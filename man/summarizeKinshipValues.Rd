% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summarizeKinshipValues.R
\name{summarizeKinshipValues}
\alias{summarizeKinshipValues}
\title{Summary statistics for imputed kinship values}
\usage{
summarizeKinshipValues(countedKValues)
}
\arguments{
\item{countedKValues}{list object from countKinshipValues function that
containes the lists \code{kinshipIds}, \code{kinshipValues},
and \code{kinshipCounts}.}
}
\value{
a data.frame with one row of summary statistics for each imputed
kinship value. The columns are as follows:
\code{id_1},
\code{id_2},
\code{min},
\code{secondQuartile},
\code{mean},
\code{median},
\code{thirdQuartile},
\code{max}, and
\code{sd}.
}
\description{
Makes a data.frame object containing simulated kinship summary statistics
using the counts of kinship values list from \code{countKinshipValues}.
}
\examples{
ped <- nprcgenekeepr::smallPed
simParent_1 <- list(
  id = "A",
  sires = c("s1_1", "s1_2", "s1_3"),
  dams = c("d1_1", "d1_2", "d1_3", "d1_4")
)
simParent_2 <- list(
  id = "B",
  sires = c("s1_1", "s1_2", "s1_3"),
  dams = c("d1_1", "d1_2", "d1_3", "d1_4")
)
simParent_3 <- list(
  id = "E",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
simParent_4 <- list(
  id = "J",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
simParent_5 <- list(
  id = "K",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
simParent_6 <- list(
  id = "N",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
allSimParents <- list(
  simParent_1, simParent_2, simParent_3,
  simParent_4, simParent_5, simParent_6
)

extractKinship <- function(simKinships, id1, id2, simulation) {
  ids <- dimnames(simKinships[[simulation]])[[1]]
  simKinships[[simulation]][
    seq_along(ids)[ids == id1],
    seq_along(ids)[ids == id2]
  ]
}

extractKValue <- function(kValue, id1, id2, simulation) {
  kValue[
    kValue$id_1 == id1 & kValue$id_2 == id2,
    paste0("sim_", simulation)
  ]
}

n <- 10
simKinships <- createSimKinships(ped, allSimParents, pop = ped$id, n = n)
kValues <- kinshipMatricesToKValues(simKinships)
extractKValue(kValues, id1 = "A", id2 = "F", simulation = 1:n)
counts <- countKinshipValues(kValues)
stats <- summarizeKinshipValues(counts)
}
