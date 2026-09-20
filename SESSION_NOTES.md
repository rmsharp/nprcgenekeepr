# Session Notes

**Purpose:** Continuity between sessions. Each session reads this first and writes to it before closing out.

**Archived 612 record(s), 1998-12-06 → 2026-08-12** into [`docs/archive/SESSION_NOTES-through-2026-08-12.md`](docs/archive/SESSION_NOTES-through-2026-08-12.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 40 record(s), 2026-08-11 → 2026-08-13** into [`docs/archive/SESSION_NOTES-through-2026-08-13.md`](docs/archive/SESSION_NOTES-through-2026-08-13.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 76 record(s), 2026-01-26 → 2026-08-15** into [`docs/archive/SESSION_NOTES-through-2026-08-15.md`](docs/archive/SESSION_NOTES-through-2026-08-15.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 170 record(s), 2026-08-19 → 2026-09-17** into [`docs/archive/SESSION_NOTES-through-2026-09-17.md`](docs/archive/SESSION_NOTES-through-2026-09-17.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-09-17.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-17.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 19 record(s), 2026-08-14 → 2026-09-18** into [`docs/archive/SESSION_NOTES-through-2026-09-18.md`](docs/archive/SESSION_NOTES-through-2026-09-18.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-09-18.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-18.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 21 record(s), 2026-09-17 → 2026-09-19** into [`docs/archive/SESSION_NOTES-through-2026-09-19.md`](docs/archive/SESSION_NOTES-through-2026-09-19.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-09-19.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-19.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 10 record(s), 2026-09-19 → 2026-09-19** into [`docs/archive/SESSION_NOTES-through-2026-09-19-2.md`](docs/archive/SESSION_NOTES-through-2026-09-19-2.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-09-19-2.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-19-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

---

## ACTIVE TASK

### What Session 733 Did
**Deliverable:** Owner-directed push to `origin/master` + CI verification (IN PROGRESS)
**Started:** 2026-09-20
**Status:** Session claimed. Work beginning.
**Ledger:** `CHANGELOG: pending`

### Session 731 Handoff Evaluation (by Session 732)
**Score: 9/10.** **What helped:** next-step (B) named this exact pickup with location and
method (`R/makePedigreeDiagramData.R:1659` + `devtools::document()` + audit §7 re-measure),
and gotcha (2) routed to the S730 receipt + `BACKLOG.md:117`, which together WERE the
execution plan (clean-export recipe with `NOT_CRAN` unset; `\donttest{}` is NOT an escape;
never hand-edit `man/*.Rd`); "expect 0 undocumented; measure it" measured 0 on both
frontiers; "~2 unpushed" measured exactly 2; the receipt's ratchet citation matched
`.quality-gates-results.json` byte-for-byte. **What was missing:** the §7 recipe's
`R_LIBS` capture is vulnerable to renv's out-of-sync banner landing on stdout (cost one
4-s failed check run this session) — chargeable to the S730 recipe, not S731, but the
carried chain didn't flag it. **What was wrong:** nothing found — every checked claim
held. **ROI:** high.

### What Session 732 Did
**Deliverable:** CRAN check-time fix applied — **DONE.** The `makePedigreeMatingLayout`
roxygen example input swapped `examplePedigree` (3,694 rows, 734 s = 71% of the whole
check) → **`smallPed`** (17 rows, 0.03 s, zero warnings) at
`R/makePedigreeDiagramData.R:1659-1663` + regenerated `man/makePedigreeMatingLayout.Rd`
via `devtools::document()`. **§7 clean-export re-measure at the fix commit `ba088d0d`:
Status OK, zero NOTEs, the >5 s examples table is EMPTY** (worst remaining:
`groupAddAssign` 1.98 s); examples 743.0 → 9.8 s elapsed over 202 Rd files; whole check
1,032 → **291.6 s CPU (4.9 min, −72%)** — matching the audit's ~5 min prediction; wall
518.8 s (8.6 min) is contention-inflated (load avg 50+, external VM + 5 Chromium procs;
CPU/wall 0.56 vs S730's 0.995) and is an upper bound, not a quiet-machine number. TDD
N/A (doc-only `.Rd` example change; the re-measure is the ratified verification gate).
Lint: 0 on the touched file (package loaded).
**Started/completed:** 2026-09-20 (single session). Claim `e7fe4713`; fix `ba088d0d`;
records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per commit; the close-out entry carries the
verification numbers. BACKLOG item removed in the records commit (S686 convention).

**What actually happened, in order:**
1. **Phase 0:** full 8-step orient; reconcile clean (0 undocumented on both frontiers at
   `400e226e`; S731 receipt complete, ratchet citation matches results file); CI 4/4
   green on `3b688ae2`; dashboard 96/100; context budget WARN = CLAUDE.md warn band only;
   2 unpushed as predicted; 5 known untracked files unchanged; audits dir unchanged.
2. **Input choice measured, not assumed:** all shipped pedigrees with the required
   columns timed through the function — `smallPed` 0.03 s/clean beat the item's named
   candidate `pedWithGenotype` (0.93 s + 5-collision warning), `qcPed` (0.91 s + same),
   `rhesusPedigree` (2.91 s + 72-collision warning); `smallPed` is already the fixture
   idiom in 13 other roxygen examples (matched their style).
3. **Fix committed BEFORE re-measure** (the §7 recipe builds `git archive HEAD`).
4. **First §7 run failed in 4 s** ("quadprog not available"): the `R_LIBS` capture took
   renv's banner on stdout. Re-captured with `| tail -1`; re-check passed as above.

**Self-assessment (Session 732): 9/10.** **Strengths:** (1) measured every candidate
input instead of adopting the item's named one — found a strictly better example (clean
layout, 30× faster); (2) verification pinned to the committed sha with the enforcement
view itself (empty >5 s table), plus a per-stage CPU decomposition explaining the wall
discrepancy rather than hand-waving it; (3) scope held — the optional Finding-4
`skip_on_cran()` lever was explicitly NOT taken; no test/implementation changes; (4) the
contended wall number is reported honestly instead of re-run until pretty.
**Weaknesses:** (1) the first §7 run was wasted on the `R_LIBS` capture fumble; (2) the
clean-machine wall time (~5 min) is inferred from CPU, not measured — the machine stayed
loaded all session.

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine Effort-S fix (S730/S731
precedent); the `R_LIBS` gotcha lives in the gotchas below and the close-out ledger
entry. **Reduction check:** the completed 20-line BACKLOG item block removed from a
mandated-read file this session.

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~6 expected after close-out: 2 pre-existing
+ claim + fix + records + sha; last two estimated at write time). The fix commit touches
`.R`/`.Rd`, so a push gets it remote R-CMD-check validation — mildly more useful than
the recent docs-only pushes, still no urgency. (B) Priorities: pedigree-growth
measurement (READY, S — now the first Up Next item after the removal); package-split
disposition + REUSE registration (owner decisions); BACKLOG.md editorial compression
(READY, L); inst/doc slimming (DECISION NEEDED, M, `BACKLOG.md:100`). (C) Standing
report-only set unchanged from S731.

**Key files:** `R/makePedigreeDiagramData.R:1659-1663` (the new example),
`man/makePedigreeMatingLayout.Rd:110-113` (regenerated), `CHANGELOG.md` S732 entries
(verification numbers), `docs/audits/CRAN_CHECK_TIME_AUDIT_2026-09-19.md` §7 (recipe;
Finding 4 holds the optional untaken lever).

**Gotchas for the next session:** (1) **§7 recipe trap:** capture `R_LIBS` with
`Rscript -e 'cat(.libPaths()[1])' 2>/dev/null | tail -1` — renv's out-of-sync banner can
land on stdout, and a polluted `R_LIBS` kills the check in 4 s with "Package required
but not available: 'quadprog'". (2) Expect 0 undocumented commits at next Phase 0 —
measure it; ~6 unpushed (estimate). (3) If a quiet-machine wall figure is ever wanted,
re-run §7 under normal load; direction is settled (empty >5 s table, worst Rd 1.98 s,
CPU 4.9 min). (4) The Finding-4 `skip_on_cran()` lever stays untaken — only if CRAN's
actual farm crowds 10 min at submission. (5) Standing set unchanged: `scratchpad/`
invisible to git BY OWNER DECISION; ratchet ~2 min, AFTER committing (Learning 772);
trim needs `--budget-bytes 65536`; renv banner expected; `CLAUDE.md` warn band; the two
`SESSION_NOTES.md` ceilings differ (owner decision pending); suite baseline
2437/0/0/184/0 — not re-run locally (no code-behavior change; the CRAN-surface suite ran
0-fail inside the §7 check).

### Session 730 Handoff Evaluation (by Session 731)
**Score: 9/10.** **What helped:** next-step (A) named the push decision with the exact recount
command — measured 8, predicted ~8 exactly; the priorities list mapped one-for-one onto the
Phase 0 picker and the owner picked the push; "expect 0 undocumented commits; measure it"
measured 0 on both frontiers; the receipt's ratchet citation matched
`.quality-gates-results.json` byte-for-byte (results 10bcea6e4007, manifest aa983075d6a2);
the S729-precedent chain it carried (claim rides the push; sha-filtered CI verification;
background-poller learning) was this session's entire method. **What was missing:** nothing
material — only the CI-wait mechanics (R-CMD-check ~34 min exceeds a 30-min monitor arm, so
one re-arm is expected) had to be re-derived from S729's recorded durations rather than
stated. **What was wrong:** nothing found — every checked claim held. **ROI:** high.

### What Session 731 Did
**Deliverable:** Owner-directed push to `origin/master` + CI verification — **DONE.**
Pushed `0572767b..3b688ae2` (9 commits: the 8 unpushed S730 docs-only commits + the S731
claim, which rode the push so CI ran on it — S729/S726/S717 precedent). All 4 push-triggered
workflows `completed success` ON THE PUSHED SHA `3b688ae2` (verified via
`gh run list --commit <sha>`, so the sha match is structural, not read off run titles):
lint 4m26s (id 35490394639), test-coverage 8m41s (35490394613), pkgdown 18m05s (35490394612),
R-CMD-check 33m37s (35490394609). This puts the S730 CRAN check-time audit and the full S730
close-out record set on the remote. No TDD phases (push + docs; no `.R` files). Lint N/A.
**Started/completed:** 2026-09-19 → 2026-09-20 (single session; the CI wait crossed local
midnight). Claim `3b688ae2` (rode the push); records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, push+CI deliverable, records, sha).

**What actually happened, in order:**
1. **Phase 0:** full 8-step orient; reconcile clean (0 undocumented on both frontiers, both
   at HEAD `bd094712`; S730 receipt `complete`, its ratchet citation matches
   `.quality-gates-results.json` exactly); CI 4/4 green on `0572767b`; dashboard 96/100;
   context budget WARN = `CLAUDE.md` warn band only (headroom) + growth run 10/10
   (report-only); 8 unpushed measured (S730's prediction exact); 5 known untracked files
   unchanged; sequencing audits unchanged since S730's check (0 commits since).
2. **Claim committed and rode the push:** `3b688ae2`; `git push` → `0572767b..3b688ae2`.
3. **CI verification:** Monitor polling `gh run list --commit 3b688ae2` at 60 s; one
   expected re-arm at the 30-min monitor cap (R-CMD-check ~34 min); all 4 workflows
   `completed success` on the pushed sha.
4. **quality_ratchet at the pushed HEAD `3b688ae2`:** 1/1 pass · 0 fail · 0 unmeasured ·
   results 24c0d9475ec1 · manifest aa983075d6a2 (tarball 3,483,933 B ≤ 5,000,000 B).

**Self-assessment (Session 731): 9/10.** **Strengths:** (1) the deliverable was verified on
the exact pushed sha by construction (`--commit` filter), not by matching run titles;
(2) prediction discipline held both ways — 8 unpushed predicted/measured, 0 undocumented
predicted/measured; (3) scope held absolutely through the ~50-min CI wait (no side work);
(4) every close-out number is from a fresh read this hour, not memory. **Weaknesses:**
(1) the re-armed monitor re-emitted the 3 already-green workflows (predicted, but still
noise); (2) durations are createdAt→updatedAt, which include queue time (matches gh's
displayed durations in direction; seconds ±).

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine push session (S729 precedent;
fourth of its kind). **Reduction check:** nothing removed from mandated-read files this
session — nothing beyond the session records was added either; `SESSION_NOTES.md` sits at
~44 KB against its 65,536 B ceiling.

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~2 expected after close-out: records + sha; both
docs-only; no urgency — CI is current through `3b688ae2`). (B) Priorities: **apply the CRAN
check-time fix** (READY, S, `BACKLOG.md:117` — natural next pickup, unchanged from S730);
pedigree-growth measurement (READY, S, `BACKLOG.md:136`); package-split disposition + REUSE
registration (owner decisions); BACKLOG.md editorial compression (READY, L); inst/doc
slimming (DECISION NEEDED, M, `BACKLOG.md:100`). (C) Standing report-only set unchanged
from S730.

**Key files:** `CHANGELOG.md:41` (S731 entries at top), `HANDOFFS.md:155` (S731 receipt),
`BACKLOG.md:117` (next natural pickup), `docs/audits/CRAN_CHECK_TIME_AUDIT_2026-09-19.md`
(now on the remote).

**Gotchas for the next session:** (1) Expect 0 undocumented commits at next Phase 0 —
measure it; ~2 unpushed (estimate at write time). (2) The apply-the-fix session's own
gotchas live in the S730 receipt and `BACKLOG.md:117` (clean-export §7 recipe with
`NOT_CRAN` unset; `\donttest{}` is NOT an escape at incoming; never edit `man/*.Rd` by
hand — `devtools::document()` regenerates). (3) CI-wait mechanics: R-CMD-check ~34 min
exceeds the 30-min Monitor cap — arm expecting one re-arm; filter with
`gh run list --commit <sha>` so the sha match is structural. (4) Standing set unchanged:
`scratchpad/` invisible to git BY OWNER DECISION; ratchet ~2 min, run AFTER committing
(Learning 772); trim needs `--budget-bytes 65536`; renv banner expected; `CLAUDE.md` warn
band; the two `SESSION_NOTES.md` ceilings differ (owner decision pending); suite baseline
2437/0/0/184/0 — remote-confirmed again by R-CMD-check on `3b688ae2`.

### Session 729 Handoff Evaluation (by Session 730)
**Score: 9/10.** **What helped:** the priorities list mapped one-for-one onto this session's
Phase 0 picker, and the owner picked its #1; the `BACKLOG.md:117` item WAS the execution plan
verbatim — both measurement axes with their exact commands, the NOT_CRAN-inversion warning
(gotcha 2) that became this session's method, and the GHA-is-not-the-CRAN-number caution that
was confirmed in passing (CI step timestamps unretrievable); "expect 0 undocumented commits;
measure it" measured 0 on both frontiers; the "~3 unpushed" estimate was already self-corrected
to 4 by S729's own sha-commit ledger entry before this session read it. **What was missing:**
nothing material — only that the item's remedy steer ("fewer gene-drop iterations; simulation
functions take `n` directly") pointed at simulation examples while the actual culprit is the
pedigree-layout example; zero harm, because the item's own measure-first mandate exists
precisely to catch that. **What was wrong:** nothing found — every checked claim held. **ROI:**
high.

### What Session 730 Did
**Deliverable:** CRAN check-time measurement audit — **DONE.**
[`docs/audits/CRAN_CHECK_TIME_AUDIT_2026-09-19.md`](docs/audits/CRAN_CHECK_TIME_AUDIT_2026-09-19.md).
**One example is the entire problem: the full CRAN-surface check is 1,037 s wall / 1,032 s CPU
(17.3 min, Status OK), and 734 s (71%) of it is the single `makePedigreeMatingLayout` Rd
example** running the full 3,694-row `examplePedigree` — ~147× CRAN's 5 s per-Rd threshold,
on an input ~5× the app's own 750-individual diagram cap (`R/modPedigree.R:406`). The other
201 timed examples total 8.9 s. Tests are fine (215 s under check, 0 fail; ~14% of local
blocks already stay home on CRAN). Measured remedy: the same call on `pedWithGenotype`
(280 rows) is 1.0 s → check drops to ~5 min, clearing the verified 10-min incoming
"Overall checktime" NOTE. Research only: no remedy applied, no `.R`/`man/` change, no TDD
phases, lint N/A.
**Started/completed:** 2026-09-19 (single session). Claim `c8397845`; deliverable `e8a0eca7`;
records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per commit; the deliverable entry carries the numbers.

**What actually happened, in order:**
1. **Phase 0:** full 8-step orient; reconcile clean (0 undocumented on both frontiers; S729
   receipt's ratchet citation matches `.quality-gates-results.json` exactly); CI 4/4 green on
   `0572767b`; dashboard 96/100; context budget warn-band only; 4 unpushed (S729's own ledger
   had already corrected its ~3 estimate); sequencing audits checked — no ratified order
   outranks the BACKLOG order (their clusters are closed issues or the retired campaign).
2. **Criteria verified at source:** CRAN policy rev 6875 fetched (CPU-time/examples/2-core/
   optional-long-tests passages quoted); the 5 s per-Rd threshold, its CPU-or-elapsed rule,
   and `_R_CHECK_DONTTEST_EXAMPLES_` = `as_cran` (donttest STILL RUNS at incoming) read from
   `tools/R/check.R` itself; the 10-min incoming "Overall checktime" NOTE evidenced from
   R-pkg-devel.
3. **Measurements:** clean-export tarball (3,485,111 B at `c8397845`, §7 recipe) →
   `R CMD check --timings` with `NOT_CRAN` unset under `/usr/bin/time -l` (1,037 s; the check's
   own >5 s table lists exactly one row); per-file testthat runs on BOTH sides of the NOT_CRAN
   switch (CRAN surface 187.6 s / 2,141 blocks / 200 skips; baseline 260.3 s / 2,437 / 184 —
   reproducing the standing baseline exactly and settling its currency as rows/failed/error/
   skipped); control measurement `pedWithGenotype` → 1.0 s; CPU/wall 0.995 = single-threaded
   (2-core policy pass measured, not assumed).
4. **BACKLOG:** measure-first item removed (complete, S686 convention), replaced in place by
   the READY/Effort-S "apply the CRAN check-time fix" item carrying every number, location,
   and the NOT-`\donttest` warning.

**Self-assessment (Session 730): 9/10.** **Strengths:** (1) every enforcement criterion was
verified in the enforcing tool's own source or at the policy page, not folklore — which
overturned the item's implicit `\donttest` remedy before it could be recommended; (2) the
headline finding is closed three ways (Ex.timings, the check's own >5 s table, and a measured
small-input control that also sized the remedy); (3) the identical-currency double test run
settled the long-standing baseline-currency question instead of comparing reporter apples to
block oranges; (4) scope held — the fix is a one-line temptation and it was filed, not applied.
**Weaknesses:** (1) all timings are single runs, no variance estimate (direction of every
conclusion is robust to that, magnitude ±); (2) the ~79 s install/vignette/manual residual was
not decomposed per stage; (3) one sloppy artifact — the full-results CSV write errored on a
list column after the needed numbers printed (per-file CSV landed fine).

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine measurement session (S727/S729
precedent); the insights' forward-carrying homes are the audit and the rewritten BACKLOG item.

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~8 expected after close-out: 4 pre-existing +
claim + deliverable + records + sha; the last two are an estimate at write time). All
docs-only. (B) Priorities: **apply the CRAN check-time fix** (READY, S, `BACKLOG.md:117` —
doc-only `.Rd` example change + §7 re-measure; the natural next pickup); pedigree-growth
measurement (READY, S, owner-requested S721); package-split disposition + REUSE registration
(owner decisions); BACKLOG.md editorial compression (READY, L); inst/doc slimming (DECISION
NEEDED, M, `BACKLOG.md:100`). (C) Standing report-only set unchanged from S729.

**Key files:** `docs/audits/CRAN_CHECK_TIME_AUDIT_2026-09-19.md` (§2 stage table, §3 findings,
§7 recipe), `BACKLOG.md:117` (the apply-the-fix item), `R/makePedigreeDiagramData.R:1659-1662`
(the roxygen example to change — never edit `man/*.Rd` by hand; `devtools::document()`
regenerates), `R/modPedigree.R:406` (the 750-individual cap), `CHANGELOG.md` S730 entries.

**Gotchas for the next session:** (1) The apply-the-fix re-measure must use the §7
clean-export recipe with `NOT_CRAN` unset — expect ~5 min total and an EMPTY >5 s table;
never measure from the working tree. (2) `pedWithGenotype` through the layout emits a benign
5-collision warning — fine for timing, but the remedy session may prefer a clean-laying-out
`examplePedigree` subset for the shipped example. (3) `\donttest{}` is NOT an escape at
incoming (verified in `check.R`) — do not let a future session re-derive the wrong remedy.
(4) Standing set unchanged: `scratchpad/` invisible to git by owner decision; ratchet ~2 min,
run AFTER committing (Learning 772); trim needs `--budget-bytes 65536`; renv banner expected;
CLAUDE.md warn band; the two `SESSION_NOTES.md` ceilings differ (owner decision pending);
suite baseline 2437/0/0/184/0 — reproduced exactly this session, currency now settled
(rows/failed/error/skipped in `as.data.frame(test_dir(...))` terms).

### Session 728 Handoff Evaluation (by Session 729)
**Score: 9/10.** **What helped:** next-step (A) named the push decision with the exact recount
command — measured 12, predicted ~12; "the push also puts the first gate manifest on the
remote" framed this session's stakes correctly; gotcha (2) (ratchet now ~2 min, run it AFTER
committing because the gate measures `git archive HEAD`) was applied directly — both close-out
ratchet runs landed at the right HEADs with no fumble; the carried S726 poller learning
avoided the blocked sleep-chain mistake on the CI wait. **What was missing:** nothing
material. **What was wrong:** nothing found — every checked claim held (12 unpushed measured
12; frontiers at HEAD; the 5 known untracked files unchanged). **ROI:** high.

### What Session 729 Did
**Deliverable:** Owner-directed push to `origin/master` + CI verification — **DONE.**
Pushed `9006b567..0572767b` (13 commits: the 12 unpushed S726–S728 docs/config commits + the
S729 claim, which rode the push so CI ran on it — S717/S726 precedent). All 4 push-triggered
workflows `completed success` ON THE PUSHED SHA `0572767b` (jq-filtered on `headSha`):
lint 4m49s (id 35485603669), test-coverage 9m39s (35485603670), pkgdown 18m32s (35485603680),
R-CMD-check 33m54s (35485603672). This is the first remote validation of the S728
build-hygiene work, including the first `.quality-gates.json` manifest now on the remote.
No TDD phases (push + docs; no `.R` files). Lint N/A.
**Started/completed:** 2026-09-19 (single session). Claim `0572767b` (rode the push);
mid-session BACKLOG filing `c9c946f7`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, filing, close-out, sha).

**Mid-session owner request (filed, not acted on — 1-and-done, S726 precedent):**
CRAN check-time item added to `BACKLOG.md:117` (`c9c946f7`, READY, Effort M): see if example
and test code can run shorter for CRAN submission needs. Measure-first mandate on the
CRAN-visible surface: `R CMD check --timings` per-Rd example times (incoming checks NOTE
> 5 s) and a suite run WITHOUT `NOT_CRAN=true` so `skip_on_cran()` exclusions match CRAN's;
remedy candidates (`\donttest{}`, smaller example inputs, `skip_on_cran()` on tests CI already
covers, shared fixtures) deferred until the measurements exist.

**Verification:** push confirmed (`master` even with `origin/master` post-push); CI 4/4
`completed success` filtered on `headSha == 0572767b` exactly (not eyeballed from the run
list); background poller from the start (35 polls, ~35 min). quality_ratchet re-run at the
close-out HEAD: see the close-out `CHANGELOG.md` entry for the citation.

**Self-assessment (Session 729): 9/10.** **Strengths:** (1) claim rode the push so CI ran on
the exact claim sha; (2) verification pinned to `headSha`, with run ids and durations
recorded; (3) the mid-session owner request was filed with a measure-first mandate and its
own ledger entry, and NOT started; (4) the CI wait used a background poller from the first
attempt. **Weaknesses:** (1) Phase 0 was an abbreviated re-verification (status, unpushed
count, frontier check) rather than the full 8-step read — the session began minutes after
S728's close-out with the full orientation in-context and the owner's task already given;
recorded here honestly rather than claimed as a full Orient; (2) the poller's 55-poll cap was
a guess that happened to fit (35 needed) — a longer R-CMD-check queue would have timed it out.

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine clean push (S726 precedent);
the CRAN check-time insight lives in the filed BACKLOG item (forward-carrying home, S686).

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~3 expected after close-out: filing `c9c946f7` +
records + sha; the last two are an estimate at write time). All docs-only; no urgency, they
ride the next push. (B) Priorities: CRAN check-time measurement (READY, M, owner-requested
S729, `BACKLOG.md:117` — measure first); pedigree-growth measurement (READY, S,
owner-requested S721); package-split disposition + REUSE registration (owner decisions);
BACKLOG.md editorial compression (READY, L); inst/doc slimming (DECISION NEEDED, M,
`BACKLOG.md:100`). (C) Standing report-only: HANDOFFS.md truncated duplicate S720 stub;
iCloud Housekeeping item closable pending confirmation; the owner's stale 19.7 MB
`../nprcgenekeepr_2.0.0.9000.tar.gz` + `../nprcgenekeepr.Rcheck/` outside the repo.

**Key files:** `BACKLOG.md:117` (new CRAN check-time item), `CHANGELOG.md` S729 entries,
`HANDOFFS.md` S729 receipt, run ids 35485603669/70/80/72 (the 4 green runs on `0572767b`).

**Gotchas for the next session:** (1) CI is now current through `0572767b` — only the ~3
close-out docs commits are unpushed; "expect 0 undocumented commits; measure it" at next
Phase 0. (2) The CRAN check-time item's test measurement must run WITHOUT `NOT_CRAN=true` —
the exact opposite of the Build/Test/Verify regression-read setting; don't blend the two
numbers. (3) Standing set unchanged from S728: `scratchpad/` invisible to git by owner
decision (`ls -d scratchpad` if in doubt); ratchet ~2 min, run AFTER committing (Learning
772); trim needs `--budget-bytes 65536`; renv banner expected; CLAUDE.md warn band; the two
`SESSION_NOTES.md` ceilings differ (owner decision pending); suite baseline 2437/0/0/184/0 —
now remote-confirmed again by R-CMD-check on `0572767b`.

### Session 727 Handoff Evaluation (by Session 728)
**Score: 9/10.** **What helped:** next step (A) WAS this session's deliverable, framed exactly
as the decision the Phase 0/1 pickers then posed (commit or discard the `.Rbuildignore` line);
the `BACKLOG.md:100` block was the execution plan verbatim — steps in order, verification
commands named (`tools:::inRbuildignore` + `git check-ignore`, S725 precedent), threshold
suggestion (<=5 MB) adopted as declared; the audit §7 recipe became the gate command nearly
verbatim; "~8 expected" unpushed measured exactly 8; "expect 0 undocumented; measure it"
measured 0 on both frontiers; gotcha (1) (dirty `.Rbuildignore`, not session-made, don't
touch) correctly shaped Phase 0. **What was missing:** nothing material — only that nobody had
checked whether the ratchet's timeout accommodates a build-based gate (one grep: 600 s, fits).
**What was wrong:** nothing found — every checked claim held, and the gate's clean-export
measurements (3,485,137 B at `f82f978a`; 3,485,027 B at `2570645b`) are consistent with the
audit's 3,485,185 B at `f8ffa40b` (drift = the docs-only commits in between). **ROI:** high.

### What Session 728 Did
**Deliverable:** Tarball build-hygiene follow-ups (`BACKLOG.md:100` steps 1–3) — **DONE.**
The owner's `^scratchpad$` `.Rbuildignore` line is committed (the 19.7 MB working-tree leak
closed); `scratchpad/` and the testthat debris (`tests/testthat/_problems/`,
`testthat-problems.rds`) are ignored in BOTH `.Rbuildignore` and `.gitignore`; and the
project's FIRST declared quality gate is live: `tarball_size_clean_export` (clean-export
`pkgbuild::build()` of `git archive HEAD`, max 5,000,000 B), measured in-session **1/1 pass
at 3,485,027 B** on the deliverable commit. Config/docs only — no `.R` files; TDD N/A;
lint N/A.
**Started/completed:** 2026-09-19 (single session). Claim `f82f978a`; deliverable `2570645b`;
records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per commit; the deliverable entry carries the numbers.

**What actually happened, in order:**
1. **Phase 0:** reconcile clean (0 undocumented on both frontiers; the sole `status: pending`
   grep hit is the HANDOFFS how-to text, not a receipt); CI 4/4 green on `9006b567`; dashboard
   96/100; context budget warn-band only; 8 unpushed as predicted; dirty `.Rbuildignore`
   reported, untouched.
2. **Owner decisions via pickers** (Phase 0 pick + one 3-question Phase 1 gate): pick the
   build-hygiene item; commit the edit; ALSO git-ignore `scratchpad/` (ghost-check tradeoff
   accepted); include the size gate.
3. **Edits:** `.Rbuildignore` +2 debris lines (:159–160) beside the owner's :155;
   `.gitignore` new block (:93–103); `.quality-gates.json` first gate (:17–27), command =
   audit §7 recipe printing a self-tagged `TARBALL_BYTES=` marker.
4. **Verification:** `git check-ignore -v` resolves all three paths to the new lines;
   `tools:::inRbuildignore` TRUE on each real path (directory matches prune contents — the
   semantics S727's 3.56 MB working-tree build measured); gate exercised twice (claim commit
   3,485,137 B; deliverable commit 3,485,027 B; both pass with ~1.5 MB headroom); `git status`
   untracked noise down to the 5 known planning/article files.
5. **BACKLOG:** completed block removed in the deliverable commit (S686 convention); step 4
   (optional `inst/doc` slimming) extracted as its own DECISION-NEEDED item at `BACKLOG.md:100`.

**Self-assessment (Session 728): 9/10.** **Strengths:** (1) all three embedded owner decisions
collected in ONE structured gate before the claim, so execution never stalled; (2) the gate was
exercised in-session twice, and the receipt cites the run at the shipped HEAD, not the claim
state; (3) scope held — no CI-workflow variant, no inst/doc slimming, nothing beyond the
approved three steps. **Weaknesses:** (1) "5 MB" was interpreted as decimal 5,000,000 B (the
audit's currency) without asking — documented in the gate's `unit`, but 5 MiB was equally
plausible; (2) the first ratchet run measured the claim state — harmless here (docs-only
claim) but the sequencing is now a Learning 772 caution; (3) every future close-out pays
~2 min of gate build time — approved, but the recurring cost lands on successors.

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~12 expected after close-out: 8 pre-existing +
claim + deliverable + records + sha; the last two are an estimate at write time). All
docs/config-only; the push also puts the first gate manifest on the remote. (B) Priorities:
pedigree-growth measurement (READY, S, owner-requested S721 — bounded at +1.07 MB total,
measure compressed from a clean build); package-split disposition (owner; size no longer
argues for it) + REUSE registration (owner action, S); BACKLOG.md editorial compression
(READY, L); the extracted inst/doc slimming item (DECISION NEEDED, M, `BACKLOG.md:100`).
(C) Standing report-only: HANDOFFS.md truncated duplicate S720 stub (two adjacent
`session: S720` blocks); iCloud Housekeeping item closable pending a duplicates-stay-gone
confirmation; the owner's stale 19.7 MB `../nprcgenekeepr_2.0.0.9000.tar.gz` +
`../nprcgenekeepr.Rcheck/` still sit outside the repo (delete/rebuild is the owner's call).

**Key files:** `.quality-gates.json:17` (the gate — name/threshold/command/why),
`.Rbuildignore:155-160` (scratchpad + debris lines), `.gitignore:93-103` (mirror block with
the tradeoff note), `BACKLOG.md:100` (extracted inst/doc item), `PROJECT_LEARNINGS.md`
Learning 772 (gate-author mechanics), `docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md` §7
(the recipe the gate command reuses).

**Gotchas for the next session:** (1) **`scratchpad/` no longer shows as untracked — by owner
decision, not by accident.** The Phase 0 untracked-file ghost-session check must remember the
directory still exists on disk (`ls -d scratchpad` if in doubt); it is now invisible to both
git and builds. (2) **`quality_ratchet.py --run` now takes ~2 min** (full package build with
vignettes) — not a hang; per-gate timeout is 600 s. Run it AFTER committing: the gate measures
`git archive HEAD` (Learning 772); never swap in `--no-build-vignettes`, which measures a
~38%-lighter artifact than the one CRAN gets. (3) The gate threshold is decimal 5,000,000 B;
thresholds only tighten — loosening is a plan-mode decision committed with `--no-verify`
(SAFEGUARDS Blast Radius). (4) Standing: every `methodology_trim.py` run needs
`--budget-bytes 65536`; `renv.lock` carries no dev tooling (`Rscript` banner expected);
CLAUDE.md in warn band (~1,640 B headroom) — narrative goes to `PROJECT_LEARNINGS.md`; the
two `SESSION_NOTES.md` ceilings still differ (56,750 B token cap binds before the 65,536 B
byte trigger — owner decision pending); suite baseline 2437/0/0/184/0 carries forward (no
code touched).

### Session 726 Handoff Evaluation (by Session 727)
**Score: 9/10.** **What helped:** the filed tarball item's measure-first mandate ("build the
real artifact and `tar tzvf` it; on-disk sizes mislead") WAS this session's method and led
straight to the answer; S726's own self-assessment flagged the ~19 MB headline as
"owner-reported, not measured" — exactly the claim that turned out to need refuting, so it
was approached as a hypothesis, not a fact; "~3 unpushed" measured 3; "expect 0 undocumented
commits; measure it" measured 0 on both frontiers; gotcha (1)'s "the `scratchpad/` NOTE
remains" was, in hindsight, the clue. **What was missing:** nobody (S721–S726) connected that
NOTE to the artifact — a top-level directory that check complains about is a directory that
ships; the item's remedy list was therefore built entirely around slimming package content.
**What was wrong:** the on-disk anchors (tests 3.4 MB, `inst/extdata` 5.3 MB) pointed at
data slimming, which measured compressed is worth almost nothing — low harm, because the
same item told the reader not to trust on-disk numbers. **ROI:** high.

### What Session 727 Did
**Deliverable:** Tarball-size audit — **DONE.**
[`docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md`](docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md).
**The "~19 MB tarball" is not package content: it is the untracked 20 MB `scratchpad/`
directory leaking into working-tree builds. A clean `git archive HEAD` build is
3,485,185 B (3.49 MB) — 35% of CRAN's 10 MB line** (CRAN 2.0.0 was 2,419,329 B). Research
only: no remedy applied, no `.R`/`.Rbuildignore`/`.gitignore` change, no TDD phases, lint N/A.
**Started/completed:** 2026-09-19 (single session). Claim `f8ffa40b`; deliverable `6d221ddc`;
close-out trim `1a5f345e`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per commit; the deliverable entry carries the numbers.

**What actually happened, in order:**
1. **Phase 0:** reconcile clean (0 undocumented on both frontiers); CI 4/4 green on the
   pushed sha `9006b567`; dashboard 96/100; context budget WARN-band only. **Dirty tree:** an
   uncommitted, not-session-made `.Rbuildignore` edit (`+^scratchpad$`). The Phase 0 picker
   (with a second question about that edit) was dismissed "to clarify"; the owner then
   replied with the pasted label "Tarball-size research" — taken as the pick. The dirty-file
   question was never answered, so the edit was left untouched all session.
2. **Three real builds** (all in the session scratch dir, via `pkgbuild::build()` run from
   the repo root so renv's library applies): working tree 3,564,041 B; clean HEAD export
   3,485,185 B; clean export + `scratchpad/` + testthat debris under the COMMITTED
   `.Rbuildignore` 19,714,510 B. Then found and inspected the owner's own artifact,
   `../nprcgenekeepr_2.0.0.9000.tar.gz` (19,732,245 B, built 20:14): 252 `scratchpad/`
   entries. Reproduction matches to 0.1%.
3. **Inventory:** 997 entries / 12.01 MB uncompressed; compressed shares by directory and a
   per-file `gzip -9` ranking. `inst/doc` is 38% of the tarball (three `html_document`
   vignettes); example/test data is cheap compressed. CRAN policy text verified at source
   (rev. 6875); installed size cross-checked against CI run 35481710058 (9.5–10.2 MB, `INFO`).
4. **Mid-session owner messages:** "note size of `../nprcgenekeepr_2.0.0.9000.tar.gz`"
   (already measured; it is the report's primary evidence) and "does this mean we need to add
   files and folders to rbuildignore?" — answered yes (the owner's pending line is the fix;
   two testthat-debris paths also warranted) and NOT acted on (a question is not an
   instruction; filed in the follow-up item).
5. **BACKLOG:** the Effort-L reduce-size item removed (premise refuted) and replaced by
   "Tarball build-hygiene follow-ups" (DECISION NEEDED, S) at `BACKLOG.md:100`; split item
   cross-ref rewritten (`:95`); pedigree-growth item given the +1.07 MB upper bound (`:140`).
6. **Close-out trim (`1a5f345e`):** this handoff pushed `SESSION_NOTES.md` to 57,111 B —
   over `context_budget.py`'s 25,000-token read cap (= 56,750 B at 2.27 B/token), which the
   pre-commit hook enforces, while `methodology_trim.py --budget-bytes 65536` still said
   NOTHING_TO_DO. Resolved with an explicit `--cut 5` (budget flag still passed; no
   `--force` needed): 10 records (S720–S724) to
   `docs/archive/SESSION_NOTES-through-2026-09-19-2.md`, L1/L2/L3 verified before and after
   commit. The trim ran on the committed pre-handoff state (the verify script anchors to
   the trim commit's parent), then this handoff was re-applied.

**Verification:** every headline number is a measured byte count from a built artifact, and
the explanation was tested by controlled reproduction, not inferred. Three draft claims in
the report were caught by a pre-commit fact-check and corrected (scratchpad file count
244→250; "~63 MB excluded"→43.5 MB measured; "leaking for weeks" re-anchored to the
2026-08-17 oldest-file date + empty `git log -S`). No code touched, so the suite baseline
2437/0/0/184/0 carries forward (Learning 764 scope rule). quality_ratchet and post-append
trim-trigger results: see the close-out `CHANGELOG.md` entry.

**Self-assessment (Session 727): 8/10.** **Strengths:** (1) refuted the item's premise by
measurement in the first 20 minutes instead of executing an Effort-L slimming campaign
against a non-problem; (2) closed the loop three ways — controlled reproduction, the owner's
actual artifact, and the local check log — rather than stopping at plausible arithmetic
(3.56 + 16.27 ≈ 19.8); (3) compressed-byte attribution overturned the item's own remedy
steer with numbers; (4) left the owner's uncommitted edit alone and answered the owner's
question without acting on it. **Weaknesses:** (1) the task pick rested on a terse pasted
label after a dismissed picker — reasonable and reversible (docs-only), but not an explicit
confirmation; (2) removing the owner-requested L item and substituting an S follow-up was
this session's judgment under the S686 convention — the owner may prefer otherwise; (3) the
`a2interactive.html` component breakdown was attempted with a sloppy regex that produced
nonsense (negative remainders) and was reported as "identified, not weighed" rather than
redone; (4) two Phase 0 shell fumbles (GNU vs BSD `stat`).

**Next steps (specific):** (A) **Owner decision first:** commit or discard the uncommitted
`.Rbuildignore` `+^scratchpad$` line — it is the fix (measured), and the follow-up item at
`BACKLOG.md:100` is blocked on it. Then that item's steps (2)–(4) in order; (2) is trivial
and can ride the same commit, verified with `tools:::inRbuildignore` + `git check-ignore`
on the real paths. (B) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~8 expected after close-out: 3 pre-existing +
claim + deliverable + trim + records + sha; the last two are an estimate at write time). All
docs-only. (C) Priorities after that: pedigree-growth measurement (READY, S — now bounded at
+1.07 MB total; measure compressed from a clean build); package-split disposition (owner —
size no longer argues for it) + REUSE registration; BACKLOG.md editorial compression
(READY, L). (D) Standing report-only: HANDOFFS.md truncated duplicate S720 stub (grep for
two adjacent `session: S720` blocks); iCloud Housekeeping item closable pending a
duplicates-stay-gone confirmation; the owner's stale 19.7 MB `../nprcgenekeepr_2.0.0.9000.tar.gz`
and `../nprcgenekeepr.Rcheck/` are outside the repo and were only read, never touched.

**Key files:** `docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md` (§1 build table, §2 inventory,
§3 findings, §7 reproduction commands), `BACKLOG.md:100` (follow-up item), `BACKLOG.md:95`
and `:140` (rewritten cross-refs), `.Rbuildignore:155` (the owner's UNCOMMITTED line),
`vignettes/a2interactive.Rmd:4-7` / `gvaConvergence.Rmd:6-8` / `simulatedKValues.Rmd:6-8`
(the `html_document` declarations behind Finding 3), `PROJECT_LEARNINGS.md` Learning 771.

**Gotchas for the next session:** (1) **The working tree is still dirty** (`.Rbuildignore`)
— not session-made; do not commit or discard it without the owner's word. Until it is
committed, a working-tree build from a checkout WITHOUT that line is 19.7 MB again.
(2) **Never measure the tarball from the working tree** — use the §7 clean-export recipe;
`pkgbuild::build()` must be launched from the repo root (renv library) even when building
an export elsewhere. (3) The `html_vignette` saving in Finding 3 is an estimate, and
`df_print: paged` does not exist under `html_vignette` — that slice needs its own
before/after build measurement. (4) Standing: every `methodology_trim.py` run needs
`--budget-bytes 65536`; `renv.lock` carries no dev tooling (`Rscript` out-of-sync banner
expected); CLAUDE.md sits in the warn band (~1,640 B headroom) — new narrative goes to
`PROJECT_LEARNINGS.md`. (5) Full-suite baseline unchanged: 2437/0/0/184/0. (6) **The two `SESSION_NOTES.md`
ceilings are NOT the same number in practice:** the token cap binds at 56,750 B, the byte
trigger at 65,536 B, and in the gap the hook refuses growth while the trimmer reports
NOTHING_TO_DO. `CLAUDE.md`'s "deliberately the same number" sentence holds for `max_bytes`
only (`.context-budget.json`'s own note says `max_tokens` binds first) — report-only here (owner decision: lower the trim budget to 56,750, or keep using
an explicit `--cut N`). With ~8 KB handoffs this recurs roughly every 4–5 sessions.

### Session 725 Handoff Evaluation (by Session 726)
**Score: 9/10.** **What helped:** the priorities list mapped one-for-one onto this session's
Phase 0 picker (push decision surfaced as the owner's actual pick); the ~31-unpushed
prediction + the post-close-out addendum's own ledger note reconciled exactly to the
measured 32; "expect 0 undocumented commits; measure it" measured 0 on the CHANGELOG
frontier, and the one commit past the HANDOFFS frontier was the addendum itself, carrying
its own ledger entry — reconcile closed as a no-op in minutes; the warn-band CLAUDE.md
gotcha correctly framed this session's context-budget WARN as headroom, not a finding.
**What was missing:** nothing material. **What was wrong:** gotcha (3)'s "the stray `~$e
Compounding Loop.html` still makes `devtools::check()` warn" was already superseded at
write time + one commit — S725's own post-close-out addendum (`89b14d1b`) deleted the file
and added standing guards; the addendum's ledger entry self-corrects this, so zero harm.
**ROI:** high.

### What Session 726 Did
**Deliverable:** Owner-directed push to `origin/master` + CI verification — **DONE.**
Pushed `4565c39d..9006b567` (33 commits: the 32 pre-existing S720–S725 commits + the S726
claim), and all 4 push-triggered workflows completed green ON THE PUSHED SHA `9006b567`:
R-CMD-check 31m53s, pkgdown 13m47s, test-coverage 10m4s, lint 4m37s. This is the FIRST
remote validation of the S720–S725 work: the S724 warning-free suite (CI's R-CMD-check runs
it), the S721 Suggests trim + renv re-snapshot, the S720 context-budget adoption, the S725
CLAUDE.md reduction, and the S725 `~$`-guard additions. No TDD phases (no `.R` files
touched; push + docs). Lint N/A.
**Started/completed:** 2026-09-19 (single session). Claim `9006b567` (rode the push, so CI
ran on it — S717 precedent); mid-session BACKLOG filing `f8970edc`; records + sha commits
follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, BACKLOG filing, close-out, sha).

**Mid-session owner request (filed, not acted on — 1-and-done, S721 precedent):**
tarball-size-reduction item added to `BACKLOG.md` Up Next (`f8970edc`, READY, Effort L):
owner reports ~19 MB source tarball vs CRAN's ≤10 MB policy; owner steer that slimming
examples/test data may beat the package split. Item mandates measure-first (`R CMD build`
+ `tar tzvf` inventory — on-disk sizes mislead because `.Rbuildignore` already excludes
`docs/`, `vignettes/articles/`, and several reference files), carries S726 on-disk anchors
(`inst/extdata/` 5.3 MB, vignette HTMLs ~4.3 MB, `tests/` 3.4 MB), and cross-references
the package-split item (S667 rec "do not split now", owner disposition pending) and the
pedigree-growth measurement item both ways.

**Verification:** push confirmed (`master` even with `origin/master` post-push;
`git rev-list --count` 33 at push time); CI 4/4 `completed success` filtered on
`headSha == 9006b567` exactly (not just "latest runs green"); quality_ratchet: 0/0 pass ·
0 fail · 0 unmeasured · results 4f53cda18c2b · manifest 4f53cda18c2b. Post-append trim
triggers (`--budget-bytes 65536`): none fire on SESSION_NOTES/HANDOFFS/CHANGELOG.

**Self-assessment (Session 726): 9/10.** **Strengths:** (1) CI verification pinned to the
exact pushed sha via `--jq` filter on `headSha`, not eyeballed from the run list; (2) the
mid-session owner request was filed with a measure-first mandate that caught the
on-disk-vs-tarball misdirection (`.Rbuildignore` excludes the two biggest trees) before it
could send the future session chasing the wrong 60 MB; (3) no scope creep — the filed item
was not started. **Weaknesses:** (1) the ~19 MB tarball figure is recorded as
owner-reported, not measured in-session (deliberate — a full `R CMD build` mid-push-session
wasn't worth the wall time, but the item's headline number is unverified until the research
session builds the artifact); (2) one harness fumble — the first CI wait used a blocked
sleep-chain form and had to be redone as a background poller.

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine clean push; the
tarball-inventory insight lives in the filed BACKLOG item (its forward-carrying home per
the S686 convention).

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~3 expected after close-out: BACKLOG filing
`f8970edc` + records + sha; the last two are an estimate at write time). All 3 are
docs-only; no urgency, they ride the next push. (B) Priorities: tarball-size-reduction
research (READY, L, owner-requested S726 — measure first); pedigree-growth measurement
(READY, S, owner-requested S721 — feeds the tarball item); package-split disposition +
REUSE registration (owner decisions pending); BACKLOG.md editorial compression (READY, L).
(C) Standing report-only: HANDOFFS.md truncated duplicate S720 stub (grep for two adjacent
`session: S720` blocks); iCloud Housekeeping item closable pending a duplicates-stay-gone
confirmation.

**Key files:** `BACKLOG.md` Up Next tail (the new tarball item + the split item's new
cross-ref line), `CHANGELOG.md` S726 entries, `HANDOFFS.md` S726 receipt,
`.github/workflows/` (unchanged — the 4 green runs are ids 35481709978–35481710058).

**Gotchas for the next session:** (1) **The `devtools::check()` warn/exit-1 gotcha should
now be CLEARED** — S725's addendum deleted the `~$` lock file and added standing guards;
the next local check run should confirm (0 errors expected; the `scratchpad/` NOTE
remains). If a `~$*` file reappears, the guards make it invisible to both git and
`R CMD build`. (2) CI is now current through `9006b567` — only the ~3 close-out docs
commits are unpushed; "expect 0 undocumented commits; measure it" at next Phase 0.
(3) Standing: every `methodology_trim.py` run needs `--budget-bytes 65536`; `renv.lock`
carries no dev tooling (`Rscript` out-of-sync banner expected); CLAUDE.md sits in the warn
band with ~1,640 B headroom — new adaptation narrative goes to `PROJECT_LEARNINGS.md`.
(4) Full-suite baseline unchanged (no test-read files touched): 2437/0/0/184/0 — and now
remote-confirmed by R-CMD-check on `9006b567`.

### Session 724 Handoff Evaluation (by Session 725)
**Score: 9/10.** **What helped:** the priorities list matched this session's Phase 0
picker one-for-one, and the picked item's own BACKLOG block WAS the plan (excess
location, remedies in order, keep-intact list — all accurate); the ~27-unpushed-commits
prediction measured exactly 27; "expect 0 undocumented commits; measure it" measured 0;
standing gotcha (4)'s "context-budget reds by design until the CLAUDE.md reduction
campaign" framed the target precisely, and the trim-budget/`~$e`-file/renv-banner
gotchas all held. **What was missing:** nothing material. **What was wrong:** nothing
found — every checked claim held. **ROI:** high.

### What Session 725 Did
**Deliverable:** `CLAUDE.md` reduction campaign — **DONE.** 43,348 B → 26,360 B, under
the 28,000 B `.context-budget.json` ceiling (17 KB cut; warn band ≥24,000 B is
documented headroom, not a defect). Method per the BACKLOG item: each Adaptations block
classified sentence-by-sentence into operative rule vs incident narrative; rules kept
(verbatim or tightened) with origins compressed to Learning pointers; narrative existing
nowhere else moved to `PROJECT_LEARNINGS.md` **Learning 770** (the relocation record:
S545 rejected alternatives, S436 origin, NEWS.Rmd drift history, `methodology_trim.py`
provenance, the S325/S546/S547 legacy-history decision chain, and the reduction method
itself); full pre-reduction text archived as `git show 1ef168b8:CLAUDE.md`. Kept intact:
SESSION PROTOCOL header, `budget:protected` Project Overview fence, TDD contract,
Build/Test/Verify. BACKLOG item removed in the deliverable commit. No TDD phases
(docs-only, S720–S724 precedent); lint N/A (no `.R` files).
**Started/completed:** 2026-09-19 (single session). Claim `1ef168b8`; deliverable
`c8512d0d`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per commit; the deliverable entry carries the full
method + verification record.

**Verification:** `wc -c CLAUDE.md` = 26,360 B; `python3 context_budget.py` = no file
over its ceiling (resident 26,360/34,000, `budget:protected` fence intact); every
Learning number cited by a new pointer grep-verified present (382/433/435/475/477/478/
479/495/506/533/544/547/549/554/586/587/669/740); `grep -c '^#### Learning '` = 770,
matching the new record's number; all in-file "above" cross-references re-read and
resolving; no test reads the 4 touched `.md` files (grep-verified: all matches are
comments/strings), so the S724 suite baseline 2437/0/0/184/0 carries forward
legitimately under Learning 764's scope rule. quality_ratchet: 0/0 pass · 0 fail · 0
unmeasured · results 4f53cda18c2b · manifest 4f53cda18c2b. Trim triggers post-append
(`--budget-bytes 65536`): none fire on SESSION_NOTES/HANDOFFS/CHANGELOG.

**Self-assessment (Session 725): 9/10.** **Strengths:** (1) every relocated narrative's
destination verified before the pointer was written — nothing points at a Learning that
doesn't hold the content; (2) caught two sentences the reduction itself falsified and
updated them in the same pass (the context-budget check's expected state; the trilogy's
"no file has moved yet"); (3) the first draft of the new expected-state sentence claimed
"all green" — measurement (warn at 26,360 B) corrected it to "no file over its ceiling"
before commit. **Weaknesses:** (1) landed in the warn band rather than under 24,000 B —
the remaining large block (the Build/Test/Verify regression-read narrative) was
explicitly on the item's keep-intact list, so deeper cutting needs an owner decision;
(2) growth headroom is only ~1,640 B before red.

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~31 expected after close-out: 27 pre-existing
+ claim + deliverable + records + sha; the last two are an estimate at write time).
(B) Priorities: pedigree-growth measurement (READY, S, owner-requested S721); owner
decisions pending: package-split disposition, REUSE registration; BACKLOG.md editorial
compression (READY, L). (C) Standing report-only: HANDOFFS.md truncated duplicate S720
stub (grep for two adjacent `session: S720` blocks); iCloud Housekeeping item closable
pending a duplicates-stay-gone confirmation.

**Key files:** `CLAUDE.md` (whole Adaptations section reshaped; overview/TDD/BTV
untouched), `PROJECT_LEARNINGS.md` tail (Learning 770), `BACKLOG.md` (campaign item
removed), `CHANGELOG.md` S725 entries.

**Gotchas for the next session:** (1) **CLAUDE.md is now under ceiling but in the warn
band — any growth commit trips the pre-commit hook's relative rule; put new adaptation
narrative in `PROJECT_LEARNINGS.md` and keep only the rule + pointer in `CLAUDE.md`**
(the Learning 770 method, recorded there as point 6). (2) The context-budget expected
state changed: reds are no longer "by design" — a `CLAUDE.md` red is now a finding.
(3) Standing: every `methodology_trim.py` run needs `--budget-bytes 65536`; the stray
`~$e Compounding Loop.html` still makes `devtools::check()` warn and exit 1
non-interactively; `renv.lock` carries no dev tooling (`Rscript` out-of-sync banner
expected). (4) Full-suite baseline unchanged this session (no test-read files touched):
2437/0/0/184/0.

