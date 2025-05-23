% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nprcgenekeeper.R, R/nprcgenekeepr-package.R
\docType{package}
\name{nprcgenekeepr-package}
\alias{nprcgenekeepr-package}
\title{Genetic Management Functions}
\description{
Primary Data Structure --- Pedigree

Contains studbook information for a number of individuals.
ASSUME: All IDs listed in the sire or dam columns must have a row entry in
the id column

\if{html}{\figure{logo.png}{options: style='float: right' alt='logo' width='120'}}

Provides genetic tools for colony management and is a derivation of the work in Amanda Vinson and Michael J Raboin (2015) \url{https://pmc.ncbi.nlm.nih.gov/articles/PMC4671785/} "A Practical Approach for Designing Breeding Groups to Maximize Genetic Diversity in a Large Colony of Captive Rhesus Macaques ('Macaca' 'mulatto')". It provides a 'Shiny' application with an exposed API. The application supports five groups of functions: (1) Quality control of studbooks contained in text files or 'Excel' workbooks and of pedigrees within 'LabKey' Electronic Health Records (EHR); (2) Creation of pedigrees from a list of animals using the 'LabKey' EHR integration; (3) Creation and display of an age by sex pyramid plot of the living animals within the designated pedigree; (4) Generation of genetic value analysis reports; and (5) Creation of potential breeding groups with and without proscribed sex ratios and defined maximum kinships.
}
\seealso{
\code{\link{getIncludeColumns}} to get set of columns that can
be used in a pedigree file

A Pedigree is a data frame within the \code{R} environment with the following
possible columns:
\itemize{
\item\{id\} \{-- character vector with unique identifier for an individual\}
\item\{sire\} \{-- character vector with unique identifier for an
individual's father (\code{NA} if unknown).\}
\item\{dam\} \{-- character vector with unique identifier for an
individual's mother (\code{NA} if unknown).\}
\item\{sex\} \{-- factor \{levels: "M", "F", "U"\} Sex specifier for an
individual\}
\item\{gen\} \{-- integer vector with the generation number of the
individual\}
\item\{birth\} \{-- Date or \code{NA} (optional) with the individual's birth
date\}
\item\{exit\} \{-- Date or \code{NA} (optional) with the individual's exit
date (death, or departure if applicable)\}
\item\{ancestry\} \{-- character vector or \code{NA} (optional) that
indicates the geographic population to which the individual belongs.\}
\item\{age\} \{-- numeric or \code{NA} (optional) indicating the individual's
current age or age at exit.\}
\item\{population\} \{-- logical (optional)
Is the id part of the extant population?\}
\item\{origin\} \{-- character vector or \code{NA} (optional) that indicates
the name of the facility that the individual was imported from if other than
local.\code{NA} indicates the individual was not imported.\}
}

Pedigree File Testing Functions

\itemize{
\item\{\link{qcStudbook}\} \{--- Main pedigree curation function that
performs basic quality control on pedigree information\}
\item\{\link{fixColumnNames}\} \{--- Changes original column names and into
standardized names.\}
\item\{\link{checkRequiredCols}\} \{--- Examines column names, cols, to see
if all required column names are present.\}
\item\{\link{correctParentSex}\} \{--- Sets sex for animals listed as either
a sire or dam.\}
\item\{\link{getDateErrorsAndConvertDatesInPed}\} \{--- Converts columns of
dates in text form to \code{Date} object columns\}
\item\{\link{checkParentAge}\} \{--- Check parent ages to be at least
\code{minParentAge}\}
\item\{\link{removeDuplicates}\} \{--- Remove duplicate records from
pedigree\}
}
Gene Dropping Function

\itemize{
\item\{\link{geneDrop}\} \{--- Performs a gene drop simulation based on the
provided pedigree information\}
}
Genetic Value Analysis Functions

Contains functions to calculate the kinship coefficient and genome
uniqueness for animals listed in a Pedigree table.
\itemize{
\item\{\link{meanKinship}\} \{--- Calculates the mean kinship for each animal
in a kinship matrix\}
\item\{\link{calcA}\} \{--- Calculates \code{a}, the number of an
individual's alleles that are rare in each simulation.\}
\item\{\link{alleleFreq}\} \{--- Calculates the count of each allele in the
provided vector.\}
\item\{\link{calcFE}\} \{--- Calculates founder equivalents.\}
\item\{\link{calcFG}\} \{--- Calculates founder genome equivalents.\}
\item\{\link{calcFEFG}\} \{--- Returns founder equivalents \code{FE} and
\code{FG} as elements in a list.\}
\item\{\link{calcGU}\} \{--- Calculates genome uniqueness for each ID that is
part of the population.\}
\item\{\link{geneDrop}\} \{--- Performs a gene drop simulation based on the
pedigree information.\}
\item\{\link{chooseAlleles}\} \{--- Combines two vectors of alleles by
randomly selecting one allele or the other at each position.\}
\item\{\link{calcRetention}\} \{--- Calculates allelic retention.\}
\item\{\link{filterKinMatrix}\} \{--- Filters a kinship matrix to include
only the egos listed in 'ids'\}
\item\{\link{kinship}\} \{--- Generates a kinship matrix\}
\item\{\link{reportGV}\} \{--- Generates a genetic value report for a
provided pedigree.\}
}
Plotting Functions

\itemize{
\item\{\link{meanKinship}\} \{--- Calculates the mean kinship for each animal
in a kinship matrix\}
}
Breeding Group Formation Functions

\itemize{
\item\{\link{meanKinship}\} \{--- Calculates the mean kinship for each animal
in a kinship matrix\}
}

Useful links:
\itemize{
  \item \url{https://rmsharp.github.io/nprcgenekeepr/}
  \item \url{https://github.com/rmsharp/nprcgenekeepr}
  \item Report bugs at \url{https://github.com/rmsharp/nprcgenekeepr/issues}
}

}
\author{
\strong{Maintainer}: R. Mark Sharp \email{rmsharp@me.com} (\href{https://orcid.org/0000-0002-6170-6942}{ORCID}) [copyright holder, data contributor]

Authors:
\itemize{
  \item Michael Raboin
  \item Terry Therneau
  \item Amanda Vinson [data contributor]
  \item Matthew Schultz (\href{https://orcid.org/0000-0001-5103-4305}{ORCID})
}

Other contributors:
\itemize{
  \item Southwest National Primate Research Center NIH grant P51 RR13986 [funder]
  \item Oregon National Primate Research Center grant P51 OD011092 [funder]
}

}
\keyword{internal}
