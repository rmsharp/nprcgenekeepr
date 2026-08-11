## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Mate Pair Analysis Shiny Module

#' Mate Pair Analysis Module - UI Function
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @return A \code{div} containing the mate-pair analysis UI: a candidate-
#'   population/age/exclude-list configuration panel and an "Eligible Pairs"
#'   / "Excluded" tabbed result view.
#'
#' @seealso \code{\link{modMatePairServer}}
#' @seealso \code{\link{reportMatePairs}} for the underlying report function.
#' @importFrom shiny NS div h3 fluidRow column wellPanel radioButtons
#' @importFrom shiny conditionalPanel numericInput textAreaInput
#' @importFrom shiny checkboxInput uiOutput actionButton downloadButton
#' @importFrom shiny tabsetPanel tabPanel icon br
#' @importFrom DT DTOutput
#' @family Shiny modules
#' @export
modMatePairUI <- function(id) {
  ns <- NS(id)

  div(
    id = ns("moduleContainer"),
    `data-ready` = "false",
    `data-module` = "matePair",

    h3("Mate Pair Analysis"),
    fluidRow(
      column(4L,
             wellPanel(
               h4(icon("heart"), "Configuration"),
               radioButtons(
                 ns("populationSource"), "Candidate population:",
                 choices = c(
                   "All alive (no recorded exit)" = "allAlive",
                   "Top ranked by genetic value" = "topRanked",
                   "Custom list (paste IDs)" = "custom"
                 )
               ),
               conditionalPanel(
                 # ns = ns already scopes this panel's input lookups to the
                 # module namespace client-side, so the condition uses the
                 # unprefixed field name (mirrors modBreedingGroupsUI's own
                 # animalSource conditionalPanel convention).
                 condition = "input.populationSource == 'topRanked'",
                 ns = ns,
                 numericInput(ns("nTopAnimals"), "Number of top animals:",
                              value = 20L, min = 5L, max = 100L)
               ),
               conditionalPanel(
                 condition = "input.populationSource == 'custom'",
                 ns = ns,
                 textAreaInput(ns("customPopulationIds"),
                               "Population IDs:", rows = 4L,
                               placeholder = "e.g. A1, A2, A3")
               ),
               numericInput(ns("minAge"),
                            "Minimum breeding age (years):",
                            value = 1L, min = 0L, max = 40L, step = 0.1),
               checkboxInput(ns("useExcludeList"),
                             "Exclude specific animals", value = FALSE),
               uiOutput(ns("excludeTextarea")),
               actionButton(ns("analyze"), "Find Eligible Pairs",
                            icon = icon("heart"),
                            class = "btn-primary btn-block")
             )
      ),
      column(8L,
             uiOutput(ns("guidance")),
             tabsetPanel(
               tabPanel(
                 "Eligible Pairs", br(),
                 DT::DTOutput(ns("pairsTable")), br(),
                 downloadButton(ns("downloadPairs"), "Export Eligible Pairs")
               ),
               tabPanel("Excluded", br(), DT::DTOutput(ns("excludedTable")))
             )
      )
    )
  )
}

#' Mate Pair Analysis Module - Server Function
#'
#' Reports eligible individual mate-pair candidates via
#' \code{\link{reportMatePairs}} (issue #151 Slice 1), wrapped in a
#' curator-facing configuration panel for the D4-ratified population scope
#' (\code{populationSource}: \code{"allAlive"} -- ids with no recorded
#' \code{ped$exit} date; \code{"topRanked"} -- the top \code{nTopAnimals}
#' ids in \code{geneticValues}' own report order, mirroring
#' \code{\link{modBreedingGroupsServer}}'s own \code{topRanked} reading;
#' \code{"custom"} -- a pasted, delimiter-separated id list), the D2 minimum-
#' age floor, and the D5-ratified exclude-list textarea. Kept structurally
#' and file-wise separate from \code{\link{modBreedingGroupsServer}} (D1) --
#' this module shares no code with it.
#'
#' \strong{The \code{geneticValues} wiring detail.} \code{shared$geneticValues}
#' (as threaded from \code{appServer.R}, matching every other module's own
#' convention) is the flat \code{reportGV()$report} data.frame, not the
#' \code{list(report = ...)} shape \code{\link{reportMatePairs}} itself
#' expects. This server wraps it (\code{list(report = geneticValues())})
#' immediately before calling \code{reportMatePairs()} -- omitting the wrap
#' would not error (a data.frame's \code{$report} accessor returns
#' \code{NULL}, not a condition), it would silently leave every genetic-
#' value column \code{NA}.
#'
#' \strong{Population scoping is a hard dependency, not a fallback-recompute.}
#' Unlike \code{modBreedingGroupsServer}'s optional \code{kinshipMatrix}
#' (which recomputes from \code{pedigree} when absent), this module always
#' receives the already-computed shared kinship reactive from
#' \code{appServer.R} and simply depends on it (module-contract rule 5:
#' upstream absence is \code{req()}), matching
#' \code{\link{modMarkerGeneticsServer}}'s own simpler precedent -- there is
#' no standalone use case for this module that would need an independent
#' recompute path.
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param pedigree reactive returning the current pedigree data frame
#'   (columns \code{id}, \code{sire}, \code{dam}, \code{sex}, \code{age},
#'   optionally \code{exit}).
#' @param kinshipMatrix reactive returning the full pedigree-based kinship
#'   matrix (row/column names are animal IDs), typically the same shared
#'   reactive passed to \code{modBreedingGroupsServer}/
#'   \code{modMarkerGeneticsServer}.
#' @param markerKinshipMatrix reactive returning the genotype-only KING-
#'   robust kinship matrix from \code{\link{modMarkerGeneticsServer}}'s own
#'   \code{markerKinshipMatrix} return element, or \code{NULL} before a
#'   genotype file has been uploaded.
#' @param geneticValues reactive returning the current genetic-value report
#'   data.frame (\code{shared$geneticValues}, with \code{id},
#'   \code{indivMeanKin}, \code{gu} columns), or \code{NULL} before the
#'   Genetic Value Analysis tab has been run.
#'
#' @return A list with three reactive elements: \code{pairs}, the eligible-
#'   pairs data.frame from the most recent \code{reportMatePairs()} run (see
#'   that function's own return documentation for columns); \code{excluded},
#'   the corresponding excluded-pairs data.frame; and \code{isReady},
#'   \code{TRUE} once a run has completed.
#'
#' @seealso \code{\link{modMatePairUI}}
#' @seealso \code{\link{reportMatePairs}}
#' @importFrom shiny moduleServer reactive reactiveVal observeEvent renderUI
#' @importFrom shiny req downloadHandler div
#' @importFrom DT renderDT
#' @importFrom utils write.csv
#' @family Shiny modules
#' @export
modMatePairServer <- function(id, pedigree, kinshipMatrix,
                              markerKinshipMatrix, geneticValues) {
  moduleServer(id, function(input, output, session) {

    # Delimiter-separated id parsing, mirroring modBreedingGroupsServer's own
    # seed-textarea convention (R/modBreedingGroups.R:380) -- reused here for
    # both the "custom" population-source textarea and the exclude-list
    # textarea.
    parseIdList <- function(raw) {
      if (is.null(raw) || !nzchar(trimws(raw))) {
        return(character(0L))
      }
      ids <- trimws(unlist(strsplit(raw, "[ ,;\t\n]")))
      ids[nzchar(ids)]
    }

    matchResults <- reactiveVal(NULL)

    output$excludeTextarea <- renderUI({
      req(isTRUE(input$useExcludeList))
      textAreaInput(session$ns("excludeIds"), "Animal IDs to exclude:",
                    rows = 3L, value = "")
    })

    observeEvent(input$analyze, {
      req(pedigree())
      ped <- pedigree()
      kmat <- kinshipMatrix()
      gv <- geneticValues()

      popIds <- switch(
        input$populationSource,
        allAlive = if ("exit" %in% names(ped)) {
          ped$id[is.na(ped$exit)]
        } else {
          ped$id
        },
        topRanked = {
          req(gv)
          nTop <- if (!is.null(input$nTopAnimals)) input$nTopAnimals else 20L
          gv$id[seq_len(min(nTop, nrow(gv)))]
        },
        custom = parseIdList(input$customPopulationIds),
        ped$id
      )

      excludeIds <- if (isTRUE(input$useExcludeList)) {
        parseIdList(input$excludeIds)
      } else {
        character(0L)
      }

      gvArg <- if (is.null(gv)) NULL else list(report = gv)

      minAge <- if (!is.null(input$minAge)) input$minAge else 1L

      res <- reportMatePairs(
        ped, kmat,
        markerKmat = markerKinshipMatrix(),
        geneticValues = gvArg,
        minAge = minAge,
        populationIds = popIds,
        exclude = excludeIds
      )
      matchResults(res)

      session$sendCustomMessage("setDataReady", list(
        selector = paste0("#", session$ns("moduleContainer")),
        ready = TRUE
      ))
    })

    output$pairsTable <- DT::renderDT({
      res <- matchResults()
      req(res)
      res$pairs
    }, server = TRUE)

    output$excludedTable <- DT::renderDT({
      res <- matchResults()
      req(res)
      res$excluded
    })

    output$downloadPairs <- downloadHandler(
      filename = function() getDatedFilename("MatePairs.csv"),
      content = function(file) {
        res <- matchResults()
        req(res)
        # Export exactly the currently-filtered/sorted rows (Dragon 4) --
        # `pairsTable_rows_all` is DT's row-position vector for every row
        # surviving the active search/filter, populated identically under
        # server = TRUE. NULL (no filter active yet) exports the full table.
        rowsAll <- input$pairsTable_rows_all
        tbl <- if (is.null(rowsAll)) {
          res$pairs
        } else {
          res$pairs[rowsAll, , drop = FALSE]
        }
        write.csv(tbl, file, na = "", row.names = FALSE)
      }
    )

    output$guidance <- renderUI({
      res <- matchResults()
      if (is.null(res)) {
        return(div(
          class = "alert alert-info",
          paste("Choose a candidate population and click \"Find Eligible",
                "Pairs\" to see results.")
        ))
      }
      if (nrow(res$pairs) == 0L) {
        div(
          class = "alert alert-warning",
          paste("No eligible pairs found under the current population",
                "scope and age settings. Try including more animals or",
                "lowering the minimum age.")
        )
      }
    })

    list(
      pairs = reactive({
        req(matchResults())
        matchResults()$pairs
      }),
      excluded = reactive({
        req(matchResults())
        matchResults()$excluded
      }),
      isReady = reactive(!is.null(matchResults()))
    )
  })
}
