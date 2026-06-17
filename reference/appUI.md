# Main Application UI for nprcgenekeepr

Main Application UI for nprcgenekeepr

## Usage

``` r
appUI(siteInfo = getSiteInfo(expectConfigFile = FALSE))
```

## Arguments

- siteInfo:

  Named list of site configuration as returned by
  [`getSiteInfo`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md);
  defaults to `getSiteInfo(expectConfigFile = FALSE)`. Its `center` and
  `configFile` elements gate the Oregon (ONPRC)-specific ORIP Reporting
  tab, which is shown only for an actual ONPRC configuration (see
  [`shouldShowOripTab`](https://github.com/rmsharp/nprcgenekeepr/reference/shouldShowOripTab.md)).
