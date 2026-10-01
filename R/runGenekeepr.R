## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Run the GeneKeepR Shiny Application
#'
#' Launches the GeneKeepR Shiny application. It uses a module-based
#' architecture with a Home tab and improved UI components. The call blocks
#' the R session until the application is stopped.
#'
#' @details
#' The application has 16 top-level tabs (15 when the ORIP Reporting tab is
#' hidden) and a "More" menu (Settings, About, Help):
#' \itemize{
#'   \item Home tab with navigation buttons
#'   \item Input tab with enhanced QC display, plus dynamic error and changed
#'     columns tabs
#'   \item Pedigree Browser with focal animal support and a Diagram tab
#'   \item Age-Sex Pyramid with enhanced controls
#'   \item Genetic Value Analysis with visualizations
#'   \item Summary Statistics with popovers
#'   \item ORIP Reporting (shown only for the ONPRC site configuration)
#'   \item Breeding Groups with group panels
#'   \item Mate Pair Analysis
#'   \item Genetic Diversity
#'   \item Marker Genetics
#'   \item Cross-Center Identity
#'   \item De-Identified Export
#'   \item Potential Parents
#'   \item Genetic Value Analysis and Breeding Group Description
#'   \item Genetic-Health Trends
#' }
#'
#' \code{\link{runModularApp}} is a soft-deprecated alias for this function.
#'
#' @param port Integer port number for the Shiny server (default 6013)
#' @param launch.browser Logical; whether to launch browser (default TRUE)
#'
#' @return Called for its side effect; blocks until the app is stopped.
#'   Returns, invisibly, the value passed to \code{shiny::stopApp()}
#'   (normally \code{NULL}).
#'
#' @seealso \code{\link{runModularApp}}, a soft-deprecated alias for this
#'   function.
#' @importFrom shiny shinyApp runApp
#' @export
#' @examples
#' \dontrun{
#' library(nprcgenekeepr)
#' runGeneKeepR()
#' }
runGeneKeepR <- function(port = 6013L, launch.browser = TRUE) { # nolint: object_name_linter
  app <- shiny::shinyApp(
    ui = appUI(),
    server = appServer
  )
  shiny::runApp(app, port = port, launch.browser = launch.browser)
}
