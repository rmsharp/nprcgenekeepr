#' Run the GeneKeepR Shiny Application
#'
#' Launches the nprcgenekeepr Shiny application for pedigree analysis
#' and genetic value calculations.
#'
#' @return Returns the error condition of the Shiny application when it
#' terminates.
#'
#' @importFrom shiny runApp
#' @export
#' @examples
#' if (interactive()) {
#'   library(nprcgenekeepr)
#'   runGeneKeepR()
#' }
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
runGeneKeepR <- function() {
  appDir <- system.file("application", package = "nprcgenekeepr")
  if (appDir == "") {
    stop(
        "Could not find application directory. ",
        "Try re-installing `nprcgenekeepr`.",
      call. = FALSE
    )
  }

  shiny::runApp(appDir, display.mode = "normal", port = 6012L)
}
