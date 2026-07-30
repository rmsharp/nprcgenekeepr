## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Calculate bias-adjusted sample skewness
#'
#' Part of the Genetic Value Analysis
#'
#' The bias-adjusted Fisher-Pearson standardized skewness coefficient,
#' \code{G1 = g1 * sqrt(n * (n - 1)) / (n - 2)}, where \code{g1 = m3 /
#' m2^1.5} and \code{m2}/\code{m3} are the second/third central sample
#' moments of \code{x} -- the "Method 2" adjustment of Joanes and Gill
#' (1998), the same convention SPSS, SAS, and Excel report by default and
#' the \code{type = 2} option in the \code{moments}/\code{e1071} CRAN
#' packages. A positive value indicates a longer right tail; negative, a
#' longer left tail; \code{0}, a symmetric distribution.
#'
#' Returns \code{NA} when \code{x} has fewer than 3 non-\code{NA} values
#' (\code{n <= 2}, the adjustment term divides by \code{n - 2}) or has zero
#' variance (all remaining values identical) -- both would otherwise divide
#' by zero.
#'
#' @param x A numeric vector.
#' @param na.rm Logical; remove \code{NA} values before computing. Default
#' \code{TRUE}.
#' @return The bias-adjusted sample skewness, a single number; \code{NA} when
#' degenerate (see Details).
#' @references Joanes, D.N. and Gill, C.A. (1998) "Comparing measures of
#' sample skewness and kurtosis." \emph{Journal of the Royal Statistical
#' Society: Series D (The Statistician)}, 47(1), 183-189.
#' @family genetic value analysis
#' @seealso \code{\link{calcKurtosis}}
#' @export
#' @examples
#' calcSkewness(c(1, 2, 3, 4, 100)) # 2.232396, a long right tail
#' calcSkewness(c(1, 2, 3, 4, 5)) # 0, symmetric
calcSkewness <- function(x, na.rm = TRUE) { # nolint: object_name_linter.
  if (na.rm) {
    x <- x[!is.na(x)]
  } else if (anyNA(x)) {
    return(NA_real_)
  }
  n <- length(x)
  if (n <= 2L) {
    return(NA_real_)
  }
  m2 <- mean((x - mean(x))^2L)
  if (m2 == 0.0) {
    return(NA_real_)
  }
  m3 <- mean((x - mean(x))^3L)
  g1 <- m3 / m2^1.5
  g1 * sqrt(n * (n - 1L)) / (n - 2L)
}
