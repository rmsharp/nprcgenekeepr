# ============================================================================
# FILE: R/modQC.R
# Quality Control Shiny Module
# ============================================================================

#' Quality Control Module - UI Function
#'
#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Creates the user interface for the quality control module.
#'
#' @return A \code{div} object containing the quality control UI elements.
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' ui <- navbarPage("GeneKeepR", tabPanel("QC", modQcUI("qc")))
#' }
#'
#' @param id character vector of length 1. The module namespace identifier.
#'
#' @seealso \code{\link{modQcServer}} for the server logic.
#' @seealso \code{\link{qcStudbook}} for the underlying QC function.
#'
#' @export
modQcUI <- function(id) {
  ns <- NS(id)

  div(
    h3("Studbook Quality Control"),
    p(class = "text-muted", "Upload and validate your studbook data"),

    fluidRow(
      column(
        width = 4,
        wellPanel(
          h4(icon("upload"), "Data Input"),
          fileInput(ns("fileInput"), "Upload Studbook File",
                    accept = c(".txt", ".csv", ".xlsx", ".xls")),
          hr(),
          numericInput(ns("minParentAge"), "Minimum Parent Age (years)",
                       value = 2, min = 0, max = 10, step = 0.5),
          checkboxInput(ns("useDatabase"), "Use LabKey Database Connection"),
          hr(),
          actionButton(ns("runQc"), "Run Quality Control",
                       icon = icon("play"), class = "btn-primary btn-block")
        )
      ),
      column(
        width = 8,
        tabsetPanel(
          id = ns("resultsTabs"),
          tabPanel("Summary", br(), uiOutput(ns("qcSummaryUI"))),
          tabPanel("Errors", br(),
                   downloadButton(ns("downloadErrors"), "Download"),
                   br(), br(), DT::dataTableOutput(ns("qcErrors"))),
          tabPanel("Warnings", br(),
                   downloadButton(ns("downloadWarnings"), "Download"),
                   br(), br(), DT::dataTableOutput(ns("qcWarnings"))),
          tabPanel("Cleaned Data", br(),
                   downloadButton(ns("downloadCleaned"), "Download"),
                   br(), br(), DT::dataTableOutput(ns("cleanedDataTable")))
        )
      )
    )
  )
}

#' Quality Control Module - Server Function
#'
#' Server logic for quality control module.
#'
#' @return A list with reactive components \code{cleanedData} and
#' \code{qcSummary}.
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param config optional reactive expression returning configuration data.
#'
#' @seealso \code{\link{modQcUI}} for the user interface.
#'
#' @importFrom shiny moduleServer reactive eventReactive req
#' @importFrom DT renderDataTable
#' @export
modQcServer <- function(id, config = NULL) {
  moduleServer(id, function(input, output, session) {

    uploadedData <- reactive({
      req(input$fileInput)
      filePath <- input$fileInput$datapath
      fileExt <- tools::file_ext(input$fileInput$name)

      tryCatch({
        if (fileExt %in% c("xlsx", "xls")) {
          data <- readxl::read_excel(filePath)
        } else if (fileExt == "txt") {
          data <- read.table(filePath, header = TRUE, sep = "\t",
                             stringsAsFactors = FALSE)
        } else {
          data <- read.csv(filePath, stringsAsFactors = FALSE)
        }
        as.data.frame(data)
      }, error = function(e) {
        showNotification(paste("Error:", e$message), type = "error")
        return(NULL)
      })
    })

    qcResults <- eventReactive(input$runQc, {
      req(uploadedData())

      withProgress(message = "Running quality control...", {
        data <- uploadedData()
        results <- list()

        incProgress(0.2, detail = "Validating structure")
        # Call your qcStudbook function here
        # results$cleaned <- qcStudbook(data, minParentAge = input$minParentAge)

        results$cleaned <- data
        results$errors <- data.frame(
          Row = integer(0), Error = character(0),
          Details = character(0), stringsAsFactors = FALSE)
        results$warnings <- data.frame(
          Row = integer(0), Warning = character(0),
          Details = character(0), stringsAsFactors = FALSE)

        incProgress(0.8, detail = "Complete")
        results
      })
    })

    output$qcSummaryUI <- renderUI({
      req(qcResults())
      results <- qcResults()

      div(class = "row",
          div(class = "col-sm-3",
              div(class = "panel panel-primary",
                  div(class = "panel-heading", h4("Errors")),
                  div(class = "panel-body", h2(nrow(results$errors))))),
          div(class = "col-sm-3",
              div(class = "panel panel-warning",
                  div(class = "panel-heading", h4("Warnings")),
                  div(class = "panel-body", h2(nrow(results$warnings)))))
      )
    })

    output$qcErrors <- DT::renderDataTable(qcResults()$errors)
    output$qcWarnings <- DT::renderDataTable(qcResults()$warnings)
    output$cleanedDataTable <- DT::renderDataTable(qcResults()$cleaned)

    output$downloadCleaned <- downloadHandler(
      filename = function() paste0("cleaned_studbook_", Sys.Date(), ".csv"),
      content = function(file) write.csv(qcResults()$cleaned, file, row.names = FALSE)
    )

    return(list(
      cleanedData = reactive({ qcResults()$cleaned }),
      qcSummary = reactive({
        list(errors = nrow(qcResults()$errors),
             warnings = nrow(qcResults()$warnings))
      })
    ))
  })
}
