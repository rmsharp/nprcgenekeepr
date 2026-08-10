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

```handoff
session: S511
date: 2026-08-10
status: complete
self_score: 9
predecessor_score: 9
active_task: Issue #151's design/architecture document is DONE and RATIFIED
(docs/planning/issue151-individual-mate-pair-analysis-plan.md). All of Tier 1/Tier 2's
ready-to-build items (#147/#149/#146/#151) now have ratified designs; #151's is the only one not
yet implemented. Issue #151 intentionally left open -- design/planning only.
what_was_done: Wrote and ratified docs/planning/issue151-individual-mate-pair-analysis-plan.md
(11 sections, ARCHITECTURE_WORKSTREAM.md structure) for issue #151 (individual mate-pair
analysis), per GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md Tier 2 item 3. Read 6 files
in full (filterPairs.R, filterAge.R, kinMatrix2LongForm.R, filterThreshold.R,
getAnimalsWithHighKinship.R, markerKinship.R) plus relevant sections of reportGV.R/orderReport.R,
modMarkerGenetics.R, modBreedingGroups.R, appServer.R, appUI.R, module-contract.md. Found the
reusable pair-eligibility pipeline lives entirely outside modBreedingGroups.R (correcting the
sequencing audit's own "shared-file risk" flag) and that modMarkerGeneticsServer() already
computes+returns a markerKinshipMatrix reactive that appServer.R's own call site silently
discards (R/appServer.R:435-439) -- both confirmed by direct code read, not assumed. Ran an
original empirical benchmark against the bundled examplePedigree fixture: an unscoped pair-reshape
produced 1,744,722 rows in 54.0s; filterAge()'s NA-passes-the-filter semantics (81% of "alive"
fixture individuals have no recorded age) means the age control alone cannot bound table size --
directly grounding the design's population-scope requirement (D4). Confirmed via a full read of
orderReport.R that no composite-score ranking precedent exists in the package, grounding the
"raw sortable columns" recommendation (D3). Presented 3 genuine judgment calls (D3 ranking, D4
population-scope, D5 exclusion transparency) via a single AskUserQuestion round; owner selected
the recommended option in all 3 cases. Updated the plan's Status to RATIFIED, recorded the outcome
in §11. Also reconciled a legal-but-stale `commit: pending` placeholder in S510's own HANDOFFS.md
receipt to the real sha (abca9edc). CHANGELOG.md [issue #151] entry + BACKLOG.md progress note
(continuing the S483-S510 narrative) + 2 new PROJECT_LEARNINGS.md entries (511-512).
Commits: 43dc264a (claim), plus this close-out commit (plan doc + all close-out writes).
next_steps: Slice 1 of docs/planning/issue151-individual-mate-pair-analysis-plan.md -- the core
`reportMatePairs()` function (§5 Slice 1), script-callable only, no UI. Start with §4's interface
catalog (exact input/output/error contract already specified) and §5's own file/test list. Slice 2
(new R/modMatePair.R UI, the D6 appServer.R marker-kinship capture, appUI.R tab mount,
documentation) is a separate future session per the plan's own session-boundary requirement --
do not bundle the two slices. Outside this cluster, the priorities list this session's own Phase 0
rendered but the owner did not pick remain open: trimming the 3 now-oversized ledger files
(SESSION_NOTES.md/CHANGELOG.md/BACKLOG.md, all past the 2,000-line read cap -- BACKLOG.md is a
NEW addition to this risk since S510's own orient); filing 2 new GitHub tracking issues for the
sequencing audit's own unfiled High-priority gaps ("Longitudinal genetic-health monitoring",
"Ancestry guardrails in breeding decisions"); surfacing issue #150's policy decision to the owner.
key_files: docs/planning/issue151-individual-mate-pair-analysis-plan.md (the full ratified design,
all decisions D1-D8 resolved -- read this first for Slice 1); R/appServer.R:430-439 (the
modMarkerGeneticsServer call site Slice 2 must edit for D6); R/modMarkerGenetics.R:320 (the
already-existing markerKinshipMatrix reactive Slice 2 threads through); R/getAnimalsWithHighKinship.R:41-59
(the exact eligibility-pipeline composition Slice 1 reuses); R/orderReport.R (the "no composite
score" precedent grounding D3, useful if that decision is ever revisited).
gotchas: (1) filterAge()'s NA-passes-the-filter semantics (R/filterAge.R:26) means minAge alone
will NOT bound Slice 1's output size on real data with incomplete age records -- the D4 population-
scope parameter is load-bearing, not optional; a RED test should exercise a case where most
candidates have NA age to prove the scope control (not the age filter) is what bounds the result
(see PROJECT_LEARNINGS.md Learning 509 for a related, earlier-discovered instance of this same
filterAge() NA-handling class -- that one via a missing column entirely, not missing values within
a present column, so the two are related but distinct traps). (2) markerKinship() can return
negative values (a valid, meaningful "more divergent than reference" signal, not an error) and can
return NA per-pair with its own warning() when neither individual has a shared heterozygous locus
(R/markerKinship.R:96-100) -- both must render sensibly in Slice 2's table, not as if they were 0
or a blank. (3) DT::renderDT(server = TRUE) (recommended given the real row-count findings) means
sort/filter happens server-side -- the CSV export must export the FILTERED result set, not the
full unfiltered table, matching every other export in this app. (4) SESSION_NOTES.md/CHANGELOG.md/
BACKLOG.md are now ALL past the 2,000-line read cap (BACKLOG.md newly so -- 2,001 lines before
this session's own append, 2,030 after) -- flagged again, still unaddressed for a third consecutive
session; a near-future session should treat this as increasingly urgent, not routine.
runtime_smoke: n/a -- docs-only session (one new file under docs/planning/, edits to
SESSION_NOTES.md/HANDOFFS.md/CHANGELOG.md/BACKLOG.md/PROJECT_LEARNINGS.md only). Zero R/, tests/,
or man/ content changed; no runtime behavior exists to verify.
changelog_ref: CHANGELOG.md 2026-08-10 "[issue #151] Pre-RED design/architecture document --
individual mate-pair analysis (Session 511)" entry (this session's close-out commit).
commit: pending -- reconciled by the next session's Phase 0, per this receipt's own documented
write-time constraint (it ships in the very commit whose sha it would name).
```

```handoff
session: S510
date: 2026-08-10
status: complete
self_score: 9
predecessor_score: 8
active_task: Issue #146 Slice 2 (exhaustive enumeration mode + UI toggle) is DONE. Issue #146
is now fully implemented across both slices and closed. No open item remains in this
sequencing-chain pickup.
what_was_done: Full strict TDD PRE-RED->RED->GREEN cycle (AskUserQuestion-gated; REFACTOR
owner-confirmed skip) implementing docs/planning/issue146-configurable-exhaustive-breeding-group-retention-plan.md
§5 Slice 2. New R/enumerateMaximalIndependentSets.R (.enumerateMaximalIndependentSets(), a
hand-rolled Bron-Kerbosch-style maximal-independent-set search on the existing kin conflict
adjacency list, D4, cites Bron & Kerbosch 1973 / Tomita-Tanaka-Takahashi 2006). groupAddAssign()
gained exhaustive/maxExhaustiveCandidates(20L)/exhaustiveTimeLimit(10) arguments, scoped to
numGp=1/no harem/no custom sexRatio (D2) with named-reason stop()s (D9) and a two-layer
feasibility guard (D5, pre-flight ceiling + wall-clock deadline degrading to a truncated result).
groupMembersReturn() gained optional exhaustive/examined/retentionRule fields, byte-identical-
by-default (D7). modBreedingGroups.R gained an Exhaustive enumeration mode checkbox (gated by a
conditionalPanel matching D2's scope exactly) and a status callout (D8). 11 new/extended test
blocks across 4 files (1 new file: test_enumerateMaximalIndependentSets.R). Full clean regression
suite 0 failed/0 error (5081 passed, up from 5050; 175 skipped; 15 pre-existing warnings
unchanged); lintr::lint_package() 0 lints (4 found+fixed on touched files); devtools::check() 0
errors/0 warnings/2 pre-existing notes (confirmed unrelated, predate this session's claim commit).
Live shinytest2/chromote smoke test against the real running app: toggle visible-when-eligible /
HIDDEN-when-ineligible (verified via computed style, not just visual), input$exhaustive confirmed
TRUE in the live server, a genuine live exhaustive run (real browser click, real ~375-animal
fixture with most seeded into group 1 via the UI's own seed-groups textarea to bring the
remaining pool under the 20-ceiling) produced the correct live status text ("Exhaustive: examined
1 partition(s). top-5 by score (min group size), N = 1"), 0 SEVERE console entries. Live
truncated-search case not reproduced (deadline not UI-configurable; already unit-tested) -- an
explicit judgment call the plan's own §5 grants. NEWS.Rmd/NEWS.md, and
vignettes/manual_components/_breeding_group_formation.Rmd (text-only, "and/or" allowance)
updated; citation/_pkgdown.yml checklists stated N/A explicitly; a2interactive.Rmd deferred per
its own standing rule. CHANGELOG.md entry + BACKLOG.md progress note + gh issue close 146.
Commits: 2f822a89 (claim), plus this close-out commit (all code/test/doc changes + close-out).
next_steps: BACKLOG's rendered priorities (this session's own Phase 0) remain open for a future
session to pick from: trim SESSION_NOTES.md (READY, Effort S-M -- NEW dashboard HIGH risk flag,
39,294 lines, past the 2,000-line read cap; the existing methodology_trim.py may or may not
directly support this file's handoff-narrative format the way it supports CHANGELOG.md/
HANDOFFS.md's dated-record format -- would need checking first, not assumed); issue #150 policy
decision (DECISION NEEDED -- owner sign-off on what "curator-controlled" export access means for
the de-identified pedigree export workflow, Tier 3 quick win otherwise); issue #151 design (Tier
2, next after #146 in the ratified sequencing audit -- no design doc yet, so this would open as a
planning session, not straight implementation).
key_files: docs/planning/issue146-configurable-exhaustive-breeding-group-retention-plan.md (the
full ratified design, all judgment calls D1-D9 already decided -- read this first for any
follow-up on issue #146's own family); R/groupAddAssign.R:194-198 (the exhaustive-branch
dispatch) and :316-405 (the new .groupAddAssignExhaustive() helper);
R/enumerateMaximalIndependentSets.R (the new algorithm, @noRd); R/modBreedingGroups.R (the new
conditionalPanel-gated checkbox + exhaustiveStatus renderUI); tests/testthat/test_enumerateMaximalIndependentSets.R
(the hand-verified 5-cycle fixture, reusable for any future maximal-independent-set correctness
work).
gotchas: (1) Any new synthetic `ped` test fixture for groupAddAssign()/getAnimalsWithHighKinship()
that needs REAL kinship conflicts (not a zero-kinship dedup-only fixture) MUST include an `age`
column -- omitting it does not error, filterAge() silently drops every kinship pair instead (a
base R df[i,"missingCol"] quirk, see PROJECT_LEARNINGS.md Learning 509). (2) A RED-phase
expect_error(regexp=...) test that deliberately passes the SAME parameter name(s) the regexp
searches for is at risk of accidentally passing before any implementation exists, since R's own
"unused arguments (name = value)" error echoes the name back -- verify every new RED test's
individual failure output, not just the aggregate pass/fail count (Learning 508). (3) Never pass
an explicit output_format override to rmarkdown::render() on a file with its own output:
frontmatter (NEWS.Rmd is github_document) -- it silently produces a hugely disproportionate
reflow diff; always git diff --stat immediately after any render, before staging (Learning 510).
(4) SESSION_NOTES.md is now the largest of the three ledger files (39,294 lines) and was NOT
addressed this session -- it will keep growing every session until a future session either trims
it (if methodology_trim.py's format assumptions fit) or a different remediation is chosen.
runtime_smoke: Live shinytest2/chromote smoke test performed against the real running app (not
testServer() alone) -- see what_was_done for the full result. All R/ changes this session touch
runtime Shiny behavior (new UI control, new server reactive wiring), so this was a hard gate, not
skipped.
changelog_ref: CHANGELOG.md 2026-08-10 "[issue #146] Slice 2 -- exhaustive enumeration mode + UI
toggle..., closes #146 (Session 510)" entry (this session's close-out commit).
commit: abca9edc (reconciled S511 -- the receipt shipped in this same close-out commit, so its
own sha could not be known at write time; confirmed via `git log -1 --format=%H -- HANDOFFS.md`)
```

```handoff
session: S509
date: 2026-08-10
status: complete
self_score: 9
predecessor_score: 9
active_task: Lossless trim of CHANGELOG.md and HANDOFFS.md via methodology_trim.py is DONE.
HANDOFFS.md fully resolved (trigger no longer fires). CHANGELOG.md improved substantially
(-38% bytes, -65% lines) but its byte/line triggers still fire -- expected, tied to the frozen
"## Legacy history (Sessions 1-324)" footer this tool is designed to never touch (a prior,
separate, already-ratified Session 325 decision, not something this session's scope covers).
what_was_done: Ran methodology_trim.py --write against both files (their first-ever archive).
HANDOFFS.md: 832,849 B/4,877 lines -> 28,806 B/409 lines, 181 of 187 records archived to
docs/archive/HANDOFFS-through-2026-08-10.md; trigger now "does not fire". CHANGELOG.md: 1,534,418 B/
10,523 lines -> 945,639 B/3,723 lines, 288 of 289 records archived to
docs/archive/CHANGELOG-through-2026-08-10.md; trigger still FIRES (expected, see active_task).
Both trims' write-time L1/L2/L3 assertions passed; independently-regenerated verify.sh scripts
also passed for HANDOFFS.md (exit 0) and, for CHANGELOG.md, passed L1/L3 with one L2 heuristic
false positive investigated and confirmed harmless (2 archived records quote a front-matter
heading verbatim in backticks while narrating an unrelated prior action -- see
PROJECT_LEARNINGS.md Learning 507 for the full grep-based proof). Fixed a real infrastructure gap
found along the way: .gitignore's blanket docs/* rule had no !docs/archive/ exception, so the
tool's own required output directory was silently untrackable -- added it, matching the project's
7 other docs/ subdirectory exceptions. Commits: 7a423398 (claim), 9113dd48 (CHANGELOG entry for
the claim commit, needed to satisfy the trim tool's own P1 pre-check), d07814a7 (HANDOFFS.md trim
+ gitignore fix), 0929172a (CHANGELOG.md trim), plus this close-out commit (SESSION_NOTES.md/
HANDOFFS.md/PROJECT_LEARNINGS.md/CHANGELOG.md).
next_steps: No further action needed on HANDOFFS.md. CHANGELOG.md's residual over-budget state is
NOT a task to pick up casually -- shrinking it further requires a deliberate, separately-scoped
migration of the ~3,568-line/935,287 B frozen Legacy History section into the dated-record format
this tool can parse (or an equivalent dedicated archival approach), which the Session 325 "freeze
legacy, go forward" decision explicitly declined to do as a multi-session campaign; only pick this
up if the owner explicitly wants to revisit that decision. Otherwise: this session's own rendered
BACKLOG priorities remain open -- issue #146 Slice 2 (READY, ratified design doc, Effort M) is the
sequencing-audit's own next pickup; issue #150 (Tier 3 policy decision on "curator-controlled"
export access) and the BLOCKED LabKey remainder are also still live.
key_files: methodology_trim.py (read in full before running; the P1 pre-check, the L1/L2/L3
assertions, and the VERIFY_TEMPLATE's L2 "leaked" heuristic at line ~1235 are the load-bearing
parts), .gitignore (the !docs/archive/ fix), docs/archive/HANDOFFS-through-2026-08-10.md +
docs/archive/CHANGELOG-through-2026-08-10.md (the 2 new shards, each with its own .verify.sh),
PROJECT_LEARNINGS.md Learning 507 (both findings, with the exact grep commands used to confirm the
verify.sh false positive).
gotchas: Never run methodology_trim.py --write without first running a plain dry run (no --check,
no --write) to see the actual retain/archive plan -- --check alone only reports whether the
trigger fires, not how much would be archived. If P1_UNDOCUMENTED fires, the fix is a CHANGELOG.md
entry for the undocumented commit(s), not --force (that flag is for a different check, SRF_RED,
and is unrelated here). A verify.sh FAIL is not automatically real data loss NOR automatically
dismissible -- check whether L1/L3 (the byte-exact checks) also failed first; if only the L2
"leaked" heuristic fired, grep-verify per Learning 507's method before concluding either way. Do
not edit methodology_trim.py itself to fix the heuristic -- it is a synced file; report gaps
upstream instead.
runtime_smoke: n/a -- docs/ledger-only change (CHANGELOG.md, HANDOFFS.md, .gitignore,
docs/archive/*, SESSION_NOTES.md, PROJECT_LEARNINGS.md). No R code, no Shiny app files touched;
no runtime behavior affected.
changelog_ref: CHANGELOG.md "Trim CHANGELOG.md/HANDOFFS.md" close-out entry (this session's
close-out commit) -- note the 2 in-session trim-action entries this tool itself wrote
(the HANDOFFS.md-trim entry and the S509-claim entry) were themselves archived into
docs/archive/CHANGELOG-through-2026-08-10.md by the CHANGELOG.md trim that ran after them; still
fully readable there, not lost.
commit: pending
```
Session claimed. Work beginning; overwritten above at close-out with the full receipt.

**Self-score breakdown (9/10):** +Investigated rather than trusted or dismissed the verify.sh L2
FAIL, reaching a falsifiable, grep-proven conclusion. +Correctly diagnosed and fixed the P1
pre-check refusal at the right layer (log the commit, don't route around the check). +Found and
fixed the docs/archive/ .gitignore gap as necessary infrastructure, not scope creep. +Set accurate
expectations about CHANGELOG.md's residual over-budget state BEFORE running the trim, so the
close-out result matches what was predicted. −Ran read-only dry-run exploration before writing the
Phase 1B claim stub (no actual harm, since nothing was written, but the ordering should have been
stricter). −Left the optional HANDOFFS.md "This file currently holds **N** receipts" front-matter
count field unadded (a soft FRONTMATTER_FIELD_ABSENT warning, not a blocker) rather than fixed or
explicitly declined.

```handoff
session: S508
date: 2026-08-10
status: complete
self_score: 8
predecessor_score: 9
active_task: Issue #146 Slice 1 (mechanical maxCandidates parameterization) is DONE. Issue #146
stays open -- Slice 2 (exhaustive enumeration + UI) is the natural next pickup, its own future
session per the ratified plan's §5 session-boundary requirement.
what_was_done: groupAddAssign()'s hardcoded 5L candidate-retention cap (R/groupAddAssign.R:200, the
only literal site) is now a maxCandidates=5L argument; R/modBreedingGroups.R gained a matching
"Candidates to retain" numericInput (default 5, 1-50) wired through runFormation()'s defensive-
default pattern. Full strict TDD PRE-RED->RED->GREEN cycle (AskUserQuestion-gated; REFACTOR
owner-confirmed skip). 5 new tests (2 direct groupAddAssign() tests real-fixture lowered/raised, 1
UI-presence test, 2 testServer mocked-binding tests on the real unmocked server code). Caught and
fixed a vacuously-passing RED test (mock default masked real behavior) before proceeding. Full
regression 0/0 (5050 passed); lintr 0 lints; devtools::check() 0/0/1 pre-existing note. Live
shinytest2 smoke test confirmed the control active (correct default, 0 console errors,
maxCandidates=1 live-caps to exactly 1 option, 3/3 runs); the "raise above 5" live-diversity half
was inconclusive for this specific bundled fixture (diagnosed as a live-vs-direct pedigree-
construction discrepancy, not a code defect -- see BACKLOG.md's S508 note for full detail).
Commits: 8d4f5caa (claim), aa4849fb (RED), plus this close-out commit (GREEN code +
NEWS/BACKLOG/CHANGELOG/SESSION_NOTES).
next_steps: Implement Slice 2 of the ratified issue #146 plan -- the exhaustive-enumeration mode
(.enumerateMaximalIndependentSets(), D2/D5/D9's scope+feasibility guard, the exhaustive/
maxExhaustiveCandidates/exhaustiveTimeLimit parameters) plus the UI toggle+status callout, per the
plan's own §5 Slice 2. Effort M-L, genuinely new combinatorial-search algorithm work with zero
existing precedent in this codebase -- read §3 D4/D5/D9 and §7 (5 named dragons) before starting.
Other still-open priorities from the last corrected list: issue #150 (Tier 3 policy decision --
needs an owner sign-off on what "curator-controlled" means before scheduling), the BLOCKED LabKey
remainder.
key_files: docs/planning/issue146-configurable-exhaustive-breeding-group-retention-plan.md §5 Slice
2 (the touched-files list + DONE criteria), §3 D4/D5/D9 (algorithm/feasibility-guard/error-semantics
decisions, already ratified -- do not re-litigate), §7 (5 named dragons, especially #2's
no-async-infrastructure shared-blocking risk and #5's "silently incomplete enumeration" failure
mode), R/groupAddAssign.R:130-235 (Slice 1's shipped code -- exhaustive mode extends this same
function), tests/testthat/test_groupAddAssign.R (Slice 1's 2 new maxCandidates tests, lines ~225-280,
as the house-style template for Slice 2's own new tests).
gotchas: Exhaustive mode is scoped to numGp==1/no harem/no custom sex ratio ONLY (D2, already
ratified) -- do not attempt broader scope, the design doc's own §2.8 evidence shows it's already
intractable at realistic scale beyond that. This app has NO async/background-job infrastructure
(Dragon 2) -- a multi-second exhaustive request blocks the whole single-process Shiny app for every
concurrent user; the ratified deadline default (exhaustiveTimeLimit=10s) was chosen with this in
mind, don't loosen it casually. .enumerateMaximalIndependentSets()'s correctness is not obvious from
casual reading (Dragon 5) -- an off-by-one produces a plausible-looking but silently INCOMPLETE
enumeration, not a crash; the test file must include at least one small, fully hand-enumerated
fixture asserting exact membership, not just a count. Separately: this session found live
shinytest2 diversity testing against the bundled obfuscated_rhesus_mhc_ped.csv fixture with
numGp=1 unreliable (converges to a single dominant partition live regardless of parameters) --
Slice 2's own live verification of exhaustive-mode correctness should NOT assume this fixture
will show multiple maximal sets without first checking empirically (a direct, non-live
groupAddAssign()/exhaustive-mode call against the fixture, cheap and fast, before any live
shinytest2 cycles).
runtime_smoke: Live shinytest2/chromote smoke test against the real running app (inst/shinytest/app.R,
package reinstalled via devtools::install() first). Confirmed: control renders with correct default
(5), 0 console errors on Breeding Groups tab load; maxCandidates=1 live-caps the rendered candidate
dropdown to exactly 1 option (3/3 runs, different numGp/threshold combos). maxCandidates=8 did not
show >1 option live (inconclusive, not a failure -- see what_was_done/BACKLOG.md detail).
changelog_ref: CHANGELOG.md "2026-08-10 · [issue #146] Slice 1 shipped — mechanical maxCandidates
parameterization (Session 508)" entry (this session's close-out commit).
commit: pending
```

```handoff
session: S507
date: 2026-08-10
status: complete
self_score: 8
predecessor_score: 6
active_task: Issue #146's design/architecture document is DONE and RATIFIED (all 4 judgment calls
answered, owner's recommended option in all 4 cases). No further design work owed. Next: Slice 1
implementation (mechanical maxCandidates parameterization) in a future session.
what_was_done: Wrote and ratified docs/planning/issue146-configurable-exhaustive-breeding-group-
retention-plan.md (9 design decisions, 4 ratified via one AskUserQuestion round). Grounded the
feasibility-guard numbers in an original empirical benchmark (Bron-Kerbosch maximal-independent-set
enumeration timed against synthetic conflict graphs) rather than guessing — found a counter-
intuitive result (sparser candidate pools are slower to exhaustively enumerate, not faster).
Corrected an initial Phase 0 priorities-list gap (missed the ratified genetic-metrics-audit
sequencing order for #146-153) after the owner flagged it, then fixed the gap at the convention
level: PROJECT_LEARNINGS.md Learning 506 + a CLAUDE.md amendment to the priorities-list
customization. BACKLOG.md progress note added. Commits: 3991c44b (CHANGELOG backfill for S506's
own close-out commit), 7888d433 (claim), and this close-out commit (docs/BACKLOG/CHANGELOG/
PROJECT_LEARNINGS/CLAUDE.md).
next_steps: Implement Slice 1 of the ratified issue #146 plan — parameterize groupAddAssign()'s
hardcoded 5L candidate-retention cap into a maxCandidates argument (default 5L, byte-identical),
plus one new numericInput in modBreedingGroupsUI. Small, mechanical, Effort S — see the plan's own
§5 Slice 1 for exact touched files and DONE criteria. Slice 2 (exhaustive enumeration + UI) is a
separate, later session per the plan's own session-boundary rule. Other still-open priorities from
this session's own corrected list: issue #150 (Tier 3 policy decision — de-identified pedigree
export, needs an owner sign-off on what "curator-controlled" means before scheduling), the
inst/extdata/ reorg Phase 4 (2 open decisions), and the BLOCKED LabKey remainder.
key_files: docs/planning/issue146-configurable-exhaustive-breeding-group-retention-plan.md (the
ratified plan — §5 for the Slice 1 implementation plan, §2.1/§2.7 for the exact groupAddAssign.R/
modBreedingGroups.R touch points), docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md
(the ratified Tier 1/2/3/Deferred order this cluster follows), R/groupAddAssign.R:130-235 (the
function Slice 1 modifies), tests/testthat/test_groupAddAssign.R:181-224 (the 2 existing
5L-hardcoded tests Slice 1 must parameterize, not silently relax).
gotchas: The 2 existing groupAddAssign tests hardcoded to 5L (test_groupAddAssign.R:181-224) must
keep asserting the exact DEFAULT behavior — parameterize them to accept maxCandidates, don't just
relax the assertion to expect_lte(..., N) for an arbitrary N (Dragon 1 in the plan). This app has
no async/background-job infrastructure (promises/future absent from DESCRIPTION) — Slice 2's
exhaustive mode, when it lands, will block the whole single-process Shiny app for every concurrent
user during a slow request, not just the requester (Dragon 2) — keep this in mind when Slice 2's
own feasibility-guard numbers are implemented, don't loosen them casually. Phase 0's priorities-list
rendering has a structural blind spot for ratified sequencing-audit orders that live in prose, not
inline BACKLOG.md tags — Learning 506/the CLAUDE.md amendment fixes this going forward, but a
future session touching the sibling PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md cluster
should confirm the fix actually surfaces that cluster's own next item (#138) correctly too.
runtime_smoke: n/a — docs-only session, no R/ code or runtime behavior changed.
changelog_ref: CHANGELOG.md "2026-08-10 · [issue #146] Design/architecture document ratified"
entry (this session's close-out commit).
commit: pending
```
<filled in at close-out>

```handoff
session: S506
date: 2026-08-10
status: complete
self_score: 9
predecessor_score: 9
active_task: BACKLOG.md's twin-connector-color Housekeeping item (issue #137 D10) is DONE and
resolved. No further work owed on it.
what_was_done: Wired color = "#009E73" (Okabe-Ito bluish-green) into .buildTwinConnectorEdges()
(R/makePedigreeDiagramData.R) for both edgeStyle values, plus the Diagram-tab legend swatch
(R/modPedigree.R). Found and fixed a second, previously undiscovered dragon:
.addRectilinearWaypoints() unconditionally reset every kept edge's color to NA under
edgeStyle = "rectilinear" -- the same anti-pattern issue #133 already fixed on the node side of
this same function, now fixed the same way (preserve-if-absent). Full strict-TDD
PRE-RED->RED->GREEN cycle, AskUserQuestion-gated at every transition (including a dedicated
pre-RED wire-vs-decline scope decision); REFACTOR owner-confirmed skip. 11 new/extended test
assertions across 4 files, 0 regressions (git stash -u: baseline failed 11/passed 5031 vs. GREEN
failed 0/passed 5042, exact delta). lintr 0 lints. devtools::check() 0 errors/0 warnings,
pre-existing notes only (1 new session-caused spelling word, "unwired," found and fixed by
rewording). Live shinytest2 smoke test confirmed the color on the real running app under BOTH
edgeStyle values. NEWS.Rmd/_pedigree_browser.Rmd documentation updated same-session.
Commits: df13dacd (claim), 17cd2f9b (RED), fb2e16f2 (GREEN), b72dbf68 (NEWS/tutorial docs),
c07de6ef (this close-out: CHANGELOG/BACKLOG/Learning 505).
next_steps: Pick the next item from BACKLOG.md's priorities list: the 15-pre-existing-baseline-
warnings root-cause fix (Housekeeping, Effort S, already fully diagnosed -- 3
test_modMarkerGenetics.R blocks need suppressWarnings() or a fixture tweak, verify exact-fraction
Fst values still hold if fixture-tweaking), the devtools::check() spelling-NOTE WORDLIST drift
(Housekeeping, Effort S, grown to 13-14 words as of this session's own check runs -- hand-add to
inst/WORDLIST in LC_ALL=C byte order), or the BLOCKED LabKey remaining recommendations (Effort M,
needs a live LabKey server). None more urgent than another.
key_files: R/makePedigreeDiagramData.R:268-286 (.buildTwinConnectorEdges(), the color source),
:1442-1457 (.addRectilinearWaypoints()'s preserve-if-absent fix, mirroring the color.background/
color.border node precedent ~40 lines below it), R/modPedigree.R:595-599,646-660 (the legend
swatch), tests/testthat/test_addRectilinearWaypoints.R (the new dedicated edge-color-preservation
test), PROJECT_LEARNINGS.md Learning 505 (the dragon's full mechanism).
gotchas: Any FUTURE code that adds edges to a direct-style makePedigreeMatingLayout() layout and
wants a pre-set color to survive edgeStyle = "rectilinear" now works correctly (the preserve-fix
covers it generically, not just the twin connector) -- but a NEW edge-level column added the same
way (mirroring dashes/label/color) would need the SAME 3-site priming pattern (childEdgesOut/
mateEdges/dupEdges) to avoid an "undefined columns selected" rbind failure; grep for how color was
added as the template. Running a git-stash-based baseline comparison concurrently with any other
command that reads/writes tracked files (e.g. devtools::document()) races against the stash --
this session hit it once (an accidental no-op document() run against stashed source); always run
git-stash comparisons serially, not backgrounded alongside other file-touching commands.
runtime_smoke: PASS -- live shinytest2 AppDriver smoke test against the real running app (twin
pedigree + twin-relations fixture upload, direct style then rectilinear style), color:"#009E73"
confirmed on both the live-rendered connector edges and the legend's 3 rows under both edgeStyle
values, zero throw-level/SEVERE console entries.
changelog_ref: CHANGELOG.md 2026-08-10 "[BL-twinConnectorColor] Twin-connector color wired --
issue #137 D10, #009E73 on both edgeStyle values (Session 506)"
commit: c07de6ef
```

```handoff
session: S505
date: 2026-08-10
status: complete
self_score: 9
predecessor_score: 10
active_task: Issue #149 Slice 2 (full module: UI, confirm gate, exports, documentation) is DONE.
Issue #149 closed -- both slices of the ratified design are now shipped. No further #149 work
remains.
what_was_done: New R/modCrossCenterIdentity.R (modCrossCenterIdentityUI/Server): 3 file uploads,
a checkCrossCenterMapping()-backed Validation tab (every issue at once), a Preview tab computing
resolveCrossCenterIds() with a per-pair lineage-change table (2 new internal helpers,
.buildCrossCenterLineagePreview()/.buildCrossCenterMergeProvenance()), a shiny::modalDialog()
confirm gate (this app's first), and 5 downloadable export artifacts. Wired into
appUI.R/appServer.R (self-contained, no shared$... args). Full strict TDD PRE-RED->RED->GREEN
cycle, AskUserQuestion-gated; REFACTOR owner-confirmed skip. 17 new test blocks, 0 regressions
(git stash -u confirmed). lintr 0 lints. devtools::check() 0 errors/0 warnings/pre-existing notes
only (1 new session-caused spelling word found and fixed by rewording). Live shinytest2 smoke
test against the real app confirmed both Dragons #6 (modalDialog under bslib) and #7 (DT NA-cell
rendering), zero console errors. NEWS.Rmd/_pkgdown.yml/colony-manager-guide.qmd documentation
done same-session; a2interactive.Rmd deferred per its own standing rule. gh issue close 149.
Commits: dcb0cde9 (claim), 6c9d790d (RED), a4d5742b/095a46f4/f22438e9/fe033200/a8a0016e (GREEN +
docs checkpoints 1-4 + 1 follow-up), b8022a4a (this close-out).
next_steps: Issue #149 is fully closed -- no follow-on work owed. Pick the next item from
BACKLOG.md's priorities list: the twin-connector-color fix-or-decline (Housekeeping, Effort S,
found S494), the 15 pre-existing baseline warnings root-cause fix (Effort S, already fully
diagnosed -- see BACKLOG.md Housekeeping item, just needs suppressWarnings()/fixture-tweak
applied to 3 test blocks), or the BLOCKED LabKey remaining recommendations (Effort M, needs a
live LabKey server). None more urgent than another.
key_files: R/modCrossCenterIdentity.R (the new module -- read its own "Shared validation
helpers" cross-reference comments before touching it again), tests/testthat/
test_modCrossCenterIdentity.R (17 tests), docs/planning/issue149-cross-center-identity-mapping-
workflow-plan.md §5 Slice 2 (the DONE criteria this session verified against), PROJECT_LEARNINGS.md
Learning 504 (the 3 shinytest2/AppDriver harness pitfalls).
gotchas: shinytest2::AppDriver$new() run via plain Rscript (outside testthat) needs
Sys.setenv(NOT_CRAN = "true") set first, or an internal skip_on_cran() throws instead of
skipping. app$upload_file()/app$set_inputs() need do.call(app$X, setNames(list(...), name)), not
a positional list argument. A DT::renderDT() table inside a not-yet-active tabPanel renders empty
until the tab is explicitly switched to (app$set_inputs(<ns>-mainTabs = "<tab>")) plus a short
settle wait -- wait_for_idle() alone does not cover DT's client-side JS init. See Learning 504 for
the full detail.
runtime_smoke: PASS -- live shinytest2 AppDriver smoke test against the real running app (upload
-> validate (dirty, then clean) -> preview -> confirm -> export sequence), both named Dragons
(#6 modalDialog/bslib, #7 DT NA-cell rendering) directly verified, zero SEVERE console entries.
changelog_ref: CHANGELOG.md 2026-08-10 "Slice 2 implemented -- full modCrossCenterIdentity Shiny
module: UI, confirm gate, exports, documentation, closes issue #149 (Session 505)"
commit: b8022a4a
```

```handoff
session: S504
date: 2026-08-10
status: complete
self_score: 9
predecessor_score: 10
active_task: Slice 1 of the ratified issue #149 design (validation core: checkCrossCenterMapping()
+ the D10 merge-column-loss fix, R-function level only, no UI) is DONE. Issue #149 stays open --
Slice 2 (full UI, confirm gate, exports, documentation) is the next pickup, a separate session.
what_was_done: Followed DEVELOPMENT_WORKSTREAM.md under this project's Strict TDD contract
(PRE-RED->RED->GREEN, AskUserQuestion-gated; REFACTOR owner-confirmed skip). Live-verified D10's
column-loss and Dragon #2's pre-rewrite-lookup bug directly against unmodified source before
writing tests; captured an exact dput() golden master. Extracted 8 shared, non-stop()ing helpers
from resolveCrossCenterIds() into R/resolveCrossCenterIds.R; added new exported
checkCrossCenterMapping() (R/checkCrossCenterMapping.R); resolveCrossCenterIds() keeps its exact
historical stop() text and all 7 pre-existing tests pass unmodified. D10 fix ships as an explicit,
NEWS.Rmd-documented additive behavior change. 10 new test blocks (9 new + 3 appended), 0
regressions. Fixed a live _pkgdown.yml reference-coverage gap the full suite caught. Commits:
2cab97a2 (claim stub) and this session's close-out commit.
next_steps: Slice 2 (full UI, confirm gate, exports, documentation) is the natural next pickup for
issue #149 -- see the plan's own §5 Slice 2 DONE criteria and verification list (live shinytest2
smoke test required; Dragons #6/#7 on modalDialog() under this app's bslib theme and DT NA
-rendering both still open). Separately, 3 untouched Phase 0 priorities remain: the
twin-connector-color fix-or-decline (Housekeeping, Effort S), the now-diagnosed-but-unfixed
10->15 pre-existing baseline warnings (Effort S, 3 test blocks now involved, see BACKLOG.md), and
the devtools::check() spelling-drift NOTE (9 words, Effort S, inst/WORDLIST).
key_files: docs/planning/issue149-cross-center-identity-mapping-workflow-plan.md (the ratified
plan, §5 Slice 2's own DONE criteria and Dragons #6-8), R/resolveCrossCenterIds.R (the 8 new
shared helpers + the relocated roxygen block -- read this file's own new "Shared validation
helpers" comment block before touching it again), R/checkCrossCenterMapping.R (the new exported
function Slice 2's UI will call), tests/testthat/test_checkCrossCenterMapping.R (9 tests
including the Dragon #2 regression proof), PROJECT_LEARNINGS.md Learning 503 (the roxygen
-adjacency and git-stash-contamination pitfalls).
gotchas: Any new function inserted into R/resolveCrossCenterIds.R BEFORE an existing exported
function silently detaches that function's roxygen doc block (devtools::document() re-associates
the block with the next function it precedes) -- always check `git status` for an unexpected
.Rd DELETION right after document(), and keep new helpers' own doc blocks physically adjacent to
their own functions, with the ORIGINAL function's doc block moved to stay immediately above its
(possibly relocated) definition. A `git stash` comparison used to prove "this warning/note
pre-exists on HEAD" is invalid if untracked new files exist and depend on the stashed-away tracked
code -- use `git stash -u` or verify a different way, and treat an implausible result (new
problems appearing, or a count LOWER than history) as a signal to check the comparison itself, not
the code. Slice 2 must also remember: D10 is an additive BEHAVIOR CHANGE (a previously-silent
merge on a disagreeing non-sire/dam column now errors) -- Slice 2's UI/export copy should not
imply this is purely cosmetic.
runtime_smoke: n/a -- confirmed via grep that neither resolveCrossCenterIds() nor
checkCrossCenterMapping() has any call site in the live Shiny app (Slice 2 wires them in);
script-callable only, matching the resolveCrossCenterIds() Slice 4 precedent.
changelog_ref: 6f58d9ad
commit: 6f58d9ad
```

