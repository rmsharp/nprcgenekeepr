## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' De-identify a twin/zygosity relations table
#'
#' Remaps \code{id1}/\code{id2} in a twin/zygosity sidecar table (see
#' \code{\link{checkTwinRelations}}) through the same alias vector
#' \code{\link{obfuscatePed}(..., map = TRUE)} already returns.
#' \code{\link{obfuscatePed}} scrubs exactly one pedigree data frame and
#' cannot reach a second, sidecar object -- this is the companion scrub a
#' twin-relations table needs so an "obfuscated" export never leaks real
#' ids through the sidecar table while the main pedigree is de-identified.
#'
#' A row whose \code{id1} or \code{id2} is absent from \code{map}
#' \code{stop()}s rather than silently dropping or leaking the real id.
#' \code{\link{checkTwinRelations}}'s own existence rule should already
#' have excluded that case upstream against the un-obfuscated pedigree, so
#' this is a defensive check, not the primary validation path.
#'
#' @param twinRelations data.frame with columns \code{id1}, \code{id2},
#' \code{code}. See \code{\link{checkTwinRelations}}.
#' @param map named character vector of aliases, keyed by the original id
#' -- the \code{map} element of \code{\link{obfuscatePed}(..., map =
#' TRUE)}'s return value.
#' @return \code{twinRelations} with \code{id1}/\code{id2} replaced by
#' their aliases; \code{code} is unchanged.
#' @family obfuscation
#' @export
#' @examples
#' ped <- data.frame(
#'   id = c("F1", "F2", "S1", "S2"),
#'   sire = c(NA, NA, "F1", "F1"),
#'   dam = c(NA, NA, "F2", "F2"),
#'   sex = c("M", "F", "F", "F"),
#'   stringsAsFactors = FALSE
#' )
#' twinRelations <- data.frame(
#'   id1 = "S1", id2 = "S2", code = "MZ twin", stringsAsFactors = FALSE
#' )
#' obfuscated <- obfuscatePed(ped, map = TRUE)
#' obfuscateTwinRelations(twinRelations, obfuscated$map)
obfuscateTwinRelations <- function(twinRelations, map) {
  ids <- unique(c(twinRelations$id1, twinRelations$id2))
  unknown <- setdiff(ids, names(map))
  if (length(unknown) > 0L) {
    stop("Twin relation id(s) not found in the de-identification map: ",
      toString(unknown), ".")
  }
  twinRelations$id1 <- unname(map[twinRelations$id1])
  twinRelations$id2 <- unname(map[twinRelations$id2])
  twinRelations
}
