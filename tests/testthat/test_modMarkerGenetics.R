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
