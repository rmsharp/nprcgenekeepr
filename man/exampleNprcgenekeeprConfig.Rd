% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{exampleNprcgenekeeprConfig}
\alias{exampleNprcgenekeeprConfig}
\title{exampleNprcgenekeeprConfig is a loadable version of the example
configuration file \code{example_nprcgenekeepr_config}}
\format{
An object of class \code{character} of length 34.
}
\usage{
exampleNprcgenekeeprConfig
}
\description{
It contains a working version of a \strong{nprcgenekeepr} configuration
file created the SNPRC.
Users of LabKey's EHR can adapt it to their systems and put it
in their home directory. Instructions are embedded as comments
within the file.
}
\examples{
library(nprcgenekeepr)
data("exampleNprcgenekeeprConfig")
head(exampleNprcgenekeeprConfig)
}
\keyword{datasets}
