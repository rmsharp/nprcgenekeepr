## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Generate the one-file example:
#' inst/extdata/examples/obfuscated_rhesus_mhc_ped_with_genotypes.csv
#'
#' The shipped rhesus MHC pedigree (obfuscated_rhesus_mhc_ped.csv, 375
#' animals) with the genotype labels of its 31 genotyped animals
#' (obfuscated_rhesus_mhc_breeder_genotypes.csv) in the same file, as the two
#' columns first_name and second_name, which is what "Pedigree(s) and
#' genotypes in one file" on the Input tab reads. S971 (BACKLOG.md:139): the
#' colony manager guide's one-file picture and the Input module's tests use
#' it. The labels are real haplotype names of the obfuscated example, so no
#' new data is made up. The 344 animals with no genotype get NA in both
#' columns.
#'
#' A new sibling file, not an in-place edit to the base fixture: the base
#' obfuscated_rhesus_mhc_ped.csv is read by many test files that pin its
#' column and row counts. Every line of the base file is kept byte for byte
#' and the two columns are added at its end, so re-running reproduces the
#' identical file.
#'
#' Run from the package root:
#'   Rscript data-raw/obfuscated_rhesus_mhc_ped_with_genotypes.R

examples <- file.path("inst", "extdata", "examples")
pedLines <- readLines(file.path(examples, "obfuscated_rhesus_mhc_ped.csv"))
genotypes <- read.csv(
  file.path(examples, "obfuscated_rhesus_mhc_breeder_genotypes.csv"),
  stringsAsFactors = FALSE
)
ids <- read.csv(text = pedLines, stringsAsFactors = FALSE)$id
at <- match(ids, genotypes$id)
labels <- ifelse(
  is.na(at),
  "NA,NA",
  sprintf("\"%s\",\"%s\"", genotypes$first_name[at], genotypes$second_name[at])
)
writeLines(
  c(paste0(pedLines[1L], ",\"first_name\",\"second_name\""),
    paste0(pedLines[-1L], ",", labels)),
  file.path(examples, "obfuscated_rhesus_mhc_ped_with_genotypes.csv")
)
