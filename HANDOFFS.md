# Handoff Receipts — durable close-out proof

The cumulative, append-only record of **each session’s close-out
handoff**, distilled into a machine-checkable block. It is the durable
answer to *“was close-out actually performed, and what did the session
hand its successor?”* — the part of close-out that otherwise lives only
in the transient `SESSION_NOTES.md` (overwritten every session) or the
spoken report (which leaves no file at all).

One `handoff` block per **session** (not per commit), newest on top. The
canonical-only `bin/check-handoff` (copy it into your `bin/` if you want
the structural check) asserts each block is present and structurally
complete; the next session’s Phase 0 reconcile greps this file for a
missing or still-`pending` receipt and backfills it — that reconcile,
not the checker, is the dependable backstop, so the discipline needs no
tooling. Together — a write-step at close-out **and** a
reconcile-on-read backstop — this makes a skipped handoff *detectable*
rather than silent.

> **A green `bin/check-handoff` is not a good handoff.** The check
> verifies presence and structure, never semantic quality. Faithfulness
> is still scored 1–10 by the next session (Phase 3A). A well-formed but
> hollow receipt passes the check and is caught only by that human
> judgement.

## How to write a receipt

**At Phase 1B (claim the session)** — write the stub block below with
`status: pending`, filling what you can, and commit it with your
session-claim commit. This committed `pending` block is the crash
breadcrumb: if the session ends before close-out, the next session’s
Phase 0 reconcile sees it.

**At Phase 3D (close-out)** — overwrite that block in place to
`status: complete` and fill every field. The block must satisfy all six
Minimum Handoff Requirements (`SESSION_RUNNER.md` §3D).

## Format — a fenced `handoff` block

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

`self_score` and `predecessor_score` are distinct keys so one can never
stand in for the other; omit `predecessor_score` on Session 1 (there is
no predecessor to score). `commit: pending` and `what_was_done: pending`
are legal at write time (the receipt ships in the very commit whose sha
it would name); the next session reconciles them to real shas.

## Size, and when to archive

handoffs-format: 2 — keep this marker, and bring it across with this
section; `bin/status` reads it.

This file gains a receipt every session and nothing removes one, so it
grows without bound. The protocol never asks a session to read it whole:
Phase 0 reconciles it against `git log` and checks the newest receipt,
and a session reads that receipt at the top — past the harness’s
default-read refusal, with an offset and a limit. Archive it when the
trimmer’s trigger fires. The tool states the trigger, and this file
names no size of its own.

**Run this rather than estimating it:**

``` sh
python3 methodology_trim.py --file HANDOFFS.md --check
```

`--check` evaluates the trigger and never writes. `--write` performs the
trim, refuses unless it can prove the split lossless, and **neither
commits nor stages** — it leaves this file modified and the new shard
*untracked*, and leaves the commit to you
(`git add HANDOFFS.md docs/archive/`).

An archive is a **shard**: a new frozen file, same format, same
newest-on-top order.

- **Path: `docs/archive/HANDOFFS-through-<CUT-KEY>.md`.** Both halves
  are load-bearing — the directory keeps the shard from shadowing this
  file, and the `HANDOFFS-` prefix is what the trigger’s own glob looks
  for. A shard named otherwise is silently invisible to it.
- **This file keeps one short pointer** naming each shard, the span it
  covers and how many receipts it holds — with the command that
  recomputes those counts, never a hand-maintained number.
- **The shard back-links here and states only facts about itself.** It
  must not restate a forward-looking rule: a shard is frozen, so a rule
  copied into one cannot be corrected when the live rule moves.
- **After a split, anything that enumerates receipts must span both** —
  `HANDOFFS.md $(git ls-files 'docs/archive/HANDOFFS-*.md')` — or it
  silently counts a shrunken population. Enumerate the shards with
  `git ls-files`, never as a bare glob: zsh aborts a command whose glob
  matches nothing, so before the first split the bare form counts
  nothing at all — the same reason the ledger’s audit is written that
  way.

The reasoning this file shares with `CHANGELOG.md` — how a ledger is
read, why the tool is the only statement of its trigger, and what a
split must conserve — is in the *Reading and archiving* subsection of
[§The Action
Ledger](https://github.com/rmsharp/nprcgenekeepr/docs/methodology/FRAMEWORK_APPARATUS.html#the-action-ledger).
That subsection makes archiving optional for `CHANGELOG.md`; this file
keeps its own rule, above — archive it when the trimmer’s trigger fires.
Everything needed to *act* is here.

What is specific to *this* file, and gets receipts wrong if assumed:

- **A record is a `handoff` block *plus the prose beneath it*, not the
  fence alone.** The self-score and predecessor-score paragraphs sit
  outside the fence and belong to the receipt above them. A fence-only
  cut severs every receipt from its own scoring.
- **Archive oldest-first by position, never by sorting on `session:`.**
  Two independent `S<N>` sequences can share one ledger — a fork and its
  upstream each running their own counter — and their numbers collide.
  The record’s identity is **session + date**.
- **A trim leaves the newest-receipt check alone and moves what the
  older-receipt checks see.** Phase 0 reconcile is frontier-based and a
  structural checker applies the full schema to the newest receipt only,
  so neither is disturbed. Its other passes are not so confined — an
  answer-slot rule reads every receipt below the newest, and a
  locator-form rule reads every receipt in the file. So after a trim,
  **run the checker against each shard as well**, and recompute any “all
  N older receipts” count from the files rather than carrying it
  forward.
- **Never trim to zero receipts.** An empty receipt ledger is
  indistinguishable from a broken one.
- **A shard freezes, with one exception this file needs:** a `commit:`
  answer slot may still be reconciled inside an archived receipt,
  because that field was always going to be filled by a later session.
  Nothing else in a shard is rewritten.

**Archived 181 record(s), 2026-07-08 → 2026-08-10** into
[`docs/archive/HANDOFFS-through-2026-08-10.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-08-10.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/HANDOFFS-through-2026-08-10.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-08-10.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 39 record(s), 2026-08-10 → 2026-08-12** into
[`docs/archive/HANDOFFS-through-2026-08-12.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-08-12.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/HANDOFFS-through-2026-08-12.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-08-12.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 17 record(s), 2026-08-12 → 2026-08-13** into
[`docs/archive/HANDOFFS-through-2026-08-13.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-08-13.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/HANDOFFS-through-2026-08-13.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-08-13.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 21 record(s), 2026-08-13 → 2026-08-14** into
[`docs/archive/HANDOFFS-through-2026-08-14.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-08-14.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

This file currently holds **1** receipt(s). Computed by
`methodology_trim.py` on every `--check`/`--write` run, never
hand-maintained.

**Archived 116 record(s), 2026-08-14 → 2026-09-17** into
[`docs/archive/HANDOFFS-through-2026-09-17.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-09-17.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 13 record(s), 2026-09-17 → 2026-09-18** into
[`docs/archive/HANDOFFS-through-2026-09-18.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-09-18.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 11 record(s), 2026-09-18 → 2026-09-19** into
[`docs/archive/HANDOFFS-through-2026-09-19.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-09-19.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/HANDOFFS-through-2026-09-19.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-09-19.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.5.0.

``` handoff
session: S731
date: 2026-09-19
status: pending
active_task: Owner-directed push of the 8 unpushed docs-only S730 commits to origin/master + CI verification (4 workflows green on the pushed sha; claim rides the push, making 9 — S729/S726/S717 precedent)
what_was_done: pending
commit: pending
```

``` handoff
session: S730
date: 2026-09-19
status: complete
self_score: 9
predecessor_score: 9
active_task: CRAN check-time measurement audit DONE — docs/audits/CRAN_CHECK_TIME_AUDIT_2026-09-19.md. Full CRAN-surface check (clean-export tarball 3,485,111 B at c8397845, NOT_CRAN unset): Status OK, 1,037 s wall / 1,032 s CPU (17.3 min), of which 734 s (71%) is the ONE makePedigreeMatingLayout Rd example on the full 3,694-row examplePedigree (~147x the 5 s per-Rd threshold; the app's own diagram cap is 750, R/modPedigree.R:406). Other 201 examples: 8.9 s combined. Tests fine: 215 s under check, 0 fail; ~14% of local blocks stay home on CRAN. Measured remedy: pedWithGenotype input -> 1.0 s, check -> ~5 min, clearing the verified 10-min incoming Overall-checktime NOTE. Research only; no remedy applied; TDD N/A; lint N/A.
what_was_done: Claim c8397845; deliverable e8a0eca7 (audit + BACKLOG measure-first item removed and replaced in place by the READY/S apply-the-fix item carrying the numbers, S686 convention). Criteria verified at source: CRAN policy rev 6875 fetched; the 5 s CPU-or-elapsed per-Rd rule and _R_CHECK_DONTTEST_EXAMPLES_=as_cran (donttest STILL RUNS at incoming) read from tools/R/check.R itself; the 10-min incoming NOTE evidenced from R-pkg-devel. Measurements: R CMD check --timings under /usr/bin/time -l (CPU/wall 0.995 = single-threaded, 2-core policy pass measured); per-file testthat runs on BOTH sides of the NOT_CRAN switch (CRAN surface 187.6 s / 2,141 blocks / 200 skips; baseline 260.3 s / 2,437 / 184 — standing baseline reproduced exactly, its currency settled as rows/failed/error/skipped); control pedWithGenotype 1.0 s.
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~8 expected after close-out: 4 pre-existing + claim + deliverable + records + sha; last two estimated at write time; all docs-only). (B) Priorities: apply the CRAN check-time fix (READY, S, BACKLOG.md:117 — doc-only .Rd example change via R/makePedigreeDiagramData.R:1659-1662 + devtools::document() + the audit §7 re-measure; natural next pickup); pedigree-growth measurement (READY, S, owner-requested S721); package-split disposition + REUSE registration (owner decisions); BACKLOG.md editorial compression (READY, L); inst/doc slimming (DECISION NEEDED, M, BACKLOG.md:100). (C) Standing report-only set unchanged from S729.
key_files: docs/audits/CRAN_CHECK_TIME_AUDIT_2026-09-19.md:1 (whole report; §2 stage table, §3 findings, §7 recipe), BACKLOG.md:117 (apply-the-fix item), R/makePedigreeDiagramData.R:1659 (the roxygen example to change), R/modPedigree.R:406 (750-individual cap), CHANGELOG.md:41 (S730 entries at top)
gotchas: The apply-the-fix re-measure must use the audit §7 clean-export recipe with NOT_CRAN unset — expect ~5 min total and an EMPTY >5 s table; never measure from the working tree. pedWithGenotype through the layout emits a benign 5-collision warning — fine for timing; the remedy session may prefer a clean-laying-out examplePedigree subset for the shipped example. \donttest{} is NOT an escape at incoming (verified in check.R) — never re-derive that remedy. Never edit man/*.Rd by hand; devtools::document() regenerates. Standing set unchanged: scratchpad/ invisible to git BY OWNER DECISION; quality_ratchet.py --run ~2 min, AFTER committing (Learning 772); methodology_trim.py needs --budget-bytes 65536; renv Rscript banner expected; CLAUDE.md warn band; SESSION_NOTES.md's two ceilings differ (owner decision pending); suite baseline 2437/0/0/184/0 reproduced exactly this session, currency settled (rows/failed/error/skipped).
runtime_smoke: n/a — research/measurement only (no runtime behavior changed); the deliverable's verification is the measurements themselves, closed three ways (Ex.timings + the check's own >5 s table + a measured small-input control). quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 10bcea6e4007 · manifest aa983075d6a2 (measured 3,485,180 B at e8a0eca7)
changelog_ref: e8a0eca7
commit: fcf6790b
```

\<free-text: S730 +/- — plus: every enforcement criterion verified in
the enforcing tool’s own source or policy page (which overturned the
item’s implicit donttest remedy before it could be recommended);
headline finding closed three ways; the identical-currency double test
run settled the long-standing 2437/184 baseline-currency question; scope
held — the one-line fix was filed as a READY/S item, not applied. Minus:
single-run timings with no variance estimate (conclusion directions
robust, magnitudes ±); the ~79 s install/vignette/manual residual not
decomposed; one sloppy artifact (full-results CSV write errored on a
list column after the needed numbers printed). Predecessor 9/10: the
BACKLOG item was the execution plan verbatim and its NOT_CRAN-inversion
gotcha was this session’s method; nothing checked was wrong; only miss
was the remedy steer pointing at simulation examples when the culprit is
the layout example — exactly what measure-first exists to catch.\>

``` handoff
session: S729
date: 2026-09-19
status: complete
self_score: 9
predecessor_score: 9
active_task: Owner-directed push to origin/master + CI verification DONE — pushed 9006b567..0572767b (13 commits: 12 unpushed S726-S728 docs/config + the S729 claim riding the push), all 4 push-triggered workflows completed success ON THE PUSHED SHA 0572767b: lint 4m49s (35485603669), test-coverage 9m39s (35485603670), pkgdown 18m32s (35485603680), R-CMD-check 33m54s (35485603672). First remote validation of the S728 build-hygiene work incl. the first .quality-gates.json manifest. No TDD phases; lint N/A.
what_was_done: Claim 0572767b (rode the push so CI ran on it — S717/S726 precedent). Mid-session owner request filed, not acted on (1-and-done, S726 precedent): CRAN check-time item at BACKLOG.md:117 (c9c946f7, READY, Effort M) — measure-first on the CRAN-visible surface (R CMD check --timings per-Rd example times, incoming NOTE > 5 s; suite run WITHOUT NOT_CRAN=true so skip_on_cran exclusions match CRAN's), remedies (donttest, smaller example inputs, skip_on_cran on CI-duplicated tests, shared fixtures) deferred until measured. CI verification via background poller from the first attempt (35 polls, ~35 min), jq-filtered on headSha == 0572767b exactly.
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~3 expected after close-out: filing c9c946f7 + records + sha; last two estimated at write time; all docs-only, no urgency). (B) Priorities: CRAN check-time measurement (READY, M, owner-requested S729, BACKLOG.md:117, measure first); pedigree-growth measurement (READY, S, owner-requested S721); package-split disposition + REUSE registration (owner decisions pending); BACKLOG.md editorial compression (READY, L); inst/doc slimming (DECISION NEEDED, M, BACKLOG.md:100). (C) Standing report-only: HANDOFFS.md truncated duplicate S720 stub; iCloud Housekeeping item closable pending confirmation; owner's stale 19.7 MB ../nprcgenekeepr_2.0.0.9000.tar.gz + ../nprcgenekeepr.Rcheck/ outside the repo.
key_files: BACKLOG.md:117 (new CRAN check-time item), CHANGELOG.md:1 (S729 entries at top), HANDOFFS.md:154 (this receipt), .quality-gates.json:17 (gate manifest now on the remote via the push)
gotchas: CI is current through 0572767b — only ~3 close-out docs commits unpushed; expect 0 undocumented commits at next Phase 0, measure it. The CRAN check-time item's test measurement must run WITHOUT NOT_CRAN=true — the exact opposite of the Build/Test/Verify regression-read setting; never blend the two numbers. Standing set unchanged from S728: scratchpad/ invisible to git BY OWNER DECISION (ls -d scratchpad if in doubt); quality_ratchet.py --run takes ~2 min and measures git archive HEAD so run it AFTER committing (Learning 772); methodology_trim.py needs --budget-bytes 65536; renv Rscript banner expected; CLAUDE.md warn band; SESSION_NOTES.md's two ceilings differ (owner decision pending); suite baseline 2437/0/0/184/0 — remote-confirmed again by R-CMD-check on 0572767b.
runtime_smoke: n/a — push + docs only (no runtime behavior changed); the deliverable's verification surface is CI itself, 4/4 green on the pushed sha. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results a39b6c231e42 · manifest aa983075d6a2 (measured 3,485,202 B at c9c946f7)
changelog_ref: 0572767b
commit: 2b6ccc45
```

\<free-text: S729 +/- — plus: the claim rode the push so CI ran on the
exact claim sha; verification pinned to headSha with run ids and
durations recorded, not eyeballed; the mid-session owner request was
filed with a measure-first mandate and its own ledger entry and NOT
started; the CI wait used a background poller from the first attempt
(S726’s sleep-chain fumble not repeated). Minus: Phase 0 was an
abbreviated re-verification (status, unpushed count, frontier check)
rather than the full 8-step read — the session began minutes after
S728’s close-out with the full orientation in-context and the owner’s
task already given; recorded honestly rather than claimed as a full
Orient. The poller’s 55-poll cap was a guess that fit (35 needed) — a
longer queue would have timed it out. Predecessor 9/10: the push
decision was named with the exact recount command (measured 12,
predicted ~12), the ratchet-after-commit gotcha was applied without a
fumble, and no checked claim failed.\>

``` handoff
session: S728
date: 2026-09-19
status: complete
self_score: 9
predecessor_score: 9
active_task: Tarball build-hygiene follow-ups DONE — the owner's ^scratchpad$ .Rbuildignore line committed (19.7 MB working-tree leak closed); scratchpad/ + testthat debris (tests/testthat/_problems/, testthat-problems.rds) ignored in BOTH .Rbuildignore and .gitignore; first declared quality gate live: tarball_size_clean_export (clean-export pkgbuild::build of git archive HEAD, max 5,000,000 B), measured 3,485,027 B pass on the deliverable commit. Config/docs only; TDD N/A; lint N/A.
what_was_done: Claim f82f978a. Deliverable 2570645b — .Rbuildignore gains ^tests/testthat/_problems$ + ^tests/testthat/testthat-problems\.rds$ beside the owner's ^scratchpad$ line; .gitignore block for scratchpad/ + both debris paths (ghost-check tradeoff accepted by owner); .quality-gates.json first gate (audit sec 7 recipe, self-tagged TARBALL_BYTES marker, threshold 5,000,000 B decimal); BACKLOG completed block removed with step 4 (inst/doc slimming) extracted as its own DECISION-NEEDED item at BACKLOG.md:100. Owner decisions collected in one 3-question AskUserQuestion before the claim: commit the edit / yes git-ignore / yes gate. Verified: git check-ignore -v resolves all 3 paths; tools:::inRbuildignore TRUE on each real path (directory matches prune contents, the semantics S727's 3.56 MB working-tree build measured); gate exercised at both HEADs (claim 3,485,137 B; deliverable 3,485,027 B), both pass with ~1.5 MB headroom. Learning 772 added (gate-author mechanics).
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~12 expected after close-out: 8 pre-existing + claim + deliverable + records + sha; the last two estimated at write time; all docs/config-only; the push also puts the first gate manifest on the remote). (B) Priorities: pedigree-growth measurement (READY, S, owner-requested S721, bounded +1.07 MB total, measure compressed from a clean build); package-split disposition (owner — size no longer argues for it) + REUSE registration (owner, S); BACKLOG.md editorial compression (READY, L); extracted inst/doc slimming item (DECISION NEEDED, M, BACKLOG.md:100). (C) Standing report-only: HANDOFFS.md truncated duplicate S720 stub (two adjacent "session: S720" blocks); iCloud Housekeeping item closable pending a duplicates-stay-gone confirmation; the owner's stale 19.7 MB ../nprcgenekeepr_2.0.0.9000.tar.gz + ../nprcgenekeepr.Rcheck/ sit outside the repo (delete/rebuild is the owner's call).
key_files: .quality-gates.json:17 (the gate — name/threshold/command/why), .Rbuildignore:155 (scratchpad line; debris lines through :160), .gitignore:93 (mirror block through :103 with the tradeoff note), BACKLOG.md:100 (extracted inst/doc item), PROJECT_LEARNINGS.md:2234 (Learning 772), docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md:212 (sec 7 recipe the gate command reuses)
gotchas: scratchpad/ no longer shows as untracked BY OWNER DECISION — the Phase 0 ghost-session check must remember it still exists on disk (ls -d scratchpad if in doubt) though invisible to git and builds. quality_ratchet.py --run now takes ~2 min (full build with vignettes; 600 s per-gate timeout) — not a hang; run it AFTER committing because the gate measures git archive HEAD (Learning 772); never swap in --no-build-vignettes, which measures a ~38%-lighter artifact than the one CRAN gets. Gate threshold is decimal 5,000,000 B; thresholds only tighten — loosening is a plan-mode decision committed with --no-verify (SAFEGUARDS Blast Radius). Standing: methodology_trim.py needs --budget-bytes 65536; renv.lock has no dev tooling (Rscript banner expected); CLAUDE.md warn band ~1,640 B headroom — narrative to PROJECT_LEARNINGS.md; SESSION_NOTES.md's two ceilings differ (56,750 B token cap binds before the 65,536 B byte trigger; owner decision pending); suite baseline 2437/0/0/184/0 carries forward (no code touched).
runtime_smoke: n/a — config/docs only (no runtime behavior changed); the deliverable's own surface is the built artifact, exercised twice by the new gate itself. quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results ef8070eeb6c7 · manifest aa983075d6a2
changelog_ref: 2570645b
commit: facc4df1
```

\<free-text: S728 +/- — plus: all three embedded owner decisions
collected in one structured gate before the claim, so execution never
stalled mid-deliverable; the gate was exercised twice in-session and the
receipt cites the run at the shipped HEAD rather than the claim state;
scope held exactly to the three approved steps (no CI-workflow variant,
no inst/doc slimming). Minus: “5 MB” was interpreted as decimal
5,000,000 B (the audit’s currency) without asking — documented in the
gate’s unit field, but 5 MiB was equally plausible; the first ratchet
run measured the claim state (harmless for a docs-only claim, now a
Learning 772 caution); every future close-out pays ~2 min of gate build
wall time — approved, but the recurring cost lands on successors.
Predecessor 9/10: next-step (A) WAS this session’s deliverable with the
decision framing intact; the BACKLOG block was the execution plan
verbatim; every checked claim held (8 unpushed measured 8; 0
undocumented on both frontiers; the gate’s measurements bracket the
audit’s number).\>

``` handoff
session: S727
date: 2026-09-19
status: complete
self_score: 8
predecessor_score: 9
active_task: Tarball-size audit DONE — the owner-reported ~19 MB tarball is NOT package content; it is the untracked 20 MB scratchpad/ directory leaking into working-tree builds (never in .Rbuildignore). Clean git-archive HEAD build = 3,485,185 B (3.49 MB, 35% of CRAN's 10 MB line; CRAN 2.0.0 was 2,419,329 B). Research only; no remedy applied. The owner's UNCOMMITTED .Rbuildignore edit (+^scratchpad$) is the fix and is still uncommitted — owner decision pending.
what_was_done: Claim f8ffa40b. Close-out trim 1a5f345e (SESSION_NOTES.md 10 records S720-S724 to docs/archive/SESSION_NOTES-through-2026-09-19-2.md, L1/L2/L3 verified; owed because the handoff crossed the 25,000-token read cap). Deliverable 6d221ddc — docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md. Three real builds (working tree 3,564,041 B; clean export 3,485,185 B; clean export + scratchpad + testthat debris under the committed .Rbuildignore 19,714,510 B) plus inspection of the owner's own artifact ../nprcgenekeepr_2.0.0.9000.tar.gz (19,732,245 B, 252 scratchpad/ entries) — reproduction matches to 0.1%. Inventory: 997 entries, 12.01 MB uncompressed; inst/doc is 38% of the tarball (three html_document vignettes), tests 0.66 MB, examples 0.46 MB, R 0.39 MB compressed. Findings 0 critical / 2 moderate / 3 minor. CRAN policy verified at source (rev 6875). BACKLOG Effort-L reduce-size item removed (premise refuted) and replaced by a DECISION-NEEDED Effort-S build-hygiene follow-up; split and pedigree-growth items' cross-refs rewritten with measured numbers. Learning 771 added. Two mid-session owner messages answered, neither acted on beyond the report.
next_steps: (A) Owner decision first — commit or discard the uncommitted .Rbuildignore +^scratchpad$ line (measured fix: working tree then builds 3.56 MB and the top-level-files NOTE clears); then BACKLOG.md:100 steps (2)-(4): ignore tests/testthat/_problems + testthat-problems.rds in .Rbuildignore and .gitignore (verify with tools:::inRbuildignore + git check-ignore on real paths), optional size gate, optional inst/doc slimming via html_vignette (its own session, needs before/after build measurement). (B) Owner push decision — recount with git rev-list --count origin/master..HEAD (~8 expected after close-out: 3 pre-existing + claim + deliverable + trim + records + sha; last two estimated at write time; all docs-only). (C) Then: pedigree-growth measurement (READY, S, now bounded at +1.07 MB total — measure compressed from a clean build); package-split disposition (size no longer argues for it) + REUSE registration (owner); BACKLOG.md editorial compression (READY, L). (D) Standing report-only: HANDOFFS.md truncated duplicate S720 stub; iCloud Housekeeping item closable pending confirmation.
key_files: docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md:1 (build table sec 1, inventory sec 2, findings sec 3, reproduction commands sec 7), BACKLOG.md:100 (follow-up item), BACKLOG.md:95 and BACKLOG.md:140 (rewritten cross-refs), .Rbuildignore:155 (owner's UNCOMMITTED line), vignettes/a2interactive.Rmd:4 and vignettes/gvaConvergence.Rmd:6 and vignettes/simulatedKValues.Rmd:6 (html_document declarations behind Finding 3), PROJECT_LEARNINGS.md:2232 (Learning 771)
gotchas: The working tree is still dirty (.Rbuildignore, not session-made) — do not commit or discard without the owner's word; a checkout without that line builds 19.7 MB from the working tree. Never measure the tarball from the working tree — use the audit's sec 7 clean-export recipe, and launch pkgbuild::build() from the repo root so renv's library applies even when building an export elsewhere. The html_vignette saving is an estimate and df_print paged does not exist under html_vignette. Compressed bytes are the currency — weigh files with gzip -9, not du. SESSION_NOTES.md has TWO ceilings that differ in practice — the 25,000-token read cap binds at 56,750 B (hook refuses growth past it) while methodology_trim.py --budget-bytes 65536 still reports NOTHING_TO_DO; in that gap use an explicit --cut N (no --force needed), and run the trim on the COMMITTED pre-handoff state because the verify script anchors to the trim commit's parent; owner decision pending on aligning the two numbers. Standing — methodology_trim.py needs --budget-bytes 65536; renv.lock has no dev tooling (Rscript out-of-sync banner expected); CLAUDE.md in warn band (~1,640 B headroom); suite baseline 2437/0/0/184/0 unchanged (no code touched).
runtime_smoke: n/a — docs-only (no runtime behavior changed). The deliverable's own verification surface was the built artifacts — three pkgbuild builds + the owner's tarball, byte counts recorded in the audit. quality_ratchet: 0/0 pass · 0 fail · 0 unmeasured · results 4f53cda18c2b · manifest 4f53cda18c2b
changelog_ref: 6d221ddc
commit: 66d4116b
```

\<free-text: S727 +/- — plus: refuted the BACKLOG item’s premise by
measurement inside the first 20 minutes instead of running an Effort-L
slimming campaign against a non-problem; closed the loop three ways
(controlled reproduction, the owner’s actual artifact, the local check
log) rather than stopping at plausible arithmetic; compressed-byte
attribution overturned the item’s remedy steer with numbers; a
pre-commit fact-check caught three wrong draft claims in the report;
left the owner’s uncommitted edit untouched and answered the owner’s
mid-session question without acting on it. Minus: the task pick rested
on a terse pasted label after a dismissed picker (reasonable,
reversible, but not explicit confirmation); replacing the
owner-requested L item with an S follow-up was session judgment under
the S686 convention; the a2interactive.html component breakdown used a
sloppy regex and was reported as identified-not-weighed instead of
redone; two Phase 0 shell fumbles (GNU vs BSD stat). Predecessor 9/10:
its measure-first mandate was this session’s method and its
self-assessment honestly flagged the 19 MB as unmeasured; what nobody
S721-S726 did was connect the long-carried scratchpad check NOTE to the
artifact.\>

``` handoff
session: S726
date: 2026-09-19
status: complete
self_score: 9
predecessor_score: 9
active_task: Owner-directed push to origin/master + CI verification DONE — pushed 4565c39d..9006b567 (33 commits: 32 pre-existing S720–S725 + the S726 claim); all 4 push-triggered workflows completed success ON the pushed sha 9006b567 (R-CMD-check 31m53s, pkgdown 13m47s, test-coverage 10m4s, lint 4m37s; run ids 35481709978–35481710058). First remote validation of the S720–S725 work (warning-free suite, Suggests trim + renv re-snapshot, context-budget adoption, CLAUDE.md reduction, ~$ guards). No TDD phases (no .R files); lint N/A.
what_was_done: Claim 9006b567 (rode the push so CI ran on it — S717 precedent). Push executed and confirmed (master even with origin/master). Mid-session owner request filed as BACKLOG.md Up Next item f8970edc, NOT acted on (1-and-done, S721 precedent): tarball-size-reduction toward CRAN ≤10 MB (owner reports ~19 MB; owner steer: slimming examples/test data may beat the package split; measure-first mandate — R CMD build + tar tzvf inventory, because .Rbuildignore already excludes docs/ and vignettes/articles/ so on-disk sizes mislead; cross-refs both ways with the package-split and pedigree-growth items). CI verified via --jq filter on headSha==9006b567, not eyeballed.
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~3 expected after close-out: f8970edc + records + sha, last two estimated at write time; all docs-only, no urgency). (B) Priorities: tarball-size-reduction research (READY, L, owner-requested S726, measure first); pedigree-growth measurement (READY, S, feeds it); package-split disposition + REUSE registration (owner decisions pending); BACKLOG.md editorial compression (READY, L). (C) Standing report-only: HANDOFFS.md truncated duplicate S720 stub (grep two adjacent "session: S720" blocks); iCloud Housekeeping item closable pending duplicates-stay-gone confirmation.
key_files: BACKLOG.md:88 (new tarball item — recount after edits; split item's cross-ref line just above), CHANGELOG.md:37 (S726 entries), SESSION_NOTES.md:33 (full S726 handoff), R-CMD-check run 35481710058 (the 31m53s green run on 9006b567)
gotchas: The devtools::check() warn/exit-1 gotcha should now be CLEARED (S725 addendum 89b14d1b deleted the ~$ lock file + added standing .Rbuildignore/.gitignore guards) — next local check run confirms; scratchpad/ NOTE remains. CI current through 9006b567; expect 0 undocumented commits at next Phase 0, measure it. Standing: methodology_trim.py always --budget-bytes 65536; renv.lock has no dev tooling (Rscript banner expected); CLAUDE.md in warn band ~1,640 B headroom — new narrative goes to PROJECT_LEARNINGS.md. Full-suite baseline 2437/0/0/184/0, now remote-confirmed by R-CMD-check on 9006b567.
runtime_smoke: n/a — no code changes; the deliverable's verification surface IS the remote CI matrix, 4/4 green pinned to the pushed sha. quality_ratchet: 0/0 pass · 0 fail · 0 unmeasured · results 4f53cda18c2b · manifest 4f53cda18c2b
changelog_ref: f8970edc
commit: 211f8786
```

\<free-text: S726 +/- — plus: CI verification pinned to the exact pushed
sha via headSha filter; the mid-session filing’s measure-first mandate
caught the on-disk-vs-tarball misdirection before it could misdirect the
research session; filed item not started (no scope creep). Minus: the
~19 MB headline is owner-reported, not measured in-session (deliberate
wall-time call, but unverified until the research session builds the
artifact); one harness fumble on the first CI-wait attempt (blocked
sleep-chain, redone as background poller).\>

``` handoff
session: S725
date: 2026-09-19
status: complete
self_score: 9
predecessor_score: 9
active_task: CLAUDE.md reduction campaign DONE — 43,348 B → 26,360 B, under the 28,000 B .context-budget.json ceiling (warn band ≥24,000 B is documented headroom, not a defect). Adaptations incident narratives moved to PROJECT_LEARNINGS.md Learning 770 (the relocation record) or replaced with pointers to their existing Learnings; every adaptation's operative rule kept; SESSION PROTOCOL header, budget:protected Project Overview fence, TDD contract, and Build/Test/Verify untouched. BACKLOG item removed in the deliverable commit. Docs-only — no TDD phases (S720–S724 precedent); lint N/A (no .R files).
what_was_done: Claim 1ef168b8. Deliverable c8512d0d: CLAUDE.md reshaped (130 lines changed; the S325/S546/S547 trilogy → 1 short block, the S518 fence-scanner post-mortem → 3 lines, all 9 close-out checklists → rule + Learning pointer, hand-maintained learnings count → its computing command, two self-falsified sentences updated) + PROJECT_LEARNINGS.md Learning 770 (holds the ONLY-in-CLAUDE.md narratives: S545 rejected alternatives, S436 origin, NEWS.Rmd drift history, methodology_trim.py provenance, the legacy-history decision chain, the reduction method) + BACKLOG item removal + CHANGELOG entry. Full pre-reduction text: git show 1ef168b8:CLAUDE.md. Verified: wc -c = 26,360; context_budget.py no-file-over-ceiling with fence intact; all 18 cited Learning numbers grep-verified present; learnings count computes to exactly 770; in-file "above" references re-read and resolving; no test reads the 4 touched .md files (grep-verified), so the 2437/0/0/184/0 baseline carries forward per Learning 764's scope rule.
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~31 expected after close-out: 27 pre-existing + claim + deliverable + records + sha; the last two estimated at write time). (B) Priorities: pedigree-growth measurement (READY, S, owner-requested S721); owner decisions pending: package-split disposition, REUSE registration; BACKLOG.md editorial compression (READY, L). (C) Standing report-only: HANDOFFS.md truncated duplicate S720 stub (grep for two adjacent "session: S720" blocks); iCloud Housekeeping item closable pending a duplicates-stay-gone confirmation.
key_files: CLAUDE.md:127 (Adaptations section start — the reshaped region runs to EOF), CLAUDE.md:217 (context-budget check with the new expected state), PROJECT_LEARNINGS.md:2230 (Learning 770 — recount after any append), BACKLOG.md:131 (where the removed campaign item sat — REUSE item now there), CHANGELOG.md:37 (S725 entries), SESSION_NOTES.md:33 (full S725 handoff)
gotchas: CLAUDE.md is under ceiling but in the warn band with ~1,640 B headroom — the pre-commit hook's relative rule refuses any commit that grows it while over a threshold state; put new adaptation narrative in PROJECT_LEARNINGS.md and keep only the rule + pointer in CLAUDE.md (Learning 770 point 6 records the method). Context-budget reds are NO LONGER "by design" — a CLAUDE.md red is now a finding. Standing: every methodology_trim.py run needs --budget-bytes 65536; the stray ~$e Compounding Loop.html still makes devtools::check() warn and exit 1 non-interactively; renv.lock carries no dev tooling (Rscript out-of-sync banner expected). Full-suite baseline unchanged: 2437/0/0/184/0.
runtime_smoke: n/a — docs-only (4 markdown files; no runtime surface, no test-read files touched). The deliverable's own verification surface IS context_budget.py, run post-edit: no file over its ceiling, budget:protected fence intact. quality_ratchet: 0/0 pass · 0 fail · 0 unmeasured · results 4f53cda18c2b · manifest 4f53cda18c2b
changelog_ref: c8512d0d
commit: 6d890617
```

\<free-text: S725 +/- — plus: every relocated narrative’s destination
was verified before its pointer was written, so the pointer chain is
lossless by construction; two sentences the reduction itself falsified
were caught and updated in the same pass; the first draft’s “all green”
expected-state claim was corrected by measurement (warn at 26,360 B)
before commit. Minus: landed in the warn band rather than under 24,000 B
— the remaining large narrative (Build/Test/Verify’s regression-read
block) was on the item’s explicit keep-intact list, so deeper cutting
needs an owner decision; headroom before red is only ~1,640 B.\>

``` handoff
session: S724
date: 2026-09-19
status: complete
self_score: 9
predecessor_score: 9
active_task: Baseline-warnings cleanup DONE — suite warning count 40 → 0 (blocks=2437 failed=0 error=0 skipped=184 warning=0; block/skip counts equal the S718–S723 baseline exactly), restoring the CRAN v2.0.0 clean-warning state. Inventory re-derived per the item's mandate: 37/40 were markerKinship NA-path across 14 blocks (stale list knew 5), 3/40 were two OTHER classes in 2 other files — refuting S723's "ALL one class" gotcha. Remedy owner-picked via AskUserQuestion: suppressWarnings() on all 16 triggering call sites (Learning 273(d)). BACKLOG item removed in the deliverable commit. No TDD phases (test-hygiene, no assertion/production change); lint checklist applied (0 lints).
what_was_done: Claim 1bd5ef9c. Deliverable eb3573bc: 16 wraps — 14 setInputs(genotypeFile) in test_modMarkerGenetics.R (2 centerA at :265/:278, 1 flaggedSlot at :416, 11 i152_roh at :927-:1712), 1 flushReact() at test_appServer_server.R:206, 1 setInputs(trimPedigree=TRUE) at test_modPedigree_processing.R:672 — plus BACKLOG item removal + CHANGELOG entry carrying the full inventory/verification record. Verified: fixture-name partition proves wrap precision (warning fixtures centerA/i152_roh/flaggedSlot vs non-warning markerGenotype/hetGenotype/marker_genotypes/malformed); 3 touched files individually 0F/0E/0W; full clean regression read 2437/0/0/184/0; lint_package 0 (package loaded first, Learning 224); diff exactly the 16 wraps, assertions and production code untouched.
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~27 expected after close-out: 23 pre-existing + claim + deliverable + records + sha; the last two estimated at write time); CI R-CMD-check runs this suite and should confirm warning-free on push. (B) Priorities: CLAUDE.md reduction campaign (READY, M); pedigree-growth measurement (READY, S, owner-requested S721); owner decisions pending: package-split disposition, REUSE registration. (C) Standing report-only: HANDOFFS.md truncated duplicate S720 stub (grep for two adjacent "session: S720" blocks); iCloud Housekeeping item closable pending a duplicates-stay-gone confirmation.
key_files: tests/testthat/test_modMarkerGenetics.R:265 (first of the 14 wraps — wraps add no lines so pre-fix line numbers hold), tests/testthat/test_appServer_server.R:206, tests/testthat/test_modPedigree_processing.R:672, R/markerKinship.R:135 (the NA-path emission, untouched), CHANGELOG.md:37 (S724 entries — recount after edits), PROJECT_LEARNINGS.md:2228 (Learning 769), SESSION_NOTES.md:33 (full S724 handoff)
gotchas: The full-suite baseline is now 2437/0/0/184/0 — ANY warning>0 in a future regression read is a new finding, never baseline. Wrap incidental working-as-designed warnings at test-AUTHORING time per Learning 273(d) — the 10→15→40 growth was new tests reusing warning-prone fixtures without wraps. The 16 wrapped sites also mute future unexpected warnings from those exact calls (owner-accepted trade; assertions unchanged). Standing: context-budget reds by design until the CLAUDE.md reduction campaign; every methodology_trim.py run needs --budget-bytes 65536; the stray ~$e Compounding Loop.html still makes devtools::check() warn and exit 1 non-interactively; renv.lock carries no dev tooling (Rscript out-of-sync banner expected).
runtime_smoke: n/a — test-only change (16 suppressWarnings() wraps in 3 test files; no runtime surface, no production code, no assertion change; FM #24 has no target). quality_ratchet: 0/0 pass · 0 fail · 0 unmeasured · results 4f53cda18c2b · manifest 4f53cda18c2b
changelog_ref: eb3573bc
commit: da52bd49
```

\<free-text: S724 +/- — plus: inventory-before-remedy sequencing caught
the class heterogeneity (37+3, not 40-of-one-class) before any fix was
designed, so the owner’s remedy gate was built from measurement rather
than the item’s stale enumeration; provably precise edits (fixture-name
partition + per-file 0W re-runs + exact-baseline block/skip counts); the
warning channel is now clean, so every future warning is signal. Minus:
the BACKLOG block removal used line-number sed rather than a
context-anchored edit (boundaries re-verified immediately before,
diff-checked after — but FM \#20-adjacent); the deliverable commit sat
exactly at the 5-file blast-radius cap, compliant but without
headroom.\>

``` handoff
session: S723
date: 2026-09-19
status: complete
self_score: 9
predecessor_score: 9
active_task: Roxygen unresolved-link warning fix DONE — R/makePedigreeDiagramData.R:2414 "@param t ... in [0, 1]." escaped to \[0, 1\]; document()/RStudio-Install runs now warning-free. Trigger: the owner's RStudio-button Install (S722 follow-up A) succeeded end-to-end (S722's encoding fix verified on the live GUI surface) with this warning the only remaining noise. Also: owner's mid-session markerKinship NA-warning report triaged to the BACKLOG baseline-warnings item and the item annotated (stale block list, count 10->15->40). No TDD phases (docs-only roxygen comment); lint checklist applied.
what_was_done: Claim 3980cc31. Deliverable d2a43162: the one-line escape + CHANGELOG entry. BACKLOG annotation e2a91424: owner-reported blocks test_modMarkerGenetics.R:1649/:1712 (issue #152 sequence-export tests, i152_roh fixture pair I2/I3, source R/markerKinship.R:135) added to the baseline-warnings item with a re-derive-the-inventory instruction. Verified 4 ways: pre/post stash test (warning reproduces on unfixed HEAD, absent with fix — first post-fix check re-run WITHOUT suppressMessages(), which hides roxygen's cli-emitted warnings); zero collateral (man//NAMESPACE untouched); lint clean on the touched file (package loaded, Learning 224); full clean regression read blocks=2437 failed=0 error=0 skipped=184 warning=40, equal to the S718-S722 baseline exactly.
next_steps: (A) Owner push decision — recount with git rev-list --count origin/master..HEAD (~23 expected after close-out: 18 pre-existing + claim + fix + annotation + records + sha; estimate). (B) Warning-cleanup session (READY, S) — the annotated baseline-warnings item; owner showed active interest; re-derive the full block inventory from a fresh suite run first, then Learning 273(d) suppressWarnings() or fixture completion. (C) Priorities: CLAUDE.md reduction campaign (READY, M); pedigree-growth measurement (READY, S, owner-requested S721); owner decisions pending: package-split disposition, REUSE registration. (D) Standing report-only: HANDOFFS.md truncated duplicate S720 stub (locate by grepping for two adjacent "session: S720" blocks — line numbers drift); iCloud Housekeeping item now closable pending a duplicates-stay-gone confirmation (dups gone, repo out of iCloud at ~/Development).
key_files: R/makePedigreeDiagramData.R:2414 (the escaped line), R/markerKinship.R:135 (NA-warning source the owner asked about), BACKLOG.md:284 (baseline-warnings item S723 annotation — recount after any BACKLOG edit), CHANGELOG.md:37 (S723 entries), PROJECT_LEARNINGS.md (Learning 768), SESSION_NOTES.md:33 (full S723 handoff)
gotchas: Never verify absence-of-warning under suppressMessages() — roxygen2/cli emit warnings as messages, so a clean suppressed run is unsound (Learning 768). The suite's 40 warnings are ALL the tracked baseline item's class (suite green 0F/0E); re-derive the block inventory rather than trusting the item's enumeration, which went stale twice (10->15->40). Standing: context-budget reds by design until the CLAUDE.md reduction campaign; every methodology_trim.py run needs --budget-bytes 65536; the stray ~$e Compounding Loop.html still makes devtools::check() warn and exit 1 non-interactively; renv.lock carries no dev tooling (Rscript out-of-sync banner expected).
runtime_smoke: The deliverable's runtime surface IS the document() roclet path: pre/post stash-verified warning-free end-to-end run, man/ untouched. No Shiny surface changed, so no NPRC_RUN_E2E run owed (Learning 765). quality_ratchet: 0/0 pass · 0 fail · 0 unmeasured · results 4f53cda18c2b · manifest 4f53cda18c2b
changelog_ref: d2a43162
commit: 77a832e0
```

\<free-text: S723 +/- — plus: caught its own unsound first verification
(suppressMessages() would have hidden the very warning under test) and
re-proved with a pre/post stash test on the exact surface; zero
collateral with exact-baseline suite; the owner’s mid-session warning
report triaged to the tracked item with a verified annotation instead of
a scope-creep fix. Minus: the invalid suppressed check happened at all;
a noisy sibling-instance grep preceded the realization that roxygen’s
own output is the exhaustive unresolved-link inventory.\>

``` handoff
session: S722
date: 2026-09-19
status: complete
self_score: 9
predecessor_score: 9
active_task: RStudio-Install vignette-encoding fix DONE — %\VignetteEncoding{UTF-8} added inside the vignette: block of all 4 tracked built vignettes; the item's 5th file (a3manual.md) is the gitignored knitr::knitr intermediate and regenerates WITH the line from the .Rmd's YAML (verified at its line 14 post-run). BACKLOG Up Next item removed in the deliverable commit. No TDD phases (vignette metadata, no .R files). Remaining verification surface: the owner's own RStudio-button Install + appServer-test re-run (GUI-only, this environment cannot click it).
what_was_done: Claim f93a6ce2. Deliverable 10934a2f: one line per file after the inert %\usepackage[UTF-8]{inputenc} boilerplate in a2interactive.Rmd/a3manual.Rmd/gvaConvergence.Rmd/simulatedKValues.Rmd + CHANGELOG entry + BACKLOG item removal. Verified three ways: (1) mechanism — tools:::.getVignetteEncoding() returns 'non-ASCII' on the pre-fix HEAD copy (the exact value that trips tools::buildVignette()'s stop) and 'UTF-8' post-fix; (2) end-to-end — RStudio's exact devtools::document(roclets = c('rd','collate','namespace','vignette')) call exited 0, all 4 .Rmd vignettes rebuilt including previously-failing a2interactive.Rmd (its .html produced; its absence among leftover build products was the failure fingerprint), man/ untouched (zero collateral .Rd churn), build products cleaned per the item's recipe; (3) regression — blocks=2437 failed=0 error=0 skipped=184 warning=40, equals the S718-S721 baseline exactly. devtools::check() not re-run (not in the item's recipe; S721 ran a full check on effectively this tree; CI exercises the batch path on push).
next_steps: (A) Owner follow-up from the item: restart R, Install via the RStudio button, re-run the appServer tests; capture any remaining failure as its own finding (likely stale-installed-copy collateral, already refreshed by S721's terminal install). (B) Owner push decision — recount with git rev-list --count origin/master..HEAD (~17 expected after close-out; estimate); the fix reaches other machines only once pushed. (C) Priorities: CLAUDE.md reduction campaign (READY, M); pedigree-growth measurement (READY, S, owner-requested S721); owner decisions pending: package-split disposition, REUSE registration. (D) Report-only: HANDOFFS.md holds a pre-existing truncated duplicate S720 stub block (unclosed fence, session/date/status only) directly above the real S720 receipt — repair deliberately in a future session.
key_files: vignettes/a2interactive.Rmd:12 (the load-bearing line; siblings a3manual.Rmd:14, gvaConvergence.Rmd:13, simulatedKValues.Rmd:13), .gitignore:18 (why vignettes/ build products are git-invisible), CHANGELOG.md:33 (S722 deliverable entry, full verification record), PROJECT_LEARNINGS.md (Learning 767), SESSION_NOTES.md:33 (full S722 handoff)
gotchas: The RStudio-button click itself is still unverified — terminal-side proof is complete but the button runs in the owner's GUI; next-step (A) is the remaining surface. Every RStudio-button Install deposits gitignored build products in vignettes/ (harmless, regenerable; a3manual.md persists by design). Pre-existing roxygen warning on every document() run: R/makePedigreeDiagramData.R:2414 @param t ... in [0, 1]. parses as a link to topic "0, 1" (@noRd, warning-only) — not a regression. Standing: context-budget reds by design; every methodology_trim.py run needs --budget-bytes 65536; the stray ~$e Compounding Loop.html still makes devtools::check() warn and exit 1 non-interactively; renv.lock carries no dev tooling (the Rscript out-of-sync banner is expected).
runtime_smoke: The deliverable's runtime surface IS the vignette-roclet path: RStudio's exact document() call ran end-to-end, exit 0, a2interactive.html produced. The one surface this environment cannot exercise — the actual RStudio Install button — is stated as the owner follow-up, not claimed. No Shiny surface changed, so no NPRC_RUN_E2E run owed (Learning 765).
changelog_ref: 10934a2f
commit: 36990de9
```

\<free-text: S722 +/- — plus: mechanism-level pre/post check on the
exact reader the failing path uses (seconds, no rebuild) before the
multi-minute end-to-end run; diff is exactly 4 one-line insertions with
man/ untouched; the gitignored-5th-file wrinkle detected and resolved
(regeneration verified) instead of over-claiming. Minus: edited
a3manual.md as if durable before noticing .gitignore:18 (caught via git
diff –stat, one check lost); the live RStudio button remains
owner-verified only.\>

``` handoff
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
commit: 32c647c1
```

\<free-text: S721 +/- — plus: read-every-hit discipline flipped two
classifications before they became errors (devtools out despite many
hits, markdown kept despite zero direct hits); renv question settled by
precedent (S637 526c7fec, covr absent from lock), not guesswork;
CI-safety of the quarto drop verified (pkgdown.yaml needs: website)
before removal. Minus: the first grep pattern set was
library()/::-shaped and would have missed the markdown engine dependency
without a deliberate secondary sweep; check’s non-interactive exit-1
briefly read as a failure before the log was inspected.\>

``` handoff
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
