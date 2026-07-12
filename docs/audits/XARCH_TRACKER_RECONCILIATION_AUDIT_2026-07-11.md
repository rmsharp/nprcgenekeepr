# XARCH Tracker Reconciliation Audit

**BACKLOG item:** "Tracker reconciliation (DECISION NEEDED, Effort S) — The remaining
audit follow-ups (XARCH-2..8) are not GitHub issues; the live tracker is #1–#39.
Decide whether to file the remaining XARCH items as issues or keep them here."
**Date:** 2026-07-11 (Session 365)
**Scope gate:** BACKLOG.md's own framing ("XARCH-2..8 remaining") was six weeks stale
— written the day of `TECH_DEBT_AUDIT_2026-05-30.md` and never re-checked against the
codebase since, despite the full monolith→modular Shiny migration (issue #27,
Phases 1–9) and other work landing in between. Before the owner could make an
informed filing decision, this session re-verified **all 8** XARCH-1..8 findings
(not just the "remaining" 7) against current source — 7 via a parallel background
workflow (one read-only agent per finding, each independently grepping/reading
current `R/*.R` files rather than trusting the original audit text), plus XARCH-3
already independently re-confirmed resolved in Session 358
(`XARCH3_SHINY_PROGRESS_HOOK_AUDIT_2026-07-11.md`).
**Status:** Audit complete. This report, 2 new GitHub issues, and a `BACKLOG.md`
update are the deliverable. No `R/`/`tests/` code was changed in this session — this
was a decision-and-documentation task, not an implementation task, so the project's
strict-TDD RED/GREEN/REFACTOR phase gates do not apply (no new observable code unit
was introduced), matching the precedent set by Session 358's audit-only close-out.

---

## 1. Summary

| Finding | Status (2026-07-11) | Disposition |
|---|---|---|
| XARCH-1 — two coexisting Shiny apps | **RESOLVED** | Closed. No further tracking. |
| XARCH-2 — implicit/inconsistent module contract | **STILL OPEN** | Filed as a GitHub issue (owner-directed). |
| XARCH-3 — Shiny progress hook leaking into compute | **RESOLVED** (S358) | Already closed; re-confirmed here. |
| XARCH-4 — hardcoded species parameters | **PARTIALLY RESOLVED** | Age/gestation half done; sex-code half tracked as a narrow `BACKLOG.md` item, not a full issue. |
| XARCH-5 — string-column-keyed pipeline, no validated seam | **STILL OPEN** | Filed as a GitHub issue (owner-directed). |
| XARCH-6 — inconsistent error/return conventions | **PARTIALLY RESOLVED** | `runQcStudbook`/`processQcStudbookResult` wrapper added; `qcStudbook()` itself + `modInput.R`'s multi-call unchanged, tracked as a narrow `BACKLOG.md` item. |
| XARCH-7 — per-site UI branching + global mutable state | **RESOLVED** | Closed. No further tracking. |
| XARCH-8 — split configuration, unclear authority | **PARTIALLY RESOLVED** | Duplicate-parser bug fixed (issue #50); column-list unification untouched, tracked as a narrow `BACKLOG.md` item. |

**Headline.** Of the 8 original findings, 3 are fully done (1, 3, 7 — all three were
casualties, directly or indirectly, of the monolith deletion), 2 are genuinely
still open exactly as originally described (2, 5), and 3 are partially done with
materially narrower remaining gaps than the original text (4, 6, 8). The owner
chose (via `AskUserQuestion`) to file GitHub issues only for the 2 fully-open items
and track the 3 partial items' narrower remaining gaps directly in `BACKLOG.md`
instead of opening full issues for them, since each is already flagged as known
"future polish" in `docs/planning/shiny-module-conversion-plan.md`.

---

## 2. Method

- **Coverage.** All 8 XARCH-1..8 findings from `TECH_DEBT_AUDIT_2026-05-30.md`
  §"Cluster: XARCH" (lines 651–739 as of that commit). XARCH-3 was excluded from
  this session's own re-verification workflow only because Session 358 had already
  independently re-confirmed it resolved with 0 findings
  (`XARCH3_SHINY_PROGRESS_HOOK_AUDIT_2026-07-11.md`); it is included in the summary
  table above for completeness.
- **Re-verification, not re-trust.** A background `Workflow` run launched one
  read-only agent per finding (XARCH-1, 2, 4, 5, 6, 7, 8), each instructed to read
  the actual current source files/functions the original finding cited (or their
  current equivalents/successors if renamed) and grep the current `R/` tree for the
  described pattern, classifying as `RESOLVED` / `MOOT` / `PARTIALLY_RESOLVED` /
  `STILL_OPEN` with concrete file:line evidence — not to trust the audit's own
  six-week-old prose. 7 agents, 98 tool calls, 0 errors.
- **Decision, not unilateral action.** Once the accurate current-state table was in
  hand, the actual filing decision (issues vs. `BACKLOG.md`-only, and for which
  subset) was posed to the owner via `AskUserQuestion` rather than assumed.

---

## 3. Findings detail

### XARCH-1 — RESOLVED
`inst/application/` is confirmed deleted (`ls` → "No such file or directory").
`R/runGenekeepr.R:39-45` defines `runGeneKeepR()` as the canonical entry point,
launching `shiny::shinyApp(ui = appUI(), server = appServer)` directly (the modular
app). `R/runModularApp.R:24-35` makes `runModularApp()` a soft-deprecated alias via
`lifecycle::deprecate_soft()` that just calls `runGeneKeepR()`.
`tests/testthat/test_monolith_removed.R` exists as a regression guard. No remaining
references to `system.file("application")` anywhere in `R/` or `inst/`.

### XARCH-2 — STILL OPEN (filed as an issue)
`R/modGeneticValue.R:471-482` — `modGeneticValueServer`'s returned `geneticValues`
reactive still renames `indivMeanKin`→`meanKinship` and `gu`→`genomeUniqueness` at
the consumer boundary, not at the source (`reportGV` still emits
`indivMeanKin`/`gu`; confirmed `R/modGeneticValue.R:266-284`).
`R/appServer.R:313-320` still passes `kinshipMatrix = NULL` into
`modSummaryStatsServer`, and `R/modSummaryStats.R:357-385` (`getKinshipMatrix()`)
falls back to recomputing kinship from the pedigree every time as a result — a
comment at `R/modSummaryStats.R:369-371` explicitly says "the path the app always
takes since appServer passes kinshipMatrix=NULL." `R/appServer.R:338-343` calls
`modBreedingGroupsServer` with no `kinshipMatrix` argument at all (the parameter
was removed from its signature, `R/modBreedingGroups.R:181-182`);
`R/modBreedingGroups.R:188-208` re-derives kinship itself. `appServer.R` still
wraps essentially every cross-module read in `tryCatch(..., error = function(e)
NULL)` (`R/appServer.R:142,146,158,207-211`).
`docs/planning/shiny-module-conversion-plan.md:69-76,132` explicitly labels
XARCH-2 "ENTANGLED (partial)" and defers "the full typed-contract /
column-standardize-at-source work... to a separate issue after the monolith is
gone." The monolith is now gone (XARCH-1 resolved); this issue is that deferred
follow-up.

### XARCH-3 — RESOLVED (Session 358)
Independently re-audited in `XARCH3_SHINY_PROGRESS_HOOK_AUDIT_2026-07-11.md`: 0
findings across a full 230-file `R/*.R` sweep. Not re-run in this session's
workflow; carried forward unchanged.

### XARCH-4 — PARTIALLY RESOLVED
The `minParentAge`/species-profile half is now genuinely centralized:
`R/resolveBreedingAge.R:27-41` is the single internal function every QC/parent-age
path routes through (called from `R/checkParentAge.R:140,143`,
`R/qcStudbook.R:277`, `R/getPotentialParents.R:106`); it calls
`R/getSpeciesMinBreedingAge.R:36-60`, which looks up a bundled per-species table
`speciesGestation` (`R/data.R:390-420`, built by `data-raw/speciesGestation.R`)
with columns `gestation`/`minMaleBreedingAge`/`minFemaleBreedingAge`, overridable
from a user config CSV via `R/loadSpeciesOverrides.R:49-146`. The bare
`minParentAge` scalar is now `lifecycle::deprecated()` in
`R/checkParentAge.R:53`, `R/qcStudbook.R:187`, `R/getPotentialParents.R:65`,
`R/runQcStudbook.R:52`, replaced by `minSireAge`/`minDamAge` defaulting to `NULL`
from that single source; `R/modInput.R` no longer contains `"minParentAge"` at all.

The sex-code half is unchanged: `M`/`F`/`U`/`H` literals are still scattered —
`R/getPotentialSires.R:22`, `R/calculateSexRatio.R:80`, `R/fillBins.R:27,31`,
`R/filterPairs.R:34`, `R/modBreedingGroups.R:330,443-444`,
`R/modSummaryStats.R:797,807` all still compare against bare string literals; no
exported `sexCodes` constant exists (only `convertSexCodes.R:37-52`, which
centralizes *conversion* of raw input, not a shared comparison constant); no
`founderSexFilter` concept exists anywhere in `R/`.

**Disposition:** narrow remaining gap (sex-code literal centralization only) noted
in `BACKLOG.md` rather than filed as a full issue.

### XARCH-5 — STILL OPEN (filed as an issue)
`R/getRequiredCols.R:25`, `R/getPossibleCols.R:53-58`, `R/getIncludeColumns.R:16-19`
remain three separate hand-maintained hardcoded column-name vectors, unchanged in
kind since the audit. `R/reportGV.R:211` still does
`includeCols <- intersect(getIncludeColumns(), names(ped))` immediately followed
by `demographics <- ped[probands, c(includeCols, "sire", "dam")]` (line 218) with
no check that any required column survived the intersect. `R/qcStudbook.R:316` has
the analogous `cols <- intersect(getPossibleCols(), colnames(sb))`. No S3
`pedigree`/`gvReport` class, `columnMap`, or consolidated schema exists anywhere in
`R/`. Nothing in the repo's history since 2026-05-30 attempted this refactor — the
finding is not entangled with the monolith deletion at all, so nothing else
resolved it as a side effect either. (Note: the original audit's cited
`mergeReportColumns` function name never actually existed — a labeling artifact of
the original audit, not a resolved/removed function; the underlying
intersect-with-no-validation pattern it was describing is fully intact regardless.)

### XARCH-6 — PARTIALLY RESOLVED
`R/qcStudbook.R:280-294` — `qcStudbook()` still returns a bare data.frame when
`reportErrors=FALSE` but an `nprcgenekeeprErr`/`errorLst` object when
`reportErrors=TRUE`, and on low parent age in non-report mode it still writes a CSV
to `tempdir()` and calls `stop()`. A new wrapper, `R/runQcStudbook.R`, was added
since the audit and gives most callers a single consistent contract
(`list(cleaned=, qcResult=)`), normalized via `R/processQcStudbookResult.R` — a
real improvement — but achieves this by calling `qcStudbook()` twice internally,
each wrapped in its own `tryCatch`. `R/modInput.R:485-525` still performs the exact
dual-call pattern the finding described: it calls `qcStudbook()` directly (lines
486-491) to get a "raw errorLst for dynamic tab display," AND separately calls
`runQcStudbook()` (lines 501-505) to get the cleaned data — `qcStudbook` is now
invoked three times total per QC run. `docs/planning/shiny-module-conversion-plan.md:85,343`
explicitly flags this as known, still-open "future polish."

**Disposition:** narrow remaining gap (the `qcStudbook`/`modInput.R` multi-call
redundancy specifically, not the whole error-contract redesign) noted in
`BACKLOG.md` rather than filed as a full issue.

### XARCH-7 — RESOLVED
`inst/application/` (the monolith the finding cited) is confirmed deleted. The
current modular app builds ONE `navbarPage(...)` argument list
(`R/appUI.R:20-38`, no duplicated branch); the only ONPRC-specific behavior is a
single inline conditional tab (`R/appUI.R:184`), gated by the predicate
`R/shouldShowOripTab.R:35` (`isTRUE(hasConfigFile) && isTRUE(center == "ONPRC")`),
reused verbatim in `R/appServer.R:325-326` — the only site-branch check left
anywhere in `R/`, so UI and server can't drift. The global-mutable-state half is
also gone: no `globalMinParentAge`/`<<-` anywhere in `R/`; `minSireAge`/
`minDamAge` are ordinary reactives (`R/modInput.R:692-696`) threaded as reactive
args into `appServer.R:373-374` module calls. Not literally the `{id, modUI,
modServer, sites}` registry the recommendation phrased, but the actual problems
described (copy-pasted per-site branches, global mutable state) no longer exist.

### XARCH-8 — PARTIALLY RESOLVED
The duplicate-parser half is fixed: `R/loadSiteConfig.R:16-18,35-51` replaced the
`read.table(sep="=")` call `appServer.R` used to do on its own; `appServer.R:64`
now calls `shared$config <- loadSiteConfig()`, which internally calls
`getSiteInfo(expectConfigFile = FALSE)`. This landed in Session 85 (2026-06-15,
issue #50) as a crash-bug fix, independent of this audit.

The core complaint is not fixed: `R/getRequiredCols.R:24-26`,
`R/getPossibleCols.R:52-59`, `R/getIncludeColumns.R:15-20` remain three separate,
independent exported functions, none referenced from `R/getSiteInfo.R`. `getSiteInfo()`
(`R/getSiteInfo.R:31-87`) is still a binary switch — if a config file exists,
`getParamDef()` errors on any missing key rather than falling back to defaults —
so the "defaults < dotfile < explicit override" merged-profile recommendation was
never implemented.

**Disposition:** narrow remaining gap (column-list unification into `getSiteInfo()`
only, not the merged-profile precedence redesign) noted in `BACKLOG.md` rather than
filed as a full issue.

---

## 4. Decision and actions taken

Presented the accurate 8-item table (§1) to the owner via `AskUserQuestion`, with
three options: (a) issues for the 2 fully-open items only + narrow BACKLOG notes
for the 3 partial items [recommended], (b) issues for all 5 not-fully-resolved
items, (c) BACKLOG-only for everything, no new issues. **Owner chose (a).**

Actions:
1. Filed GitHub issue for XARCH-2 (module contract) — see `CHANGELOG.md` for the
   issue number.
2. Filed GitHub issue for XARCH-5 (string-keyed pipeline, no validated seam) — see
   `CHANGELOG.md` for the issue number.
3. Removed `BACKLOG.md`'s "Tracker reconciliation" section (the decision it posed
   is now resolved).
4. Added three narrow-scope `BACKLOG.md` items for XARCH-4/6/8's specific
   remaining gaps (not the full original recommendations, which are already
   partially superseded by work already done).

---

## 5. Recommendations

1. **No further tracking needed for XARCH-1, 3, 7.** All three were fully resolved,
   two of them as a side effect of the monolith-deletion migration rather than
   dedicated XARCH work — worth noting for future audit-follow-up sessions: a
   cluster of "architecture" findings can collapse for free when a bigger,
   differently-motivated refactor lands.
2. **Treat the 2 new GitHub issues (XARCH-2, XARCH-5) as the live tracking home**
   for those findings going forward — do not also carry them in `BACKLOG.md`,
   consistent with this project's existing practice of not mirroring every open
   GitHub issue into `BACKLOG.md`.
3. **Re-verify BACKLOG.md's standing items periodically against current source**,
   not just at file-time. This item sat framed as "XARCH-2..8 remaining" for
   unknown prior sessions after XARCH-3 was already independently resolved
   (Session 358) without that resolution being reflected back into this item's own
   text — a live decision-needed item drifted stale for weeks.
