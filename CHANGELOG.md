# Changelog — Authoritative Action Ledger

Development / process history for the **nprcgenekeepr** project, following the
[methodology](https://github.com/rmsharp/methodology) model: `BACKLOG.md` holds open
work, **this file** holds completed history, and `ROADMAP.md` holds the feature
inventory and future plans. Per canonical v3.1+, this file is the cumulative,
append-only record of **actions taken** in this repository — the authoritative answer
to *"what was done here, ever?"* Every session records its actions here at close-out
(`SESSION_RUNNER.md` Phase 3F); Phase 0 reconciles it against `git log` and backfills
anything a crashed or out-of-band session missed. Taking an action and not recording
it is failure mode #27.

> **Note:** User-facing R-package release notes (the CRAN / pkgdown "Changelog") live in
> `NEWS.md` / `NEWS.Rmd`. This file tracks the development *process* and methodology
> history, not package releases.

## How to add an entry

At close-out, prepend one entry per action, **newest on top**, directly below this
section (above `## Legacy history` — never inside it). Key on a mechanical fact, not
judgment: *did this session author or retain any commit, or take any non-commit
action?* If yes, an entry is owed — "too small to log" is failure mode #27, not an
exception.

**Source tag — exactly one per entry**, so `grep -E '\[(issue #|BL-|ad hoc)' CHANGELOG.md`
enumerates every logged action:

- `[issue #<N>]` — a GitHub issue in this repository.
- `[BL-<N>]` — a `BACKLOG.md` item. Remove it from `BACKLOG.md` in the same commit.
- `[ad hoc]` — work with no backlog or issue origin (methodology syncs, planning/audit
  sessions, release mechanics, decline/wontfix decisions).

**Format** — the `###` header line is the required, greppable unit; detail bullets
below it (this project's established `**Deliverable:**`/verification-summary style)
are expected and encouraged:

```
### YYYY-MM-DD · [SOURCE] one-line outcome-focused summary (Session N)
- **Deliverable:** ...
```

When completing work, remove the item from `BACKLOG.md` and add an entry here.

## Size, and when to archive

Sectioning organises this file; it does not shrink it. The file grows without bound and Phase 0
reads it every session, so it also has a size discipline. **Two caps, because there are two
distinct failure modes and neither subsumes the other. Fire if either fires; stop only when both
stop conditions hold.**

| Cap | Protects against | Form | Fire when | Cut until |
|---|---|---|---|---|
| **Lines** — ~2,000, the agent `Read` truncation cap | **silent truncation**: a read past the cap returns no error and no marker, so the oldest entries simply stop existing for the reader | a **rate** | headroom < **15** entries | headroom > **30** |
| **Bytes** — a per-file budget, default **65,536 B** (64 KB) | **context tax**: every session pays for the whole file, every time | a **level with hysteresis** | `size > budget` | `size ≤ ½ × budget` |

**Run this. Do not eyeball it, and do not trust a size written here or anywhere else** — a number
in prose is stale the next time anyone prepends:

```sh
python3 methodology_trim.py --file CHANGELOG.md --check
```

`--check` evaluates both conditions, reports whether the trigger fires, and never writes. `--write`
performs the trim; a dry run is the default, and it refuses to write unless it can prove the split
lossless. **It neither commits nor stages** — it leaves the live file modified and the new shard
*untracked*, prints the rollback, and leaves the commit to you. Stage both yourself:
`git add CHANGELOG.md docs/archive/` — committing with `-a` alone would land the shortened ledger
while the shard, being untracked, never enters history at all.

**Why the line cap is a rate.** Headroom is `(2000 − lines) × entries-added ÷ lines-added` since the
last split, so it re-derives itself from the file on every read. A hand-written level cannot: it is
a derived value frozen at the moment someone typed it. This framework's own receipt ledger is the
worked example — it states its trigger as a level, *"approaches ~1,200 lines,"* and **that level has
never once fired.** The single archive that file has ever had was taken on judgment at 997 lines,
*before* the level was written; since then the file has grown several times past its byte budget
while still reading "under 1,200 lines." A level in the wrong unit says *fine* indefinitely. Where
there is no slope yet — before the first split, or immediately after one — the rate **abstains out
loud** rather than print a number it cannot support.

**Why the byte cap is not.** *"Cut until headroom is back above 30"* is unreachable on bytes at any
budget: a tool applying it would trim the file to a single record and still report the trigger
unsatisfied. A level with hysteresis terminates, and the ½ factor is what keeps the next entry from
re-firing the trigger immediately.

**The budget is judgment, and it is yours to set.** It does not follow from the line cap — at real
ledger densities, 2,000 lines is a different byte count for every file. Calibrate it the way this
default was: take the sizes your repo has actually operated at comfortably after previous archives,
and set the budget just above them. `--budget-bytes <N>` overrides it for a single run.

**Archiving again is not always the answer.** If the file has already given back everything the
last archive removed, another archive resets the *level* and not the *rate* — the tool measures
exactly that and **refuses to fire**; `--force` is how you overrule it deliberately. Before a file's
first archive there is no baseline to measure against, so it abstains rather than compute a zero.

### The shard convention

An archive is a **shard** — a new frozen file, same format, same newest-on-top order. **Note for
this file specifically:** the pre-S325 legacy history (Sessions 1-324, pre-ledger format) that used
to sit inline below a `## Legacy history` boundary marker was itself relocated into
[`docs/archive/CHANGELOG-legacy-pre-S325.md`](docs/archive/CHANGELOG-legacy-pre-S325.md) — S547,
2026-08-13, decided S546 — because the block alone (935,287 B / 3,567 lines) permanently exceeded
this file's own byte/line budgets, making the trigger unclearable by any trim of the tagged region
alone regardless of rate. It is a shard like any other (frozen, same order, no forward-looking
rule) — see that file's own header for why its name departs from the usual
`<BASENAME>-through-<CUTKEY>.md` pattern. It was created by a one-time manual relocation, not
`methodology_trim.py --write`, since the tool has no operation that moves the footer zone (only the
records zone) — verified beforehand (`classify_zones()` and `--check` against the post-relocation
content) not to break the tool's own zone classification or its byte/line trigger.

- **Path: `docs/archive/<LIVE-BASENAME>-through-<CUT-KEY>.md`.** Both halves are load-bearing. The
  directory keeps a shard from shadowing the live file by sort order, and the `CHANGELOG-` prefix is
  what the trigger's own glob looks for when it hunts its baseline — a shard named otherwise is
  silently invisible to it, and the trigger then measures against the wrong boundary.
- **The live file keeps one short pointer** naming each shard and the span it covers. Every count
  stated in that pointer carries the command that recomputes it, because a hand-maintained count
  drifts on the next prepend.
- **The shard back-links to the live file and states only facts about itself** — its own span, its
  own count. It must **not** restate a forward-looking rule. A shard is frozen, so a rule copied
  into one is wrong the moment the live rule moves, and correcting it means editing a frozen
  record. Cite the live file; do not copy it.
- **After a split the authority is the live file *and* its shards.** Any command that enumerates
  this ledger must span both by glob — `CHANGELOG.md docs/archive/CHANGELOG-*.md` — or the split
  silently shrinks the population the audit was counting.
- **Prefer a release frontier as the cut key**, because a shipped release is a boundary nothing can
  ever be written back into. A calendar date works too, but it is frozen only by convention; if you
  cut at one, say in the shard's own front matter that you departed and why.

**A trim is an action, not a side effect.** It earns its own commit and its own `[ad hoc]` entry
here — one ledger, one shard, one commit, one revert. It does **not** belong in Phase 0, which is
read-only apart from the reconcile backfill.

**Not everything that grows can be archived this way.** Archiving moves *history*. A file that grows
because someone keeps adding *procedure* has no past to move — extract a section to a sibling file
and leave a pointer instead. A backlog of open items is live state rather than history: that is a
grooming problem, and its completed items belong here, in this ledger, not in a frozen shard.

## [Unreleased]

## 2026-08

### 2026-08-13 · [ad hoc] S559: claim session (archive SESSION_NOTES.md; check HANDOFFS.md's own archive-trigger risk)
- **Deliverable:** Phase 1B claim stub only. Session 559 will run `methodology_trim.py --check`/
  `--write` against `SESSION_NOTES.md` (dashboard HIGH risk, 2,432 lines, past the 2,000-line
  agent-read cap, unresolved since S555) and check `HANDOFFS.md`'s own MEDIUM archive-trigger risk
  (109,202 B vs. 65,536 B budget) in the same pass. Logged ahead of the deliverable commit per
  `PROJECT_LEARNINGS.md` Learning 545: `methodology_trim.py --write`'s `P1_UNDOCUMENTED` gate
  refuses to run while any commit — including this session's own claim stub — sits undocumented
  ahead of this ledger's frontier.

### 2026-08-13 · [BL-N] S558 close-out: 5 remaining stale branches resolved; S557 handoff evaluation; Learning 564 logged
- **Deliverable:** Session S558's own close-out. Evaluated S557's `HANDOFFS.md` receipt (9/10 --
  its `next_steps` field named this exact item with an explicit starting-point pointer
  ("starting with `module`, most recent, most likely live WIP"), followed as the literal first
  branch investigated; `gotchas` (2) and (3) both applied/resolved directly). Self-assessment
  9/10 (built a new, concrete no-PR-history evidence methodology rather than re-presenting the
  same bare ahead-count table; every recommendation backed by a specific checkable fact; still
  gated all 5 hard-to-reverse deletions behind explicit `AskUserQuestion` confirmation despite
  the strength of the evidence; one point held back for not exhaustively verifying every one of
  `module`'s 120 unique files or every one of `issue8`'s 103 commit patches, and for the
  still-unaddressed adversarial-verification gap now 6 sessions running). `PROJECT_LEARNINGS.md`
  Learning 564 logged (merge-base-position + name-existence + deliberate-deletion evidence
  technique for the no-PR-history case). `BACKLOG.md` Housekeeping branch-cleanup item (open
  since S552) is now fully RESOLVED.
- **Commit:** this close-out's own commit.

### 2026-08-13 · [BL-N] S558: delete the 5 remaining stale repository branches (module local+remote; issue8/issue8-fix/marks-broken-issue8/nprcmanager-master remote-only)
- **Deliverable:** Reviewed the 5 branches S557 left as an owner decision (`BACKLOG.md`
  Housekeeping, found S552) via content-based evidence, not mergedness (none ever had a PR
  opened): `module`'s merge-base with `master` (`3773e63b`, 2025-12-30) is the exact commit
  where master's own modularization effort began -- master's own subsequent history
  independently completed that same effort more thoroughly, including a
  `feat!: Phase 9 -- delete the legacy monolithic Shiny application` commit `module` never got;
  of `module`'s 120 files absent from `master`, none was a substantial unique capability (the
  legacy app, superseded sample data, and ~9 small 21-110-line scratch helpers/test modules with
  modern equivalents already on `master`). `issue8`/`issue8-fix`/`marks-broken-issue8` share one
  2021-04-21 merge-base; `issue8-fix`/`marks-broken-issue8` are near-duplicates (8 files differ);
  every function name traceable from their commits (`createSimKinships`, `cumulateSimKinships`,
  `getPotentialParents`, `summarizeKinshipValues`, `countKinshipValues`, `kinshipMatrixToKValues`,
  `combinerKinshipTriangles`) already exists on `master` today with full `man/`+
  `tests/testthat/` coverage. `nprcmanager-master` has no merge-base at all with `master` --
  the project's literal first 8 commits under its pre-rename name (2017). Findings presented via
  2 `AskUserQuestion` calls (4-option cap); owner approved all 5. Deleted: `module`
  (local+remote), `issue8`/`issue8-fix`/`marks-broken-issue8`/`nprcmanager-master` (remote
  only). `git branch -a` now shows only `master` and `gh-pages` (the live `pkgdown.yaml` deploy
  target). No code/test files touched -- pure git housekeeping.
- **Commit:** this session's own deliverable commit.

### 2026-08-13 · [BL-N] S558: claim session (review 5 remaining stale branches, decide delete vs. keep)
- **Deliverable:** Session S558 claimed via Phase 1B stub (`SESSION_NOTES.md`, `HANDOFFS.md`
  `status: pending`). Task: review the 5 remaining stale `origin` branches' actual diff content
  and get an explicit owner decision (delete vs. keep) for each (`BACKLOG.md` Housekeeping,
  found S552, narrowed S557).
- **Commit:** `15ff56d1`.

### 2026-08-13 · [BL-N] S557 close-out: 7 stale branches deleted; S556 handoff evaluation
- **Deliverable:** Session S557's own close-out. Evaluated S556's `HANDOFFS.md` receipt (9/10 --
  its `next_steps` field named this exact item, "Clean up unneeded repository branches (found
  S552, READY, Effort S -- check mergedness before deleting)," and the "check mergedness before
  deleting" pointer was followed as the literal first investigative step). Self-assessment 8/10
  (thorough merge-status + PR-history cross-check before any deletion, owner confirmation
  obtained via `AskUserQuestion` before touching `origin`; one point held back for not also
  reviewing the 5 remaining branches' actual diffs against `master`, which would have let this
  session propose a disposition for at least the oldest/clearest ones rather than leaving all 5
  as a flat "needs owner review" list). `BACKLOG.md` Housekeeping item narrowed to the 5 remaining
  unmerged branches.
- **Commit:** this close-out's own commit.

### 2026-08-13 · [BL-N] S557: delete 7 confirmed-safe repository branches (3 remote+local, 4 local-only)
- **Deliverable:** Inventoried every branch beyond `master`/`gh-pages` (`BACKLOG.md` Housekeeping,
  found S552) via `git fetch --prune`, `git branch --merged`/`--no-merged` against
  `origin/master`, `git rev-list --count` ahead/behind, and `gh pr list --state open`/`--state
  all` (0 open PRs repo-wide -- none was an active PR source). `git fetch --prune` alone cleared
  4 already-deleted-upstream remote-tracking refs (`issue103-stage5-imports/7/8a/8b`, all with
  merged PRs #104-#113). Deleted as confirmed-safe (0 commits ahead of `master`, prior PR
  merged), with owner sign-off via `AskUserQuestion` before any `origin` deletion: `dev`
  (local+remote, PRs #20/21/23/24), `rlabkey-version-floor` (local+remote, PR #57),
  `or-replacement` (remote only, PR #19); plus 4 local-only `worktree-wf_*` leftovers
  (2026-08-04 workflow-tool artifacts, all 4 pointing at commit `d6ab24c4`, confirmed an
  ancestor of `master` -- zero unique commits, no active `git worktree` referenced any of
  them). Left for a future owner decision: `module`, `issue8`, `issue8-fix`,
  `marks-broken-issue8`, `nprcmanager-master` (each has real commits never merged into
  `master` and no PR was ever opened for it). `gh-pages` confirmed live (the `pkgdown.yaml`
  deploy target) and excluded from the cleanup entirely. No code/test files touched -- pure git
  housekeeping, no `devtools::check()`/regression run applicable.
- **Commit:** this session's own deliverable commit.

### 2026-08-13 · [BL-N] S557: claim session (clean up unneeded repository branches)
- **Deliverable:** Session S557 claimed via Phase 1B stub (`SESSION_NOTES.md`, `HANDOFFS.md`
  `status: pending`). Task: clean up unneeded repository branches, locally and on `origin`
  (`BACKLOG.md` Housekeeping, found S552, READY, Effort S).
- **Commit:** `7597c4f2`.

### 2026-08-13 · [BL-N] S556 close-out: dangling-parent genOf type-coercion bug fixed; S555 handoff evaluation; Learning 562 logged
- **Deliverable:** Session S556's own close-out. Evaluated S555's `HANDOFFS.md` receipt (9/10 --
  the `next_steps` field named this exact item with a "check that first" pointer to the scope
  question, followed as the literal first PRE-RED step; the root-cause diagnosis and likely-fix
  suggestion in S555's own `BACKLOG.md` write-up were both exactly correct). Self-assessment
  9/10 (strong PRE-RED-to-GREEN execution and a new documented learning; one point held back for
  the still-unaddressed adversarial-verification gap, now 5 sessions running, and for not
  investigating real-world prevalence beyond the reproduction fixture). `BACKLOG.md` Housekeeping
  item marked FIXED S556. New `PROJECT_LEARNINGS.md` Learning 562 (`expect_equal()` is type-blind
  to double-vs-integer -- a 3rd sibling of Learning 560's vacuous-pass-trap family). `NEWS.Rmd`
  gained a "Fixed:" bullet; `NEWS.md` regenerated.
- **Commit:** this close-out's own commit.

### 2026-08-13 · [BL-N] S556: fix dangling-parent genOf integer/double type-coercion bug in .positionMatingUnitForest()
- **Deliverable:** `R/makePedigreeDiagramData.R:646` -- the dangling-parent gen fallback's
  `vapply(danglingIds, ..., numeric(1L))` forced a double even though the value it returns
  (`matingUnits$gen`) was already integer; `genOf <- c(genOf, ...)` then silently widened the
  WHOLE `genOf` vector to double via R's own type-promotion rule the moment any dangling parent
  existed anywhere in the pedigree, corrupting `.addRectilinearWaypoints()`'s strict
  `identical(side$gen, Ugen)` gen-match check and spuriously firing the D2 dogleg reroute on
  unrelated, correctly-matched mate-line edges (`edgeStyle = "rectilinear"`-only; the bundled
  375-individual real fixture has no dangling parents and was never affected). Fixed:
  `numeric(1L)` -> `integer(1L)` (a 6-character diff, matching the value's actual source type).
  Empirically verified both the reproduction and the fix live (source patch + test run + revert)
  before writing any RED tests. 4 new/updated unit tests (3 `expect_type(pos$gen, "integer")`
  assertions added to existing `test_positionMatingUnitForest.R` dangling-parent tests, 1 new
  end-to-end regression test in `test_addRectilinearWaypoints.R`). `devtools::check()` 0 errors/
  1 pre-existing warning/1 pre-existing note (both unrelated); full clean regression 0 failed/0
  error; live E2E (`NPRC_RUN_E2E=true`) 15/15, 0 regressions; `lintr::lint_package()` 0 lints.
  Not filed as a GitHub issue.
- **Commit:** this session's own deliverable commit.

### 2026-08-13 · [BL-N] S556: claim session (fix dangling-parent genOf type-coercion bug)
- **Deliverable:** Session S556 claimed via Phase 1B stub (`SESSION_NOTES.md`, `HANDOFFS.md`
  `status: pending`). Task: fix the dangling-parent `genOf` integer/double type-coercion bug in
  `.positionMatingUnitForest()` (`BACKLOG.md` Housekeeping, found S555, READY, Effort M).
- **Commit:** `f9706d81`.

### 2026-08-13 · [BL-N] S555 close-out: consanguineous-mating marker shipped; S554 handoff evaluation; 2 new findings logged
- **Deliverable:** Session S555's own close-out. Evaluated S554's `HANDOFFS.md` receipt (9/10 --
  the `get_node_color()` E2E template was directly reusable verbatim; the stash/rerun RED-
  confirmation gotcha caught a real second-order defect in this session's own first-draft tests).
  Self-assessment 9/10 (one point held back for a 5-attempt fixture-construction detour before
  switching to pure empirical iteration, documented as a new `PROJECT_LEARNINGS.md` learning so
  it costs less next time). 2 new `BACKLOG.md` Housekeeping items logged from this session's own
  incidental findings: the deferred `edgeStyle = "rectilinear"` dogleg-propagation follow-up, and
  a previously-undocumented dangling-parent `genOf` integer/double type-coercion bug in
  `.positionMatingUnitForest()`/`.addRectilinearWaypoints()` (found during PRE-RED, not fixed,
  report-don't-fix precedent). 2 new `PROJECT_LEARNINGS.md` entries (560: a RED-phase
  `all(x == y)`/`all(is.na(x))` assertion vacuously passes against a not-yet-existing column;
  561: hand-tracing a multi-rule stateful algorithm is unreliable past 1-2 rules deep, verify
  empirically instead -- the same investigation that found the type-coercion bug).
- **Commit:** this close-out's own commit.

### 2026-08-13 · [BL-N] S555: consanguineous-mating visual marker, Pedigree Diagram tab (direct style)
- **Deliverable:** `makePedigreeMatingLayout()` now marks a consanguineous mating unit's
  (`kinship(sire, dam) > 0`, computed via the function's own already-validated
  `twinRelations` parameter too) 2 spouse-to-union mate-line edges with a distinct color/
  width (`"#D55E00"` Okabe-Ito vermillion, width 4) -- kinship2's own doubled/thickened
  mate-line convention (S549 Finding #2). Always on, no new UI toggle (sire/dam are
  required columns). `edges` gains `color`/`width` columns unconditionally once any mating
  unit exists. Scoped to `edgeStyle = "direct"` this session (owner-directed hold at the
  PRE-RED->RED gate) -- `"rectilinear"` propagation onto the D2 dogleg reroute is a
  deferred `BACKLOG.md` follow-up. Full strict-TDD cycle: 6 new/updated unit tests
  (`test_makePedigreeMatingLayout.R`), 1 new live E2E test (`test-e2e-pedigree-module.R`,
  56 marked edges confirmed on the bundled 375-individual fixture, 28 genuinely
  consanguineous unions x 2). `devtools::check()` 0 errors/0 warnings/1 pre-existing NOTE;
  full clean regression 0 failed/0 error; `lintr::lint_package()` 0 lints. Tutorial/article
  checklist DONE (`_pedigree_browser.Rmd`, `colony-manager-guide.qmd`); `NEWS.Rmd` DONE.
  Incidental finding, not fixed (report-don't-fix precedent): a dangling parent anywhere in
  a pedigree silently widens `.positionMatingUnitForest()`'s `genOf` from integer to
  double, which can spuriously trigger `.addRectilinearWaypoints()`'s D2 dogleg on OTHER,
  unrelated, correctly-matched mate-line edges -- logged to `BACKLOG.md` Housekeeping.
- **Commit:** this session's own deliverable commit.

### 2026-08-13 · [BL-N] S555: claim session (consanguineous-mating visual marker, Pedigree Diagram tab)
- **Deliverable:** Session S555 claimed via Phase 1B stub (`SESSION_NOTES.md`, `HANDOFFS.md`
  `status: pending`). Task: add a visual marker for consanguineous matings in the Pedigree
  Diagram tab (`BACKLOG.md` Housekeeping, found S549 Finding #2, READY, Effort S).
- **Commit:** this claim's own commit.

### 2026-08-13 · [BL-N] S554 close-out: affected-status shading defect fixed; S553 handoff evaluation
- **Deliverable:** Session S554's own close-out. Evaluated S553's `HANDOFFS.md` receipt (9/10 --
  `next_steps` priority list matched this session's own pick exactly, `gotchas`' full-regression
  discipline applied cleanly to a differently-shaped change). Self-assessment 9/10 (one point held
  back for drafting the new E2E test with an undeclared `jsonlite` dependency before checking the
  codebase's own existing anti-dependency convention, caught only by `devtools::check()`).
- **Commit:** this close-out's own commit.

### 2026-08-13 · [BL-N] S554: .affectedColor() FALSE/NA now renders open/unfilled (white), fixing the Pedigree Diagram affected-status shading defect
- **Deliverable:** `R/makePedigreeDiagramData.R`'s `.affectedColor()` (issue #133) FALSE/NA
  branch changed from `NA_character_` to `"#FFFFFF"` -- unaffected/unknown-affected individuals
  now render open/unfilled on the Pedigree Diagram tab, matching kinship2's own "unfilled if
  0/NA" convention (verified against `docs/planning/issue133-affected-status-pedigree-diagram-plan.md`
  §2.1's own kinship2-source research) rather than falling back to visNetwork's own default fill.
  A genuinely single-line core change (REFACTOR declined). 6 existing unit-test assertions
  updated across `test_makePedigreeDiagramData.R`/`test_makePedigreeMatingLayout.R`; RED properly
  confirmed by stashing the implementation and running the updated tests against unmodified
  source before reapplying. New live E2E test in `test-e2e-pedigree-module.R` (using the bundled
  `obfuscated_rhesus_mhc_ped_affected.csv` fixture) queries the rendered widget's actual node
  color for a known TRUE/FALSE/NA triple directly via JS, avoiding a `jsonlite` dependency this
  package deliberately does not carry (an initial draft using `jsonlite::fromJSON()` was caught
  and fixed by `devtools::check()`'s own "unstated dependencies in tests" guard).
  `NEWS.Rmd`/`NEWS.md` gained a "Fixed:" bullet; `BACKLOG.md` item marked DONE.
- **Verification:** `devtools::check()` 0 errors/0 warnings/1 pre-existing unrelated NOTE
  (vignettes/figure leftover); full clean regression 0 failed/0 error (2,156 test blocks);
  `lintr::lint_package()` 0 lints. Live `shinytest2`/`chromote`: the full
  `test-e2e-pedigree-module.R` suite (14 tests/49 assertions, incl. the new affected-status test
  and the pre-existing issue #137 twin-connector tests) passed with 0 regressions.
- **Commit:** this session's own deliverable commit.

### 2026-08-13 · [BL-N] S554 claim: fix the Pedigree Diagram affected-status shading defect
- **Deliverable:** Session S554 claimed. Picking up `BACKLOG.md` Housekeeping's affected-status
  shading defect (found S552, owner-reported live, READY, Effort S) -- full strict-TDD
  PRE-RED->RED->GREEN(->REFACTOR) gates apply.
- **Commit:** `402a6b5b`.

### 2026-08-13 · [BL-N] S553 close-out: Slice 3 (twinRelations full Shiny wiring) shipped, closing the item; S552 handoff evaluation, Learning 559
- **Deliverable:** Session S553's own close-out. Evaluated S552's `HANDOFFS.md` receipt (10/10 --
  every `key_files` file:line pointer accurate and directly used, `next_steps`/`gotchas` matched
  this session's own independently-derived plan point for point, Dragon 1's framing as a live
  judgment call rather than an assumed answer set up exactly the right Pre-RED investigation).
  Self-assessment 9/10 (one point held back for an avoidable `shiny::testServer()` return-value
  mistake caught only at RED, and the still-carried-forward adversarial-verification gap).
  Appended `PROJECT_LEARNINGS.md` Learning 559 (full cross-file `testthat::test_dir()` regression
  reads are necessary, not optional, when a Shiny module's return shape or a mocked dependency's
  parameter list changes -- 3 real stub/mock-drift gaps this session's own targeted 5-file run
  could not see were caught only by the full suite). Updated `BACKLOG.md`'s triggering item: all 3
  slices DONE, item fully resolved.
- **Commit:** this close-out's own commit.

### 2026-08-13 · [BL-N] S553: modPedigreeServer/appServer/modGeneticValueServer/modBreedingGroupsServer/modSummaryStatsServer gain twinRelations wiring -- Slice 3 of the ratified plan, closing the item
- **Deliverable:** Full Shiny wiring for the S550-ratified `twinRelations`-into-`kinship()` plan
  (`docs/planning/twin-relations-kinship-computation-plan.md` §4 Slice 3). `modPedigreeServer()`'s
  return list gained a `twinRelations` reactive (the raw, ungated `twinRelationsData()`);
  `R/appServer.R` gained a `shared$twinRelations` slot populated by a deliberately `req()`-free
  observer, threaded into `sharedKinshipMatrix`'s own `kinship()` call and through to
  `modGeneticValueServer`/`modBreedingGroupsServer`/`modSummaryStatsServer` (each gained a matching
  `twinRelations` parameter on its own fallback `kinship()` recompute path, mirroring the
  `kinshipOverrides` precedent's exact shape). Dragon 1 (the tab-order UX question) resolved via
  Pre-RED `AskUserQuestion`: a single upload point (Diagram tab only) -- Shiny's reactive graph
  runs every module from session start, not gated by tab visibility, so "regardless of tab visit
  order" is satisfied mechanically; resolution recorded back into the plan document's own §6
  Dragon 1 text. 13 new `test_that()` blocks across 5 files (3 new: `test_modBreedingGroups_twinRelations.R`,
  `test_modSummaryStats_twinRelations.R`, `test_modGeneticValue_twinRelations.R`; 2 extended:
  `test_modPedigree_twinRelations.R`, `test_appServer_server.R`). New live E2E test
  `test-e2e-twin-relations-cross-tab.R` verifies the literal Dragon-1 scenario end to end.
  Full clean regression (not just the targeted files) surfaced and this session fixed 3 real,
  pre-existing test-double staleness gaps in files this session's diff never touched
  (`test_appServer_logging.R`'s own local `modPedigreeServer` stub, `test_modGeneticValue.R`'s 2
  `local_mocked_bindings(reportGV = ...)` copies, `test_moduleContract.R`'s return-name whitelist)
  plus 2 mechanical additions (a new `.github/workflows/shinytest2.yaml` CI-group regex; 1
  `inst/WORDLIST` word, "ungated"). `NEWS.Rmd`/`NEWS.md` extended (one combined Slices 1-3 entry);
  `vignettes/manual_components/_pedigree_browser.Rmd` gained a paragraph on the app-wide kinship
  correction (tutorial/article checklist).
- **Verification:** `devtools::check()` 0 errors/0 warnings/1 pre-existing unrelated NOTE
  (vignettes/figure leftover); full clean regression 0 failed/0 error (2,155 test blocks, 5,568
  passed, 33 pre-existing baseline warnings); `lintr::lint_package()` 0 lints on all touched files
  (1 line-length finding fixed). Live `shinytest2`/`chromote` (`NPRC_RUN_E2E=true`): the new
  cross-tab test 3/3 assertions passed; the pre-existing `test-e2e-pedigree-module.R` suite (13
  tests/45 assertions, incl. issue #137's own twin-connector tests) re-confirmed unaffected.
- **Commit:** this session's own deliverable commit.

### 2026-08-13 · [ad hoc] S553 Phase 0 reconcile: S552's HANDOFFS.md commit self-reference
- **Deliverable:** Phase 0 ledger reconcile (`SESSION_RUNNER.md` step 6). S552's `HANDOFFS.md`
  receipt shipped with `commit: pending` -- the standard self-reference limitation (the receipt
  ships in the very commit whose sha it would name), matching the S543-S545/S549-S551 precedent
  each prior session reconciled at its own claim. `HANDOFFS.md`'s frontier (`git log -1 --
  HANDOFFS.md`) == `99796a65` (S552's own deliverable+close-out commit, bundled together that
  session), so reconciled `commit: pending` -> `99796a65`. No other undocumented commits found;
  `CHANGELOG.md`'s own frontier == `HEAD` already. `gh run list --branch master --limit 10` showed
  the scheduled `shinytest2.yaml` run still red at the E2E-tier step, unchanged from
  S548-S552's own findings -- not diagnosed this session (report, don't fix, per established
  precedent).
- **Commit:** this reconcile's own commit (`49c987c8`).

### 2026-08-13 · [BL-N] S553 claim: Slice 3 (full Shiny wiring) of the twinRelations-into-kinship() plan
- **Deliverable:** Session S553 claimed. Picking up the S550-ratified plan's own Slice 3
  (`docs/planning/twin-relations-kinship-computation-plan.md` §4) -- production code, full
  strict-TDD PRE-RED->RED->GREEN(->REFACTOR) gates apply; Pre-RED must additionally resolve Dragon
  1 (the tab-order UX question) via `AskUserQuestion` before implementation.
- **Commit:** `1fb74127`.

### 2026-08-13 · [BL-N] S552 close-out: Slice 2 (twinRelations into 4 script-callable functions) shipped, S551 handoff evaluation
- **Deliverable:** Session S552's own close-out. Evaluated S551's `HANDOFFS.md` receipt (10/10
  -- every `key_files` file:line pointer exact, both gotchas [Dragon 4 confirmed resolvable;
  `devtools::document()`-before-`check()`] directly applied, nothing inaccurate found).
  Self-assessment (9/10), handoff notes written to `SESSION_NOTES.md`/`HANDOFFS.md`. Resolved
  the plan's own open §8 item 3 question (NEWS.Rmd at Slice 2): added one combined `NEWS.Rmd`
  entry covering Slices 1-2, decision recorded back into
  `docs/planning/twin-relations-kinship-computation-plan.md`. `BACKLOG.md`'s triggering item
  updated: Slice 2 marked DONE, Slice 3 named as next. See `SESSION_NOTES.md` for the full
  record.

### 2026-08-13 · [BL-N] S552: reportGV()/gvaConvergence()/createSimKinships()/cumulateSimKinships() gain a twinRelations parameter -- Slice 2 of the ratified plan
- **Deliverable:** `R/reportGV.R`, `R/gvaConvergence.R`, `R/createSimKinships.R`,
  `R/cumulateSimKinships.R` each gained a `twinRelations = NULL` parameter, threaded straight
  through to that function's own internal `kinship()` call (plan §2.4 call sites #1-#4). 8 new
  `test_that()` blocks (2 per file: twin-propagation + backward-compatibility) added across the
  4 matching test files, reusing an extended (added `sex` column) copy of `test_kinship.R`'s own
  `fam1` 10-subject audit fixture. `reportGV()`'s tests directly assert its returned `$kinship`
  matrix against Slice 1's own ground truth; `createSimKinships()`/`cumulateSimKinships()`
  directly assert their own returned simulated/mean matrices; `gvaConvergence()`'s tests are a
  plumbing/smoke test (accepts + threads without error) since its convergence-curve output has
  no kinship-observable surface at this fixture's scale -- the same documented limitation
  `test_gvaConvergence_kinshipOverrides.R` already establishes for the analogous
  `kinshipOverrides` parameter on the identical call-site pattern. `devtools::document()`
  regenerated 4 man pages. Full strict-TDD PRE-RED->RED->GREEN cycle (each transition gated via
  `AskUserQuestion`; REFACTOR declined -- diff already minimal/mechanical). Verification:
  `devtools::check()` 0 errors/0 warnings/1 pre-existing unrelated NOTE (`vignettes/figure`,
  confirmed to predate this session); full clean regression read 0 failed/0 error;
  `lintr::lint_package()` 0 lints on all 8 touched files. TDD phase: GREEN.

### 2026-08-13 · [BL-N] S552 claim: Slice 2 (the 4 script-callable functions) of the twinRelations-into-kinship() plan
- **Deliverable:** Session S552 claimed. Picking up the S550-ratified plan's own Slice 2
  (`docs/planning/twin-relations-kinship-computation-plan.md` §4) -- production code, full
  strict-TDD PRE-RED->RED->GREEN(->REFACTOR) gates apply.

### 2026-08-13 · [ad hoc] S552: logged a new BACKLOG.md item (clean up unneeded repository branches)
- **Deliverable:** Owner-directed mid-session: inventoried (not deleted) local and `origin`
  branches beyond `master`. Local: `dev`, `module`, `rlabkey-version-floor`, 4 `worktree-wf_*`
  leftovers. Remote: `dev`, `gh-pages`, `issue103-stage5-imports`, `issue103-stage7-examples`,
  `issue103-stage8a-title-voice`, `issue103-stage8b-dedup`, `issue8`, `issue8-fix`,
  `marks-broken-issue8`, `module`, `nprcmanager-master`, `or-replacement`,
  `rlabkey-version-floor`. Documented in `BACKLOG.md` (Housekeeping, READY, Effort S) for a
  future session to check mergedness/PR-source status and decide `gh-pages` separately before
  deleting anything -- not fixed this session (unrelated to Slice 2, the actual deliverable).

### 2026-08-13 · [ad hoc] S552: logged a new BACKLOG.md item (affected-status shading fills unaffected individuals too)
- **Deliverable:** Phase 0 orientation surfaced a live owner observation ("unaffected individuals
  are still color filled ... counter to pedigree drawing convention") mid-report. Traced it to a
  concrete mechanism -- issue #133's `.affectedColor()` (`R/makePedigreeDiagramData.R:163-165`)
  sets `color.background` to `NA_character_` for `affected == FALSE`/`NA`, which visNetwork
  renders as its own default solid fill rather than an open/unfilled node. Documented as a new
  `BACKLOG.md` item (Housekeeping section, READY, Effort S) rather than fixed mid-session, since
  the owner picked a different item (Slice 2 of the `twinRelations`-into-`kinship()` plan) for
  this session's actual deliverable -- matching the established "report an incidentally-found
  gap, don't fix it mid-session" precedent (`PROJECT_LEARNINGS.md` Learning 382). Not yet filed
  as a GitHub issue.

### 2026-08-13 · [BL-N] S551 close-out: Slice 1 (kinship() twinRelations parameter) shipped, S550 handoff evaluation, Learning 558
- **Deliverable:** Session S551's own close-out. Evaluated S550's `HANDOFFS.md` receipt (9/10 --
  every claim held up against direct verification, `next_steps`/`key_files` used directly with
  zero friction, nothing inaccurate found). Self-assessment (9/10), handoff notes, and
  `PROJECT_LEARNINGS.md` Learning 558 (`devtools::check()` catches verification-surface gaps a
  targeted test run cannot; a ratified plan's own test list is a floor, not a ceiling) written
  to `SESSION_NOTES.md`/`HANDOFFS.md`. `BACKLOG.md`'s triggering item updated: Slice 1 marked
  DONE, Slice 2 named as next. See `SESSION_NOTES.md` for the full record.

### 2026-08-13 · [BL-N] S551: kinship() gains a twinRelations parameter (MZ-twin transitive-identity correction) -- Slice 1 of the ratified plan
- **Deliverable:** `R/kinship.R` gained a `twinRelations = NULL` parameter, porting kinship2's
  `mzgrp`/`mzindex` MZ-transitive-identity mechanism (plan §2.1) into the existing recursive
  depth loop, applied after each depth's individuals are processed (not a post-hoc pass on the
  finished matrix -- plan §2.2's propagation requirement). `R/applyKinshipOverrides.R`'s
  "kinship() itself is never modified" roxygen sentence updated per the ratified Dragon-2
  obligation, distinguishing a structural pedigree fact (twin identity) from an
  outside-information override. 5 new `test_that()` blocks in `tests/testthat/test_kinship.R`:
  MZ-propagation-to-a-non-twin-descendant, backward-compatibility (no `twinRelations`), a
  3-member transitive-group (union-find), DZ/UZ-coded zero-treatment, and a
  `sparse = TRUE`/`FALSE` equivalence pin (a real gap in the plan's own §4 test list, caught via
  a post-GREEN self-check and closed before close-out). `man/kinship.Rd` and
  `man/applyKinshipOverrides.Rd` regenerated via `devtools::document()`; `inst/WORDLIST` gained
  "validator's" -- both fixing gaps `devtools::check()` surfaced that the targeted test file
  alone did not. Full strict-TDD PRE-RED->RED->GREEN cycle (each transition gated via
  `AskUserQuestion`; REFACTOR declined -- code already clean). Verification: `devtools::check()`
  0 errors/0 warnings/1 pre-existing unrelated NOTE (`vignettes/figure` leftover, confirmed via
  `git log` to predate this session); full clean regression read 0 failed/0 error;
  `lintr::lint_package()` 0 lints on all 3 touched files; direct reproduction of the audit's 3
  previously-divergent cells against `kinship2` ground truth (`kinship(8,9)=0.5`,
  `kinship(9,10)=0.28125`, `kinship(10,10)=0.53125`, all exact). Close-out checklist mapping
  (plan §8): citation (#120) N/A; `NEWS.Rmd`/tutorial-article N/A for Slice 1 (applies at Slice
  3 per the plan); `a2interactive.Rmd` deferred; GitHub issue close-out N/A (no issue filed
  yet). TDD phase: GREEN.

### 2026-08-13 · [BL-N] S551 claim: Slice 1 (core algorithm) of the twinRelations-into-kinship() plan
- **Deliverable:** Session S551 claimed. Picking up the S550-ratified plan's own Slice 1
  (`docs/planning/twin-relations-kinship-computation-plan.md` §4) -- production code, full
  strict-TDD PRE-RED->RED->GREEN(->REFACTOR) gates apply.

### 2026-08-13 · [ad hoc] S551 Phase 0 reconcile: S550's HANDOFFS.md commit self-reference
- **Deliverable:** Phase 0 ledger reconcile (`SESSION_RUNNER.md` step 6). S550's `HANDOFFS.md`
  receipt shipped with `commit: pending` -- the standard self-reference limitation (the receipt
  ships in the very commit whose sha it would name), matching the S543-S545/S549 precedent each
  prior session reconciled at its own claim. `HANDOFFS.md`'s frontier (`git log -1 --
  HANDOFFS.md`) == `bab8ead8` (S550's own close-out commit), so reconciled `commit: pending` ->
  `bab8ead8`. No other undocumented commits found; `CHANGELOG.md`'s own frontier == `HEAD`
  already. `gh run list --branch master --limit 10` showed the scheduled `shinytest2.yaml` run
  still red at the E2E-tier step, unchanged from S548/S549/S550's own findings -- not diagnosed
  this session (report, don't fix, per established precedent).
- **Commit:** this reconcile's own commit (`ec056055`).

### 2026-08-13 · [BL-N] S550 close-out: session self-assessment, S549 handoff evaluation, Learning 557
- **Deliverable:** Session S550's own close-out. Evaluated S549's `HANDOFFS.md` receipt (8/10 --
  the `next_steps` priority list matched this session's own independently-rendered Phase 0
  priorities exactly, but the `active_task`/`what_was_done` fields' "15 call sites of `kinship()`"
  figure was found inaccurate once this session ran an AST-level inventory -- corrected, not
  fabricated, since S549's own audit carried the same unverified number). Self-assessment (9/10),
  handoff notes, and `PROJECT_LEARNINGS.md` Learning 557 (the call-site-verification +
  documented-invariant-tension disciplines) written to `SESSION_NOTES.md`/`HANDOFFS.md`. See
  `SESSION_NOTES.md` for the full record.

### 2026-08-13 · [BL-N] S550: ratified design for threading `twinRelations` into `kinship()`'s computation
- **Deliverable:** `docs/planning/twin-relations-kinship-computation-plan.md` (RATIFIED) --
  designed how the existing `twinRelations` sidecar data model (issue #137) reaches
  `kinship()`'s own computation, per S549 Finding #1. An AST-level (parse-and-walk) inventory
  found 7 production call sites, not the audit's carried-forward "15" -- `reportGV()`,
  `gvaConvergence()`, `createSimKinships()`, `cumulateSimKinships()` (the latter two confirmed
  to have zero in-package callers, standalone script utilities), the app's shared kinship
  reactive, and 2 Shiny-module fallback recomputes -- plus 30 test call sites; 10 further
  matrix-consumer functions (`meanKinship()`, etc.) need no change. Derived mathematically why
  the MZ-identity correction must live inside `kinship()`'s own recursive depth loop, not a
  post-hoc patch on the finished matrix (a single-pass fix cannot propagate to a twin's
  descendants -- confirmed against the audit's own `kinship(9,10)` worked example). Reconciled
  the proposal against `R/applyKinshipOverrides.R`'s own documented "`kinship()` itself is never
  modified" invariant by distinguishing a structural pedigree fact (twin identity) from an
  outside-information override, verified against `makeSimPed()`'s actual pass-through behavior
  for already-known individuals. Proposed a 3-slice implementation (core algorithm -> the 4
  script-callable functions -> full Shiny wiring, the last flagging an unresolved tab-order UX
  dragon for its own Pre-RED). Ratified via `AskUserQuestion` (2 judgment calls: extend
  `kinship()`'s own signature; trust a pre-validated `twinRelations` rather than adding a new
  `sex` parameter) -- owner selected the document's own recommended option both times, no
  changes requested. `BACKLOG.md`'s triggering item updated with the ratified pointer and the
  corrected call-site count. TDD phase: N/A (design/planning deliverable, no production code or
  test surface, matching the S457/S458/S485/S488/S491/S499/S517 precedent).

### 2026-08-13 · [BL-N] S550 claim: thread `twinRelations` into `kinship()`'s computation (design)
- **Deliverable:** Session S550 claimed. Picking up the `BACKLOG.md` Housekeeping item (found
  S549, Finding #1 of the kinship2 reproducibility audit) -- design (not implement) how the
  existing `twinRelations` sidecar data model reaches `kinship()`'s own computation, scoped to a
  design-document-only deliverable per an `AskUserQuestion`-gated scope decision.

### 2026-08-13 · [BL-N] S549 close-out: session self-assessment, S548 handoff evaluation, Learning 556
- **Deliverable:** Session S549's own close-out. Evaluated S548's `HANDOFFS.md` receipt (9/10 --
  the `next_steps` priority list matched this session's own independently-rendered Phase 0
  priorities exactly; nothing inaccurate found). Self-assessment, handoff notes, and
  `PROJECT_LEARNINGS.md` Learning 556 written to `SESSION_NOTES.md`/`HANDOFFS.md`. See
  `SESSION_NOTES.md` for the full record.

### 2026-08-13 · [BL-N] S549: kinship2 supplementary-material reproducibility audit
- **Deliverable:** `docs/audits/KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md` --
  verified whether `nprcgenekeepr`'s exported functions reproduce
  `inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf` (kinship2's own
  supplementary material). Found the full 17-subject `fam1` pedigree isn't reconstructible
  from this repo's materials (Figure 1 lives in the kinship2 *main* paper, not this
  supplement, not among the repo's other reference PDFs, not shipped in any installed
  `kinship2` dataset); audited the fully-specified 10-subject Figure S1 subset instead,
  reconstructed from Table S1's own kinship values (verified via the paper's stated
  self/parent-offspring/avuncular/cousin coefficients, not guessed from the figure). Result:
  `kinship()`'s autosomal matrix reproduces Table S1 exactly except the pedigree's one
  MZ-twin pair's cells (Finding #1 -- a real capability gap: `twinRelations` feeds only the
  Diagram tab, not `kinship()`'s 15 call sites, confirmed via a side-by-side
  `kinship2::kinship()` reproduction with the twin relation declared); pedigree-diagram
  structure (nodes/edges/generations/twin-connector) is correct via
  `makePedigreeDiagramData()`/`makePedigreeMatingLayout()`, but no visual marker exists for a
  consanguineous mating (Finding #2, distinct from the already-closed issue #134 and from the
  BACKLOG "Candidate C" dogleg item); kinship2's `pedigree.shrink()` and X-chromosome kinship
  have no `nprcgenekeepr` equivalent, both judged capability-fit non-issues rather than gaps
  (Findings #3/#4). `BACKLOG.md` updated: the triggering item resolved with a pointer; 2 new
  Housekeeping items filed for Findings #1/#2, recommended for future `AskUserQuestion` triage
  (matching the `GENETIC_METRICS_PDF_CAPABILITY_AUDIT`/`ISSUE_129_...` precedent), not filed as
  GitHub issues this session. TDD phase: N/A (audit/investigation deliverable, no production
  code or test surface, matching the S529-S548 precedent).

### 2026-08-13 · [BL-N] S549 claim: kinship2 supplement PDF reproducibility audit

### 2026-08-13 · [ad hoc] S548 close-out: session self-assessment, S547 handoff evaluation, Learning 555
- **Deliverable:** Session S548's own close-out. Evaluated S547's `HANDOFFS.md` receipt (8/10 --
  its `next_steps` priority list matched this session's own independently-rendered Phase 0
  priorities almost exactly, but item (4) was inaccurate: `BACKLOG.md`'s own text shows the
  "remaining ledger-size housekeeping" work it named was already fully resolved by S531; caught by
  reading `BACKLOG.md` directly and corrected in this session's own Phase 0 report rather than
  propagated). Self-assessed 9/10 (strengths: caught a real parser boundary-detection bug before
  any deletion by inspecting outlier block sizes; verified all 61 items' `CHANGELOG.md` coverage
  mechanically with 0 gaps; diffed the proposed result against the original before applying and
  re-read the full file after; resolved the session's own triggering `BACKLOG.md` item in the same
  commit, deleted outright per its own stated preference. Weaknesses: no `devtools::check()` run
  [deliberate -- zero `R/`/`tests/` files touched]; the coverage-verification method is a coarse
  session-citation proxy, not topic-level; did not exhaustively check for external links to each of
  the 61 deleted items individually). Full write-up in `SESSION_NOTES.md`; receipt completed in
  `HANDOFFS.md`. New finding surfaced (not diagnosed): the scheduled `shinytest2.yaml` CI run
  (`31678188033`) failed at the E2E-tier step -- reported per the S545 CI-check convention.

### 2026-08-13 · [BL-deleteResolvedBullets] S548: deleted 61 resolved BACKLOG.md pointer bullets outright
- **Deliverable:** Parsed `BACKLOG.md` programmatically (Python, strict indentation-based
  item-boundary detection — a top-level item ends only at the next `- [ ]`/`- [x]` bullet, a `## `
  header, or a column-0 non-indented non-bullet line; blank lines followed by indented content stay
  inside the item) into 78 top-level bulleted items: 61 matched the resolved-pointer shape
  (`- [ ] (none remaining -- ...)` or any `- [x]`), 17 were genuinely open and left untouched. A
  first, looser boundary rule (stop only at the next bullet or `## ` header) wrongly merged 65 lines
  of free-standing, unbulleted Tier-1/Tier-2 sequencing narrative into a preceding `[x]` item — caught
  by inspecting the largest merged blocks before deleting anything, not after; the stricter rule fixed
  it and left that narrative (and 2 similar unbulleted-narrative blocks elsewhere) untouched, since it
  was never itself a bullet.
- **Verification (S529 precedent):** extracted every `S<N>`/`Session <N>` reference cited inside each
  of the 61 items and confirmed each is covered by an entry somewhere in `CHANGELOG.md` or its 4
  archive shards (incl. the new `docs/archive/CHANGELOG-legacy-pre-S325.md`) — 58 items had >=1 cited
  session, all fully covered, zero missing (unlike S529, which found 2 gaps needing backfill first).
  The other 3 items were bare, contentless `- [ ] (none remaining)` placeholders with no narrative to
  verify — their sections' own preceding italicized prose already documents the resolution and its
  `CHANGELOG.md` pointer, so nothing was at risk of being lost.
- **Executed:** removed all 61 items (706 lines) plus this item's own trigger — `BACKLOG.md`'s
  Housekeeping item "Stop editing resolved `BACKLOG.md` items in place..." (25 lines) — since this
  session's work resolves it; deleted outright per its own instruction rather than left as a pointer.
  Collapsed resulting double-blank-lines to single. `BACKLOG.md`: 1,559 -> 822 lines (a 47%
  reduction), all 10 section headers intact, 16 genuinely open items remain (the 17th being the
  just-resolved trigger item itself). Verified via `diff`: 0 lines added, only deletions; re-read the
  full resulting file end-to-end before committing.

### 2026-08-13 · [BL-deleteResolvedBullets] S548 claim: delete resolved BACKLOG.md pointer bullets
- **Deliverable:** Session S548 claimed. Picking up the `BACKLOG.md` Housekeeping item (found
  S545) — delete the ~57-62 resolved `"(none remaining -- ... RESOLVED ...)"` pointer bullets
  outright, verifying each item's resolution has a durable `CHANGELOG.md` entry first (S529
  precedent: 2 cases had none and needed backfilling before deletion).

### 2026-08-13 · [ad hoc] S547 close-out: session self-assessment, S546 handoff evaluation
- **Deliverable:** Session S547's own close-out. Evaluated S546's `HANDOFFS.md` receipt (9/10 --
  its `gotchas` field's fence-scanner-defect warning directly shaped this session's first
  verification step, and was confirmed not applicable). Self-assessed 9/10 (strengths: verified
  the specific structural precondition the named risk needed, not just "no errors"; used the
  tool's own zone boundary rather than hand-picked line numbers; tested against the real tracked
  file, not only a scratch simulation; caught and fixed a verification-script bug before trusting
  a false result. Weakness: the temporary real-file overwrite-then-restore step carried a small,
  low-probability crash-recovery risk a git worktree would have avoided). Full write-up in
  `SESSION_NOTES.md`; receipt completed in `HANDOFFS.md`.

### 2026-08-13 · [BL-N] S547: verified and executed the CHANGELOG.md legacy-footer relocation, Learning 554
- **Deliverable:** Both verification checks from the S546-decided `BACKLOG.md` item passed, and the
  relocation was executed the same session (the item's own "if verification allows, execute"
  framing). **Check 1** (`methodology_trim.py` L1/L2/L3): zero fence markers anywhere in the legacy
  footer (grep + the tool's own `fence_scan()`), so the `SESSION_NOTES.md` fence-scanner defect
  class cannot occur here; `classify_zones()` and a real `--check` run against the post-relocation
  content both came back clean, `[CHECK] trigger does not fire`. **Check 2** (nothing expects it
  inline): grepped `docs/`, `bin/`, `*.py` — no script/tool has a live dependency on the block's
  location; `methodology_trim.py`'s `archive_events()` discovers shards by glob + a live-file-
  size-drop check, not filename parsing, so the new shard's descriptive (non-`-through-<date>`)
  name is still picked up correctly. Only inline references found were prose in already-closed
  planning docs and frozen archive/learnings history — left untouched per standing precedent
  against editing completed documents.
- **Executed:** relocated the block (935,287 B / 3,567 lines, byte-for-byte verified before/after)
  to [`docs/archive/CHANGELOG-legacy-pre-S325.md`](docs/archive/CHANGELOG-legacy-pre-S325.md);
  updated this file's "shard convention" note and live pointer to describe the new location.
  `CHANGELOG.md` is now 20,929 B / 283 lines — both the byte and line triggers clear (down from
  954,673 B / 3,836 lines). `CLAUDE.md`'s "CHANGELOG.md ledger-format resolution" note gained an
  S547 addendum recording the verification and execution. `BACKLOG.md`'s item resolved.
  `PROJECT_LEARNINGS.md` Learning 554 records the verification technique (importing
  `methodology_trim.py` and calling its `classify_zones()` directly against simulated post-edit
  content before making the real edit) for reuse on any future footer-zone relocation.

### 2026-08-13 · [BL-N] S547 claim: scope + verify the CHANGELOG.md legacy-footer bulk relocation
- **Deliverable:** Session S547 claimed. Picking up the `BACKLOG.md` Housekeeping item decided
  S546 ("Scope (and if verification allows, execute) a bulk relocation of `CHANGELOG.md`'s frozen
  pre-S325 legacy footer into its own archive file, un-retagged") — verify `methodology_trim.py`'s
  L1/L2/L3 losslessness invariants survive the relocation, grep for anything expecting the block
  inline, and execute if both are clear.

### 2026-08-13 · [ad hoc] S546 close-out: S325 CHANGELOG.md legacy-footer decision resolved (bulk-relocate scoped, not executed), Learning 553
- **Deliverable:** Session S546's own close-out. `BACKLOG.md`'s "Reopen the S325 'freeze legacy,
  go forward' decision" Housekeeping item (found S543) resolved via a 3-option `AskUserQuestion`
  (scope a lighter bulk relocation of the frozen legacy footer into its own archive file,
  un-retagged / commit to the full ~303-entry re-tag migration campaign / hold as a permanent
  known limitation) — owner picked the bulk-relocation option. `BACKLOG.md` item rewritten to
  READY, Effort M, scoped as a future session's job (verify `methodology_trim.py` L1/L2/L3
  invariants + no script expects the block inline, before moving anything — decision-only this
  session, no file relocated). `CLAUDE.md`'s "CHANGELOG.md ledger-format resolution" note gained
  an S546 addendum recording the decision and the 2 rejected-for-now fallbacks. Recorded
  `PROJECT_LEARNINGS.md` Learning 553 (a picker-before-prose-report process slip, self-caught and
  corrected; and the value of re-deriving a decision from its own underlying investigation rather
  than trusting a prior session's binary framing, which is how the third option was found).
- **Commit:** this close-out's own commit.

### 2026-08-13 · [ad hoc] S546 Phase 0 reconcile: S545's HANDOFFS.md commit self-reference
- **Deliverable:** Phase 0 ledger reconcile (`SESSION_RUNNER.md` step 6). S545's `HANDOFFS.md`
  receipt shipped with `commit: pending` — the standard self-reference limitation (the receipt
  ships in the very commit whose sha it would name), matching the S543→S544 and S544→S545
  pattern each prior session reconciled at its own claim. `HANDOFFS.md`'s frontier
  (`git log -1 -- HANDOFFS.md`) == `7021c6f7` (S545's own close-out commit), so reconciled
  `commit: pending` → `7021c6f7`. No undocumented commits found otherwise; `CHANGELOG.md`'s own
  frontier == `HEAD` already; `gh run list --branch master --limit 10` confirmed all 4 workflows
  on `7021c6f7` (S545's close-out push) completed successfully, resolving the
  still-`in_progress` `R-CMD-check.yaml` run S545's own handoff had flagged unconfirmed.
- **Commit:** this reconcile's own commit.

### 2026-08-13 · [ad hoc] S545 close-out: Phase 0 CI-check decision recorded in CLAUDE.md, BACKLOG.md updated (item resolved + 2 new items), Learning 552
- **Deliverable:** Session S545's own close-out. `BACKLOG.md`'s "Phase 0 has no step that checks
  GitHub Actions CI status" Housekeeping item (found S540) marked RESOLVED, citing the
  `CLAUDE.md` decision. Added 2 new `BACKLOG.md` items (both owner-directed mid-turn): (1) verify
  `nprcgenekeepr`'s exported functions can reproduce the kinship2 R package's own
  supplementary-material worked examples (`inst/extdata/reference/
  NIHMS593658-supplement-supplement_1.pdf`); (2) stop editing resolved `BACKLOG.md` items in
  place into "(none remaining)" pointers — delete them outright instead, per `SESSION_RUNNER.md`
  Phase 3F / FM#27's own literal instruction (57 of ~75 top-level bullets currently carry this
  pattern). Recorded `PROJECT_LEARNINGS.md` Learning 552 (the 2-axis CI-check decision shape, and
  the value of smoke-testing a documented-but-unrun Phase 0 step before close-out).
- **Commit:** this close-out's own commit.

### 2026-08-13 · [BL-phase0CiCheck] Decided the Phase 0 GitHub Actions CI-status check: gh run list --branch master --limit 10, every session, unconditionally (Session 545)
- **Deliverable:** `BACKLOG.md`'s "Phase 0 has no step that checks GitHub Actions CI status" item
  (found S540, `PROJECT_LEARNINGS.md` Learning 547). Presented the decision as a 4-option
  `AskUserQuestion` (every-session unconditional / push-conditioned / branch-protection-instead /
  hold); owner chose unconditional. Recorded in `CLAUDE.md`'s "Additional Phase 0 steps": run
  `gh run list --branch master --limit 10` at Phase 0 step 4 every session (never conditioned on
  whether this project pushed, since a scheduled/manually-triggered workflow can go red with no
  intervening local push at all); report, don't fix, any non-`completed success` run at step 7;
  the 3 rejected alternatives recorded so a future session doesn't re-litigate. Smoke-tested the
  documented command immediately: found `R-CMD-check.yaml` on `126711a9` still `in_progress` at
  15+ minutes — not a red run, but exactly the class of thing the new step exists to catch;
  reported, not chased, to keep this session's own scope intact.
- **Commit:** `7741b47e`.

### 2026-08-13 · [ad hoc] S545 claim: Phase 0 CI-status-check decision
- **Deliverable:** Session 545's Phase 1B claim stub (`SESSION_NOTES.md`, `HANDOFFS.md`).
- **Commit:** `c6c6c0a6`.

### 2026-08-13 · [ad hoc] S545 Phase 0 reconcile: S544's HANDOFFS.md commit self-reference
- **Deliverable:** Phase 0 ledger reconcile (`SESSION_RUNNER.md` step 6). S544's `HANDOFFS.md`
  receipt shipped with `commit: pending` — the standard self-reference limitation (the receipt
  ships in the very commit whose sha it would name), matching the S543 pattern S544 itself
  reconciled at its own claim. `HANDOFFS.md`'s frontier (`git log -1 -- HANDOFFS.md`) ==
  `126711a9` (S544's own close-out commit), so reconciled `commit: pending` → `126711a9`. No
  undocumented commits found otherwise; `CHANGELOG.md`'s own frontier == `HEAD` already.
- **Commit:** `dd177a80`.

### 2026-08-13 · [ad hoc] S544 close-out: test-coverage.yaml fix confirmed green on CI, BACKLOG.md updated (item resolved + new Pedigree Diagram article item), Learning 551
- **Deliverable:** Session S544's own close-out. `BACKLOG.md`'s `test-coverage.yaml` Housekeeping
  item (found S542) marked RESOLVED, citing the fix commit and the confirmed-green CI run. Added
  a new `BACKLOG.md` item (owner-requested mid-turn): a dedicated Pedigree Diagram tutorial
  article, distinct from and superseding the existing stale-screenshot item. Recorded
  `PROJECT_LEARNINGS.md` Learning 551 (the `covr --install-tests` vs. source-tree detection
  root cause, and the fast local-repro technique used to confirm it without a full `covr` run).
- **Commit:** this close-out's own commit.

### 2026-08-13 · [BL-testCoverageCovrInstallTests] Fixed test-coverage.yaml: find_pkg_src() now requires inst/ present, not just DESCRIPTION (Session 544)
- **Deliverable:** `tests/testthat/test_wordlist_coverage.R`'s `find_pkg_src()` helper was
  mis-accepting an INSTALLED package directory (retains `DESCRIPTION`, loses `inst/` — flattened
  into the package root by `R CMD INSTALL`) as a source tree under `covr::package_coverage()`'s
  `--install-tests` execution model, causing `spelling::get_wordfile()` to silently miss
  `inst/WORDLIST` and flag 146 already-whitelisted domain words as unknown. Fixed by requiring
  `dir.exists(file.path(cand, "inst"))` alongside the existing `DESCRIPTION` check in all 3
  branches (a shared `is_pkg_src()` helper). 2 new tests pin the source-vs-installed detection
  directly. Strict TDD RED→GREEN, both gates `AskUserQuestion`-approved. Full regression 0
  failed/0 error (5,519 passed); `devtools::check()` 0 errors/0 warnings/1 pre-existing
  unrelated NOTE; `lintr` clean. Pushed and confirmed `test-coverage.yaml` (plus
  `R-CMD-check.yaml`/`pkgdown.yaml`/`lint.yaml`) all `completed success` on the real CI run.
- **Commit:** `f4b478c0`.

### 2026-08-13 · [ad hoc] S544 claim: test-coverage.yaml CI diagnosis; reconciled S543's HANDOFFS.md self-reference (Session 544)
- **Deliverable:** Session 544's Phase 1B claim stub (`SESSION_NOTES.md`, `HANDOFFS.md`).
  Reconciled S543's `HANDOFFS.md` receipt's `commit: pending` self-reference to `4bac5d55`
  (the expected, routine next-session fill-in per the established S538-S541 pattern).
- **Commit:** `cd5eb453`.

### 2026-08-12 · [ad hoc] S543 close-out: CHANGELOG.md SRF_RED decision resolved, 2 new BACKLOG.md findings, Learning 550
- **Deliverable:** Session S543's own close-out. Resolved the `CHANGELOG.md` `SRF_RED` archive
  refusal by force-archiving (see the trim entry below), after finding the decisive structural
  fact that the trimmable region is capped at 116,176 B against a 935,287 B permanently-pinned
  pre-S325 legacy footer, so no trim of the tagged region can ever clear the byte/line trigger
  regardless of force. Logged 2 new `BACKLOG.md` Housekeeping items: reopening the S325
  "freeze legacy, go forward" decision as the only real lever (DECISION NEEDED, Effort L, needs
  its own scoping session); and `CHANGELOG.md`'s own ~4-entries-per-session convention as a
  possible rate contributor analogous to `HANDOFFS.md`'s diagnosed Receipt Inflation (H4), not
  confirmed causal. `PROJECT_LEARNINGS.md` Learning 550 records the SRF-artifact-vs-structural-
  ceiling distinction. See `SESSION_NOTES.md`, `HANDOFFS.md`.

**Archived 67 record(s), 2026-08-11 → 2026-08-12** into [`docs/archive/CHANGELOG-through-2026-08-12.md`](docs/archive/CHANGELOG-through-2026-08-12.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-08-12.md.verify.sh`](docs/archive/CHANGELOG-through-2026-08-12.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Relocated the entire pre-Session-325 legacy block (roughly 303 record(s), Sessions 1-324,
pre-ledger format)** into [`docs/archive/CHANGELOG-legacy-pre-S325.md`](docs/archive/CHANGELOG-legacy-pre-S325.md)
— S547, 2026-08-13 — verbatim, un-retagged, frozen, same order. Unlike the pointer above, this was
a one-time manual relocation of the frozen footer zone, not a `methodology_trim.py --write` trim of
the records zone, so there is no tool-generated `.verify.sh` for it; losslessness was instead
verified directly (a byte-for-byte comparison of the moved content against what `classify_zones()`
reported as the footer, plus a post-relocation `--check` run confirming the tool's own zone
classification and trigger both resolve cleanly) — see this file's own S547 entry and
`PROJECT_LEARNINGS.md` for the full verification record.

### 2026-08-12 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-08-12.md` (67 record(s), 1,051,843 B → 945,242 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **67** record(s) (2026-08-11 → 2026-08-12) out of [`CHANGELOG.md`](CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-08-12.md`](docs/archive/CHANGELOG-through-2026-08-12.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-08-12.md.verify.sh`](docs/archive/CHANGELOG-through-2026-08-12.md.verify.sh)
rather than trusting a digest printed here. Live file 1,051,843 B → 945,242 B (−10.1%).

### 2026-08-12 · [ad hoc] S543 claim: CHANGELOG.md SRF_RED archive-refusal decision
- **Deliverable:** Session S543 claimed (`ca6b17fb`) to decide how to handle `CHANGELOG.md`'s
  `methodology_trim.py` `SRF_RED` refusal (owner-picked via the Phase 0 `AskUserQuestion`
  picker, over `test-coverage.yaml` CI diagnosis / the Phase 0 CI-check-gap decision / issue
  #138 scoping).

