## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Load the site configuration for the modular Shiny application
#'
#' Reads the user's site-configuration file (\code{~/.nprcgenekeepr_config}, or
#' \code{~/_nprcgenekeepr_config} on Windows) using the tolerant
#' \code{\link{getSiteInfo}} parser, which handles the documented configuration
#' format (comment lines, blank lines, and multi-line / quoted /
#' comma-separated values; see
#' \code{inst/extdata/example_nprcgenekeepr_config}). The call is wrapped in
#' \code{tryCatch} so that a missing or malformed configuration file can never
#' crash the application on boot: in that case a warning is logged and
#' \code{NULL} is returned.
#'
#' This replaces a former \code{read.table(sep = "=")} call in the application
#' server that assumed a strict two-column table, could not parse the documented
#' format, and crashed \code{\link{runGeneKeepR}} at startup.
#'
#' @return A named list of site information (as returned by
#' \code{\link{getSiteInfo}}) when a configuration file is present and
#' parseable; otherwise \code{NULL}.
#'
#' @seealso \code{\link{getSiteInfo}}, \code{\link{getConfigFileName}},
#'  \code{\link{appServer}}
#' @importFrom futile.logger flog.warn
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ## Reads ~/.nprcgenekeepr_config (or ~/_nprcgenekeepr_config on
#' ## Windows) if it exists; returns NULL when no config file is
#' ## present, so this is safe to run on any machine.
#' config <- loadSiteConfig()
#' config
loadSiteConfig <- function() {
  configFile <- getConfigFileName(Sys.info())[["configFile"]]
  if (is.null(configFile) || !file.exists(configFile)) {
    return(NULL)
  }
  tryCatch(
    getSiteInfo(expectConfigFile = FALSE),
    error = function(e) {
      futile.logger::flog.warn(
        "Failed to load site configuration file '%s': %s",
        configFile, conditionMessage(e),
        name = "nprcgenekeepr"
      )
      NULL
    }
  )
}
