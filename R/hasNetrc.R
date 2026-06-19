#' Determine whether an Rlabkey-usable netrc file is present
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Checks the \code{NETRC} environment variable first, then the home directory
#' (\code{.netrc} on non-Windows, \code{_netrc} on Windows).
#'
#' @return Logical; \code{TRUE} when a netrc file is found.
#' @param homeDir home directory to search for a netrc file.
#' @param sysname operating-system name as from
#' \code{Sys.info()[["sysname"]]}.
#' @importFrom stringi stri_detect_fixed
#' @noRd
hasNetrc <- function(homeDir = Sys.getenv("HOME"),
                     sysname = Sys.info()[["sysname"]]) {
  netrcEnv <- Sys.getenv("NETRC", unset = "")
  if (nzchar(netrcEnv) && file.exists(netrcEnv)) {
    return(TRUE)
  }
  netrcName <- if (stri_detect_fixed(toupper(sysname), "WIND")) {
    "_netrc"
  } else {
    ".netrc"
  }
  file.exists(file.path(homeDir, netrcName))
}
