## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Determine if the ORIP Reporting tab should be displayed
#'
#' Determines whether the Oregon (ONPRC)-specific ORIP Reporting tab should be
#' shown in the application navigation. ORIP (Office of Research Infrastructure
#' Programs) grant reporting is specific to ONPRC, so the tab is shown only when
#' an actual site configuration file is present \emph{and} it identifies the
#' colony as ONPRC. The \code{\link{getSiteInfo}} default fallback
#' (\code{center = "ONPRC"} when no configuration file exists) does NOT show the
#' tab.
#'
#' @param center Character scalar naming the colony center, as returned by
#'   \code{getSiteInfo()$center} (e.g. "ONPRC" or "SNPRC"). \code{NULL}, missing
#'   values, or any value other than "ONPRC" yield FALSE.
#' @param hasConfigFile Logical scalar indicating whether an actual site
#'   configuration file is present (e.g.
#'   \code{file.exists(getSiteInfo()$configFile)}). When FALSE the colony center
#'   is the default fallback and the tab is not shown.
#'
#' @return Logical. TRUE if a real ONPRC configuration is active and the tab
#'   should be shown, FALSE otherwise.
#'
#' @seealso \code{\link{getSiteInfo}} for the site configuration source and
#'   \code{\link{shouldShowChangedColsTab}} for the sibling tab-visibility
#'   predicate.
#' @export
#' @examples
#' library(nprcgenekeepr)
#' shouldShowOripTab("ONPRC", TRUE)  # TRUE
#' shouldShowOripTab("SNPRC", TRUE)  # FALSE
#' shouldShowOripTab("ONPRC", FALSE) # FALSE (default fallback, no config file)
shouldShowOripTab <- function(center, hasConfigFile) {
  isTRUE(hasConfigFile) && isTRUE(center == "ONPRC")
}
