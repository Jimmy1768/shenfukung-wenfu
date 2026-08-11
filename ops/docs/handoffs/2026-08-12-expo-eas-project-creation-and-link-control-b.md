# Expo EAS project creation and link — safe receipt

Date: 2026-08-12

Scope: one authorized creation attempt for the exact public Expo target
`@jimmy1768/templemate`. This receipt records safe public outcome fields only.

## Protected invocation receipt

- Installed CLI: `/opt/homebrew/bin/eas` version `18.12.2`.
- Authenticated account label: `jimmy1768`.
- Collision preflight: the exact target was absent.
- One forced, noninteractive creation attempt: successful for
  `@jimmy1768/templemate`.
- Returned project ID: `c7b8523a-2fad-4123-bc96-0c0c85a23dec`.
- The command then exited nonzero only because dynamic `app.config.js` cannot
  be modified automatically. No creation retry occurred.
- A temporary local dependency-tree symlink was created only for the protected
  call and removed afterward.

## Local reconciliation

`mobile/app.config.js` now declares owner `jimmy1768` and the exact returned
project ID at `expo.extra.eas.projectId`. Development and production resolved
public config are guarded to use the same owner and project ID.

P3 project-info and P4 resolved-config reconciliation remain pending Control's
read-only checks. This receipt contains only the project-link metadata needed
for the next bounded reconciliation step.
