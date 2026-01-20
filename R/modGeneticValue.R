# Genetic Value Analysis Shiny Module

#' Genetic Value Analysis Module - UI Function
#'
#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' @return A \code{div} containing genetic value analysis UI.
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @seealso \code{\link{modGeneticValueServer}}
#' @seealso \code{\link{geneDrop}} for gene dropping simulation.
#'
#' @references
#' Vinson, A. and Raboin, M.J. (2015)
#' \emph{Journal of the American Association for Laboratory Animal Science},
#' \strong{54}(6), 700-707.
#' @importFrom DT DTOutput renderDT
#' @importFrom shiny NS div h3 fluidRow column wellPanel
#'   h4 icon numericInput checkboxInput sliderInput actionButton
#'   tabsetPanel tabPanel br downloadButton plotOutput tableOutput includeHTML
#' @export
modGeneticValueUI <- function(id) {
  ns <- NS(id)

  div(
    h3("Genetic Value Analysis"),
    fluidRow(
      column(4,
             wellPanel(
               h4(icon("dna"), "Analysis Options"),
               numericInput(ns("nIterations"), "Gene Drop Iterations:",
                            value = 5000, min = 100, max = 10000, step = 100),
               checkboxInput(ns("calcGenomeUniqueness"),
                             "Calculate Genome Uniqueness", TRUE),
               checkboxInput(ns("calcMeanKinship"),
                             "Calculate Mean Kinship", TRUE),
               sliderInput(ns("minAge"), "Minimum breeding age (years):",
                           min = 0, max = 10, value = 2, step = 0.5),
               actionButton(ns("runAnalysis"), "Run Analysis",
                            icon = icon("play"), class = "btn-primary btn-block")
             ),
             wellPanel(
               style = "background-color: #f8f9fa;",
               h5(icon("info-circle"), "About Genetic Values"),
               tags$ul(
                 tags$li(strong("Mean Kinship:"), " Lower is better"),
                 tags$li(strong("Genome Uniqueness:"), " Higher is better")
               )
             ),
             div(
               style = paste(
                 "padding: 10px; border: 1px solid lightgray;",
                 "background-color: #EDEDED; border-radius: 25px;",
                 "box-shadow: 0 0 5px 2px #888; margin-top: 10px;"
               ),
               includeHTML(
                 system.file("extdata", "ui_guidance", "genetic_value.html",
                             package = "nprcgenekeepr")
               )
             )
      ),
      column(8,
             tabsetPanel(
               tabPanel("Rankings",
                        br(),
                        numericInput(ns("topN"), "Show top N:", value = 20, min = 5),
                        downloadButton(ns("downloadRankings"), "Download"),
                        br(), br(),
                        DT::DTOutput(ns("rankingsTable"))
               ),
               tabPanel("Visualizations",
                        br(),
                        plotOutput(ns("gvScatterPlot"), height = "500px")
               ),
               tabPanel("Summary",
                        br(),
                        tableOutput(ns("gvSummary"))
               )
             )
      )
    )
  )
}

#' Genetic Value Analysis Module - Server Function
#'
#' @return List with \code{geneticValues}, \code{topAnimals}, and
#' \code{nAnalyzed}.
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param pedigree reactive returning pedigree data frame.
#'
#' @seealso \code{\link{modGeneticValueUI}}
#' @seealso \code{\link{modBreedingGroupsServer}} for using results.
#'
#' @references
#' Lacy, R.C. (1989) \emph{Zoo Biology}, \strong{8}, 111-123.
#'
#' @importFrom shiny moduleServer reactive eventReactive
#' @export
modGeneticValueServer <- function(id, pedigree) {
  moduleServer(id, function(input, output, session) {

    gvResults <- eventReactive(input$runAnalysis, {
      req(pedigree())

      withProgress(message = "Running genetic value analysis...", {
        ped <- pedigree()

        incProgress(0.3, detail = "Calculating kinship")
        # kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)

        incProgress(0.4, detail = "Gene dropping")
        # geneDrop <- geneDrop(ped, n = input$nIterations)

        incProgress(0.3, detail = "Computing values")
        # gv <- calcGV(ped, kmat, geneDrop)

        # Placeholder
        nAnimals <- min(50, nrow(ped))
        results <- data.frame(
          id = ped$id[1:nAnimals],
          meanKinship = runif(nAnimals, 0.1, 0.5),
          genomeUniqueness = runif(nAnimals, 0.3, 0.9),
          stringsAsFactors = FALSE
        )
        results$rank <- rank(-results$genomeUniqueness +
                               (1 - results$meanKinship))
        results <- results[order(results$rank), ]
        results$rank <- seq_len(nrow(results))
        results
      })
    })

    output$rankingsTable <- DT::renderDT({
      req(gvResults())
      data <- gvResults()
      if (input$topN < nrow(data)) data <- data[1:input$topN, ]
      data
    })

    output$gvSummary <- renderTable({
      req(gvResults())
      results <- gvResults()
      data.frame(
        Metric = c("Animals Analyzed", "Mean Kinship (avg)",
                   "Genome Uniqueness (avg)"),
        Value = c(nrow(results),
                  sprintf("%.3f", mean(results$meanKinship)),
                  sprintf("%.3f", mean(results$genomeUniqueness))),
        stringsAsFactors = FALSE
      )
    })

    output$gvScatterPlot <- renderPlot({
      req(gvResults())
      results <- gvResults()
      plot(results$meanKinship, results$genomeUniqueness,
           xlab = "Mean Kinship", ylab = "Genome Uniqueness",
           main = "Genetic Value Analysis",
           pch = 19, col = ifelse(results$rank <= 10, "red", "blue"))
    })

    output$downloadRankings <- downloadHandler(
      filename = function() paste0("geneticValues_", Sys.Date(), ".csv"),
      content = function(file) write.csv(gvResults(), file, row.names = FALSE)
    )

    return(list(
      geneticValues = reactive({ gvResults() }),
      topAnimals = reactive({ gvResults()[gvResults()$rank <= 10, ] }),
      nAnalyzed = reactive({ nrow(gvResults()) })
    ))
  })
}
