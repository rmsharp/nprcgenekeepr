# Data Input and Quality Control Module - Server Function

Server logic for data input module handling file uploads, parsing of
pedigree and genotype data files, and quality control validation.

## Usage

``` r
modInputServer(id)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

## Value

A list with reactive components:

- `cleanedStudbook` - The QC-cleaned studbook data

- `genotypeData` - Genotype data if provided

- `qcSummary` - Summary of QC results (error/warning counts)

- `minSireAge` - The minimum sire age floor (numeric, or `NULL` to use
  the species+sex breeding-age table default)

- `minDamAge` - The minimum dam age floor (numeric, or `NULL` to use the
  species+sex breeding-age table default)

- `isReady` - Logical indicating if data is ready for next step

- `debugMode` - Logical reflecting the Input tab's "Debug on" checkbox

- `changedCols` - Renamed/changed-column diagnostics from QC

- `errorLst` - The QC error list, used for dynamic tab management

- `pedigreeFileName` - The uploaded file's name, used for dynamic tab
  management

## Note

(Developer note) This module is the reference implementation of the
package's internal Shiny module contract – see
`docs/architecture/module-contract.md` in the package source (a
developer-only file; it does not ship with the installed package).

## See also

[`modInputUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputUI.md)
for the user interface.

[`modPedigreeServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeServer.md)
for using the cleaned data.

Other Shiny modules:
[`modBreedingGroupsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md),
[`modBreedingGroupsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsUI.md),
[`modGeneticDiversityServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityServer.md),
[`modGeneticDiversityUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityUI.md),
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
