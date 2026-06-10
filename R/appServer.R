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
#' @seealso \code{\link{appUI}} for the corresponding UI function
#' @seealso \code{\link{modInputServer}} for data input module
#' @seealso \code{\link{modPedigreeServer}} for pedigree browser module
#' @seealso \code{\link{modGeneticValueServer}} for genetic value analysis
#' @seealso \code{\link{shouldShowChangedColsTab}} for changed columns tab
#'  logic
#'
#' @importFrom shiny reactiveValues reactiveVal observeEvent updateNavbarPage
#'         updateTabsetPanel reactive observe req insertTab removeTab
#'         showNotification tabPanel div h3 p hr icon uiOutput
#'         verbatimTextOutput isolate
#' @importFrom futile.logger flog.logger flog.threshold flog.debug flog.info
#'         INFO DEBUG appender.file
#' @export
appServer <- function(input, output, session) {

  # ========================================
  # Initialize Logger
  # ========================================
  nprcgenekeeprLog <- file.path(getSiteInfo()$homeDir, "nprcgenekeepr.log")
  futile.logger::flog.logger(
    "nprcgenekeepr",
    futile.logger::INFO,
    appender = futile.logger::appender.file(nprcgenekeeprLog)
  )

  # ========================================
  # Shared Reactive Values
  # ========================================
  shared <- reactiveValues(
    config = NULL,
    currentStudbook = NULL,
    currentPedigree = NULL,
    qcResults = NULL,
    geneticValues = NULL
  )

  # ========================================
  # Load Configuration
  # ========================================
  observe({
    # Attempt to load configuration file
    sysInfo <- Sys.info()
    configFile <- nprcgenekeepr::getConfigFileName(sysInfo)[["configFile"]]
    if (!is.null(configFile) && file.exists(configFile)) {
      shared$config <- read.table(configFile,
                                  header = TRUE,
                                  sep = "=",
                                  stringsAsFactors = FALSE)
    }
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
  inputResults <- modInputServer("dataInput", config = reactive(shared$config))

  # Update shared data when input/QC completes
  # Use tryCatch to prevent errors from blocking reactive graph
  observe({
    studbook <- tryCatch(inputResults$cleanedStudbook(),
                         error = function(e) NULL)
    if (!is.null(studbook)) {
      shared$currentStudbook <- studbook
      shared$qcResults <- tryCatch(inputResults$qcSummary(),
                                   error = function(e) NULL)
    }
  })

  # ========================================
  # QC Result Notifications
  # ========================================

  # Show QC results via notifications and auto-navigate to appropriate tab
  observe({
    # Try to get qcSummary - will be NULL until data is processed
    qcSummary <- tryCatch(inputResults$qcSummary(), error = function(e) NULL)
    if (is.null(qcSummary)) return()

    hasErrors <- qcSummary$errors > 0
    hasWarnings <- qcSummary$warnings > 0

    # Use isolate to prevent this from re-triggering
    isolate({
      if (hasErrors) {
        # Show error notification and switch to Errors tab within Input module
        showNotification(
          paste0("QC found ", qcSummary$errors,
                 " error(s). Check the Errors tab."),
          type = "error",
          duration = 10
        )
        # Switch to the QC Summary tab within the Input module
        updateTabsetPanel(session, "dataInput-mainTabs", selected = "Errors")
      } else if (hasWarnings) {
        showNotification(
          paste0("QC found ", qcSummary$warnings,
                 " warning(s). Check the Warnings tab."),
          type = "warning",
          duration = 8
        )
        updateTabsetPanel(session, "dataInput-mainTabs", selected = "Warnings")
      } else if (qcSummary$records > 0) {
        showNotification(
          paste0("QC passed! ", qcSummary$records, " records processed."),
          type = "message",
          duration = 5
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

  # Observe QC results to manage Error List tab
  observe({
    # Get errorLst and file name from input module
    errorLst <- tryCatch(inputResults$errorLst(), error = function(e) NULL)
    fileName <- tryCatch(inputResults$pedigreeFileName(),
                         error = function(e) NULL)
    changedCols <- tryCatch(inputResults$changedCols(),
                            error = function(e) NULL)

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
    studbook = reactive(shared$currentStudbook),
    config = reactive(shared$config)
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
    pedigree = reactive(shared$currentPedigree)
  )

  # Update shared data when genetic values are calculated
  observe({
    req(gvResults$geneticValues())
    shared$geneticValues <- gvResults$geneticValues()
  })

  # Summary Statistics Module
  modSummaryStatsServer(
    "summaryStats",
    geneticValues = reactive(shared$geneticValues),
    pedigree = reactive(shared$currentPedigree),
    kinshipMatrix = NULL,
    founderStats = gvResults$founderStats
  )

  # Breeding Groups Module
  modBreedingGroupsServer(
    "breedingGroups",
    pedigree = reactive(shared$currentPedigree),
    geneticValues = reactive(shared$geneticValues)
  )

  # GV & BG Description Module (informational - no reactive state)
  modGvAndBgDescServer("gvAndBgDesc")
}
