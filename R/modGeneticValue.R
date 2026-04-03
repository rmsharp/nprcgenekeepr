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
    id = ns("moduleContainer"),
    `data-ready` = "false",
    `data-module` = "geneticValue",

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
#' @return List with \code{geneticValues}, \code{topAnimals},
#' \code{nAnalyzed}, \code{kinshipMatrix}, \code{founderStats},
#' \code{maleFounders}, and \code{femaleFounders}.
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
#' @importFrom shiny moduleServer reactive eventReactive withProgress incProgress
#' @export
modGeneticValueServer <- function(id, pedigree) {
  moduleServer(id, function(input, output, session) {

    # Store full reportGV results
    fullResults <- reactiveVal(NULL)

    gvResults <- eventReactive(input$runAnalysis, {
      req(pedigree())

      withProgress(message = "Running genetic value analysis...", {
        ped <- pedigree()

        # Create progress update function compatible with reportGV
        updateProgress <- function(n = 1L, detail = NULL, value = 0L,
                                   reset = FALSE) {
          if (reset) {
            incProgress(0, detail = detail)
          } else {
            incProgress(amount = 0.01, detail = detail)
          }
        }

        incProgress(0.1, detail = "Preparing pedigree")

        # Ensure pedigree has required columns
        if (!"population" %in% names(ped)) {
          # Set all living animals as the population
          if ("exit" %in% names(ped)) {
            ped$population <- is.na(ped$exit)
          } else {
            ped$population <- TRUE
          }
        }

        # Get probands and trim pedigree for analysis
        probands <- ped$id[ped$population]
        if (length(probands) == 0L) {
          probands <- ped$id
          ped$population <- TRUE
        }

        incProgress(0.2, detail = "Trimming pedigree")
        ped <- trimPedigree(probands, ped,
                            removeUninformative = FALSE,
                            addBackParents = FALSE)

        # Add generation if not present
        if (!"gen" %in% names(ped)) {
          ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
        }

        incProgress(0.2, detail = "Running genetic value analysis")

        # Call the real reportGV function
        gvReport <- reportGV(
          ped,
          guIter = input$nIterations,
          guThresh = 1L,
          byID = TRUE,
          updateProgress = updateProgress
        )

        # Store full results
        fullResults(gvReport)

        # Return the report data frame with added rank column
        report <- gvReport$report
        if (!"indivMeanKin" %in% names(report)) {
          # Handle edge case where report might not have expected columns
          return(report)
        }

        # Add rank based on genetic value (low kinship + high uniqueness)
        report$rank <- rank(report$indivMeanKin - report$gu)
        report <- report[order(report$rank), ]
        report$rank <- seq_len(nrow(report))

        # Signal that genetic value analysis is complete (for E2E testing)
        session$sendCustomMessage("setDataReady", list(
          selector = paste0("#", session$ns("moduleContainer")),
          ready = TRUE
        ))

        report
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
      fullRes <- fullResults()

      # Use indivMeanKin and gu column names from reportGV
      mkCol <- if ("indivMeanKin" %in% names(results)) "indivMeanKin" else "meanKinship"
      guCol <- if ("gu" %in% names(results)) "gu" else "genomeUniqueness"

      summaryData <- data.frame(
        Metric = c("Animals Analyzed", "Mean Kinship (avg)",
                   "Genome Uniqueness (avg)"),
        Value = c(nrow(results),
                  sprintf("%.4f", mean(results[[mkCol]], na.rm = TRUE)),
                  sprintf("%.4f", mean(results[[guCol]], na.rm = TRUE))),
        stringsAsFactors = FALSE
      )

      # Add founder statistics if available
      if (!is.null(fullRes)) {
        founderData <- data.frame(
          Metric = c("Total Founders", "Male Founders", "Female Founders",
                     "Founder Equivalents (FE)", "Founder Genome Equiv. (FG)"),
          Value = c(as.character(fullRes$total),
                    as.character(fullRes$nMaleFounders),
                    as.character(fullRes$nFemaleFounders),
                    sprintf("%.2f", fullRes$fe),
                    sprintf("%.2f", fullRes$fg)),
          stringsAsFactors = FALSE
        )
        summaryData <- rbind(summaryData, founderData)
      }

      summaryData
    })

    output$gvScatterPlot <- renderPlot({
      req(gvResults())
      results <- gvResults()

      # Use correct column names
      mkCol <- if ("indivMeanKin" %in% names(results)) "indivMeanKin" else "meanKinship"
      guCol <- if ("gu" %in% names(results)) "gu" else "genomeUniqueness"

      plot(results[[mkCol]], results[[guCol]],
           xlab = "Mean Kinship", ylab = "Genome Uniqueness",
           main = "Genetic Value Analysis",
           pch = 19, col = ifelse(results$rank <= 10, "red", "blue"))
    })

    output$downloadRankings <- downloadHandler(
      filename = function() paste0("geneticValues_", Sys.Date(), ".csv"),
      content = function(file) write.csv(gvResults(), file, row.names = FALSE)
    )

    return(list(
      geneticValues = reactive({
        gv <- gvResults()
        if (is.null(gv)) return(NULL)
        # Rename columns to standard names expected by other modules
        if ("indivMeanKin" %in% names(gv)) {
          names(gv)[names(gv) == "indivMeanKin"] <- "meanKinship"
        }
        if ("gu" %in% names(gv)) {
          names(gv)[names(gv) == "gu"] <- "genomeUniqueness"
        }
        gv
      }),
      topAnimals = reactive({
        gv <- gvResults()
        if (is.null(gv)) return(NULL)
        gv[gv$rank <= 10, ]
      }),
      nAnalyzed = reactive({ nrow(gvResults()) }),
      kinshipMatrix = reactive({
        req(fullResults())
        fullResults()$kinship
      }),
      founderStats = reactive({
        req(fullResults())
        fr <- fullResults()
        list(
          fe = fr$fe,
          fg = fr$fg,
          total = fr$total,
          nMaleFounders = fr$nMaleFounders,
          nFemaleFounders = fr$nFemaleFounders
        )
      }),
      maleFounders = reactive({
        req(fullResults())
        fullResults()$maleFounders
      }),
      femaleFounders = reactive({
        req(fullResults())
        fullResults()$femaleFounders
      })
    ))
  })
}
