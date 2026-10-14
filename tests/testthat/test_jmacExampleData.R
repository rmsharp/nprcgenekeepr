## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S981; BACKLOG.md:179, the owner's S980 request "reconstruct in the next
## session"; Pre-RED rulings: replace the old file, keep the species column):
## the shipped Japanese macaque example,
## inst/extdata/examples/deidentified_jmac_ped.csv, is rebuilt from the
## colony's 2018-07-11 studbook. The old file was a later, larger export (2,791
## animals, born to 2021) that records no sire for any animal and has 251
## animals dying before they were born (its dates were shifted one column at a
## time). The rebuild is the studbook's 2,590 animals, de-identified with
## obfuscatePed() (data-raw/buildJmacExample.R, seed 20180711): new ids, and each
## animal's birth, death and departure dates moved together by up to 30 days,
## so no animal's dates fall out of order. The studbook itself is neither in
## git nor in the package; the counts below are the studbook's own, measured
## S981 (they do not change under de-identification). Origin, parent-type and
## from-center columns are left out: the studbook has none.
##
## The first three blocks and the fourth fail until the file is replaced; the
## fifth is green at HEAD and stays green (the old file also has no parent born
## after its offspring): it guards the rebuild against the shift putting a
## parent after a child.

## jmacExamplePath() is in helper-jmacExample.R.
jmacExample <- function() {
  path <- jmacExamplePath()
  skip_if(path == "", "shipped jmac example not found")
  ped <- read.csv(path, stringsAsFactors = FALSE, na.strings = c("", "NA"),
                  check.names = FALSE)
  for (col in intersect(c("birth", "death", "departure"), names(ped))) {
    ped[[col]] <- as.Date(ped[[col]])
  }
  ped
}

## The ids of the animals whose `parent` (the "sire" or the "dam" column) was
## born after them. An animal with no birth date, or whose parent has none in
## the file, cannot be checked and is not reported.
bornAfterOffspring <- function(ped, parent) {
  named <- !is.na(ped[[parent]])
  parentBirth <- ped$birth[match(ped[[parent]][named], ped$id)]
  late <- !is.na(parentBirth) & !is.na(ped$birth[named]) &
    parentBirth > ped$birth[named]
  ped$id[named][late]
}

test_that("the jmac example is the studbook's 2,590 animals in nine named columns", {
  ped <- jmacExample()
  expect_identical(names(ped), c("id", "species", "sex", "status", "birth",
                                 "death", "dam", "sire", "departure"))
  expect_identical(nrow(ped), 2590L)
  expect_false(anyDuplicated(ped$id) > 0L)
  expect_true(all(nchar(ped$id) == 6L))
  expect_identical(unique(ped$species), "JAPANESE MACAQUE")
})

test_that("the jmac example keeps the studbook's counts of sires, dams, dates, sexes and statuses", {
  ped <- jmacExample()
  expect_identical(sum(!is.na(ped$sire)), 819L)
  expect_identical(sum(!is.na(ped$dam)), 2276L)
  expect_identical(sum(!is.na(ped$birth)), 2530L)
  expect_identical(sum(!is.na(ped$death)), 1886L)
  expect_identical(sum(!is.na(ped$departure)), 365L)
  ## "Hermaphrodite" (19), "Unknown" (111) and the one blank sex are all U, as
  ## the pedigree check reads them.
  expect_identical(as.list(table(ped$sex)), list(F = 1209L, M = 1250L, U = 131L))
  expect_identical(as.list(table(ped$status)),
                   list(Alive = 339L, Dead = 1886L, Shipped = 365L))
  expect_identical(ped$status == "Dead", !is.na(ped$death))
  expect_identical(ped$status == "Shipped",
                   is.na(ped$death) & !is.na(ped$departure))
})

test_that("every sire is a male in the file and no dam is a male", {
  ped <- jmacExample()
  sires <- ped$sire[!is.na(ped$sire)]
  expect_identical(length(sires), 819L)
  expect_true(all(sires %in% ped$id))
  expect_identical(unique(ped$sex[match(sires, ped$id)]), "M")
  ## Two named mothers have no row of their own in the studbook; the pedigree
  ## check adds them. Every other dam is in the file and is not a male.
  dams <- ped$dam[!is.na(ped$dam)]
  expect_identical(sum(!(dams %in% ped$id)), 2L)
  expect_false("M" %in% ped$sex[match(dams[dams %in% ped$id], ped$id)])
})

test_that("no animal dies or leaves before it is born, and none has both a death and a departure", {
  ped <- jmacExample()
  expect_identical(sum(ped$death < ped$birth, na.rm = TRUE), 0L)
  expect_identical(sum(ped$departure < ped$birth, na.rm = TRUE), 0L)
  expect_identical(sum(!is.na(ped$death) & !is.na(ped$departure)), 0L)
})

test_that("no sire or dam of the jmac example is born after its offspring", {
  ped <- jmacExample()
  expect_identical(bornAfterOffspring(ped, "sire"), character(0))
  expect_identical(bornAfterOffspring(ped, "dam"), character(0))
})
