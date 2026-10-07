## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
library(nprcgenekeepr)
data("examplePedigree")
ped <- examplePedigree
minDamAge <- 3.0
## Births in the 2008-2009 window of the whole example pedigree (71) over its
## breeding-age mothers: 598 females of known age >= 3, plus 27 of the 31
## females with no birth date who are listed as a dam (S931 ruling: a female
## with no birth date counts only if the pedigree lists an offspring for her).
## Counted independently of getProductionStatus() when the rule was set.
examplePedigreeProduction <- 71 / 625

test_that("getProductionStatus calculates correctly", {
  status <- getProductionStatus(
    ped,
    minDamAge = minDamAge, maxOffspringAge = NULL, housing = "shelter_pens",
    currentDate = as.Date("2010-10-10", format = "%Y-%m-%d")
  )
  expect_equal(status$production, examplePedigreeProduction)
  expect_equal(status$color, "red")
})
test_that("getProductionStatus calculates correctly", {
  status <- getProductionStatus(
    ped,
    minDamAge = minDamAge, maxOffspringAge = NULL, housing = "corral",
    currentDate = as.Date("2010-10-10", format = "%Y-%m-%d")
  )
  expect_equal(status$production, examplePedigreeProduction)
  expect_equal(status$color, "red")
})
## These are the IDs from the test above
ids <- c(
  "Q3J24E", "IC716S", "SJD499", "YJBY17", "5C63F4", "R3R07C",
  "MPAL6H", "X0EFTS", "LRD33X", "45V0XG", "HUJG4E", "W40T5A", "2HDW5H",
  "W17RHK", "1X5A92", "9AC7VI", "KR9CKT", "3WABPU", "8LK8R4", "FGPCWH",
  "JQJ227", "BK22E3", "CTVG9A", "QVJU41", "4G3GET", "LNVD11", "IJFU2U",
  "DLKEI5", "MGA3UT", "YVCTVD", "MDRA94", "RJ7H7T", "3921MR", "4Z5SNV",
  "ZYTRMM", "HYSW4M", "KTKPNB", "MDBYYE", "0U7WIE", "W07ANU", "9Y64R9",
  "BSDDEP", "7MEQMP", "LXJFKL", "KR0VFP", "KYFID0", "TEN5YM", "MNV5GE",
  "SPIZM7", "MM8MYL", "SSJDJE", "CS6U5F", "C6URM1", "N322YA", "6XV95Z",
  "NQSMBG", "2X4K5B", "E0ACPZ", "FCLNFN", "LVLLL5", "ZLQYFT", "NP4Q3H",
  "HWNWV4", "FCYQGS", "XWR0YW", "XIKCDK", "BWE7N8", "H6T2FF", "X994RC",
  "I04JZV", "ZKKR4C"
)
pedWith71 <- ped[ped$id %in% ids, ]
removeIDs <- c("Q3J24E", "IC716S", "SJD499", "YJBY17", "5C63F4", "R3R07C")
test_that("getProductionStatus calculates correctly", {
  status <- getProductionStatus(
    pedWith71,
    minDamAge = minDamAge, maxOffspringAge = NULL,
    housing = "shelter_pens",
    currentDate = as.Date("2010-10-10", format = "%Y-%m-%d")
  )
  expect_equal(status$production, 23.6666666666667)
  expect_equal(status$color, "green")
})
noDamsPed <- pedWith71[!pedWith71$id %in% ped$id[ped$sex == "F" &
  ped$age >= minDamAge], ]
## No breeding-age females: production is undefined, so the status is NA
## (grey), never green -- the same contract as getKinshipWithMaleStatus().
for (housingType in c("shelter_pens", "corral")) {
  test_that(paste("getProductionStatus reports NA, not green, with no dams:",
                  housingType), {
    status <- getProductionStatus(
      noDamsPed,
      minDamAge = minDamAge, maxOffspringAge = NULL,
      housing = housingType,
      currentDate = as.Date("2010-10-10", format = "%Y-%m-%d")
    )
    expect_identical(names(status), c("production", "color", "colorIndex"))
    expect_true(is.na(status$production))
    expect_true(is.na(status$color))
    expect_identical(status$colorIndex, NA_integer_)
  })
}
test_that("getProductionStatus still rejects an unknown housing with no dams", {
  expect_error(
    getProductionStatus(
      noDamsPed,
      minDamAge = minDamAge, maxOffspringAge = NULL,
      housing = "kennel",
      currentDate = as.Date("2010-10-10", format = "%Y-%m-%d")
    ),
    "Undefined housing type"
  )
})
test_that("getProductionStatus calculates correctly", {
  status <- getProductionStatus(
    pedWith71,
    minDamAge = minDamAge, maxOffspringAge = NULL,
    housing = "corral",
    currentDate = as.Date("2010-10-10", format = "%Y-%m-%d")
  )
  expect_equal(status$production, 23.6666666666667)
  expect_equal(status$color, "green")
})
dams <- ped$dam[ped$id %in% ids]
pedWith71OffspringWithDams <- ped[ped$id %in% c(ids, dams), ]
test_that("getProductionStatus calculates correctly", {
  status <- getProductionStatus(
    pedWith71OffspringWithDams,
    minDamAge = minDamAge, maxOffspringAge = NULL,
    housing = "shelter_pens",
    currentDate = as.Date("2010-10-10", format = "%Y-%m-%d")
  )
  expect_equal(status$production, 1.12698412698413)
  expect_equal(status$color, "green")
})
badPed <- pedWith71[, -1L]
test_that("getProductionStatus detects missing column", {
  expect_error(
    getProductionStatus(
      badPed,
      minDamAge = minDamAge, maxOffspringAge = NULL,
      housing = "shelter_pens",
      currentDate = as.Date("2010-10-10", format = "%Y-%m-%d")
    ),
    "ped is missing: id"
  )
})
test_that("getProductionStatus detects wrong housing type", {
  expect_error(
    getProductionStatus(
      pedWith71OffspringWithDams,
      minDamAge = minDamAge, maxOffspringAge = NULL,
      housing = "bad housing",
      currentDate = as.Date("2010-10-10", format = "%Y-%m-%d")
    ),
    "Undefined housing type in getProduction status is: bad housing"
  )
})
yellowCorralPed <- pedWith71OffspringWithDams[!
pedWith71OffspringWithDams$id %in% ids[1:39], ]
test_that("getProductionStatus calculates correctly", {
  status <- getProductionStatus(
    yellowCorralPed,
    minDamAge = minDamAge, maxOffspringAge = NULL,
    housing = "corral",
    currentDate = as.Date("2010-10-10", format = "%Y-%m-%d")
  )
  expect_equal(status$production, 0.516, tolerance = 0.001)
  expect_equal(status$color, "yellow")
})
yellowShelterPedPed <- pedWith71OffspringWithDams[
  !pedWith71OffspringWithDams$id %in% ids[1L:33L],
]
test_that("getProductionStatus calculates correctly", {
  status <- getProductionStatus(
    yellowShelterPedPed,
    minDamAge = minDamAge, maxOffspringAge = NULL,
    housing = "shelter_pens",
    currentDate = as.Date("2010-10-10", format = "%Y-%m-%d")
  )
  expect_equal(status$production, 0.61290322580652)
  expect_identical(status$color, "yellow")
})
test_that("getProductionStatus minDamAge drives the dam filter", {
  ## A dam floor above every female's age leaves zero dams, so the
  ## production ratio is undefined (NA) -- proves minDamAge is honored.
  status <- getProductionStatus(
    pedWith71,
    minDamAge = 100, maxOffspringAge = NULL,
    housing = "shelter_pens",
    currentDate = as.Date("2010-10-10", format = "%Y-%m-%d")
  )
  expect_true(is.na(status$production))
  expect_true(is.na(status$color))
})
test_that("getProductionStatus minParentAge alias warns, keeps result", {
  ## Back-compat: the deprecated scalar sets the dam floor and still warns.
  lifecycle::expect_deprecated(
    res <- getProductionStatus(
      ped,
      minParentAge = 3.0, maxOffspringAge = NULL,
      housing = "shelter_pens",
      currentDate = as.Date("2010-10-10", format = "%Y-%m-%d")
    )
  )
  expect_equal(res$production, examplePedigreeProduction)
  expect_equal(res$color, "red")
})

## ---- Females with no birth date (S931 owner ruling) ------------------------
## A female of known age counts as a breeding-age mother when she is at least
## minDamAge. A female with no birth date counts ONLY if the pedigree lists an
## offspring for her; with no offspring she is left out. Her offspring are
## looked up in the whole pedigree (damIds), not only in the group, and a known
## age below minDamAge or a blank sex never counts.
##
## Fixed currentDate 2020-07-01: the birth window is 2018-01-01 to 2019-12-31.
## d1 and d2 are mothers of known age; u1 has no birth date (age NA); k1-k3 were
## born in the window and lived well past 30 days (3 births).
rulingDate <- as.Date("2020-07-01")
makeRulingPed <- function(offspringDams) {
  data.frame(
    id = c("d1", "d2", "u1", "k1", "k2", "k3"),
    dam = c(NA_character_, NA_character_, NA_character_, offspringDams),
    sex = c("F", "F", "F", "M", "M", "M"),
    age = c(5, 6, NA, 1.9, 1.4, 1.3),
    birth = as.Date(c("2015-01-01", "2014-01-01", NA,
                      "2018-08-01", "2019-02-01", "2019-03-01")),
    exit = as.Date(c(NA, NA, NA, "2019-06-01", "2019-12-01", "2019-12-15")),
    stringsAsFactors = FALSE
  )
}
rulingProduction <- function(ped, ...) {
  getProductionStatus(ped, minDamAge = 3, housing = "shelter_pens",
                      currentDate = rulingDate, ...)
}

test_that("a female with no birth date counts as a mother when she has an offspring", {
  ## u1 is the dam of k1: 3 births over 3 mothers.
  status <- rulingProduction(makeRulingPed(c("u1", "d1", "d2")))
  expect_equal(status$production, 3 / 3)
})

test_that("a female with no birth date and no offspring is left out of the mothers", {
  ## Nobody lists u1 as a dam: 3 births over the 2 mothers of known age.
  status <- rulingProduction(makeRulingPed(c("d1", "d1", "d2")))
  expect_equal(status$production, 3 / 2)
})

test_that("a group whose only female has no birth date and no offspring has no value", {
  ped <- makeRulingPed(c(NA_character_, NA_character_, NA_character_))
  ped <- ped[ped$id != "d1" & ped$id != "d2", ]
  status <- rulingProduction(ped)
  expect_true(is.na(status$production))
  expect_true(is.na(status$color))
  expect_identical(status$colorIndex, NA_integer_)
})

test_that("a group whose only female has no birth date but has offspring is scored", {
  ped <- makeRulingPed(c("u1", "u1", "u1"))
  ped <- ped[ped$id != "d1" & ped$id != "d2", ]
  status <- rulingProduction(ped)
  expect_equal(status$production, 3 / 1)
  expect_identical(status$color, "green")
  expect_identical(status$colorIndex, 3L)
})

test_that("a female of known age under minDamAge is left out even with an offspring", {
  ped <- makeRulingPed(c("y1", "d1", "d2"))
  ped <- ped[ped$id != "u1", ]
  ped <- rbind(ped, data.frame(
    id = "y1", dam = NA_character_, sex = "F", age = 2,
    birth = as.Date("2018-07-01"), exit = as.Date(NA),
    stringsAsFactors = FALSE
  ))
  status <- rulingProduction(ped)
  expect_equal(status$production, 3 / 2)
})

test_that("an animal with a blank sex is not counted as a mother", {
  ped <- makeRulingPed(c("d1", "d2", "d1"))
  ped <- ped[ped$id != "u1", ]
  ped <- rbind(ped, data.frame(
    id = "b1", dam = NA_character_, sex = NA_character_, age = 7,
    birth = as.Date("2013-01-01"), exit = as.Date(NA),
    stringsAsFactors = FALSE
  ))
  status <- rulingProduction(ped)
  expect_equal(status$production, 3 / 2)
})

test_that("damIds finds offspring that are outside the group", {
  ## Within this group nobody lists u1 as a dam, but the whole pedigree does.
  ped <- makeRulingPed(c("d1", "d2", "d1"))
  status <- rulingProduction(ped, damIds = c("d1", "d2", "u1"))
  expect_equal(status$production, 3 / 3)
})

test_that("damIds replaces the dams listed in the group's own dam column", {
  ped <- makeRulingPed(c("u1", "d1", "d2"))
  status <- rulingProduction(ped, damIds = character(0L))
  expect_equal(status$production, 3 / 2)
})
