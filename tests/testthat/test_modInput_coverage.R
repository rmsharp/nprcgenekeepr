## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#
# Residual-branch coverage backfill for R/modInput.R (issue #111 campaign).
#
# Complements test_modInput.R / test_modInput_qcStudbook.R /
# test_modInput_incomplete_final_line.R by driving the branches those suites
# never reach: the readDataFile helper's NULL / Excel / read-error paths, the
# getData guard and read-failure / degenerate-input branches, the raw-QC
# error and warning handlers, and the output renderers plus download handlers
# (via direct storedResults() injection). Headless shiny::testServer only (no
# browser); these characterize existing correct behavior -- no production code
# is changed.

testthat::skip_on_cran()

# --- shared fixtures --------------------------------------------------------

# A valid pedigree written to a temp CSV, uploaded through the getData path.
write_pedgood_csv <- function() {
  path <- tempfile(fileext = ".csv")
  utils::write.csv(nprcgenekeepr::pedGood, path, row.names = FALSE)
  path
}

# Minimal storedResults() payload for exercising the output renderers and
# download handlers directly, independent of a QC run.
make_stored <- function(n_errors = 0L, n_warnings = 0L, cleaned = NULL,
                        changedCols = NULL) {
  errors <- data.frame(
    Row = rep(NA_integer_, n_errors),
    Error = rep("Some Error", n_errors),
    Details = rep("detail", n_errors),
    stringsAsFactors = FALSE
  )
  warnings <- data.frame(
    Row = rep(NA_integer_, n_warnings),
    Warning = rep("Some Warning", n_warnings),
    Details = rep("detail", n_warnings),
    stringsAsFactors = FALSE
  )
  list(cleaned = cleaned, errors = errors, warnings = warnings,
       changedCols = changedCols, hasChangedCols = !is.null(changedCols),
       genotype = NULL)
}

# The renderers log via futile.logger::flog.debug, which lazily skips building
# its message at or below the default (INFO) threshold. Raising the logger to
# DEBUG -- exactly what the app's "Debug on" checkbox does -- forces those
# messages to be built, the only path that reaches the errors-present /
# errors-absent branches of the qcErrors debug string. Output is routed to a
# temp file so the console stays quiet; the console appender and INFO threshold
# are restored when the calling test finishes.
local_debug_logging <- function(env = parent.frame()) {
  logfile <- tempfile(fileext = ".log")
  futile.logger::flog.appender(futile.logger::appender.file(logfile),
                               name = "nprcgenekeepr")
  futile.logger::flog.threshold(futile.logger::DEBUG, name = "nprcgenekeepr")
  withr::defer({
    futile.logger::flog.threshold(futile.logger::INFO, name = "nprcgenekeepr")
    futile.logger::flog.appender(futile.logger::appender.console(),
                                 name = "nprcgenekeepr")
    unlink(logfile)
  }, envir = env)
}

# --- readDataFile helper: NULL / Excel / read-error -------------------------

test_that("readDataFile handles NULL, Excel, and read errors", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("readxl")
  xlsx <- system.file("extdata", "2022-05-02_Deidentified_Pedigree.xlsx",
                      package = "nprcgenekeepr")
  skip_if(xlsx == "")

  shiny::testServer(modInputServer, args = list(config = NULL), {
    # A NULL file short-circuits to NULL before any read is attempted.
    expect_null(readDataFile(NULL, "fileTypeExcel", ","))

    # An .xlsx name routes to the readxl::read_excel branch.
    excel <- readDataFile(list(name = "ped.xlsx", datapath = xlsx),
                          "fileTypeExcel", ",")
    expect_true(is.data.frame(excel))
    expect_gt(nrow(excel), 0L)

    # An unreadable path is caught by the tryCatch and degrades to NULL. The
    # read.csv attempt emits an expected "cannot open file" warning; suppress
    # only that one.
    bad <- suppressWarnings(readDataFile(
      list(name = "missing.csv", datapath = tempfile(fileext = ".csv")),
      "fileTypeExcel", ","
    ))
    expect_null(bad)
  })
})

# --- activeFile switch default ----------------------------------------------

test_that("activeFile returns NULL for an unrecognized fileContent", {
  skip_if_not_installed("shiny")
  shiny::testServer(modInputServer, args = list(config = NULL), {
    session$setInputs(fileContent = "unrecognizedContent")
    expect_null(activeFile())
  })
})

# --- getData: no file selected ----------------------------------------------

test_that("getData with no uploaded file leaves results unset", {
  skip_if_not_installed("shiny")
  shiny::testServer(modInputServer, args = list(config = NULL), {
    session$setInputs(fileContent = "pedFile")
    session$setInputs(getData = 1)
    # The "Please select a file first" guard returns before storing anything.
    expect_null(storedResults())
  })
})

# --- getData: unreadable non-focal file -------------------------------------

test_that("getData surfaces a File Read Error for an unreadable file", {
  skip_if_not_installed("shiny")
  shiny::testServer(modInputServer, args = list(config = NULL), {
    session$setInputs(fileContent = "pedFile", fileType = "fileTypeExcel",
                      minSireAge = "2.0", minDamAge = "2.0")
    session$setInputs(pedigreeFileOne = list(
      name = "missing.csv", datapath = tempfile(fileext = ".csv")
    ))
    # read.csv warns before the tryCatch converts the failure into a NULL
    # rawData; suppress only that expected file-open warning.
    suppressWarnings(session$setInputs(getData = 1))
    res <- storedResults()
    expect_false(is.null(res))
    expect_true(any(grepl("File Read Error", res$errors$Error)))
    expect_true(any(grepl("Could not read", res$errors$Details)))
    expect_null(storedErrorLst())
  })
})

# --- getData: blank sire/dam floors fall back to the table default ----------

test_that("getData maps blank sire/dam floors to the table default", {
  skip_if_not_installed("shiny")
  path <- write_pedgood_csv()
  on.exit(unlink(path), add = TRUE)
  shiny::testServer(modInputServer, args = list(config = NULL), {
    session$setInputs(fileContent = "pedFile", fileType = "fileTypeExcel",
                      minSireAge = "", minDamAge = "")
    session$setInputs(pedigreeFileOne = list(name = basename(path),
                                             datapath = path))
    session$setInputs(getData = 1)
    # Blank fields parse to NULL, so the species+sex table default applies
    # (2 years for this species-less fixture) and QC still produces a cleaned
    # studbook.
    res <- storedResults()
    expect_false(is.null(res$cleaned))
  })
})

# --- getData: QC run failure ------------------------------------------------

test_that("getData surfaces a QC Processing Error when the QC run fails", {
  skip_if_not_installed("shiny")
  path <- write_pedgood_csv()
  on.exit(unlink(path), add = TRUE)
  # Both the raw errorLst pass and runQcStudbook fail: the raw pass falls back
  # to the empty error list, and the observer converts the runQcStudbook
  # failure into a "QC Processing Error" row.
  testthat::local_mocked_bindings(
    qcStudbook = function(...) stop("qc boom"),
    runQcStudbook = function(...) stop("run boom"),
    .package = "nprcgenekeepr"
  )
  shiny::testServer(modInputServer, args = list(config = NULL), {
    session$setInputs(fileContent = "pedFile", fileType = "fileTypeExcel",
                      minSireAge = "2.0", minDamAge = "2.0")
    session$setInputs(pedigreeFileOne = list(name = basename(path),
                                             datapath = path))
    session$setInputs(getData = 1)
    res <- storedResults()
    expect_true(any(grepl("QC Processing Error", res$errors$Error)))
    # The raw errorLst error handler stored the empty error list.
    expect_true("femaleSires" %in% names(storedErrorLst()))
  })
})

# --- getData: qcStudbook warning during raw QC ------------------------------

test_that("getData tolerates a qcStudbook warning during raw QC", {
  skip_if_not_installed("shiny")
  path <- write_pedgood_csv()
  on.exit(unlink(path), add = TRUE)
  # A warning from qcStudbook routes the raw errorLst through its warning
  # handler to the empty error list; runQcStudbook (real) absorbs the same
  # warning internally, so nothing escapes the observer.
  testthat::local_mocked_bindings(
    qcStudbook = function(...) {
      warning("qc warning")
      getEmptyErrorLst()
    },
    .package = "nprcgenekeepr"
  )
  shiny::testServer(modInputServer, args = list(config = NULL), {
    session$setInputs(fileContent = "pedFile", fileType = "fileTypeExcel",
                      minSireAge = "2.0", minDamAge = "2.0")
    session$setInputs(pedigreeFileOne = list(name = basename(path),
                                             datapath = path))
    session$setInputs(getData = 1)
    expect_true("femaleSires" %in% names(storedErrorLst()))
  })
})

# --- output renderers: qcSummaryUI warning panel, zero-error qcErrors,
#     and the changedCols reactive -------------------------------------------

test_that("qcSummaryUI renders the warning panel and changedCols is exposed", {
  skip_if_not_installed("shiny")
  local_debug_logging()
  shiny::testServer(modInputServer, args = list(config = NULL), {
    storedResults(make_stored(
      n_errors = 0L, n_warnings = 1L,
      cleaned = data.frame(id = "A", stringsAsFactors = FALSE),
      changedCols = list(caseChange = "ID")
    ))
    session$flushReact()

    # Warnings present selects the panel-warning class; no errors with records
    # present selects the success alert.
    ui <- as.character(output$qcSummaryUI)
    expect_true(any(grepl("panel-warning", ui)))
    expect_true(any(grepl("alert-success", ui)))

    # qcErrors renders its zero-error branch without error.
    expect_no_error(output$qcErrors)

    # The changedCols reactive returns the stored changes.
    expect_equal(session$getReturned()$changedCols(),
                 list(caseChange = "ID"))
  })
})

# --- output renderers and downloads with populated results ------------------

test_that("populated results render qcErrors and drive all three downloads", {
  skip_if_not_installed("shiny")
  local_debug_logging()
  shiny::testServer(modInputServer, args = list(config = NULL), {
    storedResults(make_stored(
      n_errors = 1L, n_warnings = 1L,
      cleaned = data.frame(id = c("A", "B"), stringsAsFactors = FALSE)
    ))
    session$flushReact()

    # qcErrors renderDT takes the errors-present branch.
    expect_no_error(output$qcErrors)

    # Each downloadHandler writes a CSV of the corresponding results.
    errs <- utils::read.csv(output$downloadErrors)
    warns <- utils::read.csv(output$downloadWarnings)
    cleaned <- utils::read.csv(output$downloadCleaned)
    expect_true(is.data.frame(errs))
    expect_true(is.data.frame(warns))
    expect_equal(nrow(cleaned), 2L)
  })
})
