#' Get the lists of portential parents for all individuals born in the colonly
#' with one or two unknown parents.
#'
#' @return a list of list with each internal list being made up of an animal
#' id (\code{id}), a vector of possible sires (\code{sire}) and a vector of
#' possible dams (\code{dam}). The \code{id} must be defined while the
#' vectors \code{sire} and \code{dam} can be empty.
#'
#' @param ped the pedigree information in datatable format.  Pedigree
#' (req. fields: id, sire, dam, gen, population).
#' This requires complete pedigree information.
#' @param minParentAge numeric values to set the minimum age in years for
#' an animal to have an offspring. Defaults to 2 years. The check is not
#' performed for animals with missing birth dates.
#' @export
getPotentialParents <- function(ped, minParentAge) {
  pUnknown <- ped[ped$fromCenter &
                    (is.na(ped$sire) | is.na(ped$dam)),]
  pUnknown <- pUnknown[!is.na(pUnknown$id), ]

  dYear <- 365 # used for number of days in a year

  ## add calcs for births and pre-allocate memory

  potentialParents <- vector(mode = "list", length = nrow(pUnknown))

  for (i in 1:nrow(pUnknown)) {
    ## Calculating breading age potential parents
    ba <- ped[ped$birth <= pUnknown$birth[i] - (dYear * minParentAge),]
    ba <- ba[!is.na(ba$id),]

    ## finding potential sires
    potentialSires <- ba[ba$sex == "M" &
                           (is.na(ba$exit) == TRUE |
                              ba$exit >= pUnknown$birth[i]), "id"]

    #if (nrow(puSire) > 0) {
    #  puSire <- cbind.data.frame(puSire$id, pUnknown$id[i], puSire$sex)
    #  colnames(puSire) <- c("potential_parent", "id", "sex")
    #  puOffspringSire <- rbind.data.frame(puOffspringSire, puSire)
    #}
    ## Selecting dams
    potentialDams <- ba[ba$sex == "F" &
                          (is.na(ba$exit) == TRUE |
                             ba$exit >= pUnknown$birth[i])
                        ,]

    births <-
      ped[ped$birth > pUnknown$birth[i] - (dYear / 2) &
            ped$birth < pUnknown$birth[i] + (dYear / 2),]

    births_plus_minus_one <-
      ped[(ped$birth < pUnknown$birth[i] + (dYear * 1.5) &
             ped$birth > pUnknown$birth[i] + (dYear / 2)) |
            (ped$birth > pUnknown$birth[i] - (dYear * 1.5) &
               ped$birth < pUnknown$birth[i] - (dYear / 2)),]
    births_plus_minus_one <-
      births_plus_minus_one[!duplicated(births_plus_minus_one$dam),]

    potentialDams <-
      potentialDams[!potentialDams$id %in% births$dam,]
    potentialDams <- potentialDams[potentialDams$id %in%
                                     births_plus_minus_one$dam,]

    #if (nrow(potentialDams) > 0) {
    #  potentialParents <- list( "id" = pUnknown$id[i][1],
    #                 "dam" = potentialDams$id,
    #                 "sire" = puSire$id
    #  )
    #  potentialDams <- cbind.data.frame(potentialDams$id, pUnknown$id[i],
    #                                    potentialDams$sex)
    #  colnames(potentialDams) <- c("potential_parent", "id", "sex")
    #  puOffspringDam <- rbind.data.frame(puOffspringDam, potentialDams)
    #} else {
    #  potentialDams <- ba[ba$sex == "F" &
    #                (is.na(ba$exit) == TRUE |
    #                ba$exit >= pUnknown$birth[i])
    #              , ]
    #  potentialDams <- potentialDams[!potentialDams$id %in% births$dam, ]
    #  if (nrow(potentialDams) > 0) {
    #    potentialDams <- cbind.data.frame(potentialDams$id, pUnknown$id[i],
    #                                      potentialDams$sex)
    #    colnames(potentialDams) <- c("potential_parent", "id", "sex")
    #    puOffspringDam <- rbind.data.frame(puOffspringDam, potentialDams)
    #  }
    #}
    potentialParents[[i]] <- list(
      "counter" = i,
      "id" = pUnknown$id[i],
      "sires" = potentialSires,
      "dams" = potentialDams$id
    )
  }
  potentialParents
}
