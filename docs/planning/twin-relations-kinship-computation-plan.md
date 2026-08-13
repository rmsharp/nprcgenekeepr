# Plan — Thread `twinRelations` into `kinship()`'s Computation

**Status:** RATIFIED (2026-08-13, this session). Both judgment-call decisions (D1, D2) were ratified via `AskUserQuestion`; the owner selected this document's own recommended option for both, with no changes requested. See §10 for the recorded outcome. This plan is ready for Slice 1 implementation in a future session.
**Session:** S550 (2026-08-13)
**Origin:** `BACKLOG.md` Housekeeping — S549 Finding #1 (`docs/audits/KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md`): `nprcgenekeepr::kinship()` has no mechanism to model monozygotic-twin genetic identity, unlike kinship2's own `relation`-argument mechanism. Not yet filed as a GitHub issue (S549 recommended, not filed, matching the `GENETIC_METRICS_PDF_CAPABILITY_AUDIT`/`ISSUE_129_...` precedent of recommending rather than unilaterally filing audit findings).
**Touches (planned, future sessions):** `R/kinship.R`, `R/reportGV.R`, `R/gvaConvergence.R`, `R/createSimKinships.R`, `R/cumulateSimKinships.R`, `R/modPedigree.R`, `R/appServer.R`, `R/modBreedingGroups.R`, `R/modSummaryStats.R`, `R/modGeneticValue.R`, `tests/testthat/test_kinship.R` and siblings for each touched file, `NEWS.Rmd`.
**Does NOT touch:** `R/checkTwinRelations.R`, `R/obfuscateTwinRelations.R`, `R/readTwinRelations.R` (issue #137's existing sidecar validator/de-identifier/reader are reused as-is, unmodified — confirmed below, §2.2); `R/makePedigreeDiagramData.R` (the Diagram tab's own twin-connector rendering is unaffected — this plan is about the *computed kinship value*, not the diagram); `.nprcColumnSchema`/`R/columnSchema.R` (no new per-individual pedigree column — `twinRelations` stays a sidecar, matching issue #137's own D1).
**Workstream:** `docs/methodology/workstreams/DESIGN_WORKSTREAM.md` — an architecture/data-flow design (how twin data reaches a widely-called core function), not a UI layout question.

> **Scope.** Design (not implement) how the existing `twinRelations` sidecar data model (issue #137, shipped S492-494) reaches `kinship()`'s own computation, so that a declared MZ-twin pair's genetic identity is correctly reflected in every kinship-driven calculation in the package, not just the Diagram tab's rendering. This document identifies every production call site of `kinship()`, evaluates where the correction mechanism must live, and separates decisions the evidence already forces from genuine judgment calls the owner must ratify (§10).

---

## 1. Context

### 1.1 What the triggering finding says

> **Source:** `docs/audits/KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md`, Finding #1.
>
> kinship2's own `kinship()` takes a `pedigree` object built with an optional `relation` argument that declares MZ/DZ/UZ twin pairs; when two individuals are declared MZ twins, kinship2 overrides their pairwise coefficient to equal their self-kinship (genetic identity) and propagates that identity to every relative computed through either twin. `nprcgenekeepr::kinship()` takes only `id`/`father.id`/`mother.id`/`pdepth` — there is no parameter through which twin identity can be supplied, and no post-processing step applies one.
>
> Confirmed against a 10-subject fixture reconstructed from kinship2's own supplementary-material PDF (Table S1): `nprcgenekeepr::kinship()`'s matrix matches the paper exactly except the two cells touching the declared MZ-twin pair (8, 9) — `kinship(8,9)` should be **0.50** (identity) but computes as **0.25** (ordinary full-sib); `kinship(9,10)` — 10 is a *child of twin 8*, not a twin themself — should be **0.28** but computes as **0.1562**. The second number is the load-bearing one: it proves the gap is not confined to the twin pair's own cell, it silently understates kinship for every relative reached through either twin.
>
> `nprcgenekeepr` already has the twin-declaration data model (`checkTwinRelations()`, `twinRelations` sidecar, issue #137) but it is wired only to `makePedigreeDiagramData()`/`makePedigreeMatingLayout()` (the Diagram tab's rendering) — never to `kinship()` or any of its production callers.

### 1.2 What is already decided (do not re-litigate)

- **The sidecar data model itself.** Issue #137 (S491 design, S492-494 implementation) already ratified and shipped `twinRelations` as a `data.frame(id1, id2, code)` sidecar, `code ∈ {"MZ twin", "DZ twin", "UZ twin"}`, validated by `checkTwinRelations(ped, twinRelations)` against kinship2's own five acceptance rules (both ids exist and differ; MZ/DZ require the pair to already share both `sire` and `dam`; MZ additionally requires matching `sex`; UZ has no precondition). This plan reuses that object and that validator verbatim — it is not redesigning the data model, only extending where the *already-validated* data is allowed to flow.
- **Which twin code needs special kinship treatment.** Confirmed directly from the installed kinship2 namespace (`getS3method("kinship", "pedigree")`, deparsed, §2.1): only `code == "MZ twin"` triggers any adjustment to the computed matrix. `"DZ twin"` (dizygotic — two separate eggs, ordinarily related) and `"UZ twin"` (zygosity undetermined) get **zero** special kinship treatment in kinship2 itself — they remain ordinary full siblings for kinship purposes, distinguished only in the Diagram tab's rendering (issue #137's own scope). This plan's kinship-side scope is therefore narrower than issue #137's rendering-side scope: MZ only.
- **No X-chromosome-specific kinship exists in this package** (S549 Finding #4, judged a capability-fit non-issue) — this plan's algorithm work is autosomal-only, matching `kinship()`'s own current scope.

### 1.3 What this session's research confirmed

`nprcgenekeepr::kinship()` (`R/kinship.R:62`) is **not** a wrapper around `kinship2::kinship()` — it is an independent, from-scratch reimplementation (originally Terry Therneau's `kinship.s`, ported), structurally near-identical to kinship2's own algorithm (same recursive depth-loop formula, same `mrow`/`drow` parent-index variable names) but taking flat vectors (`id`, `father.id`, `mother.id`, `pdepth`) rather than a `pedigree` S3 object. This structural similarity is directly load-bearing for §3 D1: kinship2's own MZ-identity mechanism ports almost line-for-line.

An AST-level count (not a text grep, which over-counts roxygen `@examples` blocks and doc comments) of every executable call to `kinship(` in `R/` finds **7** production call sites, not the 15 the triggering audit estimated — that number is corrected here per this project's own "verify a predecessor's number before repeating it" precedent (`SESSION_RUNNER.md` Phase 3A). The same AST method finds 30 further call sites in `tests/testthat/`. Full inventory in §2.

---

## 2. Evidence-based inventory

### 2.1 kinship2's own MZ-twin mechanism (deparsed from the installed namespace, not the Rd summary)

```r
havemz <- FALSE
if (!is.null(id$relation) && any(id$relation$code == "MZ twin")) {
  havemz <- TRUE
  temp <- which(id$relation$code == "MZ twin")
  mzmat <- as.matrix(id$relation[, c("indx1", "indx2")])[temp, , drop = FALSE]
  mzgrp <- 1:max(mzmat)
  while (1) {
    if (all(mzgrp[mzmat[, 1]] == mzgrp[mzmat[, 2]])) break
    for (i in 1:nrow(mzmat)) mzgrp[mzmat[i, 1]] <- mzgrp[mzmat[i, 2]] <- min(mzgrp[mzmat[i, ]])
  }
  mzindex <- cbind(unlist(tapply(mzmat, mzgrp[mzmat], function(x) { z <- unique(x); rep(z, length(z)) })),
                    unlist(tapply(mzmat, mzgrp[mzmat], function(x) { z <- unique(x); rep(z, each = length(z)) })))
  mzindex <- mzindex[mzindex[, 1] != mzindex[, 2], ]
}
# ... inside the existing depth loop, immediately after the ordinary sibling formula:
for (depth in 1:max(pdepth)) {
  # ... ordinary kmat[indx,]/kmat[,indx]/kmat[j,j] computation, unchanged ...
  if (havemz) kmat[mzindex] <- (diag(kmat))[mzindex[, 1]]
}
```

Three mechanisms, each load-bearing:

1. **Transitive grouping (`mzgrp`).** A union-find-style loop groups chained MZ declarations (A-B, B-C ⇒ {A,B,C} one group) so a triplet's every pairwise cell gets corrected, not just the declared pairs. This is exactly the transitive-propagation behavior the triggering BACKLOG item explicitly asks for ("propagating the override transitively... not just the direct pair").
2. **All-pairs index (`mzindex`).** Expands each group into every ordered off-diagonal pair within it — the actual matrix cells to overwrite.
3. **In-loop correction, not a post-hoc pass.** `kmat[mzindex] <- (diag(kmat))[mzindex[, 1]]` runs **inside** the same `for (depth in ...)` loop that computes the ordinary pedigree-derived matrix, immediately after each depth's individuals are processed — not once at the end. This placement is not cosmetic; §2.2 derives why it is mathematically required.

### 2.2 Why the correction must live inside the recursive loop, not as a post-hoc patch on the finished matrix

The standard recursive kinship formula computes any individual's row as the average of its two parents' already-computed rows: `kmat[child, X] = (kmat[mom, X] + kmat[dad, X]) / 2`, for every `X` processed at a lower depth. Two full siblings (twins included) automatically get **identical** rows relative to every *other* individual, for free, by this formula — no special handling needed there. The *only* cell that differs between "ordinary full sibling" and "MZ twin" is the pair's own cross-term, `kmat[twinA, twinB]`.

But that one cell feeds every later depth's computation: a grandchild `D` of twin B computes `kmat[A, D] = (kmat[A, B] + kmat[A, otherParentOfD]) / 2` at D's own depth — which is only correct if `kmat[A, B]` was **already** corrected to the identity value *before* D is processed. This is exactly what the triggering audit's own worked example demonstrates: `kinship(9, 10)` — 10 being a *child* of twin 8, not a twin themself — is wrong (0.1562 instead of 0.28) in `nprcgenekeepr::kinship()` today, precisely because no upstream correction to `kinship(8,9)` ever happened for 10's own row computation to draw on. **A single-pass fix applied to the finished matrix (`kmat["8","9"] <- 0.5` after the fact) would repair the twins' own cell but leave every descendant's relationships silently wrong** — the same failure mode the current code already has, just relocated one cell over. The correction is therefore forced to live inside the depth loop, at the twin pair's own depth, before any later depth is processed. This rules out a "post-hoc adjustment function operating on the already-computed matrix" as a *correct* implementation strategy (§3 D1 still asks whether that logic lives inside `kinship()` itself or a second function that reimplements the same depth-loop traversal — but either way, it cannot be a single-pass patch).

### 2.3 The `kinship()` "never modified" precedent — and why twin identity is a different kind of fact

`R/applyKinshipOverrides.R`'s own roxygen documentation states explicitly: *"`kinship()` itself is never modified (it has several callers, including two simulations that must not take current-kinship overrides)."* This is a real, deliberate architectural constraint, not incidental — `applyKinshipOverrides()`/`applyKinshipOverridesToMatrix()` exist specifically so that user-supplied "outside information" about a pair's true kinship (typically from external genotyping of a *specific* pair) can refine a computed matrix **without** touching `kinship()`'s own algorithm, because two of its callers (`createSimKinships()`, `cumulateSimKinships()` — the Monte Carlo unknown-parent simulations) must never see those overrides: an override describes the *actual, current* population, and has no defensible meaning inside a simulation exploring *hypothetical* possible-parent assignments for unrelated unknown-parent animals.

Twin identity is not the same kind of fact. It is a **structural pedigree fact** — like `sire`/`dam`/`sex` — not an outside opinion overriding a pedigree-derived computation; kinship2 itself treats it exactly this way, folding `relation` into the same `pedigree()` object as `sire`/`dam`/`sex`, never as a post-hoc override layer. And critically, twin identity is **not** the kind of fact the two simulations must be shielded from: `makeSimPed()` (§2.6) preserves every already-known individual's `id`/`sire`/`dam` unchanged across every simulated pedigree — it only imputes *unknown* parents for the specific individuals named in `allSimParents`. A twin pair with known recorded parents (a precondition `checkTwinRelations()` already enforces for MZ/DZ) keeps that same twin relationship, unchanged, in every simulated pedigree. Unlike a kinship override, there is no principled reason a Monte Carlo unknown-parent simulation should compute a *different*, non-identical kinship value for a declared MZ pair than the live pedigree does. This is the evidence-based resolution offered for §3 D1 — presented as a recommendation, not asserted as forced, since it does depart from an existing documented invariant.

### 2.4 Production call-site inventory (AST-verified)

An `Rscript` walk of every parsed `R/*.R` file's call tree (not a text grep — see script cited in §9) finds exactly 7 executable calls to `kinship(`:

| # | File:line | Context | Reached from Shiny? | Reached as exported script function? |
|---|---|---|---|---|
| 1 | `R/reportGV.R:162` | `filterKinMatrix(probands, kinship(ped$id, ped$sire, ped$dam, ped$gen))` inside `reportGV()` | Yes — `R/modGeneticValue.R:304` | Yes — `reportGV()` exported |
| 2 | `R/gvaConvergence.R:139` | Same pattern, inside `gvaConvergence()` | No — confirmed no Shiny module calls it (its own code comment: *"a script-facing diagnostic"*) | Yes — `gvaConvergence()` exported |
| 3 | `R/createSimKinships.R:60` | `kinship(simPed$id, simPed$sire, simPed$dam, simPed$gen)` per Monte Carlo iteration | No — confirmed no in-package caller at all (grep across `R/`); standalone utility documented in `vignettes/simulatedKValues.Rmd` | Yes — `createSimKinships()` exported |
| 4 | `R/cumulateSimKinships.R:63` | Same pattern | No — same as above | Yes — `cumulateSimKinships()` exported |
| 5 | `R/appServer.R:343` | `sharedKinshipMatrix` reactive — the app's canonical, computed-once kinship source (issue #122 Phase 2), threaded into both Summary Stats and Breeding Groups | Yes — this **is** the Shiny path | No — internal to `appServer()` |
| 6 | `R/modBreedingGroups.R:251` | `getKinshipMatrix()` helper's **fallback** recompute, used only when `kinshipMatrix` isn't supplied/available | Yes — module-internal fallback | No |
| 7 | `R/modSummaryStats.R:382` | `getKinshipMatrix` reactive's own **fallback** recompute (Summary Stats must render even before GV analysis has run — an existing, documented ordering constraint, `R/modSummaryStats.R:373-380`) | Yes — module-internal fallback | No |

**Confirmed NOT call sites**, despite matching a plain-text `kinship(` grep: 21 further hits across `R/*.R` are roxygen `@examples` blocks or prose (e.g. `R/meanKinship.R:26`, `R/filterKinMatrix.R:17`) that never execute inside the package; 3 hits in `R/reportGV.R` (`:186,244,283`) are inline comments referencing `kinship()` by name, not calls. `R/kinship.R:59` itself is the function's own roxygen example.

**Test-only call sites** (30, across 23 files, AST-verified the same way) are not part of this section's production inventory but are the direct verification surface for Slice 1 (§4) — most exercise `kinship()`'s existing 4-argument contract and require zero change (a new parameter defaulting to `NULL` cannot break them); a handful (`test_kinship.R`, `test_reportGV.R`) gain new twin-specific assertions.

### 2.5 Downstream consumers that do **not** need to change

Confirmed by reading each: `meanKinship()`, `filterKinMatrix()`, `applyKinshipOverrides()`/`applyKinshipOverridesToMatrix()`, `getAnimalsWithHighKinship()`, `convertRelationships()`, `kinMatrix2LongForm()`, `filterPairs()`, `filterThreshold()`, `markerRealizedRelatednessVariance()`, `reportMatePairs()` all consume an **already-computed** `kmat` matrix as their input — none of them call `kinship()` themselves (confirmed by the same AST method, §2.4). Once `kinship()`'s own output correctly reflects twin identity, every one of these consumers is correct for free, with zero code change — they operate purely on cell values, agnostic to how those values were derived. This significantly bounds this plan's blast radius: the 7 call sites in §2.4 are the *entire* surface that needs new code.

### 2.6 The two Monte Carlo simulations do not need special-case interaction handling

`makeSimPed(ped, allSimParents, verbose)` (`R/makeSimPed.R:48`) imputes **only** an already-`NA` sire/dam for the specific `id`s named in `allSimParents`; every other individual's `id`/`sire`/`dam` — including any declared twin pair with recorded parents — passes through completely unchanged into `simPed`, confirmed by direct reading of the function body (`if (length(sireNow) == 1L && is.na(sireNow)) { ... } ` — a known, non-`NA` sire is never touched). Since `checkTwinRelations()` already requires MZ/DZ pairs to have non-`NA`, shared `sire`/`dam` (§1.2), a declared twin pair can never be one of the individuals `makeSimPed()` re-assigns parents for. This means `twinRelations` can be threaded through `createSimKinships()`/`cumulateSimKinships()` **unchanged across every simulated iteration** — no interaction complexity between "declared twin identity" and "Monte Carlo unknown-parent imputation" exists to design around.

### 2.7 Where `twinRelations` is currently reachable in the app, and where it is not

`twinRelationsData()` (`R/modPedigree.R:474-483`) is a reactive **local to `modPedigreeServer()`** (the Pedigree Browser/Diagram tab's own server function), populated from `input$twinRelationsFile` — a file-upload control that exists only inside that tab's own UI (`R/modPedigree.R:163`). `modPedigreeServer()` already returns a list of further reactives to its caller (`pedigree`, `processedPedigree`, `focalAnimals`, `nAnimals`, `populationCount`, `isReady` — `R/modPedigree.R:792-812`) but **does not currently include `twinRelationsData`** in that list.

`shared$currentPedigree` (`R/appServer.R:47-53`, the app-wide `reactiveValues` object) is populated at `R/appServer.R:307` from a **different** module's output (`pedigreeResults$pedigree()`, i.e. `modInput`'s own pedigree-loading result, not `modPedigree`'s) — `shared` has no `twinRelations` slot today.

The closest existing precedent for "a second, sidecar CSV uploaded in one tab, then threaded to other modules by reference" is `kinshipOverrideData` (`R/modGeneticValue.R:221-228`), a reactive local to the **GV Analysis** tab's own upload control (`input$kinshipOverrideFile`), returned by `modGeneticValueServer()` (`R/modGeneticValue.R:523`) as `kinshipOverrides`, and threaded by `R/appServer.R` into `sharedKinshipMatrix` (`:344-347`) and both `modBreedingGroupsServer`/`modSummaryStatsServer` calls (`:409`, and the Summary Stats equivalent) as an explicit `kinshipOverrides` reactive parameter. **This is the load-bearing precedent §3 D3 follows** — except `twinRelations` is already uploaded in a *different* tab (Diagram, not GV Analysis) than the one that precedent used, which is itself a genuine design fork (§3 D3, §6 Dragon 1).

One relevant existing gate: `R/modPedigree.R:577-579`'s `diagramLayout` reactive currently gates `twinRelationsData()` behind a **local** `"Show Twin Connectors"` UI toggle (`.currentShowTwinConnectors()`) before passing it to `makePedigreeMatingLayout()` — but this gating is scoped entirely to that one reactive's own local variable, not to `twinRelationsData()` itself, which remains ungated. Exposing the raw, ungated `twinRelationsData()` reactive as a new return-list entry (§4 Slice 3) requires no change to this existing gate and does not entangle kinship computation with a display-only toggle.

### 2.8 Structural traps table

| # | Trap | Where | Consequence if ignored | Addressed by |
|---|---|---|---|---|
| 1 | A post-hoc, single-pass patch on the finished matrix cannot correctly propagate to descendants | `R/kinship.R` recursive depth-loop structure | Twins' own cell "fixed," every descendant relationship silently still wrong — the audit's own `kinship(9,10)` example | D1 (correction lives inside the depth-loop traversal, matching kinship2's placement exactly) |
| 2 | `kinship()`'s flat-vector signature has no `sex` parameter | `R/kinship.R:62` | Cannot re-run `checkTwinRelations()`'s MZ-matching-sex rule inside `kinship()` itself without a new, disruptive signature addition | D2 (trust a pre-validated `twinRelations`; document the precondition) |
| 3 | `twinRelations` is currently uploaded only inside the Diagram tab, not GV Analysis (the tab `kinshipOverrides`'s own precedent uses) | `R/modPedigree.R:163` vs. `R/modGeneticValue.R` | A user who never visits the Diagram tab gets ordinary (uncorrected) kinship everywhere else, with no upload point to fix it | D3 (Slice 3 promotion) + Dragon 1 (tab-order UX, not resolved here) |
| 4 | `createSimKinships()`/`cumulateSimKinships()` have no in-package caller | Confirmed by grep across `R/` | A design that assumes these are reached via `reportGV()`/`gvaConvergence()` internally would wire the wrong call graph | Confirmed independently script-callable (§2.4); wired directly, not via another function |
| 5 | 21 of 28 raw text-grep hits for `kinship(` are non-executing doc/comment text | `R/*.R` roxygen `@examples`, inline comments | An inventory built from `grep` alone over-counts call sites (the triggering audit's own "15" estimate) | AST-verified count in §2.4, corrected here |

---

## 3. Design decisions

Three decisions, D1-D3. D1 and D2 are genuine judgment calls requiring ratification (§10); D3 (the slice/wiring plan) is this document's own proposal per `SESSION_RUNNER.md`'s Planning-Session convention (not independently a §10 vote, matching precedent — see issue #137's plan, whose §10 votes were data-shape/rendering/UI-timing questions, never the slice count itself).

**D1 — Where does the MZ-identity correction live: inside `kinship()`'s own signature (amending the "never modified" function), or in a new, separate function that reimplements the same depth-loop traversal to preserve `kinship()` verbatim? Judgment call; requires ratification (§10 Q1).**

| Option | Mechanism | Pros | Cons | Verdict |
|---|---|---|---|---|
| **(a) Extend `kinship()` itself** — new `twinRelations = NULL` parameter; port kinship2's `mzgrp`/`mzindex`/in-loop-correction mechanism (§2.1) directly into the existing depth loop | One algorithm, one source of truth; kinship2's mechanism ports almost line-for-line given the structural similarity already confirmed (§1.3); default `NULL` is fully backward-compatible — every existing call site and all 30 test call sites are unaffected until they opt in | Amends the documented "`kinship()` itself is never modified" invariant in `R/applyKinshipOverrides.R`'s own roxygen text — that comment must be updated to explain the distinction (§2.3) so a future reader doesn't see it as contradicted rather than narrowed | **Recommended** |
| **(b) New function, e.g. `applyTwinIdentity(kmat, id, father.id, mother.id, pdepth, twinRelations)`**, called as a required second step after `kinship()`, re-deriving the depth-loop traversal independently | Preserves the "`kinship()` itself is never modified" sentence literally true | Duplicates the entire recursive algorithm in a second function purely to avoid editing the first (§2.2 already established the correction cannot be a true single-pass patch — it must re-walk the same depth structure) — a maintenance burden (two copies of the same recursive logic to keep in sync) with no correctness benefit over (a); every one of the 7 call sites still needs a code change either way (a new parameter vs. a second function call), so (b) buys no simplicity at the call sites either | Rejected as primary; a defensible minority position if the owner weighs "never touch `kinship()`'s own body" more heavily than DRY |

**Recommendation: (a).** §2.2's mathematical argument establishes the correction is not a genuine "override" in the sense the `applyKinshipOverrides()` precedent guards against (§2.3) — it is a structural pedigree fact that belongs in the same computation as `sire`/`dam`, exactly where kinship2 itself puts it. Flagged as a judgment call, not asserted as forced, specifically because it does depart from an existing, deliberately-written architectural comment; the owner may weigh preserving that invariant literally differently than this document does.

**D2 — Does `kinship()` re-validate `twinRelations` itself (call `checkTwinRelations()` internally), or trust that the caller already validated it? Judgment call; requires ratification (§10 Q2).**

The established in-package precedent (`applyKinshipOverrides()`, `R/applyKinshipOverrides.R:35`) validates internally on every call (`overrides <- checkKinshipOverrides(overrides)`), even though it is itself a "second step" function analogous to what D1 Option (a) would add. But `checkTwinRelations(ped, twinRelations)` requires the **full** pedigree data frame — specifically `sex`, to enforce the MZ-matching-sex rule — and `kinship()`'s existing signature carries no `sex` vector at all (§2.8 trap #2). Two paths:

| Option | Mechanism | Pros | Cons | Verdict |
|---|---|---|---|---|
| **(a) Trust a pre-validated input; document the precondition** | `kinship()` performs only the lightweight structural checks it *can* do with its existing inputs (both ids present in `id`, `id1 != id2` — a cheap, self-contained check); the roxygen contract states plainly that `twinRelations` must already be validated by `checkTwinRelations()` upstream | No signature disruption beyond the one new parameter; matches the fact that every existing production call site (§2.4) that will supply `twinRelations` already has access to a validated one upstream (issue #137's own Diagram-tab flow already runs `checkTwinRelations()` before use) | Diverges from the `applyKinshipOverrides()` precedent of always validating internally; a caller who bypasses `checkTwinRelations()` and hand-builds a malformed `twinRelations` gets an unhelpful downstream error (or silently wrong output) rather than a clear validation message | **Recommended** |
| **(b) Add a `sex` parameter to `kinship()` and validate fully inside** | Full parity with the `applyKinshipOverrides()` precedent; `kinship()` becomes self-defending against any malformed input regardless of caller discipline | A larger, more disruptive signature change to a function called from 37 total sites (7 production + 30 test); `sex` becomes a *required* new argument's dependency the moment `twinRelations` is non-`NULL`, an awkward conditional-requirement shape no other `kinship()` parameter has today | Rejected as primary — the signature cost is disproportionate to the benefit given every real call site already has a validated table available |

**Recommendation: (a).** `kinship()` still fails loudly (not silently) on the cheap checks it can make (id existence, non-identity) — it is not accepting arbitrary garbage, only deferring the *sex*/*shared-parentage* semantic checks to the documented precondition, consistent with `kinship()`'s own existing minimal-argument philosophy.

**D3 — Which codes trigger correction, and how is the sidecar table filtered? Forced, given §1.2.**

`kinship()` accepts the *same* `twinRelations` object already collected for the Diagram tab (all three codes together) and filters internally to `code == "MZ twin"` rows only — mirroring kinship2's own `id$relation$code == "MZ twin"` filter (§2.1) exactly. This avoids requiring two different sidecar shapes (one for rendering, one for kinship) for what is, by D2's precondition, already the same validated object. No ratification needed — this is a direct, forced consequence of §1.2's already-established scope (MZ only) plus D2's "reuse the existing validated table" choice.

---

## 4. Implementation plan — vertical slices (one session each)

```
Slice 1 (core algorithm: kinship()'s own twinRelations parameter, MZ-only, transitive groups)
  `-- Slice 2 (the 4 script-callable functions: reportGV, gvaConvergence, createSimKinships, cumulateSimKinships)
        `-- Slice 3 (full Shiny wiring: modPedigree return value, shared$twinRelations, both module fallbacks, modGeneticValue)
```

### Slice 1 — Core algorithm

**Scope:** `kinship(id, father.id, mother.id, pdepth, sparse = FALSE, twinRelations = NULL)` gains the new parameter; internally filters to `code == "MZ twin"`, builds the transitive `mzgrp`/`mzindex` structures (§2.1), and applies the in-loop correction at the same point kinship2 does. `twinRelations = NULL` (the default) is a complete no-op — every existing call, including all 30 test call sites, is byte-for-byte unaffected.

**What does NOT change:** any of the 6 downstream consumer functions in §2.5 (they take an already-computed matrix; a correctly-computed matrix requires no change on their side); the 6 other production call sites (Slices 2-3); `checkTwinRelations()`/`obfuscateTwinRelations()`/`readTwinRelations()` (reused verbatim, per D2).

**Files to touch:**
- `R/kinship.R` — new parameter, MZ-filter, `mzgrp`/`mzindex` construction, in-loop correction.
- `tests/testthat/test_kinship.R` — new test block using the exact 10-subject fixture from `docs/audits/KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md` (subjects 1-10, twin pair 8×9), asserting `kinship(8,9) == 0.50` and — the load-bearing propagation assertion — `kinship(9,10) == kinship2's own 0.2812` value (not the paper's rounded 0.28, to keep the test exact rather than tolerance-based against a print-rounded figure) when `twinRelations = data.frame(id1="8", id2="9", code="MZ twin")` is supplied; a companion assertion that omitting `twinRelations` reproduces today's existing (uncorrected) values unchanged, pinning backward compatibility; a 3-member transitive-group fixture (A-B MZ, B-C MZ ⇒ verify `kinship(A,C) == kinship(A,A)` too, not just the two declared pairs) exercising `mzgrp`'s union-find grouping; a DZ/UZ-coded pair fixture asserting **zero** change from the ordinary full-sibling value (pinning D3's filter).

**RED:** all tests above, written against the not-yet-existing parameter; confirm they fail for the right reason.

**GREEN:** implement exactly enough to pass — the parameter, the MZ filter, the mzgrp/mzindex mechanism, the in-loop correction. No caller wiring (Slices 2-3).

**DONE looks like:** `devtools::check()` 0 errors/0 warnings; new unit tests pass, including the transitive-group and propagation-to-non-twin-relative assertions; the full clean regression read shows no new failures across any of the 30 existing test call sites; running the audit's own 10-subject fixture through the new parameter reproduces `kinship2::kinship()`'s twin-declared output for all 3 previously-divergent cells (0.5000, 0.2812/≈0.28, and confirms 10's own self-kinship — which does not depend on the twin shortcut — is unaffected).

**Verify:** targeted `test_kinship.R` run; full clean regression read; full `devtools::check()`.

**Session boundary:** one session. Close out when Slice 1's DONE criteria are met. Slice 2 is a separate future session — Slice 1 alone is already a complete, independently useful, fully-backward-compatible unit (any script-based user can pass `twinRelations` directly to `kinship()` the moment Slice 1 ships).

### Slice 2 — The 4 script-callable functions

**Scope:** `reportGV()`, `gvaConvergence()`, `createSimKinships()`, `cumulateSimKinships()` each gain their own `twinRelations = NULL` parameter, passed straight through to their internal `kinship()` call (§2.4 confirms each is a single, direct call site — no intermediate wrapping to thread through). No Shiny UI change — script-callable only, mirroring issue #137's own D11 precedent of landing the R-function-level change before UI wiring.

**What does NOT change:** any Shiny module (Slice 3); the two simulation functions' own Monte Carlo mechanics (§2.6 already confirmed no interaction complexity — `twinRelations` passes through unchanged on every iteration).

**Files to touch:**
- `R/reportGV.R`, `R/gvaConvergence.R`, `R/createSimKinships.R`, `R/cumulateSimKinships.R` — new parameter each, threaded to the internal `kinship()` call.
- `tests/testthat/test_reportGV.R`, `test_gvaConvergence.R` (if it exists as a separate file — confirm at Pre-RED), `test_createSimKinships.R`, `test_cumulateSimKinships.R` — one twin-propagation assertion each, reusing the Slice 1 fixture; one no-`twinRelations`-supplied backward-compatibility assertion each.

**DONE looks like:** all 4 functions correctly propagate twin identity when supplied; omitting the parameter (existing callers, existing tests) is unaffected; full clean regression read; `devtools::check()` clean.

**Verify:** targeted test runs for all 4 files; full clean regression read; full `devtools::check()`.

**Session boundary:** one session, separate from Slice 1 and Slice 3.

### Slice 3 — Full Shiny wiring

**Scope:** promote `twinRelations` to app-wide reachability, mirroring `kinshipOverrides`'s own precedent (§2.7) with one adaptation: the upload point is `modPedigree.R` (Diagram tab), not `modGeneticValue.R` (GV Analysis tab) — the tab it is already uploaded in, per issue #137. `modPedigreeServer()`'s return list gains a `twinRelations = reactive({ twinRelationsData() })` entry (the raw, ungated reactive — §2.7 already confirmed the existing "Show Twin Connectors" toggle scopes to `diagramLayout` alone and does not need to gate this new entry). `R/appServer.R` gains `shared$twinRelations`, populated the same way `shared$currentPedigree` is (`:307`); `sharedKinshipMatrix` (`:338-347`) passes it into its `kinship()` call; `modBreedingGroupsServer`/`modSummaryStatsServer` each gain a new `twinRelations` reactive parameter on their own fallback-recompute helper, wired at their `R/appServer.R` call sites exactly as `kinshipOverrides` is today; `modGeneticValueServer`'s call to `reportGV()` (`R/modGeneticValue.R:304`) passes `shared$twinRelations` through (requires `modGeneticValueServer()` to accept it as a new parameter from `appServer.R`, since — unlike `kinshipOverrides` — this data does not originate inside the GV Analysis module itself).

**What does NOT change:** `R/makePedigreeDiagramData.R`'s own rendering (untouched — it already consumes `twinRelationsData()` directly inside `modPedigree.R`, unaffected by exposing a second read of the same reactive); the "Show Twin Connectors" toggle's existing behavior.

**Files to touch:** `R/modPedigree.R` (new return-list entry), `R/appServer.R` (new `shared` slot, 3 new wiring points), `R/modBreedingGroups.R`, `R/modSummaryStats.R` (new parameter on each fallback helper), `R/modGeneticValue.R` (new parameter, passed to `reportGV()`), `tests/testthat/test_modPedigree.R`, `test_modBreedingGroups*.R`, `test_modSummaryStats*.R`, `test_modGeneticValue*.R` (as applicable — confirm exact file set at Pre-RED), `NEWS.Rmd`.

**DONE looks like:** a user who uploads a `twinRelations` file in the Diagram tab sees the corrected kinship value reflected in Summary Stats, Breeding Groups, and GV Analysis — regardless of tab visit order (Dragon 1 below is the one open question this slice's Pre-RED must resolve before this criterion is testable); the existing "Show Twin Connectors" toggle continues to control only the Diagram tab's own rendering, unaffected by this slice; live `shinytest2`/`chromote` verification (Phase 3E) exercises the actual upload-and-cross-tab flow, not just `testServer()`.

**Verify:** targeted test runs; full clean regression read; `devtools::check()`; live `shinytest2`/`chromote` E2E smoke test; `lintr::lint_package()` on touched files.

**Session boundary:** one session, separate from Slices 1-2. Given Dragon 1 (below) is a real open UX question, this slice's own Pre-RED should resolve it via `AskUserQuestion` before implementation, following the established per-slice judgment-call pattern (e.g. issue #145's own adversarial-review-then-ratify precedent) rather than this document resolving it in advance.

---

## 5. Impact analysis

**Blast radius is small at Slice 1, growing predictably through Slices 2-3.** Slice 1 touches exactly one file (`R/kinship.R`) plus its own test file; the new parameter defaults to `NULL`, so all 37 existing call sites (7 production + 30 test) are provably unaffected until they opt in — each slice's own DONE criteria include an explicit backward-compatibility assertion, not just a "no new failures" read. §2.5 already confirmed the 10 downstream matrix-consumer functions need zero code change at any slice, since they operate on already-computed values.

**Performance:** the `mzgrp`/`mzindex` construction is `O(twin pairs)`, negligible relative to `kinship()`'s existing `O(n²)` matrix operations for any colony-scale pedigree (a small fraction of individuals are ever twins) — no performance concern identified.

**Backward compatibility:** explicitly required and testable at each slice boundary, per Slice 1-3's own DONE criteria above.

**Close-out checklists triggered** (`CLAUDE.md`): NEWS.Rmd entry in Slice 3's own session (Slices 1-2 are internal-signature-only changes with no user-facing Shiny feature yet — the tutorial/article checklist does not trigger until Slice 3 makes the capability reachable from the UI); citation checklist (#120) — this is a computation-correctness fix to an existing exported function, not a new displayed statistic/estimator, so **likely N/A**, but per the `issue137` plan's own precedent (§8 item 1), the Slice 1 implementing session should state this conclusion explicitly rather than silently omit the checklist; `a2interactive.Rmd` — `kinship()`/`reportGV()`/`gvaConvergence()`/`createSimKinships()`/`cumulateSimKinships()` are all already-documented, script-callable functions gaining a new parameter, which is exactly the shape Session 478's broadened checklist targets — **deferred, not same-slice**, per that checklist's own standing rule, once the feature has stabilized past Slice 2; lint on touched files, each slice; a `CHANGELOG.md` dated-ledger entry for each slice's own close-out, tagged `[BL-N]` until/unless this item is filed as a GitHub issue (§10 note).

---

## 6. Here be dragons

1. **The Slice 3 tab-order UX question is not resolved by this document.** `twinRelations` is uploaded only inside the Diagram tab. A user who runs GV Analysis, Summary Stats, or Breeding Groups **without** ever visiting the Diagram tab gets ordinary (uncorrected) kinship in every one of those tabs, with no upload point available to fix it short of visiting an unrelated tab first. This is the same *class* of problem `modSummaryStats.R`'s own existing code comment already names for a different reason ("Dragon 3: summary stats must render before GV is ever run") — but this document does not propose a resolution (e.g., a second, independent upload point in `modInput.R`, duplicating the Diagram tab's own upload) because doing so would itself need its own judgment call (DRY-vs-discoverability) this document has not evidenced either way. Slice 3's own Pre-RED should resolve this explicitly, per §4's own recommendation.
2. **D1's "extend `kinship()` itself" recommendation, if ratified, requires updating the specific roxygen sentence in `R/applyKinshipOverrides.R` that currently asserts `kinship()` is never modified** — not just a mechanical find-and-replace, but a rewrite explaining the structural-fact-vs-outside-information distinction §2.3 draws, so a future reader does not see the new code as silently contradicting documented intent. Not drafted here; the Slice 1 implementing session owns the exact wording.
3. **Whether `gvaConvergence()`'s own diagnostic output (grid/convergence-threshold recommendations) is sensitive to twin-corrected kinship values in any way beyond the raw kinship numbers feeding it has not been investigated.** `gvaConvergence()` is a script-facing diagnostic recommending an iteration count for gene-drop convergence — this document assumes threading `twinRelations` through unchanged is sufficient (same treatment as any other kinship input), but has not traced whether any of its internal convergence heuristics implicitly assume kinship values fall within the *ordinary* pedigree-derived range (twin identity, 0.5, is higher than any non-self ordinary pedigree relationship except a parent-child pair at some inbreeding levels — an edge case not explored here).
4. **This document has not verified the exact current file name/existence of a dedicated `test_gvaConvergence.R`** (referenced in §4 Slice 2 as "if it exists as a separate file") — Slice 2's own Pre-RED should confirm before writing tests against an assumed file that may not exist under that name.

---

## 7. Alternatives considered

| Decision | Recommended | Rejected alternative | Why rejected |
|---|---|---|---|
| D1 mechanism | Extend `kinship()`'s own signature | A separate `applyTwinIdentity()` post-processing function | §2.2 already establishes a *true* post-hoc single-pass patch is incorrect (cannot propagate to descendants); a "post-hoc" function that instead re-walks the full depth-loop traversal is not meaningfully simpler than editing `kinship()` itself, and duplicates the recursive algorithm |
| D2 validation | Trust a pre-validated `twinRelations`; lightweight self-checks only | Add a `sex` parameter to `kinship()` and fully validate internally | Disproportionate signature disruption to a function with 37 total call sites, for a benefit (defending against a caller who bypasses the existing validator) no real call site in this codebase needs |
| Slice boundary | 3 slices: algorithm core → script-callable functions → full Shiny wiring | Land Slices 1-2 together (algorithm + script functions in one session) | Slice 1 alone is independently useful and independently verifiable (any script user benefits immediately); bundling risks the "1 and done" / vertical-slice discipline this project's `SESSION_RUNNER.md` requires — each slice maps to one clean, separately-committable, separately-verifiable unit |

---

## 8. Close-out checklist mapping

1. **Citation checklist (issue #120)** — likely N/A (a correctness fix, not a new displayed statistic); the Slice 1 implementing session should state this explicitly in its own close-out rather than silently omit it, per the `issue137` plan's own precedent.
2. **Tutorial/article documentation checklist (Session 436)** — applies at Slice 3 only (the first point this becomes a reachable, user-facing Shiny capability): `vignettes/manual_components/_pedigree_browser.Rmd` and/or `vignettes/articles/colony-manager-guide.qmd`, noting that a correctly-computed kinship value now reflects declared MZ twins app-wide, not just the Diagram tab's visual connector.
3. **`NEWS.Rmd` entry checklist (Session 448)** — applies at Slice 3 (the user-facing capability), current development-version section. Slices 1-2 are internal/script-level signature additions to already-`@export`ed functions gaining a new optional parameter — a defensible case exists for a `NEWS.Rmd` entry at Slice 2 as well (new parameters on exported functions), which the Slice 2 implementing session should decide rather than this document.
4. **`a2interactive.Rmd` script-callable-function checklist (Session 450/478)** — deferred, not same-slice, per its own standing rule; `kinship()`/`reportGV()`/`gvaConvergence()`/`createSimKinships()`/`cumulateSimKinships()` all gain a new parameter on an already-documented function, which is exactly the shape this checklist covers once the feature has stabilized past Slice 2.
5. **GitHub issue close-out checklist** — not yet applicable; this item has no GitHub issue yet (§10 note). If filed before or during Slice 1, `gh issue close` applies at whichever slice ships last (Slice 3), matching the established multi-slice precedent (e.g. issue #137, #152).
6. **Lint close-out checklist** — `lintr::lint_package()` on touched files, each slice, before that slice's own close-out.
7. **`CHANGELOG.md` ledger-format** — each slice's own close-out prepends a dated `### YYYY-MM-DD · [BL-N]` (or `[issue #N]` if filed by then) entry above `## Legacy history`.

---

## 9. Provenance

This document was produced in Session S550 (2026-08-13) from direct evidence gathered this session, not a prior research pass:

1. `docs/audits/KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md` (S549) — the triggering finding, its worked numeric example, and its 10-subject fixture, all reused directly (§1.1, §4 Slice 1's proposed test fixture).
2. kinship2's own `kinship.pedigree` S3 method, deparsed directly from the installed namespace this session (`getS3method("kinship", "pedigree")`) — not the Rd summary alone — reproduced in full in §2.1.
3. An AST-level call-site inventory of this codebase, run this session via a standalone `Rscript` parse-and-walk over every `R/*.R` and `tests/testthat/*.R` file (script retained at `/private/tmp/claude-501/.../scratchpad/count_kinship_calls.R` for this session only, not committed to the repo), correcting the triggering audit's own text-grep-based "15 call sites" estimate to the AST-verified 7 production / 30 test split in §2.4.
4. Direct reads of `R/kinship.R`, `R/applyKinshipOverrides.R`, `R/reportGV.R`, `R/gvaConvergence.R`, `R/createSimKinships.R`, `R/cumulateSimKinships.R`, `R/makeSimPed.R`, `R/appServer.R`, `R/modPedigree.R`, `R/modBreedingGroups.R`, `R/modSummaryStats.R`, `R/modGeneticValue.R`, `R/checkTwinRelations.R`, `R/obfuscateTwinRelations.R`, `R/readTwinRelations.R` — all this session, all quoted with file:line citations above.
5. A structural comparison against the two most directly relevant prior planning documents in this codebase: `docs/planning/issue137-twin-zygosity-pedigree-diagram-plan.md` (S491 — the `twinRelations` data model this plan reuses) and `docs/planning/issue145-sire-dam-left-right-placement-plan.md` (S499 — cited for its own precedent of resolving a genuine open question via a slice's own Pre-RED rather than the design document itself, applied here to Dragon 1).

No adversarial-verification pass (independent agents attempting to refute this document's claims) was run this session — unlike the `issue137` plan's own provenance record. Flagged here rather than silently omitted; the owner may wish to request one before ratifying, particularly for §2.2's mathematical propagation argument and §2.6's Monte-Carlo-non-interaction claim, both load-bearing and independently checkable but not independently re-verified by a second pass in this session.

---

## 10. Ratification status — forced vs. judgment-call decisions

**Forced by evidence already gathered (no real choice, not put to a vote):** D3 (MZ-only filter, reusing the existing validated `twinRelations` object — a direct consequence of §1.2's already-established scope).

**Genuine judgment calls that must go through an `AskUserQuestion` ratification round before this plan is RATIFIED:**

**Q1 (D1) — Where does the MZ-identity correction live?**
- **Option A — Extend `kinship()`'s own signature** with a new `twinRelations = NULL` parameter, porting kinship2's mzgrp/mzindex mechanism directly into the existing depth loop. *(This document's recommendation.)*
- **Option B — A new, separate function** (e.g. `applyTwinIdentity()`) that re-derives the same depth-loop traversal independently, called as a required second step after `kinship()`, preserving the existing "`kinship()` itself is never modified" comment literally. *(A defensible minority position — rejected here on DRY grounds, not correctness grounds.)*

**Q2 (D2) — Does `kinship()` re-validate `twinRelations` internally, or trust a pre-validated input?**
- **Option A — Trust a pre-validated `twinRelations`**, documented as a precondition; `kinship()` performs only the cheap structural checks its existing inputs allow (id existence, non-identity). *(This document's recommendation.)*
- **Option B — Add a new `sex` parameter to `kinship()`** and fully reproduce `checkTwinRelations()`'s validation rules internally, matching the `applyKinshipOverrides()` precedent of always validating at the point of use. *(Rejected here as disproportionate signature disruption — a legitimate alternative if the owner weighs defensive self-validation more heavily.)*

D3's slice plan (§4) is this document's own proposal and does not require a separate vote, per the `issue137` plan's own precedent of not putting the slice count itself to a vote.

### Ratification outcome (2026-08-13, this session)

Both questions were posed via a single `AskUserQuestion` call. The owner selected **this document's own recommended option in both cases, with no changes requested**:

- **Q1 (D1):** Option A — extend `kinship()`'s own signature with a new `twinRelations = NULL` parameter, porting kinship2's mzgrp/mzindex mechanism directly into the existing depth loop. **RATIFIED.** The Slice 1 implementing session must update the "`kinship()` itself is never modified" sentence in `R/applyKinshipOverrides.R`'s roxygen text per Dragon 2 (§6).
- **Q2 (D2):** Option A — trust a pre-validated `twinRelations`, documented as a precondition; `kinship()` performs only the cheap structural checks its existing inputs allow. **RATIFIED.**

This plan is now **RATIFIED** in full (D3 forced, D1/D2 ratified above). Implementation begins with Slice 1 in a future session, per the vertical-slice plan in §4. This plan document itself changes no `R/`, `tests/`, or `man/` content — that remains true after ratification, matching the `issue133`/`issue136`/`issue137` precedent that ratification closes the *design* session, not the implementation one.

**Note on GitHub issue filing:** this item is not yet a GitHub issue (§ header). The owner may wish to file it (or decline to, per the established "recommend, don't unilaterally file" precedent) before Slice 1 begins — not resolved here, since it is an administrative choice independent of the design questions above.
