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

Other Shiny modules:
[`modBreedingGroupsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md),
[`modBreedingGroupsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsUI.md),
[`modGeneticValueServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueServer.md),
[`modGeneticValueUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueUI.md),
[`modGvAndBgDescServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescServer.md),
[`modGvAndBgDescUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescUI.md),
[`modInputServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputServer.md),
[`modInputUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputUI.md),
[`modORIPReportingUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingUI.md),
[`modPedigreeServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeServer.md),
[`modPedigreeUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeUI.md),
[`modPotentialParentsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsServer.md),
[`modPotentialParentsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsUI.md),
[`modPyramidServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidServer.md),
[`modPyramidUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidUI.md),
[`modSummaryStatsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsServer.md),
[`modSummaryStatsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsUI.md)
