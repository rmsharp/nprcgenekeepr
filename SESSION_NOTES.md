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

---

## ACTIVE TASK

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

### What Session 744 Did
**Deliverable:** Prep D-1 — **DONE** (deliverable commit `44bb4481`).
`makePedigreeMatingLayout()` gained an optional `kinshipMatrix` argument
(`R/makePedigreeDiagramData.R:1685` signature, `:1785` injection branch): a
precomputed kinship matrix (base matrix or Matrix, dimnames = ids) replaces the
internal `kinship()` call as the SOLE consanguinity source; default `NULL`
computes `kinship(ped$id, ped$sire, ped$dam, ped$gen, twinRelations =
twinRelations)` byte-identically, so no caller changes — the layout core's one
genetics back-reference is now injectable (scoping doc §4 D3 option ii; step 0
of the committed kinship2 standalone package). Full TDD cycle, every gate
owner-approved via AskUserQuestion: approach (`kinshipMatrix = NULL` over
pair-flags/`kinshipFn`), PRE-RED→RED, RED→GREEN, GREEN→REFACTOR.
**Started/completed:** 2026-09-20 (single session). Claim `1dc5d9bd`;
deliverable `44bb4481`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, deliverable, records,
sha). BACKLOG D-1 item consumed and REMOVED in the deliverable commit
(completed-item removal checklist); the BLOCKED kinship2-build item's blocker
line updated to D-2/D-3 (D-1 DONE S744) with the boundary pointer carried
forward into the item.

**What actually happened, in order:**
1. **Phase 0:** full 8-step orient; reconcile clean (0 undocumented on both
   frontiers at `c0eaef65`; S743 receipt complete; ratchet citation matched the
   results file); CI 10/10 green (latest 4 on `59f1888e`); dashboard 96/100;
   context budget WARN = CLAUDE.md warn band, growth run 20/10 (as S743
   predicted); 2 unpushed measured (= S743's estimate); 5 known untracked files
   unchanged; no live sequencing-audit cluster.
2. **Owner picked D-1** via the Phase 0 picker; claim `1dc5d9bd`.
3. **Research before RED:** workstream doc read; call site + twinRelations
   comment block re-verified current at `:1755/:1741-1754`; one production
   caller confirmed (`R/modPedigree.R:642`); scoping doc D3 re-read; kinship()
   return classes checked live (dense = base matrix, sparse = dgCMatrix,
   `inherits(x, "Matrix")` TRUE only for the latter — validation covers both).
4. **Approach gate:** owner chose `kinshipMatrix = NULL` (recommended) over
   pair-flags and `kinshipFn`.
5. **RED:** 7 tests appended (`test_makePedigreeMatingLayout.R:1689+`):
   identity-vs-default on the loop fixture; bypass proof (all-zero matrix
   suppresses the genuine 8LKBV9×FJIB3R marker); injected-marker proof (marks a
   pair the default never would); partial-matrix safe FALSE (dam dropped from
   dimnames); invalid-input errors (no dimnames, non-matrix); twinRelations
   interplay (connectors still render, zero matrix wins over twin-threaded
   kinship); issue-#164 all-isolated empty contract with matrix supplied.
   Confirmed failing on `unused argument` with all 222 pre-existing passing.
6. **GREEN:** signature + up-front validation + injection branch + roxygen
   `@param`; `devtools::document()` touched only `man/makePedigreeMatingLayout.Rd`.
   File 243/0/0; full silent regression read 0 failed / 0 error / 184 skipped.
7. **REFACTOR:** 0 lints on both touched files (package loaded first); no
   edits needed — recorded as a pass that found nothing.
8. **Close-out:** NEWS.Rmd plain-language entry (Pedigree Diagram section);
   runtime smoke = script-level both-paths-agree on shipped `smallPed`
   (`identical(injected, default)` TRUE, 27 nodes / 26 edges); ratchet AFTER
   the deliverable commit (Learning 772): 1/1 pass · results bd0b6b4bcfcf ·
   manifest aa983075d6a2 (3,486,350 B ≤ 5,000,000 B at `44bb4481`).

**Self-assessment (Session 744): 9/10.** **Strengths:** (1) the bypass is
proven behaviorally (zero-matrix test), not asserted; (2) the identity test
plus the full-suite read make "no caller changes" a measurement, not a claim;
(3) all four TDD gates ran as structured questions with exact planned actions;
(4) the 5-file per-commit cap held by moving NEWS.Rmd to the records commit;
(5) FM #28 reduction: BACKLOG.md net −7 lines. **Weaknesses:** (1) runtime
smoke is script-level, not a full Shiny launch — justified (the app's call
site passes no `kinshipMatrix`, and the default path is proven identical) and
stated rather than hidden; (2) REFACTOR produced no edits — the phase ran but
was thin; (3) the roxygen `@param` is long — parameter docs are drifting
toward CLAUDE.md-style density.

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine clean TDD session;
the durable record is the CHANGELOG entry + the code. **Reduction check
(FM #28):** BACKLOG.md net −7 lines (10-line D-1 block removed, ~3 lines of
blocker/pointer updates added) — a mandated-read file got smaller.

**Next steps (specific):** (A) **Prep D-2 is the natural next code pickup**
(READY, S, full TDD gates): rewrite the two test-only reaches into
`.buildMatingUnitForest()` — re-verify `tests/testthat/test_modPedigree.R:1669`
and `:1706` before editing (verified current S738, not re-verified S744).
D-3 (REFACTOR-only roxygen hygiene) remains READY/S. (B) ~6 unpushed after
close-out (2 carried + claim + deliverable + records + sha; last two estimated
at write time — recount with `git rev-list --count origin/master..HEAD`).
**The deliverable commit touches `R/` and `tests/` — CI is NOT current for the
new code**, so a push+CI session is now the higher-value routine pick
(S726–S743 precedent; expect R-CMD-check inside the 17m39s–22m17s band).
(C) The a2interactive deferred-documentation pass now owes a `kinshipMatrix`
demonstration when it next runs (S450/S478 checklist — deferred by design, not
skipped). (D) Other priorities unchanged: BACKLOG editorial compression
(READY, L); inst/doc slimming (DECISION NEEDED, M); REUSE registration (owner
action, S); NPRC outreach (owner review); kinship2 build item BLOCKED on
D-2/D-3 + S738 gates.

**Key files:** `R/makePedigreeDiagramData.R:1685` (new signature), `:1785`
(injection branch), `tests/testthat/test_makePedigreeMatingLayout.R:1689`
(D-1 test block), `BACKLOG.md:71` (D-2/D-3 now first), `CHANGELOG.md:41`
(S744 entries at top), `HANDOFFS.md` (S744 receipt).

**Gotchas for the next session:** (1) Expect 0 undocumented commits at next
Phase 0 — measure it; ~6 unpushed (recount). (2) A D-2 pickup is a CODE
session — full TDD gates (phase declarations, AskUserQuestion at every
transition); the reaches are in `test_modPedigree.R`, so the "tests only in
RED" phase discipline needs care: the deliverable IS a test rewrite, so agree
the phase mapping with the owner at the gate before writing anything.
(3) `inherits(x, "Matrix")` is FALSE for base matrices and TRUE for Matrix S4
classes — the D-1 validation deliberately checks `is.matrix(x) || inherits(x,
"Matrix")`; don't "simplify" it to one test. (4) Standing set unchanged:
`gh run list --commit` needs the FULL 40-char sha; smoke-test the filter
against in-flight runs BEFORE arming any monitor; `scratchpad/` invisible to
git BY OWNER DECISION; ratchet ~2 min AFTER committing (Learning 772); trim
needs `--budget-bytes 65536`; renv banner expected; CLAUDE.md warn band;
growth run 20/10 (21/10 next if nothing shrinks — measure, don't predict);
the two `SESSION_NOTES.md` ceilings differ (owner decision pending); suite
baseline 0 failed / 0 error / 184 skipped locally re-confirmed this session on
`44bb4481` — remote confirmation lands with the next push's R-CMD-check.

### Session 742 Handoff Evaluation (by Session 743)
**Score: 9/10.** **What helped:** "~11 unpushed (recount)" measured exactly 11;
"expect 0 undocumented; measure it" measured 0 on both frontiers at `ef0f34bb`; the
ratchet citation matched `.quality-gates-results.json` byte-for-byte; the growth-run
prediction ("19/10 next if nothing shrinks") was exact; the push+CI natural-next-pick
call was the owner's pick, and the carried standing set (FULL-40-char-sha smoke test,
CI band 17m39s–22m17s, single 30-min monitor arm, ratchet-during-wait) was applied as
written and all held — R-CMD-check measured 21m41s, inside the band, no re-arm.
**What was missing:** nothing material. **What was wrong:** nothing found — every
checked claim held. **ROI:** high.

### What Session 743 Did
**Deliverable:** Owner-directed push to `origin/master` + CI verification — **DONE.**
Pushed `889f9896..59f1888e` (12 commits: the 11 unpushed docs-only S737–S742
close-out/claim commits + the S743 claim `59f1888e` riding the push, S726–S740
precedent). All 4 push-triggered workflows `completed success` ON THE PUSHED SHA
`59f1888e` (verified via `gh run list --commit <full-40-char-sha>` with `headSha`
echoed back structurally, not inferred from the monitor stream): lint 4m22s
(id 35552846756), pkgdown 5m02s (35552846743), test-coverage 9m47s (35552846748),
R-CMD-check 21m41s (35552846742) — inside the established 17m39s–22m17s band; single
30-min Monitor arm covering every terminal conclusion, no re-arm. No trim needed
this session (`SESSION_NOTES.md` ~45 KB post-handoff, under the 56,750 B one-read
cap). No TDD phases (push + records; no `.R` files). Lint N/A.
**Started/completed:** 2026-09-20/21 (single session). Claim `59f1888e` (rode the
push); records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, push+CI deliverable,
records, sha). No BACKLOG item consumed (the push was a Phase 0 owner pick).

**What actually happened, in order:**
1. **Phase 0:** full 8-step orient; reconcile clean (0 undocumented on both frontiers
   at `ef0f34bb`; S742 receipt complete; ratchet citation matched the results file);
   CI 10/10 green on master (latest 4 on `889f9896`); dashboard 96/100; context
   budget WARN = CLAUDE.md warn band, growth run 19/10 (exactly as S742 predicted);
   11 unpushed measured (= S742's ~11); 5 known untracked files unchanged; no live
   sequencing-audit cluster.
2. **Owner picked the push** via the Phase 0 AskUserQuestion picker; claim `59f1888e`
   committed and rode the push `889f9896..59f1888e`; 0 unpushed after the push.
3. **Filter smoke-tested live BEFORE arming the monitor** (the S736 lesson): a direct
   `gh run list --commit <full-sha>` returned all 4 runs queued/in-progress with
   matching `headSha` — only then was the 30-min Monitor armed, covering every
   terminal conclusion, not success-only.
4. **quality_ratchet run DURING the CI wait** at the pushed HEAD `59f1888e`: 1/1 pass
   · 0 fail · 0 unmeasured · results 0ddf7e4d90f7 · manifest aa983075d6a2
   (3,483,919 B ≤ 5,000,000 B).
5. **CI verification:** monitor emitted each terminal conclusion (lint → pkgdown →
   test-coverage → R-CMD-check, all success); conclusions then re-verified directly
   from the JSON with run ids, durations, and `headSha`.

**Self-assessment (Session 743): 9/10.** **Strengths:** (1) the S736 failure mode
(silent monitor arm on a bad filter) prevented by design — filter proven against
in-flight runs before arming; (2) deliverable verified structurally on the exact
pushed sha with run ids + durations recorded; (3) no dead time — the ratchet ran
during the CI wait; (4) scope held — a pure push+CI session, nothing else touched.
**Weaknesses:** (1) durations are createdAt→updatedAt and include queue time
(seconds ±); (2) nothing novel to report — a 10th consecutive clean push exercises
the protocol but adds no new knowledge.

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine clean push (10th:
S717/S726/S729/S731/S733/S734/S735/S736/S740). **Reduction check (FM #28):** nothing
removed from a mandated-read file this session — stated explicitly; `SESSION_NOTES.md`
has ~11 KB headroom before the one-read cap binds, so the next trim is likely 1–2
sessions out.

**Next steps (specific):** (A) 2 unpushed after close-out (records + sha — estimated
at write time; recount with `git rev-list --count origin/master..HEAD`); CI current
through `59f1888e`; no push urgency. (B) Priorities unchanged: prep D-1/D-2/D-3
(READY, S each — D-1/D-2 are CODE sessions, full TDD gates; D-1 doubly motivated as
step 0 of the committed kinship2 package); BACKLOG editorial compression (READY, L);
inst/doc slimming (DECISION NEEDED, M); REUSE registration (owner action, S); NPRC
outreach (owner review). (C) The kinship2 build item stays BLOCKED — not pickable
until D-1/D-2/D-3 land and the S738 gates move; do NOT surface it in the Phase 0
picker.

**Key files:** `CHANGELOG.md:41` (S743 entries at top), `HANDOFFS.md:158` (S743
receipt), `BACKLOG.md:71` (prep D-1/D-2/D-3 — the natural code pickups),
`BACKLOG.md:95` (BLOCKED kinship2 build item — read its purpose statement before any
future planning).

**Gotchas for the next session:** (1) Expect 0 undocumented commits at next Phase 0 —
measure it; 2 unpushed after close-out (recount). (2) CI band now confirmed across 5
pushes: R-CMD-check 17m39s–22m17s; one 30-min Monitor arm suffices — and ALWAYS
smoke-test `gh run list --commit <FULL-40-char-sha>` against the in-flight runs
before arming. (3) A D-1/D-2 pickup is a CODE session — full TDD gates (phase
declarations, AskUserQuestion at every transition); re-verify
`R/makePedigreeDiagramData.R:1755` and `test_modPedigree.R:1669/:1706` before
editing. (4) Standing set unchanged: `scratchpad/` invisible to git BY OWNER
DECISION; ratchet ~2 min AFTER committing (Learning 772); trim needs
`--budget-bytes 65536`; renv banner expected; CLAUDE.md warn band; growth run 19/10
(20/10 next if nothing shrinks — measure, don't predict); the two `SESSION_NOTES.md`
ceilings differ (owner decision pending); suite baseline 2437/0/0/184/0 —
remote-confirmed again by R-CMD-check on `59f1888e`.

### Session 741 Handoff Evaluation (by Session 742)
**Score: 9/10.** **What helped:** "~7 unpushed (recount)" measured exactly 7; "expect
0 undocumented; measure it" measured 0 on both frontiers at `0cf0696e`; the ratchet
citation matched `.quality-gates-results.json` byte-for-byte; the step-2 pickup
guidance was effectively the session's execution plan — brief from Finding #4 +
Structural Observation 2, read the Recommendations first, volunteer the briefing
WITH the question (S738 lesson) — all applied as written and the owner engaged with
the full decision set in one pass. **What was missing:** nothing material — the
owner's purpose reframing (standalone-first, not extraction-for-dependency) was not
predictable from S741's state. **What was wrong:** nothing found — every checked
claim held. **ROI:** high.

### What Session 742 Did
**Deliverable:** kinship2 standalone-package step 2 owner discussion / packaging
disposition — **DONE** (commit `4697f66c`). Owner decisions via one 4-question
`AskUserQuestion` (briefing volunteered with it, from
`docs/research/kinship2-feature-gap-analysis-2026-09-20.md`):
(1) **Disposition: COMMITTED but DEFERRED** — "Not now — defer, gates stand" (prep
D-1/D-2/D-3 + the S738 revisit conditions, scoping doc §6), with owner free-text
intent recorded near-verbatim: the package WILL be built; "the primary goal is to
have a standalone near equivalent package that has the enhanced features offered
with nprcgenekeepr and particularly the pedigree drawing, annotation ability, and
interactivity" — nprcgenekeepr consuming it is secondary, NOT the primary goal.
(2) **API shape: deliberately OPEN** (df-as-is vs kinship2-compat layer — decide at
plan time with a prototype). (3) **Drawing surface: IN** — lift the module-bound
decorations (`R/modPedigree.R:675-790`) into a script-callable visNetwork renderer.
(4) **Parity closers: IN** — shrink helpers + `bitSize` exports, `familycheck` +
`ibdMatrix` ports, user-suppliable layout hints; **OUT** — block-sparse
`makekinship`. Records: S739 discussion item REMOVED (completed-item removal
checklist); still-open thread extracted as the new BLOCKED item "Build a
kinship2-similar standalone pedigree package" (`BACKLOG.md:95`) carrying the full
scope + purpose statement forward. No TDD phases (decision/records; no `.R` files).
Lint N/A.
**Started/completed:** 2026-09-20 (single session). Claim `222f0c5e`; deliverable
`4697f66c`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, deliverable, records, sha).
BACKLOG item consumed and removed; one new BLOCKED item added in its place.

**What actually happened, in order:**
1. **Phase 0:** full 8-step orient; reconcile clean (0 undocumented on both frontiers
   at `0cf0696e`; S741 receipt complete, ratchet citation matched the results file);
   CI 10/10 green (latest 4 on `889f9896`); dashboard 96/100; context budget WARN =
   CLAUDE.md warn band, growth run 18/10; 7 unpushed measured (= S741's estimate);
   5 known untracked files unchanged; no live sequencing-audit cluster.
2. **Owner picked step 2** via the Phase 0 picker (over push+CI and prep D-1/D-2);
   claim `222f0c5e`.
3. **Gap doc read in full** before briefing; briefing rendered in-chat (Findings
   #1/#2/#4, Structural Observations 2/3, sequencing/gates status), then all four
   decisions posed in ONE `AskUserQuestion` — disposition + the three scope
   questions framed as "recorded scope if/when built" so the answers land as the
   durable disposition either way.
4. **Records:** old item block (20 lines) replaced by the new BLOCKED build item
   (26 lines) with the owner's purpose statement and full IN/OUT scope; CHANGELOG
   deliverable entry carries the near-verbatim owner quote; deliverable committed
   `4697f66c`; quality_ratchet at that HEAD: 1/1 pass · results 966c2a067d51 ·
   manifest aa983075d6a2 (3,483,942 B ≤ 5,000,000 B).

**Self-assessment (Session 742): 9/10.** **Strengths:** (1) the S738 lesson applied
by design — briefing volunteered WITH the question, so the owner decided on full
context in one round; (2) all four decisions captured in one structured call, and
the owner's free-text purpose statement was preserved near-verbatim in BOTH the
ledger and the forward-carrying item (it materially changes what a future planning
session should design: sibling product, not extraction); (3) completed-item removal
checklist followed exactly (block removed, record enriched into CHANGELOG, open
thread extracted); (4) scope held — no planning or code started on a committed-but-
deferred item. **Weaknesses:** (1) `BACKLOG.md` net +6 lines (FM #28 tension —
inherent to recording a scope-rich disposition, but real); (2) the recommended
disposition option carried the S738 CRAN-release gate forward unexamined — the
owner's standalone-first reframing arguably weakens that gate's rationale, and the
session recorded the tension rather than re-posing it (deliberate: one decision
round, no re-litigating — but a future session could surface it cheaply).

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine decision/records
session; the durable record is the CHANGELOG entry + the BACKLOG item. **Reduction
check (FM #28):** nothing removed from a mandated-read file; `BACKLOG.md` grew net
+6 lines by disposition-recording — stated explicitly; the editorial-compression
item (READY, L) remains the standing counterweight.

**Next steps (specific):** (A) ~11 unpushed after close-out (7 carried + 4 S742:
claim, deliverable, records, sha — last two estimated at write time; recount with
`git rev-list --count origin/master..HEAD`); all docs-only since `889f9896`, so CI
is current; the unpushed backlog keeps growing — **a push+CI session is the natural
next pick** (S726–S740 precedent). (B) The kinship2 build item is now **BLOCKED —
not pickable** until prep D-1/D-2/D-3 land and the S738 gates move; do NOT surface
it in the Phase 0 picker. (C) Pickable priorities: prep D-1/D-2/D-3 (READY, S each;
D-1/D-2 CODE sessions, full TDD gates; D-1 is now doubly motivated as step 0 of the
committed package); BACKLOG editorial compression (READY, L); inst/doc slimming
(DECISION NEEDED, M); REUSE registration (owner action, S); NPRC outreach (owner
review).

**Key files:** `BACKLOG.md:95` (the new BLOCKED build item — a future planning
session MUST read its purpose statement before designing), `CHANGELOG.md:41` (S742
entries at top, incl. the near-verbatim owner quote), `HANDOFFS.md` (S742 receipt),
`docs/research/kinship2-feature-gap-analysis-2026-09-20.md:186` (Recommendations —
the scope decisions' evidence base).

**Gotchas for the next session:** (1) Expect 0 undocumented commits at next Phase 0
— measure it; ~11 unpushed after close-out (recount). (2) The kinship2 package
disposition is COMMITTED-deferred: treat "gates stand" as the owner's word — don't
re-pose the disposition; the one legitimately open cheap question is whether the
CRAN-release gate still fits the standalone-first purpose (see this session's
weakness #2). (3) A D-1/D-2 pickup is a CODE session — full TDD gates
(phase declarations, AskUserQuestion at every transition); re-verify
`R/makePedigreeDiagramData.R:1755` and `test_modPedigree.R:1669/:1706` before
editing. (4) Standing set unchanged: `gh run list --commit` needs the FULL 40-char
sha; `scratchpad/` invisible to git BY OWNER DECISION; ratchet ~2 min AFTER
committing (Learning 772); trim needs `--budget-bytes 65536`; renv banner expected;
CLAUDE.md warn band; growth run 18/10 (19/10 next if nothing shrinks — BACKLOG.md
is not in the budget file, so its +6 lines don't move it; measure, don't predict);
the two `SESSION_NOTES.md` ceilings differ (owner decision pending); suite baseline
2437/0/0/184/0 remote-confirmed on `889f9896`.

### Session 740 Handoff Evaluation (by Session 741)
**Score: 9/10.** **What helped:** "3 unpushed after close-out" measured exactly 3;
"expect 0 undocumented; measure it" measured 0 on both frontiers at `ab71a037`; the
ratchet citation matched `.quality-gates-results.json` byte-for-byte; the priorities
list fed the Phase 0 picker directly and its named research pickup (kinship2 gap
analysis, `BACKLOG.md:95`) was the owner's pick; the "measure the growth run rather
than predict" guidance was exactly right — measured 17/10, and the trim did NOT reset
it (the resident total tracks `CLAUDE.md` alone), answering S740's own open question.
**What was missing:** nothing material. **What was wrong:** nothing found — every
checked claim held. **ROI:** high.

### What Session 741 Did
**Deliverable:** kinship2 feature-gap analysis — **DONE** (commit `11f436cd`).
`docs/research/kinship2-feature-gap-analysis-2026-09-20.md`: kinship2 1.9.6.2's
surface enumerated LIVE from the installed package — 25 exports + 11 S3 registrations
(4 not in the export list) + 3 datasets; the BACKLOG item's embedded list was indeed
an incomplete hint (11 of 25). Verdict: **15 equivalent / 8 partial / 2 absent**.
Headline findings: (1) the compute core was already deliberately ported —
`kinship()` incl. `chrtype="x"` + transitive MZ-twin correction (`R/kinship.R:104`),
`shrinkPedigree()` + kinship2's 5 shrink helpers as internals
(`R/shrinkPedigree.R:122,227-380`) — per the shipped Tracks A/B of
`docs/planning/kinship2-supplement-full-reproduction-plan.md`; (2) the S435 drawing
gaps are ALL closed (issues #131–#137/#145, states re-verified via `gh issue view`);
(3) only `familycheck` and `ibdMatrix` are fully absent, both minor; (4) the real
step-2 question is PACKAGING, not features — drawing decorations live in the Shiny
module (`R/modPedigree.R:675-790`), not the exported surface (doc Finding #4).
`BACKLOG.md:95` item updated in place: step 1 DONE → step 2 DECISION NEEDED
(net −10 lines). Step 2 (owner discussion) deliberately NOT started ("1 and done").
No TDD phases (research/records; no `.R` files). Lint N/A.
**Started/completed:** 2026-09-20 (single session). Claim `c9457ec7`; deliverable
`11f436cd`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, deliverable, records, sha).
BACKLOG item advanced (step 1 consumed), not removed — step 2 remains open.

**What actually happened, in order:**
1. **Phase 0:** full 8-step orient; reconcile clean (0 undocumented on both frontiers
   at `ab71a037`; ratchet citation matched results file); CI 10/10 green (latest 4 on
   `889f9896`); dashboard 96/100; context budget WARN = CLAUDE.md warn band, growth
   run 17/10 (trim did not reset it); 3 unpushed measured (= S740's count); 5 known
   untracked files unchanged; no live sequencing-audit cluster.
2. **Owner picked the gap analysis** via the Phase 0 picker; claim `c9457ec7`.
3. **Enumeration before classification:** exports/S3/datasets pulled from the
   installed kinship2 via `getNamespaceExports`/`getNamespaceInfo`/`data()` — found
   the item's hint list incomplete (11/25), exactly as its own caveat warned.
4. **Prior art read before writing:** ISSUE_129 comparison (drawing-only, stale —
   all 8 follow-up issues verified CLOSED), the supplement-reproduction plan
   (Tracks A/B shipped — reframed the analysis), the S482 spike.
5. **Every analog claim verified live** (signatures/roxygen/grep with file:line);
   `familycheck`/`ibdMatrix` absence established by corpus grep, not assumption.
6. **Doc written** (audit-workstream structure: method/coverage/gap table/findings/
   structural observations/recommendations), BACKLOG item rewritten forward-carrying,
   deliverable committed `11f436cd`; quality_ratchet run at that HEAD (summary in the
   receipt).

**Self-assessment (Session 741): 9/10.** **Strengths:** (1) live enumeration made the
scope authoritative and falsified the embedded hint list rather than trusting it;
(2) the decisive prior-art discovery (Tracks A/B already shipped) turned the analysis
from a gap hunt into the packaging question step 2 actually needs; (3) all 25 + 5
supplementary rows carry this-session file:line evidence; (4) scope held — step 2
untouched; (5) FM #28 reduction: BACKLOG.md net −10 lines. **Weaknesses:** (1)
kinship2-side per-export behavior descriptions rest on the installed package's docs
plus the prior deparse-based ports, not a fresh per-export CRAN-manual re-read;
(2) the EQ-D judgments (e.g., `groupAddAssign` ⊇ `pedigree.unrelated`) are
reasoned from roxygen/source, not head-to-head empirical runs.

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine research session; the
durable record is the doc + the CHANGELOG entry. **Reduction check (FM #28):**
`BACKLOG.md` net −10 lines (31-line item → 21) — a mandated-read file got smaller.

**Next steps (specific):** (A) **Step 2 is now the natural pickup** (DECISION NEEDED,
Effort S): an owner-discussion session like S738's disposition — pose the doc's
Recommendation-1 packaging choices (a/b/c) via `AskUserQuestion`, brief from Finding
#4 + Structural Observation 2 first. Read
`docs/research/kinship2-feature-gap-analysis-2026-09-20.md` Recommendations before
posing anything. (B) ~7 unpushed after close-out (3 carried + claim + deliverable +
records + sha; the last two estimated at write time — recount with
`git rev-list --count origin/master..HEAD`); all docs-only since `889f9896`, so CI
current; push session at owner's call. (C) Other priorities unchanged: prep
D-1/D-2/D-3 (READY, S each; D-1/D-2 CODE sessions, full TDD gates); BACKLOG editorial
compression (READY, L); inst/doc slimming (DECISION NEEDED, M); REUSE registration
(owner action, S); NPRC outreach (owner review).

**Key files:** `docs/research/kinship2-feature-gap-analysis-2026-09-20.md:1` (the
deliverable — step 2 reads its Recommendations), `BACKLOG.md:95` (updated item, step
2 framing), `CHANGELOG.md:41` (S741 entries at top), `HANDOFFS.md:158` (S741 receipt).

**Gotchas for the next session:** (1) Expect 0 undocumented commits at next Phase 0 —
measure it; ~7 unpushed after close-out (recount). (2) A step-2 pickup is a
DECISION/records session (no TDD phases) but the decision belongs to the owner — brief
first, ask second (S738 precedent: volunteering the briefing with the question beats
being asked for it). (3) The gap doc's counts (15/8/2) are as-of kinship2 1.9.6.2 —
re-check `packageVersion("kinship2")` before citing them as current. (4) Standing set
unchanged: `gh run list --commit` needs the FULL 40-char sha; `scratchpad/` invisible
to git BY OWNER DECISION; ratchet ~2 min AFTER committing (Learning 772); trim needs
`--budget-bytes 65536`; renv banner expected; CLAUDE.md warn band; growth run 17/10;
the two `SESSION_NOTES.md` ceilings differ (owner decision pending); suite baseline
2437/0/0/184/0 remote-confirmed on `889f9896`.

### Session 739 Handoff Evaluation (by Session 740)
**Score: 9/10.** **What helped:** "15 unpushed after close-out" (the corrected count)
measured exactly 15; "expect 0 undocumented; measure it" measured 0 on both frontiers
at `8006087b`; the FULL-40-char-sha gotcha was applied by design — the `--commit`
filter was smoke-tested against in-flight runs seconds after the push, so S736's
silent 30-min arm could not recur; the carried CI band (17m39s–22m17s, one 30-min
Monitor arm) held — R-CMD-check measured 22m07s, no re-arm; the priorities list fed
the Phase 0 picker directly and the push was its named natural next pick. **What was
missing:** nothing material. **What was wrong:** nothing found — every checked claim
held (S739's own correction commit had already fixed its arithmetic slip in-session).
**ROI:** high.

### What Session 740 Did
**Deliverable:** Owner-directed push to `origin/master` + CI verification — **DONE.**
Pushed `2628cd02..889f9896` (16 commits: the 15 unpushed docs-only S737–S739
close-out/claim commits + the S740 claim `889f9896` riding the push, S726–S736
precedent). All 4 push-triggered workflows `completed success` ON THE PUSHED SHA
`889f9896` (verified via `gh run list --commit <full-40-char-sha>` with `headSha`
echoed back structurally): lint 4m37s (id 35548502389), pkgdown 6m13s (35548502366),
test-coverage 9m54s (35548502412), R-CMD-check 22m07s (35548502318) — inside the
established 17m39s–22m17s post-S732-fix band; single 30-min Monitor arm, no re-arm.
Also: proactive `SESSION_NOTES.md` trim `4876094d` (S733 precedent — the file was
1,701 B under the 56,750 B one-read cap and the handoff would have crossed it;
12 records archived, 55,049 → 17,713 B, L1/L2/L3 verified pre-commit, no SRF refusal
this time). No TDD phases (push + docs; no `.R` files). Lint N/A.
**Started/completed:** 2026-09-20/21 (single session). Claim `889f9896` (rode the
push); trim `4876094d`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, trim, push+CI deliverable,
records, sha). No BACKLOG item consumed (the push was a Phase 0 owner pick).

**What actually happened, in order:**
1. **Phase 0:** full 8-step orient; reconcile clean (0 undocumented on both frontiers
   at `8006087b`; S739 receipt complete; the only `status: pending` in HANDOFFS.md is
   its instructions text); CI 10/10 green on master; dashboard 96/100; context budget
   WARN = CLAUDE.md warn band + growth run 16/10 (exactly as S739 predicted), both
   synced files `canonical ok`; 15 unpushed measured (= S739's corrected count);
   5 known untracked files unchanged; no live sequencing-audit cluster.
2. **Owner picked the push** via the Phase 0 AskUserQuestion picker; claim `889f9896`
   committed and rode the push `2628cd02..889f9896`; 0 unpushed after the push.
3. **Filter smoke-tested live BEFORE arming the monitor** (the S736 lesson): a direct
   `gh run list --commit <full-sha>` returned all 4 runs queued/in-progress with
   matching `headSha` — only then was the 30-min Monitor armed, covering every
   terminal conclusion, not success-only.
4. **CI verification:** monitor emitted each terminal conclusion (lint → pkgdown →
   test-coverage → R-CMD-check, all success); conclusions then re-verified directly
   from the JSON with run ids, durations, and `headSha` — not inferred from the
   monitor stream alone.
5. **quality_ratchet run DURING the CI wait** at the pushed HEAD `889f9896`: 1/1 pass
   · 0 fail · 0 unmeasured · results 2cb2faa00809 · manifest aa983075d6a2
   (3,483,874 B ≤ 5,000,000 B).
6. **Trim, pre-handoff, on committed state:** dry run first (`--cut 5`, semantics =
   records KEPT, per the S733 gotcha), L1/L2/L3 verified via the shard's verify
   script before commit `4876094d`.

**Self-assessment (Session 740): 9/10.** **Strengths:** (1) the S736 failure mode
(silent monitor arm on a short-sha filter) was prevented by design, not luck — the
filter was proven against in-flight runs before arming; (2) deliverable verified
structurally on the exact pushed sha with run ids + durations recorded; (3) no dead
time — the ratchet ran during the CI wait; (4) the one-read-cap crossing was caught
BEFORE the handoff landed, and the trim rode committed state with the verify script
run pre-commit. **Weaknesses:** (1) durations are createdAt→updatedAt and include
queue time (seconds ±); (2) the trim's keep-count (5 records) was chosen by dry-run
inspection, not a principled rule — S733 kept 3; the convention is consistency by
feel, not policy.

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine clean push (9th:
S717/S726/S729/S731/S733/S734/S735/S736). **Reduction check (FM #28):** 12 records
removed from a mandated-read file this session (the trim) — `SESSION_NOTES.md`
55,049 → 17,713 B.

**Next steps (specific):** (A) 3 unpushed after close-out (trim + records + sha —
the ~2 first written here forgot the post-push trim commit, the same slip S739 made;
recount with `git rev-list --count origin/master..HEAD`);
CI current through `889f9896`; no push urgency. (B) Priorities unchanged: kinship2
feature-gap analysis (READY, M — step 1 of the S739 item, first-class research
pickup); prep D-1/D-2/D-3 (READY, S each — D-1/D-2 are CODE sessions, full TDD
gates); BACKLOG editorial compression (READY, L); inst/doc slimming (DECISION
NEEDED, M); REUSE registration (owner action, S); NPRC outreach (owner review).
(C) Standing report-only set: CLAUDE.md warn band unchanged; growth run was 16/10
this session — whether the SESSION_NOTES trim resets it depends on what the run
measures (the "resident total" printed equals CLAUDE.md alone), so measure at next
Phase 0 rather than predict.

**Key files:** `CHANGELOG.md:41` (S740 entries at top), `HANDOFFS.md:159` (S740
receipt), `docs/archive/SESSION_NOTES-through-2026-09-20.md` (new shard),
`BACKLOG.md:95` (kinship2 step-1 item — the next natural research pickup).

**Gotchas for the next session:** (1) Expect 0 undocumented commits at next Phase 0 —
measure it; 3 unpushed after close-out (trim + records + sha; recount). (2) CI band now
confirmed across 4 pushes: R-CMD-check 17m39s–22m17s; one 30-min Monitor arm
suffices — and ALWAYS smoke-test `gh run list --commit <FULL-40-char-sha>` against
the in-flight runs before arming. (3) `SESSION_NOTES.md` is 17.7 KB live post-trim —
several sessions of headroom before the 56,750 B one-read cap binds again.
(4) Standing set unchanged: `scratchpad/` invisible to git BY OWNER DECISION;
ratchet ~2 min AFTER committing (Learning 772); trim needs `--budget-bytes 65536`;
renv banner expected; CLAUDE.md warn band; the two `SESSION_NOTES.md` ceilings
differ (owner decision pending); suite baseline 2437/0/0/184/0 — remote-confirmed
again by R-CMD-check on `889f9896`.

### Session 738 Handoff Evaluation (by Session 739)
**Score: 9/10.** **What helped:** "~10 unpushed after close-out" measured exactly 10;
both frontiers clean at `e3370b82` as predicted; the prep-item context (D-1/D-2/D-3 as
step 0 of any extraction, the S667 §6/§2.7 pointers) fed directly into how the new
kinship2-package item was framed and cross-referenced. **What was missing:** nothing
material — the new directive was not predictable from S738's state. **What was
wrong:** nothing found. **ROI:** high, though lightly exercised (same-conversation
pickup minutes after the handoff was written).

### What Session 739 Did
**Deliverable:** BACKLOG item added — **DONE** (commit `7b10ac3d`). New Up Next item:
**discuss making a kinship2-similar standalone package from this repository's code**,
owner-directed this session. Two explicit steps: **step 1** (READY, Effort M, its own
research session) a kinship2 feature-gap analysis — enumerate kinship2's exported
surface at analysis time, classify each feature equivalent/partial/absent here,
deliverable a per-feature gap table in `docs/research/`; **step 2** (DECISION NEEDED,
gated on step 1) the owner discussion on whether/at what scope to build it.
**Combination judgment** (owner said "perhaps combining with other backlog item"):
placed directly after the S738 prep items D-1/D-2/D-3 (step 0 of any extraction) with
cross-references, rather than merged into the mostly-DONE "Pedigree diagram vs
kinship2 audit follow-ups" section — that section is a historical triage record
(drawing-only, stale: #131–#137/#145 closed most of its gaps) and is cited as step-1
prior art instead. The item is framed as the concrete path to the S738 disposition's
revisit condition 3 (the "ecosystem argument", S667 doc §6/§2.7). No TDD phases
(records only; no `.R` files). Lint N/A.
**Started/completed:** 2026-09-20 (single session, same conversation as S738). Claim
`e2671de1`; deliverable `7b10ac3d`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, deliverable, records, sha).
No BACKLOG item consumed (this session ADDED one).

**What actually happened, in order:**
1. **Abbreviated re-orient** (S735 precedent, state minutes old, named honestly): tree
   clean, both ledger frontiers at `e3370b82`, 0 undocumented, 10 unpushed (= S738's
   estimate exactly); full 8-step orient/dashboard/CI check not re-run.
2. **Claim committed** `e2671de1`.
3. **Combination decision researched before writing:** read the existing "Pedigree
   diagram vs kinship2 audit follow-ups" section — determined it is a mostly-DONE
   triage record, so adjacency + cross-references beat merging into it.
4. **Item written** with S739-verified prior-art pointers (ISSUE_129 audit, S482
   spike, `comparePedigreeStructure.R`, `shrinkPedigree.R`, `kinship.R`) and the
   explicit caveat that the kinship2 export list in the item is a hint to verify at
   analysis time, not a trusted inventory. Deliverable committed `7b10ac3d`;
   quality_ratchet run at that HEAD (summary in the receipt).

**Self-assessment (Session 739): 9/10.** **Strengths:** (1) the "perhaps combining"
directive was resolved by reading the candidate section first, and the judgment (and
its reason) recorded in the ledger rather than silently applied; (2) the item is
forward-carrying — a future session can run step 1 with no re-derivation (prior art
enumerated, deliverable format named, staleness of the old comparison flagged); (3)
full claim/receipt/ledger discipline kept for a small records session. **Weaknesses:**
(1) BACKLOG.md GREW by ~36 lines (FM #28 tension — inherent to an add-an-item
directive, but the editorial-compression item grows more overdue); (2) the kinship2
export list embedded in the item is from model knowledge, flagged as untrusted but
still a potential stale anchor.

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine grooming session.
**Reduction check (FM #28):** nothing removed from a mandated-read file; `BACKLOG.md`
grew +36 lines by owner directive — stated explicitly; the editorial-compression item
(READY, L) is the standing counterweight.

**Next steps (specific):** (A) 14 unpushed after close-out (measured post-sha-commit;
the ~12 first written here was an arithmetic slip that forgot the records + sha
commits themselves — recount with `git rev-list --count origin/master..HEAD`); all docs-only since `2628cd02`; the
unpushed backlog keeps growing, so a push+CI session is the natural next pick.
(B) The new item's step 1 (kinship2 feature-gap analysis, READY, M) is now a
first-class research pickup. (C) Other priorities unchanged: prep D-1/D-2/D-3
(READY, S each); BACKLOG editorial compression (READY, L); inst/doc slimming
(DECISION NEEDED, M); REUSE registration (owner action, S). (D) Standing report-only
set unchanged: CLAUDE.md warn band; growth run 16/10 next if nothing shrinks.

**Key files:** `BACKLOG.md:98` (the new item, right after prep D-1/D-2/D-3),
`CHANGELOG.md:41` (S739 entries at top), `HANDOFFS.md` (S739 receipt),
`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md` (step-1 prior art).

**Gotchas for the next session:** (1) Expect 0 undocumented commits at next Phase 0 —
measure it; 14 unpushed after close-out (measured). (2) A step-1
pickup must enumerate kinship2's exports from the installed package/CRAN manual at
analysis time — the list inside the BACKLOG item is an unverified hint, per the item's
own caveat. (3) D-1/D-2 pickups are CODE sessions — full TDD gates apply. (4) Standing
set unchanged: `gh run list --commit` needs the FULL 40-char sha; `scratchpad/`
invisible to git BY OWNER DECISION; ratchet ~2 min AFTER committing (Learning 772);
trim needs `--budget-bytes 65536`; renv banner expected; CLAUDE.md warn band; the two
`SESSION_NOTES.md` ceilings differ (owner decision pending); suite baseline
2437/0/0/184/0 remote-confirmed on `2628cd02`.

### Session 737 Handoff Evaluation (by Session 738)
**Score: 9/10.** **What helped:** "6 unpushed after close-out (measured)" measured
exactly 6; "expect 0 undocumented; measure it" measured 0 on both frontiers; the
ratchet citation matched `.quality-gates-results.json` byte-for-byte; the growth-run
prediction ("15/10 next if nothing shrinks") was exact; the priorities list fed the
Phase 0 picker directly, and the picked item's own pointers (the S667 doc path + the
S737 audit context lines) were most of the execution plan. **What was missing:**
nothing material — the owner asked for an S667 briefing before deciding, which the
scoping doc itself supplied. **What was wrong:** nothing found — every checked claim
held. **ROI:** high.

### What Session 738 Did
**Deliverable:** Package-split disposition — **DONE.** The owner **ACCEPTED** the S667
recommendation ("do not split now",
`docs/research/pedigree-diagram-package-split-scoping-2026-09-02.md` §6) **and queued
the three prep steps** (D-1 invert `kinship()`, D-2 remove the two test-only internal
reaches, D-3 `@noRd` blocks for `positionTreeApportion.R`) as Up Next items. Deliverable
commit `9d80dde6`: the 2026-08-19 BACKLOG item block removed (completed-item removal
checklist), the three prep items written with forward-carrying detail and
S738-verified line references, disposition + revisit conditions recorded in
`CHANGELOG.md`. No TDD phases (decision/records; no `.R` files). Lint N/A.
**Started/completed:** 2026-09-20 (single session). Claim `f9b1f2a3`; deliverable
`9d80dde6`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, deliverable, records, sha).
BACKLOG item consumed and removed; three new items added in its place.

**What actually happened, in order:**
1. **Phase 0:** full 8-step orient; reconcile clean (0 undocumented on both frontiers
   at `a4b62e16`; S737 receipt complete, ratchet citation matches results file); CI
   10/10 green on master (latest 4 on `2628cd02`); dashboard 96/100; 6 unpushed
   measured (= S737's estimate); context budget WARN = CLAUDE.md warn band + growth
   run 15/10 (as predicted), both synced files `canonical ok`; the 5 known untracked
   files unchanged; no live sequencing-audit cluster.
2. **Owner picked the package-split disposition** via the Phase 0 picker; claim
   `f9b1f2a3`.
3. **Revisit conditions re-measured at decision time** (the S667 numbers were 18 days
   old): condition 1 half-met (priority retired S699, but core churn 67 commits/60
   days · 27/30 — not single digits), condition 2 not met (`DESCRIPTION` 2.0.0.9000),
   condition 3 not met (no named consumer). Prep-step targets re-verified current:
   `kinship()` call drifted `:1551` → `R/makePedigreeDiagramData.R:1755`; the two
   `test_modPedigree.R` reaches exactly at `:1669`/`:1706`; `positionTreeApportion.R`
   roxygen count 0.
4. **Owner asked for the S667 findings before deciding** — briefing given from the
   scoping doc (boundary shape, costs D4/D5/D7, hypothetical-benefit finding, prep
   steps); owner then chose **"Accept + queue prep steps"** via AskUserQuestion.
5. **Records:** BACKLOG block (29 lines) replaced by the three prep items (27 lines);
   CHANGELOG deliverable entry carries the disposition, the re-measured conditions,
   and the load-bearing context from the removed block; deliverable committed
   `9d80dde6`; quality_ratchet run at that HEAD (summary in the receipt).

**Self-assessment (Session 738): 9/10.** **Strengths:** (1) the decision was posed on
re-measured, current facts (churn, version, line drift), not the 18-day-old S667
numbers; (2) all three prep-item targets verified against the live tree before being
written into BACKLOG (no stale line references shipped); (3) the completed-item
removal checklist followed exactly — block removed, record enriched into CHANGELOG,
still-open sub-threads extracted as their own items; (4) scope held (no prep step was
started; FM #23 respected — the owner's clarify request got a briefing, not file
edits). **Weaknesses:** (1) the first AskUserQuestion was posed before offering the
S667 briefing — the owner had to ask for context that could have been volunteered
with the question; (2) BACKLOG net reduction was only −2 lines (the three new items
nearly replace the removed block's bulk).

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine decision/records session;
the durable record is the CHANGELOG entry + the prep items. **Reduction check
(FM #28):** `BACKLOG.md` net −2 lines (29-line block → 27 lines of prep items) — a
mandated-read file got (barely) smaller.

**Next steps (specific):** (A) ~10 unpushed after close-out (6 carried + 4 S738:
claim, deliverable, records, sha — last two estimated at write time; recount with
`git rev-list --count origin/master..HEAD`); all docs-only since `2628cd02`, so CI is
current and a push session is routine when the owner wants one (S726–S736 precedent) —
the backlog of unpushed commits is growing, so sooner is better than later. (B) New
natural code pickups: prep D-1 (READY, S, TDD-gated — invert `kinship()` at
`R/makePedigreeDiagramData.R:1755`, re-verify the line first), D-2 (READY, S,
TDD-gated — `test_modPedigree.R:1669/:1706`), D-3 (READY, S, REFACTOR-only roxygen
hygiene). (C) Remaining priorities: BACKLOG.md editorial compression (READY, L);
inst/doc slimming (DECISION NEEDED, M, `BACKLOG.md:100` area); REUSE registration
(owner web-action, S); NPRC outreach (owner review). (D) Standing report-only set
unchanged: CLAUDE.md warn band; growth run 16/10 next if nothing shrinks (BACKLOG.md
is not in the budget file, so its −2 lines won't reset the run).

**Key files:** `BACKLOG.md:71` (the three new prep items), `CHANGELOG.md:41` (S738
entries at top), `docs/research/pedigree-diagram-package-split-scoping-2026-09-02.md`
§6 (revisit conditions — the doc is the durable analysis), `HANDOFFS.md` (S738
receipt).

**Gotchas for the next session:** (1) Expect 0 undocumented commits at next Phase 0 —
measure it; ~10 unpushed after close-out (8 measured + 2 estimated). (2) A session
picking up D-1 or D-2 is a CODE session: full TDD gates apply (phase declarations,
AskUserQuestion at every transition), unlike the recent docs-only run — don't carry
the "no TDD phases" reflex forward. (3) The layout core still changes; re-verify
`:1755` (D-1) and `:1669/:1706` (D-2) before editing. (4) Standing set unchanged:
`gh run list --commit` needs the FULL 40-char sha; `scratchpad/` invisible to git BY
OWNER DECISION; ratchet ~2 min AFTER committing (Learning 772); trim needs
`--budget-bytes 65536`; renv banner expected; CLAUDE.md warn band; the two
`SESSION_NOTES.md` ceilings differ (owner decision pending); suite baseline
2437/0/0/184/0 remote-confirmed on `2628cd02`.

