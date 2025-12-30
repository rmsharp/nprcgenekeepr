# ============================================================================
# FILE: R/modPyramid.R
# Age-Sex Pyramid Shiny Module
# ============================================================================

#' Age-Sex Pyramid Module - UI Function
#'
#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of mprcgenekeepr
#'
#' @return A \code{div} containing age-sex pyramid UI.
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @seealso \code{\link{modPyramidServer}}
#' @export
modPyramidUI <- function(id) {
  ns <- NS(id)

  div(
    h3("Age-Sex Pyramid Analysis"),
    fluidRow(
      column(3,
             wellPanel(
               selectInput(ns("ageUnit"), "Age Unit:",
                           choices = c("Years" = "years", "Months" = "months")),
               numericInput(ns("ageBin"), "Bin Size:", value = 2, min = 1, max = 10),
               selectInput(ns("colorScheme"), "Color Scheme:",
                           choices = c("Default" = "default", "Viridis" = "viridis")),
               hr(),
               checkboxInput(ns("showCounts"), "Show counts", TRUE),
               checkboxInput(ns("showGridlines"), "Show gridlines", TRUE),
               actionButton(ns("generatePlot"), "Generate Plot",
                            icon = icon("chart-bar"), class = "btn-primary btn-block"),
               downloadButton(ns("downloadPlot"), "Download Plot")
             )
      ),
      column(9,
             tabsetPanel(
               tabPanel("Plot", plotOutput(ns("pyramidPlot"), height = "600px")),
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
#'   downloadHandler req isolate tagList
#' @importFrom graphics text
#' @export
modPyramidServer <- function(id, pedigreeData) {
  moduleServer(id, function(input, output, session) {

    livingAnimals <- reactive({
      req(pedigreeData())
      data <- pedigreeData()
      data[is.na(data$exit_date) | data$exit_date == "", ]
    })

    output$pyramidPlot <- renderPlot({
      req(livingAnimals())
      input$generatePlot

      isolate({
        plot(1:10, main = "Age-Sex Pyramid",
             xlab = paste("Count (", input$ageUnit, ")"),
             ylab = "Age Group")
        text(5, 5, "Replace with plotAgePyramid()")
      })
    })

    output$pyramidStats <- renderTable({
      req(livingAnimals())
      data <- livingAnimals()
      data.frame(
        Metric = c("Total", "Males", "Females"),
        Value = c(nrow(data),
                  sum(data$sex == "M", na.rm = TRUE),
                  sum(data$sex == "F", na.rm = TRUE)),
        stringsAsFactors = FALSE
      )
    })

    output$downloadPlot <- downloadHandler(
      filename = function() paste0("pyramid_", Sys.Date(), ".png"),
      content = function(file) {
        png(file, width = 1200, height = 800)
        plot(1:10, main = "Age-Sex Pyramid")
        dev.off()
      }
    )

    return(list(
      data = reactive({ NULL }),
      plot = reactive({ NULL }),
      livingCount = reactive({ nrow(livingAnimals()) })
    ))
  })
}
