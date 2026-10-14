## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Rebuilds inst/extdata/examples/deidentified_jmac_ped.csv, the shipped
#' Japanese macaque example pedigree, from the colony's 2018-07-11 studbook
#' (S981; BACKLOG.md:179, the owner's S980 request "reconstruct in the next
#' session").
#'
#' The studbook is real colony data: seven tab-separated columns (`Ego ID`,
#' `Sire ID`, `Dam ID`, `Departure`, `Sex`, `Birth`, `Death`), 2,590 animals,
#' 819 of them with a sire. It is kept out of git and out of the package build
#' (`.Rbuildignore`, `.git/info/exclude`), so pass its path as an argument.
#'
#' The recipe:
#' * every animal gets `species = "JAPANESE MACAQUE"`, so the pedigree check
#'   applies the species minimum parent ages (4 years for a mother, 5 for a
#'   father);
#' * `sex` is "M" for Male, "F" for Female and "U" for everything else
#'   (Unknown, Hermaphrodite, blank), as the pedigree check reads them;
#' * `status` is derived: "Dead" with a death date, "Shipped" with only a
#'   departure date, else "Alive";
#' * the studbook has no origin, parent-type or from-center information, so
#'   those columns are left out rather than invented;
#' * a parent named but given no row of its own (two mothers) keeps its alias
#'   and still has no row, as in the studbook;
#' * `obfuscatePed()` with its defaults aliases every id (6 characters) and
#'   moves all of an animal's dates by one shared random offset of up to 30
#'   days, so no animal's dates fall out of order. `set.seed()` makes the file
#'   reproducible.
#'
#' Usage, from the package root:
#'   Rscript data-raw/buildJmacExample.R <studbook.txt> [<out.csv>]
#' The default output is the shipped example.

buildJmacExample <- function(studbookPath, seed = 20180711L, size = 6L,
                             maxDelta = 30L) {
  raw <- read.table(studbookPath, header = TRUE, sep = "\t", quote = "",
                    comment.char = "", na.strings = c("", "NA"),
                    colClasses = "character", check.names = FALSE,
                    stringsAsFactors = FALSE)
  sexCodes <- c(Male = "M", Female = "F")
  death <- as.Date(raw$Death)
  departure <- as.Date(raw$Departure)
  status <- rep("Alive", nrow(raw))
  status[!is.na(departure)] <- "Shipped"
  status[!is.na(death)] <- "Dead"
  ped <- data.frame(
    id = raw[["Ego ID"]],
    species = "JAPANESE MACAQUE",
    sex = unname(ifelse(raw$Sex %in% names(sexCodes), sexCodes[raw$Sex], "U")),
    status = status,
    birth = as.Date(raw$Birth),
    death = death,
    dam = raw[["Dam ID"]],
    sire = raw[["Sire ID"]],
    departure = departure,
    stringsAsFactors = FALSE
  )
  ## A parent without a row of its own gets a temporary one so that its id is
  ## aliased; the row is dropped again after the de-identification.
  noRow <- setdiff(c(ped$dam, ped$sire), c(ped$id, NA))
  if (length(noRow) > 0L) {
    extra <- ped[rep(NA_integer_, length(noRow)), ]
    extra$id <- noRow
    ped <- rbind(ped, extra)
  }
  set.seed(seed)
  obfuscated <- obfuscatePed(ped, size = size, maxDelta = maxDelta)
  out <- obfuscated[seq_len(nrow(raw)), ]
  ## A shifted date is fractional; keep the whole day it falls in.
  for (col in c("birth", "death", "departure")) {
    out[[col]] <- as.Date(floor(as.numeric(out[[col]])), origin = "1970-01-01")
  }
  rownames(out) <- NULL
  out
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) < 1L) {
    stop("Usage: Rscript data-raw/buildJmacExample.R <studbook.txt> ",
         "[<out.csv>]")
  }
  suppressMessages(pkgload::load_all(".", quiet = TRUE))
  outPath <- if (length(args) >= 2L) {
    args[[2L]]
  } else {
    file.path("inst", "extdata", "examples", "deidentified_jmac_ped.csv")
  }
  write.csv(buildJmacExample(args[[1L]]), outPath, row.names = FALSE, na = "")
}
