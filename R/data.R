## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Example nprcgenekeepr configuration file (loadable)
#'
#' A loadable version of the example
#' configuration file \code{example_nprcgenekeepr_config}.
#' It contains a working version of a \strong{nprcgenekeepr} configuration
#' file created at the SNPRC.
#' Users of LabKey's EHR can adapt it to their systems and put it
#' in their home directory. Instructions are embedded as comments
#' within the file.
#' @examples
#' library(nprcgenekeepr)
#' data("exampleNprcgenekeeprConfig")
#' head(exampleNprcgenekeeprConfig)
"exampleNprcgenekeeprConfig"
#' Example pedigree object (from ExamplePedigree.csv)
#'
#' A pedigree object created by \code{qcStudbook}.
#' Represents pedigree from \emph{ExamplePedigree.csv}.
#' \describe{
#' \item{id}{-- character column of animal IDs}
#' \item{sire}{-- the male parent of the animal indicated by the \code{id}
#' column. Unknown sires are indicated with \code{NA}}
#' \item{dam}{-- the female parent of the animal indicated by the \code{id}
#' column. Unknown dams are indicated with \code{NA}}
#' \item{sex}{-- factor with levels: "F", "M", "H", "U". Sex specifier for an
#' individual.}
#' \item{gen}{-- generation number (integers beginning with 0 for the founder
#' generation) of the animal indicated by the \code{id} column.}
#' \item{birth}{-- Date vector of birth dates}
#' \item{exit}{-- Date vector of exit dates}
#' \item{age}{-- numerical vector of age in years}
#' \item{ancestry}{-- factor with levels: INDIAN, CHINESE, HYBRID, JAPANESE,
#' OTHER, UNKNOWN indicating the geographic population of origin.}
#' \item{origin}{-- character vector or \code{NA} (optional) that indicates
#' the name of the facility that the individual was imported from if other than
#' local.}
#' \item{status}{-- character vector or NA. Flag indicating an individual's
#' status as alive, dead, sold, etc. Transformed to
#'  factor \{levels: ALIVE, DECEASED, SHIPPED, UNKNOWN\}. Vector of
#' standardized status codes with the possible values
#' ALIVE, DECEASED, SHIPPED, or UNKNOWN}
#' \item{recordStatus}{-- character vector with value of \code{"added"} or
#'  \code{"original"}.}
#' }
#' @examples
#' library(nprcgenekeepr)
#' data("examplePedigree")
#' exampleTree <- createPedTree(examplePedigree)
#' exampleLoops <- findLoops(exampleTree)
"examplePedigree"
#' Genetic-value report list prior to ranking
#'
#' A list object created from the list object \emph{rpt} prepared
#' by \code{reportGV}. It is created inside \code{orderReport}. This version
#' is at the state just prior to calling \code{rankSubjects} inside
#' \code{orderReport}.
#' @examples
#' library(nprcgenekeepr)
#' data("finalRpt")
#' finalRpt <- rankSubjects(finalRpt)
"finalRpt"
#' Focal animal IDs from examplePedigree
#'
#' A dataframe with one column (_id_) containing the animal
#' Ids from the __examplePedigree__ pedigree.
#' They can be used to illustrate the identification of a population of
#' interest as is shown in the example below.
#' @examples
#' library(nprcgenekeepr)
#' data("focalAnimals")
#' data("examplePedigree")
#' any(names(examplePedigree) == "population")
#' nrow(examplePedigree)
#' examplePedigree <- setPopulation(
#'   ped = examplePedigree,
#'   ids = focalAnimals$id
#' )
#' any(names(examplePedigree) == "population")
#' nrow(examplePedigree)
#' nrow(examplePedigree[examplePedigree$population, ])
"focalAnimals"
#' Small hypothetical pedigree (Lacy 1989)
#'
#' @source lacy1989Ped is a dataframe containing the small hypothetical
#' pedigree of three founders and four descendants used
#' by Robert C. Lacy in "Analysis of Founder Representation in Pedigrees:
#' Founder Equivalents and Founder Genome Equivalents" Zoo Biology 8:111-123
#' (1989).
#'
#' The founders (\code{A}, \code{B}, \code{E}) have unknown parentages and are
#' assumed to have independent ancestries.
#' \describe{
#' \item{id}{character column of animal IDs}
#' \item{sire}{the male parent of the animal indicated by the \code{id} column.
#' Unknown sires are indicated with \code{NA}}
#' \item{dam}{the female parent of the animal indicated by the \code{id}
#' column. Unknown dams are indicated with \code{NA}}
#' \item{gen}{generation number (integers beginning with 0 for the founder
#' generation) of the animal indicated by the \code{id} column.}
#' \item{population}{logical vector with all values set TRUE}
#' }
"lacy1989Ped"
#' Gene-drop alleles for lacy1989Ped (5000 iterations)
#'
#' A dataframe produced by \code{geneDrop} on
#' \code{lacy1989Ped} with 5000 iterations.
#' @source lacy1989Ped is a dataframe containing the small example pedigree used
#' by Robert C. Lacy in "Analysis of Founder Representation in Pedigrees:
#' Founder Equivalents and Founder Genome Equivalents" Zoo Biology 8:111-123
#' (1989).
#'
#' \describe{
#' There are 5000 columns, one for each iteration in \code{geneDrop}
#' containing alleles randomly selected at each
#' generation of the pedigree using Mendelian rules.
#'
#' Column 5001 is the \code{id} column with two rows for each member of the
#' pedigree (2 * 7).
#'
#' Column 5002 is the \code{parent} column with values of \code{sire} and
#' \code{dam} alternating.
#' }
"lacy1989PedAlleles"
#' Gene-drop alleles example (baboon pedigree)
#'
#' A dataframe created by the \code{geneDrop} function.
#' @format A dataframe with 554 rows and 6 variables
#' \describe{
#' \item{V1}{alleles assigned to the parents of the animals identified in
#' the \code{id} column during iteration 1 of gene dropping performed by
#' \code{geneDrop}.}
#' \item{V2}{alleles assigned to the parents of the animals identified in
#' the \code{id} column during iteration 2 of gene dropping performed by
#' \code{geneDrop}.}
#' \item{V3}{alleles assigned to the parents of the animals identified in
#' the \code{id} column during iteration 3 of gene dropping performed by
#' \code{geneDrop}.}
#' \item{V4}{alleles assigned to the parents of the animals identified in
#' the \code{id} column during iteration 4 of gene dropping performed by
#' \code{geneDrop}.}
#' \item{id}{character vector of animal IDs provided to the gene dropping
#' function \code{geneDrop}.}
#' \item{parent}{the parent type ("sire" or "dam") of the parent who supplied
#' the alleles as assigned during each of the 4 gene dropping iterations
#' performed by \code{geneDrop}.}
#' }
#' @source example baboon pedigree file provided by Deborah Newman,
#' Southwest National Primate Center.
"ped1Alleles"
#' Example studbook with a duplicated record
#'
#' A data frame with 9 rows and 5 columns (ego_id, sire.id,
#' dam_id, sex, birth_date) representing a full pedigree with a duplicated
#' record.
#'
#' It is one of six pedigrees (\code{pedDuplicateIds},
#' \code{pedFemaleSireMaleDam}, \code{pedGood},
#' \code{pedInvalidDates}, \code{pedMissingBirth},
#' \code{pedSameMaleIsSireAndDam}) used to
#' demonstrate error detection by the qcStudbook function.
"pedDuplicateIds"
#' Example studbook with sex-mismatched parents
#'
#' A data frame with 8 rows and 5 columns (ego_id, sire.id,
#' dam_id, sex, birth_date) representing a full pedigree with the errors of
#' having a sire labeled as female and a dam labeled as male.
#'
#' It is one of six pedigrees (\code{pedDuplicateIds},
#' \code{pedFemaleSireMaleDam}, \code{pedGood},
#' \code{pedInvalidDates}, \code{pedMissingBirth},
#' \code{pedSameMaleIsSireAndDam}) used to
#' demonstrate error detection by the qcStudbook function.
"pedFemaleSireMaleDam"
#' Valid example studbook (no QC errors)
#'
#' A data frame with 8 rows and 5 columns (ego_id, sire.id, dam_id,
#' sex, birth_date) representing a full pedigree with no errors.
#'
#' It is one of six pedigrees (\code{pedDuplicateIds},
#' \code{pedFemaleSireMaleDam}, \code{pedGood},
#' \code{pedInvalidDates}, \code{pedMissingBirth},
#' \code{pedSameMaleIsSireAndDam}) used to
#' demonstrate error detection by the qcStudbook function.
"pedGood"
#' Example studbook with invalid birth dates
#'
#' A data frame with 8 rows and 5 columns (id, sire, dam,
#' sex, birth) representing a full pedigree with values in the
#' \code{birth} column that are not valid dates.
#'
#' It is one of six pedigrees (\code{pedDuplicateIds},
#' \code{pedFemaleSireMaleDam}, \code{pedGood},
#' \code{pedInvalidDates}, \code{pedMissingBirth},
#' \code{pedSameMaleIsSireAndDam}) used to
#' demonstrate error detection by the qcStudbook function.
"pedInvalidDates"
#' Example studbook missing the birth date column
#'
#' A data frame with 8 rows and 4 columns (ego_id, sire.id,
#' dam_id, sex) representing a full pedigree that is missing the birth_date
#' column.
#'
#' It is one of six pedigrees (\code{pedDuplicateIds},
#' \code{pedFemaleSireMaleDam}, \code{pedGood},
#' \code{pedInvalidDates}, \code{pedMissingBirth},
#' \code{pedSameMaleIsSireAndDam}) used to
#' demonstrate error detection by the qcStudbook function.
"pedMissingBirth"
#' Raw pedigree-file fragment for testing (5 columns)
#'
#' A loadable version of a pedigree file fragment used for testing
#' and demonstration.
#' @examples
#' library(nprcgenekeepr)
#' data("pedOne")
#' head(pedOne)
"pedOne"
#' Example studbook with a male as both sire and dam
#'
#' A data frame with 8 rows and 5 columns (ego_id,
#' sire.id, dam_id, sex, birth_date) representing a full pedigree in which the
#' same male animal is listed as both a sire and a dam.
#'
#' It is one of six pedigrees (\code{pedDuplicateIds},
#' \code{pedFemaleSireMaleDam}, \code{pedGood},
#' \code{pedInvalidDates}, \code{pedMissingBirth},
#' \code{pedSameMaleIsSireAndDam}) used to
#' demonstrate error detection by the qcStudbook function.
"pedSameMaleIsSireAndDam"
#' Raw pedigree-file fragment for testing (7 columns)
#'
#' A loadable version of a pedigree file fragment used for testing
#' and demonstration.
#' @examples
#' library(nprcgenekeepr)
#' data("pedSix")
#' head(pedSix)
"pedSix"
#' Pedigree with simulated genotypes (from qcPed)
#'
#' A dataframe produced from qcPed by adding made up
#' genotypes.
#' \describe{
#' A dataframe containing 280 records with 12 columns: \code{id}, \code{sire},
#'  \code{dam}, \code{sex}, \code{gen}, \code{birth}, \code{exit}, \code{age},
#'  \code{first}, \code{second}, \code{first_name}, and \code{second_name}.
#' }
"pedWithGenotype"
#' Genetic-value report for pedWithGenotype
#'
#' A list containing the output of \code{reportGV}.
#' @source pedWithGenotypeReport was made with pedWithGenotype as input into
#' reportGV with 10,000 iterations.
#'
#' pedWithGenotypeReport is a simple example report for use in
#' examples and unit tests.
#' It was created using the following commands.
#'   \itemize{
#'     \item set_seed(10)
#'     \item pedWithGenotypeReport <- reportGV(nprcgenekeepr::pedWithGenotype,
#'           guIter = 10000)
#'     \item save(pedWithGenotypeReport,
#'                file = "data/pedWithGenotypeReport.RData")
#'   }
#'
#' @examples
#' pedWithGenotypeReport <- nprcgenekeepr::pedWithGenotypeReport
"pedWithGenotypeReport"
#' Potential breeder IDs (29 baboons)
#'
#' A character vector of 29 baboon IDs that are potential breeders.
#' @source qcBreeders is a character vector of 3 males and 26 females from
#' the \code{qcPed} data set.
#'
#' \describe{
#' These 29 animal IDs are used for examples and unit tests.
#' They were initially selected for having low kinship coefficients.
#' }
"qcBreeders"
#' Example quality-controlled baboon pedigree
#'
#' A data frame with 280 rows and 8 columns.
#' \describe{
#' \item{id}{character column of animal IDs}
#' \item{sire}{the male parent of the animal indicated by the \code{id} column.}
#' \item{dam}{the female parent of the animal indicated by the \code{id}
#' column.}
#' \item{sex}{sex of the animal indicated by the \code{id} column.}
#' \item{gen}{generation number (integers beginning with 0 for the founder
#' generation) of the animal indicated by the \code{id} column.}
#' \item{birth}{birth date in \code{Date} format of the animal indicated by the
#'  \code{id} column.}
#' \item{exit}{exit date in \code{Date} format of the animal indicated by the
#'  \code{id} column.}
#' \item{age}{age in year (numeric) of the animal indicated by the \code{id}
#' column.}
#' }
"qcPed"
#' Genetic-value report for qcPed
#'
#' qcPedGvReport is a genetic value report for illustrative purposes only.
#' It is used in examples and unit tests with the nprcgenekeepr package.
#' It was created using the following commands.
#'   \itemize{
#'     \item set_seed(10)
#'     \item qcPedGvReport <- reportGV(nprcgenekeepr::qcPed, guIter = 10000)
#'     \item save(qcPedGvReport, file = "data/qcPedGvReport.RData")
#'   }
#'
#' @examples
#' qcPedGvReport <- nprcgenekeepr::qcPedGvReport
"qcPedGvReport"
#' Hypothetical 17-animal pedigree
#'
#' A hypothetical pedigree. It has the following structure:
#' structure(list(id = c("A", "B", "C", "D", "E", "F", "G", "H",
#' "I", "J", "K", "L", "M", "N", "O", "P", "Q"), sire = c("Q", NA,
#' "A", "A", NA, "D", "D", "A", "A", NA, NA, "C", "A", NA, NA, "M", NA),
#' dam = c(NA, NA, "B", "B", NA, "E", "E", "B", "J", NA, NA,
#' "K", "N", NA, NA, "O", NA), sex = c("M", "F", "M", "M", "F",
#'  "F", "F", "M", "F", "F", "F", "F", "M", "F", "F", "F", "M"),
#'   gen = c(1, 1, 2, 2, 1, 3, 3, 2, 2, 1, 1, 2, 1, 1, 2, 3, 0),
#'   population = c(TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE,
#'   TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE)),
#'   .Names = c("id", "sire", "dam", "sex", "gen", "population"),
#'   row.names = c(NA, -17L), class = "data.frame")
"smallPed"
#' Pedigree tree built from smallPed
#'
#' A pedigree tree made from \code{smallPed}.
#' Access it using the following commands.
#' @examples
#' library(nprcgenekeepr)
#' data("smallPedTree")
"smallPedTree"
#' Rhesus genotypes (two haplotypes per animal)
#'
#' A dataframe with two haplotypes per animal.
#'
#' There are 31 rows and 3 columns.
#'
#' Represents 31 animals that are also in the obfuscated \code{rhesusPedigree}
#' pedigree from \emph{obfuscated_rhesus_mhc_breeder_genotypes.csv}.
#' \describe{
#' \item{id}{-- character column of animal IDs}
#' \item{first_name}{-- a generic name for the first haplotype}
#' \item{second_name}{-- a generic name for the second haplotype}
#' }
#' @examples
#' library(nprcgenekeepr)
#' data("rhesusGenotypes")
"rhesusGenotypes"
#' Obfuscated rhesus pedigree object
#'
#' A pedigree object.
#' Represents an obfuscated pedigree from
#' \emph{obfuscated_rhesus_mhc_ped.csv} where the
#' IDs and dates have been modified to de-identify the data.
#' \describe{
#' \item{id}{-- character column of animal IDs}
#' \item{sire}{-- the male parent of the animal indicated by the \code{id}
#' column. Unknown sires are indicated with \code{NA}}
#' \item{dam}{-- the female parent of the animal indicated by the \code{id}
#' column. Unknown dams are indicated with \code{NA}}
#' \item{sex}{-- factor with levels: "F", "M". Sex specifier for an
#' individual.}
#' \item{gen}{-- generation number (integers beginning with 0 for the founder
#' generation) of the animal indicated by the \code{id} column.}
#' \item{birth}{-- \code{Date} vector of birth dates}
#' \item{exit}{-- \code{Date} vector, all \code{NA} (no exit dates are recorded
#' in this obfuscated pedigree)}
#' \item{age}{-- numerical vector of age in years}
#' }
#' @examples
#' library(nprcgenekeepr)
#' data("rhesusPedigree")
"rhesusPedigree"
#' Per-species reproductive parameters
#'
#' A lookup table mapping a species name to reproductive parameters used across
#' the package. It keys the gestation window in
#' \code{\link{getPotentialParents}} through \code{\link{getSpeciesGestation}}
#' and the minimum
#' breeding ages in the Genetic Value Analysis unknown-parent mean-kinship
#' correction through \code{\link{getSpeciesMinBreedingAge}}.
#' Species names are matched case- and whitespace-insensitively; any species not
#' present falls back to 210 days for gestation and 2 years for the breeding
#' ages. Rhesus gestation is 210 days (the historical conservative bound;
#' typical rhesus gestation is about 165 days, per Vinson & Raboin 2015), and
#' rhesus minimum breeding ages are male = 4, female = 2.5. The table is
#' populated for the common colony NHP species, with gestation
#' values as conservative upper bounds; making the values user-configurable is
#' a separate planned enhancement. Extend or adjust it by editing
#' \code{data-raw/speciesGestation.R} and re-running that script.
#' \describe{
#' \item{species}{-- character species name (e.g. "RHESUS").}
#' \item{gestation}{-- integer maximum gestation period in days (a conservative
#' upper bound).}
#' \item{minMaleBreedingAge}{-- numeric minimum age in years at which a male of
#' the species can sire offspring.}
#' \item{minFemaleBreedingAge}{-- numeric minimum age in years at which a female
#' of the species can bear offspring.}
#' }
#' @examples
#' library(nprcgenekeepr)
#' data("speciesGestation")
#' speciesGestation
"speciesGestation"
