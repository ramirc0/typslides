# typslides 1.3.4 API

Everything below is exported by `#import "@preview/typslides:1.3.4": *`. Nothing else exists: no overlays (`#pause`, `#uncover`, `#only`), no speaker notes, no footer text, no logo slot.

## Configuration

```typst
#show: typslides.with(
  ratio: "16-9",            // "16-9" or "4-3"
  theme: "bluey",           // name below, or any color: rgb("0F766E")
  font: "Aptos",            // family name or fallback list ("Aptos", "Fira Sans")
  font-size: 20pt,          // package default is 21pt; set 20pt explicitly
  link-style: "color",      // "color", "underline", or "both"
  show-page-numbers: true,  // "n / total" in the header bar or corner
  show-progress: false,     // thin progress bar along the bottom edge
  progress-height: 3pt,
  back-color: white,        // default background for every slide
)
```

Theme names: `bluey`, `reddy`, `greeny`, `yelly`, `purply`, `dusky`, `darky` (black). The theme color fills header bars, frame titles, focus slides, dividers, links, references, footnote marks, and `stress`.

## Slides

Each call is one slide and starts a new page. Every slide also takes `back-color` (default: the global `back-color`; for `focus-slide`, the theme color).

| Signature | Notes |
|---|---|
| `front-slide(title: none, subtitle: none, authors: none, info: none, margin: auto)` | Opening slide. Title in bold, divider line, then authors and `info` (theme color). All named arguments. |
| `table-of-contents(title: "Contents", text-size: 23pt)` | Numbered list of `title-slide` sections, with `outlined` slides nested under the preceding section. Entries are links. |
| `title-slide(body, text-size: 42pt)` | Section divider. Registers a section for the contents. Divider shows deck progress. |
| `slide(title: none, outlined: false, margin: none, body)` | Workhorse. With `title`: theme header bar with title and page number. Without: thin bar only. `outlined: true` lists the title in the contents. Body is vertically centered. |
| `focus-slide(text-color: white, text-size: 60pt, body)` | Full theme-color background, centered semibold text shrunk until it fits. |
| `blank-slide(body)` | No header bar; page number in the top-right corner. Body vertically centered. |
| `bibliography-slide(bib-call, title: "References")` | Pass a `bibliography(...)` value: `#let bib = bibliography("refs.bib")` then `#bibliography-slide(bib)`. |

`margin` on `slide` overrides the page margin (default `(x: 1.6cm, top: 2.5cm, bottom: 1.2cm)` with a title). On `front-slide` it is passed to the page as is.

## Content helpers

| Signature | Notes |
|---|---|
| `framed(title: none, back-color: none, body)` | Rounded box with a 2pt black border. Without title: cream fill, width fits content. With title: theme-color title bar, full width, white body. |
| `cols(columns: none, gutter: 1em, ..bodies)` | Grid with one column per trailing content block: `#cols[a][b]`. `columns` is an array of widths like `(2fr, 1fr)` and its length must equal the number of blocks, or compilation fails. |
| `grayed(text-size: 24pt, fill-color: rgb("#F3F2F0"), body)` | Centered light-gray box. Good for a key equation or statement. |
| `stress(body)` | Theme color, semibold. |
| `bluey`, `reddy`, `greeny`, `yelly`, `purply`, `dusky` `(body)` | Fixed text colors matching the theme names. |

## Plain Typst inside slides

Lists (`-`, `+`), emphasis, `$math$`, raw code blocks, `table`, `figure`, `image`, `link`, footnotes, and `@key` citations all work as in any Typst document. Size images relative to the slide: `#image("fig.png", height: 70%)`.

Citations need a `bibliography(...)` somewhere in the document, normally the one passed to `bibliography-slide`. Only cited entries are listed unless you pass `full: true`.
