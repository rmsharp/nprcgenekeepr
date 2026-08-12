# Marker Genetics Module - Server Function

Reads an uploaded long-format marker genotype file (D1 format: `id`,
`locus`, `allele1`, `allele2`), validates and pivots it
([`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md),
[`buildMarkerGenotypeMatrix`](https://github.com/rmsharp/nprcgenekeepr/reference/buildMarkerGenotypeMatrix.md)),
estimates marker-based kinship independent of pedigree
([`markerKinship`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)),
and surfaces a per-animal comparison of pedigree-based mean kinship
(`indivMeanKin`, already computed upstream and passed in via
`kinshipMatrix`) alongside the new marker-based mean kinship
(`markerMeanKin`) – an independent check on the pedigree-implied
relatedness, not a replacement for it. A second tab surfaces the
heterozygosity diagnostic: per-animal observed heterozygosity
([`markerObservedHeterozygosity`](https://github.com/rmsharp/nprcgenekeepr/reference/markerObservedHeterozygosity.md))
alongside population-level expected heterozygosity
([`markerExpectedHeterozygosity`](https://github.com/rmsharp/nprcgenekeepr/reference/markerExpectedHeterozygosity.md)).
A third tab surfaces the Mendelian-exclusion parentage diagnostic
([`markerParentageExclusion`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md)):
the `pedigree`'s recorded dam/sire cross-referenced against the uploaded
genotypes, flagging any recorded parent the genotype evidence
contradicts. A fourth tab, "Cross- Center", surfaces a
between-population differentiation statistic
([`markerFst`](https://github.com/rmsharp/nprcgenekeepr/reference/markerFst.md))
between the first uploaded file (implicitly "Center A") and a second,
independently uploaded Center B genotype file – a population-level,
two-dataset comparison, unrelated to the per-animal cross-center
identity linking of
[`resolveCrossCenterIds`](https://github.com/rmsharp/nprcgenekeepr/reference/resolveCrossCenterIds.md)
(Slice 4). A fifth tab, "Candidate Parent Assignment" (issue \#147 Slice
2), surfaces
[`markerParentageLikelihood`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageLikelihood.md):
for every (offspring, role) pair the Parentage Exclusion tab's own
diagnostic flags as Mendelian -inconsistent, it ranks candidate
replacement parents by a CERVUS-style multilocus likelihood (LOD) score.
This tab needs no new file input – it reads the same uploaded genotype
file and `pedigree` already wired to the other tabs – and is
report-only, matching the Parentage Exclusion tab's own precedent: it
never writes to `pedigree`.

## Usage

``` r
modMarkerGeneticsServer(id, kinshipMatrix, pedigree)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- kinshipMatrix:

  reactive returning the full pedigree-based kinship matrix (row and
  column names are animal IDs), or `NULL` while upstream analysis has
  not yet been run.

- pedigree:

  reactive returning the current pedigree data frame (columns `id`,
  `sire`, `dam`), or `NULL` while upstream analysis has not yet been
  run.

## Value

A list with fourteen reactive elements: `markerGenotype`, the raw
uploaded genotype data frame (or `NULL` before upload);
`markerKinshipMatrix`, the marker-based `id` x `id` kinship matrix (or
`NULL`); `comparisonTable`, the per-animal
`indivMeanKin`/`markerMeanKin` comparison data frame (or `NULL`);
`heterozygosityTable`, the per-animal `ho`/`he` heterozygosity data
frame (`he` is the population-wide mean expected heterozygosity,
repeated per row) (or `NULL`); `exclusionTable`, the
[`markerParentageExclusion`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageExclusion.md)
flagged-pairs data frame (or `NULL` before a genotype file and a
pedigree are both available); `crossCenterGenotypeB`, the raw uploaded
Center B genotype data frame (or `NULL` before upload);
`crossCenterTable`, the
[`markerFst`](https://github.com/rmsharp/nprcgenekeepr/reference/markerFst.md)
`locus`/`fst` data frame with a trailing `"Pooled"` row (or `NULL`
before both center files are uploaded); `candidateAssignmentTable`, the
[`markerParentageLikelihood`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageLikelihood.md)
ranked-candidate data frame (a zero-row, full-column-shape data frame
when no pair is flagged; or `NULL` before a genotype file and a pedigree
are both available); `isReady`, `TRUE` once `comparisonTable` has a
value; `locusMetadataTable`, the
[`checkLocusMetadata`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md)
output (or `NULL` before a locus-metadata file is uploaded);
`realizedRelatednessTable`, the
[`markerRealizedRelatednessVariance`](https://github.com/rmsharp/nprcgenekeepr/reference/markerRealizedRelatednessVariance.md)
output (or `NULL` before `pedigree`/`kinshipMatrix` are both available);
`ldBlockTable`, the
[`markerLdBlock`](https://github.com/rmsharp/nprcgenekeepr/reference/markerLdBlock.md)
output (or `NULL` before a genotype file and a locus-metadata file are
both uploaded, or before a pedigree is available if the founders-only
restriction is checked); `ldBlockExportTable`, the
[`obfuscateLdBlocks`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateLdBlocks.md)-de-identified
export preview (or `NULL` before "Generate De-Identified Export Preview"
is clicked with both `ldBlockTable` and `pedigree` available); and
`ldBlockExportConfirmed`, `FALSE` until the confirm-gate modal's own
Confirm button is clicked for the current export preview.

## Details

A sixth tab, "Linkage and LD Block Metrics" (issue \#153 Slice 5), wires
in three additional analyses. A locus-metadata file (`locus`, `chrom`,
`pos`, optionally `cM`) is validated and classified into a three-tier
coverage report
([`checkLocusMetadata`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md),
D2). The realized-relatedness-variance table
([`markerRealizedRelatednessVariance`](https://github.com/rmsharp/nprcgenekeepr/reference/markerRealizedRelatednessVariance.md),
D3a) needs only the existing `kinshipMatrix`/`pedigree` plus a
curator-supplied chromosome count and genetic-map length – no genotype
file at all. The LD-block table
([`markerLdBlock`](https://github.com/rmsharp/nprcgenekeepr/reference/markerLdBlock.md),
D3b) reads its OWN, dedicated `linkageGenotypeFile` upload –
deliberately independent of the other five tabs' shared `genotypeFile`,
since Shiny renders every `tabPanel`'s output bindings regardless of
which tab is visible: a multiallelic file uploaded through the shared
input would break the other five tabs' own DT outputs simultaneously,
not just this tab's (found empirically this session, correcting the
original PRE-RED plan). Validated through the multiallelic-tolerant
sibling validator
([`checkLinkageMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLinkageMarkerGenotypeFile.md))
rather than
[`checkMarkerGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMarkerGenotypeFile.md).
Any exported LD-block table is de-identified
([`obfuscateLdBlocks`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateLdBlocks.md))
behind a curator confirm-gate reusing
[`modDeidentifiedExportServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modDeidentifiedExportServer.md)'s
tested Generate-Preview -\> Confirm -\> Confirm-OK pattern (D9).

This module never touches the existing single-locus genotype path
(`checkGenotypeFile`/`addGenotype`/`hasGenotype`/
`getGVGenotype`/`geneDrop`) – the D1 long-format schema is a new,
sibling concern.

## See also

[`modMarkerGeneticsUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsUI.md)

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
[`modMarkerGeneticsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsUI.md),
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
[`modSummaryStatsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsServer.md),
[`modSummaryStatsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsUI.md)
