# Draw the Pedigree Browser's Diagram from a mating layout

Returns the interactive diagram the Pedigree Browser's Diagram tab
shows, as a `visNetwork` widget, for a layout made by
[`makePedigreeMatingLayout`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md).
The Shiny application draws its Diagram with this function, so a script
that calls it gets the same picture: the sex symbols at the layout's
fixed positions, the legend (the five sex symbols, one row per affected
condition or a single “Affected” row, “Deceased”, and the dashed
repeat-appearance and twin lines), each multi-condition symbol split
into its colored sections, the slash through each deceased animal's
symbol, a canvas that grows with the number of conditions, the **Export
Diagram (PNG)** button, a “Select by id” box that lists the animals, and
the highlight on hover. The sections and the slash are painted by a
drawing script inside the widget, so they appear wherever the widget is
shown: in the RStudio viewer, in an R Markdown or Quarto document, or in
a web page saved with
[`htmlwidgets::saveWidget()`](https://rdrr.io/pkg/htmlwidgets/man/saveWidget.html).

## Usage

``` r
drawPedigreeDiagram(
  layout,
  edgeStyle = c("rectilinear", "direct"),
  onClick = NULL
)
```

## Arguments

- layout:

  the list returned by
  [`makePedigreeMatingLayout`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md).

- edgeStyle:

  the `edgeStyle` the layout was made with, `"rectilinear"` (the
  default) or `"direct"`. It sets how far the hover highlight reaches: 6
  steps under `"rectilinear"`, whose invisible routing points count as
  steps, and 1 under `"direct"`.

- onClick:

  `NULL` (the default), or a JavaScript function, as a character string,
  that runs when the diagram is clicked. The Shiny application passes
  one that sends the clicked animal to the server.

## Value

A `visNetwork` widget, 500 pixels tall, 45 more for each affected
condition past the first (at most four are drawn).

## Details

Clicking an animal re-centers the Shiny application's Diagram on it;
that needs a live Shiny session, so a script leaves `onClick` out.

## See also

[`makePedigreeMatingLayout`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)

## Examples

``` r
library(nprcgenekeepr)
layout <- makePedigreeMatingLayout(nprcgenekeepr::smallPed)
diagram <- drawPedigreeDiagram(layout)
## Print `diagram` in an interactive session to see it, or save it as a web
## page with htmlwidgets::saveWidget(diagram, "pedigree.html").
```
