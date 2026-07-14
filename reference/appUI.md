# Main Application UI for nprcgenekeepr

Main Application UI for nprcgenekeepr

## Usage

``` r
appUI(siteInfo = NULL)
```

## Arguments

- siteInfo:

  Named list of site configuration as returned by
  [`getSiteInfo`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md);
  defaults to `NULL`, in which case it is resolved internally via
  `getSiteInfo(expectConfigFile = FALSE)`. A present-but-malformed
  site-config file makes that call fail; the failure is caught and
  logged
  ([`futile.logger::flog.warn`](https://rdrr.io/pkg/futile.logger/man/flog.logger.html))
  rather than propagating, and the UI falls back to hiding the ORIP
  Reporting tab. Its `center` and `configFile` elements gate the Oregon
  (ONPRC)-specific ORIP Reporting tab, which is shown only for an actual
  ONPRC configuration (see
  [`shouldShowOripTab`](https://github.com/rmsharp/nprcgenekeepr/reference/shouldShowOripTab.md)).

## Value

A `shiny.tag.list` object (as produced by
[`shiny::tagList()`](https://rstudio.github.io/htmltools/reference/tagList.html))
describing the complete GeneKeepR user interface; pass it as the `ui`
argument to
[`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html) or
[`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html).
