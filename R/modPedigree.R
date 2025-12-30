# Pedigree Browser Shiny Module

#' Pedigree Browser Module - UI Function
#'
#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Creates user interface for browsing and filtering pedigree data,
#' including focal animal selection, trimming options, and export.
#'
#' @return A \code{div} object containing pedigree browser UI.
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @seealso \code{\link{modPedigreeServer}} for server logic.
#' @importFrom shiny NS div h3 h4 fluidRow column wellPanel helpText tags
#'   fileInput actionButton checkboxInput downloadButton includeHTML br
#' @importFrom DT DTOutput
#' @export
modPedigreeUI <- function(id) {

  ns <- NS(id)

  div(
    h3("Pedigree Browser"),

    fluidRow(
      # Left panel - HTML documentation
      column(
        4,
        div(
          style = paste(
            "padding: 10px; border: 1px solid lightgray;",
            "background-color: #EDEDED; border-radius: 25px;",
            "box-shadow: 0 0 5px 2px #888;"
          ),
          includeHTML(
            system.file("extdata", "ui_guidance", "pedigree_browser.html",
                        package = "nprcgenekeepr")
          )
        )
      ),

      # Middle panel - Focal animal input
      column(
        4,
        wellPanel(
          h4("Focal Animals"),
          helpText(
            paste0(
              "IDs of selected focal animals may be manually ",
              "entered here if analysis of all individuals is ",
              "not needed. IDs may be pasted from Excel or you ",
              "can browse for and select a file containing the list ",
              "of focal animals."
            ),
            style = "color: darkblue; font-weight: bold;"
          ),
          tags$textarea(
            id = ns("focalAnimalIds"),
            rows = 5,
            cols = 40,
            placeholder = "Enter animal IDs (one per line or comma-separated)"
          ),
          br(), br(),
          fileInput(
            ns("focalAnimalFile"),
            "Choose CSV file with focal animals",
            multiple = FALSE,
            accept = c("text/csv", "text/comma-separated-values,text/plain",
                       ".csv")
          ),
          actionButton(
            ns("updateFocalAnimals"),
            label = "Update Focal Animals",
            icon = icon("sync"),
            class = "btn-primary btn-block"
          ),
          br(),
          checkboxInput(
            ns("clearFocalAnimals"),
            label = "Clear Focal Animals",
            value = FALSE
          ),
          helpText(
            paste0(
              "The search field below will search all columns for ",
              "matches to any text or number entered."
            ),
            style = "color: darkblue; font-weight: bold;"
          )
        )
      ),

      # Right panel - Options and export
      column(
        4,
        wellPanel(
          h4("Display Options"),
          checkboxInput(
            ns("displayUnknownIds"),
            label = "Display Unknown IDs",
            value = TRUE
          ),
          helpText(
            style = "font-size: 14px; color: darkblue; font-weight: bold;",
            paste0(
              "Unknown IDs, beginning with a capital U, are created ",
              "by the application for all animals with only one parent."
            )
          ),
          br(),
          checkboxInput(
            ns("trimPedigree"),
            label = "Trim pedigree based on focal animals",
            value = FALSE
          ),
          helpText(
            style = "font-size: 14px; color: darkblue; font-weight: bold;",
            paste0(
              "Trim the pedigree to include only relatives of the focal ",
              "animals provided."
            )
          ),
          br(),
          downloadButton(
            ns("exportPedigree"),
            "Export Pedigree (CSV)",
            class = "btn-success btn-block"
          ),
          br(),
          helpText(
            "A population must be defined before proceeding to the ",
            "Genetic Value Analysis.",
            style = "color: darkblue; font-weight: bold;"
          )
        )
      )
    ),

    # Pedigree data table
    fluidRow(
      column(
        12,
        br(),
        DT::DTOutput(ns("pedigreeTable"))
      )
    )
  )
}

#' Pedigree Browser Module - Server Function
#'
#' Server logic for pedigree browser module handling focal animal
#' selection, pedigree filtering, and data export.
#'
#' @return List with \code{pedigree}, \code{focalAnimals}, and \code{nAnimals}
#'   reactives.
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param studbook reactive returning the cleaned studbook data from modInput.
#' @param config optional reactive returning configuration.
#'
#' @seealso \code{\link{modPedigreeUI}}
#' @importFrom shiny moduleServer reactive reactiveVal eventReactive observe
#'   renderUI req showNotification updateCheckboxInput
#' @importFrom DT renderDT
#' @importFrom utils read.csv write.csv
#' @export
modPedigreeServer <- function(id, studbook, config = NULL) {
  moduleServer(id, function(input, output, session) {

    # Reactive value to store focal animal IDs
    focalIds <- reactiveVal(character(0))

    # Parse focal animal IDs from text area or file
    observeEvent(input$updateFocalAnimals, {
      # Check if clearing
      if (input$clearFocalAnimals) {
        focalIds(character(0))
        showNotification("Focal animals cleared", type = "message")
        updateCheckboxInput(session, "clearFocalAnimals", value = FALSE)
        return()
      }

      ids <- character(0)

      # Get IDs from text area
      textIds <- input$focalAnimalIds
      if (!is.null(textIds) && nzchar(trimws(textIds))) {
        # Split by newlines, commas, semicolons, or tabs
        ids <- unlist(strsplit(textIds, "[,;\t\n\r]+"))
        ids <- trimws(ids)
        ids <- ids[nzchar(ids)]
      }

      # Get IDs from uploaded file
      if (!is.null(input$focalAnimalFile)) {
        tryCatch({
          fileData <- read.csv(input$focalAnimalFile$datapath,
                               stringsAsFactors = FALSE)
          # Assume first column contains IDs
          if (ncol(fileData) >= 1) {
            fileIds <- as.character(fileData[[1]])
            fileIds <- trimws(fileIds)
            fileIds <- fileIds[nzchar(fileIds)]
            ids <- unique(c(ids, fileIds))
          }
        }, error = function(e) {
          showNotification(
            paste("Error reading file:", e$message),
            type = "error"
          )
        })
      }

      focalIds(unique(ids))

      if (length(ids) > 0) {
        showNotification(
          paste("Updated focal animals:", length(ids), "IDs"),
          type = "message"
        )
      } else {
        showNotification(
          "No focal animal IDs found",
          type = "warning"
        )
      }
    })

    # Get the filtered pedigree data
    pedigreeData <- reactive({
      req(studbook())
      ped <- studbook()

      # Filter out unknown IDs if requested
      if (!input$displayUnknownIds) {
        # Unknown IDs typically start with "U"
        ped <- ped[!startsWith(ped$id, "U"), ]
      }

      # Trim to focal animals and their relatives if requested
      if (input$trimPedigree && length(focalIds()) > 0) {
        # Get focal animals and their ancestors/descendants
        # This is a placeholder - implement actual pedigree trimming logic
        # using trimPedigree() or similar function from the package
        focalMatches <- ped$id %in% focalIds()
        if (any(focalMatches)) {
          # For now, just filter to focal animals
          # TODO: Include ancestors and descendants
          ped <- ped[focalMatches, ]
        }
      }

      ped
    })

    # Render pedigree table
    output$pedigreeTable <- DT::renderDT({
      req(pedigreeData())
      pedigreeData()
    }, options = list(
      pageLength = 15,
      scrollX = TRUE,
      search = list(regex = TRUE)
    ))

    # Export handler
    output$exportPedigree <- downloadHandler(
      filename = function() {
        paste0("pedigree_", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(pedigreeData(), file, row.names = FALSE)
      }
    )

    # Return reactive values for use by other modules
    return(list(
      pedigree = reactive({ pedigreeData() }),
      focalAnimals = reactive({ focalIds() }),
      nAnimals = reactive({ nrow(pedigreeData()) }),
      isReady = reactive({
        !is.null(pedigreeData()) && nrow(pedigreeData()) > 0
      })
    ))
  })
}
