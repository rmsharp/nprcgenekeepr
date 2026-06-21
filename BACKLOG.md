# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature
inventory & future plans → `ROADMAP.md`. (Methodology file model — see
`SESSION_RUNNER.md` Phase 0.)*

## Active

(none in progress)

## Up Next

**Act on the LabKey integration research recommendations** — research
pass DONE (`docs/research/labkey-integration-options-2026-06-19.md`,
S143). \*\*Rec \#3 (explicit optional API-key auth with `.netrc`
fallback + clear error) DONE — S144,
[`setLabKeyDefaults()`](https://github.com/rmsharp/nprcgenekeepr/reference/setLabKeyDefaults.md).
Rec \#1 (`Rlabkey` version floor) DONE — S146, `Rlabkey (>= 3.2.0)` in
`DESCRIPTION` (all four EHR-module repos target LabKey 26.6; the live
ONPRC/SNPRC server version, doc §8.1, is still unobserved). See
`CHANGELOG.md`. Rec \#2 (config-ize the ONPRC defaults) DONE — S147:
centralized into the internal `defaultSiteParams()` (single source of
truth for
[`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)‘s
no-config fallback; no behavior change) + documented the center-specific
`lkPedColumns` form in the example config (flat `dam`/`sire` = SNPRC
direct columns; `Id/parents/dam` = ONPRC curated lookup). All three
quick wins (Rec \#1/#2/#3) DONE. **Rec \#4/#5 (formalize a data-source
adapter on the `getPedDirectRelatives` seam + a deterministic mocked
integration test) DONE (fetch-boundary slice) — S148: internal
`getPedigreeSource()` (`labkey` \| `dataframe`) now backs
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)’s
fetch with the walk byte-identical, plus the first deterministic walk
test.** Walk-unification DONE — S149:\*\*
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
now delegates its pedigree walk to
[`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md),
so the LabKey/EHR path returns the full connected pedigree component
(collaterals included), consistent with the in-memory function — a
deliberate, owner-accepted behavior change; the deterministic test now
asserts the full component incl. the previously-excluded collateral
sibling. **Still deferred:** a `file`/other-EHR provider on the
`getPedigreeSource()` seam; server-side filtering / `executeSql` /
consuming the centers’ `study.Pedigree`/`ehr.kinship` (until measured).

**Strengthen the shinytest2 E2E assertions + CI stability** — GitHub
issue **\#40**, the open follow-on to the now-complete Phase 8 E2E
harness: replace boot-level tautologies with behavioral checks, and
harden the full-tier Chrome process-count flake (per-group fresh
processes). Coverage goal \>80%. (The monolith → Shiny-module conversion
campaign — XARCH-1 / issue \#27, all 9 phases — is **COMPLETE**; see
`CHANGELOG.md` and `docs/planning/shiny-module-conversion-plan.md`.)

**CRAN submission preparation**

## Audit follow-ups

*(From `PED_GV_AUDIT_2026-05-30.md`; the audit compute/test items are
all resolved — see `CHANGELOG.md`. Per-item reachability notes and traps
live in `CLAUDE.md` “Project-specific Learnings”.)* - \[ \] **NEW-12 /
XARCH-3** — Shiny progress hook. **Mostly resolved** per the S21 plan
§8: `reportGV` / `groupAddAssign` are already shiny-free with an
injected `updateProgress` hook; the only real leak `getMinParentAge` was
a dead orphan (removed in Phase 9, S35). Treat as SEPARABLE cleanup.

## Tracker reconciliation (open question for the user)

- The remaining audit follow-ups (XARCH-2..8) are **not** GitHub issues;
  the live tracker is \#1–#39. Decide whether to file the remaining
  XARCH items as issues or keep them here. They currently coexist.
