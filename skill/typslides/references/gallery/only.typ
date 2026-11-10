#import "@preview/typslides:1.4.0": *
#show: typslides.with(font: "Aptos", font-size: 20pt)

#slide(title: "Only")[
  #only(1)[#framed[Only on subslide 1]]
  #only("2-")[#framed[From subslide 2 on]]
  #only(3)[#framed[Only on subslide 3]]

  Shown on every subslide. It moves when a frame above it appears.
]
