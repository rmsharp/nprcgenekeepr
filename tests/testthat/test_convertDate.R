## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(lubridate)
set_seed(10L)
someBirthDates <- paste0(
  sample(seq(0L, 15L, by = 3L), 10L, replace = TRUE) + 2000L,
  "-", sample(1L:12L, 10L, replace = TRUE), "-",
  sample(1L:28L, 10L, replace = TRUE)
)
someBadBirthDates <- paste0(
  sample(1L:12L, 10L, replace = TRUE), "-",
  sample(1L:28L, 10L, replace = TRUE), "-",
  sample(seq(0L, 15L, by = 3L), 10L, replace = TRUE) + 2000L
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
someDates <- ymd(someBirthDates)
ped2 <- data.frame(
  birth = someDates, death = someDeathDates,
  departure = someDepartureDates
)
ped3 <- data.frame(
  birth = someBirthDates, death = someDeathDates,
  departure = someDepartureDates
)
someNADeathDates <- someDeathDates
someNADeathDates[c(1L, 3L, 5L)] <- ""
someNABirthDates <- someDates
someNABirthDates[c(2L, 4L, 6L)] <- NA
ped4 <- data.frame(
  birth = someNABirthDates, death = someNADeathDates,
  departure = someDepartureDates
)

test_that("convertDate identifies bad dates", {
  expect_error(convertDate(ped1))
})
test_that("convertDate with error flag returns error list", {
  expect_equal(
    convertDate(ped1, reportErrors = TRUE),
    c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10")
  )
})
test_that("convertDate likes good dates", {
  expect_true(all(is.Date(convertDate(ped2)$birth)))
  expect_true(all(is.Date(convertDate(ped3)$birth)))
})
test_that("convertDate with error flag returns NULL with good dates", {
  expect_true(all(is.null(convertDate(ped2, reportErrors = TRUE))))
  expect_true(all(is.null(convertDate(ped3, reportErrors = TRUE))))
})
test_that(paste0(
  "convertDate handles NA and empty character string values ",
  "correctly"
), {
  expect_null(convertDate(ped4, reportErrors = TRUE))
})
test_that("convertDate ignores added records", {
  ped5 <- cbind(ped4,
    recordStatus = c(rep("added", 10L)),
    stringsAsFactors = FALSE
  )
  expect_identical(nrow(convertDate(ped5)), 10L)
  expect_true(all(convertDate(ped5)$recordStatus == "added"))
})
## Only "added" records (placeholders for unlisted parents) are skipped. An NA
## or unrecognized recordStatus is a real animal: it is kept, in place, with
## its date converted and validated like any original record.
statusPed <- data.frame(
  id = c("a", "b", "c", "d", "e", "x1"),
  birth = c(
    "2001-01-05", "2002-02-06", "2003-03-07", "2004-04-08", "2005-05-09", NA
  ),
  recordStatus = c(rep("original", 5L), "added"),
  stringsAsFactors = FALSE
)
naStatusPed <- statusPed
naStatusPed$recordStatus[3L] <- NA_character_
weirdStatusPed <- statusPed
weirdStatusPed$recordStatus[4L] <- "weird"

test_that(paste0(
  "convertDate keeps an animal whose recordStatus is NA and converts its ",
  "date without adding a phantom row"
), {
  result <- convertDate(naStatusPed)
  expect_false(anyNA(result$id))
  expect_identical(result$id, naStatusPed$id)
  expect_s3_class(result$birth, "Date")
  expect_identical(result$birth[3L], as.Date("2003-03-07"))
  expect_identical(result$recordStatus, naStatusPed$recordStatus)
})
test_that(paste0(
  "convertDate keeps an animal with an unrecognized recordStatus and ",
  "converts its date"
), {
  result <- convertDate(weirdStatusPed)
  expect_identical(result$id, weirdStatusPed$id)
  expect_s3_class(result$birth, "Date")
  expect_identical(result$birth[4L], as.Date("2004-04-08"))
  expect_identical(result$recordStatus, weirdStatusPed$recordStatus)
})
test_that("convertDate keeps every animal when every recordStatus is NA", {
  allNaPed <- statusPed[1L:5L, ]
  allNaPed$recordStatus <- NA_character_
  result <- convertDate(allNaPed)
  expect_false(anyNA(result$id))
  expect_identical(result$id, allNaPed$id)
  expect_s3_class(result$birth, "Date")
})
test_that(paste0(
  "convertDate with error flag validates the date of an animal whose ",
  "recordStatus is NA or unrecognized"
), {
  badNaPed <- naStatusPed
  badNaPed$birth[3L] <- "03-07-2003"
  expect_identical(convertDate(badNaPed, reportErrors = TRUE), "3")
  badWeirdPed <- weirdStatusPed
  badWeirdPed$birth[4L] <- "04-08-2004"
  expect_identical(convertDate(badWeirdPed, reportErrors = TRUE), "4")
})
test_that(paste0(
  "convertDate with error flag still ignores a bad date on an added record"
), {
  badAddedPed <- statusPed
  badAddedPed$birth[6L] <- "04-08-2004"
  expect_null(convertDate(badAddedPed, reportErrors = TRUE))
})
test_that("convertDate fails when date column class is real", {
  ped5 <- ped3
  ped5$birth <- rnorm(10L, 10L, 100L)
  expect_error(convertDate(ped5))
})

ped <- nprcgenekeepr::pedInvalidDates
rowsWithBadDates <- convertDate(ped, reportErrors = TRUE)
test_that("classifies dates <= 1000 CE as errors", {
  expect_true(any(3L %in% rowsWithBadDates))
})
pedWithNAs <- ped
pedWithNAs[, "birth"] <- as.Date(pedWithNAs[, "birth"], origin = "1970-01-01")

pedWithNAs <- convertDate(pedWithNAs, reportErrors = FALSE)
test_that("classifies dates <= 1000 CE as errors", {
  expect_true(all(is.na(pedWithNAs[3L:4L, "birth"])))
})
