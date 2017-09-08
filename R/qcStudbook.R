#' Quality Control for the Studbook or pedigree
#'
#' Main pedigree curation function that performs basic quality control on
#' pedigree information
#'
#' @param sb A dataframe containing a table of pedigree and demographic
#' information.
#'
#' The function recognizes the following columns (optional columns
#' will be used if present, but are not required):
#'
#' \itemize{
#' \item{id} {--- Character vector with Unique identifier for all individuals}
#' \item{sire} {--- Character vector with unique identifier for the father of the
#' current id}
#' \item{dam} {--- Character vector with unique identifier for the mother of the
#' current id}
#' \item{sex} {--- Factor {levels: "M", "F", "U"} Sex specifier for an
#' individual}
#' \item{birth} {--- Date or \code{NA} (optional) with the individual's birth
#' date}
#' \item{departure} {--- Date or \code{NA} (optional) an individual was sold
#' or shipped from the colony}
#' \item{death} {--- date or \code{NA} (optional)
#'  Date of death, if applicable}
#' \item{status} {--- Factor {levels: ALIVE, DEAD, SHIPPED} (optional)
#'  Status of an individual}
#' \item{origin} {--- Character or \code{NA} (optional)
#'  Facility an individual originated from, if other than ONPRC}
#' \item{ancestry} {--- Character or \code{NA} (optional)
#'  Geographic population to which the individual belongs}
#' \item{spf} {--- Character or \code{NA} (optional)
#'  Specific pathogen-free status of an individual}
#' \item{vasx.ovx} {--- Character or \code{NA} (optional)
#'  Indicator of the vasectomy/ovariectomy status of an animal; \code{NA} if
#'  animal is intact, assume all other values indicate surgical alteration}
#' \item{condition} {--- Character or \code{NA} (optional)
#'  Indicator of the restricted status of an animal. "Nonrestricted" animals
#'  are generally assumed to be naive.}
#' }
#' @param minParentAge numeric values to set the minimum age in years for
#' an animal to have an offspring. Defaults to 2 years. The check is not
#' performed for animals with missing birth dates.
#'
#' @return A datatable with standardized and quality controlled pedigree
#' information.
#'
#' The following changes are made to the headers.
#'
#' \itemize{
#' \item {Column headers are converted to all lower case}
#' \item {Periods (".") within column headers are collapsed to no space ""}
#' \item {\code{egoid} is converted to \code{id}}
#' \item {\code{sireid} is convert to \code{sire}}
#' \item {\code{damid} is converted to \code{dam}}}
#'
#' If the dataframe (\code{sb} does not contain the five required columns
#' (\code{id}, \code{sire}, \code{dam}, \code{sex}), and
#' \code{birth} the function throws an error by calling \code{stop()}.
#'
#' If the \code{id} field has the string \emph{UNKNOWN} (any case) or both
#' the fields \code{sire} or \code{dam} have \code{NA} or \emph{UNKNOWN}
#' (any case), the record is removed.
#' If either of the fields \code{sire} or \code{dam} have the
#' string \emph{UNKNOWN} (any case), they are replaced with a unique identifier
#' with the form \code{Unnnn}, where \code{nnnn} represents one of a series
#' of sequential integers representing the number of missing sires and
#' dams right justified in a pattern of \code{0000}. See \code{addUIds}
#' function.
#'
#' The function \code{addParents} is used to add records for parents missing
#' their own record in the pedigree.
#'
#' The function \code{convertSexCodes} is used with \code{ignore.herm == TRUE}
#' to convert sex codes according to the following factors of standardized
#' codes:
#'
#' \itemize{
#' \item{F} {-- replacing "FEMALE" or "2"}
#' \item{M} {-- replacing "MALE" or "1"}
#' \item{H} {-- replacing "HERMAPHRODITE" or "4", if igore.herm == FALSE}
#' \item{U} {-- replacing "HERMAPHRODITE" or "4", if igore.herm == TRUE}
#' \item{U} {-- replacing "UNKNOWN" or "3"}}
#'
#' The function \code{checkParentSex} is used to ensure no parent is both
#' a sire and a dam. If this error is detected, the function throws an error
#' and halts the program.
#'
#' The function \code{convertStatusCodes} converts status indicators to the
#' following factors of standardized codes. Case of the original status value
#' is ignored.
#'
#' \itemize{
#' \item{"ALIVE"} {--- replacing "alive", "A" and "1"}
#' \item {"DECEASED"} {--- replacing "deceased", "DEAD", "D", "2"}
#' \item {"SHIPPED"} {--- replacing "shipped", "sold", "sale", "s", "3"}
#' \item{"UNKNOWN"} {--- replacing is.na(status)}
#' \item {"UNKNOWN"} {--- replacing "unknown", "U", "4"}}
#'
#' The function \code{convertAncestry} coverts ancestry indicators using
#' regular experessions such that the following conversions are made from
#' character strings that match selected substrings to the following factors.
#'
#' \itemize{
#' \item{"INDIAN"} {--- replacing "ind" and not "chin"}
#' \item{"CHINESE"} {--- replacing "chin" and not "ind"}
#' \item{"HYBRID"} {--- replacing "hyb" or "chin" and "ind"}
#' \item{"JAPANESE"} {--- replacing "jap"}
#' \item{"UNKNOWN"} {--- replacing \code{NA}}
#' \item{"OTHER"} {--- replacing not matching any of the above}}
#'
#' The function \code{convertDates} converts character representations of
#' dates in the columns \code{birth}, \code{death}, \code{departure}, and
#' \code{exit} to dates using the \code{as.Date} function.
#'
#' The function \code{setExit} uses huristics and the columns \code{death}
#' and \code{departure} to set \code{exit} if it is not already defined.
#'
#' The function \code{calcAge} uses the \code{birth} and the \code{exit}
#' columns to define the \code{age} columnn. The numerical values is rounded
#' to the nearest 0.1 of a year. If \code{exit} is not defined, the
#' current system date (\code{Sys.Date()}) is used.
#'
#' The function \code{findGeneration} is used to define the generation number
#' for each animal in the pedigree.
#'
#' The function \code{removeDuplicates} checks for any duplicated records and
#' removeds the duplicates. I also throws an error and stops the program if an
#' ID appears in more
#' than one record where one or more of the other columns have a difference.
#'
#' Columns that cannot be used subsequently are removed and the rows are
#' ordered by generation number and then ID.
#'
#' Finally the columns \code{id} \code{sire}, and \code{dam} are coerce to
#' character.
#'
#' @importFrom utils write.csv
#' @export
qcStudbook <- function(sb, minParentAge = 2) {
  headers <- tolower(names(sb))
  headers <- gsub(" ", "", headers)
  headers <- gsub("_", "", headers)
  headers <- gsub("egoid", "id", headers)
  headers <- gsub("sireid", "sire", headers)
  headers <- gsub("damid", "dam", headers)
  headers <- gsub("birthdate", "birth", headers)

  # Checking for the 4 required fields (id, sire, dam, sex)
  if (is.na(match("id", headers))) {
    stop("No valid headers found")
  }

  names(sb) <- headers
  ## An age column was required, however, code below creates it if it does
  ## not exists. Thus, it is not required as a prerequisit.
  required_cols <- c("id", "sire", "dam", "sex", "birth")
  required <- required_cols %in% headers

  if (!all(required)) {
    stop(paste0("Required field missing (", paste0(required_cols[!required],
                                                   collapse = ", "), ")."))
  }

  # Removing erroneous IDs (someone started entering "unknown" for unknown
  # parents instead of leaving the field blank in PRIMe)
  sb <- sb[toupper(sb$id) != "UNKNOWN", ]
  sb$sire[toupper(sb$sire) == "UNKNOWN"] <- NA
  sb$dam[toupper(sb$dam) == "UNKNOWN"] <- NA

  # Adding UIDs
  sb <- addUIds(sb)

  # Find any parents that don't have their own line entry
  sb <- addParents(sb)

  # Add and standardize needed fields
  sb$sex <- convertSexCodes(sb$sex)
  sb$sex <- checkParentSex(sb$id, sb$sire, sb$dam, sb$sex)

  if ("status" %in% headers) {
    sb$status <- convertStatusCodes(sb$status)
  }
  if ("ancestry" %in% headers) {
    sb$ancestry <- convertAncestry(sb$ancestry)
  }

  # converting date column entries from strings to date
  sb <- convertDates(sb, time.origin = as.Date("1970-01-01"))
  sb <- setExit(sb, time.origin = as.Date("1970-01-01"))

  # ensure parents are older than offspring
  suspiciousParents <- checkParentAge(sb, minParentAge)
  if (nrow(suspiciousParents) > 0) {
    fileName <- paste0(getSiteInfo()$homeDir, "lowParentAge.csv")
    write.csv(suspiciousParents,
              file = fileName, row.names = FALSE)

    stop(paste0("Parents with low age at birth of offspring are listed in ",
                fileName, ".\n"))
  }
  # setting age
  # uses current date as the end point if no exit date is available
  if (("birth" %in% headers) && !("age" %in% headers)) {
    sb["age"] <- calcAge(sb$birth, sb$exit)
  }

  # Adding generation numbers
  sb["gen"] <- findGeneration(sb$id, sb$sire, sb$dam)

  # Cleaning-up the data.frame
  # Filtering unnecessary columns and ordering the data
  sb <- removeDuplicates(sb)
  cols <- intersect(getPossibleCols(), colnames(sb))
  sb <- sb[, cols]
  sb <- sb[with(sb, order(gen, id)), ]
  rownames(sb) <- seq(length.out = nrow(sb))

  # Ensuring the IDs are stored as characters
  sb$id <- as.character(sb$id)
  sb$sire <- as.character(sb$sire)
  sb$dam <- as.character(sb$dam)

  return(sb)
}