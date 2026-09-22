## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Genetic-Health Trends Module - UI Function
#'
#' The 16th top-level tab (issue #167 Slice 4, D7): a Shiny workflow around
#' the longitudinal colony-snapshot functions already shipped in Slices 1-3
#' (\code{\link{checkSnapshotHistory}}/\code{\link{readSnapshotHistory}}/
#' \code{\link{appendColonySnapshot}}, \code{\link{createColonySnapshot}},
#' \code{\link{calcSnapshotDeltas}}/\code{\link{plotSnapshotTrends}}).
#' Upload or grow a snapshot-history CSV, generate a new dated snapshot from
#' the analysis already loaded on the Genetic Value Analysis tab, review
#' trend plots and a per-metric delta comparison (with the D4 comparability
#' flag visible), and download both the updated history and the delta
#' table.
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @return A \code{div} object containing the module's UI.
#' @seealso \code{\link{modSnapshotTrendsServer}} for server logic.
#' @importFrom shiny NS div h3 h5 icon helpText wellPanel fileInput
#' @importFrom shiny sidebarLayout sidebarPanel mainPanel actionButton
#' @importFrom shiny tabsetPanel tabPanel uiOutput plotOutput downloadButton
#' @importFrom shiny selectInput br hr
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
            plotOutput(ns("trendPlot"), height = "600px")
          ),

          tabPanel(
            "Deltas",
            icon = icon("balance-scale"),
            br(),
            DT::DTOutput(ns("deltaTable")),
            br(),
            downloadButton(ns("downloadDeltas"), "Download Delta Table")
          )
        )
      )
    )
  )
}

#' Genetic-Health Trends Module - Server Function
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param snapshotSource reactive returning a list(ped, geneticValue,
#' guIter, guThresh) from the most recent Genetic Value Analysis run (see
#' \code{\link{modGeneticValueServer}}'s \code{snapshotSource} return
#' element), or erroring (shiny \code{req()} semantics) before any run has
#' happened.
#'
#' @return A list with reactive components:
#' \itemize{
#'   \item \code{history} - the current validated snapshot history (or
#'     \code{NULL} before any upload or generation).
#'   \item \code{deltas} - the current delta comparison (see
#'     \code{\link{calcSnapshotDeltas}}), keyed off the sidebar's rule/from/
#'     to selectors.
#'   \item \code{isReady} - logical: is a non-empty history loaded.
#' }
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
#' A malformed history upload's \code{\link{checkSnapshotHistory}}
#' violation surfaces as a notification (module-contract rule 5: this is
#' not the same seam as inter-module malleability -- the specific violation
#' is shown, not disguised as "no data yet") and leaves the current history
#' unchanged.
#'
#' @seealso \code{\link{modSnapshotTrendsUI}} for the user interface.
#' @importFrom shiny moduleServer reactive reactiveVal observeEvent req
#' @importFrom shiny renderUI helpText strong downloadHandler showNotification
#' @importFrom shiny updateSelectInput renderPlot
#' @importFrom DT renderDT
#' @importFrom utils write.csv
#' @family Shiny modules
#' @export
modSnapshotTrendsServer <- function(id, snapshotSource) {

  moduleServer(id, function(input, output, session) {

    history <- reactiveVal(NULL)

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

    output$trendPlot <- renderPlot({
      req(history())
      plotSnapshotTrends(history())
    })

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

    list(
      history = reactive(history()),
      deltas = deltas,
      isReady = reactive(!is.null(history()))
    )
  })
}
