% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getFocalAnimalPed.R
\name{getFocalAnimalPed}
\alias{getFocalAnimalPed}
\title{Get pedigree based on list of focal animals}
\usage{
getFocalAnimalPed(fileName, sep = ",")
}
\arguments{
\item{fileName}{character vector of temporary file path.}

\item{sep}{column separator in CSV file}
}
\value{
A pedigree file compatible with others in this package.
}
\description{
Get pedigree based on list of focal animals
}
\examples{
library(nprcgenekeepr)
siteInfo <- getSiteInfo(FALSE)
source <- " generated by getFocalAnimalPed: "
tryCatch(getFocalAnimalPed(fileName = "breeding file.csv"),
  warning = function(wCond) {
    cat(paste0("Warning", source, wCond),
      name = "nprcgenekeepr"
    )
    return(NULL)
  },
  error = function(eCond) {
    cat(paste0("Error", source, eCond),
      name = "nprcgenekeepr"
    )
    return(NULL)
  }
)
}
