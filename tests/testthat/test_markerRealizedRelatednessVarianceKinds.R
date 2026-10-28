## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Marker Genetics' Realized Relatedness table holds every pair"
## (S1082, owner rulings "Only the 3 kinds" and "Same rows as the app").
## markerRealizedRelatednessVariance() listed every pair of animals, though
## only Parent-Offspring, Full-Siblings and Half-Siblings pairs get a
## variance: on the example's 3,694 animals 6,824,665 rows, 13,286 of them
## with a variance, built in 8.3 s, 390.9 MB kept; opening the app's Linkage
## and LD Block Metrics tab took 13 to 18 s and kept 422.5 MB (S1082). It
## lists only those three kinds. The first block counts them on the example;
## the second compares the rows with today's rows of those kinds
## (markerRealizedRelatednessVarianceReference(), helper-perfReference.R)
## using identical(); the third counts the allocations the size of a column
## of the table of every pair.

threeKinds <- c("Parent-Offspring", "Full-Siblings", "Half-Siblings")

## Today's rows of the three kinds.
todaysKinds <- function(kmat, ped, ...) {
  rel <- markerRealizedRelatednessVarianceReference(kmat, ped, nChr = 20L,
                                                    mapLength = 28, ...)
  rel[rel$relation %in% threeKinds, ]
}

kinshipOf <- function(ped) {
  kinship(ped$id, ped$sire, ped$dam,
          findGeneration(ped$id, ped$sire, ped$dam), sparse = FALSE)
}

test_that(paste("markerRealizedRelatednessVariance() lists the example's",
                "13,286 pairs of the three kinds"), {
  colony <- exampleColony()
  rel <- markerRealizedRelatednessVariance(colony$kmat, colony$ped,
                                           nChr = 20L, mapLength = 28)
  expect_identical(nrow(rel), 13286L)
  expect_identical(c(table(factor(rel$relation, levels = threeKinds))),
                   c(`Parent-Offspring` = 4052L, `Full-Siblings` = 68L,
                     `Half-Siblings` = 9166L))
  expect_false(anyNA(rel$varR))
})

test_that(paste("markerRealizedRelatednessVariance() gives today's rows of",
                "the three kinds"), {
  small <- nprcgenekeepr::smallPed
  smallKmat <- kinshipOf(small)
  example <- exampleLivingPed()
  sampled <- withr::with_seed(1082L, sample(example$id, 600L))
  founders <- data.frame(id = c("P", "Q", "R"), sire = NA_character_,
                         dam = NA_character_, stringsAsFactors = FALSE)
  ## T's dam P is R's sire, so R and T share a parent in two roles.
  bothRoles <- data.frame(id = c("P", "Q", "R", "S", "T"),
                          sire = c(NA, NA, "P", "Q", NA),
                          dam = c(NA, NA, "Q", "T", "P"),
                          stringsAsFactors = FALSE)
  ## R and S share the sire "" (kinship() cannot read it, so the matrix is
  ## the one for an unknown sire).
  blankSire <- data.frame(id = c("P", "Q", "R", "S"),
                          sire = c(NA, NA, "", ""), dam = c(NA, NA, "Q", "P"),
                          stringsAsFactors = FALSE)
  unknownSire <- blankSire
  unknownSire$sire[unknownSire$sire %in% ""] <- NA
  missingKinship <- smallKmat
  missingKinship["G", "F"] <- missingKinship["F", "G"] <- NA
  missingKinship["D", "G"] <- missingKinship["G", "D"] <- NA
  ## The matrix's last animal, ZZ, is not in the pedigree.
  outsideId <- smallKmat
  dimnames(outsideId) <- list(c(rownames(smallKmat)[-1L], "ZZ"),
                              c(colnames(smallKmat)[-1L], "ZZ"))
  factorPed <- pedIdsAsFactors(small)
  integerKmat <- smallKmat
  storage.mode(integerKmat) <- "integer"
  inputs <- list(
    smallPed = list(smallKmat, small),
    sampledExample = list(kinshipForAnimals(example, sampled), example),
    idsSubset = list(smallKmat, small, ids = c("D", "G", "F", "C", "I")),
    noIdsFound = list(smallKmat, small, ids = "nobody"),
    allFounders = list(kinshipOf(founders), founders),
    oneByOne = list(smallKmat[1L, 1L, drop = FALSE], small),
    missingKinship = list(missingKinship, small),
    idOutsidePedigree = list(outsideId, small),
    factorColumns = list(smallKmat, factorPed),
    integerMatrix = list(integerKmat, small),
    parentInTwoRoles = list(kinshipOf(bothRoles), bothRoles),
    blankSire = list(kinshipOf(unknownSire), blankSire)
  )
  for (name in names(inputs)) {
    args <- inputs[[name]]
    expect_identical(
      do.call(markerRealizedRelatednessVariance,
              c(args, list(nChr = 20L, mapLength = 28))),
      do.call(todaysKinds, args),
      info = name
    )
  }
})

## How many allocations markerRealizedRelatednessVariance() makes on `kmat`
## at least as large as an integer column of the table of every pair (4 bytes
## a pair, the diagonal included, as kinMatrix2LongForm(removeDups = TRUE)
## lists them) and smaller than the kinship matrix. Rprofmem() adds R's
## vector header to each size.
everyPairColumnAllocations <- function(ped, kmat) {
  n <- nrow(kmat)
  low <- 4 * n * (n + 1) / 2
  high <- 8 * n * n
  log <- withr::local_tempfile()
  utils::Rprofmem(log, threshold = low - 1)
  on.exit(utils::Rprofmem(NULL), add = TRUE)
  markerRealizedRelatednessVariance(kmat, ped, nChr = 20L, mapLength = 28)
  utils::Rprofmem(NULL)
  sizes <- suppressWarnings(as.numeric(sub(" :.*", "", readLines(log))))
  sum(sizes >= low & sizes < high, na.rm = TRUE)
}

test_that(paste("markerRealizedRelatednessVariance() builds no column of",
                "the table of every pair"), {
  skip_if_not(capabilities("profmem"),
              "R was built without memory profiling (Rprofmem)")
  ## 20 sires and 20 dams, each the parent of 18 of 360 offspring, every
  ## offspring of a different pair: 400 animals, 80,200 pairs, of which 720
  ## are parent-offspring and 6,120 half-siblings.
  sires <- sprintf("S%02d", 1L:20L)
  dams <- sprintf("D%02d", 1L:20L)
  ped <- data.frame(id = c(sires, dams, sprintf("K%03d", 1L:360L)),
                    sire = c(rep(NA_character_, 40L), rep(sires, 18L)),
                    dam = c(rep(NA_character_, 40L), rep(dams, each = 18L)),
                    stringsAsFactors = FALSE)
  kmat <- kinshipOf(ped)
  rel <- markerRealizedRelatednessVariance(kmat, ped, nChr = 20L,
                                           mapLength = 28)
  expect_identical(c(table(factor(rel$relation, levels = threeKinds))),
                   c(`Parent-Offspring` = 720L, `Full-Siblings` = 0L,
                     `Half-Siblings` = 6120L))
  expect_identical(everyPairColumnAllocations(ped, kmat), 0L)
})
