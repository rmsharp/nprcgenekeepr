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
#' @importFrom shiny NS div h3 fluidRow column wellPanel h4 icon numericInput
#' @importFrom shiny checkboxInput sliderInput actionButton tabsetPanel tabPanel
#' @importFrom shiny br downloadButton plotOutput tableOutput includeHTML
#' @export
modGeneticValueUI <- function(id) {
  ns <- NS(id)

  div(
    id = ns("moduleContainer"),
    `data-ready` = "false",
    `data-module` = "geneticValue",

    h3("Genetic Value Analysis"),
    fluidRow(
      column(4L,
             wellPanel(
               h4(icon("dna"), "Analysis Options"),
               numericInput(ns("nIterations"), "Gene Drop Iterations:",
                            value = 1000L, min = 100L, max = 10000L,
                            step = 100L),
               selectInput(ns("threshold"),
                           "Genome Uniqueness Threshold:",
                           choices = c(1L, 2L, 3L, 4L, 5L), selected = 4L),
               checkboxInput(ns("calcGenomeUniqueness"),
                             "Calculate Genome Uniqueness", TRUE),
               checkboxInput(ns("calcMeanKinship"),
                             "Calculate Mean Kinship", TRUE),
               actionButton(ns("runAnalysis"), "Run Analysis",
                            icon = icon("play"),
                            class = "btn-primary btn-block")
             ),
             wellPanel(
               h5(icon("file-csv"), "Kinship Overrides (optional)"),
               helpText(
                 "Upload outside-information kinship as a CSV or Excel file",
                 "with columns id1, id2, kinship. kinship is the coefficient",
                 "f (not relatedness r = 2f). Leave empty to use",
                 "pedigree-derived kinship."
               ),
               fileInput(ns("kinshipOverrideFile"),
                         label = NULL,
                         accept = c(".csv", ".txt", ".xlsx", ".xls")),
               helpText(
                 strong("How overrides are used and their limits:"),
                 paste("Overrides change the kinship value for the listed",
                       "pair only, and apply to the rankings, breeding",
                       "groups, and summary statistics regardless of tab",
                       "order."),
                 paste("In the Summary Statistics relationship table the",
                       "relationship label stays pedigree-derived, so the",
                       "label and the overridden value can disagree."),
                 paste("The gene-drop convergence diagnostic gvaConvergence()",
                       "applies these overrides as well, ranking on the",
                       "overridden kinship."),
                 paste("For an animal missing one parent, add an optional",
                       "missingSideFor column naming that animal when the",
                       "override stands in for its missing parent's side, so",
                       "its unknown-parent kinship correction is dropped only",
                       "then; leave it blank for a known-side override. A few",
                       "edge cases (both parents unknown, or siblings sharing",
                       "an unknown parent) remain a current limitation.")
               )
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
      column(8L,
             tabsetPanel(
               tabPanel("Rankings",
                        br(),
                        numericInput(ns("topN"), "Show top N:", value = 20L,
                                     min = 5L),
                        textAreaInput(
                          ns("viewIds"),
                          paste("Filter by IDs (comma, space, semicolon, or",
                                "newline separated; blank = all):"),
                          rows = 2L),
                        actionButton(ns("view"), "Filter View"),
                        downloadButton(ns("downloadRankings"), "Export All"),
                        downloadButton(ns("downloadGVASubset"),
                                       "Export Subset"),
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
#' @param speciesOverrides reactive returning the user-configurable species
#' overrides loaded at boot by \code{\link{loadSpeciesOverrides}} (a list with
#' \code{breedingTable}, \code{gestationTable}, \code{breedingAgeDefault},
#' \code{gestationDefault}), or \code{NULL}. Threaded into
#' \code{\link{reportGV}} (issue #73 Part 2). Defaults to \code{reactive(NULL)}
#' so no config file means bundled behavior.
#'
#' @seealso \code{\link{modGeneticValueUI}}
#' @seealso \code{\link{modBreedingGroupsServer}} for using results.
#'
#' @references
#' Lacy, R.C. (1989) \emph{Zoo Biology}, \strong{8}, 111-123.
#'
#' @importFrom shiny moduleServer reactive eventReactive withProgress
#' @importFrom shiny incProgress
#' @export
modGeneticValueServer <- function(id, pedigree,
                                  speciesOverrides = reactive(NULL)) {
  moduleServer(id, function(input, output, session) {

    # Store full reportGV results
    fullResults <- reactiveVal(NULL)

    # Genome-uniqueness threshold (monolith parity: default 4, user-selectable).
    # Threaded as guThresh into reportGV, replacing the former hardcoded 1L.
    guThreshold <- reactive({
      thr <- input$threshold
      if (is.null(thr)) 4L else as.integer(thr)
    })

    # Issue #13 Slice 2: read an uploaded outside-information kinship override
    # file (id1, id2, kinship) and validate it. Soft / non-fatal in the app
    # (D5): a bad file warns and is ignored; the GV run is never aborted. A
    # > 0.5 warning (valid only for inbred pairs; D6) is surfaced but the
    # override is still applied. Returns NULL when no file is uploaded or the
    # file cannot be read -- NULL keeps reportGV() on the pedigree-derived
    # matrix. Uses an explicit is.null() guard rather than req() so that calling
    # it from gvResults() never aborts the analysis when no file is present.
    kinshipOverrideData <- reactive({
      if (is.null(input$kinshipOverrideFile)) {
        return(NULL)
      }
      tryCatch(
        withCallingHandlers(
          checkKinshipOverrides(
            readKinshipOverrides(input$kinshipOverrideFile$datapath)
          ),
          warning = function(w) {
            showNotification(
              paste("Kinship override warning:", conditionMessage(w)),
              type = "warning", duration = 10L
            )
            invokeRestart("muffleWarning")
          }
        ),
        error = function(e) {
          showNotification(
            paste("Could not read kinship overrides:", conditionMessage(e)),
            type = "error", duration = 10L
          )
          NULL
        }
      )
    })

    gvResults <- eventReactive(input$runAnalysis, {
      req(pedigree())

      # E2E determinism hook (gated; no-op in production). See gatedSeed().
      gatedSeed("nprcgenekeepr.gva_seed", "NPRC_GVA_SEED") # nolint: object_usage_linter

      withProgress(message = "Running genetic value analysis...", {
        ped <- pedigree()

        # Create progress update function compatible with reportGV
        updateProgress <- function(n = 1L, detail = NULL, value = 0L,
                                   reset = FALSE) {
          if (reset) {
            incProgress(0.0, detail = detail)
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

        # Issue #73 Part 2: thread the user-configurable species overrides
        # (loaded at boot from the config file) into reportGV. NULL fields (no
        # config, or no override) leave reportGV on the bundled defaults.
        ov <- speciesOverrides()

        # Call the real reportGV function
        gvReport <- reportGV(
          ped,
          guIter = input$nIterations,
          guThresh = guThreshold(),
          byID = TRUE,
          updateProgress = updateProgress,
          breedingTable = ov$breedingTable,
          gestationTable = ov$gestationTable,
          breedingAgeDefault = ov$breedingAgeDefault,
          gestationDefault = ov$gestationDefault,
          kinshipOverrides = kinshipOverrideData()
        )

        # Store full results
        fullResults(gvReport)

        # Return the report data frame with added rank column
        report <- gvReport$report
        if (!"indivMeanKin" %in% names(report)) {
          # Handle edge case where report might not have expected columns
          return(report)
        }

        # Add rank based on genetic value (low kinship + high uniqueness).
        # Issue #9 Slice 3 (D7): both-unknown founders lacking a recorded origin
        # are flagged "Undetermined" by orderReport. Rank them LAST so the
        # genome uniqueness inflation no longer pins them to the top of the
        # displayed table; imports, one-unknown, known animals rank normally.
        report$rank <- rank(report$indivMeanKin - report$gu)
        demote <- if ("value" %in% names(report)) {
          !is.na(report$value) & report$value == "Undetermined"
        } else {
          rep(FALSE, nrow(report))
        }
        report <- report[order(demote, report$rank), ]
        report$rank <- seq_len(nrow(report))

        # Signal that genetic value analysis is complete (for E2E testing)
        session$sendCustomMessage("setDataReady", list(
          selector = paste0("#", session$ns("moduleContainer")),
          ready = TRUE
        ))

        report
      })
    })

    # Subset/filter view (monolith parity: gvaView/filterReport). When "Filter
    # View" is pressed with one or more IDs, restrict the report to those rows;
    # otherwise (button unpressed or no IDs entered) the full report.
    gvaView <- reactive({
      rpt <- gvResults()
      if (is.null(rpt)) {
        return(NULL)
      }
      if (is.null(input$view) || input$view == 0L) {
        return(rpt)
      }
      ids <- unlist(strsplit(isolate(input$viewIds), "[ ,;\t\n]"))
      ids <- ids[nzchar(trimws(ids))]
      if (length(ids) == 0L) {
        return(rpt)
      }
      filterReport(ids, rpt)
    })

    output$rankingsTable <- DT::renderDT({
      req(gvaView())
      data <- gvaView()
      if (input$topN < nrow(data)) data <- data[1L:input$topN, ]
      data
    })

    output$gvSummary <- renderTable({
      req(gvResults())
      results <- gvResults()
      fullRes <- fullResults()

      # Use indivMeanKin and gu column names from reportGV
      mkCol <- if ("indivMeanKin" %in% names(results))
                 "indivMeanKin"
               else
                 "meanKinship"
      guCol <- if ("gu" %in% names(results)) "gu" else "genomeUniqueness"

      summaryData <- data.frame(
        Metric = c("Animals Analyzed", "Mean Kinship (avg)",
                   "Genome Uniqueness (avg)"),
        Value = c(nrow(results),
                  sprintf("%.4f", mean(results[[mkCol]], na.rm = TRUE)),
                  sprintf("%.4f", mean(results[[guCol]], na.rm = TRUE))),
        stringsAsFactors = FALSE
      )

      # Issue #2 Slice 1: report the worst-case (maximum) genome-uniqueness
      # sampling standard error so the user sees how precise the gene-drop gu
      # estimate is for the run they computed. Guarded on the column's presence.
      seCol <- if ("guSE" %in% names(results)) {
        "guSE"
      } else if ("genomeUniquenessSE" %in% names(results)) {
        "genomeUniquenessSE"
      } else {
        NULL
      }
      if (!is.null(seCol)) {
        summaryData <- rbind(
          summaryData,
          data.frame(
            Metric = "Genome Uniqueness SE (max)",
            Value = sprintf("%.4f", max(results[[seCol]], na.rm = TRUE)),
            stringsAsFactors = FALSE
          )
        )
      }

      # Add founder statistics if available
      if (!is.null(fullRes)) {
        # Issue #82 Slice 3: show founder genome equivalents inline with its
        # colony-level sampling standard error when reportGV supplied a finite
        # fgSE; otherwise the bare FG (older results / bundled objects predating
        # fgSE).
        fgDisplay <- if (!is.null(fullRes$fgSE) && is.finite(fullRes$fgSE)) {
          # nolint start: nonportable_path_linter.
          sprintf("%.2f +/- %.2f", fullRes$fg, fullRes$fgSE)
          # nolint end: nonportable_path_linter.
        } else {
          sprintf("%.2f", fullRes$fg)
        }
        founderData <- data.frame(
          Metric = c("Total Founders", "Male Founders", "Female Founders",
                     "Founder Equivalents (FE)", "Founder Genome Equiv. (FG)"),
          Value = c(as.character(fullRes$total),
                    as.character(fullRes$nMaleFounders),
                    as.character(fullRes$nFemaleFounders),
                    sprintf("%.2f", fullRes$fe),
                    fgDisplay),
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
      mkCol <- if ("indivMeanKin" %in% names(results))
                 "indivMeanKin"
               else
                 "meanKinship"
      guCol <- if ("gu" %in% names(results)) "gu" else "genomeUniqueness"

      plot(results[[mkCol]], results[[guCol]],
           xlab = "Mean Kinship", ylab = "Genome Uniqueness",
           main = "Genetic Value Analysis",
           pch = 19L, col = ifelse(results$rank <= 10L, "red", "blue"))
    })

    output$downloadRankings <- downloadHandler(
      filename = function() paste0("geneticValues_", Sys.Date(), ".csv"),
      content = function(file) write.csv(gvResults(), file, row.names = FALSE)
    )

    output$downloadGVASubset <- downloadHandler(
      filename = function() paste0("GVA_subset_", Sys.Date(), ".csv"),
      content = function(file) {
        write.csv(gvaView(), file, na = "", row.names = FALSE)
      }
    )

    list(
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
        gv[gv$rank <= 10L, ]
      }),
      nAnalyzed = reactive(nrow(gvResults())),
      kinshipMatrix = reactive({
        req(fullResults())
        fullResults()$kinship
      }),
      # Issue #13 Slice 3: expose the validated kinship-override frame (or NULL)
      # so appServer can thread it to the breeding-group and summary-stats
      # modules' fallback recompute paths. Reading the upload does not require
      # running the GV analysis, so overrides hold regardless of tab order.
      kinshipOverrides = kinshipOverrideData,
      founderStats = reactive({
        req(fullResults())
        fr <- fullResults()
        list(
          fe = fr$fe,
          fg = fr$fg,
          fgSE = fr$fgSE, # issue #82 Slice 3: scalar FG sampling SE (or NULL)
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
    )
  })
}
