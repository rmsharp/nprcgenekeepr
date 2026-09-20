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

---

## ACTIVE TASK

### What Session 738 Did
**Deliverable:** Package-split disposition — owner accept/reject of the S667 scoping
recommendation ("do not split now",
`docs/research/pedigree-diagram-package-split-scoping-2026-09-02.md`) recorded in the
BACKLOG/CHANGELOG (IN PROGRESS)
**Started:** 2026-09-20
**Status:** Session claimed. Owner picked the item via the Phase 0 picker; the
disposition question goes to the owner next.
**Ledger:** `CHANGELOG: pending` — the claim commit's `CHANGELOG.md` entry says (in
progress); Phase 3F records the rest. Until close-out, this line is the crash
breadcrumb for the next session's reconcile.

### Session 736 Handoff Evaluation (by Session 737)
**Score: 9/10.** **What helped:** the priorities list fed the Phase 0 picker directly, and
the picked item's own pointers (S667 coupling inventory names the feature file set; S727
upper bound +1.07 MB) eliminated nearly all discovery; "expect 0 undocumented; measure it"
measured 0 on both frontiers; "~2 unpushed (estimate)" measured exactly 2; the ratchet
citation matched `.quality-gates-results.json` byte-for-byte; the standing set held
(CLAUDE.md warn band present; growth run 14/10, consistent with S736's 13/10 + one more
non-shrinking measurement). **What was missing:** nothing material — this session's task
carried its own pointers in the BACKLOG item. **What was wrong:** nothing found. **ROI:**
high.

### What Session 737 Did
**Deliverable:** Pedigree-drawing feature growth measurement — **DONE.**
`docs/audits/PEDIGREE_DRAWING_FEATURE_GROWTH_AUDIT_2026-09-20.md` (commit `6346cbde`;
BACKLOG item removed and the open inst/doc-slimming item enriched in the same commit).
Headline: the feature owns **25.4–30.5% of shipped-source byte growth** (821,174–983,984 B
of +3,228,303 B since pre-feature `fc358df4`, 2026-07-29 — the package is ~19–23% larger
in source bytes because of it), **43.0% of R+test line growth** (15,582 lines; test:source
2.6:1), and **≈0.55–0.65 MB ≈ 51–61% of compressed-tarball growth** since CRAN 2.0.0
(tarball rebuilt clean this session: 3,483,939 B, matching the S728 gate figure). The
feature's largest shipped weight is NOT its own code: ~0.29 MB compressed is the
vis-network + html2canvas payload its two live widgets embed in
`inst/doc/a2interactive.html` — hard numbers now carried into the inst/doc BACKLOG item.
Marker-genetics context: one 1,247,940 B example CSV outweighs the feature's entire
tracked source. No TDD phases (measurement + docs; no `.R` files). Lint N/A.
**Started/completed:** 2026-09-20 (single session). Claim `0528da0e`; deliverable
`6346cbde`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, deliverable, records, sha).
BACKLOG item consumed and removed (completed-item removal checklist).

**What actually happened, in order:**
1. **Phase 0:** full 8-step orient; reconcile clean (0 undocumented on both frontiers at
   `aa60cd58`; S736 receipt complete, ratchet citation matches results file); CI 10/10
   green on master (latest 4 on `2628cd02`); dashboard 96/100; 2 unpushed measured
   (= S736's estimate); context budget WARN = CLAUDE.md warn band + growth run 14/10,
   both synced files `canonical ok`. Sequencing audits checked: #146–153 all closed, no
   live cluster.
2. **Owner picked the growth measurement** via the Phase 0 picker; claim `0528da0e`.
3. **Classification:** feature file set from the S667 scoping doc, verified per-file by
   `git log --diff-filter=A` creation dates and grep usage (e.g. the affected/name/twins
   example CSVs are consumed by drawing tests + diagram screenshots generator;
   `shrinkPedigree.R` created 2026-08-14 as Track B fidelity apparatus; twin-relations
   infra bucketed separately as ambiguous; `enumerateMaximalIndependentSets.R`/`zzz.R`
   confirmed NON-feature via their creating commits).
4. **Measurement:** per-file byte deltas `fc358df4`→HEAD via `git ls-tree -r -l` joined in
   a scratchpad script (shipping filter approximating `.Rbuildignore`); line counts at
   both commits; clean tarball rebuilt per the S727 §7 recipe (3,483,939 B, 5 B from the
   gate figure = gzip header noise); `inst/doc/a2interactive.html` dissected by script
   block (vis-network ×3 = 1,069,799 B + html2canvas 124,573 B + 2 widget payloads
   33,421 B attributed; the 594 KB d3-based block and 17 embedded images excluded —
   conservative). Two compressed-attribution methods (independent gzip -9 vs proportional
   tarball share) agreed within 10%; report brackets both.
5. **Reconciliation:** bucket arithmetic reconciles to the byte (821,174 + 119,748 +
   43,062 + 2,258,954 − 14,635 double-count = 3,228,303 ✓).

**Self-assessment (Session 737): 9/10.** **Strengths:** (1) attribution built from
verified creation dates + usage greps, not filename pattern-matching; (2) two independent
compressed methods cross-checked; arithmetic reconciled exactly; (3) the audit's most
actionable number (widget payload ≈ 0.29 MB compressed) was forward-carried into the live
inst/doc BACKLOG item, not left buried in the report; (4) scope held (measurement only, no
remedy); full claim/receipt/ledger discipline kept. **Weaknesses:** (1) the partial-file
bucket is an upper bound by construction, not a measurement (bracketed, disclosed); (2)
the 17 embedded images in a2interactive.html (≤538 KB uncompressed) were left
unattributed — bounded and noted, but a per-image section mapping would have tightened
the compressed range.

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine audit-workstream session;
the durable findings live in the audit doc + the enriched BACKLOG item. **Reduction
check (FM #28):** `BACKLOG.md` shrank net (−18 lines item removal, +6 lines enrichment)
— a mandated-read file got smaller this session.

**Next steps (specific):** (A) ~3 unpushed commits after close-out (deliverable + records
+ sha; claim `0528da0e` also unpushed — recount with
`git rev-list --count origin/master..HEAD`, measured 5 before the sha commit → 6 after); CI current through `2628cd02`;
docs-only since, so a push session is routine when the owner wants one (S726–S736
precedent). (B) Priorities after this session: package-split disposition + REUSE
registration (owner decisions — the audit adds ammunition: the feature is 14.1% of R/
lines, and its tarball weight is mostly the widget payload, not code); BACKLOG.md
editorial compression (READY, L, `BACKLOG.md:227` area); inst/doc slimming (DECISION
NEEDED, M, `BACKLOG.md:100` — now with quantified savings: ~0.29 MB from the widget
replacement alone + the 0.4–0.9 MB html_vignette estimate). (C) Standing report-only set
unchanged: CLAUDE.md warn band; growth run (15/10 next if nothing shrinks — note
BACKLOG.md is not in the budget file, so this session's reduction won't reset it).

**Key files:** `docs/audits/PEDIGREE_DRAWING_FEATURE_GROWTH_AUDIT_2026-09-20.md` (the
deliverable), `CHANGELOG.md:41` (S737 entries at top), `BACKLOG.md:100` (inst/doc item,
now enriched), `HANDOFFS.md:158` (S737 receipt).

**Gotchas for the next session:** (1) Expect 0 undocumented commits at next Phase 0 —
measure it; 6 unpushed after close-out (measured: 2 carried S736 commits + 4 S737). (2) The audit's shipping filter
approximates `.Rbuildignore` in a scratchpad script — if anyone re-derives the numbers,
§5 of the audit has the reproduction commands; scratchpad copies do not survive the
session. (3) `pkgbuild::build()` on a clean export takes ~4 min locally and its output
tarball differs from the gate figure by ~5 B (gzip mtime header) — not a discrepancy.
(4) Standing set unchanged: `gh run list --commit` needs the FULL 40-char sha;
`scratchpad/` invisible to git BY OWNER DECISION; ratchet ~2 min AFTER committing
(Learning 772); trim needs `--budget-bytes 65536`; renv banner expected; CLAUDE.md warn
band; the two `SESSION_NOTES.md` ceilings differ (owner decision pending); suite baseline
2437/0/0/184/0 remote-confirmed on `2628cd02`.

### Session 735 Handoff Evaluation (by Session 736)
**Score: 9/10.** **What helped:** "~2 unpushed" measured exactly 2; "expect 0
undocumented; measure it" measured 0 on both frontiers; the ratchet citation matched
`.quality-gates-results.json` byte-for-byte; the priorities list fed the Phase 0
picker directly. **What was missing:** the carried CI-monitor mechanics
("poll `gh run list --commit <sha>`") never say the sha must be the FULL 40-char
form — a short sha silently returns an empty list, and this session's monitor sat
silent through an entirely green run for its whole 30-min arm because of it (whether
prior sessions polled with full shas is not verifiable from the notes, which print
short shas throughout). **What was wrong:** nothing found — every checked claim held;
the ~21–22 min R-CMD-check figure was an overestimate this time (17m39s) in the safe
direction. **ROI:** high.

### What Session 736 Did
**Deliverable:** Owner-directed push to `origin/master` + CI verification — **DONE.**
Pushed `3b29f498..2628cd02` (3 commits: the 2 unpushed S735 close-out commits —
records `1296c6e6`, sha `dd8ea5a7` — + the S736 claim `2628cd02` riding the push,
S726–S735 precedent). All 4 push-triggered workflows `completed success` ON THE
PUSHED SHA `2628cd02` (verified via `gh run list --commit <full-sha>` with `headSha`
echoed back structurally): lint 4m56s (id 35541807254), pkgdown 7m01s (35541807276),
test-coverage 10m02s (35541807240), R-CMD-check 17m39s (35541807302) — fastest
post-S732-fix figure yet (prior band 21m28s–22m17s). No TDD phases (push + docs; no
`.R` files). Lint N/A.
**Started/completed:** 2026-09-20 (single session). Claim `2628cd02` (rode the push);
records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, push+CI deliverable, records,
sha). No BACKLOG item consumed (the push was a Phase 0 owner pick).

**What actually happened, in order:**
1. **Phase 0:** full 8-step orient; reconcile clean (0 undocumented on both frontiers
   at `dd8ea5a7`; S735 receipt complete, ratchet citation matches results file); CI
   4/4 green on `3b29f498`; dashboard 96/100; 2 unpushed measured (= S735's
   estimate); 5 known untracked files unchanged. Context budget: CLAUDE.md warn band,
   growth run 13/10 — and the `SESSION_RUNNER.md`/`SAFEGUARDS.md`
   differs-from-canonical flags are GONE (both `synced / canonical ok`; tree clean,
   no local change — the checker's reference caught up). Report-only.
2. **Owner picked the push** via the Phase 0 AskUserQuestion picker.
3. **Claim committed and rode the push:** `2628cd02`; push `3b29f498..2628cd02`;
   0 unpushed after the push — `origin/master` fully current.
4. **CI verification:** the first Monitor arm polled `gh run list --commit 2628cd02`
   (SHORT sha) — which silently returns an empty list — and expired after 30 min with
   zero events while all 4 workflows completed green underneath it. Direct check with
   the full sha (`git rev-parse`) returned all 4 `completed success` with `headSha`
   matching exactly; conclusions verified from the JSON, not inferred from silence.
5. **quality_ratchet at the pushed HEAD `2628cd02`:** 1/1 pass · 0 fail · 0 unmeasured
   · results 847588b5cc75 · manifest aa983075d6a2 (3,483,944 B ≤ 5,000,000 B).

**Self-assessment (Session 736): 8/10.** **Strengths:** (1) deliverable verified on
the exact pushed sha structurally (`headSha` echoed from the JSON), run ids +
durations recorded; (2) the monitor's silence was treated as a signal to investigate,
not as "still running" — the root cause (short-sha filter) was pinned down and
recorded rather than the run being re-armed blind; (3) scope held; full
claim/receipt/ledger discipline kept. **Weaknesses:** (1) the 30-min silent arm was
avoidable — the filter was never smoke-tested against an in-flight run before arming
(a single foreground `gh run list --commit <sha>` while runs were queued would have
shown the empty list immediately); (2) durations are createdAt→updatedAt and include
queue time (seconds ±).

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine clean push (8th:
S717/S726/S729/S731/S733/S734/S735); the full-sha gotcha lives in the gotchas below
and the deliverable ledger entry. **Reduction check:** nothing removed from a
mandated-read file this session — none over ceiling (SESSION_NOTES.md ~32 KB live vs
65,536 B); stated explicitly per FM #28's decay term.

**Next steps (specific):** (A) No push pending at handoff-write time except this
close-out's own ~2 commits (records + sha, docs-only, estimate) — recount with
`git rev-list --count origin/master..HEAD`; CI current through `2628cd02`; no
urgency. (B) Priorities unchanged: pedigree-growth measurement (READY, S,
`BACKLOG.md:117`); package-split disposition + REUSE registration (owner decisions);
BACKLOG.md editorial compression (READY, L); inst/doc slimming (DECISION NEEDED, M,
`BACKLOG.md:100`). (C) Standing report-only set SHRINKS by one: the synced-files
differ-from-canonical signal cleared this session (verified `synced / canonical ok`);
the growth run (13/10) and CLAUDE.md warn band remain.

**Key files:** `CHANGELOG.md:41` (S736 entries at top), `HANDOFFS.md:158` (S736
receipt), `BACKLOG.md:117` (next natural pickup).

**Gotchas for the next session:** (1) **`gh run list --commit` requires the FULL
40-char sha** — a short sha returns an empty list with no error, so a monitor built
on it is blind while looking armed; capture it with `git rev-parse <short>` before
polling (found this session at the cost of one silent 30-min arm). (2) Expect 0
undocumented commits at next Phase 0 — measure it; ~2 unpushed (estimate at write
time). (3) R-CMD-check 17m39s on `2628cd02` — post-fix range now 17m39s–22m17s; one
30-min Monitor arm suffices. (4) The differs-from-canonical flags on
`SESSION_RUNNER.md`/`SAFEGUARDS.md` cleared this run; if they reappear, it is the
checker's canonical reference moving, not local edits (S734 verification: last touch
`b773ddb6`, tree clean). (5) Standing set unchanged otherwise: `scratchpad/`
invisible to git BY OWNER DECISION; ratchet ~2 min, AFTER committing (Learning 772);
trim needs `--budget-bytes 65536`; renv banner expected; `CLAUDE.md` warn band; the
two `SESSION_NOTES.md` ceilings differ (owner decision pending); suite baseline
2437/0/0/184/0 — remote-confirmed again by R-CMD-check on `2628cd02`.

### Session 734 Handoff Evaluation (by Session 735)
**Score: 9/10.** **What helped:** every forward-looking claim held exactly — "~2
unpushed" measured 2, "expect 0 undocumented; measure it" measured 0 on both
frontiers, and the CI-wait figure (~21–22 min R-CMD-check, one 30-min Monitor arm)
measured 21m28s with no re-arm; the `--commit` filter mechanics and the
differs-from-canonical don't-re-sync-reflexively gotcha carried unchanged. **What was
missing:** nothing material. **What was wrong:** nothing found. **ROI:** high, though
lightly exercised — the pickup happened in the same conversation minutes after the
handoff was written, so discovery cost was near zero regardless.

### What Session 735 Did
**Deliverable:** Owner-directed push to `origin/master` + CI verification — **DONE.**
Pushed `75d2b049..3b29f498` (3 commits: the 2 unpushed S734 close-out commits —
records `be4f41ce`, sha `12218ad2` — + the S735 claim `3b29f498` riding the push,
S726/S729/S731/S733/S734 precedent). All 4 push-triggered workflows `completed
success` ON THE PUSHED SHA `3b29f498` (verified via `gh run list --commit <sha>`, sha
match structural): lint 5m14s (id 35539906766), pkgdown 6m04s (35539906763),
test-coverage 9m51s (35539906801), R-CMD-check 21m28s (35539906788) — the post-S732-fix
~21–22 min figure confirmed a THIRD consecutive time; single 30-min Monitor arm, no
re-arm. No TDD phases (push + docs; no `.R` files). Lint N/A.
**Started/completed:** 2026-09-20 (single session, same conversation as S734). Claim
`3b29f498` (rode the push); records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, push+CI deliverable, records,
sha). No BACKLOG item consumed (owner-directed push).

**What actually happened, in order:**
1. **Abbreviated re-orient (same conversation, state minutes old):** git state,
   unpushed count (2, matching S734's estimate), and both ledger frontiers re-measured
   (0 undocumented); the full 8-step orient, dashboard, CI check, and priorities
   report had run minutes earlier in S734's Phase 0 and were not re-run — noted
   honestly rather than claimed.
2. **Claim committed and rode the push:** `3b29f498`; push `75d2b049..3b29f498`;
   0 unpushed after the push — `origin/master` fully current.
3. **CI verification:** Monitor polling `gh run list --commit 3b29f498` at 60 s,
   emitting every terminal conclusion; all 4 green in 21m28s wall.
4. **quality_ratchet at the pushed HEAD `3b29f498`:** 1/1 pass · 0 fail · 0 unmeasured
   · results 0c58d203ae28 · manifest aa983075d6a2 (3,483,951 B ≤ 5,000,000 B).

**Self-assessment (Session 735): 9/10.** **Strengths:** (1) deliverable verified on
the exact pushed sha by construction, run ids + durations recorded; (2) the
same-conversation pickup was re-measured mechanically (state, frontiers) rather than
assumed from memory; (3) scope held; full claim/receipt/ledger discipline kept even
for a 2-commit push. **Weaknesses:** (1) Phase 0 was abbreviated (dashboard, issues,
SAFEGUARDS re-read not repeated) — defensible minutes after a full orient in the same
conversation, but it is a deviation to name, not hide; (2) durations are
createdAt→updatedAt and include queue time (seconds ±).

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine clean push (7th:
S717/S726/S729/S731/S733/S734). **Reduction check:** nothing removed from a
mandated-read file this session — none over ceiling (SESSION_NOTES.md ~20 KB live,
ample headroom); stated explicitly per FM #28's decay term.

**Next steps (specific):** (A) No push pending at handoff-write time except this
close-out's own ~2 commits (records + sha, docs-only, estimate) — recount with
`git rev-list --count origin/master..HEAD`; CI current through `3b29f498`; no urgency.
(B) Priorities unchanged: pedigree-growth measurement (READY, S, `BACKLOG.md:117`);
package-split disposition + REUSE registration (owner decisions); BACKLOG.md
editorial compression (READY, L); inst/doc slimming (DECISION NEEDED, M,
`BACKLOG.md:100`). (C) Standing report-only set unchanged from S734, including the two
context-budget signals (growth run; synced-files differ-from-canonical).

**Key files:** `CHANGELOG.md:41` (S735 entries at top), `HANDOFFS.md:158` (S735
receipt), `BACKLOG.md:117` (next natural pickup).

**Gotchas for the next session:** (1) Expect 0 undocumented commits at next Phase 0 —
measure it; ~2 unpushed (estimate at write time). (2) R-CMD-check 21m28s on
`3b29f498` — the ~21–22 min figure is confirmed three times running; one 30-min
Monitor arm suffices. (3) The `SESSION_RUNNER.md`/`SAFEGUARDS.md`
differs-from-canonical flags remain NOT local edits — don't re-sync reflexively (see
S734 gotcha 3; a fork-main sync is its own session with the `methodology_trim.py`
patch procedure). (4) Standing set unchanged: `scratchpad/` invisible to git BY OWNER
DECISION; ratchet ~2 min, AFTER committing (Learning 772); trim needs
`--budget-bytes 65536`; renv banner expected; `CLAUDE.md` warn band; the two
`SESSION_NOTES.md` ceilings differ (owner decision pending); suite baseline
2437/0/0/184/0 — remote-confirmed again by R-CMD-check on `3b29f498`.

### Session 733 Handoff Evaluation (by Session 734)
**Score: 9/10.** **What helped:** the "~3 unpushed" estimate measured exactly 3; the
CHANGED CI-wait gotcha (R-CMD-check ~21–22 min post-fix, fits one 30-min Monitor arm)
was exact — measured 22m17s, no re-arm; "expect 0 undocumented; measure it" measured 0
on both frontiers; the ratchet citation matched `.quality-gates-results.json`
byte-for-byte; the priorities list fed straight into the Phase 0 picker and the
`--commit` filter mechanics carried unchanged. **What was missing:** the context-budget
run surfaced two signals not itemized by S733's "WARN = CLAUDE.md warn band only" —
a growth-run 12/10 warning and "differs from canonical" flags on
`SESSION_RUNNER.md`/`SAFEGUARDS.md`; whether they were present at S733's run is not
verifiable from the handoff, and pinning them down cost a small verification detour.
**What was wrong:** nothing found — every checked claim held. **ROI:** high.

### What Session 734 Did
**Deliverable:** Owner-directed push to `origin/master` + CI verification — **DONE.**
Pushed `5ed0da83..75d2b049` (4 commits: the 3 unpushed S733 close-out commits — trim
`484c46de`, records `6fb68007`, sha `c09d7b5a` — + the S734 claim `75d2b049` riding
the push, S726/S729/S731/S733 precedent). All 4 push-triggered workflows `completed
success` ON THE PUSHED SHA `75d2b049` (verified via `gh run list --commit <sha>`, sha
match structural): lint 5m11s (id 35536061548), pkgdown 6m03s (35536061442),
test-coverage 10m35s (35536061510), R-CMD-check 22m17s (35536061496) — the ~21–22 min
post-S732-fix figure confirmed a second time; the monitor's single 30-min arm was
enough, no re-arm. No TDD phases (push + docs; no `.R` files). Lint N/A.
**Started/completed:** 2026-09-20 (single session). Claim `75d2b049` (rode the push);
records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, push+CI deliverable, records,
sha). No BACKLOG item consumed (the push was a Phase 0 owner pick).

**What actually happened, in order:**
1. **Phase 0:** full 8-step orient; reconcile clean (0 undocumented on both frontiers
   at `c09d7b5a`; S733 receipt complete, ratchet citation matches results file); CI 4/4
   green on `5ed0da83` + scheduled shinytest2 green; dashboard 96/100; 3 unpushed
   measured (= S733's estimate); 5 known untracked files unchanged. Context budget:
   CLAUDE.md warn band PLUS two signals new-to-the-record — growth run 12/10, and
   `SESSION_RUNNER.md`/`SAFEGUARDS.md` "differs from canonical (matches no revision in
   canonical history)." Verified NOT local edits: both files last touched by the S719
   forced sync `b773ddb6`, clean in the working tree — the checker's comparison target
   moved (fork-vs-canonical provenance). Report-only.
2. **Owner picked the push** via the Phase 0 AskUserQuestion picker.
3. **Claim committed and rode the push:** `75d2b049`; push `5ed0da83..75d2b049`;
   0 unpushed after the push.
4. **CI verification:** Monitor polling `gh run list --commit 75d2b049` at 60 s,
   emitting every terminal conclusion (not success-only); all 4 green in 22m17s wall.
5. **quality_ratchet at the pushed HEAD `75d2b049`:** 1/1 pass · 0 fail · 0 unmeasured
   · results 84231b1581ab · manifest aa983075d6a2 (3,483,934 B ≤ 5,000,000 B).

**Self-assessment (Session 734): 9/10.** **Strengths:** (1) deliverable verified on the
exact pushed sha by construction (`--commit` filter), run ids + durations recorded;
(2) the two new context-budget signals were pinned down at Orient (git log on both
synced files ruled out local edits) instead of being either ignored or "fixed" — the
report-don't-fix rule held; (3) scope held through the CI wait; (4) monitor filter
covered all terminal states, not just success. **Weaknesses:** (1) durations are
createdAt→updatedAt and include queue time (seconds ±); (2) whether the
differs-from-canonical flags predate this session could not be established — recorded
as unverifiable rather than guessed.

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine clean push (6th of its
kind: S717/S726/S729/S731/S733). **Reduction check:** nothing removed from a
mandated-read file this session — none was over ceiling (SESSION_NOTES.md ~17 KB live,
ample token-cap headroom); stated explicitly per FM #28's decay term.

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~2 expected after close-out: records + sha;
both docs-only, estimated at write time; no urgency — CI is current through
`75d2b049`). (B) Priorities: pedigree-growth measurement (READY, S, `BACKLOG.md:117`);
package-split disposition + REUSE registration (owner decisions); BACKLOG.md editorial
compression (READY, L); inst/doc slimming (DECISION NEEDED, M, `BACKLOG.md:100`).
(C) Standing report-only set now INCLUDES the two new context-budget signals (growth
run; synced-files differ-from-canonical) — surface them at Phase 0 until resolved or
owner-dispositioned.

**Key files:** `CHANGELOG.md:41` (S734 entries at top), `HANDOFFS.md:158` (S734
receipt), `BACKLOG.md:117` (next natural pickup).

**Gotchas for the next session:** (1) Expect 0 undocumented commits at next Phase 0 —
measure it; ~2 unpushed (estimate at write time). (2) CI-wait mechanics: R-CMD-check
22m17s on `75d2b049` — the ~21–22 min figure is now confirmed twice; one 30-min
Monitor arm suffices. (3) The `SESSION_RUNNER.md`/`SAFEGUARDS.md`
differs-from-canonical flags are NOT local edits (verified this session: last touch
`b773ddb6`, tree clean) — do NOT re-sync reflexively; a fork-main sync carries the
`methodology_trim.py` patch procedure (`CLAUDE.md` §methodology_trim local-customization
checklist) and is its own session with an owner decision. (4) Standing set unchanged
otherwise: `scratchpad/` invisible to git BY OWNER DECISION; ratchet ~2 min, AFTER
committing (Learning 772); trim needs `--budget-bytes 65536`; renv banner expected;
`CLAUDE.md` warn band; the two `SESSION_NOTES.md` ceilings differ (owner decision
pending); suite baseline 2437/0/0/184/0 — remote-confirmed again by R-CMD-check on
`75d2b049`.

### Session 732 Handoff Evaluation (by Session 733)
**Score: 9/10.** **What helped:** next-step (A) named the push decision with the exact
recount command, and the fix commit's `.R`/`.Rd` framing ("a push gets it remote
R-CMD-check validation") was this session's stakes exactly; "expect 0 undocumented;
measure it" measured 0 on both frontiers; the ratchet citation matched
`.quality-gates-results.json` byte-for-byte; the gotcha "next handoff will need a trim"
(file ~350 B under the token cap) was exact — the claim stub fit with 151 B to spare and
the handoff forced the trim, precisely as predicted; the carried CI-wait mechanics
(filter with `gh run list --commit <sha>`) set up the monitor correctly. **What was
missing:** nothing material. **What was wrong:** the "~6 unpushed" estimate (and the sha
entry's "ahead by 6") undercounted by one — S732's own HANDOFFS trim commit was missing
from its own arithmetic; measured 7. Low harm: the recount command was given and caught
it immediately. **ROI:** high.

### What Session 733 Did
**Deliverable:** Owner-directed push to `origin/master` + CI verification — **DONE.**
Pushed `3b688ae2..5ed0da83` (8 commits: the 7 unpushed S732 commits incl. the CRAN
check-time fix `ba088d0d` touching `.R`/`.Rd`, + the S733 claim riding the push —
S726/S729/S731 precedent). All 4 push-triggered workflows `completed success` ON THE
PUSHED SHA `5ed0da83` (verified via `gh run list --commit <sha>`, sha match structural):
lint 3m56s (id 35534412900), pkgdown 6m13s (35534413059), test-coverage 10m33s
(35534412911), **R-CMD-check 21m28s (35534412936) — down from 33m37s on the previous
push (`3b688ae2`): the first remote-side confirmation of the S732 fix, −12 min of CI.**
The expected monitor re-arm never happened because the check now fits one 30-min arm.
No TDD phases (push + docs; no `.R` files). Lint N/A.
**Started/completed:** 2026-09-20 (single session). Claim `5ed0da83` (rode the push);
trim `484c46de`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, trim, push+CI deliverable,
records, sha). No BACKLOG item consumed (the push was a next-steps owner decision).

**What actually happened, in order:**
1. **Phase 0:** full 8-step orient; reconcile clean (0 undocumented on both frontiers at
   `ee7cb230`; S732 receipt complete, ratchet citation matches results file); CI 4/4
   green on `3b688ae2` + scheduled shinytest2 green; dashboard 96/100; context budget
   WARN = CLAUDE.md warn band only; 7 unpushed measured; 5 known untracked files
   unchanged; audits dir unchanged since S730's check.
2. **Claim committed and rode the push:** `5ed0da83`; push `3b688ae2..5ed0da83`.
3. **CI verification:** Monitor polling `gh run list --commit 5ed0da83` at 60 s; all 4
   green in 21m28s wall (R-CMD-check the last) — no re-arm needed.
4. **quality_ratchet at the pushed HEAD `5ed0da83`:** 1/1 pass · 0 fail · 0 unmeasured ·
   results 7ced9faa4709 · manifest aa983075d6a2 (3,483,941 B ≤ 5,000,000 B).
5. **SESSION_NOTES trim (`484c46de`), pre-handoff:** file was 151 B under the 56,750 B
   token cap; archived 14 records (56,599 → 10,583 B) to
   `docs/archive/SESSION_NOTES-through-2026-09-19-3.md`, L1/L2/L3 verified before commit;
   SRF_RED overridden per the established Learning 549/586/587 resolution.

**Self-assessment (Session 733): 9/10.** **Strengths:** (1) deliverable verified on the
exact pushed sha by construction (`--commit` filter), run ids + durations recorded;
(2) the predicted trim was handled proactively on committed state BEFORE the handoff
could trip the hook, with the shard verify script run pre-commit; (3) scope held through
the CI wait; (4) the R-CMD-check duration drop was recognized and recorded as the fix's
remote confirmation, not just "still green." **Weaknesses:** (1) `methodology_trim.py
--cut N` semantics (N = records KEPT, not cut) were discovered by dry run, not known
going in — the accepted trim is more aggressive than first intended (3 records live),
though lossless and within precedent; (2) durations are createdAt→updatedAt and include
queue time (seconds ±).

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine clean push (5th of its
kind: S717/S726/S729/S731). The `--cut` semantics note lives in the gotchas below.
**Reduction check:** 14 records removed from a mandated-read file this session (the trim).

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~3 expected after close-out: trim + records
+ sha; all docs-only, last two estimated at write time; no urgency — CI is current
through `5ed0da83`). (B) Priorities: pedigree-growth measurement (READY, S,
`BACKLOG.md:117`); package-split disposition + REUSE registration (owner decisions);
BACKLOG.md editorial compression (READY, L); inst/doc slimming (DECISION NEEDED, M,
`BACKLOG.md:100`). (C) Standing report-only set unchanged from S732.

**Key files:** `CHANGELOG.md:41` (S733 entries at top), `HANDOFFS.md:158` (S733
receipt), `docs/archive/SESSION_NOTES-through-2026-09-19-3.md` (new shard),
`BACKLOG.md:117` (next natural pickup).

**Gotchas for the next session:** (1) Expect 0 undocumented commits at next Phase 0 —
measure it; ~3 unpushed (estimate at write time). (2) **CI-wait mechanics CHANGED:
R-CMD-check is now ~21–22 min on the remote after the S732 fix — it fits inside a
single 30-min Monitor arm; the ~34 min / expect-one-re-arm figure is obsolete**
(measured this session on `5ed0da83`). (3) `methodology_trim.py --cut N` keeps the
newest N records and archives the rest — dry-run (no `--write`) first; SESSION_NOTES.md
is now 10.6 KB live with several sessions of headroom before the 56,750 B token cap
binds again. (4) Standing set unchanged: `scratchpad/` invisible to git BY OWNER
DECISION; ratchet ~2 min, AFTER committing (Learning 772); trim needs
`--budget-bytes 65536`; renv banner expected; `CLAUDE.md` warn band; the two
`SESSION_NOTES.md` ceilings differ (owner decision pending); suite baseline
2437/0/0/184/0 — remote-confirmed again by R-CMD-check on `5ed0da83`.

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

