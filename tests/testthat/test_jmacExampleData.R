## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S980; BACKLOG.md:156, found S800; the owner's S980 pick "Fix 2 sires,
## one sentence"): the shipped Japanese macaque example,
## inst/extdata/examples/deidentified_jmac_ped.csv, has 2,791 rows and exactly
## two non-blank sire cells, and both name an animal that cannot be the sire:
##   8PPD8 (born 1968-06-09) lists NX5RM as sire; NX5RM was born 2003-03-19 and
##         died 36 days later.
##   82I5M (born 1974-05-17) lists 3A34N as sire; 3A34N was born 2011-06-24.
## Each of the two sires has no other offspring in the file. The owner ruled
## that those two cells (the sire and the sire type) are emptied: the true
## sires cannot be recovered from the file, so the file then records no sire for
## any animal, and its remaining parent-age errors are the 65 mothers aged 3.43
## to 3.99 years (test_modInput_blankCells.R).
##
## The first two blocks fail until the file is edited; the third is green at
## HEAD and stays green: the edit changes nothing else.

jmacExample <- function() {
  path <- system.file("extdata", "examples", "deidentified_jmac_ped.csv",
                      package = "nprcgenekeepr")
  skip_if(path == "", "shipped jmac example not found")
  ped <- read.csv(path, stringsAsFactors = FALSE, na.strings = c("", "NA"),
                  check.names = FALSE)
  ped$birth <- as.Date(ped$birth)
  ped
}

impossibleSireOffspring <- c("8PPD8", "82I5M")

test_that("the jmac example's two impossible sire entries are blank", {
  ped <- jmacExample()
  rows <- ped$id %in% impossibleSireOffspring
  ## Both animals are in the file, so a missing id cannot make the checks below
  ## pass without looking at anything.
  expect_identical(sum(rows), 2L)
  expect_true(all(is.na(ped$sire[rows])), info = ped$sire[rows])
  expect_true(all(is.na(ped[["sire.type"]][rows])),
              info = ped[["sire.type"]][rows])
})

test_that("no sire entry of the jmac example names an animal born after its offspring", {
  ped <- jmacExample()
  named <- !is.na(ped$sire)
  sireBirth <- ped$birth[match(ped$sire[named], ped$id)]
  ## An animal whose sire has no birth date in the file cannot be checked.
  late <- !is.na(sireBirth) & !is.na(ped$birth[named]) &
    sireBirth > ped$birth[named]
  expect_identical(ped$id[named][late], character(0))
})

test_that("the jmac example keeps its 2,791 animals and 2,448 named dams, each born before her offspring", {
  ped <- jmacExample()
  expect_identical(nrow(ped), 2791L)
  expect_identical(sum(!is.na(ped$dam)), 2448L)
  named <- !is.na(ped$dam)
  damBirth <- ped$birth[match(ped$dam[named], ped$id)]
  late <- !is.na(damBirth) & !is.na(ped$birth[named]) &
    damBirth > ped$birth[named]
  expect_identical(ped$id[named][late], character(0))
})
