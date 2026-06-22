#' Get the lists of portential parents for all individuals born in the colony
#' with one or two unknown parents
#'
#' `r lifecycle::badge('experimental')`
#'
#' @return a list of list with each internal list being made up of an animal
#' id (\code{id}), a vector of possible sires (\code{sire}) and a vector of
#' possible dams (\code{dam}). The \code{id} must be defined while the
#' vectors \code{sire} and \code{dam} can be empty.
#'
#' @param ped the pedigree information in data.frame format. Pedigree
#' (req. fields: id, sire, dam, gen, population).
#' This requires complete pedigree information.
#' @param minParentAge numeric values to set the minimum age in years for
#' an animal to have an offspring. Defaults to 2 years. The check is not
#' performed for animals with missing birth dates.
#' @param maxGestationalPeriod integer maximum number of days between conception
#' and birth for the species being analyzed (a conservative upper bound, e.g.
#' 210 for rhesus whose typical gestation is about 165 days). When \code{NULL}
#' (the default) the window is looked up per animal from the \code{species}
#' column of \code{ped} via \code{\link{getSpeciesGestation}}, falling back to
#' 210 days for animals whose species is missing or unrecognized; supply an
#' explicit integer to use one fixed window for every animal. It is used two
#' ways: (1) a sire who exited the colony between conception
#' (birth - maxGestationalPeriod) and birth is still retained as a candidate;
#' and (2) a female who delivered another offspring within maxGestationalPeriod
#' days of the focal birth is excluded as a candidate dam, because a female
#' bears one offspring at a time. The sire check uses presence at conception
#' while the dam check uses presence at birth; this asymmetry is intentional --
#' a sire need only be present to conceive, whereas a dam must be present
#' through the pregnancy to give birth.
#' @param gestationTable optional data.frame (columns \code{species},
#' \code{gestation}) passed to \code{\link{getSpeciesGestation}} for the
#' per-animal lookup when \code{maxGestationalPeriod} is \code{NULL}. Defaults
#' to \code{NULL}, which uses the bundled \code{\link{speciesGestation}} table.
#' @importFrom data.table as.data.table
#' @importFrom stringi stri_sub
#' @export
getPotentialParents <- function(ped, minParentAge, maxGestationalPeriod = NULL,
                                gestationTable = NULL) {
  birth <- exit <- fromCenter <- id <- sex <- NULL

  ## No point in looking at animals without a birth record.
  ped <- data.table::as.data.table(ped)
  ped <- ped[!is.na(ped$birth), ]
  ## No point in looking for potential parents without a "fromCenter" column.
  if (!any(names(ped) == "fromCenter")) {
    return(NULL)
  }
  ## Remove the records of automatically generated IDs
  ped <- removeAutoGenIds(ped)

  ## pUnknown becomes the pedigree records of animals with at least one unknown
  ## parent
  pUnknown <- ped[fromCenter &
    (is.na(ped$sire) | is.na(ped$dam)), ]
  pUnknown <- pUnknown[!is.na(pUnknown$id), ]

  ## Per-focal-animal gestation window (#46 item 2). When maxGestationalPeriod
  ## is supplied it is used for every animal (historical behavior); when NULL it
  ## is keyed to each focal animal's species, falling back to 210 days when the
  ## species column is absent, missing, or unrecognized.
  if (is.null(maxGestationalPeriod)) {
    speciesVec <- if ("species" %in% names(pUnknown)) {
      pUnknown$species
    } else {
      rep(NA_character_, nrow(pUnknown))
    }
    mgpVec <- getSpeciesGestation(speciesVec, gestationTable = gestationTable)
  } else {
    mgpVec <- rep(as.integer(maxGestationalPeriod), nrow(pUnknown))
  }

  dYear <- 365L # used for number of days in a year

  ## add calcs for births and pre-allocate memory

  potentialParents <- vector(mode = "list", length = nrow(pUnknown))
  j <- 0L # counter for potentialParents; used to prevent NULL entries
  if (nrow(pUnknown) > 0L) {
    for (i in seq_len(nrow(pUnknown))) {
      mgp <- mgpVec[i] # gestation window for this focal animal (#46 item 2)
      ## Calculating breeding age potential parents
      ba <- ped[birth <= (pUnknown$birth[i] - (dYear * minParentAge)), ]
      ba <- ba[!is.na(ba$id), ]
      if (nrow(ba) == 0L) {
        next
      }
      j <- j + 1L
      ## Selecting sires
      potentialSires <- ba[
        sex == "M" &
          (is.na(ba$exit) |
            exit >= (pUnknown$birth[i] - mgp)),
        id
      ]

      ## Selecting dams
      potentialDams <- ba[sex == "F" &
        (is.na(ba$exit) |
          exit >= pUnknown$birth[i]), ]

      ## Females who delivered another offspring within one gestational period
      ## of the focal birth: a female bears one offspring at a time, so she
      ## cannot have gestated the focal animal as well (see the dam exclusion
      ## below). The window is gestation-derived (maxGestationalPeriod) rather
      ## than the former fixed half-year.
      births <-
        ped[birth >= pUnknown$birth[i] - mgp &
          birth <= pUnknown$birth[i] + mgp, ]

      ## Females who had an offspring in the year prior or year after
      births_plus_minus_one <-
        ped[(
          birth <= pUnknown$birth[i] + (dYear * 1.5) &
            birth > pUnknown$birth[i] + (dYear / 2L)
        ) |
          (
            birth >= pUnknown$birth[i] - (dYear * 1.5) &
              birth < pUnknown$birth[i] - (dYear / 2L)
          ), ]
      births_plus_minus_one <-
        births_plus_minus_one[!duplicated(births_plus_minus_one$dam), ]


      ## Remove from consideration dams who gave birth within one gestational
      ## period (maxGestationalPeriod) of the focal birth: bearing one offspring
      ## at a time, such a female cannot also have gestated the focal animal.
      ## (#31 -- replaces the former fixed half-year window with this
      ## gestation-derived one, driven by the existing maxGestationalPeriod.)
      potentialDams <- potentialDams[!id %in% births$dam, ]
      ## Preferrentially accept dams that are proven breeders near the time of
      ## the birth.
      potentialDams <- potentialDams[id %in% births_plus_minus_one$dam, ]
      ## If no potential dams have been identified thus far, accept all females
      ## old enough to be the dam.
      if (nrow(potentialDams) == 0L) {
        potentialDams <-
          ba[sex == "F" & (is.na(ba$exit) | exit >= pUnknown$birth[i]), ]
      }

      potentialParents[[j]] <- list(
        id = pUnknown$id[i][1L],
        sires = potentialSires,
        dams = potentialDams$id
      )
    }
  }
  if (j > 0L) {
    potentialParents[1L:j]
  } else {
    NULL
  }
}
