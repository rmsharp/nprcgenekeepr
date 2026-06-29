## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

data(lacy1989Ped)
data(lacy1989PedAlleles)
ped <- lacy1989Ped
alleles <- lacy1989PedAlleles
pedFactors <- data.frame(
  id = as.factor(ped$id),
  sire = as.factor(ped$sire),
  dam = as.factor(ped$dam),
  gen = ped$gen,
  population = ped$population,
  stringsAsFactors = TRUE
)
allelesFactors <- geneDrop(pedFactors$id, pedFactors$sire, pedFactors$dam,
  pedFactors$gen,
  genotype = NULL, n = 5000L,
  updateProgress = NULL
)
feFg <- calcFEFG(ped, alleles)
feFgFactors <- calcFEFG(pedFactors, allelesFactors)

## Prior to forcing the pedigree to have id, sire, and dam as character vectors
## inside calcFG, the two calculations above with ped (characters) and
## feFactors (factors) resulted 2.189855 and 1.857998 respectively.
##
## Used example from Analysis of Founder Representation in Pedigrees: Founder
## Equivalents and Founder Genome Equivalents.
## Zoo Biology 8:111-123, (1989) by Robert C. Lacy
## He presented 2.18 as the answer, which was truncated and not precise enough
## for this specific comparison.
test_that("calcFEFG correctly calculates the number of founder genetic
equivalents in the pedigree", {
  expect_lt(abs(feFg$FG - feFgFactors$FG), 0.2)
  expect_lt(abs(feFg$FG - 2.18), 0.2)
  expect_identical(feFg$FE, feFgFactors$FE)
  expect_equal(feFg$FE, 2.9090909091)
})

## --- NEW-48 (Session 7): reject partial parentage with a clear error ----------
## calcFEFG documents "no partial parentage" (R/calcFEFG.R:16) but did not enforce
## it. A row with exactly one NA parent is not a founder (founders need BOTH NA,
## line 46), so it becomes a descendant, enters the gen loop, and indexes the
## founder matrix by NA_character_ at line 73 -- which ERRORS ("subscript out of
## bounds"), crashing far from the cause instead of explaining the problem.
## Reachability is MIXED: MASKED on the canonical qcStudbook pipeline (addUIds
## removes partial parentage) but REACHABLE via direct calls and via
## trimPedigree(removeUninformative = TRUE, addBackParents = FALSE) -> reportGV.
## (The existing complete-parentage tests above double as the no-false-positive
## guard: if the new check tripped on complete pedigrees, those would error.)
test_that("calcFEFG stops with a clear error on partial parentage", {
  partialPed <- data.frame(
    id   = c("A", "B", "C", "D"),
    sire = c(NA,  NA,  "A", NA),   # D: sire NA, dam B  -> partial (sire unknown)
    dam  = c(NA,  NA,  NA,  "B"),  # C: sire A,  dam NA -> partial (dam unknown)
    gen  = c(0L,  0L,  1L,  1L),
    population = c(TRUE, TRUE, TRUE, TRUE),
    stringsAsFactors = FALSE
  )
  ## alleles is unused here: the guard short-circuits before calcRetention(),
  ## so NULL is never dereferenced (in either the buggy or the fixed code path).
  expect_error(calcFEFG(partialPed, alleles = NULL), regexp = "partial parentage")
})

test_that("reportGV surfaces the partial-parentage error through its real caller", {
  ## Real-pipeline regression guard: reportGV() calls calcFEFG() at reportGV.R:133.
  ## A descendant with one NA parent must yield the clear diagnostic through the
  ## actual caller, not the cryptic subscript-out-of-bounds crash.
  modLacy <- lacy1989Ped
  modLacy$dam[modLacy$id == "C"] <- NA   # C: sire A, dam NA -> partial parentage
  expect_error(
    reportGV(modLacy, guIter = 50L, guThresh = 1L, byID = TRUE,
             updateProgress = NULL),
    regexp = "partial parentage"
  )
})

## --- Issue #82 D2 (Session 205): hard-fail the silent FG collapse -------------
## Same silent-collapse degeneracy as calcFG (r == 0 with p > 0 -> FG quietly 0).
## FG must become NA with a warning; FE is deterministic (no retention term) and
## stays a valid finite value.
test_that("calcFEFG returns FG = NA with a warning but a valid FE on zero retention", {
  ped <- makeFgPed()
  hf <- makeFgAlleles(ped, k = 200L, hardFail = TRUE)
  expect_warning(res <- calcFEFG(ped, hf), regexp = "retained in 0")
  expect_true(is.na(res$FG))
  expect_true(is.finite(res$FE))
  expect_equal(
    res$FE,
    1 / sum(calcFounderContributions(ped, "calcFEFG")$p^2L)
  )
})

## --- Issue #86 (Session 206): name-align founders before the FG sum ----------
## Same positional p/r misalignment as calcFG. calcFEFG$FG was silently 0 on the
## unsorted fixture; name-aligning gives FG = 32 / 21. FE (1 / sum(p^2)) has no
## retention term, so it is order-invariant and unchanged either way.
test_that("calcFEFG aligns founders by name on an unsorted-founder pedigree (issue #86)", {
  pedU <- makeFgPed(unsorted = TRUE)
  res <- calcFEFG(pedU, makeFgAlleles(pedU))
  expect_equal(res$FG, 32 / 21)
  expect_gt(res$FG, 0)
  expect_true(is.finite(res$FG))
})

test_that("calcFEFG FG is invariant to founder ordering; FE always is (issue #86)", {
  pedU <- makeFgPed(unsorted = TRUE)
  pedS <- makeFgPed(unsorted = FALSE)
  resU <- calcFEFG(pedU, makeFgAlleles(pedU))
  resS <- calcFEFG(pedS, makeFgAlleles(pedS))
  expect_equal(resU$FG, resS$FG) # FG now order-invariant (was 0 vs 32/21)
  expect_equal(resU$FE, resS$FE) # FE order-invariant already (no r term)
})
