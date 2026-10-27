## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Genetic-Health Trends Module - UI Function
#'
#' The new top-level Genetic-Health Trends tab (issue #167 Slice 4, D7): a
#' Shiny workflow around
#' the longitudinal colony-snapshot functions already shipped in Slices 1-3
#' (\code{\link{checkSnapshotHistory}}/\code{\link{readSnapshotHistory}}/
#' \code{\link{appendColonySnapshot}}, \code{\link{createColonySnapshot}},
#' \code{\link{calcSnapshotDeltas}}/\code{\link{plotSnapshotTrends}}).
#' Upload or grow a snapshot-history CSV, generate a new dated snapshot from
#' the analysis already loaded on the Genetic Value Analysis tab, review
#' trend plots and a per-metric delta comparison (with the D4 comparability
#' flag visible), and download both the updated history and the delta
#' table. A "Build Earlier Snapshots" box rebuilds past 1 Januaries from the
#' studbook's birth and exit dates (issue #170,
#' \code{\link{backfillColonySnapshots}}), and an "Earlier Snapshots" tab shows
#' what each of those dates rests on
#' (\code{\link{previewBackfillSupport}}).
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @return A \code{div} object containing the module's UI.
#' @seealso \code{\link{modSnapshotTrendsServer}} for server logic.
#' @importFrom shiny NS div h3 h5 icon helpText wellPanel fileInput
#' @importFrom shiny sidebarLayout sidebarPanel mainPanel actionButton
#' @importFrom shiny tabsetPanel tabPanel uiOutput plotOutput downloadButton
#' @importFrom shiny selectInput br hr h4 includeHTML
#' @importFrom DT DTOutput
#' @family Shiny modules
#' @export
modSnapshotTrendsUI <- function(id) {
  ns <- NS(id)

  div(
    id = ns("moduleContainer"),
    `data-ready` = "false",
    `data-module` = "snapshotTrends",

    h3("Genetic-Health Trends"),

    sidebarLayout(
      sidebarPanel(
        helpText(
          "Record dated colony snapshots from Genetic Value Analysis runs",
          "and review genetic-health trends over time."
        ),
        wellPanel(
          h5(icon("upload"), "Snapshot History"),
          fileInput(ns("historyFile"),
                    "Upload snapshot history (CSV or Excel)",
                    accept = c(".csv", ".txt", ".xls", ".xlsx")),
          uiOutput(ns("derivedRuleUI")),
          actionButton(ns("generateSnapshot"), "Generate Snapshot",
                       icon = icon("plus"), class = "btn-primary btn-block")
        ),
        hr(),
        wellPanel(
          h5(icon("balance-scale"), "Compare Snapshots"),
          selectInput(ns("deltaRule"), "Membership rule:", choices = NULL),
          selectInput(ns("deltaFrom"), "From:", choices = NULL),
          selectInput(ns("deltaTo"), "To:", choices = NULL)
        ),
        hr(),
        wellPanel(
          h5(icon("history"), "Build Earlier Snapshots"),
          helpText(
            "Rebuild snapshots for past 1 Januaries from the birth and exit",
            "dates in the studbook, so a trend can be drawn now. They are",
            "added to the same history, marked reconstructedLiving in its",
            "membershipRule column, and drawn as their own dashed line, apart",
            "from recorded snapshots."
          ),
          selectInput(ns("backfillStart"), "Start year:", choices = NULL),
          uiOutput(ns("backfillCostUI")),
          actionButton(ns("buildBackfill"), "Build earlier snapshots",
                       icon = icon("history"), class = "btn-primary btn-block")
        )
      ),

      mainPanel(
        tabsetPanel(
          id = ns("mainTabs"),

          tabPanel(
            "History",
            icon = icon("table"),
            br(),
            DT::DTOutput(ns("historyTable")),
            br(),
            downloadButton(ns("downloadHistory"), "Download Updated History")
          ),

          tabPanel(
            "Trends",
            icon = icon("chart-area"),
            br(),
            plotOutput(ns("trendPlot"), height = "auto"),
            div(
              style = paste(
                "padding: 10px; border: 1px solid lightgray;",
                "background-color: #EDEDED; border-radius: 25px;",
                "box-shadow: 0 0 5px 2px #888; margin-top: 10px;"
              ),
              h4("Reading the trend"),
              includeHTML(
                system.file("extdata", "ui_guidance", "snapshot_trends.html",
                            package = "nprcgenekeepr")
              )
            )
          ),

          tabPanel(
            "Deltas",
            icon = icon("balance-scale"),
            br(),
            DT::DTOutput(ns("deltaTable")),
            br(),
            downloadButton(ns("downloadDeltas"), "Download Delta Table")
          ),

          tabPanel(
            "Earlier Snapshots",
            icon = icon("history"),
            br(),
            h5("What each date rests on"),
            helpText(
              "Early dates rest on few animals and few recorded sires; read",
              "these counts beside the trend."
            ),
            DT::DTOutput(ns("backfillSupportTable")),
            br(),
            h5("Dates not built"),
            uiOutput(ns("backfillSkippedNote")),
            DT::DTOutput(ns("backfillSkippedTable"))
          )
        )
      )
    )
  )
}

#' Genetic-Health Trends Module - Server Function
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param snapshotSource reactive returning
#' \code{list(ped, geneticValue, guIter, guThresh)} from the most recent
#' Genetic Value Analysis run (see
#' \code{\link{modGeneticValueServer}}'s \code{snapshotSource} return
#' element), or erroring (shiny \code{req()} semantics) before any run has
#' happened.
#' @param fullPedigree reactive returning the full quality-controlled pedigree
#' (the Pedigree tab's \code{processedPedigree}, never the focal-trimmed
#' \code{analysisPedigree}, which would shrink every past population), or
#' erroring (shiny \code{req()} semantics) before a studbook is loaded. Feeds
#' the "Build Earlier Snapshots" box. Defaults to \code{reactive(NULL)}: no
#' pedigree, so the box waits.
#'
#' @return A list with reactive components:
#' \itemize{
#'   \item \code{history} - the current validated snapshot history (or
#'     \code{NULL} before any upload or generation).
#'   \item \code{deltas} - the current delta comparison (see
#'     \code{\link{calcSnapshotDeltas}}), keyed off the sidebar's rule/from/
#'     to selectors.
#'   \item \code{isReady} - logical: \code{TRUE} once \code{history} is
#'     non-\code{NULL} (a history has been uploaded or generated).
#'   \item \code{backfillSupport} - the table of what each date of the default
#'     earlier-snapshot series rests on
#'     (\code{\link{previewBackfillSupport}} of \code{fullPedigree()}),
#'     independent of the chosen start year; erroring (\code{req()}) until a
#'     pedigree is loaded.
#' }
#'
#' The "Build Earlier Snapshots" button calls
#' \code{\link{backfillColonySnapshots}} with the full pedigree, the
#' \code{guIter}, \code{guThresh} and \code{reportArgs} of
#' \code{snapshotSource()}, the chosen start year and the history already
#' held, and adds nothing of its own to the numbers. It does nothing before an
#' analysis has run. Warnings from the build are summarized in one
#' notification; a failure is reported and leaves the history as it was.
#'
#' The generated snapshot's \code{membershipRule} is auto-derived from
#' \code{snapshotSource()$ped$population} (issue #167 Slice 4, S760 owner
#' decision): \code{"focalPopulation"} when the analyzed pedigree's
#' population column excludes any animal, \code{"wholePedigree"} otherwise
#' -- truthful by construction from what \code{reportGV()} actually
#' analyzed, never a user-set dropdown that could contradict the data and
#' hit \code{\link{createColonySnapshot}}'s \code{stop()}. The delta
#' comparison keeps a user-facing rule selector, populated from the
#' uploaded/generated history's own \code{membershipRule} values.
#'
#' A \code{\link{checkSnapshotHistory}} violation on a malformed history
#' upload surfaces as a notification (module-contract rule 5: this is not
#' the same seam as inter-module malleability -- the specific violation is
#' shown, not disguised as "no data yet") and leaves the current history
#' unchanged.
#'
#' @seealso \code{\link{modSnapshotTrendsUI}} for the user interface.
#' @importFrom shiny moduleServer reactive reactiveVal observeEvent req
#' @importFrom shiny renderUI helpText strong downloadHandler showNotification
#' @importFrom shiny updateSelectInput renderPlot setProgress
#' @importFrom DT renderDT
#' @importFrom utils write.csv
#' @family Shiny modules
#' @export
modSnapshotTrendsServer <- function(id, snapshotSource,
                                    fullPedigree = reactive(NULL)) {

  moduleServer(id, function(input, output, session) {

    history <- reactiveVal(NULL)
    skippedDates <- reactiveVal(NULL)

    signalReady <- function() {
      session$sendCustomMessage("setDataReady", list(
        selector = paste0("#", session$ns("moduleContainer")),
        ready = TRUE
      ))
    }

    observeEvent(input$historyFile, {
      tryCatch(
        {
          raw <- readSnapshotHistory(input$historyFile$datapath)
          history(checkSnapshotHistory(raw))
          signalReady()
        },
        error = function(e) {
          showNotification(
            paste("Could not read snapshot history:", conditionMessage(e)),
            type = "error", duration = 10L
          )
        }
      )
    })

    # Auto-derived (D7): truthful by construction from the pedigree
    # snapshotSource() reports was actually analyzed.
    derivedRule <- reactive({
      src <- snapshotSource()
      pop <- src$ped$population
      if (!is.null(pop) && !all(pop)) "focalPopulation" else "wholePedigree"
    })

    output$derivedRuleUI <- renderUI({
      rule <- tryCatch(derivedRule(), error = function(e) NULL)
      if (is.null(rule)) {
        helpText("Run Genetic Value Analysis to enable snapshot generation.")
      } else {
        helpText("Membership rule for the next snapshot: ", strong(rule))
      }
    })

    observeEvent(input$generateSnapshot, {
      req(snapshotSource())
      src <- snapshotSource()
      tryCatch(
        {
          snapshot <- createColonySnapshot(
            src$ped, src$geneticValue, derivedRule(),
            guIter = src$guIter, guThresh = src$guThresh
          )
          history(appendColonySnapshot(history(), snapshot))
          signalReady()
        },
        error = function(e) {
          showNotification(
            paste("Could not generate snapshot:", conditionMessage(e)),
            type = "error", duration = 10L
          )
        }
      )
    })

    # Keep the sidebar's delta rule/from/to selectors populated from the
    # current history's own values, matching prior-selection where it's
    # still valid.
    observeEvent(history(), {
      hist <- history()
      req(hist)
      rules <- sort(unique(hist$membershipRule))
      selectedRule <- if (isTRUE(input$deltaRule %in% rules)) {
        input$deltaRule
      } else {
        rules[1L]
      }
      updateSelectInput(session, "deltaRule", choices = rules,
                        selected = selectedRule)
      dates <- sort(unique(as.character(hist$snapshotDate)))
      updateSelectInput(session, "deltaFrom", choices = dates,
                        selected = dates[1L])
      updateSelectInput(session, "deltaTo", choices = dates,
                        selected = dates[length(dates)])
    })

    output$historyTable <- DT::renderDT({
      req(history())
    }, options = list(pageLength = 10L))

    ## The chart's columns and height follow the width of its box, so the panel
    ## titles stay whole in a narrow window (trendPlotLayout()).
    trendWidthId <- paste0("output_", session$ns("trendPlot"), "_width")
    trendLayout <- reactive({
      trendPlotLayout(session$clientData[[trendWidthId]])
    })

    output$trendPlot <- renderPlot({
      req(history())
      plotSnapshotTrends(history(), ncol = trendLayout()$ncol)
    }, height = function() trendLayout()$height)

    deltas <- reactive({
      req(history(), input$deltaFrom, input$deltaTo, input$deltaRule)
      calcSnapshotDeltas(history(), input$deltaFrom, input$deltaTo,
                         membershipRule = input$deltaRule)
    })

    output$deltaTable <- DT::renderDT({
      deltas()
    }, options = list(pageLength = 25L))

    output$downloadHistory <- downloadHandler(
      filename = function() paste0("snapshot_history_", Sys.Date(), ".csv"),
      content = function(file) {
        write.csv(history(), file, row.names = FALSE)
      }
    )

    output$downloadDeltas <- downloadHandler(
      filename = function() paste0("snapshot_deltas_", Sys.Date(), ".csv"),
      content = function(file) {
        write.csv(deltas(), file, row.names = FALSE)
      }
    )

    # Issue #170 Slice 3: the counts every date of the default series rests
    # on, the same table a script gets from previewBackfillSupport().
    backfillSupport <- reactive({
      req(fullPedigree())
      previewBackfillSupport(fullPedigree())
    })

    observeEvent(backfillSupport(), {
      dates <- backfillSupport()$snapshotDate
      starts <- stats::setNames(as.character(dates), format(dates, "%Y"))
      updateSelectInput(session, "backfillStart", choices = starts,
                        selected = starts[[1L]])
    })

    # NULL until a start year is chosen: the function then starts its default
    startDate <- reactive({
      chosen <- input$backfillStart
      if (is.null(chosen) || !nzchar(chosen)) NULL else as.Date(chosen)
    })

    output$backfillCostUI <- renderUI({
      src <- tryCatch(snapshotSource(), error = function(e) NULL)
      support <- tryCatch(backfillSupport(), error = function(e) NULL)
      if (is.null(src)) {
        return(helpText(
          "Run Genetic Value Analysis to enable earlier snapshots."
        ))
      }
      if (is.null(support)) {
        return(helpText("Load a pedigree to enable earlier snapshots."))
      }
      start <- tryCatch(startDate(), error = function(e) NULL)
      dates <- support$snapshotDate
      if (!is.null(start)) {
        dates <- dates[dates >= start]
      }
      helpText(describeBackfillCost(dates, src$guIter))
    })

    output$backfillSupportTable <- DT::renderDT({
      support <- backfillSupport()
      support$pctSireKnown <- round(support$pctSireKnown, 1L)
      support$pctDamKnown <- round(support$pctDamKnown, 1L)
      support
    }, options = list(pageLength = 10L), rownames = FALSE)

    # NULL (no text) once a build has run, whether or not it skipped a date
    output$backfillSkippedNote <- renderUI({
      if (is.null(skippedDates())) {
        helpText("Skipped dates are listed here after a build.")
      }
    })

    output$backfillSkippedTable <- DT::renderDT({
      req(skippedDates())
    }, options = list(pageLength = 10L), rownames = FALSE)

    observeEvent(input$buildBackfill, {
      req(snapshotSource(), fullPedigree())
      src <- snapshotSource()
      warningsSeen <- character(0L)
      tryCatch(
        {
          result <- withProgress(
            message = "Building earlier snapshots", value = 0L,
            {
              updateProgress <- function(n, value, detail = NULL) {
                setProgress(value = value / n, detail = detail)
              }
              withCallingHandlers(
                do.call(backfillColonySnapshots, c(
                  list(fullPedigree(),
                       guIter = src$guIter, guThresh = src$guThresh,
                       from = startDate(), existingHistory = history(),
                       updateProgress = updateProgress),
                  src$reportArgs
                )),
                warning = function(w) {
                  warningsSeen <<- c(warningsSeen, conditionMessage(w))
                  invokeRestart("muffleWarning")
                }
              )
            }
          )
          history(result$history)
          skippedDates(result$skipped)
          signalReady()
        },
        error = function(e) {
          showNotification(
            paste("Could not build earlier snapshots:", conditionMessage(e)),
            type = "error", duration = 10L
          )
        }
      )
      if (length(warningsSeen) > 0L) {
        # Each different note once, no count: a date can raise a note twice
        notes <- utils::head(unique(warningsSeen), 3L)
        showNotification(
          paste0(
            "Earlier snapshots were built; the calculation gave ",
            if (length(notes) == 1L) "this note: " else "these notes: ",
            paste(substr(notes, 1L, 200L), collapse = " | ")
          ),
          type = "warning", duration = 15L
        )
      }
    })

    list(
      history = reactive(history()),
      deltas = deltas,
      isReady = reactive(!is.null(history())),
      backfillSupport = backfillSupport
    )
  })
}

#' The cost line of the Build Earlier Snapshots box
#'
#' Says how many snapshots a build will make, between which dates and at how
#' many gene-drop iterations, and roughly how long it takes. The time is an
#' estimate of a quarter of a second a date for 1,000 iterations, scaled by the
#' iterations only: on the 2,590-animal jmac colony the 53 default dates at
#' 1,000 iterations took 12.6 s, 0.24 s a date (performance campaign Phase 10,
#' S1065; it was 4 s a date before Phases 1, 2 and 5).
#'
#' @param dates The \code{Date}s of the build, in order.
#' @param guIter The gene-drop iterations of the last analysis.
#' @return A single string.
#'
#' @noRd
describeBackfillCost <- function(dates, guIter) {
  seconds <- length(dates) * 0.25 * guIter / 1000L
  estimate <- if (seconds < 60L) {
    "under a minute"
  } else {
    paste0("about ", round(seconds / 60L), " min")
  }
  span <- if (length(dates) == 1L) {
    paste0(" (", format(dates), ")")
  } else {
    paste0("s, ", format(min(dates)), " to ", format(max(dates)))
  }
  paste0(
    length(dates), " snapshot", span, ", at ", guIter, " iterations each. ",
    "Each date runs the gene drop again, about a quarter of a second per ",
    "1,000 iterations on a colony of 2,590 animals, so expect ", estimate,
    " here (an ",
    "estimate; larger colonies take longer)."
  )
}
