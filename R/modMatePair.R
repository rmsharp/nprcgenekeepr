## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Mate Pair Analysis Shiny Module

#' Mate Pair Analysis Module - UI Function
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @return A \code{div} containing the mate-pair analysis UI: a candidate-
#'   population/age/exclude-list configuration panel (with a collapsed
#'   "Ancestry Guardrails" section -- holding the per-rule override controls --
#'   and an always-visible ancestry-rules status line) and an "Eligible Pairs" /
#'   "Excluded" / "Ancestry" tabbed result view (the last holding the coverage
#'   summary and the audit-manifest download).
#'
#' @seealso \code{\link{modMatePairServer}}
#' @seealso \code{\link{reportMatePairs}} for the underlying report function.
#' @importFrom shiny NS div h3 fluidRow column wellPanel radioButtons
#' @importFrom shiny conditionalPanel numericInput textAreaInput selectInput
#' @importFrom shiny checkboxInput uiOutput actionButton downloadButton
#' @importFrom shiny tabsetPanel tabPanel icon br tableOutput
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
               # Issue #169 Slice 2 (D9): the ancestry guardrails sit here
               # collapsed by default, with one always-visible status line
               # (modBreedingGroupsUI's own layout). The rules come from the
               # Breeding Groups tab's upload (D7); Slice 3 adds the per-rule
               # override control inside the collapsed panel.
               checkboxInput(ns("showAncestryGuardrails"),
                             "Ancestry Guardrails", value = FALSE),
               uiOutput(ns("ancestryStatus")),
               conditionalPanel(
                 # ns = ns already scopes this panel's input lookups to the
                 # module namespace client-side, so the condition uses the
                 # unprefixed field name (a ns()-built condition
                 # double-prefixes and never matches; Learning 324).
                 condition = "input.showAncestryGuardrails",
                 ns = ns,
                 shiny::p(
                   paste(
                     "Ancestry rules come from the Ancestry Guardrails",
                     "section of the Breeding Groups tab. A pair that",
                     "matches a block rule moves to the Excluded tab",
                     "(reason \"ancestry rule\"); a pair that matches a",
                     "flag rule stays in Eligible Pairs, with its rule",
                     "shown."
                   ),
                   style = "color: gray;"
                 ),
                 # Issue 169 Slice 3a (D8/D9): per-rule override controls.
                 # The select lists the not-yet-overridden BLOCK rules; the
                 # button opens the confirm gate (a required reason).
                 # Overrides apply to this tab's runs only, and persist until
                 # cleared or the rules change.
                 selectInput(ns("overrideRule"), "Block rule to override:",
                             choices = NULL),
                 actionButton(ns("overrideOpen"), "Override rule...",
                              icon = icon("unlock")),
                 uiOutput(ns("overrideStatus")),
                 actionButton(ns("clearOverrides"), "Clear overrides")
               ),
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
               tabPanel("Excluded", br(), DT::DTOutput(ns("excludedTable"))),
               # Issue #169 Slice 3a (D9): the coverage summary and the run's
               # audit manifest. No violations table -- the inline columns of
               # Eligible Pairs and the Excluded tab are the list.
               tabPanel(
                 "Ancestry", br(),
                 uiOutput(ns("ancestryGuidance")),
                 tableOutput(ns("ancestryCoverageTable")), br(),
                 downloadButton(ns("downloadAncestryManifest"),
                                "Download Audit Manifest")
               )
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
#' \strong{Ancestry guardrails (issue #169).} \code{ancestryRules} carries the
#' rules loaded on the Breeding Groups tab. When rules are loaded and the
#' pedigree has an \code{ancestry} column, each run hands them to
#' \code{\link{reportMatePairs}}: a pair matching a \code{block} rule moves to
#' the Excluded tab (reason \code{"ancestry rule"}) and a pair matching a
#' \code{flag} rule stays in Eligible Pairs, annotated. The rules are read
#' once, at the "Find Eligible Pairs" click, so loading or clearing rules
#' afterwards never rewrites a finished run's tables. The module checks for the
#' \code{ancestry} column before passing rules (the report function stops
#' without it); a rules-loaded run on a pedigree with no such column runs
#' exactly as it does with no rules, and the status line says the guardrails
#' are inactive. An always-visible status line reports the loaded state.
#'
#' \strong{Overriding a block rule.} With active rules, the "Ancestry
#' Guardrails" section lists the block rules not yet overridden. "Override
#' rule..." opens a confirmation step that shows the warning text
#' verbatim and requires a written reason (a blank reason is refused);
#' confirming relaxes that one rule for this tab's runs, for the session,
#' until the overrides are cleared or the rules change. An overridden rule's
#' pairs stay in Eligible Pairs marked \code{"overridden"} (severity still
#' \code{"block"}); they are never silently dropped. Each override is
#' recorded per tab -- Breeding Groups keeps its own -- and the next run
#' applies it; a finished run is never rewritten.
#'
#' \strong{The Ancestry tab.} Shows the displayed run's coverage summary (how
#' many candidate animals carry each ancestry classification and which
#' classifications no rule reaches) and a "Download Audit Manifest" button.
#' The manifest is one row per rule: the rule as written, whether it was
#' overridden and why, how many otherwise-eligible pairs it matched, the
#' animal census by classification, and the confirmation warning verbatim. It
#' describes the displayed run's own rules and overrides, and is unavailable
#' for a run that had no rules in effect.
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
#' @param ancestryRules optional reactive returning the validated ancestry
#'   rules table (see \code{\link{checkAncestryRules}}) from
#'   \code{\link{modBreedingGroupsServer}}'s \code{ancestryRules} return
#'   element, or \code{NULL} when no rules are loaded. \code{NULL} (the
#'   default, or a reactive that returns \code{NULL}) applies no rules, and
#'   the results are identical to a run before this argument existed.
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
#' @importFrom shiny req downloadHandler div observe p tagList renderTable
#' @importFrom shiny showModal removeModal modalDialog modalButton
#' @importFrom shiny showNotification updateSelectInput
#' @importFrom DT renderDT
#' @importFrom utils write.csv
#' @family Shiny modules
#' @export
modMatePairServer <- function(id, pedigree, kinshipMatrix,
                              markerKinshipMatrix, geneticValues,
                              ancestryRules = NULL) {
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
    # Issue #169 Slice 3a (D8c): what the displayed run's ancestry screen used
    # -- list(rules, overrides) as they stood at the click -- or NULL when that
    # run had no rules in effect. Set together with matchResults at the click,
    # so the Ancestry tab and manifest describe the displayed run, never live
    # state.
    ancestryRun <- reactiveVal(NULL)

    output$excludeTextarea <- renderUI({
      req(isTRUE(input$useExcludeList))
      textAreaInput(session$ns("excludeIds"), "Animal IDs to exclude:",
                    rows = 3L, value = "")
    })

    # Issue #169 Slice 2 (D7): the rules loaded on the Breeding Groups tab. An
    # absent argument (script or test use) is the same as no rules loaded.
    ancestryRulesData <- reactive({
      if (is.null(ancestryRules)) NULL else ancestryRules()
    })

    # The rules a run actually receives: NULL unless rules are loaded AND the
    # pedigree carries an ancestry column. reportMatePairs() stop()s on rules
    # with no ancestry column, so the module checks first (loud, never fatal:
    # the status line below says why the guardrails are inactive).
    ancestryRulesForRun <- reactive({
      rules <- ancestryRulesData()
      ped <- pedigree()
      if (is.null(rules) || is.null(ped) ||
            !("ancestry" %in% names(ped))) {
        return(NULL)
      }
      rules
    })

    # D9's one-line status: "no rules loaded" (worded for this tab, which has
    # no upload of its own) / rule + coverage counts / the inactive notice --
    # the last two shared with Breeding Groups (.ancestryStatusLine()).
    ancestryStatusText <- reactive({
      rules <- ancestryRulesData()
      if (is.null(rules)) {
        return(paste("No ancestry rules loaded. Load a rules file on the",
                     "Breeding Groups tab to apply it here."))
      }
      .ancestryStatusLine(rules, pedigree())
    })

    output$ancestryStatus <- renderUI({
      shiny::p(ancestryStatusText(), style = "color: gray;")
    })

    # Issue #169 Slice 3a (D8): the session's confirmed per-rule overrides for
    # THIS tab (Breeding Groups keeps its own). Session-scoped, never
    # persisted; each run snapshots what is in effect (the #150
    # params-snapshot mold), so a late override never rewrites an earlier
    # run's tables or audit manifest.
    emptyAncestryOverrides <- .emptyAncestryOverrides()
    ancestryOverridesRV <- reactiveVal(emptyAncestryOverrides)

    # A new rules table may not contain the overridden rules at all -- stale
    # overrides never survive a rules change (Breeding Groups' rule, here
    # keyed on the table reaching this module).
    observeEvent(ancestryRulesData(), {
      ancestryOverridesRV(emptyAncestryOverrides)
    }, ignoreNULL = FALSE, ignoreInit = TRUE)

    # The block rules a curator can still override: active rules only (NULL
    # when the guardrails are inactive), block severity, minus the rules
    # already overridden this session.
    overridableRules <- reactive({
      .overridableAncestryRules(ancestryRulesForRun(), ancestryOverridesRV())
    })

    # Keep the override select in step with the overridable set.
    observe({
      ovr <- overridableRules()
      choices <- if (is.null(ovr) || nrow(ovr) == 0L) {
        character(0L)
      } else {
        stats::setNames(
          .ancestryPairKey(ovr$ancestry1, ovr$ancestry2),
          sprintf("%s x %s", ovr$ancestry1, ovr$ancestry2)
        )
      }
      updateSelectInput(session, "overrideRule", choices = choices)
    })

    # The confirm gate (the #150 / #168 mold): the verbatim Mate Pair
    # warning, a required free-text reason, explicit Confirm/Cancel. It opens
    # only when the curator initiates an override -- never on a routine run.
    observeEvent(input$overrideOpen, {
      ovr <- overridableRules()
      req(!is.null(ovr), nrow(ovr) > 0L)
      req(input$overrideRule %in%
            .ancestryPairKey(ovr$ancestry1, ovr$ancestry2))
      showModal(modalDialog(
        title = "Override Ancestry Rule",
        p(.matePairAncestryOverrideWarningText),
        textAreaInput(session$ns("overrideReason"),
                      "Reason for override (required):",
                      value = "", rows = 3L),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(session$ns("overrideConfirm"), "Confirm Override",
                       class = "btn-warning")
        )
      ))
    })

    observeEvent(input$overrideConfirm, {
      ovr <- overridableRules()
      req(!is.null(ovr), nrow(ovr) > 0L)
      keys <- .ancestryPairKey(ovr$ancestry1, ovr$ancestry2)
      req(input$overrideRule %in% keys)
      reason <- if (is.null(input$overrideReason)) {
        ""
      } else {
        trimws(input$overrideReason)
      }
      if (!nzchar(reason)) {
        showNotification(
          "An override needs a non-empty reason.",
          type = "error", duration = 10L
        )
        return()
      }
      row <- ovr[keys == input$overrideRule, , drop = FALSE]
      ancestryOverridesRV(rbind(
        ancestryOverridesRV(),
        data.frame(
          ancestry1 = row$ancestry1, ancestry2 = row$ancestry2,
          reason = reason, stringsAsFactors = FALSE
        )
      ))
      removeModal()
    })

    observeEvent(input$clearOverrides, {
      ancestryOverridesRV(emptyAncestryOverrides)
    })

    # NULL when no overrides are active; otherwise the pinned one-liner, which
    # says the override applies to this tab.
    overrideStatusText <- reactive({
      ov <- ancestryOverridesRV()
      if (nrow(ov) == 0L) {
        return(NULL)
      }
      sprintf(
        "%d block rule(s) overridden on this tab this session: %s.",
        nrow(ov),
        toString(sort(.ancestryPairKey(ov$ancestry1, ov$ancestry2)))
      )
    })

    output$overrideStatus <- renderUI({
      txt <- overrideStatusText()
      if (is.null(txt)) {
        return(NULL)
      }
      shiny::p(txt, style = "color: darkorange;")
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

      # D8c: the rules and overrides are read once, here, at the click (an
      # observeEvent handler is isolated), and the stored result plus
      # ancestryRun() are that run's snapshot -- loading or clearing rules, or
      # overriding, afterwards never rewrites it. NULL rules (none loaded, or
      # no ancestry column) leave the call, and so the result, exactly as it
      # was before these arguments existed (D4-1); overrides are then the
      # zero-row table, since the kernel would stop() on overrides without
      # rules. The kernel gets the ORIGINAL rules plus the overrides (Learning
      # 780), never the downgraded rules.
      rulesRun <- ancestryRulesForRun()
      overridesRun <- if (is.null(rulesRun)) {
        emptyAncestryOverrides
      } else {
        ancestryOverridesRV()
      }
      res <- reportMatePairs(
        ped, kmat,
        markerKmat = markerKinshipMatrix(),
        geneticValues = gvArg,
        minAge = minAge,
        populationIds = popIds,
        exclude = excludeIds,
        ancestryRules = rulesRun,
        overriddenRules = overridesRun
      )
      matchResults(res)
      ancestryRun(if (is.null(rulesRun)) {
        NULL
      } else {
        list(rules = rulesRun, overrides = overridesRun)
      })

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
        msg <- paste("No eligible pairs found under the current population",
                     "scope and age settings. Try including more animals or",
                     "lowering the minimum age.")
        # Name the ancestry cause when rules excluded any pair; with none the
        # text is exactly what it was before ancestry rules existed.
        nAncestry <- sum(res$excluded$reason == "ancestry rule")
        if (nAncestry > 0L) {
          msg <- paste0(msg, sprintf(paste(" %d pair(s) were excluded by",
                                           "ancestry rules -- see the",
                                           "Excluded tab."), nAncestry))
        }
        div(class = "alert alert-warning", msg)
      }
    })

    # The displayed run's downloadable audit record (D8, the #150 manifest
    # mold): NULL unless that run had rules in effect. Built from the run's
    # own snapshot -- the ORIGINAL rules plus its overrides, and the report
    # adapted from its result -- never from live input state.
    ancestryManifest <- reactive({
      res <- matchResults()
      run <- ancestryRun()
      if (is.null(res) || is.null(run)) {
        return(NULL)
      }
      .buildAncestryOverrideManifest(
        run$rules, run$overrides, .matePairAncestryReport(res),
        .matePairAncestryOverrideWarningText
      )
    })

    # D9's tab guidance: NULL once a rules-run is displayed (the tables
    # speak); otherwise say why there is nothing to show -- the status line's
    # own "no rules loaded" / inactive wording, or that no run has used the
    # rules yet.
    ancestryTabGuidanceText <- reactive({
      if (!is.null(ancestryRun())) {
        return(NULL)
      }
      if (is.null(ancestryRulesForRun())) {
        return(ancestryStatusText())
      }
      paste("Find eligible pairs with ancestry rules loaded to see the",
            "coverage summary and audit manifest here.")
    })

    output$ancestryGuidance <- renderUI({
      txt <- ancestryTabGuidanceText()
      if (is.null(txt)) {
        return(NULL)
      }
      shiny::p(txt, style = "color: gray;")
    })

    output$ancestryCoverageTable <- renderTable({
      res <- matchResults()
      req(!is.null(res), !is.null(ancestryRun()))
      res$ancestryCoverage
    })

    output$downloadAncestryManifest <- downloadHandler(
      filename = function() {
        getDatedFilename("MatePairAncestryAuditManifest.csv")
      },
      content = function(file) {
        m <- ancestryManifest()
        req(!is.null(m))
        write.csv(m, file, na = "", row.names = FALSE)
      }
    )

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
