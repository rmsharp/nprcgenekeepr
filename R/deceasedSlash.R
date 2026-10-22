## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# The deceased-animal slash of the Pedigree Browser's Diagram (S1028)

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
.deceasedSlashReach <- 19.0 / 22.0

#' Each node shape's outline distance along the slash diagonal
#'
#' S1028. How far a shape's outline is from its centre along the diagonal of
#' the slash, in units of the node \code{size}: a circle 1, a square its
#' corner (the square root of 2), a diamond its edge (1 over the square root
#' of 2), a triangle its base corner, a star about 0.66 (measured on the
#' canvas, as are the others' analytic values). The names are vis.js shape
#' names, the shapes \code{makePedigreeMatingLayout()} gives its nodes.
#' @noRd
.deceasedOutlineFactors <- c(dot = 1.0, square = sqrt(2.0),
                             diamond = 1.0 / sqrt(2.0),
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
  offset <- reach * 22.0
  svg <- sprintf(paste0(
    "<svg xmlns='http://www.w3.org/2000/svg' width='50' height='50'>",
    "<circle cx='25' cy='25' r='22' fill='white' stroke='#2B7CE9' ",
    "stroke-width='2'/>",
    "<line x1='%.1f' y1='%.1f' x2='%.1f' y2='%.1f' stroke='black' ",
    "stroke-width='4' stroke-linecap='round'/></svg>"
  ), 25.0 - offset, 25.0 + offset, 25.0 + offset, 25.0 - offset)
  paste0("data:image/svg+xml;charset=utf-8,",
         utils::URLencode(svg, reserved = TRUE))
}
