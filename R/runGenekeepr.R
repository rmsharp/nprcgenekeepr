#' Run the GeneKeepR Shiny Application (Deprecated)
#'
#' The original monolithic Shiny application has been retired.
#' \code{runGeneKeepR()} is now a soft-deprecated alias that launches the
#' modular application via \code{\link{runModularApp}}. Existing
#' zero-argument callers continue to work.
#'
#' @param port Integer port number for the Shiny server (default 6013).
#' @param launch.browser Logical; whether to launch a browser (default TRUE).
#'
#' @return Returns the error condition of the Shiny application when it
#'   terminates (from \code{\link{runModularApp}}).
#'
#' @seealso \code{\link{runModularApp}} for the modular application this
#'   now launches.
#' @export
#' @examples
#' if (interactive()) {
#'   library(nprcgenekeepr)
#'   runGeneKeepR()
#' }
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
runGeneKeepR <- function(port = 6013L, launch.browser = TRUE) { # nolint: object_name_linter
  lifecycle::deprecate_soft(
    when = "1.1.0",
    what = "runGeneKeepR()",
    with = "runModularApp()",
    details = paste(
      "The monolithic Shiny application has been retired;",
      "runGeneKeepR() now launches the modular application."
    )
  )
  runModularApp(port = port, launch.browser = launch.browser)
}
