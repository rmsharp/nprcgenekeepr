# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature
inventory & future plans → `ROADMAP.md`. (Methodology file model — see
`SESSION_RUNNER.md` Phase 0.)*

## Active

(none in progress)

## Up Next

**Act on the LabKey integration research recommendations** (BLOCKED –
remainder needs a live LabKey server to test/observe, Effort M) —
research pass DONE
(`docs/research/labkey-integration-options-2026-06-19.md`, S143).
\*\*Rec \#3 (explicit optional API-key auth with `.netrc` fallback +
clear error) DONE — S144,
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
sibling. **`file` provider DONE — S150:** `getPedigreeSource()` gained a
`"file"` source (params `fileName`/`sep`) that reads a pedigree file
(CSV or Excel) via the exported
[`getPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedigree.md),
alongside `"labkey"` and `"dataframe"`; offline-deterministic, validates
id/sire/dam, errors loudly like the `dataframe` branch. **`"file"`
provider WIRED to a first-class caller DONE — S151:** new exported
`getFileDirectRelatives(ids, fileName, sep, unrelatedParents)`, a
file-sourced sibling of
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
(reads via the `"file"` provider, then the source-agnostic
[`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)
walk). The clean symmetric family is now `getPedDirectRelatives`
(in-memory) / `getLkDirectRelatives` (LabKey) / `getFileDirectRelatives`
(file). **Option C — file pedigree source through the focal-animal app
pipeline DONE — S152:** new exported
`getFocalAnimalPedFromFile(fileName, pedigreeFileName, sep)`, a
file-sourced sibling of
[`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md)
(reads focal Ids from one file, builds the connected component from a
separate pedigree file via
[`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md);
fail-soft to a classed `nprcgenekeeprFileErr` whose `message` names WHY
the read failed — bad focal-id list file, a
missing/not-found/unreadable/ wrong-column pedigree file, or no focal
IDs matched — surfaced as the app’s “File Read Error” detail (richer
error messages added S155). `modInput` gained an optional pedigree-file
input on the focal-animals path and dispatches to the offline function
when supplied, else the unchanged LabKey path — so the Shiny
focal-animal workflow can now run offline with no LabKey/EHR connection.
(The focal-id read was factored into a shared internal
`readFocalAnimalIds()`.) **Still deferred:** a non-LabKey other-EHR
provider on the same seam; server-side filtering / `executeSql` /
consuming the centers’ `study.Pedigree`/`ehr.kinship` (research doc
explicitly defers until pull size is measured + per-center query
availability/permissions are confirmed; needs a live LabKey server to
test/observe, and a naive focal-id server filter is incompatible with
the client-side connected-component walk).

**Strengthen the shinytest2 E2E assertions + CI stability** (READY,
Effort L) — GitHub issue **\#40**, the open follow-on to the
now-complete Phase 8 E2E harness: replace boot-level tautologies with
behavioral checks, and harden the full-tier Chrome process-count flake
(per-group fresh processes). Coverage goal \>80%. (The monolith →
Shiny-module conversion campaign — XARCH-1 / issue \#27, all 9 phases —
is **COMPLETE**; see `CHANGELOG.md` and
`docs/planning/shiny-module-conversion-plan.md`.)

**CRAN submission preparation** (BLOCKED – external, Effort S to
re-scope) — v2.0.0 was already submitted to CRAN (S329,
`devtools::submit_cran()`, `CRAN-SUBMISSION` sha `8ca8bb24`); CRAN’s
review outcome is still pending as of 2026-07-09 (per the v2.0.0
article’s own Scope note). This item may be stale – whichever session
picks it up should first check whether CRAN has responded and re-scope
or close accordingly, not assume “preparation” is still the right verb.

## Documents (v1.0.8 -\> v2.0.0 write-up)

**Fix Document 1’s 15 confirmed audit findings** (READY, Effort M) –
`docs/audits/DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md` is now **CLOSED**
(S342): all 15 findings from the two-lens review (2 spot-verified by
S339, 13 independently re-verified by S342) are confirmed real, still
unfixed in `engineering-the-2.0.0-release.qmd`, and prioritized in the
audit doc’s own “Recommendations” section – 2 HIGH (factual: the
[`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
Phase-9 misattribution at L170-172, and the “four sessions…wrote
Sections 1-3” contradiction at L687-688), 3 MEDIUM (a chart hiding a
3-month zero-commit gap; only 1 hyperlink vs. 22 plain-text issue/commit
citations; TDD vocabulary used ~500 lines before being explained), 9 LOW
(grammar, unglossed jargon – “Phase A data freeze,” “vertical-slice,”
“XARCH-2” – and structural/editorial nits, batchable as one editorial
pass per the audit doc), 1 MINOR/optional (a 1-day date mismatch in
`feature-highlights.csv`, zero reader-visible impact). **Gotcha:** the
audit doc’s own line-number citations are current as of S342
(post-S340’s footnote-drift, already re-anchored) – re-anchor again if
any other session edits the article before the fix session runs.
Re-render (`quarto render`) after fixing and clean up render artifacts
before staging (Learning 314); do a full corpus sweep for stale echoes
after fixing, per the S340 precedent (Learning \#7/#10).

**Plan “Document 2”** (READY, Effort M) – package purpose, how it
addresses that purpose, and how to put it into use. Explicitly deferred
out of `docs/planning/v2-transformation-article-plan.md` (S330) to its
own future planning session per the owner’s 2026-07-09 instruction;
named as a next step in S336’s `HANDOFFS.md` receipt and again in
S339’s, never picked up by any session since. Needs its own planning
session (scope/audience/structure not yet decided) before any drafting
begins.

## Audit follow-ups

*(From `PED_GV_AUDIT_2026-05-30.md`; the audit compute/test items are
all resolved — see `CHANGELOG.md`. Per-item reachability notes and traps
live in `CLAUDE.md` “Project-specific Learnings”.)* - \[ \] **NEW-12 /
XARCH-3** (READY, Effort S) — Shiny progress hook. **Mostly resolved**
per the S21 plan §8: `reportGV` / `groupAddAssign` are already
shiny-free with an injected `updateProgress` hook; the only real leak
`getMinParentAge` was a dead orphan (removed in Phase 9, S35). Treat as
SEPARABLE cleanup.

## Tracker reconciliation (open question for the user)

- (DECISION NEEDED, Effort S) The remaining audit follow-ups
  (XARCH-2..8) are **not** GitHub issues; the live tracker is \#1–#39.
  Decide whether to file the remaining XARCH items as issues or keep
  them here. They currently coexist.
