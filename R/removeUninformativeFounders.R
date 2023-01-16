#' Remove uninformative founders.
#'
## Copyright(c) 2017-2023 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Founders (having unknown sire and dam) that appear only one time in a
#' pedigree are uninformative and can be removed from a pedigree without loss
#' of information.
#'
#' @return A reduced pedigree.
#'
#' @examples
#' \donttest{
#' examplePedigree <- nprcgenekeepr::examplePedigree
#' breederPed <- qcStudbook(examplePedigree, minParentAge = 2,
#'                          reportChanges = FALSE,
#'                          reportErrors = FALSE)
#' probands <- breederPed$id[!(is.na(breederPed$sire) &
#'                                is.na(breederPed$dam)) &
#'                                is.na(breederPed$exit)]
#' ped <- getProbandPedigree(probands, breederPed)
#' nrow(ped)
#' p <- removeUninformativeFounders(ped)
#' nrow(p)
#' p <- addBackSecondParents(p, ped)
#' nrow(p)
#' }
#'
#' @param ped datatable that is the `Pedigree`. It contains pedigree
#' information. The fields \code{sire} and \code{dam} are required.
#' @export
removeUninformativeFounders <- function(ped) {
  required <- c("id", "sire", "dam")
  if (!all(required %in% names(ped)))
    stop(paste0("Pedigree is missing ",
                paste0(required[!required %in% names(ped)],
                collapse = ", ")))

  while (TRUE) {
    founders <- ped$id[is.na(ped$sire) & is.na(ped$dam)]

    sires <- as.data.frame(table(ped$sire[ped$sire %in% founders]))
    dams <- as.data.frame(table(ped$dam[ped$dam %in% founders]))
    sires$Var1 <- as.character(sires$Var1)
    dams$Var1 <- as.character(dams$Var1)

    rmv <- c(sires$Var1[sires$Freq == 1], dams$Var1[dams$Freq == 1])
    if (isEmpty(rmv)) {
      break
    }

    ped$sire[ped$sire %in% rmv] <- NA
    ped$dam[ped$dam %in% rmv] <- NA
    ped <- ped[!(ped$id %in% rmv), ]

  }
  ped
}
