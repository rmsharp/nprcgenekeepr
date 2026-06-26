# Issue #82 -- Sampling standard error for founder genome equivalents (`fg`)

**Status:** PLAN (Session 203, 2026-06-25). Awaiting owner ratification of Section 5 before any
implementation slice begins. This document is the deliverable of a planning session; implementation is
separate sessions (one slice each), per `SESSION_RUNNER.md` (FM #18, no planning-to-implementation bleed).

**Issue:** [#82](https://github.com/rmsharp/nprcgenekeepr/issues/82) -- "Report sampling uncertainty (SE)
for founder genome equivalents (`fg`)". Split off from #2 (RATIFIED deferral S196; #2 plan
`docs/planning/issue2-gva-iteration-convergence-plan.md` D6 / Finding 5 / Dragon #9). Issue #2 is CLOSED.

**How this plan was built:** evidence-based inventory + a 3-way independent delta-method derivation panel +
an adversarial math reconciliation (workflow `wf_8672ccdd-2bf`, S203, ultracode), cross-checked against an
independent hand-derivation by the session author. The reconciler verified the gradient by finite
differences against `R/calcFG.R` on `lacy1989Ped` and **empirically validated the recommended estimator**
(agreement ratio mean(SE)/sd_emp = 1.020, 95% coverage = 0.953, 1/sqrt(K) scaling = 1.94 on `lacy1989Ped`).
Confidence: high on the math; the open items are the surfacing scope and the degeneracy policy (Section 5).

---

## 1. Context

### Problem

`FG` (founder genome equivalents) is a Genetic Value Analysis statistic reported to colony managers. Like
genome uniqueness (`gu`, whose sampling SE issue #2 Slice 1 added as `guSE`), `FG` is a **Monte Carlo
estimate** built from the gene-drop allele table: it reuses the same `geneDrop()` iteration columns, so it
carries sampling noise that shrinks as the number of iterations `K` grows. Today `FG` is displayed as a bare
number with no uncertainty. Issue #82 asks for its sampling SE so the reported `FG` can be shown as
`FG +/- SE`.

### Why this needed its own issue (the #2 deferral)

`gu`'s SE was a clean variance-of-a-mean: `guSE = 100 * sqrt(var(per-iteration rare proportion) / K)`
(`R/calcGUSE.R:62`). `FG` is **not** a mean -- it is a **nonlinear functional** of the random per-founder
retention vector:

```
FG = 1 / sum_f ( p_f^2 / r_f )
```

so a sound SE needs a **delta-method (linearization) derivation** -- different machinery from the `gu`
column-variance SE -- plus **validation against multi-seed replicate runs before exposure** (issue #82 scope;
#2 D6). A naive batch SE of per-iteration `FG` values is **degenerate** (Section 2.4) and must not be used.

### Constraints (hard)

- **Reversible vs locked:** `calcFG`/`calcFEFG`/`calcFE`/`calcRetention`/`calcFounderContributions` are
  exported public API. The point-estimate values (`FG`, `FE`, `r`, `p`) must NOT change (golden-master). A
  new SE rides additively, exactly as `guSE` did beside `gu`.
- **Strict TDD** for all code slices (RED -> GREEN -> REFACTOR, gated; declare phase every response).
- **Build-equivalent:** `devtools::check(vignettes = FALSE)` = 0 errors / 0 warnings / 0 notes; full test
  suite green; `spell_check_package(".")` = 0 (a 0/0/0 check does NOT imply spelling-clean, Learning 175).
- **Determinism:** TDD tests must be fast, isolated, deterministic. Prefer crafted allele tables (built
  directly, the `calcGUSE`/`ped1Alleles` pattern) and the column-doubling trick over a seeded `geneDrop()`.
- **Documentation:** per owner direction carried from #2 (D5/2F), the estimation technique must be explained
  in user-facing documentation accessible from the UI where the estimate is displayed
  (`inst/extdata/ui_guidance/genetic_value.html`), not only in roxygen/`man`.

### Interactions

`p` (founder contributions, `calcFounderContributions()`) is **deterministic** -- a pure function of the
pedigree, no RNG, no alleles (verified: `R/calcFounderContributions.R:26-70`; no `set.seed`/`sample`/`runif`;
Mendelian 1/2 propagation `d[ego,] = (d[sire,] + d[dam,])/2`; `test_calcFounderContributions.R` asserts
factor/character invariance). Therefore **`FE = 1/sum(p^2)` has no sampling SE -- only `FG` does**, entirely
through `r`. Do NOT add an `feSE`.

---

## 2. The mathematics (verified, high confidence)

### 2.1 Structure of the random input `r`

`calcRetention()` (`R/calcRetention.R:37-44`) builds, for each founder allele copy, a per-iteration 0/1
indicator (`founders$allele %in% descendant-alleles-of-column-k`), then averages over the `K` iteration
columns (line 40, `rowSums/ncol`) and over the founder's two allele copies (line 43, `tapply(..., mean)`).
So for founder `f`:

```
r_f = (1/K) * sum_{k=1..K} Y_{f,k},   Y_{f,k} in {0, 0.5, 1}
```

where `Y_{f,k}` is founder `f`'s per-iteration retention (mean of its two copies in iteration `k`). The `K`
iterations are **i.i.d.** (each `geneDrop()` column is an independent draw; `chooseAlleles` samples per
column). Within a single iteration the founders' `Y_{.,k}` are **correlated** (one shared gene drop). So with
`Sigma` the within-iteration founder covariance matrix (F x F):

```
E[r-bar] = mu (true retentions),   Cov(r-bar) = Sigma / K    (EXACT, not an approximation)
```

### 2.2 Gradient (verified by finite differences against `R/calcFG.R`)

With `S = sum_f p_f^2 / r_f` and `FG = 1/S` and `p` fixed:

```
dFG/dr_f = -(1/S^2) * dS/dr_f = -(1/S^2) * (-p_f^2 / r_f^2) = FG^2 * p_f^2 / r_f^2
```

Strictly positive (more retention raises FG), with a `1/r_f^2` pole as `r_f -> 0` (Section 2.4). Finite-diff
check on `lacy1989Ped`: closed form `[1.18444, 1.18760, 0.53710]` vs numeric `[1.18443, 1.18760, 0.53710]`,
agreeing to 5 decimals.

### 2.3 Variance -- delta method, full within-iteration covariance (the influence form)

```
Var(FG) ~= grad' (Sigma / K) grad,    grad_f = FG^2 * p_f^2 / r_f^2
```

The only approximation is the delta linearization; `Cov(r-bar) = Sigma/K` is exact. **The within-iteration
covariance is required** -- a diagonal/independence approximation is NOT defensible for production. Off-diagonals
are typically negative (founders compete for a finite set of descendant gene copies; contributions sum to 1),
and because the gradient weights are all positive, the diagonal-only SE is generally an **overestimate** (but
not guaranteed-conservative: positive covariance can occur within a shared lineage). Measured cost of the
diagonal approximation: ~3% on `lacy1989Ped` (only 3 highly-retained founders -- too small to bless the
approximation) vs **~46%** on a deep 20-founder pedigree. **Always use the full form; validate the cost on a
real deep pedigree, never on `lacy1989`.**

### 2.4 Why a per-iteration `FG_k` is degenerate (the trap to avoid)

A naive batch estimator -- compute `FG_k = 1/sum_f(p_f^2 / Y_{f,k})` for each column `k`, take
`sqrt(var(FG_k)/K)` -- is **wrong**. In a single iteration a founder allele is frequently lost
(`Y_{f,k}=0`), so `p_f^2 / 0 = Inf -> S = Inf -> FG_k = 0`. Essentially every iteration collapses to 0;
the "batch" is degenerate and also Jensen-biased. **Never compute a single-column `FG`.** The linearization
in 2.3 avoids this because it divides by `r-bar_f` (the K-mean, bounded away from 0 when the founder is ever
retained), not by the per-iteration `Y_{f,k}`.

### 2.5 Recommended estimator -- the influence/score form

Algebraically identical to the sandwich in 2.3 but `O(K*F)`, numerically stable, and it never forms or
inverts the F x F covariance (robust when `F > K`). It folds in ALL cross-founder covariance automatically.
This is the natural generalization of the `calcGUSE` "per-iteration value, take var/K" pattern -- continuity
with #2.

Recipe (per pedigree), all names ALIGNED BY FOUNDER ID (see Dragon D-3):

```
1. fc   <- calcFounderContributions(ped, "calcFG"); pedc <- fc$ped
   f0   <- getFounders(pedc); desc <- pedc$id[pedc$population & !(pedc$id %in% f0)]
2. fdf  <- alleles[alleles$id %in% f0,  c("id","V1")]              # founder allele labels (colnames id,allele)
   alD  <- alleles[alleles$id %in% desc, !(colnames(alleles) %in% c("id","parent"))]
   retmat <- apply(alD, 2L, function(a) fdf$allele %in% a); storage.mode(retmat) <- "numeric"
3. R    <- rowsum(retmat, fdf$id) / 2          # F x K matrix in {0,0.5,1}; rowMeans(R) == calcRetention() exactly
   rhat <- rowMeans(R)
4. p    <- fc$p[names(rhat)]                    # ALIGN BY NAME (r is id-sorted; p is getFounders-ordered)
5. keep <- !is.na(rhat) & rhat > 0 & !is.na(p) # same founder set the FG point estimate uses (Section 2.6)
   S    <- sum((p[keep]^2) / rhat[keep]);  FG <- 1 / S
6. g    <- numeric(length(rhat)); g[keep] <- FG^2 * (p[keep]^2) / (rhat[keep]^2)
7. y_k  <- as.numeric(crossprod(g, R))         # length-K influence series
   fgSE <- sd(y_k) / sqrt(K)                    # == FG^2 * sqrt(v' Sigma v / K), v_f = p_f^2/r_f^2
```

**Mandatory cross-check:** a column-bootstrap (resample the `K` columns of `R` with replacement, B >= 2000,
recompute `FG` per resample guarding non-finite, `SE_boot = sd(finite reps)`, report dropped fraction).
Large delta-vs-bootstrap disagreement flags a small-`r_f` founder where the linearization is failing -- block
exposure until resolved (raise `K`). The bootstrap is also the value to REPORT when retention is thin.

### 2.6 Degeneracy handling (three cases)

1. **`p_f = 0`** (founder not in current population): term is `0/0 = NaN`, dropped by `na.rm`; gradient 0.
   Harmless -- ensure `keep` drops exactly these so the SE refers to the same `FG` the point estimate reports.
2. **`r_f = NA`** (founder missing from retention / alignment mismatch): drop via `keep` to mirror calcFG's
   `na.rm`.
3. **`r_f = 0` with `p_f > 0`** (a contributing founder retained in ZERO of K drops): **this is a genuine
   latent bug in `calcFG`/`calcFEFG`** -- `p_f^2/0 = +Inf`, `na.rm` removes only `NaN` not `Inf`, so `S = Inf`
   and **`FG` silently collapses to 0**. The delta gradient is the `0*Inf` indeterminate form and the
   linearization is invalid at the pole. MUST detect `any(p > 0 & rhat == 0)` BEFORE computing FG or SE, and
   (a) report FG/SE as degenerate (`NA`) with a warning, and (b) advise raising `K` / flag the under-sampled
   founder. **Never emit a finite SE for a collapsed FG.** This case is materially likelier at the new
   default `K = 1000` than at the old `K = 5000` (see Dragon D-1).

   For near-zero but nonzero `r_f` (small effective count `n_f = K*r_f`, say < ~5-10): FG's sampling law is
   right-skewed and the first-order delta SE under-covers; prefer the column bootstrap in that stratum and
   flag it (the bootstrap itself degrades at `n_f ~ 1-3`). An optional documented continuity floor
   `r_f = max(r_f, 1/(2K))` removes the `Inf` but perturbs FG; the preferred remedy is raising `K`.

### 2.7 Caveat to document (not part of the SE)

`FG = g(r-bar)` is a biased estimate of `g(mu)` by `O(1/K)` (Jensen / finite-K bias), which the SE does not
capture. Note this alongside the SE at small `K`.

---

## 3. Key findings (from the S203 research)

| # | Finding | Evidence | Consequence for the plan |
|---|---------|----------|--------------------------|
| F1 | **`FG`/`FE` ARE surfaced today**, so the SE has an existing home. | `reportGV.R:236-237` returns scalars `fe`/`fg`; `modGeneticValue.R:312-324` GV-tab summary rows; `modSummaryStats.R:589-608` founder HTML table; `summary.nprcgenekeeprErr.R:212,229` text report; `makeFounderStatsTable.R:60-84` HTML founder table. | Slice 3 threads `fgSE` into each of these, mirroring `guSE`. |
| F2 | **`FG` is a single colony-level SCALAR**, not a per-animal vector like `gu`/`guSE`. | One number per pedigree (`calcFEFG.R:52`). | The SE is ONE number. **No** `orderReport` pass-through, **no** per-animal report column, **no** issue-#76 per-animal zeroing -- the largest divergence from the `guSE` wiring. Display as `FG +/- SE` (or a sibling "FG SE" row), not a column. |
| F3 | **`p` is deterministic; only `r` is stochastic.** | `calcFounderContributions.R:26-70` (no RNG); `test_calcFounderContributions.R`. | SE comes entirely from `Var(r)`; `FE` gets no SE. |
| F4 | **Latent silent-collapse bug in `calcFG`/`calcFEFG`** when `r_f=0 & p_f>0`. | `calcFG.R:61`, `calcFEFG.R:52` (`na.rm=TRUE` strips `NaN` not `Inf`). | Section 2.6 case 3. Decide (D2) whether to guard the point estimate within #82. Likelier at K=1000. |
| F5 | **The degeneracy path has no fast deterministic fixture.** | Only `examplePedigree+focalAnimals` reaches `r_f` small/zero, and only via a slow 3694-row seeded gene drop with no bundled allele table. `lacy1989` (r~0.75, 3 founders), the half-sib web (r 0.93-0.98), and `qcPed` (r 0.5-1.0) never reach it. | Slice 1 must CRAFT a tiny allele table (built directly, not via `geneDrop`) with one `p_f>0,r_f=0` founder and one `p_f=0,r_f=0` founder (D5). |
| F6 | **Founder-order misalignment risk.** | `r` is `tapply`-sorted by id; `fc$p` is `getFounders`/`colMeans`-ordered; `calcFG` combines them by `/` (POSITION, recycling). | Align `p`, `rhat`, and rows of `R` by founder NAME everywhere (Dragon D-3). Factor-vs-character peds can reorder founders. |
| F7 | **Doc drift:** `calcFG.R`/`calcFEFG.R` examples still build alleles at `n=5000`; default is now 1000. | `calcFG.R:46`, `calcFEFG.R:41`. | SE scales `1/sqrt(K)`, so reported SE is ~sqrt(5)=2.24x larger than under the old default. Update examples in the relevant slice; surface SE next to FG. |

---

## 4. Evidence-based inventory (grep, S203 -- exhaustive)

**Grep caveat (record for the executor):** `git grep -niE '\bfg\b'` returns ZERO hits because POSIX ERE
does not honor `\b` (treats it as backspace). Use `git grep -niwE 'fg'` (the `-w` word flag) -- that is what
surfaced the ~60 real `fg`/`FG` token sites. A plan trusting the bare `\bfg\b` ERE result would be empty.

### 4.1 Compute chain (the machine)

| File:lines | Role |
|---|---|
| `R/calcFEFG.R:45-53` | **Live FG path** (`reportGV.R:192` is the only internal caller). `list(FE=1/sum(p^2), FG=1/sum(p^2/r, na.rm=TRUE))`. Natural place to also return `FG_SE` (has `p` and `r` in scope), or call a sibling. |
| `R/calcFG.R:55-62` | Exported standalone `FG`; no internal caller (public script API). Mirror target / sibling home for `calcFGSE`. |
| `R/calcRetention.R:24-45` | **The SE source.** `r` = per-founder mean over columns; the per-iteration `retained` matrix (lines 37-39, before the line-40 mean) is the analogue of `calcA`'s per-iteration rare matrix that `calcGUSE` taps. `calcFGSE` must rebuild or expose it. |
| `R/calcFounderContributions.R:26-70` | `@noRd` helper; deterministic `p`. |
| `R/calcFE.R:42-45` | Deterministic `FE`; **no SE** (contrast). |
| `R/getFounders.R:27-30`, `R/isFounder.R:18` | Founder identification (deterministic). |

### 4.2 Report / display surfaces (where `fgSE` must appear -- Slice 3)

| File:lines | Role |
|---|---|
| `R/reportGV.R:192, 236-238` | `feFg <- calcFEFG(...)`; returns `fg = feFg$FG`. Add `fgSE` here, document in `@return` (`reportGV.R:14-27`). Do NOT cbind into `finalData` and do NOT add to `$gu` (FG is not per-animal). |
| `R/modGeneticValue.R:312-324, 381-391` | GV-tab summary rows "Founder Equivalents (FE)" / "Founder Genome Equiv. (FG)" from `fullRes$fe/$fg`; `founderStats` reactive re-exports. Add `fgSE` from `fullRes$fgSE` (NO `max()` -- it is already scalar). |
| `R/modSummaryStats.R:585-609` | Summary-Statistics founder HTML table (FE/FG columns) fed by `founderStats()`. |
| `R/summary.nprcgenekeeprErr.R:205-231` | Text report "Founder Genome Equivalents: <fg>". Add `(SE <fgSE>)`. |
| `R/makeFounderStatsTable.R:60-84` | Exported HTML founder-stats table; dedicated FG cell. |
| `inst/extdata/ui_guidance/genetic_value.html:9-31` | Plain-language `+/-` explanation (the wording template). Add a parallel FG note (D6). |

### 4.3 The `guSE` precedent to mirror (issue #2 Slice 1)

`R/calcGUSE.R` (new estimator) + `NAMESPACE` export + `inst/_pkgdown.yml` (2 blocks) + `R/reportGV.R:160-163,226`
(compute + de-inflate) + `R/reportGV.R:15-27` + `man/reportGV.Rd` + `R/modGeneticValue.R:293-308` (display) +
`tests/testthat/test_calcGUSE.R` (unit) + `tests/testthat/test_reportGV.R:363-398` (integration). The `fgSE`
slices replicate this set MINUS the per-animal-only points (orderReport ride-through, $gu column, issue-#76
zeroing, gvSummary `max()` reduction) -- see F2.

### 4.4 Tests + fixtures

| Fixture | Shape | Suitability for `fgSE` |
|---|---|---|
| `lacy1989Ped` + `lacy1989PedAlleles` | 7 animals, 3 founders, 4 desc; bundled 5000-col allele table; r~0.75 (uniform); FG=2.18 (Lacy published). | **BEST correctness/determinism anchor** (no test-time gene drop, no seed; column-doubling K->2K trick applies). WEAK: uniform r, never exercises degeneracy. |
| `qcPed` (no bundled alleles) | 280 animals, 124 founders; r in 0.5-1.0; FG~52.8 at K=1000 seed 1. | GOOD "SE positive and varies" case with real retention variance, but needs a seeded gene drop; no degeneracy. |
| `examplePedigree`+`focalAnimals` | 3694 animals; among `p>0` founders r 0.02-0.99 (6 with r<0.10); 1466 `p==0,r==0` (NaN). | The ONLY existing fixture hitting BOTH degeneracy branches; large/slow/seeded -- a slower integration/robustness guard, not a unit test. |
| `pedWithGenotype` + `pedWithGenotypeReport` | qcPed shape + genotypes; bundled report at `guIter=10000`. | reportGV INTEGRATION anchor. |
| `makeConvergenceFixture()` (in `test_gvaConvergence.R`, not exported) | 29 founders, 70 probands, 1 generation; r 0.93-0.98. | Deterministic scaffold but r clustered near 1 -- poor for SE (low variance, no degeneracy) unless retuned. |
| `ped1Alleles` | orphan allele table, 4 cols, no matching ped. | **UNSUITABLE** (fgSE needs a pedigree; calcGUSE could use it because gu needs none). |

**Test gaps:** (G1) no fast deterministic fixture for the degeneracy path -- craft one (D5); (G2) realistic
peds have no bundled allele table -> seeded/slow, conflicting with TDD determinism -> craft a small fixed
allele table or use the column-doubling trick on `lacy1989PedAlleles`; (G3) no deterministic mid-range-`r`
fixture for the "SE shrinks with K" test; (G4) no report-level `fgSE` coverage yet; (G5) document that
`ped1Alleles` is not usable.

---

## 5. Decisions to ratify (owner) -- BEFORE Slice 1

| # | Decision | Recommendation | Why |
|---|----------|----------------|-----|
| **D1** | Estimator. | **Influence/score-form delta method (full within-iteration covariance) as production primary; column-bootstrap as a mandatory pre-exposure cross-check and the reported value when retention is thin.** | 2.3-2.5; verified + empirically validated; `O(K*F)`; mirrors `calcGUSE`. Diagonal approximation rejected (2.3). |
| **D2** | The latent `calcFG`/`calcFEFG` silent-collapse bug (F4 / 2.6 case 3). | **Fold the guard into #82, as the first action of Slice 1** -- detect `any(p>0 & r==0)` in `calcFG`/`calcFEFG`, return `NA` + warning instead of a silent 0. (Alternative: split into its own bug issue.) | The SE path must detect this case regardless, and the SE and point estimate must agree on the founder set. Shipping an SE beside a silently-wrong `FG=0` would be worse. Tightly coupled -> same slice. |
| **D3** | Where to surface the SE. | **Everywhere FG is shown:** `reportGV()` return + GV-tab summary + Summary-Statistics founder table + text `summary()` + `makeFounderStatsTable` HTML + the in-app guidance note. Display format: `FG +/- SE` inline (owner picks inline vs a separate "Founder Genome Equiv. SE" row). | F1/F2; one consistent story (the #2 D5 principle: explain the estimate where it appears). |
| **D4** | Degeneracy / thin-retention policy. | Report `FG`/`fgSE` as `NA` + warning when `any(p>0 & r==0)`; flag the small-`r_f` skew stratum and prefer the bootstrap there; advise raising `K`. Ratify the effective-count threshold (proposed `n_f = K*r_f < ~5-10` triggers the bootstrap-preferred flag). | 2.6; protects against a confident-but-wrong SE. |
| **D5** | Build a crafted deterministic fixture for the degeneracy + mid-range tests. | **Yes** -- a tiny pedigree + a hand-built allele table (the `calcGUSE`/`ped1Alleles` pattern) with one `p_f>0,r_f=0` founder and one `p_f=0,r_f=0` founder, plus a mid-range-`r` case. | F5/G1/G3; the riskiest path (the `1/r_f^2` pole) otherwise has no fast RNG-free test. |
| **D6** | User-facing documentation of the FG SE. | Add a plain-language note to `genetic_value.html` (FG is a gene-drop estimate; the `+/-` is its sampling SE, shrinks ~1/sqrt(iterations); shown on the Summary tab; distinct from ranking stability) and reconcile the parallel surfaces (`manual_components/_summary_statistics.Rmd`, `population_genetics_terms.html`, `summary_stats.html`). Note the finite-K Jensen caveat (2.7). | #2 D5/2F precedent; owner direction that the technique be explained where displayed. |

A separate scope/approach `AskUserQuestion` will pose D1-D6 for ratification before the executor declares RED
on Slice 1 (mirrors #2 Section 8).

---

## 6. Implementation plan -- vertical slices (one session each)

Each slice is one session under strict TDD; "if I stop here, something works" holds for each (FM #25).
Expect **4 sessions minimum** for the implementation (Slice 1 + Slice 2 + Slice 3 + a publish session), plus
this planning session.

### Slice 1 = the SE estimator + degeneracy guard + crafted fixture (the math core)

- **Pre-RED:** confirm D1/D2/D4/D5 ratified. Read `R/calcGUSE.R`, `R/calcRetention.R`, `R/calcFG.R`,
  `R/calcFEFG.R`, `R/calcFounderContributions.R`, `tests/testthat/test_calcGUSE.R` firsthand.
- **RED (tests only):** new `tests/testthat/test_calcFGSE.R` --
  (a) **exact value:** on `lacy1989Ped`+`lacy1989PedAlleles`, `calcFGSE` equals an INDEPENDENT recompute of
  the influence-form SE (no reuse of the implementation's helpers; the `calcGUSE` test pattern);
  (b) **deterministic shrinkage:** the column-doubling trick (K->2K by duplicating the bundled allele
  columns) gives the RNG-free factor on the SE (analogue of `calcGUSE`'s `sqrt((K-1)/(2K-1))`);
  (c) `fgSE >= 0`; scalar; finite when retention is healthy;
  (d) **founder-order alignment:** factor vs character pedigree give the same `fgSE` (Dragon D-3);
  (e) **degeneracy (crafted fixture, D5):** a `p_f>0,r_f=0` founder -> `calcFGSE` returns `NA` + warning (NOT
  a finite number); a `p_f=0,r_f=0` founder is dropped cleanly; SE refers to the same founder set as FG;
  (f) **bootstrap agreement:** on a mid-range-`r` crafted fixture, `fgSE` (delta) agrees with a column
  bootstrap within tolerance;
  plus a guard test in `test_calcFG.R`/`test_calcFEFG.R`: `any(p>0 & r==0)` -> `FG = NA` + warning, not 0
  (D2). All RED tests fail for the right reason; golden-master `FG`/`FE`/`r`/`p` on `lacy1989`/`qcPed`
  UNCHANGED.
- **GREEN:** `R/calcFGSE.R` (influence form, Section 2.5) returning one number (the colony FG SE); the
  crafted fixture(s); the degeneracy guard in `calcFGSE` and in `calcFG`/`calcFEFG` (D2);
  `@export` + `NAMESPACE` + `man/calcFGSE.Rd` + `inst/_pkgdown.yml`. Update the `calcFG`/`calcFEFG` `@return`
  + the stale `n=5000` examples (F7).
- **DONE:** an exported `calcFGSE()` correct on `lacy1989` (matches independent recompute), shrinking
  ~1/sqrt(K) deterministically, guarding both degeneracy branches; `calcFG`/`calcFEFG` no longer silently
  collapse. **Not yet surfaced to users.**
- **Verify:** `devtools::check(vignettes = FALSE)` = 0/0/0; full regression green; `spell_check_package(".")`
  = 0; golden-master FG/FE unchanged.
- **Session boundary:** STOP. Here be dragons: the influence-form alignment (D-3) and the `r_f=0` pole (D-1).

### Slice 2 = multi-seed validation study (the "validate before expose" gate)

- **Deliverable:** a validation harness implementing the Section 2 / reconciler protocol on BOTH
  `lacy1989Ped` (fast, deterministic) AND a real deep pedigree (`examplePedigree`+`focalAnimals`, or `qcPed`
  with a fixed seed list) -- because `lacy1989` cannot exercise covariance or skew. At K=1000:
  (1) B >= 300 independent non-overlapping seeds, each -> `(FG_b, SE_b)`;
  (2) **agreement:** `mean_b(SE_b)` vs `sd(FG_1..FG_B)` (Monte Carlo truth); pass ratio ~ [0.92, 1.08]
  (band ~ 1/sqrt(2(B-1)));
  (3) **coverage:** fraction of `FG_b +/- 1.96*SE_b` covering a high-K reference FG ~ 0.95; pass [0.93, 0.97];
  (4) **1/sqrt(K) scaling:** rerun at K and 4K; both empirical sd and delta SE halve; pass [1.8, 2.2];
  (5) **degeneracy audit:** fraction of runs with `any(p>0 & r==0)` must be ~0 to expose;
  (6) **off-diagonal materiality:** report `seFull` vs `seDiag` on the REAL pedigree (document the cost
  there, per 2.3 -- not on lacy);
  (7) **bootstrap cross-check:** column-bootstrap SE agrees with delta SE; large disagreement blocks
  exposure (raise K).
  Output: a committed validation report (a `vignettes/articles/` article or a `data-raw/`-style script with
  recorded results) with the numbers and an explicit PASS/FAIL.
- **DONE:** documented evidence the SE is calibrated on a real pedigree; if any check fails, STOP and revisit
  Slice 1 (do NOT proceed to surfacing). (Note: the S203 reconciler already passed (2)-(4) on `lacy1989`:
  ratio 1.020, coverage 0.953, scaling 1.94 -- Slice 2 extends this to a real deep pedigree + (5)-(7).)
- **Verify:** the harness runs; deterministic where it can be (fixed seed list); the report renders.
- **Session boundary:** STOP. This slice is the owner's gate: no surfacing until it passes.

### Slice 3 = surface `FG +/- SE` (report + Shiny + text + HTML) + guidance doc

- **Deliverable:** thread `fgSE` into `reportGV()`'s return next to `fg` (`reportGV.R:236-238`, `@return`
  `14-27`); display in `modGeneticValue` gvSummary, `modSummaryStats` founder table, `summary.nprcgenekeeprErr`
  text, and `makeFounderStatsTable` HTML, per D3; add the plain-language FG-SE note to `genetic_value.html`
  and reconcile the parallel doc surfaces (D6). Integration test mirroring `test_reportGV.R:363-398`
  (`fgSE` present, numeric, scalar, `>= 0`) and a `modGeneticValue`/`modSummaryStats` display assertion. NEWS
  bullet (folds into the publish PR, Learning 157a -- separate session).
- **DONE:** wherever `FG` is shown, its sampling SE is shown; the guidance explains it; one consistent story;
  all existing signatures and values unchanged (additive).
- **Verify:** check 0/0/0; `spell_check_package(".")` = 0; vignettes render; **Phase-3E runtime smoke**:
  launch the app, confirm `FG +/- SE` renders in the GV tab and Summary-Statistics tab with the guidance text.
- **Session boundary:** STOP. The merge of Slice 3 (via a publish session) addresses #82's "surface it" and
  closes the issue.

### (No Slice 4.) The point estimates, fixtures, and contracts are otherwise unchanged.

---

## 7. Cross-slice notes

- **The SE math is the load-bearing risk; Slice 1 must nail it and Slice 2 must validate it on a real
  pedigree before Slice 3 exposes anything.** This ordering (compute -> validate -> surface) is the issue's
  explicit "validate before exposing" requirement (#82 scope).
- **Additive, golden-master discipline:** `FG`/`FE`/`r`/`p` values never change; the SE rides beside them.
  Pin a golden-master `FG`/`FE` on `lacy1989`/`qcPed` before vs after each slice.
- **Reuse one gene drop:** in `reportGV`, `fgSE` must be computed from the SAME `geneDrop()` run that
  produces `fg` (as `guSE` reuses `gu`'s alleles), not a fresh draw.
- **Determinism:** prefer crafted allele tables + the column-doubling trick over seeded gene drops in unit
  tests; reserve seeded runs for the Slice 2 validation harness.

## 8. Here be dragons (consolidated load-bearing risks)

| # | Dragon | Guard |
|---|--------|-------|
| **D-1** | **`r_f = 0, p_f > 0` silent collapse** (`calcFG` returns 0; SE gradient undefined). Likelier at K=1000. | Detect `any(p>0 & r==0)` before computing FG/SE; return `NA` + warning; raise K. Crafted fixture (D5). |
| **D-2** | **Never compute a per-iteration `FG_k`** -- it is degenerate (collapses to 0 most iterations) and Jensen-biased. | Use the influence form (2.5); the RED tests must not encode a per-iteration batch SE. |
| **D-3** | **Founder-order misalignment:** `r` is id-sorted (`tapply`), `p` is `getFounders`-ordered; `/` aligns by position. | Align `p`, `rhat`, rows of `R` by founder NAME everywhere; test factor vs character ped equality. |
| **D-4** | **Diagonal/independence covariance approximation is wrong** (up to ~46% on a deep pedigree). | Always use the full/influence form; validate `seFull` vs `seDiag` on a REAL deep pedigree, not `lacy1989`. |
| **D-5** | **Validating only on `lacy1989` falsely blesses** the diagonal approx and linearization (tiny off-diagonals, all founders well-retained). | Slice 2 MUST include a real deep/bottlenecked pedigree with low-contribution founders. |
| **D-6** | **Small effective-count skew** (`n_f = K*r_f` small): delta SE under-covers a right-skewed law silently. | Flag the stratum; prefer the bootstrap (which itself degrades at `n_f ~ 1-3` -- report dropped fraction); raise K. |
| **D-7** | **Conditioning when `F > K`:** an explicit `cov(t(R))` sandwich is rank-deficient. | The influence form never forms the F x F matrix -- use it (don't build the sandwich). |
| **D-8** | **RNG independence assumption:** the math needs independent columns (confirmed: `chooseAlleles` samples per column) and the validation needs non-overlapping seed streams. | Use distinct seeds in Slice 2; any shared/correlated RNG makes `Cov(r-bar)=Sigma/K` wrong. |
| **D-9** | **Doc drift:** `calcFG`/`calcFEFG` examples build at `n=5000`; default is 1000; SE is ~2.24x larger now. | Update examples (F7); surface SE next to FG; explain `1/sqrt(K)` (D6). |
| **D-10** | **`grep` for `fg`:** POSIX ERE `\b` fails. | Use `git grep -niwE 'fg'` (Section 4 caveat). |
| **D-11** | **Latent upstream doc bug** `assignAlleles.R:18` ("Default is 5000" while `n` has no default) -- surfaces only if SE work touches gene drop. | Out of scope unless the SE work modifies `geneDrop`/`assignAlleles` (it should not need to). |

## 9. Owner ratification checklist

- [ ] **D1** estimator (influence-form delta + bootstrap cross-check)
- [ ] **D2** fold the `calcFG`/`calcFEFG` silent-collapse guard into Slice 1 (vs separate issue)
- [ ] **D3** surfacing scope + display format (`FG +/- SE` inline vs separate row)
- [ ] **D4** degeneracy / thin-retention policy + effective-count threshold
- [ ] **D5** build the crafted deterministic fixture
- [ ] **D6** user-facing documentation scope (which surfaces to reconcile)
- [ ] Confirm the slice count (4 sessions: Slice 1 + Slice 2 + Slice 3 + publish) and ordering
      (compute -> validate -> surface) is acceptable.

## 10. References

- Issue [#82](https://github.com/rmsharp/nprcgenekeepr/issues/82); issue #2 (CLOSED);
  `docs/planning/issue2-gva-iteration-convergence-plan.md` (D6, Finding 5, Dragon #9 -- the deferral;
  Slice 1 = the `guSE` precedent).
- Lacy, R.C. (1989) "Analysis of Founder Representation in Pedigrees: Founder Equivalents and Founder Genome
  Equivalents." *Zoo Biology* 8:111-123 (the `FE`/`FG` definitions; `lacy1989Ped` FG = 2.18).
- Code: `R/calcFG.R`, `R/calcFEFG.R`, `R/calcRetention.R`, `R/calcFounderContributions.R`, `R/calcFE.R`,
  `R/calcGUSE.R` (SE precedent), `R/reportGV.R`, `R/modGeneticValue.R`, `R/modSummaryStats.R`,
  `R/summary.nprcgenekeeprErr.R`, `R/makeFounderStatsTable.R`.
- Research: workflow `wf_8672ccdd-2bf` (S203) -- inventory, `calcGUSE` wiring trace, tests/fixtures, current
  FG surfacing, 3-way independent derivation panel, adversarial math reconciliation (verified by finite
  differences + empirical multi-seed validation on `lacy1989Ped`).
