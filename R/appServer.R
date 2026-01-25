#' Main Application Server for nprcgenekeepr
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
