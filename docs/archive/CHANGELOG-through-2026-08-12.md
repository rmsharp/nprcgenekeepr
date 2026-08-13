# CHANGELOG.md — archive: 2026-08-11 → 2026-08-12

Retired records from [`CHANGELOG.md`](../../CHANGELOG.md), moved here so the live ledger stays small enough to read
in one pass. Same format, same newest-on-top order — this is the same ledger, continued.

Holds **67 record(s), 2026-08-11 → 2026-08-12**. Cut key: `2026-08-12`. Counts here are computed from the file
itself, never carried forward. This shard is frozen: it states no forward-looking rule,
because the live file owns those and a copy of one was wrong a day after it was written.

---

### 2026-08-12 · [ad hoc] S542 close-out: findings logged to BACKLOG.md, Learning 549
- **Deliverable:** Session S542's own close-out. Logged 2 new `BACKLOG.md` Housekeeping items
  found this session: `test-coverage.yaml` failing on `origin/master`'s last 2 pushes (S536,
  S540) — READY to diagnose; and `CHANGELOG.md`'s own `methodology_trim.py` archive attempt
  refusing via `SRF_RED` (2.9299 against the most recent 11-record archive, 0.1766 against the
  largest-drop boundary) — DECISION NEEDED, deliberately not `--force`-ed past this session.
  `PROJECT_LEARNINGS.md` Learning 549 records the SRF two-boundary discrepancy and the
  stop-and-ask discipline applied instead of forcing.

### 2026-08-12 · [ad hoc] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-08-12.md` (39 record(s), 226,617 B → 8,629 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **39** record(s) (2026-08-10 → 2026-08-12) out of [`HANDOFFS.md`](../../HANDOFFS.md) into
[`docs/archive/HANDOFFS-through-2026-08-12.md`](../../docs/archive/HANDOFFS-through-2026-08-12.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/HANDOFFS-through-2026-08-12.md.verify.sh`](../../docs/archive/HANDOFFS-through-2026-08-12.md.verify.sh)
rather than trusting a digest printed here. Live file 226,617 B → 8,629 B (−96.2%).

### 2026-08-12 · [ad hoc] S542 claim: CHANGELOG.md/HANDOFFS.md ledger archive
- **Deliverable:** Session claim commit `62882046` (SESSION_NOTES.md stub + HANDOFFS.md
  `status: pending` receipt) — logged here ahead of running `methodology_trim.py`, which
  refuses (`P1_UNDOCUMENTED`) while any commit sits undocumented past this file's frontier,
  matching the S528 precedent.

### 2026-08-12 · [ad hoc] S542 Phase 0 reconcile: HANDOFFS.md S541 receipt commit: pending → 20fc8633
- **Deliverable:** Phase 0 ledger reconcile — backfilled the S541 `HANDOFFS.md` receipt's
  self-referential `commit: pending` field to `20fc8633` (the close-out commit's own sha, now
  known since the commit exists), matching the S538→S539/S539→S540/S540→S541 precedent.

### 2026-08-12 · [BL-522] `a2interactive.Rmd` documentation pass — 8 script-callable functions/families gained demonstration sections (Session 541)
- **Deliverable:** Added demonstration sections to `vignettes/a2interactive.Rmd` for every
  exported, script-callable function that had shipped since the last documentation pass
  (S478) with zero tutorial coverage, per `BACKLOG.md`'s S522 item: `markerParentageLikelihood()`,
  `checkCrossCenterMapping()`, `checkLocusMetadata()`, `checkLinkageMarkerGenotypeFile()`,
  `markerRealizedRelatednessVariance()`, `markerLdBlock()`, `obfuscateLdBlocks()`,
  `reportMatePairs()`, and `readTwinRelations()`.
- **New sections:** "Candidate-Parent Likelihood Ranking" and "Validating a Cross-Center
  Mapping" (the latter as a lead-in immediately before the existing "Cross-Center Identity
  Linking" section, which was trimmed of its now-redundant `pedA`/`pedB`/`mapping` setup to
  avoid duplication) and "Multiallelic Marker Panels and Locus Metadata", "Realized
  Relatedness Variance", "Linkage-Disequilibrium Blocks", "De-identifying LD-Block Results"
  (all under "Marker Genetics"); a new top-level "Individual Mate-Pair Analysis" section
  reusing the tutorial's own `trimmedPed`/`trimmedGeneticValue`/`candidates` objects; a new
  "Twin/Zygosity Connectors" subsection inside "Pedigree Diagram".
- **Verification:** every demo's exact values confirmed by running the real code against the
  installed package (`pkgload::load_all()`) before writing prose, per `PROJECT_LEARNINGS.md`
  Learning 440; full vignette re-rendered end-to-end (`rmarkdown::render()`) with no
  unexpected errors. New identifiers added to `inst/WORDLIST`;
  `spelling::spell_check_package(vignettes = TRUE)` 0 rows. Full clean regression 0 failed/0
  error (4,676 passed); `devtools::check()` 0 errors/0 warnings/1 NOTE (pre-existing
  vignettes/figure-leftover, baseline-matching). `PROJECT_LEARNINGS.md` Learning 548.

### 2026-08-12 · [ad hoc] S541 Phase 0 reconcile: HANDOFFS.md S540 receipt commit: pending → 86367737
- **Deliverable:** Phase 0 ledger reconcile — backfilled the S540 `HANDOFFS.md` receipt's
  self-referential `commit: pending` field to `86367737` (the close-out commit's own sha, now
  known since the commit exists), matching the S538→S539/S539→S540 precedent.

### 2026-08-12 · [ad hoc] Fixed R-CMD-check.yaml failing on GitHub CI (Session 540)
- **Deliverable (owner-directed, not from `BACKLOG.md`):** `R-CMD-check.yaml` failed 100% of
  the time on the last 2 pushes (ubuntu release/oldrel-1/devel, windows-latest — macOS
  passed), `[ FAIL 3 | WARN 33 | SKIP 227 | PASS 5399 ]`. All 3 failures traced to S526's
  issue #152 Slice 2 benchmark tests — the D5 performance rewrite itself is correct; only the
  tests' environment assumptions were wrong.
- Root-caused, not guessed: (1)/(3) `test_markerKinship.R:169` and
  `test_markerParentageLikelihood.R:628` are `system.time()` wall-clock thresholds (0.10s/0.5s)
  calibrated on the S526 author's local machine — GitHub's shared Linux/Windows runners
  consistently miss them by 30-90%, a deterministic hardware-speed mismatch, not random
  flakiness. (2) `test_markerParentageLikelihood.R:582`'s `expect_identical(actual, golden)`
  golden-master check — confirmed via a standalone repro run both locally (macOS, byte-
  identical to golden) and inside a Linux `r-base:4.6.1` Docker container (differs at the
  2-ULP level, e.g. `1.4069136483226261` vs `...263`), a benign cross-platform `log()`-libm
  rounding non-portability, not a D5-rewrite behavior regression (`markerKinship()`'s own
  golden-master test is unaffected — its computation is exact-integer matrix products with no
  transcendental calls, confirmed by reading `R/markerKinship.R`).
- Fix (test-files only, zero production-code changes): `testthat::skip_on_ci()` on both
  timing benchmarks, kept as local/interactive regression guards; `expect_identical()` →
  `expect_equal()` for the golden-master check. Each documented with a comment recording the
  finding. Owner approved the fix approach via `AskUserQuestion` before any edit.
- Verification: full clean regression (`pkgload::load_all()` + `testthat::test_dir()`)
  0 failed/0 error (33 pre-existing warnings, unchanged baseline, 5,517 passed); both touched
  test files re-run in isolation, all pass locally (CI env var unset, so `skip_on_ci()` does
  not skip); `devtools::check()` 0 errors/0 warnings/1 NOTE (the pre-existing vignettes/figure
  leftover, matching baseline exactly) — `testthat.R` `[137s/137s] OK`; `lintr::lint_package()`
  0 lints on both touched files. Runtime smoke test: n/a — test-file-only change, no runtime/
  Shiny behavior touched.
- `PROJECT_LEARNINGS.md` Learnings 546 (the `log()` cross-platform finding) and 547 (a
  13-session-spanning gap: no Phase 0 step checks GitHub Actions CI status at all, so this
  failure sat unnoticed since S526 — flagged as a new `BACKLOG.md` Housekeeping item for a
  future decision, not fixed this session). **This fix is local-only as of this entry — the
  actual GitHub CI run stays red until a push happens** (`master` is currently 16 commits
  ahead of `origin/master`); a future push (this session's own, or the owner's) will trigger
  the first genuinely green `R-CMD-check.yaml` run since S526.

### 2026-08-12 · [ad hoc] S540 Phase 0 reconcile: HANDOFFS.md S539 receipt commit: pending → d34a6447
- `git log -1 --format=%H -- HANDOFFS.md` showed the frontier commit (`d34a6447`, the S539
  close-out commit) still carried its own receipt's self-referential `commit: pending`
  placeholder (legal at write time per `HANDOFFS.md`'s own format note — the receipt ships in
  the very commit whose sha it would name). Reconciled to `d34a6447`, matching the
  S539→S538/S538→S537 precedent immediately below. `CHANGELOG.md`'s own frontier (`841aeae2`)
  has a 2-commit gap (`53720f7e`, `d34a6447`) that is not a real undocumented action — both are
  S539's own trailing close-out commits (BACKLOG.md RESOLVED + Learning 545; the SESSION_NOTES.md/
  HANDOFFS.md handoff write itself), whose content the `[BL-518]` entry below already covers; a
  session's own final close-out commit cannot cite its own not-yet-made sha, so a 1-2 commit
  trailing gap of this shape is expected every session, not a gap to backfill.

### 2026-08-12 · [BL-518] `SESSION_NOTES.md`'s first `methodology_trim.py --write` archive (Session 539)
- **Deliverable:** Resolved the deferred remainder of the S518 ledger-size item: `SESSION_NOTES.md`
  had climbed to 42,670 lines (21x past the 2,000-line agent read cap) and 6,370,574 B (97x the
  65,536 B budget) — the dashboard's own top HIGH-risk flag. Both prior blockers (the fence-scanner
  defect, S527's rewrap fix; the `record_start` regex gap, S528's fix) were already resolved, so
  this session just re-ran the dry-run (620 records, up from S528's 599 — 21 sessions' worth of
  drift) to confirm still clean, then `--write`.
- Result (tool's own `[ad hoc]` entry immediately below has the mechanical detail): 612 of 620
  records archived to `docs/archive/SESSION_NOTES-through-2026-08-12.md`; live file 30,066 B / 370
  lines, both now well under budget. Losslessness verified via the tool's L1/L2/L3 checks and the
  generated `.verify.sh` script — all OK.
- One gate hit and cleared: `methodology_trim.py`'s `P1_UNDOCUMENTED` check refused to run while
  this session's own Phase 1B claim commit sat undocumented ahead of the ledger frontier (a trim
  commit would have advanced the frontier and hidden that gap permanently) — logged the claim to
  `CHANGELOG.md` on its own first (see the entry below), which cleared it. `PROJECT_LEARNINGS.md`
  Learning 545. `BACKLOG.md` item marked RESOLVED.

### 2026-08-12 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-08-12.md` (612 record(s), 6,370,574 B → 30,066 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **612** record(s) (1998-12-06 → 2026-08-12) out of [`SESSION_NOTES.md`](../../SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-08-12.md`](../../docs/archive/SESSION_NOTES-through-2026-08-12.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh`](../../docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh)
rather than trusting a digest printed here. Live file 6,370,574 B → 30,066 B (−99.5%).

### 2026-08-12 · [ad hoc] S539 claimed for BACKLOG.md's SESSION_NOTES.md `--write` archive item
- Session 539 claimed (`SESSION_NOTES.md`/`HANDOFFS.md` stub, commit `494e51b9`) to run
  `methodology_trim.py`'s first `--write` archive of `SESSION_NOTES.md` — both prior blockers
  (the S518 fence-scanner defect and its S527/S528 fixes) are resolved; this session re-runs the
  dry-run to confirm still clean, then writes. Logged here on its own, ahead of the deliverable,
  because `methodology_trim.py`'s own `P1_UNDOCUMENTED` gate refuses to run while any commit sits
  undocumented ahead of `CHANGELOG.md`'s frontier (a trim commit would advance that frontier and
  hide the gap permanently) — the claim commit itself needed a line before `--write` would proceed,
  matching the same gate S528 hit and noted in `BACKLOG.md`.

### 2026-08-12 · [ad hoc] S539 Phase 0 reconcile: HANDOFFS.md S538 receipt commit: pending → cf8f9bbe
- `git log -1 --format=%H -- HANDOFFS.md` showed the frontier commit (`cf8f9bbe`, the S538
  close-out commit) still carried its own receipt's self-referential `commit: pending`
  placeholder (legal at write time per `HANDOFFS.md`'s own format note — the receipt ships in
  the very commit whose sha it would name). Reconciled to `cf8f9bbe`, matching the
  S538→S537 (`a39f7756`) and S537→S536 (`66202b2a`) precedent. `CHANGELOG.md`'s own frontier
  (`git log -1 --format=%H -- CHANGELOG.md`) was `6504ebc6`; the only undocumented commit since
  then was `cf8f9bbe` itself, which — matching the established precedent that a close-out
  commit containing only `SESSION_NOTES.md`/`HANDOFFS.md` writes is not a separate action beyond
  what its paired deliverable commit already logged — is covered by this reconcile entry rather
  than a second one.

### 2026-08-12 · [BL-522] Trimmed NEWS.Rmd's post-2.0.0.9000 verbosity back to the project's terse pre-1.0.8 house style (Session 538)
- **Deliverable:** Rewrote the `2.0.0.9000 (development version)` section's 26 entries
  from multi-sentence paragraphs (full closed-form formulas, citation strings,
  derivation/approximation rationale) back to the pre-1.0.8 one/two-line-per-change
  style, per this item's own explicit scoping instruction: rewrite the open
  development-version section only, leave already-released/frozen version sections
  untouched (matching `CHANGELOG.md`'s own Legacy-history-marker precedent).
- Verified every dropped formula/citation string is already covered by the relevant
  function's roxygen `@references` and/or
  `inst/extdata/ui_guidance/population_genetics_terms.html` (spot-checked via `grep`
  across 14 statistic-bearing functions — `markerKinship()`, `markerExpectedHeterozygosity()`,
  `markerParentageExclusion()`, `markerFst()`, `markerParentageLikelihood()`,
  `markerRealizedRelatednessVariance()`, `calcSkewness()`/`calcKurtosis()`,
  `calcGeneDiversity()`, `calcNeSexRatio()`/`calcNeVariance()`, `checkLocusMetadata()`,
  `markerLdBlock()`, `computeGenomicROH()` — before dropping the citation text from
  `NEWS.Rmd`). `computeGenomicROH()`'s F_ROH formula was initially a false-negative
  (present in the HTML page under `<sub>` markup that a literal `F_ROH` `grep` missed) —
  re-checked with broader search terms before trusting the negative.
- Cross-diffed every issue number and every backtick-quoted exported/new function name,
  old text vs. new, to confirm no substantive capability mention was lost. 4 genuinely
  -dropped function-name mentions were restored after the diff caught them
  (`makeGeneticSummaryTable()`, `getPossibleCols()`, `getBoxWhiskerDescription()`/
  `savePlotToFile()`/`getPyramidPlot()`, `createSimKinships()`/`cumulateSimKinships()`);
  the remainder were confirmed-intentional (implementation-rationale mentions naming an
  existing function, not a new capability).
- **Mid-session self-correction:** an initial pass also rewrote the already-released
  `2.0.0 (20260708)` section — misreading the owner-approved "all post-2.0.0 entries"
  scope-question phrasing as license to include it, contradicting this very item's own
  "do not rewrite already-released, frozen version sections" instruction. Caught by
  re-reading the item's exact text before finishing; reverted that section verbatim
  from `git show HEAD:NEWS.Rmd` and re-rendered before closing out.
- Net: dev-version section 386 → 134 lines (252 removed); `NEWS.Rmd` 1,154 → 902 lines.
  `NEWS.md` regenerated via
  `rmarkdown::render("NEWS.Rmd", output_format = rmarkdown::github_document(html_preview = FALSE))`
  (no `NEWS.html` render litter, per `PROJECT_LEARNINGS.md` Learning 122/123's own
  documented render discipline). Section-heading count/order confirmed identical
  between `NEWS.Rmd`/`NEWS.md` (28 headings each, exact string match).
- **A first `devtools::check()` run found a real, second bug the unit-test-only pass
  missed:** rewriting the dev-version section's prose shifted `hunspell`/`spelling`'s
  context-sensitive tokenization around several already-benign `` `fn()`'s ``/
  `word's` possessive constructs (identical patterns existed pre-session and passed
  clean under S537), newly flagging 2 words -- `centers'` and a stray, context
  -orphaned `'s` fragment -- that S537's fresh `test_wordlist_coverage.R` guard
  correctly caught as a real `1 error`. Root-caused by isolating the exact flagged
  strings/line numbers via `spelling::spell_check_package()` directly (not just the
  test's pass/fail), and confirmed both are false positives (no real typo), not
  reachable by adding `centers'`/a bare `'s` to `inst/WORDLIST` (out of this session's
  own NEWS-only scope, and a bare `'s` entry would blind the guard to real future
  typos sharing that fragment) -- instead rephrased the 6 exact possessive
  constructs producing the flags (`groupAddAssign()`'s → `groupAddAssign()` gains...
  in its return value; `` makePedigreeDiagramData()`'s node data `` → `Node data from
  makePedigreeDiagramData()`; 2× `kinship2's` → `a kinship2`/`the kinship2`; 2×
  `centers'` → `from two centers`/`the populations of two centers`), re-rendered, and
  reconfirmed `spelling::spell_check_package()` returns 0 rows.
- **Verified:** `test_wordlist_coverage.R` and `test_effectivePopulationSizeDocs.R`'s
  `NEWS.Rmd` regression guard (asserts "effective population size"/"gene diversity"
  both present) both pass. Full clean regression 0 failed/0 error (33 pre-existing,
  unrelated warnings, unchanged from S537's own baseline). Final `devtools::check()`:
  0 errors / 0 warnings / 1 NOTE (only the pre-existing vignettes/figure-leftover
  NOTE — matching S537's own baseline exactly). No `R/` files touched this session
  (docs-only) — lint N/A. Phase 3E: n/a in the "launch the app" sense (no
  runtime/Shiny behavior changed); the `devtools::check()` run above is this
  session's complete build-equivalent verification.
- TDD phase: N/A — pure documentation/editorial change, no production code or test
  surface, matching this project's own established "planning session has no
  code-phases" precedent (`PROJECT_LEARNINGS.md`, extended here to a docs-only
  session).

### 2026-08-12 · [ad hoc] S538 Phase 0 reconcile: HANDOFFS.md S537 receipt commit: pending → a39f7756
- `git log -1 --format=%H -- HANDOFFS.md` showed the frontier commit (`a39f7756`, the S537
  close-out commit) still carried its own receipt's self-referential `commit: pending`
  placeholder (legal at write time per `HANDOFFS.md`'s own format note — the receipt ships in
  the very commit whose sha it would name). Reconciled to `a39f7756`, matching the
  S537→S536 (`66202b2a`) and S536→S535 (`42e3e985`/`f946e0a3`) precedent. `CHANGELOG.md`'s own
  frontier (`git log -1 --format=%H -- CHANGELOG.md`) was `250b33d0`; the only undocumented
  commit since then was `a39f7756` itself, which — matching the established precedent that a
  close-out commit containing only `SESSION_NOTES.md`/`HANDOFFS.md` writes is not a separate
  action beyond what its paired fix commit already logged — is covered by this reconcile entry
  rather than a second one.

### 2026-08-12 · [BL-521] Fixed inst/WORDLIST's spelling-check gap; added a permanent regression guard (Session 537)
- **Deliverable:** Verified all 76 currently-flagged `inst/WORDLIST` words (found S521;
  BACKLOG.md's documented count of 69 was stale) as genuine false positives via source-context
  `grep` — zero actual typos found — and hand-added them. Found and excluded 4 additional
  words (`CJ`/`PWJ`/`QBKW`/`ZX`) traced to a stale, `.gitignore`'d `vignettes/a2interactive.md`
  build byproduct that a clean checkout/CI would never see (confirmed via a `git archive HEAD`
  re-check). Added a new permanent guard, `tests/testthat/test_wordlist_coverage.R`, asserting
  `spelling::spell_check_package()` returns 0 rows, so this recurring drift (S443/S448/S452/
  S465/S490) gets a hard test failure instead of an easy-to-miss `devtools::check()` NOTE.
- **Corrected a factually-wrong convention** stated in 3 prior `BACKLOG.md` entries (S452/S465/
  S490): `inst/WORDLIST` is NOT `LC_ALL=C` byte-order sorted — it is loosely hand-maintained
  alphabetical. A first merge attempt using `LC_ALL=C sort -u` silently reordered ~21 unrelated
  existing entries; caught via `git diff` before committing and redone as a pure 76-line
  insertion (verified zero deletions).
- **A full `devtools::check()` run found a second real bug**, not caught by the unit test alone:
  the new guard's `testthat::test_path("..", "..")` broke under R CMD check's own `testthat.R`
  execution (`1 error`) because testthat runs each `test_that()` block with the working
  directory set to the test file's own directory, at a different relative depth than under
  `devtools::test()`. Root-caused (confirmed via a live `getwd()` print) and fixed by reusing
  `spelling::spell_check_test()`'s own proven `00_pkg_src`-sibling resolution strategy at the
  correct depth, verified via a fast local R-CMD-check-layout simulation before a final full
  re-check.
- **Verification:** full clean regression 0 failed/0 error; final `devtools::check()` — **0
  errors / 0 warnings / 1 NOTE** (only the pre-existing vignettes/figure-leftover NOTE; the
  spelling NOTE is gone); `lintr::lint_package()` 0 lints on the new file. No NEWS.Rmd/citation/
  tutorial/`_pkgdown.yml`/`a2interactive.Rmd` close-out checklist applies (no new export, no new
  Shiny feature). Full strict TDD PRE-RED→RED→GREEN→REFACTOR, each phase transition gated via
  `AskUserQuestion` per `CLAUDE.md`'s Development Process Contract. `PROJECT_LEARNINGS.md`
  Learning 543.

### 2026-08-12 · [ad hoc] S537 Phase 0 reconcile: HANDOFFS.md S536 receipt commit: pending → 66202b2a
- `git log -1 --format=%H -- HANDOFFS.md` showed the frontier commit (`66202b2a`, the S536
  close-out commit) still carried its own receipt's self-referential `commit: pending` placeholder
  (legal at write time per `HANDOFFS.md`'s own format note — the receipt ships in the very commit
  whose sha it would name). Reconciled to `66202b2a`, matching the S536→S535 (`42e3e985`/
  `f946e0a3`) and S535→S534 (`9abaded1`) precedent. `CHANGELOG.md`'s own frontier
  (`git log -1 --format=%H -- CHANGELOG.md`) was `420a1c53`; the only undocumented commit since
  then was `66202b2a` itself, which — matching the established precedent that a close-out commit
  containing only `SESSION_NOTES.md`/`HANDOFFS.md` writes is not a separate action beyond what its
  paired fix/feat commit already logged (see `bef447c6`/`2b54c722`, neither of which got its own
  dedicated entry) — is covered by this reconcile entry rather than a second one.

### 2026-08-12 · [BL-535] Corrected S535's "shinytest2/chromote never renders showModal()" misdiagnosis; retrofitted issue #153's E2E export-modal coverage (Session 536)
- **Deliverable:** Investigated the BACKLOG.md Housekeeping item S535 filed (headless-browser
  modal-rendering gap). Found there is NO shinytest2/chromote harness limitation: S535's own
  E2E pedigree fixture (`makeGenomicRohE2ePedigreeFile()`) omitted `columnSchema.R`'s required
  `birth` column, so `dataInput`'s QC silently rejected it and `pedigree()` stayed NULL --
  correctly (not a bug) blocking `req(pedigree())`/`req(sequenceExportRaw())` all the way to
  `showModal()`. Root-caused via a live `shinytest2::AppDriver` diagnostic session: real
  click-event listeners proved the Confirm Export click registers correctly; temporary
  `message()` instrumentation (removed before commit) in `R/modMarkerGenetics.R`'s
  `sequenceExportPreview`/`sequenceConfirmExport` observers pinpointed `pedigree()` as NULL;
  the Input tab's own `#dataInput-qcErrors` output (never checked by S535's test) showed why
  ("Missing required columns: birth"). Verified live: with `birth` added, the full Generate
  Preview -> Confirm Export -> modal (`display: block`) -> Confirm Export OK -> modal-removed
  sequence works end to end in headless Chrome, no different from a real browser. No production
  `R/` code changed -- the test fixture was the only defect.
  **Fix:** `tests/testthat/test-e2e-marker-genetics-genomic-roh-module.R` -- added `birth` to
  the fixture, removed the false "known harness limitation" framing and graceful-skip fallback,
  and strengthened assertions to actually drive Confirm -> Confirm OK live and check
  `sequenceExportGuidance`'s real empty-vs-alert render state (stronger than the pre-existing
  substring-in-static-HTML check, which let the misdiagnosis go unnoticed since a
  `downloadButton`'s `id` is always present in its href regardless of whether real content was
  ever generated). New `tests/testthat/test-e2e-marker-genetics-ld-block-module.R` retrofits
  live E2E coverage for issue #153's previously-untested LD-block export modal (same corrected
  pattern; a second, distinct QC gate -- `checkParentAge()`'s "Parent age too young" -- was
  found and fixed via wider founder/offspring birth-date spacing). `.github/workflows/
  shinytest2.yaml`'s CI group list updated for the new file (verified against
  `test_shinytest2_workflow_coverage.R`'s partition guard). `BACKLOG.md` Housekeeping item
  corrected to RESOLVED/misdiagnosed. `PROJECT_LEARNINGS.md` Learning 542 added, correcting
  Learning 541's second finding.
  **Verification:** Full strict TDD RED->GREEN, each phase transition gated by its own
  `AskUserQuestion` per `CLAUDE.md`'s Development Process Contract; RED confirmed by running the
  genomic-ROH E2E test against the original birth-less fixture (3 failures + 1 error, matching
  S535's exact symptom), then GREEN after the fixture fix (all assertions pass); the new #153
  test's own first honest run similarly failed (parent-age QC) before its fixture fix. Full
  clean regression 0 failed/0 error; `devtools::check()` 0 errors/0 warnings/2 NOTEs (both
  confirmed pre-existing via the raw `Status:` line per Learning 538). No `R/` production code
  changed, so lint N/A (`.lintr` wholesale-exempts `tests/`) and no `devtools::document()`
  needed. Phase 3E runtime verification: both E2E tests drive the real, running app end to end
  in headless Chrome (this session's own deliverable IS runtime/E2E verification).
- **Model:** Claude Sonnet 5.

### 2026-08-12 · [ad hoc] S536 Phase 0 reconcile: HANDOFFS.md S535 receipt
- `commit: pending` -> `commit: 2b54c722` (the S535 close-out commit) -- reconciled at Session
  536's Phase 0 orient, matching the S535->S534 reconcile precedent (`9abaded1`).

### 2026-08-12 · [issue #152] GitHub issue closed (Session 535)
- `gh issue close 152 --reason completed`, with a comment summarizing all 5 shipped slices
  (Sessions 525-535) and this session's own verification evidence. Matches the established
  same-session issue-close-out checklist.

### 2026-08-12 · [issue #152] Slice 5 -- full module tab, wiring, curator-controlled export, and documentation shipped, closing issue #152 (Session 535)
- **Deliverable:** Implemented issue #152 Slice 5 -- the full module tab, wiring,
  curator-controlled export, and documentation (D8/D9), per
  `docs/planning/issue152-sequence-input-genetic-metrics-plan.md` section 5 Slice 5. **Closes
  issue #152** (all 5 slices shipped, Sessions 525-535). New "Genomic ROH (F_ROH)" tab in
  `R/modMarkerGenetics.R`: reuses the EXISTING `genotypeFile`/`genotypeFileB`/`locusMetadataFile`
  inputs (validator swapped to the confirmed-superset `checkSequenceGenotypeFile()`, no new
  upload controls -- a Pre-RED `AskUserQuestion`-ratified simplification of the plan's own
  proposed interface catalog); new `sequenceRohTable` reactive; a curator confirm-gate export
  (Generate Preview -> Confirm -> Confirm-OK -> 3 downloads: de-identified genotype matrix,
  de-identified F_ROH table, manifest). New `R/obfuscateGenomicROH.R`
  (`obfuscateGenomicROH()`), a new de-identification primitive for `computeGenomicROH()`'s
  id-column table shape.
- **Verification:** Full strict TDD PRE-RED->RED->GREEN->REFACTOR, twice (once for the main
  slice, once more for a bug found via Phase 3E live verification), each transition gated by
  its own `AskUserQuestion`. 13 new tests at first RED; full clean regression 0 failed/0 error.
  **A real bug found and fixed via this slice's own Phase 3E live verification** (not caught by
  `testServer` alone): `sequenceRohTable` passed `locusMetadata()`'s ALREADY-checked output
  (with an appended `coverage` column) into `computeGenomicROH()`, which internally re-runs
  `checkLocusMetadata()` expecting the raw 3/4-column shape -- silently mislabeled `coverage` as
  `cM` on a 3-column fixture (no error, wrong data) and threw loudly on the real 4-column (with
  `cM`) committed Slice 1 fixture. Fixed by stripping `coverage` before the second check; a new
  4-column regression test added. **A second finding, not a defect:** `shinytest2`/`chromote`'s
  headless browser never renders a `showModal()` modal's DOM for either this tab's export gate
  or the already-shipped issue #153 LD-block export's identical pattern -- a pre-existing
  harness limitation, filed to `BACKLOG.md` Housekeeping (found S535) rather than fixed
  mid-session; the E2E test verifies everything live through Generate Preview at real
  50x1,000-locus scale (zero console errors) and documents + gracefully skips the Confirm-modal
  step. Final: full clean regression 0 failed/0 error (2,127 blocks); `devtools::check()` 0
  errors/0 warnings/2 NOTEs (both confirmed pre-existing via the raw `Status:` line, per Learning
  538's own discipline); `lintr::lint_package()` 0 lints on touched files. 1 genuinely new
  spelling-flagged word (`computeGenomicROH`) hand-added to `inst/WORDLIST`. `_pkgdown.yml`
  reference-coverage guard updated and passing. Tutorial/article checklist (Session 436): a new
  "Genomic ROH (F_ROH)" section added to `vignettes/articles/colony-manager-guide.qmd` with a
  real screenshot from the live app; `quarto render` confirmed clean. Citation checklist (issue
  #120): N/A, already satisfied at Slice 3. `NEWS.Rmd`/`NEWS.md` entry added.
  `PROJECT_LEARNINGS.md` Learning 541.
- **Next:** `BACKLOG.md` issue #152 tracking item marked closed. A new Housekeeping item filed
  for the `shinytest2`/`chromote` modal-rendering harness gap (found S535).

### 2026-08-12 · [ad hoc] S535 Phase 0 reconcile: HANDOFFS.md S534 receipt commit: pending → bef447c6 (Session 535)
- Phase 0 step 6 ledger reconcile: `HANDOFFS.md`'s S534 receipt was `status: complete` but
  `commit: pending` (the standard one-hop case). Reconciled to `bef447c6` (S534's own
  close-out commit, which included the receipt itself). Committed separately.

### 2026-08-12 · [BL-533] `.Rbuildignore` `methodology_trim.py` pattern typo fixed, top-level-files NOTE resolved (Session 534)
- **Deliverable:** Fixed `.Rbuildignore`'s `methodology_trim.py` pattern typo (found S533,
  filed to `BACKLOG.md` Housekeeping, not fixed that session): `^methodolog_trim\.py$`
  corrected to `^methodology_trim\.py$` (the missing "y" in "methodology"). This was the
  standing, now-confirmed root cause of `devtools::check()`'s documented "top-level files"
  NOTE (`PROJECT_LEARNINGS.md` Learning 539's own root-cause finding).
- **Verification:** One-off fix per `DEVELOPMENT_WORKSTREAM.md`'s own "just fix it" guidance
  for a single, clear bug, under `CLAUDE.md`'s Development Process Contract. Full strict TDD
  RED->GREEN->REFACTOR cycle, each transition gated by its own `AskUserQuestion`. New
  `tests/testthat/test_rbuildignore.R` (mirroring `test_pkgdown_reference_config.R`'s
  config-guard style): asserts some `.Rbuildignore` pattern matches the literal string
  `"methodology_trim.py"`. RED confirmed (1/1 failing) against the live typo before editing;
  GREEN confirmed after the one-character fix. REFACTOR: `lintr::lint_package()`
  (argument-free, per Learning 539) found 0 lints. Full clean regression 0 failed/0 error.
  `devtools::check()` (default `cran = TRUE` invocation) re-confirmed `checking top-level
  files ... OK` -- the NOTE is gone. `Status: 2 NOTEs` is unchanged in count but changed in
  composition: vignettes/figure leftover (pre-existing, unrelated) plus a
  `spelling.Rout`/`spelling.Rout.save` snapshot-mismatch NOTE under the "checking tests" step
  (no `❯`-bullet in the abbreviated table, reconfirming `BACKLOG.md`'s S521
  under-counting finding) -- traces to the already-tracked, separate `inst/WORDLIST` gap, not
  to this fix. `PROJECT_LEARNINGS.md` Learning 540 records the pattern (a `testthat` guard for
  a non-R config file) and a minor `nl`-vs-`grep -n` line-numbering near-miss. Runtime smoke
  test: n/a -- build-config/test-only change, no runtime code touched.
- **Next:** `BACKLOG.md` Housekeeping item marked resolved. No further action.

### 2026-08-12 · [ad hoc] S534 Phase 0 reconcile: HANDOFFS.md S533 receipt commit: pending → a99fd2c2 (Session 534)
- Phase 0 step 6 ledger reconcile: `HANDOFFS.md`'s S533 receipt was `status: complete` but
  `commit: pending` (the standard one-hop case). Reconciled to `a99fd2c2` (S533's own
  close-out commit, which included the receipt itself). Committed separately (`90cd53e8`).

### 2026-08-12 · [issue #152] Slice 4 -- new `obfuscateGenotypeMatrix()` de-identification primitive shipped (Session 533)
- **Deliverable:** New script-callable, `@export`ed `obfuscateGenotypeMatrix(genotypeMatrix, map)`
  (`R/obfuscateGenotypeMatrix.R`), per
  `docs/planning/issue152-sequence-input-genetic-metrics-plan.md` §5 Slice 4 (design decision
  D7, already ratified at design time, folded into D8's own vote). De-identifies a
  sequence-scale genotype matrix by remapping its row names (individual ids) through the same
  alias map `obfuscatePed(..., map = TRUE)` already returns, mirroring
  `obfuscateTwinRelations()`'s/`obfuscateLdBlocks()`'s established pattern exactly: `stop()`s
  loudly (never silently drops) on any id absent from `map`; genotype values, column names
  (loci), and row/column order are unchanged by construction.
- **Verification:** Full strict TDD PRE-RED->RED->GREEN->REFACTOR cycle, each transition gated
  by its own `AskUserQuestion`. 3 new `test_that` blocks in
  `tests/testthat/test_obfuscateGenotypeMatrix.R` (remap-and-values-unchanged,
  stop-on-missing-id, round-trip through the real `obfuscatePed(..., map = TRUE)` map). RED
  confirmed (3/3 failing, function not found) before implementation; GREEN passed all 3 blocks
  on the first attempt; REFACTOR: 0 lints needed (a first pass using
  `lintr::linters_with_defaults()` produced 4 false-positive findings this project's own
  `.lintr` config explicitly permits/disables -- caught before treating them as real; the
  correct argument-free `lintr::lint_package()` found 0). Full clean regression 0 failed/0
  error; `devtools::check()` (default `cran = TRUE` invocation) 0 errors/0 warnings/2 NOTEs,
  both confirmed pre-existing. `devtools::document()` regenerated `NAMESPACE`/
  `man/obfuscateGenotypeMatrix.Rd` plus the `@family obfuscation` cross-reference in 6 sibling
  `.Rd` files. `NEWS.Rmd`/`NEWS.md` gained a terse entry (rendered via `rmarkdown::render()`);
  `_pkgdown.yml`'s "All exposed functions" group gained the new export, confirmed via
  `test_pkgdown_reference_config.R`. Citation checklist (issue #120) and tutorial/article
  checklist (Session 436): N/A this slice, per the design doc's own §9 checklist mapping.
  Runtime smoke test: n/a -- script-callable only, no Shiny wiring touched.
- **Incidental finding:** a first `devtools::check(cran = FALSE)` call misleadingly returned
  only 1 NOTE (not the documented 2-NOTE baseline) -- investigated per
  `PROJECT_LEARNINGS.md` Learning 538's "a lower NOTE count is not automatically good news"
  rule rather than accepted at face value; root-caused to `cran = FALSE` being a non-default
  `devtools::check()` argument that suppresses the CRAN-incoming-style "checking top-level
  files" check. Re-running with the correct default reproduced the documented baseline exactly
  and fully resolved a standing open question (`PROJECT_LEARNINGS.md` Learning 538's own
  unconfirmed NOTE-trigger gotcha): `.Rbuildignore`'s `methodology_trim.py` pattern has a typo
  (`^methodolog_trim\.py$`, missing the "y"), confirmed via direct `grepl()` test. Filed to
  `BACKLOG.md` Housekeeping (not fixed mid-session -- unrelated pre-existing defect).
  `PROJECT_LEARNINGS.md` Learning 539 records this alongside the `lintr` near-miss.
- **Next:** Issue #152 stays open -- Slice 5 (full module tab, wiring, curator-controlled
  export, documentation, D8/D9) is the next and final planned slice, a separate future session.

### 2026-08-12 · [ad hoc] S533 Phase 0 reconcile: HANDOFFS.md S532 receipt commit: pending → 5149e1ab (Session 533)
- Phase 0 step 6 ledger reconcile: `HANDOFFS.md`'s S532 receipt was `status: complete` but
  `commit: pending` (the standard one-hop case). Reconciled to `5149e1ab` (S532's own
  close-out commit, which included the receipt itself). Committed separately (`686f1b36`)
  before this session's own claim commit.

### 2026-08-12 · [issue #152] Slice 3 -- new `computeGenomicROH()` F_ROH genomic-inbreeding metric shipped (Session 532)
- **Deliverable:** New script-callable, `@export`ed `computeGenomicROH(genotypeMatrix,
  locusMetadata, minSnp = 50L, minBp = 1e6)` (`R/computeGenomicROH.R`), per
  `docs/planning/issue152-sequence-input-genetic-metrics-plan.md` §5 Slice 3 (design decision
  D6). Computes per-individual genomic Runs-of-Homozygosity segments and the F_ROH inbreeding
  coefficient from a sequence-scale marker genotype matrix, independent of the recorded
  pedigree. Full strict TDD PRE-RED->RED->GREEN->REFACTOR cycle, each transition gated by an
  `AskUserQuestion` per `CLAUDE.md`'s Development Process Contract; three genuine design
  judgment calls (run-breaking rule, F_ROH's shared-denominator convention, `minSnp`/`minBp`
  defaults) ratified via a dedicated Pre-RED `AskUserQuestion` round.
- **Tests:** 9 new `test_that` blocks / 40 expectations in `tests/testthat/test_computeGenomicROH.R`
  -- a hand-derived, exact-fraction core fixture (matching `markerFst.R`'s own convention) plus 8
  edge cases (heterozygous/missing run-breaks, locus-exclusion+warning, dual-threshold both
  directions, a clean zero-segment case, absent-`locusMetadata` `stop()`, zero-`genomeLength`
  warning+`NA`, default-value confirmation). RED confirmed (9/9 failing, function not found)
  before implementation; GREEN passed all 9/40 on the first attempt; REFACTOR fixed 4
  `implicit_integer_linter` findings with 0 behavior change.
- **Verification:** Full clean regression 5,457 passed/0 failed/0 error (0 non-baseline
  offenders); `devtools::check()` 0 errors/0 warnings/2 NOTEs, both confirmed pre-existing
  (top-level files; vignettes/figure leftover). `lintr::lint_package()` 0 lints on touched
  files. Runtime smoke test: n/a -- script-callable only, no Shiny wiring touched.
- **Also this session:** direct `spelling::spell_check_package()` verification (not the
  abbreviated `devtools::check()` NOTE table) found this session's own new content introduced 6
  genuinely new spelling-gap words (`bp`, `Ceballos`, `gapless`, `Joshi`, `PLINK's`, `ROH`),
  hand-added to `inst/WORDLIST` in `LC_ALL=C` byte-order position -- the pre-existing ~77-word
  gap is unaffected. Also caught and fixed a `PROJECT_LEARNINGS.md` Learning 530 violation in
  this slice's own first-draft citation (an 11-author PLINK reference copied verbatim from
  `checkLocusMetadata.R` rather than trimmed to "Purcell, S., et al. (2007)"), removing
  `computeGenomicROH.Rd` as a second independent source of 5 already-known WORDLIST-gap
  surnames. Citation checklist (issue #120): new F_ROH entry added to
  `inst/extdata/ui_guidance/population_genetics_terms.html`. `NEWS.Rmd`/`NEWS.md`: terse entry
  added. `_pkgdown.yml`: new `computeGenomicROH` entry added. `devtools::document()` run;
  `NAMESPACE`/`man/computeGenomicROH.Rd` regenerated.
- **Issue #152 stays open** -- Slice 4 (new de-identification primitive,
  `R/obfuscateGenotypeMatrix.R`, D7) is the next planned slice, a separate future session.
- **Model:** Claude Sonnet 5.

### 2026-08-12 · [BL-518] `BACKLOG.md` "Genetic-metrics PDF audit follow-ups" section compressed, S518 item RESOLVED (Session 531)
- **Deliverable:** Compressed `BACKLOG.md`'s "Genetic-metrics PDF audit follow-ups" section (753
  lines) per the S518 ledger-size housekeeping item -- the 3rd and last of its 3 oversized sections
  (Housekeeping compressed S529; "Pedigree diagram vs kinship2" compressed S530). The intro-triage
  bullet (issues #126/#127/#129/#130, all closed) plus 6 further independently-tracked closed-issue
  narrative chains (#147, #149, #146, #151, #150, #153 -- each its own design-ratified ->
  Slice-N-DONE -> issue-closed sequence) rewritten to `BACKLOG.md`'s own short-pointer convention;
  the S479-S483 re-audit/sequencing context paragraph condensed while preserving every issue
  number, tier assignment, and audit-doc pointer. The still-open issue #152 chain (design S517,
  Slice 1 S525, Slice 2 S526, Slice 3 next) left fully untouched.
- **Verification before compressing (Learning 535/536's discipline, applied at a larger scale):**
  grepped `CHANGELOG.md` (+ both `docs/archive/CHANGELOG-through-*.md` shards) for all 39 cited
  session numbers before trusting any "See CHANGELOG.md" pointer -- 0 gaps found. All Learning
  cross-references and all 13 cited `docs/planning|audits/*` file paths confirmed to resolve via
  direct grep.
- **A real mid-session defect, found and fixed before close-out:** the first edit for issue #153's
  chain replaced only its S519 design paragraph; 3 further paragraphs (S520 Slice 1, a combined
  S521-523 recap, S524 Slice 5/close) sat elsewhere in the section and were left as now-redundant
  duplicates of the new compressed bullet. Caught by the mandatory full re-read of the compressed
  section before close-out (not during editing); fixed with a follow-up edit removing the
  duplicated 66-line block, verified via `grep -n "Progress (S"` that only the still-open #152
  chain's 3 paragraphs remained. `PROJECT_LEARNINGS.md` Learning 537.
- Net: section 753→267 lines (486 removed); `BACKLOG.md` total 1,658→1,189 (469 net removed,
  after this session's own progress notes added lines back elsewhere in the file). Zero information
  loss verified by re-reading the full compressed section end-to-end (twice -- before and after the
  duplication fix) before close-out.
- `BACKLOG.md`'s own S518 tracking item is now fully RESOLVED: all 3 oversized sections compressed
  across 3 sessions (Housekeeping S529 147→389 lines; "Pedigree diagram vs kinship2" S530 896→286
  lines; "Genetic-metrics PDF audit follow-ups" S531 753→267 lines). File total 2,501 (S529 start)
  → 1,189 lines (S531 end), a 1,312-line/52% reduction across the campaign.
- Also folded in this session's own Phase 0 ledger reconcile (`HANDOFFS.md`'s S530 receipt `commit:
  pending` → `e7feb28e`, see the entry below) before the priorities picker.
- Documentation checklists (citation/tutorial/`NEWS.Rmd`/`a2interactive.Rmd`/`_pkgdown.yml`): N/A --
  no exported function, no UI feature, no displayed statistic. Runtime smoke test (Phase 3E): N/A --
  docs-only, no `R/`/`tests/`/`man/`/`NAMESPACE`/`data/` content touched (`git diff --stat` confirms
  only `BACKLOG.md`/`CHANGELOG.md`/`PROJECT_LEARNINGS.md`/`SESSION_NOTES.md`/`HANDOFFS.md`).
  `lintr::lint_package()`: N/A, no `.R` file touched. TDD RED/GREEN/REFACTOR: N/A throughout, per
  `CLAUDE.md`'s Development Process Contract (no code or tests involved).

### 2026-08-12 · [ad hoc] S531 Phase 0 reconcile: HANDOFFS.md S530 receipt commit: pending → e7feb28e (Session 531)
- The S530 receipt's `commit:` field was necessarily `pending` at write time (the receipt ships in
  the commit whose sha it would name) -- the same one-hop self-referential gap the S527→S528,
  S528→S529, and S529→S530 reconciles each hit before it. `CHANGELOG.md`'s own frontier was already
  `HEAD` (`e7feb28e`), so no undocumented commit gap existed; only the `HANDOFFS.md` receipt needed
  backfilling.

### 2026-08-12 · [BL-518] `BACKLOG.md` "Pedigree diagram vs kinship2 audit follow-ups" section compressed (Session 530)
- **Deliverable:** Compressed `BACKLOG.md`'s "Pedigree diagram vs kinship2 audit follow-ups" section
  (896 lines) per the S518 ledger-size housekeeping item -- the 2nd of its 2 remaining oversized
  sections (Housekeeping was compressed S529). 12 fully-resolved bulleted items (issues #131/#134/
  #135/#139, the Option 2 kinship2-parity layout's feasibility study + design + 3 implementation
  slices, the duplicate-node-arc fix, issues #143/#144) rewritten to `BACKLOG.md`'s own short-pointer
  convention; a ~375-line unbulleted S480-S500 Progress-narrative chain (Tier 1: 2 crash-bug fixes +
  the issue #145 verification spike + a stale-doc refresh; Tier 2: issues #133/#136/#137/#145, each
  design-ratified then implemented across 1-3 slices, all now closed) condensed into one ~50-line
  consolidated summary retaining every session number, ratified design-doc path, and
  `PROJECT_LEARNINGS.md` Learning cross-reference. The 4 genuinely-open items (Candidate C's connector
  idea; the node-count-off-by-one gap; the fixture-docstring-mismatch gap; the `highlightNearest`
  degree=6 bound) left untouched, plus 2 already-short resolved pointers (issue #154's crash bugs;
  the free-pass-filter reachability close-out) left as-is.
- **Verification before compressing (Learning 535's own discipline, applied to a much larger set):**
  grepped `CHANGELOG.md` for all 31 cited session numbers (S440-S500) before trusting any "See
  CHANGELOG.md" pointer. A first single-file grep returned 0 of 31 found -- traced to
  `CHANGELOG.md` having already been archived twice (`docs/archive/CHANGELOG-through-2026-08-10.md`,
  `docs/archive/CHANGELOG-through-2026-08-11.md`); re-running the grep across the live file plus
  both archive shards found all 31 present, 0 real gaps (unlike S529's Housekeeping pass, which
  found 2). `PROJECT_LEARNINGS.md` Learning 536. All Learning cross-references (410, 411, 418, 419,
  443, 449-453, 457, 470, 471, 485, 488-494, 498, 499, plus already-present 382/468) and all 11 cited
  `docs/planning|audits|research/*` file paths confirmed to resolve via direct grep.
- Net: section 896→286 lines (610 removed); `BACKLOG.md` total 2,254→1,658 (596 removed, after this
  session's own S518-item progress notes added lines back elsewhere in the file). Zero
  information loss verified by re-reading the full compressed section end-to-end before close-out.
  `BACKLOG.md`'s own S518 tracking item updated in place (not closed) -- 1 section remains
  ("Genetic-metrics PDF audit follow-ups," ~753 lines, higher-risk since issue #152's thread is still
  active), flagged as its own future session.
- Also folded in this session's own Phase 0 ledger reconcile (`HANDOFFS.md`'s S529 receipt `commit:
  pending` → `73327ca1`, see the entry below) before the priorities picker.
- Documentation checklists (citation/tutorial/`NEWS.Rmd`/`a2interactive.Rmd`/`_pkgdown.yml`): N/A --
  no exported function, no UI feature, no displayed statistic. Runtime smoke test (Phase 3E): N/A --
  docs-only, no `R/`/`tests/`/`man/`/`NAMESPACE`/`data/` content touched (`git diff --stat` confirms
  only `BACKLOG.md`/`CHANGELOG.md`/`PROJECT_LEARNINGS.md`/`SESSION_NOTES.md`/`HANDOFFS.md`).
  `lintr::lint_package()`: N/A, no `.R` file touched. TDD RED/GREEN/REFACTOR: N/A throughout, per
  `CLAUDE.md`'s Development Process Contract (no code or tests involved).

### 2026-08-12 · [ad hoc] S530 Phase 0 reconcile: HANDOFFS.md S529 receipt commit: pending → 73327ca1 (Session 530)
- The S529 receipt's `commit:` field was necessarily `pending` at write time (the receipt ships in
  the commit whose sha it would name) -- the same one-hop self-referential gap the S527→S528 and
  S528→S529 reconciles hit before it. `CHANGELOG.md`'s own frontier was already `HEAD`
  (`73327ca1`), so no undocumented commit gap existed; only the `HANDOFFS.md` receipt needed
  backfilling. Also removed a leftover `<prose pending -- filled at Phase 3D close-out>` placeholder
  line that S529's close-out never filled -- recent receipts (S527/S528) carry no separate free-text
  prose paragraph, so the placeholder was dropped rather than backfilled, matching that convention.

### 2026-08-12 · [BL-518] `BACKLOG.md` Housekeeping section compressed (Session 529)
- **Deliverable:** Compressed `BACKLOG.md`'s "Housekeeping" section (147 of the file's then-2,501
  lines' worth of scope) per the S518 ledger-size housekeeping item -- 17 of its 19 fully-resolved
  items rewritten to the file's own established short-pointer convention, full detail preserved via
  `CHANGELOG.md` pointers; the 8 genuinely-open items left untouched (verbatim, including this
  session's own compression-tracking item, updated in place with progress notes rather than closed).
- Scoped via `AskUserQuestion` after a background-agent inventory pass (full read of all 2,501
  then-current lines: 62 top-level items file-wide, 48 fully resolved, ~1,500 compressible lines
  concentrated in 3 oversized sections) -- Housekeeping chosen over top-15-file-wide /
  single-biggest-item / prep-only-fixes alternatives as the one self-contained, cleanly-bounded unit.
- **2 items had no existing `CHANGELOG.md` entry despite ending in the file's standard "See
  `CHANGELOG.md`" pointer** -- a real ledger gap (FM #27), not just verbose narrative: the
  `inst/extdata/` reorganization (Sessions 415-418) and the non-portable-filename fix (Session 497),
  see the 2 backfill entries immediately below. Backfilled both before compressing rather than
  compress to a dangling pointer. `PROJECT_LEARNINGS.md` Learning 535.
- Net: Housekeeping section 652→389 lines; `BACKLOG.md` total 2,501→2,254 (net, after this session's
  own compression-tracking item grew to record what was done and what remains). Zero information
  loss verified by re-reading the full compressed section end-to-end before close-out; all preserved
  Learning-number cross-references (384/385/417/433/440/441/461/477/480/501/505) confirmed to still
  resolve in `PROJECT_LEARNINGS.md` via direct grep.
- **`BACKLOG.md`'s own item stays open** -- 2 sections remain (`Pedigree diagram vs kinship2 audit
  follow-ups`, ~896 lines; `Genetic-metrics PDF audit follow-ups`, ~753 lines incl. the still-open
  issue #152), each flagged as its own future session per the item's original "budget it as its own
  session" guidance. Also folded in this session's own Phase 0 ledger reconcile (`HANDOFFS.md`'s
  S528 receipt `commit: pending` → `529f84f5`, see the entry below) before the priorities picker.
- Documentation checklists (citation/tutorial/`NEWS.Rmd`/`a2interactive.Rmd`/`_pkgdown.yml`): N/A --
  no exported function, no UI feature, no displayed statistic. Runtime smoke test (Phase 3E): N/A --
  docs-only, no `R/`/`tests/`/`man/`/`NAMESPACE`/`data/` content touched (`git diff --stat` confirms
  only `BACKLOG.md`/`CHANGELOG.md`/`PROJECT_LEARNINGS.md`/`SESSION_NOTES.md`/`HANDOFFS.md`).
  `lintr::lint_package()`: N/A, no `.R` file touched. TDD RED/GREEN/REFACTOR: N/A throughout, per
  `CLAUDE.md`'s Development Process Contract (no code or tests involved).

### 2026-08-12 · [ad hoc] Backfilled: `devtools::check()` non-portable-filename fix (Session 497, 2026-08-09)
- No `CHANGELOG.md` entry existed for this session's work despite `BACKLOG.md`'s own detailed
  write-up — found while compressing `BACKLOG.md`'s Housekeeping section (Session 529). Backfilled
  from that narrative, not from git archaeology.
- Owner renamed `inst/extdata/reference/Standardized Human Pedigree Nomenclature: Update and
  Assessment of the Recommendations of the Nation.html` to `inst/extdata/reference/
  pedigree_nomenclature.html` (outside a session tool call, per the file's copyright-sensitive
  handling). `devtools::check()` went from 1 error/1 warning/1 note to 0/0/0 — the vignette-engine
  NOTE (previously suspected independent) was confirmed a downstream symptom of the non-portable
  -filename ERROR derailing the check pipeline, not its own defect, via `tools::pkgVignettes(check =
  TRUE)` against both source and a built tarball.
- Incidental gap found and fixed the same session: the rename broke a `.gitignore` pattern (S479)
  that kept this copyrighted, local-only file out of git; updated to the new filename. Separately,
  `.Rbuildignore` had **never** excluded this file — or 2 other S479-gitignored copyrighted files
  (`5201430.pdf`, `bioinformatics_24_2_279.pdf`) — from the built package tarball at all
  (`.gitignore` has no effect on `R CMD build`), so all three had been shipping in every distributed
  tarball despite being deliberately kept out of git. Fixed by adding `.Rbuildignore` entries for all
  three; verified via a fresh `pkgbuild::build()` that none of the three ship while the legitimately
  -shipped `Master_Genetic_metrics_2_14_15.pdf` (S418, different copyright situation) still does.
  One stale path reference fixed (`docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`);
  `PROJECT_LEARNINGS.md` Learning 480.

### 2026-08-12 · [ad hoc] Backfilled: `inst/extdata/` reorganization Phases 1-4 (Sessions 415-418, 2026-07-28)
- No `CHANGELOG.md` entry existed for this 4-phase reorg despite each phase's own `BACKLOG.md`
  write-up ending "See `CHANGELOG.md`" — found while compressing `BACKLOG.md`'s Housekeeping section
  (Session 529). Backfilled from that narrative (plan: `docs/planning/extdata-reorganization-plan.md`,
  S414), not from git archaeology.
- **Phase 1 (S415):** relocated 24 dev-scratch/orphaned items to `dev/extdata-scratch/`; removed 3
  empty untracked dirs + `code_under_development/`; deleted 11 obsolete `.Rbuildignore` + 10 dead
  `.gitignore` lines. `devtools::check()` 0 errors/0 warnings; regression 0 failed/0 error, 3198
  passed/179 skipped.
- **Phase 2 (S416):** subfolder name `examples/` (owner-picked); `git mv`'d 10 load-bearing files
  into `inst/extdata/examples/`; updated `get_test_data_path()`, ~28 `system.file()` call sites
  across 15 test files, 7 roxygen/comment path references; regenerated `man/loadSiteConfig.Rd`.
  Regression exact baseline match; `R CMD build` tarball verified.
- **Phase 3 (S417):** fixed `offline-focal-animal-workflow.qmd`'s 2 un-migrated `system.file()`
  calls (undersold by the plan's own "what DONE looks like" text) + a stale GitHub blob URL;
  re-rendered 3 targets. `PROJECT_LEARNINGS.md` Learning 384.
- **Phase 4 (S418):** PDF placement → `inst/extdata/reference/`; re-rendered stale `README.Rmd`
  (`PROJECT_LEARNINGS.md` Learning 385). Reorg fully executed, all 4 phases DONE.

### 2026-08-12 · [ad hoc] S529 Phase 0 reconcile: HANDOFFS.md S528 receipt commit: pending → 529f84f5 (Session 529)
- Phase 0 step 6 found `HANDOFFS.md`'s S528 receipt still carried `commit: pending` — the
  established one-hop case (the receipt necessarily ships in a commit before it can name that
  commit's own sha) that S526→S527 and S527→S528 each applied to their predecessor. `CHANGELOG.md`'s
  own frontier was already `HEAD` (`529f84f5`, S528's actual final commit — the post-close-out CLI
  confirmation entry), so no undocumented-commit gap existed; only the `HANDOFFS.md` receipt itself
  needed reconciling. Backfilled `commit: 529f84f5` with a one-line note explaining why it was
  unknowable at write time. Committed separately, before this session's own claim.

### 2026-08-12 · [ad hoc] S528: fold in post-close-out CLI dry-run confirmation (599/599) (Session 528)
- A final verification pass after the S528 close-out commit (`23e69529`) advanced `CHANGELOG.md`'s
  own frontier found `methodology_trim.py`'s `P1_UNDOCUMENTED` CLI gate — which blocked the tool's
  own dry-run during this session's RED/GREEN TDD phases — had cleared. Re-ran the CLI directly:
  `[L3_OK] 599 record(s) partitioned; every one byte-identical across the move`, an exact end-to-end
  confirmation (matching the direct `fence_scan()`/`record_start` cross-check used at RED/GREEN
  time). Folded into `HANDOFFS.md`'s S528 receipt, `BACKLOG.md`'s resolved item, and
  `SESSION_NOTES.md`'s self-assessment rather than left deferred to a future session. Commit
  `6d35a192`.

### 2026-08-12 · [ad hoc] S528 close-out: methodology_trim.py `\b` regex defect fixed (Session 528)
- **Deliverable:** Fixed the `methodology_trim.py` `SESSION_NOTES.md` `LEDGERS.record_start` regex's
  trailing `\b` boundary bug (found/filed S527, `BACKLOG.md` Housekeeping, READY, Effort S). Moved
  `\b` so it guards only the `What Session \d+ Did` branch instead of sitting after the whole
  alternation — `record_start = re.compile(r"^### (?:Session \d+ Handoff Evaluation \(by Session
  \d+\)|What Session \d+ Did\b)")`. The `Handoff Evaluation (by Session N)` branch needed no `\b`
  (already ends unambiguously in `)`); the alternative fix (dropping `\b` entirely) was considered
  and rejected — it would also accept a hypothetical `"Didn't"`-style false match, which moving the
  anchor avoids.
- **TDD:** full RED→GREEN cycle, no refactor candidate (2-line diff). RED: direct `fence_scan()`/
  `record_start` cross-check (the CLI's own dry-run was blocked by an unrelated `P1_UNDOCUMENTED`
  gate on this session's own in-progress claim commit) showed 523 of 598 true headings matched (0 of
  75 "Handoff Evaluation" headings). GREEN: 598 of 598, exact — confirmed both branches match and
  the `"Didn't"`-style false-match guard remains intact (no such heading exists in the file today,
  verified via `grep`). No existing Python test suite for `methodology_trim.py` in this repo
  (matching S527's own precedent for this file) — RED/GREEN evidence captured via the tool's own
  compiled regex and `fence_scan()`, not a new test file.
- **`BACKLOG.md`:** the "record_start regex never matches Handoff Evaluation headings" item (found
  S527) converted to the "(none remaining...)" resolved form. `PROJECT_LEARNINGS.md` Learning 534
  (fix-tradeoff: move `\b` to the branch that needs it, don't drop it wholesale).
- **Deferred, owner-picked:** the actual first `--write` archive of `SESSION_NOTES.md` — a future
  session should re-run the tool's dry-run once `CHANGELOG.md` has caught up to this session's claim
  commit, confirm the partitioned count reaches the true total, and only then trust `--write`.
- Runtime smoke test: n/a — no `R/` file, no `tests/testthat/` file, no config/wiring touched; only
  `methodology_trim.py` (a Python housekeeping tool, no runtime surface in the R package),
  `SESSION_NOTES.md`, `HANDOFFS.md`, `BACKLOG.md`, `CHANGELOG.md`, `PROJECT_LEARNINGS.md` (all
  markdown). `lintr::lint_package()`: N/A, no `.R` file touched. `_pkgdown.yml`/citation/tutorial/
  `a2interactive.Rmd`/`NEWS.Rmd` checklists: all N/A — no export, no Shiny feature, no displayed
  statistic. No GitHub issue tied to this `BACKLOG.md` item (housekeeping-only, not issue-tracked).

### 2026-08-12 · [ad hoc] S528 claim: fix methodology_trim.py SESSION_NOTES.md record_start `\b` regex defect (Session 528)
- **Claim only** — `SESSION_NOTES.md` stub + `HANDOFFS.md` `status: pending` receipt committed
  (`aa4ca4a8`) before any technical work, per Phase 1B. Owner-picked fix approach (move `\b` to
  guard only the `Did` branch, over dropping it entirely or holding/reporting only) and session
  scope (fix + verify only, defer the actual `--write` archive) via `AskUserQuestion` before this
  claim. See `BACKLOG.md` Housekeeping (found S527).

### 2026-08-12 · [ad hoc] Reconcile-on-read: HANDOFFS.md S527 receipt's `commit: pending` field (Session 528)
- **Ledger reconcile (Phase 0 step 6):** `CHANGELOG.md`'s own frontier and `HANDOFFS.md`'s own
  frontier both already equal `HEAD` (`08669142`) — no undocumented commit gap. One residual: the
  same one-hop precedent S527 applied to S526's own receipt had not yet been applied to S527's own
  receipt, since S527 could not know its own close-out commit's sha at write time. Reconciled S527's
  `commit:` field to `08669142` (its own close-out commit).
- **Secondary finding, not acted on (unchanged from prior sessions' own note):** the same `commit:
  pending` placeholder remains unreconciled for older receipts (S521, S519, S518, S517, S516, S515,
  S514, S513) and the `HANDOFFS.md` ~line 215 malformed/duplicate S524 fenced-block fragment — both
  still out of this narrow reconcile step's scope, still candidates for a future `BACKLOG.md`
  housekeeping item.

### 2026-08-12 · [ad hoc] S527 close-out: fence-scanner defect fixed; a second, independent regex defect found and filed (Session 527)
- **Deliverable:** Fixed the `methodology_trim.py` fence-scanner defect blocking `SESSION_NOTES.md`'s
  first archive (`BACKLOG.md` Housekeeping, found S518). Rewrapped the one offending paragraph
  (`SESSION_NOTES.md`, then-line `:24400-24401`) so the 4-backtick inline code span no longer opens
  a physical line — a 2-line, zero-content-change edit (moved the word "backtick" to the next line;
  same words, same order). Verified: `python3 methodology_trim.py --file SESSION_NOTES.md` went
  from `173 record(s) partitioned` (RED) to `522` (GREEN) — confirmed via a direct Python
  `fence_scan()`/`record_start` cross-check that 522 is the FULL count the tool's own regex is
  capable of matching (0 missing under that regex).
- **New finding, filed not fixed (report-don't-fix-mid-session, Learning 382):** verifying the fix
  surfaced a second, independent, pre-existing defect — the `SESSION_NOTES.md` `LEDGERS` entry's
  `record_start` regex (added S518) has a trailing `\b` that can never match the "Handoff Evaluation
  (by Session N)" heading branch (always ends in `)`, a non-word char, so no word/non-word boundary
  exists at end-of-line). Confirmed: 0 of 74 real "Handoff Evaluation" headings in the file match,
  independent of fence state. Filed as a new `BACKLOG.md` Housekeeping item (found S527, READY,
  Effort S) with root cause, reproduction, and fix sketch. `PROJECT_LEARNINGS.md` Learning 533.
- **Also this session:** `HANDOFFS.md` S526 receipt's `commit: pending` field reconciled to
  `a7c4f416` (Phase 0 step 6, one-hop precedent). Ledger reconcile itself found no undocumented
  commit gap (frontiers already `HEAD`).

### 2026-08-12 · [ad hoc] S527 claim: fix the methodology_trim.py fence-scanner defect blocking SESSION_NOTES.md's first archive (Session 527)
- **Claim only** — `SESSION_NOTES.md` stub + `HANDOFFS.md` `status: pending` receipt committed
  before any technical work, per Phase 1B. Deliverable: rewrap the one offending paragraph in
  `SESSION_NOTES.md` (owner-picked approach, over patching the canonical-overlay
  `methodology_trim.py` locally); scope is fix + verify only this session, not the actual
  `--write` archive (owner-picked). See `BACKLOG.md` Housekeeping (found S518).

### 2026-08-12 · [ad hoc] Reconcile-on-read: HANDOFFS.md S526 receipt's `commit: pending` field (Session 527)
- **Ledger reconcile (Phase 0 step 6):** `CHANGELOG.md`'s own frontier and `HANDOFFS.md`'s own
  frontier both already equal `HEAD` (`a7c4f416`) — no undocumented commit gap. One residual: the
  established one-hop precedent (reconcile your immediate predecessor's `commit: pending` field to
  its real sha, applied by S526 for S524/S525) had not yet been applied to S526's own receipt, since
  S526 could not know its own close-out commit's sha at write time. Reconciled S526's `commit:` field
  to `a7c4f416` (its own close-out commit).
- **Secondary finding, not acted on (unchanged from S524's/S526's own note):** the same `commit:
  pending` placeholder remains unreconciled for 8 older receipts (S521, S519, S518, S517, S516, S515,
  S514, S513) and the `HANDOFFS.md` ~line 215 malformed/duplicate S524 fenced-block fragment — both
  still out of this narrow reconcile step's scope, still candidates for a future `BACKLOG.md`
  housekeeping item.

### 2026-08-11 · [issue #152] S526 close-out: Slice 2 (markerKinship()/markerParentageLikelihood() performance rewrite) shipped (Session 526)
- **Deliverable:** Issue #152 Slice 2, per `docs/planning/issue152-sequence-input-genetic-metrics-plan.md`
  §5 Slice 2 (D5) — `markerKinship()` rewritten from an O(n²·L) nested-pair R loop to vectorized
  matrix algebra (0/1 het/genotyped indicator matrices + a per-locus reference-allele dose
  encoding reduce every pairwise count to matrix products); `markerParentageLikelihood()`
  rewritten to precompute every locus's allele-frequency table once per call instead of once
  per (offspring, candidate, locus) triple. Both signatures/output shapes unchanged. Measured
  on the committed Slice 1 fixture (50 individuals × 1,000 loci): `markerKinship()` ~0.12-0.13s
  → ~0.07-0.09s; `markerParentageLikelihood()` (10-candidate scenario) ~0.84-0.88s → ~0.35-0.39s.
- **Verification:** 4 new `test_that` blocks (2 golden-master regression tests via
  `dput(x, control = c(..., "digits17"))` + `expect_identical()`; 2 new precedent-setting
  `system.time()`-based benchmark tests, no new dependency, with an untimed warm-up call, the
  median of 3 timed reps, and a threshold tighter than the measured pre-rewrite warm runtime —
  median-of-3 added after a single-call design flaked once in a full-suite run). Full clean
  regression 5,417 passed/0 failed/0 error (17 pre-existing warnings, unchanged), re-confirmed
  clean across 2 further solo full-suite reruns. `devtools::check()` 0 errors/0
  warnings/3 NOTEs, all 3 confirmed pre-existing (raw `Status:` line, not the printed summary,
  which undercounts by 1 — see `PROJECT_LEARNINGS.md` Learning 532). `lintr::lint_package()`
  found and fixed 9 `implicit_integer_linter` findings in the new `markerKinship.R` code, 0
  lints remaining. Zero Bioconductor dependencies re-confirmed in `DESCRIPTION`.
- **REFACTOR gate:** a real candidate (a 3rd independent instance of the
  alphabetically-first-observed-allele-as-reference idiom, now in `markerFst.R`,
  `markerParentageLikelihood.R`, and the new `markerKinship.R`) was identified and declined via
  `AskUserQuestion` as out of this slice's pre-declared file scope (touches `markerFst.R`) —
  noted in `BACKLOG.md`'s issue #152/#153 narrative for a future session.
- **Learnings:** `PROJECT_LEARNINGS.md` Learning 531 (a plain `dput()` does not always
  round-trip a double exactly; use `control = c(..., "digits17")` for golden-master captures)
  and Learning 532 (a `system.time()`-based benchmark test's pass/fail can depend on JIT
  warm-up state without an explicit untimed warm-up call; plus an independent re-confirmation
  of the `devtools::check()` NOTE-undercounting finding from Learning/BACKLOG S521).
- **Status:** DONE. Issue #152 stays open — Slice 3 (the new F_ROH metric, D6) is next, a
  separate future session per the plan's own session-boundary requirement.

### 2026-08-11 · [issue #152] S526 claim: issue #152 Slice 2 (markerKinship()/markerParentageLikelihood() performance rewrite, D5) (Session 526)
- **Deliverable:** Session claimed. Issue #152 Slice 2 -- rewrite `markerKinship()`
  (currently O(n²·L)) and `markerParentageLikelihood()` (currently O(F·C·L·n)) for genome
  scale, per `docs/planning/issue152-sequence-input-genetic-metrics-plan.md` §5 Slice 2.
  Picked from this session's own Phase 0 priorities list (owner choice via `AskUserQuestion`)
  over the `methodology_trim.py` fence-scanner fix.
- **Status:** IN PROGRESS -- claim only, no implementation yet this entry.

### 2026-08-11 · [ad hoc] Reconcile-on-read: HANDOFFS.md S524/S525 receipts' `commit: pending` fields (Session 526)
- **Ledger reconcile (Phase 0 step 6):** `CHANGELOG.md`'s own frontier and `HANDOFFS.md`'s own
  frontier both already equal `HEAD` (`686bf1b3`) — no undocumented commit gap. Two residuals: the
  established S523→S524 one-hop precedent (reconcile your immediate predecessor's `commit: pending`
  field to its real sha) was not applied by S525 for S524's own receipt, so both S524's and S525's
  receipts still carried the placeholder. Reconciled S524's to `c1e7111b` (its own close-out commit)
  and S525's to `686bf1b3` (its own close-out commit).
- **Secondary finding, not acted on:** (1) the same `commit: pending` placeholder remains
  unreconciled for 8 older receipts (S521, S519, S518, S517, S516, S515, S514, S513) — unchanged
  from S524's own note; still out of this narrow reconcile step's scope, still a candidate for a
  future `BACKLOG.md` housekeeping item. (2) `HANDOFFS.md` around line 215 has a malformed fenced
  block — an opening ` ```handoff ` for S524 with no closing ` ``` ` before a second ` ```handoff `
  opens the real S524 block a few lines later (lines 215–235 are an orphaned, truncated duplicate
  fragment of the same receipt). Not fixed here — a content-integrity repair, not a ledger-frontier
  gap; flagged for the user/a future session to decide how to handle.

### 2026-08-11 · [issue #152] S525 close-out: Slice 1 (sequence ingestion + fixture) shipped (Session 525)
- **Deliverable:** Issue #152 Slice 1, per `docs/planning/issue152-sequence-input-genetic-metrics-plan.md`
  §5 Slice 1. New script-callable `checkSequenceGenotypeFile(genotype, locusMetadata = NULL,
  maxLoci = 50000L)` (`R/checkSequenceGenotypeFile.R`): same structural rules as
  `checkMarkerGenotypeFile()` (4 columns, id-first, no duplicate id x locus, biallelic-only), plus
  two new rules -- a literal `"."` (VCF missing-genotype placeholder) allele value is rejected
  before the biallelic count check runs, so the error is specific rather than misleading; and a
  locus count above `maxLoci` (default `50000L`, D1's scope-tier ceiling) triggers `warning()`,
  not `stop()`. Returns the checked dataframe, matching the established 3-for-3 sibling-validator
  convention rather than the plan's own since-superseded "TRUE invisibly" interface-catalog
  wording (PRE-RED `AskUserQuestion`, all 4 recommended options chosen). Reuses `checkLocusMetadata()`
  (already shipped as issue #153 Slice 1, S520) for the optional `locusMetadata` sidecar rather
  than reimplementing it -- a genuine PRE-RED discovery that the plan's own "Touches" list, written
  before issue #153 shipped, was stale relative to the live tree (`PROJECT_LEARNINGS.md` Learning
  528). New `data-raw/generate_sequence_fixtures.R` (seeded `set_seed(152L)`) generates a
  50-individual x 1,000-locus synthetic biallelic SNP panel across 20 chromosomes with ~2%
  missingness, plus a 100%-"full"-coverage `locusMetadata` sidecar (deliberately not issue #153's
  own sparse-mix convention -- reused by the future Slice 2 benchmark and Slice 3's F_ROH metric),
  committed as `inst/extdata/examples/example_sequence_genotypes.csv` /
  `example_sequence_locus_metadata.csv`.
- **Verification:** 18 new `test_that` blocks, 0 regressions. Full clean regression 5,408 passed/0
  failed/0 error (17 pre-existing warnings, all traced to 4 unrelated pre-existing test blocks --
  `test_appServer_server.R`, `test_modMarkerGenetics.R` x3 -- none new). `devtools::check()` 0
  errors/0 warnings/3 NOTEs, all 3 independently confirmed pre-existing (top-level files;
  vignettes/figure leftover; the known ~69-70-word spelling-WORDLIST gap, direct diff confirmed
  zero flagged words trace to this session's own files). `lintr::lint_package()` 0 lints on
  touched files (1 line-length + 1 `stopifnot_all_linter` finding fixed). `_pkgdown.yml`
  reference-coverage guard fixed (new export added to the catch-all group). `inst/WORDLIST` gained
  `GBS`/`VCF`/`VCF's`/`VCFtools`/`Danecek` (the Danecek et al. 2011 VCF citation was trimmed to
  "et al." rather than all ~12 co-authors, matching this codebase's own `MacCluer JW, et al.`
  precedent -- `PROJECT_LEARNINGS.md` Learning 530). `NEWS.Rmd`/`NEWS.md` terse entry added,
  deliberately matching the pre-1.0.8 style. REFACTOR gate: a real candidate was identified
  (`checkMarkerGenotypeFile()`'s structural-check logic is now duplicated a 3rd time) and
  explicitly declined via `AskUserQuestion` as out of this slice's pre-declared file scope --
  noted in `BACKLOG.md`'s narrative for a future session. `PROJECT_LEARNINGS.md` Learnings
  528-530 (the stale-plan-deliverable discovery; a full-suite-only test flake traced to concurrent
  Rscript diagnostic processes, not a real regression; the multi-author-citation-vs.-WORDLIST-cost
  finding). Runtime smoke test: n/a -- script-callable only, no Shiny wiring this slice. Issue
  #152 stays open -- Slice 2 (the `markerKinship()`/`markerParentageLikelihood()` performance
  rewrite, D5) is next.

### 2026-08-11 · [issue #152] S525 claim: issue #152 Slice 1 (sequence ingestion + fixture) (Session 525)
- **Deliverable:** Session claimed. Issue #152 Slice 1 -- `checkSequenceGenotypeFile()` (D2/D4),
  reusing the already-shipped `checkLocusMetadata()` (D3, shipped as issue #153 Slice 1) for the
  locus-metadata sidecar, plus a new `data-raw/` fixture-generation script and its committed
  `inst/extdata/examples/` CSV pair, per `docs/planning/issue152-sequence-input-genetic-metrics-plan.md`
  §5 Slice 1. Picked from this session's own Phase 0 priorities list (owner choice via
  `AskUserQuestion`) over 3 other candidates (the `methodology_trim.py` fence-scanner fix,
  `a2interactive.Rmd` documentation pass, `inst/WORDLIST` spelling gap).
- **Status:** IN PROGRESS -- claim only, no implementation yet this entry.

### 2026-08-12 · [issue #153] S524 close-out: Slice 5 (full module tab, wiring, documentation) shipped -- issue #153 closed (Session 524)
- **Deliverable:** Issue #153 Slice 5, per `docs/planning/issue153-linkage-haplotype-block-metrics-plan.md`
  §5 Slice 5 -- the final slice in this issue's 5-slice family. A sixth "Linkage and LD Block
  Metrics" tab in `R/modMarkerGenetics.R` (D5, D6): a locus-metadata coverage report
  (`checkLocusMetadata()`, Slice 1, three-tier full/partial/none classification); the primary,
  pedigree-valid Realized Relatedness Variance table (`markerRealizedRelatednessVariance()`, Slice 3,
  rhesus-macaque-default nChr/mapLength inputs); the secondary, descriptive LD Block Statistic table
  (`markerLdBlock()`, Slice 4) behind a persistent, non-dismissable caveat banner; and
  curator-controlled export wiring for the LD-block table (`obfuscateLdBlocks()`, D9) reusing issue
  #150's confirm-gate pattern (Generate Preview -> Confirm -> Confirm-OK).
- **Design correction (found via GREEN implementation, owner-confirmed via `AskUserQuestion`):** the
  PRE-RED plan to reuse the existing `genotypeFile` upload (re-validated through the
  multiallelic-tolerant sibling validator) was reverted in favor of a dedicated `linkageGenotypeFile`
  input -- Shiny mounts every `tabPanel`'s output bindings regardless of which tab is visible, so a
  multiallelic upload fed through the shared input broke the other 5 tabs' own DT outputs
  simultaneously (confirmed via RED test failures, not assumed). See `PROJECT_LEARNINGS.md`
  Learning 526.
- **Verification:** Full strict TDD PRE-RED->RED->GREEN cycle (REFACTOR: no candidate identified),
  each transition `AskUserQuestion`-gated. 18 new `test_that` blocks / `test_moduleContract.R`
  updated for 5 new returned reactives (`locusMetadataTable`, `realizedRelatednessTable`,
  `ldBlockTable`, `ldBlockExportTable`, `ldBlockExportConfirmed`). Full clean regression 0 failed/0
  error; `devtools::check()` 0 errors/0 warnings/2 pre-existing NOTEs (vignettes/figure leftover,
  spelling-WORDLIST gap); `lintr::lint_package()` 0 lints. Live runtime smoke test (Phase 3E) via
  Chrome browser automation against the real running app and the Slice 1 STR fixture: coverage
  report ("8 full, 2 partial, 2 none"), LD-block Dprime/r2 values matching the hand-verified test
  reference exactly, the founders-only restriction guard (table correctly goes not-ready when
  checked with no pedigree loaded, recovers when unchecked), and the export guidance state -- 0
  console errors throughout.
- **Documentation:** `NEWS.Rmd`/`NEWS.md` entry (rendered via `rmarkdown::render()`); new
  `colony-manager-guide.qmd` "Linkage and LD Block Metrics" subsection with 2 new screenshots
  (Session 436 tutorial/article checklist -- first Shiny-UI slice in this issue family); citation
  checklist (issue #120) already satisfied at Slices 3/4, reconfirmed, no new formula this slice;
  `_pkgdown.yml` unchanged (no new exports). `PROJECT_LEARNINGS.md` Learnings 526 (the
  tabPanel-eager-rendering finding) and 527 (the `BACKLOG.md` narrative-staleness finding).
  `BACKLOG.md` issue #153 narrative backfilled for S521-S523 (each never added its own Progress
  entry) and closed out with this session's own entry.
- **Issue #153 closed** -- all 5 slices now shipped (Slice 1: S520, Slice 2: S521, Slice 3: S522,
  Slice 4: S523, Slice 5: this session).

### 2026-08-12 · [issue #153] S524 claim: issue #153 Slice 5 (full module tab, D5/D6/D9) (Session 524)
- **Claim:** Phase 1B session claim for Issue #153 Slice 5 -- full module tab in
  `modMarkerGenetics.R` (D5/D6): UI coverage-report panel + persistent D3(b) caveat banner,
  curator-controlled export wiring reusing issue #150's confirm-gate pattern (D9),
  `test_moduleContract.R` coverage, tutorial/article update. Per
  `docs/planning/issue153-linkage-haplotype-block-metrics-plan.md` §5 Slice 5. Picked from this
  session's own Phase 0 priorities list (owner choice via `AskUserQuestion`) over 3 other
  candidates (issue #152 Slice 1, the `methodology_trim.py` fence-scanner fix, `HANDOFFS.md`'s
  own archive). Work beginning -- PRE-RED research next.

### 2026-08-11 · [ad hoc] Reconcile-on-read: HANDOFFS.md S523 receipt's `commit: pending` field (Session 524)
- **Ledger reconcile (Phase 0 step 6):** `CHANGELOG.md`'s own frontier (`git log -1` on this file)
  and `HANDOFFS.md`'s own frontier both already equal `HEAD` (`905f20bf`) — no undocumented commit
  gap since S523's close-out. The one residual: S523's own `HANDOFFS.md` receipt still carried
  `commit: pending` (legal at write time — the receipt ships in the very commit whose sha it would
  name) and, per the established S522→S523 precedent, had not yet been reconciled to its real sha
  by a subsequent session. Reconciled to `905f20bf`.
- **Secondary finding, not acted on:** the same `commit: pending` placeholder is still unreconciled
  for 8 older receipts (S521, S519, S518, S517, S516, S515, S514, S513) — the one-hop
  reconcile-your-immediate-predecessor pattern established by S523→S522 has not been consistently
  applied further back. Surfaced in this session's Phase 0 report; not fixed here (an 8-receipt
  editorial sweep is out of this reconcile step's narrow scope). A future session may want to file
  it as its own `BACKLOG.md` housekeeping item.

### 2026-08-12 · [issue #153] S523 close-out: Slice 4 (LD block statistic + de-identification primitive) shipped (Session 523)
- **Deliverable:** Issue #153 Slice 4, per `docs/planning/issue153-linkage-haplotype-block-metrics-plan.md`
  §5 Slice 4 — new script-callable `markerLdBlock()`, a descriptive, same-chromosome pairwise
  LD/block statistic (D3b), plus `obfuscateLdBlocks()`, its de-identification sidecar (D8/D9).
- **Research:** found a distinct gap Dragon 3 doesn't name — classical D′/r² formulas assume phased
  haplotype data, but this package's genotype matrix is unphased. Verified (3 independent numeric
  checks, not algebra alone) a two-locus multiallelic maximum-likelihood (EM) phase-frequency
  estimator — Excoffier & Slatkin (1995)'s biallelic algorithm generalized to arbitrary allele
  counts, matching the `genetics` package's own documented approach: exact match on a
  phase-resolvable toy set; recovered a known true D within 2% on a 600-individual random-mating
  simulation with 209 phase-ambiguous double heterozygotes; recovered a known 3×3 multiallelic
  joint table within ~0.017 absolute error at n=800. Aggregates via Hedrick's (1987) D′ and a
  chi-squared/Cramér's-φ²-style r², both proven (algebraically and numerically) to reduce exactly
  to classic biallelic values. An earlier composite/Burrows'-LD attempt was abandoned after its own
  toy-example validation came out inconsistent, traced to the toy fixture (not the formula)
  violating the random-mating assumption the identity needs.
- **Verification:** 16 new `test_that` blocks (12 + 4) / 38 expectations across
  `tests/testthat/test_markerLdBlock.R` and `tests/testthat/test_obfuscateLdBlocks.R`, reusing the
  Slice 1 STR fixture (no new fixture). Full clean regression suite 0 failed/0 error;
  `devtools::check()` 0 errors/0 warnings/3 NOTEs, all confirmed pre-existing (hand-added 9 new
  words to `inst/WORDLIST`); `lintr::lint_package()` 0 lints (fixed 14 introduced during GREEN).
  Fixed along the way: a pair-list-flattening bug, a missing `utils::combn()` namespace prefix, and
  a bare-apostrophe-inside-`\code{}` defect that broke `tools::parse_Rd()` for the whole file.
  Fixed the `_pkgdown.yml` reference-coverage guard.
- **Citation checklist (issue #120):** done this slice — `inst/extdata/ui_guidance/population_genetics_terms.html`
  and roxygen `@references` both updated (Excoffier & Slatkin 1995, Hedrick 1987, Weir 1996).
- **Housekeeping:** `NEWS.Rmd`/`NEWS.md` updated (rendered via `rmarkdown::render()`).
  `PROJECT_LEARNINGS.md` Learnings 524 (the unphased-data/composite-vs-EM research finding) and 525
  (the `\code{}`-apostrophe Rd-parser gotcha) added. `BACKLOG.md`'s `a2interactive.Rmd`
  documentation-pass housekeeping item updated to include the 2 new functions. Tutorial/article
  checklist (Session 436) not-yet-applicable — no UI this slice. Issue #153 stays open — Slice 5
  (full module tab, wiring, documentation) is next.
- **Ledger:** this entry plus the reconcile backfill and claim entries above.

### 2026-08-11 · [issue #153] S523 claim: issue #153 Slice 4 (markerLdBlock() + obfuscateLdBlocks(), D3b/D8/D9) (Session 523)
- **Deliverable:** Issue #153 Slice 4 per `docs/planning/issue153-linkage-haplotype-block-metrics-plan.md`
  §5 Slice 4 — the descriptive LD/haplotype-block statistic (`markerLdBlock()`, D3b) plus the
  `obfuscateLdBlocks()` de-identification primitive (D8/D9). D3(b) is an explicit, documented
  statistical compromise (no rigorous pedigree-aware LD-block method exists CRAN-side) — this
  slice's own PRE-RED must re-read §7 Dragon 3 before RED, not just reuse Slice 3's resolved
  formula-derivation pattern.
- **Picked from Phase 0 priorities list** (owner choice via `AskUserQuestion`) over 3 other
  candidates: issue #152 Slice 1, the `methodology_trim.py` fence-scanner fix, `BACKLOG.md`
  compression.
- **Ledger:** this entry only.

### 2026-08-11 · [issue #153] Backfilled (reconcile-on-read): undocumented commit 25606464 — S522 close-out finalization
- **Provenance:** Session 522's own final commit (`25606464`, "docs: S522 close-out -- record
  renv.lock finding (Learning 523, HANDOFFS, SESSION_NOTES)") touched only `HANDOFFS.md`,
  `PROJECT_LEARNINGS.md`, and `SESSION_NOTES.md` — not `CHANGELOG.md` — so it fell outside this
  ledger's own frontier (`git log -1 -- CHANGELOG.md` stayed at the prior `d920813e`). Found by
  Session 523's Phase 0 reconcile.
- **What it did:** finalized the `HANDOFFS.md` `S522` receipt (filled in the full commit list and
  expanded gotchas #5/#6 for the two out-of-band regressions), added the `S522c (ad hoc,
  reconciled)` block for `c18b7fd6`, and recorded `PROJECT_LEARNINGS.md` Learning 523 (a
  concurrent, mid-session out-of-band commit lands invisibly to Phase 0's reconcile since it
  postdates orientation — re-check `git log` before your own final close-out commit, not only at
  Phase 0). All substance already narrated in the `[ad hoc]` backfill and fix entries immediately
  below and above this one; this entry exists to close the ledger frontier gap, not to add new
  facts.
- **Ledger:** this backfill entry only.

### 2026-08-11 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit c18b7fd6 — renv.lock/pyramid-image change
- **Provenance:** a second out-of-band commit, `c18b7fd6` ("update renv.lock pyramid image", author R. Mark
  Sharp, 2026-08-11 17:49:45), landed mid-session between this session's own ledger-reconcile-backfill
  commit and its claim commit — after Phase 0's orientation had already captured `HEAD`, so invisible
  to that reconcile pass. Found only when reviewing `git log` before this session's own final commit.
- **What it did:** `renv.lock` — 2505 deletions, removing every `Suggests`-only package (and their
  transitive dependencies) from the lockfile. `vignettes/figure/plot-focal-age-sex-pyramid-1.png` —
  added a new committed image (the file `devtools::check()`'s "leftover from knitr" NOTE already flags).
- **Diagnosis:** confirmed via `renv::status(dev = TRUE)` — 60+ packages (`testthat`, `devtools`,
  `roxygen2`, `pkgdown`, `mockery`, `shinytest2`, `shinyBS`, `quarto`, `spelling`, and transitive
  deps like `pkgload`/`chromote`/`brew`/`brio`) showed `installed=y, recorded=n, used=y` — exactly
  the failure mode `CLAUDE.md`'s Build/Test/Verify section documents: `renv/settings.json`'s
  `snapshot.type: "explicit"` means a plain `renv::snapshot()` (no `dev = TRUE`) only scans
  `DESCRIPTION`'s `Imports`/`Depends`, silently dropping every `Suggests`-only package.
- **Ledger:** this backfill entry; the fix is recorded in its own entry below.

### 2026-08-11 · [ad hoc] Fix: restore renv.lock via renv::snapshot(dev = TRUE) (Session 522)
- **Fixed** the regression backfilled above: ran `renv::snapshot(dev = TRUE, prompt = FALSE)`,
  restoring all 60+ missing `Suggests`-only packages and transitive dependencies to `renv.lock`.
  Verified via `renv::status(dev = TRUE)`: "No issues found -- the project is in a consistent
  state." (Plain `renv::status()` still reports these as `used=n` — expected and documented:
  it only checks against `Imports`/`Depends`, not `Suggests`.) Committed separately from Slice 3's
  own commits, owner-confirmed via `AskUserQuestion`.
- **Ledger:** this entry only.

**Archived 11 record(s), 2026-08-10 → 2026-08-11** into [`docs/archive/CHANGELOG-through-2026-08-11.md`](../../docs/archive/CHANGELOG-through-2026-08-11.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-08-11.md.verify.sh`](../../docs/archive/CHANGELOG-through-2026-08-11.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

### 2026-08-11 · [issue #153] S522 close-out: Slice 3 (realized-relatedness-variance metric) shipped (Session 522)
- **Deliverable:** Issue #153 Slice 3, per `docs/planning/issue153-linkage-haplotype-block-metrics-plan.md`
  §5 Slice 3 — new script-callable `markerRealizedRelatednessVariance()`, estimating the variance
  of *actual* (realized) relatedness around a pair's pedigree-expected value for Parent-Offspring,
  Full-Siblings, and Half-Siblings pairs (D3a), per the closed-form solution of Hill & Weir (2011).
  Reuses `kinship()`/`convertRelationships()` rather than a new framework; other relationship
  categories return `NA`, not an error.
- **Process:** Full strict TDD PRE-RED→RED→GREEN→REFACTOR cycle, each transition
  `AskUserQuestion`-gated (REFACTOR: no candidate identified). PRE-RED derived/verified the Hill &
  Weir formula via 4 targeted literature-extraction passes cross-checked for internal consistency,
  then numerically validated against the paper's own published Table 2 (human genome, 22
  chromosomes) — all 3 relationship-type SDs within ~2%, closing out the design doc's §7 Dragon 4
  research risk.
- **Verification:** 9 new `test_that` blocks / 33 expectations in
  `tests/testthat/test_markerRealizedRelatednessVariance.R`, reusing `smallPed`'s existing known
  Full-Siblings/Half-Siblings/Parent-Offspring pairs (no new fixture). Full clean regression suite
  0 failed/0 error (5294 passed = 5261 baseline + 33 new, 15 pre-existing warnings unchanged);
  `devtools::check()` 0 errors/0 warnings/3 NOTEs, all confirmed pre-existing; `lintr::lint_package()`
  0 lints (fixed 16 introduced during GREEN: a `commented_code_linter` false positive on a
  math-notation comment via a documented `# nolint` block, 13 `implicit_integer_linter`, 1
  `unnecessary_lambda_linter`). Fixed the `_pkgdown.yml` reference-coverage guard.
- **Citation checklist (issue #120):** done this slice, per the design doc's own explicit
  Slice-3 obligation — `inst/extdata/ui_guidance/population_genetics_terms.html` and roxygen
  `@references` both updated with the Hill & Weir (2011) citation.
- **Housekeeping:** hand-added 3 words (`IBD`, `WG`, `autosome`) to `inst/WORDLIST` in collation
  order (S230 convention) — the 3 this session's own new file introduced that are genuine terms;
  reworded a 4th (`eqn` → `equation`) in roxygen prose rather than adding the abbreviation.
  `NEWS.Rmd`/`NEWS.md` updated. `PROJECT_LEARNINGS.md` Learning 522 added (the formula-verification
  methodology: numeric reproduction of a paper's own published table, not algebra alone, is what
  actually closes out a "derive/verify before RED" research risk). Owner-directed: added a
  `BACKLOG.md` item to simplify `NEWS.Rmd` entries back toward pre-1.0.8 terseness, and a
  `BACKLOG.md` item enumerating the `a2interactive.Rmd` documentation-pass gap (7 functions shipped
  since S478 with no coverage). Tutorial/article checklist (Session 436) not-yet-applicable — no
  UI this slice. Issue #153 stays open — Slice 4 (`markerLdBlock()`/`obfuscateLdBlocks()`, D3b/
  D8/D9) is next.
- **Ledger:** this entry plus the 3 other S522 entries above (ledger-reconcile backfill, claim,
  vignette-engine `[ad hoc]` fix).

### 2026-08-11 · [ad hoc] Fix: revert a2interactive.Rmd VignetteEngine to rmarkdown_notangle (Session 522)
- **Found:** the out-of-band commit `79f37e18` (backfilled above) changed `a2interactive.Rmd`'s
  `VignetteEngine` from `knitr::rmarkdown_notangle` to `knitr::knitr`, which broke
  `devtools::check()`: `R CMD build`'s vignette-rebuild step fails at the
  `pedigree-diagram-render` chunk with `Error in path.expand(): invalid 'path' argument` (via
  `knitr:::html_screenshot()`).
- **Isolated via 4 back-to-back `devtools::check()` runs**, alternating only that one YAML line:
  `knitr::knitr` → FAIL, `knitr::knitr` → FAIL (rules out a one-off flake), `rmarkdown_notangle` →
  PASS (0 errors/0 warnings/3 NOTEs, matches the established S521 baseline), `knitr::knitr` → FAIL
  again. `a3manual.Rmd`'s own unrelated `knitr::knitr` (unchanged since 2020) builds fine every
  run, so the engine name itself isn't universally broken in this environment.
- **Fix:** reverted the one YAML line (commit `5bfad100`), separate from Slice 3's own commits.
  The `.Rbuildignore` additions from `79f37e18` are untouched — unrelated, not evidenced as wrong.
- **Ledger:** this entry only.

### 2026-08-11 · [issue #153] S522 claim: issue #153 Slice 3 (markerRealizedRelatednessVariance(), D3a) (Session 522)
- **Deliverable:** Issue #153 Slice 3 per `docs/planning/issue153-linkage-haplotype-block-metrics-plan.md`
  §5 Slice 3 — the realized-relatedness-variance metric (D3a). This slice's own PRE-RED must first
  derive/verify the Hill & Weir (2011) closed-form variance formula (§7 Dragon 4) before RED tests
  can be written.
- **Status:** Claimed. Work beginning.
- **Ledger:** this entry only so far; the close-out entry follows at Phase 3F.

### 2026-08-11 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit 79f37e18 — corrected .Rbuildignore and vignette engine in a2interactive.Rmd
- **Provenance:** out-of-band commit `79f37e18` (2026-08-11 17:37:14, author R. Mark Sharp), landed 7
  minutes after S521's own close-out commit `7ab01312` (17:30:38) with no Phase 1B claim stub, no
  `SESSION_NOTES.md` entry, and no `HANDOFFS.md` receipt — found by Session 522's Phase 0 reconcile
  (`CHANGELOG.md`/`HANDOFFS.md` frontiers both at `7ab01312`, one-commit gap to `HEAD`).
- **What it did:** `.Rbuildignore` — added 3 new ignore patterns (`FRAMEWORK_LEARNINGS.md`,
  `methodolog_trim.py` — note: missing the "y" in "methodology", likely a typo that will not match
  the real `methodology_trim.py` filename — and `__pycache__`). `vignettes/a2interactive.Rmd` —
  changed the `vignette:` YAML engine directive from `knitr::rmarkdown_notangle` to `knitr::knitr`
  and reformatted it from a single escaped-newline string to a block scalar (`>`).
- **Ledger:** this backfill entry only; no other action recorded for this commit.

### 2026-08-11 · [issue #153] S521 close-out: Slice 2 (multiallelic-tolerant ingestion validator) shipped (Session 521)
- **Deliverable:** Issue #153 Slice 2, per `docs/planning/issue153-linkage-haplotype-block-metrics-plan.md`
  §5 Slice 2 — new script-callable `checkLinkageMarkerGenotypeFile()`, a sibling to
  `checkMarkerGenotypeFile()`: retains its column-count, `id`-first-column, and duplicate-row
  checks verbatim, deliberately omits the `>2`-distinct-alleles-per-locus rejection so real
  multiallelic colony marker panels (STR panels) can be ingested. Zero edits to any existing
  file — confirmed via `grep` that `checkMarkerGenotypeFile()` is called only from
  `R/modMarkerGenetics.R`'s Shiny upload handlers, not from `markerKinship()`/
  `buildMarkerGenotypeMatrix()` or any other marker function, so the existing biallelic contract
  is untouched by construction.
- **Process:** Full strict TDD PRE-RED→RED→GREEN→REFACTOR cycle, each transition
  `AskUserQuestion`-gated (REFACTOR: owner declined the extract-shared-helper option, matching
  the existing `checkMarkerGenotypeFile()`/`checkGenotypeFile()` sibling-validator precedent).
- **Verification:** 7 new `test_that` blocks / 12 expectations in
  `tests/testthat/test_checkLinkageMarkerGenotypeFile.R`, including a fixture-scale proof that the
  committed STR fixture is accepted by the new validator and still rejected by the old one. Full
  clean regression suite 0 failed/0 error (5261 passed = 5249 baseline + 12 new, 15 pre-existing
  warnings unchanged); `devtools::check()` 0 errors/0 warnings/3 NOTEs, all confirmed pre-existing
  via direct verification (moved this session's new files out of the tree entirely and re-ran
  `spelling::spell_check_package()`: a 69–71-word `inst/WORDLIST` gap already existed before this
  session touched anything). `lintr::lint_package()` 0 lints. Fixed the `_pkgdown.yml`
  reference-coverage guard. Found and fixed a real bug in this session's own `@examples` block
  (duplicate `id x locus`, caught by `R CMD check`'s example-execution step, not the test suite).
- **Housekeeping:** hand-added 2 words (`validator`, `multiallelic`) to `inst/WORDLIST` in
  collation order (S230 convention) — the 2 this session's own new file is responsible for; filed
  the remaining 69-word pre-existing gap as a new `BACKLOG.md` Housekeeping item rather than
  fixing it mid-slice. `PROJECT_LEARNINGS.md` Learning 520 added: `devtools::check()`'s abbreviated
  `❯`-bullet results table omits a bullet for the spelling-check NOTE step, so S520's own
  "1 pre-existing note" close-out claim was an undercount (confirmed via `git log` that S520 never
  touched any of the 69 flagged-word files) — a shared, easy-to-make mistake, not a fabrication.
  `NEWS.Rmd`/`NEWS.md` updated (caught and fixed a line-wrap rendering artifact in the first
  render). Citation checklist (issue #120) and tutorial/article checklist (Session 436) do not yet
  apply — no UI/displayed statistic this slice. Issue #153 stays open — Slice 3
  (`markerRealizedRelatednessVariance()`, D3a) needs its own Hill & Weir (2011) formula derivation
  first (§7 Dragon 4) before RED can begin.
- **Ledger:** this entry plus the S521 claim entry below.

### 2026-08-11 · [issue #153] S521 claim: issue #153 Slice 2 (multiallelic-tolerant ingestion validator) (Session 521)
- **Deliverable:** Session claimed. `checkLinkageMarkerGenotypeFile()` (design D4), per
  `docs/planning/issue153-linkage-haplotype-block-metrics-plan.md` §5 Slice 2 — proven against
  Slice 1's committed STR fixture, plus a regression proof that `checkMarkerGenotypeFile()`/
  `markerKinship()`'s existing biallelic contract stays untouched. Full strict TDD cycle to follow.
- **Ledger:** this entry; close-out entry to follow at Phase 3F.

### 2026-08-11 · [issue #153] S520 close-out: Slice 1 (locus-metadata ingestion + coverage validator + STR fixture) shipped (Session 520)
- **Deliverable:** Issue #153 Slice 1, per `docs/planning/issue153-linkage-haplotype-block-metrics-plan.md`
  §5 Slice 1 — new script-callable `checkLocusMetadata()` (validates a `locus, chrom, pos[, cM]`
  sidecar table, classifying each locus into D2's three-tier coverage definition: "full"
  chrom+pos present, cM optional; "partial" exactly one of chrom/pos; "none" neither) plus a new
  committed multiallelic STR fixture pair (`inst/extdata/examples/example_locus_metadata.csv` /
  `example_str_marker_genotypes.csv`, generated by `data-raw/generate_str_fixtures.R`) — the
  package's first bundled long-format multiallelic marker fixture at any scale.
- **Process:** Full strict TDD PRE-RED→RED→GREEN→REFACTOR cycle, each transition
  `AskUserQuestion`-gated (REFACTOR: owner-confirmed no candidate identified, matching the S515
  precedent). This session authored the canonical `locusMetadata` validator since #152's own
  Slice 1 has not shipped yet (design doc §7 Dragon 1's own predicted ordering risk).
- **Verification:** 10 new `test_that` blocks / 16 expectations in
  `tests/testthat/test_checkLocusMetadata.R`, including a fixture-scale proof that the existing,
  unmodified `buildMarkerGenotypeMatrix()` pivots multiallelic genotypes without error (D4's
  structural claim, empirically confirmed). Full clean regression suite 0 failed/0 error (5249
  passed, 15 pre-existing warnings unchanged); `devtools::check()` 0 errors/0 warnings/1
  pre-existing note; `lintr::lint_package()` 0 lints on touched files. Fixed the `_pkgdown.yml`
  reference-coverage guard. `NEWS.Rmd`/`NEWS.md` updated. Citation checklist (issue #120) and
  tutorial/article checklist (Session 436) do not yet apply — no UI/displayed statistic this
  slice, matching the #146/#149/#150/#151 Slice-1-only precedent. Issue #153 stays open — Slice 2
  (the multiallelic-tolerant `checkLinkageMarkerGenotypeFile()` ingestion path) is next.

### 2026-08-11 · [issue #153] S520 claim: issue #153 Slice 1 (locus-metadata ingestion + coverage validator + STR fixture) (Session 520)
- **Deliverable:** Session claimed via Phase 1B stub (`SESSION_NOTES.md`) and `HANDOFFS.md`
  `status: pending` receipt, commit `619480fa`. Picked from this session's own Phase 0 priorities
  list (owner choice via `AskUserQuestion`) as the first of two directly-pickable implementation
  options named in S519's own `HANDOFFS.md` `next_steps` (#153 Slice 1 or #152 Slice 1 — both
  designs ratified).

### 2026-08-11 · [issue #153] S519 close-out: linkage-aware/haplotype-block metrics design ratified (Session 519)
- **Deliverable:** Pre-RED design/architecture document for issue #153 (linkage-aware and
  haplotype-block metrics for marker data) — `docs/planning/issue153-linkage-haplotype-block-metrics-plan.md`.
  Design-only, zero `R/`/`tests/`/`man/` changes, matching the #133/#136/#137/#145/#146/#147/#149/
  #150/#151/#152 precedent. Picked from this session's own Phase 0 priorities list as the next
  Deferred-tier item in the ratified genetic-metrics sequencing order (#152 done → #153 → #148).
- **Research:** two parallel background agents (codebase inventory: confirmed no marker function
  treats loci as ordered/positioned anywhere in `R/`; confirmed `R/checkMarkerGenotypeFile.R:68-78`
  hard-rejects multiallelic loci; read #152's plan in full for its `locusMetadata` schema to reuse;
  domain research: locus-order metadata realism for real colony STR panels — de Groot et al. 2025's
  23-microsatellite colony panel has essentially no cM data and is multiallelic; classical LD/
  haplotype-block methods assume an unrelated/randomly-mating sample, violated by a pedigreed
  colony per Excoffier & Slatkin 1998, while the one genuinely pedigree-native method — Lander-Green
  multipoint IBD/MERLIN — isn't CRAN-available; Hill & Weir 2011's realized-relatedness-variance
  framework IS valid for a pedigreed sample; haplotype/block-level data is more re-identifying than
  single-locus data per Lin, Owen & Altman 2004 and Erlich & Narayanan 2014), plus direct
  re-verification of the two most load-bearing findings this session.
- **9 design decisions (D1-D9)**; 4 genuine judgment calls (D3 metric choice, D4 multiallelic
  ingestion, D5 module boundary, D8 CRAN-vs-hand-roll) ratified via a single `AskUserQuestion`
  round — owner selected the document's own recommended option in all four: build both a
  pedigree-valid primary metric (Hill & Weir-style) and a caveated descriptive secondary metric
  (pairwise D′/r²); add a new multiallelic-tolerant sibling ingestion validator; a new tab inside
  the existing `modMarkerGenetics.R`; hand-roll the D′/r² computation, no new CRAN dependency.
  Scoped as 5 future implementation slices, each its own future session.
- **Issue #153 intentionally left open** — design ratified, not implemented, matching every
  precedent in this cluster. Next in the ratified order: #148 (MHC), which needs its own
  scope-narrowing conversation first per the sequencing audit's Finding #4.
- Cross-reference verification: all 27 cited file paths confirmed to exist via direct checks before
  close-out.
- Model: Claude Sonnet 5.

### 2026-08-11 · [issue #153] Claimed S519 (issue #153 Pre-RED design/architecture document) (Session 519)
- Claimed the session (commit `a11b489f`) for the next Deferred-tier item in the ratified
  genetic-metrics sequencing order, per S517's own handoff `next_steps` and the sequencing audit's
  own stated ordering (#152 done → #153 → #148). Wrote the Phase 1B `SESSION_NOTES.md` stub and
  opened the `HANDOFFS.md` `status: pending` receipt.
- Model: Claude Sonnet 5.

### 2026-08-11 · [ad hoc] S518 close-out: SESSION_NOTES.md archive blocked (fence-scanner defect found), 2 BACKLOG.md follow-ups filed, 3 CLAUDE.md checklist notes added (Session 518)
- **SESSION_NOTES.md's own archive was investigated in full but NOT run**: independently tested `methodology_trim.py`'s `fence_scan()` against the real file (after the config from the prior entry checked out structurally) and found a legitimate 4-backtick inline code span at `SESSION_NOTES.md:23229` is misread as an unclosed block-fence opener, putting 42% of the file (17,040/40,269 lines) into a false "inside a fence" state and hiding 349 of 513 real record headings -- provably lossless if trimmed as-is (L1/L2/L3 still hold on whatever partition is computed) but structurally wrong (real per-session boundaries collapse into one oversized chunk). Not fixed this session: the fix is either editing frozen historical `SESSION_NOTES.md` content or patching the canonical tool's fence-scanning regex, both out of a housekeeping session's scope. Filed as a `BACKLOG.md` item (READY, Effort S) with both candidate fixes named.
- **`CHANGELOG.md`'s own archive (previous entry) does not resolve its read-truncation risk**: post-archive `--check` still fires (946,570 B vs. 65,536 B budget) because the Session-325-frozen legacy-history block is a permanently-pinned 935,292 B / 3,570-line footer this tool structurally cannot archive -- 14x the budget on its own. Documented in `CLAUDE.md` as a known consequence of the already-ratified S325 "freeze legacy, go forward" decision, not re-litigated or re-opened.
- **`BACKLOG.md`'s own remediation deferred**: confirmed via direct structural inspection (only 10 `##` sections across 2,181 lines, each a large standing topical category accumulating narrative indefinitely, not chronological newest-on-top records) that it does not fit `methodology_trim.py`'s cut model at all. Filed as its own `BACKLOG.md` item (READY, Effort L) recommending editorial compression of fully-resolved narrative into `CHANGELOG.md` pointers, per the file's own "open work only" header.
- **`CLAUDE.md` gained 3 new "Additional close-out checks" notes**: the `methodology_trim.py` local-customization survive-the-sync checklist (for any future `chore(methodology): sync framework update from canonical` session), the `SESSION_NOTES.md` fence-defect finding, and the `CHANGELOG.md` footer-pinning consequence.
- **Net result this session**: `CHANGELOG.md` archived (11 records, 981,739 B -> 946,570 B, verified via independently re-run `verify.sh`); `SESSION_NOTES.md` config added and verified but archive blocked (documented, not forced); `BACKLOG.md` remediation correctly identified as out-of-model and deferred with a concrete follow-up plan, not silently dropped.
- Model: Claude Sonnet 5.

### 2026-08-11 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-08-11.md` (11 record(s), 981,739 B → 946,570 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **11** record(s) (2026-08-10 → 2026-08-11) out of [`CHANGELOG.md`](../../CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-08-11.md`](../../docs/archive/CHANGELOG-through-2026-08-11.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-08-11.md.verify.sh`](../../docs/archive/CHANGELOG-through-2026-08-11.md.verify.sh)
rather than trusting a digest printed here. Live file 981,739 B → 946,570 B (−3.6%).

### 2026-08-11 · [ad hoc] Claimed S518 (3-file ledger-size housekeeping); added SESSION_NOTES.md config to methodology_trim.py (Session 518)
- **Deliverable so far:** claimed the session (commit `2a7f9a0e`) for the dashboard's standing HIGH
  risk (SESSION_NOTES.md/CHANGELOG.md/BACKLOG.md all past the 2,000-line read cap, flagged
  unaddressed 8-9 consecutive sessions), scoped to SESSION_NOTES.md (config + first archive) and
  CHANGELOG.md (archive) after finding BACKLOG.md's 10 standing topical sections don't fit this
  tool's chronological-record model (deferred to a future editorial-compression session).
- **Config added:** a `SESSION_NOTES.md` `LedgerSpec` entry in `methodology_trim.py` (record_start
  matches `### Session N Handoff Evaluation (by Session N+1)` or `### What Session N Did`, verified
  against all 577 matching headings in the file with zero shape variance; `footer_mode="none"`,
  confirmed by direct inspection). **Local addition, not yet upstreamed**: `methodology_trim.py` is a
  canonical-overlay file (`BOOTSTRAP.md`'s sync table) with no documented mechanism for a local
  `LEDGERS` entry to survive the next `chore(methodology): sync framework update from canonical` --
  flagged in-file and in `CLAUDE.md` for that future session to re-add.
- **Why this entry exists mid-session, not only at close-out:** `methodology_trim.py`'s own P1
  frontier check refuses to trim any file while `CHANGELOG.md`'s own commit frontier has an
  undocumented gap (this session's own claim commit) -- this entry closes that gap so the planned
  SESSION_NOTES.md/CHANGELOG.md archives can run. The session's remaining actions (the archives
  themselves) get their own entries as they land.

