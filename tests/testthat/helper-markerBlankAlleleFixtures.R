## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared fixtures for the tests of a blank allele in a marker genotype file
## (S977; test_buildMarkerGenotypeMatrix.R, test_markerHeterozygosity.R,
## test_modMarkerGenetics.R): the hand-checked X/Y/Z data of
## test_markerHeterozygosity.R in the long format a colony manager uploads
## (Ho: X 0.75, Y 1/3, Z 0.25; mean He 115/288 when Y has no L4 record), and
## records whose two alleles are both blank.

## Three animals at four loci, with Y's L4 record present and its two alleles
## given by `y4Allele1` and `y4Allele2` (both blank by default).
xyzGenotype <- function(y4Allele1 = NA_character_, y4Allele2 = NA_character_) {
  data.frame(
    id = rep(c("X", "Y", "Z"), each = 4L),
    locus = rep(paste0("L", 1L:4L), 3L),
    allele1 = c("A", "A", "A", "A", "A", "A", "B", y4Allele1,
                "B", "A", "A", "A"),
    allele2 = c("A", "B", "B", "B", "B", "A", "B", y4Allele2,
                "B", "A", "B", "A"),
    stringsAsFactors = FALSE
  )
}

## `xyzGenotype()` with Y's L4 record left out: the file a blank record must
## act like.
xyzGenotypeWithoutY4 <- function() {
  genotype <- xyzGenotype()
  genotype[!(genotype$id == "Y" & genotype$locus == "L4"), ]
}

## One record, with both alleles blank, for every animal in `ids` at every
## locus in `loci` (animal by animal).
blankRecords <- function(ids, loci) {
  data.frame(id = rep(ids, each = length(loci)),
             locus = rep(loci, times = length(ids)),
             allele1 = NA_character_, allele2 = NA_character_,
             stringsAsFactors = FALSE)
}
