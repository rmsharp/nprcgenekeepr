# Data Input and Quality Control Shiny Module

#' Data Input and Quality Control Module - UI Function
#'
#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Creates user interface for data input including file uploads for
#' pedigree and genotype data with various format options, followed by
#' quality control validation.
#'
#' @return A \code{div} object containing the data input UI.
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @seealso \code{\link{modInputServer}} for server logic.
#' @seealso \code{\link{modPedigreeUI}} for pedigree browsing after QC.
#' @importFrom shiny NS div h3 h4 tags fluidRow column sidebarLayout sidebarPanel
#'   mainPanel helpText radioButtons conditionalPanel fileInput textInput
#'   actionButton checkboxInput icon includeHTML br hr tabsetPanel tabPanel
#'   uiOutput downloadButton
#' @importFrom DT DTOutput
#' @export
modInputUI <- function(id) {
  ns <- NS(id)

  div(
    # Custom CSS for tables in the HTML documentation
    tags$style(
      type = "text/css",
      "table {border: 1px solid black; width: 100%; padding: 15px;}",
      "tr, td, th {border: 1px solid black; padding: 5px;}",
      "th {font-weight: bold; background-color: #7CFC00;}",
      "hr {border-width:2px;border-color:#A9A9A9;}"
    ),

    h3("Data Input and Quality Control"),

    sidebarLayout(
      sidebarPanel(
        style = paste(
          "padding: 10px; border: 1px solid lightgray;",
          "background-color: #EDEDED; border-radius: 25px;",
          "box-shadow: 0 0 5px 2px #888;"
        ),

        helpText("Select how you are submitting data."),

        # File type selection
        radioButtons(
          ns("fileType"),
          label = "File Type",
          choices = list(Excel = "fileTypeExcel", Text = "fileTypeText"),
          selected = "fileTypeExcel"
        ),

        # File content selection
        radioButtons(
          ns("fileContent"),
          label = "File Content",
          choices = list(
            "Pedigree(s) file only; genotypes not provided" = "pedFile",
            "Pedigree(s) and genotypes in one file" = "commonPedGenoFile",
            "Pedigree(s) and genotypes in separate files" = "separatePedGenoFile",
            "Focal animals only; pedigree built from database" = "focalAnimals"
          ),
          selected = "pedFile"
        ),

        # Separator selection for text files
        conditionalPanel(
          condition = "input.fileType == 'fileTypeText'",
          ns = ns,
          radioButtons(
            ns("separator"),
            label = "Separator",
            choices = list(Comma = ",", Semicolon = ";", Tab = "\t"),
            selected = ","
          )
        ),

        # File inputs based on content type
        conditionalPanel(
          condition = "input.fileContent == 'pedFile'",
          ns = ns,
          fileInput(ns("pedigreeFileOne"), label = "Select Pedigree File",
                    accept = c(".csv", ".txt", ".xlsx", ".xls"))
        ),

        conditionalPanel(
          condition = "input.fileContent == 'commonPedGenoFile'",
          ns = ns,
          fileInput(ns("pedigreeFileTwo"), label = "Select Pedigree-Genotype File",
                    accept = c(".csv", ".txt", ".xlsx", ".xls"))
        ),

        conditionalPanel(
          condition = "input.fileContent == 'separatePedGenoFile'",
          ns = ns,
          fileInput(ns("pedigreeFileThree"), label = "Select Pedigree File",
                    accept = c(".csv", ".txt", ".xlsx", ".xls")),
          fileInput(ns("genotypeFile"), label = "Select Genotype File",
                    accept = c(".csv", ".txt", ".xlsx", ".xls"))
        ),

        conditionalPanel(
          condition = "input.fileContent == 'focalAnimals'",
          ns = ns,
          fileInput(ns("breederFile"), label = "Select Focal Animals File",
                    accept = c(".csv", ".txt", ".xlsx", ".xls"))
        ),

        # Minimum parent age
        textInput(ns("minParentAge"),
                  label = "Minimum Parent Age (years)",
                  value = "2.0"),
        helpText(
          style = "font-size: 11px; color: #666;",
          paste(
            "Parents must be at least as old as the minimum parent age",
            "at the birthdate of an offspring."
          )
        ),

        actionButton(ns("getData"), "Read and Check Pedigree",
                     icon = icon("upload"), class = "btn-primary btn-block"),

        checkboxInput(ns("debugger"), label = "Debug on", value = FALSE)
      ),

      # Main panel with tabs for documentation and QC results
      mainPanel(
        tabsetPanel(
          id = ns("mainTabs"),

          # Input format documentation tab
          tabPanel(
            "Input Format",
            icon = icon("info-circle"),
            br(),
            div(
              style = paste(
                "padding: 15px; border: 1px solid lightgray;",
                "background-color: #EDEDED; border-radius: 15px;",
                "box-shadow: 0 0 5px 2px #888;"
              ),
              includeHTML(
                system.file("extdata", "ui_guidance", "input_format.html",
                            package = "nprcgenekeepr")
              )
            )
          ),

          # QC Summary tab
          tabPanel(
            "QC Summary",
            icon = icon("check-circle"),
            br(),
            uiOutput(ns("qcSummaryUI"))
          ),

          # Errors tab
          tabPanel(
            "Errors",
            icon = icon("exclamation-triangle"),
            br(),
            downloadButton(ns("downloadErrors"), "Download Errors"),
            br(), br(),
            DT::DTOutput(ns("qcErrors"))
          ),

          # Warnings tab
          tabPanel(
            "Warnings",
            icon = icon("exclamation-circle"),
            br(),
            downloadButton(ns("downloadWarnings"), "Download Warnings"),
            br(), br(),
            DT::DTOutput(ns("qcWarnings"))
          ),

          # Cleaned data preview tab
          tabPanel(
            "Cleaned Data",
            icon = icon("table"),
            br(),
            downloadButton(ns("downloadCleaned"), "Download Cleaned Data"),
            br(), br(),
            DT::DTOutput(ns("cleanedDataTable"))
          )
        )
      )
    )
  )
}

#' Data Input and Quality Control Module - Server Function
#'
#' Server logic for data input module handling file uploads, parsing
#' of pedigree and genotype data files, and quality control validation.
#'
#' @return A list with reactive components:
#' \itemize{
#'   \item \code{cleanedStudbook} - The QC-cleaned studbook data
#'   \item \code{genotypeData} - Genotype data if provided
#'   \item \code{qcSummary} - Summary of QC results (error/warning counts)
#'   \item \code{minParentAge} - The minimum parent age value
#'   \item \code{isReady} - Logical indicating if data is ready for next step
#' }
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param config optional reactive expression returning configuration data.
#'
#' @seealso \code{\link{modInputUI}} for the user interface.
#' @seealso \code{\link{modPedigreeServer}} for using the cleaned data.
#' @importFrom shiny moduleServer reactive eventReactive req showNotification
#'   renderUI withProgress incProgress
#' @importFrom DT renderDT
#' @export
modInputServer <- function(id, config = NULL) {

  moduleServer(id, function(input, output, session) {

    # Determine which file input to use based on content type
    activeFile <- reactive({
      switch(input$fileContent,
             "pedFile" = input$pedigreeFileOne,
             "commonPedGenoFile" = input$pedigreeFileTwo,
             "separatePedGenoFile" = input$pedigreeFileThree,
             "focalAnimals" = input$breederFile,
             NULL)
    })

    # Helper function to read file based on type
    readDataFile <- function(file, fileType, separator) {
      if (is.null(file)) return(NULL)

      tryCatch({
        fileExt <- tools::file_ext(file$name)

        if (fileExt %in% c("xlsx", "xls")) {
          data <- readxl::read_excel(file$datapath)
        } else if (fileType == "fileTypeText") {
          data <- read.table(file$datapath, header = TRUE, sep = separator,
                             stringsAsFactors = FALSE)
        } else {
          data <- read.csv(file$datapath, stringsAsFactors = FALSE)
        }

        as.data.frame(data)
      }, error = function(e) {
        showNotification(
          paste("Error reading file:", e$message),
          type = "error",
          duration = 10
        )
        NULL
      })
    }

    # Process data and run QC when button is clicked
    qcResults <- eventReactive(input$getData, {
      req(activeFile())

      withProgress(message = "Processing data...", {

        # Read primary file
        incProgress(0.2, detail = "Reading file")
        rawData <- readDataFile(activeFile(), input$fileType, input$separator)

        if (is.null(rawData)) {
          return(list(
            cleaned = NULL,
            errors = data.frame(Row = 1, Error = "File read error",
                                Details = "Could not read the uploaded file",
                                stringsAsFactors = FALSE),
            warnings = data.frame(Row = integer(0), Warning = character(0),
                                  Details = character(0), stringsAsFactors = FALSE)
          ))
        }

        # Read genotype file if separate files were selected
        genotypeData <- NULL
        if (input$fileContent == "separatePedGenoFile" && !is.null(input$genotypeFile)) {
          incProgress(0.1, detail = "Reading genotype file")
          genotypeData <- readDataFile(input$genotypeFile, input$fileType, input$separator)
        }

        incProgress(0.3, detail = "Running quality control")

        # Run QC on the data using qcStudbook
        minAge <- as.numeric(input$minParentAge)
        if (is.na(minAge)) minAge <- 2.0

        qcResult <- runQcStudbook(
          rawData,
          minParentAge = minAge,
          reportChanges = TRUE
        )

        # Build results structure
        results <- list()
        results$cleaned <- qcResult$cleaned
        results$genotype <- genotypeData
        results$errors <- qcResult$qcResult$errors
        results$warnings <- qcResult$qcResult$warnings
        results$changedCols <- qcResult$qcResult$changedCols
        results$hasChangedCols <- qcResult$qcResult$hasChangedCols

        incProgress(0.4, detail = "Complete")
        results
      })
    })

    # QC Summary UI
    output$qcSummaryUI <- renderUI({
      req(qcResults())
      results <- qcResults()

      nErrors <- nrow(results$errors)
      nWarnings <- nrow(results$warnings)
      nRecords <- if (!is.null(results$cleaned)) nrow(results$cleaned) else 0

      div(
        fluidRow(
          column(4,
                 div(class = "panel panel-primary",
                     div(class = "panel-heading", h4("Records Processed")),
                     div(class = "panel-body", h2(nRecords)))),
          column(4,
                 div(class = if (nErrors > 0) "panel panel-danger" else "panel panel-success",
                     div(class = "panel-heading", h4("Errors")),
                     div(class = "panel-body", h2(nErrors)))),
          column(4,
                 div(class = if (nWarnings > 0) "panel panel-warning" else "panel panel-success",
                     div(class = "panel-heading", h4("Warnings")),
                     div(class = "panel-body", h2(nWarnings))))
        ),
        if (nErrors == 0 && nRecords > 0) {
          div(
            class = "alert alert-success",
            icon("check"),
            " Data passed quality control. You may proceed to the Pedigree Browser."
          )
        } else if (nErrors > 0) {
          div(
            class = "alert alert-danger",
            icon("exclamation-triangle"),
            " Please review and fix errors before proceeding."
          )
        }
      )
    })

    # Render QC results tables
    output$qcErrors <- DT::renderDT({
      req(qcResults())
      qcResults()$errors
    }, options = list(pageLength = 10))

    output$qcWarnings <- DT::renderDT({
      req(qcResults())
      qcResults()$warnings
    }, options = list(pageLength = 10))

    output$cleanedDataTable <- DT::renderDT({
      req(qcResults())
      qcResults()$cleaned
    }, options = list(pageLength = 10, scrollX = TRUE))

    # Download handlers
    output$downloadErrors <- downloadHandler(
      filename = function() paste0("qc_errors_", Sys.Date(), ".csv"),
      content = function(file) {
        write.csv(qcResults()$errors, file, row.names = FALSE)
      }
    )

    output$downloadWarnings <- downloadHandler(
      filename = function() paste0("qc_warnings_", Sys.Date(), ".csv"),
      content = function(file) {
        write.csv(qcResults()$warnings, file, row.names = FALSE)
      }
    )

    output$downloadCleaned <- downloadHandler(
      filename = function() paste0("cleaned_studbook_", Sys.Date(), ".csv"),
      content = function(file) {
        write.csv(qcResults()$cleaned, file, row.names = FALSE)
      }
    )

    # Return reactive values for use by other modules
    return(list(
      cleanedStudbook = reactive({
        req(qcResults())
        qcResults()$cleaned
      }),
      genotypeData = reactive({
        req(qcResults())
        qcResults()$genotype
      }),
      qcSummary = reactive({
        req(qcResults())
        nRecords <- if (!is.null(qcResults()$cleaned)) nrow(qcResults()$cleaned) else 0L
        list(
          errors = nrow(qcResults()$errors),
          warnings = nrow(qcResults()$warnings),
          records = nRecords
        )
      }),
      minParentAge = reactive({
        as.numeric(input$minParentAge)
      }),
      isReady = reactive({
        req(qcResults())
        nrow(qcResults()$errors) == 0 && !is.null(qcResults()$cleaned)
      }),
      debugMode = reactive({ input$debugger }),
      changedCols = reactive({
        req(qcResults())
        qcResults()$changedCols
      })
    ))
  })
}
