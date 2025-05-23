% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/checkGenotypeFile.R
\name{checkGenotypeFile}
\alias{checkGenotypeFile}
\title{Check genotype file}
\usage{
checkGenotypeFile(genotype)
}
\arguments{
\item{genotype}{dataframe with genotype data}
}
\value{
A genotype file that has been checked to ensure the column types and
number required are present. The returned genotype file has the first column
name forced to "id".
}
\description{
Checks to ensure the content and structure are appropriate for a genotype
file. These checks are simply based on expected columns and legal domains.
}
\examples{
library(nprcgenekeepr)
ped <- nprcgenekeepr::qcPed
ped <- ped[order(ped$id), ]
genotype <- data.frame(
  id = ped$id[50 + 1:20],
  first_name = paste0("first_name", 1:20),
  second_name = paste0("second_name", 1:20),
  stringsAsFactors = FALSE
)

## checkGenotypeFile disallows dataframe with < 3 columns
tryCatch(
  {
    checkGenotypeFile(genotype[, c("id", "first_name")])
  },
  warning = function(w) {
    cat("Warning produced")
  },
  error = function(e) {
    cat("Error produced")
  }
)
}
