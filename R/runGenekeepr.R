#' Allows running \code{shiny} application with
#' \code{nprcgenekeepr::runGeneKeepR()}
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Run the GeneKeepR Shiny Application
#'
#' @param ... Additional arguments passed to shiny::runApp()
#'
#' @export
#' @examples
#' \dontrun{
#' library(nprcgenekeepr)
#' runGeneKeepR()
#' }
runGeneKeepR <- function(...) {

  # Ensure required packages are loaded
  requireNamespace("shiny", quietly = TRUE)
  requireNamespace("ggplot2", quietly = TRUE)
  requireNamespace("dplyr", quietly = TRUE)
  requireNamespace("DT", quietly = TRUE)

  # Add resource paths if you have www directory
  www_path <- system.file("www", package = "nprcgenekeepr")
  if (dir.exists(www_path)) {
    shiny::addResourcePath("www", www_path)
  }

  # Create the app
  app <- shiny::shinyApp(
    ui = appUI(),
    server = appServer,
    options = list(...)
  )

  # Run the app
  shiny::runApp(app, ...)
}
