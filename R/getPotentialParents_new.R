#' Get the lists of portential parents for all individuals born in the colony
#' with one or two unknown parents.
#'
#' @return a list of list with each internal list being made up of an animal
#' id (\code{id}), a vector of possible sires (\code{sire}) and a vector of
#' possible dams (\code{dam}). The \code{id} must be defined while the
#' vectors \code{sire} and \code{dam} can be empty.
#'
#' @param ped the pedigree information in data.frame format.  Pedigree
#' (req. fields: id, sire, dam, gen, population).
#' This requires complete pedigree information.
#' @param minParentAge numeric values to set the minimum age in years for
#' an animal to have an offspring. Defaults to 2 years. The check is not
#' performed for animals with missing birth dates.
#' @param maxGestationalPeriod integer value describing the days between
#' conception and birth. This will be used to prevent the removal of sires
#' who exit the colony between date of conception and birth. Need to decide
#' where this will come from.
#' @importFrom stringi stri_sub
#' @export
getPotentialParents <- function(ped, minParentAge, maxGestationalPeriod) {
  ## Remove the records of automatically generated IDs
  ## TODO change identification of automatically generated IDs from looking for
  ## an initial "U" at the beginning of an ID to a function call so that actual
  ## ID that start with a "U" are possible.
  ped <- ped[!stri_sub(ped$id, 1, 1)  == "U", ]
  ped$sire[stri_sub(ped$sire, 1, 1)  == "U" ] <- NA
  ped$dam[stri_sub(ped$dam, 1, 1)  == "U" ] <- NA

  ## pUnknown becomes the pedigree records of animals with at least one unknown
  ## parent
  pUnknown <- ped[ped$fromCenter &
                    (is.na(ped$sire) | is.na(ped$dam)), ]
  pUnknown <- pUnknown[!is.na(pUnknown$id), ]

  dYear <- 365 # used for number of days in a year

  ## add calcs for births and pre-allocate memory

  potentialParents <- vector(mode = "list", length = nrow(pUnknown))
  if (nrow(pUnknown) > 0) {
    for (i in 1:nrow(pUnknown)) {
      ## Calculating breeding age potential parents
      ba <- ped[ped$birth <= (pUnknown$birth[i] - (dYear * minParentAge)), ]
      ba <- ba[!is.na(ba$id), ]
      if (nrow(ba) == 0)
        next
      ## Selecting sires
      potentialSires <- ba[ba$sex == "M" &
                      (is.na(ba$exit) |
                         ba$exit >= (pUnknown$birth[i] - maxGestationalPeriod))
                    , "id"]

      ## Selecting dams
      potentialDams <- ba[ba$sex == "F" &
                    (is.na(ba$exit) |
                       ba$exit >= pUnknown$birth[i])
                  , ]

      ## Females who had an offspring in rolling year of focal offspring birth
      births <-
        ped[ped$birth >= pUnknown$birth[i] - (dYear / 2) &
              ped$birth <= pUnknown$birth[i] + (dYear / 2), ]

      ## Females who had an offspring in the year prior or year after
      births_plus_minus_one <-
        ped[(
          ped$birth <= pUnknown$birth[i] + (dYear * 1.5) &
            ped$birth > pUnknown$birth[i] + (dYear / 2)
        ) |
          (
            ped$birth >= pUnknown$birth[i] - (dYear * 1.5) &
              ped$birth < pUnknown$birth[i] - (dYear / 2)
          ), ]
      births_plus_minus_one <-
        births_plus_minus_one[!duplicated(births_plus_minus_one$dam), ]


      ## Remove from consideration those dams who gave birth within 1/2 year
      ## of birth date
      potentialDams <- potentialDams[!potentialDams$id %in% births$dam, ]
      ## Preferrentially accept dams that are proven breeders near the time of
      ## the birth.
      potentialDams <- potentialDams[
        potentialDams$id %in% births_plus_minus_one$dam, ]
      ## If no potential dams have been identified thus far, accept all females
      ## old enough to be the dam.
      if (nrow(potentialDams) == 0) {
        potentialDams <- ba[ba$sex == "F" &
                      (is.na(ba$exit) |
                         ba$exit >= pUnknown$birth[i])
                    , ]
      }

      potentialParents[[i]] <- list(
        "id" = pUnknown$id[i][1],
        "sires" = potentialSires,
        "dams" = potentialDams$id
      )
    }
  }
  potentialParents
}
