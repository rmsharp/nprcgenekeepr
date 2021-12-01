#' Makes a list object of matrices made up of upper and lower triangles a list
#' of kinship matraces.
#'
#' @return one matrix for each pair of input matracies with the upper triangle
#' coming from the upper triangle and the diagnal of the odd matrix and
#' the lower triangle coming from the even matrix.
#'
#'
#' @examples
#' \donttest{
#' ped <- nprcgenekeepr::smallPed
#' simParent_1 <- list(id = "A",
#'                     sires = c("s1_1", "s1_2", "s1_3"),
#'                     dams = c("d1_1", "d1_2", "d1_3", "d1_4"))
#' simParent_2 <- list(id = "B",
#'                     sires = c("s2_1", "s2_2", "s2_3"),
#'                     dams = c("d2_1", "d2_2", "d2_3", "d2_4"))
#' simParent_3 <- list(id = "E",
#'                     sires = c("s3_1", "s3_2", "s3_3"),
#'                     dams = c("d3_1", "d3_2", "d3_3", "d3_4"))
#' allSimParents <- list(simParent_1, simParent_2, simParent_3)
#' pop <- LETTERS[1:7]
#' cKinships <- createSimKinships(ped, allSimParents, pop, n = 10)
#' combinedTriangles <- combineKinshipTriangles(cKinships)
#' }
#'
#' @param a list object of kinship matrices from simulated pedigrees of possible
#' parents for animals with unknown parents
#' @importFrom gdata lowerTriangle
#' @export
combineKinshipTriangles <- function(simKinships) {
  n <- length(simKinships)
  m <- n + (n %% 2)
  cKinships <- vector(mode = "list", length = (n + 1) %/% 2)
  for (i in seq_len(n)) {
    j <- (i + 1) %/% 2
    simPed <- makeSimPed(ped, allSimParents)
    if (i %% 2 == 0) {
      # lowerTriangle(cKinships[[j]], byrow = TRUE) <- lowerTriangle(simPed)
    } else {
      cKinships[[j]] <- kinship(simPed$id, simPed$sire,
                                  simPed$dam, simPed$gen)
    }
  }
  if (m != n)
    lowerTriangle(cKinships[[j]], byrow = TRUE) <- NA

  cKinships
}

