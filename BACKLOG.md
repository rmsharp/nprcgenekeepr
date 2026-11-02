# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature
inventory & future plans → `ROADMAP.md`. (Methodology file model — see
`SESSION_RUNNER.md` Phase 0.)*

## Up Next

**Prepare the 3.0.0 CRAN submission** (plan
`docs/planning/cran-3.0.0-submission-plan.md`, S1091, DRAFT; Phases 1-8
DONE S1093-S1105, recorded in the plan’s sections 3.4-3.6 and 5 and in
`CHANGELOG.md`; Phase 9 DONE, the owner submitted 2026-10-31 from
`fa1f2849e`; **CRAN accepted, its page shows 3.0.0 published
2026-11-01**; READY, Phase 10 is the one session left, Effort S; all of
D1-D6 ruled, the recommended option each) – **The tree stays frozen
until Phase 10 starts.** `use_github_release()` tags the
`CRAN-SUBMISSION` SHA, and 55 or more local notes commits sit ahead of
`origin/master`, so push first. CRAN’s arm64 job confirms the Phase 1
fix only on its check page, a few days after publication. The plan’s
section 7 orders the phases; its Phase 10 lists the steps.

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
`CHANGELOG.md`. The live ONPRC/SNPRC server version (doc §8.1) is still
unobserved. **Still deferred:** a non-LabKey other-EHR provider on the
same seam; server-side filtering / `executeSql` / consuming the centers’
`study.Pedigree`/`ehr.kinship` (the research doc defers this until pull
size is measured and per-center query availability/permissions are
confirmed; it needs a live LabKey server to test/observe, and a naive
focal-id server filter is incompatible with the client-side
connected-component walk).

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
BLOCKED – prep steps ALL DONE (S744-S746, `CHANGELOG.md`); the remaining
blocker is the S738 revisit conditions only, scoping doc §6: engine
churn calms + an accepted CRAN release; Effort L, its own planning
session first when unblocked) – gap analysis:
`docs/research/kinship2-feature-gap-analysis-2026-09-20.md`. **The
package WILL be built; only the timing is deferred (“gates stand”).
Purpose (owner-stated): a standalone near-equivalent of kinship2
carrying nprcgenekeepr’s enhanced features — particularly the pedigree
drawing, annotation ability, and interactivity; nprcgenekeepr may
eventually consume it, but that is NOT the primary goal** (i.e. plan a
sibling product first, not an extraction nprcgenekeepr must immediately
depend on). **Ratified scope (S742, so the plan session doesn’t
re-derive):** drawing surface IN — lift the module-bound decorations
(`R/modPedigree.R`, about `:689-890`: legend, image export, tooltips)
into a script-callable visNetwork renderer (the unique value per the gap
doc’s ecosystem observation; the one substantive new-work item); parity
closers IN — export the shrink helpers + `bitSize` (tested internals in
`R/shrinkPedigree.R`: `.bitSizeOf`, `.findUnavailable`,
`.findAvailAffected`), port `familycheck` + `ibdMatrix` (the two full
absences), and user-suppliable layout hints (autohint’s override half —
real engine-surface design); OUT — block-sparse `makekinship` (dense
whole-colony matrices are current practice); API shape (data-frame-as-is
vs kinship2-compat layer) DELIBERATELY OPEN — decide at plan time with a
prototype in hand. When unblocked, the pickup is a planning session
(package boundary/plan doc in `docs/planning/`, evidence-based
inventory). **One prep claim has drifted (found S896):** D-2 took every
test outside the layout core’s own files off `.buildMatingUnitForest()`,
but `tests/testthat/test_newsReleaseState.R:198,212` calls it directly
(NEWS release-state counts; it is not one of the scoping doc’s 9 core
test files), so the planning session must re-run the grep and decide
where that test lives.

**`BACKLOG.md`’s own ledger-size housekeeping – editorial compression,
not a `methodology_trim.py` config** (found S518, 2026-08-11, READY,
Effort L; RECURRING – last pass S1108, 2026-10-31) – its `##` sections
are standing *topical* categories, not dated newest-on-top records, so
`methodology_trim.py` cannot archive them; the file’s own header states
the remedy (“Open, actionable work only… for history see
`CHANGELOG.md`”). Items **regrow** as later sessions append progress
narrative (Learning 626), so this is a recurring pass, never a one-time
fix. Each pass’s figures are in its own `CHANGELOG.md` entry, live or
under `methodology/archive/`. **Method (every pass, all steps):** before
compressing anything to a pointer, (1) verify `CHANGELOG.md` +
`methodology/archive/CHANGELOG-*.md` (pre-S325:
`docs/archive/CHANGELOG-legacy-pre-S325.md`) carry an entry heading for
every session number cited AND that the load-bearing facts are inside
those entries (a heading alone proves little); (2) confirm every cited
Learning / doc path resolves and every issue state via `gh issue view`,
not prose; (3) extract any buried open thread as its own item first; (4)
replace whole line ranges mechanically (Learning 537: a partial
`old_string` leaves later paragraphs duplicated beside the new bullet);
(5) cut only finished-work narrative, and leave what is still open in an
item as written; (6) re-read the compressed result end to end.

**Take the methodology files the S1032 sync held back (BLOCKED – on a
fix to `close_out_report.py` in the methodology repo, Effort S once it
ships)** (found S1032, 2026-10-22) – the sync copied 7 of 10 files and,
at the owner’s word, held back `SESSION_RUNNER.md`, `SAFEGUARDS.md` and
the new `close_out_report.py`. The newest runner (commit `8f63492b`)
makes section 3G print that script’s output as the last message; v1.2.0
reads the example box in `HANDOFFS.md`’s front matter as the newest
receipt and refuses, here and on the blank seed (the fork’s copy still
did on S1108’s test). The runner’s Oct 12 commit `95005e87` is held with
it. Evidence, a tested 4-line fix and the draft upstream report, **not
posted anywhere** (where to post it is the owner’s call):
`docs/audits/CLOSE_OUT_REPORT_EXAMPLE_BOX_2026-10-22.md`. **What is
left:** when the script reads this ledger, sync again
(`bin/sync --force`, then the trimmer patch per
`docs/conventions/CLOSEOUT_CHECKLISTS.md`) and, before keeping the
script, print a report from a ledger whose newest receipt is complete.

**Draw the full colony beyond the Diagram tab’s cap (issue \#138, low
priority; READY – the pickup is a scoping session, not a build; Effort M
for that session)** – the tab draws at most 750 animals (400 with
Rectilinear edges), about 1,500 drawn nodes (`R/modPedigree.R:453,465`;
the issue’s title still says “1,500-node cap”). Its source audit
(`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`,
Finding \#7) advised no action; the issue says a real need warrants a
design session (for example a colony summary view), not a higher cap.

**Two test files error instead of skipping when Chrome or Quarto is
missing** (found S1103; READY once CRAN plan Phase 10 has run, CRAN
having accepted 3.0.0; Effort S) – with `NOT_CRAN=true` on a machine
that has neither, such as CRAN’s arm64 image:
`test_positionMatingUnitForest.R:2012,2589,2627` stop with “Invalid path
to Chrome” (their guards check for the `chromote` package, not a
browser), and all four `test_pkgdown_reference_config.R` blocks stop
because
[`pkgdown::as_pkgdown()`](https://pkgdown.r-lib.org/reference/as_pkgdown.html)
needs the `quarto` package for the `.qmd` articles. A CRAN check skips
both files (`tests/testthat/slowTestFiles.txt`). Add a skip for the
missing tool in each.

**Take the finished tutorial’s pin out of `test_docsAuditSixRulings.R`**
(found S1110; READY once CRAN plan Phase 10 has run, CRAN having
accepted 3.0.0; Effort S) – SR3
(`tests/testthat/test_docsAuditSixRulings.R:92` area) requires each open
item’s phrase once in this file, and one of them is the item S1110
finished: Create a tutorial for prospective contributors. This item
holds that phrase, so the test stays green until then. Remove it from
SR3’s list and this item together.

## Outreach

**NPRC outreach & announcement plan** (DECISION NEEDED – CRAN listed
3.0.0 on 2026-11-01; owner review/edit of drafts + send timing; Effort
N/A, not a coding task) – plan complete, with ready-to-edit drafts:
`docs/planning/nprc-outreach-announcement-plan.md` (S413; text moved to
3.0.0 S1112, drafts at Appendices A and A2, “fine for now”, not signed
off). **At send time:** fill the CRAN date, check the drafts against the
version CRAN published, and re-check the contact list, still as of
2026-07-28 (owner’s ruling S1112). The emails could also ask whether
each center uses the package, which the papers need
(`docs/planning/journal-papers-scoping.md` section 5; plan not changed).
Two items remain genuinely unresolved after dedicated research, not just
undone: the Working Group’s current (2026) chair could not be confirmed
(recommended action: ask `support@nhprc.org` directly, see the plan’s
§3/§8); and a colony-manager contact could not be named at 3 of 7
centers (Southwest, Tulane, Washington – the role is undocumented by
name on each center’s own site). **Next steps are owner-executed,
real-world actions** (review/edit the drafts, confirm exact recipients,
send) per the plan’s own §7 – pick this up in a future session only if
the owner wants help drafting a specific follow-up, not as a general
“send the emails” coding task.

**Develop paper(s) for peer-reviewed journals** (owner-requested
2026-09-26; scoping DONE S1113; BLOCKED – on Mark finding out whether
any center uses the package; Effort L, multi-session) –
`docs/planning/journal-papers-scoping.md` holds the rulings, the journal
rules as read and the next steps. Mark ruled: the software paper first,
in *The R Journal*; Mark drafts, Claude helps; no co-author named so
far, of the four other package authors. Open before any draft: evidence
of use (its section 5), *The R Journal*’s AI and fee position, and a
comparator scan (one Claude session, section 6). An applied colony paper
and a retrospective are later and optional. The tiered journal names
never arrived; section 7 lists inferences. Also, the documentation audit
is finished (S1027, `CHANGELOG.md`), so the papers’ figures match the
software.
