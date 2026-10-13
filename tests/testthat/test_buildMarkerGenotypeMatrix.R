## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #130 Slice 1): buildMarkerGenotypeMatrix() pivots a validated
## D1 long-format table (id, locus, allele1, allele2) into a wide id x locus
## character matrix -- one cell per (id, locus), holding the two alleles
## sorted alphabetically and joined by "/" (e.g. "A/B"), or NA when that
## individual has no genotype record at that locus. Row/column order follows
## first-appearance in the input (mirroring kinship()'s own input-order
## convention, not a string sort -- "L10" sorts before "L2" as a string,
## which would silently scramble locus order for >9 loci).

markerGenotype <- data.frame(
  id = c(rep("P", 10L), rep("C", 10L), rep("U", 10L)),
  locus = rep(paste0("L", 1L:10L), 3L),
  allele1 = c(
    "A", "A", "A", "B", "A", "A", "B", "A", "A", "A",
    "A", "A", "B", "A", "A", "A", "B", "A", "A", "A",
    "A", "B", "A", "A", "A", "A", "A", "B", "A", "B"
  ),
  allele2 = c(
    "A", "B", "B", "B", "A", "B", "B", "B", "A", "B",
    "B", "A", "B", "B", "A", "B", "B", "B", "B", "A",
    "B", "B", "A", "B", "B", "A", "B", "B", "B", "B"
  ),
  stringsAsFactors = FALSE
)

test_that("buildMarkerGenotypeMatrix produces the correct shape and dimnames", {
  mat <- buildMarkerGenotypeMatrix(markerGenotype)
  expect_true(is.matrix(mat))
  expect_identical(dim(mat), c(3L, 10L))
  expect_identical(rownames(mat), c("P", "C", "U"))
  expect_identical(colnames(mat), paste0("L", 1L:10L))
})

test_that("buildMarkerGenotypeMatrix sorts each cell's two alleles alphabetically", {
  mat <- buildMarkerGenotypeMatrix(markerGenotype)
  expect_identical(mat["P", "L1"], "A/A")
  expect_identical(mat["P", "L2"], "A/B")
  expect_identical(mat["P", "L4"], "B/B")
  expect_identical(mat["C", "L1"], "A/B")
  expect_identical(mat["C", "L10"], "A/A")
  expect_identical(mat["U", "L8"], "B/B")
  expect_identical(mat["U", "L10"], "B/B")
})

test_that("buildMarkerGenotypeMatrix cells are NA for a missing id x locus", {
  ## Drop P's L5 record entirely -- P is simply not genotyped at that locus.
  sparse <- markerGenotype[!(markerGenotype$id == "P" & markerGenotype$locus == "L5"), ]
  mat <- buildMarkerGenotypeMatrix(sparse)
  expect_true(is.na(mat["P", "L5"]))
  ## Every other cell is unaffected by the one dropped row.
  expect_identical(mat["C", "L5"], "A/A")
  expect_identical(mat["U", "L5"], "A/B")
})

## RED (S977; BACKLOG.md:139, S976 audit findings 1 and 7): a record with a
## missing allele is a genotype that was not read, so its cell is NA, the same
## as a record that is not in the file. Before, pmin() and pmax() of an NA
## allele gave NA and paste0() turned that into the text "NA/NA", which the
## heterozygosity, kinship, parentage and F_ROH code read as a homozygote of an
## allele named NA. A record with only one allele missing is treated the same
## way (owner ruling, S977 Pre-RED): a half-typed animal can be scored neither
## homozygous nor heterozygous.
##
## Fixture: the X/Y/Z, four-locus data of test_markerHeterozygosity.R (Y has
## no L4 record there). Here Y's L4 record is present, with its alleles blank.

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

test_that("a record with both alleles blank gives an NA cell, not the text \"NA/NA\"", {
  mat <- buildMarkerGenotypeMatrix(xyzGenotype())
  expect_true(is.na(mat["Y", "L4"]))
  expect_false(any(mat == "NA/NA", na.rm = TRUE))
  ## The typed records keep their genotypes.
  expect_identical(mat["Y", "L1"], "A/B")
  expect_identical(mat["Z", "L4"], "A/A")
})

test_that("a record with only one allele blank gives an NA cell, whichever allele is blank", {
  firstBlank <- buildMarkerGenotypeMatrix(xyzGenotype(NA_character_, "B"))
  secondBlank <- buildMarkerGenotypeMatrix(xyzGenotype("A", NA_character_))
  expect_true(is.na(firstBlank["Y", "L4"]))
  expect_true(is.na(secondBlank["Y", "L4"]))
  expect_false(any(firstBlank == "NA/NA", na.rm = TRUE))
  expect_false(any(secondBlank == "NA/NA", na.rm = TRUE))
  ## The same animal's typed cells stay typed.
  expect_identical(firstBlank["Y", "L3"], "B/B")
  expect_identical(secondBlank["Y", "L3"], "B/B")
})

test_that("a blank record gives the matrix of the file without that record", {
  blank <- xyzGenotype()
  absent <- blank[!(blank$id == "Y" & blank$locus == "L4"), ]
  ## Guard: the record really is gone from the second file.
  expect_identical(nrow(blank) - nrow(absent), 1L)
  expect_identical(buildMarkerGenotypeMatrix(blank),
                   buildMarkerGenotypeMatrix(absent))
})

test_that("an animal or a locus with only blank records keeps its row or column, all NA", {
  blankAnimal <- data.frame(id = "W", locus = paste0("L", 1L:4L),
                            allele1 = NA_character_, allele2 = NA_character_,
                            stringsAsFactors = FALSE)
  blankLocus <- data.frame(id = c("X", "Y", "Z", "W"), locus = "L5",
                           allele1 = NA_character_, allele2 = NA_character_,
                           stringsAsFactors = FALSE)
  mat <- buildMarkerGenotypeMatrix(rbind(xyzGenotype(), blankAnimal, blankLocus))
  expect_identical(dim(mat), c(4L, 5L))
  expect_identical(rownames(mat), c("X", "Y", "Z", "W"))
  expect_identical(colnames(mat), paste0("L", 1L:5L))
  expect_true(all(is.na(mat["W", ])))
  expect_true(all(is.na(mat[, "L5"])))
  ## Guard: the typed animals are not blanked with them.
  expect_false(anyNA(mat["X", 1L:4L]))
})

test_that("the shipped sequence-scale example: its 2,070 records with a blank allele become NA cells", {
  path <- system.file(
    "extdata", "examples", "example_sequence_genotypes.csv",
    package = "nprcgenekeepr"
  )
  skip_if(!nzchar(path), "the shipped example is not available")
  genotype <- getGenotypes(path, sep = ",")
  ## Guard: the example still carries blank alleles (1,015 in the first
  ## allele only, 1,032 in the second only, 23 in both).
  expect_identical(
    sum(is.na(genotype$allele1) | is.na(genotype$allele2)), 2070L
  )
  mat <- buildMarkerGenotypeMatrix(checkSequenceGenotypeFile(genotype))
  expect_identical(dim(mat), c(50L, 1000L))
  expect_false(any(mat == "NA/NA", na.rm = TRUE))
  expect_identical(sum(is.na(mat)), 2070L)
})
