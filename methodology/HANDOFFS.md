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
**Put the new block directly above the newest receipt** — the first `handoff` block after the
"Size, and when to archive" section — and never inside the example box below (the code box that
opens at the four-backtick line). The trimmer counts everything inside that box as front matter, so
a receipt put there can never be archived (S917 found 104 receipts there and moved them out).

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

**Archived 181 record(s), 2026-07-08 → 2026-08-10** into [`methodology/archive/HANDOFFS-through-2026-08-10.md`](archive/HANDOFFS-through-2026-08-10.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-08-10.md.verify.sh`](archive/HANDOFFS-through-2026-08-10.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 39 record(s), 2026-08-10 → 2026-08-12** into [`methodology/archive/HANDOFFS-through-2026-08-12.md`](archive/HANDOFFS-through-2026-08-12.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-08-12.md.verify.sh`](archive/HANDOFFS-through-2026-08-12.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 17 record(s), 2026-08-12 → 2026-08-13** into [`methodology/archive/HANDOFFS-through-2026-08-13.md`](archive/HANDOFFS-through-2026-08-13.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-08-13.md.verify.sh`](archive/HANDOFFS-through-2026-08-13.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 21 record(s), 2026-08-13 → 2026-08-14** into [`methodology/archive/HANDOFFS-through-2026-08-14.md`](archive/HANDOFFS-through-2026-08-14.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-08-14.md.verify.sh`](archive/HANDOFFS-through-2026-08-14.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

This file currently holds **7** receipt(s). Computed by `methodology_trim.py` on every
`--check`/`--write` run, never hand-maintained.

**Archived 116 record(s), 2026-08-14 → 2026-09-17** into [`methodology/archive/HANDOFFS-through-2026-09-17.md`](archive/HANDOFFS-through-2026-09-17.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-17.md.verify.sh`](archive/HANDOFFS-through-2026-09-17.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 13 record(s), 2026-09-17 → 2026-09-18** into [`methodology/archive/HANDOFFS-through-2026-09-18.md`](archive/HANDOFFS-through-2026-09-18.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-18.md.verify.sh`](archive/HANDOFFS-through-2026-09-18.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 11 record(s), 2026-09-18 → 2026-09-19** into [`methodology/archive/HANDOFFS-through-2026-09-19.md`](archive/HANDOFFS-through-2026-09-19.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-19.md.verify.sh`](archive/HANDOFFS-through-2026-09-19.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 9 record(s), 2026-09-19 → 2026-09-19** into [`methodology/archive/HANDOFFS-through-2026-09-19-2.md`](archive/HANDOFFS-through-2026-09-19-2.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-19-2.md.verify.sh`](archive/HANDOFFS-through-2026-09-19-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 31 record(s), 2026-09-19 → 2026-09-21** into [`methodology/archive/HANDOFFS-through-2026-09-21.md`](archive/HANDOFFS-through-2026-09-21.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-21.md.verify.sh`](archive/HANDOFFS-through-2026-09-21.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 7 record(s), 2026-09-22 → 2026-09-23** into [`methodology/archive/HANDOFFS-through-2026-09-23.md`](archive/HANDOFFS-through-2026-09-23.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-23.md.verify.sh`](archive/HANDOFFS-through-2026-09-23.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 11 record(s), 2026-09-23 → 2026-09-24** into [`methodology/archive/HANDOFFS-through-2026-09-24.md`](archive/HANDOFFS-through-2026-09-24.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-24.md.verify.sh`](archive/HANDOFFS-through-2026-09-24.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 4 record(s), 2026-09-24 → 2026-09-26** into [`methodology/archive/HANDOFFS-through-2026-09-26.md`](archive/HANDOFFS-through-2026-09-26.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-26.md.verify.sh`](archive/HANDOFFS-through-2026-09-26.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 3 record(s), 2026-09-26 → 2026-09-26** into [`methodology/archive/HANDOFFS-through-2026-09-26-2.md`](archive/HANDOFFS-through-2026-09-26-2.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-26-2.md.verify.sh`](archive/HANDOFFS-through-2026-09-26-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 4 record(s), 2026-09-26 → 2026-09-26** into [`methodology/archive/HANDOFFS-through-2026-09-26-3.md`](archive/HANDOFFS-through-2026-09-26-3.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-26-3.md.verify.sh`](archive/HANDOFFS-through-2026-09-26-3.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 24 record(s), 2026-09-27 → 2026-09-30** into [`methodology/archive/HANDOFFS-through-2026-09-30.md`](archive/HANDOFFS-through-2026-09-30.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-09-30.md.verify.sh`](archive/HANDOFFS-through-2026-09-30.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 92 record(s), 2026-09-30 → 2026-10-04** into [`methodology/archive/HANDOFFS-through-2026-10-04.md`](archive/HANDOFFS-through-2026-10-04.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-10-04.md.verify.sh`](archive/HANDOFFS-through-2026-10-04.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 43 record(s), 2026-10-05 → 2026-10-08** into [`methodology/archive/HANDOFFS-through-2026-10-08.md`](archive/HANDOFFS-through-2026-10-08.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-10-08.md.verify.sh`](archive/HANDOFFS-through-2026-10-08.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 40 record(s), 2026-10-08 → 2026-10-14** into [`methodology/archive/HANDOFFS-through-2026-10-14.md`](archive/HANDOFFS-through-2026-10-14.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-10-14.md.verify.sh`](archive/HANDOFFS-through-2026-10-14.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.8.0.

**Archived 41 record(s), 2026-10-14 → 2026-10-21** into [`methodology/archive/HANDOFFS-through-2026-10-21.md`](archive/HANDOFFS-through-2026-10-21.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-10-21.md.verify.sh`](archive/HANDOFFS-through-2026-10-21.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.8.0.

**Archived 34 record(s), 2026-10-22 → 2026-10-25** into [`methodology/archive/HANDOFFS-through-2026-10-25.md`](archive/HANDOFFS-through-2026-10-25.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-10-25.md.verify.sh`](archive/HANDOFFS-through-2026-10-25.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.8.1.

**Archived 37 record(s), 2026-10-25 → 2026-10-30** into [`methodology/archive/HANDOFFS-through-2026-10-30.md`](archive/HANDOFFS-through-2026-10-30.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-10-30.md.verify.sh`](archive/HANDOFFS-through-2026-10-30.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.8.1.

```handoff
session: S1106
date: 2026-10-31
status: complete
self_score: 8
predecessor_score: 9
active_task: methodology/HANDOFFS.md trimmed, 197,992 to 32,259 B; deliverable done. CRAN 3.0.0 stays BLOCKED on CRAN's answer; the tree stays frozen. Not pushed; no shipped path changed.
what_was_done: Owner pick "Trim HANDOFFS.md". Phase 0 backfill of 37f0d1f73 in b3433354e; claim be549811b; trim ed1e53f3b (37 of 44 receipts to methodology/archive/HANDOFFS-through-2026-10-30.md; L1, L2, L3 OK). The shard's .verify.sh reads OK. test_archivePointersResolve.R, test_contextBudgetLedgers.R and test_handoffsReceiptPlacement.R: 23 tests, 0 failed, 0 errors. Learning 1071.
next_steps: Read Mark's email for CRAN's answer first: at 14:56 CDT the tarball, listed in incoming/pretest/ at 13:15, was in none of the 17 incoming/ folders and not in src/contrib/ (PACKAGES still reads 2.0.0), so CRAN has moved it and the outcome is not known here. Accepted: push the local commits, then one session runs plan Phase 10. Rejected: read the reason; a fix goes through its own RED-first session and repeats Phase 7 and Phase 8.
key_files: methodology/HANDOFFS.md:210 (new pointer), :214 (this receipt); methodology/archive/HANDOFFS-through-2026-10-30.md:1; PROJECT_LEARNINGS.md:3105 (Learning 1071); BACKLOG.md:8 (CRAN item); docs/planning/cran-3.0.0-submission-plan.md:951 (Phase 9).
gotchas: The next plain HANDOFFS.md trim is refused once the file passes 197,992 B, only 1,384 B above the 196,608 B warn line and less than one 4,507 B receipt (derived: SRF is regrowth over the last drop; it reproduced the printed 0.9922, not yet seen firing at this size). Dry-run before offering it and expect --force. Keep claim, trim and finalize in separate commits ([FRONTIER_PENDING_STUB]). zsh does not split an unquoted variable in a for loop, so a folder loop silently checks nothing: pipe to while read. The context budget's growth run stayed at 13/10 after the trim, and SESSION_RUNNER.md and SAFEGUARDS.md still differ from canonical (BACKLOG item, BLOCKED upstream).
runtime_smoke: n/a -- ledger files only; methodology/ is in .Rbuildignore (line 167) and no shipped path changed. Stand-ins: the shard's verify script and the three reader tests above.
changelog_ref: b3433354e (backfill); be549811b (claim); ed1e53f3b (tool's trim entry); the close-out commit (DONE entry)
commit: ed1e53f3b
quality_ratchet: 11/11 pass · 0 fail · 0 unmeasured · results 7a6291e7c383 · manifest 7e3e82ab3ae0 (run at ed1e53f3b, load about 4)
```

```handoff
session: S1105
date: 2026-10-31
status: complete
self_score: 7
predecessor_score: 9
active_task: CRAN 3.0.0 plan Phase 8 DONE; the cover note is final. BLOCKED on the owner's Phase 9 submission. Not pushed; no shipped path changed.
what_was_done: Owner picks "Fold in CRAN results", "Claude starts them" (D5 option B once), "Keep trying, then omit", "Page loads, wording fine". Claim d687cbc10, uploads record 124876a88, note and record 0cf20c8e9. win-builder R-devel Pkd6d075Q0To 284 s, R-release 7est97zX9ROI 303 s, R-oldrelease a97pG6c8qDzY 599 s, each 1 NOTE ("de", thoughtco 402). R-hub maritime-wuerhosaurus, run 41177345139: Status: OK on linux, windows, macos. macOS builder down 01:37 to 12:41 CDT (502), no upload, its line dropped by owner ruling. Marker grep 0.
next_steps: Addendum: the owner submitted 3.0.0 on 2026-10-31 from fa1f2849e, and it reached CRAN's pretest queue. Wait for CRAN's answer; the tree stays frozen until then. On rejection, read the reason; a fix goes through its own RED-first session and repeats Phase 7 and Phase 8. On acceptance, push the local commits, then one session runs plan Phase 10. Separately, HANDOFFS.md is past its 196,608 B warn line, so a trim is owed: python3 methodology/methodology_trim.py --file methodology/HANDOFFS.md --budget-bytes 65536 --check, then --write.
key_files: cran-comments.md:38 (check time), :50 (NOTE), :61 (environments); docs/planning/cran-3.0.0-submission-plan.md:923 (Phase 8 record), :952 (Phase 9); BACKLOG.md:8; PROJECT_LEARNINGS.md Learning 1070.
gotchas: The tree stays frozen until CRAN accepts: a change to R/, tests/, man/, vignettes/, inst/, data/ or DESCRIPTION repeats Phase 7 and these runs. use_github_release() tags the CRAN-SUBMISSION SHA and local notes commits sit ahead of origin/master, so push before Phase 10 (derived from the plan's text, not run). R-devel's time spread is 284 to 617 s, so CRAN's own reading may differ a lot; R-oldrelease read 599 s today. win-builder's result folders go after about 72 hours; the numbers are in the plan. A browser User-Agent on curl is refused as bot-check circumvention here; thoughtco stays a human check, done today.
runtime_smoke: n/a -- docs only; no shipped path changed, and S1102 ran the real app on these frozen paths. Windows, R-devel, R-oldrelease and x86_64 macOS are now verified on outside services. Not verified: CRAN's macOS builder (service down) and CRAN's linux-arm64 job, which runs only after release.
changelog_ref: d687cbc10 (claim); 124876a88 (uploads); the close-out commit (DONE entry)
commit: 0cf20c8e9
quality_ratchet: 11/11 pass · 0 fail · 0 unmeasured · results 9adc6bb2d813 · manifest 7e3e82ab3ae0
```

```handoff
session: S1104
date: 2026-10-31
status: complete
self_score: 8
predecessor_score: 9
active_task: CRAN 3.0.0 plan Phase 8, first half DONE: the cover note and the runbook are written. BLOCKED on the owner's five checks; then a session folds in the results. Not pushed; no shipped path changed.
what_was_done: Owner pick "CRAN Phase 8". Claim 839d75eac, note and runbook 01e6613c8, record fce171a03. cran/archive/20260717_cran-comments.md holds the 2.0.0 note; cran-comments.md is a 3.0.0 update with the Phase 7 results and seven "to be run before submission" lines; docs/planning/cran-3.0.0-phase8-runbook.md is new and the 2.0.0 runbook points to it. Tried: rhub 2.0.1 in a scratch library, rhub_doctor() passed. Measured: arm64 case 78 ff in CRAN's image, 78 on macOS; every read.csv()/read.table() through readWithFinalNewline(); about 80 CRAN-run test files call 236 of 236 exports; 54 exports added, none removed; no reverse dependencies.
next_steps: The owner runs docs/planning/cran-3.0.0-phase8-runbook.md (win-builder x3, R-hub, macOS builder). Then one session, "fold in the CRAN Phase 8 results": replace the seven marked lines in cran-comments.md, correct the NOTE list to win-builder's, grep the marker to 0, record it in the plan and BACKLOG.md:8. HARD STOP: Phase 9's upload is the owner's. An estimate: one session to fold in, one after acceptance.
key_files: cran-comments.md:1; docs/planning/cran-3.0.0-phase8-runbook.md:1; docs/planning/cran-3.0.0-submission-plan.md:895 (Phase 8 and its first-half paragraph); BACKLOG.md:8; PROJECT_LEARNINGS.md Learning 1069; tests/testthat/slowTestFiles.txt:5.
gotchas: The tree stays frozen: a change to R/, tests/, man/, vignettes/, inst/, data/ or DESCRIPTION repeats Phase 7. A win-builder upload returns no receipt, and a same-named file waiting blocks a second copy. A reading over 540 s is uploaded again before anything is cut. The macOS builder prints a link and sends no email. slowTestFiles.txt's header says 79 where this run found 80 files. HANDOFFS.md is about one receipt from its 196,608 B warn line; CHANGELOG.md's trim is owed at the same WARN, not at 65,536 B. rhub went into a scratch library here; the owner's copy goes to ~/R/nprcgenekeepr-rhub. The owner has not yet read the note's wording; changes go in at fold-in.
runtime_smoke: n/a -- docs only; no shipped path changed, and S1102 ran the real app on these frozen paths. The cover note's outside results are not run yet: win-builder, R-hub and the macOS builder are the owner's (D5 = A), so Windows, R-devel and the 10-minute limit stay unverified for this tree until then.
changelog_ref: 839d75eac (claim); the close-out commit (DONE entry)
commit: 01e6613c8
quality_ratchet: 11/11 pass · 0 fail · 0 unmeasured · results 4a788c9c967e · manifest 7e3e82ab3ae0
```

```handoff
session: S1103
date: 2026-10-31
status: complete
self_score: 8
predecessor_score: 9
active_task: CRAN 3.0.0 plan Phase 7 DONE; the tree is frozen. Phase 8, the cover note and the runbook for the owner's cross-platform runs, is next. Not pushed: notes only.
what_was_done: Owner pick "CRAN Phase 7"; verification only, no code. Claim 0a3b12a1b, record c0cf01bd7. At 0a3b12a1b (frozen paths equal 74715d95b, CI green): the section 3.1 check plus manual = TRUE read Status: 1 NOTE (V8 unavailable, formulas skipped) and Status: OK with V8 in a scratch library, [ FAIL 0 | WARN 0 | SKIP 54 | PASS 1923 ]; clean read 495 files, 4,592 blocks, 0 failed, 0 errors, 225 skipped; lint_package() 0; url_check() 20 URLs correct; spell_check_package() nothing; tarball 3,507,687 B, 12 top-level entries. CRAN's arm64 image: R CMD check of that tarball Status: OK, same counts; whole suite 0 failed, 7 errors, each message read, all missing tools (quarto 4, Chrome 3), filed BACKLOG.md:195 for after acceptance.
next_steps: Plan Phase 8, docs/planning/cran-3.0.0-submission-plan.md:895: save the 2.0.0 note as cran/archive/20260717_cran-comments.md, rewrite cran-comments.md as an update with the Phase 7 results and the linux-arm64 fix, adapt docs/planning/cran-2.0.0-phase5-runbook.md, install rhub. The owner runs the cross-platform checks (D5 = A). HARD STOP before the upload. An estimate: one session for the note and runbook, one to fold in the results. Pushing is the owner's word.
key_files: docs/planning/cran-3.0.0-submission-plan.md:855 (Phase 7 and its DONE paragraph), :895 (Phase 8), section 8 dragons 10-11; BACKLOG.md:8, :195; PROJECT_LEARNINGS.md Learning 1068; tests/testthat/slowTestFiles.txt:296,301.
gotchas: A change to R/, tests/, man/, vignettes/, inst/, data/ or DESCRIPTION repeats Phase 7; cran-comments.md, docs/, methodology/ and BACKLOG.md do not ship. V8 is in neither DESCRIPTION nor renv.lock (recipe: dragon 10). Container ngk-arm64-s1093 is stopped, holds 163 packages and /root/s1103, and needs RENV_CONFIG_AUTOLOADER_ENABLED=false (dragon 11). win-builder's incoming NOTE may flag "de" and thoughtco.com (402) though url_check() passed here. HANDOFFS.md nears its 196,608 B warn line and CHANGELOG.md its 65,536 B trim budget.
runtime_smoke: n/a -- no code changed; S1102 ran the real app on these same frozen paths. R CMD check ran on macOS and Linux ARM64. Not on CI: nothing pushed. These surfaces cannot enforce Windows, R-devel or the 10-minute limit; that is Phase 8.
changelog_ref: 0a3b12a1b (claim); the close-out commit (DONE entry)
commit: c0cf01bd7
quality_ratchet: 11/11 pass · 0 fail · 0 unmeasured · results 22d33a355f47 · manifest 7e3e82ab3ae0
```

```handoff
session: S1102
date: 2026-10-30
status: complete
self_score: 7
predecessor_score: 9
active_task: CRAN 3.0.0 plan Phase 6 DONE and pushed, CI green. Phase 7, the full local gate, is next.
what_was_done: Owner picks "CRAN Phase 6: bump", "No new test", every gate "Yes", "Yes, push now". Claim a0df353ef, RED 87cdedde3, GREEN 7e0b96305 and 74715d95b (two commits for the 5-file cap, though the gate said one), REFACTOR found nothing. DESCRIPTION, NEWS heading "3.0.0 (20261030)", CITATION.cff, README.md and ROADMAP read 3.0.0; the version item left BACKLOG.md. Pushed 1778d738f..74715d95b, 19 commits.
next_steps: Plan Phase 7, docs/planning/cran-3.0.0-submission-plan.md section "Phase 7": the section 3.1 check plus manual = TRUE, clean read, lint_package(), urlchecker::url_check(), spelling::spell_check_package(), the tarball listing and the ARM64 container run. An estimate: one session. A defect found goes back to RED in its own session.
key_files: DESCRIPTION:4; NEWS.Rmd:14; CITATION.cff:11; README.md:4,8; methodology/ROADMAP.md:11-13; BACKLOG.md:8 (CRAN item); tests/testthat/test_docsAuditSixRulings.R:91-93; docs/planning/cran-3.0.0-submission-plan.md:855 (Phase 7)
gotchas: After Phase 7 any change to R/, tests/, man/, vignettes/, inst/, data/ or DESCRIPTION repeats it. runGeneKeepR() sets port 6013 and opens a browser unless passed port = and launch.browser = FALSE; options() do nothing. README.md's version date is the install's UTC build date, so it reads 2026-10-31 beside 2026-10-30. v2.0.0's NEWS heading date moved after its tag (20260708 to 20260721), so 3.0.0's may too; the owner's call. Container ngk-arm64-s1093 is stopped (exited 137), not removed. urlchecker and spelling load here.
runtime_smoke: Real app from a scratch install of this tree on port 7791: title bar "Version 3.0.0 (2026-10-31)", About tab "Version 3.0.0", no 2.0.0 in the page, no error in the log. My first launch used options(), which runGeneKeepR() ignores; it probably opened a tab in the owner's browser. Verified: clean read 495 files 4,592 blocks 0 failed 0 errors, lint_package() 0, devtools::check() 0/0/0, CI all green on 74715d95b.
changelog_ref: a0df353ef (claim); the close-out commit (DONE and push entries)
commit: 74715d95b
quality_ratchet: 11/11 pass · 0 fail · 0 unmeasured · results bf3f107bc455 · manifest 7e3e82ab3ae0
```

```handoff
session: S1101
date: 2026-10-30
status: complete
self_score: 7
predecessor_score: 4
active_task: CRAN 3.0.0 plan Phase 5 DONE. Phase 6, the version bump, is next. Not pushed.
what_was_done: Owner ruling: "If the items are about new features, we only need to generally describe the features and not provide help-page detail." Owner picks "CRAN Phase 5: finish NEWS" and every gate "Yes". Eight NEWS sections fell, the block 574 to 391 lines; every function it named stays named and makePedigreeDiagramData() is named for the first time. Reconcile cd2046589, claim 897ad786d, RED 5b548621c, GREEN e7bb0bd89, REFACTOR 26001d3e7.
next_steps: Plan Phase 6, docs/planning/cran-3.0.0-submission-plan.md section "Phase 6", BACKLOG.md:8: DESCRIPTION to 3.0.0, the NEWS heading, re-knit, reinstall, re-render README, ROADMAP cites. An estimate: one session. Pushing is the owner's word.
key_files: NEWS.Rmd:14-404 (the block); tests/testthat/test_newsReleaseState.R:182 (newestNewsBlock); test_newsReleaseState.R newFeatureDetail (the rule, above the #168 test); docs/planning/cran-3.0.0-submission-plan.md:788 (Phase 5, S1101 paragraph); BACKLOG.md:8 (the bump)
gotchas: A new feature's detail goes to help pages and the guide, never NEWS; detail about changes to things 2.0.0 had stays. 2 of 22 facts leaving NEWS: the "113 individuals" count is nowhere else, and the trend box's words were not found in the guide by search. "Speed and Memory" figures were not checked against v2.0.0 except loading (about 1.0 s against 0.4 s; NEWS says 0.9). git grep -E with a word boundary found nothing here; use plain grep. S1100's stale entry stays in git worktree list, harmless. The owner did not ask for a harem-specific relatives option; none is recorded.
runtime_smoke: n/a -- release notes and test code only; no R/ change. Verified: clean read 495 files 4,592 blocks 0 failed 0 errors, lint_package() 0, devtools::check() 0/0/0, 8 of 8 wrong sentences caught. Not on CI: nothing pushed this session.
changelog_ref: 897ad786d (claim); cd2046589 (S1100 backfill); the close-out commit (DONE entry)
commit: 26001d3e7
quality_ratchet: 11/11 pass · 0 fail · 0 unmeasured · results 0a07a5025a1c · manifest 7e3e82ab3ae0
```

```handoff
session: S1100 (reconciled by S1101's Phase 0)
date: 2026-10-30
status: reconciled
self_score: n/a -- reconstructed, not self-scored
predecessor_score: n/a -- S1100 wrote no evaluation of S1099
active_task: CRAN 3.0.0 plan Phase 5, second half: not landed. NEWS.Rmd is unchanged; a draft of both sections awaited the owner's reading and no reply came.
what_was_done: Claim 3a8080491 only. From its transcript: a v2.0.0 install in scratch, probes of the "Fixed:" claims, and a draft of Pedigree Diagram (74 to 63 lines) and Breeding Group Formation (92 to 78 lines), tried in a throwaway worktree (23 NEWS-reading test files, 323 blocks, the one failure is the pinned harem sentence, in NEWS.Rmd and NEWS.md). No TDD gate was reached.
next_steps: The owner reads the draft or asks for changes; then RED for the pinned sentence in test_haremSexRatioStopWording.R, GREEN for the text in NEWS.Rmd. The picker decides.
key_files: docs/planning/cran-3.0.0-submission-plan.md:801 (Phase 5's S1099 paragraph); NEWS.Rmd:221 (Breeding Group Formation), NEWS.Rmd:73 (Pedigree Diagram); tests/testthat/test_haremSexRatioStopWording.R:28
gotchas: The draft existed only in a scratch folder that is gone; its text survives in the local transcript 9ec2e412-5d9e-4c6d-88f9-654ec62e4371.jsonl (the Bash calls at 22:28:25Z and 22:29:32Z). The throwaway worktree left a prunable entry in `git worktree list`.
runtime_smoke: n/a -- nothing landed.
changelog_ref: 3a8080491 (claim); the backfill entry in S1101's reconcile commit
commit: 3a8080491
```

