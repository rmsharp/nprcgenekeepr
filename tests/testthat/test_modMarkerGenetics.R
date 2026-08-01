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
##
## RED (issue #130 Slice 2): the module gains a "Heterozygosity" tab
## (mirroring modPedigree's tabsetPanel(tabPanel("Table", ...),
## tabPanel("Diagram", ...)) pattern -- here tabPanel("Kinship Comparison",
## ...) alongside a new tabPanel("Heterozygosity", ...)) and a new
## `heterozygosityTable` reactive: a per-animal id/ho/he data.frame, where
## `ho` is markerObservedHeterozygosity() (per-animal) and `he` is
## markerExpectedHeterozygosity()'s population-wide meanHe repeated on
## every row -- a direct observed-vs-expected diagnostic comparison, same
## shape convention as the existing indivMeanKin/markerMeanKin table.
##
## RED (issue #130 Slice 3): the module gains a new `pedigree` reactive
## server parameter (matching modGeneticDiversity/modPotentialParents'
## precedent) and a "Parentage Exclusion" tab backed by a new
## `exclusionTable` reactive -- markerParentageExclusion() cross-referenced
## against the pedigree's recorded dam/sire, surfaced as a flagged-pairs
## table (module-contract canonical `flagged` vocabulary).

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
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    expect_false(result$isReady())
    expect_null(result$markerKinshipMatrix())
    expect_null(result$comparisonTable())
  })
})

test_that("modMarkerGenetics computes the pedigree-vs-marker comparison table", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "markerGenotype.csv", datapath = genotypeFilePath
    ))

    expect_true(result$isReady())

    kmat <- result$markerKinshipMatrix()
    expect_identical(dimnames(kmat), list(c("P", "C", "U"), c("P", "C", "U")))
    expect_equal(kmat["P", "C"], 0.2)

    tbl <- result$comparisonTable()
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

test_that("modMarkerGeneticsUI has a Kinship Comparison / Heterozygosity / Parentage Exclusion tabsetPanel", {
  ui <- modMarkerGeneticsUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("Kinship Comparison", ui_html))
  expect_true(grepl("Heterozygosity", ui_html))
  expect_true(grepl("Parentage Exclusion", ui_html))
})

test_that("modMarkerGenetics computes the per-animal Ho vs. population He heterozygosity table", {
  skip_if_not_installed("shiny")
  ## Same hand-verified fixture as test_markerHeterozygosity.R: X/Y/Z across
  ## 4 biallelic loci, Y missing L4. Ho: X=0.75, Y=1/3, Z=0.25. Mean He
  ## (population, across all 4 loci): 115/288.
  hetGenotype <- data.frame(
    id = c(rep("X", 4L), rep("Y", 3L), rep("Z", 4L)),
    locus = c(paste0("L", 1L:4L), paste0("L", c(1L, 2L, 3L)), paste0("L", 1L:4L)),
    allele1 = c("A", "A", "A", "A", "A", "A", "B", "B", "A", "A", "A"),
    allele2 = c("A", "B", "B", "B", "B", "A", "B", "B", "A", "B", "A"),
    stringsAsFactors = FALSE
  )
  hetGenotypeFilePath <- tempfile(fileext = ".csv")
  write.csv(hetGenotype, hetGenotypeFilePath, row.names = FALSE)

  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "hetGenotype.csv", datapath = hetGenotypeFilePath
    ))

    tbl <- result$heterozygosityTable()
    expect_s3_class(tbl, "data.frame")
    expect_identical(sort(names(tbl)), sort(c("id", "ho", "he")))

    tbl <- tbl[order(tbl$id), ]
    expect_equal(tbl$ho[tbl$id == "X"], 0.75)
    expect_equal(tbl$ho[tbl$id == "Y"], 1 / 3)
    expect_equal(tbl$ho[tbl$id == "Z"], 0.25)

    ## Population-wide meanHe is repeated on every row for direct
    ## per-animal observed-vs-expected comparison.
    expect_equal(tbl$he[tbl$id == "X"], 115 / 288)
    expect_equal(tbl$he[tbl$id == "Y"], 115 / 288)
    expect_equal(tbl$he[tbl$id == "Z"], 115 / 288)
  })
})

test_that("modMarkerGenetics computes a Mendelian-exclusion parentage table against the recorded pedigree", {
  skip_if_not_installed("shiny")
  ## Same P/C/U fixture as above. C's recorded dam is P (the true
  ## parent/offspring pair per test_markerKinship.R) -- 0 exclusions,
  ## verified by this slice's Pre-RED standalone reference script. C's
  ## recorded sire is falsely set to U (the unrelated founder) -- 3
  ## exclusions (L2, L3, L10), exceeding the default maxExclusions = 2, so
  ## it must be flagged.
  pedigree <- data.frame(id = c("P", "C", "U"), sire = c(NA, "U", NA),
                          dam = c(NA, "P", NA), stringsAsFactors = FALSE)

  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(pedigree)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "markerGenotype.csv", datapath = genotypeFilePath
    ))

    tbl <- result$exclusionTable()
    expect_s3_class(tbl, "data.frame")
    expect_identical(sort(names(tbl)),
                      sort(c("id", "parentId", "role", "exclusionCount",
                              "nLoci", "flagged")))
    expect_identical(nrow(tbl), 2L)

    cDam <- tbl[tbl$id == "C" & tbl$role == "dam", ]
    expect_identical(cDam$parentId, "P")
    expect_identical(cDam$exclusionCount, 0L)
    expect_false(cDam$flagged)

    cSire <- tbl[tbl$id == "C" & tbl$role == "sire", ]
    expect_identical(cSire$parentId, "U")
    expect_identical(cSire$exclusionCount, 3L)
    expect_true(cSire$flagged)
  })
})

test_that("modMarkerGenetics's exclusion table is not ready before a pedigree is supplied", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "markerGenotype.csv", datapath = genotypeFilePath
    ))
    expect_null(result$exclusionTable())
  })
})
