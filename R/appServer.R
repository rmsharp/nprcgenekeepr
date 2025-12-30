# ============================================================================
# FILE: R/appServer.R
# Main Server Logic - Connects all modules
# ============================================================================

#' Main Application Server for mprcgenekeepr
#'
#' @param input Shiny input
#' @param output Shiny output
#' @param session Shiny session
#' @importFrom shiny reactiveValues observeEvent updateNavbarPage reactive
#'         observe req
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
    configFile <- mprcgenekeepr::getConfigFileName(sysInfo)[["configFile"]]
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
  observeEvent(input$goto_qc, {
    updateNavbarPage(session, "mainNavbar", selected = "Quality Control")
  })

  observeEvent(input$goto_pedigree, {
    updateNavbarPage(session, "mainNavbar", selected = "Pedigree Creation")
  })

  observeEvent(input$goto_pyramid, {
    updateNavbarPage(session, "mainNavbar", selected = "Age-Sex Pyramid")
  })

  # ========================================
  # Initialize Modules
  # ========================================

  # Quality Control Module
  qcResults <- modQcServer("qc", config = reactive(shared$config))

  # Update shared data when QC completes
  observe({
    req(qcResults$cleanedData())
    shared$currentStudbook <- qcResults$cleanedData()
    shared$qcResults <- qcResults$qcSummary()
  })

  # Pedigree Creation Module
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
  pyramidResults <- modPyramidServer(
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

  # Breeding Groups Module
  breedingResults <- modBreedingGroupsServer(
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
