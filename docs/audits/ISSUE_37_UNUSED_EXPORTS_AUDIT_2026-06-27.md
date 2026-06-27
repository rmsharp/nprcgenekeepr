# Audit — Issue #37: Exported Functions Not Used by the App (Session 212, 2026-06-27)

**Workstream:** `docs/methodology/workstreams/AUDIT_WORKSTREAM.md`
**Type:** Recurring-inventory re-verification (delta against the S97 audit, 2026-06-16), read-only.
**TDD phase:** N/A (no production-code surface; no `R/`, test, `NAMESPACE`, `man/`, `DESCRIPTION`, or issue-state change).
**HEAD:** `600e166d` (master, clean).

---

## Audit Summary

- **Scope:** Issue #37's premise -- the set of exported objects in `nprcgenekeepr`
  that are **not reachable from the Shiny app entry points**
  (`runModularApp` / `runGeneKeepR` / `appUI` / `appServer`) -- re-verified at HEAD
  `600e166d`, with the **delta since the S97 audit** (HEAD `a5507a35`, 2026-06-16) as the
  primary deliverable. The standing 39-export keep-as-public-API catalog was last
  established firsthand at S97; this session re-runs the reproducible method and audits
  only what moved.
- **Criteria:**
  1. Recompute the unused-export set at HEAD using the issue's own documented,
     reproducible method (call-graph reachability via `codetools::findGlobals(merge = TRUE)`).
  2. Diff against the S97 snapshot (176 vs 166 exports): what exports were **added**,
     what **entered** the unused set, what **left** it (now app-reached), and did any
     previously-reached export **regress** (fall back out of the call graph)?
  3. Classify every delta export (wire-in / keep-as-public-API / retire) with firsthand
     call-path or keep-evidence, adversarially verified.
  4. Recommend a disposition for the **issue** itself.
- **Coverage:** 220 / 220 `R/*.R` source files sourced cleanly (100%); 176 exported names
  enumerated from `NAMESPACE`; **13 delta exports** audited firsthand and adversarially
  verified (a 26-agent evidence-then-refute workflow, plus session firsthand
  confirmation of every load-bearing claim). The 37 unchanged keep-as-public-API exports
  carry their S97 disposition forward (re-confirmed unchanged by the recompute).
- **Finding count:** 0 critical · 0 moderate · 1 minor (stale issue body) ·
  5 status/inventory findings (new-export inventory; 2 exports newly wired-in; the `#29`
  rename alias; no regression; logging island stable at 0 retire).
- **Headline:** **The unused count held at 39 across 11 more days and ~10 new exports, and
  the actionable surface is still fully drained -- 0 wire-in, 39 keep-as-public-API, 0
  retire.** Of 10 exports added since S97, **9 were wired into the app at birth**; only
  `gvaConvergence` (a vignette diagnostic helper) is app-unreachable, and it is
  keep-as-public-API by the same standard as its peers. Separately, **2 exports that were
  keep-as-public-API at S97 are now app-reached** (`getPedigree`, `getPedDirectRelatives`)
  -- wired in *for free* by the file-pedigree-source refactor, the first time a #37 export
  graduated to "used" via an unrelated refactor rather than a dedicated wire-in. No export
  regressed.

---

## Method (recompute-don't-inherit)

The renv project library is not materialized in this checkout, so `pkgload::load_all`
bootstraps an empty renv and fails. Because `codetools::findGlobals` does **static
parse-tree analysis** (no execution, no package load, no dependencies), reachability was
computed by sourcing all 220 `R/*.R` files into a throwaway environment and taking the
transitive closure of `findGlobals(merge = TRUE)` over package functions, seeded at
`{runModularApp, runGeneKeepR, appUI, appServer}`. `codetools` ships in the base library,
so this reproduces the issue's method without the package installed. Script:
`scratchpad/reach_s212.R` (220/220 sourced cleanly).

**`merge = TRUE`, not `$functions` only (S97 method note, re-applied):** a function passed
to a higher-order call (`Map`/`apply`/`do.call`) lands in `$variables`, not `$functions`,
and call-position-only reachability false-flags it unused. `merge = TRUE` counts any global
reference in any position -- the correct, conservative test for "the app uses this," erring
toward "used," which is the safe direction for a package that deliberately exposes a public
API.

**Adversarial verification of the delta.** Each of the 13 delta exports was put through a
two-stage workflow: an evidence agent traced the firsthand call path (for "used") or
gathered keep-evidence (for "unused"), then an independent agent tried to **refute** the
disposition from the real files. 12 of 13 verdicts agreed; the one refutation
(`loadSpeciesOverrides`) corrected a downstream-consumer mis-attribution but **confirmed the
"used" status** -- the function is called directly at `appServer.R:74`. Every call path in
the table below was additionally re-confirmed firsthand by the session.

**S3-dispatch caveat (unchanged):** static reachability cannot prove or disprove use of the
4 S3 methods invoked via generic dispatch. They remain "cannot-prove-used," carried forward
from S97; none is in the delta set.

---

## Findings

### Finding #1 -- Inventory at HEAD: 176 exported / 137 app-used / 39 app-unused
- **Severity:** Inventory (the audit's primary measurement).
- **Evidence (recompute, HEAD `600e166d`):** `NAMESPACE` has 172 `export()` + 4
  `S3method()` = **176** exported objects (was 166 at S97). The app-entry closure reaches
  **137** of them; **39** are app-unreachable (unchanged count vs S97's 39).
- **Delta composition (exactly 4 exports moved, fully reconciled):**
  - **Left the unused set (2):** `getPedigree`, `getPedDirectRelatives` -- now app-reached
    (Finding #3).
  - **Entered the unused set (2):** `gvaConvergence` (new export, Finding #2) and
    `makeGrpNum` (the `#29` rename alias, Finding #4).
  - `39 - 2 + 2 = 39`. Every other S97-unused export is still exactly unused; every other
    S97-used export is still used.
- **Trend:** the unused count has now held at **39 across four re-verifications** (S65, S78,
  S97, S212) while the export surface grew `155 -> 158 -> 166 -> 176`. New exports arrive at
  roughly the rate old ones get wired in -- this is the package's intended public-API steady
  state, not accumulating debt.

### Finding #2 -- 10 new exports since S97; 9 wired in at birth, 1 keep-as-public-API
- **Severity:** Inventory / status confirmation.
- **Evidence:** `git diff a5507a35..HEAD -- NAMESPACE` shows exactly 10 added `export()`
  lines and **zero removals**. Firsthand call paths (all re-confirmed):

  | New export | Status | Firsthand call path (app entry -> fn) |
  |---|---|---|
  | `calcFGSE` | used | `appServer -> modGeneticValueServer -> reportGV.R:204` |
  | `calcGUSE` | used | `appServer -> modGeneticValueServer -> reportGV.R:166` |
  | `getFocalAnimalPedFromFile` | used | `appServer -> modInputServer -> modInput.R:339` |
  | `getFileDirectRelatives` | used | `... getFocalAnimalPedFromFile.R:72 -> getFileDirectRelatives` |
  | `getSpeciesGestation` | used | `appServer -> modPotentialParentsServer -> modPotentialParents.R:93` |
  | `getSpeciesMinBreedingAge` | used | `appServer -> modGeneticValueServer -> reportGV.R:134 -> correctUnknownParentMeanKinship.R:55` |
  | `loadSpeciesOverrides` | used | `appServer.R:74` (direct) |
  | `setLabKeyDefaults` | used | `appServer -> modInputServer -> ... -> getDemographics.R:39` |
  | `makeGroupNum` | used | `... fillGroupMembers.R:40` (the `#29` rename target) |
  | `gvaConvergence` | **unused** | n/a -- keep-as-public-API (Finding #4) |

- **Impact:** The wire-in rate of new exports is high (9/10 reached on arrival), consistent
  with the modular-app conversion having matured: the genetic-value SE work (`calcFGSE`,
  `calcGUSE`), the file-pedigree-source adapter, and the species-overrides config
  (`getSpeciesGestation`/`getSpeciesMinBreedingAge`/`loadSpeciesOverrides`) all shipped
  already mounted. No new wire-in candidate was created.

### Finding #3 -- 2 keep-as-public-API exports were wired in by the file-pedigree-source refactor
- **Severity:** Status confirmation (a positive delta).
- **Evidence (firsthand):** at S97 `getPedigree` and `getPedDirectRelatives` were
  app-unreachable (keep-as-public-API). At HEAD both are reached, *not* by a dedicated
  wire-in but as a side effect of the file-pedigree-source adapter
  (`getPedigreeSource`/`getFileDirectRelatives`/`getFocalAnimalPedFromFile`):
  - `getPedDirectRelatives` <- `getLkDirectRelatives.R:36` (and `getFileDirectRelatives.R:51`);
    `getLkDirectRelatives` <- `getFocalAnimalPed.R:37` <- `modInputServer`.
  - `getPedigree` <- `getPedigreeSource.R:77` <- `getFileDirectRelatives.R:48` <-
    `getFocalAnimalPedFromFile.R:72` <- `modInput.R:339` <- `modInputServer`.
- **Impact:** First instance in #37's history of an export graduating "unused -> used" via an
  unrelated refactor rather than a tracked wire-in. Net positive; no action owed. (It also
  validates the S78/S97 "keep, don't retire" stance: retiring these as "unused" at S97 would
  have been a breaking change that the refactor then needed.)

### Finding #4 -- The 2 newly-unused exports are both keep-as-public-API (0 wire-in, 0 retire)
- **Severity:** Status confirmation.
- **`gvaConvergence`** (new export): backed by `vignettes/gvaConvergence.Rmd` and
  `tests/testthat/test_gvaConvergence.R` (both confirmed firsthand); also used in
  `vignettes/articles/fg-se-validation.qmd`. It is a GVA-convergence *diagnostic* helper for
  script/vignette use, not an app feature -- documented + tested + vignette-backed -> the
  standard keep-as-public-API profile. **Not** a wire-in (no latent app surface), **not**
  retire.
- **`makeGrpNum`** (the `#29` rename alias): a genuine soft-deprecated wrapper, defined at
  `R/makeGroupNum.R:32` as `makeGrpNum <- function(numGp) { .Deprecated("makeGroupNum");
  makeGroupNum(numGp) }`, still exported (`NAMESPACE:125`) alongside the live `makeGroupNum`
  (`NAMESPACE:124`). The app's only call site (`fillGroupMembers.R:40`) now uses
  `makeGroupNum`, so the alias is app-unreachable **by design**. Disposition:
  **keep-as-public-API (deprecated alias)** -- a future-retire candidate *once its
  deprecation cycle completes* (owner-gated, tracked by the `#29` rename, not a #37 defect).
  This is **not** a stale NAMESPACE export: the alias is defined, warns, and delegates.
- **Note on `makeGrpNum`'s status change:** it moved *used -> unused* between S97 and now.
  This is the **intended** consequence of the rename (the live call moved to `makeGroupNum`),
  not an accidental regression.

### Finding #5 -- No regression; logging island unchanged; retire count stays 0
- **Severity:** Status confirmation (STABLE).
- **Evidence:** the unused set is fully accounted for by the 4-export delta above -- no
  previously app-reached export fell back out of the call graph (the only used->unused move,
  `makeGrpNum`, is the deliberate rename). The logging/error/export island (`safeExecute`,
  `logModuleEvent`, `savePlotToFile`) is unchanged -- still 0 live callers (carried from S97;
  not re-greped this session as it is outside the delta and was firsthand-confirmed at S97).
  `safeExecute` remains the lone standing conditional future-retire candidate; `makeGrpNum`
  joins it as a second (post-deprecation-cycle) conditional retire. **Active retire count: 0.**

### Finding #6 (minor) -- The issue body is stale (last updated S98)
- **Severity:** Minor (documentation).
- **Evidence:** the #37 body was last re-verified 2026-06-16 (S98) at HEAD `02728e92`
  (166 / 127 / 39). It now lags by 10 exports: it does not list the 9 new wired-in exports
  (correctly -- they are used), does not reflect `getPedigree`/`getPedDirectRelatives` as now
  app-reached, and does not carry `gvaConvergence` or the `makeGrpNum` alias in its
  catalog.
- **Recommendation:** if #37 is kept open, refresh the body to the HEAD snapshot
  (176 / 137 / 39): strike `getPedigree` and `getPedDirectRelatives` (now reached), add
  `gvaConvergence` and the `makeGrpNum` deprecated alias to the catalog. This is the same
  "update, don't close" call S62/S97 made.

---

## Items Audited -- the 13 delta exports (HEAD-verified, adversarially confirmed)

| # | Export | S97 -> S212 | Disposition | Evidence |
|---|--------|-------------|-------------|----------|
| 1 | `calcFGSE` | new -> used | used | `reportGV.R:204` |
| 2 | `calcGUSE` | new -> used | used | `reportGV.R:166` |
| 3 | `getFocalAnimalPedFromFile` | new -> used | used | `modInput.R:339` |
| 4 | `getFileDirectRelatives` | new -> used | used | `getFocalAnimalPedFromFile.R:72` |
| 5 | `getSpeciesGestation` | new -> used | used | `modPotentialParents.R:93`; `getPotentialParents.R:69`; `correctUnknownParentMeanKinship.R:63` |
| 6 | `getSpeciesMinBreedingAge` | new -> used | used | `correctUnknownParentMeanKinship.R:55` (<- `reportGV.R:134`) |
| 7 | `loadSpeciesOverrides` | new -> used | used | `appServer.R:74` (direct) |
| 8 | `setLabKeyDefaults` | new -> used | used | `getDemographics.R:39` |
| 9 | `makeGroupNum` | new -> used | used | `fillGroupMembers.R:40` (the `#29` rename target) |
| 10 | `gvaConvergence` | new -> unused | keep-as-public-API | `gvaConvergence.Rmd` + `test_gvaConvergence.R` + `fg-se-validation.qmd` |
| 11 | `getPedigree` | keep -> used | used | `getPedigreeSource.R:77` (file branch; <- `getFileDirectRelatives.R:48`) |
| 12 | `getPedDirectRelatives` | keep -> used | used | `getLkDirectRelatives.R:36`; `getFileDirectRelatives.R:51` |
| 13 | `makeGrpNum` | used -> unused | keep-as-public-API (deprecated alias) | `R/makeGroupNum.R:32` (`.Deprecated` wrapper); `NAMESPACE:125` |

**The 37 unchanged unused exports** (sim-kinship subsystem, obfuscation island,
logging/export island, founder-stats helpers, `calcFE`/`calcFG`, loop/pedigree family,
`getLkDirectAncestors`, AutoID/QC, example-data builders, small utilities, 4 S3 methods)
carry their S97 keep-as-public-API disposition forward unchanged -- see
`ISSUE_37_UNUSED_EXPORTS_AUDIT_2026-06-16.md` for their per-export evidence.

**Totals: 39 unused = 0 wire-in · 39 keep-as-public-API · 0 retire.**

---

## Comparison with Prior Audits / Re-verifications of #37

| When | Session | Totals (exports / used / unused) | Disposition of #37 | Recommendation |
|------|---------|----------------------------------|--------------------|----------------|
| 2026-06-12 | S65 (issue comment) | 155 / 116 / 39 | Re-verified inventory; 45 of 70 originals now used | Keep open; wire-in-or-retire sim-kinship + ORIP |
| 2026-06-14 | S78 (issue comment) | 158 / 119 / 39 | Full triage: **2 wire-in · 37 keep · 0 retire** | Track wire-ins under #45/#47; keep #37 as inventory |
| 2026-06-16 | S97 (`..._2026-06-16.md`) | 166 / 127 / 39 | **0 wire-in · 39 keep · 0 retire** -- actionable surface drained | Owner: close, or keep + update stale body |
| **2026-06-27** | **S212 (this audit)** | **176 / 137 / 39** | **0 wire-in · 39 keep · 0 retire** -- 9/10 new exports wired at birth; 2 keeps graduated to used | **Owner: close, or keep + refresh body to 176/137/39** |

**Trend:** unused count flat at 39 across four re-verifications while exports grew
`155 -> 176`. The *actionable* portion has been 0 since S97 and stays 0. The signal this
session adds: the package is now wiring new exports in at birth (9/10) and even retro-wiring
old keep-as-public-API exports through refactors (Finding #3) -- the "unused export"
population is healthy steady-state public API, with no regression and no recurring defect.

---

## Recommendations

1. **#37 disposition remains an owner judgment call (not an auto-close).** Its only
   ever-actionable items -- wire-ins #47/#48 and the `getPedDirectRelatives` docfix -- were
   all discharged before S97. Nothing this session adds an actionable item. Two valid options:
   - **(a) Close #37** -- the actionable surface is drained and has stayed drained across two
     more re-verifications; this report captures the standing inventory with firsthand
     evidence. (Closing is the owner retiring the standing inventory, not an "it shipped" fact.)
   - **(b) Keep #37 open** as the living catalog of intended-public exports -- the owner's
     standing preference -- **and refresh its now-staler body** to the HEAD snapshot
     (Finding #6).
2. **No code work is owed by #37.** Active retire count = 0. `safeExecute` (zero callers
   ever) and `makeGrpNum` (post-deprecation-cycle) are the only conditional future-retire
   candidates -- neither is a defect today.
3. **Method note for the next re-verification:** keep using `findGlobals(..., merge = TRUE)`
   (not `$functions`); re-run before acting on any snapshot, since the composition drifts even
   when the count holds (this session: 4 exports moved with the count unchanged at 39).

---

*Read-only audit. No `R/`, test, `NAMESPACE`, `man/`, `DESCRIPTION`, issue-state, or
issue-body change was made by this session. Reachability script: `scratchpad/reach_s212.R`
(`merge = TRUE`). All file:line references and dispositions verified firsthand at HEAD
`600e166d` on 2026-06-27, with the 13-export delta adversarially re-verified by a 26-agent
evidence-then-refute workflow.*
