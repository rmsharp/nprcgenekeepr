# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature
inventory & future plans → `ROADMAP.md`. (Methodology file model — see
`SESSION_RUNNER.md` Phase 0.)*

## Active

**Slice 2 of the issue \#125 plan – surface multiple breeding-group
candidates** (READY, Effort L) – `R/groupAddAssign.R`/
`R/groupMembersReturn.R`/`R/modBreedingGroups.R`, per
`docs/planning/issue125-ranking-priority-multi-candidate-plan.md`
Section 4 Slice 2. Full strict-TDD session (RED -\> GREEN -\> REFACTOR,
phase-gated). Independent of Slice 1 (S424, DONE – see `CHANGELOG.md`) –
do not bundle. Closes issue \#125 when done.

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

(none remaining – the “verify + likely fix the same low-contrast Mermaid
defect in colony-manager-guide.qmd” item (flagged S401) is RESOLVED:
verified S403 (2026-07-19) – NOT affected (the diagram is a plain
`flowchart LR` with zero `subgraph` blocks; the actual defect is scoped
to subgraph/cluster CSS, not a blanket pkgdown-mixed-mode issue – see
`PROJECT_LEARNINGS.md` Learning 371, which corrects Learning 369’s
root-cause claim). `format: html: mermaid: theme: default` applied to
this file’s frontmatter anyway, owner directed, as a
defensive/future-proofing measure. See `CHANGELOG.md`.)

(none remaining – the “fix broken ‘Read deeper’ links in the
colony-manager-guide article” item (issue
[\#124](https://github.com/rmsharp/nprcgenekeepr/issues/124), filed
S400) is RESOLVED on the
`fix/figure2-contrast-engineering-2.0.0-release` branch – fixed S404
(2026-07-20): all 10 `.qmd` hrefs retargeted directly to `.html`
(`vignettes/articles/colony-manager-guide.qmd:26,50,99-103,374,534`).
Pre-work verification found Learning 368’s “pkgdown’s mixed-mode build
doesn’t perform the rewrite” framing was incomplete – a bare local
`quarto render` of the same project (no pkgdown involved) produces the
identical unrewritten `.qmd` href, because the rewrite is a
`type: website`/`book` Quarto project feature this directory’s
`_quarto.yml` never enables (see `PROJECT_LEARNINGS.md` Learning 372,
which corrects Learning 368). All 7 distinct link targets confirmed live
at the fixed relative path (HTTP 200) before editing; rendered output
re-verified to contain zero remaining `.qmd` hrefs. **Issue \#124 stays
open** – the fix is on the unmerged/unpushed branch below, not yet live
on the published site. See `CHANGELOG.md`. **A second, distinct instance
found and fixed S407 (2026-07-21)** – owner-reported live 404 at
`.../articles/articles/colony-manager-guide.qmd`, traced to
`vignettes/ColonyManagerTutorial.Rmd:9` (the retired-tutorial stub,
already merged to `master` via S398, unlike the branch above): a
relative link with a doubled `articles/` path segment (this file renders
under `/articles/` too, so its own `articles/`-prefixed relative link
doubled) plus the same `.qmd`-vs-`.html` defect. Fixed by pointing the
link at the absolute published URL, and by renaming the file to
`_ColonyManagerTutorial.Rmd` – pkgdown’s `build_articles()` skips any
leading-`_` vignette by documented convention (verified against the
installed pkgdown 2.2.0’s own `package_vignettes()` source, not
assumed), which finally makes true the file’s own claim that it is not
part of the public site (previously false: no `_pkgdown.yml` exclusion
existed, so pkgdown was building and serving it). Owner also directed a
full live-site link sweep (all 13 published articles +
articles/reference/news index hubs, 238 resolved internal targets,
HTTP-checked) – no other broken links found; see `CHANGELOG.md` and the
issue \#124 comment thread for the full sweep result. **Merged and
deployed live – S408 (2026-07-21):** owner approved merging
`fix/figure2-contrast-engineering-2.0.0-release` into `master`
(`dd8e53fd`) now that the CRAN v2.0.0 submission is sufficiently
handled. Live verification after deploy found a second, unrelated defect
blocking the fix from actually taking effect:
`.github/workflows/pkgdown.yaml`’s `clean: false` deploy step meant
`gh-pages` had only ever accumulated files, never removed stale ones
(981 files, including 3 old copies of this same tutorial, one still
serving the exact `.qmd`-targeting link live). Fixed (`clean: true`,
`f5b73edf`), redeployed, verified: `gh-pages` dropped to 650 files, zero
`ColonyManagerTutorial` matches, all stale URLs 404,
`colony-manager-guide.html` has zero remaining `.qmd` hrefs. **Issue
\#124 is now fully resolved live**, not just in source. See
`CHANGELOG.md`.)

(none remaining – the “Branch-merge strategy for
`fix/figure2-contrast-engineering-2.0.0-release`” item is RESOLVED:
merged into `master` and deployed live – S408 (2026-07-21), see the
issue \#124 item above and `CHANGELOG.md`.)

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

(none remaining – the “CRAN resubmission of v2.0.0” item is RESOLVED:
**CRAN accepted the 2.0.0 submission and published it 2026-07-26**
(confirmed live via CRAN’s own package page and CRAN’s automated
Windows-binary-build notification email). The full submission saga –
archived 2025-07-29, resubmitted, rejected S392 on Windows checktime,
fixed and resubmitted S395-397, CRAN’s incoming-pretest confirmed clean
S399 – is recorded session-by-session in `CHANGELOG.md`. **Phase 6
(Post-acceptance, `docs/planning/cran-2.0.0-submission-plan.md:324`)
executed – S410 (2026-07-28):** the `v2.0.0` GitHub Release created (the
tag and the `DESCRIPTION` dev-version bump to `2.0.0.9000` were already
done ahead of time in S407); `CRAN-SUBMISSION` deleted (its job is
resolved); `NEWS.Rmd`’s stale “under review” dev-version note fixed. See
`CHANGELOG.md`. If a future CRAN cycle requires a fix-and-resubmit, it
ships as **2.0.1** – the `v2.0.0` tag never moves, since it is the one
and only submission that will ever carry that version number.

## Housekeeping

**`inst/extdata/` reorganization – Phase 4** (DECISION NEEDED – 2 open,
non-blocking decisions, Effort M) – plan:
`docs/planning/extdata-reorganization-plan.md` (S414). **Phase 1 DONE –
S415 (2026-07-28):** relocated the 12 dev-scratch + 12 orphaned
zero-reference items (24 total – the plan’s own summary table
undercounted this as “11 + 9”; `PROJECT_LEARNINGS.md` Learning 381) into
`dev/extdata-scratch/`, removed 3 empty untracked dirs (`claude/`,
`dev_scripts/`, `uat/`) + the now-empty `code_under_development/`, and
deleted 11 now-obsolete `.Rbuildignore` lines (the 10 the plan named
plus one it missed, Learning 381) + 10 dead `.gitignore` lines.
Verified: `devtools::check()` 0 errors/0 warnings (see the new
spelling-NOTE item below re: the 1 NOTE found, unrelated to this reorg –
Learning 382); `R CMD build` tarball no longer contains
`create_nprcgenekeepr_hexbadge.R` or any other dev-scratch item;
regression suite unchanged at 0 failed/0 error/0 warning, 3198 passed,
179 skipped (S412 baseline). See `CHANGELOG.md`. **Phase 2 DONE – S416
(2026-07-28):** both blocking open decisions resolved first – subfolder
name **`examples/`** (owner-picked via `AskUserQuestion`), and
`vignettes/a2interactive.R`’s generation status (owner-directed: `.Rmd`
files are the source; `.R`/`.md`/`.html` are generated derivatives –
confirmed also gitignored/untracked, `.gitignore:18,20,22`, so the
tracked-source fix is the `.Rmd` edit alone; the local `.R` copy was
regenerated via
[`knitr::purl()`](https://rdrr.io/pkg/knitr/man/knit.html) as a
courtesy, not committed). `git mv`’d all 10 load-bearing files into
`inst/extdata/examples/`; updated the central `get_test_data_path()`
test helper, ~28 individual
[`system.file()`](https://rdrr.io/r/base/system.file.html) call sites
across 15 test files, 7 path-bearing roxygen/comment prose sites
(`R/defaultSiteParams.R`, `R/loadSiteConfig.R`,
`data-raw/rhesusGenotypes.R`, `data-raw/rhesusPedigree.R`, plus 2
test-file comments), and the one hardcoded path in
`vignettes/a2interactive.Rmd`; regenerated `man/loadSiteConfig.Rd` (the
only one of the plan’s 5 named `.Rd` files that actually needed it – the
other 4 are generated from `R/data.R`, whose extdata mentions are plain
filenames with no path prefix, confirmed unaffected). Verified: fresh
regression suite exactly matches baseline (0 failed/0 error/0 warning,
3198 passed, 179 skipped); `R CMD build` tarball confirmed shipping all
10 files under `examples/` and nothing at the old flat path;
`devtools::check()` 0 errors/0 warnings, 1 NOTE (the same pre-existing,
unrelated spelling gap from S415, confirmed untouched by this session’s
diff); grep sweep confirmed the only 3 remaining un-migrated references
are exactly the ones the plan defers to Phase 3
(`vignettes/manual_components/_summary_of_major_functions.Rmd`’s GitHub
blob URL source, plus its 2 gitignored rendered byproducts). See
`CHANGELOG.md`. **Phase 3 DONE – S417 (2026-07-28):** re-ran the plan’s
own Dragon 1 grep before touching anything (never trust a prior
session’s or the plan’s own phase prose as final) and found the plan’s
Phase 3 “What DONE looks like” text undersold the actual scope:
`vignettes/articles/offline-focal-animal-workflow.qmd:104,106` called
`system.file("extdata", "<file>", ...)` directly with no `examples`
segment – confirmed in R this returned `""` (broken) since Phase 2 moved
the files, even though the plan’s own §8.1 evidence table had already
listed this exact call site. Fixed as the source bug it was, not just a
re-render target. Also fixed the stale GitHub blob URL in
`vignettes/manual_components/_summary_of_major_functions.Rmd:66`.
Re-rendered all 3 targets (`a3manual.Rmd` with `keep_md = TRUE` to also
refresh the gitignored `.md` byproduct; `a2interactive.Rmd`; the `.qmd`
pkgdown article via `quarto render`, which required a throwaway local
package install – `devtools::install()` – since the article’s
[`library(nprcgenekeepr)`](https://rmsharp.github.io/nprcgenekeepr/)
call needs a real install, not just
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)).
Verified: the fixed
[`system.file()`](https://rdrr.io/r/base/system.file.html) calls resolve
and return real data in the rendered article (`dim(colonyPed)` = 2922 x
11, not an error); the plan’s prescribed grep sweep plus a broadened
check of `vignettes/articles/*.html` both return zero stale-path hits;
`gh api` confirmed the GitHub blob URL target actually exists on
`origin/master` (Dragon 2’s “manual link click” requirement); regression
suite exact baseline match (0/0/0, 3198 passed, 179 skipped);
`devtools::check()` 0 errors/0 warnings, 1 NOTE (same pre-existing
spelling gap below, confirmed untouched – read from the raw check log’s
`Status:` line per Learning 382, not the colored summary, which again
showed 0 notes). See `CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning
384. **Phase 4 DONE – S418 (2026-07-28):** both open decisions resolved
via `AskUserQuestion`: PDF placement -\> `inst/extdata/reference/`
(end-user-facing reference material, plan’s own default); orphaned-files
archive-vs-delete -\> keep archived at `dev/extdata-scratch/`, no change
from Phase 1. `git mv`’d the PDF; ran the plan’s final repo-wide sweep
grep, which found `README.md` stale relative to its already-fixed source
(`README.Rmd` `child=`-includes `_summary_of_major_functions.Rmd`, fixed
by S417, but never re-rendered) – re-rendered `README.Rmd` to pick up
the fix; see `PROJECT_LEARNINGS.md` Learning 385. All other sweep hits
triaged as false positives: dated historical prose in
`NEWS.Rmd`/`NEWS.md` and `docs/planning/`/`docs/research/` documents
describing repo state as it existed when written, correctly left
unedited. Verified: `R CMD build` tarball ships the PDF at
`inst/extdata/reference/` and nothing at the old flat path; regression
suite exact baseline (0/0/0, 3198 passed, 179 skipped);
`devtools::check()` 0 errors/0 warnings, 1 NOTE (same pre-existing
spelling gap below, confirmed untouched). **The `inst/extdata/`
reorganization plan is now fully executed (Phases 1-4 all DONE).** See
`CHANGELOG.md`.

(none remaining – the “`ROADMAP.md`’s doc-engine-policy line is now
stale” item (flagged S418) is RESOLVED: owner resolved the editorial
wording call via `AskUserQuestion` – **path-only fix**, keeping the
doc-engine-policy category and just correcting the location –
`ROADMAP.md:21-22` now reads `dev/extdata-scratch/` developer docs
instead of `inst/extdata/` developer docs, matching where the 3 dev docs
(`claude_code.qmd`, `software_design_doc.qmd`, `meeting_notes.qmd`)
actually live since the extdata reorg’s Phase 1 (S415) – S420
(2026-07-29). See `CHANGELOG.md`.)

(none remaining – the “`NEWS.md:8` spelling-check NOTE –
`CRAN's`/`resubmission` missing from `inst/WORDLIST`” item (discovered
S415, 2026-07-28) is RESOLVED: both words hand-added to `inst/WORDLIST`
in their case-insensitive-collation position (not via
[`spelling::update_wordlist()`](https://docs.ropensci.org/spelling//reference/wordlist.html),
per S230 convention) – S421 (2026-07-29). Verified: `devtools::check()`
raw log `Status: OK`, 0 notes. See `CHANGELOG.md`.)

(none remaining – the “clean up stale untracked leftover files” item
(filed S383) is RESOLVED: 18 confirmed-dead untracked files deleted –
S384 (2026-07-15). See `CHANGELOG.md`.)

(none remaining – the “`README.Rmd` leaves an untracked `README.html`
byproduct on every render” item (flagged S410, `PROJECT_LEARNINGS.md`
Learning 376(b)) is RESOLVED: `html_preview: false` added to
`README.Rmd`’s `output: github_document` frontmatter, mirroring
`NEWS.Rmd`’s already-working pattern – S411 (2026-07-28). Verified by
re-rendering: no `README.html` byproduct produced. See `CHANGELOG.md`.)

(none remaining – the “`CLAUDE.md`‘s ’Clean regression read’ command
needs a
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
call added” item (flagged S411, `PROJECT_LEARNINGS.md` Learning 377) is
RESOLVED: `pkgload::load_all(".", quiet=TRUE)` prepended to the
documented command text (`CLAUDE.md:149`) – S412 (2026-07-28). Verified
by running the fixed command verbatim: 0 failed/0 error/0 warning, 3198
passed, 179 skipped, matching the known-good baseline. See
`CHANGELOG.md`.)

## Outreach

**NPRC outreach & announcement plan** (DECISION NEEDED – owner
review/edit of drafts + send timing; Effort N/A, not a coding task) –
plan complete: `docs/planning/nprc-outreach-announcement-plan.md` (S413,
owner-directed, not from this backlog). Covers audiences (the NPRC
Genetics and Genomics Working Group, plus each of the 7 centers’
colony-manager/veterinarian contacts), tailored messaging, channels, a
sourced 7-center contact roster (director + colony-manager/
head-veterinarian-equivalent + genetics contact per center, each with a
source), a generic timeline, 5 named risks, and ready-to-edit draft
materials (WG email, colony-manager/vet email, one-page feature summary,
presentation outline). Two items remain genuinely unresolved after
dedicated research, not just undone: the Working Group’s current (2026)
chair could not be confirmed (recommended action: ask
`support@nhprc.org` directly, see the plan’s §3/§8); and a
colony-manager contact could not be named at 3 of 7 centers (Southwest,
Tulane, Washington – the role is undocumented by name on each center’s
own site). **Next steps are owner-executed, real-world actions**
(review/edit the drafts, confirm exact recipients, send) per the plan’s
own §7 – pick this up in a future session only if the owner wants help
drafting a specific follow-up, not as a general “send the emails” coding
task. See `CHANGELOG.md`.

## Architecture (issue \#122 / XARCH-2 – module contract)

*Resolved – S372 planning session through S377 execution (Phases 1-5,
all DONE); see `CHANGELOG.md` for the per-phase detail (S373
vocabulary-composition fix, S374 kinship dedup, S375 vocabulary
collapse, S376 dead-surface pruning, S377 contract doc + guard test).
The living contract is `docs/architecture/module-contract.md`; it is
enforced by `tests/testthat/test_moduleContract.R`. `modInput` is the
reference implementation.* - \[ \] (none remaining) - \[ \] (none
remaining – the former “4 remaining unguarded
[`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
call sites” item is now fully resolved:
`R/getPedigreeSource.R:83`/`R/getLkDirectAncestors.R:26` guarded S382
(see `CHANGELOG.md`); `R/modORIPReporting.R:148`/`:244`,
`R/appServer.R:124` guarded S380. The remaining 2 sites now stand as
their own item below, since they need a genuinely different design
decision.) - \[ \] (none remaining – the
“[`setLabKeyDefaults()`](https://github.com/rmsharp/nprcgenekeepr/reference/setLabKeyDefaults.md)/[`getDemographics()`](https://github.com/rmsharp/nprcgenekeepr/reference/getDemographics.md)
unguarded
[`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
call sites” design-decision item is RESOLVED: decline, no code change –
S383 (2026-07-15). See `CHANGELOG.md`.) - \[ \] (none remaining – issue
\#123 (XARCH-5) Phase 1 implementation (S386) and the follow-up GitHub
issue comment reflecting partial, scoped closure (S387, 2026-07-15,
<https://github.com/rmsharp/nprcgenekeepr/issues/123#issuecomment-4986749021>)
are both done; the issue is left OPEN, per the plan’s own §10 decision
5, pending the escalation triggers it names. See `CHANGELOG.md`.)

## Documents (v1.0.8 -\> v2.0.0 write-up)

(none remaining – Document 2
(`docs/planning/document2-colony-manager-guide-plan.md`) is fully
executed: planning DONE (S345), Phase A DONE (S346), Phase B DONE
(S347), Phase C DONE (S348), **Phase D DONE (S398, 2026-07-17)** – full
claim-source audit, `pkgdown`/`R CMD build` verification, and the
`ColonyManagerTutorial.Rmd` retire/redirect decision. See
`CHANGELOG.md`.)

## Audit follow-ups

*(From `PED_GV_AUDIT_2026-05-30.md`; all audit follow-up items are now
resolved — see `CHANGELOG.md`. Per-item reachability notes and traps
live in `CLAUDE.md` “Project-specific Learnings”.)* - \[ \] (none
remaining)

## Genetic-metrics PDF audit follow-ups (from GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md)

*S419’s capability-comparison audit
(`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md`)
compared the package against the 2015 NHP Genetics and Genomics Working
Group PDF and found 12 missing / 9 partial findings (of 37 total).
Triaged S422 (2026-07-29) via owner `AskUserQuestion` picks – all 6
findings/clusters owner-directed to file as GitHub issues, tracked
there, not here: **\#125** (configurable ranking-priority scheme +
surface multiple breeding-group candidates, Dimensions 1 & 2), **\#126**
(kinship/genome-uniqueness distribution shape statistics – skewness,
kurtosis, Dimension 3), **\#127** (surface
`correctUnknownParentMeanKinship()`’s silently-dropped `flagged` list,
Dimension 4), **\#128** (breeding-group exclusion is top-N rank-based,
not a genetic-value floor, Dimension 2), **\#129**
(pedigree-diagram/tree visualization, currently table-only, Dimension
7), **\#130** (marker-based
kinship/heterozygosity/parentage-verification + cross-center identity
resolution, Dimensions 5 & 6). 1 finding (NGS/whole-genome/MHC-specific/
linkage-disequilibrium methods, Dimension 5) declined, no action – the
source PDF itself frames these as speculative future work even in 2015,
matching the audit’s own Recommendation \#5. The remaining findings
(PMX/MateRx/Pedscope/PedSys tool-comparison notes, the “make pedigree
available to researchers” governance recommendation) are descriptive or
already-adequately-served, not gaps requiring tracking. See
`CHANGELOG.md`.* - \[ \] (none remaining – all actionable items tracked
via GitHub issues \#125-#130 above.)
