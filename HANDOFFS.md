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

This file gains a receipt every session and Phase 0 reads it every session, so it carries the same
size discipline as `CHANGELOG.md`: **two caps, two distinct failure modes, fire if either fires,
stop only when both stop conditions hold.**

| Cap | Protects against | Form | Fire when | Cut until |
|---|---|---|---|---|
| **Lines** — ~2,000, the agent `Read` truncation cap | **silent truncation**: a read past the cap returns no error and no marker | a **rate** | headroom < **15** receipts | headroom > **30** |
| **Bytes** — a per-file budget, default **65,536 B** (64 KB) | **context tax**: every session pays for the whole file, every time | a **level with hysteresis** | `size > budget` | `size ≤ ½ × budget` |

**Run this rather than estimating it:**

```sh
python3 methodology_trim.py --file HANDOFFS.md --check
```

`--check` evaluates both conditions and never writes. `--write` performs the trim, refuses unless it
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
  docs/archive/HANDOFFS-*.md` — or it silently counts a shrunken population.

If a `CHANGELOG.md` sits beside this file, its own **Size, and when to archive** section carries the
reasoning both files share: why the line cap must be a rate, why the byte cap cannot be one, and how
to choose the budget. Everything needed to *act* is here.

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

This file currently holds **2** receipt(s). Computed by `methodology_trim.py` on every
`--check`/`--write` run, never hand-maintained.

**Archived 116 record(s), 2026-08-14 → 2026-09-17** into [`docs/archive/HANDOFFS-through-2026-09-17.md`](docs/archive/HANDOFFS-through-2026-09-17.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 13 record(s), 2026-09-17 → 2026-09-18** into [`docs/archive/HANDOFFS-through-2026-09-18.md`](docs/archive/HANDOFFS-through-2026-09-18.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

```handoff
session: S716
date: 2026-09-18
status: pending
active_task: MHC Haplotype Reporting follow-up polish (BACKLOG Housekeeping item, issue #148 Slice 4 close-out) — display-only frequency rounding in output$mhcSummaryTable (strict TDD), modMarkerGeneticsUI() @return update, two stale "no Shiny screen yet" NEWS.Rmd phrases + NEWS.md re-render. Claimed, work beginning.
what_was_done: pending
commit: pending
```

```handoff
session: S715
date: 2026-09-18
status: complete
self_score: 9
predecessor_score: 8
active_task: Curved duplicate-connectors fix — DONE, owner-ratified at every TDD gate. .resolveEdgeNodeCollisions()'s curved branch now selects roundness by scoring the PAINTED arc for true disc hits (exact cubic-solve predicate, conservative Lipschitz prefilter) over the ladder seq(0.05, 0.60, 0.05), replacing the blind +0.3 bump; curved-heuristic residuals now disclose exactly the arcs no step fully clears. No open work from this session.
what_was_done: PRE-RED probe (continuity 56/587/117 exact, ladder counterfactual: 114 of 170 truly collide, 42 cleared, events 587 -> 149, residual 72, no arc worse, +4.4 s unoptimized). RED d39c66eb (7 honest failures: helper units, never-worse property, false-positive pair keeps 0.2, __dup_0L5AWR_1 clears at 0.5, residual/true-hit correspondence, 56L -> 72L, exemplar pins flipped). GREEN 704d7c4c (R/makePedigreeDiagramData.R only: .curvedCwVia/.bezierPointAt/.bezierMinDistTo/.arcDiscHitCount + preference-ordered ladder walk; prefilter keeps counts provably identical, resolve 0.21 -> 0.95 s). Full suite 2,436 blocks 0 failed/0 error (warnings 48 -> 40 = cleared collision warnings); the 1 initial failure was S714's stale px wordlist flag, root-caused NOT this diff, fixed fa4ec9ad (Learning 764). Lint 0. devtools::check 0 errors + known 1 W/1 N untracked-file artifacts. Census re-run 69152999 (postfix CSV, frozen baselines untouched): cArc 587 -> 149, cArcEdges 117 -> 72, Track C fully clean, class (b) = 6 unchanged (article NOT re-obligated). Exemplar re-renders owner-ratified at the GREEN gate. Also: Phase 0 backfill 62b57d76; claim d5008091 repaired S714's duplicate-S713 receipt fragment in this file. Records commit follows this receipt.
next_steps: (A) MHC polish (Housekeeping, S) — the top remaining READY BACKLOG item, full brief in the block. (B) Push decision (owner): ~21 commits ahead (recount with git rev-list --count origin/master..HEAD); the delta now includes real package code (this fix), so the next push's CI round is its first remote validation. (C) Pointer-block sweep ratification (DECISION NEEDED, M). (D) Owner decisions pending: package-split disposition, REUSE registration.
key_files: R/makePedigreeDiagramData.R:2404 (arc helpers) and R/makePedigreeDiagramData.R:2982 (curved branch), tests/testthat/test_resolveEdgeNodeCollisions.R:314 (rewritten curved section), tests/testthat/test_examplePedigreeFixtures.R:183 (flipped exemplar specs), docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-18_postfix_findings.csv:1 (new standing baseline), data-raw/pedigreeDrawingErrorCensus.R:79 (postfix CSV name), NEWS.Rmd:209 (entry), PROJECT_LEARNINGS.md:2223 (Learning 764), scratchpad/s715_probe.R:1 + s715_render.R:1 + s715_layouts.rds (evidence; s715_layouts.rds$R is the current-engine Real-375 layout)
gotchas: Fresh baseline now 2,436 blocks (failed=0 error=0 skipped=184 warning=40); +2 = new helper units, warnings -8 = cleared collision warnings. Carried-baseline heuristic hole: a docs-only session editing .qmd/.Rmd prose owes test_wordlist_coverage.R before carrying a baseline forward (Learning 764). s712_layouts.rds is STALE for edge styling (pre-fix roundness) — use s715_layouts.rds. The census standing baseline is the _postfix CSV (149/72); never compare cArc against 587 as same-state. Resolve now ~0.95 s on Real 375 (arc scoring); prefilter margin + 64-sample count are the tuning knobs if layout time ever matters, census as referee. Expect ~1 self-reference commit past the CHANGELOG frontier at next Phase 0.
runtime_smoke: live chromote renders through the app's own widget construction (the S712/S714-verified path): linebreeding + half_sib full views and Real-375 before/after site crops (scratchpad/s715_render_*.png), owner-reviewed and ratified at the GREEN gate; the census re-run measures the shipped engine output itself
changelog_ref: S715 entries at the top of CHANGELOG.md (claim + close-out, 2026-09-18)
commit: ef575abb
```
S715 self-score 9/10: + probe-first counterfactual meant RED encoded measured expectations GREEN reproduced to the digit; + the never-worse property is a mechanism guarantee, not a pin; + performance solved with a provably-conservative prefilter (counts identical by construction, verified), never a weakened predicate; + the latent S714 suite failure was root-caused before fixing; - the Real-375 crops do not visually isolate the single fixed arc (density; census overlap join is the ground truth, disclosed per the S712-S714 pattern); - one wasted render iteration on the first site-crop framing. Predecessor (S714) scored 8/10: complete brief (mechanism, pointers, pins, constraints) and accurate content claims throughout; deductions for the corrupted duplicate-S713 receipt fragment its records commit left in this file (repaired at S715 claim) and the unflagged exemplar warning pins + same-day CSV-name collision, plus the px wordlist flag it left failing unrun (Learning 764).

```handoff
session: S714
date: 2026-09-18
status: complete
self_score: 9
predecessor_score: 9
active_task: Census curved-chord arc-modelling measurement pass — DONE, owner-ratified; follow-up fix item filed (arc-verified roundness selection, READY, M). No open work from this session beyond that item.
what_was_done: Modelled the arc vis-network actually paints (curvedCW quadratic Bezier; via formula transcribed from the bundled vis-network.min.js and verified against the LIVE widget to 1.1e-13 px over all 173 curved edges). Result — the 1,668-row chord heuristic was 100 percent false positives AND blind to every true hit; the true population is 587 arc-inside-symbol events on 117 of 170 Real-375 connectors (Track C arc-clean): 485 events on cross-row connectors nothing ever checked, 102 from bumped arcs crossing upper rows; the +0.3 roundness bump is net-negative on Real 375 (21 arcs hit at 0.2, 24 at 0.5). Census script extended with the exact c-arc-inside predicate (chord subclass retired, lint 0), re-run committed as the 2026-09-18 CSV (595 rows; class b = 6 at its first post-S713 re-run); article "8 of 237" updated to 6 of 237 per the S713 forward-carry; audit doc written. Incidental discovery: vis-network parseInt-truncates predefined node coordinates (Learning 763). Commits: backfill 9a096ed6, claim 88f563de, deliverable 318c32da, records commit after this receipt.
next_steps: (A) Curved-connector fix item (READY, M, strict TDD) — the new BACKLOG block carries the full brief (R/makePedigreeDiagramData.R curved branch, roundnessBump; port curvedCwVia()/bezierMinDistTo()/arcDiscHits() from the census script; re-derive test_resolveEdgeNodeCollisions.R pins 170/56/0.5; constraints S577 arc convention + S675 no-weight-tuning). (B) MHC polish (Housekeeping, S). (C) Push decision (owner) — 12 commits ahead at close-out, recount first. (D) Owner decisions pending: package-split, pointer-block sweep, REUSE registration.
key_files: docs/audits/PEDIGREE_DRAWING_CURVED_ARC_CENSUS_2026-09-18.md:1 (audit report), data-raw/pedigreeDrawingErrorCensus.R:441 (arc predicate), docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-18_findings.csv:1 (new baseline), vignettes/articles/kinship2-fidelity-validation.qmd:164 (6-of-237 site), BACKLOG.md:109 (the fix item), tests/testthat/test_resolveEdgeNodeCollisions.R:394 (56L pin), scratchpad/s714_probe.R:1 (evidence)
gotchas: Baseline still 2,434 blocks failed=0 error=0 (no package files touched). cArc/cArcEdges (587/117) is a NEW metric — never compare against the frozen 1,668 as same-metric. 2026-09-02 census artifacts stay frozen; 2026-09-18 CSV is the standing baseline. Expect ~1 self-reference commit past the CHANGELOG frontier at next Phase 0. The article's "6 of 237" re-obligates only on a class-(b) change, not on cArc changes. vis-network renders node coords parseInt-truncated (whole px) — pixel-exact reasoning must expect that.
runtime_smoke: n/a — measurement/docs session; no package runtime behavior changed (data-raw script + audit doc + article prose). The live-widget chromote verification doubled as a rendered-app check of the arc geometry itself.
changelog_ref: S714 entries at the top of CHANGELOG.md (claim + close-out, 2026-09-18)
commit: 8c717ee6
```
S714 self-score 9/10: continuity-first (frozen 1,668 reproduced to the row before any new claim), live-renderer verification of the model plus border-trim/quantization/jitter sensitivities before quoting counts, exact overlap join for the inversion finding, recommendation anchored to the measured net-negative bump; weaknesses — crops do not pixel-isolate a single offending arc (programmatic geometry, disclosed), and the audit doc briefly claimed the article edit before it landed (in-session ordering slip, corrected). Predecessor (S713) scored 9/10: exact deliverable pointer, forward-carry spelled out, frozen-CSV framing precise; stale "47 residuals" figure in the BACKLOG item and no vis-network.min.js breadcrumb were the only gaps.

```handoff
session: S713
date: 2026-09-18
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE, class CLOSED both ways, owner-ratified. Census class (b) assessment (S712 next-step A, owner-picked via AskUserQuestion at Phase 0): the 6 real 60-180 px off-centre union dots (__union_97/114/130/137/191/228) accepted as minSep-forced structural residuals, no fix item; the 2 numerical-noise rows (__union_75 ~2.8e-5 px, __union_132 ~1.0e-6 px) ratified out of the census predicate, which now uses the test suite's own 1e-3 raw-unit (0.12 px) solver-dust floor (data-raw/pedigreeDrawingErrorCensus.R, commit de4e6ce8). BACKLOG block removed per the S686 completed-item convention, with the census-re-run consequence forward-carried into the curved-chord item. Assessment session + one ratified data-raw edit; no package files touched, no TDD phases.
what_was_done: Phase 0 backfill 47905f6a (1 commit, ed79261f -- the predicted self-reconcile shape, measured exactly 1); claim 8e769e30. Probe (scratchpad/s713_probe.R + s713_probe2.R): continuity first -- frozen census reproduced TO THE DIGIT from s712_layouts.rds (max |diff| ~2e-15 u on all 8 rows) and from a fresh run (6 real rows to 1e-12); then trace()-captured .solveJointQP() inputs (5 components, target 733 variables), baseline re-solve reproduction check, and the two instruments: binding-chain analysis (every between-mates gap BINDING at its floor; chain-implied minimum offset == observed offset exactly, 0.5/0.5/1.0/1.5/1.0/0.5 u) and a wUnion sweep 2 -> 2e5 (offsets reducible ONLY via mate-span stretch, __union_137 480 -> 1,787 px) => minSep-forced at the ratified S675 weights. 4 neighbourhood crops (Learning 732 recipe) show each dot adjacent to its distal marry-in mate -- the conventional multiple-marriage chain. Owner gate (2 questions): accept-and-close ratified; adopt-floor-now ratified. Predicate edited and verified (old skip reproduces the frozen 8; new floor yields exactly the disclosed 6); lintr::lint_package() 0 lints. Coupled prose re-verified: Track B centering re-measured live (max 1.9e-11 px); "8 of 237" stays accurate as a frozen-baseline citation, count changes only at the next census re-run (forward-carried). Learning 762 appended (threshold alignment across measurement artifacts; the trace()-capture probe instrument; the silent NULL-propagation skip corollary, mechanism verified).
next_steps: (A) Census curved-chord (READY, M): arc-modelling measurement pass replacing the 1,668-chord upper bound; that pass now also owes the article's "8 of 237" update at its census re-run (BACKLOG forward-carry). (B) MHC polish (Housekeeping, S). (C) Owner decisions pending: package-split disposition, pointer-block sweep ratification, REUSE registration. (D) Informational: dashboard copy stale (v2.14.0 vs v2.18.0); untracked leftovers unchanged (+ s713_* scratchpad files, same class); LabKey remainder BLOCKED; local ahead of origin by this session's commits -- push decision is the owner's.
key_files: scratchpad/s713_probe.R:1 + scratchpad/s713_probe2.R:1 (two-instrument probe; results scratchpad/s713_probe_results.rds), scratchpad/s713_crop_A_wcpxhd.png (+ B_u97/C_u191/D_u228) (4 site crops), data-raw/pedigreeDrawingErrorCensus.R:346 (the ratified floor, de4e6ce8), tests/testthat/test_positionMatingUnitForest.R:2917 (the structural-residual test naming the same 6 -- the decisive context S712's handoff missed), CHANGELOG.md:29 (S713 entries), BACKLOG.md:109 (curved-chord with the forward-carry)
gotchas: (1) Fresh baseline still 2,434 blocks (failed=0, error=0, skipped=184, warning=48) -- no package files touched (data-raw only); S709's gotchas apply verbatim, read them in docs/archive/SESSION_NOTES-through-2026-09-18.md. (2) The census CSV remains frozen at 8 class-(b) rows -- do NOT edit it; the 6-row count exists only in a future re-run, which owes the article-figure update. (3) s712_layouts.rds remains valid (no R/ commits since S697); recompute if a layout-engine change lands. (4) Expect ~1 self-reference commit past the CHANGELOG frontier at next Phase 0; measure it. (5) The trace()-capture probe (Learning 762) needs capEnv in globalenv and translation-invariant comparisons (per-component packing shifts absolute x); a probe section can skip SILENTLY via NULL propagation -- check every section header has rows under it.
runtime_smoke: n/a -- no package runtime behavior changed (data-raw measurement script + docs/ledger edits only); the predicate edit's own verification is the old-vs-new threshold replication against the real layout (old=the frozen 8, new=exactly the disclosed 6), run live this session
changelog_ref: f67830a1
commit: f67830a1
```
Self-score 9/10: + continuity before counterfactuals (baseline re-solve had to reproduce production devs before any sweep was trusted); + two independent instruments agreeing exactly makes the verdict measurement, not judgment; + the escape route's cost quantified (span stretch 3.7x) rather than asserted; + tolerance anchored to an existing committed constant (the test's own floor) instead of a new invented one; + predicate edit verified against both thresholds. - Probe v1's 1a continuity section skipped silently (NULL propagation; caught by absent output, fixed in probe2, mechanism verified into Learning 762); - crops at neighbourhood zoom only, no pixel-ruler measurement in the render (geometry established programmatically, matching the S712 disclosure pattern). Predecessor 9/10: next-step A was the exact deliverable with both populations enumerated and exact code pointers; the layout cache reproduced the census to the digit; the crop recipe ran zero-failure; the only material gap was the committed structural-residual test that already named the 6 -- this session's most decisive context, found via a doc-comment cross-reference instead of the handoff.

```handoff
session: S712
date: 2026-09-18
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE, item CLOSED as acceptable. Census class (d) duplicate-adjacent assessment (S711 next-step A, owner-picked via AskUserQuestion at Phase 0): both sites rendered as 100%/2.2x/context crops (6 PNGs), local geometry verified programmatically against fresh current-engine layouts, verdict owner-ratified via a second AskUserQuestion with the crops in front of them. BACKLOG block removed per the S686 completed-item convention. Assessment session, no package files touched, no TDD phases.
what_was_done: Phase 0 backfill e099a6f9 (1 commit, 1788e2b8 -- the predicted self-reconcile shape, measured exactly 1); claim 7a3a49f4. Probe (scratchpad/s712_probe.R) recomputed BOTH fixture layouts fresh (default rectilinear) rather than trusting the S696 cache: census rows reproduced to the digit (Track C dx=120.0 exactly, Real 375 dx=119.9999999992; both same-row, zero nodes between; dashed dup-connector present in the edge frame at both sites). Crops via the Learning 732 recipe (scratchpad/s712_crop.R, moveTo + raw-viewport capture): Track C reads cleanly (70-px rim gap, connector plainly visible); Real 375 structurally identical but the short connector is obscured by unrelated long-range chords -- a class (c) density issue, not an adjacency defect (extra separation would lengthen the connector and worsen exactly that clutter). Owner ratified: acceptable, close, no separation follow-up. Coupled-prose check: fidelity article has zero class-(d) references (grep-verified), nothing owed. Also closed S711's open loop: R-CMD-check on the close-out head completed green in-session (4/4, run 35390065689). No new learning appended (routine assessment on existing recipes; stated, not silent).
next_steps: (A) Census class (b) (READY, M): decide the census-predicate tolerance for the 2 noise rows, then assess whether the 6 real 60-180 px union-dot offsets are minSep-forced or QP-reducible (R/makePedigreeDiagramData.R, .solveJointQP()); re-verify the coupled fidelity-article prose; scratchpad/s712_layouts.rds + s712_crop.R are a ready-made render path for the same fixtures. (B) Census curved-chord (READY, M): arc-modelling measurement pass replacing the 1,668-chord upper bound -- this session's Real-375 site is a concrete motivating example. (C) MHC polish (Housekeeping, S). (D) Owner decisions pending: package-split disposition, pointer-block sweep ratification, REUSE registration. (E) Informational: dashboard copy stale (v2.14.0 vs v2.18.0); R/appServer.R:168 re-throw observer reported-not-changed; untracked leftovers unchanged; LabKey remainder BLOCKED; local ahead of origin by this session's commits -- push decision is the owner's.
key_files: scratchpad/s712_probe.R:1 (geometry probe), scratchpad/s712_crop.R:1 (reusable crop renderer, fixture-keyed), docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-02_findings.csv:3 (Track C row) and :1679 (Real 375 row -- CSV unchanged, frozen audit record), CHANGELOG.md:29 (S712 entries), BACKLOG.md:109 (class b, now the top census item), BACKLOG.md:128 (curved-chord)
gotchas: (1) Fresh baseline still 2,434 blocks (failed=0, error=0, skipped=184, warning=48) -- no package files touched; S709's gotchas apply verbatim, read them in docs/archive/SESSION_NOTES-through-2026-09-18.md. (2) s712_layouts.rds was computed at S712 -- recompute before reuse if any layout-engine change lands (the probe rebuilds both layouts in ~3 s; the ~2-min figure in s696_crop.R's header predates the QP engine's current speed). (3) The census CSV is frozen -- a closed class is NOT edited out of it; closure lives in CHANGELOG.md. (4) Expect ~1 self-reference commit past the CHANGELOG frontier at next Phase 0; measure it. (5) The makePedigreeMatingLayout() unresolved-collision warning (1 Track C, 56 Real 375) is the documented residual disclosure, not a regression signal.
runtime_smoke: live chromote renders of the real engine's own layout output ARE the deliverable's runtime evidence (6 captures, both fixtures); no package runtime behavior changed -- docs/BACKLOG/ledger edits only
changelog_ref: 263d48ec
commit: 263d48ec
```
Self-score 9/10: + fresh layouts instead of the stale cache closed the engine-drift question before it could taint the evidence; + programmatic verification BEFORE rendering means the crops illustrate a measured fact (census values reproduced to the digit) rather than stand in for one; + proven recipe reuse, zero failed render iterations; + tight scope, class-(c) concern routed to its existing item. - The Real-375 short connector's presence is established programmatically but not pixel-confirmed at that site (obscured by chord clutter; disclosed at the gate); - no learning row (correct, no signal, but stated). Predecessor 9/10: next-step A was the exact deliverable with site ids, values, precedent pointer, and the exact BACKLOG line; gotcha 3's 1-commit shape measured exactly 1; gotcha 2's CI framing proved out (completed green in-session); nothing wrong found; only the crop recipe's location (Learning 732/scratchpad) was left to one grep.

```handoff
session: S711
date: 2026-09-18
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Owner-directed push to origin/master (S710 next-step A, owner-picked via AskUserQuestion at Phase 0): 34 commits pushed (955f6f19..afd33514), spanning S708 MHC Slice 4, the S709 export-preview crash fix, and the S710 ledger archive pass. All 4 on-push CI workflows green on afd33514 -- lint 5m43s, test-coverage 9m58s, pkgdown 16m52s, R-CMD-check 33m22s (runs 35386636842/857/853/874), watched to completion in-session and confirmed directly. Process/ops action, no code changes, no TDD phases.
what_was_done: Phase 0 backfill 83618479 (1 commit, 0f7f94fe -- the predicted self-reconcile shape, measured exactly 1); claim afd33514 written BEFORE the push so the pushed head carries the session's own breadcrumb. Push executed, background watcher polled to matrix completion, conclusions re-verified via gh run list before recording. Close-out records committed and pushed immediately after (second push; its CI round is next Phase 0's to verify, per the S706 precedent). Nothing removed from BACKLOG.md (the push was a handoff next-step, not a BACKLOG block); no new learning appended (routine session, no signal -- stated explicitly, not silently). FM 28 reduction check: nothing to trim, all three ledgers remain sparse from S710's cuts.
next_steps: (A) Census class (d) (READY, S): render the 2 duplicate-adjacent sites and judge acceptability. (B) Census class (b) (READY, M): decide the census-predicate tolerance for the 2 noise rows, then assess whether the 6 real 60-180 px union-dot offsets are minSep-forced or QP-reducible (R/makePedigreeDiagramData.R, .solveJointQP()); re-verify the coupled fidelity-article prose. (C) Census curved-chord (READY, M): arc-modelling measurement pass replacing the 1,668-chord upper bound. (D) MHC polish (Housekeeping, S). (E) Owner decisions pending: package-split disposition, pointer-block sweep ratification, REUSE registration. (F) Informational: dashboard copy stale (v2.14.0 vs v2.18.0); R/appServer.R:168 re-throw observer reported-not-changed; untracked leftovers unchanged; LabKey remainder BLOCKED.
key_files: HANDOFFS.md:146 (this receipt), CHANGELOG.md:29 (S711 entries), docs/archive/SESSION_NOTES-through-2026-09-18.md:1 (S709 gotchas, still applicable), BACKLOG.md:109 (census class b), BACKLOG.md:128 (curved-chord), BACKLOG.md:142 (census class d)
gotchas: (1) Fresh baseline still 2,434 blocks (failed=0, error=0, skipped=184, warning=48) -- neither S710 nor S711 touched package files; S709's gotchas apply verbatim, read them in docs/archive/SESSION_NOTES-through-2026-09-18.md. (2) The close-out push triggers one more CI round on the records/self-reconcile head -- expect completed success at Phase 0's gh run list; if red, that is NEW information (docs-only delta), report-don't-fix per the standing convention. (3) Expect ~1 self-reference commit past the CHANGELOG frontier at next Phase 0 (the recurring shape); measure it. (4) origin/master is now in sync -- the long-running "N commits ahead" informational item is gone; don't re-report it from stale handoffs.
runtime_smoke: n/a -- docs-only local changes; the deliverable's own verification IS the CI matrix on real runners (R CMD check, lint, coverage, pkgdown all green on the pushed head afd33514)
changelog_ref: 827a7e67
commit: 827a7e67
```
Self-score 9/10: + claim-before-push left the pushed head self-describing (a crash mid-watch would still have left origin carrying the session claim); + waited for the full matrix and re-verified the watcher's claim directly before recording it; + clean precedent-following scope, no package files touched, no scope creep. - The close-out push's own CI round is deliberately unwatched (S706 precedent, docs-only delta on a just-verified tree) -- a defensible but real open loop handed to the next Phase 0; - a routine session yields no learning row, correct but worth stating. Predecessor 9/10: next-step A was the exact deliverable -- the ~32 recount measured 32 exactly, the span description and clean-state assurance made the decision presentable with zero re-derivation, and gotcha 5's 1-commit backfill shape measured exactly 1; nothing material missing for this scope; nothing wrong found.

```handoff
session: S710
date: 2026-09-18
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Ledger archive pass (S709 next-step A, owner-picked): all three ledger byte triggers were firing and all three now clear with wide headroom -- SESSION_NOTES.md 87,984 -> 4,771 B (19 records), HANDOFFS.md 78,503 -> 16,481 B (13 receipts), CHANGELOG.md 68,117 -> 9,471 B (40 records), each into its own docs/archive/*-through-2026-09-18.md shard, L1/L2/L3 verified by each shard's verify.sh. Docs-only maintenance; no package files touched.
what_was_done: Phase 0 backfill 7ab986e2 (1 commit, 710fea78 -- the predicted self-reconcile shape, measured exactly 1); claim 852b5292. Cut-boundary discovery: the default cut on every file collided with the existing -through-2026-09-17 shards (S704-S708 all share that date), so legal retained counts were probed with dry-run --cut N -- SESSION_NOTES only >=15 or <=2, HANDOFFS only <=2, CHANGELOG only <=8 (Learning 761). Trims committed one file per commit, largest non-colliding retention satisfying both stop conditions: SESSION_NOTES retain 2 (7fbe17b7), HANDOFFS retain 2 -- the pending S710 stub + S709's complete receipt, never zero (3dbe15f3), CHANGELOG retain 8, trimmed LAST so the two earlier trim-injected P1A entries landed before its cut (447f2beb). No --force needed anywhere: the Learning 549/586/594 SRF refusals never fired (large post-2026-09-17-archive denominators). Receipt-count sentence regenerated to 2 by the tool. Learning 761 appended; records commit follows this receipt.
next_steps: (A) Push decision (owner call): ~32 commits ahead after close-out (recount with git rev-list --count origin/master..HEAD); span includes S708 MHC Slice 4, the S709 crash fix, and this archive pass; no package files touched since the S709-verified clean state. (B) Census class (d) S, class (b) M, curved-chord M -- unchanged. (C) MHC polish (Housekeeping, S). (D) Informational: package-split disposition pending; dashboard copy stale; untracked leftovers unchanged; R/appServer.R:168's deliberate re-throw observer reported-not-changed (S709 next-step E).
key_files: docs/archive/SESSION_NOTES-through-2026-09-18.md:1 (S709's full handoff lives here now), docs/archive/HANDOFFS-through-2026-09-18.md:1 (S696-S708 receipts), docs/archive/CHANGELOG-through-2026-09-18.md:1 (S697-S708 ledger records), PROJECT_LEARNINGS.md:2217 (Learning 761), HANDOFFS.md:135 (regenerated receipt-count sentence)
gotchas: (1) Baseline still 2,434 blocks (failed=0, error=0, skipped=184, warning=48) -- no package files touched; S709's gotchas still apply verbatim, read them in docs/archive/SESSION_NOTES-through-2026-09-18.md. (2) The live ledgers are deliberately sparse now -- older context is one hop away via the front-matter shard pointers; sparseness is not a ghost session. (3) The NEXT archive pass hits the same SHARD_EXISTS collision on the 2026-09-18 boundary -- probe legal cuts with dry-run --cut N first (Learning 761). (4) Every methodology_trim.py --write injects its own entry into CHANGELOG.md -- trim CHANGELOG last in any multi-file pass. (5) Expect ~1 self-reference commit past the CHANGELOG frontier at next Phase 0; measure it.
runtime_smoke: n/a -- docs-only (ledger files and docs/archive shards; zero R/, tests/, man/, vignettes/ changes)
changelog_ref: a6b26716
commit: a6b26716
```
Self-score 9/10: + dry-run probes before every write meant no rollback was ever needed; + CHANGELOG trimmed last so the tool's own injected entries stayed inside the trimmed budget; + every shard verified via its own verify.sh before its commit, and a final --check on all three files confirms no trigger fires. - The deep SESSION_NOTES cut archived S709's handoff record mid-session (before this handoff existed), briefly leaving the live ACTIVE TASK stub-only -- lossless but a crash in that window would have cost the next session an archive hop; - pre-announced an owner --force gate the evidence never required. Predecessor 9/10: next-step A was the exact deliverable with measured sizes and the "measure CHANGELOG first" instruction that proved out; the shard-name collision constraint -- the pass's dominant obstacle -- was unflagged (discoverable only by doing); the predicted SRF refusals never fired (labeled expectation, zero cost).

```handoff
session: S709
date: 2026-09-18
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Export-preview session-crash fix (top BACKLOG Up Next item, found S708): the LD-block, sequence, and MHC export-preview observers in R/modMarkerGenetics.R read every upstream reactive through safeRead() + req(); the sequence observer ports the MHC Dragon 5 missing-id pre-check (sequenceExportMissingIds -- build nothing, say why); the three guidance renderUIs name the could-not-be-processed state; the eager E2E data-ready observe() (a second, unknown, NO-CLICK crash the RED tests exposed) is defused too. Strict TDD, every gate owner-approved via AskUserQuestion.
what_was_done: Phase 0 backfill 148cccaa (1 commit, cc540bf3); claim cf97540e. PRE-RED probes: sequence missing-id crash reachable; LD missing-id crash structurally unreachable (markerLdBlock subsets to founderIds, R/markerLdBlock.R:236 -- owner re-ratified defusal-only); testServer DESTROYS the module session on an observer error so survival is directly assertable (Learning 759, refining 758). Fresh baseline before any test: 2,427/0/0/183/42 (S708 exactly). RED cd63250c: 6 testServer blocks + 1 live E2E in the already-registered ROH E2E file; 5 blocks fail via shiny.destroyed.error, guard passes by design, E2E reproduces the live disconnect on the real tab (isConnected FALSE). GREEN 310c731d (R/modMarkerGenetics.R only): the RED malformed-upload block dying at UPLOAD time exposed the eager data-ready observe({req(comparison())}) as a real no-click crash, fixed with req(safeRead(comparison)); target file 66/66; both live E2E tests green (Phase 3E); lint 0. NEWS 76807b2a + spell-check reword 61c544a3. Full suite once on final source: 2,434 = 2,427 + the 7 new; failed=3 all triaged (2 wall-clock benchmarks = CPU contention from running lint/render beside the suite, both files green on quiet re-run, Learning 760; 1 spelling fixed, re-run green); warnings 42->48 = the i152 fixture's documented markerKinship NA warnings x 3 new instances. devtools::check 0 errors, 1 W + 1 N = the known untracked-local-file artifacts. BACKLOG item removed; Learnings 759/760 appended; records commit follows this receipt.
next_steps: (A) Archive pass (READY, S): HANDOFFS.md (72,242 B) and SESSION_NOTES.md (77,442 B) byte triggers BOTH firing; CHANGELOG.md was 62,816 B before this close-out -- measure; expect SRF small-denominator refusals needing an owner --force (Learnings 549/586/594). (B) Census class (d) S, class (b) M, curved-chord M -- unchanged. (C) Push decision (owner call): ~25 commits ahead after close-out (recount with git rev-list --count origin/master..HEAD); local suite + check clean apart from the untracked-file artifacts. (D) MHC polish (Housekeeping, S). (E) Informational: R/appServer.R:168's observe re-throws cleanedStudbook errors by DELIBERATE design comment -- same crash class as Learning 758, reported not changed, owner's call; package-split disposition pending; dashboard copy stale; untracked leftovers unchanged.
key_files: R/modMarkerGenetics.R:740 (LD observer), R/modMarkerGenetics.R:816 (sequence observer + pre-check), R/modMarkerGenetics.R:807 (sequenceExportMissingIds), R/modMarkerGenetics.R:929 (MHC observer), R/modMarkerGenetics.R:1261 (fixed data-ready observe), R/modMarkerGenetics.R:1036 + :1075 + :1182 (guidance renderUIs), tests/testthat/test_modMarkerGenetics.R:1554 (S709 section), tests/testthat/test-e2e-marker-genetics-genomic-roh-module.R:192 (disconnect E2E), PROJECT_LEARNINGS.md tail (Learnings 759/760), NEWS.Rmd:374 (General Fixes entry)
gotchas: (1) Fresh baseline now 2,434 blocks (failed=0, error=0, skipped=184, warning=48); skipped +1 = new opt-in E2E; warnings +6 = documented fixture warnings, not a regression. (2) Never run heavy jobs beside the full suite -- the 2 wall-clock benchmark files fail under CPU contention; re-run alone before treating as a regression (Learning 760). (3) Observer-crash tests assert session survival directly: click, then read any module state -- shiny.destroyed.error is the honest RED signal; req(x()) does NOT guard against x() erroring (Learning 759). (4) devtools::check keeps 1 W + 1 N from the untracked local files; CI never sees them. (5) Expect ~1 self-reference commit past the CHANGELOG frontier at next Phase 0; measure it. (6) Both ROH E2E tests share makeGenomicRohE2ePedigreeFile(dropIds=); the partial variant writes a different filename so the fixtures cannot clobber each other.
runtime_smoke: live shinytest2 E2E in headless Chrome, both tests: the pre-existing full export flow (8 assertions, upload -> preview -> confirm -> unlock) unchanged, and the new disconnect check -- pedigree missing S050, Generate Preview clicked, Shiny.shinyapp.isConnected() TRUE, guidance names "1 animal ... not in the loaded pedigree"
changelog_ref: 33b0a556
commit: 33b0a556
```
Self-score 9/10: + PRE-RED probes overturned two load-bearing brief assumptions (LD unreachability; destroyed-session observability) before any test existed; + the RED honest-failure discipline surfaced a second real no-click crash the brief didn't know about; + user-boundary runtime verification (live disconnect reproduced pre-fix, survival proved post-fix); - ran lint/render beside the single full-suite launch, causing 2 spurious benchmark failures and a re-triage cycle (Learning 760); - the NEWS spell-check flag surfaced only in the full suite; - the mid-GREEN data-ready-observer fix was decided solo (disclosed in commit + gate, but a mid-session owner flag would have been cleaner). Predecessor 9/10: complete brief with the fix-pattern pointer and the E2E suggestion that became the key test; the "guidance text is the ONLY observable" claim understated the destroyed-session surface, and the eager data-ready observer wasn't flagged; "port to BOTH observers" was evidence-retired for LD.

