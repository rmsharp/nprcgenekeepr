## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## S990 (BACKLOG.md docs-audit part 2; S986 findings 1 and 8, flags MB3 and
## PD12): two help sentences say something the code does not do. The owner
## approved the replacement wording S986, the same in both places each time
## (the roxygen block and the regenerated man page).
##
## kinship(), argument chrtype: the help said "An individual with unrecognized
## sex gets NA kinship with everyone, including their own self-kinship
## value." With chrtype = "x" the code gives a founder of unrecognized sex NA
## only on its own diagonal cell and 0 with the other founders; only an
## animal of unrecognized sex that has parents gets NA with everyone. Both
## equal kinship2's vector kinship(id, dadid, momid, sex, chrtype = "x"),
## the function this one ports (checked S990, kinship2 1.9.6.2).
##
## hasBothParents(), argument id: the help said a vector of IDs "gives a
## recycling warning". The result is not one value per ID (`ped$id == id`
## recycles the IDs down the rows), and the warning appears only when the
## number of IDs does not divide the number of rows of ped.
##
## Each page is read whole, in the two places the help lives, and must hold the
## approved sentence exactly once and the old one nowhere; a sentence this long
## cannot be matched by accident (Learning 89). Both readers need the source
## tree (man/ and R/ do not exist under an installed package) and skip without
## it. The behavior locks at the end pass at HEAD: they keep the new sentences
## true.

## helpPlaces(), skipUnlessHelpInSourceTree() and expectWording() are in
## helper-pageText.R.

helpCases <- list(
  kinship = list(
    places = helpPlaces("kinship", "kinship.R"),
    unchanged = "computes X-chromosome kinship instead",
    now = paste(
      "A founder of unrecognized sex gets NA only on its own diagonal cell",
      "and 0 with the other founders, as in kinship2; an animal of",
      "unrecognized sex that has parents in the pedigree gets NA kinship",
      "with everyone, itself included."
    ),
    gone = paste(
      "An individual with unrecognized sex gets NA kinship with everyone,",
      "including their own self-kinship value."
    )
  ),
  hasBothParents = list(
    places = helpPlaces("hasBothParents", "hasBothParents.R"),
    unchanged = "a single ID to examine for parents.",
    now = paste(
      "A vector of IDs is not supported: the result is not one value per",
      "ID, and a recycling warning appears only when the number of IDs",
      "does not divide the number of rows of ped."
    ),
    gone = "A vector of IDs is not supported and gives a recycling"
  )
)

## Sanity check on the readers (green at HEAD). It proves the RED failures
## below are about the help text, not about readers that find nothing.
test_that("the readers find each function's help", {
  for (case in helpCases) {
    skipUnlessHelpInSourceTree(case$places)
    for (read in case$places) {
      expect_match(read(), case$unchanged, fixed = TRUE)
    }
  }
})

## The failing tests (RED at HEAD): both places of both functions still carry
## the old wording and lack the approved sentence.
for (name in names(helpCases)) {
  for (place in names(helpCases[[name]]$places)) {
    test_that(paste0("the ", place, " of ", name, " has the approved sentence only"), {
      case <- helpCases[[name]]
      skipUnlessHelpInSourceTree(case$places)
      expectWording(case$places[[place]](), now = case$now, gone = case$gone)
    })
  }
}

## Behavior locks (green at HEAD, not the RED drivers). The kinship sentence is
## only true while the code gives an unknown-sex founder NA on its own
## diagonal cell alone, and an unknown-sex animal with parents NA with
## everyone. Each lock carries a guard expectation, so it cannot pass on a
## fixture that does not show the case.

## Founders A (M), B (F), C (unrecognized); D and E are known-sex children of
## A and B. C has no descendants. With `withUnknownChild`, F is an
## unrecognized-sex child of A and B.
xKinship <- function(withUnknownChild) {
  id <- c("A", "B", "C", "D", "E")
  sire <- c(NA, NA, NA, "A", "A")
  dam <- c(NA, NA, NA, "B", "B")
  depth <- c(0L, 0L, 0L, 1L, 1L)
  sex <- c("M", "F", "U", "F", "M")
  if (withUnknownChild) {
    id <- c(id, "F")
    sire <- c(sire, "A")
    dam <- c(dam, "B")
    depth <- c(depth, 1L)
    sex <- c(sex, "U")
  }
  list(
    id = id, sire = sire, dam = dam, depth = depth, sex = sex,
    kmat = as.matrix(kinship(id, sire, dam, depth, chrtype = "x", sex = sex))
  )
}

test_that("a founder of unrecognized sex is NA only on its own diagonal cell", {
  fixture <- xKinship(withUnknownChild = FALSE)
  row <- fixture$kmat["C", ]
  expect_identical(sum(is.na(row)), 1L)
  expect_true(is.na(row[["C"]]))
  expect_identical(unname(row[c("A", "B")]), c(0, 0))
  expect_identical(unname(fixture$kmat[c("A", "B"), "C"]), c(0, 0))
})

test_that("an animal of unrecognized sex with parents is NA with everyone", {
  fixture <- xKinship(withUnknownChild = TRUE)
  expect_identical(fixture$sex[fixture$id == "F"], "U")
  expect_identical(fixture$dam[fixture$id == "F"], "B")
  expect_true(all(is.na(fixture$kmat["F", ])))
  expect_true(all(is.na(fixture$kmat[, "F"])))
})

test_that("both unrecognized-sex cases equal kinship2's vector kinship()", {
  skip_if_not_installed("kinship2")
  for (withUnknownChild in c(FALSE, TRUE)) {
    fixture <- xKinship(withUnknownChild)
    kinship2Sex <- c(M = 1, F = 2, U = 3)[fixture$sex]
    theirs <- kinship2::kinship(
      fixture$id, fixture$sire, fixture$dam,
      sex = unname(kinship2Sex), chrtype = "x"
    )
    expect_equal(unname(fixture$kmat), unname(as.matrix(theirs)))
    expect_true(anyNA(fixture$kmat))
  }
})

## The hasBothParents() sentence is only true while the IDs recycle down the
## rows of ped: pedOne has 8 rows, so 2 IDs divide it and 3 do not.
hasBothParentsPed <- function() {
  ped <- nprcgenekeepr::pedOne
  names(ped) <- c("id", "sire", "dam", "sex", "birth")
  ped
}

test_that("a vector of IDs does not give one value per ID", {
  ped <- hasBothParentsPed()
  ids <- c(ped$id[2L], ped$id[1L])
  expect_identical(length(ids), 2L)
  expect_identical(hasBothParents(ids, ped), logical(0L))
})

test_that("a vector of IDs warns only when its length does not divide the rows", {
  ped <- hasBothParentsPed()
  expect_identical(nrow(ped), 8L)
  expect_warning(
    hasBothParents(ped$id[1L:3L], ped),
    "longer object length is not a multiple of shorter object length"
  )
  expect_warning(hasBothParents(ped$id[1L:2L], ped), NA)
  expect_warning(hasBothParents(ped$id[1L:4L], ped), NA)
})
