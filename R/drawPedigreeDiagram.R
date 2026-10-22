## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# The Pedigree Browser's Diagram, drawn by one function a script can call
# (S1030)

#' Draw the Pedigree Browser's Diagram from a mating layout
#'
#' Returns the interactive diagram the Pedigree Browser's Diagram tab shows,
#' as a \code{visNetwork} widget, for a layout made by
#' \code{\link{makePedigreeMatingLayout}}. The Shiny application draws its
#' Diagram with this function, so a script that calls it gets the same
#' picture: the sex symbols at the layout's fixed positions, the legend (the
#' five sex symbols, one row per affected condition or a single
#' \dQuote{Affected} row, \dQuote{Deceased}, and the dashed repeat-appearance
#' and twin lines), each multi-condition symbol split into its colored
#' sections, the slash through each deceased animal's symbol, a canvas that
#' grows with the number of conditions, the \strong{Export Diagram (PNG)}
#' button, a \dQuote{Select by id} box that lists the animals, and the
#' highlight on hover. The sections and the slash are painted by a drawing
#' script inside the widget, so they appear wherever the widget is shown: in the
#' RStudio viewer, in an R Markdown or Quarto document, or in a web page saved
#' with \code{htmlwidgets::saveWidget()}.
#'
#' Clicking an animal re-centers the Shiny application's Diagram on it; that
#' needs a live Shiny session, so a script leaves \code{onClick} out.
#'
#' @param layout the list returned by \code{\link{makePedigreeMatingLayout}}.
#' @param edgeStyle the \code{edgeStyle} the layout was made with,
#'   \code{"rectilinear"} (the default) or \code{"direct"}. It sets how far
#'   the hover highlight reaches: 6 steps under \code{"rectilinear"}, whose
#'   invisible routing points count as steps, and 1 under \code{"direct"}.
#' @param onClick \code{NULL} (the default), or a JavaScript function, as a
#'   character string, that runs when the diagram is clicked. The Shiny
#'   application passes one that sends the clicked animal to the server.
#' @return A \code{visNetwork} widget, 500 pixels tall, 45 more for each
#'   affected condition past the first (at most four are drawn).
#' @seealso \code{\link{makePedigreeMatingLayout}}
#' @examples
#' library(nprcgenekeepr)
#' layout <- makePedigreeMatingLayout(nprcgenekeepr::smallPed)
#' diagram <- drawPedigreeDiagram(layout)
#' ## Print `diagram` in an interactive session to see it, or save it as a web
#' ## page with htmlwidgets::saveWidget(diagram, "pedigree.html").
#' @export
drawPedigreeDiagram <- function(layout, edgeStyle = c("rectilinear",
                                                      "direct"),
                                onClick = NULL) {
  if (!is.list(layout) || is.data.frame(layout) ||
        !is.data.frame(layout$nodes) || !is.data.frame(layout$edges)) {
    stop("drawPedigreeDiagram() requires 'layout' to be the list ",
         "makePedigreeMatingLayout() returns, with 'nodes' and 'edges' ",
         "data frames.")
  }
  edgeStyle <- match.arg(edgeStyle)
  if (!is.null(onClick) &&
        (!is.character(onClick) || length(onClick) != 1L || is.na(onClick))) {
    stop("drawPedigreeDiagram() requires 'onClick' to be NULL or one ",
         "JavaScript function, as a character string.")
  }
  # [[ ]], not $: `layout$conditions` would partially match
  # `conditionsNotDrawn` in a layout that lacks `conditions`.
  conditions <- layout[["conditions"]]
  nConditions <- if (is.null(conditions)) 0L else nrow(conditions)
  # nolint start: commented_code_linter.
  # Issue #137 Slice 3: the twin-connector legend rows (label + dashes
  # list-column + color), built the same way .buildTwinConnectorEdges()
  # builds the real connector edges' own columns -- static, unrelated to
  # whether any twin data is actually loaded (like the sex-shape/
  # Affected addNodes rows above it).
  # nolint end
  # S1029: one legend row per condition, in place of the single
  # "Affected" row; the one row stays when the pedigree has no
  # condition column, as before.
  legendConditions <- if (nConditions > 0L) {
    conditions
  } else {
    data.frame(label = "Affected", color = .conditionColors[[1L]],
               stringsAsFactors = FALSE)
  }
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
  # layout are mutually exclusive in vis.js. S1028/S1029: the height is
  # .diagramHeight()'s, which the Shiny application also gives its output.
  visNetwork::visNetwork(layout$nodes, layout$edges,
                         height = sprintf("%dpx",
                                          .diagramHeight(nConditions))) |>
    visNetwork::visPhysics(enabled = FALSE) |>
    visNetwork::visNodes(physics = FALSE) |>
    visNetwork::visEdges(smooth = FALSE) |>
    # visNetwork does not auto-bind node clicks to a Shiny input -- the
    # application wires it explicitly through onClick (confirmed hands-on,
    # issue #129 Slice 2 Pre-RED); a NULL onClick adds no click event.
    visNetwork::visEvents(
      click = onClick,
      # S1029: the sections of each multi-condition symbol, then
      # S1028's slash through each deceased animal's symbol on top.
      afterDrawing = .diagramAfterDrawing(nConditions >= 2L)
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
                  legendConditions$label, "Deceased"),
        shape = c("dot", "square", "star", "triangle", "diamond",
                  rep("hexagon", nrow(legendConditions)), "image"),
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
        color = c(NA, NA, NA, NA, NA, legendConditions$color, NA),
        # S1028: the "Deceased" row is a picture (a circle with the
        # slash), after "Affected" and before the edge rows, so the last
        # legend row stays the short "?" one (S921). Measured in the real
        # app: a label starts 11 world units under its symbol and is 14
        # tall, so a row takes its symbol (2 * size) plus 25 of the row
        # spacing (stepY). At the old size 20 and stepY 54 every label
        # overran the next symbol by 11; size 14 and stepY 60 leave 7
        # clear.
        image = c(rep(NA_character_, 5L + nrow(legendConditions)),
                  .deceasedLegendImage()),
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
        degree = if (edgeStyle == "rectilinear") 6L else 1L,
        algorithm = "all"
      )
    )
}
