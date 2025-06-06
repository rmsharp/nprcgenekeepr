% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/kinMatrix2LongForm.R
\name{kinMatrix2LongForm}
\alias{kinMatrix2LongForm}
\title{Reformats a kinship matrix into a long-format table.}
\usage{
kinMatrix2LongForm(kinMatrix, removeDups = FALSE)
}
\arguments{
\item{kinMatrix}{numerical matrix of pairwise kinship values. The row and
column names correspond to animal IDs.}

\item{removeDups}{logical value indication whether or not reverse-order ID
pairs be filtered out? (i.e., "ID1 ID2 kin_val" and "ID2 ID1 kin_val" will
be collapsed into a single entry if removeDups = TRUE)}
}
\value{
A dataframe with columns \code{id1}, \code{id2}, and \code{kinship}.
This is the kinship data reformatted from a matrix, to a long-format table.
}
\description{
Part of Group Formation
}
\examples{
library(nprcgenekeepr)
ped <- nprcgenekeepr::lacy1989Ped
ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
reformattedKmat <- kinMatrix2LongForm(kmat, removeDups = FALSE)
nrow(reformattedKmat)
reformattedNoDupsKmat <- kinMatrix2LongForm(kmat, removeDups = TRUE)
nrow(reformattedNoDupsKmat)
}
