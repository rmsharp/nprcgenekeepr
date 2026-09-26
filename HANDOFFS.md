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

This file currently holds **3** receipt(s). Computed by `methodology_trim.py` on every
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

```handoff
session: S784
date: 2026-09-26
status: pending
active_task: The NA phantom-row defect in removeUnknownAnimals() -- a recordStatus value of NA leaves an all-NA row and loses a real one (R/getRecordStatusIndex.R:15; found S782, BACKLOG.md "Up Next" item 2). Owner-picked at the Phase 0 priorities gate; the owner decides the fix shape, then one small strict-TDD slice with AskUserQuestion gates.
what_was_done: pending
commit: pending
```

```handoff
session: S783
date: 2026-09-26
status: complete
self_score: 8
predecessor_score: 9
active_task: PED_GV F4 -- DONE. getAncestors() now stops with a message naming the cycle (X -> Y -> X) instead of recursing until R aborts with "infinite recursion"; the documented diamond repeats are kept. Owner-picked at the Phase 0 priorities gate, with the owner-directed pre-step "push commits; then F4"; strict TDD with an AskUserQuestion at every gate (Pre-RED decisions, PRE-RED->RED, RED->GREEN, GREEN->REFACTOR). Owner decisions: path-based detection through an unexported worker with the exported signature unchanged; the error names the cycle; an id or parent absent from the tree and the acyclic depth limit OUT of scope and filed as their own BACKLOG item; the owner chose the REFACTOR review pass over my recommendation to skip it (no change found, no commit). F2, F3 and the two filed decisions remain open; no READY PED_GV slice is left.
what_was_done: push b5166c8b..38baa151 (18 commits, owner-directed, all four push workflows success on it); claim 38baa151; RED bebb26f5 (6 new test_that blocks in tests/testthat/test_getAncestors.R; measured 6 failing tests / 11 expectations, 6 passing); GREEN c0ef7bc6 (R/getAncestors.R only: the exported function is a wrapper over an unexported .getAncestorsOnPath(id, ptree, path) that carries the current route and stops with call. = FALSE naming the cycle); docs 4125c436 (roxygen paragraph + regenerated man/getAncestors.Rd, a NEWS.Rmd Fixed entry, BACKLOG.md F4 removed from the PED_GV item and the absent-id / depth-limit findings filed). Measured: test file 12 tests / 19 expectations, 0 failing; four caller-related files 59 expectations, 0 failed; full suite 352 files / 2,688 tests / 8,314 expectations / 1 failed / 0 errors / 187 skipped / 6 warnings (the 1 failure is test_pkgdown_reference_config.R "articles: contents covers every real article", caused by the owner's untracked vignettes/suggested_NEWS_entry.Rmd); lintr 0 on both files; R CMD check --as-cran --no-manual on a git archive $(git write-tree) export: 0 errors, 0 warnings, 1 NOTE (dev-version "Version contains large components"), * DONE / Status: / status 0 confirmed, 5.2 min; two throwaway mutation checks via a mocked binding (global visited set fails the two diamond tests; a whole-route message fails the one Z test); acyclic depth limit 997 -> 2,218 (unexplained). One disclosed change from the approved wording: "sire/dam" became "sire and dam" for nonportable_path_linter.
next_steps: (A) The NA phantom-row decision (DECISION NEEDED, S), BACKLOG.md HEAD :34, three shapes written out there; the owner picks, then a small slice. (B) The absent-id decision for getAncestors() (DECISION NEEDED, S), HEAD :55: stop with a message naming the id, or treat an absent parent as a founder (a silent behavior change). (C) F2 and F3 (DECISION NEEDED), HEAD :8. (D) READY now: NEWS.Rmd release-state sweep (M) HEAD :106 -- read the owner's untracked 3.0.0 drafts first; docs staleness audit (L) HEAD :122; the trivial cleanup bundle (S) inside the :8 item; the a2interactive reportMatePairs() section (S) HEAD :84. (E) paths-ignore (DECISION NEEDED, S) HEAD :71. (F) Owner decisions open: the working-tree residue (BACKLOG.md header, BACKLOG.log, two NEWS drafts; the draft turns one local test red), the push of the local commits after 38baa151 (RED, GREEN, docs, records), closing the 11 recommended ids.
key_files: R/getAncestors.R:49 (wrapper), :68-103 (worker; the guard at :73-81); tests/testthat/test_getAncestors.R:45 (the six new tests to :121, the diamond repeats test at :28); NEWS.Rmd:516 (the entry); man/getAncestors.Rd; R/makesLoop.R:29 and R/countLoops.R:50 (the only callers); BACKLOG.md HEAD :8 :34 :55 :71 :84 :106 :122; docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md:124 (F4); CHANGELOG.md:53 (the S783 entries); HANDOFFS.md:170 (this receipt); SESSION_NOTES.md:73 (the S782 evaluation); PROJECT_LEARNINGS.md:2266 (Learning 796); .quality-gates-results.json (untracked; the citation source).
gotchas: (1) Expect 0 undocumented on both frontiers at Phase 0 -- measure; 4 unpushed after this records commit (recount); origin/master = 38baa151. The working tree will NOT be clean: BACKLOG.md modified (the owner's 5-line YAML header ONLY; verify with git diff HEAD -- BACKLOG.md) plus untracked BACKLOG.log, suggested_NEWS_entry.md, vignettes/suggested_NEWS_entry.Rmd and the 5 known render artifacts; none is S783's; stage files by name, never git add -A. Header-less BACKLOG.md staging: edit the working file, tail -n +6 BACKLOG.md > blob, git hash-object -w blob, git update-index --cacheinfo 100644,sha,BACKLOG.md, commit, confirm the working diff is only the header. (2) A local unfiltered suite reads 1 failed while the owner's draft is in the tree (test_pkgdown_reference_config.R): expected, do not edit _pkgdown.yml for it. Faithful build check = a clean export: git archive $(git write-tree) into the scratchpad, pkgbuild::build(..., args = "--no-manual"), rcmdcheck::rcmdcheck(tb, args = c("--no-manual", "--as-cran"), error_on = "never", env = c("_R_CHECK_CRAN_INCOMING_REMOTE_" = "false", "_R_CHECK_FORCE_SUGGESTS_" = "false")) -- the argument is env, not check_env; run it in the background (5-6 min; the suite 4.6 min) and confirm "* DONE" / "Status:" in res$stdout and res$status == 0 before believing 0/0/0 (Learning 795). (3) No READY PED_GV slice remains: F2, F3, the NA defect and the absent-id defect are all owner decisions. (4) Mutation-test an unexported worker with testthat::with_mocked_bindings(code, .worker = mutant, .package = "nprcgenekeepr"); run a control first (Learning 796). (5) Ratchet 1/1 at 4125c436 (3,566,283 B, results bc39c545844e, manifest aa983075d6a2): compare BEFORE any run, run AFTER committing. (6) STANDING SET (carried from S782, condensed): full-40-char sha from git rev-parse and a smoke-tested gh run filter; git log --grep needs --extended-regexp plus a control id; scratchpad/ invisible to git BY OWNER DECISION; CLAUDE.md warn band (26,360 B) = headroom; trim budget 65,536 B for ALL THREE ledgers, trim CHANGELOG.md LAST (Learning 761); the hook counts TOKENS (2.27 B/token, ceiling 25,000: SESSION_NOTES.md was ~15,000 before S783's records) and refuses a commit that GROWS an over-ceiling budgeted file (do not bypass); shinytest2 0.5.1 load_all()s the checkout (Learning 789); .Rprofile prints renv::status(dev = TRUE) at an interactive start from the package root ("No issues found" is normal); left alone on purpose: the dead .Rbuildignore:86 line and five ignored copies of the deleted notes file under .claude/worktrees/wf_*/; zsh traps (an unquoted list variable does not word-split, ${PIPESTATUS[0]} prints empty, an unquoted glob in --include= aborts the command, NEW: stat is the zsh builtin so use /usr/bin/stat, and echo ===== fails with "= not found"); a foreground sleep before a check is blocked by the harness -- use run_in_background and wait for the notification; do not wait on CI for pushes whose every changed file is .Rbuildignored and read by no test (check the readers first), but DO await it when R/ or tests changed (this session's push did). (7) Nothing was removed from a mandated-read file this session (--check --budget-bytes 65536 fires on none). Measured at close-out: HANDOFFS.md 60,744 B and CHANGELOG.md 56,940 B against 65,536 B, and each session adds about 8-10 KB to each (an estimate from S783's own growth), so the next close-out will cross the trigger: an owner-gated archive pass (methodology_trim.py --file X --cut N --force --budget-bytes 65536; SRF_RED expected, Learnings 549/586/587; CHANGELOG.md LAST, Learning 761; N so the seam is a session boundary, Learning 777) is due at or before the next close-out. SESSION_NOTES.md (42,626 B, ~18,800 of 25,000 tokens) needs one within about two sessions.
runtime_smoke: n/a — no app caller (R/ reaches getAncestors() only through makesLoop() and countLoops(), which the app never calls; from a grep, not an app test); the roxygen example ran under R CMD check. Mechanical half: quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results bc39c545844e · manifest aa983075d6a2 (head 4125c436, 3,566,283 B).
changelog_ref: c0ef7bc6 (GREEN), 4125c436 (docs), bebb26f5 (RED), 38baa151 (claim and push)
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log); claim 38baa151
```
S783 self-score 8/10. **+** Claim first; Orient fully measured (both frontiers, remote tip, ratchet citation before the run); the function, its callers and its tests read before the Pre-RED gate; probes found that the inherited plan's "visited set" would have broken the pinned repeats, and scoped two neighbouring defects out instead of folding them in; RED proven by measured failures for the right reason; two mutation checks closed a gap the RED entry had disclosed; every phase gate went through AskUserQuestion; CI awaited on a push that carried real R/ changes; the owner's YAML header preserved. **-** I changed the approved message wording by one word for a lint rule after the gate (disclosed); R CMD check and the full suite ran on the GREEN code, before the comment-only roxygen/man/NEWS edit; three small tooling missteps (a depth-script bound, a blocked foreground sleep, two zsh traps) that cost calls, not correctness; some interim messages lacked the TDD-phase declaration; I did not open the STANDING SET. S782 evaluated 9/10 -- every Orient measurement and BACKLOG pin held and its check recipe worked as written; missing that the inherited F4 plan ("visited set" + "keep repeats") contradicts itself and that the STANDING SET is not in SESSION_NOTES; one wrong pin (HANDOFFS.md:32 for the receipt).

```handoff
session: S782
date: 2026-09-26
status: complete
self_score: 8
predecessor_score: 9
active_task: PED_GV F1 -- DONE. removeUnknownAnimals() now returns a pedigree with no recordStatus column unchanged (was 17 rows in, 0 out, silently). Owner-picked at the Phase 0 priorities gate (S781 next-steps (A)); strict TDD with an AskUserQuestion at every gate (Pre-RED contract, PRE-RED->RED, RED->GREEN, GREEN->REFACTOR). Owner decisions: return unchanged (not stop()); NA/unrecognised recordStatus OUT of scope and filed as its own BACKLOG item; the owner chose the REFACTOR review pass over my recommendation to skip it. F2, F3, F4 of the PED_GV item remain open.
what_was_done: claim a70e9dfe; RED 3772dd70 (3 new test_that blocks in tests/testthat/test_removeUnknownAnimals.R; measured 2 failing, 10 passing); GREEN 3aae4b9c (a return(ped) guard in R/removeUnknownAnimals.R plus one roxygen @return sentence and its regenerated man page); REFACTOR e948f790 (one no-op stri_c() removed from a test title); docs 00610aed (a NEWS.Rmd Fixed entry; BACKLOG.md F1 removed from the PED_GV item and the NA phantom-row defect filed). Measured: test file 13 expectations, 0 failing; full suite 352 files / 2,682 tests / 1 failed / 0 errors / 6 warnings (the 1 failure is test_pkgdown_reference_config.R "articles: contents covers every real article", caused by the owner's untracked vignettes/suggested_NEWS_entry.Rmd; the 6 warnings are all in test_modGeneticValue_snapshotSource.R); lint 0 on both files; R CMD check --as-cran --no-manual on a git archive $(git write-tree) export: 0 errors, 0 warnings, 1 NOTE (dev-version "Version contains large components", not re-measured on the parent), examples OK, tests OK, exit 0. Probe P2 found a second defect in the same function (a NA recordStatus gives an all-NA phantom row); filed, not fixed.
next_steps: (A) F4 (READY, S): getAncestors() cycle guard at R/getAncestors.R:44 (the S781 pin for the body is :44-67); keep the documented repeats (tests/testthat/test_getAncestors.R:28); BACKLOG.md HEAD :8; strict TDD with AskUserQuestion gates and a Pre-RED question on the message wording. (B) The NA phantom-row decision (DECISION NEEDED, S), BACKLOG.md HEAD :34, three shapes written out there; the owner picks, then a small slice. (C) F2 and F3 (DECISION NEEDED), BACKLOG.md HEAD :8. (D) NEWS.Rmd release-state sweep (READY, M), BACKLOG.md HEAD :90 -- read the owner's untracked 3.0.0 drafts first. (E) Docs staleness audit (READY, L) HEAD :106; paths-ignore (DECISION NEEDED, S) HEAD :55. (F) Owner decisions open: the working-tree residue (now with a measured cost: vignettes/suggested_NEWS_entry.Rmd makes one local test red and would be built as a vignette by a working-tree check), the push (17 local commits), closing the 11 recommended ids.
key_files: R/removeUnknownAnimals.R:23 (the fix); tests/testthat/test_removeUnknownAnimals.R:30 (the three new tests); R/getRecordStatusIndex.R:14 (untouched; two callers); R/getDateErrorsAndConvertDatesInPed.R:39; R/getAncestors.R:44 (F4); BACKLOG.md:34 (the NA item at HEAD) and :8 (the PED_GV item); docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md:99 (F1-F4); CHANGELOG.md:53 (the S782 entries); HANDOFFS.md:170 (this receipt); SESSION_NOTES.md:73 (the S781 evaluation); PROJECT_LEARNINGS.md:2265 (Learning 795); .quality-gates-results.json (untracked; the citation source).
gotchas: (1) Expect 0 undocumented on both frontiers at Phase 0 -- measure; 17 unpushed after this records commit (recount); origin/master = b5166c8b. The working tree will NOT be clean: BACKLOG.md modified (the owner's 5-line YAML header ONLY; verify with git diff BACKLOG.md) plus untracked BACKLOG.log, suggested_NEWS_entry.md, vignettes/suggested_NEWS_entry.Rmd and the 5 known render artifacts; none is S782's; stage files by name, never git add -A. Header-less BACKLOG.md staging: edit the working file, tail -n +6 BACKLOG.md > blob, git hash-object -w blob, git update-index --cacheinfo 100644,sha,BACKLOG.md, commit, confirm git diff BACKLOG.md shows only the header. (2) A local unfiltered suite reads 1 failed while the owner's draft is in the tree (test_pkgdown_reference_config.R): expected, do not edit _pkgdown.yml for it. For a faithful build check use a clean export (git archive $(git write-tree) or HEAD into the scratchpad), pkgbuild::build(..., args = "--no-manual"), then rcmdcheck::rcmdcheck(tb, args = c("--no-manual", "--as-cran"), error_on = "never", env = c("_R_CHECK_CRAN_INCOMING_REMOTE_" = "false", "_R_CHECK_FORCE_SUGGESTS_" = "false")) -- the argument is env, not check_env; run it in the background (6 min 20 s measured; the suite 4 min 50 s) and confirm "* DONE" / "Status:" in res$stdout and res$status == 0 before believing 0/0/0 (Learning 795). (3) Do not fix the NA defect inside getRecordStatusIndex() without the owner's pick: it has two callers. (4) Ratchet 1/1 at 00610aed (3,565,387 B, results 76631f2eafcc, manifest aa983075d6a2): compare BEFORE any run, run AFTER committing. (5) Sizes: the hook counts TOKENS (2.27 B/token, ceiling 25,000): measure with python3 context_budget.py --json; SESSION_NOTES.md is one record heavier than S781 left it, so expect an owner-gated trim (--cut N --force) within about two sessions (an estimate); HANDOFFS.md and CHANGELOG.md are under 65,536 B. (6) STANDING SET (carried from S781, condensed): full-40-char sha from git rev-parse and a smoke-tested gh run filter; git log --grep needs --extended-regexp plus a control id; scratchpad/ invisible to git BY OWNER DECISION; CLAUDE.md warn band (26,360 B) = headroom; trim budget 65,536 B for ALL THREE ledgers, trim CHANGELOG.md LAST (Learning 761); shinytest2 0.5.1 load_all()s the checkout (Learning 789); the hook refuses a commit that GROWS an over-ceiling budgeted file (do not bypass); .Rprofile prints renv::status(dev = TRUE) at an interactive start from the package root ("No issues found" is normal); left alone on purpose: the dead .Rbuildignore:86 line and five ignored copies of the deleted notes file under .claude/worktrees/wf_*/; zsh traps (an unquoted list variable does not word-split, ${PIPESTATUS[0]} prints empty, an unquoted glob in --include= aborts the command); do not wait on CI for pushes whose every changed file is .Rbuildignored and read by no test (check the readers first).
runtime_smoke: n/a — no app caller (R/ never calls removeUnknownAnimals()); the roxygen example ran under R CMD check (examples OK). Mechanical half: quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 76631f2eafcc · manifest aa983075d6a2 (head 00610aed, 3,565,387 B).
changelog_ref: 3aae4b9c (GREEN), 00610aed (docs), 3772dd70 (RED), e948f790 (REFACTOR)
commit: the records commit that carries this receipt (a commit cannot name its own hash; see git log); claim a70e9dfe
```
S782 self-score 8/10. **+** Claim first; Orient fully measured (both frontiers, remote tip, ratchet citation before the run); the function and every reference read before the Pre-RED gate; probes found and scoped a second defect (NA status) instead of folding it in or hiding it; RED proven by a measured failure; every phase gate went through AskUserQuestion; the check re-run caught a false clean before it reached a ledger; a clean export kept the owner's draft out of the evidence; the owner's YAML header preserved. **-** Three bad R CMD check attempts before the one that counts (an offline --as-cran assumption that produced a false 0/0/0, a diagnostic re-run, then an unchecked argument name) -- only about 1.3 minutes of compute, but each a chance to record a false clean, and I stated two durations I had not measured ("about 40 minutes lost", "about 20 minutes" per check; measured: 6 min 20 s), corrected here; I ran the suite in a tree I knew held untracked owner drafts and only then worked out why one test failed; no mutation check on the guard tests (only T1 was proven to fail); the REFACTOR was marginal, and I did not re-run the full suite or check after it (said so in its ledger entry). S781 evaluated 9/10 -- every Orient measurement held and the F1 plan was followed as written; missing only that the owner's untracked NEWS draft turns one local test red and pollutes a working-tree check; one small size figure was off (23,863 B stated, 24,039 B measured).

