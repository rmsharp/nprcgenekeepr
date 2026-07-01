## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Build the changed-columns tab panel
#'
#' @param errorLst list of errors and changes made by \code{qcStudbook}
#' @param pedigreeFileName name of file provided by user on Input tab
#' @return HTML formatted error list
#'
#' @export
getChangedColsTab <- function(errorLst, pedigreeFileName) {
  tabPanel(
    "Changed Columns",
    div(HTML(insertChangedColsTab(errorLst, pedigreeFileName)))
  )
}
