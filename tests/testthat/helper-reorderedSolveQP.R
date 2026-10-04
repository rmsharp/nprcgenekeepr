## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Test-harness support for the joint-QP layout tests (S893). The layout's
## quadratic program (`.solveJointQP()` in R/makePedigreeDiagramData.R) is badly
## conditioned (cond(Dmat) about 1.6e9 on the bundled 375-animal fixture), so
## the order in which `quadprog::solve.QP()` meets the variables changes its
## rounding, and so changes how far a spacing floor can be missed. The answer
## is the same in exact arithmetic; only the rounding path differs, which is
## what a different BLAS or CPU kernel changes on a CI runner. These helpers
## let a test take such a path on purpose, with a fixed seed, so a tolerance
## is checked against the solver's real noise instead of one lucky run
## (docs/audits/CI_RED_MASTER_DIAGNOSIS_2026-10-04.md).
##
## `solve.QP` is replaced inside `quadprog`'s namespace because the package
## calls it as `quadprog::solve.QP()`; no production code is touched.

## Runs `code` with quadprog::solve.QP() replaced by a wrapper that shuffles
## the QP's variables (rows and columns of Dmat, entries of dvec, rows of
## Amat), solves, and un-shuffles the solution. `seed` fixes the shuffle, so
## the same seed gives the same rounding path in every run on one machine.
## The wrapper takes exactly the arguments the package passes (no `factorized`)
## so a future change in how the package calls solve.QP() fails loudly here.
withReorderedSolveQP <- function(seed, code) {
  origSolveQP <- quadprog::solve.QP
  reorderedSolveQP <- function(Dmat, dvec, Amat, bvec, meq = 0L) {
    n <- nrow(Dmat)
    p <- withr::with_seed(seed, sample.int(n))
    fit <- origSolveQP(Dmat[p, p, drop = FALSE], dvec[p],
                       Amat[p, , drop = FALSE], bvec, meq)
    solution <- numeric(n)
    solution[p] <- fit$solution
    fit$solution <- solution
    fit
  }
  testthat::with_mocked_bindings(
    code, solve.QP = reorderedSolveQP, .package = "quadprog"
  )
}
