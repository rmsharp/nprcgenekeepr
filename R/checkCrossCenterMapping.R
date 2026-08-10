## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Collect every cross-center identity-mapping problem, without stopping
#'
#' The "show every problem at once" companion to
#' \code{\link{resolveCrossCenterIds}} (issue #149 Slice 1), sharing its
#' four validation checks -- id existence, mapping uniqueness, undeclared id
#' collisions, and conflicting recorded parents -- via the same internal
#' helpers (D2,
#' \code{docs/planning/issue149-cross-center-identity-mapping-workflow-plan.md}
#' section 3). \code{resolveCrossCenterIds()} \code{stop()}s on the first
#' problem it finds; \code{checkCrossCenterMapping()} never \code{stop()}s
#' on a domain problem -- every one found becomes a row in the returned
#' data.frame instead, so a curator can see and fix every issue at once
#' rather than one at a time. A structural problem (a required column
#' missing from any of the three inputs) still \code{stop()}s immediately,
#' matching every other \code{checkXxx()} function in this package
#' (\code{\link{checkKinshipOverrides}}, \code{\link{checkTwinRelations}}).
#'
#' Existence and uniqueness problems (tier A) are checked first; if either
#' is present, only those are returned and collision/conflict checks
#' (tier B) are skipped entirely, since a mapped id that does not resolve
#' to a real pedigree row makes those checks meaningless. Tier B -- and
#' both of its checks, across every mapped pair -- runs only once tier A is
#' clean.
#'
#' @param pedA a pedigree data.frame for the first center, with (at least)
#' columns \code{id}, \code{sire}, and \code{dam}.
#' @param pedB a pedigree data.frame for the second center, with (at least)
#' columns \code{id}, \code{sire}, and \code{dam}.
#' @param mapping a data.frame with columns \code{idA} and \code{idB}: one
#' row per curator-proposed cross-center identity link.
#' @return A data.frame of every domain problem found, with columns
#' \code{type} (\code{"existence"}, \code{"uniqueness"}, \code{"collision"},
#' or \code{"conflict"}), \code{ids} (the offending id(s), as a single
#' comma-separated string), and \code{message} (a human-readable
#' description). Zero rows means the mapping is clean, and
#' \code{\link{resolveCrossCenterIds}} can be called on the same inputs
#' without error.
#'
#' @seealso \code{\link{resolveCrossCenterIds}}
#' @export
#' @examples
#' library(nprcgenekeepr)
#' pedA <- data.frame(
#'   id = c("P1", "P2", "T1"), sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
#'   stringsAsFactors = FALSE
#' )
#' pedB <- data.frame(
#'   id = c("X9", "O1"), sire = c(NA, "X9"), dam = c(NA, NA),
#'   stringsAsFactors = FALSE
#' )
#' mapping <- data.frame(idA = "T1", idB = "X9", stringsAsFactors = FALSE)
#' checkCrossCenterMapping(pedA, pedB, mapping) # zero rows: clean
checkCrossCenterMapping <- function(pedA, pedB, mapping) {
  .requireCrossCenterPedColumns(pedA, "pedA")
  .requireCrossCenterPedColumns(pedB, "pedB")
  .requireCrossCenterMappingColumns(mapping)

  tierA <- rbind(
    .checkCrossCenterUniqueness(mapping),
    .checkCrossCenterExistenceA(pedA, mapping),
    .checkCrossCenterExistenceB(pedB, mapping)
  )
  if (nrow(tierA) > 0L) {
    return(tierA)
  }

  rbind(
    .checkCrossCenterCollision(pedA, pedB, mapping),
    .checkCrossCenterConflict(pedA, pedB, mapping)
  )
}
