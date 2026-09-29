## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#
# The genetic value report and the effective sizes read the placeholder mark
# (placeholder-marking plan Slice 3, S809). A center can mark a real animal
# whose id looks like a made-up stand-in (U1234) as FALSE in the `placeholder`
# column that qcStudbook() writes. Until now reportGV(), classifyParentage(),
# correctUnknownParentMeanKinship(), getLivingBreeders() and gvaConvergence()
# read only the id's shape, so a real U1234 was left out of the founder
# counts, its offspring were called "one unknown parent" or "both unknown",
# and it was not counted as a living breeder. Each reader now takes the whole
# pedigree and asks isGeneratedUnknownId(ped =). An id with no row (or no
# mark) in the pedigree still answers by its shape, so a parent whose
# stand-in row was filtered away still counts as unknown (plan D4, M7).
library(testthat)

## Two real sires/dams whose ids look like stand-ins (marked FALSE) and six
## offspring of the pair. With the marks read, the offspring have known
## parents; read by shape, both parents look unknown.
makeMarkedPed <- function(mark = c(FALSE, FALSE)) {
  ped <- data.frame(
    id = c("U1234", "U5678", paste0("K", 1:6)),
    sire = c(NA, NA, rep("U1234", 6)),
    dam = c(NA, NA, rep("U5678", 6)),
    sex = c("M", "F", rep(c("F", "M"), 3)),
    birth = as.Date("2000-01-01") + c(0, 0, (1:6) * 400),
    exit = as.Date(NA),
    gen = c(0L, 0L, rep(1L, 6)),
    stringsAsFactors = FALSE
  )
  ped$placeholder <- c(mark, rep(NA, 6))
  ped
}

## qcPed with the founder UL1ZA5 (a male with no exit, the sire of K7QBLH)
## marked as a real animal. Every other row is left unmarked, so it is read
## by its shape as before.
makeMarkedQcPed <- function() {
  ped <- nprcgenekeepr::qcPed
  ped$placeholder <- ifelse(ped$id == "UL1ZA5", FALSE, NA)
  ped
}

## --- classifyParentage() -----------------------------------------------------

test_that("classifyParentage(ped =) calls a parent marked FALSE known", {
  ped <- makeMarkedPed()
  expect_identical(
    nprcgenekeepr:::classifyParentage(c("U1234", "U1234", NA),
                                      c("U5678", NA, NA), ped = ped),
    c("known", "one unknown parent", "both unknown")
  )
})

test_that("classifyParentage(ped =) still reads a stand-in marked TRUE as unknown", {
  ped <- makeMarkedPed(mark = c(TRUE, TRUE))
  expect_identical(
    nprcgenekeepr:::classifyParentage("U1234", "U5678", ped = ped),
    "both unknown"
  )
})

test_that("classifyParentage(ped =) reads a parent with no row in the pedigree by its shape (D4)", {
  ## the stand-in row U0001 was filtered away; the sire id is still a stand-in
  ped <- makeMarkedPed()
  expect_identical(
    nprcgenekeepr:::classifyParentage("U0001", "U5678", ped = ped),
    "one unknown parent"
  )
  expect_identical(
    nprcgenekeepr:::classifyParentage("U0001", "U0002", ped = ped),
    "both unknown"
  )
})

test_that("classifyParentage reads by shape when ped is missing or has no mark column", {
  expect_identical(
    nprcgenekeepr:::classifyParentage("U1234", "U5678"), "both unknown"
  )
  ped <- makeMarkedPed()
  ped$placeholder <- NULL
  expect_identical(
    nprcgenekeepr:::classifyParentage("U1234", "U5678", ped = ped),
    "both unknown"
  )
})

## --- getLivingBreeders() -----------------------------------------------------

test_that("getLivingBreeders counts a living sire marked FALSE as a breeder", {
  ped <- makeMarkedPed()
  expect_setequal(nprcgenekeepr:::getLivingBreeders(ped), c("U1234", "U5678"))
})

test_that("getLivingBreeders still leaves out a stand-in marked TRUE or unmarked", {
  expect_length(
    nprcgenekeepr:::getLivingBreeders(makeMarkedPed(mark = c(TRUE, TRUE))), 0L
  )
  ped <- makeMarkedPed()
  ped$placeholder <- NA
  expect_length(nprcgenekeepr:::getLivingBreeders(ped), 0L)
})

test_that("getLivingBreeders reads a pedigree with no mark column by shape", {
  ped <- makeMarkedPed()
  ped$placeholder <- NULL
  expect_length(nprcgenekeepr:::getLivingBreeders(ped), 0L)
})

test_that("calcNeVariance on qcPed is unchanged by an all-NA mark column and moves when a founder is marked real", {
  base <- calcNeVariance(nprcgenekeepr::qcPed)
  expect_equal(base, 26.405868, tolerance = 1e-6)
  unmarked <- nprcgenekeepr::qcPed
  unmarked$placeholder <- NA
  expect_equal(calcNeVariance(unmarked), 26.405868, tolerance = 1e-6)
  ## UL1ZA5 is a living male founder with one offspring; as a real breeder it
  ## joins the count
  expect_true("UL1ZA5" %in%
    nprcgenekeepr:::getLivingBreeders(makeMarkedQcPed()))
  expect_false(isTRUE(all.equal(calcNeVariance(makeMarkedQcPed()), base)))
})

## --- correctUnknownParentMeanKinship() ---------------------------------------

test_that("correctUnknownParentMeanKinship leaves an animal whose sire is marked real uncorrected", {
  ped <- nprcgenekeepr::qcPed
  mk <- stats::setNames(rep(0.1, nrow(ped)), ped$id)
  ## control: read by shape, K7QBLH has one unknown parent and is raised
  ## by half the mean of its peers
  byShape <- nprcgenekeepr:::correctUnknownParentMeanKinship(mk, ped)
  expect_equal(unname(byShape$indivMeanKin["K7QBLH"]), 0.15)
  ## with UL1ZA5 marked real, K7QBLH's parents are both known
  marked <- nprcgenekeepr:::correctUnknownParentMeanKinship(
    mk, makeMarkedQcPed()
  )
  expect_equal(unname(marked$indivMeanKin["K7QBLH"]), 0.1)
  expect_false("K7QBLH" %in% marked$flagged)
})

## --- reportGV() ----------------------------------------------------------------

test_that("reportGV counts a real U1234 marked FALSE as a founder and its offspring as known", {
  gv <- reportGV(makeMarkedPed(), guIter = 20L)
  expect_identical(gv$nMaleFounders, 1L)
  expect_identical(gv$nFemaleFounders, 1L)
  expect_identical(gv$maleFounders$id, "U1234")
  expect_identical(gv$femaleFounders$id, "U5678")
  parentage <- stats::setNames(gv$report$parentage, gv$report$id)
  expect_identical(unname(parentage[paste0("K", 1:6)]), rep("known", 6))
  expect_false(any(gv$report$value[gv$report$id %in% paste0("K", 1:6)] ==
    "Undetermined"))
})

test_that("reportGV still leaves out stand-ins marked TRUE or unmarked", {
  for (mark in list(c(TRUE, TRUE), c(NA, NA))) {
    gv <- reportGV(makeMarkedPed(mark = mark), guIter = 20L)
    expect_identical(gv$nMaleFounders, 0L)
    expect_identical(gv$nFemaleFounders, 0L)
    expect_identical(unique(gv$report$parentage), "both unknown")
  }
})

test_that("reportGV on qcPed: an all-NA mark column changes nothing, one founder marked real is counted", {
  base <- reportGV(nprcgenekeepr::qcPed, guIter = 20L)
  unmarked <- nprcgenekeepr::qcPed
  unmarked$placeholder <- NA
  same <- reportGV(unmarked, guIter = 20L)
  expect_identical(same$nMaleFounders, base$nMaleFounders)
  expect_identical(same$nFemaleFounders, base$nFemaleFounders)
  expect_identical(same$report$parentage, base$report$parentage)
  expect_equal(same$neVariance, 26.405868, tolerance = 1e-6)

  marked <- reportGV(makeMarkedQcPed(), guIter = 20L)
  expect_identical(marked$nMaleFounders, base$nMaleFounders + 1L)
  expect_true("UL1ZA5" %in% marked$maleFounders$id)
  expect_identical(
    marked$report$parentage[marked$report$id == "K7QBLH"], "known"
  )
  expect_identical(
    base$report$parentage[base$report$id == "K7QBLH"], "one unknown parent"
  )
  expect_identical(sum(marked$report$parentage == "known"),
                   sum(base$report$parentage == "known") + 1L)
})

## --- gvaConvergence() ----------------------------------------------------------

test_that("gvaConvergence reads the mark: offspring of two real U-id parents are not Undetermined", {
  marked <- gvaConvergence(makeMarkedPed(), nMax = 200L, seed = 1L, k = 3L)
  ## only the two founders (no parents at all) lack a recorded parentage
  expect_identical(marked$nUndetermined, 2L)
  byShape <- gvaConvergence(makeMarkedPed(mark = c(NA, NA)),
                            nMax = 200L, seed = 1L, k = 3L)
  expect_identical(byShape$nUndetermined, 8L)
})

## --- through the app's module ----------------------------------------------------

test_that("modGeneticValueServer's report classifies offspring of a marked real U-id parent as known", {
  testthat::skip_on_cran()
  skip_if_not_installed("shiny")
  ped <- makeMarkedPed()[, c("id", "sire", "dam", "sex", "placeholder")]
  shiny::testServer(
    modGeneticValueServer,
    args = list(pedigree = shiny::reactive({ ped })),
    {
      session$setInputs(nIterations = 100)
      session$setInputs(runAnalysis = 1)
      results <- gvResults()
      kids <- results[results$id %in% paste0("K", 1:6), ]
      expect_identical(unique(kids$parentage), "known")
    }
  )
})
