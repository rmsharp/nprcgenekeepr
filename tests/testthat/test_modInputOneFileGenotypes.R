## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:139 (decided S971; see test_readOneFileGenotypes.R for the
## rules). The same rules through the real Input module, in "Pedigree(s) and
## genotypes in one file" mode. Measured S971 before any change, with an
## eight-animal pedigree (the real module, QC step included):
##
##   file's genotype columns               genotypes used   errors / warnings
##   first, second (whole numbers)         yes              0 / 0
##   allele_1, allele_2 (whole numbers)    NO               0 / 0
##   allele_1, allele_2 (text A, B, C)     NO               0 / 0
##   first, second (text)                  NO               0 / 0
##   first_name, second_name (text)        NO               0 / 0
##   Allele 1, Allele 2 (whole numbers)    NO               0 / 1 (a "column
##                                                          name case changed" note)
##
## Blocks that only guard what must not change (pedigree-only mode, the
## separate-files mode, a first / second file's cleaned studbook, the Warnings
## count) pass before the change and have to keep passing. The module keeps
## the QC Summary's line in storedResults()$genotypeNote (a character string in
## one-file mode, NULL in every other mode) and renders it under the three
## boxes; it is not a warning and does not move the Warnings count.

testthat::skip_on_cran()

## Run the Input module on `ped` written to a temporary CSV, in `mode`
## ("commonPedGenoFile" is the one-file mode), and return what a user gets:
## the cleaned studbook, the genotype extract, the line, the error and warning
## tables and the rendered QC Summary as one HTML string.
runOneFile <- function(ped, mode = "commonPedGenoFile") {
  path <- tempfile(fileext = ".csv")
  utils::write.csv(ped, path, row.names = FALSE)
  uploadId <- if (identical(mode, "pedFile")) {
    "pedigreeFileOne"
  } else {
    "pedigreeFileTwo"
  }
  out <- NULL
  shiny::testServer(modInputServer, args = list(), {
    session$setInputs(fileContent = mode, fileType = "fileTypeExcel",
                      separator = ",", minSireAge = "0.1", minDamAge = "0.1")
    upload <- list(list(name = basename(path), datapath = path))
    names(upload) <- uploadId
    do.call(session$setInputs, upload)
    session$setInputs(getData = 1)
    session$flushReact()
    result <- session$getReturned()
    stored <- storedResults()
    out <<- list(
      cleaned = result$cleanedStudbook(),
      genotype = result$genotypeData(),
      note = stored$genotypeNote,
      errors = stored$errors,
      warnings = stored$warnings,
      html = paste(as.character(output$qcSummaryUI), collapse = "")
    )
  })
  out
}

## The value of column `col` for the animals in oneFileIds, in that order (the
## QC step may reorder the rows).
byId <- function(cleaned, col) cleaned[[col]][match(oneFileIds, cleaned$id)]

test_that("a first/second whole-number file gives the same cleaned studbook in one-file mode as in pedigree-only mode", {
  ped <- oneFileWith(first = oneFileNums1, second = oneFileNums2)
  one <- runOneFile(ped)
  only <- runOneFile(ped, mode = "pedFile")
  expect_identical(one$cleaned, only$cleaned)
  expect_equal(nrow(one$errors), 0L)
  expect_equal(nrow(one$warnings), 0L)
})

test_that("a first/second whole-number file says what was read", {
  res <- runOneFile(oneFileWith(first = oneFileNums1, second = oneFileNums2))
  expect_identical(
    res$note,
    paste0("Genotypes read from first and second: 3 different alleles ",
           "(1, 2, 3) for 8 of 8 animals."))
  expect_false(is.null(res$genotype))
})

test_that("allele_1 and allele_2 holding whole numbers are used, with no warning added", {
  res <- runOneFile(oneFileWith(allele_1 = oneFileNums1,
                                allele_2 = oneFileNums2))
  expect_equal(nrow(res$errors), 0L)
  expect_equal(nrow(res$warnings), 0L)
  expect_true(hasGenotype(res$cleaned))
  expect_false(is.null(res$genotype))
  expect_setequal(names(res$genotype), c("id", "first", "second"))
  expect_equal(byId(res$genotype, "first"), oneFileNums1)
  expect_equal(byId(res$genotype, "second"), oneFileNums2)
  expect_identical(
    res$note,
    paste0("Genotypes read from allele1 and allele2: 3 different alleles ",
           "(1, 2, 3) for 8 of 8 animals."))
})

test_that("allele_1 and allele_2 holding text labels are used as the codes the separate file gives", {
  res <- runOneFile(oneFileWith(allele_1 = oneFileLabs1,
                                allele_2 = oneFileLabs2))
  codes <- oneFileCodes(oneFileIds, oneFileLabs1, oneFileLabs2)
  expect_equal(nrow(res$errors), 0L)
  expect_equal(nrow(res$warnings), 0L)
  expect_true(hasGenotype(res$cleaned))
  expect_equal(byId(res$cleaned, "first"), codes$first)
  expect_equal(byId(res$cleaned, "second"), codes$second)
  expect_identical(
    res$note,
    paste0("Genotypes read from allele1 and allele2: 3 different alleles ",
           "(A, B, C) for 8 of 8 animals."))
})

test_that("headers written 'Allele 1' and 'Allele 2' are read too, and the line is not a warning", {
  ped <- oneFileBase()
  ped[["Allele 1"]] <- oneFileNums1
  ped[["Allele 2"]] <- oneFileNums2
  res <- runOneFile(ped)
  expect_true(hasGenotype(res$cleaned))
  expect_match(res$note, "Genotypes read from allele1 and allele2:",
               fixed = TRUE)
  ## the one warning is the existing "column name case changed" note
  expect_equal(nrow(res$warnings), 1L)
  expect_match(res$warnings$Warning[[1L]], "case changed", fixed = TRUE)
})

test_that("text in first and second is used and the labels move to first_name and second_name", {
  res <- runOneFile(oneFileWith(first = oneFileLabs1, second = oneFileLabs2))
  codes <- oneFileCodes(oneFileIds, oneFileLabs1, oneFileLabs2)
  expect_true(hasGenotype(res$cleaned))
  expect_equal(byId(res$cleaned, "first"), codes$first)
  expect_equal(byId(res$cleaned, "first_name"), oneFileLabs1)
  expect_equal(byId(res$cleaned, "second_name"), oneFileLabs2)
  expect_match(res$note, "Genotypes read from first and second:", fixed = TRUE)
})

test_that("first_name and second_name holding text are used", {
  res <- runOneFile(oneFileWith(first_name = oneFileLabs1,
                                second_name = oneFileLabs2))
  codes <- oneFileCodes(oneFileIds, oneFileLabs1, oneFileLabs2)
  expect_true(hasGenotype(res$cleaned))
  expect_equal(byId(res$cleaned, "first"), codes$first)
  expect_match(res$note, "Genotypes read from first_name and second_name:",
               fixed = TRUE)
})

test_that("one genotype column alone is not used and the line says so", {
  res <- runOneFile(oneFileWith(allele_1 = oneFileNums1))
  expect_null(res$genotype)
  expect_match(res$note, "only one", ignore.case = TRUE)
  expect_match(res$note, "allele1", fixed = TRUE)
  expect_match(res$note, "no genotypes are used", fixed = TRUE)
})

test_that("a file with no genotype columns says what the app looked for", {
  res <- runOneFile(oneFileBase())
  expect_null(res$genotype)
  expect_identical(res$note, noGenotypeNote)
  expect_equal(nrow(res$warnings), 0L)
})

test_that("pedigree-only mode is left alone: no conversion, no line", {
  res <- runOneFile(oneFileWith(allele_1 = oneFileLabs1,
                                allele_2 = oneFileLabs2),
                    mode = "pedFile")
  expect_null(res$note)
  expect_null(res$genotype)
  expect_false(any(c("first", "second") %in% names(res$cleaned)))
  expect_false(grepl("Genotypes read from", res$html, fixed = TRUE))
  expect_false(grepl("No genotype columns were found", res$html, fixed = TRUE))
})

test_that("the separate-files mode is left alone: its genotypes still merge and it shows no line", {
  pedPath <- system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                         package = "nprcgenekeepr")
  genoPath <- system.file("extdata", "examples",
                          "obfuscated_rhesus_mhc_breeder_genotypes.csv",
                          package = "nprcgenekeepr")
  skip_if(pedPath == "" || genoPath == "")
  out <- NULL
  shiny::testServer(modInputServer, args = list(), {
    session$setInputs(fileContent = "separatePedGenoFile",
                      fileType = "fileTypeExcel", separator = ",",
                      minSireAge = "2.0", minDamAge = "2.0")
    session$setInputs(
      pedigreeFileThree = list(name = basename(pedPath), datapath = pedPath),
      genotypeFile = list(name = basename(genoPath), datapath = genoPath))
    session$setInputs(getData = 1)
    session$flushReact()
    out <<- list(note = storedResults()$genotypeNote,
                 genotype = session$getReturned()$genotypeData(),
                 html = paste(as.character(output$qcSummaryUI), collapse = ""))
  })
  expect_null(out$note)
  expect_false(is.null(out$genotype))
  expect_false(grepl("Genotypes read from", out$html, fixed = TRUE))
})

test_that("the QC Summary shows the line under the three boxes, in both forms, in one-file mode only", {
  used <- runOneFile(oneFileWith(allele_1 = oneFileLabs1,
                                 allele_2 = oneFileLabs2))
  expect_type(used$note, "character")
  if (is.character(used$note)) {
    noteAt <- regexpr(used$note, used$html, fixed = TRUE)
    warningsAt <- regexpr(">Warnings<", used$html, fixed = TRUE)
    expect_gt(noteAt, 0L)
    expect_gt(noteAt, warningsAt)
  }
  none <- runOneFile(oneFileBase())
  expect_match(none$html, noGenotypeNote, fixed = TRUE)
  expect_match(none$html, "Data passed quality control", fixed = TRUE)
  only <- runOneFile(oneFileBase(), mode = "pedFile")
  expect_false(grepl("No genotype columns were found", only$html, fixed = TRUE))
})

test_that("the shipped rhesus MHC pedigree with its genotype labels in the same file reports the animals it read", {
  pedPath <- system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                         package = "nprcgenekeepr")
  genoPath <- system.file("extdata", "examples",
                          "obfuscated_rhesus_mhc_breeder_genotypes.csv",
                          package = "nprcgenekeepr")
  skip_if(pedPath == "" || genoPath == "")
  ped <- utils::read.csv(pedPath, stringsAsFactors = FALSE)
  geno <- utils::read.csv(genoPath, stringsAsFactors = FALSE)
  at <- match(ped$id, geno$id)
  ped$first_name <- geno$first_name[at]
  ped$second_name <- geno$second_name[at]
  nGenotyped <- sum(!is.na(ped$first_name) & !is.na(ped$second_name))
  nAlleles <- length(unique(c(ped$first_name, ped$second_name)[
    !is.na(c(ped$first_name, ped$second_name))]))
  expect_gt(nAlleles, 10L)
  res <- runOneFile(ped)
  expect_true(hasGenotype(res$cleaned))
  expect_match(res$note, "Genotypes read from first_name and second_name:",
               fixed = TRUE)
  expect_match(res$note, sprintf("%d different alleles", nAlleles), fixed = TRUE)
  expect_match(res$note, ", ...) for", fixed = TRUE)
  expect_match(res$note,
               sprintf("for %d of %d animals.", nGenotyped, nrow(ped)),
               fixed = TRUE)
})
