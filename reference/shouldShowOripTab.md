# Determine if the ORIP Reporting tab should be displayed

Copyright(c) 2017-2025 R. Mark Sharp This file is part of nprcgenekeepr

## Usage

``` r
shouldShowOripTab(center, hasConfigFile)
```

## Arguments

- center:

  Character scalar naming the colony center, as returned by
  `getSiteInfo()$center` (e.g. "ONPRC" or "SNPRC"). `NULL`, missing
  values, or any value other than "ONPRC" yield FALSE.

- hasConfigFile:

  Logical scalar indicating whether an actual site configuration file is
  present (e.g. `file.exists(getSiteInfo()$configFile)`). When FALSE the
  colony center is the default fallback and the tab is not shown.

## Value

Logical. TRUE if a real ONPRC configuration is active and the tab should
be shown, FALSE otherwise.

## Details

Determines whether the Oregon (ONPRC)-specific ORIP Reporting tab should
be shown in the application navigation. ORIP (Office of Research
Infrastructure Programs) grant reporting is specific to ONPRC, so the
tab is shown only when an actual site configuration file is present
*and* it identifies the colony as ONPRC. The
[`getSiteInfo`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
default fallback (`center = "ONPRC"` when no configuration file exists)
does NOT show the tab.

## See also

[`getSiteInfo`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
for the site configuration source and
[`shouldShowChangedColsTab`](https://github.com/rmsharp/nprcgenekeepr/reference/shouldShowChangedColsTab.md)
for the sibling tab-visibility predicate.

## Examples

``` r
library(nprcgenekeepr)
shouldShowOripTab("ONPRC", TRUE)  # TRUE
#> [1] TRUE
shouldShowOripTab("SNPRC", TRUE)  # FALSE
#> [1] FALSE
shouldShowOripTab("ONPRC", FALSE) # FALSE (default fallback, no config file)
#> [1] FALSE
```
