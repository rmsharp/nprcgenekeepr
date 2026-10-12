## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared fixtures for the tests of the one-file genotype columns
## (test_readOneFileGenotypes.R, test_modInputOneFileGenotypes.R): eight
## animals, three alleles written as whole numbers (1, 2, 3) or as text
## labels (A, B, C), and the codes addGenotype() gives the same labels, which
## is the rule the one-file mode follows too.

oneFileIds <- c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4")
oneFileNums1 <- c(1, 2, 1, 2, 3, 3, 1, 2)
oneFileNums2 <- c(2, 2, 3, 1, 3, 1, 1, 2)
oneFileLabs1 <- c("A", "B", "A", "B", "C", "C", "A", "B")
oneFileLabs2 <- c("B", "B", "C", "A", "C", "A", "A", "B")

## The line shown when a one-file pedigree holds no usable genotype columns,
## word for word as the owner approved it (S971).
noGenotypeNote <- paste0(
  "No genotype columns were found in this file (looked for first and second, ",
  "first_name and second_name, allele_1 and allele_2), so no genotypes are ",
  "used.")

## The line shown when two or more of the six allele columns are in the file
## but no pair of them can be read (they do not pair, or the pair has no
## allele in it), word for word as the owner approved it (S972, the PRE-RED
## gate). `found` is the names the app has already cleaned (allele2, not
## allele_2), in the order the app looks for them.
unusablePairNote <- function(found) {
  paste0("Genotype columns were found (", toString(found), "), but they are ",
         "not a usable pair, so no genotypes are used; a pair is first and ",
         "second, first_name and second_name, or allele_1 and allele_2, with ",
         "at least one allele in it.")
}

## A pedigree the Input tab's check accepts with 0 errors (founders, then six
## offspring born at least three years after their parents), as the raw file a
## user uploads: plain column names, no genotype columns yet.
oneFileBase <- function() {
  data.frame(
    id = oneFileIds,
    sire = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
    dam = c(NA, NA, NA, NA, "d1", "d2", "d2", "d2"),
    sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
    birth = c("2000-07-18", "2003-04-13", "2005-06-19", "2002-06-22",
              "2008-01-01", "2009-02-02", "2010-03-03", "2011-04-04"),
    stringsAsFactors = FALSE
  )
}

## The base pedigree plus the named columns, in the order given.
oneFileWith <- function(...) {
  ped <- oneFileBase()
  extra <- list(...)
  for (nm in names(extra)) ped[[nm]] <- extra[[nm]]
  ped
}

## The codes addGenotype() assigns to these labels (numbered from 10001, in
## sorted order over both columns), in the order of `ids`.
oneFileCodes <- function(ids, first, second) {
  genotype <- data.frame(id = ids, a = first, b = second,
                         stringsAsFactors = FALSE)
  merged <- addGenotype(data.frame(id = ids, stringsAsFactors = FALSE),
                        genotype)
  merged <- merged[match(ids, merged$id), ]
  list(first = merged$first, second = merged$second)
}
