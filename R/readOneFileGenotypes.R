## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Read the genotype columns of a one-file pedigree
#'
#' With "Pedigree(s) and genotypes in one file" the Input tab takes the two
#' allele columns from the cleaned studbook. The first pair present, in this
#' order, with at least one allele in it, is read: \code{first} and
#' \code{second}; \code{first_name} and \code{second_name}; \code{allele1} and
#' \code{allele2} (the names \code{allele_1}, \code{Allele 1} and
#' \code{allele.1} have already become by then). Whole numbers (numbers, or
#' text that reads as numbers, as an Excel file gives them) are used as they
#' are in \code{first} and \code{second}. Anything else is a text label: the
#' labels become the integer codes \code{\link{addGenotype}} gives them, the
#' same rule as the separate genotype file, and text that stood in
#' \code{first} and \code{second} moves to \code{first_name} and
#' \code{second_name} where those are absent. Labels are not trimmed or
#' case-folded, so a misspelled label is its own allele. A label that reads as
#' a whole number above 10000 next to text labels is refused, as
#' \code{\link{checkGenotypeFile}} refuses it, because it would collide with
#' the codes.
#'
#' @param ped the studbook the Input tab's QC step has cleaned (a data.frame
#'   with an \code{id} column).
#' @return A list with \code{ped} (the studbook, with \code{first} and
#'   \code{second} set when genotypes were read, otherwise unchanged),
#'   \code{used} (\code{TRUE} when genotypes were read) and \code{note} (the
#'   one line the QC Summary shows, saying what was read or why nothing was).
#' @noRd
readOneFileGenotypes <- function(ped) {
  alleleColumns <- list(c("first", "second"),
                        c("first_name", "second_name"),
                        c("allele1", "allele2"))
  for (pair in alleleColumns) {
    if (all(pair %in% names(ped)) &&
          (hasAllele(ped[[pair[1L]]]) || hasAllele(ped[[pair[2L]]]))) {
      return(readAllelePair(ped, pair))
    }
  }
  found <- intersect(unlist(alleleColumns), names(ped))
  nPairs <- length(genotypePairLabels)
  note <- if (length(found) == 0L) {
    paste0("No genotype columns were found in this file (looked for ",
           toString(genotypePairLabels), "), so no genotypes are used.")
  } else if (length(found) == 1L) {
    paste0("Only one genotype column was found (", found, "); two are ",
           "needed, so no genotypes are used.")
  } else {
    paste0("Genotype columns were found (", toString(found), "), but they ",
           "are not a usable pair, so no genotypes are used; a pair is ",
           toString(genotypePairLabels[-nPairs]), ", or ",
           genotypePairLabels[nPairs], ", with at least one allele in it.")
  }
  list(ped = ped, used = FALSE, note = note)
}

## The three pairs the Input tab reads, as a user names them in a file header
## (the cleaned studbook has already turned allele_1 into allele1), for the two
## lines that list them.
genotypePairLabels <- c("first and second", "first_name and second_name",
                        "allele_1 and allele_2")

## A label with nothing in it (NA, "" or spaces only) is a missing allele.
blankToNa <- function(x) {
  x <- as.character(x)
  x[is.na(x) | !nzchar(trimws(x))] <- NA_character_
  x
}

## The column's alleles and whether they are whole numbers: a numeric column,
## or text in which every non-blank value reads as a number.
alleleValues <- function(x) {
  if (is.numeric(x)) {
    return(list(values = x, numeric = TRUE))
  }
  text <- blankToNa(x)
  asNumber <- suppressWarnings(as.numeric(text))
  if (anyNA(asNumber[!is.na(text)])) {
    list(values = text, numeric = FALSE)
  } else {
    list(values = asNumber, numeric = TRUE)
  }
}

hasAllele <- function(x) !all(is.na(alleleValues(x)$values))

readAllelePair <- function(ped, pair) {
  one <- alleleValues(ped[[pair[1L]]])
  two <- alleleValues(ped[[pair[2L]]])
  if (one$numeric && two$numeric) {
    ped[["first"]] <- one$values
    ped[["second"]] <- two$values
    values <- list(one$values, two$values)
  } else {
    text <- list(blankToNa(ped[[pair[1L]]]), blankToNa(ped[[pair[2L]]]))
    refused <- unique(collidingNumbers(unlist(text)))
    if (length(refused)) {
      return(list(ped = ped, used = FALSE, note = refusedNote(pair, refused)))
    }
    codes <- alleleCodes(ped$id, text[[1L]], text[[2L]])
    if (identical(pair, c("first", "second"))) {
      if (!"first_name" %in% names(ped)) ped[["first_name"]] <- ped[["first"]]
      if (!"second_name" %in% names(ped)) {
        ped[["second_name"]] <- ped[["second"]]
      }
    }
    ped[["first"]] <- codes$first
    ped[["second"]] <- codes$second
    values <- text
  }
  list(ped = ped, used = TRUE, note = readNote(pair, values))
}

## The codes addGenotype() gives these labels, in the order of `id`.
alleleCodes <- function(id, one, two) {
  genotype <- data.frame(id = id, alleleA = one, alleleB = two,
                         stringsAsFactors = FALSE)
  coded <- addGenotype(data.frame(id = id, stringsAsFactors = FALSE),
                       genotype)
  coded <- coded[match(id, coded$id), ]
  list(first = coded$first, second = coded$second)
}

refusedNote <- function(pair, numbers) {
  paste0("Genotypes in ", pair[1L], " and ", pair[2L], " were not used: an ",
         "allele reads as the whole ",
         if (length(numbers) == 1L) "number " else "numbers ",
         toString(numbers),
         ", which could collide with the codes the app gives text labels.")
}

## "Genotypes read from <a> and <b>: <n> different alleles (<list>) for <k> of
## <N> animals." The list holds the first ten alleles, in order, and "..." when
## there are more; a label with a space at either end is quoted so it shows.
readNote <- function(pair, values) {
  both <- c(values[[1L]], values[[2L]])
  alleles <- sort(unique(both[!is.na(both)]))
  shown <- vapply(utils::head(alleles, 10L), function(allele) {
    if (is.character(allele)) {
      if (identical(trimws(allele), allele)) allele else dQuote(allele, FALSE)
    } else {
      format(allele, scientific = FALSE, trim = TRUE)
    }
  }, character(1L))
  if (length(alleles) > 10L) shown <- c(shown, "...")
  nAnimals <- length(values[[1L]])
  paste0("Genotypes read from ", pair[1L], " and ", pair[2L], ": ",
         length(alleles), " different ",
         if (length(alleles) == 1L) "allele" else "alleles",
         " (", toString(shown), ") for ",
         sum(!is.na(values[[1L]]) & !is.na(values[[2L]])), " of ", nAnimals,
         if (nAnimals == 1L) " animal." else " animals.")
}
