# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature
inventory & future plans → `ROADMAP.md`. (Methodology file model — see
`SESSION_RUNNER.md` Phase 0.)*

## Up Next

**Move the version to 3.0.0 just before release (READY at release time,
Effort S)** – the owner decided (S855) the next release is **3.0.0**.
Until then `DESCRIPTION`, the `NEWS.Rmd`/`NEWS.md` heading, `README.md`
and `ROADMAP.md` stay at 2.0.0.9000 on purpose. At release prep: set
`DESCRIPTION` to 3.0.0, retitle the `NEWS.Rmd` dev block to 3.0.0 and
re-knit `NEWS.md`, reinstall the package and re-render `README`
(Learning 376), and update the 2.0.0.9000 cites in `ROADMAP.md`. The
paper-dependency item below also waits on a released 3.0.0.

**Prepare the 3.0.0 CRAN submission** (plan
`docs/planning/cran-3.0.0-submission-plan.md`, S1091, DRAFT; Phase 1
DONE S1093; Phase 2 IN PROGRESS, its cut measured S1094 and more is
owed; DECISION NEEDED on D1-D3, D5 and D6 (D4 ruled A, S1092); Effort L,
about 8-10 sessions left) – **Phase 1 (S1093):** the linux-arm64 failure
is a bug in R itself (utils `readtablehead()`,
`src/library/utils/src/io.c:910`, unfixed through R-devel): on Linux
ARM64
[`read.csv()`](https://rdrr.io/r/utils/read.table.html)/[`read.table()`](https://rdrr.io/r/utils/read.table.html)
of a file whose last value is quoted and that has no final newline read
that value with a stray 0xFF byte. Every package read now goes through
`readWithFinalNewline()` (`R/readWithFinalNewline.R`), and the failing
test passes in CRAN’s own arm64 image (container `ngk-arm64-s1093`, kept
for Phase 7). S1094 made its added newline one byte on Windows too (it
was `\r\n` from [`cat()`](https://rdrr.io/r/base/cat.html), an ERROR on
win-builder). Phase 8’s cover note must say so, and that CRAN’s arm64
job confirms it only after release. Whether to report the R bug upstream
(one-line case: `writeChar('a,b\n1,"x"', f, eos = NULL); read.csv(f)$b`
gives `x\xff`) is the owner’s call; nothing has been posted. **Phase 2
so far:** a CRAN check leaves out the 64 test files named in
`tests/testthat/slowTestFiles.txt` (S1092). **Measured on win-builder
R-devel (S1094): 652 s** for the cut tree, against 1,722 s uncut; the
tests 156 s and everything else about 496 s, so the 540 s target (D4 =
A) leaves the tests about 45 s there. **Owed to finish Phase 2:** a
further cut of about 112 s, chosen by the owner from the measured levers
in the plan’s section 3.4 (the `getGeneticDiversityStats` example’s
input, the loop functions’ twofold slowdown since 2.0.0, more test skips
with a fast test for each export they strand, the `a2interactive`
vignette), and whether 540 s stays the target; then one R-devel upload
to measure it. Still open after Phase 2: `R/modSummaryStats.R` calls the
Suggests package `shinyBS` with no guard (Phase 4a), and one help-page
DOI is wrong (Phase 3); the incoming NOTE also flags “de”
(`DESCRIPTION:37`) and the thoughtco.com URL (status 402, explained in
2.0.0’s note). The plan’s section 7 orders the phases; the item above is
its Phase 6.

**Create a tutorial for prospective contributors** (owner-requested
2026-09-26; DECISION NEEDED, Effort M) – there is no contributor guide
today: measured 2026-09-26, no `CONTRIBUTING.md` or `CODE_OF_CONDUCT` at
the repo root or in `.github/` (which holds only `workflows/`).
Candidate contents, from what this project’s own docs already say:
getting set up (clone,
[`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html),
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html));
where things live (`R/` functions, the modular Shiny app `appUI.R` +
`appServer.R` + `mod*.R`, `tests/testthat/`, the Quarto articles under
`vignettes/articles/`, `inst/extdata/`); running tests (the fast
single-file command, the full suite, `devtools::check()`); the
write-tests-first workflow; lint; roxygen / `man/` / `_pkgdown.yml` and
`NEWS.Rmd` expectations; and how to propose a change. **Decisions the
pickup needs from the owner first:** (a) form and home – a
`CONTRIBUTING.md` plus a pkgdown article, or a Quarto article alone; (b)
how much of this project’s internal discipline (strict
RED/GREEN/REFACTOR phase gates, the session protocol) is asked of
outside contributors versus kept internal; (c) audience – R developers,
colony managers who script, or both. The tutorial/article documentation
checklist in `CLAUDE.md` applies; take the commands from its “Build /
Test / Verify” section and re-check them rather than copying them from
here.

**Earlier-snapshots follow-up after \#170: build cost on a larger
colony** (BLOCKED – needs a studbook above 3,694 rows from the owner,
Effort S; \#170 is closed and its other follow-ups shipped S1042, S1049,
S1085 and S1086, see `CHANGELOG.md`) – the cost line’s quarter of a
second a date per 1,000 iterations (`describeBackfillCost()`,
`R/modSnapshotTrends.R`; S1065) is measured on the 2,590-animal jmac
studbook (53 dates, 12.6 s) and the 3,694-row example (49 dates, 9.4 s),
so a bigger colony is unmeasured. Design:
`docs/planning/retrospective-snapshot-backfill-plan.md` sections
5.3-5.4.

**Act on the LabKey integration research recommendations** (BLOCKED –
remainder needs a live LabKey server to test/observe, Effort M) —
research pass DONE
(`docs/research/labkey-integration-options-2026-06-19.md`, S143); Recs
\#1-#5 all DONE, S144-S152 (S155 added richer file-read errors), see
`CHANGELOG.md`:
[`setLabKeyDefaults()`](https://github.com/rmsharp/nprcgenekeepr/reference/setLabKeyDefaults.md)
(optional API-key auth), `Rlabkey (>= 3.2.0)`, `defaultSiteParams()`,
the internal `getPedigreeSource()` (`labkey`/`dataframe`/`file`),
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
delegating its walk to
[`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)
(a deliberate, owner-accepted behavior change: it now returns the full
connected component), and the exported
[`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md)
and
[`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
(the Shiny focal-animal workflow now runs offline). The live ONPRC/SNPRC
server version (doc §8.1) is still unobserved. **Still deferred:** a
non-LabKey other-EHR provider on the same seam; server-side filtering /
`executeSql` / consuming the centers’ `study.Pedigree`/`ehr.kinship`
(the research doc defers this until pull size is measured and per-center
query availability/permissions are confirmed; it needs a live LabKey
server to test/observe, and a naive focal-id server filter is
incompatible with the client-side connected-component walk).

**Work with LabKey (Josh Eckels) to update the LabKey integration**
(owner-requested 2026-09-26; BLOCKED – needs the owner to make contact,
and the deferred technical work also needs a live LabKey server; Effort
M, not a coding task until scoped) – companion to “Act on the LabKey
integration research recommendations” above, which records what is DONE
(Recs \#1-#5), what is unobserved (the live ONPRC/SNPRC server version)
and what was deferred pending per-center confirmation (server-side
filtering / `executeSql`, consuming the centers’ `study.Pedigree` /
`ehr.kinship` queries, a non-LabKey EHR provider). Nothing in this
repository records any contact with LabKey yet. **Suggested first step
(the owner’s):** talk with Josh Eckels about the current LabKey API and
`Rlabkey` direction and what he would change or add on the LabKey side,
using the deferred questions from that item as the agenda; then decide
which package changes follow and file each as its own item. Research
base: `docs/research/labkey-integration-options-2026-06-19.md`.

**Build a kinship2-similar standalone pedigree package from this
repository’s code — committed, deferred** (disposition S742, 2026-09-20;
BLOCKED – prep steps ALL DONE (D-1 S744, D-2 S745, D-3 S746); the
remaining blocker is the S738 revisit conditions only, scoping doc §6:
engine churn calms + an accepted CRAN release; Effort L, its own
planning session first when unblocked) – owner disposition closing the
S739 two-step discussion item (step 1: gap analysis DONE S741,
`docs/research/kinship2-feature-gap-analysis-2026-09-20.md`, 15 EQ / 8
PARTIAL / 2 ABSENT; step 2: this decision — full record in
`CHANGELOG.md` S742). **The package WILL be built; only the timing is
deferred (“gates stand”). Purpose (owner-stated): a standalone
near-equivalent of kinship2 carrying nprcgenekeepr’s enhanced features —
particularly the pedigree drawing, annotation ability, and
interactivity; nprcgenekeepr may eventually consume it, but that is NOT
the primary goal** (i.e. plan a sibling product first, not an extraction
nprcgenekeepr must immediately depend on). **Ratified scope (S742, so
the plan session doesn’t re-derive):** drawing surface IN — lift the
module-bound decorations (`R/modPedigree.R`, about `:689-890`: legend,
image export, tooltips) into a script-callable visNetwork renderer (the
unique value per the gap doc’s ecosystem observation; the one
substantive new-work item); parity closers IN — export the shrink
helpers + `bitSize` (tested internals in `R/shrinkPedigree.R`:
`.bitSizeOf`, `.findUnavailable`, `.findAvailAffected`), port
`familycheck` + `ibdMatrix` (the two full absences), and user-suppliable
layout hints (autohint’s override half — real engine-surface design);
OUT — block-sparse `makekinship` (dense whole-colony matrices are
current practice); API shape (data-frame-as-is vs kinship2-compat layer)
DELIBERATELY OPEN — decide at plan time with a prototype in hand. When
unblocked, the pickup is a planning session (package boundary/plan doc
in `docs/planning/`, evidence-based inventory). **Prep is done** (D-1
S744, D-2 S745, D-3 S746; each is in `CHANGELOG.md`):
`makePedigreeMatingLayout(kinshipMatrix = )`
(`R/makePedigreeDiagramData.R`) is the injectable boundary the package
needs, and the 13 `R/positionTreeApportion.R` functions carry `@noRd`
roxygen. **One prep claim has drifted (found S896):** D-2 took every
test outside the layout core’s own files off `.buildMatingUnitForest()`,
but `tests/testthat/test_newsReleaseState.R:234,248` has called it
directly since S790-S791 (NEWS release-state counts; it is not one of
the scoping doc’s 9 core test files), so the planning session must
re-run the grep and decide where that test lives. (The owner accepted
S667’s recommendation NOT to split the layout core, recorded S738; the
prep steps stand whether or not a split ever happens.)

**`CHANGELOG.md` regrows faster than it is trimmed: shorter entries are
the open lever** (found S543, 2026-08-12; DECISION NEEDED – the owner’s
choice of lever, Effort S) – every session writes a claim entry and a
DONE entry, often a trim or push entry too, and the file outgrows its
trims: 258,724 B seven days after its 2026-09-27 trim (S897: `SRF_RED`
7.9455, the owner took a `--force` trim to 25,172 B), and 201,025 B at
S1088’s `--force` trim, which archived the 87 records of 2026-10-23 to
2026-10-27. Measured S1089 on the six sessions of 2026-10-28: claim
entries 439-766 B, DONE entries 2,393-4,668 B (24,094 B in all, 86% in
the DONE entries), so the length of the DONE entries, not their number,
carries most of the bytes. The lever, open since S897: shorter DONE and
claim entries (and receipts); the canonical design’s remedy for the same
problem in `HANDOFFS.md` (“Receipt Inflation”, H4) is “a norm plus a
check, not an archiver” (`docs/planning/ledger-trimmer-design.md` §10.2,
not in this repo).

**`BACKLOG.md`’s own ledger-size housekeeping – editorial compression,
not a `methodology_trim.py` config** (found S518, 2026-08-11, READY,
Effort L; RECURRING – last pass S1089, 2026-10-29) – its `##` sections
are standing *topical* categories, not dated newest-on-top records, so
`methodology_trim.py` cannot archive them; the file’s own header states
the remedy (“Open, actionable work only… for history see
`CHANGELOG.md`”). Items **regrow** as later sessions append progress
narrative (Learning 626), so this is a recurring pass, never a one-time
fix. **Pass history** (each pass’s figures are in its own `CHANGELOG.md`
entry, live or under `methodology/archive/`): S529, S530, S531, S606,
S752, 2026-09-24 (ad hoc), S890, S896, S1089. File size: 378 lines on
2026-09-24, 599 at S853, 514 after S896, 234 before S1089 and 208 after
it, with the new \#138 item (most of the fall since S896 is finished
items coming off, not passes). **Method (every pass, all steps):**
before compressing anything to a pointer, (1) verify `CHANGELOG.md` +
`methodology/archive/CHANGELOG-*.md` (pre-S325:
`docs/archive/CHANGELOG-legacy-pre-S325.md`) carry an entry heading for
every session number cited AND that the load-bearing facts are inside
those entries (a heading alone proves little); (2) confirm every cited
Learning / doc path resolves and every issue state via `gh issue view`,
not prose; (3) extract any buried open thread as its own item first; (4)
replace whole line ranges mechanically (Learning 537: a partial
`old_string` leaves later paragraphs duplicated beside the new bullet);
(5) leave open items byte-untouched; (6) re-read the compressed result
end to end. **Candidates for the next pass (measured S1089; re-grep,
sizes not anchors):** the finished-work narrative in three of the six
items the owner delayed on 2026-10-22, left alone at S1089 at the
owner’s word: the LabKey research item’s list of what Recs \#1-#5
shipped, the standalone-package item’s disposition history (its
`test_newsReleaseState.R:234,248` cite is stale: the calls are now at
`:202` and `:216`), and the outreach item’s list of the plan’s contents.

**Take the methodology files the S1032 sync held back (BLOCKED – on a
fix to `close_out_report.py` in the methodology repo, Effort S once it
ships)** (found S1032, 2026-10-22) – the sync copied 7 of 10 files and,
at the owner’s word, held back `SESSION_RUNNER.md` (2 versions behind),
`SAFEGUARDS.md` (1 behind) and the new `close_out_report.py` (not
installed). The newest runner (commit `8f63492b`) makes section 3G run
`python3 close_out_report.py` and print its output as the last message;
v1.2.0 reads the example box in `HANDOFFS.md`’s front matter as the
newest receipt and refuses
(`refused: newest receipt (S<N>) is <pending | complete>`), here and on
the blank seed. The runner’s Oct 12 commit `95005e87` (its subject: a
gate run that reads unmeasured gates is repaired and repeated, or each
gate is named) is held with it. Evidence, a tested 4-line fix and the
draft upstream report, **not posted anywhere** (where to post it is the
owner’s call): `docs/audits/CLOSE_OUT_REPORT_EXAMPLE_BOX_2026-10-22.md`.
**What is left:** when the script reads this ledger, sync again
(`bin/sync --force`, then the trimmer patch per
`docs/conventions/CLOSEOUT_CHECKLISTS.md`) and, before keeping the
script, print a report from a ledger whose newest receipt is complete;
`bin/status` lists these three files until then.

**Draw the full colony beyond the Diagram tab’s cap (issue \#138, low
priority; READY – the pickup is a scoping session, not a build; Effort M
for that session)** – the tab draws at most 750 animals (400 with
Rectilinear edges), about 1,500 drawn nodes (`R/modPedigree.R:453,465`;
the issue’s title still says “1,500-node cap”). Its source audit
(`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`,
Finding \#7) advised no action; the issue says a real need warrants a
design session (for example a colony summary view), not a higher cap.

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

**Develop paper(s) for peer-reviewed journals** (owner-requested
2026-09-26; DECISION NEEDED, Effort L, its own scoping session first;
multi-session) – the owner supplied a venue-fit summary (from an
AI-assisted conversation) to start from. **Treat its journal assessments
as unverified leads:** check each journal’s current scope, article types
and fees before committing. Its recommendation, in short: version 3.0 is
more than an incremental update, so write **two complementary papers**
that cite each other – (1) a **software paper** for *The R Journal* or
the *Journal of Open Source Software* (package architecture, workflows,
reproducibility, new features; the canonical citation for the package;
per the summary, JOSS is very short and citation-like, while *The R
Journal* allows longer technical descriptions with code examples) and
(2) an **applied genetics paper** for the *American Journal of
Primatology* or the *Journal of Medical Primatology* (how the software
improves genetic management of captive primate colonies, with realistic
examples and best practices) – and optionally (3) a **retrospective
paper** on the evolution of computerized genetic management in NPRC
colonies over past decades (historical and methodological, for readers
interested in colony-management practice). The summary also grouped
further candidates into tiers (computational-biology software,
conservation genetics, statistical computing, and
animal-colony-management journals), but **the journal names in those
tiers were lost when it was pasted** – only the four above survive – so
the pickup must get the original list from the owner. Open decisions:
which papers, authorship, and what is new in 3.0 relative to the
published reference (Vinson & Raboin 2015, *JAALAS* 54(6):700-707, the
package’s key reference in `CLAUDE.md`, whose Project Overview also
holds the NIH grant acknowledgment). Natural dependency, the owner’s
call: a released 3.0.0 to cite (`DESCRIPTION` reads 2.0.0.9000 today);
the documentation audit is finished (S1027, `CHANGELOG.md`), so the
papers’ figures match the software.
