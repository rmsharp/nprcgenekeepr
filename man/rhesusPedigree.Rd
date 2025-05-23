% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{rhesusPedigree}
\alias{rhesusPedigree}
\title{rhesusPedigree is a pedigree object}
\format{
An object of class \code{data.frame} with 375 rows and 8 columns.
}
\usage{
rhesusPedigree
}
\description{
Represents an obfuscated pedigree from \emph{rhesusPedigree.csv} where the
IDs and dates have been modified to de-identify the data.
\describe{
\item{id}{-- character column of animal IDs}
\item{sire}{-- the male parent of the animal indicated by the \code{id}
column. Unknown sires are indicated with \code{NA}}
\item{dam}{-- the female parent of the animal indicated by the \code{id}
column.Unknown dams are indicated with \code{NA}}
\item{sex}{-- factor with levels: "M", "F", "U". Sex specifier for an
individual.}
\item{gen}{-- generation number (integers beginning with 0 for the founder
generation) of the animal indicated by the \code{id} column.}
\item{birth}{-- Date vector of birth dates}
\item{exit}{-- Date vector of exit dates}
\item{age}{-- numerical vector of age in years}
}
}
\examples{
library(nprcgenekeepr)
data("rhesusPedigree")
}
\keyword{datasets}
