---
name: typslides
description: Write, edit, and build slide decks with typslides, the minimalist Typst presentation package (`@preview/typslides`). Use whenever the user wants slides, a talk, lecture, pitch, or deck made in Typst, mentions typslides, or asks to turn an outline, notes, Markdown, Beamer, or PowerPoint content into Typst slides, even if they never name the package. Covers slide types, themes, columns, frames, `#pause`, `#only` and `#uncover` overlays, bibliography, building to PDF, and checking the rendered pages.
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

`references/gallery/` holds one minimal source file and one rendered PNG per feature, each showing that feature alone: `<name>.typ` and `<name>.png` for every name in the table above, plus `framed`, `cols`, `grayed`, `text-colors`, `back-color`, `progress-bar`, `theme-named`, `theme-custom`, `pause`, `only`, and `uncover`. The overlay PNGs show every subslide side by side. View the PNG when you need to know what a feature looks like; copy the `.typ` when you need working syntax.

## How the layout behaves

These are the things that go wrong in practice, with why:

- **Everything goes inside a slide function.** Each call starts its own page, so there is no `#pagebreak()` between slides. Text left outside any slide function lands on a bare page with no header.
- **Slides never shrink to fit.** Only `focus-slide` resizes its text. A `slide` with too much content silently continues onto a second page under the same title. At 20pt a titled slide fits about 14 single-line bullets before spilling over, and far fewer read well. Split long content across slides or use `cols`.
- **Titles live in a one-line header bar.** Keep them under about 60 characters.
- **The contents list is built from two sources.** It lists `title-slide` sections and nests slides marked `outlined: true` beneath them. An outlined slide needs a `title` (otherwise it shows as an empty entry), and outlined titles must be unique, because identical titles merge into one entry. Without any `title-slide`, outlined slides are listed flat. The contents slide overflows like any other: it fits 8 entries (sections plus outlined slides). For longer decks, outline only the sections.
- **Use `title:`, not headings, for slide titles.** A `= Heading` inside a slide is just large body text.
- **Bibliography.** Cite with `@key` in any slide. `bibliography-slide` lists only cited entries; pass `bibliography("refs.bib", full: true)` to list all of them.

## Overlays

`#pause`, `#only` and `#uncover` split a `slide` or `blank-slide` into subslides, like Beamer overlays. Each subslide is its own PDF page. All of them share one page number, and the progress bar advances on each.

```typst
#slide(title: "Overlays")[
  #only(1)[Only on subslide 1]
  #uncover("2-")[From subslide 2 on, with its space kept on subslide 1]

  - Shown on every subslide
  #pause
  - Shown from subslide 2 on
]
```

- **Overlays need typslides 1.4.0.** Version 1.3.4 fails with "unknown variable: pause". Import `@preview/typslides:1.4.0` in a deck with overlays. If that import fails with "package not found", 1.4.0 is not on Universe yet. Then link a clone of `github.com/manjavacas/typslides` as `<dir>/preview/typslides/1.4.0` and set `TYPST_PACKAGE_PATH=<dir>`. Without either, repeat the slide with progressively more content.
- **`#pause` works only at the top level of the slide body.** Between list items is fine. Inside `#framed[…]`, `#cols[…]` or `#align(center)[…]` it is ignored without an error. Use `#set align(center)` instead of `#align`, and wrap parts of frames or columns in `#uncover`.
- **Hidden content keeps its space, except with `#only`.** Content after a `#pause` or in a hidden `#uncover` is invisible but still laid out, so nothing moves. `#only` takes no space where it is hidden, so text below it shifts. Prefer `#uncover` unless the content should be replaced.
- **The slide gets one subslide more than its pauses, or the highest subslide named in a spec, whichever is larger.** An `#only` or `#uncover` nested inside `#framed` is not counted, so a subslide that only it needs never appears. Set the count by hand: `#slide(subslides: 3)[…]`.
- **A `#pause` also hides later `#only` and `#uncover` until its subslide arrives.** Put them before the first `#pause`.
- **Use overlays only in `slide` and `blank-slide`.** Other slide types do not split. There, `#only` and `#uncover` read the last subslide of the previous overlay slide and can hide their content.

## Speaker notes

typslides has no notes feature. When the user wants speaker notes, add this after the preamble:

```typst
#let note(body) = {
  assert(type(body) == str, message: "note takes a string")
  [#metadata(body) <speaker-note>]
}
#show: deck => {
  deck
  context pdf.attach(
    "notes.pdfpc",
    bytes(json.encode((
      pdfpcFormat: 2,
      pages: query(<speaker-note>).map(n => (
        idx: n.location().page() - 1,
        label: str(n.location().page()),
        overlay: 0,
        note: n.value,
      )),
    ))),
    mime-type: "application/json",
  )
}
```

Then write `#note("Mention the **control group**.")` inside a slide body. The snippet attaches the notes to the PDF as `notes.pdfpc` (pdfpc format 2 JSON) and adds no pages. The `ppm` presenter reads that attachment and shows each page's notes as Markdown.

- **Notes are strings.** `note` takes a Markdown string. Content in brackets fails the assert, because it would encode as a JSON tree.
- **Notes go inside slide bodies only.** A note in a `title-slide` body or an outlined slide title also lands on the contents page, which re-renders titles. A note outside any slide attaches to the next page.
- **A note belongs to the page it lands on.** On a slide that overflows, each note goes with the part of the slide around it. Notes inside `cols`, `framed` and `focus-slide` work. Several notes on one page are shown together, in order. On an overlay slide, every note repeats on each subslide, including notes after a `#pause`.

## Build and check the result

Compiling is not enough: a deck can compile cleanly and still have overflowing or wrong slides. Run the bundled script, then look at the pages.

```sh
bash <skill-dir>/scripts/check.sh deck.typ
```

It writes `deck.pdf`, renders every page to `deck-render/page-NN.png`, and compares the page count to the number of slide calls. A mismatch usually means a slide overflowed; slides generated in a `#for` loop and overlay subslides also cause one, so view the pages before concluding. Then view each rendered page and check it against what that slide should contain: page one is the front slide, and so on. Judge each page on its own; don't infer a page from its neighbors. Fix, rerun, and repeat until every page is right.

The first compile downloads the package from Typst Universe, so it needs network access once. After that it is cached.
