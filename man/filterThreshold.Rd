% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/filterThreshold.R
\name{filterThreshold}
\alias{filterThreshold}
\title{Filters kinship to remove rows with kinship values less than the specified
threshold}
\usage{
filterThreshold(kin, threshold = 0.015625)
}
\arguments{
\item{kin}{a dataframe with columns \code{id1}, \code{id2}, and
\code{kinship}. This is the kinship data reformatted from a matrix,
to a long-format table.}

\item{threshold}{numeric value representing the minimum kinship level to be
considered in group formation. Pairwise kinship below this level will be
ignored.}
}
\value{
The kinship matrix with all kinship relationships below the
threshold value removed.
}
\description{
Part of Group Formation
Filters kinship values less than the specified threshold from a long-format
table of kinship values.
}
\examples{
library(nprcgenekeepr)
ped <- nprcgenekeepr::lacy1989Ped
ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
kin <- kinMatrix2LongForm(kmat, removeDups = FALSE)
kinFiltered_0.3 <- filterThreshold(kin, threshold = 0.3)
kinFiltered_0.1 <- filterThreshold(kin, threshold = 0.1)
}
