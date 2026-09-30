#import "@preview/typslides:1.3.4": *
#show: typslides.with(font: "Aptos", font-size: 20pt)

#slide(title: "Citing")[Cite with @typst.]

#let bib = bibliography("refs.bib")
#bibliography-slide(bib)
