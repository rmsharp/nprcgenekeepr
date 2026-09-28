## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Add a birth column to the five classic-structure example pedigrees,
#' inst/extdata/examples/example_pedigree_{consanguinity,linebreeding,
#' backcross,first_cousin,half_sib}.csv (BACKLOG.md item found S801; fixed
#' S802).
#'
#' The files were written (S691/S692) with id, sire, dam, sex and gen only,
#' so the app refused them ("Missing required columns: birth") although the
#' pedigree-diagram article tells the reader to upload one. The dates are
#' made up, by one rule, so that every parent is of breeding age:
#'   * each animal sits on a drawing row: its generation, or for a founder
#'     the row just above its earliest offspring (an outside mate is born in
#'     the same row as its partner);
#'   * a row is 6 years: row 0 is born in 2000, row 1 in 2006, and so on;
#'   * a dam's offspring are a year apart, in file order;
#'   * the month (March to June) and day vary with the file row.
#' The birth column changes nothing in either drawing of a file, so the
#' article's figures are unchanged.
#' tests/testthat/test_examplePedigreeFixtures.R checks the column, the upload
#' and the drawings. Re-running this script rewrites the same dates.
#'
#' Run from the package root:
#'   Rscript data-raw/example_pedigree_birth.R

examplesDir <- file.path("inst", "extdata", "examples")
exemplars <- c("consanguinity", "linebreeding", "backcross",
               "first_cousin", "half_sib")

for (exemplar in exemplars) {
  path <- file.path(examplesDir,
                    paste0("example_pedigree_", exemplar, ".csv"))
  ped <- read.csv(path, stringsAsFactors = FALSE)
  ped$birth <- NULL

  isFounder <- is.na(ped$sire) & is.na(ped$dam)
  row <- ped$gen
  for (i in which(isFounder)) {
    offspringGen <- ped$gen[ped$sire %in% ped$id[i] | ped$dam %in% ped$id[i]]
    row[i] <- if (length(offspringGen) > 0L) min(offspringGen) - 1L else 0L
  }
  birthOrder <- integer(nrow(ped))
  for (dam in unique(ped$dam[!is.na(ped$dam)])) {
    offspring <- which(ped$dam %in% dam)
    birthOrder[offspring] <- seq_along(offspring) - 1L
  }
  fileRow <- seq_len(nrow(ped)) - 1L
  ped$birth <- sprintf("%d-%02d-%02d", 2000L + 6L * row + birthOrder,
                       3L + fileRow %% 4L, 1L + (fileRow * 7L) %% 28L)

  write.csv(ped, path, row.names = FALSE)
}
