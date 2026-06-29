# Save Plot to File

Helper function to save ggplot2 plots to files with consistent settings
and error handling. Supports PNG, PDF, and SVG formats with configurable
dimensions and resolution.

## Usage

``` r
savePlotToFile(
  plot,
  file,
  format = NULL,
  width = 8L,
  height = 6L,
  dpi = 150L,
  units = "in",
  bg = "white"
)
```

## Arguments

- plot:

  A ggplot2 plot object to save. If NULL, returns FALSE.

- file:

  character. The file path to save the plot to.

- format:

  character. Output format: "png", "pdf", or "svg". Defaults to "png".
  If not specified, format is inferred from file extension.

- width:

  numeric. Plot width in inches. Defaults to 8.

- height:

  numeric. Plot height in inches. Defaults to 6.

- dpi:

  numeric. Resolution in dots per inch for raster formats. Defaults to
  150 for good quality web/screen use. Use 300 for print.

- units:

  character. Units for width and height. Defaults to "in" (inches).

- bg:

  character. Background color. Defaults to "white".

## Value

Logical. TRUE if the file was saved successfully, FALSE otherwise.

## See also

[`ggsave`](https://ggplot2.tidyverse.org/reference/ggsave.html) for the
underlying save function

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)
p <- ggplot(mtcars, aes(mpg, wt)) + geom_point()
savePlotToFile(p, "my_plot.png")
savePlotToFile(p, "my_plot.pdf", format = "pdf")
savePlotToFile(p, "high_res.png", dpi = 300)
} # }
```
