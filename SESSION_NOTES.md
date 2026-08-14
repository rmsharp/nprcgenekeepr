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

### What Session 559 Did
**Deliverable:** Archive `SESSION_NOTES.md` (past the 2,000-line agent read cap, dashboard HIGH
risk, unresolved since S555) via `methodology_trim.py`; also check `HANDOFFS.md`'s own MEDIUM
archive-trigger risk in the same pass. (IN PROGRESS)
**Started:** 2026-08-13.
**Status:** Session claimed. Work beginning.
**Ledger:** `CHANGELOG: pending` — set at claim; this session's actions are recorded in
`CHANGELOG.md` at Phase 3F. Until close-out, this line is the crash breadcrumb for the next
session's reconcile.

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

