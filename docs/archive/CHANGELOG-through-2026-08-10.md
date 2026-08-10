# CHANGELOG.md — archive: 2026-07-08 → 2026-08-10

Retired records from [`CHANGELOG.md`](../../CHANGELOG.md), moved here so the live ledger stays small enough to read
in one pass. Same format, same newest-on-top order — this is the same ledger, continued.

Holds **288 record(s), 2026-07-08 → 2026-08-10**. Cut key: `2026-08-10`. Counts here are computed from the file
itself, never carried forward. This shard is frozen: it states no forward-looking rule,
because the live file owns those and a copy of one was wrong a day after it was written.

---

### 2026-08-10 · [ad hoc] Claim Session 509 — lossless trim of CHANGELOG.md/HANDOFFS.md (Session 509)
- **Deliverable (in progress):** losslessly trim `CHANGELOG.md` and `HANDOFFS.md` via the existing
  `methodology_trim.py` tool, addressing the dashboard's HIGH risk flag (both files past the
  2,000-line agent-`Read` truncation cap: `CHANGELOG.md` 10,503 lines/1,532,752 B, `HANDOFFS.md`
  4,877 lines/832,338 B) and MEDIUM byte-budget-archive-trigger flags (23.3x/12.7x over the
  65,536 B budget, no prior archive of either). Picked via `AskUserQuestion` "Other" over this
  session's own 4 rendered BACKLOG priority options. Logged here ahead of the trim itself because
  `methodology_trim.py`'s own P1 pre-check refuses to write while any commit sits undocumented past
  this ledger's frontier. Commit: `7a423398` (Phase 1B claim stub + pending `HANDOFFS.md` receipt).

### 2026-08-10 · [ad hoc] Remove 4 of 9 checked-but-unmigrated BACKLOG.md items (ad hoc — not a claimed session)
- **Deliverable:** deleted 4 `- [x]` checked items already fully described here (S467, S476, S484,
  S468/S465), confirmed by session-number grep before removal. 5 of the original 9 were
  deliberately kept: `517`/`557` (a mutually-referencing pair — 557 reads "from the item above",
  517 reads "filed below as its own item"; 517 is also referenced by name from a third, still-open
  location) and `1098`/`1147`/`1206` (a three-item chain, each saying "the ... item immediately
  below," plus an incoming reference to `1147` from the same third location) — removing any one of
  either cluster would have orphaned a live "item above/below" pointer. Found by grepping the whole
  file for `item above|item below|immediately` before deleting anything, the same discipline used
  for wsfct's analogous `BACKLOG.md` cleanup.
- **Verification:** `_scan_backlog_done()` (this methodology's own detector) read `{done: 9}` before,
  confirmed by direct `grep -c` after the edit; diff showed exactly 221 removed lines across exactly
  the 4 intended `- [x]` blocks (56 + 63 + 11 + 91), nothing else touched.
- **Not done here, disclosed:** the remaining 5 checked items are legitimately done (each has a
  matching entry below) but not migrated, because their own text is load-bearing for a sibling
  item's cross-reference. Rewriting those references so the items *could* be safely removed is a
  separate, judgment-heavier task, deliberately not attempted in this pass (FM #17).

### 2026-08-10 · [ad hoc] Reconcile HANDOFFS.md's preamble to the v3.1+ seed format (ad hoc — not a claimed session)
- **Deliverable:** inserted a `## Size, and when to archive` section into `HANDOFFS.md`, copied from
  the current `starter-kit/HANDOFFS.md` seed (methodology v3.6-255-gc43e7ee), between the end of
  the `## Format` section and the first real receipt (`S508`). Front-matter merge only — none of
  the file's existing receipts were touched. The file's own pre-existing `## Three files, three
  questions, one shared key` section (already present, mid-file at its original session's
  position) was left as-is, not duplicated.
- **Verification:** single-hunk diff, 57 insertions / 0 deletions; byte-exact `diff` confirmed
  everything from the `S508` receipt onward is unchanged; `bin/status ../nprcgenekeepr` flipped
  `HANDOFFS.md` from `present (stale format)` to `present`.
- **Not fixed here, disclosed:** `python3 methodology_trim.py --file HANDOFFS.md --check` now
  fires — 832,338 B against the 65,536 B budget (12.7×), no prior archive. A real, much larger
  archive job for its own future session (FM #17) — this session only made the size policy
  visible, it didn't act on it.

### 2026-08-10 · [ad hoc] Reconcile CHANGELOG.md's preamble to the v3.1+ seed format (ad hoc — not a claimed session)
- **Deliverable:** inserted a `## Size, and when to archive` section into `CHANGELOG.md`, copied
  from the current `starter-kit/CHANGELOG.md` seed (methodology v3.6-255-gc43e7ee), between the
  end of `## How to add an entry` and `## [Unreleased]`. Front-matter merge only — none of the
  existing dated entries or the `## Legacy history (pre-ledger format, Sessions 1-324)` section
  were touched. Added one project-specific note under `### The shard convention` clarifying that
  the existing `Legacy history` boundary is a one-time in-file format transition, not a shard —
  a future archive still creates a separate `docs/archive/` file on top of it.
- **Verification:** single-hunk diff, 86 insertions / 0 deletions; byte-exact `diff` confirmed
  everything from `## [Unreleased]` onward is unchanged; `bin/status ../nprcgenekeepr` flipped
  `CHANGELOG.md` from `present (stale format)` to `present`.
- **Not fixed here, disclosed:** `python3 methodology_trim.py --file CHANGELOG.md --check` now
  fires — 1,527,578 B against the 65,536 B budget (23.3×), no prior archive. Same disclosure as
  above — visible now, not acted on.

### 2026-08-10 · [ad hoc] Sync methodology-framework tracked files from canonical (ad hoc — not a claimed session)
- **Deliverable:** `SESSION_RUNNER.md`, `BOOTSTRAP.md`, `methodology_dashboard.py`,
  `RECOMMENDED_SKILLS.md`, `CLAUDE_TEMPLATE.md`, `docs/methodology/ITERATIVE_METHODOLOGY.md`,
  `docs/methodology/HOW_TO_USE.md`, `docs/methodology/workstreams/DEVELOPMENT_WORKSTREAM.md`, and
  `docs/methodology/workstreams/AUDIT_WORKSTREAM.md` updated to canonical (methodology
  v3.6-255-gc43e7ee) via `bin/sync`; `FRAMEWORK_LEARNINGS.md` and `methodology_trim.py` created
  fresh (were missing entirely). Adopter-owned seeds (`CHANGELOG.md`, `HANDOFFS.md`,
  `SESSION_NOTES.md`, `ROADMAP.md`) untouched by design.
- **Commit:** `18d8e3c7`, committed locally only (not pushed to `origin/master`).
- **Verification:** `bin/status ../nprcgenekeepr` re-run post-sync shows all tracked files
  `current`.
- **Note:** performed via a Claude Code session in the sibling `../methodology` repo, not a
  claimed nprcgenekeepr session — backfilled here because it was never logged when made (FM #27).

### 2026-08-10 · [issue #146] Slice 1 shipped — mechanical `maxCandidates` parameterization (Session 508)
- **Deliverable:** `groupAddAssign()`'s previously-hardcoded `5L` candidate-retention cap
  (`R/groupAddAssign.R:200`, the only literal site) is now a `maxCandidates = 5L` argument;
  `R/modBreedingGroups.R` gained a matching **Candidates to retain** numeric input (default 5,
  range 1-50 per the ratified plan's D6) threaded through `runFormation()`'s existing
  defensive-default pattern. Per Slice 1 of the ratified
  `docs/planning/issue146-configurable-exhaustive-breeding-group-retention-plan.md` §5. Picked from
  this session's own Phase 0 priorities list.
- **TDD:** full strict PRE-RED→RED→GREEN cycle, `AskUserQuestion`-gated at every transition;
  REFACTOR owner-confirmed skip (implementation already minimal/mechanical). 5 new tests: 2 direct
  `groupAddAssign()` tests (real `qcBreeders` fixture, lowered to 3 and raised to 8, proving the old
  hardcode is gone in both directions), 1 UI-control-presence test, 2 `testServer` tests against the
  real (unmocked) `modBreedingGroupsServer` reactive code — only the terminal `groupAddAssign()` call
  itself mocked — proving `input$maxCandidates` reaches the real argument at both the unset-default
  and an explicit value. The first attempt at the default-case test passed vacuously before any
  server change (the mock's own default happened to also be 5L); caught and fixed with a sentinel
  default before treating RED as satisfied.
- **Verification:** full clean regression suite 0 failed/0 error (5050 passed, 175 skipped, 15
  pre-existing baseline warnings unchanged); `lintr::lint_package()` 0 lints; `devtools::check()` 0
  errors/0 warnings/1 pre-existing note (vignette-engine, unchanged). Live `shinytest2` smoke test:
  the new control renders with the correct default (5) on a fresh app load, 0 console errors; a live
  run with `maxCandidates=1` consistently and correctly caps the rendered candidate dropdown to
  exactly 1 option (3/3 runs). The "raise above 5" half of the live differential proof was
  inconclusive (the bundled fixture converges to a single dominant partition live across every
  parameter combination tried, unlike a direct non-live `groupAddAssign()` call against the same
  fixture) — an incidental, out-of-scope finding, not investigated further; the parameter's
  correctness is independently proven by the direct-function and `testServer` tests above. See
  `BACKLOG.md`'s S508 progress note for full detail.
- **Docs:** `NEWS.Rmd`/`NEWS.md` updated. Citation/tutorial-article/`_pkgdown.yml` checklists N/A per
  the ratified plan's own §6/§9. `a2interactive.Rmd` coverage deferred per its own standing rule.
- **Issue #146 stays open** — Slice 2 (exhaustive enumeration + UI) is the natural next pickup, its
  own future session.

### 2026-08-10 · [issue #146] Design/architecture document ratified — configurable/exhaustive breeding-group candidate retention (Session 507)
- **Deliverable:** `docs/planning/issue146-configurable-exhaustive-breeding-group-retention-plan.md`,
  following `ARCHITECTURE_WORKSTREAM.md` (owner-picked via the established #133/#136/#137/#145/#147/
  #149 precedent of using the architecture workstream over the literal `DESIGN_WORKSTREAM.md`
  task-mapping). Design/planning only — no `R/`, `tests/`, or `man/` content changed. Picked from
  this session's own (corrected) Phase 0 priorities list — the owner flagged that the ratified
  `GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` order for issues #146-153 was missing from
  the initial rendering; corrected before the pick was made (see the Learning 506 entry below).
- **Design:** splits issue #146 into 2 vertical slices, matching the sequencing audit's own
  recommendation. **Slice 1** parameterizes `groupAddAssign()`'s hardcoded top-5 candidate-retention
  cap into a `maxCandidates` argument (mechanical, byte-identical default). **Slice 2** adds a
  bounded exhaustive-enumeration mode: a new internal `.enumerateMaximalIndependentSets()` helper
  (hand-rolled Bron-Kerbosch-style maximal-independent-set search directly on the existing `kin`
  conflict-adjacency list, citing Bron & Kerbosch 1973 / Tomita, Tanaka & Takahashi 2006), scoped to
  `numGp==1`/no harem/no custom sex ratio, gated by a two-layer feasibility guard
  (`maxExhaustiveCandidates`, a hard pre-flight ceiling; `exhaustiveTimeLimit`, a wall-clock runtime
  deadline), reporting new `exhaustive`/`examined`/`retentionRule` fields. Nine design decisions
  (D1-D9); four genuine judgment calls ratified via a single `AskUserQuestion` round — owner selected
  this document's own recommended option in all four cases: exhaustive-mode scope + `stop()`-on-
  violation error semantics (D2/D9); hand-rolled algorithm over a new `igraph` dependency (D4);
  feasibility-guard defaults `maxExhaustiveCandidates = 20L`/`exhaustiveTimeLimit = 10` seconds (D5),
  empirically grounded in this session's own original benchmark; and shipping the UI toggle in
  Slice 2 itself rather than deferring it (D8).
- **Empirical grounding:** an original, this-session-only benchmark (a throwaway, un-pivoted
  Bron-Kerbosch enumerator timed against synthetic conflict graphs) found a counter-intuitive,
  load-bearing result — lower-kinship (more diverse) candidate pools are *slower* to exhaustively
  enumerate, not faster (n=20 at 5% density: 5.5s; n=25 at 5% density: >60s, both unoptimized). Also
  confirmed the real `qcBreeders` fixture (29 candidates, `numGp=2`) already produces 1000 distinct
  partitions across 1000 random trials — direct in-repo evidence that exhaustive enumeration is
  intractable beyond `numGp=1` at realistic scale, the basis for D2's scope boundary.
- **Process fix, same session:** `PROJECT_LEARNINGS.md` Learning 506 and a `CLAUDE.md` amendment to
  the Phase 0 priorities-list customization — a flat `BACKLOG.md` tag grep alone misses a ratified
  sequencing-audit's own prose-only pickup order; this exact gap independently hit both S506's own
  handoff `next_steps` field and this session's own initial Phase 0 rendering before the owner caught
  it directly.
- No code changed — design/planning only, matching the #133/#136/#137/#147/#149 precedent. Issue
  #146 intentionally left open; next session in this cluster implements Slice 1.
- See `BACKLOG.md`'s genetic-metrics-audit progress note, `PROJECT_LEARNINGS.md` Learning 506.

### 2026-08-10 · [ad hoc] Phase 0 ledger reconcile: backfill S506's own SESSION_NOTES.md/HANDOFFS.md close-out commit (post-S506)
- **Deliverable:** Phase 0 ledger reconcile (this session, S507) found one commit past the
  `CHANGELOG.md` frontier with no ledger entry: `45d62e87` ("docs: S506 close-out — twin-connector
  color fully shipped, handoff evaluation, self-assessment"), landed after S506's own CHANGELOG/
  BACKLOG/Learning commit (`c07de6ef`) that recorded the entry below.
- **Change:** `45d62e87` filled in S506's `SESSION_NOTES.md` (Session 505 handoff evaluation, the
  "What Session 506 Did" writeup, and the self-assessment) and finalized the S506 `HANDOFFS.md`
  receipt from its Phase 1B `status: pending`/`pending`-field stub to `status: complete` with all
  six Minimum Handoff Requirements filled — writing up the just-finished session's own handoff, not
  new production work. Same class of self-referential fix as S506's own backfill of S505's
  equivalent commit (`68008f8d`), and the many prior sessions' equivalents further down this
  ledger (S466-S505).

### 2026-08-10 · [BL-twinConnectorColor] Twin-connector color wired — issue #137 D10, `#009E73` on both `edgeStyle` values (Session 506)
- **Deliverable:** `.buildTwinConnectorEdges()` (`R/makePedigreeDiagramData.R`) now sets
  `color = "#009E73"` (Okabe-Ito bluish-green) on every MZ/DZ/UZ twin connector edge — D10's own
  color pick, ratified at issue #137 Slice 2's own Pre-RED (2026-08-03) but never actually wired
  into the function (found S494, `BACKLOG.md` Housekeeping). All 3 codes share one color; only
  the dash pattern + label distinguish them (matching D6's own decision structure). Both
  `edgeStyle` values now carry it through: `makePedigreeDiagramData()`/
  `makePedigreeMatingLayout()`'s direct-style edges prime `color = NA` alongside their existing
  `label` priming so the rbind onto the twin connector's own color-bearing row doesn't fail; a
  **second, previously undiscovered dragon** in `.addRectilinearWaypoints()` — an unconditional
  `keptEdges$color <- rep(NA_character_, ...)` that silently clobbered ANY incoming edge color
  under `edgeStyle = "rectilinear"`, the exact same anti-pattern issue #133 already named and
  fixed on the NODE side of this same function — is now a preserve-if-absent conditional
  mirroring that precedent. `R/modPedigree.R`'s Diagram-tab legend (`twinLegendEdges`) gains the
  matching color swatch on all 3 rows.
- **Verification:** 11 new/extended `test_that()` assertions across 4 files
  (`test_makePedigreeDiagramData.R`, `test_makePedigreeMatingLayout.R`,
  `test_addRectilinearWaypoints.R`, `test_modPedigree.R`), confirmed genuinely RED against
  unmodified `HEAD` (`git stash -u` comparison: baseline `failed: 11, passed: 5031`; GREEN
  `failed: 0, passed: 5042` — an exact +11/-11 delta, 0 change to the 15 pre-existing baseline
  warnings). `lintr::lint_package()`: 0 lints. `devtools::check()`: 0 errors/0 warnings,
  pre-existing notes only (vignette-engine NOTE, spelling-drift diff) — one new session-caused
  spelling word ("unwired") found and fixed by rewording to "never wired," not added to
  `inst/WORDLIST` (Learning 495/501 precedent). **Live `shinytest2` smoke test** against the real
  running app (twin pedigree + twin-relations fixture upload): confirmed
  `color:"#009E73"` on the live-rendered MZ/DZ connector edges (via
  `w.network.body.data.edges.get()`, the same live-DataSet technique
  `test-e2e-pedigree-module.R` already uses) AND the legend's 3 rows, under BOTH `edgeStyle`
  values — directly proving the rectilinear dragon-fix works live — zero throw-level/SEVERE
  console entries.
- **Documentation:** `NEWS.Rmd`/`NEWS.md` (existing twin-connector bullet gained a color clause)
  and `vignettes/manual_components/_pedigree_browser.Rmd` (same gap, same fix) — a visible
  rendering change to an already-shipped, already-documented feature, not a new tab/control.
  `colony-manager-guide.qmd` has no twin-connector mention at all — a separate, pre-existing gap
  (issue #139's own scope), reported not fixed.
- See `PROJECT_LEARNINGS.md` Learning 505 (the second dragon: a deferred design decision, once
  finally wired, was the first real value to ever flow through
  `.addRectilinearWaypoints()`'s edge-color-reset path, exposing a 3-session-dormant defect
  structurally identical to an already-fixed, already-named precedent on the node side).

### 2026-08-10 · [issue #149] Slice 2 implemented — full modCrossCenterIdentity Shiny module: UI, confirm gate, exports, documentation, closes issue #149 (Session 505)
- **Deliverable:** the full end-to-end workflow the ratified design promised
  (`docs/planning/issue149-cross-center-identity-mapping-workflow-plan.md` §5 Slice 2). New
  `R/modCrossCenterIdentity.R`: `modCrossCenterIdentityUI`/`modCrossCenterIdentityServer` — 3
  file uploads (Center A/B pedigrees + identity mapping), a "Validate Mapping" action button
  gating a `checkCrossCenterMapping()`-backed Validation tab (every issue shown at once,
  including a structural-upload-error fallback folded into the same row shape), a Preview tab
  computing `resolveCrossCenterIds()` plus 2 new internal helpers
  (`.buildCrossCenterLineagePreview()`/`.buildCrossCenterMergeProvenance()`, reusing Slice 1's
  own `.rewriteCrossCenterIds()`/`.pickCrossCenterParent()` directly per D6), a
  `shiny::modalDialog()` confirmation gate (D7, this app's first-ever use of the function), and
  5 downloadable export artifacts (D8: Merged Pedigree, Mapping, Validation Results, Merge
  Summary, Provenance). Wired additively into `R/appUI.R` (new "Cross-Center Identity" tab) and
  `R/appServer.R` (self-contained, no `shared$...` args per D3). Followed
  `DEVELOPMENT_WORKSTREAM.md` under this project's Strict TDD contract (PRE-RED→RED→GREEN,
  `AskUserQuestion`-gated at every transition; REFACTOR owner-confirmed skip — implementation
  already matches the ratified design's own decomposition).
- **Verification:** 17 new test blocks in new `tests/testthat/test_modCrossCenterIdentity.R`
  (5 UI-shape, 4 validation, 3 confirm-gate, 3 export, 2 internal-helper) plus a new
  `modCrossCenterIdentity` registration in `tests/testthat/test_moduleContract.R` (D9's
  `list(mergedPedigree, issues, confirmed)` contract), 0 regressions. Full clean regression
  suite 0 failed/0 error (5026 passed, 175 skipped, 15 pre-existing warnings — confirmed
  unrelated via a `git stash -u` comparison). `lintr::lint_package()` 0 lints on touched files
  (2 `brace_linter` hits fixed). `devtools::check()` 0 errors/0 warnings/pre-existing notes
  only — a new spelling-drift word from this session's own roxygen prose ("merge's") was caught
  and fixed by rewording (not `inst/WORDLIST`-added), confirmed via re-running `tests/spelling.R`
  clean both before the documentation pass and after. `_pkgdown.yml` reference-coverage entry
  added for `modCrossCenterIdentityServer`/`modCrossCenterIdentityUI`. **Live `shinytest2`
  smoke test** (standalone driver script, not a permanent test file) against the real running
  app: uploaded a multi-issue mapping (Validation tab correctly surfaces both an existence and a
  uniqueness problem at once, Dragon #8), then a clean mapping (Preview tab's lineage-change
  table correctly resolves `sire`/`dam` to source "A" — Center B's own record of the transferred
  animal has no known parents, exactly the failure mode this feature exists to fix), confirmed
  **Dragon #6** (`modalDialog()` actually renders correctly under this app's untested bslib
  theme, with the right summary-count text) and **Dragon #7** (the Preview table's `NA`
  `pedB_sire`/`pedB_dam` cells render as blank text, read directly via `app$get_js()` cell
  traversal per `PROJECT_LEARNINGS.md` Learning 501 — not assumed), then confirmed the merge and
  verified the Export tab unlocked. Zero `SEVERE` console entries throughout.
- **Documentation (same session, per the plan's own §9 checklist mapping):** `NEWS.Rmd`/`NEWS.md`
  (new tab entry, re-rendered clean — diff shows only the new bullet); new "Cross-Center
  Identity" subsection in `vignettes/articles/colony-manager-guide.qmd` (tutorial/article
  checklist, Session 436), text-only, matching the established "no screenshot, and/or allowance
  satisfied" precedent (S465) — re-rendered via `quarto render`, clean; `a2interactive.Rmd`
  coverage explicitly deferred per the plan's own standing rule (Session 450/478), not
  same-session. Citation checklist (#120) N/A, already dispositioned in the plan's own §9.
- **Issue #149 closed** — both slices of the ratified design are now shipped.
- See `PROJECT_LEARNINGS.md` Learning 504 (a `shinytest2::AppDriver$new()` outside `testthat`
  needs `NOT_CRAN=true` set explicitly, or an internal `skip_on_cran()` throws instead of
  skipping; `upload_file()`/`set_inputs()` need `do.call()` with a named list, not a positional
  list argument; a DT-rendered table's rows are empty until the client-side widget actually
  initializes on tab switch — `wait_for_idle()` alone is not sufficient, a short explicit wait
  after switching tabs is needed too).

### 2026-08-10 · [ad hoc] Phase 0 ledger reconcile: backfill S505's own SESSION_NOTES.md/HANDOFFS.md close-out commit (post-S505)
- **Deliverable:** Phase 0 ledger reconcile (this session, S506) found one commit past the
  `CHANGELOG.md` frontier with no ledger entry: `68008f8d` ("docs: S505 close-out — issue #149
  fully shipped, handoff evaluation, self-assessment"), landed after S505's own CHANGELOG/BACKLOG/
  Learning commit (`b8022a4a`) that recorded the entry above.
- **Change:** `68008f8d` filled in S505's `SESSION_NOTES.md` (Session 504 handoff evaluation,
  the "What Session 505 Did" writeup, and the self-assessment) and finalized the S505
  `HANDOFFS.md` receipt from its Phase 1B `status: pending`/`pending`-field stub to
  `status: complete` with all six Minimum Handoff Requirements filled — writing up the
  just-finished session's own handoff, not new production work. Same class of self-referential
  fix as S505's own `e1c61673` backfill of S504's equivalent commit (`fd0c0312`), and the many
  prior sessions' equivalents further down this ledger (S466-S504).

### 2026-08-10 · [ad hoc] Phase 0 ledger reconcile: backfill S504's own HANDOFFS.md receipt commit sha (post-S504)
- **Deliverable:** Phase 0 ledger reconcile (this session, S505) found one commit past the
  `CHANGELOG.md` frontier with no ledger entry: `fd0c0312` ("docs: S504 -- backfill own
  HANDOFFS.md receipt commit sha"), landed after S504's own close-out commit (`6f58d9ad`) that
  recorded the entry below.
- **Change:** `fd0c0312` replaced the S504 `HANDOFFS.md` receipt's `changelog_ref: this
  session's close-out commit (see below).` / `commit: pending` placeholders with the actual
  commit sha (`6f58d9ad`) once known — writing up the just-finished session's own handoff, not
  new production work. Same class of self-referential fix as S503's `797c16f6` backfill
  immediately below, and the many prior sessions' equivalents further down this ledger
  (S466-S501).

### 2026-08-10 · [issue #149] Slice 1 implemented — cross-center identity-mapping validation core + `resolveCrossCenterIds()` D10 data-loss fix (Session 504)
- **Deliverable:** new exported `checkCrossCenterMapping(pedA, pedB, mapping)`
  (`R/checkCrossCenterMapping.R`), the ratified plan's D2 two-tier collect-all validator, sharing
  `resolveCrossCenterIds()`'s four checks (existence/uniqueness/collision/conflict) via 8 new
  shared, non-`stop()`ing internal helpers extracted from it. `resolveCrossCenterIds()` itself
  keeps its exact historical `stop()` message text and all 7 pre-existing tests pass unmodified
  (proven via a new golden-master test). Also fixes D10: a merged pair's other shared, agreeing
  columns (e.g. `sex`) now survive the merge instead of being silently dropped — an explicit,
  `NEWS.Rmd`-documented additive behavior change. R-function level only, no UI (Slice 2 is next).
  Followed `DEVELOPMENT_WORKSTREAM.md` under this project's Strict TDD contract
  (PRE-RED→RED→GREEN, `AskUserQuestion`-gated; REFACTOR owner-confirmed skip).
- **Verification:** 10 new test blocks (9 new `tests/testthat/test_checkCrossCenterMapping.R`, 3
  appended to `test_resolveCrossCenterIds.R`), 0 regressions. Full clean regression suite 0
  failed/0 error (4951 passed, 175 skipped, 15 pre-existing warnings — confirmed unrelated to this
  diff). `lintr::lint_package()` 0 lints. `devtools::check()` 0 errors/0 warnings/1 pre-existing
  note. `_pkgdown.yml` reference-coverage entry added (caught a real gap live).
  `runtime_smoke: n/a` — neither function has a live-app call site yet (Slice 2 wires them in).
- **Incidental finding, reported not fixed:** the "10 pre-existing baseline warnings" Housekeeping
  item has drifted to 15 (a 3rd `test_modMarkerGenetics.R` block, added S502, triggers the same
  warning pattern) — noted in `BACKLOG.md`, out of this slice's scope.
- See `PROJECT_LEARNINGS.md` Learning 503 (a roxygen doc-block/function-adjacency pitfall in
  `devtools::document()`, and a `git stash`-without-`-u` comparison-contamination pitfall).

### 2026-08-10 · [issue #149] Design/architecture document ratified — reviewed cross-center identity-mapping workflow with provenance export (Session 503)
- **Deliverable:** `docs/planning/issue149-cross-center-identity-mapping-workflow-plan.md`, following
  `ARCHITECTURE_WORKSTREAM.md` (owner-picked via `AskUserQuestion` over the literal
  `DESIGN_WORKSTREAM.md` mapping, matching the #133/#136/#137/#145/#147 precedent). Design/planning
  only — no `R/`, `tests/`, or `man/` content changed. Picked from this session's own Phase 0
  priorities list (owner choice via `AskUserQuestion`, out of #149 design / twin-connector-color fix
  / root-causing the 10 pre-existing regression warnings / the spelling-drift NOTE).
- **Design:** a new, self-contained `modCrossCenterIdentity` Shiny module wraps the existing,
  already-shipped `resolveCrossCenterIds()` (issue #130 Slice 4) with a non-fail-fast validator
  (`checkCrossCenterMapping()`, new exported, showing every mapping problem at once instead of
  stopping at the first), a merge preview with lineage-change detail, the app's first
  `shiny::modalDialog()` confirmation gate, and 5 downloadable export artifacts (Merged Pedigree,
  Mapping, Validation Results, Merge Summary, Provenance). Ten design decisions (D1-D10); four
  genuine judgment calls (D2 validation-extraction mechanism, D3 scope boundary, D8 export-artifact
  set, D10 whether to fix a newly-found data-loss defect now) ratified via a single `AskUserQuestion`
  round — owner selected this document's own recommended option in all four cases, no changes
  requested.
- **Adversarial review found and fixed 2 real gaps before ratification:** (1) a previously-unknown
  technical defect in the already-shipped `resolveCrossCenterIds()` — its merge step silently drops
  every non-`id`/`sire`/`dam` column for merged individuals, even when both centers agree on the
  value, about to become curator-visible for the first time via the new export (now D10, fixed in
  Slice 1 as an explicit, separately-tested additive change); (2) a design-consistency gap where the
  planned extraction of the per-pair conflict check silently depended on a `pedB` id-rewrite step the
  first draft never made explicit, which would have caused the new collect-all validator to
  under-report real conflicts (now fixed in D2, with a new Dragon documenting the requirement).
- **Issue #149 stays open** — design/planning only, matching the #133/#136/#137/#145/#147 precedent; a
  summary comment posted to the issue. A 2-slice implementation (Slice 1: validation core + the D10
  data-loss fix; Slice 2: full UI, confirm gate, exports, documentation) is the next pickup, each its
  own future session. See `PROJECT_LEARNINGS.md` Learning 502.

### 2026-08-10 · [ad hoc] Phase 0 ledger reconcile: backfill S502's own HANDOFFS.md receipt commit (post-S502)
- **Deliverable:** Phase 0 ledger reconcile (this session, S503) found one commit past
  the `CHANGELOG.md` frontier with no ledger entry: `797c16f6` ("docs: S502 -- handoff
  notes, HANDOFFS.md receipt complete"), landed after S502's own close-out commit
  (`6815676d`) that recorded the entry below.
- **Change:** `797c16f6` replaced the S502 `HANDOFFS.md` receipt's `status: pending`/
  `self_score: pending`/etc. placeholders with the completed handoff fields, and
  updated `SESSION_NOTES.md` with the corresponding close-out narrative -- writing up
  the just-finished session's own handoff, not new production work. Same class of
  action as the many prior sessions' equivalent self-fixes recorded further down this
  ledger (e.g. S466-S482, S501's own `627d9d49`/`55870d7a` pair immediately below).

### 2026-08-10 · [issue #155] Implemented the ratified design -- markerParentageLikelihood() now finds candidates for a recorded-but-wrong parent, closes issue #155 (Session 502)
- **Deliverable:** Implemented `docs/planning/issue155-parentage-likelihood-candidate-lookup-plan.md`
  §7 -- new internal `.markerFlaggedSlotPedigree()` helper in `R/markerParentageLikelihood.R`
  (a local "shadow" copy of `pedigree` with only the flagged (id, role) slot(s) blanked, including
  the ratified duplicate-`pedigree$id` defensive guard), wired into both `getPotentialParents()`
  call sites (`:285` auto-detect, `:298` explicit `id`/`role`/`candidates = NULL` branch).
  **`R/getPotentialParents.R` itself: zero lines changed** -- its full demographic-eligibility
  engine (breeding-age floor, gestation window, proven-breeder preference) is reused unmodified.
  The flagged/wrong recorded parent stays visible in the ranked output (D3(a)) -- its already
  -tested `LOD = -Inf`/`excluded = TRUE` doubles as a free confirmation signal for the curator.
- **Strict TDD** (`DEVELOPMENT_WORKSTREAM.md`, PRE-RED->RED->GREEN, `AskUserQuestion`-gated at
  every transition; REFACTOR owner-confirmed skip -- the implementation already matches the
  ratified design's own code block verbatim, 0 lints, no duplication found). PRE-RED live
  -verified the fix mechanism and all 3 named dragons (both-slots-flagged; batch
  no-cross-contamination; duplicate-id fail-soft) against real source before writing any test, and
  independently found a fixture landmine: the package's default auto-generated-id prefix is `"U"`
  (`getAutoIdFormat()` -> `"U%04d"`), so a non-mocked test cannot reuse the existing `"U"`-founder
  fixture from `test_modMarkerGenetics.R` without it being silently stripped by
  `removeAutoGenIds()` -- confirms Learning 497's own finding from a different angle. RED added 9
  new tests (5 `.markerFlaggedSlotPedigree()` unit tests; 2 non-mocked real-`getPotentialParents()`
  regressions, one per call site, reproducing issue #155's own repro shape; 1 mechanism-verification
  mock confirming `getPotentialParents()` is called with the shadow copy, not the real recorded
  parent; 1 live `shiny::testServer()` regression on the Candidate Parent Assignment tab, no mock),
  confirmed genuinely RED (0 regressions to the 147 pre-existing assertions they sit beside) before
  any implementation code. GREEN made all pass with 0 regressions to the full 4236-assertion
  clean-regression baseline (0 failed/0 error, 201 skipped, 15 pre-existing-class warnings).
- **Verification:** `lintr::lint_package()` 0 lints on the touched file; `devtools::check()` 0
  errors/0 warnings/2 pre-existing notes (the a2interactive.Rmd vignette-engine NOTE and a 13-word
  spelling-drift NOTE, both confirmed byte-identical before/after this diff via a second full
  `devtools::check()` run -- neither is caused by this session). This session's own new roxygen
  text (`.markerFlaggedSlotPedigree()`'s `man/` page) introduced 2 new spelling-drift words
  ("positionally", "unmutated"), fixed in the same commit via `inst/WORDLIST` (case-appropriate
  alphabetical position, per Learning 496's correction) -- the pre-existing 13-word drift
  (Housekeeping, S465/S496) is untouched, left for its own separately-tracked session.
- **Phase 3E (live runtime smoke test):** a real `shinytest2`/`chromote` `AppDriver` run against
  the actual installed app (`inst/shinytest/app.R`) -- uploaded a real pedigree CSV (with
  `fromCenter`) through the Input tab's own QC pipeline and a matching genotype CSV through the
  Marker Genetics tab, for a fixture reconstructing issue #155's own repro shape (recorded-but
  -wrong sire). The Candidate Parent Assignment tab, previously empty for this exact case (S498's
  original discovery), now renders 2 rows: the true sire ranked first (`LOD ~= 0.863`, not
  excluded) and the wrong recorded sire visible below it (`excluded = TRUE`, `LOD = -Inf` --
  renders as a blank cell, a pre-existing `DT`/JSON `-Inf`-to-`null` serialization quirk unrelated
  to this fix, confirmed by reading the real cell values via `app$get_js()` rather than trusting an
  HTML-substring `grepl()`, which produced a false negative on the first attempt). Zero console
  errors. Screenshot captured. Closes the loop on the defect exactly as S498 originally observed it.
- **Issue #155 closed** (`gh issue close 155 --reason completed`) citing this entry. See
  `PROJECT_LEARNINGS.md` Learning 501, `BACKLOG.md` Housekeeping.

### 2026-08-10 · [ad hoc] Phase 0 ledger reconcile: backfill S501's own HANDOFFS.md receipt commit sha self-correction (post-S501)
- **Deliverable:** Phase 0 ledger reconcile (this session, S502) found one commit past
  the `CHANGELOG.md` frontier with no ledger entry: `627d9d49` ("docs: S501 -- backfill
  own HANDOFFS.md receipt commit sha"), landed after S501's own close-out commit
  (`d9203515`) that recorded the entry below.
- **Change:** `627d9d49` replaced the S501 `HANDOFFS.md` receipt's `commit: pending`
  placeholder with the real commit sha (`d9203515`) -- a self-correction of the
  just-written receipt, not new production work. Same class of action as the many
  prior sessions' equivalent self-fixes recorded further down this ledger (e.g.
  S466-S482's `commit: pending` backfills).

### 2026-08-10 · [issue #155] Design/architecture document ratified — fix markerParentageLikelihood()'s auto-detect candidate lookup for a recorded-but-wrong parent (Session 501)
- **Deliverable:** `docs/planning/issue155-parentage-likelihood-candidate-lookup-plan.md`, following
  `ARCHITECTURE_WORKSTREAM.md` (owner-picked via `AskUserQuestion` over the literal
  `DESIGN_WORKSTREAM.md` mapping, matching the #136/#142/#145 precedent). Design/planning only — no
  `R/`, `tests/`, or `man/` content changed.
- **Root cause confirmed live** (not just read from the issue): `getPotentialParents()` only
  searches for candidates for an animal with an actually-missing (`NA`) parent slot;
  `markerParentageExclusion()` flags an animal whose recorded parent is present-but-wrong, both
  slots non-`NA` by definition — so the exact case issue #147 exists to address never appears in
  `getPotentialParents()`'s own `pUnknown` set, and both `markerParentageLikelihood()` call sites
  (auto-detect AND the explicit `id`/`role`/`candidates = NULL` branch, the latter untested until
  this session) silently return zero candidates.
- **Recommended and ratified mechanism ("shadow pedigree"):** a new internal
  `.markerFlaggedSlotPedigree()` helper builds a local copy of `pedigree` with only the flagged
  animal's own recorded slot blanked, passed only to the internal `getPotentialParents()` call —
  **zero changes to `getPotentialParents()` itself**, full reuse of its existing, already-tested
  demographic-eligibility engine. Live-verified twice against two independent prototypes (this
  approach and a rejected alternative adding a new `forceIncludeIds` parameter to
  `getPotentialParents()`), confirmed `identical()` output between them on a 6-individual scratch
  fixture reconstructing the issue's own repro shape.
- **Two judgment calls ratified via a single `AskUserQuestion` round** — owner selected this
  document's own recommended option in both, no changes requested: the shadow-pedigree mechanism
  over the `forceIncludeIds` alternative; leaving the flagged/wrong recorded parent visible in the
  ranked candidate output (its already-tested `LOD = -Inf`/`excluded = TRUE` behavior doubles as a
  free confirmation signal) rather than filtering it out.
- **Adversarially reviewed** by 2 independent `general-purpose` agents in parallel (correctness-vs
  -source; completeness/house-style) before ratification — found and fixed a real,
  previously-unaddressed gap (a duplicated `pedigree$id` needs the same defensive guard
  `scoreOnePair()` already has a few lines away in the same file, now incorporated into D1's
  implementation and its own test list) plus 3 citation-accuracy corrections and several
  house-style/close-out-checklist completeness gaps (missing header/metadata block, 2 missing
  alternatives, missing GitHub-issue-close/`CHANGELOG`/`_pkgdown.yml` checklist dispositions) —
  all incorporated into the ratified revision. Neither review found a defect in the recommended
  mechanism itself. See `PROJECT_LEARNINGS.md` Learning 500.
- **Issue #155 stays open** — design/planning only, matching the #133/#136/#137/#145/#147
  precedent; a single vertical-slice implementation (`R/markerParentageLikelihood.R` only, no UI
  change needed) is the next pickup in this cluster.

### 2026-08-10 · [issue #145] Slice 1 implemented — male-left/female-right default in .positionMatingUnitForest(), closes issue #145 (Session 500)
- **Deliverable:** full strict-TDD PRE-RED→RED→GREEN cycle (REFACTOR skipped, owner-confirmed —
  the GREEN diff was already minimal, single ~30-line additive block reusing an existing closure),
  `AskUserQuestion`-gated at every transition, implementing Slice 1 of
  `docs/planning/issue145-sire-dam-left-right-placement-plan.md` §4: `.positionMatingUnitForest()`
  gains a new `orderBySex = TRUE` parameter (an additive post-hoc value-swap for every D1-qualifying
  simple pair — both parents real, unambiguous `"M"`/`"F"` sex codes, mate-count exactly 1 each,
  neither with a D5 direct child); `makePedigreeMatingLayout()` threads a matching `orderBySex`
  parameter through, default on.
- **Pre-RED** built a live repro (not committed) and empirically verified D2's swap mechanism
  against (1) the real GA204Z/8LKBV9 fixture and (2) a reconstructed version of the adversarial
  review's own wide-fanout counter-example (a 3-child unit where a middle child carries 5
  grandchildren) — the first attempt showed the male landing as non-anchor already-left by accident
  of the id tie-break, so ids were adjusted to force the male into the anchor role and re-tested:
  the swap fires, the union's own `x` is invariant, all 9 descendant nodes unmoved, no new overlap.
  Also re-audited the test suite per the plan's own required step: confirmed only one existing
  fixture (the GA204Z/8LKBV9 exact-x regression test) has a hard-coded `x` assertion for a
  D1-qualifying pair, matching the plan's own citation.
- **RED:** updated the GA204Z/8LKBV9 exact-x regression test's `5A6DFT`/`8DKELJ` expected values;
  4 new `test_that` blocks in `test_positionMatingUnitForest.R` (swap case; true no-op case;
  `"H"`/`"U"`/NA sex-code exclusion, D4; the wide-fanout multi-child case) plus 2 new blocks in
  `test_makePedigreeMatingLayout.R` (default/wiring; `orderBySex = FALSE` matches the internal
  helper directly) — all structured as `orderBySex = TRUE` vs `FALSE` comparisons so every test,
  including guard/exclusion cases, genuinely fails pre-implementation (an "unused argument" error),
  not just the swap-needing cases. All 8 confirmed failing for the right reason.
- **GREEN:** implementation matched the design's own safety argument on the first attempt for the
  positioning mechanism itself; one test fix was needed after a live run — the wide-fanout fixture's
  own `C2`/`GCMate` pair turned out to be a SECOND, independently D1-qualifying pair, correctly
  swapped by the (intentionally per-unit-scoped) implementation, which the test's own "only 2 ids
  move" assertion had wrongly assumed away — widened the assertion to match the correct behavior
  rather than narrowing the implementation (`PROJECT_LEARNINGS.md` Learning 499). All 8 tests pass;
  full clean regression read 0 failed/0 error (4881 passed, up from 4858, same 10 pre-existing
  baseline warnings); `lintr::lint_package()` 0 lints on touched files (one `commented_code_linter`
  false positive suppressed, matching the established precedent); `devtools::check()` 0 errors/
  0 warnings/1 note (the pre-existing `a2interactive.Rmd` vignette-engine baseline, unchanged) — the
  first check run caught a real codoc-mismatch WARNING (forgot `devtools::document()` after adding
  the parameter), fixed; regenerating also atomically fixed a second, already-stale `.Rd` file from
  a prior session (`modMarkerGeneticsServer.Rd`, issue #147 Slice 2, S498's own roxygen source never
  regenerated) — included since the regen cannot be selectively reverted per-file.
- **Phase 3E live `shinytest2`/`chromote` smoke test** (mirroring the established
  `tests/testthat/test-e2e-pedigree-module.R` navigation/upload/click pattern, after an improvised
  first attempt used the wrong selectors/missed the "Update Focal Animals" click): visNetwork widget
  renders and is bound, 0 diagram-related console errors; screenshot of the real `5GQC24`(M) x
  `BJ4J7G`(F) 2-child family in the bundled 375-individual `obfuscated_rhesus_mhc_ped.csv` fixture
  visually confirms male-left/female-right rendering — satisfies the plan's own §6 dragon 3
  ("a live screenshot of at least one real multi-child qualifying family is still owed").
- **Documentation:** `NEWS.Rmd` gained a new entry (D7 framing — additive default, not a bug fix)
  and `NEWS.md` re-rendered. Citation checklist (#120): N/A (a rendering/layout default is not a
  statistic/estimator). `_pkgdown.yml` reference-coverage: N/A (`makePedigreeMatingLayout()` already
  listed, only a parameter added). Tutorial/article checklist: N/A this slice (no UI change ships —
  Slice 2, UI toggle wiring, was NOT created, D8 ratified option (b)). `a2interactive.Rmd` checklist:
  deferred per its own standing rule (D7).
- **Issue #145 is now fully implemented for the ratified simple-pair scope; closed as part of this
  session's close-out**, citing this entry. See `PROJECT_LEARNINGS.md` Learning 499,
  `BACKLOG.md` (pedigree-diagram cluster, Progress S500).

### 2026-08-09 · [issue #145] Design/architecture document ratified — sire/dam left-right pedigree placement default (Session 499)
- **Deliverable:** `docs/planning/issue145-sire-dam-left-right-placement-plan.md`, RATIFIED via
  `AskUserQuestion` (D3/D8/D9, the three genuine judgment calls; D1/D2/D4-D7 forced by evidence).
  Design/planning only — no `R/`/`tests/`/`man/` content changed. Corrected two claims inherited
  from the S482 verification spike once re-derived directly against `nprcgenekeepr`'s own algorithm
  (confirmed to have zero kinship2 dependency): (1) the project's own canonical GA204Z/8LKBV9
  fixture places the dam left of the sire today, not "coincidentally male-left"; (2) the multi-mate
  "crowding" case has no existing "anchor-centered, mates flank" mechanism to extend. A 3-agent
  adversarial review of the draft (before ratification) constructed a counter-example refuting the
  first-draft D2 mechanism (a subtree reflection) and an overstated "#143/#144 never touch x" claim
  (refuted by those issues' own shipped test diffs); both incorporated into a revised, more
  conservative mechanism (swap the two real parents' own `x` values) before ratification. Ratified
  design: male-left/female-right default, scoped to the simple 2-real-parent/single-mate/
  unambiguous-M-F case; a new `orderBySex = TRUE` parameter on `makePedigreeMatingLayout()`, no UI
  wiring (Slice 2 not created); no follow-up issue filed for the multi-mate case. Issue #145 stays
  open (commented, not closed — design only); Slice 1 (core positioning behavior) is the next
  pickup, gated on its own Pre-RED empirically verifying the swap mechanism live. See
  `PROJECT_LEARNINGS.md` Learning 498, `BACKLOG.md` (pedigree-diagram cluster, Progress S499).

### 2026-08-09 · [issue #147] Implement Slice 2 — Candidate Parent Assignment UI + documentation, closes issue #147 (Session 498)
- **Deliverable:** full strict-TDD PRE-RED→RED→GREEN cycle (REFACTOR skipped, owner-confirmed —
  the GREEN diff was already minimal and precedent-mirroring), `AskUserQuestion`-gated at every
  transition, implementing Slice 2 of `docs/planning/issue147-likelihood-parentage-assignment-plan.md`
  §5: a 5th, read-only "Candidate Parent Assignment" tab in `R/modMarkerGenetics.R` calling
  `markerParentageLikelihood()` (Slice 1, S496) against the module's already-wired
  `genotypeMatrix`/`pedigree` reactives — no new file input needed (D10). Picked from this
  session's own Phase 0 priorities list (owner choice via `AskUserQuestion`, out of #147 Slice 2/
  #145 design/#138 design/extdata reorg Phase 4).
- **Pre-RED** found the ratified plan's own "Files to touch" list understated scope:
  `tests/testthat/test_moduleContract.R`'s exhaustive per-module reactive-name contract test needed
  its own update (adding `"candidateAssignmentTable"`), confirmed to fail first (a genuine RED),
  not just `test_modMarkerGenetics.R`'s new tests.
- **RED:** 4 new `test_that` blocks (UI tab presence; not-ready-without-pedigree; a hand-verified
  flagged-pair case — `LOD == -Inf`/`excluded == TRUE`/`nLociUsed == 10L`, empirically confirmed
  against the real `markerParentageLikelihood()` via a standalone script before being asserted, not
  assumed — reusing the file's existing P/C/U fixture; an empty-but-valid zero-row case when
  nothing is flagged) plus the `test_moduleContract.R` update. All 5 confirmed failing for the
  right reason.
- **GREEN:** new `candidateAssignment` reactive + `DT::renderDT` output + UI tab + updated
  server roxygen, mirroring the module's existing 4-tab pattern exactly. All 5 RED tests pass;
  full clean regression read 0 failed/0 error (4858 passed, 10 pre-existing baseline warnings
  unchanged); `lintr::lint_package()` 0 lints on touched files; `devtools::check()` 0 errors/
  0 warnings/1 note.
- **Phase 3E live `shinytest2`/`chromote` smoke test found a genuine, previously-undiscovered gap
  in Slice 1's already-shipped auto-detect candidate lookup**, not caused by this session's diff:
  `markerParentageLikelihood()`'s default candidate source (`getPotentialParents()`) only ever
  proposes candidates for an animal with an *unrecorded* parent slot, never one whose recorded
  parent is present-but-wrong — the exact case `markerParentageExclusion()` flags. Confirmed
  directly (not mocked, unlike every existing test of this interaction, including this slice's
  own RED tests): a realistic live fixture with one correct + one wrong recorded parent returns
  zero candidates via the real, non-mocked `getPotentialParents()`; the identical fixture with the
  correct parent also left unrecorded correctly surfaces the true candidate. Also found and fixed
  in the same investigation: a candidate id starting with `"U"` silently vanishes from a real
  pedigree (`removeAutoGenIds()`'s own auto-generated-placeholder-id convention), unrelated to the
  deeper gap. Owner confirmed via `AskUserQuestion`: proceed with Slice 2 as scoped, using a
  realistic fixture for the live screenshot, filing the gap rather than fixing it mid-slice — filed
  as GitHub issue [#155](https://github.com/rmsharp/nprcgenekeepr/issues/155) and a new
  `BACKLOG.md` Housekeeping item (needs its own Pre-RED design pass). The tutorial gained an
  explicit callout documenting the limitation for users. `PROJECT_LEARNINGS.md` Learning 497.
- **Documentation (all in this session, per the plan's own §9 checklist mapping):** citation entry
  added to `inst/extdata/ui_guidance/population_genetics_terms.html`; `NEWS.Rmd`'s Slice-1 bullet
  updated to describe the new tab (its own "No Shiny UI yet" note removed), `NEWS.md` re-rendered;
  `vignettes/articles/colony-manager-guide.qmd` gained a new tutorial section + live-captured
  screenshot (`vignettes/articles/shiny_app_use/marker_genetics_candidate_assignment.png`) +
  the limitation callout above; `.qmd` re-verified via a full `quarto render` (clean, all chunks
  executed). `a2interactive.Rmd` checklist deferred per its own standing rule.
- **Issue #147 is now fully implemented across both slices; closed as part of this session's
  close-out**, citing this entry.
- **Incidental finding, not caused by this session's diff (reported, not fixed):** S497's own
  claimed clean `devtools::check()` 0 errors/0 warnings/0 notes no longer holds — the "no
  recognized vignette engine" NOTE for `vignettes/a2interactive.Rmd` reproduces on a clean, stashed
  tree with none of this session's changes present (confirmed via a stash test), contradicting
  S497's "2 independent fresh runs" claim. Not investigated further or fixed (unrelated to issue
  #147) — noted here for the record; a future session should reconcile this against S497's own
  `HANDOFFS.md` receipt.

### 2026-08-09 · [ad hoc] devtools::check() reaches 0/0/0 — non-portable filename + Rbuildignore copyright gap fixed (Session 497)
- **Deliverable:** A follow-up, owner-initiated fix session (post S496 close-out, same conversation)
  triggered by the owner directly renaming `inst/extdata/reference/Standardized Human Pedigree
  Nomenclature: Update and Assessment of the Recommendations of the Nation.html` (found S486,
  tracked in `BACKLOG.md`) to `inst/extdata/reference/pedigree_nomenclature.html`. Confirmed via
  `devtools::check()`: the non-portable-filename ERROR/WARNING is gone, **and** the long-tracked
  `vignettes/a2interactive.Rmd` "no recognized vignette engine" NOTE (BACKLOG.md's own S486 text
  already speculated these were "likely-related") went with it — `devtools::check()` moved from
  1 error/1 warning/1 note to **0 errors ✔ | 0 warnings ✔ | 0 notes ✔**, confirmed via 2 independent
  fresh runs. Directly investigated the vignette NOTE's own claimed cause ("Is a VignetteBuilder
  field missing?") via `tools::pkgVignettes(check = TRUE)` against both the raw source tree and a
  freshly-built tarball — found the engine tag valid and correctly recognized every time, so the
  NOTE was a downstream symptom of the filename ERROR derailing the check pipeline, not an
  independent defect.
  Incidental discovery while verifying the rename: the old filename's `.gitignore` exclusion
  (`Standardized Human Pedigree Nomenclature*.html`, S479 — deliberately keeping this copyrighted,
  local-only journal article out of the public git repo) no longer matched the new filename, so the
  renamed file briefly risked accidental commit. The owner fixed `.gitignore` directly. Separately,
  and more significantly: `.Rbuildignore` had **never** excluded this file (or the two other
  S479-gitignored copyrighted files, `5201430.pdf`/`bioinformatics_24_2_279.pdf`) — `.gitignore` has
  no effect on `R CMD build`, which reads the filesystem directly, so all three files had been
  shipping inside every built/distributed package tarball this whole time despite being deliberately
  kept out of git. Added `.Rbuildignore` entries for all three (owner-confirmed scope via
  `AskUserQuestion`, all 3 vs. just the renamed one); verified via `pkgbuild::build()` that none of
  the three ship in a fresh tarball, and that the legitimately-shipped `Master_Genetic_metrics_2_14_15.pdf`
  (S418, a different copyright situation) still does. One caught-and-fixed authoring mistake: the
  first `.Rbuildignore` comment attempt broke `R CMD build` outright (an unbalanced parenthesis
  split across multiple comment lines — `.Rbuildignore` requires every line's parens to balance
  within that single line, per the file's own existing header warning) — caught by immediately
  re-running the build, not assumed correct from a source read.
  Updated the one known prose reference to the old filename (`docs/audits/
  PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`, per `PROJECT_LEARNINGS.md` Learning 480)
  to the new path. Historical references in `SESSION_NOTES.md`/`CHANGELOG.md`/`PROJECT_LEARNINGS.md`
  correctly left untouched (dated narrative describing repo state as it existed when written).
  `BACKLOG.md`'s S486-tracked item marked resolved. No `R/`, `tests/`, or `man/` content changed —
  `.gitignore`/`.Rbuildignore`/`BACKLOG.md`/one audit doc only; no TDD gates apply (no behavior
  change to test).

### 2026-08-09 · [issue #147] Slice 1 implemented — markerParentageLikelihood() (Session 496)
- **Deliverable:** Slice 1 (core statistical function) of the ratified issue #147 plan
  (`docs/planning/issue147-likelihood-parentage-assignment-plan.md` §5) — new exported
  `markerParentageLikelihood()` (`R/markerParentageLikelihood.R`), ranking candidate replacement
  parents for a Mendelian-inconsistent recorded parent via a CERVUS-style multilocus likelihood-ratio
  (LOD) score (Meagher & Thompson 1986; Marshall, Slate, Kruuk & Pemberton 1998). Report-only —
  never writes `pedigree$sire`/`$dam`. New internal `.markerAlleleFrequencyTable()`
  (`R/markerAlleleFrequency.R`, D9). D7: `markerParentageExclusion()`'s opposite-homozygote
  comparison extracted into a shared internal `.markerOppositeHomozygoteCount()`, zero behavior
  change (a `dput()`-captured golden-master regression test proves it byte-identical). Full strict
  TDD PRE-RED→RED→GREEN→REFACTOR cycle, `AskUserQuestion`-gated at every transition. Pre-RED
  independently re-derived the LOD formula from first principles (not trusted from memory) and
  hand-verified it via a standalone scratch reference implementation before writing any RED test —
  mirroring `markerFst()`'s own Pre-RED precedent. REFACTOR hoisted the transmission-probability
  math into two more named internal helpers (`.markerTransmissionProbability()`,
  `.markerTwoSourceGenotypeProbability()`), with 4 new direct unit tests pinning the formula itself.
  Verified: 20 new/changed test_that blocks (16 in the new `test_markerParentageLikelihood.R`, 1
  golden-master regression + existing unchanged in `test_markerParentageExclusion.R`) all pass; full
  clean regression read 0 failed/0 error, 4841 passed, 175 skipped, 10 pre-existing baseline warnings
  unchanged; `devtools::check()` 2 ERRORs/1 WARNING/1 NOTE, confirmed an exact match to the
  established, pre-existing, unrelated baseline (non-portable-filename issue tracked since S486;
  vignette-engine note), 0 new; `lintr::lint_package()` 0 lints package-wide. `NEWS.Rmd`/`NEWS.md`
  updated (new exported function). No Shiny UI yet — Slice 2's scope, a separate future session.
  Incidental, unrelated findings surfaced and fixed as an unavoidable side effect of this session's
  own required `devtools::document()`/full-regression steps (not part of this session's own
  deliverable, reported not attributed): `readTwinRelations()` (shipped S494, issue #137 Slice 3)
  had never actually been exported (`@export` in its roxygen, but no `NAMESPACE` entry or man page
  existed until this session's `devtools::document()` run) — fixed as a mechanically-unavoidable
  side effect of NAMESPACE regeneration being atomic across the whole package; and the resulting
  `_pkgdown.yml` reference-coverage gap for both that function and this session's own new
  `markerParentageLikelihood()` (a pre-existing package-wide guard test, `test_pkgdown_reference_config.R`,
  cannot be satisfied for only one missing entry) — both added to `_pkgdown.yml`'s "All exposed
  functions" group. See `PROJECT_LEARNINGS.md` Learnings 495–496, `CLAUDE.md`'s new
  `_pkgdown.yml` reference-coverage checklist.

### 2026-08-09 · [issue #147] Pre-RED design/scoping session — RATIFIED architecture plan (Session 495)
- **Deliverable:** `docs/planning/issue147-likelihood-parentage-assignment-plan.md` — the statistical
  method, reference-population, and report-vs-write-back architecture decisions issue #147 itself
  requires be designed before implementation. Ran a 4-agent research `Workflow` (3 independent
  literature angles — CERVUS/LOD-score methods, Marshall et al. 1998/Kalinowski et al. 2007;
  COLONY/sibship-reconstruction methods, Wang 2004/Jones & Wang 2010/FRANz; captive-primate-colony
  precedent, directly checking what de Groot et al. 2025 — already cited in this package — actually
  uses — plus an adversarial synthesis pass explicitly stress-tested against this package's own
  realistic 2-10-locus marker-panel size) alongside a separate codebase-inventory `Explore` agent (9
  items); 6 of the agent's most load-bearing file:line citations independently spot-checked directly
  against source before use, all matched exactly. Recommends a CERVUS-style multilocus likelihood-ratio
  (LOD) score (Meagher & Thompson 1986; operationalized by Marshall, Slate, Kruuk & Pemberton 1998),
  independently validated as the captive-primate-colony domain's de facto standard by de Groot et al.
  (2025); rules out full-pedigree/sibship reconstruction (COLONY/FRANz) as solving a different, harder
  problem at disproportionate cost. Ten design decisions (D1-D10); four genuine judgment calls ratified
  via a single `AskUserQuestion` round, owner selected this document's own recommended option in all
  four cases with no changes: no-error-model LOD formula now (genotyping-error-tolerant extension
  deferred, pending independent re-verification of an unretrievable 2010 corrigendum); a fixed,
  literature-informed `minLoci` gate default; **report-only architecture** — zero code path writes
  `pedigree$sire`/`pedigree$dam` (this package has no existing pedigree-mutation precedent of any kind,
  confirmed by a full grep sweep); a 5th read-only "Candidate Parent Assignment" tab in
  `modMarkerGenetics.R`, matching the existing 4-tab pattern. A 2-slice vertical implementation plan
  (core statistical function; UI + documentation) with per-slice DONE criteria, files-to-touch, and
  verification commands. No `R/`, `tests/`, or `man/` content changed — design/planning only, matching
  the #133/#136/#137 precedent. See `PROJECT_LEARNINGS.md` Learning 494 (an adversarial-synthesis agent
  explicitly stress-tested against the calling project's own specific constraints surfaces findings no
  individual research report produces alone).

### 2026-08-09 · [issue #137] Implemented Slice 3 (UI wiring, legend, documentation) — closes issue #137 (Session 494)
- **Deliverable:** Shiny-level wiring so a user can supply a `twinRelations` sidecar CSV/Excel file
  on the Pedigree Browser's Diagram tab, gated by a new **Show Twin Connectors** toggle, with a
  matching Diagram-tab legend entry and user-facing documentation — closing the 3-slice issue #137
  chain. New `fileInput(ns("twinRelationsFile"), ...)` lives in `modPedigreeUI()`'s static UI
  (`R/modPedigree.R`), not the dynamically re-rendered `pedigreeDiagramUI` block, since a `fileInput`
  has no `value=` a fresh render could read back self-referentially (Learning 490's file-input
  corollary). New `twinRelationsData()` reactive validates the upload via `checkTwinRelations()`,
  non-fatal on error (mirrors `R/modGeneticValue.R`'s `kinshipOverrideData` precedent). New
  off-by-default **Show Twin Connectors** `checkboxInput` follows the established self-referential
  -value pattern (Learning 490) alongside `pedigreeEdgeStyle`/`pedigreeShowNames`; `diagramLayout()`
  gates whether the validated data reaches `makePedigreeMatingLayout()` on the toggle. The existing
  single `visLegend()` call gains an `addEdges` MZ/DZ/UZ legend (never a second call). New exported
  `R/readTwinRelations.R` mirrors `readKinshipOverrides()`. Pre-RED found the ratified plan's own
  "Touches" list overstated scope — neither `R/appServer.R` nor `R/modInput.R` needed a change,
  since `twinRelations` (unlike `kinshipOverrides`) is consumed only inside `modPedigree`'s own
  render chain. Found and filed (not fixed, out of this slice's file scope): Slice 2's own
  `.buildTwinConnectorEdges()` never actually wired the `#009E73` color its own S493 handoff said
  was picked (confirmed via grep, zero hits) — new `BACKLOG.md` Housekeeping item. Full strict-TDD
  PRE-RED→RED→GREEN cycle, `AskUserQuestion`-gated at every transition (REFACTOR owner-confirmed
  skip). Verified: full clean regression read 0 failed/0 error, 4758 passed, 175 skipped, 10
  pre-existing baseline warnings (unchanged); `devtools::check()` 2 ERRORs/1 WARNING/2 NOTEs, an
  exact match to S493's own baseline, 0 new; `lintr::lint_package()` 0 lints (6 false positives
  suppressed via the established `# nolint` convention). Phase 3E: the full, real
  `test-e2e-pedigree-module.R` suite (13 tests, 2 new for this slice) run live against a freshly
  `devtools::install()`ed package — all 13 passed, 0 console errors. `NEWS.Rmd` and
  `vignettes/manual_components/_pedigree_browser.Rmd` updated. Citation checklist (#120): N/A,
  confirmed explicitly. `a2interactive.Rmd` coverage deferred per its own standing rule. See
  `BACKLOG.md`, `PROJECT_LEARNINGS.md`.

### 2026-08-09 · [issue #137] Implemented Slice 2 (core rendering) of the twin/zygosity plan (Session 493)
- **Deliverable:** `makePedigreeDiagramData()`/`makePedigreeMatingLayout()` (`R/makePedigreeDiagramData.R`)
  gain an optional `twinRelations` parameter rendering a distinctly-styled connector edge per twin
  pair via a new shared `.buildTwinConnectorEdges()` helper: MZ solid + `"MZ"` label, DZ short-dash
  `c(4L, 4L)` + `"DZ"` label, UZ long-dash `c(14L, 8L)` + `"?"` label (D10 colors/dash patterns
  decided this session — `#009E73` Okabe-Ito bluish-green, grep-confirmed collision-free against
  every hex color already in `R/`). `dashes` is an `I(list(...))` list-column, re-confirmed hands-on
  via a live `rbind()`/`jsonlite` test. `twinRelations` is NOT validated internally — validation
  stays a caller-side concern (`checkTwinRelations()`), matching the
  `applyKinshipOverrides()`/`checkKinshipOverrides()` precedent. A connector always targets the two
  individuals' REAL node ids (D7) — no duplicate-node lookup needed, since `twinRelations$id1`/`id2`
  are already real ids. `.addRectilinearWaypoints()`'s `newEdges` construction now unconditionally
  stamps a `label` column (D9), fixing the "undefined columns selected" crash the design doc
  predicted — verified genuinely load-bearing by temporarily reverting the fix, re-observing the
  exact predicted crash, then restoring it. Plan:
  `docs/planning/issue137-twin-zygosity-pedigree-diagram-plan.md` §4 Slice 2.
- **Full strict-TDD PRE-RED→RED→GREEN→REFACTOR cycle**, `AskUserQuestion`-gated at every transition.
  REFACTOR fixed one doc-drift item (stale non-`L`-suffixed dash values in roxygen prose after a
  lint fix changed the code to integer literals).
- **Phase 3E live verification**: since Slice 3's UI wiring doesn't exist yet, built a standalone
  `shinyApp()` mirroring `R/modPedigree.R`'s own render chain (matching the established S465
  precedent), driven via `shinytest2`/`chromote` against a hand-picked focused subset of the Slice 1
  fixture (the 3 twin pairs + immediate family, including HV7LZ3's 3-mate/2-duplicate structure).
  Visually confirmed all 3 connector styles distinct, the MZ connector targeting HV7LZ3's REAL node
  specifically (not either of her 2 `__dup_` occurrences — D7 confirmed empirically), and twin
  connectors staying direct/unrouted under `edgeStyle = "rectilinear"` while mate-lines route
  through right-angle waypoints around them (D9) — 0 console errors under either edge style. Closes
  the design doc's own Dragon #5 gap ("never visually rendered, not even once"). Hit and fixed 3
  environmental gotchas along the way (renv library-path injection for a standalone subprocess;
  `shinytest2::AppDriver` method-name/argument corrections) — see `PROJECT_LEARNINGS.md` Learning 493.
- **Verified:** both targeted test files green (76+128 expectations); full clean regression read 0
  failed/0 error, 4733 passed, 173 skipped, 10 pre-existing baseline warnings (unchanged);
  `devtools::check()` 2 ERRORs/1 WARNING/2 NOTEs, all independently traced to already-tracked
  `BACKLOG.md` pre-existing items (non-portable filename dating to S418; vignette-engine NOTE + the
  same 9-word spelling gap tracked since S465/S490), 0 new; `lintr::lint_package()` 0 lints on
  touched files. **Issue #137 stays open** — Slice 3 (UI wiring, legend, documentation) is next.
  See `PROJECT_LEARNINGS.md` Learning 493, `BACKLOG.md`.

### 2026-08-09 · [issue #137] Implemented Slice 1 (data model + de-identification) of the twin/zygosity plan (Session 492)
- **Deliverable:** `R/checkTwinRelations.R` (new, `@export`) validates a twin/zygosity sidecar table
  `(id1, id2, code)` against kinship2's own five relation rules (design doc §2.1/D4): required
  columns, `id1`/`id2` coerced to character, off-diagonal, both ids exist in `ped`, `code` in
  `{"MZ twin", "DZ twin", "UZ twin"}` (the 4th non-twin `"spouse"` code out of scope for #137),
  MZ/DZ share both `sire` and `dam`, MZ additionally requires matching `sex`, UZ has no such
  precondition. `R/obfuscateTwinRelations.R` (new, `@export`, family obfuscation) de-identifies the
  table by remapping `id1`/`id2` through the `map` alias vector `obfuscatePed(..., map = TRUE)`
  already returns — a required Slice 1 deliverable (D5), not deferred, since `obfuscatePed()`
  cannot itself reach a second sidecar object. No visible app change (rendering + UI are Slices 2-3,
  separate future sessions). Plan: `docs/planning/issue137-twin-zygosity-pedigree-diagram-plan.md`
  §4 Slice 1.
- **Full strict-TDD PRE-RED→RED→GREEN cycle**, `AskUserQuestion`-gated at every transition
  (priorities-list pick; PRE-RED→RED; RED→GREEN; GREEN→REFACTOR, owner-confirmed skip). A real
  RED-phase rigor gap was found and fixed live during the RED step: 6 of 10 `test_checkTwinRelations.R`
  "stops on X" assertions used a bare `expect_error()` with no message pattern, trivially satisfied
  by "could not find function" rather than the intended domain rule — added `regexp` arguments to
  all 6, re-verified all 11+4 expectations (across both new test files) genuinely fail
  pre-implementation and re-validate the correct rule post-implementation. See
  `PROJECT_LEARNINGS.md` Learning 492.
- **Fixture pair added** (`data-raw/generate_twin_fixtures.R`, `inst/extdata/examples/
  obfuscated_rhesus_mhc_ped_twins.csv` + `..._twin_relations.csv`, committed separately as a `data:`
  commit per the S486/S489 precedent): built from REAL full-sibling structure already present in
  the base 375-individual pedigree (not fabricated) — MZ pair `E06FRB`/`HV7LZ3` (verified full
  sibs, both sex F; `HV7LZ3` is independently a dam with 3 distinct mates elsewhere in the
  pedigree, the design doc's own §6 Dragon 3 scenario, confirmed present not contrived), DZ pair
  `8GSXTQ`/`P844CW`, UZ pair `BRI2MW`/`677E7M` (two founders, demonstrating UZ's confirmed lack of
  any shared-parent precondition). Validated against `checkTwinRelations()` at generation time.
- **Verified:** both new test files green (11+4 expectations); full clean regression read 0
  failed/0 error, 4694 passed, 173 skipped, 0 offenders; `lintr::lint_package()` 0 issues on all
  touched `R/` files (1 `nonportable_path_linter` false positive suppressed per the established
  `# nolint` precedent, Learnings 224/461); `devtools::check()` 1 ERROR/1 WARNING/1 NOTE, all
  pre-existing and individually attributed (non-portable reference filename, `a2interactive.Rmd`
  vignette-engine NOTE), 0 new — including 2 new spelling-check words this session's own prose
  introduced ("zygosity", an ordinal-digit "th" tokenization artifact from "kinship2's own 4th"),
  both found and fixed in-session (reworded "4th"→"fourth"; hand-added "zygosity" to
  `inst/WORDLIST`) rather than left as a new gap, confirmed via a direct `spelling::spell_check_package()`
  before/after diff. A pre-existing `test_pkgdown_reference_config.R` guard caught the two new
  exports missing from `_pkgdown.yml`'s reference groups live — fixed same-session. Phase 3E: n/a —
  script-callable only, no runtime/UI change this slice.
- Issue #137 stays open (Slices 2-3 pending); no `gh issue close` this session. Next session in this
  cluster implements Slice 2 (core rendering).

### 2026-08-09 · [issue #137] Ratified an architecture/design plan for twin/zygosity encoding on the Pedigree Diagram (Session 491)
- **Deliverable:** `docs/planning/issue137-twin-zygosity-pedigree-diagram-plan.md` — Tier 2 step 4
  in the owner's `#133 > #136 > #137 > #138` sequencing (set S436). Design/scoping only — no
  `R/`/`tests/`/`man/` content changed this session; implementation begins with Slice 1 in a future
  session (FM #18: the plan is the deliverable, not its code).
- **Central architectural question:** twin-ness is a *pairwise* fact (unlike #133's `affected` or
  #136's `name`, both single-individual attributes), so `.nprcColumnSchema`'s single-per-individual
  -row model structurally cannot represent it. Resolved as a new sidecar `twinRelations` table
  `(id1, id2, code)`, mirroring kinship2's own `relation` convention (per the owner's S436
  naming-overlay directive) and this project's existing `applyKinshipOverrides()` precedent —
  needing zero change to `columnSchema.R`/`getPossibleCols()`/`qcStudbook()`/`checkRequiredCols()`/
  `fixColumnNames()`/`removeDuplicates()`.
- **kinship2 mechanism, empirically verified** (deparsed the installed namespace source, not just
  read Rd text; independently re-confirmed twice with identical results): `relation`'s numeric codes
  are 1=MZ/2=DZ/3=UZ twin plus a 4th, non-twin `4=Spouse` code the issue's own text omitted (scoped
  out of #137 as a separate future extension); DZ twins get positional clustering only in kinship2's
  own rendering, with no distinct visual mark, unlike MZ (an added crossbar) and UZ (a "?" glyph) —
  informing this design's own simpler direct-edge-with-`label` rendering choice rather than
  reproducing kinship2's wedge geometry (ruled out of scope via the same Deletion-Test refactor
  heuristic #133 D4 cited).
- **A required (not deferred) Slice 1 deliverable:** `obfuscatePed()` cannot reach a second sidecar
  object, so a new `obfuscateTwinRelations()` companion, consuming `obfuscatePed(..., map = TRUE)`'s
  existing `map` output, closes the same class of PII gap #136 D8 closed for the `name` column — in
  the same slice as the data model, not a later session.
- **Ratification:** 4 genuine judgment calls (data-model shape D1, rendering mechanism D6,
  duplicate-node connector-targeting D7, UI-wiring slice boundary D11) posed in a single
  `AskUserQuestion` round; owner selected this document's own recommended option in all four cases,
  no changes requested. All forced decisions (D2-D5, D8, D9, D12) plus all four judgment calls are
  now RATIFIED.
- **Tooling discovery, recorded as `PROJECT_LEARNINGS.md` Learning 491:** the research workflow's own
  huge (~56K-character) drafted document was silently truncated to its last ~18.6K characters before
  reaching both the persisted journal and the downstream adversarial-verify agents, causing 2 of 3
  verify lenses' "blocking" findings to be false positives (content the truncated copy never showed
  them, not a real gap in the actual document) — caught by recovering the drafting agent's raw
  transcript directly and cross-checking against this session's own independent first-hand
  verification. 3 genuinely new verify findings survived reconciliation and are incorporated into
  the ratified document (a missing `CHANGELOG.md` ledger-format close-out item; a "twin zygosity,"
  never bare "zygosity," prose-disambiguation requirement against the Marker Genetics module's
  existing "Heterozygosity" tab; and two rendering-mechanics notes — a `dashes` list-column
  technique and `visLegend()`'s single-call `addEdges` parameter).
- **Issue #137 stays open**, ready for Slice 1 implementation in a future session.

### 2026-08-09 · [issue #136] Implemented Slice 2 (label rendering + toggle + documentation) of the name-node-label plan, closing the issue (Session 490)
- **Deliverable:** the Pedigree Diagram tab can now show animal names alongside id.
  Plan: `docs/planning/issue136-name-labels-pedigree-diagram-plan.md` §4 Slice 2.
  Full TDD PRE-RED→RED→GREEN cycle, `AskUserQuestion`-gated at every transition
  (priorities-list pick; PRE-RED→RED; RED→GREEN; GREEN→REFACTOR, owner-confirmed
  skip).
- **Pre-RED (Dragon 1 + D10):** a live `chromote` render against a minimal widget
  matching `R/modPedigree.R`'s exact render chain confirmed the bundled vis.js
  renders an embedded `"\n"` as two lines — Dragon 1 resolved, no fallback needed.
  D10's truncation budget (15 characters + `"..."`) was empirically calibrated
  against the real fixture's tightest measured node spacing (48 world-units,
  §2.3) — covers the bundled fixture's entire realistic name pool unspoiled
  (max 8 characters) while bounding a pathological outlier's overlap footprint.
- **GREEN:** two new shared helpers in `R/makePedigreeDiagramData.R`,
  `.nameLabel()` (D3 augment / D4 fallback / D10 truncate) and
  `.nameTooltipLine()` (D10 full name, HTML-escaped), wired into both
  `makePedigreeDiagramData()` and `makePedigreeMatingLayout()` (D7) — the latter
  also applies to duplicate-occurrence nodes via their real individual's own
  name (D7 label parity). `R/modPedigree.R` gained an off-by-default
  **Show Names on Diagram** `checkboxInput` (D3/D4/D6) alongside the existing
  edge-style toggle; the `diagramLayout` reactive strips the `name` column
  before calling the builder when the toggle is off (both builders stay
  unconditionally name-column-aware, mirroring the `affected` precedent — no
  new function parameter). `nodesIdSelection` gained `useLabels = FALSE` (D6),
  unconditional on toggle state.
- **A real defect was found via live Phase 3E verification** (a real
  `shinytest2::AppDriver`, not `shiny::testServer()`): `pedigreeDiagramUI`'s
  `renderUI()` rebuilds the show-names checkbox from scratch on ANY of its
  reactive dependencies changing (e.g. switching the unrelated `edgeStyle`
  radio buttons), and the checkbox hardcoded `value = FALSE` instead of
  reading `.currentShowNames()` self-referentially the way the pre-existing
  `edgeStyle` radio buttons already do (`selected = style`) — toggling names
  on, then touching anything else that re-renders that UI, silently reset the
  toggle. Fixed with a one-line self-referential `value = .currentShowNames()`.
  A `shiny::testServer()` unit test cannot pin this regression (proven by
  writing one and observing it pass identically against buggy and fixed code
  — `testServer()` never simulates the real client round-trip that is the
  actual failure mechanism); permanent coverage is instead two new live
  `shinytest2`/`chromote` tests in `test-e2e-pedigree-module.R`. See
  `PROJECT_LEARNINGS.md` Learning 490.
- **Documentation checklists:** `NEWS.Rmd` (re-rendered to `NEWS.md`);
  `vignettes/manual_components/_pedigree_browser.Rmd` **and**
  `vignettes/articles/colony-manager-guide.qmd` (owner's #136 comment requires
  both, re-rendered clean); `inst/extdata/ui_guidance/input_format.html` gained
  an optional `name` row. Citation checklist (#120): N/A per the plan's own §5
  — a display label is not a statistic. `a2interactive.Rmd` coverage
  deliberately deferred per `CLAUDE.md`'s own documented policy.
- **Verified:** full clean regression read 0 failed/0 error (10 pre-existing
  baseline warnings unchanged, 4677 passed, 173 skipped); `lintr` 0 issues on
  all 6 touched `.R` files (2 `commented_code_linter` false positives found and
  reworded away, not suppressed — a `D3/D4/D6` slash-separated list parses as
  valid R division syntax, a `useLabels = FALSE`/`makePedigreeMatingLayout()`
  phrase resembles code); `devtools::check()` 1 ERROR/1 WARNING/1 NOTE, all
  pre-existing and individually attributed (non-portable filename from S418;
  `a2interactive.Rmd` vignette-engine NOTE), 0 new — the fresh run's spelling
  diff (9 words, not the 6 already tracked in `BACKLOG.md`'s S465 item) was
  confirmed via `git blame` to trace entirely to S487's commit, not this
  session's diff; full live `test-e2e-pedigree-module.R` run clean (all
  passing) including the 2 new tests. **Both slices of issue #136 are now
  shipped; issue #136 itself is closed as part of this session's close-out.**

### 2026-08-09 · [issue #136] Implemented Slice 1 (data model + de-identification) of the name-node-label plan (Session 489)
- **Deliverable:** `name` is now a recognized, optional, character pedigree column,
  correctly scrubbed by de-identification. No visible app change (rendering + toggle
  are Slice 2, a separate future session). Plan: `docs/planning/
  issue136-name-labels-pedigree-diagram-plan.md` §4 Slice 1.
- **Full TDD RED→GREEN cycle**, `AskUserQuestion`-gated at every transition
  (priorities-list pick; PRE-RED→RED; RED→GREEN; GREEN→REFACTOR, owner-confirmed
  skip). `R/columnSchema.R`: `name` appended to `.nprcColumnSchema$possible`.
  `R/getPossibleCols.R`/`man/getPossibleCols.Rd`: new `@return` bullet (`affected`
  precedent style). `R/qcStudbook.R`: `name` coerced to character when present
  (mirrors the existing `species` block exactly — needed to pass a factor-input
  test). `R/obfuscatePed.R`: `name` scrubbed to `NA` (D8) — closes the disclosure
  defect S488 found (an obfuscated pedigree would otherwise carry scrubbed ids
  beside intact real names). New sibling fixture `inst/extdata/examples/
  obfuscated_rhesus_mhc_ped_name.csv` (`data-raw/obfuscated_rhesus_mhc_ped_name.R`,
  seeded RNG) with the plan's 3 required cases: named/empty/`NA` mix (D4's
  "inconsistent" case) and one deliberately long name pre-staged for Slice 2's
  geometry mitigation (D10).
- **Pre-RED verification found 2 of the plan's suggested RED tests (trap 3
  `removeDuplicates()`, trap 4 `fixColumnNames()`) already pass with zero code
  change** — both are schema-agnostic existing behavior that already correctly
  extends to the new column. Disclosed to the owner via the PRE-RED→RED gate and
  included as labelled documentation/coverage rather than presented as
  RED-driving. See `PROJECT_LEARNINGS.md` Learning 489.
- **Verified:** full clean regression read 0 failed/0 error (10 pre-existing
  baseline warnings unchanged, 4650 passed); `lintr` 0 issues on all 8 touched
  files (project's own `.lintr` config); `devtools::check()` 1 ERROR/1 WARNING/1
  NOTE, all pre-existing and individually attributed (non-portable
  `inst/extdata/reference/...` filename from S418; `a2interactive.Rmd`
  vignette-engine NOTE), 0 new; end-to-end pipeline check against the new fixture
  confirmed `name` survives `qcStudbook()` and is correctly scrubbed by
  `obfuscatePed()`. Phase 3E: n/a — no runtime behaviour change this slice.
  Citation (#120), `NEWS.Rmd`, and tutorial/article checklists: N/A per the
  plan's own §5 (owed at Slice 2, which ships the user-visible rendering).
- Issue #136 stays open (Slice 2 pending); no `gh issue close` this session.
  Next session in this cluster implements Slice 2.

### 2026-08-09 · [ad hoc] Untracked the two committed `.DS_Store` files so they stop reappearing in `git status` (Session 488)
- **Owner-directed** ("gitignore the .DS_Store"). Pre-work inspection found the
  request's premise was already half-satisfied and the actual gap was elsewhere:
  `.gitignore:49` **already** carried a `.DS_Store` rule (added by an earlier
  session, whose own comment recorded that it deliberately left "the pre-existing
  tracked root .DS_Store -- untouched"). A `.gitignore` rule has no effect on
  already-tracked files, which is precisely why `.DS_Store` kept showing as
  modified in every session's Phase 0 `git status`.
- **Fix:** `git rm --cached .DS_Store man/.DS_Store` (2 files were tracked; both
  remain on disk, only the index entries were removed), plus a corrected
  `.gitignore` comment explaining the tracked-vs-ignored distinction so the next
  reader is not misled the same way.
- **No build impact, verified:** `.Rbuildignore:95` already excluded `\.DS_Store$`
  end-anchored (deliberately un-anchored at the front so it also catches subdirectory
  copies such as `man/.DS_Store`), so the package tarball never shipped them.
- A third copy, `docs/.DS_Store`, exists on disk but was never tracked and is
  covered by the existing ignore rule — left alone.

### 2026-08-08 · [issue #136] Designed and ratified the name-node-label plan for the pedigree diagram (Session 488)
- **Deliverable:** `docs/planning/issue136-name-labels-pedigree-diagram-plan.md`
  (commit `3121bb71`), an architecture design/scoping document for GitHub issue
  #136 ("Show names (not just ID) as Pedigree Diagram node labels"). Tier 2 step 3
  in the owner's standing #133 > #136 > #137 > #138 order (set S436). Planning
  session only — no `R/`/`tests/`/`man/` content changed (FM #18).
- **Workstream:** `ARCHITECTURE_WORKSTREAM.md`, owner-picked via `AskUserQuestion`
  over the literal `DESIGN_WORKSTREAM.md` task mapping (whose content — star
  component, panel zones, thematic grouping — does not describe a data-model plus
  rendering-contract change).
- **Ratified via `AskUserQuestion` in two rounds:** (1) framing, posed *before* the
  decisions section was drafted since the source audit's own disposition was "no
  action" — owner answered that names exist at **some centers, inconsistently**
  (making a per-node fallback a hard requirement, not a nicety) and chose an
  **optional `name` column + off-by-default display toggle** over tooltip-only,
  decline, and a configurable label-source column; (2) the four judgment-call
  decisions — **D3** augment (`id` + name, not name-only), **D6** pin
  `useLabels = FALSE` on the search dropdown, **D10** truncate the displayed name
  with the full name in the tooltip, **D8** `obfuscatePed()` drops `name` to `NA`.
  All four ratified as recommended.
- **Corrects three premises in the issue itself**, each verified first-hand:
  (a) `label` is already an independent channel and `label != id` **already ships**
  (duplicate nodes `R/makePedigreeDiagramData.R:906`, union nodes `:929`) — #136 is
  "choose the string", not "build the mechanism"; (b) the schema's
  `first_name`/`second_name` are **allele** names (`R/headerDisplayNames.R:52-53`),
  the Learning 485 trap re-encountered, though the "no *animal*-name column"
  conclusion holds; (c) the binding constraint is **geometry, not the data model** —
  measured on the real 375-individual fixture, every id is exactly 6 characters and
  25.6% of adjacent label-bearing node pairs sit 48 layout units apart with ~50-unit
  nodes, and nothing in the fixed-coordinate layout measures text (unlike kinship2,
  which sizes its layout via `strwidth`/`strheight`).
- **Found a disclosure defect no prior session had reason to look for:**
  `obfuscatePed()` (`R/obfuscatePed.R:31-43`) scrubs only `id`/`sire`/`dam` and
  Date-classed columns, so a `name` column would survive de-identification intact —
  scrubbed IDs beside real names. Made a mandatory same-slice requirement (D8).
- **Method:** a 5-lens read-only research `Workflow` with per-finding adversarial
  verification, run *alongside* independent first-hand verification of every
  load-bearing fact. Three agent claims were corrected before publication (an
  over-stated MIT-license constraint, an over-stated kinship2 "only a length check",
  and an incomplete column-vocabulary enumeration) and one citation drift fixed
  (`finalNodes` is `:1237`, not `:1238`), per Learning 485's rule on consuming
  multi-agent research.
- **Scoped as 2 vertical slices** with full DONE/verification contracts (Slice 1:
  data model + de-identification, no visible change; Slice 2: label rendering +
  toggle + documentation). Issue #136 intentionally left **open** — design ratified,
  not yet implemented; no `gh issue close` this session.
- See `PROJECT_LEARNINGS.md` Learning 488.
- **Non-commit actions this session (FM #27), both owner-directed after close-out:**
  (1) pushed the accumulated 65 local commits to `origin/master`
  (`c195d9cd..320eb016`) — the first push since S46x-era work, so `master` on
  GitHub had been ~65 commits stale; (2) posted a summary comment on issue #136
  recording the ratified design, the three corrected premises, and the
  `obfuscatePed()` finding
  (https://github.com/rmsharp/nprcgenekeepr/issues/136#issuecomment-5229361701).
  Issue #136 remains **open** — design ratified, implementation pending.

### 2026-08-08 · [issue #133] Implemented Slice 2 (legend + documentation) of the affected-status pedigree-diagram design; issue #133 closed (Session 487)
- **Deliverable:** the Diagram tab's shape-to-sex `visLegend()` gained a matching
  "Affected" row (D6), reusing Slice 1's `#CC79A7` color — one new row in the
  existing `addNodes` data frame, not a second `visLegend()` call. `NEWS.Rmd`'s
  existing #133 bullet updated (not duplicated) to describe the legend rather
  than promise it "in a later release"; `vignettes/manual_components/
  _pedigree_browser.Rmd` and `vignettes/articles/colony-manager-guide.qmd` both
  updated per the tutorial/article checklist. Full strict-TDD RED→GREEN cycle,
  `AskUserQuestion`-gated at every transition. **Both slices of issue #133 are
  now shipped; issue #133 closed** with a summary comment citing both slices'
  commits.
- **Live verification (screenshots, not just the widget-JSON test) caught two
  real defects the JSON assertions alone could not see:** the Pre-RED shape
  pick (`"box"`) rendered as a label-sized filled pill, visually inconsistent
  with the other 5 rows' fixed-size-icon style — switched to `"hexagon"`; the
  6th row's own label clipped against the legend's fixed 400px canvas height
  at the existing `stepY=65L` — retuned to `54L`. Both corrected in-place
  during GREEN, re-verified live until clean. See `PROJECT_LEARNINGS.md`
  Learning 487.
- **Also live-confirmed Dragon #3** (deferred by S486): `visExport()` PNG
  capture of a `color.background`-only affected node, using Slice 1's own
  fixture — 900+ matching `#CC79A7` pixels in the real exported PNG.
- **Incidental fix:** re-rendering `NEWS.Rmd` → `NEWS.md` found S486's own
  Slice 1 bullet had been added to `NEWS.Rmd` but never actually re-rendered/
  committed to `NEWS.md` (last touched S468) — fixed as a byproduct of this
  session's own render, not a separate action.
- **Verified:** full clean regression read 0 failed/0 error (4640 passed, same
  10 pre-existing `test_modMarkerGenetics.R` warnings — now root-caused, see
  the `[ad hoc]` entry below); `lintr::lint_package()` 0 issues on touched
  files; `devtools::check()` exact pre-existing baseline (2 ERRORs/1
  WARNING/2 NOTEs, all individually attributed, 0 new); live `shinytest2`/
  `chromote` smoke test on the real running app confirmed all 6 legend rows,
  the main diagram's affected-node coloring unaffected by the legend change,
  and the PNG export, 0 diagram/legend console errors.

### 2026-08-08 · [ad hoc] Root-caused the "10 pre-existing test_modMarkerGenetics.R warnings" every session since S448 had carried forward unexamined (Session 487)
- **Deliverable:** the owner asked directly ("what are the warnings? we had
  zero at last release") after seeing `warning: 10` in this session's clean
  regression read. Traced to commit `a319e0c5` (S447, 2026-08-01, issue #130
  Slice 5): both `test_modMarkerGenetics.R` cross-center tests upload a
  hand-derived 2-locus toy fixture where `'CA1'`/`'CA2'` happen to share no
  heterozygous locus; `markerKinship()` correctly warns and returns `NA` for
  that pair (working as designed, not a production bug) — 5× per test × 2
  tests = 10. Confirmed CRAN v2.0.0 (released 2026-07-26) genuinely predates
  S447 and shipped with a clean, 0-warning suite, matching the owner's
  recollection. Filed as a new `BACKLOG.md` Housekeeping item with 2 concrete
  fix options (owner directed file-and-continue over pause-and-fix, since it
  is unrelated to the Slice 2 TDD work in progress).

### 2026-08-08 · [issue #133] Implemented Slice 1 (data model + core rendering) of the affected-status pedigree-diagram design (Session 486)
- **Deliverable:** `affected` is now a recognized, optional logical column
  (`.nprcColumnSchema$possible` + `getPossibleCols()` roxygen); both
  `makePedigreeDiagramData()` and `makePedigreeMatingLayout()` render it
  (dominant `color.background` #CC79A7 Okabe-Ito reddish-purple for
  `affected == TRUE`, an "Affected: Yes/No/Unknown" tooltip line, `as.logical()`
  defensive coercion) — backward-compatible: absent column produces byte-identical
  output to before, confirmed by dedicated regression tests. New sibling fixture
  `inst/extdata/examples/obfuscated_rhesus_mhc_ped_affected.csv`
  (`data-raw/obfuscated_rhesus_mhc_ped_affected.R`, seeded RNG, ~20%/70%/10%
  TRUE/FALSE/NA, disclosed synthetic). Full strict-TDD RED→GREEN cycle,
  `AskUserQuestion`-gated at every transition (2 Pre-RED decisions: D8 fill
  color, the `include` question resolved "not yet").
- **Found and fixed a gap the design doc's own file-touch list did not
  anticipate:** `.addRectilinearWaypoints()` was unconditionally resetting
  every node's `color.background`/`color.border` to `NA`, which would have
  silently erased the new coloring the moment a user selected the
  pre-existing `edgeStyle = "rectilinear"` option (issue #142) — fixed with
  a preserve-if-already-set guard, covered by a new regression test in
  `test_addRectilinearWaypoints.R`. See `PROJECT_LEARNINGS.md` Learning 486.
- **Verified:** full clean regression read 0 failed/0 error (10 pre-existing
  baseline warnings unchanged, 4632 passed/171 skipped); `lintr::lint_package()`
  0 issues on touched files (2 real `nested_ifelse_linter` warnings fixed via
  shared `.affectedColor()`/`.affectedLabel()` helpers, not suppressed);
  `devtools::check()` 2 ERRORs/1 WARNING/2 NOTEs, all individually attributed
  via `git log`/`git status` to pre-existing causes unrelated to this
  session's diff (a non-portable filename from commit `887ee902`/S418, an
  `a2interactive.Rmd` vignette-engine NOTE, a `spelling.Rout` mismatch on
  issue #142-era terms — filed as a new `BACKLOG.md` Housekeeping item, not
  fixed mid-session). Live `shinytest2`/`chromote` smoke test on the real
  running app (Phase 3E) confirmed via the live vis.js Network instance's
  own DataSets — a first pass using raw DOM `outerHTML` produced a false
  negative (canvas-rendered content isn't DOM-inspectable), corrected to
  match `test-e2e-pedigree-module.R`'s own established querying technique;
  see `PROJECT_LEARNINGS.md` Learning 486.
- `NEWS.Rmd` entry added this session. `BACKLOG.md`'s pedigree-diagram
  sequencing cluster updated (S486 progress note); issue #133 stays open
  (Slice 2 — legend + documentation — still pending). See `SESSION_NOTES.md`.

### 2026-08-08 · [issue #133] Ratified an architecture/design document for affected-status pedigree-diagram encoding (Session 485)
- **Deliverable:** `docs/planning/issue133-affected-status-pedigree-diagram-plan.md`
  (`ARCHITECTURE_WORKSTREAM.md`) — 8 ratified decisions (D1-D8, each with a declined
  alternative) and 2 pre-declared vertical slices (full RED/GREEN/DONE/Verify/
  session-boundary contracts) for Tier 2 of the pedigree-diagram sequencing cluster,
  first in the owner's order #133 > #136 > #137 > #138. Grounded in 5 parallel
  research agents (kinship2's `affected` semantics read directly from the installed
  1.9.6.2 package's compiled source; visNetwork/vis.js rendering-option survey; the
  R pipeline's actual threading pattern; a simulated-fixture design; this project's
  own house style) plus this session's own independent verification: confirmed via
  `grep` that `R/modPedigree.R:446` calls `makePedigreeMatingLayout()` (not
  `makePedigreeDiagramData()`) for the live Diagram tab, and ruled out reusing the
  existing `condition`/`status` schema columns (both mean something else, per a
  direct roxygen read the 5 agents' literal `"affected"` grep did not surface — see
  `PROJECT_LEARNINGS.md` Learning 485). Ratified via `AskUserQuestion`, no changes
  requested. No `R/`/`tests/` changes — design/scoping only; a future session
  implements Slice 1 against this contract. See `BACKLOG.md`'s pedigree-diagram
  sequencing cluster (S485 progress note) and `SESSION_NOTES.md`.

### 2026-08-08 · [ad hoc] Filled in this session's own HANDOFFS.md receipt commit sha (Session 484)
- **Deliverable:** Filled in this session's own `HANDOFFS.md` receipt
  `commit: pending` placeholder with the real close-out commit sha
  (`dcc53b34`) -- the same self-correction S331-S344/S466-S470/S472/S482-S483
  each needed, closed within the same session.

### 2026-08-08 · [BL-qmdComparisonRefresh] Refreshed pedigree-diagram-kinship2-reference-comparison.qmd (Session 484)
- **Deliverable:** Tier 1 step (3) of `docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`
  — refreshed `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`, completing Tier 1
  of the pedigree-diagram sequencing cluster (crash bugs S481, issue #145 verification spike S482,
  this refresh). Found the doc's actual scope was broader than "add S482's findings": a `BACKLOG.md`
  item (found S473, never filed) flagged Examples 1-2's "founder-positioning defect" findings as
  stale from issues #143/#144 (both since fixed, S472/S474) — this session's close-out never filed
  it either, only this session finally closed it. Re-ran both example families' own `R` chunks
  against current `master` before editing prose (not from memory): confirmed `203`/`117` now
  correctly position adjacent to their own mate's row, matching kinship2's convention. Rewrote
  Examples 1-2's founder-positioning prose from "confirmed defect, not fixed here" to reflect the
  actual fix, citing #143/#144, with current re-verified output. Built and verified a new Example 4
  (a dam mated to 2 sires, "role-reversed crowding") reproducing S482's own decisive kinship2
  counter-example directly and re-executably in the document — real `align.pedigree()` output
  (`S1, D1, S2`, dam centered, split by pedigree discovery order not sex) alongside `nprcgenekeepr`'s
  own duplicate-node handling of the identical data, rather than only citing S482's research doc.
  Updated the Summary table and closing "kinds of gap" list to add the sire/dam-ordering question
  (issue #145) as its own item and close the founder-positioning item as fixed; updated the
  Purpose/subtitle for the doc's broadened scope (#142 shipped, #143/#144 shipped, #145 open).
  Re-verified `vignettes/a2interactive.Rmd`'s runnable pedigree-diagram example still executes
  cleanly against current `master` (33 animals, 48/53 direct-style nodes/edges, 86/91 rectilinear) —
  re-verification only, no content rewrite, per the folded-in housekeeping ask. Verified the full
  refreshed document via `quarto render` end to end (37 chunks, 0 R errors); deleted the rendered
  HTML after verification, matching this project's established practice of not committing
  `docs/planning/*.qmd` render byproducts. Docs-only session: no `R/`/`tests/` files changed, TDD
  RED/GREEN/REFACTOR gates N/A. `PROJECT_LEARNINGS.md` Learning 484 added (a reference doc's
  embedded empirical claims go stale exactly like a code comment's claims — re-run its own code
  before editing prose, and reproduce a research finding's counter-example re-executably rather than
  citing it); `CLAUDE.md` learning-count pointer bumped (483→484). `BACKLOG.md`'s `.qmd`-staleness
  item marked `[x]` DONE with an S484 progress note. See `SESSION_NOTES.md`, `HANDOFFS.md`.

### 2026-08-08 · [ad hoc] Filled in this session's own HANDOFFS.md receipt commit sha (Session 483)
- **Deliverable:** Filled in this session's own `HANDOFFS.md` receipt
  `commit: pending` placeholder with the real close-out commit sha
  (`638db84e`) -- the same self-correction S331-S344/S466-S470/S472/S482
  each needed, closed within the same session.

### 2026-08-08 · [ad hoc] Proposed an implementation order for GitHub issues #146-153 (Session 483)
- **Deliverable:** Per explicit owner direction ("propose an order to address the Issues... present
  them as session topics to pick up"), produced an evidence-based, codebase-grounded implementation
  order for GitHub issues #146-153 (the "Genetic Metrics PDF capability gap" cluster) — the only
  open-issue cluster with no established sequencing across 4 consecutive session handoffs
  (S479-S482). Found the 8 filed issues cite the older
  `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md` as their source, while a newer,
  revised `..._2026-08-06.md` (one day later) replaced its flat gap list with a formal High/Medium/
  Deferred priority table that was never used to re-triage the issues; used the 08-06 table as
  authoritative. Ran a 3-phase background `Workflow` — 8 parallel per-issue agents (each required to
  `Grep`/`Read` the actual current `R/` source, not estimate from issue text alone) assessing effort,
  codebase readiness, and cross-issue dependencies; one synthesis agent producing a tiered
  recommendation; one adversarial-verify agent that found the tier ordering itself sound (no missing/
  duplicated issue, no violated dependency) but required one correction and two softenings, all
  applied in the final write-up. Wrote
  `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md`: **Tier 1** (design launch) #147
  (sole High-priority item, XL effort); **Tier 2** (ready-to-build Medium) #149 > #146 > #151; **Tier
  3** (policy-gated quick win) #150 — highest codebase readiness in the batch but deliberately
  excluded from the audit's own priority table, needs an explicit owner sign-off; **Deferred**
  (design-only) #152 > #153 > #148, with #148 flagged as filed broader than the audit recommends. Key
  finding: 2 audit High-priority gaps ("Longitudinal genetic-health monitoring," "Ancestry guardrails
  in breeding decisions") have **no corresponding filed GitHub issue** anywhere in #146-153 — flagged
  for a future triage session to file, not implemented speculatively. Added a `BACKLOG.md` progress
  note under the existing "Genetic-metrics PDF audit follow-ups" section. Docs-only session: no
  `R/`/`tests/` files changed, TDD RED/GREEN/REFACTOR gates N/A, Phase 3E runtime smoke test n/a.
  `PROJECT_LEARNINGS.md` Learning 483 added (audit-priority-vs-filed-issue divergence runs both
  directions; multi-agent convergence on shared-context facts is not independent corroboration);
  `CLAUDE.md` learning-count pointer bumped (482→483). Re-rendered the priorities list with this new
  sequencing and presented it via `AskUserQuestion`, fulfilling the owner's "present as session
  topics" request. See `SESSION_NOTES.md`, `HANDOFFS.md`.

### 2026-08-08 · [ad hoc] Phase 0 ledger reconcile: backfill S482's own HANDOFFS.md receipt commit sha self-correction (post-S482)
- **Deliverable:** Phase 0 ledger reconcile (this session, S483) found one commit past
  the `CHANGELOG.md` frontier with no ledger entry: `3f8acc5c` ("docs: S482 -- backfill
  own HANDOFFS.md receipt commit sha"), landed after S482's own close-out commit
  (`b18228ff`) that recorded the entry below.
- **Change:** `3f8acc5c` replaced the S482 `HANDOFFS.md` receipt's `commit: pending`
  placeholder with the real commit sha (`b18228ff (claim stub: 3914d1db)`) -- a
  self-correction of the just-written receipt, not new production work. Same class of
  action as the many prior sessions' equivalent self-fixes recorded further down this
  ledger (e.g. S466-S472's `commit: pending` backfills).

### 2026-08-08 · [issue #145] Verification spike: kinship2 implements no male-left sire/dam rule (Session 482)
- **Deliverable:** Tier 1 step (2) of `docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`'s
  Finding #1/#2 recommendation — before any design work on [issue #145](https://github.com/rmsharp/nprcgenekeepr/issues/145),
  empirically determined kinship2's actual default (no-hints) sire/dam left-right placement behavior.
  Read `align.pedigree()`/`alignped1()`/`autohint()` source directly (kinship2 v1.9.6.2, local-only
  `renv` install) and built 5 synthetic pedigrees exercising the single-pair and multi-mate
  ("crowding") cases issue #145's own body describes. Found kinship2 implements neither a hard
  male-left invariant nor a sex-aware crossing-minimizing soft default: the ordinary direct-pedigree
  spouse-pairing code path has zero `ped$sex` check (unlike two other branches that do), and a
  role-reversed multi-mate test (1 dam, 2 sires) produced a direct counter-example — one sire
  immediately left of the dam, one immediately right, disproving "sire always left of dam" from
  kinship2's own default output. Also found issue #145's own inline citations describe
  crossing-minimization behavior that does not match kinship2's actual source — a second,
  independent citation-reliability flag beyond S480's nomenclature-document finding. Full method,
  evidence, and recommendation:
  `docs/research/issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md`. `BACKLOG.md` progress
  note added; findings posted as a
  [GitHub comment](https://github.com/rmsharp/nprcgenekeepr/issues/145#issuecomment-5227592879) on
  issue #145 (not closed — investigation only, no design/implementation decision made).
  Investigation-only session: no `R/`/`tests/` files changed, TDD RED/GREEN/REFACTOR gates N/A,
  Phase 3E runtime smoke test n/a (no package runtime behavior changed). `PROJECT_LEARNINGS.md`
  Learning 482 added; `CLAUDE.md` learning-count pointer bumped (481→482). See `SESSION_NOTES.md`,
  `HANDOFFS.md`.

### 2026-08-08 · [issue #154] Closed issue #154 (Session 481, post-close-out)
- **Deliverable:** Closed [issue #154](https://github.com/rmsharp/nprcgenekeepr/issues/154) with a
  comment citing the fix commits (`4a60db92`, `db46bde8`, `e58307a2`, `f3173ad4`) and verification
  evidence, per the established GitHub issue close-out checklist (`CLAUDE.md`) — same-session close
  for a `BACKLOG.md`-tracked item. Non-commit, outward-facing action on a public repo — recorded here
  per the ledger's non-commit-action rule (failure mode #27) since it happened after this session's
  own Phase 3F close-out commit (`f3173ad4`).

### 2026-08-08 · [issue #154] Fixed 3 dangling-parent crash bugs in the pedigree-diagram layout engine; closed the free-pass-filter reachability question (Session 481)
- **Deliverable:** Picked up Tier 1 step (1) of `docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`
  (S480). Filed [issue #154](https://github.com/rmsharp/nprcgenekeepr/issues/154) after empirically
  reproducing all 3 candidate crashes (not just reading the code) — `.buildMatingUnitForest()`/
  `.positionMatingUnitForest()`/`.addRectilinearWaypoints()` in `R/makePedigreeDiagramData.R` all
  crashed on realistic dangling-parent input (a sire/dam id with no own row in the pedigree, an
  ordinary occurrence for a focal-animal-trimmed pedigree). Fixed all 3 via strict TDD
  (RED→GREEN→REFACTOR, `AskUserQuestion`-gated at every transition, per `CLAUDE.md`'s Development
  Process Contract): (1) a real individual's `ped$gen = NA` now defaults to generation 0 instead of
  crashing `maxGen`'s contour-array sizing; (2) a mating unit whose sire AND dam are both dangling
  no longer forces a dangling id into `anchor` (the existing single-dangling guard only covered the
  exactly-one-dangling case) — such an "orphan" unit is now positioned as its own independent
  top-level root, and `unitGen`'s NA-vs-`-Inf` fallback bug (`pmax(NA, NA, na.rm = TRUE)` returns
  `NA`, not `-Inf` as the prior comment assumed) is fixed alongside it; (3) `.addRectilinearWaypoints()`'s
  D2 mate-line-dogleg loop now looks up a side's generation defensively, skipping the dogleg for a
  side with no rendered node (a dangling, free-pass parent) instead of an unconditional lookup that
  threw "subscript out of bounds". A second, more severe latent bug (infinite recursion / node-stack
  overflow from an `NA`-unsafe `==` comparison against the now-sometimes-`NA` `anchor` column) was
  caught mid-GREEN when the RED test was re-run against the first-draft fix — see
  `PROJECT_LEARNINGS.md` Learning 481. Also investigated the related, previously-unconfirmed
  free-pass-filter reachability question (`BACKLOG.md`, no issue number) with 2 targeted fixtures;
  neither reproduced a missing/duplicate node, so it is **closed with evidence, not fixed** (see
  issue #154's own closing comment).
- **Verification:** 4 new regression tests (2× `test_positionMatingUnitForest.R`, 1×
  `test_buildMatingUnitForest.R`, 1× `test_addRectilinearWaypoints.R`), all confirmed failing against
  `master` before the fix and passing after; full regression suite clean under both
  `pkgload::load_all()` + `test_dir()` and a full `devtools::check()` run (`FAIL 0 | WARN 10 | SKIP
  186 | PASS 4606`, the 10 warnings pre-existing/unrelated, traced to `test_modMarkerGenetics.R`);
  `devtools::check()` = 0 errors, 0 warnings, 2 pre-existing/unrelated NOTEs (confirmed via Learning
  161's isolate-and-reverify protocol against the untracked, gitignored nomenclature reference file
  that trips a local-only "non-portable file names" false positive); `lintr::lint_package()` 0 lints
  on the touched file; a live `shinytest2`/`chromote` runtime smoke test (Phase 3E) rendering a
  fixture combining all 3 crash shapes through a minimal app matching `R/modPedigree.R`'s exact
  `makePedigreeMatingLayout()` render chain, for both `edgeStyle` values — 0 console errors, widget
  rendered.
- **Housekeeping:** `BACKLOG.md` — removed the B3/B4 items (superseded by issue #154) and closed the
  B6 item with evidence; added a "Progress" note to the S480 sequencing-note pointer.
- Commits: `4a60db92` (claim + file issue #154 + close BACKLOG B3/B4/B6), `db46bde8` (RED),
  `e58307a2` (GREEN).

### 2026-08-08 · [issue #145] Posted a specification-bug comment on issue #145 (Session 480, post-close-out)
- **Deliverable:** User pushed back on this session's own audit report, sharpening its framing:
  issue #145's unverified "standard genetic counseling conventions" premise (unresolved `[2]`-`[7]`
  citations; not confirmed by this repo's own nomenclature reference; no existing rule in
  `R/makePedigreeDiagramData.R` to "correct" in the first place) is a **specification bug** in the
  issue itself, not merely an implementation caveat as this session's audit doc had softer-worded it.
  Per explicit user direction (`AskUserQuestion`: comment on the issue vs. strengthen the audit doc
  vs. both — user picked "comment on issue #145"), posted a comment on
  [issue #145](https://github.com/rmsharp/nprcgenekeepr/issues/145#issuecomment-5227234223) restating
  the audit's Findings #1/#2 in specification-bug terms and recommending the citations be resolved
  (or dropped in favor of kinship2's own verified default behavior) before implementation proceeds.
  Non-commit, outward-facing action on a public repo — recorded here per the ledger's non-commit-
  action rule (failure mode #27) since it happened after this session's own Phase 3 close-out.

### 2026-08-08 · [ad hoc] Pedigree-drawing backlog sequencing audit (Session 480)
- **Deliverable:** User-directed audit, `docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`,
  examining every open pedigree-drawing-related item — GitHub issues #133/#136/#137/#138/#141/#145
  plus 9 `BACKLOG.md`-only items (B1-B9, no issue numbers) found via a full grep sweep — against
  kinship2's documented drawing capabilities (built on the existing `ISSUE_129_KINSHIP2_FEATURE_
  COMPARISON_2026-07-30.md` audit and `pedigree-diagram-kinship2-reference-comparison.qmd`) and the
  standardized human pedigree nomenclature reference document
  (`inst/extdata/reference/Standardized Human Pedigree Nomenclature...html`, gitignored copyrighted
  material per S479, read locally only), and recommending a 3-tier implementation order.
- **Key findings:** (1) the nomenclature document (Bennett et al. 2008, *J Genet Couns*) is a
  commentary/adoption-survey article whose actual symbol/convention tables live in un-transcribed
  figure images, not extractable text — it does **not** textually confirm the male-left/female-right
  placement convention issue #145 cites as its rationale. (2) Direct inspection of
  `R/makePedigreeDiagramData.R`'s positioning functions found zero sex-based ordering logic anywhere
  today — issue #145 is a new-feature design request, not a fix to broken existing behavior, despite
  its own "Correct the placement" framing. (3) Two real dangling-parent crash bugs (`BACKLOG.md`
  items B3/B4, found S473, never fixed) sit in the same code region as #145 and were found to be
  higher real-world risk than any pending feature — recommended first in the sequencing order. (4)
  The owner's own existing priority order for #133/#136/#137/#138 (set in issue #133's body,
  session 436) is preserved, not re-derived.
- **Recommended order (full rationale in the audit):** Tier 1 — dangling-parent crash fixes (B3/B4),
  free-pass-filter reachability check (B6), issue #145's verification-first design, then refresh the
  stale `.qmd` comparison doc (B5); Tier 2 — #133 > #136 > #137 (owner's existing order) plus the
  `highlightNearest` degree=6 follow-up (B9); Tier 3 — explicitly deferred: #138, #141, "Candidate C"
  (B2), pending new evidence or owner sign-off.
- **BACKLOG.md:** added a "Sequencing note" pointer paragraph (before the "Candidate C" item, ~line
  1080) cross-referencing the new audit, matching the discoverability precedent set by the
  `ISSUE_129_KINSHIP2_FEATURE_COMPARISON` audit's own `BACKLOG.md` section header. No new GitHub
  issues filed this session (left to whichever future session picks up Tier 1, per the established
  "audit recommends, a later session files" pattern). No `R/`/`tests/` files touched — TDD gates N/A.
- **Verification:** direct `grep` spot-checks (not solely trusted from the delegated research
  workflow) confirmed the nomenclature document's title/authors/DOI and its Wiley all-rights-reserved
  copyright footer (no change to S479's gitignore disposition), and confirmed the absence of any
  sex-based ordering code in `R/makePedigreeDiagramData.R`. `PROJECT_LEARNINGS.md` Learning 480
  records the generalizable lesson (verify a cited source's actual extractable content, and an
  issue's own bug-vs-feature self-classification, before accepting either at face value).

### 2026-08-08 · [ad hoc] Reconciled undocumented genetic-metrics-PDF audit ghost work (Session 479)
- **Deliverable:** Phase 0 orientation found 2 uncommitted audit docs
  (`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`,
  `-2026-08-06.md`) and 9 correspondent GitHub issues (#145 user-filed; #146-153 mapping to the
  08-06 doc's own "Priority gap analysis" table) — produced by a prior session/run that never
  entered the `SESSION_RUNNER.md` protocol (no Phase 1B claim stub, no commit at all, so the
  commit-log-based ledger reconcile in Phase 0 step 6 could not see it). This entry backfills the
  record of that prior, unidentified work — **this session did not author the audit analysis
  itself**, only verified it (read both docs in full; format/rigor matches the properly-committed
  2026-07-29 baseline audit; no source changes landed between S478 and now to make it stale) and
  committed it.
- **What was committed:** both audit docs, as-is. Per user decision (`AskUserQuestion`), issues
  #145-153 stay GitHub-only — this project's established convention is that `BACKLOG.md` is an
  active work log, not an issue-tracker mirror (14 other pre-existing open issues already carry no
  `BACKLOG.md` entry); an entry gets added only once a future session actually picks one up to
  plan/implement, matching issue #142's own precedent.
- **What was NOT committed, and why:** 3 reference files also found untracked in
  `inst/extdata/reference/` (`5201430.pdf`, `bioinformatics_24_2_279.pdf`, a saved "Standardized
  Human Pedigree Nomenclature" page) are full-text copyrighted journal articles/pages (Nature
  Publishing Group 2005, Oxford University Press 2008, Wiley — none open-access-marked), unlike
  the one already-committed `Master_Genetic_metrics_2_14_15.pdf` (an unpublished NPRC
  working-group document, a different copyright situation). This repo is PUBLIC
  (`gh repo view --json visibility` → `PUBLIC`); per user decision, these 3 files are excluded via
  a new `.gitignore` block rather than committed. Also cleaned up, per user decision: 2 stale local
  `docs/planning/*.html` render byproducts (dated 2026-07-29 and 2026-08-04, unrelated to this
  ghost-work finding — their `.md`/`.qmd` sources are already safely committed) and 2 stray
  `inst/**/.DS_Store` files.
- See `PROJECT_LEARNINGS.md` Learning 479 (the commit-log ledger reconcile's blind spot for a
  zero-commit ghost session) and `CLAUDE.md`'s new Phase 0 addition.

### 2026-08-04 · [ad hoc] Documented issue #142's edgeStyle option in vignettes/a2interactive.Rmd (Session 478)
- **Deliverable:** user-directed (not from `BACKLOG.md`) — add a demonstration of issue #142's
  `edgeStyle` (direct vs. rectilinear) option to `vignettes/a2interactive.Rmd`'s existing
  "Pedigree Diagram" section, prompted by the user recalling the request and being unable to find
  its tracking issue (closed, so absent from the default open-only `gh issue list`).
- **Confirmed nothing needed building:** `makePedigreeMatingLayout(edgeStyle = c("direct",
  "rectilinear"))` was already `@export`ed and fully script-callable (issue #142, S465/S468); the
  only gap was the vignette never demonstrating it.
- **Added** a new "### Rectilinear Edge Style" subsection (data chunk, prose on the extra waypoint
  nodes/edges and `color.background`/`color.border`/`color` columns, and a render chunk matching
  `R/modPedigree.R`'s actual style-aware `highlightNearest(degree = 6L)`), plus a "### Direct Edge
  Style" heading for symmetry around the pre-existing content. Scope (demo + parity fix) confirmed
  via `AskUserQuestion`.
- **Fixed a real parity drift:** the existing direct-style render chunk's `nodesIdSelection`
  waypoint-exclusion regex had only 2 of `R/modPedigree.R`'s actual 5 reserved node-id prefixes —
  harmless under direct style alone, but wrong once shown next to the new rectilinear chunk. Both
  chunks now use the identical, correct 5-prefix pattern.
- **Added 4 new words** (`edgeStyle`, `routings`, `highlightNearest`, `demoPed`) to `inst/WORDLIST`
  — the genuinely new spelling flags this session's own prose introduced, isolated from the
  separately-tracked pre-existing 6-word drift via `spelling::spell_check_package()`, left untouched.
- **Verified:** `rmarkdown::render()` end-to-end (142/142 chunks, no errors); `devtools::check()`
  0 errors/0 warnings/1 pre-existing NOTE (unchanged, the known `a2interactive.Rmd` vignette-engine
  NOTE); full regression suite exact baseline match (0 failed/0 error, 4573 passed, 171 skipped, 10
  pre-existing warnings, `NOT_CRAN=true`); reverted a collateral `devtools::document()`
  `man/modMarkerGeneticsServer.Rd` reflow (Learnings 476/477 pattern, third consecutive hit).
- **No R/ or tests/ files changed** — TDD RED/GREEN/REFACTOR gates N/A (S448/S451-455/S475-477
  docs-only precedent). No `NEWS.Rmd` entry needed (issue #142 already documented there, S468).
- Broadened `CLAUDE.md`'s `a2interactive.Rmd` checklist to also cover a new parameter added to an
  already-documented exported function, not just a brand-new function — the shape of gap this
  session found. See `PROJECT_LEARNINGS.md` Learning 478.

### 2026-08-04 · [ad hoc] Wired the actual process fix for recurring `lintr` debt (Session 477)
- **Deliverable:** `BACKLOG.md` Housekeeping item "wire a process fix so `lintr` debt stops
  re-accumulating" (split from the S462 sweep) is resolved.
- **Corrected the item's own stale framing:** `.github/workflows/lint.yaml` already existed
  and already ran `lintr::lint_package()` on every push to `master` (and on PRs) with
  `LINTR_ERROR_ON_LINT: true` -- there was no CI job to add. `gh run list --workflow=lint.yaml`
  showed it had been red since S472's push and stayed red through S473-S476's, because
  `master` carries no branch protection requiring the check to pass -- a failing run blocks
  nothing and is easy to never look at.
- **Fixed the 2 live violations** in `R/makePedigreeDiagramData.R` (REFACTOR-only, no
  RED/GREEN -- style-only, no behavior change): a `commented_code_linter` false positive on a
  design-rationale comment suppressed via a documented `# nolint start/end` block (S466
  precedent, not deleted/reworded); an 84-char `line_length_linter` hit wrapped onto two lines
  matching this file's own established `<-`-then-indented-RHS house style.
- **Added the actual recurrence-prevention mechanism:** a new `CLAUDE.md` "Lint close-out
  checklist" requiring sessions to lint touched files (package loaded) before closing out,
  since the CI job's own existence had already been proven insufficient by 4 sessions
  committing on top of a red run without noticing.
- **Verified:** `lintr::lint_package()` (package loaded, matching CI's exact invocation) 0
  lints package-wide (was 2); full regression suite 0 failed/0 error (4573 passed, 171
  skipped, 10 pre-existing baseline warnings, unchanged from S476); `devtools::check()` 0
  errors/0 warnings/2 pre-existing NOTEs (spelling-wordlist drift + `a2interactive.Rmd`
  vignette-engine note, both unrelated, unchanged from S476 baseline).
- See `BACKLOG.md`, `PROJECT_LEARNINGS.md` Learning 477.

### 2026-08-04 · [ad hoc] Root-caused and fixed the `renv.lock` dependency-tracking gap (Session 476)
- **Deliverable:** the 10 dev-tool packages missing from `renv.lock` since ~S459 (flagged
  S474/S475) are now correctly captured, and the mechanism that dropped them is fixed so it
  cannot recur silently.
- **Root cause:** `renv/settings.json`'s `snapshot.type: "explicit"` makes a plain
  `renv::snapshot()` scan only `DESCRIPTION`'s `Imports`/`Depends`/`LinkingTo` fields,
  silently excluding every `Suggests`-only package. Traced precisely (not speculatively)
  against renv 1.2.3's own source.
- **Fix:** added `devtools`+`quarto` to `DESCRIPTION`'s `Suggests` (their existing
  `Config/renv/profiles/dev/dependencies`/`Config/Needs/website` declarations are inert --
  read only by an actively-enabled "dev" renv profile / by `pak`, neither ever used here);
  installed 6 separately-discovered not-installed `Suggests` packages (`covr`/`kableExtra`/
  `markdown`/`png`/`shinyWidgets`/`spelling`); ran the real `renv::snapshot(dev = TRUE)`
  (157 packages now recorded, up from 95); documented `dev = TRUE` as the required standing
  invocation in `CLAUDE.md`'s Build/Test/Verify section.
- **Verified:** `renv::status(dev = TRUE)` reports "No issues found"; a genuinely fresh
  `renv::restore(library = <empty temp dir>)` installed all 16 target packages from the
  fixed lockfile alone; full regression suite unchanged (0 failed/0 error, 3854 passed, 183
  skipped, 10 pre-existing baseline warnings); `devtools::check()` 0 errors/0 warnings/2
  NOTEs (both pre-existing/unrelated, confirmed via `git diff --stat` that `vignettes/` was
  untouched this session). A collateral `devtools::document()` reflow of
  `man/modMarkerGeneticsServer.Rd` (roxygen2-version line-wrap drift, not the previously-
  tracked iCloud duplicate-file pattern) was reverted before committing.
- Infra/lockfile-only session -- no `R/`/`tests/` files changed, TDD RED/GREEN/REFACTOR
  gates did not apply (S448/S451/S452/S453/S455/S475 precedent). See `BACKLOG.md`
  Housekeeping, `PROJECT_LEARNINGS.md` Learning 476.

### 2026-08-04 · [issue #142] Closed the issue (Session 475)
- **Action:** `gh issue close 142 --reason completed --comment "..."` -- the rectilinear
  mate-line/sibship-bar waypoint style was fully implemented and verified across Sessions
  463-468 (design, Slice 1, Slice 2) but the issue itself was never closed, discovered via
  this session's Phase 0 cross-check of `gh issue list` against `BACKLOG.md`'s own DONE
  markers. Closing comment cites the Session 463-468 `CHANGELOG.md` entries and their
  verification evidence. See `PROJECT_LEARNINGS.md` Learning 475 (a new same-session
  GitHub-issue-close-out checklist, `CLAUDE.md`, was ratified after finding this as the
  third consecutive instance of the same gap).

### 2026-08-04 · [issue #143] Closed the issue (Session 475)
- **Action:** `gh issue close 143 --reason completed --comment "..."` -- the founder-
  positioning defect fix was fully implemented and verified Session 472, first flagged as
  still-open-despite-resolved by Session 473's own orientation report and again by Session
  474's, but never closed until this session. Closing comment cites the Session 472
  `CHANGELOG.md` entry and its verification evidence. See `PROJECT_LEARNINGS.md` Learning
  475.

### 2026-08-04 · [issue #144] Closed the issue (Session 475)
- **Action:** `gh issue close 144 --reason completed --comment "..."` -- the anchor-side
  row-mismatch fix was fully implemented and verified Session 474; flagged as a next-step
  in that session's own handoff but not acted on until this session. Closing comment cites
  the Session 473-474 `CHANGELOG.md` entries and their verification evidence. See
  `PROJECT_LEARNINGS.md` Learning 475.

### 2026-08-04 · [issue #144] Implemented the anchor-side row-mismatch fix (Session 474)
- **Deliverable:** `R/makePedigreeDiagramData.R` -- 3 synchronized edits per the ratified plan
  (`docs/planning/issue144-anchor-row-mismatch-fix-plan.md`), full Strict TDD RED/GREEN/REFACTOR
  cycle (`AskUserQuestion`-gated at every transition). Adds a per-individual `effGenOf` (max of an
  anchor's own gen and every mating unit it anchors), threads it through
  `positionIndividual()`'s row-reservation call sites, and extends the `dispGenOf` override (issue
  #143's own pattern) to anchor occurrences. Resolves all 51 real-fixture anchor-side mismatches
  (51 -> 0), maintains issue #143's 0 non-anchor mismatches, `edgeStyle="rectilinear"` node count
  1279 -> 1228 (the D2 dogleg no longer fires for any of the resolved units). One honestly-bounded
  residual remains (an anchor anchoring 2+ mating units at genuinely differing gen, or a single-unit
  anchor with a shallower D5 child) -- not reachable in either bundled real fixture; 2 new committed
  regression tests assert deterministic, non-crashing, non-NA behavior for both shapes rather than
  leaving them unexercised.
- **Verification:** Full regression suite 0 failed/0 error (4573 passed, 171 skipped, 10
  pre-existing unrelated warnings); `devtools::check() --as-cran` 0 errors/0 warnings/2 pre-existing
  unrelated NOTEs (vignette-engine + a spelling-wordlist drift already tracked, `BACKLOG.md`
  Housekeeping since S465); live `shinytest2`/`chromote` verification against the real running app
  confirmed 3 previously-mismatched anchors (`8P17E3`/`KS2ZNP`/`B2U6J7`, gap 1/3/4) now render
  on-row under both `edgeStyle` values with zero projection nodes and zero diagram-related console
  errors, and issue #143's own already-fixed non-anchor unit (`FD3BB6`) is unaffected.
- **Incidental:** found and fixed a severe `renv` environment failure (a mid-project R 4.6.1 upgrade
  left the project library empty; 10 dev-tool packages -- `testthat`/`pkgload`/`devtools`/
  `roxygen2`/`shinytest2`/`chromote`/`dplyr`/`mockery`/`quarto`/`shinyBS` -- turned out to be
  missing from `renv.lock` itself, in both HEAD and the long-standing uncommitted diff) via
  `renv::restore()` + `renv::install()`, confirming `renv.lock`/`DESCRIPTION` stayed unchanged
  throughout. Root-causing and fixing the lockfile itself is filed as a new `BACKLOG.md`
  Housekeeping item (not fixed here -- out of scope for this implementation session). See
  `PROJECT_LEARNINGS.md` Learnings 473/474.

### 2026-08-04 · [issue #144] Designed the anchor-side row-mismatch fix (Session 473)
- **Deliverable:** `docs/planning/issue144-anchor-row-mismatch-fix-plan.md`, owner-ratified via
  `AskUserQuestion`. Adopts "Candidate B -- effective-row threading": extends issue #143's own
  `dispGenOf`-override pattern to anchor occurrences via a new per-individual `effGenOf`, ~11
  non-comment lines across 3 synchronized edits entirely inside `.positionMatingUnitForest()`;
  `.buildMatingUnitForest()` (anchor selection) stays untouched. **This session's own empirical
  work disproved the standing assumption that fixing this "would require restructuring
  `.positionMatingUnitForest()`'s recursive positioning itself... materially larger than issue
  #143's point-patch"** (`BACKLOG.md`, issue #144's own filed body) -- a node's own
  row-reservation was already fully decoupled from its `x`-computation and its recursion into
  children (see `PROJECT_LEARNINGS.md` Learning 471). Produced via a 7-agent
  characterize-then-design Workflow (4 parallel characterization agents -- mechanism
  verification, empirical enumeration of all 51 real-fixture mismatches, grep-based
  test/callsite inventory, prior-context/dragons read -- followed by 3 independently-generated
  candidate designs, each empirically validated in its own isolated git worktree against the
  real fixture and the full test suite), then a 3-agent adversarial review (mechanism-fidelity,
  empirical gap-check, workstream-checklist compliance) mirroring S471's own review pattern for
  the sibling #143 plan. The review found and this session incorporated: a factual miscount (3,
  not 4, directly-affected test files), a correction to an over-broad "provable no-op" claim
  about one guard, a widened disclosure of the fix's one honestly-bounded residual (reachable
  with a single mating unit plus a D5 direct child, not only multi-unit anchors), and 2 newly-found
  pre-existing/unrelated crash bugs plus one documentation-staleness gap -- none changed the
  adopted Decision or its core numeric claims, all independently re-verified against live source.
  Two alternatives were fully built and empirically validated but not adopted: Candidate A
  (upstream D2 tie-break redesign) also fully works but forces a mathematically-necessary
  duplicate-node/anchor redistribution (128->103 duplicates, 2->21 multi-anchor individuals);
  Candidate C (leave anchor rows alone, visually signpost the generation-span instead) does not
  reduce the mismatch count and would need its own fresh owner sign-off to redefine "fixed" --
  both preserved as live future directions in the plan's §5/§8. `BACKLOG.md` updated: the #144
  planning item marked DONE, a new READY implementation item added, and 4 new incidental-finding
  items filed (Candidate C's connector idea as a standalone enhancement; the pre-existing
  `.addRectilinearWaypoints()` dangling-parent crash under `edgeStyle="rectilinear"`; 2 more
  pre-existing dangling/NA-gen crashes found during review; the
  `pedigree-diagram-kinship2-reference-comparison.qmd`/`a2interactive.Rmd` compounding-staleness
  housekeeping item -- the last of which was itself a gap left by S472's close-out, since the
  #143 plan's own §8 had directed filing it and no session ever did). No implementation code
  changed this session -- the plan is the deliverable; implementation is a separate future
  session. `PROJECT_LEARNINGS.md` Learning 471/472 added; `CLAUDE.md`'s learning-count
  cross-reference updated (470->472, Sessions 1-472+->1-473+).

### 2026-08-04 · [ad hoc] Phase 0 ledger reconcile: backfill S472's own HANDOFFS.md receipt commit sha self-correction (post-S472)
- **Deliverable:** Phase 0 ledger reconcile (this session, S473) found one commit past
  the `CHANGELOG.md` frontier with no ledger entry: `d6ab24c4` ("docs: S472 -- backfill
  own HANDOFFS.md receipt commit sha"), landed after S472's own close-out commit
  (`1adaf85a`) that recorded the entry below.
- **Change:** `d6ab24c4` replaced the S472 `HANDOFFS.md` receipt's `commit: pending`
  placeholder with the real commit sha (`1adaf85a`) -- a self-correction of the
  just-written receipt, not new production work. Same class of action as the many
  prior sessions' equivalent self-fixes recorded further down this ledger (e.g.
  S466-S470's `commit: pending` backfills).

### 2026-08-04 · [issue #143] Implemented the founder-positioning defect fix (Session 472)
- **Deliverable:** implemented the ratified plan
  (`docs/planning/issue143-founder-positioning-fix-plan.md`) via Strict TDD
  (RED/GREEN/REFACTOR, owner-gated at each transition). Both synchronized
  edits shipped together in one commit
  (`R/makePedigreeDiagramData.R:494,585-600ish`): a free-pass leaf's contour
  reservation, and every non-anchor occurrence's final displayed row, now
  come from that occurrence's own mating unit's `gen`, not the underlying
  individual's global tree-native `gen`. Resolves 96 of the S470 audit's
  147 real-fixture mismatches (all free-pass + duplicate-node cases); the
  remaining 51 anchor-side mismatches are unaddressed by design (issue
  #144, owner-directed follow-up). RED-phase tests: rewrote
  `test_positionMatingUnitForest.R`'s gen-semantics assertions with
  hand-verified values; added an exact x/gen regression test empirically
  confirmed to discriminate a desynchronized (only one of the two edits)
  fix -- substituted for the plan's own proposed minimum-separation test,
  which this session found does not discriminate defect from correct
  behavior in this algorithm (see `PROJECT_LEARNINGS.md` Learning 470);
  added a committed real-fixture regression test asserting 0 non-anchor +
  51 anchor mismatches; updated `test_addRectilinearWaypoints.R`'s D2
  non-anchor test and both files' real-fixture node-count assertions
  (1375L -> 1279L). Verified: full regression suite 0 failed/0 error (4560
  passed, 171 skipped); `devtools::check()` 0 errors/0 warnings (1
  pre-existing, unrelated NOTE, confirmed by temporarily setting aside
  known untracked debris and restoring it); live-verified in the running
  app via `shinytest2` under both `edgeStyle` values -- FD3BB6 (the
  audit's own spot-checked example) plus 3 more previously-mismatched
  units now render on-row, zero diagram-related console errors.
  `BACKLOG.md` updated (item marked DONE; 1 new low-priority incidental
  finding added -- a 1-node live-vs-offline count discrepancy, unrelated
  to this fix, unconfirmed root cause).

### 2026-08-03 · [issue #144] Filed the anchor-side row-mismatch gap as its own GitHub issue (Session 471)
- **Deliverable:** opened [issue #144](https://github.com/rmsharp/nprcgenekeepr/issues/144),
  owner-directed (the ratified `docs/planning/issue143-founder-positioning-fix-plan.md`
  §8 explicitly instructs filing this at close-out). Documents that 51 of 237
  real-fixture mating units (22%) have an anchor-side row mismatch the issue #143
  fix does not address -- discovered via direct empirical re-verification during
  the #143 fix design, not previously known. `BACKLOG.md` updated with a new item
  linking the issue.

### 2026-08-03 · [issue #143] Designed the founder-positioning defect fix (Session 471)
- **Deliverable:** `docs/planning/issue143-founder-positioning-fix-plan.md`,
  owner-ratified via `AskUserQuestion`. Adopts the S470 audit's own "point-patch"
  candidate (two synchronized edits in `.positionMatingUnitForest()`, plus a
  dangling-free-pass-parent guard found necessary by this session's own
  adversarial review of the draft, which reproduced a real crash by applying the
  proposed patch to a scratch copy and running it against existing tests).
  Direct empirical verification of the corrected patch against the real fixture
  found the S470 audit's own `onFreePassLeaf=90` figure had silently combined 39
  genuine free-pass mismatches with 51 anchor-side mismatches (the audit's
  detection script could not distinguish them); the fix resolves 96 of 147 (65%)
  of the audit's originally-confirmed real-fixture mismatches, with the anchor
  -side remainder tracked as issue #144 (owner-directed, above). Incidentally
  found (reported, not fixed) a separate, likely-rare structural inconsistency
  between `.buildMatingUnitForest()`'s and `.positionMatingUnitForest()`'s own
  free-pass criteria -- new low-priority `BACKLOG.md` item added. No
  implementation code changed this session -- the plan is the deliverable;
  implementation is a separate future session.

### 2026-08-03 · [issue #143] Filed the founder-positioning defect as its own GitHub issue (Session 470)
- **Deliverable:** opened
  [issue #143](https://github.com/rmsharp/nprcgenekeepr/issues/143),
  owner-confirmed before filing (per `SAFEGUARDS.md`'s "actions visible to
  others" guidance -- deferred at initial close-out, then confirmed via a
  follow-up `AskUserQuestion`). Summarizes the founder-positioning defect's
  root cause, real-fixture evidence (62% of mating units affected), and the
  `docs/audits/FOUNDER_POSITIONING_DEFECT_AUDIT_2026-08-03.md` audit link.
  `BACKLOG.md`'s founder-positioning item and this session's `HANDOFFS.md`
  receipt updated to reference the filed issue.

### 2026-08-03 · [ad hoc] Filled in this session's own HANDOFFS.md receipt commit sha (Session 470)
- **Deliverable:** Filled in this session's own `HANDOFFS.md` receipt
  `commit: pending` placeholder with the real close-out commit sha
  (`0a36145c`) -- the same self-correction S331-S344/S466-S469 each needed,
  closed within the same session. Also fixed a stray literal `<` left at
  the start of the free-text prose block.

### 2026-08-03 · [BL-founderPositioningAudit] Characterized the founder-positioning defect against real bundled pedigree fixtures (Session 470)
- **Deliverable:** audit report
  (`docs/audits/FOUNDER_POSITIONING_DEFECT_AUDIT_2026-08-03.md`), no code
  changes -- resolves `BACKLOG.md`'s (found S463) open "how often does this
  occur in practice" question. On the real 375-individual rhesus fixture
  (`obfuscated_rhesus_mhc_ped.csv`), **147 of 237 mating units (62%)** have a
  mis-positioned parent -- **57 of those 147 (39%) on genuine multi-mate
  duplicate nodes**, not just single-mate founders, broadening the defect's
  known scope beyond S463's synthetic-only characterization. Root cause:
  `.positionMatingUnitForest()` assigns every non-anchor parent occurrence's
  row from that parent's own global `gen`, never from the specific mating
  unit the occurrence belongs to (`R/makePedigreeDiagramData.R:585-591`).
  Independently re-derived via a blind `Workflow` agent (identical counts;
  general rule: mismatch iff parent's own `gen` != mating-unit `gen`).
  Incidentally found (reported, not fixed) that
  `rhesusPedigree_fromCenter.csv` is byte-identical to
  `obfuscated_rhesus_mhc_ped.csv` on every shared column, contradicting
  `data-raw/rhesusPedigree.R`'s docstring claim that it is an independent
  raw/pre-obfuscation source. `BACKLOG.md`'s founder-positioning item updated
  with these findings (now READY to plan, not just DECISION NEEDED); a new
  low-priority item added for the fixture-provenance docstring gap.
  `PROJECT_LEARNINGS.md` Learnings 467-468. See `SESSION_NOTES.md` S470.

### 2026-08-03 · [ad hoc] Filled in this session's own HANDOFFS.md receipt commit sha (Session 469)
- **Deliverable:** Filled in this session's own `HANDOFFS.md` receipt
  `commit: pending` placeholder with the real close-out commit sha
  (`83c4a911`) -- the same self-correction many previous sessions (e.g.
  S331-S344, S466, S467, S468) each needed, closed within the same session
  rather than left for the next session's Phase 0 reconcile to catch and
  backfill.

### 2026-08-03 · [BL-dupNodeArc] Duplicate-node connector renders as an arc, not straight (Session 469)
- **Deliverable:** fixed the pedigree diagram's duplicate-node connector to render
  as a curved/arched dashed line, matching the kinship2/reference-pedigree
  convention (found S468). `makePedigreeMatingLayout()`'s `dupEdges` gain a
  per-edge vis.js `smooth` override (`enabled = TRUE`, `type = "curvedCW"`,
  `roundness = 0.2`), overriding `R/modPedigree.R`'s widget-level
  `visEdges(smooth = FALSE)`; every other edge is unaffected. Pre-RED source
  reading found and fixed a second integration site:
  `.addRectilinearWaypoints()`'s own fresh waypoint edges needed matching
  NA-filled `smooth.*` columns to avoid an "undefined columns selected" crash
  once the passed-through direct-style edges carried the new columns; the arc
  survives unchanged under `edgeStyle = "rectilinear"` too (live-verified).
  Full TDD cycle (RED -- 2 new tests + 1 existing test's column-set assertion
  updated for the intentionally-changed contract; GREEN; REFACTOR
  owner-confirmed skip). Verified: regression suite 0 failed/0 error (4524
  passed, exact baseline warnings); `devtools::check()` 0 new
  errors/warnings/notes; `lintr` 0. Live `shinytest2`/`chromote` verification
  against the real 375-individual fixture (both edge styles) plus a small
  isolated-fixture screenshot visually confirming the arc. `_pedigree_browser.Rmd`
  wording updated ("dashed line" -> "curved, dashed line"), re-rendered. No
  `NEWS.Rmd` entry, per the shinyBS-popover-fix precedent (S437/438) -- a bug
  fix to existing behavior is outside that checklist's scope. See `BACKLOG.md`.

### 2026-08-03 · [ad hoc] Filled in this session's own HANDOFFS.md receipt commit sha (Session 468)
- **Deliverable:** Filled in this session's own `HANDOFFS.md` receipt
  `commit: pending` placeholder with the real close-out commit sha
  (`5c19a163`) -- the same self-correction many previous sessions (e.g.
  S331-S344, S466, S467) each needed, closed within the same session rather
  than left for the next session's Phase 0 reconcile to catch and backfill.

### 2026-08-03 · [issue #142] Implement Slice 2: edgeStyle wiring, UI toggle, and live re-verification (Session 468)
- **Deliverable:** completes issue #142 (rectilinear mate-line/sibship-bar waypoint
  style). **(a)** `makePedigreeMatingLayout()` gains `edgeStyle = c("direct",
  "rectilinear")` (default `"direct"`, byte-identical existing behavior);
  `"rectilinear"` calls Slice 1's `.addRectilinearWaypoints()`. **(b)**
  `R/modPedigree.R` gains a `radioButtons()` style toggle -- net-new UI layout
  rendered alongside the widget inside the Diagram tab's own `uiOutput`, only when a
  diagram is actually shown (D4, no existing "home" for the control); a style-aware
  node cap (`pedigreeDiagramMaxNodesRectilinear = 400L`, resolved via
  `.currentEdgeStyle()`/`.currentDiagramCap()` closures defaulting to "direct" before
  the toggle has ever rendered); click-to-navigate and the search-dropdown id-prefix
  filters extended to the 3 new `__drop_`/`__bar_`/`__proj_` reserved prefixes,
  keeping `__dup_` clickable (D3).
- **Cap ratification:** the design doc's own suggested ~380-individual rectilinear cap
  was re-derived and found dimensionally wrong -- its formula
  (`directCap * (rectTotal/directTotal) / (rectTotal/individuals)`) algebraically
  simplifies to `directCap * individuals / directTotal`, which does not depend on the
  rectilinear/direct ratio at all despite appearing to. The dimensionally-correct
  re-derivation (preserve the ~1,480-node ceiling the 750 direct cap targets, divided
  by rectilinear's actual measured 3.667 nodes/individual) gives ~404. Owner ratified
  **400** via `AskUserQuestion`.
- **Live re-verification (part d) found and fixed a real regression:** #134's
  `GA204Z`/`8LKBV9` loop renders correctly under the rectilinear style (0
  diagram-related console errors); #135's search dropdown is unaffected
  (unit-test-covered). But `highlightNearest` hover-highlighting -- the exact risk the
  design doc's Section 3 D3 flagged but left unresolved -- was confirmed live to be a
  real, not hypothetical, regression: degree-1 hover often reaches only an invisible
  waypoint node under the rectilinear style. Measured concretely on the real
  375-individual fixture via `shinytest2`/`chromote` (triggering vis.js's internal
  `hoverNode` event directly and inspecting the DataSet's own dimmed/undimmed state):
  hovering an individual who is only a child, or a parent whose own mate-line was
  rerouted through a D2 projection node, lit up **nothing visible at all** -- worse
  than the direct style's own guaranteed-visible union-dot minimum. Owner chose a
  bounded mitigation via `AskUserQuestion`: `highlightNearest`'s `degree` is now
  style-aware (1 for direct, unchanged; 6 for rectilinear, covering the concretely
  measured hop distances, up to 4 for a single-child union). Live re-verified after
  the fix: the same previously-blank hover now lights up 2 real individual ids plus 3
  union dots. Documented as a bounded mitigation, not a full fix (a very wide
  sibship's D1 bar chain can still exceed 6 hops) -- new `BACKLOG.md` item filed.
  Legend and PNG export also live-confirmed unaffected.
- **Strict TDD**, 3 checkpoint commits: RED (4 tests) -> GREEN for Layer 1 (data
  layer); RED (7 tests) -> GREEN for Layer 2 (UI layer); RED (1 test) -> GREEN for the
  `highlightNearest` degree fix found during live verification. REFACTOR skipped
  (owner-confirmed via `AskUserQuestion`, GREEN already matched established style).
- **Verified at every checkpoint:** full regression suite 0 failed/0 error (10
  pre-existing baseline warnings, unchanged; final count 4515 passed, +38 new tests
  over the S467 baseline); `devtools::check()` 1 WARNING/2 NOTEs, exact pre-existing
  baseline, 0 new, at every checkpoint (including the already-tracked 6-word
  spelling-drift NOTE from `BACKLOG.md`, found S465 -- this session's own roxygen
  edit added more occurrences of the same already-flagged words, not a new distinct
  one); `lintr` 0 lints on every changed file (3 lints found and fixed on Layer 2's
  first pass: a `commented_code_linter` false positive on "D1/D2" reading as division,
  an 81-char line, an unnecessary quoted name in `radioButtons()` choices). Live
  `shinytest2`/`chromote` re-verification against the real app throughout Part (d),
  both before (confirming the regression) and after (confirming the fix) the
  `highlightNearest` change -- satisfies Phase 3E. See
  `docs/planning/pedigree-diagram-rectilinear-waypoint-design-plan.md`, `BACKLOG.md`'s
  now-DONE issue #142 item, `PROJECT_LEARNINGS.md` Learning 463.

### 2026-08-03 · [ad hoc] Log a duplicate-node connector arc-rendering gap found via owner comparison against a reference pedigree image (Session 468)
- **Deliverable:** an owner observation comparing this app's Pedigree Diagram against
  a reference image (rpubs.com/dliupress/pedigreedemo) found that this app's own
  duplicate-node mechanism (D6, issue #129 Slice 3, S461) already creates a dashed
  connector back to the real individual, matching the reference convention -- but
  renders it straight, not arched, because `R/modPedigree.R`'s
  `visEdges(smooth = FALSE)` applies globally to every edge in the widget. Logged as a
  new `BACKLOG.md` item (analytically separate from the in-progress issue #142 Slice 2
  work), not fixed this session.

### 2026-08-03 · [ad hoc] Filled in this session's own HANDOFFS.md receipt commit sha (Session 467)
- **Deliverable:** Filled in this session's own `HANDOFFS.md` receipt
  `commit: pending` placeholder with the real close-out commit sha
  (`7e2e4d94`) -- the same self-correction many previous sessions (e.g.
  S331-S344, S466) each needed, closed within the same session rather than
  left for the next session's Phase 0 reconcile to catch and backfill.

### 2026-08-03 · [BL-e2eStaleAssertion] Fix stale `test-e2e-pedigree-module.R` assertions for the known-trio Diagram edge routing (Session 467)
- **Deliverable:** `tests/testthat/test-e2e-pedigree-module.R:203-208`'s "known
  trio" edge assertions rewritten to match the live, already-shipped
  `__union_<n>` mating-unit routing (S461/Option 2 Slice 3) instead of the
  stale pre-Option-2 direct sire/dam edge -- fixes the 2 stale-assertion
  failures found by the scheduled E2E CI run (`run 30796362515`, found S462).
  REFACTOR-only per `PROJECT_LEARNINGS.md`'s `[refactor-only]` reflex (a
  green-on-arrival test correction, no production code changed), gated via
  `AskUserQuestion` `PRE-RED->REFACTOR`.
- **PRE-RED live verification (not guessed from the backlog's prose
  description):** a standalone driver script (scratchpad, not the test file)
  drove the real app against the known-trio fixture and queried the live
  vis.js network directly, confirming the edge into child `EBG407` comes from
  `__union_29`, and that union node's own incoming edges come from `PH0IXL`
  and `U5VLXP` -- plain real ids, not duplicate-occurrence ids, for this
  specific trio. Since the union node's numeric suffix is a volatile
  sequential index (not a stable identity), the new assertion captures it via
  `"from":"__union_[0-9]+"` pattern match rather than hardcoding `__union_29`,
  then separately asserts the sire/dam edges into the captured union id.
- **Verification:** the file itself (29/29 assertions pass, live app);
  full local regression suite (0 failed/0 error, 10 pre-existing warnings,
  exact S465/S466 baseline); `devtools::check()` (1 WARNING/2 NOTEs, exact
  pre-existing baseline, 0 new); `lintr::lint()` on the changed file (0
  lints). See `BACKLOG.md`, `PROJECT_LEARNINGS.md` Learning 462.

### 2026-08-03 · [ad hoc] Phase 0 ledger reconcile: backfill S466's own HANDOFFS.md receipt commit sha self-correction (post-S466)
- **Deliverable:** Phase 0 ledger reconcile (this session, S467) found one commit past
  the `CHANGELOG.md` frontier with no ledger entry: `ec3bf90e` ("docs: S466 final
  close-out -- handoff receipt commit sha"), landed after S466's own close-out commit
  (`211f3f4a`) that recorded the entry below.
- **Change:** `ec3bf90e` replaced the S466 `HANDOFFS.md` receipt's `commit: pending`
  placeholder with the real commit sha (`211f3f4a`) -- a self-correction of the
  just-written receipt, not new production work. Same class of action as the many
  prior sessions' equivalent self-fixes recorded further down this ledger (e.g.
  S331-S344's `commit: pending` backfills).

### 2026-08-03 · [BL-lintCleanup] Clean up the accumulated `lintr::lint_package()` warnings, satisfying the owner-directed issue #142 sequencing gate (Session 466)
- **Deliverable:** all 41 pre-existing `lintr::lint_package()` warnings across the
  16 TRACKED files fixed (the other 4, of the original 45, were on the untracked
  iCloud-duplicate `R/modMarkerGenetics 2.R`, correctly out of scope). REFACTOR-only
  per `PROJECT_LEARNINGS.md`'s `[refactor-only]` reflex (style-only, no new behavior,
  no RED/GREEN, no synthetic red) -- an owner-approved `PRE-RED->REFACTOR` TDD gate.
  Fixed in 4 checkpoint commits (<=4 files each, `SAFEGUARDS.md` blast-radius limit):
  `9883494f` (5 line-length-only files), `f0d0c75c` (4 files, paste/regex/wrap fixes),
  `1957a65b` (4 marker-genetics files + a new `.lintr` per-line exclusion),
  `23688365` (final 3 files).
- **Two `lintr`-heuristic false-positive classes found and corrected, not just
  fixed:** (1) `nonportable_path_linter` hits on `R/makePedigreeDiagramData.R:47,695`
  were NOT from the iCloud duplicate files as `BACKLOG.md`'s S462 entry claimed
  (never verified against the actual lines) -- both are in the real, tracked file,
  and are themselves false positives on a plain fallback label string
  (`"Other / Unrecorded"`) that merely contains `/`, not a path. (2) 4
  `commented_code_linter` hits (`R/reportGV.R:195`, `R/makePedigreeDiagramData.R:42`,
  `R/modGeneticValue.R:194,328`) were live design-rationale comments (issues
  #125/#127/#132) that embed a real R expression in prose, not dead code -- would
  have destroyed real documentation if deleted. All 6 suppressed via documented
  `# nolint` blocks. One line (`R/markerKinship.R:17`, the published KING-robust
  `\deqn{}` formula, Manichaikul et al. 2010) was deliberately left over 80 chars
  rather than risk corrupting a citation-critical formula for a cosmetic gain --
  suppressed via a new `.lintr` per-line exclusion instead.
- **Verification:** `lintr::lint_package()` 0 warnings on all 16 tracked files
  (after each batch and at the end); full regression suite 0 failed/0 error,
  10 pre-existing unrelated warnings (exact S465 baseline match) after every batch;
  `devtools::check()` exact baseline (1 pre-existing WARNING = iCloud duplicate
  filenames, 2 pre-existing NOTEs = vignette-engine + the already-filed
  spelling-drift item, 0 new). `devtools::document()` run after batches 3 and 4;
  the 3 known iCloud-duplicate-corrupted `.Rd` files (`appServer.Rd`,
  `modMarkerGeneticsServer.Rd`, `modMarkerGeneticsUI.Rd`) reverted each time
  (Learning 454); 4 legitimate `.Rd` regenerations kept and diffed (pure reflow,
  no content loss, the `\deqn{}` formula untouched). Live `shinytest2` smoke test
  (Phase 3E, required -- 4 touched files back live Shiny UI): installed the package,
  drove the real app across all 4 touched-module tabs (Genetic Value Analysis,
  Marker Genetics, Breeding Groups, Pedigree Browser); 0 `shiny-output-error` DOM
  elements, 0 SEVERE console log entries (44 total); confirmed the `numericInput`
  cutoff values and the `fileInput` `accept` attribute render byte-identical to
  pre-edit behavior.
- **`BACKLOG.md`:** the lint-cleanup item's part (a) marked DONE; part (b) (a
  process fix so lint debt stops re-accumulating -- CI gate and/or a close-out
  check) split into its own open item, not done this session. Issue #142 Slice 2's
  gate marked satisfied. See `PROJECT_LEARNINGS.md` Learning 461.

### 2026-08-03 · [ad hoc] Owner-directed sequencing: gate issue #142 completion on the accumulated lint cleanup (post-S465)
- **Decision:** owner directed (in response to a `lintr::lint_package()` observation) that
  the "Accumulated `lintr::lint_package()` warnings, 45 total across 17 files" `BACKLOG.md`
  item (found S462) must be completed **before** the pedigree drawing feature (issue #142)
  is considered complete and pushed -- not deferred until after. `BACKLOG.md` updated with
  cross-referenced notes on both the lint-cleanup item and the issue #142 Slice 2 item.
  No code changed; confirmed the current lint count (still 45, same breakdown as S462) and
  that none of it originates from Session 465's own new code.

### 2026-08-03 · [issue #142] Implement Slice 1: internal `.addRectilinearWaypoints()` helper (Session 465)
- **Deliverable:** new internal `.addRectilinearWaypoints(nodes, edges, forest, pos)`
  in `R/makePedigreeDiagramData.R`, implementing the ratified design's D1 (sibship-bar
  waypoint chain, generalizing to D5 single-known-parent groups) and D2 (per-side
  mate-line dogleg for mismatched-generation parents -- correctly resolves the
  non-anchor side's duplicate node when one exists, and does not assume the anchor is
  always the on-row parent). D5: a pure post-processing step -- no change to
  `.buildMatingUnitForest()`/`.positionMatingUnitForest()`, and no call site yet
  (`makePedigreeMatingLayout()`'s own default "direct" behavior is unaffected). Extends
  `.buildMatingUnitForest()`'s reserved-id-prefix guard to `__drop_`/`__bar_`/`__proj_`
  (D3).
- **Pre-RED finding, corrected before RED:** live-verification (a minimal `visNetwork`
  widget matching `R/modPedigree.R`'s exact render chain, driven via `shinytest2`/
  `chromote`) found the ratified design's `hidden = TRUE` waypoint mechanism does not
  work -- vis.js suppresses every edge connected to a hidden node regardless of the
  edge's own setting. Corrected mechanism (waypoint nodes at `size = 0` + fully
  transparent color; every new waypoint-touching edge given an explicit,
  non-inherited color, since vis.js edges otherwise default to inheriting color from
  their `from` node's border) verified via 8 throwaway POC apps and folded into the
  design doc as a new §11 addendum, owner-approved via `AskUserQuestion` before RED.
- **Verified:** 18 new tests (11 for `.addRectilinearWaypoints()`, 3 for the extended
  reserved-prefix guard, plus 4 already-existing input-validation/style tests
  re-confirmed passing) -- including a real 375-individual bundled-fixture node-count
  re-measurement confirming the design's own analytical estimate exactly (740
  direct-style + 488 D1 + 147 D2 = 1,375, no drift). Full regression suite 0 failed/0
  error (4477 passed = baseline + 71 new, 171 skipped, 10 pre-existing
  `test_modMarkerGenetics.R` warnings, unchanged); `devtools::check()` 0 new
  warnings/notes (confirmed via a stash test that the 1 warning + 2 notes -- the
  iCloud duplicate-file artifact, a pre-existing vignette-engine note, and a
  pre-existing spelling gap from Session 461's own docstring text -- all predate this
  session, unrelated to this diff). REFACTOR: renamed a loop variable (`F` ->
  `fromId`) to clear 7 new `T_and_F_symbol_linter` lint warnings, owner-approved via
  `AskUserQuestion`; no behavior change. Phase 3E: n/a -- no runtime behavior changed
  (the function has no call site yet; UI wiring is Slice 2). See
  `docs/planning/pedigree-diagram-rectilinear-waypoint-design-plan.md` §11,
  `BACKLOG.md`'s updated issue #142 item (Slice 1 DONE, Slice 2 scoped),
  `PROJECT_LEARNINGS.md` Learning 460.

### 2026-08-03 · [issue #142] Design: full rectilinear mate-line/sibship-bar waypoint style, ratified (Session 464)
- **Deliverable:** `docs/planning/pedigree-diagram-rectilinear-waypoint-design-plan.md`
  -- an Architecture-workstream design for issue #142 (deferred at S461's Option 2
  Slice 3), picked up via the S463 close-out `AskUserQuestion` picker. Designs D1
  (a generalized sibship-bar waypoint chain, sort-and-chain, generalizing to both
  mating-unit and D5 single-known-parent origins), D2 (a per-side mate-line dogleg
  for mismatched-generation parents -- measured 62% of real mating units need this,
  the majority case, not an edge case), D3 (3 new reserved node-id prefixes, full D6
  re-adaptation including a newly-found `highlightNearest` hover-highlight
  regression risk), D4 (an opt-in "Rectilinear" toggle defaulting to today's shipped
  "Direct" style), D5 (pure post-processing, no change to
  `.buildMatingUnitForest()`/`.positionMatingUnitForest()`). All quantitative claims
  measured directly against `inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`
  via the real, already-shipped algorithm (not estimated): 237 mating units, 147
  (62%) generation-mismatched, total rendered nodes would roughly triple per
  individual (3.67x) under the new style -- flagged as the design's single most
  consequential open number, with a suggested (not final) rectilinear-mode
  individual cap of ~380, to be re-confirmed once implemented.
- **Adversarial review (this session, before ratification):** a 3-lens Workflow
  (data-structure correctness, D6/render-chain integration, arithmetic
  reproduction) independently re-derived the design's claims against the real
  source and real fixture, catching and fixing before presentation: a real
  correctness gap in D2 (which node's `x`/`gen` to use when the non-anchor side is
  a duplicate, affecting 57/96 real cases), the `highlightNearest` regression risk
  above, a false claim about which function a vignette demos, an arithmetic
  rounding overstatement (~400 corrected to ~380), and 2 minor prose/count fixes.
  See `PROJECT_LEARNINGS.md` Learning 459.
- **Ratified via `AskUserQuestion`** (Proceed as written, D1-D5) -- no D-decision
  revisited. Implementation is separate follow-up work, not done this session;
  filed to `BACKLOG.md` and commented on issue #142
  (<https://github.com/rmsharp/nprcgenekeepr/issues/142#issuecomment-5169351526>).
  No `R/` or `tests/` files touched -- docs-only, TDD RED/GREEN/REFACTOR gates did
  not apply (S448/S451/S452/S453/S457/S458 precedent for planning/design sessions).

### 2026-08-03 · [issue #142] Research: reproduce kinship2's reference pedigree drawings with nprcgenekeepr's own rendering, for the pending #142 decision (Session 463)
- **Deliverable:** `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`
  -- owner-directed, after seeing the live Diagram tab and comparing it against
  <https://rpubs.com/dliupress/pedigreedemo>: "create a Quarto document that
  duplicates the drawings...using nprcgenekeepr's pedigree drawing capability."
  Reproduces the reference page's 3 example pedigrees (kinship2's own
  `sample.ped` families 1 and 2, plus a 16-person genotype-annotated pedigree,
  all fetched/transcribed from the reference page's own S3-hosted static HTML
  and verified against its embedded plot images) using identical underlying
  data, rendered via `kinship2::plot.pedigree()` (the reference) directly
  alongside `nprcgenekeepr`'s own current `makePedigreeMatingLayout()` +
  `visNetwork` (`R/modPedigree.R`'s exact current render chain). No package
  code changed; no decision made on issue #142 -- this is decision-support
  material only.
- **Findings (factual, not prescriptive):** confirms the owner's observation --
  kinship2 draws mates with a horizontal line at their shared row, then a
  vertical drop from its midpoint to a horizontal sibship bar, then vertical
  drops to each child (strict right angles); `nprcgenekeepr` currently draws
  straight diagonal edges from each parent to a small mating-unit node, and
  from that node to each child. Also surfaced two related, previously-unnoticed
  differences in the duplicate-individual mechanism: (1) `nprcgenekeepr` only
  duplicates an individual with multiple mating units of their own, while
  kinship2 also duplicates for pure layout/crossing-minimization reasons (a
  single-mate individual whose birth family is far from their marital family)
  -- confirmed empirically: kinship2's own family-1 render duplicates 2
  single-mate individuals (`103`, `138`) that `nprcgenekeepr`'s algorithm does
  not duplicate at all (0 duplicates, verified via `makePedigreeMatingLayout()`
  output); (2) for a genuine multi-mate individual, kinship2 draws them ONCE
  with two mate-lines, while `nprcgenekeepr` duplicates them (one occurrence
  per mating unit) -- confirmed on the 16-person genotype example (individual
  `2`, mates `3` and `10`).
- **Confirmed a genuine positioning defect, independent of the #142 styling
  question, in response to a mid-session owner observation** ("it appears 2
  males have mated") on the family-2 rendering: a founder (no recorded
  parents) who mates with someone from a LATER generation is placed at their
  OWN generation row by `.positionMatingUnitForest()`, not near their actual
  mate -- and can land visually inside an unrelated couple's own mate-line,
  making the diagram appear to show the wrong pairing. Confirmed via the
  actual node/edge coordinates (not impression) in BOTH example families:
  `203`x`204` (family 2) and `117`x`116` (family 1) each show the marry-in
  founder positioned between an unrelated couple's parent node and their own
  mate-connector node. This is a defect in x/y coordinate ASSIGNMENT, not in
  edge-drawing style, so it would persist even under a full #142
  implementation -- flagged prominently in the document as its own,
  separate, not-yet-fixed finding, not folded into the #142 question. Also
  clarified (not a defect): every node renders with the same default fill
  color since `nprcgenekeepr`'s diagram has no affected-status encoding at
  all (issue #133) -- confirmed via source (`grep -c "color" R/makePedigreeDiagramData.R`
  found zero matches).
- **`kinship2` installed via `renv::install()`** into this project's local renv
  library only, for this one-off reference comparison -- NOT added to
  `DESCRIPTION`, NOT snapshotted into `renv.lock` (confirmed `renv.lock`
  unchanged by the install). Reference material, not a dependency.
- **Verified:** `quarto render` succeeds with 0 errors; one transcription typo
  in the 16-person genotype example (individual 11's sex code) caught via a
  real `kinship2::pedigree()` validation error ("Id not female, but is a
  mother: 11") and fixed before the final render; the corrected render's
  kinship2 plots were visually compared pixel-for-pixel against the reference
  page's own embedded images and match exactly. `runtime_smoke: n/a --
  research document, no R/ or tests/ files changed`.

### 2026-08-03 · [ad hoc] Owner-directed housekeeping: audit accumulated lint debt and diagnose a scheduled-CI E2E test failure, both filed to BACKLOG.md (Session 462)
- **Lint debt:** ran `lintr::lint_package()` -- 45 warnings across 17 files (heaviest:
  `R/modMarkerGenetics.R` 6, `R/makePedigreeDiagramData.R` 5, `R/markerHeterozygosity.R` 5),
  concentrated in the issue #130 marker-genetics family (Sessions 442-447). Filed to
  `BACKLOG.md` Housekeeping as two distinct asks: a cleanup pass, and a process fix (CI gate
  and/or close-out checklist) so the debt stops re-accumulating. No code changed.
- **CI failure:** investigated
  [run 30796362515](https://github.com/rmsharp/nprcgenekeepr/actions/runs/30796362515)
  (scheduled `shinytest2` workflow, not a push) -- 2 of 251 E2E assertions failed in
  `test-e2e-pedigree-module.R:205,207`. Root cause fully diagnosed: the test asserts the
  pre-Option-2 direct sire/dam -> child edge convention, made stale by Session 461's Slice 3
  edge-routing change (edges now route through an intermediate `__union_*` node). Filed to
  `BACKLOG.md` Housekeeping with the exact fix needed; not fixed this session (diagnosis
  only, per the owner's request).

### 2026-08-03 · [ad hoc] Fix vignettes/a2interactive.Rmd's stale "Pedigree Diagram" demo section to match the shipped Option 2 render chain (Session 462)
- **Deliverable:** owner-flagged (via a screenshot of the tutorial's rendered diagram still
  showing the pre-Option-2 crossing-line style) that `vignettes/a2interactive.Rmd`'s
  "Pedigree Diagram" section (added Session 456, before the Option 2 work) still called the
  superseded `makePedigreeDiagramData()` + `visNetwork::visHierarchicalLayout()` combination,
  and its own prose claim ("reproduces the Diagram tab's rendering exactly") had gone false
  the moment Session 461's Slice 3 switched `R/modPedigree.R`'s render chain to
  `makePedigreeMatingLayout()` + fixed-position layout. Session 461's own tutorial/article
  documentation checklist pass updated `_pedigree_browser.Rmd` and `colony-manager-guide.qmd`
  but missed this pre-existing a2interactive.Rmd section.
- **Fix:** rewrote the section's intro prose, the demo-pedigree explanatory text, the
  data-generation call (`makePedigreeMatingLayout(demoPed)` in place of
  `makePedigreeDiagramData(demoPed)`), the return-contract description (3-element
  `list(nodes, edges, duplicateToReal)`, not 2), and the render chunk
  (`visPhysics(enabled = FALSE)`/`visNodes(physics = FALSE)`/`visEdges(smooth = FALSE)` in
  place of `visHierarchicalLayout()`; `visOptions()`'s search dropdown filtered to
  real-animal ids only, matching `R/modPedigree.R`'s own current filter). Verified the
  actual node/edge counts empirically (via `Rscript`) rather than guessing: the existing
  demo pedigree's own multi-mate founders (`M1`, `F2`) already exercise the duplicate-node
  convention (48 nodes: 33 real + 13 mating-unit + 2 duplicate; 53 edges, 2 dashed), so no
  fixture change was needed.
- **Verified:** `rmarkdown::render()` on the vignette succeeds with no errors, produces the
  expected `names(diagramData)`/`nrow()` output inline, and the rendered widget JSON
  confirms `physics:false` and exactly 2 `dashes:true` edges. `devtools::check()` re-run:
  0 errors, 1 pre-existing warning (iCloud duplicate-file artifact), 1 pre-existing note
  (this same vignette's own missing `VignetteBuilder` engine, unrelated to this diff) --
  exact baseline match, 0 new. Docs-only (no `R/` or `tests/` files changed), so per the
  issue #124/#139 precedent the TDD RED/GREEN/REFACTOR gates did not apply;
  `runtime_smoke: n/a — docs-only`.
- **Incidental, reverted (not a deliverable):** found 3 `man/*.Rd` files corrupted
  mid-session by the well-known iCloud duplicate-`.R`-file `devtools::document()` artifact
  (Learning 454) -- this time triggered by the owner's own local package rebuild, not this
  session's tool calls. Reverted via `git checkout --` before any commit.

### 2026-08-02 · [issue #142] File "add a full rectilinear mate-line/sibship-bar waypoint style" as a deliberately-unscheduled, additive follow-up (Session 461, same-conversation follow-up)
- **Deliverable:** [issue #142](https://github.com/rmsharp/nprcgenekeepr/issues/142), owner-directed
  via `AskUserQuestion` after a clarifying exchange (owner asked whether picking direct edges now
  would preclude adding the fuller rectilinear style later -- confirmed it would not, since a
  waypoint-based upgrade reuses Slice 1/2's already-computed positions rather than requiring rework).
  Tracks building S457's original Case C2 proof-of-concept's true right-angle mate-line/sibship-bar
  convention (extra invisible waypoint nodes) as an additive follow-up, most likely behind a
  diagram-style toggle -- not a bug, not scheduled, filed only so the fuller style has a place to
  land if there's real demand. Cross-referenced back into the design doc §9.

### 2026-08-02 · [BL-pedigreeOption2Slice3] Pedigree Diagram Option 2 implementation Slice 3 -- render-chain wiring, `makePedigreeMatingLayout()` (D6), plus a live-verification-discovered dangling-parent-reference crash fix in Slice 1's own code (Session 461)
- **Deliverable:** new exported `makePedigreeMatingLayout(ped)` in `R/makePedigreeDiagramData.R`,
  the third and final implementation slice of
  `docs/planning/pedigree-diagram-option2-layout-design-plan.md`'s §6 Migration Path -- combines
  Slice 1's `.buildMatingUnitForest()` and Slice 2's `.positionMatingUnitForest()` into the
  `list(nodes, edges, duplicateToReal)` shape `R/modPedigree.R`'s Diagram tab now renders.
  `R/modPedigree.R`'s render chain switched from `makePedigreeDiagramData()` +
  `visHierarchicalLayout()` to the new function + `visPhysics(enabled = FALSE)` +
  `visNodes(physics = FALSE)` + `visEdges(smooth = FALSE)` with fixed x/y (S457's proven Case C2
  geometry). Full TDD cycle (RED->GREEN, REFACTOR owner-confirmed skip), all `AskUserQuestion`-gated.
- **Pre-RED POC + 2 owner decisions:** a throwaway `chromote` POC against the real `GA204Z`/`8LKBV9`
  loop fixture and a wide fan-out fixture resolved (empirically, not by guessing) x/y scale constants,
  union-node style (small unlabeled dot, no legend entry), duplicate-node style (identical
  shape/label to the real individual, dashed connector), and a gap the ratified D1-D6 text left
  unspecified: whether to render §1.1's "right-angle mate-line/sibship-bar" language literally
  (new, unratified waypoint-node machinery) or as direct parent-union-child edges. Surfaced via
  `AskUserQuestion`: (1) issue #138's node-count cap re-derived to **750 individuals** (owner-picked,
  matching the design doc's own suggested resolution, over the tension with the documented-but-
  never-diagram-rendered 962-individual `colony-manager-guide.qmd` example); (2) mate-line edges
  render directly (no waypoints) with the fuller rectilinear style filed as deferred issue #142.
- **D6 integration:** click-to-navigate resolves a duplicate-node click to its real individual (via
  the new `duplicateToReal` lookup) and treats a union-node click as a no-op; the search dropdown is
  filtered to real individual ids only (`visOptions(nodesIdSelection = list(values = ...))`,
  resolving a question S458's design doc left open); union nodes get a minimal offspring-count
  tooltip and no legend entry; duplicate nodes repeat their real individual's tooltip content plus a
  duplicate-occurrence cue.
- **Live-verification-discovered defect, fixed at its root cause (not worked around):** Phase 3E
  (mandatory, not skippable for this slice) found `.buildMatingUnitForest()` crashed ("missing value
  where TRUE/FALSE needed") whenever a mating unit's non-anchor parent had no own row in the input --
  the ordinary case for `R/modPedigree.R`'s own pre-existing "Trim pedigree based on focal animals"
  feature (`trimPedigree(..., addBackParents = FALSE)`, unrelated to and pre-dating Option 2), which
  keeps a blood relative's row but not that relative's own mate's row. Slices 1/2 never exercised
  this path (both `@noRd`, tested only against self-contained fixtures); Slice 3 wiring the code into
  the live render chain for the first time is what surfaced it. Fixed in Slice 1's own file: a
  dangling reference is now treated as a founder and made structurally ineligible to become an
  anchor (there is no individual to recursively position for them); a dangling free-pass/duplicate
  node's `gen` falls back to its own mating unit's already-computed `gen`; a dangling individual gets
  no rendered node of their own. 6 new unit tests (`test_buildMatingUnitForest.R`,
  `test_positionMatingUnitForest.R`) reproducing the exact crash; the live crash scenario re-verified
  fixed via `shinytest2`/`chromote` after the fix.
- **Also found, documented (not fixed -- inherited from Slice 2's already-shipped algorithm):**
  `.buildMatingUnitForest()`'s D2 anchor tie-break is row-order-sensitive, and the live app's
  `qcStudbook()` step (pre-existing, pre-dating Option 2) reorders rows relative to the raw upload --
  so the real fixture's own "740 total nodes" figure (Slices 1/2's own unit tests, raw CSV) becomes
  739 through the live pipeline. Both are correct, self-consistent applications of the same
  deterministic algorithm to different, equally valid row orderings.
- **Verified:** full regression suite 0 failed/0 error (4405 passed = 4382 baseline + 22 new + 1
  fixed-by-lookup, 171 skipped, 10 pre-existing warnings, exact baseline match); `devtools::check()`
  exact baseline match (1 pre-existing warning -- iCloud duplicate-file artifact; 1 pre-existing note
  -- `a2interactive.Rmd` vignette-engine; 0 new); zero new lint warnings in changed code. Phase 3E
  (live `shinytest2`/`chromote` against the real installed app + real 375-individual fixture, run
  twice): physics disabled, union/duplicate styling, dashed connectors, filtered search dropdown,
  click-to-navigate (both cases), zero console errors, legible screenshotted renders for the
  `GA204Z`/`8LKBV9` loop, a trimmed focal-animal view, and the full 375-individual colony scale.
- **Incidentally found and reverted (not part of this slice's own deliverable):**
  `devtools::document()` picked up 2 long-carried-forward, untracked iCloud "conflicted copy"
  duplicate `.R` files and corrupted 3 unrelated `.Rd` pages (`man/appServer.Rd`,
  `man/modMarkerGeneticsServer.Rd`, `man/modMarkerGeneticsUI.Rd`) with merged/stale content, twice
  (once per `devtools::document()` run this session) -- each caught via `git status`/`git diff`
  review and reverted via `git checkout --` before it could reach a commit. New Housekeeping items
  filed in `BACKLOG.md` for this and for the now-stale `colony-manager-guide.qmd` screenshot.
- **Documentation checklists:** `NEWS.Rmd`/`NEWS.md` new bullets (the new export + the Diagram tab's
  new mating-aware visual convention + the 750 cap);
  `vignettes/manual_components/_pedigree_browser.Rmd`'s Diagram paragraph rewritten for the new
  convention (tutorial/article checklist); `vignettes/articles/colony-manager-guide.qmd`'s "1,500"
  corrected to "750" (its screenshot itself deferred as a new Housekeeping item, disproportionate to
  fix same-session). `_pkgdown.yml` reference config updated for the new export. `BACKLOG.md` Slice 3
  marked DONE; `PROJECT_LEARNINGS.md` Learnings 454-457 (plus a Learning 450 third-recurrence
  addendum); `CLAUDE.md` Learnings cross-reference count updated (453->457, Sessions
  1-460+->1-461+). Commented on issue #138 documenting the cap re-derivation (not closed -- #138 is
  about supporting rendering *beyond* the cap, a separate feature).

### 2026-08-02 · [BL-pedigreeOption2Slice2] Pedigree Diagram Option 2 implementation Slice 2 -- `.positionMatingUnitForest()` (D3 contour-merge positioning + D4 founder ordering + D5 direct-child positioning) (Session 460)
- **Deliverable:** new internal `.positionMatingUnitForest(ped, forest)` in
  `R/makePedigreeDiagramData.R`, the second implementation slice of
  `docs/planning/pedigree-diagram-option2-layout-design-plan.md`'s §6 Migration Path step 1 --
  consumes Slice 1's `.buildMatingUnitForest()` output and assigns final `x`/`gen` coordinates via
  a simplified Reingold-Tilford/Walker-style recursive contour-merge (D3), founder ordering by
  input row order (D4), and D5's one-known-parent fallback attaching directly. Full TDD cycle
  (RED->GREEN, REFACTOR owner-confirmed skip), all `AskUserQuestion`-gated. Resolved Slice 1's own
  deferred question: `duplicates` needs no `gen` column of its own -- the positioning function
  takes `ped` directly and looks up a duplicate's `gen` via its `realId`.
- **Pre-RED POC finding, 3 gaps the ratified design's own text did not fully specify:** prototyped
  the algorithm in a throwaway script against 8 toy fixtures plus the full real 375-individual
  bundled fixture before writing any test (matching S457's own Case-C2-POC precedent, per §9's
  dragon flag) and found (1) an individual whose one non-anchor mating-unit occurrence is "free"
  (no duplicate node, per `.buildMatingUnitForest()`'s own D2 rule) is not an independent forest
  root -- naive treatment created a phantom disconnected node; fixed by folding them into their one
  unit's children-merge as a genuine width-reserving leaf; (2) contour occupancy must be indexed by
  each node's absolute real `gen`, not relative recursive depth, since D3 step 6 pins y to real
  `gen`, which diverges from recursive depth once a duplicate/free-pass node is re-attached deep
  inside another individual's subtree (impossible in a genuine tree, possible here -- a first
  depth-indexed implementation let two unrelated founders collide); (3) even gen-indexed contours
  leave a residual ancestor-vs-nested-descendant exact-coincidence edge case (12/740 nodes, ~1.6%,
  on the real fixture), resolved with a small deterministic post-placement nudge applied only to
  individual/union nodes (duplicates keep the design's own already-accepted "not guaranteed
  collision-free" trade-off). All 3 findings owner-approved via `AskUserQuestion` before RED.
  Added a "Resolved S460" note to the design doc's own §9 dragon flag. New `PROJECT_LEARNINGS.md`
  Learnings 451-453.
- **Tests:** 12 new `test_that()` blocks in `tests/testthat/test_positionMatingUnitForest.R` --
  input validation; trio union-midpoint geometry; D5-mixed subtree; multi-mate uneven-depth
  subtrees; the real `GA204Z`/`8LKBV9` loop fixture; half-sib convergent loop; an isolated founder
  beside an unrelated family; an 8-mate wide fan-out; a deeply unbalanced 6-generation chain; the
  full real 375-individual fixture at its exact 740-node count with zero overlap and no `NA`
  x/gen; `gen`-column semantics cross-checked against each node's source of truth.
- **Verified:** regression suite 0 failed/0 error (3592 passed = 3562 baseline + 30 new, 183
  skipped, 10 pre-existing warnings, exact baseline match); `devtools::check()` introduces 0 new
  warnings/notes -- exact match to the known baseline (1 pre-existing iCloud-duplicate-file
  warning, 1 pre-existing `a2interactive.Rmd` vignette-engine NOTE); zero lint warnings in the new
  code. Phase 3E: n/a -- no runtime behavior changed (the function has no call site yet; the
  render-chain switch is Slice 3). Citation/tutorial/`NEWS.Rmd` checklists: n/a -- an internal
  (`@noRd`), not-yet-wired-in function has no displayed statistic and no user-facing surface.
- **Incidental fix (not this slice's own deliverable, a 1-byte mechanical correction in a file
  already being edited this session):** `PROJECT_LEARNINGS.md` Learning 450's own text -- which
  describes a literal control-character byte silently corrupting an `Edit` call -- itself
  contained that exact literal byte, recursed into its own bug report. Replaced with the literal
  text `\u0001` (the real source separator it was always meant to describe), verified via
  `grep -c $'\x01'` returning 0. See `BACKLOG.md` (Slice 2 marked DONE; Slice 3 filed).

### 2026-08-02 · [BL-pedigreeOption2Slice1] Pedigree Diagram Option 2 implementation Slice 1 -- `.buildMatingUnitForest()` (D1 mating-unit transformation + D2 anchor selection + D5 partial-parentage fallback) (Session 459)
- **Deliverable:** new internal `.buildMatingUnitForest()` in `R/makePedigreeDiagramData.R`, the
  first implementation slice of `docs/planning/pedigree-diagram-option2-layout-design-plan.md`'s
  §6 Migration Path step 1 -- the CraneFoot-style mating-unit/individual-duplication transformation
  (D1), deterministic anchor selection (D2), and the D5 partial-parentage fallback (folded into
  this one function, since D5 governs whether a mating unit is even synthesized for a given
  child). Full TDD cycle (RED->GREEN, REFACTOR owner-confirmed skip), all `AskUserQuestion`-gated.
- **Pre-RED finding, corrected in the ratified design doc itself:** actually implementing and
  running D2's anchor rule against the real 375-individual bundled fixture
  (`inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`) found it collides twice -- `KUENM8` and
  `IM1B5T` each anchor 2 mating units, the exact "rare case" D3 step 2 already names as legitimate
  -- which the design doc's own §7 combinatorial estimate (130 duplicates / 742 total nodes,
  computed by reasoning about the algorithm rather than running it) could not have anticipated.
  Corrected §7 and §9 in place, owner-directed via `AskUserQuestion`, to the verified 128
  duplicates / 740 total nodes. New `PROJECT_LEARNINGS.md` Learning 449.
- **Tests:** 15 new `test_that()` blocks in `tests/testthat/test_buildMatingUnitForest.R` -- input
  validation and reserved `__union_`/`__dup_` id-prefix collision; the D5 0-parent/1-parent
  fallbacks; D2's founder/mate-count/id-sort tie-breaks; a reconstructed real 8-node
  `GA204Z`/`8LKBV9` loop fixture extracted directly from the bundled E2E CSV (the original 6-node
  half-sib fixture cited in the design doc's §8 was never committed to the test suite -- S453 was
  audit-only); a reconstructed equivalent half-sib-mating convergent-loop fixture; and the real
  anchor-collision case verified end-to-end against the full bundled fixture (237 mating units,
  128 duplicates, `KUENM8`/`IM1B5T` each anchoring exactly 2).
- **Verified:** regression suite 0 failed/0 error (3562 passed = 3509 baseline + 53 new, 183
  skipped, 10 pre-existing warnings, exact baseline match); `devtools::check()` introduces 0 new
  warnings/notes -- isolated via a clean-tree re-run confirming the pre-existing iCloud-duplicate-
  file warning and a `vignettes/a2interactive.Rmd` vignette-engine NOTE both predate this session,
  unrelated to this diff. Phase 3E: n/a -- no runtime behavior changed (the function has no call
  site yet; the render-chain switch is Slice 3). Citation/tutorial/`NEWS.Rmd` checklists: n/a --
  an internal (`@noRd`), not-yet-wired-in function has no displayed statistic and no user-facing
  surface.
- **Gotcha hit and recorded:** a large `Edit` call's `new_string` landed a literal control-character
  byte instead of the intended empty-string separator, causing later exact-string `Edit` calls to
  silently fail with "string not found" despite visually-identical text -- diagnosed via `cat -A`.
  New `PROJECT_LEARNINGS.md` Learning 450. See `BACKLOG.md` (Slice 1 marked DONE; Slice 2 filed).

### 2026-08-02 · [issue #141] File "upgrade D3 to Buchheim-Jünger-Leipert if profiling shows a need" as a deliberately-unscheduled issue (Session 458, same-conversation follow-up)
- **Deliverable:** [issue #141](https://github.com/rmsharp/nprcgenekeepr/issues/141), owner-directed
  after this session's own close-out: formalize
  `docs/planning/pedigree-diagram-option2-layout-design-plan.md` §3 D3/§9's deferred
  Buchheim-Jünger-Leipert optimization as a tracked GitHub issue, explicitly labeled so it is not
  picked up speculatively.
- Created a new repository label, `premature optimization` (description: "Deferred until
  profiling/evidence shows the need is real -- do not implement speculatively"), since no existing
  label captured this evidence-gated-deferral semantics (`low priority` is priority-based, not
  condition-based). Filed the issue with both `enhancement` and `premature optimization` labels,
  naming the specific triggering condition (profiling at the node-count ceiling, or a real
  pathological-shape colony pedigree, showing quadratic degradation) that would justify picking it
  up, and the D-decisions it does NOT affect (D1/D2/D4/D5/D6 are independent of which
  tree-positioning algorithm runs after D1's transformation).
- Cross-referenced issue #141 back into the design doc at both citing locations (§3 D3, §9 dragons)
  so a future reader following either path finds the tracked issue rather than a dead-end mention.

### 2026-08-02 · [ad hoc] Pedigree Diagram Option 2 layout design -- crossing-minimization, multi-mate/half-sib representation, loop-safety, ratified as written (Session 458)
- **Deliverable:** `docs/planning/pedigree-diagram-option2-layout-design-plan.md` (Architecture
  workstream) -- the dedicated follow-up design session `docs/planning/
  pedigree-diagram-mating-lines-plan.md` §3/§7 named as Option 2's required next step: design (a)
  a crossing-minimization node-ordering algorithm, (b) multi-mate/half-sib fan-out representation,
  and (c) a loop-safety re-verification approach.
- **Key finding:** (b) and (c) are the same structural problem -- an individual belonging to more
  than one mating unit. A real bundled fixture (`inst/extdata/examples/
  obfuscated_rhesus_mhc_ped.csv`) confirmed this empirically: `8LKBV9`, issue #134's own
  consanguineous-loop verification individual, is independently confirmed this session to also be
  a 3-distinct-mate individual.
- **Decision (D1-D6):** a CraneFoot-style mating-unit/individual-duplication transformation
  (resolves crossing-minimization, multi-mate representation, and loop-safety via one mechanism),
  a deterministic anchor-selection rule (explicitly not kinship2's uncapped factorial founder-order
  search), a simplified Reingold-Tilford/Walker-style tree-positioning algorithm (not kinship2's
  undocumented internals, not full Buchheim-Jünger-Leipert, not an off-the-shelf R package),
  founder ordering by data row order, a partial-parentage fallback, and integration adaptations for
  the 4 already-shipped Diagram-tab features.
- **Research:** downloaded the real kinship2 1.9.6.2 source from CRAN (after a system-installed-
  copy/renv R-version mismatch segfaulted `library(kinship2)`, new `PROJECT_LEARNINGS.md` Learning
  447) and ran a 2-agent parallel `Workflow` at `effort: max` reading kinship2's actual
  `align.pedigree`/`alignped1-4`/`besthint`/`autohint` source plus a general crossing-minimization
  literature survey (Sugiyama/barycenter/median heuristics, Reingold-Tilford/Walker/
  Buchheim-Jünger-Leipert, CraneFoot's duplicate transformation, re-reading the Mäkinen et al. 2005
  PDF in full). A license-transitivity check (new Learning 448) found no off-the-shelf R
  tree-layout package avoids a GPL dependency (`igraph`/`data.tree` are GPL; `ggraph` is MIT but
  hard-`Imports` GPL `igraph`), consistent with this project's D2 MIT-only precedent.
- **Impact:** the transformation nearly doubles node count on real data (375 individuals -> 742
  total nodes for the bundled E2E fixture) -- issue #138's 1,500-node cap must be re-measured under
  the new model, flagged as a "here be dragons" risk since nothing will visibly break if this is
  skipped.
- **Ratified** via `AskUserQuestion` -- owner selected "proceed as written" with one editorial
  direction applied in the same turn: non-human-centric terminology throughout
  (`sire`/`dam`/`mate`/`mating`, not `husband`/`wife`/`marriage`/`spouse`), applied via 5 targeted
  edits (kinship2's own literal `spouselist` variable name preserved verbatim as a source
  citation). `BACKLOG.md` updated: design item marked DONE, new READY Slice 1 implementation
  follow-up filed (`.buildMatingUnitForest()`, D1+D2). Full regression suite run as a no-drift
  sanity check (0 failed/0 error, 3509 passed, 183 skipped, 10 pre-existing warnings, exact
  baseline match) even though no `R/`/`tests/` files were touched. Planning-only, TDD gates did not
  apply.

### 2026-08-02 · [ad hoc] Pedigree Diagram mating-line/sibship-line feasibility plan, ratified Option 2 (Session 457)
- **Deliverable:** `docs/planning/pedigree-diagram-mating-lines-plan.md` (Architecture workstream)
  answering the BACKLOG item S456 filed: is a kinship2-style mating-line/sibship-line convention
  achievable inside the ratified visNetwork (D2) decision, or does D2 need reopening?
- Read `R/makePedigreeDiagramData.R`/`R/modPedigree.R:387-468` in full (current: one edge per
  known parent, no union-node concept, `visHierarchicalLayout()` with no manual coordinates).
  Read the original D2 ratification text and found it had already explicitly named and accepted
  this exact tradeoff at ratification time.
- Owner supplied 2 reference papers mid-session (Mäkinen et al. 2005 CraneFoot; Fuchsberger et al.
  2008 PedVizApi) via `inst/extdata/reference/` (investigated before use, used as research input,
  deliberately not committed — copyright). Ran a 3-agent parallel research `Workflow`
  (implementation inventory; the owner's 2 cited kinship2 URLs; vis.js's actual capabilities).
- Built and `chromote`-screenshotted 3 empirical `visNetwork` proof-of-concept widgets, confirming
  the technique **is** achievable (a hand-computed-coordinate union-node + sibship-bar-waypoint
  approach produces true right-angle lines) but requires abandoning `visHierarchicalLayout()`
  entirely — cross-verified directly against the bundled `vis-network.min.js` source (no
  orthogonal edge-routing primitive exists; hierarchical layout cannot pin a node's free-axis
  position). Corrected an imprecise "Finding #8" citation in the originating BACKLOG item.
- Presented 4 options (reopen D2 — not recommended; full parity; a smaller partial
  `visNetworkProxy`-based step; decline) with an Impact Analysis table. Owner ratified **Option 2
  (full kinship2-parity layout on visNetwork)** via `AskUserQuestion`. Filed the concrete next
  step (a dedicated Option 2 design planning session) in `BACKLOG.md`.
- No implementation this session, per `SESSION_RUNNER.md`'s planning/implementation boundary.
  New `PROJECT_LEARNINGS.md` Learning 446. Verified: full regression suite exact baseline match
  (0 failed/0 error, 3509 passed, 183 skipped, 10 pre-existing warnings) as a no-drift sanity
  check, even though no `R/`/`tests/` files were touched.

### 2026-08-02 · [ad hoc] File BACKLOG.md item: Pedigree Diagram lacks kinship2-style mating/sibship lines (Session 456 close-out)
- **Deliverable:** owner review of the shipped Diagram section noted the underlying Diagram tab
  itself (`R/modPedigree.R`, `R/makePedigreeDiagramData.R`) -- not just the vignette demo --
  draws directly-sloped parent-to-child `visNetwork` edges with no horizontal mating line
  connecting two co-parents and no sibship line, unlike kinship2-style pedigree-chart convention
  (two reference examples cited: epilepsygenetics.blog's kinship2 post, an RPubs kinship2 demo).
  This touches the ratified D2 (visNetwork) technology decision from
  `docs/planning/issue129-pedigree-diagram-tree-visualization-plan.md`, so per
  `SESSION_RUNNER.md`'s planning-session rules it was filed as a new `BACKLOG.md` item for a
  future dedicated planning session rather than investigated or implemented in this
  documentation session. Related to, but distinct from, the S435 kinship2-comparison audit's
  Finding #8 (scored "Equivalent-different-approach" for the narrower childless-union question,
  left un-actioned) -- this item's visual-clarity framing covers ALL mated pairs, not just
  childless/remarriage unions. No code or vignette changes this entry; `BACKLOG.md` "Pedigree
  diagram vs kinship2 audit follow-ups" section only.

### 2026-08-02 · [ad hoc] Synthesize a small demo pedigree for the Pedigree Diagram section (Session 456 follow-up)
- **Deliverable:** owner review of the just-shipped "Pedigree Diagram" section (below) found the
  reused 704-row `trimmedPed` diagram too large and insufficiently diverse (only the `F`/`M`/`U`
  sex codes occur in the bundled real data) for demonstrating all five node shapes at once.
  Replaced with a synthesized 33-animal, 4-generation pedigree deliberately covering
  `F`/`M`/`H`/`U`/`NA` ("Other/Unrecorded") -- confirmed via `makePedigreeDiagramData()` output
  that all 5 shapes (dot/square/star/triangle/diamond) actually appear at least once. Prose
  flags the pedigree as synthetic (new footnote), explains why `trimmedPed` alone couldn't
  serve, and ties back to the real `trimmedPed`-scale diagram to motivate the search feature.
  Same session, not a new claim/close-out cycle -- direct owner revision of work not yet
  accepted, addressed within the same conversation.
- Verified: `rmarkdown::render()` clean; grepped rendered HTML to confirm the new prose and
  correct inline `nrow(demoPed)`/generation-count substitutions (4 generations, 33 animals).
  Re-ran the live `chromote::ChromoteSession` functional check: Export Diagram (PNG) still
  produces a real PNG (valid magic number), zero console errors. `spelling::spell_check_package()`
  confirmed zero new flagged words (no further `inst/WORDLIST` changes needed). Full regression
  suite unchanged (0 failed/0 error, 3509 passed, same 10 pre-existing warnings). Commit:
  `36fbf3f2`.

### 2026-08-02 · [ad hoc] Add a Pedigree Diagram demonstration section to vignettes/a2interactive.Rmd (Session 456)
- **Deliverable:** owner-directed (free-text task). Fulfills `CLAUDE.md`'s deferred
  `a2interactive.Rmd` script-callable-function checklist for the pedigree-diagram function family
  (issues #129/#131/#132/#135) -- the S450 marker-genetics backfill pass did not cover it, and no
  prior session had. Documentation-only -- no `R/` or `tests/` files changed, so the TDD
  RED/GREEN/REFACTOR gates did not apply (S448/S451/S452/S453/S455 precedent).
- New "Pedigree Diagram" section demonstrating the exported `makePedigreeDiagramData()` piped
  into `visNetwork::visNetwork()` with the same layout/export/legend/search options
  `R/modPedigree.R` uses, reproducing the Shiny app's Diagram tab exactly (minus the
  Shiny-specific click-to-navigate wiring, confirmed by reading `R/modPedigree.R` first).
  Reuses the `trimmedPed` object already built earlier in the tutorial.
- Verified: `rmarkdown::render()` clean; grepped rendered HTML to confirm the new section,
  the live `visNetwork` widget, and the correct inline `nrow(trimmedPed)` substitution are
  present. Live functional check via a bare `chromote::ChromoteSession` (no `shinytest2`
  needed -- the export button is pure client-side JS) against the rendered HTML: clicking
  "Export Diagram (PNG)" produced a real `pedigree_diagram.png` with a valid PNG magic-number
  signature; zero console errors/warnings. `inst/WORDLIST` gained 2 new words
  (`makePedigreeDiagramData`, `diagramData`) in byte-collation order; `spelling::spell_check_package()`
  confirmed the file now contributes zero flagged words. Full regression suite unchanged at
  0 failed/0 error (3509 passed, same 10 pre-existing `test_modMarkerGenetics.R` warnings).
  See `PROJECT_LEARNINGS.md` Learning 445.

### 2026-08-02 · [issue #139] Document the Pedigree Diagram tab in the manual/tutorial (Session 455)
- **Deliverable:** owner-picked via the Phase 0 priorities `AskUserQuestion` from a 2-option list
  (this item, NPRC outreach plan review). Documentation-only -- no `R/` or `tests/` files changed,
  so the TDD RED/GREEN/REFACTOR gates did not apply (S448/S451/S452/S453 precedent for
  non-implementation sessions).
- **Research finding:** issue #139's "zero coverage" premise was partially overtaken by events --
  #131 (S440), #132 (S449), and #135 (S454) each scoped their own doc update to one of the two
  files only, leaving an asymmetric gap: `vignettes/manual_components/_pedigree_browser.Rmd`
  covered 5 of 6 shipped Diagram-tab features but was missing the shape-to-sex legend (#132's own
  feature, documented only in the other file); `vignettes/articles/colony-manager-guide.qmd`
  covered only base rendering + the legend, missing click-to-navigate, the 1,500-node cap, Export
  PNG, hover tooltip, and Select-by-id search/highlight entirely -- versus the Table view's
  9-screenshot depth in the same file. New `PROJECT_LEARNINGS.md` Learning 444 records this as a
  general risk of the checklist's "and/or" flexibility across a feature family shipped
  incrementally over several sessions.
- **Fix:** added the shape-to-sex legend description to `_pedigree_browser.Rmd`'s existing "Data
  Table and Diagram" section, prose-only, matching that file's established no-screenshot style.
  Extended `colony-manager-guide.qmd`'s "Diagram view" paragraph to cover the 5 missing features,
  prose-only per an owner `AskUserQuestion` depth pick (over "prose + one screenshot" or "full
  screenshot parity"), matching that file's task-oriented voice.
- **Verification:** `a3manual.Rmd` (parent of `_pedigree_browser.Rmd`) rendered via
  `rmarkdown::render()`, new legend text confirmed present in the output. `colony-manager-guide.qmd`
  rendered via `quarto render --to html`, zero errors, new prose confirmed present in the output.
  `tests/spelling.R` clean (no new flagged words from either edit). Full regression suite unchanged
  at 0 failed/0 error (3509 passed, same 10 pre-existing `test_modMarkerGenetics.R` baseline
  warnings, unrelated to this session -- no `R/` files touched). Phase 3E: n/a -- documentation-only
  change, no Shiny/runtime behavior affected.
- **GitHub:** issue #139 closed via `gh api` comment
  (`https://github.com/rmsharp/nprcgenekeepr/issues/139#issuecomment-5159297837`) + state PATCH.
  `BACKLOG.md` new resolved-item bullet (matching the #131/#132/#134/#135 format) in the "Pedigree
  diagram vs kinship2 audit follow-ups" section. `PROJECT_LEARNINGS.md` Learning 444 added.
  `CLAUDE.md` learnings cross-reference count updated (443->444, Sessions 1-454+->1-455+).

### 2026-08-02 · [issue #135] Add hover tooltips + search/highlight to the Pedigree Diagram tab (Session 454)
- **Deliverable:** resolves audit Recommendation #8 (`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`
  Finding #11, priority 5 of the owner-set #131-#138 order). Strict TDD: PRE-RED (hands-on
  `visOptions()` research + two owner `AskUserQuestion` scope decisions) -> RED (10 failing tests) ->
  GREEN (minimum implementation) -> REFACTOR skipped (owner-confirmed, GREEN already matched the
  file's established style).
- **Data layer:** `R/makePedigreeDiagramData.R`'s returned nodes gain a `title` field -- an
  HTML hover-tooltip string (ID, sex spelled out matching the shape-to-sex legend's own
  Female/Male/Hermaphrodite/Unknown/"Other / Unrecorded" labels, generation, sire, dam --
  `Unknown` for missing parents; id/sire/dam HTML-escaped via a new internal `.escapeHtml()`
  helper). 8 new unit tests in `tests/testthat/test_makePedigreeDiagramData.R`.
- **UI layer:** `R/modPedigree.R`'s Diagram tab widget gained
  `visOptions(nodesIdSelection = TRUE, highlightNearest = list(enabled = TRUE, hover = TRUE,
  degree = 1, algorithm = "all"))` -- a "Select by id" search dropdown, and highlight-on-**hover**
  (not visOptions()'s own click-based default) so it doesn't overlap the existing click-to-navigate
  handler (issue #129 Slice 2). 2 new tests asserting the widget JSON config, matching the
  #131/#132 pattern.
- **Verified:** full regression suite 0 failed/0 error (3509 passed, 10 pre-existing baseline
  warnings, unchanged); `devtools::check()` 0 errors/1 warning (pre-existing iCloud duplicate-file
  artifact)/0 notes (a new WORDLIST entry, "dropdown", was needed after adding NEWS/tutorial prose).
  Live `shinytest2`/`chromote` verification against the real app and the same known trio
  `test-e2e-pedigree-module.R` uses (`obfuscated_rhesus_mhc_ped.csv`): live node `title` matches
  exactly; the real DOM search dropdown is populated with all 375 IDs; a real `change` event
  genuinely dims an unrelated node while leaving a connected one normal (the highlight logic
  executes, not just its config); click-to-navigate unaffected.
- **Accepted trade-off (owner-directed via `AskUserQuestion`), `PROJECT_LEARNINGS.md` Learning 443:**
  `nodesIdSelection` injects its own Shiny-bound `<select>` elements client-side, outside the normal
  `renderUI()` container-diff cycle -- from the second reactive re-render onward this can log one
  transient, benign `[shiny] Duplicate input IDs were found` console warning (no permanent DOM
  duplication, no functional impact); a structural fix (`visNetworkProxy()`-based incremental
  updates) was judged disproportionate to this audit's own "optional, low-priority... UI polish"
  framing and would risk the 3 already-shipped Diagram-tab features -- accepted and documented in
  code and this learning rather than fixed.
- **Documentation checklists:** `NEWS.Rmd`/`NEWS.md` new bullet;
  `vignettes/manual_components/_pedigree_browser.Rmd` Diagram paragraph extended (tutorial/article
  checklist -- proportionate prose-only addition to this file's existing no-screenshot style, not
  `colony-manager-guide.qmd`, matching the CLAUDE.md rule's "and/or"). `BACKLOG.md` new
  resolved-item bullet; `CLAUDE.md` Learnings cross-reference count updated (442->443,
  Sessions 1-453+->1-454+). Closed via GitHub comment
  (`https://github.com/rmsharp/nprcgenekeepr/issues/135#issuecomment-5156062877`).

### 2026-08-02 · [issue #134] Verify inbreeding-loop/consanguinity rendering in the Pedigree Diagram tab -- closed, no code change (Session 453)
- **Deliverable:** resolved plan Dragon P2 (`docs/planning/issue129-pedigree-diagram-tree-visualization-plan.md`
  lines 581-589, silently untracked across Slices 1/2 per `PROJECT_LEARNINGS.md` Learning 410) by
  constructing a known-loop pedigree and running it through the shipped Diagram tab. Audit-only session
  (owner-confirmed via `AskUserQuestion`) -- no production code or tracked test-suite files changed.
- **Data layer:** a synthetic 6-node half-sib-mating fixture confirmed via the package's own `kinship()`
  (`kinship(A,B) = 0.125`) to be a genuine loop; `makePedigreeDiagramData()` produced exactly 6 nodes (no
  duplication) and 6 edges (no drops), with `level` values matching `findGeneration()`'s output, which
  itself correctly treats the converging structure as a DAG, not a cycle.
- **Live layer:** rather than hand-building a second fixture, found a real consanguineous-mating case
  already in the project's own bundled E2E fixture (`inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`)
  -- `GA204Z` (F = 0.25), whose sire `8LKBV9` is also his maternal grandfather. Drove the shipped app
  end-to-end via `shinytest2`/`chromote` (the same `AppDriver` helpers `test-e2e-pedigree-module.R` uses)
  and queried the live `vis.js` `Network` instance's own `DataSet`s directly: no duplicate node, both loop
  edges present, no dropped edge, zero console errors at any level (50 `info`/5 `stderr`/1 `stdout`, 0
  `error`/`throw`/`warning`), and a visually legible diamond-shaped render via the app's own
  focal-animal+trim feature. New `PROJECT_LEARNINGS.md` Learning 442 records the "check bundled example
  data before hand-building a fixture" technique.
- **Verified:** direct live-browser structural + visual confirmation (above) -- this session's own
  deliverable *is* the runtime verification, satisfying Phase 3E.
- **Closed:** issue #134 via GitHub comment (`https://github.com/rmsharp/nprcgenekeepr/issues/134#issuecomment-5155638782`),
  no follow-up filed -- the rendering is adequate.

### 2026-08-02 · [BL-spellingNoteWordlist] Add 13 missing words to inst/WORDLIST, clearing devtools::check()'s spelling NOTE (Session 452)
- **Deliverable:** resolved the `BACKLOG.md` Housekeeping item ("`devtools::check()`'s spelling NOTE is
  broader than previously tracked," discovered S443 as just `IACUC`, broadened S448) by hand-adding the
  missing words to `inst/WORDLIST`.
- **Discovery:** a fresh `devtools::check()` run before touching anything showed the single NOTE actually
  covers 13 words, not the 12 the item named -- `Bhatia`, `Chesser`, `Cockerham`, `Fst`, `FST`, `Gst`,
  `Hedrick`, `Maddison`, `Meirmans`, `Sankararaman`, `Slatkin`, `monomorphic` (all `markerFst.Rd` citation
  terms, S447/issue #130 Slice 5) plus the already-tracked `IACUC` (`_pedigree_browser.Rmd:55`, flagged
  since S443, never actually fixed by any intervening session). New `PROJECT_LEARNINGS.md` Learning 441
  records why a "separately tracked" carve-out in a backlog item's word count doesn't mean that word has
  its own resolution path.
- **Fix:** all 13 words hand-added to `inst/WORDLIST` in `LC_ALL=C` byte-order position (not via
  `spelling::update_wordlist()`, per S230 convention).
- **Verified:** `devtools::check()` raw log before: `Status: 1 WARNING, 1 NOTE` (13-word spelling diff);
  after: `Status: 1 WARNING` (spelling.Rout vs. spelling.Rout.save now `OK`) -- the remaining WARNING is
  the pre-existing, unrelated iCloud-sync duplicate-file artifact (`R/appServer 2.R`/
  `R/modMarkerGenetics 2.R`). Regression suite unchanged: 0 failed/0 error (3489 passed, 183 skipped, 10
  pre-existing baseline warnings), exactly matching the known-good S450 baseline. Docs/data-only change
  (`inst/WORDLIST` is not app runtime code) -- Phase 3E runtime smoke test n/a.
- **Also:** updated `CLAUDE.md`'s `PROJECT_LEARNINGS.md` cross-reference count (440->441 learnings,
  Sessions 1-450+ -> 1-452+, Learning #7/#10 cross-reference discipline).

### 2026-08-02 · [BL-notCranFastTest] Fix CLAUDE.md's "Fast single-file test" command to set NOT_CRAN=true (Session 451)
- **Deliverable:** resolved the `BACKLOG.md` Housekeeping item (discovered S439, `PROJECT_LEARNINGS.md`
  Learning 417) noting that `CLAUDE.md`'s documented "Fast single-file test" one-liner doesn't set
  `NOT_CRAN`, so a file with a top-level `skip_on_cran()` (e.g. `test-e2e-data-ready.R:10`) silently
  bare-skips ("On CRAN") instead of reporting real results.
- **Fix:** prepended `Sys.setenv(NOT_CRAN = "true")` to the documented `Rscript -e '...'` one-liner in
  `CLAUDE.md`'s "Build / Test / Verify" section, with a parenthetical explaining why and citing
  Learning 417.
- **Verified:** reproduced the bug first -- the OLD command against `test-e2e-data-ready.R` reports a
  bare `S` (skipped, reason "On CRAN"); the NEW command runs all 34 real expectations (all passing).
  Docs-only change, no `R/` code touched, no runtime behavior affected (Phase 3E n/a). Confirmed
  `PROJECT_LEARNINGS.md` Learning 417 exists and matches the citation. Grepped the repo for other
  stale references to the old command text -- none found outside `BACKLOG.md`'s own now-resolved
  description; all `docs/planning/*.md` verify-command examples already independently include
  `NOT_CRAN=true` and needed no change.
- `BACKLOG.md` Housekeeping item marked resolved.

### 2026-08-02 · [BL-a2interactiveChecklist] Ratify a deferred a2interactive.Rmd checklist + backfill issue #130's marker-genetics functions (Session 450)
- **Deliverable:** resolved the `a2interactive.Rmd` documentation-checklist `BACKLOG.md` Housekeeping
  decision item (filed S447, `PROJECT_LEARNINGS.md` Learning 435) via two `AskUserQuestion` calls --
  a policy choice and a separate backfill choice, mirroring S448's `NEWS.Rmd` checklist resolution
  pattern (Learning 436). Owner picked option (a) (extend the checklist, deferred) and separately
  directed backfilling issue #130's 5 marker-genetics functions in this same session.
- **Policy (ratified in `CLAUDE.md` "Additional close-out checks"):** new exported, script-callable
  functions should eventually get a demonstration section in `vignettes/a2interactive.Rmd` -- but
  unlike the citation/tutorial-article/`NEWS.Rmd` checklists, this is explicitly DEFERRED, not
  same-session: coverage happens in a dedicated pass after a feature has stabilized, to avoid
  documenting something that may still change. Applies prospectively from this session forward.
- **Backfill:** added a new "## Marker Genetics" section to `vignettes/a2interactive.Rmd` (6
  subsections: preparing a marker genotype file, marker-based kinship, heterozygosity diagnostic,
  parentage verification/Mendelian exclusion, cross-center identity linking, cross-center Fst)
  demonstrating `checkMarkerGenotypeFile()`, `buildMarkerGenotypeMatrix()`, `markerKinship()`,
  `markerObservedHeterozygosity()`/`markerExpectedHeterozygosity()`, `markerParentageExclusion()`,
  `resolveCrossCenterIds()`, and `markerFst()`. Reused the SAME hand-verified fixtures already
  backing the Shiny app's own Marker Genetics tab screenshots in `colony-manager-guide.qmd` (the
  P/C/U kinship/parentage trio, the X/Y/Z heterozygosity trio, and the Center A/B Fst fixture, all
  sourced from `test_modMarkerGenetics.R`) so the tutorial's printed numbers match the article's
  tables. Every demo chunk verified against the real package (scratch script + full
  `rmarkdown::render()`) before being narrated in prose.
- **Incidental discovery + fix (stale local install, `PROJECT_LEARNINGS.md` Learning 440):**
  rendering failed with `could not find function "markerParentageExclusion"` -- the locally
  installed package copy (`find.package("nprcgenekeepr")`, distinct from `pkgload::load_all()`)
  had lagged 3 slices behind source (S444/S446/S447 never triggered a `devtools::install()`
  refresh). Fixed via `devtools::install(quiet = TRUE, upgrade = FALSE, dependencies = FALSE)`
  (the `upgrade = "never"` form used at S417 now errors on the current `devtools` version) before
  re-rendering -- not caused by this session's own diff (no `R/` source changed).
- **Spelling gate:** this session's own new content (function names in prose, plus "STR"/
  "misrecorded") introduced 14 new `devtools::check()` spelling flags. Hand-added all 14 to
  `inst/WORDLIST` in case-insensitive radix-sort position (not via `spelling::update_wordlist()`,
  per S230 convention), following the file's established two-block (uppercase-initial then
  lowercase-initial) sort structure. Left the existing, separately-tracked 12-word pre-existing gap
  (`Bhatia`/`Chesser`/`Cockerham`/`Fst`/`FST`/`Gst`/`Hedrick`/`IACUC`/`Maddison`/`Meirmans`/
  `Sankararaman`/`Slatkin`/`monomorphic`) untouched -- it remains its own open `BACKLOG.md`
  Housekeeping item, out of scope for this session.
- **Cleanup:** removed a stray `vignettes/a2interactive.knit.md` intermediate byproduct left by an
  earlier verification render (gitignored, never staged, but confused a raw ad hoc
  `spelling::spell_check_package()` scan with gibberish base64-looking tokens from rendered example
  data before its removal).
- **`BACKLOG.md`:** Housekeeping item marked resolved. **`PROJECT_LEARNINGS.md`:** Learning 440
  added; `CLAUDE.md`'s learnings cross-reference count updated (439→440, Sessions 1-449+→1-450+).
- **Verified:** `vignettes/a2interactive.Rmd` renders cleanly end-to-end via `rmarkdown::render()`
  (132 chunks, no errors); clean regression read 0 failed/0 error (3489 passed, 183 skipped, 10
  pre-existing baseline warnings from `test_modMarkerGenetics.R` fixture data, unchanged and
  unrelated); `devtools::check()` raw `Status:` line (per Learning 382): 1 warning (pre-existing
  iCloud-sync duplicate-file artifact, unrelated), 1 note (the pre-existing, separately-tracked
  12-word spelling gap, unrelated) -- confirmed via the raw `spelling.Rout`/`spelling.Rout.save`
  diff that zero new words from this session's own content remain flagged.
- **Phase 3E:** n/a -- documentation-only change (a vignette + `CLAUDE.md` policy text), no
  Shiny/runtime behavior affected.

### 2026-08-01 · [issue #132] Add an in-app shape-to-sex legend to the Pedigree Diagram tab (Session 449)
- **Deliverable:** implemented issue #132 (owner-picked via the Phase 0 priorities
  `AskUserQuestion`). The Pedigree Browser's Diagram tab now shows a shape-to-sex legend to the
  right of the diagram: dot = Female, square = Male, star = Hermaphrodite, triangle = Unknown,
  diamond = Other / Unrecorded -- matching `makePedigreeDiagramData()`'s existing shape mapping.
  Full TDD cycle (PRE-RED scope decisions → RED → GREEN → REFACTOR-skipped), every phase
  transition `AskUserQuestion`-gated.
- **Implementation choice (owner-picked via `AskUserQuestion`):** `visNetwork::visLegend()`
  (native, same shape renderer as the diagram itself -- no approximation) over a hand-rolled
  static HTML/CSS panel with Unicode glyphs. Verified via the `visNetwork.js` source
  (`instance.network.on(key, ...)` binds `visEvents()`'s click-to-navigate handler only to the
  main network, never `instance.legend`) that legend clicks cannot trigger navigation --
  confirmed live too: emitting a click on a legend node left the focal-animal selection and
  Table tab unchanged. Position: right of the diagram (owner-picked).
- **Layout fix found live during verification (Pre-RED/GREEN):** the default `visLegend()`
  spacing (`stepY=100`) and width (`width=0.2`) didn't comfortably fit 5 entries within the
  diagram widget's fixed 400px height -- the longest label ("Other / Unrecorded") clipped
  against the legend canvas's own `overflow:hidden` boundary, and the last row crowded the
  export button below it. Tuned `stepY=65`, `width=0.28`; re-verified live via a
  `shinytest2`/`chromote` screenshot before and after.
- **Tests:** new unit test (`tests/testthat/test_modPedigree.R`, asserting the widget's
  `x.legend` config: position, title, all 5 label/shape pairs, and the tuned
  `width`/`stepY`) and new E2E smoke test (`tests/testthat/test-e2e-pedigree-module.R`, querying
  the live legend `vis.Network` DataSet -- static-HTML text matching does not work here since the
  legend renders to an HTML5 canvas, discovered mid-RED and corrected). RED confirmed clean on
  both (11 failed unit expectations / 5 failed e2e expectations, isolated to the new tests only);
  GREEN confirmed clean (0 failed/0 error on both, full regression suite 0/0/0 non-baseline,
  `devtools::check()` 0 errors -- 1 warning/1 note both pre-existing and unrelated, S448 baseline).
- **Documentation checklists (same session, per `CLAUDE.md`):** `NEWS.Rmd`/`NEWS.md` gained a new
  bullet (2.0.0.9000 section); incidentally re-rendering also fixed a stale S448 NEWS.Rmd→NEWS.md
  render mismatch (the "Kinship Comparison" sub-tab phrase was in `NEWS.Rmd` but missing from the
  committed `NEWS.md`). Tutorial/article checklist resolved via `AskUserQuestion` given a real
  tension -- the base Diagram tab (issue #129) itself has zero tutorial coverage, tracked as open
  issue #139 -- owner picked a minimal "Diagram view" intro + the legend (not the full #139
  scope) in `vignettes/articles/colony-manager-guide.qmd`, with a note left on issue #139 so a
  future session doesn't start from zero. New live screenshot:
  `vignettes/articles/shiny_app_use/pb_diagram_legend.png`.
- **GitHub:** issue #132 closed with implementation summary; issue #139 noted (not closed) with
  the minimal-intro exception.
- **Commits:** `9158521a` (claim).

### 2026-08-01 · [BL-NewsRmdChecklist] Ratify a NEWS.Rmd entry checklist + backfill issue #130 Slices 1-5 (Session 448)
- **Deliverable:** resolved the `NEWS.Rmd` checklist `BACKLOG.md` Housekeeping decision item
  (filed S446, `PROJECT_LEARNINGS.md` Learning 433) via two `AskUserQuestion` calls -- a policy
  choice and a separate backfill choice. Owner picked the broad policy option and the backfill
  option on both.
- **Policy (ratified in `CLAUDE.md` "Additional close-out checks"):** any session that ships a
  new exported function or a new user-facing Shiny feature/control must add a `NEWS.Rmd` entry in
  the same session it ships, mirroring the existing citation (issue #120) and tutorial/article
  (Session 436) checklists. Applies prospectively from this session forward.
- **Backfill:** added 5 `NEWS.Rmd` bullets to the 2.0.0.9000 section covering issue #130's entire
  shipped slice family -- the new **Marker Genetics** tab (Slice 1: `checkMarkerGenotypeFile()`,
  `buildMarkerGenotypeMatrix()`, `markerKinship()`), its **Heterozygosity** sub-tab (Slice 2:
  `markerObservedHeterozygosity()`/`markerExpectedHeterozygosity()`), its **Parentage Exclusion**
  sub-tab (Slice 3: `markerParentageExclusion()`), the script-callable `resolveCrossCenterIds()`
  (Slice 4, no UI), and its **Cross-Center** sub-tab (Slice 5: `markerFst()`). Re-rendered
  `NEWS.Rmd` → `NEWS.md` via `rmarkdown::render()`; `git diff` confirmed the render touched
  exactly the 5 new bullets, no reflow churn (`NEWS.Rmd`'s existing `html_preview: false` avoided
  the `NEWS.html` litter documented in `PROJECT_LEARNINGS.md` Learning 122/136).
- **`BACKLOG.md`:** Housekeeping item marked resolved. **`PROJECT_LEARNINGS.md`:** Learning 436
  added (the ratify-AND-backfill resolution pattern); `CLAUDE.md`'s learnings cross-reference
  count updated (435→437, Sessions 1-447+→1-448+).
- **Incidental (folded into the Phase 1B claim commit, not a separate deliverable):** found and
  fixed S447's own `HANDOFFS.md` receipt still carrying `commit: pending` -- backfilled to the
  real `afb979bc`, the same reconcile pattern S447 itself applied to S446's receipt.
- **Incidental discovery (BACKLOG.md item broadened, not fixed mid-session):**
  `devtools::check()` surfaced 1 WARNING (untracked iCloud-sync duplicate files in `R/`,
  owner-confirmed sync-lag artifacts, unrelated) and 1 NOTE (a spelling gap). A clean `git
  worktree` at S447's own final commit (`afb979bc`) confirmed 12 words -- `Bhatia`, `Chesser`,
  `Cockerham`, `Fst`/`FST`, `Gst`, `Hedrick`, `Maddison`, `Meirmans`, `Sankararaman`, `Slatkin`,
  `monomorphic` (S447's own `markerFst.Rd` citations) plus the already-tracked `IACUC` -- were
  ALREADY missing from `inst/WORDLIST` before this session touched anything, meaning S447's own
  self-reported "`devtools::check()` 0/0/0" does not hold up under re-verification. Fixed only
  this session's own new word (`homozygote`, added to `inst/WORDLIST`); broadened the existing
  `BACKLOG.md` spelling-NOTE item with the fuller scope for a future session. New
  `PROJECT_LEARNINGS.md` Learning 437 (a predecessor's self-reported verification claim needs the
  same trust-but-verify treatment as any other claim).
- **Verified:** `NEWS.Rmd`/`NEWS.md` render clean, diff scoped to exactly the 5 new bullets;
  `devtools::check()` raw `Status:` line (per Learning 382): 0 errors, 1 warning, 1 note (both
  pre-existing/environmental, detailed above, neither introduced by this session).
- **Phase 3E:** n/a -- documentation/policy-only change, no runtime behavior affected.

### 2026-08-01 · [issue #130] Implement Slice 5 -- cross-center Fst (Session 447)
- **Deliverable:** full TDD cycle (PRE-RED→RED→GREEN, REFACTOR owner-confirmed skip, each
  transition `AskUserQuestion`-gated per `CLAUDE.md`) implementing Slice 5 of
  `docs/planning/issue130-marker-kinship-crosscenter-identity-plan.md` §4 -- the last slice in
  the issue's owner-ratified sequencing chain. New `markerFst(genotypeMatrixA, genotypeMatrixB)`
  (base R, no new dependency): Hudson's Fst estimator (Bhatia, Patterson, Sankararaman & Price
  2013, *Genome Research* 23(9):1514-1521, Eq. 10, citing Hudson, Slatkin & Maddison 1992,
  *Genetics* 132(2):583-589), computed per shared biallelic locus and pooled across loci as a
  ratio of sums (not a mean of per-locus ratios). `R/modMarkerGenetics.R` gained a Center-B
  genotype file input and a new "Cross-Center" tab.
- **Pre-RED (Dragon P2 -- estimator choice, the plan's own flagged risk):** resolved via a 5-agent
  research `Workflow` (3 parallel angles -- Weir & Cockerham 1984 primary-source research,
  alternatives research, captive-NHP-colony precedent research -- plus a dedicated adversarial
  verification stage and a synthesis stage). The adversarial pass found the first pass's own
  "Weir & Cockerham (1984)" formula was an incomplete, ~40%-off special case (missing a
  heterozygosity-driven third variance component), confirmed against 3 independent sources not
  used by the first pass -- `PROJECT_LEARNINGS.md` Learning 434. The synthesis recommended
  switching estimator families entirely to Hudson's, per Bhatia et al.'s own explicit
  recommendation for two-named-population pairwise comparisons (unbiased by sample-size ratio,
  unlike Weir & Cockerham). Presented as its own `AskUserQuestion` (separate from the phase
  gate); owner chose Hudson's estimator, the recommendation.
- **Fixture:** hand-derived two-center, two-locus toy example (Center A n=4, Center B n=6) via
  exact-fraction arithmetic during Pre-RED research, cross-checked against 2 independently-
  fetched primary sources. Expected values: `perLocus[["L1"]] = 58/1001`,
  `perLocus[["L2"]] = 139/308`, `pooledFst = 614/2233`. 5 RED test blocks in the new
  `tests/testthat/test_markerFst.R` plus 3 new blocks in `tests/testthat/test_modMarkerGenetics.R`
  (Cross-Center tab UI + `testServer()` reactive tests) cover this fixture plus edge cases:
  locus-intersection restriction, zero-genotyped-individuals-locus exclusion, both-centers-
  monomorphic `NA`-not-`NaN`, and an unclamped negative value.
- **Mid-session owner directives, both addressed in place:** (1) the roxygen/citation
  documentation must carry the full rationale for the estimator choice, not just the citation --
  added to `markerFst()`'s own `@details`, a new section in
  `inst/extdata/ui_guidance/population_genetics_terms.html`, and a new subsection in
  `vignettes/articles/colony-manager-guide.qmd`. (2) filed a `BACKLOG.md` Housekeeping item
  ensuring new features get discussed in `vignettes/a2interactive.Rmd` (a third documentation
  surface, distinct from the existing citation/tutorial-article checklists, confirmed via grep to
  have zero issue #130 coverage across its 875 lines) -- revised in place per a follow-up
  directive to record a deferred-until-fully-reviewed cadence, not the same-session pattern of
  the existing checklists -- `PROJECT_LEARNINGS.md` Learning 435.
- **Verified:** targeted test files green; full clean regression suite 0 failed/0 error (3476
  passed, 182 skipped) -- caught and fixed 2 real GREEN-phase gaps (`test_moduleContract.R`'s
  registered reactive-name list; `_pkgdown.yml`'s reference-coverage list) that the targeted test
  run alone would have missed; `devtools::check()` 0 errors/0 warnings/0 notes (run twice, before
  and after a doc-regeneration fix caught mid-session); a live `shinytest2`/`chromote` smoke test
  of the running app uploaded two real CSV files through the browser and confirmed the rendered
  Cross-Center table's values matched the hand-verified fixture exactly, with no console errors.
  Citation checklist (issue #120) and tutorial/article checklist (S436) both completed
  same-session. Issue #130 is now fully implemented across all 5 slices -- closed with a
  summary comment (https://github.com/rmsharp/nprcgenekeepr/issues/130#issuecomment-5154242857).

### 2026-08-01 · [issue #130] Implement Slice 4 -- cross-center identity linking (Session 446)
- **Deliverable:** full TDD cycle (PRE-RED→RED→GREEN, REFACTOR owner-confirmed skip, each
  transition `AskUserQuestion`-gated per `CLAUDE.md`) implementing Slice 4 of
  `docs/planning/issue130-marker-kinship-crosscenter-identity-plan.md` §4: new
  `resolveCrossCenterIds(pedA, pedB, mapping)` (base R, no new dependency) collapses a
  curator-confirmed cross-center identity link so a transferred animal becomes one node with
  its real parents intact, instead of the artificial-founder failure mode issue #130 names
  directly. Validates `id`/`sire`/`dam` on both pedigrees and `idA`/`idB` on the mapping table;
  rejects duplicate mapping rows, missing id references, conflicting non-`NA` recorded parents
  between the two sides, and an id string present in both pedigrees but undeclared in the
  mapping (fail loud, matching D5's deterministic/auditable design and the
  `getPedigreeSource()` style).
- **Pre-RED (Dragon P6 -- Shiny-wiring scope, the plan's own open call):** presented as its own
  `AskUserQuestion` (separate from the PRE-RED→RED phase gate, per `CLAUDE.md`'s phase-gate
  format). Owner chose script-callable function only, this session -- no `modInput.R` UI change
  -- matching the plan's own cited precedent of `getFileDirectRelatives()` shipping standalone
  before any UI wiring, and keeping the session to one layer given `modInput.R`'s existing
  five-branch file-content complexity.
- **Fixture:** hand-built two-center pedigree pair (Center A: `P1`/`P2` founders, their child
  `T1` later transferred, `T1`'s full sibling `S1`; Center B: `X9` = the same physical animal as
  `T1` recorded as an artificial founder, `Q1` founder, `O1` = `X9`×`Q1`'s child) + a mapping
  linking `T1`↔`X9`. Expected values hand-verified against the package's own real
  `kinship()`/`findGeneration()` before any RED assertion was written -- both the fix
  (`kinship(S1, O1) == 0.125`, the correct cross-center aunt/nephew coefficient on the merged
  pedigree) and the bug itself (`== 0` on a naive un-merged combination), extending Learning
  423's "verify with an independent script" precedent to a deliberate before/after comparison.
  See `PROJECT_LEARNINGS.md` Learning 432.
- **Verified:** targeted test file 18/18 expectations; full clean regression suite 0 failed/0
  error/0 warning (3443 passed, 182 skipped); `devtools::check()` 0 errors/0 warnings/0 notes
  (fixed one Rd cross-reference warning to a `@noRd` function along the way); `_pkgdown.yml`
  reference-coverage entry added same-session (the gap class Slice 1 hit and fixed
  retroactively). No live runtime/`shinytest2` smoke test -- n/a, no Shiny UI shipped this
  session (Dragon P6 decision).
- **Citation checklist (issue #120) / Tutorial checklist (S436):** both N/A this slice -- no new
  displayed statistic and no new UI shipped.
- **Discovery, not fixed this session:** issue #130's Slices 1-4 (S442-S446) collectively shipped
  4 new exported functions + a new Shiny module/tab with zero `NEWS.Rmd` entries, unlike sibling
  issues #125-#129 which each got one -- `CLAUDE.md` has no `NEWS.Rmd` checklist analogous to its
  citation/tutorial ones. Filed to `BACKLOG.md` as an owner decision item per the established
  report-don't-fix precedent (Learning 382/407). See `PROJECT_LEARNINGS.md` Learning 433.
- Also pushed the previously-uncommunicated `fd61f100` (Session 445's close-out commit, left
  un-pushed at that session's end) to `origin/master` at the owner's explicit Phase 0 request,
  before starting Slice 4.

### 2026-08-01 · [ad hoc] Claude Code Doctor cleanup + CLAUDE.md derivable-content trim (Session 445)
- **Deliverable:** Ran the `/doctor` Claude Code health-check (install health, skill/plugin usage,
  checked-in `CLAUDE.md` derivability, hook timing, version currency, permission defaults, denied-
  command patterns) and applied its confirmed findings. Repo-visible outcome: `CLAUDE.md` trimmed
  of a stale version number (had drifted from `DESCRIPTION`'s real `2.0.0.9000`) and three sections
  duplicating `DESCRIPTION`'s own `Description:`/`URL:` fields (`### Core Functions`, two
  `### Package Structure` layout bullets, `### Online Documentation`) -- 43 lines removed,
  committed `91b019c4`, pushed to `origin/master`. Non-repo outcome (Claude Code tooling config,
  not tracked in this repository): 8 unused skills and 2 unused LSP plugins disabled, auto
  permission mode set as the default, a stale leftover npm-global Claude Code install removed
  from the machine.
- **Process note:** this session skipped `SESSION_RUNNER.md` Phase 0 orientation and Phase 1B
  session-claim entirely, reconciled retroactively at Phase 3D only because the user explicitly
  requested close-out -- see `SESSION_NOTES.md`/`HANDOFFS.md` (S445) and `PROJECT_LEARNINGS.md`
  Learning 431.

### 2026-08-01 · [issue #130] Implement Slice 3 -- Mendelian-exclusion parentage verification (Session 444)
- **Deliverable:** full TDD cycle (PRE-RED→RED→GREEN→REFACTOR, each transition
  `AskUserQuestion`-gated per `CLAUDE.md`) implementing Slice 3 of
  `docs/planning/issue130-marker-kinship-crosscenter-identity-plan.md` §4: new
  `markerParentageExclusion(genotypeMatrix, pedigree, maxExclusions = 2L)` flags a pedigree's
  recorded dam/sire as Mendelian-inconsistent with an offspring's marker genotype (opposite-
  homozygote conflicts over jointly-genotyped loci), directly targeting the issue's named ~5%
  dam-misidentification problem. `modMarkerGenetics` gained a new `pedigree` server parameter,
  an `exclusionTable` reactive, and a "Parentage Exclusion" tab (long-format flagged-pairs table:
  `id`/`parentId`/`role`/`exclusionCount`/`nLoci`/`flagged`). `appServer.R` wires the live
  `shared$currentPedigree` into the module.
- **Pre-RED (Dragon P4 -- genotyping-error-tolerance threshold):** a 3-agent research `Workflow`
  (2 independent sources + adversarial cross-check) found no fabricated citations, but a REAL
  numeric disagreement between the two honestly-sourced reports: Cifuentes et al. (2006, human
  paternity testing) said exclude at ≥3 mismatches; a bison/cattle microsatellite parentage-
  testing patent (Schnabel et al. 2000) said exclude at ≥2. The cross-check independently
  re-verified both primary sources itself (not just the reports' paraphrases) and broke the tie
  by grepping this package's own `R/checkMarkerGenotypeFile.R` to confirm the marker model is
  biallelic-only, favoring the SNP/biallelic-calibrated precedent (Cifuentes 2006 + de Groot et
  al. 2025, a real captive rhesus/cynomolgus macaque colony parentage precedent tolerating up to
  3 mismatches) over the microsatellite-calibrated one. Owner picked `maxExclusions = 2` (flag
  only at 3+ inconsistent loci) via `AskUserQuestion`.
- **Fixture:** a hand-built 9-animal/5-locus pedigree+genotype set with boundary cases at exactly
  2 (tolerated) and exactly 3 (flagged) mismatches, an ungenotyped-recorded-parent skip case, an
  unknown-parent skip case, and a separate zero-shared-loci NA case — exact expected values
  derived via an independent standalone reference script before any RED test was written.
- **`inst/WORDLIST` sort-convention discovery:** fixing the spelling NOTE for 14 new roxygen
  citation words found (via empirical `sort(..., method = "radix")` verification) that the
  file's actual sort convention is byte-order/radix, not case-insensitive collation as prior
  sessions' shorthand described it — see `PROJECT_LEARNINGS.md` Learning 428.
- **Verified:** full clean regression suite 0 failed/0 error/0 warning (3425 passed, 182
  skipped), confirmed via a controlled `git stash`/restore before/after comparison against the
  pre-Slice-3 baseline; `devtools::check()` down to the single pre-existing, unrelated `IACUC`
  spelling NOTE (`BACKLOG.md`, out of scope); live `shinytest2`/`chromote` smoke test confirmed
  real, correctly-computed exclusion counts/flags (0/false for a true dam, 3/true for a
  falsely-recorded sire) with zero console errors, screenshot captured for the guide article.
- **Citation checklist (issue #120):** new "Mendelian-Exclusion Parentage Verification" entry in
  `inst/extdata/ui_guidance/population_genetics_terms.html`.
- **Tutorial/article checklist (S436):** new paragraph + screenshot in
  `vignettes/articles/colony-manager-guide.qmd`'s Marker Genetics section.
- See `PROJECT_LEARNINGS.md` Learnings 428–430 (WORDLIST byte-order convention; ad-hoc
  `shinytest2::AppDriver` script gotchas -- `source()` vs. direct invocation, method names; the
  Pre-RED cross-check's project-source tie-break pattern for genuine source disagreements).

### 2026-07-31 · [issue #130] Implement Slice 2 -- heterozygosity diagnostic (observed vs. expected) (Session 443)
- **Deliverable:** full TDD cycle (PRE-RED→RED→GREEN→REFACTOR, each transition
  `AskUserQuestion`-gated per `CLAUDE.md`) implementing Slice 2 of
  `docs/planning/issue130-marker-kinship-crosscenter-identity-plan.md` §4: new
  `markerObservedHeterozygosity()` (per-animal Ho, fraction of non-missing marker loci
  heterozygous) and `markerExpectedHeterozygosity()` (per-locus He = 1-Σp² from population
  allele frequencies, plus the unweighted mean across loci), both reusing Slice 1's
  `buildMarkerGenotypeMatrix()` output directly. `modMarkerGenetics` gained a new
  "Heterozygosity" tab (`tabsetPanel` alongside the existing "Kinship Comparison" tab) showing
  a per-animal `ho`/`he` comparison table (`he` = population meanHe repeated per row).
- **Pre-RED (Ho/He formula sourcing):** a 3-agent research `Workflow` (2 independent sources +
  adversarial cross-check) confirmed `He = 1 - Σp²` (Nei 1973 PNAS gene diversity) and per-animal
  Ho (fraction of heterozygous genotyped loci) as the standard forms — and caught a real
  citation-accuracy gap in the ratified plan's D3/§2G text: neither VCFtools nor PLINK's `--het`
  option reports columns named Ho/He (both report `O(HOM)`/`E(HOM)`/an inbreeding coefficient F
  instead), so this slice's own roxygen `@references` cites Nei (1973) directly rather than
  propagating that imprecision (plan text left as historical record, not retroactively edited).
  Owner scoped the slice to the plain/biased He form only (matching ratified D3 exactly) via
  `AskUserQuestion`, explicitly deferring the Nei & Roychoudhury (1974) small-sample-corrected
  estimator and standardized multilocus heterozygosity (sMLH) as documented future enhancements.
- **Fixture:** a hand-built X/Y/Z trio across 4 biallelic loci (Y missing L4, to lock in each
  animal's own non-missing-loci denominator), with exact expected Ho/He values derived via an
  independent standalone reference script before any RED test was written.
- **A real bug in the RED test itself, caught before commit:** a 2×2 matrix literal in
  `test_markerHeterozygosity.R` supplied 6 values instead of 4 — fixed during the RED-confirm
  step, before the RED commit.
- **A real, previously-undetected defect fixed along the way:** S442's own `HANDOFFS.md` receipt
  claimed `devtools::check()` "0 errors/0 warnings/0 notes," but the raw check log's `Status:`
  line actually said `1 NOTE` for spelling the whole time (`Manichaikul`/`Mychaleckyj`/`Daly`/
  `Bioinformatics`/`PLINK`/`biallelic`/`uninterpretable`, introduced by Slice 1, were never added
  to `inst/WORDLIST`) — the exact discrepancy `PROJECT_LEARNINGS.md` Learning 382 warns against,
  undetected until this session read the `Status:` line for its own new citation words. Fixed
  both the inherited gap and this session's own new words (`Nei`, `Nei's`, `Roychoudhury`) by
  hand in `inst/WORDLIST`. One unrelated, genuinely pre-existing word (`IACUC`,
  `_pedigree_browser.Rmd`) remains and is reported, not fixed, in `BACKLOG.md` (out of scope).
- **Citation checklist (issue #120):** new "Heterozygosity (Observed vs. Expected)" entry added
  to `inst/extdata/ui_guidance/population_genetics_terms.html`, citing Nei (1973) directly;
  `markerObservedHeterozygosity()`/`markerExpectedHeterozygosity()`'s own roxygen `@references`
  added at authorship.
- **Tutorial/article checklist (S436 rule):** new paragraph + screenshot in
  `vignettes/articles/colony-manager-guide.qmd`'s Marker Genetics section describing the
  Heterozygosity tab.
- **Phase 3E:** live `shinytest2`/`chromote` smoke test — uploaded the hand-verified X/Y/Z
  genotype file, confirmed the Heterozygosity tab renders `ho`/`he` values matching the fixture
  exactly (0.75/0.3333/0.25 and 0.3993 repeated), zero related console errors, real screenshot
  captured for the guide article.
- **Verified throughout:** full clean regression 0/0/0 (4096 passed, up from S442's 4067
  baseline; 170 skipped, unchanged); `devtools::check()` down to the single pre-existing,
  unrelated `IACUC` spelling NOTE (see above).
- **`BACKLOG.md`:** #130 sequencing item updated (Slice 2 DONE; Slices 3/4/5 next); new
  Housekeeping item for the `IACUC` spelling gap.
- **Learnings:** `PROJECT_LEARNINGS.md` Learnings 426-427 added (the Learning-382 recurrence, and
  `spell_check_package()` vs. `spelling.R`'s `spell_check_test()` scope difference); `CLAUDE.md`'s
  learnings-count cross-reference updated (425→427, Sessions 1-442+→1-443+).
- Commits: `86f57086` (claim), `330f3abe` (RED), `48e14f86` (GREEN checkpoint 1/2, source),
  `37462333` (GREEN checkpoint 2/2, generated docs), `00bcee16` (WORDLIST fix), `ce71221d`
  (citation + tutorial checklists), `958d2b22` (Phase 3E screenshot), this close-out commit.

### 2026-07-30 · [issue #130] Implement Slice 1 -- marker-based KING-robust kinship + multi-locus genotype foundation (Session 442)
- **Deliverable:** full TDD cycle (PRE-RED→RED→GREEN→REFACTOR, each transition
  `AskUserQuestion`-gated per `CLAUDE.md`) implementing Slice 1 of
  `docs/planning/issue130-marker-kinship-crosscenter-identity-plan.md` §4: new
  `checkMarkerGenotypeFile()` (validates the D1 long-format `id`/`locus`/`allele1`/`allele2`
  table, rejects any locus with more than 2 distinct alleles), `buildMarkerGenotypeMatrix()`
  (long-to-wide `id` x `locus` pivot), `markerKinship()` (the "between-family" KING-robust
  estimator, Manichaikul et al. 2010 Eq. 11), and a new `modMarkerGenetics` Shiny module
  (D6) surfacing a per-animal pedigree-vs-marker mean-kinship comparison table (`indivMeanKin`
  alongside new `markerMeanKin`), wired into `appUI.R`/`appServer.R` as a new "Marker Genetics"
  tab. The existing single-locus genotype path (`checkGenotypeFile`/`addGenotype`/
  `hasGenotype`/`getGVGenotype`/`geneDrop`) is completely untouched, per the plan's own §2C.
- **Pre-RED (Dragons P1/P2/P3):** a 3-agent research `Workflow` sourced the KING-robust
  formula from the primary 2010 paper AND an independent secondary source (Hail docs, after
  3 other suggested venues cited-but-didn't-reproduce the algebra), then an adversarial
  cross-check agent verified the two agree by literal algebraic reduction and caught a real
  discrepancy — one sourcing agent's own commentary named the wrong equation as "most commonly
  cited," contradicted by the other's direct KING/PLINK2/SNPRelate/GENESIS/Hail software
  survey. Resolved: implement Eq. 11 (the general-purpose, no-prior-family-knowledge form).
  Biallelic-only constraint (P1) confirmed structurally by both sources — no citable
  multiallelic variant exists anywhere checked — resolved as a validation rule
  (`checkMarkerGenotypeFile()` rejects >2-allele loci), correctly excluding the bundled
  `rhesusGenotypes` (MHC-haplotype, plausibly multiallelic) as invalid input to the new
  function. Fixture (P3): a hand-built 3-animal/10-locus biallelic parent/offspring/unrelated
  trio, with exact expected KING-robust values derived via an independent standalone
  reference script (not the package's own code) before any RED test was written — the later
  GREEN implementation matched every value exactly on the first run.
- **A real bug in the RED test itself, caught during GREEN verification:** `test_modMarkerGenetics.R`
  called the server's returned reactives as bare names instead of via
  `session$getReturned()$<name>()`, the established convention every other per-module test
  file uses — fixed once discovered (see `PROJECT_LEARNINGS.md` Learning 424).
- **Citation checklist (issue #120):** new "Marker-Based Kinship (KING-robust)" entry added to
  `inst/extdata/ui_guidance/population_genetics_terms.html` with the formula, variable
  definitions, and citation; `markerKinship()`'s own roxygen `@references` added in the same
  commit it was written.
- **Tutorial/article documentation checklist (S436):** new "Marker Genetics" section added to
  `vignettes/articles/colony-manager-guide.qmd` Section 3, with a live-captured screenshot of
  the populated comparison table (`vignettes/articles/shiny_app_use/marker_genetics_comparison.png`).
- **Phase 3E live smoke test:** `shinytest2`/`chromote` confirmed the tab uploads a genotype
  file, computes real KING-robust values matching the hand-verified fixture exactly, and joins
  them with real pedigree-based `indivMeanKin` values with zero related console errors. A first
  attempt's throwaway pedigree fixture used blank fields for missing parents and silently
  failed QC (`indivMeanKin` rendered blank) — root-caused to this project's CSV convention
  requiring literal `NA` text, not a blank field, for a missing parent (confirmed against the
  bundled `ExamplePedigree.csv`); corrected, giving a fully clean "QC passed! 4 records
  processed" run and screenshot. See `PROJECT_LEARNINGS.md` Learning 425.
- **Verified:** full clean regression read 0 failed/0 error/0 warning (4067 passed, 170
  skipped); `devtools::check()` 0 errors/0 warnings/0 notes.
- **BACKLOG.md** issue #130 sequencing item updated (Slice 1 DONE; Slices 2/3/4/5 next, any
  order per the plan's dependency graph). `PROJECT_LEARNINGS.md` Learnings 422-425 added;
  `CLAUDE.md`'s learnings-count cross-reference updated (421→425, Sessions 1-441+→1-442+).

### 2026-07-30 · [issue #130] Plan marker-based kinship/heterozygosity/parentage-verification + cross-center identity resolution (Session 441)
- **Deliverable:** one architecture-planning document,
  `docs/planning/issue130-marker-kinship-crosscenter-identity-plan.md`, following
  `ARCHITECTURE_WORKSTREAM.md`. Owner-picked from the Phase 0 priorities list (over issue #132's
  diagram legend, the `CLAUDE.md` `NOT_CRAN` doc fix, and NPRC outreach review). No `R/`, `tests/`,
  `man/`, `NAMESPACE`, or `data/` content changed — planning only.
- **Evidence base:** a 5-agent parallel research `Workflow` (issue #130's own text; the audit's
  Dimension 5/6 findings + the S422 triage trail; the existing kinship/genetic-diversity code
  inventory; the cross-center/LabKey architecture inventory; a domain-standards survey of
  marker-kinship/parentage/cross-institution-identity methods), followed by firsthand re-verification
  of every load-bearing claim (`DESCRIPTION`, `R/columnSchema.R`, `R/kinship.R`, `R/addGenotype.R`,
  `R/checkGenotypeFile.R`, `R/hasGenotype.R`, `R/getGVGenotype.R`, `R/reportGV.R:142-229`,
  `R/meanKinship.R`, `R/getPedigreeSource.R`, `R/convertFromCenter.R`,
  `docs/architecture/module-contract.md` all read directly) — no citation drift found.
- **Ratified decisions** (6, via `AskUserQuestion`, all recommended options accepted): D1 multi-locus
  genotype format is long/tidy; D2 marker kinship is a native KING-robust implementation in base R
  (no new hard dependency — avoids a Bioconductor `Imports` on this CRAN-published package); D4
  parentage verification is Mendelian exclusion in base R; D5 cross-center identity linking is a
  deterministic, curator-supplied cross-reference table (extending the `getPedigreeSource()` provider
  pattern); D6 the new capabilities get a dedicated `modMarkerGenetics` module; D7 the work is five
  vertical slices in dependency order. (D3, heterozygosity approach, was derived from D1 rather than
  separately ratified — no reasonable contested alternative.)
- **Key finding:** re-reading the audit's exact Dimension-6 wording showed the cross-center
  identity-by-state differentiation statistic (Slice 5) needs Slice 1's genotype model but **not**
  Slice 4's identity-linking capability — a population-level, two-dataset comparison, not a
  per-animal-identity operation — changing the plan's dependency graph from an assumed linear chain to
  a tree with two independently-schedulable leaves (`PROJECT_LEARNINGS.md` Learning 420).
- **Learnings:** `PROJECT_LEARNINGS.md` Learnings 420 (audit/issue prose bundling does not imply a
  technical dependency — verify the real dependency graph) and 421 (`ScheduleWakeup` is `/loop`-only;
  do not use it to wait on a background `Workflow`/`Agent` task-notification) added. `CLAUDE.md`
  learnings-count cross-reference updated (419→421, Sessions 1-440+→1-441+).
- **`BACKLOG.md`** updated: the issue #130 sequencing item now records planning as DONE, with
  implementing Slice 1 as the next step.

### 2026-07-30 · [issue #131] Add diagram image/print export to the Pedigree Diagram tab (Session 440)
- **Deliverable:** Owner-picked from the Phase 0 priorities list (over planning issue #130, the
  `CLAUDE.md` `NOT_CRAN` doc fix, and NPRC outreach review). TDD phases: PRE-RED (verified
  `visNetwork::visExport()` hands-on: bundled offline JS deps, single-format-per-widget limit) → a
  separate pre-RED `AskUserQuestion` for the export-format scope decision (PNG chosen over PDF/JPEG) →
  RED (1 failing test) → GREEN (implementation + documentation phase) → REFACTOR (skipped,
  owner-confirmed nothing to restructure).
- **Fix:** added `visNetwork::visExport(type = "png", name = "pedigree_diagram", label = "Export
  Diagram (PNG)")` to the existing pipe chain in `R/modPedigree.R`'s `renderVisNetwork()` block. Zero
  new package dependencies — `visExport()`'s JS libraries (FileSaver/Blob/canvas-toBlob/html2canvas/
  jsPDF) ship bundled inside the already-a-dependency `visNetwork` package as htmlwidget deps, confirmed
  offline/no-CDN by locating the files in the installed package tree and by inspecting the rendered
  widget's `deps` array inside a `shiny::testServer()` session.
- **Design decision:** `visExport()` supports exactly one export format per widget (`graph$x$export <-
  export`, a single overwritten slot, confirmed from its R source) — surfaced as its own pre-RED
  `AskUserQuestion` (PNG vs PDF vs JPEG); owner picked PNG, matching the issue's own named example.
- **Test:** new `test_that("modPedigreeServer's diagram widget offers a PNG export button", ...)` in
  `tests/testthat/test_modPedigree.R` asserts the widget's raw JSON payload (`output$pedigreeDiagram`
  inside `testServer()`) contains the export config; confirmed to fail for the expected reason before
  the fix (all 3 assertions FALSE).
- **Documentation phase** (per `CLAUDE.md`'s Tutorial/article documentation checklist): added a "Data
  Table and Diagram" section to `vignettes/manual_components/_pedigree_browser.Rmd` describing the
  Diagram tab and its new export button, scoped to this session's feature (full Diagram-tab tutorial
  coverage remains issue #139's separate scope); render-verified via `rmarkdown::render()` of
  `a3manual.Rmd`, confirming the new text appears in the rendered output.
- **Verification:** regression suite 0 failed/0 error/0 warning (3290 passed, 182 skipped);
  `devtools::check()` 0 errors/0 warnings/0 notes. Phase 3E runtime smoke test: live `shinytest2`/
  `chromote` session confirmed the button is genuinely functional, not just error-free — clicking it
  produced a real `pedigree_diagram.png` file (17,374 bytes) with a valid PNG magic-number signature,
  captured by overriding the chromote session's download behavior to a temp directory (`get_download()`/
  `expect_download()` don't apply, since this is a purely client-side JS download with no backing Shiny
  output). `PROJECT_LEARNINGS.md` Learnings 418/419 added. `BACKLOG.md`'s pedigree-diagram-audit
  follow-ups section updated (issue #131 item resolved). `CLAUDE.md`'s learnings-count cross-reference
  updated (417→419, Sessions 1-439+→1-440+). **Issue #131 closed via `gh api`** (per the established
  `gh-pr-edit-projectcards-workaround`), with a closing comment summarizing the fix and verification.

### 2026-07-30 · [BL-test-e2e-data-ready] Fix `test-e2e-data-ready.R`'s hollow "appUI includes data-ready.js" test (Session 439)
- **Deliverable:** Owner-picked from the Phase 0 priorities list (over planning issue #130, issue #131,
  and NPRC outreach review). TDD phases: PRE-RED (root-cause reproduction, established-pattern reuse) →
  RED (rewrote the assertion, proved it can fail) → GREEN (no production code change needed) → REFACTOR
  (skipped, owner-confirmed nothing to restructure).
- **Root cause:** the existing test computed `ui_html <- as.character(app_ui)` but never asserted
  against it — its only expectation checked `inherits(app_ui, "shiny.tag.list")`, which is
  unconditionally true regardless of whether `data-ready.js` is actually included. Compounded by
  `PROJECT_LEARNINGS.md` Learning 415 (S438): `as.character()` on a raw `tagList`/`shiny.tag` silently
  drops all `tags$head(...)` content anyway, so even a content-based `as.character()`/`grepl()` assertion
  would have been unreliable.
- **Fix:** rewrote the test to assert `htmltools::renderTags(app_ui)$head` contains both a
  distinguishing marker (`"setDataReady"`) and the full `data-ready.js` file text, mirroring
  `test_modSummaryStats_popovers.R`'s established shim-inclusion test (S438).
- **RED proof (no new feature exists to drive a natural failure):** temporarily disabled `R/appUI.R`'s
  `includeScript(dataReadyJS)` line (`if (FALSE && file.exists(dataReadyJS)) ...`), ran the rewritten
  test, confirmed both new assertions failed for the expected reason, then reverted —
  `git diff --stat R/appUI.R` confirmed byte-identical to `HEAD` after revert, so this session shipped a
  test-only diff.
- **Verification:** regression suite 0 failed/0 error/0 warning (4006 passed, 170 skipped, with
  `NOT_CRAN=true` set — see Learning 417 below); `devtools::check()` 0 errors/0 warnings/0 notes. Phase
  3E runtime smoke test: n/a — test-only change, no runtime behavior affected (stated explicitly per
  `SESSION_RUNNER.md` §3E, not silently skipped).
- **Incidental discovery:** `CLAUDE.md`'s documented "Fast single-file test" one-liner doesn't set
  `NOT_CRAN`, so running it against any file with a top-level `skip_on_cran()` (as in
  `test-e2e-data-ready.R:10`) silently skips the entire file rather than running it — filed to
  `BACKLOG.md` per the established "report, don't fix mid-session" precedent (Learning 382/407), not
  fixed here. `PROJECT_LEARNINGS.md` Learning 417 added. `BACKLOG.md`'s Housekeeping section updated
  (the fixed item resolved; the new `NOT_CRAN` gap filed). `CLAUDE.md`'s learnings-count cross-reference
  updated (416→417, Sessions 1-438+→1-439+).

### 2026-07-30 · [issue #140] Fix shinyBS popover/tooltip destroy defect under Bootstrap 4.6.0 (Session 438)
- **Deliverable:** Owner-picked from the Phase 0 priorities list (over planning issue #130, issue #131,
  and NPRC outreach review). TDD phases: PRE-RED (parallel research of 3 candidate fix directions named
  in the issue, then an owner-picked approach) → RED (2 failing tests) → GREEN (implementation, plus one
  in-flight test-design fix) → REFACTOR (skipped, owner-confirmed nothing to restructure).
- **Root cause:** shinyBS 0.65.0's `shinyBS.js` calls `$id.popover("destroy")` / `$id.tooltip("destroy")`
  unconditionally before initializing a new instance. Bootstrap 4 renamed `destroy` → `dispose`;
  `_jQueryInterface`'s regex no longer recognizes `"destroy"` as a no-op, so it creates a new (empty)
  instance and then throws looking up `data["destroy"]`, one line before the real init call — fires
  every time under this app's pinned `bslib::bs_theme(version = 4L, bootswatch = "flatly")`
  (`R/appUI.R`), not just "no instance yet."
- **Research (3 parallel agents, before the pre-RED `AskUserQuestion`):** Option A (vendor/patch
  `shinyBS.js`, Effort S — found 4 unguarded destroy calls, not just the 1 reported; requires
  documenting a vendored modified GPL-3 file inside this MIT package, stale-on-update risk). Option B
  (JS shim overriding `shinyBS.addTooltip`, Effort S — root-caused the defect; both `popify()`'s direct
  call and `addPopover()`'s Shiny custom-message path read that one mutable global at call time, so one
  override fixes both; no third-party file modified) — **chosen**. Option C (migrate to
  `bslib::tooltip()`/`popover()`, Effort L not M — confirmed by direct reproduction that both hard-require
  Bootstrap ≥5 via `tag_require()`, forcing a whole-app BS4→5 theme migration far outside this issue's
  scope; the 3 server-side `addPopover()` sites also have no clean bslib equivalent) — declined as
  out-of-scope for a single bugfix session.
- **Fix:** new `inst/www/js/shinyBS-popover-fix.js` — a self-polling IIFE that waits for
  `window.shinyBS.addTooltip`, then overrides it with a corrected version that only calls
  `destroy` when an existing `bs.tooltip`/`bs.popover` plugin instance is attached (bounded to 40
  poll attempts so it can't loop forever if shinyBS is absent, a `Suggests` dependency). Included via
  `tags$head(includeScript(...))` in `R/appUI.R`, the same mechanism already used for `data-ready.js`.
  2 new tests in `tests/testthat/test_modSummaryStats_popovers.R`. Added `htmltools` to `Suggests`
  (test-only dependency for `htmltools::renderTags()`).
- **In-flight test-design finding:** the RED-phase "appUI includes the shim" test initially asserted
  against `as.character(appUI())`, which passed for the WRONG reason (matched shinyBS's own unrelated
  inline invocation script, not the new shim) because `as.character()` silently drops ALL
  `tags$head(...)` content on a raw tag tree. Fixed to assert against `htmltools::renderTags(app_ui)$head`
  instead. See `PROJECT_LEARNINGS.md` Learning 415 — also surfaced that the project's pre-existing
  `test-e2e-data-ready.R` "appUI includes data-ready.js" test has the identical gap (zero real content
  coverage); reported to `BACKLOG.md` rather than fixed here (unrelated file, out of scope).
- **Verification:** 2 new unit tests pass; full regression suite exact-clean (0 failed/0 error/0
  warning, 3287 passed — up from 3282 — 182 skipped); `devtools::check()` 0 errors/0 warnings/0 notes
  (after adding `htmltools` to `Suggests`, which fixed one transient WARNING). **Phase 3E live
  `shinytest2`/`chromote` smoke test** (mandatory — changes JS/dependency-loading behavior): zero
  console errors of any kind on the Summary Statistics tab, AND direct DOM inspection confirms a real
  `bs.popover` instance now attaches to both a `popify()`-wrapped download button and all 3
  `addPopover()` targets (`mkBox`/`zscoreBox`/`guBox`) — popovers/tooltips are now actually functional,
  not just error-free, per Learning 414's precedent (verify the underlying claim, not just the absence
  of the originally-reported error).
- **GitHub issue #140 closed**, with the fix/verification summary posted as a closing comment (a
  placeholder "test" comment briefly posted while closing was edited in place with the real summary,
  not left as noise). `BACKLOG.md`'s Housekeeping item updated to record the resolution.
  `PROJECT_LEARNINGS.md` Learnings 415 (`as.character()` drops `tags$head()` content;
  `htmltools::renderTags()` is the correct tool) and 416 (`shinytest2::AppDriver$get_logs()`, not
  `$get_log()` — the wrong name fails with an opaque `attempt to apply non-function`, not a clear
  "method not found") added. `CLAUDE.md`'s learnings-count cross-reference updated (414→416, Sessions
  1-437+→1-438+).

### 2026-07-30 · [BL-shinyBS-console-error] Fix pre-existing "shinyBS is not defined" JS console error (Session 437)
- **Deliverable:** Owner-picked from the Phase 0 priorities list (over Planning issue #130, picking up
  issues #131-#139, and NPRC outreach -- owner first asked whether outreach could run in parallel with
  another item; declined per the "1 and done" / FM #26 rule). TDD phases: PRE-RED (root-cause
  diagnosis) → RED (2 failing tests) → GREEN (implementation) → REFACTOR (skipped, owner-confirmed
  nothing to restructure).
- **Root cause:** `R/modSummaryStats.R` accesses shinyBS only via `shinyBS::popify()`/
  `shinyBS::addPopover()` (`::`), never `library(shinyBS)`. shinyBS's `.onAttach()` hook — which
  registers the `"sbs"` `shiny::addResourcePath()` serving `shinyBS.js`/`shinyBS.css` — only fires on
  package *attach*, never on the namespace *load* that `::` triggers. Confirmed experimentally:
  `"sbs" %in% names(shiny::resourcePaths())` was `FALSE` after `pkgload::load_all()` + building
  `modSummaryStatsUI()`. The unloaded `shinyBS.js` meant `popify()`'s/`addPopover()`'s inline
  `shinyBS.addTooltip(...)` script threw `ReferenceError: shinyBS is not defined`.
- **Fix:** new `R/zzz.R` with `.onLoad(libname, pkgname)` calling `shiny::addResourcePath("sbs",
  system.file("www", package = "shinyBS"))`, guarded by `requireNamespace("shinyBS", quietly = TRUE)`
  (shinyBS is a `Suggests` dependency). 2 new unit tests in
  `tests/testthat/test_modSummaryStats_popovers.R`: resource path is registered after package load
  (`skip_if_not_installed("shinyBS")`); `.onLoad()` doesn't error when shinyBS is unavailable (via
  `mockery::stub` on a local copy of the dot-prefixed internal function, since `.onLoad` isn't exported
  even under `pkgload::load_all()`'s `export_all` default).
- **Verification:** regression suite exact-clean (0 failed/0 error/0 warning, 3282 passed, 182
  skipped); `devtools::check()` 0 errors/0 warnings/0 notes. **Phase 3E runtime smoke test (mandatory
  — this changes dependency-loading behavior):** live `shinytest2`/`chromote` app launch confirmed the
  `ReferenceError: shinyBS is not defined` no longer occurs.
- **Discovery mid-verification:** the live smoke test surfaced a second, previously-hidden,
  *unrelated* defect — shinyBS 0.65.0's JS is incompatible with this app's bundled Bootstrap 4.6.0
  popover plugin (`shinyBS.js:207`'s defensive `$id.popover("destroy")` call throws `TypeError: No
  method named "destroy"` before the actual `$id.popover(opts)` init call on the next line, so
  popovers/tooltips remain completely non-functional — confirmed via DOM inspection, 0 of the
  popover-wrapped buttons ever get a `bs.popover` plugin instance attached — same functional
  brokenness as before this fix, just a different console error). Not fixed this session, per
  `PROJECT_LEARNINGS.md` Learning 382/407's scope-discipline precedent (owner-confirmed via
  `AskUserQuestion`) — filed as
  [issue #140](https://github.com/rmsharp/nprcgenekeepr/issues/140) instead. `BACKLOG.md`'s
  Housekeeping item updated to reflect both the fix and the new follow-up issue.

### 2026-07-30 · [ad hoc] Triage pedigree-diagram-vs-kinship2 audit recommendations (Session 436)
- **Deliverable:** Owner-picked (free-text response, not a rendered `AskUserQuestion` option) from
  S435's priorities list: triage `docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`'s
  8 recommendations into GitHub issues, matching the S419→S422 audit→triage precedent. TDD Phase:
  N/A — pure triage/issue-filing + `BACKLOG.md`/`PROJECT_LEARNINGS.md` documentation, no `R/`/`tests/`
  code touched.
- **Process:** owner directed filing **all 8** recommendations as issues in one free-text reply,
  including Recommendations 4–7, which the audit itself scored "no action" (data-model-gated, or an
  already-ratified Dragon-P3 scope tradeoff) — each such issue body preserves the audit's original
  disposition text verbatim rather than silently reframing it as newly-endorsed. Owner also gave an
  explicit priority order (2, 3, 4, 1, 8, 7, then 5 unranked, then 6 explicitly deprioritized/delayed)
  that inverts the audit's own suggested ordering (which rated Finding #1 highest); recorded as-given.
  Mid-session, owner also directed a broader goal — overlay kinship2's genetics-domain naming
  conventions onto the pedigree data model where applicable when these are implemented, and build
  test pedigree fixtures with the corresponding added columns — folded into the two
  data-model-adding issue bodies (#133's `affected` argument convention, #137's `relation` argument
  convention) as forward-looking guidance, not treated as license to implement in this session.
- **Result:** filed GitHub issues #131 (diagram image/print export, Finding #3), #132 (in-app
  shape-to-sex legend, Finding #6, also resolves plan Dragon P5), #133 (affected/phenotype/genotype
  status encoding, Finding #2, data-model gated), #134 (verify inbreeding-loop/consanguinity
  rendering, Finding #1, resolves plan Dragon P2 / `PROJECT_LEARNINGS.md` Learning 410), #135 (hover
  tooltips + search/highlight, Recommendation #8), #136 (name labels instead of ID-only, Finding #8,
  data-model gated), #137 (twin/zygosity encoding, Finding #5, data-model gated), #138 (full-colony
  rendering beyond the 1,500-node cap, Finding #7, `low priority` GitHub label applied). All labeled
  `enhancement`, matching this repo's existing convention (verified via `gh label list` before
  filing, per `PROJECT_LEARNINGS.md` Learning 387's precedent). Replaced `BACKLOG.md`'s
  `## Pedigree diagram vs kinship2 audit follow-ups` per-item candidates with a resolved summary
  paragraph pointing at the 8 issue numbers (tracked there, not in `BACKLOG.md`), matching S422's
  own collapse convention. Added `PROJECT_LEARNINGS.md` Learning 411 (owner can override an audit's
  own "no action" disposition; preserve the audit's original reasoning in the filed issue). Updated
  `CLAUDE.md`'s learnings-count cross-reference (410→412, Sessions 1-435+→1-436+). Also backfilled
  `HANDOFFS.md`'s S435 receipt `commit: pending` placeholder to `db00a40d` (a Phase-0 HANDOFFS
  reconcile item flagged but not fixed during this session's own orientation).
- **Mid-session scope addition:** a second owner steering message directed that any plan
  implementing these follow-up issues must include updating the relevant tutorial/article
  (`vignettes/articles/colony-manager-guide.qmd` and/or `vignettes/manual_components/
  _pedigree_browser.Rmd`) describing the feature's purpose and use. Checking whether the
  already-shipped issue #129 base feature already followed this found it had not — zero mentions of
  the Diagram tab in any vignette/article (`grep` across all `.Rmd`/`.qmd` sources returns nothing).
  Filed **issue #139** to track that pre-existing documentation gap rather than fixing it in this
  triage-only session (per `PROJECT_LEARNINGS.md` Learning 407's precedent). Added a comment to each
  of issues #131–#138 recording the same documentation-scope expectation. Recorded the convention
  durably as `CLAUDE.md`'s new "Tutorial/article documentation checklist" (modeled on the existing
  issue-#120 citation checklist). Added `PROJECT_LEARNINGS.md` Learning 412 (a forward-looking
  directive is worth checking against current state, not just applied prospectively).
- **Runtime smoke test:** n/a — no `R/`/`tests/` code touched; pure triage/issue filing +
  `BACKLOG.md`/`PROJECT_LEARNINGS.md`/`CLAUDE.md` documentation.

### 2026-07-30 · [ad hoc] Audit: pedigree diagram (issue #129) vs kinship2 feature comparison (Session 435)
- **Deliverable:** `docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`, a
  17-point capability-comparison audit (`AUDIT_WORKSTREAM.md`) between the just-shipped
  issue #129 pedigree-diagram feature (visNetwork-based Diagram tab, Slices 1+2) and
  kinship2's pedigree-drawing feature set. Owner-directed (not from the prior GitHub-issue
  sequencing chain, not a TDD/code-implementation session — no `R/`/`tests/` code touched).
  Ran a 3-agent research-then-synthesize workflow (one agent surveyed the shipped
  implementation firsthand, one researched kinship2's actual feature set from its CRAN
  manual/vignettes/GitHub source, one synthesized both into the comparison), then
  independently re-verified every nprcgenekeepr-side citation against live source and
  re-verified three consequential kinship2 claims via direct `WebFetch` against
  CRAN/GitHub (the `sex` argument's 4 codes, the sex-to-shape `polylist` +
  deceased-slash + `arcconnect()` duplicate-instance-arc source, and that no
  `plot.pedigreeList` S3 method exists in the current package — confirmed live against
  kinship2's own `NAMESPACE`, correcting the ratified plan's own survey-table citation).
  8 findings: 4 kinship2-only (affected-status shading, twin/zygosity encoding, legend
  functions, node-label substitutability — the latter two gated by nprcgenekeepr's own
  data model lacking a name/affected field), 1 nprcgenekeepr-only (click-to-navigate +
  free pan/zoom — architecturally impossible for kinship2's static base-graphics
  design), 1 both-lack (no full-colony/arbitrary-scale rendering solution in either
  package), and 1 finding (inbreeding-loop/consanguinity rendering) that is the audit's
  headline result: the ratified plan's own Dragon P2 (required Slice-1 verification)
  was never actually resolved across S433 or S434's close-outs — recorded as
  `PROJECT_LEARNINGS.md` Learning 410. Added 4 candidate follow-up items to
  `BACKLOG.md` (`## Pedigree diagram vs kinship2 audit follow-ups`), awaiting owner
  triage before any are filed as GitHub issues, per the same audit→triage pattern
  S419→S422 used for the prior capability audit. No action implied on the
  visNetwork-vs-kinship2 technology decision (D2), which stands as ratified.

### 2026-07-30 · [issue #129] Implement Slice 2: click-to-navigate interactivity (Session 434, closes issue #129)
- **Deliverable:** Implemented the ratified plan's Slice 2
  (`docs/planning/issue129-pedigree-diagram-tree-visualization-plan.md` §4).
  Clicking a node in the Diagram tab now re-centers the population on that
  animal, re-driving the same `focalIds` reactive path the existing
  focal-animal textarea already drives (`processedPedigree` →
  `pedigreeData`) — no duplicate trim logic. `R/modPedigree.R`'s
  `output$pedigreeDiagram` gained `visNetwork::visEvents(click = ...)`,
  JS-interpolating `session$ns("pedigreeDiagram_click")` (never a bare
  `ns()`, Learning 405); a new `observeEvent(input$pedigreeDiagram_click,
  ...)` reads the clicked node id(s) and writes them into `focalIds()`,
  guarded (`req(length(...) > 0L)`) against a background (no-node) canvas
  click, which sends an empty `nodes.nodes` array. One vertical slice,
  strict TDD PRE-RED → RED → GREEN (REFACTOR skipped, owner-gated, already
  minimal), all phase transitions gated via `AskUserQuestion`.
  **Pre-RED (Dragon P4) found and corrected a real gap in the ratified
  plan's own mechanism assumption:** the plan stated visNetwork exposes
  click events as a Shiny input "without extra JavaScript" — grepping the
  installed `visNetwork` 2.1.4 JS source (`htmlwidgets/visNetwork.js`)
  showed no such auto-binding exists, and a live throwaway
  `shinytest2`/`chromote` app confirmed `visEvents(click = ...)` must be
  wired explicitly, and that a background click yields `NULL` on the R
  side (see `PROJECT_LEARNINGS.md` Learning 408). RED: 3 new
  `shiny::testServer()` assertions in `tests/testthat/test_modPedigree.R`
  (click sets `focalAnimals()`, click recomputes the trim via `pedigree()`,
  a background click is a no-op), confirmed failing for the right reason
  before GREEN. Verify: full clean regression read (0 failed/0 error/0
  warning, 3280 passed, up from 3275; 182 skipped, up from 181);
  `devtools::check()` raw log `Status: OK` (0 errors/0 warnings/0 notes).
  Live E2E click-through smoke test (Phase 3E,
  `tests/testthat/test-e2e-pedigree-module.R`) confirmed the Table tab
  visibly updates after a Diagram-tab node click — but only after
  discovering and working around a second real finding: `DT::renderDT`'s
  output is suspended while its `tabPanel` is not the active tab (Shiny's
  `outputOptions(suspendWhenHidden = TRUE)` default), so the test must
  switch back to the Table tab before asserting its content, not read it
  while still on the Diagram tab (Learning 409). NEWS.Rmd's Slice-1 bullet
  amended in place to describe the now-shipped click-to-navigate behavior
  (rendered to NEWS.md). **Both slices of issue #129 are now shipped;
  issue #129 closed** via `gh issue close` with a summary comment covering
  both sessions' work.

### 2026-07-30 · [issue #129] Implement Slice 1: core pedigree diagram render (Session 433)
- **Deliverable:** Implemented the ratified plan's Slice 1
  (`docs/planning/issue129-pedigree-diagram-tree-visualization-plan.md` §4).
  New exported `makePedigreeDiagramData(ped)` (`R/makePedigreeDiagramData.R`)
  is a pure function converting a pedigree data frame into a
  `visNetwork`-ready `list(nodes, edges)`: sex-shape mapping (F→dot,
  M→square, H→star, U→triangle), `level = gen` for hierarchical layout,
  directed sire/dam→child edges. `R/modPedigree.R`'s pedigree-table area is
  now a `tabsetPanel("Table"/"Diagram")` (mirroring `modPyramid.R`'s
  existing Plot/Statistics precedent); the new Diagram tab renders via
  `visNetwork::renderVisNetwork()` + `visHierarchicalLayout(direction =
  "UD", sortMethod = "directed")`, with a 1,500-node size guard (Dragon P3)
  that shows an informative message instead of an unbounded render above
  that threshold — preserving D3's invariant that the diagram always shows
  exactly the same population the Table tab does. `visNetwork` added to
  `DESCRIPTION` Imports (the project's first GPL dependency, arms-length
  `Imports:` of an MIT-licensed package, per Dragon P6). One vertical
  slice, strict TDD PRE-RED → RED → GREEN (REFACTOR skipped, owner-gated,
  already clean), all phase transitions gated via `AskUserQuestion`.
  Pre-RED resolved Dragons P1 (visNetwork installed + API surface
  confirmed live), P2 (a real 145-member known-loop case found in
  `examplePedigree` for future reference), P5 (shape choices confirmed
  against live `visNetwork` docs and real `sex` factor level counts).
  NEWS.Rmd gained a Slice-1-scoped bullet (rendered to NEWS.md).
  Incidentally discovered (via this session's own `devtools::check()`
  verification, not this session's diff) two pre-existing, unrelated
  spelling-NOTE words from issue #125's S423-era work (`deduplicated`,
  `selectable`) undetected since S421 — fixed inline alongside this
  session's own `visNetwork` WORDLIST addition rather than deferred to
  `BACKLOG.md`, a deliberate deviation from `PROJECT_LEARNINGS.md` Learning
  382's precedent, recorded as Learning 407 for owner review. Also
  discovered a pre-existing, unrelated `shinyBS is not defined` JS console
  error (not fixed — filed to `BACKLOG.md` per Learning 382, contrast case
  for Learning 407). `_pkgdown.yml` reference index updated for the new
  exported function. `PROJECT_LEARNINGS.md` gained Learnings 405–407.
- **Verify:** RED confirmed 13 new/extended assertions failed for the
  correct reason (function/UI/output didn't exist) before GREEN. Full
  clean regression read: 0 failed/0 error/0 warning, 3275 passed, 181
  skipped (up from the 3198/179 S412-era baseline). `devtools::check()`:
  raw log `Status: OK`, 0 errors/0 warnings/0 notes (read from the raw
  `Status:` line per Learning 382, not the colored summary alone). Live
  `shinytest2`/`chromote` E2E smoke test against the bundled
  `obfuscated_rhesus_mhc_ped.csv` fixture (375 rows): Diagram tab renders
  a bound `visNetwork` widget with no diagram-related console error;
  queried the live vis.js `DataSet` instance directly (canvas-rendered
  widgets have no DOM-inspectable node/edge content — Learning 406) and
  confirmed a known real trio's (`EBG407`/`U5VLXP`/`PH0IXL`) sex-shapes and
  directed sire/dam→child edges render correctly.

### 2026-07-29 · [issue #129] Architecture plan: pedigree-diagram/tree visualization (Session 432)
- **Deliverable:** `docs/planning/issue129-pedigree-diagram-tree-visualization-plan.md`
  — following `ARCHITECTURE_WORKSTREAM.md` (chosen over `DESIGN_WORKSTREAM.md`:
  a technology-fit/data-model/module-contract decision, not a layout
  decision). Evidence base: a 4-agent parallel research `Workflow`
  (pedigree data-flow/rendering-surface inventory; CRAN-live-verified
  diagram-library technology survey; module-contract + app-wiring review;
  prior-plan-convention + full issue/audit-text research), plus firsthand
  verification of every load-bearing claim, per `PROJECT_LEARNINGS.md`
  Learning 399's standing instruction for this issue specifically. Ratified
  4 scope decisions via `AskUserQuestion`: **D1** extend `R/modPedigree.R`
  with a new "Diagram" tab (matching `modPyramid.R`'s existing Plot/
  Statistics `tabsetPanel` precedent), not a new module; **D2** `visNetwork`
  as the rendering library (MIT-licensed, native Shiny interactivity,
  hand-built pedigree semantics) over kinship2/pedtools/ggpedigree; **D3**
  the diagram reuses `modPedigree.R`'s existing strict-lineal
  ancestors-union-descendants trim (`pedigreeData()`), not the broader
  connected-component-with-collaterals semantics; **D4** multi-slice —
  Slice 1 (core diagram render) is the next implementation session, Slice 2
  (click-to-navigate interactivity) is deferred to a separate future
  session. A second, independent adversarial-verification `Workflow` (2
  agents: a citation audit re-deriving every `file:line` citation from live
  source; an independent live CRAN fact-check of the technology-survey
  table) ran before ratification — found and fixed 1 blocking + 4 minor
  citation errors and 2 moderate technology-survey undercounts (none
  changed the D2 recommendation); see `PROJECT_LEARNINGS.md` Learning 404.
  No `R/`/`tests/`/`man/`/`NAMESPACE`/`data/` content changed — planning
  deliverable only.
- **Verify:** N/A (planning session; no code, no runtime behavior changed).

### 2026-07-29 · [issue #127] Surface correctUnknownParentMeanKinship()'s silently-dropped flagged list (Session 431)
- **Deliverable:** Implemented the ratified plan
  (`docs/planning/issue127-surface-uncorrected-kinship-flag-plan.md`). `reportGV()`'s
  `$report` gains a boolean `flagged` column (`TRUE` for a one-unknown-parent
  animal left uncorrected for lack of an eligible breeding-age peer cohort,
  `FALSE` otherwise), reaching the live Genetic Value DT table and both CSV
  downloads with no other plumbing changes, via the same `cbind()` mechanism
  the existing `parentage` column uses. `R/gvaConvergence.R`'s identical,
  deliberately-deferred discard is now documented with a comment pointing at
  the issue #127 D2 comment. One vertical slice, strict TDD PRE-RED → RED →
  GREEN (REFACTOR skipped, owner-gated, already clean), all phase transitions
  gated via `AskUserQuestion`.
- **Verify:** RED confirmed all 7 new/extended assertions failed for the
  correct reason before GREEN. `devtools::check(vignettes=FALSE)`: 0
  errors/0 warnings/0 notes (fixed a self-introduced R CMD check WARNING
  along the way — an invalid `\link{}` to a `@noRd` function, corrected to
  match the project's existing `\code{...()}` convention). Full clean
  regression read via the documented recipe reproduces the established
  baseline exactly (0/0/0, 3250 passed/179 skipped); a broader
  `NOT_CRAN=true` sweep also came back clean. Phase 3E: live-drove the
  modular Shiny app (`shinytest2`/`chromote`) and confirmed `flagged` renders
  as a real, sortable DT column in the live Genetic Value rankings table.
- **Bundled-data regeneration finding (scope-gated via `AskUserQuestion`):**
  regenerating `qcPedGvReport`/`pedWithGenotypeReport` via the documented
  recipe does not reproduce the S210-established golden-master `fg` value in
  this environment (R 4.6.1) — confirmed via a stash/unstash differential
  test to be pre-existing RNG/environment drift, not caused by this
  session's own change (it reproduces `52.7641277282`, matching S206's own
  original "non-reproducible" value almost exactly). Owner chose full regen
  + re-pin over a deterministic-splice workaround. A repo-wide grep before
  declaring GREEN done found the SAME stale value independently hardcoded in
  3 more assertions in `tests/testthat/test_summary.nprcgenekeeprGV.R` (not
  named in the plan's own blast-radius analysis) — fixed all 3. See
  `PROJECT_LEARNINGS.md` Learnings 402–403.
- **Docs:** `man/reportGV.Rd` (new `flagged` `@return` clause),
  `man/qcPedGvReport.Rd`/`man/pedWithGenotypeReport.Rd` (incidental,
  unrelated pre-existing staleness fixed as a `devtools::document()`
  byproduct — top-level list length `11` → `14`, already true before this
  session's regen). `NEWS.Rmd`/`NEWS.md` updated. Citation checklist: checked
  `inst/extdata/ui_guidance/population_genetics_terms.html` directly — no new
  entry needed (confirmed, not assumed: no existing entry covers `parentage`
  or the gu de-inflation "Undetermined" policy either, so `flagged` follows
  the same precedent). `BACKLOG.md` sequencing item updated; `CLAUDE.md`
  learning count corrected.

### 2026-07-29 · [issue #127] Plan surfacing correctUnknownParentMeanKinship()'s silently-dropped flagged list (Session 430)
- **Deliverable:** `docs/planning/issue127-surface-uncorrected-kinship-flag-plan.md`,
  ratified via `AskUserQuestion`. Architecture-workstream planning session
  (per S428 precedent) for the next issue in the owner-ratified #126/#127/#129/#130
  sequencing. A parallel research fan-out (4 agents) plus firsthand verification
  found the issue's own framing accurate (no citation drift, unlike #126) and a
  real, non-hypothetical instance of the gap: 4 of 327 animals in the bundled
  `examplePedigree` (`5IAFMK`/`BCJJKN`/`GCBYDW`/`KZM9RB`) are silently left
  uncorrected today. Design: add a boolean `flagged` column to `reportGV()`'s
  `$report` via the same `cbind()` mechanism the existing `parentage` column
  uses (`R/reportGV.R:293`), reaching the live Genetic Value DT table and both
  CSV downloads (`R/modGeneticValue.R:379-384`, `:491-501`) with no other
  plumbing. Ratified scope decisions: boolean column format; `gvaConvergence()`
  (a second, independent caller with the identical discard) deferred as
  out-of-scope, to be recorded as an issue #127 comment at Pre-RED; no
  additional Shiny notification. A second, independent adversarial-verification
  workflow pass re-checked every cited line number against live source and
  re-executed both worked examples (the real `examplePedigree` case and a
  hand-built 14-row synthetic fixture proven to run through the full
  `reportGV()` pipeline) via `Rscript`, catching and fixing one blocking
  citation error (a wrong file name) and several minor ones before
  ratification. Added `PROJECT_LEARNINGS.md` Learning 401 (a unit-test-scale
  synthetic pedigree with a bare `NA` parent is not sufficient to exercise
  `reportGV()`'s full pipeline — `calcFEFG()`/`calcFounderContributions()`
  have stricter requirements than the correction function alone). No `R/`,
  `tests/`, `man/`, `NAMESPACE`, or `data/` content changed — implementation
  is a separate future session's RED phase.

### 2026-07-29 · [issue #126] Implement kinship/genome-uniqueness distribution-shape statistics (Session 429)
- **Deliverable:** Implemented the ratified plan
  (`docs/planning/issue126-distribution-shape-stats-plan.md`), one vertical
  slice. Closes issue #126. New exported functions `calcSkewness()`/
  `calcKurtosis()` (`R/calcSkewness.R`, `R/calcKurtosis.R`) compute the
  bias-adjusted Fisher-Pearson skewness (`G1`) and excess kurtosis (`G2`)
  coefficients (Joanes & Gill 1998, "Method 2"), `NA`-guarded for `n <= 2`/
  `n <= 3` and zero-variance degeneracy. `R/modSummaryStats.R`'s live
  distribution table (`distTbl`) and `R/makeGeneticSummaryTable()` both gain
  Skewness/Kurtosis columns for Mean Kinship and Genome Uniqueness;
  `modSummaryStatsServer()`'s return list gains `mkShape`/`guShape`
  reactives (matching the existing `mkSummary`/`guSummary` precedent).
  `summarizeKinshipValues()` is unchanged, per the plan's ratified scope
  decision (deferred, recorded on the issue itself pre-RED).
- **Process:** Full strict TDD (RED -> GREEN, REFACTOR skipped -- code
  already clean), each phase gated via `AskUserQuestion`. RED added
  `tests/testthat/test_calcSkewness.R`/`test_calcKurtosis.R` (new) and
  extended `test_makeGeneticSummaryTable.R`/`test_modSummaryStats_parity.R`/
  `test_moduleContract.R`; all new/changed assertions failed for the correct
  reason, every pre-existing assertion in each touched file stayed green.
  One pre-existing test fixture (`test_makeGeneticSummaryTable.R`'s
  vocabulary-parity test) needed widening from n=3 to n=4 rows -- a real,
  correct interaction with the plan's own Dragon P3 (kurtosis needs n > 3),
  not a regression.
- **Verify:** Targeted + clean full regression read 0 failed/0 error/0
  warning, 3246 passed (this environment's true pre-session baseline on the
  unchanged prior commit is 3210, not the 3928 previously recorded in
  S427/S428's `HANDOFFS.md` -- confirmed via `git stash`, not caused by this
  session; flagged, not chased further). `devtools::check()`: 0 errors/0
  warnings, 1 NOTE (the same pre-existing `deduplicated`/`selectable`
  spelling gap tracked since S415, unrelated to this session).
  `inst/WORDLIST` updated (`skewness`, `kurtosis`, `Pearson`, `Joanes`,
  `reactives`, hand-added). `_pkgdown.yml`'s "All exposed functions" group
  updated with both new exports (a pre-existing repo-wide guard test,
  `test_pkgdown_reference_config.R`, caught the omission). `lintr` clean on
  all touched files (one targeted `# nolint: object_name_linter.` for
  `na.rm`, matching base R's own convention and the ratified plan's spec).
  Citation checklist (issue #120): `inst/extdata/ui_guidance/
  population_genetics_terms.html`'s GU/MK entries updated with a skewness/
  kurtosis explanation. `NEWS.Rmd`/`NEWS.md` updated. Phase 3E runtime smoke
  test: live app driven Input -> Genetic Value Analysis -> Summary
  Statistics; confirmed real Skewness/Kurtosis values render for both Mean
  Kinship and Genome Uniqueness on the bundled `obfuscated_rhesus_mhc_ped.csv`
  fixture, with the existing Min/1st Qu./Mean/Median/3rd Qu./Max columns and
  the founder/Ne blocks unaffected.
- Issue #126 closed on GitHub with a summary comment.

### 2026-07-29 · [issue #126] Plan kinship/genome-uniqueness distribution-shape statistics (Session 428)
- **Deliverable:** `docs/planning/issue126-distribution-shape-stats-plan.md` --
  ratified plan (via `AskUserQuestion`) to add bias-adjusted skewness/kurtosis
  (Joanes & Gill 1998, `G1`/`G2`) for mean kinship and genome uniqueness to the
  live Summary Statistics distribution table (`R/modSummaryStats.R`) and the
  `makeGeneticSummaryTable()` script-user-parity helper, as one vertical
  slice/one session. Key finding: the issue's own citations pointed at the
  wrong surfaces -- `makeGeneticSummaryTable()` has no runtime caller (a dead
  helper, same class of drift as issue #118's Dragon F1) and
  `summarizeKinshipValues()` operates on a different population (simulated
  pairwise kinship values from an unrelated Monte Carlo vignette workflow, not
  the colony-wide per-animal distribution the PDF's Dimension 3 actually asks
  about); the real live surface is `R/modSummaryStats.R:590-714`.
  `summarizeKinshipValues()` is explicitly deferred, not implemented, recorded
  as a follow-on decision on the issue itself at the implementing session's
  Pre-RED step. Worked example computed on the bundled
  `nprcgenekeepr::qcPedGvReport` dataset (no gene-drop re-run): mean kinship
  skewness 0.3756 / excess kurtosis -0.9982 (n=280); genome uniqueness is
  degenerate (`sd = 0`) in that fixture, giving a real, non-hypothetical `NA`
  test case for the zero-variance guard. `BACKLOG.md` updated: the ratified
  plan added to `## Active` (READY, Effort S); the owner-directed sequencing
  decision recorded under "Genetic-metrics PDF audit follow-ups" -- planning
  and implementing #127 and #129 follow #126's implementation; planning #130
  follows all three.
- **Verify:** N/A -- planning session, no `R/`/`tests/`/`man/`/`NAMESPACE`/
  `data/` content changed (TDD phases inapplicable, per S423/S426 precedent).

### 2026-07-29 · [issue #128] Implement genetic-value floor as an alternative breeding-group inclusion criterion (Session 427)
- **Deliverable:** `R/modBreedingGroups.R` gains an "Include animals by" control
  (`inclusionCriterion`: `"topN"` default / `"valueFloor"`) implementing Slice 1 of
  `docs/planning/issue128-genetic-value-floor-plan.md`. Selecting the genetic-value
  floor excludes any candidate whose `value` (from issue #125's `orderReport()`) is
  `"Low Value"`, for all three `animalSource` choices, bypassing `nTopAnimals`
  entirely; `"Undetermined"` animals pass, ids absent from the GV report entirely do
  not (Dragon P1 fail-safe). Full strict TDD: RED (`20b97653`, 6 new tests) -> GREEN
  (`d575bae3`) -> REFACTOR (skipped, owner-approved -- code already clean), each
  phase gated via `AskUserQuestion`. Docs: `vignettes/manual_components/
  _breeding_group_formation.Rmd` + `NEWS.Rmd`/`NEWS.md` (`bfe36cd8`).
  **Closes issue #128.**
- **Verification:** targeted test file green; clean regression read 0 failed/0
  error/0 warning, 3928 passed (up from 3907); `devtools::check()` 0 errors/0
  warnings/0 notes; Phase 3E runtime smoke test against the live app (small
  synthetic pedigree, Learning 395 precedent) confirmed Top-N-ranked unchanged
  (bounded to `nTopAnimals`) and the genetic-value floor bypassing that bound for
  all 3 `animalSource` choices, zero crashes.
- **Learnings:** `PROJECT_LEARNINGS.md` 397 (a standalone `shinytest2::AppDriver`
  script needs `NOT_CRAN=true` set itself, or `AppDriver$new()`'s internal
  `skip_on_cran()` guard aborts with an opaque "Error: Reason: On CRAN"), 398 (no
  Shiny module in this app resets `data-ready` before a new async run, so
  `wait_for_module_ready()` reads a stale `"true"` on a second click in one
  `AppDriver` session -- use `app$wait_for_idle()` instead after the first click).
- **Scope note:** E2E regression coverage was discussed with the owner mid-session
  (server-level `testServer()` tests are committed/CI-run; the Phase 3E browser
  smoke test is a one-off, uncommitted script) -- owner confirmed via
  `AskUserQuestion` to leave it at that, matching issue #125 Slices 1/2's own
  precedent of no permanent `test-e2e-*.R` addition for this module.

### 2026-07-29 · [issue #128] Write design/scoping plan: genetic-value floor as an alternative breeding-group inclusion criterion (Session 426)
- **Deliverable:** `docs/planning/issue128-genetic-value-floor-plan.md` -- an
  evidence-based design plan for closing issue #128, ratified via `AskUserQuestion`
  this session, no `R/`/`tests/` code changed.
- **Process:** answered the owner's clarifying question (which issues address the
  audit's "configurability/multiplicity" cluster) via source-code verification
  before proceeding. Launched a 4-agent research workflow reading
  `R/modBreedingGroups.R`'s top-N mechanism, `R/groupAddAssign.R`'s filter chain,
  the ranking fields available post-issue-#125, and the module contract/test
  inventory firsthand. Personally re-verified every cited line against live source,
  then independently found (not from the workflow) that `reportGV()` defaults its
  GV population to living animals only (`R/reportGV.R:144-149`), meaning a
  value-floor over the "All available" source will meet ids absent from the report
  entirely -- distinct from the ratified "Undetermined passes" rule, recorded as
  the plan's own Dragon P1 with a required RED test. Presented 4 load-bearing
  decisions via one `AskUserQuestion` call; owner ratified all 4 recommended
  options: mechanism = user-selectable alternative to top-N (not replace/
  supplement), floor signal = reuse the existing `value` column (no new cutoff),
  "Undetermined" animals pass the floor, and the floor applies to all 3
  `animalSource` choices, not just "Top ranked."
- **Result:** plan document written with a firsthand evidence-based inventory
  (every claim cited `file:line`, re-verified against current source), a RATIFIED
  design-decisions section, one vertical slice (confined to
  `R/modBreedingGroups.R` -- no `groupAddAssign()` signature change, per the plan's
  own architecture rationale) with RED/GREEN/DONE-looks-like/Verify/session-
  boundary/dragons, and a ratification record. `PROJECT_LEARNINGS.md` Learning 396
  added (independently re-verifying a research workflow's findings, both citations
  and cross-cutting domain nuances, before writing a plan); `CLAUDE.md`'s stale
  "395 learnings" count fixed to 396. Side finding, filed for a future session (not
  fixed here): the "Upload list" `animalSource` UI option has no `fileInput`/
  handling anywhere and silently behaves like "All available" -- recommend its own
  small separate issue.

### 2026-07-29 · [issue #125] Implement Slice 2: surface multiple breeding-group candidates; close issue #125 (Session 425)
- **Deliverable:** `R/groupAddAssign.R` now retains up to 5 distinct candidate
  groupings per run (a new `candidates` list field), deduplicated by
  canonicalized partition content rather than by score (Dragon R4) --
  comparing each trial only against the current up-to-5 retained set
  (O(iter x 5)). `R/groupMembersReturn.R` restructured to package the
  retained list, aliasing the existing `group`/`score`/`groupKin` fields to
  the best (first) candidate for backward compatibility. `R/modBreedingGroups.R`
  gained a "Candidate grouping" selector and a comparison table; the
  button-triggered algorithm run (`runFormation`) processes every retained
  candidate, and a new `selectedCandidateIdx`/`selectedCandidate` reactive
  pair (mirroring the existing `selectedGroup` pattern) lets
  `breedingGroups()`/`score()`/`unassigned()`/`groupKinship()` re-derive from
  the selection as a plain `reactive()` -- switching candidates never
  re-invokes `groupAddAssign()`. Leaving the selector at its default (the
  best-scoring candidate) is byte-identical to prior behavior. Full
  strict-TDD session (RED -> GREEN -> REFACTOR, phase-gated via
  `AskUserQuestion`), per
  `docs/planning/issue125-ranking-priority-multi-candidate-plan.md` Section 4
  Slice 2.
- **Process:** re-verified every plan citation firsthand before writing any
  test (zero drift since S423 -- every cited `file:line` matched exactly,
  down to specific line numbers). Wrote 8 new tests across
  `test_groupAddAssign.R`/`test_modBreedingGroups_groupAddAssign.R`/
  `test_modBreedingGroups.R`; 5 failed for the right reason pre-GREEN, 3
  (a no-reinvocation call-counter test and a default-selection backward-compat
  regression test) passed immediately as backward-compat/invariant pins,
  matching S424's established precedent for flagging such pins explicitly.
  Fixed one pre-existing test's exact-length assertion
  (`length(group) == 3L` -> `4L`) and one pre-existing `groupAddAssign` mock
  stub returning the old pre-#125 shape -- both broke on the new additive
  `candidates` field despite Dragon R5's `expect_named`-only grep coming back
  clean (see `PROJECT_LEARNINGS.md` Learning 392). REFACTOR extracted a
  `selectedCandidate()` reactive to remove 4 repeated
  `groupResults()$candidates[[idx]]` lookups.
- **Verification:** full regression suite 0 failed/0 error/0 warning (3923
  passed, up from 3907), `devtools::check()` 0 errors/0 warnings/0 notes, and
  a full Phase 3E runtime smoke test via `shinytest2`/chromote driving the
  real app (a small synthetic 40-row pedigree -- the bundled 3,694-row
  example was impractically slow for a live MIS search, Learning 395):
  confirmed 5 real, distinct, independently-selectable candidates via
  selectize's own JS API (the native `<select>`'s DOM `<option>` list is not
  a reliable proxy for a selectize widget's real choices, Learning 393),
  switching candidates genuinely changed the displayed groups, switching back
  reproduced identical content (Learning 394), and the downstream Genetic
  Diversity tab still worked with a non-default candidate selected.
- **Result:** Slice 2 shipped (commits `6b64e151` RED, `3e5dc35f`
  GREEN+REFACTOR, `11e83ec2` docs/NEWS -- checkpointed per-phase this time,
  per Learning 391). `PROJECT_LEARNINGS.md` Learnings 392-395 added.
  **Both slices of the issue #125 plan are now shipped; issue #125 closed**
  (closing comment summarizes both slices).

### 2026-07-29 · [issue #125] Implement Slice 1: configurable genetic-value ranking-priority scheme (Session 424)
- **Deliverable:** `R/orderReport.R` gained `guCutoff`/`zScoreCutoff`/`axisPriority`
  parameters (each `NULL`-defaulting to today's hardcoded `10L`/`0.25`/`"gu"`
  behavior); `R/reportGV.R` threads the same 3 params straight through; a new
  "Ranking Scheme" control (Combined default / Categorical, with Priority axis and
  both cutoffs) was added to the Genetic Value Analysis tab in `R/modGeneticValue.R`.
  Full strict-TDD session (RED -> GREEN -> REFACTOR, phase-gated via
  `AskUserQuestion`), per `docs/planning/issue125-ranking-priority-multi-candidate-plan.md`
  Section 4 Slice 1.
- **Process:** re-verified every plan citation firsthand before writing any test
  (zero drift since S423). Wrote 7 new failing tests across
  `test_orderReport.R`/`test_reportGV.R`/`test_modGeneticValue.R`, confirmed each
  failed for the right reason, then implemented. Caught and fixed a real regression
  during GREEN: 2 pre-existing `local_mocked_bindings(reportGV = function(...))` test
  stubs had hardcoded the old signature and would have broken. Refactored duplicated
  tier-claim logic into two named closures. Fixed the vignette prose
  (`genetic-value-analysis.qmd`) to describe both ranking schemes, since the app's
  actual default (combined score) differs from what a direct `reportGV()` script call
  demonstrates.
- **Verification:** full regression suite 0 failed/0 error/0 warning (3907 passed, up
  from 3198), `devtools::check()` 0 errors/0 warnings/0 notes, and a full Phase 3E
  runtime smoke test via `shinytest2`/chromote driving the real app (real 3,694-row
  pedigree upload through the actual Input tab, QC confirmed, GVA run under 4
  rankScheme/axisPriority/cutoff configurations, full-CSV-export comparison confirmed
  genuine differentiation -- 15-316 animals changed value/rank per comparison).
- **Result:** Slice 1 shipped (commits `9d627dca` RED, `fdab2eb5` GREEN+REFACTOR,
  `986eb7d8` docs/NEWS -- split retroactively into 3 checkpoint commits after a
  mid-session Blast Radius cap check found 10 files uncommitted at once; close-out
  receipt in `8274395b`; `6a02fc6e` added the learnings/backlog-tag/stale-count-fix
  content described below, as a follow-on commit after the receipt).
  `PROJECT_LEARNINGS.md` Learnings 389-391 added (a `shinytest2` smoke-test gotcha
  sequence; a tied-value-block false-negative trap; the per-phase-gate Blast Radius
  check gap). `BACKLOG.md`'s `Active` section now carries Slice 2 as
  `(READY, Effort L)`. Slice 2 (multi-candidate breeding groups) remains -- a separate
  future session; issue #125 stays open until both slices ship.

### 2026-07-29 · [issue #125] Write implementation plan: configurable ranking-priority scheme + multi-candidate breeding groups (Session 423)
- **Deliverable:** `docs/planning/issue125-ranking-priority-multi-candidate-plan.md` --
  an evidence-based implementation plan for closing issue #125, ratified via
  `AskUserQuestion` this session, no `R/`/`tests/` code changed.
- **Process:** launched a 6-agent research workflow reading the ranking
  (`R/orderReport.R`/`R/rankSubjects.R`/`R/modGeneticValue.R`) and breeding-group
  (`R/groupAddAssign.R`/`R/groupMembersReturn.R`/`R/modBreedingGroups.R`) code
  firsthand, plus config/adapter precedent, before drafting any design. Found that
  issue #125's own text (from the audit that filed it) cites `R/orderReport.R`'s
  categorical scheme, but the Shiny app actually displays a second, independently
  hardcoded scheme (`R/modGeneticValue.R:294`, `rank(indivMeanKin - gu)`) that
  unconditionally overrides it -- a correction to the issue's premise, surfaced to the
  owner before ratifying scope. Presented 4 load-bearing decisions via one
  `AskUserQuestion` call; owner ratified: expose the categorical scheme's internal
  cutoffs (not just a scheme toggle), a Shiny UI control (not a config-file key),
  top-5 distinct-scoring deduplicated breeding-group candidates, ranking-scheme first
  as Slice 1.
- **Result:** plan document written with a firsthand evidence-based inventory
  (every claim cited `file:line`), a RATIFIED design-decisions section, two vertical
  slices (Slice 1: ranking-scheme configurability; Slice 2: multi-candidate breeding
  groups) each with RED/GREEN/DONE-looks-like/Verify/session-boundary/dragons, and a
  ratification record. `PROJECT_LEARNINGS.md` Learning 388 added (the
  audit-can-be-one-layer-shallow pattern; a `ScheduleWakeup` misuse caught and
  corrected mid-session).

### 2026-07-29 · [ad hoc] Triage genetic-metrics PDF capability audit findings (Session 422)
- **Deliverable:** Owner-picked from S421's priorities list: triage
  `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md`'s 12 missing/9
  partial findings (of 37 total) into tracked items.
- **Process:** presented the audit's own recommendation clusters to the owner via 6
  `AskUserQuestion` picks (File GitHub issue / BACKLOG.md item only / Decline, no
  action). Owner picked "File GitHub issue" for all 6.
- **Result:** filed GitHub issues #125 (configurable ranking-priority scheme +
  surface multiple breeding-group candidates, Dimensions 1 & 2), #126
  (kinship/genome-uniqueness distribution shape statistics -- skewness, kurtosis,
  Dimension 3), #127 (surface `correctUnknownParentMeanKinship()`'s silently-dropped
  `flagged` list, Dimension 4), #128 (breeding-group exclusion is top-N rank-based,
  not a genetic-value floor, Dimension 2), #129 (pedigree-diagram/tree
  visualization, currently table-only, Dimension 7), #130 (marker-based
  kinship/heterozygosity/parentage-verification + cross-center identity
  resolution, Dimensions 5 & 6). Declined, no action: NGS/whole-genome/
  MHC-specific/linkage-disequilibrium methods (Dimension 5) -- the audit's own
  Recommendation #5 already concluded these are speculative future work per the
  source PDF itself, not a present-day gap. Added a new `BACKLOG.md` section
  ("Genetic-metrics PDF audit follow-ups") recording the disposition of all 21
  findings, pointing at the 6 issue numbers.
- **Runtime smoke test:** n/a -- no `R/`/`tests/` code touched; pure triage/issue
  filing + `BACKLOG.md` documentation.

### 2026-07-29 · [BL-WordlistCranResubmission] Fix `NEWS.md:8` spelling-check NOTE (Session 421)
- **Deliverable:** Owner-picked from S420's priorities list, per `BACKLOG.md`'s
  Housekeeping item flagged S415/discovered via `devtools::check()`. `NEWS.md:8`'s
  S410 edit ("CRAN's 2.0.0 submission... any future CRAN resubmission ships as
  2.0.1") introduced `CRAN's` and `resubmission` without adding them to
  `inst/WORDLIST`, producing a real `Status: 1 NOTE` in the raw `R CMD check` log
  (`PROJECT_LEARNINGS.md` Learning 382). TDD Phase: N/A -- `inst/WORDLIST` is a
  curated spelling-check word list, not production `R/`/`tests/` code.
- **Result:** hand-added `CRAN's` (between `ColonyManagerTutorial`/`Curation`) and
  `resubmission` (between `resetPopulation`/`retentions`) to `inst/WORDLIST`,
  matching the file's existing case-insensitive collation order -- did not run
  `spelling::update_wordlist()` wholesale, per the project's "avoid reconcile tools
  on curated files" convention (S230). Verified: `devtools::check()` raw log
  `Status: OK`, 0 errors/0 warnings/0 notes (the spelling NOTE is gone); regression
  suite exact baseline match (0 failed/0 error/0 warning, 3198 passed, 179 skipped).

### 2026-07-29 · [BL-RoadmapDocEnginePath] Fix `ROADMAP.md`'s stale doc-engine-policy line (Session 420)
- **Deliverable:** Owner-picked from S419's priorities list, per `BACKLOG.md`'s
  Housekeeping item flagged S418. `ROADMAP.md:21` still named `inst/extdata/` as the
  location of the 3 developer docs (`claude_code.qmd`, `software_design_doc.qmd`,
  `meeting_notes.qmd`), but those files were relocated to `dev/extdata-scratch/`
  during the extdata reorg's Phase 1 (S415). TDD Phase: N/A -- pure prose fix, no
  `R/`/`tests/` production code touched.
- **Decision:** the wording call BACKLOG.md flagged as owner-input-needed (keep the
  doc-engine-policy category and fix the path, vs. drop the category since these are
  now archived scratch files) was resolved via `AskUserQuestion` before claiming the
  session. Owner picked **path-only fix**.
- **Result:** `ROADMAP.md:21` now reads `dev/extdata-scratch/` developer docs instead
  of `inst/extdata/` developer docs. Verified via `find`/`grep` that the 3 files
  actually live there and that no other current-state document still makes the old
  claim (only dated historical prose does, correctly left unedited). `BACKLOG.md`'s
  Housekeeping entry marked RESOLVED.

### 2026-07-29 · [ad hoc] Genetic-metrics PDF vs. package capability audit (Session 419)
- **Deliverable:** Owner-directed, not from `BACKLOG.md`: audit comparing the
  recommendations in `inst/extdata/reference/Master_Genetic_metrics_2_14_15.pdf` (NHP
  Genetics and Genomics Working Group, Feb 2015) against `nprcgenekeepr`'s actual
  capabilities. TDD Phase: N/A -- audit/documentation deliverable, no `R/`/`tests/`
  production code touched.
- **Method:** read the 10-page PDF in full; ran a 14-agent `Workflow` (7 recommendation
  dimensions, each investigated then independently adversarially re-verified against
  actual source), following this project's own `PED_GV_AUDIT_2026-05-30.md` precedent.
- **Result:** `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md` -- 37
  findings (16 implemented / 9 partial / 12 missing) plus a per-dimension list of
  additional package capabilities the PDF never asked for. Notable gaps: no configurable
  ranking-priority scheme, no multiple-candidate breeding-group output, no kinship/
  genome-uniqueness distribution-shape statistics, no marker-based (SNP/STR) kinship or
  parentage verification, no cross-center pedigree integration. Notable additions beyond
  the PDF: the full Shiny app, LabKey EHR integration, studbook QC, kinship-override
  system, ORIP reporting, founder-equivalent statistics with Monte Carlo standard
  errors. Did not file new `BACKLOG.md` items for the gaps found -- left to the owner.
- **Process note:** caught one verify-stage agent's own false claim
  (`readKinshipOverrides`/`checkKinshipOverrides` "don't exist" -- they do, confirmed via
  `ls R/`/`NAMESPACE`) before it reached the final document. See `PROJECT_LEARNINGS.md`
  Learning 386.

### 2026-07-28 · [ad hoc] `inst/extdata/` reorganization Phase 4: place the PDF, final repo-wide sweep -- plan now fully executed (Session 418)
- **Deliverable:** Owner-picked from S417's priorities list: execute Phase 4 of
  `docs/planning/extdata-reorganization-plan.md` -- resolve the plan's 2 remaining
  open decisions, place `Master_Genetic_metrics_2_14_15.pdf`, and run the plan's
  final repo-wide sweep grep. TDD Phase: N/A -- file relocation + rendered-doc
  refresh, no `R/` production logic.
- **Decisions resolved via `AskUserQuestion` before claiming the session (plan
  §10):** (1) PDF placement -> `inst/extdata/reference/` (end-user-facing
  reference material analogous to `ui_guidance/`, the plan's own default); (3)
  orphaned-files archive-vs-delete -> keep archived at `dev/extdata-scratch/`, no
  change from Phase 1.
- **Execution:** re-ran a fresh, independent grep for the PDF's filename before
  touching it (none found outside planning/session-notes prose) and `git mv`'d it
  to `inst/extdata/reference/`. Ran the plan's prescribed final sweep grep, which
  found `README.md` stale relative to its already-fixed source: `README.Rmd`
  `child=`-includes `vignettes/manual_components/_summary_of_major_functions.Rmd`
  (the exact file S417 fixed for a stale GitHub blob URL), but `README.Rmd` was
  never in S417's Phase-3 render target list, so `README.md` still linked the
  pre-Phase-2 flat `inst/extdata/example_nprcgenekeepr_config` path. Re-rendered
  `README.Rmd` to pick up the fix -- see `PROJECT_LEARNINGS.md` Learning 385. All
  other sweep hits triaged and confirmed as false positives: dated historical
  prose in `NEWS.Rmd`/`NEWS.md` and various `docs/planning/`/`docs/research/`
  documents, correctly describing repo state as it existed when each was written,
  left unedited.
- **Discovered but deferred (owner-input editorial call, not a mechanical fix):**
  `ROADMAP.md:21-22` still describes "the `inst/extdata/` developer docs" as a
  documentation-engine category, but Phase 1 (S415) already relocated all 3 of
  those dev docs out of `inst/extdata/` to `dev/extdata-scratch/` -- filed as a
  new `BACKLOG.md` Housekeeping item rather than rewritten unilaterally.
- **Verify:** `R CMD build` tarball ships the PDF at `inst/extdata/reference/` and
  nothing at the old flat path (confirmed via `tar tzf`); regression suite exact
  baseline (0/0/0, 3198 passed, 179 skipped); `devtools::check()` 0 errors/0
  warnings, 1 NOTE (same pre-existing `NEWS.md:8` spelling gap, confirmed
  untouched -- read from the raw check log's `Status:` line per Learning 382).
- **`inst/extdata/` reorganization plan is now fully executed (Phases 1-4 all
  DONE)** -- `docs/planning/extdata-reorganization-plan.md`, S414 (plan) through
  S418 (this session).

### 2026-07-28 · [ad hoc] `inst/extdata/` reorganization Phase 3: fix + re-render the rendered artifacts still embedding the old flat path (Session 417)
- **Deliverable:** Owner-picked from S416's priorities list: execute Phase 3 of
  `docs/planning/extdata-reorganization-plan.md` -- re-render `a3manual.Rmd`,
  `a2interactive.Rmd`, and `vignettes/articles/offline-focal-animal-workflow.qmd` so
  their rendered outputs match Phase 2's `examples/` path. TDD Phase: N/A -- vignette
  source path fixes + re-renders, no new `R/` production logic.
- **Scope correction found by this session's own Dragon 1 grep (not trusting the
  plan's Phase 3 prose, or Phase 2's completion, as final):** the plan's Phase 3
  text described all 3 targets uniformly as re-render work, but
  `vignettes/articles/offline-focal-animal-workflow.qmd:104,106` still called
  `system.file("extdata", "<file>", package = ...)` directly with no `examples`
  segment -- confirmed in R this returned `""` (broken) since Phase 2 moved the
  files. The plan's own §8.1 evidence table had already listed this exact call
  site; only the Phase 3 prose summary undercounted it. Fixed as the source bug it
  was. Also fixed the stale GitHub blob URL in
  `vignettes/manual_components/_summary_of_major_functions.Rmd:66` (still pointed
  at the pre-Phase-2 flat path). See `PROJECT_LEARNINGS.md` Learning 384.
- **Re-rendered all 3 targets:** `a3manual.Rmd` via `rmarkdown::render(output_format
  = rmarkdown::html_vignette(keep_md = TRUE))` (the default render doesn't refresh
  the gitignored `.md` byproduct; `keep_md = TRUE` was needed to also update it);
  `a2interactive.Rmd` via `rmarkdown::render()`; the `.qmd` pkgdown article via
  `quarto render` from within `vignettes/articles/` (its `_quarto.yml` project
  context) -- required a throwaway local package install
  (`devtools::install(build_vignettes = FALSE, dependencies = FALSE)`, plus
  `R_LIBS_USER` pointed at the renv library so the quarto subprocess's fresh R
  session could find it) since the article's `library(nprcgenekeepr)` call needs a
  real install, not just `pkgload::load_all()`.
- **Verification (all per plan §6 Phase 3, plus this session's own additions):**
  the rendered article's `[shipped]` chunk executed cleanly with `dim(colonyPed)` =
  `2922 x 11` (real data, not an error) -- proof the fixed `system.file()` calls
  resolve at runtime, not just syntactically; the plan's prescribed
  `grep -rln "inst/extdata/example_nprcgenekeepr_config\|inst/extdata/ExamplePedigree"
  vignettes/*.html vignettes/*.md` returned nothing, broadened to also cover
  `vignettes/articles/*.html` (nothing); `gh api` confirmed the GitHub blob URL
  target (`inst/extdata/examples/example_nprcgenekeepr_config`) actually exists on
  `origin/master` -- Dragon 2's "manual link click" requirement, done via API
  rather than a browser; regression suite exact baseline match (0 failed/0 error/0
  warning, 3198 passed, 179 skipped); `devtools::check()` 0 errors/0 warnings, 1
  NOTE -- the same pre-existing, unrelated `NEWS.md:8` spelling gap from S415/S416,
  confirmed untouched by this session's diff, read from the raw check log's
  `Status:` line per Learning 382 (the colored summary again showed 0 notes).
- Updated `BACKLOG.md` (Phase 3 marked DONE, Phase 4's 2 open decisions restated),
  `PROJECT_LEARNINGS.md` (Learning 384), `CLAUDE.md`'s learning-count
  cross-reference (383 -> 384).

### 2026-07-28 · [ad hoc] `inst/extdata/` reorganization Phase 2: subfolder the 10 load-bearing files into examples/ (Session 416)
- **Deliverable:** Owner-picked from `BACKLOG.md`'s Housekeeping section: execute
  Phase 2 of `docs/planning/extdata-reorganization-plan.md` (S414) -- create
  `inst/extdata/examples/`, migrate the 10 load-bearing files, update every
  `system.file()`/hardcoded-path call site. TDD Phase: N/A -- file relocation +
  path-reference updates in existing tests/prose, no new `R/` production logic.
- **Pre-execution decisions resolved:** subfolder name **`examples/`** (owner-picked
  via `AskUserQuestion` over `fixtures/`/`sample-data/`/`package-data/`, plan §10 #2).
  `vignettes/a2interactive.R`'s generation status (plan §10 #4, Dragon 4): initially
  misjudged from the `%\VignetteEngine{knitr::rmarkdown_notangle}` directive as
  hand-maintained; owner corrected -- `.Rmd` files are the source, `.R`/`.md`/`.html`
  are generated derivatives, and any drift ahead of the `.Rmd` is a bug to fix.
  Confirmed further: `vignettes/*.R`/`*.md`/`*.html` are gitignored
  (`.gitignore:18,20,22`), never git-tracked -- so the tracked-source fix is the
  `.Rmd` edit alone; the stale local `a2interactive.R` (3 commits behind its `.Rmd`)
  was regenerated via `knitr::purl()` as a courtesy, producing no commit. Noted, not
  fixed (unrelated, out of scope): `vignettes/gvaConvergence.R` and
  `vignettes/simulatedKValues.R` show the same local staleness pattern but reference
  no `extdata` path.
- **Change:** Re-ran a fresh, independent exhaustive `grep -rn` for all 10 filenames
  across `R/`, `tests/`, `vignettes/`, `man/`, `data-raw/`, `README.Rmd`, `docs/`,
  `.github/` before touching anything (Dragon 1), rather than trusting the plan's own
  §8.1 inventory as final. `git mv`'d all 10 load-bearing files into
  `inst/extdata/examples/` (2 checkpoint commits of 5). Updated the central
  `get_test_data_path()` test helper (fixes every caller through it); ~28 individual
  `system.file()` call sites across 15 test files; 7 path-bearing roxygen/comment
  prose sites (`R/defaultSiteParams.R:16`, `R/loadSiteConfig.R:11`,
  `data-raw/rhesusGenotypes.R:18`, `data-raw/rhesusPedigree.R:9`, plus 2 test-file
  comments) -- correctly left `R/data.R`'s 4 extdata mentions untouched since they're
  plain filenames with no path prefix, still accurate post-move; the one hardcoded
  path in `vignettes/a2interactive.Rmd:90`. Regenerated `man/loadSiteConfig.Rd` via
  `devtools::document()` -- the only one of the plan's 5 named `.Rd` files that
  actually needed it, confirming the `R/data.R` scoping call was correct.
- **Verification:** Fresh regression suite exactly matches the pre-move baseline (0
  failed/0 error/0 warning, 3198 passed, 179 skipped, S412); `R CMD build` tarball
  confirmed all 10 files ship under `examples/` and nothing remains at the old flat
  path; `devtools::check()` 0 errors/0 warnings, 1 NOTE (the same pre-existing,
  unrelated spelling gap S415 found -- confirmed untouched by this session's diff via
  `git log` on `NEWS.md`/`inst/WORDLIST`/`tests/spelling.R`); grep sweep confirmed the
  only 3 remaining un-migrated references are exactly what the plan defers to Phase 3
  (`vignettes/manual_components/_summary_of_major_functions.Rmd`'s GitHub blob URL
  source, plus its 2 gitignored rendered byproducts `a3manual.md`/`.html`).
- **Commits:** `082a0cc4` (S416 claim), `bbf3ec9a`/`f35d809f` (file moves),
  `c38b107e` (helper + R/ + data-raw prose), `6f87d91b`/`70206939`/`58ff752f`/
  `44066adf` (test call sites), `f6282c3c` (a2interactive.Rmd), `487d0c09`
  (man/loadSiteConfig.Rd regen).

### 2026-07-28 · [ad hoc] `inst/extdata/` reorganization Phase 1: relocate dev-scratch + orphaned content (Session 415)
- **Deliverable:** Owner-picked from `BACKLOG.md`'s Housekeeping section: execute
  Phase 1 of `docs/planning/extdata-reorganization-plan.md` (S414) -- relocate
  `inst/extdata/`'s dev-scratch and orphaned (zero-reference) items into
  `dev/extdata-scratch/`, remove empty untracked directories, and delete the
  now-obsolete `.Rbuildignore`/`.gitignore` lines that named them. TDD Phase: N/A --
  file relocation + build-config cleanup, no `R/`/`tests/` production logic touched.
- **Change:** Independently re-verified the plan's item list against current ground
  truth before moving anything -- the plan's own summary table ("11 + 9" = 20 items)
  disagreed with both its own enumerated §4/§8.5 list (24 items) and its Phase 1 prose
  ("19 items"); reconciled via direct `find`/`git ls-files`/`grep -rln` against the
  actual `inst/extdata/` tree (`PROJECT_LEARNINGS.md` Learning 381), which also caught
  one obsolete `.Rbuildignore` line (`inst/extdata/meeting_notes\.html$`) the plan's
  own §8.3 list had missed. Relocated 24 confirmed-zero-reference items (12
  dev-scratch + 12 orphaned) via `git mv` in 5 checkpoint commits (5-file blast-radius
  cap, `SAFEGUARDS.md`), removed 3 empty untracked dirs (`claude/`, `dev_scripts/`,
  `uat/`) plus the now-empty `code_under_development/`, deleted 11 obsolete
  `.Rbuildignore` lines and 10 dead `.gitignore` lines (2 separate commits).
- **Verification:** Regression suite unchanged -- 0 failed/0 error/0 warning, 3198
  passed, 179 skipped, matching the S412 baseline exactly. `R CMD build` tarball
  confirmed clean: `create_nprcgenekeepr_hexbadge.R` (the file that previously shipped
  unintentionally) and the rest of the dev-scratch/orphaned cluster are gone; only the
  10 load-bearing files + the new PDF + `ui_guidance/` remain in the shipped
  `inst/extdata/`. `devtools::check()`: 0 errors/0 warnings, but the raw log's own
  `Status: 1 NOTE` directly contradicted devtools' colored "0 notes ✔" summary line --
  traced to a pre-existing, unrelated `NEWS.md:8` spelling-check gap (`CRAN's`/
  `resubmission` missing from `inst/WORDLIST`, introduced by S410, five sessions
  before this one; confirmed untouched by this session's diff) rather than anything
  this session's changes caused. Reported rather than silently fixed (scope
  discipline, `SAFEGUARDS.md`) -- see the new `BACKLOG.md` Housekeeping item.
  `PROJECT_LEARNINGS.md` Learning 382.
- **Also:** Updated the `BACKLOG.md` reorg item to Phase 1 DONE / Phases 2-4 status;
  added a new Housekeeping item for the spelling NOTE; added `PROJECT_LEARNINGS.md`
  Learnings 381-382; updated `CLAUDE.md`'s learning-count cross-reference (380 -> 382).
  Phases 2-4 remain separate future sessions (2 of 4 open decisions still block Phase
  2 per the plan's §10) -- not started, per `SESSION_RUNNER.md`'s Vertical Slice
  session-boundary discipline (FM #18).

### 2026-07-28 · [ad hoc] `inst/extdata/` reorganization plan + PDF tracking (Session 414)
- **Deliverable:** Owner-directed (not from `BACKLOG.md`; triggered by the owner adding
  `Master_Genetic_metrics_2_14_15.pdf` to `inst/extdata/`, which prompted a request for
  reorganization suggestions): (1) tracked the new PDF; (2) wrote
  `docs/planning/extdata-reorganization-plan.md`, a 4-phase plan to split
  `inst/extdata/`'s 43 mixed items into load-bearing example data
  (`inst/extdata/examples/`), unchanged UI-guidance HTML (`ui_guidance/`), and
  relocated dev-scratch/orphaned content (`dev/extdata-scratch/`). Planning-session
  deliverable; TDD Phase N/A throughout, no `R/`/`tests/` code touched.
- **Change:** Tracked the PDF as its own isolated commit (`0fa3973e`). Delegated an
  initial reference-mapping sweep to a search subagent, then cross-verified with direct
  `grep -rn` sweeps across `R/`, `tests/`, `vignettes/`, `man/`, `data-raw/`,
  `README.Rmd`, `.Rbuildignore`, `.gitignore` -- caught real gaps the subagent's
  filename-driven search missed (two whole test files, a hardcoded non-`system.file()`
  relative path in `vignettes/a2interactive.Rmd`/`.R`, two GitHub-blob-URL mentions
  embedded in rendered vignette artifacts). Presented 4 reorg-scope options via
  `AskUserQuestion`; owner picked the fullest scope. Wrote the plan with a full
  evidence-based inventory (~50 call sites across 3 `R/` files, ~15 test files, 2
  `data-raw/` provenance scripts, 2 vignette sources, 4 generated `man/*.Rd` files), 4
  "dragons," and 4 open decisions for the owner -- no reorg implemented this session,
  per `SAFEGUARDS.md`'s plan-mode gate for cross-module changes and
  `SESSION_RUNNER.md`'s Planning Sessions discipline (the plan is the deliverable;
  implementation is separate future sessions).
- **Also:** Added a `BACKLOG.md` Housekeeping item tracking the plan (Phase 1 READY,
  Phases 2-4 pending 2 of the 4 open decisions); `PROJECT_LEARNINGS.md` Learning 380
  (a delegated subagent's filename-driven grep is a starting map, not a final
  inventory -- verify it directly before citing it as evidence in a migration plan);
  `CLAUDE.md:235`'s learning-count cross-reference (379 -> 380).
- **Verification:** N/A for the plan itself (no code changed); the one file-tracking
  action (`git add`+commit the PDF) needed no test/build verification.

### 2026-07-28 · [ad hoc] NPRC outreach and announcement plan (Session 413)
- **Deliverable:** Owner-directed (not from `BACKLOG.md`): `docs/planning/nprc-outreach-announcement-plan.md`,
  a plan to announce, advertise, and correspond about nprcgenekeepr 2.0.0 to the
  national primate research center (NPRC) network and specifically the NPRC Genetics
  and Genomics Working Group. Planning-session deliverable; TDD Phase N/A throughout,
  no `R/`/`tests/` code touched.
- **Change:** Scoped via `AskUserQuestion` (owner corrected the initial audience
  assumption -- Amanda Vinson is no longer in the program; redirected toward Jeff
  Rogers as a possible lead and toward also researching colony managers/head
  veterinarians per center). Ran an 8-agent background Workflow (`wf_13dc386e-06e`,
  266 web fetches/searches, ~470K tokens) researching current Working Group
  leadership and per-center colony-manager/head-veterinarian contacts, while the
  owner supplied additional contacts in real time. The plan covers: purpose and
  timing rationale (CRAN 2.0.0 published 2026-07-26; both companion pkgdown articles
  live), a three-tier audience map (Working Group, center directors, colony
  managers/veterinarians), tailored key messages per audience, available channels
  (direct correspondence is the only realistic one -- no consortium tool-listing
  process was found), a sourced 7-center contact roster (director + colony-manager/
  head-veterinarian-equivalent + genetics contact, each with a source and explicit
  confidence/caveats), a generic phased timeline, 5 named risks, and ready-to-edit
  draft materials (a Working Group outreach email, a colony-manager/veterinarian
  email, a one-page feature summary, and a presentation/demo outline).
- **Research findings folded in:** the Working Group's own page names no chair at
  all, current or historical -- the plan explicitly warns against citing anyone as
  "current chair" rather than defaulting to the last-known name (Jeffrey Rogers),
  recommending a direct ask to `support@nhprc.org` instead. A colony-manager could
  not be named at 3 of 7 centers (Southwest, Tulane, Washington) despite each site
  describing the role -- reported honestly as not-found rather than guessed. One
  real contact-detail discrepancy was flagged rather than silently resolved (two
  spellings of Jon Hennebold's email). One research agent independently caught and
  rejected a search-engine-invented pair of fictitious veterinarian names at
  Washington NPRC before it could enter the plan -- preserved as a documented warning.
- **Public-repo judgment call:** before the close-out commit, explicitly asked the
  owner whether a document naming real third parties' direct work emails/phone
  numbers (all independently already public on institutional sites, but newly
  aggregated here) should be committed and pushed to this public repo as-is, kept
  local-only, or split into public/private versions. Owner chose commit+push as-is.
- **Also:** added a `BACKLOG.md` "Outreach" item tracking the remaining
  owner-executed next steps (review/edit drafts, confirm recipients, send -- not a
  further coding task); added `PROJECT_LEARNINGS.md` Learnings 378-379 (the
  workstream/publishing judgment calls an external-facing plan introduces; the value
  and uneven cost of instructing research agents to report not-found rather than
  fabricate); updated `CLAUDE.md`'s learning-count cross-reference.

### 2026-07-28 · [ad hoc] Close-out: predecessor evaluation, self-assessment, HANDOFFS.md receipt (Session 412)
- **Deliverable:** Phase 3 close-out for this session's `CLAUDE.md` regression-
  command fix (see the entry below). Evaluated S411's handoff (10/10 -- the
  `gotchas` field and `PROJECT_LEARNINGS.md` Learning 377 both named the exact
  fix mechanism and location, and the `BACKLOG.md` item text was itself an
  executable spec, leaving this session pure execution + verification with no
  independent diagnosis needed). Self-assessed 9/10 (docked for not
  independently investigating the still-open root-cause question Learning 377
  left unresolved -- correctly judged out of this session's Effort-S scope,
  but flagged as a still-open curiosity rather than treated as fully closed).
  Deliberately added no new `PROJECT_LEARNINGS.md` numbered entry -- this
  session discovered nothing new beyond what Learning 377 already diagnosed.
  Completed the `HANDOFFS.md` S412 receipt (`status: pending` -> `complete`).
- **TDD Phase:** N/A -- pure documentation/close-out bookkeeping, no
  `R/`/`tests/` code touched.

### 2026-07-28 · [BL-RegressionReadDoc] Fix `CLAUDE.md`'s "Clean regression read" command to prepend `pkgload::load_all()` (Session 412)
- **Deliverable:** Owner-picked from the Phase 0 priorities list, resolving the
  Housekeeping item flagged S411 (`PROJECT_LEARNINGS.md` Learning 377). Added
  `pkgload::load_all(".", quiet=TRUE);` before the `testthat::test_dir(...)`
  call in the documented "Clean regression read" command (`CLAUDE.md:149`),
  matching the neighboring "Fast single-file test" row's existing pattern, plus
  an inline parenthetical explaining why `load_all()` must run first.
- **Actions:** Verified by running the fixed command exactly as now documented:
  0 failed/0 error/0 warning, 3198 passed, 179 skipped -- matching the known-good
  S410/S411 baseline. Isolated 1-line diff on `CLAUDE.md` only. `BACKLOG.md`
  Housekeeping item resolved. No new `PROJECT_LEARNINGS.md` entry added -- this
  session applied Learning 377's already-diagnosed fix verbatim with no new
  pattern or anti-pattern discovered.
- **TDD Phase:** N/A -- documentation-only change, no `R/`/`tests/` code touched.

### 2026-07-28 · [ad hoc] Close-out: predecessor evaluation, self-assessment, Learning 377, HANDOFFS.md receipt (Session 411)
- **Deliverable:** Phase 3 close-out for this session's README.html byproduct fix
  (see the entry below). Evaluated S410's handoff (9/10 -- named the exact fix
  mechanism up front in both its `SESSION_NOTES.md` gotcha and
  `PROJECT_LEARNINGS.md` Learning 376(b), sparing this session the diagnosis
  step). Self-assessed 9/10 (docked for not fully root-causing why
  `testthat::test_dir()` alone produces mass-spurious failures, and for not
  surfacing the pre-existing `.DS_Store` drift in the close-out report body
  itself). Added `PROJECT_LEARNINGS.md` Learning 377 (the `CLAUDE.md`
  "Clean regression read" command needs a preceding `pkgload::load_all()`, or
  it reports a false mass regression) and a `BACKLOG.md` Housekeeping item for
  the doc fix. Bumped `CLAUDE.md`'s learning-count cross-reference (376 -> 377).
  Completed the `HANDOFFS.md` S411 receipt (`status: pending` -> `complete`).
- **TDD Phase:** N/A -- pure documentation/close-out bookkeeping, no
  `R/`/`tests/` code touched.

### 2026-07-28 · [ad hoc] Stop README.Rmd from leaving an untracked README.html byproduct (Session 411)
- **Deliverable:** Owner-picked from the Phase 0 priorities list, resolving the
  Housekeeping item flagged S410 (`PROJECT_LEARNINGS.md` Learning 376(b)).
  Added `html_preview: false` to `README.Rmd`'s `output: github_document`
  frontmatter, mirroring `NEWS.Rmd`'s already-working pattern (`NEWS.Rmd:4-7`).
- **Actions:** Verified via a clean pre-render version check (installed
  `2.0.0.9000` matched `DESCRIPTION`, no reinstall needed) then re-rendering
  `README.Rmd`: no `README.html` byproduct produced, and `README.md`'s content
  was unchanged (already current from S410's same-day render). Isolated
  3-line diff on `README.Rmd` only. `BACKLOG.md` Housekeeping item resolved.
- **TDD Phase:** N/A -- Quarto/R-Markdown frontmatter + rendering only, no
  `R/`/`tests/` code touched.

### 2026-07-28 · [ad hoc] Close-out: predecessor evaluation, self-assessment, Learning 376, HANDOFFS.md receipt (Session 410)
- **Deliverable:** Phase 3 close-out for this session's CRAN post-acceptance housekeeping
  (see the entry below). Evaluated S409's handoff (8/10 -- clean state and an accurately
  BLOCKED CRAN item let this session recognize instantly that today's new information
  resolved it, though the handoff had no direct content overlap with today's externally
  triggered task). Self-assessed 8/10 (docked for not surfacing the `gh release create`
  vs. `usethis::use_github_release()` deviation as its own decision point, and for only
  partially verifying binary-flavor publication 2 days post-accept). Added
  `PROJECT_LEARNINGS.md` Learning 376 (installed-vs-source package version trap when
  re-rendering `getVersion()`-dependent docs, plus the `README.html` render byproduct
  gap) and a `BACKLOG.md` Housekeeping follow-up item for the latter. Bumped `CLAUDE.md`'s
  learning-count cross-reference (375 -> 376). Completed the `HANDOFFS.md` S410 receipt
  (`status: pending` -> `complete`).
- **TDD Phase:** N/A -- pure documentation/close-out bookkeeping, no `R/`/`tests/` code
  touched.

### 2026-07-28 · [ad hoc] CRAN 2.0.0 post-acceptance housekeeping -- Phase 6 (Session 410)
- **Deliverable:** owner-directed, triggered by CRAN's automated Windows-binary-build
  notification email. Independently confirmed via CRAN's live package page
  (cran.r-project.org/package=nprcgenekeepr): version 2.0.0, published 2026-07-26 --
  the pending submission (tagged `v2.0.0`, S407) was accepted. Executed the remaining
  steps of the pre-declared Phase 6 (Post-acceptance) from
  `docs/planning/cran-2.0.0-submission-plan.md:324` (the `v2.0.0` tag and the
  `DESCRIPTION` dev-version bump to `2.0.0.9000` were already done ahead of time in
  S407, before the acceptance was known).
- **Actions:** (1) Created the missing GitHub Release for `v2.0.0`
  (github.com/rmsharp/nprcgenekeepr/releases/tag/v2.0.0) -- `gh release list` showed
  none existed (v1.0.7 was still "Latest"); notes drawn from `NEWS.md`'s
  "2.0.0 (20260708)" section plus a one-line submission/acceptance-date header.
  Verified live via `gh release view`. (2) Deleted the tracked, `.Rbuildignore`'d
  `CRAN-SUBMISSION` file -- its job (tracking the pending submission) is resolved,
  matching this project's own precedent (`96a0f67c`, post-1.0.8-acceptance). (3)
  Fixed `NEWS.Rmd`'s "2.0.0.9000 (development version)" note, which read "...is under
  review" -- now records the actual acceptance/publication dates; re-rendered to
  `NEWS.md` (isolated 3-line diff). (4) Re-knit `README.Rmd` -> `README.md`,
  owner-directed additional scope: the shipped `README.md` showed "Version 2.0.0
  (2026-07-07)", stale independent of today's news -- it predated the S407
  dev-version bump and was never re-rendered after it. Discovered the locally
  *installed* package was also stale (still `2.0.0`, not `2.0.0.9000`), which would
  have rendered an inconsistent version string; reinstalled
  (`devtools::install(quick = TRUE)`) before rendering -- isolated 2-line diff (date +
  version string only). (5) Updated `BACKLOG.md`'s CRAN resubmission item to record
  acceptance.
- **Verified:** `gh release view v2.0.0` / `gh release list` confirm the release is
  live and marked "Latest"; `git diff NEWS.md` / `git diff README.md` both isolated to
  the intended lines; `packageVersion("nprcgenekeepr")` confirmed `2.0.0.9000`
  post-reinstall; repo-wide grep swept for other stale "under review"/"pending"
  CRAN-status language.
- **TDD Phase:** N/A throughout -- packaging/release/documentation housekeeping only,
  no `R/`/`tests/` code touched.

### 2026-07-21 · [ad hoc] Close-out: predecessor evaluation, self-assessment, HANDOFFS.md receipt (Session 409)
- **Deliverable:** Phase 3 close-out for this session's title/dropdown change (see the
  entry below). Evaluated S408's handoff (9/10 -- its CDN-cache-lag verification
  discipline was directly reused this session). Self-assessed 9/10. Completed the
  `HANDOFFS.md` S409 receipt (`status: pending` -> `complete`). Co-staged in this same
  commit so this close-out action doesn't recreate the self-referential `CHANGELOG.md`
  gap the S408 session's own Phase 0 reconcile found and fixed.
- **TDD Phase:** N/A -- pure documentation/close-out bookkeeping, no `R/`/`tests/` code
  touched.

### 2026-07-21 · [ad hoc] Rename colony-manager-guide article title, reorder it to top of Articles dropdown (Session 409)
- **Deliverable:** owner-directed. (1) Remove the "nprcgenekeepr: " prefix from the
  colony-manager-guide article's title (was `"nprcgenekeepr: Purpose, Approach, and a
  Colony Manager's Guide to Practice"`, now `"Purpose, Approach, and a Colony Manager's
  Guide to Practice"`) -- this is also the Articles dropdown's display text, pulled
  directly from the vignette's own title. (2) Move it to the top of the Articles
  dropdown. `_pkgdown.yml` had no `articles:` config at all, so the dropdown was
  pkgdown's default alphabetical listing -- added one.
- **Verified against pkgdown 2.2.0's actual source before writing the config, not just
  its docs:** `navbar_articles()` collapses the ENTIRE dropdown into a single "Articles"
  link to `articles/index.html` if a custom `articles:` config exists but none of its
  sections declare a `navbar:` field -- so the added section includes `navbar: ~` to
  keep the full per-article list. `contents:` entries must use each article's pkgdown
  "name" (confirmed via `pkgdown::as_pkgdown(".")$vignettes$name`): `vignettes/articles/
  *.qmd` files need the `articles/` prefix (e.g. `articles/colony-manager-guide`);
  top-level `vignettes/*.Rmd` files (e.g. `a2interactive`) do not. All 12 existing
  articles listed explicitly, `articles/colony-manager-guide` first, the rest kept in
  their previous (alphabetical) relative order.
- **Consistency:** `vignettes/_ColonyManagerTutorial.Rmd:8` (the retired, unpublished
  stub) quoted the old title verbatim in its own link text -- updated to match.
  `docs/planning/document2-colony-manager-guide-plan.md` left untouched (historical
  planning record, not live content).
- **Verified:** directly inspected `pkgdown:::navbar_articles()`'s generated menu
  structure (not just the YAML) -- confirms 12 entries, correct order, no fallback
  "More articles..." link. Rebuilt the actual article + home page locally
  (`pkgdown::build_article("articles/colony-manager-guide")` +
  `pkgdown::build_home()`) and grepped the rendered HTML's `<title>`/`<h1>`/navbar --
  all match. Full regression suite: `0 failed/0 error/0 warning` (3198 passed, no
  `R/`/`tests/` code touched).
- **TDD Phase:** N/A throughout -- vignette frontmatter + `_pkgdown.yml` config only.

### 2026-07-21 · [ad hoc] Close-out: predecessor evaluation, self-assessment, Learning 375, HANDOFFS.md receipt (Session 408)
- **Deliverable:** Phase 3 close-out for this session's merge + pkgdown deploy fix (see
  the `[issue #124]` entry below). Evaluated both predecessor S407 handoffs (branch's
  link-fix session and master's independently-diverged CRAN tag/version-bump session,
  9/10 each -- master's `gotchas` field explicitly predicted the exact 4-file merge
  conflict this session hit). Self-assessed 9/10. Recorded `PROJECT_LEARNINGS.md`
  Learning 375 (deploy-pipeline additive-only-clean as a defect class distinct from a
  source-level fix, plus the CDN-propagation-lag verification gotcha) and refreshed
  `CLAUDE.md`'s stale learning-count/file-size cross-reference (370/1.7MB ->
  375/1.6MB). Completed the `HANDOFFS.md` S408 receipt (`status: pending` ->
  `complete`). Co-staged in this same commit specifically so this close-out action
  doesn't recreate the exact self-referential `CHANGELOG.md` gap this session's own
  Phase 0 reconcile found and backfilled for S407's close-out commit.
- **TDD Phase:** N/A -- pure documentation/close-out bookkeeping, no `R/`/`tests/` code
  touched.

### 2026-07-21 · [issue #124] Merge fix/figure2-contrast-engineering-2.0.0-release into master; fix pkgdown deploy clean:false so stale pages actually get removed (Session 408)
- **Deliverable:** owner-approved merge of `fix/figure2-contrast-engineering-2.0.0-release`
  (S401-407, 22 commits: Figure 2 contrast/layout fixes, Mermaid theme defensive fix,
  colony-manager-guide.qmd link fixes, and the ColonyManagerTutorial.Rmd doubled-path
  fix) into `master`, which had independently diverged with its own S407 (CRAN v2.0.0
  tag + `2.0.0.9000` dev-version bump). Real 3-way merge, not a fast-forward: 4 conflicts
  (`BACKLOG.md` auto-merged cleanly; `CHANGELOG.md`/`HANDOFFS.md`/`SESSION_NOTES.md`
  required manual resolution -- both sides had independently prepended entries at the
  same insertion point) -- resolved by interleaving both sides' entries in actual
  chronological order (master's S407 tag/bump commits, 10:58-11:01, precede the
  branch's S407 link-fix commits, 11:24-11:45, same day), preserving every entry from
  both histories rather than discarding either side. No `R/`/`tests/` code conflicts;
  `DESCRIPTION` untouched by the branch, so master's `2.0.0.9000` carried through
  automatically. Verified before committing: `pkgload::load_all()` clean load,
  full regression suite `0 failed/0 error/0 warning` (3198 passed, 179 skipped), and
  `R CMD build .` + `tar tzf` confirming `_ColonyManagerTutorial.Rmd` correctly excluded
  from the tarball. Pushed to `origin/master` (`dd8e53fd`), triggering the pkgdown
  redeploy.
- **Second defect found during live-site verification (not from either merged branch):**
  post-deploy, the owner-reported doubled-path URL correctly still 404s (it was never
  meant to resolve), but `https://.../articles/ColonyManagerTutorial.html` -- the OLD,
  un-prefixed page -- was still live (HTTP 200) and still contained the exact
  `.qmd`-targeting link issue #124 tracks. Root cause:
  `.github/workflows/pkgdown.yaml`'s deploy step used `clean: false`
  (`JamesIves/github-pages-deploy-action@v4.5.0`), so every pkgdown deploy has only ever
  *added* files to `gh-pages`, never removed stale ones -- confirmed via
  `git ls-tree -r origin/gh-pages`: 981 files including THREE separate old copies of
  this tutorial (`01ColonyManagerTutorial.html`, `06ColonyManagerTutorial.html`,
  `ColonyManagerTutorial.html`) from past renames, none ever cleaned up. This meant the
  source-level fix (renaming to `_ColonyManagerTutorial.Rmd`, excluding it from the
  pkgdown build) could not actually resolve the live defect -- a page already deployed
  from a prior build stays live regardless of what the current build excludes.
- **Fix:** `.github/workflows/pkgdown.yaml` `clean: false` -> `clean: true`. Checked for
  hand-maintained `gh-pages` assets a clean deploy might destroy before making the
  change -- found only `.nojekyll`, which pkgdown regenerates automatically on every
  build, so no risk of losing anything not reproducible by the next build. Owner
  confirmed via `AskUserQuestion` before touching CI/CD config (new scope beyond the
  merge itself).
- **Verified live, post-redeploy:** pushed the `clean: true` fix (`f5b73edf`), watched
  the triggered `pkgdown.yaml` run to completion (`gh run watch`), then confirmed via
  `git ls-tree -r origin/gh-pages` the branch dropped from 981 to 650 files with zero
  remaining `ColonyManagerTutorial` matches. Live HTTP checks (after a ~15s GitHub
  Pages CDN propagation delay, confirmed via response `age`/`x-cache` headers, then
  polled to clear): `ColonyManagerTutorial.html`, `01ColonyManagerTutorial.html`,
  `06ColonyManagerTutorial.html`, and `_ColonyManagerTutorial.html` (the renamed file's
  own would-be published path) all now correctly 404; the doubled-path URL also 404s
  (as intended -- it was never meant to resolve); `colony-manager-guide.html` itself
  (200) now has **zero** remaining `.qmd`-targeting hrefs -- confirms S404's original
  branch fix, not just this session's rename, is also now genuinely live for the first
  time. Issue #124 is fully resolved live, not just fixed in source.
- **TDD Phase:** N/A throughout -- git merge conflict resolution (docs/ledger files
  only) and one CI/CD YAML config line, no `R/`/`tests/` code touched.

### 2026-07-21 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit 4e5baf5e -- S407 close-out (Session 408)
- **Deliverable:** Phase 0 ledger reconcile found one commit past the `CHANGELOG.md`
  frontier (`14ace3bb`, S407's deliverable entry below): `4e5baf5e` "docs: S407 --
  close-out handoff, self-assessment, HANDOFFS.md receipt". That commit only wrote
  `HANDOFFS.md`/`SESSION_NOTES.md` (the Phase 3A/3B/3D close-out material for S407's
  already-logged deliverable) -- no new engineering action beyond what the S407 entry
  below already records. The gap is the same self-referential pattern S406/S407 each
  backfilled for their predecessor's `HANDOFFS.md` `commit:` field (S405 backfilled
  `e3b45f9f`, S406 backfilled `27e43c69`): the close-out commit's own sha cannot be
  recorded inside itself, so this session's Phase 0 records it after the fact.

### 2026-07-21 · [issue #124] Fix ColonyManagerTutorial.Rmd's doubled-path link + exclude it from pkgdown; live-site link sweep (Session 407)
- **Deliverable:** owner-reported live 404 (`.../articles/articles/colony-manager-guide.qmd`)
  traced to `vignettes/ColonyManagerTutorial.Rmd:9` (the retired-tutorial stub, merged to
  `master` via S398, not the unmerged branch S404 fixed). Two stacked defects: (1) a relative
  link with a doubled `articles/` path segment -- this file itself renders under
  pkgdown's `/articles/`, so its own `articles/`-prefixed relative link doubled to
  `/articles/articles/...`; (2) the same issue-#124 `.qmd`-vs-`.html` defect class. Fixed
  by retargeting the link to the absolute published URL
  (`https://rmsharp.github.io/nprcgenekeepr/articles/colony-manager-guide.html`), and,
  owner-directed, additionally stopped the retired stub from being published at all:
  renamed `vignettes/ColonyManagerTutorial.Rmd` -> `vignettes/_ColonyManagerTutorial.Rmd`
  (`git mv`) and updated `.Rbuildignore`'s pattern to match. pkgdown's `build_articles()`
  skips any vignette whose filename starts with `_` (documented convention, already used by
  this project's own `vignettes/manual_components/_*.Rmd` child documents) -- verified
  against the installed pkgdown 2.2.0's actual `package_vignettes()` source (not assumed),
  which confirmed the rename excludes the file from both the built tarball (`R CMD build`
  + `tar tzf`, re-verified) and the pkgdown article build. This makes the file's own
  "never part of the public pkgdown site" claim actually true -- previously false, since no
  `_pkgdown.yml` exclusion existed and a locally-built `docs/articles/ColonyManagerTutorial.html`
  artifact was found as evidence pkgdown had been building and serving it. Full regression
  suite re-run clean (0 failed / 0 error / 0 warning) though no `R/`/`tests/` code was
  touched. **Owner also directed a full live-site link sweep** of
  `https://rmsharp.github.io/nprcgenekeepr/` (all 13 published articles plus the
  articles/reference/news index hub pages): fetched each page, resolved every internal
  `href` to a fully-qualified URL via proper relative-link resolution (not string-matching),
  and HTTP-checked all 238 unique targets. Findings: (a) the one 404 above (fixed this
  session); (b) `colony-manager-guide.html`'s own 6 `.qmd`-targeting links (the original
  issue-#124 defect) still show live -- these return HTTP 200, not 404, because pkgdown's
  Quarto build also copies the raw `.qmd` source alongside the rendered `.html`, so the link
  "works" but serves the wrong content; this is the fix already committed on the unmerged
  `fix/figure2-contrast-engineering-2.0.0-release` branch (S404), not yet deployed, not a
  new finding; (c) no other broken or misdirected links found across all remaining 231
  targets. TDD Phase: N/A throughout -- markdown link, filename rename, and
  `.Rbuildignore` pattern only, no `R/`/`tests/` code touched, confirmed via an explicit
  pre-work `AskUserQuestion` (same precedent as S401-404). See `BACKLOG.md` and the issue
  #124 comment thread for the full write-up.

### 2026-07-21 · [ad hoc] Tag CRAN-submitted commit as v2.0.0, bump master to 2.0.0.9000 (Session 407)
- **Deliverable:** owner-directed release engineering, on `master`. Tag the
  exact commit `CRAN-SUBMISSION` records as uploaded to CRAN
  (`db54d3257a1655a5582c3b201136f0ec868575bb`, 2026-07-17) as `v2.0.0`, then
  move `master`'s development version forward so work isn't blocked on
  CRAN's pending review outcome.
- **Actions:** created annotated tag `v2.0.0` at the recorded submission
  commit and pushed it to `origin`. Bumped `DESCRIPTION`'s `Version` from
  `2.0.0` to `2.0.0.9000`; added a matching `NEWS.Rmd`/`NEWS.md`
  "2.0.0.9000 (development version)" heading. Added a `BACKLOG.md` note on
  the CRAN item recording that the owner has since learned CRAN requires a
  version increment for any resubmission -- a future fix-and-resubmit ships
  as `2.0.1`, never a second `2.0.0` attempt, so the `v2.0.0` tag will never
  need to move.
- **Verification:** `pkgload::load_all()` confirmed the package loads
  cleanly with the bumped version (`packageVersion()` reports
  `2.0.0.9000`); `NEWS.Rmd` rendered cleanly to `NEWS.md` via
  `rmarkdown::render()`. Grepped `R/`/`tests/` for hardcoded `"2.0.0"`
  strings -- all are `lifecycle::deprecate_*(when = "2.0.0", ...)`
  historical markers or comments, none compare against the live package
  version, so none needed changing.
- **TDD Phase:** N/A -- metadata/release-engineering only (`DESCRIPTION`,
  `NEWS.Rmd`/`NEWS.md`, `BACKLOG.md`), no `R/`/`tests/` code touched.

### 2026-07-20 · [ad hoc] Render engineering-the-2.0.0-release.qmd + audit 6 articles for the issue-#124 link defect class (Session 406)
- **Deliverable:** owner-directed. (1) Render `vignettes/articles/engineering-the-2.0.0-release.qmd`
  and confirm clean render. (2) Audit the other 6 `vignettes/articles/*.qmd` files
  (age-sex-pyramid, breeding-group-formation, fg-se-validation, genetic-value-analysis,
  offline-focal-animal-workflow, studbook-quality-control) for the same defect class
  issue #124 found in `colony-manager-guide.qmd` -- cross-article links resolving to raw
  `.qmd` source instead of rendered `.html` -- and fix any found.
- **Result:** `quarto render` of `engineering-the-2.0.0-release.qmd` succeeded cleanly
  (exit 0, 0 warnings/errors). The 6-file audit found zero links of any kind in any of
  the 6 files (not just zero `.qmd`-specific links) -- verified via a positive control
  (the same search pattern against 2 files known to contain real links, returning 46/44
  matches) before trusting the null result, rather than reporting "0 findings" from a
  bare zero-match grep alone. No fixes were needed; no `.qmd` file content changed.
- **Verification:** documentation-only action, no `R/`/`tests/` code touched; TDD Phase
  N/A (verification/audit, zero edits made). Discipline documented as
  `PROJECT_LEARNINGS.md` Learning 373.

### 2026-07-20 · [ad hoc] Branch-merge-strategy decision for fix/figure2-contrast-engineering-2.0.0-release (Session 405)
- **Deliverable:** owner-picked from the Phase 0 priorities-list `AskUserQuestion` --
  resolve the DECISION NEEDED item (first flagged S402, tracked in `BACKLOG.md` since
  S404) on whether to merge the branch now or keep accumulating work on it.
- **Decision (via `AskUserQuestion`):** keep accumulating further article work on
  `fix/figure2-contrast-engineering-2.0.0-release`; do not open a PR/merge yet. All
  four fixes already on the branch (S401-S404) remain independently verified and
  complete; none are blocked by staying unmerged. `BACKLOG.md` item left open
  (decision recorded, not resolved) since the branch itself is still unmerged and the
  merge-vs-continue choice will be revisited again in a future session.
- **Verification:** documentation-only action, no `R/`/`tests/` code touched; TDD
  Phase N/A (decision-recording bookkeeping, not implementation).

### 2026-07-20 · [issue #124] Fix broken "Read deeper" links in colony-manager-guide.qmd (Session 404)
- **Deliverable:** owner-picked from the Phase 0 priorities-list `AskUserQuestion` --
  fix the 10 broken "Read deeper" links on the live published `colony-manager-guide`
  article (issue #124, filed S400, owner-reported URGENT): all resolved to raw `.qmd`
  source files (triggering browser downloads) instead of the intended rendered
  `.html` pages. Same branch as S401-S403 (`fix/figure2-contrast-engineering-2.0.0-release`,
  owner explicitly scoped this session to stay off `master`). No `R/`/`tests/` code
  touched; TDD phase N/A throughout (markdown link hrefs only, confirmed via an
  explicit pre-work `AskUserQuestion`, same precedent as S401-403).
- **Approach decision (pre-work `AskUserQuestion`):** issue #124 offered two options --
  root-cause the pkgdown/Quarto `.qmd`->`.html` auto-rewrite, or directly retarget the
  10 links to `.html`. Verified first: a bare local `quarto render` of this project
  (no pkgdown involved, no `type: website` in `vignettes/articles/_quarto.yml`) leaves
  `.qmd` hrefs unrewritten too -- falsifying the issue's "pkgdown's mixed-mode build
  doesn't perform the rewrite" framing. The rewrite is a Quarto `type: website`/`book`
  project feature this directory's `_quarto.yml` never enables, under pkgdown or
  otherwise; fixing that would mean adding `type: website`, a bigger cross-cutting
  change to the documented mixed-mode pkgdown/Quarto integration -- out of scope for
  this Effort-S fix per `SAFEGUARDS.md`. Owner confirmed: direct link retarget.
- **Fix:** changed all 10 `.qmd` hrefs to `.html` directly in
  `vignettes/articles/colony-manager-guide.qmd` (lines 26, 50, 99-103, 374, 534 --
  2 in-prose `engineering-the-2.0.0-release` references, the 6-link Section 2
  function-group table, and 2 more `fg-se-validation`/`engineering-the-2.0.0-release`
  in-prose references). Pre-verified all 7 distinct link targets exist live at the
  exact same relative path (`curl` HTTP 200 for each `https://rmsharp.github.io/
  nprcgenekeepr/articles/<name>.html`) before editing. Post-edit: `quarto render`
  succeeded cleanly; grepped the rendered output directly and confirmed all 7
  targets resolve to `.html` hrefs with zero remaining `.qmd` hrefs.
- **Documented:** `PROJECT_LEARNINGS.md` Learning 372 (corrects Learning 368's
  "pkgdown fails to perform the rewrite" framing to "the rewrite mechanism was
  never enabled for this project type"). `BACKLOG.md`'s issue #124 item resolved;
  added a new tracked item for the still-open branch-merge decision (first flagged
  in S402's handoff, carried through S403/S404 without a `BACKLOG.md` entry until
  now).
- **Note:** issue #124 stays open on GitHub -- the fix is on the unmerged/unpushed
  branch, not yet live on the published site.

### 2026-07-19 · [ad hoc] Verify the low-contrast Mermaid defect in colony-manager-guide.qmd -- not affected, applied theme:default defensively anyway (Session 403)
- **Deliverable:** owner picked this item from the S401-authored `BACKLOG.md` "Up
  Next" list (via the Phase 0 priorities-list `AskUserQuestion`) -- verify the
  low-contrast Mermaid defect S401 flagged as "near-certainly" also present in
  `colony-manager-guide.qmd:115`'s diagram (same bare frontmatter, same pkgdown
  mixed-mode Quarto pipeline as Figure 2). Same branch as S401/S402
  (`fix/figure2-contrast-engineering-2.0.0-release`). No `R/`/`tests/` code
  touched; TDD phase N/A throughout (Quarto vignette-article frontmatter,
  confirmed via an explicit pre-work `AskUserQuestion`, same precedent as
  S401/S402).
- **Verification result: NOT affected.** Fetched the live published page and
  rendered it in headless Chrome -- `colony-manager-guide.qmd`'s diagram
  (`flowchart LR`, plain nodes, zero `subgraph` blocks) renders with clean,
  legible light-lavender node boxes and dark text, no muddy/dark-on-dark look.
- **Root cause, corrected from Learning 369:** Learning 369's claim that "none
  of the loaded stylesheets... define any `--mermaid-*` custom property" does
  not hold -- `deps/bootstrap-5.3.8/bootstrap.min.css` (pkgdown's bundled
  Bootstrap) *does* define them at `:root`. The actual defect is narrower and
  specific to **subgraph/cluster styling**: `--mermaid-fg-color--lightest`
  (cluster background) and `--mermaid-fg-color` (cluster title text) are BOTH
  derived from `--bs-body-color` (the page's dark body-text color) -- a
  dark-on-dark formula bug. Plain `.node` styling uses a different, sane pair
  (`--mermaid-node-bg-color: RGBA(var(--bs-primary-rgb), 0.1)`, a light tint,
  vs. dark text) that renders fine. Confirmed directly: the live
  `engineering-the-2.0.0-release.html` page (S401/S402's fix not yet
  merged/deployed) still shows Figure 2's subgraph titles rendering
  barely-legible gray-on-dark-gray right now, while its plain node boxes
  inside are fine -- the same live page proves both halves of this diagnosis
  at once. `colony-manager-guide.qmd`'s diagram has no `subgraph` blocks, so
  it structurally cannot hit the broken code path.
- **Methodology note:** a standalone `quarto render` is not a faithful proxy
  for the pkgdown-built site's CSS environment where subgraphs are involved --
  confirmed the local render links a *different*, Quarto-generated
  `bootstrap-<hash>.min.css` (not pkgdown's shared `deps/bootstrap-5.3.8/`
  copy). `quarto render` remains valid for confirming a `theme: default` FIX
  (which bypasses the CSS-variable path entirely via literal colors), but is
  not reliable evidence for reproducing or ruling out the *unfixed* defect --
  that requires checking the actual live/pkgdown-built page.
- **Owner decision (via `AskUserQuestion`):** apply `format: html: mermaid:
  theme: default` to `colony-manager-guide.qmd`'s frontmatter anyway, as a
  defensive/future-proofing measure even though verification showed it isn't
  currently needed (in case a subgraph is ever added to this diagram).
  Re-rendered and re-verified via `quarto render` + headless-Chrome screenshot
  after applying -- diagram still renders cleanly (Mermaid's own literal
  default-theme colors), no regression.
- **Diff:** `vignettes/articles/colony-manager-guide.qmd` only -- 3 lines
  added (frontmatter `format.html.mermaid.theme: default`). Recorded
  `PROJECT_LEARNINGS.md` Learning 371 (corrects/refines Learning 369); removed
  the resolved item from `BACKLOG.md`'s "Up Next" list.

### 2026-07-19 · [ad hoc] Fix Figure 2's subgraph-title/node-box text overlap in engineering-the-2.0.0-release.qmd (Session 402)
- **Deliverable:** owner picked this item from the S401-authored `BACKLOG.md` "Up
  Next" list (via the Phase 0 priorities-list `AskUserQuestion`) -- both Figure 2
  subgraph titles ("After -- R/appUI.R + R/appServer.R, port 6013"; "Before --
  inst/application/, port 6012") wrapped onto extra lines that rendered fully
  hidden behind the top of the first child node box beneath them (`appUI.R`/
  `ui.r`). Same branch as S401 (`fix/figure2-contrast-engineering-2.0.0-release`).
  No `R/`/`tests/` code touched; TDD phase N/A throughout (Mermaid diagram markup,
  confirmed via an explicit pre-work `AskUserQuestion`, same precedent as S401).
- **Root cause:** confirmed via a full-page headless-Chrome screenshot of the
  rendered article that Mermaid's default subgraph-title vertical-space
  reservation assumes roughly one line; a title long enough to word-wrap gets no
  extra room, so wrapped lines render underneath (hidden by) the first child
  node's box. The wrap point itself was unpredictable: the "Before" title's
  un-splittable `inst/application/,` token forced a 3-line wrap while the
  visually-similar "After" title wrapped to only 2 lines at a near-identical box
  width -- caught only by cropping tightly over each title/box boundary with `PIL`
  after a full-page screenshot looked "mostly fixed."
- **Fix (two parts):** (1) pinned the exact wrap point with a manual `<br/>`
  inside each subgraph's bracketed label text, instead of trusting Mermaid's
  automatic word-wrap, so both titles wrap to a matched, predictable 2 lines; (2)
  added `%%{init: {"flowchart": {"subGraphTitleMargin": {"top": 30, "bottom":
  5}}}}%%` as the first line of the `{mermaid}` code cell to reserve enough
  vertical space for that now-fixed 2-line height -- confirmed supported by
  Quarto's bundled Mermaid runtime (`mermaid.min.js`, v11.2.0 as of Quarto
  1.7.33, `grep`-confirmed for the `subGraphTitleMargin` key).
- **Verification:** `quarto render` clean; headless-Chrome screenshots at each
  iteration, cropped with `PIL` directly over both subgraph title/box boundaries,
  confirmed both titles now render fully above their node boxes with no
  clipping/overlap. Figure 4 (the unrelated TDD-cycle state diagram, not a
  flowchart with subgraphs) re-checked as a regression guard -- unaffected,
  S401's contrast fix (`format: html: mermaid: theme: default`) still intact.
- **Diff:** `vignettes/articles/engineering-the-2.0.0-release.qmd` only -- 1 line
  added (the init directive) + 2 subgraph-title lines edited (added `<br/>`).
  Recorded `PROJECT_LEARNINGS.md` Learning 370; removed the resolved item from
  `BACKLOG.md`'s "Up Next" list.

### 2026-07-19 · [ad hoc] Fix low-contrast Mermaid diagram colors in engineering-the-2.0.0-release.qmd Figure 2 (Session 401)
- **Deliverable:** owner flagged low contrast in Figure 2 (the monolith-vs-modular
  architecture diagram) via a screenshot of the published article. Fix scoped to
  contrast only, on a new branch `fix/figure2-contrast-engineering-2.0.0-release` --
  "other aspects of the article" explicitly deferred to future sessions. No
  `R/`/`tests/` code touched; TDD phase N/A (Quarto vignette-article rendering
  config, not production R code).
- **Root cause:** the published page renders both Mermaid diagrams in this article
  client-side via `mermaid.js` (`<pre class="mermaid mermaid-js">`), using Quarto's
  bundled `mermaid-init.js`. Its fallback path applies a `themeCSS` built entirely
  from `--mermaid-*` CSS custom properties (`--mermaid-node-bg-color`,
  `--mermaid-fg-color`, etc.) -- but those variables are normally defined by
  Quarto's own bootswatch SCSS theme pipeline (`:root { --mermaid-*: ...; }`),
  which only runs when Quarto compiles its own site/book theme. pkgdown's
  mixed-mode Quarto integration (`vignettes/articles/_quarto.yml`) renders each
  `.qmd` to a fragment and re-wraps it in pkgdown's own Bootstrap template --
  Quarto's `--mermaid-*` variable block is never generated or linked, so every
  themed color falls back to an undefined/inherited value on the live site,
  producing the muddy, low-contrast look the owner flagged. Confirmed empirically:
  fetched the live published HTML plus its `mermaid-init.js`/`mermaid.css`, and
  none of the loaded stylesheets (`bootstrap.min.css`, `mermaid.css`, etc.)
  define any `--mermaid-*` custom property.
- **Fix:** added `format: html: mermaid: theme: default` to this qmd's own YAML
  frontmatter -- Quarto's documented "Mermaid's Built-in Themes" escape hatch
  (quarto.org/docs/authoring/diagrams.html). It makes Quarto emit
  `<meta name="mermaid-theme" content="default">`, which switches
  `mermaid-init.js` onto its other branch: Mermaid's own complete, literal-color
  "default" theme, with no dependency on any page-supplied CSS variable.
  Document-scoped (applies to both Mermaid diagrams in this file: Figure 2's
  architecture flowchart and Figure 4's TDD-cycle state diagram), not
  site-wide -- `colony-manager-guide.qmd`'s own separate Mermaid diagram is
  unaffected and very likely has the identical defect (unverified, flagged in
  `BACKLOG.md` for a future session, out of scope here).
- **Verification:** `quarto render` on the file confirmed the meta tag lands in
  the output `<head>`. Rendered the file, served it in headless Chrome
  (`--headless --screenshot`), and visually confirmed both diagrams now render
  with clear, legible contrast (pale lavender/yellow fills, black text) in place
  of the dark, muddy boxes in the owner's screenshot. Also attempted the real
  `pkgdown::build_article()` pipeline for higher-fidelity verification; aborted
  it after it triggered an unrelated, unrequested favicon-cache regeneration
  (`pkgdown/favicon/`, a live external-API call) as a side effect of
  `init_site()` -- deleted that untracked output rather than committing it, and
  relied on the `quarto render` + headless-browser verification as sufficient
  (matches `SAFEGUARDS.md`'s "Documentation (Quarto, LaTeX)" build-equivalent row).
- **Known follow-up (separate item, not fixed here):** Figure 2's subgraph
  title text ("After -- R/appUI.R + ...", "Before -- inst/application/, ...")
  visibly overlaps/truncates against the first child node box in both
  subgraphs -- a pre-existing layout defect, orthogonal to contrast, still
  present after this fix. Flagged in `BACKLOG.md` for the "other aspects of
  the article" follow-up session the owner named.
- **Process gap (self-flagged):** Phase 1B (claim the session before any
  technical work) was skipped this session -- investigation and the fix began
  immediately after branch creation, with the `SESSION_NOTES.md`/`HANDOFFS.md`
  claim written only retroactively at close-out. See `PROJECT_LEARNINGS.md`
  Learning 369 and this session's `SESSION_NOTES.md` self-assessment.

### 2026-07-18 · [issue #124] File urgent issue: colony-manager-guide's "Read deeper" links point to .qmd not .html (Session 400)
- **Deliverable:** owner reported that Section 2's "Read deeper (R-API
  walkthrough)" table column on the published colony-manager-guide article
  links to raw `.qmd` source instead of rendered `.html` -- file one urgent
  GitHub issue. No `R/`/`tests/` code touched; no code fix this session;
  TDD phase N/A.
- **Investigation:** `WebFetch`-confirmed live on
  https://rmsharp.github.io/nprcgenekeepr/articles/colony-manager-guide.html
  -- all 6 Section-2-table links resolve to `.qmd`. Grepped
  `vignettes/articles/colony-manager-guide.qmd` and found 4 more instances of
  the same pattern outside the table (lines 22, 46, 370, 530; 10 total
  affected links). Confirmed via `grep -rl '\.qmd)' vignettes/articles/*.qmd`
  that no other article source file has this pattern -- isolated to this one
  file. Root-caused to `vignettes/articles/_quarto.yml`'s Quarto-project
  declaration (`project: render: ['*.qmd']`), which is what makes the
  `.qmd`-link-with-auto-rewrite-to-`.html` convention available in Quarto --
  the source correctly uses that convention, but pkgdown's mixed-mode Quarto
  build is evidently not performing the rewrite.
- **Result:** filed [issue #124](https://github.com/rmsharp/nprcgenekeepr/issues/124)
  (`bug` label; no "urgent" label exists in this repo, so priority is
  stated in the title/body instead) with the full link inventory, root
  cause, and two candidate fixes (root-cause the pkgdown/Quarto rewrite, or
  directly retarget the 10 links to `.html`) for the implementing session to
  choose between. Added a `BACKLOG.md` "Up Next" entry (READY, Effort S)
  pointing at the issue so it surfaces in the next Phase 0 priorities list.

### 2026-07-18 · [ad hoc] S399 HANDOFFS.md receipt commit-sha backfill, closed same-session
- **Deliverable:** filled in this session's own `HANDOFFS.md` receipt's `commit: pending`
  placeholder with the real deliverable commit sha (`d911ce8f`), matching the
  S331-S398 precedent of closing this within the same session rather than leaving it
  for the next session's Phase 0 reconcile.

### 2026-07-18 · [BL-CRAN200] Process CRAN's real incoming-pretest auto-check result for the 2.0.0 submission (Session 399)
- **Deliverable:** owner pasted CRAN's auto-processed email for the real
  2026-07-17 `devtools::submit_cran()` submission -- verify the actual
  `00check.log` files (not just the email summary) and update
  `BACKLOG.md`/`HANDOFFS.md` accordingly. No `R/`/`tests/` code touched;
  TDD phase N/A.
- **Result:** fetched both `00check.log`s directly
  (win-builder.r-project.org incoming-pretest logs). Windows r-devel and
  Debian both returned `Status: 1 NOTE` -- the standard incoming-feasibility
  note only (new submission, archived-package history, DESCRIPTION spelling
  flags), no WARN/ERROR. Timing breakdown holds the S392-395 fixes on the
  real submission: Windows `tests` 205s / `examples` 79s / `vignette
  outputs` 65s; Debian `tests` 89s / `examples` 43s / `vignette outputs`
  29s.
- **Reconciled a discrepancy:** the email footer reported "Check time in
  seconds: 604" -- 4s over the 600s mark that caused the S392 archival-class
  rejection -- yet the submission was not rejected. Explicitly searched the
  raw check log text for "Overall checktime" / "checktime": neither phrase
  appears anywhere. The only "Tested elapsed times" occurrence is quoted
  historical CRAN-db-override metadata from the 2025-07-29 archival, not a
  fresh flag on this submission. Second data point (after S397's 588s) that
  the win-builder-style footer "Check time" is not the same measure as
  CRAN's own incoming-pipeline "Overall checktime" gate.
- **Also fixed:** a stale cross-reference in `BACKLOG.md`'s CRAN item --
  it cited "cran-comments.md's 2026-07-17 update note," a section already
  removed by the S397 addendum trim (`3c7486b9`) before this session
  started. Corrected in the same edit. `cran-comments.md` itself needed no
  change -- it already reflects accurate pre-submission code-changes/timing
  content per the S397-established "final values only, no session
  narrative" convention.
- **Status:** package is "pending a manual inspection," per the email,
  typically within 10 working days. No further engineering action open
  unless CRAN's reviewer responds with a rejection or change request.
  Corrected `BACKLOG.md`'s stale "DECISION NEEDED" tag (flagged S398) to
  "BLOCKED -- awaiting CRAN's manual review."

### 2026-07-17 · [ad hoc] S398 addendum -- investigate and resolve post-commit screenshot drift
- **Deliverable:** a post-commit `git status` showed 30 of 33 just-committed screenshot
  files as locally modified again (small byte-size deltas, plausibly capture-to-capture
  PNG-encoding non-determinism, except `potential_parents_results.png` at ~33x larger).
  Investigated via file mtimes and a visual re-check of the uncommitted content (still
  correct, just a different capture) before deciding how to proceed -- discarded the
  drift (`git restore`) back to the already-verified committed state rather than
  re-committing an unreviewed variant, then re-confirmed `quarto render` still resolves
  cleanly against the restored state.

### 2026-07-17 · [ad hoc] S398 HANDOFFS.md receipt commit-sha backfill, closed same-session
- **Deliverable:** filled in this session's own `HANDOFFS.md` receipt's `commit: pending`
  placeholders with the three real close-out commit shas (`ac8033d0` deliverable,
  `cf3ee7db` ledger/backlog/plan, `b1ac7508` this receipt itself), matching the
  S331-S347 precedent of closing this within the same session rather than leaving it
  for the next session's Phase 0 reconcile.

### 2026-07-17 · [BL-Document2PhaseD] Execute Document 2 Phase D -- claim-source audit, pkgdown asset fix, retire ColonyManagerTutorial.Rmd (Session 398)
- **Deliverable:** `docs/planning/document2-colony-manager-guide-plan.md` §6 Phase D --
  the publish gate for `vignettes/articles/colony-manager-guide.qmd`. TDD phase N/A
  throughout (docs/vignette work, no `R/`/`tests/` code touched).
- **Full claim-source audit (workstream Phase 6):** 5 parallel agents, one per article
  section, independently re-verified every claim against current `R/` source, live
  `Rscript`/`pkgload::load_all()` checks, `gh issue view`, and file existence. Found and
  fixed 3 genuine errors (Mermaid pipeline diagram missing two real edges -- Pedigree->
  Breeding-Groups, GVA->Genetic-Diversity; founders-CSV column list typo "sires"->"sire"
  plus 3 missing columns `ancestry`/`origin`/`status`; "three export buttons" claim
  undercounting a 12-button tab). **Load-bearing finding:** all three "still broken"
  callouts drafted in Phase C (Excel-upload corruption, Custom sex-ratio, Potential-
  Parents `fromCenter`) had actually been fixed the same day (S350/351/353, 2026-07-10)
  -- the article was shipping stale bug warnings for bugs that no longer existed.
- **Owner decision (`AskUserQuestion`): full correction** -- regenerated the 2 affected
  screenshots (extended `colony-manager-guide-screenshots.R`'s Custom-sex-ratio block to
  exercise the now-working `customSexRatio` numeric input, the N7 demo Phase C deferred)
  and rewrote all 3 callouts to describe the fixed behavior, rather than a text-only
  patch leaving stale pre-fix images in place. Self-caught and fixed two issues during
  this work: (1) the first re-run placed the new Custom-ratio group formation *before*
  the Genetic Diversity capture, silently changing the state its heatmap depends on (6
  seeded/kinship groups -> 7 fresh ones) -- caught by re-inspecting the regenerated
  image, fixed by moving the block to run last; (2) Custom-ratio group formation is a
  stochastic search (`Number of simulations` default 10) -- one run's exact per-group
  sizes did not reproduce on the next run with identical inputs, so the prose describes
  the setup and stochastic nature rather than asserting one run's numbers as fact.
- **Structural fix (`SAFEGUARDS.md` "Verify Render-Dependency Completeness"):** an
  isolated `quarto render` passed cleanly, but `pkgdown::build_article()` -- this
  project's first image-heavy pkgdown article ever built -- revealed the 33 image
  references would 404 on the actual published site: pkgdown only copies non-qmd files
  living *under* `vignettes/articles/`, not a sibling directory. Fixed by `git mv
  vignettes/shiny_app_use vignettes/articles/shiny_app_use`, rewriting all 33 image
  paths + the capture script's `SHOT_DIR`, and updating `.Rbuildignore` (removed the
  now-stale `^vignettes/shiny_app_use$` line; the existing `^vignettes/articles$`
  pattern already covers the new nested location). Re-verified images now resolve in
  the built `pkgdown_site/`.
- **`ColonyManagerTutorial.Rmd` fate resolved (`AskUserQuestion`): retire/redirect** --
  replaced its 748-line content with a short redirect note to the new public article.
  Deleted 6 now-orphaned tracked screenshot files that existed only for the retired
  tutorial (`examplePedigreeTutorial.png`/`_with_alleles.png`, the 3
  `opening_screen_top/middle/bottom.png` crops Phase A had already flagged for
  retirement, `pb_cleared_focal_animals_combined.png` + its `.idraw` source), confirming
  zero remaining references first.
- **Verification:** `quarto render` clean (zero missing images, zero unresolved
  `@sec-`/`@tbl-`/`@fig-` refs, Mermaid embedded) before and after the path fix;
  `pkgdown::build_article("articles/colony-manager-guide")` succeeds, all 33 images
  resolve in the built site; `R CMD build .` + `tar tzf` confirms zero CRAN risk
  (neither the article, the retired tutorial, nor the screenshot folder ship); 3
  sibling articles spot-checked (`engineering-the-2.0.0-release.qmd` clean;
  `breeding-group-formation.qmd`/`age-sex-pyramid.qmd` fail identically on
  `library(nprcgenekeepr)`, confirmed pre-existing per S348's own precedent, not a
  regression); full regression suite 0 failed / 0 error / 0 warning.
- **`BACKLOG.md`:** removed the resolved Document 2 item (plan fully executed, no phase
  remains).

### 2026-07-17 · [ad hoc] Submit v2.0.0 to CRAN, maintainer confirmation clicked (Session 397 addendum, owner action)
- **Action:** owner ran `devtools::submit_cran()` (per the resubmit decision
  recorded above) -- package uploaded successfully to the CRAN submission
  team -- and clicked the maintainer-email confirmation link the same day.
  v2.0.0 is now fully in CRAN's review queue. Awaiting CRAN's actual review
  outcome; asynchronous and owner-only. `BACKLOG.md`'s CRAN item updated to
  reflect the confirmed-submitted status.
- **Submitted commit:** `CRAN-SUBMISSION` records `Date: 2026-07-17
  14:51:08 UTC`, `SHA: db54d3257a1655a5582c3b201136f0ec868575bb` (the
  wording-fixes commit) -- confirming exactly which tree state CRAN
  received.

### 2026-07-17 · [ad hoc] Wording fixes to cran-comments.md (Session 397 addendum)
- **Deliverable:** owner edits -- dropped "real" from "A real submission
  attempt" (all submissions are real; the word added nothing); split the
  misspelled-words NOTE into its own bullet using standard CRAN-comments
  phrasing ("Words identified as possible misspellings in DESCRIPTION: ...
  are all correctly spelled").

### 2026-07-17 · [ad hoc] Trim cran-comments.md to code changes + final timing values (Session 397 addendum)
- **Deliverable:** owner feedback -- `cran-comments.md` (a CRAN-reviewer-facing
  document) had accumulated a session-by-session process narrative (S392-397
  "update"/"follow-up" paragraphs, dead-end investigations, staleness caveats)
  that doesn't belong in front of a reviewer. Rewrote to: what code changed to
  fix the "Overall checktime" rejection (one bullet list), and the final
  timing values only. Process history stays in `CHANGELOG.md`/
  `PROJECT_LEARNINGS.md`, where it already lived in full. ~2000 words -> ~470
  words (76% reduction).

### 2026-07-17 · [ad hoc] Process win-builder Windows-devel result for CRAN 2.0.0 checktime fix -- confirms fix, owner decides to resubmit (Session 397)
- **Deliverable:** processed S396's dispatched `devtools::check_win_devel()`
  result (owner pasted the arrived `00check.log` and email text) -- confirm
  whether the S392-395 checktime fixes clear CRAN's 10-minute mark, update
  `cran-comments.md`/`BACKLOG.md`, present the resubmit/wait/hold decision.
- **Result:** `checking tests` `245s -> 200s` (-45s); `examples` 80s and
  `re-building of vignette outputs` 65s essentially unchanged (no further
  safe lever, per S395). Win-builder's own reported totals (email footer,
  not a bracket-sum of the log's `[Ns]` steps): Installation time 30s,
  **Check time 588s** -- down from the S392-394 cycle's 655-656s, and the
  first result since the archived rejection to land under CRAN's 600s mark
  (12s margin). `Status: 1 NOTE` (incoming feasibility only, no WARN/ERROR).
  Caveat carried forward: win-builder's "Check time" is a proxy for CRAN's
  own "Overall checktime" (the real incoming-pipeline figure that rejected
  S392's submission), not proven identical.
- **Caught before shipping:** almost cited a bracket-summed total (476s)
  reconstructed from the pasted log alone, before re-reading
  `cran-comments.md`'s own S393 precedent (which explicitly distinguishes
  "summed timed steps" from "the email's reported total check time") and
  asking the owner for the full email text -- revealed the real figure
  (588s) is 112s higher than the bracket-sum. Documented as
  `PROJECT_LEARNINGS.md` Learning 364.
- **Updated:** `cran-comments.md` (new 2026-07-17 narrative paragraph +
  "Test environments" section, flagging win-builder R-release/R-oldrelease/
  R-hub as stale relative to the S392-395 fixes) and `BACKLOG.md`'s CRAN
  item.
- **Owner decision (via `AskUserQuestion`, owner-only per SAFEGUARDS/the
  runbook HARD STOP): resubmit now.** Next action is the owner running
  `devtools::submit_cran()` themselves; no further engineering action this
  cycle unless CRAN rejects it again.

### 2026-07-16 · [ad hoc] Dispatch win-builder Windows-devel re-check for CRAN 2.0.0 gate (Session 396)
- **Deliverable:** owner picked this item from the Phase 0 priorities list;
  `BACKLOG.md`'s CRAN item named one specific next step -- dispatch a fresh
  win-builder Windows-devel check to confirm S395's checktime fixes before the
  resubmit/wait/hold decision. Deliberately scoped to just this single check
  (not the fuller S390 pattern of x3 win-builder variants + R-hub), matching
  the item's own Effort S next-step scope rather than expanding it.
- **Preflight:** confirmed a clean, in-sync `git status` (`master` ==
  `origin/master`) before dispatch. Unlike R-hub (which tests GitHub's copy and
  needed a push in S390), `devtools::check_win_devel()` builds and uploads a
  tarball from the LOCAL working tree, so no push was a precondition here.
- **Dispatched:** `devtools::check_win_devel(quiet = FALSE)` from the project
  root. Build succeeded cleanly (`nprcgenekeepr_2.0.0.tar.gz`, vignettes
  rebuilt OK, routine empty-directory pruning under `inst/extdata/` only).
  Confirmed uploaded to win-builder.r-project.org's R-devel queue; results due
  to `rmsharp@me.com` by ~10:46 PM 2026-07-16. `git status` re-confirmed clean
  after the build (temp build artifacts never touched the tracked tree).
- **Verification:** dispatch confirmed via the `devtools::check_win_devel()`
  console output naming the results ETA; actual pass/fail results are not yet
  available this session (asynchronous, mirroring the S361->S362 and
  S390->S391 split -- processing them is the next session's work).
- TDD Phase: N/A (release-mechanics/verification action; no `R/`/`tests/` code
  changed this session, matching S391's precedent classification).

### 2026-07-16 · [ad hoc] Re-open CRAN checktime investigation with wider scope (Session 395)
- **Deliverable:** owner redirected the closed-out S392-394 effort mid-session,
  explicitly authorizing test STRUCTURE changes and previously-protected iteration
  counts that those sessions deliberately avoided. A 7-agent investigation
  workflow re-profiled the full CRAN-mode test suite from scratch (methodology
  fix: `NOT_CRAN` must stay *unset*, not `"true"`, to mirror real CRAN skip
  behavior -- caught and corrected before the baseline was taken) and produced
  risk-rated, empirically-verified fix proposals for every top offender file.
- **Landed Bundle A (5 files, Low risk, zero coverage loss, all verified
  empirically against pre-existing assertions):**
  `tests/testthat/test_pkgdown_reference_config.R` (compute
  `pkgdown::as_pkgdown()` once instead of 3x, 13.1s -> 3.76s locally --
  **later discovered CRAN-irrelevant, see below**); `test_reportGV.R` (hoist
  3 identical `guIter=1000L` fixture computations to 1, 4.98s -> 2.64s);
  `test_appServer_dynamicTabs.R` (build `appUI()` once, share between 2
  read-only checks, 1.75s -> 0.25s); `test_appServer_server.R` +
  `test_appServer_logging.R` (several tests left 4-7 downstream Shiny child
  modules un-stubbed despite reading nothing from them -- added the missing
  stubs, matching a pattern already used correctly elsewhere in the same files;
  3.85s -> 1.53s and ~2.07s -> 0.30s respectively).
- **Full regression suite re-confirmed clean after Bundle A:** `0 failed | 0
  error | 0 warning`, same `1387` tests / `179` skipped as the pre-change
  baseline (identical coverage, no tests dropped). Suite wall clock (local,
  CRAN-mode): `94.1s -> 74.6s`.
- **Investigated and explicitly NOT changed (documented, not silently
  dropped):** `test_fillGroupMembers*.R` (gated `skip_if_not(user=="rmsharp")`
  -- zero effect on CRAN regardless of any fix); `test_getPotentialParents.R`'s
  one 3.3s test (genuine full-scale regression test for a real historical bug,
  no test-level lever); further `guIter`/`iter` reduction in examples/vignettes
  (the `guIter<=30` degeneracy guardrail re-verified as noisy/non-monotonic --
  guIter=25 fails, 20 and 30 pass -- no safe threshold found);
  `Config/testthat/parallel: true` (mechanism confirmed real and CRAN-honored,
  ~1.65x measured local speedup, but requires a `Config/testthat/edition: 3`
  migration across 264 files not audited this session -- deferred as a
  separate future effort); the ~121s "untimed overhead" gap (confirmed
  structural: only 18 of 99 `R CMD check` steps get individual timing; not a
  package-specific defect).
- **New findings flagged for owner attention (not actioned this session):**
  `reportGV()`/`groupAddAssign()`/`summary.nprcgenekeeprErr.R`'s unseeded
  `@examples` measured a 25% chance per check run of triggering a real
  `checkFgDegeneracy()` warning -- a live robustness gap, independent of
  checktime. `test_addAnimalsWithNoRelative.R` runs the same expensive
  full-colony computation as the CRAN-irrelevant fillGroupMembers files, but
  unconditionally (no skip guard) -- genuine ~5.85s local CRAN cost this
  session's baseline missed (runs outside any `test_that()` block); no fix
  proposed yet.
- **Bundle C dropped after discovery, not landed:** `test_groupAddAssign.R`'s
  proposed `iter=1000->50` fix turned out to be pointless for the stated goal
  -- every one of its 7 `test_that()` blocks is gated
  `skip_if_not(Sys.info()[["user"]]=="rmsharp")`, so the whole file already
  contributes zero time to any real CRAN/win-builder check (confirmed
  empirically, same class of finding as the fillGroupMembers files above).
  Owner redirected to investigate the `test_addAnimalsWithNoRelative.R` lead
  instead.
- **Landed instead: `test_addAnimalsWithNoRelative.R` fixture swap (Low
  risk).** `addAnimalsWithNoRelative()` is a trivial NA-fill loop whose own
  roxygen `@examples` already use a smaller `qcPed` fixture (280 rows) instead
  of the full `examplePedigree` (3694 rows) this test used, with no
  historical-bug significance found in git log for the larger scale. Swapped
  to the smaller, already-precedented fixture; updated the 3 assertions to
  the freshly-verified deterministic values (`length(kin)`: 2416 -> 591;
  replaced an arbitrary relative-count assertion on `"1SPLS8"` with a direct
  `is.na()` check -- it is in fact the NA-fill branch at this scale, more
  precisely testing the function's actual purpose; added a length-34 check on
  `"0DAV0I"`, independently corroborated against the value already shipped in
  the function's own roxygen example). Local cost: ~5.85s -> ~0.01s -- the
  single largest genuinely-CRAN-relevant fix found this session, since this
  file (unlike the fillGroupMembers files) has no skip guard and runs
  unconditionally on every real CRAN check.
- **Full regression suite re-confirmed clean after both changes:** `0 failed
  | 0 error | 0 warning`, same `1387` tests / `179` skipped as the original
  baseline throughout (dev-mode `pkgload::load_all()` profiling). Cumulative
  local wall clock (CRAN-mode, single `test_dir()` run): `94.1s -> 68.1s`
  (~28% reduction).
- **Critical correction, caught before close-out by running the actual
  build-equivalent, not just dev-mode profiling:** `R CMD build .` +
  `R CMD check --as-cran --timings` against the real built tarball (first
  attempt errored on a stale library path from running outside the
  renv-activated working directory -- re-run correctly) revealed that the
  `test_pkgdown_reference_config.R` fix -- this session's headline number --
  is **CRAN-irrelevant**: `_pkgdown.yml` is `.Rbuildignore`'d and never
  ships in the built tarball, so all 3 of that file's tests already skip on
  every real CRAN/win-builder check (`_pkgdown.yml absent; guard not
  applicable`, confirmed in the real `testthat.Rout`) -- a fact `BACKLOG.md`
  already recorded from S392 that this session's dev-mode-only baseline
  missed. The fix is a harmless local-dev-loop speedup only, same class of
  dead end as the dropped `groupAddAssign()` change. The `test_appServer_*`/
  `test_reportGV.R`/`test_addAnimalsWithNoRelative.R` fixes are confirmed
  genuinely CRAN-relevant (none appear in any skip category of the real
  check). **Real `R CMD check --as-cran --timings` result:** `examples` 22s,
  `tests` 59s, `re-building of vignette outputs` 17s, `0 errors | 0 warnings
  | 1 note`, `[ FAIL 0 | WARN 0 | SKIP 208 | PASS 3210 ]`. See
  `cran-comments.md` for full detail; not yet confirmed against win-builder.
- TDD Phase: REFACTOR (test-file structure/fixture/parameter changes only; no
  new production-code behavior -- precedent: S393's vignette `n=1000->500`
  parameter reduction).

### 2026-07-16 · [ad hoc] Close out the CRAN checktime effort: real progress, practical floor reached (Session 394)
- **Deliverable:** S393's fresh win-builder Windows-devel result confirmed the
  `simulatedKValues.Rmd` fix was real (`checking re-building of vignette outputs`
  `79s -> 66s`), but the gain was fully offset by run-to-run noise elsewhere
  (`examples`/`checking R code`/manual generation each moved up a few seconds
  between runs) -- total check time landed at `656s`, essentially unchanged from
  S392's `655s`. Investigated one more angle (the "tests" phase's long tail of
  small Shiny-`testServer()`-driven files) and concluded, with owner agreement, that
  no further safe lever exists -- closing out this three-session effort.
- **Caught and corrected a profiling methodology error before it caused a wrong
  action:** looping `testthat::test_file()` calls sequentially within one R session
  inflated `test_appServer_server.R`'s apparent cost by ~5.8x (22.951s looped vs.
  3.929s in true isolation) -- re-profiling all 8 candidate files individually (each
  its own fresh session) gave a combined total of only ~16.9s, all of it genuine
  `appServer()`-wiring coverage deliberately added by prior sessions to close a real
  0%-coverage gap, not redundant overhead. Documented as `PROJECT_LEARNINGS.md`
  Learning 362 -- a third, distinct way a local profiling number can misrepresent
  reality, alongside Learnings 360/361.
- **Also confirmed (targeted search):** no test file silently relies on an
  expensive default iteration count (`reportGV()`'s `guIter=1000L`, `geneDrop()`'s
  `n=1000L`, `gvaConvergence()`'s `nMax=3000L`) -- every real call either overrides
  it or runs on a negligibly small pedigree.
- **Net result across S392-394:** `tests` reduced `334s -> 245s` (robust,
  reproducible across 2 independent win-builder runs); `vignette rebuild` reduced
  `79s -> 66s` (robust, reproducible); total check time reduced from an extrapolated
  ~720s to a stable ~655-656s. Real, meaningful, verified progress -- but still
  ~55s over CRAN's 10-minute mark, and no further safe, mechanical lever was found
  after three rounds of investigation (declined to consolidate real Shiny test
  coverage for an estimated ~17s-local/60-85s-Windows ceiling, given the cost to
  test independence/diagnostic quality).
- **Next:** owner decision, not a further engineering task -- resubmit at the
  current margin, wait for a quieter win-builder day, or hold for new ideas.
  `BACKLOG.md`'s CRAN item retagged DECISION NEEDED accordingly.
- TDD Phase: N/A (investigation and documentation only this session; no code
  changed).

### 2026-07-16 · [ad hoc] Confirm S392's checktime fix worked, find it's still ~55s short, trim further (Session 393)
- **Deliverable:** S392's win-builder Windows-devel re-check came back. Fetched the
  verbatim `00check.log`/`testthat.Rout`/`nprcgenekeepr-Ex.timings` (not the summary
  email) rather than trusting "Status: 1 NOTE" at face value.
- **Confirmed working exactly as designed:** `testthat.Rout` shows all 10
  `skip_on_cran()` additions fired correctly (under the "On CRAN (193)" category
  alongside 183 pre-existing skips) -- `tests` phase dropped `334s -> 245s` (−89s),
  `0 FAIL / 0 WARN`, 3099 passed / 231 skipped.
- **But the total is still short of the goal:** summed timed steps dropped
  `628s -> 534s`, and the email's reported total check time dropped to `655s`
  (10 min 55s) -- an improvement, but still ~55s OVER the 10-minute mark, close
  enough that resubmitting now risks repeating the exact rejection. Owner chose
  (`AskUserQuestion`) to keep optimizing rather than resubmit at this margin.
- **Diagnosed why "vignette rebuild" (79s) hadn't moved despite the S392
  `gvaConvergence.Rmd` fix:** per-vignette render timing showed
  `ColonyManagerTutorial.Rmd` (16.58s locally, the largest by far) is actually
  `.Rbuildignore`'d (line 31) -- excluded from the real build entirely, so its cost
  was never part of the problem. `a2interactive.Rmd` (10.07s) is the real dominant
  vignette, blocked from further trimming by the same `checkFgDegeneracy` risk found
  in S392. `gvaConvergence.Rmd` was never the dominant contributor, explaining the
  unchanged aggregate figure.
- **Found and fixed one more real, safe lever:** `vignettes/simulatedKValues.Rmd`'s
  `createSimKinships(..., n = 1000L)` call cost 4.07s alone on a 17-row pedigree (a
  superlinear-in-`n` cost); reduced to `n = 500L` (1.28s, a 68% cut for a 50% `n`
  reduction) after confirming the mean-sd/row-count pattern is unchanged, preserving
  the short-vs-long convergence narrative. Updated the two hardcoded "1000" captions
  and the `stats_1000` variable name to match; re-rendered clean.
- **Broader sweep for other missed levers:** grepped all vignettes and R/ roxygen
  `@examples` for other large iteration-like literals; found only two more
  candidates, both false alarms -- `R/calcFG.R`'s `n=1000` example runs on a 7-row
  toy pedigree (negligible), and `R/data.R:273`'s `guIter=10000` is inside `@source`
  prose describing one-time historical data generation, not a real executed
  example. `test_appServer_server.R` (557 lines, 27 `testServer()` blocks testing
  real app wiring) and the rest of the "tests" long tail (200+ files, mostly
  Shiny-testServer overhead) have no comparable iteration-count lever without
  cutting real coverage.
- **Verification:** full regression 0 failed/0 error/0 warning (CRAN mode, 3197
  passed/179 skipped, unchanged from S392's post-fix baseline).
- **Next:** dispatched `devtools::check_win_devel()` again to measure the real
  impact of this additional trim.
- TDD Phase: REFACTOR (vignette content/parameter reduction only; no production
  behavior change).

### 2026-07-16 · [ad hoc] Fix real CRAN incoming-check rejection: Windows "Overall checktime" > 10 min (Session 392)
- **Deliverable:** A real 2.0.0 submission (owner ran `devtools::submit_cran()`
  out-of-session; evidenced by the uncommitted `CRAN-SUBMISSION` dated
  2026-07-16 06:17 UTC, SHA matching the S391 close-out commit `03736837`) was
  **rejected** by CRAN's actual incoming automatic check -- distinct from the
  win-builder pretests this project's own sessions have been running, which do
  not exercise this gate. Windows r-devel flagged "Overall checktime 12 min >
  10 min" -- the same failure class ("Tested elapsed times") that archived this
  package in 2025.
- **Diagnosis:** Fetched verbatim `00check.log` for both flavors (not the email
  summary): the "Overall checktime" note is NOT in the check log itself -- it's
  a separate wall-clock summary CRAN's incoming pipeline computes only for real
  submissions. Windows: `checking tests ... [334s]` (dominant), `checking
  examples ... [79s]`, `checking re-building of vignette outputs ... [79s]`.
  Debian's equivalent run stayed under 5 min -- Windows-VM-speed-specific, not
  a universal regression. Local `pkgload::load_all()`-based profiling of the
  slowest test files was initially misleading: 3 files
  (`test_fillGroupMembers.R`, `test_fillGroupMembersWithSexRatio.R`,
  `test_groupAddAssign.R`) are gated on `skip_if_not(Sys.info()[...] ==
  "rmsharp")` and never run on CRAN/win-builder/R-hub at all, and
  `test_pkgdown_reference_config.R`'s tests skip immediately once
  `_pkgdown.yml` is absent -- confirmed `.Rbuildignore`'d (so absent from the
  real built tarball). A from-scratch `R CMD build .` + check hung for 30+
  minutes on this machine (0.6 CPU-seconds burned; apparently `renv` project
  auto-activation-related, persisted even with `R_PROFILE_USER` disabled) --
  abandoned in favor of `NOT_CRAN`-controlled `testthat::test_dir()` profiling,
  which correctly respects `skip_on_cran()` the same way a real CRAN check does.
- **Fix:** `skip_on_cran()` added to the 10 true gene-drop convergence-stress
  `test_that` blocks (`nMax = 3000L`/`800L`, full budget regardless of where
  the metric converges) in `test_gvaConvergence.R` (6 blocks) and
  `test_gvaConvergence_kinshipOverrides.R` (4 blocks); their cheap/structural
  siblings (`nMax <= 200L`) are untouched and still run everywhere. `guIter`
  reduced 100L->20L at the ~23 `test_reportGV.R` call sites whose assertions
  (`indivMeanKin`, `parentage`, `neSexRatio`/`neVariance`/kinship-matrix
  equality) are deterministic and do not depend on gu-magnitude; sites on the
  tiny 10-row `makeOriginTestPed()` fixture (already `guIter = 1000L` but
  cheap regardless) and the pre-existing `skip_on_cran()`-gated `fgSE` test
  were left untouched. `nMax` reduced 3000L->1600L (grid ceiling 1500L->800L)
  in `vignettes/gvaConvergence.Rmd`; re-rendered clean with
  `recommendedIter`/`converged`/`nRankable` all unchanged (800/TRUE/70) and
  every narrative claim still accurate.
- **Reverted, not applied:** lowering `guIter` in the `reportGV()`/
  `groupAddAssign()` roxygen `@examples` (3 source files:
  `R/reportGV.R`, `R/groupAddAssign.R`, `R/summary.nprcgenekeeprErr.R`) and in
  `vignettes/a2interactive.Rmd` (2 call sites) -- empirically confirmed (same
  seed/pipeline as each surface) this introduces a NEW `checkFgDegeneracy`
  warning ("Founder genome equivalents undefined") on that fixture at
  `guIter <= 30`, which would trade a timing NOTE for a real WARNING. Reverted
  to the original `guIter = 50`/`50L`; `man/*.Rd` regenerated back to
  byte-identical original content, confirmed via `git diff`.
- **Verification:** Full regression suite 0 failed/0 error/0 warning in both
  dev mode (`NOT_CRAN=true`: 3895 passed, 167 skipped) and CRAN mode
  (`NOT_CRAN` unset: 3197 passed, 179 skipped). Local CRAN-relevant test-file
  total dropped from ~70s to ~43s (~38%) in the controlled profiling (not an
  official `R CMD check --as-cran` timing -- that run hung on this machine;
  see Diagnosis above). `cran-comments.md` and `BACKLOG.md` updated to reflect
  the real rejection (not "gate fully clean") and this fix.
- **Dispatched (owner-approved via `AskUserQuestion`, mirroring the S361/S390
  precedent that pretest triggers are session-doable):**
  `devtools::check_win_devel()` -- results due by email ~11:59 AM 2026-07-16.
  Processing them is the next session's work (mirroring the S390->S391 split).
  `devtools::submit_cran()` itself remains owner-only per SAFEGUARDS.
- TDD Phase: REFACTOR (test/example/vignette runtime reduction; no production
  behavior change; full regression suite green throughout).

### 2026-07-16 · [ad hoc] Process win-builder + R-hub results for CRAN 2.0.0 gate -- fully clean (Session 391)
- **Deliverable:** Processed the win-builder x3 results (owner shared the 3
  emails) and R-hub ("hillocked-veery") once it completed, dispatched by
  Session 390 -- confirms the S389 `.Names=` NOTE is resolved and refreshes
  the CRAN 2.0.0 pre-submission gate.
- **Win-builder (verbatim `00check.log` read via `curl`, not just the email
  summary):** all three environments (R-devel, R-release, R-oldrelease)
  `0 errors | 0 warnings | 1 note` (expected incoming-feasibility note only).
  `* checking R code for possible problems ... OK` on all three -- confirms
  S389's fix resolved the deprecated `.Names=` NOTE on R-devel itself, the
  exact environment that originally flagged it. R-oldrelease's prior
  `groupAddAssign` >10s timing note did not recur. Only one URL
  (thoughtco.com, 400) flagged this cycle vs. two in an earlier cycle (the PMC
  URL's automated-checker flag appears intermittent, not a fixed pass/fail).
- **R-hub (read via `gh run view --log`, not just job conclusion):** all
  three platforms (linux/windows/macos, R-devel) `Status: OK` with zero notes,
  `[ FAIL 0 | WARN 0 | SKIP 221 | PASS 3140 ]` -- fully clean, improving on
  the S361/362 cycle's 1 WARN (the intermittent Windows `WriteXLS` flake);
  confirmed absent here, consistent with S363's `openxlsx` migration having
  fully resolved it.
- **Net result: the CRAN 2.0.0 pre-submission gate is clean across every
  environment run this cycle** (local macOS, win-builder x3, R-hub x3).
  Folded into `cran-comments.md` §Test environments and
  `docs/planning/cran-2.0.0-phase5-runbook.md`. Next: owner-only
  `devtools::submit_cran()` + maintainer-email confirmation click.
- TDD Phase: N/A (build/verify/release-mechanics action; no `R/`/`tests/`
  code changed this session).

### 2026-07-16 · [ad hoc] Re-trigger win-builder + R-hub for CRAN 2.0.0 gate; push local-ahead commits (Session 390)
- **Deliverable:** Owner picked "CRAN resubmission" from the Phase 0 priorities
  list; scoped this session (via `AskUserQuestion`) to re-trigger win-builder x3
  and R-hub now, mirroring the S361 precedent. Results are asynchronous
  (win-builder by email in ~15-30 min; R-hub via GitHub Actions) — a follow-on
  session folds them into `cran-comments.md`, mirroring the S361→S362 split.
- **Finding before dispatch:** `origin/master` was 5 commits behind local
  `master`, and one of those commits was S389's actual `.Names=` code fix
  (`264596b6`) — not documentation. R-hub checks the code **on GitHub**, not
  local working tree, so dispatching R-hub without pushing first would have
  silently re-tested the pre-fix code and produced a false confirmation.
  Confirmed via `git log origin/master..master` and `git branch -r --contains
  264596b6` (empty — fix was unpushed). Pushed to origin first (plain
  fast-forward, 5 commits, no force), confirmed via `AskUserQuestion` since
  pushing is a shared-state action beyond the original trigger scope.
- **Dispatched:** `devtools::check_win_devel()` / `check_win_release()` /
  `check_win_oldrelease()` — all three dispatched OK, results by email to
  `rmsharp@me.com` in ~15-30 min. `rhub::rhub_doctor()` confirmed clean setup;
  `rhub::rhub_check(platforms=c("linux","windows","macos"))` dispatched as run
  "hillocked-veery" (confirmed via `gh run list`), superseding the owner's own
  pre-fix "cyclopean-iguanodon" R-hub run (2026-07-16 ~01:15, triggered directly
  by the owner before this session, per owner confirmation — informational
  only, no session/CHANGELOG gap).
- **Verification:** Dispatch confirmed for all 4 triggers (3 win-builder + 1
  R-hub); actual pass/fail results are not yet available this session (async).
  Phase 3E runtime smoke test: n/a in the traditional sense — this deliverable
  IS the verification-in-flight; the actual confirmation (does S389's fix
  resolve the NOTE, do all platforms stay green) awaits results landing in a
  follow-on session.
- TDD Phase: N/A (build/verify/release-mechanics action; no `R/`/`tests/` code
  changed this session).

### 2026-07-16 · [ad hoc] Fix deprecated `.Names=` usage flagged by win-builder (Session 389)
- **Deliverable:** Owner ran `devtools::check_win_devel()` after S388's close-out
  and it returned a NOTE not previously on file: `checking R code for possible
  problems` flagged `structure(..., .Names = ...)` in
  `tests/testthat/test_getParamDef.R:27` as a deprecated special-name call. An
  R-devel-specific check — local R 4.6.1 does not reproduce it, so S388's local
  re-verify could not have caught it.
- **Fix:** Dropped the `structure()` wrapper entirely — `tokens <- list(param =
  ..., tokenVec = ...)` — since the names were already set by the inline
  `list(param=..., tokenVec=...)` construction; `.Names=` was a dead
  re-assertion, not a second names-setting. Zero behavior change.
- **Verification:** Confirmed no other live-code `.Names` occurrence exists
  (`R/data.R:337`'s is inside non-`@examples` roxygen prose, never parsed as
  code). Single-file test and full regression suite both clean (0 failed/0
  error/0 warning, 3238 passed, 169 skipped baseline unchanged). Not yet
  confirmed against win-builder itself — awaits the owner's next run.
- TDD Phase: N/A (redundant deprecated-syntax removal, no behavior change, not
  new implementation logic).

### 2026-07-16 · [ad hoc] Re-verify CRAN 2.0.0 local `--as-cran` gate on current master (Session 388)
- **Deliverable:** Re-ran `R CMD build .` + `R CMD check --as-cran --timings` on
  current `master` (`79380fba`) before the owner-only `devtools::submit_cran()`
  step, since 25 commits touched `R/`/`tests/`/`DESCRIPTION`/`NAMESPACE` since the
  last confirmed run (S359, `19ae5657`) — more than double the 9-commit threshold
  that triggered a mandatory re-run at S359 itself. Owner scoped this session to
  local re-verify only, via `AskUserQuestion`; win-builder/R-hub re-triggering
  deferred to the owner.
- **Result:** `0 errors | 0 warnings | 1 note` (expected incoming-feasibility note
  only). Timings unchanged within noise: examples 23s (slowest `groupAddAssign`
  1.486s), tests 87s, vignette rebuild 20s. `cran-comments.md`'s existing prose
  numbers remain accurate as written — no edit needed there.
- **Gotcha found and documented:** `R CMD check` run from outside the package root
  does not activate renv (`.Rprofile` only sources `renv/activate.R` from the
  package root), producing a false `ERROR: Package required but not available:
  'openxlsx'`. Fixed by running from the package root with `--output=<scratch-dir>`
  to keep check artifacts out of the repo tree. See `PROJECT_LEARNINGS.md`
  Learning 358.
- Updated `docs/planning/cran-2.0.0-phase5-runbook.md` and `BACKLOG.md`'s CRAN item
  with the re-verification result and the residual win-builder/R-hub staleness.
  TDD Phase: N/A (build/verify action, no `R/`/`tests/` code changed).

### 2026-07-15 · [issue #123] Update GitHub issue #123 to reflect partial, scoped closure (Session 387)
- **Deliverable:** Per `docs/planning/issue123-xarch5-column-schema-plan.md` §10
  decision 5, posted a comment to issue #123 (XARCH-5) summarizing S386's Phase 1
  implementation, linking the plan and the `BACKLOG.md` tracking entry, and naming
  the plan's own escalation triggers for the still-out-of-scope full S3
  `pedigree`/`gvReport` class rewrite. TDD N/A -- GitHub issue comment, no `R/` or
  `tests/` changed. The issue is left **OPEN** (not closed outright), per the
  plan's explicit instruction.
  https://github.com/rmsharp/nprcgenekeepr/issues/123#issuecomment-4986749021
- **Verification:** Confirmed post-hoc via `gh api repos/rmsharp/nprcgenekeepr/issues/123`
  -- `state: open`, `comments: 1` -- rather than trusting the CLI's returned URL alone.
- **Not done this session (unchanged from S386):** the other 9 hardcoded
  column-list duplicates; validation at any other pipeline stage
  (`setPopulation`->`groupAddAssign`); the `nprcgenekeeprGV` print-method wrinkle.

### 2026-07-15 · [issue #123] Implement Phase 1 of the XARCH-5 column-schema plan (Session 386)
- **Deliverable:** Implemented `docs/planning/issue123-xarch5-column-schema-plan.md` §7
  Phase 1 (S385's planning-session output), following `DEVELOPMENT_WORKSTREAM.md` under
  the project's Strict TDD contract (RED->GREEN->REFACTOR, REFACTOR declared unneeded).
- **Changes:** new `R/columnSchema.R` (`@noRd`) -- internal `.nprcColumnSchema` list,
  single source of truth for the 3 column-name vectors; `getRequiredCols()`/
  `getPossibleCols()`/`getIncludeColumns()` bodies replaced with one-line pass-throughs
  (byte-identical return values, zero exported-contract change, existing
  `expect_identical` pins unmodified and still green). New `R/assertRequiredColsPresent.R`
  (`@noRd`) -- `setdiff`+`stop()` validator mirroring the already-tested
  `checkKinshipOverrides()` idiom -- wired at 3 silent-drop sites: `R/qcStudbook.R:316`
  and `R/gvaConvergence.R:161` exactly as the plan specified; `R/reportGV.R` relocated
  from the plan's literal proposed site (before the `includeCols` intersect) to
  immediately before `founders$sex` -- see Gotcha below. Also implemented the plan's
  2 small consistency decisions: `R/correctUnknownParentMeanKinship.R:141`'s inline
  `c("id","sire","dam","sex","birth")` duplicate now calls `getRequiredCols()`; and
  `getPossibleCols()`'s roxygen no longer mismarks `birth` "(optional)" (Dragon 3).
- **New tests:** `tests/testthat/test_assertRequiredColsPresent.R` (new, 5 tests);
  `tests/testthat/test_reportGV.R` (+1 -- the reproduced-bug repro inverted into a RED
  test, now green); `tests/testthat/test_qcStudbook.R` (+1 -- Dragon 2's contrived-fault
  guard, via `mockery::stub`); `tests/testthat/test_gvaConvergence.R` (+1 -- mirrors the
  `reportGV.R` case).
- **Gotcha found via full-suite verification, not the plan's own cited pinned-test
  list:** the plan's literal guard placement (before `reportGV.R`'s `includeCols`
  intersect, i.e. before `calcFEFG()` is called) regressed `test_calcFEFG.R:66`
  ("reportGV surfaces the partial-parentage error through its real caller"), which
  calls `reportGV()` directly on `lacy1989Ped` -- a bundled dataset with NO `sex`
  column at all -- expecting the call to reach `calcFEFG()`'s own pre-existing
  partial-parentage diagnostic. Root-caused via `grep -n` on the current file (not the
  plan's cited line numbers) and fixed by relocating the guard to `founders$sex`'s
  actual first dereference, after `calcFEFG()`. See `PROJECT_LEARNINGS.md` Learning 357.
- **Verification:** full regression suite 0 failed/0 error/0 warning, 169 skipped
  baseline (unchanged, matches pre-session exactly); 0 new lints on all 13 changed/new
  files (`lintr`); `devtools::check()` Status: OK (0 errors, 0 warnings, only the
  pre-existing installed-size INFO); live scripted Phase 3E smoke test (not only
  `testthat`) confirmed the fixed `reportGV()` error path and unaffected
  `qcStudbook()`/`gvaConvergence()` behavior in one interactive R session.
- **Not in scope** (plan §10, unchanged by this session): the other 9 hardcoded
  column-list duplicates found during S385's research; validation at any other pipeline
  stage (`setPopulation`->`groupAddAssign`); the half-built `nprcgenekeeprGV`
  print-method wrinkle. GitHub issue #123 itself not updated this session (an
  external/shared-system action outside this session's approved TDD-gate scope) --
  flagged in `BACKLOG.md` as an owner follow-up per the plan's own §10 recommendation
  (partial, scoped closure, not closed outright).

### 2026-07-15 · [issue #123] Architecture plan for XARCH-5 string-column-keyed pipeline (Session 385)
- **Deliverable:** `docs/planning/issue123-xarch5-column-schema-plan.md` -- a planning
  session (no implementation), following `ARCHITECTURE_WORKSTREAM.md`, for issue #123
  (XARCH-5, "Rigid pipeline threads fat data frames keyed by string column names, no
  validated seam"), tagged `DECISION NEEDED -- needs its own planning session; Effort L`
  in `BACKLOG.md` since the 2026-07-11 tracker-reconciliation audit filed it.
- **Method:** a 35-agent background research pass (6 independent inventory readers, 24
  adversarial re-verifiers, 4 independent alternative-design agents, 1 judge; 0 agent
  errors, 479 tool calls), all re-deriving claims from current source at HEAD `b534e08d`
  rather than trusting the issue text.
- **Key findings:** (1) reproduced the issue's defect by execution, not inference --
  `reportGV()` called on a pedigree missing `sex` returns successfully with no error/
  warning, silently omitting the `sex` column and corrupting `nMaleFounders`/
  `nFemaleFounders`/`total` from 3/17/20 to 0/0/0; (2) traced the full
  `qcStudbook -> setPopulation/trimPedigree -> createPedTree -> kinship/calcA ->
  reportGV -> groupAddAssign` chain and found only 3 functions in the whole chain
  perform an explicit, named-column existence check with a clear diagnostic; (3) found
  9 additional hand-maintained column-name-vector duplicates beyond the 3 the issue
  names (`getRequiredCols`/`getPossibleCols`/`getIncludeColumns`); (4) found a 3rd
  unguarded site with the byte-identical silent-drop pattern, not named by the issue:
  `R/gvaConvergence.R:161`; (5) confirmed all 8 pipeline functions and all 3 column
  getters are `@export`ed -- no internal-only cover exists, raising real CRAN-timing
  risk (v2.0.0 mid-resubmission) for any exported-contract change.
- **Decision:** rejected the issue's literal recommendation (a full S3
  `pedigree`/`gvReport` class, each pipeline stage accepting/returning it) as
  disproportionate -- only 3 of 7 implied functions actually round-trip a
  pedigree-shaped data.frame, and every touched function is exported mid-resubmission,
  the same risk category the sibling issue #122 plan's Dragon 5 already flagged.
  **Adopted instead:** consolidate the 3 getters into one internal schema (zero
  exported-contract change, existing pinned tests as the regression guard) plus an
  explicit `setdiff`+`stop()` validator (reusing an idiom already tested in this
  codebase, `checkKinshipOverrides.R`) at the 2 issue-named sites plus the 3rd found
  site -- judged to fit one ordinary TDD session (Effort S/M), not the Effort L
  originally estimated for the literal recommendation.
- **`BACKLOG.md`:** updated the issue #123 item from `DECISION NEEDED` to `READY`,
  Effort S/M, pointing at the plan for implementation.
- **TDD:** N/A -- planning-only session, no implementation code, per the project's
  established precedent for planning/audit sessions (matches S372's and S365's
  close-outs).
- **Verification:** full regression suite re-run after the doc-only session: 0 failed/
  0 error/0 warning, 169 skipped baseline (unchanged, as expected for a session with
  zero `R/`/`tests/` changes). Every line-number citation in the plan was independently
  re-read and confirmed against current source in this session (not taken on the
  research workflow's word alone).

### 2026-07-15 · [ad hoc] Delete 18 stale untracked leftover files (Session 384)
- **Deliverable:** Resolved `BACKLOG.md`'s "clean up stale untracked leftover files"
  item (filed Session 383). Deleted 18 untracked files confirmed dead, in two
  batches.
- **Batch 1 (the 6 originally flagged, S383):** `PED_GV_AUDIT_2026-05-30.html`
  (rendered audit output, already the subject of a full owner-decided policy
  resolution at Session 371 that deleted it once before -- yet present again,
  with its *original* 2026-05-30 filesystem creation timestamp intact, not a
  fresh regeneration); `R/agePyramidPlot.R`, `R/fixGenotypeCols.R`,
  `R/getSimSires.R`, `R/makeGeneticDiversityDashboard.R` (each removed from git
  tracking as dead code in a past session -- S268/S280/S285/S300 -- via real
  `git rm` commits that also deleted the working-tree copy at the time);
  `inst/_pkgdown.yml` (migrated to root `_pkgdown.yml` at S354).
- **Batch 2 (12 more, discovered mid-deletion when removing batch 1 revealed
  further previously-hidden untracked files in `git status`):**
  `tests/testthat/test_fixGenotypeCols.R` / `test_makeGeneticDiversityDashboard.R`
  (companion tests to batch-1 dead source files, deleted alongside them in the
  same original commits per those commits' own messages); `test_runGeneKeepR_alias.R`
  (tested an inverted, obsolete design reversed at issue #110/S276; superseded by
  the currently-tracked `test_runModularApp_alias.R`); `vignettes/manual_components/
  _bg_algorithm.Rmd` / `_bg_formation.Rmd` (deletion commit `45335ea9` explicitly
  calls them "confirmed-orphan vignette source files," superseded by the
  currently-tracked `_breeding_group_algorithm.Rmd`/`_breeding_group_formation.Rmd`);
  7 `vignettes/shiny_app_use/*.png` screenshots (explicitly flagged in `HANDOFFS.md`
  as "stale (2024-12-16, pre-migration) and must not be reused as-is," not
  referenced by any filename in the currently-tracked `ColonyManagerTutorial.Rmd`,
  very likely among the "8 deleted" screenshots from the S347 Phase B regeneration
  pass that never actually left disk).
- **Verification:** Each file independently checked via `git log`/`git show` history
  and cross-reference grep against currently-tracked files before deletion -- none
  referenced by any live document, test, or NAMESPACE export. Full regression suite
  re-run after both batches: 0 failed/0 error/0 warning, 169 skipped baseline
  (unchanged). No `R/`/`tests/` package behavior changed -- only dead files removed.
  TDD N/A (file deletion, no implementation).
- **Open question, not resolved this session:** why previously and verifiably
  deleted files (some removed via real `git rm` commits that delete the
  working-tree copy, one the subject of its own dedicated resolution session)
  reappeared on disk with original timestamps intact. Checked and ruled out:
  iCloud Drive sync (not on an iCloud-synced path), an in-progress Time Machine
  backup, relevant local Time Machine snapshots, `~/.Trash` contents, and shell
  history for `cp`/`rsync`/`tar` commands touching these paths -- none explain it.
  Deleting some of the files also caused previously-hidden untracked files (batch
  2) to newly appear in `git status`, itself unexplained (`core.untrackedCache`/
  `core.fsmonitor` are unset, so a stale-cache explanation doesn't obviously apply
  either). See `PROJECT_LEARNINGS.md` Learning 355.
- **BACKLOG.md:** item resolved/pruned per the established "none remaining -- see
  CHANGELOG.md" pointer convention.

### 2026-07-15 · [ad hoc] Decline the `setLabKeyDefaults()`/`getDemographics()` `getSiteInfo()` design decision -- no code change (Session 383)
- **Deliverable:** Resolved `BACKLOG.md`'s "`setLabKeyDefaults()`/`getDemographics()`'s
  unguarded `getSiteInfo()` call sites need a design decision" item (split off Session
  382). Decision: **decline -- no code change.** Both remaining sites
  (`R/setLabKeyDefaults.R:44` default arg, `R/getDemographics.R:39`) already satisfy
  their own documented "let it throw, caller wraps it" contract in every real,
  reachable call path, so no fix was warranted.
- **Investigation:** `getDemographics()` has exactly 2 real callers
  (`R/getLkDirectAncestors.R:46`, `R/getPedigreeSource.R:103`), and both already wrap
  the *entire* `getDemographics(...)` call in `tryCatch(warning=,error=) -> NULL` --
  the same guard pattern Session 382 used as its mirror source one function up. Since
  `getDemographics()`'s body is `siteInfo <- getSiteInfo(); setLabKeyDefaults(siteInfo);
  labkey.selectRows(...)`, any error `getSiteInfo()` throws inside it already propagates
  out and is already caught by that existing outer guard today. `setLabKeyDefaults()`'s
  own `getSiteInfo()` default argument is dead code in-package (its sole in-package
  caller, `getDemographics()`, always passes `siteInfo` explicitly); its own `@examples`
  already show an external caller passing `getSiteInfo(expectConfigFile = FALSE)`
  explicitly and wrapping the whole `setLabKeyDefaults(...)` call in `tryCatch`.
- **Options considered (pre-RED scope `AskUserQuestion`):** (1) decline -- no code
  change [chosen]; (2) make `getSiteInfo()` itself defensive (fixes ~20 callers at
  once, but risks silently using the WRONG center's `baseUrl`/`schemaName`/
  `lkPedColumns` on a malformed config -- wrong data instead of a loud, caught
  failure); (3) wrap these 2 sites locally anyway, redundant with the existing outer
  guard, at the cost of contradicting the functions' documented contract. No RED/GREEN/
  REFACTOR gates -- no implementation was written.
- **BACKLOG.md:** item resolved/pruned per its established "none remaining -- see
  CHANGELOG.md" pointer convention.
- **See:** `PROJECT_LEARNINGS.md` Learning 354.

### 2026-07-14 · [ad hoc] Guard 2 of the 4 remaining unguarded `getSiteInfo()` call sites (Session 382)
- **Deliverable:** Guarded `R/getPedigreeSource.R:83` and `R/getLkDirectAncestors.R:26` --
  the 2 of `BACKLOG.md`'s "4 remaining unguarded `getSiteInfo()` call sites" (filed
  Session 378, standing DECISION NEEDED since Session 380) that have an existing local
  fail-soft pattern to mirror. Investigation confirmed `getSiteInfo()` genuinely can throw
  (a present-but-malformed config file makes its regex-based parser raise an uncaught
  error, distinct from a missing config file, which only warns and falls back to
  defaults), and that both sites' own functions already wrap an adjacent `getDemographics()`
  call in `tryCatch(warning=,error=) -> NULL` -- `getPedigreeSource()`'s own docstring
  already promises `NULL` on any labkey-source fetch failure, a contract the unguarded
  `getSiteInfo()` call was silently breaking. The other 2 sites
  (`R/setLabKeyDefaults.R:44`, `R/getDemographics.R:39`) have no local pattern to mirror
  and are split off into a new, separately-scoped `BACKLOG.md` item (need a genuine design
  decision, not a mirrored guard).
- **Fix:** Wrapped each `getSiteInfo()` call in `tryCatch(error=)` **only** (not
  `warning=`), `flog.debug`+`stri_c`+`NULL`-fallback, mirroring the adjacent
  `getDemographics()` guard's idiom but deliberately narrower: `getSiteInfo()`'s
  missing-config warning is an intentional non-failure fallback that must still
  propagate (a naive full `warning=,error=` mirror would have silently swallowed it and
  regressed `getLkDirectAncestors.R`'s own pre-existing warning-propagation test).
- **Verification:** Strict TDD (pre-RED scope decision, PRE-RED->RED, RED->GREEN,
  GREEN->REFACTOR, all via `AskUserQuestion`; REFACTOR declared unneeded). RED confirmed
  1 new failing test per target file against unmodified source. GREEN: both target files
  pass; full regression suite 0 failed/0 error/0 warning (169 skipped baseline, unchanged);
  `devtools::check()` 0 errors/0 warnings/0 notes; `lintr` 0 lints on all 4 changed files.
  Phase 3E performed with real (non-mocked) evidence: built an actual malformed config
  file (missing `center`, reusing `test_appUI_siteinfo.R`'s established fixture) and
  called both real functions directly -- both returned `NULL` cleanly with no uncaught
  error; also re-confirmed the missing-config warn-and-continue path still propagates and
  completes correctly, unbroken by the new guard.
- **See:** `PROJECT_LEARNINGS.md` Learning 353.

### 2026-07-14 · [ad hoc] Fix the stale-library gap blocking full `shinytest2::AppDriver` checks (Session 381)
- **Deliverable:** Fixed `BACKLOG.md`'s "stale system-library `openxlsx` gap" item (filed
  Session 380 after 3 sessions -- S378/S379/S380 -- independently hit a
  `modBreedingGroupsServer: unused argument (kinshipMatrix = ...)` signature blocking
  live `shinytest2::AppDriver` checks). Root-cause investigation corrected the
  diagnosis: the actual stale copy was NOT in a system library (R 4.6.1's system
  library has neither `nprcgenekeepr` nor `openxlsx` installed at all) but in the
  **renv project library**'s own installed `nprcgenekeepr` copy, which nobody had
  reinstalled since before issue #122 Phase 2 added the `kinshipMatrix` parameter.
- **Fix:** `R CMD INSTALL --library=<renv project library> .` (current source) --
  `renv::install(".")` was tried first and fails on this project with
  `cp: cannot copy a directory ... into itself` (it naively copies the whole project
  tree into its own nested `renv/staging/`; plain `R CMD INSTALL` respects
  `.Rbuildignore` and avoids this).
- **Verification:** RED reproduced the exact documented failure via the
  S378-380 recipe (`shiny.appobj` built from `pkgload::load_all()` source, passed
  directly to `AppDriver$new()`). GREEN re-ran the identical script post-install:
  construction succeeded, `set_inputs(mainNavbar = "Breeding Groups")` +
  `wait_for_idle()` succeeded, tab confirmed active -- both construction- and
  interaction-level proof in one pass. Full regression suite re-run clean (0
  failed/0 error/0 warning, 169 skipped baseline, unaffected since no `R/`/`tests/`
  source changed); the pre-existing directory-based E2E suite
  (`test-e2e-breeding-groups-module.R`) passed 7/7 both before and after. No R
  source changed -- pure environment/library fix; REFACTOR declared unneeded.
- **See:** `PROJECT_LEARNINGS.md` Learning 352.

### 2026-07-14 · [ad hoc] Guard 3 lower-severity unguarded `getSiteInfo()` call sites (Session 380)
- **Deliverable:** Fixed the non-LabKey subset of `BACKLOG.md`'s "4 lower-severity
  unguarded `getSiteInfo()` call sites" item (filed by Session 378 alongside the
  `appServer.R`/`appUI.R` ORIP-tab-gate sibling pair, resolved Sessions 378-379).
  Owner-scoped via `AskUserQuestion` at Phase 1 to the 3 sites tied to the same
  issue #50 crash class, leaving the item's own explicitly-flagged 4 LabKey-fetch
  sites for a separate re-scoping session (now standing alone in `BACKLOG.md`).
  **(1)** `R/modORIPReporting.R:148` (`output$siteInfo`'s `else` branch) and `:244`
  (`downloadORIPReport`'s `else` branch) -- both call
  `getSiteInfo(expectConfigFile = FALSE)` unguarded; dead in the real running app
  (`appServer.R` always passes a non-`NULL` `siteConfig`), reachable only if
  `modORIPReportingServer()` is mounted directly without one. Wrapped both in
  `tryCatch` mirroring `appServer.R`'s/`appUI.R`'s established pattern
  (`futile.logger::flog.warn` on error, fall back to `NULL`); the existing
  `is.null(config)`/`!is.null(config)` checks downstream already fail closed.
  **(2)** `R/appServer.R:124` -- `getSiteInfo()$homeDir` inside the "Debug on"
  checkbox's `observeEvent`, live-reachable via a real user action (not boot).
  Wrapped in `tryCatch`; on error, logs via `flog.warn` and skips registering the
  file appender entirely (fails closed to whatever logging destination is already
  active, rather than the observer erroring out). Strict TDD RED->GREEN throughout
  (REFACTOR declared unneeded -- 0 lints, each fix a direct mirror of an
  established pattern); 1 pre-RED `AskUserQuestion` scope decision (which of the
  item's 3 heterogeneous classes to fix this session) plus the 3 phase gates. 3 new
  tests: 2 in `tests/testthat/test_modORIPReporting_server.R`, 1 in
  `tests/testthat/test_appServer_logging.R` (using `expect_no_warning()`, not
  `expect_no_error()`, per `PROJECT_LEARNINGS.md` Learning 347(d)'s empirically-
  confirmed condition class -- a Shiny observer's uncaught error surfaces to
  `shiny::testServer()` as `base::warning()`, not a thrown error). Found and fixed
  an unrelated, pre-existing test-isolation gap while writing the third test: the
  process-global `futile.logger` "nprcgenekeepr" registry could carry a stale file
  appender from an earlier `test_that()` block's now-deleted `withr::local_tempdir()`
  into this test, making the *already-fixed* ORIP-gate guard's own `flog.warn()`
  call throw "cannot open the connection" for a reason unrelated to the code under
  test -- fixed by explicitly resetting the logger to console at the top of the new
  test rather than depending on file-internal test execution order.
- **Verification:** target files: `test_modORIPReporting_server.R` 14/14 passed;
  `test_appServer_logging.R` 4/4 passed. Full suite 3225 passed/169 skipped/0
  failed/0 error/0 warning. `devtools::check()` 0 errors/0 warnings/0 notes. lintr 0
  lints on all 4 changed files. `grep -rn "getSiteInfo(" R/` confirmed the 4
  LabKey-fetch sites remain untouched, exactly as scoped. Phase 3E: the two
  `modORIPReporting.R` sites are dead code in the live app (no live path can reach
  them), so `shiny::testServer()` coverage is the correct and only ceiling. The
  `appServer.R:124` site is live-reachable, so a live `shinytest2::AppDriver` check
  was attempted (malformed config, then set the Debug checkbox input) -- boot
  proceeded correctly past the malformed-config ORIP gate (confirmed by its `WARN`
  log line), but the session failed to stabilize before the checkbox interaction
  could fire, on the SAME already-documented `modBreedingGroupsServer`
  stale-system-library signature `PROJECT_LEARNINGS.md` Learnings 349(d)/350
  catalogued -- recognized by signature match (third occurrence), not
  re-diagnosed. Per Learning 349(d)'s own practical rule (prefer `testServer()` over
  `AppDriver` for wiring/interaction-level checks in this stale-library
  environment), the already-GREEN `testServer()` coverage is treated as the
  sufficient verification ceiling for this call site; see Learning 351 for the full
  detail.

### 2026-07-14 · [ad hoc] Guard the unprotected `getSiteInfo()` call in `appUI.R`'s default argument (Session 379)
- **Deliverable:** `R/appUI.R:20`'s `appUI <- function(siteInfo = getSiteInfo(expectConfigFile
  = FALSE))` evaluated its default-argument expression on first reference inside the
  function body -- which happens on every real call (`runGeneKeepR()` calls `appUI()`
  with no argument). A present-but-malformed site-config file (e.g. missing the
  required `center` key) made `getParamDef()` `stop()`, propagating uncaught and
  crashing app boot via UI construction -- the sibling of the `appServer.R` half fixed
  in Session 378, found by that same session's live Phase 3E check and filed as a
  precisely-scoped `BACKLOG.md` item (fix shape + ready-to-run RED test included).
  Fixed by changing the default to `NULL` and resolving it via a body-level `tryCatch`
  mirroring `appServer.R`'s exact pattern (log via `futile.logger::flog.warn`, fall back
  to `NULL`), guarding the downstream `showOrip` computation with `!is.null(siteInfo)
  &&` so the `NULL` fallback fails closed (ORIP tab hidden) instead of crashing
  `file.exists()` on a `NULL` argument. Applied the BACKLOG item's fix shape and RED
  test recipe verbatim; added a second RED test (fails-closed ORIP-tab-absence
  assertion) mirroring `test_appServer_server.R`'s existing pair. Strict TDD RED->GREEN
  throughout (REFACTOR declared unneeded); 2 new tests in
  `tests/testthat/test_appUI_siteinfo.R`.
- **Verification:** target test file 2/2 passed; `test_appUI_version.R` (regression)
  3/3 passed; full suite 3217 passed/169 skipped/0 failed/0 error/0 warning;
  `devtools::check()` (both plain and `--no-manual` variants) 0 errors/0 warnings/0
  notes; lintr 0 lints on both changed files. Phase 3E: live `shinytest2::AppDriver`
  boot performed (not declared N/A) -- `shinyApp(ui = appUI(), server = appServer)`
  construction against a malformed config succeeded without crashing (the exact point
  that crashed pre-fix), and the emitted `flog.warn` log line confirmed the `tryCatch`
  guard's catch branch executed as designed. The subsequent browser-stability check hit
  an unrelated, pre-existing environment issue (the exact `modBreedingGroupsServer`
  stale-system-library signature `PROJECT_LEARNINGS.md` Learning 349(d) already
  documented) -- recognized by signature match rather than re-diagnosed; see Learning
  350 for the full detail. This closes the `appServer.R`/`appUI.R` sibling-bug pair
  from the issue #50 crash class; `BACKLOG.md`'s severity-graded inventory of 4
  further, lower-severity unguarded `getSiteInfo()` call sites remains open,
  deliberately out of this session's scope.

### 2026-07-14 · [ad hoc] Guard the unprotected `getSiteInfo()` call at the ORIP-tab gate, `appServer.R` half (Session 378)
- **Deliverable:** `R/appServer.R:347`'s `oripSiteInfo <- getSiteInfo(expectConfigFile
  = FALSE)` was not `tryCatch`-guarded: a present-but-malformed site-config file (e.g.
  missing the required `center` key) made `getParamDef()` `stop()`, propagating
  uncaught and crashing app boot -- the same issue #50 crash class `loadSiteConfig()`
  was built to prevent, recurring at this independent call site (found and filed as a
  `BACKLOG.md` item during issue #122 Phase 4, S376 / `PROJECT_LEARNINGS.md` Learning
  347(e)). Fixed by wrapping the call in `tryCatch` mirroring `loadSiteConfig()`'s
  pattern (log via `futile.logger::flog.warn`, fall back to `NULL`), guarding the
  downstream `shouldShowOripTab()` call with `!is.null(oripSiteInfo) &&` so the `NULL`
  fallback fails closed (ORIP tab hidden) instead of crashing `file.exists()` on a
  `NULL` argument, and reusing the single parsed value for the `siteConfig` reactive
  instead of re-calling `getSiteInfo()` a second time. Strict TDD RED->GREEN
  throughout (REFACTOR declared unneeded); 2 new tests in
  `tests/testthat/test_appServer_server.R` (section 6b).
- **Scope correction:** A live Phase 3E `shinytest2::AppDriver` boot check (required
  because this changes runtime boot behavior; `shiny::testServer()` alone cannot
  construct `appUI()`) found the fix incomplete -- `R/appUI.R:20` has an independent,
  identical unguarded `getSiteInfo(expectConfigFile = FALSE)` default-argument call
  that still crashes app boot on a malformed config. Owner chose (via
  `AskUserQuestion`) to file this separately rather than expand scope; see the new
  `BACKLOG.md` item (which also inventories 4 further unguarded `getSiteInfo()` call
  sites of lower severity, found by the same session's `grep` sweep). The
  `appServer.R` code comment was corrected to not overclaim "app boot" broadly.
- **Verification:** target test file 27/27 passed; full suite 3215 passed/169
  skipped/0 failed/0 error/0 warning; `devtools::check()` 0 errors/0 warnings/0 notes;
  lintr 0 lints on both changed files. Phase 3E: live `AppDriver` boot performed (not
  declared N/A) -- see `PROJECT_LEARNINGS.md` Learning 349 for the full detail
  including a second, inconclusive live check (unrelated pre-existing
  e2e-subprocess-staleness artifact).

### 2026-07-14 · [issue #122] Close the GitHub issue (Session 377)
- **Action:** Owner confirmed via `AskUserQuestion` (S377's close-out report flagged
  that the issue remained open even though all 5 plan phases were DONE and
  `BACKLOG.md`'s tracking was resolved). Closed with `gh issue close 122`, comment
  summarizing the 5-phase resolution (S373-S377) and pointing to `CHANGELOG.md` and
  `docs/architecture/module-contract.md`. Non-commit action; recorded here per FM #27.

### 2026-07-14 · [issue #122] Phase 5: write the contract down and make it enforceable (Session 377)
- **Deliverable:** Executed Phase 5 (the final phase) of
  `docs/planning/issue122-module-contract-plan.md` following
  `DEVELOPMENT_WORKSTREAM.md` under strict TDD, classified PRE-RED -> REFACTOR (not
  RED -> GREEN): firsthand verification found all 10 `mod*Server` functions already
  satisfied the "named list of reactives, all elements functions" shape before any
  edit, so there was no failing behavior for a RED test to drive -- a characterization
  guard, per the project's established precedent (`PROJECT_LEARNINGS.md` Learning
  277). Wrote `docs/architecture/module-contract.md` (the §4.4 contract as a living
  standards doc, house-styled on `docs/conventions/ROXYGEN_EXAMPLES_POLICY.md`, citing
  `modInput` as the reference implementation and documenting two deliberate contract
  exceptions: `modGvAndBgDescServer`'s bare `NULL` return, and `gestationTable`'s
  bare-`reactiveValues` read into `modPotentialParentsServer`, Dragon 4). Added
  `tests/testthat/test_moduleContract.R`, a cross-cutting guard test exercising all 10
  `mod*Server` functions via `shiny::testServer()` with args mirroring `appServer.R`'s
  real call sites, asserting an exhaustive named-list-of-functions shape for 9 modules
  plus the declared NULL exception for the 10th; proved the guard's non-vacuity with an
  explicit negative control (3 deliberately broken module stand-ins, each caught).
  Added a roxygen `@note` to `modInputServer` citing the contract doc and marking it
  the reference implementation; `devtools::document()` run standalone (regenerated only
  `man/modInputServer.Rd`, `NAMESPACE` unchanged). **Finding: `modInput` was already
  fully contract-compliant** -- S376's Phase 4 work (dead `config` param removal,
  completing its `@return` docs) had already, as a side effect, cleared Phase 5's
  stated "bring modInput up to the contract" prerequisite; the plan's own §4.4
  blockquote and S376's handoff gotcha both still described it as non-compliant,
  stale relative to S376's own commits. Also fixed a `.gitignore` gap discovered while
  committing: `docs/*` was blanket-ignored with a per-subdirectory allowlist that did
  not yet include `docs/architecture/`, which would have silently dropped the new
  contract doc from every commit. Verified: full suite 3870 passed/0 failed/0 error/0
  warning/167 skipped (3802 baseline + 68 new guard-test expectations);
  `devtools::check()` 0 errors/0 warnings/0 notes; lintr 0 lints on both changed files.
  Phase 3E: N/A, declared explicitly -- no runtime behavior changed (docs + a new test
  file only). **Issue #122 (XARCH-2) is now fully resolved** -- all 5 plan phases DONE
  across S373-S377; `BACKLOG.md`'s "Architecture (issue #122)" section pruned to a
  resolved pointer. See `PROJECT_LEARNINGS.md` Learning 348, `BACKLOG.md`.

### 2026-07-13 · [issue #122] Phase 4: prune the dead surface (Session 376)
- **Deliverable:** Executed Phase 4 of `docs/planning/issue122-module-contract-plan.md`
  following `DEVELOPMENT_WORKSTREAM.md` under strict TDD (RED -> GREEN -> REFACTOR, 2
  pre-RED `AskUserQuestion` scope decisions plus the 3 phase gates). Removed the dead
  `config` param from `modInputServer`/`modPedigreeServer` and its `appServer.R`
  call-site args -- neither module ever read it; `shared$config <- loadSiteConfig()`
  stays at boot (independent issue #50 regression coverage). Deleted the dead
  `shared$qcResults` write (never read anywhere). Replaced `appServer`'s blanket
  `tryCatch(..., error = function(e) NULL)` swallow with `req()` at the
  `cleanedStudbook`/`qcSummary` observers and a narrowed
  `tryCatch(shiny.silent.error = function(e) NULL)` for `changedCols` (preserving its
  independence from `errorLst`/`fileName` in the same observer). Documented
  `modInputServer`'s 4 previously-undocumented `@return` elements (source: 5
  concern-scoped commits -- `fb9e0b5c` source+docs, `ecdda66b` modInput test
  migration, `4b461527` modPedigree test migration, `03bfce99` contract-guard
  behavioral tests, `2df12dd0` `BACKLOG.md` update). **Two plan-premise corrections
  found by extending the plan's own §8 evidence-based-inventory discipline past its
  stated boundary:** (1) skipped item 3 entirely -- the plan's "`modSummaryStats`' 12
  unread reactives" claim was measured only against `appServer.R` consumption; ~53
  active `testServer()$getReturned()` assertion sites across 4 test files prove they
  are load-bearing test infrastructure, not dead code; (2) the site-config
  delete-vs-wire decision (the plan's own flagged "real design decision," §10 item 1)
  resolved to delete-threading-only after three converging checks (source inspection,
  independent call-graph tracing of the LabKey/column-validation paths, and an
  existing test proving arbitrary config content was already behaviorally inert).
  Also surfaced, out of scope and not fixed: `appServer.R:347`'s unprotected
  `getSiteInfo()` call at the ORIP-tab gate (new `BACKLOG.md` item). Verified: full
  suite 3802 passed/0 failed/0 error/0 warning/167 skipped (baseline unchanged);
  `devtools::check()` 0 errors/0 warnings/0 notes; lintr 0 lints across all 14 changed
  files; `devtools::document()` run standalone, touching only the 2 expected `.Rd`
  files (`NAMESPACE` unchanged); Phase 3E live smoke test via the repo's existing e2e
  suite -- `test-e2e-input-detailed.R` (6/6), `test-e2e-input-incomplete-final-line.R`
  (2/2), `test-e2e-input-module.R` (5/5), `test-e2e-input-tutorial.R` (8/8),
  `test-e2e-pedigree-detailed.R` (8/8), `test-e2e-pedigree-module.R` (6/6),
  `test-e2e-pedigree-tutorial.R` (13/13), all against the real modified app. See
  `PROJECT_LEARNINGS.md` Learning 347, `BACKLOG.md`.

### 2026-07-13 · [ad hoc] S375 close-out commits (learnings, backlog pointer, ledger, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap in the
  same session rather than leaving it for the next session's Phase 0 reconcile. Records
  the `BACKLOG.md` Phase-3-DONE/Phase-4-next update (`2d03c521`) and the close-out
  commit (`af539f70`: this ledger entry + `PROJECT_LEARNINGS.md` Learning 346 +
  `CLAUDE.md` pointer bump + `SESSION_NOTES.md`/`HANDOFFS.md` handoff, `status: pending`
  -> `complete`) that finalized the Session 375 handoff.

### 2026-07-13 · [issue #122] Phase 3: collapse to one canonical vocabulary (Session 375)
- **Deliverable:** Executed Phase 3 of `docs/planning/issue122-module-contract-plan.md`
  following `DEVELOPMENT_WORKSTREAM.md` under strict TDD (RED -> GREEN -> REFACTOR, 3
  `AskUserQuestion` phase gates, plus a 4th gate resolving a self-caught process
  deviation -- see below). Deleted `modGeneticValue`'s `geneticValues` reactive rename
  closure (`indivMeanKin`/`gu` -> `meanKinship`/`genomeUniqueness`) so it now returns
  `gvResults()` directly, and the now-redundant `mkCol`/`guCol` dual-vocabulary display
  probes in `gvSummary`/`gvScatterPlot` (commit `0a6e91c2`). Migrated
  `R/modSummaryStats.R`'s ~13 `gv$meanKinship`/`gv$genomeUniqueness` read sites
  (histograms, boxplot guards, quartile summaries, the `summaryStats` renderUI, the
  returned `summaryData` reactive) plus its `@param` doc, to canonical `indivMeanKin`/
  `gu` (commit `0acb29db`). Migrated `R/modORIPReporting.R`'s 4 read sites (commit
  `1f8436e8`). `rg 'meanKinship|genomeUniqueness' R/mod*.R` now returns zero hits
  outside two verified out-of-scope exclusions: the unrelated `genomeUniquenessSE`/
  `guSE` fallback in `gvSummary`, and the `meanKinshipBoxPlotGG`/`meanKinshipBoxPlot`
  reactive/list-key identifiers (not data columns; renaming the exported list key would
  be an exported-contract change, out of scope per the plan's Dragon 5).
  Five of the plan's originally-cited 12 test files (its own prose claimed "15") turned
  out to be false positives on firsthand verification -- `test_modBreedingGroups.R`,
  `test_modFounderStats.R`, `test_makeGeneticSummaryTable.R`,
  `test_modGeneticValue_coverage.R`, `test-e2e-genetic-value-tutorial.R` -- none
  actually exercise the migrated read sites (see `PROJECT_LEARNINGS.md` Learning 346).
  The other 7 test files' fixtures/assertions were flipped to canonical vocabulary as
  RED, confirmed failing for the predicted reason against unmigrated source, then
  GREEN. Full suite 0 failed/0 error/0 warning/167 skipped (baseline unchanged);
  `devtools::check()` 0 errors/0 warnings/0 notes (both before and after a standalone
  `devtools::document()` that regenerated only `man/modSummaryStatsServer.Rd`,
  `NAMESPACE` unchanged). End-to-end verification against the real 280-animal `qcPed`
  fixture: `geneticValues()` confirmed identical to `gvResults()`; `modSummaryStats`/
  `modORIPReporting` confirmed to render the exact same independently-computed mean
  values -- satisfying the plan's "byte-identical... must be re-proved, not assumed"
  DONE criterion by execution. Phase 3E (mandatory -- runtime read paths in three
  live-wired modules changed): the repo's existing `NPRC_RUN_E2E=true` browser e2e
  suite across all 5 relevant files -- `test-e2e-genetic-value-module.R` (7/7),
  `test-e2e-genetic-value-detailed.R` (7/7), `test-e2e-genetic-value-tutorial.R` (8/8),
  `test-e2e-summary-statistics-module.R` (8/8), `test-e2e-orip-module.R` (4/4), all
  34/34 passing against the real modified app. One self-caught and disclosed
  phase-gate violation (bundled a REFACTOR-phase roxygen doc edit into the GREEN commit
  without a separate gate) -- resolved via an explicit 4th `AskUserQuestion` before
  continuing; see `PROJECT_LEARNINGS.md` Learning 346(c). Split into three commits per
  `SAFEGUARDS.md`'s 5-file blast-radius cap: `modGeneticValue` + its test (2 files),
  `modSummaryStats` + its Rd + 3 test files (5 files), and the remaining 2 test files +
  `modORIPReporting` (4 files).

### 2026-07-12 · [ad hoc] S374 close-out commits (backlog pointer, learnings, ledger, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap in the
  same session rather than leaving it for the next session's Phase 0 reconcile. Records
  the `BACKLOG.md` Phase-2-DONE/Phase-3-next update (`654bbabf`) and the close-out
  commit (`e7cc7fff`: this ledger entry + `PROJECT_LEARNINGS.md` Learning 345 +
  `CLAUDE.md` pointer bump + `SESSION_NOTES.md`/`HANDOFFS.md` handoff, `status: pending`
  -> `complete`) that finalized the Session 374 handoff.

### 2026-07-12 · [issue #122] Phase 2: share one full-pedigree kinship reactive, kill the dead reuse branch (Session 374)
- **Deliverable:** Executed Phase 2 of `docs/planning/issue122-module-contract-plan.md`
  following `DEVELOPMENT_WORKSTREAM.md` under strict TDD (RED -> GREEN -> REFACTOR, 3
  `AskUserQuestion` phase gates). Deleted `modBreedingGroups`' unreachable
  `gvReactive`-based kinship-reuse branch (`shared$geneticValues` is a data frame,
  never has a `$kinship` element -- confirmed by inspection, not the plan's framing
  alone; commit `3009c83b`). Hoisted one shared, memoized, full-pedigree
  `sharedKinshipMatrix` reactive into `appServer` (commit `6351c180`), computed via the
  identical `kinship()`+`applyKinshipOverridesToMatrix()` formula each consumer already used, and
  threaded it to both `modSummaryStatsServer` (already accepted `kinshipMatrix`,
  previously always `NULL`) and `modBreedingGroupsServer` (new `kinshipMatrix` param).
  Recompute fallback retained in both consumers (Dragon 3 -- summary stats must render
  before GV is ever run). Dragon 1 sidestepped by construction, not avoidance: the
  shared reactive reads `shared$currentPedigree` directly, never `gvResults
  $kinshipMatrix` (GV's population-filtered matrix) -- proved via `setPopulation()`'s
  source (only flags a `population` column, never filters rows) and empirically via the
  plan's mandatory `identical()` regression gate against the real 280-animal `qcPed`
  fixture, with and without focal animals (all 4 checks `identical()` TRUE).
  RED: 6 test sites across 3 files (2 new tests in
  `tests/testthat/test_modBreedingGroups_sharedKinship.R`; 3 existing direct-helper-call
  sites renamed in `test_modBreedingGroups_kinshipOverrides.R`; 1 new appServer wiring
  test in `test_appServer_server.R` asserting `identical()` object identity between what
  both consumers receive), each confirmed failing for the predicted reason before any
  implementation. GREEN: full suite 0 failed/0 error/0 warning (167 skipped);
  `devtools::check()` 0 errors/0 notes/1 expected codoc WARNING (the new
  `kinshipMatrix` param undocumented). REFACTOR: added `@param kinshipMatrix`, corrected
  the now-stale `@param geneticValues`/`@param kinshipOverrides` prose describing the
  deleted branch; `devtools::document()` standalone regenerated only
  `man/modBreedingGroupsServer.Rd`, `NAMESPACE` unchanged. Re-ran `devtools::check()`:
  0 errors/0 warnings/0 notes. Phase 3E (mandatory -- this phase changes runtime
  wiring): the repo's existing browser e2e suite, gated behind `NPRC_RUN_E2E=true` (a
  second opt-in beyond `NOT_CRAN`/`skip_on_cran()` this session discovered rather than
  writing a bespoke `callr::r_bg()` script), `test-e2e-breeding-groups-module.R` (7/7)
  and `test-e2e-summary-statistics-module.R` (8/8) both pass against the real modified
  `appServer`. Two self-caught test-authoring bugs fixed during GREEN verification (a
  mocked-module stub returning bare `NULL` crashed an unrelated `appServer` observer
  reading its return value; a captured reactive was evaluated outside its live
  `testServer()` session) -- see `PROJECT_LEARNINGS.md` Learning 345. Split into two
  commits per `SAFEGUARDS.md`'s 5-file blast-radius cap: `modBreedingGroups`-scoped
  RED+GREEN+REFACTOR (4 files) and `appServer`-scoped hoist (2 files).

### 2026-07-12 · [ad hoc] S373 close-out commits (learnings, backlog pointer, ledger, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap in the
  same session rather than leaving it for the next session's Phase 0 reconcile. Records
  the close-out commit (`42035bdd`: this ledger entry + `PROJECT_LEARNINGS.md` Learning
  344 + `CLAUDE.md` pointer bump + `SESSION_NOTES.md`/`HANDOFFS.md` handoff,
  `status: pending` -> `complete`) that finalized the Session 373 handoff. Also covers
  the `BACKLOG.md` Phase-1-DONE/Phase-2-next update (`cc6f6e8a`), already committed
  ahead of close-out.

### 2026-07-12 · [issue #122] Phase 1: normalize GV report vocabulary at the seam (Session 373)
- **Deliverable:** Executed Phase 1 of `docs/planning/issue122-module-contract-plan.md`
  (commit `e51ee11b`), following `DEVELOPMENT_WORKSTREAM.md` under strict TDD
  (RED -> GREEN -> REFACTOR, 3 `AskUserQuestion` phase gates). `reportGV()` (exported)
  emits `indivMeanKin`/`gu`; `makeGeneticSummaryTable()` (exported) consumed only the
  renamed `meanKinship`/`genomeUniqueness`, so `makeGeneticSummaryTable(reportGV(ped)
  $report)` silently returned an all-`NA` table with no error or warning. New internal
  (`@noRd`) `R/normalizeGvReport.R` maps either vocabulary onto `reportGV()`'s own
  canonical column names; `makeGeneticSummaryTable()` now calls it internally. Additive:
  `NAMESPACE` unchanged, legacy `meanKinship`/`genomeUniqueness` input still works
  byte-for-byte (pinned by a new `identical()` regression test). Verified: RED tests
  failed for the predicted reason before the fix; full suite 0 failed/0 error/0 warning
  (169 skip, baseline unchanged) after; `lintr::lint_package()` 0 lints; `devtools::check()`
  0 errors/0 warnings/0 notes; end-to-end against `qcPed` confirms
  `makeGeneticSummaryTable(reportGV(qcPed)$report)` now populates correctly (was all-`NA`).
  `BACKLOG.md` updated (commit `cc6f6e8a`): Phase 1 DONE, Phase 2 (dead kinship-reuse
  branch + shared full-pedigree kinship reactive) now the READY item. Phases 2-5 remain
  separate future sessions per the plan's session-boundary gates.

### 2026-07-12 · [ad hoc] S372 close-out commits (ledger, learnings, backlog, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap in
  the same session rather than leaving it for the next session's Phase 0 reconcile.
  Records the close-out commit (`919e2d37`: this ledger entry + `PROJECT_LEARNINGS.md`
  Learning 343 + `CLAUDE.md` pointer bump + `BACKLOG.md` Architecture section +
  `SESSION_NOTES.md`/`HANDOFFS.md` handoff, `status: pending` -> `complete`) that
  finalized the Session 372 handoff.

### 2026-07-12 · [issue #122] Architecture plan for XARCH-2 (implicit/inconsistent module contract) (Session 372)
- **Deliverable:** `docs/planning/issue122-module-contract-plan.md` (676 lines,
  commit `12e30f80`) -- an `ARCHITECTURE_WORKSTREAM.md` plan for GitHub issue
  #122, the typed-module-contract work `docs/planning/shiny-module-conversion-plan.md`
  §5 deferred ("deferred to a separate issue after the monolith is gone").
  **Planning only** -- no `R/` or `tests/` code touched (FM #18; SAFEGUARDS
  gates cross-module refactoring behind plan mode). TDD N/A.
- **Research:** 10 module readers + 6 adversarial claim-verifiers + 8 symbol-level
  grep inventories + 1 completeness critic, every citation re-derived from current
  source (the issue's line refs predate S367-S370).
- **All 4 issue claims re-verified CONFIRMED -- but the issue understates the
  problem and overstates the fix:**
  - **The disease is a public-API defect, not a style issue.** `reportGV()`
    (exported) emits `indivMeanKin`/`gu`; `makeGeneticSummaryTable()` (exported)
    consumes `meanKinship`/`genomeUniqueness`. Composing them -- the natural
    `makeGeneticSummaryTable(reportGV(ped)$report)` -- returns an **all-`NA` table
    with no error and no warning.** Reproduced by execution.
  - **`modBreedingGroups`' kinship-reuse branch is unreachable dead code**, not
    merely "redundant": `R/modBreedingGroups.R:193` column-name-tests a data frame
    for `"kinship"`, which can never be TRUE.
  - **The issue's own fix is a trap.** Threading GV's kinship matrix into the
    consumers would silently rescope Summary Stats to the focal subset. Measured
    against `qcPed`: the matrices are **bit-identical on the default path**,
    divergent only when focal animals are entered.
  - **~40 `deparse()` source-grep tests structurally pin the very `tryCatch`
    error-swallowing the issue asks us to remove** (`test_modErrorHandling.R:186-192`
    et al.) -- they turn red by design, and were invisible to any behavioral
    test search.
  - **`loadSiteConfig()` -> `shared$config` -> `{modInput, modPedigree}` is dead
    end to end** -- both modules declare a `config` param and never read it. Not in
    the issue; it sat in the gap between two of its findings.
- **Proposes** a backward-compatible alternative (canonical = `reportGV`'s
  vocabulary + a tolerant internal normalizer) that fixes strictly more and breaks
  **no exported contract** -- a deliberate constraint, given v2.0.0 is mid-CRAN
  resubmission. 5 phases, one session each, with per-phase completion criteria,
  verification commands, and 6 dragons.

### 2026-07-12 · [ad hoc] S371 close-out commits (ledger/learnings/pointer, session notes, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier
  gap in the same session rather than leaving it for the next session's
  Phase 0 reconcile. Records the close-out commits (`9183aeb9`: ledger
  entry + `PROJECT_LEARNINGS.md` Learning 342 + `CLAUDE.md` pointer bump;
  `1a6a2c0f`: session notes handoff write-up + `HANDOFFS.md` receipt,
  `status: pending` -> `complete`) that finalized this session's handoff.
  Also pushed 5 unpushed S370 close-out commits to `origin/master`
  (`88736aa1..ebe7ceb3`, fast-forward) at the user's explicit request
  during Phase 0, before this deliverable was picked up.

### 2026-07-12 · [ad hoc] Resolved the S358-flagged vignette-files/PED_GV_AUDIT.html policy question (Session 371)
- **Deliverable:** Deleted `PED_GV_AUDIT_2026-05-30.html` (repo root) -- a stale
  `pandoc`-rendered copy of the already-tracked `PED_GV_AUDIT_2026-05-30.md`,
  generated by no repo script and referenced nowhere. Deleted
  `vignettes/articles/engineering-the-2.0.0-release.html` +
  `_files/` -- stale `quarto render` output from S332 (`PROJECT_LEARNINGS.md`
  Learning 308), matching the precedent every other one of the 7 sibling
  `.qmd` articles already follows (zero rendered output retained in the
  working tree). Extended `vignettes/articles/.gitignore` with `*.html`/
  `*_files/` patterns (previously only `/.quarto/`) so future `quarto render`
  verification runs in this directory no longer leave stray untracked
  output requiring manual cleanup -- closes Learning 308(b)'s diagnosed root
  cause (the top-level `.gitignore`'s single-level `vignettes/*.html` glob
  does not reach `vignettes/articles/`) at the source.
- **Verification:** `git check-ignore -v` confirmed the new patterns match
  both render-output paths and correctly do NOT match the three tracked
  source types in the directory (`.qmd`, `_quarto.yml`, `.R`). Confirmed
  `PED_GV_AUDIT_2026-05-30.md` and `vignettes/articles/engineering-the-2.0.0-
  release.qmd` (the tracked sources) are unmodified. TDD N/A (pure
  repo-hygiene, no `R/`/`tests/` source touched). Phase 3E runtime smoke:
  n/a -- docs-only, no runtime path touched. See `PROJECT_LEARNINGS.md`
  Learning 342.
- Owner decision made via 2 `AskUserQuestion` scope-decision gates (both
  resolved to the recommended, evidence-backed option) after Phase 0's
  priorities picker returned "Something else" -> the standing S358 flag.

### 2026-07-12 · [ad hoc] S370 close-out commits (learning 341, backlog, session notes, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier
  gap in the same session rather than leaving it for the next session's
  Phase 0 reconcile. Records the two close-out commits (`7064f834`:
  ledger/learnings/backlog; `c4091be3`: session notes + handoff receipt)
  that finalized this session's `HANDOFFS.md` receipt (`status: pending`
  -> `complete`) and `SESSION_NOTES.md` handoff.

### 2026-07-12 · [ad hoc] Regenerated stale man/filterPairs.Rd via standalone devtools::document() (Session 370)
- **Deliverable:** `man/filterPairs.Rd`'s `\usage{}` line now matches the live
  `filterPairs()` signature (`ignore = list(c(sexCodes[["female"]],
  sexCodes[["female"]])))`) instead of the stale literal
  `list(c("F", "F"))` left over from S367's default-arg change. Pure
  generated-doc regen -- `R/filterPairs.R` untouched, no behavior change
  (`sexCodes[["female"]]` resolves to `"F"`, identical to before).
- **Verification:** `devtools::document()` run standalone (no other pending
  roxygen edit) touched only `man/filterPairs.Rd`; confirmed via
  `git status`/`git diff`. `identical(formals(filterPairs)$ignore,
  quote(list(c(sexCodes[["female"]], sexCodes[["female"]]))))` == `TRUE`.
  Full regression: 0 failed/0 error/0 warning (169 skipped, baseline
  unchanged). TDD N/A (docs-only, no `R/`/`tests/` source touched). Phase 3E
  runtime smoke: n/a -- docs-only, no runtime path touched.
- Removed the now-resolved item from `BACKLOG.md`'s Architecture
  follow-ups section (now fully empty). See `PROJECT_LEARNINGS.md`
  Learning 341.

### 2026-07-12 · [ad hoc] S370 claimed session for man/filterPairs.Rd regen
- **Deliverable:** Phase 1B claim stub (`SESSION_NOTES.md`) + `HANDOFFS.md`
  `status: pending` receipt committed (`2ebe2161`) before any doc-regen work,
  per `BACKLOG.md`'s tiny XS item.

### 2026-07-12 · [ad hoc] S369 close-out commits (backlog, learning 340, session notes, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap
  in the same session rather than leaving it for the next session's Phase 0
  reconcile. Records the two close-out commits (`70466d76`: ledger/learnings/
  backlog; `105b6196`: session notes + handoff receipt) that finalized this
  session's `HANDOFFS.md` receipt (`status: pending` → `complete`) and
  `SESSION_NOTES.md` handoff.

### 2026-07-12 · [ad hoc] Implemented BACKLOG.md's XARCH-8 remainder: folded column-list functions into getSiteInfo() (Session 369)
- **Deliverable:** `getSiteInfo()` now returns 3 new fields --
  `requiredCols`, `possibleCols`, `includeColumns` -- sourced from
  `getRequiredCols()`/`getPossibleCols()`/`getIncludeColumns()`, added to
  BOTH return branches (config-file-present and no-config defaults).
  Additive only: no existing field changed, no signature change. This is
  the narrower remainder the 2026-07-11 reconciliation audit scoped out
  of the original XARCH-8 finding's full "merged-profile precedence"
  redesign (already excluded from tracking). Strict TDD RED
  (`tests/testthat/test_getSiteInfo.R`: updated the exact-name-enumeration
  test to include the 3 new fields, plus 2 new tests asserting
  `identical()` to the 3 source functions on both the no-config branch
  and a real-config-file branch manufactured via the same
  `withr::local_tempdir()`/`file.copy(example_nprcgenekeepr_config, ...)`
  pattern `test_loadSiteConfig.R` established for issue #50; commit
  `8243b7d3`, all 7 assertions confirmed failing for the predicted reason
  before implementation) → GREEN (`R/getSiteInfo.R` + regenerated
  `man/getSiteInfo.Rd`; commit `bd6ca077`) → REFACTOR (reviewed: the
  3-line addition duplicated identically in both branches matches every
  other field in `getSiteInfo()`, already duplicated verbatim between
  branches -- nothing to restructure). Full regression: 0 failed/0
  error/0 warning (169 skipped, baseline). `lintr::lint()` clean on both
  changed files. Phase 3E: live-launched the modular app via
  `callr::r_bg()` + `shiny::runApp()` on a scratch port (HTTP 200, zero
  error-like server-log lines, Input tab rendered), plus a direct
  `load_all()` call confirming `getSiteInfo()$requiredCols`/
  `possibleCols`/`includeColumns` are `identical()` to their source
  functions' live output. Excluded an unrelated stale-doc regeneration
  (`man/filterPairs.Rd`, recurring a third session running from S367's
  un-regenerated default-arg change) from this commit -- reverted via
  `git checkout -- man/filterPairs.Rd`; filed as its own tiny
  `BACKLOG.md` item this time (Effort XS) rather than only a handoff
  note. Removed the XARCH-8 bullet from `BACKLOG.md`'s Architecture
  follow-ups section (now empty) and updated its intro paragraph. Added
  `PROJECT_LEARNINGS.md` Learning 340, bumped `CLAUDE.md`'s pointer
  (339→340, 368→369).

### 2026-07-12 · [ad hoc] Session 369 claim (XARCH-8 getSiteInfo column-fold remainder)
- **Deliverable:** Claimed the session per Phase 1B -- `SESSION_NOTES.md`
  stub + `HANDOFFS.md` `status: pending` receipt, committed before any
  RED-test authoring (commit `04198b41`).

### 2026-07-12 · [ad hoc] S368 close-out commits (backlog, learning 339, session notes, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap
  in the same session rather than leaving it for the next session's Phase 0
  reconcile. Records the two close-out commits (`0f64fa09`: ledger/learnings/
  backlog; `48597192`: session notes + handoff receipt) that finalized this
  session's `HANDOFFS.md` receipt (`status: pending` → `complete`) and
  `SESSION_NOTES.md` handoff.

### 2026-07-12 · [ad hoc] Implemented BACKLOG.md's XARCH-6 remainder: de-duplicated qcStudbook() calls (Session 368)
- **Deliverable:** `runQcStudbook()` now returns the raw first-pass `errorLst`
  alongside its existing `cleaned`/`qcResult` fields (all 3 return paths), so
  `modInput.R` no longer needs its own separate `qcStudbook()` call to get the
  raw `errorLst` for dynamic tab display — it reuses `runQcStudbook()`'s own
  already-computed `errorLst` instead. Removes 1 of 3 `qcStudbook()`
  invocations per clean-pedigree QC run (2 of 2 on an errored one). Strict TDD
  RED (`tests/testthat/test_modInput_qcStudbook.R`: 2 call-count assertions
  via a delegating `local_mocked_bindings` mock — capture-then-call-through,
  not a stub, so real QC output stays intact for downstream assertions — plus
  1 `errorLst`-content regression guard that already passed at RED, locking in
  behavior GREEN must not break; commit `c07ea356`) → GREEN (`R/runQcStudbook.R`,
  `R/modInput.R`, `man/runQcStudbook.Rd`, and an update to
  `tests/testthat/test_modInput_sexSpecificAge.R`'s call-threading test, which
  had asserted directly on the now-removed call site; commit `a78c81b9`) →
  REFACTOR (reviewed: diff already minimal and single-purpose, nothing to
  change — matches the S367 XARCH-4 precedent). Full regression: 0 failed/0
  error/0 warning (169 skipped, baseline). `lintr::lint()` clean on all 4
  changed source/test files after fixing one new line-length violation
  introduced by the edit itself. Phase 3E: live-launched the app (HTTP 200,
  zero server-log errors, Input module rendered) combined with the
  `shiny::testServer`-based tests that exercise the exact changed reactive
  code through real CSV uploads. Excluded an unrelated stale-doc regeneration
  (`man/filterPairs.Rd`, a leftover from S367's XARCH-4 GREEN phase never
  running `devtools::document()`) from this commit — reverted via
  `git checkout -- man/filterPairs.Rd`, flagged in `SESSION_NOTES.md` gotchas
  rather than silently absorbed. Removed the XARCH-6 bullet from `BACKLOG.md`'s
  Architecture follow-ups section and updated its intro paragraph. Added
  `PROJECT_LEARNINGS.md` Learning 339, bumped `CLAUDE.md`'s pointer
  (338→339, 367→368).

### 2026-07-12 · [ad hoc] Session 368 claim (XARCH-6 qcStudbook call-count redundancy)
- **Deliverable:** Claimed the session per Phase 1B — `SESSION_NOTES.md` stub
  + `HANDOFFS.md` `status: pending` receipt. Written retroactively after
  PRE-RED research and RED-test authoring had already begun (a self-caught
  ordering miss, corrected before the RED commit landed — see
  `PROJECT_LEARNINGS.md` Learning 339(d)). Commit `e4652a4b`.

### 2026-07-12 · [ad hoc] S367 close-out commits (session notes, handoff receipt, learning 338)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap
  in the same session rather than leaving it for the next session's Phase 0
  reconcile. Records the two close-out commits (`cc2fbf83`: ledger/learnings/
  backlog; `0679bfe6`: session notes + handoff receipt) that finalized this
  session's `HANDOFFS.md` receipt (`status: pending` → `complete`) and
  `SESSION_NOTES.md` handoff.

### 2026-07-12 · [ad hoc] Implemented BACKLOG.md's XARCH-4 remainder: centralized sex-code literals (Session 367)
- **Deliverable:** Added `R/sexCodes.R` (internal, `@noRd` constant:
  `male`/`female`/`hermaphrodite`/`unknown` → `M`/`F`/`H`/`U`) and routed the
  6 files named in the BACKLOG item's remainder through it instead of bare
  string-literal comparisons: `getPotentialSires.R`, `calculateSexRatio.R`,
  `fillBins.R`, `filterPairs.R`, `modBreedingGroups.R`, `modSummaryStats.R`.
  Strict TDD RED (`tests/testthat/test_sexCodes.R`: a constant-value test plus
  a structural `findBareSexCodeLiterals()` scan test that skips roxygen `#'`
  lines, so legitimate doc-example literals never block GREEN — commit
  `13ce0186`) → GREEN (2 commits under the 5-file cap: `3a02990a` constant +
  3 sites, `b64c4481` remaining 3 sites) → REFACTOR (reviewed: nothing to
  change, diff already minimal). A dedicated pre-RED `AskUserQuestion` scope
  gate confirmed staying within the ticket's original 6 files rather than
  expanding to ~11 more files a fresh whole-repo grep found with the same
  bare-literal pattern (owner-directed; those files are left for a future
  item, not silently fixed or silently dropped — see `PROJECT_LEARNINGS.md`
  Learning 338). Full regression suite: 0 failed/0 error/0 warning. Runtime
  smoke test: live-launched `runGeneKeepR()` (HTTP 200, Breeding
  Groups/Summary Statistics modules render, no server-log errors); the exact
  changed reactive paths (founders-download CSV content, `groupStats`) are
  additionally covered by existing `shiny::testServer`-based tests with real
  value assertions. Removed the XARCH-4 bullet from `BACKLOG.md`'s
  Architecture follow-ups section.

### 2026-07-12 · [ad hoc] Session 367 claim (XARCH-4 sex-code centralization)
- **Deliverable:** Claimed the session per Phase 1B — `SESSION_NOTES.md` stub
  + `HANDOFFS.md` `status: pending` receipt. Commit `9c6749c5`.

### 2026-07-12 · [ad hoc] S366 close-out commit (session notes, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap
  in the same session rather than leaving it for S367's Phase 0 reconcile.
  Records the close-out commit (`67f67f5e`) that finalized this session's
  `HANDOFFS.md` receipt (`status: pending` → `complete`) and appended this
  session's full handoff to `SESSION_NOTES.md`.

### 2026-07-12 · [ad hoc] Moved BACKLOG.md's Architecture follow-ups section to the top (Session 366)
- **Deliverable:** Relocated the XARCH-4/6/8 remainder items ("Architecture
  follow-ups") from the bottom of `BACKLOG.md` to directly after `## Active`,
  ahead of `## Up Next`/`## Documents`/`## Audit follow-ups`, per owner direction
  given mid-Phase-0-priorities-picker. Pure reorder — diff confirmed 34
  insertions/34 deletions with identical content, no text changed. Commit
  `ba9d7801`.

### 2026-07-12 · [ad hoc] Session 366 claim (BACKLOG.md reorder)
- **Deliverable:** Claimed the session to move `BACKLOG.md`'s Architecture
  follow-ups section to the top. Commit `763af19a`.

### 2026-07-11 · [ad hoc] S365 close-out commit (session notes, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap
  in the same session rather than leaving it for S366's Phase 0 reconcile.
  Records the close-out commit (`c71a9f5a`) that finalized this session's
  `HANDOFFS.md` receipt (`status: pending` → `complete`) and appended this
  session's full handoff to `SESSION_NOTES.md`.

### 2026-07-11 · [ad hoc] Resolved BACKLOG.md's XARCH tracker-reconciliation decision (Session 365)
- **Deliverable:** Re-verified all 8 XARCH-1..8 architecture findings
  (`TECH_DEBT_AUDIT_2026-05-30.md`) against current source rather than trusting
  the six-week-old audit text, since `BACKLOG.md`'s "Tracker reconciliation" item
  had gone stale (its own "#1–#39" issue range and "XARCH-2..8 remaining" framing
  no longer matched reality — see `PROJECT_LEARNINGS.md` Learning 336). Used a
  background `Workflow` (7 read-only agents, one per remaining finding, 98 tool
  calls, 0 errors) to grep/read current `R/*.R` source directly. Result:
  XARCH-1/3/7 fully RESOLVED (1 and 7 as side effects of the monolith-deletion
  migration, issue #27; 3 independently closed in S358); XARCH-2 and XARCH-5
  STILL fully OPEN, unchanged from the original audit; XARCH-4/6/8 PARTIALLY
  resolved with materially narrower remaining gaps than originally described.
  Presented the accurate 8-item status table to the owner via `AskUserQuestion`
  (three options: issues for the 2 fully-open items only / issues for all 5
  unresolved / BACKLOG-only). **Owner chose issues for the 2 fully-open items.**
  Filed GitHub issue #122 (XARCH-2, module contract implicit/inconsistent) and
  #123 (XARCH-5, string-column-keyed pipeline with no validated seam), each with
  current-state evidence, not the stale original audit prose. Wrote
  `docs/audits/XARCH_TRACKER_RECONCILIATION_AUDIT_2026-07-11.md` documenting the
  full re-verification and decision. Removed `BACKLOG.md`'s resolved "Tracker
  reconciliation" section; replaced with three narrow-scope follow-up items for
  XARCH-4/6/8's actual remaining gaps (sex-code literal centralization;
  `qcStudbook()`/`modInput.R` multi-call redundancy; column-list-function
  unification into `getSiteInfo()`). Added `PROJECT_LEARNINGS.md` Learning 336.
  Bumped `CLAUDE.md`'s pointer (335→336, 364→365). No `R/`/`tests/` files
  changed — a decision-and-documentation session, TDD phase gates not applicable
  (no new observable code unit). Phase 3E: n/a, no runtime behavior changed.
  Commit `e87038bc`.

### 2026-07-11 · [ad hoc] Claimed session to resolve XARCH tracker-reconciliation decision (Session 365)
- **Deliverable:** Phase 1B claim stub in `SESSION_NOTES.md` and a
  `status: pending` receipt in `HANDOFFS.md` for resolving `BACKLOG.md`'s
  "Tracker reconciliation" (DECISION NEEDED) item. Commit `3b91a624`.

### 2026-07-11 · [ad hoc] Backfilled (reconcile-on-read): S364's own close-out commit (Session 365)
- **Deliverable:** Phase 0 ledger reconcile found `9eb07f0e` (S364's final
  "close-out (session notes, handoff receipt)" commit) undocumented in
  `CHANGELOG.md` — the same self-referencing gap S364 itself backfilled for
  S363's `002eb191` at the start of this session's predecessor. The commit
  finalized S364's `HANDOFFS.md` receipt (`status: pending` -> `complete`,
  all six fields filled) and appended S364's full handoff to
  `SESSION_NOTES.md`; no new deliverable, no code change. Backfilled per
  `SESSION_RUNNER.md` Phase 0 step 6, before the orientation report.

### 2026-07-11 · [ad hoc] Fixed `test_vignettes_no_deprecated_minParentAge.R`'s chunk-blind false positive (Session 364)
- **Deliverable:** Made the vignette checker chunk-aware so it stops flagging
  historical narrative prose as a live deprecated call. Owner-directed via the
  Phase 0 priorities picker, then an `AskUserQuestion` choosing to narrow the
  checker's scan over rewording the flagged prose. Extracted the scan into a
  new `findDeprecatedMinParentAgeOffenders()` helper
  (`tests/testthat/helper-vignette-minParentAge-scan.R`) that only applies the
  `minParentAge[[:space:]]*=[^=]` regex to lines strictly inside a
  ```` ```{r}/```{R} ```` ... ```` ``` ```` fence, not the whole file. Standard
  TDD: RED (3 synthetic `withr::local_tempfile()` fixtures — an in-chunk call
  must flag, out-of-chunk prose with `=` must not, an inline backtick span
  must not — all failing against the not-yet-existing helper) → GREEN (the
  fence-tracking implementation) → REFACTOR (reviewed via `lintr::lint()`:
  already clean, no duplicated regex logic, no changes needed). Updated the
  original test's inline scan loop to call the new helper and corrected its
  header comment to describe the actual (now chunk-scoped) behavior. Added
  `PROJECT_LEARNINGS.md` Learning 335 + a new `[chunk-scoped-checker]`
  glossary entry generalizing the gotcha for any future vignette-source
  content guard of this shape. Bumped `CLAUDE.md`'s learnings/session-count
  pointer (334→335, 363→364). Removed the resolved `BACKLOG.md` item.
  **Verification:** `devtools::check(args = "--as-cran")` — 0 errors | 0
  warnings | 0 notes. Full clean regression read (`NOT_CRAN=true`,
  `pkgload::load_all` + `test_dir(reporter="silent")`): 0 failed | 0 error |
  0 warning | 3775 passed (up from S363's 3771 — the 3 new fixtures plus the
  now-passing original assertion) | 167 skipped. Phase 3E: this is a
  test-infrastructure-only change (no `R/`/app runtime code touched); no
  separate `runGeneKeepR()` smoke test applicable — `devtools::check()`'s own
  `testthat.R` run is the change's actual runtime surface. No NEWS entry (no
  user-facing package behavior changed). Commit `87c521d8`.

### 2026-07-11 · [ad hoc] Claimed session to fix `minParentAge` vignette-checker false positive (Session 364)
- **Deliverable:** Phase 1B claim stub in `SESSION_NOTES.md` and a
  `status: pending` receipt in `HANDOFFS.md` for fixing
  `test_vignettes_no_deprecated_minParentAge.R`'s false-positive match
  (`BACKLOG.md` item, fix option (a): narrow the checker). Commit `c122fae2`.

### 2026-07-11 · [ad hoc] Confirmed the WriteXLS→openxlsx fix on live GitHub Actions `windows-latest` CI (Session 363)
- **Deliverable:** Pushed this session's commits to `origin/master` and watched
  (not just triggered) the `R-CMD-check.yaml` run it caused
  (run `29174654150`) rather than treating the local `--as-cran` pass as
  sufficient — this is the actual runner that had been red for 7 consecutive
  sessions (S351-S360). **Confirmed `windows-latest (release)` passed in
  11m48s**, along with all three Linux jobs and macOS; zero failures across the
  full matrix. Updated `SESSION_NOTES.md` and the `HANDOFFS.md` receipt with
  the live confirmation.

### 2026-07-11 · [ad hoc] S363 close-out commit (session notes, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap in
  the same session rather than leaving it for the next session's Phase 0 reconcile
  (mirroring the S349-S362 precedent for self-closing gaps). Records the fix work
  logged below. Commit `a425a637`.

### 2026-07-11 · [ad hoc] Fixed Windows-only `WriteXLS`/`create_wkbk()` CI flakiness via `openxlsx` (Session 363)
- **Deliverable:** Root-caused and fixed the `R-CMD-check.yaml` `windows-latest`
  regression S361/S362 diagnosed but did not fix. Owner-directed via the Phase 0
  priorities picker, then an `AskUserQuestion` choosing the root-cause fix
  (`WriteXLS`→`openxlsx`) over the narrower test-guard option, then a TDD gate
  `AskUserQuestion` approving REFACTOR-only (no new observable behavior). Captured
  a pre-change reference from the current `WriteXLS`-based implementation, then
  swapped `R/create_wkbk.R`'s `WriteXLS()` call for `openxlsx::write.xlsx(...,
  colWidths = "auto")`; explicitly returns `TRUE` on success (openxlsx's own
  return value is a workbook object, not `TRUE`, which would have silently broken
  the function's documented `@return` contract). Updated `DESCRIPTION` Imports
  (dropped `WriteXLS`, added `openxlsx`), the roxygen `@importFrom`, regenerated
  `NAMESPACE`, and `renv::snapshot()`'d the dependency change. Updated
  `test_readKinshipOverrides.R`'s `skip_if_not_installed("WriteXLS")` to
  `"openxlsx"` (its real dependency now). A first-pass synthetic identical-proof
  (character/numeric columns only) passed cleanly, but the full `devtools::check()`
  surfaced 2 real failures in `test_modInput_excelSireDam.R` (untouched by this
  session): `openxlsx` writes `Date` columns as native date-formatted numeric
  cells, but this package's own `readxl::read_excel(col_types = "text")` read
  path returns such a cell's raw serial number as text, not its rendered date
  string — silently corrupting `birth`/`exit` on read and collapsing
  `qcStudbook()`'s output to `NULL`. Fixed by explicitly coercing `Date`/`POSIXct`
  columns to `character` before writing, matching `WriteXLS`'s apparent original
  behavior; re-verified with a strengthened synthetic proof (incl. a `Date`
  column and an `NA`) plus the full suite. Added a `NEWS.Rmd` "Minor changes"
  bullet (new dependency, Perl requirement removed) and re-rendered `NEWS.md`.
  Added `PROJECT_LEARNINGS.md` Learning 334 + a new `[cross-library-file-format-
  proof]` glossary entry generalizing the gotcha (a synthetic identical-proof for
  a cross-library file-format swap must cover every real column type class, not
  just a hand-picked sample). Bumped `CLAUDE.md`'s learnings/session-count
  pointer (333→334, 362→363). **Verification:** `devtools::check(args =
  "--as-cran")` — 0 errors | 0 warnings | 0 notes. Full clean regression read
  (`NOT_CRAN=true`, `pkgload::load_all` + `test_dir(reporter="silent")`): 1
  failed | 0 error | 0 warning | 3771 passed | 167 skipped — the 1 failure
  (`test_vignettes_no_deprecated_minParentAge.R`) is pre-existing and unrelated
  (confirmed via `git log`/`git blame` unchanged since S357, `e624fc07`),
  documented as a new `BACKLOG.md` item per the mode-switch rule, not fixed.
  Removed the resolved `BACKLOG.md` item; updated the CRAN-resubmission item's
  stale cross-reference to point at this fix. Phase 3E: the full `testthat.R`
  run inside `devtools::check()` includes live `shiny::testServer()` exercises
  of the affected Excel-upload path (`test_modInput_excelSireDam.R`,
  `test_readKinshipOverrides.R`), which is this change's runtime surface —
  treated as the runtime smoke test; no separate `runGeneKeepR()` launch needed
  since no app-startup/wiring code changed.

### 2026-07-11 · [ad hoc] Claimed session to fix Windows WriteXLS CI flakiness (Session 363)
- **Deliverable:** Phase 1B claim stub in `SESSION_NOTES.md` and a `status: pending`
  receipt in `HANDOFFS.md` for fixing the Windows-only `WriteXLS`/`create_wkbk()`
  CI flakiness (BACKLOG.md item, fix option (b): replace `WriteXLS` with
  `openxlsx`). Commit `8ac1c5c8`.

### 2026-07-11 · [ad hoc] S362 close-out commit (session notes, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap in
  the same session rather than leaving it for the next session's Phase 0 reconcile
  (mirroring the S349-S361 precedent for self-closing gaps). Records the results-
  processing/correction work logged below. Commit `27a2ab31`.

### 2026-07-11 · [ad hoc] Processed CRAN 2.0.0 win-builder/R-hub results; corrected S361's Windows-blocker prediction (Session 362)
- **Deliverable:** User pasted the three win-builder completion emails
  (Status: 1/2/1 NOTE, no ERROR/WARNING) — directly contradicting S361's "very
  likely to reproduce" prediction about the Windows `WriteXLS` CI failure.
  Fetched the raw `00check.log` for each (via `curl`, not an AI-paraphrased
  `WebFetch` summary, given the stakes): all three confirm `checking tests ...
  OK` with zero failure output. Checked the R-hub run S361 dispatched
  (`occupational-burro`, run 29171440079) — all 3 jobs (linux/windows/macos,
  R-devel) green; pulled the windows job's actual log rather than trusting the
  checkmark, found `Status: OK, [ FAIL 0 | WARN 1 | SKIP 220 | PASS 3013 ]` —
  though the same `WriteXLS` "cannot open ... csv" diagnostic text does appear
  non-fatally. **Conclusion: the pre-submission gate is clean across every
  environment actually run this cycle (local macOS, win-builder x3, R-hub x3);
  the Windows `WriteXLS` CI flakiness is real and reproducible on GitHub-hosted
  Windows runners specifically, but is not present on CRAN's own win-builder
  infrastructure and is not currently blocking submission.** Updated
  `cran-comments.md`'s "Test environments" section with the real per-platform
  results (CRAN-facing-only, no internal narrative). Put the full investigation
  in `docs/planning/cran-2.0.0-phase5-runbook.md` (owner-facing). Corrected
  both of S361's `BACKLOG.md` entries: the WriteXLS item downgraded from
  "blocks CRAN resubmission" to a CI-hygiene item (still open, still worth
  fixing); the CRAN item updated to record the clean results — the only
  remaining step is now exactly `devtools::submit_cran()` + the maintainer-
  email confirmation click, both still owner-only. Added `PROJECT_LEARNINGS.md`
  Learning 333 (verify a probability-hedged prediction against the actual
  result once it lands; two "Windows CI" surfaces are not the same
  environment). Bumped `CLAUDE.md`'s learnings/session-count pointer
  (332→333, 361→362). Self-caught and fixed two mistakes before commit: a
  fabricated R-devel version number, and a duplicated `## Downstream
  dependencies` header from an imprecise edit. Phase 3E: N/A, justified — no
  `R/`/`tests/`/`DESCRIPTION`/`NAMESPACE` touched; no `submit_cran()` or other
  outward-facing action taken.

### 2026-07-11 · [ad hoc] Claimed session to process win-builder/R-hub results (Session 362)
- **Deliverable:** Phase 1B claim stub in `SESSION_NOTES.md` and a `status: pending`
  receipt in `HANDOFFS.md` for processing S361's win-builder/R-hub results.
  Commit `8ad229cb`. (Note: investigation of the pasted emails + the R-hub run
  happened before this claim, per the session notes — read-only calls only, no
  repo file touched before this commit.)

### 2026-07-11 · [ad hoc] S361 close-out commit (session notes, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap in
  the same session rather than leaving it for the next session's Phase 0 reconcile
  (mirroring the S349-S360 precedent for self-closing gaps). Records the trigger/
  finding work logged below. Commit `4631d461`.

### 2026-07-11 · [ad hoc] Triggered CRAN 2.0.0 win-builder x3 + R-hub v2; found an undocumented Windows-only CI regression (Session 361)
- **Deliverable:** Owner picked "I trigger win-builder + R-hub" via `AskUserQuestion`
  (explicitly excluding `devtools::submit_cran()`, which stays owner-only).
  Verified zero drift since S359's local gate first. Ran `devtools::build()`, then
  dispatched `devtools::check_win_devel()` / `check_win_release()` /
  `check_win_oldrelease()` (all three uploaded cleanly; results by email to
  `rmsharp@me.com` ~2026-07-11 18:30). Ran `rhub::rhub_doctor()` (all green) then
  `rhub::rhub_check(platforms = c("linux", "windows", "macos"))`; confirmed via
  `gh run list` the dispatch actually started (run 29171440079,
  `occupational-burro`), not just that the R console returned.
  **Finding:** that same `gh run list` call surfaced `R-CMD-check.yaml` failing on
  `windows-latest (release)` on every push since S351 (`b440730c`, 2026-07-10) — 7
  consecutive red runs, unnoticed until now; `ubuntu-latest`/`macos-latest` pass
  every time, so S359's macOS-only local `--as-cran` gate structurally could not
  have caught it. Read the failure log: `test_modInput_excelSireDam.R` fails via
  `create_wkbk()` (`R/create_wkbk.R:61`) → `WriteXLS::WriteXLS()`, a classic
  Perl-on-Windows dependency symptom — very likely to also surface in the
  win-builder/R-hub results just dispatched. Documented root cause, evidence, and
  two fix options as a new READY `BACKLOG.md` item rather than fixing it this
  session (SAFEGUARDS mode-switch rule; this session's narrow authorization was
  triggering only). Cross-referenced from the existing CRAN-resubmission item.
  Added `PROJECT_LEARNINGS.md` Learning 332 (local single-platform checks can miss
  a regression CI would catch — `gh run list` as a standing companion check).
  Bumped `CLAUDE.md`'s learnings/session-count pointer (331→332, 359→361). Phase
  3E: N/A, justified — no `R/`/`tests/`/`DESCRIPTION`/`NAMESPACE` touched.

### 2026-07-11 · [ad hoc] Claimed session for CRAN 2.0.0 win-builder/R-hub trigger (Session 361)
- **Deliverable:** Phase 1B claim stub in `SESSION_NOTES.md` and a `status: pending`
  receipt in `HANDOFFS.md` for triggering the Phase 5 cross-platform checks (scope
  confirmed by the owner via `AskUserQuestion`, excluding `submit_cran()`). Commit
  `eb45667c`.

### 2026-07-11 · [ad hoc] S360 close-out commit (session notes, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap in
  the same session rather than leaving it for the next session's Phase 0 reconcile
  (mirroring the S349-S359 precedent for self-closing gaps). Records the work
  commit (`67aee91b`) for the AskUserQuestion priorities-picker logged below.

### 2026-07-11 · [ad hoc] Added AskUserQuestion priorities-picker to Phase 0 (Session 360)
- **Deliverable:** User-directed methodology customization: extended `CLAUDE.md`'s
  "Additional Phase 0 steps" (the 2026-07-09 priorities-list entry) so that after
  the orientation report's prose priorities list renders, one `AskUserQuestion`
  call presents the numbered `READY`/`BLOCKED`/`DECISION NEEDED` items as a
  structured pick. Design choices recorded inline: one option per numbered item
  (never the "Lower priority"/"Informational" bundles), capped at 4 (the tool's
  max), same order as the report, "+N more" noted if truncated (no silent cap);
  skipped entirely if fewer than 2 numbered items exist; the harness's built-in
  "Other" free-text option (plus a plain prose reply) still lets the user pick
  anything not listed. Supplements, not replaces, the prose report -- adds no new
  `SESSION_RUNNER.md` step and does not change the mandatory Phase 0
  STOP-and-wait (the question itself is the wait). Not sourced from a `BACKLOG.md`
  item or GitHub issue -- pure ad hoc, user-directed in conversation. Phase 3E:
  N/A, justified -- `CLAUDE.md` prose only, no runtime behavior.

### 2026-07-11 · [ad hoc] S359 close-out commit (session notes, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap in
  the same session rather than leaving it for the next session's Phase 0 reconcile
  (mirroring the S349-S358 precedent for self-closing gaps). Records the work
  commit (`e320f245`) for the CRAN pre-submission gate refresh logged below.

### 2026-07-11 · [ad hoc] Refreshed local CRAN pre-submission gate for v2.0.0 resubmission (Session 359)
- **Deliverable:** Owner picked "local prep-only refresh" via `AskUserQuestion` (the
  BACKLOG item's own "Next (owner action)" step covers win-builder/R-hub/
  `submit_cran()`, all confirmed outward-facing/owner-only by
  `docs/planning/cran-2.0.0-phase5-runbook.md`'s own stated boundary — not
  triggered this session). Re-ran `R CMD build .` + `R CMD check --as-cran
  --timings` on current `master` (134 commits since the archived sha `8ca8bb24`,
  9 touching `R/`/`tests/`/`DESCRIPTION`/`NAMESPACE`, last locally confirmed
  S241/S242 2026-06-29): `0 errors | 0 warnings | 1 note` (down from 2 — the
  local HTML-manual note no longer reproduces on this machine's current Tidy).
  Slowest example 1.465s (`groupAddAssign`), tests 86s, vignette rebuild 21s, all
  inside prior headroom. **Finding:** the win-builder/R-hub results already on
  file in `cran-comments.md` were captured in S328 (2026-07-09, commit
  `8ca8bb24`) — the exact commit later archived, one day *before* S349's
  2026-07-10 fix (`f7a62aca`) for the CRAN Policy violation that caused the
  archival. `git merge-base --is-ancestor 8ca8bb24 f7a62aca` confirms the old
  results checked pre-fix code; they no longer attest to what this resubmission
  will carry. Reset those lines in `cran-comments.md` to plain placeholders (no
  session/commit jargon — the file is pasted verbatim into the CRAN submission)
  and recorded the full ancestry-check reasoning in the runbook instead (which is
  owner-facing process documentation, not a CRAN artifact). `BACKLOG.md`'s CRAN
  item updated in place (not removed — win-builder/R-hub/`submit_cran()` remain
  outstanding, owner action, unchanged). Added `PROJECT_LEARNINGS.md` Learning
  331, bumped `CLAUDE.md`'s learnings count (330->331). Phase 3E: N/A, justified
  — no `R/`/`tests/`/runtime-behavior files changed; deliverable is a package
  check + two doc refreshes.

### 2026-07-11 · [ad hoc] Claimed session for CRAN v2.0.0 pre-submission gate refresh (Session 359)
- **Deliverable:** Phase 1B claim stub in `SESSION_NOTES.md` and a `status: pending`
  receipt in `HANDOFFS.md` for the BACKLOG.md "CRAN resubmission of v2.0.0" item's
  local-prep-only refresh (scope confirmed by the owner via `AskUserQuestion`).
  Commit `19ae5657`.

### 2026-07-11 · [ad hoc] S358 close-out commit (session notes, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap in the
  same session rather than leaving it for the next session's Phase 0 reconcile
  (mirroring the S349-S357 precedent for self-closing gaps). Records the audit/
  bookkeeping commit (`93c9c207`) for the XARCH-3 audit logged below.

### 2026-07-11 · [ad hoc] Audited NEW-12/XARCH-3 Shiny-progress-hook BACKLOG item (Session 358)
- **Deliverable:** Verified firsthand (not trusted from the S21 plan's own text) that
  the "Shiny progress threaded into compute" concern is fully resolved. Swept all 230
  `R/*.R` files for direct `shiny::` coupling or in-place `Progress` construction
  outside the `mod*.R` Shiny module layer; confirmed `reportGV`/`groupAddAssign`/
  `geneDrop`/`convertRelationships`/`gvaConvergence` all use the clean injected
  `updateProgress` callback pattern; re-confirmed `getMinParentAge.R`'s Phase 9/S35
  deletion; ran the six compute-layer test files standalone (0 Shiny session/
  `testServer()` involvement, all pass) as behavioral proof beyond the static grep.
  0 findings requiring a fix. Report:
  `docs/audits/XARCH3_SHINY_PROGRESS_HOOK_AUDIT_2026-07-11.md`. Removed the BACKLOG.md
  item (its own stated deliverable is fully answered: no work remains).

### 2026-07-11 · [ad hoc] Claimed session for NEW-12/XARCH-3 Shiny-progress-hook audit (Session 358)
- **Deliverable:** Phase 1B claim stub in `SESSION_NOTES.md` and a `status: pending`
  receipt in `HANDOFFS.md` for the BACKLOG.md "NEW-12 / XARCH-3 — Shiny progress hook"
  audit. Commit `eaa36b8b`.

### 2026-07-11 · [ad hoc] S357 close-out commit (session notes, handoff receipt)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap in the
  same session rather than leaving it for the next session's Phase 0 reconcile
  (mirroring the S349-S356 precedent for self-closing gaps). Records the close-out
  commit (`47e4fb65`) for the Document 1 coverage-fix logged below.

### 2026-07-11 · [ad hoc] Fixed Document 1's Testing-at-Scale file-count/coverage conflation (Session 357)
- **Deliverable:** Fixed "Document 1's Testing-at-Scale section conflates file-count
  growth with testing quality" (`BACKLOG.md`, user-flagged S345). Pulled real coverage
  and test-case numbers into `vignettes/articles/engineering-the-2.0.0-release.qmd`
  §Section 3 in place of the file-count-only headline metric.
- **What changed:** Extended `vignettes/articles/data-raw/build-document1-evidence.R`'s
  T5/F3 checkpoint block to add `test_case_count` (`test_that()` blocks, derived from
  `git show <sha>:<file>` at each of the 5 existing checkpoints -- fully offline,
  cross-checks exactly against the pre-existing `test_file_count` column) and
  `coverage_pct` (Codecov's per-commit API, `api.codecov.io/api/v2/github/rmsharp/
  repos/nprcgenekeepr/commits/<sha>/`, queried live). Both BACKLOG-named endpoint
  commits (v1.0.8 `4548aa1b`, v2.0.0 `8ca8bb24`) had a recorded report: coverage
  88.62% -> 99.70%, test cases 283 -> 1,567 (454%, steeper than the 95% file-count
  growth). The three intermediate checkpoints (`6fd87749`, `3db018d1`, `a1618c48`)
  returned a 404 from Codecov's API (confirmed via its paginated commit list, 541
  records back to 2018, these three shas absent throughout) -- rendered as an honest
  "not recorded" table cell plus a prose sentence naming the mechanism, not silently
  dropped or invented. Regenerated `vignettes/articles/data/testing-growth.csv` from
  the extended script (not hand-edited) and updated the article's opening paragraph,
  `tbl-testing-growth` table/caption, and the paragraph following it accordingly.
- **Verification:** `quarto render engineering-the-2.0.0-release.qmd` succeeds cleanly
  twice (before and after a line-length wrap fix to the new R code) with 0 broken
  cross-references (`?@` artifact grep) and all 5 tables / 5 figures numbering
  correctly; spot-checked 3 unmodified sections' render output. Re-ran the isolated
  data-generation block twice, byte-identical output both times. No `R/` or `tests/`
  files changed -- package build-equivalent (`devtools::check()`/`test()`) not
  re-run, correctly out of scope. `PROJECT_LEARNINGS.md` Learning 329 added;
  `CLAUDE.md` learnings count bumped 328->329; `BACKLOG.md` item removed.

### 2026-07-11 · [ad hoc] S356 close-out commit (session notes, handoff receipt, learnings)
- **Deliverable:** Closes this session's own `CHANGELOG.md` ledger frontier gap in the
  same session rather than leaving it for the next session's Phase 0 reconcile
  (mirroring the S349-S355 precedent for self-closing gaps). Records the close-out
  commit (`f597d903`) for the read.csv() audit logged below.

### 2026-07-11 · [ad hoc] Audited read.csv() call sites for F/T/TRUE/FALSE coercion risk (Session 356)
- **Deliverable:** Audited "other `read.csv()` calls in `tests/` for the same F/T/TRUE/
  FALSE type-coercion risk that recurred in S355" (`BACKLOG.md`, discovered S355). A
  fresh grep (not a reuse of S355's list) found 27 call sites across 12 files (S355's
  own sweep had found "roughly a dozen" across 9 -- it missed a whole file,
  `test_modSummaryStats_coverage.R`). One file audited directly, the other 11 fanned out
  to independent agents (one per file) via the Workflow tool, each tracing the CSV's
  real data origin (R/ `downloadHandler` content function or in-test fixture) before
  verdicting. **Result: 0 vulnerable sites.** 6 `ALREADY-FIXED` (guarded by
  `colClasses`, three of them since their very first commit), 21 `PASS` (no column
  actually asserted on can ever collapse to an all-T/F-token set). The two
  `test_modSummaryStats_coverage.R` `ALREADY-FIXED` sites are in fact the *original*
  Learning 269(e)/S290 fix -- the module where this defect class was first discovered.
  Three sites read a fixture with a mixed-sex column that is never actually asserted on
  (dormant risk, no action needed unless a future edit adds that assertion). Full
  report: `docs/audits/READCSV_COLCLASSES_AUDIT_2026-07-11.md`. **No code changes** --
  removed the now-answered `BACKLOG.md` item. `PROJECT_LEARNINGS.md` Learning 328.

### 2026-07-11 · [ad hoc] S355 close-out commit (session notes, handoff receipt, learnings)
- **Deliverable:** Closed out Session 355 (the flaky groupAddAssign test fix, logged below):
  wrote the full session writeup + Session 354 handoff evaluation + self-assessment to
  `SESSION_NOTES.md`, completed the `HANDOFFS.md` receipt to `status: complete` referencing
  the fix commit (`2aa2e3f6`) directly, added `PROJECT_LEARNINGS.md` Learning 327, bumped
  `CLAUDE.md`'s learnings count, and filed a new `BACKLOG.md` audit item. Closes this
  session's own `CHANGELOG.md` ledger frontier gap in the same session rather than leaving
  it for the next session's Phase 0 reconcile (mirroring the S349-S354 precedent for
  self-closing gaps).

### 2026-07-11 · [ad hoc] Fixed intermittently flaky groupAddAssign tests (Session 355)
- **Deliverable:** Fixed "`test_modBreedingGroups.R`/`test_modBreedingGroups_groupAddAssign.R`
  have intermittently flaky, unseeded stochastic assertions" (`BACKLOG.md`, discovered S351).
  Diagnosis found TWO distinct root causes, not the single class BACKLOG originally assumed:
  (1) `"modBreedingGroupsServer handles maximum number of groups"` and (3)
  `"modBreedingGroupsServer works with examplePedigree subset"` are genuine unseeded
  `groupAddAssign()` MIS-sampling count mismatches, empirically reproduced at ~22% and ~10%
  failure rates respectively (default `iter = 10L`, per the UI, is not enough to always hit
  the requested group count). (2) `"downloadGroup writes the selected group's annotated
  members"` is NOT a count mismatch -- it is a base-R `read.csv()` `type.convert()` gotcha:
  when `groupAddAssign()` forms an all-female group (common, since the algorithm ignores
  female-female kinship by default), the test's own `read.csv()` call auto-coerces an all-`"F"`
  Sex column to logical `FALSE`, so `all(df$Sex %in% c("M","F"))` fails (~2% empirically). The
  actual `downloadHandler`/CSV file content is correct; only the test's naive `read.csv()` type
  inference is fragile. Fix: seeded (1) and (3) via the module's existing
  `options(nprcgenekeepr.bg_seed = 1L)` E2E determinism hook (mirrors the file's own established
  pattern), verified 10/10 deterministic trials each at the exact asserted counts (`nGroups()==20`,
  `length(groups)==3`). Fixed (2) by adding `colClasses = c("character", "character", "numeric")`
  to its `read.csv()` call -- robust to whichever group composition randomly forms, no seed
  needed. Verification: each fixed test re-run 40x via the full file (not filtered) with 0
  failures across all three; `lintr::lint()` 0 on both changed files; full-suite regression read
  1 failed (pre-existing, unrelated, `test_vignettes_no_deprecated_minParentAge.R`, same as
  S349-S354) / 0 error / 0 warning. No production `R/` code changed -- both root causes were
  entirely within the tests' own setup/assertion code. `GREEN->REFACTOR` gate: owner declined
  further refactor (the seed-option blocks intentionally mirror the file's existing pattern
  rather than introducing a new helper).

### 2026-07-11 · [ad hoc] S354 close-out commit (session notes, handoff receipt, learnings)
- **Deliverable:** Closed out Session 354 (the `inst/_pkgdown.yml` dead-config fix, logged
  below): wrote the full session writeup + Session 353 handoff evaluation +
  self-assessment to `SESSION_NOTES.md`, completed the `HANDOFFS.md` receipt to
  `status: complete` referencing the fix commit (`d14cd913`) directly, added
  `PROJECT_LEARNINGS.md` Learning 326, and bumped `CLAUDE.md`'s learnings count. Closes
  this session's own `CHANGELOG.md` ledger frontier gap in the same session rather than
  leaving it for the next session's Phase 0 reconcile (mirroring the S349–S353 precedent
  for self-closing gaps).

### 2026-07-11 · [ad hoc] Fixed dead inst/_pkgdown.yml Reference-page config (Session 354)
- **Deliverable:** `inst/_pkgdown.yml`'s curated 4-group Reference-page structure
  (`BACKLOG.md` item, discovered S345) was dead configuration: pkgdown's config
  resolver only ever reads the first config file it finds, and the project's root
  `_pkgdown.yml` (no `reference:` key) shadowed it — confirmed live via
  `pkgdown::as_pkgdown(".")$meta$reference` (`NULL`) and on the deployed site (a flat
  "All functions" list, not the grouped structure `README.md:86-94` describes).
  Independently, `inst/_pkgdown.yml`'s own lists had drifted from `NAMESPACE`
  regardless of the shadowing bug (64 of 182 current exports missing from "All
  exposed functions", incl. every `mod*Server`/`mod*UI` pair, plus ~34 further
  entries naming functions no longer in `NAMESPACE` at all). Owner picked "merge +
  re-sync into root" over "delete the grouping" via a pre-RED scope-decision
  `AskUserQuestion`. Moved the `reference:` block into root `_pkgdown.yml`, re-synced:
  added the 1 missing data object (`speciesGestation`, 24→25); dropped 2 stale
  entries from "Primary interactive functions" that are not exported functions
  (`addErrTxt` — real but internal/non-exported; `finalRpt` — a data object, already
  correctly listed under "Data objects"); rebuilt "All exposed functions" as the
  complete, current 182-export list. Deleted `inst/_pkgdown.yml`. `README.md:86-94`
  needed no update (describes the same 4 group names, unchanged). Followed
  `DEVELOPMENT_WORKSTREAM.md`'s one-off-fix path under Strict TDD, full
  RED/GREEN/(REFACTOR skipped, owner-confirmed unnecessary) with all phase gates.
- **Tests:** New `tests/testthat/test_pkgdown_reference_config.R` (4 `test_that`
  blocks, using `pkgdown::as_pkgdown()`'s public API only, no `:::` internals):
  root config has a populated `reference:` block; every current `NAMESPACE` export is
  covered by some group; the "Data objects" group covers every `data/` object;
  `inst/_pkgdown.yml` no longer exists. Guarded with `skip_if_not()`/
  `skip_if_not_installed()` so it no-ops cleanly in a built/installed tree (both
  config files are `.Rbuildignore`'d). Confirmed genuine RED against unfixed code (3
  failures + 1 skip, all for the right reason) before committing; all 4 GREEN after
  the fix.
- **Verification:** `devtools::document()` clean 0-file delta (expected, no roxygen
  touched). `lintr::lint()`: 0 on the new test file. Full-suite regression read: 1
  failed (pre-existing, unrelated, `test_vignettes_no_deprecated_minParentAge.R`,
  same as S349–S353) / 0 error / 0 warning. Build-equivalent check (no Shiny/R
  runtime behavior changed, so no live-browser Phase 3E smoke test applies): a local
  `pkgdown::build_reference_index()` render succeeded — all 4 group headings render
  in the built `reference/index.html`, 204 unique topic links present, no errors.
- **Commits:** `c8b68ef9` (claim), `a88b8237` (RED test), `d14cd913` (GREEN fix).

### 2026-07-10 · [ad hoc] S353 close-out commit (session notes, handoff receipt, learnings)
- **Deliverable:** Closed out Session 353 (the `examplePedigree` `fromCenter` fix, logged
  below): wrote the full session writeup + Session 352 handoff evaluation + self-assessment
  to `SESSION_NOTES.md`, completed the `HANDOFFS.md` receipt to `status: complete`
  referencing the fix commit (`1c1a7849`) directly, added `PROJECT_LEARNINGS.md` Learning
  325, and bumped `CLAUDE.md`'s learnings count. Closes this session's own `CHANGELOG.md`
  ledger frontier gap in the same session rather than leaving it for the next session's
  Phase 0 reconcile (mirroring the S349–S352 precedent for self-closing gaps).

### 2026-07-10 · [ad hoc] Added fromCenter column to shipped examplePedigree (Session 353)
- **Deliverable:** `data(examplePedigree)` had no `fromCenter` (colony-origin) column, so
  `modPotentialParentsServer()` (the Potential Parents tab) always degraded to an empty
  result on the package's own example data — correct behavior, but it meant the standard
  example pedigree could never demonstrate a populated result (`BACKLOG.md` item,
  discovered S348/Learning 321). Added a new `data-raw/examplePedigree.R` generator script
  (mirrors `data-raw/rhesusPedigree.R`) deriving `fromCenter` from `examplePedigree`'s
  existing, documented `origin`/`recordStatus` fields: `TRUE` for a blank origin + a real,
  non-synthetic `"original"` record; `FALSE` for imported animals (non-blank origin) or
  synthetic placeholder second-parent rows (`recordStatus == "added"`). Verified via grep
  first that this could not break the existing "degrades gracefully without fromCenter"
  coverage — that coverage depends on two OTHER, fully independent fixtures
  (`inst/extdata/ExamplePedigree.csv`, a hand-crafted synthetic `data.frame`), not
  `data(examplePedigree)` itself (fix commit `1c1a7849`).
- Strict TDD RED/GREEN/(REFACTOR skipped, owner-confirmed unnecessary): 1 pre-RED
  scope-decision `AskUserQuestion` plus the PRE-RED→RED and RED→GREEN phase gates. RED
  tests: new `tests/testthat/test_examplePedigree.R` (structure/type contract: column
  presence/type/no-NA, exact 2267/1427 derivation split) and 1 test appended to
  `tests/testthat/test_getPotentialParents.R` (`getPotentialParents()` on
  `qcStudbook(examplePedigree, ...)` returns exactly 1587 candidates, test commit
  `d059a15c`). Genuine RED confirmed against unfixed code both in scratchpad and in the
  committed test files; GREEN confirmed after, including a self-caught `nzchar_linter`
  lint fix re-verified GREEN.
- **Self-caught TDD violation, corrected in-session:** wrote `data-raw/examplePedigree.R`
  before posing the RED→GREEN `AskUserQuestion` gate. Acknowledged per `CLAUDE.md`'s Error
  Handling rule, did not execute the script, and posed the proper gate before running
  anything.
- **Phase 3E:** live `shinytest2::AppDriver` smoke test against the real modular app
  (example pedigree generated via `makeExamplePedigreeFile()`, uploaded through the real
  Input tab, live navigation to Pedigree Browser then Potential Parents) confirmed the
  status message "Found candidate parents for 1587 animal(s)..." and a downloaded CSV of
  exactly 1587 rows — matching the unit test's locked value exactly, an independent live
  cross-check.
- Verification: full-suite regression read 1 failed (pre-existing, unrelated,
  `test_vignettes_no_deprecated_minParentAge.R`, same as S349–S352) / 0 error / 0 warning;
  all 9 directly-related test files individually clean; `lintr::lint()` 0 on all 4
  changed/new files after 1 self-caught fix; `devtools::document()` clean 1-file delta
  (`man/examplePedigree.Rd`, 12→13 columns), 0 NAMESPACE delta.
- Removed the resolved `BACKLOG.md` item and updated the Document 2 Phase D note (all
  three Phase-C-discovered findings now fixed, not just two); added a `NEWS.Rmd` bullet
  under the still-unpublished 2.0.0 entry and rendered `NEWS.md`. Added
  `PROJECT_LEARNINGS.md` Learning 325 (BACKLOG-item-risk-clause-as-research-task pattern;
  derive-from-an-existing-documented-field technique) and bumped `CLAUDE.md`'s learnings
  count (324→325).

### 2026-07-10 · [ad hoc] S352 close-out commit (session notes, handoff receipt)
- **Deliverable:** Closed out Session 352 (the `nTopAnimals` conditionalPanel fix,
  logged below): wrote the full session writeup + Session 351 handoff evaluation +
  self-assessment to `SESSION_NOTES.md`, completed the `HANDOFFS.md` receipt to
  `status: complete` referencing the fix commit (`cc821d9f`) directly. Closes this
  session's own `CHANGELOG.md` ledger frontier gap in the same session rather than
  leaving it for the next session's Phase 0 reconcile (mirroring the S349–S351
  precedent for self-closing gaps).

### 2026-07-10 · [ad hoc] Fixed nTopAnimals conditionalPanel double-prefix bug (Session 352)
- **Deliverable:** `modBreedingGroupsUI()`'s `nTopAnimals` panel
  (`R/modBreedingGroups.R`) used
  `sprintf("input['%s'] == 'topRanked'", ns("animalSource"))` + `ns = ns` as its
  `conditionalPanel` condition. Passing `ns = ns` already narrows Shiny's
  client-side `input`/`output` scope to unprefixed names, so the `ns(...)`-built
  condition double-prefixed and always evaluated `FALSE` — the "Number of top
  animals" numeric input never appeared, in any `animalSource` state, including
  the default `"topRanked"` state where it should be visible on page load.
  Discovered live during S351's Phase 3E smoke test while fixing the sibling
  Custom-sex-ratio control (`BACKLOG.md` item). Fixed with the bare
  `"input.animalSource == 'topRanked'"`, matching the already-fixed sibling
  `sexRatio`/`customSexRatio` panel's pattern.
- Strict TDD RED/GREEN/(REFACTOR skipped, owner-confirmed unnecessary), 3
  `AskUserQuestion` phase gates. RED test added to
  `tests/testthat/test_modBreedingGroups.R`: greps the rendered UI HTML's
  `data-display-if` attribute for the panel's `conditionalPanel`, asserting the
  correct unprefixed condition string is present and the double-prefixed
  namespaced form is absent — scoped to the attribute itself (not the whole
  HTML) after an initial draft assertion falsely matched the radioButtons
  widget's own legitimate namespaced element id. Genuine RED confirmed against
  unfixed code both in scratchpad and in the committed test file (via
  `git stash`) before the fix; GREEN confirmed after.
- **Phase 3E:** live `shinytest2::AppDriver` smoke test against the real
  modular app (Excel/CSV pedigree loaded via the Input tab, live navigation to
  the Breeding Groups tab) confirmed the panel's `[data-display-if]` ancestor
  reports `display: block` at the default `"topRanked"` state, `display: none`
  after switching to `"All available"`, and `display: block` again after
  switching back — correcting the previously-documented always-`none` behavior.
- Verification: full-suite regression read 1 failed (pre-existing, unrelated,
  `test_vignettes_no_deprecated_minParentAge.R`, same as S349–S351) / 0 error /
  0 warning; all directly-related test files individually clean; `lintr::lint()`
  0 on both changed files; `devtools::document()` 0 delta.
- Removed the resolved `BACKLOG.md` item; added a `NEWS.Rmd` bullet under the
  still-unpublished 2.0.0 entry and rendered `NEWS.md`. No new
  `PROJECT_LEARNINGS.md` entry: this fix directly executes the sibling-bug fix
  Learning 324 already fully documented (root cause, mechanism, and exact fix
  shape) when it was discovered and correctly left out of scope in S351.

### 2026-07-10 · [ad hoc] S351 close-out commit (session notes, handoff receipt, learnings)
- **Deliverable:** Closed out Session 351 (the Breeding Groups Custom sex ratio fix,
  logged below): wrote the full session writeup + Session 350 handoff evaluation +
  self-assessment to `SESSION_NOTES.md`, completed the `HANDOFFS.md` receipt to
  `status: complete` referencing the fix commit directly (no self-referential sha,
  so no separate backfill commit was needed), added `PROJECT_LEARNINGS.md` Learning
  324 + a new `[ns-scope-conditional]` glossary reflex, and bumped `CLAUDE.md`'s
  learnings count. Split close-out into three ≤5-file commits (fix; ledger/backlog/
  release-notes; notes/handoff/learnings) per `SAFEGUARDS.md`'s per-commit 5-file
  blast-radius cap.

### 2026-07-10 · [ad hoc] Fixed Breeding Groups "Custom" sex ratio missing numeric input (Session 351)
- **Deliverable:** `modBreedingGroupsUI()`'s `sexRatio` radioButtons offered "Custom"
  with no numeric input to specify the ratio; the server's
  `parseSexRatio(input$sexRatio)` called `as.numeric("custom")`, which is `NA` and
  silently fell back to `0.0` (behaviorally identical to "None"). Added a
  `conditionalPanel`-gated `numericInput("customSexRatio", ...)` and changed
  `parseSexRatio()` to read it directly instead of parsing the radio choice string.
  Strict TDD RED/GREEN/(REFACTOR skipped, owner-confirmed) throughout, 3
  `AskUserQuestion` phase gates.
- **Phase 3E caught and this session fixed a second defect in its own new code:**
  the new `conditionalPanel`'s condition initially copied the sibling
  `nTopAnimals` panel's pattern (`sprintf("input['%s'] == 'custom'", ns("sexRatio"))`
  + `ns = ns`), which never actually shows the panel — passing `ns = ns` already
  narrows Shiny's client-side `input`/`output` scope to unprefixed names, so a
  condition built via `ns(...)` double-prefixes and always evaluates `FALSE`.
  Fixed by using the bare `"input.sexRatio == 'custom'"`, matching
  `?shiny::conditionalPanel`'s own documented example; confirmed live via
  `shinytest2::AppDriver`. The sibling `nTopAnimals` panel has the identical,
  already-shipping bug — correctly left unfixed (out of scope) and filed as a new
  `BACKLOG.md` item instead, grep-confirmed as the only other instance in `R/`.
- **Verified:** full-suite regression read 1 failed (pre-existing, unrelated,
  `test_vignettes_no_deprecated_minParentAge.R`, same as S349/S350) / 0 error / 0
  warning; `lintr::lint()` 0 on both changed files; `devtools::document()` 0 delta;
  live-browser Phase 3E (`shinytest2::AppDriver`) confirmed the control renders/hides
  correctly and forms groups with a real Custom ratio value end to end. Also
  discovered and documented (not fixed — out of scope), 2 pre-existing intermittently
  flaky, unseeded stochastic `groupAddAssign()` test assertions, confirmed
  pre-existing via `git stash` against unmodified code.
- **`BACKLOG.md`:** removed the resolved Custom-sex-ratio item; updated the Document 2
  Phase D cross-reference; added 2 new discovered items (the `nTopAnimals`
  `conditionalPanel` bug; the flaky stochastic `groupAddAssign` tests).

### 2026-07-10 · [ad hoc] S350 close-out commit (session notes, handoff receipt, learnings)
- **Deliverable:** Closed out Session 350 (the Excel-upload sire/dam corruption fix,
  logged below): wrote the full session writeup + Session 349 handoff evaluation +
  self-assessment to `SESSION_NOTES.md`, completed the `HANDOFFS.md` receipt to
  `status: complete` referencing the fix commit directly (no self-referential sha,
  so no separate backfill commit was needed), added `PROJECT_LEARNINGS.md` Learning
  323, and bumped `CLAUDE.md`'s learnings count. Split close-out into two ≤5-file
  commits (ledger/backlog/release-notes, then notes/handoff/learnings) rather than
  one bundled commit, per `SAFEGUARDS.md`'s per-commit 5-file blast-radius cap.

### 2026-07-10 · [ad hoc] Fixed Excel-upload sire/dam pedigree corruption (Session 350)
- **Deliverable:** `R/modInput.R`'s `readDataFile()` called
  `readxl::read_excel(file$datapath)` with no `col_types`; `readxl` samples early
  rows to guess each column's type, defaults sire/dam to `logical` because the
  earliest rows are blank (founder/unknown-parent rows), then silently converts
  every later alphanumeric sire/dam ID it cannot parse as logical to `NA` — with no
  warning surfaced to the app user. Confirmed on a round-trip of the shipped
  `data(examplePedigree)` via `makeExamplePedigreeFile(..., fileType = "excel")`:
  100% of the 2026 non-blank sire values and all 2026 non-blank dam values became
  `NA`, collapsing the pedigree to near-all-founders on the exact code path a real
  user's Excel upload goes through via the Input tab. The CSV/text-file paths are
  unaffected (`read.csv`/`read.table` scan the whole column, not a sample). Root-
  cause fix: reuse the already-existing, already-tested internal helper
  `readExcelPOSIXToCharacter()` (`R/readExcelPOSIXToCharacter.R`, `col_types =
  "text"`) that `getPedigree()`, `getGenotypes()`, and `readKinshipOverrides()`
  already use for their own Excel reads, instead of calling `readxl::read_excel()`
  directly — a 1-line change, no new logic. Verified date columns still round-trip
  as parseable `"YYYY-MM-DD"` text and that `qcStudbook()` already coerces them
  itself via `convertDate()`/`as.Date()`, so no downstream behavior change is
  needed. Followed `DEVELOPMENT_WORKSTREAM.md`'s one-off-fix path (not a campaign)
  under Strict TDD, full RED/GREEN/REFACTOR with all phase gates; verified genuine
  RED in scratchpad before presenting the plan (S349's false-RED lesson applied).
- **Verify (firsthand):** 2 new tests (`tests/testthat/test_modInput_excelSireDam.R`)
  both green — unit-level `readDataFile()` non-NA sire/dam count + type check, and
  an end-to-end `modInputServer` integration test via a real `getData` button click
  asserting the cleaned studbook keeps >1000 non-NA sire values (was 3 before the
  fix). Full-suite regression read (`NOT_CRAN=true`) **1 failed / 0 error / 0
  warning** (the 1 failure, `test_vignettes_no_deprecated_minParentAge.R`, is the
  same pre-existing, unrelated failure S349 already confirmed via `git stash`).
  `lintr::lint()` on both changed files = **0**; `devtools::document()` **zero
  man/NAMESPACE delta** (internal function, no roxygen change). **Phase 3E runtime
  smoke test (live browser, `shinytest2::AppDriver` against the real modular app):**
  uploaded the real Excel round-trip file through the actual file input, clicked
  "Get Data," then downloaded the result via the app's own "Download Cleaned Data"
  button (the exact artifact a real user gets) — 3694 rows, 2026 non-`NA` sire
  values, 2026 non-`NA` dam values, all matching the source data exactly, including
  the specific known pairing `KRXZ9X` → sire `UFQNBA` that would have silently
  become `NA` before the fix.

### 2026-07-10 · [ad hoc] S349 HANDOFFS.md receipt commit-sha backfill, closed same-session
- **Deliverable:** Filled in this session's own `HANDOFFS.md` receipt `commit: pending` placeholder with the real close-out commit sha (`f7a62aca`), matching the S331-S348 precedent of closing this within the same session rather than leaving it for the next session's Phase 0 reconcile.

### 2026-07-10 · [ad hoc] Fixed the CRAN Policy violation that archived nprcgenekeepr 2.0.0 (Session 349)
- **Deliverable:** Owner forwarded CRAN's 2026-07-09 email: the 2.0.0 submission was
  archived because it "creates ~/nprcgenekeepr.log in violation of the CRAN Policy."
  Root cause: `appServer()` (`R/appServer.R`) unconditionally registered a
  `futile.logger` file appender at `file.path(getSiteInfo()$homeDir,
  "nprcgenekeepr.log")` on every boot — including every `testServer(appServer, ...)`
  run in this project's own suite, which is exactly the path CRAN's win-builder/Debian
  check exercised. Confirmed live on this machine: `~/nprcgenekeepr.log` (23,648
  bytes) already existed, produced purely by running the test suite. The behavior
  contradicted `vignettes/manual_components/_software_development.Rmd`'s own
  documentation ("When the Debug on checkbox is checked... the application writes to
  a file... in the user's home directory") — the checkbox's already-tested
  `debugMode` reactive (`modInput.R`) existed but `appServer.R` never read it.
  Root-cause fix (owner-selected over a minimal tempdir()-only alternative, via
  `AskUserQuestion`): removed the unconditional top-of-function logger init; added an
  `observeEvent(inputResults$debugMode(), ...)` that registers the file appender
  (DEBUG threshold) only when the user explicitly checks "Debug on," and resets to
  `appender.console()` (INFO threshold) otherwise — restoring the documented opt-in
  behavior and satisfying CRAN's "confirmed by the user in an interactive session"
  carve-out. Followed Strict TDD throughout (RED/GREEN/REFACTOR, 2 scope/approach
  `AskUserQuestion` gates + 3 phase-transition gates). Two additional defects were
  self-caught during verification, before any of it reached GREEN: (1) the first-draft
  RED tests passed even against the unfixed code, because `futile.logger`'s
  `appender.file()` creates its target file lazily on the first write that clears the
  threshold, not at registration — every in-repo call site is `flog.debug()`, below
  the buggy code's registered `INFO` threshold, so a naive test using only
  `session$flushReact()` never actually exercised the violation; fixed by having each
  test force an explicit `flog.info(name="nprcgenekeepr")` probe. (2) The first GREEN
  implementation used `observeEvent`'s default `ignoreNULL = TRUE`, which silently
  skipped the safe-default reset on `debugMode()`'s NULL first read (before the
  client posts `input$debugger`'s value) — since `futile.logger`'s registry is
  process-global, this let a fresh session inherit a stale file appender left
  registered by an earlier session in the same R process; reproduced directly as a
  real "cannot open file: No such file or directory" warning, and independently
  surfaced by the full-suite regression read (4 new warnings present only when the
  file ran as part of the full suite, absent in isolation — classic test-order global-
  state leakage). Fixed with `ignoreNULL = FALSE`. Added `PROJECT_LEARNINGS.md`
  Learning 322 documenting both gotchas.
- **Verify (firsthand):** 3 new tests (`tests/testthat/test_appServer_logging.R`) all
  green; full-suite regression read (`NOT_CRAN=true`) **1 failed / 0 error / 0
  warning** (the 1 failure, `test_vignettes_no_deprecated_minParentAge.R`, confirmed
  pre-existing and unrelated via `git stash` against unmodified `master`); `lintr::lint()`
  on both changed files = **0**; `devtools::document()` **zero man/NAMESPACE delta**
  (all `futile.logger` calls stay `::`-qualified). **Decisive end-to-end check:**
  recorded `~/nprcgenekeepr.log`'s mtime before and after a full-suite run against the
  real, unmodified `$HOME` — **identical**, proving the suite no longer writes there
  at all. **Phase 3E runtime smoke test (live browser, `shinytest2::AppDriver` against
  the real modular app, HOME redirected to an isolated tmp dir):** no log file at
  boot; checking "Debug on" plus a real user action (the `goto_input` button) created
  the file with genuine `DEBUG` content (`DEBUG [...] goto_input button clicked`);
  app remained fully functional after unchecking it.
- **Next step (owner action, not this session's):** re-run the CRAN pre-submission
  checks (win-builder / R-hub) and resubmit — `Version: 2.0.0` was archived before
  publication, so no version bump is required for the resubmission itself unless the
  owner prefers one. Updated `BACKLOG.md`'s CRAN-submission-prep item with this
  outcome and the concrete next action.

### 2026-07-10 · [ad hoc] S348 HANDOFFS.md receipt commit-sha backfill, closed same-session
- **Deliverable:** Filled in this session's own `HANDOFFS.md` receipt `commit: pending` placeholder with the real close-out commit sha (`2ba6c204`), matching the S331-S347 precedent of closing this within the same session rather than leaving it for the next session's Phase 0 reconcile.

### 2026-07-10 · [ad hoc] Executed Document 2 Phase C: drafted the colony-manager-guide article, two new findings (Session 348)
- **Deliverable:** `docs/planning/document2-colony-manager-guide-plan.md` §6 Phase C —
  drafted `vignettes/articles/colony-manager-guide.qmd` (Abstract, Introduction,
  Section 1 adapted from `_introduction.Rmd`, Section 2 adapted from
  `_summary_of_major_functions.Rmd` with an original T1 function-group table and F1
  Mermaid pipeline diagram, Section 3 ported/modernized from `ColonyManagerTutorial.Rmd`
  using Phase B's screenshots and Phase A's re-derived N1/N2/N3/N4 numbers verbatim,
  Conclusion). Owner resolved two pre-drafting scope decisions via `AskUserQuestion`:
  Input-tab narrates CSV with an inline Excel-bug caveat; Breeding-Groups subsection
  covers None/Harem fully, omits the Custom-ratio numeric demo (N7).
- **Extended `vignettes/articles/colony-manager-guide-screenshots.R`** with 2 more
  capture blocks (owner-approved via `AskUserQuestion`, after finding Phase A's
  tab-coverage decision — both new tabs in scope — had no matching entry in Phase B's
  34-screenshot inventory, since that inventory was built from `ColonyManagerTutorial.Rmd`'s
  own figure references, which predate both tabs): `genetic_diversity_heatmap.png` and
  `potential_parents_results.png`. Re-ran the full script; 70/70 steps succeeded.
- **A third new finding, recorded to `BACKLOG.md` (not fixed this session):** the shipped
  `data(examplePedigree)` has no `fromCenter` (colony-origin) column, which
  `modPotentialParentsServer` requires — confirmed directly
  (`"fromCenter" %in% names(examplePedigree)` is `FALSE`) — so the Potential Parents tab
  cannot show populated results against this walkthrough's standard example data; the
  article documents the app's own correctly-degraded warning response instead of
  fabricating a populated example.
- Corrected two additional stale claims from `ColonyManagerTutorial.Rmd`, found via
  firsthand source verification rather than trusting the plan's summary table: the GVA
  threshold `selectInput` now offers 1-5 (default 4), not the tutorial's stale "0-3";
  the results table's actual column is named `value`, not "Value Designation" (no
  `colnames=` override exists in `modGeneticValueServer`'s `renderDT`).
- `quarto render colony-manager-guide.qmd` (isolated) succeeded cleanly — zero missing
  images, zero unresolved cross-references. Spot-checked Document 1 still renders.
- Updated `BACKLOG.md` (Document 2 item → Phase D; added the `fromCenter` finding).
  Added `PROJECT_LEARNINGS.md` Learning 321.

### 2026-07-10 · [ad hoc] S347 HANDOFFS.md receipt commit-sha backfill, closed same-session
- **Deliverable:** Filled in this session's own `HANDOFFS.md` receipt `commit: pending` placeholder with the real close-out commit sha (`9d9479ad`), matching the S331-S346 precedent of closing this within the same session rather than leaving it for the next session's Phase 0 reconcile.

### 2026-07-10 · [ad hoc] Executed Document 2 Phase B: screenshot regeneration + two new bug discoveries (Session 347)
- **Deliverable:** `docs/planning/document2-colony-manager-guide-plan.md` §6 Phase B —
  built the checked-in `shinytest2::AppDriver` capture script
  (`vignettes/articles/colony-manager-guide-screenshots.R`) and regenerated all 34
  screenshots per Phase A's gap inventory (25 kept-name in-place, 4 new, 5 correctly
  left untouched as non-app-UI spreadsheet illustrations — 3 more identified this
  session, correcting Phase A's own disposition for them). Deleted the 8 confirmed-
  orphaned pre-rename screenshot duplicates after re-confirming zero references.
- **Live numeric reproductions confirmed matching Phase A exactly:** 3694 QC'd records
  (N1), 54-animal focal trim (N2), 962-animal large-focal-group trim (N3, via the
  shipped `focalAnimals` example object), 332 living animals (N4).
- **Two new production bugs discovered and recorded to `BACKLOG.md` (not fixed this
  session, out of Phase B scope):** (1) HIGH priority — `R/modInput.R`'s
  `readDataFile()` silently corrupts sire/dam data on Excel upload (`readxl::read_excel`
  with no `col_types` infers `logical` from early blank rows, then nulls every later
  alphanumeric ID — confirmed 100% of non-blank sire values lost on a round-trip of the
  shipped example pedigree); this is the same path any real user's Excel upload goes
  through. (2) `modBreedingGroupsUI()`'s "Custom" sex-ratio option has no accompanying
  numeric-value input anywhere in the UI, silently behaving like "None".
- Updated `BACKLOG.md` (Document 2 item → Phase C; added the two new bug items).
  Added `PROJECT_LEARNINGS.md` Learning 320.

### 2026-07-10 · [ad hoc] S346 HANDOFFS.md receipt commit-sha backfill, closed same-session
- **Deliverable:** Filled in this session's own `HANDOFFS.md` receipt `commit: pending` placeholder with the real close-out commit sha (`4941b2e8`), matching the S331-S345 precedent of closing this within the same session rather than leaving it for the next session's Phase 0 reconcile.

### 2026-07-10 · [ad hoc] Executed Document 2 Phase A: screenshot gap inventory + numeric claims re-derivation (Session 346)
- **Deliverable:** `docs/planning/document2-colony-manager-guide-plan.md` §3A/§6 —
  resolved §11 decisions 1/2/5 (tab coverage = both new tabs; screenshot method =
  automated `shinytest2`; title/slug confirmed) via `AskUserQuestion`; built the full
  34-screenshot gap inventory against the current modular UI (finding real functional
  changes, not just relabeling, in 4 of 6 covered tabs); re-derived all 7
  example-data-dependent numeric claims via live `Rscript -e` verification against
  `data(examplePedigree)` (3 reproduce exactly, 2 not-re-verifiable/removed, 2 deferred
  to Phase C live capture). Flagged 8 orphaned pre-rename screenshots for Phase B
  deletion. Updated `BACKLOG.md`'s Document 2 item to point at Phase B. Added
  `PROJECT_LEARNINGS.md` Learning 319.

### 2026-07-10 · [ad hoc] S345 HANDOFFS.md receipt commit-sha backfill, closed same-session
- **Deliverable:** Filled in this session's own `HANDOFFS.md` receipt `commit: pending` placeholder with the real close-out commit sha (`14fd5382`) — the same self-correction previous sessions (S331-S336, S339-S344) each needed, closed within the same session rather than left for the next session's Phase 0 reconcile to catch and backfill.

### 2026-07-10 · [ad hoc] Planned Document 2: port/modernize ColonyManagerTutorial.Rmd (Session 345)
- **Deliverable:** `docs/planning/document2-colony-manager-guide-plan.md` — one planning
  document for the long-deferred "Document 2" BACKLOG item (package purpose, how it
  addresses that purpose, how to put it into use), following
  `RESEARCH_DOCUMENTATION_WORKSTREAM.md` (adapted, matching Document 1's precedent).
- **Owner scope decisions (via `AskUserQuestion`, twice):** (1) article form = new
  `vignettes/articles/*.qmd`, audience = primate-center bioinformatics/colony managers;
  (2) content strategy = **port and modernize `ColonyManagerTutorial.Rmd`** rather than
  draft from scratch, after this session's research found the target content already
  exists.
- **Discovery that reshaped the plan:** a broader `vignettes/` sweep (beyond the current
  public-docs surface) found `vignettes/a3manual.Rmd` + 13
  `vignettes/manual_components/*.Rmd` (CRAN-shipped, actively maintained, sharing
  `README.Rmd`'s own source for Introduction/Summary-of-Functions) and
  `vignettes/ColonyManagerTutorial.Rmd` (748 lines, screenshot-illustrated, titled for
  the exact chosen audience, actively kept in sync with API renames through
  2026-07-07 — but `.Rbuildignore`d and so invisible on CRAN and the pkgdown site; its
  screenshots, `vignettes/shiny_app_use/`, last regenerated 2024-12-16, predate the
  Shiny-module migration Session 22-35).
- **Separate finding, flagged not fixed:** `inst/_pkgdown.yml`'s curated Reference-page
  grouping is dead configuration (confirmed via `pkgdown:::pkgdown_config_path`, shadowed
  by the root `_pkgdown.yml`; confirmed live on the deployed site via `WebFetch` — a flat
  "All functions" list only) and independently stale (64 of 182 current `NAMESPACE`
  exports missing from its list).
- **BACKLOG.md updated:** replaced the "Plan Document 2" item with an "Execute Document 2
  plan (Phase A)" item; added a new item for a user-flagged gap in Document 1's
  Testing-at-Scale section (conflates test-file-count growth with actual coverage/
  test-case/E2E improvement — no `covr`/Codecov percentage or test-case count ever
  cited); added a new item for the `inst/_pkgdown.yml` dead-config finding.
- **`PROJECT_LEARNINGS.md` Learning 318** added (check the full `vignettes/` tree, not
  just the public surface, before scoping a new-document plan as fresh drafting); `CLAUDE.md`'s
  learnings count bumped 317→318.
- No `R/`/`tests/` touched; TDD Phase N/A (planning/documentation session).

### 2026-07-10 · [ad hoc] S344 HANDOFFS.md receipt commit-sha backfill, closed same-session
- **Deliverable:** Filled in this session's own `HANDOFFS.md` receipt `commit: pending` placeholder with the real close-out commit sha (`6bd0d9fb`) — the same self-correction previous sessions (S331-S336, S339, S340, S341, S342, S343) each needed, closed within the same session rather than left for the next session's Phase 0 reconcile to catch and backfill.

### 2026-07-10 · [ad hoc] Pruned the stale BACKLOG.md "issue #40 open" item (Session 344)
- **Deliverable:** Owner picked BACKLOG priority #1 ("Strengthen the shinytest2 E2E assertions + CI stability," GitHub issue #40). Before claiming the session, verified the premise via `gh issue view 40` and found it **CLOSED** (2026-06-11) — not open as `BACKLOG.md` claimed. Reported this to the owner via `AskUserQuestion` instead of starting phantom work; owner chose to prune the stale item as this session's deliverable.
- **Verified DONE, not assumed:** `gh pr view 41` confirms PR #41 (issue #40's work) `MERGED` 2026-06-11, merge commit `0363ffe3`, present in `git log`. Grepped the current test suite for `expect_true(TRUE)`: the 11 hits are all inside historical `# REVIVE: was expect_true(TRUE)...` comments documenting the fix, zero live tautologies remain. `test-e2e-summary-statistics-module.R` now targets `"Summary Statistics"` in all 8 tests (the issue's "7/8 wrong-tab" defect is fixed). `.github/workflows/shinytest2.yaml` runs the E2E tier in per-module fresh-process groups (the Chrome process-count flake mitigation) — a later CI-coverage gap in that grouping (2 files unmatched by any group regex) was also independently confirmed already closed, by Session 337 (2026-07-08/09, `test_shinytest2_workflow_coverage.R` regression guard + 15 green groups). This staleness had been independently flagged — but left unfixed as out-of-scope — by at least 3 prior documentation/audit sessions (the `v2-transformation-article-plan.md` execution pass, and the article's own claim-audit passes around S330-S334); this session is the first to actually correct `BACKLOG.md` itself.
- **Change:** Removed the "Strengthen the shinytest2 E2E assertions + CI stability" item (6 lines) from `BACKLOG.md`'s "Up Next" section — completed work belongs in `CHANGELOG.md`, not `BACKLOG.md` (project convention, see file header). Left the adjacent "Tracker reconciliation" section's now-also-stale "#1–#39" issue-range note untouched — out of this session's declared scope, noted in `SESSION_NOTES.md`/`HANDOFFS.md` for a future session instead of fixed here (SAFEGUARDS.md scope-creep discipline).
- **Phase 3E:** n/a — `BACKLOG.md` only, no `R/`/`tests/` touched, no runtime behavior changed.
- **Session:** S344 · **TDD:** N/A (documentation-hygiene fix, no `R/`/`tests/` touched) · **Verified:** `gh issue view 40`, `gh pr view 41`, `grep -rn "expect_true(TRUE)"` across all `test-app-*`/`test-e2e-*` files, `grep -n "navigate_to_tab" test-e2e-summary-statistics-module.R`, `.github/workflows/shinytest2.yaml` read directly — no claim taken from `BACKLOG.md`'s own stale text.

### 2026-07-10 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit b94ad328 — S343 HANDOFFS.md receipt commit-sha backfill
- **Deliverable:** Phase 0 ledger reconcile (this session) found one commit past the `CHANGELOG.md` frontier with no ledger entry: `b94ad328` ("docs: S343 -- backfill own HANDOFFS.md receipt commit sha"), landed after S343's own close-out commit (`98db4ff7`) that recorded the entry below.
- **Change:** `b94ad328` replaced the S343 `HANDOFFS.md` receipt's `commit: pending` placeholder with the real commit sha (`98db4ff7`) — a self-correction of the just-written receipt, not new production work. Same class of action as the `ebeeb9fd`/`7c0d680d`/`04c8de1d`/`5f0b81d2`/`ee690776`/`2278b46f`/`cc0f7798` backfills below (S342's, S341's, S339's, S334's, S333's, S332's, and S331's equivalent self-fixes).
- **Session:** this session (backfilling S343's own commit) · **Verified:** `git show --stat b94ad328` (single-file, 2-line diff to `HANDOFFS.md`); `git log -1 --format=%H -- HANDOFFS.md` now matches `b94ad328` with no further gap.

### 2026-07-10 · [ad hoc] Fixed all 15 confirmed Document 1 audit findings (Session 343)
- **Deliverable:** Owner picked this as Phase 0 priority #1: fix all 15 confirmed findings from the CLOSED `docs/audits/DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md` two-lens review in `vignettes/articles/engineering-the-2.0.0-release.qmd`, following the audit's own "Recommendations" priority order.
- **Change:** **2 HIGH (factual):** A1 — the `runGeneKeepR()` Phase-9 misattribution was backwards (Phase 9 made `runModularApp()` canonical, deprecating `runGeneKeepR()`; the reversal back to `runGeneKeepR()` canonical was a separate, later commit, issue #110/`1e64dd5d`, Session 276, never mentioned) — rewrote the passage to state both events correctly and cite the reversal. B1 — the "four sessions...wrote Sections 1-3" internal contradiction — reworded to describe four sessions sharing the receipt-gap pattern (three that wrote Sections 1-3 plus the Phase A evidence-freeze session) without misstating who wrote what; kept the correct "three sessions" phrasing elsewhere unchanged. **2 MEDIUM with concrete mechanisms:** A2 — added the three genuine zero-commit months (2026-01/02/03) to `data/commit-activity-timeline.csv` so `fig-commit-pace`'s categorical x-axis now renders the real 3-month gap as visible zero bars (verified visually post-render), plus a prose clause naming it. B10 — hyperlinked all issue-number and commit-sha citations to their GitHub URLs (37 issue links + shas across prose and R-chunk captions; verified every caption-embedded link renders as a real `<a href>` in the rendered HTML, not literal markdown syntax); left the 2 citations embedded inside a `kbl()` table cell string (`tbl-phases`'s `highlight` column, `escape=TRUE` by default) as plain text — hyperlinking there would render as literal brackets, a deliberate, documented scope boundary. **B3 (TDD vocabulary):** added a forward-reference to Section 4/@sec-methodology at first use in the Abstract. **9 LOW, batched as one editorial pass:** B5 (glossed "Phase A data freeze" at first use), B6 (glossed "vertical-slice" at first use), B2 (grammar: "illustrate" → "illustrates"), B4 (dropped the unglossed internal "XARCH-2" codename), B9 (split the self-score/predecessor-score sentence into two), B11 (added a "Risk" column gloss to `tbl-phases`'s caption), B12 (added a bridging sentence to Section 2), B7 (reworded "more honest" → "more accurate," Abstract + subsection heading), B8 (reworded the self-referential "not a stale figure this article repeated uncritically" aside to a plain statement). **A3 (optional, fixed anyway per the "all 15" deliverable):** corrected `data/feature-highlights.csv`'s `0eeee3f6` row date (2026-06-14 → 2026-06-13, zero reader-visible impact — the `date` column isn't rendered in `tbl-features`).
- **Verification:** `quarto render` succeeded clean (23 chunks, 0 errors); visually confirmed the commit-pace chart now shows the 3-month gap; confirmed 0 literal `](http` leaks in the rendered HTML (all markdown links, including caption-embedded ones, rendered as real `<a href>` tags); full `testthat::test_dir()` regression read: 1 failed / 0 error / 0 warning, the sole failure a **pre-existing, unrelated** `test_vignettes_no_deprecated_minParentAge.R` hit (a narrative `minParentAge=` mention in prose describing the now-replaced old default, first flagged by S337, untouched by this session — confirmed via `git diff` showing no change to that line). Corpus swept (`git grep`) for stale echoes of every fixed phrase — none found outside this article and the audit doc's own historical quotes of the findings. Cleaned up render artifacts (`vignettes/articles/engineering-the-2.0.0-release.html`, `_files/`, auto-written `.gitignore`) before staging, per Learning 314.
- **Phase 3E:** n/a — `vignettes/articles/` and its `data/*.csv` only; no `R/`/`tests/` touched, no runtime behavior changed. Removed the now-done "Fix Document 1's 15 confirmed audit findings" item from `BACKLOG.md`.
- **Session:** S343 · **TDD:** N/A (documentation-workstream fix, no `R/`/`tests/` touched).

### 2026-07-09 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit ebeeb9fd — S342 HANDOFFS.md receipt commit-sha backfill
- **Deliverable:** Phase 0 ledger reconcile (this session) found one commit past the `CHANGELOG.md` frontier with no ledger entry: `ebeeb9fd` ("docs: S342 -- backfill own HANDOFFS.md receipt commit sha"), landed after S342's own close-out commit (`86f0def7`) that recorded the entry below.
- **Change:** `ebeeb9fd` replaced the S342 `HANDOFFS.md` receipt's `commit: pending` placeholder with the real commit sha (`86f0def7`) — a self-correction of the just-written receipt, not new production work. Same class of action as the `7c0d680d`/`04c8de1d`/`5f0b81d2`/`ee690776`/`2278b46f`/`cc0f7798` backfills below (S341's, S339's, S334's, S333's, S332's, and S331's equivalent self-fixes).
- **Session:** this session (backfilling S342's own commit) · **Verified:** `git show --stat ebeeb9fd` (single-file, 2-line diff to `HANDOFFS.md`); `git log -1 --format=%H -- HANDOFFS.md` now matches `ebeeb9fd` with no further gap.

### 2026-07-09 · [ad hoc] Closed the Document 1 two-lens review: 13 remaining findings independently verified (Session 342)
- **Deliverable:** Owner picked BACKLOG's priority #1 ("Close out the Document 1 two-lens review") and, via `AskUserQuestion`, confirmed a verify-only scope this session (no article edits; fixes deferred to a follow-on session) — resolving the in-flight decision S341 had flagged as open.
- **Change:** Independently re-verified all 13 remaining findings (Lens A #2/#3, Lens B #2-12) from `docs/audits/DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md` against the current `engineering-the-2.0.0-release.qmd`, via direct `git log`/`git show`/`grep`/CSV re-derivation, not the DRAFT's own agent-authored text: Lens A #2 (commit-pace chart's categorical x-axis hides a real 3-month zero-commit gap, Jan-Mar 2026), Lens A #3 (a 1-day date/commit mismatch in `feature-highlights.csv`, zero reader-visible impact), and Lens B #2-12 (a grammar error; unglossed jargon — "Phase A data freeze" x3, "vertical-slice" x4, "XARCH-2"; only 1 hyperlink against 22 plain-text issue/commit citations; TDD vocabulary used ~500 lines before being explained; and 4 smaller editorial/structural nits) — all 13 confirmed real and still unfixed, 0 downgrades. Rewrote the audit doc's header from DRAFT to CLOSED, added a "Session 342 -- Independent Verification," a severity-ranked "Final Findings Summary" (all 15 findings), and a priority-ordered "Recommendations" section. Caught and fixed a self-contradiction on a full-document re-read: the ORIGINAL Lens A/B section headers still said "not independently re-verified" after the new section asserted full verification — updated those 3 inline labels in place (Learning 316). Updated `BACKLOG.md`: removed the now-done verification item, added a new READY "Fix Document 1's 15 confirmed audit findings" item pointing at the audit doc's own Recommendations.
- **Phase 3E:** n/a — `docs/audits/`, `PROJECT_LEARNINGS.md`, `CLAUDE.md`, `BACKLOG.md` only; the target article itself was not edited this session (owner's explicit verify-only scope decision).
- **Session:** S342 · **Verified:** commit-pace CSV re-derived exactly via `git log --format=%ad --date=format:%Y-%m 4548aa1b..8ca8bb24`; `0eeee3f6`'s date independently checked via `git show`; hyperlink/citation counts via `grep -c`; every finding's location re-anchored to the current 745-line file via `grep -n`, not copied from the DRAFT's own (pre-S340) line numbers.

### 2026-07-09 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit 7c0d680d — S341 HANDOFFS.md receipt commit-sha backfill
- **Deliverable:** Phase 0 ledger reconcile (this session) found one commit past the `CHANGELOG.md` frontier with no ledger entry: `7c0d680d` ("docs: S341 -- backfill own HANDOFFS.md receipt commit sha"), landed after S341's own close-out commit (`f0755ead`) that recorded the entry below.
- **Change:** `7c0d680d` replaced the S341 `HANDOFFS.md` receipt's `commit: pending` placeholder with the real commit sha (`f0755ead`) — a self-correction of the just-written receipt, not new production work. Same class of action as the `04c8de1d`/`5f0b81d2`/`ee690776`/`2278b46f`/`cc0f7798` backfills below (S339's, S334's, S333's, S332's, and S331's equivalent self-fixes).
- **Session:** this session (backfilling S341's own commit) · **Verified:** `git show --stat 7c0d680d` (single-file, 2-line diff to `HANDOFFS.md`); `git log -1 --format=%H -- HANDOFFS.md` now matches `7c0d680d` with no further gap.

### 2026-07-09 · [ad hoc] Backlog curation for Document 1/2 open items + session-startup priorities-list convention (Session 341)
- **Deliverable:** Owner redirected "continue with open items from S339" into "place in the backlog the remaining items from S339 and any other items having to do with producing both documents," then separately asked for session startups to present open work as a clear, easily-selectable interface, with a worked example from a sibling project (`~/Development/wsfct`).
- **Change:** Added `BACKLOG.md` "## Documents (v1.0.8 -> v2.0.0 write-up)" section: (1) close out the Document 1 two-lens review — independently re-confirmed, via direct read of the current article rather than the DRAFT audit's own (now line-stale) text, that Lens A #1 (`runGeneKeepR()` Phase-9 misattribution, now L170-172) and Lens B #1 ("four sessions...wrote Sections 1-3," now L687-688) are still unfixed, and that 13 more findings (Lens A #2/#3, Lens B #2-12) remain unverified; (2) plan "Document 2" (package purpose/how-to-use, deferred since S330, never picked up). Added `CLAUDE.md` "### Additional Phase 0 steps" entry (previously "(none)") documenting a `(READY | BLOCKED | DECISION NEEDED, Effort S|M|L)` tag convention on `BACKLOG.md` items, rendered at Phase 0 step 7 as a numbered, color-marked, tiered "Current priorities" list — a formatting addition to the existing report step, not a change to synced `SESSION_RUNNER.md`. Retrofitted all 6 pre-existing open `BACKLOG.md` items with the tag (CRAN-submission-prep tag checked against this ledger's own S329 entry, not guessed).
- **Phase 3E:** n/a — `BACKLOG.md`/`CLAUDE.md` only, no `R/`/`tests/` touched.
- **Session:** S341 · **Verified:** the 2 confirmed-unfixed findings re-checked against the current article file, not trusted from the DRAFT audit's own stale line numbers; CRAN-prep status checked against this file's own S329 entry.

### 2026-07-09 · [ad hoc] S340 HANDOFFS.md receipt commit-sha backfill, closed same-session
- **Deliverable:** Filled in this session's own `HANDOFFS.md` receipt `commit: pending` placeholder with the real close-out commit sha (`6dde45cd`) — the same self-correction previous sessions (S331-S336, S339) each needed, closed within the same session rather than left for the next session's Phase 0 reconcile to catch and backfill.

### 2026-07-09 · [ad hoc] Correct the Shiny-application-history narrative in Document 1 (Session 340)
- **Deliverable:** Closed out Session 339's interrupted two-lens review of `vignettes/articles/engineering-the-2.0.0-release.qmd` by incorporating the owner-supplied material information it was waiting on: the article's "two coexisting Shiny applications for most of its life" framing was wrong, and the v1.0.8 CRAN-submission story needed explaining.
- **Verified facts (not assumed):** `gh release list` shows no v1.0.8 release ever existed (v1.0.7 is "Latest"); the first commit bumping `DESCRIPTION` to `Version: 1.0.8` is literally titled "1st attempt at adding modules" (`6457a3a3`, 2025-12-29); the first Claude-co-authored commit (`2b225ff8`) is 2026-01-20, three weeks later. Owner then supplied the actual CRAN correspondence: v1.0.8 was submitted 2025-07-25, published within a day, archived by CRAN on 2025-07-29 ("issues were not corrected in time," though the owner found no corresponding problem), discovered by the owner on 2026-01-15, and never resubmitted — development went directly into the modular rewrite instead. `docs/planning/shiny-module-conversion-plan.md:12` (the real migration-planning doc, its own XARCH-1 audit finding) independently confirms the "two coexisting apps" state was genuine — but only in the months immediately before the nine-phase migration, not "for most of its life."
- **Change:** Rewrote the Abstract, added a dated CRAN-archival footnote to the Introduction, rewrote Section 1's opening paragraph, and fixed matching stale phrasing in the Introduction's "Four pillars" summary and the Conclusion — replacing "two independently maintained Shiny applications drifting out of sync" / "long-standing duplicate-implementation problem" with: one working app through v1.0.7, an unfinished hand-built scaffold started in December 2025 (before Claude Code adoption), genuine drift emerging only in the following months, closed by the nine-phase migration. Also softened the issue #27 citation — its body is empty; it only tracked the 2022-era intent to modularize, not a documented friction complaint.
- **Phase 3E:** `quarto render` — 23 chunks, 0 errors; render artifacts (`.html`, `_files/`, `.gitignore`) cleaned before staging (Learning 314).
- **Session:** S340 · **Verified:** full corpus sweep (`grep` for "long-standing"/"two coexisting"/"two independently"/"duplicate-implementation"/"drift"/"coexist") confirmed no other stale echoes remain.

### 2026-07-09 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit 04c8de1d — S339 HANDOFFS.md receipt commit-sha backfill
- **Deliverable:** Phase 0 ledger reconcile (this session) found one commit past the `CHANGELOG.md` frontier with no ledger entry: `04c8de1d` ("docs: S339 -- backfill own HANDOFFS.md receipt commit sha"), landed after S339's own close-out commit (`4c39c522`) that recorded the entry below.
- **Change:** `04c8de1d` replaced the S339 `HANDOFFS.md` receipt's `commit: pending` placeholder with the real commit sha (`4c39c522`) — a self-correction of the just-written receipt, not new production work. Same class of action as the `5f0b81d2`/`ee690776`/`2278b46f`/`cc0f7798` backfills below (S334's, S333's, S332's, and S331's equivalent self-fixes).
- **Session:** this session (backfilling S339's own commit) · **Verified:** `git show --stat 04c8de1d` (single-file, 2-line diff to `HANDOFFS.md`); `git log -1 --format=%H -- HANDOFFS.md` now matches `04c8de1d` with no further gap.

### 2026-07-09 · [ad hoc] Two-lens review of Document 1 — partial, findings preserved as DRAFT (Session 339)
- **Deliverable:** Owner asked to review Document 1 (`vignettes/articles/engineering-the-2.0.0-release.qmd`) and separately noted Document 2 (package purpose/how-to-use, `docs/planning/v2-transformation-article-plan.md`) has never been picked up since S336 named it as a next step. Owner chose to prioritize reviewing Document 1 this session (Document 2 planning remains open). **Session was interrupted by the owner before finishing** — they have material information to add in a future session that will affect the document; report-only scope, no article edits made either way.
- **Change:** Forked two independent review agents matching the S109/S110 precedent — Lens A (figure/table-vs-frozen-data fidelity) and Lens B (editorial/narrative quality). Both completed. Lens A found a HIGH-confidence real discrepancy: the article's own prose misattributes `runGeneKeepR()` becoming canonical to the Phase 9 commit (`3db018d1`), which actually made it the *deprecated* alias — it only became canonical later via an unrelated commit (`1e64dd5d`, issue #110, Session 276) never mentioned in the article — plus two lower-confidence issues. Lens B rated the article 7/10 and found a genuine internal contradiction (line 617 says "three sessions...produced Sections 1-3," line 668-669 says "four sessions...wrote Sections 1-3") plus 11 smaller findings and explicit praise for several strong passages. This session independently re-verified the single most consequential finding from each lens via direct `git` commands (both confirmed, both diagnosed more precisely than the agent's own framing) before the owner's interruption; the remaining 13 findings are agent-reported, not yet independently checked.
- **Preserved, not lost:** all findings written to new `docs/audits/DOCUMENT1_TWO_LENS_REVIEW_2026-07-09.md`, explicitly marked DRAFT — INCOMPLETE, so the ~170K tokens of completed agent work survive the interruption for whichever future session incorporates the owner's new information and finalizes the review.
- **Phase 3E:** n/a — no `R/` package runtime behavior touched, no article edits made.
- **Session:** S339 · **Verified:** both lenses' top findings independently reproduced via `git show`/`git log`; render artifacts a review agent left in `vignettes/articles/` cleaned up before staging (Learning 314).

### 2026-07-09 · [ad hoc] Update stale CI-gap narration in the v2.0.0 article (Session 338)
- **Deliverable:** Fixed the cross-deliverable staleness S337 flagged in its own close-out (`HANDOFFS.md` S337 `next_steps`, `PROJECT_LEARNINGS.md` Learning 313(c)): `vignettes/articles/engineering-the-2.0.0-release.qmd:487-503` (written by S336) narrated the shinytest2.yaml CI-coverage gap as "a real, currently open gap" — true when S336 wrote it, false as of S337's fix (commit `c5ccf69b`). Docs-only prose edit; TDD phases declared N/A per an owner-confirmed PRE-RED scope `AskUserQuestion` (no `R/` or test code touched).
- **Change:** Rewrote the passage to state the gap existed from 2026-06-11 (Phase 8e-7's close) through 2026-07-08, then was closed by Session 337 (2026-07-09) — citing the new regression test (`tests/testthat/test_shinytest2_workflow_coverage.R`), the two added CI groups, the count-free/dynamically-computed workflow comment, and the confirming live `workflow_dispatch` run (29057393786, all 15 groups green). Corpus-swept for other stale references to the old "23 files / 13 groups / 24 of 26 covered" figures (`grep` across `.qmd`/`.Rmd`/`.md`) — the only other hits were in ledger/process files (`CHANGELOG.md`, `HANDOFFS.md`, `SESSION_NOTES.md`, `PROJECT_LEARNINGS.md`, dated planning docs) that correctly narrate history as of the date each was written; none needed changing.
- **Build-equivalent verification:** `quarto render vignettes/articles/engineering-the-2.0.0-release.qmd` — 23 chunks, zero errors. Discovered and recorded as new `PROJECT_LEARNINGS.md` Learning 314: the render produced untracked `.html`/`_files/`/`.gitignore` artifacts in `vignettes/articles/` that the top-level `.gitignore`'s single-level `vignettes/*.html` pattern does not cover (confirmed via `git log --all` that no prior session ever committed such artifacts for any sibling article); manually removed before staging.
- **Learnings:** New `PROJECT_LEARNINGS.md` Learning 314 (quarto-render-leaves-untracked-artifacts-one-level-down gotcha). Updated `CLAUDE.md`'s `PROJECT_LEARNINGS.md` pointer (313 → 314 learnings, Sessions 1-337+ → 1-338+).
- **Phase 3E:** N/A — docs-only prose change, no package runtime behavior touched. Build-equivalent (`quarto render`) is this deliverable's actual verification, stated explicitly per FM #24 rather than silently treated as a runtime smoke test.
- **Session:** S338 · **Verified:** `quarto render` clean (0 errors); `git diff` reviewed line-by-line before commit; render artifacts cleaned from working tree.

### 2026-07-09 · [ad hoc] Fix CI coverage gap in shinytest2.yaml — 2 orphaned E2E test files now run (Session 337)
- **Deliverable:** Fixed the CI-coverage gap flagged by S336/`PROJECT_LEARNINGS.md` Learning 312: `.github/workflows/shinytest2.yaml`'s 13 hardcoded per-module regex groups covered only 24 of the 26 tracked `test-{app,e2e}-*.R` files, so `test-e2e-orip-module.R` (Session 86, issues #47/#49) and `test-e2e-potential-parents-module.R` (Session 82, issue #48) silently never ran in the nightly/manual-dispatch opt-in E2E job. Strict TDD: a PRE-RED scope `AskUserQuestion` plus all three phase gates (RED, GREEN, REFACTOR), each via `AskUserQuestion`; 0 stakeholder corrections (recommended option chosen every time).
- **Change:** **RED —** re-verified the gap firsthand (`git ls-tree` + hand-checked all 13 regexes against all 26 stripped filenames, exactly reproducing S336's finding), then wrote `tests/testthat/test_shinytest2_workflow_coverage.R`, a fast unit-tier test that parses the workflow's `groups=(...)` bash array out of the YAML text and asserts — using the same `grepl`-after-stripping-`test-`/`.R` transform `testthat::test_dir(filter=)` itself applies — that every tracked file matches exactly one group (checks both gap and overlap). Confirmed it failed, naming both orphaned files with no false positives. **GREEN —** added two new single-file groups (`^e2e-orip-module`, `^e2e-potential-parents-module`) to `shinytest2.yaml`, matching the existing single-file group style; re-ran the coverage test (passed) and the full clean regression read (only one pre-existing, unrelated failure remained — a deprecated `minParentAge=` reference in `articles/engineering-the-2.0.0-release.qmd:311` from S336's article work, independently confirmed pre-existing via a `git stash` A/B of just this session's two changed files). **REFACTOR —** caught that GREEN's own comment/message updates ("23"→"26", "13"→"15") reintroduced the exact hardcoded-count staleness class this fix was closing; removed all hardcoded file/group counts from prose (workflow comments and the new test's own header comment) and converted the runtime `echo "All 15 E2E module groups passed."` into a dynamically computed `echo "All ${#groups[@]} E2E module groups passed."` so it can never drift again structurally. Verified: `bash -n` syntax-checked the extracted `run:` block, `lintr` on the new test file (0 lints), full regression read identical before/after refactor.
- **Flagged, not fixed (scope discipline):** closing this gap makes `vignettes/articles/engineering-the-2.0.0-release.qmd:487-503` stale — it explicitly narrates the gap as "a real, currently open gap, not a stale figure this article repeats uncritically," which was true when S336 wrote it and is false as of this commit. Editing the article is a separate documentation-workstream deliverable; flagged here and in the session handoff for a future session, mirroring how S336 itself flagged the original gap without fixing the workflow.
- **Phase 3E:** local static verification performed (YAML parses, bash syntax valid, coverage test passes, dynamic count sanity-checked). **Owner approved a live confirmation**: `gh workflow run shinytest2.yaml --ref master` dispatched run [29057393786](https://github.com/rmsharp/nprcgenekeepr/actions/runs/29057393786), completed **success** in 18m56s — all 15 per-module groups green, including the 2 new ones.
- **Learnings:** New `PROJECT_LEARNINGS.md` Learning 313 (fixing a stale count by writing a new count is the same defect with a later expiration date; extends Learning #7/#10's cross-reference-staleness trigger to sessions that resolve a previously-documented-as-open defect). Updated `CLAUDE.md`'s `PROJECT_LEARNINGS.md` pointer (312 → 313 learnings, Sessions 1-336+ → 1-337+).
- **Session:** S337 · **Verified:** `Rscript -e 'testthat::test_file("tests/testthat/test_shinytest2_workflow_coverage.R")'` passes; full `testthat::test_dir()` clean-regression read shows the same single pre-existing unrelated failure as baseline `HEAD`.

### 2026-07-09 · [ad hoc] S336 HANDOFFS.md receipt commit-sha backfill, closed same-session
- **Deliverable:** Filled in this session's own `HANDOFFS.md` receipt `commit: pending` placeholder with the real close-out commit sha (`bca11e5d`) — the same self-correction the previous five sessions (S331-S335) each needed, closed within the same session rather than left for the next session's Phase 0 reconcile to catch and backfill.
- **Change:** A session cannot know its own close-out commit's sha before making that commit, so the receipt is necessarily written with a placeholder first. This entry and the `HANDOFFS.md` edit it describes land in one follow-up commit, immediately after the close-out commit, closing the gap in-session.
- **Session:** S336 · **Verified:** `git log -1 --format=%H -- HANDOFFS.md` will match this commit with no further gap once committed.

### 2026-07-09 · [ad hoc] Phase F of the Document-1 article plan: Abstract/Introduction/Conclusion, full claim audit, full verification chain (Session 336) — plan now fully executed
- **Deliverable:** Phase F (the publish gate) of `docs/planning/v2-transformation-article-plan.md` — drafted the Abstract (200 words), Introduction, and Conclusion (NIH grant acknowledgment, verbatim match to `CLAUDE.md`/`DESCRIPTION`) in `vignettes/articles/engineering-the-2.0.0-release.qmd`; ran the full-document claim-source audit (workstream Phase 6) across all 8 sections; ran the complete verification chain. **Documentation/article-drafting session for `vignettes/articles/` support — no `R/`/`tests/` package code touched. TDD phase: N/A** (matches S107-S110/S330-S335 precedent; declared every response). 2 `AskUserQuestion` gates at kickoff (Section 5: cut, recommended; F6 screenshot reuse: skip, recommended — both owner-confirmed). 0 stakeholder corrections.
- **Change:** Forked two parallel adversarial claim-audit passes (4 sections each) that independently re-derived every numeric/dated/sha claim from `git`/`gh`/`grep` rather than trusting the plan's own Claim-Evidence Map summary column; ~55 distinct claims checked, all 4 reported mismatches independently re-verified firsthand before any edit. **Four real defects found and fixed:** (1) Section 1 misattributed the `inst/application/` monolith deletion to `3db018d1` (that's Phase 9 Part 1/3, the `runGeneKeepR()` alias commit — the actual deletion, and the source of the article's "single `git revert`" reversibility claim, is `24992e0b`, Part 2/3, a same-timestamp sibling commit); (2) Section 2 overclaimed issue #34's hygiene-close gap as "years later" (`gh issue view`: 2026-01-20 → 2026-06-12, about five months); (3) Section 4 overcounted "all four sessions that produced Sections 1-3" (the article file's own commit history shows exactly three: S332/S333/S334); (4) Section 3's CI-coverage claim ("the 23-file tier... no gap") was accurate when Phase 8e-7 closed (2026-06-11) but had gone stale — two E2E test files added by later, unrelated sessions (`test-e2e-potential-parents-module.R`, S82, issue #48; `test-e2e-orip-module.R`, S86, issues #47/#49 — covering exactly the two new Shiny tabs Section 2 describes) never matched any of the workflow's 13 hardcoded CI group regexes. Rewrote the passage to state the current, independently-verified figures (26 files in the opt-in tier, 24 covered, 2 never executed in CI) instead of repeating the workflow file's own stale header comment. **This surfaces a real, currently-open CI gap in `.github/workflows/shinytest2.yaml`** — flagged for a future, separately-scoped TDD session (fixing CI config is a different capability, out of scope for a documentation-only session); not fixed here. Full verification chain: `quarto render` (zero unresolved refs, Tables 1-5/Figures 1-5 all resolved sequentially) → `pkgdown::build_article("articles/engineering-the-2.0.0-release")` (clean) → `R CMD build .` + `tar tzf` (confirmed `vignettes/articles/` and its `data/` subfolder absent from the shipping tarball — zero CRAN risk). Spot-check of pre-existing articles found the plan's own §1/§10 inventory stale too — **six** `vignettes/articles/*.qmd` exist, not four (`fg-se-validation.qmd`, `offline-focal-animal-workflow.qmd` were added by later, unrelated sessions after the plan was written) — rendered all six as the more thorough superset, all clean. Marked Phase F `DONE` in the plan's §7 and ticked all ten §10 Verification Checklist items with evidence; resolved all four §12 open owner decisions in place. **The plan is now fully executed, Phase A through Phase F.**
- **Also:** Added `PROJECT_LEARNINGS.md` Learning 312 — a full-document, post-hoc claim audit is a structurally different check than N per-section audits: only it re-verifies EARLIER sections' claims against CURRENT state, catching drift a per-section drafting-time review has no way to see (the CI-gap defect above is the concrete example — true when Section 3 was written, false by the time Phase F ran, purely from unrelated later sessions' changes elsewhere in the repo). Updated `CLAUDE.md`'s learning-count pointer (311 → 312 learnings, Sessions 1–335+ → 1–336+).
- **Session:** S336 · **Verified:** `quarto render` + `pkgdown::build_article()` + `R CMD build .`/`tar tzf` + all six pre-existing articles re-rendered, all firsthand; every claim-audit finding independently re-derived via direct `git log -1`/`git show --stat`/`gh issue view`/`git ls-tree` commands before editing the article, not taken from the fork reports alone.

### 2026-07-09 · [ad hoc] S335 HANDOFFS.md receipt commit-sha backfill, closed same-session
- **Deliverable:** Filled in this session's own `HANDOFFS.md` receipt `commit: pending` placeholder with the real close-out commit sha (`33f943e0`) — the same self-correction the previous four sessions (S331-S334) each needed, but closed within the same session this time rather than left for the next session's Phase 0 reconcile to catch and backfill.
- **Change:** A session cannot know its own close-out commit's sha before making that commit, so the receipt is necessarily written with a placeholder first. This entry and the `HANDOFFS.md` edit it describes land in one follow-up commit, immediately after the close-out commit, closing the gap in-session instead of leaving a `commit: pending` marker for `SESSION_RUNNER.md` Phase 0's reconcile-on-read to find next time.
- **Session:** S335 · **Verified:** `git log -1 --format=%H -- HANDOFFS.md` will match this commit with no further gap once committed.

### 2026-07-09 · [ad hoc] Phase E of the Document-1 article plan: drafted Section 4 (AI-assisted development process) + T6/F4/F5 (Session 335)
- **Deliverable:** Phase E of `docs/planning/v2-transformation-article-plan.md` — drafted Section 4 ("An AI-Assisted Development Process") of `vignettes/articles/engineering-the-2.0.0-release.qmd` plus table T6 (engineering-process metrics) and figures F4 (TDD phase-gate Mermaid diagram) and F5 (self-score trend chart), reading Session 331's frozen `vignettes/articles/data/process-metrics.csv` and `data/self-score-trend.csv` unchanged. **Documentation/article-drafting session for `vignettes/articles/` support; TDD N/A** — no `R/`/`tests/` package code touched. 0 `AskUserQuestion` gates (direct continuation of an already-ratified plan phase, the highest-scrutiny one per the plan's own dragon #2). 0 stakeholder corrections.
- **Change:** T6 presents 9 frozen metrics (328 sessions in range, 512 total commits, 309 CHANGELOG entries, 305 PROJECT_LEARNINGS entries, 7 complete HANDOFFS receipts, 269/2 stakeholder-correction mention split). Both T6 and F5 carry an explicit "Phase A data freeze (Session 331)" caption stating the source files are live and had already grown past the frozen snapshot by this session — verified firsthand, not assumed: live `CHANGELOG.md` is 317 entries and live `PROJECT_LEARNINGS.md` is 310, vs. the frozen 309/305. F5 (`ggplot2` line chart) reorders the frozen CSV's rows by session number — the raw file's date-only sort left same-day sessions in reverse-numeric order, a stable-sort artifact — without mutating the frozen file, and flags that Sessions 329-330 postdate the range's own end commit (`8ca8bb24`) despite sharing its calendar date (verified via `git log` timestamps). F4 (Mermaid `stateDiagram-v2`) diagrams the RED→GREEN→REFACTOR cycle annotated with the `AskUserQuestion` phase-gate mechanism from `CLAUDE.md`'s Development Process Contract. Independently re-verified 3 claim-map facts rather than trusting the plan's summary table alone: `SESSION_RUNNER.md`'s failure-mode table has exactly 27 rows, Session 324 is genuinely the earliest complete `HANDOFFS.md` receipt, and the Session-325 CHANGELOG ledger-format-resolution date. Cited the 4-consecutive-session commit-sha-backfill self-correction pattern (`cc0f7798`/`2278b46f`/`ee690776`/`5f0b81d2`) as concrete, already-real evidence of the ledger mechanism working, rather than a hypothetical claim. Marked Phase E `DONE` in the plan's §7. Verified via `quarto render`: `@tbl-process-metrics`/`@fig-tdd-cycle`/`@fig-self-score-trend` resolved as "Table 5"/"Figure 4"/"Figure 5", zero unresolved-ref hits, full-document numbering sequential (Tables 1-5, Figures 1-5). **F4's first version had a real defect `quarto render`'s exit code could not catch:** a `\n` inside Mermaid transition labels (wrongly modeled on F2's flowchart `<br/>` syntax) rendered as a literal backslash-n, not a line break — `quarto render` never itself parses embedded Mermaid source (ships to the reader's browser for client-side rendering). Caught by statically rendering the extracted `.mmd` via `npx -y @mermaid-js/mermaid-cli` and inspecting the actual PNG (`rsvg-convert` was tried first and rejected — it doesn't support Mermaid's `foreignObject` label elements and rendered a worse, misleading false defect); fixed by keeping each transition label on one physical line, re-verified via `mermaid-cli`, then re-rendered the full article to confirm.
- **Also:** Added `PROJECT_LEARNINGS.md` Learning 311 — `quarto render` succeeding on a `.qmd` with a native Mermaid diagram proves nothing about whether the embedded Mermaid syntax parses; it ships raw to the reader's browser for client-side rendering. Verify any new Mermaid diagram type by statically rendering it with `mermaid-cli` and inspecting the actual image before trusting a green `quarto render`, and don't substitute `rsvg-convert` for that check (no `foreignObject` support). Updated `CLAUDE.md`'s learning-count pointer (310 → 311 learnings, Sessions 1–334+ → 1–335+).
- **Session:** S335 · **Verified:** `quarto render` output HTML inspected directly for resolved cross-references and correct table/figure numbering; a standalone `mermaid-cli` PNG render caught and confirmed the fix for a real Mermaid label-escaping defect before it reached the committed article; render artifacts cleaned up before staging; direct greps/`git log` checks (not the plan's summary table alone) for the FM-27 count, the Session-324 receipt start, and the live-vs-frozen CHANGELOG/PROJECT_LEARNINGS drift.

### 2026-07-09 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit 5f0b81d2 — S334 HANDOFFS.md receipt commit-sha backfill
- **Deliverable:** Phase 0 ledger reconcile (this session) found one commit past the `CHANGELOG.md` frontier with no ledger entry: `5f0b81d2` ("docs: S334 -- backfill own HANDOFFS.md receipt commit sha"), landed after S334's own close-out commit (`735a3f2a`) that recorded the entry below.
- **Change:** `5f0b81d2` replaced the S334 `HANDOFFS.md` receipt's `commit: pending` placeholder with the real commit sha (`735a3f2a`) — a self-correction of the just-written receipt, not new production work. Same class of action as the `62339088`/`2278b46f`/`cc0f7798` backfills below (S333's, S332's, and S331's equivalent self-fixes).
- **Session:** this session (backfilling S334's own commit) · **Verified:** `git show --stat 5f0b81d2` (single-file, 2-line diff to `HANDOFFS.md`); `git log -1 --format=%H -- HANDOFFS.md` now matches `5f0b81d2` with no further gap.

### 2026-07-09 · [ad hoc] Phase D of the Document-1 article plan: drafted Section 3 (testing at scale) + T5/F3 (Session 334)
- **Deliverable:** Phase D of `docs/planning/v2-transformation-article-plan.md` — drafted Section 3 ("Testing at Scale") of `vignettes/articles/engineering-the-2.0.0-release.qmd` plus table T5 (test-suite growth) and figure F3 (growth chart), reading Session 331's frozen `vignettes/articles/data/testing-growth.csv` unchanged. **Documentation/article-drafting session for `vignettes/articles/` support; TDD N/A** — no `R/`/`tests/` package code touched. 0 `AskUserQuestion` gates (direct continuation of an already-ratified plan phase). 0 stakeholder corrections.
- **Change:** T5/F3 present the 5 frozen checkpoints (132→257 `.R` files under `tests/testthat/`, 0→32 shinytest2/AppDriver-referencing, v1.0.8-CRAN to v2.0.0-CRAN). Cross-checked both endpoint rows against `git ls-tree` at the exact commits (`4548aa1b`/`8ca8bb24`) — exact match, but the check surfaced that the CSV's `test_file_count` column counts every `.R` file under `tests/testthat/` (test files plus 4 helper/setup files), not just `test*.R`-named files; traced to the extraction script's own line of code (`build-document1-evidence.R:121`) rather than guessed, and the table/prose state precisely what's counted. Drafted a second subsection narrating the shinytest2 E2E harness's full arc: built-but-undefined-helpers (module branch, pre-Session-1) → executable via the 4-session 8a-8d sub-plan (Session 31-34, issue #39, closed 2026-06-06) → hardened via the 7-slice 8e-1..8e-7 pass (Session 37-50, issue #40, closed 2026-06-11) that replaced 41 `expect_true(TRUE)` tautologies, fixed a wrong-tab-navigation defect, wired 3 real data-bearing flows (pedigree/GVA/breeding), and defanged a CI process-count flake via 13 per-module fresh-process groups. Verified via `gh issue view` + `CHANGELOG.md` session headers that **both #39 and #40 are CLOSED**, correcting the plan's own §7 Phase D hedge ("may still show open items") and confirming `BACKLOG.md`'s "#40 open" line is stale (flagged, not fixed — scope discipline). Marked Phase D `DONE` in the plan's §7, explicitly noting T5's "(if extractable) coverage" hedge was not populated (no coverage data in the frozen CSV; no new extraction attempted, per the Reproducibility Decision). Verified via `quarto render`: `@tbl-testing-growth` resolved as "Table 4", `@fig-testing-growth` resolved as "Figure 3", zero unresolved-ref hits. The first render caught a real defect — F3's top data label clipped by the default y-axis range — fixed with `ggplot2::scale_y_continuous(expand = ...)` and re-verified by re-rendering and inspecting the output PNG directly.
- **Also:** Added `PROJECT_LEARNINGS.md` Learning 310 — a frozen extraction CSV's column name is not evidence of what its value counts; read the extraction script's own computation before writing prose/captions around a frozen number, especially when an independent re-derivation disagrees (a sibling to Learning 309's closedAt-date trap, same "go to the actual computation, not the label" shape). Updated `CLAUDE.md`'s learning-count pointer (309 → 310 learnings, Sessions 1–333+ → 1–334+).
- **Session:** S334 · **Verified:** `quarto render` output HTML + PNG inspected directly for resolved cross-references, correct row/label data, and a fixed rendering defect; render artifacts cleaned up before staging; `gh issue view 39`/`40` + `CHANGELOG.md` session-header greps for harness-status sourcing.

### 2026-07-09 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit ee690776 — S333 HANDOFFS.md receipt commit-sha backfill
- **Deliverable:** Phase 0 ledger reconcile (this session) found one commit past the `CHANGELOG.md` frontier with no ledger entry: `ee690776` ("docs: S333 -- backfill own HANDOFFS.md receipt commit sha"), landed after S333's own close-out commit (`a01e13ce`) that recorded the entry below.
- **Change:** `ee690776` replaced the S333 `HANDOFFS.md` receipt's `commit: pending` placeholder with the real commit sha (`a01e13ce`) and expanded `what_was_done` to list the full commit set — a self-correction of the just-written receipt, not new production work. Same class of action as the `2278b46f`/`cc0f7798` backfills below (S332's and S331's equivalent self-fixes).
- **Session:** this session (backfilling S333's own commit) · **Verified:** `git show --stat ee690776` (single-file, 4-line diff to `HANDOFFS.md`); `git log -1 --format=%H -- HANDOFFS.md` now matches `ee690776` with no further gap.

### 2026-07-09 · [ad hoc] Phase C of the Document-1 article plan: drafted Section 2 (new features) + T4 (Session 333)
- **Deliverable:** Phase C of `docs/planning/v2-transformation-article-plan.md` — drafted Section 2 ("New Capabilities in 2.0.0") of `vignettes/articles/engineering-the-2.0.0-release.qmd` plus table T4 (new-features summary), hand-curating from Session 331's frozen `vignettes/articles/data/feature-candidates.csv` (47 raw closed-issue candidates). **Documentation/article-drafting session for `vignettes/articles/` support; TDD N/A** — no `R/`/`tests/` package code touched. 0 `AskUserQuestion` gates (direct continuation of an already-ratified plan phase). 0 stakeholder corrections.
- **Change:** Curated the 47 raw candidates down to **13 (28%)** genuinely feature-shaped items, excluding bug fixes, internal process/tooling closes, and — the real trap — issue-hygiene closes of functionality that predates the range (issue #34's own CHANGELOG entry states "No code changed"; the real implementation, commit `7da01afe`, predates the range). Wrote a new frozen data file, `vignettes/articles/data/feature-highlights.csv` (13 rows: feature, issue, session range, date, commit sha where applicable, description), matching T2/T3's read-a-frozen-CSV-via-`kableExtra` generation pattern. Added Section 2 with three prose clusters: parent identification/species-awareness (5 features: #31/#48/#46/#73/#119), Genetic Value Analysis uncertainty (4 features: #9/#76/#82/#118), and new dashboards/module activations (#112, #47/#49) plus 2 smaller fixes (#35, #44). Fulfilled Section 1's own forward-reference to `modGeneticDiversity`/`modPotentialParents`, and correctly distinguished `modORIPReporting`'s pre-existing code (Section 1's migration) from its in-this-section activation. Marked Phase C `✅ DONE` in the plan's §7. Verified via `quarto render`: `@tbl-features` resolved as "Table 3" with zero unresolved-ref hits, all 13 rows present in output. Verified the 3 single-commit citations (`0eeee3f6`, `d4320643`, `14c8e84d`) both resolve (`git log -1`) and are ancestors of `HEAD` (`git merge-base --is-ancestor`).
- **Also:** Added `PROJECT_LEARNINGS.md` Learning 309 — a closed GitHub issue's `closedAt` date is not evidence the underlying functionality was built in that range; issue-hygiene closes of pre-existing behavior look identical to genuine in-range features in a raw closed-issue extraction, so each candidate's actual CHANGELOG entry must be read before curating it in. Updated `CLAUDE.md`'s learning-count pointer (308 → 309 learnings, Sessions 1–332+ → 1–333+). Corrected an in-progress handoff-drafting error before commit: an initial gotcha claiming issue #40 was "OPEN" was wrong — `gh issue view 40` shows CLOSED (2026-06-11) — and also surfaced (not fixed, to avoid scope creep) that `BACKLOG.md`'s "Up Next" section is stale on that same issue.
- **Session:** S333 · **Verified:** `quarto render` output HTML inspected directly for resolved cross-references and correct row count; render artifacts cleaned up before staging; commit-ancestry checks (`git merge-base --is-ancestor`) on all 3 single-commit citations.

### 2026-07-09 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit 2278b46f — S332 HANDOFFS.md receipt commit-sha backfill
- **Deliverable:** Phase 0 ledger reconcile (Session 333) found one commit past the `CHANGELOG.md` frontier with no ledger entry: `2278b46f` ("docs: S332 -- backfill own HANDOFFS.md receipt commit shas"), landed after S332's own close-out commit (`b051c883`) that recorded the entry below.
- **Change:** `2278b46f` replaced the S332 `HANDOFFS.md` receipt's `commit: pending` placeholder with the real commit sha (`b051c883`) and expanded `what_was_done` to list all 6 commits — a self-correction of the just-written receipt, not new production work. Same class of action as the `cc0f7798` backfill below (S331's equivalent self-fix).
- **Session:** S333 (backfilling S332's own commit) · **Verified:** `git show --stat 2278b46f` (single-file, 2-line diff to `HANDOFFS.md`); `git log -1 --format=%H -- HANDOFFS.md` now matches `2278b46f` with no further gap.

### 2026-07-09 · [ad hoc] Phase B of the Document-1 article plan: drafted Section 1 (Shiny modules) + T2/T3/F1/F2 (Session 332)
- **Deliverable:** Phase B of `docs/planning/v2-transformation-article-plan.md` — drafted Section 1 ("From Monolith to Modules: the Shiny Architecture Transformation") plus tables T2 (module inventory) and T3 (nine-phase migration summary) and figures F1 (commit-activity timeline) and F2 (before/after architecture diagram), reading from Session 331's frozen `vignettes/articles/data/*.csv` files. **Documentation/article-drafting session for `vignettes/articles/` support; TDD N/A** — no `R/`/`tests/` package code touched. 1 `AskUserQuestion` gate (title/slug confirmation, the plan's own flagged Phase-B-kickoff decision). 0 stakeholder corrections.
- **Change:** Wrote `vignettes/articles/engineering-the-2.0.0-release.qmd`. T2 reads `data/module-inventory.csv` via `kableExtra::kbl()`; prose flags that 2 of the 10 current modules (`modGeneticDiversity`, `modPotentialParents`) postdate the migration and belong to a later section. T3 reads `data/migration-phases.csv` plus hand-authored highlights sourced from `shiny-module-conversion-plan.md` §9, stating explicitly that Phases 3–7 have no quoted commit sha and that Phase 8 was a compound, multi-session DONE. F1 (`ggplot2`) reads `data/commit-activity-timeline.csv`. F2 is a native Quarto Mermaid before/after diagram, no new package dependency. Marked Phase B `✅ DONE` in the plan's §7 and updated its header status line. Verified via `quarto render`: both `@fig-*`/`@tbl-*` cross-references resolved in the rendered HTML (zero unresolved-ref hits) and the Mermaid runtime assets were correctly wired into the output — not just a zero exit code. Re-verified three "current state" claims live rather than trusting older sources: `4,731` total lines (`wc -l` across `R/mod*.R`/`appUI.R`/`appServer.R`, matching the frozen C1 value exactly), all 10 modules presently mounted in `R/appUI.R`/`R/appServer.R` (correcting a stale "only 6 mounted" snapshot in the Session-21-era planning doc), and the "17 files" `inst/application/` deletion count (cross-checked against `CHANGELOG.md`'s own Phase-9 close-out entry).
- **Also:** Added `PROJECT_LEARNINGS.md` Learning 308 — `quarto render` inside `vignettes/articles/` leaves generated `.html`/`_files/` output (and can auto-create a `.gitignore` covering only `.quarto/`) that the top-level `.gitignore`'s single-level `vignettes/*.html` glob does not catch; render artifacts must be deleted by hand before staging. Updated `CLAUDE.md`'s learning-count pointer (307 → 308 learnings, Sessions 1–331+ → 1–332+).
- **Session:** S332 · **Verified:** `quarto render` output HTML inspected directly for resolved cross-references and correctly-wired Mermaid assets; render artifacts cleaned up before staging (`git status --porcelain vignettes/` confirmed clean except the new `.qmd`).

### 2026-07-09 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit cc0f7798 — S331 HANDOFFS.md receipt commit-sha backfill
- **Deliverable:** Phase 0 ledger reconcile (Session 332) found one commit past the `CHANGELOG.md` frontier with no ledger entry: `cc0f7798` ("docs: S331 -- backfill own HANDOFFS.md receipt commit shas"), landed after S331's own close-out commit (`046b62d5`) that recorded the entry above.
- **Change:** `cc0f7798` replaced the S331 `HANDOFFS.md` receipt's `commit: pending` placeholder with the 5 real commit shas for that session's work, and expanded `what_was_done` to list them — a self-correction of the just-written receipt, not new production work.
- **Session:** S332 (backfilling S331's own commit) · **Verified:** `git show --stat cc0f7798` (single-file, 2-line diff to `HANDOFFS.md`); `git log -1 --format=%H -- HANDOFFS.md` now matches `cc0f7798` with no further gap.

### 2026-07-09 · [ad hoc] Phase A of the Document-1 article plan: froze the evidence base (Session 331)
- **Deliverable:** Phase A of `docs/planning/v2-transformation-article-plan.md` — built and froze the evidence-base data files + extraction script for Document 1 (the v1.0.8 → v2.0.0 technical writeup), and completed the plan's §3 Claim-Evidence Map. **Data-extraction/tooling session for `vignettes/articles/` support; TDD N/A** — no `R/`/`tests/` package code touched. 2 `AskUserQuestion` gates (path choice + commit-range-framing ratification, both the owner's call). 0 stakeholder corrections.
- **Change:** Wrote `vignettes/articles/data-raw/build-document1-evidence.R` (checked-in, reproducible — shells out to `git`/`gh`, parses `CHANGELOG.md`/`PROJECT_LEARNINGS.md`/`HANDOFFS.md`/`SESSION_NOTES.md`), producing 7 frozen CSVs under `vignettes/articles/data/`: `module-inventory.csv`, `migration-phases.csv`, `feature-candidates.csv` (47 closed-issue raw candidates), `testing-growth.csv`, `commit-activity-timeline.csv`, `process-metrics.csv`, `self-score-trend.csv`. Completed the plan's §3 Claim-Evidence Map (14 dated/sha-anchored rows) and marked Phase A `✅ DONE` in §7. Spot-checked 12 extracted numbers by hand against raw sources — all 12 confirmed exactly.
- **Also:** Corrected two inaccuracies in S330's plan draft with hard evidence: (1) resolved the plan's §2 first-session-number gotcha — the true Session 1 begins at commit `6fd87749` (2026-05-30), inside the ratified range, not predating v1.0.8 as S330 had hedged; 328 numbered sessions (Session 1 → S328) fall within the range. (2) Corrected "Phases 1-9 all marked DONE" — Phase 8 of `shiny-module-conversion-plan.md` expanded into a 4-session subplan (8a-8d, issue #39) then a 7-part hardening pass (8e-1..8e-7, issue #40, Session 37-50), visible only in the phase's body text and `CHANGELOG.md`. Added `PROJECT_LEARNINGS.md` Learnings 306 (grep both session-tag conventions when establishing a boundary) and 307 (a migration plan's phase-header DONE tags aren't a reliable completion signal alone). Updated `CLAUDE.md`'s learning-count pointer (305 → 307 learnings).
- **Session:** S331 · **Verified:** extraction script re-run twice after catching two real bugs (inspected actual CSV output, not assumed correct); 12 numbers hand-spot-checked against raw `git log`/`CHANGELOG.md`/`PROJECT_LEARNINGS.md`/`HANDOFFS.md`, 0 discrepancies.

### 2026-07-09 · [ad hoc] Wrote the Document-1 (v1.0.8->2.0.0 technical writeup) planning doc (Session 330)
- **Deliverable:** Planning session for "Document 1" — a public Quarto pkgdown article describing the v1.0.8 → v2.0.0 transformation (Shiny modules, new features, testing, extensive Claude CLI use), per the owner's instruction to produce two documents (Document 2 — package purpose/usage — is explicitly deferred to its own future planning session). **Planning session; TDD N/A** — no `R/`/`tests/` touched. 1 `AskUserQuestion` gate (public vs. internal visibility — the one parameter not derivable from the repo). 0 stakeholder corrections.
- **Change:** Wrote `docs/planning/v2-transformation-article-plan.md` (352 lines), adapting `RESEARCH_DOCUMENTATION_WORKSTREAM.md`'s claim-source/figure-provenance discipline to this repo's own evidence (git log, `CHANGELOG.md`, `PROJECT_LEARNINGS.md`, `HANDOFFS.md`) instead of external citations. Verified the exact commit-range boundary via `CRAN-SUBMISSION`'s own git history (`4548aa1b`..`8ca8bb24`, 512 non-merge commits) rather than accepting the owner's "1.0.8 to 2.0.0" phrasing loosely. Read `docs/planning/shiny-module-conversion-plan.md` in full (primary source for the article's Shiny-modules section) and discovered the already-owner-adopted Quarto/pkgdown-articles policy (Session 105) before asking a format question, resolving it as settled. Owner confirmed (`AskUserQuestion`): Document 1 will be a **public** pkgdown article, not internal-only — flagged as the plan's highest-scrutiny section (the Claude-CLI/methodology content). Proposed 7 tables + 6 figures (each with purpose/data-source/generation-method/provenance), a 6-phase (A–F) session breakdown with per-phase completion criteria, 4 named dragons, and an adapted verification checklist.
- **Also:** Added `PROJECT_LEARNINGS.md` Learning 305 — (a) mine `docs/planning/` for an already-decided policy before framing a format/toolchain question as open; (b) `CHANGELOG.md`'s own format-template line pollutes a naive `grep -c "^### "` entry count by exactly 1. Updated `CLAUDE.md`'s learning-count pointer (302 → 305 learnings, ~1.35MB → ~1.4MB).
- **Session:** S330 · **Verified:** commit-range boundary confirmed via `git log`/`CRAN-SUBMISSION` history, not accepted from phrasing; format policy confirmed by reading the Session 105 decision doc, not assumed.

### 2026-07-09 · [ad hoc] CRAN 2.0.0 submitted to CRAN submission team (Session 329)
- **Deliverable:** Recorded the CRAN 2.0.0 submission milestone. **Documentation of an owner-taken milestone; TDD N/A** — no `R/`/`tests/` touched; `CRAN-SUBMISSION` was auto-written by `devtools`, not hand-edited. 0 `AskUserQuestion` gates. 0 stakeholder corrections.
- **Change:** The owner ran `devtools::submit_cran()`; the upload succeeded. Verified firsthand via `git diff CRAN-SUBMISSION` (not just the owner's report alone): `Version: 1.0.8` / `2025-07-26` → `Version: 2.0.0` / `2026-07-09 17:57:22 UTC` / `SHA: 8ca8bb24551a6a95dc4468d8ef5218bd3d3c91e0` — the exact commit submitted, matching `origin/master`'s HEAD at submission time. Committed the updated `CRAN-SUBMISSION` (a legitimate artifact `usethis::use_github_release()` will later consume and delete in Phase 6). Updated `docs/planning/cran-2.0.0-submission-plan.md`'s Phase 5 status block (new "SUBMITTED" note with the version/date/SHA evidence) and the §9 table's Phase 5b row (marked partial-complete — submitted, CRAN's review outcome still pending).
- **Also:** Added `PROJECT_LEARNINGS.md` Learning 304 — four consecutive sessions (S326–S329) each discovered a file needing attention only after starting the Phase 1B claim, not before; write the claim stub the moment a task is understood, before any exploratory read.
- **Session:** S329 · **Verified:** `git diff CRAN-SUBMISSION` (machine-written evidence, not a verbal report taken at face value).

### 2026-07-09 · [ad hoc] Fold Phase 5b cross-platform results into cran-comments.md, all clean (Session 328)
- **Deliverable:** Completed Phase 5b's cross-platform checks and populated `cran-comments.md` with the real results. **Verification/packaging; TDD N/A** — no `R/`/`tests/`/`DESCRIPTION` touched; `cran-comments.md` is `.Rbuildignore`d. 0 `AskUserQuestion` gates (direct continuation of Phase 5b work already in motion). 0 stakeholder corrections.
- **Change:** After the Session 327 `.Rbuildignore` fix, the owner re-ran the full Phase 5b runbook. win-builder (R-devel/release/oldrelease): all three `0 errors | 0 warnings | 1 note` — confirmed via each `00check.log` that the remaining note is exactly the expected CRAN-incoming-feasibility note. R-hub v2 (linux/windows/macos): windows and macos `Status: OK` on the first run (confirmed via the actual job logs, not just the CI job-success flag); linux initially failed at the `setup-deps` step (`Failed to download Pandoc 3.8.3: Unexpected HTTP response: 504` — confirmed transient infra via the failure log, matching the runbook's documented precedent, not a code defect), then `Status: OK` on a linux-only re-run. All six platform checks now clean.
- **Also:** Updated `cran-comments.md`'s "Test environments" section (replacing both placeholders with the real results) and reconciled NOTE 1's misspelled-words list to the exact set win-builder actually flagged (`EHR`, `Raboin`, `kinships`), per the runbook's own §4.2 reconciliation instruction. Updated `docs/planning/cran-2.0.0-submission-plan.md`'s Phase 5 status block and §9 table's Phase 5b row. The only remaining step is the owner's `submit_cran()` HARD STOP (outward-facing, maintainer-email-confirmation-only, not delegable).
- **Session:** S328 · **Verified:** each win-builder `00check.log` and R-hub job log fetched and read directly, not inferred from summary status alone.

### 2026-07-09 · [ad hoc] Fix .Rbuildignore gap surfaced by win-builder NOTE 2 (Session 327)
- **Deliverable:** Fixed a real `.Rbuildignore` gap found when the owner actually ran the Phase 5b runbook. **Build-hygiene/config fix; TDD N/A** — no `R/`/`tests/` touched, verified via `R CMD build .` + `tar tzf`, matching Phase 1's own classification for this exact class of change. 0 `AskUserQuestion` gates (owner directly instructed the fix after reviewing the finding). 0 stakeholder corrections.
- **Change:** All three win-builder results (R-devel/release/oldrelease) came back `0 errors | 0 warnings | 2 NOTEs`. NOTE 1 matched `cran-comments.md`'s already-pre-explained content. NOTE 2 was new and real, not the plan's anticipated local-toolchain note: "Non-standard files/directories found at top level: `BOOTSTRAP.md` `CONTEXT_TEMPLATE.md` `HANDOFFS.md` `dashboard_history.jsonl`" — identical across all three logs (confirmed via `WebFetch` of each `00check.log`). Root cause: all four files were introduced by the Session 324 methodology sync (three new root docs, plus a generated snapshot file that is `.gitignore`d but was never separately `.Rbuildignore`d), after the S322 local gate ran — so that gate never tested against them, and Session 326's own drift check (scoped to `R/`/`tests/`/`DESCRIPTION`) could not have caught this class of gap either. Added 4 anchored, paren-free lines to `.Rbuildignore`'s existing "Methodology framework files" section, matching its established style. Verified via `R CMD build .` + `tar tzf` grep: the 4 files no longer ship; top-level listing is back to the standard set.
- **Also:** added a correction note to `docs/planning/cran-2.0.0-submission-plan.md`'s Phase 5 status block (honestly flagging that Session 326's "no change needed" conclusion was incomplete), a new Dragon #11 in §5 generalizing the lesson (a code-path-scoped drift check cannot see new root-level files; `.gitignore` and `.Rbuildignore` are separate mechanisms), and updated the §9 table's Phase 5b row. Added `PROJECT_LEARNINGS.md` Learning 303.
- **Session:** S327 · **Verified:** `R CMD build .` then `tar tzf nprcgenekeepr_2.0.0.tar.gz | grep -E "BOOTSTRAP|CONTEXT_TEMPLATE|HANDOFFS|dashboard_history"` — empty. Build artifact removed, not committed.

### 2026-07-08 · [ad hoc] CRAN 2.0.0 Phase 5b readiness re-verified, zero drift (Session 326)
- **Deliverable:** Resumed `docs/planning/cran-2.0.0-submission-plan.md` Phase 5b per the S325 handoff's SUGGESTED NEXT. **Verification/packaging; TDD N/A** — no `R/`/`tests/`/`DESCRIPTION` touched. 1 `AskUserQuestion` scope gate (verify-only vs. live-run vs. attempt-to-trigger the win-builder/R-hub uploads). 0 stakeholder corrections.
- **Change:** Put Phase 5b's scope to the owner first — the dedicated runbook (`docs/planning/cran-2.0.0-phase5-runbook.md`) frames the cross-platform runs as outward-facing and owner-triggered (needs the owner's GitHub PAT; win-builder results arrive by email), matching S135/S242/S320/S323/S325 precedent. Owner chose "Verify readiness only." Confirmed zero drift since the S322 local gate / S323 `cran-comments.md` resync: no commits touch `R/`, `tests/`, or `DESCRIPTION` since gate commit `2abfc783`; `origin/master` and `HEAD` are `0 0` apart; `DESCRIPTION` Version is still `2.0.0`; `cran-comments.md` and the Phase 5 runbook both re-read clean; `Rscript` introspection confirmed no API drift in the installed `devtools`/`rhub`/`gitcreds` versions against the runbook's function calls.
- **Also:** added a verification-status note to the plan document's Phase 5 status block and its §9 summary table's Phase 5b row, recording this re-verification. No changes to `R/`, `tests/`, `DESCRIPTION`, `NEWS.Rmd`/`NEWS.md`, `cran-comments.md`, or the runbook itself — all confirmed accurate as-is.
- **Session:** S326 · **Verified:** `git log --oneline 2abfc783..HEAD -- R/ tests/ DESCRIPTION` empty; `git rev-list --left-right --count origin/master...HEAD` = `0 0`.

### 2026-07-08 · [ad hoc] Adopt the canonical Authoritative Action Ledger format going forward (Session 325)
- **Deliverable:** Resolved the ledger-format gap S324 flagged (`CLAUDE.md` Adaptations section) — owner chose "freeze legacy, go forward" over a full 303-entry historical migration or a one-session full rewrite (`AskUserQuestion` scope gate). **Infra/docs; TDD N/A** — no `R/`/`tests/`/`DESCRIPTION` touched. 1 `AskUserQuestion` gate. 0 stakeholder corrections.
- **Change:** This file now carries the "How to add an entry" section above (source-tag rules) and a `## Legacy history (pre-ledger format, Sessions 1-324)` boundary marker below. The 303 existing entries (Sessions 1-324) are unchanged in content and format beneath that marker — no retroactive per-entry source-tag migration was attempted (that would require real judgment across 214 issue-linked, 6 pre-GitHub-era `NEW-`/`PED-`-tagged, and 83 unlabeled entries — not a mechanical pass). All entries from this session forward use the canonical `[SOURCE]`-tagged header.
- **Also:** backfilled `HANDOFFS.md`'s S324 receipt `commit: pending` field to its actual sha, now known.
- **Session:** S325 · **Verified:** n/a — docs-only. Confirmed `methodology_dashboard.py`'s `_DATED_ENTRY_RE`/freshness checks key only on the `### YYYY-MM-DD` date token (format-agnostic), so this restructure doesn't change dashboard scoring.

