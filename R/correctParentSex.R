## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Correct the sex of animals listed as a sire or dam
#'
#' Part of Pedigree Curation
#'
#' @details Only true female-sires (\code{"F"}) and male-dams (\code{"M"}) are
#' corrected (to \code{"M"} and \code{"F"} respectively). Parents recorded as
#' hermaphrodite (\code{"H"}) or unknown (\code{"U"}) sex are left unchanged,
#' consistent with \code{reportErrors = TRUE} mode, which does not flag them.
#'
#' When \code{reportErrors = TRUE}, only records whose \code{recordStatus} is
#' exactly \code{"added"} are left out of the report. A missing (\code{NA}),
#' blank or unrecognized status is treated as an original animal, and a
#' \code{NULL} \code{recordStatus} means no added records are known, so every
#' animal is checked.
#'
#' @param id character vector with unique identifier for an individual
#' @param sire character vector with unique identifier for an
#' individual's father (\code{NA} if unknown).
#' @param dam character vector with unique identifier for an
#' individual's mother (\code{NA} if unknown).
#' @param sex factor or character vector of sex codes ("M", "F", "H", "U").
#' Sex specifier for an individual. A character input returns a character
#' vector.
#' @param reportErrors logical value if TRUE will scan the entire file and
#' make a list of all errors found. The errors will be returned in a
#' list of list where each sublist is a type of error found.
#' When \code{FALSE}, an ID listed as both a sire and a dam stops with an
#' error; when \code{TRUE} it is returned as \code{sireAndDam}.
#' @param recordStatus character vector with value of \code{"added"} or
#' \code{"original"}, which indicates whether an animal was added or an
#' original animal. Only \code{"added"} is special: an \code{NA}, blank or
#' unrecognized value is treated as an original animal, and \code{NULL} means
#' no added records are known. It is used only when
#' \code{reportErrors = TRUE}.
#' @return When \code{reportErrors = FALSE}, a factor (or character
#' vector) of corrected sex codes with levels \code{"M"}, \code{"F"},
#' \code{"H"}, and \code{"U"} for the ids provided. When
#' \code{reportErrors = TRUE}, a named list of error vectors with
#' elements \code{sireAndDam}, \code{femaleSires}, and \code{maleDams}
#' (each \code{NULL} when no such errors are found).
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' pedOne <- data.frame(
#'   id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
#'   sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
#'   dam = c(NA, "d0", "d4", NA, "d1", "d2", "d2", "d2"),
#'   sex = c("F", "F", "M", "F", "F", "F", "F", "M"),
#'   recordStatus = rep("original", 8),
#'   stringsAsFactors = FALSE
#' )
#' pedTwo <- data.frame(
#'   id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
#'   sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
#'   dam = c("d0", "d0", "d4", NA, "d1", "d2", "d2", "d2"),
#'   sex = c("M", "M", "M", "F", "F", "F", "F", "M"),
#'   recordStatus = rep("original", 8),
#'   stringsAsFactors = FALSE
#' )
#' pedOneCorrected <- pedOne
#' pedOneCorrected$sex <- correctParentSex(
#'   pedOne$id, pedOne$sire, pedOne$dam,
#'   pedOne$sex, pedOne$recordStatus
#' )
#' pedOne[pedOne$sex != pedOneCorrected$sex, ]
#' pedOneCorrected[pedOne$sex != pedOneCorrected$sex, ]
#'
#' pedTwoCorrected <- pedTwo
#' pedTwoCorrected$sex <- correctParentSex(
#'   pedTwo$id, pedTwo$sire, pedTwo$dam,
#'   pedTwo$sex, pedTwo$recordStatus
#' )
#' pedTwo[pedTwo$sex != pedTwoCorrected$sex, ]
#' pedTwoCorrected[pedTwo$sex != pedTwoCorrected$sex, ]
correctParentSex <- function(id, sire, dam, sex, recordStatus,
                             reportErrors = FALSE) {
  # Get all sires and dams
  sires <- unique(sire)
  sires <- sires[!is.na(sires)]
  dams <- unique(dam)
  dams <- dams[!is.na(dams)]
  # Sexes a parent may carry without being "corrected" (H and U are exempt)
  keepAsSire <- sexCodes[c("hermaphrodite", "unknown", "male")]
  keepAsDam <- sexCodes[c("hermaphrodite", "unknown", "female")]

  # Check if any ids are listed in both the sire and dam columns (error)
  sireAndDam <- intersect(sires, dams)
  if ((length(sireAndDam) > 0L) && !reportErrors) {
    stop(sireAndDam, " : Subject(s) listed as both sire and dam")
  }
  if (!reportErrors) {
    # Update gender for sires and dams. Mirror the report branch below
    # (which exempts H/U via `!sex %in% c("H", "U", "M")`): only correct true
    # female-sires (F -> M) and male-dams (M -> F). Hermaphrodite ("H") and
    # unknown-sex ("U") parents keep their recorded sex (NEW-37).
    sex[((id %in% sires) & !(sex %in% keepAsSire))] <- sexCodes[["male"]]
    sex[((id %in% dams) & !(sex %in% keepAsDam))] <- sexCodes[["female"]]
    return(sex)
  }
  # Only "added" records are set aside: an NA, blank or unrecognised status is
  # a real animal, and an absent (NULL) status means no added rows are known.
  isAdded <- isAddedRecord(recordStatus, length(id))
  femaleSires <- id[(id %in% sires) & (!sex %in% keepAsSire) & !isAdded]
  maleDams <- id[(id %in% dams) & (!sex %in% keepAsDam) & !isAdded]
  if (length(femaleSires) == 0L) {
    femaleSires <- NULL
  }
  if (length(maleDams) == 0L) {
    maleDams <- NULL
  }
  if (length(sireAndDam) == 0L) {
    sireAndDam <- NULL
  }
  list(
    sireAndDam = sireAndDam, femaleSires = femaleSires,
    maleDams = maleDams
  )
}
