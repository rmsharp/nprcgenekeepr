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

## RED (issue #155): the Candidate Parent Assignment tab must surface a
## NON-empty table when a flagged animal's recorded parent is present but
## wrong -- found live (S498's own Phase 3E smoke test) rendering an empty
## table against exactly this scenario. Unlike the "flagged pair" test above,
## getPotentialParents() is NOT mocked here -- this is the live-wiring
## regression the bug escaped every existing (mocked) test to reach.
## Individuals are deliberately NOT named "U" (the P/C/U fixture's founder id
## elsewhere in this file) -- an id starting with "U" is the package's
## default auto-generated-unknown-id prefix (getAutoIdFormat() -> "U%04d")
## and is silently stripped/nulled by getPotentialParents()'s own internal
## removeAutoGenIds() call, found at this session's Pre-RED. Same
## SireTrue/SireWrong/Dam/C fixture as test_markerParentageLikelihood.R's own
## issue #155 tests -- same hand-verified LOD values apply.
markerGenotypeFlaggedSlot <- data.frame(
  id = c(rep("C", 4L), rep("SireTrue", 4L), rep("Dam", 4L), rep("SireWrong", 4L)),
  locus = rep(paste0("L", 1L:4L), 4L),
  allele1 = c("A", "B", "A", "A", "A", "B", "A", "A",
              "A", "B", "A", "A", "B", "A", "B", "B"),
  allele2 = c("A", "B", "A", "B", "A", "B", "A", "A",
              "A", "B", "A", "B", "B", "A", "B", "B"),
  stringsAsFactors = FALSE
)
genotypeFilePathFlaggedSlot <- tempfile(fileext = ".csv")
write.csv(markerGenotypeFlaggedSlot, genotypeFilePathFlaggedSlot, row.names = FALSE)

pedigreeFlaggedSlot <- data.frame(
  id    = c("SireTrue", "SireWrong", "Dam", "C"),
  sire  = c(NA, NA, NA, "SireWrong"),
  dam   = c(NA, NA, NA, "Dam"),
  sex   = c("M", "M", "F", "M"),
  birth = as.Date(c("1990-01-01", "1990-01-01", "1990-01-01", "2005-01-01")),
  exit  = as.Date(rep(NA, 4L)),
  fromCenter = rep(TRUE, 4L),
  stringsAsFactors = FALSE
)

test_that("modMarkerGenetics's candidate-parent-assignment table is non-empty for a real (non-mocked) recorded-but-wrong-parent fixture (issue #155)", {
  skip_if_not_installed("shiny")

  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(pedigreeFlaggedSlot)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "markerGenotypeFlaggedSlot.csv", datapath = genotypeFilePathFlaggedSlot
    ))

    tbl <- result$candidateAssignmentTable()
    expect_s3_class(tbl, "data.frame")
    expect_identical(nrow(tbl), 2L) # previously 0 rows -- the bug being fixed
    expect_identical(sort(tbl$candidateId), c("SireTrue", "SireWrong"))

    strue <- tbl[tbl$candidateId == "SireTrue", ]
    expect_equal(strue$LOD, 0.8630462173553427, tolerance = 1e-6)
    expect_false(strue$excluded)

    ## D3(a): the flagged/wrong recorded parent (SireWrong) stays visible.
    swrong <- tbl[tbl$candidateId == "SireWrong", ]
    expect_identical(swrong$LOD, -Inf)
    expect_true(swrong$excluded)
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

## RED (issue #153 Slice 5): the module gains a sixth tab, "Linkage and LD
## Block Metrics" (D5, D6 -- opt-in, zero change to the 5 existing tabs),
## wiring markerRealizedRelatednessVariance() (D3a, Slice 3) and
## markerLdBlock()/obfuscateLdBlocks() (D3b/D9, Slice 4) into the module,
## alongside a locus-metadata coverage-report panel (checkLocusMetadata(),
## Slice 1, D2/sec 2.14's three-tier PLINK-style model) and a
## curator-controlled export gate for the LD-block table reusing issue
## #150's confirm-gate pattern (modDeidentifiedExportServer's tested
## Generate-Preview -> Confirm -> Confirm-OK sequence). The multiallelic
## -tolerant genotype path (checkLinkageMarkerGenotypeFile(), Slice 2)
## reuses the SAME uploaded genotypeFile as the other 5 tabs, validated by
## a new, parallel reactive -- no new genotype file input; only a new
## locusMetadataFile input is added (owner-ratified, this session's
## PRE-RED).

i153GenotypeFilePath <- system.file(
  "extdata", "examples", "example_str_marker_genotypes.csv",
  package = "nprcgenekeepr"
)
i153LocusMetadataFilePath <- system.file(
  "extdata", "examples", "example_locus_metadata.csv",
  package = "nprcgenekeepr"
)

## Ad hoc pedigree over the STR fixture's own A01-A10 ids (no pedigree
## ships with that fixture). A01-A05 are founders (sire/dam both NA);
## A06-A10 are not. Built solely to exercise the founder-restriction
## checkbox -- not meant to be biologically realistic.
i153FoundersPed <- data.frame(
  id = sprintf("A%02d", 1L:10L),
  sire = c(rep(NA_character_, 5L), rep("A01", 5L)),
  dam = c(rep(NA_character_, 5L), rep("A02", 5L)),
  stringsAsFactors = FALSE
)

test_that("modMarkerGeneticsUI has a Linkage and LD Block Metrics tab with its controls", {
  ui <- modMarkerGeneticsUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("Linkage and LD Block Metrics", ui_html, fixed = TRUE))
  expect_true(grepl("linkageGenotypeFile", ui_html, fixed = TRUE))
  expect_true(grepl("locusMetadataFile", ui_html, fixed = TRUE))
  expect_true(grepl("nChr", ui_html, fixed = TRUE))
  expect_true(grepl("mapLength", ui_html, fixed = TRUE))
  expect_true(grepl("ldBlockFoundersOnly", ui_html, fixed = TRUE))
  expect_true(grepl("ldBlockExportPreview", ui_html, fixed = TRUE))
  expect_true(grepl("ldBlockConfirmExport", ui_html, fixed = TRUE))
  expect_true(grepl("downloadLdBlockExport", ui_html, fixed = TRUE))
})

test_that("modMarkerGeneticsUI has a persistent, non-dismissable D3(b) caveat banner", {
  ui <- modMarkerGeneticsUI("test")
  ui_html <- as.character(ui)

  ## Static markup (not a renderUI toggle) -- always present, no close/
  ## dismiss control, matching the "persistent, non-dismissable" design
  ## requirement literally rather than as a togglable notification.
  expect_true(grepl("not a rigorous, pedigree-aware", ui_html, fixed = TRUE))
  expect_false(grepl("dismiss", ui_html, ignore.case = TRUE))
})

test_that("modMarkerGenetics's locusMetadataTable is not ready before a locus-metadata file is uploaded", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    expect_null(result$locusMetadataTable())
  })
})

test_that("modMarkerGenetics's locusMetadataTable classifies the STR fixture into 8 full/2 partial/2 none", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(locusMetadataFile = list(
      name = "example_locus_metadata.csv", datapath = i153LocusMetadataFilePath
    ))

    tbl <- result$locusMetadataTable()
    expect_s3_class(tbl, "data.frame")
    expect_identical(sort(names(tbl)),
                      sort(c("locus", "chrom", "pos", "cM", "coverage")))
    expect_identical(nrow(tbl), 12L)
    expect_identical(sum(tbl$coverage == "full"), 8L)
    expect_identical(sum(tbl$coverage == "partial"), 2L)
    expect_identical(sum(tbl$coverage == "none"), 2L)
  })
})

test_that("modMarkerGenetics's realizedRelatednessTable is not ready before a pedigree is supplied", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    expect_null(result$realizedRelatednessTable())
  })
})

test_that("modMarkerGenetics's realizedRelatednessTable is not ready before kinshipMatrix is available", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(nprcgenekeepr::smallPed)), {
    result <- session$getReturned()
    expect_null(result$realizedRelatednessTable())
  })
})

test_that("modMarkerGenetics's realizedRelatednessTable uses the nChr=20/mapLength=28 default when inputs are unset", {
  skip_if_not_installed("shiny")
  ped <- nprcgenekeepr::smallPed
  kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)

  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(kmat),
                pedigree = shiny::reactive(ped)), {
    result <- session$getReturned()

    tbl <- result$realizedRelatednessTable()
    expect_s3_class(tbl, "data.frame")
    expect_identical(sort(names(tbl)),
                      sort(c("id1", "id2", "kinship", "relation", "R", "varR", "sdR")))

    ## Parent-Offspring varR is exactly 0 regardless of nChr/mapLength
    ## (test_markerRealizedRelatednessVariance.R's own finding) -- a
    ## robust wiring check independent of which default values are
    ## actually used.
    dg <- tbl[tbl$id1 == "D" & tbl$id2 == "G", ]
    expect_identical(nrow(dg), 1L)
    expect_identical(dg$relation, "Parent-Offspring")
    expect_equal(dg$varR, 0)
  })
})

test_that("modMarkerGenetics's realizedRelatednessTable respects explicit nChr/mapLength inputs", {
  skip_if_not_installed("shiny")
  ped <- nprcgenekeepr::smallPed
  kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)

  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(kmat),
                pedigree = shiny::reactive(ped)), {
    result <- session$getReturned()
    session$setInputs(nChr = 1L, mapLength = 1)
    tblSmall <- result$realizedRelatednessTable()

    session$setInputs(nChr = 20L, mapLength = 28)
    tblDefault <- result$realizedRelatednessTable()

    fsSmall <- tblSmall[tblSmall$id1 == "F" & tblSmall$id2 == "G", ]
    fsDefault <- tblDefault[tblDefault$id1 == "F" & tblDefault$id2 == "G", ]
    expect_false(isTRUE(all.equal(fsSmall$varR, fsDefault$varR)))
  })
})

test_that("modMarkerGenetics's ldBlockTable is not ready before a genotype file is uploaded", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(locusMetadataFile = list(
      name = "example_locus_metadata.csv", datapath = i153LocusMetadataFilePath
    ))
    expect_null(result$ldBlockTable())
  })
})

test_that("modMarkerGenetics's ldBlockTable is not ready before a locus-metadata file is uploaded", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(linkageGenotypeFile = list(
      name = "example_str_marker_genotypes.csv", datapath = i153GenotypeFilePath
    ))
    expect_null(result$ldBlockTable())
  })
})

test_that("modMarkerGenetics computes the LD-block table matching Slice 4's hand-verified STR values", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(linkageGenotypeFile = list(
      name = "example_str_marker_genotypes.csv", datapath = i153GenotypeFilePath
    ))
    session$setInputs(locusMetadataFile = list(
      name = "example_locus_metadata.csv", datapath = i153LocusMetadataFilePath
    ))

    tbl <- result$ldBlockTable()
    expect_s3_class(tbl, "data.frame")

    row12 <- tbl[tbl$locus1 == "STR01" & tbl$locus2 == "STR02", ]
    expect_equal(row12$Dprime, 0.606061, tolerance = 1e-5)
    expect_equal(row12$r2, 0.288889, tolerance = 1e-5)
    expect_equal(row12$nUsed, 10L)
    expect_true(is.na(row12$idsUsed))

    row34 <- tbl[tbl$locus1 == "STR03" & tbl$locus2 == "STR04", ]
    expect_equal(row34$Dprime, 0.662317, tolerance = 1e-5)
    expect_equal(row34$r2, 0.498590, tolerance = 1e-5)
  })
})

test_that("modMarkerGenetics's ldBlockTable restricts to founders when the checkbox is set", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(i153FoundersPed)), {
    result <- session$getReturned()
    session$setInputs(linkageGenotypeFile = list(
      name = "example_str_marker_genotypes.csv", datapath = i153GenotypeFilePath
    ))
    session$setInputs(locusMetadataFile = list(
      name = "example_locus_metadata.csv", datapath = i153LocusMetadataFilePath
    ))
    session$setInputs(ldBlockFoundersOnly = TRUE)

    tbl <- result$ldBlockTable()
    row12 <- tbl[tbl$locus1 == "STR01" & tbl$locus2 == "STR02", ]
    expect_identical(row12$idsUsed, "A01,A02,A03,A04,A05")
    expect_identical(row12$nUsed, 5L)
  })
})

test_that("modMarkerGenetics's ldBlockTable is not ready when founder-restricted with no pedigree loaded", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(linkageGenotypeFile = list(
      name = "example_str_marker_genotypes.csv", datapath = i153GenotypeFilePath
    ))
    session$setInputs(locusMetadataFile = list(
      name = "example_locus_metadata.csv", datapath = i153LocusMetadataFilePath
    ))
    session$setInputs(ldBlockFoundersOnly = TRUE)

    expect_null(result$ldBlockTable())
  })
})

test_that("modMarkerGenetics's ldBlockExportConfirmed starts FALSE", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    expect_false(result$ldBlockExportConfirmed())
  })
})

test_that("modMarkerGenetics's ldBlockExportTable is NULL before Generate Export Preview is clicked", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(i153FoundersPed)), {
    result <- session$getReturned()
    session$setInputs(linkageGenotypeFile = list(
      name = "example_str_marker_genotypes.csv", datapath = i153GenotypeFilePath
    ))
    session$setInputs(locusMetadataFile = list(
      name = "example_locus_metadata.csv", datapath = i153LocusMetadataFilePath
    ))
    expect_null(result$ldBlockExportTable())
  })
})

test_that("modMarkerGenetics's ldBlockExportTable de-identifies idsUsed via obfuscateLdBlocks after Generate Export Preview", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(i153FoundersPed)), {
    result <- session$getReturned()
    session$setInputs(linkageGenotypeFile = list(
      name = "example_str_marker_genotypes.csv", datapath = i153GenotypeFilePath
    ))
    session$setInputs(locusMetadataFile = list(
      name = "example_locus_metadata.csv", datapath = i153LocusMetadataFilePath
    ))
    session$setInputs(ldBlockFoundersOnly = TRUE)
    session$setInputs(ldBlockExportPreview = 1)

    raw <- result$ldBlockTable()
    exported <- result$ldBlockExportTable()
    expect_s3_class(exported, "data.frame")

    rawRow <- raw[raw$locus1 == "STR01" & raw$locus2 == "STR02", ]
    exportedRow <- exported[exported$locus1 == "STR01" & exported$locus2 == "STR02", ]

    expect_false(identical(exportedRow$idsUsed, rawRow$idsUsed))
    expect_false(grepl("A01", exportedRow$idsUsed, fixed = TRUE))
    expect_equal(exportedRow$Dprime, rawRow$Dprime)
    expect_equal(exportedRow$nUsed, rawRow$nUsed)
  })
})

test_that("modMarkerGenetics's ldBlockExportConfirmed becomes TRUE after the full confirm sequence", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(i153FoundersPed)), {
    result <- session$getReturned()
    session$setInputs(linkageGenotypeFile = list(
      name = "example_str_marker_genotypes.csv", datapath = i153GenotypeFilePath
    ))
    session$setInputs(locusMetadataFile = list(
      name = "example_locus_metadata.csv", datapath = i153LocusMetadataFilePath
    ))
    session$setInputs(ldBlockExportPreview = 1)
    session$setInputs(ldBlockConfirmExport = 1)
    session$setInputs(ldBlockConfirmExportOk = 1)

    expect_true(result$ldBlockExportConfirmed())
  })
})

test_that("modMarkerGenetics's ldBlockExportTable stays NULL after Generate Export Preview with no pedigree loaded", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(linkageGenotypeFile = list(
      name = "example_str_marker_genotypes.csv", datapath = i153GenotypeFilePath
    ))
    session$setInputs(locusMetadataFile = list(
      name = "example_locus_metadata.csv", datapath = i153LocusMetadataFilePath
    ))
    session$setInputs(ldBlockExportPreview = 1)

    expect_null(result$ldBlockExportTable())
  })
})

## ---------------------------------------------------------------------
## RED (issue #152 Slice 5): a new "Genomic ROH (F_ROH)" tab. Per this
## slice's own Pre-RED AskUserQuestion ratification: (Q1) genome-scale
## kinship/heterozygosity/Fst reruns are NOT a new dedicated tab/inputs --
## they come for free once genotypeMatrixR()/genotypeMatrixBR() validate
## via checkSequenceGenotypeFile() (a confirmed strict superset of
## checkMarkerGenotypeFile()) instead, so the EXISTING genotypeFile/
## genotypeFileB inputs and the Kinship Comparison/Heterozygosity/Cross-
## Center tabs are reused unchanged, not duplicated. (Q2) F_ROH's
## locusMetadata sidecar reuses the EXISTING locusMetadataFile input
## (already wired to issue #153's own Linkage and LD Block Metrics tab,
## same checkLocusMetadata() schema, D3's own shared-vocabulary intent) --
## no second locus-metadata upload. (Q3) the curator-gated de-identified
## export covers exactly 3 artifacts: the de-identified sequence genotype
## matrix (obfuscateGenotypeMatrix(), Slice 4), the de-identified F_ROH
## table (obfuscateGenomicROH(), new this slice), and a transformation
## manifest -- mirroring modDeidentifiedExport.R's 3-artifact shape.
##
## Fixture: reuses test_computeGenomicROH.R's own hand-verified
## coreGenotypeMatrix/coreLocusMetadata VALUES (3 individuals x 2
## chromosomes, 9 loci), converted from that file's wide matrix into the
## long-format id/locus/allele1/allele2 CSV modMarkerGeneticsServer's
## genotypeFile input expects (a missing genotype is row-ABSENCE, per
## buildMarkerGenotypeMatrix()'s own documented NA convention -- I2's L3 is
## simply omitted below). Uploaded through the SAME shared `genotypeFile`
## input the other 5 tabs already use (Q1), matching the ratified wiring
## decision -- NOT a new dedicated upload.
##
## Expected, harmless side effect of that Q1 reuse: I3 is homozygous at
## every locus (by design, for a clean F_ROH pattern), so the module's own
## already-eager comparison()/markerKmat() reactive (unrelated to any test
## below -- it just also reads genotypeFile) computes markerKinship() and
## emits its documented "share no heterozygous locus... returning NA"
## warning for the I1-I3/I2-I3 pairs. Correct, pre-existing markerKinship()
## behavior, not a defect introduced by this fixture or this slice.

i152RohGenotype <- data.frame(
  id = c(
    rep("I1", 9L),
    rep("I2", 8L), # L3 omitted -- missing genotype (NA in the wide matrix)
    rep("I3", 9L)
  ),
  locus = c(
    paste0("L", 1L:9L),
    paste0("L", c(1L, 2L, 4L:9L)),
    paste0("L", 1L:9L)
  ),
  allele1 = c(
    "A", "A", "A", "A", "A", "B", "A", "A", "A", # I1
    "A", "A", "A", "A", "B", "A", "A", "A", # I2 (L3 omitted)
    "A", "A", "A", "A", "A", "A", "A", "A", "A" # I3
  ),
  allele2 = c(
    "A", "A", "A", "A", "B", "B", "A", "A", "A", # I1
    "A", "A", "A", "B", "B", "B", "A", "A", # I2 (L3 omitted)
    "A", "A", "A", "A", "A", "A", "A", "A", "A" # I3
  ),
  stringsAsFactors = FALSE
)
i152RohGenotypeFilePath <- tempfile(fileext = ".csv")
write.csv(i152RohGenotype, i152RohGenotypeFilePath, row.names = FALSE)

i152RohLocusMetadata <- data.frame(
  locus = paste0("L", 1L:9L),
  chrom = c(rep("1", 6L), rep("2", 3L)),
  pos = c(0, 300000, 700000, 1100000, 1500000, 2000000, 0, 400000, 900000),
  stringsAsFactors = FALSE
)
i152RohLocusMetadataFilePath <- tempfile(fileext = ".csv")
write.csv(i152RohLocusMetadata, i152RohLocusMetadataFilePath,
          row.names = FALSE)

## All founders -- built solely so obfuscatePed(map = TRUE) has a real
## alias map to de-identify against, not meant to be biologically
## realistic (mirrors i153FoundersPed's own convention above).
i152RohPed <- data.frame(
  id = c("I1", "I2", "I3"),
  sire = rep(NA_character_, 3L),
  dam = rep(NA_character_, 3L),
  stringsAsFactors = FALSE
)

test_that("modMarkerGeneticsUI has a Genomic ROH (F_ROH) tab with its controls", {
  ui <- modMarkerGeneticsUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("Genomic ROH", ui_html, fixed = TRUE))
  expect_true(grepl("rohMinSnp", ui_html, fixed = TRUE))
  expect_true(grepl("rohMinBp", ui_html, fixed = TRUE))
  expect_true(grepl("sequenceExportPreview", ui_html, fixed = TRUE))
  expect_true(grepl("sequenceConfirmExport", ui_html, fixed = TRUE))
  expect_true(grepl("downloadSequenceGenotype", ui_html, fixed = TRUE))
  expect_true(grepl("downloadSequenceRoh", ui_html, fixed = TRUE))
  expect_true(grepl("downloadSequenceManifest", ui_html, fixed = TRUE))
})

test_that("modMarkerGenetics's sequenceRohTable is not ready before a genotype file is uploaded", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(locusMetadataFile = list(
      name = "i152_roh_locus_metadata.csv",
      datapath = i152RohLocusMetadataFilePath
    ))
    expect_null(result$sequenceRohTable())
  })
})

test_that("modMarkerGenetics's sequenceRohTable is not ready before a locus-metadata file is uploaded", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "i152_roh_genotype.csv", datapath = i152RohGenotypeFilePath
    ))
    expect_null(result$sequenceRohTable())
  })
})

test_that("modMarkerGenetics computes sequenceRohTable matching test_computeGenomicROH.R's own hand-verified fixture values", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "i152_roh_genotype.csv", datapath = i152RohGenotypeFilePath
    ))
    session$setInputs(locusMetadataFile = list(
      name = "i152_roh_locus_metadata.csv",
      datapath = i152RohLocusMetadataFilePath
    ))
    session$setInputs(rohMinSnp = 3, rohMinBp = 1000000)

    tbl <- result$sequenceRohTable()
    expect_s3_class(tbl, "data.frame")

    byId <- function(col) stats::setNames(tbl[[col]], tbl$id)
    expect_equal(byId("nSegments")[["I1"]], 1L)
    expect_equal(byId("totalRohLength")[["I1"]], 1100000)
    expect_equal(byId("fRoh")[["I1"]], 11 / 29, tolerance = 1e-6)
    expect_equal(byId("nSegments")[["I2"]], 0L)
    expect_equal(byId("fRoh")[["I2"]], 0, tolerance = 1e-6)
    expect_equal(byId("nSegments")[["I3"]], 1L)
    expect_equal(byId("totalRohLength")[["I3"]], 2000000)
    expect_equal(byId("fRoh")[["I3"]], 20 / 29, tolerance = 1e-6)
  })
})

## RED (bug found via Phase 3E live verification, this same session):
## locusMetadata() (the shared #153 reactive) always returns
## checkLocusMetadata()'s OWN output -- which appends a `coverage` column,
## making its column count 4 (no cM) or 5 (with cM). computeGenomicROH()
## internally re-runs checkLocusMetadata() on whatever it is given,
## expecting the RAW 3/4-column shape. A 3-column raw fixture (no cM, like
## the test above) silently passes the re-check by mistake -- "coverage"
## gets relabeled "cM", wrong but not an error, since computeGenomicROH()
## never reads cM for run detection. A 4-column raw fixture WITH a real cM
## column (matching the actual committed Slice 1 fixture's own shape) makes
## the re-check see 5 columns and throw loudly -- reproduced live in the
## running app against inst/extdata/examples/example_sequence_locus_
## metadata.csv (4 raw columns: locus, chrom, pos, cM).
i152RohLocusMetadataWithCm <- i152RohLocusMetadata
i152RohLocusMetadataWithCm$cM <- NA_real_
i152RohLocusMetadataWithCmFilePath <- tempfile(fileext = ".csv")
write.csv(i152RohLocusMetadataWithCm, i152RohLocusMetadataWithCmFilePath,
          row.names = FALSE)

test_that("modMarkerGenetics's sequenceRohTable does not error on a 4-column (with cM) locus-metadata file", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "i152_roh_genotype.csv", datapath = i152RohGenotypeFilePath
    ))
    session$setInputs(locusMetadataFile = list(
      name = "i152_roh_locus_metadata_with_cm.csv",
      datapath = i152RohLocusMetadataWithCmFilePath
    ))
    session$setInputs(rohMinSnp = 3, rohMinBp = 1000000)

    tbl <- result$sequenceRohTable()
    expect_s3_class(tbl, "data.frame")

    byId <- function(col) stats::setNames(tbl[[col]], tbl$id)
    expect_equal(byId("nSegments")[["I1"]], 1L)
    expect_equal(byId("totalRohLength")[["I1"]], 1100000)
    expect_equal(byId("nSegments")[["I3"]], 1L)
    expect_equal(byId("totalRohLength")[["I3"]], 2000000)
  })
})

test_that("modMarkerGenetics's sequenceRohTable uses minSnp=50L/minBp=1e6 defaults when inputs are unset", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "i152_roh_genotype.csv", datapath = i152RohGenotypeFilePath
    ))
    session$setInputs(locusMetadataFile = list(
      name = "i152_roh_locus_metadata.csv",
      datapath = i152RohLocusMetadataFilePath
    ))
    ## Defaults (minSnp=50L, minBp=1e6) exceed this small fixture's own
    ## scale -- no individual can qualify, but the call must not error.
    tbl <- result$sequenceRohTable()
    expect_s3_class(tbl, "data.frame")
    expect_true(all(tbl$nSegments == 0L))
  })
})

test_that("modMarkerGenetics's sequenceExportConfirmed starts FALSE", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    expect_false(result$sequenceExportConfirmed())
  })
})

test_that("modMarkerGenetics's sequence export reactives are NULL before Generate Export Preview is clicked", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(i152RohPed)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "i152_roh_genotype.csv", datapath = i152RohGenotypeFilePath
    ))
    session$setInputs(locusMetadataFile = list(
      name = "i152_roh_locus_metadata.csv",
      datapath = i152RohLocusMetadataFilePath
    ))
    session$setInputs(rohMinSnp = 3, rohMinBp = 1000000)

    expect_null(result$sequenceExportGenotypeMatrix())
    expect_null(result$sequenceExportRohTable())
    expect_null(result$sequenceExportManifest())
  })
})

test_that("modMarkerGenetics's sequence export de-identifies the genotype matrix and F_ROH table after Generate Export Preview", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(i152RohPed)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "i152_roh_genotype.csv", datapath = i152RohGenotypeFilePath
    ))
    session$setInputs(locusMetadataFile = list(
      name = "i152_roh_locus_metadata.csv",
      datapath = i152RohLocusMetadataFilePath
    ))
    session$setInputs(rohMinSnp = 3, rohMinBp = 1000000)
    session$setInputs(sequenceExportPreview = 1)

    exportedMatrix <- result$sequenceExportGenotypeMatrix()
    expect_false(any(grepl("^I[1-3]$", rownames(exportedMatrix))))

    exportedRoh <- result$sequenceExportRohTable()
    expect_s3_class(exportedRoh, "data.frame")
    expect_false(any(grepl("^I[1-3]$", exportedRoh$id)))
    ## De-identification aliases id only -- the statistics themselves are
    ## unchanged (mirrors the ldBlockExportTable precedent's own
    ## Dprime/nUsed-unchanged assertion).
    rawRoh <- result$sequenceRohTable()
    expect_equal(sort(exportedRoh$fRoh), sort(rawRoh$fRoh))

    manifest <- result$sequenceExportManifest()
    expect_s3_class(manifest, "data.frame")
    expect_equal(nrow(manifest), 1L)
    expect_true(all(c("timestamp", "packageVersion", "nIndividuals", "nLoci",
                       "minSnp", "minBp", "warningText") %in% names(manifest)))
  })
})

test_that("modMarkerGenetics's sequence export stays NULL after Generate Export Preview with no pedigree loaded", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "i152_roh_genotype.csv", datapath = i152RohGenotypeFilePath
    ))
    session$setInputs(locusMetadataFile = list(
      name = "i152_roh_locus_metadata.csv",
      datapath = i152RohLocusMetadataFilePath
    ))
    session$setInputs(rohMinSnp = 3, rohMinBp = 1000000)
    session$setInputs(sequenceExportPreview = 1)

    expect_null(result$sequenceExportGenotypeMatrix())
  })
})

test_that("modMarkerGenetics's sequenceExportConfirmed becomes TRUE after the full confirm sequence", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(i152RohPed)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "i152_roh_genotype.csv", datapath = i152RohGenotypeFilePath
    ))
    session$setInputs(locusMetadataFile = list(
      name = "i152_roh_locus_metadata.csv",
      datapath = i152RohLocusMetadataFilePath
    ))
    session$setInputs(rohMinSnp = 3, rohMinBp = 1000000)
    session$setInputs(sequenceExportPreview = 1)
    session$setInputs(sequenceConfirmExport = 1)
    session$setInputs(sequenceConfirmExportOk = 1)

    expect_true(result$sequenceExportConfirmed())
  })
})

## RED (issue #148 Slice 4): the module gains an 8th tab, "MHC Haplotype
## Reporting" (plan D8), with its OWN dedicated upload (`mhcHaplotypeFile`
## -- designation-by-upload, D2; never the shared genotypeFile input, per
## the #153 Slice 5 empirical lesson), two visible rarity-threshold inputs
## (D4, Dragon 1), a persistent descriptive-only caveat (D7), summary +
## rare-carrier tables (D5), a counts/denominator line, a pedigree
## -coverage line, and a confirm-gated de-identified export (D6: ALL MHC
## exports gated, Dragon 4) of 3 artifacts -- summary, aliased carrier
## list, manifest. Owner-ratified at PRE-RED (S708): (1) Generate Preview
## pre-checks that every MHC-file animal is in the loaded pedigree and, if
## not, builds nothing and says why -- never letting
## obfuscateMhcHaplotypes()'s stop() end the session (Dragon 5); (2) the
## carrier table lists rare haplotypes only (the function's own default);
## (3) a doc-coverage test pins that every returned reactive is documented
## in the server's @return (repairing the stale "fourteen" count).
## Existing 7 tabs / 4 uploads / 19 returned reactives: untouched (D8).

i148MhcFilePath <- system.file(
  "extdata", "examples", "obfuscated_rhesus_mhc_breeder_genotypes.csv",
  package = "nprcgenekeepr"
)
i148MhcIds <- rhesusGenotypes$id
i148ExpectedSummary <- mhcHaplotypeFrequency(rhesusGenotypes)$summary
i148ExpectedCarriers <- mhcHaplotypeCarriers(rhesusGenotypes)

## Founders-only pedigrees built solely to give obfuscatePed(map = TRUE) a
## real alias map (the i152RohPed convention above): one covering all 31
## MHC-file animals, one missing the first two (Dragon 5's precondition).
i148FullPed <- data.frame(
  id = i148MhcIds,
  sire = NA_character_,
  dam = NA_character_,
  stringsAsFactors = FALSE
)
i148PartialPed <- i148FullPed[-(1L:2L), ]

i148MalformedFilePath <- tempfile(fileext = ".csv")
write.csv(data.frame(id = "A1", haplotype1 = "H1", haplotype2 = "H2",
                     extra = "X"),
          i148MalformedFilePath, row.names = FALSE)

i148Upload <- function(session, path = i148MhcFilePath) {
  session$setInputs(mhcHaplotypeFile = list(
    name = "obfuscated_rhesus_mhc_breeder_genotypes.csv", datapath = path
  ))
}

i148Html <- function(x) paste(unlist(x), collapse = " ")

test_that("modMarkerGeneticsUI has an MHC Haplotype Reporting tab with its controls; the existing tabs and uploads are unchanged", {
  ui_html <- as.character(modMarkerGeneticsUI("test"))

  expect_true(grepl("MHC Haplotype Reporting", ui_html, fixed = TRUE))
  for (control in c("mhcHaplotypeFile", "mhcRareFrequencyThreshold",
                    "mhcRareCarrierThreshold", "mhcCountsSummary",
                    "mhcPedigreeCoverage", "mhcSummaryTable",
                    "mhcCarrierTable", "mhcExportPreview",
                    "mhcExportGuidance", "mhcConfirmExport",
                    "downloadMhcSummary", "downloadMhcCarriers",
                    "downloadMhcManifest")) {
    expect_true(grepl(paste0("test-", control), ui_html, fixed = TRUE),
                info = control)
  }
  ## D7: the persistent caveat is static markup, not a dismissable alert.
  expect_true(grepl("descriptive haplotype reporting", ui_html,
                    fixed = TRUE))
  expect_true(grepl("performs no MHC inference", ui_html, fixed = TRUE))

  ## D8 zero-changes: the existing 7 tabs and 4 uploads are all still here.
  for (tab in c("Kinship Comparison", "Heterozygosity",
                "Parentage Exclusion", "Cross-Center",
                "Candidate Parent Assignment",
                "Linkage and LD Block Metrics", "Genomic ROH (F_ROH)")) {
    expect_true(grepl(tab, ui_html, fixed = TRUE), info = tab)
  }
  for (upload in c("genotypeFile", "genotypeFileB", "linkageGenotypeFile",
                   "locusMetadataFile")) {
    expect_true(grepl(paste0("\"test-", upload, "\""), ui_html,
                      fixed = TRUE), info = upload)
  }
})

test_that("modMarkerGenetics's MHC tables are not ready before an MHC file is uploaded", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(i148FullPed)), {
    result <- session$getReturned()
    expect_null(result$mhcHaplotypeSummaryTable())
    expect_null(result$mhcHaplotypeCarrierTable())
  })
})

test_that("modMarkerGenetics's MHC tables match mhcHaplotypeFrequency/Carriers on the bundled file at the D4 defaults", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    i148Upload(session)

    summary <- result$mhcHaplotypeSummaryTable()
    expect_identical(summary, i148ExpectedSummary)
    expect_identical(nrow(summary), 33L)
    expect_identical(sum(summary$isRare), 26L)

    ## Rare haplotypes only (owner-ratified, S708): the function default.
    carriers <- result$mhcHaplotypeCarrierTable()
    expect_identical(carriers, i148ExpectedCarriers)
    expect_identical(nrow(carriers), 32L)
  })
})

test_that("modMarkerGenetics's MHC rarity flags follow the two threshold inputs", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    i148Upload(session)

    ## Carrier leg off: the frequency leg alone flags 0 at 2N = 60 (D4).
    session$setInputs(mhcRareFrequencyThreshold = 0.01,
                      mhcRareCarrierThreshold = 0)
    expect_identical(sum(result$mhcHaplotypeSummaryTable()$isRare), 0L)
    expect_identical(nrow(result$mhcHaplotypeCarrierTable()), 0L)

    ## Frequency leg wide open: every haplotype is rare, every carrier row
    ## (61 on the bundled file, pinned S706) is listed.
    session$setInputs(mhcRareFrequencyThreshold = 1,
                      mhcRareCarrierThreshold = 0)
    expect_identical(sum(result$mhcHaplotypeSummaryTable()$isRare), 33L)
    expect_identical(nrow(result$mhcHaplotypeCarrierTable()), 61L)
  })
})

test_that("modMarkerGenetics's MHC tables are not ready while a threshold input is invalid", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    i148Upload(session)

    session$setInputs(mhcRareFrequencyThreshold = -0.5,
                      mhcRareCarrierThreshold = 2)
    expect_null(result$mhcHaplotypeSummaryTable())
    expect_null(result$mhcHaplotypeCarrierTable())

    session$setInputs(mhcRareFrequencyThreshold = 0.01,
                      mhcRareCarrierThreshold = NA)
    expect_null(result$mhcHaplotypeSummaryTable())
    expect_null(result$mhcHaplotypeCarrierTable())
  })
})

test_that("modMarkerGenetics surfaces a malformed MHC upload as a real reactive error", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    i148Upload(session, path = i148MalformedFilePath)
    expect_error(result$mhcHaplotypeSummaryTable(),
                 "exactly three columns")
  })
})

test_that("modMarkerGenetics keeps the MHC upload and the shared marker upload independent (D8)", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    i148Upload(session)
    expect_null(result$markerGenotype())
    expect_null(result$comparisonTable())
  })
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pedKinshipMatrix),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    session$setInputs(genotypeFile = list(
      name = "marker_genotypes.csv", datapath = genotypeFilePath
    ))
    expect_false(is.null(result$comparisonTable()))
    expect_null(result$mhcHaplotypeSummaryTable())
  })
})

test_that("modMarkerGenetics reports the MHC counts and frequency denominator", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(NULL)), {
    i148Upload(session)
    countsHtml <- i148Html(output$mhcCountsSummary)
    expect_match(countsHtml, "31 animals", fixed = TRUE)
    expect_match(countsHtml, "2 uncertain", fixed = TRUE)
    expect_match(countsHtml, "60 certain", fixed = TRUE)
  })
})

test_that("modMarkerGenetics reports pedigree coverage of the MHC file, flagging animals absent from the pedigree", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(rhesusPedigree)), {
    i148Upload(session)
    coverageHtml <- i148Html(output$mhcPedigreeCoverage)
    expect_match(coverageHtml, "31 of 375", fixed = TRUE)
    expect_false(grepl("not in the loaded pedigree", coverageHtml,
                       fixed = TRUE))
  })
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(i148PartialPed)), {
    i148Upload(session)
    coverageHtml <- i148Html(output$mhcPedigreeCoverage)
    expect_match(coverageHtml, "29 of 29", fixed = TRUE)
    expect_match(coverageHtml, "not in the loaded pedigree", fixed = TRUE)
  })
})

test_that("modMarkerGenetics's MHC export is not ready and not confirmed before Generate Preview", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(i148FullPed)), {
    result <- session$getReturned()
    expect_false(result$mhcExportConfirmed())
    i148Upload(session)
    expect_null(result$mhcExportTables())
    ## Dragon 5: the guidance names the pedigree precondition up front.
    guidanceHtml <- i148Html(output$mhcExportGuidance)
    expect_match(guidanceHtml, "in the loaded pedigree", fixed = TRUE)
  })
})

test_that("modMarkerGenetics's MHC export aliases every id, keeps haplotype labels, and builds a manifest", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(i148FullPed)), {
    result <- session$getReturned()
    i148Upload(session)
    session$setInputs(mhcExportPreview = 1)

    exported <- result$mhcExportTables()
    expect_named(exported, c("summary", "carriers", "manifest"),
                 ignore.order = TRUE)

    displayed <- result$mhcHaplotypeCarrierTable()
    expect_identical(nrow(exported$carriers), nrow(displayed))
    expect_false(any(exported$carriers$id %in% i148MhcIds))
    expect_identical(exported$carriers$haplotype, displayed$haplotype)
    expect_identical(exported$carriers$uncertain, displayed$uncertain)

    ## D6/Dragon 4: the summary is gated too; it carries no ids to alias.
    expect_identical(exported$summary, result$mhcHaplotypeSummaryTable())

    manifest <- exported$manifest
    expect_s3_class(manifest, "data.frame")
    expect_identical(nrow(manifest), 1L)
    expect_identical(manifest$rareFrequencyThreshold, 0.01)
    expect_identical(as.numeric(manifest$rareCarrierThreshold), 2)
    expect_identical(as.integer(manifest$denominator), 60L)
  })
})

test_that("modMarkerGenetics's MHC export is a snapshot taken at Generate Preview", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(i148FullPed)), {
    result <- session$getReturned()
    i148Upload(session)
    session$setInputs(mhcRareFrequencyThreshold = 0.01,
                      mhcRareCarrierThreshold = 2)
    session$setInputs(mhcExportPreview = 1)
    session$setInputs(mhcRareCarrierThreshold = 0)

    expect_identical(nrow(result$mhcHaplotypeCarrierTable()), 0L)
    expect_identical(nrow(result$mhcExportTables()$carriers), 32L)
    expect_identical(
      as.numeric(result$mhcExportTables()$manifest$rareCarrierThreshold), 2
    )
  })
})

test_that("modMarkerGenetics's MHC export stays NULL after Generate Preview with no pedigree loaded", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(NULL)), {
    result <- session$getReturned()
    i148Upload(session)
    session$setInputs(mhcExportPreview = 1)
    expect_null(result$mhcExportTables())
  })
})

test_that("modMarkerGenetics blocks the MHC export, and says why, when MHC-file animals are absent from the pedigree", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(i148PartialPed)), {
    result <- session$getReturned()
    i148Upload(session)
    session$setInputs(mhcExportPreview = 1)

    expect_null(result$mhcExportTables())
    guidanceHtml <- i148Html(output$mhcExportGuidance)
    expect_match(guidanceHtml, "not in the loaded pedigree", fixed = TRUE)
    expect_match(guidanceHtml, "2 animal", fixed = TRUE)
  })
})

test_that("modMarkerGenetics's MHC export confirm sequence sets mhcExportConfirmed; a new preview resets it", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(i148FullPed)), {
    result <- session$getReturned()
    i148Upload(session)
    session$setInputs(mhcExportPreview = 1)
    session$setInputs(mhcConfirmExport = 1)
    session$setInputs(mhcConfirmExportOk = 1)
    expect_true(result$mhcExportConfirmed())

    session$setInputs(mhcExportPreview = 2)
    expect_false(result$mhcExportConfirmed())
  })
})

test_that("modMarkerGenetics's three MHC downloads write the previewed, de-identified artifacts", {
  skip_if_not_installed("shiny")
  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(i148FullPed)), {
    i148Upload(session)
    session$setInputs(mhcExportPreview = 1)
    session$setInputs(mhcConfirmExport = 1)
    session$setInputs(mhcConfirmExportOk = 1)

    summaryCsv <- read.csv(output$downloadMhcSummary,
                           stringsAsFactors = FALSE)
    expect_identical(nrow(summaryCsv), 33L)
    expect_identical(summaryCsv$haplotype, i148ExpectedSummary$haplotype)

    carriersCsv <- read.csv(output$downloadMhcCarriers,
                            stringsAsFactors = FALSE)
    expect_identical(nrow(carriersCsv), 32L)
    expect_false(any(carriersCsv$id %in% i148MhcIds))

    manifestCsv <- read.csv(output$downloadMhcManifest,
                            stringsAsFactors = FALSE)
    expect_identical(nrow(manifestCsv), 1L)
    expect_identical(as.integer(manifestCsv$denominator), 60L)
    expect_false(any(unlist(manifestCsv) %in% i148MhcIds))
  })
})

test_that("modMarkerGeneticsServer's @return documents every reactive it returns", {
  rdPath <- testthat::test_path("..", "..", "man",
                                "modMarkerGeneticsServer.Rd")
  skip_if(!file.exists(rdPath), "man/*.Rd not available (installed package)")
  skip_if_not_installed("shiny")

  rd <- tools::parse_Rd(rdPath)
  tags <- vapply(rd, function(x) attr(x, "Rd_tag"), character(1L))
  valueSection <- rd[[which(tags == "\\value")]]
  codeTerms <- function(x) {
    if (!is.list(x)) {
      return(character(0L))
    }
    if (identical(attr(x, "Rd_tag"), "\\code")) {
      return(paste(unlist(x), collapse = ""))
    }
    unlist(lapply(x, codeTerms))
  }
  documented <- codeTerms(valueSection)

  shiny::testServer(modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(NULL),
                pedigree = shiny::reactive(NULL)), {
    returned <- names(session$getReturned())
    undocumented <- setdiff(returned, documented)
    expect_identical(undocumented, character(0L),
                     info = paste(undocumented, collapse = ", "))
  })
})
