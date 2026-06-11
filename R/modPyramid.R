# Age-Sex Pyramid Shiny Module

#' Age-Sex Pyramid Module - UI Function
#'
#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' @return A \code{div} containing age-sex pyramid UI.
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @seealso \code{\link{modPyramidServer}}
#' @importFrom shiny NS div h3 fluidRow column wellPanel selectInput
#'   numericInput hr checkboxInput downloadButton tabsetPanel
#'   tabPanel plotOutput tableOutput includeHTML sliderInput uiOutput helpText
#' @export
modPyramidUI <- function(id) {
  ns <- NS(id)

  div(
    id = ns("moduleContainer"),
    `data-ready` = "false",
    `data-module` = "pyramid",

    h3("Age-Sex Pyramid Analysis"),
    fluidRow(
      column(3L,
             wellPanel(
               selectInput(ns("ageUnit"), "Age Unit:",
                           choices = c(Years = "years", Months = "months")),
               numericInput(ns("ageBin"), "Bin Size:", value = 2L, min = 1L,
                            max = 10L),
               selectInput(ns("colorScheme"), "Color Scheme:",
                           choices = c(Default = "default",
                                       Viridis = "viridis")),
               hr(),
               checkboxInput(ns("showCounts"), "Show counts", TRUE),
               hr(),
               sliderInput(ns("plotHeight"), "Plot Height (pixels):",
                           min = 400L, max = 1500L, value = 600L, step = 50L),
               helpText(
                 "Increase height for better visibility with many age groups",
                        style =
                   "font-size: 14px; color: darblue; font-weight: bold;"),
               hr(),
               sliderInput(ns("ageLabelSize"), "Age Label Size:",
                           min = 0.5, max = 2.0, value = 1.0, step = 0.1),
               hr(),
               downloadButton(ns("downloadPlot"), "Download Plot")
             ),
             div(
               style = paste(
                 "padding: 10px; border: 1px solid lightgray;",
                 "background-color: #EDEDED; border-radius: 25px;",
                 "box-shadow: 0 0 5px 2px #888; margin-top: 10px;"
               ),
               includeHTML(
                 system.file("extdata", "ui_guidance", "pyramidPlot.html",
                             package = "nprcgenekeepr")
               )
             )
      ),
      column(9L,
             tabsetPanel(
               tabPanel("Plot", uiOutput(ns("pyramidPlotUI"))),
               tabPanel("Statistics", tableOutput(ns("pyramidStats")))
             )
      )
    )
  )
}

#' Age-Sex Pyramid Module - Server Function
#'
#' @return List with \code{data}, \code{plot}, and \code{livingCount}.
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param pedigreeData reactive returning pedigree data frame.
#'
#' @seealso \code{\link{modPyramidUI}}
#' @importFrom grDevices dev.off png
#' @importFrom shiny moduleServer reactive eventReactive renderPlot renderTable
#'   downloadHandler req isolate tagList renderUI
#' @importFrom graphics text
#' @export
modPyramidServer <- function(id, pedigreeData) {
  moduleServer(id, function(input, output, session) {

    ns <- session$ns

    # Dynamic plot container with adjustable height
    output$pyramidPlotUI <- renderUI({
      height <- if (!is.null(input$plotHeight)) input$plotHeight else 600L
      plotOutput(ns("pyramidPlot"), height = paste0(height, "px"))
    })

    # Render pyramid plot with UI controls
    output$pyramidPlot <- renderPlot({
      req(pedigreeData())
      getPyramidPlot(
        ped = pedigreeData(),
        binWidth = input$ageBin,
        ageUnit = input$ageUnit,
        colorScheme = input$colorScheme,
        showCounts = input$showCounts,
        ageLabelCex = input$ageLabelSize
      )
    })

    output$pyramidStats <- renderTable({
      req(pedigreeData())
      ped <- pedigreeData()
      data.frame(
        Metric = c("Total", "Males", "Females"),
        Value = c(nrow(ped),
                  sum(ped$sex == "M", na.rm = TRUE),
                  sum(ped$sex == "F", na.rm = TRUE)),
        stringsAsFactors = FALSE
      )
    })

    # Signal data-ready when pyramid is rendered (for E2E testing)
    observe({
      req(pedigreeData())
      session$sendCustomMessage("setDataReady", list(
        selector = paste0("#", session$ns("moduleContainer")),
        ready = TRUE
      ))
    })

    output$downloadPlot <- downloadHandler(
      filename = function() paste0("pyramid_", Sys.Date(), ".png"),
      content = function(file) {
        # Scale PNG dimensions based on user's plot height selection
        plotHeight <- if (!is.null(input$plotHeight)) input$plotHeight else 600L
        # Maintain aspect ratio: width = height * 1.5
        png(file, width = as.integer(plotHeight * 1.5), height = plotHeight)
        getPyramidPlot(
          ped = pedigreeData(),
          binWidth = input$ageBin,
          ageUnit = input$ageUnit,
          colorScheme = input$colorScheme,
          showCounts = input$showCounts,
          ageLabelCex = input$ageLabelSize
        )
        dev.off()
      }
    )

    list(
      pedigree = reactive(pedigreeData()),
      animalCount = reactive(nrow(pedigreeData()))
    )
  })
}
