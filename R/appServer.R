## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Main Application Server for nprcgenekeepr
#'
#' Server function for the main GeneKeepR Shiny application. Initializes
#' all modules and manages shared reactive state between them.
#'
#' The server handles:
#' \itemize{
#'   \item Configuration loading from site-specific config files
#'   \item Navigation button handlers for the home page
#'   \item Dynamic tab management for QC errors and changed columns
#'   \item Module initialization and data flow between modules
#' }
#'
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#'
#' @return No return value, called for side effects. As a 'Shiny' server
#'   function, \code{appServer()} is invoked by the 'Shiny' runtime to wire up
#'   the application's reactive outputs, observers, and module servers for a
#'   running GeneKeepR session.
#'
#' @seealso \code{\link{appUI}} for the corresponding UI function
#' @seealso \code{\link{modInputServer}} for data input module
#' @seealso \code{\link{modPedigreeServer}} for pedigree browser module
#' @seealso \code{\link{modGeneticValueServer}} for genetic value analysis
#' @seealso \code{\link{shouldShowChangedColsTab}} for changed columns tab
#'  logic
#' @seealso \code{\link{loadSiteConfig}} for site configuration loading
#'
#' @importFrom shiny reactiveValues reactiveVal observeEvent updateNavbarPage
#' @importFrom shiny updateTabsetPanel reactive observe req insertTab removeTab
#' @importFrom shiny showNotification tabPanel div h3 p hr icon uiOutput
#' @importFrom shiny verbatimTextOutput isolate
#' @importFrom futile.logger flog.logger flog.threshold flog.debug flog.info
#' @importFrom futile.logger flog.warn
#' @importFrom futile.logger INFO DEBUG appender.file
#' @export
appServer <- function(input, output, session) {

  # ========================================
  # Shared Reactive Values
  # ========================================
  shared <- reactiveValues(
    config = NULL,
    speciesOverrides = NULL,
    currentStudbook = NULL,
    currentPedigree = NULL,
    geneticValues = NULL,
    breedingGroups = NULL
  )

  # ========================================
  # Load Configuration
  # ========================================
  observe({
    # Load the site configuration via the tolerant getSiteInfo() parser.
    # loadSiteConfig() returns NULL (and logs a warning) rather than erroring
    # on a missing or malformed config file, so a documented-format config can
    # never crash the app on boot (issue #50).
    shared$config <- loadSiteConfig()
    # Load the optional user-configurable species reproductive-parameter
    # overrides (issue #73 Part 2). loadSpeciesOverrides() soft-fails to the
    # bundled values, so a missing/malformed override CSV never crashes boot.
    shared$speciesOverrides <- loadSpeciesOverrides()
  })

  # ========================================
  # Navigation Button Handlers
  # ========================================
  observeEvent(input$goto_input, {
    futile.logger::flog.debug("goto_input button clicked",
                              name = "nprcgenekeepr")
    updateNavbarPage(session, "mainNavbar", selected = "Input")
  })

  observeEvent(input$goto_pedigree, {
    updateNavbarPage(session, "mainNavbar", selected = "Pedigree Browser")
  })

  observeEvent(input$goto_pyramid, {
    updateNavbarPage(session, "mainNavbar", selected = "Age-Sex Pyramid")
  })

  observeEvent(input$goto_genetic, {
    updateNavbarPage(session, "mainNavbar", selected = "Genetic Value Analysis")
  })

  observeEvent(input$goto_summary, {
    updateNavbarPage(session, "mainNavbar", selected = "Summary Statistics")
  })

  observeEvent(input$goto_breeding, {
    updateNavbarPage(session, "mainNavbar", selected = "Breeding Groups")
  })

  # ========================================
  # Initialize Modules
  # ========================================

  # Input and Quality Control Module
  inputResults <- modInputServer("dataInput")

  # ========================================
  # Debug Logging (opt-in via the Input tab's "Debug on" checkbox)
  # ========================================
  # CRAN Policy forbids writing outside the R session's temporary directory
  # during examples/tests/vignettes/loading without explicit interactive
  # user confirmation, so the file appender is never registered at boot --
  # only after a user explicitly opts in during a live session by checking
  # "Debug on" (issue: CRAN archived nprcgenekeepr 2.0.0 over the prior
  # unconditional write to ~/nprcgenekeepr.log at every appServer() boot).
  # ignoreNULL = FALSE: input$debugger (and so debugMode()) is NULL until
  # the client posts its first value, and futile.logger's "nprcgenekeepr"
  # logger is a process-global registry -- without also resetting on a NULL
  # first read, a fresh session could silently inherit a stale file appender
  # left registered by an earlier session in the same R process (e.g. a
  # multi-session Shiny Server worker, or this package's own test suite).
  observeEvent(inputResults$debugMode(), {
    if (isTRUE(inputResults$debugMode())) {
      nprcgenekeeprLog <- file.path(getSiteInfo()$homeDir, "nprcgenekeepr.log")
      futile.logger::flog.logger(
        "nprcgenekeepr",
        futile.logger::DEBUG,
        appender = futile.logger::appender.file(nprcgenekeeprLog)
      )
    } else {
      futile.logger::flog.logger(
        "nprcgenekeepr",
        futile.logger::INFO,
        appender = futile.logger::appender.console()
      )
    }
  }, ignoreInit = FALSE, ignoreNULL = FALSE)

  # Update shared data when input/QC completes. req() halts silently until
  # cleanedStudbook() is ready (its own internal req(qcResults()) guard);
  # any other error is a genuine contract violation and now surfaces instead
  # of being swallowed.
  observe({
    shared$currentStudbook <- req(inputResults$cleanedStudbook())
  })

  # ========================================
  # QC Result Notifications
  # ========================================

  # Show QC results via notifications and auto-navigate to appropriate tab.
  # req() halts silently until qcSummary() is ready; any other error now
  # surfaces instead of being swallowed.
  observe({
    qcSummary <- req(inputResults$qcSummary())

    hasErrors <- qcSummary$errors > 0L
    hasWarnings <- qcSummary$warnings > 0L

    # Use isolate to prevent this from re-triggering
    isolate({
      if (hasErrors) {
        # Show error notification and switch to Errors tab within Input module
        showNotification(
          paste0("QC found ", qcSummary$errors,
                 " error(s). Check the Errors tab."),
          type = "error",
          duration = 10L
        )
        # Switch to the QC Summary tab within the Input module
        updateTabsetPanel(session, "dataInput-mainTabs", selected = "Errors")
      } else if (hasWarnings) {
        showNotification(
          paste0("QC found ", qcSummary$warnings,
                 " warning(s). Check the Warnings tab."),
          type = "warning",
          duration = 8L
        )
        updateTabsetPanel(session, "dataInput-mainTabs", selected = "Warnings")
      } else if (qcSummary$records > 0L) {
        showNotification(
          paste0("QC passed! ", qcSummary$records, " records processed."),
          type = "message",
          duration = 5L
        )
        updateTabsetPanel(session, "dataInput-mainTabs",
                          selected = "QC Summary")
      }
    })
  })

  # ========================================
  # Dynamic Tab Management
  # ========================================

  # Track whether dynamic tabs are currently shown
  errorTabShown <- reactiveVal(FALSE)
  changedColsTabShown <- reactiveVal(FALSE)

  # Observe QC results to manage Error List tab. errorLst/fileName never
  # raise (storedErrorLst()/storedFileName() have no internal req()), so they
  # are read directly. changedCols has its own internal req(qcResults()) and
  # must stay independent of errorLst/fileName here -- a not-yet-ready
  # changedCols must not block the Error List tab logic below, which only
  # needs errorLst/fileName -- so only Shiny's own not-ready signal
  # (shiny.silent.error) is caught; any other error still surfaces.
  observe({
    # Get errorLst and file name from input module
    errorLst <- inputResults$errorLst()
    fileName <- inputResults$pedigreeFileName()
    changedCols <- tryCatch(inputResults$changedCols(),
                            shiny.silent.error = function(e) NULL)

    # Check if we should show the Error List tab
    showErrors <- !is.null(errorLst) && !is.null(fileName) &&
      checkErrorLst(errorLst)

    isolate({
      if (showErrors && !errorTabShown()) {
        # Insert Error List tab after Input
        insertTab(
          inputId = "mainNavbar",
          tab = getErrorTab(errorLst, fileName),
          target = "Input",
          position = "after",
          session = session
        )
        errorTabShown(TRUE)
        futile.logger::flog.debug(
          "Inserted Error List tab",
          name = "nprcgenekeepr"
        )
      } else if (!showErrors && errorTabShown()) {
        # Remove Error List tab
        removeTab(inputId = "mainNavbar", target = "Error List",
                  session = session)
        errorTabShown(FALSE)
        futile.logger::flog.debug(
          "Removed Error List tab",
          name = "nprcgenekeepr"
        )
      }
    })

    # Check if we should show the Changed Columns tab
    showChangedCols <- !is.null(errorLst) && !is.null(fileName) &&
      shouldShowChangedColsTab(changedCols)

    isolate({
      if (showChangedCols && !changedColsTabShown()) {
        # Insert Changed Columns tab after Input (or after Error List if shown)
        targetTab <- if (errorTabShown()) "Error List" else "Input"
        insertTab(
          inputId = "mainNavbar",
          tab = getChangedColsTab(errorLst, fileName),
          target = targetTab,
          position = "after",
          session = session
        )
        changedColsTabShown(TRUE)
        futile.logger::flog.debug(
          "Inserted Changed Columns tab",
          name = "nprcgenekeepr"
        )
      } else if (!showChangedCols && changedColsTabShown()) {
        # Remove Changed Columns tab
        removeTab(inputId = "mainNavbar", target = "Changed Columns",
                  session = session)
        changedColsTabShown(FALSE)
        futile.logger::flog.debug(
          "Removed Changed Columns tab",
          name = "nprcgenekeepr"
        )
      }
    })
  })

  # Pedigree Browser Module
  pedigreeResults <- modPedigreeServer(
    "pedigree",
    studbook = reactive(shared$currentStudbook)
  )

  # Update shared data when pedigree is created
  observe({
    req(pedigreeResults$pedigree())
    shared$currentPedigree <- pedigreeResults$pedigree()
  })

  # Age-Sex Pyramid Module
  modPyramidServer(
    "pyramid",
    pedigreeData = reactive(shared$currentPedigree)
  )

  # Genetic Value Analysis Module
  gvResults <- modGeneticValueServer(
    "geneticValue",
    pedigree = reactive(shared$currentPedigree),
    speciesOverrides = reactive(shared$speciesOverrides)
  )

  # Update shared data when genetic values are calculated
  observe({
    req(gvResults$geneticValues())
    shared$geneticValues <- gvResults$geneticValues()
  })

  # Shared full-pedigree kinship reactive (issue #122 Phase 2) -- computed
  # once from shared$currentPedigree with the GV-tab overrides applied, and
  # threaded into both Summary Stats and Breeding Groups instead of each
  # recomputing it independently. This is the FULL pedigree, never
  # gvResults$kinshipMatrix (which is population-filtered to focal animals --
  # see the module-contract plan's Dragon 1). Matches each consumer's own
  # prior recompute formula exactly, so the shared value is identical to what
  # either module computed on its own.
  sharedKinshipMatrix <- reactive({
    req(shared$currentPedigree)
    ped <- shared$currentPedigree
    if (!"gen" %in% names(ped)) {
      ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
    }
    kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
    overrides <- if (is.null(gvResults$kinshipOverrides)) {
      NULL
    } else {
      gvResults$kinshipOverrides()
    }
    applyKinshipOverridesToMatrix(kmat, overrides)
  })

  # Summary Statistics Module -- thread the GV-tab kinship overrides (issue #13
  # Slice 3) so the relationship table and kinship export reflect them even when
  # the GV analysis was not run first. kinshipMatrix now points at the shared
  # reactive above (issue #122 Phase 2); its own recompute fallback stays
  # (Dragon 3: summary stats must render before GV is ever run).
  modSummaryStatsServer( # nolint: object_usage_linter
    "summaryStats",
    geneticValues = reactive(shared$geneticValues),
    pedigree = reactive(shared$currentPedigree),
    kinshipMatrix = sharedKinshipMatrix,
    founderStats = gvResults$founderStats,
    kinshipOverrides = gvResults$kinshipOverrides
  )

  # ORIP Reporting Module (ONPRC-only, #49) -- mount only for an actual ONPRC
  # site configuration, matching the conditional ORIP tab in appUI(). The
  # getSiteInfo() call is wrapped in tryCatch (mirroring loadSiteConfig()'s
  # pattern, issue #50) so a present-but-malformed config file can never crash
  # THIS call site -- the same crash class, recurring here independently of
  # loadSiteConfig()'s own protection. NOTE: appUI()'s own
  # getSiteInfo(expectConfigFile = FALSE) default-argument call (the UI-side
  # twin of this exact gate) is a SEPARATE, still-unguarded instance of the
  # same bug -- a malformed config file can still crash app boot via that
  # call, discovered live-testing this fix; tracked as its own BACKLOG.md
  # item, deliberately out of scope here.
  oripSiteInfo <- tryCatch(
    getSiteInfo(expectConfigFile = FALSE),
    error = function(e) {
      futile.logger::flog.warn(
        "Failed to load site configuration for ORIP gating: %s",
        conditionMessage(e),
        name = "nprcgenekeepr"
      )
      NULL
    }
  )
  if (!is.null(oripSiteInfo) &&
      shouldShowOripTab(oripSiteInfo$center,
                        file.exists(oripSiteInfo$configFile))) {
    modORIPReportingServer(
      "oripReporting",
      pedigree = reactive(shared$currentPedigree),
      geneticValues = reactive(shared$geneticValues),
      siteConfig = reactive(oripSiteInfo)
    )
  }

  # Breeding Groups Module -- thread the GV-tab kinship overrides (issue #13
  # Slice 3) so group formation reflects them on the fallback recompute path
  # (used when the shared kinship reactive is unavailable), regardless of tab
  # order. kinshipMatrix points at the same shared reactive as Summary Stats
  # above (issue #122 Phase 2) -- kinship is computed once, not twice.
  bgResults <- modBreedingGroupsServer(
    "breedingGroups",
    pedigree = reactive(shared$currentPedigree),
    geneticValues = reactive(shared$geneticValues),
    kinshipMatrix = sharedKinshipMatrix,
    kinshipOverrides = gvResults$kinshipOverrides
  )

  # Capture the formed breeding groups into shared state (issue #112 Slice S4)
  # so the Genetic Diversity dashboard can read them. Stays NULL until the user
  # forms groups, which drives the dashboard's graceful degradation.
  observe({
    shared$breedingGroups <- bgResults$groups()
  })

  # Genetic Diversity Module (issue #112 Slice S4) -- assembles the formed
  # groups, the qc'd pedigree, the genetic value report, and the full kinship
  # matrix into the red/yellow/green heat map.
  modGeneticDiversityServer(
    "geneticDiversity",
    groups = reactive(shared$breedingGroups),
    pedigree = reactive(shared$currentPedigree),
    geneticValues = reactive(shared$geneticValues),
    kinshipMatrix = gvResults$kinshipMatrix
  )

  # Potential Parents Module -- follow the Input-tab sire/dam age floors
  # (issue #119 Slice 4) so candidate screening honors the same minimums as QC;
  # blank fields resolve to NULL -> the species+sex breeding-age table default.
  # Also pass the user-configurable species gestation override (loaded at boot
  # into shared$speciesOverrides; issue #73 Part 2 Slice 2). NULL fields (no
  # config, or no override) leave the prefill on the bundled speciesGestation
  # table and the built-in 210-day fallback.
  modPotentialParentsServer(
    "potentialParents",
    pedigree = reactive(shared$currentPedigree),
    minSireAge = inputResults$minSireAge,
    minDamAge = inputResults$minDamAge,
    gestationTable = shared$speciesOverrides$gestationTable,
    gestationDefault = shared$speciesOverrides$gestationDefault
  )

  # GV & BG Description Module (informational - no reactive state)
  modGvAndBgDescServer("gvAndBgDesc")
}
