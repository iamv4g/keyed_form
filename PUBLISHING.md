# Publishing

How to publish the six packages in this workspace to pub.dev, and how to cut
a later release once v0.1.0 is out.

## Published versions

The single source of truth for "what's actually live" — `pubspec.yaml`'s
`version:` is only "what this repo intends to publish next" and can run
ahead of pub.dev mid-development. Update the row for a package the moment
step 7 of its checklist below confirms it live; a git tag
(`<package>-v<version>`, from the same step) is the audit trail if this
table and pub.dev ever disagree.

| Package             | Live version    | Published on |
|----------------------|-----------------|--------------|
| `keyed_lens`         | not yet published | — |
| `keyed_form_core`    | not yet published | — |
| `keyed_form_schema`  | not yet published | — |
| `keyed_form_gen`     | not yet published | — |
| `keyed_form`         | not yet published | — |
| `keyed_form_flutter` | not yet published | — |

## Order

Each package depends on the ones before it via a real version constraint
(`^0.1.0`), not a path — `resolution: workspace` only changes how *this repo*
resolves them locally; a consumer outside the workspace resolves from
pub.dev like any other package. So a package must already be live on pub.dev
before the one that depends on it can be published:

```
1. keyed_lens          (no workspace deps)
2. keyed_form_core     (needs keyed_lens)
3. keyed_form_schema   (needs keyed_form_core)
4. keyed_form_gen      (needs keyed_form_core; dev_dependency on
                         keyed_form_schema — doesn't block publish, but
                         publishing schema first means both are usable
                         together immediately)
5. keyed_form          (needs keyed_form_core)
6. keyed_form_flutter  (needs keyed_form)
```

Publish strictly in this order. Do not start package *N* until package
*N-1*'s new version shows as available on pub.dev (the pub.dev page updates
within a minute or two of a successful publish).

## One-time setup

```bash
dart pub login   # opens a browser; sign in with the account that owns
                 # (or will own) all six packages on pub.dev
```

## Per-package checklist (repeat for each of the 6, in order)

From the package's own directory (`packages/<name>`, not the repo root):

1. **Tests and analysis are clean.**
   ```bash
   dart analyze          # flutter analyze for keyed_form_flutter
   dart test             # flutter test for keyed_form_flutter
   ```
2. **CHANGELOG.md has an entry for the version being published**, dated if
   this isn't the first release. For v0.1.0, the existing "Initial release."
   entry is enough — do not add a date to it in retrocheck; just leave it as
   the historical first entry once published.
3. **pubspec.yaml `version:` matches what you intend to publish** and every
   `dependencies:` entry pointing at a sibling package (`keyed_lens`,
   `keyed_form_core`, …) uses a version constraint wide enough to include
   whatever's actually live on pub.dev right now.
4. **Dry run:**
   ```bash
   dart pub publish --dry-run
   ```
   Fix anything it flags (0 warnings is the bar — this repo is already
   there for all six as of this writing). A dry run validates package
   layout/pubspec/size locally; it does not prove a sibling dependency
   actually resolves from the real registry, which is why the *order* above
   matters even though dry-run alone can't catch getting it wrong.
5. **Publish for real** (prompts for confirmation — read the file listing
   it prints, then confirm):
   ```bash
   dart pub publish
   ```
6. **Tag the release** in git, from the repo root, so the exact source for
   each published version is recoverable later:
   ```bash
   git tag <package>-v<version>   # e.g. keyed_lens-v0.1.0
   ```
7. **Confirm it's live**: `https://pub.dev/packages/<package>` shows the new
   version (usually within a minute; can take a few for the analysis/score
   panel to populate). Then update that package's row in the
   [Published versions](#published-versions) table above.

## After all six are out

```bash
git push origin --tags
```

Push every tag created above in one go, once all six packages are confirmed
live — not incrementally after each one, so a mid-sequence publish failure
doesn't leave a tag on git for a version that never made it to pub.dev.

Then create a GitHub Release for each tag, using that version's own
`CHANGELOG.md` section as the release notes:

```bash
for pkg in keyed_lens keyed_form_core keyed_form_schema keyed_form_gen keyed_form keyed_form_flutter; do
  version=$(grep '^version:' "packages/$pkg/pubspec.yaml" | awk '{print $2}')
  notes=$(awk -v v="$version" '
    $0 == "## " v { flag=1; next }
    /^## /        { flag=0 }
    flag
  ' "packages/$pkg/CHANGELOG.md")
  gh release create "$pkg-v$version" --title "$pkg v$version" --notes "$notes"
done
```

This assumes each package's `CHANGELOG.md` has a `## <version>` heading for
exactly the version being released (true today; stays true as long as
["Cutting a later release"](#cutting-a-later-release-v011-after-v010-is-out)
below is followed). For a one-off release, skip the loop and run the same
`gh release create` line for just that package.

## Cutting a later release (v0.1.1+, after v0.1.0 is out)

- Only the packages that actually changed need a new version — a package
  whose dependents pin `^0.1.0` keeps resolving to it unchanged.
- Bump `version:` in that package's `pubspec.yaml`.
- Add a new `## <version>` section at the *top* of its `CHANGELOG.md`
  (newest first), describing what changed since the last published version.
- If the change also requires a newer minimum version of a sibling
  dependency, widen that `dependencies:` constraint accordingly.
- Follow the same per-package checklist above, still publishing in
  dependency order if more than one package changed together.
