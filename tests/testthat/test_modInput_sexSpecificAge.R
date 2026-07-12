## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Issue #119 Slice 4 -- Shiny UI migration. The single "Minimum Parent Age"
## field is replaced by two optional fields, "Minimum Sire Age" and "Minimum
## Dam Age"; a blank field means "use the species+sex breeding-age table
## default" (parsed to NULL and passed to the sex-specific callees). These
## tests drive the two-field UX, the parsing helper, the exposed reactives, and
## the threading of the parsed floors into runQcStudbook() (XARCH-6, S368:
## modInput.R no longer calls qcStudbook() directly -- runQcStudbook() is the
## sole QC callee, and its own errorLst is reused for dynamic tab display).

# --- parseOptionalAge(): blank/invalid -> NULL, number -> numeric -----------

test_that("parseOptionalAge maps blank, whitespace, NA, and invalid to NULL", {
  expect_null(parseOptionalAge(NULL))
  expect_null(parseOptionalAge(""))
  expect_null(parseOptionalAge("   "))
  expect_null(parseOptionalAge("abc"))
  expect_null(parseOptionalAge(NA))
  expect_null(parseOptionalAge(NA_character_))
  expect_null(parseOptionalAge(character(0L)))
})

test_that("parseOptionalAge parses a valid number, trimming whitespace", {
  expect_equal(parseOptionalAge("4"), 4)
  expect_equal(parseOptionalAge("2.5"), 2.5)
  expect_equal(parseOptionalAge("  3.0  "), 3.0)
  expect_equal(parseOptionalAge("0"), 0)
  expect_equal(parseOptionalAge(2.5), 2.5)
})

# --- UI: two optional Sire/Dam fields replace the single field -------------

test_that("modInputUI renders separate Sire and Dam age fields", {
  ui <- modInputUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("minSireAge", ui_html))
  expect_true(grepl("Minimum Sire Age", ui_html))
  expect_true(grepl("minDamAge", ui_html))
  expect_true(grepl("Minimum Dam Age", ui_html))
  # The single combined field and its label are retired.
  expect_false(grepl("minParentAge", ui_html))
  expect_false(grepl("Minimum Parent Age", ui_html))
})

# --- return list: two reactives replace the single minParentAge reactive ---

test_that("modInputServer exposes minSireAge and minDamAge reactives", {
  skip_if_not_installed("shiny")
  shiny::testServer(modInputServer, args = list(config = NULL), {
    result <- session$getReturned()
    expect_true("minSireAge" %in% names(result))
    expect_true("minDamAge" %in% names(result))
    expect_true(is.function(result$minSireAge))
    expect_true(is.function(result$minDamAge))
    # The retired single reactive is gone.
    expect_false("minParentAge" %in% names(result))
  })
})

# --- blank fields -> NULL (table default) ----------------------------------

test_that("modInputServer returns NULL floors when both fields are blank", {
  skip_if_not_installed("shiny")
  shiny::testServer(modInputServer, args = list(config = NULL), {
    session$setInputs(minSireAge = "", minDamAge = "")
    result <- session$getReturned()
    expect_null(result$minSireAge())
    expect_null(result$minDamAge())
  })
})

# --- typed numbers win for that sex; the other stays NULL ------------------

test_that("modInputServer resolves a typed sire floor, blank dam stays NULL", {
  skip_if_not_installed("shiny")
  shiny::testServer(modInputServer, args = list(config = NULL), {
    session$setInputs(minSireAge = "4", minDamAge = "")
    result <- session$getReturned()
    expect_equal(result$minSireAge(), 4)
    expect_null(result$minDamAge())
  })
})

test_that("modInputServer resolves both typed floors independently", {
  skip_if_not_installed("shiny")
  shiny::testServer(modInputServer, args = list(config = NULL), {
    session$setInputs(minSireAge = "3.5", minDamAge = "2.5")
    result <- session$getReturned()
    expect_equal(result$minSireAge(), 3.5)
    expect_equal(result$minDamAge(), 2.5)
  })
})

# --- invalid / whitespace input degrades to NULL, no coercion warning ------

test_that("modInputServer maps invalid or whitespace floor input to NULL", {
  skip_if_not_installed("shiny")
  shiny::testServer(modInputServer, args = list(config = NULL), {
    expect_no_warning({
      session$setInputs(minSireAge = "invalid", minDamAge = "  ")
      result <- session$getReturned()
      expect_null(result$minSireAge())
      expect_null(result$minDamAge())
    })
  })
})

# --- getData threads the parsed floors into the QC callees -----------------

writeAgeFixtureCsv <- function() {
  path <- tempfile(fileext = ".csv")
  data("pedGood", package = "nprcgenekeepr", envir = environment())
  utils::write.csv(pedGood, path, row.names = FALSE)
  path
}

test_that("getData threads parsed sire/dam floors into the QC callees", {
  skip_if_not_installed("shiny")
  path <- writeAgeFixtureCsv()
  on.exit(unlink(path), add = TRUE)

  captured <- new.env()
  testthat::local_mocked_bindings(
    runQcStudbook = function(sb, minSireAge = NULL, minDamAge = NULL, ...) {
      captured$runSire <- minSireAge
      captured$runDam <- minDamAge
      list(
        cleaned = sb,
        qcResult = list(
          errors = data.frame(), warnings = data.frame(),
          changedCols = NULL, hasChangedCols = FALSE
        ),
        errorLst = getEmptyErrorLst()
      )
    },
    .package = "nprcgenekeepr"
  )

  shiny::testServer(modInputServer, args = list(config = NULL), {
    session$setInputs(fileContent = "pedFile", fileType = "fileTypeExcel",
                      minSireAge = "4", minDamAge = "2.5")
    session$setInputs(pedigreeFileOne = list(name = basename(path),
                                             datapath = path))
    session$setInputs(getData = 1)
    expect_equal(captured$runSire, 4)
    expect_equal(captured$runDam, 2.5)
  })
})

test_that("getData passes NULL floors to the QC callees when fields are blank", {
  skip_if_not_installed("shiny")
  path <- writeAgeFixtureCsv()
  on.exit(unlink(path), add = TRUE)

  captured <- new.env()
  testthat::local_mocked_bindings(
    runQcStudbook = function(sb, minSireAge = NULL, minDamAge = NULL, ...) {
      captured$runSire <- minSireAge
      captured$runDam <- minDamAge
      list(
        cleaned = sb,
        qcResult = list(
          errors = data.frame(), warnings = data.frame(),
          changedCols = NULL, hasChangedCols = FALSE
        ),
        errorLst = getEmptyErrorLst()
      )
    },
    .package = "nprcgenekeepr"
  )

  shiny::testServer(modInputServer, args = list(config = NULL), {
    session$setInputs(fileContent = "pedFile", fileType = "fileTypeExcel",
                      minSireAge = "", minDamAge = "")
    session$setInputs(pedigreeFileOne = list(name = basename(path),
                                             datapath = path))
    session$setInputs(getData = 1)
    expect_null(captured$runSire)
    expect_null(captured$runDam)
  })
})
