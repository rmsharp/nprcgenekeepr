## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' obfuscateId creates a vector of ID aliases of specified length
#'
#' ID aliases are pseudorandom sequences of alphanumeric upper case characters
#' where the letter "O" is not included for readability..
#' User has the option of providing a character vector of aliases to avoid
#' using.
#' Because aliases are alphanumeric, they never contain a period ("."),
#' honoring the ID rule enforced at data input by \code{qcStudbook}.
#'
#' @return A named character vector of aliases where the name is the original
#' ID value.
#'
#' @param id character vector of IDs to be obfuscated (alias creation).
#' @param size character length of each alias
#' @param existingIds character vector of existing aliases to avoid duplication.
#' @importFrom stringi stri_c
#' @export
#' @examples
#' library(nprcgenekeepr)
#' integerIds <- 1L:10L
#' obfuscateId(integerIds, size = 4L)
#' characterIds <- paste0(paste0(sample(LETTERS, 1L, replace = FALSE)), 1L:10L)
#' obfuscateId(characterIds, size = 4L)
obfuscateId <- function(id, size = 10L, existingIds = character(0L)) {
  noOInLetters <- c(
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L",
    "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y",
    "Z"
  )
  prefix <- getAutoIdPrefix()
  existingIds <- c(character(length(id)), existingIds)
  obfuscatedId <- character(length(id))
  for (i in seq_along(id)) {
    counter <- 0L
    repeat {
      if (isGeneratedUnknownId(id[i])) {
        obfuscatedId[i] <- stri_c(
          c(prefix, sample(c(noOInLetters, stri_c(0L:9L)),
            size = size - nchar(prefix), replace = TRUE
          )),
          collapse = ""
        )
      } else {
        obfuscatedId[i] <- stri_c(sample(c(noOInLetters, stri_c(0L:9L)),
          size = size,
          replace = TRUE
        ), collapse = "")
      }
      ## ensure the alias and source are both auto-generated or both not
      if (!any(obfuscatedId[i] %in% existingIds) &&
        (isGeneratedUnknownId(obfuscatedId[i]) ==
          isGeneratedUnknownId(id[i]))) {
        break
      }
      counter <- counter + 1L
      if (counter > 100L) {
        stop(
          "Character length of alias IDs is too short to easily ",
          "avoid duplicates"
        )
      }
    }
    existingIds[i] <- obfuscatedId[i]
  }
  names(obfuscatedId) <- id
  obfuscatedId
}
