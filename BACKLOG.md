# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature
inventory & future plans → `ROADMAP.md`. (Methodology file model — see
`SESSION_RUNNER.md` Phase 0.)*

## Active

(none in progress)

## Up Next

**Fix Windows-only
`WriteXLS`/[`create_wkbk()`](https://github.com/rmsharp/nprcgenekeepr/reference/create_wkbk.md)
test failure blocking CRAN 2.0.0 resubmission** (READY, Effort S-M) –
discovered S361 (2026-07-11) while triggering the win-builder/R-hub
Phase 5 checks: GitHub Actions’ `R-CMD-check.yaml` has been failing on
`windows-latest (release)` on **every push since S351** (`b440730c`,
2026-07-10 23:55:55) – 7 consecutive failing runs (S351/S352/S353/
S356/S358/S359/S360), unnoticed because no session checked `gh run list`
during that span; `ubuntu-latest` and `macos-latest` pass cleanly every
time, so S359’s local `--as-cran` gate (macOS only) could not have
caught it. Failure: `test_modInput_excelSireDam.R` –
`makeExamplePedigreeFile(fileType = "excel")` -\>
[`create_wkbk()`](https://github.com/rmsharp/nprcgenekeepr/reference/create_wkbk.md)
(`R/create_wkbk.R:61`) -\>
[`WriteXLS::WriteXLS()`](https://rdrr.io/pkg/WriteXLS/man/WriteXLS.html)
errors `cannot open .../WriteXLS/1.csv . No such file or directory` on
Windows only (`[ FAIL 2 | WARN 0 | SKIP 205 | PASS 3665 ]`, run
<https://github.com/rmsharp/nprcgenekeepr/actions/runs/29170463437>).
`WriteXLS` shells out to a bundled Perl script to convert intermediate
CSVs to `.xlsx`; this is a well-known Windows failure mode when Perl
isn’t on `PATH` or its CSV/Excel- writer modules aren’t present on the
runner. **Timing/suspect commit:** the failing test file was
added/changed by
`fix: S350 -- Excel-upload sire/dam pedigree corruption` (`5a9697a8`);
S350’s own CI run appears to have been superseded by S351’s rapid
follow-up push (concurrency cancellation), so S350 vs. S351 as the exact
first-red commit is not yet disambiguated – not yet root-caused, not yet
fixed. **Session 361 (2026-07-11) also triggered win-builder x3 +
`rhub::rhub_check()` (run `occupational-burro`,
<https://github.com/rmsharp/nprcgenekeepr/actions/runs/29171440079>) per
the owner’s explicit request BEFORE this CI finding surfaced** – both
are very likely to reproduce this same Windows failure (win-builder
results by email ~2026-07-11 18:30, R-hub via GitHub Actions/email).
**Blocks `devtools::submit_cran()`** – an unexplained ERROR on any
platform must not ship per the submission plan’s acceptance bar
(`docs/planning/cran-2.0.0-phase5-runbook.md` §4.3). Fix options to
evaluate: (a) make the Excel-writing path Windows-CI-safe
(e.g. skip/guard the `fileType = "excel"` test path when Perl/WriteXLS’s
Windows prerequisites are absent, matching the existing
`NPRC_RUN_E2E`-style opt-in pattern already used elsewhere in this
suite), or (b) replace the `WriteXLS`-based
[`create_wkbk()`](https://github.com/rmsharp/nprcgenekeepr/reference/create_wkbk.md)
with a Perl-free Excel writer (e.g. `openxlsx`/`writexl`) so the
underlying dependency itself no longer needs Perl on any platform – the
latter also removes a CRAN-time `SystemRequirements: Perl` risk, not
just a CI flake.

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

**CRAN resubmission of v2.0.0** (READY, Effort S) – CRAN responded
2026-07-09: the v2.0.0 submission (S329, `devtools::submit_cran()`,
`CRAN-SUBMISSION` sha `8ca8bb24`) was archived before publication
because
[`appServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/appServer.md)
unconditionally wrote `~/nprcgenekeepr.log` on every boot, violating
CRAN Policy. **Fixed in S349** (`R/appServer.R`: the file appender is
now gated behind the “Debug on” checkbox’s already-tested `debugMode`
reactive, never written unconditionally; see `CHANGELOG.md` 2026-07-10
S349 entry for full verification detail incl. a live-browser Phase 3E
smoke test). **Local pre-submission gate re-confirmed – S359
(2026-07-11):** `R CMD build .` + `R CMD check --as-cran --timings` on
current `master` (134 commits since the archived sha, 9 touching
`R/`/`tests/`/`DESCRIPTION`/`NAMESPACE`) –
`0 errors | 0 warnings | 1 note` (the expected incoming-feasibility note
only; the local HTML-manual note is gone). **Important:** the
win-builder/R-hub results that were on file in `cran-comments.md`
predated the S349 fix (captured the day before, on the exact sha that
was archived) – reset to placeholders; see
`docs/planning/cran-2.0.0-phase5-runbook.md`’s refreshed top note for
the full ancestry check. Next (owner action, unchanged): re-run the
win-builder / R-hub pre-submission checks (now genuinely required, not
just stale-by-time) and resubmit via `devtools::submit_cran()`. No
version bump is required (the prior 2.0.0 attempt was archived before
publication) unless the owner prefers one. **Win-builder x3 + R-hub
triggered – S361 (2026-07-11):** per owner’s explicit scoping (not
`submit_cran()`, which stays owner-only). win-builder results by email
~18:30; R-hub run `occupational-burro`
(<https://github.com/rmsharp/nprcgenekeepr/actions/runs/29171440079>).
**New blocker found the same session, likely to reproduce in both:** see
the “Fix Windows-only
`WriteXLS`/[`create_wkbk()`](https://github.com/rmsharp/nprcgenekeepr/reference/create_wkbk.md)
test failure” item above – resolve that before folding results into
`cran-comments.md` / submitting.

## Documents (v1.0.8 -\> v2.0.0 write-up)

**Execute “Document 2” plan (Phase D)** (READY, Effort M) – planning
session DONE (S345), Phase A DONE (S346), Phase B DONE (S347), **Phase C
DONE (S348)**: `docs/planning/document2-colony-manager-guide-plan.md` §6
Phase C. Drafted `vignettes/articles/colony-manager-guide.qmd`
(Abstract, Introduction, Sections 1-3, Conclusion); Section 3
ported/modernized from `ColonyManagerTutorial.Rmd` using Phase B’s
screenshots and Phase A’s re-derived N1/N2/N3/N4 numbers verbatim.
Owner-resolved pre-drafting decisions: Input-tab narrates CSV with an
inline Excel-bug caveat; Breeding-Groups subsection covers None/Harem
fully, omits the Custom-ratio numeric demo (N7). Extended
`colony-manager-guide-screenshots.R` with 2 more captures
(owner-approved) for the Genetic Diversity and Potential Parents tabs,
which Phase B’s tutorial-figure-based inventory had no way to include.
`quarto render` of the article in isolation succeeds cleanly (zero
missing images, zero unresolved cross-references). Next: **Phase D** –
assemble (Abstract/Introduction/Conclusion full pass), full claim-source
audit, decide `ColonyManagerTutorial.Rmd`’s fate (§11 decision 3),
re-verify the pkgdown Reference-page citation live (§8 dragon 5 – the
underlying dead-config bug this dragon flagged is now **fixed**, S354:
root `_pkgdown.yml` carries the grouped `reference:` block and is
re-synced against current `NAMESPACE`; see below and `CHANGELOG.md`.
Phase D’s live re-verify is now confirming a real, working grouped
Reference page, not chasing a still-open bug), and run the full
verification checklist (§9:
[`pkgdown::build_article()`](https://pkgdown.r-lib.org/reference/build_articles.html),
`R CMD build .` + tarball check, spot-check sibling articles). See the
plan’s §6 Phase D for full completion criteria. All three findings Phase
C’s screenshot capture surfaced are now **fixed** (Excel-upload
corruption S350; non-functional Custom sex ratio S351;
missing-`fromCenter` example data S353 – see below and `CHANGELOG.md`),
so Phase D can update the Potential Parents subsection to show the
now-populated result (1,587 candidates) instead of only the
graceful-degradation screenshot, if desired. The Custom-ratio numeric
demo (N7), omitted from Section 3’s Breeding-Groups subsection per
S348’s pre-drafting decision, can also be added in Phase D if desired –
the control works end to end as of S351.

## Audit follow-ups

*(From `PED_GV_AUDIT_2026-05-30.md`; all audit follow-up items are now
resolved — see `CHANGELOG.md`. Per-item reachability notes and traps
live in `CLAUDE.md` “Project-specific Learnings”.)* - \[ \] (none
remaining)

## Tracker reconciliation (open question for the user)

- (DECISION NEEDED, Effort S) The remaining audit follow-ups
  (XARCH-2..8) are **not** GitHub issues; the live tracker is \#1–#39.
  Decide whether to file the remaining XARCH items as issues or keep
  them here. They currently coexist.
