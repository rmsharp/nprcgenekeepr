# Summary Statistics Shiny Module

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

    # Export buttons row (with popover descriptions)
    fluidRow(
      column(2, offset = 1,
             shinyBS::popify(
               downloadButton(ns("downloadKinship"), "Export Kinship Matrix"),
               title = NULL,
               content = paste0(
                 "This exports the kinship matrix to a CSV file ",
                 "in the user selected directory."
               )
             )),
      column(2,
             shinyBS::popify(
               downloadButton(ns("downloadMaleFounders"), "Export Male Founders"),
               title = NULL,
               content = paste0(
                 "This exports the male founder pedigree records to ",
                 "a CSV file to the user selected directory."
               )
             )),
      column(2,
             shinyBS::popify(
               downloadButton(ns("downloadFemaleFounders"), "Export Female Founders"),
               title = NULL,
               content = paste0(
                 "This exports the female founder pedigree records ",
                 "to a CSV file to the user selected directory."
               )
             )),
      column(3,
             shinyBS::popify(
               downloadButton(ns("downloadFirstOrder"), "Export First-Order Relationships"),
               title = NULL,
               content = paste0(
                 "This exports all first-order relations to a CSV file ",
                 "to the user selected directory."
               )
             ))
    ),
    br(),
    # Additional relationship export buttons
    fluidRow(
      column(3, offset = 1,
             shinyBS::popify(
               downloadButton(ns("downloadRelationships"), "Export All Relationships"),
               title = NULL,
               content = paste0(
                 "This exports all pairwise relationship designations ",
                 "to a CSV file."
               )
             )),
      column(3,
             shinyBS::popify(
               downloadButton(ns("downloadRelationClasses"), "Export Relationship Classes"),
               title = NULL,
               content = paste0(
                 "This exports the relationship class frequency table ",
                 "to a CSV file."
               )
             ))
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
        shinyBS::popify(
          downloadButton(ns("downloadMkHist"), "Export Mean Kinship Histogram"),
          title = NULL,
          content = paste0(
            "This exports the Mean Kinship Coefficient histogram as ",
            "a PNG file to the user selected directory."
          )
        ),
        br(), br(),

        plotOutput(ns("zscoreHist"), width = "400px", height = "400px"),
        br(),
        shinyBS::popify(
          downloadButton(ns("downloadZscoreHist"), "Export Z-Score Histogram"),
          title = NULL,
          content = paste0(
            "This exports the Mean Kinship Z-score histogram as ",
            "a PNG file to the user selected directory."
          )
        ),
        br(), br(),

        plotOutput(ns("guHist"), width = "400px", height = "400px"),
        br(),
        shinyBS::popify(
          downloadButton(ns("downloadGuHist"), "Export Genome Uniqueness Histogram"),
          title = NULL,
          content = paste0(
            "This exports the Genome Uniqueness histogram as PNG ",
            "file to the user selected directory."
          )
        ),
        br()
      ),

      # Right column - Box plots
      column(
        5,
        plotOutput(ns("mkBox"), width = "400px", height = "400px"),
        br(),
        shinyBS::popify(
          downloadButton(ns("downloadMkBox"), "Export Mean Kinship Box Plot"),
          title = NULL,
          content = paste0(
            "This exports Mean Kinship Coefficient box plot as PNG file ",
            "to the user selected directory."
          )
        ),
        br(), br(),

        plotOutput(ns("zscoreBox"), width = "400px", height = "400px"),
        br(),
        shinyBS::popify(
          downloadButton(ns("downloadZscoreBox"), "Export Z-Score Box Plot"),
          title = NULL,
          content = paste0(
            "This exports the Mean Kinship Z-score box plot as ",
            "a PNG file to the user selected directory."
          )
        ),
        br(), br(),

        plotOutput(ns("guBox"), width = "400px", height = "400px"),
        br(),
        shinyBS::popify(
          downloadButton(ns("downloadGuBox"), "Export Genome Uniqueness Box Plot"),
          title = NULL,
          content = paste0(
            "This exports Genome Uniqueness box plot as a PNG ",
            "file to the user selected directory."
          )
        ),
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
#' results including kinship statistics, histograms, box plots, and
#' relationship designation analysis.
#'
#' This module provides:
#' \itemize{
#'   \item Summary statistics (counts, mean kinship, genome uniqueness)
#'   \item Histograms and box plots for genetic value distributions
#'   \item Relationship classification using \code{convertRelationships()}
#'   \item Relationship class frequency tables using \code{makeRelationClassesTable()}
#'   \item First-order relative counts using \code{countFirstOrder()}
#'   \item Export functionality for kinship matrix, founders, and relationships
#' }
#'
#' @return A list with reactive components:
#' \itemize{
#'   \item \code{summaryData} - Summary statistics (nAnimals, meanMK, meanGU)
#'   \item \code{relationships} - Pairwise relationship designations from
#'     \code{convertRelationships()}
#'   \item \code{relationClasses} - Relationship class frequency table from
#'     \code{makeRelationClassesTable()}
#'   \item \code{firstOrderCounts} - First-order relative counts per animal from
#'     \code{countFirstOrder()}
#' }
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param geneticValues reactive returning genetic value analysis results.
#'   Must be a data frame with columns \code{id}, \code{meanKinship}, and
#'   \code{genomeUniqueness}. Optional \code{zScore} column enables z-score plots.
#' @param pedigree reactive returning pedigree data frame with columns
#'   \code{id}, \code{sire}, \code{dam}, and \code{sex}. Optionally \code{gen}.
#' @param kinshipMatrix optional reactive returning kinship matrix. If NULL,
#'   the module will calculate kinship from the pedigree.
#'
#' @seealso \code{\link{modSummaryStatsUI}} for the user interface
#' @seealso \code{\link{convertRelationships}} for relationship classification
#' @seealso \code{\link{makeRelationClassesTable}} for relationship class summary
#' @seealso \code{\link{countFirstOrder}} for first-order relative counting
#' @seealso \code{\link{kinship}} for kinship matrix calculation
#'
#' @importFrom shiny moduleServer reactive renderPlot renderUI downloadHandler req
#' @importFrom grDevices dev.off png
#' @importFrom graphics hist boxplot par plot.new text
#' @importFrom stats median
#' @importFrom ggplot2 ggplot aes geom_histogram geom_boxplot geom_jitter
#'   geom_vline theme_classic xlab ylab ggtitle coord_flip ggsave
#' @export
modSummaryStatsServer <- function(id, geneticValues, pedigree,
                                   kinshipMatrix = NULL) {
  moduleServer(id, function(input, output, session) {

    # ========================================
    # Box and Whisker Plot Description for Popovers
    # ========================================
    box_and_whisker_desc <- paste0(
      "The upper whisker extends from the hinge to ",
      "the largest value no further than 1.5 * IQR ",
      "from the hinge (where IQR is the ",
      "inter-quartile range, or distance between ",
      "the first and third quartiles). The lower ",
      "whisker extends from the hinge to the ",
      "smallest value at most 1.5 * IQR of the ",
      "hinge. Data beyond the end of the whiskers ",
      "are called \"outlying\" points and are plotted ",
      "individually."
    )

    # Add popovers to boxplot outputs
    shinyBS::addPopover(
      session,
      id = session$ns("mkBox"),
      title = "Mean Kinship Coefficients",
      content = box_and_whisker_desc,
      placement = "bottom",
      trigger = "hover"
    )

    shinyBS::addPopover(
      session,
      id = session$ns("zscoreBox"),
      title = "Z-scores",
      content = box_and_whisker_desc,
      placement = "bottom",
      trigger = "hover"
    )

    shinyBS::addPopover(
      session,
      id = session$ns("guBox"),
      title = "Genome Uniqueness",
      content = box_and_whisker_desc,
      placement = "bottom",
      trigger = "hover"
    )

    # Helper: Ensure pedigree is a data.frame (not data.table)
    # Some functions like countFirstOrder use data.frame-specific syntax
    asDataFrame <- function(x) {
      if (inherits(x, "data.table")) {
        as.data.frame(x)
      } else {
        x
      }
    }

    # Helper: Get or calculate kinship matrix
    getKinshipMatrix <- reactive({
      req(pedigree())
      ped <- asDataFrame(pedigree())

      # Try to use provided kinship matrix
      if (!is.null(kinshipMatrix)) {
        kmat <- tryCatch(kinshipMatrix(), error = function(e) NULL)
        if (!is.null(kmat)) {
          return(kmat)
        }
      }

      # Calculate kinship from pedigree if not provided
      if (!"gen" %in% names(ped)) {
        ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
      }
      kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
    })

    # Relationship designation using convertRelationships
    relationshipData <- reactive({
      req(pedigree())
      ped <- asDataFrame(pedigree())
      kmat <- getKinshipMatrix()
      convertRelationships(kmat, ped)
    })

    # Relationship class summary using makeRelationClassesTable
    relationClassData <- reactive({
      rels <- relationshipData()
      makeRelationClassesTable(rels)
    })

    # First-order relative counts using countFirstOrder
    firstOrderData <- reactive({
      req(pedigree())
      ped <- asDataFrame(pedigree())
      countFirstOrder(ped, NULL)
    })

    # ========================================
    # ggplot2-based Histogram Reactives
    # ========================================

    # Mean Kinship Histogram (ggplot2)
    mkHistogramPlot <- reactive({
      req(geneticValues())
      gv <- geneticValues()
      mk <- gv$meanKinship
      avg <- mean(mk, na.rm = TRUE)
      brx <- pretty(range(mk, na.rm = TRUE), 25L)

      ggplot2::ggplot(data.frame(mk = mk), ggplot2::aes(x = mk)) +
        ggplot2::geom_histogram(
          bins = 25L,
          color = "darkblue",
          fill = "lightblue",
          breaks = brx
        ) +
        ggplot2::theme_classic() +
        ggplot2::xlab("Kinship") +
        ggplot2::ylab("Frequency") +
        ggplot2::ggtitle("Distribution of Individual Mean Kinship Coefficients") +
        ggplot2::geom_vline(ggplot2::aes(xintercept = avg),
                   color = "red",
                   linetype = "dashed")
    })

    # Z-Score Histogram (ggplot2)
    zscoreHistogramPlot <- reactive({
      req(geneticValues())
      gv <- geneticValues()

      # Handle missing zScore column
      if (!"zScore" %in% names(gv)) {
        return(NULL)
      }

      z <- gv$zScore
      avg <- mean(z, na.rm = TRUE)
      brx <- pretty(range(z, na.rm = TRUE), 25L)

      ggplot2::ggplot(data.frame(z = z), ggplot2::aes(x = z)) +
        ggplot2::geom_histogram(
          bins = 25L,
          color = "darkblue",
          fill = "lightblue",
          breaks = brx
        ) +
        ggplot2::theme_classic() +
        ggplot2::xlab("Z-Score") +
        ggplot2::ylab("Frequency") +
        ggplot2::ggtitle("Distribution of Mean Kinship Coefficients Z-scores") +
        ggplot2::geom_vline(ggplot2::aes(xintercept = avg),
                   color = "red",
                   linetype = "dashed")
    })

    # Genome Uniqueness Histogram (ggplot2)
    guHistogramPlot <- reactive({
      req(geneticValues())
      gv <- geneticValues()
      gu <- gv$genomeUniqueness
      avg <- mean(gu, na.rm = TRUE)
      brx <- pretty(range(gu, na.rm = TRUE), 25L)

      ggplot2::ggplot(data.frame(gu = gu), ggplot2::aes(x = gu)) +
        ggplot2::geom_histogram(
          color = "darkblue",
          fill = "lightblue",
          breaks = brx
        ) +
        ggplot2::theme_classic() +
        ggplot2::xlab("Genome Uniqueness Score") +
        ggplot2::ylab("Frequency") +
        ggplot2::ggtitle("Distribution of Genome Uniqueness") +
        ggplot2::geom_vline(ggplot2::aes(xintercept = avg),
                   color = "red",
                   linetype = "dashed")
    })

    # ========================================
    # ggplot2-based Boxplot Reactives
    # ========================================

    # Mean Kinship Boxplot (ggplot2)
    meanKinshipBoxPlotGG <- reactive({
      req(geneticValues())
      gv <- geneticValues()
      mk <- gv$meanKinship

      ggplot2::ggplot(data.frame(mk = mk), ggplot2::aes(x = 0L, y = mk)) +
        ggplot2::geom_boxplot(
          color = "darkblue",
          fill = "lightblue",
          notch = FALSE,
          outlier.color = "red",
          outlier.shape = 1L
        ) +
        ggplot2::geom_jitter(width = 0.2) +
        ggplot2::theme_classic() +
        ggplot2::coord_flip() +
        ggplot2::ylab("Kinship") +
        ggplot2::xlab("") +
        ggplot2::ggtitle("Boxplot of Individual Mean Kinship Coefficients")
    })

    # Z-Score Boxplot (ggplot2)
    zscoreBoxPlotGG <- reactive({
      req(geneticValues())
      gv <- geneticValues()

      # Handle missing zScore column
      if (!"zScore" %in% names(gv)) {
        return(NULL)
      }

      z <- gv$zScore

      ggplot2::ggplot(data.frame(z = z), ggplot2::aes(x = 0L, y = z)) +
        ggplot2::geom_boxplot(
          color = "darkblue",
          fill = "lightblue",
          notch = FALSE,
          outlier.color = "red",
          outlier.shape = 1L
        ) +
        ggplot2::geom_jitter(width = 0.2) +
        ggplot2::theme_classic() +
        ggplot2::coord_flip() +
        ggplot2::ylab("Z-Score") +
        ggplot2::xlab("") +
        ggplot2::ggtitle("Boxplot of Mean Kinship Coefficients Z-scores")
    })

    # Genome Uniqueness Boxplot (ggplot2)
    guBoxPlotGG <- reactive({
      req(geneticValues())
      gv <- geneticValues()
      gu <- gv$genomeUniqueness

      ggplot2::ggplot(data.frame(gu = gu), ggplot2::aes(x = 0L, y = gu)) +
        ggplot2::geom_boxplot(
          color = "darkblue",
          fill = "lightblue",
          notch = FALSE,
          outlier.color = "red",
          outlier.shape = 1L
        ) +
        ggplot2::geom_jitter(width = 0.2) +
        ggplot2::theme_classic() +
        ggplot2::coord_flip() +
        ggplot2::ylab("Genome Uniqueness") +
        ggplot2::xlab("") +
        ggplot2::ggtitle("Boxplot of Genome Uniqueness")
    })

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

    # Mean Kinship Histogram (using ggplot2)
    output$mkHist <- renderPlot({
      mkHistogramPlot()
    })

    # Z-Score Histogram (using ggplot2)
    output$zscoreHist <- renderPlot({
      plot <- zscoreHistogramPlot()
      if (is.null(plot)) {
        plot.new()
        text(0.5, 0.5, "Z-scores not available")
      } else {
        plot
      }
    })

    # Genome Uniqueness Histogram (using ggplot2)
    output$guHist <- renderPlot({
      guHistogramPlot()
    })

    # Mean Kinship Box Plot (using ggplot2)
    output$mkBox <- renderPlot({
      meanKinshipBoxPlotGG()
    })

    # Z-Score Box Plot (using ggplot2)
    output$zscoreBox <- renderPlot({
      plot <- zscoreBoxPlotGG()
      if (is.null(plot)) {
        plot.new()
        text(0.5, 0.5, "Z-scores not available")
      } else {
        plot
      }
    })

    # Genome Uniqueness Box Plot (using ggplot2)
    output$guBox <- renderPlot({
      guBoxPlotGG()
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
        req(pedigree())
        counts <- firstOrderData()
        write.csv(counts, file, row.names = FALSE)
      }
    )

    output$downloadRelationships <- downloadHandler(
      filename = function() paste0("relationships_", Sys.Date(), ".csv"),
      content = function(file) {
        rels <- relationshipData()
        write.csv(rels, file, row.names = FALSE)
      }
    )

    output$downloadRelationClasses <- downloadHandler(
      filename = function() paste0("relationship_classes_", Sys.Date(), ".csv"),
      content = function(file) {
        classes <- relationClassData()
        write.csv(classes, file, row.names = FALSE)
      }
    )

    # Plot download handlers (using ggplot2 reactives)
    output$downloadMkHist <- downloadHandler(
      filename = function() paste0("mk_histogram_", Sys.Date(), ".png"),
      content = function(file) {
        ggplot2::ggsave(file, plot = mkHistogramPlot(),
                        width = 8, height = 6, dpi = 100)
      }
    )

    output$downloadZscoreHist <- downloadHandler(
      filename = function() paste0("zscore_histogram_", Sys.Date(), ".png"),
      content = function(file) {
        plot <- zscoreHistogramPlot()
        if (!is.null(plot)) {
          ggplot2::ggsave(file, plot = plot, width = 8, height = 6, dpi = 100)
        }
      }
    )

    output$downloadGuHist <- downloadHandler(
      filename = function() paste0("gu_histogram_", Sys.Date(), ".png"),
      content = function(file) {
        ggplot2::ggsave(file, plot = guHistogramPlot(),
                        width = 8, height = 6, dpi = 100)
      }
    )

    output$downloadMkBox <- downloadHandler(
      filename = function() paste0("mk_boxplot_", Sys.Date(), ".png"),
      content = function(file) {
        ggplot2::ggsave(file, plot = meanKinshipBoxPlotGG(),
                        width = 8, height = 6, dpi = 100)
      }
    )

    output$downloadZscoreBox <- downloadHandler(
      filename = function() paste0("zscore_boxplot_", Sys.Date(), ".png"),
      content = function(file) {
        plot <- zscoreBoxPlotGG()
        if (!is.null(plot)) {
          ggplot2::ggsave(file, plot = plot, width = 8, height = 6, dpi = 100)
        }
      }
    )

    output$downloadGuBox <- downloadHandler(
      filename = function() paste0("gu_boxplot_", Sys.Date(), ".png"),
      content = function(file) {
        ggplot2::ggsave(file, plot = guBoxPlotGG(),
                        width = 8, height = 6, dpi = 100)
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
      }),
      relationships = reactive({ relationshipData() }),
      relationClasses = reactive({ relationClassData() }),
      firstOrderCounts = reactive({ firstOrderData() }),
      # ggplot2-based plot reactives for download handlers
      mkHistogram = reactive({ mkHistogramPlot() }),
      zscoreHistogram = reactive({ zscoreHistogramPlot() }),
      guHistogram = reactive({ guHistogramPlot() }),
      meanKinshipBoxPlot = reactive({ meanKinshipBoxPlotGG() }),
      zscoreBoxPlot = reactive({ zscoreBoxPlotGG() }),
      guBoxPlot = reactive({ guBoxPlotGG() })
    ))
  })
}
