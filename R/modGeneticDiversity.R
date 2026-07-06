## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Genetic Diversity Shiny Module

#' Genetic Diversity Module - UI Function
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @return A \code{div} containing the genetic diversity heat-map UI: a
#'   housing-type selector, a guidance area, and the heat-map plot.
#'
#' @seealso \code{\link{modGeneticDiversityServer}}
#' @importFrom shiny NS div h3 fluidRow column wellPanel selectInput
#' @importFrom shiny uiOutput plotOutput
#' @family Shiny modules
#' @export
modGeneticDiversityUI <- function(id) {
  ns <- NS(id)

  div(
    id = ns("moduleContainer"),
    `data-ready` = "false",
    `data-module` = "geneticDiversity",

    h3("Genetic Diversity"),
    fluidRow(
      column(3L,
             wellPanel(
               selectInput(
                 ns("housing"), "Housing type:",
                 choices = c("Shelter pens" = "shelter_pens",
                             Corral = "corral"),
                 selected = "shelter_pens"
               )
             )
      ),
      column(9L,
             uiOutput(ns("guidance")),
             plotOutput(ns("heatmap"), height = "500px")
      )
    )
  )
}

#' Genetic Diversity Module - Server Function
#'
#' Assembles the live breeding-group, genetic-value, and kinship reactive
#' inputs into the per-group heat-map statistics (via
#' \code{\link{getGeneticDiversityStats}}) and renders the red/yellow/green
#' heat map (via \code{\link{makeGeneticDiversityHeatmap}}). When breeding
#' groups have not been formed or the genetic value analysis has not been run,
#' the module shows guidance instead of an empty plot.
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param groups reactive returning a list of character vectors of animal IDs,
#'   one per breeding group (the \code{groups} returned by
#'   \code{\link{modBreedingGroupsServer}}).
#' @param pedigree reactive returning the quality-controlled pedigree data
#'   frame.
#' @param geneticValues reactive returning the genetic value report data frame
#'   (with \code{id} and \code{value} columns).
#' @param kinshipMatrix reactive returning the full kinship matrix (row and
#'   column names are animal IDs).
#' @param currentDate Date used to derive age and the production birth window.
#'   Defaults to \code{Sys.Date()}.
#'
#' @return A list with two reactive elements: \code{stats}, the per-group
#'   metric data frame (or \code{NULL} when data are not ready), and
#'   \code{heatmap}, the \code{ggplot} heat map (or \code{NULL}).
#'
#' @seealso \code{\link{modGeneticDiversityUI}}
#' @importFrom shiny moduleServer reactive renderPlot renderUI observe req div
#' @family Shiny modules
#' @export
modGeneticDiversityServer <- function(id, groups, pedigree, geneticValues,
                                      kinshipMatrix,
                                      currentDate = Sys.Date()) {
  moduleServer(id, function(input, output, session) {

    ## Read an upstream reactive that may not be ready yet (a group not formed
    ## or an analysis not run raises a silent error); treat "not ready" as NULL
    ## so the module can degrade gracefully rather than error.
    safeRead <- function(r) tryCatch(r(), error = function(e) NULL)

    diversityStats <- reactive({
      grps <- safeRead(groups)
      ped <- safeRead(pedigree)
      gvReport <- safeRead(geneticValues)
      kmat <- safeRead(kinshipMatrix)
      if (is.null(grps) || length(grps) == 0L || is.null(ped) ||
            is.null(gvReport) || is.null(kmat)) {
        return(NULL)
      }
      housing <- if (is.null(input$housing)) "shelter_pens" else input$housing
      getGeneticDiversityStats(grps, ped, gvReport, kmat,
                               housing = housing, currentDate = currentDate)
    })

    diversityPlot <- reactive({
      stats <- diversityStats()
      if (is.null(stats)) {
        return(NULL)
      }
      makeGeneticDiversityHeatmap(stats)
    })

    output$heatmap <- renderPlot({
      p <- diversityPlot()
      req(p)
      p
    })

    output$guidance <- renderUI({
      if (is.null(diversityStats())) {
        div(
          class = "alert alert-info",
          paste(
            "Form breeding groups and run the genetic value analysis to",
            "see the genetic diversity heat map."
          )
        )
      }
    })

    # Signal data-ready when the heat map is rendered (for E2E testing)
    observe({
      req(diversityPlot())
      session$sendCustomMessage("setDataReady", list(
        selector = paste0("#", session$ns("moduleContainer")),
        ready = TRUE
      ))
    })

    list(
      stats = reactive(diversityStats()),
      heatmap = reactive(diversityPlot())
    )
  })
}
