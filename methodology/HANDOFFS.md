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

This file currently holds **4** receipt(s). Computed by `methodology_trim.py` on every
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

**Archived 24 record(s), 2026-09-27 → 2026-09-30** into [`docs/archive/HANDOFFS-through-2026-09-30.md`](docs/archive/HANDOFFS-through-2026-09-30.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-30.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-30.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 92 record(s), 2026-09-30 → 2026-10-04** into [`docs/archive/HANDOFFS-through-2026-10-04.md`](docs/archive/HANDOFFS-through-2026-10-04.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-10-04.md.verify.sh`](docs/archive/HANDOFFS-through-2026-10-04.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 43 record(s), 2026-10-05 → 2026-10-08** into [`docs/archive/HANDOFFS-through-2026-10-08.md`](docs/archive/HANDOFFS-through-2026-10-08.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-10-08.md.verify.sh`](docs/archive/HANDOFFS-through-2026-10-08.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 40 record(s), 2026-10-08 → 2026-10-14** into [`methodology/archive/HANDOFFS-through-2026-10-14.md`](archive/HANDOFFS-through-2026-10-14.md) — same format, same order, frozen.
Losslessness is proved by [`methodology/archive/HANDOFFS-through-2026-10-14.md.verify.sh`](archive/HANDOFFS-through-2026-10-14.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.8.0.

```handoff
session: S997
date: 2026-10-15
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- CC1 of `docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md` (owner pick at the Phase 0 picker, item 1 of 4): the Pedigree Browser's twin-pairs file no longer drops every pair when a focal trim leaves one animal outside the view. The owner chose "keep the pairs that fit, no message" at the approach question and approved the scope and the help sentence at PRE-RED; every gate asked and answered, REFACTOR taken. Open items left: CB1, CB5, CA3 builds (each its own PRE-RED ruling), CC5 (the owner's call), the popover title, the 6e re-check, the guide sentence.
what_was_done: Phase 0 clean (gap 0, no pending receipt, no merges, CI 10 of 10 green, dashboard 96/100 High+ 0, ratchet manifest matched, nothing over a context ceiling). Claim 0dafa9d68 (SESSION_NOTES.md condensed in the claim). Measured first (module-level probe, then the real app on the bundled 375-animal example, focal E06FRB and 7U5NJD, trim on, 44 animals): a red error naming BRI2MW, HV7LZ3 and 677E7M, all three pairs dropped including the DZ pair wholly in view, 0 connector edges; probe: the layout builder and kinship() both stop on a pair with an animal they do not hold, so checking against the whole studbook alone is not enough. Owner rulings: "keep the pairs that fit, no message" (over "say so" and "leave it"); PRE-RED to RED, RED to GREEN, GREEN to REFACTOR all yes. RED f14753b50 (test_modPedigree_twinRelationsTrimmed.R 11 blocks, 7 fail, 22 of 38 expectations; test_docsAuditHousekeepingWording.R 1 of 10 fails, 4 of 37; 0 errors, 0 skipped). GREEN 8f1d4decb (R/modPedigree.R twinRelationsData() reads studbook(); .twinPairsWithin() for the diagram (the view) and the returned twinRelations (the analysis pedigree); comment and roxygen twinRelations item; man/modPedigreeServer.Rd). REFACTOR 7d51a14f2 (the helper lifted to R/twinPairsWithin.R). NEWS 9e66ce647 (NEWS.Rmd:89, NEWS.md re-knit, the diff is one bullet). Verified: suite 3,775 blocks, 12,708 expectations, 0 failed, 0 errors, 187 skipped; lint_package 0; devtools::check() 0/0/0; 6 of 6 mutations at GREEN, 4 of 4 on the lifted helper; the 13 related files 171 blocks, 462 expectations, 0 failed; the 15 NEWS-reading files 177 blocks, 0 failed. Close-out adds Learning 963, BACKLOG.md and the audit report updates, the notes (SESSION_NOTES.md condensed S975-S988, 57.8 KB to 52.1 KB: it had crossed its 25,000-token read ceiling), this receipt and the ledger entry.
next_steps: Candidates (re-grep BACKLOG.md lines, they shift after any edit above): the CB1, CB5 and CA3 builds of docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md, each its own strict-TDD session with a PRE-RED ruling (CB1 and CB5 look like Effort S, CA3 like M: estimates; CC5 is the owner's call); the popover "character(0)" title (BACKLOG.md:148, READY, Effort S: drop the title bar or give each popover a short title); the 6e re-check (46 candidates CE-CL, an audit, may take two sessions: an estimate); the BACKLOG.md items for the guide sentence (BACKLOG.md:155, DECISION NEEDED, S), the Changed Columns tab, the nameless header, the contributor tutorial and the kinship2 drawing features. Optional tidy, not in BACKLOG.md: the "both ids held" mask in R/applyKinshipOverridesToMatrix.R:26 and R/prepareKinshipOverrides.R:29 (they also warn) could share the idea behind .twinPairsWithin(); do not offer a push-only session.
key_files: R/modPedigree.R:530 (twinRelationsData reads studbook()), :688 (the diagram gets .twinPairsWithin(twinRelationsData(), data)), :962-963 (the returned twinRelations, narrowed to analysisPedigreeData()), :235-245 (the roxygen item); R/twinPairsWithin.R:20 (the helper); tests/testthat/test_modPedigree_twinRelationsTrimmed.R:62-236 (runTrimTwins and the 11 blocks); tests/testthat/test_docsAuditHousekeepingWording.R:123 (the comment guard); NEWS.Rmd:89; BACKLOG.md:127-130 (CC1 built); docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md:217 (Update S997); R/modInput.R:490-507 (CB1, the next build); R/modMarkerGenetics.R:1340 (CB5); PROJECT_LEARNINGS.md Learning 963.
gotchas: a scratch AppDriver stops "Reason: On CRAN" unless NOT_CRAN=true; zsh does not split an unquoted $VAR (use ${=VAR}); a connector is read from HTMLWidgets.find('#pedigree-pedigreeDiagram').network.body.data.edges.get() (a page-scale picture shows nothing of it), and network.focus(id, {scale: 2.2, animation: false}) plus get_screenshot(selector = ...) gives a crop; a before run of the RED sha needs no stash: git worktree add --detach <scratch dir> <sha> and an app.R that load_all()s it (remove with git worktree remove --force; the .claude/worktrees/* entries are not mine); test_modPedigree_twinRelationsTrimmed.R uses placeholder ids U0001/U0002 to separate the view from the analysis pedigree; expect_setequal(NULL, ...) errors, wrap with as.character(); the packaged inst/shinytest/app.R loads the INSTALLED package, so a scratch app.R with load_all() is needed; never git stash here; the studbook stays untracked (never git add -A).
runtime_smoke: the real app (shinytest2, headless Chrome, a scratch app.R outside the repo that load_all()s the tree; the RED commit from a scratch git worktree for the before side): bundled obfuscated_rhesus_mhc_ped_twins.csv and its twin file, focal E06FRB and 7U5NJD, trim on: before a red error naming BRI2MW, HV7LZ3 and 677E7M and 0 connector edges in the diagram widget, after no error and one edge, 8GSXTQ-P844CW DZ (zoomed before and after pictures opened for the owner); focal H16EC4 and 8GSXTQ, trim on: the Summary Statistics kinship export of E06FRB/HV7LZ3 0.125 before (error shown), 0.5 after (no error).
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results bdc450de8573 · manifest aa983075d6a2
```

```handoff
session: S996
date: 2026-10-15
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- the stale-groups item (`BACKLOG.md:155` in S995; owner pick at the Phase 0 picker, option 1 of 4): formed breeding groups outlive a new pedigree and a trimmed view. Measured first in the real app: the damage was on the Breeding Groups tab itself, not the other tabs (only Genetic Diversity reads the groups, `R/appServer.R:445`). The owner chose "say it, keep the groups" and approved the scope and the sentence at PRE-RED; every gate asked and answered, REFACTOR taken. One open item left: whether the guide names the sentence (`BACKLOG.md:155`, the owner writes it).
what_was_done: Phase 0 clean (gap 0, no pending receipt, no merges, CI 10 of 10 green, dashboard 96/100 High+ 0, ratchet manifest matched, nothing over a context ceiling). Claim d52869ae1 (SESSION_NOTES.md condensed in the claim). Measurement (a scratch app.R outside the repo, headless Chrome; a Genetic Value run, 1 group Top ranked, then rhesusPedigree or a YTQBW7 trim): Groups heading "Group 1 (18 animals)" over "No data available", Statistics 18 / 0 / 0, Group Detail the red "values must be length 1, but FUN(X[[1]]) result is length 0", the kinship table still the old one. Owner rulings: "Say it, keep the groups" (approach), then the scope and the sentence "Some animals in these breeding groups are not in the pedigree now loaded (a new file or a trimmed view). Form the groups again, or bring back the earlier pedigree, to see them." RED dcae37a3c (8 blocks in test_modBreedingGroups_groupsOutsidePedigree.R, 6 fail with 12 failed expectations of 35, 0 errors, 0 skipped, each reason read; the returned-groups and matching-case blocks green by design). GREEN a71e7b922 (R/modBreedingGroups.R: .breedingGroupsOutsidePedigreeNote, groupsOutsidePedigree, the groupStatsNote and groupDetailNote outputs, guards on groupsDisplay, its table observer, groupStats and bgGroupView). REFACTOR aaebccedb (R/groupMembersMissingFromPedigree.R holds the S995 helper and the new .anyGroupMemberMissingFromPedigree; both modules call it; one roxygen paragraph, man page). NEWS 1b19ae49a (NEWS.Rmd, Breeding Group Formation, Minor; the NEWS.md re-knit also brought in S995's Genetic Diversity entry, which NEWS.md had missed). Verified: new file 8 blocks 35 expectations 0 failed; suite 3,764 blocks, 12,666 expectations, 0 failed, 0 errors, 187 skipped, 6 warnings, after GREEN and again after REFACTOR; lint_package 0; devtools::check() 0/0/0 both times; mutation 5 of 5 at GREEN and 2 of 2 on the shared helper at REFACTOR (12 + 4 and 12 + 4 + 1 expectations); 13 NEWS-reading files 133 blocks 0 failed. Close-out commit adds Learning 962, the BACKLOG change, the notes, this receipt and the ledger entry.
next_steps: Candidates (re-grep BACKLOG.md lines, they shift after any edit above): the CC1, CB1, CB5 and CA3 builds of docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md, each its own strict-TDD session with a PRE-RED ruling (CC5 is the owner's call); the popover "character(0)" title (BACKLOG.md:148, READY, Effort S: drop the title bar or give each popover a short title); the 6e re-check (46 candidates CE-CL, an audit, may take two sessions: an estimate); the BACKLOG.md items for the guide sentence (BACKLOG.md:155, DECISION NEEDED, S), the Changed Columns tab, the nameless header, the contributor tutorial and the kinship2 drawing features. 230 commits ahead of origin/master; do not offer a push-only session.
key_files: R/modBreedingGroups.R:222 (the sentence), :897-905 (groupsOutsidePedigree, outsidePedigreeBox), :1061 (Groups page early return), :1083 (table observer guard), :1097-1103 (groupStatsNote and the groupStats guard), :1147-1153 (groupDetailNote and the bgGroupView guard); R/groupMembersMissingFromPedigree.R:17,32 (the two helpers); R/modGeneticDiversity.R:136-138 (calls the yes/no function); R/getGeneticDiversityStats.R:86-89 (the stop); tests/testthat/test_modBreedingGroups_groupsOutsidePedigree.R:68-269 (8 blocks; helpers gopText, gopCount, gopPages); NEWS.Rmd (Breeding Group Formation, last Minor bullet); BACKLOG.md:155; PROJECT_LEARNINGS.md Learning 962.
gotchas: in a testServer block swap the pedigree with a reactiveVal plus session$flushReact(); groupResults(...) is reachable inside the block, and a result rebuilt from the real one puts an animal in the Unused box deterministically; with the sentence showing, Export Current Group stops silently and writes no file (a module probe; a browser download was not tried) while the kinship export still writes the old group's matrix; in a scratch driver "Top ranked" needs a Genetic Value run before Form Groups or formation never ends; get_screenshot() refuses an existing file name (S995 recorded it and I hit it again: a fresh folder per run); textContent of an output that stopped on a silent req() still holds the old text, so read the picture; after any NEWS.Rmd edit re-knit NEWS.md and read git diff NEWS.md; commit a phase's edit before a mutation run and restore from saved text; SESSION_NOTES.md sits near its 25,000-token read ceiling (about 56,700 B), so the next claim must condense; the studbook stays untracked (never git add -A); never git stash here.
runtime_smoke: the real app (shinytest2, headless Chrome, a scratch app.R outside the repo that load_all()s the tree): before (the S995 tree) both cases showed old sizes, zero counts and the red error (the new-file Groups and Group Detail pictures opened for the owner); after GREEN both cases (new file, one-animal trim) show one blue box on Groups, Statistics and Group Detail with no output errors, and Genetic Diversity shows S995's sentence (the new-file Groups, Statistics and Group Detail pictures opened for the owner); the healthy case before the swap was read as text only (groups and tables as before). The state after REFACTOR was covered by the suite, not a second real-app run.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 3ff4f1507fe1 · manifest aa983075d6a2
```

```handoff
session: S995
date: 2026-10-15
status: complete
self_score: 7
predecessor_score: 9
active_task: DONE -- the Genetic Diversity page shows one error line twice (`BACKLOG.md:155` in S994; owner pick at the Phase 0 picker, option 1 of 4): the doubled line the owner reported was S993's "before" picture, the one trigger left is formed groups that outlive a new file or a trimmed view (measured in the real app both ways); the page now says one plain sentence once, the heat map area stays blank, any other calculation error shows once. The owner chose "say it once, in plain words" at the approach question and approved the sentence at PRE-RED; every gate asked and answered, REFACTOR taken. One open item filed: the groups themselves are never cleared (`BACKLOG.md:155`).
what_was_done: Phase 0 clean (gap 0, no pending receipt, no merges, CI 10 of 10 green, dashboard 96/100 High+ 0, ratchet manifest matched, nothing over a context ceiling). Claim 43f95da59 (SESSION_NOTES.md condensed in the claim). The owner answered the example question: it was the S993 before-picture. Real app (headless Chrome, a scratch app.R that load_all()s the tree): 1 group on the example pedigree, then a new pedigree (rhesusPedigree) and a one-animal trim (YTQBW7) each gave the same 20-id "ped has no rows for group member(s)" error in both slots. Approach question: "say it once, in plain words". RED 660b27ef2 (4 blocks in test_modGeneticDiversity.R, 3 fail with 5 failed expectations, reasons read, the fourth green by design). GREEN ad254b899 (R/modGeneticDiversity.R: groupsOutsidePedigree, the two outputs, .groupsOutsidePedigreeNote; man page). REFACTOR e6affd6ce (.groupMembersMissingFromPedigree in R/getGeneticDiversityStats.R serves the stop and the sentence). NEWS ff8d8dccb (NEWS.Rmd:461-467). Verified: module file 27 blocks 57 expectations 0 failed; suite 3,756 blocks, 12,630 expectations, 0 failed, 0 errors, 187 skipped, the same 6 warnings; lint_package 0; devtools::check() 0/0/0; mutation 3 of 3 at GREEN and the helper mutant caught at REFACTOR (4 and 1 expectations); NEWS guard 30 blocks 233 expectations. Close-out commit adds Learning 961, the BACKLOG item, the notes, this receipt and the ledger entry.
next_steps: The stale-groups item (BACKLOG.md:155, DECISION NEEDED, Effort M): measure what the Breeding Groups tab (Groups, Statistics, Group Detail), Genetic Value, Summary Statistics and Potential Parents show with the old groups after a new file or a trim (a scratch run like s995's, no code), then the owner rules: clear the groups when shared$currentPedigree changes, or leave. Or the rest of docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md: the CC1, CB1, CB5 and CA3 builds, each its own strict-TDD session with a PRE-RED ruling (the S995 picture shows two rows, Group 1 and Group 2, for one group asked: that is CA3); CC5 is the owner's call. Also open: the popover "character(0)" title (BACKLOG.md:148, READY, Effort S), the 6e re-check (46 candidates CE-CL), and the BACKLOG.md items for the Changed Columns tab, the nameless header, the contributor tutorial and the kinship2 drawing features (re-grep their lines). 224 commits ahead of origin/master; do not offer a push-only session.
key_files: R/modGeneticDiversity.R:48-54 (.groupsOutsidePedigreeNote), :136-169 (groupsOutsidePedigree and the two outputs); R/getGeneticDiversityStats.R:86-89 (the stop), :142-156 (.groupMembersMissingFromPedigree); tests/testthat/test_modGeneticDiversity.R:387-501 (the four S995 blocks, slotsOf() and timesIn()); NEWS.Rmd:461-467; R/modBreedingGroups.R:800 (groupResults is set here only); R/appServer.R:435 (shared$breedingGroups); BACKLOG.md:155 (the stale-groups item); PROJECT_LEARNINGS.md Learning 961.
gotchas: commit a phase's edit before a mutation run and restore from the saved text, never git checkout -- <file> (it reverted my uncommitted REFACTOR edit; git diff --stat exposed it; Learning 961); the packaged inst/shinytest/app.R loads the INSTALLED package, so a scratch app.R that load_all()s the tree is needed (the s995 scripts were in the session scratchpad and are not kept); BSD sed here needs -i '' and has no \| (use -E); a scratch driver that saves a picture under an existing name fails EEXIST; SESSION_NOTES.md is about 56,000 B, close to its 25,000-token read ceiling (about 56,700 B), so the next claim must condense; the guide's Genetic Diversity paragraph (colony-manager-guide.qmd:840-866) does not name the new sentence (BACKLOG.md:155, the owner writes it if wanted); the studbook stays untracked (never git add -A); never git stash here.
runtime_smoke: the real app (shinytest2, headless Chrome, a scratch app.R outside the repo that load_all()s the tree): before (RED tree) a new pedigree and a one-animal trim each gave the same red "ped has no rows for group member(s): ..." (20 ids) in the heat map slot and the guidance slot (picture opened for the owner for the new-file case; the trim case read from the page text, its picture failed on my script's file-exists error); after (GREEN) both cases show one blue box with the sentence and no red error (both pictures opened for the owner); the healthy case still draws the 2-row heat map (picture opened).
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results bc66afcc63e9 · manifest aa983075d6a2
```

```handoff
session: S994
date: 2026-10-15
status: complete
self_score: 7
predecessor_score: 9
active_task: DONE -- the housekeeping pass over the seven small wrong statements of the S991 audit report (`docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md`, Recommendation 3; owner pick at the Phase 0 picker, option 1 of 4; the owner approved all seven proposed sentences at the PRE-RED question; strict TDD, every gate asked and answered, REFACTOR taken)
what_was_done: Phase 0 clean (gap 0, no pending receipt, no merges, CI 10 of 10 green, dashboard 96/100 High+ 0, ratchet citation matched, nothing over a context ceiling). Claim 1c332bbf4. PRE-RED: read each of the seven sites, showed old and proposed text, the owner approved all seven as proposed. RED 00e84f614: test_docsAuditHousekeepingWording.R, 10 blocks / 34 expectations, 8 blocks fail with 24 failed expectations, 0 errors, 0 skipped, each reason read. GREEN 3914265cc (N1 clause and man page, darkblue, CD2 comment, ten popover tails) and 41ac8d189 (CC1 comment, the two alerts), two commits under the 5-file cap. REFACTOR d1ef2507b: one constant, .browserSavesText. Verified: suite 3,752 blocks / 12,622 expectations, 0 failed, 0 errors, 187 skipped, 6 warnings (as S993); lint 0 on 7 files; check 0/0/0; mutation 5 of 5 plus the constant. Real app before/after: ten popovers and both alerts show the new text; the pyramid line is gray before and after (theme !important). Found: every Summary Statistics popover header reads "character(0)". The owner reported mid-session a duplicated error line on the Genetic Diversity page: not examined beyond reading the code, filed in BACKLOG.md. BACKLOG.md docs-audit item updated, two items added; audit report S994 update; Learning 960; no NEWS entry.
next_steps: Ask the owner what the duplicated Genetic Diversity error line says and which steps showed it (BACKLOG.md:155; both outputs read diversityStats() at R/modGeneticDiversity.R:123 and :128-129). Then the owner rules on the rest of docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md: the CC1 (a), CB1 (a), CB5 (a) and CA3 (a) builds, each its own strict-TDD session with a PRE-RED ruling; CC5 is the owner's call. Also open: the popover "character(0)" title (BACKLOG.md:148, READY, Effort S), the 6e re-check (46 candidates CE-CL), BACKLOG.md items for the Changed Columns tab, the nameless header, the contributor tutorial and the kinship2 drawing features (re-grep their lines). 218 commits ahead of origin/master; do not offer a push-only session.
key_files: tests/testthat/test_docsAuditHousekeepingWording.R:1 (the gate; popoverTexts() reads the rendered addTooltip calls); R/modSummaryStats.R:11 (.browserSavesText), :404-406 (the comment); R/modGeneticDiversity.R:82-84; R/modPyramid.R:46; R/modPedigree.R:521-525; R/modDeidentifiedExport.R:291-292; R/modCrossCenterIdentity.R:379-380; BACKLOG.md:119-129 (docs-audit item), :148 and :155 (the two new items); docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md (S994 update); PROJECT_LEARNINGS.md Learning 960.
gotchas: the theme forces .help-block to gray with !important, so a helpText(style = "color: ...") shows nothing (the other helpText calls with a color at R/modInput.R:164 and near R/modPedigree.R:112,133,147 were not measured); the two alerts live on each module's Export sub-tab, so set <module>-mainTabs to "Export" before reading them in a real app; read a popover with $('#id').popover('show') then $('.popover:visible').last().text(); a GREEN of 7 R/ files is two commits (5-file cap); SESSION_NOTES.md closes near its 25,000-token read ceiling (about 56,700 B), so the next claim must condense text; the studbook stays untracked (never git add -A); never git stash here; zsh reads a leading = word as an expansion.
runtime_smoke: the real app (shinytest2, headless Chrome, a scratch app.R outside the repo that load_all()s a source tree chosen by an env var; the RED commit from git archive for the old side, this tree for the new): Summary Statistics, each of the ten export buttons popover shown and its text read (after: "...your browser saves to its download folder."; before: "...in the user selected directory."); Cross-Center Identity and De-Identified Export, Export sub-tab alert text (after: "...before you share these exports." / "...before you share these files."); Age-Sex Pyramid height help line computed color rgb(149, 165, 166) before and after. Pictures and scripts are in the session scratchpad, not the repo; the popover and pyramid before/after pictures and the De-Identified Export alert were opened for the owner.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results b3115e9b856c · manifest aa983075d6a2
```

```handoff
session: S993
date: 2026-10-15
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the Genetic Diversity tab scores a group that holds a living animal outside the Genetic Value population instead of stopping "kmat is missing kinship" (docs-audit part 2 slice 6d flag CA2, S991 Finding 1; owner pick at the Phase 0 picker, option 1 of 4; the PRE-RED scope question ruled (a), draw the heat map; `R/appServer.R:448` passes `sharedKinshipMatrix`; strict TDD, every gate asked and answered, REFACTOR taken)
what_was_done: Phase 0 clean (gap 0, no pending receipt, no merges, CI 10 of 10 green, dashboard 96/100 High+ 0, ratchet citation matched). Claim 3f0202ddd. PRE-RED: reproduced CA2 on the S991 pedigree (5 animals, 2 focal, 3 living; the stop names Q0RGP7), looked at the Value column (an animal with no report row is left out of the low-value share like Undetermined; 2 Low + 1 High stays red after adding 1, 6 or 30 such animals), asked the ruling and the gate. RED e173926b2: 7 new blocks, 4 fail (test_appServer_server.R section 7b: same shared reactive as Summary Statistics, a real-module run scores the group; test_geneticDiversityKinshipHelp.R: the approved help sentence in the roxygen block and the man page), 3 pass (two guards, the reader check). GREEN 4d94fb492: R/appServer.R:448, R/modGeneticDiversity.R:73-75, man page regenerated. REFACTOR 4c782a60a: withDiversityApp() (test_appServer_server.R:761). NEWS 62b9e5581 (NEWS.Rmd:451, NEWS.md re-knit). Checkpoint 74ddd2354 (BACKLOG.md, the S991 audit report, Learning 959). Verified: suite 3,742 blocks / 12,587 expectations, 0 failed, 0 errors, 187 skipped; lint 0 on the 4 changed R files; devtools::check() 0/0/0; mutation 2 of 2 at GREEN and REFACTOR (old argument back: 5 expectations fail; not-ready checks removed: both guards fail); the 17 NEWS-reading test files pass.
next_steps: The owner rules on the rest of docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md (Recommendations 3-6): one housekeeping session (N1 clause at R/modGeneticDiversity.R:81-84, darblue, CD2 and CC1 comments, ten popovers, CA5's two alert sentences; PRE-RED asks for the owner's sentences), then the CC1, CB1, CB5 and CA3 builds (each its own strict-TDD session; CA3 is the Unused row labelled Group 2 in the S993 after picture), CC5 is the owner's call. Other open picks: 6e re-check (46 candidates CE-CL), Changed Columns tab (BACKLOG.md:147), nameless header (BACKLOG.md:162), contributor tutorial (BACKLOG.md:175), kinship2 drawing features (BACKLOG.md:401). 211 commits ahead of origin/master; do not offer a push-only session (owner ruled S905).
key_files: R/appServer.R:438-448 (the call and its comment); R/modGeneticDiversity.R:70-75 (the kinshipMatrix help); R/getGeneticDiversityStats.R:105-106 (the Value share); tests/testthat/test_appServer_server.R:694-872 (section 7b, withDiversityApp() at :761); tests/testthat/test_geneticDiversityKinshipHelp.R:1 (the wording gate); NEWS.Rmd:451; BACKLOG.md:119-127 (the updated docs-audit text); docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md (Rulings, S993 update); docs/planning/issue122-module-contract-plan.md:472 (Dragon 1); PROJECT_LEARNINGS.md Learning 959.
gotchas: shiny::testServer() captures its block unevaluated, so a helper that forwards the block fails "object 'session' not found": wrap the whole testServer() call (withDiversityApp()); to read a real module's return inside testServer(appServer), copy the function before mocking and keep its return in ctl; reportGV() labelled every animal High Value for 14 and for 30 focal animals of the example pedigree, so a Low/High mix needs a hand-edited report; the real-app after picture has a second row, the Unused box labelled Group 2 (CA3, not fixed); SESSION_NOTES.md closes at 56,725 B, about 25 B under its 25,000-token read ceiling (56,750 B at 2.27 B/token), so the next claim must condense text or trim (S993 condensed the S947-S960 lines, the S992 paragraph and its own block to get under); the full suite shows 6 warnings outside the files touched (not examined); sharedKinshipMatrix was checked against the GV matrix on 2 shared animals with no overrides or twins (equal), not with overrides; start every R call with cd to the project root; the studbook stays untracked (never git add -A); never git stash here.
runtime_smoke: the real app (shinytest2, headless Chrome, a scratch app.R that load_all()s a source tree, run on a git archive of the RED commit and on this tree): example pedigree, Read and Check, 5 focal animals (FJS7RQ, H6T2FF, HEVL3L, I04JZV, S63QDN) with the trim on, Genetic Value run, Breeding Groups All available. Before: the Genetic Diversity tab showed "Error: kmat is missing kinship for group member(s): HLQ9SY, GCBYDW, AEP5EG, FTVE03, S222R3, TBCE78, 9P0DES, T3QPW5" twice and no picture. After: no error, a 2-row heat map. Pictures and scripts are in the session scratchpad, not the repo; both pictures were opened for the owner.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 0814a8203e48 · manifest aa983075d6a2
```

```handoff
session: S992
date: 2026-10-15
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- Download Plot on the Age-Sex Pyramid tab saves nothing until a pedigree is loaded (docs-audit part 2 slice 6d flag CD5, S991 Finding 2; owner pick at the Phase 0 picker, option 1 of 4, which took the report's recommended ruling; `R/modPyramid.R:141,146`: `req(pedigreeData())` first in the handler, `on.exit(dev.off(), add = TRUE)` after `png()`; strict TDD, the PRE-RED scope question and every gate asked and answered, REFACTOR taken)
what_was_done: Phase 0 clean (gap 0, no pending receipt, no merges, CI 10 of 10 green, dashboard 96/100 High+ 0, ratchet 1/1). Claim 54705dea5. Measured on a stand-in that a failing req() in a download handler answers HTTP 500 and a blank page, then asked the PRE-RED scope question (guard the click, recommended, or hide the button) and the three phase gates. RED 00945baf5: 4 new blocks in tests/testthat/test_modPyramid_coverage.R (nothing loaded saves no picture; a loaded pedigree still saves a PNG; empty-then-loaded in one module; a mocked drawing error leaves no device), 3 fail for the right reasons. GREEN 831383a43: R/modPyramid.R:141,146. REFACTOR f1913449c: the older blocks use pyramidDownloadInputs. NEWS 662381bcd: NEWS.Rmd:445. Checkpoint 9bb21f15b: BACKLOG.md, the audit report, Learning 958. Verified: suite 3,735 blocks / 12,572 expectations, 0 failed, 0 errors, 187 skipped; lint 0; check 0/0/0; mutation 2 of 2; real app 500 with nothing loaded (was 200, 45,680 B), 200 image/png loaded (332 animals). Learning 958; BACKLOG.md and the audit report updated.
next_steps: The owner rules on the rest of docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md (Recommendations 2-6): CA2 first (strict TDD, after a look at the Value column for an animal with no Genetic Value row), then one housekeeping session (the N1 clause, darblue, two comments, ten popovers, CA5 alerts; PRE-RED asks for the owner's sentences), CC1/CB1/CB5/CA3 builds, CC5 is the owner's call. Other open picks: 6e re-check (46 candidates CE-CL), Changed Columns tab (BACKLOG.md:144), nameless header (BACKLOG.md:159), contributor tutorial (BACKLOG.md:172), kinship2 drawing features (BACKLOG.md:398). 204 commits ahead of origin/master; do not offer a push-only session (owner ruled S905).
key_files: R/modPyramid.R:141,146 (the guard and on.exit); tests/testthat/test_modPyramid_coverage.R:29-32 (pyramidDownloadInputs), :96-117 (the pyramidDownload helper), :119-171 (the four new blocks); NEWS.Rmd:445; BACKLOG.md:119-125 (the updated docs-audit text); docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md (Findings 1-3, Rulings with the S992 update); R/getPyramidPlot.R:43-44 (NULL means qcPed); PROJECT_LEARNINGS.md Learning 958.
gotchas: 31 of the app's 45 download handlers have no req()/validate()/need() in their first 30 lines (a crude grep, not examined; most write a reactive that stops by itself); getPyramidPlot(NULL) draws qcPed and other ped = NULL callers were not searched (Learning 957); shiny::testServer() deletes a handler's output file when the block exits, so check the file inside the block; a failing req() read through output$x arrives as class shiny.silent.error and output$x re-runs the handler on every read; the on.exit mutant leaves devices open and R stops at exit with a QuartzBitmap error (the mutant's, not the suite's); Chrome's own display of the failed download was not watched; the CA2 fix still needs a look at the Value column; start every R call with cd to the project root; the studbook stays untracked (never git add -A); never git stash here.
runtime_smoke: the real app (shinytest2, headless Chrome, a scratch app.R that load_all()s this source): Age-Sex Pyramid tab, Download Plot with nothing loaded answered 500 text/html and saved no PNG; after uploading the example pedigree and Read and Check it answered 200 image/png, 54,732 B, PNG signature OK, picture headed "Total on 2026-Oct-14: 332" (Male 123, Female 209). Scratch files are in the session scratchpad, not the repo.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 022fc9e13caa · manifest aa983075d6a2
```

```handoff
session: S991
date: 2026-10-14
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the 21 slice 6d code candidates of docs-audit part 2 re-checked against today's code (docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md; owner pick at the Phase 0 picker, option 1 of 4; an audit, PRE-RED throughout, no code change; rulings proposed, none taken)
what_was_done: Phase 0 clean (gap 0, no pending receipt, no merges, CI 10 of 10 green, dashboard 96/100 High+ 0, ratchet citation matched). Claim 8ffd6f84f; the owed HANDOFFS.md trim ceea6dd3a (197,004 B to 28,966 B, methodology_trim.py v1.8.0, verify script OK); checkpoint 6dbcbbc7e (report and BACKLOG.md). Result: 5 closed (CA1 S970/S973, CA4 S928, CB2 S969, CC4 S882, CD6 S876), 16 still true (0 critical, 2 moderate, 14 minor), 1 new minor (N1, a help clause stale since S928). Moderate CA2: the Genetic Diversity tab stops for a living animal outside the focal set, run through the real modules on qcPed (GV matrix 2x2, pool 3, 1 outside). Moderate CD5: Download Plot with nothing loaded saves a pyramid of the packaged qcPed example, clicked in the real app (45,680 B, Total 46). Two slice claims did not hold (CC2 never FALSE not reproduced; CD3 lost overrides wrong in the app). Learning 957.
next_steps: The owner rules on the report's Recommendations (DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md): CD5 req() guard (Effort S), CA2 shared matrix after a look at the Value column, one housekeeping session (N1 clause, darblue, two comments, ten popovers, CA5 alerts), CC1/CB1/CB5/CA3 builds, CC5 is the owner's call, leave CB3/CB4/CC2/CC3/CD3. Each build is its own strict-TDD session with a PRE-RED gate. Other open picks: 6e re-check (46 candidates CE-CL), Changed Columns tab (BACKLOG.md:144), nameless header (BACKLOG.md:159), contributor tutorial (BACKLOG.md:172), kinship2 drawing features (BACKLOG.md:398). 197 commits ahead of origin/master; do not offer a push-only session (owner ruled S905).
key_files: docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md (Findings 1-3, the minor table); R/appServer.R:441-446 (CA2 wiring, comment :438-440 says full matrix); R/modBreedingGroups.R:548-558 (the living pool); R/modGeneticValue.R:302,552-555; R/modPyramid.R:136-153 (CD5 handler), :46 (darblue); R/getPyramidPlot.R:43-44 (NULL means qcPed); R/modGeneticDiversity.R:80-83 (N1); R/modPedigree.R:521-544 (CC1); R/modSummaryStats.R:393-395,386-391; BACKLOG.md:119-127 (the updated docs-audit text).
gotchas: The CA2 recommendation rests on a probe that did not look at what the Value column counts for an animal with no Genetic Value row; the CC1 fix (a) needs a probe of the layout builder with twin pairs outside the view; the CA3 groups list is read by other tabs; getPyramidPlot(NULL) draws qcPed and other ped = NULL callers were not searched; get_download() needs the tab open and NOT_CRAN=true; start every R call with cd to the project root (a stray cd tests/testthat turned renv off); methodology_trim.py v1.8.0 writes a methodology/ ledger's shard to methodology/archive/; the scratch probes and the downloaded PNG are in the session scratchpad, not the repo; the studbook stays untracked (never git add -A); never git stash here.
runtime_smoke: the real app (shinytest2, headless Chrome, the installed package, whose pyramid module equals the source): Download Plot with nothing loaded returned 200 image/png, 45,680 B, "Total on 2026-Oct-14: 46". CA2, CA3, CB5, CC1, CC2, CC3 run at module or function level; the rest read. No R/ change, so no suite, lint or check run.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 5d4a57326d13 · manifest aa983075d6a2
changelog_ref: S991 DONE entry
commit: the close-out commit that carries this receipt; claim 8ffd6f84f, trim ceea6dd3a, checkpoint 6dbcbbc7e
```

```handoff
session: S990
date: 2026-10-14
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- the help for kinship() chrtype and hasBothParents() id says what the code does (BACKLOG.md item removed; docs-audit part 2 flags MB3 and PD12, S986 findings 1 and 8; owner pick at the Phase 0 picker, option 1 of 4; strict TDD, every gate asked and answered, REFACTOR taken)
what_was_done: Phase 0 clean (gap 0, no pending receipt, CI 10 of 10 green). Claim 314243a86. Probed first: both owner-approved sentences against today's code; kinship2's vector kinship() equals ours (0 of 25 cells differ) but its pedigree() route gives 0 on an unknown-sex founder's diagonal; two IDs in reverse order give logical(0). RED 060f12371 (8 of 15 blocks failed); GREEN 797a2a3f2 (the two roxygen blocks, man pages regenerated); REFACTOR 7a5d715df (the test uses helper-pageText.R's readers). Suite 3,731 blocks, 12,562 expectations, 0 failed, 0 errors, 187 skipped; lint 0; check 0/0/0; mutation 7 of 7 at GREEN and REFACTOR. Learning 956.
next_steps: Each needs an owner pick: the Changed Columns tab and summary() decision (BACKLOG.md:141, DECISION NEEDED), the nameless-header decision (BACKLOG.md:156, DECISION NEEDED: leave it, fix each site, or check once at the front of qcStudbook()), the contributor tutorial (BACKLOG.md:169), the two kinship2 drawing features (BACKLOG.md:395), a docs-audit part 2 cluster (6d 21, 6e 46; 6a-6b has nothing left to rule on). 193 commits ahead of origin/master after this close-out; do not offer a push-only session (owner ruled S905).
key_files: R/kinship.R:57-61 (the chrtype sentence); R/hasBothParents.R:6-9 (the id sentence); man/kinship.Rd and man/hasBothParents.Rd (regenerated); tests/testthat/test_kinshipHasBothParentsHelp.R:32 (helpCases), :72 (the wording blocks), :91 (xKinship), :143 (hasBothParentsPed); tests/testthat/helper-pageText.R:92-129 (the shared page readers); BACKLOG.md:112-115 (the docs-audit text updated).
gotchas: test_groupAddAssignHelp.R still has its own copies of collapseSpace and the page readers (not touched, out of scope); a mutant defined as the file at HEAD is a no-op once GREEN is committed (use HEAD~1); sub(fixed = TRUE) changes one site of two (hasBothParents() has ped$id == id twice); kinship2 has two routes for an unknown-sex founder, so the help's "as in kinship2" names the vector kinship() this function ports; a ( cmd ) & inside a background Bash call returns at once, wait on the output file's done marker; the studbook stays untracked (never git add -A); never git stash here.
runtime_smoke: n/a -- help text only, no runtime behavior changed; the two changed help entries rendered with tools::Rd2txt and read as approved, devtools::check(document = FALSE, vignettes = FALSE, args = "--no-manual") gave 0/0/0.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results 2e4a798ff81b · manifest aa983075d6a2
changelog_ref: S990 DONE entry
commit: the close-out commit that carries this receipt; claim 314243a86, RED 060f12371, GREEN 797a2a3f2, REFACTOR 7a5d715df
```

```handoff
session: S989
date: 2026-10-14
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- checkRequiredCols() ignores an NA column name at any length, so a list of 5 or more names with an NA and a missing required column returns or names the missing columns instead of stopping "missing value where TRUE/FALSE needed" (BACKLOG.md item removed; docs-audit part 2 flag PB4, S986 finding 3; owner pick at the Phase 0 picker, option 1 of 4; strict TDD, every gate asked and answered, REFACTOR taken)
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, no merges, no untracked files, CI 10 of 10 green, dashboard 96/100 High+ 0, context budget WARN only for SESSION_RUNNER.md and the growth run, ratchet 1/1 and the newest citation matched the results file). Claim eec26f1d6. Probed first: 5 of 5 direct calls with an NA, 5+ names and a missing required name stopped "missing value where TRUE/FALSE needed" with reportErrors TRUE and FALSE; qcStudbook() with an NA header never reaches checkRequiredCols() because fixColumnNames() stops first (R/fixColumnNames.R:43, :46), and with that patched in memory a nameless origin header stops at R/addParents.R:47. PRE-RED scope question: the owner chose checkRequiredCols() only (the recommended option). RED 861f931b6 (4 new blocks; file 6 blocks, 39 expectations, 22 failed, 0 errors, 0 skipped; every NA case gave the same message; one block that ended at its first error was restructured so each case reports alone). GREEN b897b71a6 (ignore_na = TRUE in the first str_detect_fixed_all() call). REFACTOR d8b79d6fc (one found variable in place of two identical calls, R/checkRequiredCols.R:41-42). NEWS 9f49dc063 (NEWS.Rmd:437, NEWS.md re-knit). Verified: file 39 of 39; suite 3,721 blocks, 12,531 expectations, 0 failed, 0 errors, 187 skipped; lint_package 0; devtools::check 0/0/0 (document = FALSE, vignettes = FALSE) at REFACTOR; ratchet 1/1; mutation 4 of 4 caught at GREEN and 6 of 6 at REFACTOR; 15 NEWS-reading files pass. BACKLOG item removed, a nameless-header decision item added (BACKLOG.md:156), Learning 955.
next_steps: Each needs an owner pick: the two help sentences (BACKLOG.md:169, READY, Effort S, help text only with a wording gate), the Changed Columns tab and summary() decision (BACKLOG.md:141, DECISION NEEDED), the nameless-header decision (BACKLOG.md:156, DECISION NEEDED: leave it, fix each site, or check once at the front of qcStudbook()), the two kinship2 drawing features (BACKLOG.md:406), a docs-audit part 2 cluster (6d 21, 6e 46), the contributor tutorial (BACKLOG.md:180). 188 commits ahead of origin/master after this close-out; do not offer a push-only session (owner ruled S905).
key_files: R/checkRequiredCols.R:41-42 (found and the condition), :49-51 (the stop message); tests/testthat/test_checkRequiredCols.R:38 (answer()), :43-114 (the four new blocks); R/fixColumnNames.R:43 and :46 and R/addParents.R:47 (the sites the nameless-header item names); NEWS.Rmd:437; BACKLOG.md:156.
gotchas: the app never reaches checkRequiredCols() with an NA (a CSV blank header is read as X and qcStudbook() stops earlier on an NA name), so NEWS says the Input tab is not affected; an error inside a test_that() block ends it at the first error, so each RED case goes through answer(); a probe that patches the namespace after load_all() still calls the old attached copy from the global environment (use get("fn", ns)); the example CSV's header fields are quoted; devtools::check(document = FALSE, vignettes = FALSE, args = "--no-manual") gave 0/0/0; the studbook stays untracked (never git add -A); never git stash here.
runtime_smoke: the real Input module (shiny::testServer(modInputServer)) on inst/extdata/examples/ExamplePedigree.csv at REFACTOR: as shipped 0 errors, 1 warning, 3,694 records, ready TRUE; with the birth header blanked 1 error ("Missing required columns"), 0 records, not ready. The fix cannot change that path (a CSV blank header is read as X, never NA), so this shows only that the app is unharmed; the fix itself is shown by the test file, since the changed function is not reachable with an NA from the app.
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results dfecbde31261 · manifest aa983075d6a2
changelog_ref: S989 DONE entry
commit: the close-out commit that carries this receipt; claim eec26f1d6, RED 861f931b6, GREEN b897b71a6, REFACTOR d8b79d6fc, NEWS 9f49dc063
```

```handoff
session: S988
date: 2026-10-14
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- checkChangedColsLst() counts every kind of rename, so a lowercase geographicorigin header is flagged (BACKLOG.md item removed; docs-audit part 2 flag PB7; owner pick at the Phase 0 picker, option 1 of 4; strict TDD, every gate asked and answered, REFACTOR taken)
what_was_done: Phase 0 (0 undocumented commits, 0 pending receipts, no merges, no untracked files, CI 10 of 10 green, dashboard 96/100 High+ 0, context budget WARN only for SESSION_RUNNER.md and the growth run, ratchet 1/1). Claim 5dea6ce95. Probed first: an all-lowercase geographicorigin header gave qcStudbook(reportErrors = TRUE) NULL and runQcStudbook() hasChangedCols FALSE with all 13 change fields empty; geographicOrigin (mixed case) was already flagged through caseChange. Found by reading the callers that shouldShowChangedColsTab() repeats the 12-name list and summary() has 10 sentences; a list with only the geographicorigin field gives a blank summary() and an empty tab. One scope question, the owner took the recommended option: the check only. RED 62d37daac: 7 blocks in 3 test files plus a shared helper (pedLowercaseGeographicOrigin() on datePed()); 5 blocks failed with 8 expectations, each for the one cause; 2 guard blocks passed. GREEN 4566b1e99: R/checkChangedColsLst.R:37 is any(lengths(changedCols) > 0L). REFACTOR a1c47808f: one test constant. NEWS 0e3a6256a (NEWS.Rmd:430, NEWS.md re-knit; the defect dates from 2021 and is in v2.0.0). BACKLOG.md: the item removed, a new DECISION NEEDED item for the Changed Columns tab and summary(), the docs-audit count now two READY items; Learning 954.
next_steps: Each needs an owner pick: checkRequiredCols() tolerates an NA column name at any length (BACKLOG.md:156, READY, Effort S, strict TDD), the two help sentences with a wording gate (BACKLOG.md:164, READY, Effort S), the Changed Columns tab and summary() decision (BACKLOG.md:141, DECISION NEEDED: list every rename or leave it), the kinship2 drawing features (BACKLOG.md:401, which pedigree column means deceased), a docs-audit cluster (6d 21, 6e 46; re-check against today's code first), or the contributor tutorial (BACKLOG.md:175). Not an option: pushing (the owner ruled no push-only sessions); 182 commits are ahead of origin/master with this close-out, none seen by CI (estimate of CI risk: low, the full suite, lint and check ran, but check ran at GREEN only).
key_files: R/checkChangedColsLst.R:37 (the one expression); R/shouldShowChangedColsTab.R:36-42 (the 12-name list left alone); R/summary.nprcgenekeeprErr.R:111-165 (10 of 13 sentences); R/processQcStudbookResult.R:198-215 (warning rows only for caseChange and spaceRemoved); tests/testthat/test_checkChangedColsLst.R:33-68 (the four new blocks), test_runQcStudbook.R:237-252, test_modInput_qcStudbook.R:907-923, helper-renamedHeaderPedigree.R:13-19 (lowercaseGeographicOriginRename, pedLowercaseGeographicOrigin()); tests/testthat/test_appServer_dynamicTabs.R:189-209 (the agree-with-checkChangedColsLst block, a 12-field list); NEWS.Rmd:430-435; BACKLOG.md:141-154; PROJECT_LEARNINGS.md Learning 954
gotchas: with an all-lowercase geographicorigin header hasChangedCols is TRUE but the Changed Columns tab stays hidden and the Input tab's Warnings list has no row (NEWS.Rmd says so); only an all-lowercase geographicorigin, recordstatus or fromcenter header reaches those fields alone, since any capital also triggers caseChange; runQcStudbook() returns list(cleaned, qcResult, errorLst), so the flag is res$qcResult$hasChangedCols and res$hasChangedCols is NULL; export a variable before Rscript, a trailing VAR=x is an argument; devtools::check needs vignettes = FALSE to give 0/0/0; 15 test files read NEWS.Rmd and NEWS.md, so do not edit them during a suite run; SESSION_NOTES.md is 55,847 B (the Read tool's 25,000-token cap is about 56,000 B and the commit hook refuses growth past about 56,700 B, so the next claim must condense S988); the studbook stays untracked in inst/extdata/examples/ (never git add -A); never git stash here
runtime_smoke: the real Input module (shiny::testServer(modInputServer)) on inst/extdata/examples/ExamplePedigree.csv at GREEN: as shipped hasChangedCols FALSE, 0 errors, 3,694 records, ready; the same file with a lowercase geographicorigin header TRUE, 0 errors, 3,694 records, ready. Before: this session's probe on a six-animal pedigree (qcStudbook NULL, flag FALSE).
quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured · results e315c8b09228 · manifest aa983075d6a2
changelog_ref: S988 DONE entry
commit: the close-out commit that carries this receipt; claim 5dea6ce95, RED 62d37daac, GREEN 4566b1e99, REFACTOR a1c47808f, NEWS 0e3a6256a
```

