## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Read the genotype file of the separate-files mode
#'
#' With "Pedigree(s) and genotypes in separate files" the Input tab reads the
#' uploaded genotype file with \code{\link{getGenotypes}} and checks it with
#' \code{\link{checkGenotypeFile}}. A file that cannot be read (an error), or
#' that the check refuses (an error or a warning), is not used: the result has
#' no genotype and carries the one sentence the QC Summary shows. A warning
#' while only reading the file does not drop it.
#'
#' @param fileName the path of the uploaded genotype file.
#' @param sep column separator, as for \code{\link{getGenotypes}}.
#' @return A list with \code{genotype} (the checked data.frame, or \code{NULL}
#'   when the file is not used) and \code{note} (\code{NULL} when the file is
#'   used; otherwise "The genotype file was not used, so no genotypes are
#'   used." followed, when the problem has a message, by " Reason: " and the
#'   message, with a full stop added unless it already ends in ".", "!" or
#'   "?").
#' @noRd
readSeparateGenotypeFile <- function(fileName, sep = ",") {
  genotype <- tryCatch(
    getGenotypes(fileName, sep = sep),
    error = function(e) e
  )
  if (!inherits(genotype, "condition")) {
    genotype <- tryCatch(
      checkGenotypeFile(genotype),
      warning = function(w) w,
      error = function(e) e
    )
  }
  if (!inherits(genotype, "condition")) {
    return(list(genotype = genotype, note = NULL))
  }
  reason <- conditionMessage(genotype)
  note <- paste0(
    "The genotype file was not used, so no genotypes are used.",
    if (nzchar(reason)) {
      paste0(" Reason: ", reason, if (!grepl("[.!?]$", reason)) ".")
    }
  )
  list(genotype = NULL, note = note)
}
