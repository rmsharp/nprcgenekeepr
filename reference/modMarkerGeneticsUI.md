# Marker Genetics Module - UI Function

Marker Genetics Module - UI Function

## Usage

``` r
modMarkerGeneticsUI(id)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

## Value

A `div` containing the marker-genetics UI: four file upload controls
(marker genotype, Center B genotype for the Cross-Center comparison,
multiallelic-tolerant linkage genotype, and locus metadata), a guidance
area, and a tab set with the Kinship Comparison, Heterozygosity,
Parentage Exclusion, Cross-Center, Candidate Parent Assignment, Linkage
and LD Block Metrics, Genomic ROH (F_ROH), and MHC Haplotype Reporting
sub-tabs. The last three sub-tabs carry their own controls and
confirm-gated de-identified exports; the MHC sub-tab also has its own
haplotype-file upload and rarity-threshold inputs.

## See also

[`modMarkerGeneticsServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsServer.md)

Other Shiny modules:
[`modBreedingGroupsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md),
[`modBreedingGroupsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsUI.md),
[`modCrossCenterIdentityServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modCrossCenterIdentityServer.md),
[`modCrossCenterIdentityUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modCrossCenterIdentityUI.md),
[`modDeidentifiedExportServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modDeidentifiedExportServer.md),
[`modDeidentifiedExportUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modDeidentifiedExportUI.md),
[`modGeneticDiversityServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityServer.md),
[`modGeneticDiversityUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityUI.md),
[`modGeneticValueServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueServer.md),
[`modGeneticValueUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueUI.md),
[`modGvAndBgDescServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescServer.md),
[`modGvAndBgDescUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescUI.md),
[`modInputServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputServer.md),
[`modInputUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputUI.md),
[`modMarkerGeneticsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsServer.md),
[`modMatePairServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMatePairServer.md),
[`modMatePairUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMatePairUI.md),
[`modORIPReportingServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingServer.md),
[`modORIPReportingUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingUI.md),
[`modPedigreeServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeServer.md),
[`modPedigreeUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeUI.md),
[`modPotentialParentsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsServer.md),
[`modPotentialParentsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsUI.md),
[`modPyramidServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidServer.md),
[`modPyramidUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidUI.md),
[`modSnapshotTrendsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSnapshotTrendsServer.md),
[`modSnapshotTrendsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSnapshotTrendsUI.md),
[`modSummaryStatsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsServer.md),
[`modSummaryStatsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsUI.md)
