#' Work around for unit tests using sample() among various versions of R
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#' The change in how `set.seed` works in R 3.6 prompted the creation of this
#' R version agnostic replacement to get unit test code to work on multiple
#' versions of R in a Travis-CI build.
#'
#' It seems RNGkind(sample.kind="Rounding”) does not work prior to version
#' 3.6 so I resorted to using version dependent construction of the argument
#' list to set.seed() in do.call().
#'
#' @return NULL, invisibly.
#'
#' @examples
#' \donttest{
#' set_seed(1)
#' rnorm(5)
#' }
#'
#' @param seed argument to \code{set.seed}
#' @export
set_seed <- function(seed = 1) {
  version <- as.integer(R.Version()$major) +
    (as.numeric(R.Version()$minor) / 10.0)
  if (version >= 3.6) {
    args <- list(seed, sample.kind = "Rounding")
  } else {
    args <- list(seed)
  }
  suppressWarnings(do.call(set.seed, args))
}
