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

---

## ACTIVE TASK

### What Session 624 Did
**Deliverable:** Fix `CLAUDE.md`'s stale `test-app-*`/`test-e2e-*` "Clean regression read"
baseline-noise filter (`BACKLOG.md` Housekeeping item, found S623). (IN PROGRESS)
**Started:** 2026-08-23
**Status:** Session claimed. Work beginning.
**Ledger:** `CHANGELOG: pending` — set at claim; this session's actions are recorded in
`CHANGELOG.md` at Phase 3F. Until close-out, this line is the crash breadcrumb for the next
session's reconcile.

### Session 622 Handoff Evaluation (by Session 623)
**Score: 9/10.** **What helped:** the receipt's `next_steps` field named issue #163 specifically as
READY, with a concrete investigative starting point ("likely candidate is a missing/insufficient
`wait_for_idle()` around the D6 marker-genetics/mate-pair cross-module wiring") — directionally
correct (the actual root cause IS a missing wait for an async step, just a more specific one: DT's
own `server = TRUE` client<->server AJAX round-trip, not a generic Shiny idle wait) and enough to
start the investigation focused rather than blind. `gotchas` (2) — `gh run view <id> --log-failed`
returning empty for this job's log, work around via `gh api repos/.../actions/jobs/<id>/logs`
directly — was directly load-bearing: this session hit the identical need (pulling 3 separate
historical job logs, 08-18/08-20/08-21) and used the API path from the start with zero rediscovery
time. **What was missing:** nothing the receipt could reasonably have included — the exact
mechanism (DT's server-side AJAX round-trip racing the app's own `data-ready` signal) genuinely
required this session's own investigation; S622 correctly scoped it out rather than guessing.
**What was wrong:** nothing found inaccurate. **ROI:** high — both the next_steps direction and the
gotcha saved real investigative time.

### What Session 623 Did
**Deliverable:** Diagnose and fix the intermittent `e2e-mate-pair-analysis-module` shinytest2 E2E
failure — GitHub issue #163 (found by S622 in the same nightly CI run as the separately-fixed
`e2e-pedigree-` failures). **DONE.** **Started/Completed:** 2026-08-21/2026-08-22 (single session).

**What actually happened, in order:**

1. **Phase 0 orientation** (full protocol), then a mid-session owner interjection: the user flagged
   that `CLAUDE.md`'s "Clean regression read" guidance still treats `test-app-*`/`test-e2e-*` files
   as "pre-existing baseline noise" (citing `PROJECT_LEARNINGS.md` Learning 2/4, Sessions 3-4) even
   though the project has run 0 failed/0 error for weeks. Verified directly: `create_test_app()`
   (the specific thing undefined back in S3/S4) is now defined
   (`tests/testthat/helper-shinytest2.R:200`) and has been for a long time — the filter's premise is
   stale and, worse, would silently exclude a REAL regression landing in exactly those files (this
   session's own issue #163 is a concrete example). Logged to `BACKLOG.md` Housekeeping (READY,
   Effort S) rather than fixed mid-session (kept to the one claimed deliverable); this session's own
   regression checks did not use that filter.
2. **CI forensics**: pulled job logs for all 3 relevant `shinytest2.yaml` scheduled runs (08-18
   failed, 08-20 passed, 08-21 failed — same 2 assertions both failing runs) via the raw GitHub API
   (S622's own gotcha about `gh run view --log-failed` returning empty saved rediscovery time).
   Confirmed 3 earlier "failure" runs (08-12/08-13/08-14) were a DIFFERENT, already-resolved bug
   (`makeExamplePedigreeFile` not yet available) — correctly excluded from scope, not conflated with
   the current issue.
3. **Root-caused via direct execution + instrumentation, not inference**: read `modMatePairServer()`
   (`R/modMatePair.R`) and found `session$sendCustomMessage("setDataReady", ...)` fires synchronously
   right after `matchResults(res)`, but `pairsTable`/`excludedTable` are `DT::renderDT(server = TRUE)`
   outputs (the DT package default) — a separate, later, client<->server AJAX round-trip `data-ready`
   says nothing about. Confirmed empirically via 3 independent lines of evidence: (1) both real CI
   failures' captured HTML showed `.dataTables_processing` still `display: block` at read time; (2) a
   JS-instrumented local probe (event listeners on `nprcgenekeepr:dataReady` + DT's own `xhr.dt`/
   `draw.dt`) measured a genuine ~130-150ms gap even unthrottled locally; (3) a Chrome DevTools
   Protocol network-throttle harness (`app$get_chromote_session()$Network$emulateNetworkConditions()`)
   reliably reproduced the exact real failure (0 rows, id absent, processing visible) without a fix
   and reliably passed with one — a genuine forced RED→GREEN cycle for a bug that would not
   reproduce locally at normal speed (8/8 clean in an unthrottled tight loop, matching the
   `diagnose` skill's own "raise the reproduction rate" guidance for non-deterministic bugs).
   Presented root cause + fix approach via `AskUserQuestion` (PRE-RED gate) before writing any test
   code — user approved the recommended (defensive, both-tables) approach.
4. **RED**: added a new shared `wait_for_dt_rendered()` helper to `tests/testthat/helper-shinytest2.R`
   (polls a DT table's own processing indicator until hidden); wired it in before both `pairsTable`
   and `excludedTable` reads in `test-e2e-mate-pair-analysis-module.R`. **Caught a real bug in the
   helper's own first draft during the throttled verification**, not just in the target defect: used
   `el.closest('.dataTables_wrapper')`, which returned null 100% of the time because DT's wrapper is
   a DOM *child* of the table's outer container, not an ancestor (`.closest()` only walks up) — the
   broken helper's own 15s timeout simply outlasted the real (much shorter) render time, so a
   superficial check would have looked like a pass for the wrong reason. Caught by comparing the
   poll's own FALSE result against an immediately-following direct HTML read that showed the table
   WAS actually populated — the contradiction was the tell. Fixed with `.querySelector(...)`
   (descendant search). Presented RED evidence + the caught bug via `AskUserQuestion` (RED→GREEN
   gate) before running the confirming test suite.
5. **GREEN**: touched file (`test-e2e-mate-pair-analysis-module.R`) ran 5/5 clean at normal speed (0
   failed/error/warning each run). Full project-wide regression run **unfiltered**
   (`NPRC_RUN_E2E=true`, no `test-app-*`/`test-e2e-*` exclusion, per this session's own Learning-2/4
   finding above): 6,606 passed / 0 failed / 0 error / 2 skipped / 39 warnings across 2,244 test
   blocks — the 39 warnings confirmed pre-existing/unrelated (the touched file itself ran 0 warnings
   across all 5 of its own runs). A background-process handling mistake mid-run: killed a
   backgrounded regression run out of an unfounded timeout concern, right as it happened to complete
   naturally — produced a corrupted/truncated read; caught immediately (the printed content didn't
   match a clean run's shape) and re-ran cleanly via `nohup`+`disown` rather than trusting the
   corrupted output.
6. **REFACTOR**: `lintr::lint()` 0 findings on both touched files (no duplication to extract — the
   helper was written once, shared, from the start). `devtools::check()` deliberately skipped
   (test-only diff, matching S622's own precedent for the identical file-type diff).
7. **Close-out**: `PROJECT_LEARNINGS.md` Learning 656 recorded; `CLAUDE.md` learning-count
   cross-reference refreshed (655→656); `CHANGELOG.md` `[issue #163]` entry added; issue #163 closed
   on GitHub citing the full evidence trail; this handoff written.
8. **Post-close-out, owner-directed**: pushed all 11 session commits to `origin/master`
   (`004eb3e9..9128ee52`), then manually dispatched `shinytest2.yaml` (`gh workflow run`, since it
   only runs on schedule/dispatch, never on push) rather than waiting for tomorrow's schedule.
   **Result: SUCCESS** (run `32594167345`) — `e2e-mate-pair-analysis-module`: `passed=8 failed=0
   error=0`; `e2e-pedigree-` (S622's fix, same push): `passed=73 failed=0 error=0`. Both fixes now
   confirmed on live GitHub Actions CI, not just local verification. `CHANGELOG.md`/`HANDOFFS.md`
   updated with this result.

**Runtime smoke test (Phase 3E):** n/a in the traditional sense — no production runtime behavior
changed (zero `R/` diffs). The functional equivalent: the fixed tests were run against the REAL
Shiny app (shinytest2 + chromote, both real and throttled-real), confirming the fix holds under the
actual client-server rendering path under both normal and stressed network conditions.

**Close-out checklist mapping** (`CLAUDE.md`): citation / tutorial-article / `NEWS.Rmd` /
`a2interactive.Rmd` / `_pkgdown.yml` checklists all **N/A** — no new exported function, no new
user-facing Shiny feature, test-file-only diff. GitHub issue close-out **DONE** (issue #163 closed
this session, citing the `CHANGELOG.md` entry and verification evidence). Lint checklist **DONE** (0
lints, confirmed above).

**Self-assessment (Session 623): 9/10.** **Strengths:** (1) Did not stop at plausible static
evidence (the captured CI HTML alone) — built a JS-instrumented probe to MEASURE the actual race
window, then went further and used Chrome DevTools Protocol network throttling to force a genuine,
repeatable RED→GREEN cycle for a bug that would not reproduce locally at normal speed, rather than
settling for "probably fixed." (2) Caught a real bug in my own fix's first draft
(`closest()`/`querySelector()`) via the throttled verification itself, before it ever reached the
committed test file — the verification process did its job. (3) Took the user's mid-session
Learning-2/4 observation seriously: verified it directly (confirmed `create_test_app()` is now
defined) rather than deferring or dismissing it, and concretely changed this session's own
regression-check methodology (unfiltered) as a result, not just noted it for later. (4) Correctly
scoped the 3 older (08-12/08-13/08-14) CI "failures" as a different, already-resolved bug rather
than folding them into this investigation. **Weaknesses:** (1) Mishandled a backgrounded process
once — killed it out of an unfounded timeout worry right as it was completing naturally, producing
corrupted output that had to be diagnosed and the run redone; cost real time even though the
underlying regression evidence was never actually lost (recovered cleanly via `nohup`+`disown`).
(2) Spent several tool calls on ineffective "wait for the background task" filler (repeated no-op
Bash calls) before settling on a single proper long-running background waiter — should have gone
straight to that pattern.

### Session 621 Handoff Evaluation (by Session 622)
**Score: 9/10.** **What helped:** the receipt's `next_steps` field gave a clean, ordered
BACKLOG priority list (pedigree-diagram package-split scoping; NEWS.Rmd simplification; the
16-item BACKLOG sweep; 4 lower-priority items including `context_budget.py` and the macOS
chromote hang) that fed directly into this session's own Phase 0 priorities list — no
reconstruction needed, just re-verification the tags were still accurate (they were).
`gotchas` (2) — "`__proj_` node-id prefix is PRE-EXISTING `.buildMatingUnitForest()` dogleg
infrastructure, NOT introduced by Walker/BJL" — was directly load-bearing: this session's own
root-cause investigation independently rediscovered `__proj_` nodes mid-diagnosis (the first
jog-only-waypoint model gave 67 components instead of the ground-truth 56) and the gotcha's
framing meant the "wait, is this a Walker/BJL artifact?" tangent was ruled out in seconds
rather than becoming its own investigative detour. **What was missing:** the receipt
couldn't have flagged this (it's new information, not a gap in S621's own scope), but worth
noting for the record: S621's own close-out did not run the `gh run list` CI check this
session's Phase 0 found red (the scheduled `shinytest2.yaml` run) — not a fault of S621 (that
check runs at ORIENT, not close-out, and S621's own Orient predates the red run entirely by a
day), just context for why this sat unnoticed until now. **What was wrong:** nothing found
inaccurate. **ROI:** high — the handoff's own priorities list was accurate and immediately
actionable, and the `__proj_` gotcha specifically saved real investigative time.

### What Session 622 Did
**Deliverable:** Diagnose (and fix) the 2 shinytest2 `e2e-pedigree-` E2E failures surfaced by
the nightly CI run, found via this session's own Phase 0 unconditional `gh run list` check
(`CLAUDE.md`'s S545 addition). **DONE.** **Started/Completed:** 2026-08-21 (single session).

**What actually happened, in order:**

1. **Phase 0 orientation** (full protocol: `SESSION_RUNNER.md`/`SAFEGUARDS.md` read in full,
   `SESSION_NOTES.md`, `gh issue list` (12 open), `git status`/`log`/`diff --stat` (clean, S621
   fully closed out), `python3 methodology_dashboard.py` (96/100, 1 HIGH risk — `HANDOFFS.md`/
   `BACKLOG.md`/`CHANGELOG.md` all past the 2,000-line read cap, FM #28), ghost-session check on
   6 untracked files (all pre-existing, already traced by S614). **`gh run list` found the
   scheduled `shinytest2.yaml` run red** (2026-08-21T07:19 UTC) alongside all green push-triggered
   runs — surfaced as a NEW finding, not yet in `BACKLOG.md`/GitHub issues. Rendered the
   priorities list (4 `AskUserQuestion` options: the CI failure, `context_budget.py` evaluation,
   `BACKLOG.md` housekeeping continuation, the 16-item DONE sweep) — **user picked the CI
   failure.**
2. **CI forensics before claiming scope**, since the raw failure output alone didn't say which of
   the 19 module groups failed or why: pulled the full job log directly via
   `gh api repos/.../actions/jobs/<id>/logs` (the `gh run view --log-failed` CLI path returned
   empty for this job — a tooling gap worth remembering, not investigated further). Found 2
   distinct, unrelated failing groups: `e2e-mate-pair-analysis-module` (2 failures, empty results
   table, later confirmed intermittent — passed on the 2026-08-20 nightly run) and `e2e-pedigree-`
   (2 failures, same exact assertions both times). Cross-checked the pre-Walker/BJL-cutover
   2026-08-18 nightly log and found the identical `e2e-pedigree-` failure shape already present —
   ruling out "fresh migration regression" before it was ever claimed as the working hypothesis.
3. **Phase 1B claimed** (`SESSION_NOTES.md` stub + `HANDOFFS.md` `status: pending` receipt,
   committed `09f74f72`), scoped explicitly to `e2e-pedigree-` only — the mate-pair-analysis flake
   stated as out-of-scope up front, per "one intent" discipline.
4. **Root-caused by direct execution, not inference** (the `diagnose` skill's Phase 1-4): called
   `makePedigreeMatingLayout()` locally against the real `obfuscated_rhesus_mhc_ped.csv` fixture.
   `edgeStyle = "direct"` gave exactly the expected 56 marked edges (detection logic correct);
   `edgeStyle = "rectilinear"` (the app's actual default) gave 103 raw rows. First hypothesis
   (collapse only `__jog_` waypoint chains) gave 67 components, not 56 — genuinely wrong, caught
   by cross-validating with an independent `igraph::components()` implementation rather than
   trusting the hand-rolled union-find. Root-caused the gap: `__proj_` D2-dogleg nodes (from
   `.addRectilinearWaypoints()`) also need treating as pass-through waypoints on this real,
   375-individual fixture (the small unit-test fixture that "confirmed" `__proj_` unreachable was
   a different, smaller fixture under a structural invariant that doesn't generalize). With both
   waypoint types collapsed: exactly 56. Traced the MZ-connector chain the same way:
   `E06FRB -> __jog_23_a -> __jog_23_b -> HV7LZ3` — reaches the real co-twin node correctly, just
   via 2 hops. Presented the full root-cause finding via `AskUserQuestion` (PRE-RED gate) before
   writing any fix, since "the test's own assertion is wrong" doesn't fit the classic
   write-a-failing-test-first mold — user approved the chain-walking-fix approach.
5. **RED**: added 2 shared helpers to `tests/testthat/helper-shinytest2.R`
   (`count_colored_edge_lines()`, `get_edge_chain_terminus()`) implementing the validated
   waypoint-collapsing algorithm, and rewrote both failing assertions in
   `test-e2e-pedigree-module.R:350`/`:694` to use them.
6. **GREEN**: ran `test-e2e-pedigree-module.R` locally against the real Shiny app
   (shinytest2 + chromote, both available locally) — 52/52 passed, 0 failed/error (was 2 failed
   pre-fix), confirmed via `AskUserQuestion` gate before proceeding.
7. **REFACTOR**: `lintr::lint()` 0 findings on both touched files (no duplication existed to
   extract — the helpers were written once, shared, from the start). Full project-wide clean
   regression: 6,339 passed / 0 failed / 0 error / 0 non-baseline offenders across 2,244 test
   blocks. `devtools::check()` deliberately skipped (owner-confirmed via `AskUserQuestion`):
   test-only diff, no `R/`/`DESCRIPTION`/`NAMESPACE`/`man/` changes, and the check's own
   test-execution step is exactly what the regression read already covered.
8. **Scope discipline**: grepped every other `test-e2e-*.R` file for the same raw-edge-property
   assertion pattern (`edges.get()|edges.filter|m.length|marked.length`) — 0 hits, confirming the
   fragility was isolated to this one file, no broader audit owed. Filed
   [issue #163](https://github.com/rmsharp/nprcgenekeepr/issues/163) for the out-of-scope
   mate-pair-analysis-module flake rather than silently dropping it.
9. **Close-out**: `PROJECT_LEARNINGS.md` Learning 655 recorded; `CLAUDE.md` learning-count
   cross-reference refreshed (654→655); `CHANGELOG.md` `[ad hoc]` entry added; this handoff
   written.

**Runtime smoke test (Phase 3E):** n/a in the traditional sense — no production runtime behavior
changed (zero `R/` diffs). The functional equivalent here is the E2E run itself: the fixed tests
were executed against the REAL Shiny app (not mocked), confirming the fix actually holds under
the real rendering path, not just in isolation.

**Close-out checklist mapping** (`CLAUDE.md`): citation / tutorial-article / `NEWS.Rmd` /
`a2interactive.Rmd` / `_pkgdown.yml` checklists all **N/A** — no new exported function, no new
user-facing Shiny feature, test-file-only diff. GitHub issue close-out **N/A** for the fix itself
(ad hoc find-and-fix, no pre-filed issue to close) — issue #163 filed fresh for the deferred flake,
appropriately left open. Lint checklist **DONE** (0 lints, confirmed above).

**Self-assessment (Session 622): 9/10.** **Strengths:** (1) Did the CI forensics (pulling the raw
job log via the GitHub API when the CLI's own `--log-failed` came back empty) BEFORE claiming
scope or committing to a hypothesis — this is what surfaced that 2 unrelated failures were bundled
in one red run, preventing an over-scoped claim. (2) Checked the pre-migration CI log before
accepting "Walker/BJL regression" as the working theory, avoiding a wrong-cause investigation
entirely. (3) Caught my own FIRST root-cause hypothesis being wrong (67 vs. 56 components) by
cross-validating with an independent implementation (`igraph`) rather than trusting one hand-rolled
union-find, and kept digging until the discrepancy was fully explained (`__proj_` nodes), not
just patched around. (4) Recognized explicitly that "the fix is a test correction, not a
production fix" doesn't fit the classic TDD RED-must-fail mold, and surfaced that tension to the
user via `AskUserQuestion` rather than silently forcing the ceremony or silently skipping it.
**Weaknesses:** (1) Briefly misused `ScheduleWakeup` (a `/loop`-specific tool) to wait on a
background test run instead of just letting the harness's own task-notification mechanism handle
it — caught and self-corrected within the same turn, no real cost, but worth naming so it isn't
repeated. (2) Did not verify locally that `gh run view --log-failed` failing was itself worth a
one-line note anywhere durable (e.g. a `PROJECT_LEARNINGS.md` tooling-gotcha entry) — minor, left
as an oral note in this handoff instead.

### Session 613 Handoff Evaluation (by Session 614)
**Score: 10/10.** **What helped:** the `HANDOFFS.md` receipt's `next_steps` field named 3 exact,
binding obligations rather than a vague "continue Phase 2" pointer — "(1) write the new Test 15
... (2) restate the `qualifies(U)` gate ... the full 5 conjuncts ... (3) fold the widened
union-dot/`M_repr` cosmetic drift disclosure into whatever real-fixture measurement Phase 2
already owed." All 3 were directly actionable this session: (1) Test 15 was written in RED exactly
as specified; (2) the implementation's own `qualifies()` function uses the full 5-conjunct gate
(mateCount(P)==1, mateCount(M)==1, `!hasOwnDirectChild(P)`, both ids in `realIds`, unambiguous
opposite sex), not the abbreviated 3-conjunct form the design note's own first draft used; (3) is
explicitly folded into Phase 2b's own deferred real-fixture-measurement scope, not silently
dropped. `key_files` pointed exactly at the shipped `sweepMinSep()` (`:997-1015`) and `orderBySex`
(`:1054-1078`) line ranges — both read directly and cross-checked against my own port. `gotchas`
(1) "the S8 formula applies ONLY to the B1 qualifying case, do not generalize to B3" was directly
useful: my own first implementation draft had exactly this bug (inferring "is this a B1 call" from
`memberId %in% freePassIds` rather than from which call site invoked it), caught and fixed during
GREEN — the gotcha didn't prevent the bug, but its framing made the bug fast to recognize once the
test failure pointed at it. **What was missing:** nothing critical — Phase 2's own real size (large
enough to need this session's own further split into 2a/2b) wasn't flagged by S613's handoff, but
that was the parent plan's own "splittable if too large" note to make, not S613's job. **What was
wrong:** nothing found inaccurate. **ROI:** very high.

### What Session 614 Did
**Deliverable:** Walker/BJL Phase 2a (issue #141) — the adapter mechanics half of the pedigree
adapter parallel to production, per `docs/planning/pedigree-diagram-walker-bjl-apportioning-
redesign-plan.md`'s Phase 2 spec as amended by the Phase 1b design note's §8 resolution. **DONE**
— new `.positionMatingUnitForestBJL()` implementing the full 3-tier reconciliation, GREEN and
REFACTORed, 17/17 new tests passing, zero collateral damage. Owner-directed scope split (this
session's own Phase 1 `AskUserQuestion`, before declaring RED): Phase 2b (the live-render helper +
real-375-fixture A/B verification) is explicitly **not done** — a required, separate follow-up
session. **Started/Completed:** 2026-08-19–2026-08-20.

**What actually happened, in order:**

1. **Phase 0 orientation** — read `SESSION_RUNNER.md`/`SAFEGUARDS.md` in full; `SESSION_NOTES.md`
   (S613's own active task); `gh issue list` (13 open); `git status`/`log`/`diff --stat` (clean,
   S613 fully closed out, ledger frontiers both `== HEAD`, no reconcile owed); `gh run list` (CI
   green on recent completed runs, 2 in-progress at report time); `methodology_dashboard.py`
   (96/100, 1 HIGH risk — `SESSION_NOTES.md`/`HANDOFFS.md` both past the 2,000-line cap, unchanged
   from S613, not fixed this session per report-don't-fix). Ghost-session check on 6 untracked
   files (4 rendered `docs/planning/*.html` evidence docs, 1 Office lock-file artifact, 1
   `scratchpad/` dir of old verification scripts) — all traced to already-documented, already-
   resolved work, none a ghost deliverable. Rendered the priorities list (4 numbered
   `AskUserQuestion` options) — **user picked the Walker/BJL Phase 2 item.**
2. **Grounded directly in both planning documents before any code** — full reads of
   `docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md` (Migration Path/Phase
   2 spec) and `docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-reconciliation.md`
   (§3's mechanism, §8's seam-resolution formula and its 2 disclosed Phase-2 obligations).
   **Process gap, disclosed:** this reading ran across several large tool calls before the Phase 1B
   claim stub was written — a real deviation from Learning 628's own "claim at the literal next
   tool call" rule, caught and corrected (claimed immediately after, before any further work) but
   not avoided outright. No harm resulted (zero commits/technical changes happened during the gap),
   but the discipline itself was not followed as written.
3. **Phase 1B claimed** — `SESSION_NOTES.md` stub + `HANDOFFS.md` `status: pending` receipt,
   committed (`577ad298`).
4. **Scope decision, via its own dedicated `AskUserQuestion` before declaring RED** (per CLAUDE.md's
   own "pre-RED scope decision is a separate question" rule): given Phase 1a (a far simpler
   *generic* engine) filled a full session by itself, and Phase 2 adds the full B1/B2/B3
   classification + 3-tier reconciliation + 15-test matrix + a new live-render helper, the user
   picked **"split: adapter first"** — this session scopes to the adapter + full synthetic test
   matrix; the live-render helper and real-375-fixture verification are explicitly deferred to a
   Phase 2b session, disclosed up front in the test file's own header, not silently dropped.
5. **PRE-RED → RED**, gated via `AskUserQuestion`: wrote
   `tests/testthat/test_positionMatingUnitForestBJL.R` — 17 `test_that()` blocks (the design
   note's own 15-fixture matrix, §4 Tests 1-14 + §8.4's required Test 15, plus 3 property tests).
   Derived exact-value oracles for the numerically-tricky fixtures (Tests 1, 2, 5, 6, 11, 13, 14,
   15) by actually running Tier 1's own mechanics (a throwaway probe script calling the real,
   existing `.buildMatingUnitForest()`/`.positionTreeApportion()`/`.buildForestChildrenOf()`, plus
   a hand-copied `sweepMinSep()` backstop matching the shipped push semantics exactly) against each
   fixture — never hand-derived. Found and fixed 3 of my own fixture-construction bugs during this
   process (wrong assumed anchor in 2 fixtures; a vector-misalignment bug in a 3rd) by running each
   fixture against the REAL `.buildMatingUnitForest()` before finalizing assertions, not by
   reasoning alone. Confirmed genuine RED: all 17 blocks error on "could not find function," full
   clean regression 0 failed / 17 error (all new) / 0 non-baseline offenders. Committed (`0a43ec30`).
6. **RED → GREEN**, gated: implemented `.positionMatingUnitForestBJL()` in
   `R/makePedigreeDiagramData.R` (new function, zero changes to `.positionMatingUnitForest()` or
   any other existing code). First run found 9 failures; diagnosed and fixed each by actually
   running the failing fixture in isolation, not by inspection — **2 were genuine implementation
   defects**: (a) B1 eligibility needs an explicit `!hasParentEdge(M)` conjunct the OLD, shipped
   `freePassIds` helper doesn't carry (its own candidate pool never needed it, since under the OLD
   algorithm a mating unit's own sire/dam can never also be someone's tracked child — a distinction
   2b's "grandchild reattached as a real child" architecture breaks), causing a B2 individual to
   wrongly get a second, Tier-3 derived-point row; (b) a dangling non-anchor party (no own row in
   `ped`) crashed on `sireOf[[id]]`/`damOf[[id]]`, fixed by excluding dangling ids from B1
   eligibility up front, matching the OLD function's own confirmed behavior (verified directly:
   `.positionMatingUnitForest()` drops a dangling free-pass parent from its output entirely). The
   other 7 failures were my OWN test bugs (a legitimate epsilon nudge from Tier 2's own exact-tie
   sweep I hadn't accounted for in 2 assertions; a B1/B2 id-classification ambiguity in a 3rd
   fixture I'd wrongly assumed was "B1-free"). Recorded `PROJECT_LEARNINGS.md` Learnings 639/640 for
   both defect classes — both are genuinely transferable, not one-off. Verified: 17/17 GREEN (53
   expectations), full clean regression 0 failed/0 error project-wide, 0 non-baseline offenders.
   Committed (`e7f1f593`).
7. **GREEN → REFACTOR**, gated: `lintr::lint()` (package loaded first, Learning 224 methodology)
   found exactly 2 style lints (`character(0)` → `character(0L)`), test file already 0. Fixed,
   re-verified 17/17 GREEN + 0 lints + full clean regression unaffected. Committed (`afa7c5f5`).
8. **Extra verification beyond the gated cycle:** ran `devtools::document()` (0 changes, expected —
   `@noRd`, no exported symbol) and a full `devtools::check()` as an additional build-equivalent
   confirmation beyond the testthat/lintr checks the gated cycle itself required. Result: **1
   WARNING, 2 NOTEs, 0 errors — all 3 pre-existing, none attributable to this session's diff:** the
   non-portable-filename WARNING and the "scratchpad" top-level-directory NOTE both trace to the
   SAME untracked files this session's own Phase 0 ghost-session check already found and reported
   (an Office lock-file artifact, `inst/extdata/reference/~$e Compounding Loop.html`; a pre-existing
   `scratchpad/` dir left by an earlier, unrelated session) — confirmed pre-existing, not fixed here,
   per the established "report an incidentally-discovered, unrelated gap, don't fix it mid-session"
   precedent (Learning 382). The 3rd NOTE (`vignettes/figure/` knitr leftover) is the same
   long-documented pre-existing NOTE multiple prior sessions' own close-outs have already recorded.
9. **Close-out:** `BACKLOG.md`'s Walker/BJL item updated with the S614 progress paragraph;
   `PROJECT_LEARNINGS.md` Learnings 639/640 recorded; this handoff written.

**Runtime smoke test (Phase 3E):** n/a in the traditional sense — the new function is `@noRd`
(internal, non-exported), has zero call sites anywhere in the package (grep-confirmed: the only
reference to `.positionMatingUnitForestBJL` outside its own definition and its own test file is
this session's own documentation), and is never reached by the Shiny app's reactive chain or any
exported function. Matches Phase 1a's own precedent exactly (`.positionTreeApportion()` also
shipped inert, wired to nothing, in its own session). No runtime behavior changed; nothing to
smoke-test.

**Close-out checklist mapping** (`CLAUDE.md`): citation / tutorial-article / `NEWS.Rmd` /
`a2interactive.Rmd` / `_pkgdown.yml` checklists all **N/A** — no new exported function, no new
user-facing Shiny feature, `@noRd` throughout. GitHub issue close-out **N/A** — issue #141 stays
open (this is one slice of a 5+ session parent plan). Lint checklist **DONE** (0 lints on both
touched files, confirmed above).

**Self-assessment (Session 614): 9/10.** **Strengths:** (1) Derived exact-value oracles for the
numerically-tricky RED fixtures by actually executing the existing engine against a throwaway
probe, rather than hand-computing or guessing — caught 3 of my own fixture-construction mistakes
before they ever reached the implementation phase, matching this investigation's own established
"verified by execution" standard. (2) Made the Phase 2a/2b scope split explicit via its own
dedicated `AskUserQuestion`, rather than either forcing all of Phase 2 into one session (risking a
rushed, under-verified close) or silently narrowing scope without surfacing the decision. (3)
Diagnosed every GREEN-phase test failure by actually running the specific failing fixture in
isolation and reasoning from real output, not by inspection or assumption — this is what
distinguished the 2 genuine implementation defects from the 7 test-authoring bugs, and would have
been impossible to sort out correctly from code-reading alone. (4) Recorded both genuine defect
classes as transferable `PROJECT_LEARNINGS.md` entries with concrete practical rules, not just
fixed-and-moved-on. (5) Ran the full clean-regression read 3 times (post-RED, post-GREEN,
post-REFACTOR) plus a fresh `devtools::check()`, not just once at the end. **Weaknesses:** (1) The
Phase 1B claim was not made at the literal next tool call after the user picked this item — 2 large
planning-document reads happened first (disclosed above, no technical harm resulted, but the
discipline itself was violated). (2) Did not build the live-render helper or measure the real
375-individual fixture this session — **this is a real, material gap, not a formality**: the parent
plan's own Verification Plan names the real-fixture zero-coincidence check as "the single most
important test in the whole migration," and it has NOT been run against this new adapter. Phase 2a
being GREEN on synthetic fixtures is necessary but explicitly not sufficient evidence the adapter
is correct on the actual pedigree shape this whole redesign exists to fix — a future session must
not skip Phase 2b or treat Phase 2a's own green tests as if they already answered that question.
(3) 3 of my own 17 RED-phase fixtures needed correction during GREEN (not wrong in intent, but
wrong in a specific mechanical detail — which party wins an anchor tie-break, or what a legitimate
epsilon nudge does to an exact-equality assertion) — a more careful first pass, verifying EVERY
fixture (not just the numerically-hardest ones) against the real `.buildMatingUnitForest()` before
finalizing, would have caught these in RED rather than GREEN. **ROI:** high — Phase 2's single
largest, most novel implementation slice (the 3-tier adapter itself) is done and verified; Phase 2b
is now a bounded, well-scoped remainder (build one reusable helper, run it on 2-3 fixtures) rather
than an undifferentiated continuation of "the whole rest of Phase 2."

**Next steps:** Phase 2b (its own session) — build `tests/testthat/helper-live-render-positions.R`
(the chromote-based `getPositions()` ground-truth harness the parent plan's own Phase 2 spec
requires), then run the real-fixture zero-coincidence gate and the F1/Track-C/real-375 live-render
checks against `.positionMatingUnitForestBJL()`. **Must explicitly measure, not assume:** whether
the adapter's own zero-exact-coincidence property (verified so far only on synthetic fixtures)
survives the real 375-individual pedigree's own scale and irregularity — if it does not, Phase 2b
returns to Phase 1b with the specific counter-example, per the parent plan's own gate. Also owed
from S613's own Obligation 3 (deferred here, not dropped): fold the widened union-dot/`M_repr`
cosmetic-distance disclosure (`sweepMinSep()` pushing `P` itself, not only `P`'s children) into
whatever real-fixture measurement Phase 2b runs.

**Key files:** `R/makePedigreeDiagramData.R:1278-1457` (`.positionMatingUnitForestBJL()`,
the new function, immediately after `.positionMatingUnitForest()` and before
`makePedigreeMatingLayout()`); `tests/testthat/test_positionMatingUnitForestBJL.R` (all 17 tests,
own header documents the Phase 2b deferral explicitly); `R/positionTreeApportion.R`
(unchanged, Phase 1a engine this adapter calls into for Tier 1); `docs/planning/pedigree-diagram-
walker-bjl-phase1b-mixed-gen-reconciliation.md` §3/§8 (the mechanism/formula this implements);
`PROJECT_LEARNINGS.md` Learnings 639/640 (the 2 defect classes found this session).

**Gotchas for Phase 2b:** (1) The chromote live-render helper is genuinely new infrastructure (no
prior committed version exists despite 2 prior bespoke, uncommitted uses per the parent plan's own
C2-4 finding) — budget real design time, not just a mechanical port. (2) `.positionMatingUnitForestBJL()`
is entirely untested against ANY real-world-shaped irregularity (polygamous anchors beyond 5
mates, deep asymmetric branches, actual dangling-parent data) — the real-375 fixture will very
likely surface at least one case the 17 synthetic fixtures didn't anticipate; do not be surprised
if Phase 2b needs its own repair-and-critique round rather than a clean first pass, matching this
investigation's own 6-prior-attempts history. (3) `mateCountP`/`mateCountM` in `qualifies()` are
computed via `sum(anchoredUnits$sire==id | anchoredUnits$dam==id)` — this counts ANCHORED unions
only (matching the design note's own intent), not total mating-unit membership; if a future change
touches this function, preserve that distinction. (4) `derivedX()`'s `isB1` parameter is passed
explicitly by each call site (never inferred from `memberId %in% b1Ids`) specifically to avoid
Learning 639's own bug recurring — do not "simplify" this back to an inferred check.

---

### Session 614 Handoff Evaluation (by Session 615)
**Score: 9/10.** **What helped:** the `HANDOFFS.md`/`SESSION_NOTES.md` `next_steps` field named 5
exact, executable pieces of work ("build helper-live-render-positions.R"; "run the real-fixture
zero-coincidence gate"; "the F1/Track-C/real-375 live-render checks"; "must explicitly measure, not
assume: whether the zero-exact-coincidence property survives real scale"; "fold in S613's Obligation
3") — all 5 were directly actionable and became this session's own 7 new tests almost one-to-one.
`key_files` pointed exactly at the shipped `.positionMatingUnitForestBJL()` (`:1278-1457`) and the
new function's own output contract (`id`/`x`/`gen`, no `y`) — both read directly and confirmed
before writing a single test. **Gotcha #2 ("the real-375 fixture will very likely surface at least
one case the 17 synthetic fixtures didn't anticipate") was directly borne out — but not in the
shape predicted:** no code defect surfaced (the adapter's own internal invariants all passed clean
on first run), but the REAL-SCALE live-render check surfaced something more fundamental — a
previously-unmeasured characteristic of vis.js's own rendering (pixel-rounding collapses the shared
1e-3 cosmetic tie-break nudge) that neither the 17 synthetic tests nor any prior session had reason
to find, since it requires actual production-scale chromote rendering to observe. The handoff's own
framing ("do not be surprised if Phase 2b needs its own repair-and-critique round") correctly primed
for "expect something," even though what showed up was a measurement finding, not an implementation
bug. **What was missing:** the handoff didn't anticipate that `devtools::check()` itself (not just
`testthat`/`lintr`) would be needed to catch a real regression (the new "unstated dependencies in
tests" WARNING) — a reasonable gap, since Phase 2a touched zero chromote/htmlwidgets code, so there
was no reason for S614 to have hit this. **What was wrong:** nothing found inaccurate. **ROI:** very
high — the 5-item `next_steps` list mapped almost directly onto this session's own scope, with zero
re-derivation needed.

### What Session 615 Did
**Deliverable:** Walker/BJL Phase 2b (issue #141) — the real-fixture verification half of the
Walker/BJL pedigree adapter, per `docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-
plan.md`'s Phase 2 spec and `docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-
reconciliation.md` §8.4 Obligation 2. **DONE** — new reusable chromote-based live-render helper,
7 new tests (24 total in the file), all GREEN and REFACTORed. **Started/Completed:** 2026-08-19 –
2026-08-20.

**What actually happened, in order:**

1. **Phase 0 orientation** — read `SESSION_RUNNER.md`/`SAFEGUARDS.md` in full; `SESSION_NOTES.md`
   (S614's own active task); `gh issue list` (13 open); `git status`/`log`/`diff --stat` (clean, 6
   local unpushed S614 commits, both `CHANGELOG.md`/`HANDOFFS.md` ledger frontiers `== HEAD`, no
   reconcile owed); `gh run list` (S612's own `R-CMD-check.yaml` failure traced to hosted-runner
   infra flake, not code; 3 S613-push workflows shown `in_progress` 5+ hours — flagged as likely
   stuck/orphaned, not diagnosed, per report-don't-fix); `methodology_dashboard.py` (96/100, 1 HIGH
   risk, unchanged from S614). Ghost-session check on the same 6 untracked files S614 already
   traced — unchanged, no new ghost work. Rendered the priorities list (4 numbered `AskUserQuestion`
   options) — **user picked Walker/BJL Phase 2b.**
2. **Phase 1B claimed** — `SESSION_NOTES.md` stub + `HANDOFFS.md` `status: pending` receipt,
   committed (`87c59054`).
3. **PRE-RED research** — full reads of both governing planning documents' Phase 2 spec, Phase 1b
   §8.4 Obligation 1/2, and the `data-raw/kinship2FidelityValidation.R`/`test_makePedigreeMatingLayout.R:124`/
   investigation-doc §2.2 precedent for the live-render methodology; read `.positionMatingUnitForestBJL()`
   and `makePedigreeMatingLayout()` directly (not from memory) to derive the exact `xScale=120`/
   `yScale=150` scaling and the vis.js `document.getElementById("graph"+el.id).chart` binding
   mechanism (read directly from the installed `visNetwork.js` source, then **verified live via a
   throwaway probe script** before committing to the design — confirmed the mechanism actually
   works and found `elementId` isn't reliably honored by `visNetwork()`, so the helper locates the
   widget dynamically via `document.querySelector('.visNetwork')` instead). Found F1 and "Track C"
   are the SAME already-established 9-subject fixture (not 2 separate ones the plan's own wording
   suggested). **2 dedicated `AskUserQuestion` gates before RED:** (a) minimal position-only
   nodes/edges for the live-render check vs. full `makePedigreeMatingLayout()` cosmetic decoration
   — owner picked minimal, informed by the probe confirming styling doesn't affect `getPositions()`
   when physics is off; (b) the formal PRE-RED→RED gate itself, listing the exact 7 planned tests.
4. **RED** — added `.buildMinimalEdges()` test helper + 7 `test_that()` blocks to
   `test_positionMatingUnitForestBJL.R` (24 total). Confirmed genuine RED: the 3 helper-dependent
   tests errored "could not find function `getLiveRenderedPositions`"; the 4 real-fixture
   measurement tests (calling the ALREADY-SHIPPED adapter, genuinely unknown outcome) all **passed
   on first run** — zero-coincidence gate clean, exact-midpoint invariant clean, 224/237 structural
   count confirmed, Obligation 2 drift comfortably bounded. Directly computed (outside testthat, for
   the session record) the actual measured numbers: 180/224 touching / 208/224 half-column (vs. OLD
   175/224 / 203/224); 34 qualifying B1 unions, drift 0.399–0.401.
5. **GREEN** — implemented `getLiveRenderedPositions()` (`tests/testthat/helper-live-render-positions.R`).
   First combined-file run found 2 real bugs, both found and fixed via direct execution, not
   inspection: (a) chromote's own 10s default `Page$loadEventFired()` timeout was too short for the
   714-node real fixture's self-contained HTML — added a `loadTimeout` parameter (30s default, 60s
   for the real fixture); (b) **major finding, not a bug**: live-rendering revealed vis.js's
   `getPositions()` rounds to whole pixels (confirmed via a direct 3-node probe: `x=150/150.12/150.5`
   all read back as `150`), so the shared 1e-3-raw-unit cosmetic tie-break nudge (×`xScale=120` =
   0.12px) used by BOTH the OLD and NEW algorithms renders pixel-identical to whatever it was
   nudged away from. Measured side by side on the real fixture (same script, same helper): OLD
   368/714 nodes pixel-coincident (182 groups), NEW 380/714 (190 groups) — comparable, a
   pre-existing shared characteristic, not a Phase 2b regression. **Stopped and asked** (via
   `AskUserQuestion`) rather than silently redesigning the tests: owner picked "diagnostic, not hard
   gate" — Tests 6/7 rewritten to assert only DataSet-integrity (no id silently collapses; confirmed
   clean on both fixtures) and report the measured rate via `message()`. Recorded
   `PROJECT_LEARNINGS.md` Learning 641. 24/24 tests GREEN; full clean regression 0 failed/0 error;
   `lintr::lint_package()` 0 findings (already clean, no fixes needed).
6. **`devtools::check()` — found and fixed a real NEW WARNING** ("unstated dependencies in tests:
   chromote, htmlwidgets") — the SAME `pkg::fn()` pattern `data-raw/kinship2FidelityValidation.R`
   already used safely (that script is `.Rbuildignore`d, outside the checked surface) is genuinely
   unsafe once copied into the CHECKED `tests/testthat/` surface. **Stopped and asked** rather than
   unilaterally choosing between "add to Suggests" vs. "avoid `::` syntax"; the user clarified the
   general packaging rule directly (`Suggests:` for test/example/vignette-needed packages,
   `Config/Needs/<name>:` for dev-tooling-only ones) rather than answering the question as posed —
   applied it: `chromote`/`htmlwidgets` added to `Suggests:` (confirmed `renv::snapshot(dev=TRUE)`
   needed no changes, both already transitively pinned). **User then flagged `covr`'s own placement
   mid-turn** (already sitting in `Suggests:` despite being pure coverage tooling, already installed
   independently by `.github/workflows/test-coverage.yaml:27`) — relocated to a new
   `Config/Needs/coverage: covr`, matching the file's own pre-existing `Config/Needs/website: quarto`
   precedent. Flagged (not fixed, user directed a `BACKLOG.md` item instead) that `devtools`/
   `roxygen2`/`pkgdown` look like further instances of the same misplacement. Recorded
   `PROJECT_LEARNINGS.md` Learning 642. Re-ran `devtools::check()`: "unstated dependencies in tests
   ... OK" confirmed; final result 0 errors/1 WARNING/2 NOTEs, all 3 pre-existing (non-portable
   filename, `scratchpad/` top level, `vignettes/figure/` knitr leftover) — identical to S614's own
   baseline, zero new.
7. **REFACTOR** — re-confirmed `lintr::lint_package()` 0 lints project-wide and the full test suite
   (via `devtools::check()`'s own `testthat.R` run, 24/24 + whole project) green; no structural code
   changes needed beyond the GREEN-phase bug fixes already made.
8. **Close-out:** `BACKLOG.md`'s Walker/BJL item updated with the Phase 2b progress paragraph; new
   Housekeeping item added for the `Suggests`/`Config-Needs` cleanup (user-directed); this handoff
   written.

**Runtime smoke test (Phase 3E):** n/a, matching Phase 1a/2a's own precedent exactly —
`.positionMatingUnitForestBJL()` itself is unchanged this session (zero production code touched;
only new test infrastructure + a `DESCRIPTION`/`renv.lock` metadata change). No runtime behavior
changed; nothing to smoke-test.

**Close-out checklist mapping** (`CLAUDE.md`): citation / tutorial-article / `NEWS.Rmd` /
`a2interactive.Rmd` / `_pkgdown.yml` checklists all **N/A** — no new exported function, no new
user-facing Shiny feature. GitHub issue close-out **N/A** — issue #141 stays open (one slice of a
5+ session parent plan). Lint checklist **DONE** (0 lints, confirmed above).

**Self-assessment (Session 615): 9/10.** **Strengths:** (1) Verified the vis.js `getPositions()`
binding mechanism via a live throwaway probe BEFORE committing to the helper's design, exactly
matching this project's own "verified by execution" standard — caught that `elementId` isn't
reliably honored, avoiding a design built on an untested assumption. (2) When the live-render check
revealed the pixel-rounding characteristic, stopped and asked rather than either (a) silently
weakening the test to hide an inconvenient result, or (b) unilaterally attempting a production-code
fix outside a measurement session's own charter — this is the single most consequential judgment
call this session made. (3) Measured the OLD algorithm side by side with the NEW one before
characterizing the finding, rather than assuming (without evidence) that Phase 2b's own new code was
the cause — this turned a scary-looking "380 nodes colliding" result into a correctly-contextualized
"comparable to the pre-existing baseline" finding. (4) Ran `devtools::check()`, not just
`testthat`/`lintr`, catching a real regression neither of the other two tools could have found; fixed
it via the owner's own stated packaging rule rather than guessing. (5) Directly computed the actual
real-fixture measured numbers (touching/half-column counts, Obligation 2 drift range) via a
standalone script for the session record, since `testthat`'s own reporters suppress `message()`
output by default. **Weaknesses:** (1) The initial DESCRIPTION-fix question offered only 2 options
(add to Suggests vs. avoid `::`) without considering the `Config/Needs/` alternative at all — the
user had to supply that framing directly rather than it being one of the offered choices, a real gap
in the question's own completeness. (2) Did not proactively audit the REST of `Suggests:` for the
same misplacement pattern before the user pointed at `covr` specifically — once `covr`'s own
placement was flagged, `devtools`/`roxygen2`/`pkgdown` should arguably have been checked with the
same scrutiny in the same pass rather than only afterward, in prose, unverified. (3) The Obligation-2
measurement test re-derives `b1Ids`/`qualifies()` predicates directly from `forest`/`ped` rather than
reusing any shared production logic — necessary (these predicates are internal to
`.positionMatingUnitForestBJL()`, not separately callable) but creates a real, disclosed duplication-
drift risk if the production predicate ever changes without the test being updated to match. **ROI:**
very high — Phase 2 is now fully closed out with real, measured evidence (not just synthetic-fixture
coverage) behind its own most important gate, and a previously-unknown, potentially load-bearing
characteristic of the rendering pipeline (pixel-rounding vs. cosmetic nudges) is now documented
rather than latent.

**Next steps:** Phase 3 (cutover) — its own separate session, per the parent plan's own Phase 3
spec: **Commit 3-1** (4 files — production call site switch, `.positionMatingUnitForest()`/
`.computeDupNudge()`/patch-stack deletion, `.positionMatingUnitForestBJL()` renamed to replace it
outright, `test_positionMatingUnitForest.R` becomes the merged final test file with re-pinned
positional literals); **Commit 3-2** (2 files, genuinely deferrable only if `test_addRectilinearWaypoints.R`/
`test_resolveEdgeNodeCollisions.R` are ALREADY green after Commit 3-1 — must be confirmed by
actually running the suite, not assumed). **A decision Phase 3 should make explicitly, informed by
this session's own new evidence:** whether the pixel-rounding/cosmetic-nudge characteristic
(Learning 641) needs its own follow-up design session (widening the epsilon so it survives pixel
rounding) before or after cutover — this session deliberately left that open, not resolved, per its
own measurement-only charter. Also still owed: Phase 4 (cleanup/docs, close issue #141).

**Key files:** `tests/testthat/helper-live-render-positions.R` (new, the reusable chromote helper —
`getLiveRenderedPositions()`, `loadTimeout` param); `tests/testthat/test_positionMatingUnitForestBJL.R:809-`
(Phase 2b's 7 new tests, `.buildMinimalEdges()` helper near the top); `DESCRIPTION` (`chromote`/
`htmlwidgets` added to `Suggests:`, `covr` moved to new `Config/Needs/coverage:`); `R/makePedigreeDiagramData.R:1278-1457`
(`.positionMatingUnitForestBJL()`, UNCHANGED this session — read only, for the Obligation-2 predicate
re-derivation); `PROJECT_LEARNINGS.md` Learnings 641/642 (the 2 findings this session).

**Gotchas for Phase 3:** (1) The pixel-rounding characteristic (Learning 641) applies EQUALLY to the
OLD algorithm being replaced — do not treat it as something the cutover itself needs to fix; it's a
pre-existing, disclosed, comparable-magnitude characteristic of both. (2) `test_positionMatingUnitForestBJL.R`'s
own Tests 6/7 (F1/real-375 live-render) are diagnostic, not hard gates — when merging this file's
content into `test_positionMatingUnitForest.R` per Commit 3-1's own spec, preserve that framing
rather than accidentally hardening them into a gate neither algorithm clears. (3) `.buildMinimalEdges()`
and the live-render tests deliberately do NOT exercise `makePedigreeMatingLayout()`'s own full
cosmetic decoration (shapes/colors/twin markers) — Phase 3's own live-render check (F1/Track-C/real
fixture, "directly confirming... correct child-centering and no new visual overlap") is the first
point where that full decoration actually needs live-rendering, and should reuse
`getLiveRenderedPositions()` unmodified (per the plan's own intent) rather than building a second
helper. (4) `getLiveRenderedPositions()`'s default `loadTimeout=30`/`waitSeconds=1.5` are fine for
small fixtures; the real-375-scale render needs `loadTimeout=60`/`waitSeconds=3` explicitly (not
committed as new defaults, to keep small-fixture tests fast) — pass them explicitly for any
comparably large fixture in Phase 3.

### Session 615 Handoff Evaluation (by Session 616)
**Score: 7/10** (structural ceiling, not a quality fault). **What helped:** the receipt's
`key_files`/`what_was_done` fields let me quickly confirm `getLiveRenderedPositions()` and its
2 call sites were the only surface in play, and its own disclosed gotcha — "the real-375 fixture
will very likely surface at least one case the 17 synthetic fixtures didn't anticipate" — primed
me correctly for "expect a genuine new finding here," which turned out true, just in a different
place (CI-platform timing, not the fixture itself). **What was missing, structurally rather than
by omission:** S615's `next_steps`/`gotchas` are entirely about Phase 3 (cutover) — which is NOT
what this session worked on. This isn't a handoff quality gap: the run that actually failed
(`32335116264`) was triggered by S615's OWN final close-out commit push, meaning the failure
didn't exist yet at the moment S615 wrote its handoff — no amount of care in that handoff could
have surfaced it. This session's actual task was found by MY OWN Phase 0's `gh run list` CI-status
check (the CLAUDE.md addition ratified S545), not inherited from S615's handoff at all. **What was
wrong:** nothing found inaccurate in what S615 claimed about its own work. **ROI:** low for THIS
session specifically, but through no fault of S615's — a real structural limit on how far a
written handoff can reach (it cannot predict a CI run triggered by its own closing commit).

### What Session 616 Did
**Deliverable:** Diagnose and fix the `R-CMD-check.yaml` `windows-latest` CI failure (`gh run`
`32335116264`) introduced by S615's new `tests/testthat/helper-live-render-positions.R`. **DONE**
— root-caused to a documented chromote `Page$navigate()`/`Page$loadEventFired()` race
(rstudio/chromote#102), fixed via `$go_to()`, verified GREEN on 2 consecutive real
`R-CMD-check.yaml` pushes (`windows-latest` clean both times). **Started/Completed:** 2026-08-20.

**What actually happened, in order:**

1. **Phase 0 orientation** — read `SESSION_RUNNER.md`/`SAFEGUARDS.md` in full; `SESSION_NOTES.md`
   (S614/S615's own active task, both read in full); `gh issue list` (13 open); `git status`/`log`/
   `diff --stat` (clean, ledger frontiers both `== HEAD`, no reconcile owed); `methodology_dashboard.py`
   (96/100, 1 HIGH risk, unchanged); **`gh run list --branch master --limit 10`** (per CLAUDE.md's
   S545-ratified CI-status-check step) found `R-CMD-check.yaml` RED on `windows-latest` only, from
   S615's own final push — surfaced as a 4th numbered priorities-list option, distinct from any
   `BACKLOG.md` tag. Ghost-session check on the same 6 untracked files prior sessions already traced
   — unchanged, no new ghost work. Rendered the priorities list (4 numbered `AskUserQuestion`
   options) — **user picked the CI fix.**
2. **Protocol gap, disclosed and corrected (see `PROJECT_LEARNINGS.md` Learning 644):** went
   straight from the picker answer into diagnosis (`gh run view --log-failed`, downloading the
   failed run's artifact, reading `00check.log`/`testthat.Rout.fail`) WITHOUT claiming the session
   first — a 4th recurrence of the Learning 624/625/628 pattern. Caught once the diagnosis reached
   a concrete root-cause hypothesis; corrected immediately (claimed before writing any fix code),
   committed separately (`db736a3d`).
3. **Diagnosis, verified by primary sources, not guesswork:** downloaded the failed run's
   `nprcgenekeepr.Rcheck` artifact directly (`gh run download`) rather than trusting the annotation
   summary alone; confirmed both Windows failures were `Chromote: timed out waiting for event
   Page.loadEventFired` at `helper-live-render-positions.R:84`. `WebSearch`/`WebFetch` research
   (rstudio/chromote#102, the package's own "Loading a page reliably" vignette) identified the
   documented race between `Page$navigate()` and `Page$loadEventFired()` as separate CDP round-
   trips, and `$go_to()` as chromote's own shipped fix; confirmed `$go_to()` exists with the needed
   `timeout_`/`delay` parameters in the exact pinned/installed chromote version (0.5.1).
4. **Pre-RED approach decision, via its own `AskUserQuestion`:** this is a CI-environment-timing
   bug no local test can deterministically RED/GREEN (the race doesn't reliably reproduce on a
   quiet local machine); owner picked "no new test — the CI run itself is the test" over adding a
   source-inspection regression test, with the existing 2 chromote tests (already green locally,
   already red on Windows CI) serving as RED and a real pushed CI run as GREEN.
5. **RED→GREEN gate** (`AskUserQuestion`, exact diff spelled out) → implemented: replaced
   `helper-live-render-positions.R`'s `Page$navigate()`+`Page$loadEventFired()`+`Sys.sleep()`
   sequence with a single `$go_to(url, timeout_ = loadTimeout, delay = waitSeconds)` call.
   Verified locally: full clean regression 0 failed/0 error (incl. all 24 chromote tests),
   `lintr::lint()` 0 findings.
6. **GREEN→REFACTOR gate** (no-op, already 0 lints) → committed (`f75e3e42`), pushed, then polled
   `gh run view`/`gh run list` (background, via `Bash run_in_background` + `TaskOutput`) for the
   real R-CMD-check.yaml run until completion: **`windows-latest` GREEN** — confirms the fix. A
   DIFFERENT, unrelated failure appeared on `ubuntu-latest (release)`
   (`chromote:::launch_chrome()` process-launch abort, not the loadEventFired race) — diagnosed as
   NOT caused by this session's diff (`$go_to()` only touches post-connection page-load waiting,
   never process launch) and confirmed transient by re-running the SAME job unmodified
   (`gh run rerun --job`), which passed clean. **User flagged this had been seen before and asked
   for deeper diagnosis, not a dismissal** — researched it properly (rstudio/chromote issues
   #106/#124/#134/#150/#170, a well-documented port-allocation/resource-contention category) and
   found this project had ALREADY solved an analogous flake for a different workflow
   (`.github/workflows/shinytest2.yaml`'s `browser-actions/setup-chrome@v2` + `CHROMOTE_CHROME` +
   assert-resolvable pattern, from `docs/planning/phase8-e2e-harness-subplan.md` Risk R5) — a
   concrete, evidenced lead for a future session, filed as a `BACKLOG.md` item rather than folded
   into this session's own scope (owner-directed via `AskUserQuestion`, matching "1 and done").
7. **Mid-session, unrelated user question answered without touching files:** "why are `BACKLOG.md`
   items marked Done instead of moved to `CHANGELOG.md`" — investigated and answered directly
   (the file uses `- [x]` checked-but-retained items against its own stated "open items only"
   policy; a known, already-diagnosed gap per S518/S529's own Housekeeping item), no file changes
   made answering it.
8. **Mid-session, second explicit user task, executed inline:** "make a backlog item to simplify
   NEWS.Rmd entries... include guardrails... organize by feature not chronologically." Investigated
   S538's prior trim (386->134 lines, 2026-08-12) and the CURRENT state (315 lines/57 entries, 8
   days later — regrown in the same verbose/technical style with zero guardrail), pulled 3 verified
   current examples of the technical/verbose pattern, wrote a fully-scoped `BACKLOG.md` item
   capturing the owner's 3 explicit requirements (iterative-until-satisfied; by-feature not
   chronological; a designed, landed guardrail against recurrence).
9. **Close-out:** this handoff; `PROJECT_LEARNINGS.md` Learnings 643/644; 2 `BACKLOG.md` items
   filed (NEWS.Rmd simplification; the `launch_chrome()` flake) — committed separately (`935cca22`)
   from the code fix, per `SAFEGUARDS.md`'s commit-boundary discipline.

**Runtime smoke test (Phase 3E):** n/a — the only production-surface file touched is
`tests/testthat/helper-live-render-positions.R`, a test-only helper with zero call sites outside
`tests/testthat/`. No Shiny app / runtime behavior changed.

**Close-out checklist mapping** (`CLAUDE.md`): citation / tutorial-article / `NEWS.Rmd` /
`a2interactive.Rmd` / `_pkgdown.yml` checklists all **N/A** — no new exported function, no new
user-facing Shiny feature, test-infrastructure-only fix. GitHub issue close-out **N/A** — this
work isn't tied to a specific open issue (a CI-health fix incidental to issue #141's own Phase 2b,
not itself part of that issue's scope). Lint checklist **DONE** (0 lints, confirmed above).

**Self-assessment (Session 616): 8/10.** **Strengths:** (1) Diagnosed from primary evidence at
every step — downloaded and read the actual failed-run artifact rather than trusting the
annotation summary; researched the race condition via chromote's own documentation/issue tracker
rather than guessing at a fix; confirmed the exact installed/pinned chromote version had the
needed API before proposing it. (2) Correctly distinguished 2 genuinely different chromote failure
classes (a post-connect event race vs. a pre-connect process-launch failure) rather than assuming
one fix should cover both, or that a green retry meant "nothing more to see" — this distinction
came from actually reading the stack traces, not from a plausible-sounding unified story. (3) When
the user pushed back on treating the launch_chrome flake as a dismissible fluke, did real research
rather than either over-conceding scope (silently expanding this session) or under-responding
(reasserting "it's just flaky") — landed on a well-evidenced `BACKLOG.md` item citing this
project's OWN prior, analogous fix. (4) Honored the CI-environment-only nature of the bug by using
an actual push-and-observe verification loop (background polling) rather than declaring victory on
local-only evidence, which would have been faithful-verification failure mode #24 in this exact
shape. (5) Kept 2 unrelated mid-session user requests (the BACKLOG.md-Done question, the NEWS.Rmd
item) properly scoped — answered/filed without expanding this session's own TDD-gated deliverable.
**Weaknesses:** (1) **Repeated Learning 624/625/628's Phase 1B-skip pattern a 4th time** — went
straight from the priorities-picker answer into diagnostic work (downloading CI artifacts) before
writing the claim stub, exactly the failure mode 3 prior learnings already named. Recorded as
Learning 644 with a candidate mechanical fix (fold the claim into the picker's own
`AskUserQuestion`) rather than a 4th "try to remember better" restatement, since restating clearly
isn't working. (2) Did not verify the `windows-latest` fix with more than 2 CI runs — a race
condition fix confirmed clean twice is strong but not absolute evidence; a 3rd or Nth push over
time would strengthen confidence further, deliberately not pursued here to avoid over-scoping a
single-fix session into an extended confidence-building campaign. **ROI:** high — the actual
CI-red state this session inherited (S615's own final push, `R-CMD-check.yaml` red on
`windows-latest`) is now genuinely green, confirmed by real CI evidence, not just local passing
tests; 2 well-evidenced follow-on `BACKLOG.md` items were filed rather than either silently
expanding scope or losing the findings.

**Next steps:** No specific technical next step from this session's own scope (the CI fix is
complete and verified). 3 items now sit in `BACKLOG.md` a future session could pick up: (1) the
`launch_chrome()` intermittent-flake fix (READY, Effort M — port `shinytest2.yaml`'s Chrome-setup
pattern into `R-CMD-check.yaml`, verify via repeated pushes since the failure is intermittent);
(2) the NEWS.Rmd simplify-by-feature-with-guardrails item (READY, Effort L, owner-directed,
explicitly iterative/multi-round); (3) Walker/BJL Phase 3 (cutover, issue #141) — still the
largest single READY item, unchanged by this session, per S615's own `next_steps` (Commit 3-1 /
3-2 as specified there).

**Key files:** `tests/testthat/helper-live-render-positions.R:75-90` (the `$go_to()` fix, only
file with production-relevant changes); `BACKLOG.md` (2 new items, "Up Next" section, after the
pedigree-package-factoring item); `PROJECT_LEARNINGS.md` Learnings 643/644.

**Gotchas for future sessions:** (1) `$go_to()` is now this project's own established pattern for
ANY future chromote-based live-render helper — do not reintroduce the manual
`Page$navigate()`+`Page$loadEventFired()` sequence elsewhere. (2) The `launch_chrome()` flake is
real and NOT fixed — a future session should not assume "it passed on retry" means it's resolved;
`BACKLOG.md`'s own item lays out why (intermittent, needs the same Chrome-provisioning pattern
`shinytest2.yaml` already uses, needs repeated-push verification not single-run). (3) Learning
644's own candidate fix (folding the Phase 1B claim into the priorities-picker `AskUserQuestion`)
is untried — a future session proposing it should treat it as a hypothesis to test, not an
already-validated mechanism.

**Post-close-out correction (same session, disclosed rather than left silent, matching the
established S575/S603/S607 precedent):** after this record was first written, a context
interruption meant the Phase 3G report was never actually shown to the owner — the owner's next
message ("this is not a formal Phase 3 close-out report") caught it. Separately, before that: the
owner directly clarified the NEWS.Rmd `BACKLOG.md` item's "reorganize by feature" requirement —
feature-grouping applies WITHIN each release heading, never across them (release headings keep
their existing reverse-chronological order). `BACKLOG.md:740-770` edited to make that scoping
explicit; logged in `CHANGELOG.md` as its own dated entry (`8007c1c8`) rather than silently folded
into this record with no trace, matching this project's own "disclose a found-after-the-fact
correction" convention. Both corrections are additive — nothing in the original close-out content
above was inaccurate or retracted, unlike S603's precedent (a retracted fix) or S607's (a
verification gap); this is closer to S575's shape (real findings surfaced after the close-out
commit had already landed).


---

### What Session 617 Did
**Deliverable:** Sync this project's canonical-overlay methodology files to `v3.7` of
`https://github.com/KJ5HST/methodology.git`, per `BOOTSTRAP.md`'s "Updating an existing project"
procedure, then re-apply this project's own documented local customization to
`methodology_trim.py` (`CLAUDE.md`'s "methodology_trim.py local-customization checklist") and verify.
(IN PROGRESS)
**Started:** 2026-08-20
**Status:** Session claimed. Work beginning.
**Ledger:** `CHANGELOG: pending` — set at claim; this session's actions are recorded in
`CHANGELOG.md` at Phase 3F. Until close-out, this line is the crash breadcrumb for the next
session's reconcile.

### Session 616 Handoff Evaluation (by Session 617)
**Score: 8/10.** **What helped:** the handoff was structurally complete (all 6 minimum requirements
present, `HANDOFFS.md` receipt filled correctly) and its "Gotchas for future sessions" item 1
("`$go_to()` is now this project's own established pattern for ANY future chromote-based live-render
helper") is exactly the kind of durable, transferable fact a handoff should carry forward. **What was
missing:** nothing that blocked this session — S616's own task (a CI-timing fix) is unrelated to
today's methodology-sync task, which arrived as a fresh user directive rather than from S616's own
`next_steps` list, so there was little in that list this session could directly use. This is expected,
not a defect in S616's handoff: not every session's task descends from the immediately-prior one.
**What was wrong:** nothing found inaccurate. **ROI:** moderate — mainly useful for confirming the
repo was in a genuinely clean, fully-closed-out state before this session's own claim (verified
independently via `git status`/ledger-frontier checks in Phase 0, which matched what S616 reported).

### What Session 617 Did
**Deliverable:** Sync this project's canonical-overlay methodology files to `v3.7` of
`https://github.com/KJ5HST/methodology.git`. **DONE**, via hand-reconciliation rather than a blind
overlay — the user picked this explicitly (`AskUserQuestion`, "Hand-reconcile onto v3.7") after a
significant discovery changed the shape of the task. **Started/Completed:** 2026-08-20.

**What actually happened, in order:**

1. **Phase 0 orientation** (continuing from the prior turn) — read `SESSION_RUNNER.md`/`SAFEGUARDS.md`
   in full; `SESSION_NOTES.md` (S613-616's own active task, the Walker/BJL Phase 2a/2b + CI-fix
   thread); `gh issue list` (13 open); `git status`/`log`/`diff --stat` (clean, ledger frontiers both
   `== HEAD`); `gh run list` (several in-progress/pending from the last 2 pushes, nothing red);
   `methodology_dashboard.py` (96/100, 1 HIGH risk — `HANDOFFS.md` past its 2,000-line cap,
   unchanged); ghost-session check on 6 untracked files (all pre-existing, already traced by
   S614-616). Rendered the priorities list + `AskUserQuestion` — user did not pick from it; instead
   gave a fresh directive: "sync with v3.7 of https://github.com/KJ5HST/methodology.git".
2. **Investigated the sibling `/Users/rmsharp/Development/methodology` checkout** (a fork,
   `origin=rmsharp/methodology`, `upstream=KJ5HST/methodology`, both remotes present) — confirmed it
   has the real `v3.7` tag (`git describe --tags` → `v3.7`, commit `dcb6fc6`, "Merge pull request #74
   from KJ5HST/release/v3.7"). Ran `bin/status`/`bin/sync --dry-run` against it with the sibling
   checked out AT that tag (never touched the sibling's working tree destructively — restored to
   `main` immediately after extracting what was needed; later comparisons used `git show
   v3.7:<path>` directly, touching nothing in the sibling repo at all).
3. **Major discovery, before any file was touched:** `bin/status` flagged `SESSION_RUNNER.md`,
   `BOOTSTRAP.md`, `CLAUDE_TEMPLATE.md`, `methodology_dashboard.py`, and 3 `docs/methodology/` files
   as "locally modified" (not "N versions behind") against true `v3.7`. Full diffs revealed why:
   this project's `FRAMEWORK_LEARNINGS.md` and `methodology_trim.py` — both actively, heavily used
   (the latter for CHANGELOG/HANDOFFS/SESSION_NOTES archiving; the former never actually true
   canonical) — **have never existed in any tagged `KJ5HST/methodology` release, v1.0.0 through
   v3.7** (checked all 27 tags directly). They reached this project via the 2026-08-10 sync
   (`18d8e3c7`), whose own commit message honestly names its actual source as
   `KJ5HST/methodology v3.6-255-gc43e7ee` — the `rmsharp/methodology` fork's unreleased `main`
   branch, 255 commits past the v3.6 *tag*, not an official release. Also found:
   `methodology_dashboard.py` locally is 2.14.0, genuinely NEWER than true v3.7's 2.10.6 — a literal
   sync would have been a downgrade. Conversely, true v3.7's `SESSION_RUNNER.md` has a real addition
   this project was missing: **Failure Mode #28 "Unbounded mandatory read"** + 4 Degradation
   Detection rows. Recorded as `PROJECT_LEARNINGS.md` Learning 645.
4. **Surfaced this to the user via `AskUserQuestion`** before touching any file — 3 options
   (hand-reconcile / literal overlay / sync from the fork's main instead). **User picked
   hand-reconcile.**
5. **Executed the reconciliation**, file by file, verifying each against the actual `v3.7` tag
   content (`git show v3.7:<path>`, never the sibling's live working tree after the first checkout):
   - `SESSION_RUNNER.md`: added FM #28 + its 4 Degradation Detection rows (genuine new v3.7 content);
     kept the local `FRAMEWORK_LEARNINGS.md`-extraction pattern for the 2 Learning-routing bullets and
     the "Learnings (added by sessions)" section (local's `FRAMEWORK_LEARNINGS.md` already holds 21
     rows vs. v3.7's inline 13 — reverting would have been a real regression, confirmed by reading
     the file directly, not assumed).
   - `RECOMMENDED_SKILLS.md`: applied v3.7's improved `/caveman` skill description verbatim (a genuine
     content upgrade, unrelated to the `FRAMEWORK_LEARNINGS.md` question) — now matches v3.7 exactly.
   - `CLAUDE_TEMPLATE.md`, `ITERATIVE_METHODOLOGY.md`, `HOW_TO_USE.md`,
     `docs/methodology/workstreams/AUDIT_WORKSTREAM.md`: confirmed each's only diff is the
     `FRAMEWORK_LEARNINGS.md` citation-target (both sides self-consistent with their own pattern) —
     no change needed.
   - `BOOTSTRAP.md`: confirmed local is a strict superset of v3.7 (includes the FRAMEWORK_LEARNINGS.md/
     `methodology_trim.py` mentions AND an entire "3 rules for a `bin/sync`-less update" section v3.7
     doesn't have at all) — no change needed.
   - `methodology_dashboard.py`: kept at local 2.14.0 per the user's explicit choice (no downgrade).
   - `SAFEGUARDS.md`, `CONTEXT_TEMPLATE.md`, and 8 `docs/methodology/workstreams/*` files: already
     confirmed byte-identical to v3.7 — no action.
   - `FRAMEWORK_LEARNINGS.md`, `methodology_trim.py`: left untouched by design (not part of v3.7's
     manifest at all; `bin/sync` would neither update nor delete them).
6. **Corrected `CLAUDE.md`'s now-confirmed-inaccurate claim** that `methodology_trim.py` is "a
   canonical-overlay file per `BOOTSTRAP.md`'s sync table" — rewrote the local-customization checklist
   entry to state the actual provenance and narrow the residual risk to its real trigger (a future
   sync against the fork's *unreleased* `main`, not a tagged release, which is what S617 ran).
7. **Verified cross-references** (this project's own Learning #7 discipline, now literally cited
   inside the SESSION_RUNNER.md text just edited): grepped for stale "27 failure modes" claims after
   adding FM #28 — found and fixed one in `CLAUDE.md`'s Project-Specific Failure Modes section; found
   one more (`docs/methodology/README.md`) that is dated historical changelog prose describing a past
   release, correctly left untouched. Also refreshed `CLAUDE.md`'s stale `PROJECT_LEARNINGS.md`
   pointer count (635→645 learnings, ~3.5MB→~2.6MB actual) while already editing the surrounding text.
8. **Filed a `BACKLOG.md` Housekeeping item** for `context_budget.py` (a genuinely new v3.7 tool,
   `bin/status` reports `missing`/`absent`) — deliberately NOT adopted this session (a new capability
   is a bigger decision than syncing an existing file), flagged for a future scoping session.
9. **Verified nothing broke:** `methodology_trim.py --check` still runs cleanly on all 3 ledgers
   (CHANGELOG.md/HANDOFFS.md/SESSION_NOTES.md — pre-existing trigger-fires unrelated to this session,
   matching the dashboard's already-known HIGH risk flag); `methodology_dashboard.py` still runs,
   health unchanged at 96/100.
10. **Close-out:** this handoff; `PROJECT_LEARNINGS.md` Learning 645 recorded (step 3 above).

**Runtime smoke test (Phase 3E):** n/a — docs/tooling-only sync, zero `.R` files touched, no Shiny
app or package runtime behavior affected. Confirmed via `git status --porcelain` (only `.md` files +
`RECOMMENDED_SKILLS.md`/`CLAUDE.md`/`PROJECT_LEARNINGS.md`/`BACKLOG.md` changed).

**Close-out checklist mapping** (`CLAUDE.md`): citation / tutorial-article / `NEWS.Rmd` /
`a2interactive.Rmd` / `_pkgdown.yml` checklists all **N/A** — no R code, no exported function, no
Shiny feature. GitHub issue close-out **N/A** — not tied to a GitHub issue. Lint checklist **N/A** —
no `.R` files touched.

**Self-assessment (Session 617): 9/10.** **Strengths:** (1) Did not blindly trust "sync to v3.7" as a
mechanical file-overlay — checked out the actual tag and diffed against it before touching anything,
which is what surfaced the fork-vs-upstream provenance gap in the first place. (2) When the discovery
changed the shape of the task, stopped and asked via `AskUserQuestion` rather than either silently
downgrading working tools (`methodology_dashboard.py`, the `FRAMEWORK_LEARNINGS.md` pattern) or
silently deviating from the literal instruction by syncing from the fork instead. (3) Verified every
"locally modified" file's diff line-by-line against actual `v3.7` tag content (via `git show`, never
trusting the sibling repo's mutable working tree after the first checkout) rather than accepting
`bin/status`'s summary label at face value — this is what caught that `RECOMMENDED_SKILLS.md`'s "1
version behind" WAS a safe, genuine upgrade while the 7 "locally modified" files were not. (4) Applied
this project's own Learning #7 (cross-reference completeness) to the very edit that introduced it —
grepped for stale failure-mode-count claims after adding FM #28 and fixed the one live instance found.
(5) Recorded the provenance-gap discovery as a `PROJECT_LEARNINGS.md` learning with a concrete,
transferable practical rule, not just fixed-and-moved-on. **Weaknesses:** (1) Did not re-verify the
sibling repo's clean/restored state with a final `git status` after the last `git show`-based
extraction pass (though no further checkouts happened after the one restore, so risk was low — worth
a habit going forward: confirm the sibling repo is exactly as found before ending any session that
touches it). (2) The Phase 1B claim (S617's own stub) happened after the Phase 0
orientation-continuation and BEFORE any technical investigation began, which is correct per Learning
624/625/628/644's own repeated finding — but this session's investigation (checking out tags, running
`bin/status`) happened AFTER the claim, so this session did NOT repeat that specific failure mode;
noting explicitly since it's now a recorded pattern worth confirming session over session. **ROI:**
high — this session avoided 2 real regressions (a `methodology_dashboard.py` downgrade, a
`FRAMEWORK_LEARNINGS.md`-pattern content loss with no replacement) that a literal, un-investigated
"just run `bin/sync`" would have caused, adopted one genuine new capability (FM #28) the project was
missing, and corrected a standing factual error in `CLAUDE.md` about this project's own tooling
provenance.

**Next steps:** No further methodology-sync work is owed from this session's own scope — the
reconciliation is complete and verified. One item is now in `BACKLOG.md` Housekeeping a future session
could pick up: evaluate adopting `context_budget.py` (v3.7's new context/token-budget tracker,
READY, Effort S — a scoping session). Separately, this session's investigation makes 2 broader,
optional future considerations visible (not filed as BACKLOG items, since neither is a concrete,
scoped task yet): (a) whether `FRAMEWORK_LEARNINGS.md`/`methodology_trim.py` should be formally
re-framed as fully project-owned tools (drop the "sync" framing entirely, since no tagged release will
ever update them) or whether this project wants to periodically pull fresh copies from the fork's
`main` on purpose; (b) whether future methodology syncs should default to checking out a specific tag
in the sibling checkout (as this session did) rather than trusting whatever branch happens to be
checked out there, given `bin/sync --source=local`'s documented behavior of reading the working tree
as-is.

**Key files:** `SESSION_RUNNER.md:220-222,278,329-330,356-360,365-382` (the FM #28 addition + the
preserved `FRAMEWORK_LEARNINGS.md` pattern); `CLAUDE.md:272` (the corrected `methodology_trim.py`
provenance note), `CLAUDE.md:282,286` (refreshed cross-reference counts);
`RECOMMENDED_SKILLS.md:94` (the `/caveman` description upgrade); `BACKLOG.md` Housekeeping (the new
`context_budget.py` item, inserted first); `PROJECT_LEARNINGS.md` Learning 645 (the full
provenance-gap finding and practical rule).

**Gotchas for future sessions:** (1) A future "sync methodology" session should check out the specific
target tag in the sibling `/Users/rmsharp/Development/methodology` checkout (verify clean first,
restore the branch after) rather than trusting whatever is currently checked out there — `bin/sync
--source=local` has no concept of "the latest release," it reads the working tree as-is. (2)
`FRAMEWORK_LEARNINGS.md` and `methodology_trim.py` will NOT be touched by any future tagged-release
sync (they're absent from `bin/_manifest.py`'s `DISTRIBUTION` for every tag checked) — do not expect
`bin/status`/`bin/sync` to ever report them as anything but `missing`/absent-from-manifest when
compared against a tag; this is expected, not a bug. (3) `methodology_dashboard.py` was deliberately
left at 2.14.0 (ahead of true v3.7's 2.10.6) — if a future session syncs again and sees this flagged
"locally modified," that's the same intentional preservation, not new drift, unless the fork's version
has since fallen behind what's needed.

---

### Session 617 Handoff Evaluation (by Session 618)
**Score: 8/10.** **What helped:** the receipt was structurally complete (all 6 minimum
requirements present, `HANDOFFS.md` block filled correctly, `status: complete`) and every claim
it made — clean repo, both ledger frontiers `== HEAD`, dashboard 96/100 — was independently
re-verified as accurate in this session's own Phase 0 (`git log -1 -- CHANGELOG.md`/`HANDOFFS.md`,
a fresh `methodology_dashboard.py` run). The `gotchas` list (FRAMEWORK_LEARNINGS.md/
methodology_trim.py permanently absent from tagged-sync manifests; methodology_dashboard.py
deliberately ahead of v3.7) is durable, correct information a future methodology-sync session will
need. **What was missing:** nothing that blocked this session — S617's own task (a methodology
framework sync) is unrelated to this session's task (a CI-config fix), which arrived from the
priorities-list picker rather than from S617's own `next_steps`, so there was little in that list
this session could directly use. This mirrors S617's own evaluation of S616 exactly ("not every
session's task descends from the immediately-prior one") — expected, not a defect. **What was
wrong:** nothing found inaccurate. **ROI:** moderate — mainly useful for confirming the repo was
genuinely clean and fully closed out before this session's own claim, matching S617's own
precedent for scoring a handoff whose task didn't chain into the next session's.

### What Session 618 Did
**Deliverable:** Fix `R-CMD-check.yaml`'s intermittent chromote Chrome-launch failure (BACKLOG.md
Housekeeping item, found S616) — port `shinytest2.yaml`'s `browser-actions/setup-chrome@v2` +
`CHROMOTE_CHROME` + preflight-resolvability pattern into `R-CMD-check.yaml`, then verify via
repeated real CI pushes. **PARTIALLY DONE, disclosed:** `windows-latest` genuinely fixed and
verified GREEN on a real push; `macos-latest` reclassified as a distinct, still-open problem,
deferred to a future session per owner direction. **Started/Completed:** 2026-08-20.

**What actually happened, in order:**

1. **Phase 0 orientation** — read `SAFEGUARDS.md` in full; `SESSION_NOTES.md` (S613–617's full
   thread, ~590 lines); `gh issue list` (13 open); `git status`/`log --oneline -5`/`diff --stat`
   (clean, 4 unpushed S617 commits); `methodology_dashboard.py` (96/100, 1 project HIGH — but the
   underlying risk-flag detail, read directly from `dashboard.html`, showed 3 files now past the
   2,000-line cap: `HANDOFFS.md` 2,529, and **`BACKLOG.md` 2,097 / `CHANGELOG.md` 2,039, both
   newly crossed** since S617 — a timely instance of the FM #28 "unbounded mandatory read" S617
   itself had just adopted into `SESSION_RUNNER.md`, flagged in the report, not fixed). `gh run
   list --branch master` (S545-ratified CI-status-check step) found `R-CMD-check.yaml` RED on
   `windows-latest` — "Chrome debugging port not open after 10 seconds" — matching the already-
   filed BACKLOG item almost exactly, plus new evidence it now also hits `windows-latest`, not
   just `ubuntu-latest`. Ledger reconcile: 1 commit past the `CHANGELOG.md` frontier
   (`d0d248b8`), matched the established S600/S602–S616 self-reference-workaround precedent
   (a receipt-only edit, nothing new to log) — no backfill needed; `HANDOFFS.md` frontier
   `== HEAD`. Ghost-session check on the same 6 untracked files prior sessions already traced —
   unchanged. Rendered the 4-item priorities list + `AskUserQuestion` — **user picked the
   chromote CI-flake fix.**
2. **Phase 1B claimed immediately** — `SESSION_NOTES.md` stub + `HANDOFFS.md` `status: pending`
   receipt, committed (`1d1d9203`), before any technical investigation — avoided a 5th
   recurrence of the Learning 624/625/628/644 pattern.
3. **PRE-RED research** — read `docs/methodology/workstreams/DEVELOPMENT_WORKSTREAM.md`,
   `shinytest2.yaml`'s full Chrome-provisioning block, `R-CMD-check.yaml`'s current state.
   `WebFetch`/`WebSearch` confirmed `browser-actions/setup-chrome@v2` supports macOS/Windows/
   Linux and that `install-dependencies` is documented Linux-only (a no-op elsewhere, matching
   `no-sudo`'s own explicit annotation) — verified against the action's own `action.yml`, not
   assumed. **PRE-RED→RED gate** (`AskUserQuestion`): chose a static structural test (parsing
   the raw workflow YAML, `test_shinytest2_workflow_coverage.R`'s own house style) over "CI-run-
   only, no new test" (S616's precedent for a pure runtime race) — this is a parseable config
   change, not a runtime race, so a deterministic local RED/GREEN cycle is possible and was
   judged more rigorous.
4. **RED** — wrote `tests/testthat/test_r_cmd_check_workflow_chrome_setup.R` (3 `test_that`
   blocks, 8 expectations): asserts `browser-actions/setup-chrome@v2` + `id: setup-chrome` +
   `install-dependencies: true`; `CHROMOTE_CHROME` exported from `chrome-path` via
   `$GITHUB_ENV`; `chromote::find_chrome()` asserted, in the correct order ahead of
   `check-r-package@v2`. Confirmed genuine RED: 8/8 fail (steps don't exist yet), full clean
   regression 8 failed/0 error project-wide, all 8 in the new file. Committed (`888fcbf4`).
5. **RED→GREEN gate** (`AskUserQuestion`, exact diff spelled out) → implemented: ported the
   3-step pattern into `R-CMD-check.yaml` between `setup-r-dependencies@v2` and
   `check-r-package@v2`. 8/8 GREEN, full regression 0 failed/0 error, `lintr::lint_package()` 0
   lints. Committed (`58905242`).
6. **GREEN→REFACTOR gate** (`AskUserQuestion`) → confirmatory no-op (0 lints, minimal diff); ran
   `devtools::check()` as extra verification — 0 errors/1 WARNING/2 NOTEs, all 3 confirmed
   pre-existing (matching S614–S617's own exact baseline). Pushed to trigger real CI.
7. **1st real CI run (`32403201121`) found the GREEN implementation had a genuine bug, NOT
   intermittency:** `windows-latest` still failed with the EXACT SAME "port not open" symptom.
   Direct log inspection (`gh run view --log`, not just `--log-failed`) found `CHROMOTE_CHROME =`
   printed EMPTY — the `echo ... >> "$GITHUB_ENV"` step is bash syntax, and unlike
   `shinytest2.yaml` (ubuntu-only, bash is the OS default), this job's matrix includes
   `windows-latest`, whose `run:` default shell is PowerShell. `chromote::find_chrome()` had
   silently fallen back to the ambient system Chrome. **Same run also showed a NEW,
   previously-green leg failing: `macos-latest`**, with `CHROMOTE_CHROME` confirmed correctly
   set (ruling out the same shell bug) but `Chromote: timed out waiting for response to command
   Runtime.evaluate` plus an internal `attempt to apply non-function` — a live CDP timeout, not a
   launch failure, a genuinely different symptom class. **Stopped and reported both findings to
   the owner via `AskUserQuestion` rather than silently pushing another speculative fix** — owner
   clarified: fix the diagnosed Windows bug and re-push; treat macOS as intermittent for now,
   escalate to its own future session if it recurs.
8. **Fixed the diagnosed bug within GREEN** (matching this project's own "found/fixed via
   execution during GREEN" precedent, S614/S615): extended the RED test with a `step_block_
   containing()` helper asserting the CHROMOTE_CHROME-exporting step declares `shell: bash` —
   confirmed genuine RED (1/9 new expectation fails) — then added `shell: bash` to the step —
   9/9 GREEN, full regression 0 failed/0 error, 0 lints. Committed (`a3d34f1a`), pushed.
9. **2nd real CI run (`32406103954`): `windows-latest` GREEN**, `CHROMOTE_CHROME` confirmed
   correctly populated. **`macos-latest` failed AGAIN with the identical CDP-timeout signature**
   — 2/2 recurrence with `CHROMOTE_CHROME` confirmed correctly set both times, ruling out both
   the shell bug and pure one-off resource contention as the sole explanation; the same run also
   showed `ubuntu-latest (oldrel-1)` red, characterized via its own log as an entirely unrelated
   r-hub.io R-version-resolution API failure (before any Chrome-provisioning step runs, this leg
   was green on the 1st push with the same code) — confirmed transient by re-running the single
   job (`gh run rerun --job 96545448701`), passed clean.
10. **Close-out:** `BACKLOG.md`'s chromote-flake item updated in place with the full S618
    narrative (windows-latest FIXED/verified; macos-latest reclassified as a distinct, still-open
    problem, deferred; ubuntu-oldrel-1 noted as unrelated transient noise) rather than checked
    off, since the item's own original scope (both platforms) is only half-resolved.
    `PROJECT_LEARNINGS.md` Learnings 646/647 recorded; `CLAUDE.md`'s learning-count cross-
    reference refreshed (645→647). This handoff written.

**Runtime smoke test (Phase 3E):** the deliverable changes CI runtime behavior directly — verified
via 2 real, pushed `R-CMD-check.yaml` runs (not local-only), exactly the faithful verification this
kind of change needs (matching S616's own "push-and-observe" precedent). `windows-latest`
confirmed GREEN on live infrastructure with `CHROMOTE_CHROME` populated correctly; `macos-latest`
confirmed still RED on live infrastructure, disclosed, not silently treated as passing.

**Close-out checklist mapping** (`CLAUDE.md`): citation / tutorial-article / `NEWS.Rmd` /
`a2interactive.Rmd` / `_pkgdown.yml` checklists all **N/A** — no new exported R function, no new
user-facing Shiny feature, CI-workflow-config-only. GitHub issue close-out **N/A** — this work
isn't tied to a specific open issue. Lint checklist **DONE** (0 lints on both touched `.R` files,
confirmed 3 times across RED/GREEN/the shell-bash fix).

**Self-assessment (Session 618): 8/10.** **Strengths:** (1) Followed the full TDD PRE-RED→RED→
GREEN→REFACTOR cycle with an `AskUserQuestion` gate at every transition, including the atypical
"is a local RED/GREEN cycle even possible for a CI-config change" pre-RED decision — reasoned
explicitly rather than defaulting to S616's runtime-race precedent without checking whether it
actually applied here. (2) Verified via REAL CI pushes, not just local tests, exactly per the
BACKLOG item's own "repeated real pushes, not a single run" requirement — this is what caught a
genuine implementation bug (Windows shell portability) no local machine (bash-default) could ever
have surfaced. (3) When the 1st real push contradicted the fix hypothesis (macOS regression,
Windows unchanged), stopped and reported both findings via `AskUserQuestion` rather than either
silently declaring partial victory or unilaterally chasing more speculative fixes — matching this
project's own established "stop and ask" precedent (S616). (4) Correctly distinguished 3 different
failure signatures across 2 CI runs (Windows shell bug; macOS CDP timeout; unrelated ubuntu
r-hub.io infra flake) by reading actual step logs and env values, not by assuming a shared cause —
avoided both over-fixing and mis-attributing. (5) Found and fixed a bug in my OWN test (a comment
line falsely matching `chromote::find_chrome()`) via direct execution, then extended the RED
coverage to lock in the shell:bash requirement rather than patching the YAML and moving on. (6)
Claimed the session at the literal next step after the picker resolved, avoiding a 5th recurrence
of Learning 624/625/628/644's documented pattern. **Weaknesses:** (1) Did not research GitHub
Actions' own per-OS default-shell behavior before writing the first GREEN diff — a `shinytest2.yaml`-
verbatim port assumed bash without checking whether the destination matrix's OS composition
(mixed, unlike the ubuntu-only source) made that assumption unsafe; a live CI failure was needed to
surface it, when a documentation check likely would have caught it first. (2) The macOS
CDP-timeout regression remains genuinely unresolved at close-out — disclosed in full, with 2
data points and exact signatures, not silently dropped, but the underlying "is the pin itself
implicated" question is still open. (3) 2 full CI-verification round-trips (≈35 CI-minutes each
across 5 matrix legs) were needed rather than 1, extending the session's real-world duration —
inherent to "verify via real CI," not obviously avoidable, but worth naming. **ROI:** high — a
genuinely broken CI leg (`windows-latest`, red across the 2 pushes immediately preceding this
session) is now green and independently re-verified twice; a previously vague "intermittent
Chrome-launch failure" is now split into 3 precisely characterized, evidence-backed problems
(1 fixed, 1 newly-scoped for a future session, 1 confirmed unrelated noise) — a materially
better-scoped starting point than this session's own.

**Next steps:** A future session should investigate the `macos-latest` CDP-timeout regression as
its own dedicated task (`BACKLOG.md`'s chromote item narrates the full finding) — research the
`Chromote: timed out waiting for response to command Runtime.evaluate` / `attempt to apply
non-function` signature against chromote's own issue tracker, determine whether the pinned
152.0.7977.54 Chrome-for-Testing build has known headless-CDP problems on macOS ARM64, and decide
whether pinning is even the right fix for that leg (vs. leaving macOS on ambient Chrome, which was
green before this session's diff) before attempting another fix. **Must explicitly measure, not
assume:** whether a 3rd real CI push reproduces the same signature a 3rd time (strengthening the
"real, recurring" conclusion) or clears (weakening it back toward "coincidental double flake") —
this session stopped at 2 data points per owner direction, not because 2 was judged sufficient.

**Key files:** `.github/workflows/R-CMD-check.yaml:48-75` (the 3-step Chrome-provisioning block +
the `shell: bash` fix); `tests/testthat/test_r_cmd_check_workflow_chrome_setup.R` (3 `test_that`
blocks, 9 expectations, incl. the `step_block_containing()`/`drop_comment_lines()` helpers);
`BACKLOG.md` Housekeeping (the chromote-flake item, updated in place with the full S618
narrative — NOT checked off, since macOS remains open); `PROJECT_LEARNINGS.md` Learnings 646/647.

**Gotchas for a future session:** (1) `shell: bash` is now this project's own established
requirement for ANY `run:` step using bash syntax inside a workflow whose matrix includes
`windows-latest` — do not assume a step ported from an ubuntu-only workflow carries its shell
default along. (2) The macOS CDP timeout reproduced with `CHROMOTE_CHROME` CONFIRMED correctly
set both times — do not re-diagnose it as "the pin isn't working," that specific hypothesis is
already ruled out; the open question is why a live CDP round-trip times out on an
already-connected, correctly-pinned session. (3) `ubuntu-latest (oldrel-1)`'s r-hub.io
version-resolution failure is unrelated CI infra noise, already confirmed transient by a clean
rerun — do not fold it into the chromote-flake investigation if it recurs; it is a different
category entirely (R-version resolution, not Chrome).

### Session 618 Handoff Evaluation (by Session 619)
**Score: 9/10.** **What helped:** `next_steps` named 3 exact, actionable directives — "research
the signature against chromote's own issue tracker," "check whether the pinned 152.0.7977.54
Chrome-for-Testing build has known headless-CDP problems on macOS ARM64," and "decide whether
pinning is even the right fix for that leg (vs. leaving macOS on ambient Chrome, which was green
before this session's diff) before attempting another fix" — all 3 were followed almost verbatim:
a 6-agent research workflow did exactly that research, and the eventual fix WAS "leave macOS on
ambient Chrome," precisely the alternative S618 had already named as a live option rather than
something this session had to discover from scratch. `key_files`
(`.github/workflows/R-CMD-check.yaml:48-75`, `test_r_cmd_check_workflow_chrome_setup.R`) pointed
exactly at the files this session edited. `gotchas` #2 ("`CHROMOTE_CHROME` CONFIRMED correctly set
both times — do not re-diagnose it as 'the pin isn't working'") held up exactly: this session's own
H1 fix attempt independently re-confirmed the env var was correctly set even while genuinely
failing, matching the gotcha precisely rather than re-litigating it. **What was missing:** nothing
critical — S618 could not have known the eventual root-cause mechanism (chromote's internal
`get_pixel_ratio()` bootstrap probe) without the same source-level research this session did; that
gap is appropriately S618's own deferral, not an omission. **What was wrong:** nothing found
inaccurate — every claim (distinct from the Windows shell bug, recurring 2/2, `CHROMOTE_CHROME`
correctly set) was independently re-verified and held. **ROI:** very high — the `next_steps` text
functioned almost as a mini research brief, directly shaping this session's own investigation
structure.

### What Session 619 Did
**Deliverable:** Diagnose AND fix the `macos-latest` CDP-timeout CI failure in `R-CMD-check.yaml`
(`BACKLOG.md` Housekeeping item, found S618). **DONE** — root cause identified via direct chromote
source inspection; a first fix attempt (raise `default_timeout`) was tried, verified via real CI,
and found NOT to work (a genuine falsification, not a formality); a fallback fix (revert
`macos-latest` to ambient Chrome) was then implemented and verified GREEN on real CI, resolving the
CI-config half of this item completely — all 5 `R-CMD-check.yaml` matrix legs are now green.
**Started/Completed:** 2026-08-20 (single session).

**What actually happened, in order:**

1. **Phase 0 orientation** — read `SAFEGUARDS.md` in full; `SESSION_NOTES.md` (S613–618's full
   thread); `gh issue list` (13 open); `git status`/`log`/`diff --stat` (clean, S618 fully closed
   out, both ledger frontiers `== HEAD`). `gh run list --branch master` (S545-ratified CI-status
   check) found the MOST RECENT push (S618's own docs-only close-out commit) still showed
   `R-CMD-check.yaml` red on `macos-latest`, with the identical `Runtime.evaluate` signature — a
   3rd data point, on a docs-only commit, ruling out any code-diff cause. `methodology_dashboard.py`
   (96/100, 1 HIGH risk, unchanged — the same 3 files past the 2,000-line cap, report-don't-fix).
   Ledger reconcile: no gap (both frontiers `== HEAD`). Ghost-session check on the same 6 untracked
   files prior sessions already traced — unchanged. Rendered the priorities list + `AskUserQuestion`
   — **user picked the macOS CDP-timeout investigation.**
2. **Phase 1B claimed at the literal next step** — `SESSION_NOTES.md` stub + `HANDOFFS.md`
   `status: pending` receipt, committed (`40c2e96b`), before any technical investigation — avoided
   a 5th recurrence of the Learning 624/625/628/644 pattern.
3. **Mid-session, unrelated user question:** owner noticed 16 `[x]`-checked DONE items still in
   `BACKLOG.md`. Investigated (not assumed): confirmed each already has a dated `CHANGELOG.md`
   entry (nothing at risk of loss) and that this matches an established periodic-batch-sweep
   precedent (S548, 2026-08-13), not a new process break. Filed a new Housekeeping item per owner
   direction to keep the current task uninterrupted rather than switching scope mid-session
   (`ff091613`).
4. **Diagnosis via a 6-agent research workflow** (`diagnose` skill's Phase 1–3): 5 parallel research
   angles (chromote's own source, chromote's issue tracker, GitHub Actions macOS-runner
   resource-constraint evidence, Gatekeeper/quarantine mechanics, a fresh trace of this project's
   own CI logs) + 1 synthesis pass. Found the exact mechanism via direct source inspection (not
   assumed): `ChromoteSession$new()` unconditionally issues an internal `Runtime.evaluate` command
   during its own bootstrap (`private$get_pixel_ratio()`, chromote 0.5.1) to read
   `window.devicePixelRatio`, governed by a 10s `default_timeout` field with no constructor
   argument to raise it. Ranked 5 falsifiable hypotheses; H1 (cold-launch timing exhaustion) was
   top-ranked and best-evidenced.
5. **H1 fix, full TDD cycle** (PRE-RED→RED→GREEN→REFACTOR, `AskUserQuestion`-gated at every
   transition): raised `chromote::default_chromote_object()$default_timeout` to 60s in
   `helper-live-render-positions.R`, guarded by a new structural RED test
   (`test_helper_live_render_positions_timeout.R`, 3 `test_that` blocks / 6 expectations).
   Confirmed genuine RED (6/6 fail), GREEN (6/6 pass, full clean regression 0 failed/0 error, 0
   lints), `devtools::check()` (0 errors, 1 pre-existing WARNING, 2 pre-existing NOTEs, all
   confirmed unrelated to this diff). Committed (`1553099a` RED, `1780789d` GREEN), pushed.
6. **Real CI verification found H1 FALSIFIED, not confirmed:** run `32417985922`'s `macos-latest`
   leg failed again after 13m34s — identical signature, identical 3 tests, wall time roughly
   doubled (454s→865s, consistent with the full 60s actually being exhausted 3 times). Reported
   this negative result to the user immediately via `AskUserQuestion` rather than silently trying
   another guess (matching S616/S618's own "stop and ask" precedent) — recorded as
   `PROJECT_LEARNINGS.md` Learning 648.
7. **Fallback fix, full TDD cycle** (PRE-RED→RED→GREEN→REFACTOR, gated): added
   `if: ${{ matrix.config.os != 'macos-latest' }}` to the 3 Chrome-provisioning steps in
   `R-CMD-check.yaml`, reverting that one leg to ambient Chrome (S616's own proven-green
   precedent), guarded by 3 new assertions extending
   `test_r_cmd_check_workflow_chrome_setup.R`. Confirmed genuine RED (3/3 fail), GREEN (12/12
   pass — 9 pre-existing + 3 new — full clean regression 0 failed/0 error, 0 lints). Committed
   (`4a134701` RED, `d2e9f487` GREEN), pushed.
8. **Real CI verification: ALL 5 matrix legs GREEN**, run `32423688930` — `macos-latest` completed
   in 10m4s (faster than any prior run on this leg since chromote tests joined `R CMD check`'s
   surface), with the 3 Chrome-provisioning steps cleanly skipped (`-`) and `check-r-package@v2`
   passing. `ubuntu-latest`/`windows-latest` unaffected, pin intact. Recorded as
   `PROJECT_LEARNINGS.md` Learning 649.
9. **Close-out:** `BACKLOG.md`'s chromote item removed outright (Phase 3F's literal instruction —
   fully resolved, full history already in `CHANGELOG.md` across S616/S618/S619 entries; a
   deliberate choice not to perpetuate the exact `[x]`-left-in-place pattern flagged mid-session
   in step 3) plus a new, explicitly optional/low-priority Housekeeping item for the still-
   unexplained *why* (the pinned binary's hang mechanism itself, distinct from the now-fully-
   resolved practical CI failure). `PROJECT_LEARNINGS.md` Learnings 648/649 recorded; `CLAUDE.md`'s
   learning-count cross-reference refreshed (647→649). This handoff written.

**Runtime smoke test (Phase 3E):** the deliverable changes CI runtime behavior directly — verified
via 2 real, pushed `R-CMD-check.yaml` runs (not local-only): the H1 attempt confirmed FAILING on
live infrastructure (disclosed, not hidden), the fallback confirmed GREEN on all 5 matrix legs on
live infrastructure. This is the faithful verification this kind of change needs, matching
S616/S618's own "push-and-observe" precedent.

**Close-out checklist mapping** (`CLAUDE.md`): citation / tutorial-article / `NEWS.Rmd` /
`a2interactive.Rmd` / `_pkgdown.yml` checklists all **N/A** — no new exported R function, no new
user-facing Shiny feature, CI-workflow/test-helper-config-only. GitHub issue close-out **N/A** —
this work isn't tied to a specific open issue (matching S618's own precedent). Lint checklist
**DONE** (0 lints on all 3 touched files, confirmed at each GREEN phase).

**Self-assessment (Session 619): 9/10.** **Strengths:** (1) Used a 6-agent research workflow for
the diagnosis phase rather than guessing — direct source inspection of chromote's actual GitHub
code (not just its documented API) found the exact internal mechanism, which no amount of log-
reading alone would have surfaced. (2) Followed the full TDD PRE-RED→RED→GREEN→REFACTOR cycle,
`AskUserQuestion`-gated at every transition, for BOTH the H1 attempt and the fallback — two
complete, independently-verified cycles within one deliverable, not one cycle skipped for
expediency. (3) When H1 failed on real CI, reported the negative result honestly and immediately,
treating the falsification itself as diagnostic evidence (distinguishing "genuinely wedged" from
"needs more time") rather than silently trying a second guess — matching this project's own
"stop and ask" precedent and turning a failed attempt into a documented, transferable learning
(648) rather than a discarded dead end. (4) Verified via REAL CI pushes both times, not local
tests alone — the only faithful verification for a CI-runner-specific timing/environment bug. (5)
Handled the mid-session unrelated user question (stale BACKLOG.md `[x]` items) by investigating
before answering (confirmed nothing was at risk, confirmed it matched existing precedent) rather
than assuming either "this is broken" or "this is fine," and avoided scope creep by filing rather
than fixing mid-task, per the user's own explicit choice. (6) At close-out, removed the now-fully-
resolved chromote BACKLOG item outright (Phase 3F's literal text) rather than leaving it
`[x]`-checked — a small but deliberate act of not perpetuating the exact debt pattern surfaced
mid-session. **Weaknesses:** (1) Two early process missteps, both self-corrected but real
overhead: attempted `ScheduleWakeup` (a `/loop`-specific tool) to wait on a background task
outside a loop context, and spawned a redundant monitoring `Agent` for a background Bash task
that already had its own completion notification — neither caused harm, both wasted a small
amount of turns/tokens. (2) The H1 fix attempt, while the top-ranked hypothesis from a genuinely
thorough research pass, still cost a full ~14-minute real-CI round-trip that did not resolve the
issue — the fallback's own supporting evidence (S616's directly-proven-green run on ambient
Chrome, same leg) was arguably at least as strong as H1's evidence going in, and a more skeptical
prioritization might have tried the lower-risk fallback first or in parallel rather than
sequentially. (3) The research workflow itself was a substantial token investment (~500k
subagent tokens, 6 agents, ~12 minutes) for a diagnosis whose actionable outcome (the fallback)
did not strictly require ALL 5 research angles — though the mechanism-level finding (the exact
internal `Runtime.evaluate` call site) is now durably documented and may save a future session
real time if pinned-Chrome parity on macOS is ever revisited. **ROI:** very high — a CI failure
that had recurred on every real push since S618 (4 consecutive red `macos-latest` runs across 2
sessions) is now fully green, with a well-evidenced, documented root-cause explanation on record
rather than a blind patch, and the exact falsification data point (raising the timeout does NOT
help) is preserved so no future session re-attempts the same speculative fix.

**Next steps:** No forced next step — the practical problem (macOS CI failing) is FULLY resolved.
Optional, explicitly low-priority: a future session could investigate WHY the pinned
Chrome-for-Testing binary hangs on `macos-latest`'s `ChromoteSession$new()` bootstrap specifically
(`BACKLOG.md` Housekeeping's new optional item) — only worth doing if pinned-Chrome reproducibility
on macOS becomes valuable later; the research workflow's own findings (an unconfirmed-for-Chromium
Firefox/Mozilla sandbox-stall analog; Gatekeeper/quarantine evidenced as NOT applicable to
`browser-actions/setup-chrome`'s actual pipeline) are a starting point, not a solved problem.
Otherwise, pick up any other `BACKLOG.md` item per the normal Phase 0 priorities-list process
(Walker/BJL Phase 2b, NEWS.Rmd simplification, and the pedigree-package-split scoping session were
the other 3 items on this session's own priorities list, still open).

**Key files:** `.github/workflows/R-CMD-check.yaml:48-89` (the 3-step Chrome-provisioning block +
the new `if:` guards); `tests/testthat/helper-live-render-positions.R:75-96` (the `default_timeout`
raise, H1's own code — kept even though H1 alone didn't resolve macOS, since it's harmless, correct
hygiene, and still matters for the legs that keep the pin); `tests/testthat/test_r_cmd_check_
workflow_chrome_setup.R` (12 expectations, 4 `test_that` blocks, the new one guarding the `if:`
guards); `tests/testthat/test_helper_live_render_positions_timeout.R` (new file, 3 `test_that`
blocks / 6 expectations, structural/source-inspection style); `PROJECT_LEARNINGS.md` Learnings
648/649 (the falsification finding and the per-platform-fallback pattern); `BACKLOG.md`
Housekeeping (the chromote item removed outright; the new optional root-cause item added).

**Gotchas for a future session:** (1) `macos-latest` in `R-CMD-check.yaml` now runs WITHOUT a
pinned Chrome — it uses whatever Chrome the runner image ships ambiently, same as before S618's
pin was introduced. If `macos-latest` ever starts failing chromote tests again, do NOT assume it's
this exact bug recurring — re-diagnose from scratch, since ambient Chrome can itself drift over
time in a way the pinned binary wouldn't. (2) Raising `default_timeout` (`helper-live-render-
positions.R`) is proven NOT sufficient to fix a genuinely wedged chromote session on the pinned
macOS binary — do not re-attempt "just raise it further" as a fix for any future recurrence of
this specific symptom without new evidence; treat a still-failing raised-timeout as confirming
"wedged," not "needs more time." (3) The 16-item `BACKLOG.md` `[x]`-sweep and the optional
macOS root-cause item are both genuinely optional/low-priority — neither blocks anything, both are
explicitly deferred, not accidentally dropped.

### Session 619 Handoff Evaluation (by Session 620)
**Score: 8/10.** **What helped:** `key_files` pointed exactly at the files this session's own
diagnosis touched; `gotchas` #1/#2 (macOS reverted to ambient Chrome; raising `default_timeout`
proven insufficient, don't re-attempt) held up and were directly relevant background while reading
the CI-status check at Phase 0. **What was missing/wrong:** `next_steps` said "Walker/BJL Phase 2b...
still open" as one of "the other 3 items on this session's own priorities list" — this was already
STALE at the moment S619 wrote it: Phase 2b had been DONE 4 sessions earlier (S615, per
`BACKLOG.md`'s own dated entry), and S619's own Phase 0 orientation should have surfaced this via
the standard priorities-list render. This didn't cost this session real time (Phase 0's own fresh
`BACKLOG.md` read caught the correct state — Phase 3 was the actual next step, not Phase 2b — before
any priorities list was rendered to the user), but it's the kind of inaccuracy Learning-worthy
elsewhere in this project's history: a handoff's "next_steps" list should be re-verified against the
CURRENT `BACKLOG.md` state at write time, not copied forward from an earlier session's own framing
without re-checking. **ROI:** moderate — the CI-status gotchas were useful; the stale priorities
pointer was caught by Phase 0's own independent process, not by trusting the handoff.

### What Session 620 Did
**Deliverable:** Walker/BJL Phase 3 — Cutover (issue #141), per `docs/planning/pedigree-diagram-
walker-bjl-apportioning-redesign-plan.md` §Migration Path Phase 3. **DONE** — full TDD
PRE-RED→RED→GREEN→REFACTOR cycle, `AskUserQuestion`-gated at every transition. `.positionMatingUnitForest()`
cut over from the OLD contour-merge implementation to the Walker/BJL engine; `.computeDupNudge()`
and the OLD implementation deleted; `orderBySex` removed from `makePedigreeMatingLayout()`'s public
signature. **Started/Completed:** 2026-08-20–2026-08-21 (single session).

**What actually happened, in order:**

1. **Phase 0 orientation** — read `SESSION_RUNNER.md`/`SAFEGUARDS.md` in full; `SESSION_NOTES.md`
   (S613-619's thread); `gh issue list` (13 open); `git status`/`log`/`diff --stat` (clean, S619
   fully closed out, ledger frontiers both `== HEAD` except the self-reference 2-commit gap, matching
   the established S600/S602-619 no-op pattern); `gh run list` (CI green on all recent runs);
   `methodology_dashboard.py` (96/100, 1 HIGH risk, unchanged file-size items). Ghost-session check
   on the same 6 untracked files prior sessions already traced — unchanged, no new ghost deliverable.
   Rendered the priorities list (4 numbered `AskUserQuestion` options) — **user picked Walker/BJL
   Phase 3 (the direct continuation of the in-flight epic, Phase 2b's real-fixture gate having
   already passed per S615).**
2. **Grounded directly in the plan document's Phase 3 spec, Evidence-Based Inventory, and current
   source** before any code: full read of the plan's Migration Path Phase 3 section (Commit 3-1/3-2
   file lists), the full pinned-value/test inventory table, and direct reads of every affected test
   file (`test_positionMatingUnitForest.R` in full — all 1583 original lines across several Read
   calls — plus `test_positionMatingUnitForestBJL.R` in full, 931 lines, plus the relevant sections
   of `test_makePedigreeMatingLayout.R`/`test_addRectilinearWaypoints.R`/
   `test_resolveEdgeNodeCollisions.R`) and the current `.positionMatingUnitForestBJL()`/
   `.positionMatingUnitForest()`(OLD)/`makePedigreeMatingLayout()` source.
3. **Phase 1B claimed** — `SESSION_NOTES.md` stub + `HANDOFFS.md` `status: pending` receipt,
   committed (`014f0910`).
4. **PRE-RED scope decision, via its own dedicated `AskUserQuestion`** (per CLAUDE.md's "pre-RED
   scope decision is a separate question" rule): reconciled the plan's literal "Commit 3-1 (4 files)
   / Commit 3-2 (2 files)" split against this project's own unbroken RED/GREEN-as-separate-commits
   convention — chose RED (test-only, files re-pinned/merged/deleted) then GREEN (production swap
   alone), each its own commit.
5. **Second PRE-RED scope decision**, surfaced by direct source inspection before writing RED: found
   the top-level plan's own "orderBySex... untouched" claim was stale relative to Phase 1b's own
   later, ratified finding ("restructured, not preserved unchanged — eliminated as a separate
   pass") — `.positionMatingUnitForestBJL()` never had an `orderBySex` parameter at all, and 6 test
   blocks across 2 files still tested the OLD toggle directly. Presented via `AskUserQuestion`; owner
   picked removing the parameter from the public signature outright (zero real callers,
   grep-confirmed) over keeping it as a silent no-op.
6. **RED**, gated: built a throwaway monkey-patch probe (reassigning `.positionMatingUnitForest`'s
   package-namespace binding to delegate to `.positionMatingUnitForestBJL()`, matching this
   project's own "verify by execution, never hand-derive" discipline) to derive every new pinned
   value — trio/GA204Z-loop positional literals, the F1/nested/notover black-box regression values
   (150.12/60.12/180.12), Track 1/2 defect counts (all found to fully resolve to 0, a genuinely
   surprising result from directly running the code, not predicted) — then wrote the merged/re-pinned
   `test_positionMatingUnitForest.R` (24 BJL tests merged in, 3-way-OR invariant replaced with a
   single exact-equality assertion, 4 orderBySex tests + 2 Track-3-clamp tests + 3 computeDupNudge
   white-box tests deleted, 3 Track-3-Engagement-Gate fixtures transformed into black-box regression
   coverage), deleted `test_positionMatingUnitForestBJL.R`, and re-pinned the other 3 files. Confirmed
   genuine RED (219 failed / 0 error, entirely contained to the 5 touched files). Committed
   (`d6135511`, later amended — see step 8).
7. **RED→GREEN**, gated: deleted `.computeDupNudge()` and the OLD `.positionMatingUnitForest()`
   (~700 lines); renamed `.positionMatingUnitForestBJL()` to `.positionMatingUnitForest()`, updating
   its own roxygen doc; updated the call site; removed `orderBySex` from `makePedigreeMatingLayout()`.
   First full-regression run found 20 failures / 1 error — **2 genuine implementation defects**,
   diagnosed by running each failing fixture in isolation, not by inspection: (a) BJL never carried
   the OLD function's own input-validation guards (Phase 2a/2b's fixtures were always valid by
   construction, so this gap was never exercised) — restored verbatim; (b) a mating unit whose BOTH
   sire and dam are dangling (issue #154's original "both-dangling" shape) crashed
   `.buildForestChildrenOf()` on an empty `rootIds` — BJL had no equivalent to the OLD algorithm's
   own issue #154 fix; fixed by making such a unit's own real children independent Tier-1 roots
   directly, and broadening Tier 2's union-x derivation to cover every unit with ≥1 real child (not
   just anchored ones). The remaining 18 failures / 0 errors were **RED-phase test bugs** (matching
   S614's own established "3 RED-phase test bugs found and fixed during GREEN" precedent): a now-
   superseded minSep property test (deleted, its correctly-scoped Phase 2a successor already merged
   in), the issue #143/#144 mismatch-count regression guard (rewrote to assert the mismatch set is
   exactly the B2 population, 56, not 0 — B2 individuals render at their own genuine gen by design
   under the new engine, a deliberate Phase 1b/2a difference from the OLD algorithm's uniform
   non-anchor override, confirmed via direct classification: all 56 were B2, none unexplained), 1
   `test_addRectilinearWaypoints.R` fixture whose own non-anchor was accidentally B2-shaped (fixed by
   making it a parentless B1 founder, restoring the fixture's own intended premise), and 3
   `test_makePedigreeMatingLayout.R`/`test_resolveEdgeNodeCollisions.R` connector/curved-heuristic
   re-pins driven by the new engine's different coordinate distribution (1 fixture — the small issue
   #160 comment 1 synthetic reproduction — no longer collides at all under the new coordinates;
   rewritten to use the real 375-fixture instead, which reliably reproduces the mechanism, 47
   measured collisions). Verified genuine GREEN: full clean regression 0 failed/0 error project-wide
   (2 marker-genetics failures seen in ONE full-suite run confirmed pre-existing order-dependent
   flakiness via `git stash` — both pass cleanly in isolation, absent from RED's own offender list).
8. **Amended RED** (`e92d945e`) to fold in the 4 test-file corrections from step 7 — each
   re-verified via `git stash` (temporarily removing the GREEN-phase production diff) to confirm the
   corrected content still shows genuine, meaningful RED against the OLD, unmodified algorithm (229
   failed / 0 error, up from 219, still entirely contained to the same 5 files) before amending —
   keeping RED an honest, minimal "what should be true post-cutover" record and GREEN a clean,
   SAFEGUARDS.md-cap-compliant (5 files: `R/makePedigreeDiagramData.R` + `NEWS.Rmd`/`NEWS.md` +
   `man/makePedigreeMatingLayout.Rd` + `inst/WORDLIST`) production-only commit (`b013c009`).
9. **GREEN→REFACTOR**, gated: `lintr::lint_package()` (whole package) 0 findings before AND after a
   genuine simplification (an O(n·m) `vapply` scan replaced with a direct `unique(childEdges$from)`
   membership check, verified behavior-preserving via full regression + lint). Committed
   (`01f29342`).
10. **Required Phase-3 verification beyond the gated cycle:** live-render check (F1/Track-C 9-subject
    and real-375 fixtures, via `helper-live-render-positions.R`, already merged into the suite from
    Phase 2b) confirmed passing as part of the full clean regression, plus a direct standalone
    re-confirmation; fresh grep re-confirmed the call-site/downstream-consumer inventory (single call
    site, zero `matingUnits`/`duplicates`/`childEdges` consumers outside this file) has not drifted
    since planning; `devtools::check()` (0 errors, 1 WARNING + 2 NOTEs, all 3 confirmed pre-existing
    — a 4th, NEW Rd cross-reference warning, a `\link{}` to the now-internal
    `.positionMatingUnitForest()` from the one exported function's doc, was found and fixed
    in-session); pushed and confirmed CI green on all 4 workflows.
11. **Close-out:** `BACKLOG.md`'s Walker/BJL item updated with the full S620 progress narrative;
    `CHANGELOG.md` entry added; `PROJECT_LEARNINGS.md` Learnings 650/651/652 recorded; `CLAUDE.md`'s
    learning-count cross-reference refreshed (649→652); this handoff written.

**Runtime smoke test (Phase 3E):** the deliverable changes runtime behavior directly (every Diagram
tab render now uses the new positioning engine) — verified via the live-render checks in step 10
(chromote-driven real DOM rendering, not just internal x/gen math), plus the full `devtools::check()`
examples run (`makePedigreeMatingLayout()`'s own `@examples` block executes against the real bundled
example pedigree). This is the faithful verification this kind of change needs, matching this
project's own established "live-render, not just internal math" precedent (S615's own memory note).

**Close-out checklist mapping** (`CLAUDE.md`): citation checklist **N/A** — no new statistic.
Tutorial/article checklist **N/A** — no new Shiny tab/control, internal algorithm swap only.
`NEWS.Rmd` checklist **DONE** — same-session entry disclosing the layout-engine switch and the
`orderBySex` removal. `a2interactive.Rmd` checklist **deferred, per its own explicit policy** —
`grep`-confirmed `a2interactive.Rmd` never documented `orderBySex` to begin with (removing it creates
no staleness/broken-example risk there), so nothing is actively broken; the whole Walker/BJL
migration's user-facing effect (diagrams look different) is a candidate for the deferred
documentation pass once the migration fully completes (Phase 4+). `_pkgdown.yml` checklist **N/A** —
no new exported function, only a parameter removed from an already-listed one. GitHub issue
close-out **N/A** — issue #141 stays open (Phase 4, a future session, closes it per the plan's own
spec). Lint checklist **DONE** (0 lints, package-wide, confirmed at REFACTOR).

**Self-assessment (Session 620): 9/10.** **Strengths:** (1) Used a real monkey-patch probe (never a
plain "call the new function directly") to derive every re-pinned literal against the FULL, real
downstream pipeline — this is what caught several genuinely surprising, unpredictable-by-reasoning
findings (the D1 bar-vs-bar residual and larger-gap residual both fully resolving to 0, not just
improving; the real-fixture DZ twin connector losing its collision while MZ/"?" kept theirs) that a
literal-by-literal hand-derivation would have gotten wrong. (2) Diagnosed every GREEN-phase failure
by running the specific failing fixture/probe in isolation, never by inspection or assumption — this
surfaced 2 genuine implementation defects (input validation, both-dangling root handling) as
distinct from RED-phase test bugs, and traced the B2-rendering-difference root cause across 4
separately-symptomatic test failures rather than patching each ad hoc (recorded as its own
transferable Learning 650). (3) Surfaced 2 real, non-obvious scope/approach decisions
(RED/GREEN commit-split reconciliation; the `orderBySex` removal, found via direct source inspection
contradicting the top-level plan's own now-stale claim) via dedicated `AskUserQuestion`s before
writing code, rather than silently picking an interpretation. (4) Kept every commit within
`SAFEGUARDS.md`'s 5-file cap by amending the still-local, unpushed RED commit with GREEN-phase test
corrections — re-verified via `git stash` that the amended content was still genuinely RED against
the untouched baseline before amending, rather than either exceeding the cap or leaving a known-red
intermediate commit (which the plan's own Phase 3 spec explicitly warns against). (5) Found and fixed
a NEW `devtools::check()` warning (Rd cross-reference) in-session rather than deferring it, keeping
the package's check status at parity with every prior session's own established pre-existing-only
baseline. **Weaknesses:** (1) The initial RED-phase test-file authoring did not anticipate the
B2-rendering-difference (a design choice already documented in the Phase 1b design note, findable via
grep before writing RED, not just via GREEN-phase failures) — Learning 650 names the transferable
fix (grep the design note's own documented OLD-vs-NEW differences against the existing test suite's
own trigger conditions BEFORE writing RED). (2) This session ran long (a single sitting covering the
full plan-scoped Phase 3, as the plan's own "session boundary: this phase is one session" note
anticipated given its C2-1/C2-2 restructuring) — no session-boundary violation, but a genuinely large
amount of ground covered in one continuous session. **ROI:** very high — a 5+ session migration's own
central cutover step is complete, all tests genuinely green (not vacuously), 2 real defects the new
engine would otherwise have shipped with are fixed, and 3 transferable Learnings (650/651/652)
compress the session's own hard-won diagnostic technique for any future engine-swap migration.

**Next steps:** **Phase 4** (cleanup/documentation) is the plan's own explicit next step — its own
separate session, per the plan's "session boundary: this phase is one session" note (acceptable to
split into 4a/4b if too large, per the plan's own C2-8 fix): (1) update
`docs/planning/pedigree-diagram-option2-layout-design-plan.md`'s D3 section to describe the completed
BJL implementation; (2) close GitHub issue #141, citing this migration's commits
(`014f0910`/`e92d945e`/`b013c009`/`01f29342`, plus S610/S613/S614/S615's own prior-phase commits) and
the regression-number re-pin evidence; (3) update `BACKLOG.md`'s "Track 3's 2 disclosed trade-offs"
item (both trade-offs are now resolved by construction — no clamp exists anywhere in the new engine);
(4) sweep stale in-code comments referencing Track 3/Track 6/`.computeDupNudge()`/the old patch-stack
(a fresh `grep -rn "Track 6\|Track 3\|computeDupNudge\|finalUnitX" R/ docs/` is the plan's own named
verification command); (5) confirm explicitly (not assume) whether the tutorial/article and
`a2interactive.Rmd` checklists apply — this session's own close-out already confirmed
`a2interactive.Rmd` needs no fix (never documented `orderBySex`), but the FULL migration's own
user-facing "diagrams look different" effect may warrant a documentation note once Phase 4 completes
the whole redesign. Otherwise, `BACKLOG.md`'s other READY items remain open: NEWS.Rmd simplification
(Effort L, explicitly iterative/multi-round), the pedigree-diagram-package-split scoping session
(Effort M, owner-directed to run after this migration is fully done — i.e., after Phase 4), and the
16-item `BACKLOG.md` `[x]`-sweep (Effort S).

**Key files:** `R/makePedigreeDiagramData.R:585-798` (the production `.positionMatingUnitForest()`,
formerly `.positionMatingUnitForestBJL()` — the 2 new GREEN-phase fixes live at `:657-679` [orphan-
unit roots] and `:703-717` [Tier 2 `xDerivableUnits` broadening]); `:896-` (`makePedigreeMatingLayout()`,
`orderBySex` removed); `tests/testthat/test_positionMatingUnitForest.R` (now ~1910 lines, the merged
production test file — the 3-way-OR replacement is at the "single exact-equality" test near the file's
middle, the transformed Track-3-Engagement-Gate fixtures and the merged BJL Phase 2a/2b content follow
the zero-coincidence-gate test); `docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-
plan.md` (§Migration Path Phase 3/Phase 4, §Evidence-Based Inventory); `PROJECT_LEARNINGS.md`
Learnings 650/651/652.

**Gotchas for a future session:** (1) The monkey-patch probe technique (Learning 651) is reusable for
ANY future "swap engine X for Y, re-pin downstream literals" migration in this codebase — don't
re-derive it from scratch; `unlockBinding()` + `assign()` on the OLD function's namespace binding,
then call the real, unmodified, exported top-level function through it. (2) `orderBySex` is GONE from
`makePedigreeMatingLayout()`'s public signature — if any future session finds external code (a script,
a vignette, a downstream consumer) still passing it, that call will now error with "unused argument,"
not silently no-op; this is the intended, disclosed behavior (NEWS.Rmd/man page both document it), not
a regression to investigate. (3) B2 individuals (own parent edge or own D5 direct child) now render at
their own genuine gen, not their non-anchor unit's gen — do NOT assume every non-anchor party renders
at its unit's gen the way the OLD algorithm's issue #143 override guaranteed; check B1 vs. B2 status
first (Learning 650's own practical rule). (4) Track 3's parent-span clamp and the entire
`.computeDupNudge()`/Track-3-Engagement-Gate mechanism no longer exist anywhere in the codebase — any
future BACKLOG.md item or in-code comment still referencing them describes OLD, now-dead behavior
(Phase 4's own comment-sweep task, not yet done).

---

### Session 620 Handoff Evaluation (by Session 621)
**Score: 9/10.** **What helped:** the `next_steps` field named exactly the 6 concrete actions
Phase 4 needed (D3 section update; close issue #141 citing commits; update `BACKLOG.md`'s trade-off
item; sweep stale in-code comments with the plan's own exact `grep` command; confirm the
tutorial/article and `a2interactive.Rmd` checklists rather than assume; add `NEWS.Rmd`/`CHANGELOG.md`
entries) — used almost verbatim as this session's own task checklist. `key_files`/`gotchas` were
directly useful and all confirmed accurate on re-read: `.positionMatingUnitForest():585-798`,
`orderBySex` removed, Track 3/`.computeDupNudge()` genuinely gone (grep-confirmed 0 hits in `R/`),
B2-vs-B1 gen rendering — every one of these was load-bearing for writing an accurate D3 update and
issue-close comment without re-deriving them from scratch. **What was missing:** the `HANDOFFS.md`
receipt's own free-text prose section was left as the literal unfilled placeholder
(`<free-text prose: filled at close-out>`) rather than actual prose — `SESSION_NOTES.md`'s version
was fully written, so this cost nothing practically, but the receipt itself didn't fully satisfy its
own documented format (a small, worth-noting gap, not scored heavily). **What was wrong:** nothing
found inaccurate — every specific claim (commit shas, line ranges, "Track 3/6 no longer exist",
"`a2interactive.Rmd` already N/A for `orderBySex`") checked out exactly on independent verification
this session. **ROI:** very high.

### What Session 621 Did
**Deliverable:** Walker/BJL Phase 4 — Cleanup & Close (issue #141), per `docs/planning/pedigree-
diagram-walker-bjl-apportioning-redesign-plan.md`'s §Phase 4 spec. **DONE** — documentation/cleanup
only, no production logic changed. **Started/Completed:** 2026-08-20 (single session).

**What actually happened, in order:**

1. **Phase 0 orientation** — read `SESSION_RUNNER.md`/`SAFEGUARDS.md` in full; `SESSION_NOTES.md`
   (S613-S620's thread); `gh issue list` (13 open); `git status`/`log`/`diff --stat` (clean, S620
   fully closed out, `CHANGELOG.md` ledger 2 commits behind `HEAD` — confirmed the established
   self-reference no-op pattern, not a genuine gap; `HANDOFFS.md` frontier `== HEAD`); `gh run list`
   (CI green on all recent runs); `methodology_dashboard.py` (96/100, 1 HIGH risk, unchanged
   file-size items). Ghost-session check on the same 6 untracked files prior sessions already
   traced — unchanged, no new ghost deliverable. **Incidental finding, reported not fixed:**
   `BACKLOG.md`'s single-child-union item still carried an inline "targeted repair session (READY,
   Effort S)" tag for a function (`.computeSingleChildAntiCoincidence()`) that grep-confirmed was
   never shipped — the item's own LATER prose (S609, same block) showed this was redirected to the
   Walker/BJL migration itself 12 sessions earlier; struck later this session as part of the Phase 4
   deliverable itself (see below), not a separate action. Rendered the priorities list (4 numbered
   `AskUserQuestion` options) — **user picked Walker/BJL Phase 4.**
2. **Phase 1B claimed** — `SESSION_NOTES.md` stub + `HANDOFFS.md` `status: pending` receipt,
   committed (`7dccb6e6`).
3. **Grounded directly in the plan's Phase 4 spec, the D3 section it points at, and issue #141's
   full text/comments** before any edit: read `docs/planning/pedigree-diagram-walker-bjl-
   apportioning-redesign-plan.md`'s §Phase 4 ("what DONE looks like," the verification command),
   the option2-layout-design-plan.md's full D3 section (§3), and `gh issue view 141` in full
   (body + the S609 comment; state OPEN, labels `enhancement`/`premature optimization`).
4. **D3 section updated** — appended a "Superseded (S609-S620)" note after the original D3 text
   (not rewritten in place, matching this project's established precedent of preserving historical
   planning narrative — BACKLOG.md's own append-only item convention is the same pattern) describing
   the correctness-driven redirect, the 3-tier reconciliation mechanism shipped, and the explicit
   D1/D2/D4/D5/D6-unchanged scope boundary.
5. **Stale in-code comment sweep** — ran the plan's own verification command
   (`grep -rn "Track 6|Track 3|computeDupNudge|finalUnitX" R/ docs/`), then deliberately extended it
   to `tests/` (not in the plan's own command, but `test_that()` descriptions are exactly as much
   in-code documentation as a roxygen comment — Learning 654). `R/` was already accurate (S620 had
   annotated its own doc comments correctly during RED). `docs/planning/*.md` deliberately left
   untouched — 13 files reference these terms, all legitimate historical record of decisions made at
   the time, matching this project's precedent against retroactively editing frozen/historical
   narrative. **One genuine finding in `tests/`:** `test_makePedigreeMatingLayout.R`'s own
   `test_that()` docstring for the 1,412-node real-fixture assertion still narrated the REMOVED
   Track 3 clamp's arithmetic ("1,202 + 210 = 1,412") as the live explanation — verified stale, not
   just dated, by actually re-executing the real fixture (`direct nodes: 714`, `__bar_: 251`,
   `__drop_: 237`, `__proj_: 56` [pre-existing dogleg infrastructure, unrelated to this migration],
   `__jog_: 154`) and finding the OLD arithmetic's own terms no longer decompose the number at all,
   even though both totals coincidentally land on 1,412. Rewrote the docstring to the verified
   current composition — **no assertion values changed** (both `1412L` and `154L` were already
   correct), comment-only. Spot-verified via `testthat::test_file()` on the one touched file (all
   green) plus a full clean regression afterward (0 failed/0 error, no non-baseline offenders) and
   `lintr::lint()` (0 findings) before committing.
6. **BACKLOG.md's "Track 3's 2 disclosed trade-offs" item closed** (`[x]`) — both trade-offs
   (child-centering quality, D1 bar-vs-bar overlap) confirmed resolved by construction; the D1
   bar-vs-bar residual specifically re-measured this session by running
   `test_addRectilinearWaypoints.R` directly (all green, 0 residual, matching its own docstring
   claim). The stale single-child-union tag found at Phase 0 (step 1 above) struck in place with a
   dated explanation, not deleted — Learning 653.
7. **Issue #141 closed** on GitHub: a comment citing the full Phase 1a-4 commit history
   (`8ac50a4e` S611; `0a43ec30`/`e7f1f593`/`afa7c5f5` S614; `891837d6` S615;
   `014f0910`/`e92d945e`/`b013c009`/`01f29342` S620) and re-confirming the D1/D2/D4/D5/D6-unchanged
   scope. **Label decision gated via `AskUserQuestion`** (3 prior sessions, S609/S620×2, had
   explicitly deferred this exact call to "a future planning session or the owner directly" — this
   was that session): owner picked removing `premature optimization`, since its own meaning no
   longer applies to a closed, shipped, adversarially-verified implementation.
8. **Tutorial/article and `a2interactive.Rmd` checklists explicitly re-confirmed, not assumed** —
   grepped both `vignettes/articles/colony-manager-guide.qmd` and `vignettes/a2interactive.Rmd` for
   algorithm-specific claims (contour-merge/Reingold/Walker/Buchheim/`orderBySex`): zero hits in
   either. Independently confirmed the vignette's own "5 reserved node-id prefixes" comment is still
   accurate — `__proj_` is pre-existing `.buildMatingUnitForest()` dogleg infrastructure (gen-mismatch
   waypoints), unrelated to and unaffected by this migration, not a new prefix it introduced.
9. **`NEWS.Rmd`** needs no further entry — S620's own entry already discloses the user-facing change
   (layout engine switch, `orderBySex` removal) completely, confirmed by direct read.
10. **Close-out:** `CHANGELOG.md` S621 entry added; commits split across the 5-file cap (deliverable:
    `909dad20`; learnings: `8878239c`); `PROJECT_LEARNINGS.md` Learnings 653/654 recorded;
    `CLAUDE.md`'s learning-count cross-reference refreshed (652→654); this handoff written.

**Runtime smoke test (Phase 3E):** n/a — documentation/cleanup only, zero production logic touched
(confirmed: `R/` needed no changes at all, the one code-adjacent edit was a test file's comment-only
docstring). No runtime behavior changed; nothing to smoke-test, matching this session's own
declared TDD framing (stated at Phase 1: "N/A this session... documentation/cleanup").

**Close-out checklist mapping** (`CLAUDE.md`): citation checklist **N/A** — no new statistic.
Tutorial/article checklist **DONE (confirmed N/A)** — explicitly re-grepped this session, not
assumed. `NEWS.Rmd` checklist **N/A (already satisfied by S620)** — confirmed by direct read, no
further entry needed. `a2interactive.Rmd` checklist **DONE (confirmed N/A)** — explicitly re-grepped,
including the reserved-node-id-prefix claim specifically. `_pkgdown.yml` checklist **N/A** — no new
exported function. GitHub issue close-out **DONE** — issue #141 closed this session, citing the full
commit history per the established #131/#134/#135/#139/#142/#143/#144 precedent. Lint checklist
**DONE** (0 lints on the one touched test file, package-wide unaffected).

**Self-assessment (Session 621): 9/10.** **Strengths:** (1) Extended the plan's own literal
verification grep beyond its stated `R/ docs/` scope into `tests/`, finding one genuine stale
docstring the plan's own command would have missed entirely (Learning 654). (2) Verified the stale
docstring's replacement by actually re-executing the real fixture and breaking down every node-id
prefix, rather than just updating the one number that had visibly changed (`210L`→`154L`) and leaving
an equally-confident-but-wrong arithmetic framing around it — found a pre-existing, unrelated
`__proj_` node category in the process that resolved what first looked like a real discrepancy. (3)
Found and corrected a stale `BACKLOG.md` inline tag that a flat future grep would have surfaced as a
live option, years after the same item's own later prose had already documented its abandonment
(Learning 653) — caught only because the named function was grep-confirmed never shipped, not by
reading the tag's own text. (4) Gated the `premature optimization` label decision via
`AskUserQuestion` rather than either unilaterally deciding it or leaving it unresolved a 4th time,
directly resolving a decision 3 prior sessions had explicitly deferred. (5) Preserved historical
planning narrative by appending rather than rewriting (D3 section, BACKLOG.md item), matching this
project's own strong precedent, while still making the CURRENT state easy to find. (6) Full clean
regression + lint run despite this being a documentation-only session, rather than assuming
comment-only edits are risk-free. **Weaknesses:** (1) Spent real investigative time
(several tool calls) chasing the exact node-count arithmetic discrepancy before finding the
`__proj_` explanation — defensible given this project's own "verify by execution, never assume"
standard, but a more experienced first guess (checking `.buildMatingUnitForest()`'s reserved-prefix
list, which already enumerated `__proj_`) would have found the explanation faster. (2) Did not
independently re-verify EVERY one of S620's own `key_files` line-range claims byte-for-byte before
relying on them (spot-checked the ones actually used); low risk here since all spot-checks that were
done came back accurate. **ROI:** high — the 11-session Walker/BJL migration (S610-S621) is fully
closed out: implementation shipped and verified (S610-S620), documentation/issue/backlog trail
closed (S621), 2 project-level process learnings captured with transferable practical rules.

**Next steps:** Walker/BJL (issue #141) is fully closed — no further session owed. `BACKLOG.md`'s
other READY items remain open, in the order left by this session's own Phase 0 priorities list:
(1) the pedigree-diagram package-split scoping session (Effort M, research/scoping only) — the
"probably after the Walker/BJL redesign" sequencing condition its own text named is now satisfied;
(2) `NEWS.Rmd` simplification for a non-technical audience (Effort L, explicitly iterative, needs a
recurrence guardrail this time per S538's own gap); (3) the 16-item `BACKLOG.md` `[x]`-sweep
(Effort S, housekeeping — note this item's own count grows by at least 1 more now that this
session's own Track 3 trade-off item is `[x]`-checked); (4) lower-priority items unchanged from
S621's own Phase 0 report (Chrome-for-Testing macOS hang root-cause, `context_budget.py` adoption
evaluation, `DESCRIPTION` `Suggests:`/`Config/Needs` cleanup, kinship2 supplement PDF reproduction,
`BACKLOG.md`'s own ledger-size compression).

**Key files:** `docs/planning/pedigree-diagram-option2-layout-design-plan.md` (D3 section, the
"Superseded (S609-S620)" note appended this session); `BACKLOG.md` (the "Track 3's 2 disclosed
trade-offs" item, now `[x]`-closed, plus the struck stale tag in the single-child-union sub-thread);
`tests/testthat/test_makePedigreeMatingLayout.R:588-625` (the corrected docstring, assertions
unchanged); `PROJECT_LEARNINGS.md` Learnings 653/654; GitHub issue #141 (closed, `enhancement` label
only, `premature optimization` removed).

**Gotchas for a future session:** (1) `.computeSingleChildAntiCoincidence()` was NEVER shipped —
if a future session finds it referenced anywhere outside `BACKLOG.md`'s own now-struck historical
note, that is new, not a missed cleanup from this session. (2) The `__proj_` node-id prefix is
PRE-EXISTING `.buildMatingUnitForest()` dogleg infrastructure (parent/union gen-mismatch waypoints),
NOT something the Walker/BJL migration introduced — do not attribute future `__proj_`-related bugs
to the new positioning engine without checking `.buildMatingUnitForest()` first (line ~1418 in
`R/makePedigreeDiagramData.R`). (3) `docs/planning/*.md` files are deliberately excluded from any
future "stale reference" sweep unless a specific file is explicitly named as needing a live update
(as `pedigree-diagram-option2-layout-design-plan.md`'s D3 section was this session) — most planning
docs are intentionally frozen historical record, not living documentation.
