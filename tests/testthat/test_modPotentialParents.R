# Tests for modPotentialParents.R - Potential Parents Shiny Module (#48)
#
# Wires getPotentialParents() into a user-facing Shiny surface: a numeric
# maxGestationalPeriod input (default 210), a "Find Potential Parents" button,
# a sortable results table, and a CSV download. Owner-ratified design in
# Session 79; integration of the shipped #31 logic under umbrella #45.

# =============================================================================
# flattenPotentialParents() - pure helper turning the getPotentialParents
# list-of-lists (or NULL) into a render/CSV-ready data.frame.
# =============================================================================

test_that("flattenPotentialParents exists", {
  expect_true(exists("flattenPotentialParents"))
})

test_that("flattenPotentialParents returns a data.frame with the expected columns", {
  pp <- list(list(id = "A1", sires = "S1", dams = "D1"))
  df <- flattenPotentialParents(pp)

  expect_true(is.data.frame(df))
  expect_identical(names(df), c("id", "nSires", "nDams", "sires", "dams"))
})

test_that("flattenPotentialParents maps NULL to a 0-row data.frame (empty state)", {
  df <- flattenPotentialParents(NULL)

  expect_true(is.data.frame(df))
  expect_equal(nrow(df), 0L)
  expect_true(all(c("id", "nSires", "nDams", "sires", "dams") %in% names(df)))
})

test_that("flattenPotentialParents maps an empty list to a 0-row data.frame", {
  df <- flattenPotentialParents(list())

  expect_true(is.data.frame(df))
  expect_equal(nrow(df), 0L)
  expect_true(all(c("id", "nSires", "nDams", "sires", "dams") %in% names(df)))
})

test_that("flattenPotentialParents flattens a multi-animal list correctly", {
  pp <- list(
    list(id = "A1", sires = c("S1", "S2"), dams = "D1"),
    list(id = "A2", sires = "S3", dams = c("D2", "D3", "D4"))
  )
  df <- flattenPotentialParents(pp)

  expect_equal(nrow(df), 2L)
  expect_equal(df$id, c("A1", "A2"))
  expect_equal(df$nSires, c(2L, 1L))
  expect_equal(df$nDams, c(1L, 3L))
  expect_equal(df$sires, c("S1, S2", "S3"))
  expect_equal(df$dams, c("D1", "D2, D3, D4"))
})

test_that("flattenPotentialParents handles an entry with no candidate sires", {
  pp <- list(list(id = "A1", sires = character(0), dams = "D1"))
  df <- flattenPotentialParents(pp)

  expect_equal(df$nSires, 0L)
  expect_equal(df$sires, "")
  expect_equal(df$nDams, 1L)
  expect_equal(df$dams, "D1")
})

# =============================================================================
# CSV content - the flattened data.frame round-trips through write.csv.
# =============================================================================

test_that("flattenPotentialParents output round-trips through write.csv", {
  pp <- list(
    list(id = "A1", sires = c("S1", "S2"), dams = "D1"),
    list(id = "A2", sires = character(0), dams = c("D2", "D3"))
  )
  df <- flattenPotentialParents(pp)

  tf <- tempfile(fileext = ".csv")
  on.exit(unlink(tf))
  utils::write.csv(df, tf, row.names = FALSE)
  back <- utils::read.csv(tf, stringsAsFactors = FALSE, colClasses = "character")

  expect_equal(nrow(back), 2L)
  expect_true(all(c("id", "nSires", "nDams", "sires", "dams") %in% names(back)))
  expect_equal(back$id, c("A1", "A2"))
  expect_equal(back$sires, c("S1, S2", ""))
  expect_equal(back$dams, c("D1", "D2, D3"))
})

# =============================================================================
# modPotentialParentsUI()
# =============================================================================

test_that("modPotentialParentsUI returns a shiny.tag", {
  ui <- modPotentialParentsUI("test")
  expect_true(inherits(ui, "shiny.tag"))
})

test_that("modPotentialParentsUI contains the expected controls and namespace", {
  ui_html <- as.character(modPotentialParentsUI("ppNS"))

  expect_true(grepl("ppNS-maxGestationalPeriod", ui_html))
  expect_true(grepl("ppNS-findParents", ui_html))
  expect_true(grepl("ppNS-downloadParents", ui_html))
  expect_true(grepl("ppNS-resultsTable", ui_html))
  expect_true(grepl("Find Potential Parents", ui_html))
})

test_that("modPotentialParentsUI numeric input defaults to 210", {
  ui_html <- as.character(modPotentialParentsUI("test"))
  expect_true(grepl("value=\"210\"", ui_html))
})

# =============================================================================
# modPotentialParentsServer()
# =============================================================================

test_that("modPotentialParentsServer computes a populated table on button press", {
  skip_if_not_installed("shiny")

  pedOne <- nprcgenekeepr::rhesusPedigree
  pedOne$id <- as.character(pedOne$id)
  pedOne$sire <- as.character(pedOne$sire)
  pedOne$dam <- as.character(pedOne$dam)
  pedOne$birth <- as.Date(pedOne$birth)
  pedOne$fromCenter <- TRUE

  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(pedOne), minParentAge = 2),
    {
      session$setInputs(maxGestationalPeriod = 210, findParents = 1)
      td <- session$getReturned()$tableData()

      expect_true(is.data.frame(td))
      expect_true(nrow(td) > 0L)
      expect_true(all(c("id", "nSires", "nDams", "sires", "dams") %in% names(td)))
      expect_true("BRI2MW" %in% td$id)
    }
  )
})

test_that("modPotentialParentsServer degrades to an empty table when fromCenter is absent", {
  skip_if_not_installed("shiny")

  ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    birth = as.Date(c("2000-01-01", "2000-01-01", "2003-01-01")),
    exit = as.Date(NA),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(ped), minParentAge = 2),
    {
      session$setInputs(maxGestationalPeriod = 210, findParents = 1)
      td <- session$getReturned()$tableData()

      expect_true(is.data.frame(td))
      expect_equal(nrow(td), 0L)
    }
  )
})

test_that("modPotentialParentsServer degrades to an empty table when there are no unknowns", {
  skip_if_not_installed("shiny")

  # Only from-center animal (C) has both parents known; A and B have unknown
  # parents but are not from-center -> getPotentialParents returns NULL.
  ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    birth = as.Date(c("2000-01-01", "2000-01-01", "2003-01-01")),
    exit = as.Date(NA),
    fromCenter = c(FALSE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(ped), minParentAge = 2),
    {
      session$setInputs(maxGestationalPeriod = 210, findParents = 1)
      td <- session$getReturned()$tableData()

      expect_true(is.data.frame(td))
      expect_equal(nrow(td), 0L)
    }
  )
})

test_that("modPotentialParentsServer returns the expected reactive list", {
  skip_if_not_installed("shiny")

  ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    birth = as.Date(c("2000-01-01", "2000-01-01", "2003-01-01")),
    exit = as.Date(NA),
    fromCenter = c(TRUE, TRUE, TRUE),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(ped)),
    {
      result <- session$getReturned()

      expect_true(is.list(result))
      expect_true(all(c("potentialParents", "tableData") %in% names(result)))
      expect_true(is.function(result$potentialParents))
      expect_true(is.function(result$tableData))
    }
  )
})
