## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## NEW-13 / NEW-23 (Session 17): the founder-contribution algorithm shared by
## calcFE(), calcFG(), and calcFEFG() is extracted into one @noRd helper,
## calcFounderContributions(), which also collapses the triplicated S7
## partial-parentage guard into a single definition. The helper returns both the
## founder mean-contribution vector `p` and the toCharacter()-coerced `ped`, so
## the FG callers feed calcRetention() the exact same character pedigree they do
## today (behaviour-preserving by construction).
library(testthat)

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
  pedFactors$id, pedFactors$sire, pedFactors$dam
)
pedFactors$population <- getGVPopulation(pedFactors, NULL)

test_that("calcFounderContributions returns p + character ped; FE = 1/sum(p^2)", {
  fc <- calcFounderContributions(ped)
  expect_type(fc, "list")
  expect_named(fc, c("p", "ped"))
  expect_type(fc$p, "double")
  ## The founder-equivalent derived from p matches the published Lacy 1989 value
  ## (Zoo Biology 8:111-123, 1989); identical to what calcFE() returns today.
  expect_equal(1L / sum(fc$p^2L), 2.9090909091)
  ## ped is returned coerced to character so FG callers feed calcRetention() the
  ## same character pedigree as the current code does.
  expect_type(fc$ped$id, "character")
  expect_type(fc$ped$sire, "character")
  expect_type(fc$ped$dam, "character")
})

test_that("calcFounderContributions gives identical p for factor and character peds", {
  ## Mirrors the existing test_calcFE.R `expect_identical(fe, feFactors)` guard:
  ## toCharacter() inside the helper must erase the factor/character distinction.
  expect_identical(
    calcFounderContributions(ped)$p,
    calcFounderContributions(pedFactors)$p
  )
})

test_that("calcFounderContributions stops on partial parentage, naming the caller", {
  partialPed <- data.frame(
    id   = c("A", "B", "C", "D"),
    sire = c(NA,  NA,  "A", NA),   # D: sire NA, dam B  -> partial
    dam  = c(NA,  NA,  NA,  "B"),  # C: sire A,  dam NA -> partial
    gen  = c(0L,  0L,  1L,  1L),
    population = c(TRUE, TRUE, TRUE, TRUE),
    stringsAsFactors = FALSE
  )
  ## The single guard is parameterized by caller so each public function keeps
  ## its exact error message (calcFE / calcFG / calcFEFG "requires complete
  ## parentage (no partial parentage)").
  expect_error(
    calcFounderContributions(partialPed, caller = "calcFE"),
    regexp = "calcFE.*partial parentage"
  )
  expect_error(
    calcFounderContributions(partialPed),
    regexp = "calcFEFG.*partial parentage"
  )
})

## S925: with one living descendant, the founder-contribution step took that
## animal's row without keeping the matrix shape, so colMeans() stopped calcFE(),
## calcFG(), calcFEFG() and calcFGSE() with "'x' must be an array of at least two
## dimensions".
oneDescendantPed <- data.frame(
  id = c("F1", "F2", "C1"),
  sire = c(NA, NA, "F1"),
  dam = c(NA, NA, "F2"),
  gen = c(0L, 0L, 1L),
  population = c(TRUE, TRUE, TRUE),
  stringsAsFactors = FALSE
)

test_that("founder contributions work with one living descendant (S925)", {
  fc <- calcFounderContributions(oneDescendantPed)
  expect_equal(fc$p, c(F1 = 0.5, F2 = 0.5))
  ## FE = 1 / sum(p^2) = 1 / (0.25 + 0.25)
  expect_equal(calcFE(oneDescendantPed), 2)
})

test_that("calcFG, calcFEFG and calcFGSE work with one living descendant (S925)", {
  set_seed(1L)
  alleles <- geneDrop(oneDescendantPed$id, oneDescendantPed$sire,
    oneDescendantPed$dam, oneDescendantPed$gen,
    n = 50L
  )
  ## The one descendant carries exactly one allele of each founder in every
  ## gene drop, so retention is 0.5 for each founder whatever the seed:
  ## FG = 1 / (0.25 / 0.5 + 0.25 / 0.5) = 1, with no sampling variation.
  expect_equal(calcFG(oneDescendantPed, alleles), 1)
  fefg <- calcFEFG(oneDescendantPed, alleles)
  expect_equal(fefg$FE, 2)
  expect_equal(fefg$FG, 1)
  expect_equal(calcFGSE(oneDescendantPed, alleles), 0)
})
