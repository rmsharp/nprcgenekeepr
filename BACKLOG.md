# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature
inventory & future plans → `ROADMAP.md`. (Methodology file model — see
`SESSION_RUNNER.md` Phase 0.)*

## Active

(none in progress)

## Architecture follow-ups (from TECH_DEBT_AUDIT_2026-05-30.md, re-verified 2026-07-11)

*Resolves the former “Tracker reconciliation” decision item (S365) –
`docs/audits/XARCH_TRACKER_RECONCILIATION_AUDIT_2026-07-11.md`
re-verified all 8 XARCH-1..8 findings against current source rather than
trusting the six-week-old audit text. XARCH-1/3/7 are fully RESOLVED (no
further tracking). XARCH-2 (implicit/ inconsistent module contract) and
XARCH-5 (string-column-keyed pipeline, no validated seam) are STILL OPEN
and owner-directed to GitHub issues \#122 and \#123 respectively – track
them there, not here. XARCH-4 (sex-code literal centralization) is now
also fully RESOLVED – S367 (2026-07-12): see `CHANGELOG.md`. XARCH-6
([`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)/`modInput.R`
multi-call redundancy) is now also fully RESOLVED – S368 (2026-07-12):
see `CHANGELOG.md`. XARCH-8’s narrower remaining gap is now also fully
RESOLVED – S369 (2026-07-12): see `CHANGELOG.md`. The
`man/filterPairs.Rd` staleness this recurring collateral regen left
behind (S367 origin, flagged S368/S369) is now also RESOLVED – S370
(2026-07-12): see `CHANGELOG.md`. No items remain in this section.* - \[
\] (none remaining)

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
`submit_cran()`, which stays owner-only). **Results processed – S362
(2026-07-11): all clean.** win-builder: 0 errors \| 0 warnings on all
three R versions (1 note each – the expected incoming-feasibility note;
R-oldrelease also flagged the known `groupAddAssign` \>10s timing note
on slower hardware, not a failure). R-hub (`occupational-burro`,
<https://github.com/rmsharp/nprcgenekeepr/actions/runs/29171440079>):
`Status: OK` on linux/windows/macos, 0 test failures. The Windows
`WriteXLS` CI failure S361 flagged as a likely blocker did NOT reproduce
on either external check – it was a GitHub-Actions-runner-specific
flake, not present on CRAN’s own win-builder infrastructure.
**Root-caused and fixed S363 (2026-07-11):**
[`create_wkbk()`](https://github.com/rmsharp/nprcgenekeepr/reference/create_wkbk.md)
now writes `.xlsx` via `openxlsx` instead of `WriteXLS`, removing the
Perl-on-Windows dependency entirely; see `CHANGELOG.md`. Results folded
into `cran-comments.md`’s “Test environments” section. **Pre-submission
gate is now clean across every environment actually run this cycle.**
Next (owner action, unchanged): `devtools::submit_cran()`, then click
the maintainer-email confirmation link – both still owner-only per
SAFEGUARDS and the runbook’s HARD STOP.

## Architecture (issue \#122 / XARCH-2 – module contract)

**Execute the issue \#122 module-contract plan, Phase 3** (READY, Effort
S) – planning session DONE (S372):
`docs/planning/issue122-module-contract-plan.md`. **Phase 1 DONE – S373
(2026-07-12):** fixed the reproduced user-facing bug –
[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
(exported) emits `indivMeanKin`/`gu` while
[`makeGeneticSummaryTable()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGeneticSummaryTable.md)
(exported) consumed `meanKinship`/`genomeUniqueness`, so
`makeGeneticSummaryTable(reportGV(ped)$report)` silently returned an
all-`NA` table. New internal `@noRd` normalizer
(`R/normalizeGvReport.R`) +
[`makeGeneticSummaryTable()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGeneticSummaryTable.md)
now tolerant of both vocabularies. Additive; broke no exported contract;
touched no module (`NAMESPACE` unchanged). Verified end-to-end against
`qcPed` (`makeGeneticSummaryTable(reportGV(qcPed)$report)` now populates
correctly) and via full suite (0 failed/0 error/0 warning) +
`devtools::check()` (0/0/0). See `CHANGELOG.md`. **Phase 2 DONE – S374
(2026-07-12):** killed `modBreedingGroups`’ unreachable kinship-reuse
branch (never once returned a matrix – `shared$geneticValues` is a data
frame, never had a `$kinship` element); hoisted one shared, memoized,
full-pedigree `sharedKinshipMatrix` reactive into `appServer`
([`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)+`applyKinshipOverridesToMatrix()`,
matching each consumer’s own prior recompute formula exactly), threaded
to both `modSummaryStatsServer` and `modBreedingGroupsServer` (new
`kinshipMatrix` param) instead of each independently recomputing it.
Recompute fallback retained in both consumers (Dragon 3). Dragon 1
sidestepped by construction: the shared reactive is always
full-pedigree, never `gvResults$kinshipMatrix` – confirmed via
[`setPopulation()`](https://github.com/rmsharp/nprcgenekeepr/reference/setPopulation.md)‘s
source (only flags a `population` column, never filters rows) and
empirically via the plan’s mandatory
[`identical()`](https://rdrr.io/r/base/identical.html) gate against the
real 280-animal `qcPed` fixture, with and without focal animals. Dragon
2’s cited `test_modErrorHandling.R:180-184` pin
(`modBreedingGroupsServer` tryCatch/showNotification) stayed green
unmodified – the deleted dead branch was not that test’s actual tryCatch
source (a second, unrelated one lives in the group-formation
`eventReactive`). Verified: full suite 0 failed/0 error/0 warning;
`devtools::check()` 0/0/0; Phase 3E live smoke test via the repo’s
existing browser e2e suite (`NPRC_RUN_E2E=true` – not just `NOT_CRAN`),
`test-e2e-breeding-groups-module.R` (7/7) and
`test-e2e-summary-statistics-module.R` (8/8) both pass against the real
modified `appServer`. See `CHANGELOG.md`. **Phase 3 DONE – S375
(2026-07-13):** vocabulary collapse. Deleted the `geneticValues` rename
closure (`R/modGeneticValue.R`) so it returns `gvResults()` directly,
and the now-redundant `mkCol`/`guCol` dual-vocabulary display probes in
`gvSummary`/`gvScatterPlot`; migrated `modSummaryStats.R` (~13 sites)
and `modORIPReporting.R` (4 sites) to canonical `indivMeanKin`/`gu`.
`rg 'meanKinship|genomeUniqueness' R/mod*.R` now returns zero hits
outside two verified out-of-scope exclusions: the unrelated
`genomeUniquenessSE`/`guSE` fallback in `gvSummary` (a different
vocabulary concern the plan doesn’t touch) and the
`meanKinshipBoxPlotGG`/`meanKinshipBoxPlot` reactive/list-key
identifiers (not data columns; renaming the exported list key would be
an exported-contract change, out of scope per Dragon 5). Five of the
plan’s originally-cited 12 test files turned out to be false positives
on firsthand verification (`test_modBreedingGroups.R`,
`test_modFounderStats.R`, `test_makeGeneticSummaryTable.R`,
`test_modGeneticValue_coverage.R`, `test-e2e-genetic-value-tutorial.R` –
none actually exercise the migrated read sites); the other 7 were
updated. Verified: full suite 0 failed/0 error/0 warning/167 skipped
(baseline unchanged); `devtools::check()` 0/0/0; end-to-end against the
real 280-animal `qcPed` fixture (`geneticValues()` identical to
`gvResults()`; `modSummaryStats`/`modORIPReporting` render the exact
same mean values computed independently); Phase 3E live smoke test via
the repo’s existing e2e suite – `test-e2e-genetic-value-module.R` (7/7),
`test-e2e-genetic-value-detailed.R` (7/7),
`test-e2e-genetic-value-tutorial.R` (8/8),
`test-e2e-summary-statistics-module.R` (8/8), `test-e2e-orip-module.R`
(4/4), all against the real modified app. See `CHANGELOG.md`. **Phase 4
next:** prune the dead surface (the dead `shared$config` chain incl. a
real design decision on delete-vs-wire, `shared$qcResults`,
`modSummaryStats`’ 12 unread returned reactives, `modInput`’s
undocumented `@return` elements) and replace the blanket
`tryCatch(..., error = function(e) NULL)` swallow in `appServer` with
explicit `req()`/contract guards. Depends on Phases 1-3 (all done).
Dragon 2 bites hardest here – see the plan’s §6 Phase 4 and §7 Dragon 2
before starting. Phase 5 (contract note + guard test) remains **one
session** after Phase 4.

**Issue \#123 (XARCH-5, string-column-keyed pipeline, no validated
seam)** (DECISION NEEDED – needs its own planning session; Effort L) –
related to \#122 but explicitly **out of scope** of the S372 plan. Track
on GitHub.

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
