## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Force dataframe columns to character
#'
#' Converts designated columns of a dataframe to character. Defaults to
#' converting columns \code{id}, \code{sire}, and \code{dam}.
#'
#' @param  df a dataframe. Columns named in \code{headers} are converted to
#' character.
#' @param headers character vector with the names of the columns to be
#' converted to character class. Names that are not columns of \code{df} are
#' skipped silently. Defaults to \code{c("id", "sire", "dam")}.
#' @return A dataframe with the specified columns converted to class
#' "character" for display with xtables (in shiny)
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' pedGood <- nprcgenekeepr::pedGood
#' names(pedGood) <- c("id", "sire", "dam", "sex", "birth")
#' class(pedGood[["id"]])
#' pedGood <- toCharacter(pedGood)
#' class(pedGood[["id"]])
toCharacter <- function(df, headers = c("id", "sire", "dam")) {
  headers <- intersect(names(df), headers)
  for (col in headers) {
    df[[col]] <- as.character(df[[col]])
  }
  df
}

#' Factor or number ids as text
#'
#' A studbook whose ids are numbers (\code{read.csv()} reads number ids as
#' integers) or factors names the same animals as one whose ids are text, so
#' the functions that find animals by name take such ids as their text (owner
#' ruling S1083). Any other value is returned unchanged, so it reaches the
#' code it reached before.
#'
#' @param x a vector of animal ids.
#' @return \code{x} as text when it is a factor or numbers, otherwise
#' \code{x}.
#' @noRd
idsAsText <- function(x) {
  if (is.factor(x) || is.numeric(x)) {
    return(as.character(x))
  }
  x
}

#' A pedigree's factor or number ids as text
#'
#' @param ped a pedigree.
#' @return \code{ped} with each of its \code{id}, \code{sire} and \code{dam}
#' columns passed through \code{idsAsText()}.
#' @noRd
pedIdsAsText <- function(ped) {
  for (col in intersect(names(ped), c("id", "sire", "dam"))) {
    ped[[col]] <- idsAsText(ped[[col]])
  }
  ped
}
