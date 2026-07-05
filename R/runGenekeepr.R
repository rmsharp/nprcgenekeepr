## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Run the GeneKeepR Shiny Application
#'
#' Launches the GeneKeepR Shiny application. It uses a module-based
#' architecture with a Home tab and improved UI components.
#'
#' @details
#' The application includes:
#' \itemize{
#'   \item Home tab with navigation buttons
#'   \item Input tab with enhanced QC display
#'   \item Dynamic error and changed columns tabs
#'   \item Enhanced Pedigree Browser with focal animal support
#'   \item Genetic Value Analysis with visualizations
#'   \item Summary Statistics with popovers
#'   \item Breeding Groups with group panels
#'   \item Age-Sex Pyramid with enhanced controls
#' }
#'
#' \code{\link{runModularApp}} is a soft-deprecated alias for this function.
#'
#' @param port Integer port number for the Shiny server (default 6013)
#' @param launch.browser Logical; whether to launch browser (default TRUE)
#'
#' @return Returns the error condition of the Shiny application when it
#'   terminates.
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
