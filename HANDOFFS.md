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

This file currently holds **1** receipt(s). Computed by `methodology_trim.py` on every
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

```handoff
session: S721
date: 2026-09-19
status: complete
self_score: 9
predecessor_score: 9
active_task: Suggests: audit DONE — all 22 DESCRIPTION Suggests: entries audited against the owner's rule; 16 retained with grep-verified load sites, 6 relocated/removed (owner-ratified via 2 AskUserQuestion gates): devtools + roxygen2 to the new Config/Needs/dev group, quarto dropped (already Config/Needs/website), grid/png/shinyWidgets deleted as unused everywhere. renv.lock re-snapshotted (dev = TRUE, S637 precedent, 21 packages dropped). BACKLOG item removed in the deliverable commit. Also filed (owner mid-session request, ede5289e): BACKLOG Housekeeping item to measure package growth from the pedigree-drawing feature (rough +/-20% acceptable). No TDD phases (metadata only, no .R files).
what_was_done: Claim 05943cd5. Owner-requested backlog item ede5289e. Deliverable cd748874: DESCRIPTION (6 Suggests lines out, Config/Needs/dev in; roxygen2's version constraint superseded by Config/roxygen2/version) + renv::snapshot(dev = TRUE) + BACKLOG item removal + full-audit CHANGELOG entry. Audit method: grep inventory across R/, tests/, vignettes/, man/, inst/, data-raw/, then every thin hit READ for code-vs-comment — devtools' 20+ hits are all comments (out); pkgdown's one hit is real test code, test_pkgdown_reference_config.R:25 (stays, filing item's suspicion refuted); a secondary engine sweep kept markdown (a3manual.{Rmd,md} knitr::knitr engine renders through it). Verified: full regression read blocks=2437 failed=0 error=0 skipped=184 warning=40 (equals S718-S720 baseline exactly); full devtools::check() 21m52s, 0 errors, all dependency gates OK, 0 new warnings/notes (the 1 WARNING + 1 NOTE name pre-existing untracked clutter: inst/extdata/reference/~$e Compounding Loop.html and scratchpad/).
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~12 expected after close-out; estimate). (B) Priorities: CLAUDE.md reduction campaign (READY, M); pedigree-growth measurement (READY, S, owner-requested S721); owner decisions pending: package-split disposition, REUSE registration. (C) Owner call, trivial: delete the stray untracked ~$e Compounding Loop.html (it alone makes devtools::check() warn and exit 1 non-interactively).
key_files: DESCRIPTION:60 (trimmed Suggests), DESCRIPTION:85 (Config/Needs website/coverage/dev), renv.lock:1 (21 packages dropped), BACKLOG.md:96 (new pedigree-growth Housekeeping item), PROJECT_LEARNINGS.md (Learning 766), SESSION_NOTES.md:33 (full S721 handoff)
gotchas: devtools::check() exits 1 non-interactively until the stray ~$ file is removed — pre-existing clutter WARNING, not a regression; current true baseline is 0 errors + that WARNING + the scratchpad/ NOTE. renv.lock no longer carries dev tooling (devtools/roxygen2/quarto/pak/usethis/rcmdcheck etc.) — fresh-clone restore yields a runtime+test library only; install dev tooling via Config/Needs/dev / Config/Needs/website or the renv dev profile field. S720's standing gotchas carry forward (context-budget reds by design; every methodology_trim.py run needs --budget-bytes 65536; per-clone no-growth hook). grid/png/shinyWidgets deletion means "unused now", not "banned" — re-declare in Suggests if reintroduced.
runtime_smoke: n/a — dependency metadata only; no runtime code path changed (removed packages have zero R/ references, grep-proven; every R/-loaded package retained). Full suite at exact baseline + full devtools::check() incl. vignette rebuild ran as the verification instead.
changelog_ref: cd748874
commit: pending
```
<free-text: S721 +/- — plus: read-every-hit discipline flipped two classifications before they became errors (devtools out despite many hits, markdown kept despite zero direct hits); renv question settled by precedent (S637 526c7fec, covr absent from lock), not guesswork; CI-safety of the quarto drop verified (pkgdown.yaml needs: website) before removal. Minus: the first grep pattern set was library()/::-shaped and would have missed the markdown engine dependency without a deliberate secondary sweep; check's non-interactive exit-1 briefly read as a failure before the log was inspected.>

```handoff
session: S720
date: 2026-09-19
status: complete

```handoff
session: S720
date: 2026-09-19
status: complete
self_score: 9
predecessor_score: 9
active_task: context_budget.py ADOPTED with honest ceilings; methodology_trim.py budget SETTLED at the old 65,536 B cadence (pass --budget-bytes 65536 on every run, recorded in CLAUDE.md); the owed SESSION_NOTES.md trim executed (79,738 B to 3,500 B). BACKLOG.md:119 item DONE and removed. Both decisions owner-ratified via AskUserQuestion. Docs/process tooling, no TDD phases, no .R files touched. Open: owner push decision; the new CLAUDE.md reduction campaign item (READY, M) is the remedy for the deliberate CLAUDE.md red.
what_was_done: Claim 572562f1. Evaluation: seed-config run exit 2; --calibrate REJECTED (0.60 B/token, negative -6,015-token intercept, n=119, R^2=0.73 — implausible/confounded), dashboard-measured 2.27 B/token adopted instead; overlap analysis showed CLAUDE.md is the one Phase-0 mandated read nothing gates. Adoption bc6be1d0: .context-budget.json rewritten with derivations in _ keys (SESSION_NOTES.md max_bytes = 65,536 = the trimmer cadence, one remedy per red; max_lines 1000 at measured ~69 B/line; structure patterns fixed for this file's real layout — note max 0 is a literal bound, not a disable); budget:protected fence around CLAUDE.md's Project Overview; per-clone no-growth pre-commit hook installed; Phase 0 check + red-by-design expectations recorded in CLAUDE.md; completed BACKLOG item removed, successor CLAUDE.md-reduction item filed; committed --no-verify (the hook correctly refuses the CLAUDE.md growth this commit itself makes — recorded bypass). Trim c079c27a: 21 records to docs/archive/SESSION_NOTES-through-2026-09-19.md under --budget-bytes 65536, verify.sh L1/L2/L3 OK before commit; the hook ran live on this commit and passed the shrink path. Full suite re-run at close-out — result in the close-out CHANGELOG entry.
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~6 expected after close-out; estimate). (B) Suggests: audit (READY, S, near BACKLOG.md:133). (C) Owner decisions pending: package-split disposition (BACKLOG.md:71), REUSE registration (BACKLOG.md Housekeeping). (D) CLAUDE.md reduction campaign (new item, READY, M) — clears the by-design red.
key_files: .context-budget.json:1 (calibrated config, derivations inline), CLAUDE.md:131 (Context-budget check, Additional Phase 0 steps), CLAUDE.md:293 (trigger-budget decision inside the methodology_trim.py checklist), BACKLOG.md:119 (CLAUDE.md reduction campaign item), docs/archive/SESSION_NOTES-through-2026-09-19.md:1 (shard + .verify.sh), SESSION_NOTES.md:33 (full S720 handoff)
gotchas: Phase 0's python3 context_budget.py exits 2 with CLAUDE.md + resident red BY DESIGN until the reduction campaign lands — only NEW reds are findings; a SESSION_NOTES.md red means exactly one thing, a --budget-bytes 65536 trim is owed. The per-clone hook refuses any commit growing CLAUDE.md — shrink or --no-verify with the rationale recorded; fresh clones re-run install-hook. Every methodology_trim.py run needs --budget-bytes 65536. HANDOFFS.md was 62,667 B before this receipt and is within ~3 KB of the budget — this close-out measures it after appending and trims if it fires (result in the close-out ledger entry). The dashboard's SESSION_NOTES.md HIGH-flag text (trimmer answers NO_CONFIG) overstates — stock-class hardcoding vs the local extension; act on the size, not the text.
runtime_smoke: The deliverable IS tooling: post-config context_budget.py run shows exactly the intended reds and both sync-drift checks ok; --selftest passes (refuse paths observed there); hook observed live passing the shrink path on c079c27a and bypassed with recorded rationale on bc6be1d0; trimmer verify.sh L1/L2/L3 OK pre-commit. R package untouched; full suite re-run at close-out as insurance.
changelog_ref: bc6be1d0
commit: 7e8ebc5f
```

