## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #130 Slice 1): modMarkerGenetics is a new, dedicated Shiny
## module (D6) surfacing a per-animal comparison of pedigree-based mean
## kinship (already in the GVA report, canonical column `indivMeanKin`) and
## the new marker-based mean kinship (`markerMeanKin`) computed from an
## uploaded D1 long-format genotype file via checkMarkerGenotypeFile() ->
## buildMarkerGenotypeMatrix() -> markerKinship(). This file spot-checks
## behavior; the exhaustive named-list-of-reactives shape check lives in
## test_moduleContract.R (module-contract.md rule 2), not duplicated here.

library(testthat)

## Same hand-verified fixture as test_markerKinship.R: parent P / offspring C
## / unrelated founder U across 10 biallelic loci.
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
genotypeFilePath <- tempfile(fileext = ".csv")
write.csv(markerGenotype, genotypeFilePath, row.names = FALSE)

## A hand-chosen, externally-supplied pedigree-based kinship matrix (this
## module never calls kinship() itself -- kinshipMatrix is an upstream
## reactive argument, matching modGeneticDiversity's precedent).
pedKinshipMatrix <- matrix(
  c(0.50, 0.25, 0.00,
    0.25, 0.50, 0.00,
    0.00, 0.00, 0.50),
  nrow = 3L,
  dimnames = list(c("P", "C", "U"), c("P", "C", "U"))
)

test_that("modMarkerGenetics is not ready before a genotype file is uploaded", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix)), {
    expect_false(isReady())
    expect_null(markerKinshipMatrix())
    expect_null(comparisonTable())
  })
})

test_that("modMarkerGenetics computes the pedigree-vs-marker comparison table", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix)), {
    session$setInputs(genotypeFile = list(
      name = "markerGenotype.csv", datapath = genotypeFilePath
    ))

    expect_true(isReady())

    kmat <- markerKinshipMatrix()
    expect_identical(dimnames(kmat), list(c("P", "C", "U"), c("P", "C", "U")))
    expect_equal(kmat["P", "C"], 0.2)

    tbl <- comparisonTable()
    expect_s3_class(tbl, "data.frame")
    expect_identical(sort(names(tbl)), sort(c("id", "indivMeanKin", "markerMeanKin")))
    expect_identical(sort(tbl$id), c("C", "P", "U"))

    tbl <- tbl[order(tbl$id), ]
    ## Pedigree-based mean kinship: colMeans() of pedKinshipMatrix.
    expect_equal(tbl$indivMeanKin[tbl$id == "P"], 0.25)
    expect_equal(tbl$indivMeanKin[tbl$id == "C"], 0.25)
    expect_equal(tbl$indivMeanKin[tbl$id == "U"], 1 / 6)

    ## Marker-based mean kinship: colMeans() of the KING-robust matrix
    ## hand-verified in test_markerKinship.R.
    expect_equal(tbl$markerMeanKin[tbl$id == "P"], 0.7 / 3)
    expect_equal(tbl$markerMeanKin[tbl$id == "C"], 0.4 / 3)
    expect_equal(tbl$markerMeanKin[tbl$id == "U"], 0.2 / 3)
  })
})
