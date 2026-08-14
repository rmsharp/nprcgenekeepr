## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Shrink a pedigree to fit within a bit-size budget
#'
#' A \code{kinship2::pedigree.shrink()} equivalent (Track B of
#' \code{docs/planning/kinship2-supplement-full-reproduction-plan.md} §4):
#' trims a pedigree down to the individuals needed to keep it genetically
#' informative within a genotyping-cost budget (\code{maxBits}), given which
#' individuals are genotyped (\code{genotyped}) and, optionally, which are
#' affected by a trait of interest (\code{affected}).
#'
#' Ported from kinship2's own \code{pedigree.shrink()} orchestrator and its 5
#' internal helpers (\code{bitSize}, \code{findUnavailable} --
#' \code{excludeUnavailFounders}/\code{excludeStrayMarryin} --,
#' \code{findAvailNonInform}, \code{findAvailAffected},
#' \code{pedigree.trim}), all deparsed directly from the installed
#' \code{kinship2} namespace (1.9.6.2), over this package's own
#' \code{id}/\code{sire}/\code{dam} data-frame pedigree representation
#' (kinship2 uses an S3 \code{pedigree} object with integer row indices
#' instead). Three tiers, applied in order:
#' \enumerate{
#'   \item \strong{Unavailable trim.} Iteratively removes terminal (leaf)
#'   individuals who are not genotyped, then removes any founder couple
#'   with exactly one child together and no other mate, when both parents
#'   are themselves founders and neither is genotyped (the couple's shared
#'   child is promoted to founder status rather than removed), then removes
#'   any remaining childless founder ("stray marry-in") \emph{regardless of
#'   genotyped status} -- matching kinship2's own \code{excludeStrayMarryin},
#'   which does not consult availability at all.
#'   \item \strong{Non-informative trim.} Removes a genotyped, non-parent
#'   individual whose own \code{sire} and \code{dam} are both known and both
#'   genotyped, when the individual is not \code{affected} (an \code{NA}
#'   \code{affected} status counts as unaffected here, matching kinship2's
#'   own \code{all(x == 0, na.rm = TRUE)} rule) -- they add no genotype
#'   information beyond what their parents already supply. A single-known-
#'   parent individual (one of \code{sire}/\code{dam} known, the other
#'   \code{NA}) is never trimmed by this tier: kinship2's own
#'   \code{pedigree()} constructor forbids that input shape entirely
#'   ("Subjects must have both a father and mother, or have neither",
#'   confirmed against the installed namespace), so its algorithm never has
#'   to define this case -- this package's pedigrees allow partial
#'   parentage as ordinary data (see \code{\link{getIdsWithOneParent}}), so
#'   a literal port would divide a zero-length vector and error. This is a
#'   deliberate, documented package-specific extension, not a kinship2
#'   behavior.
#'   \item \strong{Affected-priority trim.} While the pedigree's bit size
#'   (\code{2 * nNonFounder - nFounder}) still exceeds \code{maxBits},
#'   removes one genotyped, non-parent individual at a time -- trying
#'   \code{NA}-affected candidates first, then unaffected, then affected --
#'   choosing whichever single candidate's removal (including any cascade
#'   through tiers 1-2 above) minimizes the resulting bit size. Ties are
#'   broken deterministically by lowest \code{id}, compared as a string
#'   (ratified design decision D-B2) -- kinship2's own reference
#'   implementation breaks ties via \code{runif()} against the global RNG
#'   state, so the \emph{same} input can produce a \emph{different} answer
#'   run-to-run; a live, multi-seed comparison against the installed
#'   \code{kinship2} confirmed this is a genuine difference in reference
#'   behavior, not a hypothetical one. Unlike kinship2's own
#'   \code{idTrimmed}/\code{idList$affect} fields, which record only the
#'   single trial candidate per round even when its removal cascades
#'   further (confirmed live: a fixture exists where kinship2's own
#'   \code{pedSizeFinal} drops by 2 in one round but \code{idTrimmed} names
#'   only 1) -- \code{shrinkPedigree()}'s \code{idTrimmed}/
#'   \code{idList$affected} record every id actually removed each round, so
#'   \code{pedSizeOriginal - pedSizeFinal} always equals
#'   \code{length(idTrimmed)}. This does not change which individuals
#'   survive, only the completeness of the returned audit trail.
#' }
#'
#' @param ped a pedigree \code{data.frame}. The fields \code{id},
#' \code{sire} and \code{dam} are required; an optional \code{affected}
#' logical column is used as the default source for \code{affected} (see
#' below). \code{sire}/\code{dam} are \code{NA} for a founder, and may be
#' \code{NA} for only one of the two (partial parentage) -- see the
#' non-informative-trim tier above for how that case is handled.
#' @param genotyped a logical vector, the same length as \code{nrow(ped)}
#' and in the same row order, \code{TRUE} where a genotype (or other
#' available biological sample) exists for that individual. \code{NA} is
#' not allowed, matching kinship2's own \code{avail} validation.
#' @param affected \code{NULL} (default) or a logical vector the same
#' length as \code{nrow(ped)}. When \code{NULL}, defaults to \code{ped$affected}
#' if that column exists, or to all-\code{FALSE} (unaffected) if it does
#' not -- ensuring the affected-priority trim can always make progress even
#' with no recorded affected status.
#' @param maxBits numeric, default \code{16L}. The bit-size budget the
#' affected-priority trim reduces toward.
#'
#' @return A list:
#' \describe{
#'   \item{ped}{The shrunk pedigree \code{data.frame}, with all of
#'   \code{ped}'s original columns; a promoted founder's \code{sire}/
#'   \code{dam} are set to \code{NA}.}
#'   \item{idTrimmed}{Character vector, every \code{id} removed, in removal
#'   order.}
#'   \item{idList}{A list with elements \code{unavail}, \code{noninform}
#'   and \code{affected} -- character vectors (\code{character(0)} when
#'   empty) grouping \code{idTrimmed} by which tier removed each id.}
#'   \item{bitSize}{Numeric vector: the pedigree's bit size before any
#'   trimming, after tiers 1-2, then one further value per affected-
#'   priority round.}
#'   \item{genotyped}{The final \code{genotyped} vector, aligned to
#'   \code{ped$id}.}
#'   \item{pedSizeOriginal, pedSizeIntermed, pedSizeFinal}{Integer row
#'   counts: original, after tiers 1-2, and final.}
#' }
#'
#' @seealso \code{\link{isFounder}}, \code{\link{getIdsWithOneParent}}
#'
#' @references Sinnwell JP, Therneau TM, Schaid DJ (2014). "The kinship2 R
#' Package for Pedigree Data." \emph{Human Heredity}, 78(2), 91-93.
#' @references \url{https://cran.r-project.org/package=kinship2}
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::examplePedigree[, c("id", "sire", "dam")]
#' genotyped <- rep(TRUE, nrow(ped))
#' result <- shrinkPedigree(ped, genotyped, maxBits = 16L)
#' nrow(ped)
#' nrow(result$ped)
shrinkPedigree <- function(ped, genotyped, affected = NULL, maxBits = 16L) {
  required <- c("id", "sire", "dam")
  missingCols <- setdiff(required, names(ped))
  if (length(missingCols) > 0L) {
    stop("Pedigree is missing ", toString(missingCols))
  }
  n <- nrow(ped)
  if (length(genotyped) != n) {
    stop("genotyped must be the same length as nrow(ped) (", n, ")")
  }
  genotyped <- as.logical(genotyped)
  if (anyNA(genotyped)) {
    stop("NA values not allowed in genotyped vector.")
  }
  if (is.null(affected)) {
    affected <- if ("affected" %in% names(ped)) ped$affected else rep(FALSE, n)
  }
  affected <- as.logical(affected)
  if (length(affected) != n) {
    stop("affected must be the same length as nrow(ped) (", n, ")")
  }

  ped$id <- as.character(ped$id)
  ped$sire <- as.character(ped$sire)
  ped$dam <- as.character(ped$dam)
  names(genotyped) <- ped$id
  names(affected) <- ped$id

  pedSizeOriginal <- n
  bitSizeOriginal <- .bitSizeOf(ped)

  idTrimmed <- character(0L)
  idList <- list(
    unavail = character(0L), noninform = character(0L),
    affected = character(0L)
  )

  step <- .findUnavailable(ped, genotyped)
  ped <- step$ped
  genotyped <- genotyped[ped$id]
  if (length(step$removed) > 0L) {
    idTrimmed <- c(idTrimmed, step$removed)
    idList$unavail <- step$removed
  }

  nChange <- 1L
  nNew <- nrow(ped)
  while (nChange > 0L && nNew > 0L) {
    nOld <- nrow(ped)
    step <- .findAvailNonInform(ped, genotyped, affected)
    if (length(step$removed) > 0L) {
      idTrimmed <- c(idTrimmed, step$removed)
      idList$noninform <- c(idList$noninform, step$removed)
      ped <- step$ped
      genotyped <- genotyped[ped$id]
    }
    nNew <- nrow(ped)
    nChange <- nOld - nNew
  }
  pedSizeIntermed <- nrow(ped)
  bitSizeVal <- .bitSizeOf(ped)
  bitSizeTrajectory <- c(bitSizeOriginal, bitSizeVal)

  isTrimmed <- TRUE
  while (isTrimmed && bitSizeVal > maxBits && nrow(ped) > 0L) {
    save <- .findAvailAffected(ped, genotyped, affected, affstatus = NA)
    isTrimmed <- save$isTrimmed
    if (!isTrimmed) {
      save <- .findAvailAffected(ped, genotyped, affected, affstatus = FALSE)
      isTrimmed <- save$isTrimmed
    }
    if (!isTrimmed) {
      save <- .findAvailAffected(ped, genotyped, affected, affstatus = TRUE)
      isTrimmed <- save$isTrimmed
    }
    if (isTrimmed) {
      ped <- save$ped
      genotyped <- genotyped[ped$id]
      bitSizeVal <- save$bitSize
      bitSizeTrajectory <- c(bitSizeTrajectory, bitSizeVal)
      idTrimmed <- c(idTrimmed, save$removed)
      idList$affected <- c(idList$affected, save$removed)
    }
  }

  list(
    ped = ped,
    idTrimmed = idTrimmed,
    idList = idList,
    bitSize = bitSizeTrajectory,
    genotyped = genotyped,
    pedSizeOriginal = as.integer(pedSizeOriginal),
    pedSizeIntermed = as.integer(pedSizeIntermed),
    pedSizeFinal = as.integer(nrow(ped))
  )
}

#' Compute a pedigree's bit size (internal)
#'
#' \code{2 * nNonFounder - nFounder}, kinship2's own genotyping-cost proxy.
#'
#' @param ped a pedigree \code{data.frame} with \code{sire}/\code{dam}
#' columns.
#' @return A single numeric value.
#' @noRd
.bitSizeOf <- function(ped) {
  nFounder <- sum(isFounder(ped))
  nNonFounder <- nrow(ped) - nFounder
  2L * nNonFounder - nFounder
}

#' Is each row of \code{ped} a parent of some other row? (internal)
#' @param ped a pedigree \code{data.frame}.
#' @return A logical vector, one element per row.
#' @noRd
.isParentOf <- function(ped) {
  ped$id %in% c(ped$sire[!is.na(ped$sire)], ped$dam[!is.na(ped$dam)])
}

#' Remove ungenotyped terminal individuals, unavailable founder couples,
#' and stray marry-ins (internal port of kinship2's \code{findUnavailable}
#' + \code{excludeUnavailFounders} + \code{excludeStrayMarryin}).
#'
#' @param ped a pedigree \code{data.frame}.
#' @param genotyped a logical vector named by \code{ped$id}.
#' @return A list with \code{ped} (the reduced pedigree) and \code{removed}
#' (character vector of removed ids, in removal order).
#' @noRd
.findUnavailable <- function(ped, genotyped) {
  removed <- character(0L)
  repeat {
    isTerminal <- !.isParentOf(ped)
    drop <- isTerminal & !genotyped[ped$id]
    if (!any(drop)) {
      break
    }
    removed <- c(removed, ped$id[drop])
    ped <- ped[!drop, , drop = FALSE]
  }

  excl <- .excludeUnavailFounders(ped, genotyped)
  ped <- excl$ped
  removed <- c(removed, excl$removed)

  strayIds <- .strayMarryinIds(ped)
  if (length(strayIds) > 0L) {
    removed <- c(removed, strayIds)
    ped <- ped[!(ped$id %in% strayIds), , drop = FALSE]
  }

  list(ped = ped, removed = removed)
}

#' Remove an unavailable founder couple with exactly one shared child and
#' no other mate, promoting the child to founder status (internal port of
#' kinship2's \code{excludeUnavailFounders}).
#' @inheritParams .findUnavailable
#' @return A list with \code{ped} and \code{removed} (character vector).
#' @noRd
.excludeUnavailFounders <- function(ped, genotyped) {
  nonFounderRows <- !is.na(ped$sire) & !is.na(ped$dam)
  if (!any(nonFounderRows)) {
    return(list(ped = ped, removed = character(0L)))
  }
  marriages <- unique(data.frame(
    sire = ped$sire[nonFounderRows], dam = ped$dam[nonFounderRows],
    stringsAsFactors = FALSE
  ))
  marriageKey <- paste(ped$sire[nonFounderRows], ped$dam[nonFounderRows],
    sep = "\r")
  sibshipSize <- table(marriageKey)[paste(marriages$sire, marriages$dam,
    sep = "\r")]
  nMarrSire <- table(marriages$sire)[marriages$sire]
  nMarrDam <- table(marriages$dam)[marriages$dam]
  eligible <- marriages[sibshipSize == 1L & nMarrSire == 1L & nMarrDam == 1L, ,
    drop = FALSE]

  removed <- character(0L)
  for (i in seq_len(nrow(eligible))) {
    sireId <- eligible$sire[i]
    damId <- eligible$dam[i]
    sireRow <- ped[ped$id == sireId, ]
    damRow <- ped[ped$id == damId, ]
    sireIsFounder <- is.na(sireRow$sire) && is.na(sireRow$dam)
    damIsFounder <- is.na(damRow$sire) && is.na(damRow$dam)
    if (sireIsFounder && damIsFounder &&
        !genotyped[sireId] && !genotyped[damId]) {
      childId <- ped$id[!is.na(ped$sire) & !is.na(ped$dam) &
        ped$sire == sireId & ped$dam == damId]
      ped$sire[ped$id == childId] <- NA
      ped$dam[ped$id == childId] <- NA
      ped <- ped[!(ped$id %in% c(sireId, damId)), , drop = FALSE]
      removed <- c(removed, sireId, damId)
    }
  }
  list(ped = ped, removed = removed)
}

#' Ids of childless founders ("stray marry-ins") -- removed unconditionally,
#' regardless of genotyped status (internal port of kinship2's
#' \code{excludeStrayMarryin}).
#' @param ped a pedigree \code{data.frame}.
#' @return Character vector of ids.
#' @noRd
.strayMarryinIds <- function(ped) {
  ped$id[isFounder(ped) & !.isParentOf(ped)]
}

#' Remove a genotyped, unaffected (or NA-affected), non-parent individual
#' whose own sire and dam are both known and both genotyped (internal port
#' of kinship2's \code{findAvailNonInform}).
#' @inheritParams .findUnavailable
#' @param affected a logical vector named by \code{ped$id}.
#' @return A list with \code{ped} and \code{removed}.
#' @noRd
.findAvailNonInform <- function(ped, genotyped, affected) {
  isParent <- .isParentOf(ped)
  isUnaffected <- !(!is.na(affected[ped$id]) & affected[ped$id])
  eligible <- !isParent & genotyped[ped$id] & isUnaffected
  candidateGenotyped <- genotyped
  for (thisId in ped$id[eligible]) {
    sireId <- ped$sire[ped$id == thisId]
    damId <- ped$dam[ped$id == thisId]
    if (!is.na(sireId) && !is.na(damId) &&
        genotyped[sireId] && genotyped[damId]) {
      candidateGenotyped[thisId] <- FALSE
    }
  }
  .findUnavailable(ped, candidateGenotyped)
}

#' Trial-remove each eligible candidate for one affected-status priority
#' tier, choosing whichever single removal (cascade included) minimizes
#' the resulting bit size; ties broken by lowest id, string-sorted (D-B2)
#' (internal port of kinship2's \code{findAvailAffected}).
#' @inheritParams .findAvailNonInform
#' @param affstatus \code{NA}, \code{FALSE} or \code{TRUE} -- the affected
#' status this tier targets.
#' @return A list with \code{isTrimmed} and, when \code{TRUE}, also
#' \code{ped}, \code{removed} and \code{bitSize}.
#' @noRd
.findAvailAffected <- function(ped, genotyped, affected, affstatus) {
  isParent <- .isParentOf(ped)
  ownAffected <- affected[ped$id]
  if (is.na(affstatus)) {
    candidates <- ped$id[!isParent & genotyped[ped$id] & is.na(ownAffected)]
  } else {
    candidates <- ped$id[!isParent & genotyped[ped$id] &
      !is.na(ownAffected) & ownAffected == affstatus]
  }
  if (length(candidates) == 0L) {
    return(list(isTrimmed = FALSE))
  }

  trial <- lapply(candidates, function(cid) {
    trialGenotyped <- genotyped
    trialGenotyped[cid] <- FALSE
    .findUnavailable(ped, trialGenotyped)
  })
  trialBitSize <- vapply(trial, function(x) .bitSizeOf(x$ped), numeric(1L))
  best <- which(trialBitSize == min(trialBitSize))
  chosen <- sort(candidates[best])[1L]
  chosenTrial <- trial[[which(candidates == chosen)]]

  list(
    isTrimmed = TRUE,
    ped = chosenTrial$ped,
    removed = chosenTrial$removed,
    bitSize = .bitSizeOf(chosenTrial$ped)
  )
}
