## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Run the Modular Version of GeneKeepR (Deprecated)
#'
#' \code{runModularApp()} has been renamed to \code{\link{runGeneKeepR}}, a
#' name that says what the function does. \code{runModularApp()} is now a
#' soft-deprecated alias that launches the application via
#' \code{\link{runGeneKeepR}}, passing all arguments through. Existing callers
#' continue to work. Called directly, it emits a lifecycle message ("was
#' deprecated in nprcgenekeepr 2.0.0"); soft deprecation is silent for calls
#' made from inside another package.
#'
#' @param port Integer port number for the Shiny server (default 6013)
#' @param launch.browser Logical; whether to launch browser (default TRUE)
#'
#' @return Called for its side effect; blocks until the app is stopped.
#'   Returns, invisibly, the value passed to \code{shiny::stopApp()}
#'   (normally \code{NULL}), as \code{\link{runGeneKeepR}} does.
#'
#' @seealso \code{\link{runGeneKeepR}}, the function this now launches.
#' @export
#' @examples
#' \dontrun{
#' library(nprcgenekeepr)
#' runModularApp()
#' }
runModularApp <- function(port = 6013L, launch.browser = TRUE) { # nolint: object_name_linter
  lifecycle::deprecate_soft(
    when = "2.0.0",
    what = "runModularApp()",
    with = "runGeneKeepR()",
    details = paste(
      "runModularApp() has been renamed;",
      "runGeneKeepR() now launches the application."
    )
  )
  runGeneKeepR(port = port, launch.browser = launch.browser)
}
