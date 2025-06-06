% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/removeUnknownAnimals.R
\name{removeUnknownAnimals}
\alias{removeUnknownAnimals}
\title{removeUnknownAnimals Removes unknown animals added to pedigree that serve as
placeholders for unknown parents.}
\usage{
removeUnknownAnimals(ped)
}
\arguments{
\item{ped}{pedigree dataframe}
}
\value{
Pedigree with unknown animals removed
}
\description{
removeUnknownAnimals Removes unknown animals added to pedigree that serve as
placeholders for unknown parents.
}
\examples{
library(nprcgenekeepr)
ped <- nprcgenekeepr::smallPed
addedPed <- cbind(ped,
  recordStatus = rep("original", nrow(ped)),
  stringsAsFactors = FALSE
)
addedPed[1:3, "recordStatus"] <- "added"
ped2 <- removeUnknownAnimals(addedPed)
nrow(ped)
nrow(ped2)
}
