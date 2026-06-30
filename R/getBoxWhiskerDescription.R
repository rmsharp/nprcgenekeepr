## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get Box and Whisker Plot Description
#'
#' Returns a description of how box and whisker plots work, suitable for
#' use in popovers and tooltips in the Shiny application.
#'
#' @return Character string containing the box and whisker plot description
#'   explaining whiskers, IQR (inter-quartile range), and outliers.
#'
#' @seealso \code{\link{modSummaryStatsServer}} which uses this for popovers
#' @export
#' @examples
#' desc <- getBoxWhiskerDescription()
#' cat(desc)
#'
getBoxWhiskerDescription <- function() {
  paste0(
    "The upper whisker extends from the hinge to ",
    "the largest value no further than 1.5 * IQR ",
    "from the hinge (where IQR is the ",
    "inter-quartile range, or distance between ",
    "the first and third quartiles). The lower ",
    "whisker extends from the hinge to the ",
    "smallest value at most 1.5 * IQR of the ",
    "hinge. Data beyond the end of the whiskers ",
    "are called \"outlying\" points and are plotted ",
    "individually."
  )
}
