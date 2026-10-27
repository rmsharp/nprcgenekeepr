## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Pedigree Browser Shiny Module

#' Pedigree Browser Module - UI Function
#'
#' Creates user interface for browsing and filtering pedigree data,
#' including focal animal selection (typed or pasted IDs, or an uploaded
#' file), trimming options, the Display Unknown IDs filter, and export. A
#' Diagram tab draws the pedigree (rectilinear or direct edge style, optional
#' names and twin connectors, PNG export, and click-to-focal), with a
#' twin/zygosity sidecar upload; the diagram is drawn only up to 400 animals
#' (rectilinear) or 750 animals (direct).
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @return A \code{div} object containing pedigree browser UI.
#'
#' @seealso \code{\link{modPedigreeServer}} for server logic.
#' @importFrom shiny NS div h3 h4 fluidRow column wellPanel helpText tags
#' @importFrom shiny fileInput actionButton checkboxInput downloadButton
#' @importFrom shiny includeHTML br uiOutput tabsetPanel tabPanel
#' @importFrom DT DTOutput
#' @family Shiny modules
#' @export
modPedigreeUI <- function(id) {

  ns <- NS(id)

  div(
    id = ns("moduleContainer"),
    `data-ready` = "false",
    `data-module` = "pedigree",

    h3("Pedigree Browser"),

    fluidRow(
      # Left panel - HTML documentation
      column(
        4L,
        div(
          style = paste(
            "padding: 10px; border: 1px solid lightgray;",
            "background-color: #EDEDED; border-radius: 25px;",
            "box-shadow: 0 0 5px 2px #888;"
          ),
          includeHTML(
            system.file("extdata", "ui_guidance", "pedigree_browser.html",
                        package = "nprcgenekeepr")
          )
        )
      ),

      # Middle panel - Focal animal input
      column(
        4L,
        wellPanel(
          h4("Focal Animals"),
          helpText(
            paste0(
              "Enter focal animal IDs here to analyze them instead of the ",
              "living animals; with none entered, the living animals are ",
              "analyzed (every animal if none is alive). IDs may be pasted ",
              "from Excel or you can browse for and select a file ",
              "containing the list of focal animals."
            ),
            style = "color: darkblue; font-weight: bold;"
          ),
          tags$textarea(
            id = ns("focalAnimalIds"),
            rows = 5L,
            cols = 40L,
            placeholder = "Enter animal IDs (one per line or comma-separated)"
          ),
          br(), br(),
          # Rendered server-side so "Clear Focal Animals" can reset the widget
          # (and its displayed file name) without a client-side dependency.
          uiOutput(ns("focalAnimalFileUI")),
          actionButton(
            ns("updateFocalAnimals"),
            label = "Update Focal Animals",
            icon = icon("sync"),
            class = "btn-primary btn-block"
          ),
          br(),
          checkboxInput(
            ns("clearFocalAnimals"),
            label = "Clear Focal Animals",
            value = FALSE
          ),
          helpText(
            paste0(
              "The search field below will search all columns for ",
              "matches to any text or number entered."
            ),
            style = "color: darkblue; font-weight: bold;"
          )
        )
      ),

      # Right panel - Options and export
      column(
        4L,
        wellPanel(
          h4("Display Options"),
          checkboxInput(
            ns("displayUnknownIds"),
            label = "Display Unknown IDs",
            value = TRUE
          ),
          helpText(
            style = "font-size: 14px; color: darkblue; font-weight: bold;",
            paste0(
              "Unknown IDs are created by the application for all animals ",
              "with only one parent. By default they are a capital U ",
              "followed by at least four capital letters or digits (the ",
              "format is configurable via setAutoIdFormat()); a real ",
              "animal whose ID merely starts with U, such as U1, is kept. ",
              "The placeholder column says which rows are made up: TRUE ",
              "hides the row, FALSE keeps it, so a real animal with an ",
              "ID such as U1234 can be marked FALSE in the uploaded file. ",
              "Unticking the box changes only this table: the other tabs ",
              "still use every animal."
            )
          ),
          br(),
          checkboxInput(
            ns("trimPedigree"),
            label = "Trim pedigree based on focal animals",
            value = FALSE
          ),
          helpText(
            style = "font-size: 14px; color: darkblue; font-weight: bold;",
            paste0(
              "Trim the pedigree to include only the ancestors and ",
              "descendants of the focal animals provided."
            )
          ),
          br(),
          downloadButton(
            ns("exportPedigree"),
            "Export Pedigree (CSV)",
            class = "btn-success btn-block"
          ),
          br(),
          helpText(
            "A population must be defined before proceeding to the ",
            "Genetic Value Analysis.",
            style = "color: darkblue; font-weight: bold;"
          )
        ),
        # Issue #137 Slice 3: the twin-relations sidecar upload lives in
        # this STATIC UI, never inside the dynamically re-rendered
        # pedigreeDiagramUI block below -- a fileInput has no value=
        # argument a fresh render could read back self-referentially the
        # way checkboxInput/radioButtons do (Learning 490's file-input
        # corollary), so keeping it outside any block that ever
        # re-executes is the only way to avoid silently discarding an
        # already-uploaded file. Mirrors R/modGeneticValue.R's
        # kinshipOverrideFile wellPanel (the closest existing precedent
        # for an optional, validated pairwise-data upload).
        wellPanel(
          h4("Twin/Zygosity Relations (optional)"), # nolint: nonportable_path_linter
          helpText(
            paste0(
              "Upload a twin zygosity sidecar file (CSV or Excel) with ",
              "columns id1, id2, code (MZ twin, DZ twin, or UZ twin) to ",
              "mark twin pairs with a connector on the Diagram tab. ",
              "Leave empty for no twin connectors."
            ),
            style = "color: darkblue; font-weight: bold;"
          ),
          fileInput(
            ns("twinRelationsFile"),
            label = NULL,
            accept = c(".csv", ".txt", ".xlsx", ".xls")
          )
        )
      )
    ),

    # Pedigree data table / diagram
    fluidRow(
      column(
        12L,
        br(),
        tabsetPanel(
          tabPanel("Table", DT::DTOutput(ns("pedigreeTable"))),
          tabPanel("Diagram", uiOutput(ns("pedigreeDiagramUI")))
        )
      )
    )
  )
}

#' Pedigree Browser Module - Server Function
#'
#' Server logic for pedigree browser module handling focal animal
#' selection (typed, pasted or uploaded, or set by clicking a diagram node),
#' pedigree processing, filtering (focal trim and the Display Unknown IDs
#' filter), the Diagram tab (edge style, names, twin connectors, PNG export),
#' the twin/zygosity sidecar upload, and data export.
#'
#' This module processes the studbook by:
#' \itemize{
#'   \item Adding a \code{population} column via \code{setPopulation()}:
#'     the focal animals, or the living animals when none are entered
#'   \item Adding a \code{pedNum} column via \code{findPedigreeNumber()}
#'   \item Ensuring a \code{gen} column exists via \code{findGeneration()}
#'   \item Optionally trimming to the ancestors and descendants of focal
#'     animals via \code{trimPedigree()} and \code{getDescendantPedigree()}
#' }
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param studbook reactive returning the cleaned studbook data from modInput.
#'
#' @return A list of reactive values:
#' \itemize{
#'   \item \code{pedigree} - Filtered pedigree for display (respects
#'     trim/unknown settings)
#'   \item \code{analysisPedigree} - The pedigree the other tabs analyze
#'     (focal-animal trim applied, no Display Unknown IDs filter, which
#'     affects only the table); \code{appServer} uses it, not
#'     \code{pedigree}, as the shared current pedigree
#'   \item \code{processedPedigree} - Full pedigree with population, pedNum,
#'     gen columns
#'   \item \code{focalAnimals} - Character vector of focal animal IDs
#'   \item \code{nAnimals} - Count of animals in filtered pedigree
#'   \item \code{populationCount} - Count of animals marked as population
#'   \item \code{isReady} - Logical indicating if pedigree data is ready.
#'     With no studbook loaded, \code{isReady()} and \code{nAnimals()} halt
#'     with a silent \code{\link[shiny]{req}} error instead of returning
#'     \code{FALSE} and 0
#'   \item \code{twinRelations} - The validated twin/zygosity sidecar
#'     (\code{NULL} if none uploaded, if invalid, or if no pair has both
#'     animals in \code{analysisPedigree}). Checked against the whole
#'     studbook, not the trimmed view: an id that is not in the studbook, or
#'     any other failure of \code{checkTwinRelations()}, shows an error
#'     notification and makes the whole sidecar \code{NULL}; a valid pair with
#'     an animal outside \code{analysisPedigree} (a focal-animal trim) is left
#'     out of this value, with no message. Unlike the Diagram tab's own
#'     rendering, this is the raw, ungated reactive -- not filtered by the
#'     "Show Twin Connectors" toggle -- so callers outside this module
#'     (e.g. \code{appServer}) see the validated data regardless of that
#'     toggle's state (BL-N Slice 3).
#' }
#'
#' @seealso \code{\link{modPedigreeUI}} for the UI component
#' @seealso \code{\link{setPopulation}} for population marking
#' @seealso \code{\link{trimPedigree}} for pedigree trimming
#' @seealso \code{\link{findPedigreeNumber}} for pedigree numbering
#' @seealso \code{\link{findGeneration}} for generation calculation
#'
#' @importFrom shiny moduleServer reactive reactiveVal eventReactive observe
#' @importFrom shiny renderUI req showNotification updateCheckboxInput
#' @importFrom shiny fileInput updateTextAreaInput radioButtons tagList
#' @importFrom DT renderDT
#' @importFrom utils read.csv write.csv
#' @family Shiny modules
#' @export
modPedigreeServer <- function(id, studbook) {
  moduleServer(id, function(input, output, session) {

    # Reactive value to store focal animal IDs
    focalIds <- reactiveVal(character(0L))

    # Bumping this key re-renders a fresh file input, which clears the file
    # name shown in the browser after a "Clear Focal Animals" action.
    fileInputKey <- reactiveVal(0L)
    # Remember the file path and text that were last cleared, so a subsequent
    # "Update" does not silently re-read content the user already cleared.
    clearedFilePath <- reactiveVal(NULL)
    clearedText <- reactiveVal(NULL)

    # Render the focal animal file input dynamically so it can be reset.
    output$focalAnimalFileUI <- renderUI({
      fileInputKey()
      fileInput(
        session$ns("focalAnimalFile"),
        "Choose CSV file with focal animals",
        multiple = FALSE,
        accept = c("text/csv", # nolint: nonportable_path_linter
                   "text/comma-separated-values,text/plain", # nolint: nonportable_path_linter
                   ".csv")
      )
    })

    # Parse focal animal IDs from text area or file
    observeEvent(input$updateFocalAnimals, {
      # Check if clearing
      if (input$clearFocalAnimals) {
        focalIds(character(0L))
        # Forget the currently loaded file and text so the next update does
        # not re-read them, and reset the file widget's displayed name.
        clearedFilePath(
          if (!is.null(input$focalAnimalFile)) {
            input$focalAnimalFile$datapath
          } else {
            NULL
          }
        )
        clearedText(input$focalAnimalIds)
        updateTextAreaInput(session, "focalAnimalIds", value = "")
        fileInputKey(fileInputKey() + 1L)
        showNotification("Focal animals cleared", type = "message")
        updateCheckboxInput(session, "clearFocalAnimals", value = FALSE)
        return()
      }

      ids <- character(0L)

      # Get IDs from text area (skipping text that was just cleared)
      textIds <- input$focalAnimalIds
      if (!is.null(textIds) && nzchar(trimws(textIds)) &&
            !identical(textIds, clearedText())) {
        # Split by newlines, commas, semicolons, or tabs
        ids <- unlist(strsplit(textIds, "[,;\t\n\r]+"))
        ids <- trimws(ids)
        ids <- ids[nzchar(ids)]
      }

      # Get IDs from uploaded file (skipping a file that was just cleared;
      # a newly chosen file has a different temp path and still loads)
      if (!is.null(input$focalAnimalFile) &&
            !identical(input$focalAnimalFile$datapath, clearedFilePath())) {
        tryCatch({
          fileData <- read.csv(input$focalAnimalFile$datapath,
                               stringsAsFactors = FALSE)
          # Assume first column contains IDs
          if (ncol(fileData) >= 1L) {
            fileIds <- as.character(fileData[[1L]])
            fileIds <- trimws(fileIds)
            fileIds <- fileIds[nzchar(fileIds)]
            ids <- unique(c(ids, fileIds))
          }
        }, error = function(e) {
          showNotification(
            paste("Error reading file:", e$message),
            type = "error"
          )
        })
      }

      focalIds(unique(ids))

      if (length(ids) > 0L) {
        showNotification(
          paste("Updated focal animals:", length(ids), "IDs"),
          type = "message"
        )
      } else {
        showNotification(
          "No focal animal IDs found",
          type = "warning"
        )
      }
    })

    # Process the pedigree with population marking and additional columns
    processedPedigree <- reactive({
      req(studbook())
      ped <- studbook()

      # Add population column using setPopulation
      # If focal animals specified, only those are marked as population
      # If no focal animals, the living animals are the population; with
      # nobody alive that is an empty list, which setPopulation() turns into
      # every animal
      focal <- focalIds()
      if (length(focal) == 0L) {
        focal <- ped$id[isLivingAnimal(ped)]
      }
      ped <- setPopulation(ped, focal)

      # Add pedNum column to identify separate pedigrees
      ped$pedNum <- findPedigreeNumber(ped$id, ped$sire, ped$dam)

      # Ensure gen column exists
      if (!"gen" %in% names(ped)) {
        ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
      }

      ped
    })

    # Trim to focal animals, their ancestors, and their descendants if
    # requested
    applyFocalTrim <- function(ped) {
      if (input$trimPedigree && length(focalIds()) > 0L) {
        focal <- focalIds()
        # Get focal animals that exist in pedigree
        probands <- focal[focal %in% ped$id]
        if (length(probands) > 0L) {
          # Include both ancestors (upward closure) and descendants (downward
          # closure) of the focal animals. Strict-lineal -- collateral
          # relatives (siblings, cousins, mates) are not included.
          ancestors <- trimPedigree(probands, ped, removeUninformative = FALSE,
                                    addBackParents = FALSE)
          descendants <- getDescendantPedigree(probands, ped)
          ped <- ped[ped$id %in% union(ancestors$id, descendants$id), ]
        }
      }

      ped
    }

    # Get the filtered pedigree data for display
    pedigreeData <- reactive({
      req(processedPedigree())
      ped <- processedPedigree()

      # Filter out unknown IDs if requested
      if (!input$displayUnknownIds) {
        # Auto-generated unknown IDs are detected via the shared predicate,
        # which reads the pedigree's placeholder mark when it has one
        ped <- ped[!isGeneratedUnknownId(ped$id, ped = ped), ]
      }

      applyFocalTrim(ped)
    })

    # The pedigree the other tabs analyze: the Display Unknown IDs box only
    # filters the table above, so a hidden stand-in never leaves its children
    # naming a parent the analysis cannot find. The focal-animal trim is a
    # deliberate narrowing and still applies.
    analysisPedigreeData <- reactive({
      req(processedPedigree())
      applyFocalTrim(processedPedigree())
    })

    # Render pedigree table
    output$pedigreeTable <- DT::renderDT({
      req(pedigreeData())
      pedigreeData()
    }, options = list(
      pageLength = 15L,
      scrollX = TRUE,
      search = list(regex = TRUE)
    ))

    # Pedigree diagram (issue #129 Slice 1). Above this many nodes, show an
    # informative message instead of rendering the widget rather than an
    # unbounded render. Re-derived for Option 2 Slice 3 (owner-directed,
    # S461): the mating-unit/duplicate transformation renders ~2x total
    # widget nodes per individual (740/375 = 1.973x, confirmed against the
    # real bundled fixture, Slices 1/2) -- 750 individuals keeps the total
    # rendered node count near the original ~1,500-node ceiling this cap was
    # actually calibrated for. This is BELOW the 962-individual focal-trim
    # example in vignettes/articles/colony-manager-guide.qmd -- accepted
    # (owner-directed) since that example was only ever evidenced through
    # the Table tab, never proven to render through the Diagram tab itself.
    pedigreeDiagramMaxNodes <- 750L

    # nolint start: commented_code_linter.
    # Issue #142 Slice 2: the rectilinear edge style's waypoint nodes
    # render ~3.667 total nodes per individual on the real 375-individual
    # fixture (vs. ~1.973 for the direct style), so the direct-style cap
    # above would let a rectilinear render grow ~1.86x larger for the same
    # animal count. Owner-ratified via AskUserQuestion (S468): preserve the
    # same ~1,480-node ceiling the direct cap targets (750 * 1.973), scaled
    # down for the rectilinear ratio (1,480 / 3.667 ~= 404) and rounded to a
    # clean number.
    # nolint end: commented_code_linter.
    pedigreeDiagramMaxNodesRectilinear <- 400L

    # S1074: the edge-style, Show Names and Show Twin Connectors controls are
    # drawn by pedigreeDiagramUI below after it has built the first layout,
    # and the browser reports the value each one shows when it binds it
    # (NULL -> "rectilinear", NULL -> FALSE). Read straight from input, that
    # report rebuilt the layout with the same settings: two builds per first
    # drawing, 3.9 s of the 708-animal example's in Direct. So each setting is
    # held in a reactiveVal, which ignores a value identical to the one it
    # holds; observeEvent() ignores a NULL input, so the default stands until
    # the control reports, and priority 1 updates it before the outputs that
    # read it run. Each .current*() below is such a reactiveVal; calling it
    # with no argument reads it.
    .heldSetting <- function(name, default) {
      value <- reactiveVal(default)
      observeEvent(input[[name]], value(input[[name]]), priority = 1L)
      value
    }

    # Issue #142 Slice 2: which edge style is currently selected, defaulting
    # to "rectilinear" (the default since S574, matching
    # makePedigreeMatingLayout()'s own edgeStyle default) before the style
    # toggle below has ever rendered, and the node cap that applies to it.
    .currentEdgeStyle <- .heldSetting("pedigreeEdgeStyle", "rectilinear")
    .currentDiagramCap <- function() {
      if (.currentEdgeStyle() == "rectilinear") {
        pedigreeDiagramMaxNodesRectilinear
      } else {
        pedigreeDiagramMaxNodes
      }
    }

    # The Diagram Edge Style buttons with `style` selected, drawn beside the
    # diagram and (S1077) beside the over-limit message when Direct can draw
    # the pedigree.
    .edgeStyleButtons <- function(style) {
      radioButtons(
        session$ns("pedigreeEdgeStyle"),
        label = "Diagram Edge Style",
        choices = c(Direct = "direct",
                    "Rectilinear (kinship2-style)" = "rectilinear"),
        selected = style,
        inline = TRUE
      )
    }

    # Issue #136 Slice 2: whether the diagram shows names alongside id.
    # Off by default (owner-ratified "some centers, inconsistently"
    # framing) -- defaulting to FALSE before the toggle below has ever
    # rendered means the very first render is byte-identical to
    # pre-issue-136 behavior, same pattern as .currentEdgeStyle() above.
    .currentShowNames <- .heldSetting("pedigreeShowNames", FALSE)

    # nolint start: commented_code_linter.
    # Issue #137 Slice 3: whether the diagram shows twin/zygosity
    # connectors. Off by default (D11/backward-compat framing, matching
    # .currentShowNames()'s own precedent) -- has no visible effect unless
    # a valid twinRelationsFile has also been uploaded (see
    # twinRelationsData() below).
    # nolint end
    .currentShowTwinConnectors <- .heldSetting("pedigreeShowTwinConnectors",
                                               FALSE)

    # nolint start: commented_code_linter.
    # Issue #137 Slice 3 (D5/D11): read + validate an uploaded twin
    # -relations sidecar file. Soft/non-fatal (mirrors
    # R/modGeneticValue.R's kinshipOverrideData precedent): a bad file
    # notifies and is ignored -- the diagram is never aborted. Returns NULL
    # when no file is uploaded or the file fails validation. Unlike
    # kinshipOverrideData, there is no warning-handling branch:
    # checkTwinRelations() only ever stop()s, it never warn()s (confirmed,
    # R/checkTwinRelations.R), so a warning handler here would be dead
    # code. Validated against studbook(), the whole pedigree the module
    # received, not the focal-trimmed view, so a twin pair with an animal
    # outside the view is still a valid pair. Each use gets only the pairs
    # whose two animals it holds: the diagram the view, the other tabs the
    # analysis pedigree. The diagram builder and kinship() both stop on an
    # id they do not hold.
    # nolint end
    twinRelationsData <- reactive({
      if (is.null(input$twinRelationsFile)) {
        return(NULL)
      }
      req(studbook())
      tryCatch(
        checkTwinRelations(
          studbook(),
          readTwinRelations(input$twinRelationsFile$datapath)
        ),
        error = function(e) {
          showNotification(
            paste("Could not read twin relations:", conditionMessage(e)),
            type = "error", duration = 10L
          )
          NULL
        }
      )
    })

    output$pedigreeDiagramUI <- renderUI({
      req(pedigreeData())
      n <- nrow(pedigreeData())
      style <- .currentEdgeStyle()
      cap <- .currentDiagramCap()
      if (n > cap && style == "rectilinear" && n <= pedigreeDiagramMaxNodes) {
        # S1077 (owner ruling "Buttons and wording"): Direct can draw this
        # pedigree, so the message keeps the edge-style buttons above it.
        tagList(
          .edgeStyleButtons(style),
          div(
            class = "alert alert-warning",
            sprintf(
              paste(
                "Diagram not shown: %d animals exceeds the %d-animal limit of",
                "the Rectilinear style. Choose Direct above to draw up to %d",
                "animals, or narrow the focal-animal selection."
              ),
              n, cap, pedigreeDiagramMaxNodes
            )
          )
        )
      } else if (n > cap) {
        div(
          class = "alert alert-warning",
          sprintf(
            paste(
              "Diagram not shown: %d animals exceeds the %d-animal display",
              "limit. Narrow the focal-animal selection to view a diagram."
            ),
            n, cap
          )
        )
      } else {
        # Issue #164, P5-suppression plan Phase 3 (Shiny UX messaging) --
        # makePedigreeMatingLayout() already suppresses fully-isolated
        # individuals (no sire, no dam, no mate, no children) from the
        # rendered diagram and reports them via isolatedIds (Phase 1);
        # surface that here rather than silently rendering fewer nodes.
        layout <- diagramLayout()
        isolatedIds <- layout$isolatedIds
        if (nrow(layout$nodes) == 0L && length(isolatedIds) > 0L) {
          # Dragon 3 (3B ratified S643) / Dragon 4: suppression emptied
          # the diagram entirely -- show an explicit message instead of a
          # blank widget. Singular wording when the rendered set was
          # exactly one individual (the Focal-Animal-trim-to-one-isolated-
          # individual case, plan Sec 1.2's 2nd trigger); plural otherwise
          # (the whole-colony/#164 case). Worked copy per plan Sec 3
          # Dragon 4.
          div(
            class = "alert alert-info",
            if (length(isolatedIds) == 1L) {
              sprintf(
                paste(
                  "%s has no recorded parents, mates, or offspring in this",
                  "data, so there is no pedigree relationship to diagram."
                ),
                isolatedIds
              )
            } else {
              sprintf(
                paste(
                  "None of the %d loaded individuals have any recorded",
                  "parent, mate, or offspring relationships, so there is",
                  "nothing to diagram. (See the Table tab.)"
                ),
                length(isolatedIds)
              )
            }
          )
        } else {
          # D4: no existing "home" for this control -- net-new UI layout
          # rendered alongside the widget, inside this same uiOutput, only
          # when a diagram is actually shown.
          tagList(
            if (length(isolatedIds) > 0L) {
              # Dragon 4: partial suppression -- the diagram itself still
              # renders below; this banner is the only signal a colony
              # manager gets that some individuals are missing from it.
              div(
                class = "alert alert-info",
                sprintf(
                  paste(
                    "%d individual(s) with no recorded parents, mates, or",
                    "offspring are not shown in this diagram: %s (see the",
                    "Table tab to find them)"
                  ),
                  length(isolatedIds), toString(isolatedIds)
                )
              )
            },
            .edgeStyleButtons(style),
            # Issue #136 Slice 2, decisions D3, D4, D6 -- no existing home
            # for this control either -- same D4 net-new-UI precedent as
            # the edge style toggle above. Off by default; has no visible
            # effect on a pedigree with no name column.
            #
            # value = .currentShowNames() (NOT a hardcoded FALSE) -- found
            # live (Phase 3E) that this renderUI() block re-executes on ANY
            # of its dependencies changing (e.g. switching edgeStyle, which
            # this control has nothing to do with), rebuilding the
            # checkbox from scratch each time. A hardcoded value = FALSE
            # silently discarded an already-on toggle the next time
            # anything else re-rendered this UI. Self-referential value,
            # mirroring the pre-existing edgeStyle radioButtons' own
            # selected = style pattern immediately above, fixes it.
            checkboxInput(
              session$ns("pedigreeShowNames"),
              label = "Show Names on Diagram",
              value = .currentShowNames()
            ),
            # nolint start: commented_code_linter.
            # Issue #137 Slice 3: same net-new-UI / self-referential-value
            # precedent as the two controls above (Learning 490) -- off by
            # default; has no visible effect unless a twinRelationsFile
            # has also been uploaded (twinRelationsData() above).
            # nolint end
            checkboxInput(
              session$ns("pedigreeShowTwinConnectors"),
              label = "Show Twin Connectors",
              value = .currentShowTwinConnectors()
            ),
            # S1028: 500 px, not the default 400, so the legend's 11 rows
            # fit at a readable size with no label touching the next symbol
            # (the legend shares the canvas's height). S1029: 45 px more for
            # each legend row past the 11th (.diagramHeight()).
            visNetwork::visNetworkOutput(
              session$ns("pedigreeDiagram"),
              height = sprintf("%dpx", .diagramHeight(nrow(layout$conditions)))
            ),
            if (length(layout$conditionsNotDrawn) > 0L) {
              # S1029: kinship2 draws at most four conditions; say which
              # columns were left out rather than dropping them silently.
              div(
                class = "alert alert-info",
                sprintf(
                  paste("Only the first four affected columns are drawn.",
                        "Not drawn: %s."),
                  toString(layout$conditionsNotDrawn)
                )
              )
            }
          )
        }
      }
    })

    # Shared between the render below and the click-to-navigate observer
    # (Option 2 Slice 3, D6) so both see the same duplicateToReal lookup
    # without recomputing the mating-unit forest twice.
    diagramLayout <- reactive({
      req(pedigreeData())
      data <- pedigreeData()
      req(nrow(data) <= .currentDiagramCap())
      # Issue #136 Slice 2: the mating-layout builder is unconditionally
      # name-column-aware (same optional-column contract as affected) --
      # the toggle lives entirely at this layer by controlling whether the
      # name column even reaches the builder, rather than adding a new
      # builder parameter.
      if (!.currentShowNames()) {
        data$name <- NULL
      }
      # Issue #137 Slice 3 (D11): the toggle gates whether the validated
      # twinRelations data even reaches the builder -- same pattern as the
      # name-column gate immediately above -- rather than a post-hoc filter
      # on the builder's own output.
      twinRelations <- if (.currentShowTwinConnectors()) {
        .twinPairsWithin(twinRelationsData(), data)
      } else {
        NULL
      }
      makePedigreeMatingLayout(data, edgeStyle = .currentEdgeStyle(),
                               twinRelations = twinRelations)
    })

    output$pedigreeDiagram <- visNetwork::renderVisNetwork({
      # S1030: the whole picture is drawPedigreeDiagram()'s, so a script
      # that calls it draws what this tab draws. Only the click wiring is
      # the app's: it sends the clicked node to click-to-navigate below.
      drawPedigreeDiagram(
        diagramLayout(),
        edgeStyle = .currentEdgeStyle(),
        onClick = sprintf(
          "function(nodes) { Shiny.setInputValue('%s', nodes.nodes); }",
          session$ns("pedigreeDiagram_click")
        )
      )
    })

    # Click-to-navigate (issue #129 Slice 2): clicking a diagram node sets it
    # as the new focal-animal selection, reusing the same focalIds path the
    # focal-animal textarea already drives. A background (no-node) click
    # sends an empty nodes.nodes array -- guarded against here so it does not
    # clear the current selection.
    #
    # Option 2 Slice 3 (D6): a click on a mating-unit node is a no-op (it
    # has no corresponding animal to navigate to); a click on a duplicate
    # node resolves to its real individual via the layout's own
    # duplicateToReal lookup, so clicking any occurrence of a duplicated
    # individual navigates identically to clicking their anchor occurrence.
    # Issue #142 D3: the 3 new rectilinear waypoint-node prefixes get the
    # same no-op treatment as "__union_" -- they carry no clickable
    # identity. This exclusion deliberately stays separate from "__dup_",
    # which must remain clickable (see the paragraph above).
    observeEvent(input$pedigreeDiagram_click, {
      clickedNodes <- input$pedigreeDiagram_click
      req(length(clickedNodes) > 0L)
      ids <- as.character(clickedNodes)
      ids <- ids[!grepl("^__union_|^__drop_|^__bar_|^__proj_", ids)]
      req(length(ids) > 0L)
      duplicateToReal <- diagramLayout()$duplicateToReal
      isDup <- ids %in% names(duplicateToReal)
      ids[isDup] <- unname(duplicateToReal[ids[isDup]])
      focalIds(unique(ids))
    })

    # Signal data-ready when pedigree is available (for E2E testing)
    observe({
      req(pedigreeData())
      session$sendCustomMessage("setDataReady", list(
        selector = paste0("#", session$ns("moduleContainer")),
        ready = TRUE
      ))
    })

    # Export handler
    output$exportPedigree <- downloadHandler(
      filename = function() {
        paste0("pedigree_", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(pedigreeData(), file, row.names = FALSE)
      }
    )

    # Return reactive values for use by other modules
    list(
      pedigree = reactive({
        pedigreeData()
      }),
      analysisPedigree = reactive({
        analysisPedigreeData()
      }),
      processedPedigree = reactive({
        processedPedigree()
      }),
      focalAnimals = reactive({
        focalIds()
      }),
      nAnimals = reactive({
        nrow(pedigreeData())
      }),
      populationCount = reactive({
        ped <- processedPedigree()
        sum(ped$population, na.rm = TRUE)
      }),
      isReady = reactive({
        !is.null(pedigreeData()) && nrow(pedigreeData()) > 0L
      }),
      # BL-N Slice 3: the raw, ungated twinRelationsData() reactive, so
      # appServer can thread a declared twin identity into kinship-driven
      # calculations app-wide -- not just this tab's own diagram rendering
      # (which stays gated behind "Show Twin Connectors", untouched here).
      # Narrowed to the pairs whose two animals are in the analysis pedigree,
      # the pedigree those calculations run on.
      twinRelations = reactive({
        .twinPairsWithin(twinRelationsData(), analysisPedigreeData())
      })
    )
  })
}
