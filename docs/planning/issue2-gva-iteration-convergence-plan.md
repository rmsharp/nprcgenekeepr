# Issue #2 Plan -- Evidence-based advice on the number of gene-drop iterations for the Genetic Value Analysis

**Status:** PLAN -- **Section 8 RATIFIED (Session 196, 2026-06-25).** Implementation slices are separate later
sessions (FM #18). **Slice 1 is unblocked.** All six §8 owner decisions are resolved (§8); the S195 empirical
claims were re-established firsthand in S196, correcting three factual errors (§2C, Findings 3-4) -- see
"§9A. Firsthand evidence (S196)".

**Issue:** [#2](https://github.com/rmsharp/nprcgenekeepr/issues/2) (OPEN since 2020-04-05) --
"Need to provide evidence based advice on number of iterations needed for Genetic Value Analysis."

> Come up with a definition of reproducible and see if we can run and automate the test to find the needed
> number of iterations. There is a relationship between variation between genetic value estimates and the
> number of iterations used to provide the estimates such that higher iterations provide smaller variation in
> the estimates.

**Research provenance:** Code map + prior-art scan (two `Explore` agents) and a 7-agent
investigate/design/critique workflow (`wf_fdb7c410-95f`); all load-bearing file:line anchors re-verified
firsthand in S195 (Section 9). The adversarial critique overturned two claims from the first design pass --
both corrections are folded in below (Section 3, "Here be dragons").

---

## 1. Context

### 1A. The premise is real (verified)

Genome uniqueness `gu` is the only ranked Genetic Value Analysis (GVA) output that carries Monte Carlo noise.
`calcGU` (`R/calcGU.R:95-100`) computes, for each animal `i`:

```
gu_i = 100 * rowSums(rare[i, ]) / (2 * K)
```

where `K` = number of gene-drop iteration columns `V1..VK` (`calcGU.R:96`) and `rare[i,k]` (from
`calcA`, `R/calcA.R:27-43`) = the count of animal `i`'s two allele-rows that are *population-rare*
(allele frequency `<= guThresh`) in iteration `k`. So `gu_i` is a Monte Carlo proportion, and the owner's
framing is exactly right: its precision is a function of (a) the number of iterations `K` -- the sampling
standard error shrinks like `1/sqrt(K)` -- and (b) pedigree structure, because each animal's underlying
rare-allele probability `p_i = gu_i/100` and the crowding near rank boundaries differ by pedigree. There is
no single universal "right" iteration count; the needed `K` is pedigree- (and threshold-) dependent.

Mean kinship is **deterministic** (`kinship()` solves the identity-by-descent recursion; `reportGV.R:110-117`)
and contributes zero Monte Carlo noise -- correctly out of scope. Founder genome equivalents `fg`
(`calcFEFG.R`) is **also stochastic** (it reuses the same gene-drop columns) -- see Section 3.

### 1B. The owner's steer, and what the code permits

The owner steered: *"the proper approach may be simply to report convergence rate during the calculation
phase."* The spirit is right and is adopted; the **literal** form (stream a running `gu` as animals are
processed inside `geneDrop`) is **not feasible**, for a concrete code reason:

- `calcA` decides which alleles are "rare" per iteration column from the **whole population's** alleles in
  that column (`calcA.R:33-36` -> `alleleFreq.R:30` `table(alleles)`). You cannot classify any animal's
  rare-allele indicator for iteration `k` until *every* animal has contributed its allele to column `k`.
- But `geneDrop`'s loop is **animals-outer**: for each animal it samples that animal's alleles across **all**
  `K` iterations at once (`geneDrop.R:127-145`; `assignAlleles.R:35,46`; `chooseAlleles.R:16-17`). At no
  point mid-loop does the code hold "iteration `k` for all animals" -- it holds "all iterations for one
  animal." The two axes are orthogonal to what streaming would need.

**The feasible realization that keeps the spirit:** because the `K` columns are i.i.d. gene-drop replicates,
the entire convergence picture is recoverable from the *single completed run the user already pays for* --
recompute `gu` on nested column prefixes `V1..Vk`, or read the per-column variance directly. This is a cheap
post-gene-drop pass, not `R` separate replicate runs, and not a re-architecture of `geneDrop`. That insight
(the "column-prefix subset" trick) is what makes Section 4's design both faithful to the steer and low-risk.

### 1C. Prior process history (do not re-run)

- **Never claimed.** Issue #2 appears as a standing backlog item in every recent session's "Other options"
  menu (`SESSION_NOTES.md`) but was never started.
- **Two June 2026 audits** classify it OPEN / not-implemented:
  `docs/audits/BACKLOG_STALENESS_AUDIT_2026-06-12.md:43,141` and
  `docs/audits/IMPLEMENTED_BUT_OPEN_AUDIT_2026-06-16.md:84`.
- **A verbatim TODO** lives in the tutorial vignette: `vignettes/ColonyManagerTutorial.Rmd:459-461`
  ("1000 iterations has seemed to provide reproducible results for our pedigrees ... pedigree structure is
  expected to affect precision when iterations are held constant") plus an HTML-commented restatement of the
  issue. The doc already half-states the owner's point, with **no study behind it**.
- **A related-but-different precedent:** `vignettes/simulatedKValues.Rmd` compares 10/100/1000 iterations for
  **kinship** estimation on the 17-animal toy `smallPed`, measuring spread via `sd` across replicates
  (`summarizeKinshipValues.R:115`). It is qualitative, toy-data, kinship (not `gu`), and defines no
  reproducibility criterion. Its comparison-table idiom (`simulatedKValues.Rmd:223-293`) is a reusable
  presentation pattern for the `gu` study; its statistics are not.

---

## 2. Evidence-based inventory (firsthand)

### 2A. The `gu` machinery (the surfaces a fix touches)

| Element | Location | Note |
|---|---|---|
| `gu = rowSums(rare)/(2*iterations) * 100` | `R/calcGU.R:95-100` | the Monte Carlo proportion |
| `rare[i,k]` per-column rare counts (`tapply(..., sum)`) | `R/calcA.R:27-43` | `apply(alleles, 2L, countRare)` -- column-oriented; this matrix is the raw material for both SE and the column-prefix trick |
| population frequency per column (`table`) | `R/alleleFreq.R:25-33` | the streaming blocker (whole population needed per column) |
| gene-drop loop (animals-outer, all `K` per animal) | `R/geneDrop.R:90,127-160` | `n = guIter`; returns `id,parent,V1..Vn` |
| `reportGV` signature + flow | `R/reportGV.R:93-219` | `guIter=5000L, guThresh=1L, byID=TRUE`; `geneDrop` at `:136-140`; `calcGU` at `:150`; final `cbind` at `:213-215`; returns `list(report=orderReport(...), kinship, gu, ...)` |
| `fg` (also stochastic) | `R/calcFEFG.R:51-52`; `R/calcRetention.R` | `FG = 1/sum(p^2/r)`, `r` from the same columns |

### 2B. The ranking pipeline (what "rank stability" must actually target)

The displayed rank is **not** a smooth score. `orderReport` (`R/orderReport.R:55-98`) buckets animals into
ordered groups, then `rankSubjects` assigns sequential integers and `rbind`s them:

```
imports -> highGu(gu > 10, ordered by -trunc(gu) then zScores) -> lowMk(zScores <= 0.25)
        -> lowVal(zScores > 0.25) -> noParentage(rank = NA)
```

So rank churn is driven by three **discontinuities**: the `gu > 10` cutoff (`orderReport.R:72`), each
integer-`trunc(gu)` step inside `highGu` (`:73`), and the `zScores <= 0.25` boundary (`:77`). Convergence
diagnostics must measure crowding near these, not generic Spearman. (The first design pass mis-described the
rank as `rank(indivMeanKin - gu)`; corrected here.)

### 2C. The issue #76 de-inflated `gu = 0` set (must be excluded from every metric)

`reportGV.R:205-211` sets `gu$gu[undetermined] <- 0.0` for both-unknown, no-recorded-origin animals **after**
`calcGU`; `rankSubjects` gives them `rank = NA` (the `noParentage` bucket). These zeros are a **policy
constant**, not a Monte Carlo estimate -- their SE is identically 0 and they are unrankable. Every
reproducibility metric must be computed on the rankable `gu > 0` subset, with the Undetermined count reported
separately.

**Firsthand correction (S196 -- the S195 numbers here were subagent-sourced and wrong).** On the bundled
`qcPed` the Undetermined set is **124 of 280** (NOT 156 -- 156 is the *rankable* count). More importantly,
firsthand (`reportGV(qcPed)` ground truth + `calcGU`/`calcA` at the defaults `guThresh=1, byID=TRUE`):
`{gu > 0}` == `{both-unknown founders}` == `{the issue #76 Undetermined set}` are the **identical 124 animals**
(`identical()` TRUE for both correspondences). Founders enter the gene drop with freshly minted private
alleles, so they carry *all* the genome uniqueness; every known-parentage animal inherits from the shared pool
and has `gu` exactly 0. So **after the issue #76 de-inflation every qcPed animal has `gu = 0`** (the 124
founders zeroed by policy, the 156 rankable already 0). `pedWithGenotype` and `rhesusPedigree` are the same.
Consequence: these pedigrees have **zero rankable `gu` signal**, so they cannot exercise a `gu`-based metric at
all (see Finding 4).

### 2D. The iteration-count default contradiction (84-hit inventory; key map)

The mandated grep inventory found **84 sites**; the load-bearing contradictions:

| Surface | Value | Location |
|---|---|---|
| `reportGV` / `geneDrop` function default | **5000L** | `R/reportGV.R:93`, `R/geneDrop.R:90` (+ `man/reportGV.Rd:9`, `man/geneDrop.Rd:13`) |
| Shiny GVA UI default | **1000L** | `R/modGeneticValue.R:38` (pinned by `tests/testthat/test_modGeneticValue.R:38`) |
| NEWS 2.0.0 claim | "default ... changed to **1000**" | `NEWS.Rmd:239`, `NEWS.md:254-255` |
| CHANGELOG | "5000 -> 1000 (monolith parity)" | `CHANGELOG.md:2205` |
| Example data built at | **10000** | `R/data.R:263,308`; `man/pedWithGenotypeReport.Rd:12,20`; `man/qcPedGvReport.Rd:19` |
| Example data built at | **5000** | `man/lacy1989PedAlleles.Rd:6,17,33` |
| Vignette guidance (stale) | "Default is 5000" | `vignettes/a2interactive.Rmd:367-368`, `vignettes/manual_components/_genetic_value_analysis.Rmd:26-27` |
| Vignette guidance (folklore) | "1000 ... seemed to provide reproducible results" | `vignettes/ColonyManagerTutorial.Rmd:459-461` |

**The contradiction is real and unresolved:** NEWS/CHANGELOG announce a `5000 -> 1000` change that **never
reached the function signature** (`reportGV.R:93` is still `5000L`); a normal scripting user gets 5000, a
Shiny user gets 1000, and the shipped example data used 5000/10000. (Out of scope but noted by the same
inventory: the breeding-group sim has a parallel `1000L` function vs `10L` UI split --
`R/groupAddAssign.R:124` vs `R/modBreedingGroups.R:59`, `CHANGELOG.md:2084`. Not part of #2; flag only.)

### 2E. Reproducibility infrastructure + behavior-pinning tests

- Seeding: `set_seed()` (`R/set_seed.R:19-28`, exported) and `gatedSeed("nprcgenekeepr.gva_seed",
  "NPRC_GVA_SEED")` (`R/set_seed.R:39-43`; called at `R/modGeneticValue.R:144-145`). No parallelism in the
  gene-drop path, so seeding is clean.
- Progress hook: `withProgress` + a custom `updateProgress` passed to `reportGV`
  (`R/modGeneticValue.R:147-158,202`); `incProgress(detail=)` accepts a free-text string, so an SE readout
  can ride the existing toast. Durable display would add a row to `gvSummary`
  (`R/modGeneticValue.R:269-306`).
- Tests pinning current behavior (TDD anchors / must-update): `test_reportGV.R:5,28,322` (uses `guIter`
  100L/1000L), `test_modGeneticValue.R:38` (UI default 1000L), `test_modGeneticValue.R:1529,1579`
  (stub signatures with `guIter = 5000L`).

### 2F. The in-app user-facing documentation surface (where the estimate is displayed)

The GVA tab renders a guidance panel **beside the results**, via
`includeHTML(system.file("extdata", "ui_guidance", "genetic_value.html"))` (`R/modGeneticValue.R:65-68`).
`inst/extdata/ui_guidance/genetic_value.html` is **hand-authored HTML** (not generated from any Rmd; no build
script references it) and currently says **nothing** about iterations, genome-uniqueness precision, or
standard error. It links to the longer "Genetic Value Analysis and Breeding Group Description" tab
(`inst/extdata/ui_guidance/gvAndBgDesc.html`, rendered by `R/modGvAndBgDesc.R:29`); term definitions live in
`population_genetics_terms.html` (surfaced via `R/modSummaryStats.R:222-224`, which already imports
`withMathJax`). A **parallel, separately-maintained** copy of this material exists as vignette/manual
components `vignettes/manual_components/_genetic_value_analysis.Rmd` and `_genome_uniqueness_algorithm.Rmd`
(the latter already explains the gene-drop and is one of the stale-"5000" sites in 2D). **Two documentation
surfaces must therefore stay consistent**: the in-app `inst/extdata/ui_guidance/*.html` (hand-authored) and the
vignette `manual_components/_*.Rmd`.

---

## 3. Key findings that shaped the design (and two corrections)

1. **`gu` is a Monte Carlo proportion; lead with the exact column-variance SE.** Let `m_ik = rare[i,k]/2`
   (per-column value), `phat_i = mean_k m_ik = gu_i/100`. The exact Monte Carlo SE is
   `SE(phat_i) = sqrt(var(m_i.)/K)` -- computed **from the actual per-column `rare` values**, so it is correct
   for any `byID` / `guThresh` automatically. The textbook `sqrt(phat(1-phat)/(2K))` is a cheap display
   approximation only.

2. **CORRECTION 1 -- drop the "homozygotes inflate SE by up to sqrt(2)" claim.** Empirically false at the
   default `guThresh = 1`: a rare allele has population frequency `<= 1` (one copy in the whole population),
   so a homozygote cannot carry one; per-column counts are effectively `{0,1}`. At `guThresh >= 2` the
   measured `SE_exact/SE_approx` ratio is `<= 1` (**confirmed firsthand S196: median 0.82 at `guThresh=2`, 0.85
   at `guThresh=3`; ~1.0 at the default `guThresh=1`**), i.e. the Bernoulli form slightly *over*-states. **No
   `(1+rho)` inflation of `N`.** (Structural note: a heterozygote carrying two *distinct*
   freq-1 alleles could in principle give count 2, which is another reason to compute SE from the real `rare`
   matrix rather than a closed form.)

3. **CORRECTION 2 -- the rank is a bucketed order statistic; rank fragility is boundary-density, not
   `1/sqrt(N)`.** The displayed rank sorts by `-trunc(gu)` then deterministic `zScores`, so an animal's rank
   only moves when its `gu` fluctuation crosses an integer-`trunc` (or the `gu=10`) boundary *and* that
   reorders it past a neighbour. Honest rank diagnostics count animals within `2*SE` of `gu = 10` and of each
   integer-`trunc(gu)` boundary; do **not** apply a Spearman-Brown smooth-reliability correction to a bucketed
   statistic. (Firsthand S196: on every bundled pedigree the max absolute rank change is **0** across `N` from
   5 to 2000 -- the gu-bearing animals are structurally separated, see Finding 4 -- so the S195 "5-8 positions"
   figure was wrong; the point that fragility is boundary-density-driven, not smooth, stands.)

4. **NO bundled pedigree can validate a rank-stability tool -- the dense fixture is mandatory (firsthand S196).**
   The S195 "qcPed is bimodal 55.7%/43%, 2-of-280 mid-range" description was wrong. The truth, verified
   firsthand across all 25 bundled datasets: `qcPed` / `pedWithGenotype` / `rhesusPedigree` have **zero**
   rankable `gu` signal (2C -- all rankable animals at `gu = 0`), so their selection order is pure deterministic
   mean-kinship. `examplePedigree` is the **only** bundled pedigree with rankable `gu > 0` (294 of 2322
   rankable; 271 at `gu > 10`; **only 7 in the `(1,10]` mid-range**, 2 within +/-2 of the `gu=10` cutoff), and
   even there the gu-bearing animals are structurally fixed (founder alleles at `gu = 100`/`50`), so **selection
   order is identical at `N = 5` and `N = 2000`** (top-20 overlap 1.0, max rank change 0). A `gvaConvergence()`
   run on any shipped pedigree would therefore tautologically "recommend" ~5 iterations. **A dense-mid-range
   fixture built in Slice 2 RED is the only way to produce a pedigree where iteration count actually moves the
   selection order** -- it is load-bearing, not optional (Dragon #2).

5. **`fg` is also stochastic** but is a nonlinear functional (`1/sum(p^2/r)`); a naive batch SE is a
   delta-method approximation. Either derive + validate it against multi-seed replicates, or defer `fg`
   uncertainty out of scope and say so. Do **not** assert "`fg` needs more iterations than `gu`" without
   evidence.

6. **Seed-reproducibility != estimate-precision.** `gatedSeed` already makes `gu` bit-identical run-to-run at
   a fixed seed (E2E determinism). That is orthogonal to Monte Carlo precision. The deliverable reports
   **sampling precision of the estimate**; it changes nothing about seeding. State this plainly so reviewers
   do not conflate "stable with a fixed seed" (already true) with "precise" (the actual question).

7. **The "cheap column-prefix" claim needs a small refactor to be true.** `calcGU` -> `calcA` re-tables
   population frequencies for every column on every prefix. Recomputing `gu` over a grid of nested prefixes
   re-tabulates early columns up to (grid-size)x. The fix the tool should adopt: factor the `rare`-matrix
   computation out of `calcA` once, then re-aggregate columns (`O(n*K)`, cheap) per prefix. Make this
   explicit or the "one simulation, several cheap passes" claim is false at the sizes that motivate the
   feature.

---

## 4. Design decisions (recommendations for owner ratification)

### D1 -- Definition of "reproducible" (selection-order primary; ratified S195)

**Owner decision (S195): selection order is the best measure of stability.** The application exists to rank
and select animals, so "reproducible" is defined on the **selection order** -- would the run lead to the same
animals chosen in the same order -- not on the precision of the `gu` number. Per-animal precision (SE) is
**demoted** to a displayed, explanatory diagnostic (D5), not the definition: **numeric precision is of
interest to the user and is shown, but it is of little value for breeder selection** (owner, S195) -- it
informs, it does not gate.

Declare a `gu` report **reproducible at `K` iterations** when, computed on the **rankable `gu > 0` subset**
(the issue #76 `gu = 0` "Undetermined" set excluded, 2C) and ordered by the actual `orderReport` pipeline
(2B), two independent half-runs agree on selection order:

- **(primary -- the selected set)** top-`k` overlap `>= o_min` between the two half-runs -- the same animals
  are chosen. Defaults **`k = 20`, `o_min = 0.90`** (`<= 2` of 20 may differ).
- **(primary -- the order of the selected)** a top-weighted rank-agreement measure on the decision-relevant
  animals (recommended: Kendall's tau-b, or Spearman restricted to the ranked `gu > 0` / top portion)
  `>= rho_min`, default **`rho_min = 0.95`** -- the chosen animals come out in the same order.
- Reproducible = **both** hold.

**Diagnostics (reported, not gating):** the per-animal `gu` SE (the displayed `+/-`, D5) -- it *explains* why
the order is or is not stable but no longer defines reproducibility; max absolute rank change among the top
animals; and the **boundary-fragility count** -- animals within `2*SE` of the `gu = 10` cutoff, an
integer-`trunc(gu)` step, or the `z <= 0.25` boundary (2B) -- the leading indicator of order instability.

**Stopping rule (Slice 2 `gvaConvergence()`):** raise `K` until selection order is stable (both primary
criteria) for the pedigree in hand.

**Honest properties of an order-based criterion** (so the executor is not surprised): (i) selection order is a
bucketed **step function**, so the needed `K` is driven by *boundary crowding*, not a smooth `1/sqrt(K)` curve
-- expect plateaus and jumps, not a clean decay (Finding 3); (ii) pure set overlap is binary at the cut line,
so a single near-tie animal at rank `k` vs `k+1` reads as a hard miss -- pairing it with the order-agreement
measure softens that; (iii) **no bundled pedigree** makes order non-trivial (all are stable at `N=5`, Finding 4),
so the order criterion can only be **validated** on the dense-mid-range fixture built in Slice 2 RED.

**Half-split soundness:** the `K` columns are i.i.d., so two disjoint halves are genuinely independent
estimates; compare the halves **to each other** (never to their own pooled mean -- spurious `-1.0`). A
`K/2`-vs-`K/2` split is **conservative** for the `K` run; no Spearman-Brown up-correction on a bucketed
statistic (Finding 3).

**RATIFIED (S196): order metric = Kendall's tau-b** (robust to the bucketed-rank ties), with provisional
thresholds **`k = 20`, `o_min = 0.90`, `rho_min = 0.95`**. Because no bundled pedigree can calibrate them
(Finding 4), these provisional values are **finalized against the dense-mid-range fixture in Slice 2 RED** --
they do not gate Slice 1, which carries no order metric.

### D2 -- Architecture: ship C first, then A; B out of scope (RATIFIED S196)

**RATIFIED (S196): ship C (Slice 1) then A (Slice 2); B out of scope.**

- **C (Slice 1) -- per-animal `guSE` column (additive, signature-stable).** Compute exact column-variance SE
  from the `rare` matrix `calcGU` already builds, carry a `guSE` column through `reportGV`'s `cbind`
  (`reportGV.R:213-215`) into `$report` and `$gu`, and add one "max `gu` SE" line to the Shiny `gvSummary`
  (`modGeneticValue.R:269-306`). No new dependency, no signature change, no change to `gu` values. This is the
  faithful, near-zero-risk realization of "report convergence (precision) for the run you already computed."
- **A (Slice 2) -- a `gvaConvergence()` diagnostic.** One `geneDrop` at `Nmax`, recompute `gu` (and the
  bucketed ranking) on nested column prefixes, report the D1 metrics vs `N` and a recommended `N`. A
  **diagnostic table**, not a silent default-changer. Requires the dense-mid-range fixture (Finding 4) and the
  `calcA` refactor (Finding 7).
- **B (streaming inside `geneDrop` + early-stop) -- OUT OF SCOPE.** Infeasible as literally framed (1B), and a
  forced version re-architects the most performance-critical function and breaks `geneDrop`'s documented
  `V1..Vn` return contract, the fixed-`N` example datasets, and the seeded tests. Revisit only if, after
  seeing C+A, the owner explicitly wants live early-stop and accepts that blast radius.

### D3 -- Reconcile the 5000/1000/10000 default contradiction (RATIFIED S196: align to 1000)

The deliverable must **resolve** 2D, or #2 gains a tool but stays "open."

**RATIFIED (S196): option (a) -- align the `reportGV`/`geneDrop` function default down to `1000L`** to match
the Shiny UI default and the NEWS/CHANGELOG claim; Slice 3 fixes every stale "5000" doc/man/vignette site
in 2D.

**Evidence basis (corrected, firsthand S196).** The S195 justification ("`qcPed` converges by `N ~ 250-500`;
worst-animal SE ~1.1pp at `N=1000`") was **vacuous** -- `qcPed`'s rankable set has no `gu` signal (2C), so
there is nothing to converge. The grounded evidence is from `examplePedigree` (the only bundled pedigree with
signal): selection order is stable well below 1000 (in fact at `N=5`, Finding 4), and the per-animal numeric SE
decays cleanly `~1/sqrt(N)` -- **0.79pp at `N=1000`, 0.56pp at `N=2000`, extrapolating ~0.35pp at `N=5000`**.
Since the owner ratified that **selection order** governs breeder choice and numeric precision is "of little
value for breeder selection" (D1), 1000 is comfortably adequate: it already gives sub-1pp numeric precision,
and 5000 buys only a marginally tighter `+/-` that has been explicitly deprioritized. The new
`gvaConvergence()` (Slice 2) is how a user checks an atypical pedigree of their own. Rejected: (b) keep 5000
(spends compute for deprioritized precision and leaves the UI/function split as a smaller mismatch); (c)
adaptive default (larger -- its own issue).

### D4 -- Scope of the SE/recommendation (RATIFIED S196)

**RATIFIED (S196): compute `guSE` from the real `rare` matrix (automatically correct for any `guThresh`/`byID`);
scope the iteration *recommendation* to the defaults while exposing the parameters.** `guSE` is computed from
the real `rare` matrix, so it is correct across `byID` and `guThresh` with no extra work. The *recommendation*
in A is `(pedigree, guThresh, byID)`-dependent; scope the headline claim to defaults and expose the parameters.
Exclude the de-inflated `gu = 0` set from every metric (2C). (Firsthand S196: `byID` makes **no** difference at
the default `guThresh=1` -- `byID=TRUE` and `FALSE` give identical `rare` sums -- so the default path is
`byID`-insensitive; `guThresh` does change the counts.)

### D5 -- User-facing in-app documentation of the estimate (owner requirement, S195; scope RATIFIED S196)

**RATIFIED (S196): Slice 1 updates the in-app `genetic_value.html` only**; the longer `gvAndBgDesc.html` and the
parallel vignette `manual_components` are reconciled in Slice 3 (keeps Slice 1 small and vertical).

Per owner direction: the estimation technique must be **documented and explained in the application's
user-facing documentation, accessible from the UI where the estimate is displayed** -- not only in
roxygen/`man`. The surface is the GVA tab's guidance panel `inst/extdata/ui_guidance/genetic_value.html`
(rendered in-app at `modGeneticValue.R:65-68`, 2F), with the longer treatment in `gvAndBgDesc.html` and
consistency kept in the parallel `vignettes/manual_components/_genome_uniqueness_algorithm.Rmd` /
`_genetic_value_analysis.Rmd`. Because the explanation must accompany the estimate **the moment it appears**,
the plain-language writeup ships **with Slice 1** (when `guSE` first shows in `gvSummary`), not deferred to
Slice 3. In colony-manager language it states: genome uniqueness is a Monte Carlo (gene-drop) **estimate**;
the reported `+/-` is its sampling standard error, which shrinks like `1/sqrt(iterations)`; the precision
needed depends on the pedigree (so there is no universal iteration count); and -- once Slice 2 lands -- how to
use `gvaConvergence()` to check a given pedigree. It must **distinguish two ideas** so they are not conflated:
**precision of the number** (the `+/-` -- of interest, informational) versus **stability of the selection
order** (what actually governs which breeders are chosen, reported by `gvaConvergence()`). A small `+/-` does
not by itself mean the selection is settled; that is what the order-stability check is for. Use `withMathJax` for any formula. **Split across slices:**
Slice 1 ships the short explanation in `genetic_value.html` (where the estimate is shown); Slice 3 reconciles
the longer `gvAndBgDesc.html` and the parallel vignette `manual_components` (including the stale-"5000" fix) so
both surfaces tell one story.

### D6 -- `fg` (founder genome equivalents) uncertainty (RATIFIED S196: deferred)

**RATIFIED (S196): `fg` SE is OUT OF SCOPE for #2 -- deferred to follow-up issue [#82](https://github.com/rmsharp/nprcgenekeepr/issues/82) (opened S196).** `fg` is also
stochastic (it reuses the same gene-drop columns) but is a nonlinear functional `1/sum(p^2/r)`, so a sound SE
needs delta-method derivation + multi-seed validation rather than the simple column-variance used for `gu`
(Finding 5). Keeping #2 focused on `gu` avoids hand-waving an `fg` SE. **Follow-up issue #82 opened (S196).**

---

## 5. Implementation plan -- vertical slices (one session each)

Each slice is one session under strict TDD (RED -> GREEN -> REFACTOR, gated). "If I stop here, something
works" holds for each (FM #25, vertical slices).

### Slice 1 (recommended first) = C: per-animal `guSE` column

- **RED:** new tests in `test_reportGV.R` (and a `calcGU`/helper-level test): a known fixture's `guSE` equals
  the exact column-variance SE; `guSE` shrinks ~`1/sqrt(K)` across `K`; the de-inflated `gu = 0` animals get
  `guSE = 0` / excluded; a `gvSummary` test for the new "max `gu` SE" row (`test_modGeneticValue.R`).
- **GREEN:** add the `guSE` computation (from `rare`) and thread the column additively through
  `reportGV.R:213-215` into `$report`/`$gu`; one summary row in `modGeneticValue.R:269-306`; **and add the
  plain-language explanation of the reported `gu` `+/-` to the in-app guidance panel
  `inst/extdata/ui_guidance/genetic_value.html`** (D5/2F) so the estimate is explained where it is shown.
- **DONE:** `reportGV()$report` and `$gu` carry a `guSE` column; the Shiny summary shows worst-case `gu` SE;
  the GVA tab's guidance panel explains what the reported `+/-` means; `gu` values and all existing signatures
  unchanged.
- **Verify:** `devtools::check(vignettes = FALSE)` = 0/0/0; full regression green; `spell_check_package(".")`
  = 0; confirm `orderReport`/`rankSubjects` pass the new column through (Section 6 dragon); launch the app and
  confirm the guidance text renders in the GVA tab beside the new SE line (Phase-3E runtime smoke).
- **Session boundary:** STOP after Slice 1. NEWS bullet folds into the publish PR (separate session).

### Slice 2 = A: `gvaConvergence()` diagnostic + the validation fixture

- **RED (fixture FIRST):** build/simulate a dense-mid-range pedigree fixture (many animals in `gu` 5-20%,
  several near the `gu = 10` cutoff) -- without it the tests are tautological (Finding 4). Then tests:
  `gvaConvergence()` on that fixture recommends a *larger* `N` than on `qcPed`; metrics computed on `gu > 0`
  only; half-splits compared to each other; column-prefix results match a full re-run at the same `N`.
- **GREEN:** factor the `rare`-matrix build out of `calcA` so prefixes reuse it (Finding 7); implement
  `gvaConvergence()` returning the D1 metrics-vs-`N` table + recommended `N`; export + `man` + a short
  vignette reusing the `simulatedKValues` table idiom.
- **DONE:** an exported diagnostic that gives pedigree-specific iteration advice and discriminates the hard
  fixture from `qcPed`.
- **Verify:** check 0/0/0; regression green; the fixture is deterministic (`set_seed`).
- **Session boundary:** STOP. Here be dragons: the `calcA` refactor must not change `gu` (golden-master
  `gu` on `ped1Alleles`/`qcPed` before vs after).

### Slice 3 = Default reconciliation + docs (closes the issue's literal ask)

- **Deliverable:** implement the D3 decision (default alignment or NEWS/CHANGELOG correction) and rewrite the
  `ColonyManagerTutorial.Rmd:459-461` TODO into evidence-based guidance ("precision is `f(K, pedigree)`; here
  is how to check yours with `gvaConvergence()`; the default is `<chosen>`"). Update every stale 2D doc/man
  site so the package tells one consistent story. **Reconcile the two doc surfaces (D5/2F):** extend the longer
  in-app `inst/extdata/ui_guidance/gvAndBgDesc.html`, and bring the parallel vignette components
  `vignettes/manual_components/_genome_uniqueness_algorithm.Rmd` / `_genetic_value_analysis.Rmd` into agreement
  with the Slice 1 `genetic_value.html` text (this is where the stale-"5000" lines in those components get
  fixed).
- **DONE:** no surviving "Default is 5000" vs "changed to 1000" contradiction; the vignette TODO is gone; the
  in-app HTML and the vignette `manual_components` tell one consistent story; #2's three asks (define
  reproducible / automate the test / evidence-based advice) are all met.
- **Verify:** check 0/0/0; `spell_check_package(".")` = 0; vignettes render; `grep` the 2D terms confirms one
  consistent default across `R/`, `man/`, `inst/extdata/ui_guidance/`, and `vignettes/`.
- **Session boundary:** STOP. This is the slice whose merge closes #2.

### Slice 4 (owner-gated, likely never) = B: streaming / early-stop

Only if the owner, after C+A, still wants live early-stop and accepts re-architecting `geneDrop` (loop-order
change), redefining its `V1..Vn` return contract, regenerating the fixed-`N` example datasets, and reworking
the seeded E2E hook + fixed-`N` tests. Flagged out of scope; documented here so the decision is explicit.

---

## 6. Cross-slice notes

- **SE math is shared:** Slice 1's exact column-variance SE is the same quantity Slice 2's diagnostic
  aggregates -- C and A are one coherent design, not two.
- **The `calcA` refactor is load-bearing for A's performance** (Finding 7) and must be `gu`-preserving
  (golden-master test).
- **Column carry-through:** by inspection `orderReport` subsets rows and `rbind`s, preserving columns; Slice 1
  must still confirm `rankSubjects` does not drop `guSE`.
- **Determinism:** all new tests pin `set_seed()`; nothing changes seed behavior (Finding 6).

## 7. Here be dragons (consolidated load-bearing risks)

1. **Do not inflate `N` for homozygotes** -- the `sqrt(2)` claim is wrong at default threshold (Finding 2).
2. **NO bundled pedigree can validate the rank tool** -- `qcPed`/`pedWithGenotype`/`rhesusPedigree` have zero
   rankable `gu` signal, and `examplePedigree` (the only one with signal) is order-stable at `N=5`; build the
   dense-mid-range fixture in RED *before* A or the tests are tautological (Finding 4, firsthand S196).
3. **Exclude the issue #76 `gu = 0` Undetermined set from every metric** (2C) -- **124/280** on `qcPed` (NOT
   156; 156 is the rankable count), and on `qcPed` that set *is* the entire `gu > 0` set; they are a policy
   constant with SE 0 and rank NA.
4. **The rank is bucketed, not smooth** -- target `gu = 10`, integer-`trunc(gu)`, and `z <= 0.25` boundaries;
   no Spearman-Brown on a bucketed statistic (Finding 3).
5. **Half-split must compare halves to each other**, never to their pooled mean (spurious `-1.0`).
6. **"Cheap" prefixes require the `calcA` refactor** (Finding 7), which must preserve `gu` exactly.
7. **`byID`/`guThresh` scope** -- compute SE from the real `rare` matrix so it is correct off the defaults;
   scope the *recommendation* to defaults or parameterize it.
8. **B breaks the `geneDrop` `V1..Vn` contract**, the fixed-`N` example data, and the seeded tests -- keep out
   of scope.
9. **`fg` uncertainty** -- derive+validate or defer; do not hand-wave (Finding 5).
10. **Seed-reproducibility != precision** -- say so explicitly (Finding 6).
11. **Two parallel doc surfaces** (D5/2F) -- the in-app `inst/extdata/ui_guidance/*.html` is hand-authored and
    is NOT generated from the vignette `manual_components/_*.Rmd`; both are edited by hand and must be kept
    consistent, or the app and the manual will disagree about iterations/precision.

## 8. Owner ratification checklist (RESOLVED -- Session 196, 2026-06-25)

**All items ratified. Slice 1 is unblocked.**

- [x] **D1 primary measure:** selection-order stability (RATIFIED S195 -- per-animal SE is a displayed
      diagnostic, "of interest but of little value for breeder selection," not a gate).
- [x] **D1 thresholds (S196):** order metric = **Kendall's tau-b**; provisional **`k = 20`, `o_min = 0.90`,
      `rho_min = 0.95`**, finalized against the Slice-2 dense fixture (they do not gate Slice 1).
- [x] **D2 sequencing (S196):** ship **C (Slice 1) then A (Slice 2); B out of scope**.
- [x] **D3 default reconciliation (S196):** option **(a) -- align the function default to `1000L`** + fix all
      stale "5000" docs in Slice 3 (firsthand evidence basis; see D3).
- [x] **D4 scope (S196):** compute `guSE` from the real `rare` matrix (correct for any `guThresh`/`byID`
      automatically); scope the iteration *recommendation* to the defaults, exposing the parameters.
- [x] **D5 doc scope (S196):** Slice 1 updates the **in-app `genetic_value.html` only**; longer
      `gvAndBgDesc.html` + vignette `manual_components` reconciled in Slice 3.
- [x] **`fg` (S196, D6):** **deferred to follow-up issue #82** (nonlinear functional; needs its own
      delta-method derivation + validation). Opened S196.

---

## 9. Firsthand anchors (verified Session 195)

`R/calcGU.R:88-104` (`gu = rowSums(rare)/(2*iterations)*100`); `R/calcA.R:27-43` (`apply(.,2L,countRare)`,
`tapply(a,ids,sum)`); `R/reportGV.R:93` (`guIter=5000L, guThresh=1L, byID=TRUE`), `:136-140` (`geneDrop`),
`:150` (`calcGU`), `:205-211` (issue #76 de-inflation), `:213-219` (`cbind` + returned list);
`R/orderReport.R:55-98` (bucketed ranking; `gu>10` at `:72`, `-trunc(gu)` at `:73`, `z<=0.25` at `:77`);
`R/modGeneticValue.R:37-39` (UI default `1000L`), `:144-145` (`gatedSeed`), `:147-158,202` (progress),
`:269-306` (`gvSummary`). Default-contradiction inventory: see 2D (84 sites; cross-checked against
`test_modGeneticValue.R:38`). Research: workflow `wf_fdb7c410-95f` (investigate/design/critique, 7 agents).

### 9A. Firsthand evidence (Session 196 -- re-established the load-bearing empirical claims)

S195 flagged that the `qcPed` empirical numbers were subagent-sourced and not personally re-run. S196
re-established them firsthand (scratchpad analysis scripts + `reportGV()` ground truth; column-prefix trick on
one `Nmax` gene-drop run -- no replicate experiment). Results that **shaped or corrected** the plan:

| Claim | S195 (plan) | S196 firsthand | Effect |
|---|---|---|---|
| `qcPed` Undetermined count | 156/280 | **124/280** (156 is the *rankable* count) | §2C, Finding 4, Dragon #3 corrected |
| `qcPed` `gu` distribution | "bimodal 55.7%/43%, 2 mid-range" | `{gu>0}` == `{founders}` == `{Undetermined}` (124, identical sets); **all rankable at `gu=0`; all 280 at `gu=0` post-#76** | §2C, Finding 4 corrected |
| Bundled data for validation | "`qcPed` can't (bimodal)" | **NO bundled ped can**: 3 have zero `gu` signal; `examplePedigree` (only one with signal) is order-stable at `N=5` | Finding 4, Dragon #2 strengthened (dense fixture mandatory) |
| D3 convergence basis | "`qcPed` converges by `N~250-500`" | **vacuous** (`qcPed` has no rankable signal); grounded on `examplePedigree`: order stable `<<1000`, SE 0.79pp@1000 -> 0.56pp@2000 -> ~0.35pp@5000 (`1/sqrt(N)`) | D3 evidence basis corrected; still supports align-to-1000 |
| SE shrinks `~1/sqrt(N)` | asserted | **confirmed** (clean decay on `examplePedigree`) | Finding 1 confirmed |
| `SE_exact/SE_approx` | "~0.81-0.84 at `guThresh>=2`" | **confirmed** (0.82@thr2, 0.85@thr3; ~1.0@thr1) | Correction 1 confirmed |
| column-prefix trick valid | asserted | **confirmed** (per-column rareness independent; prefix `gu` == `calcGU` exactly) | D2/Slice 2 premise confirmed |
| `byID` effect at `guThresh=1` | (not stated) | **none** (`TRUE`/`FALSE` identical) | D4 note |

Scripts (scratchpad, not in repo): `gva_convergence_study.R` (qcPed), `gva_convergence_examplePed.R`
(examplePedigree convergence + half-split). Ground-truth cross-check: `reportGV(qcPed)` / `reportGV(examplePedigree)`.

## 10. Candidates considered and rejected

- **B as literally framed (stream `gu` during the `geneDrop` loop):** infeasible -- per-iteration rare
  classification needs the whole-population frequency table, and `geneDrop` accumulates all-iterations-per-
  animal, not all-animals-per-iteration (1B).
- **Closed-form `sqrt(p(1-p)/(2N))` as the primary SE:** rejected in favor of the exact column-variance SE
  from the real `rare` matrix (correct across `byID`/`guThresh`); the closed form survives only as a cheap
  display approximation (Findings 1-2).
- **Spearman / top-k on the full proband set as the headline criterion:** rejected -- the `gu = 0` tie block
  and the bucketed order statistic make it report tie-reshuffling as instability; use the `gu > 0` subset and
  boundary-density counts (Findings 3-4, 2C).
- **A separate replicate experiment (`R` full re-runs at each `N`):** unnecessary -- the i.i.d. columns of one
  `Nmax` run give the whole curve via prefixes/half-splits at a fraction of the cost (1B, Finding 7).
