# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature
inventory & future plans → `ROADMAP.md`. (Methodology file model — see
`SESSION_RUNNER.md` Phase 0.)*

## Active

(none in progress)

## Up Next

**Act on the LabKey integration research recommendations** — research
pass DONE (`docs/research/labkey-integration-options-2026-06-19.md`,
S143). **Rec \#3 (explicit optional API-key auth with `.netrc`
fallback + clear error) DONE — S144,
[`setLabKeyDefaults()`](https://github.com/rmsharp/nprcgenekeepr/reference/setLabKeyDefaults.md).
Rec \#1 (`Rlabkey` version floor) DONE — S146, `Rlabkey (>= 3.2.0)` in
`DESCRIPTION` (all four EHR-module repos target LabKey 26.6; the live
ONPRC/SNPRC server version, doc §8.1, is still unobserved). See
`CHANGELOG.md`.** Remaining quick win (before CRAN re-submission): **Rec
\#2** — move the hardcoded ONPRC defaults out of
[`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
into config + reconcile the example-config drift (flat `dam`/`sire` vs
`Id/parents/dam`). Larger: formalize a data-source adapter on the
existing `getPedDirectRelatives` seam + a mocked integration test (would
consume the new
[`setLabKeyDefaults()`](https://github.com/rmsharp/nprcgenekeepr/reference/setLabKeyDefaults.md)
auth on the adapter’s LabKey provider). Each is a candidate GitHub issue
/ separate implementation session. (Deferred until measured: server-side
filtering / `executeSql` / consuming the centers’
`study.Pedigree`/`ehr.kinship`.)

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
