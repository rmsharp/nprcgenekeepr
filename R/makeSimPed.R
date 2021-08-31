#' Makes a simulated pedigree using representative sires and dams
#'
#' For each \code{id} in \code{allSimParents} with one or more unknow parents
#' each unknown parent is replaced with a random sire or dam as needed from
#' the corresponding parent vector (\code{sires} or \code{dams}).
#'
#' The algorithm assigns parents randomly from the lists of possible sires and
#' dams and does not prevent a dam from being selected more than once within
#' the same breeding period. While this is probably not introducing a large
#' error, it is not ideal.

#' @param ped The pedigree information in data.frame format
#' @param allSimParents list made up of lists where the internal list
#'        has the offspring ID \code{id}, a vector of representative sires
#'        (\code{sires}), and a vector of representative dams (\code{dams}).
#' @export
makeSimPed <- function(ped, allSimParents) {
  nIds <- length(allSimParents)

  for (i in seq_len(nIds)) {
    ped$sire[ped$id == allSimParents[[i]]$id] <-
      sample(allSimParents[[i]]$sires, size = 1)
    ped$dam[ped$id == allSimParents[[i]]$id] <-
      sample(allSimParents[[i]]$dams, size = 1)
  }
  ped
}
