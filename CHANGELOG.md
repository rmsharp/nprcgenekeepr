# Changelog — Authoritative Action Ledger

Development / process history for the **nprcgenekeepr** project,
following the [methodology](https://github.com/rmsharp/methodology)
model: `BACKLOG.md` holds open work, **this file** holds completed
history, and `ROADMAP.md` holds the feature inventory and future plans.
Per canonical v3.1+, this file is the cumulative, append-only record of
**actions taken** in this repository — the authoritative answer to
*“what was done here, ever?”* Every session records its actions here at
close-out (`SESSION_RUNNER.md` Phase 3F); Phase 0 reconciles it against
`git log` and backfills anything a crashed or out-of-band session
missed. Taking an action and not recording it is failure mode \#27.

> **Note:** User-facing R-package release notes (the CRAN / pkgdown
> “Changelog”) live in `NEWS.md` / `NEWS.Rmd`. This file tracks the
> development *process* and methodology history, not package releases.

## 2026-08

### 2026-08-27 · \[issue \#164\] S644: Phase 1 – suppress fully-isolated individuals in makePedigreeMatingLayout(), closes issue \#164

- **Deliverable:** implemented Phase 1 (core renderer fix) of the
  ratified
  `docs/planning/pedigree-diagram-isolated-individual-suppression-plan.md`
  – new `.findIsolatedIds()` (Dragon 1’s predicate),
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  pre-filters isolated individuals out of `ped` (Dragon 2), an
  early-return fully-typed empty result when every individual is
  isolated instead of crashing (Dragon 3, ratified 3B – this is issue
  \#164’s fix), a `childEdgesOut` defense-in-depth 0-row guard, an
  `isolatedIds` return field, a conditional
  [`message()`](https://rdrr.io/r/base/message.html) (Dragon 5). Scoped
  to Phase 1 only (Phases 2/3 deferred) per owner confirmation via
  `AskUserQuestion`, following the plan’s own §10 vertical-slice option.
  Full strict TDD (PRE-RED/RED/GREEN/REFACTOR, each transition gated via
  `AskUserQuestion`) – REFACTOR skipped, GREEN diff already matched
  established patterns.
- **Verification:** new `tests/testthat/test_findIsolatedIds.R` (8
  cases) + 10 new/modified assertions in
  `tests/testthat/test_makePedigreeMatingLayout.R`, 219 passed/0
  failed/0 error; issue \#164’s exact 2-row and 1-row repros run
  manually, confirmed non-crashing under both `edgeStyle` values;
  `lintr::lint_package()` 0 lints (loaded first, per Learning 224) after
  fixing 2 real findings (a `commented_code_linter` false-positive from
  `fn()/fn()` reading as division in a prose comment, an
  implicit-integer style issue in `character(0)`); full clean regression
  read (`NOT_CRAN=true`, `load_all()`, `test_dir(reporter="silent")`)
  shows exactly `failed: 6, error: 1`, confined to the 2 pre-documented
  `test_comparePedigreeStructure.R` Track B blocks (plan §2.4’s own
  prediction, matched exactly) plus the 1 pre-existing unrelated
  `test_wordlist_coverage.R` failure – nothing else regressed. **Phase
  3E runtime smoke test:** live
  [`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html)
  run against the actual Diagram tab (a custom P5-style fixture)
  confirms the isolated individual is absent from the rendered vis.js
  node set, connected individuals render correctly, 0 JS console errors
  – this deliverable changes the live Diagram tab’s rendering (its one
  production call site, `R/modPedigree.R:588`), so build-clean alone was
  not sufficient.
- **Deferred, tracked in `BACKLOG.md`:** Phase 2 (2
  `test_comparePedigreeStructure.R` Track B blocks now fail, exactly as
  the plan predicted – `P5` is correctly suppressed, so the old
  `identical = FALSE`/`individualsOnlyInB = "P5"` assertions are now
  wrong; plus the article/ `data-raw` correction) and Phase 3
  (`R/modPedigree.R` Shiny UX messaging + e2e coverage).
- **Issue \#164 closed this session**, citing implementing commit
  `fc5ac928` and the verification evidence above.
- **Commits:** `4376adaa` (Phase 1B claim), `fc5ac928` (Phase 1
  implementation).
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[BL-N\] S643: ratified design plan for P5-suppression in makePedigreeMatingLayout(), entangled with issue \#164; pinned pedigree-drawing as BACKLOG.md’s standing top priority

- **Deliverable:** owner picked “P5-suppression design” from the
  rendered priorities list and added a standing directive:
  pedigree-drawing fidelity work stays the top of `BACKLOG.md`’s
  priorities, ahead of every other item, until the owner says it’s done
  – pinned as a note at the top of `BACKLOG.md` (commit `a2c32ec4`) and
  recorded as a durable project memory
  (`pedigree-drawing-standing-priority.md`). This session’s own
  deliverable: a RATIFIED architecture/design document,
  `docs/planning/pedigree-diagram-isolated-individual-suppression-plan.md`,
  for suppressing fully-isolated individuals (`P5`’s exact profile: no
  sire, no dam, never anyone’s sire/dam) in
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md),
  together with issue \#164 (crashes outright on an
  all-isolated-pedigree). Design only, no implementation – planning and
  implementation are separate sessions.
- **Research:** a 7-agent background `Workflow` run (`wf_7e5447f1-206`)
  – 4 parallel “Understand” readers (renderer source flow incl. issue
  \#164’s exact crash site; the Track B full test fixture and every
  assertion that will break; every now-wrong passage in
  `kinship2-fidelity-validation.qmd`; a grep-based blast-radius
  inventory of every
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  call site plus the Diagram tab’s focal-individual mechanism) fed into
  3 parallel “Design” agents (minimal-guard, principled-filter-stage,
  ux-first), each producing a full candidate design. **Found a real gap
  in the original `BACKLOG.md` scoping note:** the blast-radius agent
  discovered `R/modPedigree.R`’s Focal Animals + “Trim pedigree”
  mechanism can independently reach the identical “100%-isolated input”
  degenerate case as issue \#164, one deliberate individual selection at
  a time – not just via a whole-colony all-founder load. One design
  agent (minimal-guard) empirically patched the live
  `R/makePedigreeDiagramData.R`, ran the real fixtures + full test suite
  against its own patch, and reverted – **independently verified clean
  afterward** (`git status --short`/`git diff --stat -- R/ tests/` both
  empty) before any of its empirical findings (incl. a real,
  previously-undiscovered twin-connector dangling-edge interaction) were
  trusted or written into the design document.
- **Ratified decisions** (`AskUserQuestion`, 2 questions, owner picked
  the document’s own recommended option both times, no changes
  requested): isolation predicate (sire/dam/never-a- parent, excluding
  `twinRelations`-connected ids) and hook point (`.findIsolatedIds()`,
  pre-filters `ped` at the top of
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md))
  were forced by convergence across all 3 independent designs, not a
  judgment call. **Dragon 3 (RATIFIED):** when suppression would empty
  the diagram, render nothing + an explicit plain-language message – not
  “render everyone anyway,” which would re-show a `P5`-like individual
  whenever they’re 100% of what’s being rendered, the exact case just
  ruled an error. **Dragon 4 (RATIFIED):** the `R/modPedigree.R` Shiny
  UI messaging ships in the same implementation as the core fix, not
  deferred.
- **Document structure** (house style matched to
  `docs/planning/twin-relations-kinship- computation-plan.md`):
  evidence-based inventory with exact line numbers for every touched
  file (§2), a 3-phase implementation plan with completion criteria (§4,
  may run as one pre-declared vertical slice per §10 since Dragon 4 was
  ratified in-scope), an Impact Analysis table (§5), an Alternatives
  Considered table comparing all 3 candidate designs honestly (§7), and
  a close-out checklist mapping (§8: `NEWS.Rmd`, tutorial/article, issue
  \#164 close-out) for whichever future session implements it.
- **`BACKLOG.md`:** the P5-suppression item updated to point at the
  ratified plan and summarize the ratified decisions (commit
  `222a2afe`). Also filed (not fixed) a still-open finding from this
  session’s own Phase 0: `lint.yaml` CI failed on S642’s own close-out
  push (`object_usage_linter` on
  `data-raw/kinship2FidelityValidation.R:339`), contradicting S642’s own
  “0 lints” close-out claim, most likely a stale-globalenv artifact –
  not yet confirmed. No GitHub issue filed, matching this project’s
  CI-break tracking convention.
- **`PROJECT_LEARNINGS.md` Learning 675** (commit `8488e6fa`):
  multi-angle parallel design research surfaces genuine interactions a
  single-threaded read misses; letting a candidate design empirically
  patch-and-run during the research phase (not deferred to
  implementation) catches defects reading alone wouldn’t – contingent on
  independently verifying the agent didn’t leave residue, not trusting
  its own “reverted” claim.
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[ad hoc\] S643: record CHANGELOG.md entry for S642’s Learning-674 record and close-out commit (reconcile-on-read)

- **Deliverable:** Phase 0 reconcile found 2 commits past the
  `CHANGELOG.md` frontier (`39ef1c55`) with no ledger entry, the same
  two-commit shape S640’s own reconcile found for S639: `f6aecbdf`
  (“record Learning 674, update learnings-count pointer” – touched
  `CLAUDE.md`/`PROJECT_LEARNINGS.md` only) is a genuine standalone
  undocumented action, not the usual self-reference case; `df3ea858`
  (S642’s own close-out commit, writing the final `HANDOFFS.md`
  receipt + `SESSION_NOTES.md`) is the familiar self-reference gap this
  project’s precedent already names (S639-\>S640-\>…-\>S642). Backfilled
  both: fixed the S642 receipt’s `commit:` field from `pending` to
  `df3ea858` (this session, prior to this entry’s own commit), and this
  entry records `f6aecbdf`’s own action – `PROJECT_LEARNINGS.md`
  Learning 674 (an untested diagnostic/reporting layer has its own bug
  surface independent of the thing it reports on; a session’s narrative
  interpretation of a fix is a separate claim from the fix itself and
  needs the domain owner’s own sign-off) – and `CLAUDE.md`’s
  learnings-count pointer updated to match (673-\>674, S641+-\>S642+).
  `HANDOFFS.md` frontier check found no gap (`df3ea858` is already its
  own frontier).
- **Also found, live-checked via `gh run list`/`gh run view`, NOT
  self-resolved – reported, not fixed:** `lint.yaml` FAILED on S642’s
  own close-out push (run `33022564528`, commit `df3ea858`) –
  `[object_usage_linter] no visible global function definition for '.formatStructuralDiscrepancy'`
  at `data-raw/kinship2FidelityValidation.R:339`, exit code 31
  (`LINTR_ERROR_ON_LINT: true`). This contradicts S642’s own close-out
  claim of “0 lints on all 3 touched files” –
  `.formatStructuralDiscrepancy()` lives in
  `tests/testthat/helper-comparePedigreeStructure.R` (a `testthat`
  helper, not part of the package’s `R/` source), so it is not in scope
  for
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  the way `CLAUDE.md`’s Lint close-out checklist (Learning 224)
  prescribes; the most likely explanation is that S642’s local
  interactive session already had `.formatStructuralDiscrepancy` bound
  in its global environment (from an earlier `test_dir()`/`test_file()`
  run in the same session) when `lintr::lint_package()` ran, masking
  exactly the gap CI’s clean-environment run exposed – not yet
  confirmed, offered as a hypothesis for whichever session fixes this.
  No code/workflow file touched this session (per the CI-break tracking
  convention, `CLAUDE.md`: report a live CI break, don’t file a GitHub
  issue for it; fix if in scope, otherwise defer via `BACKLOG.md`).
  `R-CMD-check.yaml` was still `in_progress` on the same push at
  observation time – not yet resolved to a verdict.
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[ad hoc\] S642: fix data-raw/kinship2FidelityValidation.R’s own untested discrepancy-reporting gap; file the P5-suppression renderer defect

- **Deliverable:** owner-directed review of
  `kinship2-fidelity-validation.qmd`, working through Track A/B/C with
  every image re-rendered live (not trusted from cached files) and every
  claim traced against the raw fixture data programmatically. Two real
  findings, one fixed this session, one scoped to `BACKLOG.md` for a
  future session (owner chose “both, sequenced”).
- **Fixed via full strict TDD** (RED: 5 new tests in
  `tests/testthat/test_comparePedigreeStructure.R` for a new
  `.formatStructuralDiscrepancy()` helper, confirmed failing with “could
  not find function”; GREEN: minimum implementation):
  `data-raw/kinship2FidelityValidation.R`’s own local
  `reportDiscrepancy()` was never updated when S641 added
  `individualsOnlyInA`/`individualsOnlyInB` to
  `.comparePedigreeStructures()`’s return shape – confirmed live by
  re-running the script, which printed
  `!! DISCREPANCY -- Track B full !!` with nothing underneath, silently
  dropping the one detail (`individualsOnlyInB: "P5"`) the
  `identical = FALSE` verdict is based on. That reporting logic lived
  only in a script explicitly excluded from `R CMD check` (“not part of
  R CMD check” per its own header), so no test had ever exercised it.
  Extracted the logic into `.formatStructuralDiscrepancy(label, cmp)` in
  `tests/testthat/helper-comparePedigreeStructure.R` (auto-loaded under
  `test_dir()`/[`devtools::test()`](https://devtools.r-lib.org/reference/test.html),
  so it now has real coverage) – returns a character string (not a
  [`cat()`](https://rdrr.io/r/base/cat.html) side effect) specifically
  so its content is assertable. `data-raw/kinship2FidelityValidation.R`
  now calls it; re-running the script live confirms the report now
  correctly prints `individuals only in nprcgenekeepr: P5`. 120/120
  pre-existing tests in the file still pass; 5 new tests pass; 0 lints
  on all 3 touched files.
- **Filed, not fixed this session** (owner-directed, “both, sequenced”):
  `BACKLOG.md` “Up Next” now has a new item – `P5` (a fully isolated
  founder: no sire, no dam, no mate, no children) is erroneously
  rendered by
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  in the Track B full fixture; kinship2’s own `plot.pedigree()`
  correctly omits it. The owner explicitly ruled this an error (“P5… is
  erroneously included”), reversing S641’s own
  `kinship2-fidelity-validation.qmd` Verdict text (“the more useful
  default, not a bug to reconcile away”) – that framing is now known to
  be wrong and will need correcting alongside the code fix. Entangled
  with issue \#164 (the layout function crashes outright when every
  individual has zero edges) – a future session needs to design
  “suppress isolated individuals” and “what happens when suppression
  empties the diagram” together.
- **Also found and confirmed pre-existing** (not caused by this session,
  verified via `git stash`): `test_wordlist_coverage.R` fails locally
  (`comparator`, from `R/comparePedigreeStructure.R:230`’s roxygen text,
  not yet in `inst/WORDLIST`) – added as a new instance to the existing
  “spelling NOTE has drifted again” `BACKLOG.md` item (now 10 words),
  not a new item. Also observed one flaky `chromote`-based test error
  (`test_positionMatingUnitForest.R`, live-render helper) on one of two
  full-regression runs, not the other – matches this project’s own
  long-documented Chrome/chromote flakiness pattern (existing
  `BACKLOG.md` item), not caused by this session’s changes.
- **Verified:** full clean regression (`test_dir()`) 0 failed/0 error
  attributable to this session’s 3 touched files across 2 separate runs;
  `lintr::lint_package()` 0 lints on all 3 touched files;
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  0 errors/1 warning/1 note (both pre-existing – non-portable filename,
  `scratchpad/` – confirmed unrelated, matching S641’s own baseline),
  `testthat.R` and `spelling.R` both `OK` under `R CMD check`’s own run.
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[ad hoc\] S642: record CHANGELOG.md entry for S641’s HANDOFFS.md sha-fix action (reconcile-on-read)

- **Deliverable:** Phase 0 reconcile found 1 commit past the
  `CHANGELOG.md` frontier (`ed574b86`) with no ledger entry: `7c0b149d`,
  S641’s own close-out commit (writing the final `HANDOFFS.md` receipt +
  `SESSION_NOTES.md`). This is the same recurring self-reference gap
  this project’s precedent already names (S638→S639, S639→S640,
  S640→S641) – a close-out commit can’t cite its own sha in the receipt
  it writes, so the receipt’s `commit:` field is left `pending` and the
  commit itself postdates the last `CHANGELOG.md`-touching commit.
  Backfilled: fixed the S641 receipt’s `commit:` field from `pending` to
  `7c0b149d` (this session, prior to this entry’s own commit).
  `HANDOFFS.md` frontier check found no gap (`7c0b149d` is already its
  own frontier). Also found, live-checked, and confirmed self-resolved:
  `R-CMD-check.yaml` run `33006620646` (S640’s close-out push, commit
  `d2ecc8e1`) failed on `ubuntu-latest (devel)` at the “Set up Chrome”
  step with `read ECONNRESET` – a transient network error, not a
  code/config regression (the other 4 platform legs on that same run,
  incl. `oldrel-1`, all passed). Both subsequent pushes (`638e7417`,
  `7c0b149d`) re-ran all 5 legs clean, including `devel`, with no
  intervening change to `.github/workflows/R-CMD-check.yaml` or
  Chrome-provisioning steps. No prior session’s Phase 0 report caught
  this run as failed – S641’s own report only saw it as still
  `in_progress` and moved on. No code, test, or workflow file touched
  this session (per the CI-break tracking convention, `CLAUDE.md`:
  report a self-resolved live CI break, don’t file an issue for it).
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[ad hoc\] S641: fix the kinship2 structural comparator’s isolated-individual blind spot; close the kinship2 structural-comparison BACKLOG item

- **Deliverable:** picked up “kinship2 CI-verification close-out” from
  S640’s priorities list (verify Track C’s live-kinship2 tests actually
  run in CI). Before acting, the owner asked directly for a real
  demonstration – render and compare actual images, trace ground truth
  programmatically – rather than trusting the prior “identical = TRUE”
  claims. Doing so live-viewed
  `kinship2-fidelity-validation-img/trackB-kinship2-full.png` against
  `trackB-nprc-full.png` and found a real, visible discrepancy:
  kinship2’s own plot shows 15 individuals, nprcgenekeepr’s shows 16 –
  `P5`, a fully isolated founder (no parents, never anyone’s mate or
  parent) that kinship2’s own `align.pedigree()` silently drops from the
  plot grid while
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  renders it.
- **Root cause, confirmed live, not assumed:**
  `.comparePedigreeStructures()` (Track C of the kinship2
  structural-comparison plan, S635) diffed only `parentChildEdges` and
  `matePairs` – an isolated individual contributes zero rows to either
  table on EITHER side, so its presence/absence was structurally
  invisible to the diff. This is exactly the class of false-equivalence
  claim the owner has previously flagged (S631: “your equivalence
  assessments have been wrong in the past for these same pedigrees”) –
  confirmed here on the article’s own published Track B full fixture,
  which the “Structural verification” section (added Track D, S636) and
  the “Verdict” section both claimed was “structurally identical”/“PASS”
  based on this blind spot.
- **Fixed via full strict TDD** (RED: 23 new/updated assertions in
  `tests/testthat/test_comparePedigreeStructure.R`, including a direct
  regression test against the article’s own published Track B fixture,
  confirmed failing for the right reason; GREEN: minimum
  implementation). `.extractKinship2Structure()` gained a `displayedIds`
  param (default: all declared ids) and returns `individuals`;
  `.extractNprcStructure()` returns `individuals` (real, non-synthetic
  node ids, duplicate-safe); `.comparePedigreeStructures()` diffs
  `individuals` too (`individualsOnlyInA`/`individualsOnlyInB`), folded
  into `identical` (missing `individuals` on both sides stays backward
  compatible – treated as empty, no discrepancy, so every pre-existing
  hand-built-fixture unit test needed no changes beyond the field-count
  assertions). `compareAgainstKinship2()`
  (`tests/testthat/helper-comparePedigreeStructure.R`) now computes
  kinship2’s actually-placed id set via a new `.kinship2DisplayedIds()`
  helper (calls `align.pedigree()` directly, muffling the known-benign
  “Unexpected result in autohint” kinship2 message only after confirming
  the `nid` placement result is still fully correct despite it) and
  passes it as `displayedIds`. REFACTOR skipped by owner choice (diff
  already minimal, matching Track A/B/C’s own precedent). Commit
  `9fe3b7f5`.
- **Live-verified the fix’s actual effect** on all 4 of the article’s
  own fixtures via the fixed `compareAgainstKinship2()`: Track B full
  (16 subjects) now correctly reports `identical = FALSE` with `P5` in
  `individualsOnlyInB`; Track B shrunk (8 subjects), Track C (9-subject
  dogleg), and the real 375-individual bundled fixture all still
  correctly report `identical = TRUE` (P5 does not survive
  [`shrinkPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/shrinkPedigree.md)’s
  trim – an uninformative founder with no descendants – and neither
  Track C nor the real fixture has any isolated individuals). This
  confirms the fix catches a real defect without introducing any false
  positive on fixtures that were genuinely fine.
- **Corrected `vignettes/articles/kinship2-fidelity-validation.qmd`** to
  match: the Track B full-fixture fig-alt (removed the false “matching
  kinship2’s own family groupings” claim), the Structural verification
  table (Track B full: Yes -\> No, with an explanation that this is a
  real, expected difference in rendering convention, not a defect in
  either package – and that showing every declared individual is
  arguably the more useful default for colony management), and the
  Verdict section (from a blanket “PASS, all 3 tracks” to “PASS, with
  one known and expected difference”, explicitly naming the gap and the
  fix). Confirmed via `quarto render` (clean, no errors) – the
  build-equivalent for this documentation change.
- **Verified:** full clean regression 0 failed/0 error (6492 passed, 39
  pre-existing warnings, unchanged baseline);
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  0 errors/1 warning/1 note (both pre-existing – non-portable filename,
  `scratchpad/` – unrelated); `lintr::lint_package()` 0 lints on touched
  files.
- **BACKLOG.md:** removed the “Build a real structural/topological
  pedigree-diagram comparison algorithm against kinship2” item in full –
  all 4 tracks (A-D, S633-S636) were already DONE, and this session both
  fixed the one remaining gap in Track C’s own comparator (a defect the
  item’s final “CI skip-vs-run confirmation” framing had not
  anticipated) and completed the confirmation itself (all 6
  live-kinship2 tests run, not skip, in CI since S637’s `kinship2`
  Suggests fix, confirmed directly against real CI job logs in this
  session’s own Phase 0). No GitHub issue was ever filed for this item
  (owner-directed correction handled directly in `BACKLOG.md`), so no
  issue close-out is owed.
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[ad hoc\] S641: record CHANGELOG.md entry for S640’s HANDOFFS.md sha-fix action (reconcile-on-read)

- **Deliverable:** Phase 0 reconcile found 1 commit past the
  `CHANGELOG.md` frontier (`a77d6a5c`) with no ledger entry: `d2ecc8e1`,
  S640’s own close-out commit (writing the final `HANDOFFS.md` receipt +
  `SESSION_NOTES.md`). This is the familiar self-reference gap this
  project’s precedent already names – a close-out commit can’t cite its
  own sha in the receipt it writes, so the receipt’s `commit:` field is
  left `pending` and the commit itself postdates the last
  `CHANGELOG.md`-touching commit. Backfilled: fixed the S640 receipt’s
  `commit:` field from `pending` to `d2ecc8e1` (this session, prior to
  this entry’s own commit). `HANDOFFS.md` frontier check found no gap
  (`d2ecc8e1` is already its own frontier). No code, test, or workflow
  file touched.
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[ad hoc\] S640: close `ubuntu-latest (oldrel-1)` `setup-r@v2` CI flake – confirmed transient, no code/config change

- **Deliverable:** `BACKLOG.md` “Up Next” item found S638 (incidental to
  watching CI while root-causing the temp-detritus NOTE) –
  `R-CMD-check.yaml`’s `ubuntu-latest (oldrel-1)` leg failed once, at
  the `setup-r@v2` step itself, before any package code ran
  (`Failed to get R oldrel-1: ... Error: The process '/usr/bin/sudo' failed with exit code 100`,
  run `32930961617`, the S637 close-out commit). The item’s own text
  asked a future session to check reproducibility before treating it as
  more than a one-off transient runner/apt flake. Checked directly
  against real CI history (`gh run view` on each): the 4 real
  `R-CMD-check.yaml` runs since that one failure – `32969359216` (S638
  Learning-record push), `32971663253` (S638 close-out push),
  `33002411920` (S639 resolve push), `33003541368` (S639 close-out push)
  – all show `ubuntu-latest (oldrel-1)` completing `success` cleanly
  (10-12 min each), with no intervening change to `R-CMD-check.yaml` or
  `DESCRIPTION` that would explain a fix. Confirmed transient: GitHub
  Actions/`r-lib/actions@setup-r` infrastructure, not this project’s
  code, tests, dependencies, or workflow config. No RED/GREEN/REFACTOR
  cycle – no defect exists to fix, matching the established precedent
  (Track D, S636) for a PRE-RED-only investigative session with no new
  package code to test. Owner-approved closing the item on this evidence
  via `AskUserQuestion`. Removed from `BACKLOG.md` (no code/workflow
  files touched this session).
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[ad hoc\] S640: record CHANGELOG.md entry for S639’s HANDOFFS.md sha-fix action, plus S639’s separately-committed Learning 672 record

- **Deliverable:** Phase 0 reconcile found 2 commits past the
  `CHANGELOG.md` frontier (`507cc6ad`) with no ledger entry. Unlike
  prior sessions’ reconcile gaps (always just the close-out commit
  alone, since the Learning-record commit and the CHANGELOG-entry commit
  were usually the same commit), S639 split them: `805b2b83` (“record
  Learning 672…, update learnings-count pointer”) landed *after*
  `507cc6ad` (the commit that actually touched `CHANGELOG.md`), so it
  was a genuine standalone undocumented action, not just the usual
  self-reference case. `9f2b1c16` (S639’s close-out commit, writing the
  final `HANDOFFS.md` receipt + `SESSION_NOTES.md`) is the familiar
  self-reference gap this project’s precedent already names. Backfilled
  both: fixed the S639 receipt’s `commit:` field from `507cc6ad` to
  `9f2b1c16` (commit `0a79fbbc`), and this entry records that fix plus
  `805b2b83`’s own action – `PROJECT_LEARNINGS.md` Learning 672
  (documenting `test-coverage.yaml`’s no-`strategy.matrix` structural
  nuance found during S639’s RED-phase research: a BACKLOG item’s
  recommended fix can be right about the mechanism and wrong about the
  mechanics when the target lacks a structural property the item’s text
  never checked) and `CLAUDE.md`’s learnings-count pointer updated to
  match.
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[BL-N\] S639: provision pinned Chrome for `test-coverage.yaml`’s chromote-dependent tests

- **Deliverable:** `BACKLOG.md` “Up Next” item found S637, incidental to
  watching CI for the `R-CMD-check.yaml` fix – `test-coverage.yaml`
  (which runs `covr::package_coverage()`, executing this package’s full
  test suite including `test_positionMatingUnitForest.R`’s
  `getLiveRenderedPositions()` call) never received the chromote
  Chrome-provisioning fix
  `R-CMD-check.yaml`/`R-CMD-check-scheduled.yaml` both have
  (S616/S618/S619/S629), so it hit the identical
  ambient-Chrome-discovery flake (`chromote:::launch_chrome()` -\>
  `startup()` -\>
  [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html)).
  Ported the identical 3-step pattern (pinned
  `browser-actions/setup-chrome@v2`
  - `CHROMOTE_CHROME` export +
    [`chromote::find_chrome()`](https://rstudio.github.io/chromote/reference/find_chrome.html)
    pre-flight assertion), with one deliberate deviation: no `if:` guard
    on any step, since `test-coverage.yaml` runs a single, unconditional
    `ubuntu-latest` job with no `strategy.matrix` at all (unlike the
    other 2 workflows) – referencing `matrix.config.os` in an `if:` on a
    non-matrix job is an invalid GitHub Actions expression, not a
    harmless no-op. Full strict TDD: RED (9 assertions failed for the
    right reason) -\> GREEN (minimum implementation, 33/33 guard-test
    expectations pass) -\> REFACTOR skipped by owner choice (diff
    already minimal). Extended
    `tests/testthat/test_r_cmd_check_workflow_chrome_setup.R` with 3 new
    `test_that()` blocks – a separate section, not folded into the
    existing `R-CMD-check.yaml`/`-scheduled.yaml` loop, for the same
    no-matrix/different-anchor-step reasons above (that loop’s own
    macos-latest-skip test and `check-r-package@v2` ordering anchor
    don’t apply to this workflow). Verified: full clean regression 0
    failed/0 error/6453 passed (unchanged baseline);
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
    0 errors, 1 WARNING + 1 NOTE (both confirmed pre-existing/unrelated
    – non-portable filename, `scratchpad/`); `lintr::lint_package()` 0
    lints on touched files. Commit: `c6abedf5`.
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[ad hoc\] S639: record CHANGELOG.md entry for the HANDOFFS.md sha-fix action itself (matching S607/S623/S629-S638 precedent)

- **Deliverable:** Phase 0 reconcile found `92c717d7` (S638’s own
  close-out commit, writing the final `HANDOFFS.md` receipt +
  `SESSION_NOTES.md`) past the `CHANGELOG.md` frontier with no ledger
  entry — the same self-reference gap this project’s precedent already
  names (a close-out commit cannot cite its own sha at write time),
  anticipated verbatim by S638’s own gotcha (3). Fixed the S638
  receipt’s `commit:` field from `cd4f968c` to `92c717d7` (commit
  `6e2a3fe2`), and this entry logs that fix commit itself, per the
  established two-step pattern.
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[BL-N\] S638: root-cause and fix the `checking for detritus in the temp directory` NOTE (`org.chromium.Chromium.*`, all 3 `ubuntu-latest` legs)

- **Deliverable:** `BACKLOG.md` item found S636, confirmed reproducing
  S637 (“root cause not yet diagnosed”). Root cause:
  `tests/testthat/helper-live-render-positions.R`’s
  `getLiveRenderedPositions()` closed only the `ChromoteSession` it
  creates, never the parent
  [`chromote::default_chromote_object()`](https://rstudio.github.io/chromote/reference/default_chromote_object.html)
  singleton – so the underlying Chrome subprocess was only ever
  hard-killed by `processx`’s `supervise = TRUE` parent-exit mechanism,
  never given a chance to run Chromium’s own
  `ProcessSingleton::Cleanup()`, leaving its
  `SingletonCookie`/`SingletonSocket` lock directory
  (`org.chromium.Chromium.<random>` on CI’s unbranded build) behind in
  the shared OS temp root. Confirmed via direct chromote 0.5.1 source
  inspection and a local reproduction (a disposable subprocess mimicking
  the helper’s exact pattern, before/after temp-dir diff) – reproduces
  identically on macOS/branded Chrome, confirming the mechanism is
  platform-generic, not CI-specific. Fix: register a ONE-TIME,
  session-teardown-scoped graceful close
  (`withr::defer(chromeParent$close(), envir = testthat::teardown_env())`)
  on the helper’s first call, guarded to register exactly once across
  its 3 call sites – no change to Chrome-launch count/timing. New
  structural regression guard:
  `tests/testthat/ test_helper_live_render_positions_teardown.R`
  (matches `test_helper_live_render_positions_timeout.R`’s house style;
  a supplementary live mechanism-proof test was prototyped, worked in
  every standalone repro, but proved flaky specifically inside
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)’s
  sandbox subprocess and never exercised this fix’s own code path –
  dropped rather than chased further, owner-directed). Verified
  empirically against the real caller: ran
  `test_positionMatingUnitForest.R` (the only real usage, 3 call sites)
  end-to-end as a standalone subprocess, 0 leftover temp-dir entries
  before vs. after; a real
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  run’s “checking for detritus in the temp directory” step reported a
  bare `OK` for the first time. Full clean regression 0 failed/0 error;
  `lintr::lint_package()` 0 lints. Incidentally found, not chased (filed
  to `BACKLOG.md` instead): `ubuntu-latest (oldrel-1)` failing at the
  `setup-r@v2` step itself (a `sudo`/R-installer infra error, unrelated
  to this fix). See `PROJECT_LEARNINGS.md` Learning 671. Commits:
  `cc8d617e` (claim), `03e3bd52` (fix).
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[ad hoc\] S638: record CHANGELOG.md entry for the HANDOFFS.md sha-fix action itself (matching S607/S623/S629-S636 precedent)

- **Deliverable:** Phase 0 reconcile found `dec55f20` (S637’s close-out
  commit, writing the final `HANDOFFS.md` receipt + `SESSION_NOTES.md`)
  past the `CHANGELOG.md` frontier with no ledger entry — the same
  self-reference gap this project’s precedent already names (a close-out
  commit cannot cite its own sha at write time). Fixed the S637
  receipt’s `commit:` field to add `dec55f20` (commit `ce396c87`), and
  this entry logs that fix commit itself, per the established two-step
  pattern. Commit: `ce396c87`.
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[BL-N\] S637: fix R-CMD-check.yaml CI break to a genuinely clean 0/0/0 baseline

- **Deliverable:** owner-directed “broader” scope (a clean baseline, not
  just a green checkmark) on `BACKLOG.md`’s top item (found S636).
  Root-caused both real issues directly rather than trusting the 4
  candidate fixes S636 listed: (1) `kinship2` was simply never declared
  in `DESCRIPTION` (confirmed via grep) — added to `Suggests:`, removing
  the “unstated dependencies in tests” WARNING without reopening Track
  C’s “tests call kinship2 live” decision (Learning 667) or loosening
  the CI gate; (2) the long-standing `vignettes/figure` knitr-leftover
  NOTE (first documented ~S520, deferred 80+ sessions) traced to one
  dead, git-tracked PNG nothing reads — removed via `git rm`. Full
  strict TDD (RED → GREEN → REFACTOR skipped by owner choice, diff
  minimal): new `tests/testthat/test_r_cmd_check_clean_baseline.R`
  guards both. A third, newly-found NOTE (`org.chromium.Chromium.*` temp
  detritus, chromote-related) was deliberately not chased this session
  (owner-directed) — filed to `BACKLOG.md` instead, now confirmed
  reproducing on all 3 `ubuntu-latest` legs. **Live-verified on real
  CI:** pushed, then confirmed via direct per-platform job-log
  inspection — `macos-latest`/`windows-latest` are genuine `Status: OK`;
  the 3 ubuntu legs show only the separately-filed detritus NOTE. A
  previously-flagged consequence (declaring `kinship2` in `Suggests:`
  means CI’s `setup-r-dependencies@v2` `needs: check` now installs it,
  flipping Track C’s 6 `skip_if_not_installed("kinship2")` tests from
  skip to run) confirmed clean: 0 failures on any of the 5 platforms.
  Incidentally discovered, not fixed (reported per Learning 382’s
  precedent, filed to `BACKLOG.md`): `test-coverage.yaml` fails
  intermittently on the already-diagnosed chromote Chrome-launch flake
  (S616/S618/S619/S629) — it never received the Chrome-provisioning fix
  the other 2 CI workflows have, and isn’t covered by the existing guard
  test either. Verified:
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  0 errors/0 \[tracked-repo\] warnings/0 \[tracked-repo\] notes; full
  clean regression 0 failed/0 error/39 warnings/6439 passed;
  `lintr::lint_package()` 0 lints; `renv::snapshot(dev = TRUE)` +
  `renv::status(dev = TRUE)` consistent. See `PROJECT_LEARNINGS.md`
  Learning 670. Commits: `e335542f` (claim), `526c7fec` (fix),
  `438f3eb8` (docs).
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[ad hoc\] S636: record HANDOFFS.md receipt commit-sha fix for the CI-break correction (matching S607/S623/S629-S635 precedent)

- **Deliverable:** logging this session’s own `HANDOFFS.md` receipt
  `commit` field fix (`519a8182` content correction, `80ffacbf` second
  close-out pass) as its own ledger entry, since the fix commit
  (`613988c6`) is itself an action this session took. Commit:
  `613988c6`.
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[ad hoc\] S636: push Track A-D’s commits (first time), discover and document R-CMD-check.yaml is red on master

- **Deliverable:** pushed `master` (owner-approved via
  `AskUserQuestion`) — the first time Track A/B/C/D’s commits (31
  prior + this session’s) ever reached CI. Confirmed good news first:
  Track C’s 3 live-kinship2 end-to-end tests skip cleanly on every
  platform (`{kinship2} is not installed (6): ...`), exactly as designed
  — the plan §5 gotcha outstanding since S635 is now resolved. Also
  discovered, not assumed: `R-CMD-check.yaml` fails on all 5 matrix
  jobs, root-caused via direct job-log inspection on 2 platforms to
  `r-lib/actions/check-r-package@v2`’s default `error-on: "warning"`
  (not overridden in this project’s workflow file) tripping on Track C’s
  already-accepted “unstated dependencies in tests: kinship2” WARNING
  (`PROJECT_LEARNINGS.md` Learning 667) — a real, previously-unverified
  consequence, since these commits had never reached CI before.
  Presented via `AskUserQuestion`; owner directed leaving CI red for a
  dedicated future session rather than editing the workflow file this
  session (a process/infra decision outside Track D’s own scope).
  Initially filed as issue \#165, then closed same-session per live
  owner correction (“do not file GitHub issues for CI breaks – those
  should be fixed as found or deferred to a future session via the
  backlog”) — tracked instead as a `BACKLOG.md` “Up Next” item with full
  root-cause detail and 4 candidate fix approaches, none decided. Added
  `PROJECT_LEARNINGS.md` Learning 669.
- **Model:** Claude Sonnet 5.

### 2026-08-26 · \[ad hoc\] S636: record CHANGELOG.md entry for the HANDOFFS.md sha-fix action itself (matching S607/S623/S629-S635 precedent)

- **Deliverable:** logging this session’s own `HANDOFFS.md` receipt
  `commit` field fix (`36653242` mechanical, `00a1d6d2` documentation,
  `8463dbd9` close-out) as its own ledger entry, since the fix commit
  (`8e7a12f6`) is itself an action this session took. Commit:
  `8e7a12f6`.
- **Model:** Claude Sonnet 5.

### 2026-08-25/26 · \[ad hoc\] S636: implement Track D of the kinship2 structural-comparison plan (close the loop)

- **Deliverable:**
  `docs/planning/pedigree-diagram-kinship2-structural-comparison-plan.md`
  §4.4. Ported `PROJECT_LEARNINGS.md` Learning 643’s `$go_to()`
  chromote-race fix into `data-raw/kinship2FidelityValidation.R`’s
  `screenshot_layout()` (replacing the racy
  `Page$navigate()`+`Page$loadEventFired()`+[`Sys.sleep()`](https://rdrr.io/r/base/Sys.sleep.html)
  sequence). Ran the script end-to-end locally — no hang, no race —
  regenerating all 4 nprcgenekeepr-side Track B/C images (the 4
  kinship2-side base-R plots were byte-identical, as expected). Added a
  Track D section sourcing
  `tests/testthat/helper-comparePedigreeStructure.R` and running Track
  C’s own `compareAgainstKinship2()` against the vignette’s own Track
  B/C fixtures live: Track B full (16 subjects), Track B shrunk (8
  subjects), and Track C (9 subjects, consanguineous dogleg) all report
  `identical = TRUE`, no discrepancy on any of the 3. Owner-approved
  PRE-RED framing — no RED/GREEN cycle, since no new package function
  exists to unit-test; verified functionally instead (script completes
  cleanly, images regenerate, comparator runs), matching Learning 643’s
  own original verification precedent (real execution, not a unit test).
  Removed `vignettes/articles/kinship2-fidelity-validation.qmd`’s S631
  “not currently verified” caveat (fully supported by the 3/3 identical
  result); added a new “Structural verification” section and updated the
  “Verdict” section. **Genuine coverage gap found and presented, not
  silently resolved either way (`PROJECT_LEARNINGS.md` Learning 668):**
  `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`
  shares the identical S631 caveat but rests on 4 completely different
  example pedigrees never run through the comparator — presented via
  `AskUserQuestion`; owner chose to leave that document’s own caveat
  standing (adding an explicit note naming the untested gap) rather than
  following plan §4.4’s literal “remove from both” text. Added a
  plain-language `NEWS.Rmd` entry (the plan’s own “first genuinely
  user-facing consequence” framing). Verified: both `.qmd` files render
  clean via `quarto render`;
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  0 errors / 2 WARNINGs / 2 NOTEs, all 4 unchanged from Track C’s own
  baseline; full clean regression 0 failed / 0 error / 39 warnings /
  6437 passed (the previously-documented `test_wordlist_coverage.R` “1
  pre-existing failure” did NOT reproduce this session — flagged, not
  investigated, see Learning 668); `lintr::lint_package()` 0 lints (1
  `undesirable_function_linter` hit on the new
  [`source()`](https://rdrr.io/r/base/source.html) call, suppressed via
  `# nolint start/end`, matching `data-raw/fgSEValidation.R`’s own
  established precedent). All 4 tracks of the kinship2
  structural-comparison plan are now DONE. Commits: `36653242`
  (mechanical: script fix + regenerated images), `00a1d6d2`
  (documentation: caveat removal + coverage-gap note + `NEWS.Rmd`).
- **Model:** Claude Sonnet 5.

### 2026-08-25 · \[ad hoc\] S635: record CHANGELOG.md entry for the HANDOFFS.md sha-fix action itself (matching S607/S623/S629-S634 precedent)

- **Deliverable:** logging this session’s own `HANDOFFS.md` receipt
  `commit` field fix (`57a75044` deliverable, `73a27e11` close-out) as
  its own ledger entry, since the fix commit (`456ca044`) is itself an
  action this session took. Commit: `456ca044`.
- **Model:** Claude Sonnet 5.

### 2026-08-25 · \[ad hoc\] S635: implement Track C of the kinship2 structural-comparison plan (`.comparePedigreeStructures()`)

- **Deliverable:** `R/comparePedigreeStructure.R` —
  `.comparePedigreeStructures(a, b)`, a new zero-`kinship2`-dependency
  internal (`@noRd`) function implementing
  `docs/planning/ pedigree-diagram-kinship2-structural-comparison-plan.md`
  §3.3/§4.3 (canonicalized, order-independent set-diff of two
  `list(parentChildEdges, matePairs)` structures, agnostic to which side
  is kinship2 vs. nprcgenekeepr). New
  `tests/testthat/helper-comparePedigreeStructure.R` holds
  `toKinship2Pedigree()` (D-5’s sire/dam-reversal auto-swap) and
  `compareAgainstKinship2()` orchestration — genuinely
  `kinship2`-dependent,
  [`requireNamespace()`](https://rdrr.io/r/base/ns-load.html)-guarded,
  deliberately placed outside `R/` and outside the plan’s literal
  `data-raw/kinship2FidelityValidation.R` suggestion (owner-approved
  deviation at the PRE-RED gate, matching the project’s own established
  `data-raw/fgSEValidation.R` + `tests/testthat/helper-fgSEValidation.R`
  split). New D-7 crossing-duplication fixture (10 subjects, a double
  cross-marriage between two founder sibships) empirically confirmed,
  via direct inspection of kinship2’s own unexported
  `alignped1`/`alignped2`/ `alignped3` source, to trigger kinship2’s
  real single-mate plot-time duplication (dragon 1, plan §1.3) — see
  `PROJECT_LEARNINGS.md` Learning 667. Full strict TDD (RED: 5 pure
  comparator unit tests confirmed failing for the right reason —
  `could not find function ".comparePedigreeStructures"`; GREEN: passed
  clean on the first implementation, 1 `brace_linter` style fix;
  REFACTOR: skipped by choice, already minimal). Live-kinship2
  end-to-end tests confirm `identical = TRUE` on the existing 9-subject
  Track-C fixture, the new D-7 fixture, and the real 375-individual
  bundled fixture (D-8 toy-and-real-scale discipline) — a clean pass on
  all three, reported as a finding, not silently assumed. Verified:
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  0 errors / 2 WARNINGs (1 pre-existing non-portable filename + 1 new
  “unstated dependencies in tests: kinship2” — Track C’s tests are the
  only real executable `kinship2::`/`kinship2:::` calls in the codebase;
  accepted as a documented trade-off for genuine ongoing regression
  protection, owner-confirmed once the concrete WARNING count was in
  hand, per `PROJECT_LEARNINGS.md` Learning 667) / 2 NOTEs (both
  pre-existing); full clean regression 1 pre-existing failure
  (`test_wordlist_coverage.R`, same known baseline) / 0 error;
  `lintr::lint_package()` 0 lints on touched files. `BACKLOG.md`’s top
  item updated: Track C marked DONE, Track D (port the `$go_to()`
  chromote fix, regenerate images, remove the S631 caveats if the
  comparator supports it) named as next pickup.
- **Model:** Claude Sonnet 5.

### 2026-08-25 · \[ad hoc\] S634: record CHANGELOG.md entry for the HANDOFFS.md sha-fix action itself (matching S607/S623/S629-S633 precedent)

- **Deliverable:** logging this session’s own `HANDOFFS.md` receipt
  `commit` field fix (deliverable `b52f2058` → deliverable + close-out
  `b52f2058 (deliverable), af67682b (close-out)`) as its own ledger
  entry, since the fix commit (`e468e899`) is itself an action this
  session took. Commit: `e468e899`.
- **Model:** Claude Sonnet 5.

### 2026-08-25 · \[ad hoc\] S634: file issue \#164 (makePedigreeMatingLayout() crashes on zero parent-child edges)

- **Deliverable:** filed [issue
  \#164](https://github.com/rmsharp/nprcgenekeepr/issues/164) for a
  genuine, reproducible, pre-existing bug incidentally found while
  designing a Track B founder-only test fixture —
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  throws `arguments imply differing number of rows: 0, 1` on any
  pedigree with zero total parent-child edges (root-caused to
  `R/makePedigreeDiagramData.R :1172`’s
  `childEdgesOut <- data.frame(childEdges, dashes = FALSE, ...)`, which
  cannot recycle a scalar onto a 0-row `childEdges`). Reported, not
  fixed, per the established “found-an-unrelated- gap, report don’t fix
  mid-session” precedent (`PROJECT_LEARNINGS.md` Learning 382). Worked
  around in Track B’s own tests by hand-building the founder-only
  fixture directly in `.extractNprcStructure()`’s input-contract shape.
- **Model:** Claude Sonnet 5.

### 2026-08-25 · \[ad hoc\] S634: implement Track B of the kinship2 structural-comparison plan (`.extractNprcStructure()`)

- **Deliverable:** `R/comparePedigreeStructure.R` —
  `.extractNprcStructure()`, a new zero-`kinship2`-dependency internal
  (`@noRd`) function implementing
  `docs/planning/ pedigree-diagram-kinship2-structural-comparison-plan.md`
  §3.2/§4.2 (hardened/vectorized, not the plan’s own illustrative loop
  version), plus the D-2 edgeStyle-invariance property test appended to
  `tests/testthat/test_comparePedigreeStructure.R` (7 new `test_that()`
  blocks: return shape, founder-only, D5 single-known-parent, the
  7-subject fixture reused from Track A, the 9-subject Track C fixture
  with duplicates + a real consanguineous union, and 2
  edgeStyle-invariance property tests against the Track C fixture and
  the real 375-individual bundled fixture), plus a test-file- local
  `.extractNprcStructureFromWaypoints()` helper (a second, independent
  extraction walking `__drop_`/`__bar_`/`__proj_`/`__jog_` rectilinear
  waypoint chains — the plan’s own §3.2 gives no pseudocode for this
  half, so it was designed from scratch this session and empirically
  prototyped/ verified in `scratchpad/` against the 9-subject fixture
  and the real 375-individual fixture BEFORE being written into RED,
  confirming D-2’s invariance claim holds — 502 parent-child edges / 237
  mate pairs matched exactly on the real fixture). Full strict TDD: RED
  (7 blocks confirmed failing for the right reason — function not found)
  → GREEN (implementation passed clean on the first run, no bug found
  this time) → REFACTOR skipped by owner-approved choice (the apparent
  duplication between the production extractor and the test-only walker
  is deliberate — plan §4.2’s own “separately-implemented” requirement —
  not accidental; factoring it out would let a shared-logic bug silently
  pass the invariance test on both sides). Verified:
  `lintr::lint_package()` 0 lints (fixed 2 `string_boundary_linter`
  hits, `grepl("^__union_", ...)` → `startsWith(..., "__union_")`); full
  clean regression 1 pre-existing failure (`test_wordlist_coverage.R`,
  same known baseline) / 0 error / 39 warnings;
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  Status: 1 WARNING, 2 NOTEs, 0 errors, all 3 confirmed
  pre-existing/unrelated (non-portable untracked filename, untracked
  `scratchpad/`, `vignettes/figure/` knitr leftover), matching Track A’s
  own baseline — the full installed-package test suite ran clean inside
  the check (`FAIL 0 | WARN 39 | SKIP 206 | PASS 6395`). Runtime smoke
  test: n/a — pure internal function, zero call sites (confirmed by
  grep), no runtime/Shiny wiring changed. `BACKLOG.md`’s top item
  updated (Track B DONE, Track C next). Commit: `b52f2058`.
- **Model:** Claude Sonnet 5.

### 2026-08-25 · \[ad hoc\] S633: record close-out commit sha in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S632 precedent)

- **Deliverable:** fixed this session’s own `HANDOFFS.md` receipt
  `commit` field from the deliverable-only sha to include the close-out
  commit itself (`d09a51e1` deliverable, `de9efb07` close-out). Commit:
  `c09ac79d`.
- **Model:** Claude Sonnet 5.

### 2026-08-25 · \[ad hoc\] S633: implement Track A of the kinship2 structural-comparison plan (`.extractKinship2Structure()`)

- **Deliverable:** `R/comparePedigreeStructure.R` (new) —
  `.extractKinship2Structure()`, a zero-`kinship2`-dependency internal
  (`@noRd`) function implementing
  `docs/planning/ pedigree-diagram-kinship2-structural-comparison-plan.md`
  §3.1/§4.1 exactly, plus
  `tests/testthat/test_comparePedigreeStructure.R` (5 `test_that()`
  blocks, 19 assertions across 4 synthetic fixtures: founder-only,
  single-known-parent, multi-mate/shared-parent dedup, a combined
  7-subject/2-mating fixture). Full strict TDD: RED (5 blocks confirmed
  failing for the right reason — function not found) → GREEN
  (implementation; found and fixed a real bug in the plan’s own §3.1
  pseudocode along the way — a literal scalar `role` value fails
  [`data.frame()`](https://rdrr.io/r/base/data.frame.html)’s recycling
  rule against a zero-match founder mask, fixed with
  `role = rep("father", sum(hasFather))`, see `PROJECT_LEARNINGS.md`
  Learning 666) → REFACTOR skipped by owner-approved choice (code
  already minimal). Verified: `lintr::lint_package()` 0 lints (after
  fixing 2 `implicit_integer_linter` hits); full clean regression 1
  pre-existing failure (`test_wordlist_coverage.R`, confirmed via direct
  grep that the flagged word `bitSize` originates entirely in the
  pre-existing `R/shrinkPedigree.R`) / 0 error;
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  0 errors, 1 warning + 2 notes, all 3 confirmed pre-existing/unrelated
  (non-portable untracked-file name, untracked `scratchpad/` dir,
  pre-existing `vignettes/figure/` knitr leftover). Runtime smoke test:
  n/a — pure internal function, zero call sites, no runtime/Shiny wiring
  changed. `BACKLOG.md`’s top item updated (Track A DONE, Track B next).
  `PROJECT_LEARNINGS.md` Learning 666. `CLAUDE.md` learnings-count
  pointer refreshed (632+/665 -\> 633+/666). Commit: `d09a51e1`.
- **Model:** Claude Sonnet 5.

### 2026-08-25 · \[ad hoc\] S632: record close-out commit sha in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S631 precedent)

- **Deliverable:** fixed this session’s own `HANDOFFS.md` receipt
  `commit` field from the deliverable-only sha to include the close-out
  commit itself (`1662fa14` deliverable, `11bcf417` close-out). Commit:
  `86fead66`.
- **Model:** Claude Sonnet 5.

### 2026-08-25 · \[ad hoc\] S632: design a structural/topological pedigree-diagram comparison algorithm vs kinship2 (BACKLOG.md Up Next item found S631)

- **Deliverable:**
  `docs/planning/pedigree-diagram-kinship2-structural-comparison-plan.md`
  — an interface-first design resolving the DECISION NEEDED tag on
  `BACKLOG.md`’s top “Up Next” item. A 5-agent research fan-out
  (kinship2 `pedigree` object internals verified live;
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
  output/synthetic-id structure re-verified directly against source;
  existing test/fixture inventory; prior-planning-doc “dragons”; a
  grep-based integration-point inventory), plus this session’s own
  direct re-verification of the 2 most load-bearing structural claims
  (`R/makePedigreeDiagramData.R:1085-1234,460-522,355-365`), produced 8
  numbered design decisions (forced vs. judgment call, each labeled) and
  an interface-first design for 3 `R/` internal (`@noRd`) functions —
  `.extractKinship2Structure()`/`.extractNprcStructure()`/
  `.comparePedigreeStructures()` — all zero-`kinship2`-dependency by
  construction (typed to the minimal field shape kinship2’s `pedigree`
  object actually exposes, not its S3 class; only a thin
  `data-raw/`-side wrapper touches `kinship2::` directly). Split into 4
  session-sliceable tracks (A: kinship2-side extractor; B:
  nprcgenekeepr-side extractor + an edgeStyle-invariance property test;
  C: the diff + a new crossing-duplication fixture + live-kinship2
  end-to-end tests against the Track-C fixture and the real
  375-individual fixture; D: port the `$go_to()` chromote fix,
  regenerate images, remove the S631 caveats once Track C
  confirms/resolves parity). 4 owner- ratification questions (code
  placement, twin-relation scope, the new fixture, Track D placement)
  answered via `AskUserQuestion`, all exactly per the plan’s own
  recommendation. `BACKLOG.md`’s top item updated (design DONE/RATIFIED,
  Track A named as next pickup — not marked `[x]`, since implementation
  hasn’t happened). `PROJECT_LEARNINGS.md` Learning 665 (the
  typed-to-minimal-shape adapter pattern for optional-dependency
  comparators). `CLAUDE.md` learnings-count pointer refreshed (631+/664
  -\> 632+/665). Commit: `1662fa14`.
- **Model:** Claude Sonnet 5.

### 2026-08-25 · \[ad hoc\] S631: record close-out commit sha in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S630 precedent)

- **Deliverable:** fixed this session’s own `HANDOFFS.md` receipt
  `commit` field from the pre-close-out commit to include the close-out
  commit itself (`16a23c2a` correction, `35b1a23e` close-out). Commit:
  `7b487066`.
- **Model:** Claude Sonnet 5.

### 2026-08-25 · \[ad hoc\] S631: stop presenting kinship2 diagram comparisons as verified equivalent (owner correction)

- **Deliverable:** owner corrected this session directly – “you are
  still publishing comparisons of kinship2 output to nprcgenekeepr
  output as equivalent when they are clearly not… I have stated that
  your equivalence assessments have been wrong in the past for these
  same pedigrees.” Investigated
  `vignettes/articles/kinship2-fidelity-validation.qmd` and
  `docs/planning/ pedigree-diagram-kinship2-reference-comparison.qmd`:
  found neither document’s diagram-image claims are backed by any
  programmatic structural comparison (only Track A’s kinship-matrix
  [`identical()`](https://rdrr.io/r/base/identical.html) and Track B’s
  surviving-id-set [`setequal()`](https://rdrr.io/r/base/sets.html) are
  genuinely checked); found both documents’ images are stale relative to
  the same-row-collision-avoidance work and the Walker/BJL positioning
  rewrite (issue \#141). Added a prominent, honest caveat to both
  documents (not a fix) stating the diagram-equivalence claims are
  unverified and must not be cited until a real comparison exists. Filed
  a `BACKLOG.md` item scoping the actual fix (port the known `chromote`
  `$go_to()` race fix into `data-raw/kinship2FidelityValidation.R`,
  regenerate every image, build a real structural edge-set comparison)
  as dedicated future-session work, per owner direction not to rush it
  this session. `PROJECT_LEARNINGS.md` Learning 664 recorded;
  user-memory `verify-diagrams-against-ground-truth.md` updated with a
  third instance. `CLAUDE.md` learnings-count pointer refreshed
  (630+/663 -\> 631+/664). Commit: `16a23c2a`.
- **Model:** Claude Sonnet 5.

### 2026-08-25 · \[ad hoc\] S630: record close-out commit sha in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S629 precedent)

- **Deliverable:** fixed this session’s own `HANDOFFS.md` receipt
  `commit` field from the pre-close-out commit list to include the
  actual close-out commit sha (`6740eba3` claim, `27cad886` RED,
  `fcd24fdb` GREEN, `4fcdcb22` screenshots + BACKLOG.md, `ba12d1d5`
  close-out). Commit: `0ced68d9`.
- **Model:** Claude Sonnet 5.

### 2026-08-25 · \[ad hoc\] S630: fix live Diagram-tab crash found while verifying pedigree-diagram.qmd screenshots (BACKLOG.md item found S582)

- **Deliverable:** verifying the pedigree-diagram.qmd article’s
  screenshots against the current app (a `BACKLOG.md`-flagged staleness
  item) surfaced a real, live crash instead: the Diagram tab errored
  `Error: subscript out of bounds` under its own default (Rectilinear)
  edge style on a realistic focal-animal trim of the real 375-individual
  bundled fixture. Root-caused (via a fresh package reinstall + a
  standalone
  [`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html)
  run with full server-log capture, ruling out a stale-build or harness
  artifact) to `.detectStraight()` inside `.resolveEdgeNodeCollisions()`
  (`R/makePedigreeDiagramData.R`, introduced by commit `c7bdbe4b`, issue
  \#160 Track 2): `xOf`/`yOf` were named atomic vectors, and `[[` throws
  on an atomic vector for an unmatched name instead of returning `NULL`
  as the existing [`is.null()`](https://rdrr.io/r/base/NULL.html) guard
  expected – so an edge referencing a node id absent from `nodes`
  (exactly what a real ancestors+descendants focal-trim union can
  produce) crashed instead of being skipped. Fixed via full strict-TDD
  RED-\>GREEN (2 new tests: a minimal synthetic dangling-reference
  fixture, and a real-fixture regression pinning the exact production
  crash), `AskUserQuestion`-gated at PRE-RED/RED-\>GREEN/
  GREEN-\>REFACTOR (no refactor needed – a 2-line change). All 5
  screenshots regenerated against the fixed app and visually confirmed
  correct; `pedigree-diagram.qmd` and `kinship2-fidelity-validation.qmd`
  re-rendered to HTML and PDF for owner review (not committed –
  regenerable review artifacts, matching the `docs/planning/*.html`
  precedent). `BACKLOG.md` staleness item (found S582) closed `[x]`.
  `NEWS.Rmd` Pedigree Diagram entry added (plain-language criterion).
  `PROJECT_LEARNINGS.md` Learning 663 recorded. `CLAUDE.md`
  learnings-count pointer refreshed (629+/662 -\> 630+/663). Not filed
  as a GitHub issue, matching the established “found-and-fixed same
  session” precedent. Commits: `27cad886` (RED), `fcd24fdb` (GREEN),
  `4fcdcb22` (screenshots + BACKLOG.md).
- **Model:** Claude Sonnet 5.

### 2026-08-24 · \[ad hoc\] S629: record close-out commit sha in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S628 precedent)

- **Deliverable:** fixed this session’s own `HANDOFFS.md` receipt
  `commit` field from `pending` to the actual close-out commit shas
  (`2e06b49c` claim, `1bedb5e5` RED, `156b67ad` GREEN, `9e643b46`
  close-out docs). Commit: `33ebae62`.
- **Model:** Claude Sonnet 5.

### 2026-08-24 · \[BL-N\] S629: fix R-CMD-check-scheduled.yaml’s chromote Chrome-launch flake (ported from R-CMD-check.yaml)

- **Deliverable:** diagnose and fix the red `R-CMD-check-scheduled` run
  found live at Phase 0 (`CLAUDE.md`’s `gh run list` CI-status
  checklist, run `32710819747`, `ubuntu-latest (release)` only). Root
  cause: `.github/workflows/R-CMD-check-scheduled.yaml` is a
  near-duplicate of `R-CMD-check.yaml` (identical 5-leg matrix,
  identical `chromote` dependency) that never received the
  S616/S618/S619 Chrome-provisioning fix, because
  `tests/testthat/ test_r_cmd_check_workflow_chrome_setup.R` guarded
  only the non-scheduled file by hardcoded path – the scheduled twin was
  free to drift with nothing catching it until its own weekly cron run
  hit the identical pre-fix failure signature
  (`chromote:::launch_chrome()` -\> `startup()` -\> “Chrome debugging
  port not open after 10 seconds”, inside
  `test_positionMatingUnitForest.R:1645`’s
  `getLiveRenderedPositions()`). Confirmed the failure was
  real-but-intermittent (not a code regression) via
  `gh run rerun --job`, which passed clean on the identical unmodified
  job – matching the exact diagnostic method Learning 647 documents for
  this failure class. Fixed via full TDD (`AskUserQuestion`-gated at
  every transition): RED parametrized the test file’s existing 4
  `test_that()` blocks to loop over both workflow files (shared helper
  functions, not a duplicated test file), confirmed failing only for the
  scheduled file, for the right reason; GREEN ported the identical
  3-step pattern (pinned `browser-actions/setup-chrome@v2` +
  `CHROMOTE_CHROME` + a
  [`chromote::find_chrome()`](https://rstudio.github.io/chromote/reference/find_chrome.html)
  pre-flight assertion, same `if: != macos-latest` guard) into
  `R-CMD-check-scheduled.yaml`. A deeper DRY alternative (a shared
  `workflow_call` reusable workflow so the 2 files can’t drift apart
  structurally) was considered and declined at the pre-RED gate as
  bigger scope than this one-off fix, owner-directed not to file as a
  follow-up.
- **Verification:** all 8 guard tests pass (was 4 pass/4 fail at RED);
  full clean regression 0 failed/0 error;
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  0 errors (1 warning + 2 notes, all pre-existing/unrelated – the
  untracked lock-file/scratchpad/knitr-figure artifacts, unrelated to
  this diff); `lintr::lint_package()` 0 lints on the touched test file;
  YAML parses clean (`python3 yaml.safe_load`). **Live-verified on real
  CI, owner-directed** (matching this project’s own established bar for
  CI-workflow fixes, S616/S618/S619): pushed all 23 pending commits
  (`git push origin master`, closing a 5-session unpushed-commit gap),
  confirming all 4 push- triggered workflows green
  (`R-CMD-check.yaml`/`lint.yaml`/`pkgdown.yaml`/`test-coverage.yaml`),
  then manually dispatched `R-CMD-check-scheduled.yaml`
  (`gh workflow run`, run `32796324964`) to verify the fixed workflow
  directly rather than waiting for next Monday’s cron.
- **BACKLOG.md:** Housekeeping item added and marked `[x]` DONE in the
  same session (found-and- fixed live, not filed as a GitHub issue,
  matching the established Track A/B/C precedent).
  `PROJECT_LEARNINGS.md` Learning 662 recorded. `CLAUDE.md`
  learnings-count pointer refreshed (628+/661 → 629+/662).
- Commits: `2e06b49c` (claim), `1bedb5e5` (RED), `156b67ad` (GREEN).
- **Model:** Claude Sonnet 5.

### 2026-08-24 · \[ad hoc\] S628: record close-out commit shas in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S627 precedent)

- **Deliverable:** fixed this session’s own `HANDOFFS.md` receipt
  `commit`/`what_was_done: pending` → real commit shas (`5c8cc7e1`,
  `815274cb`, `4f85129f`, `99572079`), matching the established
  self-reference-workaround precedent (the receipt can’t name its own
  close-out commit’s sha until after that commit exists).

### 2026-08-24 · \[BL-N\] S628: `NEWS.Rmd` dev-section simplified for a non-technical audience, reorganized by feature, guardrail landed

- **Deliverable:** simplify `NEWS.Rmd`’s `2.0.0.9000` dev-version
  entries for a non-technical (colony-manager/veterinarian) audience,
  reorganize by feature within the release heading, and design/land a
  concrete guardrail against re-drift (`BACKLOG.md` Up Next, found
  2026-08-20, owner-directed, refined 2026-08-20) – **DONE**,
  multi-round `AskUserQuestion` draft/review/ revise loop per the item’s
  own owner-stated requirement, not a single unilateral pass.
- **Guardrail (requirement 3):** extended `CLAUDE.md`’s existing
  “NEWS.Rmd entry checklist” (Session 448) with an explicit
  plain-language/no-jargon criterion. Docs-only, no in-file style note
  and no automated lint – both evaluated and explicitly declined via
  owner discussion: the in-file note’s actual beneficiary traced to
  nothing distinct (every `NEWS.Rmd` edit in this project’s history is
  session-mediated, and every session already reads `CLAUDE.md`); an
  automated banned-term lint would false-positive on legitimate domain
  vocabulary this audience already knows
  (kinship/genotype/heterozygosity vs. e.g. “a CERVUS-style multilocus
  LOD score”).
- **Taxonomy (requirement 2):** reorganized the section’s 58 entries
  into 10 feature groups (Package, Pedigree Diagram, Kinship & Pedigree
  Calculations, Marker Genetics, Cross-Center Identity Matching, Genetic
  Value Analysis, Breeding Group Formation, Mate Pair Analysis,
  De-Identified Export, General Fixes), proposed and approved via
  `AskUserQuestion` before any rewrite.
- **Two further defect classes found and fixed, both owner-caught then
  generalized project-wide rather than fixed only where first shown:**
  - **Forward-reference ordering:** entries within a group were not
    reliably in true shipping order, so a later refinement could sit
    before the feature’s own introduction (most visibly issue \#141’s
    positioning-engine entry – actually shipped 2026-08-20/21 – sitting
    first in Pedigree Diagram, ahead of everything it depended on).
    Fixed via an 8-agent background workflow doing real
    `git log`/`CHANGELOG.md` archaeology per feature group to establish
    true chronology and reorder accordingly; also caught a real
    mis-attribution (the “anchor generation mismatch” fix is S573, not
    issue \#144/S473-474 as initially assumed) and a genuine naming
    collision (Marker Genetics’ “Cross-Center” sub-tab vs. the separate
    “Cross-Center Identity” tab – fixed with a disambiguating clause
    after confirming the real UI label in `R/modMarkerGenetics.R:143`,
    not an invented rename).
  - **Delta-language for a reader-invisible “before”:** entries framed
    as “gained”/“Fixed:”/ “Changed:”/“rebuilt” relative to a prior state
    the reader never experienced, since the enclosing feature is itself
    new within this still-unreleased dev section (nothing before `2.0.0`
    – the package’s only actual CRAN-accepted version – establishes any
    reader-known baseline; owner: “everything not yet on CRAN is
    considered a draft”). Reworded to state final shipped behavior
    directly wherever the enclosing tab is itself new this release
    (Pedigree Diagram: 11 entries; Marker Genetics: 5; Cross-Center
    Identity Matching: 1); left untouched wherever the delta is
    legitimate (Kinship & Pedigree Calculations, Genetic Value Analysis,
    Breeding Group Formation, General Fixes,
    [`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)’s
    `linkedDateShift` – each confirmed pre-existing via
    `NAMESPACE`/`git log`/`NEWS.md`, not assumed).
- **Verification, mechanical not eyeballed, after every pass:** entry
  count held at 58 throughout every reorder/reword pass; all 24 distinct
  issue-number citations preserved (6 were accidentally dropped
  mid-rewrite and caught by a diff sweep before presenting);
  [`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
  (this file’s own build-equivalent) run clean after every substantive
  edit; `NEWS.md` regenerated to match. `git diff` confirmed the
  untouched rest of the file (everything from the `2.0.0` heading
  onward) byte-identical throughout.
- **`BACKLOG.md`:** item marked `[x]` DONE in place with the full
  resolution recorded. `PROJECT_ LEARNINGS.md` Learning 661 records the
  order-vs-wording generalization gap this session’s own round 2 -\>
  round 3 correction demonstrated. `CLAUDE.md` learnings-count pointer
  refreshed (627+/660 -\> 628+/661).
- **Model:** Claude Sonnet 5.

### 2026-08-23 · \[issue \#161\] S627: owner decision – keep the mating-unit node marker, no code change

- **Deliverable:** decide (owner call) whether to hide the `__union_N`
  mating-unit node marker to match kinship2’s plain-intersection
  convention (unblocked S625) – **DONE, decision-only, no code change.**
- **Evidence gathered before presenting the decision:** read
  `vignettes/articles/shiny_app_use/diagram_rectilinear_edge_style.png`
  (nprcgenekeepr’s own current rendering – a small blue dot at every
  mating junction) and
  `vignettes/articles/kinship2-fidelity-validation-img/trackC-kinship2.png`
  (kinship2’s actual output – mate-line and sibship-drop meet as a
  plain, marker-free intersection), confirming the issue’s own framing
  directly rather than trusting its prose description.
- **New finding beyond the issue’s own stated trade-off:** the
  `__union_N` node’s `title = sprintf("%d offspring", ...)` hover
  tooltip (`R/makePedigreeDiagramData.R:1067`) would be silently lost by
  the established `size = 0` + transparent-color invisible-node
  technique – confirmed by checking the D1/D2 waypoint nodes’ own
  construction (`title = NA_character_`, since a zero-size vis.js node
  isn’t hoverable). A real information-loss cost with no relation to
  kinship2 parity, not named in the original issue.
- **Presented via `AskUserQuestion`** (4 options: keep / hide everywhere
  / hide in “direct” style only / hold for a live comparison), both
  images shown, tooltip finding included. **Owner decision: keep the dot
  (status quo).**
- **Close-out:** `BACKLOG.md` item marked `[x]` DONE in place with the
  resolution recorded. [Issue
  \#161](https://github.com/rmsharp/nprcgenekeepr/issues/161) closed
  (`gh issue close --reason completed`) citing the evidence and
  decision. `PROJECT_LEARNINGS.md` Learning 660 recorded (trace a
  proposed technique against its own established precedent for hidden
  side effects before presenting a design decision); `CLAUDE.md`’s
  learning/session-count pointer refreshed (626+/659 -\> 627+/660).

### 2026-08-23 · \[BL-projectLearningsGapConfirm\] S626: confirm `PROJECT_LEARNINGS.md`/`methodology_dashboard.py` gap is NOT real – correct the record

- **Deliverable:** confirm-then-decide whether
  `methodology_dashboard.py`’s size-risk list has a real gap by omitting
  `PROJECT_LEARNINGS.md` (`BACKLOG.md` Housekeeping item, found S625) –
  **DONE, documentation-only, no code change.**
- **Finding: the S625 item’s premise does not hold.** Direct grep of
  `SESSION_RUNNER.md`/ `SAFEGUARDS.md` found no Phase 0 step that
  mandates reading `PROJECT_LEARNINGS.md` in full – only `SAFEGUARDS.md`
  (step 1), `SESSION_NOTES.md`’s ACTIVE TASK (step 2), and
  `CHANGELOG.md`/ `HANDOFFS.md` (step 6’s ledger reconcile) are named.
  `CLAUDE.md`’s own text says explicitly: “Read it when you need
  prior-session context… append new learnings there, not here” – read ON
  DEMAND (grep-by-`Learning N`, the pattern every citation actually
  uses), never read whole. `methodology_dashboard.py`’s own
  `READ_CAP_WATCHED` comment independently states the identical
  exclusion principle for `ROADMAP.md` (“cited as a pointer, never as a
  file read whole to compute anything”) – `PROJECT_LEARNINGS.md` fits
  that same excluded category, not the mandated-read category the S625
  item assumed.
- **Second reason not to hand-patch even if the premise had held:**
  `methodology_dashboard.py` is a canonical **TRACKED** dest
  (`bin/_manifest.py`, sibling `methodology` checkout,
  `starter-kit/methodology_dashboard.py` line 44); this project’s copy
  is already stale (v2.14.0 vs. canonical v2.15.2), so a local list edit
  risks silent loss or drift on the next sync – the same risk class the
  tool’s own comment already names for why
  `SESSION_RUNNER.md`/`SAFEGUARDS.md` themselves are excluded from the
  list.
- **Presented finding to the owner via `AskUserQuestion`** (3 options:
  correct the record / flag it anyway as a different, non-FM#28 risk /
  hold and dig deeper) – owner picked “correct the record.” `BACKLOG.md`
  item marked `[x]` DONE in place with the resolution recorded (not
  deleted, matching this project’s mark-DONE-not-delete convention).
  `PROJECT_LEARNINGS.md` Learning 659 recorded (confirm a predecessor’s
  premise via direct grep, even when the item is well-hedged as
  “confirm-then-decide”); `CLAUDE.md`’s learning/session-count pointer
  refreshed (625+/658 -\> 626+/659).

### 2026-08-23 · \[BL-backlogXCheckSweep\] S625: sweep 18 `[x]`-checked, fully-resolved items out of `BACKLOG.md`

- **Deliverable:** delete the accumulated `[x]`-checked DONE items out
  of `BACKLOG.md`’s “Active” and “Housekeeping” sections outright,
  matching the S548 precedent – **DONE**, documentation-only.
- **Direct re-count at claim found 18 items, not the “16” the triggering
  item (found S619) cited** (2 more checked since: S607’s MIT/REUSE
  badges, S624’s own `CLAUDE.md`-filter item). Confirmed, not
  spot-checked, every one of the 18 items’ cited session numbers
  (S574-S624) has a substantive `CHANGELOG.md` entry before deleting
  anything – spot-verified the largest deletion, the S592-S621
  same-row-collision/Walker-BJL migration chain (~590 lines), resolves
  to real dedicated `[issue #141]`-tagged entries.
- **Mechanics:** computed exact line-range boundaries via
  `grep -n "^- \[x\]\|^- \[ \]\|^## "`, deleted all 18 in one `sed` pass
  into a scratch file, verified before applying (`[x]` count 0, `[ ]`
  count unchanged 36=36, all `##` headers intact, no seam artifacts) –
  avoided iterative live-file edits across 1,000+ lines. `BACKLOG.md`
  2,192 -\> ~1,170 lines net, ~47% reduction.
- **Found and fixed one dangling cross-reference the deletion created**
  (not caught by the established `CHANGELOG.md`/Learning/file-path grep
  checklist, since it’s a same-file spatial pointer, not a citation):
  the kept issue \#161 item referenced “Tracks 1-3 above”/“the follow-up
  item below,” both now-deleted – rewritten in place noting both of
  S592’s named deferral conditions are now satisfied (Tracks 1-3 shipped
  S596; the Track 3 trade-offs resolved by the unrelated Walker/BJL
  migration, issue \#141 closed S621), unblocking \#161 for an owner
  decision.
- **Incidental finding, filed not fixed:** `methodology_dashboard.py`’s
  size-risk file list omits `PROJECT_LEARNINGS.md`, itself past the
  2,000-line FM \#28 cap (2,005 lines) – confirms a gotcha S624’s own
  `HANDOFFS.md` receipt had flagged unconfirmed. New `BACKLOG.md`
  Housekeeping item filed.
- Recorded `PROJECT_LEARNINGS.md` Learning 658 (dangling spatial
  cross-references after a `BACKLOG.md` deletion; the dashboard-coverage
  gap); `CLAUDE.md`’s learning/session-count pointer refreshed (624+/657
  -\> 625+/658). Triggering item marked `[x]` DONE in place (not deleted
  same-session, matching this project’s mark-DONE-not-delete
  convention).
- **Model:** Claude Sonnet 5.

### 2026-08-23 · \[BL-cleanRegressionFilter\] S624: remove stale test-app-*/test-e2e-* baseline-noise filter from CLAUDE.md

- **Deliverable:** fix `CLAUDE.md`’s stale “Clean regression read”
  `test-app-*`/`test-e2e-*` exclusion filter (`BACKLOG.md` Housekeeping
  item, found S623) – **DONE**, documentation-only, zero `R/`/ `tests/`
  code changed.
- **Root cause of staleness:** the filter’s own reason for existing
  (`create_test_app()` undefined, Learning \#2/#4, Sessions 3-4) no
  longer holds – `create_test_app()` is defined at
  `tests/testthat/helper-shinytest2.R:200` and has been for a long time;
  unfiltered full-regression runs report 0 failed/0 error across those
  files for weeks (S622/S623). The blanket
  `!grepl("test-app-|test-e2e-", file)` exclusion had become a live
  risk, not a convenience – it would silently hide a real regression
  landing in exactly those files, which issue \#163 (S623) nearly
  demonstrated.
- **Fix:** removed the exclusion filter from `CLAUDE.md`’s
  Build/Test/Verify section; added a dated inline note explaining why
  and warning against reviving a permanent file-name-pattern amnesty.
  Left `PROJECT_LEARNINGS.md` Learning \#2/#4 unedited (frozen
  historical record of Sessions 3-4), per this project’s
  no-retroactive-edit precedent.
- **Scope verification:** grepped the full repo for the stale filter’s
  text (~20 hits) and classified each individually before deciding scope
  – `docs/archive/*.md` (frozen), `PROJECT_LEARNINGS.md` (frozen, named
  off-limits by the originating item), a dozen `docs/planning/*.md`
  historical plans for already-closed issues or the already-shipped
  2.0.0 release, and narrative in `CHANGELOG.md`/`SESSION_NOTES.md`
  describing past sessions’ findings – only `CLAUDE.md`’s own
  Build/Test/Verify section was live, executable guidance. Recorded as
  `PROJECT_LEARNINGS.md` Learning 657.
- **BACKLOG.md:** Housekeeping item marked DONE with the resolution and
  verification recorded in place.
- **Verify:** no code touched, so no fresh full-regression run this
  session – relies on S623’s own same-day unfiltered run (6,606 passed/0
  failed/0 error/2 skipped/39 warnings). Cross-references
  (`Learning 2`/`Learning 4`, `helper-shinytest2.R:200`, issue \#163)
  grep-confirmed to resolve.
- **Model:** Claude Sonnet 5.

### 2026-08-22 · \[issue \#163\] S623: fix intermittent shinytest2 e2e-mate-pair-analysis-module E2E failure (DT server-side-render race)

- **Deliverable:** diagnose and fix the intermittent
  `test-e2e-mate-pair-analysis-module.R` failure found by S622 in the
  same nightly CI run as the (separately fixed) `e2e-pedigree-`
  regressions – **DONE**, test-only fix, zero `R/` production code
  changed.
- **Root cause, confirmed empirically, not just inferred:**
  [`modMatePairServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMatePairServer.md)‘s
  `observeEvent(input$analyze, ...)` (and every other module using the
  same pattern) flips the app’s `data-ready` attribute via
  `session$sendCustomMessage("setDataReady", ...)` the moment its
  SERVER-side reactive computation finishes – but
  `pairsTable`/`excludedTable` are `DT::renderDT(server = TRUE)`
  outputs, which then make their OWN separate client\<-\>server AJAX
  round-trip to fetch and draw the row data. `wait_for_module_ready()`
  polling `data-ready` says nothing about that second, later step.
  Confirmed via: (1) both real CI failures’ captured HTML showing the
  table’s own `.dataTables_processing` indicator still `display: block`
  (still fetching) at the moment the test read it; (2) a local
  JS-instrumented probe measuring the actual `data-ready` -\> DT-draw
  gap (~130-150ms even on a fast unthrottled machine); (3) a
  throttled-CDP- network reproduction
  (`Network.emulateNetworkConditions`) that reliably reproduces the
  exact failure (0 rows, expected id absent) without the fix and
  reliably passes with it.
- **Fix:** new shared `wait_for_dt_rendered()` helper in
  `tests/testthat/helper-shinytest2.R` (polls a DT table’s own
  `.dataTables_processing` indicator until hidden – reusable by any
  server-side DT table read in the E2E suite, not mate-pair-specific);
  wired in before both `pairsTable` and `excludedTable` reads in
  `test-e2e-mate-pair-analysis-module.R`. Caught and fixed a real bug in
  the helper’s own first draft during verification
  (`.closest('.dataTables_wrapper')` vs `.querySelector(...)` – the
  wrapper is a DOM *child* of the table’s outer container, not an
  ancestor).
- **Verification:** touched test file 5/5 clean at normal speed (0
  failed/error/warning); full project-wide regression run UNFILTERED
  (`NPRC_RUN_E2E=true`, no `test-app-*`/`test-e2e-*` exclusion – see the
  BACKLOG.md finding below): 6,606 passed / 0 failed / 0 error / 2
  skipped / 39 warnings (pre-existing, unrelated – the touched file
  itself ran 0 warnings across all 5 runs). `lintr::lint()`: 0 findings
  on both touched files.
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  deliberately skipped (test-only diff, matching S622’s own precedent
  for the identical file-type diff).
- **Incidental finding, logged not fixed:** `CLAUDE.md`’s “Clean
  regression read” guidance still instructs excluding
  `test-app-*`/`test-e2e-*` files as “pre-existing baseline noise”
  (Learning 2/4, Sessions 3-4) – that root cause (`create_test_app()`
  undefined) no longer exists
  (`tests/testthat/helper-shinytest2.R:200`), so the filter is stale and
  risks hiding a real future regression in exactly those files. Logged
  to `BACKLOG.md` Housekeeping (READY, Effort S), not fixed this session
  (out of this session’s own one-deliverable scope). This session’s own
  regression checks did not use that filter.
- Issue \#163 closed. `PROJECT_LEARNINGS.md` Learning 656 recorded.
- **Post-close-out, owner-directed:** pushed all 11 session commits to
  `origin/master` (`004eb3e9..9128ee52`), then manually dispatched
  `shinytest2.yaml` (`gh workflow run`, run `32594167345`) rather than
  waiting for tomorrow’s schedule, to confirm the fix on real CI rather
  than local verification alone. **Result: SUCCESS.**
  `e2e-mate-pair-analysis-module` group: `passed=8 failed=0 error=0`;
  `e2e-pedigree-` group (S622’s fix, same push):
  `passed=73 failed=0 error=0`. Both fixes now confirmed green on live
  GitHub Actions, not just locally.
- **Model:** claude-sonnet-5.

### 2026-08-21 · \[ad hoc\] S622: fix 2 shinytest2 e2e-pedigree- E2E assertions that broke once diagram edges route through waypoint nodes

- **Deliverable:** diagnose and fix 2 `test-e2e-pedigree-module.R`
  failures found via this session’s own Phase 0 unconditional
  `gh run list` check (CLAUDE.md, S545) – **DONE**, test-only fix, zero
  `R/` production code changed. Root-caused by direct execution
  ([`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  called locally against the real `obfuscated_rhesus_mhc_ped.csv`
  fixture, both `edgeStyle` values): `edgeStyle = "direct"` gave exactly
  the expected 56 consanguineous-marker edges, confirming the detection
  logic was correct; `edgeStyle = "rectilinear"` (the app’s actual
  default) gave 103 raw colored DOM rows that collapsed to exactly 56
  once both `__jog_` (Track 2 same-row collision jogging) and `__proj_`
  (D2 anchor/non-anchor dogleg routing) waypoint node types were treated
  as pass-through in a shared-endpoint graph analysis (cross-validated
  with `igraph::components()`). The MZ twin-connector “wrong target”
  failure was the same class of bug: the connector chain
  `E06FRB -> __jog_23_a -> __jog_23_b -> HV7LZ3` correctly reaches the
  real co-twin node, just via 2 waypoint hops instead of 1 direct edge.
  Checked the pre-Walker/BJL-cutover 2026-08-18 nightly CI log:
  identical failure shape, confirming BOTH bugs pre-date the migration
  entirely (the cutover only reshuffled which edges collide, shifting
  the raw count from 82 to 101, never introducing either defect). Fixed
  by adding 2 shared helpers to `tests/testthat/helper-shinytest2.R`
  (`count_colored_edge_lines()`, `get_edge_chain_terminus()`) that
  collapse waypoint chains before asserting, replacing the
  raw-DOM-row-count and single-hop-target assertions in
  `test-e2e-pedigree-module.R:350`/`:694`. A grep across every other
  `test-e2e-*.R` file confirmed this raw-edge-property assertion pattern
  was isolated to this one file – no further audit needed. Verification:
  `test-e2e-pedigree-module.R` run locally against the real app, 52/52
  passed, 0 failed/error (was 2 failed pre-fix); `lintr::lint()` 0
  findings on both touched files; full project-wide clean regression
  6339 passed/0 failed/0 error/0 non-baseline offenders. A third,
  unrelated, intermittent failure in the same CI run
  (`e2e-mate-pair-analysis-module`, empty results table) was explicitly
  out of scope (different module, flaky not deterministic – passed on
  the 2026-08-20 nightly run) and filed as [issue
  \#163](https://github.com/rmsharp/nprcgenekeepr/issues/163) for a
  future session. `PROJECT_LEARNINGS.md` Learning 655 recorded. See
  `HANDOFFS.md`/`SESSION_NOTES.md` for the full session record.

### 2026-08-21 · \[issue \#141\] S621: Walker/BJL Phase 4 – cleanup, docs, and issue close-out

- **Deliverable:** the migration’s final phase, per
  `docs/planning/pedigree-diagram-walker-bjl- apportioning-redesign-plan.md`’s
  own Phase 4 spec – **DONE**, documentation/cleanup only, no production
  logic changed.
  `docs/planning/pedigree-diagram-option2-layout-design-plan.md`’s D3
  section updated with a superseded-by note describing the shipped
  implementation (appended, not rewritten, matching this project’s
  precedent against retroactively editing historical planning
  narrative). Issue \#141 closed with a comment citing the full Phase
  1a-4 commit history (`8ac50a4e` S611, `0a43ec30`/`e7f1f593`/`afa7c5f5`
  S614, `891837d6` S615, `014f0910`/`e92d945e`/ `b013c009`/`01f29342`
  S620) and re-confirming D1/D2/D4/D5/D6 stayed untouched; its
  `premature optimization` label removed via `AskUserQuestion`
  (deliberately left unchanged by 3 prior sessions, S609/S620×2, as a
  decision for a future session or the owner – this was that session;
  owner picked removal, since the label’s own meaning no longer applies
  to a closed, shipped, adversarially-verified implementation).
  `BACKLOG.md`’s “Track 3’s 2 disclosed trade-offs” item closed (`[x]`):
  both trade-offs (child-centering quality, D1 bar-vs-bar overlap)
  confirmed resolved by construction – re-measured live this session, D1
  bar-vs-bar residual is now 0 on the real 375-individual fixture. A
  separate, stale “targeted repair session (READY, Effort S)” tag on the
  same item’s own single-child-union sub-thread (superseded by the S609
  redirect to this same Walker/BJL migration, but never struck) was
  found and corrected in place – a flat future `BACKLOG.md` tag grep
  would otherwise have surfaced a dead option (the function it named,
  `.computeSingleChildAntiCoincidence()`, was never shipped,
  grep-confirmed 0 hits). Stale in-code comment sweep
  (`grep -rn "Track 6\|Track 3\|computeDupNudge\|finalUnitX" R/ tests/`,
  extended beyond the plan’s own `R/ docs/` command since
  `docs/planning/*.md` is deliberately left as historical record): `R/`
  was already accurate (S620 had already annotated its own doc comments
  correctly); one genuinely stale docstring found and fixed in
  `tests/testthat/test_makePedigreeMatingLayout.R` (a test’s own
  multi-line description still narrated the OLD Track 3 clamp’s “1,202 +
  210 = 1,412” arithmetic and its “coincidentally resolves” framing;
  replaced with the current, directly-executed composition – 1,412
  unchanged, but now correctly decomposed as 1,258 structural + 154 jog
  waypoints, not the stale formula). Tutorial/article and
  `a2interactive.Rmd` checklists explicitly re-confirmed N/A (not merely
  assumed): grepped both for algorithm-specific claims
  (contour-merge/Reingold/Walker/Buchheim/ `orderBySex`) – zero hits in
  either; the vignette’s own “5 reserved node-id prefixes” comment was
  independently confirmed still accurate (`__proj_` is pre-existing
  `.buildMatingUnitForest()` dogleg infrastructure, unrelated to and
  unaffected by this migration, not a new prefix this migration
  introduced). `NEWS.Rmd` needs no further entry – S620’s own entry
  already discloses the user-facing change completely. No new
  test/lint/check run required (no assertions or production logic
  changed); the one behavior-preserving test-docstring edit was
  spot-verified via
  [`testthat::test_file()`](https://testthat.r-lib.org/reference/test_file.html)
  on the touched file (all green) rather than a full regression, since
  nothing else in the diff could affect other files.

### 2026-08-21 · \[issue \#141\] S620: Walker/BJL Phase 3 cutover – production call-site swap

- **Deliverable:** cut over `.positionMatingUnitForest()` from the OLD
  Reingold-Tilford/Walker-style contour-merge implementation to the
  Walker/Buchheim-Jünger-Leipert engine built across S610-S615, per
  `docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md`’s
  Migration Path Phase 3 – **DONE**, full TDD RED→GREEN→REFACTOR cycle,
  `AskUserQuestion`-gated at every transition. `.computeDupNudge()` and
  the OLD implementation deleted outright;
  `.positionMatingUnitForestBJL()` renamed to
  `.positionMatingUnitForest()`, replacing it as the sole production
  positioning engine. Restructured from the plan’s own literal “Commit
  3-1 (4 files) / Commit 3-2 (2 files, conditional)” split, per the
  plan’s own explicit fallback clause:
  `test_addRectilinearWaypoints.R`/`test_resolveEdgeNodeCollisions.R`
  genuinely needed re-pinning (measured via a monkey-patch probe, not
  assumed), so all 5 test files landed in one RED commit with production
  code in a separate GREEN commit – Commit 3-2 does not exist as a
  separate step. 2 genuine implementation defects found and fixed during
  GREEN (input-validation guards missing; a both-sire-and-dam-dangling
  mating unit crashed on an empty `rootIds`, issue \#154’s own original
  fix having no BJL equivalent). `orderBySex` removed from
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
  public signature (owner-directed) – Phase 1b’s design note had already
  found the mechanism “restructured, not preserved unchanged,” folded
  unconditionally into the new engine with no way to disable it, and
  zero real callers ever passed it. Live-render verification
  (F1/Track-C, real-375 fixtures) confirmed passing. Full clean
  regression 0 failed/0 error throughout; `lintr::lint_package()` 0
  findings;
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  0 errors, 1 WARNING + 2 NOTEs all pre-existing (a 4th, new Rd
  cross-reference warning found and fixed in-session). CI green on all 4
  workflows. Commits: `014f0910` (claim), `e92d945e` (RED, amended once
  to fold in 4 GREEN-phase test corrections), `b013c009` (GREEN),
  `01f29342` (REFACTOR). `BACKLOG.md`’s Walker/BJL item updated with the
  full S620 narrative; `PROJECT_LEARNINGS.md` Learnings 650/651/652
  recorded. **Next: Phase 4** (cleanup/documentation, issue \#141
  close-out) — its own separate session.

### 2026-08-20 · \[ad hoc\] S619: fix R-CMD-check.yaml’s macos-latest chromote CDP timeout

- **Deliverable:** diagnose AND fix the `macos-latest` chromote
  `Runtime.evaluate` CDP timeout in `R-CMD-check.yaml` (`BACKLOG.md`
  Housekeeping item, found S618) – **DONE, all 5 matrix legs green.**
  Root cause found via a 6-agent research workflow doing direct chromote
  0.5.1 source inspection: `ChromoteSession$new()` unconditionally
  issues an internal `Runtime.evaluate` command during its own bootstrap
  (`private$get_pixel_ratio()`) governed by a 10s `default_timeout` with
  no constructor argument to raise it. First fix attempt (raise
  `default_timeout` to 60s, `helper-live-render-positions.R`, full TDD
  RED/GREEN) was pushed and verified via real CI to NOT resolve the
  failure (identical signature, wall time roughly doubled, confirming a
  genuinely wedged session, not slow – run `32417985922`) – reported
  honestly rather than silently retried, recorded as
  `PROJECT_LEARNINGS.md` Learning 648. Fallback fix (revert
  `macos-latest` specifically to ambient/unpinned Chrome via an `if:`
  guard on the 3 Chrome-provisioning steps, matching S616’s own
  proven-green precedent for that leg, full TDD RED/GREEN) verified
  GREEN on the next real CI push (run `32423688930`, all 5 legs green,
  `macos-latest` in 10m4s) – recorded as Learning 649. `BACKLOG.md`’s
  chromote item removed outright (fully resolved); a new, explicitly
  optional/low-priority item added for the still- unexplained
  pinned-binary hang mechanism. Commits: `40c2e96b` (claim), `ff091613`
  (BACKLOG housekeeping filing, unrelated mid-session user question),
  `1553099a` (H1 RED), `1780789d` (H1 GREEN), `4a134701` (fallback RED),
  `d2e9f487` (fallback GREEN).

### 2026-08-20 · \[ad hoc\] S619: file BACKLOG.md item for stale \[x\] DONE-item sweep

- **Deliverable:** owner noticed `BACKLOG.md` still carries 16
  `[x]`-checked DONE items despite its own “open, actionable work only”
  header. Investigated: confirmed each already has a dated
  `CHANGELOG.md` entry (spot-checked, nothing at risk of loss);
  confirmed this matches an established periodic-batch-sweep precedent
  (S548, 2026-08-13, “delete 61 resolved BACKLOG.md pointer bullets
  outright”) rather than a new process break. Filed a new `BACKLOG.md`
  Housekeeping item (READY, Effort S) for a future sweep session, per
  owner direction to keep the current macOS CDP-timeout diagnosis
  (S619’s own claimed task) uninterrupted.

### 2026-08-20 · \[ad hoc\] S618: port Chrome-provisioning into R-CMD-check.yaml (windows-latest fixed, macos-latest still open)

- **Deliverable:** fixed `R-CMD-check.yaml`’s intermittent chromote
  Chrome-launch failure (`BACKLOG.md` Housekeeping item, found S616) on
  `windows-latest` – ported `shinytest2.yaml`’s
  `browser-actions/setup-chrome@v2` + `CHROMOTE_CHROME` +
  `find_chrome()` preflight pattern via full TDD
  (PRE-RED→RED→GREEN→REFACTOR, `AskUserQuestion`-gated at every
  transition). New
  `tests/testthat/test_r_cmd_check_workflow_chrome_setup.R` guards the
  pattern structurally. 1st real CI push found the port only partly
  worked: `windows-latest` still failed identically because the
  `CHROMOTE_CHROME` env-export step uses bash syntax, which silently
  no-ops under `windows-latest`’s default PowerShell shell
  (`shinytest2.yaml` never needed `shell: bash` since it’s ubuntu-only)
  – fixed by adding `shell: bash`, with a new RED test locking in the
  requirement. Confirmed GREEN on 2 real CI pushes. **Same 2 pushes
  surfaced a NEW, distinct problem on `macos-latest`** (previously
  green):
  `Chromote: timed out waiting for response to command Runtime.evaluate`
  with `CHROMOTE_CHROME` confirmed correctly set both times (2/2
  recurrence) – a live CDP round-trip timeout, not a launch failure,
  ruling out both the shell bug and pure one-off resource contention.
  Owner-directed to defer investigation to a future session rather than
  continue speculative fixing. `ubuntu-latest (oldrel-1)`’s red on the
  2nd push confirmed unrelated (r-hub.io R-version-resolution API infra
  noise, transient — passed clean on rerun). `BACKLOG.md`’s chromote
  item updated in place with the full finding (not checked off — macOS
  remains open). Recorded `PROJECT_LEARNINGS.md` Learnings 646/647.
- **Model:** Claude Sonnet 5.

### 2026-08-20 · \[ad hoc\] S617: sync methodology framework to canonical v3.7 (hand-reconciled)

- **Deliverable:** synced this project’s canonical-overlay methodology
  files toward `v3.7` of `https://github.com/KJ5HST/methodology.git`,
  hand-reconciled rather than blind-overlaid after discovering
  `FRAMEWORK_LEARNINGS.md`/`methodology_trim.py` have never existed in
  any tagged canonical release (they trace to the 2026-08-10 sync
  actually running against the `rmsharp/methodology` fork’s unreleased
  `main` branch, `v3.6-255-gc43e7ee`) and that local
  `methodology_dashboard.py` (2.14.0) is genuinely newer than true
  v3.7’s (2.10.6). Adopted FM \#28 “Unbounded mandatory read” + 4
  Degradation Detection rows into `SESSION_RUNNER.md`; applied
  `RECOMMENDED_SKILLS.md`’s improved `/caveman` description; preserved
  the local `FRAMEWORK_LEARNINGS.md`-extraction pattern (21 rows
  vs. v3.7’s inline 13) and `methodology_dashboard.py` at 2.14.0 per
  owner direction (`AskUserQuestion`); corrected `CLAUDE.md`’s
  inaccurate claim that `methodology_trim.py` is a canonical-overlay
  file; fixed a stale “27 failure modes” cross-reference; filed a
  `BACKLOG.md` item for the new-in-v3.7 `context_budget.py` (not adopted
  this session); recorded `PROJECT_LEARNINGS.md` Learning 645.
- **Model:** Claude Sonnet 5.

### 2026-08-20 · \[ad hoc\] S616: post-close-out correction folded into SESSION_NOTES.md/HANDOFFS.md (S575/S603/S607 precedent)

- **Deliverable:** the owner flagged that the prior conversational recap
  was not a formal Phase 3G report (a context interruption meant the
  actual close-out content was never shown before this session continued
  into the BACKLOG.md addendum below). Folded BOTH the missed-report gap
  and the NEWS.Rmd item’s by-feature scoping clarification into S616’s
  own `SESSION_NOTES.md` record and `HANDOFFS.md` receipt (`gotchas`/new
  “Post-close-out correction” paragraph), rather than leaving the
  addendum below as a bare, disconnected CHANGELOG line — matching this
  project’s own established precedent (S575, S603, S607) for disclosing
  a found-after-the-fact correction in the session’s own durable record,
  not just the ledger.
- **Model:** Claude Sonnet 5.

### 2026-08-20 · \[ad hoc\] S616 addendum: clarify NEWS.Rmd BACKLOG.md item’s by-feature scoping

- **Deliverable:** owner asked (post-close-out, same conversation) that
  the NEWS.Rmd simplification item’s “reorganize by feature” requirement
  explicitly scope to WITHIN each release heading, not across them.
  `BACKLOG.md`’s existing item (filed this session) edited to add that
  scoping explicitly, plus a note that release headings themselves keep
  their existing reverse-chronological order. No other file changed.
- **Model:** Claude Sonnet 5.

### 2026-08-20 · \[ad hoc\] S616: record close-out commit sha in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S615 precedent)

- **Deliverable:** `HANDOFFS.md`’s S616 receipt `commit:` field updated
  from `pending` to the actual close-out commit sha (`25fd57cd`).
- **Model:** Claude Sonnet 5.

### 2026-08-20 · \[ad hoc\] S616: close out (fix confirmed GREEN, 2 BACKLOG.md items filed, Learnings 643/644)

- **Deliverable:** `SESSION_NOTES.md` Session 615 handoff evaluation
  (7/10, a structural ceiling — the failure this session fixed was
  triggered by S615’s own closing push, so S615’s handoff could not have
  anticipated it) + full Session 616 handoff (self-score 8/10);
  `HANDOFFS.md` S616 receipt completed (`status: complete`).
- **Model:** Claude Sonnet 5.

### 2026-08-20 · \[ad hoc\] S616: file 2 BACKLOG.md items found this session

- **Deliverable:** (1) Simplify `NEWS.Rmd` entries for a non-technical
  audience, reorganized by feature not chronologically, with a
  designed-and-landed guardrail against recurrence (owner-directed,
  READY, Effort L) — S538 (2026-08-12) trimmed the dev-section once with
  no guardrail; it regrew from 134 to 315 lines / 26 to 57 entries in 8
  days in the same verbose/technical style. (2) `R-CMD-check.yaml`’s
  chromote tests can hit an intermittent `chromote:::launch_chrome()`
  process-launch failure, distinct from the `Page.loadEventFired` race
  fixed this session and unmitigated unlike `shinytest2.yaml`’s own
  already-solved version of the same problem
  (`browser-actions/setup-chrome@v2` + `CHROMOTE_CHROME` +
  assert-resolvable, per `docs/planning/phase8-e2e-harness-subplan.md`
  Risk R5) — owner-directed to file separately rather than fold into
  this session, matching “1 and done.”
- **Model:** Claude Sonnet 5.

### 2026-08-20 · \[ad hoc\] S616: fix R-CMD-check.yaml windows-latest chromote timeout (Page.loadEventFired race)

- **Deliverable:** `tests/testthat/helper-live-render-positions.R`’s
  `getLiveRenderedPositions()` (shipped S615) used the manual
  `Page$navigate()` + `Page$loadEventFired(timeout_ = loadTimeout)`
  sequence, a documented chromote race (rstudio/chromote#102, the
  package’s own “Loading a page reliably” vignette): the load event can
  fire in the gap between the 2 calls, before R registers a listener, so
  the 2nd call then waits the FULL timeout for an event that will never
  fire again. Surfaced as `R-CMD-check.yaml` red on `windows-latest`
  only (run `32335116264`, triggered by S615’s own final push) — the
  other 4 matrix platforms (macOS, 3× Linux) were unaffected, a slower/
  busier CI runner being exactly what tips a race from “usually wins” to
  “loses.” Fixed by replacing the 2-call sequence + a trailing
  `Sys.sleep(waitSeconds)` with chromote’s own documented reliable
  alternative, a single
  `$go_to(url, timeout_ = loadTimeout, delay = waitSeconds)` call, which
  registers the listener before navigating. `PROJECT_LEARNINGS.md`
  Learning 643.
- **Diagnosis method:** downloaded the failed run’s actual
  `nprcgenekeepr.Rcheck` artifact (`gh run download`) rather than
  trusting the annotation summary; confirmed both Windows failures were
  the identical
  `Chromote: timed out waiting for event Page.loadEventFired` at
  `helper-live-render-positions.R:84`. Root cause identified via
  `WebSearch`/`WebFetch` against chromote’s own documentation/issue
  tracker, not guessed. No local Windows environment was available — the
  fix’s verification is 2 consecutive real `R-CMD-check.yaml` pushes
  going GREEN on `windows-latest`, the only faithful check for a
  CI-platform-timing-specific defect. A owner- directed pre-RED
  `AskUserQuestion` established this approach (no new local test — a
  race condition can’t be deterministically captured in a fast local
  unit test; the existing 2 chromote tests + the real CI run serve as
  RED/GREEN).
- **Incidentally found, NOT fixed this session (filed to `BACKLOG.md`
  instead, owner-directed):** a SECOND, unrelated chromote failure
  (`chromote:::launch_chrome()` process-launch abort) appeared on
  `ubuntu-latest (release)` in the very next CI run — confirmed NOT
  caused by this session’s diff (`$go_to()` only touches post-connection
  page-load waiting, never process launch) and confirmed transient by
  re-running the same job unmodified (`gh run rerun --job`), which
  passed clean.
- **Verification:** full clean regression 0 failed/0 error (incl. all 24
  chromote tests), `lintr::lint()` 0 findings, both confirmed locally
  before push; `windows-latest` GREEN on 2 consecutive real
  `R-CMD-check.yaml` runs after the fix.
- **Model:** Claude Sonnet 5.

### 2026-08-20 · \[ad hoc\] S616: claim session for R-CMD-check Windows chromote timeout fix

- **Deliverable:** `SESSION_NOTES.md` stub + `HANDOFFS.md`
  `status: pending` receipt, committed (`db736a3d`) — written after
  diagnosis had already begun (a disclosed Phase 1B-skip, see
  `PROJECT_LEARNINGS.md` Learning 644), not at the ideal point, but
  before any code change.
- **Model:** Claude Sonnet 5.

### 2026-08-20 · \[ad hoc\] S615: record close-out commit sha in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S614 precedent)

- **Deliverable:** `HANDOFFS.md`’s S615 receipt
  `commit:`/`changelog_ref:` fields updated from `pending` to the actual
  close-out commit sha (`ac2723b5`) and the dated `CHANGELOG.md` entry
  pointer.
- **Model:** Claude Sonnet 5.

### 2026-08-20 · \[issue \#141\] S615: Phase 2b GREEN – Walker/BJL real-fixture + live-render verification

- **Deliverable:** New reusable
  `tests/testthat/helper-live-render-positions.R`
  (`getLiveRenderedPositions()` – renders via the app’s own
  `visNetwork()`/`visPhysics(FALSE)` call, drives `chromote` headless,
  reads back ground truth via vis.js’s own `getPositions()`), completing
  the parent plan’s own Phase 2 “New deliverable… fixing C2-4.” 7 new
  tests added to `tests/testthat/test_positionMatingUnitForestBJL.R` (24
  total): a helper smoke test; the real 375-individual fixture’s own
  zero-exact-x/gen-coincidence gate (“the single most important test in
  the whole migration” – PASSES); the exact-midpoint invariant re-run on
  real data (previously synthetic-only, PASSES); single-child-union
  near-parent prevalence re-measurement (224/237 structural, unchanged;
  new breakdown 180/224 touching \<=31px / 208/224 half-column \<=60px
  vs. the OLD algorithm’s clamp-affected 175/224 / 203/224 – comparable,
  not dramatically reduced); Phase 1b sec8.4 Obligation 2’s combined
  trigger-frequency measurement (34 `orderBySex`-qualifying B1 unions,
  drift range 0.399-0.401, inside the disclosed cosmetic bound); 2
  live-render checks (F1/“Track C” 9-subject fixture, real
  375-individual/714-node fixture).
- **Major incidental finding (`PROJECT_LEARNINGS.md` Learning 641):**
  live-rendering revealed vis.js’s `getPositions()` rounds reported
  coordinates to the nearest whole pixel, so the shared 1e-3-raw-unit
  “cosmetic” tie-break nudge used by BOTH `.positionMatingUnitForest()`
  (OLD) and `.positionMatingUnitForestBJL()` (NEW) – `xScale=120`, so
  0.12px – renders pixel-identical to whatever it was nudged away from.
  Measured side by side on the real fixture, same script, same helper:
  OLD 368/714 nodes pixel-coincident (182 groups), NEW 380/714 (190
  groups) – comparable, a pre-existing characteristic shared by both
  algorithms, not a Phase 2b regression. Owner-directed
  (`AskUserQuestion`, on finding this): Tests 6/7 redesigned as
  diagnostics (DataSet-integrity hard gate – confirmed clean, no id
  silently collapses in vis.js’s own DataSet on either fixture – plus a
  [`message()`](https://rdrr.io/r/base/message.html)-reported
  measurement), not a hard pixel-coincidence gate neither algorithm
  actually clears.
- **2 real implementation bugs found and fixed during GREEN, both via
  direct execution:** (1) chromote’s own 10-second default
  `Page$loadEventFired()` timeout was too short for the 714-node
  fixture’s self-contained HTML – added a `loadTimeout` parameter
  (default 30s, 60s used for the real fixture); (2) a NEW
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  WARNING (“unstated dependencies in tests: chromote, htmlwidgets”) from
  copying `data-raw/kinship2FidelityValidation.R`’s own `pkg::fn()` call
  pattern (safe there – that script is `.Rbuildignore`d) into the
  CHECKED `tests/testthat/` surface – fixed per the user’s own clarified
  packaging rule (`Suggests:` for anything test/example/
  vignette-needed, `Config/Needs/<name>:` for dev-tooling-only packages)
  by adding `chromote`/ `htmlwidgets` to `DESCRIPTION`’s `Suggests:`
  (`renv::snapshot(dev=TRUE)` needed no lockfile changes – both already
  transitively pinned). `PROJECT_LEARNINGS.md` Learning 642.
  Incidentally also relocated `covr` (pure coverage tooling, already
  CI-installed independently via `.github/workflows/test-coverage.yaml`)
  from `Suggests:` to a new `Config/Needs/coverage: covr`, user-flagged
  mid-session.
- **Verification:** 24/24 tests GREEN; full clean regression 0 failed/0
  error project-wide (confirmed twice – a direct `test_dir()` run and
  again inside
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)’s
  own `testthat.R`); `lintr::lint_package()` 0 findings project-wide;
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  0 errors / 1 WARNING / 2 NOTEs, all 3 pre-existing (non-portable
  filename, `scratchpad/` top-level dir, `vignettes/figure/` knitr
  leftover) – identical to S614’s own baseline, zero new.
  `.positionMatingUnitForestBJL()` itself unchanged – Phase 2b touched
  zero production code.
- **Model:** Claude Sonnet 5.

### 2026-08-20 · \[issue \#141\] S615: Phase 2b close-out (BACKLOG/PROJECT_LEARNINGS/SESSION_NOTES/HANDOFFS)

- **Deliverable:** `BACKLOG.md`’s Walker/BJL item updated with the Phase
  2b progress paragraph plus a new Housekeeping item (`DESCRIPTION`’s
  `Suggests:`/`Config/Needs/` cleanup, user-directed, not fixed this
  session beyond `covr`); `PROJECT_LEARNINGS.md` Learnings 641 (vis.js
  pixel-rounding vs. the shared cosmetic tie-break nudge) and 642 (the
  `R CMD check` unstated-test-dependencies gotcha); `SESSION_NOTES.md`
  Session 614 handoff evaluation (9/10) + full Session 615 handoff;
  `HANDOFFS.md` S615 receipt completed (`status: complete`,
  `self_score: 9`).
- **Model:** Claude Sonnet 5.

### 2026-08-19 · \[ad hoc\] S614: record close-out commit sha in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S613 precedent)

- **Deliverable:** `HANDOFFS.md`’s S614 receipt `commit:` field updated
  from `pending` to the actual close-out commit sha (`55cd2875`).
- **Model:** Claude Sonnet 5.

### 2026-08-19 · \[issue \#141\] S614: Phase 2a GREEN – Walker/BJL pedigree adapter (`.positionMatingUnitForestBJL()`)

- **Deliverable:** New `.positionMatingUnitForestBJL()` in
  `R/makePedigreeDiagramData.R`, alongside `.positionMatingUnitForest()`
  – zero changes to that function or any other existing code, no shared
  call site yet. Implements the 3-tier reconciliation
  [`docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-reconciliation.md`](https://github.com/rmsharp/nprcgenekeepr/docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-reconciliation.md)
  settles on: Tier 1 genuine-tree BJL (`.positionTreeApportion()`, Phase
  1a, unchanged) via a `CHILDREN(individual)` accessor, terminated by a
  reinstated `sweepMinSep()` backstop; Tier 2 union-midpoint
  derivation + exact-tie sweep; Tier 3 B1/B3 derived points using §8.1’s
  fixed formula (anchored on the anchor’s own final Tier-1 `x`, never
  the union’s). Owner-directed scope split (Phase 2’s own “splittable if
  too large” allowance, via `AskUserQuestion` before RED): this session
  covers adapter mechanics only (“Phase 2a”) – the live-render helper
  and real-375-fixture A/B verification are explicitly deferred to a
  required Phase 2b session, not done here.
- New
  [`tests/testthat/test_positionMatingUnitForestBJL.R`](https://github.com/rmsharp/nprcgenekeepr/tests/testthat/test_positionMatingUnitForestBJL.R):
  17 `test_that()` blocks (the design note’s own 15-fixture matrix, §4
  Tests 1-14 + §8.4’s required Test 15, plus 3 property tests), all
  synthetic/hand-built. Full strict-TDD cycle, every transition gated
  via `AskUserQuestion`: PRE-RED (grounded in both planning docs) → RED
  (confirmed genuine, 0 fixture bugs in pre-function assertions) → GREEN
  (found and fixed 2 real implementation defects – B1 eligibility needed
  an explicit `!hasParentEdge(M)` conjunct the OLD shipped `freePassIds`
  helper doesn’t carry; a dangling non-anchor id crashed on
  `sireOf[[id]]`, fixed by excluding dangling ids up front) → REFACTOR
  (2 style-only lint fixes). Verified 3 times: 17/17 GREEN (53
  expectations), full clean regression 0 failed/0 error project-wide
  each time, `lintr::lint()` 0 findings, and a full
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  (1 WARNING + 2 NOTEs, all 3 confirmed pre-existing and unrelated to
  this diff). `PROJECT_LEARNINGS.md` Learnings 639/640 recorded.
  `BACKLOG.md`’s Walker/BJL item updated with the S614 progress
  paragraph.
- **Model:** Claude Sonnet 5.

### 2026-08-19 · \[ad hoc\] S613: record close-out commit sha in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S612 precedent)

- **Deliverable:** `HANDOFFS.md`’s S613 receipt `commit:` field updated
  from `pending` to the actual close-out commit sha (`3d5019b0`).
- **Model:** Claude Sonnet 5.

### 2026-08-19 · \[issue \#141\] S613: Phase 1b continuation – sweepMinSep()/orderBySex seam RESOLVED, first-attempt sound

- **Deliverable:**
  [`docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-reconciliation.md`](https://github.com/rmsharp/nprcgenekeepr/docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-reconciliation.md)
  §8 – resolves the seam S612’s round-4 critique found (§7): reinstating
  `sweepMinSep()` broke an invariant the `orderBySex` sign-fold formula
  depended on. Fix: anchor `M_repr.x` on the frozen Tier-1 `P.x`
  directly instead of the drift-prone Tier-2 `U.x(FINAL)`, gated on the
  same `mateCount==1` qualifying test the shipped `orderBySex` code
  already uses. A repair→3-lens adversarial-critique `Workflow` (4
  agents) found this sound on its **first** attempt – no repair round 2
  needed, the first first-attempt-sound outcome across this
  investigation’s 5-round design-note history plus 6 prior full
  implementation attempts. Proof holds for any drift magnitude, not just
  the 2 executed counter-examples §7 produced. 2 implementation-time
  obligations disclosed for Phase 2 (a required new Test 15 + a
  P.x-freshness assertion; a widened cosmetic-disclosure scope), written
  into the design note as binding conditions, not open questions.
  **Phase 2 (pedigree adapter, parallel to production) is now READY.**
  Zero production code touched. `BACKLOG.md`’s Walker/BJL item updated
  with the S613 progress paragraph. `PROJECT_LEARNINGS.md` Learning 638
  recorded (eliminate-the-invariant-dependency pattern).
- **Model:** Claude Sonnet 5.

### 2026-08-19 · \[ad hoc\] S612: record close-out commit sha in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S611 precedent)

- **Deliverable:** `HANDOFFS.md`’s S612 receipt `commit:` field updated
  from `pending` to the actual close-out commit sha (`c95b4b74`).
- **Model:** Claude Sonnet 5.

### 2026-08-19 · \[issue \#141\] S612: Phase 1b research/design spike – substantial progress, honest non-terminal outcome

- **Deliverable:**
  [`docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-reconciliation.md`](https://github.com/rmsharp/nprcgenekeepr/docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-reconciliation.md),
  the Walker/BJL redesign’s Phase 1b forest/mixed-gen reconciliation
  design note. Cases (a)/(b)/(c)/(d) and the core “eliminate 0-delta
  edges from the recursion” architecture (Candidate 2b) validated across
  3 adversarial critique rounds, corroborated by direct reads of
  CraneFoot’s and kinship2’s own real source. A 4th critique round found
  the interaction between the reinstated `sweepMinSep()` backstop and a
  new `orderBySex` sign-fold formula is unsound (executed
  counter-example: the fix inverts the male/female ordering it exists to
  preserve) – disclosed, not hidden, with 3 candidate fixes named for a
  follow-up continuation session. Zero production code touched.
  `BACKLOG.md`’s Walker/BJL item updated with the S612 progress
  paragraph. `PROJECT_LEARNINGS.md` Learnings 636
  (workflow-chaining-via-files) and 637 (interaction-seam critique
  pattern) recorded.
- **Model:** Claude Sonnet 5.

### 2026-08-19 · \[ad hoc\] S611: record the HANDOFFS.md sha-fix action itself (bd95d164)

- **Deliverable:** the sha-fix commit itself (`bd95d164`) recorded here
  per failure mode \#27 applying even to the self-referential
  sha-backfill commit — matching S600/S602-S610 precedent exactly.
- **Model:** Claude Sonnet 5.

### 2026-08-19 · \[ad hoc\] S611: record close-out commit sha in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S610 precedent)

- **Deliverable:** `HANDOFFS.md`’s S611 receipt `commit:` field updated
  from `pending` to the actual close-out commit sha (`8ac50a4e`).
- **Model:** Claude Sonnet 5.

### 2026-08-19 · \[issue \#141\] S611: implement Phase 1a — standalone BJL apportioning engine (RED→GREEN→REFACTOR), commit `8ac50a4e`

- **Deliverable:** `R/positionTreeApportion.R`
  (`.positionTreeApportion()`/ `.buildForestChildrenOf()`,
  internal/non-exported) + `tests/testthat/test_positionTreeApportion.R`
  (5 `test_that()` blocks / 8 exact-value expectations: single node;
  balanced 3×3 n-ary tree; asymmetric deep-narrow + wide-shallow tree; a
  3-tree forest via a synthetic-super-root helper; Walker’s own 15-node
  worked example, TR89-034 Figure 12, as the required golden test). Zero
  changes to `R/makePedigreeDiagramData.R` or any existing test file.
  `BACKLOG.md`’s Track 3 item updated with Phase 1a progress.
  `PROJECT_LEARNINGS.md` gained Learnings 634-635
  (d3-hierarchy-as-executable-oracle technique; the `test_dir()`
  Shiny-reactive-crash environment gotcha, not previously documented).
  `CLAUDE.md`’s learnings-count pointer updated.
- **PRE-RED research:** downloaded and read Walker’s primary source
  (TR89-034, UNC, 1989) directly, not a secondary summary. Installed
  real `d3-hierarchy` v3.1.2 via Node.js and ran it to independently
  cross-check the primary-source extraction (exact match on all 15
  nodes, relative to root) and generate exact-value oracles for the
  other 3 fixtures by actually running the reference implementation.
  **Found and proved** (via a constructed adversarial fixture, not mere
  inspection) a real defect in the plan’s own `apportion()` pseudocode:
  a missing modifier- accumulator update
  (`vip_mod`/`vop_mod += shiftVal`) immediately after `moveSubtree()`
  fires, present in real d3-hierarchy’s own source
  (`sip`/`sop += shift`) but omitted from the plan.
- **RED→GREEN→REFACTOR:** RED confirmed genuine (5/5 tests erroring
  “could not find function,” not vacuous). GREEN: all 8 expectations
  passed on the **first** implementation attempt. REFACTOR: 53→0 `lintr`
  findings (line-length, implicit-integer, one unnecessary-lambda),
  structure only, re-verified 8/8 GREEN after. Full clean-regression
  read (277 files, excluding documented
  `test-app-*`/`test-e2e-*`/`appServer`/`shinytest2` baseline noise) run
  3 times (RED/GREEN/REFACTOR checkpoints): 0 failed/0 error every time.
- **Model:** Claude Sonnet 5.

### 2026-08-19 · \[ad hoc\] S611: file BACKLOG.md item — investigate factoring out pedigree-diagram drawing into a separate R package

- **Deliverable:** owner-directed `BACKLOG.md` “Up Next” item —
  research/scope whether to split the pedigree-diagram layout/rendering
  code out of `nprcgenekeepr` into its own dependency package
  (advantages/disadvantages, not a decision). Explicitly sequenced after
  the in-progress Walker/BJL apportioning redesign (issue \#141) to
  avoid package-boundary churn mid-algorithm-change.
- **Model:** Claude Sonnet 5.

### 2026-08-19 · \[ad hoc\] S610: record the HANDOFFS.md sha-fix action itself (fd8c64d0)

- **Deliverable:** the sha-fix commit itself (`fd8c64d0`) recorded here
  per failure mode \#27 applying even to the self-referential
  sha-backfill commit — matching S600/S602-S609 precedent exactly.
- **Model:** Claude Sonnet 5.

### 2026-08-19 · \[ad hoc\] S610: record close-out commit sha in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S609 precedent)

- **Deliverable:** `HANDOFFS.md`’s S610 receipt `commit:` field updated
  from `pending` to the actual close-out commit sha (`3eb6c0bf`).
- **Model:** Claude Sonnet 5.

### 2026-08-19 · \[issue \#141\] S610: close out (Walker/BJL apportioning redesign — architecture plan)

- **Deliverable:**
  [`docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md`](https://github.com/rmsharp/nprcgenekeepr/docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md)
  (642 lines) — the planning session
  `pedigree-diagram-single-child-union-parent-coincidence-investigation.md`
  §11 called for, scoping a complete
  Reingold-Tilford/Walker/Buchheim-Jünger-Leipert apportioning redesign
  of D3 (`.positionMatingUnitForest()`) across 5 phases. **Planning only
  — no production code written or modified**
  (`git status --porcelain -- R/ tests/` empty throughout).
- **Method:** an 8-agent `Workflow` (3 parallel research passes → design
  synthesis → 3 parallel adversarial critique lenses → repair; 162 tool
  calls, 1.24M subagent tokens, 0 errors). **All 3 critique lenses
  returned `designSound: false` on the first draft.** The decisive
  finding: the draft’s own proposed reconciliation mechanism (a “global
  LEFTNEIGHBOR table”) was *misattributed* (real BJL **replaces**
  Walker’s global per-level table with a purely local sibling lookup —
  the draft claimed the opposite) and *mechanically unsound* (a
  non-sibling comparison partner breaks `moveSubtree`/`executeShifts`’s
  sibling-indexed bookkeeping), and would have reintroduced this
  investigation’s own signature “one-directional sweep, first one wins”
  failure shape **one level down, inside the replacement algorithm’s own
  internals** — a 7th instance of the same root cause, caught at the
  planning stage rather than after implementation.
- **Independent verification found 2 errors the critiques missed**, both
  corrected and documented in the plan as corrections: (1) a real file
  misattribution — the `-6.0`/`90`/`129.06` gate-behavior pins are in
  `test_positionMatingUnitForest.R` (`:1582`/`:1491`/`:1524`), not
  `test_makePedigreeMatingLayout.R` as the draft’s inventory *and* its
  Phase 3 commit list both claimed; traced to a critique agent
  conflating that file’s name with the other file’s line count
  (`test_positionMatingUnitForest.R` is exactly 1,583 lines). (2) Two
  `test_that()` block counts (18→19, 44→46).
- **Plan shape:** Phase 1a standalone BJL engine (genuine trees only,
  cross-checked against MIT-licensed `d3-hierarchy`); **Phase 1b (NEW,
  required, gates Phase 2)** a research/design spike for the
  forest/mixed-gen reconciliation problem the literature does not
  address at all — this project’s forest has 0-delta tree edges no
  Reingold-Tilford/Walker/BJL no-overlap proof covers, and 1b may
  legitimately conclude “more research needed”; Phase 2 adapter built
  parallel to production plus a reusable
  `helper-live-render-positions.R` chromote harness; Phase 3 cutover in
  2 scoped commits (4 files, then 2), each independently green; Phase 4
  cleanup + close issue \#141. Removal of Track 3’s clamp / Track 6’s
  `finalUnitX` override / `.computeDupNudge()` / both `sweepMinSep()`
  passes / the epsilon de-collision pass is **conditional** on Phase 2’s
  real-fixture zero-coincidence gate, never asserted in advance.
- `BACKLOG.md` Track 3 item updated (status tag + S610 progress
  paragraph). Issue \#141 deliberately **not** closed and its
  `premature optimization` label deliberately **not** changed — both
  deferred to the plan’s own Phase 4 / the owner, matching S609’s
  restraint.
- **Model:** Claude Sonnet 5.

### 2026-08-19 · \[ad hoc\] S610: claim session (Track 3 algorithm-family redesign scoping)

- **Deliverable:** Phase 1B claim stub in `SESSION_NOTES.md` +
  `status: pending` `HANDOFFS.md` receipt, committed (`99930551`) before
  any technical work — 2nd consecutive session claiming correctly after
  the S606-S608 three-session lapse (Learnings 624/625/628).
- **Model:** Claude Sonnet 5.

### 2026-08-18 · \[ad hoc\] S609: record the HANDOFFS.md sha-fix action itself (03ada3bc)

- **Deliverable:** the sha-fix commit itself (`03ada3bc`) recorded here
  per failure mode \#27 applying even to the self-referential
  sha-backfill commit — matching S600/S602-S608 precedent exactly.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · \[ad hoc\] S609: record close-out commit sha in HANDOFFS.md receipt (self-reference workaround, matching S600/S602-S608 precedent)

- **Deliverable:** `HANDOFFS.md`’s S609 receipt `commit:` field updated
  from `pending` to the actual close-out commit sha (`3344270c`).
- **Model:** Claude Sonnet 5.

### 2026-08-18 · \[ad hoc\] S609: close out (Track 6 D3‴ repair — Critique Round 3 failed, redirected to algorithm-family redesign)

- **Deliverable:** built and Critique-Round-3’d “D3‴” (the Track 6
  single-child union/parent- coincidence repair ratified S608 §9) in a
  scratch copy — all 3 independent critique lenses returned
  `designStillSound: false` (6th failed design attempt in this
  investigation’s history). A live owner architecture challenge,
  resolved by re-reading 3 primary sources in full, then redirected the
  defect class: pursue a complete
  Reingold-Tilford/Walker/Buchheim-Jünger-Leipert implementation (issue
  \#141) rather than a 7th local patch. No production code changed.
- Published a verified kinship2-vs-nprcgenekeepr before/after comparison
  Artifact (F1 fixture, node coordinates traced programmatically before
  trusting the images).
- `docs/planning/pedigree-diagram-single-child-union-parent-coincidence-investigation.md`
  §10 (Critique Round 3 findings) and §11 (owner-ratified redirect)
  added.
- `BACKLOG.md` Track 3 item updated with the S609 progress + redirect
  paragraphs.
- GitHub issue \#141 commented (new correctness-based evidence;
  AI-authorship disclaimer; label not changed unilaterally).
- `PROJECT_LEARNINGS.md` Learnings 630 (adversarial mutation-test
  diagnostic-sufficiency claims; boolean `capped` fields need a
  magnitude check) and 631 (read full truncated Workflow output before
  reporting; re-read primary sources, not condensed restatements, under
  direct challenge).
- `CLAUDE.md` learnings-count pointer updated (627→631 learnings,
  Sessions 1–607+→1–609+ — also corrects a 2-learning drift S608 itself
  left unfixed).
- **Model:** Claude Sonnet 5.

### 2026-08-18 · \[ad hoc\] S609: claim session (Track 6 targeted repair) (cffc09b7)

- **Deliverable:** Phase 1B claim stub (`SESSION_NOTES.md`) +
  `HANDOFFS.md` `status: pending` receipt, written and committed before
  any technical work — correcting the pattern Learnings 624/625/628
  flagged in the 3 immediately preceding sessions.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · \[ad hoc\] S608: record the HANDOFFS.md sha-fix action itself (30631c83)

- **Deliverable:** `HANDOFFS.md`’s S608 receipt `commit:` field updated
  from `pending` to the actual close-out commit sha (`8c697fab`), then
  this action itself recorded here per failure mode \#27 applying even
  to the self-referential sha-backfill commit — matching S600/S602-S607
  precedent exactly.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · \[ad hoc\] S608: close out — Track 6 single-child union investigation

- **Deliverable:** Phase 3 close-out for the investigation below. Added
  `PROJECT_LEARNINGS.md` Learnings 628 (a third consecutive Phase 1B
  skip, despite Learnings 624/625 already documenting and sharpening the
  rule against exactly this — the practical rule is revised to bind the
  stub-writing tool calls syntactically to the last scope-fixing
  `AskUserQuestion`, not left as a remembered follow-up) and 629 (a
  repaired design’s own extensive self-verification missed a real bug a
  second, independently-scripted critique round found — a tautological
  invariant-test check that re-invoked the same function it was meant to
  verify). Completed the `HANDOFFS.md` S608 receipt (`status: complete`)
  and the Phase 3A evaluation of S607’s own handoff (9/10) in
  `SESSION_NOTES.md`.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · \[ad hoc\] S608: investigate the Track 6 single-child union/parent-coincidence defect (found S603) — investigation only, no production code

- **Deliverable:** Picked up via `AskUserQuestion` as the Track 3
  child-centering trade-off decision, then pivoted (owner-directed) away
  from the exhausted 5-attempt duplicate-occurrence-selection mechanism
  to S603’s own newly-found, structurally distinct defect: Track 6’s
  single-child union formula can place a union’s marker and both mate
  edges essentially on top of one of its own 2 parents. Ran a 15-agent
  Evidence→Design→Synthesize→Critique→Repair→Critique-2 `Workflow`
  (14/15 agents succeeded; 1 Design candidate hit a transient API error,
  disclosed not hidden). Found the defect is majority-prevalence on the
  real 375-individual bundled fixture (72% of all matings visually
  coincide with a parent, live-verified via chromote pixel-space
  rendering) — not the rare edge case S603’s own 3 examples suggested. A
  synthesized design (“D3”) had real correctness majors (worsened 3
  established collision-metric tests, regressed a deliberately-correct
  S583 pinned test); a repair (“D3″”) addressed most of those, but
  Critique Round 2 found a new, live-verified bug (a “self-duplicate
  phantom obstacle” discarding 75% of the repair’s own residual
  improvement) with an already-verified one-line fix in hand. Wrote up
  the full investigation:
  [`docs/planning/pedigree-diagram-single-child-union-parent-coincidence-investigation.md`](https://github.com/rmsharp/nprcgenekeepr/docs/planning/pedigree-diagram-single-child-union-parent-coincidence-investigation.md).
  Owner ratified (via `AskUserQuestion`) a targeted future repair
  session (apply the one-line fix
  - add diagnostic return fields + a fresh Critique Round 3, then
    PRE-RED→RED→GREEN) over accepting the defect as permanent, holding,
    or re-running the failed candidate first. `BACKLOG.md` Active
    updated with a Progress paragraph and a READY-tagged next-step
    pointer. No `R/*.R` file was modified — every live-verification in
    the `Workflow` ran against scratch copies under the session’s own
    harness scratchpad, confirmed via
    `git status --porcelain -- R/ tests/` empty throughout by multiple
    agents.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · \[ad hoc\] S608: claim session (late; Phase 1B was skipped, caught and corrected)

- **Deliverable:** `SESSION_NOTES.md` stub + `HANDOFFS.md`
  `status: pending` receipt, committed (`0bb03e0f`) — written after
  research and a 1-agent scoping dispatch had already run (Phase 1B was
  skipped when the task was first picked), self-caught and corrected
  rather than deferred to a future session’s reconcile. See
  `PROJECT_LEARNINGS.md` Learning 628 for the pattern this recurrence
  confirms.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · \[ad hoc\] S607: post-close-out correction — REUSE badge renders “unregistered,” not green; new BACKLOG.md item for the owner action needed

- **Deliverable:** After pushing S607’s REUSE compliance work, verified
  the live badge directly (`curl` against `api.reuse.software/badge/...`
  and `/info/...`) rather than assuming a push was sufficient. Found it
  renders gray **“unregistered”** — `api.reuse.software` requires a
  one-time manual registration (repo URL + email, confirmed via email)
  at <https://api.reuse.software/register> before it will crawl and
  report compliance at all; this is a registration step tied to the
  owner’s own email/identity, not something a session can or should
  perform. The repo itself IS `reuse lint`-compliant (1234/1234,
  verified locally) — only the badge’s live rendering is blocked on this
  owner step. New `BACKLOG.md` Housekeeping item filed (DECISION NEEDED
  / owner action, Effort S) rather than leaving the gap undocumented.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · \[ad hoc\] S607: record close-out commit sha in HANDOFFS.md receipt (`c871be1b`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> `c871be1b` (the close-out commit whose sha the
  receipt itself couldn’t name until after it was made), matching the
  S600/S602/S603/S604/S605/S606 self-reference-workaround precedent.

### 2026-08-18 · \[ad hoc\] S607: MIT + REUSE license badges added to README.Rmd, full REUSE compliance

- **Deliverable:** `BACKLOG.md` Housekeeping item (added S600,
  `[ad hoc]` entry above) — both halves DONE. **MIT badge:** static
  shields.io badge added to `README.Rmd`’s existing badges block;
  `README.md` re-rendered via
  [`devtools::build_readme()`](https://devtools.r-lib.org/reference/build_readme.html).
  **REUSE badge:** owner picked “do the compliance work now” over
  skipping the badge or holding, via `AskUserQuestion`. Installed the
  `reuse` CLI (v6.2.0, `brew install reuse` — not previously available
  locally) rather than approximating compliance from spec knowledge
  alone. `reuse lint` before any change: 0/1234 files (tracked +
  untracked working-tree content) had a valid SPDX license identifier,
  confirming the S567/S600 grep finding. Added `LICENSES/MIT.txt`
  (canonical SPDX text via `reuse download MIT`, network-verified) and
  `REUSE.toml`: one blanket `"**"` annotation
  (`2017-2026 R. Mark Sharp`, MIT) covering all first-party content,
  plus a carve-out for 5 files vendored in by tooling and not authored
  by this project — `renv/activate.R` and the 4
  `man/figures/lifecycle-*.svg` badges — both confirmed MIT / Posit
  Software, PBC by checking `renv`’s and `lifecycle`’s own installed
  `DESCRIPTION`, not assumed.
  `inst/extdata/reference/Master_Genetic_metrics_2_14_15.pdf`’s
  copyright status was genuinely ambiguous from PDF metadata alone
  (generic “Word” authorship) — owner confirmed via `AskUserQuestion` it
  is the project’s own MIT-licensed work, distinct from the 4 already-
  gitignored third-party papers (S567/S568). `reuse lint` after:
  **1234/1234 compliant, 0 missing** — verified against the real tool,
  not assumed from the config. `.Rbuildignore` gained `REUSE.toml`/
  `LICENSES`, matching the existing
  `CITATION.cff`/`codecov.yml`/`_pkgdown.yml` precedent;
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  confirmed 0 new NOTEs from this change (the 1 warning + 2 notes
  present — the recurring Office lock file, `scratchpad/`, the
  long-standing `vignettes/figure/` knitr leftover — are all
  pre-existing, unrelated to this session). REUSE badge will render
  green only after this commit is pushed (api.reuse.software queries the
  live GitHub repo, not the local working tree). New
  `PROJECT_LEARNINGS.md` Learning 627 (run the real compliance tool,
  don’t approximate it). `CLAUDE.md` learnings-count pointer refreshed
  (626→627, S606+→S607+).
- **Model:** Claude Sonnet 5.

### 2026-08-18 · \[ad hoc\] S606: record close-out commit sha in HANDOFFS.md receipt (`b10b6d2d`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit`/`changelog_ref: pending` -\> `b10b6d2d` (the close-out commit
  whose sha the receipt itself couldn’t name until after it was made),
  matching the S600/S602/S603/S604/S605 self-reference-workaround
  precedent.

### 2026-08-18 · \[BL-518\] S606: `BACKLOG.md` “Genetic-metrics PDF audit follow-ups” section

re-compressed; S518 item’s “fully RESOLVED” claim corrected -
**Deliverable:** Re-compressed `BACKLOG.md`’s “Genetic-metrics PDF audit
follow-ups” section (304→80 lines), continuing the S529/S530/S531
precedent. Fixed a stale intro claim (“#152 \[Deferred\] is in progress
\[Slice 3 next\]” → closed, independently confirmed via
`gh issue view 152`/`153`, both `CLOSED`). Condensed 6 sequential
“Progress (SNNN…)” paragraphs (S517 design + issue \#152 Slices 1-5,
~265 lines) into 1 consolidated summary preserving every session number,
design-doc path, and `PROJECT_LEARNINGS.md` Learning cross-reference
(532/538/539/540/541/542, all verified to resolve). Found and fixed a
live, previously-unpropagated correction: the S535 paragraph’s own
“`shinytest2`/`chromote` headless-modal-rendering harness limitation”
finding was retracted one session later by `PROJECT_LEARNINGS.md`
Learning 542 (S536 — real cause was a test fixture missing a required
`birth` column) but never back-ported into `BACKLOG.md`’s own prose —
rewrote it to state the corrected root cause rather than compress the
debunked framing into shorter form. Verified `CHANGELOG.md` (+ 5
`docs/archive/CHANGELOG-through-*.md` shards) covers all 23 candidate
session numbers before compressing to a pointer (0 real gaps; 1 apparent
gap, S492, was a search-pattern false negative — the archive heading
reads “Session 492,” not “S492”). - **Also found and corrected:** the
S518 tracking item’s own text (`BACKLOG.md` Housekeeping) had claimed
“fully RESOLVED” after S531’s 2026-08-12 compression, but the very
section S531 compressed (267 lines then) had regrown to 304 by this
session’s own read — 3 intervening sessions (S532/S533/S535) each
appended their own progress paragraph as issue \#152’s slices shipped,
the exact accumulation pattern the item’s own opening paragraph names as
the root problem. Recorded as new `PROJECT_LEARNINGS.md` Learning 626
rather than left silently uncorrected. “Pedigree diagram vs kinship2”
(S530’s own prior target) was NOT re-checked this session for the same
regrowth risk — flagged for a future session, not silently skipped. -
**Process note:** claimed the session (Phase 1B `SESSION_NOTES.md`
stub + `HANDOFFS.md` `status: pending` receipt) BEFORE any investigation
of `BACKLOG.md`’s own content, breaking the 2-session Phase 1B-skip
streak `PROJECT_LEARNINGS.md` Learnings 624/625 documented (S604,
S605). - TDD: N/A throughout — pure docs edit, no
`R/`/`tests/`/`man/`/`NAMESPACE`/`data/` content touched, matching the
S529/S530/S531 precedent. `git diff --stat`: `BACKLOG.md` +73/−268 (net
−195 lines), `PROJECT_LEARNINGS.md` +1 new Learning (626), `CLAUDE.md`
learnings-count pointer 625→626.

### 2026-08-18 · \[ad hoc\] S605: record close-out commit sha in HANDOFFS.md receipt (`3539bc38`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit`/`changelog_ref: pending` -\> `3539bc38` (the close-out commit
  whose sha the receipt itself couldn’t name until after it was made),
  matching the S600/S602/S603/S604 self-reference-workaround precedent.

### 2026-08-18 · \[ad hoc\] S605: fix R-CMD-check.yaml CI-red — `inst/WORDLIST` missing “radix”

- **Deliverable:** `inst/WORDLIST` — added `radix` (before `RData`), the
  one word
  [`spelling::spell_check_package()`](https://docs.ropensci.org/spelling//reference/spell_check_package.html)
  flagged as uncovered. Root cause: S604’s close-out edit to
  `NEWS.Rmd`/`NEWS.md` (issue \#162’s changelog bullet, “byte/radix
  order”) introduced the word *after* S604’s own full-clean-regression
  check had already run, so it was never re-verified — same defect class
  as the S584/S587 precedent (`md's`, backfilled S603/S604). Found
  during this session’s own Phase 0 CI-status check (`gh run list`),
  reported (not filed as a `BACKLOG.md` item — trivial enough to fix
  same-session per the “just fix it” one-off-bug convention) and fixed
  in the same session, per user pick from the rendered priorities list.
  Verification: target test (`test_wordlist_coverage.R`) 0 failures;
  full clean-regression suite 0 failed/0 error project-wide; direct
  `spelling::spell_check_package(".", vignettes = TRUE)` — “No spelling
  errors found.” No `.R` file touched (lint N/A); no runtime behavior
  changed (Phase 3E N/A, stated explicitly). TDD: full
  PRE-RED→RED→GREEN→REFACTOR cycle with all 3 gated `AskUserQuestion`s —
  RED was the already-existing, already-failing
  `test_wordlist_coverage.R` assertion (no new test needed, the existing
  test fully captured the requirement); REFACTOR concluded as a genuine
  no-op (single-line addition to a flat word list).
- **Process note (self-flagged):** this session again skipped Phase 1B
  (the `SESSION_NOTES.md` claim stub + `HANDOFFS.md` `status: pending`
  receipt, committed *before* any technical work) — the exact gap S604
  self-flagged and logged as `PROJECT_LEARNINGS.md` Learning 624 one
  session earlier, in the very same session that documented it. Caught
  only after the GREEN edit had already landed, not before. See the
  updated Learning 624 entry and this session’s `HANDOFFS.md` receipt
  for the corrective framing.

### 2026-08-18 · \[ad hoc\] S604: record close-out commit sha in HANDOFFS.md receipt (`6f645d4a`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit`/`changelog_ref: pending` -\> `6f645d4a` (the close-out commit
  whose sha the receipt itself couldn’t name until after it was made),
  matching the S600/S602/S603 self-reference-workaround precedent.

### 2026-08-18 · \[issue \#162\] S604: fix `preferAnchor()`’s locale-dependent final tie-break

- **Deliverable:** `R/makePedigreeDiagramData.R:410` —
  `preferAnchor()`’s final anchor tie-break (reached when 2 candidate
  parents tie on both generation and mate count, guaranteed for every
  full-sibling mate pair) fell back to a bare `a < b` character
  comparison, which invokes the session’s own locale-dependent
  `Scollate()`. Replaced with
  `order(c(a, b), method = "radix")[1L] == 1L`, the same
  locale-independent byte-order technique Learning 585/588 already
  established in this file and 3 others. Full TDD RED→GREEN→REFACTOR: 1
  new `test_that()` in `tests/testthat/test_positionMatingUnitForest.R`
  (full-sibling `a1`×`A1` fixture, live-confirmed to flip anchor
  selection between this environment’s default locale and byte/radix
  order); RED confirmed failing pre-fix (2 assertions), GREEN confirmed
  passing post-fix with 0 regressions in the file. Full clean
  regression: **0 failed / 0 error** across the entire suite (the
  `test_wordlist_coverage.R` failure this session’s own Phase 0 backfill
  entry above already fixed). `lintr::lint_package()`: 0 lints on both
  touched files. Runtime smoke test:
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  run on the real 375-individual bundled fixture (714 nodes/827 edges, 0
  NAs). GitHub issue \#162 closed citing this entry. **Model:** Claude
  Sonnet 5.

### 2026-08-18 · \[ad hoc\] Backfilled (reconcile-on-read): undocumented commit `39de7dc2` — WORDLIST fix

- **Deliverable:** `inst/WORDLIST` gained `md's` (alphabetic position,
  matching the S230 convention), fixing the `test_wordlist_coverage.R`
  failure that S603’s orientation found making `R-CMD-check.yaml` red on
  `master` (S603 reported it as out of that session’s own scope — “still
  open” — and did not fix it). Committed directly by the project owner
  outside of a Claude Code session (no `SESSION_NOTES.md` claim stub, no
  `HANDOFFS.md` receipt) — reconciled here per `SESSION_RUNNER.md` Phase
  0 step 6, found at Session 604’s orientation. **Model:** none
  (human-authored commit, no assistant session).

### 2026-08-18 · \[ad hoc\] S603: record close-out commit sha in HANDOFFS.md receipt (`478a36af`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit`/`changelog_ref: pending` -\> `a577d89f` (the close-out commit
  whose sha the receipt itself couldn’t name until after it was made),
  matching the S600/S602 self-reference-workaround precedent.

### 2026-08-18 · \[ad hoc\] S603: post-close-out correction — S602’s “child-centering half DONE” claim RETRACTED

- **Session summary:** owner reviewed S602’s published comparison
  artifact and reported 3 observations (“the after image still shows the
  union marker inside P2”; “X×A/A×Y descenders not centered”; “the W×Y
  descender lands directly below Y”) contradicting the artifact’s own
  “verified”/“correct behavior” framing, which this assistant had
  relayed without independent verification. Mid-session, the owner gave
  a direct instruction to fix the underlying verification approach, not
  just this one instance. All 3 observations independently reproduced
  against current source (not the artifact’s own claims): F1 fixture
  (`test_positionMatingUnitForest.R:1140-1146`) rendered via
  `visNetwork`/`chromote` at both the pre-fix commit (`cdb9a167~1`,
  isolated `git worktree`, working tree untouched) and current `HEAD`,
  positions read via `visNetwork`‘s own live `getPositions()`.
  **Confirmed:** (1) the Track-3-Engagement Gate fix moves `__union_1`
  5px against P2’s 25px node radius — code-correct, TDD-green, and
  visually indistinguishable from doing nothing (3×-zoom before/after
  screenshots are pixel-identical); (2)/(3) the X×A/A×Y/W×Y descender
  defects are real and — checked directly against the gate’s own
  qualification rule (none of these 3 unions’ children are duplicated
  anywhere in the fixture) — structurally unrelated to S602’s fix; they
  are pure output of the earlier, separate Track 6 “center on one child”
  design. The artifact’s “correct behavior, verified” label for these
  rested on the design’s own stated intent, never the rendered geometry.
  Owner chose “record correction now” (documentation only, no code
  changed) via `AskUserQuestion`. **Corrections made:** `BACKLOG.md`
  (Track 3 trade-offs item’s “DONE” header retracted, full correction
  paragraph appended); investigation doc §12 “Net result” retracted, new
  §13 appended (methodology, numbers, root-cause distinction,
  methodology note); `NEWS.Rmd`/`NEWS.md` (S602 bullet
  “Fixed:”→“Changed:”, correction paragraph appended, re-rendered — diff
  confirmed scoped to that one bullet); `PROJECT_LEARNINGS.md` Learning
  623 (this session’s own methodology gap, generalized); `CLAUDE.md`
  learnings pointer refreshed (622→623); the published artifact
  corrected in place to Revision 4 (same design system as Revisions 1-3,
  new retraction box, fresh live-rendered before/after images replacing
  the prior unverified ones); this assistant’s own user-level
  `verify-diagrams-against-ground-truth` memory updated with the second,
  distinct failure mode (magnitude/geometry verification, not just edge
  topology; a design’s stated intent is not proof of visual
  correctness). Also surfaced during this session’s own Phase 0
  orientation, reported not fixed: `R-CMD-check.yaml` red on `master`
  for the last-pushed commit (S601’s close-out) —
  `test_wordlist_coverage.R` flags `md's` as uncovered by
  `inst/WORDLIST`, same defect class as the S584/S587 precedent.
- **Model:** Claude Sonnet 5.

### 2026-08-18 · \[ad hoc\] S603: claim session (post-close-out correction: child-centering fix has no visible effect) (`9cb8528b`)

- **Deliverable:** Phase 1B claim stub written to
  `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-17 · \[ad hoc\] S602: Track-3-Engagement Gate — duplicate-occurrence-selection centering fix IMPLEMENTED (RED→GREEN→REFACTOR)

- **Session summary:** implemented the design from the
  duplicate-occurrence-centering investigation’s §11.4 (5 workflow
  attempts across S598-S601, first sound design found S601), closing the
  investigation with shipped, TDD-verified code. Two `AskUserQuestion`
  gates before RED: a pre-RED scope decision (owner: full implementation
  now, over unit-tested-but-unwired or accepting the trade-offs as
  permanent) and the mandatory `TDD: PRE-RED→RED` gate (owner: full
  scope). Recovered 2 gaps the investigation doc’s own prose left only
  narratively described — the qualification rule’s literal (a)/(b)
  clauses and `.computeDupNudge()`‘s full 6-argument signature — by
  reading both design workflows’ own raw `journal.jsonl` outputs
  directly (`wf_2d657d34-184`, `wf_f8b481f4-0f8`), not by re-deriving
  from the doc’s prose (`PROJECT_LEARNINGS.md` Learning 621). **RED:** 7
  new/ modified tests in
  `tests/testthat/test_positionMatingUnitForest.R`, all hand-constructed
  and empirically verified against real, unmodified source — F1/F2/F3
  reproduce the investigation’s own documented values exactly; a fresh
  9-individual nested/chained fixture reproduces the worse-than-erasure
  regression from scratch; a variant confirms the gate doesn’t
  over-suppress a genuine correction; a dangling-parent fixture; the
  separately-accepted erasure trade-off confirmed untouched;
  `checkInvariant()` gained a 3rd disjunct + `.commentOneFixture()`
  added to its call list (avoiding a vacuous
  widened-disjunct-with-unwidened-call-list trap); a strict F1
  regression assertion. One test initially passed vacuously pre-GREEN (a
  “value must stay unchanged” black-box claim, trivially true when
  nothing exists yet to change it) — caught and fixed with a paired
  white-box assertion before treating RED as complete
  (`PROJECT_LEARNINGS.md` Learning 622). All 7 confirmed failing
  pre-GREEN, 0 collateral damage to the rest of the suite. **GREEN:**
  new internal `.computeDupNudge()` (`R/makePedigreeDiagramData.R`,
  `@noRd`) implementing the qualification rule, Stage-1 clip-and-average
  target, and the Track-3-Engagement Gate; wired into
  `.positionMatingUnitForest()` at the confirmed insertion point. Full
  clean regression: 0 new failed/error (only the pre-existing, unrelated
  `test_wordlist_coverage.R` failure). `lintr`: 4
  `implicit_integer_linter` style nits, fixed. **REFACTOR:** cached each
  union’s parent `[lo, hi]` span (previously recomputed independently by
  Track 3’s clamp loop and the new nudge loop) — structure only,
  byte-identical result re-confirmed via a 3rd `TDD: GREEN→REFACTOR`
  gate. **Runtime smoke test (Phase 3E):** headless — confirmed the
  app’s own Pedigree Diagram call chain
  ([`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md))
  runs clean on the real 375-individual bundled fixture (1412 nodes/
  1525 edges), no new errors. **Demonstration:** owner asked mid-session
  for a visual before/after vs. `kinship2` comparison; built one from a
  temporary git worktree at the pre-fix commit (F1 fixture,
  [`kinship2::plot.pedigree()`](https://rdrr.io/pkg/kinship2/man/plot.pedigree.html)
  reference + nprcgenekeepr before/after), traced every parent-child
  edge programmatically against the source pedigree before trusting
  either rendering, and published as a shared Artifact (union x moves
  0.12 → -6.0, matching kinship2’s own centered convergence point far
  more closely) — not committed to the repo (an ephemeral demonstration,
  not a project deliverable). `NEWS.Rmd`/`NEWS.md`: new entry disclosing
  the fix and its 0/237 real-corpus scope. `BACKLOG.md`: Track 3
  trade-offs item’s child-centering half marked DONE (D1 bar-vs-bar half
  remains open). Investigation doc: status banner updated to
  IMPLEMENTED, new §12 recording the full RED/GREEN/REFACTOR/smoke-test
  record. `PROJECT_LEARNINGS.md`: Learnings 621-622. No GitHub issue —
  this item was tracked in `BACKLOG.md` only, matching the
  investigation’s own established precedent. Follow-up commit
  `921d12f4`: corrected `HANDOFFS.md`’s own S602 receipt (its `commit:`
  field initially said `pending` despite `status: complete` —
  self-referencing a commit’s own sha inside that same commit isn’t
  possible; fixed to name both the claim and close-out commit shas,
  matching S600’s own established precedent for this field).
- **Model:** Claude Sonnet 5.

### 2026-08-17 · \[ad hoc\] S601: duplicate-occurrence-selection centering — narrow repair converges (5th workflow attempt, first sound design in this investigation)

- **Session summary:** owner directed a narrowly-scoped repair (fix only
  the worse-than-erasure regression the pivot workflow found; leave the
  separately-accepted erasure trade-off alone) rather than a full 6th
  redesign. A 6-agent `Workflow` (`wf_f8b481f4-0f8`, 0 errors, ~1.04M
  subagent tokens, ~55 min): 2 independent repair candidates converged
  on an identical idea — a “Track-3- Engagement Gate”
  (`engaged(U) := |rawFinalUnitX[U] - clampedFinalUnitX[U]| > 1e-9`;
  suppress the nudge entirely when Track 3’s own clamp never altered U’s
  value, since a union it left untouched has nothing to repair).
  Synthesized; **fresh 3-lens adversarial critique returned
  `designStillSound: true` on all 3 lenses** — zero major findings, 3
  minor ones. No 2nd repair round needed. **First design across 5
  workflow attempts in this investigation (S598, S599, S600, S601×2) to
  survive a full adversarial critique cleanly.** Live-verified: closes
  the regression on multiple nested/chained reconstructions, leaves the
  target case and both no-op fixtures byte-identical to before, does not
  over-suppress a genuinely-needed correction, and is a provable pure
  pass-through for the separate erasure trade-off. Presented the
  milestone via `AskUserQuestion` (close out now / address 3 minor
  findings first); owner chose close out now, matching this project’s
  plan/implementation session-boundary discipline (still PRE-RED, no
  code written). Appended full findings as the investigation doc’s new
  §11; updated the doc’s status banner and “start here” pointer (now
  §11.4) across all 3 places it appears. Added `PROJECT_LEARNINGS.md`
  Learnings 618-620 (a mandatory safety clamp can compose with a proven
  bound to produce a result worse than doing nothing; gate a repair
  mechanism on whether its own target constraint was actually binding; a
  fix’s real-world qualifying frequency on the project’s own test
  corpora is load-bearing go/no-go evidence). Refreshed `CLAUDE.md`’s
  `PROJECT_LEARNINGS.md` pointer (617→620 learnings, S600+→S601+).
- **Files:**
  `docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md`
  (§11 + banner), `BACKLOG.md` (Track 3 trade-offs progress note),
  `PROJECT_LEARNINGS.md` (Learnings 618-620), `CLAUDE.md` (pointer
  refresh), `SESSION_NOTES.md`, `HANDOFFS.md` (close-out).
- **Model:** Claude Sonnet 5 (main loop); Claude Sonnet 5 (all
  subagents, both workflows).

### 2026-08-17 · \[ad hoc\] S601: duplicate-occurrence-selection centering — pivot to post-hoc-bounded-nudge (4th workflow attempt), still not sound, plus a zero-real-impact finding

- **Session summary:** picked up S600’s investigation doc §9.7 item 1
  go/no-go (`BACKLOG.md`’s Track 3 trade-offs follow-up). Posed the
  go/no-go as a dedicated `AskUserQuestion` (accept Track 3 trade-offs
  as permanent / pivot to post-hoc nudge / authorize a 4th pre-clamp
  attempt / hold); owner picked “pivot” — a mechanism shape untried by
  S598/S599/S600, all of which stayed on a pre-clamp substitution. A
  12-agent `Workflow` (`wf_2d657d34-184`, 0 errors, ~2.10M subagent
  tokens, ~92 min): 4 independent post-hoc-nudge candidates (2 of 4
  verified **zero** dependency on `preferAnchor()`/issue \#162 — a
  genuine option no pre-clamp design ever had), synthesis, round-1
  critique (**all 3 lenses `designStillSound: false`**), repair, round-2
  critique (**still false on 2 of 3**): invariant-preservation
  reconfirmed a reclamp-erasure problem; edge-cases found something
  *worse* — a nested/chained sibling-consanguineous shape where the
  nudge actively corrupts a union Track 3 alone already positioned
  correctly, landing farther from the true center than either the
  nudge’s own uncapped target or doing nothing. **New, independent
  finding: the qualifying condition never fires on either existing test
  corpus (0/4 `small`, 0/237 real 375-individual fixture)** — even a
  sound version of this mechanism would currently touch zero pedigrees
  this package tests or ships. **Four independent attempts across 2
  structurally different mechanism families (S598-S600 pre-clamp, S601
  post-hoc) have now all failed adversarial critique.** Presented via
  `AskUserQuestion`; owner chose a narrowly-scoped repair over accepting
  Track 3’s trade-offs as permanent, a full 5th redesign, or holding
  (see the following entry, same session). Appended full findings as the
  investigation doc’s new §10 (workflow structure, 4-candidate table,
  synthesis, both critique rounds, the repair, the zero-real-impact
  finding, updated §10.7 open questions).
- **Files:**
  `docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md`
  (§10), `BACKLOG.md` (Track 3 trade-offs progress note).
- **Model:** Claude Sonnet 5 (main loop); Claude Sonnet 5 (all
  subagents).

### 2026-08-17 · \[ad hoc\] S600: duplicate-occurrence-selection centering — 3rd attempt (magnitude-bound), still not sound, plus an independent finding

- **Session summary:** picked up S599’s investigation doc §8.6 open
  questions (`BACKLOG.md`’s Track 3 trade-offs follow-up). Posed the
  §8.6 item 3 go/no-go as a dedicated `AskUserQuestion`
  (refine-with-magnitude-bounded-from-round-1 / pivot-to-post-hoc-nudge
  / run-both / accept-as- permanent); owner picked “refine.” Ran a 3rd
  12-agent design→synthesize→critique→repair→critique `Workflow`
  (`wf_be91a88b-c4c`, 0 errors, ~1.86M subagent tokens): Layers 1/2 held
  as given per S599’s own §8.5 finding, 4 independent magnitude-bounding
  candidates each required to pass a magnitude-stress fixture from round
  1 (S599’s own self-identified process gap); 2 candidates independently
  converged on an identical “cap the substitution delta to `±K·minSep`”
  design. Synthesis claimed success on all 4 required fixtures.
  **Round-1 critique found the synthesis’s entire success was contingent
  on silently reinterpreting Layer 1’s own “given, do not redesign”
  qualification rule** — under the literal rule, Pass 2 is dead code for
  exactly the target case’s own shape — plus a newly-load-bearing locale
  dependency in `preferAnchor()`’s tie-break. A repair round elevated
  both findings honestly and corrected the magnitude bound to a tighter
  universal form. **Round-2 critique (same 3 lenses, re-run fresh) still
  `designStillSound: false` on 2 of 3 lenses**: the bound measures
  against the wrong reference frame (overshoots the real children’s own
  span by 50% in the tightest, most common legitimate case, undetected
  across 2 full rounds), and the `preferAnchor()` locale bug is broader
  than characterized (already corrupts today’s shipped output,
  structurally guaranteed for every full-sibling mate pair) — plus a
  live 120x pixel-scale bug in the design’s own proposed RED test.
  Presented via `AskUserQuestion`; owner chose hold again, over one more
  repair round, pivoting to a post-hoc nudge, or accepting Track 3’s
  trade-offs as permanent. Appended full findings as the investigation
  doc’s new §9 (candidate table, both critique rounds, the independent
  finding, updated decision log, status banner) — §9.7 supersedes §8.6,
  now with a much stronger recommendation to treat a 4th attempt at this
  mechanism as needing justification, not the default (3 consecutive
  sessions have each failed at a deeper layer). Updated `BACKLOG.md`’s
  Track 3 trade-offs item with the S600 progress note. Added
  `PROJECT_LEARNINGS.md` Learnings 615 (a “given” component can be
  silently reinterpreted, must be checked against its literal wording),
  616 (a provably-bounded quantity can still violate the invariant it
  protects if it measures the wrong reference frame), and 617 (closing
  one round’s failure mode narrows but doesn’t bound the search);
  `CLAUDE.md` learnings-count pointer refreshed (614→617).
- **Files:**
  `docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md`
  (§9 appended, status banner + decision log updated, a self-introduced
  References-section duplication caught and fixed before commit);
  `BACKLOG.md` (S600 progress note); `PROJECT_LEARNINGS.md` (Learnings
  615-617); `CLAUDE.md` (learnings pointer); `SESSION_NOTES.md` /
  `HANDOFFS.md` (session claim + close-out).
- **Verification:** docs-only session, no `R/`/`tests/` file touched
  (confirmed via `git diff --stat`); no
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)/regression/lint
  run needed. Every new cross-reference in the investigation doc
  re-verified to resolve before commit (including re-reading the file
  after the edit to catch the duplication bug above).
- Model: Claude Sonnet 5.

### 2026-08-17 · \[ad hoc\] S600: file preferAnchor() locale-non-determinism bug, found incidental to the above

- **Session summary:** the magnitude-bound workflow above independently
  discovered a real, pre-existing, standalone defect unrelated to
  whether the centering fix ever ships: `preferAnchor()`
  (`R/makePedigreeDiagramData.R:403-411`, Track 4’s gen→mateCount→id
  tie-break) falls back to a bare `a < b` string comparison, confirmed
  live `LC_COLLATE`-locale-dependent — the same defect class as
  `PROJECT_LEARNINGS.md` Learning 585, but here confirmed to already
  corrupt today’s shipped pipeline output for any tied-generation,
  tied-mate-count parent pair (proved structurally guaranteed for every
  full-sibling mate pair via
  [`findGeneration()`](https://github.com/rmsharp/nprcgenekeepr/reference/findGeneration.md)’s
  BFS layering). Per Learning 382’s “report, don’t fix mid-session”
  precedent, not fixed this session — filed as [GitHub issue
  \#162](https://github.com/rmsharp/nprcgenekeepr/issues/162) and a new
  `BACKLOG.md` Housekeeping item (READY, Effort S), with the suggested
  fix (Learning 585’s own radix-based comparator) already named.
- **Files:** `BACKLOG.md` (new Housekeeping item). GitHub issue \#162
  filed (not a repo file change).
- **Verification:** n/a — issue filing and documentation only, no code
  change.
- Model: Claude Sonnet 5.

### 2026-08-17 · \[ad hoc\] S600: MIT license + REUSE compliance badge item added to BACKLOG (owner-directed)

- **Session summary:** owner asked to add a `BACKLOG.md` item for making
  the project MIT-licensed and adding license/REUSE badges to
  `README.Rmd`. Checked current state first rather than assuming the ask
  was unmet: `DESCRIPTION`’s `License: MIT + file LICENSE` plus tracked
  `LICENSE`/`LICENSE.md` have existed since S102’s CRAN hygiene pass —
  presented this via `AskUserQuestion` rather than filing a redundant
  item; owner narrowed scope to the badges specifically. Split into 2
  sub-items by risk: the MIT badge (a static shields.io image, safe to
  add, READY/Effort S) and the REUSE badge (a LIVE compliance check
  against api.reuse.software; verified this repo currently has none of
  what REUSE compliance requires — no `LICENSES/` dir, no SPDX headers,
  no `REUSE.toml`/`.reuse/dep5` — so adding it as-is would likely render
  red/non-compliant; flagged DECISION NEEDED with the concrete
  compliance path named, rather than adding a badge likely to embarrass
  the README).
- **Files:** `BACKLOG.md` (new Housekeeping item).
- **Verification:** n/a — documentation only, no code change.
- Model: Claude Sonnet 5.

### 2026-08-17 · \[ad hoc\] S599: duplicate-occurrence-selection centering redesign attempt — still not sound

- **Session summary:** picked up S598’s investigation doc §6 open
  questions (`BACKLOG.md`’s Track 3 trade-offs follow-up). Confirmed no
  code drift since S598’s HEAD, then ran a 12-agent
  design→synthesize→critique→repair→critique `Workflow`
  (`wf_115a9428-581`, 0 errors): 4 independent candidate
  qualification-rule designs (Symmetric Blend, Sibling-Union-Count
  Abstention, 2-Child Eligibility Gate, Sole-Qualifying-Duplicate Gate —
  the last disqualified live, still misfires `0.7`), each live-verified
  via
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  against the target case (`-6`) and the primary counter-example (stays
  at raw `0.5`). Synthesized into “Sibling-Relationship-Count Abstention
  Guard”; round-1 adversarial critique found a NEW compounding misfire
  (2 different children of one union each substituting toward a shared
  3rd sibling, `0.5→3.775`); repaired with a Layer-2 abstention ceiling
  that neutralized it (live-reconfirmed). **Round-2 critique on the
  repair still `designStillSound: false` on 2 of 3 lenses** — an
  unbounded-magnitude problem in the untouched “safe”
  single-substitution case (`-0.05→-16.238` live-measured as an
  unrelated fan-out grew, driven by the substitution formula itself,
  inherited unchanged from the original S592 design by every candidate
  tried across both S598 and this session) and a TDD white-box-test
  necessity (both abstention branches are output-identical to today’s
  shipped behavior, so a black-box RED test would pass
  pre-implementation). Presented via `AskUserQuestion`; owner chose hold
  again, over one more targeted repair round or shipping disclosed.
  Appended full findings as the investigation doc’s new §8 (candidate
  table, both critique rounds, updated decision log, status banner) —
  §8.6 supersedes §6 as the entry point for a future redesign session,
  with an explicit flag that a 3rd attempt should first weigh whether
  this is the right layer to fix child-centering quality at, given 2
  consecutive attempts have now failed adversarial critique. Updated
  `BACKLOG.md`’s Track 3 trade-offs item with the S599 progress note.
  Added `PROJECT_LEARNINGS.md` Learnings 613 (a repair earns a fresh
  full critique, not a narrower re-check) and 614 (verifying direction ≠
  verifying magnitude for a substitution-based design); `CLAUDE.md`
  learnings-count pointer refreshed (612→614, _(2.4→)2.5 MB).
- **Files:**
  `docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md`
  (§8 appended, status banner + decision log updated); `BACKLOG.md`
  (S599 progress note); `PROJECT_LEARNINGS.md` (Learnings 613-614);
  `CLAUDE.md` (learnings pointer); `SESSION_NOTES.md` / `HANDOFFS.md`
  (session claim + close-out).
- **Verification:** docs-only session, no `R/`/`tests/` file touched
  (confirmed via `git diff --stat`); no
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)/regression/lint
  run needed. Every new cross-reference in the investigation doc
  verified to resolve before commit.
- Model: Claude Sonnet 5.

### 2026-08-16 · \[ad hoc\] S598: duplicate-occurrence-selection centering fix — investigation, held for redesign

- **Session summary:** picked up `BACKLOG.md`’s “Track 3’s 2 disclosed
  trade-offs” item, scoped to the child-centering half only. Ran a
  6-agent research/verify/adversarial-critique workflow against the
  never-adopted S592 “fix (a)” design (duplicate-occurrence
  substitution): confirmed it still fits current HEAD exactly at
  `R/makePedigreeDiagramData.R:974-994` and live-reproduced its headline
  number (0.12 shipped → -6 under the fix, issue \#160 comment-1
  fixture) — but one of 3 adversarial critique lenses found a genuine,
  live-verified correctness gap inside the design’s own claimed scope (a
  sibling mating 2 different co-siblings of the same union can move the
  union’s center farther from true, not closer). Presented via
  `AskUserQuestion`; owner chose to hold for a redesign session rather
  than ship the flawed design (disclosed) or an unverified patch — 2
  candidate guards improvised live this session were both checked
  against the counter-example and both failed to exclude it. Wrote the
  full evidence record to
  `docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md`
  (explicitly an investigation, not a ratified plan) — flags a naming
  collision between `BACKLOG.md`’s informal “Track 4” shorthand for this
  fix and the unrelated, already-shipped
  `pedigree-diagram-track4-gen-aware-anchor-plan.md`. Updated
  `BACKLOG.md`’s Track 3 trade-offs item with the S598 progress note and
  next step. Also rendered the issue \#160 comment-1 fixture through
  both `kinship2` and `nprcgenekeepr` (ad hoc, not committed) for a
  user-requested visual comparison, ground-truth-verified edge-by-edge
  before presenting. Added `PROJECT_LEARNINGS.md` Learnings 611
  (adversarial critique found a real gap in an
  already-multi-agent-vetted design) and 612 (the “Track 4”
  naming-collision gotcha); `CLAUDE.md` learnings-count pointer
  refreshed (610→612, S597+→S598+).
- **Commits:** `9b94d7ce` (Phase 1B session claim), plus this session’s
  close-out commit.
- **Model:** claude-sonnet-5.

### 2026-08-16 · \[ad hoc\] S597: Phase 0 orientation + ledger backfill + stale-artifact correction — no BACKLOG item picked

- **Session summary:** did not pick or advance any of S596’s 3 offered
  BACKLOG priorities (Track 3 trade-offs decision / issue \#161 / S582
  screenshot check); Phase 1 was never completed. Ran a full Phase 0
  orientation (found and backfilled a real 2-commit `CHANGELOG.md` gap
  left by S596’s own close-out, commit `8fc0e383` — see the entry
  directly below), then followed a user-directed browser detour into an
  unplanned side-quest: reviewed a previously-published claude.ai
  “Pedigree Fidelity Proof” artifact and found its “not previously
  reported” defect callout was stale — verbatim `PROJECT_LEARNINGS.md`
  Learning 604, already fixed twice over by Tracks 1–2 — traced its
  stamped commit `f12e7cbb` to Session 590, predating issue \#160’s own
  filing. Regenerated both comparison plates fresh against current HEAD
  ([`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html) +
  `chromote`), with independently re-derived (non-circular) ground-truth
  collision verification: 0 same-row collisions on both plates; Track
  1’s fix confirmed via exact node coordinates (D1 bar row 60 units off
  the children’s row, matching `sibshipBarFraction=0.4`); the one
  flagged residual on Plate 2 confirmed to be the known,
  already-disclosed curved-heuristic case, not new. Republished to the
  same artifact URL with a correction callout. This artifact is external
  (claude.ai-hosted), not git-tracked — its render script lived only in
  this session’s ephemeral scratchpad. At close-out, completed a dropped
  mid-conversation user request: `BACKLOG.md`’s Track 3 trade-offs item
  gained a 3rd possibility (a bar-aware detect-and-jog repair for the D1
  bar-vs-bar residual specifically). Added `PROJECT_LEARNINGS.md`
  Learning 610 (a previously-published external artifact’s stamped
  commit sha can go stale with nothing in Phase 0’s own ledger-reconcile
  positioned to catch it, since that reconcile only walks git-tracked
  files). `CLAUDE.md` learnings-count pointer refreshed (609→610). No
  R/production code touched; no runtime smoke test applicable.
  `HANDOFFS.md` `status: complete` receipt written (self-assessment 6/10
  — real ledger and stale-artifact fixes, but no BACKLOG priority
  advanced this session).

### 2026-08-16 · \[issue \#160\] S596 close-out: handoff evaluation, self-assessment, Learning 609, HANDOFFS.md receipt

- **Close-out actions (reconcile-on-read backfill, Session 597 Phase
  0):** evaluated S595’s handoff (8/10, `SESSION_NOTES.md`);
  self-assessed this session (9/10); completed the `HANDOFFS.md`
  `status: complete` receipt (all 6 fields); added
  `PROJECT_LEARNINGS.md` Learning 609 (testthat/waldo
  tolerance-semantics gotcha —
  `expect_equal()`/[`all.equal()`](https://rdrr.io/r/base/all.equal.html)
  with a bare `tolerance=N` is scale-relative, not absolute) and
  refreshed `CLAUDE.md`’s stale learnings-count pointer (604→609
  learnings, S591+→S596+). Next session’s candidates named in the
  handoff: (1) decide the fate of Track 3’s 2 disclosed trade-offs (new
  `BACKLOG.md` follow-up item), (2) issue \#161’s now-unblocked deferred
  decision, (3) the small S582 stale-screenshot check — none mandated.
  Commits: `6261d6f9` (Learning 609 + `CLAUDE.md` refresh), `6ba6289e`
  (`HANDOFFS.md`/`SESSION_NOTES.md` close-out). This entry itself was
  the gap: S596 wrote the Track 3 deliverable entry below but, unlike
  S595’s own “close-out” entry precedent, never logged a matching entry
  for these 2 trailing commits — caught by Session 597’s Phase 0 ledger
  reconcile (`CHANGELOG.md` frontier `e4795723` vs. `HEAD` `6ba6289e`).

### 2026-08-16 · \[issue \#160\] S596: Track 3 (S583 parent-span clamp) shipped

- **Deliverable:** new clamp loop in `.positionMatingUnitForest()`
  (`R/makePedigreeDiagramData.R`) — plan §2.3/§6 Session C of
  `docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`.
  Clamps each mating unit’s `finalUnitX` into its own 2 parents’
  `[min, max]` x-range whenever the child-centered formula would place
  it outside that span — a disclosed, owner-ratified reopening of Track
  6 §2.4’s “unconditionally” wording (S592 §9, re-confirmed via this
  session’s own PRE-RED `AskUserQuestion`). Skips a union with a
  dangling (free-pass) parent rather than propagating `NA` — found live
  this session, fixed after regressing 2 pre-existing tests. Reproduced
  BACKLOG.md’s own S583 example byte-for-byte via
  [`trimPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/trimPedigree.md)
  against the real 375-individual bundled fixture, plus the 9-subject
  consanguineous fixture BACKLOG names. **2 trade-offs found during
  REFACTOR, both disclosed and owner-accepted via `AskUserQuestion`:**
  the plan’s own §7 faithful child-centering metric worsens (9/251 →
  53/251 child edges over the 200-unit threshold, max offset 4,121 →
  10,627), and the already-disclosed D1 bar-vs-bar x-overlap residual
  (plan §8) worsens substantially (9 → 116 post-Track-1 hits) — both
  trace to the same mechanism (pulling a runaway union back toward its
  own parents moves it away from its children and back toward
  neighboring subtrees). Beneficial side effect: Track 2’s own same-row
  collision baseline drops (150 → 105 edges, node count 1,502 → 1,412).
  Updated `test_positionMatingUnitForest.R`,
  `test_resolveEdgeNodeCollisions.R`, `test_makePedigreeMatingLayout.R`,
  `test_addRectilinearWaypoints.R` with disclosed, behavior-driven
  golden-value churn.
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  0 errors/0 warnings/1 pre-existing NOTE; full clean regression 0
  failed/0 error; `lintr::lint_package()` no lints. `NEWS.Rmd`/`NEWS.md`
  entry added. `BACKLOG.md`’s Track 3 and S583 items marked DONE; a new
  follow-up item filed for the 2 accepted trade-offs. Commits:
  `8b8e399d` (RED), plus this session’s GREEN+REFACTOR and close-out.

### 2026-08-15 · \[issue \#160\] S596 claim: implement Track 3 (S583 parent-span clamp)

- **Deliverable claimed:** plan §2.3/§6 Session C of
  `docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`
  — clamp `finalUnitX` into its own 2 parents’ `[min, max]` range in
  `.positionMatingUnitForest()`. Session stub written to
  `SESSION_NOTES.md`; `HANDOFFS.md` `status: pending` receipt opened.
  Work beginning.

### 2026-08-15 · \[issue \#160\] S595 close-out: handoff evaluation, self-assessment, Learning 608, HANDOFFS.md receipt

- **Close-out actions:** evaluated S594’s handoff (8/10,
  `SESSION_NOTES.md`); self-assessed this session (8/10); completed the
  `HANDOFFS.md` `status: complete` receipt (all 6 fields, including a
  disclosed process note about the missed GREEN→REFACTOR gate);
  self-flagged and disclosed that gap to the user via `AskUserQuestion`
  before proceeding, rather than after. Next session’s recommended
  pickup: Track 3 (S583 parent-span clamp, plan §2.3/§6 Session C — its
  own PRE-RED reopening-confirmation gate required first).

### 2026-08-15 · \[issue \#160\] S595: Track 2 (general same-row detect-and-jog framework) shipped, issue \#160 closed

- **Deliverable:** new `.resolveEdgeNodeCollisions()`
  (`R/makePedigreeDiagramData.R`), wired into
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
  `edgeStyle == "rectilinear"` branch — plan §2.2/§6 Session B of
  `docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`.
  Detects and repairs any straight same-row edge colliding with an
  unrelated node (a strictly rectilinear 2-waypoint “step,” never moving
  an existing node); the curved duplicate connector gets a disclosed
  `smooth.roundness`-bump heuristic instead, visually confirmed via
  `chromote`. Found and fixed 2 real implementation bugs mid-REFACTOR
  (jog-vs-jog collisions from a single shared row offset; color/label
  identity loss on twin-connector/consanguinity-marker edges), both
  caught by the full regression + rendered-image verification, not
  assumed. Real 375-individual bundled fixture: 150 → 0 straight-edge
  collisions (3,081 obstacle-pairs pre-fix); 52 curved-heuristic
  residuals disclosed.
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  0 errors/0 warnings/1 pre-existing NOTE; full clean regression 0
  failed/0 error; `lintr::lint_package()` no lints. `NEWS.Rmd`/`NEWS.md`
  entry added. `BACKLOG.md`’s Track 2 and issue \#160 items marked DONE.
  GitHub issue \#160 closed citing both Session A (S593) and this
  session’s evidence. Commits: `89d23e2a` (RED), `c7bdbe4b`
  (GREEN+REFACTOR), plus this close-out.

### 2026-08-15 · \[issue \#160\] S595 claim: implement Track 2 (general same-row detect-and-jog collision framework)

- **Deliverable claimed:** plan §2.2/§6 Session B of
  `docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`
  — new `.resolveEdgeNodeCollisions()` wired into
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md).
  Session stub written to `SESSION_NOTES.md`; `HANDOFFS.md`
  `status: pending` receipt opened. Work beginning.

### 2026-08-15 · \[ad hoc\] S594 close-out: SESSION_NOTES.md archive DONE, stale CLAUDE.md fence-scanner note corrected (Session 594)

- **Deliverable:** Lossless archive trim of `SESSION_NOTES.md` —
  **DONE.** Found the `CLAUDE.md` “archive blocked by a fence-scanner
  defect (S518)” note stale: that defect and a second, independent
  `\b`-boundary defect were fixed S527/S528, and 2 archive rounds had
  already run successfully since. The actual live blocker was a fresh
  `SRF_RED` refusal (SRF 2.0371 vs. 0.0576, a 35.35x spread across two
  archive boundaries) — the same pattern `PROJECT_LEARNINGS.md`
  Learnings 549/586/587 diagnosed for `CHANGELOG.md`/`HANDOFFS.md`, and
  which Learning 587 explicitly predicted would recur here. Surfaced
  both readings +absolute byte deltas via `AskUserQuestion`; owner chose
  `--force`. `methodology_trim.py --force --write` archived 76 records
  to `docs/archive/SESSION_NOTES-through-2026-08-15.md` (see the tool’s
  own entry directly below); L1/L2/L3 losslessness confirmed both by the
  tool’s console output and independently via the generated `.verify.sh`
  script. Dashboard HIGH+ risk 1 → 0 (health unchanged, 96/100).
  Corrected the `CLAUDE.md` note to the verified current state. Added
  `PROJECT_LEARNINGS.md` Learning 607 (stale-persistent-note pattern;
  Learning 587’s prediction confirmed). No `BACKLOG.md` item existed for
  this — nothing to remove there. Commits: `a3c8f1c9` (claim,
  self-corrected a same-session date typo), plus this close-out.

### 2026-08-15 · \[ad hoc\] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-08-15.md` (76 record(s), 397,442 B → 5,262 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a
session’s judgment. Moved the oldest **76** record(s) (2026-01-26 →
2026-08-15) out of
[`SESSION_NOTES.md`](https://github.com/rmsharp/nprcgenekeepr/SESSION_NOTES.md)
into
[`docs/archive/SESSION_NOTES-through-2026-08-15.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-15.md).
Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run
[`docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh)
rather than trusting a digest printed here. Live file 397,442 B → 5,262
B (−98.7%).

### 2026-08-15 · \[ad hoc\] S594 claim: lossless archive trim of SESSION_NOTES.md (Session 594)

- **Deliverable:** Lossless archive trim of `SESSION_NOTES.md`,
  user-directed at Phase 0 (dashboard HIGH-risk flag, file at 4,645
  lines / 395,482 B). PRE-RED investigation: the `CLAUDE.md` note
  framing this as blocked by a `methodology_trim.py` fence-scanner
  defect (S518) is stale — both that defect and the follow-on
  `\b`-boundary defect (S527, `PROJECT_LEARNINGS.md` Learning 533) were
  already fixed (S527/S528) and two archives already succeeded. Actual
  current blocker: a fresh `SRF_RED` refusal (SRF 2.0371 vs. 0.0576,
  35.35x spread across two archive boundaries), matching the
  `CHANGELOG.md`/`HANDOFFS.md` pattern `PROJECT_LEARNINGS.md` Learnings
  549/586/587 already diagnosed. Session claimed; decision pending.

## How to add an entry

At close-out, prepend one entry per action, **newest on top**, directly
below this section (above `## Legacy history` — never inside it). Key on
a mechanical fact, not judgment: *did this session author or retain any
commit, or take any non-commit action?* If yes, an entry is owed — “too
small to log” is failure mode \#27, not an exception.

**Source tag — exactly one per entry**, so
`grep -E '\[(issue #|BL-|ad hoc)' CHANGELOG.md` enumerates every logged
action:

- `[issue #<N>]` — a GitHub issue in this repository.
- `[BL-<N>]` — a `BACKLOG.md` item. Remove it from `BACKLOG.md` in the
  same commit.
- `[ad hoc]` — work with no backlog or issue origin (methodology syncs,
  planning/audit sessions, release mechanics, decline/wontfix
  decisions).

**Format** — the `###` header line is the required, greppable unit;
detail bullets below it (this project’s established
`**Deliverable:**`/verification-summary style) are expected and
encouraged:

    ### YYYY-MM-DD · [SOURCE] one-line outcome-focused summary (Session N)
    - **Deliverable:** ...

When completing work, remove the item from `BACKLOG.md` and add an entry
here.

## Size, and when to archive

Sectioning organises this file; it does not shrink it. The file grows
without bound and Phase 0 reads it every session, so it also has a size
discipline. **Two caps, because there are two distinct failure modes and
neither subsumes the other. Fire if either fires; stop only when both
stop conditions hold.**

| Cap | Protects against | Form | Fire when | Cut until |
|----|----|----|----|----|
| **Lines** — ~2,000, the agent `Read` truncation cap | **silent truncation**: a read past the cap returns no error and no marker, so the oldest entries simply stop existing for the reader | a **rate** | headroom \< **15** entries | headroom \> **30** |
| **Bytes** — a per-file budget, default **65,536 B** (64 KB) | **context tax**: every session pays for the whole file, every time | a **level with hysteresis** | `size > budget` | `size ≤ ½ × budget` |

**Run this. Do not eyeball it, and do not trust a size written here or
anywhere else** — a number in prose is stale the next time anyone
prepends:

``` sh
python3 methodology_trim.py --file CHANGELOG.md --check
```

`--check` evaluates both conditions, reports whether the trigger fires,
and never writes. `--write` performs the trim; a dry run is the default,
and it refuses to write unless it can prove the split lossless. **It
neither commits nor stages** — it leaves the live file modified and the
new shard *untracked*, prints the rollback, and leaves the commit to
you. Stage both yourself: `git add CHANGELOG.md docs/archive/` —
committing with `-a` alone would land the shortened ledger while the
shard, being untracked, never enters history at all.

**Why the line cap is a rate.** Headroom is
`(2000 − lines) × entries-added ÷ lines-added` since the last split, so
it re-derives itself from the file on every read. A hand-written level
cannot: it is a derived value frozen at the moment someone typed it.
This framework’s own receipt ledger is the worked example — it states
its trigger as a level, *“approaches ~1,200 lines,”* and **that level
has never once fired.** The single archive that file has ever had was
taken on judgment at 997 lines, *before* the level was written; since
then the file has grown several times past its byte budget while still
reading “under 1,200 lines.” A level in the wrong unit says *fine*
indefinitely. Where there is no slope yet — before the first split, or
immediately after one — the rate **abstains out loud** rather than print
a number it cannot support.

**Why the byte cap is not.** *“Cut until headroom is back above 30”* is
unreachable on bytes at any budget: a tool applying it would trim the
file to a single record and still report the trigger unsatisfied. A
level with hysteresis terminates, and the ½ factor is what keeps the
next entry from re-firing the trigger immediately.

**The budget is judgment, and it is yours to set.** It does not follow
from the line cap — at real ledger densities, 2,000 lines is a different
byte count for every file. Calibrate it the way this default was: take
the sizes your repo has actually operated at comfortably after previous
archives, and set the budget just above them. `--budget-bytes <N>`
overrides it for a single run.

**Archiving again is not always the answer.** If the file has already
given back everything the last archive removed, another archive resets
the *level* and not the *rate* — the tool measures exactly that and
**refuses to fire**; `--force` is how you overrule it deliberately.
Before a file’s first archive there is no baseline to measure against,
so it abstains rather than compute a zero.

### The shard convention

An archive is a **shard** — a new frozen file, same format, same
newest-on-top order. **Note for this file specifically:** the pre-S325
legacy history (Sessions 1-324, pre-ledger format) that used to sit
inline below a `## Legacy history` boundary marker was itself relocated
into
[`docs/archive/CHANGELOG-legacy-pre-S325.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/CHANGELOG-legacy-pre-S325.md)
— S547, 2026-08-13, decided S546 — because the block alone (935,287 B /
3,567 lines) permanently exceeded this file’s own byte/line budgets,
making the trigger unclearable by any trim of the tagged region alone
regardless of rate. It is a shard like any other (frozen, same order, no
forward-looking rule) — see that file’s own header for why its name
departs from the usual `<BASENAME>-through-<CUTKEY>.md` pattern. It was
created by a one-time manual relocation, not
`methodology_trim.py --write`, since the tool has no operation that
moves the footer zone (only the records zone) — verified beforehand
(`classify_zones()` and `--check` against the post-relocation content)
not to break the tool’s own zone classification or its byte/line
trigger.

- **Path: `docs/archive/<LIVE-BASENAME>-through-<CUT-KEY>.md`.** Both
  halves are load-bearing. The directory keeps a shard from shadowing
  the live file by sort order, and the `CHANGELOG-` prefix is what the
  trigger’s own glob looks for when it hunts its baseline — a shard
  named otherwise is silently invisible to it, and the trigger then
  measures against the wrong boundary.
- **The live file keeps one short pointer** naming each shard and the
  span it covers. Every count stated in that pointer carries the command
  that recomputes it, because a hand-maintained count drifts on the next
  prepend.
- **The shard back-links to the live file and states only facts about
  itself** — its own span, its own count. It must **not** restate a
  forward-looking rule. A shard is frozen, so a rule copied into one is
  wrong the moment the live rule moves, and correcting it means editing
  a frozen record. Cite the live file; do not copy it.
- **After a split the authority is the live file *and* its shards.** Any
  command that enumerates this ledger must span both by glob —
  `CHANGELOG.md docs/archive/CHANGELOG-*.md` — or the split silently
  shrinks the population the audit was counting.
- **Prefer a release frontier as the cut key**, because a shipped
  release is a boundary nothing can ever be written back into. A
  calendar date works too, but it is frozen only by convention; if you
  cut at one, say in the shard’s own front matter that you departed and
  why.

**A trim is an action, not a side effect.** It earns its own commit and
its own `[ad hoc]` entry here — one ledger, one shard, one commit, one
revert. It does **not** belong in Phase 0, which is read-only apart from
the reconcile backfill.

**Not everything that grows can be archived this way.** Archiving moves
*history*. A file that grows because someone keeps adding *procedure*
has no past to move — extract a section to a sibling file and leave a
pointer instead. A backlog of open items is live state rather than
history: that is a grooming problem, and its completed items belong
here, in this ledger, not in a frozen shard.

## \[Unreleased\]

## 2026-08

### 2026-08-15 · \[BL-1\] S593: close out (Track 1 – D1 sibship-bar row offset, issue \#160)

- **Deliverable:** Track 1 (D1 sibship-bar genuine intermediate row)
  shipped, closing issue \#160’s 2 originally-reported collisions.
  `sibshipBarFraction = 0.4` added to `.addRectilinearWaypoints()`’s D1
  loop (`R/makePedigreeDiagramData.R`). Reproduced byte-for-byte against
  the actual
  [`kinship2::sample.ped`](https://rdrr.io/pkg/kinship2/man/sample.ped.html)
  family 2 fixture cited in the collision-avoidance plan’s own evidence
  — both collisions confirmed cleared.
- **Two disclosed residuals found during implementation** (neither
  anticipated by the plan’s Session A bullet in the bar-vs-node case;
  the bar-vs-bar case was named as an open gotcha by S592’s own handoff,
  checked and measured here): (1) no fixed rational `sibshipBarFraction`
  is collision-free for every generation gap — 2/488 waypoints collide
  on the real fixture for a gap-5 union; (2) two different sibships
  sharing a generation gap can still land bars on the identical row if
  x-ranges overlap — 42 cases before Track 1, 9 after (79% reduction,
  not elimination). Both counted in a permanent regression test,
  disclosed in `NEWS.Rmd`/`BACKLOG.md`/ 2 GitHub issue \#160 comments,
  deferred to Track 2 (gap-agnostic general detect-and-jog).
- **Action taken:** `lintr::lint_package()` clean on both touched files.
  Full clean regression (`NOT_CRAN` set, `load_all()` first): 0 failed/0
  error, twice.
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html):
  0 errors/0 warnings/1 NOTE (pre-existing `vignettes/figure` knitr
  leftover, dated Aug 11, unrelated). `NEWS.Rmd`/`NEWS.md` entries added
  and rendered. 2 GitHub issue \#160 comments posted with full evidence.
  `BACKLOG.md` Track 1 item marked DONE. Checked
  `vignettes/articles/kinship2-fidelity- validation.qmd` for stale
  screenshots (1 image technically affected, judged not stale for the
  unrelated feature it documents, not regenerated — disclosed, not
  silently decided). Issue \#160 not closed — Track 2 still required.
  Commits: `71ce091c` (implementation), `6cb913fc` (bar-vs-bar residual
  disclosure + test), plus this close-out.
- **Protocol note:** the GREEN→REFACTOR `AskUserQuestion` gate was
  skipped mid-session (proceeded directly from a passing GREEN run into
  lint/regression/[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)/NEWS/GitHub-comment
  work) — caught before Phase 3 close-out, acknowledged per
  `CLAUDE.md`’s Error Handling section, retroactively confirmed via
  `AskUserQuestion` before continuing. See `SESSION_NOTES.md`
  Self-Assessment for the full account.

### 2026-08-15 · \[BL-1\] S593: claim session (implement Track 1 – D1 sibship-bar row offset)

- **Deliverable (in progress):** Implement Track 1 (D1 sibship-bar
  genuine intermediate row) – Session A of
  `docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`
  §2.1/§6 (`BACKLOG.md`, found S592, READY, Effort S). User selected
  this item from the Phase 0 priorities picker over Track 2, Track 3,
  and issue \#148 scoping.
- **Action taken:** Claim stub written to `SESSION_NOTES.md`;
  `status: pending` receipt opened in `HANDOFFS.md`. Full PRE-RED -\>
  RED -\> GREEN -\> REFACTOR TDD gates to follow.

### 2026-08-15 · \[ad hoc\] S592: reconcile HANDOFFS.md commit self-reference (14a405b1)

- **Action taken:** updated S592’s own `HANDOFFS.md` receipt `commit:`
  field from the write-time placeholder
  (`b600b43a, plus this close-out`) to the actual close-out commit sha
  (`b600b43a, 14a405b1`), matching the established S589/S590/S591
  precedent for this self-referential field.

### 2026-08-15 · \[BL-1\] S592: close out — root-cause architecture plan (issues \#160/#161/S583 collision-avoidance gap)

- **Deliverable:**
  `docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`
  — a 3-track phased architecture plan addressing the shared “no
  same-row collision-avoidance for placement” root cause behind issues
  \#160, \#161, and the S583 union-position gap. Built via a 12-agent
  research/design/judge `Workflow` (5 research readers, 4 independent
  candidate architectures, 3 independently-lensed judges — 12/12
  completed, 0 errors); no single candidate won on all 3 judge lenses,
  so this document synthesizes the highest-scoring, judge-vetted piece
  of each rather than adopting one wholesale. Owner-ratified via
  `AskUserQuestion` (both Recommended options selected: the 3-track
  synthesis, and deferring issue \#161’s marker-visibility decision
  until Tracks 1–3 ship).
- **Tracks:** Track 1 (D1 sibship-bar genuine intermediate row — an
  unconditional geometric guarantee, no detection logic, closes issue
  \#160’s 2 originally-reported collisions); Track 2 (general same-row
  detect-and-jog framework wired into
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  itself so every caller benefits — closes issue \#160 comment 1’s
  broadened finding); Track 3 (parent-span clamp on `finalUnitX`, a
  deliberate disclosed reopening of Track 6 §2.4, its own PRE-RED gate
  at implementation time — closes the S583 item). The narrower
  duplicate-occurrence-selection root fix and issue \#161 are named, not
  scheduled/deferred, not implemented.
- **Not implemented this session** — planning session, output is the
  document, not code; no `R/`/`tests/` file touched, TDD phases
  INAPPLICABLE (matches the S588/S589/S590 precedent).
- **Action taken:** commented on issues \#160 and \#161 linking the plan
  (neither closed — both remain open pending implementation); updated
  `BACKLOG.md` (planning item marked DONE, 3 new READY/DECISION-NEEDED
  implementation items added, the \#160/#161/S583 items annotated with
  pointers to the plan); verified every cross-referenced file/citation
  in the plan resolves.

### 2026-08-15 · \[BL-1\] S592: claim session (root-cause planning: issues \#160/#161/S583 collision-avoidance gap)

- **Deliverable (in progress):** Planning session addressing
  `BACKLOG.md`’s “Active” item (found S591) — the shared “no same-row
  collision-avoidance for placement” root cause behind issues \#160,
  \#161, and the S583 union-position gap, following
  `ARCHITECTURE_WORKSTREAM.md`. User selected this item from a 4-option
  Phase 0 priorities picker over the two narrower decision-only
  alternatives (#160 alone, \#161 alone) and the
  lower-priority/informational bucket.
- **Action taken:** Claim stub written to `SESSION_NOTES.md`;
  `status: pending` receipt opened in `HANDOFFS.md`. Dispatched a
  12-agent research/design/judge `Workflow` (5 parallel research readers
  over `.positionMatingUnitForest()`/`.addRectilinearWaypoints()`, a
  grep-based call-site inventory, Track 4/6 ratified-invariant
  extraction, and prior-spike history; 4 independent collision-avoidance
  candidate architectures; 3 independently-lensed judges) to ground the
  plan in verified evidence before writing it.

### 2026-08-15 · \[ad hoc\] S591: close out (live investigation — issues \#160/#161, no code changed)

- **Deliverable:** Close-out for a session with no pre-declared task
  (Phase 1B was skipped — see `SESSION_NOTES.md` self-assessment) that
  ran as organic, user-driven investigation: answered a history question
  via a 5-agent research workflow, corrected 2 self-caught-by-user
  errors (a mischaracterized evidence source; tool-result images that
  never reached the user), generated fresh current-HEAD
  kinship2-vs-nprcgenekeepr renders and published them as an Artifact,
  found and filed 2 real pedigree-diagram rendering defects (issues
  \#160, \#161) with coordinate-level evidence, confirmed the
  already-tracked S583 `BACKLOG.md` item live, and added a
  planning-session `BACKLOG.md` item for the shared root cause. Full
  narrative in `SESSION_NOTES.md` “What Session 591 Did.”
  `PROJECT_LEARNINGS.md` Learning 604 added (verify-against-ground-truth
  methodology gap); `CLAUDE.md`’s stale learnings-count pointer fixed
  (603→604, S590→S591). Self-score 6/10 — real weaknesses named plainly
  (Phase 1B skipped; TDD phase never declared per-response; session
  shape doesn’t fit the “one deliverable” model). No `R/`/`tests/` file
  touched; runtime smoke test n/a. `HANDOFFS.md` receipt written
  directly as `status: complete` (no prior `pending` stub existed, since
  Phase 1B was skipped).

### 2026-08-15 · \[BL-N\] Added planning-session backlog item for the shared collision-avoidance gap

- **Deliverable:** Owner-directed. Added a `BACKLOG.md` Active item
  proposing a dedicated planning session to address the shared root
  cause behind issue \#160, issue \#161, and the S583 union-position
  item — all trace to
  `.positionMatingUnitForest()`/`.addRectilinearWaypoints()` computing
  node/edge placement locally with no check for what else occupies that
  x/y region. No code changed; the item itself asks for a plan document,
  not an implementation, per `SESSION_RUNNER.md`’s Planning Sessions
  discipline.

### 2026-08-15 · \[ad hoc\] Push commits (`ea49636e..25697bb9`)

- **Deliverable:** Owner-directed. Pushed 11 local commits (S588-S590’s
  own claim/deliverable/ reconcile docs, plus this conversation’s issue
  \#160/#161 ledger entries) to `origin/master`, clean fast-forward, no
  force.

### 2026-08-15 · \[issue \#161\] Filed pedigree-diagram mating-unit-marker kinship2-parity question

- **Deliverable:** Filed [issue
  \#161](https://github.com/rmsharp/nprcgenekeepr/issues/161) — found
  live in conversation reviewing a fresh render of the `A x Y`
  consanguineous fixture against kinship2. kinship2 draws no marker for
  a mating (a plain line intersection); nprcgenekeepr draws a small
  filled circle for every `__union_N` node. Mechanically feasible via
  the same `size = 0` + transparent-color technique already used for
  invisible D1/D2 rectilinear waypoints (issue \#142, S465), but a
  genuine design question, not an obvious fix. Not implemented — needs a
  decision first. Also added to `BACKLOG.md` Active.

### 2026-08-15 · \[issue \#160\] Commented with a second, broader reproduction

- **Deliverable:** Commented on [issue
  \#160](https://github.com/rmsharp/nprcgenekeepr/issues/160#issuecomment-5304476340)
  with a second fixture (the `A x Y` consanguineous example) showing a
  more severe instance of the same defect: P1×P2’s own union lands
  entirely outside their parents’ span (traced to Track 6’s centering
  formula using a duplicated child’s *real*, far-away occurrence instead
  of the nearby duplicate), and the resulting over-stretched sibship bar
  collides with both an unrelated node (W) and a duplicate-connector
  dashed edge. Broadens the diagnosed root cause: the collision isn’t
  specific to the sibship-bar D1 loop — any straight same-row edge
  (sibship bar or duplicate-connector) lacks collision-avoidance against
  an intervening node. Also annotated the related-but-distinct
  `BACKLOG.md` S583 item (union-outside-parents’-span) with a 3-instance
  live reconfirmation of that already-tracked gap on the same fixture
  (X×A, A×Y, W×Y unions each collapsing to their one child’s x) — not
  filed as a new issue, since it’s the same gap already tracked there.
  No code changed.

### 2026-08-15 · \[issue \#160\] Filed pedigree-diagram rectilinear sibship-bar false-parentage defect

- **Deliverable:** Filed [issue
  \#160](https://github.com/rmsharp/nprcgenekeepr/issues/160) — found
  live in conversation (not a claimed session), while generating fresh
  kinship2-vs-nprcgenekeepr comparison renders from current HEAD
  (`f12e7cbb`) to visually verify the Track 1-6 kinship2-fidelity
  remediation effort. On
  [`kinship2::sample.ped`](https://rdrr.io/pkg/kinship2/man/sample.ped.html)
  family 2 (14 people, no multi-mate individuals — the project’s own
  “cleanest comparison” fixture), under `edgeStyle = "rectilinear"` (the
  current shipped default since Track 2, S574): the rectilinear
  sibship-bar waypoints sit at the exact same y as the children’s own
  row (zero vertical drop from an intermediate bar row), so the bar
  reads as a straight mate-line chain — and 2 unrelated nodes (203×204’s
  own mating-unit dot; 209, a marry-in founder with no blood relation to
  201×202) land directly on that line, each visually implying a
  parent-child relationship that does not exist. Confirmed against
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
  own returned `nodes`/`edges` (coordinate collision, not a rendering
  artifact) and against a pixel-level screenshot crop of both collision
  points. Root cause is a pre-existing design gap in
  `.addRectilinearWaypoints()` (issue \#142) — not a regression from
  Track 1-6, which measured edge orthogonality but never checked for
  coordinate collisions between unrelated nodes. Not fixed this
  conversation — no session claimed, reported per the established
  “report, don’t fix mid-session” precedent (`PROJECT_LEARNINGS.md`
  Learning 382); needs its own design pass. See issue \#160 for full
  reproduction steps and evidence.

### 2026-08-15 · \[BL-N\] S590: close out (pedigree-diagram layout SECOND feasibility spike – igraph::layout_with_sugiyama())

- **Deliverable:** Ran the pedigree-diagram layout SECOND feasibility
  spike (`BACKLOG.md`, found S589, HIGH PRIORITY) —
  `docs/planning/pedigree-diagram-layout-sugiyama-spike-plan.md` + a
  runnable evidence document,
  `docs/planning/pedigree-diagram-layout-sugiyama-spike-evidence.qmd`.
  Adapted `igraph::layout_with_sugiyama()` (owner-selected via
  `AskUserQuestion` over a ported Brandes-Köpf 2002 alternative),
  reusing S589’s own faithful harness verbatim. Found and fixed 2 real
  methodological issues en route: a stale renv-cached installed package
  build (predates Track 6 by ~3.5h —
  [`library(nprcgenekeepr)`](https://rmsharp.github.io/nprcgenekeepr/)
  silently loads it;
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  used throughout instead) and `layout_with_sugiyama()`’s own
  vertex-order-sensitive crossing heuristic (mitigated via standard
  multi-restart). Synthetic example: 20% gap reduction, 0 crossings
  (matching S589’s own candidate). Real 375-individual fixture:
  **regressed** on every axis measured (9/251→25/251 edges over
  threshold, max offset 4,121→10,110, crossings 3,174→5,916), confirmed
  not a tuning artifact via a restart/seed sweep and an edge-weight
  check. **Verdict: NOT FEASIBLE as prototyped.** This is the THIRD
  independently-designed candidate to regress the real fixture.
  Owner-ratified: **close the non-rigid-layout investigation as
  inherent** — no further spike scoped on this thread. Updated
  `BACKLOG.md` (item DONE, no new spike item added); commented on and
  **closed** GitHub issue \#159 with the cumulative 3-candidate
  evidence. Added `PROJECT_LEARNINGS.md` Learnings 601–603; fixed a
  stale learnings-count cross-reference in `CLAUDE.md`.
  Planning/investigation session, TDD phases inapplicable — no `R/` file
  touched.

### 2026-08-15 · \[BL-N\] S590: claim (pedigree-diagram layout SECOND feasibility spike)

- **Deliverable:** Non-commit-adjacent claim entry per Phase 1B. Session
  claimed to run the pedigree-diagram layout SECOND feasibility spike
  (`BACKLOG.md`, found S589, HIGH PRIORITY) — adapt
  `igraph::layout_with_sugiyama()` (owner-selected via
  `AskUserQuestion`), tested against the same two fixtures S589 used.
  Planning/investigation session, TDD phases inapplicable.

### 2026-08-15 · \[ad hoc\] S590: reconcile HANDOFFS.md commit self-reference (`f3492719`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> the real sha (`f3492719`, close-out) —
  unknowable until after that commit existed. Matches the established
  S562-S589 precedent.

### 2026-08-15 · \[ad hoc\] S589: reconcile HANDOFFS.md commit self-reference (`691071a0`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> the real sha (`691071a0`, close-out) —
  unknowable until after that commit existed. Matches the established
  S562-S588 precedent.

### 2026-08-15 · \[BL-N\] S589: close out (pedigree-diagram non-rigid layout feasibility spike)

- **Deliverable:** Ran the pedigree-diagram layout feasibility spike
  (`BACKLOG.md`, found S588, HIGH PRIORITY) —
  `docs/planning/pedigree-diagram-nonrigid-layout-spike-plan.md` + a
  runnable evidence document,
  `docs/planning/pedigree-diagram-nonrigid-layout-spike-evidence.qmd`.
  Prototyped a barycenter/median layered-DAG compaction candidate
  (owner-selected via `AskUserQuestion`): 20% gap reduction and zero
  edge crossings on the synthetic example, but **regressed** the real
  375-individual fixture under a faithful full-pipeline measurement
  (9/251→15/251 edges over threshold, 6.1x layout-width growth),
  root-caused to convergence instability at high-mate-count “hub”
  individuals. **Verdict: NOT FEASIBLE as prototyped.** Owner-ratified
  recommendation: a second, narrower spike adapting a proven library
  (`igraph::layout_with_sugiyama()`) rather than tuning this candidate
  further; campaign document deferred. Updated `BACKLOG.md` (S588 item
  DONE, new READY item for the 2nd spike); commented on GitHub issue
  \#159 (not closed). Added `PROJECT_LEARNINGS.md` Learnings 598–600;
  fixed a stale learnings-count cross-reference in `CLAUDE.md`.
  Planning/investigation session, TDD phases inapplicable — no `R/` file
  touched.

### 2026-08-15 · \[BL-N\] S589: claim (pedigree-diagram layout feasibility spike)

- **Deliverable:** Non-commit-adjacent claim entry per Phase 1B. Session
  claimed to run the pedigree-diagram layout feasibility spike
  (`BACKLOG.md`, found S588, HIGH PRIORITY) — prototype one
  non-rigid/constraint-aware layout candidate (barycenter/median
  layered-DAG compaction, owner-selected via `AskUserQuestion`), tested
  against the synthetic example and a faithful real-fixture
  reproduction. Planning/investigation session, TDD phases inapplicable.

### 2026-08-15 · \[ad hoc\] S588: reconcile HANDOFFS.md commit self-reference (`999c3b74`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: ... this close-out commit` -\> the real sha (`999c3b74`,
  close-out) — unknowable until after that commit existed. Matches the
  established S562-S587 precedent.

### 2026-08-15 · \[BL-N\] S588: close out (pedigree-diagram sibling subtree-width asymmetry design)

- **Deliverable:** Designed a fix for “Pedigree Diagram: sibling
  subtree-width asymmetry” (`BACKLOG.md`, found S576) —
  `docs/planning/pedigree-diagram-sibling-subtree-width-plan.md` + a
  runnable evidence document,
  `docs/planning/pedigree-diagram-sibling-subtree-width-evidence.qmd`.
  Built a 13-individual synthetic reproduction, rendered it via kinship2
  and nprcgenekeepr side by side, and empirically tested one candidate
  (bounded-depth contour-merge lookahead) — rejected: it closed the
  toy-example gap but introduced an edge crossing and regressed a
  real-fixture proxy measure. Found the deeper reason no low-risk tuning
  of the current algorithm can work (the rigid-subtree model shared with
  the Reingold-Tilford/Walker/Buchheim-Jünger-Leipert family issue \#141
  names). First ratified DEFER (Round 1); owner corrected mid-session
  (“high priority, work cost is not a deterrent”); re-ratified COMMIT to
  a redesign (Round 2, both rounds recorded transparently). Filed GitHub
  issue \#159, then updated it to reflect Round 2. Updated `BACKLOG.md`
  (S576 item DONE; new READY high-priority feasibility-spike item
  added). Wrote `PROJECT_LEARNINGS.md` Learnings 596 (test candidates
  against both a toy example and the real fixture, render output not
  just metrics) and 597 (surface priority/cost-tolerance questions
  explicitly via `AskUserQuestion` rather than inferring them from
  measured technical severity).

### 2026-08-15 · \[BL-N\] S588: claim (design a fix for pedigree-diagram sibling subtree-width asymmetry)

- **Deliverable:** Non-commit-adjacent claim entry per Phase 1B. Session
  claimed to design a fix for “Pedigree Diagram: sibling subtree-width
  asymmetry” (`BACKLOG.md`, found S576) — one architecture/design
  document, planning session, TDD phases inapplicable.

### 2026-08-15 · \[ad hoc\] S587: push commits (`d6deec73..94fcab60`)

- **Deliverable:** Non-commit action, recorded per failure mode \#27.
  Owner-directed push of this session’s 4 commits (`8b4d0f18` claim,
  `45b44585` fix + close-out, `8d4ae826` HANDOFFS.md reconcile,
  `94fcab60` CHANGELOG reconcile-of-reconcile) — the `inst/WORDLIST`
  fix. Clean fast-forward, no force. `master` and `origin/master` in
  sync.

### 2026-08-15 · \[ad hoc\] S587: reconcile HANDOFFS.md commit self-reference (`45b44585`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: ... close-out commit sha to follow` -\> the real sha
  (`45b44585`, fix + close-out) — unknowable until after that commit
  existed. Matches the established S562-S586 precedent.

### 2026-08-15 · \[BL-N\] S587: close out (R-CMD-check.yaml CI fix — inst/WORDLIST gap)

- **Deliverable:** Fix the red `R-CMD-check.yaml` CI (`BACKLOG.md`
  Housekeeping, found S584) — added 4 words
  [`spelling::spell_check_package()`](https://docs.ropensci.org/spelling//reference/spell_check_package.html)
  flags (`matings`, `Rectilinear's`, `runnable`, `visNetwork's`) to
  `inst/WORDLIST`, each at its alphabetic neighbor. All 4 confirmed via
  grep as legitimate tracked-source domain/package-name terms before
  whitelisting, not typos. Owner interrupted mid-verification to
  question running the full `test_dir()` clean regression for a non-code
  data-file change — corrected to
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  alone (the literal CI-matching build equivalent): 0 errors/0
  warnings/1 pre-existing unrelated NOTE; `test_wordlist_ coverage.R`
  3/3 passing. Written up as `PROJECT_LEARNINGS.md` Learning 595.
  Removed the completed item from `BACKLOG.md` Housekeeping.

### 2026-08-15 · \[BL-N\] S587: claim (fix red R-CMD-check.yaml CI)

- **Deliverable:** Non-commit-adjacent claim entry per Phase 1B. Session
  claimed to fix the `inst/WORDLIST` gap `BACKLOG.md` Housekeeping filed
  at S584.

### 2026-08-15 · \[ad hoc\] S586: push commits (`c17451e7..981e463c`)

- **Deliverable:** Non-commit action, recorded per failure mode \#27.
  Owner-directed push of this session’s 3 commits (`a8367a4f` claim,
  `b1e8f8f2` fix + close-out, `981e463c` HANDOFFS.md reconcile) — the
  lint.yaml fix plus the CLAUDE.md verification-formula correction.
  Clean fast-forward, no force. `master` and `origin/master` in sync.

### 2026-08-15 · \[ad hoc\] S586: reconcile HANDOFFS.md commit self-reference (`b1e8f8f2`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: ... close-out commit sha to follow` -\> the real sha
  (`b1e8f8f2`, fix + close-out) — unknowable until after that commit
  existed. Matches the established S562-S585 precedent.

### 2026-08-15 · \[BL-N\] S586: close out (lint.yaml CI fix — R/kinship.R nested-ifelse + implicit-integer)

- **Deliverable:** Fix the red `lint.yaml` CI (`BACKLOG.md`
  Housekeeping, found S584) — 3 pre-existing lints in
  `R/kinship.R:127,131,133` from S564’s X-chromosome kinship work —
  DONE. Collapsed the nested
  [`ifelse()`](https://rdrr.io/r/base/ifelse.html) computing `sexNum`
  (line 126-128) into a single vectorized
  [`match()`](https://rdrr.io/r/base/match.html)/index lookup
  (`c(1L, 2L)[match(sex, c(sexCodes[["male"]], sexCodes[["female"]]))]`),
  provably behavior-identical by R’s own coercion/indexing semantics;
  changed the two bare `0` literals in `c(founderDiag, 0)` (sparse and
  dense branches) to `0.0`. Strict-TDD: a pre-RED scope decision (close
  a found test-coverage gap before touching the sparse branch),
  PRE-RED→RED, and GREEN→REFACTOR (declined, recommended) all fired as
  `AskUserQuestion` gates before their phase’s first edit.
- **Pre-RED finding:** no existing test combined `chrtype = "x"` with
  `sparse = TRUE` — the dense X-linked branch was thoroughly
  characterized (self-kinship, unknown-sex→NA, twin correction) but the
  sparse X-linked branch (containing one of the two implicit-integer
  lint sites) had zero coverage. Added
  `test_that("kinship() with chrtype = 'x' gives identical results for sparse = TRUE and sparse = FALSE")`
  to `tests/testthat/test_kinship.R`, mirroring the file’s existing
  twin-corrected sparse/dense-parity test. Confirmed GREEN against
  unmodified code (not a failing-first RED — this is a pure refactor
  task with no new behavior, so the safety-net test starts passing by
  design, a distinction surfaced and approved at the PRE-RED→RED gate).
- **Verification:** (1) new test file 34/34 assertions passing after the
  fix; (2) `lintr::lint_package()` (the literal `lint.yaml` CI
  mechanism, `LINTR_ERROR_ON_LINT=true`) — 0 lints package-wide, down
  from 3; (3) full clean regression (`NOT_CRAN=true`) — 0 new
  failures/errors, the only failure is the pre-existing,
  already-documented `test_wordlist_coverage.R` WORDLIST gap (S573); (4)
  runtime-reachability check — grepped
  `R/mod*.R`/`appServer.R`/`appUI.R` for `chrtype`: zero matches,
  confirming the modified branch is script-callable only, not wired to
  any live Shiny path (all in-app
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  calls use the default autosomal branch, untouched by this fix) — the
  basis for the Phase 3E runtime-smoke determination.
- **Process fix (found this session, close-out documentation):**
  `CLAUDE.md`’s “Clean regression read” formula was missing the
  `NOT_CRAN=true` prefix its neighboring “Fast single-file test” formula
  requires — run verbatim as documented, it silently skipped
  `test_wordlist_coverage.R`’s `skip_on_cran()` and reported a false
  `sum(failed): 0` where 1 was expected. Caught only because this
  session’s own Phase 0 orientation had already established the WORDLIST
  gap as a known open failure. Fixed inline in `CLAUDE.md` (added the
  prefix); see `PROJECT_LEARNINGS.md` Learning
  594. 

### 2026-08-15 · \[BL-N\] S586: claim (fix red lint.yaml CI)

- **Deliverable:** Session claimed. Picked from the Phase 0 priorities
  picker (1 of 4 options, first-listed per S585’s own `next_steps`
  ordering). Phase 1B stub written to `SESSION_NOTES.md`; pending
  receipt opened in `HANDOFFS.md`. Commit `a8367a4f`.

### 2026-08-15 · \[ad hoc\] S585: reconcile HANDOFFS.md commit self-reference (`6a34c351`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> the three real shas (`6a34c351` close-out,
  `9ab5b507` fix + guard, `eace45d8` claim) – unknowable until after
  those commits existed. Matches the established S562-S584 precedent.

### 2026-08-15 · \[BL-N\] S585: close out (pkgdown.yaml CI fix — articles: contents: gap)

- **Deliverable:** Fix the red `pkgdown.yaml` CI (`BACKLOG.md`
  Housekeeping, found S584 — and, discovered while removing the item,
  independently found a day earlier by S566, never cross-referenced by
  either session) — DONE. Added the missing
  `- articles/pedigree-diagram` line to `_pkgdown.yml`’s `articles:` →
  `contents:` list, plus a new regression-test guard (4th `test_that()`
  in `test_pkgdown_reference_config.R`) mirroring the file’s existing
  `reference:`-coverage tests: compares `pkg$vignettes$name` (pkgdown’s
  own ground-truth article list, partials auto-excluded) against the
  configured `articles: contents:` list via
  [`setdiff()`](https://rdrr.io/r/base/sets.html). Strict-TDD: a pre-RED
  scope decision, PRE-RED→RED, RED→GREEN, and GREEN→REFACTOR (skipped,
  declared, not silently omitted) all fired as `AskUserQuestion` gates
  before their phase’s first edit.
- **Verification (5 checks, all run this session):** (1) RED confirmed —
  the new test failed, naming `articles/pedigree-diagram` exactly, with
  the file’s 3 pre-existing tests unaffected;
  2.  GREEN confirmed — same test file 5/5 passing; (3) full clean
      regression — 1 pre-existing unrelated failure
      (`test_wordlist_coverage.R`, the already-filed S573 WORDLIST gap),
      0 errors;
  3.  `lintr::lint_package()` — 0 lints on the touched R file; (5)
      faithful check — directly invoked
      `pkgdown:::build_articles_index(pkg)`, the exact internal function
      CI’s error names
      (`Error in build_articles_index(): ! In _pkgdown.yml, 1 vignette missing from index`),
      and confirmed it now succeeds. (A stray `pkgdown/favicon/`
      directory this direct call generated as a side effect was removed
      before commit — not part of the deliverable.)
- **Housekeeping:** removed 2 `BACKLOG.md` items for the identical gap —
  S584’s (found via this session’s own push finally letting CI run) and
  a previously-unfixed S566 entry (2026-08-14, filed a day earlier,
  never cross-referenced by S584). See `PROJECT_LEARNINGS.md` Learning
  593 for the generalizable “grep before filing” rule this collision
  motivates.
- **Not done, out of scope (user-directed via the pre-RED
  `AskUserQuestion`):** did not add an articles-index-coverage clause to
  `CLAUDE.md`’s existing `_pkgdown.yml` reference-coverage checklist —
  offered as a 3rd scope option, declined in favor of “fix + regression
  test guard” only.

### 2026-08-15 · \[BL-N\] S585: claim (fix red pkgdown.yaml CI)

- **Deliverable:** Session claimed. Picked from the Phase 0 priorities
  picker as the widest- blast-radius of the 3 CI reds S584 filed (the
  docs site was not deploying at all). Phase 1B stub written to
  `SESSION_NOTES.md`; pending receipt opened in `HANDOFFS.md`.

### 2026-08-15 · \[ad hoc\] S584: push documentation commits (`7436a7a9..07824e0a`)

- **Deliverable:** Non-commit action, recorded per failure mode \#27.
  Owner-directed second push of this session’s 2 remaining
  documentation-only commits (`9c817bcb`, `07824e0a` — `BACKLOG.md`,
  `CHANGELOG.md`, `HANDOFFS.md`; no source or test files). Clean
  fast-forward, no force. `master` and `origin/master` in sync.
- **Expected CI consequence, stated up front:** this re-triggers the 4
  push-triggered workflows. `pkgdown`, `lint` and `R-CMD-check` are
  expected to fail again — the 3 pre-existing defects recorded in the
  entry below are untouched by a docs-only push, and were deliberately
  left unfixed as separate deliverables. `test-coverage` is expected to
  pass. No new information is anticipated from these runs; they are a
  side effect of the push, not a verification step.

### 2026-08-15 · \[ad hoc\] S584: CI outcome of the push — S584’s fix CONFIRMED green; 3 pre-existing reds surfaced

- **`shinytest2` SUCCESS** (run `31868762486`) — **this session’s fix
  confirmed in CI, not just locally.** The previously-failing group
  reports
  `^e2e-mate-pair-analysis-module: files=1 passed=8 failed=0 skipped=0 error=0`
  (was `error=1`), matching the local reproduction exactly; all 19
  module groups pass. Independent bonus confirmation of Learning 592:
  `^e2e-twin-relations-: files=1 passed=3` now appears and runs, proving
  its absence from the old CI log was a stale-snapshot artifact, never a
  partition drift.
- **`test-coverage` SUCCESS.**
- **3 pre-existing failures surfaced, none caused by this session, each
  independently dated** — all invisible to CI until this push because it
  had been pinned to a 145-commit-stale `origin/master`:
  - **`pkgdown` FAILURE** (`31868761401`) — `articles/pedigree-diagram`
    missing from `_pkgdown.yml`; the article landed in `2b3e8ef6` (S560)
    without an index entry. Docs site does not deploy.
  - **`lint` FAILURE** (`31868761462`) — 3 lints in
    `R/kinship.R:127,131,133` from `7bbc6273` (S564); the job sets
    `LINTR_ERROR_ON_LINT: true`. A miss against `CLAUDE.md`’s own Lint
    close-out checklist, not a novel gap.
  - **`R-CMD-check` FAILURE** (`31868761411`) — all 5 platform jobs,
    `Status: 1 ERROR, 1 NOTE`, the `inst/WORDLIST` gap from `c9860f4b`
    (S573). **Answers this session’s own open question:** CI is NOT
    masking it (`r-lib/actions` sets `NOT_CRAN`, so `skip_on_cran()`
    never fires), which also settles the S581 “0 errors” discrepancy —
    the failure is real and platform-independent.
- **All 3 filed as `BACKLOG.md` items, none fixed** — each is a separate
  deliverable under “1 and done” (`PROJECT_LEARNINGS.md` Learning 382’s
  report-don’t-fix precedent).

### 2026-08-15 · \[BL-N\] S584: push master to origin (148 commits) + dispatch shinytest2.yaml

- **Deliverable:** Non-commit action, recorded per failure mode \#27.
  Owner directed “push” after this session’s close-out surfaced the
  145-commit divergence as a `BACKLOG.md` DECISION NEEDED item; the
  unpushed state was **not** deliberate. Pushed `7021c6f7..7436a7a9`
  (148 commits = the 145 pre-existing + this session’s 3), clean
  fast-forward, no force, `master -> master`, verified by
  `git push --dry-run` before executing. `master` and `origin/master`
  now in sync for the first time since S545 (2026-08-13).
- **CI consequence:** the 4 push-triggered workflows (`R-CMD-check`,
  `lint`, `pkgdown`, `test-coverage`) fired automatically against
  current `HEAD` – their first run against any work since S545.
  `shinytest2.yaml` has no push trigger (`schedule`/`workflow_dispatch`
  only), so it was dispatched by hand:
  `gh workflow run shinytest2.yaml --ref master`, run `31868762486`.
  This is the run that actually observes S584’s own fix in CI rather
  than locally.
- **`BACKLOG.md` item closed** in the same commit (the “local master is
  145 commits ahead” item filed earlier this session).

### 2026-08-15 · \[ad hoc\] S584: reconcile HANDOFFS.md commit self-reference (`f36146ea`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> the three real shas (`f36146ea` close-out,
  `66593c61` fix + guard, `9b23075e` claim) – unknowable until after
  those commits existed. Matches the established S562-S583 precedent.

### 2026-08-15 · \[ad hoc\] S584: close out (shinytest2.yaml CI red diagnosed AND fixed, + regression guard)

- **Deliverable:** Root-caused the scheduled `shinytest2.yaml` failure
  (red 3 consecutive nights, 2026-08-12/13/14):
  `.github/workflows/shinytest2.yaml:161-183` runs the E2E tier by
  spawning one `Rscript -e 'testthat::test_dir(...)'` per module group,
  which bypasses `tests/testthat.R` – the only file in the repo calling
  [`library(nprcgenekeepr)`](https://rmsharp.github.io/nprcgenekeepr/).
  `test_dir()` does not attach the package under test and no
  `helper-*.R`/`setup.R` does either, so package exports are absent in
  that process (`exists("makeExamplePedigreeFile")` -\> `FALSE`).
  `tests/testthat/test-e2e-mate-pair-analysis-module.R:58` called
  [`makeExamplePedigreeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeExamplePedigreeFile.md)
  bare (correctly exported at `NAMESPACE:136`; a pure lookup failure)
  and had never once passed in CI – it shipped in `8781709d` (S513,
  issue \#151 Slice 2) and the nightly went red the night it landed.
  Every local verification path `CLAUDE.md` documents begins with
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html),
  which DOES attach the package, so no local run could have reproduced
  it.
- **Scope, measured not assumed:** a call-graph sweep of all 30
  `test-{e2e,app}-*.R` files (bare called names intersected with
  [`getNamespaceExports()`](https://rdrr.io/r/base/ns-reflect.html),
  minus helper- and self-defined names) found **exactly one** offending
  call site.
- **Fix (Strict TDD, all 3 gates fired as `AskUserQuestion` calls before
  their phase’s first edit):** RED – new
  `tests/testthat/test_e2e_package_qualification.R`, a static guard that
  fails if any E2E-tier file calls a package export bare, confirmed
  failing and naming the offender. GREEN – one-line qualification to
  `nprcgenekeepr::makeExamplePedigreeFile(` plus a comment recording why
  it must stay qualified. REFACTOR not entered (nothing to restructure;
  stated, not skipped).
- **Verification:** guard GREEN; the previously-failing group rerun with
  the EXACT CI command in the un-attached environment now
  `files=1 passed=8 failed=0 skipped=0 error=0` (also clearing the
  workflow’s own `p == 0` silent-skip guard); full clean regression
  5,958 passed / 1 pre-existing unrelated failure
  (`test_wordlist_coverage.R`) / 0 errors; `lintr::lint_package()` 0
  lints on touched files;
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  **1 error / 0 warnings / 1 note — both pre-existing, neither caused by
  this session** (the error is the same `test_wordlist_coverage.R`
  failure, flagging `matings` and `visNetwork's` from
  `NEWS.md:232`/`NEWS.md:208`; the note is the known `vignettes/figure/`
  knitr leftover). Provenance verified rather than assumed: both words
  entered `NEWS.md` in `c9860f4b` (S573, 2026-08-14 14:34), and this
  session modified neither `NEWS.md` nor `inst/WORDLIST`. Filed as its
  own `BACKLOG.md` item — the project’s documented build equivalent has
  been red since S573 with no session reporting it.
- **Cleared, not assumed:** the commit titled “corrected .Rbuildignore”
  (`79f37e18`) sits in the regression window but its diff touches
  nothing under `R/`; and the CI log’s missing `^e2e-twin-relations-`
  module group is a stale-snapshot artifact, not a Learning-312
  partition drift – both that test file and its group regex were added
  together in the unpushed `c91f7c49`.
- **Filed:** new `BACKLOG.md` Housekeeping item (DECISION NEEDED) –
  local `master` is 145 commits ahead of `origin/master`, so all CI is
  testing S545-era code and this fix cannot be observed green until a
  push (and `shinytest2.yaml`, having no push trigger, then needs a
  manual `workflow_dispatch`). See `PROJECT_LEARNINGS.md` Learnings 591
  and 592.

### 2026-08-15 · \[ad hoc\] S584: claim (diagnose the red scheduled shinytest2.yaml CI run)

- **Deliverable:** Session claimed. Phase 0’s unconditional
  `gh run list --branch master` check (the `CLAUDE.md` convention
  ratified S545) found the scheduled `shinytest2.yaml` workflow
  `completed failure` on both 2026-08-13 and 2026-08-14 – first flagged
  by S581’s own Phase 0, carried forward unchanged through S582/S583’s
  handoffs, never diagnosed. Owner picked this as this session’s
  deliverable from the Phase 0 priorities picker. Scoped as diagnosis
  (root cause with evidence from the actual failing run); any fix goes
  through a phase gate first. Phase 1B stub written to
  `SESSION_NOTES.md`; pending receipt opened in `HANDOFFS.md`.

### 2026-08-15 · \[ad hoc\] S583: reconcile HANDOFFS.md commit self-reference (`ce830dbe`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> `ce830dbe` (the close-out commit’s own sha,
  unknowable until after that commit was made) – matching the
  established S562-S582 precedent.

### 2026-08-15 · \[BL-N\] S583: close out (union-outside-parents-span finding filed)

- **Deliverable:** New `BACKLOG.md` item filed (found S583) – a mating
  union with a single child (or whose children’s own midpoint falls
  outside the parents’ span) can be positioned entirely outside its own
  two parents’ x-range, diverging from kinship2’s own
  always-centered-between- spouses convention. Distinct from the S576
  sibling subtree-width item (that one measures distance from a union to
  its CHILDREN; this one measures distance from a union to its PARENTS –
  an axis Track 6’s own verification never checked). Reproduced live via
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  on the real `obfuscated_rhesus_mhc_ped.csv` fixture, the same 6-animal
  subgraph `pb_diagram_legend.png` depicts: `5A6DFT` x=-60, `8DKELJ`
  x=60, their union x=120 (outside the parent span). Confirmed via a
  direct
  [`kinship2::pedigree()`](https://rdrr.io/pkg/kinship2/man/pedigree.html)/`plot.pedigree()`
  comparison of the identical pedigree – kinship2 centers the descent
  line between the two parents unconditionally. No code changed;
  investigation and filing only, per the user’s own choice among 3
  offered next steps. See `PROJECT_LEARNINGS.md` Learning 590.

### 2026-08-15 · \[BL-N\] S583: claim (file union-outside-parents-span finding)

- **Deliverable:** Session claimed. Investigating a user question about
  `pb_diagram_legend.png` surfaced that a mating union’s x can land
  entirely outside its own two parents’ x-span (not just off-center
  among children) – filing this as a new `BACKLOG.md` finding, distinct
  from the already-tracked S576 sibling subtree-width item. Phase 1B
  stub written to `SESSION_NOTES.md`; pending receipt opened in
  `HANDOFFS.md`.

### 2026-08-15 · \[ad hoc\] S582: reconcile HANDOFFS.md commit self-reference (`3e8870d2`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> `3e8870d2` (the close-out commit’s own sha,
  unknowable until after that commit was made) – matching the
  established S562-S581 precedent.

### 2026-08-15 · \[BL-N\] S582: close out (pb_diagram_legend.png reshoot DONE)

- **Deliverable:** `BACKLOG.md` item (found S574) – **DONE**. Recaptured
  `vignettes/articles/shiny_app_use/pb_diagram_legend.png` via a
  standalone `shinytest2`/chromote script reproducing the canonical
  `pedigree-diagram-screenshots.R`’s “Base fixture” step
  (`obfuscated_rhesus_mhc_ped.csv`, focal ids
  `8LKBV9`/`FJIB3R`/`GA204Z`, selector `#pedigree-moduleContainer`),
  deliberately not setting `pedigreeEdgeStyle` so the capture inherits
  the app’s own current zero-interaction default (`"rectilinear"`,
  confirmed live via `R/modPedigree.R`’s `.currentEdgeStyle()`). New
  image confirmed showing “Rectilinear (kinship2-style)” pre-selected
  with right-angle edge routing, diffed visually against the prior
  committed image. Build-equivalent:
  [`pkgdown::build_article()`](https://pkgdown.r-lib.org/reference/build_articles.html)
  for both `articles/pedigree-diagram` and
  `articles/colony-manager-guide` rendered clean (`quarto render`);
  built HTML’s embedded image MD5-confirmed identical to the new source
  PNG. Render litter removed before commit. Neither article’s prose
  needed a change (already said “Rectilinear” is the default, from Track
  2’s own S574 pass). Incidental finding filed as its own `BACKLOG.md`
  item, not fixed: the same script’s other 3 non-base-fixture
  screenshots share the identical never-sets-`pedigreeEdgeStyle`
  omission and may be stale by the same mechanism, unverified. See
  `PROJECT_LEARNINGS.md` Learning 589.

### 2026-08-14 · \[BL-N\] S582: claim (reshoot pb_diagram_legend.png)

- **Deliverable:** Session claimed. `BACKLOG.md` item (found S574) –
  reshoot `shiny_app_use/pb_diagram_legend.png`, stale since Track 2
  (S574) flipped the Diagram tab’s zero-interaction default to
  Rectilinear. Phase 1B stub written to `SESSION_NOTES.md`; pending
  receipt opened in `HANDOFFS.md`.

### 2026-08-14 · \[ad hoc\] S581: reconcile HANDOFFS.md commit self-reference (`6dd26870`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> `6dd26870` (the close-out commit’s own sha,
  unknowable until after that commit was made) – matching the
  established S562-S580 precedent.

### 2026-08-14 · \[BL-N\] S581: close out (locale-dependent order() tie-break sweep DONE)

- **Deliverable:** `BACKLOG.md` order()-sweep item (found S578) –
  **DONE**. Fresh `grep -n "order(" R/*.R` (26 sites) classified all; 4
  real hits fixed (`method = "radix"` added, RED-\>GREEN-\>REFACTOR):
  `orderReport.R:81,93`, `qcStudbook.R:323`, `modBreedingGroups.R:690`
  `bgGroupView`. 2 initially-flagged hits corrected to false positives
  via empirical verification: `kinshipMatrixToKValues.R:107`
  (data.table’s own `forder()` auto-substitution),
  `computeGenomicROH.R:112` (returned value provably locale-invariant
  despite the intermediate sort being locale-sensitive) – explanatory
  comments added, no behavior change. See `PROJECT_LEARNINGS.md`
  Learning 588 for the full classification methodology.

### 2026-08-14 · \[BL-N\] S581: verification (full clean regression + live E2E)

- **Deliverable:** 4 targeted RED tests confirmed GREEN post-fix; full
  clean regression 5,955 passed / 1 pre-existing failure unrelated
  (`test_wordlist_coverage.R`) / 0 errors / 33 pre-existing warnings
  (both match the established baseline); 0 lints on all 5 touched R
  files (`lintr::lint_package()`, project’s own `.lintr` config);
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  0 errors/0 warnings/1 pre-existing NOTE (`vignettes/figure/` knitr
  leftover). Live E2E (`NPRC_RUN_E2E=true`, real `shinytest2`/`chromote`
  browser) confirmed all 3 affected runtime paths:
  `test-e2e-mate-pair-analysis-module.R` (qcStudbook),
  `test-e2e-genetic-value-tutorial.R` (orderReport/reportGV),
  `test-e2e-breeding-groups-module.R` (bgGroupView) – all pass.

### 2026-08-14 · \[BL-N\] S581: REFACTOR (explanatory comments, no behavior change)

- **Deliverable:** Added comments to `R/kinshipMatrixToKValues.R:107`
  and `R/computeGenomicROH.R:112` documenting why each is NOT the
  Learning 585 defect class despite superficially matching the
  character-column-sort pattern. Verified no behavior change (both
  files’ own test suites pass unchanged); 0 lints.

### 2026-08-14 · \[BL-N\] S581: GREEN (method=“radix” for 4 confirmed hits)

- **Deliverable:** `R/orderReport.R:81,93`, `R/qcStudbook.R:323`,
  `R/modBreedingGroups.R:690` – `method = "radix"` added to each
  locale-dependent [`order()`](https://rdrr.io/r/base/order.html) call.
  4 targeted RED tests now GREEN; full clean regression 1 pre-existing
  failure unrelated, 0 errors; 0 lints on touched files;
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  0 errors/0 warnings/1 pre-existing NOTE.

### 2026-08-14 · \[BL-N\] S581: RED (4 confirmed locale-dependent order() hits)

- **Deliverable:** Fresh `grep -n "order(" R/*.R` classification (26
  sites). 4 real hits confirmed via empirical divergence testing and RED
  tests added: `test_orderReport.R` (2 new blocks), `test_qcStudbook.R`
  (1 new block), `test_modBreedingGroups.R` (1 new block,
  [`shiny::testServer()`](https://rdrr.io/pkg/shiny/man/testServer.html)
  – no prior coverage of `bgGroupView` existed). All 4 confirmed failing
  for the right reason against unmodified source; 0 regressions in the 3
  touched test files. 2 initially-flagged hits
  (`kinshipMatrixToKValues.R:107`, `computeGenomicROH.R:112`) corrected
  to false positives during this same investigation – no test written
  for either (nothing to prove).

### 2026-08-14 · \[BL-N\] S581: claim session (locale-dependent order() tie-break sweep)

- **Deliverable:** Phase 1B claim. Picked via Phase 0 `AskUserQuestion`
  from `BACKLOG.md`’s order()-sweep item (found S578). Wrote
  `SESSION_NOTES.md` claim stub and `HANDOFFS.md` `status: pending`
  receipt. PRE-RED investigation (fresh grep + classification) up next.

### 2026-08-14 · \[ad hoc\] S580: reconcile HANDOFFS.md commit self-reference (`75c23fe5`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> `75c23fe5` (the close-out commit’s own sha,
  unknowable until after that commit was made) – matching the
  established S562-S579 precedent.

### 2026-08-14 · \[BL-N\] S580: close out (HANDOFFS.md byte-budget/line-headroom archive trim DONE)

- **Deliverable:** Session S580’s own close-out. Evaluated S579’s
  `HANDOFFS.md` receipt (9/10 – the `gotchas` field’s `SRF_RED`
  non-durability warning primed this session for the identical
  divergence on `HANDOFFS.md`, saving a full re-diagnosis).
  Self-assessed 9/10 (proactively added the claim commit’s own ledger
  entry instead of waiting for `P1_UNDOCUMENTED` to catch it; pulled
  absolute byte deltas before the `SRF_RED` decision; caught and fixed a
  stranded front-matter sentence the tool’s own edit left behind;
  weakness: still no independent adversarial-verification pass, and
  skipped a second scope-confirmation `AskUserQuestion` after the
  picker). Wrote handoff notes to `SESSION_NOTES.md`; completed the
  `HANDOFFS.md` receipt (`status: complete`).

### 2026-08-14 · \[BL-N\] S580: downstream updates (BACKLOG item resolved, PROJECT_LEARNINGS 587)

- **Deliverable:** Removed the resolved `BACKLOG.md` Housekeeping item
  (`HANDOFFS.md`’s archive trigger, found S579), replaced with a short
  resolution pointer. Added `PROJECT_LEARNINGS.md` Learning 587:
  confirms the Learning 586 `SRF_RED` recurrence pattern is not
  `CHANGELOG.md`- specific – the very next session hit it on
  `HANDOFFS.md` too, a file Learning 549 had cited as having “proceeded
  cleanly” the one time it was checked. Also repositioned
  `HANDOFFS.md`’s own “This file currently holds N receipt(s)” sentence
  back to immediately after the newest archive pointer (the tool’s
  in-place regex edit left it stranded between the 3rd and 4th pointer
  blocks after this session’s new pointer was inserted), matching the
  established S508/S561 convention.

### 2026-08-14 · \[ad hoc\] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-08-14.md` (21 record(s), 125,404 B → 9,682 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a
session’s judgment. Moved the oldest **21** record(s) (2026-08-13 →
2026-08-14) out of
[`HANDOFFS.md`](https://github.com/rmsharp/nprcgenekeepr/HANDOFFS.md)
into
[`docs/archive/HANDOFFS-through-2026-08-14.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-08-14.md).
Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run
[`docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh)
rather than trusting a digest printed here. Live file 125,404 B → 9,682
B (−92.3%).

### 2026-08-14 · \[BL-N\] S580: claim session (HANDOFFS.md byte-budget/line-headroom archive trim)

- **Deliverable:** Phase 1B claim stub written to
  `SESSION_NOTES.md`/`HANDOFFS.md` (`status: pending`) for this
  session’s deliverable: archive `HANDOFFS.md`’s tagged-receipt portion
  into a new dated shard (`BACKLOG.md` Housekeeping, found S579) – both
  the line-headroom (4 records against the 15-record threshold) and
  byte-budget (125,043 B against 65,536 B) triggers fire. Owner-picked
  via `AskUserQuestion` over 3 other READY items (locale-dependent
  [`order()`](https://rdrr.io/r/base/order.html) sweep, sibling
  subtree-width asymmetry, stale `pb_diagram_legend.png` screenshot).

### 2026-08-14 · \[BL-N\] S579: post-close-out finding: HANDOFFS.md’s own archive trigger fires

- **Deliverable:** A post-close-out `--check` sweep of both ledgers
  (prompted by this session’s own `CHANGELOG.md` trim) found
  `HANDOFFS.md`’s line-headroom trigger now fires (4 records against the
  15-record threshold) – not fixed this session (out of scope), filed as
  a new `BACKLOG.md` Housekeeping item with the SRF boundary numbers
  already pulled for whoever picks it up next.

### 2026-08-14 · \[ad hoc\] S579: reconcile HANDOFFS.md commit self-reference (`c35b1983`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> `c35b1983` (the close-out commit’s own sha,
  unknowable until after that commit was made).

### 2026-08-14 · \[BL-N\] S579: close out (CHANGELOG.md byte-budget archive trim DONE)

- **Deliverable:** Session S579’s own close-out. Evaluated S578’s
  `HANDOFFS.md` receipt (7/10 – the `next_steps` pointer to this exact
  item was accurate and immediately actionable, but no `gotchas` entry
  warned that `CHANGELOG.md` archiving carries a real,
  previously-documented risk of `SRF_RED` refusal). Self-assessed 8/10
  (self-caught a Learning-553-shaped picker-before-prose mistake within
  the same turn; surfaced the `SRF_RED` refusal’s two boundary readings
  plus absolute byte deltas to the user rather than force-passing or
  silently blocking; weakness: the risk wasn’t checked during Phase 0,
  only after committing to the task). Wrote handoff notes to
  `SESSION_NOTES.md`; completed the `HANDOFFS.md` receipt
  (`status: complete`).

**Archived 62 record(s), 2026-08-13 → 2026-08-14** into
[`docs/archive/CHANGELOG-through-2026-08-14.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/CHANGELOG-through-2026-08-14.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/CHANGELOG-through-2026-08-14.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/CHANGELOG-through-2026-08-14.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

### 2026-08-14 · \[ad hoc\] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-08-14.md` (62 record(s), 101,210 B → 32,753 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a
session’s judgment. Moved the oldest **62** record(s) (2026-08-13 →
2026-08-14) out of
[`CHANGELOG.md`](https://github.com/rmsharp/nprcgenekeepr/CHANGELOG.md)
into
[`docs/archive/CHANGELOG-through-2026-08-14.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/CHANGELOG-through-2026-08-14.md).
Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run
[`docs/archive/CHANGELOG-through-2026-08-14.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/CHANGELOG-through-2026-08-14.md.verify.sh)
rather than trusting a digest printed here. Live file 101,210 B → 32,753
B (−67.6%).

### 2026-08-14 · \[ad hoc\] S579: claim session (CHANGELOG.md byte-budget archive trim) (`f18431b0`)

- **Deliverable:** Phase 1B claim stub (`SESSION_NOTES.md`) and
  `HANDOFFS.md` `status: pending` receipt for this session’s
  deliverable: archive `CHANGELOG.md`’s tagged-record portion into a new
  dated shard (`BACKLOG.md` Housekeeping, found S573) — the byte trigger
  fires again (100,783 B against the 65,536 B budget).

### 2026-08-14 · \[ad hoc\] S578: reconcile HANDOFFS.md commit self-reference (`b321df39`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> `b321df39` (the close-out commit whose sha the
  receipt itself couldn’t name until after it was made) – matching the
  established S562-S577 precedent.

### 2026-08-14 · \[BL-N\] S578: close out (Track 6 child-centered union-position implementation DONE) (`b321df39`)

- **Deliverable:** Full session record written (`SESSION_NOTES.md`,
  `HANDOFFS.md` receipt). See the receipt for the complete
  self-assessment (9/10) and predecessor evaluation (8/10).

### 2026-08-14 · \[BL-N\] S578: Track 6 downstream updates for locale-independence fix (BACKLOG, plan doc section 10) (`26f7d909`)

- **Deliverable:** Documents the
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)-found,
  `LC_ALL=C`-reproduced locale-dependent tie-break defect and its
  `method = "radix"` fix in the `BACKLOG.md` DONE item and the plan
  doc’s section 10 Implementation Record. Also files a new `BACKLOG.md`
  Housekeeping item for the same defect class found more broadly across
  the package
  ([`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md),
  `orderReport()`), not fixed this session.

### 2026-08-14 · \[BL-N\] S578: locale-independent tie-break in de-collision pass (`b0467657`)

- **Deliverable:**
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  (run as its own separate build-equivalent step, not skipped as
  redundant with the already-green
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html) +
  `test_dir()` regression read) surfaced 5 test failures, not the 1
  known pre-existing `test_wordlist_coverage.R` failure. Root-caused via
  `LC_ALL=C` reproduction (no code change):
  [`order()`](https://rdrr.io/r/base/order.html) on a character node-id
  vector is `LC_COLLATE`-locale-dependent, so which of 2 exactly-tied
  same-gen nodes absorbs the de-collision pass’s 1e-3 epsilon nudge can
  differ between locales – a genuinely pre-existing latent defect (the
  original pre-Track-6 pass used the same non-radix
  [`order()`](https://rdrr.io/r/base/order.html)) that this session’s
  own widened node-category coverage first exposed as an observable,
  hardcoded-test-breaking symptom. Fixed by adding `method = "radix"`
  (R’s only locale-independent character-vector ordering) to both
  affected [`order()`](https://rdrr.io/r/base/order.html) calls in
  `.positionMatingUnitForest()`; updated 4 `expectPos()` values in
  `test_positionMatingUnitForest.R` to match the new locale-stable
  output. Verified: targeted file green under both `en_US.UTF-8` and
  `LC_ALL=C`; full clean regression under `LC_ALL=C` 1 pre-existing
  unrelated failure, 0 new; `lintr::lint_package()` 0 lints;
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  re-run clean against the established baseline only.
  `PROJECT_LEARNINGS.md` Learning 585 records the finding.

### 2026-08-14 · \[BL-N\] S578: Track 6 downstream updates (BACKLOG, plan doc section 10) (`228b5071`)

- **Deliverable:** Marked the `BACKLOG.md` Housekeeping item DONE
  (implemented S578). Added section 10 (Implementation Record) to
  `docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md`
  documenting the 2 Pre-RED corrections, re-measured headline figures,
  and verification evidence.

### 2026-08-14 · \[BL-N\] S578: GREEN, Track 6 child-centered mating-unit position (`f65ecbea`)

- **Deliverable:** Implements
  `docs/planning/pedigree-diagram-track6-child-centered-union- position-plan.md`
  §2 (Extended Candidate A, design ratified S576) in
  `.positionMatingUnitForest()` (`R/makePedigreeDiagramData.R`): a
  mating unit’s `finalUnitX` is now the midpoint of its own children’s
  final x (was its 2 parents’ midpoint); a duplicate node’s `dupX` is
  now derived from the new `finalUnitX`; the final de-collision pass is
  broadened to cover every node (real, duplicate, union). Pre-RED
  empirical validation found the `orderBySex` block must move earlier in
  the function (finalUnitX/dupX computed after it, not at §2.1’s
  literally-described pre-orderBySex location) for the §2.4 invariant to
  hold. Also fixed 2 pre-existing tests whose assertions directly
  encoded the old parent-midpoint behavior. Verified: all 30 tests in
  `test_positionMatingUnitForest.R` pass; full clean regression 1
  pre-existing unrelated failure, 0 new; `lintr::lint_package()` 0
  lints; real-fixture re-measurement matches the ratified figures
  (100/251→9/251 violating edges, 61.94/120.12→ 48.00/48.00
  duplicate-to-union distance, 0 exact coincidences); live
  `visNetwork`/`chromote` render (both `edgeStyle` values, small + full
  real fixture) 0 console errors, visually confirms unions now sit close
  to their own children.

### 2026-08-14 · \[BL-N\] S578: RED, Track 6 child-centered union-position invariant (`0780cdfd`)

- **Deliverable:** Added 2 new tests to
  `test_positionMatingUnitForest.R` (the §2.4 invariant on the small
  GA204Z/8LKBV9 fixture + the real 375-individual fixture; a
  duplicate-vs-any-node exact-coincidence test) and updated the existing
  “issue \#143 fix” exact-value test (8 of 13 `expectPos()` calls,
  re-derived live via a from-scratch reimplementation of Extended
  Candidate A run against unmodified `.buildMatingUnitForest()` output).
  Confirmed RED: the 3 touched tests fail against unmodified source
  (8/27, 225/241, 1/1 expectations), including a genuine pre-existing
  duplicate/union coincidence unrelated to this decision; all 25 other
  tests in the file pass unchanged.

### 2026-08-14 · \[ad hoc\] S578: claim session (Track 6 child-centered union-position implementation) (`ca921a92`)

- **Deliverable:** Phase 1B claim stub written to
  `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-14 · \[ad hoc\] S577: reconcile HANDOFFS.md commit self-reference (`3a1a8de4`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> `3a1a8de4` (the close-out commit whose sha the
  receipt itself couldn’t name until after it was made) – matching the
  established S562-S576 precedent. Bundled into the SAME commit as this
  entry (unlike S576’s own instance of this same action, which this
  session’s Phase 0 found had no matching `CHANGELOG.md` entry at all
  and had to backfill) – applying this session’s own Phase 0 finding
  immediately rather than repeating the gap.

### 2026-08-14 · \[BL-N\] S577: close out (duplicate-connector arc curve-direction fix DONE)

- **Deliverable:** GREEN implementation ratified via both TDD phase
  gates (`AskUserQuestion` PRE-RED-\>RED and RED-\>GREEN, both approved
  as written; GREEN-\>REFACTOR offered and explicitly skipped).
  `R/makePedigreeDiagramData.R`’s `dupEdges` construction now x-orders
  `from`/`to` instead of always `from=dupId`, matching kinship2’s own
  `arcconnect()` convention (always sorts its pair by x before drawing).
  Verified: targeted tests 188/188, full clean regression 4854/4854 (0
  error), 0 lint on the touched file, real 375-individual fixture
  re-measurement 52/52 same-row connectors now correct (was 19/52), live
  `visNetwork`/`chromote` render visually confirms the convex bow.
  Self-score 9/10; S576 handoff evaluation 9/10. See `HANDOFFS.md` S577
  receipt for the full record.

### 2026-08-14 · \[BL-N\] S577: downstream updates (BACKLOG item removed, plan doc section 7a) (`ee22559c`)

- **Deliverable:** Removed the resolved `BACKLOG.md` Housekeeping item.
  Updated
  `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md`
  section 7a with the root cause and fix summary.

### 2026-08-14 · \[BL-N\] S577: GREEN, x-order duplicate-connector from/to (`a01c176c`)

- **Deliverable:** `R/makePedigreeDiagramData.R` `dupEdges` construction
  (~line 1342): order `from`/`to` by ascending x (using the
  already-computed `nodes$x`) instead of the fixed
  `from=dupId, to=realId`,
  `smooth.type="curvedCW"`/`smooth.roundness=0.2` unchanged. Fixes the
  duplicate-individual dashed connector’s bow direction to match
  kinship2’s own convention regardless of which occurrence sits
  left/right. Verified self-contained: `dupEdges$color`/`width` are
  unconditionally NA regardless of `from`/`to`, and no downstream
  `.addRectilinearWaypoints()` D1/D2 logic keys off a
  duplicate-connector row’s `from`/`to`.

### 2026-08-14 · \[BL-N\] S577: RED, duplicate-connector arc x-ordering (`0d013838`)

- **Deliverable:** Added 2 new tests to
  `tests/testthat/test_makePedigreeMatingLayout.R` (a deterministic
  `loopPed`-fixture case + the real 375-individual bundled fixture)
  asserting every dashed duplicate-connector edge has `from.x <= to.x`.
  Updated 3 existing tests whose filters assumed `from` is always the
  duplicate id, relaxed to `{from,to}` set membership. Confirmed RED:
  184 pass / 4 fail against the pre-fix implementation.

### 2026-08-14 · \[ad hoc\] S577: claim session (duplicate-individual arc curve-direction fix) (`a04090ec`)

- **Deliverable:** Phase 1B claim stub written to
  `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-14 · \[ad hoc\] S576: reconcile HANDOFFS.md commit self-reference (`ce8c50a1`) (Backfilled reconcile-on-read, Session 577)

- **Deliverable:** Fixed S576’s own `HANDOFFS.md` receipt
  `commit: pending` -\> `7b04a911` (the close-out commit whose sha the
  receipt itself couldn’t name until after it was made) – matching the
  established S562-S575 precedent. Backfilled at Session 577 Phase 0
  reconcile: the commit itself (`ce8c50a1`, made at S576 close-out)
  landed with no corresponding `CHANGELOG.md` entry, found via the
  `CHANGELOG.md` frontier (`7b04a911`) trailing `HEAD` by one commit
  while `HANDOFFS.md`’s own frontier had no gap.

### 2026-08-14 · \[BL-N\] S576: close out (Track 6 design ratified)

- **Deliverable:** Design document ratified via `AskUserQuestion`
  (“proceed as written”).
  `docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md`
  DONE. Updated
  `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md`
  (new §4 Track 6 entry, §7b pointer), `BACKLOG.md` (originating item
  annotated DESIGN RATIFIED S576; new item filed for the residual
  sibling-subtree-width-asymmetry finding), `PROJECT_LEARNINGS.md`
  (Learning 582). Self-score 8/10; S575 handoff evaluation 8/10. See
  `HANDOFFS.md` S576 receipt for the full record.

### 2026-08-14 · \[BL-N\] S576: Track 6 design – child-centered mating-unit position

- **Deliverable:** Design document for the pedigree-diagram parent-child
  positioning offset (`BACKLOG.md` Housekeeping, found S575). Decided
  “Extended Candidate A”: recompute a mating unit’s final x from its own
  children’s final x-span instead of its 2 parents; recompute the
  duplicate (non-anchor-parent) node’s x from the new union x; broaden
  the existing de-collision pass to cover duplicates (closes a
  regression the union-only fix alone would introduce, measured this
  session). Validated on the real 375-individual bundled fixture:
  violating child-edges 100/251 -\> 9/251 (91% reduction), worst-case
  offset 10,687 -\> 4,121 scaled units (61% reduction),
  duplicate-to-union distance mean 62/max 120 -\> constant 48. 9
  residual edges (3.6%) traced to a distinct, out-of-scope phenomenon
  (sibling subtree-width asymmetry), filed as its own new `BACKLOG.md`
  item. Implementation is a separate future session.

### 2026-08-14 · \[ad hoc\] S576: claim session (parent-child positioning offset design) (`43dac0f7`)

- **Deliverable:** Phase 1B claim stub written to
  `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-14 · \[ad hoc\] S575: post-close-out correction (2 real findings owner caught in the published artifact)

- **Deliverable:** Owner review of the published comparison artifact
  identified 2 real issues neither Track 5 nor any prior Claim (1-4c)
  checked: (1) the duplicate-connector dashed arc bows concave, opposite
  kinship2’s own convex `arcconnect()` convention; (2) children are
  frequently rendered far from their own parent union – 100/251 (40%)
  real-fixture child-edge groups exceed a 200-unit horizontal offset,
  73/251 (29%) exceed 500, max 10,687, root-caused to
  `R/makePedigreeDiagramData.R:924`’s parent-midpoint union-x
  computation being decoupled from child position, compounded by Track
  3’s per-row `sweepMinSep()`. Corrected the published artifact in place
  (same URL), the remediation plan
  (`docs/planning/pedigree-diagram-kinship2-fidelity- remediation-plan.md`
  new §7), this session’s own `SESSION_NOTES.md`/`HANDOFFS.md` records
  (self-score revised 9 -\> 6), and `PROJECT_LEARNINGS.md` (new Learning
  581, plus repositioned Learning 580 which had been inserted out of
  order). Filed 2 new `BACKLOG.md` Housekeeping items for future
  dedicated sessions – neither fixed this session.

### 2026-08-14 · \[ad hoc\] S575: reconcile HANDOFFS.md commit self-reference (`bb0c9bb2`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> `bb0c9bb2` (the close-out commit whose sha the
  receipt itself couldn’t name until after it was made) – matching the
  established S562-S574 precedent.

### 2026-08-14 · \[ad hoc\] S575: close out (Track 5 re-measurement DONE, no gap found)

- **Deliverable:** Evaluated S574’s handoff (9/10), self-assessed
  (9/10), documented `PROJECT_LEARNINGS.md` Learning 580 (live/offline
  cross-validation + structural-proof pattern for coverage questions),
  wrote the full `HANDOFFS.md` receipt.

### 2026-08-14 · \[ad hoc\] S575: Track 5 re-measurement (no rectilinear routing gap found) (`3c3412af`)

- **Deliverable:**
  `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md`
  §Track 5 – re-measured, after Tracks 3-4 landed, how much
  diagonal-edge residue remains in `edgeStyle = "rectilinear"` mode.
  Cross-validated 3 ways: offline
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
  on the real 375-individual fixture (0 non-dashed diagonal edges
  vs. 237 in `direct` mode); structural proof from
  `.addRectilinearWaypoints()`’s D1/D2 loops (coverage guaranteed by
  construction, any pedigree); live `shinytest2`/`chromote` query of the
  rendered `visNetwork` widget matching the offline figures exactly. All
  5 tracks of the remediation plan are now resolved – no
  `.addRectilinearWaypoints()` change was warranted. Mid-session:
  published a direct-vs-rectilinear comparison Artifact at owner
  request.

### 2026-08-14 · \[ad hoc\] S575: claim session (Track 5 re-measurement) (`68432947`)

- **Deliverable:** Phase 1B claim stub written to
  `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-14 · \[ad hoc\] S574: reconcile HANDOFFS.md commit self-reference (`98327c27`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> `98327c27` (the close-out commit whose sha the
  receipt itself couldn’t name until after it was made) – matching the
  established S562-S573 precedent.

### 2026-08-14 · \[ad hoc\] S574: close out (Track 2 implementation DONE) (`98327c27`)

- **Deliverable:** Evaluated S573’s handoff (9/10), self-assessed
  (9/10), documented `PROJECT_LEARNINGS.md` Learning 579, wrote the full
  `HANDOFFS.md` receipt.

### 2026-08-14 · \[ad hoc\] S574: downstream updates (NEWS, plan doc, BACKLOG) (`4931ef91`)

- **Deliverable:** `NEWS.Rmd`/`NEWS.md` “Changed:” entry; remediation
  plan’s Track 2 section marked DONE with full implementation record, §5
  status line updated (only Track 5 remains); `BACKLOG.md` Housekeeping
  item flagging `pb_diagram_legend.png` as a now-stale screenshot
  (found, not fixed, this session).

### 2026-08-14 · \[ad hoc\] S574: vignette updates for the new default (`6a619ad1`)

- **Deliverable:** Updated `vignettes/a2interactive.Rmd`,
  `vignettes/articles/colony-manager- guide.qmd`, and
  `vignettes/articles/pedigree-diagram.qmd` (the 3rd found during this
  session’s own doc pass, not named in Track 2’s own documentation-debt
  note) – all default-behavior/ node-cap prose corrected to match the
  new rectilinear default.

### 2026-08-14 · \[ad hoc\] S574: test updates for the default edgeStyle flip (`1db9af90`)

- **Deliverable:** 1 test helper + 13 blocks pinned to
  `edgeStyle = "direct"` explicitly or rewritten to assert the new
  default, across `test_addRectilinearWaypoints.R`/
  `test_makePedigreeMatingLayout.R`/`test_modPedigree.R`. A 9th gap in
  `test-e2e-pedigree-module.R` found and fixed only after reinstalling
  the dev package into the `renv` library (`PROJECT_LEARNINGS.md`
  Learning 579).

### 2026-08-14 · \[ad hoc\] S574: Track 2 implementation (flip default edgeStyle to rectilinear) (`cb5141f7`)

- **Deliverable:**
  `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md`
  §Track 2 –
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
  `edgeStyle` default and `R/modPedigree.R`’s `.currentEdgeStyle()`
  NULL-fallback flipped `"direct"` -\> `"rectilinear"` (2-line source
  diff, matching roxygen docstring + regenerated `man/`). Verified: full
  clean regression 0 failed/0 error among true offenders;
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  0 errors/0 warnings/1 pre-existing NOTE; 0 lints; live `shinytest2`
  verification of all 6 named must-not-regress features (#129/#131/#132/
  \#134/#135/#138) against the real bundled fixture (reinstalled dev
  package), 3.05s timed render.

### 2026-08-14 · \[ad hoc\] S574: claim session (Track 2 implementation) (`1a81aefd`)

- **Deliverable:** Phase 1B claim stub written to
  `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-14 · \[ad hoc\] S573: reconcile HANDOFFS.md commit self-reference (`21022157`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> `21022157` (the close-out commit whose sha the
  receipt itself couldn’t name until after it was made) – matching the
  established S562-S572 precedent.

### 2026-08-14 · \[ad hoc\] S573: close out (Track 4 implementation DONE)

- **Deliverable:** Closed out Track 4 implementation (gen-aware D2
  anchor selection, Candidate A) of
  `docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` –
  self-assessed 9/10 (adversarial-verification gap flagged S551-S558
  still open on this larger-than-usual vertical-slice session;
  live-verification screenshots too zoomed-out to visually distinguish
  individual multi-anchor nodes, though live-JS-queried coordinates
  substantively cover the same requirement). Evaluated S572’s own
  handoff 9/10 (accurate, executable §6/§7 pointer; zero material gaps
  except an unflagged second-order consequence – the
  consanguineous-marker dogleg test’s own full premise rewrite). Added
  `PROJECT_LEARNINGS.md` Learning 578 (a committed regression test’s
  fixture can outlive the exact scenario it demonstrates once an
  upstream fix closes a defect class structurally; needs a full premise
  rewrite, not a value update). Cross-updated both planning documents
  (implementation record appended to Track 4’s own plan; the remediation
  plan’s own Track 4 section and §5 status note) and `BACKLOG.md`’s
  Candidate C item. See `SESSION_NOTES.md` Session 573 entry,
  `HANDOFFS.md` S573 receipt.

### 2026-08-14 · \[ad hoc\] S573: Track 4 implementation (gen-aware D2 anchor selection, Candidate A) (GREEN)

- **Deliverable:** `.buildMatingUnitForest()`’s `preferAnchor()`
  (`R/makePedigreeDiagramData.R`) rewritten gen-first (prefers the
  deeper-gen parent, subsuming founder-preference – a founder always has
  `gen == 0`), the elimination/`used` shortcut and now-dead
  `isFounderOf()` removed. `.positionMatingUnitForest()`’s `effGenOf`
  computation and the anchor `dispGenOf` override deleted;
  `positionIndividual()`’s 2 call sites revert to `genOf`. Net
  simplification: 24 insertions / 69 deletions. Establishes the
  structural invariant `matingUnits$gen == genOf[[anchor]]`
  unconditionally, closing the anchor-side row-mismatch residual issue
  \#144’s own plan explicitly predicted and left open (51/237
  real-fixture mismatches -\> 0). PRE-RED: prototyped the exact edit
  directly against live source (stash/rerun precedent), captured the
  full 16-block/43-expectation blast radius, reverted before writing RED
  tests. New invariant test (0 exceptions on the real fixture) plus the
  2 residual-acceptance tests at
  `test_positionMatingUnitForest.R:809-893` rewritten to
  residual-resolved assertions, confirmed RED against unmodified source.
  GREEN: all 16 pre-existing blocks across
  `test_buildMatingUnitForest.R`/`test_positionMatingUnitForest.R`/
  `test_addRectilinearWaypoints.R`/`test_makePedigreeMatingLayout.R`
  re-derived from live implementation output, including a full premise
  rewrite of the consanguineous-marker dogleg-propagation test (its
  triggering scenario is now structurally unreachable). REFACTOR
  declined (owner-confirmed via `AskUserQuestion` – the GREEN diff
  already is the net simplification). Measured redistribution on the
  real fixture: duplicate nodes 128-\>102 (-20.3%), multi-anchor
  individuals 2-\>22 (max 5, `WCPXHD`), direct-style nodes 740-\>714,
  rectilinear nodes 1228-\>1202. Verified: full clean regression 0
  failed/0 error;
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  0 errors/0 warnings/1 pre-existing unrelated NOTE;
  `lintr::lint_package()` 0 lints on all 5 touched files. Phase 3E: live
  `shinytest2` verification against the real bundled fixture, both
  `edgeStyle` values – node counts matched exactly, zero diagram-related
  console errors, 2 screenshots, 4 multi-anchor individuals live-queried
  with valid coordinates; the existing 15-test/52-assertion live E2E
  pedigree-module suite passed unchanged. `NEWS.Rmd` entry added
  (regenerated `NEWS.md`, incidentally catching it up on 5 entries
  already in `NEWS.Rmd` since S563-S571 that had never been
  regenerated). Commit: `f7724917`.

### 2026-08-14 · \[ad hoc\] S573: claim session (Track 4 implementation)

- **Deliverable:** Claim stub for implementing Track 4 (gen-aware D2
  anchor selection, Candidate
  1.  of
      `docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md`
      (ratified S572). Owner-picked via `AskUserQuestion` over Track 2
      (flip default `edgeStyle`), issue \#148’s scope-narrowing
      conversation, and the NPRC outreach plan. Commit: `1ebcb006`.

### 2026-08-14 · \[ad hoc\] S572: reconcile HANDOFFS.md commit self-reference (`c5d2c5a9`)

- **Deliverable:** Fixed this session’s own `HANDOFFS.md` receipt
  `commit: pending` -\> `c5d2c5a9` (the close-out commit whose sha the
  receipt itself couldn’t name until after it was made) – matching the
  established S562-S571 precedent.
