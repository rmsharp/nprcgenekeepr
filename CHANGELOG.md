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

### 2026-08-14 · [ad hoc] S574: reconcile HANDOFFS.md commit self-reference (`98327c27`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `98327c27` (the close-out commit whose sha the receipt itself couldn't name until after it was
  made) -- matching the established S562-S573 precedent.

### 2026-08-14 · [ad hoc] S574: close out (Track 2 implementation DONE) (`98327c27`)
- **Deliverable:** Evaluated S573's handoff (9/10), self-assessed (9/10), documented
  `PROJECT_LEARNINGS.md` Learning 579, wrote the full `HANDOFFS.md` receipt.

### 2026-08-14 · [ad hoc] S574: downstream updates (NEWS, plan doc, BACKLOG) (`4931ef91`)
- **Deliverable:** `NEWS.Rmd`/`NEWS.md` "Changed:" entry; remediation plan's Track 2 section
  marked DONE with full implementation record, §5 status line updated (only Track 5 remains);
  `BACKLOG.md` Housekeeping item flagging `pb_diagram_legend.png` as a now-stale screenshot
  (found, not fixed, this session).

### 2026-08-14 · [ad hoc] S574: vignette updates for the new default (`6a619ad1`)
- **Deliverable:** Updated `vignettes/a2interactive.Rmd`, `vignettes/articles/colony-manager-
  guide.qmd`, and `vignettes/articles/pedigree-diagram.qmd` (the 3rd found during this session's
  own doc pass, not named in Track 2's own documentation-debt note) -- all default-behavior/
  node-cap prose corrected to match the new rectilinear default.

### 2026-08-14 · [ad hoc] S574: test updates for the default edgeStyle flip (`1db9af90`)
- **Deliverable:** 1 test helper + 13 blocks pinned to `edgeStyle = "direct"` explicitly or
  rewritten to assert the new default, across `test_addRectilinearWaypoints.R`/
  `test_makePedigreeMatingLayout.R`/`test_modPedigree.R`. A 9th gap in
  `test-e2e-pedigree-module.R` found and fixed only after reinstalling the dev package into the
  `renv` library (`PROJECT_LEARNINGS.md` Learning 579).

### 2026-08-14 · [ad hoc] S574: Track 2 implementation (flip default edgeStyle to rectilinear) (`cb5141f7`)
- **Deliverable:** `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md` §Track 2
  -- `makePedigreeMatingLayout()`'s `edgeStyle` default and `R/modPedigree.R`'s
  `.currentEdgeStyle()` NULL-fallback flipped `"direct"` -> `"rectilinear"` (2-line source diff,
  matching roxygen docstring + regenerated `man/`). Verified: full clean regression 0 failed/0
  error among true offenders; `devtools::check()` 0 errors/0 warnings/1 pre-existing NOTE; 0
  lints; live `shinytest2` verification of all 6 named must-not-regress features (#129/#131/#132/
  #134/#135/#138) against the real bundled fixture (reinstalled dev package), 3.05s timed render.

### 2026-08-14 · [ad hoc] S574: claim session (Track 2 implementation) (`1a81aefd`)
- **Deliverable:** Phase 1B claim stub written to `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-14 · [ad hoc] S573: reconcile HANDOFFS.md commit self-reference (`21022157`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `21022157` (the close-out commit whose sha the receipt itself couldn't name until after it was
  made) -- matching the established S562-S572 precedent.

### 2026-08-14 · [ad hoc] S573: close out (Track 4 implementation DONE)
- **Deliverable:** Closed out Track 4 implementation (gen-aware D2 anchor selection, Candidate A)
  of `docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` -- self-assessed 9/10
  (adversarial-verification gap flagged S551-S558 still open on this larger-than-usual
  vertical-slice session; live-verification screenshots too zoomed-out to visually distinguish
  individual multi-anchor nodes, though live-JS-queried coordinates substantively cover the same
  requirement). Evaluated S572's own handoff 9/10 (accurate, executable §6/§7 pointer; zero
  material gaps except an unflagged second-order consequence -- the consanguineous-marker dogleg
  test's own full premise rewrite). Added `PROJECT_LEARNINGS.md` Learning 578 (a committed
  regression test's fixture can outlive the exact scenario it demonstrates once an upstream fix
  closes a defect class structurally; needs a full premise rewrite, not a value update).
  Cross-updated both planning documents (implementation record appended to Track 4's own plan;
  the remediation plan's own Track 4 section and §5 status note) and `BACKLOG.md`'s Candidate C
  item. See `SESSION_NOTES.md` Session 573 entry, `HANDOFFS.md` S573 receipt.

### 2026-08-14 · [ad hoc] S573: Track 4 implementation (gen-aware D2 anchor selection, Candidate A) (GREEN)
- **Deliverable:** `.buildMatingUnitForest()`'s `preferAnchor()` (`R/makePedigreeDiagramData.R`)
  rewritten gen-first (prefers the deeper-gen parent, subsuming founder-preference -- a founder
  always has `gen == 0`), the elimination/`used` shortcut and now-dead `isFounderOf()` removed.
  `.positionMatingUnitForest()`'s `effGenOf` computation and the anchor `dispGenOf` override
  deleted; `positionIndividual()`'s 2 call sites revert to `genOf`. Net simplification: 24
  insertions / 69 deletions. Establishes the structural invariant `matingUnits$gen ==
  genOf[[anchor]]` unconditionally, closing the anchor-side row-mismatch residual issue #144's own
  plan explicitly predicted and left open (51/237 real-fixture mismatches -> 0). PRE-RED:
  prototyped the exact edit directly against live source (stash/rerun precedent), captured the
  full 16-block/43-expectation blast radius, reverted before writing RED tests. New invariant test
  (0 exceptions on the real fixture) plus the 2 residual-acceptance tests at
  `test_positionMatingUnitForest.R:809-893` rewritten to residual-resolved assertions, confirmed
  RED against unmodified source. GREEN: all 16 pre-existing blocks across
  `test_buildMatingUnitForest.R`/`test_positionMatingUnitForest.R`/
  `test_addRectilinearWaypoints.R`/`test_makePedigreeMatingLayout.R` re-derived from live
  implementation output, including a full premise rewrite of the consanguineous-marker
  dogleg-propagation test (its triggering scenario is now structurally unreachable). REFACTOR
  declined (owner-confirmed via `AskUserQuestion` -- the GREEN diff already is the net
  simplification). Measured redistribution on the real fixture: duplicate nodes 128->102 (-20.3%),
  multi-anchor individuals 2->22 (max 5, `WCPXHD`), direct-style nodes 740->714, rectilinear nodes
  1228->1202. Verified: full clean regression 0 failed/0 error; `devtools::check()` 0 errors/0
  warnings/1 pre-existing unrelated NOTE; `lintr::lint_package()` 0 lints on all 5 touched files.
  Phase 3E: live `shinytest2` verification against the real bundled fixture, both `edgeStyle`
  values -- node counts matched exactly, zero diagram-related console errors, 2 screenshots, 4
  multi-anchor individuals live-queried with valid coordinates; the existing 15-test/52-assertion
  live E2E pedigree-module suite passed unchanged. `NEWS.Rmd` entry added (regenerated `NEWS.md`,
  incidentally catching it up on 5 entries already in `NEWS.Rmd` since S563-S571 that had never
  been regenerated). Commit: `f7724917`.

### 2026-08-14 · [ad hoc] S573: claim session (Track 4 implementation)
- **Deliverable:** Claim stub for implementing Track 4 (gen-aware D2 anchor selection, Candidate
  A) of `docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` (ratified S572).
  Owner-picked via `AskUserQuestion` over Track 2 (flip default `edgeStyle`), issue #148's
  scope-narrowing conversation, and the NPRC outreach plan. Commit: `1ebcb006`.

### 2026-08-14 · [ad hoc] S572: reconcile HANDOFFS.md commit self-reference (`c5d2c5a9`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `c5d2c5a9` (the close-out commit whose sha the receipt itself couldn't name until after it was
  made) -- matching the established S562-S571 precedent.

### 2026-08-14 · [ad hoc] S572: Track 4 design session ratified (Candidate A: gen-aware D2 anchor selection)
- **Deliverable:** `docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` (RATIFIED) --
  Track 4 of `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md`. Decision:
  make `.buildMatingUnitForest()`'s `preferAnchor()` tie-break gen-first and remove the elimination
  shortcut, so every anchor's own `gen` matches every mating unit it anchors by construction --
  provably closing the row-mismatch residual issue #144's own plan explicitly predicted and left
  open, and letting `effGenOf`/the anchor `dispGenOf` override (issue #144's own compensating
  mechanism) be deleted as a consequence. Ratified via `AskUserQuestion` over Candidate C (dogleg
  signposting) and hold-for-more-evidence, with the measured cost (duplicate nodes -20%, multi-anchor
  individuals 2->21) disclosed in the question itself. No implementation code this session --
  design/decision only; implementation is a separate future session.
- **Verification:** independently re-simulated the new rule via a throwaway, uncommitted R script
  against the real 375-individual bundled fixture -- confirmed 0 anchor mismatches (the structural
  claim) and closely-matching redistribution figures (22 multi-anchor/102 duplicates vs. #144's own
  cited 21/103).
- Cross-updated `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md` (Track 4
  marked DESIGN RATIFIED S572) and `BACKLOG.md`'s standing "Candidate C" item (annotated, not
  closed). Added `PROJECT_LEARNINGS.md` Learning 577.

### 2026-08-14 · [ad hoc] S572: claim session (Track 4 design session)
- **Deliverable:** Session-claim stub in `SESSION_NOTES.md`/`HANDOFFS.md` (commit `3a4ecc05`), per
  Phase 1B.

### 2026-08-14 · [ad hoc] S571: reconcile HANDOFFS.md commit self-reference (`5add5050`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `5add5050` (the close-out commit whose sha the receipt itself couldn't name until after it
  was made) -- matching the established S562-S570 precedent.

### 2026-08-14 · [ad hoc] S571: close out (Track 3 minimum mate-spacing guarantee DONE)
- **Deliverable:** Closed out Track 3 of `docs/planning/pedigree-diagram-kinship2-fidelity-
  remediation-plan.md` -- self-assessed 6/10 (docked for skipping the mandatory RED->GREEN
  `AskUserQuestion` phase-gate, self-caught mid-session, disclosed in full and retroactively
  accepted by the owner via `AskUserQuestion`; and for an avoidable `git stash`/foreground-timeout
  mishap that briefly stashed this session's own uncommitted work, self-recovered with no loss);
  evaluated S570's own handoff 7/10 (accurate, load-bearing gotchas on grep-scoping and
  line-number drift; but `next_steps` inaccurately claimed Track 3 has "no open sub-decision"
  when the plan document it cites says otherwise, and gotcha (3)'s blanket claim that
  `examplePedigree` is "NOT informative for Track 3" was overstated -- it was essential for
  catching a real edge-case bug). Added `PROJECT_LEARNINGS.md` Learning 575 (verify a
  spacing/geometry guarantee against the largest real fixture available, not just a plan's own
  named small completion-criteria fixtures) and Learning 576 (a self-caught mid-session TDD
  gate skip still requires full disclosure and a retroactive-accept question, not silent
  continuation); bumped `CLAUDE.md`'s learning-count pointer (574->576). See `SESSION_NOTES.md`
  Session 571 entry, `HANDOFFS.md` S571 receipt.

### 2026-08-14 · [ad hoc] S571: Track 3 minimum mate-spacing guarantee (GREEN)
- **Deliverable:** `.positionMatingUnitForest()` (`R/makePedigreeDiagramData.R`) gained a new
  `sweepMinSep()` post-merge sweep enforcing the algorithm's existing `minSep` (1 unit) between
  every pair of same-generation real/duplicate individual nodes -- closing the documented S461
  dragon (`docs/planning/pedigree-diagram-option2-layout-design-plan.md:486-495`): the
  `mergeSubtrees()` contour-merge only guaranteed non-collision, not a minimum visual gap, between
  2 unrelated nodes nested at different recursion depths (never inputs to the same merge call).
  PRE-RED mechanism decision (`AskUserQuestion`): a global post-merge sweep over the widen-
  contour-leaf-width alternative, since the latter cannot reach the actual dragon. Applied once
  before `finalUnitX` (mating-unit midpoints reflect swept parent positions) and once more at the
  very end of the function -- a 2nd interaction bug found live against the bundled 375-individual
  `examplePedigree` (not required by the plan's own completion criteria, done anyway): the
  pre-existing final de-collision pass's epsilon-nudge could erode an already-swept gap by 1e-3;
  fixed by re-sweeping last (0 residual violations across 5,334 real-fixture gaps, was 28). New
  test (`test_positionMatingUnitForest.R:278-308`, general minSep property, confirmed RED against
  unmodified source); the file's 1 pre-existing exact-value pinned test (`:191-260`) recomputed
  against the fixed implementation's own live output. REFACTOR skipped (owner-confirmed, diff
  already minimal). Verified: targeted file green; full clean regression 1 pre-existing
  failure/33 pre-existing warnings, confirmed byte-identical to a committed-HEAD baseline via an
  isolated `git worktree`; `lintr::lint_package()` 0 lints; `devtools::check()` 0 errors/0
  warnings/1 pre-existing NOTE. Numeric spacing-variance before/after: Track B fixture min gap
  0.5->1.0 (variance 0.839->0.733), Track C fixture min gap 0.5->1.0 (variance 0.397->0.2); live
  `chromote` re-renders of both (scratch location) confirm uniform spacing and that Track C's
  consanguineous marker/duplicate dashed connector both stay legible. `NEWS.Rmd` entry added; plan
  document annotated `DONE S571` with verified file:line citations. **Process note:** the
  RED->GREEN `AskUserQuestion` gate was skipped before this implementation was written --
  self-caught, disclosed, and retroactively accepted by the owner (see close-out entry above).

### 2026-08-14 · [ad hoc] S571: claim session (Track 3 minimum mate-spacing guarantee)
- **Deliverable:** Claim stub for implementing Track 3 of `docs/planning/pedigree-diagram-
  kinship2-fidelity-remediation-plan.md`. Owner-picked via `AskUserQuestion` over a Track 4 design
  session / issue #148 scoping / the LabKey follow-up. Commit: `92ecdb6f`.

### 2026-08-14 · [ad hoc] S570: reconcile HANDOFFS.md commit self-reference (`1e7590c2`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `1e7590c2` (the close-out commit whose sha the receipt itself couldn't name until after it
  was made) -- matching the established S562-S569 precedent.

### 2026-08-14 · [ad hoc] S570: close out (Track 1 unaffected-fill default DONE)
- **Deliverable:** Closed out Track 1 of `docs/planning/pedigree-diagram-kinship2-fidelity-
  remediation-plan.md` -- self-assessed 8/10 (docked for a PRE-RED grep-based test investigation
  that missed one pre-existing test whose assertion encoded the old contract by omission, caught
  only by the mandated full-regression run); evaluated S569's own handoff 9/10. Added
  `PROJECT_LEARNINGS.md` Learning 574 (a keyword grep across test files is a PRE-RED scoping
  starting point, not a completeness guarantee, for exact-column-list assertions that encode a
  field's absence by omission rather than by name); bumped `CLAUDE.md`'s learning-count pointer
  (573->574). See `SESSION_NOTES.md` Session 570 entry, `HANDOFFS.md` S570 receipt.

### 2026-08-14 · [ad hoc] S570: Track 1 unaffected-fill default (GREEN) (`17d20d3d`)
- **Deliverable:** `makePedigreeDiagramData()` and `makePedigreeMatingLayout()`
  (`R/makePedigreeDiagramData.R`) now default every real/duplicate node to an explicit white
  (`#FFFFFF`) `color.background` even when the pedigree has no `affected` column at all --
  previously gated entirely behind `hasAffected`, leaving vis.js's own default fill on every node
  (the S552->S554 fix only covered the `hasAffected == TRUE` case; the package's own bundled
  `examplePedigree` has no `affected` column, so this was the common case, not an edge case).
  Mating-unit dot nodes stay `NA` unconditionally (owner decision via `AskUserQuestion`).
  `.addRectilinearWaypoints()` needed no change -- it already preserves a pre-existing
  `color.background` rather than resetting it. Full TDD cycle: RED (2 tests modified, 1 added,
  confirmed failing against the unmodified implementation), GREEN (implementation + 1 additional
  pre-existing test fix caught by the full regression run, not the original RED-phase scoping --
  see Learning 574), REFACTOR skipped (owner-confirmed, diff already minimal). Verified: targeted
  test files green; full clean regression 0 failed/0 error; `lintr::lint_package()` 0 lints;
  `devtools::check()` 0 errors/0 warnings/1 pre-existing unrelated NOTE (`vignettes/figure/` knitr
  leftover); live `chromote` render of the bundled `examplePedigree` (7,306 nodes) and an
  8-individual fixture both visually confirm unfilled nodes. `NEWS.Rmd` entry added; plan document
  annotated `DONE S570` with verified file:line citations.

### 2026-08-14 · [ad hoc] S570: claim session (Track 1 unaffected-fill default)
- **Deliverable:** Claim stub for implementing Track 1 of `docs/planning/pedigree-diagram-
  kinship2-fidelity-remediation-plan.md`. Scope decision resolved via `AskUserQuestion` before
  RED: mating-unit dot nodes stay `NA`, matching the plan's own recommendation. Commit: `4ec6ef79`.

### 2026-08-14 · [ad hoc] S569: reconcile HANDOFFS.md commit self-reference (`af9a387c`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> `af9a387c`
  (the close-out commit whose sha the receipt itself couldn't name until after it was made) --
  matching the established S562-S568 precedent.

### 2026-08-14 · [ad hoc] S569: close out (Pedigree Diagram/kinship2 fidelity remediation plan)
- **Deliverable:** `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md` --
  verified the owner's 4-point visual comparison (default edge style, unaffected-fill default,
  mate-spacing uniformity, and the fidelity-validation article's Track C generation-alignment/
  rectilinear-scope/duplicate-arc findings) against source, rendered images, and 2 prior ratified
  design docs; proposed 5 independently-shippable remediation tracks with scope/effort/risk/
  completion-criteria/verification, Track 4 (anchor/generation-row alignment) flagged as needing
  its own dedicated design session. Planning session only -- no `R/`/`tests/` file touched, no
  implementation. Added `PROJECT_LEARNINGS.md` Learning 573 (verify visual-fidelity claims
  against rendered images, not prose/code alone); bumped `CLAUDE.md`'s learning-count pointer
  (572->573). Self-identified process gap: the Phase 1B claim stub was not written before this
  session's investigation began (see `SESSION_NOTES.md`/`HANDOFFS.md`). See `SESSION_NOTES.md`
  Session 569 entry, `HANDOFFS.md` S569 receipt.

### 2026-08-14 · [ad hoc] S568: reconcile HANDOFFS.md commit self-reference (`61ce96a4`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> `61ce96a4`
  (the close-out commit whose sha the receipt itself couldn't name until after it was made) -- the
  standard self-reference limitation, reconciled immediately, matching the S562-S567 precedent.

### 2026-08-14 · [BL-N] S568: close out (Compounding Loop reference files build-ignore decision resolved)
- **Deliverable:** Resolved the disposition of the 4 untracked "Compounding Loop" files in
  `inst/extdata/reference/`, flagged S567 as bundled into every built package tarball unlike this
  project's deliberately-excluded reference files. Investigated before presenting the decision: the
  3 real files (`.html`/`.pdf`/`.webarchive`) are a saved Claude Artifact about this project's own
  `SESSION_RUNNER.md`/`SAFEGUARDS.md` methodology (`github.com/KJ5HST/methodology`) -- personal
  reference material, not genetics/package content, distinct from the existing 4 gitignored files
  (copyrighted scientific papers). The 4th file, `~$e Compounding Loop.html`, was confirmed via
  byte inspection to be a content-less Microsoft/LibreOffice editor lock file (162 B, the owner's
  own name in the binary lock-file format), never committed (`git log` empty). Owner decision (via
  `AskUserQuestion`): gitignore + `.Rbuildignore` the 3 real files in place, matching the
  established S479/S497/S567 precedent (over moving them out of `inst/extdata/reference/`
  entirely, tracking+shipping them, or deleting them outright); deleted the lock file
  unconditionally. Added a new, distinct comment block to both `.gitignore` and `.Rbuildignore`
  (not merged into the existing NIHMS/copyrighted-paper blocks, whose rationale doesn't apply to
  this file's actual nature) -- wrote the `.Rbuildignore` comment paren-free from the start,
  applying S567's own documented gotcha rather than repeating its mistake. Verified via an actual
  `pkgbuild::build()` + tarball-content inspection that all 3 real files are now excluded (the
  NIHMS precedent and the 1 tracked exception both re-confirmed unaffected); `git check-ignore -v`
  confirms all 3 match the new `.gitignore` rule. Full `devtools::check()`: 0 errors, 0 warnings, 0
  notes -- this also resolved the long-standing "checking for portable file names" WARNING every
  recent session had carried forward as pre-existing (these exact files were its cause).
  `BACKLOG.md` updated in place (the item marked RESOLVED). Incidentally found, reported (not
  fixed): an empty, untracked `inst/extdata/reference/untitled folder` directory (dated the same
  day as the Compounding Loop files) surfaced in this session's own build log -- added as a new
  `BACKLOG.md` Housekeeping item. No TDD phase gate applies (no production `R/` code changed --
  config-only, plus deleting one content-less file). Commits: `794e095c` (claim) + this close-out
  commit.

### 2026-08-14 · [BL-N] S568: claim session (Compounding Loop reference files build-ignore decision)
- **Deliverable:** Claim stub for deciding the disposition of the 4 untracked "Compounding Loop"
  files in `inst/extdata/reference/`, flagged S567 as bundled into every built package tarball.
  Commit: `794e095c`.

### 2026-08-14 · [ad hoc] S567: reconcile HANDOFFS.md commit self-reference (`9a721a1d`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `619ffd98` (the close-out commit whose sha the receipt itself couldn't name until after
  it was made) -- the standard self-reference limitation, reconciled immediately, matching
  the S562/S563/S564/S565/S566 precedent.

### 2026-08-14 · [BL-N] S567: close out (kinship2 supplement PDF copyright classification resolved)
- **Deliverable:** Resolved the copyright/licensing classification of
  `inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf` (kinship2's own supplementary
  material), unresolved since S545. Owner decision (via `AskUserQuestion`): gitignore it,
  matching the S479/S497 precedent for this directory -- it is an NIHMS/PMC deposit (free
  reading access under NIH's public-access policy) but that isn't confirmed to carry
  third-party redistribution rights, so it is excluded from this PUBLIC repo out of the same
  caution as the 3 already-gitignored files, not because it fails their "no open-access
  marking" test. Added a distinguishing comment (not merged into the existing 3-file comment,
  which would have made that comment's own rationale inaccurate) to both `.gitignore` and
  `.Rbuildignore`. Caught and fixed a real bug in my own first edit: `.Rbuildignore` treats
  every line, including `#` comments, as a Perl regex (the file's own header warns of this
  exactly), and my first comment's parenthetical text had an unbalanced paren split across
  lines, aborting `R CMD build` with a PCRE compilation error -- caught immediately by actually
  running the build, not assumed safe. Verified via an actual `R CMD build`/`pkgbuild::build()`
  that the file is excluded from the built tarball (matching the other 3 precedent files;
  `Master_Genetic_metrics_2_14_15.pdf`, the one tracked exception, still ships as expected). Full
  `devtools::check()`: 0 errors, 1 warning (non-portable "Compounding Loop" filenames --
  confirmed pre-existing/unrelated, same finding as every recent session), 0 notes. `BACKLOG.md`
  updated in place (the item's trailing "Note" marked RESOLVED). Incidentally found, reported
  (not fixed): that same tarball inspection showed the untracked "Compounding Loop" files (the
  source of the portable-file-names warning) ARE bundled into the built tarball, unlike the
  deliberately excluded reference PDFs -- added as a new `BACKLOG.md` Housekeeping item. No TDD
  phase gate applies (no production `R/` code changed -- config-only). Commits: `1b84ca97`
  (claim) + this close-out commit.

### 2026-08-14 · [BL-N] S567: claim session (resolve NIHMS593658 PDF copyright classification)
- **Deliverable:** Claim stub for resolving the kinship2 supplement PDF's copyright/licensing
  classification, flagged unresolved in every session since S545. Commit: `1b84ca97`.

### 2026-08-14 · [ad hoc] S566: reconcile HANDOFFS.md commit self-reference (`d0390201`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `d0390201` (the close-out commit whose sha the receipt itself couldn't name until
  after it was made) -- the standard self-reference limitation, reconciled
  immediately, matching the S562/S563/S564/S565 precedent.

### 2026-08-14 · [BL-N] S566: close out (kinship2 supplement full-reproduction plan fully RESOLVED -- GitHub issues filed+closed, fidelity validation article published)
- **Deliverable:** Filed and closed 3 GitHub issues (`#156` Track A/X-chromosome kinship,
  `#157` Track B/`shrinkPedigree()`, `#158` Track C/consanguineous-marker propagation), each
  citing its implementing commit (`7bbc6273`/`f68a24ff`/`89be00ca`) and this session's own
  independent re-verification. New `data-raw/kinship2FidelityValidation.R` computes each
  track's numeric/graphic comparison live against the installed (non-dependency) kinship2
  1.9.6.2, reusing each track's own already-committed test fixture verbatim (`fam1` from
  `test_kinship.R`; the 16-subject composite from `test_shrinkPedigree.R`; the 9-subject dogleg
  fixture from `test_makePedigreeMatingLayout.R`), and writes 8 PNGs. New
  `vignettes/articles/kinship2-fidelity-validation.qmd` (matching
  `vignettes/articles/fg-se-validation.qmd`'s own precedent) embeds the results as frozen
  tables/images -- **all 3 tracks came back exact matches**: Track A's autosomal and X-linked
  kinship matrices are bit-for-bit identical to kinship2's own output (max abs diff = 0 across
  200 compared cells); Track B's `shrinkPedigree()` reproduces kinship2's exact surviving
  subject set and exact `bitSize` trajectory on a 16-subject fixture, shown as before/after
  pedigree diagrams from both packages; Track C's consanguineous marker flags the same union
  kinship2 flags under both edge styles (2 marked edges direct, 3 rectilinear). Caught and
  fixed 2 real bugs by re-running and inspecting actual script output, not by trusting a
  plausible-looking fix: kinship2's stricter sire=male/dam=female pedigree validation rejected
  2 fixtures' guessed `sex` values (fixed without altering the nprcgenekeepr-side fixtures
  themselves); a `lintr`-suggested `%in%` -> `==` rewrite silently inflated an edge count from
  2/3 to 14/10 via `NA`-comparison rows (fixed with an explicit `!is.na()` guard) -- see
  `PROJECT_LEARNINGS.md`-bound gotchas in `HANDOFFS.md`'s own S566 receipt. Also fixed a Quarto
  `<basename>_files/`-suffix directory-naming collision found via an actual failed
  `quarto render`. `lintr::lint_package()` 0 lints (24 fixed on the new script);
  `spelling::spell_check_package()` 0 new flags (4 words added to `inst/WORDLIST`
  `LC_ALL=C`-positioned, 1 resolved by rewording to an already-accepted synonym);
  `devtools::check()` 0 errors, 1 warning + 1 note, both confirmed pre-existing/unrelated
  (untracked "Compounding Loop" files' non-portable names; a pre-existing `vignettes/figure/`
  knitr leftover). Updated `BACKLOG.md`'s kinship2 plan tracker item to RESOLVED with the full
  summary; added `articles/kinship2-fidelity-validation` to `_pkgdown.yml`'s `articles:`
  `contents:` navbar list. Incidentally found, reported (not fixed): that same list is missing
  `articles/pedigree-diagram` -- logged as a new `BACKLOG.md` Housekeeping item. **The kinship2
  supplement full-reproduction plan is now FULLY closed out** (all 3 tracks implemented S563-
  S565, all 3 issue-tracked and independently fidelity-verified S566). See `SESSION_NOTES.md`,
  `HANDOFFS.md`, `BACKLOG.md`.
- **Model:** Claude Sonnet 5.

### 2026-08-14 · [BL-N] S566: claim session (close out kinship2 supplement full-reproduction plan: file GitHub issues for Tracks A/B/C + publish a numeric+graphic fidelity validation article)
- **Deliverable:** Phase 0 orient complete (Health 96/100, 0 High+ risk; `shinytest2.yaml`
  scheduled CI red 2 consecutive runs [2026-08-12, 2026-08-13] after 8 straight prior green,
  reported not diagnosed; 60 commits unpushed, unchanged pattern; ledger reconcile --
  `CHANGELOG.md`/`HANDOFFS.md` frontiers both == `HEAD`, no gap, no backfill needed; no ghost
  session -- 6 untracked files individually assessed, none reads as an undocumented deliverable).
  Priorities list (2 numbered items) rendered via `AskUserQuestion` -- owner picked "file GitHub
  issues for kinship2 supplement Tracks A/B/C" (all 3 now complete: C S563, A S564, B S565), then
  directed the deliverable be expanded to also include a numeric+graphic fidelity validation
  article comparing nprcgenekeepr against kinship2, matching the existing
  `vignettes/articles/fg-se-validation.qmd` precedent. Owner confirmed via a follow-up
  `AskUserQuestion`: 3 separate GitHub issues, one per track, each filed then immediately closed
  citing its commit/`CHANGELOG.md` entry (matching the established #142/#143/#144 close-out
  precedent). Claim stubs written to `SESSION_NOTES.md`/`HANDOFFS.md` (`status: pending`). Work
  beginning.

### 2026-08-14 · [ad hoc] S565: reconcile HANDOFFS.md commit self-reference (`f68a24ff`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `f68a24ff` (the close-out commit whose sha the receipt itself couldn't name until
  after it was made) -- the standard self-reference limitation, reconciled
  immediately, matching the S562/S563/S564 precedent.

### 2026-08-14 · [BL-N] S565: close out (Track B of kinship2 supplement full-reproduction plan DONE -- all 3 tracks now complete)
- **Deliverable:** New `R/shrinkPedigree.R`: `shrinkPedigree(ped, genotyped,
  affected = NULL, maxBits = 16L)`, a `kinship2::pedigree.shrink()` equivalent over
  this package's own `id`/`sire`/`dam` data-frame pedigree representation. All 8 of
  kinship2's own internal helpers deparsed directly from the installed namespace
  (1.9.6.2) at Pre-RED, including the 2 the plan itself flagged as undeparsed. 5
  findings beyond the plan's own framing (documented in the function's own roxygen
  and `PROJECT_LEARNINGS.md` Learnings 571-572): `excludeStrayMarryin` ignores
  `genotyped` entirely; `excludeUnavailFounders` requires exactly-one-child AND
  neither-parent-remarried; `NA` affected status counts as unaffected; a
  single-known-parent individual would crash a literal port (kinship2's own
  `pedigree()` forbids that input shape; this package's data model allows it) --
  handled conservatively instead; and kinship2's own `idTrimmed`/`idList$affect`
  silently omit cascade-removed ids in the affected-priority tier (confirmed live
  via a dedicated fixture) -- `shrinkPedigree()` deliberately fixes this
  bookkeeping gap. Deterministic lowest-id (string-sorted) tie-break (D-B2)
  confirmed against a fixture proven live to be a genuine tie in kinship2's own
  `runif()`-based reference. 14 `test_that()` blocks (20 expectation markers) in
  new `tests/testthat/test_shrinkPedigree.R`, every hardcoded expected value
  independently verified live against installed `kinship2`, not hand-derived.
  `devtools::check()` 0 errors, 1 warning + 1 note, both confirmed pre-existing via
  `git stash`; full clean regression 1 pre-existing failure
  (`test_wordlist_coverage.R`, confirmed unrelated); `lintr::lint_package()` 0
  lints. Fixed 2 real gaps found by `devtools::check()`: `_pkgdown.yml` reference
  coverage (added `shrinkPedigree` to 2 groups) and a new spelling flag
  (`orchestrator`, `inst/WORDLIST`). `NEWS.Rmd` entry added. **All 3 tracks of the
  kinship2 supplement full-reproduction plan are now DONE** (C: S563, A: S564, B:
  S565); none has a GitHub issue yet. See `SESSION_NOTES.md`, `HANDOFFS.md`,
  `BACKLOG.md`.
- **Model:** Claude Sonnet 5.

### 2026-08-13 · [BL-N] S565: claim session (implement Track B of kinship2 supplement full-reproduction plan)
- **Deliverable:** Phase 0 orient complete (Health 96/100, 0 High+ risk; scheduled
  `shinytest2.yaml` CI still red, unchanged/undiagnosed since S548, reported not
  diagnosed; 57 commits unpushed, unchanged precedent since S548; ledger reconcile --
  `CHANGELOG.md`/`HANDOFFS.md` frontiers both == `HEAD`, no gap, no backfill needed;
  no ghost session -- same 6 untracked files S564 already flagged, unchanged). Cross-
  checked the ratified genetic-metrics sequencing audit's own prose order (per
  `CLAUDE.md`'s sequencing-audit-cluster check) -- surfaced issue #148 (DECISION
  NEEDED, needs its own scope-narrowing conversation) as a priorities-list option.
  Priorities list (4 items) rendered via `AskUserQuestion` -- owner picked Track B
  (`shrinkPedigree()`, a `pedigree.shrink()` equivalent) of the ratified kinship2
  supplement full-reproduction plan (`docs/planning/kinship2-supplement-full-
  reproduction-plan.md` §4). Claim stubs written to `SESSION_NOTES.md`/`HANDOFFS.md`
  (`status: pending`). Work beginning.

### 2026-08-13 · [BL-N] S564: claim session (implement Track A of kinship2 supplement full-reproduction plan)
- **Deliverable:** Phase 0 orient complete (Health 96/100, 0 High+ risk; `shinytest2.yaml`
  scheduled CI red 2 days running, reported not diagnosed; 54 commits unpushed, unchanged
  precedent since S548; no ghost session, no ledger reconcile needed). Priorities list
  rendered via `AskUserQuestion` -- owner picked Track A (X-chromosome kinship, Table S2)
  of the ratified kinship2 supplement full-reproduction plan
  (`docs/planning/kinship2-supplement-full-reproduction-plan.md` §3). Confirmed
  `R/kinship.R`'s current `kinship()` signature matches the plan's stated baseline (no
  drift since S562 ratification). Claim stubs written to `SESSION_NOTES.md`/`HANDOFFS.md`
  (`status: pending`). Work beginning.

### 2026-08-13 · [ad hoc] S564: reconcile HANDOFFS.md commit self-reference (`7bbc6273`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `7bbc6273` (the close-out commit whose sha the receipt itself couldn't name until
  after it was made) -- the standard self-reference limitation, reconciled
  immediately, matching the S562/S563 precedent.

### 2026-08-13 · [BL-N] S564: close out (Track A of kinship2 supplement full-reproduction plan DONE)
- **Deliverable:** `kinship()` gained `chrtype = c("autosome", "x")` and `sex`
  arguments (Track A, `docs/planning/kinship2-supplement-full-reproduction-plan.md`
  §3) -- X-chromosome kinship reproducing the kinship2 supplement's Table S2, core
  algorithm only per ratified D-A2 Option A. Full PRE-RED→RED→GREEN TDD cycle, each
  transition `AskUserQuestion`-gated; REFACTOR skipped (owner choice, matching Track
  C's own precedent).
- **PRE-RED finding beyond the plan's own framing:** Table S2's printed values
  already embed the MZ-twin correction (Figure S1 declares subjects 8/9 identical
  twins) -- one fixture satisfies both "reproduce Table S2" and the plan's
  separately-listed "combined X-linked + MZ-twin" coverage requirement. Full 10x10
  matrix transcribed via `pdftotext -layout` against
  `inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf` and
  cross-validated by hand-porting kinship2's own algorithm against the installed
  `kinship2` 1.9.6.2.
- **Fix:** `chrtype = "autosome"` (default) is byte-identical to every prior call
  site (pinned by `expect_identical()`); the new `chrtype = "x"` branch reuses the
  existing MZ-twin `mzgrp`/`mzindex` correction unchanged.
- **Tests:** 6 new `test_that()` blocks in `tests/testthat/test_kinship.R` (Table S2
  reproduction; twin-correction isolation; backward-compat pin; `sex`/`chrtype`
  validation; unknown-sex NA propagation), all confirmed failing for the right
  reason against unmodified source before GREEN.
- **Verify:** `devtools::check()` 0 errors, 1 warning + 1 note, both confirmed
  pre-existing/unrelated via `git stash` (matches Track C's S563 findings exactly);
  full clean regression 1 pre-existing failure (`test_wordlist_coverage.R`,
  confirmed via `git stash`); 2 new spelling flags from a new `@references`
  citation fixed via `inst/WORDLIST` (not left as debt); `lintr::lint_package()` 0
  new lints (2 introduced suppressed via documented `# nolint`, matching file
  convention; 5 pre-existing confirmed via `git stash`, left untouched).
- **Docs:** `NEWS.Rmd` entry added; roxygen `@references` added citing the kinship2
  supplement source; `BACKLOG.md`'s kinship2 plan tracker annotated (Track B remains
  open); `PROJECT_LEARNINGS.md` Learning 570 logged (`devtools::check()`'s
  `man/*.Rd` regeneration is not reliably synced to a pre-launch `document()` call --
  always `document()` immediately before each `check()` launch). Not filed as a
  GitHub issue, matching Track C's own precedent.

### 2026-08-13 · [ad hoc] S563: reconcile HANDOFFS.md commit self-reference (`89be00ca`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `89be00ca` (the close-out commit whose sha the receipt itself couldn't name until after it
  was made) -- the standard self-reference limitation, reconciled immediately (matching the
  S562 precedent), not left for a future session's Phase 0 reconcile-on-read.

### 2026-08-13 · [BL-N] S563: close out (Track C of kinship2 supplement full-reproduction plan DONE)
- **Deliverable:** `edgeStyle="rectilinear"` consanguineous-marker color/width now survives a D2
  dogleg reroute in `R/makePedigreeDiagramData.R`'s `.addRectilinearWaypoints()` (Track C,
  `docs/planning/kinship2-supplement-full-reproduction-plan.md` §5; S549 Finding #2's deferred
  follow-up, S555). Full PRE-RED→RED→GREEN TDD cycle, each transition `AskUserQuestion`-gated;
  REFACTOR skipped (owner choice, diff already minimal).
- **Fix:** the D2 loop looks up a dropped mate edge's own color/width (keyed by the dogleg's
  `projId`) and applies it as a post-hoc override after the existing generic-fallback assignment
  — required by `do.call(rbind, newEdgeList)`'s column-alignment constraint across D1/D2 edge
  types, a structural wrinkle the originating plan did not anticipate.
- **Fixture:** the plan's referenced "12-row fixture" was never committed as code — read
  `.buildMatingUnitForest()`'s anchor-selection algorithm directly from source and built an
  independently-verified 9-row equivalent, correct on the first attempt (`PROJECT_LEARNINGS.md`
  Learning 569).
- **Verification:** 1 new `test_that()` block (5 assertions,
  `tests/testthat/test_makePedigreeMatingLayout.R`) confirmed RED then GREEN; sibling
  `test_addRectilinearWaypoints.R` unaffected; full clean regression 1 pre-existing failure
  (`test_wordlist_coverage.R`, confirmed via `git stash` unrelated to this diff);
  `lintr::lint_package()` 0 lints on touched files; `devtools::check()` 0 errors, 1 warning + 1
  note, both confirmed pre-existing/unrelated (untracked "Compounding Loop" files' non-portable
  names; a pre-existing `vignettes/figure/` knitr leftover).
- **Docs:** `NEWS.Rmd` entry added; `BACKLOG.md`'s S555 deferred-follow-up item annotated
  `FIXED S563`; the kinship2 plan's Track C clause annotated `DONE S563` (Tracks A/B remain
  open, no GitHub issue filed yet for any of the 3 tracks). **Model:** Claude Sonnet 5.

### 2026-08-13 · [BL-N] S563: claim session (implement Track C of kinship2 supplement full-reproduction plan)
- **Deliverable:** Implement Track C (`docs/planning/kinship2-supplement-full-reproduction-plan.md`
  §5) — finish `edgeStyle="rectilinear"` consanguineous-marker color/width propagation onto D2
  dogleg-rerouted projection edges in `R/makePedigreeDiagramData.R`'s
  `.addRectilinearWaypoints()`. Claim only; work in progress, strict TDD
  (PRE-RED→RED→GREEN→REFACTOR), each transition gated by `AskUserQuestion`.

### 2026-08-13 · [ad hoc] S562: reconcile HANDOFFS.md commit self-reference (`0ce5ac60`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `0ce5ac60` (the close-out commit whose sha the receipt itself couldn't name until
  after it was made) -- the standard self-reference limitation, reconciled immediately
  rather than deferred to a future session's Phase 0.
- **Commit:** `8a6cf5e7`.

### 2026-08-13 · [BL-N] S562 close-out: kinship2 supplement PDF full-reproduction plan RATIFIED; Learning 568 logged
- **Deliverable:** `docs/planning/kinship2-supplement-full-reproduction-plan.md` (~600
  lines) -- a plan to fully reproduce `NIHMS593658-supplement-supplement_1.pdf`'s
  results, following up on the S549 audit's own "no action" verdict on 2 of its 4
  findings, at explicit owner direction. 3 independently session-sliceable tracks:
  Track A (X-chromosome kinship, `kinship()` gains `chrtype`/`sex`, core-algorithm-only
  scope); Track B (a new `shrinkPedigree()` function porting kinship2's own
  `pedigree.shrink()` 5-helper algorithm, script-callable only, deterministic
  tie-break); Track C (finish the `edgeStyle="rectilinear"` consanguineous-marker
  color/width propagation). All 4 judgment-call questions ratified via one
  `AskUserQuestion` call -- owner selected the plan's own recommended option in every
  case. `BACKLOG.md` Housekeeping gained a new pointer item. No `R/`/`tests/`/`man/`
  content changed -- this session is design-only, matching the S550 twin-kinship plan's
  own precedent that ratification closes the design session, not the implementation
  one. `PROJECT_LEARNINGS.md` Learning 568 logged (the session's own scope-arc
  process learning: a request phrased as a question about a past session's output is
  not itself a scope signal for the current one). `CLAUDE.md` learnings-count pointer
  refreshed (568, ~2.3 MB).
- **Verification:** N/A build-equivalent for a planning document (no code/tests to
  run); Phase 3E runtime smoke test N/A, stated explicitly (no R/ package code
  changed).
- **Commit:** this session's own close-out commit.

### 2026-08-13 · [BL-N] S562: claim session (plan to fully reproduce kinship2 supplement PDF's results)
- **Deliverable:** Phase 1B claim. Write a plan document to fully reproduce
  `inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf`'s results with
  `nprcgenekeepr` -- X-chromosome kinship (Table S2), a `pedigree.shrink()` equivalent, and
  the `edgeStyle="rectilinear"` consanguineous-marker propagation follow-up (the 2 items
  `docs/audits/KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md` judged out of scope
  plus the 1 remaining partial gap).
- **Commit:** this claim's own commit.

### 2026-08-13 · [BL-N] S561 close-out: HANDOFFS.md FRONTMATTER_FIELD_ABSENT finding resolved; Learning 567 logged
- **Deliverable:** Session S561's own close-out. Evaluated S560's `HANDOFFS.md` receipt (9/10
  -- `next_steps` named this exact item verbatim as item 2 of its priority list; nothing found
  inaccurate; `gotchas` had no way to anticipate this session's actual pitfall, a stale
  tool-behavior claim in `BACKLOG.md`'s own prose). Added "This file currently holds **3**
  receipt(s)." to `HANDOFFS.md`'s front matter (owner-picked remedy via `AskUserQuestion`),
  verified via a direct unit-check of `methodology_trim.py`'s own compiled regex plus a
  dry-run `--cut @<sha>` record-count confirmation (the live archive trigger doesn't fire this
  session, so a real `--write` couldn't verify it directly). Found and corrected a stale claim
  in the process: `methodology_trim.py`'s `--check` path structurally cannot reach
  `apply_regenerated()` (it returns before the archive-plan-building code that calls it) --
  only a real `--write` that builds an archive plan does, contradicting the original S508
  finding's "every check/write run" framing. Logged as `PROJECT_LEARNINGS.md` Learning 567;
  `BACKLOG.md` item annotated RESOLVED in place with the corrected framing; `CLAUDE.md`'s
  learnings-count pointer refreshed (561+ sessions, 567 learnings). Self-assessed 9/10 --
  caught and corrected its own initial N=2-vs-3 counting mistake (the Phase 1B claim stub is
  itself a live receipt) via the tool's own record parser rather than trusting a hand
  computation; stayed scoped to the one decision, deferring the adjacent
  `edgeStyle="rectilinear"` tag-gap finding to a future session. Runtime smoke test: n/a --
  docs/config-only change, no R package or Shiny code touched. 45+ local commits remain
  unpushed (unchanged, deferred again per the S548-onward precedent).
- **BACKLOG.md:** resolves the S508/S559 `HANDOFFS.md` regenerated-field item.

### 2026-08-13 · [BL-N] S561: claim session (resolve HANDOFFS.md FRONTMATTER_FIELD_ABSENT finding)
- **Deliverable:** Phase 1B claim stub only. Session 561 will add a self-updating "This file
  currently holds **N** receipt(s)" sentence to `HANDOFFS.md`'s front matter, resolving the
  recurring `FRONTMATTER_FIELD_ABSENT` finding `methodology_trim.py` prints on every
  `--check`/`--write` run against `HANDOFFS.md` (`BACKLOG.md` Housekeeping, found S508,
  re-surfaced S559). Remedy confirmed via `AskUserQuestion`: add the front-matter sentence
  (over removing the `regenerated` entry from `methodology_trim.py`'s `LEDGERS["HANDOFFS.md"]`
  config).

### 2026-08-13 · [BL-N] S560 close-out: Pedigree Diagram article shipped; S559 handoff evaluation; Learning 566 logged
- **Deliverable:** Session S560's own close-out. Evaluated S559's `HANDOFFS.md` receipt
  (9/10 -- its `next_steps` field named this exact item verbatim as item 1 of its priority
  list, followed as the literal picked option; nothing found inaccurate; `gotchas` had no way
  to anticipate this session's screenshot-legibility pitfall, not a real gap). Self-assessed
  9/10 (full breakdown in `SESSION_NOTES.md`/`HANDOFFS.md`). Logged
  `PROJECT_LEARNINGS.md` Learning 566 (screenshot-legibility fix via focal-animal trimming +
  the node-radius/edge-length occlusion geometry finding) and refreshed `CLAUDE.md`'s
  learnings-count pointer (560+ sessions, 566 learnings, ~2.3 MB). Compressed both resolved
  `BACKLOG.md` Housekeeping items (the S461 stale-screenshot item and this session's own
  S544 article item) to the file's established short-pointer convention.

### 2026-08-13 · [BL-N] S560: write vignettes/articles/pedigree-diagram.qmd (new dedicated Pedigree Diagram tab article)
- **Deliverable:** New dedicated article `vignettes/articles/pedigree-diagram.qmd` (9
  sections: Overview, Node shapes/legend, Diagram Edge Style, Consanguineous marker,
  Affected-status shading, Showing names, Twin/zygosity relations, Interacting with the
  diagram, Script-callable equivalent, See also) documenting the Pedigree Diagram tab's full
  current feature set, matching the established per-tab-article convention
  (`age-sex-pyramid.qmd`/`genetic-value-analysis.qmd`/`breeding-group-formation.qmd`).
  New `vignettes/articles/pedigree-diagram-screenshots.R` (a `shinytest2::AppDriver`
  screenshot-generation script, one fresh `AppDriver` per bundled example fixture) produced 5
  screenshots, each trimmed to a small feature-relevant subgraph via the Diagram tab's own
  Focal Animals + Trim Pedigree controls (a first full-fixture pass was functionally correct
  but visually illegible -- see Learning 566). Regenerated `pb_diagram_legend.png` in place
  (Option 2 mating-unit convention, resolving the S461 stale-screenshot item) and fixed
  `colony-manager-guide.qmd`'s own stale pre-Option-2 opening sentence, added a twin-
  connectors mention and a pointer to the new article, and added the new article to the
  Section 2 function-group table (row 2, Pedigree Browser). Updated `a2interactive.Rmd`'s own
  cross-reference to point to the new article instead of `colony-manager-guide.qmd`'s
  paragraph. **Verification:** `quarto render` clean on both `.qmd` files (both fully
  build-ignored via `^vignettes/articles$` in `.Rbuildignore`, so neither reaches
  `R CMD check`); a targeted `rmarkdown::render()` on `a2interactive.Rmd` (the one real,
  non-ignored CRAN vignette touched) confirmed it still knits cleanly end-to-end;
  `lintr::lint_package()` 0 lints (the new `.R` script lives under `vignettes/`, already
  excluded from `.lintr`'s own scan scope). Phase 3E runtime smoke test: n/a, stated
  explicitly -- no R/ package code changed. Not a TDD-gated session (documentation only).
- **BACKLOG.md:** resolves both the S544 dedicated-article item and the S461
  stale-screenshot item it subsumes (see close-out entry above for the compression).

### 2026-08-13 · [BL-N] S560: claim session (write vignettes/articles/pedigree-diagram.qmd)
- **Deliverable:** Phase 1B claim stub only. Session 560 will write a new dedicated article,
  `vignettes/articles/pedigree-diagram.qmd`, documenting the Pedigree Diagram tab's full
  current feature set (BACKLOG.md Housekeeping, found S544, owner-directed) with
  freshly-captured live-app screenshots via a `shinytest2::AppDriver` script (matching
  `colony-manager-guide-screenshots.R`'s pattern) -- also resolving the separately-flagged
  stale `pb_diagram_legend.png` item. Doc-location and screenshot-capture scope confirmed via
  `AskUserQuestion` (new dedicated article; yes, capture fresh screenshots).

### 2026-08-13 · [ad hoc] S560 Phase 0 reconcile: S559's HANDOFFS.md commit self-reference
- **Deliverable:** Phase 0 ledger reconcile (`SESSION_RUNNER.md` step 6). S559's `HANDOFFS.md`
  receipt shipped with `commit: pending` -- the standard self-reference limitation (the receipt
  ships in the very commit whose sha it would name), matching the S543-S545/S549-S553/S558-S559
  precedent each prior session reconciled at its own claim. `HANDOFFS.md`'s frontier (`git log -1
  -- HANDOFFS.md`) == `abf1a984` (S559's own close-out commit), so reconciled `commit: pending` ->
  `abf1a984`. `CHANGELOG.md`'s own frontier == `HEAD` already (zero-commit gap, no backfill
  needed). `gh run list --branch master --limit 10` showed the scheduled `shinytest2.yaml` run
  still red (23m52s, 2026-08-13T07:32:33Z), unchanged from S548-S559's own findings -- not
  diagnosed this session (report, don't fix, per established precedent).
- **Commit:** this reconcile's own commit.

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

