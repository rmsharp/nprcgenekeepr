## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# More than one affected condition on the Pedigree Browser's Diagram (S1029)

#' The colors of the affected conditions, in order
#'
#' S1029. Condition 1 keeps the pink a lone \code{affected} column has always
#' had (\code{.affectedColor()}); the other three are the colour-blind-safe
#' Okabe-Ito orange, sky blue and bluish green. kinship2 allows four
#' conditions, so the length of this vector is the most the Diagram draws.
#' @noRd
.conditionColors <- c("#CC79A7", "#E69F00", "#56B4E9", "#009E73")

#' The pedigree columns that are affected conditions
#'
#' S1029 (owner ruling). Every column whose name starts with
#' \code{affected}, in the order the pedigree holds them. QC lower-cases a
#' header and drops its spaces, periods and underscores, so the test reads the
#' name as written: a raw data frame with \code{Affected2} has no such
#' column, as it never had \code{affected}.
#' @param ped data frame.
#' @return character vector of column names, \code{character(0)} for none.
#' @noRd
.conditionColumns <- function(ped) {
  grep("^affected", names(ped), value = TRUE)
}

#' What the legend and the tooltip call each condition
#'
#' S1029. \dQuote{Affected} for the column \code{affected}, \dQuote{Affected 2}
#' where the rest of the name is a number, and \dQuote{Affected (diabetes)}
#' for the rest of the name otherwise. A separator left at the front of the
#' rest (\code{affected_diabetes} in a raw data frame) is dropped.
#' @param columns character vector of condition column names.
#' @return character vector, as long as \code{columns}.
#' @noRd
.conditionLabels <- function(columns) {
  vapply(columns, function(column) {
    rest <- sub("^[._ -]+", "", sub("^affected", "", column))
    if (!nzchar(rest)) {
      "Affected"
    } else if (grepl("^[0-9]+$", rest)) {
      paste("Affected", rest)
    } else {
      sprintf("Affected (%s)", rest)
    }
  }, character(1L), USE.NAMES = FALSE)
}

#' The afterDrawing handler that paints the sections of a symbol
#'
#' S1029. With two or more conditions the layout gives each animal's node an
#' \code{affectedSections} string, one character per condition: \code{"1"}
#' where the animal is affected. visNetwork has no sectioned shape, so after
#' each draw this clips to the node's own outline (the same paths vis.js
#' draws: a circle, a square, a diamond, a triangle, a star) and fills the
#' affected sections, equal pie sections counter-clockwise from the top (the
#' first of two is the left half), then strokes the outline and the section
#' lines again so an open section still reads as one. The text uses single
#' quotes only: it travels inside a JSON string.
#' @param colors the fill of each condition, in order.
#' @return A JavaScript function, as a character string.
#' @noRd
.conditionSectionsHandler <- function(colors = .conditionColors) {
  paste0(
    "function(ctx) {\n",
    "  var net = this;\n",
    "  var colors = [",
    paste0("'", colors, "'", collapse = ", "), "];\n",
    "  var animals = net.body.data.nodes.get({filter: function(n) {",
    " return typeof n.affectedSections === 'string' &&",
    " n.affectedSections.length > 1; }});\n",
    "  if (animals.length === 0) { return; }\n",
    "  var trace = function(shape, x, y, s) {\n",
    "    ctx.beginPath();\n",
    "    if (shape === 'square') {\n",
    "      ctx.rect(x - s, y - s, 2 * s, 2 * s);\n",
    "    } else if (shape === 'diamond') {\n",
    "      ctx.moveTo(x, y + s); ctx.lineTo(x + s, y);\n",
    "      ctx.lineTo(x, y - s); ctx.lineTo(x - s, y);\n",
    "    } else if (shape === 'triangle') {\n",
    "      var r = s * 1.15, yy = y + 0.275 * r, o = 2 * r, h = o / 2;\n",
    "      var ir = Math.sqrt(3) / 6 * o, a = Math.sqrt(o * o - h * h);\n",
    "      ctx.moveTo(x, yy - (a - ir)); ctx.lineTo(x + h, yy + ir);\n",
    "      ctx.lineTo(x - h, yy + ir);\n",
    "    } else if (shape === 'star') {\n",
    "      var q = s * 0.82, yq = y + 0.1 * q;\n",
    "      for (var j = 0; j < 10; j++) {\n",
    "        var rr = (j % 2 === 0) ? 1.3 * q : 0.5 * q;\n",
    "        ctx.lineTo(x + rr * Math.sin(2 * j * Math.PI / 10),",
    " yq - rr * Math.cos(2 * j * Math.PI / 10));\n",
    "      }\n",
    "    } else {\n",
    "      ctx.arc(x, y, s, 0, 2 * Math.PI);\n",
    "    }\n",
    "    ctx.closePath();\n",
    "  };\n",
    "  ctx.save();\n",
    "  ctx.lineWidth = 1;\n",
    "  animals.forEach(function(n) {\n",
    "    var p = net.getPosition(n.id), s = n.size || 25;\n",
    "    var k = n.affectedSections.length, d = 2 * Math.PI / k;\n",
    "    var border = (n.color && n.color.border) || '#2B7CE9';\n",
    "    ctx.save();\n",
    "    trace(n.shape, p.x, p.y, s);\n",
    "    ctx.clip();\n",
    "    for (var i = 0; i < k; i++) {\n",
    "      var from = -Math.PI / 2 - (i + 1) * d, to = -Math.PI / 2 - i * d;\n",
    "      if (n.affectedSections.charAt(i) === '1') {\n",
    "        ctx.beginPath();\n",
    "        ctx.moveTo(p.x, p.y);\n",
    "        ctx.arc(p.x, p.y, 3 * s, from, to, false);\n",
    "        ctx.closePath();\n",
    "        ctx.fillStyle = colors[i];\n",
    "        ctx.fill();\n",
    "      }\n",
    "    }\n",
    "    ctx.strokeStyle = border;\n",
    "    for (var m = 0; m < k; m++) {\n",
    "      var edge = -Math.PI / 2 - m * d;\n",
    "      ctx.beginPath();\n",
    "      ctx.moveTo(p.x, p.y);\n",
    "      ctx.lineTo(p.x + 3 * s * Math.cos(edge),",
    " p.y + 3 * s * Math.sin(edge));\n",
    "      ctx.stroke();\n",
    "    }\n",
    "    ctx.restore();\n",
    "    ctx.strokeStyle = border;\n",
    "    trace(n.shape, p.x, p.y, s);\n",
    "    ctx.stroke();\n",
    "  });\n",
    "  ctx.restore();\n",
    "}"
  )
}

#' The one afterDrawing handler of the Diagram
#'
#' S1029. visNetwork takes one \code{afterDrawing} function, so this runs the
#' section painter first and the S1028 deceased slash after it, which puts the
#' slash on top of the sections. Each is called with the network as
#' \code{this}.
#' @param sections \code{TRUE} when the pedigree has two or more conditions,
#'   so some node carries \code{affectedSections}; the section painter is left
#'   out otherwise.
#' @return A JavaScript function, as a character string.
#' @noRd
.diagramAfterDrawing <- function(sections = FALSE) {
  if (!sections) {
    return(.deceasedSlashHandler())
  }
  paste0(
    "function(ctx) {\n",
    "  (", .conditionSectionsHandler(), ").call(this, ctx);\n",
    "  (", .deceasedSlashHandler(), ").call(this, ctx);\n",
    "}"
  )
}

#' The height of the Diagram's canvas, in pixels
#'
#' S1029. The legend shares the canvas, rescaling itself to fill it. At 500 px
#' its 11 rows read at 0.70 of full size (standalone widget, then the real
#' app); every legend row past the 11th adds 66 world units to the legend, so
#' the canvas grows 45 px (66 times 0.70, rounded) per extra row to keep the
#' text the same size. A pedigree with no condition draws the single
#' \dQuote{Affected} row, as does one with a single condition, so both keep
#' 500 px.
#' @param nConditions number of conditions drawn, 0 to 4.
#' @return integer pixels.
#' @noRd
.diagramHeight <- function(nConditions) {
  500L + 45L * max(as.integer(nConditions) - 1L, 0L)
}
