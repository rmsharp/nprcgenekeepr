# Audit — Issue #37: Exported Functions Not Used by the App (Session 97, 2026-06-16)

**Workstream:** `docs/methodology/workstreams/AUDIT_WORKSTREAM.md`
**Type:** Recurring-inventory re-verification (delta against the S78 triage), read-only.
**TDD phase:** N/A (no production-code surface; no `R/`, test, `NAMESPACE`, or `man/` change).

---

## Audit Summary

- **Scope:** Issue #37's premise — the set of exported objects in `nprcgenekeepr`
  that are **not reachable from the Shiny app entry points**
  (`runModularApp` / `runGeneKeepR` / `appUI` / `appServer`) — re-verified at HEAD
  (`a5507a35`), plus the current disposition status of everything #37 has tracked.
- **Criteria:**
  1. Recompute the unused-export set at HEAD using the issue's own documented,
     reproducible method (call-graph reachability via `codetools::findGlobals`).
  2. Diff against the S78 triage snapshot (2026-06-14): what entered / left the set,
     and is the S78 disposition (2 wire-in · 37 keep-as-public-API · 0 retire) still
     accurate?
  3. Resolve every wire-in / docfix item #37 surfaced — shipped, fixed, or still open?
  4. Recommend a disposition for the **issue** itself.
- **Coverage:** 202 / 202 `R/*.R` source files sourced cleanly (100%); 166 exported
  names enumerated from `NAMESPACE`; all 39 unused exports categorized and dispositioned.
- **Finding count:** 0 critical · 0 moderate · 2 minor (stale issue body; S3 undercount) ·
  3 status confirmations (both wire-ins discharged; surfaced docfix fixed; retire-set unchanged).
- **Headline:** **The actionable surface #37 ever tracked is now fully drained.** Both
  S78 wire-in candidates shipped and their tracking issues are CLOSED (#47, #48); the one
  docfix #37 surfaced is fixed (S87); the remaining **39 unused exports are all
  keep-as-public-API by owner decision, 0 retire** (re-confirmed). #37 is now a *pure
  standing inventory* with no open work — closing it is an owner judgment call, not an
  auto-close.

---

## Method (recompute-don't-inherit)

The renv project library is not materialized in this checkout, so `pkgload::load_all`
bootstraps an empty renv and fails. Because `codetools::findGlobals` does **static
parse-tree analysis** (no execution, no package load, no dependencies), reachability was
computed by sourcing all 202 `R/*.R` files into a throwaway environment and running the
issue's documented closure over them — `codetools` ships in the base library. This
reproduces the issue's method without needing the package installed.

**A method-correctness bug was caught and fixed during this audit (the value of recompute).**
The first pass used `findGlobals(f, merge = FALSE)$functions` — call-position references
only. That flagged `chooseDate` as unused, contradicting S78 ("`chooseDate` is no longer
unused"). Firsthand check: `R/setExit.R:54` calls `Map(chooseDate, ped$death, ped$departure)`
— `chooseDate` is passed **as a value**, so it lands in `$variables`, not `$functions`. The
`$functions`-only graph **undercounts** any function handed to a higher-order call
(`Map`/`apply`/`do.call`). Re-running with `merge = TRUE` (any global reference, in any
position — the correct, conservative test for "the app uses this") moved exactly one
function (`chooseDate`) into the reached set and reconciled the result with S78. The
`merge = TRUE` choice errs toward "used," which is the safe direction for a package that
deliberately exposes a public API.

**S3-dispatch caveat (unchanged from prior runs):** static reachability cannot prove or
disprove use of S3 methods invoked via generic dispatch. The 4 unused S3 methods below are
"cannot-prove-used," not "provably dead."

---

## Findings

### Finding #1 — Both S78 wire-in candidates are discharged (status: RESOLVED)
- **Severity:** Status confirmation (was the only *actionable* content of #37).
- **Evidence (HEAD, firsthand):**
  - **ORIP module pair** — `modORIPReportingUI` mounted at `R/appUI.R:181`,
    `modORIPReportingServer` mounted at `R/appServer.R:286`. Tracking issue **#47 CLOSED**
    (shipped S83 `6fd16715`; ONPRC-gated under #49, S84; opt-in E2E S86). Now app-reached →
    correctly absent from the unused set.
  - **`getPotentialParents`** — wired through the new `R/modPotentialParents.R:150`
    (`modPotentialParentsUI` at `R/appUI.R:200`, `modPotentialParentsServer` at
    `R/appServer.R:302`). Tracking issue **#48 CLOSED** (shipped S80). Now app-reached, and
    `removeAutoGenIds` follows transitively (called at `R/getPotentialParents.R:42`) → both
    correctly absent from the unused set.
- **Impact:** S78's "① wire-in (2)" column is now fully delivered. #37 has **no remaining
  wire-in candidates.** (Umbrella **#45** stays OPEN, but only because it parents
  still-deferred **#28** — its `getPotentialParents` wire-in line is delivered.)

### Finding #2 — The docfix #37 surfaced is FIXED (status: RESOLVED)
- **Severity:** Status confirmation.
- **Evidence:** S78 flagged `getPedDirectRelatives` `@examples` (`R/getPedDirectRelatives.R`)
  as a copy-paste defect — its example invoked `getLkDirectRelatives()` instead of itself.
  At HEAD the example reads `getPedDirectRelatives(ids = "E", ped = ped)` with no stray
  `getLkDirectRelatives` call. Fixed in **S87 `2a64770f`** ("docs: fix roxygen @examples to
  invoke documented fns; backfill tests"). The S95 audit did not re-check this; this run
  confirms it closed.
- **Remaining (optional, low priority, unchanged):** S78's optional suggestion of *dedicated*
  tests for `kinshipMatrixToKValues` and `getAncestors` (currently covered only transitively
  via callers' tests) is still open — a nice-to-have, not a defect.

### Finding #3 — The "logging island" is unchanged; 0 retire (status: STABLE)
- **Severity:** Status confirmation.
- **Evidence:** `safeExecute`, `logModuleEvent`, `savePlotToFile` still have **zero callers**
  anywhere in `R/` outside their own files (grep, firsthand). The island remains reachable
  from nothing live; modules still use ad-hoc `message()`/`tryCatch` and raw `ggplot2::ggsave`.
  S78's owner-ratified disposition (keep / defer; adopt incrementally if a logging need
  arises) holds verbatim. `safeExecute` (zero callers ever) remains the **one** standing
  future-*retire* candidate if the owner declines a logging standard.
- **Impact:** No code action owed. The retire count stays **0**.

### Finding #4 — Current unused set: 39 exports (35 functions + 4 S3 methods)
- **Severity:** Inventory (the audit's primary measurement).
- **Evidence:** `127` exported objects app-reached / `39` unused at HEAD. Composition delta
  vs the S78 snapshot (which counted the now-discharged wire-ins as unused):
  - **Left the unused set since S78 (4):** `modORIPReportingUI`, `modORIPReportingServer`,
    `getPotentialParents`, `removeAutoGenIds` — all now app-reached (Findings #1).
  - **Stable:** the remaining 35 functions + 4 S3 methods (full table below).
- The S78 disposition framework — *"exported but app-unreachable" is intended public API,
  not dead code* (documented + tested + `@examples`/vignette/`inst` use, or called by another
  package function ⇒ keep) — re-applies unchanged to all 39.

### Finding #5 (minor) — The issue body is stale
- **Severity:** Minor (documentation).
- **Evidence:** The #37 body (last re-verified 2026-06-12, S65) predates the wire-ins: it
  still lists `modORIPReporting*` and `getPotentialParents` as unused (they are now mounted),
  and its strikethrough table is two wire-ins out of date. It also lists only **3** unused S3
  methods; the verified set is **4** (see Finding #6).
- **Recommendation:** If #37 is kept open, update the body to the HEAD snapshot (strike the 3
  now-reached functions, add the 4th S3 method, note the `getPedDirectRelatives` docfix done).
  This is the same "update, don't close" call S62 made — still applicable.

### Finding #6 (minor) — S3-method undercount in the issue body
- **Severity:** Minor.
- **Evidence:** The reachability recompute flags **4** exported S3 methods outside the app
  closure — `print.summary.nprcgenekeeprErr`, `print.summary.nprcgenekeeprGV`,
  `summary.nprcgenekeeprErr`, **`summary.nprcgenekeeprGV`** — whereas the issue body's
  "† S3 methods" note lists only 3 (omits `summary.nprcgenekeeprGV`). Per the S3-dispatch
  caveat these are "cannot-prove-used," but the body should list all 4 if kept.

---

## Items Audited — the 39 unused exports (HEAD-verified) with disposition

Disposition column carries the S78 triage verdict, re-confirmed against HEAD this session.

| # | Export | Cluster | Disposition |
|---|--------|---------|-------------|
| 1–7 | `makeSimPed`, `createSimKinships`, `cumulateSimKinships`, `kinshipMatrixToKValues`, `kinshipMatricesToKValues`, `countKinshipValues`, `summarizeKinshipValues` | Sim-kinship subsystem | keep-as-public-API (tested + `simulatedKValues.Rmd`; future app home = **#10 OPEN**) |
| 8–11 | `obfuscatePed`, `obfuscateId`, `obfuscateDate`, `mapIdsToObfuscated` | Obfuscation island | keep-as-public-API (pkgdown-indexed, tested; produced the shipped de-identified example data) |
| 12–14 | `logModuleEvent`, `safeExecute`, `savePlotToFile` | Logging/error/export island | keep / defer (owner-ratified); `safeExecute` = lone future-retire candidate (Finding #3) |
| 15–16 | `makeFounderStatsTable`, `makeGeneticSummaryTable` | Founder-stats helpers | keep-as-public-API (app already renders founder stats inline at `modSummaryStats.R:583-638`) |
| 17–18 | `calcFE`, `calcFG` | Founder equivalents | keep-as-public-API (documented + `@examples` + `test_calcFE`/`test_calcFG`; no live callers — `reportGV`→`calcFEFG`→`calcFounderContributions`/`calcRetention`) |
| 19–22 | `createPedTree`, `getAncestors`, `findLoops`, `countLoops` | Loop/pedigree family | keep-as-public-API (`a2interactive` vignette + tests; `getAncestors` called by `countLoops`/`makesLoop`) |
| 23–25 | `getPedigree`, `getLkDirectAncestors`, `getPedDirectRelatives` | Data-access | keep-as-public-API (documented file-import / EHR helpers; `getPedDirectRelatives` docfix done S87) |
| 26–27 | `setAutoIdFormat`, `removeUnknownAnimals` | AutoID / QC | keep-as-public-API (`setAutoIdFormat` = the #44/#38 public knob, consumed in-app via `getAutoIdFormat`) |
| 28–31 | `createExampleFiles`, `makeExamplePedigreeFile`, `create_wkbk`, `saveDataframesAsFiles` | Example-data builders | keep-as-public-API (vignette-driven; `create_wkbk`/`saveDataframesAsFiles` called by the builders) |
| 32–35 | `get_elapsed_time_str`, `headerDisplayNames`, `dataframe2string`, `is_valid_date_str` | Small utilities | keep-as-public-API (`a2interactive` vignette + tests) |
| 36–39 | `print.summary.nprcgenekeeprErr`, `print.summary.nprcgenekeeprGV`, `summary.nprcgenekeeprErr`, `summary.nprcgenekeeprGV` | S3 methods | keep — cannot prove unused (generic dispatch; static analysis can't trace) |

**Totals:** 39 unused = **0 wire-in · 39 keep-as-public-API · 0 retire** (with `safeExecute`
the standing conditional future-retire). Down from S78's "2 wire-in · 37 keep · 0 retire" —
the 2 wire-ins shipped.

---

## Comparison with Prior Audits / Re-verifications of #37

| When | Session | Totals (used / unused) | Disposition of #37 | Recommendation |
|------|---------|------------------------|--------------------|----------------|
| 2026-06-12 | S65 (issue comment) | 116 used / 39 unused (155 exports) | Re-verified inventory; 45 of 70 originals now used | Keep open; wire-in-or-retire the sim-kinship + ORIP clusters |
| 2026-06-12 | S62 (`BACKLOG_STALENESS_AUDIT`) | — | PARTIAL — headline resolved | **UPDATE the issue, don't close** (strike resolved rows) |
| 2026-06-14 | S78 (issue comment) | 119 used / 39 unused (158 exports) | Full triage: **2 wire-in · 37 keep · 0 retire** | Track wire-ins under #45/#47; keep #37 as standing inventory |
| 2026-06-16 | S95 (`IMPLEMENTED_BUT_OPEN_AUDIT`) | — | ambiguous / owner-judgment | Owner: retire the inventory, or keep as catalog? (wire-ins #47/#48 shipped+closed) |
| **2026-06-16** | **S97 (this audit)** | **127 used / 39 unused (166 exports)** | **0 wire-in · 39 keep · 0 retire** — actionable surface fully drained | **Owner: close (no work left), or keep + update the stale body** |

**Trend:** the unused *count* hovers at ~39 across four re-verifications even as the package
grew (155 → 166 exports) and the live call graph expanded — i.e. new exports arrive at roughly
the rate old ones get wired in. The *actionable* portion has monotonically shrunk: 2 wire-ins
+ 1 docfix at S78 → **0 open actionable items at S97.** No issue regressed (no previously-wired
export fell back out of the call graph). No recurring structural defect — the "unused export"
status is, by repeated owner decision, intended public-API steady state, not debt.

---

## Recommendations

1. **#37 disposition is an owner judgment call (not an auto-close).** Its only ever-actionable
   items — wire-ins #47, #48 and the `getPedDirectRelatives` docfix — are all shipped/fixed and
   their tracking issues CLOSED. The remaining 39 exports are keep-as-public-API by deliberate,
   repeatedly-reaffirmed owner decision (S65, S78, S95). Two equally valid options:
   - **(a) Close #37** — the actionable surface is drained; what remains is bookkeeping that
     this audit report now captures with firsthand evidence. (Closing is *not* an "it shipped"
     fact; it is the owner choosing to retire the standing inventory.)
   - **(b) Keep #37 open** as the living catalog of intended-public exports — the owner's
     standing preference — **and update its now-stale body** (Findings #5, #6).
2. **If kept open, update the body to this HEAD snapshot:** strike `modORIPReportingUI`,
   `modORIPReportingServer`, `getPotentialParents` (now mounted), reflect `removeAutoGenIds` as
   transitively reached, add `summary.nprcgenekeeprGV` as the 4th unused S3 method, and note the
   `getPedDirectRelatives` `@examples` docfix (S87 `2a64770f`).
3. **No code work is owed by #37.** Retire count = 0. `safeExecute` (zero callers ever) is the
   sole conditional future-retire candidate — actionable only if/when the owner decides against
   adopting a package logging standard; it is not a defect today.
4. **Method note for the next re-verification:** use `findGlobals(..., merge = TRUE)`, not
   `$functions` only — functions passed to `Map`/`apply`/`do.call` (e.g. `chooseDate`) are
   missed by call-position-only reachability and will produce false "unused" flags.

---

*Read-only audit. No `R/`, test, `NAMESPACE`, `man/`, `DESCRIPTION`, issue-state, or
issue-body change was made by this session. Reachability script: `/tmp/s97_reach2.R`
(`merge = TRUE`). All file:line references and issue states verified firsthand at HEAD
`a5507a35` on 2026-06-16.*
