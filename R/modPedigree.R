## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Pedigree Browser Shiny Module

#' Pedigree Browser Module - UI Function
#'
#' Creates user interface for browsing and filtering pedigree data,
#' including focal animal selection, trimming options, and export.
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
              "IDs of selected focal animals may be manually ",
              "entered here if analysis of all individuals is ",
              "not needed. IDs may be pasted from Excel or you ",
              "can browse for and select a file containing the list ",
              "of focal animals."
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
              "Unknown IDs, by default beginning with a capital U (the ",
              "format is configurable via setAutoIdFormat()), are created ",
              "by the application for all animals with only one parent."
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
#' selection, pedigree processing, filtering, and data export.
#'
#' This module processes the studbook by:
#' \itemize{
#'   \item Adding a \code{population} column via \code{setPopulation()}
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
#'   \item \code{processedPedigree} - Full pedigree with population, pedNum,
#'     gen columns
#'   \item \code{focalAnimals} - Character vector of focal animal IDs
#'   \item \code{nAnimals} - Count of animals in filtered pedigree
#'   \item \code{populationCount} - Count of animals marked as population
#'   \item \code{isReady} - Logical indicating if pedigree data is ready
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
      # If no focal animals, all animals are in population
      # If focal animals specified, only those are marked as population
      focal <- focalIds()
      ped <- setPopulation(ped, focal)

      # Add pedNum column to identify separate pedigrees
      ped$pedNum <- findPedigreeNumber(ped$id, ped$sire, ped$dam)

      # Ensure gen column exists
      if (!"gen" %in% names(ped)) {
        ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
      }

      ped
    })

    # Get the filtered pedigree data for display
    pedigreeData <- reactive({
      req(processedPedigree())
      ped <- processedPedigree()

      # Filter out unknown IDs if requested
      if (!input$displayUnknownIds) {
        # Auto-generated unknown IDs are detected via the shared predicate
        ped <- ped[!isGeneratedUnknownId(ped$id), ]
      }

      # Trim to focal animals, their ancestors, and their descendants if
      # requested
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

    # Issue #142 Slice 2: which edge style is currently selected, defaulting
    # to "direct" before the style toggle below has ever rendered (so the
    # very first render is byte-identical to pre-issue-142 behavior), and
    # the node cap that applies to it.
    .currentEdgeStyle <- function() {
      if (is.null(input$pedigreeEdgeStyle)) {
        "direct"
      } else {
        input$pedigreeEdgeStyle
      }
    }
    .currentDiagramCap <- function() {
      if (.currentEdgeStyle() == "rectilinear") {
        pedigreeDiagramMaxNodesRectilinear
      } else {
        pedigreeDiagramMaxNodes
      }
    }

    # Issue #136 Slice 2: whether the diagram shows names alongside id.
    # Off by default (owner-ratified "some centers, inconsistently"
    # framing) -- defaulting to FALSE before the toggle below has ever
    # rendered means the very first render is byte-identical to
    # pre-issue-136 behavior, same pattern as .currentEdgeStyle() above.
    .currentShowNames <- function() {
      if (is.null(input$pedigreeShowNames)) {
        FALSE
      } else {
        input$pedigreeShowNames
      }
    }

    output$pedigreeDiagramUI <- renderUI({
      req(pedigreeData())
      n <- nrow(pedigreeData())
      style <- .currentEdgeStyle()
      cap <- .currentDiagramCap()
      if (n > cap) {
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
        # D4: no existing "home" for this control -- net-new UI layout
        # rendered alongside the widget, inside this same uiOutput, only
        # when a diagram is actually shown.
        tagList(
          radioButtons(
            session$ns("pedigreeEdgeStyle"),
            label = "Diagram Edge Style",
            choices = c(Direct = "direct",
                        "Rectilinear (kinship2-style)" = "rectilinear"),
            selected = style,
            inline = TRUE
          ),
          # Issue #136 Slice 2, decisions D3, D4, D6 -- no existing home
          # for this control either -- same D4 net-new-UI precedent as the
          # edge style toggle above. Off by default; has no visible effect
          # on a pedigree with no name column.
          #
          # value = .currentShowNames() (NOT a hardcoded FALSE) -- found
          # live (Phase 3E) that this renderUI() block re-executes on ANY
          # of its dependencies changing (e.g. switching edgeStyle, which
          # this control has nothing to do with), rebuilding the checkbox
          # from scratch each time. A hardcoded value = FALSE silently
          # discarded an already-on toggle the next time anything else
          # re-rendered this UI. Self-referential value, mirroring the
          # pre-existing edgeStyle radioButtons' own selected = style
          # pattern immediately above, fixes it.
          checkboxInput(
            session$ns("pedigreeShowNames"),
            label = "Show Names on Diagram",
            value = .currentShowNames()
          ),
          visNetwork::visNetworkOutput(session$ns("pedigreeDiagram"))
        )
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
      makePedigreeMatingLayout(data, edgeStyle = .currentEdgeStyle())
    })

    output$pedigreeDiagram <- visNetwork::renderVisNetwork({
      layout <- diagramLayout()
      # Option 2 Slice 3: fixed x/y coordinates (S457's proven Case C2
      # geometry) replace visHierarchicalLayout() entirely -- confirmed
      # hands-on (Learning 446) that manual coordinates and hierarchical
      # layout are mutually exclusive in vis.js.
      visNetwork::visNetwork(layout$nodes, layout$edges) |>
        visNetwork::visPhysics(enabled = FALSE) |>
        visNetwork::visNodes(physics = FALSE) |>
        visNetwork::visEdges(smooth = FALSE) |>
        # visNetwork does not auto-bind node clicks to a Shiny input -- wire
        # it explicitly (confirmed hands-on, issue #129 Slice 2 Pre-RED).
        visNetwork::visEvents(click = sprintf(
          "function(nodes) { Shiny.setInputValue('%s', nodes.nodes); }",
          session$ns("pedigreeDiagram_click")
        )) |>
        # Image export (issue #131): visExport() bundles its own JS deps
        # (FileSaver/Blob/canvas-toBlob/html2canvas/jsPDF) as htmlwidget
        # dependencies -- no CDN calls, confirmed hands-on Pre-RED.
        visNetwork::visExport(
          type = "png", name = "pedigree_diagram",
          label = "Export Diagram (PNG)"
        ) |>
        # Shape-to-sex legend (issue #132): renders as its own, separate
        # vis.Network instance (confirmed in the visNetwork.js source,
        # Pre-RED) -- its clicks do not reach the click-to-navigate handler
        # bound above via visEvents().
        visNetwork::visLegend(
          addNodes = data.frame(
            label = c("Female", "Male", "Hermaphrodite", "Unknown",
                       "Other / Unrecorded", # nolint: nonportable_path_linter
                       "Affected"),
            shape = c("dot", "square", "star", "triangle", "diamond",
                       "hexagon"),
            # Issue #133 Slice 2 (D6): the "Affected" row shares this SAME
            # addNodes data frame -- a second visLegend() call would
            # overwrite, not stack (confirmed S485). The 5 sex-shape rows
            # get NA here, preserving their existing unset-color rendering;
            # only the new row carries a color, reusing Slice 1's D8 swatch.
            # "hexagon" (not "box") -- confirmed hands-on this session that
            # vis.js sizes "box" to its label text (renders as a filled
            # pill/badge), breaking the fixed-size-icon-plus-separate-label
            # style all 5 existing rows share; "hexagon" is a fixed-size icon
            # like the other 5, none of which claim it.
            color = c(NA, NA, NA, NA, NA, "#CC79A7"),
            stringsAsFactors = FALSE
          ),
          useGroups = FALSE,
          position = "right",
          main = "Sex",
          # Default width (0.2) clips the longest label ("Other /
          # Unrecorded") against the legend canvas's own overflow:hidden
          # boundary (confirmed hands-on, Pre-RED) -- widened enough for it
          # to render in full.
          width = 0.28,
          # Default stepY (100) spaces 5 entries across 400 world-units,
          # which does not comfortably fit the widget's fixed 400px height
          # alongside the export button below it (confirmed hands-on,
          # Pre-RED) -- tightened so all 5 legend rows render without
          # crowding the button. Issue #133 Slice 2 (Dragon #4): the 6th
          # ("Affected") row's own label was confirmed hands-on to clip
          # against this same 400px boundary at stepY=65L (the icon itself
          # rendered, but "Affected" text below it did not) -- retuned to
          # 54L so 6 rows fit within the same envelope 5 rows previously
          # occupied.
          stepY = 54L
        ) |>
        # Search + highlight (issue #135): nodesIdSelection adds a
        # "Select by id" dropdown; highlightNearest dims non-connected
        # nodes. hover = TRUE (not visOptions()'s own click-based default)
        # so the highlight trigger is hover, not click -- click is already
        # bound above to click-to-navigate (issue #129 Slice 2), and the
        # two would otherwise both fire on the same click. NOTE: the list
        # key is "hover", not "hoverNearest" -- the latter is only the name
        # of the OUTPUT JSON field this produces (confirmed against
        # visNetwork:::visOptions()'s source, PROJECT_LEARNINGS.md
        # Learning 443).
        #
        # KNOWN TRADE-OFF (Learning 443, owner-accepted): nodesIdSelection
        # injects its own Shiny-bound <select> elements client-side,
        # outside this renderUI()-wrapped container's normal diff cycle.
        # From the SECOND reactive re-render onward (e.g. two consecutive
        # click-to-navigate actions), this can log one transient, benign
        # "[shiny] Duplicate input IDs were found" console warning -- the
        # DOM always ends with exactly one live element (no permanent
        # duplication) and all diagram interactivity keeps working
        # correctly afterward (verified hands-on via shinytest2/chromote).
        # Root cause is visNetwork's own client-side widget lifecycle, not
        # this package's code; a structural fix (e.g. visNetworkProxy()
        # incremental updates instead of a full renderVisNetwork()
        # re-render) was judged disproportionate to what the audit itself
        # scored "optional, low-priority... UI polish" and would risk the
        # three already-shipped Diagram-tab features above (click-to-
        # navigate, export, legend).
        #
        # Option 2 Slice 3 (D6): nodesIdSelection's own "values" option
        # (confirmed in visOptions()'s source) restricts the dropdown to an
        # explicit id list -- filtered here to real individuals only, so a
        # real individual appears once in the searchable list, not once per
        # mating-unit/duplicate occurrence.
        #
        # Issue #136 Slice 2 (D6): the useLabels dropdown option is pinned
        # to FALSE UNCONDITIONALLY (not toggle-dependent) -- without it,
        # the moment a real individual's label becomes a name (show-names
        # toggle on), visNetwork's own useLabels-defaults-TRUE behavior
        # (unset before this session) would silently switch the dropdown
        # to listing names while its caption still reads "Select by id"
        # (confirmed hands-on Pre-RED, design doc sec 2.5).
        visNetwork::visOptions(
          nodesIdSelection = list(
            enabled = TRUE, useLabels = FALSE, values = layout$nodes$id[
              !grepl("^__union_|^__dup_|^__drop_|^__bar_|^__proj_",
                     layout$nodes$id)
            ]
          ),
          highlightNearest = list(
            enabled = TRUE, hover = TRUE,
            # Issue #142 D3 (live-confirmed regression, S468): under the
            # rectilinear style, a plain individual's nearest edge-graph
            # neighbor is often an invisible __bar_/__drop_/__proj_
            # waypoint rather than a visible union dot, so degree = 1L
            # (correct for the direct style, where degree 1 always
            # reaches a visible node) can highlight nothing visible at
            # all. Raising it is a bounded mitigation, not a full fix --
            # very wide sibships (a long D1 bar chain) can still exceed
            # it -- but it restores visible feedback for the common case
            # confirmed live (measured hop distances up to 4).
            degree = if (.currentEdgeStyle() == "rectilinear") 6L else 1L,
            algorithm = "all"
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
      })
    )
  })
}
