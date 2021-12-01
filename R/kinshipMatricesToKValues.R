#' Forms kValue matrix from list of kinship matrices
#'
#' A `kValue` matrix has one row for each pair of individuals in the kinship
#' matrix and one column for each kinship matrix.
#' @examples
#' \donttest{
#' ped <- nprcgenekeepr::smallPed
#' simParent_1 <- list(id = "A",
#'                    sires = c("s1_1", "s1_2", "s1_3"),
#'                    dams = c("d1_1", "d1_2", "d1_3", "d1_4"))
#' simParent_2 <- list(id = "B",
#'                    sires = c("s1_1", "s1_2", "s1_3"),
#'                    dams = c("d1_1", "d1_2", "d1_3", "d1_4"))
#' simParent_3 <- list(id = "E",
#'                    sires = c("A", "C", "s1_1"),
#'                    dams = c("d3_1", "B"))
#' simParent_4 <- list(id = "J",
#'                    sires = c("A", "C", "s1_1"),
#'                    dams = c("d3_1", "B"))
#' simParent_5 <- list(id = "K",
#'                    sires = c("A", "C", "s1_1"),
#'                    dams = c("d3_1", "B"))
#' simParent_6 <- list(id = "N",
#'                    sires = c("A", "C", "s1_1"),
#'                    dams = c("d3_1", "B"))
#' allSimParents <- list(simParent_1, simParent_2, simParent_3,
#'                      simParent_4, simParent_5, simParent_6)
#' extractKinship <- function(simKinships, id1, id2, simulation) {
#'  ids <- dimnames(simKinships[[simulation]])[[1]]
#'  simKinships[[simulation]][seq_along(ids)[ids == id1],
#'                            seq_along(ids)[ids == id2]]
#' }
#' extractKValue <- function(kValue, id1, id2, simulation) {
#'  kValue[kValue$id_1 ==  id1 & kValue$id_2 == id2, paste0("sim_", simulation)]
#' }
#' n <- 10
#' simKinships <- createSimKinships(ped, allSimParents, pop = ped$id, n = n)
#' kValues <- kinshipMatricesToKValues(simKinships)
#' extractKValue(kValues, id1 = "A", id2 = "F", simulation = 1:n)
#' }
#'
#' @param kinshipMatrices list of square matrices of kinship values. May or
#' may not have named rows and columns.
#' @export
kinshipMatricesToKValues <- function(kinshipMatrices) {
  first <- TRUE
  for (i in seq_along(kinshipMatrices)) {
    if (first) {
      kValues <- as.data.frame(as.table(kinshipMatrices[[i]]))
      names(kValues) <- c("id_1", "id_2", "sim_1")
      first <- FALSE
    } else { # only need kinship value
      kValues[paste0("sim_", i)] <-
        as.numeric(as.data.frame(as.table(kinshipMatrices[[i]]))$Freq)
    }
  }
  kValues$id_1 <- as.character(kValues$id_1)
  kValues$id_2 <- as.character(kValues$id_2)
  kValues
}
