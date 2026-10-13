## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:139 (found S974, measured in the real app S975; the owner chose
## "pedigree-only FG" at the PRE-RED scope question).
##
## With genotypes, the Genetic Value Summary tab showed Founder Genome Equiv.
## (FG) as NA and Gene Diversity (GD) as N/A, in both the one-file and the
## separate-files mode (the same colony without genotypes: 52.09 +/- 0.09 and
## 0.9904). The cause: a genotyped animal starts the gene drop from its own two
## real alleles, so a founder whose only descendants are genotyped never passes
## a simulated allele on, is "retained" in 0 of the iterations, and
## p^2 / r = p^2 / 0 gives an undefined FG (R/checkFgDegeneracy.R). On the
## shipped one-file example that is 3 founders (function-level run, set.seed(1),
## 200 drops: 677E7M, FEEN9W, ZZ646X, each with one descendant, a genotyped
## animal). Raising the number of iterations cannot help.
##
## The ruling: fg, fgSE and neGD come from a gene drop that ignores the
## genotypes. reportGV() runs the genotype gene drop first, as before (so gu is
## unchanged for the same seed), and a second, pedigree-only drop only when at
## least one animal has a code. A pedigree with no codes keeps its one drop
## and its exact results.
##
## The blocks that compare with a hand run set the same seed, run the same two
## drops in the same order, and read the same calc functions reportGV() calls.

## A pedigree of the Lacy 1989 example (founders A, B, E; C, D from A x B; F, G
## from D x E) plus a second family, founders H and I and their only child J,
## who is genotyped. H and I have no other descendant, so with J's real alleles
## neither can pass a simulated allele on. `codes = FALSE` leaves the genotype
## columns off; `allNA = TRUE` gives the columns with no code in them; `only`
## codes J on both alleles ("both"), or on one allele only ("first", "second").
smallGenotypedPed <- function(codes = TRUE, allNA = FALSE, only = "both") {
  ped <- data.frame(
    id   = c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J"),
    sire = c(NA, NA, "A", "A", NA, "D", "D", NA, NA, "H"),
    dam  = c(NA, NA, "B", "B", NA, "E", "E", NA, NA, "I"),
    sex  = c("M", "F", "M", "F", "F", "M", "F", "M", "F", "M"),
    stringsAsFactors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  if (codes || allNA) {
    ped$first <- rep(NA_integer_, nrow(ped))
    ped$second <- rep(NA_integer_, nrow(ped))
    if (!allNA) {
      if (only != "second") ped$first[ped$id == "J"] <- 10001L
      if (only != "first") ped$second[ped$id == "J"] <- 10002L
    }
  }
  ped
}

## The shipped one-file example, read as the Input tab reads it (375 animals,
## 31 genotyped), every animal in the population.
exampleGenotypedPed <- function() {
  path <- system.file("extdata", "examples",
                      "obfuscated_rhesus_mhc_ped_with_genotypes.csv",
                      package = "nprcgenekeepr")
  ped <- suppressWarnings(suppressMessages(
    qcStudbook(getPedigree(path), reportErrors = FALSE, reportChanges = FALSE)))
  ped <- readOneFileGenotypes(ped)$ped
  setPopulation(ped, ids = ped$id)
}

founderWarning <- "Founder genome equivalents undefined"

## reportGV() at the seed, 200 drops, with its warnings kept.
runGV <- function(ped, seed = 7L, updateProgress = NULL) {
  kept <- character(0L)
  set.seed(seed)
  gv <- withCallingHandlers(
    suppressMessages(reportGV(ped, guIter = 200L, guThresh = 1L, byID = TRUE,
                              updateProgress = updateProgress)),
    warning = function(w) {
      kept <<- c(kept, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )
  list(gv = gv, warnings = kept)
}

## What reportGV() should compute by hand: the genotype drop first, then (when
## the pedigree has codes) the pedigree-only drop, at the same seed.
handRun <- function(ped, seed = 7L, n = 200L, second = TRUE) {
  ped$population <- getGVPopulation(ped, NULL)
  genotype <- getGVGenotype(ped)
  drop <- function(g) {
    geneDrop(ids = ped$id, sires = ped$sire, dams = ped$dam, gen = ped$gen,
             genotype = g, n = n, updateProgress = NULL)
  }
  set.seed(seed)
  withGenotypes <- drop(genotype)
  pedigreeOnly <- if (second) drop(NULL) else withGenotypes
  list(ped = ped, withGenotypes = withGenotypes, pedigreeOnly = pedigreeOnly)
}

## The founder scalars a drop gives.
founderScalars <- function(ped, alleles) {
  fg <- suppressWarnings(calcFEFG(ped, alleles)$FG)
  list(fg = fg,
       fgSE = suppressWarnings(calcFGSE(ped, alleles)),
       neGD = calcGeneDiversity(fg))
}

## The example's two runs, once: reportGV() and the hand run.
exampleRuns <- local({
  cache <- NULL
  function() {
    if (is.null(cache)) {
      ped <- exampleGenotypedPed()
      cache <<- list(ped = ped, run = runGV(ped), hand = handRun(ped))
    }
    cache
  }
})

test_that("founders whose only descendant is genotyped no longer make FG, its SE and GD undefined", {
  run <- runGV(smallGenotypedPed())
  expect_false(any(grepl(founderWarning, run$warnings, fixed = TRUE)),
               info = paste(run$warnings, collapse = " | "))
  expect_true(is.finite(run$gv$fg))
  expect_true(is.finite(run$gv$fgSE))
  expect_true(is.finite(run$gv$neGD))
})

test_that("on the small pedigree FG, its SE and GD are what a pedigree-only drop gives, run after the genotype drop", {
  ped <- smallGenotypedPed()
  run <- runGV(ped)
  hand <- handRun(ped)
  want <- founderScalars(hand$ped, hand$pedigreeOnly)
  expect_equal(run$gv$fg, want$fg)
  expect_equal(run$gv$fgSE, want$fgSE)
  expect_equal(run$gv$neGD, want$neGD)
})

test_that("genotypes do not move the deterministic founder numbers (fe and the two effective sizes)", {
  withCodes <- runGV(smallGenotypedPed())$gv
  without <- runGV(smallGenotypedPed(codes = FALSE))$gv
  expect_equal(withCodes$fe, without$fe)
  expect_equal(withCodes$neSexRatio, without$neSexRatio)
  expect_equal(withCodes$neVariance, without$neVariance)
})

test_that("the shipped one-file example gives a finite FG, SE and GD, the pedigree-only values, and no warning", {
  skip_on_cran()
  ex <- exampleRuns()
  expect_false(any(grepl(founderWarning, ex$run$warnings, fixed = TRUE)),
               info = paste(ex$run$warnings, collapse = " | "))
  expect_true(is.finite(ex$run$gv$fg))
  expect_true(is.finite(ex$run$gv$fgSE))
  expect_true(is.finite(ex$run$gv$neGD))
  want <- founderScalars(ex$hand$ped, ex$hand$pedigreeOnly)
  expect_equal(ex$run$gv$fg, want$fg)
  expect_equal(ex$run$gv$fgSE, want$fgSE)
  expect_equal(ex$run$gv$neGD, want$neGD)
})

## Passes before and after the change: genome uniqueness still comes from the
## genotype drop. Where the report holds a nonzero gu, it is the first drop's
## (the report zeroes the "Undetermined" animals).
test_that("genome uniqueness on the example is still the genotype drop's", {
  skip_on_cran()
  ex <- exampleRuns()
  probands <- as.character(ex$hand$ped$id[ex$hand$ped$population])
  by <- calcGU(ex$hand$withGenotypes, threshold = 1L, byID = TRUE,
               pop = probands)[probands, , drop = FALSE]
  shown <- ex$run$gv$gu$gu
  nonzero <- shown != 0
  ## 18 of the 375 animals have a nonzero gu at threshold 1 (measured S975).
  expect_gt(sum(nonzero), 10L)
  expect_equal(unname(shown[nonzero]), unname(by$gu[nonzero]))
})

## Passes before and after the change. The Input tab accepts a row with one
## allele only ("at least one allele in it"), so a code in either column counts:
## S975 mutants that read `first` only, or needed both codes, survived the
## blocks above without this one.
test_that("an animal coded on one allele only still gives the pedigree-only FG, SE and GD", {
  for (only in c("first", "second")) {
    ped <- smallGenotypedPed(only = only)
    run <- runGV(ped)
    expect_false(any(grepl(founderWarning, run$warnings, fixed = TRUE)),
                 info = only)
    hand <- handRun(ped)
    want <- founderScalars(hand$ped, hand$pedigreeOnly)
    expect_equal(run$gv$fg, want$fg, info = only)
    expect_equal(run$gv$fgSE, want$fgSE, info = only)
    expect_equal(run$gv$neGD, want$neGD, info = only)
  }
})

## Passes before and after the change: with no codes there is one drop, so the
## results are exactly the one drop's.
test_that("a pedigree with no genotype codes, or columns with no code in them, uses one gene drop", {
  for (variant in list(smallGenotypedPed(codes = FALSE),
                       smallGenotypedPed(allNA = TRUE))) {
    run <- runGV(variant)
    hand <- handRun(variant, second = FALSE)
    want <- founderScalars(hand$ped, hand$withGenotypes)
    expect_equal(run$gv$fg, want$fg)
    expect_equal(run$gv$fgSE, want$fgSE)
    expect_equal(run$gv$neGD, want$neGD)
  }
})

## Passes before and after the change: the second drop is silent, so the
## progress bar the Genetic Value tab shows moves exactly as it did.
test_that("the progress callback fires as often with genotypes as without", {
  calls <- function(ped) {
    n <- 0L
    runGV(ped, updateProgress = function(...) n <<- n + 1L)
    n
  }
  expect_gt(calls(smallGenotypedPed(codes = FALSE)), 0L)
  expect_equal(calls(smallGenotypedPed()), calls(smallGenotypedPed(codes = FALSE)))
})
