## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## A Cross-Center pedigree file with its column headings and no animals: the
## three required columns plus any `extra` ones, all zero-row character.
emptyPedigree <- function(extra = character(0L)) {
  cols <- c("id", "sire", "dam", extra)
  as.data.frame(
    stats::setNames(rep(list(character(0L)), length(cols)), cols),
    stringsAsFactors = FALSE
  )
}

## The mapping such a file needs: a mapping row names an animal the file does
## not have, and the merge stops.
noMapping <- data.frame(
  idA = character(0L), idB = character(0L), stringsAsFactors = FALSE
)
