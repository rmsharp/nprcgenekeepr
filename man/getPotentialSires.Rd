% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getPotentialSires.R
\name{getPotentialSires}
\alias{getPotentialSires}
\title{Provides list of potential sires}
\usage{
getPotentialSires(ids, minAge = 1, ped)
}
\arguments{
\item{ids}{character vector of IDs of the animals}

\item{minAge}{integer value indicating the minimum age to consider in group
formation. Pairwise kinships involving an animal of this age or younger will
 be ignored. Default is 1 year.}

\item{ped}{dataframe that is the `Pedigree`. It contains pedigree
information including the IDs listed in \code{candidates}.}
}
\value{
A character vector of potential sire Ids
}
\description{
Provides list of potential sires
}
\examples{
\donttest{
library(nprcgenekeepr)
ped <- nprcgenekeepr::pedWithGenotype
ids <- nprcgenekeepr::qcBreeders
getPotentialSires(ids, minAge = 1, ped)
}

}
