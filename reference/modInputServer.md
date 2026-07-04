# Data Input and Quality Control Module - Server Function

Server logic for data input module handling file uploads, parsing of
pedigree and genotype data files, and quality control validation.

## Usage

``` r
modInputServer(id, config = NULL)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- config:

  optional reactive expression returning configuration data.

## Value

A list with reactive components:

- `cleanedStudbook` - The QC-cleaned studbook data

- `genotypeData` - Genotype data if provided

- `qcSummary` - Summary of QC results (error/warning counts)

- `minParentAge` - The minimum parent age value

- `isReady` - Logical indicating if data is ready for next step

## See also

[`modInputUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputUI.md)
for the user interface.

[`modPedigreeServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeServer.md)
for using the cleaned data.

Other Shiny modules:
[`modBreedingGroupsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md),
[`modBreedingGroupsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsUI.md),
[`modGeneticValueServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueServer.md),
[`modGeneticValueUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueUI.md),
[`modGvAndBgDescServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescServer.md),
[`modGvAndBgDescUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescUI.md),
[`modInputUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputUI.md),
[`modORIPReportingServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingServer.md),
[`modORIPReportingUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingUI.md),
[`modPedigreeServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeServer.md),
[`modPedigreeUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeUI.md),
[`modPotentialParentsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsServer.md),
[`modPotentialParentsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsUI.md),
[`modPyramidServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidServer.md),
[`modPyramidUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidUI.md),
[`modSummaryStatsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsServer.md),
[`modSummaryStatsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsUI.md)
