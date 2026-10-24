## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Count each individual's rare alleles per simulation, fast
#'
#' The count behind \code{calcA()}, \code{calcGU()}, \code{calcGUSE()} and
#' \code{reportGV()}: for each animal and each gene-drop iteration, the number
#' (0, 1 or 2) of the animal's alleles that are rare in that iteration. The
#' result is exactly \code{calcA()}'s (performance plan Phase 1, decision D1).
#'
#' A table shaped like \code{geneDrop()}'s is counted with \code{match()} and
#' \code{tabulate()}, one iteration column at a time. Any other table goes
#' through \code{rareAlleleCountsGeneral()}, today's \code{table()} and
#' \code{tapply()} count, unchanged (owner ruling S1053), so it gives today's
#' result, or today's error, by construction.
#'
#' @param alleles a dataframe with \{V1 ... Vn, id, parent\}, as
#' \code{calcA()} takes it.
#' @param threshold the maximum number of copies of an allele for it to be
#' rare, as \code{calcA()} takes it.
#' @param byID logical; if TRUE an animal's two copies of one allele count once
#' toward that allele's frequency, as in \code{calcA()}.
#' @return An integer matrix: rows the levels of \code{as.factor(alleles$id)},
#' columns the iteration columns, each cell an animal's rare-allele count.
#' @noRd
rareAlleleCounts <- function(alleles, threshold = 1L, byID = FALSE) {
  shape <- geneDropShape(alleles, threshold)
  if (is.null(shape)) {
    return(rareAlleleCountsGeneral(alleles, threshold, byID))
  }
  m <- shape$alleles
  first <- shape$first
  second <- shape$second
  out <- matrix(0L, nrow = length(first), ncol = ncol(m),
                dimnames = list(shape$ids, colnames(m)))
  for (k in seq_len(ncol(m))) {
    a <- m[, k]
    u <- unique(a)
    code <- match(a, u)
    nU <- length(u)
    cnt <- tabulate(code, nU)
    if (byID) {
      # An animal carrying two copies of an allele counts once toward it.
      homo <- code[first] == code[second]
      cnt <- cnt - tabulate(code[first][homo], nU)
    }
    rare <- cnt[code] <= threshold
    out[, k] <- rare[first] + rare[second]
  }
  out
}

#' The parts of a table shaped like geneDrop()'s, or NULL
#'
#' The fast count gives \code{calcA()}'s result only where matching allele
#' values exactly is the same as matching their text, as \code{table()} does,
#' and where every animal has the two rows \code{geneDrop()} gives it. So the
#' table must be a dataframe with an \code{id} column and at least two numeric
#' iteration columns, with no missing value, every value a whole number below
#' 1e15 (where a double's 15-digit text form still tells values apart), no
#' missing id, every id on exactly two rows, and \code{threshold} one number.
#'
#' @param alleles the table \code{rareAlleleCounts()} was given.
#' @param threshold the threshold \code{rareAlleleCounts()} was given.
#' @return NULL, or a list: \code{alleles}, the iteration columns as a matrix;
#' \code{ids}, the levels of \code{as.factor(alleles$id)}, the result's row
#' order as \code{tapply()} gives it; \code{first} and \code{second}, the rows
#' holding each animal's two alleles, in that order.
#' @noRd
geneDropShape <- function(alleles, threshold) {
  if (!is.data.frame(alleles) || !("id" %in% names(alleles)) ||
        !is.numeric(threshold) || length(threshold) != 1L ||
        is.na(threshold)) {
    return(NULL)
  }
  cols <- iterationColumns(alleles)
  if (sum(cols) < 2L ||
        !all(vapply(alleles[cols], is.numeric, logical(1L)))) {
    return(NULL)
  }
  m <- as.matrix(alleles[, cols])
  if (anyNA(m) || (is.double(m) && !all(m == trunc(m) & abs(m) < 1e15))) {
    return(NULL)
  }
  ids <- as.factor(alleles$id)
  g <- as.integer(ids)
  if (length(g) == 0L || anyNA(g) ||
        !all(tabulate(g, nlevels(ids)) == 2L)) {
    return(NULL)
  }
  rows <- order(g)
  list(alleles = m, ids = levels(ids), first = rows[c(TRUE, FALSE)],
       second = rows[c(FALSE, TRUE)])
}

#' The iteration columns of a gene-drop table
#'
#' Every column of a \code{geneDrop()} table except \code{id} and
#' \code{parent} holds one iteration's alleles.
#'
#' @param alleles a gene-drop table.
#' @return A logical vector over the table's columns, TRUE for each iteration
#' column.
#' @noRd
iterationColumns <- function(alleles) {
  !(colnames(alleles) %in% c("id", "parent"))
}

#' Today's rare-allele count, for any table
#'
#' \code{calcA()}'s count before performance plan Phase 1, word for word:
#' \code{alleleFreq()} and \code{table()} per iteration, then \code{tapply()}
#' per animal. \code{rareAlleleCounts()} calls it for a table not shaped like
#' \code{geneDrop()}'s, which keeps that table's result, error and warnings.
#'
#' @inheritParams rareAlleleCounts
#' @return As \code{rareAlleleCounts()}.
#' @noRd
rareAlleleCountsGeneral <- function(alleles, threshold = 1L, byID = FALSE) {
  ids <- alleles$id
  alleles <- alleles[, !(names(alleles) %in% c("id", "parent"))]

  countRare <- function(a) {
    if (byID) {
      f <- alleleFreq(a, ids)
    } else {
      f <- alleleFreq(a)
    }
    rareAlleles <- f$allele[f$freq <= threshold]
    a <- (a %in% rareAlleles)
    tapply(a, ids, sum)
  }

  # S925: cbind keeps one row per animal; apply()'s own simplification turned
  # a single animal's row into a bare vector and dropped its id.
  do.call(cbind, apply(alleles, 2L, countRare, simplify = FALSE))
}
