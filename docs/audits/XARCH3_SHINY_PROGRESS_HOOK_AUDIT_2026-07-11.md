# NEW-12 / XARCH-3 "Shiny Progress Hook" Audit

**BACKLOG item:** "NEW-12 / XARCH-3 (READY, Effort S) — Shiny progress hook" (from
`PED_GV_AUDIT_2026-05-30.md`; the item's own text: "Mostly resolved per the S21 plan
§8: `reportGV` / `groupAddAssign` are already shiny-free with an injected
`updateProgress` hook; the only real leak `getMinParentAge` was a dead orphan
(removed in Phase 9, S35). Treat as SEPARABLE cleanup.")
**Date:** 2026-07-11 (Session 358)
**Scope gate:** A fresh, whole-`R/`-directory sweep for the defect signature (direct
`shiny::`/`library(shiny)` coupling, or in-place `Progress` construction, inside a
compute function) — not a re-use of the S21 plan's own file list. All 230 `R/*.R`
files searched; every file the sweep surfaced was read and classified.
**Status:** Audit complete. This report is the deliverable; **no code was changed in
this session** — the BACKLOG item's own claim was verified firsthand, not merely
trusted, and held up. Zero findings required a fix.

---

## 1. Audit Summary

- **Criteria.** For every GV/PED-domain compute function that reports progress: (a)
  does it depend on Shiny directly (a `shiny::` call, `library(shiny)`/
  `require(shiny)`, or in-function `Progress$new()`/`withProgress()`/`incProgress()`
  construction) such that calling it outside a Shiny session would fail or behave
  differently, or (b) does it thread progress through a plain `function`-or-`NULL`
  parameter (`updateProgress`) that the *caller* supplies, guarded by
  `if (!is.null(updateProgress))`? (a) = **FAIL**; (b), or no progress reporting at
  all, = **PASS**. A `Progress`-object *construction* site is expected and correct
  **only** inside a `mod*.R` Shiny module file — construction anywhere else is a
  **FAIL**.
- **Method.** `grep -rln "shiny::"` and a separate `grep -rln
  "incProgress\|withProgress\|Progress\$new"` across all 230 `R/*.R` files (not a
  sample — every file was in scope for the grep; every file the grep surfaced was
  then read in full or with targeted context). Cross-checked the `updateProgress`
  parameter's actual call sites (not just its declaration) in every compute function
  that has one. Ran the six standalone test files covering the compute chain
  (`reportGV`, `groupAddAssign`, `geneDrop`, `convertRelationships`, `gvaConvergence`
  ×2) to confirm empirically — not just by static grep — that they pass with no
  `shiny::testServer`/session machinery involved.
- **Coverage.** 230 / 230 `R/*.R` files swept for the defect signature. 10 files
  surfaced by the sweep; all 10 classified (§3). `getMinParentAge.R`'s claimed Phase
  9/S35 deletion independently re-confirmed (file absent; corroborating detail in
  `PROJECT_LEARNINGS.md` about the `@import shiny` NAMESPACE relocation it triggered).
- **Finding count.** **0 FAIL.** 9 PASS, 1 out-of-scope-but-related observation
  (`safeExecute.R` — see §4.1; already tracked under issue #37, not this item).

**Headline.** The BACKLOG item's own claim is correct and now independently verified,
not just trusted: `reportGV`, `groupAddAssign`, `geneDrop`, `convertRelationships`,
and `gvaConvergence` are all genuinely Shiny-free in their compute logic — every one
threads progress through a plain injected `updateProgress` callback, guarded by an
`is.null()` check, with the only `shiny::` text in any of their files being a roxygen
`@param` type-reference (`\code{shiny::Progress}`), never executable code. Every
actual `Progress` object is constructed inside a `mod*.R` Shiny module file
(`modBreedingGroups.R`, `modGeneticValue.R`), which is the correct location. The six
compute-layer test files all pass standalone, with no Shiny session or
`testServer()` involved, which is the behavioral proof the static grep can only
imply. `getMinParentAge.R`, the one genuine historical leak, is confirmed deleted.
The BACKLOG item can close with 0 residual work.

---

## 2. Findings

No FAIL findings. Zero.

---

## 3. Items Audited

| File | Role | Verdict | Notes |
|---|---|---|---|
| `R/reportGV.R` | GV orchestrator (the item's primary named file) | PASS | `updateProgress` is a `function`-or-`NULL` param (L123), called at 3 checkpoints (L179-221) each guarded by `if (!is.null(updateProgress))`. Only `shiny::` text is a `@param` doc reference (L30), not code. |
| `R/groupAddAssign.R` | Breeding-group formation (the item's other named file) | PASS | Same pattern: `updateProgress` param (L129), one guarded call site (L183-184). Only `shiny::` text is a `@param` doc reference (L54). |
| `R/geneDrop.R` | Gene-drop simulation, called by `reportGV`/`gvaConvergence` | PASS | Same pattern: `updateProgress` param (L93), two guarded call sites (L121-145). Only `shiny::` text is a `@param` doc reference (L57). |
| `R/convertRelationships.R` | Relationship-matrix conversion, called by `reportGV` | PASS | Same pattern: `updateProgress` param (L35), one guarded call site (L94-95). Only `shiny::` text is a `@param` doc reference (L15). |
| `R/gvaConvergence.R` | GVA convergence driver | PASS | `updateProgress` is accepted and forwarded verbatim to `geneDrop()` (L181) — never called directly, never inspected. Only `shiny::` text is a `@param` doc reference (L70). |
| `R/getMinParentAge.R` | The item's one confirmed historical leak (`@import shiny`, 0 callers) | RESOLVED (deleted) | File does not exist — confirmed absent (`ls` returns "No such file or directory"), matching the S21 plan's Phase 9 (Session 35) deletion record. Its sole `@import shiny` contribution to `NAMESPACE` was relocated to `R/nprcgenekeepr-package.R:8` at deletion time (`PROJECT_LEARNINGS.md`, `[deletion-namespace-fallout]`) rather than silently lost. |
| `R/modBreedingGroups.R` | Shiny module — constructs the `updateProgress` closure for `groupAddAssign` | PASS | `Progress`/`incProgress` construction (L307-310) is confined to this Shiny module file, which is the correct, expected location — not a compute-layer leak. |
| `R/modGeneticValue.R` | Shiny module — constructs the `updateProgress` closure for `reportGV` | PASS | Same: `incProgress`/`withProgress` construction (L216-227) confined to this Shiny module file. |
| `R/appUI.R`, `R/runGenekeepr.R` | App shell / launcher | N/A (out of scope) | Real `shiny::`-prefixed calls, but these are the app's own UI/launch code, not GV/PED compute — Shiny coupling here is expected and correct, not the defect XARCH-3 describes. |
| `R/safeExecute.R` | Generic error-handling wrapper (not GV/PED domain compute) | Out of scope — see §4.1 | Has genuine, guarded `shiny::getDefaultReactiveDomain()`/`shiny::showNotification()` calls (L58,62), but is a general-purpose utility outside the reportGV/groupAddAssign compute chain this BACKLOG item names, and is already tracked separately under issue #37. |

**Behavioral verification (not just static grep):** `test_reportGV.R`,
`test_groupAddAssign.R`, `test_geneDrop.R`, `test_convertRelationships.R`,
`test_gvaConvergence.R`, and `test_gvaConvergence_kinshipOverrides.R` all pass
standalone (0 failures; 1 pre-existing CRAN-only skip in `test_reportGV.R`, unrelated
to this audit), confirming these functions genuinely execute outside any Shiny
session — none of the six test files reference `shiny` or `testServer()` at all.

---

## 4. Structural Observations

**4.1 — `safeExecute.R`'s guarded `shiny::` calls are a different, already-tracked
concern, not a NEW-12/XARCH-3 finding.** `safeExecute()` calls
`shiny::getDefaultReactiveDomain()` inside a `tryCatch` (defaults to `NULL` on error)
and only calls `shiny::showNotification()` if the caller opted in with `notify =
TRUE` *and* a live session exists (`!is.null(session)`) — it degrades cleanly with no
Shiny session running, and its own test suite (`test_modErrorHandling.R`, 33
assertions) passes standalone confirming that. This is architecturally sound
(optional, guarded, session-checked), not the "progress threaded unconditionally
into compute" pattern XARCH-3 was scoped to. Separately, issue #37 ("Exported
functions not currently used by app," re-verified Session 98 / 2026-06-16) already
flags `safeExecute` as having "zero callers anywhere, ever" and names it the "lone
conditional future-retire candidate" among the package's unused exports — that is the
correct home for any future decision about this function's fate, not this item.

**4.2 — The injected-callback pattern is applied consistently, not ad hoc.** All five
GV compute functions that accept `updateProgress` use the identical shape
(`function or NULL`, `if (!is.null(updateProgress)) updateProgress(...)`), and both
call sites that actually construct a `Progress` object live in `mod*.R` Shiny module
files. This is a reference implementation worth preserving as the template for any
future compute function that needs progress reporting — the pattern, not just this
one item's compliance with it, is what should be checked if a new long-running
compute function is added later.

**4.3 — The BACKLOG item's own text was accurate, not optimistic.** Unlike the
predecessor `read.csv()` audit (S356), which found the prior session's own count had
undercounted the true scope, this item's "mostly resolved... treat as SEPARABLE
cleanup" phrasing held up exactly as written once independently re-verified against
the actual `R/` tree rather than trusted from the S21 plan's text alone.

---

## 5. Comparison with Prior Audits

| Metric | `READCSV_COLCLASSES_AUDIT_2026-07-11.md` (S356) | This audit (S358) |
|---|---|---|
| Total findings | 0 FAIL / 6 ALREADY-FIXED / 21 PASS | 0 FAIL / 9 PASS / 1 out-of-scope observation |
| Critical findings | 0 | 0 |
| Predecessor's own claim held up? | No — undercounted by 1 file, several sites | Yes — the BACKLOG item's text was accurate |
| Coverage | 27/27 call sites, 12/12 files | 230/230 `R/*.R` files swept; 10/10 surfaced files classified |

---

## 6. Recommendations

1. **Remove the `BACKLOG.md` item.** Its own stated deliverable — confirm the
   Shiny-progress-hook concern is resolved — is fully answered: it is, and was
   verified firsthand rather than re-trusted from the S21 plan.
2. **No code change is warranted.** The injected-`updateProgress` pattern (§4.2) is
   already the right shape; there is nothing to refactor.
3. **If `safeExecute()`'s disposition is ever revisited** (issue #37's "lone
   conditional future-retire candidate" framing), do it under issue #37, not as a
   XARCH-3 follow-up — the two are unrelated defect classes that happen to share the
   word "Shiny."
