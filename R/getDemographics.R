#' Get demographic data
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#' This is a thin wrapper around \code{labkey.selectRows()}.
#'
#' @return A data.frame containing LabKey demographic data with the columns
#' specified in the single parameter provided.
#'
#' @examples
#' \donttest{
#' ## Needs a connection to a LabKey server
#' library(nprcgenekeepr)
#' siteInfo <- getSiteInfo()
#' colSet <- siteInfo$lkPedColumns
#' source <- " generated by getDemographics: "
#' pedSourceDf <- tryCatch(getDemographics(colSelect = colSet),
#'   warning = function(wCond) {
#'     cat(paste0("Warning", source, wCond),
#'       name = "nprcgenekeepr"
#'     )
#'     return(NULL)
#'   },
#'   error = function(eCond) {
#'     cat(paste0("Error", source, eCond),
#'       name = "nprcgenekeepr"
#'     )
#'     return(NULL)
#'   }
#' )
#' }
#'
#' @param colSelect (optional) a vector of comma separated strings specifying
#' which columns of a dataset or view to import
#' @importFrom Rlabkey labkey.selectRows
#' @export
getDemographics <- function(colSelect = NULL) {
  siteInfo <- getSiteInfo()
  demoDf <- labkey.selectRows(
    baseUrl = siteInfo$baseUrl, folderPath = siteInfo$folderPath,
    schemaName = siteInfo$schemaName, queryName = siteInfo$queryName,
    viewName = "", colSort = NULL, colFilter = NULL,
    containerFilter = NULL, colNameOpt = "fieldname",
    maxRows = NULL, colSelect = colSelect,
    showHidden = TRUE
  )
  demoDf
}
