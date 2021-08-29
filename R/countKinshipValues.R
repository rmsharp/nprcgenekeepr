#' Counts the number of occurrences of each kinship value seen for a pair of
#' individuals in a series of simulated pedigrees.
#'
#' @examples
#' \donttest{
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
#'   kValue[kValue$id_1 ==  id1 & kValue$id_2 == id2, paste0("sim_", simulation)]
#' }
#'
#' n <- 10
#' simKinships <- createSimKinships(ped, allSimParents, pop = ped$id, n = n)
#' kValues <- kinshipMatricesToKValues(simKinships)
#' extractKValue(kValues, id1 = "A", id2 = "F", simulation = 1:n)
#' counts <- countKinshipValues(kValues)
#' }
#'
#' @param kValues matrix of kinship values from simulated pedigrees where each
#'        row represents a pair of individuals in the pedigree and each column
#'        represents the vector of kinship values generated in a simulated
#'        pedigree.
#' \emph{nprcgenekeepr})
#' @export
countKinshipValues <- function(kValues) {
  idCols <- c("id_1", "id_2")
  valueCols <- names(kValues)[!is.element(names(kValues), idCols)]
  kinshipIds <- kinshipValues <- kinshipCounts <-
    vector(mode = "list", length = length(valueCols))

  for (row in seq_len(nrow(kValues))) {
    valuesTable <- table(as.numeric(kValues[row, valueCols]))
    kinshipIds[[row]] <- as.character(kValues[row, idCols])
    kinshipValues[[row]] <- as.numeric(names(valuesTable))
    kinshipCounts[[row]] <- as.numeric(valuesTable)
  }
  list(kinshipIds = kinshipIds,
       kinshipValues = kinshipValues,
       kinshipCounts = kinshipCounts)
}
