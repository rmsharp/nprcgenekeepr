## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' getErrorTab skeleton of list of errors
#'
#' @return HTML formatted error list
#'
#' @param errorLst list of errors and changes made by \code{qcStudbook}
#' @param pedigreeFileName name of file provided by user on Input tab
#' @export
getErrorTab <- function(errorLst, pedigreeFileName) {
  tabPanel(
    "Error List",
    div(HTML(insertErrorTab(errorLst, pedigreeFileName)))
  )
}
