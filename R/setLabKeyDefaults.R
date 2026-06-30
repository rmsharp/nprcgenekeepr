## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Configure Rlabkey authentication for the current session
#'
#' Sets up the credentials that \code{\link{getDemographics}} (and any other
#' \code{Rlabkey} call) uses to authenticate against the LabKey EHR server. An
#' API key, when available, is preferred; otherwise the function falls back to
#' a \code{.netrc}/\code{_netrc} file; when neither is present it stops with an
#' actionable error rather than letting \code{Rlabkey} fail later with an opaque
#' message.
#'
#' The API key is sourced, in order of precedence, from
#' \enumerate{
#'   \item the environment variable \code{NPRCGENEKEEPR_LABKEY_APIKEY}, then
#'   \item an \code{apiKey} entry in the nprcgenekeepr configuration file.
#' }
#' When an API key is found, \code{\link[Rlabkey]{labkey.setDefaults}} is called
#' with that key and \code{siteInfo$baseUrl}. When no API key is found, the
#' function checks for a netrc file (the \code{NETRC} environment variable,
#' then the home-directory \code{.netrc} on non-Windows or \code{_netrc} on
#' Windows) and, if present, leaves \code{Rlabkey} to use it. The API key is
#' never read from or written to the package sources; keep it in the
#' environment, the configuration file, or the netrc file only.
#'
#' @return Invisibly, a list with elements \code{method} (one of
#' \code{"apiKey"} or \code{"netrc"}) and \code{baseUrl}. Stops with an error
#' when no credential can be found.
#'
#' @param siteInfo list of site information as returned by
#' \code{\link{getSiteInfo}}. The elements used are \code{baseUrl},
#' \code{configFile}, \code{homeDir}, and \code{sysname}.
#' @importFrom Rlabkey labkey.setDefaults
#' @export
#' @examples
#' \donttest{
#' ## Requires an apiKey (env var or config) or a .netrc file to succeed.
#' library(nprcgenekeepr)
#' result <- tryCatch(
#'   setLabKeyDefaults(getSiteInfo(expectConfigFile = FALSE)),
#'   error = function(e) conditionMessage(e)
#' )
#' }
setLabKeyDefaults <- function(siteInfo = getSiteInfo()) {
  apiKey <- Sys.getenv("NPRCGENEKEEPR_LABKEY_APIKEY", unset = "")
  if (!nzchar(apiKey)) {
    apiKey <- getConfigApiKey(siteInfo$configFile)
  }
  if (nzchar(apiKey)) {
    labkey.setDefaults(apiKey = apiKey, baseUrl = siteInfo$baseUrl)
    return(invisible(list(method = "apiKey", baseUrl = siteInfo$baseUrl)))
  }
  if (hasNetrc(siteInfo$homeDir, siteInfo$sysname)) {
    return(invisible(list(method = "netrc", baseUrl = siteInfo$baseUrl)))
  }
  stop(
    "No LabKey credential found.\n",
    "Provide an API key in the environment variable ",
    "NPRCGENEKEEPR_LABKEY_APIKEY,\n",
    "or add an 'apiKey' entry to your configuration file (",
    siteInfo$configFile, "),\n",
    "or create a netrc file as described at\n",
    "https://www.labkey.org/Documentation/wiki-page.view?name=netrc\n"
  )
}
