# Tests for appServer()'s debug-log file appender (R/appServer.R).
#
# CRAN Policy forbids a package from writing outside the R session's
# temporary directory during examples, tests, vignettes, or loading, without
# explicit interactive user confirmation. appServer() used to register a
# futile.logger file appender pointed at file.path(getSiteInfo()$homeDir,
# "nprcgenekeepr.log") unconditionally at boot -- every appServer() run,
# including this project's own testServer(appServer, ...) suite, wrote to
# the real $HOME. CRAN's win-builder/Debian check hit the identical path via
# test_appServer_server.R and archived the nprcgenekeepr 2.0.0 submission
# over it (owner-forwarded CRAN email, 2026-07-09).
#
# The fix restores the behavior already documented in
# vignettes/manual_components/_software_development.Rmd ("When the Debug on
# checkbox is checked... the application writes to a file named
# nprcgenekeepr.log in the user's home directory"): the file appender is
# only registered after modInputServer's already-tested debugMode reactive
# (wired to the Input tab's "Debug on" checkbox) is TRUE, never at boot.
#
# Every test that exercises file-appender registration redirects HOME to an
# isolated withr::local_tempdir() (the project's established pattern -- see
# test_loadSiteConfig.R, test_defaultSiteParams.R) so it never touches the
# real developer home directory, regardless of whether the fix is in place
# yet. (The "resets to console" test below is the one exception: it never
# reaches file-appender registration, so it has no HOME-dependent path to
# isolate.)
#
# Tests that assert on file-vs-console destination force an explicit
# flog.info(name = "nprcgenekeepr") probe after boot rather than relying on
# an incidental application call site. This is
# deliberate: futile.logger's appender.file() only opens/creates its target
# file lazily, on the first write that clears the registered threshold --
# registration alone never creates the file (confirmed directly: calling
# flog.logger(..., appender = appender.file(path)) with no subsequent write
# leaves the path nonexistent). Every in-repo call site under appServer()'s
# reactive graph is flog.debug(), which is *below* the buggy code's
# registered INFO threshold and so is silently filtered -- routing a probe
# through an incidental flog.debug() call site would not reliably exercise
# either the buggy or the fixed destination. The explicit flog.info() probe
# instead tests the thing that actually matters: which destination (file
# under HOME, or console) is currently registered for the "nprcgenekeepr"
# logger name, independent of which call sites exist or their severity.

# getSiteInfo() warns when no site-configuration file is present, which is
# the normal state in the test environment; appServer() may call it. Muffle
# only that specific, expected warning (same helper as test_appServer_server.R).
muffleConfig <- function(expr) {
  withCallingHandlers(
    expr,
    warning = function(w) {
      if (grepl("configuration file is missing", conditionMessage(w),
                fixed = TRUE)) {
        invokeRestart("muffleWarning")
      }
    }
  )
}

test_that("appServer does not create a log file at boot when debugMode is FALSE", {
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  logPath <- file.path(tmp, "nprcgenekeepr.log")

  # Real modInputServer mounts here (debugMode defaults to FALSE -- see
  # test_modInput.R "modInputServer debugMode starts as FALSE by default"),
  # matching the exact boot path CRAN's check exercised.
  muffleConfig(shiny::testServer(appServer, {
    session$flushReact()
    futile.logger::flog.info("logging probe", name = "nprcgenekeepr")
  }))

  expect_false(file.exists(logPath))
})

test_that("appServer writes the log file only after debugMode flips to TRUE", {
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  logPath <- file.path(tmp, "nprcgenekeepr.log")

  debugFlag <- shiny::reactiveVal(FALSE)

  testthat::with_mocked_bindings(
    modInputServer = function(id, ...) {
      list(
        cleanedStudbook = shiny::reactive(NULL),
        qcSummary = shiny::reactive(NULL),
        errorLst = shiny::reactive(NULL),
        pedigreeFileName = shiny::reactive(NULL),
        changedCols = shiny::reactive(NULL),
        genotypeData = shiny::reactive(NULL),
        minSireAge = shiny::reactive(NULL),
        minDamAge = shiny::reactive(NULL),
        isReady = shiny::reactive(FALSE),
        debugMode = shiny::reactive(debugFlag())
      )
    },
    .package = "nprcgenekeepr",
    {
      muffleConfig(shiny::testServer(appServer, {
        session$flushReact()
        futile.logger::flog.info("probe before opt-in", name = "nprcgenekeepr")
        expect_false(file.exists(logPath))

        debugFlag(TRUE)
        session$flushReact()
        futile.logger::flog.info("probe after opt-in", name = "nprcgenekeepr")
        expect_true(file.exists(logPath))
      }))
    }
  )
})

test_that(paste("appServer's debug-log observer fails closed (console",
                 "logging, no warning) when the site config file is",
                 "malformed"), {
  # BACKLOG: "4 lower-severity unguarded getSiteInfo() call sites" (2) --
  # getSiteInfo()$homeDir at appServer.R:124 is unguarded; a present-but-
  # malformed config file (missing the required 'center' key) makes
  # getParamDef() stop(). Per PROJECT_LEARNINGS.md Learning 347(d), an
  # observer's uncaught error surfaces to shiny::testServer() as a
  # base::warning() (Shiny's own reactive-error reporting), not a thrown R
  # error -- so the RED assertion is expect_no_warning(), not
  # expect_no_error()/expect_error(). A flog.info() probe after opt-in
  # confirms the fix fails CLOSED (stays on console logging) rather than
  # silently registering a file appender it can't safely resolve the path
  # for, mirroring the "writes the log file only after debugMode flips to
  # TRUE" test's probe idiom above. futile.logger's "nprcgenekeepr" logger is
  # a process-global registry (see this file's header comment); reset it to
  # console explicitly so this test's outcome does not depend on what a
  # PRIOR test in the same R process left registered (the preceding test
  # above may leave a file appender pointing at its own since-deleted
  # withr::local_tempdir()).
  futile.logger::flog.logger(
    "nprcgenekeepr",
    futile.logger::INFO,
    appender = futile.logger::appender.console()
  )
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  cfg_name <- basename(getConfigFileName(Sys.info())[["configFile"]])
  writeLines(c("baseUrl = \"http://example\"", "schemaName = \"study\""),
             file.path(tmp, cfg_name))
  logPath <- file.path(tmp, "nprcgenekeepr.log")

  debugFlag <- shiny::reactiveVal(FALSE)

  testthat::with_mocked_bindings(
    modInputServer = function(id, ...) {
      list(
        cleanedStudbook = shiny::reactive(NULL),
        qcSummary = shiny::reactive(NULL),
        errorLst = shiny::reactive(NULL),
        pedigreeFileName = shiny::reactive(NULL),
        changedCols = shiny::reactive(NULL),
        genotypeData = shiny::reactive(NULL),
        minSireAge = shiny::reactive(NULL),
        minDamAge = shiny::reactive(NULL),
        isReady = shiny::reactive(FALSE),
        debugMode = shiny::reactive(debugFlag())
      )
    },
    .package = "nprcgenekeepr",
    {
      expect_no_warning(
        muffleConfig(shiny::testServer(appServer, {
          session$flushReact()
          debugFlag(TRUE)
          session$flushReact()
          futile.logger::flog.info(
            "probe after opt-in with malformed config",
            name = "nprcgenekeepr"
          )
        }))
      )
    }
  )
  expect_false(file.exists(logPath))
})

test_that("appServer resets to console logging even when debugMode's first read is NULL", {
  # input$debugger (and so debugMode()) is NULL until the client posts its
  # first value. futile.logger's "nprcgenekeepr" logger is a process-global
  # registry, so a NULL-first-read that silently no-ops (observeEvent's
  # default ignoreNULL = TRUE) would let a fresh session inherit whatever a
  # PRIOR session in the same R process last left registered -- simulated
  # here as a file appender pointing at a path that no longer exists, the
  # exact shape of the regression this test guards against.
  tmp <- withr::local_tempdir()
  stalePath <- file.path(tmp, "gone", "nprcgenekeepr.log")
  futile.logger::flog.logger(
    "nprcgenekeepr",
    futile.logger::DEBUG,
    appender = futile.logger::appender.file(stalePath)
  )

  testthat::with_mocked_bindings(
    modInputServer = function(id, ...) {
      list(
        cleanedStudbook = shiny::reactive(NULL),
        qcSummary = shiny::reactive(NULL),
        errorLst = shiny::reactive(NULL),
        pedigreeFileName = shiny::reactive(NULL),
        changedCols = shiny::reactive(NULL),
        genotypeData = shiny::reactive(NULL),
        minSireAge = shiny::reactive(NULL),
        minDamAge = shiny::reactive(NULL),
        isReady = shiny::reactive(FALSE),
        debugMode = shiny::reactive(NULL)
      )
    },
    .package = "nprcgenekeepr",
    {
      muffleConfig(shiny::testServer(appServer, {
        session$flushReact()
        expect_no_warning(
          futile.logger::flog.info("probe", name = "nprcgenekeepr")
        )
      }))
    }
  )
})
