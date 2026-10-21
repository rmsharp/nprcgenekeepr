## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Pedigree Browser Shiny Module

#' How far the deceased slash reaches past a symbol's centre
#'
#' S1028. The distance from the centre of a circle to each end of the slash,
#' along each axis, as a fraction of the circle's radius. One number for the
#' slash the diagram draws and the slash in the legend's picture, so the two
#' overhang a circle by the same amount (the legend's amount: the line runs
#' 19 out from the centre of a circle of radius 22, 1.22 times the circle's
#' outline along the diagonal). The diagram scales it by each shape's outline
#' (\code{.deceasedOutlineFactors}) so every shape is overhung by that same
#' amount.
#' @noRd
.deceasedSlashReach <- 19 / 22

#' Each node shape's outline distance along the slash diagonal
#'
#' S1028. How far a shape's outline is from its centre along the diagonal of
#' the slash, in units of the node \code{size}: a circle 1, a square its
#' corner (the square root of 2), a diamond its edge (1 over the square root
#' of 2), a triangle its base corner, a star about 0.66 (measured on the
#' canvas, as are the others' analytic values). The names are vis.js shape
#' names, the shapes \code{makePedigreeMatingLayout()} gives its nodes.
#' @noRd
.deceasedOutlineFactors <- c(dot = 1, square = sqrt(2), diamond = 1 / sqrt(2),
                             triangle = 1.386, star = 0.66)

#' The afterDrawing handler that strokes the deceased slash
#'
#' S1028. visNetwork has no slash shape, so after each draw this strokes a
#' line from bottom-left to top-right through every node whose \code{deceased}
#' field is \code{TRUE}, sized from the node's own \code{size} and shape. The
#' text uses single quotes only: it travels inside a JSON string.
#' @param reach see \code{.deceasedSlashReach}.
#' @param outline see \code{.deceasedOutlineFactors}.
#' @return A JavaScript function, as a character string.
#' @noRd
.deceasedSlashHandler <- function(reach = .deceasedSlashReach,
                                  outline = .deceasedOutlineFactors) {
  sprintf(paste0(
    "function(ctx) {\n",
    "  var net = this;\n",
    "  var reach = %s;\n",
    "  var outline = {%s};\n",
    "  var marked = net.body.data.nodes.get(",
    "{filter: function(n) { return n.deceased === true; }});\n",
    "  if (marked.length === 0) { return; }\n",
    "  ctx.save();\n",
    "  ctx.lineWidth = 3;\n",
    "  ctx.lineCap = 'round';\n",
    "  ctx.strokeStyle = '#000000';\n",
    "  marked.forEach(function(n) {\n",
    "    var p = net.getPosition(n.id);\n",
    "    var r = (n.size || 25) * reach * (outline[n.shape] || 1);\n",
    "    ctx.beginPath();\n",
    "    ctx.moveTo(p.x - r, p.y + r);\n",
    "    ctx.lineTo(p.x + r, p.y - r);\n",
    "    ctx.stroke();\n",
    "  });\n",
    "  ctx.restore();\n",
    "}"
  ), format(reach, digits = 4L),
  paste0(names(outline), ": ", format(round(outline, 4L), trim = TRUE),
         collapse = ", "))
}

#' The legend's picture of a deceased animal: a circle with the slash
#'
#' S1028. The legend is its own vis.Network and cannot share the diagram's
#' handler, so its \dQuote{Deceased} row is an inline SVG image: a circle of
#' radius 22 with the slash drawn \code{reach} of that radius out from the
#' centre along each axis.
#' @param reach see \code{.deceasedSlashReach}.
#' @return A \code{data:} URI, as a character string.
#' @noRd
.deceasedLegendImage <- function(reach = .deceasedSlashReach) {
  offset <- reach * 22
  svg <- sprintf(paste0(
    "<svg xmlns='http://www.w3.org/2000/svg' width='50' height='50'>",
    "<circle cx='25' cy='25' r='22' fill='white' stroke='#2B7CE9' ",
    "stroke-width='2'/>",
    "<line x1='%.1f' y1='%.1f' x2='%.1f' y2='%.1f' stroke='black' ",
    "stroke-width='4' stroke-linecap='round'/></svg>"
  ), 25 - offset, 25 + offset, 25 + offset, 25 - offset)
  paste0("data:image/svg+xml;charset=utf-8,",
         utils::URLencode(svg, reserved = TRUE))
}

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

    # Issue #142 Slice 2: which edge style is currently selected, defaulting
    # to "rectilinear" (the default since S574, matching
    # makePedigreeMatingLayout()'s own edgeStyle default) before the style
    # toggle below has ever rendered, and the node cap that applies to it.
    .currentEdgeStyle <- function() {
      if (is.null(input$pedigreeEdgeStyle)) {
        "rectilinear"
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

    # nolint start: commented_code_linter.
    # Issue #137 Slice 3: whether the diagram shows twin/zygosity
    # connectors. Off by default (D11/backward-compat framing, matching
    # .currentShowNames()'s own precedent) -- has no visible effect unless
    # a valid twinRelationsFile has also been uploaded (see
    # twinRelationsData() below).
    # nolint end
    .currentShowTwinConnectors <- function() {
      if (is.null(input$pedigreeShowTwinConnectors)) {
        FALSE
      } else {
        input$pedigreeShowTwinConnectors
      }
    }

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
            radioButtons(
              session$ns("pedigreeEdgeStyle"),
              label = "Diagram Edge Style",
              choices = c(Direct = "direct",
                          "Rectilinear (kinship2-style)" = "rectilinear"),
              selected = style,
              inline = TRUE
            ),
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
            # (the legend shares the canvas's height).
            visNetwork::visNetworkOutput(session$ns("pedigreeDiagram"),
                                         height = "500px")
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
      layout <- diagramLayout()
      # nolint start: commented_code_linter.
      # Issue #137 Slice 3: the twin-connector legend rows (label + dashes
      # list-column + color), built the same way .buildTwinConnectorEdges()
      # builds the real connector edges' own columns -- static, unrelated to
      # whether any twin data is actually loaded (like the sex-shape/
      # Affected addNodes rows above it).
      # nolint end
      twinLegendEdges <- data.frame(
        label = c("MZ", "DZ", "?"),
        color = rep("#009E73", 3L),
        stringsAsFactors = FALSE
      )
      twinLegendEdges$dashes <- I(list(FALSE, c(4L, 4L), c(14L, 8L)))
      # S921: the dashed repeat-appearance link's legend row -- plain dashes
      # like dupEdges in R/makePedigreeDiagramData.R, color unset so it
      # follows the diagram's own edge color. It goes FIRST: the legend
      # rescales itself to fill its canvas and the Export button covers the
      # last row's right-hand end, so the last row has to stay the short "?"
      # one (confirmed hands-on, S921).
      legendEdges <- rbind(
        data.frame(label = "Same animal, again", color = NA_character_,
                   dashes = I(list(TRUE)), stringsAsFactors = FALSE),
        twinLegendEdges
      )
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
        visNetwork::visEvents(
          click = sprintf(
            "function(nodes) { Shiny.setInputValue('%s', nodes.nodes); }",
            session$ns("pedigreeDiagram_click")
          ),
          # S1028: the slash through each deceased animal's symbol.
          afterDrawing = .deceasedSlashHandler()
        ) |>
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
                       "Affected", "Deceased"),
            shape = c("dot", "square", "star", "triangle", "diamond",
                       "hexagon", "image"),
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
            color = c(NA, NA, NA, NA, NA, "#CC79A7", NA),
            # S1028: the "Deceased" row is a picture (a circle with the
            # slash), after "Affected" and before the edge rows, so the last
            # legend row stays the short "?" one (S921). Measured in the real
            # app: a label starts 11 world units under its symbol and is 14
            # tall, so a row takes its symbol (2 * size) plus 25 of the row
            # spacing (stepY). At the old size 20 and stepY 54 every label
            # overran the next symbol by 11; size 14 and stepY 60 leave 7
            # clear.
            image = c(rep(NA_character_, 6L), .deceasedLegendImage()),
            size = 14L,
            stringsAsFactors = FALSE
          ),
          # nolint start: commented_code_linter.
          # Issue #137 Slice 3 (D6/§2.8 trap #10): the twin-connector
          # legend rows, added via THIS SAME visLegend() call's addEdges
          # parameter -- confirmed by reading visLegend()'s own source
          # (Pre-RED) that addEdges passes straight through to
          # x$legend$edges with no validation, exactly like addNodes above,
          # so a second visLegend() call is not needed and would only
          # overwrite this one (same single-scalar-slot constraint the
          # #133 Affected-row comment above already established). Values
          # match .buildTwinConnectorEdges() (R/makePedigreeDiagramData.R)
          # exactly -- label + dashes + color (D10's #009E73 color pick,
          # found never wired at S494, fixed S506). S921: the same table
          # now also leads with the "Same animal, again" row for the dashed
          # repeat-appearance link (built above, where `legendEdges` is
          # made).
          # nolint end
          addEdges = legendEdges,
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
          # occupied. S1028: 11 rows now (the "Deceased" picture), in a 500px
          # canvas, at 60L (see the symbol size above).
          stepY = 60L
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
            # all. Raising it restores visible feedback for the common
            # case confirmed live (measured hop distances up to 4).
            #
            # KNOWN LIMITATION (S909, owner-ruled: keep 6). The hover
            # counts every edge, invisible waypoints included, so it can
            # stop short of an animal's own parents' union dot. Measured
            # on the 375-animal rhesus pedigree: hovering never lights
            # nothing (0 of 375), and 373 of 375 animals light everything
            # the direct style's degree 1 lights; the other 2 are 7 hops
            # from that dot because their sibship connectors were
            # rerouted through __jog_ waypoints. A pair with 9 or more
            # full siblings reaches the same limit on its own (the widest
            # bundled pedigree has 4). Raising the degree was declined to
            # keep the hover simple: 7 would light about 5 more nodes on
            # a typical hover (median 14 -> 19) to fix those 2 animals,
            # and no fixed degree covers a wide family. The owner notes
            # that some baboon pedigrees have more siblings (none is
            # bundled, so not measured here); revisit only when a user
            # asks. Measurements and scripts:
            # docs/audits/HIGHLIGHT_NEAREST_REACH_2026-10-05.md.
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
