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

```handoff
session: S543
date: 2026-08-12
status: pending
self_score: pending
predecessor_score: pending
active_task: CHANGELOG.md SRF_RED archive-refusal decision (owner-picked via Phase 0
AskUserQuestion picker, over test-coverage.yaml CI diagnosis / Phase 0 CI-check-gap decision /
issue #138 scoping).
what_was_done: pending
next_steps: pending
key_files: pending
gotchas: pending
runtime_smoke: pending
changelog_ref: pending
commit: pending
```

```handoff
session: S542
date: 2026-08-12
status: complete
self_score: 8
predecessor_score: 9
active_task: HANDOFFS.md archived (226,617 B -> 8,629 B, 2,908 -> 142 lines). CHANGELOG.md's own
archive attempt refused (SRF_RED) and was deliberately NOT forced -- left for a future session's
scoping decision, logged to BACKLOG.md. 2 new BACKLOG.md Housekeeping findings this session:
test-coverage.yaml CI break (READY to diagnose), CHANGELOG.md SRF_RED (DECISION NEEDED).
what_was_done: Ran methodology_trim.py --file HANDOFFS.md --write: archived 39 of 40 records to
docs/archive/HANDOFFS-through-2026-08-12.md, verified lossless via the tool's own generated
verify.sh (L1/L2/L3 OK) before committing. Confirmed the sole retained record was this session's
own pending stub. Logged the Phase 1B claim commit to CHANGELOG.md first (a2550a1e), per
Learning 545, to clear the tool's P1_UNDOCUMENTED gate. Also ran gh run list beyond the routine
Phase 0 checklist and found test-coverage.yaml failing on origin/master's last 2 pushes (S536,
S540) -- confirmed R-CMD-check.yaml itself had gone green (closing S541's own open question).
Commits: 62882046 (claim), a2550a1e (ledger: record claim), 3ddb59ea (the archive), this
close-out's own commit (sha pending at write time, self-referential).
next_steps: Two new BACKLOG.md Housekeeping items, both unstarted: (1) test-coverage.yaml CI
break -- READY to diagnose, Effort S/M; needs gh run view <id> --log (not --log-failed) or a
local covr::package_coverage() repro to isolate the actual testthat.R failure past the
spelling.R sandbox-path noise. (2) CHANGELOG.md SRF_RED refusal -- DECISION NEEDED, Effort S;
a future session (or the owner) should choose between --force-ing a partial trim now vs.
reopening the S325 legacy-footer migration question. Unchanged from S541: Phase 0 CI-check gap
(DECISION NEEDED), NPRC outreach owner review (DECISION NEEDED), LabKey remaining recs (BLOCKED).
key_files: HANDOFFS.md (archived, 142 lines); docs/archive/HANDOFFS-through-2026-08-12.md (new
shard, 39 records); BACKLOG.md Housekeeping section (2 new items); CHANGELOG.md (claim entry +
tool's own auto-appended archive entry); PROJECT_LEARNINGS.md Learning 549 (new).
gotchas: (1) methodology_trim.py's SRF_RED gate is computed against the MOST RECENT archive
only -- a small preceding trim (yesterday's 11-record CHANGELOG.md archive) can make an
otherwise-healthy file refuse to archive again, while the SAME file reads healthy against its
largest-drop boundary. Read both numbers the tool prints before deciding whether --force is
appropriate; don't force reflexively off the RED reading alone. (2) The P1_UNDOCUMENTED gate
checks CHANGELOG.md's frontier regardless of which file is being trimmed (ledger_rel_for()
always returns "CHANGELOG.md") -- even a HANDOFFS.md-only trim needs the claim commit logged to
CHANGELOG.md first if the claim commit doesn't itself touch CHANGELOG.md. (3) This session ran
the Phase 0 priorities AskUserQuestion picker before the mandatory prose orientation report,
out of CLAUDE.md's documented order -- caught and corrected mid-session by re-reading that
convention; a future session should render the prose report first, every time.
runtime_smoke: n/a -- docs/ledger-only change, no runtime/Shiny behavior touched.
changelog_ref: this session's own CHANGELOG.md entries, 2026-08-12 ([ad hoc] the claim; [ad hoc]
the tool's own auto-appended HANDOFFS.md archive entry; [ad hoc] x2 for the BACKLOG.md findings)
commit: pending
```

