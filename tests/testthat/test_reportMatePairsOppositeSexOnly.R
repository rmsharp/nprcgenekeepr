## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Mate Pair's default run uses about 1 GB of app memory" (S1081,
## owner ruling "Both"). reportMatePairs() built the table of every pair of
## its animals (kinMatrix2LongForm()) and filterPairs() then merged it with
## the pedigree twice to drop the same-sex pairs: on the example's default
## population (1,704 animals, 1,452,660 pairs, 315,023 of them male-female)
## that allocated 1,810 MB, 1,526 MB of it in filterPairs(), and took 8.2 s
## (S1081, Rprofmem). It builds only the male-female pairs. The first block
## counts the allocations the size of a column of the table of every pair;
## the second compares the report with today's (reportMatePairsReference(),
## helper-perfReference.R) using identical().

## How many allocations reportMatePairs() makes on `kmat` at least as large as
## a column of the table of every pair (8 bytes a pair, the diagonal included,
## as kinMatrix2LongForm(removeDups = TRUE) builds it) and smaller than the
## kinship matrix, which reportMatePairs() copies when it cuts it to the
## animals it pairs. Rprofmem() adds R's vector header to each size.
everyPairColumnAllocations <- function(ped, kmat) {
  n <- nrow(kmat)
  low <- 8 * n * (n + 1) / 2
  high <- 8 * n * n
  log <- withr::local_tempfile()
  utils::Rprofmem(log, threshold = low - 1)
  on.exit(utils::Rprofmem(NULL), add = TRUE)
  reportMatePairs(ped, kmat)
  utils::Rprofmem(NULL)
  sizes <- suppressWarnings(as.numeric(sub(" :.*", "", readLines(log))))
  sum(sizes >= low & sizes < high, na.rm = TRUE)
}

## Unrelated founders, `nM` males then `nF` females, all of breeding age, and
## their kinship matrix. One sex far outnumbers the other, as on the example
## (1,493 males and 211 females with no exit date), so most pairs are
## same-sex.
lopsidedColony <- function(nM, nF) {
  ped <- data.frame(id = sprintf("A%04d", seq_len(nM + nF)),
                    sire = NA_character_, dam = NA_character_,
                    sex = rep(c("M", "F"), c(nM, nF)), age = 5,
                    stringsAsFactors = FALSE)
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  list(ped = ped, kmat = kinship(ped$id, ped$sire, ped$dam, ped$gen))
}

test_that("reportMatePairs() builds no column of the table of every pair", {
  skip_if_not(capabilities("profmem"),
              "R was built without memory profiling (Rprofmem)")
  for (sizes in list(c(50L, 350L), c(350L, 50L))) {
    colony <- lopsidedColony(sizes[[1L]], sizes[[2L]])
    expect_identical(nrow(reportMatePairs(colony$ped, colony$kmat)$pairs),
                     17500L)
    expect_identical(everyPairColumnAllocations(colony$ped, colony$kmat), 0L,
                     label = sprintf("%d males and %d females", sizes[[1L]],
                                     sizes[[2L]]))
  }
})

## The report is the same as today's.
expectSameReport <- function(ped, kmat, ...) {
  expect_identical(reportMatePairs(ped, kmat, ...),
                   reportMatePairsReference(ped, kmat, ...))
}

test_that("reportMatePairs() gives today's report on the example", {
  ped <- examplePed()
  living <- exampleLivingIds()
  kmat <- kinshipForAnimals(ped, living)
  gv <- list(report = data.frame(
    id = living, indivMeanKin = seq_along(living) / 1000,
    gu = rev(seq_along(living)) / 10, stringsAsFactors = FALSE
  ))
  marker <- kmat[living[1:40], living[1:40]] / 2
  expectSameReport(ped, kmat, populationIds = living)
  expectSameReport(ped, kmat, markerKmat = marker, geneticValues = gv,
                   minAge = 5L, populationIds = living,
                   exclude = living[seq(1L, 200L, by = 10L)])
  sampled <- withr::with_seed(1081L, sample(ped$id, 600L))
  expectSameReport(ped, kinshipForAnimals(ped, sampled), minAge = 3L,
                   populationIds = sampled)
  males <- living[ped$sex[match(living, ped$id)] == "M"]
  expectSameReport(ped, kmat, populationIds = males)
  expectSameReport(ped, kmat, populationIds = character(0L))
})

test_that("reportMatePairs() gives today's report with ancestry rules", {
  ped <- qcStudbook(
    read.csv(system.file("extdata", "examples",
                         "example_ancestry_pedigree.csv",
                         package = "nprcgenekeepr"),
             stringsAsFactors = FALSE, na.strings = c("", "NA")),
    minSireAge = 2, minDamAge = 2, reportChanges = FALSE,
    reportErrors = FALSE
  )
  ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
  kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
  rules <- suppressWarnings(checkAncestryRules(readAncestryRules(
    system.file("extdata", "examples", "example_ancestry_rules.csv",
                package = "nprcgenekeepr")
  )))
  suppressWarnings({
    expectSameReport(ped, kmat, ancestryRules = rules)
    expectSameReport(ped, kmat, ancestryRules = rules,
                     overriddenRules = data.frame(ancestry1 = "CHINESE",
                                                  ancestry2 = "INDIAN"))
  })
})

test_that(paste("reportMatePairs() gives today's report with unpaired sexes,",
                "unknown ids, missing kinships and an unusual matrix"), {
  ped <- data.frame(
    id = c("M1", "F1", "F2", "U1", "H1", "N1", "M2", "F3"),
    sire = NA_character_, dam = NA_character_,
    sex = c("M", "F", "F", "U", "H", NA, "M", "F"),
    age = c(4, 6, NA, 3, 3, 3, 0.5, 8),
    stringsAsFactors = FALSE
  )
  ids <- c(ped$id, "X9")
  kmat <- matrix(0, length(ids), length(ids), dimnames = list(ids, ids))
  diag(kmat) <- 0.5
  kmat["F2", "M1"] <- kmat["M1", "F2"] <- NA
  kmat["F3", "M2"] <- kmat["M2", "F3"] <- 0.25
  expectSameReport(ped, kmat)
  expectSameReport(ped, kmat, minAge = 5L, exclude = "F3")
  expectSameReport(ped, kmat, populationIds = c("M1", "F1", "X9", "Z0"))
  ## A matrix the male-female build is not made for (integer cells) runs
  ## today's steps.
  intKmat <- kmat
  intKmat[is.na(intKmat)] <- 0
  storage.mode(intKmat) <- "integer"
  expectSameReport(ped, intKmat)
})
