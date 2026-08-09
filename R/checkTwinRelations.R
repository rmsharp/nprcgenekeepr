## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Validate a twin/zygosity relations table
#'
#' Checks the structure and domain of a twin/zygosity sidecar table. The
#' table supplies pairwise twin declarations (\code{id1}, \code{id2},
#' \code{code}) that record which individuals in a pedigree are twins and
#' with what twin zygosity certainty -- a fact this package's per-individual
#' pedigree data frame cannot represent directly (see
#' \code{docs/planning/issue137-twin-zygosity-pedigree-diagram-plan.md}).
#' It mirrors \code{\link{checkKinshipOverrides}}: it \code{stop()}s on
#' structural or domain errors and returns the (id-coerced) table when the
#' input is acceptable.
#'
#' \code{code} adopts kinship2's own literal twin-code labels --
#' \code{"MZ twin"}, \code{"DZ twin"}, \code{"UZ twin"} -- rather than a
#' bare \code{"zygosity"} identifier, which would collide with this
#' package's unrelated marker-genetics heterozygosity vocabulary (see
#' \code{\link{markerObservedHeterozygosity}}). kinship2's own fourth,
#' non-twin \code{"spouse"} code is out of scope here.
#'
#' Validation reproduces kinship2's own \code{relation} acceptance rules,
#' confirmed empirically against the installed kinship2 namespace: both
#' ids must exist in \code{ped} and differ (all codes); an \code{"MZ
#' twin"}/\code{"DZ twin"} pair must already share both \code{sire} and
#' \code{dam} in \code{ped}; an \code{"MZ twin"} pair must additionally
#' have matching \code{sex}; \code{"UZ twin"} has no such precondition.
#'
#' @param ped a pedigree data.frame with (at least) \code{id}, \code{sire},
#' \code{dam}, and \code{sex} columns.
#' @param twinRelations data.frame with columns \code{id1}, \code{id2},
#' \code{code}; each row is one twin declaration. Any extra columns are
#' ignored.
#' @return The validated \code{twinRelations} data.frame with \code{id1}
#' and \code{id2} coerced to character.
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
#' checkTwinRelations(ped, twinRelations)
checkTwinRelations <- function(ped, twinRelations) {
  required <- c("id1", "id2", "code")
  missingCols <- setdiff(required, names(twinRelations))
  if (length(missingCols) > 0L) {
    stop("Twin relations must have columns ", toString(required),
      "; missing: ", toString(missingCols), ".")
  }
  twinRelations$id1 <- as.character(twinRelations$id1)
  twinRelations$id2 <- as.character(twinRelations$id2)

  if (any(twinRelations$id1 == twinRelations$id2)) {
    stop("Twin relations must be off-diagonal: id1 and id2 must differ.")
  }

  unknown <- setdiff(unique(c(twinRelations$id1, twinRelations$id2)), ped$id)
  if (length(unknown) > 0L) {
    stop("Twin relation id(s) not found in the pedigree: ",
      toString(unknown), ".")
  }

  validCodes <- c("MZ twin", "DZ twin", "UZ twin")
  badCode <- setdiff(unique(twinRelations$code), validCodes)
  if (length(badCode) > 0L) {
    stop("Twin relations 'code' must be one of ", toString(validCodes),
      "; invalid value(s): ", toString(badCode), ".")
  }

  sireOf <- stats::setNames(ped$sire, ped$id)
  damOf <- stats::setNames(ped$dam, ped$id)
  sexOf <- stats::setNames(ped$sex, ped$id)

  for (i in seq_len(nrow(twinRelations))) {
    id1 <- twinRelations$id1[i]
    id2 <- twinRelations$id2[i]
    code <- twinRelations$code[i]
    if (code %in% c("MZ twin", "DZ twin")) {
      sharedParents <- !is.na(sireOf[[id1]]) && !is.na(damOf[[id1]]) &&
        identical(sireOf[[id1]], sireOf[[id2]]) &&
        identical(damOf[[id1]], damOf[[id2]])
      if (!sharedParents) {
        # nolint start: nonportable_path_linter.
        msg <- paste0("MZ/DZ twin pair (%s, %s) must share both sire ",
          "and dam in the pedigree.")
        # nolint end: nonportable_path_linter.
        stop(sprintf(msg, id1, id2))
      }
    }
    if (code == "MZ twin" && !identical(sexOf[[id1]], sexOf[[id2]])) {
      stop(sprintf("MZ twin pair (%s, %s) must have matching sex.", id1, id2))
    }
  }
  twinRelations
}
