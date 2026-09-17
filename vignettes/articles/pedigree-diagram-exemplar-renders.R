# Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
#
# Regenerates the classic-structure exemplar diagrams in
# vignettes/articles/pedigree-diagram-img/ that "pedigree-diagram.qmd"'s
# "Reading classic breeding structures" section relies on -- one Rectilinear
# (the app's default edge style) render per bundled exemplar pedigree
# (inst/extdata/examples/example_pedigree_*.csv, shipped S692). Adapted from
# the S691 authoring session's scratchpad render script (chromote screenshot
# of a physics-off visNetwork widget, full-fit view computed from both x and
# y extents with an over-zoom cap); the resulting images were owner-approved
# at S691's visual gate, and their drawn structure is pinned by
# tests/testthat/test_examplePedigreeFixtures.R (S693) -- if that test file's
# spec list changes, re-run this script and get the new renders re-reviewed.
#
# Expected console output includes exactly two layout warnings, both
# owner-accepted at S691's visual gate (see the test file's
# rectilinearCollisionWarning pins): the linebreeding and half_sib
# Rectilinear layouts each report "2 same-row edge-node collision(s) could
# not be fully resolved". Any OTHER warning, or those warnings vanishing,
# means the engine changed -- stop and re-review before committing images.
#
# Run from the package root:
#   Rscript vignettes/articles/pedigree-diagram-exemplar-renders.R

suppressMessages(pkgload::load_all(".", quiet = TRUE))
suppressMessages({
  library(visNetwork)
  library(htmlwidgets)
})

structures <- c("consanguinity", "linebreeding", "backcross",
                "first_cousin", "half_sib")
outDir <- file.path("vignettes", "articles", "pedigree-diagram-img")
dir.create(outDir, showWarnings = FALSE, recursive = TRUE)
vw <- 1200L
vh <- 900L

for (structure in structures) {
  csv <- system.file("extdata", "examples",
                     paste0("example_pedigree_", structure, ".csv"),
                     package = "nprcgenekeepr", mustWork = TRUE)
  ped <- utils::read.csv(csv, stringsAsFactors = FALSE)
  warnings_seen <- character(0)
  layout <- withCallingHandlers(
    suppressMessages(makePedigreeMatingLayout(ped, edgeStyle = "rectilinear")),
    warning = function(w) {
      warnings_seen <<- c(warnings_seen, conditionMessage(w))
      invokeRestart("muffleWarning")
    }
  )

  cx <- mean(range(layout$nodes$x))
  cy <- mean(range(layout$nodes$y))
  xr <- max(diff(range(layout$nodes$x)), 1)
  yr <- max(diff(range(layout$nodes$y)), 1)
  sc <- min(0.88 * vw / xr, 0.88 * vh / yr, 1.2)
  cat(sprintf("%s rectilinear: %d nodes, %d edges, extent %.0f x %.0f%s\n",
              structure, nrow(layout$nodes), nrow(layout$edges), xr, yr,
              if (length(warnings_seen) > 0) {
                paste0("\n  warning: ", paste(warnings_seen, collapse = "; "))
              } else {
                ""
              }))

  widget <- visNetwork::visNetwork(layout$nodes, layout$edges,
                                   width = vw, height = vh) |>
    visNetwork::visPhysics(enabled = FALSE) |>
    visNetwork::visNodes(physics = FALSE) |>
    visNetwork::visEdges(smooth = FALSE)
  tmpHtml <- tempfile(fileext = ".html")
  htmlwidgets::saveWidget(widget, tmpHtml, selfcontained = TRUE)
  b <- chromote::ChromoteSession$new(width = vw, height = vh)
  b$go_to(paste0("file://", tmpHtml), delay = 2.5)
  b$Runtime$evaluate(sprintf(
    "HTMLWidgets.findAll('.visNetwork')[0].network.moveTo(
       {position: {x: %f, y: %f}, scale: %f, animation: false});",
    cx, cy, sc))
  Sys.sleep(0.8)
  shot <- b$Page$captureScreenshot(format = "png",
                                   captureBeyondViewport = FALSE)
  outPng <- file.path(outDir,
                      paste0("exemplar-", structure, "-rectilinear.png"))
  writeBin(jsonlite::base64_dec(shot$data), outPng)
  b$close()
  cat("->", outPng, "\n")
}
