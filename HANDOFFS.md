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

```handoff
session: S397
date: 2026-07-17
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE -- processed S396's win-builder Windows-devel result for
  the CRAN 2.0.0 checktime fix. Check time in seconds: 588, 12s under
  CRAN's 600s mark (down from the S392-394 cycle's 655-656s). Owner decided
  (AskUserQuestion): resubmit now. Next action is the owner running
  devtools::submit_cran() themselves -- owner-only per SAFEGUARDS/the
  runbook HARD STOP. No further engineering action open on this item unless
  CRAN rejects it again.
what_was_done: Read cran-comments.md's own S393 precedent before computing
  anything from the owner's pasted 00check.log -- this surfaced the
  project's established distinction between a bracket-summed total (476s,
  what the pasted log alone would have produced) and "the email's reported
  total check time" (the actual authoritative figure). Asked the owner for
  the full email text; got Installation time 30s / Check time 588s -- 112s
  higher than the bracket-sum, avoiding a wrong number. Updated
  cran-comments.md (new 2026-07-17 narrative paragraph + Test environments
  section) and BACKLOG.md's CRAN item with the confirmed result. Presented
  the resubmit/wait/hold decision via AskUserQuestion; owner chose resubmit
  now. Recorded the decision in BACKLOG.md. Documented the near-miss as
  PROJECT_LEARNINGS.md Learning 364. Commits: 9eccd624 (session claim);
  this receipt finalizes in the close-out commit that follows.
next_steps: No engineering action open on the CRAN item -- the owner runs
  devtools::submit_cran() and clicks the maintainer-email confirmation link
  themselves (owner-only). If CRAN rejects again, the next session should
  fetch the verbatim rejection detail (not just the summary) before
  proposing any fix, per this project's established practice. Otherwise,
  BACKLOG.md's next READY item is "Execute Document 2 Phase D" (Effort M) --
  see docs/planning/document2-colony-manager-guide-plan.md Section 6 Phase
  D for full completion criteria.
key_files: cran-comments.md (2026-07-17 S397 narrative paragraph + Test
  environments section, lines ~119-144 and ~172-209 pre-session); BACKLOG.md
  (CRAN item, ~lines 71-115 pre-session); CHANGELOG.md 2026-07-17 S397 entry;
  PROJECT_LEARNINGS.md Learning 364.
gotchas: (1) win-builder's emailed "Check time in seconds" total is NOT
  reconstructible by summing the 00check.log body's individual [Ns] step
  brackets -- it lives in the email's separate wrapper text alongside
  "Installation time in seconds," and is meaningfully higher (112s in this
  case) than the bracket-sum. Always ask for/fetch that literal line rather
  than deriving a substitute. (2) win-builder's "Check time" remains a proxy
  for CRAN's own "Overall checktime" (the real incoming-pipeline figure),
  not proven identical -- 12s of margin on a proxy metric is real progress
  but not a guarantee against a repeat rejection; the owner was told this
  explicitly before deciding. (3) win-builder R-release/R-oldrelease/R-hub
  results on file are still Session 390/391-era, unconfirmed against the
  S392-395 checktime fixes (not expected at risk, since the checktime gate
  is Windows-r-devel-specific, but not verified). (4) Gmail MCP access was
  expired this session (token needs re-auth) -- could not independently
  check for the win-builder email; relied on the owner pasting it directly.
runtime_smoke: n/a -- release-mechanics/verification + documentation action,
  no runtime application behavior changed.
changelog_ref: CHANGELOG.md 2026-07-17 S397 entry
commit: 9eccd624 (session claim); this receipt is finalized in the
  close-out commit that follows.
```

```handoff
session: S396
date: 2026-07-16
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE (dispatch only) -- dispatched a fresh win-builder
  Windows-devel check (devtools::check_win_devel()) to confirm S395's
  CRAN checktime fixes resolve the archived-rejection failure class
  ("Overall checktime 12 min > 10 min" on Windows r-devel). Results are
  asynchronous (~15-30 min via email) -- processing them is the next
  session's work, mirroring the S361->S362 and S390->S391 split.
what_was_done: Confirmed a clean, in-sync tree at Phase 0 (no ghost
  session, CHANGELOG.md/HANDOFFS.md both current). Scoped narrowly to
  BACKLOG.md's literal "Next" text -- one win-builder Windows-devel check,
  not the broader S390 pattern (x3 win-builder + R-hub) -- since the
  BACKLOG item itself calls for only that single Effort-S action this
  cycle. Ran devtools::check_win_devel(quiet = FALSE) from the project
  root; build succeeded (nprcgenekeepr_2.0.0.tar.gz, vignettes rebuilt
  OK), uploaded to win-builder.r-project.org R-devel queue. Dispatch
  confirmed: results due to rmsharp@me.com by ~10:46 PM 2026-07-16.
  git status confirmed clean both before and after the build. Commit
  a2ad6c13 (session claim); no further code/doc commit needed beyond
  this close-out commit since no implementation changed.
next_steps: When the win-builder email arrives (~10:46 PM 2026-07-16),
  fetch the verbatim 00check.log (not just the email summary, per this
  project's established practice -- see S391). Confirm "0 errors | 0
  warnings" AND explicitly check for an "Overall checktime" wall-clock
  summary line (the exact failure class that archived the real
  submission in S392) -- win-builder's own check log format may or may
  not surface that summary the same way CRAN's incoming pipeline does,
  so verify against the actual timing figures in the log, don't infer
  from "0 errors/0 warnings" alone. If clean, update cran-comments.md's
  Test Environments section and BACKLOG.md's CRAN item with the
  confirmed result, then present the resubmit/wait/hold decision to the
  owner via AskUserQuestion (devtools::submit_cran() remains owner-only
  per SAFEGUARDS.md).
key_files: BACKLOG.md (CRAN resubmission item, ~lines 71-88 pre-session);
  cran-comments.md (Test Environments section to update with the new
  result); docs/planning/cran-2.0.0-phase5-runbook.md (full runbook and
  HARD STOP on submit_cran()); CHANGELOG.md 2026-07-16 S396 entry.
gotchas: (1) devtools::check_win_devel() uploads a tarball built from the
  LOCAL working tree via FTP -- unlike R-hub, it does NOT test GitHub's
  copy, so no push was a precondition here (contrast S390, which had to
  push before dispatching R-hub). (2) renv::status() reports an
  out-of-sync warning (rlang 1.2.0!=1.3.0, zip repo/version drift) on
  every Rscript invocation in this project currently -- pre-existing,
  unrelated to the package's own DESCRIPTION/build, does not block
  check_win_devel() dispatch; don't chase it as part of this task.
  (3) Local R CMD check --as-cran already confirmed 0 errors/0
  warnings/1 note with tests 59s/examples 22s/vignette-rebuild 17s (S395)
  -- comfortably under the 10-minute threshold on local macOS hardware,
  but the archived rejection happened specifically because win-builder's
  Windows VM runs slower than local hardware -- a clean local check is
  necessary but was already proven NOT sufficient; the win-builder
  Windows result is the one that actually confirms or refutes the fix.
runtime_smoke: n/a -- release-mechanics/verification action, no runtime
  application behavior changed.
changelog_ref: CHANGELOG.md 2026-07-16 S396 entry
commit: a2ad6c13 (session claim); this receipt is finalized in the
  close-out commit that follows.
```
<Score breakdown: predecessor 9/10 -- BACKLOG's literal "Next" text gave
this session an unambiguous, correctly-scoped single action with no
rediscovery cost; only ding is not having a fallback line for what to do
if the archived-rejection checktime note reappears despite S395's fixes.
Self 8/10 -- correctly scoped narrow (declined implicit S390-pattern
scope creep), verified tree cleanliness before/after the build, correctly
classified TDD N/A; docked one point for not explicitly weighing/
surfacing the R-hub-and-other-win-builder-variants tradeoff as a
considered-and-declined option rather than simply not raising it.>
```

```handoff
session: S395
date: 2026-07-17
status: complete
self_score: 7
predecessor_score: 8
active_task: DONE -- re-opened the CRAN 2.0.0 checktime investigation with
  owner-authorized wider scope (test structure + previously-protected
  iteration counts). Landed 2 real CRAN-relevant fixes, correctly declined
  a 3rd (verified pointless before implementing), caught and corrected a
  4th (looked like the biggest win, verified CRAN-irrelevant before
  close-out). Win-builder confirmation is the next concrete step, not done
  this session.
what_was_done: Bundle A (5 files, commit 3af7651f) -- pkgdown::as_pkgdown()
  hoisted 3x->1x (test_pkgdown_reference_config.R, later found
  CRAN-irrelevant, see gotchas); test_reportGV.R guIter=1000L fixture
  hoisted 3x->1x; test_appServer_dynamicTabs.R appUI() hoisted; 
  test_appServer_server.R/test_appServer_logging.R missing downstream
  Shiny-module stubs added to under-stubbed with_mocked_bindings blocks.
  Investigated+dropped test_groupAddAssign.R iter=1000->50 (rmsharp-gated
  file, zero real CRAN benefit -- not implemented). Landed
  test_addAnimalsWithNoRelative.R fixture swap (commit d7981a09,
  examplePedigree->qcPed, ~5.85s->~0.01s, the session's only genuinely
  large CRAN-relevant win). Ran real R CMD check --as-cran --timings on
  the built tarball (commit 7eefa048), which surfaced the pkgdown
  correction; updated cran-comments.md/CHANGELOG.md/BACKLOG.md accordingly.
  Full local dev-mode regression suite clean throughout (0 failed/0
  error/0 warning, 1387 tests/179 skipped, unchanged coverage). Real R CMD
  check: examples 22s / tests 59s / vignette-rebuild 17s, 0 errors | 0
  warnings | 1 note, FAIL 0 | WARN 0 | SKIP 208 | PASS 3210.
next_steps: Dispatch a fresh win-builder Windows-devel check (S390
  precedent, explicit owner scoping via AskUserQuestion first) to confirm
  the real combined impact of this session's 2 genuine fixes before any
  resubmit/wait/hold decision. Before touching any other previously-slow
  test file, grep PROJECT_LEARNINGS.md/BACKLOG.md for that file's name
  first (Learning 363).
key_files: test_pkgdown_reference_config.R (CRAN-irrelevant but harmless,
  see gotchas), test_reportGV.R:392-488, test_appServer_dynamicTabs.R:127-145,
  test_appServer_server.R, test_appServer_logging.R,
  test_addAnimalsWithNoRelative.R, cran-comments.md, CHANGELOG.md,
  BACKLOG.md (CRAN item), PROJECT_LEARNINGS.md Learning 363
gotchas: (1) pkgdown fix is real but CRAN-irrelevant -- don't count it in
  any future checktime tally. (2) Win-builder not yet re-triggered --
  local numbers are promising (~13.8s CRAN-relevant local savings) but
  unconfirmed at real scale. (3) Grep PROJECT_LEARNINGS.md/BACKLOG.md for
  a file's name before touching it again -- this session paid for
  skipping that once (Learning 363). (4) Two flagged-not-fixed findings:
  unseeded reportGV()/groupAddAssign()/summary.nprcgenekeeprErr.R
  @examples (~25% checkFgDegeneracy warning risk per run, independent of
  checktime); R/addAnimalsWithNoRelative.R's own roxygen comment ("should
  be 259") is stale (actual 591) -- minor, not fixed, out of scope. (5)
  Standing: do not touch ColonyManagerTutorial.Rmd or lower guIter in
  reportGV()/groupAddAssign() examples or a2interactive.Rmd -- degeneracy
  guardrail re-verified real but noisier than documented (guIter=25
  fails, 20/30 pass). (6) Config/testthat/parallel:true confirmed real
  and CRAN-honored (~1.65x local) but needs a Config/testthat/edition:3
  migration across 264 files, not audited -- future effort. (7)
  submit_cran() owner-only. (8) Document 2 Phase D (READY, Effort M);
  LabKey remainder (BLOCKED) unchanged.
runtime_smoke: n/a -- test-file-only changes, no R/ production code
  changed. Real R CMD check --as-cran on the built tarball (this
  session's equivalent verification) confirms the changed tests execute
  correctly under the actual CRAN mechanism, not just dev-mode.
changelog_ref: 2026-07-16/17 CHANGELOG.md entries "Re-open CRAN checktime
  investigation with wider scope" (2 entries, the second appending the
  real-check correction)
commit: 7eefa048
```

```handoff
session: S394
date: 2026-07-16
status: complete
self_score: 9
predecessor_score: 9
active_task: Closed out the 3-session CRAN 2.0.0 checktime effort (S392-394).
  Confirmed S393's fix was real (vignette rebuild 79s->66s) but offset by run-to-run
  noise (total 656s, unchanged from S392's 655s). Investigated the "tests" long tail
  as directed, caught a profiling-methodology error before it caused a wrong edit,
  found no further safe lever, and closed out with owner agreement -- DONE.
what_was_done: Fetched the verbatim 00check.log for the fresh win-builder result --
  confirmed simulatedKValues.Rmd's fix was real (vignette rebuild 79s->66s) but fully
  offset by noise elsewhere (examples +6s, R-code-check +2s, HTML manual +5s).
  Confirmed via a multi-line-aware search that no test relies on an unspecified
  default iteration count. Profiled 8 Shiny-testServer-heavy candidate files by
  looping test_file() calls in one session -- test_appServer_server.R showed a
  suspicious 22.951s/10-tests (uniform ~2.3s/test), which would have justified
  consolidating tests into fewer session mounts. Re-verified by re-running that file
  alone in a fresh session: 3.929s, under a fifth of the looped figure. Re-profiled
  all 8 files individually: combined total 16.9s, all genuine appServer()-wiring
  coverage (added by prior sessions to close a real 0%-coverage gap), not redundant
  overhead -- not a safe consolidation target for that size of payoff. Documented as
  PROJECT_LEARNINGS.md Learning 362. Updated BACKLOG.md (CRAN item retagged DECISION
  NEEDED), cran-comments.md (final S394 summary), CHANGELOG.md (S394 entry),
  CLAUDE.md (learning-count refresh). No test/vignette/R code changed this session.
next_steps: The CRAN 2.0.0 checktime effort is closed for now -- real, verified
  progress (tests 334s->245s, vignette rebuild 79s->66s, both confirmed across
  independent win-builder runs) but total check time is stable at ~655-656s, ~55s
  over the 10-min mark. The one genuinely unexplored angle: the ~119-121s
  "untimed overhead" gap between summed check-log steps and the reported total --
  nobody has investigated whether this is reducible. The resubmit/wait/hold decision
  at the current margin is the owner's, not a session's; devtools::submit_cran()
  remains owner-only.
key_files: BACKLOG.md (CRAN item retagged), cran-comments.md (final S394 summary
  note), CHANGELOG.md (new S394 entry), PROJECT_LEARNINGS.md (Learning 362),
  CLAUDE.md (learning-count refresh), HANDOFFS.md (this receipt).
gotchas: Don't re-run the S392-394 sweeps without new information -- three rounds
  found no further safe lever. Standing warnings still apply: do NOT touch
  vignettes/ColonyManagerTutorial.Rmd (.Rbuildignore'd, separately owned by the
  Document 2 backlog item) or lower guIter in reportGV()/groupAddAssign()'s roxygen
  examples or vignettes/a2interactive.Rmd (triggers checkFgDegeneracy at
  guIter<=30). When profiling per-file test timing for any future decision, always
  re-verify a surprising number in complete isolation (fresh Rscript invocation)
  before trusting it -- see Learning 362.
runtime_smoke: n/a -- investigation and documentation only, no R/ production runtime
  behavior, tests, or vignettes changed this session.
changelog_ref: CHANGELOG.md 2026-07-16 "Close out the CRAN checktime effort: real progress, practical floor reached (Session 394)"
commit: pending
```

```handoff
session: S393
date: 2026-07-16
status: complete
self_score: 9
predecessor_score: 9
active_task: Confirmed S392's skip_on_cran() fix works (tests 334s->245s, 0 FAIL/0
  WARN) but total check time (655s) was still ~55s over the 10-min mark. Diagnosed
  why vignette-rebuild hadn't moved (ColonyManagerTutorial.Rmd, the largest local
  render, is .Rbuildignore'd and irrelevant; a2interactive.Rmd is the real dominant
  vignette, blocked by the checkFgDegeneracy risk). Found and fixed one more real
  lever (simulatedKValues.Rmd's createSimKinships n=1000L->500L), confirmed via a
  broad sweep that no further safe lever exists, and dispatched a fresh win-builder
  Windows-devel check -- DONE (fix + dispatch; results asynchronous).
what_was_done: Fetched verbatim 00check.log/nprcgenekeepr-Ex.timings/testthat.Rout
  from the win-builder result (not the summary email) -- confirmed all 10
  skip_on_cran() additions fired under the "On CRAN (193)" category, tests dropped
  334s->245s, but summed timed steps only dropped 628s->534s and the reported total
  (655s) implies ~121s of untimed overhead, still ~55s over 600s. Timed each of the 5
  source-tree vignettes individually: ColonyManagerTutorial.Rmd (16.58s, largest) is
  confirmed .Rbuildignore'd (line 31) and therefore irrelevant to the real build --
  also separately out of scope since BACKLOG.md's Document 2 item already owns
  deciding its fate. a2interactive.Rmd (10.07s) is the real dominant vignette,
  already known blocked by S392's checkFgDegeneracy finding. simulatedKValues.Rmd
  (5.56s) was the one real unaddressed lever: createSimKinships(n=1000L) alone costs
  4.07s on a 17-row pedigree (superlinear in n -- halving n to 500 cut time 68%, not
  50%). Verified the mean-sd/row-count pattern is materially unchanged at n=500,
  applied the reduction, updated 2 hardcoded "1000" captions + the stats_1000
  variable name, re-rendered clean. A broader sweep across all tests/vignettes/
  roxygen @examples for other large iteration parameters found only false alarms
  (mock-function defaults already skip_on_cran()'d; tiny 7-row-pedigree calls;
  @source prose, not executed code). Full regression re-confirmed clean (CRAN mode
  3197 passed/179 skipped/0 failed/0 error/0 warning, unchanged from S392's
  baseline). Committed: 80a852f0 (fix+docs), 08c9d29c (dispatch-ETA). Dispatched
  devtools::check_win_devel() again.
next_steps: Win-builder Windows-devel results due by email ~01:22 PM 2026-07-16
  (rmsharp@me.com) -- fetch the verbatim 00check.log/testthat.Rout/Ex.timings (not
  just the email) and confirm the total is now comfortably under 600s, not just
  barely under. If still over: (a) the ~121s "untimed overhead" gap's reducibility
  is unexplored, (b) test_appServer_server.R (557 lines/27 testServer() blocks,
  3.57s local, largest remaining single test file) is a real-coverage file, not a
  skip_on_cran() candidate -- any change there needs more care than a parameter
  trim. devtools::submit_cran() remains owner-only regardless of outcome.
key_files: vignettes/simulatedKValues.Rmd (n=1000L->500L + 2 captions + variable
  rename), BACKLOG.md (CRAN item updated twice), cran-comments.md (2026-07-16
  follow-up note), CHANGELOG.md (new S393 entry), PROJECT_LEARNINGS.md (Learning
  361), CLAUDE.md (learning-count refresh), HANDOFFS.md (this receipt).
gotchas: Do NOT touch vignettes/ColonyManagerTutorial.Rmd for CRAN-timing purposes --
  it's .Rbuildignore'd (irrelevant) AND its fate is a separate, owner-ratified
  decision under BACKLOG.md's "Document 2" item. Do NOT re-attempt lowering guIter in
  reportGV()/groupAddAssign()'s roxygen examples or vignettes/a2interactive.Rmd --
  confirmed guIter<=30 triggers checkFgDegeneracy there (S392, re-confirmed by trust
  this session). Before trusting ANY local render/test-timing profile as a stand-in
  for the real CRAN check, check .Rbuildignore and skip guards for every file in the
  profile, not just suspected ones (Learning 361).
runtime_smoke: n/a -- vignette content/parameter changes only, no R/ production
  runtime behavior changed. Equivalent verification: full regression suite (0
  failed/0 error/0 warning) + direct vignette re-render (HTML-inspected, no genuine
  warnings/errors).
changelog_ref: CHANGELOG.md 2026-07-16 "Confirm S392's checktime fix worked, find it's still ~55s short, trim further (Session 393)"
commit: 80a852f0 / 08c9d29c
```
<Self-score 9/10. Strengths: fetched verbatim check-result files rather than trusting
the summary email; checked .Rbuildignore before investing effort in the largest
local vignette render, avoiding both a repeat of S392's local-profiling-mismatch
class of mistake and a scope collision with the separately-owned Document 2 decision;
empirically verified the simulatedKValues.Rmd n-reduction preserves its narrative
before applying it, learning directly from S392's checkFgDegeneracy near-miss; ran a
genuinely broad sweep and correctly discarded 4 false-alarm candidates by checking
context rather than assuming from parameter names. Weaknesses: the fix found is
modest relative to the ~55s gap -- did not fully close it despite a thorough sweep
(stated honestly, not oversold); did not investigate whether the ~121s untimed
overhead gap is itself reducible, leaving that open for the next session.>

```handoff
session: S392
date: 2026-07-16

```handoff
session: S392
date: 2026-07-16
status: complete
self_score: 8
predecessor_score: 8
active_task: Fixed CRAN's real incoming-check rejection of the v2.0.0 resubmission
  (Windows "Overall checktime 12 min > 10 min", owner ran submit_cran() out-of-session).
  Gated the true gene-drop convergence-stress tests behind skip_on_cran(), trimmed
  guIter/nMax at verified-safe call sites, updated the ledger/backlog to reflect the
  real rejection, committed the real CRAN-SUBMISSION event, and dispatched a fresh
  win-builder Windows-devel check (results due ~11:59 AM 2026-07-16) -- DONE.
what_was_done: Fetched verbatim 00check.log for both flavors via curl (not the email
  summary) -- confirmed "Overall checktime" is a CRAN-incoming-only wall-clock summary,
  not in the check log itself; Windows tests phase [334s] dominant, examples [79s] and
  vignette-rebuild [79s] secondary. Local pkgload::load_all()-based profiling was
  initially misleading -- 3 files are rmsharp-username-gated (never run on CRAN) and
  test_pkgdown_reference_config.R skips once _pkgdown.yml is absent (confirmed
  .Rbuildignore'd); found via reading every candidate file, not assumed. skip_on_cran()
  added to 10 true convergence-stress test_that blocks across test_gvaConvergence.R (6)
  and test_gvaConvergence_kinshipOverrides.R (4); guIter 100L->20L at 23
  test_reportGV.R sites verified gu-magnitude-independent. Attempted the same trim in
  reportGV()/groupAddAssign()'s roxygen @examples -- caught a NEW checkFgDegeneracy
  warning via direct testing, reverted cleanly (git diff empty vs HEAD after
  devtools::document()). Applied that lesson test-first to vignettes/a2interactive.Rmd
  (same risk confirmed, skipped without editing) and vignettes/gvaConvergence.Rmd
  (different function, no degeneracy risk -- nMax 3000L->1600L applied, re-rendered
  clean, recommendedIter/converged/nRankable unchanged at 800/TRUE/70). Full regression:
  0 failed/0 error/0 warning in both dev mode (3895 passed) and CRAN mode (3197 passed,
  179 skipped); local CRAN-relevant test total ~70s->~43s (~38%). Updated BACKLOG.md/
  cran-comments.md/CHANGELOG.md/PROJECT_LEARNINGS.md (Learning 360)/CLAUDE.md. Three
  commits: c24b1c24 (code/test/vignette fix), 17506e34 (docs/ledger), 7043e9c1
  (CRAN-SUBMISSION event record). Dispatched devtools::check_win_devel() (owner-approved
  via AskUserQuestion, mirroring S361/S390 precedent).
next_steps: Win-builder Windows-devel results due by email ~11:59 AM 2026-07-16
  (rmsharp@me.com) -- fetch the verbatim 00check.log (not just the email), confirm the
  timing dropped with real margin and no "Overall checktime" note recurs. If still
  close to 10 min, next levers: test_appServer_server.R/test_modSummaryStats*.R/
  test_modPedigree.R (not yet investigated), or more headroom on test_reportGV.R's
  guIter=20. devtools::submit_cran() remains owner-only regardless of how clean the
  fresh run comes back.
key_files: tests/testthat/test_gvaConvergence.R (6 skip_on_cran() adds),
  tests/testthat/test_gvaConvergence_kinshipOverrides.R (4 skip_on_cran() adds),
  tests/testthat/test_reportGV.R (23 guIter sites), vignettes/gvaConvergence.Rmd:119-125,
  BACKLOG.md, cran-comments.md, CHANGELOG.md, PROJECT_LEARNINGS.md (Learning 360),
  CLAUDE.md, CRAN-SUBMISSION, HANDOFFS.md (this receipt).
gotchas: Do NOT re-attempt lowering guIter in reportGV()/groupAddAssign()'s roxygen
  examples or vignettes/a2interactive.Rmd without re-testing empirically first --
  guIter<=30 reliably triggers a NEW checkFgDegeneracy warning on that fixture
  (Learning 360b). The R CMD build . hang (Learning 360c, ~30+ min, 0.6 CPU-seconds,
  cause unresolved) persisted even with R_PROFILE_USER disabled -- devtools::
  check_win_devel()'s internal pkgbuild::build() did NOT hit it, a viable alternative
  path if a future session needs an authoritative local R CMD check --as-cran run.
runtime_smoke: n/a -- test-execution-policy/gene-drop-iteration/vignette-content
  changes only, no R/ production runtime behavior changed. Equivalent verification:
  full regression suite (0 failed/0 error/0 warning both NOT_CRAN states) + vignette
  re-render confirmed via direct HTML inspection.
changelog_ref: CHANGELOG.md 2026-07-16 "Fix real CRAN incoming-check rejection: Windows Overall checktime > 10 min (Session 392)"
commit: c24b1c24 / 17506e34 / 7043e9c1
```
<Self-score 8/10. Strengths: fetched verbatim check logs rather than trusting summaries;
read every candidate file (and grepped beyond them) before proposing edits, catching
4 false-positive files and 2 real contributors the initial profile missed; caught the
checkFgDegeneracy regression via direct empirical testing before it shipped, on both
the file where it was found the hard way and the one tested proactively afterward;
respected the 5-file blast-radius cap across 3 concern-scoped commits; posed both the
fix-strategy and win-builder-dispatch decisions via AskUserQuestion rather than
assuming scope. Weaknesses: edited+regenerated docs for the first roxygen-example trim
before testing its safety (should have tested first, as was correctly done afterward);
sank ~30 min into two R CMD build hangs before pivoting to a working profiling
alternative -- should have pivoted after the first; the build hang's true cause remains
unresolved, flagged honestly rather than presented as solved.>

```handoff
session: S391
date: 2026-07-16

```handoff
session: S391
date: 2026-07-16
status: complete
self_score: 9
predecessor_score: 10
active_task: Process win-builder x3 results (owner shared the 3 emails) and R-hub ("hillocked-veery") that S390 dispatched -- confirm the S389 .Names= NOTE is gone, fold results into cran-comments.md Sec.4 -- DONE. All environments clean. TDD Phase: N/A (build/verify/release-mechanics action, no R/tests code changed).
what_was_done: Fetched verbatim 00check.log for all 3 win-builder environments via curl (not just the email summary or an AI-summarized WebFetch) -- all three 0 errors/0 warnings/1 note, and `checking R code for possible problems ... OK` on all three, confirming S389's fix resolved the NOTE on R-devel itself. Investigated a discrepancy (only 1 URL flagged vs. cran-comments.md's prior 2) by grepping source -- PMC URL still present in DESCRIPTION:20, so its non-appearance this cycle is checker intermittency, not a fix; reported factually. Polled R-hub completion via Bash run_in_background + until-loop (single-notification wait, not Monitor). On completion, pulled actual job logs via gh run view --log (not just conclusion:success) -- all 3 platforms Status: OK (zero notes), FAIL 0 | WARN 0 | SKIP 221 | PASS 3140, confirming the S361/362 cycle's WriteXLS Windows flake (1 WARN) does not recur (consistent with S363's openxlsx migration). Folded all results into cran-comments.md (NOTE prose + Test environments), docs/planning/cran-2.0.0-phase5-runbook.md (refresh-log entry), BACKLOG.md (CRAN item), and CHANGELOG.md (new S391 entry). Two Edit calls initially failed because old_string was composed from memory rather than the file's actual text -- checked git status/diff to rule out an external edit (FM #22) before re-reading and retrying correctly. Commit: pending (lands in this close-out commit).
next_steps: The CRAN 2.0.0 pre-submission gate is now clean across every environment run this cycle (local macOS, win-builder x3, R-hub x3) -- no known outstanding technical blocker. Only remaining step is owner-only: devtools::submit_cran() (or the web form) + click the maintainer-email confirmation link -- per SAFEGUARDS and the runbook's HARD STOP, cannot be delegated to a session. Other standing items: Document 2 Phase D (READY, Effort M); LabKey remainder (BLOCKED).
key_files: cran-comments.md (NOTE prose + Test environments updated), docs/planning/cran-2.0.0-phase5-runbook.md (S390/391 refresh-log entry), BACKLOG.md (CRAN item), CHANGELOG.md (new 2026-07-16 S391 entry), HANDOFFS.md (this receipt).
gotchas: The CRAN gate is fully green everywhere it has been run -- do not re-trigger win-builder/R-hub again without a code change since the last confirmed run (would just burn external resources for no new information). PMC-URL automated-checker intermittency (flagged one cycle, absent the next) is worth a passing watch on any future win-builder run but is not a blocker -- both flagged URLs are confirmed reachable in a browser. Always fetch verbatim check logs (curl/gh run view --log) rather than trusting email/job-conclusion summaries alone -- this is how the WriteXLS-flake-resolution and the .Names=-fix-confirmation were actually verified, not assumed.
runtime_smoke: Satisfied by the deliverable itself (unlike S390) -- win-builder x3 and R-hub x3 are now both confirmed clean via verbatim log inspection, the strongest verification available short of CRAN's own review.
changelog_ref: CHANGELOG.md 2026-07-16 "Process win-builder + R-hub results for CRAN 2.0.0 gate -- fully clean (Session 391)"
commit: pending (lands in this close-out commit)
```

```handoff
session: S390
date: 2026-07-16
status: complete
self_score: 9
predecessor_score: 8
active_task: Re-trigger win-builder (devtools::check_win_devel/release/oldrelease()) and R-hub (rhub::rhub_check platforms=c("linux","windows","macos")) on current master per docs/planning/cran-2.0.0-phase5-runbook.md Sec.2-3 -- refreshes the CRAN 2.0.0 pre-submission gate (last run S361/362, now 27+ commits stale) and confirms whether S389's .Names= fix resolved the deprecated-special-names NOTE -- DONE (dispatch side; results are async). TDD Phase: N/A (build/verify/release-mechanics action, no R/tests code changed).
what_was_done: Owner picked CRAN resubmission from the Phase 0 priorities list. Checked R environment first (R 4.6.1, devtools/rhub/gitcreds all present) before posing the trigger-scope AskUserQuestion (session triggers now / owner runs themselves / hold) -- owner picked "session triggers now," mirroring S361. Claimed the session (commit cda19a67) before any technical work. Before dispatching, checked origin sync: git log origin/master..master found 5 commits ahead, git branch -r --contains 264596b6 was empty -- S389's actual .Names= fix commit was unpushed, and R-hub checks GitHub's copy of master, not local. Posed a second AskUserQuestion (push then trigger both / win-builder only, skip R-hub) since pushing is a distinct shared-state action -- owner picked "push then trigger both." git push origin master (fast-forward, 971bf3c9..cda19a67, no force). Dispatched devtools::check_win_devel()/check_win_release()/check_win_oldrelease() -- all confirmed ("results in 15-30 mins" to rmsharp@me.com). Ran rhub::rhub_doctor() (all green) then rhub::rhub_check(platforms=c("linux","windows","macos")) -- dispatched as run "hillocked-veery" (id 29473979892), confirmed in_progress via gh run list. While confirming, found an unlogged completed R-hub run "cyclopean-iguanodon" (2026-07-16 ~01:15, success) -- asked the owner directly rather than assuming; owner confirmed they triggered it themselves before S389's fix existed (informational only, mirrors the S389 check_win_devel() owner-run precedent, no CHANGELOG gap to backfill). Updated CHANGELOG.md, BACKLOG.md's CRAN item, added PROJECT_LEARNINGS.md Learning 359 (push-before-R-hub gap) and bumped CLAUDE.md's cross-reference count (358->359, Sessions 1-388+ -> 1-390+). Commit: pending (lands in this close-out commit).
next_steps: Results are NOT yet in -- check rmsharp@me.com for 3 win-builder emails (~15-30 min after ~05:30) and gh run list / https://github.com/rmsharp/nprcgenekeepr/actions for "hillocked-veery" (R-hub, historically 30-45 min). Once in: confirm the .Names= NOTE is actually gone on win-builder R-devel specifically, fold all results into cran-comments.md Sec.4 (replacing the stale S361/362 numbers), then devtools::submit_cran() + maintainer-email-confirmation-click (owner-only, HARD STOP, unchanged). Mirrors the S361->S362 trigger/process split. Other standing items: Document 2 Phase D (READY, Effort M); LabKey remainder (BLOCKED).
key_files: docs/planning/cran-2.0.0-phase5-runbook.md (read, Sec.2-3 followed), cran-comments.md (read, NOT yet updated -- awaits results), BACKLOG.md (CRAN item updated), CHANGELOG.md (new 2026-07-16 S390 entry), PROJECT_LEARNINGS.md (Learning 359), CLAUDE.md (cross-reference count), HANDOFFS.md (this receipt).
gotchas: R-hub checks the code ON GITHUB, not local working tree -- if local is ahead of origin by even one non-doc commit, R-hub silently re-tests stale code instead of erroring (see Learning 359). Always diff origin/master..master and check whether any ahead commit touches R/tests/DESCRIPTION/NAMESPACE before trusting an R-hub dispatch. Win-builder is unaffected (uploads the local tarball directly). R-hub run ids/labels: "hillocked-veery" = this session (post-fix, authoritative); "cyclopean-iguanodon" = owner's own pre-fix run, superseded, ignore its result.
runtime_smoke: Not satisfiable this session -- stated explicitly, not silently skipped. The actual verification (do the checks pass, is the .Names= NOTE gone) is asynchronous; "4 triggers dispatched without error" confirms the checks are running, not that they will pass. A follow-on session must read the actual results.
changelog_ref: CHANGELOG.md 2026-07-16 "Re-trigger win-builder + R-hub for CRAN 2.0.0 gate; push local-ahead commits (Session 390)"
commit: pending (lands in this close-out commit)
```

```handoff
session: S389
date: 2026-07-16
status: complete
self_score: 9
predecessor_score: 10
active_task: Fix tests/testthat/test_getParamDef.R:27's deprecated .Names= usage flagged by a fresh owner-run win-builder check (checking R code for possible problems NOTE) -- DONE. TDD Phase: N/A (redundant deprecated-syntax removal, no behavior change).
what_was_done: Owner ran devtools::check_win_devel() after S388 and got a new NOTE: structure(..., .Names=...) in test_getParamDef.R:27, deprecated special-name usage, an R-devel-specific check local R 4.6.1 doesn't reproduce. Read the flagged line: .Names= was redundant, since list(param=..., tokenVec=...)'s inline argument names already set those exact names. Grepped the whole R/tests/vignettes/inst tree for other occurrences; found R/data.R:337 but confirmed it's inside non-@examples roxygen prose, never parsed as code, so left untouched. Posed the fix-shape decision via AskUserQuestion (drop structure() entirely / minimal-diff rename / defer) before editing -- owner picked dropping the wrapper. Claimed the session (commit 3355dde9) before editing. Replaced structure(list(...), .Names=c(...)) with plain list(param=..., tokenVec=...) -- zero change to actual list contents. Verified: single-file test (4/4 assertions unchanged) and full regression suite (0 failed/0 error/0 warning, 3238 passed, 169 skipped baseline unchanged). Re-grepped post-fix: zero remaining .Names occurrences in live code. Updated BACKLOG.md and CHANGELOG.md, explicitly noting the fix is NOT yet confirmed against win-builder (local R can't reproduce this check). Commit: pending (lands in this close-out commit).
next_steps: Owner's call: re-trigger win-builder (devtools::check_win_devel/release/oldrelease()) to confirm this NOTE is actually resolved -- this session could not verify that locally. Also still open: R-hub re-trigger (both outward-facing, owner-scoped per S388/S361 precedent), then devtools::submit_cran() + email confirmation. Other standing BACKLOG items unchanged: Document 2 Phase D (READY, Effort M); LabKey remainder (BLOCKED).
key_files: tests/testthat/test_getParamDef.R:4-27 (fixed), BACKLOG.md (CRAN item updated), CHANGELOG.md (new 2026-07-16 S389 entry), HANDOFFS.md (this receipt).
gotchas: Local R (4.6.1, release) does not reproduce win-builder's R-devel-specific "deprecated special names in structure()" check -- a clean local R CMD check does NOT guarantee win-builder is also clean; some checks are R-devel-only. Watch for other R-devel-only findings on the next win-builder run that local checks can't catch.
runtime_smoke: n/a for application runtime (test-fixture change only, no Shiny app/service registration touched) -- satisfied instead by single-file test + full regression suite (0/0/0, 3238 passed). A full local R CMD check --as-cran would add no confirmation value since local R doesn't reproduce the specific check that flagged this NOTE; true confirmation awaits the owner's next win-builder run.
changelog_ref: CHANGELOG.md 2026-07-16 "Fix deprecated .Names= usage flagged by win-builder (Session 389)"
commit: pending (lands in this close-out commit)
```

```handoff
session: S388
date: 2026-07-16
status: complete
self_score: 9
predecessor_score: 8
active_task: Re-verify the local CRAN --as-cran gate remains clean on current master (25 commits touching R/tests/DESCRIPTION/NAMESPACE since the last confirmed run, S359 commit 19ae5657) before the owner-only devtools::submit_cran() step -- DONE. TDD Phase: N/A (build/verify action, no R/ or tests/ code changed).
what_was_done: Checked gate currency before claiming: git log 19ae5657..HEAD found 25 commits touching R/tests/DESCRIPTION/NAMESPACE since S359's last confirmed run, exceeding the 9-commit threshold that triggered a mandatory re-run at S359 itself. Owner scoped this session to local-only re-verify via AskUserQuestion. Built the tarball with R CMD build . (from the package root, so renv resolves openxlsx and the rest of the project library -- a first attempt from the scratchpad directory produced a false ERROR: Package required but not available: 'openxlsx' since R CMD check/build only activate renv from the package root). Ran R CMD check --as-cran --timings --output=<scratch-dir> from the package root: 0 errors | 0 warnings | 1 note (expected incoming-feasibility note only), timings unchanged within noise (examples 23s, tests 87s, vignette rebuild 20s, slowest example groupAddAssign 1.486s). Confirmed cran-comments.md's existing prose numbers remain accurate, no edit needed. Updated docs/planning/cran-2.0.0-phase5-runbook.md and BACKLOG.md's CRAN item with the re-verification result and the explicitly-deferred win-builder/R-hub re-trigger. Added PROJECT_LEARNINGS.md Learning 358 (renv/cwd R CMD check gotcha + CRAN-gate-staleness process gap) and updated CLAUDE.md's learnings cross-reference count (357->358). Added CHANGELOG.md 2026-07-16 S388 entry. Commit: pending (lands in this close-out commit).
next_steps: Pick from the standing BACKLOG priorities: Document 2 Phase D (READY, Effort M); LabKey integration remainder (BLOCKED -- needs a live LabKey server, Effort M); CRAN resubmission (owner-only from here -- decide whether to re-trigger win-builder/R-hub, since those results are now also 25-commits stale, then devtools::submit_cran() + email confirmation click).
key_files: docs/planning/cran-2.0.0-phase5-runbook.md (S388 refresh-log entry), BACKLOG.md (CRAN item updated), cran-comments.md (read, confirmed accurate, not modified), PROJECT_LEARNINGS.md (Learning 358), CLAUDE.md (cross-reference count), CHANGELOG.md (new 2026-07-16 S388 entry), HANDOFFS.md (this receipt). Build/check artifacts in the session scratchpad, not the repo.
gotchas: R CMD build/R CMD check must run FROM the package root for renv to activate (.Rprofile sources renv/activate.R) -- running elsewhere produces a false "Package required but not available" ERROR. Use R CMD check --output=<dir> <tarball> from the package root to keep .Rcheck artifacts out of the repo tree while renv stays active. Win-builder/R-hub results on file are still from S361/362, now also 25-commits stale -- re-triggering is outward-facing (network + GitHub token) and owner-scoped per the S361 precedent, pose via AskUserQuestion before triggering.
runtime_smoke: Satisfied by the deliverable itself -- R CMD check --as-cran installs the package, loads the namespace, runs the full example suite (23s) and full test suite (87s), and rebuilds all vignettes (20s) in a clean R session. No separate smoke test needed; this IS the runtime verification.
changelog_ref: CHANGELOG.md 2026-07-16 "Re-verify CRAN 2.0.0 local --as-cran gate on current master (Session 388)"
commit: pending (lands in this close-out commit)
```

```handoff
session: S387
date: 2026-07-15
status: complete
self_score: 9
predecessor_score: 9
active_task: Update GitHub issue #123 (XARCH-5) to reflect partial, scoped closure per docs/planning/issue123-xarch5-column-schema-plan.md Sec.10 decision 5 -- DONE. TDD Phase: N/A (GitHub issue comment, no R/ or tests/ changed). Issue left OPEN per the plan's explicit instruction.
what_was_done: Read the plan's Sec.9 impact analysis and Sec.10 decision 5 for the exact recommended framing. Checked issue #123's live state via `gh api repos/rmsharp/nprcgenekeepr/issues/123` (gh issue view fails on this repo's deprecated-projectCards GraphQL bug). Drafted a comment summarizing S386's Phase 1 implementation (commit 8a5465d8), the plan's rejection of the issue's literal S3-class recommendation (Sec.4/Sec.5), and the plan's escalation triggers (a)/(b)/(c) for revisiting it. Presented the full draft to the owner and confirmed before posting (a shared, visible-to-others action) -- approved as drafted, 0 edits. Posted via `gh issue comment 123 --body-file`: https://github.com/rmsharp/nprcgenekeepr/issues/123#issuecomment-4986749021. Verified post-hoc via gh api (state: open, comments: 1) rather than trusting the CLI's returned URL alone. Updated BACKLOG.md (pruned the completed item to a one-line pointer) and CHANGELOG.md (new 2026-07-15 S387 entry). Also broadened a personal cross-session memory (gh-pr-edit-projectcards-workaround) to note gh issue view hits the same bug -- no new PROJECT_LEARNINGS.md entry, since this is already thoroughly documented there. Commit: pending (lands in this close-out commit).
next_steps: Pick from the standing BACKLOG priorities: Document 2 Phase D (READY, Effort M); LabKey integration remainder (BLOCKED -- needs a live LabKey server, Effort M); CRAN resubmission v2.0.0 (READY, Effort S, owner-only -- devtools::submit_cran() + email confirmation click). None more urgent than another.
key_files: docs/planning/issue123-xarch5-column-schema-plan.md Sec.9/Sec.10 (read, not modified), BACKLOG.md (issue #123 item pruned), CHANGELOG.md (new 2026-07-15 S387 entry), HANDOFFS.md (this receipt), GitHub issue #123 comment (https://github.com/rmsharp/nprcgenekeepr/issues/123#issuecomment-4986749021).
gotchas: gh issue view <N> fails on this repo with the deprecated-projectCards GraphQL error (same bug as gh pr edit, see gh-pr-edit-projectcards-workaround memory and PROJECT_LEARNINGS.md); use `gh api repos/:owner/:repo/issues/<N>` instead. gh issue comment/list and gh api reads/writes are all unaffected. Issue #123 is deliberately left OPEN, not closed -- see the posted comment's escalation triggers for when to revisit the full S3 class rewrite.
runtime_smoke: n/a -- GitHub issue comment, no R/ package runtime behavior changed. Verified GitHub-side state instead (issue state: open, comments: 1, via gh api).
changelog_ref: CHANGELOG.md 2026-07-15 "Update GitHub issue #123 to reflect partial, scoped closure (Session 387)"
commit: pending (lands in this close-out commit)
```

```handoff
session: S386
date: 2026-07-15
status: complete
self_score: 9
predecessor_score: 8
active_task: Implement Phase 1 of docs/planning/issue123-xarch5-column-schema-plan.md (issue #123, XARCH-5) -- DONE. Consolidated getRequiredCols()/getPossibleCols()/getIncludeColumns() into one internal column schema + added a setdiff+stop() validator at 3 silent-drop sites. Strict TDD RED->GREEN->REFACTOR (REFACTOR declared unneeded, 0 lints), following DEVELOPMENT_WORKSTREAM.md.
what_was_done: New R/columnSchema.R (.nprcColumnSchema, @noRd) and R/assertRequiredColsPresent.R (@noRd, mirrors the tested checkKinshipOverrides() setdiff+stop idiom). getRequiredCols()/getPossibleCols()/getIncludeColumns() became one-line pass-throughs (byte-identical returns, zero exported-contract change). Validator wired at qcStudbook.R:316 and gvaConvergence.R:161 exactly per plan; reportGV.R's guard RELOCATED from the plan's literal site (before the includeCols intersect) to immediately before founders$sex (after calcFEFG()) -- the plan's site regressed test_calcFEFG.R:66, which calls reportGV() directly on lacy1989Ped, a bundled dataset with NO sex column, expecting to reach calcFEFG()'s own pre-existing partial-parentage error first. Root-caused via grep -n on current line numbers, fixed by relocation, documented as PROJECT_LEARNINGS.md Learning 357. Also implemented the plan's 2 consistency decisions (correctUnknownParentMeanKinship.R:141 swap; getPossibleCols() roxygen birth-optional fix). New tests/testthat/test_assertRequiredColsPresent.R (5 tests) + 1 new test_that each in test_reportGV.R/test_qcStudbook.R (mockery::stub contrived fault)/test_gvaConvergence.R. Verification: full suite 0 failed/0 error/0 warning, 169 skipped baseline (unchanged); 0 new lints (13 files); devtools::check() Status OK; live scripted Phase 3E smoke test confirmed. 6 AskUserQuestion gates total (3 pre-RED §10 scope decisions + PRE-RED->RED + RED->GREEN + GREEN->REFACTOR), all owner-approved, 0 stakeholder corrections. Updated BACKLOG.md, CHANGELOG.md (S386 entry), PROJECT_LEARNINGS.md Learning 357, CLAUDE.md (learnings pointer). Commit: pending (lands in this close-out commit).
next_steps: Pick from BACKLOG.md's remaining open items: LabKey integration remainder (BLOCKED, needs a live LabKey server); CRAN resubmission of v2.0.0 (READY, Effort S, owner-only: devtools::submit_cran() + email confirmation click); Document 2 Phase D (READY, Effort M). Also an owner (non-coding) follow-up: update GitHub issue #123 to partial/scoped closure per the plan's own §10 recommendation -- not done this session (external/shared-system action outside this session's approved scope).
key_files: R/columnSchema.R (new), R/assertRequiredColsPresent.R (new), R/getRequiredCols.R, R/getPossibleCols.R (body + roxygen), R/getIncludeColumns.R, R/reportGV.R (guard before founders$sex, NOT the plan's literal site), R/qcStudbook.R:316, R/gvaConvergence.R:161, R/correctUnknownParentMeanKinship.R:141, tests/testthat/test_assertRequiredColsPresent.R (new), tests/testthat/test_reportGV.R, tests/testthat/test_qcStudbook.R, tests/testthat/test_gvaConvergence.R, man/getPossibleCols.Rd (regenerated), BACKLOG.md, CHANGELOG.md (2026-07-15 S386 entry), PROJECT_LEARNINGS.md Learning 357, CLAUDE.md (learnings pointer).
gotchas: (1) reportGV()'s guard is NOT at the plan's literal cited site -- it sits immediately before founders$sex (after calcFEFG()), not before the includeCols intersect (before calcFEFG()), because test_calcFEFG.R:66 exercises reportGV() directly on the sex-less lacy1989Ped dataset expecting calcFEFG()'s own partial-parentage error first. Re-read PROJECT_LEARNINGS.md Learning 357 before touching this guard again. (2) Explicitly out of scope (plan §10, unchanged): the other 9 hardcoded column-list duplicates found during S385's research; validation at setPopulation->groupAddAssign; the half-built nprcgenekeeprGV print-method wrinkle. (3) GitHub issue #123 itself NOT updated this session (owner action, shared external system). (4) Standing items unchanged: LabKey remainder (BLOCKED); CRAN resubmission (READY, owner-only); Document 2 Phase D (READY, Effort M).
runtime_smoke: Performed, not declared N/A -- 3 new error paths added (runtime behavior change). Live scripted smoke test in a fresh pkgload::load_all() R session (not Shiny, not testthat): reportGV() on qcPed-minus-sex now errors cleanly instead of silently returning 0/0/0; qcStudbook() still throws its own pre-existing distinct error (confirming the new qcStudbook.R:316 guard is genuinely unreachable today, per Dragon 2); gvaConvergence() on a sex-less fixture now errors with the new guard's message; getRequiredCols()/getIncludeColumns() confirmed byte-identical to pre-refactor.
changelog_ref: CHANGELOG.md 2026-07-15 S386 entry
commit: 05fe2a03 (session claim); close-out commit sha pending (lands in this commit, reconciled next session per the established no-backfill-vs-reconcile pattern if this receipt-sha itself needs a follow-up fix)
```

```handoff
session: S385
date: 2026-07-15
status: complete
self_score: 8
predecessor_score: 7
active_task: Architecture plan for issue #123 (XARCH-5, string-column-keyed pipeline, no validated seam), following ARCHITECTURE_WORKSTREAM.md. Planning session only -- DONE, docs/planning/issue123-xarch5-column-schema-plan.md written and committed.
what_was_done: Ran a 35-agent background research Workflow (6 inventory readers, 24 adversarial re-verifiers, 4 alternative-design agents, 1 judge; 0 errors, 479 tool calls) that traced the full qcStudbook->setPopulation/trimPedigree->createPedTree->kinship/calcA->reportGV->groupAddAssign pipeline's actual column dependencies, found 9 additional hand-maintained column-name-vector duplicates beyond the 3 the issue names, and REPRODUCED the issue's defect by execution: reportGV() on a pedigree missing 'sex' returns successfully with no error/warning, silently corrupting nMaleFounders/nFemaleFounders/total from 3/17/20 to 0/0/0. Confirmed via grep that all 8 pipeline functions and all 3 column getters are @export'd -- no internal-only cover, so CRAN-resubmission-timing risk applies to any signature-changing alternative. Rejected the issue's literal "full S3 class" recommendation as disproportionate; adopted a scoped design: consolidate the 3 getters into one internal schema (zero exported-contract change) + an explicit setdiff+stop() validator (reusing an already-tested house idiom, checkKinshipOverrides.R) at the 2 issue-named sites plus a 3rd found during research (gvaConvergence.R:161). Judged to fit one ordinary TDD session (Effort S/M, not the originally-tagged Effort L). Independently re-read and confirmed the plan's most load-bearing citations myself before finalizing (not just trusting the workflow). Updated BACKLOG.md (issue #123: DECISION NEEDED/Effort L -> READY/Effort S/M), CHANGELOG.md (new S385 entry), PROJECT_LEARNINGS.md Learning 356, CLAUDE.md (learnings pointer). Ran full regression suite as due diligence (zero R/tests/ files changed): 0 failed/0 error/0 warning, 169 skipped baseline. Commit: pending (lands in this close-out commit).
next_steps: Implement docs/planning/issue123-xarch5-column-schema-plan.md's Phase 1 (Migration Path, section 7) -- one TDD session: new R/columnSchema.R consolidating the 3 getters, new assertRequiredColsPresent() validator wired at reportGV.R:211 (scoped to id/sex only, Dragon 1), qcStudbook.R:316, and gvaConvergence.R:161. Section 10 lists 5 open decisions for the implementing session to resolve first. Other standing items: CRAN resubmission (READY, Effort S, owner-only); Document 2 Phase D (READY, Effort M); LabKey integration remainder (BLOCKED).
key_files: docs/planning/issue123-xarch5-column-schema-plan.md (new, the deliverable -- see its own file:line citations throughout, all independently re-verified this session), BACKLOG.md (issue #123 item), CHANGELOG.md (2026-07-15 S385 entry), PROJECT_LEARNINGS.md Learning 356, CLAUDE.md (learnings pointer).
gotchas: (1) The adopted design is a SCOPED schema-consolidation-plus-validator, not the issue's literal full-S3-class ask -- follow the plan's section 7 exactly, one phase, one session. (2) Plan section 6 Dragons matter: do NOT check the full getIncludeColumns() list at the reportGV.R:211 site (origin/condition are deliberately optional -- scope to c("id","sex") only); the qcStudbook.R:316 guard's RED test needs a contrived fault, not an observed one -- say so honestly in the test comment. (3) Plan section 10 lists 5 open decisions for the implementing session (correctUnknownParentMeanKinship.R:141 inline-duplicate swap; getPossibleCols() "birth (optional)" roxygen mismatch; whether the qcStudbook.R site is worth its contrived-test cost; the half-built nprcgenekeeprGV print-method wrinkle; explicit future-direction NOT this session's work). (4) This session repeated S383's own previously-documented Phase 1B ordering slip (investigated before claiming) -- self-caught and corrected, but now a second documented instance; flagged in PROJECT_LEARNINGS as worth a future methodology look. (5) Standing items unchanged: CRAN resubmission (READY, owner-only); Document 2 Phase D (READY, Effort M).
runtime_smoke: n/a -- planning-only session, zero R/tests/ files changed, no runtime behavior to verify (same precedent as S383). Ran the full regression suite anyway as due diligence after editing docs/BACKLOG/CHANGELOG/PROJECT_LEARNINGS/CLAUDE.md: 0 failed/0 error/0 warning, 169 skipped baseline, unchanged.
changelog_ref: CHANGELOG.md 2026-07-15 S385 entry
commit: b534e08d (session claim); close-out commit sha pending (lands in this commit, will be reconciled next session per established no-backfill-vs-reconcile pattern if this receipt-sha itself needs a follow-up fix)
```

```handoff
session: S384
date: 2026-07-15
status: complete
self_score: 9
predecessor_score: 8
active_task: Deleted 18 confirmed-dead untracked files (6 flagged by S383 + 12 discovered mid-session), resolving BACKLOG.md's "clean up stale untracked leftover files" item (DONE).
what_was_done: Deleted the 6 originally-flagged files after confirming via a deeper SESSION_NOTES.md history search that PED_GV_AUDIT_2026-05-30.html had already been the subject of a full S371 policy-decision session that deleted it once before -- yet it reappeared with its ORIGINAL 2026-05-30 creation timestamp intact. Ruled out iCloud sync, active Time Machine backup, relevant local TM snapshots, ~/.Trash, and shell history as explanations; surfaced this via AskUserQuestion before proceeding. Deleting batch 1 revealed 12 MORE previously-hidden untracked files in git status (3 test files, 2 vignette-component orphans, 7 stale screenshots) that had not appeared in any earlier git status this session. Independently verified each of the 12 via git log/git show + cross-reference grep against currently-tracked files (ColonyManagerTutorial.Rmd, test_runModularApp_alias.R, tracked _breeding_group_*.Rmd siblings) before proposing deletion via a second AskUserQuestion; owner approved. Deleted all 12. Full regression suite re-run clean after both batches (0 failed/0 error/0 warning, 169 skipped baseline). Updated BACKLOG.md, CHANGELOG.md (2026-07-15 entry, both batches + open resurrection question), PROJECT_LEARNINGS.md Learning 355, CLAUDE.md (learnings pointer). Commit: pending (lands in this close-out commit).
next_steps: Pick from BACKLOG.md's remaining open items: CRAN resubmission (READY, Effort S, owner-only: devtools::submit_cran() + email confirmation click); Document 2 Phase D (READY, Effort M); LabKey integration remainder (BLOCKED, needs a live LabKey server); issue #123/XARCH-5 (DECISION NEEDED, needs its own planning session).
key_files: BACKLOG.md (Housekeeping item resolved), CHANGELOG.md (2026-07-15 S384 entry with full per-file provenance), PROJECT_LEARNINGS.md Learning 355, CLAUDE.md (learnings pointer). 18 files deleted, none tracked by git -- see CHANGELOG.md entry for the full list.
gotchas: (1) PED_GV_AUDIT_2026-05-30.html and several R/tests/vignettes files independently reappeared as untracked cruft across multiple past sessions despite verified prior deletions (some via real git rm commits) -- if this happens again, it's a KNOWN recurring pattern (see PROJECT_LEARNINGS.md Learning 355 for what's been checked and ruled out: iCloud, Time Machine, Trash, shell history, git untracked-cache config), not a fresh anomaly needing re-diagnosis from zero. (2) Always re-run git status after any deletion pass on this repo -- removing one batch of untracked files can reveal another. (3) Standing items unchanged: CRAN resubmission (READY, owner-only); Document 2 Phase D (READY, Effort M); LabKey integration remainder (BLOCKED); issue #123/XARCH-5 (DECISION NEEDED).
runtime_smoke: Performed, not declared N/A -- full regression suite re-run after both deletion batches: 0 failed/0 error/0 warning, 169 skipped baseline unchanged. Meaningful because untracked test files for now-deleted dead functions were being silently run by testthat::test_dir() alongside their untracked source files before this cleanup.
changelog_ref: CHANGELOG.md 2026-07-15 S384 entry
commit: 875983f5 (session claim), 3b313a7b (close-out: delete files + docs + ledger + learnings + backlog); receipt-sha reconcile done in two commits (4b0e5131, then this fix) after a self-caught ordering slip -- 4b0e5131 landed before this sha field was actually filled in
```

```handoff
session: S383
date: 2026-07-15
status: complete
self_score: 9
predecessor_score: 8
active_task: Resolved BACKLOG.md's "setLabKeyDefaults()/getDemographics() unguarded getSiteInfo() call sites" DECISION NEEDED item (split off S382). Decision: decline, no code change (DONE).
what_was_done: Traced getDemographics()'s real callers (R/getLkDirectAncestors.R:46, R/getPedigreeSource.R:103) and found both already wrap the ENTIRE getDemographics(...) call in tryCatch(warning=,error=)->NULL, so a getSiteInfo() error thrown inside it already propagates out and is already caught today. setLabKeyDefaults()'s own getSiteInfo() default arg is dead code in-package (its sole caller always passes siteInfo explicitly); its @examples already show external callers wrapping the whole call. Posed a 3-option pre-RED scope AskUserQuestion (decline / make getSiteInfo() defensive / wrap locally anyway); owner picked decline. No RED/GREEN/REFACTOR gates -- no implementation written. Self-caught and corrected a Phase 1B ordering slip (investigated before claiming the session) mid-session. Discovered and flagged (untouched) 6 untracked leftover files from past dead-code-removal sessions, filed as a new BACKLOG Housekeeping item. Updated BACKLOG.md, CHANGELOG.md (2026-07-15 entry), PROJECT_LEARNINGS.md Learning 354, CLAUDE.md (learnings pointer). Commit: pending (lands in this close-out commit).
next_steps: Pick from BACKLOG.md's remaining open items: new Housekeeping item (untracked leftover files, READY, Effort S); CRAN resubmission (READY, Effort S, owner-only: devtools::submit_cran() + email confirmation click); Document 2 Phase D (READY, Effort M); LabKey integration remainder (BLOCKED, needs a live LabKey server); issue #123/XARCH-5 (DECISION NEEDED, needs its own planning session).
key_files: R/getSiteInfo.R (read only), R/setLabKeyDefaults.R:44 (read only), R/getDemographics.R:39 (read only), R/getLkDirectAncestors.R:46, R/getPedigreeSource.R:103 (read -- existing outer guards), BACKLOG.md (item resolved, new Housekeeping item), CHANGELOG.md (2026-07-15 S383 entry), PROJECT_LEARNINGS.md Learning 354, CLAUDE.md (learnings pointer).
gotchas: (1) The getSiteInfo() design-decision BACKLOG item is CLOSED -- do not reopen or re-derive; reasoning is in CHANGELOG.md 2026-07-15 / Learning 354. (2) General pattern for any future "unguarded call site" item: trace the ENCLOSING function's real callers before scoping a fix -- R's error propagates to the FIRST enclosing tryCatch, wherever it lives; a line with no LOCAL tryCatch can still be fully protected by an OUTER one. (3) 6 untracked leftover files (R/agePyramidPlot.R, R/fixGenotypeCols.R, R/getSimSires.R, R/makeGeneticDiversityDashboard.R, PED_GV_AUDIT_2026-05-30.html, inst/_pkgdown.yml) left untouched on disk, filed as a new BACKLOG Housekeeping item -- verify each is genuinely superseded before deleting. (4) Standing items unchanged: CRAN resubmission (READY, owner-only); Document 2 Phase D (READY, Effort M); LabKey integration remainder (BLOCKED); issue #123/XARCH-5 (DECISION NEEDED).
runtime_smoke: n/a -- decision-only, zero R/tests/ files changed, no runtime behavior to verify.
changelog_ref: CHANGELOG.md 2026-07-15 S383 entry
commit: cbe89ef5 (session claim), 4490fb26 (close-out: decision + docs + ledger + learnings + backlog)
```

```handoff
session: S382
date: 2026-07-14
status: complete
self_score: 9
predecessor_score: 9
active_task: Guarded the 2 of BACKLOG.md's "4 remaining unguarded getSiteInfo() call sites" that have an existing local fail-soft pattern to mirror (R/getPedigreeSource.R:83, R/getLkDirectAncestors.R:26). The other 2 (setLabKeyDefaults.R:44, getDemographics.R:39) are split off into a new, separately-scoped BACKLOG.md item (DONE).
what_was_done: Read getSiteInfo() and its parsing helpers directly, confirming it genuinely can throw on a present-but-malformed config file (distinct from a missing file, which only warns and falls back to defaults). Found getPedigreeSource.R:83 and getLkDirectAncestors.R:26 each have an adjacent getDemographics() call already tryCatch-guarded to NULL in the same function -- getPedigreeSource()'s own docstring already promises NULL on fetch failure, a contract its unguarded getSiteInfo() call was silently breaking. setLabKeyDefaults.R:44/getDemographics.R:39 have no local pattern to mirror and both functions' docs describe "let it throw" as intended -- split off as a new BACKLOG item requiring a real design decision. Posed a pre-RED scope AskUserQuestion (4 options); owner picked "guard the 2 mirrorable sites." PRE-RED->RED gate surfaced a refinement: the guard must catch error only, not warning, since getSiteInfo()'s missing-config warning is an intentional non-failure and getLkDirectAncestors.R's own existing test asserts it propagates -- a naive full mirror of the adjacent warning=,error= pattern would have silently regressed it. RED: added 1 test to test_getLkDirectAncestors.R, 2 to test_getPedigreeSource.R (error case + warning-still-propagates regression lock); confirmed exactly 1 new failure per file against unmodified source. GREEN: implemented both tryCatch(error=) guards (flog.debug+stri_c+NULL fallback, mirroring the adjacent getDemographics guard's shape but narrowed to error only). Target files pass; full suite 0 failed/0 error/0 warning (169 skipped baseline); devtools::check() 0/0/0 (3m18s); lintr 0 lints on all 4 changed files; grep-confirmed the 2 out-of-scope sites untouched. GREEN->REFACTOR gate: declared unneeded (minimal, already-idiomatic, 0 lints). Phase 3E: built a REAL malformed config file (missing "center", reusing test_appUI_siteinfo.R's established fixture) and called both real (unmocked) functions -- both returned NULL cleanly, no uncaught error; also re-confirmed the real missing-config warn-and-continue path still propagates and completes unchanged. Updated BACKLOG.md (2 sites resolved, new item filed for the remaining 2). Wrote PROJECT_LEARNINGS.md Learning 353. Commit: pending (lands in this close-out commit).
next_steps: Pick from BACKLOG.md's remaining open items: the new "setLabKeyDefaults()/getDemographics() getSiteInfo() design decision" item (DECISION NEEDED, Effort S-M, needs a real design decision -- make getSiteInfo() itself defensive vs. give these 2 functions a new fail-soft contract, NOT a copy of this session's mirrored-guard fix shape); CRAN resubmission (READY, owner-only); Document 2 Phase D (READY, Effort M); LabKey integration remainder (BLOCKED, needs a live LabKey server); issue #123/XARCH-5 (DECISION NEEDED, needs its own planning session).
key_files: R/getLkDirectAncestors.R:26-38 (new tryCatch(error=) guard), R/getPedigreeSource.R:82-99 (same guard shape), tests/testthat/test_getLkDirectAncestors.R (+1 test), tests/testthat/test_getPedigreeSource.R (+2 tests), CHANGELOG.md (2026-07-14 S382 entry), BACKLOG.md (2 sites marked resolved, new design-decision item filed for the remaining 2), PROJECT_LEARNINGS.md Learning 353, CLAUDE.md (learnings-count pointer refreshed to 353).
gotchas: (1) The remaining 2 getSiteInfo() sites now stand as their OWN BACKLOG.md item -- a genuine design decision, not a copy of this session's fix shape. (2) getSiteInfo()'s two failure branches are NOT symmetric: missing config WARNS and falls back to usable defaults (not a failure, must propagate); malformed-but-present config THROWS (a real failure). Any future getSiteInfo() guard must catch error only, never warning. (3) The real malformed-config-file fixture recipe (HOME env var override + config file missing the center key) is established in test_appUI_siteinfo.R/test_appServer_server.R -- reused here for Phase 3E. (4) Standing items unchanged: CRAN resubmission (READY, owner-only); Document 2 Phase D (READY, Effort M); LabKey integration remainder (BLOCKED); issue #123/XARCH-5 (DECISION NEEDED).
runtime_smoke: Performed, not declared N/A -- built a real (non-mocked) malformed config file and called both fixed functions directly: both returned NULL cleanly, no uncaught error, proof against the actual getTokenList/getParamDef parsing failure rather than a synthetic simulated one. Also re-confirmed the real missing-config warn-and-continue path is unbroken.
changelog_ref: CHANGELOG.md 2026-07-14 S382 entry
commit: 748cacb6 (session claim), 4f67e094 (close-out: fix + tests + ledger + learnings + backlog)
```

```handoff
session: S381
date: 2026-07-14
status: complete
self_score: 9
predecessor_score: 7
active_task: Fixed BACKLOG.md's "stale system-library openxlsx gap blocking full-browser-stability shinytest2::AppDriver checks" item (filed S380). Root-cause investigation found the item's own diagnosis was wrong: the stale copy was in the renv project library, not any system library (DONE).
what_was_done: RED reproduced the exact documented modBreedingGroupsServer: unused argument (kinshipMatrix = ...) failure via the S378-380 shiny.appobj-direct-pass AppDriver recipe. Before applying the prescribed fix, introspected WHERE the stale copy actually lived via loadNamespace(lib.loc=...) + args() against each candidate library rather than trusting the inherited diagnosis: the R 4.6.1 system library (/Library/Frameworks/R.framework/Versions/4.6/Resources/library) has neither nprcgenekeepr nor openxlsx installed at all (R upgraded 2026-07-09); the RENV PROJECT library's installed nprcgenekeepr copy (v2.0.0) had the exact stale signature, missing kinshipMatrix entirely (pre-issue-#122-Phase-2). Surfaced this correction via the RED->GREEN AskUserQuestion gate; owner approved fixing the renv library instead. Applied R CMD INSTALL --library=<renv project library> . (renv::install(".") failed first with a cp-into-itself error from its own renv/staging/ nesting; plain R CMD INSTALL avoids this). Verified: reinstalled copy's args() now shows kinshipMatrix; re-ran the IDENTICAL RED script -- construction succeeded, set_inputs(mainNavbar="Breeding Groups") + wait_for_idle() succeeded, tab confirmed active. Full regression suite re-run clean (0 failed/0 error/0 warning, 169 skipped baseline, unaffected -- no R/tests source changed); pre-existing directory-based E2E suite (test-e2e-breeding-groups-module.R) passed 7/7 both before and after (an open question, not chased further -- see gotchas); .libPaths() ordering unaffected. No refactor applicable (0 source lines changed). Pruned the resolved BACKLOG.md item. Wrote PROJECT_LEARNINGS.md Learning 352 (3 sub-findings). Commit: pending (lands in this close-out commit).
next_steps: Pick from BACKLOG.md's remaining open items: the standalone "4 remaining unguarded getSiteInfo() call sites (LabKey-fetch)" item (DECISION NEEDED, Effort S, needs its own re-scoping session); CRAN resubmission (READY, owner-only); Document 2 Phase D (READY, Effort M); LabKey integration remainder (BLOCKED, needs a live LabKey server); issue #123/XARCH-5 (DECISION NEEDED, needs its own planning session).
key_files: None in R/ or tests/ (pure environment fix). The renv project library at ~/Library/Caches/org.R-project.R/R/renv/library/nprcgenekeepr-229b003c/macos/R-4.6/aarch64-apple-darwin23 was reinstalled from current source. CHANGELOG.md (2026-07-14 S381 entry), BACKLOG.md (resolved item removed), PROJECT_LEARNINGS.md Learning 352, CLAUDE.md (learnings-count pointer refreshed to 352).
gotchas: (1) The R system library still has neither nprcgenekeepr nor openxlsx installed -- fine and expected now; only relevant if a future ad-hoc verification script bypasses renv entirely. (2) Open mechanistic question (Learning 352(c)): the directory-based E2E harness passed cleanly even while the renv library was stale, while the shiny.appobj-direct-pass route failed -- shinytest2 printed an "Overriding library()/require() to load local package" message only for the latter route; not chased further, relevant to a future shinytest2-internals investigation. (3) To reinstall this package's own source into one of its own project libraries, use R CMD INSTALL --library=<path> . directly, not renv::install(".") -- the latter fails with a cp-into-itself error on this project's layout. (4) Standing items unchanged: 4 remaining getSiteInfo() LabKey-fetch sites (DECISION NEEDED); CRAN resubmission (READY, owner-only); Document 2 Phase D (READY, Effort M); LabKey integration remainder (BLOCKED); issue #123/XARCH-5 (DECISION NEEDED).
runtime_smoke: Performed, not declared N/A -- this session's entire deliverable IS a runtime-environment fix, so its own GREEN verification (the live shinytest2::AppDriver reproduce-then-fix pair, construction + interaction level) serves as Phase 3E directly; the pre-existing directory-based E2E suite was also re-confirmed passing post-fix as a collateral-effect check.
changelog_ref: CHANGELOG.md 2026-07-14 S381 entry
commit: 3be1092d (session claim), 2963f489 (close-out: docs, ledger, learnings, backlog prune -- no R/tests source changed this session)
```

```handoff
session: S380
date: 2026-07-14
status: complete
self_score: 9
predecessor_score: 9
active_task: Guarded the 3 lower-severity unguarded getSiteInfo() call sites scoped this session (R/modORIPReporting.R:148,244 dead-code else branch; R/appServer.R:124 Debug-checkbox observer) -- non-LabKey subset of BACKLOG.md's "4 lower-severity unguarded getSiteInfo() call sites" item (DONE). The 4 LabKey-fetch sites stand alone as their own DECISION-NEEDED BACKLOG.md item, exactly as that item's own text required.
what_was_done: R/modORIPReporting.R:148/244: wrapped both else-branch getSiteInfo(expectConfigFile = FALSE) calls in tryCatch (flog.warn on error, NULL fallback), mirroring appServer.R's/appUI.R's established pattern; existing is.null(config) checks downstream already fail closed. R/appServer.R:122-152: wrapped the Debug-checkbox observer's getSiteInfo() call in tryCatch; on error, logs via flog.warn and skips file-appender registration entirely (fails closed to whatever logging destination is already active). Strict TDD RED->GREEN (REFACTOR declared unneeded, 0 lints), 1 pre-RED AskUserQuestion scope decision (the BACKLOG item bundles 3 heterogeneous classes; owner picked "dead code + observer only") plus the 3 phase gates. 3 new tests: 2 in test_modORIPReporting_server.R, 1 in test_appServer_logging.R (expect_no_warning, not expect_no_error, per Learning 347(d)'s empirically-confirmed condition class). Found and fixed an unrelated pre-existing test-isolation gap: futile.logger's process-global registry carried a stale file appender from an earlier test's deleted withr::local_tempdir(), making the ALREADY-FIXED ORIP-gate guard's own flog.warn() throw for a reason unrelated to the code under test -- fixed by resetting the logger to console at the top of the new test. Also fixed a pre-existing stale header comment ("Both tests...") in test_appServer_logging.R while already editing that file. Verification: target files 14/14 and 4/4 passed; full suite 3225 passed/169 skipped/0 failed/0 error/0 warning; devtools::check() 0/0/0; lintr 0/0 on all 4 changed files; grep confirmed the 4 LabKey-fetch sites untouched. Phase 3E: two modORIPReporting.R sites are dead code (no live check possible/needed); appServer.R:124 is live-reachable, live shinytest2::AppDriver attempted (malformed config + Debug-checkbox toggle) -- boot proceeded correctly past the malformed-config ORIP gate (WARN log line confirmed) but failed to stabilize before the checkbox interaction could fire, on the SAME modBreedingGroupsServer stale-system-library signature Learnings 349(d)/350 documented (3rd occurrence, now blocking interaction not just construction) -- recognized by signature match, testServer() coverage treated as the sufficient ceiling per Learning 349(d)'s own rule. Pruned BACKLOG.md's 3 resolved sites; filed a new BACKLOG.md item for the recurring openxlsx/modBreedingGroupsServer environment gap (3 independent sessions now). Wrote PROJECT_LEARNINGS.md Learning 351 (3 sub-findings). Commit: pending (lands in this close-out commit).
next_steps: Pick from BACKLOG.md's remaining open items: the standalone "4 remaining unguarded getSiteInfo() call sites (LabKey-fetch)" item (DECISION NEEDED, Effort S, needs its own re-scoping session -- do not treat as a simple continuation of this session's pattern); the new "openxlsx/modBreedingGroupsServer stale-system-library" infra item (READY, Effort S, would unblock full browser-stability AppDriver checks for future runtime-facing fixes); CRAN resubmission (READY, owner-only); Document 2 Phase D (READY, Effort M); LabKey integration remainder (BLOCKED, needs a live LabKey server); issue #123/XARCH-5 (DECISION NEEDED, needs its own planning session).
key_files: R/modORIPReporting.R:143-165,249-282 (siteInfo renderer + downloadORIPReport else-branch guards), R/appServer.R:122-152 (debug-log observer guard), tests/testthat/test_modORIPReporting_server.R (+2 tests), tests/testthat/test_appServer_logging.R (+1 test, +stale-header-comment fix), CHANGELOG.md (2026-07-14 S380 entry), BACKLOG.md (3 resolved sites removed, 4-LabKey-site item standing alone, new openxlsx infra item), PROJECT_LEARNINGS.md Learning 351, CLAUDE.md (learnings-count pointer refreshed to 351).
gotchas: (1) The getSiteInfo() inventory is now down to exactly the 4 LabKey-fetch sites (getLkDirectAncestors.R:26, setLabKeyDefaults.R:44, getPedigreeSource.R:83, getDemographics.R:39) -- marked DECISION NEEDED, needs its own re-scoping session, not a copy of this session's fix shape. (2) The modBreedingGroupsServer/openxlsx stale-system-library gap has now blocked live AppDriver verification in 3 independent sessions (S378/S379/S380) -- filed as its own BACKLOG.md item; fixing it would unblock full browser-stability checks broadly, not just this bug class. (3) futile.logger's "nprcgenekeepr" logger is process-global -- any NEW test exercising a flog.warn/flog.info call site should explicitly reset the logger to console at its own start, not assume a clean starting state left by whatever test ran before it. (4) Standing items unchanged: CRAN resubmission (READY, owner-only); Document 2 Phase D (READY, Effort M); LabKey integration remainder (BLOCKED); issue #123/XARCH-5 (DECISION NEEDED).
runtime_smoke: Performed, not declared N/A -- dead-code sites correctly need no live check; the one live-reachable site (appServer.R:124) got a genuine live AppDriver attempt producing partial positive evidence (malformed-config boot proceeds correctly up to a known, unrelated, already-documented environment wall) before hitting that wall -- recognized by signature match (3rd occurrence), not re-diagnosed as a new regression. testServer() coverage (already GREEN, using the exact condition class Learning 347(d) established) is the documented-sufficient ceiling per Learning 349(d)'s own practical rule, not silently treated as equivalent to a full live pass.
changelog_ref: CHANGELOG.md 2026-07-14 S380 entry
commit: c20ce977 (session claim), 7be35ed4 (implementation + tests, 4 files), 62f74e21 (ledger + learnings, 3 files), pending (close-out, lands in this commit)
```

```handoff
session: S379
date: 2026-07-14
status: complete
self_score: 9
predecessor_score: 9
active_task: Guarded R/appUI.R:20's unprotected getSiteInfo() default-argument call (DONE). This closes the appServer.R/appUI.R sibling-bug pair from the issue #50 crash class. Follow-up filed: BACKLOG.md "4 lower-severity unguarded getSiteInfo() call sites" (S378's severity-graded inventory, now standing on its own).
what_was_done: R/appUI.R: changed appUI <- function(siteInfo = getSiteInfo(expectConfigFile = FALSE)) to siteInfo = NULL, resolved via a body-level tryCatch mirroring appServer.R's exact pattern (futile.logger::flog.warn on error, fall back to NULL); guarded showOrip with !is.null(siteInfo) && so a NULL fallback fails closed instead of crashing file.exists(NULL); updated the @param roxygen doc; devtools::document() regenerated man/appUI.Rd. Applied BACKLOG.md's fully-specified fix shape and RED test recipe verbatim (filed by S378); added a second RED test (fails-closed ORIP-tab-absence assertion). Strict TDD RED->GREEN (REFACTOR declared unneeded, 0 lints), 2 AskUserQuestion phase gates (no pre-RED scope decision needed -- fix shape had no open alternative). Verification: target file 2/2 passed; test_appUI_version.R regression 3/3 passed; full suite 3217 passed/169 skipped/0 failed/0 error/0 warning; devtools::check() (plain and --no-manual variants) both 0/0/0; lintr 0/0; grep confirmed explicit-siteInfo callers (test_modORIPReporting.R) unaffected. Phase 3E live shinytest2::AppDriver boot: shinyApp(ui = appUI(), server = appServer) construction against a malformed config succeeded without crashing (the exact point that crashed pre-fix); WARN log line confirmed the tryCatch guard fired. Subsequent AppDriver browser-stability check hit the exact, already-documented Learning 349(d) modBreedingGroupsServer stale-system-library signature -- recognized by match, not re-diagnosed. Pruned BACKLOG.md per [[backlog-vs-changelog-placement]]: removed both the appServer.R and appUI.R resolved items entirely (rather than leaving RESOLVED status lines), re-filed the still-open 4-site inventory as its own standalone item. Wrote PROJECT_LEARNINGS.md Learning 350 (2 sub-findings). Commit: pending (lands in this close-out commit).
next_steps: No immediate follow-up required for THIS bug class -- the appServer.R/appUI.R sibling pair is fully resolved. Pick from BACKLOG.md's remaining open items: the standalone "4 lower-severity unguarded getSiteInfo() call sites" item (READY, Effort S, lowest of the four internally but still open); CRAN resubmission (READY, owner-only); Document 2 Phase D (READY, Effort M); LabKey integration remainder (BLOCKED, needs a live LabKey server); issue #123/XARCH-5 (DECISION NEEDED, needs its own planning session).
key_files: R/appUI.R:4-51 (roxygen @param + the fix), man/appUI.Rd (regenerated), tests/testthat/test_appUI_siteinfo.R (new, 2 tests), CHANGELOG.md (2026-07-14 S379 entry), BACKLOG.md (both getSiteInfo()-pair items removed, replaced with the standalone 4-site item), PROJECT_LEARNINGS.md Learning 350, CLAUDE.md (learnings-count pointer refreshed to 350).
gotchas: (1) The appServer.R/appUI.R sibling-bug pair (issue #50 crash class) is now FULLY resolved -- don't re-open either without re-confirming against current source first. (2) The [e2e-subprocess-lib]/Learning 349(d) modBreedingGroupsServer staleness trap (missing openxlsx in the system library) is STILL unfixed -- any future live AppDriver check needing full browser-stability confirmation will hit it again; fixing it is its own small infrastructure task. (3) NOT_CRAN=true is still needed even OUTSIDE test_that() for a live shinytest2/chromote check (Learning 349(c), re-confirmed). (4) BACKLOG.md hygiene: close out a completed item by REMOVING it, not by leaving a "RESOLVED S<N>" status line -- per [[backlog-vs-changelog-placement]] (user-flagged twice); this session had to self-correct an initial draft that repeated S378's own non-compliant precedent.
runtime_smoke: Performed, not declared N/A -- live shinytest2::AppDriver boot with a malformed config confirmed the exact point that crashed pre-fix (shinyApp construction) now succeeds, with a WARN log line as direct positive evidence the guard fired. The subsequent browser-stability sub-check hit an unrelated, already-documented environment issue (Learning 349(d)) -- same limitation S378 hit on its second check, not a new finding.
changelog_ref: CHANGELOG.md 2026-07-14 S379 entry
commit: b9ccf98e (implementation + tests, 3 files), 9dc9ec20 (ledger + learnings, 3 files)
```

```handoff
session: S378
date: 2026-07-14
status: complete
self_score: 9
predecessor_score: 8
active_task: Guarded R/appServer.R:347's unprotected getSiteInfo() call (DONE, scoped to appServer.R). A live Phase 3E check found appUI.R:20 has an independent, identical unguarded getSiteInfo() default-argument call that still crashes app boot on a malformed config -- owner chose to file it separately (new BACKLOG.md item, ready to pick up) rather than expand this session's scope.
what_was_done: R/appServer.R: wrapped the getSiteInfo(expectConfigFile = FALSE) call in tryCatch mirroring loadSiteConfig()'s pattern (log via futile.logger::flog.warn, fall back to NULL); guarded the shouldShowOripTab() call with !is.null(oripSiteInfo) && so the NULL fallback fails closed instead of crashing file.exists(NULL); reused the single parsed value for the siteConfig reactive instead of a second getSiteInfo() call; added flog.warn to the existing @importFrom roxygen line (NAMESPACE unchanged, already present via loadSiteConfig.R). Added 2 tests to tests/testthat/test_appServer_server.R (section 6b). Strict TDD RED->GREEN (REFACTOR declared unneeded), 1 pre-RED AskUserQuestion scope decision (rejected a "reuse shared$config" alternative -- verified non-viable due to Shiny observe/flush timing) plus the 3 phase gates. Live Phase 3E AppDriver boot (shiny.appobj passed directly, NOT_CRAN=true) found appUI.R's sibling bug -- surfaced via AskUserQuestion, owner chose narrower scope; corrected the appServer.R comment's overclaim and filed a precise BACKLOG.md item (with a grep inventory of 4 more lower-severity unguarded getSiteInfo() sites). Verification: target file 27/27 passed; full suite 3215 passed/169 skipped/0 failed/0 error/0 warning; devtools::check() 0/0/0; lintr 0/0. Wrote PROJECT_LEARNINGS.md Learning 349 (4 sub-findings). Commit: pending (lands in this close-out commit).
next_steps: Pick up the new BACKLOG.md item "Unprotected getSiteInfo() call in appUI.R's default argument" -- fix shape and a ready-to-run RED test are already spelled out there. Before starting, re-grep getSiteInfo(` across R/ to confirm the inventory hasn't changed. Other standing items unchanged: CRAN resubmission (READY, owner-only); Document 2 Phase D (READY, Effort M); issue #123/XARCH-5 (DECISION NEEDED, needs its own planning session).
key_files: R/appServer.R:38-39 (new @importFrom flog.warn), R/appServer.R:346-373 (the fix + corrected comment), tests/testthat/test_appServer_server.R (new section 6b, 2 tests), BACKLOG.md (appServer.R item resolved, new appUI.R item + 4-site inventory), PROJECT_LEARNINGS.md Learning 349.
gotchas: (1) appUI.R:20's identical bug is the next pickup, already scoped in BACKLOG.md. (2) A live shinytest2/chromote check needs NOT_CRAN=true even OUTSIDE test_that() -- an ad-hoc script fails with a bare "Reason: On CRAN" otherwise. (3) AppDriver$new() accepts a shiny.appobj directly (no system-library install needed) for a "does it crash" check, but the subprocess can still resolve STALE code for functions the passed object calls by name -- not reliable for wiring/signature regressions here (the system library is missing openxlsx, added S363, so R CMD INSTALL there currently fails; a separate concern, not fixed this session).
runtime_smoke: Performed, not declared N/A -- live shinytest2::AppDriver boot with a malformed config found the appUI.R gap (the actual point of doing this). A second live check (valid-config regression) was inconclusive due to an unrelated, pre-existing e2e-subprocess-staleness issue; happy path verified indirectly (unchanged code + existing passing testServer() coverage).
changelog_ref: CHANGELOG.md 2026-07-14 S378 entry
commit: 8bd90042 (implementation + tests, 2 files), 31b49d34 (ledger + learnings, 3 files)
```

```handoff
session: S377
date: 2026-07-14
status: complete
self_score: 9
predecessor_score: 8
active_task: Issue #122 module-contract plan Phase 5 DONE. Issue #122 (XARCH-2) fully resolved -- all 5 phases complete. GitHub issue #122 itself not yet closed (flagged for owner).
what_was_done: Wrote docs/architecture/module-contract.md (the section-4.4 contract as a living standards doc, house-styled on docs/conventions/ROXYGEN_EXAMPLES_POLICY.md; cites modInput as the reference implementation; documents 2 deliberate exceptions -- modGvAndBgDescServer's bare NULL, and gestationTable's bare-reactiveValues read into modPotentialParentsServer per Dragon 4). Added tests/testthat/test_moduleContract.R, a guard test exercising all 10 mod*Server functions via shiny::testServer() with args mirroring appServer.R's real call sites, asserting a named-list-of-functions shape for 9 modules plus the declared NULL exception for the 10th; proved non-vacuity with an explicit negative control (3 broken stand-ins, all caught). Added modInputServer's @note roxygen citation; devtools::document() standalone (only man/modInputServer.Rd regenerated). Classified PRE-RED->REFACTOR (not RED->GREEN): firsthand verification of all 10 modules found everything already compliant before any edit -- modInput's 2 plan-cited defects were already fixed by S376's own Phase 4 work as a side effect, without S376 or the plan's blockquote realizing this cleared Phase 5's stated prerequisite. Also fixed a .gitignore gap (docs/* blanket-ignore with a per-subdirectory allowlist that didn't include docs/architecture/, which silently dropped the new doc from git status). Pruned BACKLOG.md's issue #122 section to a resolved pointer. Full suite 3870 passed/0/0/0/167 skipped (3802 baseline + 68 new); devtools::check() 0/0/0; lintr 0/0 on changed files. Commit: pending (this receipt lands in the same close-out commit).
next_steps: Pick the next BACKLOG item: unprotected getSiteInfo() call at appServer.R:347 (READY, Effort S); issue #123/XARCH-5 (DECISION NEEDED, needs its own planning session, Effort L); CRAN resubmission (READY, owner-only action, nothing left for an agent); Document 2 Phase D (READY, Effort M). Consider whether to close GitHub issue #122 (XARCH-2) now that all 5 plan phases are DONE -- this session deliberately did not close it unilaterally (visible action on a shared system).
key_files: docs/architecture/module-contract.md (new), tests/testthat/test_moduleContract.R (new), R/modInput.R:265-269 (new @note roxygen block), man/modInputServer.Rd (regenerated), .gitignore:47-48 (new docs/architecture/ allowlist exception).
gotchas: (1) Issue #122 GitHub issue itself is NOT closed -- only the BACKLOG.md tracking is resolved; ask the owner before closing the actual GitHub issue. (2) Any NEW docs/<topic>/ subdirectory added in a future session will hit the same .gitignore trap this session found (docs/* blanket-ignored, per-subdirectory allowlist) unless also added to .gitignore's allowlist -- check with `git status --short <new-dir>/` right after creating it. (3) A background research fork returned a result unrelated to the prompt this session (single unrelated sentence after ~157s) -- do not trust or extrapolate from a fork result that doesn't answer what was asked; redo directly instead.
runtime_smoke: N/A, declared explicitly -- no runtime behavior changed (docs + a new test file only; roxygen @note is a documentation-only comment). Matches the project's CRAN-Phase-1-metadata precedent for docs/test-only sessions.
changelog_ref: CHANGELOG.md 2026-07-14 S377 entry
commit: 044f998b (implementation, 5 files), b6e264ba (BACKLOG.md)
```

```handoff
session: S376
date: 2026-07-13
status: complete
self_score: 9
predecessor_score: 9
active_task: Issue #122 module-contract plan Phase 4 DONE. Phase 5 (contract note + guard test) next -- see BACKLOG.md.
what_was_done: Removed the dead config param from modInputServer/modPedigreeServer + appServer.R call-site args (kept shared$config <- loadSiteConfig() at boot); deleted the dead shared$qcResults write; replaced appServer's blanket tryCatch(..., error = function(e) NULL) swallow with req() at cleanedStudbook/qcSummary observers and a narrowed tryCatch(shiny.silent.error = function(e) NULL) for changedCols (preserving independence from errorLst/fileName in the same observer); documented modInputServer's 4 previously-undocumented @return elements. Skipped the plan's item 3 (modSummaryStats' "12 unread reactives") entirely -- found ~53 active testServer()$getReturned() assertion sites across 4 test files proving the plan's premise false. Site-config delete-vs-wire decision resolved to delete-threading-only via 3 converging checks (source inspection, independent call-graph tracing, an existing test proving behavioral inertness). Strict TDD RED (9 files) -> GREEN -> REFACTOR (no-op, confirmed clean). Full suite 3802 passed/0/0/0/167 skipped; devtools::check() 0/0/0; lintr 0 lints across 14 changed files. Phase 3E: NPRC_RUN_E2E=true across 7 e2e files, 48/48 passing. Surfaced (not fixed, new BACKLOG item) an unrelated unprotected getSiteInfo() call at appServer.R:347. Commits fb9e0b5c (source+docs, 5 files), ecdda66b (modInput tests, 5 files), 4b461527 (modPedigree tests, 3 files), 03bfce99 (contract-guard tests, 3 files).
next_steps: Execute Phase 5 of docs/planning/issue122-module-contract-plan.md -- write docs/architecture/module-contract.md capturing §4.4, add a guard test asserting every mod*Server returns a named list of reactives whose elements are all functions, bring modInput up to the contract and document it as the reference implementation. Read the plan's §6 Phase 5 before starting.
key_files: R/modInput.R:239-266 (@return doc + signature), R/modPedigree.R:169-198 (@param/signature), R/appServer.R:41-289 (config-removal call sites, qcResults deletion, req()/tryCatch guard changes); test files (see CHANGELOG.md). Plan: docs/planning/issue122-module-contract-plan.md section 6 Phase 4 (line 412), section 7 Dragon 2 (line 499), section 10 (line 657).
gotchas: (1) Phase 5's guard test MUST NOT assume modSummaryStats' 12 returns are dead -- this session's finding means a correct guard test has to account for a module whose reactives no production caller consumes but real tests do. (2) modInput is Phase 5's target reference implementation and is not yet fully contract-compliant -- re-read what remains before starting. (3) The new unprotected-getSiteInfo() BACKLOG item (appServer.R:347) is a separate, unrelated fix -- don't fold it into Phase 5 just because it's nearby. (4) An observer's uncaught error surfaces to shiny::testServer() as a warning(), not a thrown error -- verify empirically (isolated 2-line reproduction) before writing expect_error() against reactive-graph errors.
runtime_smoke: NOT_CRAN=true NPRC_RUN_E2E=true across test-e2e-input-detailed.R (6/6), test-e2e-input-incomplete-final-line.R (2/2), test-e2e-input-module.R (5/5), test-e2e-input-tutorial.R (8/8), test-e2e-pedigree-detailed.R (8/8), test-e2e-pedigree-module.R (6/6), test-e2e-pedigree-tutorial.R (13/13) -- 48/48 passing against the real modified app.
changelog_ref: CHANGELOG.md 2026-07-13 S376 entry
commit: fb9e0b5c, ecdda66b, 4b461527, 03bfce99, 2df12dd0 (BACKLOG.md)
```
<Self-score breakdown: +extended the plan's own §8 evidence-based-inventory discipline
PAST its stated boundary (checked tests/, not just appServer.R wiring) and caught a
false "12 unread reactives" premise before it broke ~53 test assertions with no
replacement mechanism; +posed both pre-RED scope corrections via AskUserQuestion with
concrete evidence rather than deciding or deferring silently; +caught a real
sequencing hazard the plan's text under-specified (naive req() would have let
changedCols' not-ready state block sibling reads that don't depend on it) and fixed it
with a narrowly-scoped tryCatch(shiny.silent.error=) instead, confirmed empirically;
+caught and fixed my own test-authoring assumption (observer errors surface as
warnings under testServer(), not thrown errors) via isolated reproduction before
declaring GREEN; +surfaced a genuine adjacent bug (unprotected getSiteInfo() at the
ORIP gate) and correctly deferred it to BACKLOG rather than scope-creeping the fix in;
-no material weakness found this session, though the extensive pre-RED investigation
(loadSiteConfig/getSiteInfo tracing, LabKey call-graph, 12-reactive test-consumer
count) ran long relative to Phase 3 -- warranted given what it caught, but worth
naming.>

## Three files, three questions, one shared key

- **`SESSION_NOTES.md`** — the *transient scratchpad*: rich working notes, overwritten every session.
- **`HANDOFFS.md`** (this file) — the *durable receipt*: the distilled, machine-checkable proof that
  the handoff was written, kept forever.
- **`CHANGELOG.md`** — the *cumulative action ledger*: *"what was done here, ever?"*, append-only.

The shared key across all three is the commit sha (`changelog_ref` / `commit` here). This file
**distills** the handoff; it does not copy the scratchpad. The belongs-here test: *would the next
session need this block to continue the work without re-reading the whole repo?*

---

<!-- Receipts go below, newest on top. Delete the seed-sentinel line above when you add the first one. -->

```handoff
session: S375
date: 2026-07-13
status: complete
self_score: 8
predecessor_score: 8
active_task: Issue #122 module-contract plan Phase 3 DONE. Phase 4 (prune dead surface, replace tryCatch swallow) next -- see BACKLOG.md.
what_was_done: Deleted modGeneticValue's geneticValues rename closure (now returns gvResults() directly) and the redundant mkCol/guCol dual-vocab display probes; migrated modSummaryStats.R (~13 sites + @param doc) and modORIPReporting.R (4 sites) to canonical indivMeanKin/gu. Verified 5 of the plan's 12 cited test files were false positives (consumer never reads the flagged column, or already dual-vocab tolerant) by tracing each consumer firsthand; updated the 7 real ones. Strict TDD RED (7 files) -> GREEN -> REFACTOR (@param doc, devtools::document() standalone). Full suite 0/0/0/167 skipped; devtools::check() 0/0/0. End-to-end against real 280-animal qcPed: geneticValues() identical to gvResults(); modSummaryStats/modORIPReporting render the exact same independently-computed values. Phase 3E: NPRC_RUN_E2E=true across 5 e2e files, 34/34 passing. Self-caught and disclosed one phase-gate violation (bundled a REFACTOR doc edit into GREEN) via a 4th AskUserQuestion. Commits 0a6e91c2 (modGeneticValue, 2 files), 0acb29db (modSummaryStats, 5 files), 1f8436e8 (modORIPReporting, 4 files).
next_steps: Execute Phase 4 of docs/planning/issue122-module-contract-plan.md -- prune the dead site-config chain (config params on modInputServer/modPedigreeServer, shared$config; a real delete-vs-wire design decision per the plan's §10), the dead shared$qcResults write, modSummaryStats' 12 unread returned reactives, modInput's undocumented @return elements, and replace appServer's blanket tryCatch(..., error = function(e) NULL) swallow (6-7 sites) with explicit req()/contract guards. Read the plan's §6 Phase 4 and §7 Dragon 2 (structural deparse() tests designed to go red) before starting.
key_files: R/modGeneticValue.R:339-457 (probe + closure deletion); R/modSummaryStats.R (~13 sites + @param); R/modORIPReporting.R:209-211,283-285; 7 test files (see CHANGELOG.md); man/modSummaryStatsServer.Rd (regenerated). Plan: docs/planning/issue122-module-contract-plan.md section 6 Phase 4 (line 412), section 7 Dragon 2 (line 499).
gotchas: (1) Dragon 2 bites hardest in Phase 4 -- ~3 structural deparse() tests (test_modErrorHandling.R:180-184,240-246, test_modSiteConfig.R:132-141, test_loadSiteConfig.R:80-81) are DESIGNED to go red; triage them first, rewrite to assert behavior. (2) The site-config delete-vs-wire choice is a real design decision (plan §10), likely its own pre-RED AskUserQuestion scope gate separate from the TDD phase gates. (3) Re-verify the plan's own Phase 4 citations firsthand before trusting them -- this session found 5 false-positive test-file citations and a "15 vs 12" count mismatch in the SAME plan for Phase 3. (4) devtools::document() standalone, never bundled with the code edit -- this session self-caught exactly that mistake, don't repeat it.
runtime_smoke: NOT_CRAN=true NPRC_RUN_E2E=true across test-e2e-genetic-value-module.R (7/7), test-e2e-genetic-value-detailed.R (7/7), test-e2e-genetic-value-tutorial.R (8/8), test-e2e-summary-statistics-module.R (8/8), test-e2e-orip-module.R (4/4) -- 34/34 passing against the real modified app.
changelog_ref: CHANGELOG.md 2026-07-13 S375 entry
commit: 0a6e91c2, 0acb29db, 1f8436e8, 2d03c521 (BACKLOG.md)
```
<Self-score breakdown: +held strict TDD faithfully; +independently verified the plan's own
grep-derived test-file inventory rather than trusting it, finding 5 false positives and a
15-vs-12 count mismatch; +ran genuine end-to-end verification against real qcPed data, not just
unit tests; +ran the mandatory Phase 3E live smoke test via the strongest available option (5
e2e files, 34/34); +held the 5-file blast-radius cap across 3 concern-scoped commits.
-self-caught phase-gate violation (bundled a REFACTOR-phase doc edit into GREEN without a
separate gate) -- disclosed and corrected before anything was committed, but shouldn't have
happened; -a minor miscount in the PRE-RED gate proposal (said "5 fixture blocks" for
test_modSummaryStats_ggplots.R when only 3 needed edits), caught and corrected during execution.
Predecessor (S374) scored 8/10 -- precise on rename-closure location, doc-standalone, and the
NPRC_RUN_E2E option, but silent on the possibility that some of the plan's own cited test files
might not need editing at all, a discovery this session had to make independently.>

```handoff
session: S374
date: 2026-07-12
status: complete
self_score: 9
predecessor_score: 8
active_task: Issue #122 module-contract plan Phase 2 DONE. Phase 3 (vocabulary collapse) next -- see BACKLOG.md.
what_was_done: Deleted modBreedingGroups' unreachable gvReactive-based kinship-reuse branch; hoisted one shared, memoized, full-pedigree sharedKinshipMatrix reactive into appServer, threaded to both modSummaryStatsServer and modBreedingGroupsServer (new kinshipMatrix param). Recompute fallback retained (Dragon 3). Dragon 1 sidestepped by construction (never wires gvResults$kinshipMatrix), proved via setPopulation() source + the plan's mandatory identical() gate on real qcPed, with/without focal animals. Strict TDD RED (6 sites, 3 files) -> GREEN -> REFACTOR (@param docs, devtools::document() standalone). Full suite 0/0/0; devtools::check() 0 errors/0 warnings/0 notes. Phase 3E: repo's existing NPRC_RUN_E2E=true browser e2e suite, 7/7 + 8/8 passing. Commits 3009c83b (modBreedingGroups, 4 files), 6351c180 (appServer, 2 files).
next_steps: Phase 3 (vocabulary collapse) -- delete the rename closure at R/modGeneticValue.R:470-482, migrate modSummaryStats (~13 sites)/modORIPReporting (4 sites) to canonical indivMeanKin/gu names. Read plan section 6 Phase 3 for the exact site list; re-verify line numbers before trusting them. devtools::document() standalone after roxygen edits (Learning 341). Phase 3E live smoke test required again -- check NPRC_RUN_E2E=true e2e coverage first (Learning 345(a)).
key_files: R/modBreedingGroups.R:181-263 (kinshipMatrix param, rewritten getKinshipMatrix), R/appServer.R:303-370 (sharedKinshipMatrix reactive + both wirings), tests/testthat/test_modBreedingGroups_sharedKinship.R (new), tests/testthat/test_modBreedingGroups_kinshipOverrides.R (3 renamed calls), tests/testthat/test_appServer_server.R:391-459 (new wiring test), man/modBreedingGroupsServer.Rd (regenerated), docs/planning/issue122-module-contract-plan.md section 6 Phase 2 / section 7 Dragons.
gotchas: A Shiny reactive captured from a with_mocked_bindings() stub inside shiny::testServer() cannot be evaluated after the block exits (module session destroyed) -- read its value inside the live block. A capture-only stub replacing a real child module must still return every field the caller reads downstream (e.g. list(groups = reactive(NULL))), not bare NULL, or an unrelated observer crashes. The plan's own Dragon-2 citation for test_modErrorHandling.R:180-184 is imprecise for Phase 2 -- that test's tryCatch/showNotification pin is satisfied by an unrelated, untouched eventReactive block, not the deleted dead branch; verify plan citations against source, don't trust them. See PROJECT_LEARNINGS.md Learning 345.
runtime_smoke: PERFORMED -- test-e2e-breeding-groups-module.R (7/7) and test-e2e-summary-statistics-module.R (8/8) under NOT_CRAN=true NPRC_RUN_E2E=true, real chromote browser sessions against the modified appServer.
changelog_ref: CHANGELOG.md 2026-07-12 "Phase 2: share one full-pedigree kinship reactive, kill the dead reuse branch (Session 374)"
commit: 3009c83b, 6351c180
```
<Strict TDD RED->GREEN->REFACTOR throughout, 3 AskUserQuestion phase gates, all approved with no
modification. Held the plan's mandatory identical() regression gate and Phase 3E live smoke test
as non-negotiable given they change runtime wiring, per the plan's own requirement and FM #24.
Self-score 9/10: +faithful TDD with all 6 RED sites confirmed failing for the predicted reason,
+did not trust the plan's Dragon-2 citation at face value and verified it against source (found
it imprecise), +discovered and used a stronger Phase 3E artifact (NPRC_RUN_E2E e2e suite) than the
plan's own suggestion, +self-caught and fixed two test-authoring bugs during GREEN verification
via reading actual errors rather than guessing, +held the 5-file blast-radius cap via a two-commit
split; -jumped to the Phase 0 priorities-picker AskUserQuestion before rendering the required
prose report, self-caught and corrected before any further action but should not have happened.
Predecessor (S373) scored 8/10 -- accurate and specific on the two dragons/gates that mattered
most, but silent on the existing e2e infrastructure and the 3 existing tests that would need
updating for the renamed helper param, both discovered independently this session.

```handoff
session: S373
date: 2026-07-12
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE -- Phase 1 of docs/planning/issue122-module-contract-plan.md executed and committed. New internal R/normalizeGvReport.R (@noRd) + makeGeneticSummaryTable() gains dual-vocabulary tolerance, fixing the reproduced all-NA-table bug. No Shiny module touched, NAMESPACE unchanged. Phases 2-5 remain separate future sessions, starting with Phase 2.
what_was_done: Executed Phase 1 following DEVELOPMENT_WORKSTREAM.md under strict TDD (RED -> GREEN -> REFACTOR, 3 AskUserQuestion phase gates, all approved). reportGV() (exported) emits indivMeanKin/gu; makeGeneticSummaryTable() (exported) consumed only the renamed meanKinship/genomeUniqueness, so makeGeneticSummaryTable(reportGV(ped)$report) silently returned an all-NA table with no error or warning. Added internal normalizeGvReport() (renames meanKinship/genomeUniqueness -> indivMeanKin/gu only when the canonical name is absent; idempotent; NULL-safe) and wired it into makeGeneticSummaryTable() after the existing NULL/empty guard. RED: 6 new tests (4 in new test_normalizeGvReport.R, 2 in test_makeGeneticSummaryTable.R) all failed for the predicted reason before any implementation. GREEN: minimum implementation, all 6 pass, affected-file suite literal 0 failed/0 error/0 warning (Dragon 6 baseline held). Hit and root-caused a commented_code_linter false positive (a bare #122 issue reference mid-comment tripped it -- see PROJECT_LEARNINGS.md Learning 344(a)); fixed by dropping the #. REFACTOR: widened roxygen @param on both functions, ran devtools::document() standalone (regenerated only man/makeGeneticSummaryTable.Rd, NAMESPACE untouched). Full verification: full-package suite 0/0/0 (169 skip baseline unchanged), lintr::lint_package() 0 lints, devtools::check() 0 errors/0 warnings/0 notes (~3m20s). End-to-end verified against real qcPed data: makeGeneticSummaryTable(reportGV(qcPed)$report) now populates correctly. Implementation committed at exactly 5 files (e51ee11b, the SAFEGUARDS blast-radius cap); BACKLOG.md's Phase-1-DONE/Phase-2-next update committed separately (cc6f6e8a). Also: PROJECT_LEARNINGS.md Learning 344, CLAUDE.md pointer (343->344, 372->373), CHANGELOG.md entry.
next_steps: Pick up PHASE 2 of the plan (BACKLOG.md, READY, Effort S) -- kill modBreedingGroups' dead kinship-reuse branch (R/modBreedingGroups.R:191-196) and hoist one shared, memoized, full-pedigree kinship reactive into appServer for both modSummaryStatsServer and modBreedingGroupsServer. READ the plan's section 7 Dragons FIRST: Dragon 1 (kinship matrices are scope-different, not value-different -- identical()-gate the fix, both with and without focal animals entered) and Dragon 2 (~40 deparse() source-grep tests structurally pin the exact tryCatch this phase changes -- triage via the plan's section 6 Step 0 grep BEFORE touching source) both bite on contact in Phase 2. Phase 2 DOES change runtime wiring, so Phase 3E's live smoke test (callr::r_bg() + shiny::runApp(), per S369 precedent) is mandatory this time, unlike this session's legitimate N/A. Separately unchanged: CRAN resubmission (READY, owner-only), Document 2 Phase D (READY, Effort M), LabKey remainder (BLOCKED), issue #123/XARCH-5 (DECISION NEEDED, needs its own planning session).
key_files: R/normalizeGvReport.R (new, the normalizer); R/makeGeneticSummaryTable.R:26-46 (call site + widened @param); tests/testthat/test_normalizeGvReport.R (new, 4 tests); tests/testthat/test_makeGeneticSummaryTable.R:36-56 (2 new tests); man/makeGeneticSummaryTable.Rd (regenerated). Plan: docs/planning/issue122-module-contract-plan.md section 6 Phase 1 (done) / Phase 2 (next), section 7 Dragons.
gotchas: (1) Dragon 1 and Dragon 2 (see next_steps) both bite on contact in Phase 2 -- read plan section 7 in full first. (2) Phase 2 changes runtime wiring -- Phase 3E live smoke test is mandatory, unlike this session. (3) The plan's identical() verification gate for Phase 2 is mandatory, not optional -- capture before/after both with and without focal animals entered. (4) commented_code_linter false positive (Learning 344(a)): a bare #NNN issue reference immediately after a single bare word in an R source comment can trip lintr's commented-code check (R's own comment-truncation makes the surviving prefix parse as valid code) -- write "issue 122" not "issue #122" in R source comments, or verify empirically in a scratch file if unsure. (5) makeGeneticSummaryTable() still has zero live callers in any Shiny module after this session -- Phase 1 fixed the exported-function contract bug but did not wire it into the app; that wiring is out of this plan's scope entirely (not deferred to a later phase, just not part of issue #122).
runtime_smoke: n/a -- no runtime-loaded path changed. Explicit FM #24 determination: grep -rln "makeGeneticSummaryTable" R/ shows zero call sites in any mod*.R or appServer.R (only its own tests and a @seealso doc reference it) -- not wired into the running Shiny app at all, so there is no live UI path this change touches. NAMESPACE unchanged (no exported signature moved).
changelog_ref: CHANGELOG.md 2026-07-12 "[issue #122] Phase 1: normalize GV report vocabulary at the seam (Session 373)"
commit: e51ee11b
```

**Report (Phase 3G).** Deliverable: Phase 1 of the issue #122 module-contract plan, executed and
committed (`e51ee11b`). `reportGV()` (exported) emits `indivMeanKin`/`gu`; `makeGeneticSummaryTable()`
(exported) consumed only the renamed `meanKinship`/`genomeUniqueness`, so composing them silently
returned an all-`NA` table. Fixed with one new internal (`@noRd`) normalizer, additive, no exported
contract broken, no Shiny module touched. Verified by strict TDD (RED failed for the predicted
reason, GREEN minimal, REFACTOR docs-only) and by execution against the package's own `qcPed` data
-- `makeGeneticSummaryTable(reportGV(qcPed)$report)` now populates correctly.

**+/- self-score (9/10).** **+** Held strict TDD faithfully with 3 approved phase gates; ran the
plan's own Dragon-2 pre-check proactively rather than assuming exemption; root-caused a `lintr`
false positive by genuine bisection instead of suppressing it (now `PROJECT_LEARNINGS.md` Learning
344(a)); verified the fix by execution against real package data, not just unit tests; held the
5-file blast-radius cap; ran the full `devtools::check()` build-equivalent even though not
explicitly demanded by the plan's Phase 1 verification list. **-** The lint bisection took several
scratch-file iterations to isolate the exact trigger -- a minor efficiency cost, though it produced
a reusable, durable finding rather than being pure overhead.

```handoff
session: S372
date: 2026-07-12
status: complete
self_score: 9
predecessor_score: 7
active_task: DONE -- architecture plan for GitHub issue #122 (XARCH-2, module contract) written and committed. Planning only; implementation is 5 separate sessions, one per phase, starting with Phase 1. No R/ or tests/ code touched (verified: git diff --stat -- R/ tests/ is empty).
what_was_done: Wrote docs/planning/issue122-module-contract-plan.md (676 lines, commit 12e30f80) following ARCHITECTURE_WORKSTREAM.md. Research pass: 25 agents (10 module readers, 6 adversarial claim-verifiers, 8 symbol grep-inventories, 1 completeness critic), every citation re-derived from current source since the issue's line refs predate S367-S370. All 4 of issue #122's claims re-verified CONFIRMED -- but the issue understates the problem and overstates the fix, and the plan says so with evidence. (1) The disease is a PUBLIC-API defect, not the internal style issue the issue describes: reportGV() (exported, NAMESPACE:171) emits indivMeanKin/gu while makeGeneticSummaryTable() (exported, NAMESPACE:129) consumes meanKinship/genomeUniqueness, so makeGeneticSummaryTable(reportGV(ped)$report) returns an all-NA table with no error and no warning -- REPRODUCED BY EXECUTION. (2) modBreedingGroups' kinship-reuse branch is unreachable dead code, not "redundant" (R/modBreedingGroups.R:193 column-name-tests a data frame for "kinship" -- never TRUE). (3) The issue's own fix is a trap: threading GV's kinship matrix into the consumers would silently rescope Summary Stats to the focal subset; measured against qcPed, the matrices are bit-identical on the default path and divergent only when focal animals are entered. (4) ~40 deparse() source-grep tests structurally pin the very tryCatch error-swallowing the issue asks us to remove. (5) loadSiteConfig() -> shared$config -> {modInput, modPedigree} is dead end to end -- both modules ignore the param; not in the issue, it sat in the gap between two of its findings. Plan proposes a backward-compatible alternative (canonical = reportGV's vocabulary + a tolerant internal normalizer) that fixes strictly more and breaks NO exported contract -- deliberate, given v2.0.0 is mid-CRAN-resubmission. 5 phases, one session each, per-phase completion criteria + verification commands + 6 dragons. Also: PROJECT_LEARNINGS.md Learning 343, CLAUDE.md pointer (342->343, 371->372), BACKLOG.md Architecture section (Phase 1 + issue #123), CHANGELOG.md entry.
next_steps: Pick up PHASE 1 of the plan (BACKLOG.md, READY, Effort S) -- it fixes the reproduced user-facing bug, is purely additive, breaks no exported contract, and touches no Shiny module. Add one internal @noRd normalizer (R/normalizeGvReport.R) and make makeGeneticSummaryTable() tolerant of BOTH column vocabularies; RED test is that makeGeneticSummaryTable(data.frame(id=1:3, indivMeanKin=..., gu=...)) currently yields an all-N/A table. See the plan's §6 Phase 1 for completion criteria and verification commands. READ §7 (Dragons) FIRST regardless of which phase is picked. Phases 2-5 follow in order, one session each. Separately unchanged: CRAN resubmission (READY, owner-only), Document 2 Phase D (READY, Effort M), LabKey remainder (BLOCKED), and GitHub issue #123 (XARCH-5) which needs its own planning session.
key_files: docs/planning/issue122-module-contract-plan.md (the deliverable). Evidence: R/modGeneticValue.R:470-482 (the rename closure), :232 (the population guard that never fires), :489-492 (the kinship reactive); R/modBreedingGroups.R:193 (the dead reuse branch); R/modSummaryStats.R:363 (its ONLY tryCatch -- and the branch Phase 2 deletes); R/makeGeneticSummaryTable.R:33-41 (the all-NA fallthrough); R/reportGV.R:52-60 (the documented @return), :134,:140 (proband filtering); R/appServer.R:64,105,281 (the dead config chain), :313 (discarded 12-reactive return + its nolint); R/modInput.R:245,266 and R/modPedigree.R:171,198 (dead config params); tests/testthat/test_modErrorHandling.R:180-192,240-246 (the deparse pins); NAMESPACE:129,136,171.
gotchas: (1) DRAGON 2 is the biggest hidden constraint in this codebase for ANY refactor -- ~40 tests deparse() a server function and grepl() its SOURCE TEXT. test_modErrorHandling.R:186-192 asserts deparse(modSummaryStatsServer) contains "tryCatch", and that module has exactly ONE, inside the branch Phase 2 deletes. Run `rg -n 'deparse\((appServer|mod[A-Za-z]+Server)\)' tests/testthat/` BEFORE touching a module body. When one goes red, rewrite it to assert behavior -- do not preserve the anti-pattern to keep it green. (2) The affected-file test baseline is CLEAN (0 failed/0 error/0 warning) -- the project's usual test-app-*/test-e2e-* noise caveat does NOT apply to this blast radius, so per-phase verification can demand a literal zero. Still check the warning column (S313). (3) The dead shared$config chain is a DOMAIN question, not a code question -- was site config supposed to reach modInput/modPedigree? It may be a latent missing feature, not dead code. ASK before deleting (plan §10 decision 1). (4) Do NOT "tidy" appServer.R:375-376's unwrapped gestationTable read into an eager one -- it is a load-bearing lazy promise (Dragon 4; R/modPotentialParents.R:237-240 documents why). (5) The plan deliberately breaks no exported contract because v2.0.0 is mid-CRAN-resubmission; if a future session reopens the "rename at source" option, it must not land before the resubmission completes.
runtime_smoke: n/a -- planning document only. No R/ source, test, config, or runtime-loaded path changed (git diff --stat -- R/ tests/ is empty), so there is no runtime behavior to verify. Explicit determination per FM #24, not a default skip. The plan itself mandates a live Phase 3E smoke test for its own Phases 2 and 4, which do change runtime wiring.
changelog_ref: CHANGELOG.md 2026-07-12 "[issue #122] Architecture plan for XARCH-2 (implicit/inconsistent module contract) (Session 372)"
commit: 12e30f80
```

**Report (Phase 3G).** Deliverable: a 676-line architecture plan for issue #122, committed as
`12e30f80`. The session's real work was refusing to take the issue at face value: all four of its
claims re-verified TRUE, and its recommendation would still have broken the exported API of a
package sitting mid-CRAN-resubmission. Following it literally — "standardize column names at the
source, in `reportGV()`" — would rename the documented `@return` of an exported function, break a
deliberately-pinned contract test, and change the user's downloaded CSV. The plan proposes the
inverse (adopt `reportGV()`'s vocabulary as canonical; add a tolerant normalizer), which fixes
strictly more and breaks strictly less.

The most valuable find was one the issue never mentions: the two exported functions
`reportGV()` and `makeGeneticSummaryTable()` disagree about what the genetic-value columns are
called, so composing them returns an **all-`NA` table with no error** — reproduced by execution,
not inferred. The module-contract mess is what keeps that hidden.

**+/- self-score (9/10).** **+** Treated the issue as a hypothesis and verified its prescription
separately from its claims; reproduced the user-facing bug rather than asserting it; caught myself
copying "make `modInput` the reference implementation" from the issue unverified, then disproved it
(dead `config` param, `@return` documenting 6 of 10 elements); verified every `file:line` in the
plan resolves; held the plan/implementation boundary with zero `R/` edits. **−** I drafted Dragon 1
into the plan from one sub-agent's prose **without running the experiment** — precisely the
documentation-level-verification failure the plan itself warns against. Two verifiers had
contradicted each other and the completeness critic had to catch it and actually run both paths.
The plan is right because an adversarial pass caught me, not because I was careful. Learning 343(d).

**Predecessor (S371): 7/10.** Accurate, honest, real gotchas — but its `next_steps` listed only the
three `BACKLOG.md` items and never surfaced GitHub issues #122/#123, even though `BACKLOG.md` itself
delegates the open XARCH findings to them. The owner went straight to #122 via "Other." A handoff's
job is to answer "what next?", and this one had a blind spot exactly where the work actually was.

```handoff
session: S371
date: 2026-07-12
status: complete
self_score: 9
predecessor_score: 8
active_task: DONE -- S358-flagged vignette-files/PED_GV_AUDIT.html policy question resolved and closed out. Also pushed 5 unpushed S370 close-out commits to origin/master (lightweight sync action, done first during Phase 0).
what_was_done: Traced provenance before proposing options: git log confirmed PED_GV_AUDIT_2026-05-30.md is tracked but its root .html was never tracked and has no generating script anywhere in the repo; ls on all 8 vignettes/articles/*.qmd siblings confirmed 7/8 carry zero rendered output in the tree (only the S332-flagged engineering-the-2.0.0-release.html/_files survive, Learning 308). Posed 2 scope decisions via one AskUserQuestion call with evidence-backed recommendations; both resolved to the recommended option. Claimed the session (a929e6a9) before touching any file. Deleted PED_GV_AUDIT_2026-05-30.html and vignettes/articles/engineering-the-2.0.0-release.html+_files/; extended vignettes/articles/.gitignore with *.html/*_files/ (previously only /.quarto/), closing Learning 308(b)'s diagnosed root cause (top-level .gitignore's single-level vignettes/*.html glob doesn't reach articles/) rather than just the symptom. Verified via git check-ignore -v against both render-output paths (match) and the 3 tracked source types .qmd/_quarto.yml/.R (correctly no match). Committed (d57d1938). Added PROJECT_LEARNINGS.md Learning 342, bumped CLAUDE.md pointer (341->342, 370->371), added 1 CHANGELOG.md entry. Committed (9183aeb9). Also pushed 5 unpushed S370 close-out commits to origin/master (88736aa1..ebe7ceb3, fast-forward) at the user's explicit request, before this deliverable was picked.
next_steps: Vignette-files/PED_GV_AUDIT.html policy question is now fully resolved -- won't resurface. Pick from: (a) CRAN resubmission (READY, Effort S, but owner-only: devtools::submit_cran() + email confirmation); (b) Document 2 Phase D (READY, Effort M); (c) LabKey remainder (BLOCKED, needs live LabKey server). Also still worth a real decision, not another per-session substitution: the headless-browser-tool gap (S367/S368/S369).
key_files: vignettes/articles/.gitignore (extended with *.html/*_files/), PROJECT_LEARNINGS.md Learning 342, CLAUDE.md (pointer), CHANGELOG.md (1 entry)
gotchas: A stray "4" message arrived mid-turn during this session's Phase 0 with no resolvable referent -- flagged to the user but never resolved to a concrete meaning; if it meant something specific, it's still unaddressed. vignettes/articles/.gitignore now covers *.html/*_files/ -- future quarto renders in that directory should no longer leave stray untracked output requiring Learning 308(c)'s manual cleanup; if one still does, that's a signal to revisit the pattern, not to reapply manual cleanup by rote.
runtime_smoke: n/a -- docs/repo-hygiene only, no R/ package runtime behavior or runtime-loaded path changed
changelog_ref: CHANGELOG.md 2026-07-12 "Resolved the S358-flagged vignette-files/PED_GV_AUDIT.html policy question (Session 371)"
commit: d57d1938
```

```handoff
session: S370
date: 2026-07-12
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE -- BACKLOG.md's tiny man/filterPairs.Rd regen item implemented and closed out. BACKLOG.md's Architecture follow-ups section is now genuinely fully empty (S369 had left a self-contradicting intro claiming this while still listing the item; fixed).
what_was_done: Confirmed the drift was cosmetic-only (sexCodes[["female"]] resolves to "F", identical to the stale literal) before acting. Wrote and committed the Phase 1B claim stub (2ebe2161) before any further action. Ran devtools::document() standalone (deliberately with no other roxygen edit pending) -- git diff confirmed exactly one file changed, man/filterPairs.Rd, only the \usage{} line. This directly tested (not just applied) the Learning 339(c)/340(d) diagnosis that the 3-session collateral-regen recurrence was a bundling artifact, not a devtools::document() property -- confirmed true, recorded as Learning 341. Verified fidelity via identical(formals(filterPairs)$ignore, quote(list(c(sexCodes[["female"]], sexCodes[["female"]])))) == TRUE. Full regression 0 failed/0 error/0 warning (169 skipped, baseline unchanged). Removed the resolved BACKLOG.md bullet and fixed its intro paragraph's stale "No items remain" self-contradiction. Added PROJECT_LEARNINGS.md Learning 341, bumped CLAUDE.md pointer (340->341, 369->370), added 2 CHANGELOG.md entries.
next_steps: BACKLOG.md's Architecture follow-ups section is now fully empty -- no doc-regen or XARCH remainders left. Pick from: (a) CRAN resubmission (READY, Effort S, but owner-only: devtools::submit_cran() + email confirmation); (b) Document 2 Phase D (READY, Effort M); (c) LabKey remainder (BLOCKED, needs live LabKey server). Also still worth a real decision, not another per-session substitution: the headless-browser-tool gap (S367/S368/S369); and the untracked vignettes/articles/*.html / PED_GV_AUDIT_2026-05-30.html policy question, open since S358 (see PROJECT_LEARNINGS.md Learning 308).
key_files: man/filterPairs.Rd (regenerated \usage{} line only), BACKLOG.md (resolved bullet removed, intro paragraph fixed), PROJECT_LEARNINGS.md Learning 341, CLAUDE.md (pointer)
gotchas: BACKLOG.md's Architecture follow-ups section is now durably empty -- don't expect another item there without a fresh audit. No other man/*.Rd staleness was audited (correctly out of scope for this dedicated tiny item; a broader sweep would be its own future task if warranted).
runtime_smoke: n/a -- docs-only. No production source or runtime-loaded path changed; man/filterPairs.Rd is rendered documentation only (?filterPairs, pkgdown), not loaded by any Shiny runtime path. Explicit determination per FM #24, not a default skip.
changelog_ref: CHANGELOG.md 2026-07-12 "Regenerated stale man/filterPairs.Rd via standalone devtools::document() (Session 370)"
commit: 0b85750c
```

```handoff
session: S369
date: 2026-07-12
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE -- BACKLOG.md's XARCH-8 remainder (fold getRequiredCols()/getPossibleCols()/getIncludeColumns() into getSiteInfo()) implemented and closed out. BACKLOG.md's Architecture follow-ups section is now empty except for a new tiny man/filterPairs.Rd item.
what_was_done: Read the original TECH_DEBT_AUDIT_2026-05-30.md XARCH-8 entry and the 2026-07-11 reconciliation audit's narrower disposition (merged-profile redesign excluded; only the column-list fold remains). Confirmed via grep that getRequiredCols()/getPossibleCols()/getIncludeColumns() are referenced nowhere from getSiteInfo(). Wrote the Phase 1B claim stub and committed it (04198b41) BEFORE any RED-test authoring (deliberately checked against S368's Learning 339(d) process miss -- held this time). TDD RED: updated test_getSiteInfo.R's exact-name-enumeration test (17->20 fields) plus 2 new identical()-based tests covering BOTH of getSiteInfo()'s independent return branches (no-config via expectConfigFile=FALSE, and a real config file manufactured via the same withr::local_tempdir()+file.copy(example_nprcgenekeepr_config) pattern test_loadSiteConfig.R established for issue #50). All 7 assertions failed for the predicted reason before implementation (commit 8243b7d3). TDD GREEN: added requiredCols/possibleCols/includeColumns to both return branches of R/getSiteInfo.R plus 3 roxygen @return bullets; devtools::document() regenerated man/getSiteInfo.Rd plus, for a THIRD consecutive session, the unrelated stale man/filterPairs.Rd (S367 leftover) -- reverted via git checkout, this time filed as its own BACKLOG.md item rather than only a handoff note. Full regression 0 failed/0 error/0 warning (169 skipped, baseline); lintr clean (commit bd6ca077). REFACTOR: reviewed, nothing to restructure (duplication matches the file's existing convention). Phase 3E: live-launched the app via callr::r_bg()+shiny::runApp() with stdout/stderr file redirection (HTTP 200, 0 error-like log lines, Input tab rendered) plus a direct load_all() smoke confirming the new fields are identical() to their live source functions. Updated BACKLOG.md, added PROJECT_LEARNINGS.md Learning 340, bumped CLAUDE.md pointer (339->340, 368->369), added 2 CHANGELOG.md entries.
next_steps: No XARCH remainders left in BACKLOG.md. Pick from: (a) the new tiny man/filterPairs.Rd BACKLOG.md item (Effort XS -- one devtools::document() run, docs-only commit); (b) CRAN resubmission (READY, Effort S, but owner-only: devtools::submit_cran() + email confirmation); (c) Document 2 Phase D (READY, Effort M); (d) LabKey remainder (BLOCKED). Also worth a real decision (not another per-session substitution): the headless-browser-tool gap, now 3 sessions running (S367/S368/S369).
key_files: R/getSiteInfo.R (requiredCols/possibleCols/includeColumns added to both return branches + 3 @return bullets), man/getSiteInfo.Rd (regenerated), tests/testthat/test_getSiteInfo.R (exact-name-enumeration test updated; 2 new tests covering both return branches)
gotchas: man/filterPairs.Rd staleness recurred a 3rd time (S367 origin, S368 and S369 both reverted+flagged) -- now filed as BACKLOG.md item (Effort XS), pick it up with a single devtools::document() run. Headless-browser tool still absent from this environment -- same substitution as S367/S368. test_getSiteInfo.R's 2 new tests hardcode the withr::local_tempdir()+file.copy(example_nprcgenekeepr_config) pattern -- if that example config file's schema changes, update the fixture, not just the assertions.
runtime_smoke: Live-launched appUI()/appServer via shiny::runApp() in a callr::r_bg() background process (stdout/stderr file redirection, not in-process sink() which produced an empty log on first attempt) -- HTTP 200, stderr contained only expected startup lines (no errors), Input tab rendered. Combined with a direct load_all() confirmation that getSiteInfo()'s 3 new fields are identical() to their live source functions, plus the 2 new RED-turned-GREEN tests exercising both return branches.
changelog_ref: CHANGELOG.md 2026-07-12 "Implemented BACKLOG.md's XARCH-8 remainder: folded column-list functions into getSiteInfo() (Session 369)"
commit: bd6ca077
```
Implemented BACKLOG.md's XARCH-8 remainder end to end under strict TDD,
deliberately re-checking S368's own Phase 1B process-miss finding and
holding the correct ordering this time. Self-score 9/10: +read both the
original tech-debt-audit's full recommendation and the reconciliation
audit's narrower disposition before scoping RED, so tests targeted
exactly the scoped remainder; +recognized getSiteInfo()'s two
independent return branches each needed independent RED coverage rather
than relying on the no-config branch alone; +diagnosed and fixed a dead-
end live-launch attempt (in-process sink() producing an empty log)
rather than declaring Phase 3E impossible; +went beyond "app didn't
crash" by directly confirming the new fields' live values match their
source functions; +escalated the 3rd-recurring man/filterPairs.Rd
staleness from a handoff gotcha to an actual BACKLOG.md item, closing a
gap S368 had explicitly self-flagged; +stayed within the 5-file
blast-radius cap on every commit. -The first live-launch attempt wasted
a debugging cycle because the working callr::r_bg() smoke-test script
from prior sessions was never saved verbatim, only described in prose --
a future session should save the working script itself. -Did not
escalate the headless-browser-tool gap to a settled decision, despite
noting it is now a 3-session-running repeated judgment call in its own
right.

```handoff
session: S368
date: 2026-07-12
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- BACKLOG.md's XARCH-6 remainder (qcStudbook() call-count redundancy) implemented and closed out. XARCH-8 remainder is now the only item left in "Architecture follow-ups."
what_was_done: Read modInput.R:484-525/runQcStudbook.R/processQcStudbookResult.R to find the exact redundancy: modInput.R's own direct qcStudbook() call (for the raw errorLst) duplicated runQcStudbook()'s internal first pass -- 3 calls per clean-pedigree run, 2 per errored run. TDD RED: 3 tests appended to test_modInput_qcStudbook.R -- 2 call-count assertions via a delegating local_mocked_bindings mock (capture the real qcStudbook, wrap to count-and-delegate, preserving real QC output) confirming 3-vs-2 and 2-vs-1 off-by-one; 1 errorLst-content regression guard that already passed at RED (13ce0186-style precedent; commit c07ea356). Caught a Phase 1B gap here (claim stub not yet written despite PRE-RED research + RED already done) -- corrected by committing the claim stub as its own commit (e4652a4b) ahead of RED. TDD GREEN: runQcStudbook() now returns errorLst at all 3 return paths; modInput.R's standalone qcStudbook() call removed, storedErrorLst() now sourced from qcResult$errorLst. Full regression surfaced a real fallout in test_modInput_sexSpecificAge.R (stale assertions on the now-removed call) -- fixed to assert only on runQcStudbook()'s captured args. Reverted an unrelated stale-doc regen (man/filterPairs.Rd, S367 leftover) via git checkout rather than absorbing it. Fixed one new lint. Commit a78c81b9 (4 files). REFACTOR: reviewed, nothing to change. Phase 3E: live app launch (HTTP 200, 0 log errors, Input module rendered) + the 3 new testServer tests exercising real CSV uploads. Removed BACKLOG.md's XARCH-6 bullet, updated its intro. Added PROJECT_LEARNINGS.md Learning 339, bumped CLAUDE.md pointer (338->339, 367->368), added 2 CHANGELOG.md entries.
next_steps: Pick up XARCH-8 remainder (fold getRequiredCols()/getPossibleCols()/getIncludeColumns() into getSiteInfo()) next -- READY, Effort S, now the only item in BACKLOG.md's Architecture follow-ups section. Separately: (a) regenerate man/filterPairs.Rd for real (S367's stale default-arg doc, currently reverted not fixed); (b) decide whether to file the ~11 other bare-sex-literal files (S367 finding) as a BACKLOG.md item or GitHub issue; (c) the untracked vignettes/articles/*.html / PED_GV_AUDIT_2026-05-30.html policy question remains open (S358-S368).
key_files: R/runQcStudbook.R (errorLst added to all 3 return paths + @return bullet), R/modInput.R:484-517 (standalone qcStudbook() call removed), man/runQcStudbook.Rd (regenerated), tests/testthat/test_modInput_qcStudbook.R (3 new tests), tests/testthat/test_modInput_sexSpecificAge.R (call-threading test updated to new contract)
gotchas: man/filterPairs.Rd was regenerated stale by this session's devtools::document() run (S367 leftover, never fixed there) -- reverted via git checkout, NOT fixed; will keep resurfacing until someone regenerates it for real. The ~11-file wider bare-sex-literal pattern (S367 finding) is still not in BACKLOG.md. No headless-browser tool installed -- Phase 3E used the same live-launch + testServer substitution as S367. test_modInput_qcStudbook.R's new call-count tests are hardcoded to modInputServer's exact call pattern -- if that pattern changes again, update the expected counts rather than deleting the tests.
runtime_smoke: Live-launched appUI()/appServer via shiny::runApp() in a callr::r_bg() background process on a scratch port -- HTTP 200, 0 error-like lines in the captured server log, Input module rendered. Combined with 3 new shiny::testServer tests driving real CSV uploads (pedGood, pedFemaleSireMaleDam) through the delegating mock and asserting real errorLst() content. No headless-browser screenshot (tool unavailable, same judgment call as S367).
changelog_ref: CHANGELOG.md 2026-07-12 "Implemented BACKLOG.md's XARCH-6 remainder: de-duplicated qcStudbook() calls (Session 368)"
commit: a78c81b9
```
Implemented BACKLOG.md's XARCH-6 remainder end to end under strict TDD, including
an in-session self-correction of a Phase 1B ordering miss before it reached the
RED commit. Self-score 8/10: +designed a delegating mock (capture-then-call-through)
so call-count RED tests could assert an exact count without sacrificing real QC
output for downstream assertions; +added a regression-guard test for errorLst
content that already passed at RED, protecting against a fix that removes the
redundant call but routes the wrong errorLst; +ran the full regression suite after
GREEN rather than assuming a clean removal, caught a real fallout in
test_modInput_sexSpecificAge.R and fixed it to the new correct contract;
+identified and excluded an unrelated stale-doc regeneration (man/filterPairs.Rd)
from this commit instead of silently absorbing or silently ignoring it; +caught
and fixed a new lint before calling GREEN done. -Missed Phase 1B's claim-before-any-
technical-work rule -- PRE-RED research and RED-test authoring both happened before
the claim stub was written; self-caught before the RED commit landed, but a real
ordering miss, not a stylistic nit. -Did not attempt a headless-browser install for
Phase 3E, repeating S367's same judgment call rather than escalating it to a settled
decision. -Left the filterPairs.Rd staleness as a gotcha rather than filing it as
its own tiny BACKLOG.md item.

```handoff
session: S367

```handoff
session: S367
date: 2026-07-12
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE -- BACKLOG.md's XARCH-4 remainder (sex-code literal centralization) implemented and closed out. XARCH-6/8 remainders are now the only items left in "Architecture follow-ups."
what_was_done: Fresh whole-repo grep found ~11 more files beyond the ticket's own 6-file scope with the same bare M/F/H/U literal pattern; posed a dedicated pre-RED AskUserQuestion (owner chose the narrow 6-file scope). Claimed (9c6749c5). TDD RED: tests/testthat/test_sexCodes.R -- a constant-value test plus a structural findBareSexCodeLiterals() scan test (skips roxygen #' lines from v1) asserting zero bare literals across the 6 files; confirmed both fail for the right reason (13ce0186). TDD GREEN: added R/sexCodes.R (internal @noRd constant male/female/hermaphrodite/unknown -> M/F/H/U) and routed getPotentialSires.R, calculateSexRatio.R, fillBins.R, filterPairs.R, modBreedingGroups.R, modSummaryStats.R through it; split into 2 commits under the 5-file cap (3a02990a, b64c4481). Full regression: 0 failed/0 error/0 warning. Fixed one new lint (fillBins.R:31 line length) before finishing GREEN. REFACTOR: reviewed, nothing to change. Removed BACKLOG.md's XARCH-4 bullet, updated its intro. Added PROJECT_LEARNINGS.md Learning 338, bumped CLAUDE.md pointer (337->338, 366->367), added 2 CHANGELOG.md entries.
next_steps: Pick up XARCH-6 remainder (qcStudbook()/modInput.R multi-call redundancy) or XARCH-8 remainder (fold column-list functions into getSiteInfo()) next -- both READY, Effort S, now the only items in BACKLOG.md's Architecture follow-ups section. Separately, decide whether to file the ~11 other files with the same bare-sex-literal pattern (calcNeSexRatio.R, getKinshipWithMaleStatus.R, getPotentialParents.R, getSexRatioWithAdditions.R, getProductionStatus.R, getSpeciesMinBreedingAge.R, modORIPReporting.R, modPyramid.R, reportGV.R, resolveBreedingAge.R, groupAddAssign.R's default arg) as a new BACKLOG.md item or GitHub issue -- currently undocumented anywhere except this receipt and SESSION_NOTES.md.
key_files: R/sexCodes.R (new constant), R/getPotentialSires.R:22, R/calculateSexRatio.R:80-81, R/fillBins.R:27-34, R/filterPairs.R:34-36, R/modBreedingGroups.R:330,443-444, R/modSummaryStats.R:797,807 (all: literal -> sexCodes[[...]] ), tests/testthat/test_sexCodes.R (new)
gotchas: The ~11-file wider pattern is real but deliberately out of scope -- do not assume it was missed. test_sexCodes.R's scan is hardcoded to exactly the 6 files this session touched -- extend its file list rather than duplicating the scanner if more files get centralized later. No headless-browser tool (chromium-cli/Playwright) is installed in this environment -- Phase 3E used a live app launch + existing shiny::testServer coverage instead; a future UI-heavy change should install one or budget the same substitution.
runtime_smoke: Live-launched runGeneKeepR() via pkgload::load_all() on a scratch port -- HTTP 200, zero server-log errors, Breeding Groups/Summary Statistics modules rendered with their download handlers present. Combined with existing shiny::testServer tests that read real founders-download CSV content and render groupStats through the full reactive pipeline. No headless-browser screenshot (tool unavailable, not installed -- judged disproportionate for this change's risk level).
changelog_ref: CHANGELOG.md 2026-07-12 "Implemented BACKLOG.md's XARCH-4 remainder: centralized sex-code literals (Session 367)"
commit: b64c4481
```
Implemented BACKLOG.md's XARCH-4 remainder end to end under strict TDD, including a
dedicated pre-RED scope decision when a fresh whole-repo grep found ~11 more files
with the same bare-literal pattern beyond the ticket's named 6. Self-score 9/10:
+ratified the ticket's own scope against current source rather than trusting it
(Learning 336's pattern, generalized to a single item and captured fresh as
Learning 338); +designed the RED-phase structural scan test to skip roxygen prose
from its first version rather than discovering the false-positive later (applying
Learning 335 proactively); +caught and fixed a new lint violation the edit itself
introduced before calling GREEN done; +combined an actual live app launch with
existing shiny::testServer coverage for Phase 3E rather than silently treating
"tests passed" as sufficient for a Shiny-module-server change. -Did not attempt to
install a headless-browser tool for a true click-through screenshot -- judged
disproportionate for a low-risk, already-well-covered refactor, but a judgment call
worth a second opinion rather than settled policy. -Did not check whether the ~11
out-of-scope files already have their own test coverage, which would help whoever
picks up that future item size it.

```handoff
session: S366
date: 2026-07-12
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE -- BACKLOG.md's "Architecture follow-ups" (XARCH-4/6/8 remainder) section relocated to the top of the backlog, directly after ## Active, ahead of ## Up Next/## Documents/## Audit follow-ups. Pure reorder, no content changed.
what_was_done: AskUserQuestion picker returned "XARCH-4: centralize sex codes" but a [Request interrupted by user] event + the user's plain-text imperative ("move all of the XARCh items to top of backlog") arrived in the same exchange; treated the imperative as authoritative, not the stale picker answer (see PROJECT_LEARNINGS.md Learning 337). Claimed (763af19a, 2 files). Re-read BACKLOG.md fresh, moved the Architecture follow-ups section via 2 Edit calls (remove from bottom, insert after ## Active). Verified via git diff --stat: 34 insertions/34 deletions, content byte-identical. Committed (ba9d7801, 1 file). Added PROJECT_LEARNINGS.md Learning 337, bumped CLAUDE.md pointer (336->337, 365->366), added 2 CHANGELOG.md entries (claim, reorder work).
next_steps: The now-top-of-backlog XARCH-4/6/8 remainder items (Effort S each) are natural next picks. Standing open items unchanged: LabKey remainder (BLOCKED), CRAN resubmission (READY, owner-only devtools::submit_cran() + email click), Document 2 Phase D (READY). The untracked vignettes/articles/*.html / PED_GV_AUDIT_2026-05-30.html policy question is still open (flagged S358 through S366) -- see PROJECT_LEARNINGS.md Learning 308 for root cause.
key_files: BACKLOG.md (Architecture follow-ups section relocated to top; no content changed), PROJECT_LEARNINGS.md Learning 337, CLAUDE.md (pointer), CHANGELOG.md
gotchas: This was a pure REORDER -- XARCH-4/6/8 were relocated, not started or implemented. XARCH-2/XARCH-5 remain tracked exclusively as GitHub issues #122/#123, do not re-add to BACKLOG.md. A user's plain-text message that arrives concurrently with an AskUserQuestion picker's tool result supersedes that result -- don't execute a picker answer without checking for a same-exchange override (Learning 337).
runtime_smoke: n/a -- docs-only, no R/, tests/, app startup, or wiring code touched.
changelog_ref: CHANGELOG.md 2026-07-12 entries for Session 366 (claim, reorder work)
commit: ba9d7801
```

```handoff
session: S365
date: 2026-07-11
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE -- BACKLOG.md's "Tracker reconciliation" (DECISION NEEDED) item resolved. Re-verified all 8 XARCH findings against current source: XARCH-1/3/7 RESOLVED, XARCH-2/5 STILL OPEN (filed as GitHub issues #122/#123), XARCH-4/6/8 PARTIALLY resolved (narrow remaining gaps tracked in BACKLOG.md).
what_was_done: Phase 0 backfilled S364's own undocumented close-out commit (9eb07f0e, commit 3f7567b4). User's first reply to the priorities picker was a clarifying question ("what is XARCH-2..8"), answered before re-posing the picker; user re-selected "Tracker reconciliation." Confirmed the item's own framing was stale (inst/application/ deleted -- moots XARCH-1/7; XARCH-3 independently closed S358) before accepting it. Launched a background Workflow (7 read-only agents, one per XARCH-1/2/4/5/6/7/8, 98 tool calls, current-source grep/read only) to re-verify rather than trust the 2026-05-30 audit text. Presented the accurate 8-item table via AskUserQuestion (3 options); user chose "issues for the 2 truly open." Claimed (3b91a624). Spot-checked several agent citations via direct grep before trusting them. Wrote docs/audits/XARCH_TRACKER_RECONCILIATION_AUDIT_2026-07-11.md. Filed GitHub issues #122 (XARCH-2) and #123 (XARCH-5) with current-state evidence. Removed BACKLOG.md's resolved "Tracker reconciliation" section; added "Architecture follow-ups" with 3 narrow-scope items for XARCH-4/6/8. Committed (e87038bc, 2 files). Added PROJECT_LEARNINGS.md Learning 336, bumped CLAUDE.md pointer (335->336, 364->365), added 2 CHANGELOG.md entries (claim, resolution work). Committed (2e77b3e0, 3 files).
next_steps: Standing open items unchanged: LabKey remainder (BLOCKED), CRAN resubmission (READY, owner-only devtools::submit_cran() + email click), Document 2 Phase D (READY), the untracked vignettes/articles/*.html / PED_GV_AUDIT_2026-05-30.html policy question (still open, flagged repeatedly across many prior sessions, still unaddressed). XARCH-2/XARCH-5 now live as GitHub issues #122/#123 -- pick up either directly from GitHub, not BACKLOG.md.
key_files: docs/audits/XARCH_TRACKER_RECONCILIATION_AUDIT_2026-07-11.md (new), BACKLOG.md (Tracker reconciliation section removed, Architecture follow-ups added), PROJECT_LEARNINGS.md Learning 336, CLAUDE.md (pointer), CHANGELOG.md, GitHub issues #122/#123
gotchas: Do NOT re-add XARCH-2/XARCH-5 to BACKLOG.md -- they are tracked exclusively as GitHub issues now. The 3 new BACKLOG.md "Architecture follow-ups" items (XARCH-4/6/8) are deliberately narrower than the original audit's full recommendations -- read the audit doc's §3 before scoping any of them. This session self-closed its own CHANGELOG.md ledger-frontier gap with an extra commit after this close-out commit rather than leaving it for S366's Phase 0 reconcile (S363/S364 both left theirs for the next session to backfill).
runtime_smoke: n/a -- no R/, tests/, app startup, service registration, or wiring code touched. Decision-and-documentation deliverable only; no runtime surface to smoke-test.
changelog_ref: CHANGELOG.md 2026-07-11 entries for Session 365 (claim, resolution work), plus the S364 close-out backfill entry
commit: e87038bc
```

```handoff
session: S364
date: 2026-07-11
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE -- test_vignettes_no_deprecated_minParentAge.R's chunk-blind false positive on vignettes/articles/engineering-the-2.0.0-release.qmd:344 fixed by making the checker chunk-aware. devtools::check(--as-cran): 0 errors/0 warnings/0 notes. Full regression read: 0 failed/0 error/0 warning, 3775 passed (up from 3771).
what_was_done: Three AskUserQuestion gates (priorities pick; fix-approach scope -- chose narrow-the-checker over reword-the-prose; TDD PRE-RED->RED with the 3-fixture plan previewed). Claimed (c122fae2). Added 3 test_that blocks to test_vignettes_no_deprecated_minParentAge.R calling a not-yet-existing findDeprecatedMinParentAgeOffenders() against synthetic withr::local_tempfile() fixtures (in-chunk call/out-of-chunk prose/inline backtick span); confirmed RED (4/4 failing, including the original real false positive). Asked RED->GREEN gate; created tests/testthat/helper-vignette-minParentAge-scan.R with a fence-tracking findDeprecatedMinParentAgeOffenders() that only applies the deprecated-pattern regex between ```{r}/```{R} and closing ``` fences; updated the original test's inline loop to call it and corrected its header comment (which had already claimed a chunk-aware scope it never implemented). Confirmed GREEN (4/4 pass). Asked GREEN->REFACTOR gate; lintr::lint() on both files: no lints found, nothing to change. Committed the fix (87c521d8, 2 files). Removed the resolved BACKLOG.md item, added PROJECT_LEARNINGS.md Learning 335 + a new [chunk-scoped-checker] glossary entry, bumped CLAUDE.md's pointer (334->335, 363->364), added 2 CHANGELOG.md entries (caught and fixed an incorrect [BL-1] source tag before committing -- this repo's actual practice is [ad hoc] uniformly). Committed (b1702a41, 4 files). Split close-out into claim/fix/ledger-docs/handoff commits (each <=5 files), correcting rather than repeating S363's 13-file bundled-commit precedent. At self-assessment, ran an additional corpus-wide old-regex-vs-new-helper comparison across every vignettes/**/*.{Rmd,qmd} file: old scan matched exactly 1 line anywhere (the fixed false positive), new scan matches 0 -- confirms no other true positive was silently missed.
next_steps: Standing open items unchanged: LabKey remainder (BLOCKED), CRAN resubmission (READY, remaining step is owner-only devtools::submit_cran() + email click), Document 2 Phase D (READY), tracker reconciliation (DECISION NEEDED), the untracked vignettes/articles/*.html / PED_GV_AUDIT_2026-05-30.html policy question (still open, untouched since S363).
key_files: tests/testthat/helper-vignette-minParentAge-scan.R (new -- findDeprecatedMinParentAgeOffenders()), tests/testthat/test_vignettes_no_deprecated_minParentAge.R (calls the helper, corrected header comment, 3 new test_that blocks), BACKLOG.md (resolved item removed), PROJECT_LEARNINGS.md Learning 335 + [chunk-scoped-checker], CLAUDE.md (pointer), CHANGELOG.md
gotchas: The fence-tracker only recognizes backtick ```{r}/```{R} ... ``` fences (matches this corpus's actual style, confirmed by the corpus-wide comparison) -- no ~~~-style fences, non-R engines, or nested/malformed fences; a deliberate user-approved scope boundary, not an oversight, but would need extending for a future vignette using a different fence style. This repo's CHANGELOG.md source-tag practice is [ad hoc] for BACKLOG-item resolutions too, despite the documented [BL-<N>] format -- BACKLOG.md items here have no numeric IDs, so [BL-<N>] has never actually been used.
runtime_smoke: n/a in the traditional sense -- test-infrastructure-only change (no R/ production code, app startup, or wiring touched). The change's own runtime surface is devtools::check()'s testthat.R run (and standalone test_file() runs before it), which directly exercises the fixed test both ways.
changelog_ref: CHANGELOG.md 2026-07-11 entries for Session 364 (claim, fix work)
commit: 87c521d8
```

```handoff
session: S363
date: 2026-07-11
status: complete
self_score: 9
predecessor_score: 8
active_task: DONE -- Windows-only WriteXLS/create_wkbk() CI flakiness (R-CMD-check.yaml, red since S351) fixed by replacing WriteXLS with openxlsx. devtools::check(--as-cran): 0 errors/0 warnings/0 notes. CONFIRMED on the actual GitHub Actions windows-latest runner: run 29174654150, windows-latest (release) passed in 11m48s.
what_was_done: Three AskUserQuestion gates (priorities pick; fix-approach scope -- chose replace-the-dependency over guard-the-test; TDD PRE-RED->REFACTOR per [refactor-only]). Claimed (8ac1c5c8). Installed openxlsx into renv. Captured a pre-change WriteXLS reference, then swapped create_wkbk()'s WriteXLS() call for openxlsx::write.xlsx(colWidths="auto"), added an explicit TRUE return (openxlsx's own return value is a workbook object, not TRUE -- would have silently broken the documented @return contract). Updated DESCRIPTION/NAMESPACE/renv.lock; fixed test_readKinshipOverrides.R's now-wrong skip_if_not_installed("WriteXLS") to "openxlsx". A first-pass synthetic identical-proof (no Date column) passed, but the FULL devtools::check() caught 2 real failures in test_modInput_excelSireDam.R: openxlsx writes Date columns as native date-formatted numeric cells, but this package's own readxl::read_excel(col_types="text") read path returns such a cell's raw serial number as text, not its date string -- silently corrupting birth/exit and collapsing qcStudbook()'s output to NULL. Isolated by direct WriteXLS-vs-openxlsx comparison (not assumption); fixed by explicitly coercing Date/POSIXct columns to character before writing. Re-verified: 0 errors/0 warnings/0 notes; strengthened proof (incl. a Date column + NA) identical() TRUE. Full regression read: 1 failed/0 error/0 warning/3771 passed -- the 1 failure is pre-existing and unrelated (test_vignettes_no_deprecated_minParentAge.R, confirmed via git blame unchanged since S357), documented as a new BACKLOG item, not fixed (mode-switch rule). Added a NEWS.Rmd bullet + re-rendered NEWS.md. Added PROJECT_LEARNINGS.md Learning 334 + a new [cross-library-file-format-proof] glossary entry. Bumped CLAUDE.md's pointer (333->334, 362->363). Removed the resolved BACKLOG item, added the new vignette-checker finding, fixed a stale cross-reference.
next_steps: BACKLOG.md's new test_vignettes_no_deprecated_minParentAge.R item (READY, Effort S, two fix options scoped) is a quick, unrelated pickup. Other open items unchanged: LabKey remainder (BLOCKED), Document 2 Phase D (READY), tracker reconciliation (DECISION NEEDED), CRAN resubmission's remaining owner-only devtools::submit_cran() step -- now genuinely unblocked with a fully green R-CMD-check.yaml across all platforms.
key_files: R/create_wkbk.R (WriteXLS->openxlsx swap, explicit TRUE return, Date/POSIXct-to-character coercion), DESCRIPTION (Imports), NAMESPACE (regenerated), renv.lock (snapshotted), tests/testthat/test_readKinshipOverrides.R:35 (skip gate), NEWS.Rmd/NEWS.md, BACKLOG.md, PROJECT_LEARNINGS.md Learning 334, CLAUDE.md (pointer), CHANGELOG.md
gotchas: The pre-existing vignette-checker failure is unrelated and NOT fixed -- don't assume it was introduced by this session. openxlsx's write.xlsx() return value is NOT TRUE/FALSE like WriteXLS's was -- any future edit to create_wkbk() must keep the explicit `TRUE` at the end or the documented @return contract silently breaks again. Any other df_list write path added in the future that includes Date/POSIXct columns needs the same explicit as.character() coercion -- openxlsx's native date-cell typing does not survive this package's col_types="text" read path.
runtime_smoke: devtools::check()'s full testthat.R run exercises the affected Excel-upload path live via shiny::testServer() (test_modInput_excelSireDam.R, test_readKinshipOverrides.R) -- this IS the change's runtime surface, and is what caught then confirmed the fix. No separate runGeneKeepR() launch needed -- no app-startup/wiring code changed.
changelog_ref: CHANGELOG.md 2026-07-11 entries for Session 363 (claim, fix work, close-out)
commit: a425a637
```

```handoff
session: S362
date: 2026-07-11
status: complete
self_score: 8
predecessor_score: 7
active_task: DONE -- CRAN 2.0.0 win-builder x3 + R-hub v2 results processed and folded into cran-comments.md. All clean: win-builder 0 errors/0 warnings on all 3 R versions; R-hub Status OK on linux/windows/macos, 0 test failures. Corrected S361's "very likely to reproduce" prediction about the Windows WriteXLS CI failure -- it did not reproduce on either external check. Remaining CRAN step is now exactly devtools::submit_cran() + email confirmation, both owner-only, unchanged.
what_was_done: Fetched win-builder's 3 directory listings then raw 00check.log text via curl (not an AI-paraphrased WebFetch summary, given the stakes) -- confirmed checking tests ... OK with zero failure output on R-devel/R-release/R-oldrelease. Checked the R-hub run S361 dispatched (occupational-burro, 29171440079) -- all 3 jobs green; pulled the windows job's actual log (not just the checkmark/annotations) and found Status: OK, FAIL 0, though the same WriteXLS "cannot open csv" diagnostic text appears non-fatally. Self-corrected a Phase 1B ordering lapse (investigated before claiming; all read-only, no repo mutation before the claim commit at 8ad229cb). Updated cran-comments.md's Test environments section with real per-platform results (CRAN-facing-only, no internal narrative); caught and fixed two self-introduced mistakes (a fabricated R-devel version number, a duplicated header) by re-reading immediately after editing. Put the full investigation narrative in docs/planning/cran-2.0.0-phase5-runbook.md (owner-facing) per house convention. Corrected both of S361's BACKLOG.md entries: downgraded the WriteXLS item from "blocks CRAN" to CI-hygiene (still READY, still worth fixing); updated the CRAN item to record the clean results and the now-exact remaining owner action. Added PROJECT_LEARNINGS.md Learning 333 (verify a probability-hedged prediction against the actual result; don't generalize a CI finding across superficially similar environments).
next_steps: Owner runs devtools::submit_cran() (or the web form) then clicks the maintainer-email confirmation link -- both owner-only per SAFEGUARDS and the runbook's HARD STOP; nothing else is blocking. Separately, BACKLOG.md's WriteXLS/Windows CI-hygiene item remains open (R-CMD-check.yaml still red) -- worth fixing but no longer urgent/blocking. Other open items unchanged: Document 2 Phase D (READY), LabKey remainder (BLOCKED), tracker reconciliation (DECISION NEEDED).
key_files: cran-comments.md (Test environments section + misspelled-words note), docs/planning/cran-2.0.0-phase5-runbook.md (top note extended), BACKLOG.md (both S361 entries corrected), PROJECT_LEARNINGS.md Learning 333, CLAUDE.md (learning/session-count pointer), SESSION_NOTES.md (S362 handoff)
gotchas: The exact R-hub windows-job step that emits the non-fatal WriteXLS diagnostic is still undisambiguated (example re-run vs. vignette rebuild vs. something else) -- pin this down if a future session wants full certainty before fixing the underlying flakiness. cran-comments.md is pasted verbatim into the actual CRAN submission -- keep it CRAN-facing-only, no session/commit jargon, no investigation narrative (that goes in the runbook). The WriteXLS CI-hygiene item's severity was downgraded but it is NOT resolved -- don't let "no longer blocking" read as "no longer needed."
runtime_smoke: n/a -- no R/tests/DESCRIPTION/NAMESPACE touched; docs only (cran-comments.md, runbook, BACKLOG.md, PROJECT_LEARNINGS.md, CLAUDE.md, SESSION_NOTES.md, HANDOFFS.md); no devtools::submit_cran() or other outward-facing action taken
changelog_ref: CHANGELOG.md 2026-07-11 entries for Session 362 (claim, results-processing/correction, close-out)
commit: 27a2ab31
```

```handoff
session: S361
date: 2026-07-11
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE -- win-builder x3 + R-hub v2 triggered for CRAN 2.0.0 (excludes devtools::submit_cran(), owner-only). Also found and documented (not fixed) a 7-session-old Windows-only CI regression (R-CMD-check.yaml red since S351) that the triggered checks are very likely to reproduce. New BACKLOG item filed; CRAN item cross-referenced.
what_was_done: Phase 0 orientation full pass (0 ledger gap). Priorities picker (S360's new AskUserQuestion customization) exercised for the first time -- user picked CRAN resubmission. Second AskUserQuestion scoped exactly which owner-gated actions to trigger (win-builder+R-hub, not submit_cran()). Verified zero drift since S359's local gate; confirmed an existing GitHub PAT via gitcreds without printing it. Claimed session (eb45667c). Ran devtools::build(), dispatched check_win_devel/release/oldrelease() (results by email ~18:30), ran rhub::rhub_doctor() (all green) then rhub::rhub_check(linux,windows,macos) -- confirmed via gh run list the dispatch actually started (run 29171440079, occupational-burro). That same gh run list call surfaced R-CMD-check.yaml failing on windows-latest(release) on every push since S351 (7 consecutive red runs, macOS/Linux unaffected) -- read the actual failure log: test_modInput_excelSireDam.R fails via create_wkbk() -> WriteXLS::WriteXLS() with a Windows/Perl-dependency symptom. Documented root cause, evidence, and two fix options as a new READY BACKLOG.md item (not fixed -- respects SAFEGUARDS mode-switch rule and this session's narrow authorization). Added PROJECT_LEARNINGS.md Learning 332. Reported the finding and asked a third AskUserQuestion on whether to wait in-session for async results; owner chose close out now.
next_steps: Check win-builder emails (~18:30, rmsharp@me.com) and the R-hub run (https://github.com/rmsharp/nprcgenekeepr/actions/runs/29171440079) with the Windows WriteXLS finding already in mind. Fix the Windows-only WriteXLS/create_wkbk() test failure (BACKLOG.md "Up Next" item 1) before folding results into cran-comments.md or running devtools::submit_cran() -- an unexplained ERROR blocks submission per the plan's acceptance bar. Two fix options documented: guard the Windows Excel-write test path, or replace WriteXLS with a Perl-free writer (openxlsx/writexl). Other open items unchanged: LabKey remainder (BLOCKED), Document 2 Phase D (READY), tracker reconciliation (DECISION NEEDED).
key_files: docs/planning/cran-2.0.0-phase5-runbook.md (read, Sections 2-3 followed, not modified), R/create_wkbk.R:61, R/makeExamplePedigreeFile.R:30-39 (read to characterize the Windows failure, not modified), BACKLOG.md (new item + CRAN item cross-reference), PROJECT_LEARNINGS.md Learning 332, CLAUDE.md (learning-count/session-count pointer), SESSION_NOTES.md (S361 handoff)
gotchas: The Windows WriteXLS CI failure will almost certainly also appear in the win-builder/R-hub results now in flight -- expect it, don't treat it as a fresh surprise. An unexplained Windows ERROR blocks devtools::submit_cran() per the acceptance bar. The exact first-red commit (S350 5a9697a8 vs. S351 2ee65618) is undisambiguated -- S350's own CI run is missing from gh run list entirely (likely cancelled by S351's rapid follow-up push under GitHub Actions concurrency-cancellation), not independently confirmed. gh run list is not currently part of any session's routine checks (Phase 0's triad has no CI-status step) -- this is how a real regression sat undetected for 7 sessions; worth considering for a future Phase 0/verification addition.
runtime_smoke: n/a -- no R/tests/DESCRIPTION/NAMESPACE touched; only docs (BACKLOG.md/SESSION_NOTES.md/HANDOFFS.md/PROJECT_LEARNINGS.md/CLAUDE.md) plus external win-builder/R-hub triggers against already-built/already-committed code
changelog_ref: CHANGELOG.md 2026-07-11 entries for Session 361 (claim, trigger actions, Windows CI finding, close-out)
commit: 4631d461
```

```handoff
session: S360
date: 2026-07-11
status: complete
self_score: 9
predecessor_score: n/a -- same-conversation continuation of S359, not a cold read
active_task: DONE. Extended CLAUDE.md's "Additional Phase 0 steps" so the rendered priorities list is followed by one AskUserQuestion call presenting the numbered BACKLOG.md items as a structured pick.
what_was_done: Added a new sub-entry to CLAUDE.md:191-217, directly after the existing 2026-07-09 priorities-list bullet. Rule: one AskUserQuestion option per numbered READY/BLOCKED/DECISION NEEDED item (never the "Lower priority"/"Informational" bundles), capped at 4 (tool max) in report order with a "+N more" note if truncated (no silent cap), skipped entirely below 2 real items, harness auto-"Other" + plain prose reply still work. Caught and fixed a self-introduced :red_circle:/:orange_circle: shortcode-vs-emoji mismatch against the existing adjacent bullet before committing. Confirmed CLAUDE.md stays within its 25KB byte budget (14.2KB / 241 lines) despite exceeding the softer ~200-line target. Commits: 2fea62cc (claim), 67aee91b (work).
next_steps: This behavior takes effect starting the NEXT fresh session's Phase 0 -- it did not retroactively apply to this conversation's own already-completed orientation. Watch the "cap at 4, +N more" truncation note actually fires if BACKLOG.md ever grows past 4 numbered items (currently exactly 4, so unexercised). No BACKLOG.md item created for this -- it's a standing process instruction, not trackable work.
key_files: CLAUDE.md:191-217 (the new AskUserQuestion sub-entry).
gotchas: (1) Takes effect next fresh session, not retroactively. (2) The 4-item truncation rule is untested against a real >4-item BACKLOG. (3) Same standing items as S359: win-builder/R-hub/submit_cran() owner-only outward-facing, unstarted; untracked vignettes/articles/*.html policy question open, untouched.
runtime_smoke: n/a -- CLAUDE.md prose only, no runtime behavior
changelog_ref: 2026-07-11 · [ad hoc] Added AskUserQuestion priorities-picker to Phase 0 (Session 360)
commit: 67aee91b
```

```handoff
session: S359
date: 2026-07-11
status: complete
self_score: 9
predecessor_score: 8
active_task: DONE. Refreshed the local CRAN pre-submission gate for "CRAN resubmission of v2.0.0" (BACKLOG.md item). Local R CMD check --as-cran --timings is green (0 errors/0 warnings/1 note). Found the on-file win-builder/R-hub results predate S349's archival-causing fix and reset them to placeholders. Item stays open -- win-builder/R-hub/submit_cran() remain owner action, unchanged.
what_was_done: User picked local-prep-only refresh via AskUserQuestion (runbook explicitly frames win-builder/R-hub/submit_cran() as owner-only/outward-facing). R CMD build . + R CMD check --as-cran --timings on current master: 0 errors | 0 warnings | 1 note (down from 2 -- local HTML-manual note no longer reproduces). Slowest example groupAddAssign 1.465s, tests 86s, vignette rebuild 21s. Verified via git merge-base --is-ancestor 8ca8bb24 f7a62aca that the archived-submission sha is an ancestor of S349's fix commit -- the win-builder/R-hub results on file (S328, 2026-07-09) checked pre-fix code, not just old code. git rev-list: 134 commits since (9 touching R/tests/DESCRIPTION/NAMESPACE). Reset cran-comments.md's win-builder/R-hub lines to plain placeholders (file is CRAN-facing-only); put the full ancestry-check reasoning in the runbook instead. Updated BACKLOG.md's CRAN item in place. Added PROJECT_LEARNINGS.md Learning 331, bumped CLAUDE.md's learnings count (330->331). Commits: 19ae5657 (claim), e320f245 (work).
next_steps: The win-builder/R-hub cross-platform checks + devtools::submit_cran() remain owner-only, outward-facing, unstarted -- next session (or the owner directly) should NOT trigger them without an explicit AskUserQuestion scope confirmation first. When run, fold real results into cran-comments.md's now-placeholder Test-environments lines per the runbook's own §4 step (plain CRAN language, no session/commit references). Other BACKLOG.md items untouched: Document 2 Phase D (READY, Effort M); LabKey integration remainder (BLOCKED); tracker reconciliation (DECISION NEEDED).
key_files: cran-comments.md (Resubmission/R CMD check results/Test environments sections), docs/planning/cran-2.0.0-phase5-runbook.md (header note + §1 gate callout), BACKLOG.md (CRAN item), CHANGELOG.md (2 entries), PROJECT_LEARNINGS.md Learning 331, CLAUDE.md (learnings count line).
gotchas: (1) win-builder/R-hub/submit_cran() are owner-only outward-facing actions -- confirm scope via AskUserQuestion before any agent session attempts them. (2) cran-comments.md's win-builder/R-hub lines are now placeholders, not stale-but-real numbers -- do not paste old numbers back in without re-running. (3) git merge-base --is-ancestor <old-sha> <fix-sha> is the mechanical test for "does this on-file result still represent current code" -- reusable whenever a doc claims a commit-pinned result is still valid. (4) The untracked vignettes/articles/*.html render-artifact policy question remains open from prior sessions, untouched, user's call.
runtime_smoke: n/a -- docs-only session (no R/, tests/, NAMESPACE, or DESCRIPTION changed; local package check was run and reverted, not committed)
changelog_ref: 2026-07-11 · [ad hoc] Refreshed local CRAN pre-submission gate for v2.0.0 resubmission (Session 359)
commit: e320f245
```

```handoff
session: S358
date: 2026-07-11
status: complete
self_score: 9
predecessor_score: 6
active_task: DONE. Audited BACKLOG.md's "NEW-12 / XARCH-3 -- Shiny progress hook" item -- verified firsthand that the Shiny-out-of-compute concern is fully resolved. 0 findings required a fix; BACKLOG item removed.
what_was_done: Swept all 230 R/*.R files for the defect signature (shiny:: code calls, library(shiny), incProgress/withProgress/Progress$new outside mod*.R). Confirmed reportGV.R/groupAddAssign.R/geneDrop.R/convertRelationships.R/gvaConvergence.R have zero executable shiny:: code (only roxygen @param text) and all use the identical function-or-NULL, is.null()-guarded updateProgress injected-callback pattern; confirmed the only two real Progress-construction sites (modBreedingGroups.R, modGeneticValue.R) are correctly inside Shiny module files; confirmed getMinParentAge.R (the item's one named historical leak) is genuinely deleted, cross-checked against PROJECT_LEARNINGS.md's account of its NAMESPACE @import shiny relocation. Ran the six compute-layer test files standalone (test_reportGV/test_groupAddAssign/test_geneDrop/test_convertRelationships/test_gvaConvergence x2) as behavioral proof: 0 failures, 1 pre-existing CRAN-only skip, none reference shiny/testServer(). Found one out-of-scope match (safeExecute.R -- guarded shiny:: calls, but a different, already-tracked concern under issue #37) and routed it there rather than folding it in. Wrote docs/audits/XARCH3_SHINY_PROGRESS_HOOK_AUDIT_2026-07-11.md (0 FAIL / 9 PASS / 1 out-of-scope observation). Removed the BACKLOG.md item, added 2 CHANGELOG.md entries, PROJECT_LEARNINGS.md Learning 330, bumped CLAUDE.md's learnings count (329->330). Commits: eaa36b8b (claim), 93c9c207 (audit report + bookkeeping).
next_steps: No follow-up owed -- this audit is complete and the BACKLOG item is closed. Other BACKLOG.md items untouched: CRAN resubmission of v2.0.0 (owner action, READY); Document 2 Phase D (READY, Effort M); LabKey integration remainder (blocked); tracker reconciliation (decision needed). The open policy question about whether vignettes/articles/*.html render artifacts should be tracked remains unresolved -- flagged again at this session's own Phase 0, left untouched, per SAFEGUARDS's "don't touch a previous session's uncommitted state" rule; it's the user's call.
key_files: docs/audits/XARCH3_SHINY_PROGRESS_HOOK_AUDIT_2026-07-11.md (new, the deliverable); BACKLOG.md (item removed, ~L98-101); PROJECT_LEARNINGS.md Learning 330; R/reportGV.R, R/groupAddAssign.R, R/geneDrop.R, R/convertRelationships.R, R/gvaConvergence.R (read, not modified -- all confirmed clean); R/safeExecute.R (read, not modified -- confirmed out-of-scope/issue #37); R/modBreedingGroups.R:295-339, R/modGeneticValue.R:205-244 (read, confirmed correct Progress-construction sites).
gotchas: (1) origin/master had fallen one session behind local (S357 didn't push its close-out; S356 had) -- this session pushes its own close-out to origin/master as a fast-forward at Phase 3F, closing that gap too; if local ever runs ahead of origin by more than the current session's own unpushed work, flag it explicitly in the handoff. (2) The updateProgress injected-callback pattern (function-or-NULL, is.null()-guarded, Progress object built only inside mod*.R files) is the project's confirmed clean template for any future compute function needing progress reporting -- copy this shape rather than reaching for shiny:: directly. (3) safeExecute.R's guarded shiny:: calls are a DIFFERENT, already-tracked concern (issue #37's "zero callers ever" retire candidate) -- do not conflate with a future XARCH-3-style audit; see this audit's §4.1. (4) The untracked PED_GV_AUDIT_2026-05-30.html / vignettes/articles/.gitignore / engineering-2.0.0-release.html+_files/ remain an open, unresolved policy question from earlier sessions -- still untouched, still the user's call.
runtime_smoke: n/a -- zero R/ or tests/ files were changed (only read/grepped/test-run for verification). The deliverable is a new audit report plus BACKLOG/CHANGELOG/PROJECT_LEARNINGS/CLAUDE.md bookkeeping; no runtime behavior exists for it to exercise (matches S356's identical audit-workstream justification).
changelog_ref: CHANGELOG.md 2026-07-11 "Audited NEW-12/XARCH-3 Shiny-progress-hook BACKLOG item (Session 358)"
commit: 93c9c207
```
This session picked BACKLOG priority #3 from its own Phase 0 orientation report and
closed it with a firsthand-verified "0 findings" result rather than trusting the
item's own "mostly resolved" framing at face value. Self-score 9/10: +whole-directory
sweep (230/230 R/*.R files) rather than a re-check of only the two named files,
+behavioral proof (ran the compute-layer tests standalone) beyond static grep,
+correctly routed an out-of-scope match (safeExecute.R) to its real home (issue #37)
instead of padding or dropping it, +independently cross-checked the getMinParentAge.R
deletion claim, +corrected S357's own documented near-miss by claiming the session
before any substantive R/ investigation began; -did not use the Workflow tool despite
ultracode being active (justified for this scope, but a judgment call worth the next
session weighing explicitly), -the grep-based defect signature has an inherent,
disclosed blind spot for indirect/dynamic Shiny invocation. Predecessor (S357) scored
6/10 -- its priorities-list contribution was directly useful, but its handoff didn't
disclose that it skipped the origin push S356 had performed, leaving this session to
discover the drift itself at Phase 0 rather than reading it in the receipt.

```handoff
session: S357
date: 2026-07-11
status: complete
self_score: 8
predecessor_score: 7
active_task: DONE. Fixed "Document 1's Testing-at-Scale section conflates file-count growth with testing quality" (BACKLOG.md, user-flagged S345). Coverage 88.62%->99.70%, test cases 283->1,567, both pulled from Codecov's live API and git history respectively, not estimated.
what_was_done: Queried Codecov's per-commit API (api.codecov.io) for both BACKLOG-named endpoint commits: v1.0.8 4548aa1b = 88.62% coverage, v2.0.0 8ca8bb24 = 99.70%. Derived test_that() case counts for all 5 existing growth-table checkpoints from git history (283->1,567 at the same two endpoints), cross-checked exactly against the pre-existing test_file_count column at all 5 points before trusting the new numbers. The 3 intermediate checkpoints 404'd from Codecov; confirmed genuinely absent (not a query error) via the paginated commit-list endpoint (541 records back to 2018) -- rendered as "not recorded" in the table plus a prose sentence naming the mechanism. Extended vignettes/articles/data-raw/build-document1-evidence.R's T5/F3 block (not hand-editing the CSV) so the table stays script-regeneratable; ran the isolated block twice, byte-identical output. Updated engineering-the-2.0.0-release.qmd's opening paragraph, tbl-testing-growth table/caption, and the paragraph after it; left fig-testing-growth untouched (new metrics have a different scale, would distort a file-count-scaled chart). quarto render succeeded cleanly twice (before/after fixing 2 new R lines over the 80-char convention), 0 broken cross-refs, all 5 tables/5 figures numbered correctly document-wide, 3 unmodified sections spot-checked. Removed the BACKLOG.md item, added CHANGELOG.md entry, PROJECT_LEARNINGS.md Learning 329, bumped CLAUDE.md's learnings count (328->329). Commits: 9d31cca2 (claim), e624fc07 (content fix + bookkeeping).
next_steps: No follow-up owed -- this fix is complete and verified. Other BACKLOG.md items untouched: CRAN resubmission of v2.0.0 (owner action); Document 2 Phase D (READY); NEW-12/XARCH-3 cleanup (READY); LabKey integration remainder (blocked); tracker reconciliation (decision needed). The open policy question about whether vignettes/articles/*.html render artifacts should be tracked (an untracked .gitignore already sits there from an earlier session) remains unresolved -- flagged again at this session's own Phase 0 and left untouched, per SAFEGUARDS's "don't touch a previous session's uncommitted state" rule; it's the user's call, not a technical blocker.
key_files: vignettes/articles/engineering-the-2.0.0-release.qmd (Section 3, ~L392-495 -- opening paragraph, tbl-testing-growth table+caption, new paragraph after the table); vignettes/articles/data-raw/build-document1-evidence.R (T5/F3 block, ~L108-167); vignettes/articles/data/testing-growth.csv (regenerated, not hand-edited); BACKLOG.md (item removed); PROJECT_LEARNINGS.md Learning 329.
gotchas: (1) Codecov's per-commit API (api.codecov.io/api/v2/github/rmsharp/repos/nprcgenekeepr/commits/<full-sha>/) is a reusable technique for any future documentation fix needing a real historical metric this project's CI already tracks -- try it before falling back to local recomputation or an "unreconstructable" caveat. If a specific sha 404s, paginate the commit-list endpoint (.../commits/?page_size=100) to confirm it's genuinely absent rather than a one-off query mistake. (2) vignettes/articles/data/*.csv files under this article are frozen, script-generated evidence (data-raw/build-document1-evidence.R) -- extend the script and re-run it, never hand-edit the CSV, or the article's own stated reproducibility guarantee goes stale. (3) This session did substantive investigative work (Codecov queries, git-history pagination) BEFORE writing the Phase 1B claim stub -- none of it was a file edit, but the next session should claim immediately after receiving a task, before any research, to stay unambiguously inside the protocol's "before any technical work" boundary.
runtime_smoke: n/a -- documentation-only (vignette article + its data-raw generation script + regenerated CSV), zero R/ or tests/ package files changed. The deliverable's own build-equivalent (quarto render) was run twice and verified clean, which is the correct substitute per SAFEGUARDS.md's build-equivalent table.
changelog_ref: CHANGELOG.md 2026-07-11 "Fixed Document 1's Testing-at-Scale file-count/coverage conflation (Session 357)"
commit: e624fc07
```
This session picked BACKLOG priority #3 from its own Phase 0 orientation report and
closed it cleanly with real, externally-verified numbers rather than the BACKLOG item's
own permitted fallback ("not reconstructable... with an honest caveat"). Self-score
8/10: +found the authoritative external source (Codecov API) on the first try for both
commits that mattered, +cross-verified the new git-derived metric against an
already-established column before trusting it, +investigated rather than assumed the
reason 3/5 checkpoints lack a coverage record, +kept the table script-regeneratable
rather than hand-editing frozen data, +verified the render twice with a document-wide
cross-reference/numbering check, not just "the chunk ran"; -did a meaningful amount of
research (two rounds of Codecov queries, git-history digging) before writing the Phase
1B claim stub, which is a process near-miss even though none of that work touched a
file. Predecessor (S356) scored 7/10 -- clean ledger/handoff state made orientation
free, but its task-specific content had no bearing on this session's different BACKLOG
pick, so most of it went unused rather than being unhelpful.

```handoff
session: S356
date: 2026-07-11
status: complete
self_score: 9
predecessor_score: 8
active_task: DONE. Audited "other read.csv() calls in tests/ for the same F/T/TRUE/FALSE type-coercion risk that recurred in S355" (BACKLOG.md, discovered S355). Result: 27 sites audited (not S355's estimated ~12), 0 vulnerable, 6 already guarded, 21 safe by column shape.
what_was_done: Re-verified S355's own grep sweep rather than trusting it -- fresh grep found 27 call sites across 12 files (S355 found ~12 across 9, missing test_modSummaryStats_coverage.R entirely). Hand-audited test_modBreedingGroups.R's 4 sites directly (1 already fixed by S355, 3 PASS -- don't touch Sex column). Ran an 11-agent Workflow parallel fan-out (one per remaining file), each given the exact defect mechanism and instructed to trace real data provenance (R/ downloadHandler content function or test fixture) rather than pattern-match column names -- 0 errors, 96 tool calls, ~422K tokens, ~2.7 min wall-clock. Synthesized all 27 verdicts into docs/audits/READCSV_COLCLASSES_AUDIT_2026-07-11.md per AUDIT_WORKSTREAM.md's report format. Result: 0 FAIL, 6 ALREADY-FIXED (2 of them the original Learning 269(e)/S290 fix site), 21 PASS. 3 sites flagged as dormant risk only (read a mixed-sex fixture column but never assert on it -- no action needed today). Removed the now-answered BACKLOG.md item. Added CHANGELOG.md entry, PROJECT_LEARNINGS.md Learning 328, bumped CLAUDE.md's learnings count (327->328). Commits: 8ad6276c (claim), df5322d2 (audit report + ledger).
next_steps: No follow-up owed -- this audit is complete with a clean (0-finding) result. If a FUTURE session edits test_modPedigree_coverage.R:56, test_modGeneticValue.R:1423, or test_modORIPReporting_server.R:226 to add an assertion on that fixture's sex/Sex column, add a colClasses guard in the same edit (Learning 269(e)/327/328) -- not needed until then. Other BACKLOG.md items untouched: CRAN resubmission of v2.0.0 (owner action); Document 2 Phase D (READY); Document 1 coverage-number gap; NEW-12/XARCH-3 cleanup; LabKey integration remainder (blocked); tracker reconciliation (decision needed).
key_files: docs/audits/READCSV_COLCLASSES_AUDIT_2026-07-11.md (the audit report, new); BACKLOG.md (item removed); PROJECT_LEARNINGS.md Learning 328. No R/ or tests/ files touched -- zero code changes.
gotchas: (1) A predecessor session's own grep-based inventory is a starting point, not verified ground truth -- S355's "roughly a dozen" undercounted by a whole file; always re-run the grep fresh rather than trusting a prior session's count. (2) The audit criterion is NOT "does this read.csv() call have colClasses on its own line" -- multi-line calls can have colClasses on a continuation line (false positive for "unguarded"), and a column matching "sex"-like naming isn't automatically at risk if it's never actually read back and asserted on after the read.csv() call (false positive for "vulnerable"). Trace real provenance, don't pattern-match. (3) Workflow's parallel() fan-out (one agent per file, JSON-schema-constrained output) fits cleanly when each item's verdict is independent and needs multi-step tracing -- used here for the first time in this project's history for an audit task.
runtime_smoke: n/a -- docs-only (audit report + BACKLOG/CHANGELOG/learnings bookkeeping), zero R/ or tests/ files changed, nothing to runtime-verify.
changelog_ref: CHANGELOG.md 2026-07-11 "Audited read.csv() call sites for F/T/TRUE/FALSE coercion risk (Session 356)"
commit: df5322d2
```

```handoff
session: S355
date: 2026-07-11
status: complete
self_score: 9
predecessor_score: 8
active_task: DONE. Fixed "test_modBreedingGroups.R/test_modBreedingGroups_groupAddAssign.R have intermittently flaky, unseeded stochastic assertions" (BACKLOG.md, discovered S351) -- diagnosis found TWO distinct root causes, not the single class BACKLOG assumed: 2 genuine unseeded groupAddAssign() MIS-sampling count mismatches, plus 1 unrelated base-R read.csv() type-coercion gotcha.
what_was_done: Reproduced each of the 3 BACKLOG-named test blocks individually (100+ trials each via direct shiny::testServer() loops, NOT_CRAN=true): "handles maximum number of groups" ~22% failure rate, "works with examplePedigree subset" ~10%, both genuine unseeded count mismatches. "downloadGroup writes the selected group's annotated members" (~2% failure) traced to read.csv()'s type.convert() auto-coercing an all-"F" Sex column to logical FALSE when groupAddAssign() forms an all-female group (common -- female-female kinship is ignored by default) -- this exact gotcha was already documented as PROJECT_LEARNINGS.md Learning 269(e) (S290, different module) and recurred here. Fix: options(nprcgenekeepr.bg_seed = 1L) + on.exit() + Sys.unsetenv("NPRC_BG_SEED") before the two count-mismatch tests' testServer() calls (mirrors the file's own established pattern; verified 10/10 deterministic trials each at the exact asserted counts -- the file's own existing seed convention, 42L, was tried first and found to give the WRONG count for one scenario); colClasses = c("character","character","numeric") added to the third test's read.csv() call. No production R/ code changed. Verification: each fixed test re-run 40x via the full file, 0/40 failures each; lintr 0 on both changed files; full-suite regression read 1 failed (pre-existing, unrelated, test_vignettes_no_deprecated_minParentAge.R, same as S349-S354) / 0 error / 0 warning. Updated BACKLOG.md (item removed; new READY/Effort-S audit item added for ~a dozen other unguarded read.csv() call sites in tests/ found via grep, not individually checked this session), CHANGELOG.md, PROJECT_LEARNINGS.md Learning 327, CLAUDE.md learnings count (326->327). Commits: 495ec65c (claim), 2aa2e3f6 (fix).
next_steps: No follow-up owed for this fix -- complete and verified. New BACKLOG.md item from this session (READY, Effort S): audit ~12 other read.csv() call sites in tests/testthat/*.R (test_getFocalAnimalPed.R:302,545; test_modInput.R:762,860; test_modInput_coverage.R:258-260; test_modGeneticValue.R:1423; test_modPedigree_coverage.R:56; test_modPotentialParents_coverage.R:79; test_modORIPReporting_server.R:177,208,226,242; test_species_first_class.R:71; test-e2e-orip-module.R:141; test-e2e-potential-parents-module.R:119) for the same Learning-269(e) type-coercion risk. Other BACKLOG.md items untouched: CRAN resubmission of v2.0.0 (owner action); Document 2 Phase D (READY); Document 1 coverage-number gap; NEW-12/XARCH-3 cleanup; LabKey integration remainder (blocked); tracker reconciliation (decision needed).
key_files: tests/testthat/test_modBreedingGroups.R (2 of 3 fixes: seed insert + colClasses fix); tests/testthat/test_modBreedingGroups_groupAddAssign.R (1 seed insert); BACKLOG.md (item removed, audit item added); PROJECT_LEARNINGS.md Learning 327.
gotchas: (1) groupAddAssign()'s default iter=10L (the UI's nIterations default, not the function's own documented default of 1000L) means any new unseeded test asserting an exact groupAddAssign()-derived count risks the same flakiness -- seed AND verify the seed empirically for that exact scenario (a working seed for one scenario is not guaranteed for another; confirmed directly with 42L). (2) Any new test reading back a downloaded CSV via read.csv() and asserting a column that could plausibly be all-"F"/"T"/"TRUE"/"FALSE" needs explicit colClasses (Learning 269(e), silently recurred once already). (3) Ad hoc Rscript calling testthat::test_file() on a skip_on_cran()-guarded file needs Sys.setenv(NOT_CRAN="true") set FIRST or the whole file silently skips with 0 tests run -- a first repro attempt got a false "not flaky" reading this way. (4) shiny::testServer()'s test-block expression value is discarded, not returned -- capture results via <<- assignment, not as the block's trailing expression.
runtime_smoke: N/A, justified -- no R/ package runtime behavior changed (test-only fix). Build-equivalent substituted per SAFEGUARDS.md's own table: 40x repeated execution per fixed test (0 failures each) + lintr (0) + full-suite regression read (1 pre-existing unrelated failure / 0 error / 0 warning), all in step 9 of the session writeup.
changelog_ref: CHANGELOG.md 2026-07-11 "Fixed intermittently flaky groupAddAssign tests (Session 355)"
commit: 2aa2e3f6
```

```handoff
session: S354
date: 2026-07-11
status: complete
self_score: 9
predecessor_score: 8
active_task: DONE. Fixed "inst/_pkgdown.yml's curated Reference-page grouping is dead configuration" (BACKLOG.md, discovered S345) -- pkgdown's config resolver only reads root _pkgdown.yml, so inst/_pkgdown.yml's grouped Reference structure was never used. Moved the reference: block into root _pkgdown.yml, re-synced against current NAMESPACE, deleted inst/_pkgdown.yml.
what_was_done: New tests/testthat/test_pkgdown_reference_config.R (4 test_that blocks, pkgdown::as_pkgdown() public API only): root config has a populated reference: block; every current NAMESPACE export is covered by some group; "Data objects" covers every data/ object; inst/_pkgdown.yml no longer exists. Confirmed genuine RED (3 failures + 1 skip) before committing. Fix: root _pkgdown.yml's new reference: block -- "Data objects" 24->25 (added speciesGestation), "Major Features and Functions" unchanged, "Primary interactive functions" 58->56 (dropped addErrTxt [real but non-exported internal helper] and finalRpt [a data object, not a function]), "All exposed functions" rebuilt as the complete current 182-export list (was missing 64 real exports incl. all mod*Server/mod*UI pairs, plus ~34 further stale entries the original BACKLOG research never documented). Deleted inst/_pkgdown.yml (verified committed history first). All 4 tests GREEN. devtools::document(): 0 delta. lintr: 0. Full-suite regression read: 1 failed (pre-existing, unrelated, test_vignettes_no_deprecated_minParentAge.R, same as S349-S353) / 0 error / 0 warning. Local pkgdown::build_reference_index() render succeeded (this deliverable's build-equivalent; no Shiny runtime behavior changed, so no live-browser Phase 3E check applies) -- all 4 group headings render, 204 unique topic links. Updated BACKLOG.md (item removed; Document 2 Phase D note cross-referenced), CHANGELOG.md, PROJECT_LEARNINGS.md Learning 326, CLAUDE.md learnings count (325->326). Commits: c8b68ef9 (claim), a88b8237 (RED test), d14cd913 (GREEN fix).
next_steps: No follow-up owed for this fix -- complete and verified. Other BACKLOG.md items untouched: CRAN resubmission of v2.0.0 (owner action); Document 2 Phase D (READY, its pkgdown-citation sub-task is now easier per this fix); Document 1 coverage-number gap; flaky stochastic groupAddAssign tests; NEW-12/XARCH-3 cleanup; LabKey integration remainder (blocked); tracker reconciliation (decision needed).
key_files: _pkgdown.yml:35-268 (root, new reference: block, the fix); inst/_pkgdown.yml (deleted); tests/testthat/test_pkgdown_reference_config.R (new); BACKLOG.md (item removed, Document 2 note updated); PROJECT_LEARNINGS.md Learning 326.
gotchas: (1) The "All exposed functions" list has NO build-time drift protection -- pkgdown::build_reference_index() does not warn on missing/stale topics, confirmed directly; only the new test catches future drift, so run the suite (not just a pkgdown build) before trusting the Reference page is current. (2) "Primary interactive functions" is still a hand-curated 56-entry SUBSET, not exhaustive -- the mod*Server/mod*UI functions are deliberately NOT in it. (3) Both _pkgdown.yml and inst/_pkgdown.yml are .Rbuildignore'd, so the new test's skip_if_not(file.exists(...)) guards are load-bearing (make it a clean no-op in a built/installed tree), not decorative.
runtime_smoke: N/A, justified -- no R/ package runtime behavior changed (docs-site config + a new test file only). Build-equivalent substituted per SAFEGUARDS.md's own table: local pkgdown::build_reference_index() render, confirmed all 4 groups render live with 204 unique topic links, no errors.
changelog_ref: CHANGELOG.md 2026-07-11 "Fixed dead inst/_pkgdown.yml Reference-page config (Session 354)"
commit: d14cd913
```

```handoff
session: S353
date: 2026-07-10
status: complete
self_score: 9
predecessor_score: 8
active_task: DONE. Fixed "Shipped example pedigree cannot demonstrate the Potential Parents feature" (BACKLOG.md, discovered S348/Learning 321) -- data(examplePedigree) now has a fromCenter (colony-origin) column, derived from its existing origin/recordStatus fields, so the Potential Parents tab shows a populated result (1587 candidates) instead of only the graceful-degradation message.
what_was_done: New data-raw/examplePedigree.R (mirrors data-raw/rhesusPedigree.R) derives fromCenter = blank origin + recordStatus=="original" (2267 TRUE / 1427 FALSE); regenerated data/examplePedigree.RData; added R/data.R roxygen doc, devtools::document() regenerated man/examplePedigree.Rd (12->13 cols). Grepped tests/ and vignettes/ first to confirm this could not break the existing "degrades gracefully without fromCenter" coverage, which depends on two OTHER independent fixtures (inst/extdata/ExamplePedigree.csv; a synthetic unit-test data.frame), not data(examplePedigree) itself. Added tests/testthat/test_examplePedigree.R (structure/type contract) and 1 test appended to tests/testthat/test_getPotentialParents.R (getPotentialParents() on qcStudbook(examplePedigree,...) == 1587 candidates). Full TDD gates: 1 pre-RED scope-decision AskUserQuestion + PRE-RED->RED + RED->GREEN (GREEN->REFACTOR: no refactor needed). Self-caught and corrected a TDD violation (wrote data-raw/examplePedigree.R before the RED->GREEN gate; acknowledged, did not run it, posed the gate first). Verification: full-suite regression read 1 failed (pre-existing, unrelated, test_vignettes_no_deprecated_minParentAge.R, same as S349-S352) / 0 error / 0 warning; all 9 directly-related test files individually clean; lintr 0 on all 4 changed/new files after 1 self-caught nzchar_linter fix; devtools::document() clean 1-file delta, 0 NAMESPACE delta. Updated BACKLOG.md (item removed; Document 2 Phase D note updated -- all 3 Phase-C findings now fixed), NEWS.Rmd/NEWS.md (2.0.0 entry), PROJECT_LEARNINGS.md Learning 325, CLAUDE.md learnings count (324->325). Commits: 1c1a7849 (fix), d059a15c (test), 08da9542 (ledger/backlog/release notes).
next_steps: No follow-up owed for this fix -- complete and verified end-to-end including a live Phase 3E confirmation matching the unit test's locked value exactly. Document 2 Phase D (docs/planning/document2-colony-manager-guide-plan.md section 6 Phase D, still queued, untouched by this session) can now show a POPULATED Potential Parents result if desired -- BACKLOG.md's note updated accordingly; this session deliberately did not touch colony-manager-guide.qmd itself (separate deliverable, out of scope). Other BACKLOG.md items (CRAN resubmission -- owner action; Document 1 coverage-number gap; dead inst/_pkgdown.yml config; flaky stochastic groupAddAssign tests; NEW-12/XARCH-3 cleanup; LabKey integration remainder -- blocked; tracker reconciliation -- decision needed) untouched.
key_files: data-raw/examplePedigree.R (new, the fix); data/examplePedigree.RData (regenerated, +fromCenter); R/data.R (new roxygen entry) / man/examplePedigree.Rd (regenerated); tests/testthat/test_examplePedigree.R (new); tests/testthat/test_getPotentialParents.R:376-386 (new appended test); tests/testthat/exampleFile.txt (tracked fixture, regenerated side effect); NEWS.Rmd/NEWS.md; BACKLOG.md; PROJECT_LEARNINGS.md Learning 325.
gotchas: (1) data(examplePedigree) now has 13 columns (added fromCenter), not 12 -- re-check any future numeric re-derivation against it for old-shape assumptions (Learnings 319/320's discipline). (2) getPotentialParents() against the full shipped examplePedigree at minSireAge=minDamAge=2, maxGestationalPeriod=210L now returns exactly 1587 candidates -- the new locked regression value in both the unit test and this session's live smoke test; if origin/recordStatus derivation logic or the underlying data changes, update both together. (3) The two INDEPENDENT "no fromCenter" fixtures (inst/extdata/ExamplePedigree.csv; the synthetic data.frame in test_modPotentialParents.R:138) remain untouched and still correctly demonstrate graceful degradation -- do not confuse them with the now-fixed data(examplePedigree) R object.
runtime_smoke: DONE, live browser. shinytest2::AppDriver launched the real modular app, generated examplePedigree as a CSV via makeExamplePedigreeFile() (Document 2's own upload method), uploaded through the real Input tab, navigated to Pedigree Browser then Potential Parents, clicked "Find Potential Parents", and read the real status message + the app's own download handler (not DOM/widget introspection, per Learning 323). Confirmed: status message "Found candidate parents for 1587 animal(s) with at least one unknown parent"; downloaded CSV has exactly 1587 rows, columns id/nSires/nDams/sires/dams -- exactly matching the unit test's locked value.
changelog_ref: CHANGELOG.md 2026-07-10 "Added fromCenter column to shipped examplePedigree (Session 353)"
commit: 1c1a7849
```

```handoff
session: S352
date: 2026-07-10
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Fixed the nTopAnimals conditionalPanel double-prefix bug (BACKLOG.md, discovered S351's Phase 3E smoke test) -- modBreedingGroupsUI()'s nTopAnimals panel used sprintf("input['%s'] == 'topRanked'", ns("animalSource")) + ns=ns as its conditionalPanel condition, which double-prefixes and always evaluates FALSE, so the numeric input never appeared in any animalSource state including the default "topRanked" state where it should be visible on page load.
what_was_done: R/modBreedingGroups.R:44-49, condition changed to the bare "input.animalSource == 'topRanked'" (matching the already-fixed sibling sexRatio/customSexRatio panel's pattern) + comment update. Added 1 new RED test to tests/testthat/test_modBreedingGroups.R (~line 42-61): extracts the rendered UI's data-display-if attribute values via regex and asserts the correct unprefixed condition string is present / the double-prefixed namespaced form is absent, scoped to those attributes specifically (not the whole HTML, after a first-draft whole-HTML assertion falsely matched the radioButtons widget's own legitimate namespaced element id -- caught and corrected via git-stash-verified RED/GREEN before committing). Full TDD gates: 3 AskUserQuestion phase gates (PRE-RED->RED; RED->GREEN; GREEN->REFACTOR, no refactor needed). Verification: full-suite regression read 1 failed (pre-existing, unrelated, test_vignettes_no_deprecated_minParentAge.R, same as S349-S351) / 0 error / 0 warning; all directly-related test files individually clean; lintr 0 on both changed files; devtools::document() 0 delta. Updated BACKLOG.md (removed the resolved item), added a NEWS.Rmd bullet under the still-unpublished 2.0.0 entry + rendered NEWS.md (clean 4-line diff). No new PROJECT_LEARNINGS.md entry -- Learning 324 (S351) already fully documents this exact bug's root cause/mechanism/fix shape.
next_steps: No follow-up owed for this fix -- complete and verified end-to-end including a live Phase 3E confirmation of all 3 relevant states. Orientation-report priorities otherwise unchanged: CRAN resubmission of v2.0.0 is an OWNER action; Document 2 Phase D (docs/planning/document2-colony-manager-guide-plan.md section 6 Phase D) remains queued and untouched by this session; other BACKLOG.md items (Document 1 coverage-number gap, dead inst/_pkgdown.yml config, flaky stochastic groupAddAssign tests, Potential Parents example-data gap) untouched.
key_files: R/modBreedingGroups.R:44-49 (the fix, condition string + comment); tests/testthat/test_modBreedingGroups.R:42-61 (new RED test); NEWS.Rmd/NEWS.md (2.0.0 entry, new bullet); BACKLOG.md (item removed).
gotchas: (1) When testing a conditionalPanel's rendered condition string via as.character(ui), do NOT grepl() the whole HTML for a namespaced field name -- it legitimately appears elsewhere too (e.g. the source widget's own id/name attributes). Extract just the data-display-if="..." attribute values first (regmatches(html, gregexpr('data-display-if="[^"]*"', html))) and assert against those. (2) shinytest2::AppDriver$new() itself calls a testthat::skip_on_cran()-style guard internally -- confirmed by isolation (library(shinytest2) + system.file() alone are fine; AppDriver$new(...) alone reproduces "Error: Reason: On CRAN" outside a test context) -- set NOT_CRAN=true for ANY ad hoc Rscript that instantiates AppDriver directly, not just testthat::test_file() calls on skip_on_cran()-guarded files (S350's already-documented instance of the same NOT_CRAN requirement).
runtime_smoke: DONE, live browser. shinytest2::AppDriver launched the real modular app (inst/shinytest/app.R via pkgload::load_all()), uploaded ExamplePedigree.csv through the real Input tab, navigated to the real Breeding Groups tab, and queried the panel's [data-display-if] ancestor's getComputedStyle().display directly (per S351's documented gotcha -- never the child input's own display). Confirmed: "block" at the default "topRanked" state, "none" after switching to "All available", "block" again after switching back to "Top ranked" -- correcting the previously-documented always-"none" behavior. nTopAnimals value round-trips (20, the default).
changelog_ref: CHANGELOG.md 2026-07-10 "Fixed nTopAnimals conditionalPanel double-prefix bug (Session 352)"
commit: cc821d9f
```

```handoff
session: S351
date: 2026-07-10
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Fixed Breeding Groups "Custom" sex ratio missing numeric input (BACKLOG.md, discovered S347) -- modBreedingGroupsUI()'s sexRatio radioButtons offered "Custom" with no numeric input; parseSexRatio(input$sexRatio) called as.numeric("custom"), which is NA and silently fell back to 0.0 (same as "None").
what_was_done: R/modBreedingGroups.R: added a conditionalPanel-gated numericInput("customSexRatio", "Custom ratio (F per M):", value=1.0, min=0.5, max=20.0, step=0.5) after the sexRatio radioButtons; changed parseSexRatio(sexRatioInput) to parseSexRatio(sexRatioInput, customSexRatio=NULL), reading the new input directly (fail-soft to 0.0 on NULL/NA) instead of trying as.numeric() on the radio choice string. Added 2 tests (test_modBreedingGroups.R: UI-HTML-grep for "customSexRatio"; test_modBreedingGroups_groupAddAssign.R: local_mocked_bindings(groupAddAssign=...) capturing the actual sexRatio value reaching the algorithm, asserting 2.5) and modified 1 pre-existing test that had set sexRatio="3" directly (an input the real radioButtons -- none/harem/custom -- can never emit) to route through sexRatio="custom", customSexRatio="3" instead. Verified genuine RED in scratchpad before committing tests (Learning 322/323 discipline). Full TDD gates: 3 AskUserQuestion phase gates (PRE-RED->RED; RED->GREEN; GREEN->REFACTOR, no refactor needed). Phase 3E's live shinytest2::AppDriver check caught a second defect in this session's OWN new code: the conditionalPanel's condition initially copied the sibling nTopAnimals panel's ns()-wrapped pattern (sprintf("input['%s'] == 'custom'", ns("sexRatio")) + ns=ns), which never shows the panel -- ns=ns already narrows Shiny's client-side scope to unprefixed names, so a condition built via ns(...) double-prefixes and always evaluates FALSE (confirmed by reading shiny.js's _narrowScopeComponent + ?shiny::conditionalPanel's documented example). Fixed with the bare "input.sexRatio == 'custom'". Discovered (via the same live check) that the sibling nTopAnimals panel has the IDENTICAL, already-shipping bug -- correctly left unfixed (out of scope, SAFEGUARDS mode-switch discipline), grep-confirmed as the only other instance in R/, and filed as a new BACKLOG.md item. Also discovered and documented (not fixed) 2 pre-existing intermittently flaky, unseeded stochastic groupAddAssign() test assertions, confirmed pre-existing via git stash against unmodified master. Verification: full-suite regression read 1 failed (pre-existing, unrelated, test_vignettes_no_deprecated_minParentAge.R, same as S349/S350) / 0 error / 0 warning; lintr 0 on both changed files; devtools::document() 0 delta. Updated BACKLOG.md (removed the resolved item; updated Document 2 Phase D note; added 2 new discovered items), added a NEWS.Rmd bullet under the still-unpublished 2.0.0 entry + rendered NEWS.md, added PROJECT_LEARNINGS.md Learning 324 + new [ns-scope-conditional] glossary reflex, bumped CLAUDE.md's learnings count (323->324).
next_steps: No follow-up owed for this fix -- complete and verified end-to-end, including the self-discovered conditionalPanel defect in its own new code. Two NEW BACKLOG.md items from this session are READY/Effort S for pickup: (1) the pre-existing nTopAnimals conditionalPanel bug (R/modBreedingGroups.R) -- 1-line condition-string fix, grep-confirmed as the only other instance of the ns()-double-prefix pattern in R/; (2) 2 intermittently flaky, unseeded stochastic groupAddAssign test assertions (test_modBreedingGroups.R:250/:1015, test_modBreedingGroups_groupAddAssign.R:744) -- needs seeding or assertion-relaxation. Orientation-report items otherwise unchanged: CRAN resubmission of v2.0.0 is an OWNER action; Document 2 Phase D (docs/planning/document2-colony-manager-guide-plan.md section 6 Phase D) remains queued, now with only the fromCenter example-data finding still open; other BACKLOG.md items untouched.
key_files: R/modBreedingGroups.R:55-70 (UI fix, conditionalPanel + numericInput), R/modBreedingGroups.R:205-217 (parseSexRatio fix), R/modBreedingGroups.R:258-259 (call site); tests/testthat/test_modBreedingGroups.R (new UI test); tests/testthat/test_modBreedingGroups_groupAddAssign.R (new mocked-server test + 1 modified test); PROJECT_LEARNINGS.md Learning 324 (the conditionalPanel/ns() double-prefix gotcha, full detail); BACKLOG.md (2 new discovered items, full detail).
gotchas: For any future conditionalPanel(ns=ns) work in this codebase: the condition string must use the BARE unprefixed field name ("input.field == 'value'"), never ns("field") -- passing ns=ns already narrows the client-side scope client-side, and shiny::testServer() CANNOT catch this class of bug (no client-side JS evaluation) -- only a live shinytest2::AppDriver check can. To read a conditionalPanel's true visibility live, query the [data-display-if] ancestor directly (.closest("[data-display-if]")) -- a descendant input's own getComputedStyle().display does NOT inherit "none" from a hidden ancestor and gives a false "visible" reading (this session's own first attempt hit exactly that false positive). Also: 2 groupAddAssign-based tests in this suite are unseeded and intermittently flaky (see next_steps item 2) -- don't assume a red run on those specific tests means your own change broke something without first checking via git stash against unmodified code.
runtime_smoke: DONE, live browser. shinytest2::AppDriver launched the real modular app, uploaded a real pedigree via the Input tab, navigated to the real Breeding Groups tab, and drove the real sexRatio radio + customSexRatio numeric input. This check is what caught the conditionalPanel/ns() double-prefix defect described above. Final confirmed state: panel hidden at default (sexRatio="none"), shown after selecting "Custom", customSexRatio value round-trips (readback 3), and clicking "Form Groups" with sexRatio="custom", customSexRatio=3 produces a rendered group panel with no error/danger notification.
changelog_ref: CHANGELOG.md 2026-07-10 "Fixed Breeding Groups \"Custom\" sex ratio missing numeric input (Session 351)"
commit: 2ee65618
```

```handoff
session: S350
date: 2026-07-10
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Fixed the Excel-upload sire/dam pedigree-corruption bug (BACKLOG.md, discovered S347) -- R/modInput.R's readDataFile() called readxl::read_excel(file$datapath) with no col_types, so sample-based column-type guessing defaulted sire/dam to logical (early rows are blank founders) and silently nulled every later alphanumeric ID, with no error shown.
what_was_done: R/modInput.R:306, readxl::read_excel(file$datapath) -> readExcelPOSIXToCharacter(file$datapath) -- reusing the existing, already-tested internal helper (col_types="text") that getPedigree()/getGenotypes()/readKinshipOverrides() already use for their own Excel reads. 1-line fix, no new logic. Added tests/testthat/test_modInput_excelSireDam.R (2 tests): unit-level readDataFile() non-NA sire/dam count + is.character() checks, and an end-to-end modInputServer integration test via a real getData click asserting the cleaned studbook keeps >1000 non-NA sire values (was 3 before the fix). Verified genuine RED in scratchpad before committing the tests (applying Learning 322's lesson). Full TDD gates: 3 AskUserQuestion phase gates (PRE-RED->RED; RED->GREEN; GREEN->REFACTOR, no refactor needed). Verification: full-suite regression read (NOT_CRAN=true) 1 failed (pre-existing, unrelated, same as S349 confirmed via git stash) / 0 error / 0 warning; all directly-related test files individually clean; lintr 0 on both changed files; devtools::document() zero man/NAMESPACE delta. Updated BACKLOG.md (removed the resolved item; updated Document 2 Phase D's note), added a NEWS.Rmd bullet under the still-unpublished 2.0.0 entry + rendered NEWS.md, added PROJECT_LEARNINGS.md Learning 323, bumped CLAUDE.md's learnings count (322->323).
next_steps: No follow-up owed for this fix -- complete and verified end-to-end. Orientation-report priorities are otherwise unchanged: CRAN resubmission of v2.0.0 is an OWNER action (re-run win-builder/R-hub, devtools::submit_cran()); Document 2 Phase D (docs/planning/document2-colony-manager-guide-plan.md section 6 Phase D) remains queued, now with one fewer open finding (Excel corruption fixed; Custom sex ratio and missing fromCenter still open); other BACKLOG.md items untouched.
key_files: R/modInput.R:303-306 (the fix, in full context); tests/testthat/test_modInput_excelSireDam.R (new, 2 tests); R/readExcelPOSIXToCharacter.R (the reused helper); NEWS.Rmd/NEWS.md (2.0.0 entry); BACKLOG.md (item removed); PROJECT_LEARNINGS.md Learning 323 (full detail on the DT-widget introspection dead ends).
gotchas: For any future Phase-3E session verifying a DT::renderDT table live: do NOT trust app$get_value(output=...) or raw app$get_html(selector) on page 1 to reflect the true full dataset (client-side DT ships the whole dataset but get_value returns only widget dependency metadata, and page 1 can show a default-sorted subset, e.g. genuine founders, giving a false negative) -- drive the app's own download handler instead (app$get_download("<ns>-<downloadId>")) for a decisive check of the real full dataset. Also: this project's test files with a top-level testthat::skip_on_cran() need NOT_CRAN=true set when run via the documented "Fast single-file test" command, or the whole file silently skips (pre-existing project behavior, not new).
runtime_smoke: DONE, live browser. shinytest2::AppDriver launched the real modular app (system.file("shinytest", package="nprcgenekeepr") via pkgload::load_all()): uploaded the real Excel round-trip file through the actual file input, clicked "Get Data," downloaded the cleaned result via the app's own "Download Cleaned Data" button. Confirmed 3694 rows, 2026 non-NA sire, 2026 non-NA dam -- exact match to source -- including the specific known pairing KRXZ9X -> sire UFQNBA that would have silently become NA before the fix.
changelog_ref: CHANGELOG.md 2026-07-10 "Fixed Excel-upload sire/dam pedigree corruption (Session 350)"
commit: 5a9697a8
```

```handoff
session: S349
date: 2026-07-10
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Fixed the CRAN Policy violation -- appServer() unconditionally wrote ~/nprcgenekeepr.log outside tempdir() on every boot (owner-forwarded CRAN archival email, 2026-07-09). Root-cause fix: gated the file appender behind the existing, already-tested inputResults$debugMode reactive (the documented "Debug on" checkbox) instead of firing unconditionally at appServer() boot. Also fixed a second, self-discovered regression (observeEvent's default ignoreNULL=TRUE leaking stale global logger state into a fresh session).
what_was_done: Removed R/appServer.R's unconditional top-of-function futile.logger file-appender init. Added observeEvent(inputResults$debugMode(), {...}, ignoreInit=FALSE, ignoreNULL=FALSE) after inputResults <- modInputServer(...): registers a file appender (DEBUG threshold) at getSiteInfo()$homeDir/nprcgenekeepr.log only when debugMode() is TRUE, else appender.console() (INFO) -- restoring the behavior vignettes/manual_components/_software_development.Rmd already documented. Wrote 3 tests (tests/testthat/test_appServer_logging.R): no-file-at-boot (the load-bearing CRAN-compliance guard), file-created-only-after-opt-in, and no-stale-state-on-NULL-first-read (guards the ignoreNULL fix). Full TDD gates: 2 AskUserQuestion scope/approach gates (fix approach; PRE-RED->RED) + RED->GREEN + GREEN->REFACTOR (no refactor needed). Caught and fixed 2 self-discovered issues before declaring done: (1) first-draft RED tests passed against unfixed code because futile.logger::appender.file() creates its target lazily on first WRITE, not at registration, and every in-repo call site is flog.debug() which sat below the buggy code's INFO threshold -- fixed by forcing an explicit flog.info() probe in each test; (2) full-suite regression read surfaced 4 new warnings (stale file appender from a torn-down withr::local_tempdir() leaking into a later real boot) traced to observeEvent's default ignoreNULL=TRUE skipping the safe-default reset on debugMode()'s NULL first read -- fixed with ignoreNULL=FALSE, added the 3rd test. Verification: full-suite regression read 1 failed (pre-existing, unrelated, confirmed via git stash against unmodified master) / 0 error / 0 warning; devtools::document() zero man/NAMESPACE delta; lintr 0 on both changed files; decisive check -- ~/nprcgenekeepr.log's real mtime unchanged after a full-suite run against my actual unmodified $HOME. Updated BACKLOG.md (CRAN item resolved, next owner action named), added a NEWS.Rmd bullet under the still-unpublished 2.0.0 entry + rendered NEWS.md, added PROJECT_LEARNINGS.md Learning 322, bumped CLAUDE.md's learnings count (321->322).
next_steps: Owner action, not an agent session: re-run win-builder/R-hub pre-submission checks and devtools::submit_cran() (no version bump needed -- 2.0.0 was archived pre-publication). Once CRAN publishes, close BACKLOG.md's CRAN item and follow this project's established post-acceptance checklist (see S326-329). Document 2 Phase D (docs/planning/document2-colony-manager-guide-plan.md §6 Phase D) remains the next queued documentation deliverable when the user returns to that workstream -- S348's handoff is still fully valid and unconsumed (this session did not touch it; the CRAN email pre-empted it).
key_files: R/appServer.R:41-134 (the fix, in full); tests/testthat/test_appServer_logging.R (new, 3 tests); vignettes/manual_components/_software_development.Rmd:33-42 (the documented behavior restored); NEWS.Rmd/NEWS.md (2.0.0 entry); BACKLOG.md (CRAN item); PROJECT_LEARNINGS.md Learning 322 (the two futile.logger gotchas, full detail).
gotchas: The "nprcgenekeepr" futile.logger logger name is a process-global registry -- test_modInput_coverage.R already manages this defensively; any new test that registers a custom appender/threshold for that name should reset it or use withr-scoped isolation, or it will leak into unrelated later tests exactly as this session found (4 warnings in test_appServer_server.R, invisible when that file ran alone). appender.file() creates its target file lazily on first WRITE that clears the threshold, not at registration -- a test asserting non-creation must force a probe write, not just boot-and-check.
runtime_smoke: DONE, live browser. shinytest2::AppDriver launched the real modular app (system.file("shinytest", package="nprcgenekeepr") via pkgload::load_all()) with HOME redirected to an isolated tmp dir: no log file at boot; checking "Debug on" + clicking "Go to Input" created the file with real DEBUG content; app stayed functional after unchecking.
changelog_ref: CHANGELOG.md 2026-07-10 "Fixed the CRAN Policy violation that archived nprcgenekeepr 2.0.0 (Session 349)"
commit: f7a62aca
```

```handoff
session: S348
date: 2026-07-10
status: complete
self_score: 9
predecessor_score: 10
active_task: DONE. Executed Document 2 plan Phase C -- docs/planning/document2-colony-manager-guide-plan.md §6 Phase C: drafted vignettes/articles/colony-manager-guide.qmd (Abstract, Introduction, Sections 1-3, Conclusion), Section 3 ported/modernized from ColonyManagerTutorial.Rmd using Phase B's screenshots and Phase A's re-derived numbers. Extended the capture script with 2 owner-approved new screenshots; discovered a third new finding (example data missing fromCenter column).
what_was_done: Drafted vignettes/articles/colony-manager-guide.qmd (~510 lines): Section 1 adapted from _introduction.Rmd; Section 2 adapted from _summary_of_major_functions.Rmd plus an original T1 function-group/tab/article table and an F1 Mermaid pipeline diagram; Section 3 walks all 10 unconditional tabs using Phase A's N1 (3694->2322/1372 unknown)/N2 (54-animal trim)/N3 (962-animal trim via focalAnimals)/N4 (332 living, 123M/209F) verbatim, N5 dropped, N6 deliberately left unpinned (stochastic GVA cutover, matching Phase B's own framing), N7 per owner's decision (None/Harem covered, Custom demo omitted). Found and corrected two additional stale ColonyManagerTutorial.Rmd claims via firsthand source verification: GVA threshold selectInput now offers 1-5/default 4 (not the tutorial's stale "0-3"); the results table's actual column is named `value` (not "Value Designation", unverified against the actual renderDT call). Found a gap between Phase A's tab-coverage decision (both new tabs in scope) and Phase B's 34-screenshot inventory (built from ColonyManagerTutorial.Rmd's own figure references, which predate both tabs) -- surfaced via AskUserQuestion; owner chose to extend the capture script now. Added 2 capture blocks to vignettes/articles/colony-manager-guide-screenshots.R (genetic_diversity_heatmap.png, potential_parents_results.png), reusing existing helpers; re-ran the full script, 70/70 steps succeeded. Visual spot-check of the new screenshots surfaced a third finding: data(examplePedigree) has no fromCenter column, which modPotentialParentsServer requires -- confirmed directly via Rscript, not assumed from the UI warning text; documented the app's actual correctly-degraded response in the article rather than fabricating a populated example. quarto render (isolated) succeeded cleanly -- verified zero missing images and zero unresolved cross-references via grep; made one post-render wording fix (a Conclusion sentence implied the two flagged production bugs were already filed GitHub issues) and re-rendered clean. Spot-checked Document 1 still renders; studbook-quality-control.qmd's library(nprcgenekeepr) failure confirmed pre-existing (package not R CMD INSTALLed in this dev env), not a regression. Cleaned up all render byproducts (including a stray pkgdown/ sanity-check scaffold) before committing. Wrote the Phase C DONE blockquote into the plan (§6) and updated its Status line. Updated BACKLOG.md (Document 2 item -> Phase D; added the fromCenter finding). Added PROJECT_LEARNINGS.md Learning 321 and bumped CLAUDE.md's learnings count. Commit: 2ba6c204.
next_steps: Execute Phase D of docs/planning/document2-colony-manager-guide-plan.md -- assemble and verify: full pass on Abstract/Introduction/Conclusion (this session's versions are first drafts, not audited); the full claim-source audit (workstream Phase 6) over the whole article; AskUserQuestion resolving §11 decision 3 (retire/redirect ColonyManagerTutorial.Rmd or keep both); re-verify the pkgdown Reference-page citation live if the article ends up citing it (§8 dragon 5 -- this draft does not currently cite it, confirm that's still true); run the full §9 verification checklist (pkgdown::build_article() -- this session's attempt errored "Can't find article" on an uninitialized cache, needs real investigation not a retry; R CMD build . + tar tzf; spot-check the six existing articles plus Document 1). Also resolve the third new BACKLOG.md finding (fromCenter column missing from example data) before or as part of publishing.
key_files: vignettes/articles/colony-manager-guide.qmd (the whole deliverable); vignettes/articles/colony-manager-guide-screenshots.R (2-block extension, header comment updated); docs/planning/document2-colony-manager-guide-plan.md §6 Phase C blockquote (full findings detail), §9 (verification checklist), §11 decision 3, §8 dragon 5; BACKLOG.md (Document 2 item now points to Phase D; 3 bug/gap items); PROJECT_LEARNINGS.md Learning 321; R/modPotentialParents.R (the fromCenter requirement); R/getGeneticDiversityStats.R (heat-map metric columns: Value/Origin/Production/Inbreeding).
gotchas: pkgdown::build_article("colony-manager-guide") errored "Can't find article" against a freshly-initialized pkgdown cache in this session -- Phase D should investigate whether this is a cache-priming order issue (e.g. needs build_site() or an index build first) before assuming the article itself is misconfigured. studbook-quality-control.qmd (and likely other feature articles that library() the package rather than pkgload::load_all() it) cannot render in this dev environment without first R CMD INSTALLing the package -- pre-existing, don't mistake for a new regression. modPotentialParentsUI has no #<module>-moduleContainer wrapper unlike every other module -- any future screenshot/E2E work targeting it needs a different selector strategy (this session used no selector, capturing the full viewport). N6 (GVA High/Low cutover row) and the seed-groups example are both deliberately NOT pinned to specific numbers/content in the article -- don't "improve" them with an invented row number or fabricated infant/dam ID pairs without a fresh live run backing the claim.
runtime_smoke: n/a -- no R/ package source modified this session (new Quarto article, a capture-script extension, regenerated documentation image assets, and doc/planning/BACKLOG/CLAUDE.md/PROJECT_LEARNINGS.md updates only); the fromCenter finding was diagnosed via direct Rscript probing, not fixed -- no code change to smoke-test. TDD Phase: N/A throughout (documentation/tooling session).
changelog_ref: CHANGELOG.md 2026-07-10 "Executed Document 2 Phase C: drafted the colony-manager-guide article, two new findings (Session 348)"
commit: 2ba6c204
```

```handoff
session: S347
date: 2026-07-10
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Executed Document 2 plan Phase B -- docs/planning/document2-colony-manager-guide-plan.md §6 Phase B: built the checked-in shinytest2::AppDriver capture script, regenerated all 34 current-UI screenshots per §3A's gap inventory, deleted the 8 orphaned pre-rename screenshots. Discovered and recorded two new production bugs (Excel-upload data corruption; non-functional Custom sex ratio) not fixed this session.
what_was_done: Built vignettes/articles/colony-manager-guide-screenshots.R, a checked-in shinytest2::AppDriver capture script covering all 34 §3A screenshots (25 kept-name in-place regenerations, 4 new files replacing retired concepts, 5 correctly left untouched as non-app-UI spreadsheet illustrations -- 3 of those 5 identified as a Phase-A disposition correction this session). Fixed three script bugs found via a first failed run (get_screenshot() overwrite refusal; a nonexistent DT search-box input binding; app$click("id") blocking on Shiny's ~4s stability-wait default for long-running computations -- switched to wait_=FALSE + click_element_safe() + explicit long-timeout polling, matching this project's own E2E convention). Visual spot-check surfaced a MAJOR previously-unknown bug: R/modInput.R's readDataFile() calls readxl::read_excel() with no col_types, which silently nulls 100% of non-blank sire values (2026/2026) and 2023/2026 dam values on an Excel round-trip of the shipped example pedigree -- the same path any real user's Excel upload goes through. Switched the capture script to CSV (unaffected) and re-verified; also fixed a smaller scripting inconsistency (displayUnknownIds left TRUE instead of FALSE for the large-focal-group sequence) via a targeted patch script. Found a second new bug: Breeding Groups' "Custom" sex-ratio radio has no numeric-value input anywhere in the UI, silently behaving identically to "None". Live numeric reproductions confirmed matching Phase A exactly: 3694 QC'd records (N1), 54-animal focal trim (N2), 962-animal large-focal-group trim (N3, via the shipped focalAnimals object), 332 living animals (N4). Deleted the 8 confirmed-orphaned pre-rename screenshots after re-confirming zero references. Wrote the Phase B DONE blockquote into the plan (§6) and updated its Status line. Updated BACKLOG.md (Document 2 item -> Phase C; added the two new bug findings as HIGH/READY items). Added PROJECT_LEARNINGS.md Learning 320 and bumped CLAUDE.md's learnings count. Commit: 9d9479ad.
next_steps: Execute Phase C of docs/planning/document2-colony-manager-guide-plan.md -- port and draft Sections 1-3 into vignettes/articles/colony-manager-guide.qmd using Phase B's screenshots and Phase A's re-derived numbers. See §6 Phase C for full completion criteria (risk MEDIUM, highest claim-density phase). Before drafting the Input-tab narrative, resolve how to handle the Excel-upload corruption bug (BACKLOG.md) -- do not silently instruct readers to upload Excel while it's broken. The Breeding-Groups "sex ratio of 2.5" demonstration (N7) cannot be captured until the missing-custom-ratio-input bug (also BACKLOG.md) is fixed -- adjust scope or wait.
key_files: vignettes/articles/colony-manager-guide-screenshots.R (new capture script, full provenance/decision comments at top); docs/planning/document2-colony-manager-guide-plan.md §6 Phase B blockquote (full findings detail); BACKLOG.md (3 items: Document 2 -> Phase C, Excel-upload corruption, Custom sex-ratio gap); vignettes/shiny_app_use/ (25 regenerated, 4 new, 8 deleted); PROJECT_LEARNINGS.md Learning 320; R/modInput.R:290-322 (readDataFile(), the Excel-corruption bug site); R/modBreedingGroups.R:55-58,197-203 (the Custom-sex-ratio gap: UI radio choices vs. parseSexRatio()).
gotchas: The Excel-upload bug affects ANY Excel file shaped like the shipped example (many blank-parent rows before alphanumeric ones) -- do not use makeExamplePedigreeFile(..., fileType="excel") for anything needing correct sire/dam data until fixed; use fileType="csv" instead. The Pedigree Browser table's DT search box is not a bound Shiny input (pedigree-pedigreeTable_search errors "Unable to find input binding") -- don't rely on it in future capture/test scripts. shinytest2's app$click("id") (vs. click_element_safe(app, "#id")) blocks on Shiny stabilizing within ~4s and throws for any multi-second+ computation, with failures cascading to every subsequent interaction in the same session since the server stays busy -- always use click_element_safe()/wait_=FALSE for GVA runs, breeding-group formation, or anything else that takes real compute time.
runtime_smoke: n/a -- no R/ package source modified this session (a new tooling script under vignettes/articles/, regenerated documentation image assets, and doc/planning/BACKLOG/CLAUDE.md/PROJECT_LEARNINGS.md updates only); the two newly-discovered app bugs were diagnosed via direct Rscript/AppDriver probing, not fixed, so there is no code change to smoke-test. TDD Phase: N/A throughout (documentation/tooling session).
changelog_ref: CHANGELOG.md 2026-07-10 "Executed Document 2 Phase B: screenshot regeneration + two new bug discoveries (Session 347)"
commit: 9d9479ad
```

```handoff
session: S346
date: 2026-07-10
status: complete
self_score: 8
predecessor_score: 9
active_task: DONE. Executed Document 2 plan Phase A -- docs/planning/document2-colony-manager-guide-plan.md §3A/§6: resolved decisions 1/2/5 (tab coverage = both new tabs; screenshot method = automated shinytest2; title/slug confirmed), built the full 34-screenshot gap inventory, re-derived all 7 example-data-dependent numeric claims.
what_was_done: Resolved §11 decisions 1/2/5 via AskUserQuestion. Read ColonyManagerTutorial.Rmd in full plus all 7 relevant R/mod*.R files (modInput, modPedigree, modPyramid, modGeneticValue, modSummaryStats, modBreedingGroups) to disposition every one of the 34 referenced screenshots against the current modular UI -- found 4 of 6 covered tabs have real functional changes beyond relabeling (new Kinship Overrides feature on GVA, new Harem sex-ratio option on Breeding Groups, a deliberate GVA ranking-algorithm change per issue #9 Slice 3 that makes the tutorial's own "Founders are high value by definition" claim factually wrong). Found and flagged 8 orphaned pre-rename duplicate screenshots (zero references, confirmed via grep) for Phase B deletion. Ran real Rscript -e verification against the shipped data(examplePedigree) for all 7 numeric claims: 3 reproduce exactly (3,694/2,322/1,372 counts; the 54-animal focal trim, contingent on replicating the app's exact unknown-filter-then-trim operation order per R/modPedigree.R:329-343; 332 living animals), 2 verdicted not-re-verifiable/remove (unlisted 85-animal large-focal-group list; inconsistent 3,691-animal/hardware-timing claim), 2 deliberately deferred to live capture in Phase C as stochastic-simulation outputs (GVA row-268 cutover; breeding-group sex-ratio breakdown). Wrote all findings into the plan document in place (new §3A, ✅ DONE blockquote in §6, resolved strikethroughs in §11, updated Status line), matching Document 1's own established Phase-completion convention. Updated BACKLOG.md's Document 2 item to point at Phase B. Added PROJECT_LEARNINGS.md Learning 319 and bumped CLAUDE.md's learnings count. Commit: pending (this receipt's own commit).
next_steps: Execute Phase B of docs/planning/document2-colony-manager-guide-plan.md -- build the checked-in shinytest2::AppDriver capture script and regenerate all current-UI screenshots per §3A's per-screenshot disposition table; delete the 8 orphaned pre-rename screenshots after re-confirming zero references; spike-test the shinytest2 capture method early in the session since it has been decided but not yet tried against the running app (risk HIGH, dragon 1).
key_files: docs/planning/document2-colony-manager-guide-plan.md §3A (both new tables), §6 Phase A blockquote, §11 resolved decisions; BACKLOG.md (Document 2 item updated); PROJECT_LEARNINGS.md (Learning 319); CLAUDE.md (learnings count); SESSION_NOTES.md (S346 section, S345 handoff evaluation).
gotchas: Phase B must replicate the EXACT unknown-filter-then-trim operation order (R/modPedigree.R:329-343) when regenerating the 54-animal focal-trim screenshot/claim -- the reverse order silently gives 87, not 54. Do not reuse the tutorial's original "85 focal animals" claim -- the shipped focalAnimals data object does not reproduce it (gives 962); Phase B/C must pick and record a new focal-ID list. The GVA "Founders are high value by definition" prose is now factually wrong (issue #9 Slice 3 demotes parentage-less "Undetermined" animals to the bottom of the ranking) -- Phase C must rewrite this, not just reshoot the screenshot. A pre-existing, cosmetic-only cross-reference numbering defect in the plan doc (several "§9 dragon"/"§12 decision" mentions that should read "§8"/"§11") was noticed but left unfixed, out of this session's scope -- flag for whoever next substantially edits the plan.
runtime_smoke: n/a -- planning-adjacent execution session (docs/planning/, BACKLOG.md, PROJECT_LEARNINGS.md, CLAUDE.md, SESSION_NOTES.md, HANDOFFS.md only); no R/ or tests/ files modified (read-only Rscript -e verification calls against the loaded package), no runtime behavior changed. TDD Phase: N/A throughout.
changelog_ref: CHANGELOG.md 2026-07-10 "Executed Document 2 Phase A: screenshot gap inventory + numeric claims re-derivation (Session 346)"
commit: 4941b2e8
```

```handoff
session: S345
date: 2026-07-10
status: complete
self_score: 8
predecessor_score: 8
active_task: DONE. Planned "Document 2" -- docs/planning/document2-colony-manager-guide-plan.md, following RESEARCH_DOCUMENTATION_WORKSTREAM.md (adapted, matching Document 1's precedent).
what_was_done: Surveyed the public docs surface (README, six vignettes/articles/*.qmd) and got owner sign-off via AskUserQuestion on form (new pkgdown article) + audience (colony-manager/domain-expert). Before drafting, ran a broader vignettes/ sweep and discovered the target content already exists: a3manual.Rmd + 13 manual_components/*.Rmd (CRAN-shipped, actively maintained, shares README's source) and ColonyManagerTutorial.Rmd (748 lines, screenshot-illustrated, titled for the exact chosen audience, .Rbuildignore'd and unpublished, screenshots stale pre-dating the Shiny-module migration). Also confirmed inst/_pkgdown.yml's Reference-page grouping is dead config (shadowed by root _pkgdown.yml, verified via pkgdown:::pkgdown_config_path + a live-site WebFetch) and independently stale (64/182 exports missing). Surfaced this via a second AskUserQuestion; owner chose to port/modernize ColonyManagerTutorial.Rmd rather than draft fresh. Wrote the full plan: discovery + scope decisions, 12-row evidence table, proposed outline/tables/figures, a 4-phase breakdown with completion criteria and dragons, verification checklist, 5 open decisions for the owner. Added 3 BACKLOG.md items (Document-2 plan-executed status, a user-requested item on Document 1's testing section conflating file-count growth with coverage/test-case/E2E improvement, and the pkgdown dead-config finding) -- none fixed this session, out of scope. Added PROJECT_LEARNINGS.md Learning 318 and bumped CLAUDE.md's learnings count. Commit: pending (this receipt's own commit).
next_steps: Execute Phase A of docs/planning/document2-colony-manager-guide-plan.md -- AskUserQuestion resolving open decisions 1-2 (tab-coverage extent: include Genetic Diversity #112 + Potential Parents #48 or not; screenshot-regeneration method: shinytest2-automated vs. manual), confirm title/slug, build the screenshot gap inventory and re-derive ColonyManagerTutorial.Rmd's example-data-dependent numeric claims against current data. Separately, either of the two other new BACKLOG items (Document-1 testing-section coverage fix, pkgdown dead-config fix) are independent, smaller, Effort-S pickups with no ordering dependency on the Document-2 phases.
key_files: docs/planning/document2-colony-manager-guide-plan.md (the deliverable, all sections); BACKLOG.md (3 items added/updated); PROJECT_LEARNINGS.md (Learning 318); CLAUDE.md (learnings count); SESSION_NOTES.md (S345 section, S344 handoff evaluation).
gotchas: Do not draft Document 2 as fresh prose -- ColonyManagerTutorial.Rmd + manual_components/*.Rmd are the primary source, per the owner's explicit port/modernize decision. vignettes/shiny_app_use/*.png screenshots are stale (2024-12-16, pre-migration) and must not be reused as-is. Any numeric claim carried from ColonyManagerTutorial.Rmd (row counts, timing claims) is tied to 2019-2020-era example data/hardware and must be re-derived, not copied (plan's dragon 2). Two pre-existing untracked render/audit artifacts were observed but NOT created by or cleaned up in this session (out of scope): PED_GV_AUDIT_2026-05-30.html (repo root) and vignettes/articles/engineering-the-2.0.0-release.html/_files//.gitignore (Learning 314's pattern, timestamped just before this session started).
runtime_smoke: n/a -- planning/docs-only session (docs/planning/, BACKLOG.md, PROJECT_LEARNINGS.md, CLAUDE.md, SESSION_NOTES.md, HANDOFFS.md); no R/ or tests/ touched, no runtime behavior changed. TDD Phase: N/A throughout.
changelog_ref: CHANGELOG.md 2026-07-10 "Planned Document 2: port/modernize ColonyManagerTutorial.Rmd (Session 345)"
commit: 14fd5382
```

```handoff
session: S344
date: 2026-07-10
status: complete
self_score: 9
predecessor_score: 7
active_task: DONE. Pruned the stale BACKLOG.md "issue #40 open" item -- issue #40 is CLOSED (merged PR #41, 2026-06-11) and the described E2E-strengthening + CI-stability work is fully done.
what_was_done: Backfilled S343's own undocumented HANDOFFS-sha-backfill commit (b94ad328) into CHANGELOG.md, committed separately (4eb4b463), before the Phase 0 report. Owner picked BACKLOG priority #1 (issue #40 E2E work); before claiming the session, verified via gh issue view 40 (CLOSED, 2026-06-11), gh pr view 41 (MERGED, 0363ffe3), and grep of expect_true(TRUE) across all test-app-*/test-e2e-* files (only historical REVIVE comments remain, zero live tautologies) that the described work is already done -- reported this to the owner via AskUserQuestion instead of starting phantom work; owner chose to prune the stale item. Claimed the session (commit 3bd62024) before any edit. Removed the 6-line stale item from BACKLOG.md's "Up Next" section. Verified via git grep that no other active doc (CLAUDE.md, ROADMAP.md) echoes the stale claim. Added a CHANGELOG.md entry with the full verification chain inline. No R/ or tests/ touched (TDD Phase: N/A).
next_steps: Two independent paths open, same as S343 left them minus the now-closed #40 item: (1) "Plan Document 2" (READY, Effort M) -- package purpose/how-to-use, deferred since S330, named in S336/S339/S341/S343's handoffs, never picked up. (2) LabKey integration remainder (BLOCKED on live server access), CRAN submission prep (BLOCKED/may be stale -- re-check CRAN status first before assuming "preparation" is still the right verb), NEW-12/XARCH-3 Shiny progress hook (READY, Effort S, small separable cleanup), the Tracker-reconciliation DECISION NEEDED item (also flag while there: its own "#1-39" issue-range note is now stale too, issues run to #116 -- noticed this session, not fixed, out of scope), or one of the 8 open GitHub issues (#116, #37, #36, #28, #12, #11, #10, #5).
key_files: BACKLOG.md (removed lines, "Up Next" section), CHANGELOG.md (new [ad hoc] entry with full verification chain), SESSION_NOTES.md (S344 section, S343 handoff evaluation)
gotchas: Before trusting any BACKLOG.md item's "READY"/open framing at face value, spot-check against gh issue/pr state if the item cites a specific issue number -- this exact item survived 3+ prior sessions flagging it stale (visible in CHANGELOG.md history around S330-S334) without anyone actually fixing BACKLOG.md, including a session (S341) whose own deliverable was backlog curation. The "Tracker reconciliation" section's "#1-39" issue-range note (BACKLOG.md, near the bottom) is now also stale (issues run to #116) -- noticed, not fixed, flagged for whoever picks that item up.
runtime_smoke: n/a -- BACKLOG.md only, no R/ or tests/ touched, no runtime behavior changed.
changelog_ref: CHANGELOG.md 2026-07-10 "Pruned the stale BACKLOG.md \"issue #40 open\" item (Session 344)"
commit: 6bd0d9fb
```

```handoff
session: S343
date: 2026-07-10
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Fixed all 15 confirmed findings from the CLOSED docs/audits/DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md audit in vignettes/articles/engineering-the-2.0.0-release.qmd, following the audit's own "Recommendations" priority order.
what_was_done: Backfilled S342's own undocumented HANDOFFS-sha-backfill commit (ebeeb9fd) into CHANGELOG.md, committed separately (520eb531), before the Phase 0 report. Owner picked BACKLOG priority #1 (fix all 15 findings). Claimed the session (commit 6e4d0c85) before technical work. Fixed all 15: A1 (HIGH, runGeneKeepR() Phase-9 misattribution -- independently re-verified via git show on 3db018d1/1e64dd5d before rewriting), B1 (HIGH, "four sessions wrote Sections 1-3" contradiction, reworded per the audit's specific diagnosis), A2 (MEDIUM, added the 3 genuine zero-commit months to data/commit-activity-timeline.csv so fig-commit-pace's chart now visibly shows the gap -- confirmed by rendering and reading the PNG), B10 (MEDIUM, hyperlinked 37 issue/commit citations across prose and captions; discovered and documented a kbl()-escape-by-default rendering gotcha -- Learning 317 -- and deliberately left 2 table-cell citations unlinked rather than silently breaking them), B3 (MEDIUM, added a Section-4 forward-reference at first TDD-vocabulary use), 9 LOW findings batched as one editorial pass, A3 (MINOR/optional, fixed anyway per the "all 15" framing: feature-highlights.csv date off-by-one). Verified: quarto render clean (23 chunks, 0 errors), visually confirmed the chart gap, 0 literal markdown-link leaks in rendered HTML, full testthat::test_dir() regression read (1 failed/0 error/0 warning, the 1 failure pre-existing and unrelated, confirmed via git diff), corpus swept for stale echoes (none found). Cleaned up render artifacts (Learning 314). Updated BACKLOG.md, CHANGELOG.md, PROJECT_LEARNINGS.md (Learning 317), CLAUDE.md (learnings count 316->317). Commit: pending.
next_steps: The article's audit-driven fix work is now complete. Two independent paths open: (1) "Plan Document 2" (READY, Effort M) -- package purpose/how-to-use, deferred since S330, named in S336/S339/S341's handoffs, never picked up. (2) One of the other BACKLOG items (shinytest2 E2E hardening issue #40, LabKey integration remainder BLOCKED on live server access, CRAN submission prep BLOCKED/stale -- re-check CRAN status first) or one of the 8 open GitHub issues (#116, #37, #36, #28, #12, #11, #10, #5). Separately, note (not urgent): test_vignettes_no_deprecated_minParentAge.R has a pre-existing failure (a narrative minParentAge= mention in prose describing the now-replaced old default, first flagged by S337, Session 337's own handoff already deferred it as "a documentation-workstream fix, a different capability" -- still open, still not this session's scope, since it wasn't one of the 15 audit findings).
key_files: vignettes/articles/engineering-the-2.0.0-release.qmd (all 15 fixes applied, verify via the CHANGELOG.md entry's per-finding breakdown), vignettes/articles/data/commit-activity-timeline.csv (3 new zero-commit rows), vignettes/articles/data/feature-highlights.csv (1-line date fix), docs/audits/DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md (unchanged -- historical audit record, left as-is), BACKLOG.md ("## Documents" section, fix item removed), PROJECT_LEARNINGS.md (Learning 317), CLAUDE.md (learnings count 316->317).
gotchas: kableExtra::kbl() escapes cell content by default -- markdown link syntax inside an R-vector column rendered via kbl() shows as literal text, not a link, unless escape=FALSE (Learning 317); this is why tbl-phases's 2 embedded issue citations are still plain text, a deliberate documented exception, not a miss. The pre-existing test_vignettes_no_deprecated_minParentAge.R failure (article L344, prose describing the now-replaced old default) is unrelated to this session and was NOT one of the 15 audit findings -- do not conflate it with this session's scope if a future session investigates open test failures.
runtime_smoke: n/a -- vignettes/articles/*.qmd and data/*.csv only, no R/ or tests/ touched, no runtime behavior changed. Ran quarto render (build-equivalent) + full testthat::test_dir() regression read instead, both clean apart from the one confirmed pre-existing, unrelated failure.
changelog_ref: CHANGELOG.md 2026-07-10 "Fixed all 15 confirmed Document 1 audit findings (Session 343)"
commit: 98db4ff7
```

```handoff
session: S342
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Closed docs/audits/DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md -- independently verified the 13 remaining findings (Lens A #2/#3, Lens B #2-12) against the current article; header now CLOSED, not DRAFT.
what_was_done: Backfilled S341's own undocumented HANDOFFS-sha-backfill commit (7c0d680d) into CHANGELOG.md, committed separately (e146e235), before the Phase 0 report. Owner picked BACKLOG priority #1; AskUserQuestion confirmed verify-only scope (no article edits, fixes deferred). Claimed the session (commit 7c4c6f02) before technical work. Read the full 745-line article and independently re-verified all 13 remaining findings via git log/git show/grep/CSV re-derivation (not the DRAFT's own text): Lens A #2 (commit-pace chart hides a real 3-month zero-commit gap, confirmed via git log --format=%ad --date=format:%Y-%m 4548aa1b..8ca8bb24 exact-matching the CSV), Lens A #3 (0eeee3f6 1-day date mismatch, confirmed via git show, zero reader impact), Lens B #2-12 (grammar error; unglossed "Phase A data freeze"/"vertical-slice"/"XARCH-2"; 1 hyperlink vs 22 plain-text citations; TDD vocab undefined ~500 lines; 4 more editorial/structural nits) -- all 13 confirmed real, still unfixed, 0 downgrades. Wrote a new verification section, a severity-ranked Final Findings Summary (all 15 findings), and priority-ordered Recommendations into the audit doc; changed header DRAFT->CLOSED. Caught and fixed a self-contradiction on full-document re-read: original Lens A/B headers still said "not independently re-verified" after the new section claimed full verification -- fixed 3 inline labels in place (Learning 316, PROJECT_LEARNINGS.md). Updated BACKLOG.md (removed the done verification item, added a new READY fix item) and CHANGELOG.md. Commit: 86f0def7.
next_steps: One clear next step: BACKLOG.md's new "Fix Document 1's 15 confirmed audit findings" item (READY, Effort M) -- follow the audit doc's own "Recommendations" priority order (2 HIGH factual fixes first, then 2 MEDIUM with ready-made mechanisms, then TDD-vocab placement, then batch the 9 LOW findings as one editorial pass, A3 optional/opportunistic). Re-render via quarto and clean render artifacts (Learning 314) after fixing; full corpus sweep for stale echoes after (S340 precedent). Separately, "Plan Document 2" (READY, Effort M) remains open and untouched, deferred since S330.
key_files: docs/audits/DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md (now CLOSED; "Session 342 -- Independent Verification" L164-273, "Final Findings Summary" table L275-297, "Recommendations" L299-319), vignettes/articles/engineering-the-2.0.0-release.qmd (read in full, NOT edited -- all 15 findings' current locations cited in the audit doc), BACKLOG.md ("## Documents" section, new fix item), PROJECT_LEARNINGS.md (Learning 316), CLAUDE.md (learnings count 315->316).
gotchas: The audit doc's line-number citations are now current as of this session's re-anchoring (post-S340 drift already corrected) -- but will go stale again if any OTHER session edits the article before the fix session runs; re-anchor again if so (Learning 315). The severity/priority rankings in the Final Findings Summary and Recommendations are this session's own synthesis judgment, not yet shown to the owner or cross-checked by a second reviewer -- treat as a first draft the fix session (or the owner) may want to re-rank. `PED_GV_AUDIT_2026-05-30.html` remains an untouched, pre-existing untracked artifact in the repo root (still flagged, not this session's, not cleaned up).
runtime_smoke: n/a -- docs/audits/, PROJECT_LEARNINGS.md, CLAUDE.md, BACKLOG.md, CHANGELOG.md only; the article itself was not edited (owner's explicit verify-only scope decision); no R/ or tests/ touched, no runtime behavior changed.
changelog_ref: CHANGELOG.md 2026-07-09 "Closed the Document 1 two-lens review: 13 remaining findings independently verified (Session 342)"
commit: 86f0def7
```

```handoff
session: S341
date: 2026-07-09
status: complete
self_score: 7
predecessor_score: 9
active_task: DONE. Backlog curation for S339's open Document 1 audit items + Document 2 planning, plus (owner-directed mid-session) a new session-startup priorities-list convention.
what_was_done: Read the full current article (745 lines) and confirmed, via direct read (not the DRAFT audit's own text), that S339's two already-confirmed-real findings (Lens A #1 -- runGeneKeepR() Phase-9 misattribution, now L170-172; Lens B #1 -- "four sessions...wrote Sections 1-3" contradiction, now L687-688) are still unfixed, and that the audit file's cited line numbers are stale by ~20 lines after S340's edit. Added a BACKLOG.md "## Documents" section with 2 items (close out the two-lens review; plan Document 2), naming both confirmed-unfixed findings, the 13 still-unverified findings, and the line-number-staleness gotcha. Added a CLAUDE.md "### Additional Phase 0 steps" entry (previously "(none)") documenting a (READY | BLOCKED | DECISION NEEDED, Effort S|M|L) tag convention on BACKLOG.md items, rendered at Phase 0 step 7 as a numbered, color-marked, tiered "Current priorities" list -- per the owner's explicit request and a worked example from a sibling project (~/Development/wsfct). Retrofitted all 6 pre-existing open BACKLOG.md items with the tag (LabKey-remainder and CRAN-prep BLOCKED; E2E-CI issue #40 and NEW-12/XARCH-3 READY; tracker-reconciliation DECISION NEEDED) -- the CRAN-prep BLOCKED tag was checked against CHANGELOG.md's S329 CRAN-submission entry, not guessed. Commit: f0755ead.
next_steps: Two independent pickup points, either can go next: (1) the "Close out the Document 1 two-lens review" BACKLOG.md item -- independently re-verify Lens A #2/#3 and Lens B #2-12 (13 findings) against the CURRENT article file (the audit doc's own cited line numbers have drifted), then decide with the owner whether fixes land in that session or a follow-on, then finalize docs/audits/DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md's DRAFT header. (2) "Plan Document 2" -- a fresh planning session for the package purpose/how-to-use article; scope/audience/structure all undecided. Separately: the new Phase 0 priorities-list convention (CLAUDE.md "Additional Phase 0 steps") has not yet been exercised by an actual Orient -- the next session's Phase 0 step 7 is its first live test; the owner has not seen it render yet and may want the shape adjusted.
key_files: BACKLOG.md ("## Documents" section L67-89; READY/BLOCKED/DECISION tags on all 6 pre-existing open items), CLAUDE.md ("### Additional Phase 0 steps" subsection, previously "(none)"), vignettes/articles/engineering-the-2.0.0-release.qmd:170-172 and :687-688 (the 2 confirmed-unfixed findings' current locations, NOT edited this session), docs/audits/DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md (still DRAFT, unchanged, its own line numbers now stale)
gotchas: This session skipped the Phase 1B claim stub before starting technical work (see SESSION_NOTES.md self-assessment) -- low blast-radius (docs-only) but a real process miss, not to be repeated. The priorities-list convention's exact rendering (emoji colors, tier names, tag vocabulary) was designed from a single worked example and has not been shown to the owner in a live Orient report yet -- treat it as a first draft the owner may want to adjust. `PED_GV_AUDIT_2026-05-30.html` is a pre-existing untracked render artifact in the repo root (not from this session) -- still there, not cleaned up, flagged only.
runtime_smoke: n/a -- BACKLOG.md/CLAUDE.md only, no R/ or tests/ touched, no runtime behavior changed.
changelog_ref: CHANGELOG.md 2026-07-09 "Backlog curation for Document 1/2 open items + session-startup priorities-list convention (Session 341)"
commit: f0755ead
```

```handoff
session: S340
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 9
active_task: DONE. Corrected the Shiny-application-history narrative in Document 1 (engineering-the-2.0.0-release.qmd) -- the owner-supplied material information S339 was interrupted to wait for.
what_was_done: Verified the owner's correction against git history before editing: no v1.0.8 GitHub/CRAN release exists (gh release list -- v1.0.7 is "Latest"); the DESCRIPTION Version:1.0.8 bump commit is literally titled "1st attempt at adding modules" (6457a3a3, 2025-12-29), three weeks before the first Claude-co-authored commit (2b225ff8, 2026-01-20); only 4 commits touched inst/application/ between scaffold-start and Phase-9 deletion. Owner then supplied the actual CRAN correspondence (submitted 2025-07-25, published within a day, archived 2025-07-29 "issues were not corrected in time," discovered by owner 2026-01-15, never resubmitted). Confirmed via docs/planning/shiny-module-conversion-plan.md:12 that the "two coexisting apps" framing is real project history (its own XARCH-1 audit finding), just wrongly scoped in the article as "for most of its life" rather than the few months before the migration. Drafted exact replacement text, got owner sign-off via two AskUserQuestion rounds, then edited: Abstract, a new dated CRAN-archival footnote in the Introduction, Section 1's opening paragraph, the Introduction's "Four pillars" summary, and the Conclusion (a full grep sweep after the targeted edits caught these last two stale echoes the owner hadn't named). Softened the issue #27 citation (empty body; only tracked the 2022 intent to modularize). quarto render: 23 chunks, 0 errors; cleaned up render artifacts (Learning 314). Commit: 6dde45cd.
next_steps: S339's DRAFT audit (docs/audits/DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md) still has 13 unverified findings (Lens A #2/#3, Lens B #2-12) -- this session did NOT address or resolve them, only the separate historical-narrative issue the owner raised. A future session should independently re-verify those before acting on them, and should note that neither review lens was scoped to catch factual/historical-accuracy issues like this one (worth naming explicitly, not assuming the two-lens review was exhaustive). Document 2 (package purpose/how-to-use article, deferred since S336) is still not picked up by any session.
key_files: vignettes/articles/engineering-the-2.0.0-release.qmd (Abstract L14-25, Introduction footnote L49-58, "Four pillars" summary L60-63, Section 1 opening L78-94, Conclusion L722-730 -- all edited this session), docs/planning/shiny-module-conversion-plan.md:12 (source of the real "two coexisting apps" XARCH-1 finding), docs/audits/DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md (S339's still-DRAFT review, unchanged and unresolved by this session)
gotchas: The article now correctly distinguishes "the two apps drifted" (true, but only for the months just before the migration) from "two coexisting apps for most of its life" (false) -- do not let a future edit collapse that nuance back into a blanket claim. The CRAN-archival footnote paraphrases the owner's private email correspondence; the owner's home address/phone visible in the forwarded screenshot were deliberately excluded and must stay excluded from any future edit of this passage.
runtime_smoke: n/a -- docs-only change (vignettes/articles/), no R/ package runtime behavior touched.
changelog_ref: CHANGELOG.md 2026-07-09 "Correct the Shiny-application-history narrative in Document 1 (Session 340)"
commit: 6dde45cd
```
<free-text prose: self-score breakdown>

**+ (what went right):** Verified the owner's own correction against git history rather
than accepting it uncritically (found the exact scaffold-start commit, the exact
Claude-adoption date, corroborating evidence in the real migration-planning doc).
Asked before drafting exact wording, twice, for a factual/historical claim rather than
guessing. Ran a full corpus sweep after the targeted edit and caught two additional
stale echoes the owner hadn't named (Introduction summary, Conclusion) -- the kind of
completeness check Learning #7/#10 call for. Verified the render clean and cleaned up
artifacts per Learning 314. Kept the owner's personal contact info out of the public
document.
**- (what could improve):** Did not annotate the still-DRAFT two-lens audit file to
note explicitly that neither lens was scoped to catch this class of issue -- a fair
but real gap, since a future session skimming that audit could otherwise assume its
"DRAFT -- 2/15 findings verified" caveat covers this angle too, when it never was in
scope for either lens.

```handoff
session: S339
date: 2026-07-09
status: complete
self_score: 7
predecessor_score: 8
active_task: PARTIAL, INTERRUPTED BY OWNER (not a crash). Two-lens review of Document 1 (engineering-the-2.0.0-release.qmd) ran to completion on both lenses; owner then said material information will be added in a future session that affects the document, and asked to close out now rather than finalize. Findings preserved in docs/audits/DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md, marked DRAFT -- INCOMPLETE.
what_was_done: Investigated the owner's "earlier session planned two documents" reference -> confirmed via docs/planning/v2-transformation-article-plan.md: Document 1 = this article (drafted S330-336), Document 2 = package purpose/how-to-use (deferred, named in S336's next_steps, never picked up by S337/S338, never in BACKLOG.md). AskUserQuestion -> owner picked reviewing Document 1 this session. Second AskUserQuestion on review approach -> owner picked "two-lens review, report only," matching the S109/S110 precedent. Forked two general-purpose agents in parallel: Lens A (figure/table-vs-frozen-data fidelity) found 3 issues (1 HIGH-confidence real discrepancy: article prose says Phase 9 commit 3db018d1 made runGeneKeepR() canonical, but that commit actually made it the DEPRECATED alias -- it only became canonical later via unrelated commit 1e64dd5d/issue #110/S276, never mentioned in the article; 1 medium-confidence chart-axis issue; 1 low-confidence cosmetic CSV date mismatch, invisible to readers). Lens B (editorial/narrative quality) rated the article 7/10, found 12 issues (most significant: a genuine internal contradiction, line 617 says "three sessions...produced Sections 1-3" vs line 668-669 "four sessions...wrote Sections 1-3"), plus explicit praise for several strong passages. Independently re-verified the single most consequential finding from EACH lens via direct git commands before recording either as confirmed (both held, and in both cases this session's own re-derivation was more precise than the agent's framing). Cleaned up vignettes/articles/ render artifacts one review agent left behind (Learning 314's exact defect class, recognized on sight). Was about to write findings into a docs/audits/ report (checked the project's naming convention first) when interrupted.
next_steps: DO NOT treat docs/audits/DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md as a finished review -- it is explicitly marked DRAFT/INCOMPLETE. Next session: (1) get the owner's promised material information first; (2) independently re-verify the NOT-yet-checked findings (Lens A #2/#3, Lens B #2-12) before acting on any of them -- only Lens A #1 and Lens B #1 were independently confirmed by this session; (3) decide with the owner whether to fix findings this session or a further one; (4) re-render and clean up render artifacts again after any edit (Learning 314); (5) finalize the audit file's status once resolved. Separately, unrelated to this thread: "Document 2" planning is STILL not picked up by any session -- raise it again if the owner wants it prioritized.
key_files: docs/audits/DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md (new, full findings, DRAFT), vignettes/articles/engineering-the-2.0.0-release.qmd:150-153 (Lens A Finding 1 location, NOT yet edited), vignettes/articles/engineering-the-2.0.0-release.qmd:617-618,668-669 (Lens B Finding 1 location, NOT yet edited), docs/planning/v2-transformation-article-plan.md (the original two-document plan, confirms Document 1/Document 2 split)
gotchas: The audit file is a DRAFT snapshot of two forked agents' reports plus this session's spot-verification of exactly 2 of the 15 combined findings -- the other 13 are agent-reported, not independently confirmed; do not upgrade their status without checking. `quarto render` (run by one of the review agents while inspecting figures, not by this session directly) again left untracked .html/_files/.gitignore artifacts in vignettes/articles/ -- cleaned up this session, will recur on any future render (Learning 314, not yet structurally fixed at the .gitignore level).
runtime_smoke: n/a -- no R/ package runtime behavior touched, no article edits made (report-only scope, held even through the interruption).
changelog_ref: CHANGELOG.md 2026-07-09 "Two-lens review of Document 1 -- partial, findings preserved as DRAFT (Session 339)"
commit: 4c39c522
```
<free-text prose: self-score breakdown>

**+ (what went right):** Investigated the owner's reference thoroughly before assuming
scope, rather than guessing which "two documents" they meant. Asked two genuinely-the-
owner's-call scope questions instead of assuming. Matched established project
precedent (two-lens review) rather than inventing new methodology. Did not trust
either forked agent's headline finding at face value -- independently re-derived both
from git, and reached a MORE precise diagnosis than the agent's own framing both
times. Recognized and cleaned up render artifacts on sight from a two-sessions-old
learning. When interrupted mid-task, did not let ~170K tokens of completed agent work
evaporate -- captured it in a durable, explicitly-DRAFT file instead.
**- (what could improve):** Only 2 of 15 combined findings were independently
re-verified before the interruption; the remainder are agent-reported only. Did not
ask the owner, before launching two expensive forked reviews, whether there was
additional context to fold in first -- a cheap check that might have surfaced the
owner's material information earlier and avoided reviewing a version of the document
that's about to change.

```handoff
session: S338
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 10
active_task: DONE. The stale passage in vignettes/articles/engineering-the-2.0.0-release.qmd:487-503 (S336's narration of the shinytest2.yaml CI coverage gap as "currently open") now correctly states the gap was closed by S337 (commit c5ccf69b, live run 29057393786, independently re-verified this session: 15 groups in the current workflow file, run status success/completed).
what_was_done: PRE-RED scope AskUserQuestion (3 options) -> owner picked "prose fix, TDD N/A". Rewrote qmd:487-503 into two paragraphs: para 1 keeps the historical narrative (gap existed 2026-06-11 through 2026-07-08), para 2 states the S337 resolution (new regression test, 2 added CI groups, count-free workflow comment, confirming live run) with the commit sha and run link. Corpus-grepped .qmd/.Rmd/.md for other stale "23 files/13 groups/24 of 26" references -- only hits were dated ledger/planning docs correctly narrating history, none touched. Verified via `quarto render` (23 chunks, 0 errors); cleaned up untracked .html/_files/.gitignore render artifacts the render left in vignettes/articles/ (see gotchas). Independently re-derived (not just trusted from S337's receipt): current workflow file's groups=(...) array has exactly 15 entries incl. the 2 new ones; `gh run view 29057393786` returns status=completed, conclusion=success; commit c5ccf69b exists with the expected message. New PROJECT_LEARNINGS.md Learning 314. Updated CLAUDE.md's learning-count pointer (313->314, Sessions 1-337+ -> 1-338+). Commits: see changelog_ref.
next_steps: No CI/testing work pending from this session. The two dated planning docs matched by the staleness grep (docs/planning/phase8e-assertion-strengthening-subplan.md, docs/planning/issue2-gva-iteration-convergence-plan.md) were confirmed historically-dated and out of scope but not read in full -- a future exhaustive corpus sweep could go further, though nothing indicates a live issue there. No other open item from this session.
key_files: vignettes/articles/engineering-the-2.0.0-release.qmd:487-509 (the rewritten passage), PROJECT_LEARNINGS.md (Learning 314), CLAUDE.md:177 (learning-count pointer)
gotchas: `quarto render`ing any vignettes/articles/*.qmd leaves untracked .html, _files/, and an auto-written .gitignore (for .quarto/) in that subdirectory -- the top-level .gitignore's vignettes/*.html-style patterns are single-level globs and do NOT match vignettes/articles/*.html. Clean these up before staging; confirmed via `git log --all --oneline -- 'vignettes/articles/*.html'` (empty) that no prior session has ever committed rendered output for any sibling article, so absence is the norm, not an oversight.
runtime_smoke: n/a -- docs-only prose change, no R/ package runtime behavior touched. Build-equivalent verification (quarto render, 0 errors) performed instead and stated as this deliverable's actual completeness check, per FM #24.
changelog_ref: CHANGELOG.md 2026-07-09 "Update stale CI-gap narration in the v2.0.0 article (Session 338)"
commit: 195cf2ec
```
<free-text prose: self-score breakdown>

**+ (what went right):** Asked a PRE-RED scope question before any edit, even for a
docs-only change, per the TDD contract. Independently re-derived the key figures
(current CI group count, live-run status, commit existence) rather than trusting
S337's receipt at face value, even though every one of them held exactly. Preserved
the article's historical narrative voice instead of just deleting the stale claim.
Ran the actual build-equivalent (`quarto render`), not just an eyeball diff review.
Caught a genuine, non-obvious repo-hygiene gotcha (render artifacts escaping the
top-level `.gitignore` in this subdirectory) and recorded it as a new learning instead
of silently discarding the evidence. Ran a corpus-wide grep sweep for other stale
references before declaring done.
**- (what could improve):** Did not read the two peripheral planning docs
(`phase8e-assertion-strengthening-subplan.md`, `issue2-gva-iteration-convergence-plan.md`)
in full -- confirmed historically-dated and out of scope from the matched lines alone,
which was adequate for this session's narrow deliverable but not an exhaustive read.

```handoff
session: S337
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 9
active_task: The shinytest2.yaml CI-coverage gap S336 flagged (Learning 312) is FIXED -- all 26 tracked test-{app,e2e}-*.R files now match exactly one of 15 CI groups, guarded by a new regression test. One new cross-deliverable staleness surfaced as a side effect (see gotchas/next_steps): the article's own narration of this gap as "currently open" is now stale.
what_was_done: Re-verified the gap firsthand (git ls-tree + hand-checked all 13 old regexes against all 26 stripped filenames) before touching anything -- exactly reproduced S336's finding (test-e2e-orip-module.R, test-e2e-potential-parents-module.R uncovered). PRE-RED scope AskUserQuestion (3 options) -> owner picked "regression test + fix". RED: wrote tests/testthat/test_shinytest2_workflow_coverage.R -- parses the groups=(...) bash array out of the YAML text and asserts, via the same grepl-after-stripping-test-/.R transform test_dir(filter=) itself uses, that every tracked file matches exactly one group (gap AND overlap checked); confirmed it failed naming exactly the 2 orphaned files, 0 false positives. GREEN gate approved -> added "^e2e-orip-module" and "^e2e-potential-parents-module" to shinytest2.yaml's groups array (matching the existing single-file group style); re-ran the coverage test (passed) and the full clean regression read (1 pre-existing unrelated failure only -- test_vignettes_no_deprecated_minParentAge.R, confirmed pre-existing and unrelated via a git stash A/B of just my 2 changed files). REFACTOR gate approved -> caught that GREEN's own comment/echo updates ("23"->"26", "13"->"15") reintroduced the exact hardcoded-count staleness class being fixed; removed all hardcoded counts from prose and converted the runtime echo message to `${#groups[@]}` (dynamically computed, cannot drift again). Verified: bash -n syntax-check on the extracted run: block (via python yaml.safe_load), dynamic-count sanity check (printed 15 correctly), lintr on the new file (0 lints), full regression read identical before/after refactor. New PROJECT_LEARNINGS.md Learning 313. Updated CLAUDE.md's learning-count pointer (312->313, Sessions 1-336+ -> 1-337+). Commits: see changelog_ref.
next_steps: vignettes/articles/engineering-the-2.0.0-release.qmd:487-503 (written by S336) narrates this CI gap as "a real, currently open gap, not a stale figure this article repeats uncritically" -- that is now FALSE as of this session's GREEN commit. A future documentation-workstream session should update that passage (and check @sec-features / T-tables for any other reference to "24 of 26 covered") to state the gap is closed, citing this session's commit. This is a different capability/deliverable from the CI fix itself -- flagged, not fixed here (same discipline S336 used for the original gap). No other CI/E2E work is pending from this session.
key_files: .github/workflows/shinytest2.yaml:8-27,118-186 (groups array + all count-bearing comments/echo, now count-free/dynamic), tests/testthat/test_shinytest2_workflow_coverage.R (new regression test, full file), PROJECT_LEARNINGS.md (Learning 313), CLAUDE.md:177 (learning-count pointer), vignettes/articles/engineering-the-2.0.0-release.qmd:487-503 (NOT edited -- now stale, flagged above)
gotchas: The article passage above is now a KNOWN STALE cross-reference as a direct, mechanical side effect of this fix -- do not treat "24 of 26 covered, 2 orphaned" as current fact anywhere in the repo; grep for "24 of\|24 covered\|13 hardcoded\|13-group" before trusting any prose claim about this workflow's coverage. The coverage test parses the YAML by locating `groups=(` and the next line matching `^\s*\)\s*$` -- if the array's bash formatting ever changes shape (e.g. inline `)`), the parser needs updating too; it will fail loudly (0 group regexes extracted -> explicit expect_true failure), not silently pass. True live-runner confirmation (an actual `workflow_dispatch`/nightly GitHub Actions run with real Chrome) was NOT performed this session -- only local static verification (parse + syntax + the new test); flagged per FM #24, not silently treated as equivalent.
runtime_smoke: CONFIRMED live -- owner approved triggering it; `gh workflow run shinytest2.yaml --ref master` dispatched run 29057393786, completed success in 18m56s (all 15 per-module groups green, including the 2 new ones for the previously-orphaned files): https://github.com/rmsharp/nprcgenekeepr/actions/runs/29057393786 . Local static verification (YAML parses, bash -n, dynamic ${#groups[@]} sanity check, full testthat regression read before/after REFACTOR) also held.
changelog_ref: CHANGELOG.md 2026-07-09 "Fix CI coverage gap in shinytest2.yaml -- 2 orphaned E2E test files now run (Session 337)"
commit: c22b5e22
```
<free-text prose: self-score breakdown>

**+ (what went right):** full TDD phase-gate discipline -- a PRE-RED scope question plus
all three phase gates (RED/GREEN/REFACTOR), each via `AskUserQuestion`, 0 stakeholder
corrections. Re-verified the gap firsthand (git ls-tree + hand-checked regexes) rather
than trusting S336's handoff numbers at face value, even though they turned out exact.
The RED test mirrors `test_dir(filter=)`'s own matching semantics precisely (not an
approximation) and checks a STRONGER invariant than the minimum ask (overlap, not just
gap). Verified the one other failing test in the suite was pre-existing and unrelated
via a `git stash` A/B rather than assuming. Caught, during my OWN REFACTOR review, that
GREEN's edit reintroduced the identical hardcoded-count defect class being fixed, and
corrected it structurally (a computed count) instead of just re-updating the literal --
this is the session's most valuable catch and it came from taking REFACTOR seriously as
a real phase, not a rubber stamp. Proactively found and flagged (without touching, correct
scope discipline) that the fix stales a DIFFERENT already-shipped document.

**- (what could improve):** skipped the Phase 1B claim stub -- did not write a
`SESSION_NOTES.md`/`HANDOFFS.md` stub before starting technical work; caught only at
close-out. No actual harm this session (it completed normally with no crash), but it is
a real protocol miss that should not recur. Did not perform true live-runner (GitHub
Actions `workflow_dispatch`) verification -- strong local static verification instead,
flagged explicitly rather than silently treated as equivalent, but genuinely not the
same confirmation. Found the stale article passage because I already knew from S336's
own handoff to look at it, not from an independent full-corpus grep sweep for other
possible mentions of the old counts (README, other planning docs) -- a more exhaustive
sweep might have found something I didn't check for.

```handoff
session: S336
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 9
active_task: v2-transformation-article-plan.md is now FULLY EXECUTED (Phase A through Phase F, no Phase G). A real, currently-open CI gap was discovered as a side effect (see gotchas/next_steps) and is unfixed, flagged for a future session. CRAN 2.0.0 review outcome still pending, independent of this plan.
what_was_done: Drafted Abstract (200 words) + Introduction + Conclusion (verbatim NIH grant ack) in engineering-the-2.0.0-release.qmd; Section 5 cut and F6 skipped per two owner AskUserQuestions at kickoff. Ran the full-document claim-source audit (workstream Phase 6) via two parallel forked adversarial-verification passes across all 8 sections (~55 claims), each independently re-derived from git/gh/grep, not the plan's own summary table -- then independently re-verified all 4 reported mismatches firsthand before editing. Fixed 4 real defects: (1) Section 1 misattributed the inst/application/ deletion commit (3db018d1 -> 24992e0b, the correct Phase-9-Part-2/3 commit); (2) Section 2's issue #34 "years later" overclaim -> "about five months later" (gh issue view: 2026-01-20 to 2026-06-12); (3) Section 4's "four sessions that produced Sections 1-3" -> "three" (git log confirms S332/S333/S334); (4) Section 3's CI-coverage claim was stale -- the 13-group E2E CI partition covers 24 of 26 opt-in test files, not "23, no gap"; rewrote to state current verified figures. Full verification chain: quarto render (zero unresolved refs) -> pkgdown::build_article("articles/engineering-the-2.0.0-release") (clean) -> R CMD build . + tar tzf (zero CRAN risk confirmed). Found the plan's own "four existing articles" claim stale (six exist) and rendered all six. Marked Phase F DONE in the plan's Sec7, ticked all 10 Sec10 checklist items, resolved all 4 Sec12 open decisions. Added PROJECT_LEARNINGS.md Learning 312. Commits: 268df760 (S336 claim stub), plus this receipt's own commit (see changelog_ref).
next_steps: No Phase G -- the plan is fully executed. Before anything else: triage the CI-gap defect this session found (see gotchas) -- it needs its own small TDD-governed session, not a continuation of this one. Beyond that, three independent, not-pre-decided directions: (1) the CI-gap fix if prioritized; (2) "Document 2" (package purpose/how-to-use, explicitly out of scope for this plan) needs a fresh planning session per the owner's 2026-07-09 instruction; (3) resume whatever the CRAN 2.0.0 review outcome requires once it arrives.
key_files: vignettes/articles/engineering-the-2.0.0-release.qmd (Abstract/Introduction/Conclusion added; 4 claim-audit fixes applied to Sections 1-3-4), docs/planning/v2-transformation-article-plan.md (Phase F closure note, Sec10 checklist ticked, Sec12 decisions resolved), .github/workflows/shinytest2.yaml:127-141 (the groups=(...) array needing 2 more regexes -- NOT edited this session, flagged only), PROJECT_LEARNINGS.md (Learning 312), CLAUDE.md:177 (learning-count pointer)
gotchas: REAL, CURRENTLY-OPEN DEFECT (not this session's to fix): .github/workflows/shinytest2.yaml's 13-group E2E CI partition covers 24 of 26 files in the opt-in test-(app|e2e)-*.R tier -- test-e2e-potential-parents-module.R (issue #48, S82) and test-e2e-orip-module.R (issues #47/#49, S86) match none of the 13 hardcoded group regexes and never run in CI. Fix: add 2 group regexes to groups=(...) at shinytest2.yaml:127-141, update the header comment's stale "23...no gap" claim, verify via a live triggered workflow run (a local test_dir(filter=) dry run confirms the regex match but not the job itself). Separately: a full-document claim audit run AFTER each phase individually verified its own section can still find real defects a per-section review has no way to catch (drift from unrelated LATER sessions' changes) -- do not treat a phase's own "DONE, verified" status as exempt from a later cross-document audit.
runtime_smoke: n/a -- documentation/article-drafting session, no R/ package runtime behavior changed; the full verification chain (quarto render + pkgdown::build_article() + R CMD build ./tar tzf + all 6 pre-existing articles re-rendered) is this deliverable's actual build-equivalent verification, performed and confirmed
changelog_ref: CHANGELOG.md 2026-07-09 "Phase F of the Document-1 article plan: Abstract/Introduction/Conclusion, full claim audit, full verification chain (Session 336) -- plan now fully executed"
commit: bca11e5d
```
<free-text prose>

**+ (what went right):** did not rubber-stamp Sections 1-4 as already-DONE just
because prior sessions had verified them at draft time -- ran the full-document audit
the plan's own checklist actually requires and it found 4 real, independently
confirmed defects, one of them (the CI gap) a genuinely new class this project hadn't
named before: a claim that was true when its own session verified it and went false
later purely from unrelated sessions changing the world elsewhere. Correctly
separated "discover and report" from "fix" for that CI gap -- documenting it
precisely and flagging it to the owner rather than either silently patching CI
mid-documentation-session (scope creep) or silently ignoring a defect the audit
surfaced (the exact failure the audit exists to prevent). Independently re-verified
every fork-reported finding firsthand before touching the article, per the
"adversarial refutation applies to your own agents' output too" guidance -- all 4
held, but only because they were checked, not assumed. Caught that the plan's own
"four existing articles" instruction was itself stale and rendered the fuller,
correct set of six rather than literally matching a stale instruction.

**- (what could improve):** the two forked audit passes were split by section count
(4 sections each) decided before either ran, not by claim density -- wall-clock came
out ~229s vs ~281s, a modest but real imbalance; a finer split might parallelize more
evenly next time. Did not sweep the rest of the repo (planning docs, README) for
other prose that might also repeat the now-stale "23-file CI tier" claim beyond the
workflow file and the article itself -- no other location was identified as likely,
but the search wasn't exhaustive.

```handoff
session: S335
date: 2026-07-09
status: complete
self_score: 8
predecessor_score: 8
active_task: Phase E of docs/planning/v2-transformation-article-plan.md is DONE. Phase F (assemble/consolidate/verify/publish -- Abstract, Introduction, optional Section 5, Conclusion, full §10 Verification Checklist incl. pkgdown::build_article()/R CMD build tarball check) is next and is the publish gate (§9 dragon #3: public URL, not fully reversible in practice). F6 screenshot reuse still needs an owner AskUserQuestion before Phase F touches vignettes/shiny_app_use/. CRAN 2.0.0 waiting period (from S329) is unchanged and independent.
what_was_done: Added Section 4 ("An AI-Assisted Development Process") + T6 (@tbl-process-metrics, 9-row process-metrics table) + F4 (@fig-tdd-cycle, Mermaid stateDiagram-v2 of RED->GREEN->REFACTOR with AskUserQuestion gate annotations) + F5 (@fig-self-score-trend, ggplot2 line chart, session-chronological order) to engineering-the-2.0.0-release.qmd, reading Phase A's frozen process-metrics.csv/self-score-trend.csv unchanged. Both T6 and F5 carry an explicit "Phase A data freeze (Session 331)" caption stating the source files are live and had already grown past the frozen snapshot by this session -- verified firsthand: live CHANGELOG.md is 317 entries and live PROJECT_LEARNINGS.md is 310, vs. the frozen 309/305. Reordered F5's rows by session number (frozen CSV's date-only sort left same-day sessions in reverse-numeric order) without mutating the frozen file, matching T2's established client-side-reorder precedent; flagged that Sessions 329-330 postdate the range's own end commit (8ca8bb24) despite sharing its calendar date, verified via git log timestamps. Independently verified 3 claim-map facts rather than trusting the summary table alone: SESSION_RUNNER.md's failure-mode table has exactly 27 rows, Session 324 is genuinely the earliest complete HANDOFFS.md receipt, and the Session-325 CHANGELOG ledger-format-resolution date. Cited the 4-consecutive-session commit-sha-backfill self-correction pattern (cc0f7798/2278b46f/ee690776/5f0b81d2, all real commits) as concrete evidence of the ledger mechanism working. quarto render succeeded; T6/F4/F5 resolved as Table 5/Figure 4/Figure 5, zero unresolved refs. F4's first version had a real defect quarto render's exit code could not catch: a \n inside Mermaid transition labels (wrongly modeled on F2's flowchart <br/> syntax) rendered as a literal backslash-n, not a line break -- caught by statically rendering the extracted .mmd via npx mermaid-cli and inspecting the actual PNG (rsvg-convert was tried and rejected -- it doesn't support Mermaid's foreignObject label elements and showed a worse, misleading false defect); fixed by keeping each label on one line, re-verified via mermaid-cli then re-rendered the full article. Cleaned up render artifacts before staging. Commits: bd3b3fcf (S335 claim stub), 9c4fbf93 (Phase 0 ledger backfill for 5f0b81d2, this session's own reconcile-on-read finding), plus this receipt's own commit (see changelog_ref).
next_steps: Phase F of the article plan -- the publish gate. Draft Abstract, Introduction, optional Section 5 (owner decision per plan §12.2 -- recommend drafting only if Sections 1-4's own tables don't already summarize), Conclusion (NIH grant ack, P51 RR13986/P51 OD011092). Then the full §10 Verification Checklist across ALL FOUR sections (not just Section 4): quarto render + pkgdown::build_article() + R CMD build . + tar tzf (zero CRAN risk, S107-110 precedent -- fuller chain than Phase A-E used), spot-check the 4 pre-existing articles still render, F6 needs an explicit owner AskUserQuestion before vignettes/shiny_app_use/ is touched.
key_files: vignettes/articles/engineering-the-2.0.0-release.qmd (Section 4 + T6/F4/F5 appended), vignettes/articles/data/process-metrics.csv + data/self-score-trend.csv (read, not modified -- Phase A's frozen data, now confirmed stale vs. live CHANGELOG.md/PROJECT_LEARNINGS.md), docs/planning/v2-transformation-article-plan.md (header status line + §7 Phase E marked DONE), PROJECT_LEARNINGS.md (Learning 311), CLAUDE.md:177 (learning-count pointer), CHANGELOG.md (backfill entry for undocumented commit 5f0b81d2, prepended during this session's own Phase 0 reconcile)
gotchas: T6/F5's source files (CHANGELOG.md/PROJECT_LEARNINGS.md/HANDOFFS.md/SESSION_NOTES.md) are LIVE, still-growing files read at a point in time (Phase A, Session 331) -- unlike T5's git-ls-tree-at-sha data, these numbers will keep drifting further from the article's own numbers every session; any future session citing T6 should say "as extracted at the Phase A freeze," never "current." Mermaid stateDiagram-v2 transition labels do NOT support \n for line breaks (unlike F2's flowchart <br/>) -- keep labels one line, or verify with mermaid-cli before trusting quarto render's exit code (new Learning 311). BACKLOG.md's stale "#40 open" line remains unpruned -- flagged 4 consecutive sessions now (S333-S335, S334 twice) -- prune next time BACKLOG.md is open for any reason.
runtime_smoke: n/a -- documentation/article-drafting session for vignettes/articles/ support, no R/ package runtime behavior changed; quarto render + a standalone mermaid-cli PNG render (caught and fixed a real Mermaid label defect) is this deliverable's actual build-equivalent verification, performed and confirmed
changelog_ref: CHANGELOG.md 2026-07-09 "Phase E of the Document-1 article plan: drafted Section 4 (AI-assisted development process) + T6/F4/F5 (Session 335)"
commit: 33f943e0
```
<free-text prose, self-score breakdown>

**+ (what went right):** independently re-verified 3 claim-map facts rather than trusting
the plan's own summary table (FM-27 count, Session-324 receipt start, live-vs-frozen
CHANGELOG/PROJECT_LEARNINGS drift); caught a real Mermaid rendering defect invisible to
`quarto render`'s exit code by extending the verification method itself (standalone
`mermaid-cli` PNG render), documented as new Learning 311 for future sessions; fixed a
genuine data-presentation bug (F5's stable-sort row order) without mutating frozen data,
matching established precedent; held scope tightly (no F6, no Section 5, no `BACKLOG.md`
edit -- the conditional instruction was evaluated and correctly found not to trigger).

**- (what could improve):** F4's first drafted version had the `\n` defect at all --
avoidable if Mermaid's `stateDiagram-v2` label syntax had been checked or
verification-rendered before writing the "real" version into the article, rather than
after; did not independently spot-check the `stakeholder_correction_zero_mentions`/
`nonzero_mentions` grep pattern against a hand sample of `SESSION_NOTES.md`, taking the
frozen 269/2 split from the plan's own claim-map row without an independent sanity check.

**Predecessor (Session 334) evaluation: 8/10.** Handoff correctly scoped Phase E and
correctly sourced the F5 coverage caveat, but did not flag that T6/F5's own source files
are live snapshots that would have drifted further by Phase E -- a gap this session had
to discover and verify independently. Full evaluation in `SESSION_NOTES.md`.

```handoff
session: S334
date: 2026-07-09
status: complete
self_score: 8
predecessor_score: 9
active_task: Phase D of docs/planning/v2-transformation-article-plan.md is DONE. Phase E (draft Section 4 -- Claude CLI/methodology, risk HIGH dragon -- + T6/F4/F5, reading process-metrics.csv and self-score-trend.csv) is next. Phase F must come last. 2 open owner decisions from the plan's §12 remain (optional Section 5 at Phase F; F6 screenshot reuse -- did not gate Phase D, likely doesn't gate Phase E either). CRAN 2.0.0 waiting period (from S329) is unchanged and independent.
what_was_done: Added Section 3 ("Testing at Scale") + T5 (@tbl-testing-growth) + F3 (@fig-testing-growth) to engineering-the-2.0.0-release.qmd, reading Phase A's frozen testing-growth.csv unchanged. Cross-checked both endpoint rows against git ls-tree at the exact commits (4548aa1b/8ca8bb24) -- exact match, but surfaced that the CSV's test_file_count column counts ALL .R files under tests/testthat/ (incl. 4 helper/setup files), not just test*.R -- traced to the extraction script's actual line of code (build-document1-evidence.R:121), not guessed; wrote table/prose to state precisely what's counted (new Learning 310). Verified via gh issue view + CHANGELOG.md session headers that BOTH issue #39 (harness-enable, 8a-8d, closed 2026-06-06) and issue #40 (assertion-hardening, 8e-1..8e-7, closed 2026-06-11) are CLOSED -- contradicts BACKLOG.md's stale "#40 open" line (not fixed, scope discipline). Narrated the harness's full arc (dormant scaffold -> executable -> hardened) sourced to both Phase-8 subplans + CHANGELOG.md session entries, not estimated. quarto render caught a real defect on first render (F3's top data label clipped by the y-axis range) -- fixed with scale_y_continuous(expand=...) and re-rendered to confirm. Marked Phase D DONE in the plan's §7, explicitly flagging that T5's "(if extractable) coverage" hedge was NOT populated (no coverage data in the frozen CSV). Commits: baa5c99d (S334 claim stub), 62339088 (Phase 0 ledger backfill for ee690776, this session's own reconcile-on-read finding), plus this receipt's own commit (see changelog_ref).
next_steps: Phase E of the article plan -- draft Section 4 (Claude CLI/methodology) + T6/F4/F5, reading process-metrics.csv and self-score-trend.csv (both already frozen by Phase A). F5 has a stated coverage caveat (plan §6): HANDOFFS.md receipts only cover recent (Session-325-era) sessions -- state that limitation in the caption, don't imply full-range coverage. Re-read PROJECT_LEARNINGS.md's own framing before drafting to confirm the section doesn't contradict this project's documented failure modes/corrections (the plan's own Phase E verification step).
key_files: vignettes/articles/engineering-the-2.0.0-release.qmd (Section 3 + T5/F3 appended), vignettes/articles/data/testing-growth.csv (read, not modified -- Phase A's frozen 5-checkpoint data), vignettes/articles/data-raw/build-document1-evidence.R:108-131 (T5/F3 extraction logic, read to resolve the column-definition question), docs/planning/v2-transformation-article-plan.md (§1/§7 Phase D marked DONE, coverage-hedge flagged), docs/planning/phase8-e2e-harness-subplan.md + docs/planning/phase8e-assertion-strengthening-subplan.md (read for harness-status sourcing), PROJECT_LEARNINGS.md (Learning 310), CLAUDE.md:177 (learning-count pointer), BACKLOG.md (read, confirmed stale on #40 again, not modified -- flagged 3x now across S333/S334)
gotchas: testing-growth.csv's test_file_count is "all .R files in tests/testthat/", not "test*.R files" -- future sessions citing this column should use the same precise framing, not "test file count" bare. BACKLOG.md's "#40 open" line is stale for the third consecutive flagged session (S333, S334) without a fix -- next session that opens BACKLOG.md for any reason should just prune it. F6 screenshot reuse still needs an owner decision but has not gated either Phase C or Phase D -- likely won't gate Phase E's T6/F4/F5 either (Phase E's dragon is tone/T6-extraction, not screenshots). The 8e-7 CI flake-mitigation number ("~1 error / 5 runs") is sourced to the subplan's own self-report, not independently re-measured -- correctly caveated in the article as subplan-sourced, but note if a future audit wants a stronger source.
runtime_smoke: n/a -- documentation/article-drafting session for vignettes/articles/ support, no R/ package runtime behavior changed; quarto render (output HTML + PNG inspected directly, one defect caught and fixed) is this deliverable's actual build-equivalent verification, performed and confirmed
changelog_ref: CHANGELOG.md 2026-07-09 "Phase D of the Document-1 article plan: drafted Section 3 (testing at scale) + T5/F3 (Session 334)"
commit: 735a3f2a
```
<free-text prose, self-score breakdown>

**+ (what went right):** verified the frozen CSV against primary git data before trusting
it (caught a real column-definition ambiguity, not a bug in the data itself); verified
harness status against primary sources (gh issue view, CHANGELOG) rather than the
plan's own hedge or the stale BACKLOG.md line; caught and fixed a real render defect
(clipped data label) by looking at the actual output image, not just the exit code;
held scope tightly (no F6, no Section 4/5, no BACKLOG.md fix); produced a new,
generalizable learning (310) rather than silently fixing the discrepancy and moving on.

**- (what could improve):** flagged BACKLOG.md's staleness a third time without
fixing it -- should have just fixed it this session once it was clear the pattern was
repeating (a small, unambiguous, one-line prune, not scope creep); did not independently
re-verify the 8e-7 flake-rate claim beyond its own subplan source.

**Score: 8/10.** Matches S333's standard: solid verification discipline, one small
scope-discipline judgment call (BACKLOG.md) flagged rather than silently repeated a
fourth time.

```handoff
session: S333
date: 2026-07-09
status: complete
self_score: 8
predecessor_score: 9
active_task: Phase C of docs/planning/v2-transformation-article-plan.md is DONE. Phase D (draft Section 3 -- testing at scale -- + T5/F3, reading testing-growth.csv and cross-checking e2e/shinytest2 status against phase8-e2e-harness-subplan.md, NOT against BACKLOG.md's stale #40-is-open line) is next. Phases D-E remain reorderable; Phase F must come last. 2 open owner decisions from the plan's §12 remain (optional Section 5 at Phase F; F6 screenshot reuse before Phase D/E -- now directly relevant since Phase D is testing). CRAN 2.0.0 waiting period (from S329) is unchanged and independent.
what_was_done: Hand-curated feature-candidates.csv's 47 raw closed-issue candidates down to 13 (28%) genuinely feature-shaped items, reading each borderline candidate's actual CHANGELOG entry rather than trusting closedAt/labels alone -- caught and excluded 3 issue-hygiene closes of pre-range functionality (#34/#14/#8; #34's own entry says "No code changed"). Wrote vignettes/articles/data/feature-highlights.csv (13 curated rows, T2/T3's frozen-CSV-via-kableExtra pattern). Added Section 2 ("New Capabilities in 2.0.0") + T4 to engineering-the-2.0.0-release.qmd: 3 prose clusters (parent identification/species-awareness x5, GVA uncertainty x4, dashboards/activations x2 + 2 smaller fixes). Fulfilled Section 1's forward-reference to modGeneticDiversity/modPotentialParents; correctly distinguished modORIPReporting's pre-existing code from its in-this-section activation. Marked Phase C DONE in the plan's §7. Verified via quarto render: @tbl-features resolved as Table 3, zero unresolved refs, 13/13 rows present. Verified 3 single-commit citations (0eeee3f6, d4320643, 14c8e84d) both resolve and are ancestors of HEAD. Also backfilled undocumented commit 2278b46f (S332's own receipt sha fix) into CHANGELOG.md during Phase 0 reconcile. Commits: 17333a1f (Phase 0 CHANGELOG backfill), 7cd0f395 (S333 claim stub), 4dcc6869 (article + T4 data), cdda9d35 (plan-doc Phase C DONE), 307c9c77 (learnings+pointer), a01e13ce (CHANGELOG+SESSION_NOTES+this receipt's own commit).
next_steps: Phase D of the article plan -- draft Section 3 (testing) + T5/F3, from testing-growth.csv. Cross-check e2e/shinytest2 harness status against phase8-e2e-harness-subplan.md + CHANGELOG.md directly -- BACKLOG.md's "#40 is open" line is stale (verified CLOSED 2026-06-11 via gh issue view). Get an owner decision on F6 screenshot reuse before touching vignettes/shiny_app_use/.
key_files: vignettes/articles/engineering-the-2.0.0-release.qmd (Section 2 + T4 appended), vignettes/articles/data/feature-highlights.csv (new, this session's curated output -- not a Phase A artifact, no regeneration script by design), docs/planning/v2-transformation-article-plan.md (§1/§7 Phase C marked DONE), PROJECT_LEARNINGS.md (Learning 309), CLAUDE.md:177 (learning-count pointer), vignettes/articles/data/feature-candidates.csv (read, not modified -- the 47 raw candidates), BACKLOG.md (read, found stale on #40, not modified -- flagged not fixed, scope discipline)
gotchas: feature-highlights.csv is Phase C's own hand-curated output, not auto-generated -- do not assume a script produced it. A closed issue's closedAt date is not evidence of in-range work (Learning 309) -- always read the actual CHANGELOG entry for borderline candidates in future curation passes (Phase D/E will face the same raw-closed-issue-list risk). BACKLOG.md's "Up Next" section is stale on issue #40 (claims open, actually CLOSED 2026-06-11) -- not fixed this session (scope discipline), Phase D should prune it. F6 screenshot reuse still needs an explicit owner decision, now directly relevant to Phase D. Phase F's own sha-resolution checklist item should sweep this session's 3 single-commit citations too, not just T3's (S332-flagged).
runtime_smoke: n/a -- documentation/article-drafting session for vignettes/articles/ support, no R/ package runtime behavior changed; quarto render (output HTML inspected for resolved cross-refs + correct row count) is this deliverable's actual build-equivalent verification, performed and confirmed
changelog_ref: CHANGELOG.md 2026-07-09 "Phase C of the Document-1 article plan: drafted Section 2 (new features) + T4 (Session 333)"
commit: a01e13ce
```

```handoff
session: S332
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 9
active_task: Phase B of docs/planning/v2-transformation-article-plan.md is DONE. Phase C (draft Section 2 -- new features -- + T4, curating vignettes/articles/data/feature-candidates.csv's 47 raw candidates) is next. Phases C-E remain reorderable; Phase F must come last. 2 open owner decisions from the plan's §12 remain (optional Section 5 at Phase F; F6 screenshot reuse before Phase D/E) but neither blocked Phase B. CRAN 2.0.0 waiting period (from S329) is unchanged and independent.
what_was_done: Owner confirmed the proposed title/slug via AskUserQuestion. Wrote vignettes/articles/engineering-the-2.0.0-release.qmd -- Section 1 (Shiny modules, issue #27, the nine-phase migration Session 22->35), T2 (module inventory, kableExtra, flags 2 of 10 modules as post-migration additions), T3 (nine-phase migration summary, states Phases 3-7 have no quoted sha and Phase 8 was a compound multi-session DONE), F1 (ggplot2 commit-activity chart), F2 (native Quarto Mermaid before/after architecture diagram, no new dependency). Marked Phase B DONE in the plan's §7. Verified via quarto render: cross-references resolved in the output HTML, Mermaid runtime correctly wired -- not just exit code 0. Re-verified live: 4,731 total module lines (wc -l, matches frozen C1 exactly), all 10 modules currently mounted (correcting a stale "only 6 mounted" snapshot in the older planning doc), the "17 files" inst/application/ deletion count (cross-checked against CHANGELOG.md's own Phase-9 entry). Also backfilled one undocumented commit (cc0f7798, S331's own receipt sha fix) into CHANGELOG.md during this session's Phase 0 reconcile. Commits (6, to respect the 5-file blast-radius cap): 6c0eb75f (Phase 0 CHANGELOG backfill), bbd59276 (S332 claim stub), e6bc887f (article), 5501c347 (plan-doc Phase B DONE), 86711601 (learnings+pointer), b051c883 (CHANGELOG+SESSION_NOTES+this receipt's own commit).
next_steps: Phase C of the article plan -- draft Section 2 (new features) + T4, curating (not re-extracting) from vignettes/articles/data/feature-candidates.csv's 47 raw closed-issue candidates. Phases C-E are reorderable, Phase F must come last. Before Phase F specifically: verify each T3 commit sha still resolves in git log (this session reused Phase A's already-verified C3 shas but did not independently re-run git log -1 <sha> for each this session -- see gotcha below).
key_files: vignettes/articles/engineering-the-2.0.0-release.qmd (new, Section 1 + T2/T3/F1/F2), docs/planning/v2-transformation-article-plan.md (§1/§7 Phase B marked DONE), PROJECT_LEARNINGS.md (Learning 308), CLAUDE.md:177 (learning-count pointer), vignettes/articles/data/module-inventory.csv + migration-phases.csv + commit-activity-timeline.csv (read, not modified -- this phase's data source), R/appUI.R + R/appServer.R (read via grep for live module-mount verification, not modified)
gotchas: feature-candidates.csv is 47 RAW candidates, not curated -- Phase C must hand-select feature-worthy items. After any quarto render used for in-session verification, run git status --porcelain on vignettes/articles/ and delete generated .html/_files/render-.gitignore before staging -- the top-level .gitignore's vignettes/*.html glob does not reach the articles/ subdirectory (Learning 308); this will recur every future rendering phase. vignettes/shiny_app_use/ screenshots (F6) remain untouched, need explicit owner confirmation before Phase D/E touches them. The stakeholder-correction-rate number (C14) is a mention-count proxy, not a verified audit -- Section 4 prose (Phase E) must state that limit explicitly. F5 self-score-trend data covers only S324-S330 (7 sessions), a partial window. T3's commit shas were reused from Phase A's already-verified C3 values, not independently re-run this session -- do a final git log -1 <sha> pass before Phase F's publish gate (the plan's own §10 checklist already requires this).
runtime_smoke: n/a -- documentation/article-drafting session for vignettes/articles/ support, no R/ package runtime behavior changed; quarto render (output HTML inspected for resolved cross-refs + correctly-wired Mermaid assets) is this deliverable's actual build-equivalent verification, performed and confirmed
changelog_ref: CHANGELOG.md 2026-07-09 "Phase B of the Document-1 article plan: drafted Section 1 (Shiny modules) + T2/T3/F1/F2 (Session 332)"
commit: b051c883
```

```handoff
session: S331
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 8
active_task: Phase A of docs/planning/v2-transformation-article-plan.md is DONE. Phase B (draft Section 1 + T2/T3/F1/F2) is next, reading from the frozen CSVs. 3 open owner decisions from the plan's §12 remain (title/slug, optional Section 5, F6 screenshot reuse) but none blocked Phase A -- they gate later phases specifically. CRAN 2.0.0 waiting period (from S329) is unchanged and independent.
what_was_done: Wrote vignettes/articles/data-raw/build-document1-evidence.R (checked-in, reproducible extraction script) producing 7 frozen CSVs under vignettes/articles/data/ (module-inventory, migration-phases, feature-candidates [47 raw closed-issue candidates], testing-growth, commit-activity-timeline, process-metrics, self-score-trend). Completed the plan's §3 Claim-Evidence Map (14 dated/sha-anchored rows, C1-C14) and marked Phase A DONE in §7. Corrected two inaccuracies in S330's plan with hard evidence: (1) resolved the §2 first-session-number gotcha -- true Session 1 begins at 6fd87749 (2026-05-30), inside the ratified range, not predating v1.0.8; 328 sessions (Session 1 -> S328) fall within the range. (2) corrected "Phases 1-9 all marked DONE" -- Phase 8 expanded into subplan 8a-8d (issue #39) then hardening pass 8e-1..8e-7 (issue #40, Session 37-50), visible only in the phase body + CHANGELOG.md. Spot-checked 12 numbers by hand, all confirmed exactly. Added PROJECT_LEARNINGS.md Learnings 306-307, updated CLAUDE.md's learning-count pointer (305->307). Commits (5, to respect the 5-file blast-radius cap): 0d98efc9 (script+4 CSVs), 92a6d85e (remaining 3 CSVs), 1ddbf0c5 (plan doc), b8c89420 (learnings+pointer), 046b62d5 (this receipt's own commit).
next_steps: Phase B of the article plan -- draft Section 1 (Shiny modules) + tables T2/T3 + figures F1/F2, reading from vignettes/articles/data/*.csv. Phases B-E are reorderable (no hard dependency), Phase F must come last. Owner may resolve the remaining 3 open §12 decisions before/at the relevant phase (title at Phase B kickoff; Section 5 at Phase F; F6 screenshots before Phase D/E). Independently, CRAN 2.0.0 waiting period continues unchanged.
key_files: vignettes/articles/data-raw/build-document1-evidence.R (new, this session's extraction script), vignettes/articles/data/*.csv (7 new frozen files), docs/planning/v2-transformation-article-plan.md (§2/§3/§7 updated), PROJECT_LEARNINGS.md (Learnings 306-307), CLAUDE.md:177 (learning-count pointer), docs/planning/shiny-module-conversion-plan.md §9 (T3 source, read not modified), docs/planning/phase8-e2e-harness-subplan.md (Phase-8 correction source, read not modified)
gotchas: Phase B drafts .qmd prose for the first time -- read plan §4/§7 Phase B criteria first; T2/T3 read directly from frozen CSVs, no new extraction needed. feature-candidates.csv is 47 RAW candidates, not curated -- Phase C must hand-select feature-worthy items. vignettes/shiny_app_use/ screenshots (F6) remain untouched, need explicit owner confirmation before any future phase touches them. The stakeholder-correction-rate number (C14) is a mention-count proxy, not a verified audit -- Section 4 prose must state that limit explicitly. F5 self-score-trend data covers only S324-S330 (7 sessions), a partial window not a full-range trend.
runtime_smoke: n/a -- data-extraction/tooling session for vignettes/articles/ support, no R/ package runtime behavior changed
changelog_ref: CHANGELOG.md 2026-07-09 "Phase A of the Document-1 article plan: froze the evidence base (Session 331)"
commit: 046b62d5
```

```handoff
session: S330
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 9
active_task: Plan for Document 1 written and DRAFT (not yet approved for implementation). Owner still needs to confirm 4 open decisions (§12 of the plan) before Phase A begins. CRAN 2.0.0 waiting period (from S329) is unchanged and independent of this work.
what_was_done: Wrote docs/planning/v2-transformation-article-plan.md (352 lines) -- a planning-session deliverable for "Document 1," a public Quarto pkgdown article describing the v1.0.8->v2.0.0 transformation (Shiny modules, new features, testing, Claude CLI use). Adapted RESEARCH_DOCUMENTATION_WORKSTREAM.md's claim-source/figure-provenance discipline to this repo's own evidence (git log, CHANGELOG.md, PROJECT_LEARNINGS.md, HANDOFFS.md) in place of external citations. Verified the exact commit-range boundary via CRAN-SUBMISSION's git history (4548aa1b..8ca8bb24, 512 commits) rather than accepting the owner's phrasing loosely. Read shiny-module-conversion-plan.md in full (primary source for Section 1) and discovered the already-adopted Quarto/pkgdown-articles policy (Session 105) before asking a format question, resolving it as settled rather than open. Asked one AskUserQuestion (public vs internal visibility) -- owner chose public. Proposed 7 tables + 6 figures with purpose/source/generation/provenance each, a 6-phase (A-F) session breakdown, 4 dragons, and an adapted verification checklist. Added PROJECT_LEARNINGS.md Learning 305 (mine docs/planning/ for decided policy before asking format questions; CHANGELOG.md grep off-by-one gotcha) and updated CLAUDE.md's learning-count pointer (302->305). Commit: b93f36de (claim stub: d2275494).
next_steps: Owner reviews docs/planning/v2-transformation-article-plan.md and resolves the 4 open decisions in its §12 (title/slug, keep-or-cut Section 5, F6 screenshot reuse, commit-range framing ratification). Once approved, Phase A (build and freeze the evidence base) is the next session -- see the plan's §7. Independently, the CRAN 2.0.0 waiting period from S329 continues (owner's email-confirmation click, then CRAN's review outcome) -- unrelated and not blocking.
key_files: docs/planning/v2-transformation-article-plan.md (new, this session's deliverable), docs/planning/shiny-module-conversion-plan.md (read in full, primary Section-1 source), docs/planning/quarto-documentation-future-proofing-analysis.md:163-237 (Quarto/pkgdown-articles policy), PROJECT_LEARNINGS.md (Learning 305), CLAUDE.md:177 (learning-count pointer), SESSION_NOTES.md (S330 handoff), HANDOFFS.md (this receipt)
gotchas: The plan is a DRAFT -- do not start Phase A without owner approval of the 4 open §12 decisions. vignettes/shiny_app_use/ screenshots must not be touched without explicit owner confirmation (possibly hand-curated). Section 4's evidentiary metrics (self-score trend, TDD adherence rate, correction counts) do not exist yet -- Phase A/E must do real extraction. The exact first-session-number boundary for the 512-commit range is unverified (a same-session grep found a plausible but uncross-checked S1) -- resolve in Phase A before it becomes a document claim.
runtime_smoke: n/a -- planning/documentation session, no R/ package runtime behavior changed
changelog_ref: CHANGELOG.md 2026-07-09 "Wrote the Document-1 (v1.0.8->2.0.0 technical writeup) planning doc (Session 330)"
commit: b93f36de
```

```handoff
session: S329
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 9
active_task: CRAN 2.0.0 submitted successfully. Awaiting owner's email confirmation click, then CRAN's review outcome. Phase 6 (tag + release + dev-version bump) gated on the acceptance email, not yet started.
what_was_done: Owner reported devtools::submit_cran() upload succeeded. Verified firsthand via git diff CRAN-SUBMISSION (auto-written by devtools, not hand-edited): Version 1.0.8/2025-07-26 -> Version 2.0.0/2026-07-09 17:57:22 UTC/SHA 8ca8bb24 (the exact commit submitted, matching origin/master HEAD at submission time). Committed the updated CRAN-SUBMISSION (legitimate expected artifact, consumed/deleted later by Phase 6's use_github_release()). Updated the plan doc's Phase 5 status block (new SUBMITTED note with version/date/SHA evidence) and Sec9 table Phase 5b row (marked partial-done, since CRAN's review outcome is still pending). Added PROJECT_LEARNINGS.md Learning 304 (4 consecutive sessions each discovered a needs-attention file only after starting the claim, not before -- write the Phase 1B stub the moment a task is understood, before any exploratory read). Commit: 8bb126ce (claim stub: ac871a65).
next_steps: Owner clicks the maintainer-email confirmation link CRAN sends to rmsharp@me.com -- without it the submission never reaches CRAN review. After that, this is a pure waiting period (CRAN's automated + human review, historically ~1 day to a couple weeks) -- no action available until CRAN's acceptance or rejection email arrives. Phase 6 is a separate future session, strictly gated on that email. If the owner wants other work meanwhile, one of the 8 open GitHub issues (#116, #37, #36, #28, #12, #11, #10, #5) remains available.
key_files: CRAN-SUBMISSION (auto-updated, committed as-is), docs/planning/cran-2.0.0-submission-plan.md (Phase 5 SUBMITTED note + Sec9 row), PROJECT_LEARNINGS.md (Learning 304), SESSION_NOTES.md (S329 handoff), HANDOFFS.md (this receipt)
gotchas: Do not start Phase 6 until CRAN's acceptance email actually arrives -- submission succeeding != CRAN accepting; CRAN-SUBMISSION still being present (not deleted by use_github_release()) is itself the signal Phase 6 hasn't happened. Write the Phase 1B claim stub before touching ANY file, including read-only exploration -- per new Learning 304, a confirmed 4-session pattern. If CRAN comes back requiring changes rather than a clean accept, that reopens Phase 2/4-class work, not Phase 6 -- read the actual rejection content before assuming what's needed.
runtime_smoke: n/a -- documentation of an owner-taken milestone, no R/ package runtime behavior changed
changelog_ref: CHANGELOG.md 2026-07-09 "CRAN 2.0.0 submitted to CRAN submission team (Session 329)"
commit: 8bb126ce
```

```handoff
session: S328
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 9
active_task: Phase 5b cross-platform checks complete and clean (win-builder x3 0/0/1 expected NOTE, R-hub linux/windows/macos 0/0/0). cran-comments.md fully populated. Only remaining: owner's submit_cran() HARD STOP.
what_was_done: After the S327 .Rbuildignore fix, owner re-ran the full Phase 5b runbook. win-builder x3 all came back 0/0/1 NOTE -- fetched each 00check.log directly and confirmed the remaining note is exactly the expected CRAN-incoming-feasibility note (EHR/Raboin/kinships, correctly spelled). R-hub v2: windows+macos Status:OK on first run (verified via gh run view --log, not just job-success flag); linux failed at setup-deps (Pandoc download 504, confirmed transient infra via the actual log, matching runbook precedent) then Status:OK on a linux-only re-run (watched both runs via gh run watch in background). Updated cran-comments.md: filled in both Test-environments placeholders with real results, reconciled NOTE 1's misspelled-words list to the exact set win-builder flagged (EHR/Raboin/kinships, dropped LabKey/Macaca mulatta) per the runbook's own Sec4.2 instruction. Updated the plan doc's Phase 5 status block + Sec9 table row. Commit: 7517124d (claim stub: 8fcc9170).
next_steps: Owner runs devtools::submit_cran() (or the web form) and clicks the maintainer-email confirmation link -- the plan's HARD STOP, cannot be delegated. After CRAN accepts, Phase 6 (tag + GitHub release + dev-version bump to 2.0.0.9000) is a separate future session, only after the acceptance email. Otherwise one of the 8 open GitHub issues (#116, #37, #36, #28, #12, #11, #10, #5) remains available.
key_files: cran-comments.md (Test environments filled in, NOTE 1 words reconciled), docs/planning/cran-2.0.0-submission-plan.md (Phase 5 status completion note + Sec9 row), SESSION_NOTES.md (S328 handoff), HANDOFFS.md (this receipt)
gotchas: submit_cran() is the owner's action only -- do not attempt to trigger it even if asked to "finish Phase 5b." Three consecutive sessions (S326/S327/S328) each briefly edited a file before writing the Phase 1B claim stub, self-caught every time before a commit landed -- not yet a formal PROJECT_LEARNINGS entry, but a 4th recurrence should trigger one.
runtime_smoke: n/a -- cran-comments.md is .Rbuildignore'd prose, no R/ package runtime behavior changed
changelog_ref: CHANGELOG.md 2026-07-09 "Fold Phase 5b cross-platform results into cran-comments.md, all clean (Session 328)"
commit: 7517124d
```

```handoff
session: S327
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 7
active_task: .Rbuildignore gap fixed and verified. Owner needs to re-run the Phase 5b runbook (win-builder x3 + R-hub v2) against the corrected tree before folding results into cran-comments.md and submitting.
what_was_done: Owner ran the S326-handed-off Phase 5b runbook; all 3 win-builder results came back 0/0/2 NOTEs. NOTE 1 matched cran-comments.md's pre-explained content. NOTE 2 was new and real (not the plan's anticipated local-HTML-manual note): "Non-standard files/directories found at top level: BOOTSTRAP.md, CONTEXT_TEMPLATE.md, HANDOFFS.md, dashboard_history.jsonl" -- confirmed identical across all 3 logs via WebFetch of each 00check.log. Root cause: S324 methodology sync added these (3 tracked root docs + 1 gitignored-but-not-Rbuildignored generated file) after the S322 local gate ran; gitignore and Rbuildignore are separate mechanisms. Fixed: 4 anchored lines added to .Rbuildignore's existing "Methodology framework files" section. Verified: R CMD build . + tar tzf grep -- files no longer ship, top-level listing back to standard set; artifact removed, not committed. Updated the plan doc (Phase 5 status correction note, new Dragon #11, Sec9 table) and added PROJECT_LEARNINGS.md Learning 303. Commit: c1fc47b9 (claim stub: a1dadfd3).
next_steps: Owner re-runs win-builder x3 against a freshly built tarball (should come back 0/0/1 NOTE now); re-runs rhub::rhub_check() once this fix is pushed (the in-flight run checked the pre-fix tree); folds clean results into cran-comments.md's Test environments section + reconciles the misspelled-words list; then submit_cran() is the owner's HARD STOP action.
key_files: .Rbuildignore (4 new lines), docs/planning/cran-2.0.0-submission-plan.md (Phase 5 status correction + Dragon #11 + Sec9 row), PROJECT_LEARNINGS.md (Learning 303), SESSION_NOTES.md (S327 handoff), HANDOFFS.md (this receipt)
gotchas: The 3 completed win-builder runs and the in-flight R-hub run all reflect the PRE-FIX tree -- do not treat them as final; re-run all cross-platform checks after this fix is pushed. Before any future cross-platform run, diff the root-level file listing against .Rbuildignore coverage directly (a git-log-scoped R/tests/DESCRIPTION drift check cannot see new root-level files, per Dragon #11 / Learning 303).
runtime_smoke: n/a -- build-hygiene/config fix, no R/ package runtime behavior changed; verified via R CMD build + tar tzf per Phase 1's own classification
changelog_ref: CHANGELOG.md 2026-07-09 "Fix .Rbuildignore gap surfaced by win-builder NOTE 2 (Session 327)"
commit: c1fc47b9
```

```handoff
session: S326
date: 2026-07-08
status: complete
self_score: 8
predecessor_score: 8
active_task: CRAN 2.0.0 Phase 5b readiness re-verified, zero drift found. Still PENDING, owner-triggered (win-builder x3 + R-hub v2 need the owner's GitHub PAT and email). 8 open GitHub issues untouched, no priority set among them.
what_was_done: Asked the owner via AskUserQuestion how to scope Phase 5b (verify-only vs. live-run vs. attempt-to-trigger); owner chose verify-only. Confirmed zero drift since S322/S323: git log --oneline 2abfc783..HEAD -- R/ tests/ DESCRIPTION empty; origin/master 0/0 vs HEAD; DESCRIPTION Version still 2.0.0; cran-comments.md and the Phase5 runbook re-read clean; Rscript introspection confirmed devtools 2.5.2/rhub 2.0.1/gitcreds 0.1.2 installed with function signatures still matching the runbook's calls. Added a verification-status note to docs/planning/cran-2.0.0-submission-plan.md's Phase 5 status block + Sec9 table row. No R/tests/DESCRIPTION/cran-comments.md/runbook changes needed. Commit: 4e6193cb (claim stub: a9ebea7e).
next_steps: Either (a) owner runs the Phase 5b runbook (docs/planning/cran-2.0.0-phase5-runbook.md Quick sequence) whenever ready -- folding real results into cran-comments.md and submitting is a separate future session -- or (b) pick up one of the 8 open GitHub issues (#116, #37, #36, #28, #12, #11, #10, #5) -- owner's call, none more urgent.
key_files: docs/planning/cran-2.0.0-submission-plan.md (Phase 5 status block + Sec9 table Phase 5b row), SESSION_NOTES.md (S326 handoff), HANDOFFS.md (this receipt), CHANGELOG.md (new [ad hoc] entry)
gotchas: Phase 5b's actual cross-platform runs remain owner-only -- don't trigger devtools::check_win_*()/rhub::rhub_check() without explicit owner request, despite the plan's Phase 5 prose reading as "fine for the agent to run"; the runbook's SAFEGUARDS framing + repeated owner precedent (S135/S242/S320/S323/S325/S326) overrides that. When adding a HANDOFFS.md receipt, insert directly after the "Receipts go below, newest on top" sentinel comment, not under the "Three files..." heading (this session's own near-miss, self-caught before commit).
runtime_smoke: n/a -- docs/planning-only, no R/ package runtime behavior changed
changelog_ref: CHANGELOG.md 2026-07-08 "CRAN 2.0.0 Phase 5b readiness re-verified, zero drift (Session 326)"
commit: 4e6193cb
```

```handoff
session: S325
date: 2026-07-08
status: complete
self_score: 8
predecessor_score: 7
active_task: CHANGELOG.md ledger-format gap resolved (freeze legacy, go forward). CRAN 2.0.0 Phase 5b remains owner-triggered, not started. 8 open GitHub issues untouched, no priority set among them.
what_was_done: Added an "Authoritative Action Ledger" intro + "How to add an entry" section (source-tag rules: [issue #<N>]/[BL-<N>]/[ad hoc]) to CHANGELOG.md, copied from the real canonical starter-kit/CHANGELOG.md seed (~/Development/methodology). Added a "## Legacy history (pre-ledger format, Sessions 1-324)" boundary marker; the 303 existing entries below it are byte-for-byte unchanged. Wrote this session's own action as the first canonical-format entry above the marker. Updated CLAUDE.md's Adaptations section (CHANGELOG-gap note -> resolution note; corrected a stale "33 learnings" pointer to the actual 302). Backfilled HANDOFFS.md's S324 commit:pending field to 0c3af8b9. Added PROJECT_LEARNINGS.md Learning 302. Commit: 07ae8aec (claim stub: 68f3117f).
next_steps: Either (a) resume docs/planning/cran-2.0.0-submission-plan.md Phase 5b (owner-triggered win-builder x3 + R-hub v2), or (b) pick up one of the 8 open GitHub issues (#116, #37, #36, #28, #12, #11, #10, #5) -- owner's call, none more urgent.
key_files: CHANGELOG.md:1-61 (new intro/how-to-add-an-entry/legacy-marker/S325 entry), CLAUDE.md (Adaptations section), HANDOFFS.md (S324 commit backfill), PROJECT_LEARNINGS.md (Learning 302)
gotchas: New CHANGELOG.md entries always go above "## Legacy history", never inside it. Every new entry needs exactly one [issue #<N>]/[BL-<N>]/[ad hoc] source tag. Neither CRAN Phase 5b nor any open issue is more urgent than another right now.
runtime_smoke: n/a — docs-only, no R/ package runtime behavior changed
changelog_ref: CHANGELOG.md 2026-07-08 "Adopt the canonical Authoritative Action Ledger format going forward (Session 325)"
commit: 07ae8aec
```

```handoff
session: S324
date: 2026-07-08
status: complete
self_score: 8
predecessor_score: 9
active_task: Methodology sync to canonical v3.4 — complete. CRAN 2.0.0 Phase 5b (win-builder/R-hub) remains owner-triggered, not started this session.
what_was_done: Ran bin/sync --source=local --force (full unshallowed clone of KJ5HST/methodology, cross-checked against rmsharp/methodology fork) to update SESSION_RUNNER.md, SAFEGUARDS.md, RECOMMENDED_SKILLS.md, methodology_dashboard.py, docs/methodology/{ITERATIVE_METHODOLOGY,HOW_TO_USE}.md, all 9 docs/methodology/workstreams/*.md; created BOOTSTRAP.md, CLAUDE_TEMPLATE.md, CONTEXT_TEMPLATE.md, HANDOFFS.md. Manually refreshed docs/methodology/README.md (not manifest-tracked). Updated CLAUDE.md (FM count 25->27, new CHANGELOG ledger-gap note) and .gitignore (dashboard_history.jsonl). CHANGELOG.md entry: 2026-07-08 Session 324. Commit: 0c3af8b9.
next_steps: Either (a) resume docs/planning/cran-2.0.0-submission-plan.md Phase 5b — owner-triggered win-builder x3 + R-hub v2, see SESSION_NOTES.md S323 entry — or (b) run a dedicated CHANGELOG.md ledger-format migration session per CLAUDE.md's new Adaptations note (canonical v3.1+ ledger format vs. this project's ~30+-session dated-subsection history).
key_files: CLAUDE.md (Adaptations section, FM-count + CHANGELOG-gap edits), CHANGELOG.md:17-28 (this entry), PROJECT_LEARNINGS.md Learning 301 (shallow-clone / force-overwrite-verification findings), .gitignore (dashboard_history.jsonl), SESSION_RUNNER.md + SAFEGUARDS.md (full canonical replace, now v3.4)
gotchas: CHANGELOG.md is deliberately still old-format (SEED disposition, bin/sync never auto-migrates it) — do not force new-format `[SOURCE]`-tagged entries into it without a dedicated migration pass. Any future methodology sync MUST git fetch --unshallow the canonical clone first, or bin/status falsely reports every TRACKED file as "locally modified" (Learning 301).
runtime_smoke: n/a — docs/infra-only, no R/ package runtime behavior changed
changelog_ref: CHANGELOG.md 2026-07-08 "Update methodology to canonical v3.4 (Session 324)"
commit: 0c3af8b9
```
Synced this project's methodology tooling from a stale v2.6 to the current canonical v3.4 (8 tagged releases), per the user's literal BOOTSTRAP.md-documented request. Verified before force-overwriting the two flagged files (no real customization lost — traced to a prior session's pre-release wording adoption, not a hand-edit). Deferred the CHANGELOG.md ledger-format migration as its own future task rather than bundling a large history reformat into this sync, per the tool's own documented guidance. Self-score 8/10: +diligent verification before any destructive action (shallow-clone bug caught, fork cross-check, project-term grep before --force), +correct scope boundary (didn't reformat 30+ sessions of CHANGELOG history), +adopted the new HANDOFFS.md receipt immediately rather than waiting for a future reconcile; -did not open a Phase 1B pending stub for this deliverable before starting (the new protocol requiring it wasn't yet synced in when the task began — retroactive rather than upfront), -did not restate "TDD Phase: N/A" inline at the top of each chat response per CLAUDE.md's literal enforcement rule during this task. Predecessor (S323) scored 9/10 on documentation quality/completeness alone — its CRAN-plan handoff was not exercised this session since the user redirected to an unrelated deliverable, which is not a mark against it.
