# Handoff Receipts — durable close-out proof

The cumulative, append-only record of **each session's close-out handoff**, distilled into a
machine-checkable block. It is the durable answer to *"was close-out actually performed, and what
did the session hand its successor?"* — the part of close-out that otherwise lives only in the
transient `SESSION_NOTES.md` (overwritten every session) or the spoken report (which leaves no file
at all).

One `handoff` block per **session** (not per commit), newest on top. The canonical-only
`bin/check-handoff` (copy it into your `bin/` if you want the structural check) asserts each block is
present and structurally complete; the next session's Phase 0 reconcile greps this file for a missing
or still-`pending` receipt and backfills it — that reconcile, not the checker, is the dependable
backstop, so the discipline needs no tooling. Together — a write-step at close-out **and** a
reconcile-on-read backstop — this makes a skipped handoff *detectable* rather than silent.

> **A green `bin/check-handoff` is not a good handoff.** The check verifies presence and structure,
> never semantic quality. Faithfulness is still scored 1–10 by the next session (Phase 3A). A
> well-formed but hollow receipt passes the check and is caught only by that human judgement.

## How to write a receipt

**At Phase 1B (claim the session)** — write the stub block below with `status: pending`, filling what
you can, and commit it with your session-claim commit. This committed `pending` block is the crash
breadcrumb: if the session ends before close-out, the next session's Phase 0 reconcile sees it.

**At Phase 3D (close-out)** — overwrite that block in place to `status: complete` and fill every
field. The block must satisfy all six Minimum Handoff Requirements (`SESSION_RUNNER.md` §3D).

## Format — a fenced `handoff` block

````
```handoff
session: S<N>
date: YYYY-MM-DD
status: <pending | complete>
self_score: <1-10>
predecessor_score: <1-10>
active_task: <current state>
what_was_done: <what you did, including a commit sha — or the literal `pending`>
next_steps: <specific and actionable; never "pick next from backlog">
key_files: <each entry carries a path:line token, e.g. SessionManager.java:245>
gotchas: <traps the next session should watch for>
runtime_smoke: <a run result, or "n/a — docs-only", or "impossible: <reason>">
changelog_ref: <PR #N or a short-sha into CHANGELOG.md>
commit: <short-sha — or `pending` until the next session reconciles it>
```
<free-text prose: the durable proxy for the Phase 3G spoken report, plus the +/- self-score breakdown>

Write clean `key: value` lines — no inline `#` comments (a `#` is a literal value character,
as in `changelog_ref: PR #52`). The keys are the six Phase 3D Minimum Handoff Requirements (the sixth
*is* `self_score`) plus `predecessor_score` (the Phase 3A evaluation) and a little metadata. `status`
is `pending` at the Phase 1B claim and `complete` at
close-out; a third value, `reconciled`, is written *only* by a later session's Phase 0 reconcile
when it reconstructs a receipt a crashed session never completed — you never write it yourself.
````

`self_score` and `predecessor_score` are distinct keys so one can never stand in for the other; omit
`predecessor_score` on Session 1 (there is no predecessor to score). `commit: pending` and
`what_was_done: pending` are legal at write time (the receipt ships in the very commit whose sha it
would name); the next session reconciles them to real shas.

## Size, and when to archive

This file gains a receipt every session and Phase 0 reads it every session, so it carries the same
size discipline as `CHANGELOG.md`: **two caps, two distinct failure modes, fire if either fires,
stop only when both stop conditions hold.**

| Cap | Protects against | Form | Fire when | Cut until |
|---|---|---|---|---|
| **Lines** — ~2,000, the agent `Read` truncation cap | **silent truncation**: a read past the cap returns no error and no marker | a **rate** | headroom < **15** receipts | headroom > **30** |
| **Bytes** — a per-file budget, default **65,536 B** (64 KB) | **context tax**: every session pays for the whole file, every time | a **level with hysteresis** | `size > budget` | `size ≤ ½ × budget` |

**Run this rather than estimating it:**

```sh
python3 methodology_trim.py --file HANDOFFS.md --check
```

`--check` evaluates both conditions and never writes. `--write` performs the trim, refuses unless it
can prove the split lossless, and **neither commits nor stages** — it leaves this file modified and
the new shard *untracked*, and leaves the commit to you (`git add HANDOFFS.md docs/archive/`).

An archive is a **shard**: a new frozen file, same format, same newest-on-top order.

- **Path: `docs/archive/HANDOFFS-through-<CUT-KEY>.md`.** Both halves are load-bearing — the
  directory keeps the shard from shadowing this file, and the `HANDOFFS-` prefix is what the
  trigger's own glob looks for. A shard named otherwise is silently invisible to it.
- **This file keeps one short pointer** naming each shard, the span it covers and how many receipts
  it holds — with the command that recomputes those counts, never a hand-maintained number.
- **The shard back-links here and states only facts about itself.** It must not restate a
  forward-looking rule: a shard is frozen, so a rule copied into one cannot be corrected when the
  live rule moves.
- **After a split, anything that enumerates receipts must span both** — `HANDOFFS.md
  docs/archive/HANDOFFS-*.md` — or it silently counts a shrunken population.

If a `CHANGELOG.md` sits beside this file, its own **Size, and when to archive** section carries the
reasoning both files share: why the line cap must be a rate, why the byte cap cannot be one, and how
to choose the budget. Everything needed to *act* is here.

What is specific to *this* file, and gets receipts wrong if assumed:

- **A record is a `handoff` block *plus the prose beneath it*, not the fence alone.** The self-score
  and predecessor-score paragraphs sit outside the fence and belong to the receipt above them. A
  fence-only cut severs every receipt from its own scoring.
- **Archive oldest-first by position, never by sorting on `session:`.** Two independent `S<N>`
  sequences can share one ledger — a fork and its upstream each running their own counter — and
  their numbers collide. The record's identity is **session + date**.
- **A trim leaves the newest-receipt check alone and moves what the older-receipt checks see.**
  Phase 0 reconcile is frontier-based and a structural checker applies the full schema to the newest
  receipt only, so neither is disturbed. Its other passes are not so confined — an answer-slot rule
  reads every receipt below the newest, and a locator-form rule reads every receipt in the file. So
  after a trim, **run the checker against each shard as well**, and recompute any "all N older
  receipts" count from the files rather than carrying it forward.
- **Never trim to zero receipts.** An empty receipt ledger is indistinguishable from a broken one.
- **A shard freezes, with one exception this file needs:** a `commit:` answer slot may still be
  reconciled inside an archived receipt, because that field was always going to be filled by a later
  session. Nothing else in a shard is rewritten.

**Archived 181 record(s), 2026-07-08 → 2026-08-10** into [`docs/archive/HANDOFFS-through-2026-08-10.md`](docs/archive/HANDOFFS-through-2026-08-10.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-10.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-10.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 39 record(s), 2026-08-10 → 2026-08-12** into [`docs/archive/HANDOFFS-through-2026-08-12.md`](docs/archive/HANDOFFS-through-2026-08-12.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-12.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-12.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 17 record(s), 2026-08-12 → 2026-08-13** into [`docs/archive/HANDOFFS-through-2026-08-13.md`](docs/archive/HANDOFFS-through-2026-08-13.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-13.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-13.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

This file currently holds **6** receipt(s). Computed by `methodology_trim.py` on every
`--check`/`--write` run, never hand-maintained.

```handoff
session: S566
date: 2026-08-14
status: pending
self_score: pending
predecessor_score: pending
active_task: File 3 GitHub issues (kinship2 supplement Tracks A/B/C, all now complete),
  each filed then closed citing its commit/CHANGELOG entry; publish a new numeric+graphic
  fidelity validation article (vignettes/articles/kinship2-fidelity-validation.qmd)
  comparing nprcgenekeepr's Track A/B/C outputs against kinship2's own reference outputs,
  matching the fg-se-validation.qmd precedent.
what_was_done: pending
next_steps: pending
key_files: docs/planning/kinship2-supplement-full-reproduction-plan.md (the plan being
  closed out); vignettes/articles/fg-se-validation.qmd (the validation-article
  precedent); R/kinship.R (Track A), R/shrinkPedigree.R (Track B),
  R/makePedigreeDiagramData.R (Track C, .addRectilinearWaypoints())
gotchas: pending
runtime_smoke: pending
changelog_ref: pending
commit: pending
```
<in progress -- claim stub only, full receipt written at close-out>

```handoff
session: S565
date: 2026-08-14
status: complete
self_score: 8
predecessor_score: 9
active_task: Track B of the ratified kinship2 supplement full-reproduction plan --
  DONE. shrinkPedigree() ported. All 3 tracks of the plan are now complete
  (C: S563, A: S564, B: S565).
what_was_done: Full PRE-RED->RED->GREEN TDD cycle (REFACTOR skipped, owner choice),
  each transition AskUserQuestion-gated. PRE-RED deparsed all 8 of kinship2's own
  internal helpers directly from the installed namespace (1.9.6.2), including the 2
  the plan itself flagged as undeparsed -- found 5 things beyond the plan's own
  framing (4 at PRE-RED, 1 more mid-GREEN): excludeStrayMarryin ignores genotyped
  entirely; excludeUnavailFounders requires exactly-one-child AND neither-parent-
  remarried; NA affected status counts as unaffected; a single-known-parent
  individual crashes a literal port (kinship2's own pedigree() forbids that input
  shape, this package's data model doesn't) -- handled conservatively instead,
  documented, tested; and kinship2's own idTrimmed/idList$affect silently omit
  cascade-removed ids in the affected-priority tier (confirmed live via a dedicated
  fixture) -- shrinkPedigree() deliberately fixes this bookkeeping gap.
  PROJECT_LEARNINGS.md Learnings 571/572 logged. RED: 14 new test_that() blocks (20
  expectation markers) in new tests/testthat/test_shrinkPedigree.R, every hardcoded
  expected value independently verified live against installed kinship2, not
  hand-derived; 1 more test added mid-GREEN after finding 5 surfaced. GREEN: new
  R/shrinkPedigree.R (8 functions); first test run caught a test-transcription bug
  (missing affected arg), not an implementation bug -- fixed, all 20 markers pass.
  Verified: full clean regression 1 pre-existing failure (test_wordlist_coverage.R,
  confirmed via git stash unrelated); lintr::lint_package() 0 lints (stripped an
  initial round of unneeded nolint comments that were themselves causing new
  line_length findings); devtools::check() 2 cycles to 0 errors/1 pre-existing
  warning/1 pre-existing note -- 1st cycle found and fixed 2 real gaps
  (_pkgdown.yml reference-coverage missing the new export; a new spelling flag,
  "orchestrator", fixed via inst/WORDLIST). Commits: c1c54cb7 (claim) + this
  close-out commit.
next_steps: All 3 tracks of the kinship2 supplement full-reproduction plan
  (docs/planning/kinship2-supplement-full-reproduction-plan.md) are now DONE.
  None of the 3 has a GitHub issue yet (matches the established "recommend, don't
  unilaterally file" precedent) -- the owner may want to file one (or three)
  retroactively, or decide it's not worth it now that the work is complete.
  Separately, 2 unresolved open items carried forward unchanged from S564: (1)
  inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf (the kinship2
  supplement PDF itself) remains untracked -- a possible copyright/licensing
  question the owner should decide (commit it, gitignore it, or leave local-only).
  (2) shrinkPedigree() (and kinship()'s new chrtype/sex params from Track A) are
  exactly the trigger case for a future a2interactive.Rmd documentation pass
  (deferred by design, per that checklist's own standing rule -- not overdue yet).
  BACKLOG.md priorities otherwise unchanged: LabKey (BLOCKED, Effort M), NPRC
  outreach (DECISION NEEDED, Effort N/A), issue #148 (DECISION NEEDED -- needs its
  own scope-narrowing conversation first).
key_files: R/shrinkPedigree.R (the full Track B implementation -- shrinkPedigree()
  plus 7 internal helpers, extensively documented in its own roxygen); tests/
  testthat/test_shrinkPedigree.R (14 test_that() blocks, 20 expectation markers);
  _pkgdown.yml (shrinkPedigree added to 2 reference groups); inst/WORDLIST
  ("orchestrator" added); NEWS.Rmd (new entry); BACKLOG.md (kinship2 plan tracker,
  Track B annotated DONE, all 3 tracks complete); PROJECT_LEARNINGS.md Learnings
  571-572; docs/planning/kinship2-supplement-full-reproduction-plan.md §4 (the
  spec this session implemented, now fully closed out).
gotchas: (1) kinship2's own findAvailAffected()'s trial-removal loop calls the FULL
  findUnavailable() cascade for each candidate, not a single-row removal --
  measuring bitSize after a candidate's removal means measuring after any
  stray-marryin/childless-non-founder cascade too, not just the candidate alone.
  (2) A test fixture transcribed from a live Pre-RED scratch-verification script
  must carry over EVERY argument used in that verification, not just the ped/
  genotyped shape -- an omitted optional argument with its own non-trivial default
  (affected here) silently changes which code path fires (Learning 572). (3) This
  project's .lintr already allows camelCase (object_name_linter styles =
  snake_case/CamelCase/camelCase) -- do not reflexively add
  `# nolint: object_name_linter` comments by pattern-matching an older file; verify
  the lint actually fires first, since an unneeded nolint comment can itself push a
  line over the 80-char limit and create a NEW finding. (4) cyclocomp_linter is
  explicitly disabled in this project's .lintr (`cyclocomp_linter = NULL`) --
  referencing it in a nolint comment produces a "could not find linter" warning,
  not a suppression. (5) The `&`/`disown` double-backgrounding trap (S563's own
  finding, restated in S564's handoff) still caught this session once -- prefer
  `run_in_background: true` alone, or a Monitor with an explicit completion-check
  loop, never manual `&`/`disown`.
runtime_smoke: No live shinytest2/chromote run this session -- Track B is
  script-callable only (ratified D-B3, no Shiny tab), so there is no runtime/UI
  wiring to smoke-test. Behavior was verified by direct execution instead:
  devtools::check()'s own testthat run exercises every new code path against the
  new test fixtures, and every hardcoded expected value was independently
  cross-validated live against the installed kinship2::pedigree.shrink().
changelog_ref: CHANGELOG.md, S565 entries (claim + close-out, both `[BL-N]`-tagged)
commit: f68a24ff
```

```handoff
session: S564
date: 2026-08-13
status: complete
self_score: 8
predecessor_score: 8
active_task: Track A of the ratified kinship2 supplement full-reproduction plan --
  DONE. kinship() gained chrtype = c("autosome", "x") and sex arguments; Track B
  (a pedigree.shrink() equivalent) remains open.
what_was_done: Full PRE-RED->RED->GREEN TDD cycle (REFACTOR skipped, owner choice),
  each transition AskUserQuestion-gated. PRE-RED transcribed the PDF's full 10x10
  Table S2 via pdftotext -layout and cross-validated it by hand-porting kinship2's
  own X-linked algorithm, run live against the installed kinship2 1.9.6.2 --
  discovered Table S2's own printed values already embed the MZ-twin correction
  (Figure S1's subjects 8/9 are twins), so one fixture satisfies both "reproduce
  Table S2" and the plan's separately-listed "combined X-linked+MZ-twin" coverage
  requirement. RED: 6 new test_that() blocks in tests/testthat/test_kinship.R,
  caught and fixed one vacuous-pass assertion before confirming all 6 fail for the
  right reason. GREEN: new chrtype/sex params, an X-linked depth-loop branch reusing
  the existing MZ-twin mzgrp/mzindex correction unchanged; chrtype="autosome"
  (default) left byte-for-byte untouched, pinned by expect_identical(). Verified:
  targeted tests pass; full clean regression 1 pre-existing failure
  (test_wordlist_coverage.R, confirmed via git stash); lintr::lint_package() 2 new
  lints suppressed via documented # nolint (5 pre-existing left untouched);
  devtools::check() needed 4 cycles to reach 0 errors/1 pre-existing warning/1
  pre-existing note (a real codoc mismatch from a stale man/kinship.Rd, a broken
  \\link{sexCodes} cross-reference, and 2 new spelling flags were each found and
  fixed along the way -- PROJECT_LEARNINGS.md Learning 570 logged on the
  check()/document() sync gap this exposed). Commits: bfd9532f (claim) + this
  close-out commit.
next_steps: Pick up Track B (a pedigree.shrink() equivalent, new shrinkPedigree(),
  Effort L, most novel of the 3 -- its own Pre-RED must first deparse kinship2's
  excludeUnavailFounders/excludeStrayMarryin helpers, not yet done) --
  docs/planning/kinship2-supplement-full-reproduction-plan.md §4. Separate session
  (different capability, never bundled per SESSION_RUNNER.md's vertical-slice rule).
  Neither Track A nor B has a GitHub issue yet -- the owner may wish to file for
  both before further implementation. Separately: an unresolved open item from this
  session -- inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf (the
  kinship2 supplement PDF itself) remains untracked; a possible copyright/licensing
  question the owner should decide (commit it, gitignore it, or leave local-only)
  before more documentation accumulates assuming one answer. BACKLOG.md priorities
  otherwise unchanged: LabKey (BLOCKED, Effort M), NPRC outreach (DECISION NEEDED,
  Effort N/A), issue #148 (DECISION NEEDED -- needs its own scope-narrowing
  conversation first).
key_files: R/kinship.R:79-193 (kinship(), the full Track A diff -- chrtype/sex
  params, X-linked branch, roxygen docs); tests/testthat/test_kinship.R:31-95 (fam1
  fixture + gen column, and the 6 new Track A test_that() blocks); man/kinship.Rd
  (regenerated); NEWS.Rmd (new entry); inst/WORDLIST (2 new proper-noun entries);
  BACKLOG.md (kinship2 plan tracker, Track A annotated DONE); PROJECT_LEARNINGS.md
  Learning 570 (the check()/document() sync gap); docs/planning/kinship2-supplement-
  full-reproduction-plan.md §4 (Track B, the next pickup).
gotchas: (1) Always run devtools::document() manually immediately before every
  devtools::check() launch -- check()'s own man/*.Rd regeneration is not reliably
  synced to a pre-launch document() call (Learning 570); a codoc-mismatch or
  Rd-cross-reference WARNING may just mean "document() wasn't re-run after the last
  edit," not a genuine defect. (2) Do not launch a long-running check() and then
  keep editing roxygen/NEWS.Rmd "while waiting" -- assume any such run is now
  unreliable and re-run after document(). (3) Track B's own Pre-RED must deparse
  excludeUnavailFounders/excludeStrayMarryin before writing RED tests -- still not
  done. (4) Track B naming: use `genotyped`, never `avail`/`available` (collides
  with R/makeAvailable.R's own unrelated breeding-group concept). (5) The
  double-backgrounding pitfall (an `&`-suffixed command inside or alongside a
  run_in_background:true Bash call produces a premature "completed" notification
  while the R process keeps running detached) recurred twice this session despite
  being a documented S563 finding -- prefer run_in_background:true alone, or a
  Monitor with an explicit grep-for-completion-marker loop, never `&`/`disown`.
runtime_smoke: No live shinytest2/chromote run this session -- Track A is
  script-callable only (ratified D-A2 Option A explicitly excludes the Shiny app),
  so there is no runtime/UI wiring to smoke-test. Behavior was verified by direct
  execution instead: devtools::check()'s own testthat run (145s) exercises every
  new code path against the new test fixtures, not merely a build-passes check.
changelog_ref: CHANGELOG.md "S564: close out (Track A of kinship2 supplement
  full-reproduction plan DONE)"
commit: 7bbc6273
```

```handoff
session: S563
date: 2026-08-13
status: complete
self_score: 9
predecessor_score: 7
active_task: Implement Track C of the ratified kinship2 supplement
full-reproduction plan (docs/planning/kinship2-supplement-full-reproduction-plan.md
§5) -- edgeStyle="rectilinear" consanguineous-marker color/width propagation onto D2
dogleg-rerouted projection edges, R/makePedigreeDiagramData.R
.addRectilinearWaypoints(). DONE.
what_was_done: Full PRE-RED->RED->GREEN TDD cycle (REFACTOR skipped, owner choice --
diff already minimal), each transition AskUserQuestion-gated. PRE-RED found the
plan's referenced "12-row fixture" was never committed as code; read
.buildMatingUnitForest()'s anchor-selection algorithm directly from source and built
an independently-verified 9-row equivalent on the first attempt (Learning 569). RED:
1 new test_that() block (5 assertions) in
tests/testthat/test_makePedigreeMatingLayout.R, confirmed failing for the right
reason against unmodified source. GREEN: R/makePedigreeDiagramData.R's D2 loop now
looks up a dropped mate edge's color/width (keyed by the dogleg's projId) and applies
it as a post-hoc override after the existing generic-fallback assignment (required by
do.call(rbind, newEdgeList)'s column-alignment constraint across D1/D2 edge types --
a structural wrinkle the plan itself did not anticipate). Verified: targeted +
sibling test files all pass; full clean regression 1 pre-existing failure
(test_wordlist_coverage.R, confirmed via git stash unrelated to this diff);
lintr::lint_package() 0 lints on touched files; devtools::check() 0 errors, 1
warning + 1 note, both confirmed pre-existing/unrelated (untracked "Compounding
Loop" files' non-portable names; a pre-existing vignettes/figure/ knitr leftover).
Close-out: BACKLOG.md's S555 deferred-follow-up item annotated FIXED S563;
kinship2 plan's Track C clause annotated DONE S563 (Tracks A/B remain open);
NEWS.Rmd entry added; PROJECT_LEARNINGS.md Learning 569 logged. Commits: 91c78152
(claim) + this close-out commit.
next_steps: Pick up Track A (X-chromosome kinship, kinship() gains chrtype/sex,
Effort M) or Track B (a pedigree.shrink() equivalent, new shrinkPedigree(),
Effort L, most novel -- its own Pre-RED must first deparse kinship2's
excludeUnavailFounders/excludeStrayMarryin helpers, not yet done) --
docs/planning/kinship2-supplement-full-reproduction-plan.md §3/§4. Each is its own
separate implementation session (different capability, never bundled with the
other per SESSION_RUNNER.md's vertical-slice rule). None of the 3 tracks has a
GitHub issue yet -- the owner may wish to file 3 before further implementation.
Separately: a stale BACKLOG.md tag was found this session (the "ledger-size
housekeeping" item, S518, still says READY/Effort L in its header though its body
says fully RESOLVED since S531) -- a 1-line tag cleanup, not urgent. BACKLOG.md
priorities otherwise unchanged: LabKey (BLOCKED, Effort M), NPRC outreach
(DECISION NEEDED, Effort N/A), issue #148 (DECISION NEEDED -- needs its own
scope-narrowing conversation first, surfaced via the ratified sequencing audit's
own prose order, not an inline tag).
key_files: R/makePedigreeDiagramData.R:1499-1622 (.addRectilinearWaypoints(), the
D2 loop + post-hoc override, this session's entire production diff);
tests/testthat/test_makePedigreeMatingLayout.R:1043-1120 (the new Track C test
block); docs/planning/kinship2-supplement-full-reproduction-plan.md §3/§4 (Tracks
A/B, the next pickups); PROJECT_LEARNINGS.md Learning 569 (the anchor-selection
algorithm, reusable for any future D2-dogleg-targeting fixture); BACKLOG.md (the
S555 deferred-follow-up item and the kinship2 plan item, both annotated this
session).
gotchas: (1) do.call(rbind, newEdgeList) requires matching columns across every
entry -- D1's sibship-bar/chain edges have no color/width columns of their own, so
any future edit to this function that wants per-edge color/width must either add
those columns to ALL newEdgeList entries or use the post-hoc-override pattern this
session established (projColor/projWidth keyed by a unique id, applied after the
blanket fallback assignment) -- do not attempt to set color/width directly inside
the D2 loop's own data.frame() call, it will be silently clobbered by the later
blanket assignment. (2) Track B's own Pre-RED must deparse
excludeUnavailFounders/excludeStrayMarryin before writing RED tests -- still not
done. (3) Track B naming: use `genotyped`, never `avail`/`available` (collides
with R/makeAvailable.R's own unrelated breeding-group concept). (4) Track A's
X-linked branch must apply the existing MZ-twin mzgrp/mzindex correction inside
the new chrtype="x" loop too.
runtime_smoke: No live shinytest2/chromote run this session -- judged sufficient
per the plan's own §5.3 allowance ("a rendering-detail fix, not a new interaction
pattern"): the new unit test directly asserts on the exact edges data.frame
makePedigreeMatingLayout() returns, the same structure R/modPedigree.R's
visNetwork::renderVisNetwork() consumes for rendering -- a static review of the
actual returned data, not merely a build-passes check. Stated explicitly, not
silently skipped.
changelog_ref: this session's own CHANGELOG.md entries, 2026-08-13 (claim; this
close-out entry)
commit: 89be00ca
```

```handoff
session: S562
date: 2026-08-13
status: complete
self_score: 8
predecessor_score: 9
active_task: Write a plan document to fully reproduce
inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf's results with
nprcgenekeepr -- DONE, RATIFIED.
what_was_done: Wrote docs/planning/kinship2-supplement-full-reproduction-plan.md
(~600 lines), following the S550 twin-kinship plan's own structure/evidence
standard. 3 independently session-sliceable tracks: Track A (X-chromosome kinship,
kinship() gains chrtype/sex, core-algorithm-only per ratified scope); Track B (a
new shrinkPedigree() function porting kinship2's own 5-helper pedigree.shrink()
algorithm, script-callable only, deterministic tie-break -- the most novel track,
with 2 kinship2 sub-helpers left as an explicit Pre-RED item); Track C (finish the
edgeStyle="rectilinear" consanguineous-marker color/width propagation, smallest,
no open design question). Deparsed kinship2's own installed namespace directly for
both new capabilities (kinship.default's chrtype="x" branch; pedigree.shrink's
full helper chain). Found 2 real traps: the `available`/`avail` naming collision
with R/makeAvailable.R's unrelated breeding-group concept, and the MZ-twin
correction's interaction with the new X-linked branch. Ratified 4 judgment calls
via one AskUserQuestion call (owner picked this plan's own recommended option in
all 4 cases). Added a BACKLOG.md Housekeeping pointer item. Logged
PROJECT_LEARNINGS.md Learning 568 (the session's own scope-arc/mid-turn-
interruption-misreading process learning). Commits: 749d0530 (claim) + this
close-out commit.
next_steps: Implement one track (Track C recommended first -- smallest, no open
design question, fixture already built: R/makePedigreeDiagramData.R's
.addRectilinearWaypoints() D2 loop, ~2-line fix). Track A next (X-chromosome
kinship -- moderate, well-precedented signature extension to kinship()). Track B
last (pedigree.shrink() equivalent -- most novel; its own Pre-RED must first
deparse kinship2's excludeUnavailFounders/excludeStrayMarryin helpers, not yet
read this session). Each track is its own separate implementation session (never
bundled -- 3 different capabilities per SESSION_RUNNER.md's vertical-slice rule).
None of the 3 tracks has a GitHub issue yet -- the owner may wish to file 3 before
implementation begins. BACKLOG.md priorities otherwise unchanged from S561: LabKey
(BLOCKED, Effort M), NPRC outreach (DECISION NEEDED, Effort N/A).
key_files: docs/planning/kinship2-supplement-full-reproduction-plan.md (the
deliverable, all sections); R/makePedigreeDiagramData.R:1489-1531 (Track C's exact
gap, .addRectilinearWaypoints() D2 loop); R/kinship.R:79-171 (Track A's extension
point); R/trimPedigree.R, R/removeUninformativeFounders.R (confirmed NOT reused by
Track B -- a different problem); R/columnSchema.R:23 (affected column, reusable by
Track B); R/makeAvailable.R (the naming-collision trap Track B's own D-B1 avoids);
docs/planning/twin-relations-kinship-computation-plan.md (S550, the structural
precedent this plan followed); docs/audits/
KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md (S549, the triggering
audit); BACKLOG.md Housekeeping (the new pointer item, inserted directly after the
existing deferred edgeStyle="rectilinear" note).
gotchas: (1) Track B's own Pre-RED must deparse
excludeUnavailFounders/excludeStrayMarryin (kinship2::getFromNamespace(...)) before
writing RED tests -- not done this session, explicitly flagged as an open item, not
assumed. (2) Track B's naming: use `genotyped`, never `avail`/`available` -- the
latter collides with R/makeAvailable.R's own unrelated breeding-group-candidate-pool
concept already in this package's public vocabulary. (3) Track A's X-linked branch
must apply the existing MZ-twin mzgrp/mzindex correction inside the new chrtype="x"
loop too (kinship2 itself does this) -- omitting it would silently regress
twin-kinship parity for any pedigree with both a declared MZ pair and an X-linked
kinship request. (4) Track B cannot be verified against the PDF's own printed
numbers at any reachable scale (only Tracks A/C can) -- verify against installed
kinship2::pedigree.shrink() directly instead, on a self-constructed fixture. (5) The
plan's own AST call-site counts for kinship() (inherited context from the S550 plan)
predate this session and should be re-counted at Track A implementation time, not
trusted as still-current.
runtime_smoke: n/a -- docs-only planning session, no R/ package code changed,
nothing to launch. Stated explicitly, not silently skipped.
changelog_ref: this session's own CHANGELOG.md entries, 2026-08-13 (claim; this
close-out entry)
commit: 0ce5ac60
```

```handoff
session: S561
date: 2026-08-13
status: complete
self_score: 9
predecessor_score: 9
active_task: Resolve HANDOFFS.md's recurring FRONTMATTER_FIELD_ABSENT finding (BACKLOG.md
Housekeeping, found S508, re-surfaced S559) -- add a self-updating "This file currently holds
**N** receipt(s)" sentence to HANDOFFS.md's front matter -- DONE.
what_was_done: Added "This file currently holds **3** receipt(s). Computed by
methodology_trim.py on every --check/--write run, never hand-maintained." to HANDOFFS.md's
front matter, right after the last "Archived N record(s)..." pointer block. Owner picked this
remedy (over removing the regenerated config entry) via AskUserQuestion. Verified via a direct
unit-check (imported methodology_trim's own LEDGERS["HANDOFFS.md"].regenerated[0] regex,
confirmed it matches and extracts the correct value) and a dry-run --cut @<sha> (no --write)
confirming the live record parser counts exactly 3, matching the sentence -- the live archive
trigger doesn't fire this session, so a real --write couldn't be used to verify directly.
Found and corrected a stale claim in the process: methodology_trim.py's --check path returns
before ever reaching apply_regenerated() (only a real --write that builds an archive plan
does), contradicting the original S508 finding's "every check/write run" framing -- logged as
PROJECT_LEARNINGS.md Learning 567 and corrected in the BACKLOG.md item's own resolved-item
text. Commit e2d051fe (claim) + this close-out commit.
next_steps: BACKLOG.md priorities, in order: (1) Fix edgeStyle="rectilinear" consanguineous-
marker color/width propagation on dogleg-rerouted edges (found S555 -- a verified 12-row
reproduction fixture already exists; S560's own handoff called this "READY, Effort S" but
BACKLOG.md's own inline text for the item carries no matching tag -- add the tag when picking
this up, or as its own tiny fix first). (2) Issue #148 (MHC haplotype frequency reporting)
needs a scope-narrowing conversation before implementation, per the ratified genetic-metrics
sequencing audit (DECISION NEEDED). Unchanged: NPRC outreach owner review (DECISION NEEDED);
LabKey remaining recs (BLOCKED); the scheduled shinytest2.yaml CI run is still red, unchanged
since S548, still not diagnosed by any session. Local master remains ahead of origin (45+
commits after this session) -- a future session should consider pushing.
key_files: HANDOFFS.md:127-131 (the new front-matter sentence); methodology_trim.py:196-221
(the LEDGERS["HANDOFFS.md"] regenerated-field regex this sentence must match);
BACKLOG.md:70-90 (item annotated RESOLVED); PROJECT_LEARNINGS.md (new Learning 567);
CLAUDE.md:282 (learnings-count pointer).
gotchas: (1) methodology_trim.py's --check path structurally cannot reach apply_regenerated()
-- it returns at line ~1610, before the archive-plan-building code (~1660+) that calls it at
line 1707. Don't expect a --check run to surface or clear a FRONTMATTER_FIELD_ABSENT finding;
only a real --write with the trigger firing (or an explicit --cut) does. (2) A digit --cut
falls back to the archived span's max date for the shard filename, which collides with an
already-existing same-day shard (SHARD_EXISTS) -- use a non-digit --cut (a date, or @<ref>) to
pick a distinct dry-run shard name when probing this code path safely. (3) Count "retained"
receipts AFTER writing the Phase 1B claim stub, not before -- the stub is itself a live receipt
the moment it's committed; this session wrote N=2 first and had to correct it to 3.
runtime_smoke: n/a -- docs/config-only change (a front-matter sentence + a Python tool's
LEDGERS config was only READ, not modified); no R package or Shiny code touched.
changelog_ref: this session's 2 CHANGELOG.md entries (claim, close-out) dated 2026-08-13
commit: pending
```
<free-text: Strengths (1) traced methodology_trim.py's actual control flow rather than trusting
a 3-session-old prose characterization of its behavior, catching and correcting a stale claim
in the process; (2) caught its own N=2-vs-3 counting mistake by checking against the tool's own
record parser rather than trusting a hand computation; (3) verified a fix that couldn't be
exercised live (trigger doesn't fire) via two independent indirect methods instead of shipping
it unverified; (4) stayed narrowly scoped to the one decision, explicitly deferring the
tempting adjacent edgeStyle="rectilinear" tag-gap fix to a future session.
Weaknesses (1) the ordering mistake that produced the initial wrong N=2 (should have counted
receipts after, not before, writing the claim stub); (2) no second-agent adversarial
verification, though the diff is small (3 lines) and low-risk; (3) 45+ local commits still
unpushed, deferred again.
**Predecessor (S560) score: 9/10** -- see the Session 560 Handoff Evaluation in
SESSION_NOTES.md for the full breakdown; its next_steps field named this exact item verbatim as
item 2 of its priority list, followed as the literal picked option.>

```handoff
session: S560
date: 2026-08-13
status: complete
self_score: 9
predecessor_score: 9
active_task: Write vignettes/articles/pedigree-diagram.qmd (new dedicated Pedigree Diagram
tab article, incl. freshly-captured live-app screenshots via shinytest2) -- BACKLOG.md
Housekeeping, found S544 -- DONE.
what_was_done: Wrote vignettes/articles/pedigree-diagram.qmd (9 sections: Overview, Node
shapes/legend, Diagram Edge Style, Consanguineous marker, Affected-status shading, Showing
names, Twin/zygosity relations, Interacting with the diagram, Script-callable equivalent, See
also) plus vignettes/articles/pedigree-diagram-screenshots.R (a new shinytest2::AppDriver
screenshot script, 5 screenshots against small feature-relevant subgraphs trimmed from the
bundled obfuscated_rhesus_mhc_ped*.csv fixtures). Regenerated pb_diagram_legend.png in place
and fixed colony-manager-guide.qmd's stale pre-Option-2 "one node per animal... directed
sire/dam edges" opening sentence + added the new article to its function-group table.
Updated a2interactive.Rmd's own cross-reference to point to the new article. quarto render
clean on both .qmd files; targeted rmarkdown::render() on a2interactive.Rmd (the one real,
non-ignored vignette touched) confirmed clean; lintr::lint_package() 0 lints.
next_steps: BACKLOG.md priorities, in order: (1) Fix edgeStyle="rectilinear" consanguineous-
marker color/width propagation on dogleg-rerouted edges (READY, Effort S, found S555 -- a
verified 12-row reproduction fixture already exists). (2) Decide add-vs-remove for
HANDOFFS.md's FRONTMATTER_FIELD_ABSENT finding (DECISION NEEDED, Effort S, first seen S508).
(3) Issue #148 (MHC haplotype frequency reporting) needs a scope-narrowing conversation
before implementation, per the ratified genetic-metrics sequencing audit (DECISION NEEDED).
Unchanged: NPRC outreach owner review (DECISION NEEDED); LabKey remaining recs (BLOCKED); the
scheduled shinytest2.yaml CI run is still red, unchanged since S548, still not diagnosed by
any session. Local master remains ahead of origin (44+ commits after this session) -- a
future session should consider pushing.
key_files: vignettes/articles/pedigree-diagram.qmd (new article); vignettes/articles/
pedigree-diagram-screenshots.R (new screenshot script); vignettes/articles/shiny_app_use/
pb_diagram_legend.png (regenerated) + diagram_rectilinear_edge_style.png/
diagram_show_names.png/diagram_affected_shading.png/diagram_twin_connectors.png (new);
vignettes/articles/colony-manager-guide.qmd (Diagram-view paragraph fixed, table row 2
updated); vignettes/a2interactive.Rmd (cross-reference updated); BACKLOG.md Housekeeping (2
items resolved, compressed); PROJECT_LEARNINGS.md (new Learning 566); CLAUDE.md:282
(learnings-count pointer).
gotchas: (1) A live-app screenshot of a full 375-animal bundled fixture is functionally
correct but visually illegible -- trim to a small (3-7 animal) feature-relevant subgraph via
the Diagram tab's own Focal Animals + Trim Pedigree controls BEFORE capturing (Learning 566).
(2) The consanguineous-marker color CANNOT be shown in a close-up/zoomed screenshot when the
marked edge's own endpoint node radius exceeds its world-space length -- confirmed via direct
network.getPositions()/canvasToDOM() JS queries against the live visNetwork widget, not a
screenshot-technique failure; describe it in prose instead of chasing a zoom fix (Learning
566). (3) Quarto crossref syntax `[text](@sec-x)` (markdown-link-wrapped) does NOT resolve --
only bare `@sec-x` or `(@sec-x)` do, and even those render as "(Section N)" against
UN-numbered headings in this project's own quarto config, which is why this article uses
plain prose section-name pointers throughout instead, matching every sibling article's own
convention (none of which use quarto crossrefs at all).
runtime_smoke: n/a -- pure documentation (a new article + a screenshot-generation script
under vignettes/articles/, fully build-ignored via .Rbuildignore); no R/ package code
changed, no runtime/Shiny behavior surface to launch or observe. Stated explicitly, not
silently skipped.
changelog_ref: this session's own CHANGELOG.md entries, 2026-08-13 (reconcile, claim,
deliverable, close-out)
commit: pending
```
<**Self-score 9/10.** +: (1) read all 3 existing coverage surfaces
(`_pedigree_browser.Rmd`, `colony-manager-guide.qmd`, `a2interactive.Rmd`) before writing,
catching `colony-manager-guide.qmd`'s own stale pre-Option-2 opening sentence directly.
(2) did not accept the first illegible screenshot pass as good enough -- iterated to a
concrete fix (trim to a feature-relevant focal set via the app's own existing controls).
(3) when a specific screenshot (the consanguineous-marker close-up) genuinely could not work,
verified WHY via direct JS/canvas-position queries rather than guessing, then described the
limitation honestly in prose instead of shipping a misleading image. (4) verified with the
actual build tool (`quarto render`) rather than eyeballing markdown, catching 2 real defects
(broken crossref syntax, a fabricated vignette title) before they shipped. (5) confirmed the
actual build-ignore/lint scope (`.Rbuildignore`, `.lintr`) rather than assuming close-out
checklist triggers applied broadly. -: (1) the first full-fixture screenshot pass was a
predictable, avoidable mistake -- `a2interactive.Rmd`'s own prose, read earlier the same
session, already explained why a dense real fixture doesn't demonstrate features legibly.
(2) no independent adversarial-verification pass beyond this session's own manual review --
the same standing gap flagged across many prior sessions. (3) did not push the now 44+ local
commits to `origin`, matching the repeatedly-deferred precedent from S548 onward.
**Predecessor (S559) score: 9/10** -- see the Session 559 Handoff Evaluation in
SESSION_NOTES.md for the full breakdown; its `next_steps` field named this exact item
verbatim as item 1 of its priority list, followed as the literal picked option.>

```handoff
session: S559
date: 2026-08-13
status: complete
self_score: 8
predecessor_score: 9
active_task: Archive SESSION_NOTES.md (past the 2,000-line agent read cap, dashboard HIGH risk,
unresolved since S555) via methodology_trim.py; also checked and archived HANDOFFS.md
(dashboard MEDIUM risk) and, once its own byte trigger fired as a direct side effect,
CHANGELOG.md too -- DONE, all 3 ledgers archived and verified.
what_was_done: Ran methodology_trim.py --write against SESSION_NOTES.md, HANDOFFS.md, and
CHANGELOG.md. First attempt chained all 3 --write calls without committing between them,
which broke CHANGELOG.md's own generated verify.sh (compared against a stale HEAD, 2
entries behind) -- not real data loss (the tool's own in-process L1/L2/L3 checks, run
against true in-memory content, had already passed), but an invalid comparison. Recovered
via a precise surgical unwind of just the premature CHANGELOG.md trim, then re-ran all 3 as
separate write-verify-commit cycles per the tool's own advertised discipline. Final commits:
4c7f8415 (claim), 8e586478 (SESSION_NOTES.md: 2,432->339 lines, 208,194->27,604 B), 306a4b4d
(HANDOFFS.md: 109,667->9,200 B), ec76e487 (CHANGELOG.md: 67,414->33,924 B). All 3 shards'
verify.sh scripts pass cleanly against real committed HEAD. Also fixed S558's own HANDOFFS.md
receipt commit: pending -> cafd7d49 before archiving it (documented reconcile exception).
Logged PROJECT_LEARNINGS.md Learning 565 (the chained-trim/verify.sh interaction) and a new
BACKLOG.md Housekeeping item (HANDOFFS.md's recurring FRONTMATTER_FIELD_ABSENT finding,
first seen S508, needs an explicit add-vs-remove decision). Updated CLAUDE.md's stale
"Sessions 1-504+; 503 learnings" pointer to the current count.
next_steps: BACKLOG.md priorities, in order: (1) Write the dedicated Pedigree Diagram tab
article (READY, Effort M, unchanged since S544). (2) Fix edgeStyle="rectilinear"
consanguineous-marker color/width propagation on dogleg-rerouted edges (READY, Effort S,
found S555 -- a verified 12-row reproduction fixture already exists). (3) Decide add-vs-
remove for HANDOFFS.md's FRONTMATTER_FIELD_ABSENT finding (new this session, DECISION
NEEDED, Effort S). (4) Issue #148 (MHC haplotype frequency reporting) needs a
scope-narrowing conversation before implementation, per the ratified genetic-metrics
sequencing audit. Unchanged: NPRC outreach owner review (DECISION NEEDED); LabKey remaining
recs (BLOCKED); the scheduled shinytest2.yaml CI run is still red, unchanged from
S544-S559's own findings, still not diagnosed by any session. Local master remains ahead of
origin (38+ commits after this session) -- a future session should consider pushing.
key_files: BACKLOG.md Housekeeping (new HANDOFFS.md front-matter-field item);
PROJECT_LEARNINGS.md (new Learning 565); CLAUDE.md:282 (learnings-count pointer);
docs/archive/SESSION_NOTES-through-2026-08-13.md, docs/archive/HANDOFFS-through-2026-08-13.md,
docs/archive/CHANGELOG-through-2026-08-13.md (the 3 new shards, each with its own .verify.sh).
No R/ or tests/ files touched this session (pure ledger/documentation housekeeping).
gotchas: (1) methodology_trim.py's generated verify.sh validates an uncommitted --write
against HEAD -- if a session's deliverable is archiving MULTIPLE ledger files in one
sitting, commit each file's own --write (and run its verify.sh) BEFORE running --write
against the next file, exactly as the tool's own printed output says ("one ledger, one
shard, one entry, one commit, one revert"). CHANGELOG.md is the one most likely to break
this way, since every OTHER ledger's own trim writes an entry into it as a side effect. See
PROJECT_LEARNINGS.md Learning 565 for the full recovery methodology if this is hit anyway.
(2) A ledger's own byte trigger can fire as a side effect of another ledger's trim entries
landing in it -- re-run --check on CHANGELOG.md after archiving any other ledger, even if
it wasn't part of the original plan. (3) HANDOFFS.md's declared "retained receipt count"
regenerated front-matter field has no matching sentence in the file's actual front matter
(a real, non-blocking, recurring FRONTMATTER_FIELD_ABSENT finding since S508) -- don't
mistake it for a new defect; it's tracked in BACKLOG.md Housekeeping now, decision pending.
runtime_smoke: n/a -- pure ledger/documentation housekeeping (archiving 3 ledger files), no
runtime/Shiny behavior surface exists to launch or observe. Stated explicitly, not silently
skipped.
changelog_ref: this session's own CHANGELOG.md entries, 2026-08-13 (claim; 3 ledger-trim
entries auto-written by methodology_trim.py; this close-out entry)
commit: abf1a984
```
<**Self-score 8/10.** +: (1) ran --check before every --write and verified losslessness via
each shard's own generated verify.sh before every commit -- caught the chained-trim defect
itself rather than committing broken state. (2) recovered via a precise, minimal surgical
unwind (removing exactly the erroneous trim's own top-inserted entry and bottom-removed
tail) rather than a blanket revert that would have discarded 2 valid trims' work.
(3) extended scope to CHANGELOG.md's own trigger only because this session's own actions
caused it to fire, without treating that as license for unrelated scope creep. (4) fixed
the S558 receipt's stale commit: pending placeholder using the documented reconcile
exception. (5) surfaced the pre-existing S508-era HANDOFFS.md FRONTMATTER_FIELD_ABSENT
finding as an explicit, trackable BACKLOG.md decision item instead of letting it keep
recurring silently. (6) documented the chained-trim gotcha as PROJECT_LEARNINGS.md
Learning 565. -: (1) the core mistake -- chaining 3 --write calls without committing
between them despite the tool's own printed guidance saying exactly that -- was avoidable
and cost real session time to recover from. (2) no independent adversarial-verification
pass beyond the tool's own internal checks and this session's own manual review -- the same
standing gap S551-S558 have flagged across 7 consecutive sessions, though the risk here is
lower given the tool's own L1/L2/L3 checks are themselves independent verification.
(3) did not push the now 38+ local commits to origin -- left for the owner/a future
session, matching the repeatedly-deferred precedent from S548 onward.
**Predecessor (S558) score: 9/10** -- see the Session 558 Handoff Evaluation in
SESSION_NOTES.md for the full breakdown; its next_steps field named this exact item
verbatim as item 1 of its priority list, followed as the literal first and only
investigative step.>

