## Issue #82 Slice 2 -- recorded validation study for calcFGSE() (the founder-
## genome-equivalent sampling SE). This is the "validate before expose" gate:
## the SE must be shown calibrated on a REAL deep/bottlenecked pedigree before it
## is surfaced to users (Slice 3). The seven checks (agreement, coverage,
## 1/sqrt(K) scaling, degeneracy audit, off-diagonal materiality, bootstrap
## cross-check) follow plan docs/planning/issue82-fg-se-plan.md Section 2 / 6.
##
## Run from the package root (build-ignored; not part of R CMD check):
##   Rscript data-raw/fgSEValidation.R
## Reproducible: fixed seed list (B = 300). ~11 min. Writes the recorded numbers
## to data-raw/fgSEValidation-results.rds; the table embedded in
## vignettes/articles/fg-se-validation.qmd is this script's printed summary.
##
## The harness functions (fgSEValidate etc.) live in the test helpers so the test
## suite unit-tests them on synthetic input; this runner drives the slow study.

suppressMessages(pkgload::load_all(".", quiet = TRUE))
source("tests/testthat/helper-fgSEFixtures.R")
source("tests/testthat/helper-fgSEValidation.R")

B <- 300L
seeds <- seq_len(B)
K <- 1000L

## lacy1989: fast deterministic anchor (3 well-retained founders; off-diagonal
## negligible; cannot exercise covariance or skew -- that is what the real
## pedigree is for).
lacyPed <- nprcgenekeepr::lacy1989Ped

## examplePedigree: the real deep/bottlenecked pedigree (202 founders, several
## with r < 0.10), assembled exactly as reportGV() analyzes it.
data("examplePedigree")
breederPed <- qcStudbook(examplePedigree,
  minParentAge = 2, reportChanges = FALSE, reportErrors = FALSE
)
focal <- breederPed$id[!(is.na(breederPed$sire) & is.na(breederPed$dam)) &
  is.na(breederPed$exit)]
exPed <- setPopulation(ped = breederPed, ids = focal)
probands <- exPed$id[exPed$population]
exPed <- trimPedigree(probands, exPed,
  removeUninformative = FALSE, addBackParents = FALSE
)
exPed$population <- getGVPopulation(exPed, NULL)

message("Running lacy1989 (B=", B, ", K=", K, ") ...")
tLacy <- system.time(resLacy <- fgSEValidate(lacyPed, seeds = seeds, k = K))
message("  ", round(tLacy[["elapsed"]]), "s")

message("Running examplePedigree (B=", B, ", K=", K, ") ...")
tEx <- system.time(resEx <- fgSEValidate(exPed, seeds = seeds, k = K))
message("  ", round(tEx[["elapsed"]]), "s")

results <- list(
  lacy1989 = resLacy, examplePedigree = resEx,
  B = B, K = K, generated = "2026-06-26",
  elapsed = c(lacy1989 = tLacy[["elapsed"]], examplePedigree = tEx[["elapsed"]])
)
saveRDS(results, "data-raw/fgSEValidation-results.rds")

## ---- printed summary (the numbers embedded in the article) ----
fmtSummary <- function(res, label) {
  s <- res$summary
  v <- res$verdict
  yn <- function(x) if (isTRUE(x)) "PASS" else "FAIL"
  cat(sprintf("\n== %s (B=%d, K=%d) ==\n", label, s$B, s$k))
  cat(sprintf("  agreement  mean(SE)/sd(FG) = %.4f   [0.92,1.08]  %s\n",
    s$agreementRatio, yn(v$agreement)))
  cat(sprintf("  coverage   frac FG+-1.96SE covers ref = %.4f   [0.93,0.97]  %s\n",
    s$coverage, yn(v$coverage)))
  cat(sprintf("  scaling    emp=%.3f delta=%.3f   [1.8,2.2]  %s\n",
    s$scalingEmp, s$scalingDelta, yn(v$scaling)))
  cat(sprintf("  degeneracy fraction any(p>0 & r=0) = %.4f   ==0  %s\n",
    s$degeneracyFraction, yn(v$degeneracy)))
  cat(sprintf("  bootstrap  boot/delta = %.4f (dropped %.4f)   [0.85,1.15]  %s\n",
    s$bootstrapRatio, s$bootDropped, yn(v$bootstrap)))
  cat(sprintf("  off-diag   seFull=%.5g seDiag=%.5g  full/diag=%.3f (reported)\n",
    s$seFull, s$seDiag, s$offDiagRatio))
  cat(sprintf("  refFG(K=%d)=%.5g   VERDICT: %s\n",
    s$refK, s$refFG, yn(v$overall)))
}
fmtSummary(resLacy, "lacy1989")
fmtSummary(resEx, "examplePedigree")
cat("\nDONE\n")
