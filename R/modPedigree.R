# ============================================================================
# FILE: R/modPedigree.R
# Pedigree Creation Shiny Module
# ============================================================================

#' Pedigree Creation Module - UI Function
#'
#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Creates user interface for pedigree creation from focal animal lists.
#'
#' @return A \code{div} object containing pedigree creation UI.
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @seealso \code{\link{modPedigreeServer}} for server logic.
#' @importFrom shiny NS div h3 fluidRow column wellPanel
#'   radioButtons conditionalPanel fileInput numericInput actionButton
#'   tabsetPanel tabPanel uiOutput
#' @importFrom DT DTOutput
#' @export
modPedigreeUI <- function(id) {
  ns <- NS(id)

  div(
    h3("Pedigree Creation"),
    fluidRow(
      column(4,
             wellPanel(
               radioButtons(ns("inputSource"), "Data Source:",
                            choices = c("Upload focal animal list" = "file",
                                        "Use LabKey database" = "labkey",
                                        "Use cleaned studbook" = "studbook")),
               conditionalPanel(
                 condition = sprintf("input['%s'] == 'file'", ns("inputSource")),
                 ns = ns,
                 fileInput(ns("focalAnimalsFile"), "Upload CSV")),
               numericInput(ns("maxGenerations"), "Max generations",
                            value = 5, min = 1, max = 20),
               actionButton(ns("createPedigree"), "Create Pedigree",
                            icon = icon("sitemap"), class = "btn-primary btn-block")
             )
      ),
      column(8,
             tabsetPanel(
               tabPanel("Summary", uiOutput(ns("pedigreeSummary"))),
               tabPanel("Table", DT::DTOutput(ns("pedigreeTable")))
             )
      )
    )
  )
}

#' Pedigree Creation Module - Server Function
#'
#' @return List with \code{pedigree} and \code{nAnimals} reactives.
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param studbook optional reactive returning studbook data.
#' @param config optional reactive returning configuration.
#'
#' @seealso \code{\link{modPedigreeUI}}
#' @importFrom shiny moduleServer reactive eventReactive
#'  renderUI div h4 h2
#' @importFrom DT renderDT
#' @export
modPedigreeServer <- function(id, studbook = NULL, config = NULL) {
  moduleServer(id, function(input, output, session) {

    pedigreeData <- eventReactive(input$createPedigree, {
      if (input$inputSource == "studbook") {
        req(studbook())
        return(studbook())
      }

      # Placeholder pedigree
      data.frame(
        id = paste0("ID", 1:10),
        sire = c(NA, NA, "ID1", "ID1", NA, "ID3", "ID3", NA, NA, "ID5"),
        dam = c(NA, NA, "ID2", "ID2", NA, "ID4", "ID4", NA, NA, "ID6"),
        sex = sample(c("M", "F"), 10, replace = TRUE),
        stringsAsFactors = FALSE
      )
    })

    output$pedigreeSummary <- renderUI({
      req(pedigreeData())
      div(class = "panel panel-primary",
          div(class = "panel-heading", h4("Total Animals")),
          div(class = "panel-body", h2(nrow(pedigreeData()))))
    })

    output$pedigreeTable <- DT::renderDT(pedigreeData())

    return(list(
      pedigree = reactive({ pedigreeData() }),
      nAnimals = reactive({ nrow(pedigreeData()) })
    ))
  })
}
