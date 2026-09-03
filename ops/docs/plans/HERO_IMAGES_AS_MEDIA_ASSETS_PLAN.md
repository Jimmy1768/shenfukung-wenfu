# Hero Images As Media Assets

Status: **proposed, nothing authorized.** Written 2026-09-03 at the Director's
request after he rejected the current hero-image design.

Owner: Wenfu Planning / Director

Reference implementation: `combatives-rails`, AFL settings page. **Study it,
do not copy it** — the Director's instruction. Paths below point at the real
files so the reuse is specific rather than aspirational.

## Why this exists

The hero-image work of 2026-09-02/03 kept producing patches that turned out to
be symptoms. The Director named the actual fault in one line: **URL and upload
are two separate routes**, and Wenfu treats them as one.

`combatives-rails` already models this correctly and has done for a while.

### The one column Wenfu is missing

`academy_media_assets.storage_kind`, validated to `external_url` or `upload`,
with each branch validating its own field
(`app/models/academy_media_asset.rb:10-13`):

```text
storage_kind = "external_url"  ->  file_url present
storage_kind = "upload"        ->  source_key present
```

Wenfu has no equivalent. `temple.hero_images[tab]` holds a pasted URL *or* an
uploaded URL with nothing recording which, and `media_assets.file_uid` held a
storage key *or* a URL. **That ambiguity is what broke the Phase 0 S3
migration**, which would have rewritten seeded rows to
`prod/https://placehold.co/...`. The `file_uid`-is-not-a-URL validation added
on 2026-09-03 is a guard against the symptom; `storage_kind` is the fix.

### Column-by-column

| concern | `academy_media_assets` | Wenfu `media_assets` |
| --- | --- | --- |
| which route produced this | `storage_kind`, validated | — |
| the external URL | `file_url` | `metadata["url"]` |
| the storage key | `source_key` | `file_uid` (also holds URLs) |
| lifecycle | `status`: draft / active / archived | — |
| reclaiming the object | `after_destroy_commit :delete_uploaded_file_from_storage` | — |

The last row matters more than it looks. Combatives deletes the S3 object when
the row is destroyed, guarded by `storage_kind == "upload"` and a check that no
sibling row references the same key
(`app/models/academy_media_asset.rb:138-152`). **Wenfu's entire Phase 2 orphan
sweep exists because Wenfu never did this.** Adopting the hook makes most of
that phase unnecessary rather than merely easier.

## Why the [x] button works there and not here

```erb
<%= button_to t("...archive"), afl_archive_academy_media_path(@academy, asset),
      class: "settings-gallery-corner settings-gallery-corner--archive",
      form_class: "settings-gallery-corner-form--archive" %>
```

`app/views/afl/settings/show.html.erb:187-199`. Plain `button_to`, no
JavaScript, no Stimulus. Archive is `patch`; delete is `delete` with
`form: { data: { turbo_confirm: ... } }`.

It works because **the gallery list sits outside the upload form.** That page
has several independent forms rather than one large one.

Wenfu renders each hero slot *inside* the profile `form_with`, so `button_to`
would nest a form inside a form. Any [x] control here requires moving the hero
list out of the profile form first. That is a layout change, not a styling one,
and it is the real prerequisite.

## The decision this plan cannot make for itself

**Does `temple.hero_images` survive?**

On 2026-09-03 the render path was deliberately collapsed so `hero_images[tab]`
is the only thing read, with `MediaAsset` demoted to provenance. Combatives has
no equivalent map: the asset row *is* the record, and `resolved_file_url`
renders from it.

- **Keep the map.** Rendering stays one column read, no join, no N+1. The asset
  carries `storage_kind`, `source_key`, `status`. Cost: two places again, which
  is exactly the fault just removed — unless the map is derived, never authored.
- **Drop the map.** One representation, matching combatives. Cost: the public
  `GET /api/v1/temple` gains a query per request unless the resolved map is
  cached, and `hero_images` is a column other code reads today.

Recommendation: **keep the map as a derived cache, written only by the asset
layer, never edited directly.** That preserves today's zero-query render while
making the asset row authoritative. It needs a rule stated once and enforced:
nothing outside `MediaAssets::*` writes `temple.hero_images`.

The Director should settle this before Phase 1 starts, because every later
phase inherits it.

## Phases

Nothing here is authorized. Each phase is independently shippable.

### Phase 1 — `storage_kind` on `media_assets`

Add `storage_kind`, `file_url`, `source_key`; backfill from existing rows
(`file_uid` starting `http` becomes `external_url` + `file_url`, otherwise
`upload` + `source_key`); validate each branch. `file_uid` and
`metadata["url"]` become read-only compatibility shims, then go.

Retires the `file_uid_is_a_storage_key` validation added 2026-09-03 — it was
guarding the absence of this column.

### Phase 2 — `status`, and archive/restore/delete

`draft / active / archived`, with three routes mirroring
`config/routes.rb:565-567` in combatives. Replaces `HeroImageRemover`'s
unlink-only behaviour, which was the Director's earlier call made under a
design that had no archived state to offer.

### Phase 3 — reclaim the object on destroy

Port `delete_uploaded_file_from_storage`, including the sibling-reference guard
and the `storage_kind == "upload"` gate. Supersedes most of Phase 2 of
`MEDIA_ASSET_REMOVAL_AND_ORPHAN_RECLAMATION_PLAN.md`; that plan should be
updated, not run in parallel.

### Phase 4 — move the hero list out of the profile form

Prerequisite for the [x] control. The upload form, the URL form and the list
become separate forms on the page, as they are in the AFL settings page.

### Phase 5 — the [x] control

`button_to` corner buttons on the thumbnail. Only after Phase 4, and only
reusing the existing markup shape.

## Explicitly out of scope

- **Presigned direct-to-S3 upload.** Combatives PUTs the file straight from the
  browser (`app/javascript/controllers/afl/media_upload_controller.js`,
  `lib/uploads/presign`). Wenfu's `HeroImageUploader` takes the file through
  Rails and there is no presign infrastructure here at all. Porting it is a
  separate, larger piece of work and nothing in this plan needs it.
- **`position` / reordering.** Hero tabs are a fixed named set, not an ordered
  gallery. Reuse the pattern, not every column.
- **Gallery entries and gathering heroes.** They have their own paths and their
  own detached-asset policy. Aligning them is worth doing and is not this plan.

## Open questions for the Director

1. The `hero_images` map: keep as derived cache, or drop (see above).
2. Does archive/restore apply to hero images, or is archived state only
   meaningful for galleries where you can see the archived shelf?
3. Phase 3 deletes real files. Does hero-image delete stay behind an archive
   step, as gallery does, or is one click enough for a tab image?
