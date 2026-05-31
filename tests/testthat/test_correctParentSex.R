#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
library(testthat)
pedOne <- data.frame(
  id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
  dam = c(NA, "d0", "d4", NA, "d1", "d2", "d2", "d2"),
  sex = c("F", "F", "M", "F", "F", "F", "F", "M"),
  recordStatus = rep("original", 8L),
  stringsAsFactors = FALSE
)
pedTwo <- data.frame(
  id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
  dam = c("d0", "d0", "d4", NA, "d1", "d2", "d2", "d2"),
  sex = c("M", "M", "M", "F", "F", "F", "F", "M"),
  recordStatus = rep("original", 8L),
  stringsAsFactors = FALSE
)
pedThree <- data.frame(
  id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
  dam = c("d0", "d0", "d4", NA, "d1", "d2", "s1", "d2"),
  sex = c("M", "M", "M", "F", "F", "F", "F", "M"),
  recordStatus = rep("original", 8L),
  stringsAsFactors = FALSE
)

pedOne$sex <- correctParentSex(
  pedOne$id, pedOne$sire, pedOne$dam, pedOne$sex,
  pedOne$recordStatus
)
pedTwo$sex <- correctParentSex(
  pedTwo$id, pedTwo$sire, pedTwo$dam, pedTwo$sex,
  pedOne$recordStatus
)
test_that("correctParentSex makes correct changes", {
  expect_true(pedOne$sex[1L] == "M")
  expect_true(pedTwo$sex[2L] == "F")
  expect_error(correctParentSex(
    pedThree$id, pedThree$sire, pedThree$dam,
    pedThree$sex, pedOne$recordStatus
  ))
})
test_that(paste0(
  "correctParentSex returns NULLs if no errors detected and ",
  "reportErrors flag is TRUE"
), {
  test <- correctParentSex(pedOne$id, pedOne$sire, pedOne$dam, pedOne$sex,
    pedOne$recordStatus,
    reportErrors = TRUE
  )
  expect_true(is.null(test$femaleSires) & is.null(test$maleDams))
  test <- correctParentSex(pedTwo$id, pedTwo$sire, pedTwo$dam, pedTwo$sex,
    pedOne$recordStatus,
    reportErrors = TRUE
  )
  expect_true(is.null(test$femaleSires) & is.null(test$maleDams))
})
test_that(paste0(
  "correctParentSex returns character vector with ID where ",
  "errors detected and reportErrors flag is TRUE"
), {
  expect_equal(correctParentSex(pedThree$id, pedThree$sire, pedThree$dam,
    pedThree$sex, pedOne$recordStatus,
    reportErrors = TRUE
  )$sireAndDam, "s1")
  pedTwo <- data.frame(
    id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
    sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
    dam = c("d0", "d0", "d4", NA, "d1", "d2", "d2", "d2"),
    sex = c("M", "M", "M", "F", "F", "F", "F", "M"),
    stringsAsFactors = FALSE
  )
  expect_identical(correctParentSex(pedTwo$id, pedTwo$sire, pedTwo$dam, pedTwo$sex,
    pedOne$recordStatus,
    reportErrors = TRUE
  )$maleDams, "d1")
})

# --- NEW-37: the correction branch must mirror the report branch -------------
# The report branch (reportErrors = TRUE) deliberately exempts H/U parents
# (correctParentSex.R:71,73 use `!sex %in% c("H","U","M")` / `c("H","U","F")`).
# The default correction branch (reportErrors = FALSE) must agree: a
# hermaphrodite ("H") or unknown-sex ("U") animal listed as a sire/dam keeps
# its recorded sex and is NOT silently rewritten to M/F.
pedHU <- data.frame(
  id = c("sH", "sU", "dH", "dU", "o1", "o2"),
  sire = c(NA, NA, NA, NA, "sH", "sU"),
  dam = c(NA, NA, NA, NA, "dH", "dU"),
  sex = c("H", "U", "H", "U", "F", "M"),
  recordStatus = rep("original", 6L),
  stringsAsFactors = FALSE
)
test_that("correctParentSex leaves H/U sires and dams unchanged (NEW-37)", {
  corrected <- correctParentSex(
    pedHU$id, pedHU$sire, pedHU$dam, pedHU$sex, pedHU$recordStatus
  )
  expect_identical(corrected[pedHU$id == "sH"], "H") # H sire stays H
  expect_identical(corrected[pedHU$id == "sU"], "U") # U sire stays U
  expect_identical(corrected[pedHU$id == "dH"], "H") # H dam stays H
  expect_identical(corrected[pedHU$id == "dU"], "U") # U dam stays U
})
test_that(paste0(
  "correctParentSex still corrects true female-sires and male-dams ",
  "(NEW-37 guard)"
), {
  pedMix <- data.frame(
    id = c("fSire", "mDam", "o1"),
    sire = c(NA, NA, "fSire"),
    dam = c(NA, NA, "mDam"),
    sex = c("F", "M", "F"),
    recordStatus = rep("original", 3L),
    stringsAsFactors = FALSE
  )
  corrected <- correctParentSex(
    pedMix$id, pedMix$sire, pedMix$dam, pedMix$sex, pedMix$recordStatus
  )
  expect_identical(corrected[pedMix$id == "fSire"], "M") # F sire -> M
  expect_identical(corrected[pedMix$id == "mDam"], "F") # M dam  -> F
})
test_that(paste0(
  "qcStudbook preserves a U-sex parent through the canonical pipeline ",
  "(NEW-37)"
), {
  sb <- data.frame(
    id = c("sU", "dF", "o1"),
    sire = c(NA, NA, "sU"),
    dam = c(NA, NA, "dF"),
    sex = c("U", "F", "F"),
    birth = as.Date(c("2000-01-01", "2000-01-01", "2010-01-01")),
    recordStatus = rep("original", 3L),
    stringsAsFactors = FALSE
  )
  ped <- qcStudbook(sb, reportErrors = FALSE)
  expect_identical(as.character(ped$sex[ped$id == "sU"]), "U")
})
