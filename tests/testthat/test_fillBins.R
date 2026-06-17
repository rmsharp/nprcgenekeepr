#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
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
pedOne$age <- (mdy("06/01/2018") - as.Date(pedOne$birth)) / dyears(1L)
test_that("fillBins adds correct number to each bin", {
  lower_ages <- seq(0L, 20L, by = 5L)
  upper_ages <- NULL
  expect_identical(fillBins(pedOne, lower_ages)$males, c(0L, 0L, 2L, 1L, 0L))
  expect_identical(fillBins(pedOne, lower_ages)$females, c(2L, 2L, 0L, 1L, 0L))
})

## #33: complete the fillBins @return documentation. The @return block (NOT
## the title, which already mentions \code{males}/\code{females}) must describe
## both returned elements and carry no leftover TODO placeholder.
returnBlock <- function(src) {
  lines <- readLines(src, warn = FALSE)
  retIdx <- grep("@return", lines)[1L]
  if (is.na(retIdx)) {
    return(NA_character_)
  }
  rest <- lines[seq.int(retIdx + 1L, length(lines))]
  nextTag <- which(grepl("^#'\\s*@", rest))[1L]
  end <- if (is.na(nextTag)) length(lines) else retIdx + nextTag - 1L
  paste(lines[seq.int(retIdx, end)], collapse = "\n")
}

test_that("fillBins @return documentation is complete (no TODO placeholder)", {
  src <- testthat::test_path("..", "..", "R", "fillBins.R")
  skip_if(!file.exists(src), "R/ source not available (installed package)")
  block <- returnBlock(src)
  expect_false(
    grepl("TODO", block, fixed = TRUE),
    info = "fillBins @return must not contain a TODO placeholder"
  )
  expect_match(block, "\\bmales\\b",
    info = "@return must document the males element"
  )
  expect_match(block, "\\bfemales\\b",
    info = "@return must document the females element"
  )
})

test_that("fillBins returns the documented list(males, females) contract", {
  lower_ages <- seq(0L, 20L, by = 5L)
  res <- fillBins(pedOne, lower_ages)
  expect_type(res, "list")
  expect_named(res, c("males", "females"))
  expect_type(res$males, "integer")
  expect_type(res$females, "integer")
  expect_length(res$males, length(lower_ages))
  expect_length(res$females, length(lower_ages))
})
