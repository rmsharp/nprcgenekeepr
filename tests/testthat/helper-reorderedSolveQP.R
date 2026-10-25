## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Test-harness support for the joint-QP layout tests (S893). The layout's
## quadratic program (`.solveJointQP()` in R/makePedigreeDiagramData.R) is badly
## conditioned (cond(Dmat) about 1.6e9 on the bundled 375-animal fixture), so
## the order in which the solver meets the variables changes its rounding,
## and so changes how far a spacing floor can be missed. The answer is the
## same in exact arithmetic; only the rounding path differs, which is what a
## different BLAS or CPU kernel changes on a CI runner. These helpers let a
## test take such a path on purpose, with a fixed seed, so a tolerance is
## checked against the solver's real noise instead of one lucky run
## (docs/audits/CI_RED_MASTER_DIAGNOSIS_2026-10-04.md).
##
## `solve.QP.compact` is replaced inside `quadprog`'s namespace because the
## package calls it as `quadprog::solve.QP.compact()` (Phase 7 of the
## performance and memory campaign, S1060: each separation constraint is
## passed as its two entries, not as a dense column); no production code is
## touched.

## Runs `code` with quadprog::solve.QP.compact() replaced by a wrapper that
## shuffles the QP's variables (rows and columns of Dmat, entries of dvec, the
## variable each constraint entry names), solves, and un-shuffles the
## solution. Each constraint's entries are put back in the order of their new
## variable numbers, the order the dense quadprog::solve.QP() adds them in, so
## a seed takes the same rounding path the S893 wrapper of the dense solver
## took (S1060: identical on 300 of 300 seeds for trackBFull and trackC) and
## the seeds the tests chose keep their measured margins. `seed` fixes the
## shuffle, so the same seed gives the same rounding path in every run on one
## machine. The wrapper takes exactly the arguments the package passes (no
## `factorized`) so a future change in how the package calls the solver fails
## loudly here, and the test fails if the wrapper never ran: a shuffle that
## intercepts nothing would check nothing.
withReorderedSolveQP <- function(seed, code) {
  origSolveQP <- quadprog::solve.QP.compact
  calls <- 0L
  reorderedSolveQP <- function(Dmat, dvec, Amat, Aind, bvec, meq = 0L) {
    calls <<- calls + 1L
    n <- nrow(Dmat)
    p <- withr::with_seed(seed, sample.int(n))
    newIndex <- order(p)
    for (i in seq_len(ncol(Aind))) {
      k <- seq_len(Aind[1L, i])
      moved <- newIndex[Aind[k + 1L, i]]
      inOrder <- order(moved)
      Aind[k + 1L, i] <- moved[inOrder]
      Amat[k, i] <- Amat[k, i][inOrder]
    }
    fit <- origSolveQP(Dmat[p, p, drop = FALSE], dvec[p], Amat, Aind, bvec,
                       meq)
    solution <- numeric(n)
    solution[p] <- fit$solution
    fit$solution <- solution
    fit
  }
  result <- testthat::with_mocked_bindings(
    code, solve.QP.compact = reorderedSolveQP, .package = "quadprog"
  )
  testthat::expect(
    calls > 0L,
    "withReorderedSolveQP(): quadprog::solve.QP.compact() never ran, so the shuffle checked nothing"
  )
  result
}
