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

### 2026-08-13 · [ad hoc] S559 close-out: SESSION_NOTES.md/HANDOFFS.md/CHANGELOG.md all archived; S558 handoff evaluation; Learning 565 logged
- **Deliverable:** Session S559's own close-out. Evaluated S558's `HANDOFFS.md` receipt (9/10
  -- its `next_steps` field named this exact item verbatim as item 1 of its priority list,
  followed as the literal first and only investigative step; nothing found inaccurate beyond
  the expected, documented `commit: pending` self-reference, reconciled to `cafd7d49` before
  archiving). Self-assessed 8/10 (the one point off: an avoidable process mistake -- chained
  3 `methodology_trim.py --write` calls across different ledger files without committing
  between them, breaking `CHANGELOG.md`'s own generated `verify.sh` comparison against a
  stale `HEAD` -- caught before any commit, recovered via a precise surgical unwind, and
  documented as `PROJECT_LEARNINGS.md` Learning 565 so a future multi-ledger archive session
  doesn't repeat it). Logged a new `BACKLOG.md` Housekeeping item for `HANDOFFS.md`'s
  recurring, non-blocking `FRONTMATTER_FIELD_ABSENT` finding (first seen S508, needs an
  explicit add-vs-remove decision). Updated `CLAUDE.md`'s stale "Sessions 1-504+; 503
  learnings" pointer to the current count (559+; 565 learnings). See `SESSION_NOTES.md` for
  the full record.

**Archived 34 record(s), 2026-08-12 → 2026-08-13** into [`docs/archive/CHANGELOG-through-2026-08-13.md`](docs/archive/CHANGELOG-through-2026-08-13.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-08-13.md.verify.sh`](docs/archive/CHANGELOG-through-2026-08-13.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

### 2026-08-13 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-08-13.md` (34 record(s), 67,414 B → 33,924 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **34** record(s) (2026-08-12 → 2026-08-13) out of [`CHANGELOG.md`](CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-08-13.md`](docs/archive/CHANGELOG-through-2026-08-13.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-08-13.md.verify.sh`](docs/archive/CHANGELOG-through-2026-08-13.md.verify.sh)
rather than trusting a digest printed here. Live file 67,414 B → 33,924 B (−49.7%).

### 2026-08-13 · [ad hoc] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-08-13.md` (17 record(s), 109,667 B → 9,200 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **17** record(s) (2026-08-12 → 2026-08-13) out of [`HANDOFFS.md`](HANDOFFS.md) into
[`docs/archive/HANDOFFS-through-2026-08-13.md`](docs/archive/HANDOFFS-through-2026-08-13.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/HANDOFFS-through-2026-08-13.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-13.md.verify.sh)
rather than trusting a digest printed here. Live file 109,667 B → 9,200 B (−91.6%).

### 2026-08-13 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-08-13.md` (40 record(s), 208,194 B → 27,604 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **40** record(s) (2026-08-11 → 2026-08-13) out of [`SESSION_NOTES.md`](SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-08-13.md`](docs/archive/SESSION_NOTES-through-2026-08-13.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh)
rather than trusting a digest printed here. Live file 208,194 B → 27,604 B (−86.7%).

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

