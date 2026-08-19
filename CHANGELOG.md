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

## 2026-08

### 2026-08-19 · [ad hoc] S610: record close-out commit sha in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S609 precedent)
- **Deliverable:** `HANDOFFS.md`'s S610 receipt `commit:` field updated from `pending` to the
  actual close-out commit sha (`3eb6c0bf`).
- **Model:** Claude Sonnet 5.

### 2026-08-19 · [issue #141] S610: close out (Walker/BJL apportioning redesign — architecture plan)
- **Deliverable:** [`docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md`](docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md)
  (642 lines) — the planning session
  `pedigree-diagram-single-child-union-parent-coincidence-investigation.md` §11 called for, scoping
  a complete Reingold-Tilford/Walker/Buchheim-Jünger-Leipert apportioning redesign of D3
  (`.positionMatingUnitForest()`) across 5 phases. **Planning only — no production code written or
  modified** (`git status --porcelain -- R/ tests/` empty throughout).
- **Method:** an 8-agent `Workflow` (3 parallel research passes → design synthesis → 3 parallel
  adversarial critique lenses → repair; 162 tool calls, 1.24M subagent tokens, 0 errors).
  **All 3 critique lenses returned `designSound: false` on the first draft.** The decisive finding:
  the draft's own proposed reconciliation mechanism (a "global LEFTNEIGHBOR table") was
  *misattributed* (real BJL **replaces** Walker's global per-level table with a purely local sibling
  lookup — the draft claimed the opposite) and *mechanically unsound* (a non-sibling comparison
  partner breaks `moveSubtree`/`executeShifts`'s sibling-indexed bookkeeping), and would have
  reintroduced this investigation's own signature "one-directional sweep, first one wins" failure
  shape **one level down, inside the replacement algorithm's own internals** — a 7th instance of the
  same root cause, caught at the planning stage rather than after implementation.
- **Independent verification found 2 errors the critiques missed**, both corrected and documented in
  the plan as corrections: (1) a real file misattribution — the `-6.0`/`90`/`129.06` gate-behavior
  pins are in `test_positionMatingUnitForest.R` (`:1582`/`:1491`/`:1524`), not
  `test_makePedigreeMatingLayout.R` as the draft's inventory *and* its Phase 3 commit list both
  claimed; traced to a critique agent conflating that file's name with the other file's line count
  (`test_positionMatingUnitForest.R` is exactly 1,583 lines). (2) Two `test_that()` block counts
  (18→19, 44→46).
- **Plan shape:** Phase 1a standalone BJL engine (genuine trees only, cross-checked against
  MIT-licensed `d3-hierarchy`); **Phase 1b (NEW, required, gates Phase 2)** a research/design spike
  for the forest/mixed-gen reconciliation problem the literature does not address at all — this
  project's forest has 0-delta tree edges no Reingold-Tilford/Walker/BJL no-overlap proof covers,
  and 1b may legitimately conclude "more research needed"; Phase 2 adapter built parallel to
  production plus a reusable `helper-live-render-positions.R` chromote harness; Phase 3 cutover in 2
  scoped commits (4 files, then 2), each independently green; Phase 4 cleanup + close issue #141.
  Removal of Track 3's clamp / Track 6's `finalUnitX` override / `.computeDupNudge()` / both
  `sweepMinSep()` passes / the epsilon de-collision pass is **conditional** on Phase 2's
  real-fixture zero-coincidence gate, never asserted in advance.
- `BACKLOG.md` Track 3 item updated (status tag + S610 progress paragraph). Issue #141 deliberately
  **not** closed and its `premature optimization` label deliberately **not** changed — both deferred
  to the plan's own Phase 4 / the owner, matching S609's restraint.
- **Model:** Claude Sonnet 5.

### 2026-08-19 · [ad hoc] S610: claim session (Track 3 algorithm-family redesign scoping)
- **Deliverable:** Phase 1B claim stub in `SESSION_NOTES.md` + `status: pending` `HANDOFFS.md`
  receipt, committed (`99930551`) before any technical work — 2nd consecutive session claiming
  correctly after the S606-S608 three-session lapse (Learnings 624/625/628).
- **Model:** Claude Sonnet 5.

### 2026-08-18 · [ad hoc] S609: record the HANDOFFS.md sha-fix action itself (03ada3bc)
- **Deliverable:** the sha-fix commit itself (`03ada3bc`) recorded here per failure mode #27
  applying even to the self-referential sha-backfill commit — matching S600/S602-S608 precedent
  exactly.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · [ad hoc] S609: record close-out commit sha in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S608 precedent)
- **Deliverable:** `HANDOFFS.md`'s S609 receipt `commit:` field updated from `pending` to the
  actual close-out commit sha (`3344270c`).
- **Model:** Claude Sonnet 5.

### 2026-08-18 · [ad hoc] S609: close out (Track 6 D3‴ repair — Critique Round 3 failed, redirected to algorithm-family redesign)
- **Deliverable:** built and Critique-Round-3'd "D3‴" (the Track 6 single-child union/parent-
  coincidence repair ratified S608 §9) in a scratch copy — all 3 independent critique lenses
  returned `designStillSound: false` (6th failed design attempt in this investigation's history).
  A live owner architecture challenge, resolved by re-reading 3 primary sources in full, then
  redirected the defect class: pursue a complete Reingold-Tilford/Walker/Buchheim-Jünger-Leipert
  implementation (issue #141) rather than a 7th local patch. No production code changed.
- Published a verified kinship2-vs-nprcgenekeepr before/after comparison Artifact (F1 fixture,
  node coordinates traced programmatically before trusting the images).
- `docs/planning/pedigree-diagram-single-child-union-parent-coincidence-investigation.md` §10
  (Critique Round 3 findings) and §11 (owner-ratified redirect) added.
- `BACKLOG.md` Track 3 item updated with the S609 progress + redirect paragraphs.
- GitHub issue #141 commented (new correctness-based evidence; AI-authorship disclaimer; label
  not changed unilaterally).
- `PROJECT_LEARNINGS.md` Learnings 630 (adversarial mutation-test diagnostic-sufficiency claims;
  boolean `capped` fields need a magnitude check) and 631 (read full truncated Workflow output
  before reporting; re-read primary sources, not condensed restatements, under direct challenge).
- `CLAUDE.md` learnings-count pointer updated (627→631 learnings, Sessions 1–607+→1–609+ — also
  corrects a 2-learning drift S608 itself left unfixed).
- **Model:** Claude Sonnet 5.

### 2026-08-18 · [ad hoc] S609: claim session (Track 6 targeted repair) (cffc09b7)
- **Deliverable:** Phase 1B claim stub (`SESSION_NOTES.md`) + `HANDOFFS.md` `status: pending`
  receipt, written and committed before any technical work — correcting the pattern
  Learnings 624/625/628 flagged in the 3 immediately preceding sessions.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · [ad hoc] S608: record the HANDOFFS.md sha-fix action itself (30631c83)
- **Deliverable:** `HANDOFFS.md`'s S608 receipt `commit:` field updated from `pending` to the
  actual close-out commit sha (`8c697fab`), then this action itself recorded here per failure
  mode #27 applying even to the self-referential sha-backfill commit — matching S600/S602-S607
  precedent exactly.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · [ad hoc] S608: close out — Track 6 single-child union investigation
- **Deliverable:** Phase 3 close-out for the investigation below. Added `PROJECT_LEARNINGS.md`
  Learnings 628 (a third consecutive Phase 1B skip, despite Learnings 624/625 already documenting
  and sharpening the rule against exactly this — the practical rule is revised to bind the
  stub-writing tool calls syntactically to the last scope-fixing `AskUserQuestion`, not left as a
  remembered follow-up) and 629 (a repaired design's own extensive self-verification missed a real
  bug a second, independently-scripted critique round found — a tautological invariant-test check
  that re-invoked the same function it was meant to verify). Completed the `HANDOFFS.md` S608
  receipt (`status: complete`) and the Phase 3A evaluation of S607's own handoff (9/10) in
  `SESSION_NOTES.md`.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · [ad hoc] S608: investigate the Track 6 single-child union/parent-coincidence defect (found S603) — investigation only, no production code
- **Deliverable:** Picked up via `AskUserQuestion` as the Track 3 child-centering trade-off
  decision, then pivoted (owner-directed) away from the exhausted 5-attempt
  duplicate-occurrence-selection mechanism to S603's own newly-found, structurally distinct
  defect: Track 6's single-child union formula can place a union's marker and both mate edges
  essentially on top of one of its own 2 parents. Ran a 15-agent
  Evidence→Design→Synthesize→Critique→Repair→Critique-2 `Workflow` (14/15 agents succeeded; 1
  Design candidate hit a transient API error, disclosed not hidden). Found the defect is
  majority-prevalence on the real 375-individual bundled fixture (72% of all matings visually
  coincide with a parent, live-verified via chromote pixel-space rendering) — not the rare edge
  case S603's own 3 examples suggested. A synthesized design ("D3") had real correctness majors
  (worsened 3 established collision-metric tests, regressed a deliberately-correct S583 pinned
  test); a repair ("D3″") addressed most of those, but Critique Round 2 found a new,
  live-verified bug (a "self-duplicate phantom obstacle" discarding 75% of the repair's own
  residual improvement) with an already-verified one-line fix in hand. Wrote up the full
  investigation:
  [`docs/planning/pedigree-diagram-single-child-union-parent-coincidence-investigation.md`](docs/planning/pedigree-diagram-single-child-union-parent-coincidence-investigation.md).
  Owner ratified (via `AskUserQuestion`) a targeted future repair session (apply the one-line fix
  + add diagnostic return fields + a fresh Critique Round 3, then PRE-RED→RED→GREEN) over
  accepting the defect as permanent, holding, or re-running the failed candidate first. `BACKLOG.md`
  Active updated with a Progress paragraph and a READY-tagged next-step pointer. No `R/*.R` file
  was modified — every live-verification in the `Workflow` ran against scratch copies under the
  session's own harness scratchpad, confirmed via `git status --porcelain -- R/ tests/` empty
  throughout by multiple agents.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · [ad hoc] S608: claim session (late; Phase 1B was skipped, caught and corrected)
- **Deliverable:** `SESSION_NOTES.md` stub + `HANDOFFS.md` `status: pending` receipt, committed
  (`0bb03e0f`) — written after research and a 1-agent scoping dispatch had already run (Phase 1B
  was skipped when the task was first picked), self-caught and corrected rather than deferred to a
  future session's reconcile. See `PROJECT_LEARNINGS.md` Learning 628 for the pattern this
  recurrence confirms.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · [ad hoc] S607: post-close-out correction — REUSE badge renders "unregistered," not green; new BACKLOG.md item for the owner action needed
- **Deliverable:** After pushing S607's REUSE compliance work, verified the live badge directly
  (`curl` against `api.reuse.software/badge/...` and `/info/...`) rather than assuming a push was
  sufficient. Found it renders gray **"unregistered"** — `api.reuse.software` requires a one-time
  manual registration (repo URL + email, confirmed via email) at
  https://api.reuse.software/register before it will crawl and report compliance at all; this is a
  registration step tied to the owner's own email/identity, not something a session can or should
  perform. The repo itself IS `reuse lint`-compliant (1234/1234, verified locally) — only the
  badge's live rendering is blocked on this owner step. New `BACKLOG.md` Housekeeping item filed
  (DECISION NEEDED / owner action, Effort S) rather than leaving the gap undocumented.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · [ad hoc] S607: record close-out commit sha in HANDOFFS.md receipt (`c871be1b`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> `c871be1b`
  (the close-out commit whose sha the receipt itself couldn't name until after it was made),
  matching the S600/S602/S603/S604/S605/S606 self-reference-workaround precedent.

### 2026-08-18 · [ad hoc] S607: MIT + REUSE license badges added to README.Rmd, full REUSE compliance
- **Deliverable:** `BACKLOG.md` Housekeeping item (added S600, `[ad hoc]` entry above) — both halves
  DONE. **MIT badge:** static shields.io badge added to `README.Rmd`'s existing badges block;
  `README.md` re-rendered via `devtools::build_readme()`. **REUSE badge:** owner picked "do the
  compliance work now" over skipping the badge or holding, via `AskUserQuestion`. Installed the
  `reuse` CLI (v6.2.0, `brew install reuse` — not previously available locally) rather than
  approximating compliance from spec knowledge alone. `reuse lint` before any change: 0/1234 files
  (tracked + untracked working-tree content) had a valid SPDX license identifier, confirming the
  S567/S600 grep finding. Added `LICENSES/MIT.txt` (canonical SPDX text via `reuse download MIT`,
  network-verified) and `REUSE.toml`: one blanket `"**"` annotation (`2017-2026 R. Mark Sharp`, MIT)
  covering all first-party content, plus a carve-out for 5 files vendored in by tooling and not
  authored by this project — `renv/activate.R` and the 4 `man/figures/lifecycle-*.svg` badges — both
  confirmed MIT / Posit Software, PBC by checking `renv`'s and `lifecycle`'s own installed
  `DESCRIPTION`, not assumed. `inst/extdata/reference/Master_Genetic_metrics_2_14_15.pdf`'s copyright
  status was genuinely ambiguous from PDF metadata alone (generic "Word" authorship) — owner confirmed
  via `AskUserQuestion` it is the project's own MIT-licensed work, distinct from the 4 already-
  gitignored third-party papers (S567/S568). `reuse lint` after: **1234/1234 compliant, 0 missing** —
  verified against the real tool, not assumed from the config. `.Rbuildignore` gained `REUSE.toml`/
  `LICENSES`, matching the existing `CITATION.cff`/`codecov.yml`/`_pkgdown.yml` precedent;
  `devtools::check()` confirmed 0 new NOTEs from this change (the 1 warning + 2 notes present — the
  recurring Office lock file, `scratchpad/`, the long-standing `vignettes/figure/` knitr leftover —
  are all pre-existing, unrelated to this session). REUSE badge will render green only after this
  commit is pushed (api.reuse.software queries the live GitHub repo, not the local working tree).
  New `PROJECT_LEARNINGS.md` Learning 627 (run the real compliance tool, don't approximate it).
  `CLAUDE.md` learnings-count pointer refreshed (626→627, S606+→S607+).
- **Model:** Claude Sonnet 5.

### 2026-08-18 · [ad hoc] S606: record close-out commit sha in HANDOFFS.md receipt (`b10b6d2d`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit`/`changelog_ref: pending`
  -> `b10b6d2d` (the close-out commit whose sha the receipt itself couldn't name until after it was
  made), matching the S600/S602/S603/S604/S605 self-reference-workaround precedent.

### 2026-08-18 · [BL-518] S606: `BACKLOG.md` "Genetic-metrics PDF audit follow-ups" section
re-compressed; S518 item's "fully RESOLVED" claim corrected
- **Deliverable:** Re-compressed `BACKLOG.md`'s "Genetic-metrics PDF audit follow-ups" section
  (304→80 lines), continuing the S529/S530/S531 precedent. Fixed a stale intro claim ("#152
  [Deferred] is in progress [Slice 3 next]" → closed, independently confirmed via `gh issue view
  152`/`153`, both `CLOSED`). Condensed 6 sequential "Progress (SNNN...)" paragraphs (S517 design +
  issue #152 Slices 1-5, ~265 lines) into 1 consolidated summary preserving every session number,
  design-doc path, and `PROJECT_LEARNINGS.md` Learning cross-reference (532/538/539/540/541/542,
  all verified to resolve). Found and fixed a live, previously-unpropagated correction: the S535
  paragraph's own "`shinytest2`/`chromote` headless-modal-rendering harness limitation" finding was
  retracted one session later by `PROJECT_LEARNINGS.md` Learning 542 (S536 — real cause was a test
  fixture missing a required `birth` column) but never back-ported into `BACKLOG.md`'s own prose —
  rewrote it to state the corrected root cause rather than compress the debunked framing into
  shorter form. Verified `CHANGELOG.md` (+ 5 `docs/archive/CHANGELOG-through-*.md` shards) covers
  all 23 candidate session numbers before compressing to a pointer (0 real gaps; 1 apparent gap,
  S492, was a search-pattern false negative — the archive heading reads "Session 492," not "S492").
- **Also found and corrected:** the S518 tracking item's own text (`BACKLOG.md` Housekeeping) had
  claimed "fully RESOLVED" after S531's 2026-08-12 compression, but the very section S531
  compressed (267 lines then) had regrown to 304 by this session's own read — 3 intervening
  sessions (S532/S533/S535) each appended their own progress paragraph as issue #152's slices
  shipped, the exact accumulation pattern the item's own opening paragraph names as the root
  problem. Recorded as new `PROJECT_LEARNINGS.md` Learning 626 rather than left silently uncorrected.
  "Pedigree diagram vs kinship2" (S530's own prior target) was NOT re-checked this session for the
  same regrowth risk — flagged for a future session, not silently skipped.
- **Process note:** claimed the session (Phase 1B `SESSION_NOTES.md` stub + `HANDOFFS.md`
  `status: pending` receipt) BEFORE any investigation of `BACKLOG.md`'s own content, breaking the
  2-session Phase 1B-skip streak `PROJECT_LEARNINGS.md` Learnings 624/625 documented (S604, S605).
- TDD: N/A throughout — pure docs edit, no `R/`/`tests/`/`man/`/`NAMESPACE`/`data/` content
  touched, matching the S529/S530/S531 precedent. `git diff --stat`: `BACKLOG.md` +73/−268 (net
  −195 lines), `PROJECT_LEARNINGS.md` +1 new Learning (626), `CLAUDE.md` learnings-count pointer
  625→626.

### 2026-08-18 · [ad hoc] S605: record close-out commit sha in HANDOFFS.md receipt (`3539bc38`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit`/`changelog_ref: pending`
  -> `3539bc38` (the close-out commit whose sha the receipt itself couldn't name until after it was
  made), matching the S600/S602/S603/S604 self-reference-workaround precedent.

### 2026-08-18 · [ad hoc] S605: fix R-CMD-check.yaml CI-red — `inst/WORDLIST` missing "radix"
- **Deliverable:** `inst/WORDLIST` — added `radix` (before `RData`), the one word
  `spelling::spell_check_package()` flagged as uncovered. Root cause: S604's close-out edit to
  `NEWS.Rmd`/`NEWS.md` (issue #162's changelog bullet, "byte/radix order") introduced the word
  *after* S604's own full-clean-regression check had already run, so it was never re-verified —
  same defect class as the S584/S587 precedent (`md's`, backfilled S603/S604). Found during this
  session's own Phase 0 CI-status check (`gh run list`), reported (not filed as a `BACKLOG.md`
  item — trivial enough to fix same-session per the "just fix it" one-off-bug convention) and
  fixed in the same session, per user pick from the rendered priorities list. Verification: target
  test (`test_wordlist_coverage.R`) 0 failures; full clean-regression suite 0 failed/0 error
  project-wide; direct `spelling::spell_check_package(".", vignettes = TRUE)` — "No spelling
  errors found." No `.R` file touched (lint N/A); no runtime behavior changed (Phase 3E N/A,
  stated explicitly). TDD: full PRE-RED→RED→GREEN→REFACTOR cycle with all 3 gated
  `AskUserQuestion`s — RED was the already-existing, already-failing `test_wordlist_coverage.R`
  assertion (no new test needed, the existing test fully captured the requirement); REFACTOR
  concluded as a genuine no-op (single-line addition to a flat word list).
- **Process note (self-flagged):** this session again skipped Phase 1B (the `SESSION_NOTES.md`
  claim stub + `HANDOFFS.md` `status: pending` receipt, committed *before* any technical work) —
  the exact gap S604 self-flagged and logged as `PROJECT_LEARNINGS.md` Learning 624 one session
  earlier, in the very same session that documented it. Caught only after the GREEN edit had
  already landed, not before. See the updated Learning 624 entry and this session's `HANDOFFS.md`
  receipt for the corrective framing.

### 2026-08-18 · [ad hoc] S604: record close-out commit sha in HANDOFFS.md receipt (`6f645d4a`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit`/`changelog_ref: pending` ->
  `6f645d4a` (the close-out commit whose sha the receipt itself couldn't name until after it was
  made), matching the S600/S602/S603 self-reference-workaround precedent.

### 2026-08-18 · [issue #162] S604: fix `preferAnchor()`'s locale-dependent final tie-break
- **Deliverable:** `R/makePedigreeDiagramData.R:410` — `preferAnchor()`'s final anchor tie-break
  (reached when 2 candidate parents tie on both generation and mate count, guaranteed for every
  full-sibling mate pair) fell back to a bare `a < b` character comparison, which invokes the
  session's own locale-dependent `Scollate()`. Replaced with
  `order(c(a, b), method = "radix")[1L] == 1L`, the same locale-independent byte-order technique
  Learning 585/588 already established in this file and 3 others. Full TDD RED→GREEN→REFACTOR: 1
  new `test_that()` in `tests/testthat/test_positionMatingUnitForest.R` (full-sibling `a1`×`A1`
  fixture, live-confirmed to flip anchor selection between this environment's default locale and
  byte/radix order); RED confirmed failing pre-fix (2 assertions), GREEN confirmed passing
  post-fix with 0 regressions in the file. Full clean regression: **0 failed / 0 error** across the
  entire suite (the `test_wordlist_coverage.R` failure this session's own Phase 0 backfill entry
  above already fixed). `lintr::lint_package()`: 0 lints on both touched files. Runtime smoke test:
  `makePedigreeMatingLayout()` run on the real 375-individual bundled fixture (714 nodes/827 edges,
  0 NAs). GitHub issue #162 closed citing this entry. **Model:** Claude Sonnet 5.

### 2026-08-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit `39de7dc2` — WORDLIST fix
- **Deliverable:** `inst/WORDLIST` gained `md's` (alphabetic position, matching the S230 convention),
  fixing the `test_wordlist_coverage.R` failure that S603's orientation found making `R-CMD-check.yaml`
  red on `master` (S603 reported it as out of that session's own scope — "still open" — and did not fix
  it). Committed directly by the project owner outside of a Claude Code session (no `SESSION_NOTES.md`
  claim stub, no `HANDOFFS.md` receipt) — reconciled here per `SESSION_RUNNER.md` Phase 0 step 6, found
  at Session 604's orientation. **Model:** none (human-authored commit, no assistant session).

### 2026-08-18 · [ad hoc] S603: record close-out commit sha in HANDOFFS.md receipt (`478a36af`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit`/`changelog_ref: pending` ->
  `a577d89f` (the close-out commit whose sha the receipt itself couldn't name until after it was made),
  matching the S600/S602 self-reference-workaround precedent.

### 2026-08-18 · [ad hoc] S603: post-close-out correction — S602's "child-centering half DONE" claim RETRACTED
- **Session summary:** owner reviewed S602's published comparison artifact and reported 3 observations
  ("the after image still shows the union marker inside P2"; "X×A/A×Y descenders not centered"; "the
  W×Y descender lands directly below Y") contradicting the artifact's own "verified"/"correct behavior"
  framing, which this assistant had relayed without independent verification. Mid-session, the owner
  gave a direct instruction to fix the underlying verification approach, not just this one instance.
  All 3 observations independently reproduced against current source (not the artifact's own claims):
  F1 fixture (`test_positionMatingUnitForest.R:1140-1146`) rendered via `visNetwork`/`chromote` at both
  the pre-fix commit (`cdb9a167~1`, isolated `git worktree`, working tree untouched) and current
  `HEAD`, positions read via `visNetwork`'s own live `getPositions()`. **Confirmed:** (1) the
  Track-3-Engagement Gate fix moves `__union_1` 5px against P2's 25px node radius — code-correct,
  TDD-green, and visually indistinguishable from doing nothing (3×-zoom before/after screenshots are
  pixel-identical); (2)/(3) the X×A/A×Y/W×Y descender defects are real and — checked directly against
  the gate's own qualification rule (none of these 3 unions' children are duplicated anywhere in the
  fixture) — structurally unrelated to S602's fix; they are pure output of the earlier, separate
  Track 6 "center on one child" design. The artifact's "correct behavior, verified" label for these
  rested on the design's own stated intent, never the rendered geometry. Owner chose "record correction
  now" (documentation only, no code changed) via `AskUserQuestion`. **Corrections made:** `BACKLOG.md`
  (Track 3 trade-offs item's "DONE" header retracted, full correction paragraph appended);
  investigation doc §12 "Net result" retracted, new §13 appended (methodology, numbers, root-cause
  distinction, methodology note); `NEWS.Rmd`/`NEWS.md` (S602 bullet "Fixed:"→"Changed:", correction
  paragraph appended, re-rendered — diff confirmed scoped to that one bullet); `PROJECT_LEARNINGS.md`
  Learning 623 (this session's own methodology gap, generalized); `CLAUDE.md` learnings pointer
  refreshed (622→623); the published artifact corrected in place to Revision 4 (same design system as
  Revisions 1-3, new retraction box, fresh live-rendered before/after images replacing the prior
  unverified ones); this assistant's own user-level `verify-diagrams-against-ground-truth` memory
  updated with the second, distinct failure mode (magnitude/geometry verification, not just edge
  topology; a design's stated intent is not proof of visual correctness). Also surfaced during this
  session's own Phase 0 orientation, reported not fixed: `R-CMD-check.yaml` red on `master` for the
  last-pushed commit (S601's close-out) — `test_wordlist_coverage.R` flags `md's` as uncovered by
  `inst/WORDLIST`, same defect class as the S584/S587 precedent.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · [ad hoc] S603: claim session (post-close-out correction: child-centering fix has no visible effect) (`9cb8528b`)
- **Deliverable:** Phase 1B claim stub written to `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-17 · [ad hoc] S602: Track-3-Engagement Gate — duplicate-occurrence-selection centering fix IMPLEMENTED (RED→GREEN→REFACTOR)
- **Session summary:** implemented the design from the duplicate-occurrence-centering investigation's
  §11.4 (5 workflow attempts across S598-S601, first sound design found S601), closing the
  investigation with shipped, TDD-verified code. Two `AskUserQuestion` gates before RED: a pre-RED
  scope decision (owner: full implementation now, over unit-tested-but-unwired or accepting the
  trade-offs as permanent) and the mandatory `TDD: PRE-RED→RED` gate (owner: full scope). Recovered 2
  gaps the investigation doc's own prose left only narratively described — the qualification rule's
  literal (a)/(b) clauses and `.computeDupNudge()`'s full 6-argument signature — by reading both
  design workflows' own raw `journal.jsonl` outputs directly (`wf_2d657d34-184`, `wf_f8b481f4-0f8`),
  not by re-deriving from the doc's prose (`PROJECT_LEARNINGS.md` Learning 621). **RED:** 7 new/
  modified tests in `tests/testthat/test_positionMatingUnitForest.R`, all hand-constructed and
  empirically verified against real, unmodified source — F1/F2/F3 reproduce the investigation's own
  documented values exactly; a fresh 9-individual nested/chained fixture reproduces the
  worse-than-erasure regression from scratch; a variant confirms the gate doesn't over-suppress a
  genuine correction; a dangling-parent fixture; the separately-accepted erasure trade-off confirmed
  untouched; `checkInvariant()` gained a 3rd disjunct + `.commentOneFixture()` added to its call list
  (avoiding a vacuous widened-disjunct-with-unwidened-call-list trap); a strict F1 regression
  assertion. One test initially passed vacuously pre-GREEN (a "value must stay unchanged" black-box
  claim, trivially true when nothing exists yet to change it) — caught and fixed with a paired
  white-box assertion before treating RED as complete (`PROJECT_LEARNINGS.md` Learning 622). All 7
  confirmed failing pre-GREEN, 0 collateral damage to the rest of the suite. **GREEN:** new internal
  `.computeDupNudge()` (`R/makePedigreeDiagramData.R`, `@noRd`) implementing the qualification rule,
  Stage-1 clip-and-average target, and the Track-3-Engagement Gate; wired into
  `.positionMatingUnitForest()` at the confirmed insertion point. Full clean regression: 0 new
  failed/error (only the pre-existing, unrelated `test_wordlist_coverage.R` failure). `lintr`: 4
  `implicit_integer_linter` style nits, fixed. **REFACTOR:** cached each union's parent `[lo, hi]`
  span (previously recomputed independently by Track 3's clamp loop and the new nudge loop) —
  structure only, byte-identical result re-confirmed via a 3rd `TDD: GREEN→REFACTOR` gate. **Runtime
  smoke test (Phase 3E):** headless — confirmed the app's own Pedigree Diagram call chain
  (`makePedigreeMatingLayout()`) runs clean on the real 375-individual bundled fixture (1412 nodes/
  1525 edges), no new errors. **Demonstration:** owner asked mid-session for a visual before/after
  vs. `kinship2` comparison; built one from a temporary git worktree at the pre-fix commit (F1
  fixture, `kinship2::plot.pedigree()` reference + nprcgenekeepr before/after), traced every
  parent-child edge programmatically against the source pedigree before trusting either rendering,
  and published as a shared Artifact (union x moves 0.12 → -6.0, matching kinship2's own centered
  convergence point far more closely) — not committed to the repo (an ephemeral demonstration, not a
  project deliverable). `NEWS.Rmd`/`NEWS.md`: new entry disclosing the fix and its 0/237 real-corpus
  scope. `BACKLOG.md`: Track 3 trade-offs item's child-centering half marked DONE (D1 bar-vs-bar half
  remains open). Investigation doc: status banner updated to IMPLEMENTED, new §12 recording the full
  RED/GREEN/REFACTOR/smoke-test record. `PROJECT_LEARNINGS.md`: Learnings 621-622. No GitHub issue —
  this item was tracked in `BACKLOG.md` only, matching the investigation's own established precedent.
  Follow-up commit `921d12f4`: corrected `HANDOFFS.md`'s own S602 receipt (its `commit:` field
  initially said `pending` despite `status: complete` — self-referencing a commit's own sha inside
  that same commit isn't possible; fixed to name both the claim and close-out commit shas, matching
  S600's own established precedent for this field).
- **Model:** Claude Sonnet 5.

### 2026-08-17 · [ad hoc] S601: duplicate-occurrence-selection centering — narrow repair converges (5th workflow attempt, first sound design in this investigation)
- **Session summary:** owner directed a narrowly-scoped repair (fix only the worse-than-erasure
  regression the pivot workflow found; leave the separately-accepted erasure trade-off alone) rather
  than a full 6th redesign. A 6-agent `Workflow` (`wf_f8b481f4-0f8`, 0 errors, ~1.04M subagent
  tokens, ~55 min): 2 independent repair candidates converged on an identical idea — a "Track-3-
  Engagement Gate" (`engaged(U) := |rawFinalUnitX[U] - clampedFinalUnitX[U]| > 1e-9`; suppress the
  nudge entirely when Track 3's own clamp never altered U's value, since a union it left untouched
  has nothing to repair). Synthesized; **fresh 3-lens adversarial critique returned
  `designStillSound: true` on all 3 lenses** — zero major findings, 3 minor ones. No 2nd repair round
  needed. **First design across 5 workflow attempts in this investigation (S598, S599, S600,
  S601×2) to survive a full adversarial critique cleanly.** Live-verified: closes the regression on
  multiple nested/chained reconstructions, leaves the target case and both no-op fixtures
  byte-identical to before, does not over-suppress a genuinely-needed correction, and is a provable
  pure pass-through for the separate erasure trade-off. Presented the milestone via `AskUserQuestion`
  (close out now / address 3 minor findings first); owner chose close out now, matching this
  project's plan/implementation session-boundary discipline (still PRE-RED, no code written).
  Appended full findings as the investigation doc's new §11; updated the doc's status banner and
  "start here" pointer (now §11.4) across all 3 places it appears. Added `PROJECT_LEARNINGS.md`
  Learnings 618-620 (a mandatory safety clamp can compose with a proven bound to produce a result
  worse than doing nothing; gate a repair mechanism on whether its own target constraint was actually
  binding; a fix's real-world qualifying frequency on the project's own test corpora is load-bearing
  go/no-go evidence). Refreshed `CLAUDE.md`'s `PROJECT_LEARNINGS.md` pointer (617→620 learnings,
  S600+→S601+).
- **Files:** `docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md` (§11 +
  banner), `BACKLOG.md` (Track 3 trade-offs progress note), `PROJECT_LEARNINGS.md` (Learnings
  618-620), `CLAUDE.md` (pointer refresh), `SESSION_NOTES.md`, `HANDOFFS.md` (close-out).
- **Model:** Claude Sonnet 5 (main loop); Claude Sonnet 5 (all subagents, both workflows).

### 2026-08-17 · [ad hoc] S601: duplicate-occurrence-selection centering — pivot to post-hoc-bounded-nudge (4th workflow attempt), still not sound, plus a zero-real-impact finding
- **Session summary:** picked up S600's investigation doc §9.7 item 1 go/no-go (`BACKLOG.md`'s Track
  3 trade-offs follow-up). Posed the go/no-go as a dedicated `AskUserQuestion` (accept Track 3
  trade-offs as permanent / pivot to post-hoc nudge / authorize a 4th pre-clamp attempt / hold);
  owner picked "pivot" — a mechanism shape untried by S598/S599/S600, all of which stayed on a
  pre-clamp substitution. A 12-agent `Workflow` (`wf_2d657d34-184`, 0 errors, ~2.10M subagent tokens,
  ~92 min): 4 independent post-hoc-nudge candidates (2 of 4 verified **zero** dependency on
  `preferAnchor()`/issue #162 — a genuine option no pre-clamp design ever had), synthesis, round-1
  critique (**all 3 lenses `designStillSound: false`**), repair, round-2 critique (**still false on 2
  of 3**): invariant-preservation reconfirmed a reclamp-erasure problem; edge-cases found something
  *worse* — a nested/chained sibling-consanguineous shape where the nudge actively corrupts a union
  Track 3 alone already positioned correctly, landing farther from the true center than either the
  nudge's own uncapped target or doing nothing. **New, independent finding: the qualifying condition
  never fires on either existing test corpus (0/4 `small`, 0/237 real 375-individual fixture)** — even
  a sound version of this mechanism would currently touch zero pedigrees this package tests or ships.
  **Four independent attempts across 2 structurally different mechanism families (S598-S600
  pre-clamp, S601 post-hoc) have now all failed adversarial critique.** Presented via
  `AskUserQuestion`; owner chose a narrowly-scoped repair over accepting Track 3's trade-offs as
  permanent, a full 5th redesign, or holding (see the following entry, same session). Appended full
  findings as the investigation doc's new §10 (workflow structure, 4-candidate table, synthesis, both
  critique rounds, the repair, the zero-real-impact finding, updated §10.7 open questions).
- **Files:** `docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md` (§10),
  `BACKLOG.md` (Track 3 trade-offs progress note).
- **Model:** Claude Sonnet 5 (main loop); Claude Sonnet 5 (all subagents).

### 2026-08-17 · [ad hoc] S600: duplicate-occurrence-selection centering — 3rd attempt (magnitude-bound), still not sound, plus an independent finding
- **Session summary:** picked up S599's investigation doc §8.6 open questions (`BACKLOG.md`'s Track 3
  trade-offs follow-up). Posed the §8.6 item 3 go/no-go as a dedicated `AskUserQuestion`
  (refine-with-magnitude-bounded-from-round-1 / pivot-to-post-hoc-nudge / run-both / accept-as-
  permanent); owner picked "refine." Ran a 3rd 12-agent design→synthesize→critique→repair→critique
  `Workflow` (`wf_be91a88b-c4c`, 0 errors, ~1.86M subagent tokens): Layers 1/2 held as given per
  S599's own §8.5 finding, 4 independent magnitude-bounding candidates each required to pass a
  magnitude-stress fixture from round 1 (S599's own self-identified process gap); 2 candidates
  independently converged on an identical "cap the substitution delta to `±K·minSep`" design.
  Synthesis claimed success on all 4 required fixtures. **Round-1 critique found the synthesis's
  entire success was contingent on silently reinterpreting Layer 1's own "given, do not redesign"
  qualification rule** — under the literal rule, Pass 2 is dead code for exactly the target case's
  own shape — plus a newly-load-bearing locale dependency in `preferAnchor()`'s tie-break. A repair
  round elevated both findings honestly and corrected the magnitude bound to a tighter universal
  form. **Round-2 critique (same 3 lenses, re-run fresh) still `designStillSound: false` on 2 of 3
  lenses**: the bound measures against the wrong reference frame (overshoots the real children's own
  span by 50% in the tightest, most common legitimate case, undetected across 2 full rounds), and
  the `preferAnchor()` locale bug is broader than characterized (already corrupts today's shipped
  output, structurally guaranteed for every full-sibling mate pair) — plus a live 120x pixel-scale
  bug in the design's own proposed RED test. Presented via `AskUserQuestion`; owner chose hold again,
  over one more repair round, pivoting to a post-hoc nudge, or accepting Track 3's trade-offs as
  permanent. Appended full findings as the investigation doc's new §9 (candidate table, both critique
  rounds, the independent finding, updated decision log, status banner) — §9.7 supersedes §8.6, now
  with a much stronger recommendation to treat a 4th attempt at this mechanism as needing
  justification, not the default (3 consecutive sessions have each failed at a deeper layer). Updated
  `BACKLOG.md`'s Track 3 trade-offs item with the S600 progress note. Added `PROJECT_LEARNINGS.md`
  Learnings 615 (a "given" component can be silently reinterpreted, must be checked against its
  literal wording), 616 (a provably-bounded quantity can still violate the invariant it protects if
  it measures the wrong reference frame), and 617 (closing one round's failure mode narrows but
  doesn't bound the search); `CLAUDE.md` learnings-count pointer refreshed (614→617).
- **Files:** `docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md`
  (§9 appended, status banner + decision log updated, a self-introduced References-section
  duplication caught and fixed before commit); `BACKLOG.md` (S600 progress note); `PROJECT_LEARNINGS.md`
  (Learnings 615-617); `CLAUDE.md` (learnings pointer); `SESSION_NOTES.md` / `HANDOFFS.md` (session
  claim + close-out).
- **Verification:** docs-only session, no `R/`/`tests/` file touched (confirmed via
  `git diff --stat`); no `devtools::check()`/regression/lint run needed. Every new cross-reference in
  the investigation doc re-verified to resolve before commit (including re-reading the file after the
  edit to catch the duplication bug above).
- Model: Claude Sonnet 5.

### 2026-08-17 · [ad hoc] S600: file preferAnchor() locale-non-determinism bug, found incidental to the above
- **Session summary:** the magnitude-bound workflow above independently discovered a real,
  pre-existing, standalone defect unrelated to whether the centering fix ever ships:
  `preferAnchor()` (`R/makePedigreeDiagramData.R:403-411`, Track 4's gen→mateCount→id tie-break)
  falls back to a bare `a < b` string comparison, confirmed live `LC_COLLATE`-locale-dependent — the
  same defect class as `PROJECT_LEARNINGS.md` Learning 585, but here confirmed to already corrupt
  today's shipped pipeline output for any tied-generation, tied-mate-count parent pair (proved
  structurally guaranteed for every full-sibling mate pair via `findGeneration()`'s BFS layering).
  Per Learning 382's "report, don't fix mid-session" precedent, not fixed this session — filed as
  [GitHub issue #162](https://github.com/rmsharp/nprcgenekeepr/issues/162) and a new `BACKLOG.md`
  Housekeeping item (READY, Effort S), with the suggested fix (Learning 585's own radix-based
  comparator) already named.
- **Files:** `BACKLOG.md` (new Housekeeping item). GitHub issue #162 filed (not a repo file change).
- **Verification:** n/a — issue filing and documentation only, no code change.
- Model: Claude Sonnet 5.

### 2026-08-17 · [ad hoc] S600: MIT license + REUSE compliance badge item added to BACKLOG (owner-directed)
- **Session summary:** owner asked to add a `BACKLOG.md` item for making the project MIT-licensed and
  adding license/REUSE badges to `README.Rmd`. Checked current state first rather than assuming the
  ask was unmet: `DESCRIPTION`'s `License: MIT + file LICENSE` plus tracked `LICENSE`/`LICENSE.md`
  have existed since S102's CRAN hygiene pass — presented this via `AskUserQuestion` rather than
  filing a redundant item; owner narrowed scope to the badges specifically. Split into 2 sub-items by
  risk: the MIT badge (a static shields.io image, safe to add, READY/Effort S) and the REUSE badge
  (a LIVE compliance check against api.reuse.software; verified this repo currently has none of what
  REUSE compliance requires — no `LICENSES/` dir, no SPDX headers, no `REUSE.toml`/`.reuse/dep5` — so
  adding it as-is would likely render red/non-compliant; flagged DECISION NEEDED with the concrete
  compliance path named, rather than adding a badge likely to embarrass the README).
- **Files:** `BACKLOG.md` (new Housekeeping item).
- **Verification:** n/a — documentation only, no code change.
- Model: Claude Sonnet 5.

### 2026-08-17 · [ad hoc] S599: duplicate-occurrence-selection centering redesign attempt — still not sound
- **Session summary:** picked up S598's investigation doc §6 open questions (`BACKLOG.md`'s Track 3
  trade-offs follow-up). Confirmed no code drift since S598's HEAD, then ran a 12-agent
  design→synthesize→critique→repair→critique `Workflow` (`wf_115a9428-581`, 0 errors): 4 independent
  candidate qualification-rule designs (Symmetric Blend, Sibling-Union-Count Abstention, 2-Child
  Eligibility Gate, Sole-Qualifying-Duplicate Gate — the last disqualified live, still misfires
  `0.7`), each live-verified via `pkgload::load_all()` against the target case (`-6`) and the
  primary counter-example (stays at raw `0.5`). Synthesized into "Sibling-Relationship-Count
  Abstention Guard"; round-1 adversarial critique found a NEW compounding misfire (2 different
  children of one union each substituting toward a shared 3rd sibling, `0.5→3.775`); repaired with a
  Layer-2 abstention ceiling that neutralized it (live-reconfirmed). **Round-2 critique on the
  repair still `designStillSound: false` on 2 of 3 lenses** — an unbounded-magnitude problem in the
  untouched "safe" single-substitution case (`-0.05→-16.238` live-measured as an unrelated
  fan-out grew, driven by the substitution formula itself, inherited unchanged from the original
  S592 design by every candidate tried across both S598 and this session) and a TDD white-box-test
  necessity (both abstention branches are output-identical to today's shipped behavior, so a
  black-box RED test would pass pre-implementation). Presented via `AskUserQuestion`; owner chose
  hold again, over one more targeted repair round or shipping disclosed. Appended full findings as
  the investigation doc's new §8 (candidate table, both critique rounds, updated decision log,
  status banner) — §8.6 supersedes §6 as the entry point for a future redesign session, with an
  explicit flag that a 3rd attempt should first weigh whether this is the right layer to fix
  child-centering quality at, given 2 consecutive attempts have now failed adversarial critique.
  Updated `BACKLOG.md`'s Track 3 trade-offs item with the S599 progress note. Added
  `PROJECT_LEARNINGS.md` Learnings 613 (a repair earns a fresh full critique, not a narrower re-check)
  and 614 (verifying direction ≠ verifying magnitude for a substitution-based design); `CLAUDE.md`
  learnings-count pointer refreshed (612→614, ~2.4→~2.5 MB).
- **Files:** `docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md`
  (§8 appended, status banner + decision log updated); `BACKLOG.md` (S599 progress note);
  `PROJECT_LEARNINGS.md` (Learnings 613-614); `CLAUDE.md` (learnings pointer); `SESSION_NOTES.md` /
  `HANDOFFS.md` (session claim + close-out).
- **Verification:** docs-only session, no `R/`/`tests/` file touched (confirmed via
  `git diff --stat`); no `devtools::check()`/regression/lint run needed. Every new cross-reference in
  the investigation doc verified to resolve before commit.
- Model: Claude Sonnet 5.

### 2026-08-16 · [ad hoc] S598: duplicate-occurrence-selection centering fix — investigation, held for redesign
- **Session summary:** picked up `BACKLOG.md`'s "Track 3's 2 disclosed trade-offs" item, scoped to
  the child-centering half only. Ran a 6-agent research/verify/adversarial-critique workflow
  against the never-adopted S592 "fix (a)" design (duplicate-occurrence substitution): confirmed it
  still fits current HEAD exactly at `R/makePedigreeDiagramData.R:974-994` and live-reproduced its
  headline number (0.12 shipped → -6 under the fix, issue #160 comment-1 fixture) — but one of 3
  adversarial critique lenses found a genuine, live-verified correctness gap inside the design's own
  claimed scope (a sibling mating 2 different co-siblings of the same union can move the union's
  center farther from true, not closer). Presented via `AskUserQuestion`; owner chose to hold for a
  redesign session rather than ship the flawed design (disclosed) or an unverified patch — 2
  candidate guards improvised live this session were both checked against the counter-example and
  both failed to exclude it. Wrote the full evidence record to
  `docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md` (explicitly an
  investigation, not a ratified plan) — flags a naming collision between `BACKLOG.md`'s informal
  "Track 4" shorthand for this fix and the unrelated, already-shipped
  `pedigree-diagram-track4-gen-aware-anchor-plan.md`. Updated `BACKLOG.md`'s Track 3 trade-offs item
  with the S598 progress note and next step. Also rendered the issue #160 comment-1 fixture through
  both `kinship2` and `nprcgenekeepr` (ad hoc, not committed) for a user-requested visual comparison,
  ground-truth-verified edge-by-edge before presenting. Added `PROJECT_LEARNINGS.md` Learnings 611
  (adversarial critique found a real gap in an already-multi-agent-vetted design) and 612 (the
  "Track 4" naming-collision gotcha); `CLAUDE.md` learnings-count pointer refreshed (610→612,
  S597+→S598+).
- **Commits:** `9b94d7ce` (Phase 1B session claim), plus this session's close-out commit.
- **Model:** claude-sonnet-5.

### 2026-08-16 · [ad hoc] S597: Phase 0 orientation + ledger backfill + stale-artifact correction — no BACKLOG item picked
- **Session summary:** did not pick or advance any of S596's 3 offered BACKLOG priorities (Track 3
  trade-offs decision / issue #161 / S582 screenshot check); Phase 1 was never completed. Ran a
  full Phase 0 orientation (found and backfilled a real 2-commit `CHANGELOG.md` gap left by S596's
  own close-out, commit `8fc0e383` — see the entry directly below), then followed a user-directed
  browser detour into an unplanned side-quest: reviewed a previously-published claude.ai "Pedigree
  Fidelity Proof" artifact and found its "not previously reported" defect callout was stale —
  verbatim `PROJECT_LEARNINGS.md` Learning 604, already fixed twice over by Tracks 1–2 — traced its
  stamped commit `f12e7cbb` to Session 590, predating issue #160's own filing. Regenerated both
  comparison plates fresh against current HEAD (`pkgload::load_all()` + `chromote`), with
  independently re-derived (non-circular) ground-truth collision verification: 0 same-row
  collisions on both plates; Track 1's fix confirmed via exact node coordinates (D1 bar row 60
  units off the children's row, matching `sibshipBarFraction=0.4`); the one flagged residual on
  Plate 2 confirmed to be the known, already-disclosed curved-heuristic case, not new. Republished
  to the same artifact URL with a correction callout. This artifact is external (claude.ai-hosted),
  not git-tracked — its render script lived only in this session's ephemeral scratchpad. At
  close-out, completed a dropped mid-conversation user request: `BACKLOG.md`'s Track 3 trade-offs
  item gained a 3rd possibility (a bar-aware detect-and-jog repair for the D1 bar-vs-bar residual
  specifically). Added `PROJECT_LEARNINGS.md` Learning 610 (a previously-published external
  artifact's stamped commit sha can go stale with nothing in Phase 0's own ledger-reconcile
  positioned to catch it, since that reconcile only walks git-tracked files). `CLAUDE.md`
  learnings-count pointer refreshed (609→610). No R/production code touched; no runtime smoke test
  applicable. `HANDOFFS.md` `status: complete` receipt written (self-assessment 6/10 — real ledger
  and stale-artifact fixes, but no BACKLOG priority advanced this session).

### 2026-08-16 · [issue #160] S596 close-out: handoff evaluation, self-assessment, Learning 609, HANDOFFS.md receipt
- **Close-out actions (reconcile-on-read backfill, Session 597 Phase 0):** evaluated S595's handoff
  (8/10, `SESSION_NOTES.md`); self-assessed this session (9/10); completed the `HANDOFFS.md`
  `status: complete` receipt (all 6 fields); added `PROJECT_LEARNINGS.md` Learning 609
  (testthat/waldo tolerance-semantics gotcha — `expect_equal()`/`all.equal()` with a bare
  `tolerance=N` is scale-relative, not absolute) and refreshed `CLAUDE.md`'s stale learnings-count
  pointer (604→609 learnings, S591+→S596+). Next session's candidates named in the handoff: (1)
  decide the fate of Track 3's 2 disclosed trade-offs (new `BACKLOG.md` follow-up item), (2) issue
  #161's now-unblocked deferred decision, (3) the small S582 stale-screenshot check — none
  mandated. Commits: `6261d6f9` (Learning 609 + `CLAUDE.md` refresh), `6ba6289e`
  (`HANDOFFS.md`/`SESSION_NOTES.md` close-out). This entry itself was the gap: S596 wrote the
  Track 3 deliverable entry below but, unlike S595's own "close-out" entry precedent, never logged
  a matching entry for these 2 trailing commits — caught by Session 597's Phase 0 ledger reconcile
  (`CHANGELOG.md` frontier `e4795723` vs. `HEAD` `6ba6289e`).

### 2026-08-16 · [issue #160] S596: Track 3 (S583 parent-span clamp) shipped
- **Deliverable:** new clamp loop in `.positionMatingUnitForest()` (`R/makePedigreeDiagramData.R`)
  — plan §2.3/§6 Session C of
  `docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`. Clamps each mating unit's
  `finalUnitX` into its own 2 parents' `[min, max]` x-range whenever the child-centered formula
  would place it outside that span — a disclosed, owner-ratified reopening of Track 6 §2.4's
  "unconditionally" wording (S592 §9, re-confirmed via this session's own PRE-RED
  `AskUserQuestion`). Skips a union with a dangling (free-pass) parent rather than propagating
  `NA` — found live this session, fixed after regressing 2 pre-existing tests. Reproduced
  BACKLOG.md's own S583 example byte-for-byte via `trimPedigree()` against the real
  375-individual bundled fixture, plus the 9-subject consanguineous fixture BACKLOG names.
  **2 trade-offs found during REFACTOR, both disclosed and owner-accepted via `AskUserQuestion`:**
  the plan's own §7 faithful child-centering metric worsens (9/251 → 53/251 child edges over the
  200-unit threshold, max offset 4,121 → 10,627), and the already-disclosed D1 bar-vs-bar
  x-overlap residual (plan §8) worsens substantially (9 → 116 post-Track-1 hits) — both trace to
  the same mechanism (pulling a runaway union back toward its own parents moves it away from its
  children and back toward neighboring subtrees). Beneficial side effect: Track 2's own same-row
  collision baseline drops (150 → 105 edges, node count 1,502 → 1,412). Updated
  `test_positionMatingUnitForest.R`, `test_resolveEdgeNodeCollisions.R`,
  `test_makePedigreeMatingLayout.R`, `test_addRectilinearWaypoints.R` with disclosed,
  behavior-driven golden-value churn. `devtools::check()` 0 errors/0 warnings/1 pre-existing NOTE;
  full clean regression 0 failed/0 error; `lintr::lint_package()` no lints. `NEWS.Rmd`/`NEWS.md`
  entry added. `BACKLOG.md`'s Track 3 and S583 items marked DONE; a new follow-up item filed for
  the 2 accepted trade-offs. Commits: `8b8e399d` (RED), plus this session's GREEN+REFACTOR and
  close-out.

### 2026-08-15 · [issue #160] S596 claim: implement Track 3 (S583 parent-span clamp)
- **Deliverable claimed:** plan §2.3/§6 Session C of
  `docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md` — clamp `finalUnitX` into
  its own 2 parents' `[min, max]` range in `.positionMatingUnitForest()`. Session stub written to
  `SESSION_NOTES.md`; `HANDOFFS.md` `status: pending` receipt opened. Work beginning.

### 2026-08-15 · [issue #160] S595 close-out: handoff evaluation, self-assessment, Learning 608, HANDOFFS.md receipt
- **Close-out actions:** evaluated S594's handoff (8/10, `SESSION_NOTES.md`); self-assessed this
  session (8/10); completed the `HANDOFFS.md` `status: complete` receipt (all 6 fields, including a
  disclosed process note about the missed GREEN→REFACTOR gate); self-flagged and disclosed that
  gap to the user via `AskUserQuestion` before proceeding, rather than after. Next session's
  recommended pickup: Track 3 (S583 parent-span clamp, plan §2.3/§6 Session C — its own PRE-RED
  reopening-confirmation gate required first).

### 2026-08-15 · [issue #160] S595: Track 2 (general same-row detect-and-jog framework) shipped, issue #160 closed
- **Deliverable:** new `.resolveEdgeNodeCollisions()` (`R/makePedigreeDiagramData.R`), wired into
  `makePedigreeMatingLayout()`'s `edgeStyle == "rectilinear"` branch — plan §2.2/§6 Session B of
  `docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`. Detects and repairs any
  straight same-row edge colliding with an unrelated node (a strictly rectilinear 2-waypoint
  "step," never moving an existing node); the curved duplicate connector gets a disclosed
  `smooth.roundness`-bump heuristic instead, visually confirmed via `chromote`. Found and fixed 2
  real implementation bugs mid-REFACTOR (jog-vs-jog collisions from a single shared row offset;
  color/label identity loss on twin-connector/consanguinity-marker edges), both caught by the full
  regression + rendered-image verification, not assumed. Real 375-individual bundled fixture: 150
  → 0 straight-edge collisions (3,081 obstacle-pairs pre-fix); 52 curved-heuristic residuals
  disclosed. `devtools::check()` 0 errors/0 warnings/1 pre-existing NOTE; full clean regression 0
  failed/0 error; `lintr::lint_package()` no lints. `NEWS.Rmd`/`NEWS.md` entry added.
  `BACKLOG.md`'s Track 2 and issue #160 items marked DONE. GitHub issue #160 closed citing both
  Session A (S593) and this session's evidence. Commits: `89d23e2a` (RED), `c7bdbe4b`
  (GREEN+REFACTOR), plus this close-out.

### 2026-08-15 · [issue #160] S595 claim: implement Track 2 (general same-row detect-and-jog collision framework)
- **Deliverable claimed:** plan §2.2/§6 Session B of
  `docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md` — new
  `.resolveEdgeNodeCollisions()` wired into `makePedigreeMatingLayout()`. Session stub written to
  `SESSION_NOTES.md`; `HANDOFFS.md` `status: pending` receipt opened. Work beginning.

### 2026-08-15 · [ad hoc] S594 close-out: SESSION_NOTES.md archive DONE, stale CLAUDE.md fence-scanner note corrected (Session 594)
- **Deliverable:** Lossless archive trim of `SESSION_NOTES.md` — **DONE.** Found the `CLAUDE.md`
  "archive blocked by a fence-scanner defect (S518)" note stale: that defect and a second,
  independent `\b`-boundary defect were fixed S527/S528, and 2 archive rounds had already run
  successfully since. The actual live blocker was a fresh `SRF_RED` refusal (SRF 2.0371 vs.
  0.0576, a 35.35x spread across two archive boundaries) — the same pattern
  `PROJECT_LEARNINGS.md` Learnings 549/586/587 diagnosed for `CHANGELOG.md`/`HANDOFFS.md`, and
  which Learning 587 explicitly predicted would recur here. Surfaced both readings +absolute
  byte deltas via `AskUserQuestion`; owner chose `--force`. `methodology_trim.py --force --write`
  archived 76 records to `docs/archive/SESSION_NOTES-through-2026-08-15.md` (see the tool's own
  entry directly below); L1/L2/L3 losslessness confirmed both by the tool's console output and
  independently via the generated `.verify.sh` script. Dashboard HIGH+ risk 1 → 0 (health
  unchanged, 96/100). Corrected the `CLAUDE.md` note to the verified current state. Added
  `PROJECT_LEARNINGS.md` Learning 607 (stale-persistent-note pattern; Learning 587's prediction
  confirmed). No `BACKLOG.md` item existed for this — nothing to remove there. Commits: `a3c8f1c9`
  (claim, self-corrected a same-session date typo), plus this close-out.

### 2026-08-15 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-08-15.md` (76 record(s), 397,442 B → 5,262 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **76** record(s) (2026-01-26 → 2026-08-15) out of [`SESSION_NOTES.md`](SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-08-15.md`](docs/archive/SESSION_NOTES-through-2026-08-15.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh)
rather than trusting a digest printed here. Live file 397,442 B → 5,262 B (−98.7%).

### 2026-08-15 · [ad hoc] S594 claim: lossless archive trim of SESSION_NOTES.md (Session 594)
- **Deliverable:** Lossless archive trim of `SESSION_NOTES.md`, user-directed at Phase 0 (dashboard
  HIGH-risk flag, file at 4,645 lines / 395,482 B). PRE-RED investigation: the `CLAUDE.md` note
  framing this as blocked by a `methodology_trim.py` fence-scanner defect (S518) is stale — both
  that defect and the follow-on `\b`-boundary defect (S527, `PROJECT_LEARNINGS.md` Learning 533)
  were already fixed (S527/S528) and two archives already succeeded. Actual current blocker: a
  fresh `SRF_RED` refusal (SRF 2.0371 vs. 0.0576, 35.35x spread across two archive boundaries),
  matching the `CHANGELOG.md`/`HANDOFFS.md` pattern `PROJECT_LEARNINGS.md` Learnings 549/586/587
  already diagnosed. Session claimed; decision pending.

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

### 2026-08-15 · [BL-1] S593: close out (Track 1 -- D1 sibship-bar row offset, issue #160)
- **Deliverable:** Track 1 (D1 sibship-bar genuine intermediate row) shipped, closing issue
  #160's 2 originally-reported collisions. `sibshipBarFraction = 0.4` added to
  `.addRectilinearWaypoints()`'s D1 loop (`R/makePedigreeDiagramData.R`). Reproduced byte-for-byte
  against the actual `kinship2::sample.ped` family 2 fixture cited in the collision-avoidance
  plan's own evidence — both collisions confirmed cleared.
- **Two disclosed residuals found during implementation** (neither anticipated by the plan's
  Session A bullet in the bar-vs-node case; the bar-vs-bar case was named as an open gotcha by
  S592's own handoff, checked and measured here): (1) no fixed rational `sibshipBarFraction` is
  collision-free for every generation gap — 2/488 waypoints collide on the real fixture for a
  gap-5 union; (2) two different sibships sharing a generation gap can still land bars on the
  identical row if x-ranges overlap — 42 cases before Track 1, 9 after (79% reduction, not
  elimination). Both counted in a permanent regression test, disclosed in `NEWS.Rmd`/`BACKLOG.md`/
  2 GitHub issue #160 comments, deferred to Track 2 (gap-agnostic general detect-and-jog).
- **Action taken:** `lintr::lint_package()` clean on both touched files. Full clean regression
  (`NOT_CRAN` set, `load_all()` first): 0 failed/0 error, twice. `devtools::check()`: 0 errors/0
  warnings/1 NOTE (pre-existing `vignettes/figure` knitr leftover, dated Aug 11, unrelated).
  `NEWS.Rmd`/`NEWS.md` entries added and rendered. 2 GitHub issue #160 comments posted with full
  evidence. `BACKLOG.md` Track 1 item marked DONE. Checked `vignettes/articles/kinship2-fidelity-
  validation.qmd` for stale screenshots (1 image technically affected, judged not stale for the
  unrelated feature it documents, not regenerated — disclosed, not silently decided). Issue #160
  not closed — Track 2 still required. Commits: `71ce091c` (implementation), `6cb913fc`
  (bar-vs-bar residual disclosure + test), plus this close-out.
- **Protocol note:** the GREEN→REFACTOR `AskUserQuestion` gate was skipped mid-session (proceeded
  directly from a passing GREEN run into lint/regression/`devtools::check()`/NEWS/GitHub-comment
  work) — caught before Phase 3 close-out, acknowledged per `CLAUDE.md`'s Error Handling section,
  retroactively confirmed via `AskUserQuestion` before continuing. See `SESSION_NOTES.md`
  Self-Assessment for the full account.

### 2026-08-15 · [BL-1] S593: claim session (implement Track 1 -- D1 sibship-bar row offset)
- **Deliverable (in progress):** Implement Track 1 (D1 sibship-bar genuine intermediate row) --
  Session A of `docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md` §2.1/§6
  (`BACKLOG.md`, found S592, READY, Effort S). User selected this item from the Phase 0
  priorities picker over Track 2, Track 3, and issue #148 scoping.
- **Action taken:** Claim stub written to `SESSION_NOTES.md`; `status: pending` receipt opened
  in `HANDOFFS.md`. Full PRE-RED -> RED -> GREEN -> REFACTOR TDD gates to follow.

### 2026-08-15 · [ad hoc] S592: reconcile HANDOFFS.md commit self-reference (14a405b1)
- **Action taken:** updated S592's own `HANDOFFS.md` receipt `commit:` field from the
  write-time placeholder (`b600b43a, plus this close-out`) to the actual close-out commit sha
  (`b600b43a, 14a405b1`), matching the established S589/S590/S591 precedent for this
  self-referential field.

### 2026-08-15 · [BL-1] S592: close out — root-cause architecture plan (issues #160/#161/S583 collision-avoidance gap)
- **Deliverable:** `docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md` — a
  3-track phased architecture plan addressing the shared "no same-row collision-avoidance for
  placement" root cause behind issues #160, #161, and the S583 union-position gap. Built via a
  12-agent research/design/judge `Workflow` (5 research readers, 4 independent candidate
  architectures, 3 independently-lensed judges — 12/12 completed, 0 errors); no single candidate
  won on all 3 judge lenses, so this document synthesizes the highest-scoring, judge-vetted piece
  of each rather than adopting one wholesale. Owner-ratified via `AskUserQuestion` (both
  Recommended options selected: the 3-track synthesis, and deferring issue #161's
  marker-visibility decision until Tracks 1–3 ship).
- **Tracks:** Track 1 (D1 sibship-bar genuine intermediate row — an unconditional geometric
  guarantee, no detection logic, closes issue #160's 2 originally-reported collisions); Track 2
  (general same-row detect-and-jog framework wired into `makePedigreeMatingLayout()` itself so
  every caller benefits — closes issue #160 comment 1's broadened finding); Track 3 (parent-span
  clamp on `finalUnitX`, a deliberate disclosed reopening of Track 6 §2.4, its own PRE-RED gate at
  implementation time — closes the S583 item). The narrower duplicate-occurrence-selection root
  fix and issue #161 are named, not scheduled/deferred, not implemented.
- **Not implemented this session** — planning session, output is the document, not code; no
  `R/`/`tests/` file touched, TDD phases INAPPLICABLE (matches the S588/S589/S590 precedent).
- **Action taken:** commented on issues #160 and #161 linking the plan (neither closed — both
  remain open pending implementation); updated `BACKLOG.md` (planning item marked DONE, 3 new
  READY/DECISION-NEEDED implementation items added, the #160/#161/S583 items annotated with
  pointers to the plan); verified every cross-referenced file/citation in the plan resolves.

### 2026-08-15 · [BL-1] S592: claim session (root-cause planning: issues #160/#161/S583 collision-avoidance gap)
- **Deliverable (in progress):** Planning session addressing `BACKLOG.md`'s "Active" item (found
  S591) — the shared "no same-row collision-avoidance for placement" root cause behind issues
  #160, #161, and the S583 union-position gap, following `ARCHITECTURE_WORKSTREAM.md`. User
  selected this item from a 4-option Phase 0 priorities picker over the two narrower
  decision-only alternatives (#160 alone, #161 alone) and the lower-priority/informational bucket.
- **Action taken:** Claim stub written to `SESSION_NOTES.md`; `status: pending` receipt opened in
  `HANDOFFS.md`. Dispatched a 12-agent research/design/judge `Workflow` (5 parallel research
  readers over `.positionMatingUnitForest()`/`.addRectilinearWaypoints()`, a grep-based call-site
  inventory, Track 4/6 ratified-invariant extraction, and prior-spike history; 4 independent
  collision-avoidance candidate architectures; 3 independently-lensed judges) to ground the plan
  in verified evidence before writing it.

### 2026-08-15 · [ad hoc] S591: close out (live investigation — issues #160/#161, no code changed)
- **Deliverable:** Close-out for a session with no pre-declared task (Phase 1B was skipped — see
  `SESSION_NOTES.md` self-assessment) that ran as organic, user-driven investigation: answered a
  history question via a 5-agent research workflow, corrected 2 self-caught-by-user errors (a
  mischaracterized evidence source; tool-result images that never reached the user), generated
  fresh current-HEAD kinship2-vs-nprcgenekeepr renders and published them as an Artifact, found
  and filed 2 real pedigree-diagram rendering defects (issues #160, #161) with coordinate-level
  evidence, confirmed the already-tracked S583 `BACKLOG.md` item live, and added a planning-session
  `BACKLOG.md` item for the shared root cause. Full narrative in `SESSION_NOTES.md` "What Session
  591 Did." `PROJECT_LEARNINGS.md` Learning 604 added (verify-against-ground-truth methodology
  gap); `CLAUDE.md`'s stale learnings-count pointer fixed (603→604, S590→S591). Self-score 6/10 —
  real weaknesses named plainly (Phase 1B skipped; TDD phase never declared per-response; session
  shape doesn't fit the "one deliverable" model). No `R/`/`tests/` file touched; runtime smoke test
  n/a. `HANDOFFS.md` receipt written directly as `status: complete` (no prior `pending` stub
  existed, since Phase 1B was skipped).

### 2026-08-15 · [BL-N] Added planning-session backlog item for the shared collision-avoidance gap
- **Deliverable:** Owner-directed. Added a `BACKLOG.md` Active item proposing a dedicated planning
  session to address the shared root cause behind issue #160, issue #161, and the S583
  union-position item — all trace to `.positionMatingUnitForest()`/`.addRectilinearWaypoints()`
  computing node/edge placement locally with no check for what else occupies that x/y region. No
  code changed; the item itself asks for a plan document, not an implementation, per
  `SESSION_RUNNER.md`'s Planning Sessions discipline.

### 2026-08-15 · [ad hoc] Push commits (`ea49636e..25697bb9`)
- **Deliverable:** Owner-directed. Pushed 11 local commits (S588-S590's own claim/deliverable/
  reconcile docs, plus this conversation's issue #160/#161 ledger entries) to `origin/master`,
  clean fast-forward, no force.

### 2026-08-15 · [issue #161] Filed pedigree-diagram mating-unit-marker kinship2-parity question
- **Deliverable:** Filed [issue #161](https://github.com/rmsharp/nprcgenekeepr/issues/161) — found
  live in conversation reviewing a fresh render of the `A x Y` consanguineous fixture against
  kinship2. kinship2 draws no marker for a mating (a plain line intersection); nprcgenekeepr draws
  a small filled circle for every `__union_N` node. Mechanically feasible via the same
  `size = 0` + transparent-color technique already used for invisible D1/D2 rectilinear waypoints
  (issue #142, S465), but a genuine design question, not an obvious fix. Not implemented — needs a
  decision first. Also added to `BACKLOG.md` Active.

### 2026-08-15 · [issue #160] Commented with a second, broader reproduction
- **Deliverable:** Commented on [issue #160](https://github.com/rmsharp/nprcgenekeepr/issues/160#issuecomment-5304476340)
  with a second fixture (the `A x Y` consanguineous example) showing a more severe instance of the
  same defect: P1×P2's own union lands entirely outside their parents' span (traced to Track 6's
  centering formula using a duplicated child's *real*, far-away occurrence instead of the nearby
  duplicate), and the resulting over-stretched sibship bar collides with both an unrelated node (W)
  and a duplicate-connector dashed edge. Broadens the diagnosed root cause: the collision isn't
  specific to the sibship-bar D1 loop — any straight same-row edge (sibship bar or
  duplicate-connector) lacks collision-avoidance against an intervening node. Also annotated the
  related-but-distinct `BACKLOG.md` S583 item (union-outside-parents'-span) with a 3-instance live
  reconfirmation of that already-tracked gap on the same fixture (X×A, A×Y, W×Y unions each
  collapsing to their one child's x) — not filed as a new issue, since it's the same gap already
  tracked there. No code changed.

### 2026-08-15 · [issue #160] Filed pedigree-diagram rectilinear sibship-bar false-parentage defect
- **Deliverable:** Filed [issue #160](https://github.com/rmsharp/nprcgenekeepr/issues/160) — found
  live in conversation (not a claimed session), while generating fresh kinship2-vs-nprcgenekeepr
  comparison renders from current HEAD (`f12e7cbb`) to visually verify the Track 1-6
  kinship2-fidelity remediation effort. On `kinship2::sample.ped` family 2 (14 people, no
  multi-mate individuals — the project's own "cleanest comparison" fixture), under
  `edgeStyle = "rectilinear"` (the current shipped default since Track 2, S574): the rectilinear
  sibship-bar waypoints sit at the exact same y as the children's own row (zero vertical drop from
  an intermediate bar row), so the bar reads as a straight mate-line chain — and 2 unrelated nodes
  (203×204's own mating-unit dot; 209, a marry-in founder with no blood relation to 201×202) land
  directly on that line, each visually implying a parent-child relationship that does not exist.
  Confirmed against `makePedigreeMatingLayout()`'s own returned `nodes`/`edges` (coordinate
  collision, not a rendering artifact) and against a pixel-level screenshot crop of both collision
  points. Root cause is a pre-existing design gap in `.addRectilinearWaypoints()` (issue #142) —
  not a regression from Track 1-6, which measured edge orthogonality but never checked for
  coordinate collisions between unrelated nodes. Not fixed this conversation — no session claimed,
  reported per the established "report, don't fix mid-session" precedent (`PROJECT_LEARNINGS.md`
  Learning 382); needs its own design pass. See issue #160 for full reproduction steps and
  evidence.

### 2026-08-15 · [BL-N] S590: close out (pedigree-diagram layout SECOND feasibility spike -- igraph::layout_with_sugiyama())
- **Deliverable:** Ran the pedigree-diagram layout SECOND feasibility spike (`BACKLOG.md`, found
  S589, HIGH PRIORITY) — `docs/planning/pedigree-diagram-layout-sugiyama-spike-plan.md` + a
  runnable evidence document, `docs/planning/pedigree-diagram-layout-sugiyama-spike-evidence.qmd`.
  Adapted `igraph::layout_with_sugiyama()` (owner-selected via `AskUserQuestion` over a ported
  Brandes-Köpf 2002 alternative), reusing S589's own faithful harness verbatim. Found and fixed 2
  real methodological issues en route: a stale renv-cached installed package build (predates
  Track 6 by ~3.5h — `library(nprcgenekeepr)` silently loads it; `pkgload::load_all()` used
  throughout instead) and `layout_with_sugiyama()`'s own vertex-order-sensitive crossing
  heuristic (mitigated via standard multi-restart). Synthetic example: 20% gap reduction, 0
  crossings (matching S589's own candidate). Real 375-individual fixture: **regressed** on every
  axis measured (9/251→25/251 edges over threshold, max offset 4,121→10,110, crossings
  3,174→5,916), confirmed not a tuning artifact via a restart/seed sweep and an edge-weight
  check. **Verdict: NOT FEASIBLE as prototyped.** This is the THIRD independently-designed
  candidate to regress the real fixture. Owner-ratified: **close the non-rigid-layout
  investigation as inherent** — no further spike scoped on this thread. Updated `BACKLOG.md`
  (item DONE, no new spike item added); commented on and **closed** GitHub issue #159 with the
  cumulative 3-candidate evidence. Added `PROJECT_LEARNINGS.md` Learnings 601–603; fixed a stale
  learnings-count cross-reference in `CLAUDE.md`. Planning/investigation session, TDD phases
  inapplicable — no `R/` file touched.

### 2026-08-15 · [BL-N] S590: claim (pedigree-diagram layout SECOND feasibility spike)
- **Deliverable:** Non-commit-adjacent claim entry per Phase 1B. Session claimed to run the
  pedigree-diagram layout SECOND feasibility spike (`BACKLOG.md`, found S589, HIGH PRIORITY) —
  adapt `igraph::layout_with_sugiyama()` (owner-selected via `AskUserQuestion`), tested against
  the same two fixtures S589 used. Planning/investigation session, TDD phases inapplicable.

### 2026-08-15 · [ad hoc] S590: reconcile HANDOFFS.md commit self-reference (`f3492719`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> the real
  sha (`f3492719`, close-out) — unknowable until after that commit existed. Matches the
  established S562-S589 precedent.

### 2026-08-15 · [ad hoc] S589: reconcile HANDOFFS.md commit self-reference (`691071a0`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> the real
  sha (`691071a0`, close-out) — unknowable until after that commit existed. Matches the
  established S562-S588 precedent.

### 2026-08-15 · [BL-N] S589: close out (pedigree-diagram non-rigid layout feasibility spike)
- **Deliverable:** Ran the pedigree-diagram layout feasibility spike (`BACKLOG.md`, found S588,
  HIGH PRIORITY) — `docs/planning/pedigree-diagram-nonrigid-layout-spike-plan.md` + a runnable
  evidence document, `docs/planning/pedigree-diagram-nonrigid-layout-spike-evidence.qmd`.
  Prototyped a barycenter/median layered-DAG compaction candidate (owner-selected via
  `AskUserQuestion`): 20% gap reduction and zero edge crossings on the synthetic example, but
  **regressed** the real 375-individual fixture under a faithful full-pipeline measurement
  (9/251→15/251 edges over threshold, 6.1x layout-width growth), root-caused to convergence
  instability at high-mate-count "hub" individuals. **Verdict: NOT FEASIBLE as prototyped.**
  Owner-ratified recommendation: a second, narrower spike adapting a proven library
  (`igraph::layout_with_sugiyama()`) rather than tuning this candidate further; campaign document
  deferred. Updated `BACKLOG.md` (S588 item DONE, new READY item for the 2nd spike); commented on
  GitHub issue #159 (not closed). Added `PROJECT_LEARNINGS.md` Learnings 598–600; fixed a stale
  learnings-count cross-reference in `CLAUDE.md`. Planning/investigation session, TDD phases
  inapplicable — no `R/` file touched.

### 2026-08-15 · [BL-N] S589: claim (pedigree-diagram layout feasibility spike)
- **Deliverable:** Non-commit-adjacent claim entry per Phase 1B. Session claimed to run the
  pedigree-diagram layout feasibility spike (`BACKLOG.md`, found S588, HIGH PRIORITY) —
  prototype one non-rigid/constraint-aware layout candidate (barycenter/median layered-DAG
  compaction, owner-selected via `AskUserQuestion`), tested against the synthetic example and a
  faithful real-fixture reproduction. Planning/investigation session, TDD phases inapplicable.

### 2026-08-15 · [ad hoc] S588: reconcile HANDOFFS.md commit self-reference (`999c3b74`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: ... this close-out
  commit` -> the real sha (`999c3b74`, close-out) — unknowable until after that commit existed.
  Matches the established S562-S587 precedent.

### 2026-08-15 · [BL-N] S588: close out (pedigree-diagram sibling subtree-width asymmetry design)
- **Deliverable:** Designed a fix for "Pedigree Diagram: sibling subtree-width asymmetry"
  (`BACKLOG.md`, found S576) — `docs/planning/pedigree-diagram-sibling-subtree-width-plan.md` +
  a runnable evidence document, `docs/planning/pedigree-diagram-sibling-subtree-width-evidence.qmd`.
  Built a 13-individual synthetic reproduction, rendered it via kinship2 and nprcgenekeepr side by
  side, and empirically tested one candidate (bounded-depth contour-merge lookahead) — rejected: it
  closed the toy-example gap but introduced an edge crossing and regressed a real-fixture proxy
  measure. Found the deeper reason no low-risk tuning of the current algorithm can work (the
  rigid-subtree model shared with the Reingold-Tilford/Walker/Buchheim-Jünger-Leipert family issue
  #141 names). First ratified DEFER (Round 1); owner corrected mid-session ("high priority, work
  cost is not a deterrent"); re-ratified COMMIT to a redesign (Round 2, both rounds recorded
  transparently). Filed GitHub issue #159, then updated it to reflect Round 2. Updated `BACKLOG.md`
  (S576 item DONE; new READY high-priority feasibility-spike item added). Wrote
  `PROJECT_LEARNINGS.md` Learnings 596 (test candidates against both a toy example and the real
  fixture, render output not just metrics) and 597 (surface priority/cost-tolerance questions
  explicitly via `AskUserQuestion` rather than inferring them from measured technical severity).

### 2026-08-15 · [BL-N] S588: claim (design a fix for pedigree-diagram sibling subtree-width asymmetry)
- **Deliverable:** Non-commit-adjacent claim entry per Phase 1B. Session claimed to design a fix
  for "Pedigree Diagram: sibling subtree-width asymmetry" (`BACKLOG.md`, found S576) — one
  architecture/design document, planning session, TDD phases inapplicable.

### 2026-08-15 · [ad hoc] S587: push commits (`d6deec73..94fcab60`)
- **Deliverable:** Non-commit action, recorded per failure mode #27. Owner-directed push of this
  session's 4 commits (`8b4d0f18` claim, `45b44585` fix + close-out, `8d4ae826` HANDOFFS.md
  reconcile, `94fcab60` CHANGELOG reconcile-of-reconcile) — the `inst/WORDLIST` fix. Clean
  fast-forward, no force. `master` and `origin/master` in sync.

### 2026-08-15 · [ad hoc] S587: reconcile HANDOFFS.md commit self-reference (`45b44585`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: ... close-out commit
  sha to follow` -> the real sha (`45b44585`, fix + close-out) — unknowable until after that
  commit existed. Matches the established S562-S586 precedent.

### 2026-08-15 · [BL-N] S587: close out (R-CMD-check.yaml CI fix — inst/WORDLIST gap)
- **Deliverable:** Fix the red `R-CMD-check.yaml` CI (`BACKLOG.md` Housekeeping, found S584) —
  added 4 words `spelling::spell_check_package()` flags (`matings`, `Rectilinear's`, `runnable`,
  `visNetwork's`) to `inst/WORDLIST`, each at its alphabetic neighbor. All 4 confirmed via grep as
  legitimate tracked-source domain/package-name terms before whitelisting, not typos. Owner
  interrupted mid-verification to question running the full `test_dir()` clean regression for a
  non-code data-file change — corrected to `devtools::check()` alone (the literal CI-matching
  build equivalent): 0 errors/0 warnings/1 pre-existing unrelated NOTE; `test_wordlist_
  coverage.R` 3/3 passing. Written up as `PROJECT_LEARNINGS.md` Learning 595. Removed the
  completed item from `BACKLOG.md` Housekeeping.

### 2026-08-15 · [BL-N] S587: claim (fix red R-CMD-check.yaml CI)
- **Deliverable:** Non-commit-adjacent claim entry per Phase 1B. Session claimed to fix the
  `inst/WORDLIST` gap `BACKLOG.md` Housekeeping filed at S584.

### 2026-08-15 · [ad hoc] S586: push commits (`c17451e7..981e463c`)
- **Deliverable:** Non-commit action, recorded per failure mode #27. Owner-directed push of this
  session's 3 commits (`a8367a4f` claim, `b1e8f8f2` fix + close-out, `981e463c` HANDOFFS.md
  reconcile) — the lint.yaml fix plus the CLAUDE.md verification-formula correction. Clean
  fast-forward, no force. `master` and `origin/master` in sync.

### 2026-08-15 · [ad hoc] S586: reconcile HANDOFFS.md commit self-reference (`b1e8f8f2`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: ... close-out commit
  sha to follow` -> the real sha (`b1e8f8f2`, fix + close-out) — unknowable until after that commit
  existed. Matches the established S562-S585 precedent.

### 2026-08-15 · [BL-N] S586: close out (lint.yaml CI fix — R/kinship.R nested-ifelse + implicit-integer)
- **Deliverable:** Fix the red `lint.yaml` CI (`BACKLOG.md` Housekeeping, found S584) — 3
  pre-existing lints in `R/kinship.R:127,131,133` from S564's X-chromosome kinship work — DONE.
  Collapsed the nested `ifelse()` computing `sexNum` (line 126-128) into a single vectorized
  `match()`/index lookup (`c(1L, 2L)[match(sex, c(sexCodes[["male"]], sexCodes[["female"]]))]`),
  provably behavior-identical by R's own coercion/indexing semantics; changed the two bare `0`
  literals in `c(founderDiag, 0)` (sparse and dense branches) to `0.0`. Strict-TDD: a pre-RED
  scope decision (close a found test-coverage gap before touching the sparse branch), PRE-RED→RED,
  and GREEN→REFACTOR (declined, recommended) all fired as `AskUserQuestion` gates before their
  phase's first edit.
- **Pre-RED finding:** no existing test combined `chrtype = "x"` with `sparse = TRUE` — the dense
  X-linked branch was thoroughly characterized (self-kinship, unknown-sex→NA, twin correction) but
  the sparse X-linked branch (containing one of the two implicit-integer lint sites) had zero
  coverage. Added `test_that("kinship() with chrtype = 'x' gives identical results for sparse =
  TRUE and sparse = FALSE")` to `tests/testthat/test_kinship.R`, mirroring the file's existing
  twin-corrected sparse/dense-parity test. Confirmed GREEN against unmodified code (not a
  failing-first RED — this is a pure refactor task with no new behavior, so the safety-net test
  starts passing by design, a distinction surfaced and approved at the PRE-RED→RED gate).
- **Verification:** (1) new test file 34/34 assertions passing after the fix; (2)
  `lintr::lint_package()` (the literal `lint.yaml` CI mechanism, `LINTR_ERROR_ON_LINT=true`) — 0
  lints package-wide, down from 3; (3) full clean regression (`NOT_CRAN=true`) — 0 new
  failures/errors, the only failure is the pre-existing, already-documented
  `test_wordlist_coverage.R` WORDLIST gap (S573); (4) runtime-reachability check — grepped
  `R/mod*.R`/`appServer.R`/`appUI.R` for `chrtype`: zero matches, confirming the modified branch is
  script-callable only, not wired to any live Shiny path (all in-app `kinship()` calls use the
  default autosomal branch, untouched by this fix) — the basis for the Phase 3E runtime-smoke
  determination.
- **Process fix (found this session, close-out documentation):** `CLAUDE.md`'s "Clean regression
  read" formula was missing the `NOT_CRAN=true` prefix its neighboring "Fast single-file test"
  formula requires — run verbatim as documented, it silently skipped `test_wordlist_coverage.R`'s
  `skip_on_cran()` and reported a false `sum(failed): 0` where 1 was expected. Caught only because
  this session's own Phase 0 orientation had already established the WORDLIST gap as a known
  open failure. Fixed inline in `CLAUDE.md` (added the prefix); see `PROJECT_LEARNINGS.md` Learning
  594.

### 2026-08-15 · [BL-N] S586: claim (fix red lint.yaml CI)
- **Deliverable:** Session claimed. Picked from the Phase 0 priorities picker (1 of 4 options,
  first-listed per S585's own `next_steps` ordering). Phase 1B stub written to `SESSION_NOTES.md`;
  pending receipt opened in `HANDOFFS.md`. Commit `a8367a4f`.

### 2026-08-15 · [ad hoc] S585: reconcile HANDOFFS.md commit self-reference (`6a34c351`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> the three
  real shas (`6a34c351` close-out, `9ab5b507` fix + guard, `eace45d8` claim) -- unknowable until
  after those commits existed. Matches the established S562-S584 precedent.

### 2026-08-15 · [BL-N] S585: close out (pkgdown.yaml CI fix — articles: contents: gap)
- **Deliverable:** Fix the red `pkgdown.yaml` CI (`BACKLOG.md` Housekeeping, found S584 — and,
  discovered while removing the item, independently found a day earlier by S566, never
  cross-referenced by either session) — DONE. Added the missing `- articles/pedigree-diagram`
  line to `_pkgdown.yml`'s `articles:` → `contents:` list, plus a new regression-test guard (4th
  `test_that()` in `test_pkgdown_reference_config.R`) mirroring the file's existing
  `reference:`-coverage tests: compares `pkg$vignettes$name` (pkgdown's own ground-truth article
  list, partials auto-excluded) against the configured `articles: contents:` list via `setdiff()`.
  Strict-TDD: a pre-RED scope decision, PRE-RED→RED, RED→GREEN, and GREEN→REFACTOR (skipped,
  declared, not silently omitted) all fired as `AskUserQuestion` gates before their phase's first
  edit.
- **Verification (5 checks, all run this session):** (1) RED confirmed — the new test failed,
  naming `articles/pedigree-diagram` exactly, with the file's 3 pre-existing tests unaffected;
  (2) GREEN confirmed — same test file 5/5 passing; (3) full clean regression — 1 pre-existing
  unrelated failure (`test_wordlist_coverage.R`, the already-filed S573 WORDLIST gap), 0 errors;
  (4) `lintr::lint_package()` — 0 lints on the touched R file; (5) faithful check — directly
  invoked `pkgdown:::build_articles_index(pkg)`, the exact internal function CI's error names
  (`Error in build_articles_index(): ! In _pkgdown.yml, 1 vignette missing from index`), and
  confirmed it now succeeds. (A stray `pkgdown/favicon/` directory this direct call generated as a
  side effect was removed before commit — not part of the deliverable.)
- **Housekeeping:** removed 2 `BACKLOG.md` items for the identical gap — S584's (found via this
  session's own push finally letting CI run) and a previously-unfixed S566 entry (2026-08-14,
  filed a day earlier, never cross-referenced by S584). See `PROJECT_LEARNINGS.md` Learning 593
  for the generalizable "grep before filing" rule this collision motivates.
- **Not done, out of scope (user-directed via the pre-RED `AskUserQuestion`):** did not add an
  articles-index-coverage clause to `CLAUDE.md`'s existing `_pkgdown.yml` reference-coverage
  checklist — offered as a 3rd scope option, declined in favor of "fix + regression test guard"
  only.

### 2026-08-15 · [BL-N] S585: claim (fix red pkgdown.yaml CI)
- **Deliverable:** Session claimed. Picked from the Phase 0 priorities picker as the widest-
  blast-radius of the 3 CI reds S584 filed (the docs site was not deploying at all). Phase 1B stub
  written to `SESSION_NOTES.md`; pending receipt opened in `HANDOFFS.md`.

### 2026-08-15 · [ad hoc] S584: push documentation commits (`7436a7a9..07824e0a`)
- **Deliverable:** Non-commit action, recorded per failure mode #27. Owner-directed second push of
  this session's 2 remaining documentation-only commits (`9c817bcb`, `07824e0a` — `BACKLOG.md`,
  `CHANGELOG.md`, `HANDOFFS.md`; no source or test files). Clean fast-forward, no force. `master`
  and `origin/master` in sync.
- **Expected CI consequence, stated up front:** this re-triggers the 4 push-triggered workflows.
  `pkgdown`, `lint` and `R-CMD-check` are expected to fail again — the 3 pre-existing defects
  recorded in the entry below are untouched by a docs-only push, and were deliberately left unfixed
  as separate deliverables. `test-coverage` is expected to pass. No new information is anticipated
  from these runs; they are a side effect of the push, not a verification step.

### 2026-08-15 · [ad hoc] S584: CI outcome of the push — S584's fix CONFIRMED green; 3 pre-existing reds surfaced
- **`shinytest2` SUCCESS** (run `31868762486`) — **this session's fix confirmed in CI, not just
  locally.** The previously-failing group reports
  `^e2e-mate-pair-analysis-module: files=1 passed=8 failed=0 skipped=0 error=0` (was `error=1`),
  matching the local reproduction exactly; all 19 module groups pass. Independent bonus
  confirmation of Learning 592: `^e2e-twin-relations-: files=1 passed=3` now appears and runs,
  proving its absence from the old CI log was a stale-snapshot artifact, never a partition drift.
- **`test-coverage` SUCCESS.**
- **3 pre-existing failures surfaced, none caused by this session, each independently dated** — all
  invisible to CI until this push because it had been pinned to a 145-commit-stale `origin/master`:
  - **`pkgdown` FAILURE** (`31868761401`) — `articles/pedigree-diagram` missing from `_pkgdown.yml`;
    the article landed in `2b3e8ef6` (S560) without an index entry. Docs site does not deploy.
  - **`lint` FAILURE** (`31868761462`) — 3 lints in `R/kinship.R:127,131,133` from `7bbc6273`
    (S564); the job sets `LINTR_ERROR_ON_LINT: true`. A miss against `CLAUDE.md`'s own Lint
    close-out checklist, not a novel gap.
  - **`R-CMD-check` FAILURE** (`31868761411`) — all 5 platform jobs, `Status: 1 ERROR, 1 NOTE`, the
    `inst/WORDLIST` gap from `c9860f4b` (S573). **Answers this session's own open question:** CI is
    NOT masking it (`r-lib/actions` sets `NOT_CRAN`, so `skip_on_cran()` never fires), which also
    settles the S581 "0 errors" discrepancy — the failure is real and platform-independent.
- **All 3 filed as `BACKLOG.md` items, none fixed** — each is a separate deliverable under
  "1 and done" (`PROJECT_LEARNINGS.md` Learning 382's report-don't-fix precedent).

### 2026-08-15 · [BL-N] S584: push master to origin (148 commits) + dispatch shinytest2.yaml
- **Deliverable:** Non-commit action, recorded per failure mode #27. Owner directed "push" after
  this session's close-out surfaced the 145-commit divergence as a `BACKLOG.md` DECISION NEEDED
  item; the unpushed state was **not** deliberate. Pushed `7021c6f7..7436a7a9` (148 commits = the
  145 pre-existing + this session's 3), clean fast-forward, no force, `master -> master`, verified
  by `git push --dry-run` before executing. `master` and `origin/master` now in sync for the first
  time since S545 (2026-08-13).
- **CI consequence:** the 4 push-triggered workflows (`R-CMD-check`, `lint`, `pkgdown`,
  `test-coverage`) fired automatically against current `HEAD` -- their first run against any work
  since S545. `shinytest2.yaml` has no push trigger (`schedule`/`workflow_dispatch` only), so it was
  dispatched by hand: `gh workflow run shinytest2.yaml --ref master`, run `31868762486`. This is the
  run that actually observes S584's own fix in CI rather than locally.
- **`BACKLOG.md` item closed** in the same commit (the "local master is 145 commits ahead" item
  filed earlier this session).

### 2026-08-15 · [ad hoc] S584: reconcile HANDOFFS.md commit self-reference (`f36146ea`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> the three
  real shas (`f36146ea` close-out, `66593c61` fix + guard, `9b23075e` claim) -- unknowable until
  after those commits existed. Matches the established S562-S583 precedent.

### 2026-08-15 · [ad hoc] S584: close out (shinytest2.yaml CI red diagnosed AND fixed, + regression guard)
- **Deliverable:** Root-caused the scheduled `shinytest2.yaml` failure (red 3 consecutive nights,
  2026-08-12/13/14): `.github/workflows/shinytest2.yaml:161-183` runs the E2E tier by spawning one
  `Rscript -e 'testthat::test_dir(...)'` per module group, which bypasses `tests/testthat.R` -- the
  only file in the repo calling `library(nprcgenekeepr)`. `test_dir()` does not attach the package
  under test and no `helper-*.R`/`setup.R` does either, so package exports are absent in that
  process (`exists("makeExamplePedigreeFile")` -> `FALSE`).
  `tests/testthat/test-e2e-mate-pair-analysis-module.R:58` called `makeExamplePedigreeFile()` bare
  (correctly exported at `NAMESPACE:136`; a pure lookup failure) and had never once passed in CI --
  it shipped in `8781709d` (S513, issue #151 Slice 2) and the nightly went red the night it landed.
  Every local verification path `CLAUDE.md` documents begins with `pkgload::load_all()`, which DOES
  attach the package, so no local run could have reproduced it.
- **Scope, measured not assumed:** a call-graph sweep of all 30 `test-{e2e,app}-*.R` files
  (bare called names intersected with `getNamespaceExports()`, minus helper- and self-defined
  names) found **exactly one** offending call site.
- **Fix (Strict TDD, all 3 gates fired as `AskUserQuestion` calls before their phase's first edit):**
  RED -- new `tests/testthat/test_e2e_package_qualification.R`, a static guard that fails if any
  E2E-tier file calls a package export bare, confirmed failing and naming the offender. GREEN --
  one-line qualification to `nprcgenekeepr::makeExamplePedigreeFile(` plus a comment recording why
  it must stay qualified. REFACTOR not entered (nothing to restructure; stated, not skipped).
- **Verification:** guard GREEN; the previously-failing group rerun with the EXACT CI command in the
  un-attached environment now `files=1 passed=8 failed=0 skipped=0 error=0` (also clearing the
  workflow's own `p == 0` silent-skip guard); full clean regression 5,958 passed / 1 pre-existing
  unrelated failure (`test_wordlist_coverage.R`) / 0 errors; `lintr::lint_package()` 0 lints on
  touched files; `devtools::check()` **1 error / 0 warnings / 1 note — both pre-existing, neither
  caused by this session** (the error is the same `test_wordlist_coverage.R` failure, flagging
  `matings` and `visNetwork's` from `NEWS.md:232`/`NEWS.md:208`; the note is the known
  `vignettes/figure/` knitr leftover). Provenance verified rather than assumed: both words entered
  `NEWS.md` in `c9860f4b` (S573, 2026-08-14 14:34), and this session modified neither `NEWS.md` nor
  `inst/WORDLIST`. Filed as its own `BACKLOG.md` item — the project's documented build equivalent
  has been red since S573 with no session reporting it.
- **Cleared, not assumed:** the commit titled "corrected .Rbuildignore" (`79f37e18`) sits in the
  regression window but its diff touches nothing under `R/`; and the CI log's missing
  `^e2e-twin-relations-` module group is a stale-snapshot artifact, not a Learning-312 partition
  drift -- both that test file and its group regex were added together in the unpushed `c91f7c49`.
- **Filed:** new `BACKLOG.md` Housekeeping item (DECISION NEEDED) -- local `master` is 145 commits
  ahead of `origin/master`, so all CI is testing S545-era code and this fix cannot be observed green
  until a push (and `shinytest2.yaml`, having no push trigger, then needs a manual
  `workflow_dispatch`). See `PROJECT_LEARNINGS.md` Learnings 591 and 592.

### 2026-08-15 · [ad hoc] S584: claim (diagnose the red scheduled shinytest2.yaml CI run)
- **Deliverable:** Session claimed. Phase 0's unconditional `gh run list --branch master` check
  (the `CLAUDE.md` convention ratified S545) found the scheduled `shinytest2.yaml` workflow
  `completed failure` on both 2026-08-13 and 2026-08-14 -- first flagged by S581's own Phase 0,
  carried forward unchanged through S582/S583's handoffs, never diagnosed. Owner picked this as
  this session's deliverable from the Phase 0 priorities picker. Scoped as diagnosis (root cause
  with evidence from the actual failing run); any fix goes through a phase gate first. Phase 1B
  stub written to `SESSION_NOTES.md`; pending receipt opened in `HANDOFFS.md`.

### 2026-08-15 · [ad hoc] S583: reconcile HANDOFFS.md commit self-reference (`ce830dbe`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> `ce830dbe`
  (the close-out commit's own sha, unknowable until after that commit was made) -- matching the
  established S562-S582 precedent.

### 2026-08-15 · [BL-N] S583: close out (union-outside-parents-span finding filed)
- **Deliverable:** New `BACKLOG.md` item filed (found S583) -- a mating union with a single child
  (or whose children's own midpoint falls outside the parents' span) can be positioned entirely
  outside its own two parents' x-range, diverging from kinship2's own always-centered-between-
  spouses convention. Distinct from the S576 sibling subtree-width item (that one measures
  distance from a union to its CHILDREN; this one measures distance from a union to its PARENTS --
  an axis Track 6's own verification never checked). Reproduced live via
  `makePedigreeMatingLayout()` on the real `obfuscated_rhesus_mhc_ped.csv` fixture, the same
  6-animal subgraph `pb_diagram_legend.png` depicts: `5A6DFT` x=-60, `8DKELJ` x=60, their union
  x=120 (outside the parent span). Confirmed via a direct `kinship2::pedigree()`/`plot.pedigree()`
  comparison of the identical pedigree -- kinship2 centers the descent line between the two
  parents unconditionally. No code changed; investigation and filing only, per the user's own
  choice among 3 offered next steps. See `PROJECT_LEARNINGS.md` Learning 590.

### 2026-08-15 · [BL-N] S583: claim (file union-outside-parents-span finding)
- **Deliverable:** Session claimed. Investigating a user question about `pb_diagram_legend.png`
  surfaced that a mating union's x can land entirely outside its own two parents' x-span (not just
  off-center among children) -- filing this as a new `BACKLOG.md` finding, distinct from the
  already-tracked S576 sibling subtree-width item. Phase 1B stub written to `SESSION_NOTES.md`;
  pending receipt opened in `HANDOFFS.md`.

### 2026-08-15 · [ad hoc] S582: reconcile HANDOFFS.md commit self-reference (`3e8870d2`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> `3e8870d2`
  (the close-out commit's own sha, unknowable until after that commit was made) -- matching the
  established S562-S581 precedent.

### 2026-08-15 · [BL-N] S582: close out (pb_diagram_legend.png reshoot DONE)
- **Deliverable:** `BACKLOG.md` item (found S574) -- **DONE**. Recaptured
  `vignettes/articles/shiny_app_use/pb_diagram_legend.png` via a standalone `shinytest2`/chromote
  script reproducing the canonical `pedigree-diagram-screenshots.R`'s "Base fixture" step
  (`obfuscated_rhesus_mhc_ped.csv`, focal ids `8LKBV9`/`FJIB3R`/`GA204Z`, selector
  `#pedigree-moduleContainer`), deliberately not setting `pedigreeEdgeStyle` so the capture
  inherits the app's own current zero-interaction default (`"rectilinear"`, confirmed live via
  `R/modPedigree.R`'s `.currentEdgeStyle()`). New image confirmed showing "Rectilinear
  (kinship2-style)" pre-selected with right-angle edge routing, diffed visually against the prior
  committed image. Build-equivalent: `pkgdown::build_article()` for both `articles/pedigree-diagram`
  and `articles/colony-manager-guide` rendered clean (`quarto render`); built HTML's embedded image
  MD5-confirmed identical to the new source PNG. Render litter removed before commit. Neither
  article's prose needed a change (already said "Rectilinear" is the default, from Track 2's own
  S574 pass). Incidental finding filed as its own `BACKLOG.md` item, not fixed: the same script's
  other 3 non-base-fixture screenshots share the identical never-sets-`pedigreeEdgeStyle` omission
  and may be stale by the same mechanism, unverified. See `PROJECT_LEARNINGS.md` Learning 589.

### 2026-08-14 · [BL-N] S582: claim (reshoot pb_diagram_legend.png)
- **Deliverable:** Session claimed. `BACKLOG.md` item (found S574) -- reshoot
  `shiny_app_use/pb_diagram_legend.png`, stale since Track 2 (S574) flipped the Diagram tab's
  zero-interaction default to Rectilinear. Phase 1B stub written to `SESSION_NOTES.md`; pending
  receipt opened in `HANDOFFS.md`.

### 2026-08-14 · [ad hoc] S581: reconcile HANDOFFS.md commit self-reference (`6dd26870`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> `6dd26870`
  (the close-out commit's own sha, unknowable until after that commit was made) -- matching the
  established S562-S580 precedent.

### 2026-08-14 · [BL-N] S581: close out (locale-dependent order() tie-break sweep DONE)
- **Deliverable:** `BACKLOG.md` order()-sweep item (found S578) -- **DONE**. Fresh
  `grep -n "order(" R/*.R` (26 sites) classified all; 4 real hits fixed (`method = "radix"`
  added, RED->GREEN->REFACTOR): `orderReport.R:81,93`, `qcStudbook.R:323`,
  `modBreedingGroups.R:690` `bgGroupView`. 2 initially-flagged hits corrected to false positives
  via empirical verification: `kinshipMatrixToKValues.R:107` (data.table's own `forder()`
  auto-substitution), `computeGenomicROH.R:112` (returned value provably locale-invariant despite
  the intermediate sort being locale-sensitive) -- explanatory comments added, no behavior change.
  See `PROJECT_LEARNINGS.md` Learning 588 for the full classification methodology.

### 2026-08-14 · [BL-N] S581: verification (full clean regression + live E2E)
- **Deliverable:** 4 targeted RED tests confirmed GREEN post-fix; full clean regression 5,955
  passed / 1 pre-existing failure unrelated (`test_wordlist_coverage.R`) / 0 errors / 33
  pre-existing warnings (both match the established baseline); 0 lints on all 5 touched R files
  (`lintr::lint_package()`, project's own `.lintr` config); `devtools::check()` 0 errors/0
  warnings/1 pre-existing NOTE (`vignettes/figure/` knitr leftover). Live E2E
  (`NPRC_RUN_E2E=true`, real `shinytest2`/`chromote` browser) confirmed all 3 affected runtime
  paths: `test-e2e-mate-pair-analysis-module.R` (qcStudbook), `test-e2e-genetic-value-tutorial.R`
  (orderReport/reportGV), `test-e2e-breeding-groups-module.R` (bgGroupView) -- all pass.

### 2026-08-14 · [BL-N] S581: REFACTOR (explanatory comments, no behavior change)
- **Deliverable:** Added comments to `R/kinshipMatrixToKValues.R:107` and
  `R/computeGenomicROH.R:112` documenting why each is NOT the Learning 585 defect class despite
  superficially matching the character-column-sort pattern. Verified no behavior change (both
  files' own test suites pass unchanged); 0 lints.

### 2026-08-14 · [BL-N] S581: GREEN (method="radix" for 4 confirmed hits)
- **Deliverable:** `R/orderReport.R:81,93`, `R/qcStudbook.R:323`, `R/modBreedingGroups.R:690` --
  `method = "radix"` added to each locale-dependent `order()` call. 4 targeted RED tests now
  GREEN; full clean regression 1 pre-existing failure unrelated, 0 errors; 0 lints on touched
  files; `devtools::check()` 0 errors/0 warnings/1 pre-existing NOTE.

### 2026-08-14 · [BL-N] S581: RED (4 confirmed locale-dependent order() hits)
- **Deliverable:** Fresh `grep -n "order(" R/*.R` classification (26 sites). 4 real hits
  confirmed via empirical divergence testing and RED tests added: `test_orderReport.R` (2 new
  blocks), `test_qcStudbook.R` (1 new block), `test_modBreedingGroups.R` (1 new block,
  `shiny::testServer()` -- no prior coverage of `bgGroupView` existed). All 4 confirmed failing
  for the right reason against unmodified source; 0 regressions in the 3 touched test files. 2
  initially-flagged hits (`kinshipMatrixToKValues.R:107`, `computeGenomicROH.R:112`) corrected to
  false positives during this same investigation -- no test written for either (nothing to prove).

### 2026-08-14 · [BL-N] S581: claim session (locale-dependent order() tie-break sweep)
- **Deliverable:** Phase 1B claim. Picked via Phase 0 `AskUserQuestion` from `BACKLOG.md`'s
  order()-sweep item (found S578). Wrote `SESSION_NOTES.md` claim stub and `HANDOFFS.md`
  `status: pending` receipt. PRE-RED investigation (fresh grep + classification) up next.

### 2026-08-14 · [ad hoc] S580: reconcile HANDOFFS.md commit self-reference (`75c23fe5`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> `75c23fe5`
  (the close-out commit's own sha, unknowable until after that commit was made) -- matching the
  established S562-S579 precedent.

### 2026-08-14 · [BL-N] S580: close out (HANDOFFS.md byte-budget/line-headroom archive trim DONE)
- **Deliverable:** Session S580's own close-out. Evaluated S579's `HANDOFFS.md` receipt (9/10 --
  the `gotchas` field's `SRF_RED` non-durability warning primed this session for the identical
  divergence on `HANDOFFS.md`, saving a full re-diagnosis). Self-assessed 9/10 (proactively added
  the claim commit's own ledger entry instead of waiting for `P1_UNDOCUMENTED` to catch it; pulled
  absolute byte deltas before the `SRF_RED` decision; caught and fixed a stranded front-matter
  sentence the tool's own edit left behind; weakness: still no independent adversarial-verification
  pass, and skipped a second scope-confirmation `AskUserQuestion` after the picker). Wrote handoff
  notes to `SESSION_NOTES.md`; completed the `HANDOFFS.md` receipt (`status: complete`).

### 2026-08-14 · [BL-N] S580: downstream updates (BACKLOG item resolved, PROJECT_LEARNINGS 587)
- **Deliverable:** Removed the resolved `BACKLOG.md` Housekeeping item (`HANDOFFS.md`'s archive
  trigger, found S579), replaced with a short resolution pointer. Added `PROJECT_LEARNINGS.md`
  Learning 587: confirms the Learning 586 `SRF_RED` recurrence pattern is not `CHANGELOG.md`-
  specific -- the very next session hit it on `HANDOFFS.md` too, a file Learning 549 had cited as
  having "proceeded cleanly" the one time it was checked. Also repositioned `HANDOFFS.md`'s own
  "This file currently holds N receipt(s)" sentence back to immediately after the newest archive
  pointer (the tool's in-place regex edit left it stranded between the 3rd and 4th pointer blocks
  after this session's new pointer was inserted), matching the established S508/S561 convention.

### 2026-08-14 · [ad hoc] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-08-14.md` (21 record(s), 125,404 B → 9,682 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **21** record(s) (2026-08-13 → 2026-08-14) out of [`HANDOFFS.md`](HANDOFFS.md) into
[`docs/archive/HANDOFFS-through-2026-08-14.md`](docs/archive/HANDOFFS-through-2026-08-14.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh)
rather than trusting a digest printed here. Live file 125,404 B → 9,682 B (−92.3%).

### 2026-08-14 · [BL-N] S580: claim session (HANDOFFS.md byte-budget/line-headroom archive trim)
- **Deliverable:** Phase 1B claim stub written to `SESSION_NOTES.md`/`HANDOFFS.md` (`status:
  pending`) for this session's deliverable: archive `HANDOFFS.md`'s tagged-receipt portion into a
  new dated shard (`BACKLOG.md` Housekeeping, found S579) -- both the line-headroom (4 records
  against the 15-record threshold) and byte-budget (125,043 B against 65,536 B) triggers fire.
  Owner-picked via `AskUserQuestion` over 3 other READY items (locale-dependent `order()` sweep,
  sibling subtree-width asymmetry, stale `pb_diagram_legend.png` screenshot).

### 2026-08-14 · [BL-N] S579: post-close-out finding: HANDOFFS.md's own archive trigger fires
- **Deliverable:** A post-close-out `--check` sweep of both ledgers (prompted by this session's
  own `CHANGELOG.md` trim) found `HANDOFFS.md`'s line-headroom trigger now fires (4 records
  against the 15-record threshold) -- not fixed this session (out of scope), filed as a new
  `BACKLOG.md` Housekeeping item with the SRF boundary numbers already pulled for whoever picks
  it up next.

### 2026-08-14 · [ad hoc] S579: reconcile HANDOFFS.md commit self-reference (`c35b1983`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> `c35b1983`
  (the close-out commit's own sha, unknowable until after that commit was made).

### 2026-08-14 · [BL-N] S579: close out (CHANGELOG.md byte-budget archive trim DONE)
- **Deliverable:** Session S579's own close-out. Evaluated S578's `HANDOFFS.md` receipt (7/10 --
  the `next_steps` pointer to this exact item was accurate and immediately actionable, but no
  `gotchas` entry warned that `CHANGELOG.md` archiving carries a real, previously-documented risk
  of `SRF_RED` refusal). Self-assessed 8/10 (self-caught a Learning-553-shaped picker-before-prose
  mistake within the same turn; surfaced the `SRF_RED` refusal's two boundary readings plus
  absolute byte deltas to the user rather than force-passing or silently blocking; weakness: the
  risk wasn't checked during Phase 0, only after committing to the task). Wrote handoff notes to
  `SESSION_NOTES.md`; completed the `HANDOFFS.md` receipt (`status: complete`).

**Archived 62 record(s), 2026-08-13 → 2026-08-14** into [`docs/archive/CHANGELOG-through-2026-08-14.md`](docs/archive/CHANGELOG-through-2026-08-14.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-08-14.md.verify.sh`](docs/archive/CHANGELOG-through-2026-08-14.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

### 2026-08-14 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-08-14.md` (62 record(s), 101,210 B → 32,753 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **62** record(s) (2026-08-13 → 2026-08-14) out of [`CHANGELOG.md`](CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-08-14.md`](docs/archive/CHANGELOG-through-2026-08-14.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-08-14.md.verify.sh`](docs/archive/CHANGELOG-through-2026-08-14.md.verify.sh)
rather than trusting a digest printed here. Live file 101,210 B → 32,753 B (−67.6%).

### 2026-08-14 · [ad hoc] S579: claim session (CHANGELOG.md byte-budget archive trim) (`f18431b0`)
- **Deliverable:** Phase 1B claim stub (`SESSION_NOTES.md`) and `HANDOFFS.md` `status: pending`
  receipt for this session's deliverable: archive `CHANGELOG.md`'s tagged-record portion into a
  new dated shard (`BACKLOG.md` Housekeeping, found S573) — the byte trigger fires again
  (100,783 B against the 65,536 B budget).

### 2026-08-14 · [ad hoc] S578: reconcile HANDOFFS.md commit self-reference (`b321df39`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> `b321df39`
  (the close-out commit whose sha the receipt itself couldn't name until after it was made) --
  matching the established S562-S577 precedent.

### 2026-08-14 · [BL-N] S578: close out (Track 6 child-centered union-position implementation DONE) (`b321df39`)
- **Deliverable:** Full session record written (`SESSION_NOTES.md`, `HANDOFFS.md` receipt). See
  the receipt for the complete self-assessment (9/10) and predecessor evaluation (8/10).

### 2026-08-14 · [BL-N] S578: Track 6 downstream updates for locale-independence fix (BACKLOG, plan doc section 10) (`26f7d909`)
- **Deliverable:** Documents the `devtools::check()`-found, `LC_ALL=C`-reproduced locale-dependent
  tie-break defect and its `method = "radix"` fix in the `BACKLOG.md` DONE item and the plan
  doc's section 10 Implementation Record. Also files a new `BACKLOG.md` Housekeeping item for the
  same defect class found more broadly across the package (`qcStudbook()`, `orderReport()`), not
  fixed this session.

### 2026-08-14 · [BL-N] S578: locale-independent tie-break in de-collision pass (`b0467657`)
- **Deliverable:** `devtools::check()` (run as its own separate build-equivalent step, not
  skipped as redundant with the already-green `pkgload::load_all()` + `test_dir()` regression
  read) surfaced 5 test failures, not the 1 known pre-existing `test_wordlist_coverage.R`
  failure. Root-caused via `LC_ALL=C` reproduction (no code change): `order()` on a character
  node-id vector is `LC_COLLATE`-locale-dependent, so which of 2 exactly-tied same-gen nodes
  absorbs the de-collision pass's 1e-3 epsilon nudge can differ between locales -- a genuinely
  pre-existing latent defect (the original pre-Track-6 pass used the same non-radix `order()`)
  that this session's own widened node-category coverage first exposed as an observable,
  hardcoded-test-breaking symptom. Fixed by adding `method = "radix"` (R's only
  locale-independent character-vector ordering) to both affected `order()` calls in
  `.positionMatingUnitForest()`; updated 4 `expectPos()` values in
  `test_positionMatingUnitForest.R` to match the new locale-stable output. Verified: targeted
  file green under both `en_US.UTF-8` and `LC_ALL=C`; full clean regression under `LC_ALL=C` 1
  pre-existing unrelated failure, 0 new; `lintr::lint_package()` 0 lints; `devtools::check()`
  re-run clean against the established baseline only. `PROJECT_LEARNINGS.md` Learning 585 records
  the finding.

### 2026-08-14 · [BL-N] S578: Track 6 downstream updates (BACKLOG, plan doc section 10) (`228b5071`)
- **Deliverable:** Marked the `BACKLOG.md` Housekeeping item DONE (implemented S578). Added
  section 10 (Implementation Record) to
  `docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md` documenting the
  2 Pre-RED corrections, re-measured headline figures, and verification evidence.

### 2026-08-14 · [BL-N] S578: GREEN, Track 6 child-centered mating-unit position (`f65ecbea`)
- **Deliverable:** Implements `docs/planning/pedigree-diagram-track6-child-centered-union-
  position-plan.md` §2 (Extended Candidate A, design ratified S576) in
  `.positionMatingUnitForest()` (`R/makePedigreeDiagramData.R`): a mating unit's `finalUnitX` is
  now the midpoint of its own children's final x (was its 2 parents' midpoint); a duplicate
  node's `dupX` is now derived from the new `finalUnitX`; the final de-collision pass is
  broadened to cover every node (real, duplicate, union). Pre-RED empirical validation found the
  `orderBySex` block must move earlier in the function (finalUnitX/dupX computed after it, not
  at §2.1's literally-described pre-orderBySex location) for the §2.4 invariant to hold. Also
  fixed 2 pre-existing tests whose assertions directly encoded the old parent-midpoint behavior.
  Verified: all 30 tests in `test_positionMatingUnitForest.R` pass; full clean regression 1
  pre-existing unrelated failure, 0 new; `lintr::lint_package()` 0 lints; real-fixture
  re-measurement matches the ratified figures (100/251→9/251 violating edges, 61.94/120.12→
  48.00/48.00 duplicate-to-union distance, 0 exact coincidences); live `visNetwork`/`chromote`
  render (both `edgeStyle` values, small + full real fixture) 0 console errors, visually
  confirms unions now sit close to their own children.

### 2026-08-14 · [BL-N] S578: RED, Track 6 child-centered union-position invariant (`0780cdfd`)
- **Deliverable:** Added 2 new tests to `test_positionMatingUnitForest.R` (the §2.4 invariant on
  the small GA204Z/8LKBV9 fixture + the real 375-individual fixture; a duplicate-vs-any-node
  exact-coincidence test) and updated the existing "issue #143 fix" exact-value test (8 of 13
  `expectPos()` calls, re-derived live via a from-scratch reimplementation of Extended
  Candidate A run against unmodified `.buildMatingUnitForest()` output). Confirmed RED: the 3
  touched tests fail against unmodified source (8/27, 225/241, 1/1 expectations), including a
  genuine pre-existing duplicate/union coincidence unrelated to this decision; all 25 other
  tests in the file pass unchanged.

### 2026-08-14 · [ad hoc] S578: claim session (Track 6 child-centered union-position implementation) (`ca921a92`)
- **Deliverable:** Phase 1B claim stub written to `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-14 · [ad hoc] S577: reconcile HANDOFFS.md commit self-reference (`3a1a8de4`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> `3a1a8de4`
  (the close-out commit whose sha the receipt itself couldn't name until after it was made) --
  matching the established S562-S576 precedent. Bundled into the SAME commit as this entry (unlike
  S576's own instance of this same action, which this session's Phase 0 found had no matching
  `CHANGELOG.md` entry at all and had to backfill) -- applying this session's own Phase 0 finding
  immediately rather than repeating the gap.

### 2026-08-14 · [BL-N] S577: close out (duplicate-connector arc curve-direction fix DONE)
- **Deliverable:** GREEN implementation ratified via both TDD phase gates (`AskUserQuestion`
  PRE-RED->RED and RED->GREEN, both approved as written; GREEN->REFACTOR offered and explicitly
  skipped). `R/makePedigreeDiagramData.R`'s `dupEdges` construction now x-orders `from`/`to`
  instead of always `from=dupId`, matching kinship2's own `arcconnect()` convention (always sorts
  its pair by x before drawing). Verified: targeted tests 188/188, full clean regression
  4854/4854 (0 error), 0 lint on the touched file, real 375-individual fixture re-measurement
  52/52 same-row connectors now correct (was 19/52), live `visNetwork`/`chromote` render visually
  confirms the convex bow. Self-score 9/10; S576 handoff evaluation 9/10. See `HANDOFFS.md` S577
  receipt for the full record.

### 2026-08-14 · [BL-N] S577: downstream updates (BACKLOG item removed, plan doc section 7a) (`ee22559c`)
- **Deliverable:** Removed the resolved `BACKLOG.md` Housekeeping item. Updated
  `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md` section 7a with the root
  cause and fix summary.

### 2026-08-14 · [BL-N] S577: GREEN, x-order duplicate-connector from/to (`a01c176c`)
- **Deliverable:** `R/makePedigreeDiagramData.R` `dupEdges` construction (~line 1342): order
  `from`/`to` by ascending x (using the already-computed `nodes$x`) instead of the fixed
  `from=dupId, to=realId`, `smooth.type="curvedCW"`/`smooth.roundness=0.2` unchanged. Fixes the
  duplicate-individual dashed connector's bow direction to match kinship2's own convention
  regardless of which occurrence sits left/right. Verified self-contained: `dupEdges$color`/`width`
  are unconditionally NA regardless of `from`/`to`, and no downstream
  `.addRectilinearWaypoints()` D1/D2 logic keys off a duplicate-connector row's `from`/`to`.

### 2026-08-14 · [BL-N] S577: RED, duplicate-connector arc x-ordering (`0d013838`)
- **Deliverable:** Added 2 new tests to `tests/testthat/test_makePedigreeMatingLayout.R` (a
  deterministic `loopPed`-fixture case + the real 375-individual bundled fixture) asserting every
  dashed duplicate-connector edge has `from.x <= to.x`. Updated 3 existing tests whose filters
  assumed `from` is always the duplicate id, relaxed to `{from,to}` set membership. Confirmed RED:
  184 pass / 4 fail against the pre-fix implementation.

### 2026-08-14 · [ad hoc] S577: claim session (duplicate-individual arc curve-direction fix) (`a04090ec`)
- **Deliverable:** Phase 1B claim stub written to `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-14 · [ad hoc] S576: reconcile HANDOFFS.md commit self-reference (`ce8c50a1`) (Backfilled reconcile-on-read, Session 577)
- **Deliverable:** Fixed S576's own `HANDOFFS.md` receipt `commit: pending` -> `7b04a911` (the
  close-out commit whose sha the receipt itself couldn't name until after it was made) -- matching
  the established S562-S575 precedent. Backfilled at Session 577 Phase 0 reconcile: the commit
  itself (`ce8c50a1`, made at S576 close-out) landed with no corresponding `CHANGELOG.md` entry,
  found via the `CHANGELOG.md` frontier (`7b04a911`) trailing `HEAD` by one commit while
  `HANDOFFS.md`'s own frontier had no gap.

### 2026-08-14 · [BL-N] S576: close out (Track 6 design ratified)
- **Deliverable:** Design document ratified via `AskUserQuestion` ("proceed as written").
  `docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md` DONE. Updated
  `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md` (new §4 Track 6 entry, §7b
  pointer), `BACKLOG.md` (originating item annotated DESIGN RATIFIED S576; new item filed for the
  residual sibling-subtree-width-asymmetry finding), `PROJECT_LEARNINGS.md` (Learning 582).
  Self-score 8/10; S575 handoff evaluation 8/10. See `HANDOFFS.md` S576 receipt for the full record.

### 2026-08-14 · [BL-N] S576: Track 6 design -- child-centered mating-unit position
- **Deliverable:** Design document for the pedigree-diagram parent-child positioning offset
  (`BACKLOG.md` Housekeeping, found S575). Decided "Extended Candidate A": recompute a mating
  unit's final x from its own children's final x-span instead of its 2 parents; recompute the
  duplicate (non-anchor-parent) node's x from the new union x; broaden the existing de-collision
  pass to cover duplicates (closes a regression the union-only fix alone would introduce, measured
  this session). Validated on the real 375-individual bundled fixture: violating child-edges
  100/251 -> 9/251 (91% reduction), worst-case offset 10,687 -> 4,121 scaled units (61% reduction),
  duplicate-to-union distance mean 62/max 120 -> constant 48. 9 residual edges (3.6%) traced to a
  distinct, out-of-scope phenomenon (sibling subtree-width asymmetry), filed as its own new
  `BACKLOG.md` item. Implementation is a separate future session.

### 2026-08-14 · [ad hoc] S576: claim session (parent-child positioning offset design) (`43dac0f7`)
- **Deliverable:** Phase 1B claim stub written to `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-14 · [ad hoc] S575: post-close-out correction (2 real findings owner caught in the published artifact)
- **Deliverable:** Owner review of the published comparison artifact identified 2 real issues
  neither Track 5 nor any prior Claim (1-4c) checked: (1) the duplicate-connector dashed arc bows
  concave, opposite kinship2's own convex `arcconnect()` convention; (2) children are frequently
  rendered far from their own parent union -- 100/251 (40%) real-fixture child-edge groups exceed a
  200-unit horizontal offset, 73/251 (29%) exceed 500, max 10,687, root-caused to
  `R/makePedigreeDiagramData.R:924`'s parent-midpoint union-x computation being decoupled from
  child position, compounded by Track 3's per-row `sweepMinSep()`. Corrected the published artifact
  in place (same URL), the remediation plan (`docs/planning/pedigree-diagram-kinship2-fidelity-
  remediation-plan.md` new §7), this session's own `SESSION_NOTES.md`/`HANDOFFS.md` records
  (self-score revised 9 -> 6), and `PROJECT_LEARNINGS.md` (new Learning 581, plus repositioned
  Learning 580 which had been inserted out of order). Filed 2 new `BACKLOG.md` Housekeeping items
  for future dedicated sessions -- neither fixed this session.

### 2026-08-14 · [ad hoc] S575: reconcile HANDOFFS.md commit self-reference (`bb0c9bb2`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `bb0c9bb2` (the close-out commit whose sha the receipt itself couldn't name until after it was
  made) -- matching the established S562-S574 precedent.

### 2026-08-14 · [ad hoc] S575: close out (Track 5 re-measurement DONE, no gap found)
- **Deliverable:** Evaluated S574's handoff (9/10), self-assessed (9/10), documented
  `PROJECT_LEARNINGS.md` Learning 580 (live/offline cross-validation + structural-proof pattern for
  coverage questions), wrote the full `HANDOFFS.md` receipt.

### 2026-08-14 · [ad hoc] S575: Track 5 re-measurement (no rectilinear routing gap found) (`3c3412af`)
- **Deliverable:** `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md` §Track 5
  -- re-measured, after Tracks 3-4 landed, how much diagonal-edge residue remains in
  `edgeStyle = "rectilinear"` mode. Cross-validated 3 ways: offline `makePedigreeMatingLayout()` on
  the real 375-individual fixture (0 non-dashed diagonal edges vs. 237 in `direct` mode);
  structural proof from `.addRectilinearWaypoints()`'s D1/D2 loops (coverage guaranteed by
  construction, any pedigree); live `shinytest2`/`chromote` query of the rendered `visNetwork`
  widget matching the offline figures exactly. All 5 tracks of the remediation plan are now
  resolved -- no `.addRectilinearWaypoints()` change was warranted. Mid-session: published a
  direct-vs-rectilinear comparison Artifact at owner request.

### 2026-08-14 · [ad hoc] S575: claim session (Track 5 re-measurement) (`68432947`)
- **Deliverable:** Phase 1B claim stub written to `SESSION_NOTES.md`/`HANDOFFS.md`.

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

