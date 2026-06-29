# Pedigree Browser Shiny Module

#' Pedigree Browser Module - UI Function
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
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
#' @importFrom shiny fileInput actionButton checkboxInput downloadButton
#' @importFrom shiny includeHTML br uiOutput
#' @importFrom DT DTOutput
#' @export
modPedigreeUI <- function(id) {

  ns <- NS(id)

  div(
    id = ns("moduleContainer"),
    `data-ready` = "false",
    `data-module` = "pedigree",

    h3("Pedigree Browser"),

    fluidRow(
      # Left panel - HTML documentation
      column(
        4L,
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
        4L,
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
            rows = 5L,
            cols = 40L,
            placeholder = "Enter animal IDs (one per line or comma-separated)"
          ),
          br(), br(),
          # Rendered server-side so "Clear Focal Animals" can reset the widget
          # (and its displayed file name) without a client-side dependency.
          uiOutput(ns("focalAnimalFileUI")),
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
        4L,
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
              "Unknown IDs, by default beginning with a capital U (the ",
              "format is configurable via setAutoIdFormat()), are created ",
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
              "Trim the pedigree to include only the ancestors and ",
              "descendants of the focal animals provided."
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
        12L,
        br(),
        DT::DTOutput(ns("pedigreeTable"))
      )
    )
  )
}

#' Pedigree Browser Module - Server Function
#'
#' Server logic for pedigree browser module handling focal animal
#' selection, pedigree processing, filtering, and data export.
#'
#' This module processes the studbook by:
#' \itemize{
#'   \item Adding a \code{population} column via \code{setPopulation()}
#'   \item Adding a \code{pedNum} column via \code{findPedigreeNumber()}
#'   \item Ensuring a \code{gen} column exists via \code{findGeneration()}
#'   \item Optionally trimming to the ancestors and descendants of focal
#'     animals via \code{trimPedigree()} and \code{getDescendantPedigree()}
#' }
#'
#' @return A list of reactive values:
#' \itemize{
#'   \item \code{pedigree} - Filtered pedigree for display (respects
#'     trim/unknown settings)
#'   \item \code{processedPedigree} - Full pedigree with population, pedNum,
#'     gen columns
#'   \item \code{focalAnimals} - Character vector of focal animal IDs
#'   \item \code{nAnimals} - Count of animals in filtered pedigree
#'   \item \code{populationCount} - Count of animals marked as population
#'   \item \code{isReady} - Logical indicating if pedigree data is ready
#' }
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param studbook reactive returning the cleaned studbook data from modInput.
#' @param config optional reactive returning configuration.
#'
#' @seealso \code{\link{modPedigreeUI}} for the UI component
#' @seealso \code{\link{setPopulation}} for population marking
#' @seealso \code{\link{trimPedigree}} for pedigree trimming
#' @seealso \code{\link{findPedigreeNumber}} for pedigree numbering
#' @seealso \code{\link{findGeneration}} for generation calculation
#'
#' @importFrom shiny moduleServer reactive reactiveVal eventReactive observe
#' @importFrom shiny renderUI req showNotification updateCheckboxInput
#' @importFrom shiny fileInput updateTextAreaInput
#' @importFrom DT renderDT
#' @importFrom utils read.csv write.csv
#' @export
modPedigreeServer <- function(id, studbook, config = NULL) {
  moduleServer(id, function(input, output, session) {

    # Reactive value to store focal animal IDs
    focalIds <- reactiveVal(character(0L))

    # Bumping this key re-renders a fresh file input, which clears the file
    # name shown in the browser after a "Clear Focal Animals" action.
    fileInputKey <- reactiveVal(0L)
    # Remember the file path and text that were last cleared, so a subsequent
    # "Update" does not silently re-read content the user already cleared.
    clearedFilePath <- reactiveVal(NULL)
    clearedText <- reactiveVal(NULL)

    # Render the focal animal file input dynamically so it can be reset.
    output$focalAnimalFileUI <- renderUI({
      fileInputKey()
      fileInput(
        session$ns("focalAnimalFile"),
        "Choose CSV file with focal animals",
        multiple = FALSE,
        accept = c("text/csv", # nolint: nonportable_path_linter
                   "text/comma-separated-values,text/plain", # nolint: nonportable_path_linter
                   ".csv")
      )
    })

    # Parse focal animal IDs from text area or file
    observeEvent(input$updateFocalAnimals, {
      # Check if clearing
      if (input$clearFocalAnimals) {
        focalIds(character(0L))
        # Forget the currently loaded file and text so the next update does
        # not re-read them, and reset the file widget's displayed name.
        clearedFilePath(
          if (!is.null(input$focalAnimalFile)) {
            input$focalAnimalFile$datapath
          } else {
            NULL
          }
        )
        clearedText(input$focalAnimalIds)
        updateTextAreaInput(session, "focalAnimalIds", value = "")
        fileInputKey(fileInputKey() + 1L)
        showNotification("Focal animals cleared", type = "message")
        updateCheckboxInput(session, "clearFocalAnimals", value = FALSE)
        return()
      }

      ids <- character(0L)

      # Get IDs from text area (skipping text that was just cleared)
      textIds <- input$focalAnimalIds
      if (!is.null(textIds) && nzchar(trimws(textIds)) &&
            !identical(textIds, clearedText())) {
        # Split by newlines, commas, semicolons, or tabs
        ids <- unlist(strsplit(textIds, "[,;\t\n\r]+"))
        ids <- trimws(ids)
        ids <- ids[nzchar(ids)]
      }

      # Get IDs from uploaded file (skipping a file that was just cleared;
      # a newly chosen file has a different temp path and still loads)
      if (!is.null(input$focalAnimalFile) &&
            !identical(input$focalAnimalFile$datapath, clearedFilePath())) {
        tryCatch({
          fileData <- read.csv(input$focalAnimalFile$datapath,
                               stringsAsFactors = FALSE)
          # Assume first column contains IDs
          if (ncol(fileData) >= 1L) {
            fileIds <- as.character(fileData[[1L]])
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

      if (length(ids) > 0L) {
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

    # Process the pedigree with population marking and additional columns
    processedPedigree <- reactive({
      req(studbook())
      ped <- studbook()

      # Add population column using setPopulation
      # If no focal animals, all animals are in population
      # If focal animals specified, only those are marked as population
      focal <- focalIds()
      ped <- setPopulation(ped, focal)

      # Add pedNum column to identify separate pedigrees
      ped$pedNum <- findPedigreeNumber(ped$id, ped$sire, ped$dam)

      # Ensure gen column exists
      if (!"gen" %in% names(ped)) {
        ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
      }

      ped
    })

    # Get the filtered pedigree data for display
    pedigreeData <- reactive({
      req(processedPedigree())
      ped <- processedPedigree()

      # Filter out unknown IDs if requested
      if (!input$displayUnknownIds) {
        # Auto-generated unknown IDs are detected via the shared predicate
        ped <- ped[!isGeneratedUnknownId(ped$id), ]
      }

      # Trim to focal animals, their ancestors, and their descendants if
      # requested
      if (input$trimPedigree && length(focalIds()) > 0L) {
        focal <- focalIds()
        # Get focal animals that exist in pedigree
        probands <- focal[focal %in% ped$id]
        if (length(probands) > 0L) {
          # Include both ancestors (upward closure) and descendants (downward
          # closure) of the focal animals. Strict-lineal -- collateral
          # relatives (siblings, cousins, mates) are not included.
          ancestors <- trimPedigree(probands, ped, removeUninformative = FALSE,
                                    addBackParents = FALSE)
          descendants <- getDescendantPedigree(probands, ped)
          ped <- ped[ped$id %in% union(ancestors$id, descendants$id), ]
        }
      }

      ped
    })

    # Render pedigree table
    output$pedigreeTable <- DT::renderDT({
      req(pedigreeData())
      pedigreeData()
    }, options = list(
      pageLength = 15L,
      scrollX = TRUE,
      search = list(regex = TRUE)
    ))

    # Signal data-ready when pedigree is available (for E2E testing)
    observe({
      req(pedigreeData())
      session$sendCustomMessage("setDataReady", list(
        selector = paste0("#", session$ns("moduleContainer")),
        ready = TRUE
      ))
    })

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
    list(
      pedigree = reactive({
        pedigreeData()
      }),
      processedPedigree = reactive({
        processedPedigree()
      }),
      focalAnimals = reactive({
        focalIds()
      }),
      nAnimals = reactive({
        nrow(pedigreeData())
      }),
      populationCount = reactive({
        ped <- processedPedigree()
        sum(ped$population, na.rm = TRUE)
      }),
      isReady = reactive({
        !is.null(pedigreeData()) && nrow(pedigreeData()) > 0L
      })
    )
  })
}
