---
name: typslides
description: Write, edit, and build slide decks with typslides, the minimalist Typst presentation package (`@preview/typslides`). Use whenever the user wants slides, a talk, lecture, pitch, or deck made in Typst, mentions typslides, or asks to turn an outline, notes, Markdown, Beamer, or PowerPoint content into Typst slides, even if they never name the package. Covers slide types, themes, columns, frames, bibliography, building to PDF, and checking the rendered pages.
---

# typslides

typslides 1.3.4 is a small Typst package: one function per slide type, a theme color, and a few layout helpers. The whole API fits in `references/api.md`. Read it before using any argument not shown here, because inventing arguments or functions is the most common way a deck fails to compile.

## Start every deck from this preamble

```typst
#import "@preview/typslides:1.3.4": *

#show: typslides.with(
  ratio: "16-9",
  theme: "bluey",
  font: "Aptos",
  font-size: 20pt,
)
```

- `font-size: 20pt` is deliberate. The package default is 21pt, which crowds titled slides, and typslides' own attempt to shrink slide text to 20pt has no effect. Setting it here is the fix.
- Aptos is the house font. If `typst fonts | grep -i aptos` prints nothing, Typst warns and falls back to its built-in font. Tell the user and offer `font: ("Aptos", "Fira Sans")` or installing Aptos (a free Microsoft download).
- Keep the other defaults unless the user asks. Add `show-progress: true` for a progress bar along the bottom.

## Pick slide types

| Need | Function | Gallery file |
|---|---|---|
| Opening slide | `#front-slide(title:, subtitle:, authors:, info:)` | `front-slide` |
| Agenda | `#table-of-contents()` | `table-of-contents` |
| Section divider | `#title-slide[Name]` | `title-slide` |
| Normal content | `#slide(title: "…")[…]` | `slide` |
| Content without a title | `#slide[…]` (thin bar) or `#blank-slide[…]` (no bar) | `slide-untitled`, `blank-slide` |
| One big message | `#focus-slide[…]` | `focus-slide` |
| References | `#bibliography-slide(bibliography("refs.bib"))` | `bibliography-slide` |

Helpers inside a slide: `#framed[…]` or `#framed(title: "…")[…]` for callouts, `#cols[…][…]` for columns, `#grayed[…]` for a highlighted equation or statement, `#stress[…]` for emphasis in the theme color, and `#bluey[…]`, `#reddy[…]` and friends for fixed colors. Themes: `theme: "reddy"` or any `rgb(...)`.

`references/gallery/` holds one minimal source file and one rendered PNG per feature, each showing that feature alone: `<name>.typ` and `<name>.png` for every name in the table above, plus `framed`, `cols`, `grayed`, `text-colors`, `back-color`, `progress-bar`, `theme-named`, and `theme-custom`. View the PNG when you need to know what a feature looks like; copy the `.typ` when you need working syntax.

## How the layout behaves

These are the things that go wrong in practice, with why:

- **Everything goes inside a slide function.** Each call starts its own page, so there is no `#pagebreak()` between slides. Text left outside any slide function lands on a bare page with no header.
- **Slides never shrink to fit.** Only `focus-slide` resizes its text. A `slide` with too much content silently continues onto a second page under the same title. At 20pt a titled slide fits about 14 single-line bullets before spilling over, and far fewer read well. Split long content across slides or use `cols`.
- **Titles live in a one-line header bar.** Keep them under about 60 characters.
- **The contents list is built from two sources.** It lists `title-slide` sections and nests slides marked `outlined: true` beneath them. An outlined slide needs a `title` (otherwise it shows as an empty entry), and outlined titles must be unique, because identical titles merge into one entry. Without any `title-slide`, outlined slides are listed flat. The contents slide overflows like any other: it fits 8 entries (sections plus outlined slides). For longer decks, outline only the sections.
- **Use `title:`, not headings, for slide titles.** A `= Heading` inside a slide is just large body text.
- **There are no animations.** `#pause`, `#uncover`, and `#only` do not exist and fail with "unknown variable". For a step-by-step reveal, repeat the slide with progressively more content. If the user needs real overlays, say typslides cannot do it.
- **Bibliography.** Cite with `@key` in any slide. `bibliography-slide` lists only cited entries; pass `bibliography("refs.bib", full: true)` to list all of them.

## Build and check the result

Compiling is not enough: a deck can compile cleanly and still have overflowing or wrong slides. Run the bundled script, then look at the pages.

```sh
bash <skill-dir>/scripts/check.sh deck.typ
```

It writes `deck.pdf`, renders every page to `deck-render/page-NN.png`, and compares the page count to the number of slide calls. A mismatch usually means a slide overflowed; slides generated in a `#for` loop also cause one, so view the pages before concluding. Then view each rendered page and check it against what that slide should contain: page one is the front slide, and so on. Judge each page on its own; don't infer a page from its neighbors. Fix, rerun, and repeat until every page is right.

The first compile downloads the package from Typst Universe, so it needs network access once. After that it is cached.
