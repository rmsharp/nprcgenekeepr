## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Calculate allelic retention
#'
#' Part of Genetic Value Analysis
#'
#' @param ped the pedigree information in datatable format.  Pedigree
#' (req. fields: id, sire, dam, population).
#'
#' It is assumed that the pedigree has no partial parentage. When the
#' \code{population} column is missing or has no \code{TRUE} values, there
#' are no descendants and every retention value is 0.
#' @param alleles dataframe of containing an \code{AlleleTable}. This is a
#' table of allele information produced by \code{geneDrop()}.
#' @return A named one-dimensional array with one value per founder: the
#' proportion of the gene-drop simulations (a number from 0 to 1, not a count)
#' in which the founder's allele is retained in the population's descendants.
#'
#' @references Lacy RC. 1989. Analysis of founder representation in
#' pedigrees: founder equivalents and founder genome equivalents. Zoo Biol
#' 8:111-123.
#' @family genetic value analysis
#' @export
#' @examples
#' library(nprcgenekeepr)
#' data("lacy1989Ped")
#' data("lacy1989PedAlleles")
#' ped <- lacy1989Ped
#' alleles <- lacy1989PedAlleles
#' retention <- calcRetention(ped, alleles)
calcRetention <- function(ped, alleles) {
  ## Each step in its own statement: an argument evaluated lazily inside
  ## rowSums()'s S4 dispatch would reword today's error messages.
  scan <- founderRetentionScan(ped, alleles)
  meanRetention(scan)
}

#' The founder alleles and the iterations that retain each
#'
#' The first steps of \code{calcRetention()}, shared with \code{calcFGSE()}
#' and \code{founderStatistics()}, so \code{reportGV()} scans the gene drop
#' once for both founder numbers (performance plan Phase 5).
#'
#' @inheritParams calcRetention
#' @return A list: \code{founders}, a dataframe of the founders' rows of
#' \code{alleles} with columns \code{id} and \code{allele} (their \code{V1});
#' \code{retained}, \code{retainedFounderAlleles()}'s matrix for those
#' alleles.
#' @noRd
founderRetentionScan <- function(ped, alleles) {
  # ASSUME: Pedigree has no partial parentage
  founders <- getFounders(ped)
  descendants <- ped$id[ped$population & !(ped$id %in% founders)]

  founders <- alleles[(alleles$id %in% founders), c("id", "V1")]
  colnames(founders) <- c("id", "allele")

  list(founders = founders,
       retained = retainedFounderAlleles(founders$allele, alleles,
                                         descendants))
}

#' Each founder's mean retention
#'
#' \code{calcRetention()}'s result from \code{founderRetentionScan()}'s: each
#' allele's share of iterations that retain it, averaged over the founder's
#' two alleles.
#'
#' @param scan \code{founderRetentionScan()}'s list.
#' @return As \code{calcRetention()}.
#' @noRd
meanRetention <- function(scan) {
  retained <- rowSums(scan$retained, na.rm = TRUE) / ncol(scan$retained)
  founders <- cbind(scan$founders, retained)

  founders <- tapply(founders$retained, founders$id, mean)
  founders
}

#' Which founder alleles each gene-drop iteration retains, fast
#'
#' The scan behind \code{calcRetention()}, \code{calcFGSE()} and
#' \code{reportGV()}: for each founder allele and each iteration column, TRUE
#' when the allele is among the current descendants' alleles in that
#' iteration. The result is exactly today's \code{apply()} of \code{\%in\%}
#' (performance plan Phase 5, decision D1).
#'
#' A table of numbers is scanned one iteration column at a time, the
#' descendants' alleles looked up among the founder alleles with
#' \code{match()}. A table with a missing value among the descendants' alleles,
#' found as the scan reads each column, and any other table go through
#' \code{retainedFounderAllelesGeneral()}, today's scan, unchanged (owner
#' ruling S1058), so it gives today's result, or today's error, by
#' construction.
#'
#' @param founderAlleles the founders' alleles, column \code{V1} of their rows
#' of \code{alleles}, in row order.
#' @param alleles a dataframe with \{V1 ... Vn, id, parent\}, as
#' \code{geneDrop()} gives it.
#' @param descendants the ids of the current descendants.
#' @return A logical matrix: one row per founder allele, one column per
#' iteration column, with the iteration columns' names.
#' @noRd
retainedFounderAlleles <- function(founderAlleles, alleles, descendants) {
  shape <- retentionShape(founderAlleles, alleles, descendants)
  if (is.null(shape)) {
    return(retainedFounderAllelesGeneral(founderAlleles, alleles,
                                         descendants))
  }
  u <- unique(founderAlleles)
  code <- match(founderAlleles, u)
  out <- matrix(FALSE, nrow = length(founderAlleles),
                ncol = length(shape$columns),
                dimnames = list(NULL, names(alleles)[shape$columns]))
  for (k in seq_along(shape$columns)) {
    a <- alleles[[shape$columns[k]]][shape$rows]
    if (anyNA(a)) {
      return(retainedFounderAllelesGeneral(founderAlleles, alleles,
                                           descendants))
    }
    seen <- logical(length(u))
    seen[match(a, u, nomatch = 0L)] <- TRUE
    out[, k] <- seen[code]
  }
  out
}

#' The parts of a table the fast scan reads, or NULL
#'
#' Looking the descendants' alleles up among the founder alleles gives
#' today's \code{\%in\%} where both are plain numbers, and today's
#' \code{apply()} returns a matrix with the columns' own names where there are
#' at least two founder alleles and at least two iteration columns. So the
#' table must be a dataframe whose iteration columns, at least two, have
#' unique, non-empty names and hold plain integers or doubles, and the founder
#' alleles, at least two, must be plain integers or doubles with none missing.
#' \code{retainedFounderAlleles()} checks the descendants' alleles for a
#' missing value as it reads each column, so each column is read once.
#'
#' @inheritParams retainedFounderAlleles
#' @return NULL, or a list: \code{columns}, the positions of the iteration
#' columns; \code{rows}, TRUE for each row of a current descendant.
#' @noRd
retentionShape <- function(founderAlleles, alleles, descendants) {
  plainNumbers <- function(v) {
    typeof(v) %in% c("integer", "double") && !is.object(v)
  }
  if (!is.data.frame(alleles) || !plainNumbers(founderAlleles) ||
        length(founderAlleles) < 2L || anyNA(founderAlleles)) {
    return(NULL)
  }
  columns <- which(iterationColumns(alleles))
  columnNames <- names(alleles)[columns]
  if (length(columns) < 2L || anyNA(columnNames) ||
        !all(nzchar(columnNames)) || anyDuplicated(columnNames) > 0L) {
    return(NULL)
  }
  for (j in columns) {
    if (!plainNumbers(alleles[[j]])) {
      return(NULL)
    }
  }
  list(columns = columns, rows = alleles$id %in% descendants)
}

#' Today's retention scan, for any table
#'
#' \code{calcRetention()}'s scan before performance plan Phase 5, word for
#' word: the descendants' rows of the iteration columns, then \code{apply()}
#' of \code{\%in\%} per column. \code{retainedFounderAlleles()} calls it for a
#' table it does not scan fast, which keeps that table's result, error and
#' warnings.
#'
#' @inheritParams retainedFounderAlleles
#' @return As \code{retainedFounderAlleles()}.
#' @noRd
retainedFounderAllelesGeneral <- function(founderAlleles, alleles,
                                          descendants) {
  alleles <- alleles[
    (alleles$id %in% descendants),
    !(colnames(alleles) %in% c("id", "parent"))
  ]

  apply(alleles, 2L, function(a) {
    founderAlleles %in% a
  })
}
