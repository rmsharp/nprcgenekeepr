# Genetic Management Functions

Primary Data Structure — Pedigree

Contains studbook information for a number of individuals. ASSUME: All
IDs listed in the sire or dam columns must have a row entry in the id
column

Provides genetic tools for colony management and is a derivation of the
work in Amanda Vinson and Michael J Raboin (2015)
<https://pmc.ncbi.nlm.nih.gov/articles/PMC4671785/> "A Practical
Approach for Designing Breeding Groups to Maximize Genetic Diversity in
a Large Colony of Captive Rhesus Macaques ('Macaca' 'mulatto')". It
provides a 'Shiny' application with an exposed API. The application
supports five groups of functions: (1) Quality control of studbooks
contained in text files or 'Excel' workbooks and of pedigrees within
'LabKey' Electronic Health Records (EHR); (2) Creation of pedigrees from
a list of animals using the 'LabKey' EHR integration; (3) Creation and
display of an age by sex pyramid plot of the living animals within the
designated pedigree; (4) Generation of genetic value analysis reports;
and (5) Creation of potential breeding groups with and without
proscribed sex ratios and defined maximum kinships.

## See also

[`getIncludeColumns`](https://github.com/rmsharp/nprcgenekeepr/reference/getIncludeColumns.md)
to get set of columns that can be used in a pedigree file

A Pedigree is a data frame within the `R` environment with the following
possible columns:

- {id} {– character vector with unique identifier for an individual}

- {sire} {– character vector with unique identifier for an individual's
  father (`NA` if unknown).}

- {dam} {– character vector with unique identifier for an individual's
  mother (`NA` if unknown).}

- {sex} {– factor {levels: "M", "F", "U"} Sex specifier for an
  individual}

- {gen} {– integer vector with the generation number of the individual}

- {birth} {– Date or `NA` (optional) with the individual's birth date}

- {exit} {– Date or `NA` (optional) with the individual's exit date
  (death, or departure if applicable)}

- {ancestry} {– character vector or `NA` (optional) that indicates the
  geographic population to which the individual belongs.}

- {age} {– numeric or `NA` (optional) indicating the individual's
  current age or age at exit.}

- {population} {– logical (optional) Is the id part of the extant
  population?}

- {origin} {– character vector or `NA` (optional) that indicates the
  name of the facility that the individual was imported from if other
  than local.`NA` indicates the individual was not imported.}

Pedigree File Testing Functions

- {[qcStudbook](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)}
  {— Main pedigree curation function that performs basic quality control
  on pedigree information}

- {[fixColumnNames](https://github.com/rmsharp/nprcgenekeepr/reference/fixColumnNames.md)}
  {— Changes original column names and into standardized names.}

- {[checkRequiredCols](https://github.com/rmsharp/nprcgenekeepr/reference/checkRequiredCols.md)}
  {— Examines column names, cols, to see if all required column names
  are present.}

- {[correctParentSex](https://github.com/rmsharp/nprcgenekeepr/reference/correctParentSex.md)}
  {— Sets sex for animals listed as either a sire or dam.}

- {[getDateErrorsAndConvertDatesInPed](https://github.com/rmsharp/nprcgenekeepr/reference/getDateErrorsAndConvertDatesInPed.md)}
  {— Converts columns of dates in text form to `Date` object columns}

- {[checkParentAge](https://github.com/rmsharp/nprcgenekeepr/reference/checkParentAge.md)}
  {— Check parent ages to be at least `minParentAge`}

- {[removeDuplicates](https://github.com/rmsharp/nprcgenekeepr/reference/removeDuplicates.md)}
  {— Remove duplicate records from pedigree}

Gene Dropping Function

- {[geneDrop](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)}
  {— Performs a gene drop simulation based on the provided pedigree
  information}

Genetic Value Analysis Functions

Contains functions to calculate the kinship coefficient and genome
uniqueness for animals listed in a Pedigree table.

- {[meanKinship](https://github.com/rmsharp/nprcgenekeepr/reference/meanKinship.md)}
  {— Calculates the mean kinship for each animal in a kinship matrix}

- {[calcA](https://github.com/rmsharp/nprcgenekeepr/reference/calcA.md)}
  {— Calculates `a`, the number of an individual's alleles that are rare
  in each simulation.}

- {[alleleFreq](https://github.com/rmsharp/nprcgenekeepr/reference/alleleFreq.md)}
  {— Calculates the count of each allele in the provided vector.}

- {[calcFE](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md)}
  {— Calculates founder equivalents.}

- {[calcFG](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md)}
  {— Calculates founder genome equivalents.}

- {[calcFEFG](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md)}
  {— Returns founder equivalents `FE` and `FG` as elements in a list.}

- {[calcGU](https://github.com/rmsharp/nprcgenekeepr/reference/calcGU.md)}
  {— Calculates genome uniqueness for each ID that is part of the
  population.}

- {[geneDrop](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)}
  {— Performs a gene drop simulation based on the pedigree information.}

- {[chooseAlleles](https://github.com/rmsharp/nprcgenekeepr/reference/chooseAlleles.md)}
  {— Combines two vectors of alleles by randomly selecting one allele or
  the other at each position.}

- {[calcRetention](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md)}
  {— Calculates allelic retention.}

- {[filterKinMatrix](https://github.com/rmsharp/nprcgenekeepr/reference/filterKinMatrix.md)}
  {— Filters a kinship matrix to include only the egos listed in 'ids'}

- {[kinship](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)}
  {— Generates a kinship matrix}

- {[reportGV](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)}
  {— Generates a genetic value report for a provided pedigree.}

Plotting Functions

- {[meanKinship](https://github.com/rmsharp/nprcgenekeepr/reference/meanKinship.md)}
  {— Calculates the mean kinship for each animal in a kinship matrix}

Breeding Group Formation Functions

- {[meanKinship](https://github.com/rmsharp/nprcgenekeepr/reference/meanKinship.md)}
  {— Calculates the mean kinship for each animal in a kinship matrix}

Useful links:

- <https://rmsharp.github.io/nprcgenekeepr/>

- <https://github.com/rmsharp/nprcgenekeepr>

- Report bugs at <https://github.com/rmsharp/nprcgenekeepr/issues>

## Author

**Maintainer**: R. Mark Sharp <rmsharp@me.com>
([ORCID](https://orcid.org/0000-0002-6170-6942)) \[copyright holder,
data contributor\]

Authors:

- Michael Raboin

- Terry Therneau

- Amanda Vinson \[data contributor\]

- Matthew Schultz ([ORCID](https://orcid.org/0000-0001-5103-4305))

Other contributors:

- Southwest National Primate Research Center NIH grant P51 RR13986
  \[funder\]

- Oregon National Primate Research Center grant P51 OD011092 \[funder\]
