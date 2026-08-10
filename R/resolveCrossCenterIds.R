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

## -- Shared validation helpers (issue #149 Slice 1, D2) -----------------
##
## Extracted from resolveCrossCenterIds()'s original inline checks so that
## checkCrossCenterMapping() (R/checkCrossCenterMapping.R) can reuse the
## exact same logic in a non-stop()ing, collect-all form, without
## duplicating it (the S496 .markerOppositeHomozygoteCount() precedent).
## resolveCrossCenterIds() itself calls these helpers in its original exact
## order and keeps its own historical stop() message text verbatim -- the
## helpers' own `message` field is used only by checkCrossCenterMapping(),
## so this function's error text stays byte-for-byte unchanged (D2's
## golden-master requirement, tests/testthat/test_resolveCrossCenterIds.R).

#' An empty cross-center validation-problem data.frame
#'
#' The zero-row shape every \code{.checkCrossCenter*()} helper returns when
#' it finds nothing wrong.
#' @return A zero-row data.frame with columns \code{type}, \code{ids},
#' \code{message}.
#' @noRd
.emptyCrossCenterProblems <- function() {
  data.frame(
    type = character(0L), ids = character(0L), message = character(0L),
    stringsAsFactors = FALSE
  )
}

#' Row-bind a list of cross-center validation-problem data.frames
#'
#' @param problems a list of data.frames (each shaped like
#' \code{\link{.emptyCrossCenterProblems}}'s return value; \code{NULL}
#' entries are dropped).
#' @return A single combined data.frame; zero rows if every entry was empty.
#' @noRd
.bindCrossCenterProblems <- function(problems) {
  problems <- Filter(Negate(is.null), problems)
  if (length(problems) == 0L) {
    return(.emptyCrossCenterProblems())
  }
  result <- do.call(rbind, problems)
  rownames(result) <- NULL
  result
}

#' Require a pedigree data.frame to carry id/sire/dam columns
#'
#' Shared by \code{\link{resolveCrossCenterIds}} and
#' \code{\link{checkCrossCenterMapping}} -- a structural problem always
#' \code{stop()}s immediately in both, exactly like every other
#' \code{checkXxx()} function in this package (never collected as a row).
#' @param p a pedigree data.frame.
#' @param subject the argument name to name in the error (\code{"pedA"} or
#' \code{"pedB"}).
#' @noRd
.requireCrossCenterPedColumns <- function(p, subject) {
  if (!all(c("id", "sire", "dam") %in% names(p))) {
    stop(
      "resolveCrossCenterIds(): '", subject, "' must contain columns ",
      "id, sire, and dam.",
      call. = FALSE
    )
  }
}

#' Require a mapping data.frame to carry idA/idB columns
#' @param mapping a mapping data.frame.
#' @noRd
.requireCrossCenterMappingColumns <- function(mapping) {
  if (!all(c("idA", "idB") %in% names(mapping))) {
    stop(
      "resolveCrossCenterIds(): 'mapping' must contain columns idA and ",
      "idB.",
      call. = FALSE
    )
  }
}

#' Check a mapping table for duplicate idA/idB values
#' @param mapping a mapping data.frame.
#' @return A \code{.emptyCrossCenterProblems()}-shaped data.frame: zero
#' rows if \code{idA} and \code{idB} are each unique, else one row per
#' offending column (\code{type = "uniqueness"}).
#' @noRd
.checkCrossCenterUniqueness <- function(mapping) {
  problems <- list()
  dupA <- unique(mapping$idA[duplicated(mapping$idA)])
  if (length(dupA) > 0L) {
    problems[[length(problems) + 1L]] <- data.frame(
      type = "uniqueness", ids = toString(dupA),
      message = paste0(
        "Duplicate idA value(s) in mapping: ", toString(dupA), "."
      ),
      stringsAsFactors = FALSE
    )
  }
  dupB <- unique(mapping$idB[duplicated(mapping$idB)])
  if (length(dupB) > 0L) {
    problems[[length(problems) + 1L]] <- data.frame(
      type = "uniqueness", ids = toString(dupB),
      message = paste0(
        "Duplicate idB value(s) in mapping: ", toString(dupB), "."
      ),
      stringsAsFactors = FALSE
    )
  }
  .bindCrossCenterProblems(problems)
}

#' Check that every mapping$idA value exists in pedA$id
#' @param pedA a pedigree data.frame.
#' @param mapping a mapping data.frame.
#' @return A \code{.emptyCrossCenterProblems()}-shaped data.frame: zero
#' rows if clean, else one row (\code{type = "existence"}) whose
#' \code{ids} is \code{toString()} of every missing idA value.
#' @noRd
.checkCrossCenterExistenceA <- function(pedA, mapping) {
  missingA <- setdiff(mapping$idA, pedA$id)
  if (length(missingA) == 0L) {
    return(.emptyCrossCenterProblems())
  }
  data.frame(
    type = "existence", ids = toString(missingA),
    message = paste0(
      "mapping references idA value(s) not present in pedA$id: ",
      toString(missingA), "."
    ),
    stringsAsFactors = FALSE
  )
}

#' Check that every mapping$idB value exists in pedB$id
#' @param pedB a pedigree data.frame.
#' @param mapping a mapping data.frame.
#' @return See \code{\link{.checkCrossCenterExistenceA}}, for the idB side.
#' @noRd
.checkCrossCenterExistenceB <- function(pedB, mapping) {
  missingB <- setdiff(mapping$idB, pedB$id)
  if (length(missingB) == 0L) {
    return(.emptyCrossCenterProblems())
  }
  data.frame(
    type = "existence", ids = toString(missingB),
    message = paste0(
      "mapping references idB value(s) not present in pedB$id: ",
      toString(missingB), "."
    ),
    stringsAsFactors = FALSE
  )
}

#' Check for an id present in both pedigrees but undeclared in mapping
#' @param pedA,pedB pedigree data.frames.
#' @param mapping a mapping data.frame.
#' @return A \code{.emptyCrossCenterProblems()}-shaped data.frame: zero
#' rows if clean, else one row (\code{type = "collision"}).
#' @noRd
.checkCrossCenterCollision <- function(pedA, pedB, mapping) {
  unmappedAIds <- setdiff(pedA$id, mapping$idA)
  unmappedBIds <- setdiff(pedB$id, mapping$idB)
  collision <- intersect(unmappedAIds, unmappedBIds)
  if (length(collision) == 0L) {
    return(.emptyCrossCenterProblems())
  }
  data.frame(
    type = "collision", ids = toString(collision),
    message = paste0(
      "id(s) appear in both pedA and pedB but are not declared in ",
      "'mapping': ", toString(collision), ". Add a mapping row linking ",
      "them, or ensure ids are unique to each center."
    ),
    stringsAsFactors = FALSE
  )
}

#' Rewrite pedB so every mapped id refers to its canonical idA value
#'
#' Every mapped id -- its own ego row and any \code{sire}/\code{dam}
#' pointer to it elsewhere in \code{pedB} -- is translated to its
#' \code{idA} value. Pure data preparation; never \code{stop()}s.
#'
#' \strong{Load-bearing ordering note (Dragon #2,
#' \code{docs/planning/issue149-cross-center-identity-mapping-workflow-plan.md}
#' section 7 item 2):} the per-pair conflict check
#' (\code{\link{.checkCrossCenterConflict}}) looks up a mapped pair's
#' \code{pedB} row \emph{by its canonical idA value}. Doing that lookup
#' against \code{pedB} \emph{before} this rewrite has run silently returns
#' an all-\code{NA} row, not an error -- which would make a conflict check
#' report zero conflicts even when real ones exist. This rewrite must
#' always run first.
#'
#' @param pedB a pedigree data.frame for the second center.
#' @param mapping a mapping data.frame.
#' @return \code{pedB} with \code{id}/\code{sire}/\code{dam} rewritten.
#' @noRd
.rewriteCrossCenterIds <- function(pedB, mapping) {
  translate <- stats::setNames(mapping$idA, mapping$idB)
  rewrite <- function(x) {
    hit <- x %in% names(translate)
    x[hit] <- translate[x[hit]]
    x
  }
  pedB$id <- rewrite(pedB$id)
  pedB$sire <- rewrite(pedB$sire)
  pedB$dam <- rewrite(pedB$dam)
  pedB
}

#' Resolve one column's value for a merged cross-center pair
#'
#' Generalizes the original \code{pickParent()} closure: prefer whichever
#' side has a non-\code{NA} value; a mapped pair whose two sides both
#' record a non-\code{NA}, \emph{different} value is a real conflict. Pure
#' computation -- never \code{stop()}s; the caller decides whether to stop
#' immediately (\code{\link{resolveCrossCenterIds}}) or collect the
#' conflict as a row (\code{\link{.checkCrossCenterConflict}}).
#'
#' @param rowA,rowB single-row data.frames (or 1-row slices) for the same
#' physical animal, one per center.
#' @param field the column name to resolve.
#' @return A list with \code{value} (the resolved value, meaningless when
#' \code{conflict} is \code{TRUE}), \code{source} (\code{"A"}, \code{"B"},
#' \code{"both"}, or \code{NA} when neither side has a value), and
#' \code{conflict} (logical).
#' @noRd
.pickCrossCenterParent <- function(rowA, rowB, field) {
  a <- rowA[[field]]
  b <- rowB[[field]]
  if (!is.na(a) && !is.na(b) && !identical(a, b)) {
    return(list(value = NA, source = NA_character_, conflict = TRUE))
  }
  if (!is.na(a) && !is.na(b)) {
    list(value = a, source = "both", conflict = FALSE)
  } else if (!is.na(a)) {
    list(value = a, source = "A", conflict = FALSE)
  } else if (!is.na(b)) {
    list(value = b, source = "B", conflict = FALSE)
  } else {
    list(value = b, source = NA_character_, conflict = FALSE)
  }
}

#' Check every mapped pair for a conflicting sire/dam value
#'
#' Performs \code{\link{.rewriteCrossCenterIds}} internally before looking
#' up any row (Dragon #2) -- \code{pedB} is passed in un-rewritten, exactly
#' as the caller received it, since \code{checkCrossCenterMapping()}'s
#' other checks need the original id space.
#'
#' @param pedA,pedB pedigree data.frames.
#' @param mapping a mapping data.frame.
#' @return A \code{.emptyCrossCenterProblems()}-shaped data.frame: one row
#' per conflicting (mapped pair, field) combination found -- every one,
#' not just the first.
#' @noRd
.checkCrossCenterConflict <- function(pedA, pedB, mapping) {
  rewrittenPedB <- .rewriteCrossCenterIds(pedB, mapping)
  problems <- list()
  for (idA in mapping$idA) {
    rowA <- pedA[pedA$id == idA, , drop = FALSE][1L, ]
    rowB <- rewrittenPedB[rewrittenPedB$id == idA, , drop = FALSE][1L, ]
    for (field in c("sire", "dam")) {
      result <- .pickCrossCenterParent(rowA, rowB, field)
      if (result$conflict) {
        problems[[length(problems) + 1L]] <- data.frame(
          type = "conflict", ids = idA,
          message = paste0(
            "mapped id '", idA, "' has conflicting ", field,
            " values between pedA and pedB: '", rowA[[field]], "' vs '",
            rowB[[field]], "'."
          ),
          stringsAsFactors = FALSE
        )
      }
    }
  }
  .bindCrossCenterProblems(problems)
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
#' across the two centers' independent namespaces. As of issue #149 Slice 1
#' (D10), a merged pair's other shared columns (beyond \code{id}/
#' \code{sire}/\code{dam}) follow the identical non-\code{NA}-preferred/
#' error-on-conflict rule -- previously they were silently dropped.
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
#' @seealso \code{\link{getFileDirectRelatives}},
#' \code{\link{checkCrossCenterMapping}}
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
  .requireCrossCenterPedColumns(pedA, "pedA")
  .requireCrossCenterPedColumns(pedB, "pedB")
  .requireCrossCenterMappingColumns(mapping)

  if (nrow(.checkCrossCenterUniqueness(mapping)) > 0L) {
    # nolint start: nonportable_path_linter
    stop(
      "resolveCrossCenterIds(): 'mapping' must link each id at most once; ",
      "found duplicate idA and/or idB values.",
      call. = FALSE
    )
    # nolint end: nonportable_path_linter
  }

  existenceA <- .checkCrossCenterExistenceA(pedA, mapping)
  if (nrow(existenceA) > 0L) {
    stop(
      "resolveCrossCenterIds(): mapping references idA value(s) not ",
      "present in pedA$id: ", existenceA$ids,
      call. = FALSE
    )
  }
  existenceB <- .checkCrossCenterExistenceB(pedB, mapping)
  if (nrow(existenceB) > 0L) {
    stop(
      "resolveCrossCenterIds(): mapping references idB value(s) not ",
      "present in pedB$id: ", existenceB$ids,
      call. = FALSE
    )
  }

  unmappedAIds <- setdiff(pedA$id, mapping$idA)
  unmappedBIds <- setdiff(pedB$id, mapping$idB)
  collisionProblems <- .checkCrossCenterCollision(pedA, pedB, mapping)
  if (nrow(collisionProblems) > 0L) {
    stop(
      "resolveCrossCenterIds(): id(s) appear in both pedA and pedB but ",
      "are not declared in 'mapping': ", collisionProblems$ids,
      ". Add a mapping row linking them, or ensure ids are unique to each ",
      "center.",
      call. = FALSE
    )
  }

  pedB <- .rewriteCrossCenterIds(pedB, mapping)

  mergedRows <- lapply(mapping$idA, function(idA) {
    rowA <- pedA[pedA$id == idA, , drop = FALSE][1L, ]
    rowB <- pedB[pedB$id == idA, , drop = FALSE][1L, ]

    sireResult <- .pickCrossCenterParent(rowA, rowB, "sire")
    if (sireResult$conflict) {
      stop(
        "resolveCrossCenterIds(): mapped id '", idA, "' has conflicting ",
        "sire values between pedA and pedB: '", rowA$sire, "' vs '",
        rowB$sire, "'.",
        call. = FALSE
      )
    }
    damResult <- .pickCrossCenterParent(rowA, rowB, "dam")
    if (damResult$conflict) {
      stop(
        "resolveCrossCenterIds(): mapped id '", idA, "' has conflicting ",
        "dam values between pedA and pedB: '", rowA$dam, "' vs '",
        rowB$dam, "'.",
        call. = FALSE
      )
    }

    rowData <- list(id = idA, sire = sireResult$value, dam = damResult$value)

    # D10: generalize the same "prefer non-NA, error on differing non-NA
    # values" resolution to every OTHER column present on both sides, so
    # agreeing metadata (e.g. sex) survives the merge instead of being
    # silently dropped (previously only id/sire/dam were ever populated;
    # see docs/planning/issue149-cross-center-identity-mapping-workflow-plan.md
    # section 2.12 / D10). Columns present on only one side are unaffected
    # here -- bindPedigreeRows() below NA-fills those as it always has.
    otherCols <- setdiff(
      intersect(names(rowA), names(rowB)), c("id", "sire", "dam")
    )
    for (col in otherCols) {
      colResult <- .pickCrossCenterParent(rowA, rowB, col)
      if (colResult$conflict) {
        stop(
          "resolveCrossCenterIds(): mapped id '", idA, "' has conflicting ",
          col, " values between pedA and pedB: '", rowA[[col]], "' vs '",
          rowB[[col]], "'.",
          call. = FALSE
        )
      }
      rowData[[col]] <- colResult$value
    }

    do.call(data.frame, c(rowData, stringsAsFactors = FALSE))
  })
  merged <- do.call(rbind, mergedRows)

  unmappedPedA <- pedA[pedA$id %in% unmappedAIds, , drop = FALSE]
  unmappedPedB <- pedB[pedB$id %in% unmappedBIds, , drop = FALSE]

  bindPedigreeRows(list(unmappedPedA, merged, unmappedPedB))
}
