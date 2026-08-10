## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Enumerate every maximal independent set of a conflict graph
#'
#' Implements the classic Bron-Kerbosch recursive search (no pivoting -- see
#' Dragon 3/D4 of the issue #146 Slice 2 plan for why a pivoting refinement
#' is a performance optimization, not a correctness requirement) directly on
#' the \code{kin}-shaped conflict adjacency list already built by
#' \code{\link{getAnimalsWithHighKinship}}/
#' \code{\link{addAnimalsWithNoRelative}} -- no complement graph is
#' materialized. A maximal independent set of a
#' graph is exactly a maximal clique of its complement, so this is the
#' standard Bron-Kerbosch \code{R}/\code{P}/\code{X} formulation with
#' "adjacent" replaced by "compatible" (not conflicting) throughout.
#'
#' Never \code{stop()}s: a wall-clock \code{deadline} elapsed mid-search
#' ends the recursion early and reports \code{truncated = TRUE} with
#' whatever maximal independent sets were found before the deadline, rather
#' than erroring. The caller (\code{\link{groupAddAssign}}) is responsible
#' for the pre-flight \code{cap} refusal (issue #146 Slice 2 D5/D9) -- this
#' function only asserts that precondition defensively, it does not enforce
#' it as a user-facing error itself.
#'
#' @param candidates Character vector of candidate IDs.
#' @param kin Named list of high-kinship (conflicting) relatives, as
#' produced by \code{\link{getAnimalsWithHighKinship}}/
#' \code{\link{addAnimalsWithNoRelative}} -- each name is a candidate ID and
#' each value is a character vector of that ID's conflicting IDs (or
#' \code{NA} when the ID has no conflicts).
#' @param cap Integer. Defensive upper bound on \code{length(candidates)} --
#' the caller's own pre-flight feasibility ceiling (issue #146 Slice 2 D5),
#' asserted here as an internal precondition rather than re-enforced as a
#' second user-facing refusal.
#' @param deadline A \code{POSIXct} wall-clock deadline. The search checks
#' this at every recursive step and truncates gracefully once it has
#' elapsed.
#'
#' @return A list with elements \code{sets} (a list of character vectors,
#' one per maximal independent set found), \code{examined} (integer, the
#' number of sets in \code{sets}), and \code{truncated} (logical, whether
#' the deadline elapsed before the search completed).
#'
#' @references Bron, C. and Kerbosch, J. (1973) "Algorithm 457: finding all
#' cliques of an undirected graph" \emph{Communications of the ACM}, 16(9),
#' 575-577. Tomita, E., Tanaka, A. and Takahashi, H. (2006) "The worst-case
#' time complexity for generating all maximal cliques and computational
#' experiments" \emph{Theoretical Computer Science}, 363(1), 28-42.
#'
#' @noRd
.enumerateMaximalIndependentSets <- function(candidates, kin, cap, deadline) {
  stopifnot(length(candidates) <= cap)

  sets <- list()
  truncated <- FALSE

  compatible <- function(v) {
    conflicts <- kin[[v]]
    if (is.null(conflicts) || (length(conflicts) == 1L && is.na(conflicts))) {
      setdiff(candidates, v)
    } else {
      setdiff(candidates, c(conflicts, v))
    }
  }

  bk <- function(r, p, x) {
    if (truncated) {
      return(invisible(NULL))
    }
    if (Sys.time() > deadline) {
      truncated <<- TRUE
      return(invisible(NULL))
    }
    if (length(p) == 0L && length(x) == 0L) {
      sets[[length(sets) + 1L]] <<- r
      return(invisible(NULL))
    }
    for (v in p) {
      if (truncated) {
        break
      }
      if (Sys.time() > deadline) {
        truncated <<- TRUE
        break
      }
      vCompat <- compatible(v)
      bk(c(r, v), intersect(p, vCompat), intersect(x, vCompat))
      p <- setdiff(p, v)
      x <- union(x, v)
    }
  }

  bk(character(0L), candidates, character(0L))

  list(sets = sets, examined = length(sets), truncated = truncated)
}
