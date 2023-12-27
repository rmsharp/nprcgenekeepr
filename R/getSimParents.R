#' Gets a list of representative sires and dams for an individual obtained by
#' searching pedigree.
#'
#' Representative sires and dams are defined as animals are to have the
#' following characteristics.
#' \enumerate{
#' \item{Alive at the time of birth}{This is okay for dams but weak for sires
#'       as sire could have died prior to birth. This should be strengthed
#'       with a gestational time estimate. A gestational time of 0 is
#'       currently used.}
#' \item{}
#' }
#' The function getRepresentativeParents is used to find representative parents
#' within the pedigree that could have been the parent for an animal born within
#' the pedigree that does not have one or more parents identified. These
#' representative parents are then used to calculate an estimated kinship
#' coefficient by averaging the kinship coefficient of the sires and of the
#' dams.
#'
#' The current strategy is to use all representative parents as defined by the
#' criteria above. This could be enhanced by allowing the user to provide
#' a list of representative parents if available. This could be easily handled.
getRepresentativeParents <- function(id, ped) {

}
