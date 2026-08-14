# Session Notes

**Purpose:** Continuity between sessions. Each session reads this first and writes to it before closing out.

**Archived 612 record(s), 1998-12-06 → 2026-08-12** into [`docs/archive/SESSION_NOTES-through-2026-08-12.md`](docs/archive/SESSION_NOTES-through-2026-08-12.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 40 record(s), 2026-08-11 → 2026-08-13** into [`docs/archive/SESSION_NOTES-through-2026-08-13.md`](docs/archive/SESSION_NOTES-through-2026-08-13.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

---

## ACTIVE TASK

### Session 562 Handoff Evaluation (by Session 563)
**Score: 7/10.** **What helped:** `next_steps` named this exact item verbatim as the
recommended first pickup ("Track C recommended first -- smallest, no open design
question... `R/makePedigreeDiagramData.R`'s `.addRectilinearWaypoints()` D2 loop"),
and `key_files` pointed directly at `R/makePedigreeDiagramData.R:1489-1531` -- exactly
the right code, saving real location-finding time. The "no open design question"
characterization was accurate and held throughout (§5.2 was correct: the fix mirrors
an existing precedent, issue #137 D10, with no genuine judgment call). **What was
wrong:** two claims did not hold up. (1) "fixture already built" -- S562 inherited
`BACKLOG.md`'s own S555-era wording without independently verifying it; the actual
12-row fixture was never committed as code, only described in prose
(`PROJECT_LEARNINGS.md` Learning 561), and had to be reconstructed from scratch this
session (Learning 569). (2) "~2-line fix" undersold the real diff: `do.call(rbind,
newEdgeList)`'s column-alignment requirement (D1 sibship-bar edges share the same
list, with no color/width columns of their own) forced a 2-part fix (an in-loop
lookup plus a post-hoc override after the existing blanket-fallback assignment), not
a simple in-place edit -- neither S562 nor the plan's own §5.3 flagged this structural
constraint. **What was missing:** no warning about the `newEdgeList`/`do.call(rbind)`
shared-list constraint between D1 and D2 edges -- would have saved a few minutes of
design-space exploration before landing on the post-hoc-override approach.
**ROI:** Net positive -- the accurate file/line pointer and correct "no design
decision" framing outweighed the 2 inaccuracies, which were caught quickly via direct
empirical verification (Pre-RED) rather than costing a wasted implementation attempt.

### What Session 563 Did
**Deliverable:** Implement Track C of the ratified kinship2 supplement
full-reproduction plan (`docs/planning/kinship2-supplement-full-reproduction-plan.md`
§5) -- finish `edgeStyle="rectilinear"` consanguineous-marker color/width propagation
onto D2 dogleg-rerouted projection edges in `R/makePedigreeDiagramData.R`'s
`.addRectilinearWaypoints()`. **DONE.** **Started/Completed:** 2026-08-13. **Status:**
DONE. TDD phase: REFACTOR skipped by owner choice (diff already minimal, no structural
improvement identified) -- full PRE-RED -> RED -> GREEN cycle completed, each
transition gated by `AskUserQuestion` per `CLAUDE.md`'s Development Process Contract
override.

**What happened, in order:** **(1)** Phase 0 orient in full (`SESSION_RUNNER.md`,
`SAFEGUARDS.md`, `SESSION_NOTES.md`, `gh issue list`, `git status`/`log`/`diff --stat`
[50 commits ahead of `origin/master`, unpushed, unchanged pattern since S548],
`methodology_dashboard.py` [Health 96/100, 0 High+ risk], `gh run list --branch
master --limit 10` [push-triggered workflows green on last-pushed commit; scheduled
`shinytest2.yaml` still red, unchanged since S548, not diagnosed -- report, don't
fix], ledger reconcile [`CHANGELOG.md` frontier == `HEAD`; `HANDOFFS.md` frontier one
commit behind `HEAD`, but that commit only documents a known self-reference
limitation already resolved -- no backfill needed]). Found and reported a stale
`BACKLOG.md` tag (the "ledger-size housekeeping" item's header still said
`READY, Effort L` though its body stated `fully RESOLVED` since S531) -- excluded from
the priorities picker, flagged for future cleanup. Rendered the priorities list (4
tagged/surfaced items, including issue #148 surfaced via the ratified sequencing-audit
prose per `CLAUDE.md`'s own check) via `AskUserQuestion` -- user picked the kinship2
reproduction plan, Track C. **(2)** Read the plan's §5 (Track C) in full; stated
understanding back to the user. **(3)** Phase 1B: wrote the claim stub to
`SESSION_NOTES.md`/`HANDOFFS.md` (`status: pending`) plus a `CHANGELOG.md` claim
entry, committed (`91c78152`). **(4)** PRE-RED: confirmed the exact gap
(`R/makePedigreeDiagramData.R`'s D2 dogleg loop, ~line 1523, builds new projection
edges without color/width, falling to the generic `#2B7CE9`/`NA` stamp later);
confirmed no design decision needed (mirrors the KEPT-edges precedent, issue #137
D10); confirmed the test home (`tests/testthat/test_makePedigreeMatingLayout.R`,
extending the existing "Finding #2" block). Discovered the plan's referenced "12-row
fixture" was never committed as code -- read `.buildMatingUnitForest()`'s anchor-
selection algorithm directly from source (not hand-traced) and constructed an
independently-verified 9-row equivalent on the first attempt (Learning 569), verified
live via `Rscript` before writing any test code. Gated PRE-RED->RED via
`AskUserQuestion`. **(5)** RED: added 1 new `test_that()` block (5 assertions) to
`tests/testthat/test_makePedigreeMatingLayout.R`; confirmed all 4 substantive
assertions fail for the right reason against unmodified source (color/width mismatch,
not a missing-column vacuous-pass per Learning 560's own trap). **(6)** Gated RED->
GREEN via `AskUserQuestion`. Implemented the fix: a `projColor`/`projWidth` lookup
recorded during the D2 loop (keyed by each dogleg's `projId`), applied as a post-hoc
override after the existing blanket color/width fallback assignment (required by
`do.call(rbind, newEdgeList)`'s column-alignment constraint across D1/D2 edge types --
not anticipated by the plan). **(7)** Verified: targeted test file (all pass); sibling
`test_addRectilinearWaypoints.R` (all pass, no regression); full clean regression (1
pre-existing failure, `test_wordlist_coverage.R`, confirmed via `git stash` to fail
identically on unmodified source -- unrelated 2-word spelling gap already present
project-wide); `lintr::lint_package()` on touched files (0 lints); `devtools::check()`
(0 errors, 1 warning + 1 note, both confirmed pre-existing/unrelated -- the untracked
"Compounding Loop" clutter files' non-portable names, and a pre-existing
`vignettes/figure/` knitr leftover). **(8)** Gated GREEN->REFACTOR via
`AskUserQuestion` -- owner chose to skip (diff already minimal). **(9)** Close-out:
annotated `BACKLOG.md`'s S555 deferred-follow-up item `FIXED S563` with full
verification summary; annotated the kinship2 plan's Track C clause `DONE S563`,
noting Tracks A/B remain open; added a `NEWS.Rmd` entry; reviewed the tutorial-article
checklist (`vignettes/articles/pedigree-diagram.qmd`'s "Consanguineous mating marker"
section already claims "applies under both edge styles" -- now fully accurate as a
result of this fix, no edit needed); logged `PROJECT_LEARNINGS.md` Learning 569 (the
anchor-selection-algorithm-read-directly-from-source technique); refreshed
`CLAUDE.md`'s learnings-count pointer.

**Close-out checklist mapping** (`CLAUDE.md`): citation checklist N/A (a rendering-
correctness fix to an existing display, not a new displayed statistic); tutorial/
article checklist reviewed, no edit needed (see above); `NEWS.Rmd` entry checklist
DONE; `a2interactive.Rmd` checklist N/A (`makePedigreeMatingLayout()`'s own signature
is unchanged -- no new parameter, Shiny-UI-only rendering fix); GitHub issue
close-out N/A (Track C, like all 3 tracks, has no GitHub issue yet -- plan's own §7
recommends filing 3, not filed by this session, matching the established
"recommend, don't unilaterally file" precedent); lint checklist DONE (0 lints);
`_pkgdown.yml` reference-coverage checklist N/A (no new exported function, no
signature change to an existing one).

**Self-assessment (Session 563): 9/10.** **Strengths:** (1) Did not trust the
inherited "fixture already built" claim at face value -- searched for the actual
fixture code, found it was never committed, and read the underlying algorithm
directly from source rather than re-attempting S555's own trial-and-error approach
(Learning 561) or fabricating a plausible-looking fixture that might not actually
trigger the target code path. The constructed 9-row fixture worked correctly on the
first empirical verification. (2) Followed the RED-phase vacuous-pass-trap discipline
(Learnings 560/562) throughout -- every new assertion used `expect_equal()` against a
concrete expected value, never `all(x==y)`/`expect_true(all(is.na(...)))`. (3) Caught
a structural constraint the plan itself did not anticipate (the `do.call(rbind,
newEdgeList)` column-alignment requirement forcing a 2-part fix) by reading the full
surrounding function before editing, rather than attempting the naive "just add
color/width to the D2 data.frame" edit and discovering the `rbind()` failure only at
test time. (4) Ran the full `devtools::check()` (not just targeted/regression tests)
and positively confirmed, via `git stash`, that both findings it surfaced (1 warning,
1 note) pre-date this session's diff -- rather than assuming pre-existing status
without checking. (5) Followed every TDD phase-gate via `AskUserQuestion` exactly as
`CLAUDE.md` requires, with each option spelling out concrete next-phase actions.
**Weaknesses:** (1) The background `devtools::check()` run initially double-
backgrounded (an `&`-suffixed command inside a `run_in_background: true` Bash call),
causing a premature "completed" task notification while the actual R process kept
running detached -- required manual `ps`-based polling and 2 `Monitor` calls to
recover a reliable completion signal; a cleaner approach would have used
`run_in_background: true` alone, without the internal `&`. (2) No independent
adversarial-verification pass beyond this session's own direct test/check output --
same standing gap flagged across many prior sessions, low risk here given the small,
mechanically-forced diff and full green verification, but still unaudited by a second
reader/agent. (3) Did not file a GitHub issue for Track C (or the other 2 tracks),
matching precedent but leaving all 3 tracks still untracked outside `BACKLOG.md`/the
plan document. (4) Did not push the now 53+ local commits to `origin` -- left for the
owner/a future session, matching the repeatedly-deferred precedent from S548 onward.
**Ledger:** recorded in `CHANGELOG.md` (this session's reconcile, claim, deliverable,
and close-out entries).

### Session 561 Handoff Evaluation (by Session 562)
**Score: 9/10.** **What helped:** the `next_steps` field named this exact item
verbatim as item (1) of its priority list -- "Fix `edgeStyle=\"rectilinear\"`
consanguineous-marker color/width propagation on dogleg-rerouted edges (found S555 --
a verified 12-row reproduction fixture already exists; S560's own handoff called this
\"READY, Effort S\" but `BACKLOG.md`'s own inline text for the item carries no
matching tag -- add the tag when picking..." -- which became, almost verbatim, Track C
of this session's own plan (`docs/planning/kinship2-supplement-full-reproduction-
plan.md` §5), including independently re-confirming S560/S561's own "READY, Effort S"
characterization via this session's own direct code read (§5.2: "no design decision
needed, mechanically forced by the existing precedent"). `key_files`/`gotchas` were
scoped entirely to S561's own receipt-count-sentence work and had no way to anticipate
this session's actual pivot (an owner directive broadening scope mid-session from
"tag one item" to "plan a full 3-track reproduction") -- not a real gap, since S561
could not have predicted an owner-directed scope expansion that hadn't been asked for
yet. **What was wrong:** nothing found inaccurate. **What was missing:** n/a, see
above. **ROI:** High -- even though this session's actual deliverable grew far beyond
what S561's handoff anticipated, the one concrete pointer it did give (the
`edgeStyle="rectilinear"` gap, its exact file/line evidence, and its own verified
12-row fixture) was directly reusable as Track C's entire evidence section with zero
re-derivation.

### What Session 562 Did
**Deliverable:** Write a plan document,
`docs/planning/kinship2-supplement-full-reproduction-plan.md`, to fully reproduce
`inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf`'s (kinship2's own
supplementary material) results with `nprcgenekeepr` -- **DONE, RATIFIED.**
**Started/Completed:** 2026-08-13. **Status:** DONE. TDD phase: N/A (planning/design
document, no test or production code -- matches the S550 precedent for the
twin-kinship design session).

**Scope arc (owner-directed, mid-session, twice):** the session opened as a
continuation of a prior-turn Q&A about where `docs/audits/
KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md`'s (S549) results live. The
next instruction ("use the gap analysis to develop backlog items") was read as
formalizing/tagging that audit's one remaining open finding (Track C below) --
confirmed via `AskUserQuestion`, Phase 1B prep begun. A then-genuinely-accidental
mid-turn interruption (the user was only fixing a typo in an aside, not redirecting)
was initially misread as a scope correction, triggering an unneeded full re-scope
round; the user then clarified both points separately, and -- critically -- confirmed
the REAL goal all along was broader: literal reproduction of the PDF's results,
including 2 capabilities (X-chromosome kinship, a `pedigree.shrink()` equivalent) the
S549 audit had explicitly judged "no action, capability-fit." No work was lost at
either pivot -- nothing had been committed past the claim-stub stage yet. Logged as
`PROJECT_LEARNINGS.md` Learning 568.

**What happened, in order:** **(1)** Phase 0 orient in full (`SESSION_RUNNER.md`,
`SAFEGUARDS.md`, `SESSION_NOTES.md`, `gh issue list`, `git status`/`log`/`diff --stat`
[46 commits ahead of `origin/master`, unpushed, unchanged pattern since S548],
`methodology_dashboard.py` [Health 96/100, 0 High+ risk], `gh run list --branch
master --limit 10` [all push-triggered workflows green on latest pushed commit;
scheduled `shinytest2.yaml` still red, unchanged since S548, not diagnosed this
session -- report, don't fix], ledger reconcile [`CHANGELOG.md`/`HANDOFFS.md`
frontiers both == `HEAD`, zero-commit gap]). 6 untracked files individually checked
(not just by directory/extension): the kinship2 supplement PDF + its own
`docs/planning/*.html` sibling trace to S549's already-committed audit, not a ghost
session; the 4 "Compounding Loop" files remain the same untriaged clutter flagged
since S555. Rendered the priorities list (2 tagged `BACKLOG.md` items: LabKey
BLOCKED, NPRC outreach DECISION NEEDED) via `AskUserQuestion` -- rejected by the user
for clarification, which redirected the session onto the S549-audit thread instead
(see scope arc above). **(2)** After the 2nd re-scope, stated understanding back to
the user and declared TDD phase N/A. **(3)** Wrote the Phase 1B claim stub to
`SESSION_NOTES.md`/`HANDOFFS.md` (`status: pending`) plus a `CHANGELOG.md` claim
entry, committed (`749d0530`). **(4)** Evidence gathering: read the S550 twin-kinship
plan (`docs/planning/twin-relations-kinship-computation-plan.md`) as the structural
precedent to follow; deparsed kinship2's own installed-namespace mechanisms directly
(not the Rd docs) for both new capabilities -- `kinship.default`'s `chrtype="x"`
branch (X-linked kinship: males inherit the mother's row only and have self-kinship
1.0, not 0.5; females use the same avg-of-parents formula as autosomal; the existing
MZ-twin `mzindex` correction applies inside the X-linked branch too, a real
interaction trap flagged in the plan) and `pedigree.shrink()`'s full 5-helper
orchestration (`bitSize`, `findUnavailable`, `findAvailNonInform`,
`findAvailAffected` [uses `runif()` for non-deterministic tie-breaks -- flagged as a
design decision, not silently ported], `pedigree.trim`). Read
`R/kinship.R` (current, post-twin-work state), `R/trimPedigree.R`,
`R/removeUninformativeFounders.R`, `R/columnSchema.R` (confirmed `affected` already
exists as an optional pedigree column, issue #133 -- reusable for the shrink-equivalent
with zero new column), `R/makeAvailable.R` (confirmed a real, unrelated "available"
naming collision with kinship2's own `avail` argument -- breeding-group candidate
pools, not genotyping status), and `R/makePedigreeDiagramData.R`'s full
`.addRectilinearWaypoints()` (found the exact 2-line gap: the D2 dogleg loop never
looks up a dropped mate edge's own color/width before building its replacement
projection edges). **(5)** Drafted the plan
(`docs/planning/kinship2-supplement-full-reproduction-plan.md`, ~600 lines): 3
independently-sliceable tracks (A: X-chromosome kinship: `kinship()` gains
`chrtype`/`sex`; B: a `shrinkPedigree()` equivalent, the most novel of the 3; C: the
rectilinear marker-propagation fix, smallest, no open design question), a scope
caveat carried forward from S549 (the full 17-subject `fam1` pedigree still isn't
reconstructible) plus a new one specific to Track B (the PDF gives no reproducible
`pedigree.shrink()` worked example at any reachable scale -- Track B verifies against
the installed `kinship2::pedigree.shrink()` directly instead, stated explicitly
rather than discovered mid-implementation), per-track evidence/design-decision/
vertical-slice/dragons sections mirroring the S550 precedent's structure,
alternatives-considered, close-out checklist mapping, and provenance. **(6)** Ratified
4 genuine judgment calls via one `AskUserQuestion` call (Track A propagation scope,
Track B naming, Track B tie-break determinism, Track B UI) -- owner selected the
plan's own recommended option in all 4 cases, no changes requested. Updated the plan's
status to RATIFIED and filled in the ratification-outcome section. **(7)** Added a
new `BACKLOG.md` Housekeeping pointer item (owner-directed follow-up to the S549
audit, tagged READY/Effort L overall with per-track S/M/L breakdown) directly below
the existing deferred rectilinear-marker item, so future Phase 0 priorities scans
surface it. **(8)** Logged `PROJECT_LEARNINGS.md` Learning 568 (the scope-arc/
mid-turn-interruption-misreading process learning) and refreshed `CLAUDE.md`'s
learnings-count pointer (568, ~2.3 MB).

**Close-out checklist mapping** (`CLAUDE.md`): citation/tutorial-article/`NEWS.Rmd`/
`a2interactive.Rmd`/GitHub-issue-close-out checklists -- all N/A (a planning document,
no R code, no new function/UI/statistic shipped, no linked GitHub issue yet -- the
plan's own §7 explicitly defers 3 of these checklists to whichever future session
implements each track); lint checklist N/A (no `.R` files touched); `_pkgdown.yml`
reference-coverage checklist N/A (no new exported function).

**Self-assessment (Session 562): 8/10.** **Strengths:** (1) Followed the S550
twin-kinship plan's own structure and evidence standard closely (deparse the
installed namespace directly, not just Rd docs; separate forced decisions from
genuine judgment calls; ratify via `AskUserQuestion` in the same session) rather than
inventing a new, untested plan-document shape. (2) Found and flagged 2 real,
non-obvious traps before they could become implementation-time surprises: the
`available`/`avail` naming collision (§6.3 of the plan) and the MZ-twin correction's
interaction with the new X-linked branch (§3.1 point 3) -- both would have been easy
to miss without directly reading the relevant existing code/deparsed namespace first.
(3) Was honest about a real evidence gap rather than papering over it: Track B's own
2 undeparsed kinship2 sub-helpers (`excludeUnavailFounders`/`excludeStrayMarryin`)
are explicitly flagged as an open Pre-RED item, not silently assumed. (4) Correctly
recovered from a genuine scope-interpretation mistake (misreading a typo-fix
interruption as a scope correction) by asking rather than guessing, and did not let
the correction cost any committed work.
**Weaknesses:** (1) The mid-session re-scope churn (3 `AskUserQuestion` rounds before
settling on the final task) cost real turns and could have been partially avoided by
asking one broader clarifying question earlier, before assuming "use the gap analysis
to develop backlog items" meant only the narrow tagging task. (2) No independent
adversarial-verification pass on the plan's own technical claims (the X-linked/MZ-twin
interaction argument, the `pedigree.shrink()` algorithm transcription) -- flagged
explicitly in the plan's own §8 Provenance rather than silently omitted, matching the
S550 precedent's own disclosed limitation, but still an unaudited gap. (3) Did not
file GitHub issues for any of the 3 tracks (left as a follow-up per the plan's own §7
recommendation, matching the established "recommend, don't unilaterally file"
precedent -- not necessarily a defect, but worth naming). (4) Did not push the now
47+ local commits to `origin` -- left for the owner/a future session, matching the
repeatedly-deferred precedent from S548 onward.
**Ledger:** recorded in `CHANGELOG.md` (this session's reconcile, claim, deliverable,
and close-out entries).

### Session 560 Handoff Evaluation (by Session 561)
**Score: 9/10.** **What helped:** the `next_steps` field named this exact item verbatim as
item 2 of its priority list -- "(2) Decide add-vs-remove for HANDOFFS.md's
FRONTMATTER_FIELD_ABSENT finding (DECISION NEEDED, Effort S, first seen S508)" -- matching
this session's own independently-rendered `AskUserQuestion` priorities list (built fresh from
`BACKLOG.md`'s own tags, per Phase 0 step 7, not copied from the handoff), which surfaced the
same 3 tagged items (this one, LabKey BLOCKED, NPRC DECISION NEEDED) with zero re-derivation
needed. `key_files` and the rest of `next_steps` (unchanged BLOCKED/DECISION NEEDED items, the
still-red scheduled `shinytest2.yaml`, the 44+ unpushed local commits) all cross-checked clean
against this session's own independent Phase 0 findings. **What was wrong:** nothing found
inaccurate. **What was missing:** `gotchas` were scoped entirely to S560's own
screenshot-legibility findings and had no way to anticipate this session's actual pitfall (a
tool-behavior claim carried in `BACKLOG.md` prose since S508 -- "every `--check`/`--write` run
... prints" the finding -- turned out to be inaccurate for the current `methodology_trim.py`
version; see this session's own Learning 567) -- not a real gap, since S560 never touched
`methodology_trim.py`. One minor inconsistency worth flagging forward: `next_steps` item (1)
(the `edgeStyle="rectilinear"` consanguineous-marker color-propagation fix) characterizes it as
"(READY, Effort S)", but `BACKLOG.md`'s own inline text for that item (the "Deferred follow-up"
paragraph under the consanguineous-marker entry) carries no matching inline tag -- so this
session's own tag-only `AskUserQuestion` priorities render correctly omitted it, even though
S560's handoff (correctly, per its own investigation) knew it was ready. A future session
adding that inline tag would close the gap between the handoff's characterization and what the
tag-scan actually sees. **ROI:** High -- the `next_steps` pointer named the exact item, its
exact tag/effort, and its own found-session, leaving zero time spent re-establishing what
needed deciding; this session's own time went entirely into implementing the decision and
verifying a tool-behavior claim the original finding had gotten wrong.

### What Session 561 Did
**Deliverable:** Resolve `HANDOFFS.md`'s recurring `FRONTMATTER_FIELD_ABSENT` finding
(`BACKLOG.md` Housekeeping, found S508, re-surfaced S559) -- add a self-updating "This file
currently holds **N** receipt(s)" sentence to `HANDOFFS.md`'s front matter (owner-picked via
`AskUserQuestion`, over removing the `regenerated` config entry from `methodology_trim.py`).
**DONE.** **Started/Completed:** 2026-08-13. **Status:** DONE. TDD phase: N/A (declared at
claim) -- methodology/ledger housekeeping, no R package code or `testthat` tests involved
(`methodology_trim.py` has no Python test suite in this repo; it's a canonical-overlay tool),
matching the established precedent for prior ledger-housekeeping sessions (S508, S559, S560).

**What happened, in order:** **(1)** Phase 0 orient in full (`SESSION_RUNNER.md`,
`SAFEGUARDS.md`, `SESSION_NOTES.md`, `gh issue list`, `git status`/`log`/`diff --stat`,
`methodology_dashboard.py` [Health 96/100, 0 High+ risk, 2 MEDIUM -- the pre-existing
`.Rproj.user` vendor-JS file, not a project concern; `HANDOFFS.md` at 11 records of headroom
before its next archive-rate trigger], `gh run list --branch master --limit 10` [all
push-triggered workflows green on the last-pushed commit, ~S544/S545 vintage -- nothing has
run against the 44 unpushed local commits yet, expected; scheduled `shinytest2.yaml` still
red, unchanged since S548, still undiagnosed], ledger reconcile [`CHANGELOG.md`/`HANDOFFS.md`
frontiers both == `HEAD` (`2b3e8ef6`), zero-commit gap, no backfill needed]). 6 untracked files
found -- verified individually (not just by directory/extension, per the ghost-session-check
discipline): the kinship2 supplement PDF and its own `docs/planning/*.html` Quarto-render
sibling are both already-documented/tracked-by-`.qmd`-source known clutter (unresolved
git-tracking decision since S545); the 4 "Compounding Loop" files (a browser-saved article +
its lock-file byproduct) were first flagged S555, still untriaged -- none read as an
undocumented deliverable, so no new ghost-session finding. Rendered the priorities list (3
tagged items from `BACKLOG.md`: this one, LabKey BLOCKED, NPRC outreach DECISION NEEDED) via
`AskUserQuestion` -- user picked the `HANDOFFS.md` field decision. **(2)** A 2nd
`AskUserQuestion` resolved the item's own pre-recorded scope decision (add the front-matter
sentence vs. remove the `regenerated` config entry) -- user picked "add the sentence."
**(3)** Wrote the Phase 1B claim stub to `SESSION_NOTES.md` and `HANDOFFS.md`
(`status: pending`) plus a `CHANGELOG.md` claim entry, committed (`e2d051fe`). **(4)** Declared
TDD phase N/A, stated understanding back to the user. **(5)** Read `methodology_trim.py`'s
`LEDGERS["HANDOFFS.md"]` config (the `regenerated` tuple's regex,
`(This file currently holds \*\*)(\d+)(\*\*)`) and `HANDOFFS.md`'s own "Size, and when to
archive" section (the existing pointer-block convention its sibling ledgers already follow) to
match wording/placement exactly. Added "This file currently holds **N** receipt(s). Computed
by `methodology_trim.py` on every `--check`/`--write` run, never hand-maintained." immediately
after the last "Archived N record(s)..." pointer block, before the first real `handoff` fence.
**(6)** Computed N: initially wrote 2 (the pre-claim retained count), then caught and corrected
it to 3 once the session's own Phase 1B claim stub was itself counted as a live receipt --
confirmed via the tool's own record parser (a dry-run `--cut @e2d051fe`, refused with
`CUT_OUT_OF_RANGE ... selects 0 retained records of 3`), not just recomputed by hand. **(7)**
Verified two ways, since the live archive trigger doesn't fire this session (20-record
headroom): a direct unit-check importing `methodology_trim`'s own compiled regex against the
new sentence (matches, extracts the correct old value); a `--check` re-run confirming no new
findings. **(8)** In the process, found and corrected a stale claim: tracing
`methodology_trim.py`'s actual control flow (`--check` returns at line ~1610, before the
archive-plan-building code that calls `apply_regenerated()` at line 1707) shows the original
S508 finding's own framing -- "every `--check`/`--write` run ... prints" the warning -- is
inaccurate for the current tool version; only a real `--write` that builds an archive plan
reaches that check. Logged as `PROJECT_LEARNINGS.md` Learning 567. **(9)** Annotated the
`BACKLOG.md` item RESOLVED in place (matching the established sibling-entry convention --
`FIXED S555`/`RESOLVED S560`-style annotation, not deletion), including the corrected framing.
**(10)** Refreshed `CLAUDE.md`'s learnings-count pointer (561+ sessions, 567 learnings).

**Close-out checklist mapping** (`CLAUDE.md`): citation/tutorial-article/`NEWS.Rmd`/
`a2interactive.Rmd`/GitHub-issue-close-out checklists -- all N/A (no R code, no new
function/UI/statistic, no linked GitHub issue); lint checklist N/A (no `.R` files touched);
`_pkgdown.yml` reference-coverage checklist N/A (no new exported function).

**Self-assessment (Session 561): 9/10.** **Strengths:** (1) Did not accept the `--check`
verification path at face value -- when a dry-run couldn't reach `apply_regenerated()` under
normal conditions, traced the actual control flow rather than assuming the fix was unverifiable
or silently shipping it unverified, and found two safe verification paths that don't require a
real archive event. (2) Caught its own arithmetic mistake (N=2 vs. the correct N=3, since the
session's own claim stub is itself a live receipt) by checking against the tool's own record
count rather than trusting the first hand-computed value. (3) Recognized the original finding's
"every check/write" framing as a claim to re-verify against source, not a fact to carry
forward -- and did so, correcting `BACKLOG.md`'s own resolved-item text rather than silently
inheriting a stale characterization. (4) Kept the session narrowly scoped to the one decision +
its implementation, explicitly declining to also fix the newly-found `edgeStyle="rectilinear"`
tag gap noted above (deferred to a future session per the ghost-session/no-mid-session-fix
precedent) even though it would have been a small, tempting addition.
**Weaknesses:** (1) The first hand-written front-matter sentence (N=2) was wrong the moment it
was written, since the Phase 1B claim stub had already been added to the same file earlier in
the same session -- a predictable ordering mistake (write the claim stub, THEN count receipts,
not count-then-claim) that a stricter sequencing would have avoided outright rather than
catching after the fact. (2) No independent adversarial-verification pass beyond this session's
own direct regex/CLI checks -- the same standing gap flagged across many prior sessions,
here on a small enough diff (3 lines) that the risk is low, but still unaudited by a second
reader/agent. (3) Did not push the now 45+ local commits to `origin` -- left for the owner/a
future session, matching the repeatedly-deferred precedent from S548 onward.
**Ledger:** recorded in `CHANGELOG.md` (this session's reconcile, claim, deliverable, and
close-out entries).

### Session 559 Handoff Evaluation (by Session 560)
**Score: 9/10.** **What helped:** the `next_steps` field named this exact item verbatim as
item 1 of its priority list -- "(1) Write the dedicated Pedigree Diagram tab article (READY,
Effort M, unchanged since S544)" -- and this session's own independently-rendered
`AskUserQuestion` priorities list (built fresh from `BACKLOG.md`'s own tags, per Phase 0
step 7, not copied from the handoff) surfaced the identical item as option 1; the user's pick
matched with zero re-derivation needed. `key_files` correctly listed every ledger/doc file
S559 touched, letting this session confirm at a glance that none of them were relevant to
its own different deliverable. **What was wrong:** nothing found inaccurate -- the `commit:
pending` self-reference limitation in S559's own `HANDOFFS.md` receipt was the documented,
expected placeholder (not an error), reconciled to `abf1a984` this session's own Phase 0 step
6, matching the established S543-S559 precedent. **What was missing:** `gotchas` were scoped
entirely to `methodology_trim.py`'s chained-`--write` interaction (S559's own deliverable) and
had no way to anticipate this session's actual pitfall (a live-app screenshot of a
375-animal fixture is functionally correct but visually illegible; a specific color marker
can be geometrically occluded at every zoom level) -- not a real gap, since S559 never
touched the Diagram tab or its screenshots. **ROI:** High -- the `next_steps` pointer named
the exact deliverable, its exact BACKLOG.md tag/effort, and its own found-session, leaving
zero time spent re-establishing what needed doing; this session's own time went entirely into
the harder screenshot-legibility and article-writing work the item itself called for.

### What Session 560 Did
**Deliverable:** Write a new dedicated article, `vignettes/articles/pedigree-diagram.qmd`,
documenting the Pedigree Diagram tab's full current feature set, with freshly-captured
live-app screenshots -- **DONE.** (BACKLOG.md Housekeeping, found S544, owner-directed via
`AskUserQuestion` for both doc-location and screenshot-capture scope this session.)
**Started/Completed:** 2026-08-13. **Status:** DONE. Not a TDD-gated session (no
implementation/test code; declared N/A, matching the S559 pure-documentation precedent).

**What happened, in order:** **(1)** Phase 0 orient in full (`SESSION_RUNNER.md`,
`SAFEGUARDS.md`, `SESSION_NOTES.md`, `gh issue list`, `git status`/`log`/`diff --stat`,
`methodology_dashboard.py` [Health 96/100, 0 High+ risk, 1 pre-existing MEDIUM -- a large
vendor JS file under `.Rproj.user/`, not a project concern], `gh run list --branch master
--limit 10` [all push-triggered workflows green on latest commits; scheduled
`shinytest2.yaml` still red, unchanged since S548, not diagnosed], ledger reconcile
[`CHANGELOG.md`/`HANDOFFS.md` frontiers both at `HEAD`; one self-reference artifact found and
fixed -- S559's own `HANDOFFS.md` receipt `commit: pending` -> `abf1a984`, logged and
committed separately (`9e8b57ee`) per the one-write-Phase-0-permits rule]). 6 untracked files
found, same known/pre-existing set S555-S559 already flagged. Rendered the priorities list (3
numbered items in the `AskUserQuestion` picker) -- user picked "Pedigree Diagram article."
**(2)** A 2nd `AskUserQuestion` round resolved 2 real scope decisions before claiming: doc
location (new dedicated article, matching the established per-tab-article convention --
`age-sex-pyramid.qmd`/`genetic-value-analysis.qmd`/`breeding-group-formation.qmd` -- over
expanding `colony-manager-guide.qmd` in place) and screenshot capture (yes, via `shinytest2`,
over text/code-only). **(3)** Wrote the Phase 1B claim stub to `SESSION_NOTES.md` and
`HANDOFFS.md` (`status: pending`) plus a `CHANGELOG.md` claim entry, committed (`edae2611`).
**(4)** Stated understanding back to the user, declaring TDD phase N/A (no code/tests
planned). **(5)** Read the existing coverage first: `vignettes/manual_components/
_pedigree_browser.Rmd` (the most complete, S553-updated narrative source -- fed into the PDF/
Word manual, not pkgdown), `vignettes/articles/colony-manager-guide.qmd`'s own "Diagram view"
paragraph (found stale -- still said "one node per animal... directed sire/dam edges,"
predating the Option 2 mating-unit convention), and `vignettes/a2interactive.Rmd`'s "Pedigree
Diagram" section (the script-callable API deep dive, already thorough and current). **(6)**
Wrote `vignettes/articles/pedigree-diagram-screenshots.R`, a new `shinytest2::AppDriver`
screenshot-generation script (matching `colony-manager-guide-screenshots.R`'s own
conventions, one fresh `AppDriver` per bundled fixture rather than one shared session, since
each screenshot needs a different `obfuscated_rhesus_mhc_ped*.csv` example). First pass
(5 screenshots against the full 375-animal fixtures) was functionally correct but visually
illegible -- fixed by narrowing each fixture to a small (3-7 animal) feature-relevant
subgraph via the tab's own existing Focal Animals + Trim Pedigree controls before capturing
(a specific known consanguineous sire/dam pair found via `kinship(sire,dam) > 0` computed
directly against the raw fixture; all 3 declared twin pairs from the twin-relations fixture
at once). A 6th planned "consanguineous marker close-up" screenshot was abandoned after
direct JS/canvas-position queries confirmed the marked edge is geometrically occluded by its
own endpoint node's rendered radius at every zoom level tested (1.5x-13x) -- a real property
of the live diagram's own vis.js rendering, not a screenshot artifact -- resolved by
describing the marker honestly in prose instead of presenting a misleading close-up. **(7)**
Wrote the article (203 lines, 9 sections: Overview, Node shapes/legend, Diagram Edge Style,
Consanguineous marker, Affected-status shading, Showing names, Twin/zygosity relations,
Interacting with the diagram, Script-callable equivalent, See also), cross-linking to
`colony-manager-guide.qmd` and `a2interactive.Rmd` in both directions. Fixed 3 issues found
during a `quarto render` verification pass: `[text](@sec-x)` markdown-link-wrapped crossrefs
don't resolve (only bare `@sec-x`/`(@sec-x)` do) -- replaced all with plain prose pointers
instead, since no sibling article in this project uses quarto's numbered-crossref feature and
introducing "(Section N)" links pointing at un-numbered headings would have been an
inconsistent, confusing one-off; a fabricated companion-vignette title ("Building blocks:
interactive R workflows") that doesn't match `a2interactive.Rmd`'s real title ("Interactive
Use of nprcgenekeepr"); one line-wrap artifact from an earlier edit. **(8)** Updated
`colony-manager-guide.qmd`: fixed its own stale "one node per animal... directed sire/dam
edges" opening sentence to describe the actual mating-unit convention and `edgeStyle`
toggle, added a twin-connectors mention and a pointer to the new article, added the new
article to the Section 2 function-group table's row 2 (Pedigree Browser), and refreshed the
regenerated `pb_diagram_legend.png`'s alt text (now includes the Affected legend row).
Updated `a2interactive.Rmd`'s own existing cross-reference to point to the new dedicated
article instead of `colony-manager-guide.qmd`'s paragraph. **(9)** Verification: `quarto
render` on both `.qmd` files (clean, both build-ignored via `^vignettes/articles$` in
`.Rbuildignore` so neither touches `R CMD check`); a targeted `rmarkdown::render()` on
`a2interactive.Rmd` (the one REAL, non-ignored CRAN vignette touched) confirmed it still
knits cleanly end-to-end; `lintr::lint_package()` 0 lints (the new `.R` script lives under
`vignettes/`, which `.lintr`'s own `exclusions` list already excludes from scope). Phase 3E
runtime smoke test: N/A, stated explicitly -- no R/ package code changed, nothing to launch.
**(10)** Logged `PROJECT_LEARNINGS.md` Learning 566 (the screenshot-legibility fix + the
node-radius-occlusion geometry finding) and refreshed `CLAUDE.md`'s learnings-count pointer
(566, ~2.3 MB).

**Close-out checklist mapping** (`CLAUDE.md`): citation checklist N/A (no new statistic/
estimator); tutorial/article checklist -- this session's deliverable IS that checklist's
target; `NEWS.Rmd` checklist N/A (no new exported function/Shiny control, pure documentation);
`a2interactive.Rmd` checklist N/A (updated an existing cross-reference, not a new function/
parameter); GitHub issue close-out N/A (BACKLOG.md item, no issue number); lint checklist --
ran, 0 lints (file excluded by `.lintr` config regardless); `_pkgdown.yml` reference-coverage
checklist N/A (no new exported function, and this project has no `_pkgdown.yml` at all --
confirmed via repo-wide search).

**Self-assessment (Session 560): 9/10.** **Strengths:** (1) Read the 3 existing coverage
surfaces (`_pedigree_browser.Rmd`, `colony-manager-guide.qmd`, `a2interactive.Rmd`) before
writing anything, avoiding both duplication and contradiction with what already existed --
directly caught `colony-manager-guide.qmd`'s own stale opening sentence this way. (2) Did not
accept the first screenshot pass as "good enough" -- recognized illegibility as a real defect
against the deliverable's actual purpose (documentation a reader can see) and iterated to a
concrete fix (trim to a feature-relevant focal set) rather than shipping technically-correct-
but-useless images. (3) When the consanguineous-marker close-up genuinely could not be made
to work, verified WHY via direct JS/canvas-position queries rather than guessing or quietly
shipping a misleading image, then made the honest call to describe the limitation in prose --
matching this project's own standing "report the real state, don't fabricate" discipline.
(4) Verified render-correctness with the actual build tool (`quarto render`) rather than
trusting the markdown by eye, which caught 2 real defects (broken crossref syntax, a
fabricated vignette title) before they shipped. (5) Confirmed the actual build-ignore/lint
scope (`.Rbuildignore`, `.lintr`) rather than assuming the close-out checklists' file-touching
triggers applied, avoiding both a skipped real check (the a2interactive.Rmd render) and an
unnecessary one (a full `devtools::check()` for a change with zero R/ package-code surface).
**Weaknesses:** (1) The first screenshot pass (full 375-animal fixtures, no trimming) was a
predictable mistake in hindsight -- the same illegibility problem `a2interactive.Rmd`'s own
existing prose already explains ("too dense for a single static demonstration to usefully
show every feature at once," its stated reason for using a small synthetic pedigree instead)
was sitting in a file this session read early on, before the first capture attempt; catching
that connection sooner would have saved a full capture-and-review cycle. (2) No independent
adversarial-verification pass beyond the tool's own render checks and this session's own
manual screenshot review -- the same standing gap flagged across many consecutive prior
sessions, here even more relevant since prose-accuracy claims (e.g. exact hex colors, exact
node-cap numbers) were self-verified against source rather than checked by a second reader/
agent. (3) Did not push the now 44+ local commits to `origin` -- left for the owner/a future
session, matching the repeatedly-deferred precedent from S548 onward.
**Ledger:** recorded in `CHANGELOG.md` (this session's reconcile, claim, deliverable, and
close-out entries).

### Session 558 Handoff Evaluation (by Session 559)
**Score: 9/10.** **What helped:** the `next_steps` field named this exact item verbatim as
item 1 of its priority list -- "`SESSION_NOTES.md` is now 2,400+ lines -- past the
2,000-line agent read cap (dashboard HIGH risk, unchanged/still not in `BACKLOG.md` since
S555 first flagged it, 4 consecutive sessions now) -- a future session should scope/run an
archive pass (`methodology_trim.py --file SESSION_NOTES.md --check` first), mirroring the
`CHANGELOG.md` precedent" -- followed as the literal first and only investigative step
before running `--check`. The user picked this exact item from the rendered
`AskUserQuestion` priorities picker with zero re-derivation needed. **What was wrong:**
nothing found inaccurate in the record of S558's own work; the receipt's `commit: pending`
placeholder was the expected, documented self-reference limitation (the receipt ships in
the very commit whose sha it would name), not an error -- reconciled to `cafd7d49` this
session before archiving it, per `HANDOFFS.md`'s own stated exception allowing a `commit:`
field to be filled in inside an already-archived receipt. **What was missing:** S558's
`gotchas` were scoped entirely to its own branch-cleanup deliverable and had no way to
anticipate this session's actual pitfall (chaining multiple `methodology_trim.py --write`
calls across different ledger files without committing between them breaks the generated
`verify.sh`'s comparison against `HEAD` -- Learning 565); not a real gap, since S558 never
touched `methodology_trim.py` itself. **ROI:** High -- the `next_steps` pointer named the
exact file, the exact dashboard risk, the session-count it had gone unresolved, and the
exact command to start with, leaving zero time spent re-establishing what needed doing.

### What Session 559 Did
**Deliverable:** Archive `SESSION_NOTES.md` (past the 2,000-line agent read cap, dashboard
HIGH risk, unresolved since S555) via `methodology_trim.py`; also checked and archived
`HANDOFFS.md` (dashboard MEDIUM risk) and, once its own byte trigger fired as a direct
side effect, `CHANGELOG.md` too. **DONE, all 3 ledgers archived and verified.**
**Started/Completed:** 2026-08-13. **Status:** DONE. Not a TDD-gated session (no code/test
changes, pure ledger/documentation housekeeping).

**What happened, in order:** **(1)** Phase 0 orient in full (`SESSION_RUNNER.md`,
`SAFEGUARDS.md`, `SESSION_NOTES.md`, `gh issue list`, `git status`/`log`/`diff --stat`,
`methodology_dashboard.py` [Health 96/100, 1 High risk -- `SESSION_NOTES.md` 2,432 lines,
unresolved 4 sessions; 1 Medium -- `HANDOFFS.md` archive trigger fired, 109,202 B vs.
65,536 B budget], `gh run list --branch master --limit 10` [scheduled `shinytest2.yaml`
still red, unchanged, still not diagnosed], ledger reconcile [`CHANGELOG.md`/`HANDOFFS.md`
frontiers both at `HEAD` (`cafd7d49`), zero-commit gap, no backfill needed]). 6 untracked
files found, same known/pre-existing set S555-S558 already flagged. Rendered the
priorities list (4 numbered items in the `AskUserQuestion` picker) -- user picked "Archive
SESSION_NOTES.md." **(2)** Wrote the Phase 1B claim stub to `SESSION_NOTES.md` and
`HANDOFFS.md` (`status: pending`); also fixed S558's own `HANDOFFS.md` receipt
`commit: pending` -> `cafd7d49` (the documented reconcile exception) and logged an `[ad
hoc]` `CHANGELOG.md` claim entry ahead of the deliverable, per `PROJECT_LEARNINGS.md`
Learning 545 (`methodology_trim.py --write`'s `P1_UNDOCUMENTED` gate refuses to run while
any commit, including the session's own claim stub, sits undocumented ahead of the
ledger's frontier) -- committed (`4c7f8415`). **(3)** Stated understanding back to the
user, declaring TDD phase N/A. **(4)** Ran `--check` against `SESSION_NOTES.md` and
`HANDOFFS.md` (both fired); ran `--write` against both **without committing between
them** -- a mistake. Each `--write` appends its own self-describing entry into
`CHANGELOG.md`, so by the time `CHANGELOG.md`'s own byte trigger was checked (a direct,
foreseeable side effect of those 2 new entries) and its own `--write` run, its generated
`verify.sh` compared the shard+live split (55 records) against a stale `HEAD` (53
records, 2 behind) and FAILED L1/L3 -- not real data loss (the tool's own in-process
L1_OK/L2_OK/L3_OK checks, run against the true in-memory pre-write content, had already
passed correctly), but an invalid comparison caused by not following the tool's own
printed guidance ("one ledger, one shard, one entry, one commit, one revert"). **(5)**
Recovered by surgically unwinding just the premature `CHANGELOG.md` trim (removed its
own added entry, restored its removed tail records from `HEAD`, deleted its shard files
-- safe because insertions/deletions from independent trims land in non-overlapping
regions of the file), then re-ran all 3 trims as 3 fully separate commit-verify-protect
cycles in file order: `SESSION_NOTES.md` --write -> verify (PASS) -> commit (`8e586478`);
`HANDOFFS.md` --write -> verify (PASS) -> commit (`306a4b4d`); `CHANGELOG.md` --write ->
verify (PASS) -> commit (`ec76e487`). All 3 shards' `verify.sh` scripts now pass cleanly
against real committed `HEAD`. Final sizes: `SESSION_NOTES.md` 2,432 -> 339 lines (208,194
-> 27,604 B); `HANDOFFS.md` 4,877-equivalent -> 148 lines (109,667 -> 9,200 B);
`CHANGELOG.md` 67,414 -> 33,924 B. All 3 triggers clear. **(6)** Documented the chained-
trim/`verify.sh` interaction as `PROJECT_LEARNINGS.md` Learning 565. **(7)** Logged a new
`BACKLOG.md` Housekeeping item for `HANDOFFS.md`'s recurring, non-blocking
`FRONTMATTER_FIELD_ABSENT` finding (the declared "retained receipt count" regenerated
field has no matching front-matter sentence to update -- first seen S508, still
unresolved, needs an explicit add-vs-remove decision from a future session). **(8)**
Updated `CLAUDE.md`'s stale "Sessions 1-504+; 503 learnings" pointer to the current count
(559+; 565 learnings), a cross-reference this session's own `PROJECT_LEARNINGS.md` edit
touched.

**Close-out checklist mapping** (`CLAUDE.md`): citation/tutorial-article/`NEWS.Rmd`/
`a2interactive.Rmd`/GitHub-issue-close-out checklists -- all N/A, no code shipped, no
issue filed, no new function/parameter/statistic. Lint -- N/A, no `.R` files touched.

**Phase 3E runtime smoke test:** N/A, stated explicitly (not silently skipped) -- ledger
archiving has no runtime/Shiny behavior surface; nothing to launch or observe.

**Self-assessment (Session 559): 8/10.** **Strengths:** (1) Ran `--check` before every
`--write`, and verified losslessness via each shard's own generated `verify.sh` before
every commit -- caught the chained-trim defect itself rather than committing broken state
and finding out later. (2) When the defect was found, recovered via a precise, minimal
surgical unwind (removing exactly the erroneous trim's own top-inserted entry and bottom-
removed tail, both non-overlapping with the other 2 valid trims' pending edits) rather
than a blanket revert that would have discarded good work. (3) Extended scope to
`CHANGELOG.md`'s own trigger only because this session's own actions caused it to fire --
avoided leaving a self-inflicted red flag for the next session, without treating this as
license for unrelated scope creep. (4) Fixed the S558 receipt's stale `commit: pending`
placeholder using the documented reconcile exception before archiving it. (5) Surfaced the
pre-existing (S508-era) `HANDOFFS.md` `FRONTMATTER_FIELD_ABSENT` finding as an explicit,
trackable `BACKLOG.md` decision item instead of letting it keep recurring silently on every
future archive. (6) Documented the chained-trim gotcha as `PROJECT_LEARNINGS.md` Learning
565 so a future multi-ledger archive session doesn't repeat the mistake.
**Weaknesses:** (1) The core mistake itself -- chaining 3 `--write` calls without
committing between them despite the tool's own printed guidance saying exactly that --
was avoidable with a more careful first read of that guidance; the recovery was clean but
the mistake cost real session time. (2) No independent adversarial-verification pass
beyond the tool's own internal checks and this session's own manual diff/verify review --
the same standing gap S551-S558 have flagged across 7 consecutive sessions now, though the
risk profile here is lower than for a judgment-based code deliverable since the tool's own
L1/L2/L3 checks are themselves a form of independent verification. (3) Did not push the
now 38+ local commits to `origin` -- left for the owner/a future session rather than
assumed, matching the repeatedly-deferred precedent from S548 onward.
**Ledger:** recorded in `CHANGELOG.md` (this session's claim, 3 deliverable/trim, and
close-out entries).

### Session 557 Handoff Evaluation (by Session 558)
**Score: 9/10.** **What helped:** the `next_steps` field named this exact item (item 2 of
its priority list) with an explicit starting-point pointer -- "starting with `module`
(most recent, 2026-01-26, most likely live WIP)" -- followed as the literal first branch
investigated. `gotchas` (2) ("`git fetch --prune` is a free, zero-risk first step... run it
before any manual branch-status reasoning") was followed directly at the very start of this
session's investigation. `gotchas` (3) (a local branch mirroring its remote counterpart
should get the SAME disposition, not merely implied) was resolved this session: local
`module` was deleted together with `origin/module` in the same step, both stated explicitly.
The item's own per-branch table (ahead-count, last-commit date, PR history) let this session
skip straight to diff-content investigation instead of re-deriving the branch list from
scratch. **What was wrong:** nothing found inaccurate -- every ahead-count/last-commit-date
this session re-verified matched S557's own table exactly. **What was missing:** `gotchas`
(1) (the `--merged`/PR-history cross-check technique, Learning 563) doesn't directly apply
to any of these 5 branches (none ever had a PR opened), so this session had to develop a
different evidence technique (merge-base-position-vs-master's-own-later-history,
name-existence cross-check, deliberate-deletion check -- now Learning 564) from scratch;
not a real gap in S557's handoff, since S557 explicitly scoped its own gotchas to what it
had actually encountered, not a technique for a case it hadn't hit yet. **ROI:** High -- the
per-branch table and the "starting with `module`" pointer meant zero time spent
re-establishing which branches remained or why; all of this session's own time went into
the harder diff-content investigation the item itself called for.

### What Session 558 Did
**Deliverable:** Review the 5 remaining stale `origin` branches' actual diff content
(`module`, `issue8`, `issue8-fix`, `marks-broken-issue8`, `nprcmanager-master`) and get an
explicit owner decision (delete vs. keep) for each (`BACKLOG.md` Housekeeping, found S552,
narrowed S557) -- **DONE, all 5 deleted, item fully RESOLVED.**
**Started/Completed:** 2026-08-13. **Status:** DONE. Not a TDD-gated session (no code/test
changes, pure repository housekeeping).

**What happened, in order:** **(1)** Phase 0 orient in full (`SESSION_RUNNER.md`,
`SAFEGUARDS.md`, `SESSION_NOTES.md`, `gh issue list`, `git status`/`log`/`diff --stat`,
`methodology_dashboard.py` [Health 96/100, 1 High+ risk -- `SESSION_NOTES.md` 2,322 lines,
past the 2,000-line cap, unchanged/unlogged for 3+ consecutive sessions now; 1 MEDIUM --
`HANDOFFS.md` archive trigger fired, 102,724 B vs. 65,536 B budget, also unlogged],
`gh run list --branch master --limit 10` [scheduled `shinytest2.yaml` still red, unchanged,
still not diagnosed], ledger reconcile [`CHANGELOG.md`/`HANDOFFS.md` frontiers both at
`HEAD` (`791e69a0`), zero-commit gap, no backfill needed]). 6 untracked files found, same
known/pre-existing set S555-S557 already flagged (5 in `inst/extdata/reference/` plus
`docs/planning/pedigree-diagram-kinship2-reference-comparison.html`, confirmed this session
to be the rendered output of the *tracked* `.qmd` of the same name, not a mystery
deliverable). Rendered the priorities list (6 numbered items sourced from `BACKLOG.md`'s
own tags plus the audit-sourced issue #148 item, first 4 in the `AskUserQuestion` picker
per the 4-option cap) -- user picked "Resolve 5 stale branches." **(2)** Wrote the Phase 1B
claim stub to `SESSION_NOTES.md` and `HANDOFFS.md` (`status: pending`), committed
(`15ff56d1`). **(3)** Stated understanding back to the user, declaring TDD phase N/A (no
implementation/test code planned). **(4)** Investigated each branch: `git fetch --prune`
first, then per branch -- ahead-count/last-commit re-verification (matched S557's table
exactly), `git merge-base` against `master` plus a `git log` read of what `master`'s OWN
history did after that fork point, `comm -23` file-list diffing (`module` only, 120 unique
files), targeted `git ls-tree -r --name-only master | grep` name-existence checks for every
substantively-named unique function/file, and a `git log --diff-filter=D` check confirming
`inst/application/` (the legacy monolithic app `module` still carries) was deliberately
deleted on `master`'s own line (`feat!: Phase 9`). Findings: `module`'s merge-base is the
exact commit where master's own modularization work began, and master completed that same
effort independently and more thoroughly; `issue8`/`issue8-fix`/`marks-broken-issue8` share
one 2021-04-21 merge-base, `issue8-fix`/`marks-broken-issue8` are near-duplicates (8 files
differ), and every function name traceable from their commits already exists on `master`
today with full `man/`+`tests/testthat/` coverage; `nprcmanager-master` has no merge-base
at all with `master` (the project's literal first 8 commits, pre-rename, 2017).
**(5)** Presented the full evidence table, then gated the actual deletions behind 2
`AskUserQuestion` calls (a 4-option multiSelect for `module`/`issue8`/`issue8-fix`/
`marks-broken-issue8`, plus a single-select for `nprcmanager-master` -- split across 2
questions to respect the 4-option-per-question cap) -- owner approved all 5. **(6)**
Executed: `git branch -D module` (local), `git push origin --delete module issue8
issue8-fix marks-broken-issue8 nprcmanager-master`, re-fetched with `--prune` to confirm --
`git branch -a` now shows only `master` and `gh-pages`. **(7)** Rewrote the `BACKLOG.md`
item to a compressed resolved note (matching the file's own established convention for
fully-resolved Housekeeping items) and added `PROJECT_LEARNINGS.md` Learning 564
documenting the 3-technique evidence methodology (merge-base position vs. master's own
later history; name-existence cross-check; deliberate-deletion check) for the
no-PR-history case Learning 563 (S557) didn't cover.

**Close-out checklist mapping** (`CLAUDE.md`): citation/tutorial-article/`NEWS.Rmd`/
`a2interactive.Rmd`/GitHub-issue-close-out checklists -- all N/A, no code shipped, no issue
filed for this item, no new function/parameter/statistic. Lint -- N/A, no `.R` files
touched.

**Phase 3E runtime smoke test:** N/A, stated explicitly (not silently skipped) -- branch
deletion has no runtime/Shiny behavior surface; nothing to launch or observe.

**Self-assessment (Session 558): 9/10.** **Strengths:** (1) Did not stop at "no PR trail,
can't be established" for these 5 branches -- built a genuinely new, concrete evidence
methodology (merge-base position vs. master's own later history; name-existence
cross-check against master's current tree; deliberate-deletion check) rather than
re-presenting the same bare ahead-count table S557 already had. (2) Every recommendation
was backed by a specific, checkable fact (e.g., `module`'s merge-base commit hash and what
master did after it; exact function names found via `git ls-tree`; the `feat!: Phase 9`
deletion commit) rather than a vague "this looks old" judgment. (3) Still gated all 5
hard-to-reverse remote deletions behind explicit owner confirmation via `AskUserQuestion`
despite the strength of the evidence -- did not treat the evidence as self-authorizing.
(4) Closed the item fully (not narrowed further) -- `BACKLOG.md`'s branch-cleanup item,
open since S552, is now RESOLVED. (5) Recorded the new evidence technique as its own
`PROJECT_LEARNINGS.md` entry (564) rather than letting it live only in this session's
commit history, explicitly cross-referencing Learning 563 (S557) as the sibling technique
for the has-PR-history case.
**Weaknesses:** (1) Did not exhaustively verify every one of `module`'s 120 unique files
individually -- spot-checked ~9 of the smaller R files plus a directory-level check on the
legacy app; did not diff vignette PNG byte content or confirm every sample-data CSV has a
modern replacement (a reasonable scope boundary given the file count, but worth naming
honestly rather than implying exhaustive coverage). (2) Did not read full `git log -p`
patches for every one of `issue8`'s 103 commits -- relied on the oneline commit log plus
function-name cross-checks; a small chance remains that a genuinely orphaned fix is buried
in there undetected. (3) No independent adversarial-verification pass on the "safe to
delete" judgment beyond the owner's own sign-off -- the same standing gap S551-S557 have
now flagged unaddressed across 6 consecutive sessions for different deliverables.
**Ledger:** recorded in `CHANGELOG.md` (this session's claim, deliverable, and close-out
entries).

### Session 556 Handoff Evaluation (by Session 557)
**Score: 9/10.** **What helped:** the `next_steps` field named this exact item verbatim --
"Clean up unneeded repository branches (found S552, READY, Effort S -- check mergedness before
deleting)" -- as item 3 of its priority list, and "check mergedness before deleting" was followed
as the literal first investigative step (`git branch --merged`/`--no-merged` against
`origin/master`, `git rev-list --count` ahead/behind, `gh pr list`). **What was wrong:** nothing
found inaccurate. **What was missing:** the handoff's one-line pointer didn't carry forward S552's
own original inventory detail (which specific branches existed, that 4 were `issue103-stage*`
already superseded) -- not a real gap, since `BACKLOG.md`'s own item text (written S552, read
directly this session) already carried that detail; the `next_steps` pointer correctly didn't
duplicate it. **ROI:** High -- the one-line "check mergedness before deleting" pointer was exactly
the right-sized instruction: specific enough to start from, not so prescriptive it pre-empted this
session's own PR-history cross-check (which surfaced a real nuance -- `issue8`'s content was
merged via `dev`/other PRs, not directly, so raw `--no-merged` status alone would have
mis-classified it as straightforwardly unmerged).

### What Session 557 Did
**Deliverable:** Clean up unneeded repository branches, locally and on `origin` (`BACKLOG.md`
Housekeeping, found S552, READY, Effort S) -- **DONE for the 7 confirmed-safe branches; the 5
genuinely unmerged branches are narrowed to an explicit owner-decision item, not resolved.**
**Started/Completed:** 2026-08-13. **Status:** DONE (narrowed scope, matching the item's own
"confirm none is an active PR source" framing). Not a TDD-gated session (no code/test changes).

**What happened, in order:** **(1)** Phase 0 orient in full (`SESSION_RUNNER.md`, `SAFEGUARDS.md`,
`SESSION_NOTES.md`, `gh issue list`, `git status`/`log`/`diff --stat`, `methodology_dashboard.py`
[Health 96/100, 1 High+ risk -- `SESSION_NOTES.md` 2,238 lines, past the 2,000-line cap, still
unchanged/not in `BACKLOG.md` since S555 first flagged it; also a MEDIUM `HANDOFFS.md`
archive-trigger risk, likewise still not logged], `gh run list --branch master --limit 10`
[scheduled `shinytest2.yaml` still red, unchanged, not diagnosed], both sequencing-audit docs
re-checked per `CLAUDE.md`'s Phase 0 customization [genetic-metrics cluster's next item, issue
#148, confirmed still the right next item; pedigree-diagram cluster's Tier 1/2 items confirmed
already resolved via `gh issue list` (#133/#136/#137 no longer open), only the explicitly-deferred
Tier 3 items (#138/#141) remain]). 6 untracked files found, all pre-dating the last commit --
same set S555/S556 already flagged as known/not-a-ghost-session, reported unchanged. Ledger
reconcile: `CHANGELOG.md`/`HANDOFFS.md` frontiers both at `HEAD` (`a2e3ecb8`), zero-commit gap,
no backfill needed. Rendered the priorities list (6 numbered items from `BACKLOG.md` tags plus
the audit-sourced #148 item, first 4 in the `AskUserQuestion` picker per the 4-option cap) --
user picked "Clean up branches." **(2)** Wrote the Phase 1B claim stub to `SESSION_NOTES.md` and
`HANDOFFS.md` (`status: pending`), committed (`7597c4f2`). **(3)** Stated understanding back to
the user, declaring TDD phase N/A for this session (no implementation/test code planned -- a
repository-housekeeping deliverable, so the RED/GREEN/REFACTOR gates don't apply). **(4)**
Inventoried every non-`master` branch: `git fetch origin --prune` (cleared 4 already-deleted-
upstream refs for free: `issue103-stage5-imports/7/8a/8b`), `git branch -r --merged`/`--no-merged
origin/master`, `git rev-list --count` ahead/behind for each of the 8 remaining remote branches,
`gh pr list --state open` (0 open PRs) and `--state all` (cross-referenced `headRefName` against
every branch name to distinguish "genuinely never merged" from "content merged via a different
branch"). Confirmed `gh-pages` as the live `pkgdown.yaml` deploy target (excluded from cleanup).
Confirmed the 4 `worktree-wf_*` local branches all point at commit `d6ab24c4`, an ancestor of
`master` (zero unique commits), with no active `git worktree` referencing any of them.
**(5)** Presented the full findings table to the user, then gated the actual deletions behind an
`AskUserQuestion` (deleting a remote branch is hard to reverse) -- owner picked "delete all 7 safe
branches." **(6)** Executed: `git branch -d`/`-D` for the 6 local deletions (`dev`,
`rlabkey-version-floor`, 4x `worktree-wf_*`), `git push origin --delete` for the 3 remote
deletions (`dev`, `rlabkey-version-floor`, `or-replacement`), re-fetched with `--prune` to confirm.
Left untouched, exactly as scoped: `module`, `issue8`, `issue8-fix`, `marks-broken-issue8`,
`nprcmanager-master` (each has real unmerged commits and no PR history to lean on) and `gh-pages`
(live deploy target).

**Close-out checklist mapping** (`CLAUDE.md`): citation/tutorial-article/`NEWS.Rmd`/
`a2interactive.Rmd`/GitHub-issue-close-out checklists -- all N/A, no code shipped, no issue filed
for this item, no new function/parameter/statistic. Lint -- N/A, no `.R` files touched.

**Phase 3E runtime smoke test:** N/A, stated explicitly (not silently skipped) -- branch deletion
has no runtime/Shiny behavior surface; nothing to launch or observe.

**Self-assessment (Session 557): 8/10.** **Strengths:** (1) Never deleted anything without first
establishing mergedness AND PR-history cross-reference AND (for the remote deletions) explicit
owner sign-off -- three independent safety checks before any hard-to-reverse action, per
`SAFEGUARDS.md`'s "verify before delete" rule and the outward-facing-action confirmation norm.
(2) Caught a real nuance a naive `--no-merged` read would have missed: `issue8`'s own commits
show as unmerged directly, but its content reached `master` via intermediate PRs (#22/#25 into
`dev`), which changes how a future session should read that branch's status. (3) `git fetch
--prune` up front did real, free cleanup (4 stale refs) before any manual reasoning was needed --
worth establishing as a standing first step for any future branch-hygiene session. (4) Rewrote
the `BACKLOG.md` item to hand the next session a self-contained decision list (per-branch ahead
count, last-commit date, PR history) rather than a bare "5 branches remain" note.
**Weaknesses:** (1) Did not review the actual diff content (`git log -p origin/master..origin/
<branch>`) of any of the 5 remaining branches, so the handoff can describe *what* is unmerged
(commit counts, dates) but not *whether* it's still wanted -- left entirely to a future session
or the owner. (2) `module`'s local branch (identical to `origin/module`) was left in place
without being called out as needing the same eventual disposition as its remote counterpart --
implied but not stated as its own explicit follow-up.
**Ledger:** recorded in `CHANGELOG.md` (this session's claim, deliverable, and close-out entries).

### Session 555 Handoff Evaluation (by Session 556)
**Score: 9/10.** **What helped:** the `next_steps` field named this exact item (item 3 of the
priority list) with an explicit "check that first" pointer to the scope/live-impact question --
followed as the literal first PRE-RED step, confirming the bundled 375-individual fixture has no
dangling parents and was never affected. The `BACKLOG.md` item S555 itself wrote carried the full
root-cause diagnosis (`R/makePedigreeDiagramData.R:644`, `vapply(..., numeric(1L))`, `c()` type
promotion) and a "likely fix" (`integer(1L)` template) that turned out exactly correct on first
empirical verification -- PRE-RED investigation went straight to confirming rather than
re-deriving the diagnosis from scratch. `gotchas` (3) (empirically verify a positioning
algorithm's actual behavior rather than hand-tracing, `PROJECT_LEARNINGS.md` Learning 561) was
followed directly: patched the live source file and ran both affected test suites before
committing to a RED test plan, rather than reasoning abstractly about type propagation.
**What was wrong:** nothing found inaccurate. **What was missing:** `gotchas` (1) documented that
`all(x == y)`-style RED assertions vacuously pass against a missing column, but not that
`expect_equal()` is ALSO type-blind to double-vs-integer (a distinct blind spot) -- this session
had to discover that independently via a 2-line empirical check before it was clear the new RED
tests needed `expect_type()`, not `expect_equal()`; now documented as
`PROJECT_LEARNINGS.md` Learning 562 so a future session doesn't have to rediscover it. **ROI:**
High -- the root-cause diagnosis and likely-fix suggestion were both exactly correct, letting
PRE-RED investigation confirm rather than re-derive, and the reproduction fixture built into the
`BACKLOG.md` item description was reused directly for the new RED test.

### What Session 556 Did
**Deliverable:** Fix the dangling-parent `genOf` integer/double type-coercion bug in
`.positionMatingUnitForest()` (`BACKLOG.md` Housekeeping, found S555, READY, Effort M) --
**DONE.** A dangling parent anywhere in a pedigree silently widened `genOf` from integer to
double, which could spuriously trigger `.addRectilinearWaypoints()`'s D2 dogleg reroute on
unrelated, correctly-matched mate-line edges elsewhere in the diagram (`edgeStyle =
"rectilinear"`-only). **Started/Completed:** 2026-08-13. **Status:** DONE. TDD phase: GREEN
(REFACTOR declined via `AskUserQuestion` -- the fix is a single `vapply()` type-template change
plus an explanatory comment; nothing structurally to refactor).

**What happened, in order:** **(1)** Phase 0 orient in full (`SESSION_RUNNER.md`, `SAFEGUARDS.md`,
`SESSION_NOTES.md`, `gh issue list`, `git status`/`log`/`diff --stat`, `methodology_dashboard.py`
[Health 96/100, 1 High+ risk -- `SESSION_NOTES.md` 2,136 lines, past the 2,000-line agent read
cap, unchanged from S555's own flag, still not in `BACKLOG.md`], `gh run list --branch master
--limit 10` [scheduled `shinytest2.yaml` still red, unchanged, not diagnosed], sequencing-audit
cross-check per `CLAUDE.md`'s Phase 0 customization [genetic-metrics cluster's own next item,
issue #148, surfaced as its own numbered priority per the audit's "scope-narrowing conversation
first" recommendation; pedigree-diagram cluster's own Tier 1 items (B1-B9) confirmed already
resolved/compressed away, nothing further to surface there]). 6 untracked files found, all
timestamped ~16:32-16:39 same day -- the identical set S555 already flagged as too-recent/
not-a-ghost-session; reported unchanged, not acted on. User picked the dangling-parent bug from
the rendered `AskUserQuestion` priorities. **(2)** Wrote the Phase 1B claim stub, committed
(`f9706d81`). **(3)** PRE-RED: read `.positionMatingUnitForest()`/`.addRectilinearWaypoints()`
in full; confirmed the root cause matches S555's own `BACKLOG.md` diagnosis exactly. Empirically
reproduced the bug on a new 5-row fixture (an unrelated, already-on-row `P1xP2` union --
the existing "D2: both parents at the same gen" no-op precedent -- gets 3 spurious `__proj_`
nodes purely because a second, unrelated union elsewhere references a dangling parent).
Empirically verified the candidate fix (`numeric(1L)` -> `integer(1L)`) by patching the live
source file directly, running both affected suites (`test_positionMatingUnitForest.R` 133
assertions, `test_addRectilinearWaypoints.R` 81 assertions -- both pass unchanged), then
reverting via `git checkout --` before writing any RED tests. Discovered mid-investigation that
`expect_equal()` is type-blind to double-vs-integer (`expect_equal(0, 0L)` passes) -- meaning 3
pre-existing dangling-parent tests were already passing against the (buggy, double-typed) `gen`
column the whole time, and a new RED test using the same assertion style would be equally blind;
logged as `PROJECT_LEARNINGS.md` Learning 562. **(4)** PRE-RED->RED gate via `AskUserQuestion`:
extended 3 existing dangling-parent tests in `test_positionMatingUnitForest.R` with
`expect_type(pos$gen, "integer")`, plus 1 new end-to-end test in `test_addRectilinearWaypoints.R`
reproducing the exact spurious-dogleg symptom on the verified 5-row fixture. Confirmed RED for
real against unmodified source (not just reasoning): all 4 failed for the right reason (3x
"Actual type: double"; 1x 3 spurious `__proj_` nodes plus mate-edge replacement).
**(5)** RED->GREEN gate via `AskUserQuestion`: applied the verified fix
(`R/makePedigreeDiagramData.R:646`) plus an explanatory comment documenting the root cause and
its downstream effect. All 4 targeted tests passed; full clean regression 0 failed/0 error (no
non-baseline offenders); `devtools::document()` no-op (`@noRd`, not exported);
`devtools::check()` 0 errors/1 pre-existing warning (the untracked "Compounding Loop" files
flagged at Phase 0, unrelated to this diff)/1 pre-existing note (`vignettes/figure` leftover);
`lintr::lint_package()` 0 lints on touched files. **(6)** GREEN->REFACTOR gate via
`AskUserQuestion`: owner picked "close out as-is." **(7)** Phase 3E runtime smoke test: ran the
live E2E pedigree-module suite (`NPRC_RUN_E2E=true`) -- 15/15 passed, 0 regressions, confirming
the fix doesn't disturb the live-rendered app (the bundled fixture has no dangling parents, so
nothing new is visibly different there, which is itself the expected, correct outcome).

**Close-out checklist mapping** (`CLAUDE.md`): citation checklist (#120) -- N/A, an internal
defensive fix, not a new displayed statistic. Tutorial/article checklist -- N/A, no existing
documented prose claim needed correcting (the narrow dangling-parent + rectilinear scenario was
never described in any vignette/article). `NEWS.Rmd` -- DONE: new "Fixed:" bullet added to the
dev-version section; `NEWS.md` regenerated via `rmarkdown::render()` using the file's own default
`github_document` format (a first attempt with an explicit `md_document` override produced a
much larger, incorrect diff -- reverted and re-rendered with no override). `a2interactive.Rmd`
checklist -- N/A, no new exported function/parameter (`@noRd` internal fix only). GitHub issue
close-out -- N/A, no issue was filed for this item. Lint -- DONE, 0 lints on touched files.

**Self-assessment (Session 556): 9/10.** **Strengths:** (1) PRE-RED investigation matched S555's
own root-cause diagnosis exactly and empirically verified the exact fix (source patch, test run,
revert) BEFORE writing any RED tests, so RED->GREEN was fast and confident rather than
exploratory. (2) Discovered and documented a new test-assertion blind spot
(`expect_equal()`'s double-vs-integer type-blindness) rather than writing RED tests that would
have been just as vacuously blind as the existing suite already was -- caught via a deliberate
empirical check, not assumed. (3) Followed the established stash/rerun RED-confirmation
discipline and the prototype-patch-then-revert PRE-RED discipline (both prior-session precedents)
cleanly. (4) Minimal, surgical fix (a 6-character diff) with a thorough explanatory comment,
verified against the full clean regression AND the live E2E suite before closing out.
**Weaknesses:** (1) No independent adversarial-verification pass run on this fix -- carried
forward unaddressed from S551-S555's own flagged gap (5 consecutive sessions now). (2) Did not
investigate whether any real (non-bundled, non-synthetic) pedigree with dangling parents +
`edgeStyle = "rectilinear"` exists in practice -- the `BACKLOG.md` item's own "scope/severity not
yet established" framing was resolved only for the bundled fixture (confirmed unaffected), not
for real-world usage patterns generally.
**Ledger:** recorded in `CHANGELOG.md` (this session's claim, deliverable, and close-out entries).

### Session 554 Handoff Evaluation (by Session 555)
**Score: 9/10.** **What helped:** the `next_steps` field's priority-ordered list (consanguineous
marker item 1, article item 2) matched this session's own independently-rendered `AskUserQuestion`
priorities exactly, and the owner picked item 1 directly from it -- zero re-derivation needed.
`gotchas` (1) (the `jsonlite`-avoidance convention, with the `get_node_color()` JS-based template)
was directly reused as the exact template for this session's own new live E2E test (a `get`-style
JS query returning a plain value, no JSON parsing). `gotchas` (2) (RED is not properly confirmed
just by reasoning -- stash/rerun the implementation) was followed and caught a real, second-order
mistake this session's own tests would otherwise have hidden (3 of 6 new tests vacuously passed
against unimplemented code via R's `all(logical(0)) == TRUE` behavior -- see this session's own
`PROJECT_LEARNINGS.md` Learning 560). **What was wrong:** nothing found inaccurate. **What was
missing:** nothing material -- S554's own scope (a single-line color fix) didn't need to anticipate
a materially different feature (a new derived column on a different function). **ROI:** High -- the
`get_node_color()` JS template alone saved a full round of E2E-helper trial and error, and the
stash/rerun gotcha, followed proactively, caught a genuine RED-confirmation defect this session's
own first draft introduced.

