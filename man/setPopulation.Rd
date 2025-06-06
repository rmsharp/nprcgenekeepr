% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/setPopulation.R
\name{setPopulation}
\alias{setPopulation}
\title{Population designation function}
\usage{
setPopulation(ped, ids)
}
\arguments{
\item{ped}{datatable that is the \code{Pedigree}. It contains pedigree
information. The \code{id} column is required.}

\item{ids}{character vector of IDs to be flagged as part of the population
under consideration.}
}
\value{
An updated pedigree with the \code{population} column added or
updated by being set to \code{TRUE} for the animal IDs in \code{ped$id} and
\code{FALSE} otherwise.
}
\description{
Part of the pedigree filtering toolset.
}
\examples{
examplePedigree <- nprcgenekeepr::examplePedigree
breederPed <- qcStudbook(examplePedigree,
  minParentAge = 2,
  reportChanges = FALSE,
  reportErrors = FALSE
)
focalAnimals <- breederPed$id[!(is.na(breederPed$sire) &
  is.na(breederPed$dam)) &
  is.na(breederPed$exit)]
breederPed <- setPopulation(ped = breederPed, ids = focalAnimals)
nrow(breederPed[breederPed$population, ])
}
