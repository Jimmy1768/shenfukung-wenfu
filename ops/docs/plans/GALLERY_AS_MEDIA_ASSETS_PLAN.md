# Gallery As Media Assets

Status: **proposed, nothing authorized.** Written 2026-09-03.

Owner: Wenfu Planning / Director

Reference implementation: `combatives-rails`, AFL settings page. **Study it,
do not copy it** — the Director's instruction. Paths below point at the real
files so the reuse is specific rather than aspirational.

## Scope — this is the gallery, not hero images

Originally written against hero images. The Director redirected it: the robust
media-asset machinery belongs on the **gallery**, which is the surface that
actually needs it. Hero images are a fixed set of eight named slots and stay
simple.

**Hero images are out of scope.** They keep `temple.hero_images`, the single
render path established 2026-09-03, and a plain Remove button under each
image. No archive, no status, no per-slot media-asset lifecycle. If the
gallery work later makes some of it free, that is a separate conversation.

## Why the gallery needs it

`temple_gallery_entries.photo_urls` is a **jsonb array of bare URL strings**:

```ruby
t.jsonb "photo_urls", default: [], null: false
```

Consequences, all live today:

- **A photo has no identity.** It is a string in an array. Nothing records
  whether it was pasted or uploaded, when, or by whom.
- **Nothing links a photo to its `MediaAsset`.** `MediaAssets::ManagedUploader`
  creates rows with `file_uid` set to the storage key, but the entry stores
  only the resulting URL. The two are associated by coincidence of value.
- **`Admin::GalleryEntriesController#destroy` destroys the entry and leaves
  every photo in S3 permanently.** No sweep, no reclamation, no record.
- **A single photo cannot be removed from an entry** except by editing the raw
  URL list, which has exactly the failure mode the hero images had.

This is the same fault as the hero images had, in a worse form: there the map
at least had named keys.

## What combatives already solved

### `storage_kind` — the Director's "URL and upload are two separate routes"

`academy_media_assets.storage_kind`, validated to `external_url` or `upload`,
each branch validating its own field (`app/models/academy_media_asset.rb:10-13`):

```text
storage_kind = "external_url"  ->  file_url present
storage_kind = "upload"        ->  source_key present
```

Wenfu has no equivalent anywhere. `media_assets.file_uid` held a storage key
*or* a URL, and **that ambiguity is what broke the Phase 0 S3 migration**,
which would have rewritten seeded rows to `prod/https://placehold.co/...`. The
`file_uid`-is-not-a-URL validation added 2026-09-03 guards the symptom;
`storage_kind` is the fix.

### Column-by-column

| concern | `academy_media_assets` | Wenfu today |
| --- | --- | --- |
| which route produced this | `storage_kind`, validated | — |
| the external URL | `file_url` | `metadata["url"]` |
| the storage key | `source_key` | `file_uid` (also holds URLs) |
| lifecycle | `status`: draft / active / archived | — |
| ordering | `position` + reorder route | — |
| reclaiming the object | `after_destroy_commit :delete_uploaded_file_from_storage` | — |

The last row matters most. Combatives deletes the S3 object when the row is
destroyed, guarded by `storage_kind == "upload"` and a check that no sibling
row references the same key (`app/models/academy_media_asset.rb:138-152`).
**Wenfu's orphan-reclamation phase exists because that hook was never
written.** Adopting it makes most of that phase unnecessary rather than
merely easier.

### The corner controls, and what they actually are

```erb
<%= button_to t("...gallery.archive"), afl_archive_academy_media_path(@academy, asset),
      method: :patch, class: "settings-gallery-corner--archive" %>
<%= button_to t("...gallery.delete_symbol"), afl_delete_academy_media_path(@academy, asset),
      method: :delete, form: { data: { turbo_confirm: t("...delete_confirm") } } %>
```

`app/views/afl/settings/show.html.erb:187-199`. Plain `button_to`, no
JavaScript, no Stimulus. It works because **the gallery list sits outside the
upload form** — that page has several independent forms rather than one large
one. Any Wenfu gallery page must be laid out the same way, which is free since
it is being built rather than retrofitted.

## Director's ruling 2026-09-03: archive is the gate

**Adding archive is what makes S3 delete safe. Delete is reachable only from
the archived state, never directly from a live image.**

This makes Phase 2 the precondition for Phase 3, not merely the step before
it. Reclaiming a file is irreversible, so the reversible step has to exist
first and the operator has to have passed through it.

**Stricter than the reference.** In combatives an active gallery card carries
both controls side by side:

```text
left pill   "Archive"        patch, reversible
right [x]   delete_symbol ×  delete, permanent, turbo_confirm
```

So its `[x]` is *delete*, and a live image can be destroyed in one click plus
a confirm. Wenfu will not. On a live gallery photo the only destructive
control is archive; delete appears solely in the archived list, beside
Restore — and the `×` glyph should not be reused for archive, since on the
page it came from it means delete.

## Phases

Nothing here is authorized. Each phase is independently shippable.

### Phase 1 — `storage_kind` on `media_assets`

Add `storage_kind`, `file_url`, `source_key`; backfill from existing rows
(`file_uid` starting `http` becomes `external_url` + `file_url`, otherwise
`upload` + `source_key`); validate each branch. `file_uid` and
`metadata["url"]` become read-only shims, then go.

Retires the `file_uid_is_a_storage_key` validation added 2026-09-03, which was
guarding the absence of this column.

Hero images use `media_assets` too, so this phase touches them — but only as
the provenance record they already are. Their render path does not change.

### Phase 2 — `status`, and archive / restore / delete

`draft / active / archived`, three routes mirroring
`config/routes.rb:565-567` in combatives, and an archived shelf below the live
list as in the reference screenshot.

### Phase 3 — reclaim the object on destroy

**Blocked on Phase 2 by ruling, not just by sequence.** No S3 delete ships
until archive exists and delete is reachable only from the archived list.

Port `delete_uploaded_file_from_storage` with its sibling-reference guard and
`storage_kind == "upload"` gate. Supersedes most of Phase 2 of
`MEDIA_ASSET_REMOVAL_AND_ORPHAN_RECLAMATION_PLAN.md`; that plan should be
updated rather than run in parallel.

### Phase 4 — gallery entries reference assets, not strings

Replace `photo_urls`'s bare strings with references to `MediaAsset` rows, so a
photo has identity, provenance and a lifecycle. This is the phase that makes
the other three worth having, and the one with real migration work: existing
`photo_urls` entries must be matched to their `MediaAsset` rows by URL, and
any that match nothing need a decision.

### Phase 5 — the gallery admin page

Built on the layout the reference uses: separate upload form, separate URL
form, and the list outside both so `button_to` works without nesting.

## Explicitly out of scope

- **Hero images.** See Scope above. They keep the simple map and a Remove
  button.
- **Presigned direct-to-S3 upload.** Combatives PUTs the file straight from the
  browser (`app/javascript/controllers/afl/media_upload_controller.js`,
  `lib/uploads/presign`). Wenfu's uploaders take the file through Rails and
  there is no presign infrastructure here at all. Porting it is separate,
  larger, and nothing in this plan needs it.
- **Gathering heroes.** `TempleGathering` already carries `hero_image_url` plus
  `metadata["hero_asset_id"]` and destroys its asset. Aligning it is worth
  doing and is not this plan.

## Open questions for the Director

1. Does the gallery keep `photo_urls` as a derived cache for rendering, the way
   hero images keep their map, or does it read assets directly?
2. Archived photos: visible only in the admin, or does an archived photo
   disappear from the public gallery immediately? (In combatives, archived is
   simply not `active`, so it stops rendering.)
3. Phase 4's migration will find `photo_urls` entries that match no
   `MediaAsset` — pasted external URLs, most likely. Do those become
   `external_url` assets, or stay as they are?
