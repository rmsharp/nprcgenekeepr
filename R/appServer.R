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
#' @seealso \code{\link{shouldShowErrorTab}} for error tab logic
#' @seealso \code{\link{shouldShowChangedColsTab}} for changed columns tab logic
#'
#' @importFrom shiny reactiveValues observeEvent updateNavbarPage reactive
#'         observe req insertTab removeTab showNotification tabPanel div h3
#'         p hr icon uiOutput verbatimTextOutput
#' @export
appServer <- function(input, output, session) {

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
    updateNavbarPage(session, "mainNavbar", selected = "Input")
  })

  observeEvent(input$goto_pedigree, {
    updateNavbarPage(session, "mainNavbar", selected = "Pedigree Browser")
  })

  observeEvent(input$goto_pyramid, {
    updateNavbarPage(session, "mainNavbar", selected = "Age-Sex Pyramid")
  })

  # ========================================
  # Initialize Modules
  # ========================================

  # Input and Quality Control Module
  inputResults <- modInputServer("input", config = reactive(shared$config))

  # Update shared data when input/QC completes
  observe({
    req(inputResults$cleanedStudbook())
    shared$currentStudbook <- inputResults$cleanedStudbook()
    shared$qcResults <- inputResults$qcSummary()
  })

  # ========================================
  # Dynamic Tab Management
  # ========================================
  # Track whether dynamic tabs have been inserted
  tabState <- reactiveValues(
    errorTabInserted = FALSE,
    changedColsTabInserted = FALSE
  )

  # Observe QC results and manage dynamic tabs

  observe({
    # Wait for QC results to be available
    qcSummary <- tryCatch(inputResults$qcSummary(), error = function(e) NULL)
    if (is.null(qcSummary)) return()

    # Get error and changed columns information
    hasErrors <- qcSummary$errors > 0
    changedCols <- tryCatch(inputResults$changedCols(), error = function(e) NULL)
    hasChangedCols <- shouldShowChangedColsTab(changedCols)

    # Remove existing dynamic tabs first
    if (tabState$errorTabInserted) {
      tryCatch({
        removeTab(inputId = "mainNavbar", target = "Error List")
        tabState$errorTabInserted <- FALSE
      }, error = function(e) NULL)
    }

    if (tabState$changedColsTabInserted) {
      tryCatch({
        removeTab(inputId = "mainNavbar", target = "Changed Columns")
        tabState$changedColsTabInserted <- FALSE
      }, error = function(e) NULL)
    }

    # Insert Error List tab if there are errors
    if (hasErrors) {
      tryCatch({
        insertTab(
          inputId = "mainNavbar",
          tabPanel(
            "Error List",
            icon = icon("exclamation-triangle"),
            div(
              class = "alert alert-danger",
              h3("Quality Control Errors"),
              p("The following errors were found in your data. ",
                "Please fix these errors and re-upload."),
              hr(),
              uiOutput("input-qcErrors")
            )
          ),
          target = "Input",
          position = "before",
          select = TRUE
        )
        tabState$errorTabInserted <- TRUE
      }, error = function(e) {
        showNotification(
          paste("Could not insert Error tab:", e$message),
          type = "warning"
        )
      })
    } else if (hasChangedCols) {
      # Insert Changed Columns tab if columns were renamed (and no errors)
      tryCatch({
        insertTab(
          inputId = "mainNavbar",
          tabPanel(
            "Changed Columns",
            icon = icon("info-circle"),
            div(
              class = "alert alert-info",
              h3("Column Names Modified"),
              p("The following column names were automatically adjusted ",
                "to match expected format:"),
              hr(),
              verbatimTextOutput("input-changedColsDisplay")
            )
          ),
          target = "Input",
          position = "before",
          select = FALSE
        )
        tabState$changedColsTabInserted <- TRUE
      }, error = function(e) {
        showNotification(
          paste("Could not insert Changed Columns tab:", e$message),
          type = "warning"
        )
      })
    }
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
    kinshipMatrix = NULL
  )

  # Breeding Groups Module
  modBreedingGroupsServer(
    "breedingGroups",
    pedigree = reactive(shared$currentPedigree),
    geneticValues = reactive(shared$geneticValues)
  )

  # ========================================
  # Session Info (for debugging)
  # ========================================
  observe({
    cat("Session info:\n")
    cat("  Studbook loaded:", !is.null(shared$currentStudbook), "\n")
    cat("  Pedigree loaded:", !is.null(shared$currentPedigree), "\n")
    cat("  Genetic values calculated:", !is.null(shared$geneticValues), "\n")
  })
}
