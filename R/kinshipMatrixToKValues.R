#' Extracts a dataframe with a row for each kinship coeficient in the kinship
#' matrix
#'
#' A `kValue` matrix has one row for each pair of individuals in the kinship
#' matrix and one column for each kinship matrix.
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::smallPed
#' simParent_1 <- list(id = "A",
#'                     sires = c("s1_1", "s1_2", "s1_3"),
#'                     dams = c("d1_1", "d1_2", "d1_3", "d1_4"))
#' simParent_2 <- list(id = "B",
#'                     sires = c("s1_1", "s1_2", "s1_3"),
#'                     dams = c("d1_1", "d1_2", "d1_3", "d1_4"))
#' simParent_3 <- list(id = "E",
#'                     sires = c("A", "C", "s1_1"),
#'                     dams = c("d3_1", "B"))
#' simParent_4 <- list(id = "J",
#'                     sires = c("A", "C", "s1_1"),
#'                     dams = c("d3_1", "B"))
#' simParent_5 <- list(id = "K",
#'                     sires = c("A", "C", "s1_1"),
#'                     dams = c("d3_1", "B"))
#' simParent_6 <- list(id = "N",
#'                     sires = c("A", "C", "s1_1"),
#'                     dams = c("d3_1", "B"))
#' allSimParents <- list(simParent_1, simParent_2, simParent_3,
#'                       simParent_4, simParent_5, simParent_6)
#'
#' extractKinship <- function(simKinships, id1, id2, simulation) {
#'   ids <- dimnames(simKinships[[simulation]])[[1]]
#'   simKinships[[simulation]][seq_along(ids)[ids == id1],
#'                             seq_along(ids)[ids == id2]]
#' }
#'
#' extractKValue <- function(kValue, id1, id2, simulation) {
#'   kValue[kValue$id_1 ==  id1 & kValue$id_2 == id2,
#'          paste0("sim_", simulation)]
#' }
#'
#' simPed <- makeSimPed(ped, allSimParents)
#' simKinship <- kinship(simPed$id, simPed$sire,
#'                       simPed$dam, simPed$gen)
#' kValues <- kinshipMatrixToKValues(simKinship)
#' }
#'
#' @return data.frame object with columns \code{id_1}, \code{id_2}, and
#' \code{kinship} where the first two columns contain the IDs of the
#' individuals in the kinship matrix provided to the function and the
#' \code{kinship} columm contains the corresponding kinship coefficient.
#' In contrast to the kinship matrix. Each possible pairing of IDs appears
#' once.

#' @param kinshipMatrix square kinship matrix. May or may not have named
#' rows and columns.
#' @importFrom data.table as.data.table
#' @export
kinshipMatrixToKValues <- function(kinshipMatrix) {
  # gdata::lowerTriangle(kinshipMatrix, byrow = TRUE) <- NA was replaced
  # with the next three lines
  ret <- t(kinshipMatrix)
  ret[rev(lower.tri(kinshipMatrix, diag = FALSE))] <- NA
  kinshipMatrix <- t(ret)

  kValues <- as.data.table(as.table(kinshipMatrix))
  kValues <- kValues[!is.na(kValues$N), ]
  kValues <- kValues[order(kValues$V1, kValues$V2), ]
  names(kValues) <- c("id_1", "id_2", "kinship")
  kValues$id_1 <- as.character(kValues$id_1)
  kValues$id_2 <- as.character(kValues$id_2)
  kValues
}
