## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get site information
#'
#' @param expectConfigFile logical parameter when set to \code{FALSE}, no
#' configuration is looked for. Default value is \code{TRUE}.
#' @return A list of site specific information used by the application.
#'
#' Currently this returns the following character strings in a named list.
#' \enumerate{
#'   \item \code{center} -- One of "SNPRC" or "ONPRC"
#'   \item \code{baseUrl} -- If \code{center} is "SNPRC", baseUrl is one of
#'   "https://boomer.txbiomed.local:8080/labkey" or
#'   "https://vger.txbiomed.local:8080/labkey".
#'   To allow testing, if \code{center} is "ONPRC" baseUrl is
#'   "https://boomer.txbiomed.local:8080/labkey".
#'   \item \code{schemaName} -- If \code{center} is "SNPRC", schemaName is
#'   "study". If \code{center} is "ONPRC", schemaName is "study"
#'   \item \code{folderPath} -- If \code{center} is "SNPRC", folderPath is
#'   "/SNPRC". If \code{center} is "ONPRC", folderPath is "/ONPRC"
#'   \item \code{queryName} -- is "demographics"
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
      configFile = config[["configFile"]]
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
      configFile = config[["configFile"]]
    )
  }
}
