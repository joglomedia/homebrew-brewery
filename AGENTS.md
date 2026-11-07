# Agent guide

This guide applies to the entire repository. Use it when maintaining this Homebrew
tap with an AI coding CLI. Follow the user's requested scope and preserve unrelated
work in the checkout.

## Repository layout

- Tap: `joglomedia/brewery`.
- Remote: `https://github.com/joglomedia/homebrew-brewery.git`.
- `Casks/stockbit.rb`: unofficial Stockbit desktop cask for macOS.
- `Formula/curl-impersonate.rb`: prebuilt curl-impersonate binaries from the
  `lexiforest/curl-impersonate` GitHub releases, for macOS and Linux.
- `README.md`: user-facing installation and usage instructions.

There is currently no repository test runner, Gemfile, or CI workflow. Use Homebrew's
tools and the formula's existing `test do` block. Read versions from the package
files; do not treat versions mentioned in prior conversations as current.

## Before editing

1. Run `git status --short`, inspect the current branch and remotes, and read the
   affected package, README, and recent relevant commits.
2. Check for existing user edits before modifying or staging files.
3. Confirm the requested upstream release and the exact asset for each supported
   platform. A successful HTTP response alone does not verify an artifact.
4. Keep downloads, mounted images, and investigation output outside the repository,
   using a task-specific directory created with `mktemp -d`.

Use `rg` for repository searches. Keep changes focused on the affected package and
documentation that actually needs updating. Do not add dependencies, CI, or new
test frameworks for a routine version bump.

## Download and checksum verification

- Download the actual release file over HTTPS, following redirects and failing on
  HTTP errors. For example, use `curl --fail --location --show-error` with a quoted
  URL and an explicit output path.
- Compute SHA-256 from the downloaded bytes with `shasum -a 256 <file>` on macOS or
  `sha256sum <file>` on Linux. Compare published upstream checksums when available.
- Update each version or versioned URL together with its matching checksum. Never
  guess a checksum, reuse one from another asset, or replace it with `:no_check` to
  make a pinned release install.
- Inspect the archive or image contents to confirm the expected executable or app
  is present. Do not commit release binaries or generated validation output.

## Stockbit cask

The release URL follows this pattern:

```text
https://sda-release-v2.stockbit.com/release/<version>/macos/Stockbit.dmg
```

1. Preserve the interpolated `#{version}` URL and `user_agent: :fake` setting. Use a
   browser user agent such as `--user-agent 'Mozilla/5.0'` for manual downloads.
2. On macOS, run `hdiutil verify <dmg>`, then attach the image with
   `hdiutil attach -readonly -nobrowse -mountpoint <temporary-mountpoint> <dmg>`.
3. Confirm `Stockbit.app` exists. Inspect `Contents/Info.plist` with `plutil -p` and
   check `CFBundleShortVersionString`, `CFBundleVersion`, `CFBundleIdentifier`, and
   `LSMinimumSystemVersion` against the release and cask metadata.
4. Inspect `Contents/MacOS/Stockbit` with `file` or `lipo -archs`. The existing cask
   uses one DMG for Intel and Apple Silicon; verify that assumption for new releases.
5. Check the app signature with `codesign --verify --deep --strict --verbose=2
   <app-path>`. This verifies the bundle signature, not notarization or runtime
   behavior. Detach the image with `hdiutil detach <temporary-mountpoint>` afterward.
6. Update `version` and `sha256`. Keep `app "Stockbit.app"`, `auto_updates true`,
   `depends_on :macos`, and the existing zap paths unless upstream changes justify
   adjusting them. Do not broaden zap paths speculatively.

Keep the Indonesian description concise, under 80 characters, without repeating
the cask name at the start or adding a final period.

The current `livecheck` extracts a plist from the version-pinned download URL. It
can inspect that artifact's version but does not independently discover a newer
release. Do not use it as proof that the pinned version is the latest.

## curl-impersonate formula

Update all four release URLs and their individual SHA-256 values together:

| Homebrew branch | Upstream asset suffix |
| --- | --- |
| macOS ARM | `arm64-macos.tar.gz` |
| macOS Intel | `x86_64-macos.tar.gz` |
| Linux ARM | `aarch64-linux-gnu.tar.gz` |
| Linux Intel | `x86_64-linux-gnu.tar.gz` |

The asset names currently follow
`curl-impersonate-v<version>.<asset-suffix>` under the matching GitHub release tag.
Verify the actual release assets instead of assuming the naming scheme persists.

- Inspect each archive with `tar -tzf <archive>` and confirm the binary and browser
  wrapper scripts match the existing `bin.install Dir["curl*"]` installation logic.
- Preserve the `ca-certificates` dependency and the existing formula test unless
  the release requires a documented change.
- Check whether browser wrapper names or supported impersonation profiles changed;
  update the README examples when necessary.
- Do not infer cross-platform correctness from downloading only the host's asset.

## Validation

Run these checks for each changed Ruby file, substituting its path:

```sh
ruby -c Casks/stockbit.rb
brew style Casks/stockbit.rb
git diff --check
```

Homebrew's named-package commands may read a separately installed copy of this tap.
Compare `brew --repository joglomedia/brewery` with the working checkout before
using them. Ensure validation exercises the edited files.

Some Homebrew versions reject package paths outside a registered tap. In that case,
run this from the checkout root to create a temporary local validation tap. Copy
only the package being checked; set `package_file` to
`Formula/curl-impersonate.rb` for a formula change:

```sh
validation_tap="local-validation/brewery-$(date +%s)"
package_file="Casks/stockbit.rb"
brew tap-new --no-git "$validation_tap"
validation_repo=$(brew --repository "$validation_tap")
mkdir -p "$validation_repo/$(dirname "$package_file")"
cp "$package_file" "$validation_repo/$package_file"
```

If Homebrew requires trust, trust only the specific candidate being checked, using
`brew trust --cask "$validation_tap/stockbit"` or
`brew trust --formula "$validation_tap/curl-impersonate"`. Do not disable Homebrew's
trust checks globally. Set `HOMEBREW_NO_AUTO_UPDATE=1` for the following commands to
avoid an unrelated tap refresh during validation.

For a Stockbit change, run on macOS:

```sh
HOMEBREW_NO_AUTO_UPDATE=1 brew fetch --cask "$validation_tap/stockbit"
HOMEBREW_NO_AUTO_UPDATE=1 brew audit --cask --strict "$validation_tap/stockbit"
```

For a curl-impersonate change:

```sh
HOMEBREW_NO_AUTO_UPDATE=1 brew fetch --formula --all-platforms "$validation_tap/curl-impersonate"
HOMEBREW_NO_AUTO_UPDATE=1 brew audit --formula --strict "$validation_tap/curl-impersonate"
```

For changes to formula installation or executable behavior, install and test the
candidate in a disposable or task-authorized environment, then run
`brew test <tap>/curl-impersonate`. Testing an already installed older version does
not validate the candidate. A fetch or audit does not prove an application launches.

Consult `brew help <command>` if the local Homebrew version uses different flags.
On Linux, verify Stockbit's download and checksum but report that DMG inspection,
code-signature validation, and macOS installation checks were not performed.

After validation, remove the temporary tap with `brew untap "$validation_tap"`
**before** removing its package trust entries: untap may need to load the cask.
Use the corresponding `brew untrust --cask` or `brew untrust --formula` command for
each entry added. Detach mounted images before deleting temporary files. Restore
Homebrew developer mode if validation enabled it and it was previously disabled.

## Delivery and Git workflow

- Review `git diff --check`, `git diff`, and `git status --short` before finishing.
- Summarize the package/version change, validation performed, and any checks that
  could not run. Distinguish pre-existing failures from regressions.
- Stage only task-related files. Use a concise commit subject such as
  `Update Stockbit to v<version>`.
- Commit and push when requested or already authorized for the current work. Check
  the actual branch and upstream; do not assume `master` or force-push to resolve
  divergence. Preserve unrelated commits and user changes.
- After pushing, verify the remote update succeeded and report the commit and any
  remaining working-tree changes.
