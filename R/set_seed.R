## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Set a reproducible RNG seed across R versions
#'
#' R 3.6 changed how \code{set.seed} and \code{sample} work. For R 3.6 and
#' later this function calls \code{set.seed(seed, sample.kind = "Rounding")},
#' which restores the earlier \code{sample()} behavior, so results of
#' \code{sample()} differ from those after a plain \code{set.seed(seed)}.
#' For earlier versions of R it calls \code{set.seed(seed)}. This lets unit
#' tests give the same results on multiple versions of R in a CICD test build.
#' Messages and warnings from \code{set.seed} are suppressed.
#'
#' @param seed argument to \code{set.seed}
#' @return NULL, invisibly.
#'
#' @export
#' @examples
#' set_seed(1)
#' rnorm(5)
set_seed <- function(seed = 1L) {
  version <- as.integer(R_version()$major) +
    (as.numeric(R_version()$minor) / 10.0)
  if (version >= 3.6) {
    arguments <- list(seed, sample.kind = "Rounding")
  } else {
    arguments <- list(seed)
  }
  suppressMessages(suppressWarnings(do.call(set.seed, arguments)))
}
#' Apply a gated RNG seed for reproducible E2E testing
#'
#' Reads \code{optionName} (env-var \code{envName} as fallback). When set,
#' pins the RNG via [set_seed()] so the genetic-value / breeding-group module
#' servers give reproducible stochastic output under shinytest2; a no-op
#' otherwise (=> NA).
#'
#' @param optionName Option name, e.g. \code{"nprcgenekeepr.gva_seed"}.
#' @param envName Environment-variable fallback, e.g. \code{"NPRC_GVA_SEED"}.
#' @return NULL, invisibly.
#' @noRd
gatedSeed <- function(optionName, envName) {
  seed <- getOption(optionName, as.integer(Sys.getenv(envName, NA)))
  if (!is.na(seed)) set_seed(seed)
  invisible(NULL)
}
#' Wrap R.Version
#'
#' @return R.Version() output
#' @noRd
R_version <- function() { # nolint: object_name_linter.
  R.Version()
}
