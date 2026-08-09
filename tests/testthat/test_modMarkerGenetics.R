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
##
## RED (issue #130 Slice 5): the module gains a SECOND file input
## (`genotypeFileB`, Center B's marker genotype file -- the existing
## `genotypeFile` input stays Center A's, unrenamed, so Slices 1-3's
## existing reactives/tests are untouched) and a "Cross-Center" tab backed
## by a new `crossCenterTable` reactive -- markerFst() computing the
## between-population differentiation statistic from both centers' pivoted
## genotype matrices, surfaced as a locus/fst data frame with a trailing
## "Pooled" summary row.
##
## RED (issue #147 Slice 2): the module gains a 5th, read-only "Candidate
## Parent Assignment" tab backed by a new `candidateAssignmentTable`
## reactive -- markerParentageLikelihood() (Slice 1) called against the
## module's already-wired `genotypeMatrixR()`/`pedigree` reactives (no new
## file input needed, matching D10), auto-detecting every Mendelian
## -flagged (offspring, role) pair and ranking candidate replacement
## parents by LOD. Report-only, matching the Parentage Exclusion tab's own
## precedent -- the returned table never mutates `pedigree`.

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

test_that("modMarkerGeneticsUI has a Cross-Center tab", {
  ui <- modMarkerGeneticsUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("Cross-Center", ui_html))
})

## Two centers' long-format genotype files -- the same 2-locus, 4-vs-6
## individual fixture hand-verified in test_markerFst.R (perLocus L1 =
## 58/1001, L2 = 139/308, pooledFst = 614/2233).
centerAGenotype <- data.frame(
  id = c(rep("CA1", 2L), rep("CA2", 2L), rep("CA3", 2L), rep("CA4", 2L)),
  locus = rep(c("L1", "L2"), 4L),
  allele1 = c("A", "A", "A", "A", "A", "A", "B", "A"),
  allele2 = c("A", "A", "A", "B", "B", "B", "B", "A"),
  stringsAsFactors = FALSE
)
centerAGenotypeFilePath <- tempfile(fileext = ".csv")
write.csv(centerAGenotype, centerAGenotypeFilePath, row.names = FALSE)

centerBGenotype <- data.frame(
  id = c(rep("CB1", 2L), rep("CB2", 2L), rep("CB3", 2L),
         rep("CB4", 2L), rep("CB5", 2L), rep("CB6", 2L)),
  locus = rep(c("L1", "L2"), 6L),
  allele1 = c("A", "B", "B", "A", "A", "B", "B", "B", "A", "B", "B", "A"),
  allele2 = c("B", "B", "B", "B", "B", "B", "B", "B", "A", "B", "B", "B"),
  stringsAsFactors = FALSE
)
centerBGenotypeFilePath <- tempfile(fileext = ".csv")
write.csv(centerBGenotype, centerBGenotypeFilePath, row.names = FALSE)

test_that("modMarkerGenetics's cross-center table is not ready before both center files are uploaded", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "centerA.csv", datapath = centerAGenotypeFilePath
    ))
    expect_null(result$crossCenterTable())
  })
})

test_that("modMarkerGenetics computes the cross-center Fst table from two uploaded center files", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "centerA.csv", datapath = centerAGenotypeFilePath
    ))
    session$setInputs(genotypeFileB = list(
      name = "centerB.csv", datapath = centerBGenotypeFilePath
    ))

    tbl <- result$crossCenterTable()
    expect_s3_class(tbl, "data.frame")
    expect_identical(sort(names(tbl)), sort(c("locus", "fst")))
    expect_identical(sort(tbl$locus), c("L1", "L2", "Pooled"))

    expect_equal(tbl$fst[tbl$locus == "L1"], 58 / 1001, tolerance = 1e-6)
    expect_equal(tbl$fst[tbl$locus == "L2"], 139 / 308, tolerance = 1e-6)
    expect_equal(tbl$fst[tbl$locus == "Pooled"], 614 / 2233, tolerance = 1e-6)
  })
})

test_that("modMarkerGeneticsUI has a Candidate Parent Assignment tab", {
  ui <- modMarkerGeneticsUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("Candidate Parent Assignment", ui_html))
})

test_that("modMarkerGenetics's candidate-parent-assignment table is not ready before a pedigree is supplied", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "markerGenotype.csv", datapath = genotypeFilePath
    ))
    expect_null(result$candidateAssignmentTable())
  })
})

test_that("modMarkerGenetics computes a candidate-parent-assignment table for a flagged pair", {
  skip_if_not_installed("shiny")
  ## Same P/C/U fixture as the Parentage Exclusion tests above: C's recorded
  ## sire is falsely set to the unrelated founder U (3 exclusion loci vs C,
  ## exceeding the default maxExclusions = 2 -> flagged); C's recorded dam P
  ## is the true parent (0 exclusions -> not flagged, so trio conditioning
  ## applies). Only (C, "sire") is auto-detected. getPotentialParents() is
  ## mocked (matching test_markerParentageLikelihood.R's own established
  ## convention) to supply a single fixed sire candidate ("U") for C, since
  ## this minimal fixture's pedigree has none of getPotentialParents()'s own
  ## required demographic columns (birth/fromCenter/sex) -- this reactive
  ## test verifies WIRING (the tab calls markerParentageLikelihood() against
  ## the module's real genotypeMatrix/pedigree reactives and renders its
  ## real output), not a re-derivation of the LOD formula itself (already
  ## exhaustively hand-verified in test_markerParentageLikelihood.R). U's
  ## LOD == -Inf here is empirically confirmed (this session's Pre-RED, a
  ## standalone script calling the real, current markerParentageLikelihood()
  ## against this exact fixture) rather than assumed: ANY Mendelian
  ## -incompatible (opposite-homozygote) locus forces LOD to exactly -Inf
  ## under the no-error-model formula regardless of trio conditioning
  ## (test_markerParentageLikelihood.R's own finding (a), confirmed to
  ## generalize to the trio case there too), and the Parentage Exclusion tab
  ## test above already confirms U has 3 such loci against C.
  pedigree <- data.frame(id = c("P", "C", "U"), sire = c(NA, "U", NA),
                          dam = c(NA, "P", NA), stringsAsFactors = FALSE)
  testthat::local_mocked_bindings(
    getPotentialParents = function(ped, ...) {
      list(list(id = "C", sires = "U", dams = character(0L)))
    },
    .package = "nprcgenekeepr"
  )

  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(pedigree)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "markerGenotype.csv", datapath = genotypeFilePath
    ))

    tbl <- result$candidateAssignmentTable()
    expect_s3_class(tbl, "data.frame")
    expect_identical(sort(names(tbl)),
                      sort(c("id", "role", "candidateId", "LOD", "delta",
                              "nLociUsed", "excluded", "lowPower")))
    expect_identical(nrow(tbl), 1L)
    expect_identical(tbl$id, "C")
    expect_identical(tbl$role, "sire")
    expect_identical(tbl$candidateId, "U")
    expect_identical(tbl$LOD, -Inf)
    expect_identical(tbl$nLociUsed, 10L)
    expect_true(tbl$excluded)
    expect_false(tbl$lowPower)
    expect_true(is.na(tbl$delta)) # sole candidate: no next-ranked row below it
  })
})

test_that("modMarkerGenetics's candidate-parent-assignment table is an empty-but-valid data frame when nothing is flagged", {
  skip_if_not_installed("shiny")
  ## Both recorded parents Mendelian-consistent (C has no recorded sire at
  ## all; its recorded dam P has 0 exclusions) -- no pair is flagged, so
  ## markerParentageLikelihood() returns its zero-row emptyResult() WITHOUT
  ## calling getPotentialParents() (confirmed by reading
  ## markerParentageLikelihood()'s own auto-detect branch: the
  ## nrow(flags) == 0L guard returns before that call, and empirically
  ## confirmed this session's Pre-RED against this exact fixture) -- unlike
  ## the flagged-pair test above, no mock is needed here.
  pedigree <- data.frame(id = c("P", "C", "U"), sire = c(NA, NA, NA),
                          dam = c(NA, "P", NA), stringsAsFactors = FALSE)

  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(pedigree)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "markerGenotype.csv", datapath = genotypeFilePath
    ))

    tbl <- result$candidateAssignmentTable()
    expect_s3_class(tbl, "data.frame")
    expect_identical(nrow(tbl), 0L)
    expect_identical(sort(names(tbl)),
                      sort(c("id", "role", "candidateId", "LOD", "delta",
                              "nLociUsed", "excluded", "lowPower")))
  })
})
