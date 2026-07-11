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
smoke test). Next (owner action): re-run the win-builder / R-hub
pre-submission checks and resubmit via `devtools::submit_cran()`. No
version bump is required (the prior 2.0.0 attempt was archived before
publication) unless the owner prefers one.

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
re-verify the pkgdown Reference-page citation live (§8 dragon 5), and
run the full verification checklist (§9:
[`pkgdown::build_article()`](https://pkgdown.r-lib.org/reference/build_articles.html),
`R CMD build .` + tarball check, spot-check sibling articles). See the
plan’s §6 Phase D for full completion criteria. Phase D must account for
one remaining new finding below (example data missing `fromCenter`) when
finalizing the article – the other two (Excel-upload corruption;
non-functional Custom sex ratio) are now **fixed, S350 / S351** (see
below and `CHANGELOG.md`). The Custom-ratio numeric demo (N7), omitted
from Section 3’s Breeding-Groups subsection per S348’s pre-drafting
decision, can now be added in Phase D if desired – the control works end
to end as of S351.

**`nTopAnimals` (and any other `ns()`-wrapped) `conditionalPanel` never
actually shows/hides** (READY, Effort S) – discovered live during S351’s
Phase 3E smoke test while fixing the sibling Custom-sex-ratio control.
[`modBreedingGroupsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsUI.md)’s
`nTopAnimals` panel (`R/modBreedingGroups.R`, condition
`sprintf("input['%s'] == 'topRanked'", ns("animalSource"))` + `ns = ns`)
double-prefixes the input name: passing `ns = ns` to
`conditionalPanel()` already makes Shiny’s client-side JS narrow the
`input`/`output` scope to the module’s unprefixed names (confirmed by
reading `shiny.js`’s `_narrowScopeComponent`, which strips the namespace
prefix from every scope key), so a condition string built via
`ns("animalSource")` looks up a namespaced key that no longer exists in
the narrowed scope and always evaluates to `undefined == 'topRanked'` –
`FALSE`. Confirmed live via
[`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html):
`getComputedStyle(...).display` on the panel’s `[data-display-if]`
ancestor is `"none"` in EVERY state (`animalSource` = the default
`"topRanked"`, `"all"`, and back to `"topRanked"`) – the “Number of top
animals” numeric input is invisible today regardless of selection,
including the default state where it’s supposed to be visible on page
load. S351’s own new `customSexRatio` panel avoided this bug by using
the correct unprefixed condition (`"input.sexRatio == 'custom'"`,
matching
[`?shiny::conditionalPanel`](https://rdrr.io/pkg/shiny/man/conditionalPanel.html)’s
own documented `ns=` usage), so it is NOT itself affected. Grepped all
of `R/` for every other `conditionalPanel(` call (S351): `modInput.R`’s
5 panels all already use the correct unprefixed form
(`input.fileType == ...`, `input.fileContent == ...`) – `nTopAnimals` is
the ONLY instance of the buggy double-prefixed pattern in the package.
Fix: change the condition to `"input.animalSource == 'topRanked'"` (or
`sprintf("input['%s'] == 'topRanked'", "animalSource")`).

**Shipped example pedigree cannot demonstrate the Potential Parents
feature** (READY, Effort S) – discovered during S348’s Document-2 Phase
C screenshot capture.
[`modPotentialParentsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsServer.md)
requires a `fromCenter` (colony-origin) column to identify in-colony
candidates for animals with unknown parentage; `data(examplePedigree)`
has no such column (confirmed:
`"fromCenter" %in% names(examplePedigree)` is `FALSE`), so running “Find
Potential Parents” against it always shows the app’s
graceful-degradation warning (“This dataset has no colony-origin
(‘fromCenter’) field…”) and an empty results table – correct behavior,
not a bug, but it means this walkthrough’s standard example data cannot
show what a populated result looks like. Fix (either): add a
`fromCenter` column to the shipped `examplePedigree`/`focalAnimals`
example objects (verify no other documented example or test relies on
their current column set first), or add a small supplementary example
dataset specifically for demonstrating this feature.

**Document 1’s Testing-at-Scale section conflates file-count growth with
testing quality** (READY, Effort S) –
`vignettes/articles/engineering-the-2.0.0-release.qmd` §Section 3
(`#sec-testing`, ~L392-455) leads with “the test suite grew from 132 to
257 `.R` files… a 95% increase” as its headline metric and never cites
an actual `covr`/Codecov coverage percentage or a test-*case* count,
despite the project having a live Codecov badge (`README.md`) and a
`test-coverage.yaml` CI workflow the section itself references by
filename (L524) without quoting its output. The word “coverage” appears
three times in the section, none of them a quantified code-coverage
figure – twice describing E2E *behavioral* coverage (“Coverage at the
end of 8d was boot-level”) and once naming the CI workflow file.
File-count growth is a real but weak proxy: more files can mean more
tests, better coverage, or more E2E depth, but doesn’t by itself
establish any of the three, and the section’s own prose (rightly) argues
the *kind* of test that improved (E2E
dormant-to-executable-to-behavioral) matters more than the count – it
just never backs that argument with the coverage number that would make
it load-bearing rather than qualitative. (User-flagged, S345.) Fix: pull
an actual
[`covr::package_coverage()`](http://covr.r-lib.org/reference/package_coverage.md)
percentage (or the Codecov API’s recorded value) at both endpoint
commits (`4548aa1b`, `8ca8bb24`) if reconstructable, or at minimum the
current value with an honest “not reconstructable at the v1.0.8
endpoint” caveat if not; consider also citing total test-*case* count
(not just file count) alongside the existing file-count table.

**`inst/_pkgdown.yml`’s curated Reference-page grouping is dead
configuration** (READY, Effort S) – discovered during S345’s Document-2
planning research. `pkgdown`’s own config resolver
(`pkgdown:::pkgdown_config_path`) picks the first existing file from
`_pkgdown.yml`, `_pkgdown.yaml`, `pkgdown/_pkgdown.yml`,
`pkgdown/_pkgdown.yaml`, `inst/_pkgdown.yml`, `inst/_pkgdown.yaml` in
that order; the project’s root `_pkgdown.yml` exists (no `reference:`
key), so `inst/_pkgdown.yml`’s “Data objects”/“Major Features and
Functions”/“Primary interactive functions”/“All exposed functions”
grouping is never read. Confirmed live on the deployed site
(`https://rmsharp.github.io/nprcgenekeepr/reference/index.html`): a flat
“All functions” list only, not the grouped structure `README.md:86-94`
describes. Independently, `inst/_pkgdown.yml`’s own lists have drifted
from `NAMESPACE` regardless (64 of 182 current exports missing from its
“All exposed functions” list, incl. every `mod*Server`/`mod*UI` pair) –
so fixing the shadowing alone is not sufficient; the lists need
re-syncing too, or the `reference:` block should be regenerated fresh
rather than merely un-shadowed. Fix: either move/merge
`inst/_pkgdown.yml`’s `reference:` block into the root `_pkgdown.yml`
(re-synced against current `NAMESPACE`), or delete `inst/_pkgdown.yml`
if the grouped structure is no longer wanted and update
`README.md:86-94` to match whichever is chosen. See
`docs/planning/document2-colony-manager-guide-plan.md` §1 for full
verification detail.

**`test_modBreedingGroups.R`/`test_modBreedingGroups_groupAddAssign.R`
have intermittently flaky, unseeded stochastic assertions** (READY,
Effort S) – discovered during S351’s regression verification (not
previously documented). At least 3 distinct `test_that()` blocks call
[`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
(via `modBreedingGroupsServer`) with no
[`set.seed()`](https://rdrr.io/r/base/Random.html)/`NPRC_BG_SEED` and
then assert an EXACT outcome of its random MIS sampling:
`test_modBreedingGroups.R:250` (“handles maximum number of groups”,
asserts `nGroups()==20` from a 50-animal pool),
`test_modBreedingGroups.R:1015` (“downloadGroup writes the selected
group…”, asserts every downloaded row’s `Sex` is `M`/`F`), and
`test_modBreedingGroups_groupAddAssign.R:744` (“works with
examplePedigree subset”, asserts `length(groups)==3`). Each failed
intermittently (not on every run) when the same file was re-run
repeatedly in isolation, and reproduced identically against completely
unmodified `master` (confirmed via `git stash`), so this predates S351
and is unrelated to the Custom-sex-ratio fix – it was encountered only
because the full-suite/per-file regression reads this session’s
close-out requires happened to hit it. Not filed as a GitHub issue; only
found via repeated local runs, not yet characterized for rate/trigger
(see the project’s own `[flake-aware-validation]` reflex,
`PROJECT_LEARNINGS.md`, for the discipline this needs: reproduce N
times, characterize rate + trigger, before deciding harden-now
vs. defer). Fix (either): seed each such test
([`set.seed()`](https://rdrr.io/r/base/Random.html) or the module’s own
`NPRC_BG_SEED`/`nprcgenekeepr.bg_seed` determinism hook, already used
elsewhere in `test_modBreedingGroups.R`) for a deterministic outcome, or
relax the assertions to tolerances
[`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)’s
own docs justify (MIS sampling over `iter` iterations is not guaranteed
to hit an exact count).

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
