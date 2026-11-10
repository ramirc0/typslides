# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Typslides is a Typst Universe package (`@preview/typslides`) for minimalist slides. It is pure Typst, with no build system, test suite, or CI. This repo is a fork; upstream is `manjavacas/typslides`.

## Commands

`template/main.typ` imports `@preview/typslides:<version>`. Compiled as is, it downloads the published package and ignores local edits. Point a package path at the repo instead. The version directory MUST match the import.

```sh
mkdir -p /tmp/typpkg/preview/typslides
ln -sfn "$PWD" /tmp/typpkg/preview/typslides/1.4.0
typst compile --package-path /tmp/typpkg template/main.typ /tmp/out.pdf
```

Scratch files at the repo root can import `/lib.typ` directly. To check a computed value (the closest thing to a unit test), emit it as labeled metadata and read it back:

```typst
// probe.typ
#import "/lib.typ": *
#show: typslides.with()
#slide[#context [#metadata(text.size) <probe>]]
```

```sh
typst eval 'query(<probe>).map(it => it.value)' --in probe.typ --root .
```

After visual changes, regenerate the README screenshots and the Universe thumbnail:

```sh
typst compile --package-path /tmp/typpkg template/main.typ 'img/slide-{p}.svg'
typst compile --package-path /tmp/typpkg --pages 1 --ppi 250 template/main.typ thumbnail.png
```

## Architecture

- `lib.typ` is the package entrypoint. It re-exports an explicit, alphabetical list from `typslides.typ`. A new public function MUST be added there, or package users cannot reach it.
- `typslides.typ` holds the `typslides()` config function and every public slide and component function. `utils.typ` holds `_`-prefixed private helpers, glob-imported by `typslides.typ`.
- `typslides()`, applied with `#show: typslides.with(...)`, stores its config in `state`s (`theme-color`, `default-back-color`, `page-numbers`, `progress-enabled`, `progress-thickness`). Code that reads them with `.get()` MUST run inside `context`.
- A theme name resolves through `_theme-colors` in `utils.typ`; a color value is used as is. The color functions (`bluey`, `reddy`, ...) in `typslides.typ` hardcode the same hex values. Adding or changing a theme touches both files, the `lib.typ` exports, and the README theme list.
- Every slide function calls `set page(...)` inside `context`. That starts a new page, which is what separates slides. Only `title-slide` and `table-of-contents` also call `pagebreak()`.
- Outline: `title-slide` emits `metadata(body) <section>`. `slide(outlined: true)` emits `metadata(title) <subsection>` from its header, which is drawn in `page(background:)` and so repeats on every page of an overflowing slide. `table-of-contents` queries both labels, nests subsections under the preceding section, and calls `.dedup()` to drop those repeats.

## Typst pitfalls

- A `set` rule only applies to the rest of its enclosing block. A helper made only of set rules styles nothing for its caller. To share styles, write `(body) => { set ...; body }` and apply it with `show:`.
- `context { ... }` always returns content, never `none`. Comparing its result to `none` is always true.
- Code MUST stay compatible with `compiler` in `typst.toml` (0.14.0), which may be older than the local `typst`.

## Conventions

- The version string lives in `typst.toml`, the import in `README.md`, and the import in `template/main.typ`. All three MUST change together.
- The README Quickstart mirrors `template/main.typ`, with the nested code block commented out. Keep them in sync.
- Public functions document their purpose, arguments, and return value in a `//` comment block above the definition.
- PR bodies SHOULD follow `.github/PR_TEMPLATE.md`. GitHub does not auto-load that filename.
