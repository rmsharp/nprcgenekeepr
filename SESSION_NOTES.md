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

**Next steps (specific):** (A) ~2 unpushed after close-out (records + sha, docs-only,
estimate at write time — recount with `git rev-list --count origin/master..HEAD`);
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
measure it; ~2 unpushed after close-out (estimate; recount). (2) CI band now
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

