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

## Three files, three questions, one shared key

- **`SESSION_NOTES.md`** — the *transient scratchpad*: rich working notes, overwritten every session.
- **`HANDOFFS.md`** (this file) — the *durable receipt*: the distilled, machine-checkable proof that
  the handoff was written, kept forever.
- **`CHANGELOG.md`** — the *cumulative action ledger*: *"what was done here, ever?"*, append-only.

The shared key across all three is the commit sha (`changelog_ref` / `commit` here). This file
**distills** the handoff; it does not copy the scratchpad. The belongs-here test: *would the next
session need this block to continue the work without re-reading the whole repo?*

---

<!-- Receipts go below, newest on top. Delete the seed-sentinel line above when you add the first one. -->

```handoff
session: S325
date: 2026-07-08
status: pending
self_score: TBD
predecessor_score: TBD
active_task: Resolve CHANGELOG.md ledger-format gap (freeze legacy, go forward) -- in progress.
what_was_done: pending
next_steps: pending
key_files: CHANGELOG.md
gotchas: pending
runtime_smoke: n/a — docs-only
changelog_ref: pending
commit: pending
```

```handoff
session: S324
date: 2026-07-08
status: complete
self_score: 8
predecessor_score: 9
active_task: Methodology sync to canonical v3.4 — complete. CRAN 2.0.0 Phase 5b (win-builder/R-hub) remains owner-triggered, not started this session.
what_was_done: Ran bin/sync --source=local --force (full unshallowed clone of KJ5HST/methodology, cross-checked against rmsharp/methodology fork) to update SESSION_RUNNER.md, SAFEGUARDS.md, RECOMMENDED_SKILLS.md, methodology_dashboard.py, docs/methodology/{ITERATIVE_METHODOLOGY,HOW_TO_USE}.md, all 9 docs/methodology/workstreams/*.md; created BOOTSTRAP.md, CLAUDE_TEMPLATE.md, CONTEXT_TEMPLATE.md, HANDOFFS.md. Manually refreshed docs/methodology/README.md (not manifest-tracked). Updated CLAUDE.md (FM count 25->27, new CHANGELOG ledger-gap note) and .gitignore (dashboard_history.jsonl). CHANGELOG.md entry: 2026-07-08 Session 324. Commit: pending.
next_steps: Either (a) resume docs/planning/cran-2.0.0-submission-plan.md Phase 5b — owner-triggered win-builder x3 + R-hub v2, see SESSION_NOTES.md S323 entry — or (b) run a dedicated CHANGELOG.md ledger-format migration session per CLAUDE.md's new Adaptations note (canonical v3.1+ ledger format vs. this project's ~30+-session dated-subsection history).
key_files: CLAUDE.md (Adaptations section, FM-count + CHANGELOG-gap edits), CHANGELOG.md:17-28 (this entry), PROJECT_LEARNINGS.md Learning 301 (shallow-clone / force-overwrite-verification findings), .gitignore (dashboard_history.jsonl), SESSION_RUNNER.md + SAFEGUARDS.md (full canonical replace, now v3.4)
gotchas: CHANGELOG.md is deliberately still old-format (SEED disposition, bin/sync never auto-migrates it) — do not force new-format `[SOURCE]`-tagged entries into it without a dedicated migration pass. Any future methodology sync MUST git fetch --unshallow the canonical clone first, or bin/status falsely reports every TRACKED file as "locally modified" (Learning 301).
runtime_smoke: n/a — docs/infra-only, no R/ package runtime behavior changed
changelog_ref: CHANGELOG.md 2026-07-08 "Update methodology to canonical v3.4 (Session 324)"
commit: pending
```
Synced this project's methodology tooling from a stale v2.6 to the current canonical v3.4 (8 tagged releases), per the user's literal BOOTSTRAP.md-documented request. Verified before force-overwriting the two flagged files (no real customization lost — traced to a prior session's pre-release wording adoption, not a hand-edit). Deferred the CHANGELOG.md ledger-format migration as its own future task rather than bundling a large history reformat into this sync, per the tool's own documented guidance. Self-score 8/10: +diligent verification before any destructive action (shallow-clone bug caught, fork cross-check, project-term grep before --force), +correct scope boundary (didn't reformat 30+ sessions of CHANGELOG history), +adopted the new HANDOFFS.md receipt immediately rather than waiting for a future reconcile; -did not open a Phase 1B pending stub for this deliverable before starting (the new protocol requiring it wasn't yet synced in when the task began — retroactive rather than upfront), -did not restate "TDD Phase: N/A" inline at the top of each chat response per CLAUDE.md's literal enforcement rule during this task. Predecessor (S323) scored 9/10 on documentation quality/completeness alone — its CRAN-plan handoff was not exercised this session since the user redirected to an unrelated deliverable, which is not a mark against it.
