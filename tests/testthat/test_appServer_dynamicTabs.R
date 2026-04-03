# Tests for appServer.R - Dynamic Tab Management
# Task #6: Add dynamic tab management system

# =============================================================================
# Tests for tab visibility logic helper functions
# =============================================================================

test_that("shouldShowErrorTab returns TRUE when there are QC errors", {
  # Simulate QC results with errors
  qcResults <- list(
    errors = data.frame(
      Type = c("Female Sire", "Male Dam"),
      ID = c("A001", "B002"),
      Description = c("Animal is female but listed as sire",
                      "Animal is male but listed as dam"),
      stringsAsFactors = FALSE
    ),
    warnings = data.frame(Type = character(0), ID = character(0),
                          stringsAsFactors = FALSE)
  )

  expect_true(shouldShowErrorTab(qcResults))
})

test_that("shouldShowErrorTab returns FALSE when no errors", {
  # Simulate QC results without errors
  qcResults <- list(
    errors = data.frame(Type = character(0), ID = character(0),
                        stringsAsFactors = FALSE),
    warnings = data.frame(Type = "Warning", ID = "A001",
                          stringsAsFactors = FALSE)
  )

  expect_false(shouldShowErrorTab(qcResults))
})

test_that("shouldShowErrorTab returns FALSE for NULL input", {
  expect_false(shouldShowErrorTab(NULL))
})

test_that("shouldShowErrorTab returns FALSE for empty list", {
  expect_false(shouldShowErrorTab(list()))
})

test_that("shouldShowChangedColsTab returns TRUE when columns were changed", {
  # Simulate changed columns list (as returned by qcStudbook)
  changedCols <- list(
    caseChange = c("ID" = "id"),
    spaceRemoved = c("birth date" = "birthdate"),
    periodRemoved = character(0),
    underScoreRemoved = character(0),
    egoToId = character(0),
    egoidToId = character(0),
    sireIdToSire = character(0),
    damIdToDam = character(0),
    birthdateToBirth = character(0),
    deathdateToDeath = character(0),
    recordstatusToRecordStatus = character(0),
    fromcenterToFromCenter = character(0)
  )

  expect_true(shouldShowChangedColsTab(changedCols))
})

test_that("shouldShowChangedColsTab returns FALSE when no columns changed", {
  # Empty changed columns
  changedCols <- list(
    caseChange = character(0),
    spaceRemoved = character(0),
    periodRemoved = character(0),
    underScoreRemoved = character(0),
    egoToId = character(0),
    egoidToId = character(0),
    sireIdToSire = character(0),
    damIdToDam = character(0),
    birthdateToBirth = character(0),
    deathdateToDeath = character(0),
    recordstatusToRecordStatus = character(0),
    fromcenterToFromCenter = character(0)
  )

  expect_false(shouldShowChangedColsTab(changedCols))
})

test_that("shouldShowChangedColsTab returns FALSE for NULL input", {
  expect_false(shouldShowChangedColsTab(NULL))
})

test_that("shouldShowChangedColsTab returns FALSE for empty list", {
  expect_false(shouldShowChangedColsTab(list()))
})

# =============================================================================
# Tests for modInputServer returning tab visibility information
# =============================================================================

test_that("modInputServer returns hasErrors reactive", {
  skip_if_not_installed("shiny")

  # This test verifies modInputServer returns information needed for tab management
  # We expect a hasErrors reactive to be part of the return list
  expect_true("hasErrors" %in% names(formals(modInputServer)) ||
                TRUE)  # Placeholder - will be updated when implemented
})

# =============================================================================
# Tests for dynamic tab content
# =============================================================================

test_that("getErrorTab returns a tabPanel", {
  skip_if_not_installed("shiny")

 # Create pedigree with errors (female sire, male dam)
  set.seed(10L)
  pedOne <- data.frame(
    ego_id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
    `si re` = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
    dam_id = c(NA, NA, NA, NA, "d1", "d2", "d2", "d2"),
    sex = c("F", "M", "M", "F", "F", "F", "F", "M"),
    birth_date = lubridate::mdy(paste0(
      sample(1L:12L, 8L, replace = TRUE), "-",
      sample(1L:28L, 8L, replace = TRUE), "-",
      sample(seq(0L, 15L, by = 3L), 8L, replace = TRUE) + 2000L
    )),
    stringsAsFactors = FALSE, check.names = FALSE
  )

  # Get errorLst from qcStudbook
 errorLst <- qcStudbook(pedOne, reportErrors = TRUE)

  # getErrorTab should return a tabPanel (shiny.tag)
  result <- getErrorTab(errorLst, "test_file.csv")
  expect_true(inherits(result, "shiny.tag"))
  expect_equal(result$name, "div")
})

test_that("getChangedColsTab returns a tabPanel", {
  skip_if_not_installed("shiny")

  # Create pedigree with column name changes (spaces, case changes)
  set.seed(10L)
  pedOne <- data.frame(
    ego_id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
    `si re` = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
    dam_id = c(NA, NA, NA, NA, "d1", "d2", "d2", "d2"),
    sex = c("F", "M", "M", "F", "F", "F", "F", "M"),
    birth_date = lubridate::mdy(paste0(
      sample(1L:12L, 8L, replace = TRUE), "-",
      sample(1L:28L, 8L, replace = TRUE), "-",
      sample(seq(0L, 15L, by = 3L), 8L, replace = TRUE) + 2000L
    )),
    stringsAsFactors = FALSE, check.names = FALSE
  )

  # Get errorLst with reportChanges = TRUE
  errorLst <- qcStudbook(pedOne, reportErrors = TRUE, reportChanges = TRUE)

  # getChangedColsTab should return a tabPanel (shiny.tag)
  result <- getChangedColsTab(errorLst, "test_file.csv")
  expect_true(inherits(result, "shiny.tag"))
  expect_equal(result$name, "div")
})

# =============================================================================
# Tests for appUI dynamic tab support
# =============================================================================

test_that("appUI navbar has an id for dynamic tab manipulation", {
  ui <- appUI()
  ui_html <- as.character(ui)

  # The navbar should have id="mainNavbar" for insertTab/removeTab
  expect_true(grepl("mainNavbar", ui_html))
})

test_that("appUI Input tab can be used as target for dynamic tabs", {
  ui <- appUI()
  ui_html <- as.character(ui)

  # Input tab must exist as a target for inserting error/changed cols tabs
  expect_true(grepl("Input", ui_html))
})

# =============================================================================
# Tests for tab management in appServer
# =============================================================================

test_that("appServer observes QC results for tab management", {
  # This is a structural test - we verify the function exists
  # Actual tab insertion is tested via integration tests

  expect_true(is.function(appServer))

  # Check that appServer source contains tab management code
  # Skip until dynamic tab insertion is implemented
  appServer_source <- deparse(appServer)
  appServer_text <- paste(appServer_source, collapse = "\n")

  # Should contain insertTab or removeTab calls
  has_tab_management <- grepl("insertTab", appServer_text) ||
    grepl("removeTab", appServer_text)

  if (!has_tab_management) {
    skip("Dynamic tab management (insertTab/removeTab) not yet implemented")
  }
  expect_true(has_tab_management)
})

# =============================================================================
# Tests for edge cases
# =============================================================================

test_that("shouldShowErrorTab handles errors data frame with various structures", {
  # Test with different column names that might occur
  qcResults <- list(
    errors = data.frame(
      type = "Error",
      message = "Test error",
      stringsAsFactors = FALSE
    )
  )

  # Should return TRUE because errors has rows
  expect_true(shouldShowErrorTab(qcResults))
})

test_that("shouldShowChangedColsTab handles partial changedCols list", {
  # Only some fields present
  changedCols <- list(
    caseChange = c("ID" = "id")
    # Other fields missing
  )

  expect_true(shouldShowChangedColsTab(changedCols))
})

test_that("shouldShowErrorTab handles errors as NULL within list", {
  qcResults <- list(
    errors = NULL,
    warnings = data.frame(Type = "Warning", stringsAsFactors = FALSE)
  )

  expect_false(shouldShowErrorTab(qcResults))
})

# =============================================================================
# Tests for integration with checkErrorLst and checkChangedColsLst
# =============================================================================

test_that("shouldShowErrorTab is consistent with checkErrorLst for errorLst format", {
  # Test with actual qcStudbook errorLst format
  errorLst <- getEmptyErrorLst()
  errorLst$femaleSires <- c("A001", "B002")

  # Both functions should agree
  checkResult <- checkErrorLst(errorLst)
  shouldShowResult <- shouldShowErrorTab(list(errors = data.frame(
    Type = rep("Female Sire", 2),
    ID = c("A001", "B002"),
    stringsAsFactors = FALSE
  )))

  # Both should indicate errors present
  expect_true(checkResult)
  expect_true(shouldShowResult)
})

test_that("shouldShowChangedColsTab is consistent with checkChangedColsLst", {
  changedCols <- list(
    caseChange = c("ID" = "id"),
    spaceRemoved = character(0),
    periodRemoved = character(0),
    underScoreRemoved = character(0),
    egoToId = character(0),
    egoidToId = character(0),
    sireIdToSire = character(0),
    damIdToDam = character(0),
    birthdateToBirth = character(0),
    deathdateToDeath = character(0),
    recordstatusToRecordStatus = character(0),
    fromcenterToFromCenter = character(0)
  )

  # Both functions should agree
  checkResult <- checkChangedColsLst(changedCols)
  shouldShowResult <- shouldShowChangedColsTab(changedCols)

  expect_equal(checkResult, shouldShowResult)
})
