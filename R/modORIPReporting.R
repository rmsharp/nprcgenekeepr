## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# ORIP Reporting Shiny Module

#' ORIP Reporting Module - UI Function
#'
#' Creates user interface for ORIP (Office of Research Infrastructure Programs)
#' reporting. This module will contain formatted reports suitable for submission
#' to ORIP as part of primate center grant reporting requirements.
#'
#' @details
#' The ORIP Reporting tab provides summary statistics and formatted reports
#' for submission to the Office of Research Infrastructure Programs. This
#' includes:
#' \itemize{
#'   \item Colony demographics summary
#'   \item Genetic diversity metrics
#'   \item Breeding program statistics
#'   \item Founder representation analysis
#' }
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @return A \code{div} object containing the ORIP reporting UI.
#'
#' @seealso \code{\link{modORIPReportingServer}} for server logic.
#' @importFrom shiny NS div h3 h4 p br fluidRow column helpText hr
#' @importFrom shiny downloadButton htmlOutput tableOutput
#' @family Shiny modules
#' @export
modORIPReportingUI <- function(id) {
  ns <- NS(id)

  div(
    h3("ORIP Reporting"),
    br(),

    # Guidance section
    fluidRow(
      column(
        10L,
        offset = 1L,
        style = paste(
          "border: 1px solid lightgray; background-color: #EDEDED;",
          "border-radius: 25px; box-shadow: 0 0 5px 2px #888; padding: 10px;"
        ),
        h4("About ORIP Reporting"),
        p("This module provides formatted reports for submission to the ",
          "Office of Research Infrastructure Programs (ORIP). Reports include ",
          "colony demographics, genetic diversity metrics, and breeding ",
          "program statistics as required for NIH primate center grants."),
        hr(),
        helpText(
          "Note: This feature is under development. Additional reporting ",
          "capabilities will be added based on ORIP requirements."
        )
      )
    ),
    br(),

    # Export buttons
    fluidRow(
      column(3L, offset = 1L,
             downloadButton(ns("downloadORIPReport"), "Export ORIP Report")),
      column(3L,
             downloadButton(ns("downloadDemographics"), "Export Demographics"))
    ),
    br(),

    # Site information section
    fluidRow(
      column(10L, offset = 1L,
             h4("Site Information"),
             htmlOutput(ns("siteInfo")))
    ),
    br(),

    # Colony summary section
    fluidRow(
      column(10L, offset = 1L,
             h4("Colony Summary"),
             tableOutput(ns("colonySummary")))
    ),
    br(),

    # Genetic diversity section
    fluidRow(
      column(10L, offset = 1L,
             h4("Genetic Diversity Metrics"),
             htmlOutput(ns("geneticDiversity")))
    ),
    br(),

    # Placeholder for future features
    fluidRow(
      column(
        10L,
        offset = 1L,
        style = paste(
          "border: 1px solid #ffc107; background-color: #fff3cd;",
          "border-radius: 10px; padding: 15px;"
        ),
        h4("Coming Soon"),
        p("Additional ORIP reporting features are under development:"),
        tags$ul(
          tags$li("Founder contribution analysis"),
          tags$li("Inbreeding trends over time"),
          tags$li("Breeding success rates"),
          tags$li("Age structure analysis"),
          tags$li("Formatted PDF report generation")
        )
      )
    )
  )
}

#' ORIP Reporting Module - Server Function
#'
#' Server logic for ORIP reporting module. Generates summary statistics
#' and formatted reports for Office of Research Infrastructure Programs
#' submissions.
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param pedigree reactive returning pedigree data frame.
#' @param geneticValues reactive returning genetic value analysis results.
#' @param siteConfig reactive returning site configuration from getSiteInfo().
#'
#' @return A list with reactive components for ORIP reporting.
#'
#' @seealso \code{\link{modORIPReportingUI}} for the user interface
#' @seealso \code{\link{getSiteInfo}} for site configuration
#'
#' @importFrom shiny moduleServer reactive renderUI renderTable downloadHandler
#' @importFrom shiny req tags
#' @importFrom utils write.csv
#' @family Shiny modules
#' @export
modORIPReportingServer <- function(id, pedigree = NULL, geneticValues = NULL,
                                    siteConfig = NULL) {
  moduleServer(id, function(input, output, session) {

    # Site information display
    output$siteInfo <- renderUI({
      config <- if (!is.null(siteConfig)) {
        tryCatch(siteConfig(), error = function(e) NULL)
      } else {
        # getSiteInfo() is wrapped in tryCatch (mirroring appServer.R's/
        # appUI.R's ORIP-gate guard, issue #50 crash class) so a
        # present-but-malformed config file can never crash THIS call site.
        # BACKLOG.md's "4 lower-severity unguarded getSiteInfo() call sites"
        # (1): unreachable via appServer.R's real wiring (it always passes a
        # non-NULL siteConfig), but reachable if this module is ever mounted
        # directly without one.
        tryCatch(
          getSiteInfo(expectConfigFile = FALSE),
          error = function(e) {
            futile.logger::flog.warn(
              "Failed to load site configuration for ORIP display: %s",
              conditionMessage(e),
              name = "nprcgenekeepr"
            )
            NULL
          }
        )
      }

      if (is.null(config)) {
        return(p("Site configuration not available"))
      }

      tags$div(
        tags$table(
          class = "table table-condensed",
          tags$tr(tags$td(tags$strong("Center:")), tags$td(config$center)),
          tags$tr(tags$td(tags$strong("Node:")), tags$td(config$nodename)),
          tags$tr(tags$td(tags$strong("User:")), tags$td(config$user)),
          tags$tr(tags$td(tags$strong("System:")),
                  tags$td(paste(config$sysname, config$release)))
        )
      )
    })

    # Colony summary table
    output$colonySummary <- renderTable({
      req(pedigree)
      ped <- tryCatch(pedigree(), error = function(e) NULL)

      if (is.null(ped) || nrow(ped) == 0L) {
        return(data.frame(
          Metric = "No data",
          Value = "Load pedigree data to see colony summary",
          stringsAsFactors = FALSE
        ))
      }

      # Calculate colony statistics
      nTotal <- nrow(ped)
      nMales <- sum(ped$sex == "M", na.rm = TRUE)
      nFemales <- sum(ped$sex == "F", na.rm = TRUE)
      nUnknown <- nTotal - nMales - nFemales

      # Founders (animals with no known parents)
      nFounders <- sum(isFounder(ped))
      nMaleFounders <- sum(isFounder(ped) & ped$sex == "M", na.rm = TRUE)
      nFemaleFounders <- sum(isFounder(ped) & ped$sex == "F", na.rm = TRUE)

      data.frame(
        Metric = c("Total Animals", "Males", "Females", "Unknown Sex",
                   "Total Founders", "Male Founders", "Female Founders"),
        Value = c(nTotal, nMales, nFemales, nUnknown,
                  nFounders, nMaleFounders, nFemaleFounders),
        stringsAsFactors = FALSE
      )
    })

    # Genetic diversity metrics
    output$geneticDiversity <- renderUI({
      req(geneticValues)
      gv <- tryCatch(geneticValues(), error = function(e) NULL)

      if (is.null(gv) || nrow(gv) == 0L) {
        return(p("Run genetic value analysis to see diversity metrics"))
      }

      # Calculate metrics
      meanMK <- mean(gv$indivMeanKin, na.rm = TRUE)
      meanGU <- mean(gv$gu, na.rm = TRUE)

      tags$div(
        tags$table(
          class = "table table-condensed",
          tags$tr(
            tags$td(tags$strong("Mean Kinship Coefficient:")),
            tags$td(sprintf("%.4f", meanMK))
          ),
          tags$tr(
            tags$td(tags$strong("Mean Genome Uniqueness:")),
            tags$td(sprintf("%.4f", meanGU))
          ),
          tags$tr(
            tags$td(tags$strong("Animals Analyzed:")),
            tags$td(nrow(gv))
          )
        )
      )
    })

    # Download ORIP Report
    output$downloadORIPReport <- downloadHandler(
      filename = function() {
        paste0("orip_report_", Sys.Date(), ".csv")
      },
      content = function(file) {
        # Compile report data
        ped <- tryCatch(pedigree(), error = function(e) NULL)
        gv <- tryCatch(geneticValues(), error = function(e) NULL)
        config <- if (!is.null(siteConfig)) {
          tryCatch(siteConfig(), error = function(e) NULL)
        } else {
          # Same getSiteInfo() guard as the siteInfo renderer above --
          # BACKLOG.md's "4 lower-severity unguarded getSiteInfo() call
          # sites" (1).
          tryCatch(
            getSiteInfo(expectConfigFile = FALSE),
            error = function(e) {
              futile.logger::flog.warn(
                "Failed to load site configuration for ORIP report export: %s",
                conditionMessage(e),
                name = "nprcgenekeepr"
              )
              NULL
            }
          )
        }

        report <- data.frame(
          Category = character(),
          Metric = character(),
          Value = character(),
          stringsAsFactors = FALSE
        )

        # Site info
        if (!is.null(config)) {
          report <- rbind(report, data.frame(
            Category = rep("Site", 3L),
            Metric = c("Center", "Node", "Report Date"),
            Value = c(config$center, config$nodename, as.character(Sys.Date())),
            stringsAsFactors = FALSE
          ))
        }

        # Colony stats
        if (!is.null(ped) && nrow(ped) > 0L) {
          report <- rbind(report, data.frame(
            Category = rep("Colony", 3L),
            Metric = c("Total Animals", "Males", "Females"),
            Value = c(
              as.character(nrow(ped)),
              as.character(sum(ped$sex == "M", na.rm = TRUE)),
              as.character(sum(ped$sex == "F", na.rm = TRUE))
            ),
            stringsAsFactors = FALSE
          ))
        }

        # Genetic diversity
        if (!is.null(gv) && nrow(gv) > 0L) {
          report <- rbind(report, data.frame(
            Category = rep("Genetic Diversity", 2L),
            Metric = c("Mean Kinship", "Mean Genome Uniqueness"),
            Value = c(
              sprintf("%.4f", mean(gv$indivMeanKin, na.rm = TRUE)),
              sprintf("%.4f", mean(gv$gu, na.rm = TRUE))
            ),
            stringsAsFactors = FALSE
          ))
        }

        write.csv(report, file, row.names = FALSE)
      }
    )

    # Download Demographics
    output$downloadDemographics <- downloadHandler(
      filename = function() {
        paste0("demographics_", Sys.Date(), ".csv")
      },
      content = function(file) {
        ped <- tryCatch(pedigree(), error = function(e) NULL)
        if (!is.null(ped)) {
          write.csv(ped, file, row.names = FALSE)
        } else {
          write.csv(data.frame(Note = "No pedigree data available"),
                    file, row.names = FALSE)
        }
      }
    )

    # Return reactive values
    list(
      colonySummary = reactive({
        req(pedigree)
        ped <- pedigree()
        list(
          nTotal = nrow(ped),
          nMales = sum(ped$sex == "M", na.rm = TRUE),
          nFemales = sum(ped$sex == "F", na.rm = TRUE),
          nFounders = sum(isFounder(ped))
        )
      })
    )
  })
}
