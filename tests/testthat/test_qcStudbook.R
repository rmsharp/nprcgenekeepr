## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)
library(lubridate)
library(stringi)

set_seed(10L)
pedOne <- data.frame(
  ego_id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  `si re` = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
  dam_id = c(NA, NA, NA, NA, "d1", "d2", "d2", "d2"),
  sex = c("F", "M", "M", "F", "F", "F", "F", "M"),
  birth_date = mdy(
    paste0(
      sample(1L:12L, 8L, replace = TRUE), "-",
      sample(1L:28L, 8L, replace = TRUE), "-",
      sample(seq(0L, 15L, by = 3L), 8L, replace = TRUE) +
        2000L
    )
  ),
  stringsAsFactors = FALSE, check.names = FALSE
)
pedTwo <- data.frame(
  ego_id =
    c("UNKNOWN", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  `si re` = c(NA, NA, NA, NA, "UNKNOWN", "s1", "s2", "s2"),
  dam_id = c(NA, NA, NA, NA, "d1", "d2", "UNKNOWN", "d2"),
  sex = c("F", "M", "M", "F", "F", "F", "F", "M"),
  fromcenter = c("F", "T", "T", "F", "F", "F", "F", "T"),
  birth_date = mdy(
    paste0(
      sample(1L:12L, 8L, replace = TRUE), "-",
      sample(1L:28L, 8L, replace = TRUE), "-",
      sample(seq(0L, 15L, by = 3L), 8L, replace = TRUE) +
        2000L
    )
  ),
  status = c(
    "A", "alive", "Alive", "1", "S", "Sale", "sold",
    "shipped"
  ),
  ancestry = c(
    "china", "india", "hybridized", NA, "human",
    "gorilla", "human", "gorilla"
  ),
  stringsAsFactors = FALSE, check.names = FALSE
)
pedThree <- data.frame(
  id = c("s1", "d1", "s2", NA, "o1", "o2", "o3", "o4"),
  sire = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
  dam = c(NA, NA, NA, NA, "d1", "d2", "d2", "d2"),
  sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
  stringsAsFactors = FALSE
)
pedThree <- pedThree[!is.na(pedThree$id), ]
pedFour <- data.frame(
  id = c("s1", NA, NA, "d2", "o1", "o2", "o3", "o4"),
  sire = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
  dam = c(NA, NA, NA, NA, "d1", "d2", "d2", "d2"),
  sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
  stringsAsFactors = FALSE
)
pedFour <- pedFour[!is.na(pedFour$id), ]
test_that("qcStudbook detects errors in column names", {
  expect_error(suppressWarnings(qcStudbook(pedOne)))
  expect_error(suppressWarnings(qcStudbook(pedOne[, -1L], minParentAge = NULL)))
})
test_that(
  "qcStudbook returns list of suspicious parents when reportErrors == TRUE",
  {
    expect_identical(
      suppressWarnings(qcStudbook(pedOne,
        reportErrors = TRUE
      )$suspiciousParents$id),
      c("o2", "o3", "o4")
    )
  }
)
test_that(
  "qcStudbook returns list of missing column names when reportErrors == TRUE",
  {
    expect_identical(
      suppressWarnings(
        qcStudbook(pedOne[, -1L],
          minParentAge = NULL,
          reportErrors = TRUE
        )$missingColumns
      ),
      "id"
    )
  }
)
test_that("qcStudbook detects missing required column names", {
  expect_error(suppressWarnings(qcStudbook(pedOne[, -3L])))
})
test_that(
  "qcStudbook returns list of bad column names when reportErrors == TRUE",
  {
    expect_identical(
      qcStudbook(pedOne[, -3L], reportErrors = TRUE)$missingColumns,
      "dam"
    )
  }
)
test_that("qcStudbook corrects column names", {
  newPedOne <- suppressWarnings(qcStudbook(pedOne, minParentAge = NULL))
  expect_named(newPedOne, c(
    "id", "sire", "dam", "sex", "gen",
    "birth", "exit", "age", "recordStatus"
  ))
  expect_identical(as.character(newPedOne$sex[newPedOne$id == "d1"]), "F")
  expect_identical(as.character(newPedOne$sex[newPedOne$id == "s1"]), "M")
})
test_that(
  "qcStudbook reports correction of column names with reportErrors == TRUE",
  {
    errorLst <- qcStudbook(pedOne,
      minParentAge = NULL,
      reportChanges = TRUE, reportErrors = TRUE
    )
    expect_identical(errorLst$changedCols$spaceRemoved, "si re to sire")
    expect_identical(
      errorLst$changedCols$underScoreRemoved,
      "ego_id, dam_id, and birth_date to egoid, damid, and birthdate"
    )
    expect_identical(errorLst$changedCols$damIdToDam, "damid to dam")
    expect_identical(errorLst$changedCols$birthdateToBirth,
                     "birthdate to birth")
  }
)
test_that(
  "qcStudbook corrects use of 'UNKNOWN' in 'id', 'sire' and 'dam' IDS",
  {
    newPedTwo <- suppressWarnings(qcStudbook(pedTwo, minParentAge = NULL))
    expect_identical(newPedTwo$sire[newPedTwo$id == "o1"], "U0001")
    expect_identical(newPedTwo$dam[newPedTwo$id == "o3"], "U0002")
    expect_identical(newPedTwo$sire[newPedTwo$id == "o1"], "U0001")
    expect_true(is.na(newPedTwo$sire[newPedTwo$id == "U0001"]))
  }
)
test_that("qcStudbook corrects status", {
  newPedTwo <- suppressWarnings(qcStudbook(pedTwo,
    minParentAge = NULL
  ))
  newPedTwo$status <- as.character(newPedTwo$status)
  expect_identical(newPedTwo$status[newPedTwo$id == "s2"], "ALIVE")
  expect_identical(newPedTwo$status[newPedTwo$id == "d2"], "ALIVE")
  expect_identical(newPedTwo$status[newPedTwo$id == "o1"], "SHIPPED")
})
test_that("qcStudbook corrects ancestry", {
  newPedTwo <- suppressWarnings(qcStudbook(pedTwo, minParentAge = NULL))
  newPedTwo$ancestry <- as.character(newPedTwo$ancestry)
  expect_identical(newPedTwo$ancestry[newPedTwo$id == "s2"], "HYBRID")
  expect_identical(newPedTwo$ancestry[newPedTwo$id == "d2"], "UNKNOWN")
  expect_identical(newPedTwo$ancestry[newPedTwo$id == "o1"], "OTHER")
})
test_that("qcStudbook removes duplicates", {
  pedDups <- rbind(pedOne, pedOne[1L:3L, ])
  qcPedDups <- qcStudbook(pedDups, minParentAge = NULL)
  expect_identical(nrow(pedOne), nrow(qcPedDups))
})
test_that(
  "qcStudbook removes duplicates and reports them when reportErrors == TRUE",
  {
    pedDups <- rbind(pedOne, pedOne[1L:3L, ])
    dups <- qcStudbook(pedDups,
      minParentAge = NULL,
      reportErrors = TRUE
    )$duplicateIds
    expect_identical(dups, c("s1", "d1", "s2"))
  }
)
test_that(
  "qcStudbook returns NULL with reportErrors == TRUE and no errors present",
  {
    pedClean <- qcStudbook(pedOne, minParentAge = NULL)
    expect_null(qcStudbook(pedClean,
      minParentAge = NULL,
      reportErrors = TRUE
    ))
  }
)
pedFive <- data.frame(
  id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
  dam = c(NA, "d0", "d4", NA, "d1", "d2", "d2", "d2"),
  sex = c("F", "F", "M", "F", "F", "F", "F", "M"),
  birth = mdy(
    paste0(
      sample(1L:12L, 8L, replace = TRUE), "-",
      sample(1L:28L, 8L, replace = TRUE), "-",
      sample(seq(0L, 15L, by = 3L), 8L, replace = TRUE) +
        2000L
    )
  ),
  stringsAsFactors = FALSE
)
test_that(
  paste0(
    "qcStudbook returns NULL errors with reportErrors == TRUE and errors ",
    "not present"
  ),
  {
    pedClean <- qcStudbook(pedFive, minParentAge = NULL, reportErrors = TRUE)
    expect_null(pedClean$maleDams)
  }
)
test_that(
  paste0(
    "qcStudbook returns parent sex errors with reportErrors == TRUE and ",
    "errors present"
  ),
  {
    pedClean <- qcStudbook(pedFive, minParentAge = NULL, reportErrors = TRUE)
    expect_identical(pedClean$femaleSires, "s1")
  }
)
test_that("qcStudbook returns pedigree date errors with reportErrors == TRUE", {
  set_seed(10L)
  someBirthDates <- paste0(
    sample(seq(0L, 15L, by = 3L), 8L,
      replace = TRUE
    ) + 2000L, "-",
    sample(1L:12L, 8L, replace = TRUE), "-",
    sample(1L:28L, 8L, replace = TRUE)
  )
  someBadBirthDates <- paste0(
    sample(1L:12L, 8L, replace = TRUE), "-",
    sample(1L:28L, 8L, replace = TRUE), "-",
    sample(seq(0L, 15L, by = 3L), 8L,
      replace = TRUE
    ) + 2000L
  )
  someDeathDates <- sample(someBirthDates, length(someBirthDates),
    replace = FALSE
  )
  someDepartureDates <- sample(someBirthDates, length(someBirthDates),
    replace = FALSE
  )
  ped1 <- data.frame(
    birth = someBadBirthDates, death = someDeathDates,
    departure = someDepartureDates
  )
  pedSix <- data.frame(pedFive[, names(pedFive) != "birth"], ped1)
  ped6 <- suppressWarnings(qcStudbook(pedSix,
    minParentAge = NULL,
    reportErrors = TRUE
  ))
  expect_identical(
    ped6$invalidDateRows,
    c("1", "2", "3", "4", "5", "6", "7", "8")
  )
})
test_that(
  "qcStudbook passes through nonessential date columns with all == NA",
  {
    pedSeven <- cbind(pedSix, exit = NA, stringsAsFactors = FALSE)
    ped7 <- qcStudbook(pedSeven, minParentAge = NULL, reportErrors = TRUE)
    expect_identical(ped7$invalidDateRows, character(0L))
    ped7 <- qcStudbook(pedSeven, minParentAge = NULL, reportErrors = FALSE)
    expect_true(all(is.na(ped7$exit)))
    expect_length(ped7$exit, 12L)
  }
)
test_that("qcStudbook identifies individual bad dates in date columns", {
  birth <- format(pedOne$birth_date, format = "%Y-%m-%d")
  birth[5L] <- "04-02-2015"
  birth[6L] <- "03-17-2009"
  pedEight <- pedOne
  pedEight$birth_date <- NULL
  pedEight$birth <- birth
  ped8 <- qcStudbook(pedEight, minParentAge = NULL, reportErrors = TRUE)
  expect_identical(ped8$invalidDateRows, c("5", "6"))
})
pedNine <-
  data.frame(
    ego_id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
    `si re` = c("s0", NA, NA, NA, "s1", "s1", "s2", "s2"),
    dam_id = c(NA, "s0", NA, NA, "d1", "d2", "d2", "d2"),
    sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
    birth_date = mdy(
      paste0(
        sample(1L:12L, 8L, replace = TRUE), "-",
        sample(1L:28L, 8L, replace = TRUE), "-",
        sample(seq(0L, 15L, by = 3L), 8L, replace = TRUE) +
          2000L
      )
    ),
    stringsAsFactors = FALSE, check.names = FALSE
  )
test_str <- stri_c(
  "qcStudbook does not report as an error the wrong sex ",
  "for animals added into the pedigree and appear as both ",
  "a sire and dam without an ego record. These need to ",
  "be reported as an error because they are both a sire ",
  "and a dam."
)
test_that(test_str, {
  ped9 <- qcStudbook(pedNine, minParentAge = NULL, reportErrors = TRUE)
  expect_identical(ped9$sireAndDam, "s0")
  expect_length(ped9$duplicateIds, 0L)
})

## NEW-45: IDs may not contain a period ('.'). The documented domain spec
## (input_format.html: id/sire/dam are "Alphanumeric characters (no symbols)")
## is now enforced at data input. Default mode -> stop(); reportErrors == TRUE
## -> the offending value(s) are returned in errorLst$invalidIdChars.
pedPeriod <- data.frame(
  id = c("s1", "d1", "o1.2"),
  sire = c(NA, NA, "s1"),
  dam = c(NA, NA, "d1"),
  sex = c("M", "F", "F"),
  birth = as.Date(c("2000-01-01", "2000-01-01", "2010-01-01")),
  stringsAsFactors = FALSE
)
test_that("qcStudbook rejects IDs containing a period in default mode (NEW-45)", {
  expect_error(
    qcStudbook(pedPeriod, minParentAge = NULL),
    "must not contain a period"
  )
})
test_that("qcStudbook reports period-bearing IDs when reportErrors == TRUE", {
  res <- qcStudbook(pedPeriod, minParentAge = NULL, reportErrors = TRUE)
  expect_identical(res$invalidIdChars, "o1.2")
})
test_that("qcStudbook accepts period-free IDs (no false positive) (NEW-45)", {
  ## pedFive is period-free (it has an unrelated femaleSires error that keeps
  ## the errorLst non-NULL), so the invalidIdChars field must be empty (length
  ## 0) before AND after the fix.
  expect_length(
    qcStudbook(pedFive, minParentAge = NULL, reportErrors = TRUE)$invalidIdChars,
    0L
  )
})

## Issue #117 spinoff (S299): qcStudbook() must preserve the genotype-bearing
## headers first_name/second_name through its column-name normalization.
## fixColumnNames() (the #117 fix) restores every spelling of these headers to
## canonical first_name/second_name before the point where the downstream
## fixGenotypeCols() workaround used to run, so that redundant call was removed
## from qcStudbook(). This guards the invariant end-to-end: a future
## fixColumnNames() regression is caught even though the fixGenotypeCols() safety
## net is gone.
mkGenoPed <- function(fn, sn) {
  ped <- data.frame(
    id = c("s1", "d1", "o1", "o2"),
    sire = c(NA, NA, "s1", "s1"),
    dam = c(NA, NA, "d1", "d1"),
    sex = c("M", "F", "F", "M"),
    birth = as.Date(c("2000-01-01", "2000-01-01",
                      "2010-01-01", "2010-01-01")),
    stringsAsFactors = FALSE
  )
  ped[[fn]] <- c("A004_B002", "A004_B012b", "A008_B017a", "A004_B048a")
  ped[[sn]] <- c("A004_B048a", "A008_B017a", "A004_B002", "A004_B012b")
  ped
}
test_that(
  "qcStudbook keeps genotype first_name/second_name across header spellings",
  {
    spellings <- list(
      c("first_name", "second_name"),
      c("First Name", "Second Name"),
      c("first.name", "second.name"),
      c("firstname", "secondname"),
      c("FIRSTNAME", "SECONDNAME")
    )
    for (sp in spellings) {
      out <- qcStudbook(mkGenoPed(sp[[1L]], sp[[2L]]), minParentAge = NULL)
      expect_true(all(c("first_name", "second_name") %in% names(out)))
      expect_false(any(c("firstname", "secondname") %in% names(out)))
    }
  }
)

## Issue #119 Slice 1: qcStudbook threads the new sex-specific breeding-age
## params through to checkParentAge; minParentAge stays a deprecated alias.
test_that("qcStudbook accepts minSireAge/minDamAge (issue #119)", {
  pedNew <- qcStudbook(nprcgenekeepr::examplePedigree,
    minSireAge = 2.0, minDamAge = 2.0
  )
  pedOld <- suppressWarnings(
    qcStudbook(nprcgenekeepr::examplePedigree, minParentAge = 2.0)
  )
  expect_identical(pedNew, pedOld)
})

test_that("qcStudbook minParentAge alias emits a deprecation warning", {
  lifecycle::expect_deprecated(
    qcStudbook(nprcgenekeepr::examplePedigree, minParentAge = 2.0)
  )
})

## Issue #123 (XARCH-5) Phase 1, Dragon 2: no known code path drops a required
## column between checkRequiredCols() (~line 210) and the line-316 reorder --
## checkRequiredCols() already guarantees id/sire/dam/sex/birth ~100 lines
## earlier in the same function. This is a defense-in-depth guard against a
## FUTURE internal regression, not a fix for an observed-today bug -- stated
## honestly here, per the plan's own Dragon 2 caveat. The fault below is
## CONTRIVED by stubbing removeDuplicates() to strip 'sex' from its returned
## data.frame, simulating a hypothetical future internal fault reaching line
## 316, rather than reproducing any bug this codebase actually exhibits.
test_that("qcStudbook's line-316 guard fires on a contrived internal fault (issue #123 / XARCH-5 Dragon 2)", {
  mockery::stub(qcStudbook, "removeDuplicates", function(sb, ...) {
    sb$sex <- NULL
    sb
  })
  expect_error(
    qcStudbook(pedOne, minParentAge = NULL),
    "required column\\(s\\) missing.*sex"
  )
})
