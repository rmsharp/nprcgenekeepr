% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getDateErrorsAndConvertDatesInPed.R
\name{getDateErrorsAndConvertDatesInPed}
\alias{getDateErrorsAndConvertDatesInPed}
\title{Converts columns of dates in text form to \code{Date} object columns}
\usage{
getDateErrorsAndConvertDatesInPed(sb, errorLst)
}
\arguments{
\item{sb}{A dataframe containing a table of pedigree and demographic
information.}

\item{errorLst}{object with placeholders for error types found in a pedigree
file by \code{qcStudbook} through the functions it calls.}
}
\value{
A list with the pedigree, \code{sb}, and the \code{errorLst} with
invalid date rows (\code{errorLst$invalidDateRows})
}
\description{
Finds date errors in columns defined in
\code{convertDate} as dates and converts date strings to \code{Date} objects.
}
\details{
If there are no errors that prevent the calculation of exit dates, they are
calculated and added to the pedigree otherwise the pedigree is not updated.
}
\examples{
library(nprcgenekeepr)
ped <- nprcgenekeepr::pedInvalidDates
ped
errorLst <- getEmptyErrorLst()
colNamesAndErrors <- fixColumnNames(names(ped), errorLst)
names(ped) <- colNamesAndErrors$newColNames
pedAndErrors <- getDateErrorsAndConvertDatesInPed(ped, errorLst)
pedAndErrors$sb
pedAndErrors$errorLst
}
