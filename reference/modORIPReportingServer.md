# ORIP Reporting Module - Server Function

Server logic for ORIP reporting module. Generates summary statistics and
formatted reports for Office of Research Infrastructure Programs
submissions.

## Usage

``` r
modORIPReportingServer(
  id,
  pedigree = NULL,
  geneticValues = NULL,
  siteConfig = NULL
)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- pedigree:

  reactive returning pedigree data frame.

- geneticValues:

  reactive returning genetic value analysis results.

- siteConfig:

  reactive returning site configuration from getSiteInfo().

## Value

A list with reactive components for ORIP reporting.

## See also

[`modORIPReportingUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingUI.md)
for the user interface

[`getSiteInfo`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
for site configuration
