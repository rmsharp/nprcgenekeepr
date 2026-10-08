## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Made-up data for five of the colony manager guide's nine Marker Genetics
## pictures (docs-audit slice 2, Phase 4b, S944). The genotype values are the
## hand-verified fixtures of test_modMarkerGenetics.R (the same numbers appear
## in test_markerKinship.R, test_markerHeterozygosity.R and test_markerFst.R);
## copied here, not shared, so that file stays as it was. The four other
## pictures use files the package ships (inst/extdata/examples).
##
## Plain function definitions, no testthat dependency, so
## vignettes/articles/marker-genetics-screenshots.R can source() this file
## outside the test harness (same as helper-captureHarness.R).
## tests/testthat/test_markerPictureScreenshots.R runs these data through the
## real Marker Genetics module and checks the numbers the guide's captions
## quote.

#' The data behind the made-up Marker Genetics pictures
#'
#' @return A named list of eight data frames. The five genotype files are in
#'   long format (\code{id}, \code{locus}, \code{allele1}, \code{allele2});
#'   the three pedigrees are written as an uploaded file would be, with
#'   \code{birth} as ISO text and a \code{fromCenter} column (the Candidate
#'   Parent Assignment tab finds no candidate for a pedigree without one,
#'   \code{R/getPotentialParents.R:101}).
#'   \itemize{
#'     \item \code{trioGenotype}: P, C and U at loci L1 to L10 (P is C's dam,
#'       U is unrelated).
#'     \item \code{heterozygosityGenotype}: X, Y and Z at loci L1 to L4 (Y has
#'       no L4).
#'     \item \code{centerAGenotype}, \code{centerBGenotype}: two centers at
#'       loci L1 and L2.
#'     \item \code{candidateGenotype}: the trio with U renamed Q.
#'     \item \code{comparisonPedigree}: P, Q, U and C; C's dam is P and its sire
#'       is Q, U is unrelated.
#'     \item \code{exclusionPedigree}: P, U and C; C's recorded dam is P, its
#'       recorded sire is the unrelated U.
#'     \item \code{candidatePedigree}: P, Q and C; C's recorded sire is Q.
#'   }
markerPictureFixtures <- function() {
  trioGenotype <- data.frame(
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

  heterozygosityGenotype <- data.frame(
    id = c(rep("X", 4L), rep("Y", 3L), rep("Z", 4L)),
    locus = c(paste0("L", 1L:4L), paste0("L", c(1L, 2L, 3L)),
              paste0("L", 1L:4L)),
    allele1 = c("A", "A", "A", "A", "A", "A", "B", "B", "A", "A", "A"),
    allele2 = c("A", "B", "B", "B", "B", "A", "B", "B", "A", "B", "A"),
    stringsAsFactors = FALSE
  )

  centerAGenotype <- data.frame(
    id = c(rep("CA1", 2L), rep("CA2", 2L), rep("CA3", 2L), rep("CA4", 2L)),
    locus = rep(c("L1", "L2"), 4L),
    allele1 = c("A", "A", "A", "A", "A", "A", "B", "A"),
    allele2 = c("A", "A", "A", "B", "B", "B", "B", "A"),
    stringsAsFactors = FALSE
  )
  centerBGenotype <- data.frame(
    id = c(rep("CB1", 2L), rep("CB2", 2L), rep("CB3", 2L),
           rep("CB4", 2L), rep("CB5", 2L), rep("CB6", 2L)),
    locus = rep(c("L1", "L2"), 6L),
    allele1 = c("A", "B", "B", "A", "A", "B", "B", "B", "A", "B", "B", "A"),
    allele2 = c("B", "B", "B", "B", "B", "B", "B", "B", "A", "B", "B", "B"),
    stringsAsFactors = FALSE
  )

  candidateGenotype <- trioGenotype
  candidateGenotype$id[candidateGenotype$id == "U"] <- "Q"

  comparisonPedigree <- data.frame(
    id = c("P", "Q", "U", "C"),
    sire = c(NA, NA, NA, "Q"),
    dam = c(NA, NA, NA, "P"),
    sex = c("F", "M", "M", "M"),
    birth = c("2005-01-01", "2005-01-01", "2005-01-01", "2015-01-01"),
    fromCenter = TRUE,
    stringsAsFactors = FALSE
  )
  exclusionPedigree <- data.frame(
    id = c("P", "U", "C"),
    sire = c(NA, NA, "U"),
    dam = c(NA, NA, "P"),
    sex = c("F", "M", "M"),
    birth = c("2005-01-01", "2005-01-01", "2015-01-01"),
    fromCenter = TRUE,
    stringsAsFactors = FALSE
  )
  candidatePedigree <- data.frame(
    id = c("P", "Q", "C"),
    sire = c(NA, NA, "Q"),
    dam = c(NA, NA, "P"),
    sex = c("F", "M", "M"),
    birth = c("2005-01-01", "2005-01-01", "2015-01-01"),
    fromCenter = TRUE,
    stringsAsFactors = FALSE
  )

  list(
    trioGenotype = trioGenotype,
    heterozygosityGenotype = heterozygosityGenotype,
    centerAGenotype = centerAGenotype,
    centerBGenotype = centerBGenotype,
    candidateGenotype = candidateGenotype,
    comparisonPedigree = comparisonPedigree,
    exclusionPedigree = exclusionPedigree,
    candidatePedigree = candidatePedigree
  )
}
