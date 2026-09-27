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

handoffs-format: 2 — keep this marker, and bring it across with this section; `bin/status` reads it.

This file gains a receipt every session and nothing removes one, so it grows without bound. The
protocol never asks a session to read it whole: Phase 0 reconciles it against `git log` and checks
the newest receipt, and a session reads that receipt at the top — past the harness's default-read
refusal, with an offset and a limit. Archive it when the trimmer's trigger fires. The tool states the
trigger, and this file names no size of its own.

**Run this rather than estimating it:**

```sh
python3 methodology_trim.py --file HANDOFFS.md --check
```

`--check` evaluates the trigger and never writes. `--write` performs the trim, refuses unless it
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
  $(git ls-files 'docs/archive/HANDOFFS-*.md')` — or it silently counts a shrunken
  population. Enumerate the shards with `git ls-files`, never as a bare glob: zsh aborts a
  command whose glob matches nothing, so before the first split the bare form counts nothing
  at all — the same reason the ledger's audit is written that way.

The reasoning this file shares with `CHANGELOG.md` — how a ledger is read, why the tool is the only
statement of its trigger, and what a split must conserve — is in the *Reading and archiving*
subsection of [§The Action Ledger](docs/methodology/FRAMEWORK_APPARATUS.md#the-action-ledger).
That subsection makes archiving optional for `CHANGELOG.md`; this file keeps its own rule, above —
archive it when the trimmer's trigger fires. Everything needed to *act* is here.

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

**Archived 21 record(s), 2026-08-13 → 2026-08-14** into [`docs/archive/HANDOFFS-through-2026-08-14.md`](docs/archive/HANDOFFS-through-2026-08-14.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

This file currently holds **2** receipt(s). Computed by `methodology_trim.py` on every
`--check`/`--write` run, never hand-maintained.

**Archived 116 record(s), 2026-08-14 → 2026-09-17** into [`docs/archive/HANDOFFS-through-2026-09-17.md`](docs/archive/HANDOFFS-through-2026-09-17.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 13 record(s), 2026-09-17 → 2026-09-18** into [`docs/archive/HANDOFFS-through-2026-09-18.md`](docs/archive/HANDOFFS-through-2026-09-18.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 11 record(s), 2026-09-18 → 2026-09-19** into [`docs/archive/HANDOFFS-through-2026-09-19.md`](docs/archive/HANDOFFS-through-2026-09-19.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-19.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-19.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 9 record(s), 2026-09-19 → 2026-09-19** into [`docs/archive/HANDOFFS-through-2026-09-19-2.md`](docs/archive/HANDOFFS-through-2026-09-19-2.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-19-2.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-19-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 31 record(s), 2026-09-19 → 2026-09-21** into [`docs/archive/HANDOFFS-through-2026-09-21.md`](docs/archive/HANDOFFS-through-2026-09-21.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-21.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-21.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 7 record(s), 2026-09-22 → 2026-09-23** into [`docs/archive/HANDOFFS-through-2026-09-23.md`](docs/archive/HANDOFFS-through-2026-09-23.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-23.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-23.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 11 record(s), 2026-09-23 → 2026-09-24** into [`docs/archive/HANDOFFS-through-2026-09-24.md`](docs/archive/HANDOFFS-through-2026-09-24.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-24.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-24.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 4 record(s), 2026-09-24 → 2026-09-26** into [`docs/archive/HANDOFFS-through-2026-09-26.md`](docs/archive/HANDOFFS-through-2026-09-26.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-26.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-26.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 3 record(s), 2026-09-26 → 2026-09-26** into [`docs/archive/HANDOFFS-through-2026-09-26-2.md`](docs/archive/HANDOFFS-through-2026-09-26-2.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-26-2.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-26-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 4 record(s), 2026-09-26 → 2026-09-26** into [`docs/archive/HANDOFFS-through-2026-09-26-3.md`](docs/archive/HANDOFFS-through-2026-09-26-3.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-26-3.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-26-3.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

```handoff
session: S791
date: 2026-09-27
status: pending
self_score: pending
predecessor_score: pending
active_task: IN PROGRESS -- NEWS.Rmd release-state sweep, stage 2 piece (c) (connector routing, collision avoidance, and the Rectilinear sibling-bar entries). Owner-picked at the Phase 0 priorities gate. Disclosure: this claim stub was written LATE -- PRE-RED fact-finding (re-reading the section, tracing issue #160's Track 1/Track 2 history, measuring the current residual count) happened first, and only after that did the PRE-RED->RED AskUserQuestion gate get posed and RED get written; caught before the RED commit, corrected by writing this stub now rather than silently skipping it (same class of self-caught process slip as S790's own disclosures).
what_was_done: pending
next_steps: pending
key_files: pending
gotchas: pending
runtime_smoke: pending
changelog_ref: pending
commit: pending
```

```handoff
session: S790
date: 2026-09-27
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE (stage 2 piece (b) of the NEWS.Rmd release-state sweep) -- the Pedigree Diagram section's mating-symbol placement/spacing entries state the finished state: a stale duplicate-node count (22, measured S573, never re-checked) is now 113 (measured fresh); 6 overlapping "symbol sits centered/spaced" entries from many sessions merged into 1, worded "in most cases"; the "every mating symbol...each mated pair" claim reworded to "many mated pairs" (both were overstatements, same class as S789's male-left finding). 42 to 37 entries. Pieces (c), (d) remain, in BACKLOG.md.
what_was_done: claim f953672e; RED a2d440f1 (matingUnitDuplicateCount() + unit test, extended promisesEveryPair() to flag a leading "each", 2 new section-scoped real-file checks; 24 tests, 92 expectations, 3 failing by design); RED ledger backfill 7d0fae64 (the RED commit omitted its own CHANGELOG.md entry, caught and fixed before the next commit); GREEN b007682c (NEWS.Rmd only: target file 24/88/0 failed; full unfiltered suite 354 files, 2,752 tests, 8,582 expectations, 1 failed = the known pkgdown draft, 0 errors, 187 skipped, 6 warnings, matching the S789 baseline plus this piece's own +3/+14 exactly; NEWS.Rmd knits); REFACTOR ff682ffb (no behavior change; BACKLOG.md sweep item narrowed, pieces (c)/(d) line ranges re-derived fresh against the post-edit file); the S790 records commit carries this receipt, SESSION_NOTES.md and Learning 803.
next_steps: (A) Stage 2 piece (c): connector routing, collision avoidance and the Rectilinear sibling-bar entries (READY, M), BACKLOG.md working (re-derive at pickup -- as of this close: :67-69, :79-90, :122-130, :137-142, :153-164, :178-198); the item flags NEWS.Rmd:82's "Two rarer related cases are not corrected" (issue #160) as kept but NOT re-checked against the code -- piece (c) must find what the two cases are. Add checks as failing tests FIRST, scoped with newsSectionEntries(); verify every claim against real output (Learning 802/803). (B) Also READY: the docs staleness audit (L); the a2interactive reportMatePairs() section (S) sub-item (1); the PED_GV cleanup bundle (S); the Chrome-for-Testing hang root cause (M, optional); the BACKLOG.md ledger-size housekeeping (L). (C) DECISION NEEDED: male-left placement roxygen vs. real layouts (S); blank/unrecognized sex reported as a wrong-sex parent (S); the isAddedRecord() helper (S, optional); convertDate row numbering (S, low); getAncestors() absent id (S); F2/F3 of the PED_GV item; paths-ignore (S). (D) Owner items: contributor tutorial, papers (own scoping session first), harem-sire hole, blank ancestry OTHER/UNKNOWN, LabKey (both items), retrospective backfill, trimmer verify false positive. (E) Your decisions open: the working-tree residue (untouched), the push of the 15 local commits after ff8308a5 (CI has not seen S790; NEWS.Rmd and a test file changed, so await it), closing the 11 recommended PED_GV ids, the NEWS.Rmd:18 Package entry, the two methodology files context_budget.py flags as matching no canonical revision (still not investigated). HANDOFFS.md is at or near its 65,536 B trim budget after this receipt -- propose the owner-gated archive pass early next session if a commit is refused.
key_files: tests/testthat/test_newsReleaseState.R (matingUnitDuplicateCount() and its unit test, the extended promisesEveryPair() with its each-idiom control, the 2 new real-file checks before the #168 test); NEWS.Rmd:21 (Pedigree Diagram section, 37 entries; rewritten at :73-78, :91-95, :143-146); R/makePedigreeDiagramData.R (.buildMatingUnitForest(), the duplicates data frame); tests/testthat/test_positionMatingUnitForest.R:2917-2974 (the disclosed-residuals centering test); BACKLOG.md working (sweep item, narrowed); CHANGELOG.md (S790 entries, newest first: REFACTOR, GREEN, RED ledger backfill, RED, claim); PROJECT_LEARNINGS.md:2273 (Learning 803).
gotchas: (1) Expect 0 undocumented on both frontiers -- measure; 15 unpushed after this records commit (recount); origin/master = ff8308a5, CI green (4/4) but has NOT seen any S790 commit. Working tree NOT clean: BACKLOG.md = owner's 5-line header only, untracked BACKLOG.log, two suggested_NEWS_entry drafts, 5 render artifacts; stage by name; BACKLOG.md commit recipe: tail -n +6 into a blob, hash-object, update-index --cacheinfo, commit, confirm the diff is the 5 header lines (worked again). (2) Full suite baseline: 354 files, 2,752 tests, 8,582 expectations, 187 skipped, 6 warnings, 1 failed (pkgdown draft) on a quiet machine; check uptime first (Learnings 760, 800). (3) Ratchet 1/1 at ff682ffb (results ce2ee7e8ec51, manifest aa983075d6a2): compare BEFORE any run, run AFTER committing. (4) Wording contracts from pieces (a)/(b): a limit number followed within 60 non-digit chars by its style name; "default" attaches to the style named just before it, else the first after; exactly one shading entry; no "by default" or every-pair word on male-left; the duplicate-count entry cites a number a test recomputes fresh (do not hand-edit without re-running it); promisesEveryPair() now flags "each" only when followed by a word, not punctuation. Each piece scopes its own new patterns with newsSectionEntries(). (5) HANDOFFS.md measured 62,993 B before this receipt (budget 65,536 B) -- this receipt likely crosses it; if a commit is refused, run methodology_trim.py --file HANDOFFS.md --write --budget-bytes 65536 (expect the SRF small-denominator refusal and --force, owner-gated), trim CHANGELOG.md LAST (Learning 761). SESSION_NOTES.md 51,669 B (~22.8k tokens against the 25,000-token hook ceiling), CHANGELOG.md 46,815 B before this session's own growth -- both have headroom but check with context_budget.py, not wc -c alone. (6) STANDING SET carried in this receipt (unchanged from S789's gotcha 7, condensed): full-40-char sha from git rev-parse and a smoke-tested gh run filter; git log --grep needs --extended-regexp plus a control id; scratchpad/ invisible to git BY OWNER DECISION; CLAUDE.md warn band = headroom; trim budget 65,536 B for all three ledgers, trim CHANGELOG.md LAST and the cut keeps the N newest; the hook counts TOKENS (2.27 B/token, ceiling 25,000 = 56,750 B) and refuses a commit that GROWS an over-ceiling file (do not bypass); zsh traps (unquoted list vars, ${PIPESTATUS[0]}, unquoted globs, BSD sed -i, a cd persisting across Bash calls); a foreground sleep is blocked (use run_in_background); skip waiting on CI only when every changed file is .Rbuildignored and read by no test. NEW in S790: pose the PRE-RED->RED phase gate as the very next action after PRE-RED fact-finding, before opening any test file (Learning 803d); each TDD-phase commit needs its OWN CHANGELOG.md entry as it happens -- verify against a recent session's git show --stat if in doubt; a shared lexical guard extended for a new trigger word needs a control for that word's other, harmless use (Learning 803c); a number cited in a NEWS entry can go stale from LATER, unrelated code changes even though it was correct when written -- pin it with a test that recomputes it from real output (Learning 803a).
runtime_smoke: n/a -- NEWS.Rmd, a test file and records only; no runtime behavior changed (no R/ file touched); claims checked against real .buildMatingUnitForest() output and the position engine's own test suite, not a live click-through of the Shiny Diagram tab. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results ce2ee7e8ec51 · manifest aa983075d6a2
changelog_ref: ff682ffb (REFACTOR), b007682c (GREEN), 7d0fae64 (RED ledger backfill), a2d440f1 (RED), f953672e (claim), and the S790 records entry
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log); claim f953672e
```

```handoff
session: S789
date: 2026-09-27
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE (stage 2 piece (a) of the NEWS.Rmd release-state sweep) -- the Pedigree Diagram section's display and defaults entries state the finished state against 2.0.0: the display limit is stated once (400 animals with the default Rectilinear connector style, 750 with Direct), Rectilinear is named the default (the notes called Direct the default), shading is one rule (only animals marked affected are shaded; unaffected, unknown and every animal with no affected column are drawn open), and male-left is in most cases (not by default: no setting; not always: real layouts refute it); 45 entries became 42; four section-scoped checks in tests/testthat/test_newsReleaseState.R tie the notes to the app. Pieces (b), (c), (d) remain, in BACKLOG.md.
what_was_done: claim 95d0d2de; RED 4523973e (3 helpers with unit tests and 4 real-file checks failing by design, 10 failing expectations in 4 tests as predicted); RED correction a4b61e66 (my check required the word always; probing every mixed-sex mating of the bundled pedigrees showed the male on the left in 227 of 257, 88.3 percent, so the check now forbids by default and any every-pair word: 9 failing); GREEN 4e8ada74 (NEWS.Rmd only: the file 21 tests, 74 expectations, 0 failed; full unfiltered suite 354 files, 2,749 tests, 8,568 expectations, 1 failed = the known pkgdown draft, 0 errors, 187 skipped, 6 warnings; every claim checked against the code and real layout output first); REFACTOR 9df0bac6 (one unit test moved; BACKLOG.md sweep item narrowed, male-left placement item filed, audit item extended; ratchet 1/1); ledger trim 43179247 (CHANGELOG.md 65,424 to 37,593 B, 13 of 25 records, owner-approved, --cut 12 --force, verify script OK on L1/L2/L3); ledger trim 87118663 (SESSION_NOTES.md 53,844 to 25,632 B before my record was put back, 4 of 7 records, owner-approved, --cut 3 --force, verify OK on L1/L2/L3); the S789 records commit carries this receipt, SESSION_NOTES.md and Learning 802.
next_steps: (A) Stage 2 piece (b): mating-symbol placement and spacing (READY, M), BACKLOG.md working :136 -- the item lists the NEWS.Rmd lines (:70-78, :91-100, :119-131, :152-156, :163-167; re-derive by reading the section); add the piece's checks to test_newsReleaseState.R as failing tests FIRST, scoped with newsSectionEntries(block, "Pedigree Diagram"); check every sentence against the code and real output; the entry at NEWS.Rmd:73-78 states 22 individuals in the bundled example pedigree, a number NOT verified (measure it with makePedigreeMatingLayout). (B) Also READY: the docs staleness audit (L) :195; the a2interactive reportMatePairs() section (S), sub-item 1 of :114; the PED_GV cleanup bundle (S) :13; the Chrome-for-Testing hang root cause (M, optional) :386; the BACKLOG.md ledger-size housekeeping (L) :444. (C) DECISION NEEDED: male-left placement, roxygen versus real layouts (S) :176; blank or unrecognized sex reported as a female sire or male dam (S) :39; the isAddedRecord() helper (S, optional) :56; convertDate row numbering :70; getAncestors() absent id :85; F2 and F3 :13; paths-ignore :101. (D) Owner items: contributor tutorial :222, papers :606 (own scoping session first), harem-sire :261, blank ancestry :239, LabKey :300 and :315, retrospective backfill :281, trimmer verify false positive :409. (E) Your decisions open: the working-tree residue, the push of the local commits after ff8308a5 (CI was green on ff8308a5 and has not seen S789; a test file changed, so await it), closing the 11 recommended PED_GV ids, whether to delete the Package entry at NEWS.Rmd:18, the two methodology files context_budget.py says match no canonical revision.
key_files: tests/testthat/test_newsReleaseState.R:100 (newsSectionEntries), :117 (defaultStyles), :142 (promisesEveryPair), :147 (readCap), :155 (diagramCaps), :165 (diagramSectionEntries), :276-367 (helper unit tests), :369, :396, :413, :430 (the four real-file checks); NEWS.Rmd:21 (the Pedigree Diagram section, 42 entries; rewritten entries at :22, :43, :46, :58); R/modPedigree.R:405 (limits, also :417), :423 (default style), :505 (the over-limit message); R/makePedigreeDiagramData.R:173 (.affectedColor), :1682 (layout signature), :1590 (male-left roxygen); BACKLOG.md working :136 (sweep item) and :176 (male-left item); CHANGELOG.md:63 (the S789 records entry), :82 and :90 (the two trim entries), :98 (REFACTOR), :114 (GREEN), :149 (RED correction), :172 (RED), :208 (claim); HANDOFFS.md:178 (this receipt); PROJECT_LEARNINGS.md:2272 (Learning 802); docs/archive/CHANGELOG-through-2026-09-26-3.md
gotchas: (1) Expect 0 undocumented on both frontiers at Phase 0 -- measure; 9 unpushed after this records commit (recount); origin/master = ff8308a5, CI on it green (4 of 4). The working tree will NOT be clean: BACKLOG.md modified (the owner's 5-line YAML header ONLY; verify with git diff HEAD -- BACKLOG.md), untracked BACKLOG.log, two suggested_NEWS_entry drafts and 5 render artifacts; stage by name; for a BACKLOG.md commit edit the working file, tail -n +6 into a scratch file, git hash-object -w it, git update-index --cacheinfo 100644,<sha>,BACKLOG.md, commit, then confirm the diff is the 5 header lines (worked verbatim again); working BACKLOG.md line numbers are HEAD +5. (2) A local unfiltered suite reads 1 failed on a QUIET machine (test_pkgdown_reference_config.R, the owner's draft); under host load two wall-clock benchmarks (test_markerKinship.R, test_markerParentageLikelihood.R) also fail (Learnings 760, 800). Baseline now 354 files, 2,749 tests, 8,568 expectations, 187 skipped, 6 warnings. Clean-export R CMD check only when R/ changes (recipe in the S788 receipt gotcha 2, Learning 797d). (3) Ratchet 1/1 at 9df0bac6 (3,577,928 B, results 40286d04f00e, manifest aa983075d6a2): compare BEFORE any run, run AFTER committing. (4) The new checks are wording contracts: a limit number is followed within 60 non-digit characters by its style name; default attaches to the style named just before it in the same sentence, else the first after; exactly one shading entry (the words shade, shaded, shading, filled, unfilled); the male-left entry has no by default and no always, every or all; each later piece adds its own, scoped with newsSectionEntries(); the guard from stage 1 still scans the whole newest block for milestone phrases. (5) THE COMMIT HOOK COUNTS TOKENS: SESSION_NOTES.md has a 25,000-token ceiling (56,750 B at 2.27 B per token), not the 65,536 B of the size table, and refuses a commit that GROWS an over-ceiling file (do not bypass); measure with python3 context_budget.py (it prints tokens), not wc -c. Measured after this records commit is written: SESSION_NOTES.md 37,289 B, HANDOFFS.md about 62 KB (trim budget 65,536 B: the next claim stub plus a close-out receipt of this size (about 9 KB, too big: keep the next one under 5 KB) will cross it, so propose the owner-gated HANDOFFS.md archive pass at Orient or before the receipt), CHANGELOG.md about 41 KB. (6) The S788 receipt gotcha (1) is superseded (the push happened). (7) STANDING SET (carried from S787, condensed; READ IT BEFORE THE FIRST COMMAND): full-40-char sha from git rev-parse and a smoke-tested gh run filter; git log --grep needs --extended-regexp plus a control id; scratchpad/ invisible to git BY OWNER DECISION; CLAUDE.md warn band (26,658 B) = headroom; trim budget 65,536 B for ALL THREE ledgers, trim CHANGELOG.md LAST (Learning 761) and the cut keeps the N newest (Learning 777); the hook counts TOKENS (2.27 B/token, ceiling 25,000 = 56,750 B) and refuses a commit that GROWS an over-ceiling budgeted file (do not bypass); shinytest2 0.5.1 load_all()s the checkout (Learning 789); .Rprofile prints renv::status(dev = TRUE) at an interactive start from the package root (normal); zsh traps: an unquoted list variable does not word-split, ${PIPESTATUS[0]} prints empty, an unquoted glob in --include= aborts (quote it), stat is the builtin (use /usr/bin/stat), echo ===== fails, an apostrophe or parenthesis inside an unquoted echo argument aborts the whole command (put probe scripts in files), a cd <dir> && ... persists across Bash calls (start each command with cd <root> &&), BSD sed -i needs an empty suffix (or use Python); a foreground sleep is blocked (use run_in_background; a plain command run with run_in_background notifies at its real end, Learning 799f); the Grep tool may be unavailable (use grep through Bash with quoted globs); skip waiting on CI only for pushes whose every changed file is .Rbuildignored and read by no test, but DO await it when R/ or tests changed; NEW in S788: put a scope question to the owner in plain words first (feedback memory and Learning 801c); a grep -l for a file NAME matches comments (grep for a read call instead); a shell variable assigned earlier in the line is not in Rscript's environment (use the literal path); the AskUserQuestion header for a phase gate can exceed 12 characters (accepted). NEW in S789: AskUserQuestion takes the questions array (a pasted string fails to parse, twice); a full suite run alone in the background takes 4.6 minutes at load about 6 and its notification arrives at its real end; methodology_trim.py dry-run first (--cut 12 --force --budget-bytes 65536), it names its own shard (-3 when the day's name is taken) and adds its own ledger entry; verify a claim about behavior against the real function's output, not the roxygen (Learning 802).
runtime_smoke: n/a -- NEWS.Rmd, a test file and records only; no runtime behavior changed (no R/ file touched); NEWS.Rmd was knit to a scratch file (1,399 lines); the limit and default are read from the code and the shading and male-left claims were checked against real makePedigreeMatingLayout() output, not a live click-through of the Shiny Diagram tab. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 40286d04f00e · manifest aa983075d6a2
changelog_ref: 9df0bac6 (REFACTOR), 4e8ada74 (GREEN), a4b61e66 (RED correction), 4523973e (RED), 95d0d2de (claim), 43179247 and 87118663 (ledger trims), and the S789 records entry
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log); claim 95d0d2de
```

