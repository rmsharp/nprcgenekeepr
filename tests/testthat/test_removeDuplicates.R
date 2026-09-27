## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)
library(stringi)
ped <- nprcgenekeepr::smallPed
newPed <- cbind(ped, recordStatus = rep("original", nrow(ped)))

test_that("removeDuplicates removes nothing with no duplicates", {
  ped1 <- removeDuplicates(newPed)
  expect_identical(nrow(newPed), nrow(ped1))
  ped <- rbind(newPed, newPed[1L:3L, ])
  ped1 <- removeDuplicates(ped)
  expect_identical(nrow(ped) - 3L, nrow(ped1))
  ped <- newPed
  ped2 <- ped[1L:3L, ]
  ped2$dam[[1L]] <- "B"
  ped <- rbind(ped, ped2)
  expect_error(removeDuplicates(ped))
})
test_that("removeDuplicates detects missing column and stops processing", {
  expect_error(removeDuplicates(ped))
  expect_silent(removeDuplicates(newPed))
})
test_that(stri_c(
  "removeDuplicates returns NULL reportErrors flag == TRUE ",
  "when there are no duplicates"
), {
  expect_null(removeDuplicates(newPed, reportErrors = TRUE))
  ped <- rbind(newPed, newPed[1L:3L, ])
  ped1 <- removeDuplicates(ped, reportErrors = TRUE)
  expect_identical(ped1, c("A", "B", "C"))
  ped <- newPed
  ped2 <- ped[1L:3L, ]
  ped2$dam[[1L]] <- "B"
  ped <- rbind(ped, ped2)
  expect_identical(removeDuplicates(ped, reportErrors = TRUE), c("A", "B", "C"))
})

## Only "added" is a special recordStatus (the removeUnknownAnimals() and
## convertDate() contract). An NA, blank or unrecognised status is a real
## animal, so its duplicates are reported and it is never mistaken for an
## added record.
makeStatusPed <- function(id, status) {
  data.frame(id = id, recordStatus = status, stringsAsFactors = FALSE)
}
pedWithDups <- rbind(newPed, newPed[1L:3L, ])
dupRows <- nrow(newPed) + 1L:3L

test_that("removeDuplicates reports duplicates whose recordStatus is NA", {
  firstNA <- pedWithDups
  firstNA$recordStatus[1L:3L] <- NA
  expect_identical(
    removeDuplicates(firstNA, reportErrors = TRUE), c("A", "B", "C")
  )
  secondNA <- pedWithDups
  secondNA$recordStatus[dupRows] <- NA
  expect_identical(
    removeDuplicates(secondNA, reportErrors = TRUE), c("A", "B", "C")
  )
  allNA <- pedWithDups
  allNA$recordStatus <- NA_character_
  expect_identical(
    removeDuplicates(allNA, reportErrors = TRUE), c("A", "B", "C")
  )
})
test_that("removeDuplicates does not invent a duplicate from NA statuses", {
  innocentNA <- pedWithDups
  innocentNA$recordStatus[c(nrow(newPed) - 1L, nrow(newPed))] <- NA
  expect_identical(
    removeDuplicates(innocentNA, reportErrors = TRUE), c("A", "B", "C")
  )
  noDups <- newPed
  noDups$recordStatus[c(3L, 5L)] <- NA
  expect_null(removeDuplicates(noDups, reportErrors = TRUE))
})
test_that("removeDuplicates treats a blank or unrecognised status as real", {
  weird <- pedWithDups
  weird$recordStatus[dupRows] <- "weird"
  expect_identical(
    removeDuplicates(weird, reportErrors = TRUE), c("A", "B", "C")
  )
  blank <- pedWithDups
  blank$recordStatus[dupRows] <- ""
  expect_identical(
    removeDuplicates(blank, reportErrors = TRUE), c("A", "B", "C")
  )
})
test_that("removeDuplicates never names an added record as a duplicate", {
  ## More added records than originals: a logical mask shorter than ped$id
  ## would be recycled over the added rows.
  recycled <- makeStatusPed(
    c("x", "x", "z", "a1", "a2", "a3", "a4"),
    c(rep("original", 3L), rep("added", 4L))
  )
  expect_identical(removeDuplicates(recycled, reportErrors = TRUE), "x")
})
test_that("removeDuplicates reports the right ids whatever the row order", {
  addedFirst <- makeStatusPed(
    c("a1", "x", "z", "x"), c("added", rep("original", 3L))
  )
  expect_identical(removeDuplicates(addedFirst, reportErrors = TRUE), "x")
  twoAddedFirst <- makeStatusPed(
    c("a1", "a2", "x", "x"), c("added", "added", "original", "original")
  )
  expect_identical(removeDuplicates(twoAddedFirst, reportErrors = TRUE), "x")
  addedMiddle <- makeStatusPed(
    c("x", "a1", "x", "z"), c("original", "added", "original", "original")
  )
  expect_identical(removeDuplicates(addedMiddle, reportErrors = TRUE), "x")
})
test_that("control: removeDuplicates keeps its ordinary reportErrors result", {
  ## one entry per extra occurrence of an id
  triple <- makeStatusPed(c("x", "x", "x", "z"), "original")
  expect_identical(removeDuplicates(triple, reportErrors = TRUE), c("x", "x"))
  ## nothing to report
  expect_null(
    removeDuplicates(makeStatusPed(character(0L), character(0L)),
      reportErrors = TRUE
    )
  )
  expect_null(
    removeDuplicates(makeStatusPed(c("a", "b", "c"), "added"),
      reportErrors = TRUE
    )
  )
  ## added records that share an id are not duplicated original records
  addedTwice <- makeStatusPed(
    c("x", "y", "a1", "a1", "a1"),
    c("original", "original", "added", "added", "added")
  )
  expect_null(removeDuplicates(addedTwice, reportErrors = TRUE))
})
test_that("control: removeDuplicates accepts a factor recordStatus", {
  asFactor <- pedWithDups
  asFactor$recordStatus <- factor(
    asFactor$recordStatus,
    levels = c("original", "added")
  )
  expect_identical(
    removeDuplicates(asFactor, reportErrors = TRUE), c("A", "B", "C")
  )
})
test_that("control: removeDuplicates reportErrors = FALSE ignores the status", {
  allNA <- pedWithDups
  allNA$recordStatus <- NA_character_
  expect_identical(nrow(removeDuplicates(allNA)), nrow(newPed))
  weird <- pedWithDups
  weird$recordStatus <- "weird"
  expect_identical(nrow(removeDuplicates(weird)), nrow(newPed))
  recycled <- makeStatusPed(
    c("x", "x", "z", "a1", "a2", "a3", "a4"),
    c(rep("original", 3L), rep("added", 4L))
  )
  expect_identical(nrow(removeDuplicates(recycled)), 6L)
})
