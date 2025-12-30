# ============================================================================
# FILE: R/modSummaryStats.R
# Summary Statistics Shiny Module
# ============================================================================

#' Summary Statistics Module - UI Function
#'
#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Creates user interface for summary statistics display including
#' histograms and box plots for mean kinship, z-scores, and genome uniqueness.
#'
#' @return A \code{div} object containing summary statistics UI.
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @seealso \code{\link{modSummaryStatsServer}} for server logic.
#' @importFrom shiny NS div h3 fluidRow column br downloadButton
#'   plotOutput htmlOutput withMathJax includeHTML
#' @export
modSummaryStatsUI <- function(id) {
  ns <- NS(id)

  div(
    h3("Summary Statistics and Plots"),

    # Summary stats HTML guidance at top
    fluidRow(
      column(
        10,
        offset = 1,
        style = paste(
          "border: 1px solid lightgray; background-color: #EDEDED;",
          "border-radius: 25px; box-shadow: 0 0 5px 2px #888; padding: 10px;"
        ),
        withMathJax(
          includeHTML(
            system.file("extdata", "ui_guidance", "summary_stats.html",
                        package = "nprcgenekeepr")
          )
        )
      )
    ),
    br(),

    # Export buttons row
    fluidRow(
      column(2, offset = 1,
             downloadButton(ns("downloadKinship"), "Export Kinship Matrix")),
      column(2,
             downloadButton(ns("downloadMaleFounders"), "Export Male Founders")),
      column(2,
             downloadButton(ns("downloadFemaleFounders"), "Export Female Founders")),
      column(3,
             downloadButton(ns("downloadFirstOrder"), "Export First-Order Relationships"))
    ),
    br(),

    # Summary statistics output
    fluidRow(
      column(10, offset = 1, htmlOutput(ns("summaryStats")))
    ),
    br(),

    # Plots row - Histograms on left, Box plots on right
    fluidRow(
      # Left column - Histograms
      column(
        5,
        offset = 1,
        plotOutput(ns("mkHist"), width = "400px", height = "400px"),
        br(),
        downloadButton(ns("downloadMkHist"), "Export Mean Kinship Histogram"),
        br(), br(),

        plotOutput(ns("zscoreHist"), width = "400px", height = "400px"),
        br(),
        downloadButton(ns("downloadZscoreHist"), "Export Z-Score Histogram"),
        br(), br(),

        plotOutput(ns("guHist"), width = "400px", height = "400px"),
        br(),
        downloadButton(ns("downloadGuHist"), "Export Genome Uniqueness Histogram"),
        br()
      ),

      # Right column - Box plots
      column(
        5,
        plotOutput(ns("mkBox"), width = "400px", height = "400px"),
        br(),
        downloadButton(ns("downloadMkBox"), "Export Mean Kinship Box Plot"),
        br(), br(),

        plotOutput(ns("zscoreBox"), width = "400px", height = "400px"),
        br(),
        downloadButton(ns("downloadZscoreBox"), "Export Z-Score Box Plot"),
        br(), br(),

        plotOutput(ns("guBox"), width = "400px", height = "400px"),
        br(),
        downloadButton(ns("downloadGuBox"), "Export Genome Uniqueness Box Plot"),
        br()
      )
    ),
    br(),

    # Population genetics terms HTML at bottom
    fluidRow(
      column(
        10,
        offset = 1,
        style = paste(
          "border: 1px solid lightgray; background-color: #EDEDED;",
          "border-radius: 25px; box-shadow: 0 0 5px 2px #888; padding: 10px;"
        ),
        withMathJax(
          includeHTML(
            system.file("extdata", "ui_guidance", "population_genetics_terms.html",
                        package = "nprcgenekeepr")
          )
        )
      )
    )
  )
}

#' Summary Statistics Module - Server Function
#'
#' Server logic for summary statistics module displaying genetic analysis
#' results including kinship statistics, histograms, and box plots.
#'
#' @return A list with reactive components for export.
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param geneticValues reactive returning genetic value analysis results.
#' @param pedigree reactive returning pedigree data frame.
#' @param kinshipMatrix optional reactive returning kinship matrix.
#'
#' @seealso \code{\link{modSummaryStatsUI}} for the user interface.
#' @importFrom shiny moduleServer reactive renderPlot renderUI downloadHandler req
#' @importFrom grDevices dev.off png
#' @importFrom graphics hist boxplot par
#' @importFrom stats median
#' @export
modSummaryStatsServer <- function(id, geneticValues, pedigree,
                                   kinshipMatrix = NULL) {
  moduleServer(id, function(input, output, session) {

    # Summary statistics HTML output
    output$summaryStats <- renderUI({
      req(geneticValues())
      gv <- geneticValues()

      div(
        h4("Population Summary"),
        tags$ul(
          tags$li(paste("Animals analyzed:", nrow(gv))),
          tags$li(paste("Mean kinship (average):",
                        sprintf("%.4f", mean(gv$meanKinship, na.rm = TRUE)))),
          tags$li(paste("Genome uniqueness (average):",
                        sprintf("%.4f", mean(gv$genomeUniqueness, na.rm = TRUE))))
        )
      )
    })

    # Mean Kinship Histogram
    output$mkHist <- renderPlot({
      req(geneticValues())
      gv <- geneticValues()
      hist(gv$meanKinship,
           main = "Mean Kinship Coefficient Distribution",
           xlab = "Mean Kinship Coefficient",
           col = "steelblue",
           border = "white")
    })

    # Z-Score Histogram
    output$zscoreHist <- renderPlot({
      req(geneticValues())
      gv <- geneticValues()
      if ("zScore" %in% names(gv)) {
        hist(gv$zScore,
             main = "Mean Kinship Z-Score Distribution",
             xlab = "Z-Score",
             col = "steelblue",
             border = "white")
      } else {
        plot.new()
        text(0.5, 0.5, "Z-scores not available")
      }
    })

    # Genome Uniqueness Histogram
    output$guHist <- renderPlot({
      req(geneticValues())
      gv <- geneticValues()
      hist(gv$genomeUniqueness,
           main = "Genome Uniqueness Distribution",
           xlab = "Genome Uniqueness",
           col = "steelblue",
           border = "white")
    })

    # Mean Kinship Box Plot
    output$mkBox <- renderPlot({
      req(geneticValues())
      gv <- geneticValues()
      boxplot(gv$meanKinship,
              main = "Mean Kinship Coefficient",
              ylab = "Mean Kinship Coefficient",
              col = "steelblue")
    })

    # Z-Score Box Plot
    output$zscoreBox <- renderPlot({
      req(geneticValues())
      gv <- geneticValues()
      if ("zScore" %in% names(gv)) {
        boxplot(gv$zScore,
                main = "Mean Kinship Z-Score",
                ylab = "Z-Score",
                col = "steelblue")
      } else {
        plot.new()
        text(0.5, 0.5, "Z-scores not available")
      }
    })

    # Genome Uniqueness Box Plot
    output$guBox <- renderPlot({
      req(geneticValues())
      gv <- geneticValues()
      boxplot(gv$genomeUniqueness,
              main = "Genome Uniqueness",
              ylab = "Genome Uniqueness",
              col = "steelblue")
    })

    # Download handlers
    output$downloadKinship <- downloadHandler(
      filename = function() paste0("kinship_matrix_", Sys.Date(), ".csv"),
      content = function(file) {
        req(kinshipMatrix)
        write.csv(kinshipMatrix(), file)
      }
    )

    output$downloadMaleFounders <- downloadHandler(
      filename = function() paste0("male_founders_", Sys.Date(), ".csv"),
      content = function(file) {
        req(pedigree())
        ped <- pedigree()
        males <- ped[ped$sex == "M" & is.na(ped$sire) & is.na(ped$dam), ]
        write.csv(males, file, row.names = FALSE)
      }
    )

    output$downloadFemaleFounders <- downloadHandler(
      filename = function() paste0("female_founders_", Sys.Date(), ".csv"),
      content = function(file) {
        req(pedigree())
        ped <- pedigree()
        females <- ped[ped$sex == "F" & is.na(ped$sire) & is.na(ped$dam), ]
        write.csv(females, file, row.names = FALSE)
      }
    )

    output$downloadFirstOrder <- downloadHandler(
      filename = function() paste0("first_order_relationships_", Sys.Date(), ".csv"),
      content = function(file) {
        # Placeholder - implement based on your relationship calculation
        req(pedigree())
        write.csv(data.frame(message = "First-order relationships"), file,
                  row.names = FALSE)
      }
    )

    # Plot download handlers
    .savePlot <- function(plotFn, file, width = 800, height = 600) {
      png(file, width = width, height = height)
      plotFn()
      dev.off()
    }

    output$downloadMkHist <- downloadHandler(
      filename = function() paste0("mk_histogram_", Sys.Date(), ".png"),
      content = function(file) {
        .savePlot(function() {
          gv <- geneticValues()
          hist(gv$meanKinship,
               main = "Mean Kinship Coefficient Distribution",
               xlab = "Mean Kinship Coefficient",
               col = "steelblue", border = "white")
        }, file)
      }
    )

    output$downloadZscoreHist <- downloadHandler(
      filename = function() paste0("zscore_histogram_", Sys.Date(), ".png"),
      content = function(file) {
        .savePlot(function() {
          gv <- geneticValues()
          if ("zScore" %in% names(gv)) {
            hist(gv$zScore,
                 main = "Mean Kinship Z-Score Distribution",
                 xlab = "Z-Score",
                 col = "steelblue", border = "white")
          }
        }, file)
      }
    )

    output$downloadGuHist <- downloadHandler(
      filename = function() paste0("gu_histogram_", Sys.Date(), ".png"),
      content = function(file) {
        .savePlot(function() {
          gv <- geneticValues()
          hist(gv$genomeUniqueness,
               main = "Genome Uniqueness Distribution",
               xlab = "Genome Uniqueness",
               col = "steelblue", border = "white")
        }, file)
      }
    )

    output$downloadMkBox <- downloadHandler(
      filename = function() paste0("mk_boxplot_", Sys.Date(), ".png"),
      content = function(file) {
        .savePlot(function() {
          gv <- geneticValues()
          boxplot(gv$meanKinship,
                  main = "Mean Kinship Coefficient",
                  ylab = "Mean Kinship Coefficient",
                  col = "steelblue")
        }, file)
      }
    )

    output$downloadZscoreBox <- downloadHandler(
      filename = function() paste0("zscore_boxplot_", Sys.Date(), ".png"),
      content = function(file) {
        .savePlot(function() {
          gv <- geneticValues()
          if ("zScore" %in% names(gv)) {
            boxplot(gv$zScore,
                    main = "Mean Kinship Z-Score",
                    ylab = "Z-Score",
                    col = "steelblue")
          }
        }, file)
      }
    )

    output$downloadGuBox <- downloadHandler(
      filename = function() paste0("gu_boxplot_", Sys.Date(), ".png"),
      content = function(file) {
        .savePlot(function() {
          gv <- geneticValues()
          boxplot(gv$genomeUniqueness,
                  main = "Genome Uniqueness",
                  ylab = "Genome Uniqueness",
                  col = "steelblue")
        }, file)
      }
    )

    # Return reactive values for use by other modules
    return(list(
      summaryData = reactive({
        req(geneticValues())
        gv <- geneticValues()
        list(
          nAnimals = nrow(gv),
          meanMK = mean(gv$meanKinship, na.rm = TRUE),
          meanGU = mean(gv$genomeUniqueness, na.rm = TRUE)
        )
      })
    ))
  })
}
