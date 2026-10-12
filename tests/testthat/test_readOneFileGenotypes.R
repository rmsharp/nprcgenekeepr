## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:139 (S968 ruled "show a notice"; at S970 the owner redirected:
## implement the columns, so the genotypes are used; at S971 the owner chose
## to read text labels as well as whole numbers and to have the Input tab say
## what was read, or that nothing usable was found). With "Pedigree(s) and
## genotypes in one file", columns named allele_1 / allele_2 loaded with 0
## errors and 0 warnings and their genotypes were then not used, with nothing
## saying so; text labels, and first_name / second_name, were not used either.
##
## readOneFileGenotypes(ped) takes the studbook the Input tab's QC step has
## cleaned (so the headers are already normalised: allele_1, Allele 1 and
## allele.1 all arrive as allele1) and returns a list with
##   ped   the studbook with the integer columns first and second added when
##         genotypes were read (it is unchanged when they were not),
##   used  TRUE when genotypes were read,
##   note  the one line the QC Summary shows.
##
## Which pair is read, first match wins: whole-number first and second (left as
## they are); first and second holding text; first_name and second_name;
## allele1 and allele2. Whole numbers are used as they are, as first and
## second always were; text labels become the codes addGenotype() gives them
## (numbered from 10001, sorted over both columns), the same rule as the
## separate genotype file. The user's labels are kept: text that stood in
## first / second moves to first_name / second_name when those are absent.
## A label that reads as a whole number above 10000 next to text labels is
## refused, as checkGenotypeFile() refuses it, because it would collide with
## the codes. Nothing is trimmed or case-folded, so a misspelt label is a
## separate allele and shows up in the line's count, which is the point of the
## line.
##
## The two lines the owner approved (the second one word for word) are pinned
## exactly; the wording of the single-column and refusal lines is pinned by
## its facts only, until the owner approves their sentences.

test_that("whole-number first and second are used as they are and the line says what was read", {
  ped <- oneFileWith(first = oneFileNums1, second = oneFileNums2)
  res <- readOneFileGenotypes(ped)
  expect_true(res$used)
  expect_identical(res$ped, ped)
  expect_identical(
    res$note,
    paste0("Genotypes read from first and second: 3 different alleles ",
           "(1, 2, 3) for 8 of 8 animals."))
})

test_that("the line lists whole-number alleles in numeric order", {
  ped <- oneFileWith(first = rep(c(2, 10), 4L), second = rep(c(10, 2), 4L))
  res <- readOneFileGenotypes(ped)
  expect_match(res$note, "2 different alleles (2, 10)", fixed = TRUE)
})

test_that("the line lists at most ten alleles and then says there are more", {
  ped <- oneFileWith(first = 1:8, second = 5:12)
  res <- readOneFileGenotypes(ped)
  expect_identical(
    res$note,
    paste0("Genotypes read from first and second: 12 different alleles ",
           "(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, ...) for 8 of 8 animals."))
})

test_that("one allele and one animal are worded in the singular", {
  ped <- data.frame(id = "x1", first = 7, second = 7, stringsAsFactors = FALSE)
  res <- readOneFileGenotypes(ped)
  expect_identical(
    res$note,
    "Genotypes read from first and second: 1 different allele (7) for 1 of 1 animal.")
})

test_that("an animal counts as genotyped when both alleles are present", {
  ped <- oneFileWith(first = c(1, 2, NA, NA, 3, 3, 1, 2),
                     second = c(2, 2, NA, 1, 3, 1, 1, NA))
  res <- readOneFileGenotypes(ped)
  expect_true(res$used)
  expect_identical(
    res$note,
    paste0("Genotypes read from first and second: 3 different alleles ",
           "(1, 2, 3) for 5 of 8 animals."))
})

test_that("allele1 and allele2 holding whole numbers become first and second as they are", {
  ped <- oneFileWith(allele1 = oneFileNums1, allele2 = oneFileNums2)
  res <- readOneFileGenotypes(ped)
  expect_true(res$used)
  expect_identical(res$ped$first, oneFileNums1)
  expect_identical(res$ped$second, oneFileNums2)
  expect_identical(res$ped[names(ped)], ped)
  expect_true(hasGenotype(res$ped))
  expect_identical(names(getGVGenotype(res$ped)), c("id", "first", "second"))
  expect_identical(
    res$note,
    paste0("Genotypes read from allele1 and allele2: 3 different alleles ",
           "(1, 2, 3) for 8 of 8 animals."))
})

test_that("allele1 and allele2 holding text labels become the codes the separate file gives, and the labels stay", {
  ped <- oneFileWith(allele1 = oneFileLabs1, allele2 = oneFileLabs2)
  res <- readOneFileGenotypes(ped)
  codes <- oneFileCodes(ped$id, oneFileLabs1, oneFileLabs2)
  expect_true(res$used)
  expect_type(res$ped$first, "integer")
  expect_identical(res$ped$first, codes$first)
  expect_identical(res$ped$second, codes$second)
  expect_setequal(unique(c(res$ped$first, res$ped$second)), 10001:10003)
  expect_identical(res$ped[names(ped)], ped)
  expect_true(hasGenotype(res$ped))
  expect_identical(
    res$note,
    paste0("Genotypes read from allele1 and allele2: 3 different alleles ",
           "(A, B, C) for 8 of 8 animals."))
})

test_that("text in first and second becomes codes, and the labels move to first_name and second_name", {
  ped <- oneFileWith(first = oneFileLabs1, second = oneFileLabs2)
  res <- readOneFileGenotypes(ped)
  codes <- oneFileCodes(ped$id, oneFileLabs1, oneFileLabs2)
  expect_true(res$used)
  expect_identical(res$ped$first, codes$first)
  expect_identical(res$ped$second, codes$second)
  expect_identical(res$ped$first_name, oneFileLabs1)
  expect_identical(res$ped$second_name, oneFileLabs2)
  expect_true(hasGenotype(res$ped))
  expect_match(res$note, "Genotypes read from first and second: 3 different alleles (A, B, C) for 8 of 8 animals.",
               fixed = TRUE)
})

test_that("labels already in first_name and second_name are not overwritten", {
  ped <- oneFileWith(first = oneFileLabs1, second = oneFileLabs2,
                     first_name = rep("keep1", 8L),
                     second_name = rep("keep2", 8L))
  res <- readOneFileGenotypes(ped)
  expect_true(res$used)
  expect_identical(res$ped$first_name, rep("keep1", 8L))
  expect_identical(res$ped$second_name, rep("keep2", 8L))
  expect_identical(res$ped$first,
                   oneFileCodes(ped$id, oneFileLabs1, oneFileLabs2)$first)
})

test_that("first_name and second_name holding text are read and stay where they are", {
  ped <- oneFileWith(first_name = oneFileLabs1, second_name = oneFileLabs2)
  res <- readOneFileGenotypes(ped)
  codes <- oneFileCodes(ped$id, oneFileLabs1, oneFileLabs2)
  expect_true(res$used)
  expect_identical(res$ped$first, codes$first)
  expect_identical(res$ped$second, codes$second)
  expect_identical(res$ped[names(ped)], ped)
  expect_match(res$note, "Genotypes read from first_name and second_name: 3 different alleles (A, B, C)",
               fixed = TRUE)
})

test_that("whole-number first and second win over every other pair, and the file is left as it is", {
  withAllele <- oneFileWith(first = oneFileNums1, second = oneFileNums2,
                            allele1 = rep(9, 8L), allele2 = rep(8, 8L))
  res <- readOneFileGenotypes(withAllele)
  expect_identical(res$ped, withAllele)
  expect_match(res$note, "Genotypes read from first and second:", fixed = TRUE)
  ## an exported pedigree carries codes and their labels together
  exported <- oneFileWith(first = oneFileNums1, second = oneFileNums2,
                          first_name = oneFileLabs1,
                          second_name = oneFileLabs2)
  res <- readOneFileGenotypes(exported)
  expect_identical(res$ped, exported)
  expect_match(res$note, "Genotypes read from first and second:", fixed = TRUE)
})

test_that("text in first and second comes before first_name and before allele1", {
  ped <- oneFileWith(first = oneFileLabs1, second = oneFileLabs2,
                     allele1 = oneFileNums1, allele2 = oneFileNums2)
  res <- readOneFileGenotypes(ped)
  expect_identical(res$ped$first,
                   oneFileCodes(ped$id, oneFileLabs1, oneFileLabs2)$first)
  expect_match(res$note, "Genotypes read from first and second:", fixed = TRUE)
})

test_that("first_name and second_name come before allele1 and allele2", {
  ped <- oneFileWith(first_name = oneFileLabs1, second_name = oneFileLabs2,
                     allele1 = rev(oneFileLabs1), allele2 = rev(oneFileLabs2))
  res <- readOneFileGenotypes(ped)
  expect_identical(res$ped$first,
                   oneFileCodes(ped$id, oneFileLabs1, oneFileLabs2)$first)
  expect_match(res$note, "Genotypes read from first_name and second_name:",
               fixed = TRUE)
})

test_that("a single allele column is not used and the line says so", {
  for (ped in list(oneFileWith(allele1 = oneFileNums1),
                   oneFileWith(first = oneFileNums1))) {
    res <- readOneFileGenotypes(ped)
    expect_false(res$used)
    expect_identical(res$ped, ped)
    expect_match(res$note, "only one", ignore.case = TRUE)
    expect_match(res$note, "no genotypes are used", fixed = TRUE)
  }
  expect_match(readOneFileGenotypes(oneFileWith(allele1 = oneFileNums1))$note,
               "allele1", fixed = TRUE)
})

test_that("a file with no genotype columns is not used and the line says what was looked for", {
  ped <- oneFileBase()
  res <- readOneFileGenotypes(ped)
  expect_false(res$used)
  expect_identical(res$ped, ped)
  expect_identical(res$note, noGenotypeNote)
})

test_that("a label that reads as a whole number above 10000 next to text is refused, with the reason", {
  ped <- oneFileWith(allele1 = c("A", "B", "10500", "A", "B", "A", "B", "A"),
                     allele2 = oneFileLabs2)
  res <- readOneFileGenotypes(ped)
  expect_false(res$used)
  expect_false(any(c("first", "second") %in% names(res$ped)))
  expect_identical(res$ped, ped)
  expect_match(res$note, "not used", fixed = TRUE)
  expect_match(res$note, "10500", fixed = TRUE)
  expect_match(res$note, "allele1", fixed = TRUE)
})

test_that("whole numbers above 10000 are used as they are, as first and second always were", {
  big <- c(10500, 10600, 10500, 10600, 10500, 10600, 10500, 10600)
  ped <- oneFileWith(allele1 = big, allele2 = rev(big))
  res <- readOneFileGenotypes(ped)
  expect_true(res$used)
  expect_identical(res$ped$first, big)
})

test_that("a misspelt label is a separate allele and the line shows it", {
  ped <- oneFileWith(
    allele1 = c("A", "a", "B", "B ", "C", "A", "a", "B"),
    allele2 = c("A", "A", "C", "C", "A", "B", "a", "C"))
  res <- readOneFileGenotypes(ped)
  expect_true(res$used)
  expect_length(unique(c(res$ped$first, res$ped$second)), 5L)
  expect_match(res$note, "5 different alleles", fixed = TRUE)
  expect_match(res$note, "\"B \"", fixed = TRUE)
  expect_match(res$note, "(^|[(, ])a[,)]")
})

test_that("blank and space-only labels count as missing", {
  ped <- oneFileWith(
    allele1 = c("A", "B", "", " ", "C", "A", "B", "C"),
    allele2 = c("B", "A", "A", "A", "", "C", "B", NA))
  res <- readOneFileGenotypes(ped)
  expect_true(res$used)
  ## each allele is coded on its own: first is missing where the first label is
  ## blank (rows 3 and 4), second where the second one is (rows 5 and 8)
  expect_true(all(is.na(res$ped$first[c(3L, 4L)])))
  expect_false(anyNA(res$ped$first[c(1L, 2L, 5L, 6L, 7L, 8L)]))
  expect_true(all(is.na(res$ped$second[c(5L, 8L)])))
  expect_false(anyNA(res$ped$second[c(1L, 2L, 3L, 4L, 6L, 7L)]))
  expect_match(res$note, "3 different alleles (A, B, C) for 4 of 8 animals.",
               fixed = TRUE)
})

## An Excel upload reads every cell as text (the guide's callout on the Excel
## read), so whole numbers arrive as "1", "2", "10". They are whole numbers all
## the same: a file saved as xlsx and as csv has to give the same alleles.
## Added S971 (RED amendment, owner's answer at the GREEN-to-RED gate): the
## code was written in GREEN without a test, and a mutation that read such text
## as labels was caught by no block.
test_that("text that reads as whole numbers, as an Excel file gives them, is used as numbers", {
  allele1 <- c("1", "2", "1", "2", "10", "10", "1", "2")
  allele2 <- c("2", "2", "10", "1", "10", "1", "1", "")
  ped <- oneFileWith(allele1 = allele1, allele2 = allele2)
  res <- readOneFileGenotypes(ped)
  expect_true(res$used)
  expect_type(res$ped$first, "double")
  expect_identical(res$ped$first, as.numeric(allele1))
  expect_identical(res$ped$second, c(2, 2, 10, 1, 10, 1, 1, NA))
  expect_identical(res$ped[names(ped)], ped)
  expect_identical(
    res$note,
    paste0("Genotypes read from allele1 and allele2: 3 different alleles ",
           "(1, 2, 10) for 7 of 8 animals."))
})

test_that("a column that mixes whole-number text with a label is read as labels and coded", {
  allele1 <- c("1", "A", "1", "A", "B", "B", "1", "A")
  allele2 <- c("A", "A", "B", "1", "B", "1", "1", "A")
  ped <- oneFileWith(allele1 = allele1, allele2 = allele2)
  res <- readOneFileGenotypes(ped)
  codes <- oneFileCodes(ped$id, allele1, allele2)
  expect_true(res$used)
  expect_type(res$ped$first, "integer")
  expect_identical(res$ped$first, codes$first)
  expect_identical(res$ped$second, codes$second)
  expect_setequal(unique(c(res$ped$first, res$ped$second)), 10001:10003)
  expect_match(res$note, "3 different alleles (1, A, B) for 8 of 8 animals.",
               fixed = TRUE)
})
