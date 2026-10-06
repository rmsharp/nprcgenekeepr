## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Make a relation classes table from kinship pairs
#'
#' Counts the pairs of animals in each relationship class of a long-form
#' kinship table.
#'
#' @param kin a dataframe with columns \code{id1}, \code{id2}, \code{kinship},
#' and \code{relation}. It is a long-form table of pairwise kinships, with
#' relationship categories included for each pair.
#' @return A data.frame with columns \code{Relationship Class} and
#' \code{Frequency}: the number of pairs in each of the following relationship
#' classes: Parent-Offspring, Full-Siblings, Half-Siblings,
#' Grandparent-Grandchild, Full-Cousins, Cousin - Other, Full-Avuncular,
#' Avuncular - Other, Other, and No Relation. Self pairs are not counted, and
#' classes with no pairs are left out.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' suppressMessages(library(dplyr))
#'
#' qcPed <- nprcgenekeepr::qcPed
#' qcPed <- qcPed[1:50, ] # Comment out for full example
#' bkmat <- kinship(qcPed$id, qcPed$sire, qcPed$dam, qcPed$gen,
#'   sparse = FALSE
#' )
#' kin <- convertRelationships(bkmat, qcPed)
#' relClasses <- makeRelationClassesTable(kin)
#' relClasses$`Relationship Class` <-
#'   as.character(relClasses$`Relationship Class`)
#' relClassTbl <- kin[!kin$relation == "Self", ] |>
#'   group_by(relation) |>
#'   summarise(count = n())
#' relClassTbl
makeRelationClassesTable <- function(kin) {
  relationClass <- unname(relationClassNames)

  kin <- kin[kin$relation != relationClassNames[["self"]], ]
  if (nrow(kin) == 0L) {
    return(data.frame(
      `Relationship Class` = factor(character(0L)),
      Frequency = integer(0L), check.names = FALSE
    ))
  }
  r <- as.data.frame(table(kin$relation))
  colnames(r) <- c("Relationship Class", "Frequency")

  relationClass <- relationClass[relationClass %in% r[, "Relationship Class"]]
  r[match(relationClass, r[, "Relationship Class"]), ]
}
