# Run the GeneKeepR Shiny Application

Launches the GeneKeepR Shiny application. It uses a module-based
architecture with a Home tab and improved UI components. The call blocks
the R session until the application is stopped.

## Usage

``` r
runGeneKeepR(port = 6013L, launch.browser = TRUE)
```

## Arguments

- port:

  Integer port number for the Shiny server (default 6013)

- launch.browser:

  Logical; whether to launch browser (default TRUE)

## Value

Called for its side effect; blocks until the app is stopped. Returns,
invisibly, the value passed to
[`shiny::stopApp()`](https://rdrr.io/pkg/shiny/man/stopApp.html)
(normally `NULL`).

## Details

The application has 16 top-level tabs (15 when the ORIP Reporting tab is
hidden) and a "More" menu (Settings, About, Help):

- Home tab with navigation buttons

- Input tab with enhanced QC display, plus dynamic error and changed
  columns tabs

- Pedigree Browser with focal animal support and a Diagram tab

- Age-Sex Pyramid with enhanced controls

- Genetic Value Analysis with visualizations

- Summary Statistics with popovers

- ORIP Reporting (shown only for the ONPRC site configuration)

- Breeding Groups with group panels

- Mate Pair Analysis

- Genetic Diversity

- Marker Genetics

- Cross-Center Identity

- De-Identified Export

- Potential Parents

- Genetic Value Analysis and Breeding Group Description

- Genetic-Health Trends

[`runModularApp`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
is a soft-deprecated alias for this function.

## See also

[`runModularApp`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md),
a soft-deprecated alias for this function.

## Examples

``` r
if (FALSE) { # \dontrun{
library(nprcgenekeepr)
runGeneKeepR()
} # }
```
