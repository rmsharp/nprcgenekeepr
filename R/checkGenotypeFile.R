## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Check genotype file
#'
#' Checks to ensure the content and structure are appropriate for a genotype
#' file. These checks are simply based on expected columns and legal domains.
#' The function stops (an error, not a warning) when the dataframe has fewer
#' than three columns, when the first column name does not contain
#' \code{"id"} (any case), when any column is named \code{first} or
#' \code{second} (any case), or when an allele in columns 2 or 3 that reads
#' as an integer is above 10000 (it would collide with the integer codes
#' \code{\link{addGenotype}} assigns).
#'
#' @param genotype dataframe with genotype data
#' @return The genotype dataframe, checked for the column count, the first
#' column's name and the allele range described above; no column types are
#' checked. The returned genotype file has the first column name forced to
#' "id".
#'
#' @importFrom stringi stri_c stri_detect_fixed stri_detect_regex
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::qcPed
#' ped <- ped[order(ped$id), ]
#' genotype <- data.frame(
#'   id = ped$id[50 + 1:20],
#'   first_name = paste0("first_name", 1:20),
#'   second_name = paste0("second_name", 1:20),
#'   stringsAsFactors = FALSE
#' )
#'
#' ## checkGenotypeFile disallows dataframe with < 3 columns
#' tryCatch(
#'   {
#'     checkGenotypeFile(genotype[, c("id", "first_name")])
#'   },
#'   warning = function(w) {
#'     cat("Warning produced")
#'   },
#'   error = function(e) {
#'     cat("Error produced")
#'   }
#' )
checkGenotypeFile <- function(genotype) {
  cols <- names(genotype)
  if (length(cols) < 3L) {
    stop("Genotype file must have at least three columns.")
  } else if (!stri_detect_fixed(tolower(cols[1L]), "id")) {
    stop("Genotype file must have 'id' as the first column.")
  } else if (any(tolower(cols) %in% c("first", "second"))) {
    stop("Genotype file cannot have a column named 'first' or 'second'.")
  } else {
    for (i in 2L:3L) {
      alleles <- unique(genotype[, i][!is.na(genotype[, i])])
      numbers <- suppressWarnings(as.integer(alleles))
      numbers <- numbers[!is.na(numbers)]
      if (any(numbers > 10000L)) {
        numberStr <- stri_c(format(numbers[numbers > 10000L],
          scientific = FALSE
        ), sep = ", ")
        stop(stri_c("Possible collision on allele(s) interpreted as a number
                    > 10000: ", numberStr, collapse = ", "))
      }
      # Anything goes
      # if (any(stri_detect_regex(alleles, "[;:\"']+"))) {
      #   stop(stri_c("Alleles have one or more of the following characters,
      #               which are not currently supported: ", ";:\"'"))
      # }
    }
  }
  names(genotype) <- c("id", cols[2L:length(cols)])
  genotype
}
