## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Row-bind pedigree fragments, filling missing columns with \code{NA}
#'
#' \code{\link{resolveCrossCenterIds}}'s merged output combines rows sliced
#' directly from \code{pedA}/\code{pedB} (which may carry columns beyond
#' \code{id}/\code{sire}/\code{dam}, e.g. \code{sex}) with newly constructed
#' rows for merged individuals (which only ever have \code{id}/\code{sire}/
#' \code{dam}); plain \code{rbind()} errors on that column mismatch.
#'
#' @param dfs a list of data.frames (or \code{NULL} entries, which are
#' dropped) to combine.
#' @return A single data.frame over the union of all input columns, with
#' \code{NA} filled in wherever a source data.frame lacked a column.
#' @noRd
bindPedigreeRows <- function(dfs) {
  dfs <- Filter(function(d) !is.null(d) && nrow(d) > 0L, dfs)
  if (length(dfs) == 0L) {
    return(data.frame(id = character(0L), sire = character(0L),
                       dam = character(0L), stringsAsFactors = FALSE))
  }
  allCols <- unique(unlist(lapply(dfs, names)))
  dfs <- lapply(dfs, function(d) {
    for (col in setdiff(allCols, names(d))) {
      d[[col]] <- NA
    }
    d[, allCols, drop = FALSE]
  })
  result <- do.call(rbind, dfs)
  rownames(result) <- NULL
  result
}

#' Merge two centers' pedigrees via a curator-confirmed identity link
#'
#' Collapses a transferred animal's two center-specific records into ONE
#' node with its real parents intact, instead of leaving it as an
#' artificial founder at the receiving center -- the failure mode issue
#' #130 names directly (a transferred animal loses its recorded lineage
#' because the two centers use independent id namespaces). Follows the
#' \code{getPedigreeSource()} design style (D5): a deterministic,
#' curator-supplied cross-reference table, never coincidental same-string
#' ids, and fail-loud validation on any ambiguity.
#'
#' @details
#' For each \code{mapping} row, the two records collapse into one, keyed by
#' the \code{idA} value (the canonical id): every reference to the mapped
#' \code{idB} value anywhere in \code{pedB} -- as that animal's own \code{id}
#' or as a \code{sire}/\code{dam} pointer on any other animal -- is rewritten
#' to \code{idA}. The merged individual's \code{sire}/\code{dam} prefer
#' whichever side has a non-\code{NA} value (this is what fixes the
#' artificial-founder problem: a center that never knew the animal's real
#' parents recorded \code{NA}, and the origin center's real parents win). A
#' mapped pair whose two sides both record a non-\code{NA}, \emph{different}
#' \code{sire} or \code{dam} is a real data inconsistency, not something to
#' silently pick a side on, so it errors instead. Animals not named in
#' \code{mapping} pass through unchanged; an id string present in both
#' \code{pedA} and \code{pedB} that is \emph{not} declared in \code{mapping}
#' is also an error -- per D5, identity is established only by the explicit
#' mapping table, never assumed from a coincidentally matching id string
#' across the two centers' independent namespaces.
#'
#' @param pedA a pedigree data.frame for the first center, with (at least)
#' columns \code{id}, \code{sire}, and \code{dam}.
#' @param pedB a pedigree data.frame for the second center, with (at least)
#' columns \code{id}, \code{sire}, and \code{dam}.
#' @param mapping a data.frame with columns \code{idA} and \code{idB}: one
#' row per curator-confirmed cross-center identity link, naming the same
#' physical animal's id in \code{pedA} and in \code{pedB}. Each id may
#' appear at most once in \code{idA} and at most once in \code{idB}.
#' @return A single merged pedigree data.frame over the union of
#' \code{pedA}'s and \code{pedB}'s columns, with one row per distinct
#' animal (mapped pairs collapsed to their canonical \code{idA} id).
#'
#' @seealso \code{\link{getFileDirectRelatives}}
#' @export
#' @examples
#' library(nprcgenekeepr)
#' pedA <- data.frame(
#'   id = c("P1", "P2", "T1"), sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
#'   stringsAsFactors = FALSE
#' )
#' ## X9 is the SAME physical animal as T1, but Center B recorded it as an
#' ## artificial founder because it never knew the real parents.
#' pedB <- data.frame(
#'   id = c("X9", "O1"), sire = c(NA, "X9"), dam = c(NA, NA),
#'   stringsAsFactors = FALSE
#' )
#' mapping <- data.frame(idA = "T1", idB = "X9", stringsAsFactors = FALSE)
#' resolveCrossCenterIds(pedA, pedB, mapping)
resolveCrossCenterIds <- function(pedA, pedB, mapping) {
  requirePedColumns <- function(p, subject) {
    if (!all(c("id", "sire", "dam") %in% names(p))) {
      stop(
        "resolveCrossCenterIds(): '", subject, "' must contain columns ",
        "id, sire, and dam.",
        call. = FALSE
      )
    }
  }
  requirePedColumns(pedA, "pedA")
  requirePedColumns(pedB, "pedB")

  if (!all(c("idA", "idB") %in% names(mapping))) {
    stop(
      "resolveCrossCenterIds(): 'mapping' must contain columns idA and ",
      "idB.",
      call. = FALSE
    )
  }

  if (anyDuplicated(mapping$idA) > 0L || anyDuplicated(mapping$idB) > 0L) {
    # nolint start: nonportable_path_linter
    stop(
      "resolveCrossCenterIds(): 'mapping' must link each id at most once; ",
      "found duplicate idA and/or idB values.",
      call. = FALSE
    )
    # nolint end: nonportable_path_linter
  }

  missingA <- setdiff(mapping$idA, pedA$id)
  if (length(missingA) > 0L) {
    stop(
      "resolveCrossCenterIds(): mapping references idA value(s) not ",
      "present in pedA$id: ", toString(missingA),
      call. = FALSE
    )
  }
  missingB <- setdiff(mapping$idB, pedB$id)
  if (length(missingB) > 0L) {
    stop(
      "resolveCrossCenterIds(): mapping references idB value(s) not ",
      "present in pedB$id: ", toString(missingB),
      call. = FALSE
    )
  }

  unmappedAIds <- setdiff(pedA$id, mapping$idA)
  unmappedBIds <- setdiff(pedB$id, mapping$idB)
  collision <- intersect(unmappedAIds, unmappedBIds)
  if (length(collision) > 0L) {
    stop(
      "resolveCrossCenterIds(): id(s) appear in both pedA and pedB but ",
      "are not declared in 'mapping': ", toString(collision),
      ". Add a mapping row linking them, or ensure ids are unique to each ",
      "center.",
      call. = FALSE
    )
  }

  # Rewrite pedB so every mapped id -- its own ego row and any sire/dam
  # pointer to it elsewhere in pedB -- refers to its canonical idA value.
  translate <- stats::setNames(mapping$idA, mapping$idB)
  rewrite <- function(x) {
    hit <- x %in% names(translate)
    x[hit] <- translate[x[hit]]
    x
  }
  pedB$id <- rewrite(pedB$id)
  pedB$sire <- rewrite(pedB$sire)
  pedB$dam <- rewrite(pedB$dam)

  mergedRows <- lapply(mapping$idA, function(idA) {
    rowA <- pedA[pedA$id == idA, , drop = FALSE][1L, ]
    rowB <- pedB[pedB$id == idA, , drop = FALSE][1L, ]

    pickParent <- function(field) {
      a <- rowA[[field]]
      b <- rowB[[field]]
      if (!is.na(a) && !is.na(b) && !identical(a, b)) {
        stop(
          "resolveCrossCenterIds(): mapped id '", idA, "' has conflicting ",
          field, " values between pedA and pedB: '", a, "' vs '", b, "'.",
          call. = FALSE
        )
      }
      if (!is.na(a)) a else b
    }

    data.frame(
      id = idA, sire = pickParent("sire"), dam = pickParent("dam"),
      stringsAsFactors = FALSE
    )
  })
  merged <- do.call(rbind, mergedRows)

  unmappedPedA <- pedA[pedA$id %in% unmappedAIds, , drop = FALSE]
  unmappedPedB <- pedB[pedB$id %in% unmappedBIds, , drop = FALSE]

  bindPedigreeRows(list(unmappedPedA, merged, unmappedPedB))
}
