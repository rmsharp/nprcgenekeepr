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
    "birth", "exit", "age", "recordStatus", "placeholder"
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
  stri_c(
    "qcStudbook reports only the real duplicate id, not the ids it adds for ",
    "unlisted parents, when reportErrors == TRUE"
  ),
  {
    ## Three original records (id x twice) whose four parents have no record
    ## of their own, so qcStudbook() appends four "added" records.
    pedDupUnlisted <- data.frame(
      id = c("x", "x", "z"),
      sire = c("s1", "s1", "s2"),
      dam = c("d1", "d1", "d2"),
      sex = c("F", "F", "M"),
      birth = as.Date(c("2010-01-01", "2010-01-01", "2012-01-01")),
      stringsAsFactors = FALSE
    )
    errorLst <- qcStudbook(pedDupUnlisted,
      minParentAge = NULL,
      reportErrors = TRUE
    )
    expect_identical(errorLst$duplicateIds, "x")
  }
)
test_that(
  stri_c(
    "control: qcStudbook reports no duplicate id for unlisted parents when ",
    "no id is duplicated and reportErrors == TRUE"
  ),
  {
    pedUnlisted <- data.frame(
      id = c("x", "y", "z"),
      sire = c("s1", "s1", "s2"),
      dam = c("d1", "d1", "d2"),
      sex = c("F", "F", "M"),
      birth = as.Date(c("2010-01-01", "2011-01-01", "2012-01-01")),
      stringsAsFactors = FALSE
    )
    expect_null(qcStudbook(pedUnlisted, minParentAge = NULL, reportErrors = TRUE))
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

## BACKLOG (found S578, broadened S581): the final `order(gen, id)` reorder
## (qcStudbook.R L323) uses plain, locale-dependent `order()`, the same class
## of bug Learning 585 fixed in `.positionMatingUnitForest()` via
## `method = "radix"`. Empirically confirmed (S581) this session that plain
## `order()` on this id set diverges between `LC_COLLATE = "C"` and this
## environment's own default (`en_US.UTF-8`) -- byte/radix order is
## `A1, B2, _ctrl, a9, b17`; the current default-locale order is
## `_ctrl, A1, a9, b17, B2`. All 5 animals are founders (gen 0), so `gen` is
## constant and the observed row order is entirely decided by the `id`
## secondary key.
test_that("qcStudbook orders same-generation ids by byte/radix order, not locale collation (#578)", {
  divergingIds <- c("b17", "B2", "a9", "A1", "_ctrl")
  qcOrderPed <- data.frame(
    id = divergingIds,
    sire = rep(NA_character_, 5L),
    dam = rep(NA_character_, 5L),
    sex = rep("F", 5L),
    birth = rep(as.Date("2010-01-01"), 5L),
    stringsAsFactors = FALSE
  )
  out <- suppressWarnings(qcStudbook(qcOrderPed, minParentAge = NULL))
  expect_identical(out$id, c("A1", "B2", "_ctrl", "a9", "b17"))
})

## --- the placeholder mark (placeholder-marking plan Slice 2, S808) --------
## qcStudbook() writes a logical `placeholder` column: TRUE for a made-up
## stand-in for an unknown parent, FALSE for a real animal (D2). It marks the
## stand-ins it makes TRUE, keeps a user's TRUE/FALSE, and marks every other
## row by the id-shape rule. K2 has no recorded sire and K3 no recorded dam, so
## QC makes one stand-in for each; U1 is a real animal (D3, Slice 1).
pedMade <- data.frame(
  id = c("S1", "D1", "U1", "K1", "K2", "K3"),
  sire = c(NA, NA, NA, "S1", NA, "S1"),
  dam = c(NA, NA, NA, "D1", "D1", NA),
  sex = c("M", "F", "F", "F", "M", "F"),
  birth = as.Date(c("2000-01-01", "2000-01-01", "2000-01-01",
                    "2008-01-01", "2009-01-01", "2010-01-01")),
  stringsAsFactors = FALSE
)
## U1234 is a real sire; K1 is its offspring.
pedU1234 <- data.frame(
  id = c("S1", "D1", "U1234", "K1", "K2"),
  sire = c(NA, NA, NA, "U1234", NA),
  dam = c(NA, NA, NA, "D1", "D1"),
  sex = c("M", "F", "M", "F", "M"),
  birth = as.Date(c("2000-01-01", "2000-01-01", "2000-01-01",
                    "2008-01-01", "2009-01-01")),
  placeholder = c(NA, NA, FALSE, NA, NA),
  stringsAsFactors = FALSE
)
markOf <- function(ped, ids) ped$placeholder[match(ids, ped$id)]

test_that("qcStudbook() adds a logical placeholder column marking exactly the stand-ins it made", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL) # default U%04d
  q <- qcStudbook(pedMade, minSireAge = 2, minDamAge = 2)
  made <- c(q$sire[q$id == "K2"], q$dam[q$id == "K3"])
  expect_true(is.logical(q$placeholder))
  expect_false(anyNA(q$placeholder))
  expect_setequal(q$id[q$placeholder], made)
})

## A format set directly with options() skips setAutoIdFormat()'s check (D11),
## so its ids ("U   1") need not look like stand-ins. The mark records what QC
## made, not what an id looks like (D2).
test_that("qcStudbook() marks the stand-ins it made TRUE even when their ids do not look like stand-ins", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = "U%4d")
  q <- qcStudbook(pedMade, minSireAge = 2, minDamAge = 2)
  made <- q$sire[q$id == "K2"]
  expect_false(isGeneratedUnknownId(made)) # the id-shape rule cannot read it
  expect_true(markOf(q, made))
})

test_that("qcStudbook() keeps a real U1234 marked FALSE real, through removeAutoGenIds()", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL)
  q <- qcStudbook(pedU1234, minSireAge = 2, minDamAge = 2)
  expect_false(markOf(q, "U1234"))
  out <- removeAutoGenIds(q)
  expect_true("U1234" %in% out$id)
  expect_identical(out$sire[out$id == "K1"], "U1234")
})

## M4: recordStatus is rebuilt on every QC run; the mark must not be.
test_that("running qcStudbook() again keeps every placeholder mark", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL)
  q1 <- qcStudbook(pedU1234, minSireAge = 2, minDamAge = 2)
  q2 <- qcStudbook(q1, minSireAge = 2, minDamAge = 2)
  expect_false(anyNA(q1$placeholder))
  expect_identical(sum(q1$placeholder), 1L) # K2's made sire
  expect_identical(markOf(q2, q1$id), q1$placeholder)
})

test_that("qcStudbook() marks a pedigree with no placeholder column by the id-shape rule", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL)
  q <- qcStudbook(nprcgenekeepr::examplePedigree, minSireAge = 2, minDamAge = 2)
  expect_false(anyNA(q$placeholder))
  expect_identical(q$placeholder, isGeneratedUnknownId(q$id))
  expect_gt(sum(q$placeholder), 0L)
})

## D13: TRUE/FALSE in R's own spellings, 1/0 and blank are accepted.
test_that("qcStudbook() reads TRUE/FALSE spellings, 1/0 and blanks in the placeholder column", {
  old <- getOption("nprcgenekeepr.autoIdFormat")
  on.exit(options(nprcgenekeepr.autoIdFormat = old), add = TRUE)
  options(nprcgenekeepr.autoIdFormat = NULL)
  ids <- c("S1", "D1", "U1", "K1", "K2", "K3")
  asText <- pedMade
  asText$placeholder <- c("TRUE", "F", "true", "False", "", NA)
  q <- qcStudbook(asText, minSireAge = 2, minDamAge = 2)
  expect_identical(markOf(q, ids), c(TRUE, FALSE, TRUE, FALSE, FALSE, FALSE))
  asNumber <- pedMade
  asNumber$placeholder <- c(1, 0, 1L, 0, NA, NA)
  q <- qcStudbook(asNumber, minSireAge = 2, minDamAge = 2)
  expect_identical(markOf(q, ids), c(TRUE, FALSE, TRUE, FALSE, FALSE, FALSE))
})

## D5/D13: any other value stops QC and lists the rows (data rows, as for
## invalid dates).
test_that("qcStudbook(reportErrors = TRUE) lists the rows with a placeholder value it does not accept", {
  bad <- pedMade
  bad$placeholder <- c("yes", NA, "2", "TRUE", NA, NA)
  errorLst <- qcStudbook(bad, minSireAge = 2, minDamAge = 2,
                         reportErrors = TRUE)
  expect_identical(errorLst$invalidPlaceholderRows, c("1", "3"))
  badNumber <- pedMade
  badNumber$placeholder <- c(1, 2, 0, NA, NA, -1)
  errorLst <- qcStudbook(badNumber, minSireAge = 2, minDamAge = 2,
                         reportErrors = TRUE)
  expect_identical(errorLst$invalidPlaceholderRows, c("2", "6"))
})

test_that("qcStudbook() stops, naming the rows, on a placeholder value it does not accept", {
  bad <- pedMade
  bad$placeholder <- c("yes", NA, "2", "TRUE", NA, NA)
  expect_error(
    qcStudbook(bad, minSireAge = 2, minDamAge = 2),
    "placeholder.*1, 3"
  )
})
