#' Counts the number of occurrences of each kinship value seen for a pair of
#' individuals in a series of simulated pedigrees.
#'
#' @examples
#' \donttest{
#' set.seed(20210529)
#' size <- 10000 # Represent simulated pedigrees
#' numRows <- 100 # Represents number of pairs of individuals.
#' kSamples <- sample(c(0, 0.0675, 0.125, 0.25, 0.5, 0.75), size = size,
#'                    replace = TRUE,
#'                    prob = c(0.005, 0.3, 0.15, 0.075, 0.0375, 0.01875))
#' # Each row in `kSamples` represents a pair of individuals in a pedigree
#' kSamples <- matrix(kSamples, nrow = numRows, byrow = TRUE)
#' # `kVC` is assigned the Kinshp Values found and the Count of each.
#' kVC <- countKinshipValues(kSamples)
#' kVC$kinshipValues[[1]]
#' kVC$kinshipCounts[[1]]
#' }
#'
#' @param kValues matrix of kinship values from simulated pedigrees where each
#'        row represents a pair of individuals in the pedigree and each column
#'        represents the vector of kinship values generated in a simulated
#'        pedigree.
#' \emph{nprcgenekeepr})
#' @export
countKinshipValues <- function(kValues) {
  kinshipValues <- kinshipCounts <- list(length(kValues))

  for (row in seq_len(nrow(kValues))) {
    valuesTable <- table(kValues[row, ])
    kinshipValues[[row]] <- as.numeric(names(valuesTable))
    kinshipCounts[[row]] <- as.numeric(valuesTable)
  }
  list(kinshipValues = kinshipValues,
       kinshipCounts = kinshipCounts)
}
