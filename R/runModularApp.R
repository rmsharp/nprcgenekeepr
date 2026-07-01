## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Run the Modular Version of GeneKeepR
#'
#' Launches the modularized Shiny application for testing purposes.
#' This version uses the new module-based architecture with a Home tab
#' and improved UI components.
#'
#' @details
#' This function runs the modular version of the application which includes:
#' \itemize{
#'   \item Home tab with navigation buttons
#'   \item Modular Input tab with enhanced QC display
#'   \item Dynamic error and changed columns tabs
#'   \item Enhanced Pedigree Browser with focal animal support
#'   \item Genetic Value Analysis with visualizations
#'   \item Summary Statistics with popovers
#'   \item Breeding Groups with group panels
#'   \item Age-Sex Pyramid with enhanced controls
#' }
#'
#' Use \code{\link{runGeneKeepR}} to run the original monolithic version.
#'
#' @param port Integer port number for the Shiny server (default 6013)
#' @param launch.browser Logical; whether to launch browser (default TRUE)
#'
#' @return Returns the error condition of the Shiny application when it
#'   terminates.
#'
#' @importFrom shiny shinyApp runApp
#' @export
#' @examples
#' \dontrun{
#' library(nprcgenekeepr)
#' runModularApp()
#' }
runModularApp <- function(port = 6013L, launch.browser = TRUE) { # nolint: object_name_linter
  app <- shiny::shinyApp(
    ui = appUI(),
    server = appServer
  )
  shiny::runApp(app, port = port, launch.browser = launch.browser)
}
