# Summary Statistics Shiny Module

# Global variables used in ggplot2 aes() calls
utils::globalVariables(c("x", "y"))

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
#' @importFrom shiny NS div h3 fluidRow column br downloadButton plotOutput
#' @importFrom shiny htmlOutput withMathJax includeHTML
#' @export
modSummaryStatsUI <- function(id) {
  ns <- NS(id)

  div(
    id = ns("moduleContainer"),
    `data-ready` = "false",
    `data-module` = "summaryStats",

    h3("Summary Statistics and Plots"),

    # Summary stats HTML guidance at top
    fluidRow(
      column(
        10L,
        offset = 1L,
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
      column(2L, offset = 1L,
             shinyBS::popify(
               downloadButton(ns("downloadKinship"), "Export Kinship Matrix"),
               title = NULL,
               content = paste0(
                 "This exports the kinship matrix to a CSV file ",
                 "in the user selected directory."
               )
             )),
      column(2L,
             shinyBS::popify(
               downloadButton(ns("downloadMaleFounders"),
                              "Export Male Founders"),
               title = NULL,
               content = paste0(
                 "This exports the male founder pedigree records to ",
                 "a CSV file to the user selected directory."
               )
             )),
      column(2L,
             shinyBS::popify(
               downloadButton(ns("downloadFemaleFounders"),
                              "Export Female Founders"),
               title = NULL,
               content = paste0(
                 "This exports the female founder pedigree records ",
                 "to a CSV file to the user selected directory."
               )
             )),
      column(3L,
             shinyBS::popify(
               downloadButton(ns("downloadFirstOrder"),
                              "Export First-Order Relationships"),
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
      column(3L, offset = 1L,
             shinyBS::popify(
               downloadButton(ns("downloadRelationships"),
                              "Export All Relationships"),
               title = NULL,
               content = paste0(
                 "This exports all pairwise relationship designations ",
                 "to a CSV file."
               )
             )),
      column(3L,
             shinyBS::popify(
               downloadButton(ns("downloadRelationClasses"),
                              "Export Relationship Classes"),
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
      column(10L, offset = 1L, htmlOutput(ns("summaryStats")))
    ),
    br(),

    # Plots row - Histograms on left, Box plots on right
    fluidRow(
      # Left column - Histograms
      column(
        5L,
        offset = 1L,
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
          downloadButton(ns("downloadGuHist"),
                         "Export Genome Uniqueness Histogram"),
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
        5L,
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
          downloadButton(ns("downloadGuBox"),
                         "Export Genome Uniqueness Box Plot"),
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
        10L,
        offset = 1L,
        style = paste(
          "border: 1px solid lightgray; background-color: #EDEDED;",
          "border-radius: 25px; box-shadow: 0 0 5px 2px #888; padding: 10px;"
        ),
        withMathJax(
          includeHTML(
            system.file("extdata", "ui_guidance",
                        "population_genetics_terms.html",
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
#'   \item Relationship class frequency tables using
#'         \code{makeRelationClassesTable()}
#'   \item First-order relative counts using \code{countFirstOrder()}
#'   \item Export functionality for kinship matrix, founders, and relationships
#' }
#'
#' @return A list with reactive components:
#' \itemize{
#'   \item \code{summaryData} - Summary statistics (nAnimals, meanMK, meanGU)
#'   \item \code{relationships} - Pairwise relationship designations from
#'     \code{convertRelationships()}. When \code{kinshipOverrides} are supplied,
#'     a logical \code{overridden} column flags the pairs whose kinship value
#'     came from an override (issue #13 item-3).
#'   \item \code{relationClasses} - Relationship class frequency table from
#'     \code{makeRelationClassesTable()}
#'   \item \code{firstOrderCounts} - First-order relative counts per animal from
#'     \code{countFirstOrder()}
#'   \item \code{mkSummary} - Six-number summary of mean kinship
#'   \item \code{guSummary} - Six-number summary of genome uniqueness
#' }
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param geneticValues reactive returning genetic value analysis results.
#'   Must be a data frame with columns \code{id}, \code{meanKinship}, and
#'   \code{genomeUniqueness}. Optional \code{zScore} column enables z-score
#'    plots.
#' @param pedigree reactive returning pedigree data frame with columns
#'   \code{id}, \code{sire}, \code{dam}, and \code{sex}. Optionally \code{gen}.
#' @param kinshipMatrix optional reactive returning kinship matrix. If NULL,
#'   the module will calculate kinship from the pedigree.
#' @param founderStats optional reactive returning a list of founder statistics
#'   (\code{fe}, \code{fg}, \code{total}, \code{nMaleFounders},
#'   \code{nFemaleFounders}). When supplied, a founder summary table is rendered
#'   on the Summary Statistics tab (monolith parity). If NULL, it is omitted.
#' @param kinshipOverrides optional reactive returning a validated
#'   outside-information kinship-override data frame (\code{id1}, \code{id2},
#'   \code{kinship}); see \code{\link{applyKinshipOverrides}} (issue #13).
#'   When the module recomputes kinship from the pedigree (the usual path), the
#'   overrides are applied to that matrix, so the relationship table and the
#'   kinship CSV export reflect the supplied values regardless of tab order.
#'   The override moves the kinship \emph{value} only; the \code{relation}
#'   \emph{label} stays pedigree-derived (it is computed from pedigree structure,
#'   not from the kinship value). Overridden pairs are flagged with a logical
#'   \code{overridden} column in the relationship table (issue #13 item-3).
#'   \code{NULL} (the default) is a no-op.
#'
#' @seealso \code{\link{modSummaryStatsUI}} for the user interface
#' @seealso \code{\link{convertRelationships}} for relationship classification
#' @seealso \code{\link{makeRelationClassesTable}} for relationship class
#'          summary
#' @seealso \code{\link{countFirstOrder}} for first-order relative counting
#' @seealso \code{\link{kinship}} for kinship matrix calculation
#'
#' @importFrom shiny moduleServer reactive renderPlot renderUI downloadHandler
#' @importFrom shiny req
#' @importFrom grDevices dev.off png
#' @importFrom graphics hist boxplot par plot.new text
#' @importFrom stats median
#' @importFrom ggplot2 ggplot aes geom_histogram geom_boxplot geom_jitter
#' @importFrom ggplot2 geom_vline theme_classic xlab ylab ggtitle coord_flip
#' @importFrom ggplot2 ggsave
#' @export
modSummaryStatsServer <- function(id, geneticValues, pedigree,
                                   kinshipMatrix = NULL, founderStats = NULL,
                                   kinshipOverrides = NULL) {
  moduleServer(id, function(input, output, session) {

    # ========================================
    # Box and Whisker Plot Description for Popovers
    # ========================================
    box_and_whisker_desc <- getBoxWhiskerDescription()

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

      # Calculate kinship from pedigree if not provided (the fallback recompute,
      # the path the app always takes since appServer passes kinshipMatrix=NULL).
      # Issue #13 Slice 3: apply outside-information kinship overrides to this
      # matrix so the relationship table and the kinship CSV export reflect them
      # regardless of tab order. The passed-kinshipMatrix branch above already
      # carries overrides. Ids absent from the matrix are warn-dropped, never
      # aborting the module (D5). The override moves the kinship VALUE; the
      # relation LABEL stays pedigree-derived (convertRelationships is structural).
      if (!"gen" %in% names(ped)) {
        ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
      }
      kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
      overrides <- if (is.null(kinshipOverrides)) NULL else kinshipOverrides()
      applyKinshipOverridesToMatrix(kmat, overrides)
    })

    # Relationship designation using convertRelationships. Issue #13 item-3
    # (R13): the relation LABEL is pedigree-derived, but the kinship VALUE can
    # be overridden, so flag pairs whose value came from an override (the flag
    # column appears only when overrides are supplied; D10 otherwise).
    relationshipData <- reactive({
      req(pedigree())
      ped <- asDataFrame(pedigree())
      kmat <- getKinshipMatrix()
      rel <- convertRelationships(kmat, ped)
      overrides <- if (is.null(kinshipOverrides)) NULL else kinshipOverrides()
      flagOverriddenRelationships(rel, overrides)
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
        ggplot2::ggtitle(
          "Distribution of Individual Mean Kinship Coefficients") +
        ggplot2::geom_vline(ggplot2::aes(xintercept = avg),
                   color = "red",
                   linetype = "dashed")
    })

    # Z-Score Histogram (ggplot2)
    zscoreHistogramPlot <- reactive({
      req(geneticValues())
      gv <- geneticValues()

      # reportGV emits "zScores" (plural); accept the legacy "zScore" too.
      zCol <- if ("zScores" %in% names(gv)) {
        "zScores"
      } else if ("zScore" %in% names(gv)) {
        "zScore"
      } else {
        NULL
      }
      if (is.null(zCol)) {
        return(NULL)
      }

      z <- gv[[zCol]]
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
      if (!"meanKinship" %in% names(gv)) return(NULL)
      mk <- gv$meanKinship

      df <- data.frame(x = "", y = mk)
      ggplot2::ggplot(df, ggplot2::aes(x = x, y = y)) +
        ggplot2::geom_boxplot(
          color = "darkblue",
          fill = "lightblue",
          notch = FALSE,
          outlier.color = "red",
          outlier.shape = 1L
        ) +
        ggplot2::geom_jitter(ggplot2::aes(y = y), width = 0.2) +
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

      # reportGV emits "zScores" (plural); accept the legacy "zScore" too.
      zCol <- if ("zScores" %in% names(gv)) {
        "zScores"
      } else if ("zScore" %in% names(gv)) {
        "zScore"
      } else {
        NULL
      }
      if (is.null(zCol)) {
        return(NULL)
      }

      z <- gv[[zCol]]
      df <- data.frame(x = "", y = z)

      ggplot2::ggplot(df, ggplot2::aes(x = x, y = y)) +
        ggplot2::geom_boxplot(
          color = "darkblue",
          fill = "lightblue",
          notch = FALSE,
          outlier.color = "red",
          outlier.shape = 1L
        ) +
        ggplot2::geom_jitter(ggplot2::aes(y = y), width = 0.2) +
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
      if (!"genomeUniqueness" %in% names(gv)) return(NULL)
      gu <- gv$genomeUniqueness

      df <- data.frame(x = "", y = gu)
      ggplot2::ggplot(df, ggplot2::aes(x = x, y = y)) +
        ggplot2::geom_boxplot(
          color = "darkblue",
          fill = "lightblue",
          notch = FALSE,
          outlier.color = "red",
          outlier.shape = 1L
        ) +
        ggplot2::geom_jitter(ggplot2::aes(y = y), width = 0.2) +
        ggplot2::theme_classic() +
        ggplot2::coord_flip() +
        ggplot2::ylab("Genome Uniqueness") +
        ggplot2::xlab("") +
        ggplot2::ggtitle("Boxplot of Genome Uniqueness")
    })

    # Six-number summaries of mean kinship and genome uniqueness
    # (monolith Summary Statistics tab parity, server.r:545-630)
    mkSummaryData <- reactive({
      req(geneticValues())
      summary(geneticValues()$meanKinship)
    })

    guSummaryData <- reactive({
      req(geneticValues())
      summary(geneticValues()$genomeUniqueness)
    })

    # One distribution-table row: label + Min/1stQ/Mean/Median/3rdQ/Max
    quartileRow <- function(label, s) {
      tags$tr(
        tags$td(label),
        tags$td(sprintf("%.4f", s["Min."])),
        tags$td(sprintf("%.4f", s["1st Qu."])),
        tags$td(sprintf("%.4f", s["Mean"])),
        tags$td(sprintf("%.4f", s["Median"])),
        tags$td(sprintf("%.4f", s["3rd Qu."])),
        tags$td(sprintf("%.4f", s["Max."]))
      )
    }

    # Summary statistics HTML output
    output$summaryStats <- renderUI({
      req(geneticValues())
      gv <- geneticValues()
      fs <- if (!is.null(founderStats)) founderStats() else NULL

      # Founder summary table (Known/Female/Male counts + FE + FG), rendered
      # only when founderStats is threaded in (monolith server.r:558-570).
      founderTbl <- if (!is.null(fs)) {
        tags$table(
          class = "display",
          tags$thead(tags$tr(
            tags$th("Known Founders"),
            tags$th("Known Female Founders"),
            tags$th("Known Male Founders"),
            tags$th("Founder Equivalents"),
            tags$th("Founder Genome Equivalents")
          )),
          tags$tbody(tags$tr(
            tags$td(as.character(fs$total)),
            tags$td(as.character(fs$nFemaleFounders)),
            tags$td(as.character(fs$nMaleFounders)),
            tags$td(sprintf("%.2f", fs$fe)),
            # Issue #82 Slice 3: founder genome equivalents inline with its
            # sampling SE when a finite fgSE is threaded through founderStats();
            # otherwise the bare FG.
            tags$td(
              if (!is.null(fs$fgSE) && is.finite(fs$fgSE)) {
                # nolint start: nonportable_path_linter.
                sprintf("%.2f +/- %.2f", fs$fg, fs$fgSE)
                # nolint end: nonportable_path_linter.
              } else {
                sprintf("%.2f", fs$fg)
              }
            )
          ))
        )
      }

      # Mean-kinship / genome-uniqueness quartile distribution tables.
      distTbl <- tags$table(
        class = "display",
        tags$thead(tags$tr(
          tags$th(""),
          tags$th("Min"),
          tags$th("1st Quartile"),
          tags$th("Mean"),
          tags$th("Median"),
          tags$th("3rd Quartile"),
          tags$th("Max")
        )),
        tags$tbody(
          quartileRow("Mean Kinship", mkSummaryData()),
          quartileRow("Genome Uniqueness", guSummaryData())
        )
      )

      div(
        h4("Population Summary"),
        tags$ul(
          tags$li(paste("Animals analyzed:", nrow(gv))),
          tags$li(paste("Mean kinship (average):",
                        sprintf("%.4f", mean(gv$meanKinship, na.rm = TRUE)))),
          tags$li(paste("Genome uniqueness (average):",
                        sprintf("%.4f", mean(gv$genomeUniqueness,
                                             na.rm = TRUE))))
        ),
        founderTbl,
        br(),
        distTbl
      )
    })

    # Signal data-ready when summary stats are available (for E2E testing)
    observe({
      req(geneticValues())
      session$sendCustomMessage("setDataReady", list(
        selector = paste0("#", session$ns("moduleContainer")),
        ready = TRUE
      ))
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
        write.csv(getKinshipMatrix(), file)
      }
    )

    output$downloadMaleFounders <- downloadHandler(
      filename = function() paste0("male_founders_", Sys.Date(), ".csv"),
      content = function(file) {
        req(pedigree())
        ped <- pedigree()
        males <- ped[ped$sex == "M" & isFounder(ped), ]
        write.csv(males, file, row.names = FALSE)
      }
    )

    output$downloadFemaleFounders <- downloadHandler(
      filename = function() paste0("female_founders_", Sys.Date(), ".csv"),
      content = function(file) {
        req(pedigree())
        ped <- pedigree()
        females <- ped[ped$sex == "F" & isFounder(ped), ]
        write.csv(females, file, row.names = FALSE)
      }
    )

    output$downloadFirstOrder <- downloadHandler(
      filename = function() {
        paste0("first_order_relationships_", Sys.Date(), ".csv")
      },
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
      filename = function() {
        paste0("relationship_classes_", Sys.Date(), ".csv")
      },
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
                        width = 8L, height = 6L, dpi = 100L)
      }
    )

    output$downloadZscoreHist <- downloadHandler(
      filename = function() paste0("zscore_histogram_", Sys.Date(), ".png"),
      content = function(file) {
        plot <- zscoreHistogramPlot()
        if (!is.null(plot)) {
          ggplot2::ggsave(file, plot = plot, width = 8L, height = 6L,
                          dpi = 100L)
        }
      }
    )

    output$downloadGuHist <- downloadHandler(
      filename = function() paste0("gu_histogram_", Sys.Date(), ".png"),
      content = function(file) {
        ggplot2::ggsave(file, plot = guHistogramPlot(),
                        width = 8L, height = 6L, dpi = 100L)
      }
    )

    output$downloadMkBox <- downloadHandler(
      filename = function() paste0("mk_boxplot_", Sys.Date(), ".png"),
      content = function(file) {
        ggplot2::ggsave(file, plot = meanKinshipBoxPlotGG(),
                        width = 8L, height = 6L, dpi = 100L)
      }
    )

    output$downloadZscoreBox <- downloadHandler(
      filename = function() paste0("zscore_boxplot_", Sys.Date(), ".png"),
      content = function(file) {
        plot <- zscoreBoxPlotGG()
        if (!is.null(plot)) {
          ggplot2::ggsave(file, plot = plot, width = 8L, height = 6L,
                          dpi = 100L)
        }
      }
    )

    output$downloadGuBox <- downloadHandler(
      filename = function() paste0("gu_boxplot_", Sys.Date(), ".png"),
      content = function(file) {
        ggplot2::ggsave(file, plot = guBoxPlotGG(),
                        width = 8L, height = 6L, dpi = 100L)
      }
    )

    # Return reactive values for use by other modules
    list(
      summaryData = reactive({
        req(geneticValues())
        gv <- geneticValues()
        list(
          nAnimals = nrow(gv),
          meanMK = mean(gv$meanKinship, na.rm = TRUE),
          meanGU = mean(gv$genomeUniqueness, na.rm = TRUE)
        )
      }),
      relationships = reactive(relationshipData()),
      relationClasses = reactive(relationClassData()),
      firstOrderCounts = reactive(firstOrderData()),
      mkSummary = mkSummaryData,
      guSummary = guSummaryData,
      # ggplot2-based plot reactives for download handlers
      mkHistogram = reactive(mkHistogramPlot()),
      zscoreHistogram = reactive(zscoreHistogramPlot()),
      guHistogram = reactive(guHistogramPlot()),
      meanKinshipBoxPlot = reactive(meanKinshipBoxPlotGG()),
      zscoreBoxPlot = reactive(zscoreBoxPlotGG()),
      guBoxPlot = reactive(guBoxPlotGG())
    )
  })
}
