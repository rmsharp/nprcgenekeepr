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

**The rules** — how to add an entry, source tags, reading and archiving — are in
[§The Action Ledger](docs/methodology/FRAMEWORK_APPARATUS.md#the-action-ledger), which `bin/sync`
keeps current. ledger-format: 2 — keep this marker; `bin/status` reads it.

## 2026-08

## 2026-09

**Archived 328 record(s), 2026-08-14 → 2026-09-17** into [`docs/archive/CHANGELOG-through-2026-09-17.md`](docs/archive/CHANGELOG-through-2026-09-17.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-09-17.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-17.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 40 record(s), 2026-09-17 → 2026-09-18** into [`docs/archive/CHANGELOG-through-2026-09-18.md`](docs/archive/CHANGELOG-through-2026-09-18.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-09-18.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-18.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 35 record(s), 2026-09-18 → 2026-09-19** into [`docs/archive/CHANGELOG-through-2026-09-19.md`](docs/archive/CHANGELOG-through-2026-09-19.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-09-19.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-19.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 31 record(s), 2026-09-19 → 2026-09-19** into [`docs/archive/CHANGELOG-through-2026-09-19-2.md`](docs/archive/CHANGELOG-through-2026-09-19-2.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-09-19-2.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-19-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

### 2026-09-20 · [ad hoc] S734 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `be4f41ce`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S734 commit. S734 total: 3 commits (claim `75d2b049` — rode the push, records
  `be4f41ce`, this one). Ahead of `origin/master` by 2 after close-out, both docs-only;
  CI is current through `75d2b049`, so no urgency — push is the owner's call. Expect 0
  undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-20 · [ad hoc] S734 close-out: session records (handoff, S733 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S733 evaluation: 9/10 — every checked claim held;
  only gap was two context-budget signals not itemized: growth run 12/10 and
  `SESSION_RUNNER.md`/`SAFEGUARDS.md` "differs from canonical," this session verified
  NOT local edits — both last touched by the S719 forced sync `b773ddb6`, tree clean;
  report-only). `HANDOFFS.md` receipt complete. No new `PROJECT_LEARNINGS.md` entry
  (routine clean push, 6th of its kind: S717/S726/S729/S731/S733). quality_ratchet at
  the pushed HEAD `75d2b049`: 1/1 pass · 0 fail · 0 unmeasured · results 84231b1581ab ·
  manifest aa983075d6a2 (3,483,934 B ≤ 5,000,000 B). ~2 unpushed after close-out
  (estimate); push is the owner's call.

### 2026-09-20 · [ad hoc] S734 deliverable: push `5ed0da83..75d2b049` + CI 4/4 green on the pushed sha — post-fix R-CMD-check duration confirmed a second time
- Pushed 4 commits (the 3 unpushed S733 close-out commits — trim `484c46de`, records
  `6fb68007`, sha `c09d7b5a` — + the S734 claim `75d2b049` riding the push,
  S726/S729/S731/S733 precedent). All 4 push-triggered workflows `completed success`
  ON THE PUSHED SHA `75d2b049` (`gh run list --commit`, sha match structural): lint
  5m11s (id 35536061548), pkgdown 6m03s (35536061442), test-coverage 10m35s
  (35536061510), R-CMD-check 22m17s (35536061496) — the ~21–22 min post-S732-fix
  figure confirmed twice now; single 30-min Monitor arm, no re-arm. Durations are
  createdAt→updatedAt (include queue; seconds ±).

### 2026-09-20 · [ad hoc] S734 claim: owner-directed push to `origin/master` (stub + pending receipt + in-progress ledger entry) *(in progress)*
- Owner picked the push at Phase 0 (AskUserQuestion). 3 unpushed docs-only S733
  close-out commits at claim time; the claim rides the push (S726/S729/S731/S733
  precedent) so CI runs on it. Phase 3F records the outcome.

### 2026-09-20 · [ad hoc] S733 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `6fb68007`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S733 commit. S733 total: 4 commits (claim `5ed0da83` — rode the push, trim
  `484c46de`, records `6fb68007`, this one). Ahead of `origin/master` by 3 after
  close-out, all docs-only; CI is current through `5ed0da83`, so no urgency — push is
  the owner's call. Expect 0 undocumented commits past the frontier at next Phase 0;
  measure it.

### 2026-09-20 · [ad hoc] S733 close-out: session records (handoff, S732 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S732 evaluation: 9/10 — only miss was the ~6
  unpushed estimate undercounting its own trim commit; measured 7); `HANDOFFS.md` receipt
  complete. No new `PROJECT_LEARNINGS.md` entry (routine clean push, 5th of its kind:
  S717/S726/S729/S731); the `methodology_trim.py --cut N` = keep-newest-N semantics note
  and the CHANGED CI-wait mechanics (R-CMD-check now ~21–22 min post-fix, fits one
  30-min Monitor arm) live in the handoff gotchas. quality_ratchet at the pushed HEAD
  `5ed0da83`: 1/1 pass · 0 fail · 0 unmeasured · results 7ced9faa4709 · manifest
  aa983075d6a2 (3,483,941 B ≤ 5,000,000 B). ~3 unpushed after close-out (estimate);
  push is the owner's call.

### 2026-09-20 · [ad hoc] S733 deliverable: push `3b688ae2..5ed0da83` + CI 4/4 green on the pushed sha — first remote validation of the S732 CRAN check-time fix
- Pushed 8 commits (the 7 unpushed S732 commits incl. fix `ba088d0d` touching
  `.R`/`.Rd`, + the S733 claim riding the push — S726/S729/S731 precedent). All 4
  push-triggered workflows `completed success` ON THE PUSHED SHA `5ed0da83`
  (`gh run list --commit`, sha match structural): lint 3m56s (id 35534412900), pkgdown
  6m13s (35534413059), test-coverage 10m33s (35534412911), **R-CMD-check 21m28s
  (35534412936) — down from 33m37s on the previous push `3b688ae2`: the S732 example
  shrink confirmed remote-side, −12 min of CI per push.** The expected 30-min-cap
  monitor re-arm never fired because the check now fits one arm. Durations are
  createdAt→updatedAt (include queue; seconds ±).

### 2026-09-20 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-09-19-3.md` (14 record(s), 56,599 B → 10,583 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **14** record(s) (2026-09-19 → 2026-09-19) out of [`SESSION_NOTES.md`](SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-09-19-3.md`](docs/archive/SESSION_NOTES-through-2026-09-19-3.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-09-19-3.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-19-3.md.verify.sh)
rather than trusting a digest printed here. Live file 56,599 B → 10,583 B (−81.3%).

### 2026-09-20 · [ad hoc] S733 claim: owner-directed push to `origin/master` + CI verification *(in progress)*
- Session claimed after full Phase 0 (reconcile clean: 0 undocumented on both frontiers at
  `ee7cb230`; S732 receipt complete, ratchet citation matches `.quality-gates-results.json`;
  CI 4/4 green on `3b688ae2` + scheduled shinytest2 green; dashboard 96/100; context budget
  WARN = `CLAUDE.md` warn band only; 7 unpushed measured vs S732's ~6 estimate — the delta
  is the S732 HANDOFFS trim commit). Owner picked the push via the Phase 0 picker. Claim
  rides the push so CI runs on it (S726/S729/S731 precedent). Phase 3F records the rest.

### 2026-09-20 · [ad hoc] S732 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `e6439a20`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S732 commit. S732 total: 5 commits (claim `e7fe4713`, fix `ba088d0d`, records
  `e6439a20`, trim `e33a7b41`, this one). Ahead of `origin/master` by 6 after close-out —
  the fix commit touches `.R`/`.Rd`, so the next push gets it remote R-CMD-check
  validation; push is the owner's call. Expect 0 undocumented commits past the frontier
  at next Phase 0; measure it.

### 2026-09-20 · [ad hoc] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-09-19-2.md` (9 record(s), 69,215 B → 28,548 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **9** record(s) (2026-09-19 → 2026-09-19) out of [`HANDOFFS.md`](HANDOFFS.md) into
[`docs/archive/HANDOFFS-through-2026-09-19-2.md`](docs/archive/HANDOFFS-through-2026-09-19-2.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/HANDOFFS-through-2026-09-19-2.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-19-2.md.verify.sh)
rather than trusting a digest printed here. Live file 69,215 B → 28,548 B (−58.8%).

### 2026-09-20 · [ad hoc] S732 close-out: fix verified (§7 re-measure — Status OK, >5 s table EMPTY, check CPU 1,032 → 291.6 s); session records
- **Verification at the fix commit `ba088d0d`** (audit §7 clean-export recipe, `NOT_CRAN`
  unset): **Status OK, zero NOTEs, the >5 s examples table is EMPTY** (worst remaining Rd:
  `groupAddAssign` 1.98 s elapsed); examples 743.0 → 9.8 s elapsed over 202 Rd files;
  whole check 1,032 → 291.6 s CPU (4.9 min, −72%), matching the audit's ~5 min
  prediction. Wall 518.8 s (8.6 min) is contention-inflated (load avg 50+, external VM +
  5 Chromium processes; CPU/wall 0.56 vs S730's 0.995) — an upper bound; the CRAN-surface
  test suite ran 0-fail inside the check. T1–T4 cleared. The Finding-4 `skip_on_cran()`
  lever deliberately NOT taken (audit holds it if CRAN's farm ever crowds 10 min).
  Gotcha for §7 reuse: capture `R_LIBS` with `... | tail -1` — renv's out-of-sync banner
  can land on stdout and a polluted `R_LIBS` kills the check in 4 s ("quadprog not
  available"; cost one failed run this session). **Completed BACKLOG item removed**
  (`BACKLOG.md:117`, S686 convention) in this commit. `SESSION_NOTES.md` handoff written
  (S731 evaluation: 9/10; self: 9/10); `HANDOFFS.md` receipt complete. No new
  `PROJECT_LEARNINGS.md` entry (routine Effort-S fix). quality_ratchet at close-out:
  cited in the receipt. ~6 unpushed after close-out (estimate); push is the owner's call.

### 2026-09-20 · [ad hoc] S732 deliverable: CRAN check-time fix — `makePedigreeMatingLayout` example input `examplePedigree` → `smallPed`
- `R/makePedigreeDiagramData.R:1659-1662` roxygen `@examples` + regenerated
  `man/makePedigreeMatingLayout.Rd` (`devtools::document()`, never hand-edited). Input
  choice measured in-session across all shipped pedigrees with the required columns:
  `smallPed` (17 rows) 0.03 s, ZERO warnings/messages — beats the item's named candidate
  `pedWithGenotype` (0.93 s, 5-collision warning), `qcPed` (0.91 s, same warning), and
  `rhesusPedigree` (2.91 s, 72-collision warning); `smallPed` is also the established
  fixture idiom in 13 other roxygen examples. Lint: 0 on the touched file (package
  loaded). Verification = the audit §7 clean-export re-measure, run AFTER this commit
  (the recipe builds from `git archive HEAD`); results in the close-out entry. BACKLOG
  item removal follows the re-measure passing, not this commit.

### 2026-09-20 · [ad hoc] S732 claim: apply the CRAN check-time fix (in progress)
- Session claimed after full Phase 0 (reconcile clean: 0 undocumented on both frontiers at
  `400e226e`; CI 4/4 green on `3b688ae2`; dashboard 96/100; context budget warn-band only;
  2 unpushed docs-only as S731 predicted). Owner picked the `BACKLOG.md:117` READY/S item
  via the Phase 0 picker: shrink the `makePedigreeMatingLayout` roxygen example input
  (`R/makePedigreeDiagramData.R:1659-1662`) + `devtools::document()` + audit §7
  clean-export re-measure. TDD N/A (doc-only `.Rd` example change; the re-measure is the
  verification gate per the item). Close-out records the rest.
- Final S731 commit. S731 total: 3 commits (claim `3b688ae2` — rode the push, records
  `f5656164`, this one) + the push itself (a non-commit action, its own entry below). Ahead
  of `origin/master` by 2 after close-out — both docs-only, push is the owner's call. Expect
  0 undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-20 · [ad hoc] S731 close-out: session records (handoff, S730 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (evaluation of S730: 9/10; self-assessment: 9/10);
  `HANDOFFS.md` receipt overwritten to `status: complete` with the six requirements filled.
  quality_ratchet at the pushed HEAD `3b688ae2`: 1/1 pass · 0 fail · 0 unmeasured ·
  results 24c0d9475ec1 · manifest aa983075d6a2 (tarball 3,483,933 B ≤ 5,000,000 B). No new
  `PROJECT_LEARNINGS.md` entry (routine push session, S729 precedent). No BACKLOG item
  consumed. Next natural pickup: the READY/S apply-the-CRAN-check-time-fix item
  (`BACKLOG.md:117`). ~2 unpushed after close-out (estimate at write time); push is the
  owner's call.

### 2026-09-20 · [ad hoc] S731 deliverable: push to origin/master + CI verification — 4/4 workflows green on the pushed sha
- **Pushed `0572767b..3b688ae2`** (9 commits: the 8 unpushed S730 docs-only commits + the
  S731 claim riding the push — S729/S726/S717 precedent). All 4 push-triggered workflows
  `completed success` ON THE PUSHED SHA `3b688ae2` (verified via
  `gh run list --commit <sha>`): lint 4m26s (id 35490394639), test-coverage 8m41s
  (35490394613), pkgdown 18m05s (35490394612), R-CMD-check 33m37s (35490394609). Puts the
  S730 CRAN check-time audit and full S730 close-out record set on the remote. The push is
  a non-commit action; this entry is its ledger record.

### 2026-09-19 · [ad hoc] S731 claim: owner-directed push to origin/master (stub + pending receipt + in-progress ledger entry)
- Session claimed. Deliverable (in progress): push the 8 unpushed docs-only S730 commits to
  `origin/master` (this claim commit rides the push, making 9 — S729/S726/S717 precedent, so
  CI runs on the pushed sha) and verify all 4 push-triggered workflows `completed success` on
  that sha. Phase 3F records the rest. Until close-out, this entry is the crash breadcrumb.

### 2026-09-19 · [ad hoc] S730 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `fcf6790b`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S730 commit. S730 total: 4 commits (claim `c8397845`, deliverable `e8a0eca7`, records
  `fcf6790b`, this one). Ahead of `origin/master` by 8 after close-out — all docs-only, push
  is the owner's call. Expect 0 undocumented commits past the frontier at next Phase 0;
  measure it.

### 2026-09-19 · [ad hoc] S730 close-out: session records (handoff, S729 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (evaluation of S729: 9/10; self-assessment: 9/10);
  `HANDOFFS.md` receipt overwritten to `status: complete` with the six requirements filled.
  quality_ratchet at the deliverable HEAD `e8a0eca7`: 1/1 pass · 0 fail · 0 unmeasured ·
  results 10bcea6e4007 · manifest aa983075d6a2 (tarball 3,485,180 B ≤ 5,000,000 B). No new
  `PROJECT_LEARNINGS.md` entry (routine measurement session; forward-carrying homes are the
  audit + the rewritten `BACKLOG.md:117` item). Next natural pickup: the READY/S
  apply-the-fix item. ~8 unpushed after close-out (estimate at write time); push is the
  owner's call.

### 2026-09-19 · [ad hoc] S730 deliverable: CRAN check-time audit — one example is 71% of the whole check
- **`docs/audits/CRAN_CHECK_TIME_AUDIT_2026-09-19.md`.** Full `R CMD check --timings` of the
  clean-export tarball (3,485,111 B at `c8397845`), CRAN surface (no `NOT_CRAN`): **Status OK,
  1,037 s wall / 1,032 s CPU (17.3 min)** on M2 Max / R 4.6.1 — of which **734.1 s is the single
  `makePedigreeMatingLayout` Rd example** (full 3,694-row `examplePedigree`; ~147× the 5 s
  per-Rd threshold; the app's own diagram cap is 750, `R/modPedigree.R:406`). Other 201 timed
  examples: 8.9 s combined. Tests: 215 s under check, 0 fail; identical-currency comparison
  measured ~14% of local test blocks staying home on CRAN (2,437/184 baseline reproduced
  exactly vs 2,141/200 CRAN-surface). Verified at source: CRAN policy rev 6875; the 5 s
  threshold and `\donttest`-still-runs-at-incoming in `tools/R/check.R`; the 10-min incoming
  "Overall checktime" NOTE (R-pkg-devel). Measured remedy: `pedWithGenotype` input → 1.0 s
  (~17.3 min → ~5 min total). Research only — no remedy applied, no `.R`/`man/` change; TDD
  N/A; lint N/A. BACKLOG: measure-first item removed (complete), replaced by the READY/S
  apply-the-fix item carrying the numbers (S686 convention).

### 2026-09-19 · [ad hoc] S730 claim: CRAN check-time measurement audit (in progress)
- Session claimed for the `BACKLOG.md:117` item (owner-requested mid-S729). Measurement/research
  only: `R CMD check --timings` per-Rd example times + a suite run WITHOUT `NOT_CRAN=true` so
  `skip_on_cran()` exclusions match CRAN's; remedies weighed in the audit report, none applied.
  Stub + pending `HANDOFFS.md` receipt ride this commit; close-out records the rest.

### 2026-09-19 · [ad hoc] S729 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `2b6ccc45`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S729 commit. S729 total: 5 commits (claim `0572767b`, pushed and CI-validated; filing
  `c9c946f7`; records `2b6ccc45`; trim `10016a8e`; this one). Ahead of `origin/master` by 4
  after close-out (the trim made it 4, not the ~3 the handoff estimated) — all docs-only,
  push is the owner's call. Expect 0 undocumented commits past the frontier at next Phase 0;
  measure it.

### 2026-09-19 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-09-19-2.md` (31 record(s), 66,352 B → 33,624 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **31** record(s) (2026-09-19 → 2026-09-19) out of [`CHANGELOG.md`](CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-09-19-2.md`](docs/archive/CHANGELOG-through-2026-09-19-2.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-09-19-2.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-19-2.md.verify.sh)
rather than trusting a digest printed here. Live file 66,352 B → 33,624 B (−49.3%).

### 2026-09-19 · [ad hoc] S729 close-out: push DONE (13 commits, 4/4 CI green on `0572767b` — first remote validation of S728 incl. the first quality-gate manifest) + session records
- **Deliverable:** pushed `9006b567..0572767b`; all 4 push-triggered workflows `completed
  success` on the pushed sha exactly (jq `headSha` filter): lint 4m49s (35485603669),
  test-coverage 9m39s (35485603670), pkgdown 18m32s (35485603680), R-CMD-check 33m54s
  (35485603672). Background poller from the first attempt (35 polls, ~35 min).
- **Records:** `SESSION_NOTES.md` S729 handoff + S728 evaluation (9/10 — the push decision
  named with the exact recount command, measured 12 vs predicted ~12; the ratchet-after-commit
  gotcha applied cleanly); `HANDOFFS.md` receipt complete (self 9/10 — abbreviated Phase 0
  re-verification recorded honestly as the main minus); no new learning (routine clean push,
  S726 precedent).
- **Receipt citation** (run at `c9c946f7`): quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured
  · results `a39b6c231e42` · manifest `aa983075d6a2` (gate measured 3,485,202 B).
- **Post-append measurements** (`--budget-bytes 65536`): SESSION_NOTES 36,997 B and HANDOFFS
  56,465 B — no trigger; CHANGELOG was 64,861 B BEFORE this entry (~675 B from its trigger),
  so the trigger state is re-checked after this append and any owed trim lands as its own
  commit (S727 precedent). context_budget: no file over ceiling (`CLAUDE.md` warn band,
  documented headroom).

### 2026-09-19 · [ad hoc] S729 mid-session owner request filed (not acted on — 1-and-done, S726 precedent): BACKLOG item to see if example/test code can run shorter for CRAN submission needs
- New Up Next item (READY, Effort M): measure-first mandate on the CRAN-visible surface —
  `R CMD check --timings` for per-Rd example times (incoming checks NOTE > 5 s), and a suite
  run WITHOUT `NOT_CRAN=true` so `skip_on_cran()` exclusions match CRAN's, with per-file wall
  times; remedy candidates (`\donttest{}`, smaller example inputs, `skip_on_cran()` on tests
  that duplicate CI coverage, shared fixtures) explicitly deferred to after measurement.
  Filed while the S729 push's CI verification poller runs.

### 2026-09-19 · [ad hoc] S729 claim: owner-directed push to origin/master + CI verification (stub + pending receipt + this in-progress entry)
- Deliverable (in progress): push the 12 unpushed S726–S728 docs/config commits + this claim
  (13 total; the claim rides the push so CI runs on it — S717/S726 precedent), then verify all
  4 push-triggered workflows green on the pushed sha exactly. First remote validation of the
  S728 build-hygiene work (ignore entries + the first `.quality-gates.json` manifest).

### 2026-09-19 · [ad hoc] S728 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `facc4df1`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S728 commit. S728 total: 4 commits (claim `f82f978a`; deliverable `2570645b`; records
  `facc4df1`; this one). Ahead of `origin/master` by 12 after close-out (8 pre-existing + these
  4) — all docs/config-only, push is the owner's call; the push also puts the first quality-gate
  manifest on the remote. Expect 0 undocumented commits past the frontier at next Phase 0;
  measure it.

### 2026-09-19 · [ad hoc] S728 close-out: tarball build-hygiene DONE + session records (handoff, S727 evaluation 9/10, receipt, Learning 772)
- **Records:** `SESSION_NOTES.md` S728 handoff + S727 evaluation (9/10 — its next-step (A) WAS
  this session's deliverable, the `BACKLOG.md:100` block was the execution plan verbatim, and
  every checked claim held); `HANDOFFS.md` receipt complete (self 9/10);
  `PROJECT_LEARNINGS.md` Learning 772 (gate-author mechanics: a gate measuring
  `git archive HEAD` measures the last commit, so run `--run` AFTER committing; the 600 s
  per-gate timeout fits a build gate; a self-tagged extract marker survives chatty tooling).
- **Receipt citation** (run at the deliverable HEAD `2570645b`): quality_ratchet: 1/1 pass ·
  0 fail · 0 unmeasured · results `ef8070eeb6c7` · manifest `aa983075d6a2` — the new gate's
  first citation-of-record, measured 3,485,027 B against the 5,000,000 B threshold.
- **Post-append measurements** (`--budget-bytes 65536`): no trigger fires — SESSION_NOTES
  31,480 B, HANDOFFS 52,085 B, CHANGELOG 61,770 B pre-entry (CHANGELOG is ~3.7 KB from its
  trigger — expect it to fire within a session or two). context_budget: no file over ceiling
  (`CLAUDE.md` warn band, documented headroom).

### 2026-09-19 · [ad hoc] S728 deliverable: tarball build-hygiene follow-ups DONE — leak closed in both ignore files, testthat debris ignored, 5 MB clean-export size gate live (first declared quality gate)
- **`.Rbuildignore`:** the owner's pending `^scratchpad$` line committed (owner-directed via
  picker; the measured fix for the 19.7 MB working-tree leak, S727 audit Finding 1), plus
  `^tests/testthat/_problems$` and `^tests/testthat/testthat-problems\.rds$` (Finding 2).
- **`.gitignore`:** `scratchpad/` (owner accepted the documented ghost-check tradeoff) plus the
  two testthat-debris paths.
- **`.quality-gates.json`:** first gate declared — `tarball_size_clean_export`, max 5,000,000 B
  measured on a `git archive HEAD` clean-export `pkgbuild::build()` (audit §7 recipe, Finding 5
  remedy). Exercised in-session at `f82f978a`: **1/1 pass, measured 3,485,137 B** (results
  `16f2d705768f` · manifest `aa983075d6a2`).
- **Verification:** `git check-ignore -v` resolves all three paths to the new `.gitignore`
  lines; `tools:::inRbuildignore` TRUE on each real path (`scratchpad`,
  `tests/testthat/_problems`, `tests/testthat/testthat-problems.rds` — directory matches prune
  contents, the semantics S727's 3.56 MB working-tree build measured); `git status` untracked
  noise now only the 5 known planning/article files. No `.R` files touched — TDD N/A, lint N/A,
  suite baseline 2437/0/0/184/0 carries forward (Learning 764 scope rule).
- **BACKLOG:** completed item's block removed in this commit (S686 convention); its still-open
  step 4 (optional `inst/doc` slimming via `html_vignette`, Effort M) extracted as its own
  DECISION-NEEDED item in place.

### 2026-09-19 · [ad hoc] S728 claim: tarball build-hygiene follow-ups (stub + pending receipt + this in-progress entry)
- Deliverable (in progress): `BACKLOG.md:100` steps 1–3 — commit the owner's `.Rbuildignore`
  `+^scratchpad$` line (owner-directed via Phase 0/1 picker), git-ignore `scratchpad/`
  (owner: yes, accepting the documented ghost-check tradeoff), add the testthat-debris paths
  (`tests/testthat/_problems/`, `testthat-problems.rds`) to `.Rbuildignore`/`.gitignore`,
  and declare a clean-export tarball-size gate (≤5 MB) in `.quality-gates.json` (owner: yes).
  Step 4 (inst/doc slimming) stays deferred — its own session per the item.

### 2026-09-19 · [ad hoc] S727 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `66d4116b`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S727 commit. S727 total: 5 commits (claim `f8ffa40b`; deliverable `6d221ddc`; trim
  `1a5f345e`; records `66d4116b`; this one). Ahead of `origin/master` by 8 after close-out
  (3 pre-existing S726 + these 5) — all docs-only, push is the owner's call. The owner's
  `.Rbuildignore` `+^scratchpad$` edit remains uncommitted by design. Expect 0 undocumented
  commits past the frontier at next Phase 0; measure it.

### 2026-09-19 · [ad hoc] S727 close-out: tarball-size audit DONE + session records (handoff, S726 evaluation 9/10, receipt, Learning 771)
- **Records:** `SESSION_NOTES.md` S727 handoff + S726 evaluation (9/10 — its measure-first
  mandate was this session's method and its self-assessment honestly flagged the ~19 MB as
  unmeasured; nobody S721–S726 connected the long-carried `scratchpad` check NOTE to the
  artifact); `HANDOFFS.md` receipt complete (self 8/10); `PROJECT_LEARNINGS.md` Learning 771
  (a top-level-directory check NOTE means the directory ships; three artifacts share one
  name; compressed bytes are the currency).
- **Why the trim entry below exists:** the handoff took `SESSION_NOTES.md` to 57,111 B — past
  `context_budget.py`'s 25,000-token read cap (56,750 B at 2.27 B/token; hook-enforced) while
  the trimmer at `--budget-bytes 65536` reported NOTHING_TO_DO. Trimmed with an explicit
  `--cut 5` (budget flag still passed, no `--force`), on the committed pre-handoff state.
  **Finding, report-only:** the two `SESSION_NOTES.md` ceilings differ in practice (56,750 B
  vs 65,536 B); `CLAUDE.md`'s "deliberately the same number" holds for `max_bytes` only.
  Owner decision: align the trim budget to 56,750 B, or keep the explicit-cut workaround.
- **Post-append measurements** (`--budget-bytes 65536`): no trigger fires —
  SESSION_NOTES 24,540 B, HANDOFFS 46,707 B, CHANGELOG 56,646 B pre-entry (CHANGELOG is
  ~9 KB from its trigger). context_budget: no file over ceiling (`CLAUDE.md` warn band,
  unchanged 26,360 B). quality_ratchet: 0/0 pass · 0 fail · 0 unmeasured · results
  4f53cda18c2b · manifest 4f53cda18c2b.
- **Non-commit actions this session:** none (no push, no issue/PR/tag activity). Read-only
  outside the repo: `../nprcgenekeepr_2.0.0.9000.tar.gz` and `../nprcgenekeepr.Rcheck/00check.log`
  were listed/grepped, never modified; CRAN policy page and the CRAN 2.0.0 tarball header
  fetched; CI run 35481710058's log read via `gh`.
- **Still uncommitted, deliberately:** the owner's `.Rbuildignore` `+^scratchpad$` line.
  Unpushed after close-out: ~8 docs-only commits — owner push decision.

### 2026-09-19 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-09-19-2.md` (10 record(s), 49,225 B → 15,427 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **10** record(s) (2026-09-19 → 2026-09-19) out of [`SESSION_NOTES.md`](SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-09-19-2.md`](docs/archive/SESSION_NOTES-through-2026-09-19-2.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-09-19-2.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-19-2.md.verify.sh)
rather than trusting a digest printed here. Live file 49,225 B → 15,427 B (−68.7%).

### 2026-09-19 · [ad hoc] S727 deliverable: tarball-size audit — the "~19 MB tarball" is a `scratchpad/` leak; the real package builds to 3.49 MB (`docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md`)
- **Headline (all measured, none estimated):** clean `git archive HEAD` build =
  **3,485,185 B** (35% of CRAN's 10 MB line; CRAN 2.0.0 = 2,419,329 B, so +1.07 MB / +44%
  since release). The owner's `../nprcgenekeepr_2.0.0.9000.tar.gz` = 19,732,245 B and lists
  252 `scratchpad/` entries (19.99 MB uncompressed; untracked dir, 250 files, 16.3 MB
  compressed — two 5.6 MB `.rds` captures + 65 PNGs). Controlled reproduction (clean export
  + `scratchpad/` + untracked testthat debris, committed `.Rbuildignore`) = 19,714,510 B —
  matches to 0.1%. `git log -S'scratchpad' -- .Rbuildignore` is empty: it was never excluded.
  Current working tree (with the owner's UNCOMMITTED `+^scratchpad$`) = 3,564,041 B; the
  +78,856 B over clean is `tests/testthat/_problems/` + `testthat-problems.rds` (untracked,
  neither git- nor build-ignored).
- **Inventory:** 997 entries, 12.01 MB uncompressed. Compressed shares: `inst/doc` 1.37 MB
  (38% — three `html_document` vignettes; `a2interactive.html` alone 855 KB), `tests` 0.66,
  `inst/extdata/examples` 0.46, `R` 0.39, `man` 0.31, `data` 0.14. CRAN sub-limits: data
  2.66 MB pass; documentation 4.38 MB `inst/doc` = 86% of the 5 MB guideline (borderline);
  installed size 8.9 MB local / 9.5–10.2 MB on CI run 35481710058 (`INFO`).
- **Findings:** 0 critical · 2 moderate (scratchpad leak; doc-guideline headroom) · 3 minor
  (testthat debris ships; installed size; no mechanical size gate). Policy text verified at
  source (CRAN Repository Policy rev. 6875). No remedy applied — research-only deliverable.
- **BACKLOG:** the S726 Effort-L "reduce tarball size" item REMOVED (premise refuted by
  measurement) and replaced by a DECISION-NEEDED Effort-S build-hygiene follow-up item
  carrying the ranked actions; package-split item's cross-ref rewritten ("size is not an
  argument for splitting" — all of `R/` is 0.39 MB compressed); pedigree-growth item given
  the +1.07 MB upper bound. Stale-reference sweep of `BACKLOG.md`/`ROADMAP.md`: none left.
- No `.R` files touched (no TDD phases, lint N/A). The owner's uncommitted `.Rbuildignore`
  edit was left untouched and is not in this commit. All builds ran in the session scratch
  directory; nothing written to the repo or `..` besides the three files in this commit.

### 2026-09-19 · [ad hoc] S727 claim: tarball-size audit (in progress)
- Owner picked "Tarball-size research" from the Phase 0 4-option picker. Deliverable: one
  audit report — a measured `R CMD build` contents inventory (bytes attributed to files
  that actually ship) + ranked remedy candidates; no remedies applied this session.
  Pre-existing uncommitted `.Rbuildignore` change (`^scratchpad$`, not session-made) left
  untouched and excluded from this commit. Close-out adds its own entry.

### 2026-09-19 · [ad hoc] S726 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `211f8786`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S726 commit. S726 total: 4 commits (claim `9006b567` — pushed, CI-validated;
  BACKLOG filing `f8970edc`; records `211f8786`; this one). Ahead of `origin/master` by 3
  after close-out — push is the owner's call, all docs-only. Expect 0 undocumented commits
  past the frontier at next Phase 0; measure it.

### 2026-09-19 · [ad hoc] S726 close-out: push DONE (33 commits `4565c39d..9006b567`, 4/4 CI green on the pushed sha) + session records
- **Deliverable verified:** all 4 push-triggered workflows `completed success` filtered on
  `headSha == 9006b567` (R-CMD-check 31m53s, pkgdown 13m47s, test-coverage 10m4s, lint
  4m37s; run ids 35481709978–35481710058). First remote validation of S720–S725: the
  warning-free suite, the Suggests trim + renv re-snapshot, the context-budget adoption,
  the CLAUDE.md reduction, the `~$` guards.
- **Records:** SESSION_NOTES S726 handoff + S725 evaluation (9/10, one superseded-at-write
  gotcha noted, self-corrected by S725's own addendum entry); HANDOFFS receipt complete;
  no new PROJECT_LEARNINGS entry (routine clean push; the tarball-inventory insight lives
  in the filed BACKLOG item, its forward-carrying home).
- **Post-append trigger measurements** (`--budget-bytes 65536`): no trim fires on
  SESSION_NOTES/HANDOFFS/CHANGELOG. quality_ratchet: 0/0 pass · 0 fail · 0 unmeasured ·
  results 4f53cda18c2b · manifest 4f53cda18c2b.
- Unpushed after close-out: ~3 docs-only commits (BACKLOG filing + records + sha) — owner
  push decision; expect 0 undocumented commits past the frontier at next Phase 0.

### 2026-09-19 · [ad hoc] S726 mid-session owner request: tarball-size-reduction item filed in `BACKLOG.md` Up Next (READY, Effort L)
- Owner reports the source tarball at ~19 MB vs CRAN policy's ≤10 MB ("should, if
  possible"; data ≤5 MB, documentation ≤5 MB generally) and steers that slimming
  examples/test data may beat the package split; extensive code research required first.
- Item filed with a measure-first mandate (`R CMD build` + `tar tzvf` inventory — on-disk
  sizes mislead because `.Rbuildignore` already excludes `docs/`, `vignettes/articles/`,
  and several reference files), S726 quick size anchors, the remedy candidate list, and
  cross-references both ways with the package-split investigation item (S667 scoping rec
  "do not split now", owner disposition pending) and the pedigree-growth measurement item.
- Filed only, not acted on (1-and-done; S721 `ede5289e` precedent for mid-session filings).

### 2026-09-19 · [ad hoc] S726 claim: owner-directed push to `origin/master` (in progress)
- Owner picked "Push to origin" from the Phase 0 4-option picker. 32 unpushed commits
  (S720–S725) at claim time; this claim commit rides the push, so CI runs on it (S717
  precedent). Deliverable: push + all 4 push-triggered workflows green. Close-out adds
  its own entry.

### 2026-09-19 · [ad hoc] S725 post-close-out, owner-directed: recurring Word lock file `inst/extdata/reference/~$e Compounding Loop.html` deleted; standing `~$` guards added to `.Rbuildignore` and `.gitignore`
- Owner picked "delete + Rbuildignore guard" from the close-out `AskUserQuestion`. The file
  was a 162-byte Microsoft Word owner/lock file (contents: just the Office username) for the
  local-only `The Compounding Loop.html`; first deleted S568, recreated 2026-08-18 by a later
  Word open, and flagged by local `devtools::check()` as a non-portable filename because
  `R CMD build` copies the working tree (never committed — `git log --all` on the path is
  empty, so the `rm` is a non-commit action recorded here).
- **Guards (the new part beyond S568's plain delete):** `.Rbuildignore` gains unanchored
  `~\$` (paren-free per the file's own regex-safety rule); `.gitignore` gains `~$*` in the
  same reference-file section, mirroring the S497/S567/S568 pairing precedent.
- **Verified on a probe lock file** (`~$probe.txt`, created then removed):
  `git check-ignore -v` matched `.gitignore:91:~$*`, and R's own `tools:::inRbuildignore()`
  — the code path `R CMD build` uses — returned TRUE. The next local `devtools::check()`
  should drop the non-portable-filename warning; the known warn/exit-1 gotcha recorded in
  S724/S725 handoffs is thereby expected to clear (next check run confirms).

### 2026-09-19 · [ad hoc] S725 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `6d890617`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S725 commit. S725 total: 4 commits (claim `1ef168b8`, deliverable `c8512d0d`,
  records `6d890617`, this one); ahead of `origin/master` by 31 including the 27
  pre-existing — push is the owner's call. Expect 0 undocumented commits past the
  frontier at next Phase 0; measure it.

### 2026-09-19 · [ad hoc] S725 close-out: session records (SESSION_NOTES handoff + S724 evaluation 9/10, HANDOFFS receipt complete) and post-append verification measurements
- **Trigger states, measured AFTER the handoff/receipt text was appended**, all under
  `--budget-bytes 65536`: `SESSION_NOTES.md` 42,524 B, `HANDOFFS.md` 36,925 B,
  `CHANGELOG.md` 46,092 B — none fires; no trim owed this session. `context_budget.py`:
  no file over its ceiling (`CLAUDE.md` 26,360 B, warn band = documented headroom).
- **Close-out checklists:** no `.R` files touched → lint N/A; no new exports/statistics/
  Shiny features → NEWS/pkgdown/citation/tutorial/`a2interactive` N/A; completed BACKLOG
  item names no GitHub issue → issue close-out N/A; CI green all session (on the S719
  push); quality_ratchet 0/0 (manifest empty by design); runtime smoke N/A — docs-only.
  Learning 770 doubles as the session learning (its point 6 records the reduction method).
- **Owner mid-session report, triaged not fixed (S723 precedent):** the untracked
  `inst/extdata/reference/~$e Compounding Loop.html` is a 162-byte Microsoft Word
  owner/lock file (contents: just the Office username) left behind on 2026-08-18 when the
  local-only `The Compounding Loop.html` reference file was opened in Word; never
  committed; its 3 parent files are individually `.Rbuildignore`d (lines 125-127) but the
  lock file is not, so `R CMD build` copies it into the check tarball → the non-portable-
  filename warning. Remedy (delete + optional `.Rbuildignore` `~$` guard) posed to the
  owner at close-out; not acted on inside this session's deliverable.
- Sha self-reconcile commit follows with its own entry; expect 0 undocumented commits past
  the frontier at next Phase 0.

### 2026-09-19 · [ad hoc] S725 deliverable: `CLAUDE.md` reduction campaign — 43,348 B → 26,360 B, under the 28,000 B ceiling; BACKLOG item removed (completed record here)
- **Method (per the item):** each Adaptations block classified sentence-by-sentence into
  operative rule vs incident narrative; rules kept (verbatim or tightened) with origins
  compressed to Learning pointers; narrative that existed nowhere else moved into the new
  `PROJECT_LEARNINGS.md` Learning 770 (the relocation record — S545 rejected alternatives,
  S436 origin, NEWS.Rmd drift history, `methodology_trim.py` provenance, the S325/S546/S547
  legacy-history decision chain); the full pre-reduction text is archived as
  `git show 1ef168b8:CLAUDE.md`. Kept intact per the item: SESSION PROTOCOL header, the
  `budget:protected` Project Overview fence, the TDD contract (incl. Phase-gate format),
  Build/Test/Verify. Hand-maintained learnings count replaced with its computing command
  (Compute remedy); two sentences the reduction itself falsified were updated (the
  context-budget check's expected state; the trilogy's "no file has moved yet").
- **Verification:** `wc -c CLAUDE.md` = 26,360 B (≤ 28,000; warn band ≥ 24,000 is headroom,
  documented as such); `python3 context_budget.py` reports no file over its ceiling,
  resident total 26,360/34,000 green, `budget:protected` fence intact;
  `grep -c '^#### Learning '` = 770, matching the new relocation record's number; every
  Learning number cited by a new pointer verified present (382/433/435/475/477/478/479/
  495/506/533/544/547/549/554/586/587/669/740). No `.R` files touched → lint checklist N/A;
  no TDD phases (docs-only, S720–S724 precedent).

### 2026-09-19 · [ad hoc] S725 claim: `CLAUDE.md` reduction campaign — move Adaptations incident narratives to `PROJECT_LEARNINGS.md`, keep rules + pointers, bring the file under its 28,000 B ceiling *(in progress)*
- Owner-picked from the Phase 0 4-option picker. Phase 0: reconcile clean (0 undocumented
  commits on both frontiers, predicted 0 by S724 — measured 0); CI 10/10 green (still on
  the S719 push; the 27 unpushed commits have never seen CI); dashboard 96/100;
  context-budget reds by-design only (`CLAUDE.md` 43,348 B — this session's target);
  untracked files all long-standing/known. Stub + pending receipt ride this commit.

### 2026-09-19 · [ad hoc] S724 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `da52bd49`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S724 commit. S724 total: 4 commits (claim `1bd5ef9c`, deliverable `eb3573bc`,
  records `da52bd49`, this one); ahead of `origin/master` by 27 including the 23
  pre-existing — push is the owner's call, and the 0-warning suite reaches CI only once
  pushed (CI's R-CMD-check runs this same suite). Expect 0 undocumented commits past the
  frontier at next Phase 0; measure it.

### 2026-09-19 · [ad hoc] S724 close-out: session records (SESSION_NOTES handoff + S723 evaluation 9/10, HANDOFFS receipt complete, `PROJECT_LEARNINGS.md` Learning 769) and post-append verification measurements
- **Trigger states, measured AFTER the handoff/receipt/learning text was appended**, all under
  `--budget-bytes 65536`: `SESSION_NOTES.md` 37,239 B, `HANDOFFS.md` 32,489 B, `CHANGELOG.md`
  41,926 B — none fires; no trim owed this session.
- **`context_budget.py` post-append run:** exactly the documented expected state — `CLAUDE.md`
  43,348 B / resident total over (red by design, remedy filed), `SESSION_NOTES.md` ok.
- **Close-out checklists:** lint DONE (3 touched test `.R` files, 0 lints, package loaded
  first); no new exports/statistics/Shiny features → NEWS/pkgdown/citation/tutorial/
  `a2interactive` N/A; BACKLOG item completed but names no GitHub issue → issue close-out N/A;
  CI green all session (on the S719 push), no CI break found; quality_ratchet cited in the
  receipt (0/0, manifest empty by design); runtime smoke N/A — test-only, no runtime surface.
- Sha self-reconcile commit follows with its own entry; expect 0 undocumented commits past the
  frontier at next Phase 0.

### 2026-09-19 · [ad hoc] S724 deliverable: baseline-warnings cleanup — suite warning count 40 → 0 via 16 `suppressWarnings()` wraps on triggering test calls; BACKLOG item removed (completed record here)
- **Inventory re-derived from a fresh full-suite run** (the item's own mandate — and it was
  right to demand it): the 40 warnings were NOT all one class. 37 are the `markerKinship()`
  NA-path (`R/markerKinship.R:131-139`, working as designed) across 14 blocks, all in
  `test_modMarkerGenetics.R` — the 3 known 5-warning blocks (2 cross-center + the issue #155
  candidate-parent block) plus **11** two-warning blocks from the `i152_roh_genotype.csv`
  fixture (pairs I1/I3, I2/I3; the item's stale list knew only 2 of these). The other 3 are
  out-of-class: `test_appServer_server.R` "wires child-module outputs into shared state"
  (2: `findGeneration` unplaced-id + empty-`max()` `-Inf`, from the 1-row toy pedigree) and
  `test_modPedigree_processing.R` "trimPedigree works with examplePedigree" (1:
  `makePedigreeMatingLayout()` 2-collision residual, the accepted render-quality warning).
- **Remedy:** owner picked "suppress all 16 sites" via `AskUserQuestion` (Learning 273(d) —
  suppress the incidental warning, not the branch; fixture-completion option declined). The
  16 wraps: 14 `setInputs(genotypeFile=...)` (2 centerA, 1 flaggedSlot, 11 i152_roh), 1
  `session$flushReact()` (appServer), 1 `setInputs(trimPedigree=TRUE)`. Test assertions and
  production code untouched; diff is exactly the 16 wraps.
- **Verification:** all 3 touched files individually 0 failed/0 error/0 warning; full clean
  regression read `blocks=2437 failed=0 error=0 skipped=184 warning=0` — block and skip
  counts equal the S718–S723 baseline exactly, warnings 40 → 0; `lintr::lint_package()` 0
  lints (package loaded first, Learning 224). The suite is back to the 0-warning state of
  CRAN v2.0.0 — the owner's "we had zero at last release" report (S487) that opened the item.
- No TDD phases (test-hygiene: no new tests, no assertion or production change; the remedy
  choice was the session's gate, posed with the inventory in hand).

### 2026-09-19 · [ad hoc] S724 claim: baseline-warnings cleanup — re-derive the warning-block inventory, then clean the ~40 markerKinship() NA-path suite warnings *(in progress)*
- The `BACKLOG.md:233` Housekeeping item (found S487, annotated S723; count 10 → 15 → 40,
  block list stale twice). Plan: fresh-suite inventory grouped by test block first; remedy
  (Learning 273(d) `suppressWarnings()` on triggering calls vs. fixture completion with
  expected-value re-verification) gated by `AskUserQuestion` with the inventory in hand.
  Owner picked this from the Phase 0 four-option picker. Stub + pending receipt in this commit.

### 2026-09-19 · [ad hoc] S723 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `77a832e0`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S723 commit. S723 total: 5 commits (claim `3980cc31`, deliverable `d2a43162`,
  BACKLOG annotation `e2a91424`, records `77a832e0`, this one); ahead of `origin/master`
  by 23 including the 18 pre-existing — push is the owner's call, and the warning fix
  reaches other clones only once pushed. Expect 0 undocumented commits past the frontier
  at next Phase 0; measure it.

### 2026-09-19 · [ad hoc] S723 close-out: session records (SESSION_NOTES handoff + S722 evaluation 9/10, HANDOFFS receipt complete, `PROJECT_LEARNINGS.md` Learning 768) and post-append verification measurements
- **Trigger states, measured AFTER the handoff/receipt/learning text was appended**, all under
  `--budget-bytes 65536`: `SESSION_NOTES.md` 30,599 B (does not fire), `HANDOFFS.md` does not
  fire, `CHANGELOG.md` does not fire — no trim owed this session.
- **`context_budget.py` post-append run:** exactly the documented expected state — `CLAUDE.md`
  43,348 B / resident total over (red by design, remedy filed), `SESSION_NOTES.md` ok.
- **Close-out checklists:** lint DONE (touched `.R` file clean, package loaded first); no new
  exports/statistics/Shiny features → NEWS/pkgdown/citation/tutorial/`a2interactive` N/A (a
  roxygen comment on a `@noRd` internal changes no user-facing surface); no BACKLOG item
  completed and none names a GitHub issue → issue close-out N/A; CI green all session, no CI
  break found; quality_ratchet cited in the receipt (0/0, manifest empty by design).
- Sha self-reconcile commit follows with its own entry; expect 0 undocumented commits past the
  frontier at next Phase 0.

### 2026-09-19 · [ad hoc] S723: BACKLOG baseline-warnings item annotated — owner-reported RStudio test warnings triaged to it; block list marked stale (10 → 15 → 40), re-derive-the-inventory instruction added
- Mid-session owner report: `markerKinship()` "share no heterozygous locus" warnings at
  `test_modMarkerGenetics.R:1649`/`:1712` (issue #152 sequence-export-preview tests, S535's
  `i152_roh_genotype.csv` fixture, pair `'I2'`/`'I3'`) — 2 blocks not in the item's 3-block
  list. Source confirmed `R/markerKinship.R:135`, the documented NA path; suite green.
  Annotation only — no fix, per 1-and-done and the item's own "report, don't fix
  mid-session" lineage; the item stays READY (Effort S) for a dedicated cleanup session.

