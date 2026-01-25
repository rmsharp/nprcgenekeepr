# Tests for modInput.R - qcStudbook Integration
# These tests verify the integration of qcStudbook() with the modInput module

# ============================================================================
# Helper Function Tests - processQcStudbookResult
# ============================================================================

test_that("processQcStudbookResult converts errorLst with no errors to UI format", {
  # This function should convert qcStudbook errorLst to UI-friendly format
  errorLst <- getEmptyErrorLst()

  result <- processQcStudbookResult(errorLst)

  expect_true(is.list(result))
  expect_true("errors" %in% names(result))
  expect_true("warnings" %in% names(result))
  expect_true("changedCols" %in% names(result))
  expect_true("hasErrors" %in% names(result))
  expect_false(result$hasErrors)
  expect_equal(nrow(result$errors), 0)
})

test_that("processQcStudbookResult detects female sires", {
  errorLst <- getEmptyErrorLst()
  errorLst$femaleSires <- c("A001", "A002")

  result <- processQcStudbookResult(errorLst)

  expect_true(result$hasErrors)
  expect_true(nrow(result$errors) > 0)
  expect_true(any(grepl("female.*sire|sire.*female", result$errors$Error, ignore.case = TRUE)))
})

test_that("processQcStudbookResult detects male dams", {
  errorLst <- getEmptyErrorLst()
  errorLst$maleDams <- c("B001", "B002")

  result <- processQcStudbookResult(errorLst)

  expect_true(result$hasErrors)
  expect_true(nrow(result$errors) > 0)
  expect_true(any(grepl("male.*dam|dam.*male", result$errors$Error, ignore.case = TRUE)))
})

test_that("processQcStudbookResult detects animals that are both sire and dam", {
  errorLst <- getEmptyErrorLst()
  errorLst$sireAndDam <- c("C001")

  result <- processQcStudbookResult(errorLst)

  expect_true(result$hasErrors)
  expect_true(nrow(result$errors) > 0)
  expect_true(any(grepl("sire.*dam|both", result$errors$Error, ignore.case = TRUE)))
})

test_that("processQcStudbookResult detects duplicate IDs", {
  errorLst <- getEmptyErrorLst()
  errorLst$duplicateIds <- c("D001", "D002", "D003")

  result <- processQcStudbookResult(errorLst)

  expect_true(result$hasErrors)
  expect_true(nrow(result$errors) > 0)
  expect_true(any(grepl("duplicate", result$errors$Error, ignore.case = TRUE)))
})

test_that("processQcStudbookResult detects missing columns", {
  errorLst <- getEmptyErrorLst()
  errorLst$missingColumns <- c("id", "sire")

  result <- processQcStudbookResult(errorLst)

  expect_true(result$hasErrors)
  expect_true(nrow(result$errors) > 0)
  expect_true(any(grepl("missing.*column", result$errors$Error, ignore.case = TRUE)))
})

test_that("processQcStudbookResult detects invalid date rows", {
  errorLst <- getEmptyErrorLst()
  errorLst$invalidDateRows <- c("row 5", "row 10")

  result <- processQcStudbookResult(errorLst)

  expect_true(result$hasErrors)
  expect_true(nrow(result$errors) > 0)
  expect_true(any(grepl("date|invalid", result$errors$Error, ignore.case = TRUE)))
})

test_that("processQcStudbookResult detects suspicious parents (low age)", {
  errorLst <- getEmptyErrorLst()
  errorLst$suspiciousParents <- data.frame(
    id = c("E001", "E002"),
    parentId = c("P001", "P002"),
    parentAge = c(1.5, 1.2),
    stringsAsFactors = FALSE
  )

  result <- processQcStudbookResult(errorLst)

  expect_true(result$hasErrors)
  expect_true(nrow(result$errors) > 0)
  expect_true(any(grepl("parent.*age|age|young", result$errors$Error, ignore.case = TRUE)))
})

test_that("processQcStudbookResult detects database connection failure", {
  errorLst <- getEmptyErrorLst()
  errorLst$failedDatabaseConnection <- "Could not connect to database"

  result <- processQcStudbookResult(errorLst)

  expect_true(result$hasErrors)
  expect_true(nrow(result$errors) > 0)
  expect_true(any(grepl("database|connection", result$errors$Error, ignore.case = TRUE)))
})

test_that("processQcStudbookResult tracks changed columns", {
  errorLst <- getEmptyErrorLst()
  errorLst$changedCols$caseChange <- c("ID", "SIRE")
  errorLst$changedCols$spaceRemoved <- c("dam id")

  result <- processQcStudbookResult(errorLst)

  expect_false(result$hasErrors) # Changed columns are warnings, not errors
  expect_true(result$hasChangedCols)
  expect_true(nrow(result$warnings) > 0 || length(result$changedCols) > 0)
})

test_that("processQcStudbookResult handles multiple error types", {
  errorLst <- getEmptyErrorLst()
  errorLst$femaleSires <- c("A001")
  errorLst$maleDams <- c("B001")
  errorLst$duplicateIds <- c("C001")

  result <- processQcStudbookResult(errorLst)

  expect_true(result$hasErrors)
  # Should have at least 3 error entries

  expect_gte(nrow(result$errors), 3)
})

test_that("processQcStudbookResult returns proper data frame structure for errors", {
  errorLst <- getEmptyErrorLst()
  errorLst$femaleSires <- c("A001")

  result <- processQcStudbookResult(errorLst)

  expect_true("Row" %in% names(result$errors) || "ID" %in% names(result$errors))
  expect_true("Error" %in% names(result$errors))
  expect_true("Details" %in% names(result$errors))
})

# ============================================================================
# Integration Tests - qcStudbook with real pedigree data
# ============================================================================

test_that("runQcStudbook processes valid pedigree correctly", {
  data("pedGood", package = "nprcgenekeepr")

  result <- runQcStudbook(pedGood, minParentAge = 2.0)

  expect_true(is.list(result))
  expect_true("cleaned" %in% names(result))
  expect_true("qcResult" %in% names(result))
  expect_false(result$qcResult$hasErrors)
  expect_true(is.data.frame(result$cleaned))
  expect_true(nrow(result$cleaned) > 0)
})

test_that("runQcStudbook detects female sire/male dam errors", {
  data("pedFemaleSireMaleDam", package = "nprcgenekeepr")

  result <- runQcStudbook(pedFemaleSireMaleDam, minParentAge = 2.0)

  expect_true(result$qcResult$hasErrors)
  expect_true(nrow(result$qcResult$errors) > 0)
})

test_that("runQcStudbook detects duplicate IDs", {
  data("pedDuplicateIds", package = "nprcgenekeepr")

  result <- runQcStudbook(pedDuplicateIds, minParentAge = 2.0)

  expect_true(result$qcResult$hasErrors)
  expect_true(any(grepl("duplicate", result$qcResult$errors$Error, ignore.case = TRUE)))
})

test_that("runQcStudbook detects invalid dates", {
  data("pedInvalidDates", package = "nprcgenekeepr")

  result <- runQcStudbook(pedInvalidDates, minParentAge = 2.0)

  expect_true(result$qcResult$hasErrors)
  expect_true(any(grepl("date|invalid", result$qcResult$errors$Error, ignore.case = TRUE)))
})

test_that("runQcStudbook detects same animal as sire and dam", {
  data("pedSameMaleIsSireAndDam", package = "nprcgenekeepr")

  result <- runQcStudbook(pedSameMaleIsSireAndDam, minParentAge = 2.0)

  expect_true(result$qcResult$hasErrors)
})

test_that("runQcStudbook respects minParentAge parameter", {
  # Create pedigree with young parent
  ped <- data.frame(
    id = c("P1", "P2", "O1"),
    sire = c(NA, NA, "P1"),
    dam = c(NA, NA, "P2"),
    sex = c("M", "F", "M"),
    birth = as.Date(c("2020-01-01", "2020-01-01", "2021-06-01")),
    stringsAsFactors = FALSE
  )

  # With minParentAge = 2, parent at 1.5 years should be flagged
  result <- runQcStudbook(ped, minParentAge = 2.0)
  expect_true(result$qcResult$hasErrors)

  # With minParentAge = 1, should pass

  result2 <- runQcStudbook(ped, minParentAge = 1.0)
  expect_false(result2$qcResult$hasErrors)
})

test_that("runQcStudbook reports column name changes", {
  # Create pedigree with non-standard column names
  ped <- data.frame(
    EGO_ID = c("A", "B", "C"),
    SIRE_ID = c(NA, NA, "A"),
    DAM_ID = c(NA, NA, "B"),
    SEX = c("M", "F", "F"),
    BIRTH_DATE = as.Date(c("2010-01-01", "2010-01-01", "2015-01-01")),
    stringsAsFactors = FALSE
  )

  result <- runQcStudbook(ped, minParentAge = 2.0, reportChanges = TRUE)

  expect_true(result$qcResult$hasChangedCols)
})

# ============================================================================
# Module Server Integration Tests
# ============================================================================

test_that("modInputServer calls qcStudbook when processing data", {
  skip_if_not_installed("shiny")

  # Create a temporary CSV file with valid pedigree data
  temp_file <- tempfile(fileext = ".csv")
  data("pedGood", package = "nprcgenekeepr")
  write.csv(pedGood, temp_file, row.names = FALSE)

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      # Simulate file upload
      session$setInputs(
        fileContent = "pedFile",
        fileType = "fileTypeExcel",
        minParentAge = "2.0"
      )

      # Mock the file input
      session$setInputs(
        pedigreeFileOne = list(
          name = basename(temp_file),
          datapath = temp_file
        )
      )

      # Trigger data processing
      session$setInputs(getData = 1)

      # Get results
      result <- session$getReturned()

      # The cleaned studbook should have been processed by qcStudbook
      cleaned <- result$cleanedStudbook()
      expect_true(is.data.frame(cleaned))

      # qcStudbook adds 'gen' column
      expect_true("gen" %in% names(cleaned))
    }
  )

  unlink(temp_file)
})

test_that("modInputServer returns errors from qcStudbook", {
  skip_if_not_installed("shiny")

  # Create a temporary CSV with bad pedigree data
  temp_file <- tempfile(fileext = ".csv")
  data("pedFemaleSireMaleDam", package = "nprcgenekeepr")
  write.csv(pedFemaleSireMaleDam, temp_file, row.names = FALSE)

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(
        fileContent = "pedFile",
        fileType = "fileTypeExcel",
        minParentAge = "2.0"
      )

      session$setInputs(
        pedigreeFileOne = list(
          name = basename(temp_file),
          datapath = temp_file
        )
      )

      session$setInputs(getData = 1)

      result <- session$getReturned()

      # Should have errors
      qcSummary <- result$qcSummary()
      expect_true(qcSummary$errors > 0)

      # isReady should be FALSE when there are errors
      expect_false(result$isReady())
    }
  )

  unlink(temp_file)
})

test_that("modInputServer isReady returns TRUE for valid pedigree", {
  skip_if_not_installed("shiny")

  temp_file <- tempfile(fileext = ".csv")
  data("pedGood", package = "nprcgenekeepr")
  write.csv(pedGood, temp_file, row.names = FALSE)

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(
        fileContent = "pedFile",
        fileType = "fileTypeExcel",
        minParentAge = "2.0"
      )

      session$setInputs(
        pedigreeFileOne = list(
          name = basename(temp_file),
          datapath = temp_file
        )
      )

      session$setInputs(getData = 1)

      result <- session$getReturned()

      # Should be ready when no errors
      expect_true(result$isReady())
    }
  )

  unlink(temp_file)
})

test_that("modInputServer qcSummary includes error and warning counts", {
  skip_if_not_installed("shiny")

  temp_file <- tempfile(fileext = ".csv")
  data("pedGood", package = "nprcgenekeepr")
  write.csv(pedGood, temp_file, row.names = FALSE)

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      session$setInputs(
        fileContent = "pedFile",
        fileType = "fileTypeExcel",
        minParentAge = "2.0"
      )

      session$setInputs(
        pedigreeFileOne = list(
          name = basename(temp_file),
          datapath = temp_file
        )
      )

      session$setInputs(getData = 1)

      result <- session$getReturned()
      qcSummary <- result$qcSummary()

      expect_true("errors" %in% names(qcSummary))
      expect_true("warnings" %in% names(qcSummary))
      expect_true("records" %in% names(qcSummary))
      expect_true(is.numeric(qcSummary$errors))
      expect_true(is.numeric(qcSummary$warnings))
      expect_true(is.numeric(qcSummary$records))
    }
  )

  unlink(temp_file)
})

# ============================================================================
# Edge Cases
# ============================================================================

test_that("processQcStudbookResult handles NULL input", {
  result <- processQcStudbookResult(NULL)

  expect_true(is.list(result))
  expect_true(result$hasErrors)
  expect_true(nrow(result$errors) > 0)
})

test_that("processQcStudbookResult handles empty suspiciousParents dataframe", {
  errorLst <- getEmptyErrorLst()
  # suspiciousParents is already an empty data.frame in getEmptyErrorLst()

  result <- processQcStudbookResult(errorLst)

  expect_false(result$hasErrors)
})

test_that("runQcStudbook handles NULL pedigree input", {
  expect_error(runQcStudbook(NULL, minParentAge = 2.0))
})

test_that("runQcStudbook handles empty pedigree", {
  ped <- data.frame(
    id = character(0),
    sire = character(0),
    dam = character(0),
    sex = character(0),
    birth = as.Date(character(0)),
    stringsAsFactors = FALSE
  )

  result <- runQcStudbook(ped, minParentAge = 2.0)

  expect_true(is.list(result))
  # Empty pedigree should not cause errors, just return empty cleaned data
  expect_equal(nrow(result$cleaned), 0)
})

test_that("runQcStudbook handles pedigree with only required columns", {
  ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    birth = as.Date(c("2010-01-01", "2010-01-01", "2015-01-01")),
    stringsAsFactors = FALSE
  )

  result <- runQcStudbook(ped, minParentAge = 2.0)

  expect_false(result$qcResult$hasErrors)
  expect_true(is.data.frame(result$cleaned))
})

# ============================================================================
# Return Value Tests - changedCols reactive
# ============================================================================

test_that("modInputServer returns changedCols information", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modInputServer,
    args = list(config = NULL),
    {
      result <- session$getReturned()

      # Should have changedCols reactive
      expect_true("changedCols" %in% names(result))
      expect_true(is.function(result$changedCols))
    }
  )
})
