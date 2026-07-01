## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Build the error-list tab panel
#'
#' @param errorLst list of errors and changes made by \code{qcStudbook}
#' @param pedigreeFileName name of file provided by user on Input tab
#' @return HTML formatted error list
#'
#' @export
getErrorTab <- function(errorLst, pedigreeFileName) {
  tabPanel(
    "Error List",
    div(HTML(insertErrorTab(errorLst, pedigreeFileName)))
  )
}
