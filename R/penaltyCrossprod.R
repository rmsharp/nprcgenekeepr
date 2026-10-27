## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## The width of the column blocks .blockCrossprod() multiplies.
.penaltyBlockSize <- 32L

## What .blockProductIsExact() found, by the matprod option it was made under.
.blockProductCache <- new.env(parent = emptyenv())

#' Multiply the diagram's penalty table by itself
#'
#' \code{.solveJointQP()} squares its penalty table, \code{t(pmat) \%*\%
#' pmat}, one row per penalty term, and each row holds only two or three
#' numbers: on the example's diagram (708 animals) the table is 1,480 rows by
#' 1,489 columns and the whole product took 1.07 s with R's own math library
#' (S1073). Where the block product is exact (\code{.blockProductIsExact()})
#' a table over \code{.penaltyBlockSize} columns with no missing or infinite
#' number is multiplied by blocks (\code{.blockCrossprod()}), 0.04 s on the
#' example; any other table is multiplied whole, as before.
#'
#' @param pmat the penalty table, a numeric matrix.
#' @return \code{t(pmat) \%*\% pmat}, the same to the last bit.
#' @noRd
.penaltyCrossprod <- function(pmat) {
  if (ncol(pmat) > .penaltyBlockSize && all(is.finite(pmat)) &&
        .blockProductIsExact()) {
    return(.blockCrossprod(pmat))
  }
  .matrixProduct(t(pmat), pmat)
}

#' Multiply a table by itself, block by block
#'
#' Each pair of column blocks is multiplied over only the rows with a nonzero
#' number in both, kept in row order. Every term this leaves out is an exact
#' zero, so a math library that adds each entry's terms one after another in
#' row order, as R's own does, gives the whole product's result to the last
#' bit.
#'
#' @param pmat a numeric matrix with at least \code{size} columns and no
#' missing or infinite number.
#' @param size the width of the column blocks; the last block also takes the
#' columns left over, so every block has at least \code{size} columns.
#' @return \code{t(pmat) \%*\% pmat}.
#' @noRd
.blockCrossprod <- function(pmat, size = .penaltyBlockSize) {
  n <- ncol(pmat)
  blockOf <- pmin((seq_len(n) - 1L) %/% size + 1L, max(1L, n %/% size))
  blocks <- split(seq_len(n), blockOf)
  hasNumber <- matrix(vapply(blocks, function(cols) {
    rowSums(pmat[, cols, drop = FALSE] != 0.0) > 0.0
  }, logical(nrow(pmat))), nrow = nrow(pmat))
  dmat <- matrix(0.0, n, n)
  for (a in seq_along(blocks)) {
    for (b in seq_along(blocks)) {
      rows <- which(hasNumber[, a] & hasNumber[, b])
      if (length(rows) > 0L) {
        dmat[blocks[[a]], blocks[[b]]] <- .matrixProduct(
          t(pmat[rows, blocks[[a]], drop = FALSE]),
          pmat[rows, blocks[[b]], drop = FALSE]
        )
      }
    }
  }
  dmat
}

#' Is the block product exact with this R's math library?
#'
#' Multiplies a fixed probe table by itself whole and by blocks and says
#' whether the two agree to the last bit. A library that adds a long product
#' in chunks (OpenBLAS, which CI's Ubuntu runs load) rounds the block sums
#' differently and is refused. The answer is kept for the rest of the session,
#' one for each \code{matprod} option, and no random numbers are drawn.
#'
#' @return \code{TRUE} or \code{FALSE}.
#' @noRd
.blockProductIsExact <- function() {
  key <- getOption("matprod", "default")
  known <- .blockProductCache[[key]]
  if (is.null(known)) {
    probe <- .blockProductProbe()
    known <- identical(.blockCrossprod(probe),
                       .matrixProduct(t(probe), probe))
    assign(key, known, envir = .blockProductCache)
  }
  known
}

#' The probe table of the block-product check
#'
#' 4,096 rows, longer than the chunk any common math library adds a product
#' in, and 96 columns, three blocks; each row holds three numbers in columns
#' spread over the table, so every entry of the product adds terms from all
#' parts of it.
#'
#' @return a 4,096 x 96 numeric matrix.
#' @noRd
.blockProductProbe <- function() {
  nRows <- 4096L
  nCols <- 3L * .penaltyBlockSize
  r <- seq_len(nRows)
  probe <- matrix(0.0, nRows, nCols)
  probe[cbind(r, r %% nCols + 1L)] <- sqrt(r)
  probe[cbind(r, (7L * r) %% nCols + 1L)] <- -0.5 * sqrt(r + 1.0)
  probe[cbind(r, (31L * r + 5L) %% nCols + 1L)] <- 1.0 / sqrt(r + 2.0)
  probe
}

#' The matrix product the penalty functions use
#'
#' \code{x \%*\% y}; one place for a test to stand in a math library that adds
#' in another order.
#'
#' @param x,y numeric matrices.
#' @return \code{x \%*\% y}.
#' @noRd
.matrixProduct <- function(x, y) {
  x %*% y
}
