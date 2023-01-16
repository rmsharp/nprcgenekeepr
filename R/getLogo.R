#' Get Logo file name
#'
## Copyright(c) 2017-2023 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @return A character vector of length one having the name of the logo file
#' used in the \code{Input} tab. A warning is returned if the configuration
#' file is not found.
#'
#' @examples
#' \donttest{
#' result = tryCatch({
#'   getLogo()
#' }, warning = function(w) {
#' print(paste0("Warning in getLogo: ", w, ". File is to be ",
#'              suppressWarnings(getLogo())$file))
#' }, error = function(e) {
#' print(paste0("Error in in getLogo: ", e))
#' })
#'
#' }
#' @export
getLogo <- function() {
  logo <- list()
  if (getSiteInfo()$center == "SNPRC") {
    logo$file <- "../nprcgenekeepr_2_color_logo.jpg"
    logo$height <- 200L
    logo$width <- 350L
  } else {
    logo$file <- "../nprcgenekeepr_2_color_logo.jpg"
    logo$height <- 200L
    logo$width <- 350L
  }
  logo
}
