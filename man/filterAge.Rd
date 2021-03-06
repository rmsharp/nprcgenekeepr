% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/filterAge.R
\name{filterAge}
\alias{filterAge}
\title{Removes kinship values where an animal is less than the minAge}
\usage{
filterAge(kin, ped, minAge = 1)
}
\arguments{
\item{kin}{a dataframe with columns \code{id1}, \code{id2}, and
\code{kinship}. This is the kinship data reformatted from a matrix,
to a long-format table.}

\item{ped}{dataframe of pedigree information including the IDs listed
in "candidates".}

\item{minAge}{numeric value representing minimum years of age of
animals to retain.}
}
\description{
Part of Group Formation
}
