## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Dedicated unit tests for getAncestors(), which had no direct test coverage.
#' getAncestors() recursively returns the sire-then-dam lineage for an ID,
#' given a pedigree tree (list of id -> list(sire, dam)).

ptree <- list(
  A = list(sire = NA_character_, dam = NA_character_),
  B = list(sire = NA_character_, dam = NA_character_),
  C = list(sire = "A", dam = "B"),
  D = list(sire = "A", dam = "B"),
  E = list(sire = "C", dam = "D")
)

test_that("getAncestors returns character(0) for a founder", {
  expect_identical(getAncestors("A", ptree), character(0))
})

test_that("getAncestors returns character(0) for a missing (NA) ID", {
  expect_identical(getAncestors(NA_character_, ptree), character(0))
})

test_that("getAncestors returns both parents for a one-generation ID", {
  expect_identical(getAncestors("C", ptree), c("A", "B"))
})

test_that("getAncestors returns the sire-then-dam lineage (with repeats)", {
  expect_identical(
    getAncestors("E", ptree),
    c("C", "A", "B", "D", "A", "B")
  )
})

test_that("getAncestors covers the full ancestor set for an ID", {
  expect_setequal(unique(getAncestors("E", ptree)), c("A", "B", "C", "D"))
})

test_that("getAncestors works on a createPedTree() pedigree tree", {
  pt <- createPedTree(nprcgenekeepr::lacy1989Ped)
  expect_setequal(unique(getAncestors("F", pt)), c("A", "B", "D", "E"))
  expect_false("F" %in% getAncestors("F", pt))
})

# A pedigree cycle (an animal that is its own ancestor) is a data error. It used
# to recurse until R aborted with "evaluation nested too deeply: infinite
# recursion"; getAncestors() now stops with a message that names the cycle.
# The documented repeats (see the "with repeats" test above) are a diamond, not
# a cycle, and must keep being returned.
np <- NA_character_
cycleMessage <- function(expr) {
  tryCatch(
    {
      expr
      NA_character_
    },
    error = function(e) conditionMessage(e)
  )
}

test_that("getAncestors stops with a message naming a sire-side 2-cycle", {
  cyc <- list(
    X = list(sire = "Y", dam = np),
    Y = list(sire = "X", dam = np)
  )
  msg <- cycleMessage(getAncestors("X", cyc))
  expect_match(msg, "contains a cycle", fixed = TRUE)
  expect_match(msg, "X -> Y -> X", fixed = TRUE)
})

test_that("getAncestors stops with a message naming a self-parent", {
  cyc <- list(S = list(sire = "S", dam = np))
  msg <- cycleMessage(getAncestors("S", cyc))
  expect_match(msg, "contains a cycle", fixed = TRUE)
  expect_match(msg, "S -> S", fixed = TRUE)
})

test_that("getAncestors stops with a message naming a dam-side 2-cycle", {
  cyc <- list(
    A = list(sire = np, dam = "B"),
    B = list(sire = np, dam = "A")
  )
  msg <- cycleMessage(getAncestors("A", cyc))
  expect_match(msg, "contains a cycle", fixed = TRUE)
  expect_match(msg, "A -> B -> A", fixed = TRUE)
})

test_that("getAncestors names every id of a 3-cycle, in order", {
  cyc <- list(
    X = list(sire = "Y", dam = np),
    Y = list(sire = np, dam = "W"),
    W = list(sire = "X", dam = np)
  )
  msg <- cycleMessage(getAncestors("X", cyc))
  expect_match(msg, "contains a cycle", fixed = TRUE)
  expect_match(msg, "X -> Y -> W -> X", fixed = TRUE)
})

test_that("getAncestors names only the cycle when the start id is outside it", {
  cyc <- list(
    Z = list(sire = "X", dam = np),
    X = list(sire = "Y", dam = np),
    Y = list(sire = "X", dam = np)
  )
  msg <- cycleMessage(getAncestors("Z", cyc))
  expect_match(msg, "X -> Y -> X", fixed = TRUE)
  expect_false(grepl("\\bZ\\b", msg))
})

test_that("findLoops and countLoops surface the cycle message", {
  cyc <- list(
    X = list(sire = "Y", dam = np),
    Y = list(sire = "X", dam = np)
  )
  expect_match(cycleMessage(findLoops(cyc)), "contains a cycle", fixed = TRUE)
  expect_match(
    cycleMessage(countLoops(list(X = FALSE, Y = FALSE), cyc)),
    "contains a cycle",
    fixed = TRUE
  )
})

# A parent listed in the sire or dam column that has no entry of its own in the
# tree is carried on as an animal with unknown parents, as qcStudbook() does
# (addParents() adds the entry). Asking about an animal that is not in the tree
# at all is a mistake by the caller and stops with a message naming it.
errorMessage <- cycleMessage

test_that("getAncestors stops with a message naming an animal that is not in the tree", {
  msg <- errorMessage(getAncestors("NOPE", ptree))
  expect_false(is.na(msg))
  expect_match(msg, "NOPE", fixed = TRUE)
  expect_match(msg, "is not in the pedigree tree", fixed = TRUE)
})

test_that("getAncestors carries on when the sire is not in the tree", {
  tree <- c(ptree, list(K = list(sire = "GONE", dam = "B")))
  expect_identical(getAncestors("K", tree), c("GONE", "B"))
})

test_that("getAncestors carries on when the dam, or both parents, are not in the tree", {
  damGone <- c(ptree, list(K = list(sire = "A", dam = "GONE")))
  expect_identical(getAncestors("K", damGone), c("A", "GONE"))
  bothGone <- list(K = list(sire = "G1", dam = "G2"))
  expect_identical(getAncestors("K", bothGone), c("G1", "G2"))
})

test_that("getAncestors carries on when a grandparent is not in the tree", {
  tree <- list(
    P = list(sire = "GONE", dam = np),
    Q = list(sire = np, dam = np),
    K = list(sire = "P", dam = "Q")
  )
  expect_identical(getAncestors("K", tree), c("P", "GONE", "Q"))
})

test_that("getAncestors on a raw tree equals the answer after qcStudbook() adds the absent parents", {
  trees <- absentParentTrees()
  absent <- c("GONE_X", "GONE_Y", "GONE_Z", "GONE_P", "GONE_Q")
  expect_false(any(absent %in% names(trees$raw)))
  expect_true(all(absent %in% names(trees$qc)))
  expect_identical(
    getAncestors("K", trees$raw),
    c("S1", "GONE_X", "GONE_Y", "D1", "GONE_X", "GONE_Z")
  )
  for (id in names(trees$raw)) {
    expect_identical(getAncestors(id, trees$raw), getAncestors(id, trees$qc))
  }
})
