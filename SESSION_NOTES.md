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

**Archived 14 record(s), 2026-09-19 → 2026-09-19** into [`docs/archive/SESSION_NOTES-through-2026-09-19-3.md`](docs/archive/SESSION_NOTES-through-2026-09-19-3.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-09-19-3.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-19-3.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 12 record(s), 2026-09-20 → 2026-09-20** into [`docs/archive/SESSION_NOTES-through-2026-09-20.md`](docs/archive/SESSION_NOTES-through-2026-09-20.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-09-20.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-20.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 13 record(s), 2026-09-02 → 2026-09-20** into [`docs/archive/SESSION_NOTES-through-2026-09-20-2.md`](docs/archive/SESSION_NOTES-through-2026-09-20-2.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-09-20-2.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-20-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

---

## ACTIVE TASK

### Session 745 Handoff Evaluation (by Session 746)
**Score: 9/10.** **What helped:** "10 unpushed (recount)" measured exactly 10;
"expect 0 undocumented; measure it" measured 0 on both frontiers at `41c43c35`;
the growth-run prediction (22/10) was exact; the ratchet-table-rounds gotcha
paid off twice — this session's own table showed 3.48894e+06 where the results
file says 3,488,944, exactly the trap; the D-3 guidance was the execution plan
as written (`grep -c "^#'"` = 0 re-verified still true; PRE-RED→REFACTOR gate
posed before editing, as instructed). **What was missing:** nothing material.
**What was wrong:** nothing found — every checked claim held. **ROI:** high.

### What Session 746 Did
**Deliverable:** Prep D-3 — **DONE** (deliverable commit `a5a9bf42`). All 13
functions in `R/positionTreeApportion.R` now carry `@noRd` roxygen blocks
(title + `@param` + `@return` + `@noRd`, matching `R/shrinkPedigree.R`'s
internal-doc house style). Diff mechanically proven comment-only: exactly 160
added `#'` lines, 0 deletions, no code touched, no line over 80 chars.
REFACTOR-only (owner-gated PRE-RED→REFACTOR via AskUserQuestion with the exact
edits; the RED/GREEN-skipping mapping was already owner-ratified in the BACKLOG
tag). **Started/completed:** 2026-09-21 (single session). Claim `19de9c64`;
deliverable `a5a9bf42`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, deliverable, records,
sha). BACKLOG D-3 item REMOVED in the deliverable commit (completed-item
checklist); the kinship2-standalone item's blocker updated to the S738 revisit
conditions ONLY (prep steps ALL DONE: D-1 S744, D-2 S745, D-3 S746), with the
D-3 fact and prep-origin context carried forward into the item.

**What actually happened, in order:**
1. **Phase 0:** full 8-step orient; reconcile clean (0 undocumented on both
   frontiers at `41c43c35`; S745 receipt complete, its ratchet citation matches
   `.quality-gates-results.json` byte-for-byte); CI 10/10 green but current
   only through S743's push; 10 unpushed measured; dashboard 96/100; context
   budget WARN = CLAUDE.md warn band, growth run 22/10; 5 known untracked
   files unchanged; no live sequencing-audit cluster.
2. **Owner picked D-3** via the Phase 0 picker (over push+CI, BACKLOG
   compression, inst/doc slimming); claim `19de9c64`.
3. **Research before the gate:** workstream doc read; the full 277-line file
   read end-to-end; 13 function definitions confirmed; `grep -c "^#'"` = 0
   re-verified; house style sampled from `R/shrinkPedigree.R`; **the iCloud
   duplicate files (`R/appServer 2.R`, `R/modMarkerGenetics 2.R`) confirmed
   GONE from `R/`** — so the S461 `devtools::document()` corruption trap did
   not apply to this session's verification plan.
4. **PRE-RED→REFACTOR gate:** approved with the exact edits + verification
   plan spelled out (the alternative offered: review all 13 block texts in
   chat first).
5. **REFACTOR:** 13 blocks written; diff verified comment-only mechanically
   (grep on the diff's `+` lines: 1 non-`#'` line = the `+++` header).
6. **Verification:** `devtools::document()` byte-identical no-op on `man/` +
   `NAMESPACE` (correct outcome — `@noRd` generates nothing);
   `test_positionTreeApportion.R` passes; full silent suite **0 failed /
   0 error / 184 skipped** (7054 passed); lint 0 on the touched file
   (package loaded first).
7. **Close-out:** no NEWS.Rmd entry owed (no exported function, no
   user-facing change — checklist consulted, not skipped); no WORDLIST risk
   (`@noRd` text never reaches `.Rd`/vignettes, so the spelling gate cannot
   see it); ratchet AFTER the deliverable commit (Learning 772): 1/1 pass ·
   results b7c4dc700aa7 · manifest aa983075d6a2 (3,488,944 B ≤ 5,000,000 B at
   `a5a9bf42`, read from the results FILE — the run table rounded to
   3.48894e+06, re-confirming the S745 gotcha). Tarball grew +2,386 B vs
   S745's 3,486,558 B: the roxygen comments ride in the `R/` sources —
   expected, not a defect.

**Self-assessment (Session 746): 9/10.** **Strengths:** (1) the
comment-only claim is a measurement, not an assertion (diff `+`-line grep);
(2) the `document()` no-op check turned "docs hygiene" into a mechanically
verifiable outcome, and the iCloud-dup pre-check protected it; (3) scope held
exactly (no code edits, no export changes, no drive-by fixes); (4) both the
Phase 0 picker and the phase gate ran as structured questions.
**Weaknesses:** (1) **FM #28 reduction: none this session** — BACKLOG.md net
0 lines (8-line D-3 block removed but equal bytes carried forward into the
kinship2 item); no mandated-read file got smaller — said plainly per the
degradation-detection row, not left unsaid; (2) roxygen prose accuracy rests
on my reading of the code, not on any gate — a wrong `@param` description
would fail no test (mitigated by the full-file read and the engine's
exact-value oracle tests, but it is documentation, not proof).

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine clean REFACTOR
session (S745 precedent); the durable record is the CHANGELOG entries + the
code.

**Next steps (specific):** (A) **Push + CI verification is now overdue as the
top routine pick** (S726–S743 precedent): 14 unpushed expected after close-out
(recount with `git rev-list --count origin/master..HEAD`), and THREE
deliverable commits (`44bb4481` R/+tests, `eb896c2e` tests, `a5a9bf42` R/
comment-only) have never been seen by CI — expect R-CMD-check inside the
17m39s–22m17s band; smoke-test the FULL-40-char-sha `--commit` filter against
in-flight runs BEFORE arming any monitor. (B) **kinship2-standalone item is
now blocked on the S738 revisit conditions ONLY** (engine churn calms + an
accepted CRAN release) — NOT a routine pickup; when the owner judges the
conditions met, the pickup is a planning session (`docs/planning/` boundary
doc, evidence-based inventory; ratified scope already in the BACKLOG item).
(C) **iCloud-duplicate Housekeeping item is now closable-on-confirmation:**
the 2 duplicate `.R` files are gone from `R/` (verified this session); the
item's own text says confirm non-reappearance and close — a future session
should re-check `ls R/ | grep ' 2\.'` and, if still clean after local
rebuilds, close the item (Effort XS). (D) Others unchanged: BACKLOG editorial
compression (READY, L); inst/doc slimming (DECISION NEEDED, M); REUSE
registration (owner action, S); NPRC outreach (owner review).

**Key files:** `R/positionTreeApportion.R` (13 `@noRd` blocks, file now 437
lines), `BACKLOG.md:71` (kinship2 item, blocker + prep-context updated),
`CHANGELOG.md:41` (S746 entries at top), `HANDOFFS.md` (S746 receipt).

**Gotchas for the next session:** (1) Expect 0 undocumented commits at next
Phase 0 — measure it; 14 unpushed expected after close-out (recount).
(2) **Cite the ratchet's measured value from `.quality-gates-results.json`,
never the run table** — confirmed AGAIN this session (table 3.48894e+06 vs
file 3,488,944). (3) The tarball baseline is now 3,488,944 B (grew +2,386 B
with the roxygen — expected); don't read the delta as a regression.
(4) Standing set unchanged: `gh run list --commit` needs the FULL 40-char
sha + smoke-test the filter before arming a monitor; `scratchpad/` invisible
to git BY OWNER DECISION; ratchet AFTER committing (Learning 772); trim needs
`--budget-bytes 65536`; renv banner expected; CLAUDE.md warn band; growth run
22/10 (23/10 next if nothing shrinks — measure, don't predict); the two
`SESSION_NOTES.md` ceilings differ (owner decision pending); suite baseline
0 failed / 0 error / 184 skipped re-confirmed locally on `a5a9bf42` — remote
confirmation for all THREE unpushed deliverables lands with the next push.

### Session 744 Handoff Evaluation (by Session 745)
**Score: 9/10.** **What helped:** "~6 unpushed (recount)" measured exactly 6;
"expect 0 undocumented; measure it" measured 0 on both frontiers at `d1a34d0d`;
the growth-run prediction (21/10) was exact; the D-2 guidance was the execution
plan as written — `:1669`/`:1706` were both still current, and "agree the
RED/GREEN phase mapping with the owner at the gate before writing anything"
was exactly the right call (owner ratified REFACTOR-only); the
CI-not-current-for-new-code flag fed the Phase 0 report directly. **What was
missing:** nothing material. **What was wrong:** one immaterial slip — the
receipt's ratchet citation transcribed the measured size as 3,486,350 B where
`.quality-gates-results.json` says 3,486,353 B (all hashes matched, so the
gate outcome is unaffected; mechanism identified this session: the ratchet
table DISPLAYS a rounded value — cite from the results file, not the table).
**ROI:** high.

### What Session 745 Did
**Deliverable:** Prep D-2 — **DONE** (deliverable commit `eb896c2e`). The two
test-only reaches into the internal `.buildMatingUnitForest()` in
`tests/testthat/test_modPedigree.R` (were `:1669`/`:1706`, both re-verified
current before editing) are rewritten through `makePedigreeMatingLayout()`'s
exported surface: the union-click no-op test now takes
`grep("^__union_", layout$nodes$id, value = TRUE)[1L]` (the `^` anchor
matters — waypoint ids like `__drop___union_1` contain but don't start with
the prefix), and the duplicate-click test uses `duplicateToReal` for
length/id/realId. Zero functional `.buildMatingUnitForest` calls remain
outside the layout core's own test files (S667 §2.4/D6 closed). No production
code touched; no new exports. **Phase mapping (owner-ratified via
AskUserQuestion): REFACTOR-only** — same mapping as D-3; chosen over a
RED→GREEN boundary-guard meta-test and over a new exported accessor. Two
gates ran (approach; PRE-RED→REFACTOR with exact planned edits).
**Started/completed:** 2026-09-21 (single session). Claim `d6dc0852`;
deliverable `eb896c2e`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, deliverable, records,
sha). BACKLOG D-2 item consumed and REMOVED in the deliverable commit
(completed-item checklist); the BLOCKED kinship2-build item's blocker updated
to D-3 only (D-1 DONE S744, D-2 DONE S745), with the D-2 boundary fact
carried forward into the item.

**What actually happened, in order:**
1. **Phase 0:** full 8-step orient; reconcile clean (0 undocumented on both
   frontiers at `d1a34d0d`; S744 receipt complete except the 3-byte measured-
   size transcription slip noted above — hashes matched, report-only); CI
   10/10 green but current only through `59f1888e` (S744's `44bb4481`
   unpushed); dashboard 96/100; context budget WARN = CLAUDE.md warn band,
   growth run 21/10; 6 unpushed measured; 5 known untracked files unchanged;
   no live sequencing-audit cluster.
2. **Owner picked D-2** via the Phase 0 picker (over push+CI, D-3, BACKLOG
   compression); claim `d6dc0852`.
3. **Research before any gate:** workstream doc read; both reaches re-read in
   place (`:1669` needs a union node id to click; `:1706` needs the dup
   id→realId pair); `makePedigreeMatingLayout()`'s return contract read; then
   **equivalence proven empirically before editing** — on the fixture, the
   public return's union-id set and `duplicateToReal` mapping are identical
   to the internal forest's (`setequal` TRUE, mapping `identical` TRUE).
4. **Approach gate:** owner chose REFACTOR-only (recommended) over the
   boundary-guard RED→GREEN framing and the exported-accessor option.
5. **PRE-RED→REFACTOR gate:** approved with the exact edits spelled out.
6. **REFACTOR:** the two blocks rewritten (+ short boundary comments);
   grep confirms 0 functional reaches remain in `test_modPedigree.R`; full
   file passes; full silent suite **0 failed / 0 error / 184 skipped**
   (7054 passed); lint 0 on the touched file (package loaded first).
7. **Close-out:** no NEWS.Rmd entry owed (no exported function, no
   user-facing change — checklist consulted, not skipped); ratchet AFTER the
   deliverable commit (Learning 772): 1/1 pass · results cb8622ee3020 ·
   manifest aa983075d6a2 (3,486,558 B ≤ 5,000,000 B at `eb896c2e`, figure
   read from the results FILE, not the rounded table display).

**Self-assessment (Session 745): 9/10.** **Strengths:** (1) equivalence was a
measurement, not an assumption — the fixture-level identity check ran before
any edit; (2) both gates ran as structured questions with exact planned
actions; (3) scope held exactly (no guard test, no accessor, no production
code); (4) FM #28 reduction: BACKLOG.md net −3 lines; (5) the S744 ratchet
transcription slip was root-caused (rounded table display) and the
countermeasure applied in-session. **Weaknesses:** (1) REFACTOR-only means no
new failing-test proof — correctness rests on the pre-edit equivalence
measurement plus the suite staying green (deliberate, owner-ratified, but a
weaker proof shape than D-1's bypass tests); (2) the union-test boundary
comment is 4 lines — borderline density for a test file.

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine clean REFACTOR
session; the durable record is the CHANGELOG entry + the code. **Reduction
check (FM #28):** BACKLOG.md net −3 lines (7-line D-2 block removed; +4 lines
of blocker/boundary updates) AND `SESSION_NOTES.md` trimmed 61,388 → 13,607 B
— two mandated-read files got smaller.

**Trim (rode the records commit):** the records commit was REFUSED by the
context-budget pre-commit hook (`SESSION_NOTES.md` would have hit 27,043 tok
vs the hook's 25,000-tok ceiling — the known "two ceilings differ" situation;
the byte budget was fine). Resolution: `methodology_trim.py --cut 3
--budget-bytes 65536 --force --write` (SRF_RED fired as the standing gotcha
predicts; `--force` is the established owner-ratified resolution, Learnings
549/586/587). 13 records → `docs/archive/SESSION_NOTES-through-2026-09-20-2.md`;
L1/L2/L3 verified via the shard's verify script with ONE expected exception —
the frontier record (the S745 claim stub, committed at `d6dc0852`) was
overwritten in place by this very handoff, the accepted BL-27 close-out-bundle
pattern; manually diffed per the script's NOTE and confirmed a stub finalize,
not data loss. The trimmer's own `[ad hoc]` CHANGELOG entry rides the same
commit.

**Next steps (specific):** (A) **Push + CI verification is now the top
routine pick** (S726–S743 precedent): 10 unpushed after close-out (8 measured
post-deliverable + records + sha, last two estimated at write time — recount
with `git rev-list --count origin/master..HEAD`), and TWO code deliverables
(`44bb4481` R/+tests/, `eb896c2e` tests/) have never been seen by CI — expect
R-CMD-check inside the 17m39s–22m17s band; smoke-test the FULL-40-char-sha
`--commit` filter against in-flight runs BEFORE arming any monitor.
(B) **Prep D-3 is the last prep step** (READY, S, REFACTOR-only): `@noRd`
roxygen blocks for `R/positionTreeApportion.R`'s 13 functions (`grep -c "^#'"`
= 0 verified S738, not re-verified S745). When D-3 lands, the kinship2-build
item's prep-step blocker is fully cleared (the S738 revisit-condition gates
remain). (C) Other priorities unchanged: BACKLOG editorial compression
(READY, L); inst/doc slimming (DECISION NEEDED, M); REUSE registration (owner
action, S); NPRC outreach (owner review).

**Key files:** `tests/testthat/test_modPedigree.R:1668-1691` (union-click
rewrite), `:1710-1730` (duplicate-click rewrite), `BACKLOG.md:71` (D-3 now the
first prep item), `CHANGELOG.md:41` (S745 entries at top), `HANDOFFS.md` (S745
receipt).

**Gotchas for the next session:** (1) Expect 0 undocumented commits at next
Phase 0 — measure it; 10 unpushed after close-out (recount). (2) **Cite the
ratchet's measured value from `.quality-gates-results.json`, never from the
run table** — the table rounds (3.48656e+06 vs 3,486,558), which is exactly
how S744's receipt picked up its 3-byte slip. (3) A D-3 pickup is
REFACTOR-only by its own BACKLOG tag (no RED/GREEN), but it is still a
phase-gated session — pose the PRE-RED→REFACTOR gate before editing.
(4) Standing set unchanged: `gh run list --commit` needs the FULL 40-char
sha + smoke-test the filter before arming a monitor; `scratchpad/` invisible
to git BY OWNER DECISION; ratchet ~2 min AFTER committing (Learning 772);
trim needs `--budget-bytes 65536`; renv banner expected; CLAUDE.md warn band;
growth run 21/10 (22/10 next if nothing shrinks — measure, don't predict);
the two `SESSION_NOTES.md` ceilings differ (owner decision pending); suite
baseline 0 failed / 0 error / 184 skipped locally re-confirmed this session
on `eb896c2e` — remote confirmation for BOTH code deliverables lands with the
next push's R-CMD-check.

### Session 743 Handoff Evaluation (by Session 744)
**Score: 9/10.** **What helped:** "2 unpushed (recount)" measured exactly 2;
"expect 0 undocumented; measure it" measured 0 on both frontiers at `c0eaef65`;
the ratchet citation matched `.quality-gates-results.json` byte-for-byte; the
growth-run prediction ("20/10 next if nothing shrinks") was exact; D-1 was the
handoff's named natural code pickup and was the owner's pick; its D-1-specific
guidance (re-verify `R/makePedigreeDiagramData.R:1755` first; full TDD gates
with AskUserQuestion at every transition) was the execution plan as written —
`:1755` was still current, and all four gates ran. **What was missing:**
nothing material. **What was wrong:** nothing found — every checked claim held.
**ROI:** high.

