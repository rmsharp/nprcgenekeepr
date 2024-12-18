#' obfucateId creates a vector of ID aliases of specified length
#'
## Copyright(c) 2017-2020 R. Mark Sharp
## This file is part of nprcgenekeepr
#' ID aliases are pseudorandom sequences of alphanumeric upper case characters
#' where the letter "O" is not included for readability..
#' User has the option of providing a character vector of aliases to avoid
#' using.
#'
#' @return A named character vector of aliases where the name is the original
#' ID value.
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' integerIds <- 1:10
#' obfuscateId(integerIds, size = 4)
#' characterIds <- paste0(paste0(sample(LETTERS, 1, replace = FALSE)), 1:10)
#' obfuscateId(characterIds, size = 4)
#' }
#' @param id character vector of IDs to be obfuscated (alias creation).
#' @param size character length of each alias
#' @param existingIds character vector of existing aliases to avoid duplication.
#' @importFrom stringi stri_c
#' @export
obfuscateId <- function(id, size = 10, existingIds = character(0)) {
  noOInLetters <- c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L",
                    "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y",
                    "Z")
  existingIds <- c(character(length(id)), existingIds)
  obfuscatedId <- character(length(id))
  for (i in seq_along(id)) {
    counter <- 0
    repeat {
      if (grepl("^U", id[i], ignore.case = TRUE)) {
        obfuscatedId[i] <- stri_c(c("U", sample(c(noOInLetters, stri_c(0:9)),
                                              size = size - 1, replace = TRUE)),
                                  collapse = "")
      } else {
        obfuscatedId[i] <- stri_c(sample(c(noOInLetters, stri_c(0:9)),
                                         size = size,
                                         replace = TRUE), collapse = "")
      }
      ## grepl is ensuring both IDs are Unknown or known
      if (!any(obfuscatedId[i] %in% existingIds) &&
          (grepl("^U", obfuscatedId[i], ignore.case = TRUE) ==
           grepl("^U", id[i], ignore.case = TRUE)))
        break
      counter <- counter + 1
      if (counter > 100)
        stop(paste0("Character length of alias IDs is too short to easily ",
                    "avoid duplicates"))
    }
    existingIds[i] <- obfuscatedId[i]
  }
  names(obfuscatedId) <- id
  obfuscatedId
}
