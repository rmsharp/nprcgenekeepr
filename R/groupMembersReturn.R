## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Form the return list for groupAddAssign
#'
#' @param retained List of up to 5 retained candidate solutions (issue #125),
#' each a list with elements \code{groupMembers} (list of character vectors,
#' one per group) and \code{score}. Ordered best-scoring first.
#' @param withKin logical variable indicating to return kinship coefficients
#' when \code{TRUE}.
#' @inheritParams meanKinship
#' @return A list with items \code{group}, \code{score}, \code{candidates},
#' and optionally \code{groupKin}. \code{group}, \code{score}, and (when
#' present) \code{groupKin} alias the best (first) retained candidate, for
#' backward compatibility.
#' \code{candidates} is a list of all retained candidates, each a list with
#' its own \code{group}, \code{score}, and, when \code{withKin == TRUE},
#' \code{groupKin} (a list of kinship matrices for each individual in that
#' candidate's groups).
#'
#' @noRd
groupMembersReturn <- function(retained, withKin, kmat) {
  candidates <- lapply(retained, function(r) {
    if (withKin) {
      groupKin <- list()
      for (i in seq_along(r$groupMembers)) {
        groupKin[[i]] <- filterKinMatrix(r$groupMembers[[i]], kmat)
      }
      list(group = r$groupMembers, score = r$score, groupKin = groupKin)
    } else {
      list(group = r$groupMembers, score = r$score)
    }
  })

  value <- list(
    group = candidates[[1L]]$group,
    score = candidates[[1L]]$score,
    candidates = candidates
  )
  if (withKin) {
    value$groupKin <- candidates[[1L]]$groupKin
  }
  value
}
