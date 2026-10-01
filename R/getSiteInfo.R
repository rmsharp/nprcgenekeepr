## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get site information
#'
#' @param expectConfigFile logical parameter when set to \code{FALSE}, no
#' configuration is looked for. Default value is \code{TRUE}.
#' @return A named list of 20 elements of site specific information used by
#' the application.
#'
#' The first seven elements (\code{center}, \code{baseUrl},
#' \code{schemaName}, \code{folderPath}, \code{queryName},
#' \code{lkPedColumns} and \code{mapPedColumns}) are read from the
#' configuration file when one exists. A configuration file that lacks one of
#' these keys causes an error ("Could not find ..."). When no configuration
#' file exists, the defaults for the ONPRC are returned instead: center
#' "ONPRC", baseUrl \code{"https://primeuat.ohsu.edu"}, schemaName "study",
#' folderPath "/ONPRC/EHR" and queryName "demographics". A warning is
#' signaled for the missing file only when \code{expectConfigFile} is
#' \code{TRUE}.
#'
#' The returned list contains the following elements.
#' \enumerate{
#'   \item \code{center} -- center name, such as "ONPRC" or "SNPRC"
#'   \item \code{baseUrl} -- base URL of the LabKey server
#'   \item \code{schemaName} -- LabKey schema name
#'   \item \code{folderPath} -- LabKey folder path
#'   \item \code{queryName} -- LabKey query name, "demographics" by default
#'   \item \code{lkPedColumns} -- LabKey column names for the pedigree
#'   \item \code{mapPedColumns} -- the package column names that
#'   \code{lkPedColumns} are renamed to
#'   \item \code{sysname}, \code{release}, \code{version},
#'   \code{nodename}, \code{machine}, \code{login}, \code{user} and
#'   \code{effective_user} -- character strings from \code{Sys.info()}
#'   \item \code{homeDir} and \code{configFile} -- the home directory and
#'   the expected configuration file path, from
#'   \code{\link{getConfigFileName}}
#'   \item \code{requiredCols} -- the required studbook columns, from
#'   \code{\link{getRequiredCols}}
#'   \item \code{possibleCols} -- the possible studbook columns, from
#'   \code{\link{getPossibleCols}}
#'   \item \code{includeColumns} -- the superset of report-inclusion columns,
#'   from \code{\link{getIncludeColumns}}
#' }
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ## default sends warning if configuration file is missing
#' suppressWarnings(getSiteInfo())
#' getSiteInfo(expectConfigFile = FALSE)
getSiteInfo <- function(expectConfigFile = TRUE) {
  sysInfo <- Sys.info()
  config <- getConfigFileName(sysInfo)

  if (file.exists(config[["configFile"]])) {
    lines <- readLines(config[["configFile"]], skipNul = TRUE)
    tokenList <- getTokenList(lines)
    list(
      center = getParamDef(tokenList, "center"),
      baseUrl = getParamDef(tokenList, "baseUrl"),
      schemaName = getParamDef(tokenList, "schemaName"),
      folderPath = getParamDef(tokenList, "folderPath"),
      queryName = getParamDef(tokenList, "queryName"),
      lkPedColumns = getParamDef(tokenList, "lkPedColumns"),
      mapPedColumns = getParamDef(tokenList, "mapPedColumns"),
      sysname = sysInfo[["sysname"]],
      release = sysInfo[["release"]],
      version = sysInfo[["version"]],
      nodename = sysInfo[["nodename"]],
      machine = sysInfo[["machine"]],
      login = sysInfo[["login"]],
      user = sysInfo[["user"]],
      effective_user = sysInfo[["effective_user"]],
      homeDir = config[["homeDir"]],
      configFile = config[["configFile"]],
      requiredCols = getRequiredCols(),
      possibleCols = getPossibleCols(),
      includeColumns = getIncludeColumns()
    )
  } else {
    if (expectConfigFile) {
      warning(
        "The nprcgenekeepr configuration file is missing.\n",
        "It is required when the LabKey API is to be used.\n",
        "The file should be named: ",
        config[["configFile"]], ".\n"
      )
    }
    defaults <- defaultSiteParams()
    list(
      center = defaults[["center"]],
      baseUrl = defaults[["baseUrl"]],
      schemaName = defaults[["schemaName"]],
      folderPath = defaults[["folderPath"]],
      queryName = defaults[["queryName"]],
      lkPedColumns = defaults[["lkPedColumns"]],
      mapPedColumns = defaults[["mapPedColumns"]],
      sysname = sysInfo[["sysname"]],
      release = sysInfo[["release"]],
      version = sysInfo[["version"]],
      nodename = sysInfo[["nodename"]],
      machine = sysInfo[["machine"]],
      login = sysInfo[["login"]],
      user = sysInfo[["user"]],
      effective_user = sysInfo[["effective_user"]],
      homeDir = config[["homeDir"]],
      configFile = config[["configFile"]],
      requiredCols = getRequiredCols(),
      possibleCols = getPossibleCols(),
      includeColumns = getIncludeColumns()
    )
  }
}
