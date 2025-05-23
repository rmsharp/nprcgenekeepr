% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getPedigree.R
\name{getPedigree}
\alias{getPedigree}
\title{Get pedigree from file}
\usage{
getPedigree(fileName, sep = ",")
}
\arguments{
\item{fileName}{character vector of temporary file path.}

\item{sep}{column separator in CSV file}
}
\value{
A pedigree file compatible with others in this package.
}
\description{
Get pedigree from file
}
\examples{
library(nprcgenekeepr)
ped <- getPedigree(fileName = system.file("testdata", "qcPed.csv",
  package = "nprcgenekeepr"
))
}
