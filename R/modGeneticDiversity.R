## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Genetic Diversity Shiny Module

#' Genetic Diversity Module - UI Function
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @return A \code{div} containing the genetic diversity heat-map UI: a
#'   housing-type selector, a guidance area, the heat-map plot, and a note about
#'   animals with no birth date (shown only when there are any).
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
             plotOutput(ns("heatmap"), height = "500px"),
             uiOutput(ns("birthDateNote"))
      )
    )
  )
}

## Said on the page when a formed group holds an animal the loaded pedigree no
## longer has (a new file was read, or the view was trimmed, after the groups
## were formed).
.groupsOutsidePedigreeNote <- paste(
  "Some animals in the breeding groups are not in the pedigree now loaded",
  "(a new file or a trimmed view). Form the groups again to see the heat map."
)

#' Genetic Diversity Module - Server Function
#'
#' Assembles the live breeding-group, genetic-value, and kinship reactive
#' inputs into the per-group heat-map statistics (via
#' \code{\link{getGeneticDiversityStats}}) and renders the red/yellow/green
#' heat map (via \code{\link{makeGeneticDiversityHeatmap}}). When breeding
#' groups have not been formed or the genetic value analysis has not been run,
#' the module shows guidance instead of an empty plot. When a formed group
#' holds an animal the loaded pedigree no longer has (a new file was read, or
#' the view was trimmed, after the groups were formed), the page says so in one
#' sentence and asks for the groups to be formed again; any other calculation
#' error is shown once, where the heat map would be. When any animal in the
#' groups has no birth date, a note under the heat map says how many, and how
#' many females among them the Production and Inbreeding columns counted (those
#' the pedigree lists as a dam) and left out.
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param groups reactive returning a list of character vectors of animal IDs,
#'   one per breeding group (the \code{groups} returned by
#'   \code{\link{modBreedingGroupsServer}}). That list includes the trailing
#'   "Unused" element when candidates remain unplaced, and the heat map scores
#'   it as another group. If the list is named, the names are the heat map's
#'   row labels (the app passes the names that the Breeding Groups module
#'   returns as groupLabels, so the last row reads "Unused animals"); an
#'   unnamed list gives "Group 1", "Group 2" and so on.
#' @param pedigree reactive returning the quality-controlled pedigree data
#'   frame.
#' @param geneticValues reactive returning the genetic value report data frame
#'   (with \code{id} and \code{value} columns).
#' @param kinshipMatrix reactive returning a square kinship matrix (row and
#'   column names are animal IDs) covering every member of every group;
#'   \code{\link{getGeneticDiversityStats}} stops when a group member is
#'   missing from it. In the app this is the full-pedigree kinship matrix that
#'   Summary Statistics and Breeding Groups also use, so it covers every animal
#'   of the pedigree, not only the Genetic Value population.
#' @param currentDate Date used to derive age and the production birth window.
#'   Defaults to \code{Sys.Date()}.
#'
#' @return A list with two reactive elements: \code{stats}, the per-group
#'   metric data frame (or \code{NULL} when data are not ready), and
#'   \code{heatmap}, the \code{ggplot} heat map (or \code{NULL}). Errors
#'   raised inside \code{getGeneticDiversityStats} (a group member missing
#'   from the kinship matrix) are not caught, so the reactives error instead
#'   of returning \code{NULL}.
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

    ## A formed group can hold an animal the loaded pedigree no longer has
    ## (the groups outlive a new file or a trimmed view).
    groupsOutsidePedigree <- reactive({
      .anyGroupMemberMissingFromPedigree(safeRead(groups), safeRead(pedigree))
    })

    output$heatmap <- renderPlot({
      ## The guidance says what to do in that case.
      req(!groupsOutsidePedigree())
      p <- diversityPlot()
      req(p)
      p
    })

    output$guidance <- renderUI({
      if (groupsOutsidePedigree()) {
        return(div(class = "alert alert-info", .groupsOutsidePedigreeNote))
      }
      ## Any other failing calculation is reported once, by the heat map.
      stats <- tryCatch(diversityStats(), error = function(e) e)
      if (inherits(stats, "error")) {
        return(NULL)
      }
      if (is.null(stats)) {
        div(
          class = "alert alert-info",
          paste(
            "Form breeding groups and run the genetic value analysis to",
            "see the genetic diversity heat map."
          )
        )
      }
    })

    output$birthDateNote <- renderUI({
      ## A failing calculation is already reported on the page (by the heat
      ## map, or by the guidance sentence), so it is read as "not ready" here.
      if (is.null(tryCatch(diversityStats(), error = function(e) NULL))) {
        return(NULL)
      }
      s <- summarizeMissingBirthDates(safeRead(groups), safeRead(pedigree))
      if (s$animals == 0L) {
        return(NULL)
      }
      div(class = "alert alert-warning", makeBirthDateNoteText(s))
    })

    # Signal data-ready when the heat map is rendered (for E2E testing). An
    # error in an observer ends the user's whole session, unlike an error in
    # an output (shown in the tab), so a failing calculation is read as "not
    # ready" here; heatmap and guidance still report it.
    observe({
      req(tryCatch(diversityPlot(), error = function(e) NULL))
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
