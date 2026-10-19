## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get tokens from a character vector of lines
#'
#' Reads the lines of an nprcgenekeepr configuration file. The term before
#' each equals sign names a setting and the terms after it, up to the next
#' name, are its value; terms are separated by blanks, commas or line breaks,
#' a term in double quotes is kept whole (a quote not closed on its line ends
#' at the end of that line), and a \code{#} that begins a word starts a
#' comment that runs to the end of the line. Round brackets outside quotes are
#' ignored. A setting with nothing after its equals sign has an empty value.
#'
#' @param lines character vector with text from configuration file
#' @return A list with two elements: \code{param}, a character vector of
#' parameter names, and \code{tokenVec}, a list of the token vectors parsed
#' for each parameter (an empty character vector for a setting with no value).
#'
#' @importFrom stringi stri_replace_all_fixed stri_replace_all_regex
#' @importFrom stringi stri_trim_both stri_split_regex stri_split_boundaries
#' @importFrom stringi stri_detect_regex
#' @export
#' @examples
#' lines <- c(
#'   "center = \"SNPRC\"",
#'   " baseUrl = \"https://boomer.txbiomed.local:8080/labkey\"",
#'   " schemaName = \"study\"", " folderPath = \"/SNPRC\"",
#'   " queryName = \"demographics\"",
#'   "lkPedColumns = (\"Id\", \"gender\", \"birth\", \"death\",",
#'   "              \"lastDayAtCenter\", \"dam\", \"sire\")",
#'   "mapPedColumns = (\"id\", \"sex\", \"birth\", \"death\", ",
#'   "  \"exit\", \"dam\", \"sire\")"
#' )
#' lkVec <- c(
#'   "Id", "gender", "birth", "death",
#'   "lastDayAtCenter", "dam", "sire"
#' )
#' mapVec <- c("id", "sex", "birth", "death", "exit", "dam", "sire")
#' tokenList <- getTokenList(lines)
#' params <- tokenList$param
#' tokenVectors <- tokenList$tokenVec
getTokenList <- function(lines) {
  terms <- scanConfigTerms(lines)
  nameAt <- which(c(terms$isEquals[-1L], FALSE))
  ends <- c(nameAt[-1L] - 1L, length(terms$text))
  tokenVec <- lapply(seq_along(nameAt), function(k) {
    from <- nameAt[k] + 2L
    if (from > ends[k]) character(0L) else terms$text[from:ends[k]]
  })
  list(param = terms$text[nameAt], tokenVec = tokenVec)
}

#' Split configuration lines into terms
#'
#' Scans the lines one character at a time. A double quote starts a part of a
#' term that is kept whole, blank, comma, equals sign, round brackets and
#' \code{#} included, up to the closing quote or the end of the line. Outside
#' quotes, blanks, commas and the end of a line end a term, an equals sign is a
#' term of its own, round brackets are dropped, and a \code{#} that begins a
#' term ends the line.
#'
#' @param lines character vector with text from configuration file
#' @return A list with \code{text}, the terms in order, and \code{isEquals},
#' which is \code{TRUE} for an equals sign that stands outside quotes.
#' @noRd
scanConfigTerms <- function(lines) {
  terms <- list(text = character(0L), isEquals = logical(0L))
  for (line in lines) {
    chars <- stri_split_boundaries(line, type = "character")[[1L]]
    chars <- chars[nzchar(chars)]
    isBlank <- stri_detect_regex(
      chars, "^[\\p{WHITE_SPACE},]+$" # nolint: nonportable_path_linter
    )
    word <- character(0L) # the characters of the term being read
    hasQuote <- FALSE # the term being read has a quoted part
    inQuote <- FALSE
    for (i in seq_along(chars)) {
      ch <- chars[i]
      if (inQuote) {
        if (ch == "\"") inQuote <- FALSE else word <- c(word, ch)
      } else if (ch == "\"") {
        inQuote <- TRUE
        hasQuote <- TRUE
      } else if (ch == "#" && length(word) == 0L && !hasQuote) {
        break
      } else if (isBlank[i] || ch == "=") {
        terms <- addConfigTerm(terms, word, hasQuote)
        word <- character(0L)
        hasQuote <- FALSE
        if (ch == "=") terms <- addConfigTerm(terms, "=", FALSE, TRUE)
      } else if (!ch %in% c("(", ")")) {
        word <- c(word, ch)
      }
    }
    terms <- addConfigTerm(terms, word, hasQuote)
  }
  terms
}

#' Add a term to the terms read so far
#'
#' @param terms list with \code{text} and \code{isEquals}, see
#' \code{scanConfigTerms}.
#' @param word character vector, the characters of the term.
#' @param hasQuote logical, \code{TRUE} when the term had a quoted part, which
#' makes an empty term (\code{""}) a term.
#' @param isEquals logical, \code{TRUE} for an equals sign outside quotes.
#' @return \code{terms} with the term added, or unchanged when there is none.
#' @noRd
addConfigTerm <- function(terms, word, hasQuote, isEquals = FALSE) {
  if (length(word) > 0L || hasQuote) {
    terms$text <- c(terms$text, paste(word, collapse = ""))
    terms$isEquals <- c(terms$isEquals, isEquals)
  }
  terms
}
