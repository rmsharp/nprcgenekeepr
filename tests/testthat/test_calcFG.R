#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr

ped <- data.frame(
  id = c("A", "B", "C", "D", "E", "F", "G"),
  sire = c(NA, NA, "A", "A", NA, "D", "D"),
  dam = c(NA, NA, "B", "B", NA, "E", "E"),
  stringsAsFactors = FALSE
)
ped["gen"] <- findGeneration(ped$id, ped$sire, ped$dam)
ped$population <- getGVPopulation(ped, NULL)
pedFactors <- data.frame(
  id = c("A", "B", "C", "D", "E", "F", "G"),
  sire = c(NA, NA, "A", "A", NA, "D", "D"),
  dam = c(NA, NA, "B", "B", NA, "E", "E"),
  stringsAsFactors = TRUE
)
pedFactors["gen"] <- findGeneration(
  pedFactors$id, pedFactors$sire,
  pedFactors$dam
)
pedFactors$population <- getGVPopulation(pedFactors, NULL)
alleles <- geneDrop(ped$id, ped$sire, ped$dam, ped$gen,
  genotype = NULL,
  n = 5000L, updateProgress = NULL
)
allelesFactors <- geneDrop(pedFactors$id, pedFactors$sire, pedFactors$dam,
  pedFactors$gen,
  genotype = NULL, n = 5000L,
  updateProgress = NULL
)
fg <- calcFG(ped, alleles)
fgFactors <- calcFG(pedFactors, allelesFactors)

## Prior to forcing the pedigree to have id, sire, and dam as character vectors
## inside calcFG, the two calculations above with ped (characters) and
## feFactors (factors) resulted 2.189855 and 1.857998 respectively.
##
## Used example from Analysis of Founder Representation in Pedigrees: Founder
## Equivalents and Founder Genome Equivalents.
## Zoo Biology 8:111-123, (1989) by Robert C. Lacy
## He presented 2.18 as the answer, which was truncated and not precise enough
## for this specific comparison.
test_that("calcFG correctly calculates the number of founder genetic
equivalents in the pedigree", {
  expect_lt(abs(fg - fgFactors), 0.2)
  expect_lt(abs(fg - 2.18), 0.2)
})

## --- NEW-48 (Session 7): reject partial parentage (identical bug, R/calcFG.R:83)
## The complete-parentage test above doubles as the no-false-positive guard.
test_that("calcFG stops with a clear error on partial parentage", {
  partialPed <- data.frame(
    id   = c("A", "B", "C", "D"),
    sire = c(NA,  NA,  "A", NA),   # D: sire NA, dam B  -> partial
    dam  = c(NA,  NA,  NA,  "B"),  # C: sire A,  dam NA -> partial
    gen  = c(0L,  0L,  1L,  1L),
    population = c(TRUE, TRUE, TRUE, TRUE),
    stringsAsFactors = FALSE
  )
  ## alleles unused: guard short-circuits before calcRetention().
  expect_error(calcFG(partialPed, alleles = NULL), regexp = "partial parentage")
})

## --- Issue #82 D2 (Session 205): hard-fail the silent FG collapse -------------
## When a contributing founder (p > 0) is retained in ZERO gene-drop iterations
## (r == 0), the term p^2 / 0 = Inf and na.rm strips only NaN, not Inf, so the
## sum is Inf and FG silently collapses to 0. The fix detects this and returns
## NA with a warning (advising more iterations) instead of a misleading 0.
test_that("calcFG returns NA with a warning when a contributing founder has zero retention", {
  ped <- makeFgPed()
  hf <- makeFgAlleles(ped, k = 200L, hardFail = TRUE)
  expect_warning(res <- calcFG(ped, hf), regexp = "retained in 0")
  expect_true(is.na(res))
})
