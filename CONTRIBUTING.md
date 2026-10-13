# Contributing

## Layout

Each top-level folder with a `typst.toml` is one Typst Universe package,
exactly as it gets published. `thesis/` is the first. Shared brand
colors and fonts live in `common/brand.typ`. Every package carries a
copy as `src/common.typ`, because a published package has to be
self-contained.

## Work on a template

```bash
./scripts/dev-link.sh
typst watch --package-path .dev/packages --font-path fonts thesis/template/main.typ
```

`dev-link.sh` links every package into `.dev/packages/preview/`, so the
template's `@preview/...` import resolves to your working tree instead
of the published version. For live preview in VS Code with Tinymist,
add this to the workspace settings and use an absolute path:

```json
{
  "tinymist.typstExtraArgs": ["--package-path", "/path/to/repo/.dev/packages", "--font-path", "/path/to/repo/fonts"]
}
```

After editing `common/brand.typ`, run `./scripts/sync-common.sh` to
update the copies in the packages.

## Test

```bash
./scripts/check.sh
./tests/run.sh
```

`check.sh` verifies that versions, imports, the changelog, and the
`common` copies agree. `run.sh` compiles every template as `typst init`
would create it and fails on any warning. CI runs both on every pull
request.

## Release a template

Each template has its own version. Releasing one does not touch the
others.

1. `./scripts/bump.sh thesis 0.2.0` sets the version in `typst.toml`,
   the template import, and the README.
2. Add a `### 0.2.0` section to the changelog in `thesis/README.md`.
3. If the first page changed, run `./scripts/thumbnail.sh thesis`.
4. Commit, then `./scripts/release.sh thesis`. It runs the checks and
   tests and tags `thesis-v0.2.0`.
5. `git push origin main thesis-v0.2.0`.

## Publish to Typst Universe

Publishing goes through a pull request to
[typst/packages](https://github.com/typst/packages). Fork it once under
the LS3 organization and clone it with a sparse checkout, so only your
package folders are downloaded.

```bash
git clone --filter=blob:none --sparse git@github.com:LS3-university-of-stuttgart/packages.git typst-packages
git -C typst-packages sparse-checkout set packages/preview/ls3-uni-stuttgart-thesis
```

Then, for each release:

```bash
./scripts/publish.sh thesis ../typst-packages
```

It copies the package from its release tag into the clone. Commit it
there, push, and open a pull request titled
`ls3-uni-stuttgart-thesis:0.2.0`. Typst's CI checks it and a maintainer
reviews it, usually within a few days. A published version never
changes, so every fix needs a new version.
