## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Breeding Group Formation Shiny Module

#' Breeding Groups Module - UI Function
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @return A \code{div} containing breeding group formation UI.
#'
#' @seealso \code{\link{modBreedingGroupsServer}}
#' @seealso \code{\link{groupAddAssign}} for group formation algorithm.
#'
#' @references
#' Vinson, A. and Raboin, M.J. (2015) "A Practical Approach for Designing
#' Breeding Groups to Maximize Genetic Diversity in a Large Colony of
#' Captive Rhesus Macaques (\emph{Macaca mulatta})" \emph{Journal of the
#' American Association for Laboratory Animal Science}, 2015 Nov, Vol.54(6),
#' pp.700-707.
#' @importFrom DT DTOutput renderDT
#' @importFrom shiny NS div h3 fluidRow column wellPanel radioButtons
#' @importFrom shiny conditionalPanel numericInput actionButton tabsetPanel
#' @importFrom shiny tabPanel uiOutput tableOutput icon includeHTML
#' @family Shiny modules
#' @export
modBreedingGroupsUI <- function(id) {
  ns <- NS(id)

  div(
    id = ns("moduleContainer"),
    `data-ready` = "false",
    `data-module` = "breedingGroups",

    h3("Breeding Group Formation"),
    fluidRow(
      column(4L,
             wellPanel(
               h4(icon("users"), "Configuration"),
               radioButtons(ns("animalSource"), "Source:",
                            choices = c("Top ranked" = "topRanked",
                                        "Upload list" = "custom",
                                        "All available" = "all")),
               radioButtons(ns("inclusionCriterion"), "Include animals by:",
                            choices = c("Top N ranked" = "topN",
                                        "Genetic-value floor" = "valueFloor"),
                            selected = "topN"),
               conditionalPanel(
                 # ns = ns already scopes this panel's input lookups to the
                 # module namespace client-side, so the condition uses the
                 # unprefixed field name (sprintf(..., ns("animalSource"))
                 # would double-prefix and never match). nTopAnimals only
                 # matters when the top-N inclusion criterion is selected
                 # (issue #128) -- the genetic-value floor bypasses it.
                 condition = paste0("input.animalSource == 'topRanked' && ",
                                    "input.inclusionCriterion == 'topN'"),
                 ns = ns,
                 numericInput(ns("nTopAnimals"), "Number of top animals:",
                              value = 20L, min = 5L, max = 100L)
               ),
               numericInput(ns("nGroups"), "Number of groups:",
                            value = 3L, min = 1L, max = 20L),
               numericInput(ns("maxKinship"), "Max kinship threshold:",
                            value = 0.25, min = 0L, max = 0.5, step = 0.01),
               radioButtons(ns("sexRatio"), "Sex ratio:",
                            choices = c(None = "none",
                                        "Harem (1M:NF)" = "harem",
                                        Custom = "custom")),
               conditionalPanel(
                 # ns = ns already scopes this panel's input lookups to the
                 # module namespace client-side, so the condition uses the
                 # unprefixed field name (sprintf(..., ns("sexRatio")) here
                 # would double-prefix and never match).
                 condition = "input.sexRatio == 'custom'",
                 ns = ns,
                 numericInput(ns("customSexRatio"),
                              "Custom ratio (F per M):",
                              value = 1.0, min = 0.5, max = 20.0,
                              step = 0.5)
               ),
               numericInput(ns("minAge"),
                            "Minimum breeding age (years):",
                            value = 1L, min = 0L, max = 40L, step = 0.1),
               numericInput(ns("nIterations"),
                            "Number of simulations:",
                            value = 10L, min = 1L, max = 1000000L),
               numericInput(ns("maxCandidates"),
                            "Candidates to retain:",
                            value = 5L, min = 1L, max = 50L),
               conditionalPanel(
                 # Exhaustive mode is only supported for numGp = 1, no
                 # harem, no custom sex ratio (issue #146 Slice 2, D2) -- the
                 # sexRatio radio's "none" choice already excludes both harem
                 # and custom, so gating on it plus nGroups == 1 exactly
                 # matches D2's eligibility scope (Dragon 4: hides the toggle
                 # outside its supported scope rather than letting the user
                 # discover the restriction only via a stop() error).
                 condition = "input.nGroups == 1 && input.sexRatio == 'none'",
                 ns = ns,
                 checkboxInput(ns("exhaustive"),
                               "Exhaustive enumeration mode",
                               value = FALSE),
                 uiOutput(ns("exhaustiveStatus"))
               ),
               checkboxInput(ns("withKinship"),
                             "Include kinship in display of groups",
                             value = FALSE),
               checkboxInput(ns("seedGroups"),
                             "Seed groups with specific animals",
                             value = FALSE),
               uiOutput(ns("seedTextareas")),
               actionButton(ns("formGroups"), "Form Groups",
                            icon = icon("users"),
                            class = "btn-primary btn-block")
             )
      ),
      column(8L,
             wellPanel(
               selectInput(ns("candidateChoice"), "Candidate grouping:",
                           choices = NULL),
               tableOutput(ns("candidateComparison"))
             ),
             tabsetPanel(
               tabPanel("Groups", br(), uiOutput(ns("groupsDisplay"))),
               tabPanel("Statistics", br(), tableOutput(ns("groupStats"))),
               tabPanel(
                 "Group Detail", br(),
                 selectInput(ns("viewGrp"), "Group to view:", choices = NULL),
                 h4("Group members"),
                 DT::DTOutput(ns("groupMemberTable")),
                 br(),
                 h4("Within-group kinship"),
                 DT::DTOutput(ns("groupKinTable")),
                 br(),
                 downloadButton(ns("downloadGroup"),
                                "Export Current Group"),
                 downloadButton(ns("downloadGroupKin"),
                                "Export Current Group Kinship Matrix")
               )
             )
      )
    ),
    fluidRow(
      column(
        width = 10L,
        offset = 1L,
        style = paste0(
          "border: 1px solid lightgray; background-color: #EDEDED; ",
          "border-radius: 15px; box-shadow: 0 0 5px 2px #888; ",
          "margin-top: 15px; padding: 10px;"
        ),
        includeHTML(
          system.file("extdata", "ui_guidance", "group_formation.html",
                      package = "nprcgenekeepr")
        )
      )
    )
  )
}

#' Breeding Groups Module - Server Function
#'
#' Server logic for breeding group formation using the groupAddAssign algorithm.
#' This module integrates with the kinship-based maximal independent set (MIS)
#' algorithm to form optimal breeding groups that minimize relatedness within
#' groups while maximizing group sizes.
#'
#' The module supports multiple configuration options:
#' \itemize{
#'   \item \strong{Animal source}: Select top-ranked animals or all available
#'   \item \strong{Kinship threshold}: Maximum allowed kinship within groups
#'   \item \strong{Harem mode}: Form groups with exactly one male each
#'   \item \strong{Sex ratio}: Target female-to-male ratio in groups
#' }
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param pedigree reactive returning pedigree data frame with columns:
#'   id, sire, dam, sex, and optionally birth, exit, gen.
#' @param geneticValues optional reactive returning genetic value results
#'   from \code{\link{modGeneticValueServer}}, used to source the
#'   \code{topRanked} animal-source candidate list. Unrelated to kinship.
#' @param kinshipMatrix optional reactive returning a kinship matrix,
#'   typically a full-pedigree matrix shared with
#'   \code{\link{modSummaryStatsServer}} (e.g. from \code{appServer}) rather
#'   than independently recomputed. If NULL, the module calculates kinship
#'   from the pedigree.
#' @param kinshipOverrides optional reactive returning a validated
#'   outside-information kinship-override data frame (\code{id1}, \code{id2},
#'   \code{kinship}); see \code{\link{applyKinshipOverrides}}.
#'   When the module recomputes kinship from the pedigree (the shared
#'   \code{kinshipMatrix} is unavailable), the overrides are applied to that
#'   matrix so group formation reflects them regardless of tab order.
#'   \code{NULL} (the default) is a no-op. A provided \code{kinshipMatrix} is
#'   expected to already carry overrides applied at its source.
#' @param twinRelations optional reactive returning a validated twin/zygosity
#'   sidecar data.frame (\code{id1}, \code{id2}, \code{code}); see
#'   \code{\link{checkTwinRelations}}. When the module recomputes kinship from
#'   the pedigree (the shared \code{kinshipMatrix} is unavailable), it is
#'   passed straight through to \code{\link{kinship}} so group formation
#'   reflects a declared MZ-twin pair's corrected identity regardless of tab
#'   order (BL-N Slice 3). \code{NULL} (the default) is a no-op. A provided
#'   \code{kinshipMatrix} is expected to already reflect it at its source.
#'
#' Up to 5 distinct candidate groupings are formed per run (issue #125), with
#' a "Candidate grouping" selector letting the user switch among them without
#' re-running \code{\link{groupAddAssign}}. All reactive components below
#' reflect the currently-selected candidate, defaulting to the best-scoring
#' one -- identical to the single-solution behavior prior to issue #125.
#'
#' @return List with reactive components:
#' \itemize{
#'   \item \code{groups} - List of character vectors with animal IDs per group
#'   \item \code{nGroups} - Number of groups formed
#'   \item \code{score} - Optimization score from groupAddAssign
#'     (minimum group size)
#'   \item \code{unassigned} - Character vector of candidate IDs not placed
#'     in groups
#'   \item \code{groupKinship} - List of kinship matrices per group
#'     (if withKin=TRUE)
#' }
#'
#' @seealso \code{\link{modBreedingGroupsUI}} for the UI component
#' @seealso \code{\link{groupAddAssign}} for the underlying MIS algorithm
#' @seealso \code{\link{modGeneticValueServer}} for genetic value analysis
#' @seealso \code{\link{kinship}} for kinship matrix calculation
#'
#' @importFrom shiny moduleServer reactive eventReactive reactiveVal
#' @importFrom shiny withProgress incProgress req showNotification
#' @family Shiny modules
#' @export
modBreedingGroupsServer <- function(id, pedigree, geneticValues = NULL,
                                    kinshipMatrix = NULL,
                                    kinshipOverrides = NULL,
                                    twinRelations = NULL) {
  moduleServer(id, function(input, output, session) {

    # Store results from groupAddAssign
    groupResults <- reactiveVal(NULL)

    # Helper: use the shared kinship matrix (issue #122 Phase 2) if provided,
    # else calculate from pedigree
    getKinshipMatrix <- function(ped, kinshipMatrix, overrides = NULL,
                                 twinRelations = NULL) {
      # Try the shared kinship matrix first
      if (!is.null(kinshipMatrix)) {
        kmat <- tryCatch(kinshipMatrix(), error = function(e) NULL)
        if (!is.null(kmat)) {
          return(kmat)
        }
      }

      # Calculate kinship from pedigree (the fallback recompute). Issue #13
      # Slice 3: apply outside-information kinship overrides to this freshly
      # recomputed matrix so group formation reflects them even when the GV tab
      # was not run first. The genetic-value-output branch above already carries
      # overrides (applied inside reportGV). Ids absent from the matrix are
      # warn-dropped, never aborting the module (D5). BL-N Slice 3: a declared
      # twin identity is threaded straight into kinship() itself (not a
      # post-hoc matrix patch, mirroring reportGV()'s own call shape).
      if (!"gen" %in% names(ped)) {
        ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
      }
      kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen,
                      twinRelations = twinRelations)
      applyKinshipOverridesToMatrix(kmat, overrides)
    }

    # Helper: Parse sex ratio from UI input. "custom" reads its value from
    # the customSexRatio numeric input rather than parsing the radio choice
    # string itself.
    parseSexRatio <- function(sexRatioInput, customSexRatio = NULL) {
      if (is.null(sexRatioInput) || sexRatioInput %in% c("none", "harem")) {
        return(0.0)
      }
      sexRatioNum <- suppressWarnings(as.numeric(customSexRatio))
      if (is.null(customSexRatio) || is.na(sexRatioNum)) {
        0.0
      } else {
        sexRatioNum
      }
    }

    # Helper: Filter out NA/empty groups from groupAddAssign result
    filterValidGroups <- function(groupList) {
      validGroups <- lapply(groupList, function(g) {
        if (length(g) == 0L || all(is.na(g))) return(NULL)
        g[!is.na(g)]
      })
      validGroups[!vapply(validGroups, is.null, logical(1L))]
    }

    # Runs groupAddAssign() once per "Form Groups" click and stores the full
    # multi-candidate result (issue #125 Slice 2). Kept separate from
    # `breedingGroups` (below) so that changing the candidate selection never
    # re-invokes groupAddAssign() -- only this eventReactive's own trigger
    # (input$formGroups) does.
    runFormation <- eventReactive(input$formGroups, {
      req(pedigree())

      # E2E determinism hook (gated; no-op in production). See gatedSeed().
      gatedSeed("nprcgenekeepr.bg_seed", "NPRC_BG_SEED") # nolint: object_usage_linter

      withProgress(message = "Forming breeding groups...", {
        ped <- pedigree()

        # Raw candidate pool based on source selection, unnarrowed (issue
        # #128): "topRanked" yields the full ranked id list in report order;
        # "custom"/"all" yield every pedigree id. The top-N cutoff moved out
        # of this step into the inclusion-criterion narrowing below.
        rawPool <- if (input$animalSource == "topRanked") {
          req(geneticValues())
          geneticValues()$id
        } else {
          ped$id
        }

        # Narrow the raw pool by inclusion criterion (issue #128). A missing
        # input$inclusionCriterion defaults to "topN", reproducing today's
        # exact behavior for all three sources unless the user actively
        # selects the genetic-value floor.
        inclusionCriterion <- if (is.null(input$inclusionCriterion)) {
          "topN"
        } else {
          input$inclusionCriterion
        }
        candidateIds <- if (inclusionCriterion == "valueFloor") {
          # req(geneticValues()) gates ALL three sources here -- previously
          # only topRanked needed a prior GV run. An id with no row in
          # geneticValues() at all fails the floor (a fail-safe default,
          # distinct from an id present with value == "Undetermined", which
          # passes): `passingIds` only ever contains ids that ARE in the
          # report, so a rawPool id absent from the report is never a member
          # and is excluded by the %in% filter below.
          req(geneticValues())
          gv <- geneticValues()
          passingIds <- gv$id[gv$value != "Low Value"]
          rawPool[rawPool %in% passingIds]
        } else if (input$animalSource == "topRanked") {
          rawPool[seq_len(min(input$nTopAnimals, length(rawPool)))]
        } else {
          rawPool
        }

        incProgress(0.2, detail = "Calculating kinship")
        ovr <- if (is.null(kinshipOverrides)) NULL else kinshipOverrides()
        twins <- if (is.null(twinRelations)) NULL else twinRelations()
        kmat <- getKinshipMatrix(ped, kinshipMatrix, overrides = ovr,
                                 twinRelations = twins)

        incProgress(0.3, detail = "Running group formation algorithm")

        # Parse groupAddAssign parameters
        threshold <- input$maxKinship
        numGp <- input$nGroups
        harem <- (input$sexRatio == "harem")
        sexRatio <- parseSexRatio(input$sexRatio, input$customSexRatio)
        minAge <- if (!is.null(input$minAge)) input$minAge else 1.0
        iter <- if (!is.null(input$nIterations)) {
          as.integer(input$nIterations)
        } else {
          10L
        }
        withKin <- if (!is.null(input$withKinship)) input$withKinship else FALSE
        maxCandidates <- if (!is.null(input$maxCandidates)) {
          as.integer(input$maxCandidates)
        } else {
          5L
        }
        # Issue #146 Slice 2: exhaustive mode, its UI toggle only visible
        # when D2-eligible, but the input value may still be leftover-TRUE
        # from a prior eligible run even if the UI has since hidden it --
        # groupAddAssign() itself is the authoritative D2 scope gate
        # (stop()s if ineligible), so no client-side re-check is needed here.
        exhaustive <- if (!is.null(input$exhaustive)) {
          input$exhaustive
        } else {
          FALSE
        }

        # Seed groups ("current groups") parity (monolith server.r:1019-1056):
        # build a length-numGp list of seed-animal IDs from the per-group
        # textareas when seeding is enabled. seq_len() honors every group's
        # textarea (the monolith's seq_along(input$numGp) is a length-1 scalar,
        # so it only ever reads curGrp1). Building here ties the list length to
        # the same numGp passed to groupAddAssign, so length(currentGroups) can
        # never exceed numGp (its length guard).
        currentGroups <- if (isTRUE(input$seedGroups)) {
          lapply(seq_len(numGp), function(i) {
            raw <- input[[paste0("curGrp", i)]]
            if (is.null(raw) || !nzchar(trimws(raw))) {
              return(character(0L))
            }
            ids <- trimws(unlist(strsplit(raw, "[ ,;\t\n]")))
            ids[nzchar(ids)]
          })
        } else {
          list(character(0L))
        }
        if (length(currentGroups) > numGp) {
          currentGroups <- currentGroups[seq_len(numGp)]
        }

        # Seeded animals are not also candidates (monolith server.r:1098-1100;
        # groupAddAssign also drops them and their relatives internally).
        candidateIds <- setdiff(candidateIds, unlist(currentGroups))

        # Seed IDs absent from the pedigree are rejected (validate-and-block):
        # a phantom seed otherwise survives into the group and crashes the
        # Group Detail member view (addSexAndAgeToGroup -> getCurrentAge).
        badSeeds <- setdiff(unlist(currentGroups), ped$id)

        # Progress callback for groupAddAssign
        updateProgress <- function(n = 1L, detail = NULL, value = 0L,
                                   reset = FALSE) {
          incProgress(amount = 0.001, detail = detail)
        }

        # Run the MIS-based group formation algorithm. When any seed ID is not
        # in the pedigree, block formation with a clear notification rather than
        # forming a group with a phantom member.
        result <- if (length(badSeeds) > 0L) {
          showNotification(
            paste("Seed animals not in the pedigree:", toString(badSeeds)),
            type = "error",
            duration = 10L
          )
          list(candidates = list(list(group = list(character(0L)), score = 0L)))
        } else {
          tryCatch({
            groupAddAssign(
              candidates = candidateIds,
              kmat = kmat,
              ped = ped,
              currentGroups = currentGroups,
              threshold = threshold,
              ignore = list(c(sexCodes[["female"]], sexCodes[["female"]])),
              minAge = minAge,
              iter = iter,
              numGp = numGp,
              harem = harem,
              sexRatio = sexRatio,
              withKin = withKin,
              maxCandidates = maxCandidates,
              exhaustive = exhaustive,
              updateProgress = updateProgress
            )
          }, error = function(e) {
            showNotification(
              paste("Could not form breeding groups. Error:",
                    e$message,
                    "Please check your input data and try again."),
              type = "error",
              duration = 10L
            )
            list(candidates = list(
              list(group = list(character(0L)), score = 0L)
            ))
          })
        }

        # Process every retained candidate (issue #125 Slice 2), not just the
        # best: each gets its own validGroups/unassigned/hasUnused, so the
        # selector below (`selectedCandidateIdx`) can switch among them
        # without re-running groupAddAssign(). kmat is retained once, at the
        # top level -- it does not vary by candidate.
        candidateViews <- lapply(result$candidates, function(cand) {
          validGroups <- filterValidGroups(cand$group)
          assignedIds <- unlist(validGroups)
          unassignedIds <- setdiff(candidateIds, assignedIds)

          # The unused-animals group is the last element appended by
          # addGroupOfUnusedAnimals(); it survives filterValidGroups() only
          # when non-empty, in which case it is validGroups' last element.
          lastRaw <- cand$group[[length(cand$group)]]
          hasUnused <- !(length(lastRaw) == 0L || all(is.na(lastRaw)))

          list(
            validGroups = validGroups,
            score = cand$score,
            groupKin = cand$groupKin,
            unassigned = unassignedIds,
            hasUnused = hasUnused
          )
        })

        # result$exhaustive/examined/retentionRule are absent (NULL) unless
        # this run used exhaustive = TRUE (D7's byte-identical-by-default
        # return shape) -- carried through so output$exhaustiveStatus below
        # can render the search outcome for the run that actually produced
        # the currently-displayed candidates.
        groupResults(list(
          candidates = candidateViews, kmat = kmat,
          exhaustive = result$exhaustive, examined = result$examined,
          retentionRule = result$retentionRule
        ))

        incProgress(0.5, detail = "Complete")

        # Signal that breeding group formation is complete (for E2E testing)
        session$sendCustomMessage("setDataReady", list(
          selector = paste0("#", session$ns("moduleContainer")),
          ready = TRUE
        ))

        candidateViews[[1L]]$validGroups
      })
    })

    # Index of the currently-selected candidate grouping (issue #125 Slice 2),
    # clamped to the number of retained candidates -- mirrors `selectedGroup`
    # below, one level up (candidate solutions rather than groups within one
    # solution).
    selectedCandidateIdx <- reactive({
      res <- groupResults()
      req(!is.null(res))
      n <- length(res$candidates)
      req(n >= 1L)
      withinIntegerRange(input$candidateChoice, minimum = 1L,
                         maximum = n)[1L]
    })

    # Populate the candidate selector whenever a new formation result is
    # available. Mirrors the `viewGrp`-populating observe() below.
    observe({
      res <- groupResults()
      req(!is.null(res))
      n <- length(res$candidates)
      req(n >= 1L)
      scores <- vapply(res$candidates, function(cand) cand$score, numeric(1L))
      labels <- sprintf("Candidate %d (score %s)", seq_len(n), scores)
      updateSelectInput(session, "candidateChoice",
                        choices = stats::setNames(seq_len(n), labels),
                        selected = 1L)
    })

    # The currently-selected candidate's full view model (validGroups, score,
    # groupKin, unassigned, hasUnused) -- the single read point every reactive
    # below uses instead of repeating groupResults()$candidates[[idx]].
    selectedCandidate <- reactive({
      res <- groupResults()
      req(!is.null(res))
      res$candidates[[selectedCandidateIdx()]]
    })

    # The selected candidate's group-membership list -- a plain reactive(),
    # not an eventReactive, so switching candidates re-derives this without
    # re-invoking groupAddAssign() (only runFormation()'s own trigger,
    # input$formGroups, does that). Leaving candidateChoice at its default
    # (index 1, the best-scoring candidate) is byte-identical to pre-Slice-2
    # behavior.
    breedingGroups <- reactive({
      runFormation()
      selectedCandidate()$validGroups
    })

    output$candidateComparison <- renderTable({
      res <- groupResults()
      req(!is.null(res))
      data.frame(
        Candidate = seq_along(res$candidates),
        Score = vapply(res$candidates, function(cand) cand$score, numeric(1L)),
        Groups = vapply(res$candidates,
                        function(cand) length(cand$validGroups), integer(1L)),
        stringsAsFactors = FALSE
      )
    })

    # Issue #146 Slice 2 (D8): reports the exhaustive-mode search outcome for
    # the run that produced the currently-displayed candidates. NULL (no
    # output) when that run did not use exhaustive = TRUE.
    output$exhaustiveStatus <- renderUI({
      res <- groupResults()
      req(!is.null(res))
      if (is.null(res$exhaustive)) {
        return(NULL)
      }
      if (isTRUE(res$exhaustive)) {
        shiny::p(
          sprintf("Exhaustive: examined %d partition(s). %s",
                  res$examined, res$retentionRule),
          style = "color: green;"
        )
      } else {
        shiny::p(
          sprintf(paste("Exhaustive search truncated after examining %d",
                        "partition(s) before the time limit. %s"),
                  res$examined, res$retentionRule),
          style = "color: darkorange;"
        )
      }
    })

    # Seed-group textareas: one per requested group, shown only when seeding is
    # enabled. Namespaced via session$ns so each dynamically-created input reads
    # back as input[["curGrp<i>"]] inside this module.
    output$seedTextareas <- renderUI({
      req(isTRUE(input$seedGroups))
      numGp <- input$nGroups
      req(!is.null(numGp), !is.na(numGp), numGp >= 1L)
      do.call(tagList, lapply(seq_len(numGp), function(i) {
        textAreaInput(session$ns(paste0("curGrp", i)),
                      label = paste("Seed animals", i),
                      value = "", rows = 3L)
      }))
    })

    output$groupsDisplay <- renderUI({
      req(breedingGroups())
      ped <- pedigree()

      groupsList <- lapply(seq_along(breedingGroups()), function(i) {
        groupIds <- breedingGroups()[[i]]
        nAnimals <- length(groupIds)
        div(class = "panel panel-primary",
            div(class = "panel-heading",
                h4(sprintf("Group %d (%d animals)", i, nAnimals))),
            div(class = "panel-body",
                DT::DTOutput(session$ns(paste0("groupTable", i))))
        )
      })
      do.call(tagList, groupsList)
    })

    observe({
      req(breedingGroups())
      ped <- pedigree()

      lapply(seq_along(breedingGroups()), function(i) {
        output[[paste0("groupTable", i)]] <- DT::renderDT({
          groupIds <- breedingGroups()[[i]]
          # Create display data frame from IDs
          groupData <- ped[ped$id %in% groupIds,
                           c("id", "sex", "birth", "sire", "dam")]
          groupData
        }, options = list(pageLength = 10L, dom = "t"))
      })
    })

    output$groupStats <- renderTable({
      req(breedingGroups())
      ped <- pedigree()

      stats <- lapply(seq_along(breedingGroups()), function(i) {
        groupIds <- breedingGroups()[[i]]
        sexes <- ped$sex[ped$id %in% groupIds]
        data.frame(
          Group = i,
          Total = length(groupIds),
          Males = sum(sexes == sexCodes[["male"]], na.rm = TRUE),
          Females = sum(sexes == sexCodes[["female"]], na.rm = TRUE),
          stringsAsFactors = FALSE
        )
      })
      do.call(rbind, stats)
    })

    # ---- Group Detail tab: viewGrp selector + per-group member/kinship views

    # Selected group index, clamped to the number of groups actually formed.
    # length() rather than req(breedingGroups()) because an empty result is a
    # zero-length list, which req() treats as truthy.
    selectedGroup <- reactive({
      req(length(breedingGroups()) >= 1L)
      withinIntegerRange(input$viewGrp, minimum = 1L,
                         maximum = length(breedingGroups()))[1L]
    })

    # Populate the group selector when groups are (re)formed. When a non-empty
    # group of unused animals is present it is the last element, labelled
    # "Unused"; otherwise every element is labelled "Group i".
    observe({
      n <- length(breedingGroups())
      req(n >= 1L)
      labels <- paste("Group", seq_len(n))
      if (isTRUE(selectedCandidate()$hasUnused)) {
        labels[n] <- "Unused"
      }
      updateSelectInput(session, "viewGrp",
                        choices = stats::setNames(seq_len(n), labels),
                        selected = 1L)
    })

    # Annotated members (Ego ID / Sex / Age in Years) of the selected group.
    bgGroupView <- reactive({
      req(breedingGroups())
      ids <- breedingGroups()[[selectedGroup()]]
      gp <- addSexAndAgeToGroup(ids, pedigree())
      gp$age <- round(gp$age, 1L)
      colnames(gp) <- c("Ego ID", "Sex", "Age in Years")
      # method = "radix": Ego ID is a character column -- plain order() is
      # locale-dependent (Learning 585), method = "radix" is byte-order and
      # locale-independent.
      gp[order(gp$`Ego ID`, method = "radix"), , drop = FALSE]
    })

    # Within-group kinship submatrix of the selected group, derived from the
    # retained full kinship matrix (identical to groupAddAssign's groupKin
    # because the group's members are a subset of the candidate set).
    bgGroupKinView <- reactive({
      req(breedingGroups())
      res <- groupResults()
      req(!is.null(res$kmat))
      ids <- breedingGroups()[[selectedGroup()]]
      as.data.frame(as.matrix(round(filterKinMatrix(ids, res$kmat), 6L)))
    })

    output$groupMemberTable <- DT::renderDT(
      bgGroupView(),
      options = list(pageLength = 25L, dom = "t")
    )
    output$groupKinTable <- DT::renderDT(
      bgGroupKinView(),
      options = list(pageLength = 25L, dom = "t")
    )

    output$downloadGroup <- downloadHandler(
      filename = function() {
        getDatedFilename(paste0("Group-", input$viewGrp, ".csv"))
      },
      content = function(file) {
        write.csv(bgGroupView(), file, na = "", row.names = FALSE)
      }
    )
    output$downloadGroupKin <- downloadHandler(
      filename = function() {
        getDatedFilename(paste0("GroupKin-", input$viewGrp, ".csv"))
      },
      content = function(file) {
        write.csv(bgGroupKinView(), file, na = "", row.names = TRUE)
      }
    )

    list(
      groups = reactive(breedingGroups()),
      nGroups = reactive(length(breedingGroups())),
      score = reactive({
        res <- groupResults()
        if (is.null(res)) return(0L)
        selectedCandidate()$score
      }),
      unassigned = reactive({
        res <- groupResults()
        if (is.null(res)) return(character(0L))
        selectedCandidate()$unassigned
      }),
      groupKinship = reactive({
        res <- groupResults()
        if (is.null(res)) return(NULL)
        selectedCandidate()$groupKin
      })
    )
  })
}
