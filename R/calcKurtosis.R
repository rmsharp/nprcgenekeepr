## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Calculate bias-adjusted sample excess kurtosis
#'
#' Part of the Genetic Value Analysis
#'
#' The bias-adjusted Fisher-Pearson standardized EXCESS kurtosis
#' coefficient, \code{G2 = ((n + 1) * g2 + 6) * (n - 1) / ((n - 2) * (n -
#' 3))}, where \code{g2 = m4 / m2^2 - 3} and \code{m2}/\code{m4} are the
#' second/fourth central sample moments of \code{x} -- the "Method 2"
#' adjustment of Joanes and Gill (1998), the same convention SPSS, SAS, and
#' Excel report by default and the \code{type = 2} option in the
#' \code{moments}/\code{e1071} CRAN packages. Excess (not raw) kurtosis: a
#' normal distribution reads \code{0}. Positive values indicate heavier
#' tails / a sharper peak than normal; negative, lighter tails / a flatter
#' peak.
#'
#' Returns \code{NA} when \code{x} has fewer than 4 non-\code{NA} values
#' (\code{n <= 3}, the adjustment term divides by \code{(n - 2) * (n - 3)})
#' or has zero variance (all remaining values identical) -- both would
#' otherwise divide by zero.
#'
#' @param x A numeric vector.
#' @param na.rm Logical; remove \code{NA} values before computing. Default
#' \code{TRUE}.
#' @return The bias-adjusted sample excess kurtosis, a single number;
#' \code{NA} when degenerate (see Details).
#' @references Joanes, D.N. and Gill, C.A. (1998) "Comparing measures of
#' sample skewness and kurtosis." \emph{Journal of the Royal Statistical
#' Society: Series D (The Statistician)}, 47(1), 183-189.
#' @family genetic value analysis
#' @seealso \code{\link{calcSkewness}}
#' @export
#' @examples
#' calcKurtosis(c(1, 2, 3, 4, 100)) # 4.986866, heavy-tailed
#' calcKurtosis(c(1, 2, 3, 4, 5)) # -1.2, flatter than normal
calcKurtosis <- function(x, na.rm = TRUE) { # nolint: object_name_linter.
  if (na.rm) {
    x <- x[!is.na(x)]
  } else if (anyNA(x)) {
    return(NA_real_)
  }
  n <- length(x)
  if (n <= 3L) {
    return(NA_real_)
  }
  m2 <- mean((x - mean(x))^2L)
  if (m2 == 0.0) {
    return(NA_real_)
  }
  m4 <- mean((x - mean(x))^4L)
  g2 <- m4 / m2^2L - 3.0
  ((n + 1L) * g2 + 6L) * (n - 1L) / ((n - 2L) * (n - 3L))
}
