# Issue #13 Plan — Assign kinship coefficients into the kinship matrix from outside information

**Tracks:** GitHub issue **#13** ("Assign kinship coefficients into the kinship coefficient matrix based on outside information"). Filed 2020-11-20 with an **empty body** (title only); classified "genuinely open, large" in the S62/S95 backlog audits. Part of the older external-data cluster (#10/#11/#12/#28) but mechanically distinct: #13 *injects known kinship*, it does not pull from an external system.

**Authored:** Session 213 (2026-06-27), **planning/design session**. The owner picked this as the session deliverable. The TDD code-phases (RED / GREEN / REFACTOR) are **inapplicable to this document** — it is a design doc, not code. Each implementation slice in §4 is its own strict-TDD session (RED → GREEN → REFACTOR), one slice per session (FM #18/#25: do not bundle plan + implementation, do not bundle slices).

**Two owner decisions already made at Phase 1 (S213, via `AskUserQuestion`):**
- **Deliverable = a design document** (this file), not implementation and not a thin slice now.
- **Semantics = pair-level overrides** — a table of `(id1, id2, kinship)` values that **set** the corresponding matrix cells (and the symmetric twin). One mechanism covers molecular/genomic estimates, known-but-unrecorded relationships, and manual corrections. The pedigree-derived value is replaced for those pairs only; everything else is unchanged. (This settles **D3** below; the remaining decisions D1–D2, D4–D10 carry recommendations flagged for owner ratification.)

**Status: DRAFT — recommendations flagged for owner ratification.** Per the issue #9 / issue #73 precedent, drafting and ratification are **separate sessions**: this session writes the plan; a follow-up session ratifies §3 (an `AskUserQuestion` pass or `/grill-me`) **before the first implementation slice declares RED**. The RED test numbers depend on the ratified decisions.

**Adversarial verification (S213):** the draft was put through a 3-agent verification workflow (citation accuracy — 54 citations checked, 1 minor name fixed; consumer-inventory completeness; design red-team). The core symmetric-REPLACE-at-`reportGV:118` mechanism was **confirmed sound**, but the pass surfaced four substantive issues now folded in: §2C gained the missed consumers; **D5** (soft-drop must live in `reportGV`, not only the loader), **D6** (kinship range / `f`-vs-`r`), and the new **D11** (stacking with the issue-#9 correction) were added/revised; Slice 1/3 specs and §6 dragons updated.

> **Scope.** This is the planning deliverable. **No `R/`, `tests/`, `man/`, `NAMESPACE`, or `data/` content is changed by writing it.** Evidence-based inventory in §2 is firsthand (`file:line` read this session).

---

## 1. Context

### What #13 asks for

The title is the whole spec: *assign kinship coefficients into the kinship coefficient matrix based on outside information.* "Outside information" = anything not derivable from the studbook pedigree — e.g. molecular/genomic relatedness estimates, a known sib pair whose shared parent was never recorded, or a manual correction. The user supplies those known values and they are written into the kinship matrix so the genetic analyses that read the matrix use the corrected numbers.

### The matrix is a single choke point — confirmed firsthand

`kinship()` (`R/kinship.R:69`, signature `kinship(id, father.id, mother.id, pdepth, sparse = FALSE)`) is a **custom** implementation (Therneau/Lange algorithm; **not** the `kinship2` package — it is not a dependency). It returns a square base-R matrix with `dimnames(kmat) <- list(id, id)` (`R/kinship.R:109`) — rows and columns named by animal id. The off-diagonal cell `kmat[a, b]` is the kinship coefficient of animals `a` and `b`; the diagonal `kmat[i, i]` is self-kinship `(1 + f_parents)/2` (`R/kinship.R:104`), i.e. `0.5` for a non-inbred animal.

Every genetic consumer reads that one object. `kinMatrix2LongForm()` already converts it to exactly the `(id1, id2, kinship)` long form the owner described (`R/kinMatrix2LongForm.R:27`), and `filterKinMatrix()` subsets it by id (`R/filterKinMatrix.R:27`). So a pair-level override is, mechanically, "write `kmat[id1, id2]` and `kmat[id2, id1]`."

### Two existing precedents to follow, not invent

The project already has a fully-built pattern for "the user supplies an optional file that modifies a computed result," shipped under issue #73 Part 2:

1. **Optional config-file path + soft loader/validator/merge** — `getSpeciesOverridesPath()` (`R/getSpeciesOverridesPath.R:44`, a `getConfigApiKey`-style soft-lookup returning `""` when absent) → `loadSpeciesOverrides()` (`R/loadSpeciesOverrides.R:42`: returns an empty struct on a missing path `:49`, `tryCatch` soft-fail `:67`, `utils::read.csv` `:96`, required-column check `:97-106`, merge `:111`). Reader-test isolation template: `test_loadSpeciesOverrides.R`.
2. **Shiny upload + validator + merge** — for *dataset-specific* supplemental data (genotypes, optional pedigree): `getGenotypes()` (`R/getGenotypes.R`) reads by extension; `checkGenotypeFile()` validates non-fatally (`R/checkGenotypeFile.R:38` — ≥3 cols `:41`, id-first `:43`, banned names `:45`); `addGenotype()` merges on `"id"` (`R/addGenotype.R`). Validator-test template: `test_checkGenotypeFile.R`.

And `reportGV()` **already accepts `NULL`-default override parameters** (`breedingTable, gestationTable, breedingAgeDefault, gestationDefault`, `R/reportGV.R:101-104`, from issue #73) — so "thread an optional, `NULL`-default override into `reportGV` and default to identical-to-today" is an established in-repo pattern, not a new idea.

---

## 2. Evidence-based inventory (firsthand — every line read this session)

### 2A. Matrix computation and the leaf helpers

| Function | File:line | Relevant fact |
|---|---|---|
| `kinship(id, father.id, mother.id, pdepth, sparse = FALSE)` | `R/kinship.R:69` | custom Therneau/Lange; **not** `kinship2` |
| diagonal (self-kinship / inbreeding) | `R/kinship.R:104` | `kmat[i, i] <- (1L + kmat[mom, dad]) / 2L` |
| dimnames | `R/kinship.R:109` | `dimnames(kmat) <- list(id, id)` — id-named rows/cols |
| `meanKinship(kmat)` | `R/meanKinship.R:22-23` | `colMeans(kmat, na.rm = TRUE)` — includes the diagonal |
| `filterKinMatrix(ids, kmat)` | `R/filterKinMatrix.R:27` | id-named subset |
| `kinMatrix2LongForm(kinMatrix, removeDups = FALSE)` | `R/kinMatrix2LongForm.R:27` | matrix → `id1, id2, kinship` data frame |
| `getAnimalsWithHighKinship(kmat, ped, threshold, currentGroups, ...)` | `R/getAnimalsWithHighKinship.R:45` | long-form + threshold filter |
| `convertRelationships(kmat, ped, ids = NULL, updateProgress = NULL)` | `R/convertRelationships.R:36` | kinship as relationship-class tiebreaker |

### 2B. `kinship()` call sites in `R/` — the blast radius if changed at the matrix level

| Caller | File:line | Overrides desired? |
|---|---|---|
| `reportGV` | `R/reportGV.R:118` (`kmat <- filterKinMatrix(probands, kinship(...))`) | **Yes** — primary (mean kinship → GV rankings) |
| `modBreedingGroups` (fallback recompute) | `R/modBreedingGroups.R:173` | Yes (Slice 3) |
| `modSummaryStats` (fallback recompute) | `R/modSummaryStats.R:357` | Yes (Slice 3) |
| `gvaConvergence` (diagnostic) | `R/gvaConvergence.R:126` | Optional / low priority |
| `createSimKinships` | `R/createSimKinships.R:58` | **No** — simulates *future* kinship |
| `cumulateSimKinships` | `R/cumulateSimKinships.R:61` | **No** — simulation |

**Implication (load-bearing):** overriding *inside* `kinship()` would force every caller — including the two simulations, which model future not current kinship — to take overrides, and changes a 6-caller signature. Keep `kinship()` untouched; apply overrides with a separate leaf function at the consumer level (D1).

### 2C. Downstream consumers and the contract an injected matrix must satisfy

- **GV rankings (primary):** `reportGV.R:118` builds `kmat` → `:124` `indivMeanKin <- meanKinship(kmat)` → z-scores → ranking; the issue-#9 `correctUnknownParentMeanKinship(indivMeanKin, ped, ...)` runs at `:134` **on top of** the mean kinship. `reportGV` returns the matrix as `$kinship` at `:245`. **Because overrides would be applied to `kmat` before `:124`, both `meanKinship` and the #9 correction automatically see them — no separate threading into the #9 path.**
- **Breeding groups:** `modBreedingGroupsServer(id, pedigree, geneticValues = NULL)` (`R/modBreedingGroups.R:153`). `getKinshipMatrix()` (`:160`) prefers `geneticValues()$kinship` (the matrix `reportGV` returned) and **falls back to a fresh `kinship()`** at `:173`; `kmat <- getKinshipMatrix(...)` `:213` → `groupAddAssign(...)` `:280`. Threshold default `0.015625` (≈ 2nd cousins) gates co-housing.
- **Summary stats / relationships / export:** `modSummaryStatsServer(..., kinshipMatrix = NULL, ...)` (`R/modSummaryStats.R:294`). `getKinshipMatrix()` reactive (`:341`) prefers the passed `kinshipMatrix()` `:346-347`, else fresh `kinship()` `:357`; → `convertRelationships(kmat, ped)` `:365`; CSV export `write.csv(getKinshipMatrix(), file)` `:711`.
- **Reactive producer + other matrix readers (added per S213 verification):** `modGeneticValueServer` re-exposes the returned matrix as `kinshipMatrix = reactive({ fullResults()$kinship })` (`R/modGeneticValue.R:388-390`) — **this is the reactive the two modules above consume**, so patching `reportGV`'s `$kinship` (Slice 1) reaches them through it. `groupAddAssign(candidates, kmat, ...)` reads the matrix via `filterKinMatrix` (`R/groupAddAssign.R:134`) + `getAnimalsWithHighKinship` (`:135`); `groupMembersReturn` filters it for per-group display (`R/groupMembersReturn.R:24`). `summary.nprcgenekeeprGV()` reads `$kinship` but currently assigns-and-discards it (`R/summary.nprcgenekeeprErr.R:207`, `nolint` — "may add later"), so no override surface there today.
- **Out of scope (simulation chain):** `kinshipMatrixToKValues` (`R/kinshipMatrixToKValues.R:98`) and `kinshipMatricesToKValues` (`R/kinshipMatricesToKValues.R:96`) long-form *simulated* kinship matrices fed by `createSim`/`cumulateSim`; per D8 the simulations take no overrides, so these are correctly excluded.
- **Not affected:** genome uniqueness (gene-drop simulation, not the matrix) — correct; an outside *kinship* value should not silently move genome uniqueness.

**Architectural finding:** both modules consume the GV module's returned `$kinship` via reactive, with a `kinship()` *fallback recompute* when GV output is unavailable. So overrides applied inside `reportGV` reach breeding groups + summary stats **transitively** whenever those tabs run after the GV tab; only the **fallback recompute** paths (`:173`, `:357`) miss them. That divides the work cleanly (Slice 1 = reportGV; Slice 3 = the fallback paths).

### 2D. Override-loading precedents (the templates to copy)

| Concern | Precedent | File:line |
|---|---|---|
| Optional config key (soft-lookup, `""` if absent) | `getConfigApiKey` / `getSpeciesOverridesPath` | `R/getConfigApiKey.R:12`, `R/getSpeciesOverridesPath.R:44` (generic key reader `:18-29`) |
| Soft loader (empty/built-in on missing, `tryCatch` on malformed) | `loadSpeciesOverrides` | `R/loadSpeciesOverrides.R:42,49,67` |
| CSV read + required-column validation | `readAndMergeSpeciesOverrides` (read.csv + `setdiff(required, names)`) | `R/loadSpeciesOverrides.R:92,96,97-106` |
| Upload + non-fatal validator (dataset-specific data) | `getGenotypes` + `checkGenotypeFile` | `R/getGenotypes.R`, `R/checkGenotypeFile.R:38-45` |
| Documented optional config key | `speciesOverridesPath` example | `inst/extdata/example_nprcgenekeepr_config:61,74` |

### 2E. Tests that pin current behavior (TDD anchors / regression guards)

| Test | What it pins | Touched by |
|---|---|---|
| `test_kinship.R` | `kinship()` matrix values + dimnames | none — **regression guard** (kinship() untouched) |
| `test_meanKinship.R` | `colMeans` semantics | none — regression guard |
| `test_filterKinMatrix.R` | id-named subsetting | none — regression guard |
| `test_reportGV.R` | `reportGV` on `qcPed`; column set; #86 `fg` pin; bundled-report `fgSE` | Slice 1 (new `kinshipOverrides` tests; **no-override path stays byte-identical**) |
| `test_groupAddAssign.R`, `test_modBreedingGroups*.R` | group formation + threshold | Slice 3 |
| `test_modSummaryStats*.R`, `test_convertRelationships.R` | relationship display / export | Slice 3 |
| `test_loadSpeciesOverrides.R` | reader: temp file, missing → empty, malformed → soft-fail; `withr::local_tempdir()` + `local_envvar(HOME)` isolation | **Copy this isolation pattern** for the new reader test (Slice 2/3) |
| `test_checkGenotypeFile.R` | non-fatal validator structure | **The validator-test template** for `checkKinshipOverrides` (Slice 1) |

**Gap:** no test injects an outside kinship value and asserts it reaches an analysis. That is the new coverage #13 adds.

---

## 3. Design decisions (recommendations for owner ratification)

Settle these before the first slice declares RED. D3 is already decided (owner, Phase 1). Each other item shows options + a **recommendation**; dragons are flagged.

**D1 — Injection level (load-bearing).**
Options: (a) override *inside* `kinship()`; (b) a **separate leaf** `applyKinshipOverrides(kmat, overrides)` that patches a computed matrix, applied at the consumer level.
**Recommend (b).** `kinship()` has 6 callers (§2B) including two simulations that must NOT take current-kinship overrides; (b) keeps that signature and the 5 non-primary callers untouched, is unit-testable in isolation, and mirrors the issue-#73 "leaf function + thread a `NULL`-default param" pattern. **This is the load-bearing blast-radius boundary — the issue-#9 plan enforced the identical "never change `kinship()`" rule.** *Ratify.*

**D2 — Override data model / CSV schema.**
**Recommend:** long form `id1` (character), `id2` (character), `kinship` (numeric), header required, matched by name — identical to `kinMatrix2LongForm()` output, so a user can export the current matrix, edit a few rows, and feed it back. The in-memory function API takes this as a data frame; the file form is the same columns as CSV. *Ratify the column names (`id1`/`id2`/`kinship`).*

**D3 — Override semantics = REPLACE the cell. (DECIDED — owner, Phase 1.)**
`applyKinshipOverrides` sets `kmat[id1, id2] <- kmat[id2, id1] <- value` (symmetric write). The pedigree-derived value for that pair is discarded in favor of the outside value; all other cells unchanged. **Documented v1 limitation (dragon):** this is a *direct cell* replacement — it does **not** propagate to descendants (overriding a sire–dam pair does not recompute their offspring rows). A pedigree-consistent propagation is a much larger feature; v1 honors the literal "assign coefficients into the matrix." *No decision needed; recorded.*

**D4 — Off-diagonal only, or allow self/inbreeding overrides (`id1 == id2`)?**
The diagonal stores self-kinship `(1+F)/2`, not the inbreeding coefficient `F` — so a self-pair override is ambiguous (is the supplied number a kinship or an `F`?).
**Recommend: off-diagonal only in v1** (require `id1 != id2`; reject/drop self-pairs in the validator). Self/inbreeding overrides deferred to a follow-up with explicit `F`-vs-self-kinship semantics. *Ratify; dragon (silent mis-interpretation if allowed without a defined convention).*

**D5 — Unknown-id handling (id not in the matrix). [REVISED per S213 verification — red-team finding 2.]**
`kmat` inside `reportGV` is `filterKinMatrix(probands, ...)` (`R/reportGV.R:118`, `probands = ped$id[ped$population]` at `:112`) — only the population subset; founders/ancestors and animals outside `pop` are **absent** (`R/filterKinMatrix.R:28`). The canonical use case "override a sire–dam pair" (D3) typically references **ancestors not in probands**. So a strict `stop()`-on-unknown-id leaf called directly by `reportGV` would **abort the whole run** for exactly the documented cases — and D5's own rationale ("should not abort the run") would be violated on the script path.
**Recommend:** the standalone leaf `applyKinshipOverrides(kmat, overrides)` stays **strict** (`stop()` on an id absent from `kmat`) for a clean contract; but **`reportGV` (and every app/file path) intersects the override id-set with `rownames(kmat)` and warn-drops non-member rows BEFORE calling the leaf** (or calls the leaf in an explicit soft mode). Soft handling must **not** be deferred to Slice 2 — Slice 1's `reportGV` path needs it. This mirrors the `loadSpeciesOverrides` strict-reader / soft-wrapper split, except the soft wrapper lives in `reportGV`, not only the file loader. *Ratify.*

**D6 — Validation rules (`checkKinshipOverrides`, mirroring `checkGenotypeFile`). [REVISED per S213 verification — red-team finding 3.]**
**Recommend:** required columns present (D2); `id1`/`id2` coerced to character; `id1 != id2` (D4); **duplicate (unordered) pairs → `stop()`** rather than silent last-wins (an outside source giving two values for one pair is a data error the user must resolve). **Range:** `kinship` numeric and not NA; reject `< 0`. A naive `<= 1` upper bound is **too loose for an off-diagonal cell**: for non-inbred animals the diagonal is `0.5` (`R/kinship.R:104`) and Cauchy–Schwarz bounds off-diagonal kinship at `<= sqrt(f_ii·f_jj)` — i.e. `<= 0.5` for non-inbred pairs (identical twins are the max at `0.5`), so a value in `(0.5, 1]` exceeds the diagonal and breaks positive-semi-definiteness. **Recommend warn (or reject) off-diagonal values `> 0.5`** (use the exact `sqrt(diag·diag)` bound for inbred pairs when the matrix is in hand). **Critically, `kinship` is the kinship coefficient `f`, NOT the coefficient of relatedness `r` (= 2f for non-inbred):** supplying `r` (e.g. `0.5` for half-sibs whose true `f = 0.125`) passes a `[0,1]` check and silently corrupts the matrix — state `f`-not-`r` in the `@param` docs and the CSV template header. *Ratify the upper-bound policy (warn vs reject `> 0.5`) and the duplicate policy.*

**D7 — App delivery mechanism (load-bearing for the app slices).**
The leaf + `reportGV` param (Slice 1) is delivery-agnostic and usable from a script today. For the *app*, options: (a) **Shiny upload** (genotype-style — per-session, dataset-specific); (b) **config-file path** (species-overrides-style — site-wide); (c) both.
**Recommend (a) Shiny upload.** Outside kinship is *dataset-specific* supplemental data tied to the animals being analyzed (exactly like genotypes), not a stable site setting — the genotype upload (`getGenotypes`/`checkGenotypeFile`) is the closer semantic precedent and gives per-analysis control. The config-path loader can be added later for batch/script users at low cost (it reuses the same validator + leaf). *Load-bearing — ratify; it sets the Slice 2 shape.*

**D8 — Which consumers apply overrides, and in what order.**
**Recommend:** Slice 1 = `reportGV` (mean kinship → GV rankings; the primary axis named in the issue, and it feeds breeding groups + summary stats transitively via the GV reactive, §2C). Slice 2 = app delivery wired to the GV module. Slice 3 = the breeding-group + summary-stats **fallback recompute** paths (`:173`, `:357`) so overrides hold even when those tabs run without GV output, plus relationship/export display. Simulations (`createSim`/`cumulateSim`) are **out of scope**. `gvaConvergence` (diagnostic) optional follow-up. *Ratify the scope exclusions.*

**D9 — Provenance / transparency.**
A silent replacement is a trust risk (the user may not realize a pedigree value was overwritten).
**Recommend:** `applyKinshipOverrides`/`reportGV` emit a `message()` summarizing "N kinship overrides applied" (and warn on dropped rows). v1 does **not** add per-cell matrix metadata (a base matrix can't carry it cleanly) and does **not** add a "was-overridden" report column. Richer provenance (a returned applied-overrides table, a flagged report column) is a documented follow-up. *Ratify whether a message suffices for v1.*

**D10 — Backward-compatibility invariant (hard, every slice).**
All new parameters default to `NULL`; `kinshipOverrides = NULL` ⇒ `applyKinshipOverrides` is a no-op ⇒ the matrix is identical to today; no upload / no config ⇒ behavior byte-identical to today. The no-override path is an explicit acceptance test in **every** slice. *No decision — invariant.*

**D11 — Interaction with the issue-#9 unknown-parent mean-kinship correction (load-bearing genetics decision). [ADDED per S213 verification — red-team finding 1.]**
Applying the override to `kmat` before `meanKinship` (`R/reportGV.R:124`) means it also feeds `correctUnknownParentMeanKinship` at `:134`, which for an animal missing exactly one parent **adds `sexMean/2`** on top (`R/correctUnknownParentMeanKinship.R:145` one-unknown detection, `:155` loop, `:175` `corrected = min(original + sexMean*0.5, 1)`). The feature's headline use case (D3) — "a known relationship whose shared parent was never recorded" — is **precisely a one-unknown-parent animal**, i.e. exactly the #9 trigger set. So an override for such an animal does **not replace** the #9 statistical estimate; it **stacks** the user's known value with the `+sexMean/2` estimate, and (via the uncorrected `original` snapshot at `R/correctUnknownParentMeanKinship.R:153`) the overridden value also propagates into *other* animals' corrections through their `sexMean`. The earlier framing that "the #9 correction automatically sees them" is therefore a **risk, not a pure benefit**.
**Recommend:** make `correctUnknownParentMeanKinship` override-aware — **exclude any animal that carries an applied override from the `+sexMean/2` correction** (the user's outside info supersedes the statistical stand-in for that animal), and decide whether overridden ids are also excluded from other animals' `sexMean` cohorts (or document that they are not). Alternative: explicitly document that overrides and the #9 estimate **stack** and accept it. **This is the #1 dragon — a genetics-methodology call, the owner's to make; strongly consider `/grill-me` to settle it, as issue #9's D2 was settled.** A regression test must pin the chosen behavior for a one-unknown-parent animal that is also overridden. *Ratify.*

---

## 4. Implementation plan — vertical slices (one strict-TDD session each)

Vertical, not horizontal (FM #25): each slice ships a working end-to-end narrow path. "If I stop after this slice, does something work?" — yes for each. The validator + leaf are built in their first consumer (Slice 1), not as standalone infrastructure (that would be a horizontal slice).

### Slice 1 (first) = function-level core: outside kinship changes GV rankings from a script
**Why first:** the smallest end-to-end useful path (no UI), independent of the unratified delivery decision (D7), and it builds the leaf + validator that every later slice reuses. A script user gets the whole feature: `reportGV(ped, kinshipOverrides = data.frame(id1=, id2=, kinship=))`.
**Scope:** (1) new exported leaf `applyKinshipOverrides(kmat, overrides)` (D1/D3): validate via (2), then symmetric-write each pair; `stop()` on unknown id; no-op + return `kmat` unchanged when `overrides` is `NULL`/empty; `message()` the count (D9). (2) new `checkKinshipOverrides(overrides)` validator (D6, mirror `checkGenotypeFile`): required columns, numeric kinship (not NA, reject `< 0`, warn/reject off-diagonal `> 0.5`), `id1 != id2`, duplicate-pair `stop()`. (3) add `kinshipOverrides = NULL` to `reportGV` (mirror the existing `breedingTable = NULL` params at `R/reportGV.R:101-104`); **intersect the override id-set with `rownames(kmat)` and warn-drop non-proband rows (D5) BEFORE** calling the strict leaf; apply the survivors to `kmat` **immediately after `R/reportGV.R:118` and before `meanKinship` at `:124`**; **handle the #9 interaction per the ratified D11** (exclude overridden animals from the `correctUnknownParentMeanKinship` `+sexMean/2` correction, or the ratified alternative). (4) `NAMESPACE`/`man` for the two new exported functions; the leaf `@param`/CSV-template docs state `kinship` is `f`-not-`r` (D6) and the matrix is a dense, symmetric, id-named base matrix.
**RED:** (a) `test_applyKinshipOverrides.R` — a small named fixture matrix; overriding `(a,b)=0.25` sets both `kmat["a","b"]` and `kmat["b","a"]`; `NULL`/empty ⇒ identical matrix; unknown id ⇒ `stop()` (strict leaf); off-diagonal-only holds. (b) `test_checkKinshipOverrides.R` — accepts a valid frame; rejects missing column, NA/`< 0` kinship, **off-diagonal value `> 0.5` (D6)**, `id1==id2`, duplicate pair. (c) `test_reportGV.R` — `reportGV(qcPed, kinshipOverrides = <frame raising one real pair>)` changes that pair's mean kinship / ranking vs the no-override baseline; **a non-proband id in the override frame warns and is dropped rather than aborting `reportGV` (D5)**; **a one-unknown-parent overridden animal follows the ratified #9-interaction behavior (D11)**; **`reportGV(qcPed)` output is byte-identical to today** (D10).
**GREEN:** implement (1)–(4) minimally.
**DONE looks like:** a script user supplies `(id1,id2,kinship)` and the GV mean-kinship ranking reflects it; with no overrides the report is byte-identical to today; two new functions exported + documented.
**Verify:** `Rscript -e 'suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_applyKinshipOverrides.R", reporter="summary")'` (repeat for the validator + `test_reportGV.R`); clean regression read (`as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))`, check `sum(failed)`+`sum(error)` isolating `!grepl("test-app-|test-e2e-", file)`); build-equivalent `devtools::check(vignettes = FALSE)` → 0/0/0 (Learning 161); `spell_check_package(".")` = 0 (a 0/0/0 check does not imply spelling-clean). **No `runModularApp()` smoke** — no Shiny/runtime wiring changes in Slice 1.
**Session boundary:** one session. Close out. **NEWS** entry (user-facing: `reportGV` gains `kinshipOverrides`; two new exports) folded into the publish PR (Learning 157a); PR uses **"Relates to #13"**.
**Dragons:** keep `kinship()` untouched (6 callers, §2B); the apply must be **after** `filterKinMatrix`/`kinship` at `:118` and **before** `meanKinship` at `:124`; symmetric write (set both `[id1,id2]` and `[id2,id1]`); `message()`, not `print()`; **soft-drop non-proband ids in `reportGV` — do not let the strict leaf abort the run (D5/R2-finding)**; **reconcile with the #9 `+sexMean/2` correction (D11 — the #1 dragon)**; **validate `f`-not-`r` and reject off-diagonal `> 0.5` (D6)**; **document the leaf's dense, symmetric, id-named base-matrix assumption** (a sparse `Matrix` object is out of contract).

### Slice 2 = app delivery: upload outside kinship in the GV tab (gated on D7)
**Prerequisite:** D7 ratified (recommended: Shiny upload). If config-path is chosen instead, swap the upload UI for a `getSpeciesOverridesPath`-style key + a `loadKinshipOverrides()` soft loader, reusing Slice 1's validator.
**Scope (Shiny-upload path):** (1) a file input in the Genetic Value tab (accept `.csv/.txt/.xlsx/.xls`, mirror `modInput` genotype upload); (2) read via a `getGenotypes`-style reader → Slice 1's `checkKinshipOverrides` (non-fatal: bad file ⇒ warn, ignore — D5); (3) pass the validated frame into the `reportGV(...)` call in `modGeneticValueServer` (the call that already threads `breedingTable` etc.). Overrides now flow to the app GV rankings — and **transitively** to breeding groups + summary stats whenever they consume the GV reactive (§2C).
**RED:** a `testServer(modGeneticValueServer, ...)` test that an injected override reactive reaches `reportGV` and changes the displayed ranking; an empty/absent upload ⇒ identical to today; a malformed file ⇒ warn + unchanged.
**GREEN:** implement minimally. **Backward-compat:** no upload ⇒ `NULL` ⇒ identical to today.
**DONE looks like:** uploading an outside-kinship CSV in the GV tab changes the rankings; no upload ⇒ unchanged.
**Verify:** targeted `testServer` test (`NOT_CRAN=true`); clean regression read; 0/0/0; **Phase-3E runtime smoke REQUIRED** (Shiny wiring change, FM #24): launch `runModularApp()`, upload a small override CSV, confirm the GV ranking moves and a no-upload launch is unaffected.
**Session boundary:** one session. Close out. NEWS entry; PR **"Relates to #13"**.
**Dragons:** non-fatal validation in the app (never abort the run on a bad override file — D5); the upload is dataset-specific (cleared when the pedigree changes); confirm the transitive flow to breeding groups/summary stats actually fires (they must consume GV output, not their fallback).

### Slice 3 = secondary consumers + fallback paths + close #13
**Scope:** apply overrides on the **fallback recompute** paths so they hold even when a tab runs without GV output: `modBreedingGroups.R:173` and `modSummaryStats.R:357` (apply Slice 1's leaf to the freshly recomputed `kmat`, sourced from the same override input as Slice 2). Confirm breeding-group co-housing (threshold `0.015625`) and the relationship table / kinship CSV export (`modSummaryStats.R:711`) reflect overrides. Optionally the `gvaConvergence` diagnostic.
**RED:** `test_modBreedingGroups*` — an override raising a pair above threshold excludes them from a shared group on the fallback path; `test_modSummaryStats*`/`test_convertRelationships` — the override shows in the relationship table / exported matrix; no-override ⇒ unchanged.
**GREEN:** implement minimally.
**DONE looks like:** outside kinship affects breeding-group formation and the summary-stats **kinship-value** column/export on every path, not only via GV output. **Note (red-team finding 4):** `convertRelationships` derives the `relation` label from the pedigree CEPH structure, consulting the kinship value only as a last-resort tiebreak (`R/convertRelationships.R:87`; long-form at `:40`); a REPLACE moves the `kinship` column but **not** the `relation` label, so an unreconciled table can show e.g. `kinship=0.5` next to `relation="No Relation"`. Slice 3 must either reconcile/flag overridden pairs in the table, or narrow this DONE to "the kinship value reflects overrides; relationship labels stay pedigree-derived" and document the divergence so users are not shown self-contradictory rows.
**Verify:** targeted tests; clean regression read; 0/0/0; **Phase-3E smoke REQUIRED** (changes displayed group formation + relationships).
**Session boundary:** one session. Close out. NEWS entry; PR **"Closes #13"** (the last slice).
**Dragons:** the two modules already prefer GV output and only recompute as a fallback (§2C) — make sure the fallback override path matches the GV-output path so results are consistent regardless of tab order; do not touch the simulations.

---

## 5. Cross-slice notes

- **Ordering rationale:** Slice 1 (script core, delivery-agnostic) → Slice 2 (app delivery, primary GV consumer) → Slice 3 (secondary consumers + fallbacks). Slice 1 is independent of the D7 ratification; Slices 2–3 are gated on it.
- **Each slice is a full RED → GREEN → REFACTOR session** with the phase-gate `AskUserQuestion` at every transition (Development Process Contract). Publish (PR → CI → merge) is a standard separate step; a **NEWS entry is user-facing and required** per slice, folded into the same PR (Learning 157a). Slices 1–2 use **"Relates to #13"**; Slice 3 uses **"Closes #13"**.
- **The backward-compat invariant (D10) is load-bearing across all slices:** every new param defaults to `NULL`; no override ⇒ byte-identical to today; tested explicitly each slice.
- **`kinship()` is never modified** — that is the blast-radius boundary (same boundary the issue-#9 work enforced).
- **`reportGV` already proves the threading pattern** (its `breedingTable`/`gestationTable` `NULL`-default params from #73) — Slice 1 adds `kinshipOverrides` the same way.

## 6. Here be dragons (consolidated load-bearing risks)

- **R1 — Never change `kinship()` (D1).** 6 callers (§2B), two of which are simulations that must not take current-kinship overrides. Apply overrides with a separate leaf at the consumer level.
- **R2 — Apply at the right point in `reportGV` (D8).** After `filterKinMatrix(probands, kinship(...))` at `R/reportGV.R:118`, before `meanKinship` at `:124`. Earlier and the override key-set may not match probands; later and mean kinship / the #9 correction miss it.
- **R3 — Symmetric write (D3).** Set both `kmat[id1,id2]` and `kmat[id2,id1]`; consumers (`kinMatrix2LongForm`, `colMeans`) assume symmetry.
- **R4 — Replace ≠ propagate (D3).** v1 patches the named cells only; it does not recompute descendant rows. Document this clearly so a user does not assume pedigree-consistent propagation.
- **R5 — Diagonal ambiguity (D4).** The diagonal is `(1+F)/2`, not `F`. Off-diagonal only in v1; reject self-pairs in the validator.
- **R6 — Strict leaf, soft loader (D5).** `applyKinshipOverrides`/`checkKinshipOverrides` `stop()` on bad input (strict contract); the app/file loader catches and warns (never aborts the run) — the `loadSpeciesOverrides` strict-reader / soft-wrapper split.
- **R7 — Backward-compat (D10).** `NULL` ⇒ no-op ⇒ identical to today; test the no-override path in every slice. Slice 1 must show `reportGV(qcPed)` byte-identical.
- **R8 — Genome uniqueness is intentionally unaffected.** It is gene-drop, not the matrix; do not "also" patch it — an outside *kinship* value should not move genome uniqueness.
- **R9 — Transitive vs fallback matrix (D8).** Breeding groups + summary stats prefer GV output (the `modGeneticValue.R:388-390` reactive) but recompute `kinship()` as a fallback (`:173`, `:357`); Slice 3 must patch the fallback too, or results differ by tab order. **Intermediate-state caveat:** after Slice 2 but before Slice 3, group formation/relationships depend on whether the GV tab was run first (the fallback recompute lacks overrides) — land the fallback patch with app delivery, or document a "run the GV tab first" requirement in NEWS/UI until Slice 3.
- **R10 — Phase-3E required for Slices 2–3** (Shiny runtime wiring). Build-clean is necessary but not sufficient (FM #24); launch the app with and without an override file.
- **R11 — Stacking with the issue-#9 correction (D11 — the #1 dragon).** Applying before `meanKinship` means a one-unknown-parent overridden animal also gets `+sexMean/2` (`R/correctUnknownParentMeanKinship.R:175`) — the override stacks with the statistical estimate for the feature's *primary* use case. Make the correction override-aware or document the stacking; pin it with a test. Genetics call — owner's to ratify.
- **R12 — Validator range + `f`-vs-`r` (D6).** Off-diagonal kinship is `<= 0.5` for non-inbred pairs; `(0.5,1]` breaks PSD. Supplying coefficient of relatedness `r` (=2f) instead of kinship `f` passes a `[0,1]` check and silently corrupts the matrix. Reject/warn `> 0.5`; document `f`-not-`r`.
- **R13 — Relationship label vs value divergence (Slice 3).** `convertRelationships`' `relation` label is pedigree-derived (`R/convertRelationships.R:51-91`), not value-derived; an override moves only the `kinship` column, so the table can self-contradict. Reconcile/flag overridden pairs, or narrow the Slice-3 claim and document.

## 7. Owner ratification checklist (resolve before Slice 1 RED)

- [ ] **D1** — injection via a separate leaf `applyKinshipOverrides` at the consumer level; `kinship()` never modified. *(recommended)*
- [x] **D3** — semantics = pair-level **replace** the cell, symmetric write, no descendant propagation in v1. *(DECIDED — owner, S213 Phase 1)*
- [ ] **D2** — CSV/data-frame schema = `id1`, `id2`, `kinship` (header required, matched by name).
- [ ] **D4** — off-diagonal only in v1 (reject `id1 == id2`); self/inbreeding override deferred.
- [ ] **D5** — strict leaf (`stop()`); **`reportGV` + every app/file path warn-drops non-member ids before the leaf (never aborts the run)** — *revised S213 verification.*
- [ ] **D6** — validation: required cols, `id1 != id2`, duplicate pair → `stop()`; **reject `< 0`/NA, warn-or-reject off-diagonal `> 0.5`, document `f`-not-`r`** — *revised S213 verification* (confirm upper-bound + duplicate policy).
- [ ] **D7** — app delivery = **Shiny upload** (genotype-style), not config-path, for v1. *(load-bearing — sets Slice 2)*
- [ ] **D8** — scope = `reportGV` (Slice 1) → app delivery (Slice 2) → breeding-group/summary-stats fallback paths (Slice 3); simulations excluded; `gvaConvergence` optional.
- [ ] **D9** — provenance = a `message()` count for v1; no per-cell metadata / report column.
- [ ] **D10** — backward-compat invariant (no override ⇒ byte-identical) is a hard acceptance test in every slice.
- [ ] **D11** — reconcile overrides with the issue-#9 `+sexMean/2` correction (exclude overridden animals, or document the stacking) — **#1 dragon, added S213 verification; genetics call, consider `/grill-me`.**
- [ ] **Slice order** — Slice 1 (script core) → Slice 2 (app upload) → Slice 3 (secondary consumers + close #13).
