# nprcgenekeepr — Project-Specific Learnings

> Extracted verbatim from `CLAUDE.md` on 2026-06-06 to keep `CLAUDE.md`
> within its size budget (Claude Code targets ~200 lines / ~25 KB; the
> file had grown to 97k chars, ~91% of which was this single table). No
> content was changed in the move. **Append new project learnings here,
> not in `CLAUDE.md`.** Base, methodology-level learnings remain in
> `SESSION_RUNNER.md`.

*Migrated verbatim from `SESSION_RUNNER.md`’s Learnings table during the
2026-05-31 methodology update (Session 10) so the synced runner stays
byte-identical to canonical. These are nprcgenekeepr-specific
institutional memory from Sessions 1–27 (the PED/GV audit-fix campaign,
then the Shiny-module conversion). The base, methodology-level learnings
remain in `SESSION_RUNNER.md`. **Format note (Session 28):** the
recurring cross-cutting reflexes were extracted into the glossary below
and are cited from each Learning by `[tag]`; each Learning now carries
only its UNIQUE finding / <file:line> / mechanism / verdict. No
information was dropped — Session 28 was an information-preserving trim
(the prior single-cell table was ~90% of this file, reloaded every
session) verified by an adversarial per-Learning no-loss audit.*

#### Recurring Reflexes (glossary)

*These patterns recur across the Learnings. The canonical statement
lives here, stated once; each Learning cites the reflexes it used or
first discovered by `[tag]`. A `[tag]` with “(discovered \#N)” means
Learning N is where it entered the campaign.*

- **\[verify-first\]** (discovered \#5/#8a/#9a) — Empirically reproduce
  the ACTUAL failure mode, and confirm the prescribed fix actually fixes
  *that* failure, BEFORE writing the RED test. The audit’s stated
  mechanism AND its remedy can both be wrong: NEW-48 was a hard CRASH
  not “silent NA” (character vs logical/integer NA indexing differ —
  `m[NA_character_,]` errors, `m[NA_integer_,]` returns a silent NA
  row); NEW-25’s prescribed “terminal else” would NOT have fixed a crash
  that fires at the FIRST `if (NA)` (`NaN`/`NA` comparisons yield `NA`).
  Probe PAST a precursor warning to see the terminal behavior (a
  both-handlers `tryCatch(warning=,error=)` hides an error that follows
  a warning). Don’t theorize — verify empirically.
- **\[discriminating-RED\]** (discovered \#15a/#20) — A pre-existing
  test can silently PASS on buggy output (a both-names fixture;
  coincidental equality; a substring collision like `grepl("1000")`
  matching `max="10000"`). Design RED on an input where buggy ≠ correct;
  key on the SPECIFIC rendered token (`value="10"`, not a bare `10` that
  collides with min/max/step) and on the right LAYER (UI HTML vs an
  internal reactive vs the cleaned studbook — a server read may already
  work so a `testServer` input-effect passes at HEAD). Probe real data
  first for reachability and for which existing assertions move. A
  pre-existing test passing on SILENTLY-corrupted output is itself a
  TELL the bug is real.
- **\[stop-vs-warning\]** (discovered \#6/#8b) — Choose by the CURRENT
  baseline, per-mechanism (can differ within one function):
  silent-success → `warning`/NA (preserve the success contract);
  already-crash → clear `stop` (preserve the crash-contract, improve
  only the message). An in-repo sibling that already enforces the
  invariant supplies the message precedent.
- **\[reachability\]** (discovered \#5/#6) — Verify reachability
  per-mechanism through the full `qcStudbook` pipeline before “fixing”;
  it is often MIXED (some triggers masked, some live) and can be
  DOUBLY-masked. Known maskers: `addUIds` (qcStudbook.R:180 — eliminates
  partial parentage), `addParents` (injects founder lines for missing
  parents), `convertSexCodes` (folds H→U / NA→U), `removeDuplicates`
  (qcStudbook.R:277), and `kinship`’s own unique-id `stop`.
  `checkParentAge` is NOT an integrity guard (drops NA-birth rows,
  checkParentAge.R:91). For an orphaned `@noRd`/`@export` symbol →
  exhaustive caller-trace (incl. `do.call`/`get`/`match.fun`/`eval` +
  commented-out consumers); for a side-effect bug → call-graph
  propagation (an internal caller can INSULATE the leak). A grep
  inventory can NARROW scope (proving siblings unreachable) or WIDEN it.
- **\[regression-read\]** (discovered \#2/#4) — Authoritative read =
  `as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))`
  under `pkgload::load_all(".")` (else the STALE installed namespace →
  phantom failures in files you never touched — see \[stale-namespace\])
  AND `NOT_CRAN=true` (the `skip_on_cran`/CI condition; a bare
  `test_dir` clean read is necessary but NOT sufficient —
  `devtools::test`/CI can ERROR). Sum `failed` AND `error`, and watch
  the `warning` column, not just `failed`/`error` (a green suite can
  ACQUIRE a warning from a change to a different file). The
  `test-app-*`/`test-e2e-*` files are baseline noise — `test_dir` SKIPS
  them (≈156–159),
  [`testthat::test_local()`](https://testthat.r-lib.org/reference/test_package.html)
  ERRORS them (≈154, all call the once-undefined `create_test_app`);
  isolate true offenders with `!grepl("test-app-|test-e2e-", file)`.
- **\[stale-namespace\]** (discovered \#15b/#16c) — A bare
  `Rscript -e 'test_dir(...)'` without `load_all` runs against the
  installed namespace, not the working tree → a flood of failures in
  untouched files (the TELL) and your own change can read inverted.
  Likewise a new cross-file helper’s `object_usage_linter` “no visible
  global function definition” is a stale-namespace transient. The
  `/tmp`-copy HEAD method (Learning \#7) is INVALID for
  `object_usage_linter` — linting outside the package dir loses BOTH
  `.lintr` and the namespace (HEAD-in-`/tmp` = 103 default-linter lints
  vs 21 in-package — not comparable). Authoritative: REINSTALL
  (`R CMD INSTALL`) + re-lint, or HEAD~1-vs-HEAD counts in-place.
- **\[lint-net-zero\]** (discovered \#7) — `.lintr` suppresses findings
  by HARDCODED line number; any edit that inserts/removes lines ABOVE a
  suppressed line shifts the exclusion and resurfaces a pre-existing,
  intentionally-suppressed lint → bump the exclusion’s line number, do
  NOT “fix” the resurfaced finding. Confirm it’s pre-existing by linting
  the HEAD copy first:
  `git show HEAD:path > /tmp/x.R; Rscript -e 'lintr::lint("/tmp/x.R")'`
  (but this `/tmp` method is invalid for `object_usage_linter` — see
  \[stale-namespace\]). `tests` is wholesale-excluded (`.lintr:35`) so
  test edits are lint-exempt by config. Prove net-zero by
  `git stash push -- <touched files only>` → lint HEAD in-place →
  `stash pop`, diffing by line CONTENT not range. Match net-zero, not
  the lint-tripping idiom: explicit-`L` integers,
  [`nzchar()`](https://rdrr.io/r/base/nchar.html) (not `x != ""`),
  [`toString()`](https://rdrr.io/r/base/toString.html) (not
  `paste(collapse=)`).
- **\[identical-proof\]** (discovered \#15c/#16b) — Prove any
  behavior-preserving refactor
  BYTE-[`identical()`](https://rdrr.io/r/base/identical.html) vs a
  pre-change reference captured firsthand, INCLUDING the full output of
  a seeded stochastic consumer (`set.seed(42)`
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md))
  so the deterministic path is verified inside a random function.
  Preserve the empty-input contract (`do.call(rbind, all-NULL)` → `NULL`
  → guard back to
  [`data.frame()`](https://rdrr.io/r/base/data.frame.html)). For a
  side-effect bug, snapshot the target with an IMMUTABLE `paste0(...)`
  string, NOT `before <- ped` (which shares the SEXP — `setDT`/`setattr`
  mutate it in place).
- **\[idiom-inventory\]** (discovered \#16a) — For a fix-all-instances
  refactor, inventory by the PREDICATE/idiom, NOT the concept’s NAME —
  variable naming hides sites (`grep founder`=10 sites; the broad
  `is.na(sire)&is.na(dam)` sweep caught 2 more). Filter false positives
  (roxygen examples, `xor`/OR partial-parentage, `hasBothParents`,
  unrelated `is.na` on births/sex). Applies equally to a
  reference-mutation inventory
  (`setDT`/`setDF`/`:=`/`set(`/`setattr`/`setkey`) and a `rownames(x)<-`
  inventory.
- **\[right-sized-orchestration\]** (discovered \#9-corollary/#16d) —
  Solo grep/probe when mechanism+reachability are deterministically
  settled (honest “trivial or already-verified” per ultracode’s “unless
  already verified” — say so rather than reflexively orchestrating; a
  heavier 3-lens workflow \[empirical ‖ static ‖ adversarial-critic\]
  would be ceremony). Run a read-only multi-agent discovery workflow for
  a broad current-state map or a MEDIUM-risk multi-feature slice; a
  comment/dead-code/parser-inert change needs none.
- **\[completeness-workflow\]** (discovered \#21c) — Follow a
  single-pass discovery fan-out with an adversarial COMPLETENESS-CRITIC
  pass that hunts specifically for omissions (it catches the parity gaps
  a synthesis drops — exactly the “executor reaches parity but misses a
  feature” failure the planning grep-inventory exists to prevent), and a
  multi-angle finder sweep for a fix-all refactor (re-derive the
  inventory by predicate / keyword / idiom / layer). Then VERIFY the
  critic’s findings firsthand — it CONFIRMS, it is not trusted.
- **\[macos-dupe-scan\]** (discovered \#26c) — Scan for `* 2.*` macOS
  duplicate files (`git status … '* 2.*'`) before `document()`/commit;
  the tell is a `man/` delta with NO roxygen change (roxygen merges both
  copies into the `.Rd`; the `% Please edit documentation in …` line
  names the culprit) — and `test_dir` (matches `^test.*\.R`) double-runs
  a duplicated test file (inflated pass count). Per SAFEGUARDS (didn’t
  create it) surface via `AskUserQuestion` and MOVE to `/tmp`
  (reversible), don’t delete; then revert the `.Rd` churn and
  re-`document()` → zero-delta.
- **\[document-zero-delta\]** (discovered \#22/#23) — After any
  roxygen-affecting edit run `document()` and confirm zero
  `man/`+`NAMESPACE` delta. `import(shiny)` (NAMESPACE:168)
  blanket-covers new shiny controls
  (`selectInput`/`textAreaInput`/`numericInput`…) → no `@importFrom`
  churn.
- **\[phase-3E-smoke\]** (discovered \#22d) — Any appServer wiring /
  runtime-behavior change → launch
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  and confirm it binds + HTTP 200 and the new controls render (grep the
  served HTML for the namespaced ids). Build/test-clean ≠ runtime-clean
  (FM \#24).
- **\[news-vs-changelog\]** (discovered \#22d/#27e) — Completed work →
  `CHANGELOG.md`; PRUNE `BACKLOG.md` to OPEN items at close-out (don’t
  let “✅ DONE” lines accrete — user-flagged 2026-06-04). `NEWS.md` =
  analytical-API release notes; add a bullet only for a real
  numeric/behavior change, and CHECK `NEWS.md` for in-file precedent
  first (NEWS.md:85 carries the parallel modular GVA iter 5000→1000
  bullet). Pure-display/parity slices → CHANGELOG only.
- **\[testServer-mechanics\]** (discovered \#22b/#26a/#27c) —
  `output$<renderUI>` returns a list with `$html` (assert
  `as.character(x$html)`); `output$<downloadHandler>` RUNS the content
  fn and returns the WRITTEN FILE PATH (content is unit-testable — read
  the file); a `req(NULL)` dead button surfaces as an error on access.
  Drive DYNAMIC namespaced inputs by LOCAL id
  (`session$setInputs(curGrp1=…)`; read `input[["curGrp"i]]` — never
  re-`ns()` the server read; `ns()` belongs only on the UI/renderUI
  side). [`set.seed()`](https://rdrr.io/r/base/Random.html) carries
  deterministically across the `eventReactive(input$formGroups)`
  boundary. `req()`/`isTruthy()` treats a zero-length LIST as TRUE → an
  auto-firing observer runs on degenerate inputs → guard on
  `length(x) >= 1L`, not `req(x)`. Internal `reactiveVal`s are DIRECTLY
  accessible in the `testServer` eval env
  (`storedResults()`/`storedErrorLst()`), not only via
  `session$getReturned()`. To mock a package fn called by BARE NAME
  nested inside `moduleServer`’s closure, use
  `testthat::local_mocked_bindings(fn = …, .package = "<pkg>")` — it
  patches the namespace binding GLOBALLY so the real caller resolves the
  mock even nested inside `observeEvent`→`moduleServer`;
  `mockery::stub(<standalone-fn>, …)` does NOT transfer to the module
  level (the module isn’t the stubbed fn). Mutation-prove the mock fires
  (unmocked, the real fn errors / the output never assigns) — discovered
  \#29.
- **\[author-decision\]** (discovered \#13a/#17a) — Surface a genuine
  scope/approach/domain fork as a pre-RED `AskUserQuestion` with
  evidence in hand. A literal “delegate to X” may be UNIMPLEMENTABLE
  (signature asymmetry); a “support vs reject the input” fork is settled
  by \[domain-spec-authority\]; a “more robust than the monolith” clamp
  is the author’s call.
- **\[refactor-only\]** (discovered \#18c/#20a) — Comment/dead-code
  cleanup, a green-on-arrival test correction, and inert-control removal
  have NO new behavior and NO new unit → declare REFACTOR-only and gate
  `PRE-RED→REFACTOR`; do NOT manufacture a synthetic RED (asserting a
  deliberately-wrong expectation just to force red is forbidden;
  skipping RED/GREEN here is HONEST, not the prohibited FM \#17
  erosion). Prove parser-/behavior-inert via
  [`identical()`](https://rdrr.io/r/base/identical.html). Delete a
  tautological test WITH the control it echoed; don’t “fix” it.
- **\[mutation-check\]** (discovered \#20b) — Prove a green-on-arrival
  test or a new guard DISCRIMINATES by disabling the guarded behavior
  IN-PLACE (`perl -i`/`Edit`, then `git checkout` to restore — NOT a
  worktree, see \[no-worktree-baseline\]) and confirming the NEW
  assertion FAILS; the OLD assertion passing the same mutant is the
  coverage proof. In tests use `is.nan`, not just `is.na` (`is.na(NaN)`
  is TRUE in R — `all(is.na(x))` passes on both NA and NaN; assert
  `expect_false(any(is.nan(x)))` to separate them).
- **\[domain-spec-authority\]** (discovered \#13/#14c) — Settle
  support-vs-reject and edge-input contracts from the project’s OWN
  documented spec, not general convention: `input_format.html:86-97`
  “Alphanumeric characters (no symbols)” (live in the app via
  modInput.R:152-153; named as authority by `_input.Rmd:39-40`). A
  documented-but-UNENFORCED rule means enforcing it is a real behavior
  change needing author sign-off; prefer the targeted rule (`.`-only)
  over the broad spec unless the author opts in.
- **\[no-worktree-baseline\]** (discovered \#3) — HEAD git worktrees
  won’t run here (the worktree lacks `renv/activate.R`, so its
  `.Rprofile` aborts and `load_all` fails). Establish a clean-HEAD
  baseline by in-place revert or a `git grep`-on-HEAD structural proof,
  then restore — instead of a worktree suite run.
- **\[ci-suite-parity\]** (discovered \#32) — A CI/config step that RUNS
  the test suite must replicate the LOCAL verify command’s gating env,
  not just the opt-in flag: set BOTH `NPRC_RUN_E2E` AND **`NOT_CRAN`**
  at job-level `env:` — on a non-interactive `Rscript` runner
  `skip_on_cran()` fires unless `NOT_CRAN` is set, so the whole tier
  SILENTLY SKIPS, and `test_dir(stop_on_failure=TRUE)` is BLIND to skips
  (skip ≠ failure) → the job goes green-on-nothing. Convert the
  silent-skip class into a loud failure:
  `res <- as.data.frame(test_dir(..., stop_on_failure=TRUE)); if (sum(res$passed)==0L) stop(...)`.
  For a browser-E2E R package also: INSTALL the package
  (`R CMD INSTALL .` — the AppDriver subprocess
  [`library()`](https://rdrr.io/r/base/library.html)s it +
  `system.file(package=)` resolves against it); disable the renv
  autoloader (`RENV_CONFIG_AUTOLOADER_ENABLED:'false'`) so
  deps+install+test land on the SITE lib the subprocess sees (the
  autoloader forces `.libPaths()[1]` to renv’s PRIVATE lib, invisible to
  the subprocess starting in the installed `shinytest/` dir with no
  project `.Rprofile`); assert
  [`chromote::find_chrome()`](https://rstudio.github.io/chromote/reference/find_chrome.html)
  resolves to a SINGLE EXISTING path (bare `nzchar(NULL)` passes
  vacuously). A CI step you can’t live-run is verified statically (YAML
  parse + adversarial review + validate the exact run-step R locally);
  flag the not-statically-verifiable bits (here the renv lib-path /
  subprocess interaction) as explicit live-run watch items — never treat
  static-clean as runtime-clean (FM \#24). Extends \[regression-read\]
  from READING a suite to AUTHORING the CI that runs it.
- **\[flake-aware-validation\]** (discovered \#34) — A SINGLE green run
  of a process-count-/timing-sensitive browser tier PROVES nothing about
  stability; “run once” is exactly what hides an intermittent flake.
  Broadening a `test_dir(filter=…)` to run MORE files in ONE process is
  the load that surfaces the §5(8c) AppDriver-process-count dragon — but
  only intermittently (~1 transient Chrome error in 5 local full-tier
  runs; the same file passes 8/8/8 in isolation; concurrent load —
  e.g. an adversarial review’s parallel agents — is itself a trigger).
  Validate N times (or let the review’s concurrency surface it), then
  REPRODUCE firsthand to characterize the RATE + TRIGGER
  (contention-sensitivity) rather than trusting the agent or panicking
  (\[completeness-workflow\]). Under `stop_on_failure=TRUE` even a
  low-rate flake reds the scheduled job, so bring a discovered flake to
  the owner as a scope `AskUserQuestion` (\[author-decision\]) —
  document + defer hardening (per-§5(8c) “run grouped” in fresh
  processes) to a follow-on that can be live-validated, vs harden now —
  rather than silently shipping a known-flaky CI; never ship CI
  hardening you can only validate on the unreachable live runner
  (FM-#24-adjacent).
- **\[deletion-namespace-fallout\]** (discovered \#35) — Deleting an R
  file also removes whatever its ROXYGEN tags uniquely contribute to
  NAMESPACE. `getMinParentAge.R` (an `@noRd`, 0-caller orphan) was the
  SOLE carrier of `#' @import shiny`, so deleting it dropped the
  package-wide `import(shiny)` from NAMESPACE (leaving only the partial
  `importFrom` list) and the modular UI died at runtime with
  `could not find function "h5"`. A reference/caller grep CANNOT catch
  this — it reasons about who CALLS the symbol, not what the file’s
  roxygen EMITS; neither the §10 inventory nor a multi-modal sweep
  flagged it (the regression run did). After ANY file deletion:
  re-`document()`, diff NAMESPACE, and run the full regression / UI
  smoke; relocate a still-needed sole `@import`/`@importFrom` to a
  retained file (e.g. `R/<pkg>-package.R`). Extends
  \[document-zero-delta\] to the deletion case.
- **\[production-in-disguise\]** (discovered \#36) — When decomposing a
  “test/quality/refactor” issue into a plan, classify each work item by
  whether it actually requires a PRODUCTION-code change;
  determinism/reproducibility hooks, perf, and new public surface
  usually DO, even inside an issue titled “strengthen tests.” Issue \#40
  (“strengthen E2E assertions”) read as test-only, but its determinism
  item needs a gated
  [`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)
  added to TWO EXPORTED server functions
  (`modGeneticValueServer`/`modBreedingGroupsServer` have ZERO
  `set.seed` — firsthand; the issue’s “set.seed in
  modBreedingGroupsServer” was imprecise, it must be ADDED). Isolate
  such an item into its OWN owner-gated, full RED→GREEN→REFACTOR +
  `check()` slice, distinct from the test-only run-and-observe +
  \[mutation-check\] conversion slices; one such item silently BREAKS a
  prior “test-only” scope boundary (8a–8d were R-code-free) — call it
  out explicitly in the plan’s impact/scope section.
- **\[hard-gate-spike\]** (discovered \#37) — When a plan designates a
  load-bearing assumption as a HARD-GATE spike to confirm in a live
  environment FIRST, treat the spike as a HYPOTHESIS TEST: it can
  FALSIFY the planned mechanism, not merely de-risk it. (8e-1: the
  §2.3/§4 `.tab-content > .tab-pane.active` +
  innerText-honors-visibility design was WRONG — the modules nest their
  OWN tabsetPanels so `.tab-content` is NON-UNIQUE \[5 containers = 1
  top-level navbar + 4 nested module sub-tabsets, active sub-panes
  “Input Format”/“Plot”/“Rankings”/“Groups”\]; `querySelector`
  first-match latches onto a nested pane after a nav, and a mid-fade
  nested element masked innerText visibility \[hidden Home read 1895
  chars\].) Run it BEFORE any dependent work; STOP on failure (do NOT
  write conversions on an unconfirmed mechanism). A BOUNDED read-only
  DIAGNOSTIC that finds the corrected mechanism in the same session IS
  the spike succeeding (confirm-OR-correct is its definition) — but a
  mechanism change DEVIATES from the approved plan, so bring it to the
  owner as a scope/approach `AskUserQuestion` (\[author-decision\]:
  apply-fix-and-complete vs checkpoint-and-stop), don’t silently
  redesign past the gate (SAFEGUARDS mode-switch / FM \#8). Fix pattern
  for a navbarPage with nested tabsets: scope to the only `.tab-content`
  NOT inside a `.tab-pane` (`!t.closest('.tab-pane')`) → its
  direct-child `.tab-pane.active` (structural; no dependence on the
  dynamic `data-tabsetid`; correctly scoped, innerText DOES honor
  visibility — hidden pane reads ““). Extends \[verify-first\] to a
  PLANNED MECHANISM (vs an audit’s bug mechanism).
- **\[output-dom-discriminator\]** (discovered \#47) — A Shiny
  `renderDT`/`render*` output read via
  `app$get_value(output="<ns>-<id>")` returns NULL **only while
  SUSPENDED** (its tab hidden, `suspendWhenHidden=TRUE`); the moment the
  tab is activated it UN-SUSPENDS to a non-NULL value (a `json`-class
  ATOMIC string for DT — `v$json` errors, coerce with `as.character`)
  **even when `req()` is unmet / no data loaded** (an empty
  `<div … visibility:hidden></div>` widget). So
  `is.null(get_value(output=…))` discriminates SUSPENSION, not DATA — it
  passes green-on-arrival the instant you `navigate_to_tab`, and is NOT
  a data-bearing check. For a genuine data assertion, match the
  RENDERED-DOM content via `get_html_safe(app, "#<ns>-<id>")`: the
  DataTables row-count info (`"of N entries"`), `<th>` column headers,
  or the length menu (`dataTables_length`). Refines plan §2.3’s “output
  tier” (the get_value-empty-when-hidden claim is only half-true). Every
  8e-6 DT target is subject to this (pedigree `pedigreeTable`, GVA
  `rankingsTable`, breeding `groupStats`/`groupKinTable`).
- **\[e2e-subprocess-lib\]** (discovered \#47) — The shinytest2
  `AppDriver` SUBPROCESS resolves the package from the **SYSTEM/site
  library** (`/Library/Frameworks/.../R-4.5/.../library`), NOT the renv
  cache, because the E2E spike/run sets
  `RENV_CONFIG_AUTOLOADER_ENABLED=false` and `inst/shinytest/app.R` does
  [`library(nprcgenekeepr)`](https://rmsharp.github.io/nprcgenekeepr/).
  So a LOCAL e2e spike or `test_file` exercises whatever was last
  `R CMD INSTALL`ed into the system lib — which can be badly STALE
  (S47’s was Jul-2025, ~3 months / dozens of commits behind). REINSTALL
  current source there BEFORE any local e2e spike/run if `R/` changed
  since:
  `RENV_CONFIG_AUTOLOADER_ENABLED=false R CMD INSTALL --no-multiarch --no-docs --library=<system-lib> .`
  (pure-R → seconds). The LOCAL corollary of \[ci-suite-parity\]’s
  “install + disable autoloader so install+test land on the SITE lib the
  subprocess sees”; the renv-cache install (`find.package` under
  renv-active) is a SEPARATE copy, irrelevant to the subprocess.

#### Learnings (per session)

#### Learning 1 — plan-mode output is a draft (FM \#19 discovery)

When a prompt contains a multi-phase plan with “implement,” the
deliverable is a PLAN document with evidence-based inventory, not Phase
1 code. The gap: Phase 1’s task mapping had no entry for plan-mode
handoffs, so the session defaulted to “implement.” Structural fix: new
mapping row + FM \#19. **Apply:** when a prompt contains a multi-phase
plan with “implement” — recognize it as a planning workstream.

#### Learning 2 — `test_local` errors vs failed (S3, NEW-15 regression verify)

[`testthat::test_local()`](https://testthat.r-lib.org/reference/test_package.html)
records test ERRORS in a separate `error` column, distinct from `failed`
(expectation failures). A tally summing only `failed` can read “0 fail”
while 100+ tests error. This repo has 154 pre-existing errors (every
`test-app-*`/`test-e2e-*` file calls the once-undefined
`create_test_app()`; they error, not skip, because
`shinytest2`+`chromote` are installed). **Reflexes:**
\[regression-read\]. **Apply:** whenever verifying “no regressions” —
count both columns; treat pre-existing erroring files as baseline;
isolate a change’s true delta by FILE SET, not a single counter.

#### Learning 3 — no HEAD worktree here (S3)

HEAD git worktrees won’t run: the worktree lacks `renv/activate.R`, so
its `.Rprofile` aborts and
[`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)
fails. For a pre-change baseline, revert the single file in place or use
a structural proof (`git grep` showing a symbol is undefined at HEAD)
instead of a worktree suite run. **Reflexes:** \[no-worktree-baseline\]
(canonical). **Apply:** when you need a clean-HEAD comparison — skip the
worktree; use in-place revert or a `git grep`-on-HEAD argument.

#### Learning 4 — runner-dependent e2e noise (S4, NEW-34 regression verify)

The `create_test_app` baseline noise behaves differently by runner:
[`testthat::test_local()`](https://testthat.r-lib.org/reference/test_package.html)
ERRORS on the `test-app-*`/`test-e2e-*` files (≈154 in `error`), but
`testthat::test_dir("tests/testthat")` SKIPS them (≈159 in `skipped`, 0
`error`). Neither is a regression. Cleanest compute-change regression
read: `as.data.frame(test_dir(..., reporter="silent"))` +
offender-isolation. **Reflexes:** \[regression-read\]. **Apply:** prefer
`test_dir` + offender-isolation for a 0/0/0 signal; don’t be alarmed by
skip↔︎error count shifts on the e2e files.

#### Learning 5 — prove reachability via the canonical pipeline (S4, NEW-34)

For an audit-flagged “latent” crash, prove reachability through the
project’s CANONICAL pipeline (`qcStudbook`), not only a hand-crafted
input — and account for transforms that re-establish the guarded
condition. NEW-34 needed an empty `pUnknown`; `removeAutoGenIds` re-NA-s
U-prefixed parents, so “resolve all NA parents” was insufficient — you
also had to avoid U-prefixed parent ids. A read-only fan-out workflow
(caller-trace ‖ empirical-repro ‖ masking-critic) settled
REACHABLE-vs-MASKED before any code changed. **Reflexes:**
\[verify-first\]\[reachability\]\[right-sized-orchestration\].
**Apply:** before “fixing” any latent/masked audit item — reproduce via
the real pipeline; have an adversarial agent argue MASKED; only then
write the RED test.

#### Learning 6 — reachability splits by MECHANISM (S5, NEW-40 `findGeneration`)

A “silent NA / silent degradation” item usually splits by mechanism, not
one yes/no. The dangling-parent path is MASKED by `addParents` in
`qcStudbook`, but the CYCLE path is REACHABLE through the full pipeline
because `checkParentAge` drops NA-birth rows (checkParentAge.R:91) and
so isn’t a cycle guard. Enumerate each trigger separately; fix at the
single CHOKE POINT (`if (anyNA(gen)) warning(...)`) so every mechanism
is covered at once; prefer `warning` over `stop` to keep the return
contract — all callers unaffected (provably non-spurious — a valid
acyclic self-contained pedigree always places every id). COROLLARY:
adding a [`warning()`](https://rdrr.io/r/base/warning.html) can trip an
EXISTING test that exercises the degenerate path — scan the suite’s
`warning` column (not just `failed`/`error`) and update such a test to
EXPECT the diagnostic, not suppress it. **Reflexes:**
\[reachability\]\[stop-vs-warning\]\[regression-read\]. **Apply:**
verify reachability per-mechanism, guard at the choke point with a
warning, scan the `warning` column.

#### Learning 7 — `.lintr` line-number shift trap (S6, NEW-37)

This repo’s `.lintr` suppresses findings by hardcoded line number
(`.lintr:17-34` excludes specific lines in ~19 files,
e.g. `"R/correctParentSex.R" = 70L`). Any edit that inserts/removes
lines ABOVE a suppressed line (a roxygen `@details`, an import,
comments) shifts it, so a pre-existing, intentionally-suppressed lint
resurfaces, reading as “a lint you introduced.” NEW-37: my `@details`
shifted `if (reportErrors)` L70→L75, resurfacing the
`unnecessary_nesting_linter` that `70L` had hidden. Fix = bump the
exclusion (70L→75L), NOT refactor the suppressed (out-of-scope
NEW-36/PED-6 dual-return) structure. Confirm the lint is pre-existing by
linting the HEAD copy
(`git show HEAD:path > /tmp/x.R; Rscript -e 'lintr::lint("/tmp/x.R")'`)
before assuming you caused it — don’t theorize, verify (cf. Learning
\#3). **Reflexes:** \[lint-net-zero\] (canonical). **Apply:** after
editing any file in `.lintr` exclusions, re-lint, verify against HEAD,
bump the exclusion’s line number.

#### Learning 8 — audit MECHANISM can be wrong; stop-vs-warning by current mode (S7, NEW-48 `calcFEFG`/`calcFE`/`calcFG`)

**(a)** The audit’s stated mechanism can be wrong — reproduce the ACTUAL
failure mode first. The audit called NEW-48 “silent NA corruption”;
empirical repro proved a hard CRASH (`subscript out of bounds`):
`m[NA_character_,]` ERRORS while `m[NA_integer_/NA_logical_,]` returns a
silent NA row, and `calcFEFG` coerces ids to character (`toCharacter`),
so a lone-NA parent is `NA_character_` (a 3-lens workflow — empirical ‖
static ‖ adversarial-critic — converged on CRASH-not-corruption).
**(b)** stop-vs-warning depends on the CURRENT failure mode (the INVERSE
of \#4/#6): NEW-48’s baseline is ALREADY a crash, so a clear
[`stop()`](https://rdrr.io/r/base/stop.html) is contract-PRESERVING (no
currently-succeeding input now fails — only the message improves), while
`warning`+degrade would be the behavior change. Reachability MIXED: M2
canonical `qcStudbook`→`reportGV` pipeline MASKED by `addUIds`
(qcStudbook.R:180); M1 direct exported call + M3
`trimPedigree(removeUninformative=TRUE, addBackParents=FALSE)` via
removeUninformativeFounders.R:52-53 REACHABLE. **Reflexes:**
\[verify-first\]\[stop-vs-warning\]\[reachability\]. **Apply:**
empirically reproduce the actual failure mode (character vs
logical/integer NA indexing differ); choose stop-vs-warning by the
current behavior.

#### Learning 9 — audit’s prescribed FIX can be wrong; orphaned code (S8, NEW-25 `getProportionLow`)

**(a)** The prescribed FIX can be as wrong as the mechanism (extends
\#8a). The audit framed it as “three-way if/else-if has no terminal
`else`,” implying “add a terminal else.” But `NaN > 0.5` is `NA`, and
`if (NA)` errors *“missing value where TRUE/FALSE needed”* at the FIRST
`if` — before any fall-through — so a terminal `else` would NOT have
fixed it (a ~1-min repro caught the non-fix). **(b)** Reachability isn’t
always a `qcStudbook`-masking question: `getProportionLow` is `@noRd`
and its ONLY consumer is the dead/commented
`makeGeneticDiversityDashboard` (NEW-20) — so “verify reachability”
meant an exhaustive caller-trace, the fix is robustness-hardening of an
orphaned retained helper, and the empty/edge-input contract is a pure
DOMAIN decision for the author. COROLLARY: when grep on a unique-named
symbol settles reachability, that IS “already verified” — do NOT spin up
the heavier 3-lens reachability workflow (empirical ‖ static ‖
adversarial-critic); it would be ceremony (honest reading of ultracode’s
“unless already verified”). **Reflexes:**
\[verify-first\]\[reachability\]\[author-decision\]\[right-sized-orchestration\].
**Apply:** reproduce AND confirm the prescribed remedy actually fixes
it; for zero-live-caller code, caller-trace + author-decide the edge
contract.

#### Learning 10 — disprove an unreachable mechanism; both-ways stop/warning (S9, NEW-52 `cumulateSimKinships`)

**(a)** An audit’s mechanism can be UNREACHABLE for the function’s VALUE
DOMAIN — and under strict TDD the response is to DISPROVE and NOT fix
it. M1 (`n=1` → `0/0=NaN`) reproduced, but M2 (“near-constant cells →
tiny-negative under the root → `sqrt` NaN”) does NOT —
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
returns dyadic rationals (sums of powers of ½), exact in IEEE-754, so
constant-across-sims cells cancel to exactly 0 (probe: 0 negative
numerators, 117 exactly-0, 0 NaN at n=10/100), and the unstable
expression is only reachable *through* `cumulateSimKinships`, so
non-dyadic data can’t reach it. No failing test can be written → no
code; a `pmax(num,0)` clamp would be speculative, untestable defensive
code. **(b)** stop-vs-warning can apply BOTH WAYS in ONE function: `n=1`
currently succeeds silently (returns valid mean/min/max + NaN sd) →
NA+warning preserves the success (the NEW-40 side); `n=0` already
crashes (uninitialized `minKinship`) → clear `stop` preserves the
crash-contract (the NEW-48 side) — same function, opposite baselines,
opposite remedies. COROLLARY: `is.na(NaN)` is TRUE — a RED test must
assert `expect_false(any(is.nan(x)))`, not `all(is.na(x))` (which passes
on both). Reachability grep-settled: `cumulateSimKinships` is
`@export`ed but a public orphan (zero live callers) → no workflow
(Learning \#9 corollary). **Reflexes:**
\[verify-first\]\[stop-vs-warning\]\[mutation-check\]\[reachability\].
**Apply:** reproduce each claimed mechanism; disprove + skip an
unreachable one; pick stop-vs-warning per-mechanism; use `is.nan` in
tests.

#### Learning 11 — updating the embedded methodology (S10)

The synced trio (`SESSION_RUNNER.md`, `SAFEGUARDS.md`,
`methodology_dashboard.py`) must stay BYTE-IDENTICAL to canonical
(`rmsharp/methodology` `starter-kit/`); `bin/sync`/`bin/status` REFUSE
to overwrite a `locally modified` file without `--force`. Project
customizations (Learnings, build-equivalent, task mappings, extra Phase
0 steps) live in THIS CLAUDE.md “Project-Specific Methodology
Adaptations” — never in the synced files. Procedure: clone canonical →
diff to separate real customization from staleness → extract
customizations into CLAUDE.md → `bin/sync . --source=local --force` →
confirm `bin/status` = `current`. Docs under `docs/methodology/` are
do-not-edit reference copies (refresh by overwrite). The dashboard
scores `CHANGELOG.md` (not `NEWS.md`) as the changelog; `NEWS.md`
remains CRAN-facing release notes. Last synced to `f32d780` (S10,
2026-05-31). **Apply:** whenever updating the methodology or editing a
synced file — relocate customizations to CLAUDE.md, keep synced files
canonical, re-run `bin/status` = `current`. Don’t answer
methodology-governed questions from general convention — consult the
project’s own source of truth (the synced files +
`methodology_dashboard.py`).

#### Learning 12 — side-effect-on-the-caller bug class (S11, NEW-53 `makeSimPed`/`getPotentialParents`/`createSimKinships`)

**(a)** A NEW bug class — “side-effect-on-the-caller” — where the audit
over-claims the HARM, not just the mechanism (extends the \#8a/#9a/#10a
“audit-claim-wrong” lineage). The audit said `makeSimPed` “overwrites
sire/dam” and `createSimKinships` “adds a population column in place”;
empirically BOTH false. The ONLY leak is a by-reference CLASS flip
`data.frame`→`data.table` (from `setDT`, which mutates attributes in
place); content is preserved because the post-`setDT` `ped$col[…]<-v`
triggers `$<-.data.table`’s shallow-copy-and-rebind (decoupling the
local `ped` before any column write). Realized harm = `[`-semantics
divergence in the CALLER’s later code (`df[1]`=column vs `dt[1]`=ROW;
`df[,"x"]`=vector vs `dt[,"x"]`=1-col table). **(b)** Reachability for a
side-effect bug is a CALL-GRAPH-propagation question, not a
`qcStudbook`-masker (NEW-37/40/48) nor a value-domain (NEW-52) question:
`cumulateSimKinships` copies via its line-52 `ped$population<-…` before
the sim loop, so it does NOT leak — exposure is direct calls to the
three `@export`ed fns. Fix: `setDT(ped)` →
`ped <- data.table::as.data.table(ped)` (copies for both inputs,
byte-identical output — probed; the minimal swap suffices because `$<-`
never leaks a *new* column to the caller either — no unconditional
`copy()` needed). Grep the FULL reference-mutation inventory
(`setDT`/`setDF`/`:=`/`set(`/`setattr`/`setkey`) — the handoff named 2
sites, the audit named makeSimPed+createSimKinships, the real cluster
was 3 (fix-all-instances, workstream Q4). RED-assert the caller’s object
UNCHANGED (`class(ped)` stays `"data.frame"`) with an immutable
snapshot. Mechanism+reachability deterministic-probe-and-grep-settled →
no workflow (3rd consecutive). **Reflexes:**
\[verify-first\]\[reachability\]\[idiom-inventory\]\[identical-proof\].
**Apply:** separate the real leak (often just a class/attr flip) from
claimed corruption; trace whether internal callers insulate it; fix with
`as.data.table`; RED-assert caller-unchanged.

#### Learning 13 — mechanism correct → DOMAIN-DEFINITION fork; new-errorLst is 4-touch (S13, NEW-45 `geneDrop` period-in-id)

**(a)** When the mechanism is CORRECT (the inverse of \#8a/#9a/#10a,
where the mechanism was wrong), the live decision often shifts to a
DOMAIN-DEFINITION question — does the domain permit the input AT ALL?
NEW-45’s mechanism was right (a `.` truncates the
`strsplit(rownames, ".")` id/parent rebuild). The fork “support periods
vs reject them” is settled by the project’s OWN spec
(`input_format.html:86-97` “Alphanumeric characters (no symbols)”, live
via modInput.R:152-153, cited by `_input.Rmd:39-40`) → PRECLUDED →
reject. Tool: a read-only multi-modal domain sweep (validation-code ‖
docs ‖ conventions ‖ example-data + an adversarial synthesizer that
steelmans both sides), verify load-bearing evidence firsthand (Learning
\#20). **(b)** Enforcement the user can’t SEE is incomplete (Phase 3E):
a new `errorLst` field is a 4-touch change —
[`getEmptyErrorLst()`](https://github.com/rmsharp/nprcgenekeepr/reference/getEmptyErrorLst.md) +
the
[`checkErrorLst()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkErrorLst.md)
count + BOTH hardcoded renderers (`processQcStudbookResult.R` for the
Shiny table, `summary.nprcgenekeeprErr.R` for the summary text — neither
has a generic loop) — and it trips structure-count tests
(`test_getFocalAnimalPed` field-count 9→10; Learning \#6 corollary). A
pre-existing test passing on SILENTLY-corrupted output is a tell the bug
is real (`test_modGeneticValue`’s `C.003` fixture). **(c)** Prefer the
TARGETED rule (`.`-only) over the broad documented spec unless the
author opts in (full alphanumeric would reject legitimate `-`/`_`). In
lint-dirty `processQcStudbookResult.R` (13 pre-existing lints, issue
\#30) use idiomatic [`toString()`](https://rdrr.io/r/base/toString.html)
to add 0 net lints. **Reflexes:**
\[verify-first\]\[domain-spec-authority\]\[author-decision\]\[completeness-workflow\]\[lint-net-zero\].
**Apply:** when the mechanism checks out — ask SUPPORT vs REJECT, settle
from the spec; trace a new error field through
`getEmptyErrorLst`/`checkErrorLst` + both renderers; enforce the
targeted rule.

#### Learning 14 — actual crash + crash SITE differ; doubly-masked; sibling precedent (S14, NEW-46 `geneDrop` duplicate ids)

**(a)** The audit’s “silent wrong values” was a hard CRASH again (3rd
after NEW-48/NEW-25) and the crash SITE differed: the audit said “parent
lookup by rowname (geneDrop.R:82-104),” but it crashes at
`rownames(ped) <- ids` (geneDrop.R:97) with base-R’s
`"duplicate 'row.names' are not allowed"` — BEFORE the lookup. R’s
`.rowNamesDF<-` REJECTS duplicate row.names (precursor warning then hard
error) — it does NOT silently mangle, so any `rownames(x)<-<non-unique>`
CRASHES. METHOD TRAP: a both-handlers `tryCatch` short-circuits on the
precursor warning and HIDES whether an error follows (probe v1 read
“warning”; probe v2 suppressing/letting-pass the warning revealed the
terminal hard error) — probe PAST it. **(b)** Reachability
DOUBLY-masked: the canonical `qcStudbook→reportGV→geneDrop` path is
masked by `removeDuplicates` (qcStudbook.R:277) AND by `kinship`’s
`stop` which `reportGV` calls (reportGV.R:81) BEFORE `geneDrop`
(reportGV.R:92). The `rownames<-` idiom inventory found a sibling at
reportGV.R:122 but kinship crashes first → scope PROVEN geneDrop-only,
reachable ONLY via a direct
[`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
call (the grep NARROWED scope; contrast Learning \#12, where the grep
WIDENED scope to 3 sites). **(c)** Baseline already-a-crash → an in-repo
SIBLING
([`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md),
[`removeDuplicates()`](https://github.com/rmsharp/nprcgenekeepr/reference/removeDuplicates.md))
supplies the contract + message; `geneDrop`’s new guard mirrors
`kinship`’s `"animal IDs must be unique"`; unambiguous domain → no sweep
(grep+probe-settled, 5th consecutive no-workflow). **Reflexes:**
\[verify-first\]\[reachability\]\[idiom-inventory\]\[stop-vs-warning\]\[domain-spec-authority\].
**Apply:** reproduce the terminal behavior past any precursor warning;
trace ALL upstream guards (reachability can be doubly-masked, grep can
NARROW); mirror a sibling’s `stop`.

#### Learning 15 — mechanism+fix both correct → the EXISTING test is the risk (S15, NEW-16 `summarizeKinshipValues`)

**(a)** When mechanism AND fix are both correct, the load-bearing risk
is a pre-existing test that silently PASSES on buggy output (the NEW-45
`C.003` “test passing on corrupted output” pattern). NEW-16:
`secondQuartile` used `fivenum()[1]` (min) instead of `[2]` (lower
hinge); the existing `test_summarizeKinshipValues.R:75` asserts
`secondQuartile[10]==0` and STILL passes after the fix (that row’s hinge
coincidentally equals its min). The discriminating RED uses an input
where buggy≠correct: `numbers=1:5` → `fivenum=1,2,3,4,5` so hinge
`2`≠min `1`. Probe real data first (5/153 rows change; confirm which
assertions move). **(b)** TOOLING TRAP: `test_dir()` as a bare
`Rscript -e` WITHOUT `load_all` runs against the stale installed
namespace → phantom failures in untouched files (NEW-16’s first run: 46
failed / 68 error across ~40 files I never touched, every prior fix
missing from the installed build) + your own change reads inverted; the
repo’s documented “Clean regression read” (CLAUDE.md “Build / Test /
Verify”) OMITS `load_all` (valid only in an already-loaded/in-sync
session). Always prepend `suppressMessages(pkgload::load_all("."))`
(corrected: 0/0/1977). **(c)** Prove a behavior-preserving refactor
(`rbind`-in-loop → preallocated list + single `do.call(rbind,…)`) with
[`identical()`](https://rdrr.io/r/base/identical.html) vs a captured
reference (seeded pipeline + synthetic input + the all-skipped edge);
preserve the empty-input contract
(`do.call(rbind, all-NULL)`→`NULL`→guard to
[`data.frame()`](https://rdrr.io/r/base/data.frame.html)).
Grep/probe-settled → no workflow (6th consecutive). **Reflexes:**
\[discriminating-RED\]\[stale-namespace\]\[regression-read\]\[identical-proof\].
**Apply:** assume a pre-existing test passes on the bug — RED on
buggy≠correct; always `load_all`; prove “no behavior change” with
[`identical()`](https://rdrr.io/r/base/identical.html).

#### Learning 16 — first pure refactor: extract `getFounders`/`isFounder` (S16, PED-1/NEW-17, S1 KIN-2)

De-dup the founder predicate `is.na(sire)&is.na(dam)` at 12 inline sites
across 9 files. **(a)** Inventory by IDIOM not name: `grep founder`=10;
the broad `is.na(sire/dam)` sweep caught 2 more
(`modSummaryStats.R:606`/616, named `males`/`females`). Separate the
true idiom (BOTH parents NA) from `xor`/OR partial-parentage,
exactly-one-parent `hasBothParents`, and unrelated `is.na` on
births/sex; the bare-vector site `findPedigreeNumber.R:35`
(`id[is.na(sire)&is.na(dam)]`, no `ped` object) doesn’t fit a
`getFounders(ped)` contract — leave as a documented exclusion. **(b)**
Behavior-preserving BY CONSTRUCTION (R’s 3-valued `&` is assoc/comm even
with NA, so `sex & isFounder(ped)` ≡ `sex & is.na(sire) & is.na(dam)`,
and `sum(isFounder(ped))` ≡ `sum(mask, na.rm=TRUE)` since
[`is.na()`](https://rdrr.io/r/base/NA.html) never returns NA) — but
prove [`identical()`](https://rdrr.io/r/base/identical.html) anyway
incl. a seeded
[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
(extends \[identical-proof\]). **(c)** New cross-file helper
`object_usage_linter` “no visible global function” = stale-namespace
transient; the Learning \#7 `/tmp` method is INVALID for it (loses
`.lintr`+namespace — HEAD-in-`/tmp` = 103 lints vs 21 in-package, not
comparable) → REINSTALL+re-lint and/or HEAD~1-vs-HEAD counts in-place
(both Shiny modules = 60/17 at each → my edits added 0). **(d)** A
fix-all refactor IS the canonical sweep shape — a 4-finder multi-angle
completeness-sweep workflow (re-deriving the inventory by predicate /
keyword / idiom / Shiny-layer) → 0 misses, 1 intentional exclusion.
**Reflexes:**
\[idiom-inventory\]\[identical-proof\]\[lint-net-zero\]\[stale-namespace\]\[completeness-workflow\].
**Apply:** any extract-helper / fix-all-instances refactor.

#### Learning 17 — “delegate to X” may be unimplementable; audit the un-relocated wiring (S17, NEW-13/NEW-23)

Extract the founder-contribution algorithm shared verbatim by
`calcFE`/`calcFG`/`calcFEFG` into one `@noRd`
`calcFounderContributions()`; collapse the triplicated S7
partial-parentage guard. **(a)** A “delegate to X” framing
(BACKLOG/audit said “calcFE/calcFG delegate to calcFEFG”) can be
literally UNIMPLEMENTABLE — check signature asymmetry: `calcFE(ped)`
takes no `alleles` and is deliberately gene-drop-free, while `calcFEFG`
needs `alleles` for FG; literal delegation would force calcFE to compute
an FG it can’t feed. The shared-helper realization is a SUPERSET of the
audit’s intent (guard collapsed) that keeps calcFE gene-drop-free;
surface the fork (shared-`@noRd`-helper vs make-`alleles`-optional) as a
pre-RED `AskUserQuestion`. **(b)** The hidden divergence risk is in the
WIRING you DON’T relocate: calcFG/calcFEFG reassign
`ped <- toCharacter(ped)` BEFORE `calcRetention`; moving `toCharacter`
into the helper would feed the ORIGINAL (possibly factor) ped — a silent
divergence on factor input (which the tests exercise). Verify the
downstream’s sensitivity (`calcRetention` is `%in%`-coercion-robust to
factors) but don’t RELY on it — make equivalence hold BY CONSTRUCTION:
the helper returns `list(p, ped)` so the wrapper feeds `calcRetention`
the same coerced ped. **(c)** TDD RED for a pure refactor = test the NEW
unit’s existence (the PED-1 pattern — the cross-function
characterization already PASSES); preserve each function’s exact error
message through the single guard by parameterizing a `caller` arg (one
guard, byte-identical messages — strictly more conservative than the
generic message the existing `regexp="partial parentage"` tests would
have tolerated). Note `.caller` would trip `object_name_linter`
(`.lintr` styles = snake/Camel/camel; cf. `kinship.R`’s `# nolint` for
`father.id`) → use `caller`. **(d)** Deterministic
[`identical()`](https://rdrr.io/r/base/identical.html) IS the gold
standard (FE/FG char AND factor, the full `set.seed(42)`
[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
object \[the live calcFEFG caller\], all 3 guard messages); THEN a
3-agent adversarial-equivalence workflow (static body-diff vs the GREEN
commit via `git show`, 20 empirical OLD-vs-NEW edge tests transcribing
the originals, contract/guard/namespace) independently returned 0
divergences — it CONFIRMS, doesn’t discover. Lint net-zero (the
new-helper `object_usage` finding is the Learning \#16c stale-namespace
transient — vanishes under `load_all`/reinstall). **Reflexes:**
\[author-decision\]\[identical-proof\]\[completeness-workflow\]\[lint-net-zero\].
**Apply:** any “delegate/consolidate” refactor — check signature
asymmetry; audit un-relocated wiring; RED the new unit’s existence;
parameterize one guard by `caller`.

#### Learning 18 — motivation dissolved by a prior session; verify each “dead” var (S18, NEW-22/NEW-30)

Annotate the Mendelian ½ factor; remove the dead `UID.founders` block in
`calcFounderContributions.R` + add Mendelian-½ comments in `kinship.R`.
**(a)** An audit item’s MOTIVATION can be made moot by earlier work (a
new branch of \#8a/#9a/#10a: not the mechanism wrong, the *reason gone*)
— DECLINE the mechanical fix rather than perform it. NEW-22 flagged the
½ as DUPLICATION “hardcoded in 5 places,” but S17’s NEW-13/NEW-23
already collapsed the 3 `calc*` copies into one helper; the remaining
`/2L` sites are 4–5 DISTINCT formulas (parental-contribution avg,
parental-kinship avg, self-kinship `(1+f)/2`, founder self-kinship init)
split across the GV compute and the kinship engine — NOT one shared
knob. A named constant would FALSELY imply they are the same value and
over-couple two independent modules; `/2` is self-documenting in
genetics. The disciplined output was a documented author DECLINE
(comment-only), surfaced as a pre-RED `AskUserQuestion`, not a reflexive
extraction. **(b)** Verify each “dead” var: `founderMatrix <- NULL` is
NOT dead — `founderMatrix` is USED one line up
(`d <- rbind(founderMatrix, d)`), and the `<- NULL` is an intentional
memory free (drops the founders×founders identity block before the long
generation loop); only the `## UID.founders` commented block was
genuinely dead. **(c)** A comment-only + dead-code-removal cleanup is
REFACTOR by nature (no RED/GREEN — skipping them is HONEST, NOT the
prohibited FM \#17 erosion); don’t fake a synthetic RED; prove
parser-inert via [`identical()`](https://rdrr.io/r/base/identical.html)
on the seeded
[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md).
**(d)** A parser-inert change is BOTH “trivial” AND “already-verified” →
no workflow. COROLLARY: confirm FIRST that neither edited file is
`.lintr` line-excluded (the \#7 shift-trap bites only excluded files —
here neither was), and phrase prose comments WITHOUT code-like tokens
(no `fn(args)`/bare `(1+f)/2`) so `commented_code_linter` doesn’t flag
them. **Reflexes:**
\[refactor-only\]\[identical-proof\]\[right-sized-orchestration\]\[lint-net-zero\]\[author-decision\].
**Apply:** when an audit item is “now trivial” because a prior session
changed the code — re-derive whether its motivation still holds; verify
each “dead” var; treat as REFACTOR-only.

#### Learning 19 — test-infra debt; investigate completeness before “gate vs finish” (S19, `create_test_app`)

Define the missing `create_test_app()` so the 23
`test-app-*`/`test-e2e-*` files’ 154 errors become opt-in skips. **(a)**
A “test debt” binary (“define the helper OR gate the tests”) can hide
that the effort is ~90% complete and entangled with a bigger item —
investigate COMPLETENESS first. The app was already INSTRUMENTED for e2e
(`appUI.R` injects `data-ready.js`; all 6 `mod*` set `data-ready` on a
namespaced container), `inst/shinytest/app.R` existed, 159 `test_that` +
a `shinytest2.yaml` CI workflow were in place — only the one-line entry
helper was missing; the tests are entangled with XARCH-1 (two coexisting
apps, the highest-risk audit item, sequenced LAST). Right deliverable =
“gate clean (opt-in) + file a tracked issue,” NOT “implement+validate
159 browser tests”; surface this fork as a pre-RED author
`AskUserQuestion`. **(b)** `skip_on_cran()` keys on `NOT_CRAN`, so a
suite can look CLEAN under bare `test_dir` yet ERROR under
`devtools::test`/CI — the CAUSE behind \#2/#4’s symptom; verify under
`NOT_CRAN=true` (a 0/0 under bare `test_dir` is necessary but NOT
sufficient). **(c)** TDD the gate helper browser-free (home =
`helper-shinytest2.R`, auto-sourced) — RED→GREEN is real (function
missing → “could not find function”): skip unless
`Sys.getenv("NPRC_RUN_E2E")=="true"`, else return
`system.file("shinytest", …)` (assert it’s a dir with `app.R`); assert
the gate by catching the `skip` condition
(`tryCatch(…, condition=function(c)c)` → `expect_s3_class(cnd,"skip")`,
probe-confirmed class `c("skip","condition")`); scope env vars with base
`Sys.setenv`/`Sys.unsetenv`+`on.exit` (NOT `withr` — undeclared dep);
keep GREEN minimal (OMIT a speculative “app.R missing” guard — untested
code is out of scope). **(d)** Preserve the deferred plan as a GitHub
ISSUE (#39, not just a BACKLOG line) capturing existing assets + the
remaining campaign + the XARCH-1 dependency, so it can’t be lost again;
deterministic probe (git `-S` to prove never-defined; `system.file`
resolution; skip-class probe) → no workflow. **Reflexes:**
\[author-decision\]\[regression-read\]\[right-sized-orchestration\].
**Apply:** for test-infra debt — investigate how complete the existing
effort is and whether it’s entangled before “gate vs finish”; reproduce
under `NOT_CRAN=true`; TDD an opt-in gate browser-free; capture deferred
work as an issue.

#### Learning 20 — green-on-arrival test fix is REFACTOR-only; mutation-check (S20, vacuous test)

`test_getPotentialParents.R` test “works with records with no potential
parent” recomputed a local `ped` but asserted the old top-level
`potentialParents[[1L]]$id` — a copy/paste tautology (flagged S4) that
verified nothing about its named scenario. **(a)** Fixing a
green-on-arrival vacuous test is REFACTOR-only: production is already
correct (`getPotentialParents` correctly DROPS the no-breeding-age
candidate), so a correct assertion passes immediately — declaring RED
would violate “RED must fail,” and a deliberately-wrong expectation is a
synthetic RED. Gate `PRE-RED→REFACTOR`; surface the classification as
the author’s pre-RED `AskUserQuestion` (it is genuinely ambiguous —
strengthening a test changes what it verifies, yet the suite’s pass/fail
and all production behavior are unchanged → REFACTOR in the system
sense). **(b)** The substitute for RED-rigor is a MUTATION CHECK:
disable the `if (nrow(ba)==0L) next` skip in-place (Learning \#3 —
`perl -i` then `git checkout`) → BRI2MW reappears → the new
`expect_false(… %in% …)` + `length==N-1` FAIL; the OLD vacuous assertion
would have PASSED that same mutant (because it read only global fixture
state) — the coverage proof. A green-on-arrival test with no mutation
check is indistinguishable from another tautology. **(c)** Verify-first
applies to TEST defects — reproduce the scenario’s ACTUAL output (BRI2MW
dropped; 50→49) before writing the corrected assertion; never assert
from the test’s NAME or the handoff’s description. **(d)** `.lintr`
excludes `tests` wholesale (`.lintr:35`) → test edits lint-exempt by
config (the Learning \#16c `/tmp`-lint is doubly-invalid — loses both
`.lintr` and namespace); deterministic, mutation-verified → no workflow
(cf. Learnings \#9/#18d/#19d). **Reflexes:**
\[refactor-only\]\[mutation-check\]\[verify-first\]\[no-worktree-baseline\]\[lint-net-zero\].
**Apply:** for a vacuous/tautological test — reproduce real output; if
production is correct classify REFACTOR-only; mutation-check the new
assertion discriminates.

#### Learning 21 — first PLANNING deliverable; the audit was STALE (S21, XARCH-1 / issue \#27)

Plan completing the monolith→modular Shiny conversion →
`docs/planning/shiny-module-conversion-plan.md`. **(a)** A planning
session is NOT strict-TDD — declare RED/GREEN/REFACTOR INAPPLICABLE and
follow the SESSION_RUNNER Planning protocol (a planning session’s
discipline is the architecture workstream + the planning checklist:
plan-is-the-deliverable, FM \#18/#19; MANDATORY grep-based inventory;
per-phase done-criteria; vertical slices, FM \#25; the CLAUDE.md TDD
override governs only *implementation* sessions, so a planning session
has no code-phases). Do NOT implement (even “plan completing X” is
planning). **(b)** verify-first is even MORE load-bearing for a plan (an
executor TRUSTS every claim) — and the project’s own
`TECH_DEBT_AUDIT_2026-05-30.md` was STALE: claimed ui.r=1631 lines
(actually 53, sources 8 `uitp*.R`); a “stale lowercase server.r/ui.r
duplicate” (a macOS case-insensitive-FS artifact — git tracks one file);
“do XARCH-3/4/7 before XARCH-1” (MOOT: 3 done-but-orphan, 7 retired, 4
orthogonal). Code is REALITY; re-verify every <file:line> firsthand.
**(c)** For a broad map use a read-only discovery fan-out (single-pass
synthesis MISSES things) THEN an adversarial COMPLETENESS-CRITIC (it
caught 4 real parity gaps the synthesis dropped: a dead kinship-download
`req(NULL)`; absent MK/GU quartile tables; an FE/FG founder-table gap; a
100× breeding-`gpIter` 10→1000 drift — plus an offset-mapping trap;
exactly the “executor reaches parity but misses a feature” failure the
grep-inventory prevents) — then verify the critic too (it mis-stated one
NAMESPACE line; was right about a3manual). **(d)** Surface
scope/product/domain forks via `AskUserQuestion` AFTER discovery
(evidence in hand): scope (“how complete is ‘completing’?”:
parity+E2E+retire vs subsets); product inclusions (ORIP/Settings:
exclude → parity = match the monolith, the cleaner boundary); domain
defaults (the GU threshold: re-expose the monolith’s user control,
default 4). Structure as VERTICAL slices, risk-ordered, deletion
LAST/irreversible (its own commit, full preflight). **Reflexes:**
\[verify-first\]\[completeness-workflow\]\[author-decision\]. **Apply:**
for a PLAN/architecture doc — declare TDD inapplicable, write don’t
implement; re-verify audit claims firsthand;
discovery-then-completeness-critic; forks via `AskUserQuestion`;
vertical slices, deletion last.

#### Learning 22 — first conversion slice: trace the real column name (S22, Phase 1, `modSummaryStats`/`appServer`)

**(a)** The plan’s “trace the real column name FIRST” gotcha is
load-bearing (a textbook \#15/#20). `reportGV.R:89`
`zScores <- scale(indivMeanKin)` cbinds to a column literally named
`zScores` ([`scale()`](https://rdrr.io/r/base/scale.html) returns an
unnamed 1-col matrix → `cbind` names it from the deparsed symbol),
arriving UNRENAMED at `modSummaryStats` which checked `zScore`
(singular) → z-score plots ALWAYS NULL. The pre-existing
`test_modSummaryStats_ggplots.R` PASSED because its `makeTestGVData()`
injects BOTH names — the discriminating RED uses ONLY the real plural
name; fix = dual-name lookup preferring `zScores` (matching
`modGeneticValue`’s `indivMeanKin`/`meanKinship` fallback idiom).
**(b)** Verify the `testServer` surfacing before asserting:
`output$<renderUI>`→list `$html`; `output$<downloadHandler>` RUNS the
content fn → written FILE PATH (download content unit-testable); a
`req(NULL)` dead button surfaces as an access error. **(c)** Net-zero
lint can CONFLICT with idiom — passing an existing reactive through
directly (`mkSummary = mkSummaryData`) is lint-clean AND
behavior-identical; prove net-zero by a touched-files-only stash, diff
by CONTENT not line range. **(d)** A module’s RETURN list is safe to
extend when uncaptured (`appServer` calls `modSummaryStatsServer(...)`
with no assignment); an appServer WIRING change is a RUNTIME change →
Phase 3E mandatory. NEWS deferred to the Phase 9 canonical switch.
**Reflexes:**
\[discriminating-RED\]\[testServer-mechanics\]\[lint-net-zero\]\[phase-3E-smoke\]\[news-vs-changelog\].
**Apply:** a Shiny-module parity slice — confirm the real column/field
name before RED; probe `testServer` surfacing; prefer the lint-clean
form; runtime-smoke any wiring change.

#### Learning 23 — mount a built-but-unwired module; key RED on unique content (S23, Phase 2, `modGvAndBgDesc`)

Wire the `modGvAndBgDesc` description tab into `appUI`/`appServer` — the
first slice that MOUNTS a whole module. **(a)** The discriminating RED
must key on the new module’s UNIQUE rendered CONTENT, never a heading it
may SHARE. The plan’s hint (“assert the tab’s H3”) would assert
`"Genetic Value Analysis and Breeding Group Description"`, which also
lives in `genetic_value.html` that `modGeneticValue` already mounts via
`includeHTML` → PASSES at HEAD. The discriminating marker is the
module’s OWN body text (`gvAndBgDesc.html` has
`"kinship coefficients"`): grep-proven absent from every already-mounted
guidance file (`genetic_value.html`/`group_formation.html`) AND from
[`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
at HEAD. **(b)** A module’s UI fn may not call `NS(id)` — then there is
NO namespaced container and the included content is the ONLY mount
marker (`modGvAndBgDescUI` ignores `id`). READ the UI fn before
designing the assertion. **(c)** An informational module (returns NULL)
is verified STRUCTURALLY
(`grepl("modGvAndBgDescServer", deparse(appServer))`) + at RUNTIME
(Phase 3E). Tab placement parity comes from the monolith
(`inst/application/ui.r` lists `uitpGvAndBgDesc` LAST); far from the
dynamic-tab insert target → `test_appServer_dynamicTabs.R` unaffected.
**Reflexes:**
\[discriminating-RED\]\[phase-3E-smoke\]\[right-sized-orchestration\].
**Apply:** mounting a built-but-unwired module — RED on the module’s
UNIQUE included-content (grep-prove it’s absent everywhere mounted + at
HEAD); read the UI fn for `NS()`; verify NULL-modules structurally +
runtime; take placement from the monolith.

#### Learning 24 — threaded-parameter slice: RED an internal reactive (S24, Phase 3, `modGeneticValue`)

Genome-uniqueness threshold control + threading, subset/filter +
Export-Subset, iterations 5000→1000, remove the inert `minAge` slider
(first MEDIUM-risk multi-sub-feature slice). **(a)** A discriminating
RED for a threaded-parameter fix keys on an INTERNAL REACTIVE exposing
the threaded value, NOT the stochastic output. The modular app hardcoded
`guThresh=1L`; “default 4” means the threaded integer 4 (the monolith
maps label N→value N+1, `selected=4L`). No existing test pinned the
threshold → exposed
`guThreshold <- reactive(if is.null(input$threshold) 4L else as.integer(...))`
and RED-asserted `guThreshold()==4L` (deterministic; the value-based
alternative is FRAGILE — stochastic gene-drop, the module sets no seed,
and tiny pedigrees crash). **(b)** A flipped grepl UI-default assertion
can be NON-DISCRIMINATING via SUBSTRING: `grepl("1000", ui_html)` PASSES
at HEAD because `max="10000"` contains “1000” — re-key on `value="1000"`
(+ `expect_false(grepl('value="5000"'))`). **(c)** Removing an inert UI
control is REFACTOR (dead-code), not RED→GREEN — its tautological tests
(`setInputs(minAge=x); expect_equal(input$minAge,x)`) are DELETED with
it; 2 SIBLING inert controls (`calcGenomeUniqueness`/`calcMeanKinship`)
deferred. **(d)** A discovery + adversarial-completeness workflow IS
warranted for a MEDIUM slice, and it flagged 3 blockers I verified
firsthand: `%||%` not portable (use explicit `is.null`); `stri_trim` not
the imported symbol (`stri_trim_both` is — use base `trimws`);
`import(shiny)` (NAMESPACE:168) covers new controls (`document()`
zero-delta). Lint net-zero held BECAUSE removing the slider dropped 3
implicit-integer lints that offset the new `selectInput` (used explicit
`c(1L,…,5L)`/`4L` to add 0). **Reflexes:**
\[discriminating-RED\]\[refactor-only\]\[completeness-workflow\]\[lint-net-zero\]\[document-zero-delta\].
**Apply:** a “threaded-parameter + new-controls” slice — RED the
threaded value via an internal reactive; key UI-default on `value="…"`;
treat inert-control removal as REFACTOR; run a workflow then verify its
blockers.

#### Learning 25 — “both modes” can narrow to one; trace the real consumer (S25, Phase 4, `modInput` genotype merge)

Wire `getGenotypes`/`checkGenotypeFile`/`addGenotype` so an uploaded
`input$genotypeFile` is read + merged; populate the always-NULL
`genotypeData()`. **(a)** The recon’s biggest payoff was NARROWING
scope. The plan said “make `separatePedGenoFile` AND `commonPedGenoFile`
merge,” but ONLY `addGenotype` integer-codes alleles into the numeric
`first`/`second` that `reportGV` requires
(`fixGenotypeCols`/`fixColumnNames` only RENAME
`firstname`→`first_name`), and the monolith never calls `addGenotype`
for `commonPedGenoFile` → a combined ped+geno file’s string
`first_name`/`second_name` never reach gene-drop in EITHER app →
common-mode is at parity by NO-OP; adding it there would be behavior
BEYOND parity. Prove empirically (combined-file → `runQcStudbook` →
`hasGenotype`=FALSE). **(b)** The load-bearing outcome rides on a
DIFFERENT artifact than the task names: `genotypeData()` has ZERO
downstream consumers; the GV-uses-genotypes outcome rides 100% on the
cleaned studbook carrying numeric `first`/`second` (merge BEFORE
`qcStudbook`, qcStudbook.R:281-283). So the discriminating RED keys on
`cleanedStudbook`, NOT `genotypeData()` (populating it was an author
opt-in via `getGVGenotype(cleaned)` — NULL when no genotype, return
stays 9 elements → no structural-test churn). **(c)** The conversion
target should be MORE robust than the monolith: `addGenotype(ped, NULL)`
CRASHES and `checkGenotypeFile` returns NULL on a bad file, so the
monolith (server.r:145, unguarded) crashes — the modular merge is
NULL-guarded; do NOT replicate or touch the monolith (Phase 9 deletes
it). **(d)** A non-happy-path test green-at-HEAD (feature absent =
nothing to crash) is valid coverage — mutation-verify the guard (drop it
→ the edge test ERRORS). Fixtures = the shipped
`obfuscated_rhesus_mhc_ped.csv` (375 rows) + `…_breeder_genotypes.csv`
(31 rows) via
`testServer setInputs(<fileInput>=list(datapath=<real file>))`.
**Reflexes:**
\[discriminating-RED\]\[verify-first\]\[mutation-check\]\[completeness-workflow\].
**Apply:** a “wire functions to merge an uploaded file” slice — prove
whether each mode reaches the consumer (can narrow to one); trace the
REAL load-bearing artifact; make the target more robust than the
monolith; cover green-at-HEAD non-happy paths + mutation-verify.

#### Learning 26 — thread the kinship matrix dragon; empty-list observer guard (S26, Phase 5, `modBreedingGroups`)

A new “Group Detail” tab: `viewGrp` selector + per-group member view +
per-group kinship matrix view + `downloadGroup`/`downloadGroupKin`.
**(a)** Discharge a “thread the matrix” DRAGON by proving the threaded
value is byte-[`identical()`](https://rdrr.io/r/base/identical.html) to
the formation’s own output at the SOURCE. `result$groupKin` is NULL
(`withKin` defaults FALSE — no `withKinship` UI control until Phase 6),
so compute `filterKinMatrix(groupIds, kmat)` from the module’s
already-computed full `kmat` (store it in the `groupResults`
reactiveVal). Proved two equivalences firsthand: `withKin` affects only
the RETURN not FORMATION (groupAddAssign.R:191→`groupMembersReturn`, so
storing `kmat` can’t perturb `groups()`);
`filterKinMatrix(group, FULL_kmat)` == the monolith’s reduced-kmat
result because each group ⊆ candidates and `filterKinMatrix` selects
rows/cols by NAME (groupAddAssign.R:134 reduction is a no-op for the
subset). Discharged “formation unchanged” with a seeded HEAD reference
(`groups`/`score`/`unassigned`/`nGroups` all
[`identical()`](https://rdrr.io/r/base/identical.html) across 3 seeds;
`set.seed` deterministic across the `testServer`
`eventReactive(input$formGroups)` boundary), and made the
`filterKinMatrix`-equivalence a committed RED assertion (download CSV ==
`filterKinMatrix` on a recomputed full kmat). **(b)**
`req()`/`isTruthy()` treats a zero-length LIST as TRUE → an auto-firing
`observe` runs on degenerate inputs, here
`updateSelectInput(choices=setNames(integer(0),character(0)), selected=1L)`
on the harem-no-eligible-sires case → a base-R WARNING
`'names' attribute [1] must be the same length as the vector [0]`
surfaced on a PRE-EXISTING test (`"handles harem sex ratio"`). Guard on
`length(x)>=1L`, NOT `req(x)`; diff the `warning` column under a
touched-file stash (HEAD 0 vs mine 1 localized it). **(c)** A
mid-session macOS `* 2.*` DUPLICATE (`R/modBreedingGroups 2.R`,
`tests/testthat/test_modBreedingGroups 2.R`; cause unknown) corrupted
`document()` (doubled `.Rd`) and `test_dir` (matches `^test.*\.R`)
double-ran the test (inflated pass count) — scan before
documenting/committing; MOVE to `/tmp`, revert the `.Rd` churn,
re-`document()` → zero-delta. **(d)** Clamp BOTH views to
`length(breedingGroups())` (ACTUAL count — more robust than the
monolith, where `bgGroupView` clamps `viewGrp` to `input$numGp`
REQUESTED and `bgGroupKinView` does NOT clamp at all, a latent
out-of-range bug); RED-test it (`viewGrp="99"` → last group). Track a
`hasUnused` flag computed from the RAW `result$group` last element to
label the selector’s “Unused” choice WITHOUT changing `groups()`
(modular `breedingGroups()` is length N when all candidates are assigned
— the appended unused group is empty, dropped by `filterValidGroups` —
or N+1 when some are unassigned, the unused group surviving as the last
element). The recon (5 agents, `wf_9f046794-b6a`) confirmed the parity
surface, self-corrected two over-scoped critic items, and caught nothing
wrong — its value was independent confirmation of the dragon proof
obligations. **Reflexes:**
\[identical-proof\]\[testServer-mechanics\]\[macos-dupe-scan\]\[author-decision\]\[document-zero-delta\].
**Apply:** a “thread the kinship/derived matrix into a display” slice —
prove the threaded value
byte-[`identical()`](https://rdrr.io/r/base/identical.html) at the
SOURCE + seeded HEAD reference for “formation unchanged”; guard
empty-list observers on `length>=1L`; scan `* 2.*`; clamp at the actual
group count.

#### Learning 27 — surface inert controls (UI-only gap); port the feature not the bug (S27, Phase 6, `modBreedingGroups`)

Seed-group “current groups” widget + expose the inert
`minAge`/`nIterations`/`withKinship` controls + breeding-sim iteration
default 1000→10. **(a)** “Surface an inert control” can be a UI-ONLY gap
— the server ALREADY reads the input (modBreedingGroups.R:201-203), so a
`testServer` input-effect RED PASSES at HEAD (`withKinship=TRUE` flips
`groupKinship()` non-NULL even at HEAD). VERIFY which LAYER the gap
lives in — the discriminating RED keys on
[`modBreedingGroupsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsUI.md)
HTML; the iter default needs a real change → RED on the rendered
`value="10"` (not bare `10`). **(b)** Port the FEATURE not the
monolith’s BUG: `getCurrentGroups` (server.r:1037-1050) is doubly buggy
(`seq_along` of a scalar → reads only `curGrp1`;
`vapply(…, character(0L))` → a 0×N matrix). Build
`lapply(seq_len(numGp), …)` and RED-test the SECOND seed group is
honored; build the list INSIDE the `formGroups` eventReactive off
`input$nGroups` so the `length>numGp` `stop` is structurally
unreachable. **(c)** `testServer` drives DYNAMIC namespaced inputs by
LOCAL id (`setInputs(curGrp1=…)`; read `input[["curGrp"i]]` — `ns()`
only on the UI side); probe HEAD across seeds and pick one that FAILS at
HEAD (seed 42 passed by chance; seed 7 fails — makeGroupMembers.R:34-40
seeds group i with `currentGroups[[i]]`). **(d)** A validate-and-block
guard: reproduce the WORST outcome first — a seed id absent from the
pedigree survives into `result$group` and CRASHES the Phase-5 member
view (`addSexAndAgeToGroup`→`getCurrentAge` on length-0 `birth`); choose
validate-and-block (more robust than the monolith’s partial
`validate(need())`; cf. #25c/#26d), mutation-verify (disable → phantom
survives → R6 fails). **(e)** NEWS-vs-CHANGELOG: don’t trust a handoff’s
blanket claim — NEWS.md:85 already carried the parallel modular GVA iter
bullet, so the breeding iter 1000→10 (a real numeric change) warrants a
NEWS bullet too. Net-zero lint: explicit-`L` on `numericInput`
value/min/max; [`nzchar()`](https://rdrr.io/r/base/nchar.html) not
`x != ""`. **Reflexes:**
\[discriminating-RED\]\[testServer-mechanics\]\[mutation-check\]\[news-vs-changelog\]\[completeness-workflow\]\[lint-net-zero\].
**Apply:** a “surface inert controls + port a dynamic-input widget”
slice — verify whether the gap is UI-only; port the intended contract
not the bug; drive dynamic inputs by LOCAL id + pick a seed that fails
at HEAD; validate-and-block + mutation-verify; check NEWS precedent.

#### Learning 28 — information-preserving doc trim via an adversarial no-loss audit (S28, this file)

Trimmed CLAUDE.md (the 27-row Learnings table was ~90% of an 84 KB file
reloaded every session) without loss of information — the campaign’s
first DOC-CONDENSATION deliverable (not code; declare TDD code-phases
INAPPLICABLE, like a planning session, Learning \#21a). **(a)** The
structural win is a **glossary**: the ~21 cross-cutting reflexes were
re-explained inline 3–10× each, so factoring them into one “Recurring
Reflexes” section (cited per-Learning by `[tag]`) is most of the saving
— NOT dropping per-row facts. **(b)** “Without loss of information” is a
HARD GATE needing a real check, not eyeballing: a **mechanical token
gate** (every `file.R:NN` ref + every `NEW-/PED-/XARCH-/#` ID + backtick
symbols in old must survive in new — `comm -23` the sorted sets) catches
dropped REFERENCES, but it CANNOT catch a dropped *mechanism/verdict*
that was reworded away. **(c)** For semantic no-loss, run a **per-row
adversarial completeness audit** (\[completeness-workflow\]): one critic
per Learning diffs original-vs-condensed AND the glossary (a fact moved
UP to the glossary is not lost), returns structured
`{fact, severity, present_in_new, suggested_restore}`. The first draft
over-compressed (30% smaller) and the audit caught genuine drops in
20/27 rows (exact error messages like `if (NA)` → *“missing value where
TRUE/FALSE needed”*; algebraic equivalences; named fixtures
`test_modGeneticValue`/`C.003`; the `git show HEAD:path` lint-verify
command); restoring the high+medium facts landed at **18%** smaller
(84→69 KB) — fact-dense rows don’t compress far, so calibrate
expectations there, not at 50%. **(d)** Right-size the verification
(\[right-sized-orchestration\]): a SECOND audit confirmed convergence
(11 rows clean, glossary faithful); a THIRD would be ceremony
(adversarial critics always surface *some* phrasing nitpick) — stop when
residual flags are pure emphasis and the mechanical gate is clean. Keep
everything before the Learnings section BYTE-IDENTICAL (head/tail
`diff -q`); verify tag integrity (every cited `[tag]` defined, no orphan
glossary entry). **Apply:** any information-preserving condensation of a
dense reference doc — extract a stated-once glossary, gate references
mechanically, audit semantics per-row adversarially (glossary counts as
a valid home), restore high/medium drops, stop at convergence.

#### Learning 29 — wire a function across the module boundary; mock the EHR seam through `moduleServer` (S29, Phase 7, focal-animal/LabKey in `modInput`)

Wired `getFocalAnimalPed`/`getLkDirectRelatives` so the modular “Focal
animals only; pedigree built from database” path builds the pedigree
from the ONPRC EHR (monolith server.r:86-113). **(a)** UI parity ALREADY
existed (modInput.R:70 radio / :111-116 `breederFile` / :244
`activeFile`) — the gap was PURELY server-side: the focal-ID file was
read AS A PEDIGREE by `readDataFile` (modInput.R:314) → a spurious
`missingColumns` error → the option was visibly present but BROKEN. So
the discriminating RED keys on the SERVER reactive
(`storedResults()$cleaned` non-NULL for success;
`storedErrorLst()$failedDatabaseConnection` non-empty for DB-failure),
NOT the UI (a UI grep for `breederFile`/`focalAnimals` PASSES at HEAD —
test_modInput.R:34/259 already green). **(b)** The owner-consult fork
(mock-wire vs live-integration vs descope) is settled by
\[author-decision\] WITH evidence in hand: a read-only recon proved the
path is fully unit-testable under mock, REFRAMING the choice — descope
removes a non-working affordance, mock-wire makes it work; owner chose
full parity. **(c)** MOCKING THROUGH `moduleServer`: `getFocalAnimalPed`
calls `getLkDirectRelatives` by bare name;
`testthat::local_mocked_bindings(getLkDirectRelatives = …, .package = "nprcgenekeepr")`
patches the package-ns binding GLOBALLY so the REAL `getFocalAnimalPed`
body runs and resolves the mock even nested inside the
`observeEvent`→`moduleServer` closure (verified firsthand: mocked output
= the stub; unmocked, the real fn `cannot open file` and the output
never assigns — the mutation proof).
`mockery::stub(getFocalAnimalPed, "getLkDirectRelatives", …)`
(test_getFocalAnimalPed.R’s idiom) does NOT transfer to module level
(`modInputServer` isn’t the stubbed fn). See \[testServer-mechanics\].
**(d)** PORT THE FEATURE NOT THE BUG (extends \#25c/#27b): the monolith
branches on `is.element("nprckeepErr", class(...))` — a TYPO; the real
class is `nprcgenekeeprErr` (`is.element("nprckeepErr",…)` = FALSE
firsthand), so the monolith’s DB-failure branch NEVER fired. The modular
wiring uses `inherits(built, "nprcgenekeeprErr")` + routes the errorLst
to `storedErrorLst()` → the ALREADY-WIRED appServer Error-tab observer
surfaces `failedDatabaseConnection` (`checkErrorLst` keys on it FIRST;
`summary.nprcgenekeeprErr` renders it) — no new renderer/appServer code;
drop the monolith’s dead bare-NULL branch (`getFocalAnimalPed` returns
only a df or an errorLst). **(e)** Verification LIMITED by environment
(no live EHR) — stated, NOT skipped (NOT FM \#24): the mock covers
everything on the module’s side of the ONPRC boundary; the live
`getLkDirectRelatives`→`getDemographics` call is owner-verifiable only.
Lint net-zero via explicit-`L` (`integer(0L)`/`character(0L)`) so the
copied empty-warnings-df shape adds 0 `implicit_integer` lints;
`document()` zero-delta (`getFocalAnimalPed` same-package — no import);
Phase-3E smoke = app binds + HTTP 200 + focal controls render.
**Reflexes:**
\[discriminating-RED\]\[author-decision\]\[testServer-mechanics\]\[verify-first\]\[completeness-workflow\]\[lint-net-zero\]\[phase-3E-smoke\]\[news-vs-changelog\]\[right-sized-orchestration\].
**Apply:** wiring an existing function across the module boundary — find
the real (server-side) gap, discriminating-RED on the reactive not the
UI; mock a nested package seam via `local_mocked_bindings(.package=)` +
mutation-prove it fires; port the intended contract not the monolith’s
typo; route errorLsts to the existing surfacing channel; state
environmental verification limits explicitly.

#### Learning 30 — second PLANNING deliverable; the PARENT PLAN was stale; inventory test helpers by CALL FORM (S30, Phase 8 sub-plan / issue \#39)

Planned Phase 8 of the conversion (enable the shinytest2 E2E harness) →
`docs/planning/phase8-e2e-harness-subplan.md`. Planning/architecture
session — TDD code-phases INAPPLICABLE (Learning \#21a); the plan is the
deliverable, no code written (FM \#18/#19). **(a)** A planning session’s
\[verify-first\] target is the PARENT PLAN’s own inventory, not just an
external audit (extends \#21b “the audit was STALE” → “the parent plan
was stale”). The conversion plan §9 Phase 8 (S21) claimed “**3** missing
helpers / **one** session”; a firsthand call-site census found **6
undefined helpers + 1 undefined constant `E2E_TIMEOUT`** and a
**4-session mini-campaign**. Re-derive the symbol inventory by grep —
never trust a prior plan’s count. **(b)** For a TEST-HELPER inventory,
key on the CALL FORM (arity + named args), NOT just symbol presence
(\[idiom-inventory\] applied to helpers): `navigate_to_tab` has **109
three-arg vs 27 two-arg** calls → MUST be
`navigate_to_tab(app, label, fallback=NULL)` (a 2-arg signature errors
“unused argument” on 109 sites); `create_app_driver` gets
`height`/`width` at 2 sites → MUST forward `...`; `E2E_TIMEOUT` at
error-states.R:232 is TOP-LEVEL (hard error) while
L46/boundary-conditions.R:44 are `tryCatch`-swallowed. A bare
symbol-existence grep (the parent’s method) misses all three. **(c)**
HIDDEN-DOM: a `navbarPage` renders ALL tabs’ static UI into the DOM at
boot (verified `as.character(appUI())` = 85,106 chars containing every
tab’s keywords), so the suite’s dominant `grepl(kw, "body")` pattern
PASSES TRIVIALLY on boot → “harness runs green” ≠ “validates behavior.”
The planning fork is therefore TWO deliverables: **make-executable**
(helpers + CI; issue \#39) vs **make-validate** (rewrite ~41
`expect_true(TRUE)` tautologies + a wrong-tab-nav bug:
summary-statistics-module navigates to “Genetic Value Analysis” in 7/8
tests yet passes). Surfaced both to the owner (\[author-decision\]);
owner scoped \#39 to executable-only, filed validate (“8e”) as a
separate issue. Do NOT over-sell “green.” **(d)** A “one session” parent
phase can be a multi-session MINI-CAMPAIGN once inventoried — the
planning output is the realistic risk-ordered session map (8a helpers
browser-free RED→GREEN / 8b boot-smoke + CI 🐉 first browser run / 8c 15
shallow files / 8d 5 interaction+menu files → close \#39), with all 159
tests assigned. DEFER inert work: the `input`→`dataInput` namespace
mismatch is real but the polling helpers are NEVER CALLED (verified) →
8e, not 8a; fixing it early is churn with no observable effect
(module-side signaling already uses `session$ns`, so the live app is
correct). **(e)** \[completeness-workflow\] for a plan (discovery
fan-out → adversarial completeness-critic): the census of all 23 files →
a critic that returned **16 findings (4 HIGH the single-pass synthesis
dropped** — the 3 extra helpers, the constant, the arity, the
`...`-forwarding) → re-verify EACH firsthand (greps/`sed`) — the critic
CONFIRMS, is not trusted (#21c). \[right-sized-orchestration\]: one
read-only workflow (7 agents), no third pass. **Reflexes:**
\[verify-first\]\[completeness-workflow\]\[author-decision\]\[idiom-inventory\]\[right-sized-orchestration\].
**Apply:** for a sub-plan of a parent-plan phase — re-derive the
inventory firsthand by grep (the parent plan’s symbol count is a
\[verify-first\] target, often stale); inventory test helpers by CALL
FORM (arity / named args), not just name; if the suite is a `navbarPage`
E2E, test the hidden-DOM hypothesis and split make-executable vs
make-validate as separate owner-scoped deliverables; size the phase
honestly as a mini-campaign; run discovery → completeness-critic →
re-verify-firsthand.

#### Learning 31 — first sub-phase EXECUTION; the approved plan’s §4 pseudo-code was a verify-first target (duplicate-arg splice); browser-free TDD via fake AppDriver stubs (S31, Phase 8a / issue \#39)

Implemented Phase 8a of the conversion: define the 6 shinytest2 E2E
driver helpers + `E2E_TIMEOUT` in `tests/testthat/helper-shinytest2.R`
(browser-free RED→GREEN, strict TDD RESUMED after the two planning
sessions \#21/#30). **(a)** An APPROVED plan’s §4 helper pseudo-code is
itself a \[verify-first\] target — implementing it VERBATIM ships a
latent bug (extends Learning \#30’s “the parent plan’s count is stale”
from PLANNING to EXECUTION). The §4
`create_app_driver(app_dir, name, ...)` body hardcodes
`height=800, width=1200` then splices `...`; the 2
`boundary-conditions.R` sites that pass `height=`/`width=` as NAMED args
make `AppDriver$new(... height=800 ... height=600 ...)` → R error
*“formal argument ‘height’ matched by multiple actual arguments”*
(verified by introspection:
`formals(shinytest2::AppDriver$public_methods$initialize)` has EXPLICIT
`height`/`width` — NOT absorbed by AppDriver’s own `...`). Fix = expose
them as named formals `(app_dir, name, height=800, width=1200, ...)` so
a caller’s named arg binds there; `...` still forwards other args
(e.g. `seed`). Surfaced the one-line deviation-from-§4 in the
PRE-RED→RED gate (\[author-decision\]); it FULFILLS the plan’s stated
intent (“height/width override the defaults”), not deviates from it.
**(b)** Audit a fix-all/wire-up helper’s signature by CALL FORM (arity +
named-vs-positional) BEFORE baking it in (\[idiom-inventory\] applied to
EXECUTION, the \#30 lesson): firsthand greps re-derived every call form
— `create_app_driver` 144 two-arg + 2 named-height/width;
`navigate_to_tab` 109 three-arg (POSITIONAL `fallback`) + 28 two-arg (no
named 3rd arg, no 4-arg); `get_html_safe` 153× `(app,"body")`;
`click_element_safe`/`navigate_to_menu_item`/`get_values_safe` 5/4/3
sites; return-value consumption (`success <-` ×129 for navigate_to_tab →
must return logical; `body <- ...; grepl(kw, body)` → must return “” not
error). **(c)** \[right-sized-orchestration\] HONESTY about a workflow
failure: launched a read-only 7-agent call-site-audit workflow to
confirm the signatures; it FAILED on a framework hiccup (one subagent
never emitted StructuredOutput after 2 nudges → the bare `agent()`
critic call threw, failing the run). Rather than re-run, did the
call-form audit firsthand by grep (deterministic, grep-settled) — and it
CAUGHT the (a) duplicate-arg bug. When a verification workflow dies on
framework mechanics and the underlying check is deterministic grep, do
it by hand — don’t fight the framework; the workflow’s INTENT (catch
signature bugs) was met by the manual fallback. **(d)** BROWSER-FREE TDD
of browser helpers via FAKE APPDRIVER STUBS: a plain
[`list()`](https://rdrr.io/r/base/list.html) of functions stands in for
the R6 AppDriver (`app$method(args)` resolves `$` on a list and calls
the element). Three stubs discriminate the contracts: *throwing* (every
method [`stop()`](https://rdrr.io/r/base/stop.html)s → proves the
`*_safe` helpers return
`""`/[`list()`](https://rdrr.io/r/base/list.html)/`FALSE` and
`navigate_to_tab`→FALSE), *recording-ok* (`set_inputs` stores into an
env → `get_value` reflects it → `navigate_to_tab` read-back TRUE),
*silent-no-op* (`get_value` never reflects the set tab →
`navigate_to_tab` FALSE — proves the read-back DISCRIMINATES a silent
failed navigation, sub-plan finding 15; \[discriminating-RED\]).
`create_app_driver`’s body inherently needs Chrome → covered by
existence+formals only in 8a (real construction is 8b); stated as a
browser-deferred limit, NOT FM \#24 (the helper is test infra, not app
runtime). **(e)** Phase 3E (runtime APP smoke) is N/A here — 8a changes
NO running-app behavior; the helpers live only in the test tree
(`helper-shinytest2.R`, auto-sourced by testthat), so the test SUITE is
the runtime + the verification (distinct from every prior modular slice
S22–S29, which changed appServer/app and needed a
[`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
smoke). `tests/` is `.lintr`-excluded (`.lintr:35` `"tests"`) →
lint-exempt (direct lint = “No lints found”); `document()` zero
`man/`+`NAMESPACE` delta (only `tests/` touched, no `R/` roxygen);
test-infra only → CHANGELOG only, no NEWS. The new file
`test_helper_shinytest2.R` (underscore → default suite, browser-free,
always-runs like `test_create_test_app.R`) added 14 `test_that` / 32
assertions; full non-e2e suite 0 failed/0 error, 2154 passed (+32).
**Reflexes:**
\[verify-first\]\[idiom-inventory\]\[discriminating-RED\]\[right-sized-orchestration\]\[regression-read\]\[refactor-only\]\[document-zero-delta\]\[lint-net-zero\]\[author-decision\].
**Apply:** for a sub-phase EXECUTION of an approved plan — treat the
plan’s helper pseudo-code as a \[verify-first\] target (re-audit every
call form by arity/named-vs-positional before baking the signature; a
verbatim splice of defaults + `...` duplicate-crashes on named
overrides); if a confirmation workflow dies on framework mechanics and
the check is deterministic grep, finish it by hand; TDD browser helpers
browser-free via fake-AppDriver
[`list()`](https://rdrr.io/r/base/list.html) stubs (throwing / recording
/ silent-no-op) to discriminate error + success + read-back contracts;
Phase 3E is N/A when the deliverable lives only in the test tree (say
so) — the suite is the runtime.

#### Learning 32 — first CONFIG-ONLY sub-phase (CI infra, no RED→GREEN); the silent-skip CI blocker the adversarial review caught (S32, Phase 8b / issue \#39)

Implemented Phase 8b of the conversion: the first-ever real browser run
of the modular app (3 boot-smoke files green opt-in) + the CI rewire of
`.github/workflows/shinytest2.yaml`. **(a)** An “implementation”
sub-phase can be **CONFIG-ONLY** — no new R unit, no RED→GREEN (extends
\#21a/#18c from PLANNING/REFACTOR to CI-INFRA). The 3 boot-smoke files
are pre-existing and use `create_test_app()`+`AppDriver$new` DIRECTLY /
`testServer` (no Phase-8a derived helpers), and sub-plan §11 says the
E2E files are *run/triaged, not rewritten* → the **verify-first browser
SPIKE is the runtime verification** and the only deliverable change is
the CI YAML. Declare TDD code-phases INAPPLICABLE (config-only) and gate
the CLASSIFICATION via `AskUserQuestion` with the spike evidence in hand
— do NOT manufacture a synthetic RED. The spike also settled the §8.1
nav spike: `app$click('a[data-value="Input"]')` clicks the live bslib
navbar (no self-skip — `app-navigation: ...` 3 dots, no `S`). **(b)**
The CI-authoring \[regression-read\] footgun (\[ci-suite-parity\],
discovered here): I set `NPRC_RUN_E2E` in the CI env but **DROPPED
`NOT_CRAN`** — on the non-interactive `Rscript {0}` runner
`testthat::on_cran()` (`if NOT_CRAN=='' then !interactive()`) is TRUE →
all 3 files’ `skip_on_cran()` fires → every test SILENTLY SKIPS →
`stop_on_failure` is blind to skips → the scheduled job goes GREEN
running nothing. My own glossary \[regression-read\] names this exact
footgun, and the sub-plan’s verify command carried `NOT_CRAN`, but its
§7 CI spec OMITTED it and I propagated the gap. **Reproduced firsthand**
(NOT_CRAN unset, non-interactive → `nb:4 skipped:4 failed:0`; my local
pass only held because I set `NOT_CRAN=true`). Fix = `NOT_CRAN:'true'`
at job env + a positive `if (sum(res$passed)==0L) stop()` guard so the
silent-skip class fails loud. **(c)** Non-obvious browser-E2E CI
requirements the parent §7 omitted: must **INSTALL the package**
(`R CMD INSTALL .` after `setup-r-dependencies` — `inst/shinytest/app.R`
does
[`library(nprcgenekeepr)`](https://rmsharp.github.io/nprcgenekeepr/),
`create_test_app()` uses `system.file("shinytest", package=)`; pure-R →
fast, no `src/`); the renv autoloader makes `R CMD INSTALL` target
renv’s PRIVATE lib which the AppDriver subprocess (starts in the
installed `shinytest/` dir, no project `.Rprofile`) can’t see →
`RENV_CONFIG_AUTOLOADER_ENABLED:'false'` to install to the SITE lib; the
`find_chrome()` assert must check a single EXISTING path (`nzchar(NULL)`
passes vacuously); `browser-actions/setup-chrome@v2` `chrome-path` →
`CHROMOTE_CHROME` via `$GITHUB_ENV`; chromote auto-adds `--no-sandbox`
when `CI` is set (no manual flag on ubuntu 24.04). **(d)** The
adversarial review EARNED ITS KEEP + I re-verified firsthand
(\[completeness-workflow\]/\[right-sized-orchestration\]: the workflow
CONFIRMS, I verify): a read-only 5-agent workflow (4 lenses \[gh-actions
‖ chromote-chrome ‖ r-pkg-install ‖ conformance\] + a
completeness-critic) caught the HIGH `NOT_CRAN` blocker (2 lenses), the
renv-lib-path omission (critic), and the `find_chrome` vacuity — I
reproduced the blocker firsthand and confirmed the critic’s 2 flagged
false-positives (R CMD INSTALL does NOT build vignettes; the
find_chrome-NULL path is unreachable since CHROMOTE_CHROME is set
first), rather than trusting the agents. Grounded the design in
researched current best practice (<setup-chrome@v2> latest = v2;
ubuntu-latest ships Chrome; chromote CI defaults) and validated the
EXACT run-step + Chrome-assert R locally. **(e)** Static-only CI
verification HONESTY (not FM \#24): the live GitHub run was DEFERRED
(owner chose static+adversarial; branch `add-methodology` not on remote
→ a live run creates a remote feature branch + outward CI). Verify
statically (YAML parse + adversarial review + the exact run-step R
validated locally green = 37/0/0/0) AND flag the ONE thing not
statically verifiable — the renv lib-path / AppDriver-subprocess
interaction — as the **\#1 live-run watch item**; don’t treat
static-clean as runtime-clean. No R/test code changed → `document()` N/A
(no roxygen), `tests/`+`.github` lint-exempt, full non-e2e suite 0
failed/0 error (5 pre-existing `modPyramid` warnings, unchanged S31
baseline); CI infra → CHANGELOG only, no NEWS. **Reflexes:**
\[verify-first\]\[ci-suite-parity\]\[regression-read\]\[completeness-workflow\]\[right-sized-orchestration\]\[author-decision\]\[refactor-only\]\[phase-3E-smoke\]\[news-vs-changelog\].
**Apply:** for a CONFIG/CI-infra sub-phase — run the verify-first spike
to settle whether there is any RED→GREEN (often none → declare
config-only, gate the classification via `AskUserQuestion`, no synthetic
RED); when authoring CI that RUNS the suite, replicate the local verify
env (`NOT_CRAN`+the opt-in var) and guard the silent-skip class
(`sum(passed)>0`); for browser-E2E CI also install the package + disable
the renv autoloader + assert `find_chrome()` resolves to an existing
path; verify the YAML statically +
adversarial-review-then-re-verify-firsthand, and flag the
not-statically-verifiable bits as explicit live-run watch items.

#### Learning 33 — second CONFIG/run-and-observe sub-phase; right-sizing the orchestration DOWN (no workflow w/o ultracode); validate the EXACT broadened CI filter (S33, Phase 8c / issue \#39)

Implemented Phase 8c of the conversion: run-and-observe the 15 shallow
per-module E2E files (103 tests) green opt-in + broaden the CI run-step
filter in `.github/workflows/shinytest2.yaml` to the 18 verified 8b+8c
files. **(a)** The \#32 config-only pattern REPEATS for 8c but THINNER:
not just the test files but ALSO the 8a helpers already exist, so the
verify-first spike is *pure run-and-observe* — no triage, nothing to
write. The per-module-group browser spike was 103/103 green (input 19 /
pedigree 19 / pyramid 12 / genetic-value 22 / summary 8 / breeding 23,
0/0/0) → classify config/run-and-observe via `AskUserQuestion` with the
spike evidence in hand (no synthetic RED — Learning \#18c/#32). The
deliverable’s only ARTIFACT is a one-line `filter` broaden (vs \#32’s
6-edit CI rewrite). **(b)** \[right-sized-orchestration\] cuts BOTH WAYS
— and the cut depends on the ultracode state AND the change surface.
Ultracode was **OFF** this session (no keyword, no budget directive, no
confirming system-reminder), so the standing “author a workflow by
default” did NOT apply; S31/S32 ran workflows because they were under
ultracode AND had a real verification surface, whereas a one-line filter
broaden validated end-to-end locally is honestly “already verified” → I
ran NO workflow and SAID SO. Declining a workflow is the same reflex as
running one (#32 ran a 5-agent review for a 6-edit rewrite; \#33
declined for a 1-line change) — the discipline is matching the
orchestration to the surface, not always-orchestrating. **(c)** A
broadened `test_dir(filter=…)` regex is itself a \[verify-first\]
target: the S32 handoff’s “broaden **toward `^(app|e2e)-`**” — taken
literally — would pull in the 5 UNVERIFIED Phase-8d files. Narrowed to a
positive 8b+8c include-list and PROVED firsthand it selects EXACTLY 18
files / excludes EXACTLY the 5 8d, by replicating testthat’s
stripped-name match in R
(`sub("[.][rR]$","",sub("^test[-_]?","",files))` then
`grepl(filt, stripped)`) — do NOT trust the regex by eye. Then re-ran
the EXACT run-step expression
(`res<-as.data.frame(test_dir(filter=…, stop_on_failure=TRUE))` + the
`sum(passed)==0` guard) in a SINGLE process → 18 files / passed=140 /
0/0/0, exit 0 — which simultaneously discharges the §5(8c)
**AppDriver-process-count dragon** (15+ files × drivers in one
`test_dir`; no flaky timeout / resource exhaustion). The single-process
run-step validation is the Phase-3E analog for a CI-config change (the
suite IS the runtime). **(d)** “GREEN” on a `navbarPage` hidden-DOM
suite (§2.3) means harness-EXECUTABLE, not behavior-VALIDATED —
confirmed firsthand by two masked defects that still pass: pyramid’s
`navigate_to_tab(app,"Age-Sex Pyramid","Pyramid")` 3rd arg is the
ignored `fallback` (it navigates the TOP-LEVEL tab; modPyramid’s
“Plot”/“Statistics” sub-tabs are never targeted, yet `grepl`-body
passes), and summary-statistics-module navigates to the WRONG tab
(“Genetic Value Analysis”) in 7/8 tests and still passes (§2.4). All 6
nav labels DO exactly match real navbar titles (appUI.R:24-204) so
navigation genuinely occurs (read-back TRUE) — but even a silent no-op
would pass via the whole-page body. These are 8e items, NOT 8c blockers
(don’t fix). **(e)** Live GitHub run DEFERRED again (branch not on
remote, same posture as S32) — broadening the filter does NOT change
S32’s \#1 live-run watch item (the renv-lib-path / AppDriver-subprocess
interaction is the SAME risk category whether CI runs 3 or 18 files). No
R/test code changed → `document()` N/A, `tests/`+`.github` lint-exempt,
no NEWS (CI infra → CHANGELOG only). \[macos-dupe-scan\]: the `* 2.*`
hits are all `.Rproj.user/` RStudio session state (gitignored), NOT the
source-tree `R/foo 2.R`/`test_foo 2.R` class —
`git status --porcelain '*2.*'` was empty, so the
`document()`/`test_dir` corruption risk is absent. **Reflexes:**
\[verify-first\]\[right-sized-orchestration\]\[author-decision\]\[regression-read\]\[phase-3E-smoke\]\[refactor-only\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** for a second/Nth config/run-and-observe sub-phase — run the
spike (pure run-and-observe when files+helpers already exist; classify
config-only via `AskUserQuestion`, no synthetic RED); RIGHT-SIZE the
orchestration to BOTH the change surface and the ultracode state
(decline a workflow for a one-line change validated end-to-end locally
and SAY SO — declining is the same reflex as running); treat a broadened
test-filter regex as a \[verify-first\] target — prove it selects
EXACTLY the intended files and excludes the rest (replicate testthat’s
stripped-name match in R), then re-run the EXACT run-step in ONE process
(discharges the process-count dragon); remember “green” on a navbarPage
hidden-DOM suite = harness-executable, not behavior-validated (the
masked wrong-tab / no-op navigations are 8e, not blockers).

#### Learning 34 — third CONFIG/run-and-observe sub-phase; the spike PREVENTED helper work; a single validation run MASKED a process-count flake the ultracode review caught; close \#39 + document (S34, Phase 8d / issue \#39)

Implemented Phase 8d of the conversion (the FINAL \#39 sub-phase): the 5
interaction/menu E2E files green opt-in + broaden the CI run-step filter
to the full `^(app|e2e)-` tier (23 files) + **close \#39** + file 8e
(#40). **(a)** The config/run-and-observe pattern repeats, but 8d had a
REAL spike (§8.2 navbarMenu) that could have meant helper work — and
\[verify-first\] PREVENTED it (a spike can SHRINK scope, not just
de-risk): `set_inputs(mainNavbar="Settings"/"About"/"Help")` →
`get_value(input="mainNavbar")` reads the child label back TRUE for all
3 (navbarMenu children are tab inputs just like top-level tabs), so the
provisional `navigate_to_menu_item` delegate-to-`navigate_to_tab` body
is already FINAL — no DOM dropdown-open+click, no RED→GREEN. Running the
spike BEFORE classifying turned the handoff’s “MEDIUM-HIGH 🐉, may need
a real helper” into config/run-and-observe; classify via
`AskUserQuestion` with the 53/53 evidence in hand (no synthetic RED).
The only code touch: finalize the docstring (body byte-`identical`) +
the CI filter. **(b)** \[flake-aware-validation\] — the headline lesson,
and a direct CORRECTION of Learning \#33’s claim that the single-process
run “discharges the AppDriver-process-count dragon”: at 18 files it
didn’t bite, but broadening to **23 in one process** SURFACED it. A
SINGLE green full-tier run (my 193/0/0/0) proved nothing about stability
— “broaden + **run once**” (the S33 handoff’s own phrasing) is exactly
what HIDES an intermittent flake. The ultracode 4-lens review caught it
(its run \#1 = 191/0/0/**1 error** in `workflow-integration.R`
“maintains state”; isolated 8/8/8) — and the review’s OWN 4 concurrent
agents pressuring Chrome is itself the trigger (contention-sensitivity).
\[completeness-workflow\]: the review CONFIRMS, I verify — REPRODUCED
firsthand (my 2 fresh dedicated runs BOTH clean → low-rate ~1/5,
contention-driven) rather than trusting the agent or panicking. **(c)**
A flake found mid-close is a SCOPE FORK, not a thing to paper over
(\[author-decision\]): under `stop_on_failure=TRUE` even a low-rate
flake reds the scheduled job, so I brought
NEW-information-not-at-the-original-gate to the owner as an
`AskUserQuestion` — close \#39 + document (chosen) vs harden-now
(per-§5(8c) “run grouped” fresh processes) vs keep-narrower. Hardening
that can ONLY be validated on the live GitHub runner (the flake is
environmental + the branch isn’t on remote) is DEFERRED to \#40, NOT
shipped unvalidated (shipping unvalidatable CI complexity is its own
FM-#24-adjacent risk). **(d)** \[right-sized-orchestration\] under
ultracode = run the review HERE — the EXACT inverse of \#33’s honest
decline: \#33 had ultracode OFF + a 1-line change → no workflow; \#34
had ultracode ON + a consequential DECISION surface (close a long-lived
tracking issue? is \#40 complete? is the diff minimal?) even though the
CODE surface was trivial (a comment + a 1-line filter). The panel earned
its keep: Lens-1/3 all-confirm (diff comment-only + minimal; \#40
captures every §2.4/§2.5/§6 item + the new navbarMenu false-positive);
Lens-4 caught a real **`.DS_Store` BLOCKER** → commit with EXPLICIT
`git add` of only the 2 intended files (never `-A`; the pre-existing
macOS binary must not ride along — \[macos-dupe-scan\]’s commit-hygiene
sibling); Lens-2 caught the flake. Match the orchestration to the
DECISION surface, not just the code surface. **(e)** Honesty nuances:
the spike resolved to “the input VALUE reaches the navbarMenu child” —
NOT “navigation works”; the visible pane does NOT truly switch (navbar
“More” highlights; `grepl(body)` passes via §2.3 hidden-DOM) → the §8.3
false-positive, deferred to 8e/#40 (do NOT overstate the spike). \#39
closed on the owner’s ACTUAL scope (§1.1 “executable + CI green opt-in”
= LOCAL validation + wired CI); TWO live-run watch items now ride on the
first master run (renv lib-path + the flake). Diff comment-only + CI →
`document()` N/A, `tests/`+`.github` lint-exempt, no `* 2.*` source
dupes (only `.Rproj.user/`, gitignored); non-e2e regression 0 failed/0
error (2159 passed, 156 e2e-skipped, 5 pre-existing `modPyramid`
warnings); test-infra/CI → CHANGELOG only, no NEWS. **Reflexes:**
\[verify-first\]\[flake-aware-validation\]\[completeness-workflow\]\[right-sized-orchestration\]\[author-decision\]\[regression-read\]\[refactor-only\]\[ci-suite-parity\]\[phase-3E-smoke\]\[macos-dupe-scan\]\[news-vs-changelog\].
**Apply:** for the final config/run-and-observe sub-phase with a real
spike — run the spike FIRST (\[verify-first\]); it can SHRINK scope (a
navbarMenu `set_inputs` read-back works → no helper change, no
RED→GREEN) → classify config-only via `AskUserQuestion`. NEVER trust a
single green run of a process-count-/timing-sensitive browser tier
(\[flake-aware-validation\]) — validate N times or let an adversarial
review’s concurrency surface the flake, reproduce firsthand to
characterize rate+trigger, and bring a discovered flake to the owner as
a scope decision (document + defer hardening to a follow-on that can be
live-validated, vs harden now) rather than silently shipping a
known-flaky `stop_on_failure` CI. Run the review when ultracode is ON
AND the DECISION surface is consequential even if the CODE surface is
trivial (it also catches the `.DS_Store`-class commit-hygiene BLOCKER →
explicit `git add`).

#### Learning 35 — Phase 9: retire the monolith (irreversible delete); a deleted file’s sole `@import` is load-bearing NAMESPACE fallout the reference-grep misses; full `check()` is a strictly stronger gate than the regression-read (S35, Phase 9 / issue \#27)

The FINAL conversion phase:
[`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
→ a
[`lifecycle::deprecate_soft()`](https://lifecycle.r-lib.org/reference/deprecate_soft.html)
alias launching `runModularApp(port=6013L, launch.browser=TRUE)`;
**deleted `inst/application/`** (17 files) + the orphans
`getMinParentAge`/`getLogo`/`shouldShowErrorTab`/`modMinimalTest`;
closed \#27. Strict TDD (RED→GREEN gated) + 4 owner `AskUserQuestion`s +
the pre-RED→RED / RED→GREEN gates. **(a) Pre-flight an IRREVERSIBLE
delete by RE-RUNNING the (stale, Session-21) §10 grep-inventory as a
read-only multi-modal sweep + a completeness-critic, then
FIRSTHAND-verify every load-bearing claim**
(\[verify-first\]\[completeness-workflow\]\[right-sized-orchestration\]):
`system.file("application")` is the SOLE live ref (R/runGenekeepr.R:19);
`inst/www/` (the modular app’s `data-ready.js`, appUI.R:9) is a
DIFFERENT directory from the deleted `inst/application/www/` —
conflating them breaks the app; `lifecycle` already a dep; all 17 files
tracked → `git revert`-able (§15). The sweep even self-contradicted on
`getLogo` (“exported ∴ keep” vs §10 “delete”) — exported ≠ keep when the
SOLE caller is the monolith being deleted (it is a public-API removal →
NEWS bullet). **(b) DELETION NAMESPACE FALLOUT — the inventory’s blind
spot** (\[deletion-namespace-fallout\]): `getMinParentAge.R` was an
`@noRd`, 0-caller orphan, BUT it carried the package’s ONLY
`#' @import shiny`; deleting it silently dropped `import(shiny)` from
NAMESPACE (leaving only the partial `importFrom` list) → the modular UI
died with `could not find function "h5"`. Neither §10 nor the sweep
flagged it (both reasoned about CALLERS, not what the file’s roxygen
EMITS); the REGRESSION RUN caught it. Fix: relocate `@import shiny` to
`R/nprcgenekeepr-package.R`; re-`document()`; re-verify. **(c) RED an
alias without launching a server**
(\[discriminating-RED\]\[testServer-mechanics\]):
[`testthat::local_mocked_bindings`](https://testthat.r-lib.org/reference/local_mocked_bindings.html)
BOTH `runModularApp` (same pkg) AND `runApp` (`.package="shiny"`) → the
test runs clean at HEAD (returns the monolith sentinel, no deprecation)
and post-impl (modular sentinel + deprecation);
[`lifecycle::expect_deprecated()`](https://lifecycle.r-lib.org/reference/expect_deprecated.html)
forces verbosity; `system.file("application", package=…)==""` is a clean
RUNTIME RED for “monolith no longer ships” (split into its own
`test_monolith_removed.R` and PAIRED into the deletion commit so every
commit stays green). 3 commits: reversible code → standalone deletion →
docs (§15 single-revert). **(d) The full `devtools::check()` is a
STRICTLY STRONGER gate than the \[regression-read\]** — it caught a
PRE-EXISTING, unrelated defect prior sessions’ regression-read never
surfaced: `a2interactive.Rmd`’s error-list table hardcoded 9
descriptions while
[`getEmptyErrorLst()`](https://github.com/rmsharp/nprcgenekeepr/reference/getEmptyErrorLst.md)
returns 10 (the NEW-45 `invalidIdChars` field), failing the vignette
build ([`data.frame()`](https://rdrr.io/r/base/data.frame.html): 10 vs
9). It surfaced because prior sessions used the regression-read AS the
gate and never ran full `check()`. Owner-gated fixing it as its OWN
`fix:` commit (NOT bundled — scope discipline / FM \#8). Final `check()`
= **0 errors / 0 warnings**; only pre-existing NOTEs (non-standard
top-level dev files; a stale `spelling.Rout.save` baseline of ~60 domain
words). **(e)** `a3manual`/`a2interactive` `.md/.html/.R` are
STALE-BY-DESIGN release artifacts (dated Jan 20, pre-Phases-1–8) — do
NOT force-reknit (months of unrelated regeneration noise + heavy-chunk
failure risk); `check()` builds vignettes from SOURCE anyway, so the
source edit is what matters. Re-knit only the actively-maintained
`README.md`/`NEWS.md`. **Reflexes:**
\[verify-first\]\[completeness-workflow\]\[right-sized-orchestration\]\[author-decision\]\[discriminating-RED\]\[testServer-mechanics\]\[regression-read\]\[document-zero-delta\]\[deletion-namespace-fallout\]\[phase-3E-smoke\]\[news-vs-changelog\].
**Apply:** when deleting files, account for what each file’s ROXYGEN
tags uniquely contribute to NAMESPACE (a sole `@import`/`@importFrom`) —
re-`document()` + diff NAMESPACE + run a full regression / UI smoke
after deletion; never trust the reference-grep alone
(\[deletion-namespace-fallout\]). Pre-flight an irreversible delete with
a re-run inventory sweep + firsthand load-bearing checks + an owner
gate. Run the FULL `check()` (not just the regression-read) for any
release-affecting deliverable — it is the only gate that exercises
vignette-build / examples / spelling; fix any PRE-EXISTING failure it
surfaces as a separate `fix:` commit, not bundled.

#### Learning 36 — third PLANNING deliverable; a “strengthen tests” issue hid a PRODUCTION change; a discovery-workflow’s HEADLINE COUNTS are themselves a verify-first target (S36, Phase 8e plan / issue \#40)

Decomposed issue \#40 (the sub-plan §6 “8e” follow-on) into
`docs/planning/phase8e-assertion-strengthening-subplan.md` — 7
risk-ordered vertical TDD slices for the active-pane assertion
mechanism + tautology/wrong-tab conversion + namespace fix +
determinism + real flows + CI-stability. Planning/architecture session —
TDD code-phases INAPPLICABLE (the plan is the deliverable, no code
written; mirrors \#30, FM \#18/#19). **(a) \[production-in-disguise\] —
a “test-quality” issue can hide a PRODUCTION change.** \#40 is titled
“strengthen E2E assertions” and reads as 5 test-only work items, but
item 5 (stochastic determinism) requires adding a gated
[`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)
hook to TWO **exported** server functions
(`modGeneticValue.R`/`modBreedingGroups.R` — which I firsthand-confirmed
have ZERO `set.seed`; the issue’s “set.seed in modBreedingGroupsServer”
was imprecise, it must be ADDED; the RNG is delegated to
`geneDrop`→`chooseAlleles`/`groupAddAssign`→`fillGroupMembers`).
`AppDriver$new(seed=)` can’t control it (seeds startup, not the
click-triggered eventReactive after intervening RNG). Isolated it as
slice **8e-5**: its OWN owner-gated, full RED→GREEN→REFACTOR + `check()`
slice using the existing exported
[`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)
(pins `sample.kind="Rounding"`), gated `getOption/Sys.getenv` so the
default path is unchanged — distinct from the test-only
run-and-observe+\[mutation-check\] conversion slices (8e-2/8e-3). This
BREAKS the sub-plan §11 “8a–8d are test-only” boundary → flagged
explicitly in the plan’s §11. **(b) A discovery-workflow’s HEADLINE
AGGREGATES are a \[verify-first\] target, reconciled against firsthand
greps AND prior authoritative docs**
(\[completeness-workflow\]/\[verify-first\] applied to the workflow’s
OWN counts, not just its findings). The 23-agent census reported “**49**
tautologies” and per-file `nTestBlocks` summing to **163**; firsthand
`grep -c 'expect_true(TRUE'` = **41** (the census conflated ~8 of a
DISTINCT ≈18 `expect_true(nchar(html)>100)` near-tautology class into
the 49), and `grep -c 'test_that('` = **159** (4 census `n=` rows
off-by-one —
input-detailed/genetic-value-detailed/error-states/home-navigation each
+1). The census’s OWN adversarial critic caught the 49-vs-41 conflation;
a SEPARATE adversarial review of the **synthesized PLAN itself** (not
the evidence) caught the 163-vs-159 §3-table error I’d propagated from
the census `n=`, plus a home-nav trap (`grepl("Home"/"Input")` at
:155-156 asserts navbar `<ul>` labels NOT inside any tab-pane →
`assert_active_pane` would correctly FAIL them → carve them out) and a
missing `get_js`/`wait_for_js` contract note. The TIEBREAKER for the
off-by-one rows was the PARENT plan’s own counts (6/7/13/10). The
workflow CONFIRMS; firsthand greps + prior docs SETTLE. **(c) Review the
PLAN, not just the evidence** — running a second adversarial reviewer
over the written document (against the codebase + the issue) is a
distinct, high-ROI step that catches PROPAGATED transcription errors a
forward census can’t (the §3 count, the navbar-label trap, the
seed-insertion-point nesting, the appUI:156-vs-159 cite). **(d) The
active-pane mechanism is the load-bearing domain finding seeded for the
executor:** `get_html`/`get_text` serialize the WHOLE hidden navbarPage
DOM (every pane’s static UI is in the boot DOM — the \#30 hidden-DOM
finding, now the thing 8e fixes), so only
`app$get_js(".tab-content > .tab-pane.active … innerText")` honors CSS
visibility, gated on `data-value`==title (== mainNavbar value → no
`#tab-NNNN` id guessing). Code-readable on the static DOM, but the BS4
runtime `.active`/`.show` toggling + `innerText`-honors-visibility MUST
be confirmed in a live Chrome in slice 8e-1 as a HARD GATE (if it fails,
the helper design changes for every later slice). Confirmed firsthand:
shinytest2 0.5.0 exposes `get_js`/`wait_for_js`/`get_value`; `jsonlite`
is NOT a dep → the helper quotes labels with base-R
`encodeString(x, quote="'")`, not
[`jsonlite::toJSON`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html).
**(e)** Verticality + ordering: 8e-1 load-bearing
(mechanism+spike+wrong-tab fix+first file) → 8e-2/8e-3 (static-UI
conversion, independent) → 8e-4 (namespace, prereq for) → 8e-6 (real
flows; 8e-5 DECOUPLED — Option-C structural-invariant assertions need no
production change) → 8e-7 (CI per-group fresh processes, ORTHOGONAL,
live-runner-validated only — FM-#24-adjacent, don’t claim it fixes the
flake until a live run shows it; pairs with the two S34 watch items).
Planning artifacts (workflow `wf_4ebcdb7f-f4b`) NOT committed; no
runtime/R change → Phase-3E N/A (the plan is the deliverable), no NEWS
(planning doc → CHANGELOG/handoff only). **Reflexes:**
\[verify-first\]\[completeness-workflow\]\[right-sized-orchestration\]\[author-decision\]\[idiom-inventory\]\[production-in-disguise\]\[news-vs-changelog\].
**Apply:** when planning a sub-phase that decomposes a
“test/quality/refactor” issue — classify each work item by whether it
touches PRODUCTION code and isolate those as owner-gated full-TDD slices
distinct from the test-only run-and-observe ones
(\[production-in-disguise\]); treat a discovery-workflow’s HEADLINE
COUNTS (`n=`/aggregates) as a \[verify-first\] target, reconciling
against firsthand greps + the parent plan’s counts before citing; run a
SECOND adversarial review over the SYNTHESIZED PLAN itself (not just the
evidence) to catch propagated transcription errors; keep slices vertical
and risk-order the load-bearing browser spike FIRST as a hard gate.

#### Learning 37 — first EXECUTION slice of 8e; the hard-gate spike FALSIFIED the plan’s load-bearing selector, and the bounded diagnostic that found the fix IS the spike succeeding (S37, Phase 8e-1 / issue \#40)

Implemented slice 8e-1: the 4 active-pane helpers
(`get_active_pane_text`/`get_active_pane_value`/`wait_for_active_pane`/`assert_active_pane`)
in `tests/testthat/helper-shinytest2.R` (browser-free RED→GREEN) + the
live-Chrome spike (HARD GATE) + the
`test-e2e-summary-statistics-module.R` conversion (8
tautologies/wrong-tab → behavioral active-pane assertions). Strict TDD,
gated. **(a) \[hard-gate-spike\] — the load-bearing spike FALSIFIED the
planned mechanism (R1 fired).** The plan §2.3/§4 specified
`.tab-content > .tab-pane.active` + innerText-honors-visibility, flagged
“confirm in live Chrome FIRST, STOP if it fails.” The spike DISCONFIRMED
it: the modules nest their OWN tabsetPanels, so `.tab-content` is
NON-UNIQUE — **5** containers (1 top-level navbar + 4 nested; nested
active sub-panes “Input Format”/“Plot”/“Rankings”/“Groups”),
`querySelector` first-match latched onto the nested “Input Format” after
the Settings nav (so `assert_active_pane(Settings)`=FALSE, item 4
failed), and a mid-fade nested element made innerText look like it
ignored visibility (hidden Home read 1895). A spike on a load-bearing
assumption is a hypothesis test — it can FALSIFY, not just de-risk.
**(b) The bounded read-only DIAGNOSTIC that found the corrected
mechanism IS the spike succeeding** (not a redesign mode-switch). A
second read-only diagnostic spike (no conversion code) proved a
corrected selector — the only `.tab-content` NOT inside a `.tab-pane`
(`!t.closest('.tab-pane')`), its direct-child `.tab-pane.active`:
structurally resolved (no dependence on the dynamic
`data-tabsetid=8517`), it tracked EVERY navigation incl. the
navbarMenu(“More”) “Settings” child, and — correctly scoped — innerText
DID honor visibility (hidden Pedigree=0). Because it deviates from the
approved plan’s mechanism (R1), I brought it to the owner as a
scope/approach `AskUserQuestion` (\[author-decision\]:
apply-fix-and-complete \[chosen\] vs checkpoint-and-stop vs
literal-stop) rather than silently redesigning past the gate (SAFEGUARDS
/ FM \#8); confirmed the corrected helpers 17/17 through a live spike.
**(c) Browser-free unit tests SURVIVE the mechanism rewrite because the
fake stubs key on the JS’s INVARIANTS, not its exact text** (the \#31
fake-AppDriver-stub idiom extended to active-pane helpers).
`fake_app_pane` discriminates by inspecting the `get_js` arg for the
`data-value` vs `innerText` substring and simulates `wait_for_js`
success only when the embedded label == its own `data_value`;
`fake_app_pane_liar` (wait succeeds but value≠label) proves
`assert_active_pane`’s redundant
`identical(get_active_pane_value, tab_label)` guard. Both substrings
survive the selector change (the corrected JS still reads
`getAttribute('data-value')`/`innerText`), so all 11 new tests / 59
expectations stayed GREEN across the fix — the unit layer proves the
CONTRACT (never-throw + pane/content discrimination), the live spike
proves the BROWSER TRUTH. **(d) The wrong-tab RED→GREEN and the
\[mutation-check\] are the SAME proof in two directions, and the spike
already captured the RED.** Tests 2–8 navigated to “Genetic Value
Analysis” (the §2.4/#33d wrong-tab defect — “Summary Statistics” is its
own `tabPanel`, appUI.R:156-159), so the converted
`assert_active_pane(app,"Summary Statistics",…)` is FALSE while nav
targets GVA (RED — captured live: “assert SS on GVA = FALSE”) and TRUE
once nav→“Summary Statistics” (GREEN). The post-conversion
\[mutation-check\] (one boot: wrong-tab→FALSE, correct-tab→TRUE)
re-proves discrimination at the test-file level (the old
`expect_true(TRUE)` passed BOTH). Assert STATIC UI only — export-button
labels, the h3 “Summary Statistics and Plots”, and the bottom
population-genetics guidance HTML that statically defines “Founder
Equivalents”/“Founder Genome Equivalents”; the founder/quartile TABLES +
rendered plots are data-dependent → deferred to 8e-6 (the §8e-1 dragon-2
deferral, honored). **(e)** Phase-3E / scope: the deliverable lives ONLY
in the test tree (`helper-shinytest2.R` + `test_helper_shinytest2.R` +
the one converted e2e file) → the SUITE + the live AppDriver spike ARE
the runtime (the \#31 “Phase-3E N/A; the suite is the runtime” pattern);
I DID drive the real app (17/17 spike + 8/8 e2e browser run). `tests/`
is `.lintr`-excluded → lint-exempt; no `R/` roxygen → `document()` N/A;
test-infra → CHANGELOG only, no NEWS. Non-e2e regression 0 failed/0
error (2122 passed, 159 e2e-skipped, 5 pre-existing `modPyramid`
warnings). Committed ONLY the 3 intended test files via explicit
`git add` (the pre-existing `.DS_Store`/`..Rcheck/`/audit-html must NOT
ride along — \[macos-dupe-scan\]’s commit-hygiene sibling, \#34d);
transient `/tmp/spike_*.R`+`/tmp/mutation_check.R` NOT committed.
**Reflexes:**
\[hard-gate-spike\]\[verify-first\]\[author-decision\]\[discriminating-RED\]\[mutation-check\]\[regression-read\]\[phase-3E-smoke\]\[right-sized-orchestration\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** when a plan flags a load-bearing mechanism as a HARD-GATE
spike — run it BEFORE any dependent work; it can FALSIFY the planned
mechanism (a non-unique selector / a wrong visibility assumption), and a
BOUNDED read-only diagnostic that finds the corrected mechanism is the
spike SUCCEEDING — bring the deviation to the owner as a scope fork
(\[author-decision\]), don’t silently redesign past the gate. TDD
browser helpers browser-free via fake-AppDriver stubs that key on the
JS’s INVARIANTS (substrings/contract) so they survive a mechanism
rewrite; prove the live truth with the spike. For a navbarPage with
nested tabsetPanels, scope the active-pane selector to the only
`.tab-content` not inside a `.tab-pane`. The wrong-tab RED and the
\[mutation-check\] are the same proof in two directions.

#### Learning 38 — first PURE run-and-observe conversion slice (no defect, no RED); splitting an oversized conversion slice highest-value-first; the active-pane wrong-content mutant must use pane-ABSENT text (S38, Phase 8e-2 home-nav sub-slice / issue \#40)

Implemented the **home-nav + light-app-file** sub-slice of 8e-2:
converted `test-e2e-home-navigation.R` (8 of 10 blocks →
`assert_active_pane`; 2 navbar-label carve-outs kept as whole-DOM
`grepl`), and strengthened `test-app-loading.R` +
`test-app-navigation.R`. Unlike 8e-1 (which carried a wrong-tab RED),
this slice has **no defect** — the app already behaves and every
navigation targets the correct tab — so it is the campaign’s first
**PURE \[refactor-only\] run-and-observe** conversion: green-on-arrival,
no RED/GREEN, rigor supplied entirely by the \[mutation-check\].
Classified at a single `PRE-RED→run-and-observe` \[author-decision\]
gate (no synthetic RED — Learning \#20a). **(a) Splitting an oversized
conversion slice — highest-value-first.** Plan §5 8e-2 = 11 files / **64
browser-booting `test_that` blocks** (each boots its own Chrome
AppDriver) → past one comfortable session and squarely the plan’s
risk-R3 / §5(8c) process-count-flake exposure. Surfaced the split as an
owner \[author-decision\] (4 options: home-nav+app / input-family /
input+home+app / all-11); owner chose **home-nav + app files (14
blocks)**. The right first cut is the highest *behavioral* value, not
the literal slice: the 3 `#goto_*` clicks are genuine interactions wired
to `updateNavbarPage(session,"mainNavbar",selected=…)`
(`appServer.R:72-94`), so converting them to
`assert_active_pane(app,<target>,…)` turns a no-op-tolerant body-grepl
into a real pane-switch assertion — more coverage per block than
static-keyword rescoping. Input/pedigree/pyramid families deferred to
later 8e-2 sessions (they correctly pass the FULL titles “Pedigree
Browser”/“Age-Sex Pyramid” as `navigate_to_tab`’s ignored `fallback` arg
— verified NO hidden wrong-tab defect there, unlike 8e-1’s
summary-statistics). **(b) The active-pane wrong-content mutant must use
text GENUINELY ABSENT from the target pane — `innerText` carries EVERY
static control label.** The \[mutation-check\]’s wrong-pane arm (after
`#goto_input`, `assert_active_pane(app,"Home")`/`"Age-Sex Pyramid"` →
FALSE) and the content-blind contrast
(`grepl("Age-Sex Pyramid Analysis|Bin Size", body)` → TRUE while on
Input — the hidden pane is in the whole-body DOM) cleanly prove
discrimination. But the *wrong-content* arm first FALSELY passed:
`assert_active_pane(app,"Input","Focal Animals")` returned TRUE because
the Input File-Content radio literally renders “Focal animals only;
pedigree built from database” (`modInput.R:70`) — `innerText` includes
it. Refined to `"Color Scheme"` (a Pyramid-only control) → FALSE.
Lesson: a “right-pane / wrong-pattern” mutant needs a string in NO
sibling control of that pane; pick it by reading the module UI, not by
guessing a plausibly-foreign label. **(c) Static-anchor sourcing + the
carve-out as a STRUCTURAL strengthen.** Pattern choices came from
reading each pane’s module UI for data-independent text (Input h3 “Data
Input and Quality Control” `modInput.R:42`; Pedigree h4 “Focal
Animals”/“Display Options” `modPedigree.R:52,103`; Pyramid h3 “Age-Sex
Pyramid Analysis”/“Bin Size”/“Color Scheme” `modPyramid.R:25-32`) —
data-bearing tables/plots stay deferred to 8e-6 (plan R9). The carve-out
generalizes beyond home-nav: navbar `<ul>`/dropdown LABELS live outside
every `.tab-pane`, so `assert_active_pane` would correctly NOT match
them — `home-navigation` “Navbar has all main tabs”/“More menu” stay
`grepl`, and `test-app-loading` block 2’s navbar grepl was strengthened
STRUCTURALLY instead — `wait_for_element(app,'a[data-value="Input"]')`
(real tab anchors) rather than a body substring the Home pane’s “Go to
Input” button text would also satisfy. **(d)** Phase-3E / scope:
test-tree-only → the browser run (14 blocks / **22** expectations, net
+2 from the strengthened app files) + the live mutation-check spike ARE
the runtime (the \#31 pattern); `tests/` is `.lintr`-excluded; no `R/`
change → no `document()`/NEWS, \[news-vs-changelog\] → CHANGELOG only.
\[regression-read\] held the S37 baseline exactly (2122 passed / 0
failed / 0 error, 159 e2e-skipped, 5 pre-existing `modPyramid`
warnings). Committed ONLY the intended files via explicit `git add`
(\[macos-dupe-scan\] commit-hygiene — `.DS_Store`/`..Rcheck/`/audit-html
must NOT ride along); `/tmp/mutation_check_8e2.R` not committed.
**Reflexes:**
\[refactor-only\]\[author-decision\]\[mutation-check\]\[verify-first\]\[regression-read\]\[phase-3E-smoke\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** a conversion slice with no underlying defect is a PURE
run-and-observe \[refactor-only\] (green-on-arrival; \[mutation-check\]
is the rigor) — gate `PRE-RED→run-and-observe`, do NOT force a synthetic
RED. When an oversized conversion slice must split, cut
highest-BEHAVIORAL-value first (real interactions wired to a state
change \> static-keyword rescoping), as an owner \[author-decision\].
For an active-pane \[mutation-check\], the wrong-content mutant must use
text in NO sibling control of the target pane (`innerText` carries every
static label) — source it by reading the module UI. Strengthen
navbar-label assertions STRUCTURALLY (real `a[data-value]` anchors),
never via `assert_active_pane` (labels are outside the panes).

#### Learning 39 — Input-family run-and-observe conversion (8e-2 part A, continued): the `innerText` VISIBILITY-MAP drives static-pattern choice; a tautology can encode a FALSE premise (assert pane-active, don’t fabricate a feature); the active nested-tab guidance HTML is the fallback anchor when a sidebar control is conditionally hidden (S39, Phase 8e-2 Input family / issue \#40)

Converted the 3 Input-family E2E files (`input-module` 5 /
`input-detailed` 6 / `input-tutorial` 8 = **19** browser-booting blocks)
from the content-blind
`navigate_to_tab → grepl(get_html_safe(app,"body"))` idiom to
`assert_active_pane(app,"Input",<static>)`. Same class as \#38 — PURE
**\[refactor-only\]** run-and-observe (no defect; the Input pane already
renders and `navigate_to_tab("Input")` already targets the right tab —
“Input” IS the `tabPanel` title, `appUI.R:120-124`), gated
`PRE-RED→run-and-observe` **\[author-decision\]**;
**\[mutation-check\]** supplies the rigor (no synthetic RED). **(a) The
`innerText` VISIBILITY-MAP is the load-bearing tool for choosing a
static pattern** — extends \#38b (“innerText carries every static
label”) with the crucial corollary: `innerText` honors CSS
`display:none`, so within the active Input pane the reliably-visible
text is ONLY {sidebar controls NOT inside a false `conditionalPanel`} ∪
{the ACTIVE nested-tab content} ∪ {nested-tab NAV labels}. HIDDEN →
unusable: the Separator radio “Comma/Semicolon/Tab” (its
`conditionalPanel` condition `input.fileType=='fileTypeText'` is FALSE —
fileType defaults `fileTypeExcel`, `modInput.R:55-85`), the 3
non-default `fileInput`s, and every non-active nested tab’s content (the
“Download Errors/Warnings/Cleaned Data” buttons + `DTOutput`s). So
“supports comma/tab-separated” could NOT assert the hidden “Comma”/“Tab”
labels → drew anchors from the always-rendered guidance instead (see
(c)). Read the module UI for the DEFAULT input state (which
radios/conditionalPanels are selected) BEFORE picking a pattern; the
browser run is the **\[verify-first\]** check (a hidden-subtree pattern
→ `assert_active_pane`=FALSE → caught immediately). **(b) A tautology
test can encode a FALSE premise — convert it honestly, never force a
match.** `input-detailed` “has example data option” was
`expect_true(TRUE)` with a dead `grepl("example|demo|sample|test")`; the
module has NO example/demo-data feature (the only “examples” text is
incidental — “the name used in examples and output” in the format docs).
Asserting that string would manufacture false coverage. The honest
conversion is NULL-pattern `assert_active_pane(app,"Input")` — it proves
navigation actually landed on + made visible the Input pane (a genuine
upgrade over `expect_true(TRUE)`) WITHOUT claiming a nonexistent
feature; flagged the name/feature mismatch in the handoff. Contrast
`input-tutorial` “genotype file support” (also a tautology) which DID
have real backing — File Content radio “Pedigree(s) and genotypes …”
(`modInput.R:67-70`) + the Genotype-format docs → real pattern
`"genotype"`. Rule: classify each tautology by whether its NAMED feature
ACTUALLY EXISTS — real → assert it; nonexistent → NULL-pattern
pane-active + flag, never force-match incidental text. **(c) The active
nested-tab guidance HTML is the fallback static anchor when a sidebar
control is conditionally hidden.** The Input pane’s first/default nested
tab “Input Format” renders `includeHTML(input_format.html)`
(`modInput.R:142-157`), so its full text is in `innerText` — it supplied
the CSV/comma/tab/format anchors the conditionally-hidden Separator
panel could not (“comma-delimited”, “tab-delimited”). When the sidebar
can’t anchor a pattern (the relevant control sits in a false
`conditionalPanel`), reach for the always-rendered guidance in the
ACTIVE nested tab — but confirm it IS the active nested tab (a
non-default nested tab is `display:none` too). **(d)** Phase-3E / scope:
test-tree-only → the browser run (19 blocks / 19 expectations — a 1:1
swap, net 0) + the live mutation-check spike ARE the runtime (#31
pattern); drove the real app. \[mutation-check\] PASS at all arms —
correct `(Input,"Data Input and Quality Control")`→TRUE, wrong-pane
`(Age-Sex Pyramid,…)`→FALSE, wrong-content
`(Input,"Color Scheme")`→FALSE (“Color Scheme” is Pyramid-only, sourced
by READING `modPyramid.R` per \#38b not by guessing), old whole-body
`grepl("Color Scheme",body)`→TRUE (content-blind contrast), active-pane
innerText grepl→FALSE (sanity). **\[regression-read\]** held the S38
baseline EXACTLY (2122 passed / 0 failed / 0 error, 159 e2e-skipped, 5
pre-existing `modPyramid` warnings, 0 non-e2e offenders). `tests/`
`.lintr`-excluded; no `R/` change → no `document()`/NEWS
(**\[news-vs-changelog\]** → CHANGELOG only). Commit ONLY the 3 test
files + docs via explicit `git add` (**\[macos-dupe-scan\]** —
`.DS_Store`/`..Rcheck/`/audit-html must NOT ride along);
`/tmp/mutation_check_8e2_input.R` not committed. **8e-2 now ~half done**
(home-nav+app S38 + Input S39); PEDIGREE family
(module/detailed/tutorial = 19) and PYRAMID family (module/detailed =
12) remain as SEPARATE sessions (plan R3 / FM \#18/#25). **Reflexes:**
\[refactor-only\]\[author-decision\]\[mutation-check\]\[verify-first\]\[regression-read\]\[phase-3E-smoke\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** for an active-pane conversion, choose each static pattern
from the `innerText` VISIBILITY-MAP — only default-visible sidebar
controls + the ACTIVE nested-tab content + nested-tab nav labels are
present; `conditionalPanel`s with a false condition and non-active
nested tabs are `display:none` and unusable (read the module UI for the
DEFAULT state; the browser run is the \[verify-first\]). Convert a
tautology by whether its named feature EXISTS — real → assert it;
nonexistent → NULL-pattern `assert_active_pane(app,"<Tab>")` + flag,
never force-match incidental text. When a sidebar control is
conditionally hidden, anchor on the always-rendered guidance HTML in the
active nested tab.

#### Learning 40 — Pedigree-family run-and-observe conversion (8e-2 part B): the genuine-grepl-vs-tautology conversion split, the genuine-to-NULL data-dependent sub-case, and a PRE-GATE adversarial refutation of the whole map (S40, Phase 8e-2 Pedigree family / issue \#40)

Converted the 3 Pedigree-family E2E files (`pedigree-module` 5 /
`pedigree-detailed` 6 / `pedigree-tutorial` 8 = **19** browser-booting
blocks) from the content-blind
`navigate_to_tab → grepl(get_html_safe(app,"body"))` idiom to
`assert_active_pane(app,"Pedigree Browser",<pattern>)`. Same class as
\#38/#39 — PURE **\[refactor-only\]** run-and-observe (no defect; the
Pedigree pane already renders, “Pedigree Browser” IS the `tabPanel`
title `appUI.R:130`, and `navigate_to_tab`’s 3rd `fallback` arg is an
explicit documented NO-OP `helper-shinytest2.R:245-250` — re-verified
firsthand, NO wrong-tab defect), gated `PRE-RED→run-and-observe`
**\[author-decision\]**; **\[mutation-check\]** supplies the rigor (no
synthetic RED). **(a) The conversion is a PRINCIPLED SPLIT by the OLD
assertion’s kind, not a uniform rewrite.** Two classes need different
treatment: a **genuine `expect_true(grepl(orig, html))`** assert already
encodes real intent → KEEP its original regex verbatim and only rescope
the haystack to the active pane (faithful refactor: same pattern,
tighter scope — module L6/L25/L42/L76, detailed L6/L25/L82, both
dragons); a **`expect_true(TRUE)` tautology** (with a dead
`has_* <- grepl(...)`) has NO behavior to preserve → free to choose a
PRECISE default-visible anchor for the named control (“Display Unknown
IDs”/“Focal Animals”/“Choose CSV file”/“Trim pedigree”/“Update Focal
Animals”/“Clear Focal Animals”, `modPedigree.R:52,72,79,86,105,118`).
Don’t uniformly substitute precise anchors (loses faithfulness on the
genuine asserts) nor uniformly keep-regex (the dead tautology regexes
were never asserted — a precise anchor is strictly more honest and
discriminating). **(b) A GENUINE assert can ALSO become NULL — the
data-dependent sub-case, distinct from \#39’s nonexistent-feature
NULL.** \#39’s honest-tautology rule NULLs a tautology whose named
feature doesn’t exist. Here a *real*
`expect_true(grepl("table|dataTable", html))` assert (module L59,
detailed L63) must ALSO convert to NULL-pattern
`assert_active_pane(app,"Pedigree Browser")` — not because the table is
fake, but because it is **data-dependent**:
`DT::DTOutput(ns("pedigreeTable"))` is gated by `req(pedigreeData())`
(`modPedigree.R:150,306`) and these tests load no studbook, so the table
renders an EMPTY div with no innerText. The original regex matched only
because “table” appears elsewhere in the whole-body DOM (CSS/JS/the
`pedigreeTable` id ATTRIBUTE) — exactly the content-blindness the
conversion closes. So the test of “keep the regex” is whether at least
one alternative is DEFAULT-VISIBLE in the pane innerText; if NONE is
(the target is data-bearing), drop to NULL + flag the content assertion
as deferred to 8e-6 (same destination as \#39’s data-bearing deferral;
DataTables “Show X entries” pagination, tutorial L28, is the same
data-dependent case). Result: 4 honest NULLs (module L59, detailed L63,
detailed L101 \[nonexistent “status filter”\], tutorial L28), 15 content
patterns; a NULL `assert_active_pane` still genuinely upgrades the old
`expect_true(TRUE)`/content-blind grepl (it catches a wrong-tab /
silent-no-op nav). **(c) The always-rendered LEFT-panel guidance HTML
carries the dragon column-keywords — extends \#39(c) from the
active-nested-tab guidance to the unconditional left panel.** Both
dragons (`pedigree-detailed:57`
`sire|dam|parent|offspring|ancestor|descendant`, `pedigree-tutorial:174`
`sire|dam|sex|birth|exit|age|gen|population`) resolve against
`inst/extdata/ui_guidance/pedigree_browser.html` (`includeHTML` at
`modPedigree.R:41-44`), which lists “Ego ID, Sire ID, Dam ID, Sex,
Generation, and Population columns… Birth Date, Exit Date, Age”. Unlike
\#39’s Input case (the anchor lived in the ACTIVE nested tab, so
nested-tab state mattered), modPedigree has no nested tabsetPanel — the
guidance column is unconditionally visible, so the column names are
reliable static anchors. (Honesty self-correction: my draft cited a
helpText “ancestors of focal animals”; the actual
`modPedigree.R:124-127` text is “relatives of the focal animals” — the
critic caught the misquote; verdict unaffected since guidance “Sire ID,
Dam ID” independently satisfies `sire|dam`.) **(d) A PRE-GATE
adversarial refutation of the WHOLE map — verify the conversion before
committing the owner to the gate, not after.** Rather than pose the gate
on a self-authored map and discover a bad pattern only in the (slow,
19-Chrome-boot) browser run, ran a 4-agent workflow (3 per-file skeptics
each told to default-to-refuted + a cross-checking critic) over all 19
proposed patterns BEFORE the `AskUserQuestion`: **0/19 refuted**, critic
GO, every pattern confirmed default-visible, the 4 NULLs confirmed
honest (no overlooked static anchor), and the \[mutation-check\] labels
“Color Scheme”/“Bin Size” confirmed FOREIGN (grep: only
`modPyramid.R:31-32`). This is \[right-sized-orchestration\] applied to
a conversion slice (a MEDIUM-risk 19-block multi-file map earns a
read-only refutation sweep; the browser run remains the authoritative
\[verify-first\]) and a \[completeness-workflow\] (the critic hunts for
an overlooked honest anchor that would make a NULL dishonest). Cheap
relative to a wasted browser cycle; the owner gate then carried a
verified map. **(e)** Phase-3E / scope: test-tree-only → the browser run
(19 blocks / 19 expectations — 1:1 swap, net 0) + the live
mutation-check spike ARE the runtime (#31 pattern); drove the real app.
**\[regression-read\]** non-e2e **2162 passed / 0 failed / 0 error / 0
non-e2e offenders** (156 skipped, 5 pre-existing `modPyramid` warnings)
— the e2e-only change self-skips at `create_test_app()`
(`helper-shinytest2.R:196`) so non-e2e counts are definitionally
unaffected (count differs from S39’s reported 2122 only because this
invocation set `NOT_CRAN=true`, surfacing more non-e2e tests —
orthogonal to the change, NOT a regression). `tests/` `.lintr`-excluded;
no `R/` change → no `document()`/NEWS (**\[news-vs-changelog\]** →
CHANGELOG only). Commit ONLY the 3 test files + docs via explicit
`git add` (**\[macos-dupe-scan\]** — `.DS_Store`/`..Rcheck/`/audit-html
must NOT ride along); `/tmp/mutation_check_8e2_pedigree.R` not
committed. **8e-2 now ~3/4 done** (home-nav+app S38 + Input S39 +
Pedigree S40); the PYRAMID family (`pyramid-module`/`pyramid-detailed` =
12) is the last 8e-2 cut, a SEPARATE session (plan R3 / FM \#18/#25).
**Reflexes:**
\[refactor-only\]\[author-decision\]\[mutation-check\]\[verify-first\]\[regression-read\]\[phase-3E-smoke\]\[news-vs-changelog\]\[macos-dupe-scan\]\[right-sized-orchestration\]\[completeness-workflow\].
**Apply:** for an active-pane conversion, split by the OLD assertion’s
kind — genuine `grepl` asserts KEEP their regex (rescope only);
tautologies get a precise default-visible anchor. A genuine assert whose
target is DATA-DEPENDENT (no default-visible innerText, e.g. a
`req()`-gated `DTOutput`) drops to NULL-pattern + defer-to-8e-6, just
like a nonexistent-feature tautology — the test is “is ≥1 alternative
default-visible?”, not “is the feature real?”. Anchor dragon
column-keywords on the unconditional guidance HTML. Refute the whole
pattern map with a read-only adversarial workflow BEFORE the gate; the
browser run is still the authoritative verify.

#### Learning 41 — Pyramid-family run-and-observe conversion (8e-2 part C, FINAL → 8e-2 COMPLETE): the NULL test is “does ≥1 regex alternative match DEFAULT-VISIBLE innerText?” NOT “is the named feature real / data-dependent?” (refines \#40b); keep a genuine regex VERBATIM even when the test NAME overclaims; and the pre-gate refutation EARNED its keep by correcting 2/12 self-authored over-NULLs (S41, Phase 8e-2 Pyramid family / issue \#40)

Converted the 2 Pyramid-family E2E files (`pyramid-module` 6 /
`pyramid-detailed` 6 = **12** browser-booting blocks) from the
content-blind `navigate_to_tab → grepl(get_html_safe(app,"body"))` idiom
to `assert_active_pane(app,"Age-Sex Pyramid",<pattern>)`, the LAST 8e-2
cut. Same class as \#38/#39/#40 — PURE **\[refactor-only\]**
run-and-observe (no defect; the Pyramid pane already renders, “Age-Sex
Pyramid” IS the `tabPanel` title `appUI.R:139`, `navigate_to_tab`’s 3rd
`fallback` arg the documented no-op `helper-shinytest2.R:250`), gated
`PRE-RED→run-and-observe` **\[author-decision\]**;
**\[mutation-check\]** supplies the rigor (no synthetic RED). Outcome:
10 keep-regex (module L6/L25/L42/L59/L76/L93; detailed
L6/L25\[🐉\]/L44\[🐉\]/L80), 2 tautology→anchor (detailed L63
`expect_true(TRUE)`→“Download Plot”; detailed L99 `nchar(html)>100`→“Age
Plot”), **0 NULL**. **(a) The NULL test is purely “does ≥1 regex
alternative match DEFAULT-VISIBLE innerText?” — NOT “does the test’s
NAMED target exist / is it data-dependent?” — refining \#40b.** My FIRST
map over-NULLed D3 (“maximum age setting”) and D6 (“data requirement
message”) by reasoning from the test’s NAMED intent (no max-age control
exists; the empty-vs-loaded state is data-dependent). Wrong altitude:
the conversion is a HAYSTACK-RESCOPE, so the only question is whether
the kept/anchored pattern matches something DEFAULT-VISIBLE in the pane.
D3’s genuine regex `max|maximum|age|limit` matches the always-visible
age labels (“Age Unit:”, “Age Label Size:”, h3 “Age-Sex Pyramid
Analysis”) — the `max=10/1500/2.0` tokens are numeric widget BOUNDS (not
innerText), and there’s no max-age control, but “age” IS visible → KEEP
(rescope), do NOT NULL. \#40b’s “genuine→NULL” fires ONLY when NO
alternative is default-visible (the `req()`-gated `DTOutput` whose only
“table” hit was a DOM id attribute); it is NOT triggered by a
nonexistent/overclaiming NAME when the regex still matches
incidental-but-visible static text. **(b) Keep a genuine regex VERBATIM
even when the test NAME overclaims; flag the dragon in a comment — do
NOT rename/retarget.** D3 stays `max|maximum|age|limit` (the critic’s
“rescope to /age\|bin\|unit\|label/ + rename the test” is a regex+name
change = scope creep beyond a haystack-rescope slice). Faithfulness =
same pattern, tighter scope; the overclaiming name is pre-existing and
not this slice’s defect to fix. A code comment records that the match is
via static “age” labels, not a real max-age control. **(c) A
content-LENGTH tautology (`nchar>100`, no regex to keep) whose pane has
an always-rendered guidance panel gets a GUIDANCE ANCHOR, not
NULL+defer.** D6’s test names a “placeholder or instruction shown
without data” — the unconditional `includeHTML(pyramidPlot.html)` (“A
Pedigree Age Plot plots an age-distribution of live animals…”,
`modPyramid.R:55-58`) IS that instruction, always visible pre-data →
anchor “Age Plot” (distinct from D5’s
`population|distribution|pyramid|demographic`). NULL+defer-to-8e-6 was
over-conservative: the empty-state MESSAGE is static, only the rendered
PLOT is data-dependent — and no block here targets the plot. Extends
\#39(c)/#40(c) (guidance-as-anchor) to the FALLBACK case: a
content-length tautology with no surviving regex still gets a real
anchor when the pane carries unconditional guidance. **(d) The pre-gate
refutation EARNED ITS KEEP this session by CORRECTING the map (2/12
refuted), not merely confirming it (S40 was 0/19).** Both refuted blocks
were my over-NULLs (a)/(c); the skeptics+critic, reasoning from the same
source, caught them BEFORE the `AskUserQuestion` gate and BEFORE the
slow 12-Chrome-boot browser run. Adopting the corrections produced the
0-NULL map. This is the payoff case for
**\[right-sized-orchestration\]**/**\[completeness-workflow\]** as a
PRE-GATE: when the author’s first map is wrong, a read-only adversarial
sweep is cheap insurance that converts a private misjudgment into a
corrected, owner-gateable map — the value is exactly highest when
refutedCount\>0. (Verify the critic firsthand — it CONFIRMS; here its
source-grounded reasoning was independently checked against
`modPyramid.R` + the guidance HTML before adopting.) **(e) The 0-NULL
outcome contradicted the S40 handoff’s anticipation** that the
data-dependent `plotOutput` would force NULLs/defers in the pyramid
family. It didn’t: none of the 12 blocks asserts the rendered
plot/Statistics table — every block targets a static sidebar control, a
nav/tab label, the h3, or the unconditional guidance — so the pyramid
pane’s rich static surface yields a real content anchor for all 12. A
handoff’s per-block anticipation is a hint, not a spec (FM \#6/#20
applied to a handoff): census the actual blocks firsthand. **(f)**
Phase-3E / scope: test-tree-only → the browser run (12 blocks / 12
expectations — 1:1 swap, net 0) + the live mutation-check spike ARE the
runtime (#31 pattern); drove the real app. **\[mutation-check\]** PASS,
INVERTED vs the Pedigree slice (Pyramid is now the TARGET pane) —
correct `(Age-Sex Pyramid,"Bin Size")`→TRUE, wrong-pane
`(Pedigree Browser,"Bin Size")`→FALSE, wrong-content
`(Age-Sex Pyramid,"Focal Animals")`→FALSE (“Focal Animals” Pedigree-only
`modPedigree.R:52`, grep-confirmed foreign to Pyramid; “Bin Size”
Pyramid-only `modPyramid.R:31`), old whole-body
`grepl("Focal Animals",body)`→TRUE (content-blind contrast), active-pane
innerText grepl→FALSE (sanity). **\[regression-read\]** non-e2e **2162
passed / 0 failed / 0 error / 0 non-e2e offenders** (156 skipped, 5
pre-existing `modPyramid` warnings) — S40 baseline held EXACTLY; the
e2e-only change self-skips at `create_test_app()`
(`helper-shinytest2.R:196`). `tests/` `.lintr`-excluded; no `R/` change
→ no `document()`/NEWS (**\[news-vs-changelog\]** → CHANGELOG only).
Commit ONLY the 2 test files + docs via explicit `git add`
(**\[macos-dupe-scan\]** — `.DS_Store`/`..Rcheck/`/audit-html must NOT
ride along); `/tmp/mutation_check_8e2_pyramid.R` not committed. **8e-2
is now COMPLETE** (home-nav+app S38 + Input S39 + Pedigree S40 + Pyramid
S41); next is **8e-3** (genetic-value / breeding-groups / menu /
workflow), a SEPARATE session. **Reflexes:**
\[refactor-only\]\[author-decision\]\[mutation-check\]\[verify-first\]\[regression-read\]\[phase-3E-smoke\]\[news-vs-changelog\]\[macos-dupe-scan\]\[right-sized-orchestration\]\[completeness-workflow\].
**Apply:** in an active-pane conversion, decide NULL by ONE question —
“does ≥1 pattern alternative match DEFAULT-VISIBLE pane innerText?”; if
yes (even via incidental static text under an overclaiming test name),
KEEP the genuine regex verbatim (rescope only, flag the dragon in a
comment, never rename/retarget); NULL ONLY when nothing default-visible
satisfies a faithful pattern (a `req()`-gated output). A content-length
tautology with no regex still gets a real anchor when the pane has
unconditional guidance HTML. Run the pre-gate adversarial refutation
precisely because it can CORRECT your map, not just confirm it — its
value peaks when refutedCount\>0; adopt corrections, verify the critic
firsthand, then gate. Census the actual blocks; a predecessor’s
per-block anticipation is a hint, not a spec.

#### Learning 42 — Genetic-Value family run-and-observe conversion (8e-3 part B-1, FIRST 8e-3 cut): a tautology that has a DEAD computed grepl pattern → REVIVE that exact pattern rescoped (vs \#41’s fresh-anchor case); the pre-gate refutation NARROWS a revived pattern by pruning FOREIGN alternatives while keeping real-but-data-dependent ones; and a missing-`NOT_CRAN` regression read fakes a 40-pass “regression” (S42, Phase 8e-3 Genetic-Value family / issue \#40)

Converted the 3 Genetic-Value-family E2E files (`genetic-value-module` 7
/ `-detailed` 7 / `-tutorial` 8 = **22** browser-booting blocks) from
the content-blind `navigate_to_tab → grepl(get_html_safe(app,"body"))`
idiom to `assert_active_pane(app,"Genetic Value Analysis",<pattern>)`,
the FIRST 8e-3 cut. Same class as \#38–#41 — PURE **\[refactor-only\]**
run-and-observe (no defect; the GV pane already renders, “Genetic Value
Analysis” IS the `tabPanel` title `appUI.R:148` == the module h3
`modGeneticValue.R:32`), gated `PRE-RED→run-and-observe`
**\[author-decision\]**; **\[mutation-check\]** supplies the rigor (no
synthetic RED). Outcome: **16 keep-regex · 3 REVIVE · 1 ANCHOR · 2
NULL**. **(a) NEW sub-case — a tautology WITH a dead computed grepl
pattern → REVIVE that exact pattern, rescoped, NOT a fresh anchor
(#41(c) handled only `expect_true(TRUE)`/`nchar` tautologies with NO
surviving regex).** Three blocks read
`has_X <- grepl(PATTERN, html, ...)` then asserted `expect_true(TRUE)` —
the author WROTE the intended check but never asserted it. The most
faithful conversion revives PATTERN against the active pane: D3
`founder|equivalent|FE|genetic` (✓“founder” in guidance “rare founder
alleles” + “genetic” in h3), D6 `report|export|download|summary`
(✓“Export All/Subset” download buttons + “Summary” nested-tab label).
The remaining content-LENGTH tautology (D7 `nchar(html)>200`, no regex)
still gets a guidance ANCHOR (“ranks animals”, `genetic_value.html`) per
\#41(c). **(b) The pre-gate refutation NARROWS a revived pattern —
pruning FOREIGN alternatives while KEEPING real-but-data-dependent ones
— a distinct correction mode from \#40d/#41d’s NULL/un-NULL.** T8 (a
revived `focal|display|Show.*entries|search|filter`) was corrected to
just `filter`: four alternatives (focal/display/Show.\*entries/search)
are COPY-PASTE artifacts from another module’s test and appear NOWHERE
in the GV pane, while only “filter” matches default-visible text
(“Filter View”/“Filter by IDs”). Contrast D3/D6, whose non-matching
alternatives (founder-EQUIVALENTS, report) are REAL GV concepts rendered
WITH DATA in 8e-6 → keep verbatim (faithful to author intent). **Rule:
when reviving a dead multi-alternative pattern, KEEP alternatives that
are genuine pane concepts (default-visible now, or its own data-bearing
output later); DROP alternatives foreign to the module entirely.** A
genuine, already-passing grepl (the 16 keeps, incl. the 3 dragons
M4/D1/T4) stays VERBATIM regardless (#41b) — the prune applies only to
REVIVED dead patterns where you are authoring a new assertion. **(c) 2
NULL** (T5 “Value Designation”, T7 “Z-score”) — data-dependent results
concepts absent from static UI/guidance, no faithful default-visible
alternative → assert pane-active only, defer the data-bearing assertion
to 8e-6 (#40b/#41a). **(d) A regression read that OMITS `NOT_CRAN=true`
fakes a regression.** My first **\[regression-read\]** (no `NOT_CRAN`)
returned **2122 passed / 159 skipped** — a 40-pass DROP vs the 2162
baseline that looked alarming. But a test-tree-only edit to e2e files
(which self-skip at `create_test_app()` `helper-shinytest2.R:196`)
CANNOT lower non-e2e passes — that impossibility is the TELL. Cause:
without `NOT_CRAN=true`, ~40 NON-e2e unit tests with their own
`skip_on_cran()` guards silently skip (skip ≠ fail, so FAIL stayed 0 and
it masqueraded as a clean-but-smaller suite). Re-running `NOT_CRAN=true`
restored **2162 / 0 / 0 / 156-skip / 5-warn / 0 offenders** EXACTLY, and
the 3 GV files showed 0/0/0/22-skip (proving the edit innocent).
Reinforces **\[regression-read\]**: `NOT_CRAN=true` is mandatory, AND a
suspicious pass-count delta from an edit that provably can’t cause it is
a MEASUREMENT artifact — diagnose it firsthand (re-measure / reason
about the skip mechanism), never hand-wave or claim “baseline held” off
the wrong read. **(e) Family-per-session split extends to 8e-3
(owner-gated).** 8e-3 censused firsthand at **8 files / ~56 blocks**
(~3× an 8e-2 session, past the family boundary S38–S41 set); per the
plan §5 “may split if oversized” + don’t-bundle (FM \#18/#25) I posed a
pre-RED scope **\[author-decision\]** and the owner scoped THIS session
to the genetic-value family only (breeding-groups family +
settings-about/workflow deferred to follow-ons). Confirms \#38’s “split
an oversized conversion slice” at the next slice; the special
menu/workflow files (navbarMenu finalization of `navigate_to_menu_item`,
visit-N conversion) are distinct higher-value work that belongs in its
own cut. **(f)** Phase-3E / scope: test-tree-only → the browser run (22
blocks / 22 expectations, 1:1 swap net 0) + the live mutation-check
spike ARE the runtime (#31 pattern). **\[mutation-check\]** PASS,
INVERTED (Genetic Value Analysis is the TARGET pane) — correct
`(Genetic Value Analysis,"Run Analysis")`→TRUE, wrong-pane
`(Pedigree Browser,"Run Analysis")`→FALSE, wrong-content
`(Genetic Value Analysis,"Focal Animals")`→FALSE (“Focal Animals”
Pedigree-only `modPedigree.R:52`, grep-confirmed foreign to GV), old
whole-body `grepl("Focal Animals",body)`→TRUE (content-blind contrast),
active-pane innerText grepl→FALSE (sanity). `tests/` `.lintr`-excluded
(**\[lint-net-zero\]** N/A by config); no `R/` change → no
`document()`/NEWS (**\[news-vs-changelog\]** → CHANGELOG only). Commit
ONLY the 3 test files + docs via explicit `git add`
(**\[macos-dupe-scan\]** —
`.DS_Store`/`..Rcheck/`/`PED_GV_AUDIT_2026-05-30.html` must NOT ride
along); `/tmp/mutation_check_8e3_gv.R` not committed. Next 8e-3 cuts:
**breeding-groups family** (3 files, ~23) then **settings-about +
workflow-integration** (2 files, ~11 — finalize `navigate_to_menu_item`
as a true visible-pane check, kill the workflow visit-N false-positive).
**Reflexes:**
\[refactor-only\]\[author-decision\]\[mutation-check\]\[verify-first\]\[regression-read\]\[right-sized-orchestration\]\[completeness-workflow\]\[phase-3E-smoke\]\[news-vs-changelog\]\[macos-dupe-scan\]\[lint-net-zero\].
**Apply:** in an active-pane conversion, split by the OLD assertion’s
kind — a genuine passing grepl stays VERBATIM (rescope only, flag
dragons, never rename); a tautology that carries a DEAD computed grepl
pattern REVIVES that pattern rescoped (prune only alternatives FOREIGN
to the module, keep real-but-data-dependent ones); a
no-regex/content-length tautology gets a guidance anchor; NULL only when
nothing default-visible matches a faithful pattern. Always read the
regression with `NOT_CRAN=true`; if a test-only edit appears to drop the
pass count, suspect a missing `NOT_CRAN` (or another measurement
artifact) before suspecting a real regression — re-measure firsthand.
When a slice is ~3× a session, pose a pre-RED scope `AskUserQuestion`
and do one family.

#### Learning 43 — Breeding-Groups family run-and-observe conversion (8e-3 part B-2): a THIRD NULL sub-case — a STATIC feature that is present-but-in-an-inactive-NESTED-tab (`display:none`) → NULL+defer (vs \#39’s nonexistent-feature and \#40’s data-dependent `req()`-gate); nested-tab NAV labels ARE in active-pane innerText while their CONTENT is not; and `sum(nb)−sum(failed)` is NOT the passed count (S43, Phase 8e-3 Breeding-Groups family / issue \#40)

Converted the 3 Breeding-Groups-family E2E files
(`breeding-groups-module` 7 / `-detailed` 7 / `-tutorial` 9 = **23**
browser-booting blocks) from the content-blind
`navigate_to_tab → grepl(get_html_safe(app,"body"))` idiom to
`assert_active_pane(app,"Breeding Groups",<pattern>)`, the 2nd of three
8e-3 cuts. Same class as \#38–#42 — PURE **\[refactor-only\]**
run-and-observe (no defect; the BG pane already renders, “Breeding
Groups” IS the `tabPanel` title `appUI.R:166`), gated
`PRE-RED→run-and-observe` **\[author-decision\]**;
**\[mutation-check\]** supplies the rigor (no synthetic RED). Outcome:
**12 keep-regex · 6 REVIVE · 1 ANCHOR · 4 NULL**. **(a) A THIRD NULL
sub-case — a STATICALLY-PRESENT control that lives in an INACTIVE nested
tab (`display:none`) is not in the active-pane innerText →
NULL-pane-active + defer.** `modBreedingGroups` right column is a nested
`tabsetPanel` “Groups”(default)/“Statistics”/“Group Detail”; the export
`downloadButton`s “Export Current Group”/“Export Current Group Kinship
Matrix” (`modBreedingGroups.R:83-86`) are STATIC (not `req()`-gated) but
sit in the INACTIVE “Group Detail” nested tab → `innerText` (which
honors CSS visibility) excludes them, and the guidance HTML has no
export tokens. So D5/T7 (“export”) and T9 (“kinship matrix export”) have
no faithful default-visible match → NULL, deferred to 8e-6 / a
nested-tab-navigation enhancement. This is DISTINCT from \#39b (a
NONEXISTENT feature — T5 “infants with dam”: no such control in the
modular UI at all, tutorial-only) and \#40b (a DATA-DEPENDENT
`req()`-gated output). One family carried two different NULL reasons (T5
nonexistent; D5/T7/T9 present-but-nested-hidden) — both correctly
resolve to pane-active-only, but for different reasons worth recording:
the NULL test is still purely “does ≥1 faithful alternative match
DEFAULT-VISIBLE innerText?” (#41a), and “default-visible” excludes
inactive nested-tab content as firmly as it excludes a `req()`-gated
empty div. **(b) Nested-tab NAV labels ARE in the active-pane innerText
even though the inactive tabs’ CONTENT is not.** The nested
`<ul class="nav nav-tabs">` (labels “Groups”/“Statistics”/“Group
Detail”) is a descendant of the top-level BG `.tab-pane` and is always
visible, so M7 `statistic|summary|total` validly anchors on the
“Statistics” nav label and D4’s revived “group” matches the “Groups” nav
label — even though those tabs’ bodies are hidden. This was the one
genuinely uncertain point (M7’s ONLY matcher is that nav label — no
“statistic” in any sidebar control or the guidance); the pre-gate critic
settled it by RENDERING the actual Shiny
`navbarPage`+nested-`tabsetPanel` DOM via Rscript (a stronger firsthand
check than source-reasoning) and confirming the nav `<ul>` is in
`p.innerText`; the browser run then confirmed M7 GREEN. Lesson:
nested-tab NAV labels are usable static anchors; nested-tab CONTENT is
not (it is `display:none` when the tab is inactive) — the same
active-vs-inactive split \#39 found for the Input module’s nested tabs,
now stated as a general rule for a module whose named features hide
behind non-default nested tabs. **(c) REVIVE-pruning recurred (#42b)
with inputId artifacts as a named prune class.** 6
tautologies-with-dead-grepl revived: D2→`harem`,
D4→`result|group|table|output|formed` (keep all — “group” matches now,
rest are the data-dependent formed-group display → 8e-6),
T1→`group.*formation|source.*animal` (prune framing words
`workflow`/`Choose.*group`),
T4→`Seed.*Group|seed.*animal|specific.*animal` (prune `pre.*seed` + the
inputId `seedGroups`), T6→`Include.*kinship|kinship.*display` (prune the
inputId `showKinship` + the non-matching-order `display.*kinship`),
T8→`top.*ranked` (prune `high.*value`/`value.*animal` never-rendered +
the FOREIGN-module token `genetic.*analysis` — the GV pane). Prune
classes, all confirmed by the critic: inputId artifacts
(`seedGroups`/`showKinship`/`sexRatio` are attributes, NOT innerText),
never-rendered framing words, wrong-token-order `.*` alternatives, and
foreign-module tokens; KEEP the matching label + real-but-data-dependent
(#42a/b). A genuine passing grepl (the 12 keeps incl. the D1 dragon
`size|number|count|animals` — no “size” control, matches via
“number”/“animals”) stays VERBATIM, flagged in a comment, never renamed
(#41b). **(d) The pre-gate refutation CONFIRMED the whole map (0
corrections, like S40) yet still earned its keep — by RESOLVING a real
uncertainty, not just rubber-stamping.** Unlike S41/S42 (which corrected
2/12 and 1/22), here 0/23 changed — but the workflow’s value was
settling M7 firsthand (the DOM render) where my own confidence was
lowest, and dismissing two skeptic refutations that demanded NULL on the
false premise that nested nav labels are not in innerText. **Robust to
partial agent failure:** 2 of 3 skeptics hit stream-idle timeouts; the 1
complete skeptic + 1 partial (whose returned refutations the critic
still adjudicated) + the critic were sufficient — a
\[completeness-workflow\] degrades gracefully when the synthesizer
verifies firsthand rather than vote-counting. A 0-correction pre-gate is
NOT wasted when it converts a private low-confidence judgment (M7) into
a DOM-verified one before the slow 23-Chrome browser run. **(e)
`passed = sum(res$nb) − sum(res$failed)` is WRONG — refines
\[regression-read\].** My first read reported `passed=2323`, a +161 jump
over the S40–S42 baseline of 2162 — impossible for a test-only e2e edit
(the BG files self-skip), so per \#42d I diagnosed firsthand rather than
reporting a regression OR hand-waving “baseline held”. Cause: the `nb`
column counts skip and warning rows too — the canonical tally (counting
expectation classes directly: `expectation_success`=2162,
`expectation_skip`=156, `expectation_warning`=5; 2162+156+5=2323) shows
the true passed count is **`expectation_success`** (== the testthat
reporter’s `PASS` line), NOT `sum(nb)−sum(failed)`. The S40–S42 “2162”
was the canonical count; my formula was the artifact. Report passed via
`expectation_success` (or the reporter PASS line), never `sum(nb)`.
Baseline held EXACTLY: 2162 / 0 failed / 0 error / 156 skip / 5
pre-existing `modPyramid` warn / 0 non-e2e offenders. **(f)** Phase-3E /
scope: test-tree-only → the browser run (23 blocks / 23 expectations,
1:1 swap net 0) + the live mutation-check spike ARE the runtime (#31
pattern). **\[mutation-check\]** PASS, INVERTED (Breeding Groups is the
TARGET pane) — correct `(Breeding Groups,"Form Groups")`→TRUE,
wrong-pane `(Pedigree Browser,"Form Groups")`→FALSE, wrong-content
`(Breeding Groups,"Focal Animals")`→FALSE (“Focal Animals”
Pedigree/Input-only `modPedigree.R:52`/`modInput.R:114`, grep-confirmed
foreign to BG; “Form Groups” the BG actionButton
`modBreedingGroups.R:66`), old whole-body
`grepl("Focal Animals",body)`→TRUE (content-blind contrast), active-pane
innerText grepl→FALSE (sanity). `tests/` `.lintr`-excluded
(**\[lint-net-zero\]** N/A by config); no `R/` change → no
`document()`/NEWS (**\[news-vs-changelog\]** → CHANGELOG only). Commit
ONLY the 3 test files + docs via explicit `git add`
(**\[macos-dupe-scan\]** —
`.DS_Store`/`..Rcheck/`/`PED_GV_AUDIT_2026-05-30.html` must NOT ride
along; the `* 2.*` macOS dupes are all in `.Rproj.user/`, none in
`tests/`); `/tmp/mutation_check_8e3_bg.R` not committed. **8e-3 now 2/3
done** (genetic-value S42 + breeding-groups S43); the LAST 8e-3 cut =
**settings-about (4) + workflow-integration (7)** — NOT mechanical:
finalize `navigate_to_menu_item` as a true visible-pane check (resolve
the §8.3 navbarMenu false-positive, update its docstring
`helper-shinytest2.R:283-299`) + convert the workflow “visits N tabs”
loop to per-pane active assertions; a SEPARATE session (FM \#18/#25).
**Reflexes:**
\[refactor-only\]\[author-decision\]\[mutation-check\]\[verify-first\]\[regression-read\]\[right-sized-orchestration\]\[completeness-workflow\]\[phase-3E-smoke\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** in an active-pane conversion, NULL a block when nothing
DEFAULT-VISIBLE matches a faithful pattern — and “default-visible”
excludes BOTH `req()`-gated content AND a static control that lives in
an INACTIVE nested tab (`display:none`), distinct from a nonexistent
feature; all three resolve to pane-active-only + defer. Nested-tab NAV
labels (always visible) ARE usable anchors; nested-tab CONTENT is not.
When reviving a dead pattern, prune inputId artifacts / framing words /
wrong-order `.*` / foreign-module tokens, keep the matching label +
real-but-data-dependent. Report the regression passed count as
`expectation_success` (or the testthat PASS line), NEVER
`sum(nb)−sum(failed)` (`nb` includes skips+warnings). Run the pre-gate
refutation even expecting 0 corrections — its payoff can be resolving
ONE low-confidence judgment firsthand (render the actual DOM); it
degrades gracefully if some skeptics time out, provided the critic
verifies firsthand.

#### Learning 44 — Settings-About + Workflow-Integration conversion (8e-3 FINAL cut → 8e-3 COMPLETE): the navbarMenu(“More”) dragon is RESOLVED firsthand (a child DOES become the lone active top-level `.tab-pane` via `set_inputs(mainNavbar=child)`) → `navigate_to_menu_item` finalized as a genuine visible-pane check (docstring only, body unchanged); navbar CHROME (brand) is element-scopable (strictly stronger than the 8e-2 whole-body carve-out); and a “visits N tabs” count-loop tautology only discriminates when the threshold is raised to the FULL count (S44, Phase 8e-3 FINAL / issue \#40)

Converted the LAST two 8e-3 files — `test-e2e-settings-about.R` (4) +
`test-e2e-workflow-integration.R` (7) = **11** browser-booting blocks —
from the content-blind
`navigate_to_tab → grepl(get_html_safe(app,"body"))` idiom to
`assert_active_pane(...)`. Same class as \#38–#43 — PURE
**\[refactor-only\]** run-and-observe, gated `PRE-RED→run-and-observe`
**\[author-decision\]**; **\[mutation-check\]** supplies the rigor (no
synthetic RED). Outcome: **10 keep-regex-rescope · 1 navbar-chrome
carve-out**. **(a) The navbarMenu(“More”) dragon — flagged
R1/§2.3-item-4, deferred by 8e-1 (`[hard-gate-spike]` \#37 confirmed
only the input read-back) and carried as a 🐉 by S42/S43 — is RESOLVED
firsthand: a navbarMenu child DOES become the lone active top-level
`.tab-pane` via `set_inputs(mainNavbar=child)`.** A live-DOM spike
(Rscript→AppDriver) confirmed after
`navigate_to_menu_item(app,"Settings")`: top-level `.tab-content` count
== **1** (the children land in the SAME single container as the 8
top-level `tabPanel`s — no separate dropdown container),
`get_active_pane_value`==“Settings”,
`get_active_pane_text`==“Application Settings Configuration options will
go here”; idem About (version/credits/NIH) and Help
(Documentation/Online). So `navigate_to_menu_item`’s delegate body
(→`navigate_to_tab`’s `set_inputs`+read-back) was ALREADY a genuine
visible-pane switch — only its docstring’s “body-grepl passes regardless
of a true visible-pane switch (shallow-coverage limit … strengthened in
8e)” caveat needed retiring (`helper-shinytest2.R:283-292`; **body
unchanged → still PURE run-and-observe, NOT a helper RED→GREEN**). This
is `[hard-gate-spike]` in its CONFIRM mode (vs 8e-1’s FALSIFY): a spike
can validate the planned mechanism, not only break it — but you still
RUN it firsthand before the dependent conversions (rendering the DOM is
the strongest refutation when the load-bearing question is itself a DOM
behavior, which is why a separate source-reasoning skeptic panel — S43’s
pre-gate shape — was SUBSUMED here by the two live spikes). **(b) Navbar
CHROME (the brand/title) is element-scopable — a strictly STRONGER
choice than the 8e-2 whole-body carve-out — even though active-pane does
not apply to it.** The brand renders as
`<span class="navbar-brand">GeneKeepR</span>`, OUTSIDE any `.tab-pane`
(spike-confirmed `!document.querySelector('.tab-pane .navbar-brand')`),
so `assert_active_pane` correctly cannot reach it (same category as the
home-navigation navbar-LABEL carve-outs `:147-185` that 8e-2 left as
whole-body grepl). BUT unlike those labels, the brand has a stable class
→ scope the grepl to the element itself:
`grepl("GeneKeepR", get_html_safe(app, ".navbar-brand"))`.
**\[mutation-check\]**-proven strictly stronger:
`grepl("Breeding", brand)`==FALSE while the OLD
`grepl("Breeding", body)`==TRUE (whole-body was content-blind —
“GeneKeepR” also lives in the Home `<h1>` “Welcome to GeneKeepR” and the
About pane, so the old assertion passed even if the brand were removed).
Rule: a non-pane navbar element with a stable selector → scope to that
selector, don’t settle for a whole-body grepl carve-out. **(c) A “visits
N tabs” COUNT-LOOP tautology only becomes discriminating when the
threshold is raised to the FULL count.** Workflow W1 looped 6 panes
accumulating `tabs_visited` then asserted `>= 3` (with content-blind
whole-body grepls → always 6 → always passes). Converting each inner
check to `assert_active_pane` is necessary but NOT sufficient: with
`>= 3`, breaking ONE nav drops the count to 5 which STILL passes — the
mutation doesn’t bite. Raise the threshold to equal the count (`== 6L`)
so any single failed/wrong-pane nav reds the block (mutation-confirmed:
a wrong-pane `assert_active_pane`→FALSE → count 5 → `==6L` fails). This
is the one block that AGGREGATES many panes (vs the per-block 1:1 swaps
elsewhere); the discriminating lever is the THRESHOLD, not just the
inner predicate. **(d) GOTCHA — re-navigating to an ALREADY-ACTIVE tab
raises shinytest2’s “Server did not update any output values within 4
seconds”** (`set_inputs(mainNavbar=)` with default `wait_=TRUE` blocks
on an output flush that a no-op nav never produces). Harmless in the
real isolated blocks (each fresh app navigates Home→a DISTINCT tab, and
W1/W3’s sequences are all distinct-adjacent transitions → output always
updates), but it bit the FIRST diagnostic spike when I checked two
patterns for the same pane back-to-back. When spiking multiple checks
against one pane in a single app instance, sequence DISTINCT tabs
between reads (or pass `wait_=FALSE`); it is NOT a defect in the
converted tests. **(e)** W2/W3 were
[`is.list()`](https://rdrr.io/r/base/list.html) responsiveness
tautologies (no grepl) — strengthened to genuine pane-switch asserts
(Input-active-then-Home-active; final-pane-active after the 4-switch
loop), net-0 expectations, dropping the now-unused `get_values_safe()`
calls. The 8 remaining workflow patterns + the 4 settings patterns were
all genuine grepls → KEEP verbatim, rescope (every one
**\[verify-first\]**-confirmed against the real active-pane innerText in
spike v2: ALL_OK). **(f)** Phase-3E / scope: test-tree-only → the
browser run (11 blocks / 12 expectations — net 0 vs the old 12: settings
4 + workflow W1:1/W2:2/W3:1/W4:1/W5:1/W6:1/W7:1) + the two live DOM
spikes + the live mutation-check spike ARE the runtime (#31 pattern).
**\[regression-read\]** non-e2e **2162 `expectation_success` / 0 failed
/ 0 error / 156 skip / 5 pre-existing `modPyramid` warn / 0 non-e2e
offenders** — S40–S43 baseline held EXACTLY (read via
`sum(nb)−failed−skipped−warning`=2162, NOT `sum(nb)`=2323, per \#43e).
`tests/` `.lintr`-excluded (**\[lint-net-zero\]** N/A by config); helper
docstring is a TEST-tree roxygen comment, not an `R/` export → no
`document()`/NEWS (**\[news-vs-changelog\]** → CHANGELOG only). Commit
ONLY the 3 test-tree files + docs via explicit `git add`
(**\[macos-dupe-scan\]** —
`.DS_Store`/`..Rcheck/`/`PED_GV_AUDIT_2026-05-30.html` must NOT ride
along); spikes `/tmp/spike_navbarmenu_8e3.R`,
`/tmp/spike_workflow_patterns.R`, `/tmp/mutation_check_8e3_final.R` not
committed. **8e-3 is now COMPLETE** (genetic-value S42 + breeding-groups
S43 + settings-about/workflow S44); next is **8e-4** (namespace
`input-`→`dataInput-` fix + error-states/boundary-conditions interaction
revival — RED→GREEN for the ns fix, §2.4) — a SEPARATE session (FM
\#18/#25). **Reflexes:**
\[hard-gate-spike\]\[refactor-only\]\[author-decision\]\[mutation-check\]\[verify-first\]\[regression-read\]\[phase-3E-smoke\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** when a plan’s load-bearing assumption is a DOM behavior,
settle it by RENDERING the live DOM in a bounded spike BEFORE the
dependent conversions — a `[hard-gate-spike]` confirms-or-corrects, and
a live-DOM render subsumes a source-reasoning skeptic panel for a DOM
question. A `set_inputs(mainNavbar=child)` DOES activate a navbarMenu
child as the lone top-level `.tab-pane` (one `.tab-content`), so
`navigate_to_menu_item` is a genuine visible-pane check (docstring-only
finalization). Scope a non-pane navbar element (brand) to its own stable
selector, not a whole-body grepl. Convert a “visits N tabs” count-loop
by raising the threshold to the FULL count so a single failed nav reds
the block. Re-navigating to an already-active tab raises a 4s no-output
timeout — sequence distinct tabs when spiking same-pane checks in one
app instance.

#### Learning 45 — Namespace fix + error-states/boundary interaction revival (8e-4): the FIRST hybrid 8e slice (RED→GREEN namespace + run-and-observe conversions, two gates in one session); the namespace discriminator is the input VALUE READ-BACK, not a throw (shinytest2 `set_inputs` on an unbound id WARNS and never sets); a no-file `getData` click surfaces a TRANSIENT `showNotification` toast (the only pre-data error-state); a browser-free recording-stub anchors the helper fix in the always-run layer; and a concurrent external code-formatter rewrote 14 `R/` files mid-session — surfaced, owner-gated, verified inert, excluded from the commit (S45, Phase 8e-4 / issue \#40)

Converted `test-e2e-error-states.R` (13) +
`test-e2e-boundary-conditions.R` (13) = **26** browser-booting blocks
from the content-blind `nchar(html)>100` / dead-grepl /
`interaction-noop-tryCatch` idioms to behavioral assertions, and applied
the §2.4 namespace fix (`input-`→`dataInput-`) at all 5 sites + the
`upload_and_wait` helper. **(a) The FIRST 8e slice that is NOT pure
run-and-observe — a HYBRID: RED→GREEN for the namespace fix (4 tests) +
run-and-observe for the 23 conversions, both gated (`PRE-RED→RED` then
`RED→GREEN`, two `[author-decision]` gates).** Sites per §2.4
(`helper-shinytest2.R:150`/`:154`, `error-states:24`/`:45`,
`boundary:43`); the §2.4 DO-NOT-CHANGE list (data-ready bare ids, the
`data-module="input"` literal, `#goto_input`, tab anchors
`a[data-value=]`) respected. **(b) The namespace discriminator is the
input VALUE READ-BACK, not an exception.** Contrary to the plan’s “wrong
id throws” framing, shinytest2
`set_inputs(\`input-minParentAge\`=…)`on an UNBOUND id emits a WARNING ("Unable to find input binding") and **does not set anything** (and does not raise an R error) — so the wrong-id RED is proven by`get_value(input=“dataInput-minParentAge”)`staying at the default "2.0" ≠ the set value, NOT by a`tryCatch`-caught throw. The CLICK path differs:`app\$click(selector="#input-getData")\`
on a missing selector THROWS ("Cannot find HTML element") →
\`click_element_safe\`→FALSE → \`expect_true\` fails. One slice, two
distinct namespace discriminators (textInput → read-back; actionButton
click → throw→FALSE). \*\*(c) A no-file \`getData\` click surfaces a
TRANSIENT \`showNotification\` warning toast — the ONLY error-state
available pre-data.\*\* \`modInput.R:305-308\`
\`observeEvent(getData)\`: \`if (is.null(activeFile())) {
showNotification("Please select a file first.", type="warning");
return() }\`. A \`\[verify-first\]\` spike confirmed the toast renders
into \`#shiny-notification-panel\` and is readable right after \`click +
wait_for_idle\` (before its ~5s auto-dismiss). Crucially the
zero/non-numeric-age blocks WITHOUT a file surface NO error —
\`minParentAge\` is a \`textInput\` accepting any string (\`get_value\`
reflects "0"/"abc"); the \`as.numeric()\` coercion only fires inside the
never-reached (no-file) handler. So the genuine assertions there are the
\*\*input round-trip + pane-active\*\*, NOT an "error-state" (refines
the plan's "surfaces a visible error/state" — true only for the no-file
click). \*\*(d) A browser-free recording-stub anchors the helper
namespace fix in the ALWAYS-RUN layer.\*\* The e2e blocks self-skip
without \`NPRC_RUN_E2E\`, and \`upload_and_wait\` is exercised by no
8e-4 test (it serves 8e-6's real upload) — so its RED→GREEN is a
recording fake-app stub in \`test_helper_shinytest2.R\` (mirrors 8a's
stub idiom) asserting it uploads to \`dataInput-pedigreeFileOne\` and
clicks \`dataInput-getData\`; RED = hardcoded
\`input-pedigreeFileOne\` + default \`module_id="input"\`, GREEN =
default \`"dataInput"\` + DERIVE the upload id via
\`do.call(app\$upload_file, setNames(list(file_path), sprintf(“%s-%s”,
module_id,
file_input_id)))`. +4 always-run expectations (2162→2166) protect the fix even when the browser suite is opted out. **(e) ZERO blocks deferred to 8e-6 — the plan's "some boundary blocks need data → defer" did not materialize.** Every pane's CONTROL labels are static (present without data) and all 26 patterns`\[verify-first\]`-confirmed against real active-pane innerText (every spike cell TRUE): Input (`Minimum
Parent Age`/`Read and Check Pedigree`), Pedigree (`Focal
Animals`/`Display Options`/`search`), Pyramid (`Bin Size`/`Age
Unit`/`Age Label`), GV (`Run Analysis`/`Iterations`/`Threshold`/`Export
All`/`Export Subset`), BG (`Form Groups`/`Number of groups`/`Sex
ratio`/`Harem`), Home (`Welcome`/`GeneKeepR`). The two rapid/repeat-click blocks assert the FINAL pane (Home / Input); the narrow/short-window blocks assert Home active on BOOT (no nav). **(f) ⚠ A concurrent external code-formatter rewrote 14`R/`PRODUCTION files mid-session — surfaced, owner-gated, verified inert, EXCLUDED from the commit (FM #22 in the wild).** Orientation showed a clean tree (only`.DS_Store`); minutes later`pkgload::load_all`FAILED (`\[verify-first\]`caught it) on a parse error in`makeFounderStatsTable.R:68`— an automated style pass (`‘…’`→`“…”`,`0`→`0L`,`round(x,2)`→`round(x,2L)`; likely an editor format-on-save /`styler`/ another agent on the open #30 lint work) converted single-quoted HTML strings to double quotes WITHOUT escaping the inner`class=“…”`, closing the literal early. The modified set was actively GROWING (11→13→15→17 tracked files across read-only polls) → the tool was running CONCURRENTLY. Per SAFEGUARDS (preserve user edits) / FM #22 I did NOT touch, revert, or "fix" the unauthored uncommitted changes — STOPPED and gated with the owner (`AskUserQuestion`). By the next poll the formatter had SELF-HEALED the 2 broken files (a later pass rewrote them valid) and settled at 17;`\[regression-read\]`then proved the whole reformat behaviorally inert (non-e2e **2166`expectation_success`/ 0 failed / 0 error / 156 skip / 5 pre-existing`modPyramid`warn / 0 non-e2e offenders** — the S40–S44 baseline + exactly the +4 new helper expectations). The 8e-4 commit staged ONLY the 4 test-tree files + docs via explicit`git
add`, leaving the owner's 14-file reformat as their uncommitted in-progress work (`\[macos-dupe-scan\]`also excluded`.DS_Store`/`..Rcheck/`/`PED_GV_AUDIT_2026-05-30.html`). Lesson: a non-parsing tree at the START of code work is not always YOUR breakage or a stale checkout — in an AI/tooling-heavy repo a formatter may run concurrently; verify firsthand (`load_all`+ parse-check +`git
status`growth), and if the changes are unauthored + uncommitted, SURFACE + gate, never silently fix or revert. **(g)** Phase-3E / scope: test-tree-only → the browser run (26 blocks / 29 expectations, 0 failed/0 error/0 skip) + the two live spikes (DOM/namespace + mutation-check) ARE the runtime (#31). **[mutation-check]** PASS:`assert_active_pane(GV,“Export
All\|Export Subset”)`→TRUE, wrong-pane`(Breeding
Groups,…)`→FALSE, wrong-content`(GV,“Number of
groups”)`→FALSE ("Number of groups" BG-only, grep-confirmed foreign to GV), OLD whole-body`grepl(“Number
of groups”,
body)`→TRUE (content-blind contrast), active-pane innerText grepl→FALSE (sanity); namespace`dataInput-minParentAge`reflects "0", click`\#dataInput-getData`→notification, wrong selector`\#input-getData`→`click_element_safe`→FALSE.`tests/.lintr`-excluded (**[lint-net-zero]** N/A); no`R/`change by ME → no`document()`/NEWS (**[news-vs-changelog]** → CHANGELOG only). Next is **8e-5** (⚠ PRODUCTION`R/`gated`set_seed`— own owner-gated full RED→GREEN→REFACTOR+`check()`, [production-in-disguise]) or **8e-6** (real upload+QC/GVA/breeding flows + the deferred data-bearing asserts; 8e-4 is its prerequisite — the`dataInput-`ids are now correct). **Reflexes:** [hard-gate-spike][verify-first][mutation-check][regression-read][author-decision][phase-3E-smoke][news-vs-changelog][macos-dupe-scan]. **Apply:** a hybrid 8e slice gates twice (PRE-RED→RED for the failing namespace tests, then RED→GREEN). For a namespaced textInput the wrong-id discriminator is the`get_value`read-back (shinytest2 WARNS, never sets — does NOT throw); for an actionButton it is the`app\$click`throw. Anchor a helper's namespace fix in a browser-free recording-stub unit test (the e2e layer self-skips). Convert a pre-data block to`assert_active_pane`against a STATIC control label, not data-bearing content. If`load_all`fails at the start of code work with unauthored uncommitted`R/`edits that are still growing, a formatter is running concurrently — surface + owner-gate, verify inert via the regression, and commit only your own files via explicit`git
add\`; never revert or silently fix someone else’s in-progress work.

#### Learning 46 — Stochastic determinism hook (8e-5): the \[production-in-disguise\] item EXECUTED — an env/option-gated `set_seed()` added to two EXPORTED module servers via owner-gated full RED→GREEN→REFACTOR; the determinism RED compares a stochastic engine’s output across TWO `testServer` runs (RNG carries across invocations) guarded against a vacuous `identical(NULL,NULL)`; committing a concurrent formatter’s reformat DESYNCS `man/` (it rewrapped `#'` comments + changed signature defaults to `8L`) so run `document()` before `check()`; and the new cross-file helper’s `object_usage_linter` flag is a \[stale-namespace\] transient (S46, Phase 8e-5 / issue \#40)

The slice flagged by \#35 \[production-in-disguise\] as the ONE
issue-#40 item that needs a real `R/` change is now DONE: an
**env/option-gated
[`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)
hook** added at the top of `gvResults`’s and `breedingGroups`’s
`eventReactive` bodies (immediately after `req()`, ahead of
`withProgress`, so no intervening RNG is consumed before the engine
call) —
`seed <- getOption("nprcgenekeepr.gva_seed", as.integer(Sys.getenv("NPRC_GVA_SEED", NA))); if (!is.na(seed)) set_seed(seed)`
(and `nprcgenekeepr.bg_seed`/`NPRC_BG_SEED`), using the existing
**exported**
[`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)
(pins `sample.kind="Rounding"`). **(a) Owner-gated approach choice +
full TDD** — a pre-RED `[author-decision]` `AskUserQuestion` chose
**Option A** (env/option gate) over Option B (a user-facing
`numericInput` “reproducible mode”) and Option C-only (no production
change, structural invariants in 8e-6); then **three gated transitions**
(PRE-RED→RED, RED→GREEN, GREEN→REFACTOR), each its own `AskUserQuestion`
per the contract. This is the first 8e slice with a true `R/`
RED→GREEN→REFACTOR (8e-4 was a hybrid; 8e-2/8e-3 were run-and-observe).
**(b) The determinism RED is `[discriminating-RED]` over a STOCHASTIC
consumer across TWO `testServer` invocations.** `set_seed`-determinism
cannot be observed in one run; the RED sets the option then runs
`testServer(modGeneticValueServer, …)` TWICE in one test, capturing
`gvResults()[order(id),"gu"]` each time via `<<-` (the
directly-stochastic `gu` from `geneDrop`→`sample`; the `rank` column is
`seq_len(n)` by construction → useless as a discriminator), and asserts
`expect_identical(guA, guB)`. It FAILS at HEAD because R’s global RNG
STATE CARRIES OVER between the two sequential `testServer` runs (no
per-run reseed) → unseeded `gu` differs run-to-run; the gated seed makes
both runs reseed identically → identical. **⚠ Guard against a vacuous
pass:** if the `<<-` capture silently failed (NULL),
`identical(NULL,NULL)` would PASS and fake a green RED — so each
determinism test FIRST asserts `expect_true(length(guA) > 0L)`; at HEAD
that passes (capture works) while the `identical` fails, proving the RED
is real, not vacuous (extends `[identical-proof]`/`[discriminating-RED]`
to a stochastic-output comparison — cf. #18’s “seeded `reportGV`
byte-identical” but here the SEED ITSELF is the thing under test).
Breeding mirrors it on `session$getReturned()$groups()`. **(c) The gate
MECHANISM is pinned by a `set_seed` MOCK** (`[testServer-mechanics]`):
`local_mocked_bindings(set_seed = function(seed=1L){recorder$called<-TRUE; recorder$seed<-seed})`
(no `.package` arg — matches `test-set_seed.R`; patches the namespace
binding so the BARE-NAME call nested in `moduleServer`→`eventReactive`
resolves the mock) proves “called once with the option value” (RED at
HEAD — never called) and the env-fallback “`NPRC_GVA_SEED` read when the
option is absent → called with `7L`” (RED at HEAD); the default-path
**guard** “option+env unset → NOT called” is green-on-arrival (a
regression guard, honestly classified — not RED). Net 8 tests = 6
genuine RED + 2 guards; RED confirmed firsthand BEFORE GREEN (no
synthetic RED). **(d) REFACTOR** factored the duplicated 3-line gate
into one `@noRd` helper `gatedSeed(optionName, envName)` in
`R/set_seed.R`; structure-only, no new tests, `[document-zero-delta]`
held (`@noRd` ⇒ no NAMESPACE/man delta for MY change). **(e) ⚠
Committing a concurrent formatter’s reformat DESYNCS `man/` — run
`document()` BEFORE `check()`.** S45’s reformat (committed here as the
clean baseline `d0989408` on owner request, re-verified inert at 2166
via `[regression-read]`) had ALSO rewrapped `#'` roxygen comments AND
changed `savePlotToFile`’s formals defaults to integer
(`width=8L/height=6L/dpi=150L`) — so `document()` regenerated 3 man
files (`appServer`, `modSummaryStatsServer`, `savePlotToFile`); the
`savePlotToFile` `\usage` `8`→`8L` is a real **codoc** drift that
`R CMD check` WOULD have flagged as a WARNING. This is a
`[deletion-namespace-fallout]` COUSIN in reverse: a source change (here
a reformat, not a deletion) silently desyncs a GENERATED artifact
(`man/`) that a content grep cannot see — the tell was `git status`
showing `man/` deltas after `document()`, NOT after the reformat commit.
Attribution confirmed firsthand: roxygen versions match (7.3.2 = 7.3.2),
and
`git show d0989408 -- R/appServer.R R/modSummaryStats.R | grep "^[+-]#'"`
proved the reformat rewrapped the `#'` comments → all 3 man changes are
reformat consequences → committed as a SEPARATE `docs:` commit
(causality explicit), distinct from the 8e-5 commit. Reflex: after
committing ANY reformat that touches `R/`, run `document()` and diff
`man/`+`NAMESPACE` before `check()` — a code formatter can edit roxygen
comments and signature defaults. **(f) The new helper’s
`object_usage_linter` “no visible global function definition for
‘gatedSeed’” is a `[stale-namespace]` transient** — single-file `lint()`
(and the INSTALLED namespace, which lacks the just-added helper) can’t
resolve a cross-file package-internal function; `devtools::check()`
(builds from source, full namespace) emitted NO such NOTE, confirming it
(per the `[stale-namespace]` rule: “a new cross-file helper’s
`object_usage_linter` … is a stale-namespace transient”). **(g)**
`[phase-3E-smoke]`:
[`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
from WORKING-TREE source (`load_all`, so `gatedSeed`+hooks active)
serves HTTP 200 on the default gate-unset path. `[regression-read]`
**2180 `expectation_success` / 0 failed / 0 error / 156 skip / 5
pre-existing `modPyramid` warn / 0 non-e2e offenders** (= 2166
baseline + 14 new; default path unchanged — gate-unset regression IS the
R2 risk mitigation). `[news-vs-changelog]` → CHANGELOG only (gate no-op
by default ⇒ no analytical numeric change ⇒ no NEWS).
`[macos-dupe-scan]` commit hygiene: explicit `git add` excludes
`.DS_Store`/`..Rcheck/`/`PED_GV_AUDIT_2026-05-30.html`. Next is **8e-6**
(real upload+QC/GVA/breeding flows; 8e-5 now enables OPTIONAL
exact-value assertions via `withr::local_envvar(NPRC_GVA_SEED=…)` around
`AppDriver$new()`, but Option-C structural invariants are usable
regardless) or **8e-7** (CI per-module fresh-process grouping,
orthogonal). **Reflexes:**
\[production-in-disguise\]\[author-decision\]\[verify-first\]\[discriminating-RED\]\[testServer-mechanics\]\[identical-proof\]\[regression-read\]\[document-zero-delta\]\[deletion-namespace-fallout\]\[stale-namespace\]\[phase-3E-smoke\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** isolate a determinism/reproducibility hook into its own
owner-gated full RED→GREEN→REFACTOR + `check()` slice
(\[production-in-disguise\]); gate the seed via
`getOption(opt, as.integer(Sys.getenv(env, NA)))` at the top of the
engine’s `eventReactive` (no-op when unset). RED a
stochastic-determinism property by comparing the engine’s output across
two `testServer` runs in one process (RNG carries over) + a `length>0`
non-vacuous-capture guard; pin the mechanism with a
`local_mocked_bindings(set_seed=…)` call-recorder. After committing a
reformat that touched `R/`, run `document()` + diff `man/`/`NAMESPACE`
before `check()` — a formatter can rewrap `#'` comments and change
signature defaults (`8`→`8L`), desyncing generated docs (codoc WARNING)
that no content grep catches; commit the regen separately with explicit
causality. A new cross-file helper’s `object_usage_linter` flag is a
stale-namespace artifact — confirm via `check()`, don’t “fix” it.

#### Learning 47 — Real upload→pedigree E2E flow (8e-6a): the FIRST genuinely data-bearing E2E assertions in the suite; the `[hard-gate-spike]` CORRECTED the plan’s §2.3 “output tier” (`get_value(output=DT)` un-suspends to non-NULL WITHOUT data → assert rendered-DOM content, not `is.null`); and a local e2e spike tests the SYSTEM-lib install, not the working tree, unless reinstalled first (S47, Phase 8e-6a / issue \#40)

8e-6a wired the real pipeline
`upload_and_wait(app, obfuscated_rhesus_mhc_ped.csv) → #dataInput-getData → navigate_to_tab("Pedigree Browser")`
and converted the 3 NULL’d pedigree blocks from S40 (A1
`test-e2e-pedigree-module.R`, A2 `-detailed.R`, A3 `-tutorial.R`) from
pane-active-only into **data-bearing** asserts on the rendered
`#pedigree-pedigreeTable` — the first time the E2E suite drives a real
analytical flow (recon `[completeness-workflow]` `wf_855f37cd-4ac`
confirmed NOTHING clicks `runAnalysis`/`formGroups`/uploads today →
genuine RED→GREEN). **(a) The `[hard-gate-spike]` CORRECTED the plan,
didn’t just confirm it.** Plan §2.3’s “output tier” said
`get_value(output=)` is empty for a hidden tab via `suspendWhenHidden`,
implying `!is.null(get_value(…))` is a data check. Firsthand: the
pedigree DToutput is NULL only while SUSPENDED (tab hidden); the instant
`navigate_to_tab` activates the tab it UN-SUSPENDS to a non-NULL `json`
atomic string EVEN with no studbook (`req(pedigreeData())` unmet → empty
`visibility:hidden` div). So `is.null(get_value)` discriminates
SUSPENSION, not DATA → dropped it mid-RED and asserted RENDERED-DOM
content via `get_html_safe(app, "#pedigree-pedigreeTable")` (→ new
reflex `[output-dom-discriminator]`). **(b) Spike sequence** (mirrors
8e-1): a standalone `AppDriver` Rscript proved (G4) the helper-default
`pedFile`/`pedigreeFileOne` upload of the canonical CSV flips
`dataInput` ready + QC clean; (G5) the output renders 375 rows only
AFTER the nav → driver order is upload→nav→assert; (G2) the DT
`get_value` shape is `json` (atomic, `$`-unindexable). A second
micro-spike (loading the REAL `helper-shinytest2.R` via `sys.source`, so
`assert_active_pane` reports `Pedigree Browser` correctly) captured
exact strings: thead
`id sire dam sex gen birth exit age recordStatus population pedNum`,
info `Showing 1 to 15 of 375 entries`, length menu
`Show 10 15 25 50 100 entries`. **(c) `[discriminating-RED]` +
`[mutation-check]`:** RED proven firsthand (no upload → empty hidden div
→ every `expect_match` fails); a mutation spike then confirmed the
assertions REJECT wrong content (`"of 999 entries"`, off-by-one
`"of 374 entries"`, foreign column `genotype`, foreign-pane
`Breeding Groups`, same pattern on `#pedigree-exportPedigree`) while
ACCEPTING the real 375/sire/dam/length-menu → data-specific, not “any
non-empty”. **(d) `[e2e-subprocess-lib]` (NEW):** the AppDriver
subprocess resolves the package from the SYSTEM lib under
`RENV_CONFIG_AUTOLOADER_ENABLED=false`, and that install was Jul-2025
stale → reinstalled current source there before spiking, else the spike
tests phantom behavior. **(e) Assertions:** A1 `"of 375 entries"` +
`"sire"`; A2 + `"dam"`; A3 `"dataTables_length"` (Show-N-entries menu) +
`"of 375 entries"`. A4 (“status filter”) left honest pane-active — no
filter CONTROL exists (only a rendered `recordStatus` COLUMN, a future
data-bearing option). **(f) `[refactor-only]` REFACTOR DECLINED:** the
3-line `system.file→upload_and_wait→skip` driver is idiomatic with these
files’ inline setup (each block already inlines
`create_test_app`/`create_app_driver`/`navigate`); factoring only the
upload would be inconsistent + scope creep. **(g)** `[regression-read]`
**2180 `expectation_success` / 0 failed / 0 error / 156 skip / 5
`modPyramid` warn / 0 non-e2e offenders** (S46 baseline EXACT; test-only
— e2e self-skips without `NPRC_RUN_E2E`); `[phase-3E-smoke]` = the live
GREEN AppDriver run (real pipeline) IS the runtime (#31);
`[news-vs-changelog]` → CHANGELOG only; `[macos-dupe-scan]` explicit
`git add`. Owner-gated 4 `AskUserQuestion`s (\[author-decision\]:
scope→8e-6a, PRE-RED→RED, RED→GREEN, REFACTOR-declined). **(h)** The
recon critic caught 3 census errors that would have produced a wrong RED
for 8e-6b/c: DT `value` levels are
`"High Value"/"Low Value"/"Undetermined"` (not High/Low), the module
`breedingGroups()` length is `∈ {numGp, numGp+1}` (`filterValidGroups`
drops the empty leftover — not a hard +1), and the strict within-group
kinship invariant is unattainable (module hardcodes `ignore=F–F`).
**Reflexes:**
\[hard-gate-spike\]\[output-dom-discriminator\]\[e2e-subprocess-lib\]\[discriminating-RED\]\[mutation-check\]\[verify-first\]\[author-decision\]\[refactor-only\]\[regression-read\]\[phase-3E-smoke\]\[news-vs-changelog\]\[macos-dupe-scan\]\[completeness-workflow\].
**Apply:** for a real-pipeline E2E flow — run the `[hard-gate-spike]`
live (boot→upload→nav→inspect) BEFORE any RED and let it correct plan
assumptions; assert rendered-DOM CONTENT (`get_html_safe`
row-count/headers/length-menu), NOT `is.null(get_value(output=DT))`
(which only proves un-suspension); reinstall current source into the
SYSTEM lib first (\[e2e-subprocess-lib\]); prove the content assertions
reject WRONG values via a mutation spike; drive the upload BEFORE
navigating (suspendWhenHidden renders only on tab-activation).

#### Learning 48 — Real GVA-run E2E flow (8e-6b): the rankings DT’s `value` column is real but arrives via `orderReport()`→`rankSubjects()`→`rbind` (NOT reportGV’s `cbind` — trace column PROVENANCE), and the default `topN=20` render truncates to the top-ranked rows so only “High Value” survives (asserting “Low Value”/“Undetermined” would RED a green flow); both data-bearing tokens are seed-INDEPENDENT structural invariants (S48, Phase 8e-6b / issue \#40)

8e-6b drove the real GVA pipeline
`upload_and_wait(app, obfuscated_rhesus_mhc_ped.csv) → navigate_to_tab("Genetic Value Analysis") → set nIterations=100 → click_element_safe("#geneticValue-runAnalysis") → wait_for_module_ready("geneticValue")`
and converted the 2 NULL’d GV blocks from S42 (B1
`test-e2e-genetic-value-tutorial.R:99` Value Designation, B2 `:144`
Z-score) from pane-active-only into **data-bearing** asserts on the
rendered `#geneticValue-rankingsTable` — the second real-flow slice
after 8e-6a. **(a) `[output-dom-discriminator]` column-provenance
correction.** A static read of `reportGV.R:144`
(`finalData <- cbind(demographics, indivMeanKin, zScores, gu, offspring)`)
shows NO `value` column and would have produced a wrong assertion — but
`reportGV.R:146` wraps it as `report = orderReport(finalData, ped)`, and
`orderReport()` splits the frame into sublists, calls
[`rankSubjects()`](https://github.com/rmsharp/nprcgenekeepr/reference/rankSubjects.md)
(which ADDS the `value` “High/Low/Undetermined” + `rank` columns,
`rankSubjects.R:36-46`), then `do.call("rbind", …)` re-flattens to one
frame. So the rendered DT carries `value` AND `zScores` after all — the
recon critic was right; the naive `cbind`-only read was the trap.
**Trace a rendered column’s provenance through the WHOLE pipeline; a
`cbind` site is not the last word when a later `orderReport`/`rbind`
adds columns.** **(b) NEW `[topN-truncation]`: row-truncation hides the
lower designations.** `output$rankingsTable` truncates to `input$topN`
(default 20) via `data[1:input$topN, ]` (`modGeneticValue.R:240`), and
the module re-orders by `rank(indivMeanKin − gu)` ascending so the
top-20 are the BEST animals → all “High Value”. The firsthand spike
confirmed the render shows `"of 20 entries"` with `"High Value"` TRUE
but `"Low Value"`/`"Undetermined"` FALSE. ⟹ in the DEFAULT view the ONLY
faithful Value-designation token is `"High Value"`; asserting “Low
Value”/“Undetermined” would RED a green flow (or you must raise `topN`).
This refines S47’s recon note (“levels are High/Low/Undetermined”): all
three exist in the full report, but only High Value survives the default
top-N render. **(c) `[hard-gate-spike]` + `[discriminating-RED]`:** the
live spike proved RED firsthand (post-upload, post-nav, PRE-run the
output is an empty `visibility:hidden` div → “High Value”/“zScores” both
FALSE) then GREEN (after click+wait the DT renders, both TRUE; headers
`… indivMeanKin zScores gu … value rank`). The `gvResults` eventReactive
sends `setDataReady` on `#geneticValue-moduleContainer` only when a
downstream consumer reads it — the default-visible Rankings inner tab’s
`rankingsTable` reads `gvaView()→gvResults()` on the click, so
`wait_for_module_ready("geneticValue")` is the correct barrier (no
inner-tabset switch needed; Summary/Visualizations stay
`suspendWhenHidden`). **(d) `[mutation-check]`:** correct
`"High Value"`/`"zScores"`→TRUE; wrong designation
`"Low Value"`/`"Undetermined"` (truncated away)→FALSE; foreign-pane
`"Form Groups"` (BG)/`"Focal Animals"` (Ped)→FALSE — data-specific, not
“any non-empty”. **(e) `[seed-independent-structural]` (Option C):** ran
GREEN with NO `NPRC_GVA_SEED` — both tokens are structural invariants
(`zScores` is a fixed column header; “High Value” is guaranteed for the
top-ranked rows regardless of the gene-drop RNG), so the assertions need
neither the 8e-5 seed hook nor value-stable RNG. **(f)
`[e2e-subprocess-lib]` no-op this session:** the SYSTEM-lib install was
already current (`gatedSeed` present, v1.1.0.9000) because `R/` was
unchanged since S47’s reinstall → verified currency firsthand, did NOT
reinstall (the reflex’s ACTION is conditional on `R/` having changed
since the last install; the CHECK is unconditional). **(g)
`[refactor-only]` REFACTOR DECLINED** (owner-gated): the ~6-line
upload→nav→run flow duplicates across B1/B2, but a reusable GVA-run
helper belongs in `helper-shinytest2.R` co-designed with 8e-6c (the
breeding flow has the analogous run-and-render shape) — premature here,
and a file-local helper would break the suite’s self-contained
inline-setup style. **(h)** `[regression-read]` **2180
`expectation_success` / 0 failed / 0 error / 156 skip / 5 `modPyramid`
warn / 0 non-e2e offenders** (S47 baseline EXACT; test-only — the file
self-skips without `NPRC_RUN_E2E`); `[phase-3E-smoke]` = the live GREEN
AppDriver run + the mutation spike ARE the runtime (#31);
`[news-vs-changelog]` → CHANGELOG only; test-tree-only → no
`document()`, `tests/` lint-exempt; `[macos-dupe-scan]` explicit
`git add`. Owner-gated 3 `AskUserQuestion` phase gates
(\[author-decision\]: PRE-RED→RED, RED→GREEN, GREEN→REFACTOR-declined;
scope was fixed by the user’s “8e-6b” instruction, not re-asked).
**Reflexes:**
\[hard-gate-spike\]\[output-dom-discriminator\]\[topN-truncation\]\[discriminating-RED\]\[mutation-check\]\[seed-independent-structural\]\[e2e-subprocess-lib\]\[refactor-only\]\[regression-read\]\[phase-3E-smoke\]\[author-decision\].
**Apply:** when asserting a rendered DT column/cell, trace the column’s
PROVENANCE through the whole pipeline (a `cbind` site may not be the
last word — a later `orderReport`/`rbind` can add columns) AND account
for any row-truncation (`topN`) that hides values present in the full
data; prefer tokens that survive the DEFAULT render and are
RNG-invariant (column headers, top-rank designations) so the assertion
needs no seed.

#### Learning 49 — Real breeding-group E2E flow (8e-6c → 8e-6 COMPLETE): the export buttons + rendered Group-Detail tables live in a NO-`id` nested tabset reached only by a DOM click on `a[data-value='Group Detail']`; make a static-UI button data-bearing by PAIRING its visibility-gated LABEL with a `suspendWhenHidden` DT so each block needs the full flow (not just nested-tab nav); `animalSource='all'` isolates breeding from GVA; and the non-e2e baseline is MEASUREMENT-method-sensitive → prove edit-inertness with a stash diff, not the headline count (S49, Phase 8e-6c / issue \#40)

8e-6c drove the real breeding pipeline
`upload_and_wait(app, obfuscated_rhesus_mhc_ped.csv) → navigate_to_tab("Breeding Groups") → set_inputs(animalSource="all", nIterations=5) → click_element_safe("#breedingGroups-formGroups") → wait_for_module_ready("breedingGroups") → click_element_safe("a[data-value='Group Detail']")`
and revived the 3 export-NULL’d BG blocks from S43 (D5
`test-e2e-breeding-groups-detailed.R:89`, T7 `-tutorial.R:135`, T9
`-tutorial.R:178`) into data-bearing asserts under RED→GREEN (3
`AskUserQuestion` gates: PRE-RED→RED · RED→GREEN ·
GREEN→REFACTOR-declined; scope fixed by the owner’s “8e-6c”). **(a)
\[hard-gate-spike\] captured the recon’s two OPEN items firsthand.** The
Group Detail nested `tabsetPanel` (`modBreedingGroups.R:72`) has **NO
`id`** → `set_inputs` cannot drive it → activate via the UNIQUE DOM link
`a[data-value='Group Detail']` (spike: `count==1`),
`click_element_safe → TRUE`. This CLOSES the Learning \#43 loop: \#43
found a nested tab’s CONTENT is `display:none`-excluded from active-pane
innerText while its NAV LABEL is included; \#49’s fix is to CLICK the
nav link, after which the nested pane becomes visible and its content
enters the TOP-LEVEL active pane’s innerText (`assert_active_pane`
resolves the only non-nested `.tab-content`, whose innerText now carries
the activated nested pane). The intermediate spike state PROVED both
steps are needed: post-formation but pre-activation,
`Ego ID`/`Export Current Group` are still FALSE. **(b) Make a STATIC-UI
button data-bearing by PAIRING.** The `downloadButton`s are static UI —
present in the DOM always, just `display:none` in the inactive nested
tab — so `get_html` on the button id would match “Export Current Group”
even in RED (a trap, the \#43 reason these were NULL’d). So assert the
button LABEL via active-pane innerText (visibility-gated: absent until
the nested tab is activated) AND pair it with the `suspendWhenHidden`
rendered DT (`#breedingGroups-groupMemberTable` → “Ego ID”/“Age in
Years”; `#breedingGroups-groupKinTable` → `<table>`), which needs BOTH
group formation AND tab visibility → each block genuinely requires the
full upload→form→activate flow, not merely nested-tab nav.
\[mutation-check\] 13/13: right-token-WRONG-table (`"Ego ID"` in the kin
DT) → FALSE, foreign-pane → FALSE, pre-flow → FALSE, correct → TRUE.
**(c) `animalSource='all'` ISOLATES breeding from GVA.** The module’s
`topRanked` (default) branch does `req(geneticValues())` (only set after
a GVA run, `appServer.R:272`), but `'all'` uses `ped$id` directly →
upload→QC→kinship→group-formation→render with NO GVA dependency — a
cleaner/faster vertical slice than the upload→GVA→breeding chain (and
GVA is already covered by 8e-6b). **(d) What NOT to assert.** Requested
`numGp=3` but the algorithm formed ONE big MIS group (so the
S43-handoff’s “`{numGp, numGp+1}`” is NOT guaranteed — high threshold
0.25 + hardcoded `ignore=F–F` yields one large independent set) → assert
the export buttons + rendered tables, NOT the group count; the strict
within-group kinship invariant is unattainable (`ignore=F–F`) → never
assert it numerically. All tokens are static labels / rendered
column-headers / table structure → seed-INDEPENDENT (Option C), GREEN
with no `NPRC_BG_SEED`. **(e) \[regression-read\] refinement — the
non-e2e baseline is MEASUREMENT-METHOD-sensitive.**
[`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)
under renv → 2140 pass / 0 err (clean);
[`library()`](https://rdrr.io/r/base/library.html) under
`RENV_CONFIG_AUTOLOADER_ENABLED=false` (system lib) ERRORS on tests
whose Suggests deps the bare system lib lacks; S48’s reported 2180 was a
different measurement. Since an e2e `test_that` SKIPS at
`create_test_app()` BEFORE any assertion (NPRC_RUN_E2E unset), a
test-only e2e edit is STRUCTURALLY inert on the non-e2e count → PROVE it
with a `git stash` diff (pre-edit == post-edit == **2140 / 0 fail / 0
err / 0 non-e2e offenders**) instead of chasing the headline number.
**(f)** System-lib currency must be checked under the AppDriver’s ACTUAL
resolution (`RENV_CONFIG_AUTOLOADER_ENABLED=false` → system lib), NOT
plain [`library()`](https://rdrr.io/r/base/library.html) (renv redirects
to the stale project lib, which lacked `gatedSeed`/`downloadGroupKin`) —
\[verify-first\] on lib resolution; R/ unchanged since S48 → system lib
already current, no reinstall. **Phase-3E:** the live GREEN AppDriver
runs (detailed 8/0/0, tutorial 11/0/0) + the 13/13 mutation spike ARE
the runtime (#31). Test-tree-only → no `document()`/NEWS; `tests/`
lint-exempt; CHANGELOG-only. Committed via explicit `git add`
(\[macos-dupe-scan\]: `.DS_Store`/`..Rcheck/`/audit-html excluded).
REFACTOR (shared flow helper) owner-DECLINED (precedent + the
GVA/breeding flows DIVERGE on the nested-tab activation, so a “shared”
helper is messier than a clean abstraction). **Reflexes:**
\[hard-gate-spike\]\[verify-first\]\[discriminating-RED\]\[mutation-check\]\[seed-independent\]\[regression-read\]\[phase-3E-smoke\]\[news-vs-changelog\]\[macos-dupe-scan\]\[author-decision\]\[refactor-only\].
**Apply:** to assert a feature in an INACTIVE no-`id` nested tab, click
its unique `a[data-value='<title>']` and read the activated content from
the TOP-LEVEL active pane’s innerText; make a static-UI button
data-bearing by PAIRING its visibility-gated label with a
`suspendWhenHidden` rendered output (so the assertion needs the DATA
flow, not just nav); isolate a downstream module from an upstream one
via its own input branch when the slice is about that module; never
assert a stochastic group COUNT or an unattainable kinship invariant —
assert the rendered export/tables; and when a test-only e2e edit appears
to “move” the non-e2e baseline, recognize the count is method-sensitive
and PROVE inertness with a stash diff (e2e blocks skip at
`create_test_app` regardless of content).

#### Learning 50 — CI per-module fresh-process grouping (8e-7, the FINAL §8e slice): partition the 23-file E2E tier into 13 per-module groups each run in a fresh `Rscript` process so no one process accumulates 23 Chrome instances; the partition is STATICALLY PROVABLE locally (replicate testthat’s stripped-name `grepl` match against the COMMITTED regexes → exactly 23, no overlap/gap) but the flake fix is LIVE-RUNNER-ONLY; check fail/error BEFORE the silent-skip guard so a real failure is never mislabeled “executed nothing”; and keep the per-group R snippet apostrophe-free because it lives inside bash `Rscript -e '...'` (S50, Phase 8e-7 / issue \#40)

8e-7 converted the single 23-files-in-one-process E2E run step in
`.github/workflows/shinytest2.yaml` into a **single job looping over 13
per-module group regexes, each in a fresh `Rscript` process**, defusing
the S34 “AppDriver process-count dragon” (23 Chrome instances
accumulating in one process → ~1 transient timeout / 5 full-tier runs).
This is the LAST §8e slice → the issue-#40 assertion-strengthening +
CI-stability campaign is now code-complete. **(a) \[author-decision\]
topology gated, single-job loop chosen OVER a matrix.** A pre-phase
`AskUserQuestion` offered (A) single job + bash loop spawning one
`Rscript` per group (plan §8’s literal design — 1× setup, sequential,
fresh PROCESS per group) vs (B) a 13-leg `strategy.matrix` (fresh RUNNER
per group, parallel, per-group UI checks, but 13× the
checkout/setup-r/deps/INSTALL/Chrome cost). Owner chose A — cheapest,
plan-faithful, root-cause-sufficient (≤3 files/process already defuses
the dragon); the matrix’s extra isolation/visibility wasn’t worth 13×
setup for a nightly job. Then the phase gate `PRE-RED→run-and-observe`
(CI config, no RED→GREEN per plan §6). **(b) \[ci-static-proof\] the
partition is PROVABLE locally even though the flake is not.** Per
Learning \#33c (replicate testthat’s stripped-name `grepl` match: strip
leading `test-?` + trailing `.[rR]`, then `grepl(rx, name)`) — extracted
the 13 regexes from the COMMITTED YAML (not a draft) and proved
union==the 23 `^(app|e2e)-` tier with no overlap/gap/stray, applied
against the FULL 182-file dir (so a group can’t silently reach a
non-tier file; the `^app-` trailing dash correctly excludes
`test_appServer_dynamicTabs`/`test_create_test_app`). The 13 groups:
`^app-`(2), `^e2e-breeding-groups-`(3), `^e2e-genetic-value-`(3),
`^e2e-input-`(3), `^e2e-pedigree-`(3), `^e2e-pyramid-`(2), + 7
single-file regexes (boundary-conditions, data-ready, error-states,
home-navigation, settings-about, summary-statistics,
workflow-integration). **(c) \[guard-ordering\] check fail/error BEFORE
the silent-skip guard.** Per group:
`test_dir(filter=rx, stop_on_failure=FALSE)` → `cat` a
`passed/failed/skipped/error` report → `if (f>0||e>0) quit(status=1)`
FIRST → `if (p==0) stop(...)`. The smoke EXPOSED that the naive order
(p==0 guard first) mislabels a real failure as “executed nothing”
whenever a failing group has 0 passes — reordering makes the silent-skip
guard fire only for the TRUE nothing-ran case (all-skipped / empty)
while real failures red the job with correct context. The guard is now
PER GROUP (stronger than the old whole-run `sum(passed)==0`): one
group’s filter drift can’t hide behind the others; a ZERO-match regex is
separately caught by `test_dir`’s own “No test files found” abort (→
nonzero exit). The bash loop runs ALL groups (full signal, one flake
doesn’t skip the rest) and reds the job if ANY failed — preserving
`stop_on_failure` job semantics; the job env / Chrome provisioning /
`R CMD INSTALL` / `timeout-minutes:30` / removed `continue-on-error`(R6)
all preserved; each group wrapped in `::group::`/`::endgroup::` log
folds. **(d) \[quote-safety\] the per-group R snippet lives inside bash
`Rscript -e '...'` → ZERO single-quotes allowed.** All R strings are
double-quoted and the inline R COMMENTS are apostrophe-free (wrote
“groups”/“test_dirs”, not “group’s”/“test_dir’s”) — an apostrophe would
terminate the bash single-quote and break the step. Verified by grepping
the `-e` block for `'` (none) + `bash -n` on the extracted run step
(clean) + `yaml.safe_load` (parses). **(e) \[phase-3E-smoke\] the
run-step LOGIC is locally verifiable; the FLAKE is not.** Smoked the
snippet on a throwaway test dir (deterministic, no Chrome): pass→exit0,
fail→exit1 (no “executed nothing” mislabel), skip→silent-skip
guard→exit1, nomatch→`test_dir` abort→exit1 — all 4 branches. But the
flake mitigation is ENVIRONMENTAL / LIVE-RUNNER-ONLY (FM \#24’s cousin):
proven that the partition selects the right files and the guards behave,
but only the first live GitHub run can confirm the 23-in-one-process
flake is gone — explicitly NOT claimed fixed until then. ⚠ A
smoke-HARNESS bug bit briefly: `out=$(Rscript ... | grep ...)` then
`${PIPESTATUS[0]}` reads the ASSIGNMENT’s status (always 0), not
Rscript’s — capture the exit with `$?` right after a non-piped
`out=$(Rscript ...)`. The committed snippet was never wrong; the harness
was. **(f) \[right-tool\] a deterministic partition is best proven by an
executable check, not an agent fan-out** — the R verification script IS
the adversarial proof (it asserts no-overlap/no-gap programmatically); a
workflow of skeptic agents would add nothing to a provably-correct regex
partition. **(g) Scope = CI-config ONLY** — `shinytest2.yaml` + notes;
NO `R/`/`tests/` change → the suite is byte-identical, no regression run
needed (the change alters only how CI INVOKES the suite).
`[news-vs-changelog]` → CHANGELOG only; `[macos-dupe-scan]` explicit
`git add` (`.DS_Store`/`..Rcheck/`/audit-html excluded). **Did NOT push
or bundle the master push (FM \#2/#18) — that SEPARATE deliverable is
what first exercises the two S34 watch items (renv lib-path + the
now-mitigated flake).** **Reflexes:**
\[author-decision\]\[ci-static-proof\]\[guard-ordering\]\[quote-safety\]\[phase-3E-smoke\]\[right-tool\]\[regression-read\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** to defang a per-process resource-accumulation flake in a CI
test tier, partition the files into per-module groups each run in a
FRESH process via a bash loop spawning one `Rscript` per group (preserve
env / install / `stop_on_failure` semantics + a PER-GROUP silent-skip
guard); PROVE the partition locally by replicating testthat’s
stripped-name `grepl` match against the COMMITTED regexes (exactly N, no
overlap/gap) even though the flake fix is live-runner-only; in the
per-group snippet check fail/error BEFORE the passed==0 guard, and keep
the `Rscript -e '...'` body apostrophe-free; smoke the run-step logic on
a throwaway dir but state plainly that the flake mitigation ships
unvalidated until the first live run.

#### Learning 51 — Promote a long-lived integration branch to master + live-validate (8e-7 follow-through → issue \#40 close): the FIRST remote push exercises PR-triggered checks that local verification never ran → expect first-remote-CI surprises ORTHOGONAL to package correctness; HOLD the merge for them, triage each to root cause, surface the merge decision to the owner; the live master `shinytest2` dispatch IS Phase-3E (S51, promote `add-methodology` → master / PR \#41 / pkgdown \#42)

Pushed the long-lived `add-methodology` dev branch (105 commits / 356
files; master a strict ancestor → 0 behind → clean conflict-free merge)
to **master via PR \#41** (merge commit `0363ffe3`),
`workflow_dispatch`-ed `shinytest2` on master (run `27356752221`
SUCCESS), and CLOSED \#40 — completing the §8e / issue-#40 campaign.
**(a) \[first-remote-CI\] a branch verified only LOCALLY has never run
its `pull_request`/push workflows.** Read every workflow `on:` trigger
BEFORE pushing to know what fires: here the push/PR ran `lint` +
`pkgdown` + `R-CMD-check` (×5 platforms) + `test-coverage` for the FIRST
time on these 105 commits (`shinytest2` is
`schedule`+`workflow_dispatch` only → NOT per-PR → dispatch it manually
post-merge, and its triggers only register once it’s on the default
branch). **HELD the merge for the PR’s first CI**
(`gh pr checks 41 --watch`) instead of merging blind into a possibly-red
master (SAFEGUARDS “don’t start from a broken state”). **(b)
\[triage-to-root-cause\] separate REAL-&-blocking from KNOWN/advisory; a
green R-CMD-check is NOT a green pkgdown.** R-CMD-check green on all 5
platforms ⇒ package correctness intact; **pkgdown FAIL** =
doc-site-deploy-ONLY; **lint FAIL** = known style debt (open \#30);
**codecov/patch+project FAIL** = EXTERNAL advisory thresholds (the
`test-coverage` workflow that GENERATES coverage PASSED; codecov’s own
commit-status checks fail on diff/threshold — routine on a big PR adding
hard-to-unit-test Shiny modules covered by opt-in E2E codecov can’t
see). **(c) the pkgdown `docs/` collision is STATICALLY detectable from
`.gitignore`.** `docs/*` ignored +
`!docs/methodology/`/`!docs/planning/` un-ignored ⇒ those 15 files are
git-tracked INSIDE pkgdown’s default `docs/` output dir; on a fresh
clone `docs/` is non-empty with no `pkgdown.yml` sentinel →
`build_site_github_pages(clean=TRUE)`→`clean_site()`→`check_dest_is_pkgdown()`
errors “not built by pkgdown” → exit 1. The one DING: a thorough
pre-push audit could have PREDICTED this from `.gitignore:32-36`
(reading triggers tells you a check RUNS, not that it FAILS). Fix
options (logged as **\#42**, not done — 1-and-done): relocate the
methodology docs out of `docs/` (Option 1, keeps the site URL) or set a
pkgdown `destination:`. **(d) \[author-decision\] surface a
real-but-non-blocking merge call via `AskUserQuestion`** — don’t
presume; owner chose “merge now, fix pkgdown later”; log the deferred
fix as its OWN issue rather than scope-creeping it into the promotion.
**(e) \[preserve-history\] merge with `--merge`, NEVER squash a
multi-session campaign** (105 commits of TDD/session deliverables) into
one. The merge commit lands on master but NOT the feature branch → they
diverge; put close-out notes on the dev branch (add-methodology) and let
the next sync carry them (or cherry-pick). **(f) \[phase-3E\] for a
CI/integration deliverable the runtime verification IS the live workflow
run on the real branch** (#31): `workflow_dispatch` `shinytest2` on
master → confirm each of the 13 per-module group folds FIRSTHAND from
the run log (`passed>0 failed=0 error=0` — extract via
`gh api .../jobs/<id>/logs | grep`), not merely “the step is green.”
Both S34 watch items resolved on the FIRST run (renv lib-path under
`RENV_CONFIG_AUTOLOADER_ENABLED=false`; the 23-in-one-process flake →
zero transients under 8e-7’s per-module fresh processes). One clean run
CONFIRMS-but-doesn’t-PROVE a probabilistic flake gone — said so
explicitly; per-group isolation means any future transient reds only its
own group and is independently re-dispatchable. Stakeholder corrections:
0. **Reflexes:**
\[first-remote-CI\]\[verify-first\]\[triage-to-root-cause\]\[author-decision\]\[preserve-history\]\[phase-3E-smoke\]\[regression-read\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** before the first push of a long-lived local-only branch —
read every workflow `on:` trigger, run a local build-equivalent gate,
HOLD the merge for the PR’s first CI, triage each red to root cause
(package-correctness vs doc-site/style/advisory), surface a
real-but-non-blocking merge decision to the owner and log the deferred
fix as its own issue; merge with `--merge` to preserve multi-session
history; validate a CI deliverable by dispatching the live workflow on
the target branch and reading each group’s result firsthand; and state
plainly that one clean run doesn’t prove a probabilistic flake gone.

#### Learning 52 — Fix pkgdown’s `docs/` collision (#42) by REPOINTING the output dir, not relocating the doc trees: `build_site_github_pages(dest_dir=...)` OVERRIDES `_pkgdown.yml destination:` (set BOTH); the methodology framework PINS reference docs to `docs/methodology/` (synced dashboard + synced cross-refs), making “relocate” the wrong fix; and fixing one CI failure UNMASKS the next — pkgdown builds vignettes from source IGNORING `.Rbuildignore`, so a check-excluded vignette can be green on R-CMD-check yet fatal to pkgdown (S52, issue \#42 / pkgdown)

#### Learning 53 — Auditing `.lintr` line-exclusions requires `parse_settings=FALSE`, and the hardcoded line numbers drift two ways (S53, issue \#30 planning)

**(a) The auditing trap.** To see what a `.lintr` `"file" = line`
exclusion actually suppresses you MUST bypass `.lintr` —
`lintr::lint("R/foo.R")` (and `lint_package()`) default to
`parse_settings=TRUE`, which reads `.lintr` and applies the very
exclusion under audit, so a suppressed line reports “No lints found” and
looks stale. Use
`lint(..., linters=<project tag set>, parse_settings=FALSE)` or
`lint_package(..., parse_settings=FALSE, exclusions=list("inst","tests","vignettes"))`.
A subagent that skipped this wrongly declared
`getLkDirectAncestors.R:26/29/35` a stale exclusion; bypassing it proved
`undesirable_function_linter` DOES flag the local variable named
`source` (it flags the *symbol* shadowing
[`base::source`](https://rdrr.io/r/base/source.html), not just calls) →
the fix is a variable RENAME, not an exclusion deletion. **(b)
Line-number drift goes both ways** (\[lint-net-zero\] sibling): a shift
can leave an exclusion pointing at lines with NO lint (dead config —
`getPyramidPlot.R = 25:27` suppressed 0; the real lints had moved to
16/38/41-43) OR keep suppressing while the *content* changed. **(c)
Verify-first beats the agent’s headline.** Adversarial verification
overturned two examine-agent recommendations: “delete the all-commented
`makeGeneticDiversityDashboard.R`” reversed an explicit author
won’t-delete decision (NEW-20, `.Rbuildignore`’d, namespace fallout per
\#35) → KEEP-EXCLUDE; and “set_seed.R:11 exclusion is stale, just remove
it” was wrong because removing it re-fires the lint — a stray trailing
`#'` (which also leaks into `man/set_seed.Rd`) fools
`commented_code_linter` and must be stripped. **(d) Fix-and-de-exclude
atomically:** clean a file’s code and delete ITS `.lintr` entry in the
SAME commit, so no stale line number is ever left. **(e)
`commented_code_linter` IS active** via the tag set; the
`#commented_code_linter = NULL` line in `.lintr` is a dead no-op (a
failed `linters_with_tags` modify) — resolving issue \#30’s “reports not
finding it” confusion. **(f) `undesirable_function_linter` flags
symbols, not just calls** — a local var named `source`/`sapply`/etc.
shadowing an undesirable function trips it. **Reflexes:**
\[verify-first\]\[lint-net-zero\]\[author-decision\]\[parse-settings-false\].
**Apply:** audit exclusions with `parse_settings=FALSE`; rename
shadowing locals; never delete author-retained files; strip stray `#'`;
fix-and-de-exclude in one commit. \#42: the `pkgdown` Build-site step
failed on a fresh CI clone because `docs/methodology/`+`docs/planning/`
are git-tracked inside pkgdown’s default `docs/` output dir
(`.gitignore:32-36`) with no `pkgdown.yml` sentinel →
`clean_site()`/`check_dest_is_pkgdown()` refuses to wipe a dir it didn’t
build → exit 1. **(a) \[author-decision\] chose Option 2 (repoint), NOT
the issue’s recommended Option 1 (relocate the trees) — surfaced via
`AskUserQuestion` because the recommendation had a constraint the issue
author hadn’t weighed.** The methodology framework’s OWN convention pins
reference docs to `docs/methodology/`: the SYNCED
`methodology_dashboard.py:109-110` scores
`docs/methodology`+`docs/methodology/workstreams` (20 of the 98 health
pts) and the SYNCED `SESSION_RUNNER.md` (13 refs) + `SAFEGUARDS.md` (1
ref) cross-link that path — none durably editable in-repo (re-synced
from upstream). So relocating would break things I can’t fix; repointing
pkgdown touches nothing the framework cares about. **When the owner’s
written recommendation conflicts with evidence you’ve found, don’t
silently follow OR silently override — surface the trade-off with exact
actions and let them choose.** **(b) \[verify-first on library
internals\] `build_site_github_pages(dest_dir="docs")` does
`as_pkgdown(pkg, override=list(destination=dest_dir))` — its `dest_dir`
ARG OVERRIDES `_pkgdown.yml destination:`.** Read the installed-pkgdown
(2.1.1) source AND proved it empirically
(`as_pkgdown(".",override=list(destination="pkgdown_site"))$dst_path` →
`pkgdown_site`; default → `docs`). ⟹ setting the yml ALONE does NOT fix
CI (the owner proposed the yml; I confirmed it’s
necessary-but-insufficient and set BOTH: workflow
`dest_dir="pkgdown_site"` for CI +
`_pkgdown.yml destination: pkgdown_site` for local `build_site()`
consistency). Don’t assume a config field is honored by every entry
point — `build_site()` reads the yml, `build_site_github_pages()`
overrides it. **(c) Fix (commit `fcc154e8`):**
`.github/workflows/pkgdown.yaml` `dest_dir="pkgdown_site"` + deploy
`folder: docs→pkgdown_site`; `_pkgdown.yml destination: pkgdown_site`;
`.gitignore += pkgdown_site/`; `.Rbuildignore += ^pkgdown_site$`. NO
file moves; gh-pages URL unchanged (the site deploys from the gh-pages
BRANCH via JamesIves, so the build-dir name is a transient artifact); no
`R/`/`tests/` change → suite byte-identical, R-CMD-check unaffected.
**\[local-proof-before-push\]** simulated the fresh-clone state in a
temp package skeleton: `clean_site(dest=docs)` ERRORS “is non-empty and
not built by pkgdown” (reproduces \#42) while
`clean_site(dest=pkgdown_site)` is a clean no-op — proved the fix
locally before any CI cycle. **(d) \[fix-unmasks-next\] a CI failure can
MASK later-stage failures; fixing it reveals the next one.** With
clean_site resolved, the build reached vignette rendering and failed on
`ColonyManagerTutorial.Rmd:209` chunk `make-errorList-definition-tbl` —
`data.frame(Error=names(getEmptyErrorLst()), Definition=errorDescriptions)`
paired **10 error types vs 9 hardcoded descriptions** (“arguments imply
differing number of rows: 10, 9”). Root cause: the NEW-45 “no period in
IDs” feature (commit `5e228bd9`) added the `invalidIdChars` type to
[`getEmptyErrorLst()`](https://github.com/rmsharp/nprcgenekeepr/reference/getEmptyErrorLst.md)
without updating the vignette table → added the missing description in
positional order (after `duplicateIds`, before `changedCols`) using the
package’s canonical wording (commit `e89975c8`). **(e)
\[pkgdown-vs-Rbuildignore\] pkgdown builds ALL vignettes from the source
tree IGNORING `.Rbuildignore`; R CMD build/check builds only the
NON-ignored ones.** `ColonyManagerTutorial.Rmd` is `.Rbuildignore`’d
(`:36`) — likely for CRAN tarball-size/time (it reads screenshots from
the also-`.Rbuildignore`’d `vignettes/shiny_app_use/`) — so R-CMD-check
NEVER builds it (green on all 5 platforms) yet pkgdown does → it was the
ONE pkgdown-built vignette no R-CMD-check covers, hence the only place a
render bug could hide (the other 3 —
a2interactive/a3manual/simulatedKValues — ARE check-built → green →
render fine; this let me PREDICT the re-run would go green, which it
did). **If you add/rename an error type in
[`getEmptyErrorLst()`](https://github.com/rmsharp/nprcgenekeepr/reference/getEmptyErrorLst.md),
update the `ColonyManagerTutorial.Rmd` table in lockstep (positional
pairing).** **(f) \[scope-discipline\] when the fix unmasked a SEPARATE
bug, surfaced it via `AskUserQuestion` (fix-now vs file-separately)
rather than silently scope-creeping** — characterized the root cause,
the whack-a-mole risk (a 4th vignette untested at that point), and the
`.Rbuildignore` reason it was latent, so the owner could decide with
full info; owner chose fix-now. **(g) \[phase-3E\] validation chain, all
firsthand:** local fresh-clone simulation → PR \#43 pkgdown run
`27361729368` (fresh-clone, Deploy skipped on PR) SUCCESS, all 4
vignettes rendered → merged `--merge` to master `c6ad23dd` → master push
run `27362288625` Build site SUCCESS **+ Deploy SUCCESS** (exercises the
new `folder: pkgdown_site` → gh-pages). The live master pkgdown run IS
Phase-3E (#31) — confirmed the steps firsthand, not “the check is
green.” **\#42 auto-closed on merge** (PR body “Fixes \#42”) +
validation comment. Owner-gated decisions: 4 `AskUserQuestion`
(fix-approach, vignette-scope, merge; + honored the owner’s mid-stream
yml correction) — 0 corrections. `[news-vs-changelog]` → CHANGELOG only;
`[macos-dupe-scan]` explicit `git add`. **Reflexes:**
\[author-decision\]\[verify-first\]\[local-proof-before-push\]\[fix-unmasks-next\]\[pkgdown-vs-Rbuildignore\]\[scope-discipline\]\[phase-3E-smoke\]\[triage-to-root-cause\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** to fix a pkgdown `docs/` collision when reference docs
legitimately live under `docs/`, REPOINT pkgdown’s output via the
workflow `dest_dir` arg (it overrides `_pkgdown.yml destination:`) + set
the yml too for local consistency, rather than relocating tracked trees
the framework pins there; prove the fix with a fresh-clone
`clean_site()` simulation BEFORE pushing; expect a masked CI failure to
reveal the next one (pkgdown builds `.Rbuildignore`’d vignettes that
R-CMD-check skips); and surface any unmasked separate bug as a scope
decision rather than silently absorbing it.

#### Learning 54 — Implement issue \#30 to a GREEN lint check: Phase 1 (commented-code) committed alone, then a per-file editor→verifier fan-out for the 154-lint residual (S54, issue \#30 implementation)

**(a) \[orchestrate-fanout-verify-globally\] A broad
mechanical-but-judgment cleanup is a per-file pipeline.** 154 residual
lints across 18 files: a workflow with ONE editor + ONE adversarial
verifier per file (each editing its OWN distinct file → zero Edit
conflicts) applied 150+ fixes and verified all 18 behavior-preserved in
~6 min. The editors iterated-until-clean and caught EXTRA
`implicit_integer` literals that only surfaced after a wrap shifted
lines (`pch = 19`→`19L`, `errors$Error[1]`→`[1L]`). The orchestration
parallelizes the per-site judgment; the AUTHORITATIVE verification (full
`lint_package()`=0, full test suite, `document()`, app boot) is done by
the parent, not trusted from the agents. **(b)
\[reconcile-against-CI-command\] An agent’s `parse_settings=FALSE`
self-lint can fire linters the project `.lintr` does NOT.** A verifier
reported 2 `coalesce_linter` “remaining” on `modInput.R`; but
`coalesce_linter` isn’t in the project tag set
(`"coalesce_linter" %in% names(proj)` → FALSE) and the real CI command
`lintr::lint_package()` (reads `.lintr`) showed **0**. The flagged lines
were pre-existing, untouched, behavior-correct. NEVER accept a non-green
claim from a sub-probe without reproducing it with the exact CI command.
**(c) `implicit_integer` int-vs-double is behaviorally moot in R but
intent-correctness matters** (owner kept the linter ON, did not
disable): append `L` for counts/indices/lengths/UI-widths/durations
(`column(8L)`, `character(0L)`, `errors > 0L`, `rep("Site", 3L)`);
append `.0` only where a real is intended (`ped$age * 12.0`).
`double * 12L` == `double * 12.0` numerically, so this is style, not
behavior — but pick the intent-correct form. **(d) \[author-decision\]
targeted inline `# nolint: <linter>` for VERIFIED false-positives only**
— `object_usage` on package-internal funcs lintr can’t resolve
(`calcFounderContributions`, `gatedSeed`) + one it misreads
(`founderStats` IS a `modSummaryStatsServer` formal,
modSummaryStats.R:293); `nonportable_path` on MIME strings
(`"text/css"`); `object_name` on the base-R-standard `launch.browser`
arg; [`library()`](https://rdrr.io/r/base/library.html) in the shinytest
harness; the CRAN [`par()`](https://rdrr.io/r/graphics/par.html)
save/restore idiom. Read each to PROVE it’s a non-bug before suppressing
(all 6 object_usage were false positives — 0 latent bugs). **(e)
Wrapping a roxygen line reflows the generated `.Rd`** → run `document()`
after and COMMIT the regenerated man pages
(`getPyramidPlot`/`modBreedingGroupsServer`/`modPedigreeServer` here);
the `\item`/`\value` text is identical, just rewrapped — R-CMD-check
requires man/ to match source. `@importFrom` wraps did NOT change
`NAMESPACE` (roxygen joins continuation lines → same tokens). **(f)
\[phase-3E-smoke\] verify runtime Shiny edits by BOOTING the app from
`load_all` source, not the stale system lib** — `pkgload::load_all(".")`
then build each `modXUI()` + `runModularApp(launch.browser=FALSE)`;
confirmed all 7 module UI builders constructed (where most
`column()`/`implicit_integer` UI edits live) and the app served **HTTP
200 / 92KB** — the unit suite (2140/0/0, S49 baseline) does NOT exercise
the mod servers, so the boot is the real runtime gate for these files.
**(g) The lint-dump basename ≠ `R/<name>`** — the dump’s `app.R`
actually lives at `inst/shinytest/app.R` (no `R/app.R`); have agents
DISCOVER and flag the real path rather than assume. **(h) \[scope\] the
owner expanded a “1-and-done” session mid-stream** (“proceed to clean up
lints that remain”) — honored it as a deliberate scope expansion (Phase
1 + residual), committed Phase 1 ALONE first as a recoverable boundary
(\[lint-net-zero\]: code fix + exclusion removal same commit) before the
architect-mode residual fan-out. **Reflexes:**
\[orchestrate-fanout-verify-globally\]\[reconcile-against-CI-command\]\[author-decision\]\[phase-3E-smoke\]\[lint-net-zero\]\[verify-first\].
**Apply:** for a broad lint backlog, fan out one editor + one
adversarial verifier per file; keep `implicit_integer` int/double
intent-correct; `# nolint` only PROVEN false-positives; `document()` +
commit man/ after any roxygen reflow; reconcile every lint count against
the real `lint_package()` CI command; and BOOT the app to verify runtime
Shiny edits.

#### Learning 55 — Adversarial verification can overturn a plan’s “behavior-none” classification: an EXPORTED `sapply`→`%in%` swap diverged on NA input → owner-gated reclassification to RED→GREEN→REFACTOR (S55, issue \#30 Phase 3)

**(a) \[verify-first-before-classifying\] “Obviously equivalent” is a
hypothesis, not a fact — especially on an exported function.** Phase 3
of the \#30 plan labeled `checkRequiredCols.R`’s
`as.character(unlist(sapply(requiredCols, \(col) if (!any(col == cols)) col)))`
→ `requiredCols[!requiredCols %in% cols]` as behavior-none
(“agent-verified across present/absent/empty cases”). A per-file
adversarial verifier (`wf_eb654565-758`; one skeptic per refactor, each
told to REFUTE behavior-equivalence and ALLOWED TO RUN R) constructed
the untested case: `cols = c("id", NA, "sire")` with a required col
absent → the OLD `if (!any(col == cols))` evaluates `if (!NA)` and
THROWS `"missing value where TRUE/FALSE needed"`, while `%in%` treats NA
cleanly and RETURNS the missing cols. I reproduced it firsthand (non-NA
inputs byte-identical across 5 cases; NA input: error vs clean return).
`checkRequiredCols` is `@export`ed → the divergence is on the public
surface. **There is NO clean lint-passing rewrite that preserves the
exact NA-error** (it is inherent to the `sapply`/`if` structure), so the
lint fix *necessarily* changes behavior → it belongs in the
behavior-SENSITIVE bucket (RED→GREEN→REFACTOR), not behavior-none. The
plan had caught `addSexAndAgeToGroup` as “the only real behavior risk”
(§6 \#4); this is a SECOND one it under-scoped. **(b) \[strict-TDD\] A
behavior change discovered mid-REFACTOR is a phase violation — surface
it, don’t ship it.** Per the project TDD contract (REFACTOR = no
behavior change) I paused before committing, surfaced 3 options via
`AskUserQuestion`; the owner chose DEFER to Phase 4. Reverted the one
file to its EXACT pre-session state (sapply + exclusion restored) and
shipped only the 6 GENUINELY behavior-none refactors (the other 6
verifiers returned refuted=false, each with empirical R comparison).
**(c) The 6 that WERE behavior-none:** `unnecessary_nesting` collapses
(drop an `else` after an unconditional
[`stop()`](https://rdrr.io/r/base/stop.html)/[`return()`](https://rdrr.io/r/base/function.html),
or `else { if }` → `else if`) are pure control-flow-equivalent;
`undesirable_function_linter` flags a local var named `source`
(shadowing [`base::source`](https://rdrr.io/r/base/source.html) — it
flags the SYMBOL, not just a call) → rename to `msgSource` (a value
reference, so resolution is unaffected — cosmetic); `unnecessary_lambda`
`\(df) inherits(df, "data.frame")` →
`vapply(dfList, inherits, logical(1L), what = "data.frame")` (vapply
feeds each element positionally to `inherits`’s `x`, `what=` appended
via `...` → identical call; a list element named `what` cannot misbind
because elements pass positionally). **(d) \[owner-flagged-config-fix\]
A pre-existing `.lintr` casing bug (`R/CheckRequiredCols.R` capital-C)
suppresses nothing on case-sensitive CI** — `lintr` exclusions are
case-sensitive on Linux, so the capital-C entry let the L34 lint fire on
the CI runner while macOS hid it. Fixed to lowercase
`R/checkRequiredCols.R` at the owner’s explicit request (config-only,
behavior-none); the corrected entry now suppresses the deferred file’s
lint on Linux too, while the CODE refactor stays deferred. **I initially
restored the buggy casing as a literal “revert” and only flagged it —
the owner had to point it out; the better call was to fix it proactively
(behavior-none, independent of the deferred code).** **(e)
\[orchestrate-then-verify-globally\]** 7 verifiers ran in parallel (~95
s); the AUTHORITATIVE gate (`lint_package()`=0, full suite 2140/0/0/159,
`devtools::check()` 0 errors) was run by the parent, not trusted from
agents. **Reflexes:**
\[verify-first\]\[adversarial-overturns-plan\]\[strict-TDD\]\[author-decision\]\[lint-net-zero\]\[orchestrate-fanout-verify-globally\].
**Apply:** before classifying a
`*apply`/`%in%`/[`match()`](https://rdrr.io/r/base/match.html) swap on
an EXPORTED function as behavior-none, adversarially test NA / duplicate
/ out-of-contract input; if it diverges, it is RED→GREEN→REFACTOR, not
REFACTOR — surface and let the owner decide. And `.lintr` line-exclusion
paths are case-sensitive on CI — match the real filename casing.

#### Learning 56 — Implement \#30 Phase 4 (the behavior-sensitive bucket): adversarial verification catches edge divergences that firsthand probing MISSES — empty-input column-drop + abuse-input error-message — and one was a latent caller crash-fix (S56, issue \#30 Phase 4)

**(a) \[verify-first / adversarial-beats-my-own-probe\] A dedicated
skeptic finds the edge case your own firsthand probe didn’t think to
try.** I had firsthand-proven `addSexAndAgeToGroup`’s
`sapply`→`ped$sex[match(ids, ped$id)]` equivalent across
happy/missing/duplicate inputs and DOWNGRADED it from the plan’s “RED
slice” to a behavior-none REFACTOR (the `age` vapply already errors
identically on any ≠1-row id, so `sex` can’t diverge — true on those
inputs). The 6-skeptic adversarial workflow (`wf_168f8dcf-1e5`, each
told to REFUTE + run R) tried `ids = character(0)`: OLD
`sapply(character(0), …)` returns a NAMED EMPTY LIST →
[`data.frame()`](https://rdrr.io/r/base/data.frame.html) DROPS that
column → 2 cols (ids, age); NEW
[`match()`](https://rdrr.io/r/base/match.html) returns a length-0 factor
→ retained → 3 cols (ids, sex, age). A SHAPE divergence I never probed.
**Lesson: run the adversarial pass even AFTER your own firsthand
verification — “I tested it” is not “I tested the empty / zero-length /
wrong-type case.”** Always include `character(0)` / length-0 / `NA` /
wrong-type in an `*apply`-swap’s adversarial set. **(b)
\[trace-the-caller\] The empty-input divergence was a LATENT CRASH FIX,
not a regression.** The sole caller `modBreedingGroups.R:438-440` does
`gp <- addSexAndAgeToGroup(ids, ped); colnames(gp) <- c("Ego ID","Sex","Age in Years")`
— assigning 3 names to OLD’s 2-col empty-group result THROWS
`"'names' attribute [3] must be the same length as the vector [2]"`;
NEW’s 3-col result renders an empty table. NEW also matches the
`@return` doc (3 columns). So “adopt the new behavior” (owner choice)
FIXED a latent empty-group crash in the breeding-groups member view.
Tracing the ONE caller turned an abstract “shape differs” into a
concrete decision. **(c) A guard-clause inversion `if(x)`→`if(!x)`
diverges on non-logical input.** `create_wkbk`’s
`if (replace){remove} else {warn;return}` →
`if (!replace){warn;return}; remove`: for `replace` a non-logical
non-coercible value (string/list) while the file exists, OLD
`if(replace)` throws “argument is not interpretable as logical” while
NEW `!replace` (evaluated FIRST, before `if`) throws “invalid argument
type” — both error, only the message text differs. Coercible values
(0/1/NA/logical) are identical. `replace` is documented logical → owner
ACCEPTED the cosmetic message change (no clean lint-passing rewrite
preserves the exact message). **(d) \[strict-TDD\] Surface BOTH
refutations before shipping, even the trivial one.** Per \#55’s
precedent and the REFACTOR contract, I paused on both (not just the
meaningful `addSexAndAge` one) and posed ONE `AskUserQuestion` with the
caller-traced consequences + recommendations; owner chose adopt-new /
accept. 0 corrections. **(e) \[process-slip — re-lint after EVERY edit,
incl. roxygen\] I committed the checkpoint `17e3fa06` after adding an
`@details` block without re-linting → an 81-char line landed in it;
caught by the NEXT `lint_package()` run and fixed-forward in the
batch.** A roxygen edit can introduce a `line_length` lint just like
code — re-run `lint_package()` AFTER any edit and BEFORE the commit, not
just after the code change. **(f) The 4 genuinely behavior-none
refactors** (correctParentSex if/else inversion with the report body
falling through; fillGroupMembers `else{if}`→`else if`; setExit
`mapply`→`unlist(Map(...))` since `chooseDate` is always length-1;
checkRequiredCols `%in%` strictly within the agreed NA envelope) were
confirmed by the skeptics (6000-iter fuzz / 146 seeded / 21 inputs / ~50
inputs respectively, all identical incl. error messages). **(g)
\[phase-3E\] the runtime gate for a pure-fn change consumed by Shiny =
the module test, not an app boot.** `addSexAndAgeToGroup`’s integration
is exercised by `test_modBreedingGroups.R:1015-1122` (the `viewGrp`
member view → `c("Ego ID","Sex","Age in Years")` colnames path), green
in the full suite — stronger and cheaper than manually creating an empty
group in a booted app. **Reflexes:**
\[verify-first\]\[adversarial-beats-own-probe\]\[trace-the-caller\]\[strict-TDD\]\[author-decision\]\[lint-net-zero\]\[re-lint-after-every-edit\]\[orchestrate-fanout-verify-globally\]\[phase-3E-via-module-test\].
**Apply:** when swapping
`*apply`/[`match()`](https://rdrr.io/r/base/match.html)/`%in%` or
inverting a guard clause on an EXPORTED fn, adversarially test EMPTY
(`character(0)`), zero-length, `NA`, and WRONG-TYPE inputs (not just
happy/missing/dup) — and trace the actual caller(s) to judge whether a
shape/error divergence is a regression or a latent-bug fix; re-lint
after every edit including roxygen.

#### Learning 57 — Closing \#30 (admin) + the macOS `SESSION_NOTES 2.md` dupe is a check *WARNING* (not just a NOTE) because of the SPACE in its name (S57, issue \#30 close + repo hygiene)

**(a) \[verify-the-gating-fact-firsthand\] Re-verify the one fact a
close turns on, even when the handoff already states it.** Before
`gh issue close 30` I re-ran `lintr::lint_package()` = **0** myself
rather than trusting the S56 handoff’s count — the project’s own
standing gotcha is “always reconcile any sub-probe lint count against
the real `lint_package()`.” A close is a public, hard-to-walk-back act;
pay the few seconds to confirm its load-bearing premise. **(b)
\[macos-dupe → portable-names WARNING, not the top-level NOTE\] The
recurring macOS sync duplicate `SESSION_NOTES 2.md` causes the lone
`devtools::check()` WARNING specifically via the “non-portable file
names” check — because of the SPACE in the filename — which is a
DIFFERENT check from the “non-standard files/directories found at top
level” NOTE that the no-space methodology/audit files
(`RECOMMENDED_SKILLS.md`, `methodology_dashboard.py`,
`PED_GV_AUDIT_2026-05-30.{html,md}`, `TECH_DEBT_AUDIT_2026-05-30.md`,
`dashboard.html`, `nprcgenekeepr_notes.txt`,
`20250504_cran-comments.md`) trigger.** Root cause of why the dupe
reaches the build at all: `.Rbuildignore`’s `^SESSION_NOTES\.md$` is an
EXACT-match regex that does not cover the space-name, so the dupe lands
in the build tarball while the real file is ignored. `rm` clears the
WARNING (verified firsthand: post-removal `devtools::check()` = **0
errors / 0 warnings / 3 pre-existing NOTEs** — clock-skew, spelling, and
the top-level-files NOTE which no longer lists the dupe). The NOTE is
pre-existing/accepted and is NOT cleared by removing the dupe.
**Permanent fix (DEFERRED — owner’s call, out of this session’s
scope):** broaden the pattern to `^SESSION_NOTES.*\.md$` (or
`^SESSION_NOTES.*`) so any future macOS dupe is build-ignored and never
re-raises the WARNING. **(c) \[safe-delete-untracked\] “Untracked” is
not “safe to delete.”** Before `rm` I verified the dupe was untracked
(`??`), never committed (empty `git log -- "SESSION_NOTES 2.md"`), AND
content-contained in the live file
(`comm -13 <(sort SESSION_NOTES.md) <(sort "SESSION_NOTES 2.md")` → 0
dupe-only lines). A point-in-time copy could hold edits absent from the
original; confirm zero unique content first. **(d)
\[declare-N/A-honestly\] An admin/hygiene session (issue close +
untracked-file removal + doc/changelog edits) writes no production code
or tests → the RED→GREEN→REFACTOR cycle does not apply; declare TDD
phase N/A every response rather than forcing a phase.** **Reflexes:**
\[verify-first\]\[verify-the-gating-fact\]\[safe-delete-untracked\]\[macos-dupe-scan\]\[news-vs-changelog\]\[commit-before-scope-switch\].
**Apply:** when a session’s whole point is to close an issue, re-verify
the issue’s resolution criterion firsthand before closing; and remember
the macOS dupe trips a *WARNING* (space → portable-names) distinct from
the top-level-files *NOTE* — `rm` it (or broaden `.Rbuildignore` to kill
it permanently).

#### Learning 58 — Execute S57’s DEFERRED `.Rbuildignore` permanent dupe-fix: broaden the exact-match to `.*`, and verify a build-ignore change at the BUILD level (stage dummy → `R CMD build` → `tar tzf`), not via `devtools::check()` (S58, repo hygiene / `.Rbuildignore`)

**(a) \[permanent-over-recurring\] Kill a recurring-toil class at the
root rather than re-doing the manual fix each session.** S57 cleared the
macOS-dupe WARNING by `rm`-ing `SESSION_NOTES 2.md` and explicitly
DEFERRED the permanent fix (Learning 57b); S58 executed it —
`.Rbuildignore:77` `^SESSION_NOTES\.md$` → `^SESSION_NOTES.*\.md$`. An
exact-match build-ignore entry does NOT cover macOS sync dupes
(`X 2.md`, `X 3.md`, `X copy.md`); broaden to `^X.*\.md$`. The project
had already patched this exact class narrowly ONCE (`.Rbuildignore:30`
`^\.Rhistory\ 2$` — an escaped-space exact match for a single dupe),
which is the TELL that the narrow form keeps coming back; the `.*`
generalization is the durable fix. **(b) \[build-not-check\] Verify a
`.Rbuildignore` change at the BUILD level, not via
`devtools::check()`.** The “non-portable file names” WARNING is a pure
function of the built tarball’s CONTENTS, so the authoritative, targeted
gate is: stage a real dummy (`touch "SESSION_NOTES 2.md"`) →
`R CMD build --no-build-vignettes --no-manual .` →
`tar tzf <tarball> | grep -i SESSION_NOTES` (expect NONE) → remove the
dummy + tarball. This proved exclusion (0 SESSION_NOTES entries / 693
files, RC=0) WITHOUT the ~90s full `check()` that S57 self-dinged as
over-heavy — check would be redundant here since no R code/metadata
affecting it changed and S57 already established the dupe→WARNING link.
Pair it with a fast `grepl(old, files)` vs `grepl(new, files)` regex
probe (`ignore.case = TRUE, perl = TRUE` — mirrors R CMD build’s
case-insensitive relative-path match) as the RED-equivalent: confirm OLD
misses the dupes, NEW catches all variants, and neither over-matches
(`CHANGELOG.md` / non-`.md` stay FALSE; the canonical name stays
excluded). **(c) \[declare-N/A-honestly, cont. from 57d\] A
`.Rbuildignore`-only change is TDD N/A — there is NO shippable unit test
for it, because `.Rbuildignore` is DROPPED from the built tarball, so a
`testthat` assertion that reads it can’t run under R CMD check.**
Substitute the build-level proof above; do not manufacture a synthetic
test. **(d) \[glob-dont-hardcode\] DESCRIPTION `Version` is the
tarball-name source of truth, not CLAUDE.md.** The built tarball was
`nprcgenekeepr_1.1.0.9000.tar.gz` (dev version) while CLAUDE.md still
says “Version 1.0.8” — glob `nprcgenekeepr_*.tar.gz`; a hardcoded
`_1.0.8` would have matched nothing. (Stale CLAUDE.md version flagged
for a future one-line fix.) **(e) \[Rscript –vanilla for one-offs\] In
an renv project, run throwaway R from a temp `.R` file via
`Rscript --vanilla`** — inline `-e` with backslashes (`"\\."`) hits
shell-escaping AND `.Rprofile` prints the renv out-of-sync banner;
`--vanilla` skips `.Rprofile`/renv and a file sidesteps the quoting.
**Reflexes:**
\[verify-first\]\[macos-dupe-scan\]\[news-vs-changelog\]\[right-sized-orchestration\]\[declare-N/A-honestly\].
**Apply:** when a recurring macOS-dupe (or any sync-dupe) keeps
re-raising a check WARNING, broaden the `.Rbuildignore` exact-match to
`.*` and prove it by building with a staged dummy and inspecting the
tarball — not by `devtools::check()`, and not by eye.

#### Learning 59 — Generalize the dupe-guard to the whole methodology `.md` cluster — and the trap that surfaced: EVERY `.Rbuildignore` line is a perl regex, so a “comment” with an unbalanced paren ABORTS the build (S59, repo hygiene / `.Rbuildignore`)

**(a) \[generalize-the-class, cont. from 58a\] S58 broadened only
`SESSION_NOTES`; the same macOS-dupe WARNING class still hit every
sibling exact-match pattern.** Broadened all 7 to `<NAME>.*\.md$`
(`.Rbuildignore:77-84`): `PROJECT_LEARNINGS`, `CLAUDE`,
`SESSION_RUNNER`, `SAFEGUARDS`, `BACKLOG`, `ROADMAP`, `CHANGELOG`. A
dupe of any of them (`CLAUDE 2.md`, `CHANGELOG copy.md`) would otherwise
have re-raised the exact WARNING S58 just killed for SESSION_NOTES.
Killing a *class* means covering every member, not the one that bit you
last. **(b) \[Rbuildignore-lines-are-ALL-regexes\] The load-bearing new
fact: `.Rbuildignore` has NO comment syntax — every line is a perl regex
matched against relative paths. The existing `#`-prefixed “comments”
only work because each happens to be a VALID regex that matches no real
file (a path containing the literal comment text doesn’t exist).** I
added a multi-line `#` comment whose 2nd/3rd lines held an unbalanced
`(` (`... sync dupes (` 2.md`,`) → `R CMD build` aborted immediately:
`Error ... invalid regular expression '# Patterns broadened ...('`. The
fix: keep every comment line a valid regex — balanced parens or, safest,
NO parens / no leading quantifier (`*`,`+`,`?`). I left an inline NOTE
in the file warning the next editor. The TELL that this is a regex-file,
not a prose-file: line 73’s original `(tooling, not R package content)`
works ONLY because its parens are balanced. **(c) \[the build step IS
the test\] This was caught by the build-level verify (Learning 58b), not
by eye — a static read of the comment looked fine.** A `.Rbuildignore`
edit’s authoritative gate is `R CMD build`; running it after EVERY edit
(not just the pattern lines) is what surfaced the invalid-regex abort
before it could ship. **(d) \[zsh-not-bash: no word-split on unquoted
scalars\] The Bash tool runs in zsh, where `for n in $NAMES` does NOT
split an unquoted scalar on whitespace (bash does).** My first verify
loop iterated ONCE over the whole string → created 1 bogus file named
`PROJECT_LEARNINGS CLAUDE ... 2.md` instead of 7. Use an explicit
literal list (`for n in A B C ...`) or a real array, never an unquoted
space-joined scalar, when a loop’s correctness depends on
word-splitting. **(e) \[authoritative build proof\] Staged 14 REAL
spaced dupes (both `2.md` and `copy.md` forms × 7 names) → `R CMD build`
(RC=0) → `tar tzf` (693 files) → ZERO of the 7 names as `.md` (dupes AND
canonicals excluded), real content (DESCRIPTION/NAMESPACE) present;
`trap cleanup EXIT` removed all dupes + the tarball.** Paired with an
all-7-names regex probe (RED-equivalent): OLD misses every dupe form,
NEW catches `2.md`/`copy.md` and does NOT over-match
`<NAME>.Rmd`/`<NAME>_archive.txt`. **(f)
\[scope-the-decision-to-the-owner\] Two genuine author-decisions posed
via `AskUserQuestion` before editing:** pattern style (loose `.*` to
match S58’s shipped line — chosen — vs a targeted `( [0-9]+| copy)?`
with zero over-match) and file scope (the already-ignored cluster —
chosen, pure behavior-none — vs ALSO adding currently-UNignored docs
like `RECOMMENDED_SKILLS.md`/audit files, which would change tarball
contents + shrink the top-level-files NOTE, a DIFFERENT change).
Deferring the latter kept this a pure dupe-guard. **Reflexes:**
\[verify-first\]\[build-not-check\]\[macos-dupe-scan\]\[news-vs-changelog\]\[declare-N/A-honestly\]\[right-sized-orchestration\]\[commit-before-scope-switch\].
**Apply:** treat `.Rbuildignore` as a regex file (balanced/safe comments
only) and re-build after any edit; when scripting verification in this
environment remember it’s zsh (explicit lists, not unquoted scalars);
and when generalizing a guard, cover every member of the class, not just
the triggering file.

#### Learning 60 — Execute the deferred scope-B: exclude ALL non-shipping top-level files to eliminate the “non-standard top-level files” NOTE — and BUILD THE BASELINE TARBALL to enumerate the real set, don’t trust the handoff’s candidate list (S60, repo hygiene / `.Rbuildignore`)

**(a) \[enumerate-from-the-artifact, not the handoff\] The handoff’s
candidate-file list was incomplete; the authoritative set came from
building the baseline tarball.** S59’s SUGGESTED-NEXT \#1 named 4
candidate files (`RECOMMENDED_SKILLS.md`, `TECH_DEBT_AUDIT`,
`PED_GV_AUDIT.{md,html}`) but the actual NOTE comprised **8** — also
`20250504_cran-comments.md`, `methodology_dashboard.py`,
`dashboard.html`, `nprcgenekeepr_notes.txt`. I got the complete set by
`R CMD build` → `tar tzf <tarball> | grep -E '^pkg/[^/]+$'` (the
tarball’s top-level FILES are exactly the NOTE’s input), then
subtracting the 5 standard files
(`DESCRIPTION`/`NAMESPACE`/`NEWS.md`/`README.md`/`LICENSE`). Lesson: for
a “shrink/eliminate the NOTE” task, enumerate from the built artifact,
not from a prose candidate list — and pose the scope `AskUserQuestion`
only AFTER you have the real set, so the options are grounded in
reality. **(b) \[the NOTE is a pure function of tarball top-level
contents\] “Non-standard files/directories found at top level” is
computed by R CMD check from the unpacked tarball’s top-level entries
minus a fixed standard set, so building + listing top-level entries is
the AUTHORITATIVE gate** — a full `devtools::check()` is not needed
(same build-not-check logic as Learning 58b, here applied to a NOTE
rather than a WARNING). Excluding all 8 left exactly the 5 standard
files (685 files vs the 693 baseline = the 8 removed) → NOTE eliminated,
verified directly. **(c) \[consolidate-to-prevent-recurrence\] The root
cause of `20250504_cran-comments.md` shipping was 7 sibling exact-match
lines + a missed 8th.** Replaced all 7 dated
`^YYYYMMDD_cran-comments\.md$` with one `^[0-9]+_cran-comments\.md$` — a
NEW dated cran-comments file is now auto-ignored, killing the “someone
adds a dated file and forgets the ignore line” class. When you find N
exact-match lines for a dated/numbered family, a single regex is the
durable fix. **(d) \[dupe-guard only where dupes happen\] Used
`<NAME>.*` (dupe-guarded) for the macOS-synced methodology/audit docs
(`RECOMMENDED_SKILLS`, `PED_GV_AUDIT`, `TECH_DEBT_AUDIT`) but tight
`^X\.ext$` for
`methodology_dashboard.py`/`dashboard.html`/`nprcgenekeepr_notes.txt`
and the cran-comments regex — those aren’t sync-prone, so the broad form
would only add over-match risk for no benefit.** Match the guard to the
actual threat, don’t apply `.*` reflexively. **(e) \[zsh-nomatch ABORTS,
cont. from 59d\] `rm -f nprcgenekeepr_*.tar.gz` with no matching file
ABORTED the whole script in zsh (`no matches found`) before
`R CMD build` ran** — even with `-f`, zsh errors on an unmatched glob
unless `unsetopt nomatch` / `setopt null_glob`. I’d applied the zsh
lesson to the dupe-staging array but forgot it for the cleanup glob;
prefix `unsetopt nomatch 2>/dev/null; setopt null_glob 2>/dev/null`
before ANY glob that might not match. **Reflexes:**
\[verify-first\]\[build-not-check\]\[macos-dupe-scan\]\[news-vs-changelog\]\[declare-N/A-honestly\]\[right-sized-orchestration\]\[commit-before-scope-switch\].
**Apply:** to “shrink/eliminate a top-level-files NOTE,” build the
baseline tarball to enumerate the real non-standard set, exclude per
owner scope, then re-build and confirm the top level is only standard
files; consolidate dated/numbered families to one regex; and disable zsh
`nomatch` before glob cleanups.

#### Learning 61 — Closing a STALE issue (resolved by a prior session but never formally closed): verify the integration is LIVE and PINNED firsthand before closing — the proof is a test that would FAIL if reverted to the placeholder (S61, issue \#34 close)

**(a) \[verify-the-gating-fact-firsthand, cont. from 57a\] When the
deliverable is closing an issue, the gating fact is the issue’s
resolution CLAIM — establish it firsthand, don’t infer it from “looks
done.”** \#34 (“integrate qcStudbook in modInput”, bug/high) described
placeholder QC (`# TODO: Replace with actual qcStudbook() call` +
`results$cleaned <- rawData`); the current `modInput.R:408/423` already
calls
[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)/[`runQcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/runQcStudbook.md).
The integration landed during the Shiny-module conversion (commit
`7da01afe`, extended `c9019d51`/`bb7f2be6`) and `CHANGELOG.md`’s
Session-20 entry (`:1216-1217`) even recorded “#34 … is stale (already
integrated)” — yet nobody had closed the GitHub issue. **An issue can
outlive its resolution; closing it is itself an evidence-gated
deliverable.** The handoff chain (S20→S60) kept listing \#34 as the
“highest-value open BUG to implement” when CHANGELOG already knew it was
done — a systemic issue-tracker-lags-code gap, not one session’s miss.
**(b) \[pin-test = the integration proof; a \[mutation-check\] sibling\]
The single strongest evidence a claimed-complete integration is REAL is
a test that would FAIL if the code were reverted to the placeholder.**
`test_modInput_qcStudbook.R:296` asserts `"gen" %in% names(cleaned)`;
`gen` is added ONLY by
[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
(`qcStudbook.R:267`), never by the old `results$cleaned <- rawData`
passthrough → that one assertion pins the live path. When verifying “is
X actually wired,” don’t just confirm the call exists — locate (or note
the ABSENCE of) the discriminating test the placeholder would have
failed. **(c) \[firsthand test gate — skips are load-bearing\]
`test_qcStudbook.R` 38/0/0/0 + `test_modInput_qcStudbook.R` 90/0/0/0
(pass/fail/err/skip).** The **0 skips** mattered: the
[`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
module-server tests carry `skip_if_not_installed("shiny")`, so a nonzero
skip would mean the end-to-end module path never executed and the green
was hollow. Confirm `shiny` is installed → those tests actually drove
`modInputServer` (upload → `getData` → assert the cleaned studbook).
**(d) \[right-sized adversarial close under ultracode\] For an
irreversible public act on a HIGH-priority bug, ran a small 3-lens
refute-the-close workflow** (residual-placeholder/live-path ‖
functional-completeness-vs-issue-intent ‖ test-authenticity), each
skeptic told to find a reason NOT to close → all `refuted=false`, high
confidence, 0 gaps. The AUTHORITATIVE test gate was run by the parent
firsthand, not trusted from the agents (agents read code; I ran R). A
3-lens fan-out is proportionate here; a heavier pass would be ceremony,
a solo close would underuse the ultracode budget. (First launch failed
on an unsupported `run_in_background` arg — Workflow always backgrounds;
re-invoked clean, one self-corrected round-trip.) **(e)
\[declare-N/A-honestly, cont. from 57d/58c\] A verify-and-close session
writes no production code or tests → TDD phase N/A every response;**
pre-committed to NOT fixing in-session if a gap surfaced (separate TDD
session) so scope discipline held even with “while I’m here” temptation.
**Reflexes:**
\[verify-first\]\[verify-the-gating-fact\]\[mutation-check\]\[right-sized-orchestration\]\[declare-N/A-honestly\]\[news-vs-changelog\]\[commit-before-scope-switch\].
**Apply:** to close an issue a prior session resolved-but-didn’t-close,
verify the resolution firsthand — find the discriminating test the
original defect/placeholder would have failed (the integration’s “pin”),
run the relevant tests confirming 0 skips on any conditionally-skipped
end-to-end tests, and for a high-value/irreversible close run a small
adversarial refute-the-close pass while keeping the test gate firsthand.
And when picking a backlog “bug,” READ THE CODE to confirm it’s still
live before treating it as implementation work — the tracker can lag the
code.

#### Learning 62 — Backlog-staleness audit: generalize the \#34 finding to the WHOLE tracker via a classify→adversarial-refute fan-out — the refute pass earns its keep by knocking down a false-STALE the owner himself had flagged in 2020 (S62, audit / `docs/audits/`)

**(a) \[generalize-the-#34-finding to the whole tracker\] S61 found ONE
issue (#34) resolved-but-open; this audited all 21 open issues for the
same staleness.** Result: only **2 of 21** are fully done (#14 genotype
support, \#8 no-parentage handling) — both landed in the S20–25
Shiny-module conversion and were never closed; **5 PARTIAL** (#1, \#5,
\#9, \#35, \#37); **14 genuinely OPEN**. The tracker lags the code, but
**only in the resolved→still-open direction** — no issue was falsely
“open” the other way. Confirms the systemic gap is “closing doesn’t
happen,” not “issues are wrong.” **(b) \[adversarial-refute-the-close
EARNS ITS KEEP — not ceremony\] Of the 3 issues a classifier called
STALE, the skeptic confirmed 2 and KNOCKED DOWN 1 (#1).** \#1 (“clear
focal animals list”) has a `Clear Focal Animals` checkbox
(`modPedigree.R:84-88`) that resets `focalIds(character(0L))` — but
**never** resets the file-browser input (`input$focalAnimalFile`; no
`shinyjs::reset` anywhere), so a later “Update” re-reads the
still-uploaded file. **The owner’s OWN 2020 GitHub comment says exactly
this:** *“Introduced a partial fix… a new checkbox
`Clear Focal Animals`… but it does not clear file names read in with the
file browser.”* Closing on the checkbox alone would have re-buried a gap
the author documented six years ago. For an outward-facing close, the
refute step changed the answer on 1/3 of candidates — load-bearing.
**(c) \[verify-close-relevant-calls firsthand — incl. the issue’s own
comments\] Re-verified all 3 close-relevant calls (#14/#8/#1) firsthand
against source AND GitHub.** An agent CITED the \#1 owner comment as
evidence; I confirmed it real via
`gh api repos/:owner/:repo/issues/1/comments` (a bare `gh issue view 1`
printed empty — a TTY/pager quirk; the API showed 1 comment). Agents
read code; the parent runs the authoritative checks (here: `gh api`,
`R`-free grep/Read of `orderReport.R:44-54` + `rankSubjects.R:38,43` for
\#8, the test assertions at `test_modInput_qcStudbook.R:538-545` for
\#14). **(d) \[search-by-CONTENT, not the cited line\] The load-bearing
classifier instruction: old issues’ line numbers have drifted, so grep
the quoted TODO TEXT / function name, never the cited line.** \#35’s
placeholder moved from the issue’s “lines 246-253” to
`modPedigree.R:292-302` (a real
[`trimPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/trimPedigree.md)
call replacing it) — a line-number check misses the resolution; content
search finds it AND reveals it’s only ancestors (`getProbandPedigree`
walks backward only), so PARTIAL not STALE. **(e) \[hold STALE at the
\#34 bar\] STALE = placeholder REPLACED by real logic, not a TODO
deleted/reworded.** 14 OPEN issues still carry the cited TODO VERBATIM
(`fillBins.R:6` “RMS provide description”, `agePyramidPlot.R:60` chimp
TODO, `getPotentialParents.R:92-94` “a bit of a hack”,
`removeAutoGenIds.R:4-6` leading-`U`). \#8 was
confirmed-resolved-but-CAVEATED → downgraded to a close-WITH-NOTE
(functional both-solutions-live, but gated on the optional `origin`
column + no test asserts the `Undetermined`/`rank=NA` branch) — distinct
from \#14’s clean close. **(f) \[Workflow `args` gotcha + build-safe
report placement\] `Workflow({args:[38,37,…]})` arrived as a NON-array →
`pipeline()` threw instantly (0 agents, 59 ms).** Fix: hardcode the
work-list in the script
(`const ISSUES = Array.isArray(args)&&args.length ? args : [38,37,…]`)
and re-launch from the patched `scriptPath` (resume not needed — nothing
cached). Placed the report under `docs/audits/` — build-ignored via
`.Rbuildignore:15` `^docs$` — so it does NOT regress S60’s elimination
of the “non-standard top-level files” NOTE (a top-level dated audit file
like the existing `PED_GV_AUDIT`/`TECH_DEBT_AUDIT` would have re-added
to it). **(g) \[1-and-done: audit ≠ close\] The deliverable is the audit
REPORT with closure RECOMMENDATIONS; closing issues is an outward-facing
follow-up, NOT executed this session** (stated in Phase 1, held to it).
Net available: \#14 clean close, \#8 caveated close, \#37/#35 updates,
ID-cluster (#38/#32/#26/#31 — one feature split across four issues)
consolidation. **Reflexes:**
\[verify-first\]\[completeness-workflow\]\[right-sized-orchestration\]\[news-vs-changelog\]\[declare-N/A-honestly\]\[commit-before-scope-switch\]\[author-decision\].
**Apply:** for a backlog-staleness sweep, fan out one classifier per
issue (instruct: search by CONTENT, hold STALE at the \#34 bar),
adversarially REFUTE every STALE before recommending a close, verify
close-relevant calls firsthand INCLUDING the GitHub issue’s own
comments, write the report under a build-ignored path, and recommend —
don’t execute — the closes (1-and-done).

#### Learning 63 — Executing an audit’s close recommendation is itself evidence-gated: re-verify intent-completeness firsthand (it re-graded \#14 from “clean” to “caveated”), and reconcile EVERY adversarial verdict against a `load_all` run — a “tests failing” refutation was a stale-installed-binary artifact (S63, issue \#14 close)

**(a) \[the audit’s confidence is a HUNCH until re-verified — don’t
inherit it\] S62 classified \#14 a “clean close, high confidence”;
firsthand verification re-graded it to close-WITH-CAVEAT.** The audit’s
per-issue classifier checked the headline (the separate-genotype-file
path works + the test pin passes) and stopped there. My deeper check
found the `commonPedGenoFile` (combined-file) UI mode never
integer-codes string alleles → those genotypes never satisfy
[`hasGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/hasGenotype.md)
and never reach
[`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md).
**Lesson:** a verify-and-close session executing an audit recommendation
must independently re-check *intent-completeness against the WHOLE
issue* (here: does EVERY input mode track, not just the one the audit
cited), not ratify the audit’s grade. An audit recommending a close is
the start of the verification, not the end of it. This is Learning 61(a)
applied to a recommendation rather than a raw backlog item. **(b)
\[reconcile each adversarial verdict against firsthand evidence —
refuted≠true, refuted≠false, until checked\] The 3-lens refute pass
returned 1 confirm + 2 refuted; one refutation was REAL and one was an
ARTIFACT.** The intent-completeness refutation (combined-file caveat)
was real and changed the deliverable. The test-authenticity refutation —
“the test at `:503-547` is actively FAILING, the installed
`modInputServer` is missing the genotype merge block” — was FALSE: the
agent decompiled the **stale installed binary** (compiled RDB) instead
of the source. My own
[`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)
run was 90/0/0/0 and I had read the merge block at
`R/modInput.R:384-396` directly. **Lesson:** when a subagent claims an R
test is failing or code is missing, it may be inspecting
`getNamespaceVersion`/the installed namespace, which can lag the working
tree; the authoritative source gate is `load_all` (or a fresh install)
run by the parent. Don’t accept `refuted=true` at face value AND don’t
dismiss it — verify each verdict firsthand; the value of the refute pass
is the questions it raises, not the verdicts it returns. **(c)
\[stale-install is a recurring R-package verification trap — the version
string is NOT proof of currency\] `getNamespaceVersion("nprcgenekeepr")`
returns the rolling dev `1.1.0.9000` whether the installed binary is
current or months stale.** So a matching version does not mean the
installed code equals the source. An agent decompiling the installed
namespace can therefore “see” code the source has already superseded
(or, here, code the source ADDED that the install lacks). Always test
via `load_all` against the working tree when verifying a source-level
claim; never let an installed-binary inspection stand in for it. **(d)
\[verification flipped the approved premise → re-confirm with the owner,
even about something they once decided\] The combined-file caveat was a
DELIBERATE parity choice in the owner’s OWN commit `c9019d51`.** Even
so, because it changed the close from the “clean” framing the owner
approved (when picking “#14” off my menu) to a caveated one, I surfaced
it via `AskUserQuestion` (clean / caveated / keep-open-narrowed) rather
than silently downgrading or unilaterally closing. The owner chose
caveated close. **Lesson:** when firsthand verification flips the
premise of an approved outward-facing action, re-confirm the framing —
owning a past design decision is not the same as authorizing today’s
issue-state change on the new understanding. (Safeguards: “if what you
find contradicts how it was described, surface that instead of
proceeding.”) **(e) \[“close with caveat” authorizes the close +
comment, NOT new tracker writes — the classifier enforced this
correctly\] I tried to file a 1-line follow-up enhancement for the
combined-file gap; the auto-mode classifier DENIED it** (the approved
action was closing \#14; a new issue is a separate external write).
Right boundary. I captured the residual *in the close comment* instead
(with the file pointers a future enhancement needs) and labeled it “not
filed.” **Lesson:** when an outward-facing scope is approved narrowly,
keep within it — record spun-off gaps in the artifact you ARE authorized
to write, and leave issue-creation to the owner unless explicitly
approved. Don’t treat “optionally I could also…” in a menu option as
standing authorization. **Reflexes:**
\[verify-first\]\[verify-the-gating-fact\]\[reconcile-agent-claims-firsthand\]\[stale-install-trap\]\[author-decision\]\[right-sized-orchestration\]\[declare-N/A-honestly\]\[news-vs-changelog\]\[commit-before-scope-switch\].
**Apply:** when executing an audit’s close recommendation, re-verify the
issue’s FULL intent firsthand (every mode/path, not just the cited one)
— the audit’s grade is a hunch; run a refute-the-close pass and
reconcile EACH verdict against a
[`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)
run (a stale installed binary yields false “tests failing”/“code
missing” refutations); if verification re-grades the close, re-confirm
the framing with the owner via `AskUserQuestion`; and keep new-issue
creation out of a “close with caveat” scope — document spun-off gaps in
the close comment.

#### Learning 64 — When an adversarial gate SPLITS, reconcile the dissenting verdict by REPRODUCTION, not majority vote — a “hold-open” outvoted 2-to-1 was substantively right, and reproducing its claim (optional-column gating silently recreates the original bug) upgraded a footnote caveat into a strengthened one (S64, issue \#8 close)

**(a) \[a split gate is decided by evidence, not a vote count\] The
3-lens refute pass on closing \#8 returned 1 `hold-open` (refuted=true,
high) + 2 `close-with-caveat` (refuted=false, high).** The tempting move
is to go with the 2-of-3 majority. Instead I reconstructed the
dissenter’s central claim in code: a no-parent founder with no
offspring, run through `orderReport()` *without* an `origin` column →
`value="High Value", rank=1` (the exact bug \#8 describes); *with*
`origin` (NA for the ONPRC-born animal) → `"Undetermined"/NA`. The
reproduction CONFIRMED the hold-open verdict’s substance even though it
was outvoted. **Lesson:** adversarial verdicts are inputs to a firsthand
reconciliation, not a poll to be tallied — the lone dissenter is exactly
the one to reproduce, because if it’s right it changes the deliverable.
(Extends Learning 63(b): reconcile EACH verdict; 64 adds: when they
disagree, the reproduction breaks the tie, not the count.) **(b)
\[optional-column gating that SILENTLY recreates the bug is a stronger
finding than a footnote caveat\] The S62 audit graded \#8 “close WITH
CAVEAT” treating the `origin` gating (`R/orderReport.R:31`
`if ("origin" %in% names(rpt))`) as a footnote.** Firsthand, the gating
means the fix does NOTHING — with no warning — for any studbook lacking
the optional `origin` column (absent from most bundled datasets;
`origin` reaches the report only via
`intersect(getIncludeColumns(), names(ped))` at `R/reportGV.R:119`). The
headline symptom is fully present in the default path. **Lesson:**
“implemented but gated on an optional input” is not automatically a
minor caveat — check what happens on the DEFAULT path and whether the
user is warned; a safeguard that silently no-ops is materially worse
than the audit’s one-line note implied. A staleness classifier checks
the headline + cited anchors and stops; it won’t probe the alternate
input path or a long comment thread’s second arc (here, the orphaned
2021 simulated-kinship subsystem + the unresolved “discuss with Matt”
design item). **(c) \[the same premise-flip → re-confirm-with-owner
reflex as S63, second time running\] Firsthand verification again
flipped the approved premise (audit’s footnote caveat → reproduced
silent-failure + orphaned subsystem), so I surfaced it via
`AskUserQuestion`** (close-with-strengthened-caveat /
hold-open-and-re-scope / close-and-file-followup) before the
irreversible `gh issue close`. Owner chose strengthened caveat. Held the
S63 scope boundary: documented the three remaining items (origin-absent
safeguard, regression test, simulated-kinship integration) in the close
comment as candidate enhancements but filed NO new issues. **Lesson:**
the premise-flip reflex isn’t a one-off — every audit-driven close is
gated on re-verifying intent firsthand, and a reproduction (not just a
code read) is the strongest re-grade evidence to bring the owner.
**Reflexes:**
\[verify-first\]\[reproduce-the-dissenting-verdict\]\[verify-the-gating-fact\]\[default-path-not-just-headline\]\[author-decision\]\[surface-premise-flip\]\[scope-discipline\]\[declare-N/A-honestly\]\[news-vs-changelog\].
**Apply:** when an adversarial refute gate splits, reproduce the
dissenting (hold-open) verdict’s claim in code before deciding — a
majority of “close” verdicts does not outweigh one reproduced blocker;
treat optional-input gating as a potential silent-failure (test the
default path + check for a warning), not a footnote; and when
verification re-grades an approved close, re-confirm the framing with
the owner via `AskUserQuestion` and keep new-issue creation out of the
“close with caveat” scope.

#### Learning 65 — “Update a stale inventory issue” is a recompute-from-scratch task, not a patch-the-named-clusters task: the handoff said ≈2 clusters flipped; a call-graph reachability recomputation found 45 of 70 listed functions are now used (S65, issue \#37 update)

**(a) \[recompute, don’t patch the cited clusters\] S64 (inheriting the
S62 audit) framed \#37 as “strike the resolved Shiny-module + genotype
rows; keep the still-accurate unused-export inventory” — ≈7 functions,
“bulk holds.”** A from-scratch reachability recomputation found **45 of
the 70 listed functions are now used by the app** (only 22 + 3 S3
methods still unused); totals 155 exports / 116 used / 39 unused vs the
issue’s 108 / 38 / 70. The per-issue classifier had checked the headline
(the 4 Shiny modules) + the genotype anchor and stopped — the SAME
calibration miss flagged for S62→#14 and S63→#8, here amplified because
\#37 is a 70-row inventory, not a single yes/no. **Lesson:** when the
deliverable is “update a stale inventory,” the unit of work is
recomputing the WHOLE inventory, not patching the rows the handoff
names; the handoff tells you where to start, not how much is stale.
Stale entries the inherited framing would have left in place included
`rankSubjects`, `calcGU`, `filterKinMatrix/Report/Threshold`,
`getOffspring`, `withinIntegerRange` — all now live. **(b) \[call-graph
reachability is the right tool AND it’s reproducible\]
`codetools::findGlobals(f, merge=FALSE)$functions ∩ package-functions`
gives each function’s callees; BFS from the app entry seeds
`{runModularApp, runGeneKeepR, appUI, appServer}` yields the transitive
“used by the app” set; exported names outside it are unused.** This is
more rigorous than grep (it follows the call graph, not text matches)
and more reliable than farming per-function judgments to agents (which
conflate test/`man`/`@examples` references with app use — roxygen lives
in comments and is correctly NOT seen by findGlobals, which parses the
function body). Concrete call paths are the evidence to ship
(e.g. `rankSubjects: appServer → modGeneticValueServer → reportGV → orderReport → rankSubjects`).
Put the method in the issue so the inventory is reproducible, not a
one-time snapshot. **(c) \[name the static method’s blind spots and
CHECK them — don’t hand-wave\] findGlobals misses dynamic dispatch
(`do.call`/`match.fun`/`get` string calls) and S3 generic dispatch.**
Checked explicitly: the only string-dispatched call in `R/` is
`do.call("rbind", …)` (base), and NONE of the 22 still-unused names
appear as a string literal anywhere in `R/` → no dynamic invocation the
closure missed; the 3 S3 methods (`print.summary.*`,
`summary.nprcgenekeeprErr`) aren’t dispatched on the app path (the app’s
[`summary()`](https://rdrr.io/r/base/summary.html) calls hit
`summary.default` on numeric vectors). A stated-and-checked limitation
is verification; an unstated one is a latent error. (Also note the 3 S3
methods aren’t even in `getNamespaceExports` — registered via `S3method`
— yet the issue author counted them as exported; keep them with an S3
caveat rather than silently dropping them.) **(d) \[for an
outward-facing edit, surface FORM + SCOPE before acting\] Editing the
owner’s own issue body is reversible (GitHub keeps edit history) but
still overwrites authored text, and “also add the 17 newer unused
exports” expands scope beyond the literal task.** Both are the owner’s
call → ONE `AskUserQuestion` with concrete previews
(strikethrough-in-place vs rewrite vs comment-only; scope-to-70 vs
add-the-17) let the owner choose grounded in mockups; then a timeline
pointer comment so a silent body edit isn’t invisible to watchers. Same
surface-before-irreversible discipline S63/S64 used for closes, applied
to an UPDATE. **Reflexes:**
\[verify-first\]\[recompute-don’t-patch\]\[reproducible-method-in-the-artifact\]\[name-and-check-the-blind-spot\]\[surface-form-and-scope\]\[right-sized-orchestration\]\[declare-N/A-honestly\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** to “update a stale inventory/audit issue,” recompute the
whole inventory with a reproducible static method (call-graph closure
for “used by the app”), adversarially check that method’s blind spots,
then surface the edit’s form + scope to the owner before the
outward-facing change.

#### Learning 66 — Merging an out-of-band branch into a diverged base: prove the merge is clean BEFORE running it and confirm keep-both AFTER, and re-read any operating file the merge rewrites (S66, merge `chore/methodology-pr2527-wording` → `add-methodology`)

**(a) \[bracket the merge: prove-clean-before, verify-keep-both-after\]
When a branch and its target both touched the same file, don’t
`git merge` and trust the exit code — bracket it with verification.**
The branch (one wording-only commit `ce7d6779`, methodology PR \#25/#27
adoption) edited PROJECT_LEARNINGS.md’s line-3 header blockquote;
Sessions 63–65 had appended Learning rows to its tail. BEFORE:
`git rev-parse HEAD:<file>` showed CLAUDE.md / SESSION_RUNNER.md /
HOW_TO_USE.md blobs were byte-identical to the branch base (→ those
three merge trivially), and
`git diff b7f45901..HEAD -- PROJECT_LEARNINGS.md` showed the divergence
was tail-only (`@@ -224,3`) vs the branch’s line-3 edit (→
non-overlapping); a `git merge-tree` dry run grepped for **actual**
`^<<<<<<<` markers returned **0** (the “changed in both” line it also
prints is informational, NOT a conflict — grep the marker, not that
phrase, or you raise a false alarm). AFTER: confirmed BOTH the new “size
budget” header AND the S63/64/65 tail appends survived (the prompt’s
“keep both” rule), which git’s 3-way merge does automatically for
non-overlapping hunks. **Lesson:** a clean merge-tree dry run +
blob-equality check turns “I hope it merges” into “I know it will, and
here is the keep-both proof”; that bracketing is the whole value-add of
a human/agent over a bare `git merge`. **(b) \[re-read an operating file
the merge rewrites; close out under the NEW text\] This merge rewrote
SESSION_RUNNER.md §3C — my own close-out routing for learnings.** Per
the prompt’s caution I re-read the merged 3C before closing out: it now
routes *adopter-project* learnings to `CLAUDE.md` → Project-Specific
Methodology Adaptations → Project-specific Learnings (which this repo
redirects to PROJECT_LEARNINGS.md) and says explicitly NOT to edit the
synced “Learnings (added by sessions)” table. So this very learning went
to PROJECT_LEARNINGS.md, not the table — the change I merged codified
the rule I then had to follow. **Lesson:** when a merge lands new
wording in a file you operate from (SESSION_RUNNER / SAFEGUARDS /
CLAUDE), treat close-out as governed by the post-merge text, not the
version you read at orient. **(c) \[anchor analysis to live HEAD, not
the handoff’s session number\] The task arrived with out-of-band context
(the branch was prepared outside the session protocol, so S65’s handoff
could not pre-name it), and a mid-flight user note corrected that “S65
has also closed since the prompt was written.”** Because the pre-merge
analysis used `git merge-base` / `merge-tree` against the live HEAD
(`003ae525` = S65) rather than the session number quoted in the
instructions, the correction required zero rework — the analysis was
already current. **Lesson:** compute merge/diff facts against the actual
current ref; then a stale session-number in the instructions is a no-op,
not a redo. **Reflexes:**
\[verify-first\]\[prove-clean-before-merge\]\[verify-keep-both\]\[re-read-rewritten-operating-file\]\[anchor-to-live-HEAD\]\[right-sized-solo\]\[declare-N/A-honestly\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** to any branch merge where both sides touched a shared file —
bracket the merge with a blob-equality + `merge-tree` dry-run
(`^<<<<<<<` only) check and an after-merge keep-both confirmation; and
whenever a merge edits a file you operate from, re-read it before acting
on it. A mechanical single-commit merge with explicit verification steps
is a right-sized SOLO task — no Workflow fan-out needed (ultracode ≠
orchestrate-everything).

#### Learning 67 — Re-scoping a partially-done feature issue: verify which half shipped AND validate the issue’s OWN suggested API against the code (it can cite a signature that doesn’t exist), then expose the semantic fork the one-line ask hides (S67, issue \#35 re-scope)

**(a) \[the issue’s “Suggested Implementation” is a claim to verify, not
a spec to inherit\] \#35 proposed
`trimPedigree(focalIds(), ped, ancestors = TRUE, descendants = TRUE)` —
but `trimPedigree`’s real signature is
`(probands, ped, removeUninformative = FALSE, addBackParents = FALSE)`;
the `ancestors`/`descendants` params never existed.** A re-scope that
copied the issue’s suggested call forward would have handed the
implementer a non-compiling spec. The body ALSO cited stale placeholder
lines 246-253 that had already been replaced by live ancestor logic at
292-302. **Lesson:** when grooming a feature issue, check every API the
body names against the actual function definition — author-proposed code
in an old issue ages exactly like cited line numbers do. Read the
signature, don’t trust the snippet. **(b) \[verify which half of a “X
and Y” ask already shipped — by reading the call chain, not the title\]
\#35 = “include ancestors AND descendants.” Firsthand: ancestors DONE
(`modPedigree.R:292-302` → `trimPedigree` → `getProbandPedigree`, an
upward sire/dam closure at `getProbandPedigree.R:24-40`), descendants
NOT — neither walks downward, and `getOffspring` is single-level only.**
**Lesson:** for a compound feature ask, the re-scope’s first job is to
partition done/not-done against the live call graph; the handoff’s
“ancestors done, descendants not” was a hint to verify, not a finding to
restate (same recompute-don’t-inherit discipline as Learning 65, applied
to a feature rather than an inventory). **(c) \[a one-line ask can hide
a semantic fork — surface it, don’t pick silently\] “Include
descendants” has two non-equivalent implementations: (A) strict lineal —
a new downward closure mirroring `getProbandPedigree`, unioned with
ancestors (focal’s ancestors+descendants only); (B) reuse
[`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)
(`R/getPedDirectRelatives.R:46-59`), which loops parents AND offspring
to closure but thereby also pulls in collateral relatives
(siblings/cousins/mates) = the whole connected pedigree.** The package
has a both-directions primitive already, but it is broader than lineal,
and there is NO transitive descendants-only helper. I documented both as
an open design choice (owner’s pick) rather than committing the issue to
one. **Lesson:** when re-scoping, expose the design fork the ask glosses
over (here, lineal vs all-relatives — plus the UI help text at
`modPedigree.R:125` already says “relatives” while the behavior is
ancestors-only); a grooming/re-scope deliverable is a faithful spec, and
prematurely picking an approach is implementation work the session isn’t
doing. **Reflexes:**
\[verify-first\]\[recompute-don’t-inherit\]\[validate-the-issues-own-API\]\[partition-done-vs-not-by-call-graph\]\[surface-the-semantic-fork\]\[surface-form-and-scope\]\[right-sized-solo\]\[declare-N/A-honestly\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** to re-scope a partially-implemented feature issue — trace the
live call chain to partition which half shipped, validate every API/line
the body cites against the current code (author-proposed snippets go
stale like line numbers), and surface both the edit’s form and any
hidden semantic fork to the owner via `AskUserQuestion` before the
outward-facing edit.

#### Learning 68 — A behavior-change feature’s RED phase must inventory EVERY pre-existing test that asserts the OLD contract, not just add tests for the new behavior; the full-suite regression read is the backstop, not the plan (S68, implement \#35 descendants — first real TDD code session after the S57–S67 non-code run)

**(a) \[grep the test corpus for the contract you’re changing DURING
RED\] The trim feature deliberately flips an existing contract:
ancestors-only → ancestors+descendants.** In RED I wrote the new
helper’s unit tests + 2 integration tests in the obvious file
(`test_modPedigree_processing.R`), but a SECOND pre-existing test in a
*different* file — `test_modPedigree.R:419` (“trims pedigree based on
focal animals”) — still asserted the old result (`nrow==3`,
`expect_false("D")`) for focal `{A,C}`. Under strict-lineal, D is a
child of focal A → a descendant → now correctly included (`nrow==4`; E
stays excluded as a half-sib collateral). The full-suite
clean-regression read caught it in GREEN (2 failures), and I updated it
to the new approved contract with reasoning. **Lesson:** when
RED-planning a behavior change (not greenfield), `grep -rn` the whole
test corpus for the symbol/behavior you’re changing (here `trimPedigree`
/ “trims pedigree”) and bring EVERY old-contract assertion into the RED
set — do not rely on the GREEN regression read to surface them.
CLAUDE.md’s “clean-regression read” is the backstop that proved its
worth here, not a substitute for an exhaustive RED inventory. (FM
\#25-adjacent: the new tests “felt complete” while the contract change
rippled to a test the RED plan never looked at.) **(b) \[a newly-added
exported function trips object_usage_linter until it is installed —
prove it’s an artifact, don’t dismiss it\] After adding
`getDescendantPedigree` and calling it from `modPedigree.R`, lintr
flagged “no visible global function definition for
‘getDescendantPedigree’” — while the existing `trimPedigree` call one
line above did NOT warn.** Cause: `object_usage_linter` resolves against
the INSTALLED namespace; a brand-new function lives only in the dev
(`load_all`) namespace until reinstall. Re-running
`lint(..., object_usage_linter())` after
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
→ **0 warnings**, proving it a staleness artifact, not an
undefined-function bug (the full suite passing already implied runtime
resolution). **Lesson:** a lint warning that fires only for a
newly-added sibling function is the install-staleness artifact — confirm
by linting with the dev namespace loaded, rather than ignoring it OR
“fixing” a non-bug. **(c) \[the project’s phase-gate convention,
exercised for real after a long non-code run\] First actual
RED→GREEN→REFACTOR session since S56-era code work.** The convention
held cleanly: declared the TDD phase atop every response; posed a
SEPARATE pre-RED approach decision (Option A strict-lineal vs Option B
`getPedDirectRelatives`) BEFORE declaring RED; then one
`AskUserQuestion` at each of PRE-RED→RED, RED→GREEN, GREEN→REFACTOR. The
Option A design I previewed to the owner came essentially straight from
S67’s documented spec, making PRE-RED→GREEN nearly mechanical. **0
stakeholder corrections** — approach + every transition were the owner’s
call, applied as chosen. **Right-sized SOLO:** a single-helper feature
verifiable by a focused suite is mechanical/directly-checkable; a
Workflow fan-out would be ceremony (same call S65/S66/S67 made —
ultracode ≠ orchestrate-everything). **Reflexes:**
\[grep-the-contract-during-RED\]\[regression-read-is-the-backstop-not-the-plan\]\[prove-the-lint-artifact\]\[declare-phase-every-response\]\[separate-pre-RED-approach-decision\]\[phase-gate-via-AskUserQuestion\]\[right-sized-solo\]\[news-and-changelog\].
**Apply:** when implementing a feature that changes an existing
behavioral contract, during RED grep the entire test corpus for
assertions of the OLD behavior and bring them all into the RED set;
treat a newly-added-function `object_usage_linter` warning as an
install-staleness artifact (confirm via `load_all`); and keep declaring
the phase + gating each transition via `AskUserQuestion` even on a
small, clean feature.

#### Learning 69 — Closing an issue: verify the shipped code against EACH of the issue’s enumerated acceptance criteria, not just “the suite is green” — a green suite proves the tests pass, not that every sub-ask was addressed (S69, close \#35)

**(a) \[map the close to the acceptance criteria, not to a passing test
count\] \#35 had been re-scoped by S67 into three explicit asks: (1)
union the descendant set with the existing ancestor set, (2) Option A
strict-lineal (no collaterals), (3) align the over-promising “relatives”
UI label.** Before the (irreversible, outward-facing) `gh issue close`,
I confirmed all three firsthand in the working tree: the union at
`R/modPedigree.R:299-305`, the strict-lineal closure in
`R/getDescendantPedigree.R` (no `getParents`/collateral step), and the
help text at `:124-126` now reading “ancestors and descendants”. Running
the three covering test files green was necessary but NOT sufficient —
green proves the assertions hold, not that each enumerated sub-ask
shipped (the UI-label item, e.g., has no failing test gating it).
**Lesson:** when the issue body enumerates acceptance criteria
(especially a re-scoped issue that lists them), the close’s firsthand
evidence is a criterion-by-criterion map of asks → code, with the suite
as a backstop — not a green-suite result standing in for the map.
(Extends the S64/S65 “don’t close without firsthand evidence” rule: the
evidence is acceptance-criteria coverage, not just test status.) **(b)
\[a clean three-session feature lifecycle, each honoring “1 and done”\]
\#35 ran S67 re-scope → S68 implement → S69 close — three sessions, one
deliverable each, no bundling.** S67 produced a faithful spec (and
exposed the Option A/B fork); S68 implemented exactly Option A with full
TDD and shipped + closed-out in one commit; S69 did only the
administrative close after firsthand re-verification. The owner’s
explicit “close \#35” was the gate for the outward-facing action S68
deliberately deferred (FM \#2 “keep going” avoided: S68 did NOT
self-close the issue it implemented). **Right-sized SOLO:** a
single-issue close verifiable by running three test files + reading the
diff is mechanical/directly-checkable — a Workflow fan-out would be
ceremony (same call S65–S68 made; ultracode ≠ orchestrate-everything).
**Reflexes:**
\[verify-first\]\[map-asks-to-code-not-just-green-suite\]\[owner-confirm-before-irreversible-close\]\[1-and-done\]\[right-sized-solo\]\[declare-N/A-honestly\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** before closing any issue, list its acceptance criteria and
confirm each one in the shipped code firsthand; treat a passing suite as
the backstop, not the proof; and never self-close an issue you
implemented in the same session without an explicit owner go-ahead.

#### Learning 70 — Consolidating overlapping issues is a SUBSYSTEM-mapping task, not an issue-reading task — and the adversarial completeness critic (not the facet-mappers) is what finds the structure the issues don’t mention (S70, consolidate \#26/#32/#38 → umbrella \#44)

**(a) \[map the subsystem the issues touch, don’t just summarize the
issues\] \#26/#32/#38 all framed the problem as the single hard-coded
leading-“U” convention.** A firsthand subsystem map (Workflow: 4
parallel facet readers — generation / detection / callers-config / tests
— + a completeness critic) found the package actually carries THREE
independent “unknown/auto-generated” conventions, coupled only by call
ordering in `qcStudbook.R` (`unknown2NA → addUIds → addParents`): (1)
textual `"UNKNOWN"` sentinel (`unknown2NA.R`, case-insensitive
`toupper()=="UNKNOWN"`); (2) the `"U%04d"` prefix — TWO producers
(`addUIds.R:47,54` + `obfuscateId.R:38-43`, a second minter) and 7
detection sites across 4 files with INCONSISTENT case-handling
(`stri_sub`/`startsWith` case-sensitive vs
`grepl("^U", ignore.case=TRUE)`), and NO centralized predicate; (3)
`recordStatus="added"/"original"` (`addParents.R:43-61`) with the
ALREADY-centralized `getRecordStatusIndex()` predicate consumed by 5
functions. **Lesson:** an umbrella/consolidation deliverable’s unit of
work is the subsystem the issues touch, not the issue text — the issues
describe the symptom the reporter noticed, not the landscape underneath.
The umbrella’s quality (and where its “out of scope” boundary falls)
depends on the map, not the titles. **(b) \[the completeness critic
earns its keep — it found what the facet-mappers asserted didn’t exist\]
The four facet agents reported `addUIds` as “exactly ONE site where IDs
are synthesized” and the DETECTION facet said “no centralized predicate
exists.”** The adversarial completeness critic (phase 2, fed the
combined inventory and told to refute) overturned BOTH: `obfuscateId`
mints a second `"U"` id, `addParents` is a second synthesizer (tracked
by `recordStatus`, not the prefix), and `getRecordStatusIndex` IS a
centralized predicate — for a parallel convention the mappers were blind
to because each was scoped to search only for `"U"`. **Lesson:** under
ultracode, the completeness-critic pass on a mapping fan-out is not
ceremony — facet agents are each scoped to one lens and structurally
blind to a parallel mechanism; the critic’s whole job is to find the
mechanism no single lens was searching for. The session’s most
load-bearing finding came from the critic, not the mappers. **(c) \[a
subagent’s map is an assumption until firsthand-verified — especially
before an irreversible/outward-facing action\] Before writing the map
into outward-facing artifacts (creating \#44, closing \#26/#32) I
re-read the 8 load-bearing files myself** (`addUIds`,
`removeAutoGenIds`, `addParents`, `getRecordStatusIndex`, `obfuscateId`,
`unknown2NA`, the `qcStudbook.R:188-199` ordering, the
`modPedigree.R:112` tooltip) rather than copying the workflow’s findings
verbatim — confirming the three-convention thesis and the two-generator
claim in source. This is \[verify-first\]/recompute-don’t-inherit
(Learning 65/67) extended to WORKFLOW output: orchestration breadth does
not lower the firsthand-verification bar for the claims you publish.
**Right-sizing note:** this INVERTS the S65/S67/S69 “single-issue
grooming = solo” call — a MULTI-issue consolidation spanning a subsystem
is exactly where the Workflow fan-out + adversarial verify pays for
itself; the right-size heuristic is *breadth of the surface*, not “it’s
a grooming session.” **Honest miss:** my `AskUserQuestion` option copy
said closing 2 issues = “18 → 16”, forgetting the umbrella is itself a
new open issue (true net **18 → 17**); caught at verification, corrected
in the handoff — decision-aid arithmetic deserves the same care as the
deliverable’s. **Reflexes:**
\[verify-first\]\[map-the-subsystem-not-the-issue-text\]\[completeness-critic-finds-the-parallel-mechanism\]\[verify-workflow-output-before-publishing\]\[surface-form-and-scope\]\[right-size-by-surface-breadth\]\[declare-N/A-honestly\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** to consolidate overlapping issues into an umbrella — map the
whole subsystem they touch (fan-out facet readers + an adversarial
completeness critic to catch parallel mechanisms no single lens searches
for), firsthand-verify every load-bearing claim before the
outward-facing create/close, and surface scope + originals-disposition
to the owner via `AskUserQuestion`; recognize that a multi-issue
consolidation is Workflow-worthy even when single-issue grooming is not.

#### Learning 71 — Implementing a “make it configurable, keep it byte-identical” feature: the byte-identical constraint is satisfied at the EXPRESSION level (a drop-in equivalent, NA-semantics included), and the UNCHANGED tests are the proof — not “the suite is green” (S71, implement \#44/#38, configurable auto-ID format)

**(a) \[byte-identical = expression-level equivalence, and the UNCHANGED
tests are the proof\] \#44’s acceptance criterion \#1 was “with no
configuration, all existing behavior is byte-identical.”** I satisfied
it by replacing each inline check with a predicate that returns the
*identical* value, not a “cleaner” one: `isGeneratedUnknownId(x)` is
`startsWith(as.character(x), prefix)`, which equals the old
`stri_sub(x,1,1)=="U"` / `startsWith(x,"U")` for ALL inputs **including
NA** (both yield `NA` for `NA`, so the replacement is a true drop-in
even inside `ped$sire[<idx>] <- NA` where the index carries NAs).
Generation: `sprintf("U%04d", n)` ≡ `paste0("U", sprintf("%04d", n))`;
`obfuscateId`’s mint stays `size - nchar(prefix)` = `size - 1` for the
1-char default. **The proof was that 3 of the 4 “U”-baking tests
(`test_addUIds`, `test_qcStudbook`, `test_modPedigree`) passed
UNCHANGED** — only the one deliberate case-reconciliation test changed.
**Lesson:** when an acceptance criterion is “byte-identical,” verify
equivalence at the expression level (does the new call return the same
value, NA semantics and all, as the old one?) and let the *unchanged*
characterization tests be the evidence — a green suite full of *edited*
tests proves nothing about back-compat. **(b) \[a fixture’s edge-case
datum is where “reconcile the inconsistency” becomes a concrete
owner-facing fork — grep for it DURING pre-RED\] The abstract ask
“reconcile case-sensitivity” only became a real decision once I found
the lowercase `"u001"` in `test_obfuscateId.R:28`.** That single datum
made the fork concrete: case-sensitive (the issue’s recommendation) is a
deliberate, test-visible behavior change *there*; case-insensitive
breaks no existing test. Grepping the test corpus for the distinguishing
data BEFORE posing the `AskUserQuestion` let me hand the owner an
evidence-based choice naming *exactly which test changes and why*, not a
hand-wave. **Lesson:** before surfacing an approach decision that
“reconciles an inconsistency” or “fixes a latent bug,” grep the fixtures
for the data that distinguishes the options; the decision aid should
cite the specific test/line that flips, so the owner chooses against
evidence, not abstraction. (Pairs with Learning 70’s “decision-aid
care.”) **(c) \[a handoff gotcha naming a “second / easy-to-miss” site
is a RED-inventory line item, closed by a completeness grep\] S70’s
gotcha — “`obfuscateId` is a SECOND `\"U\"` producer, easy to miss; any
format change must touch it too” — was load-bearing.** The mint path
needed `getAutoIdPrefix()` + `size - nchar(prefix)` (not hard-coded
`"U"` + `size-1`) to honor a multi-char configured prefix while staying
byte-identical for the 1-char default; missing it would have left a
second generator un-threaded and failed the round-trip. After GREEN I
ran an exhaustive `grep` for any remaining auto-ID `"U"` literal across
`R/` and confirmed all 7 detection sites + 2 generators were centralized
(the only other `"U"` hits being the unrelated sex-factor level
M/F/U/H). **Lesson:** when a predecessor’s gotcha flags a
“second/parallel/easy-to-miss” site, promote it to an explicit RED-scope
item and close the loop with a completeness grep that proves no instance
of the old literal survives. **(d) \[triage a devtools::check NOTE by
attribution BEFORE fixing — a pre-existing baseline NOTE is not this
session’s to resolve\] check() returned 1 NOTE: the `spelling.R`
comparison test (`spelling.Rout` vs a stale `spelling.Rout.save` reading
“All Done!”).** Rather than reflexively expand `inst/WORDLIST` or
regenerate the `.save` (scope creep, FM \#8), I attributed it:
`spell_check_package(".")` plus the check’s own word list showed **0 of
my new identifiers** among the 54 flagged words — all flagged terms live
in pre-existing files. So the NOTE pre-existed and my session neither
introduced nor worsened it; I flagged it as a future-housekeeping
candidate and left it. **Lesson:** when `check()` yields a NOTE/WARNING,
run the underlying check directly and confirm whether *your* symbols
contribute before acting; “check clean of anything my change caused, 1
pre-existing baseline NOTE” is an honest, correct close state — fixing
baseline noise is a separate deliverable. **Right-size note:** this
contained 6-file single-feature TDD change was correctly SOLO (no
Workflow) — the byte-identical claim was directly checkable via full
suite + exhaustive grep + `check()`; contrast S70’s multi-issue
subsystem map, which WAS Workflow-worthy. The Learning-70(c) heuristic
held: right-size by *breadth of surface*, not “it’s a code session.”
**Reflexes:**
\[byte-identical-is-expression-level\]\[unchanged-tests-are-the-proof\]\[grep-fixtures-for-the-deciding-datum-pre-RED\]\[promote-handoff-gotcha-to-RED-scope\]\[completeness-grep-after-GREEN\]\[attribute-check-NOTEs-before-fixing\]\[right-size-by-surface-breadth\]\[declare-phase-every-response\]\[phase-gate-via-AskUserQuestion\]\[news-and-changelog\].
**Apply:** to implement a “configurable but back-compatible” change —
prove byte-identical by expression-level equivalence (NA semantics
included) and by which characterization tests stay UNCHANGED; grep
fixtures for the edge-case datum that makes a “reconcile” decision
concrete and cite it in the owner’s decision aid; treat predecessor
“second/easy-to-miss site” gotchas as RED-scope items closed by a
completeness grep; and attribute every `check()` NOTE to
mine-vs-baseline before touching it.

#### Learning 72 — Consolidation ≠ deduplication: a consolidation session must let the firsthand research decide whether the issues are duplicates-to-close or distinct-sub-tasks-to-link; a thin shared primitive + severe lift asymmetry ⇒ a LINKING umbrella with both kept open, not closes (S73, consolidate \#31/#28 → umbrella \#45)

**(a) \[the disposition is an evidence outcome, not the pattern
inherited from the prior consolidation\] The task (“consolidate the
parent-ID cluster into an umbrella”) implicitly carried S70’s \#44
template, where the consolidated issues (#26/#32) were TRUE duplicates
and got CLOSED.** Firsthand, \#31 and \#28 are NOT duplicates: they
share only the scalar “estimated conception date = birth − gestation”
and diverge sharply in mechanism, data model, and lift — \#31 is a
bounded in-function refactor over data already present; \#28 needs a NEW
timestamped-colocation subsystem the package wholly lacks, blocked on
the \#11/#12 data pulls. So the right disposition was a LINKING umbrella
(#45) with BOTH sub-tasks kept OPEN and cross-linked — not a
dedup-and-close. I surfaced the duplicate-vs-distinct finding + the
disposition via `AskUserQuestion` rather than force-fitting the prior
pattern (owner chose linking-umbrella, both open). **Lesson:** a
consolidation deliverable’s disposition (close-as-duplicate vs
link-as-distinct-sub-task) is decided by the research, not by the
consolidation that preceded it; “umbrella” does NOT imply “close the
originals.” The signal that says LINK-don’t-merge is a *thin shared
primitive + lift asymmetry* — verify both before assuming dedup. **(b)
\[reading the CORE file firsthand beat both the issue text and the
subagent summaries\] The single most scope-shaping fact — that
`getPotentialParents` ALREADY takes `maxGestationalPeriod` and applies
it sire-side (`:62`), so \#31 is “extend the existing gestation quantity
to the dam side,” not “add gestation to a function with none” — came
from reading the function myself**, not from the issue bodies (which say
“use gestational length” as if none existed) nor verbatim from the facet
readers. It also let the owner pick “reuse the existing param” over “new
option” from an informed position. **Lesson:** in a grooming/design
session, read the core implementation firsthand before drafting — the
issue describes the symptom the reporter noticed, the subagents
summarize, but the *function* tells you what is already half-built and
reframes the ask. **(c) \[the firsthand-verification bar applies to
EVERY layer of a fan-out, the adversarial CRITIC included\] Learning
70(c) verified the facet-MAPPERS before publishing; here the
completeness CRITIC itself overstated — it asserted “no species column
in the data model,” but a firsthand grep found example input pedigrees
DO carry a `species` column (`deidentified_jmac_ped.csv`) plus latent
multi-species intent (#36, `agePyramidPlot.R:60`).** I published the
accurate, narrower fact in \#45 (no species in the CANONICAL fixtures /
parent-ID data model, but present in some inputs) rather than the
critic’s absolute; also re-confirmed firsthand that \#28’s location data
is genuinely absent and that `getPotentialParents` is unwired (only its
test + one ext-data caller → \#37). **Lesson:** a critic that refutes
the mappers can still itself overstate — verify the claim you are about
to publish whoever produced it, including the adversarial pass.
**Right-size note:** this multi-issue subsystem consolidation WAS
Workflow-worthy (breadth of surface — Learning 70’s heuristic held) even
though \#45’s *scope* is narrow (one function); contrast the
single-issue closes S69/S72 rightly ran solo. **Honest −1:** I confirmed
the `species` column is in the raw CSV headers but did NOT trace whether
ingestion (`getPossibleCols`/`toCharacter`) retains it into the internal
pedigree — I stated the verified-narrow fact, but a full trace would
have resolved “is species-specific gestation even reachable today” for
the \#31 implementer. **Reflexes:**
\[verify-first\]\[disposition-is-an-evidence-outcome-not-the-inherited-pattern\]\[thin-primitive+lift-asymmetry⇒link-don’t-merge\]\[read-the-core-file-before-drafting\]\[verify-every-layer-including-the-critic\]\[surface-disposition-via-AskUserQuestion\]\[right-size-by-surface-breadth\]\[declare-N/A-honestly\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** when consolidating overlapping issues, let firsthand research
decide duplicate-vs-distinct (a thin shared primitive + lift asymmetry ⇒
a linking umbrella with sub-tasks kept open, NOT dedup-closes); read the
core implementation yourself before drafting the design (it reveals
what’s already half-built and reframes the ask); and hold the
firsthand-verification bar for every layer of a workflow’s output, the
adversarial critic included.

#### Learning 73 — TDD on an intentional behavior change with exact-set characterization fixtures: derive the new expected sets from an INDEPENDENT read-only reference computation + per-delta justification (never from running the production change), and back them with from-first-principles driving tests that fail on the old code for the RIGHT reason (S74, implement \#31 — gestation-derived dam-exclusion window)

**(a) \[the RED chicken-and-egg of exact-set fixtures, resolved by an
independent oracle + per-delta justification\] When a behavior change
rewrites the expected output of an `expect_identical` characterization
fixture (here `dams_1`/`dams_4`), you cannot write the new expected
values by running the not-yet-written production change — that is
circular (asserting the code matches itself).** Resolution: in PRE-RED I
built a *throwaway, read-only* copy of the function with only the
intended one-line change (in `/tmp`, never committed, never touching
`R/`) as an oracle, diffed it against the shipped output, and
**justified every delta against the biological rule** — each of the 5
dropped dams (`0B7XRI −193 d`, `PHCADH +195 d`, `1SIP4V +183 d`,
`DMI0QY +192 d`, `HV7LZ3 −192 d`) delivered another offspring within the
new ±`maxGestationalPeriod` window, a gestation conflict. The new
fixtures = old minus the justified removals, written into the test in
RED; they fail on shipped code (still returning the old 7/10 sets) for
the right reason. **Lesson:** the new expected values for a
characterization-fixture behavior change come from an *independent*
derivation (a reference computation you can read, plus a per-row “why
this changed” check), not from the production code under test — and the
comment block recording each delta’s justification is what turns
“silently regenerated” into “recomputed and justified” (the umbrella’s
explicit bar). **(b) \[the characterization fixtures lock the surface;
the CORRECTNESS proof is separate, from-first-principles driving tests\]
The exact-set fixtures are a regression net, not a proof of the rule.**
I added two tests that prove the rule independently of the rhesus
fixture’s accidents: (1) a **hand-verifiable synthetic pedigree** — a
focal animal plus `DAM_IN` (another offspring at +200 d) and `DAM_OUT`
(+400 d) — asserting `DAM_IN` is excluded at `maxGestationalPeriod=210`
but retained at `180`, isolating the exact window edge with values
verifiable by hand; and (2) a **differential/responsiveness test**
asserting BRI2MW’s dam set differs between 165 d and 210 d (acceptance
criterion \#2: selection must respond to the parameter, not a hard-coded
half-year). Both fail on shipped code for the right reason — the
synthetic one because shipped uses a fixed ±182.5 d window, the
differential one because shipped dam selection ignored
`maxGestationalPeriod` entirely. **Lesson:** pair brittle exact-set
characterization fixtures with at least one synthetic, hand-computed
test that isolates the changed rule on a minimal controlled input, and
(where the issue frames it as “responds to X”) a differential test
across two values of X; the fixtures catch unintended regressions, the
driving tests prove the intended behavior. **(c) \[“reconcile X if
appropriate” is a prompt to ANALYZE, not necessarily to CHANGE — and
proving a candidate change is a no-op is a real result\] The umbrella
flagged two adjacent things (“reconcile the sire/dam exit-check
asymmetry if appropriate”; consider the preferential band).** Firsthand
analysis showed (i) the exit-check asymmetry (`exit ≥ birth − gestation`
for sires vs `exit ≥ birth` for dams) is **biologically correct** — a
sire need only be present at conception, a dam through to birth — so the
right action was to *document it as intentional*, not change it; and
(ii) widening the exclusion window while leaving the preferential band’s
inner edge at the old half-year is **behaviorally a no-op**, because the
wider exclusion (`:94`) always removes the overlap region before the
preferential intersection (`:97`) runs — so leaving the band untouched
is the minimal *and* equivalent choice (I proved it on the data: outputs
identical either way). I surfaced both as the resolved scope in the
pre-RED `AskUserQuestion` (minimal vs broader-reconciliation),
recommending minimal. **Lesson:** when a spec says “reconcile/consider X
if appropriate,” the deliverable is the *analysis*; “X is already
correct — document it” and “changing X is provably a no-op — don’t” are
both valid, scope-minimizing outcomes — surface them as the recommended
option rather than changing code to look responsive (FM \#8 resisted).
**Right-size note:** this contained single-function change was correctly
SOLO (no Workflow) — the behavior change was directly checkable via an
independent oracle + full suite + `check()`; the read-only exploration
that quantified the deltas was research I needed in my own context, not
a fan-out (Learning 70’s right-size-by-surface-breadth heuristic held).
**Reflexes:**
\[independent-oracle-for-fixture-deltas\]\[justify-every-delta-not-silently-regenerate\]\[synthetic-hand-verifiable-driving-test\]\[differential-test-for-responds-to-X\]\[prove-the-no-op\]\[document-correct-asymmetry-dont-change-it\]\[declare-phase-every-response\]\[phase-gate-via-AskUserQuestion\]\[right-size-by-surface-breadth\]\[news-and-changelog\]\[macos-dupe-scan\].
**Apply:** to TDD an intentional behavior change that rewrites
characterization fixtures — derive the new expected values from an
independent read-only reference computation and justify each delta
against the domain rule (never from the production change under test);
back them with a hand-verifiable synthetic-input test that isolates the
changed rule and, when the ask is “responds to X,” a differential test
across two values of X; and treat “reconcile X if appropriate” as a call
to analyze, where proving X correct-as-is or a change a no-op are valid
minimal-scope outcomes.

#### Learning 74 — A spec/grooming session’s research workflow needs a critic that separates DERIVED findings from INVENTED design, and recompute-don’t-inherit extends to your own project’s prior issue maps (which go stale when later code ships) (S76, spec \#28 colocation data model)

**(a) \[a facet asked to REASON about semantics returns design proposals
dressed as findings — the completeness critic’s job in a spec workflow
is to demote them to ratifiable options\] When a research workflow
includes a facet that *reasons* (semantics, modeling) rather than
*reads* (code, config), its output is a mix of findings and proposals —
and the proposals arrive phrased like derived requirements.** Facet E
(colocation inference semantics) returned an elaborate 3-case model
(missing-sire / missing-dam / both-unknown), a postnatal mother-infant
co-housing window, a grain-confidence ordering, and overlap-duration
weighting — none of which exists in code — as `spec_implications` worded
like settled findings. The completeness critic caught exactly this
(“almost entirely INVENTED design, not derived from package evidence …
presenting invented design as implications risks the spec adopting
unvalidated husbandry assumptions as settled”), so the spec carries them
as **\[OPEN — husbandry ratification required\]**, not fact. The
code-reading facets needed the critic for a different failure: an
inter-reader contradiction (Facet B “species novelCol survives” vs Facet
D “species dropped”), resolved firsthand at `qcStudbook.R:281-283`
(`sb[, c(cols, novelCols)]` ⇒ it survives). **Lesson:** a critic pass
over fanned-out research must classify each item as derived-vs-proposed
and reconcile contradictions; reading facets overstate *absence/claims*,
reasoning facets invent *design* — both must be demoted before they
harden into a spec. **(b) \[recompute-don’t-inherit applies to your OWN
project’s prior issue maps — they go stale when later code ships\] A
design issue’s “verified firsthand” current-state map is verified only
as of its authoring.** Umbrella \#45 (authored S73) carried a line-cited
map of `getPotentialParents`, but S74 (#31) then rewrote that function —
so \#45’s `:72-94` dam-window citation was stale this session. I re-read
the function against the working tree (the spec’s §2 cites the post-S74
lines: window `:83-85`, exclusion `:106`, fallback `:112-115`) rather
than inherit \#45’s map, and said so in the spec. **Lesson:** this is
Learnings 70/72c/73’s recompute principle applied to a *self-authored
umbrella* — the place you are most tempted to trust. If any code an
inherited map describes shipped a change after the map was written, the
map is stale; recompute and note the supersession. **(c) \[the
non-obvious cross-cutting constraint is a spec’s highest-value finding\]
The owner flagged grain + temporal model; the research surfaced a
constraint neither \#28 nor \#45 mentioned: obfuscation coherence.**
`obfuscatePed` jitters each Date column independently
(`obfuscatePed.R:34-37` + a fresh `runif` per element
`obfuscateDate.R:50`, ±30 d default) and covers only the pedigree — so
naïvely obfuscating location dates corrupts the interval-overlap math
(±30 d ≈ 1/5 of gestation) and orphans the location FK. The spec makes
coherent per-animal-delta obfuscation + alias-remap an explicit
requirement (§9), alongside the other cross-cutting items the
originating issue didn’t name (null-coverage matrix, `location = NULL`
byte-identical default, performance at colony scale). **Lesson:** a
data-model spec’s value is disproportionately in the cross-cutting
constraints the originating issue omitted; the critic’s
section-by-section outline exists to force those into view, not merely
to answer the owner’s flagged questions. **Right-size note:** this
multi-facet spec genuinely warranted a Workflow (5 readers + critic) —
unlike the contained single-function S74 change that was correctly SOLO
— because the surface spanned four subsystems (conception primitive,
ingestion/data-model, LabKey/Oracle/ARMS sourcing, obfuscation/temporal)
no single context maps well at once (Learning 70’s
right-size-by-surface-breadth heuristic, the breadth side this time).
**Reflexes:**
\[critic-classifies-derived-vs-invented\]\[reconcile-inter-reader-contradictions-firsthand\]\[recompute-stale-self-authored-map\]\[firsthand-verify-before-outward-facing-spec\]\[surface-cross-cutting-constraints\]\[owner-decisions-via-AskUserQuestion\]\[recommend-with-rationale-plus-open-register\]\[additive-comments-not-body-overwrites\]\[right-size-by-surface-breadth\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** to any spec/design/grooming session that fans out research —
run a completeness critic that (1) classifies each facet item as
derived-from-evidence vs proposed-design (carry proposals as ratifiable
**\[OPEN\]**, never as fact), (2) catches and resolves inter-reader
contradictions firsthand, and (3) names the cross-cutting constraints
the originating issue didn’t; and recompute any current-state map you
inherit — including your own project’s prior umbrella/issue maps —
against the working tree, because later commits silently invalidate
them.

#### Learning 75 — Before putting a spec’s recommendations to the owner, verify each `[REC]` firsthand against the code: a verify-and-sharpen workflow can OVERTURN a prior session’s own recommendations, and most “open decisions” aren’t decisions for the owner at all (S77, ratify \#28’s §13 open-decisions register)

**(a) \[a spec’s own `[REC]` is an assumption-level claim until
re-verified — verifying before asking can flip it\] A
decisions/ratification session’s first job is not to relay the spec’s
recommendations to the owner; it is to re-prove each one against the
working tree, because the spec author could be wrong.** The S76 spec’s
§5-case-3 `[REC]` said both-parents-unknown animals have “no known
anchor,” so colocation should be withheld (require ≥1 known parent). An
item-verifier re-read `getPotentialParents.R:46-48` firsthand and found
the `pUnknown` filter is an inclusive OR — a both-unknown infant is
already processed and, crucially, its **own birth-time location is a
valid dam-side anchor**, identical to the missing-dam case; only the
*sire* side is genuinely anchorless. So the recommendation flipped from
“withhold” to “dam-side colocation only,” and I flagged the overturn to
the owner rather than presenting the spec’s `[REC]` as settled.
Separately, §10 mis-cited \#36 (“Add chimpanzee-specific age pyramid
plot settings”) as the “make species first-class” prerequisite —
firsthand `gh` lookup showed \#36 is a display ticket; first-class
species was un-ticketed (now \#46). **Lesson:** treat every `[REC]` in
an inbound spec — *especially one a prior session of yours authored* —
as a claim to re-verify before the owner sees it; a verify-and-sharpen
fan-out exists precisely to catch the recommendations and citations that
are plausible-but-wrong. This is Learnings 70/72c/73/74b’s
recompute-don’t-inherit applied to *recommendations*, not just
current-state maps. **(b) \[an “open-decisions register” over-states
what the owner must decide — classify each item before asking\] Not
every `[OPEN]` item is an owner-judgment call; many are corollaries of
decisions already made or deferrals gated on absent inputs, and bundling
them all into questions wastes the stakeholder’s attention.** The
completeness critic classified the 8 register items into **4 genuine
owner-decisions** (missing-dam model, both-unknown, output shape,
provenance) vs **4 ratifiable corollaries/deferrals**
(coherent-obfuscation = technical-correctness requirement;
single-species, flat-file, POSIXct = corollaries of S76’s
already-DECIDED scope or `#11/#12`-gated). It also found two §7 policy
gaps absent from §13 despite the register’s “owner sign-off before
sizing” contract. I asked the 4 genuine decisions via `AskUserQuestion`
(2 rounds, **staggered** so the dependent both-unknown item could be
informed by the missing-dam answer — same-call questions are answered
simultaneously, so a true dependency requires a later call), and folded
the rest + the §7 gaps into a single multi-select batch ratification.
Result: 0 stakeholder corrections, all recommendations accepted.
**Lesson:** classify register items as genuine-decision /
safe-ratification / already-decided / out-of-scope-defer before
composing questions; ask the genuine ones with room (crux first), batch
the rubber-stamps, and order calls so dependent decisions follow the
decisions they depend on. **(c) \[record ratifications additively and
split a discovered mis-citation into its own issue\] The deliverable of
a ratification session is the decisions recorded where the spec lives,
plus any tracker corrections the verification surfaced.** I posted the
ratified register as a **new comment** on \#28 (preserving the S76 spec
— FM \#22), each item annotated `[DECIDED-S77]`/`[SIZING]` with the two
corrections inline; added a register-ratified link comment on umbrella
\#45; and (with owner consent via `AskUserQuestion`) filed **\#46** to
own the corrected first-class-species dependency rather than letting the
mis-citation rot in a spec footnote. Carried sizing notes forward for
the implementer (the new species-dependent `postnatalCoHousingWindow`
param; the `obfuscateDate.R:49-57` per-element-re-draw rework that will
break existing obfuscation tests). **Right-size note:** the
verify-and-sharpen Workflow (8 verifiers + critic) was the right call
here — verifying 8 independent `[REC]`s against different files is a
genuine breadth fan-out (Learning 70), and it de-risked owner decisions
by catching the two unsound spec claims before they reached the owner; a
SOLO read would have been tempted to trust the spec’s own
recommendations. **Reflexes:**
\[verify-every-REC-firsthand-before-asking\]\[overturn-prior-session-recommendations-when-wrong\]\[classify-register-items-genuine-vs-ratifiable\]\[stagger-dependent-AskUserQuestion-across-calls\]\[crux-first-batch-the-rubber-stamps\]\[additive-comments-not-body-overwrites\]\[file-an-issue-for-a-discovered-miscitation\]\[carry-sizing-notes-for-the-implementer\]\[right-size-by-surface-breadth\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** to any session that ratifies/grooms an inbound spec’s
open-decisions list — re-verify each recommendation and citation
firsthand (be ready to overturn your own prior session), classify which
items are truly the owner’s to decide vs corollaries to batch-ratify,
stagger genuinely-dependent questions across `AskUserQuestion` calls,
and record the outcome additively where the spec lives while splitting
any discovered tracker error into its own issue.

#### Learning 76 — Triaging “unused exports” is a coupling-and-provenance problem, not a per-function checklist: “app-unreachable ≠ dead code”, caller-edges must be proven REAL (not <roxygen/@seealso>/comment), and mutually-referencing unused sets form CLOSED ISLANDS whose keep/wire/retire decision is a unit (S78, triage \#37)

**(a) \[the disposition axis is wire-in / keep-as-public-API / retire —
and for a dual-purpose package the DEFAULT is keep, not retire\] \#37
lists functions exported but unreached by the Shiny app’s call graph;
the naïve reading is “dead code to delete.”** But CLAUDE.md’s Project
Overview states the package was enhanced “to expose functions for use
either interactively or in R scripts” — so app-unreachable is the
*expected* state for deliberate script API. The right framework is three
dispositions: **wire-in** (clear app value + latent intent — a
built-but-unmounted module, an open-issue mandate),
**keep-as-public-API** (the default for any export that is documented +
tested + has `@examples`/vignette/`inst` use, OR is called by another
package function; retiring is a breaking change), **retire** (genuinely
dead: no tests/examples/vignette/callers, superseded — a HIGH bar).
Result for \#37: 2 wire-in, 37 keep, **0 retire**. **Lesson:** before
triaging “unused” exports, anchor on the package’s own stated dual
nature; “unused by the app” is a reachability fact, not a verdict — make
retire earn a breaking-change-level burden of proof, and treat
keep-as-public-API as the default. **(b) \[an “otherPkgCallers” claim is
worthless until the edge is proven a REAL call —
<roxygen/@seealso>/comment references masquerade as dependencies\] The
investigator agents reported `calcFE`/`calcFG` as “called by
`calcFEFG`/`calcFounderContributions`/`calcRetention`”; the completeness
critic re-grepped with `#'`/comment lines stripped and found they are
called by NOTHING** — `calcFEFG` computes FE/FG via
`calcFounderContributions`+`calcRetention` (the NEW-13/NEW-23 refactor),
and the only `calcFE(`/`calcFG(` tokens in `R/` are refactor *comments*.
The keep disposition survived (script-API grounds), but a
retire-blocking dependency analysis built on the fabricated edge would
have been unsafe. I verified firsthand before recording. **Lesson:** a
caller-edge used to justify keep/block-retire must be a verified
*function call*, not a `@seealso` tag, an `@examples` line, or a
provenance comment; when a fan-out reports “called by X”, re-grep
stripping roxygen/comments before trusting it. (Recompute-don’t-inherit
— Learnings 70c/72c/74b/75a — applied to the dependency graph itself.)
**(c) \[find the CLOSED ISLANDS — maximal unused sets that only call
each other and are reached from nothing live — because their disposition
is COUPLED\] Per-function dispositions hid the real structure: two
islands.** The obfuscation trio
(`obfuscatePed`→`obfuscateId`/`obfuscateDate`, `obfuscatePed` itself
callerless) and the logging/error/export trio (`logModuleEvent` called
only by `safeExecute`+`savePlotToFile`, both of which are callerless).
Neither is reachable from anything live, so each island’s
keep/wire/retire decision must be made as a *unit* — you cannot retire
`obfuscateId` while `obfuscatePed` lives, and “wire in the logging
standard” vs “retire the island” is one decision over three functions.
The investigators’ uniform “high-confidence wire-in” on the logging
island over-stated it (“built-but-unmounted” and
“tried-and-rejected-in-favor-of-ad-hoc” are observationally identical
from the call graph alone — `safeExecute` has zero callers ever; the app
deliberately uses raw `ggsave` at 7 sites), so the critic correctly
demoted it to an owner decision. **Lesson:** a triage of unused exports
must compute the call graph *among* the unused set and surface its
connected components; a closed island is one decision, and absent a
positive intent signal (open issue, TODO, partial wiring) an
unadopted-infra island is an owner roadmap call, not a high-confidence
wire-in. **Right-size note:** the 39-export triage genuinely warranted a
Workflow (9 investigators + critic) — breadth of surface (Learning 70’s
heuristic, breadth side) — and the critic earned its keep on every axis
(fabricated edge, closed islands, confidence calibration, the
\#8-CLOSED/#10-OPEN roadmap correction). **Reflexes:**
\[app-unreachable≠dead-code\]\[keep-as-public-API-is-the-default\]\[retire-must-earn-a-breaking-change-burden\]\[prove-caller-edges-are-real-not-roxygen\]\[re-grep-stripping-comments\]\[compute-the-call-graph-among-the-unused-set\]\[closed-island-is-one-decision\]\[no-high-confidence-wire-in-without-a-positive-intent-signal\]\[verify-critic-claims-firsthand\]\[bind-clusters-to-VERIFIED-open-issues\]\[surface-genuine-decisions-via-AskUserQuestion\]\[file-an-issue-for-a-ratified-wire-in\]\[additive-comments-not-body-overwrites\]\[right-size-by-surface-breadth\]\[declare-N/A-honestly\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** to triage “unused/exported” code — anchor on the package’s
stated script-vs-app duality (keep-as-public-API is the default; retire
carries a breaking-change burden); prove every caller-edge is a real
call (strip roxygen/comments and re-grep) before using it to justify a
disposition; compute the call graph among the unused set and treat each
closed island as a single coupled decision; require a positive intent
signal before assigning high-confidence wire-in; verify every critic
claim firsthand; and record dispositions additively, filing a tracking
issue for each ratified wire-in.

#### Learning 77 — A “wire-in” (#37 integration) is not one shape: a built-but-unmounted module is a mount-only wire-in (no design step), but a never-surfaced exported function is a build-from-scratch wire-in whose FIRST session is a design-decisions step resolving the UX forks — don’t read a handoff’s “implement (Real TDD)” as license to code when the user-facing surface doesn’t exist yet (S79, resolve UX forks for the getPotentialParents wire-in → \#48)

**(a) \[classify the wire-in before scoping it — mount-only vs
build-from-scratch decides the session count\] \#37’s two ratified
wire-ins look alike on the issue list but decompose differently.** ORIP
(#47) is a **mount-only** wire-in: `modORIPReporting.R` already exists
complete+tested, so the whole job is two edits (a `tabPanel` + a
`mod*Server` call) — no product decisions, one session.
`getPotentialParents` (#48) is a **build-from-scratch** wire-in: no
module, no UI, no render/export logic exists, so its app value is gated
on genuine UX forks (where does `maxGestationalPeriod` come from; where
does the surface live; how is it triggered and exported) that are the
owner’s to decide. The honest decomposition is **two sessions** — a
design-decisions session (this one: `AskUserQuestion` the forks, record
them on the tracking issue) then a TDD implementation session — not one.
**Lesson:** before sizing a wire-in, check whether the thing being wired
already exists as a built unit; if it does, it’s a mount (skip design,
go straight to TDD); if it must be built, resolve the product/UX forks
first and treat that resolution as its own deliverable. **(b) \[a
handoff’s “implement (Real TDD)” is a candidate label, not a license to
skip the design gate\] S78’s handoff pre-named this as “Implement the
`getPotentialParents` wire-in … Real TDD.”** Taken literally that
invites starting code; but the surface didn’t exist, so the load-bearing
first move was resolving the forks (FM \#18 — don’t bleed design into
implementation; FM \#23 — the owner’s “explain it” was a question, and
even “Yes, proceed” meant proceed *with the design-step-first path* I’d
recommended, not “start coding”). I explained firsthand, recommended the
path, and only on “Yes” claimed the session (Phase 1B stub), declared
TDD N/A, asked the three forks crux-first via `AskUserQuestion` (0
corrections), recorded them additively on a new issue **\#48** + a link
comment on umbrella \#45, and **stopped before any code**. **Right-size
note:** correctly SOLO — three well-scoped product forks grounded in ~4
files (`getPotentialParents.R`, `appUI.R`, `appServer.R`, the
`fromCenter` producers) is a focused read, not a breadth fan-out; a
Workflow would have been theater (Learning 70’s right-size heuristic,
the contained side — same call as S74/S75). **Reflexes:**
\[classify-wire-in-mount-vs-build\]\[build-from-scratch-wire-in-needs-a-design-session-first\]\[handoff-candidate-label≠skip-the-gate\]\[question-not-instruction-FM23\]\[resolve-UX-forks-via-AskUserQuestion-crux-first\]\[file-an-issue-for-the-ratified-design\]\[additive-comments-not-body-overwrites\]\[right-size-SOLO-for-a-contained-read\]\[declare-N/A-honestly\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** when a handoff or issue names a “wire-in,” first determine
whether the wired unit already exists (mount-only → go straight to a TDD
implementation session) or must be built (build-from-scratch → its first
session resolves the owner’s UX forks and records them on a tracking
issue; implementation is a separate TDD session); never let an inbound
“implement” label skip the design gate when the user-facing surface
doesn’t yet exist.

#### Learning 78 — Executing a build-from-scratch Shiny wire-in under strict TDD: extract the module’s data logic into a PURE helper so the contract is pinned by deterministic tests (not trapped behind reactives), and the mandatory Phase-3E for a module-mount is a headless `AppDriver` boot — which closes the integration gap unit tests cannot, modulo three repo toolchain gotchas (S80, implement \#48: getPotentialParents tab)

**(a) \[find the pure function hiding inside the module and test it
exhaustively; let testServer cover only the reactive glue\] The
render/CSV mapping (`getPotentialParents`’s list-of-lists → a flat
data.frame) was extracted as `flattenPotentialParents()` — Shiny-free —
mirroring the existing `makeFounderStatsTable`/`makeGeneticSummaryTable`
pattern.** That made 7 of 14 tests trivially deterministic (columns;
`NULL`/empty → 0-row empty state; multi-animal flatten; empty-sires →
`""`/0; `write.csv` round-trip), and the **same** helper feeds both
[`DT::renderDT`](https://rdrr.io/pkg/DT/man/dataTableOutput.html) and
the `downloadHandler`, so the on-screen table and the CSV cannot
diverge. The reactive surface
([`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html))
then only had to prove the glue: button → `getPotentialParents` →
flatten → table, plus the two empty-state degradations (no `fromCenter`
column; no unknowns). Note `testServer` runs the **real reactive graph**
(not mocks), so the happy-path test on the rhesus fixture is genuine
module-level integration evidence — the remaining runtime unknown is
only whether the module is actually mounted in the assembled app.
**Lesson:** when TDD-ing a Shiny module, first ask “what is the pure
function hiding inside this module?” — pull it out, test it as
data-in/data-out, and keep the reactive tests thin. Honor the ratified
UI scope while doing so: the owner ratified only the gestation numeric
input, so `minParentAge` stayed a server param (default `2.0`, the QC
value), NOT a second UI input — don’t let the helper’s flexibility tempt
extra surface. **(b) \[Phase-3E for a mount is a headless AppDriver boot
— and three gotchas decide whether it runs and whether you trust its
logs\] Build-clean + `testServer`-green prove the module works in
isolation but NOT that the `tabPanel`/`mod*Server` wiring mounted it and
that `shared$currentPedigree` reaches it; that integration gap is
exactly what Phase-3E must close (FM \#24).** Booting
`inst/shinytest/app.R` (= `shinyApp(appUI(), appServer)`) through
[`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html)
closes it: broken wiring ⇒ no boot or absent controls. Confirmed
firsthand: app boots with full server init, the tab + all four
namespaced controls mount, default 210 is set, navigation works,
existing tabs survive, and the module’s outputs appear only as clean
`shiny:value potentialParents-*` log entries. **Three gotchas:** (1)
under `Rscript` AppDriver aborts with “Reason: On CRAN” unless
`NOT_CRAN=true` is set (non-interactive ⇒ treated as CRAN); (2) the E2E
app drives the **installed** package — `devtools::install()` your dev
code first or the smoke tests stale bits; (3) `shinyBS is not defined`
JS console errors are **pre-existing app-wide noise** (shinyBS popovers
used elsewhere) — to separate a regression from baseline noise, grep the
captured logs for *your module’s namespace*, not the bare word “error”.
The e2e suite is opt-in (`NPRC_RUN_E2E=true`) and skips by default in
`test()`/`check()`, so it is NOT a substitute for actively running the
smoke during the session. **Reflexes:**
\[extract-the-pure-helper-from-the-module\]\[test-pure-logic-exhaustively-reactive-glue-thinly\]\[one-helper-feeds-table-and-CSV\]\[testServer-runs-the-real-reactive-graph\]\[honor-the-ratified-UI-scope-no-extra-inputs\]\[phase3E-for-a-mount-is-a-headless-AppDriver-boot\]\[NOT_CRAN=true-for-AppDriver-under-Rscript\]\[install-dev-code-before-e2e\]\[distinguish-preexisting-log-noise-by-namespace\]\[declare-TDD-phase-every-response\]\[gate-every-transition-via-AskUserQuestion\]\[news-AND-changelog-for-a-user-facing-feature\]\[macos-dupe-scan\].
**Apply:** when implementing a build-from-scratch Shiny wire-in under
strict TDD — extract the data transformation into a pure Shiny-free
helper feeding every output, pin it with deterministic tests, use
`testServer` only for the reactive glue; then run the mandatory Phase-3E
as a headless `AppDriver` boot of the assembled app (install dev code
first, `NOT_CRAN=true`, separate your namespace’s logs from pre-existing
app noise).

#### Learning 79 — Verifying a shipped feature with a live owner click-through: do the click-through FIRST (it catches integration defects headless checks bless), but the example data you stage must pass through the app’s EXACT ingest+validate path — a pre-flight that diverges from the app (reader `na.strings`, or `processQcStudbookResult` vs the raw `errorLst` the UI shows) ships a defective fixture to the owner (S81, owner-confirm close \#48 via click-through)

**(a) \[click-through-FIRST earns its keep — it caught a defect a
headless pre-check had blessed\] The owner ran the live tab and hit
*“Subject(s) listed as both sire and dam”* (offending id blank → “cell
empty”); my pre-flight pipeline run had said CLEAN.** Root cause: the
staged example CSV wrote unknown parents as **empty cells**
(`write.csv(na="")`), but the app’s text reader (`modInput.R:274` =
`read.table(..., fill=TRUE, quote="\"")`, **default `na.strings="NA"`**)
reads `""` as the empty *string*, not `NA`, so `""` appeared in **both**
the sire and dam columns → `correctParentSex.R:71`
`intersect(sires,dams)` flagged it. My pre-check used
`na.strings=c("","NA")`, silently coercing `""`→`NA` and masking the bug
— a pure FM \#24 instance (the verification diverged from the app, so
“headless-passes” blessed a runtime defect). **Fix:** write unknown
parents as **literal `NA`** (matching `ExamplePedigree.csv`) and
re-verify with the app’s exact reader → clean + 50 candidates.
**Lesson:** “click-through first” (the owner’s call here) is not
ceremony — it exercises the real browser→reader→QC→reactive path that
unit/headless checks approximate; let it run before you commit/close.
**(b) \[match the app’s EXACT verification surface, not a convenient
proxy\] Two divergences bit the same session.** (i) The reader’s
`na.strings` (above). (ii) I judged “is the file clean?” by
`processQcStudbookResult()$hasErrors`, but that category-set
**excludes** the `sireAndDam` error — the app’s Errors tab renders the
raw `errorLst$sireAndDam` (from `qcStudbook(reportErrors=TRUE)`)
directly. So my “0 errors” verdict read a signal the UI does not use.
**Lesson:** to pre-verify app-ingested data, read the file the way
`readDataFile` does AND inspect the same `errorLst` components the UI
displays — reuse the app’s functions, don’t reimplement a looser proxy.
**(c) \[diagnose alarming-but-cosmetic warnings FROM THE CODE, don’t
guess a fix\] The *“Column name case changed: fromCenter → fromcenter”*
warning looked like it would break `getPotentialParents` (case-sensitive
on `"fromCenter"`).** Reading `fixColumnNames.R` settled it firsthand:
`:20` lowercases all headers (and logs the caseChange), `:61` restores
`fromcenter`→`fromCenter`; the cleaned studbook keeps `fromCenter`, so
the feature works. Cosmetic (same noise for
`recordStatus`/`geographicOrigin`). The cure for owner alarm is a
source-grounded explanation, not a speculative “try X.” **(d) \[shipped
example data may be adversarial-by-design — stage a purpose-built clean
fixture, owner-chosen\] The package’s pedigree example files are
deliberately error-laden input-error QC fixtures; none reaches a
feature’s happy path.** A live demo of a new feature often needs a
purpose-built clean fixture — here
`inst/extdata/rhesusPedigree_fromCenter.csv` (`rhesusPedigree` +
`fromCenter=TRUE`, unknowns as literal `NA`), with the source chosen by
the owner via `AskUserQuestion` (rhesus vs full-ExamplePedigree vs
modify-in-place; new file avoids blast radius on the many
tests/vignettes referencing `ExamplePedigree.csv`). Surface this in the
handoff so the next demo session doesn’t rediscover it. **Right-size
note:** correctly SOLO — a contained diagnose-and-stage across ~10 files
with interactive owner round-trips is not a breadth fan-out; a Workflow
would have been theater (Learning 70, contained side). **Reflexes:**
\[click-through-first-catches-integration-defects\]\[replicate-the-apps-EXACT-reader-na.strings-fill-quote\]\[inspect-the-raw-errorLst-the-UI-renders-not-just-processQcStudbookResult\]\[reuse-the-apps-functions-dont-reimplement-a-proxy\]\[write-unknown-parents-as-literal-NA\]\[diagnose-cosmetic-warnings-from-the-source\]\[shipped-example-data-may-be-error-fixtures-by-design\]\[stage-a-purpose-built-clean-fixture-owner-chosen-via-AskUserQuestion\]\[new-file-over-modify-in-place-to-bound-blast-radius\]\[owner-confirmed-close-only\]\[right-size-SOLO-for-a-contained-diagnose\]\[declare-N/A-honestly\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** when verifying an app feature with a live click-through — run
the click-through FIRST, but make the pre-flight traverse the app’s
exact ingest+validate path (reader flags AND the same validation surface
the UI renders, by reusing the app’s own functions); write example
pedigrees with unknowns as literal `NA`; expect shipped example data to
be adversarial-by-design and stage a purpose-built clean fixture
(owner-chosen source, prefer a new file over modify-in-place); diagnose
alarming warnings from the source before proposing fixes; and close the
issue only on owner confirmation.

#### Learning 80 — Backfilling a regression E2E test for ALREADY-SHIPPED behavior under strict TDD: the RED→GREEN cycle is degenerate (no production code), so map it honestly — RED authors assertions with TEETH that self-skip when opt-in is off, GREEN re-derives the baked regression value through the app’s EXACT pipeline BEFORE the browser run, and the browser E2E run itself IS the Phase-3E verification; preserve the sibling test idiom over DRY-extraction (S82, opt-in E2E test for the \#48 Potential Parents tab)

**(a) \[declare the degenerate cycle up front and gate it — don’t fake a
failing-first RED\] The deliverable was a durable opt-in E2E test for a
feature that already shipped (S80) and was owner-verified (S81), so
there is NO production code to write and the classic “RED fails, GREEN
makes it pass” does not literally apply.** Rather than perform a fake
failing-first cycle, I declared the honest classification at the
PRE-RED→RED gate (regression/characterization backfill) and mapped the
phases truthfully: RED = author the test so each data assertion has
TEETH (passes only when the shipped feature returns the verified result;
a broken/empty feature renders the empty-state and fails the match) AND
self-skips cleanly when the opt-in env var is off; GREEN = run it
against the shipped feature and confirm green; REFACTOR = lint/tidy. The
RED verification was “run it, watch it self-skip correctly” (`SSSS`, 0
fail/error) — the opt-in equivalent of “watch it fail”. **Lesson:** when
the production code already exists, don’t contort the work into a fake
RED→GREEN — name the degenerate cycle at the gate and define what
RED/GREEN/REFACTOR concretely mean for a test backfill (teeth + clean
self-skip / run-green-against-shipped / lint), so the discipline stays
honest instead of theatrical. **(b) \[GREEN’s real work is re-deriving
the regression value through the app’s EXACT object-under-test, BEFORE
the expensive browser run\] A regression lock (here
`PP_EXPECTED_CANDIDATES <- 50L`) is only as good as the number baked
in.** Before the browser run I re-derived it through the app’s exact
pipeline — `read.csv` (the CSV reader path, `modInput.R:279`) →
`runQcStudbook(minParentAge=2, reportChanges=TRUE)$cleaned` →
`setPopulation` → `findPedigreeNumber`/`findGeneration`
(`modPedigree.R:261-280`) → `getPotentialParents(_, 2.0, 210L)` — NOT
the looser raw-`rhesusPedigree` path the unit test uses. Crucially I
confirmed which object the module actually feeds: it exports
`pedigree = reactive(pedigreeData())` (`modPedigree.R:344`) — the
FILTERED pedigree (generated-unknowns removed), not `processedPedigree`
— and computed the count on BOTH, getting 50 either way, so the browser
E2E passed on the first try. **Lesson:** for a regression-locking test,
independently re-derive the locked value through the production
object-under-test (trace which reactive/return the code actually
consumes, not a convenient proxy) BEFORE the slow end-to-end run; and
when a distinction might matter (filtered vs full pedigree), compute
both and PROVE it’s immaterial rather than assume —
recompute-don’t-inherit (Learnings 70c/72c/74b/75a) applied to the
test’s expected value. **(c) \[the browser E2E IS the Phase-3E runtime
verification, and assertions must have teeth; preserve the sibling idiom
over DRY-extraction\] An opt-in browser E2E that actually runs (chromote
present) is the strongest Phase-3E — real Chrome, real reactive graph,
real upload→QC→pedigree→compute→DT-render→CSV-download — so the GREEN
run doubles as the mandatory runtime smoke (FM \#24 answered head-on,
not “skipped/build-clean”).** The assertions are deliberately teethy:
*“Found candidate parents for 50 animal”*, the DT info text *“of 50
entries”*, and a `get_download` CSV with exactly 50 rows + the
`id,nSires,nDams,sires,dams` header — each fails when the feature is
broken (the empty-state/warning renders instead), unlike the
`grepl(keyword, get_html(app,"body"))` tautology the helper’s own
comments warn passes once the app boots regardless of tab. And in
REFACTOR I did NOT extract the repeated skip/`AppDriver` boilerplate
into a helper: the sibling `test-e2e-*-module.R` files deliberately
repeat it, so DRY-extraction would diverge from the established idiom —
matching siblings beats local cleverness for a regression net.
**Right-size note:** correctly SOLO — a contained single-file test
backfill with interactive TDD gates is not a breadth fan-out; a Workflow
would have been theater (Learning 70/77 right-size heuristic, contained
side). This held even with **ultracode “on”** — the project
methodology + these learnings govern the right-size call, and “use a
Workflow on every substantive task” yields to “right-size by breadth of
surface” when the surface is one file. **Reflexes:**
\[declare-the-degenerate-RED→GREEN-for-a-test-backfill\]\[RED=teeth+clean-self-skip\]\[assertions-must-have-teeth-not-body-grepl\]\[GREEN-re-derive-the-locked-value-through-the-exact-pipeline\]\[trace-which-reactive-the-module-actually-feeds\]\[compute-both-variants-and-prove-immaterial\]\[browser-E2E-is-the-Phase-3E-verification\]\[opt-in-via-NPRC_RUN_E2E+NOT_CRAN+install-first\]\[preserve-the-sibling-test-idiom-no-DRY-extraction\]\[right-size-SOLO-even-under-ultracode\]\[declare-phase-every-response\]\[gate-every-transition-via-AskUserQuestion\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** to backfill a regression test for already-shipped behavior
under strict TDD — declare the degenerate (no-production-code) cycle at
the PRE-RED→RED gate and define RED/GREEN/REFACTOR concretely (teeth +
clean self-skip / run-green-against-shipped + re-derive the locked value
through the exact production pipeline first / lint preserving the
sibling idiom); make every data assertion fail when the feature is
broken; let the real browser E2E run be the Phase-3E runtime
verification; and right-size SOLO for a single-file test even when an
“always use a Workflow” directive is in force.

#### Learning 81 — Executing a MOUNT-ONLY Shiny wire-in (a built-but-unmounted module) under strict TDD is the smallest vertical slice: 2 production edits, RED is the wiring-grep idiom (NOT module unit tests — the module is already tested), and the deparse-grep server test’s teeth come from the Phase-3E AppDriver boot, not the grep; and a mid-session owner QUESTION that reveals new scope → answer firsthand + file an issue, don’t expand the deliverable (S83, wire in the ORIP module \#47; ONPRC-gating deferred to \#49)

**(a) \[the mount-only wire-in is the smallest TDD slice — 2 edits, and
RED is the wiring-grep idiom, not module re-tests\] Learning 77
predicted a built-but-unmounted module is a mount-only wire-in (no
design step); \#47 confirmed it: exactly 2 production edits — an
`appUI.R` `tabPanel` and an `appServer.R` `modXxxServer(...)` call, each
mirroring the 7 siblings.** The module already had unit tests
(`test_modSiteConfig.R`), so RED needed only WIRING tests, and
`test_modGvAndBgDesc.R` is the exact precedent: (1)
`as.character(appUI())` must contain a DISCRIMINATING marker present
only when the module mounts — here the `oripReporting-` namespace prefix
(proves the mount AND the id) plus the module’s unique body text
*“Office of Research Infrastructure Programs”* (proves the right
content, not a generic phrase a sibling tab already emits); (2)
`deparse(appServer)` must contain the server-call name AND the
namespace. Both markers are absent at HEAD → the tests fail as
ASSERTIONS (not errors/undefined-functions) → present after the 2 edits.
**Lesson:** for a mount-only wire-in don’t re-test the module — the RED
net is the wiring grep idiom (appUI-render + appServer-deparse), and
choose a marker that can only appear once the module is mounted
(namespace prefix + unique body text), not one a sibling already
renders. **(b) \[the deparse-grep server test is structurally weak — its
real teeth are the Phase-3E AppDriver boot\] Be honest about the limit:
`grepl("modORIPReportingServer", deparse(appServer))` only confirms the
source TEXT contains the call — near-tautological; it cannot catch a
wrong reactive or a runtime mount failure.** The teeth for the server
wiring are the mandatory Phase-3E — a headless `AppDriver` boot of the
INSTALLED app (Learning 78’s recipe: `NOT_CRAN=true` +
`devtools::install()` first) that proves the tab is REACHABLE (navigate
via `app$set_inputs(mainNavbar="ORIP Reporting")`, assert the active
pane shows the module’s content) and its namespaced outputs register
with **0 module-namespaced JS errors** (grep the logs for YOUR
namespace, separating the pre-existing app-wide `shinyBS` noise). Carry
this script gotcha: `app$get_html(".tab-pane.active")` returns MULTIPLE
nodes (every nested module tabset has its own active pane), so collapse
with `paste(collapse=" ")` or assert on
`app$get_value(input="mainNavbar")` instead of `&&`-ing a length-N
vector (a length-5 vector into `isTRUE`/`&&` halts the run). **Lesson:**
mirror the codebase’s deparse-grep wiring idiom for the RED net, but
treat it as a smoke-alarm wire, not proof — the AppDriver Phase-3E is
what actually verifies a module mount (FM \#24 answered head-on). **(c)
\[a mid-session owner QUESTION that reveals new scope → answer
firsthand, then file an issue; don’t bleed it into the deliverable (FM
\#23 + 1-and-done)\] Mid-close-out the owner asked whether the tab’s
visibility is config/ONPRC-dependent.** I answered FIRSTHAND from the
code (no — it’s a static `tabPanel`, always mounted; only the displayed
center label reflects config, defaulting to “ONPRC” via
`getSiteInfo.R:66` when absent) and changed nothing. The owner then
clarified the tab SHOULD be ONPRC-gated but “that is too much for this
session — put it as an issue.” Correct handling: answer the question,
recognize the clarification as a REAL new requirement, and capture it as
a tracked issue (**\#49**, with evidence-based design options — dynamic
`insertTab`/`removeTab` mirroring the Error List pattern at
`appServer.R:163-242`, and the genuine “show or hide when no config file
→ default ONPRC” product fork flagged) rather than expanding the current
GREEN. The \#47 wire-in stands as built (always-visible); \#49 tracks
the gating. **Right-size note:** correctly SOLO — a 2-edit mount with
interactive TDD gates is not a breadth fan-out; a Workflow would have
been theater (Learning 70/77 contained side), holding under ultracode
“on” (project methodology governs). **Reflexes:**
\[mount-only-wire-in=2-edits-no-design-step\]\[RED=wiring-grep-not-module-re-tests\]\[appUI-render-grep+appServer-deparse-grep
idiom\]\[pick-a-discriminating-marker-namespace-prefix+unique-body-text\]\[markers-absent-at-HEAD-fail-as-assertions\]\[deparse-grep-is-a-smoke-alarm-not-proof\]\[Phase-3E-AppDriver-boot-is-the-real-server-verification\]\[NOT_CRAN+install-first\]\[grep-logs-for-YOUR-namespace-separate-shinyBS-noise\]\[tab-pane.active-returns-multiple-nodes-collapse-or-get_value\]\[a-question-is-not-an-instruction-FM#23\]\[answer-firsthand-from-the-code\]\[new-requirement→file-an-issue-not-scope-creep\]\[1-and-done\]\[owner-confirmed-close-only\]\[right-size-SOLO-even-under-ultracode\]\[declare-phase-every-response\]\[gate-every-transition-via-AskUserQuestion\]\[news-vs-changelog\]\[macos-dupe-scan\].
**Apply:** to a mount-only Shiny wire-in (an existing, tested, but
unmounted module) under strict TDD — write 2 edits (UI tabPanel + server
call) mirroring siblings; RED = wiring-grep tests only (appUI-render for
a discriminating mount marker + appServer-deparse for the call), not
module re-tests; treat the deparse-grep as a smoke alarm and make the
headless AppDriver Phase-3E the real proof of the mount; and when a
mid-session owner question surfaces a new requirement, answer it
firsthand and file an issue rather than expanding the session’s
deliverable.

#### Learning 82 — Gating an existing UI element on DEPLOYMENT config under strict TDD: resolve the product fork AND the approach as a SEPARATE pre-RED AskUserQuestion (both change the test expectations); implement as a PURE predicate + parameterized-UI injection (maps onto the codebase’s own fast test idioms, no browser for core logic); and drive the REAL config path across all scenarios in Phase-3E — which is exactly where a pre-existing latent bug surfaces (flag-and-file, don’t fix) (S84, gate the ORIP tab to ONPRC-only \#49; close \#47; file \#50)

**(a) \[a config-gating change has TWO pre-RED forks — a PRODUCT fork
and a TECHNICAL-approach fork — and BOTH alter the RED expectations, so
pose both as a SEPARATE pre-RED AskUserQuestion, not the RED gate\] \#49
carried a product fork (when no config file exists,
[`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
returns the default fallback `center="ONPRC"` — show or hide the tab?)
and an approach fork (build-time conditional `tabPanel` vs dynamic
`insertTab`/`removeTab`).** Both are load-bearing on the tests: S83’s
wiring test asserted the ORIP tab is ALWAYS present, but under the
owner’s chosen “hide unless a real ONPRC config” that assertion FLIPS to
absent in dev/CI (no config file). Per the phase-gate contract these
author/owner decisions are a SEPARATE `AskUserQuestion` posed BEFORE
declaring RED (distinct from the PRE-RED→RED gate itself). Recompute the
seam firsthand to pick the approach:
[`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
is evaluated ONCE at `shinyApp(appUI(), appServer)` construction
(`runModularApp.R:40`, `inst/shinytest/app.R`), and the deployment
center is fixed per server — so the tab’s presence is a per-deployment
CONSTANT, not a per-session reactive. Build-time gating is therefore
semantically correct AND simpler than the dynamic `insertTab` pattern,
which exists for DATA-driven tabs (Error List, `appServer.R:163-242`)
that genuinely toggle on per-session user input. **Lesson:** when a
gating change has a product fork AND an approach fork that both move the
test expectations, surface both in ONE pre-RED `AskUserQuestion`
(recommend + spell out trade-offs), and let the actual evaluation model
— verified firsthand (build-time-once vs per-session-reactive) — drive
the approach, not the “most consistent with the existing mechanism”
reflex (the existing dynamic-tab mechanism fits a DIFFERENT trigger
shape). **(b) \[implement as a PURE predicate + a parameterized-UI that
INJECTS the resolved config — it maps onto the codebase’s own test
idioms and turns an environment-dependent feature into deterministic,
browserless unit tests\] The sibling `shouldShowChangedColsTab`
(exported, own file, tested as a pure predicate +
`as.character(appUI())` grepl + `deparse(appServer)` grepl) is the exact
precedent.** Mirror it: NEW exported `R/shouldShowOripTab.R` =
`isTRUE(hasConfigFile) && isTRUE(center == "ONPRC")` — and prefer
`isTRUE(center == "ONPRC")` over `identical(center, "ONPRC")` so it’s
robust to a NAMED/attributed `center` (e.g. `getParamDef` could return
one), to `NA`, `NULL`, and length≠1, all → FALSE. Parameterize
`appUI(siteInfo = getSiteInfo(expectConfigFile = FALSE))` so the
integration tests INJECT a `siteInfo` list (`center` + an
existing-vs-nonexistent `configFile` path →
[`file.exists()`](https://rdrr.io/r/base/files.html) is the
discriminator) and assert the tab present/absent DETERMINISTICALLY — no
HOME/config-file mocking, no browser. Gate the `appServer` server mount
on the SAME predicate so UI tab and server module toggle together (a UI
tab whose server isn’t mounted is an empty, non-functional tab); the
`deparse(appServer)` grep for `shouldShowOripTab` is the structural lock
that the mount is gated. **Lesson:** for a config-gated UI element,
extract a PURE predicate (unit-testable like its siblings) and make the
UI function accept the resolved config as a DEFAULTED parameter —
injection converts an environment-dependent feature into fast
deterministic unit tests so the build-equivalent (full suite + lint)
stays quick; reserve the browser for Phase-3E. (Watch the lint false
positive: `object_usage_linter` flags a BRAND-NEW package function as
“no visible global function” until the package is re-installed — confirm
by re-linting after `devtools::install()`, like its already-installed
siblings.) **(c) \[Phase-3E must drive the REAL config path across ALL
gated scenarios — and that is exactly where a pre-existing latent bug
surfaces: flag-and-file, don’t fix; and classify logs by LEVEL not
namespace-mention\] The unit tests inject `siteInfo`, but Phase-3E must
prove the gate works through the REAL `getSiteInfo`→config-file path.**
Bulletproof recipe: generate a temp app dir whose `app.R` does
`Sys.setenv(HOME=<temp dir containing .nprcgenekeepr_config>)` BEFORE
`shinyApp(appUI(), appServer)`, so the child process’s
`getConfigFileName` reads the controlled config regardless of env
inheritance; boot one `AppDriver` per scenario (ONPRC config → tab
present + navigable + 5 outputs register values; SNPRC → absent; no
config → absent; siblings intact throughout). Driving the real config
path made this the FIRST app boot ever performed WITH a config file
present — which immediately crashed on a PRE-EXISTING bug: the
config-loading observer (`appServer.R:63`, from `6457a3a3`) uses
`read.table(sep="=")`, which CANNOT parse the DOCUMENTED config format
(comments, blank lines, multi-line quoted values) that `getSiteInfo`’s
tolerant tokenizer handles — latent in dev/CI only because no config
file exists there. Correct handling (FM \#23 + scope discipline +
1-and-done): do NOT fix it (unrelated to \#49); SIDESTEP it for the
smoke with a stripped single-line `key=value` config both parsers
accept; FILE it (**\#50**) with root cause + repro + suggested fix; note
it in the handoff. Also: a naive Phase-3E log metric
(`sum(grepl("oripReporting", msgs))`) counted INFO-level `shiny:value`
output registrations as “errors” and produced a false FAIL — classify by
log LEVEL/text (genuine `error`-level, minus the pre-existing app-wide
`shinyBS` noise), not by namespace MENTION, before declaring a Phase-3E
result. **Lesson:** verify a config-gated feature by driving the REAL
config path in Phase-3E (HOME-override-in-app.R for full control);
expect that “the first boot with a config present” can expose
pre-existing config-handling bugs — flag-and-file them (don’t bleed a
fix into the deliverable), and sidestep them minimally to complete the
smoke; and judge runtime logs by level/text, not namespace mention.
**Reflexes:** \[config-gating has a PRODUCT fork + an APPROACH fork —
both move the tests\]\[resolve them as a SEPARATE pre-RED
AskUserQuestion not the RED gate\]\[recompute the evaluation model
firsthand: appUI() is built ONCE → per-deployment constant → build-time
gating beats dynamic insertTab\]\[dynamic-insertTab is for DATA-driven
tabs, not deployment-config tabs\]\[mirror the sibling pure-predicate
idiom: own file + exported + unit test + as.character(appUI()) grepl +
deparse(appServer) grepl\]\[isTRUE(x==“ONPRC”) not identical —
names/NA/NULL/length-safe\]\[parameterize appUI(siteInfo=…) and INJECT
config → deterministic browserless tests\]\[gate UI tab AND server mount
on the same predicate so they toggle together\]\[object_usage_linter
false-positives a brand-new fn until installed — re-lint after
install\]\[Phase-3E drives the REAL config path via
HOME-override-in-app.R, one AppDriver per
scenario\]\[first-boot-with-a-config-present can expose pre-existing
config bugs → flag-and-file \#50, don’t fix (FM \#23 +
1-and-done)\]\[sidestep an out-of-scope bug minimally to complete the
smoke\]\[classify Phase-3E logs by LEVEL/text not
namespace-mention\]\[owner-confirmed close only
(#47)\]\[declare-phase-every-response\]\[gate-every-transition-via-AskUserQuestion\]\[news-vs-changelog\]\[macos-dupe-scan\]\[right-size-SOLO-even-under-ultracode\].
**Apply:** to gate an existing UI element on deployment configuration
under strict TDD — resolve the product fork and the technical approach
in a SEPARATE pre-RED `AskUserQuestion` (both change the test
expectations); implement as a PURE predicate (mirroring the codebase’s
sibling tab-visibility predicate) plus a UI function that accepts the
resolved config as a defaulted parameter so tests inject it
deterministically; gate the matching server mount on the same predicate;
and in Phase-3E drive the REAL config-file path across every scenario —
being ready to flag-and-file (not fix) any pre-existing config-handling
bug the first config-present boot exposes, and to classify runtime logs
by level rather than by namespace mention.

#### Learning 83 — Fixing a boot crash caused by a REDUNDANT parse path that diverged from the canonical one: the fix is to DELETE the redundancy and route through the single source of truth, not harden the wrong parser; before reshaping a reactive value grep its consumers (a passed-but-unused value is safe to retype); and since an observer isn’t unit-testable in isolation, extract its risky logic into a PURE helper the observer calls — unit-test the helper, lock the wiring with a deparse-grep, prove the integration in Phase-3E (S85, fix \#50: documented-format config crashes the modular app on boot)

**(a) \[a crash from a REDUNDANT representation that diverged from the
canonical parser → consolidate to the single source of truth; don’t
harden the wrong parser\] The same artifact (the site config file) was
parsed TWO ways:** the tolerant
[`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
tokenizer (`readLines`→`getTokenList`→`getParamDef`, which handles
comments / blank lines / multi-line quoted / comma-separated values)
AND, redundantly, the `appServer` config observer’s
`read.table(configFile, header=TRUE, sep="=")`, which assumes a strict
2-column table and stops with *“line N did not have 2 elements”* on the
documented format (`inst/extdata/example_nprcgenekeepr_config`). The bug
was latent in dev/CI only because no config file exists there (the
`file.exists(configFile)` branch never runs). **Lesson:** when two code
paths parse the SAME artifact differently and one crashes, the fix is
NOT to make the broken parser tolerant (that perpetuates the
duplication) — it is to DELETE the redundant path and route through the
one canonical parser (issue \#50’s suggested fix \#1, owner-chosen over
the minimal `tryCatch`-only patch). “Two parsers for one file format” is
the smell; one source of truth is the cure. Wrap the canonical call in
`tryCatch`(→`flog.warn`+`NULL`) so a missing/malformed file fails SOFT
(the app must reach a stable boot state regardless of a user’s config
file), but make loading actually WORK, not merely not-crash. **(b)
\[before changing a reactive value’s TYPE/shape, grep its consumers — a
“passed but unused” value is safe to reshape\] `shared$config` is wired
into TWO module signatures
(`modInputServer("dataInput", config = reactive(shared$config))` and
`modPedigreeServer(..., config = reactive(shared$config))`) but
referenced by NEITHER module body** (both declare `config = NULL` and
ignore it — confirmed by
`grep -n "config" R/modInput.R R/modPedigree.R`). So switching
`shared$config` from a `read.table` data.frame to the
[`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
named list has ZERO runtime consumer impact. **Lesson:**
recompute-don’t-inherit applies at the DATA-shape level too — before
reshaping a shared/reactive value, grep every consumer to learn what
shape they actually depend on; a value that is plumbed-but-unused is
free to retype, and knowing that converts a “scary type change across
the reactive graph” into a safe local edit. **(c) \[an observer/reactive
isn’t unit-testable in isolation (needs a Shiny session) → extract its
risky logic into a PURE helper, unit-test the helper, lock the wiring
with a deparse-grep, prove integration in Phase-3E\] The crash lived in
an `observe({...})`, which can’t be exercised by a fast `testthat` test
without standing up a session.** Same extract-to-a-test-seam move as
Learning 78 (pure helper for module logic) and 82 (pure predicate for
tab visibility), now applied to a crashing observer: NEW exported
`R/loadSiteConfig.R` (`getConfigFileName(Sys.info())` → `NULL` if no
file, else
`tryCatch(getSiteInfo(expectConfigFile=FALSE), error→flog.warn+NULL)`),
and the observer collapses to a one-liner
`shared$config <- loadSiteConfig()`. The helper gets deterministic
browserless tests via
[`withr::local_tempdir()`](https://withr.r-lib.org/reference/with_tempfile.html) +
`withr::local_envvar(c(HOME=tmp))` (the codebase’s env-override idiom;
copy the example config to
`basename(getConfigFileName(Sys.info())[["configFile"]])` so it’s
OS-correct). Add a **characterization guard** test asserting the OLD
broken call (`read.table(sep="=")`) errors on the documented file — it
is green BEFORE and after the fix (so it’s not a RED driver; classify it
honestly), but it fails loudly if anyone reintroduces the strict parser.
Lock the wiring with a `deparse(appServer)` grep (`loadSiteConfig`
present, `read.table` absent), and prove the integration in Phase-3E by
booting the installed app with the REAL documented config present
(HOME-override-in-`app.R`, `NOT_CRAN=true`, install-first) — the exact
boot S84 had to SIDESTEP with a stripped single-line config now succeeds
with the documented format. **Lesson:** to fix a crash inside a
reactive/observer under strict TDD, push the crashing logic down into a
pure exported helper (fast unit tests with teeth), keep the observer a
one-liner, lock the call site with a structural deparse-grep, and let
Phase-3E’s real-config boot be the integration proof. **Continuation
note:** this is the designed payoff of S84’s flag-and-file — S84
surfaced \#50 on the first config-present boot, sidestepped it, and
filed it as candidate (1) with the exact RED/GREEN/Phase-3E shape; S85
executed that shape. The flag-and-file → next-session-fix loop worked.
**Reflexes:** \[two parsers for one file format is the smell →
consolidate to the single source of truth, don’t harden the wrong
one\]\[fail-soft via tryCatch but make loading actually work\]\[grep a
reactive value’s consumers before reshaping it — passed-but-unused is
safe to retype\]\[an observer isn’t unit-testable → extract a PURE
helper, unit-test it, one-line the observer\]\[withr::local_tempdir +
local_envvar(HOME) is the env-override test idiom; name the config by
basename(getConfigFileName(…)) for
OS-correctness\]\[characterization-guard test locks the root cause but
is green throughout → not a RED driver, classify
honestly\]\[deparse(appServer) grep locks the call site\]\[Phase-3E
boots the REAL documented config that previously crashed — the boot S84
sidestepped\]\[object_usage_linter false-positives a brand-new fn until
installed — re-lint after install\]\[owner picks single-source-of-truth
vs minimal-patch via a SEPARATE pre-RED
AskUserQuestion\]\[declare-phase-every-response\]\[gate-every-transition\]\[news-vs-changelog:
a startup-crash fix is user-facing → NEWS+CHANGELOG\]\[flag-and-file →
next-session-fix loop is the compounding
mechanism\]\[right-size-SOLO-even-under-ultracode\]. **Apply:** to fix a
crash caused by a redundant/divergent parse (or any duplicated
representation of one artifact) under strict TDD — delete the redundant
path and route through the canonical parser (wrapped to fail-soft); grep
the affected value’s consumers first to confirm the reshape is safe;
extract the crashing reactive’s logic into a pure exported helper with
deterministic env-override unit tests; lock the call site with a
deparse-grep and a root-cause characterization guard; and prove it in
Phase-3E by driving the real input that previously crashed.

#### Learning 84 — A durable opt-in browser E2E for a DEPLOYMENT-CONFIG-GATED tab needs both polarities of teeth and a config-injecting app fixture: the POSITIVE case CANNOT use the stock test app (no config → tab hidden) so boot a generated `app.R` that HOME-overrides a real config before `shinyApp()` (S84’s Phase-3E recipe promoted to a reusable test fixture), while the NO-CONFIG negative case is FREE from that same stock `create_test_app()`; reuse the opt-in gate without growing the shared helper, and confirm every gate outcome in-process before the slow browser run (S86, durable opt-in E2E for the ORIP tab \#47/#49)

**(a) \[a config-gated tab’s POSITIVE E2E must construct the app under a
REAL config — the stock app hides it — but the NO-CONFIG negative case
is FREE from that same stock app, so one E2E file mixes a
config-injecting builder with the stock app\] The ORIP tab is build-time
gated (`appUI.R:17`
`showOrip = shouldShowOripTab(siteInfo$center, file.exists(siteInfo$configFile))`,
server mount gated identically at `appServer.R:283-292`), with
`siteInfo` defaulting to `getSiteInfo(expectConfigFile = FALSE)`.** So
the standard installed app (`inst/shinytest/app.R` →
[`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
with no config present) yields the default fallback `center="ONPRC"` BUT
a `configFile` path that does NOT exist → tab HIDDEN. The sibling
`test-e2e-potential-parents-module.R` drives a NON-gated tab via
`create_test_app()` (the stock `inst/shinytest` dir); a config-gated
tab’s POSITIVE case CANNOT reuse it. The fixture: a local
`build_config_app_dir(center)` that writes a temp `app.R` doing
`Sys.setenv(HOME = <temp dir with a complete documented-format .nprcgenekeepr_config>)`
BEFORE `shinyApp(appUI(), appServer)` — S84/S85’s
HOME-override-in-`app.R` Phase-3E recipe, now promoted from a one-off
smoke script to a reusable TEST fixture (`getConfigFileName.R:16` reads
`Sys.getenv("HOME")`, so the child process’s gate reads the controlled
config). Conversely, the NO-CONFIG NEGATIVE case is FREE: the stock
`create_test_app()` app already has no config → the gate correctly hides
the tab, so that block asserts absence against the unmodified installed
app. **Lesson:** for an opt-in E2E of a deployment-config-gated UI
element, the positive case needs a config-injecting app fixture
(HOME-override `app.R`), but the no-config negative case rides the stock
app for free — one self-contained E2E file uses both. Embed the HOME
path as an absolute forward-slash literal
(`normalizePath(winslash="/")`), name the config by
`basename(getConfigFileName(Sys.info())[["configFile"]])` for
OS-correctness, write all 7 params (`getSiteInfo`/`getParamDef`
[`stop()`](https://rdrr.io/r/base/stop.html)s on a missing one when a
file exists), and put the config dir INSIDE the app dir so one
`unlink(recursive=TRUE)` (registered AFTER `app$stop()`) cleans both.

**(b) \[reuse the opt-in gate without growing the shared helper — call
`create_test_app()` for its skip side-effect and discard its returned
path\] The opt-in gate lives in one place
(`helper-shinytest2.R::create_test_app()` skips unless
`NPRC_RUN_E2E="true"`), and the new config-injecting builder must honor
it without duplicating the gate string or modifying a helper 137
call-sites depend on.** The move: `build_config_app_dir()` calls
`create_test_app()` as its first line purely for the skip side-effect
(and to confirm the package is installed), then ignores the stock-dir
return and builds the config app instead. The new test file thus adds
ZERO shared-helper surface and stays fully self-contained — preserving
the sibling “self-contained `test-e2e-*` file” idiom (Learning 80c:
prefer matching the established e2e idiom over DRY-extraction for a
regression net). **Lesson:** when a new opt-in E2E needs the same gate
but a different app dir, invoke the existing gate helper for its
side-effect and discard its path rather than re-implementing the gate or
widening the shared helper — single source of the gate, zero blast
radius on shared test infrastructure.

**(c) \[GATING teeth come in TWO polarities, and you confirm every gate
outcome in-process BEFORE the browser run\] A gate E2E proves both that
the tab APPEARS+functions under the right config AND that it is
genuinely ABSENT otherwise — and the negative polarity is the one a
body-grepl tautology can’t fake.** Positive teeth (ONPRC): the gated
namespace output `#oripReporting-siteInfo` renders **ONPRC** (only true
when the live config reached the module, not the default-fallback path)
plus a DETERMINISTIC download —
`app$get_download("oripReporting-downloadORIPReport")` always writes a
Site section (`Category/Metric/Value`, a `Center=ONPRC` row) even with
no pedigree loaded, so the CSV assertion needs no upload. Negative teeth
(no-config AND SNPRC): `grepl("oripReporting-", get_html(app,"body"))`
is **FALSE** — absence of the namespace is only true when the tab is
genuinely unmounted (a booted-but-wrong-tab app can’t fake it, unlike
the `grepl(keyword, body)` tautology the helper comments warn about).
The SNPRC block specifically proves the gate keys on **center**, not
mere config presence — a discriminator the no-config case alone cannot
establish (config file present, `center!="ONPRC"` → still absent). And
applying Learning 80b’s “re-derive the locked value first” to a
PREDICATE rather than a count: before the slow browser run, confirm all
three gate outcomes in-process
([`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
parse →
[`shouldShowOripTab()`](https://github.com/rmsharp/nprcgenekeepr/reference/shouldShowOripTab.md)):
ONPRC→TRUE, SNPRC→FALSE, no-config→FALSE — so the 4-block browser run
passed first try. **Right-size note:** correctly SOLO — a contained
single-file test backfill with interactive TDD gates is not a breadth
fan-out; a Workflow would have been theater, and this held even with
**ultracode “on”** (the project methodology + these learnings govern the
right-size call; “use a Workflow on every substantive task” yields to
“right-size by breadth of surface” when the surface is one file —
Learning 80c). The degenerate RED→GREEN (already-shipped behavior, no
production code) was declared honestly at the PRE-RED→RED gate (Learning
80a); RED verification = “run it, watch all 4 blocks self-skip” (`SSSS`,
0 fail/error). **Reflexes:** \[config-gated tab’s POSITIVE E2E can’t use
the stock app — build a HOME-override config-injecting app
fixture\]\[promote the Phase-3E HOME-override recipe to a reusable test
fixture\]\[the NO-CONFIG negative case is free from the stock
create_test_app() app\]\[reuse the opt-in gate via create_test_app()’s
skip side-effect, discard its path — no shared-helper
change\]\[self-contained e2e file, no DRY-extraction\]\[embed HOME as
normalizePath(winslash=“/”) absolute literal\]\[name the config by
basename(getConfigFileName(…)) for OS-correctness\]\[write all 7 params
— getParamDef stop()s on a missing one\]\[config dir inside app dir →
one unlink after app\$stop()\]\[two-polarity teeth: positive
namespace-renders-ONPRC + deterministic download-CSV row, negative
grepl-namespace-ABSENT\]\[SNPRC block proves the gate keys on center not
config-presence\]\[confirm every gate outcome in-process BEFORE the
browser run (Learning 80b applied to a predicate)\]\[browser E2E IS the
Phase-3E verification (FM \#24)\]\[opt-in via NPRC_RUN_E2E + NOT_CRAN +
install-first\]\[declare the degenerate RED→GREEN at the
gate\]\[RED=teeth+clean-self-skip (SSSS)\]\[REFACTOR re-verifies
parsing + a fresh browser run when it touches config the app
reads\]\[right-size-SOLO-even-under-ultracode\]\[news-vs-changelog:
test-only → CHANGELOG only\]\[macos-dupe-scan\]. **Apply:** to write a
durable opt-in browser E2E for a deployment-config-gated UI element
under strict TDD — build a config-injecting app fixture (HOME-override
`app.R`) for the positive case, ride the stock app for the no-config
negative case, reuse the opt-in gate via the existing helper’s skip
side-effect (no shared-helper change), assert both polarities of teeth
(gated content + download under the right config; namespace ABSENT under
wrong/no config, with a wrong-center block to prove the gate keys on the
config value not mere presence), confirm every gate outcome in-process
before the slow browser run, and let the real 4-block browser run be the
Phase-3E runtime verification.

#### Learning 85 — A “docfix sweep” under strict TDD: turn a single named example bug into an evidence-based scope via a read-only audit FIRST; the discriminating RED test for a roxygen `@examples` is STRUCTURAL (“the example for F invokes F()”, extracted from `man/<F>.Rd` via `tools::Rd2ex`) — NOT “the example runs” (broken examples often still run); the build-equivalent is actually RUNNING the corrected examples; and new tests for already-correct functions are an honest degenerate cycle (hand-derive expected values + teeth-check by perturbation) (S87, fix 3 `@examples` defects + backfill tests for `kinshipMatrixToKValues`/`getAncestors`)

**(a) \[before scoping a “sweep”, AUDIT the whole surface read-only so
the scope `AskUserQuestion` is evidence-based, not blind — and classify
the false positives\] The handoff named ONE example bug
(`getPedDirectRelatives`), but “sweep” implies breadth.** A cheap
read-only audit (`awk` the `@examples`→def block for every `@export`ed
function; flag any whose example never calls `<fn>(`) found 5 suspects →
3 real defects (`getPedDirectRelatives` severe: called
`getLkDirectRelatives` + omitted required `ped`; `cumulateSimKinships`
called `createSimKinships`; `getIdsWithOneParent` called only sibling
helpers) and 2 FALSE positives (`summary.nprcgenekeeprErr` /
`print.summary.nprcgenekeeprErr` — S3 methods correctly demonstrated via
the [`summary()`](https://rdrr.io/r/base/summary.html)/auto-print
GENERIC; the heuristic can’t see dispatch). Also confirmed firsthand the
“±” candidates `kinshipMatrixToKValues`/`getAncestors` had **zero**
direct test references (`grep -rln` in `tests/testthat/`). **Lesson:**
when a candidate is framed as a “sweep” with an optional “±” tail, run
the breadth audit during PRE-RED (read-only) and present the findings —
real defects, false positives, and coverage gaps — as the scope
`AskUserQuestion` options (per the phase-gate contract, scope is a
SEPARATE pre-RED question). The audit converts “fix the one named bug”
into a deliberate owner choice across the true surface;
recompute-don’t-inherit applies to the scope itself.

**(b) \[the discriminating RED test for a documentation/example defect
is STRUCTURAL, not behavioral — “the example for F invokes F()” —
because broken examples frequently still RUN\] “The documented example
runs without error” is NOT a RED driver here:**
`getPedDirectRelatives`’s buggy example called
`getLkDirectRelatives(ids=...)` which fails SOFT to `NULL` (its
`getDemographics` is `tryCatch`’d — no LabKey, no error), and the other
two called real sibling functions — so all three “ran” at HEAD. The
property that actually encodes the defect is “the `@examples` for `F`
contains a call `F(`”. Test it by extracting the example from the
GENERATED `man/<F>.Rd` via `tools::Rd2ex(rd, out=tmp)` then
`grepl(paste0(fn,"("), code, fixed=TRUE)` (use `fixed=TRUE` — `\(` is
“an unrecognized escape” and is needless here; and require the `(` so a
mere mention in a comment doesn’t satisfy it). Add a NEGATIVE assertion
for the severe case (`getPedDirectRelatives` must NOT call
`getLkDirectRelatives(`). Locate the `.Rd` with
`testthat::test_path("..","..","man",paste0(fn,".Rd"))` and
`skip_if(!file.exists, ...)` so it runs under `load_all`/dev (where
`man/` exists and it’s RED→GREEN) and skips gracefully under an
installed package (no `man/`) — the project’s accepted
context-gated-test idiom. **Lesson:** for a roxygen-example fix under
TDD, the meaningful RED test is structural
(example-invokes-its-own-function), read from the generated `.Rd`;
“example runs” is a weak guard because wrong examples routinely run. The
real “does it run?” check is the build-equivalent below.

**(c) \[the docs build-equivalent is RUNNING the corrected examples;
`document()` must be scope-checked; coverage tests of correct functions
are an honest degenerate cycle; and a user-facing help defect is
NEWS-worthy\] After the GREEN roxygen edits + `devtools::document()`,
the SAFEGUARDS “build-equivalent” for documentation is to actually
execute each fixed example**
([`tools::Rd2ex`](https://rdrr.io/r/tools/Rd2HTML.html)→`source(out, local=new.env())`,
assert no error) — this is what `R CMD check` does and it’s the proof
the new examples work, complementing the structural test. Guard
`document()` for scope: `git status` must show ONLY the intended
`man/*.Rd` (here exactly 3) — restore any unrelated roxygen-version
drift, and confirm `NAMESPACE` is untouched (no new exports for an
example-only change). The two NEW test files
(`test_kinshipMatrixToKValues.R`, `test_getAncestors.R`) exercise
already-correct shipped functions, so they pass from the start — declare
this **honest degenerate RED→GREEN**: hand-derive every expected value
independently (the symmetric kinship matrix’s coefficients; the
recursive sire-then-dam lineage `c("C","A","B","D","A","B")` for the
explicit `ptree`), and TEETH-CHECK by perturbing a value in a throwaway
run to confirm it fails — proving the assertions bite. Build small
deterministic fixtures in-test (a hand-built `ptree`, a 3×3 named + 2×2
unnamed matrix) rather than leaning on dataset structure (note: in
`lacy1989Ped`, `E` is a FOUNDER → use `F` for the `createPedTree`
integration check). **news-vs-changelog:** the `getPedDirectRelatives`
example was a user-facing HELP defect
([`?getPedDirectRelatives`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)
showed the wrong function) → **BOTH** — a NEWS Documentation bullet
(edit `NEWS.Rmd`,
[`rmarkdown::render`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
to `NEWS.md`, verify the diff is EXACTLY the new bullet, no reflow
churn) plus the CHANGELOG entry (NEWS historically lists example/roxygen
fixes). **Right-size note:** correctly SOLO even with **ultracode “on”**
— a docs+tests sweep gated by interactive TDD is not a breadth fan-out;
a Workflow would be theater (the project methodology + Learning 80c/84
govern the right-size call). **Reflexes:** \[audit the whole `@export`
surface read-only BEFORE scoping a “sweep” — `awk` the @examples→def
block for any fn whose example never calls itself\]\[classify S3-method
false positives (example calls the GENERIC → dispatch)\]\[confirm “±”
coverage gaps firsthand via grep -rln in tests/\]\[scope is a SEPARATE
pre-RED AskUserQuestion built from the audit findings\]\[structural RED
test = example-invokes-its-own-fn, extracted from man/.Rd via
tools::Rd2ex\]\[grepl(…, fixed=TRUE) — avoid the `\(` escape, require
the `(`\]\[add a NEGATIVE assertion for the wrong-fn
call\]\[skip_if(!file.exists(man/…)) so it runs under load_all, skips
under installed pkg\]\[docs build-equivalent = actually RUN the fixed
examples (Rd2ex→source, expect no error)\]\[scope-check document(): only
the intended .Rd change, NAMESPACE untouched, restore roxygen-version
drift\]\[tests of already-correct fns = honest degenerate cycle:
hand-derive expected values + teeth-check by perturbation\]\[build
deterministic in-test fixtures, not dataset-shape-dependent
ones\]\[lacy1989Ped E is a founder — use F for ancestors\]\[a
user-facing help defect → NEWS+CHANGELOG; render NEWS.Rmd→NEWS.md, diff
= only the new
bullet\]\[declare-phase-every-response\]\[gate-every-transition-via-AskUserQuestion\]\[right-size-SOLO-even-under-ultracode\]\[Phase-3E
N/A for docs+tests — state it, don’t silently skip\]\[macos-dupe-scan\].
**Apply:** to a “docfix sweep ± tests” candidate under strict TDD —
first run a read-only audit across all exported functions to turn the
one named bug into an evidence-based scope (real defects vs dispatch
false positives vs coverage gaps) and pose that as the pre-RED scope
question; write the RED test as a STRUCTURAL
“example-invokes-its-own-function” check extracted from the generated
`man/*.Rd` (not “example runs”, which broken examples pass); make the
docs build-equivalent the actual execution of the corrected examples;
treat new tests of already-correct functions as an honest degenerate
cycle with hand-derived, teeth-checked expectations; scope-check
`document()`; and route a user-facing help-example correction to BOTH
NEWS and the CHANGELOG.

#### Learning 86 — A version-string HOUSEKEEPING fix is still a real RED→GREEN under strict TDD, and the load-bearing insight is RED-test SCOPE: an un-scoped `grepl` over `as.character(appUI())` was a FALSE PASS at HEAD because the app already renders the dynamic version elsewhere (the title bar via `getVersion()`), so a positive assertion MUST be scoped to the specific element (the About-panel region); choose the root-cause DYNAMIC fix (reuse the existing exported `getVersion()` helper, which reads the version from `DESCRIPTION`) over a hard-coded literal so it can’t drift again (S88, replace stale `Version 1.0.8` in `R/appUI.R:230` + `CLAUDE.md`)

**The trap and the fix.** The deliverable looked trivial (a stale
`Version 1.0.8` string carried since S56), but two non-obvious facts
made it a genuine TDD slice. **(1) A rendered-UI assertion needs
element-scope or it lies.** My first RED rendered the whole
[`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
to HTML and asserted `grepl("Version <pkgver>", html)` (positive) plus
`!grepl("Version 1.0.8", html)` (negative). The positive PASSED at HEAD
— a FALSE PASS — because `appUI.R:47` ALREADY shows
[`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)
(dynamic, with build date) in the title bar, so `"Version 1.1.0.9000"`
was present regardless of the broken About tab; only the negative had
teeth. Fix: scope the assertions to the About panel by slicing the
rendered HTML from its `About GeneKeepR` heading forward (`regexpr` +
`substring(html, i, i + 200L)`) and guard that the heading exists; then
BOTH assertions fail for the right reason at HEAD. **Lesson:** when
asserting on a rendered page that contains the same token in more than
one place, scope the assertion to the element under test, or RED passes
for the wrong reason — a false-positive RED is as dangerous as a missing
test. **(2) Reuse the existing source-of-truth helper.** A
`grep getVersion(` showed the package already had an exported
`getVersion(date=)` wrapping `packageVersion("nprcgenekeepr")`; the
dynamic GREEN is `p(paste("Version", getVersion(date = FALSE)))` (reuse,
DRY) — NOT a fresh inline `utils::packageVersion(...)`. The owner chose
dynamic over hard-coded via a separate pre-RED `AskUserQuestion`
(permanent-over-recurring: kill the drift class at the root). **Phase-3E
for a build-time UI string:** the version is set at UI CONSTRUCTION, not
via server reactivity, so an `AppDriver` boot of the INSTALLED app + a
body-HTML check (`<p>Version 1.1.0.9000</p>` present, `1.0.8` absent) is
sufficient — no tab navigation needed (all `tabPanel`s render into the
DOM at load, just hidden). **news-vs-changelog:** the displayed app
version is user-facing → BOTH NEWS (a Shiny-application bullet; render
`NEWS.Rmd`→`NEWS.md`, diff = only the new bullet) and the CHANGELOG.
**Right-size:** correctly SOLO even under **ultracode “on”** — a
two-edit fix gated by interactive TDD is not a breadth fan-out (project
methodology + Learning 80c/84/85 govern). **Reflexes:** \[housekeeping ≠
trivial — scope it as a real RED→GREEN\]\[scope a rendered-UI assertion
to the element under test — a whole-page grepl FALSE-PASSES when the
same token appears elsewhere (here the title bar’s
getVersion())\]\[slice the element by its heading: regexpr(“About
GeneKeepR”) + substring(…,i,i+200L), guard the heading exists\]\[grep
for an existing source-of-truth helper before writing an inline one —
getVersion(date=FALSE) reads packageVersion\]\[prefer the dynamic
root-cause fix over a literal that re-drifts
(permanent-over-recurring)\]\[body-only edit to a UI fn → no
document()/NAMESPACE/DESCRIPTION change; utils already imported, helper
already exported\]\[Phase-3E for a build-time UI string = AppDriver
body-HTML check on the INSTALLED app; tabPanels are in the DOM at load,
no navigation needed\]\[news-vs-changelog: displayed version is
user-facing → BOTH\]\[declare-phase-every-response\]\[separate pre-RED
approach AskUserQuestion when the choice changes test+impl (dynamic vs
hard-coded)\]\[gate-every-transition-via-AskUserQuestion\]\[right-size-SOLO-even-under-ultracode\]\[macos-dupe-scan\].
**Apply:** to a stale-string / version-display housekeeping fix in a
Shiny UI under strict TDD — write a RED test that renders the real UI
function and SCOPES the positive+negative assertions to the specific
element (don’t grep the whole page; a duplicate token elsewhere will
false-pass), reuse any existing exported version/source-of-truth helper
for a dynamic root-cause fix instead of a literal, verify the live
string via an AppDriver body-HTML check on the installed app, and route
the user-facing displayed version to BOTH NEWS and the CHANGELOG.

#### Learning 87 — Fixing a “noisy warning” bug under strict TDD: REPRODUCE firsthand FIRST to establish it is noise-not-data-loss (which decides the whole fix shape); suppress it SURGICALLY with `withCallingHandlers` + message-matched `invokeRestart("muffleWarning")` (never blanket `suppressWarnings`), and prove the surgery with teeth that an UNRELATED warning still propagates; consolidate across all readers via a shared `@noRd` internal helper (the package’s non-exported convention → `document()` no-op); and test a server-internal closure structurally while putting behavioral teeth on the exported readers (S89, fix \#4 — “incomplete final line found by readTableHeader” on files with no trailing newline)

**The shape of the fix is decided by reproduction, not the bug report.**
Issue \#4 reported
`"incomplete final line found by readTableHeader on '...0.txt'"` from a
Shiny text upload. The naive reading (“a final line is incomplete → a
row is dropped”) would lead to a file-normalization fix. **Reproducing
firsthand** (write a CSV with no trailing newline, read it, capture
warnings + `nrow`) showed the opposite: `read.table`/`read.csv` read
**every** row correctly (`nrow == 3`, last row intact) and merely emit a
*cosmetic* warning. That single fact decided everything — the fix is to
**suppress the warning**, not to recover a row — so
recompute-don’t-inherit applies to the BUG’S ACTUAL BEHAVIOR before
designing anything. **(1) Surgical, not blanket.** The mechanism is
`withCallingHandlers(expr, warning = function(w) if (grepl("incomplete final line", conditionMessage(w), fixed = TRUE)) invokeRestart("muffleWarning"))`
— it muffles ONLY that one warning and lets every other warning (a
genuinely malformed file, a config problem) reach the caller.
[`suppressWarnings()`](https://rdrr.io/r/base/warning.html) would have
been wrong: it hides real problems too. The discriminating RED teeth for
“surgical” is a test that an UNRELATED `warning("...")` STILL propagates
(`expect_warning`) — and the strongest RUNTIME proof, in Phase-3E, is
that `getFocalAnimalPed`’s unrelated “configuration file is missing”
warning still fires while the incomplete-final-line one is gone. A “no
warnings at all” assertion would be both untestable for that reader (the
config warning legitimately fires without a DB) and semantically wrong
(it would mean blanket suppression). **(2) Lazy-eval makes the wrapper
trivial.** `muffleIncompleteFinalLine(expr)` takes `expr` as an
unevaluated promise; `withCallingHandlers(expr, ...)` forces it only
after the handler is registered (the same idiom `suppressWarnings`
itself uses) — so no `substitute`/`eval` gymnastics are needed. **(3)
Consolidate via a shared `@noRd` internal helper.** The owner chose
(separate pre-RED scope `AskUserQuestion`: all-readers-via-helper vs
named-readers vs app-only) the **root-cause** scope — wrap the read at
all four sites (`getPedigree`, `getGenotypes` → `read.table`;
`getFocalAnimalPed` → `read.csv`; `modInput.R`’s `readDataFile` text +
CSV branches) through one helper, over fixing only the reported upload
path. `@noRd` is the package’s established convention for non-exported
internals (confirmed via
`getRecordStatusIndex`/`readExcelPOSIXToCharacter` — no `man/*.Rd`,
referenced in tests as `nprcgenekeepr:::`), so `document()` is a
**no-op** (no NAMESPACE/`man/`/DESCRIPTION churn) — scope-check
`git status` after to confirm. **(4) Test a server-internal closure
structurally; put behavioral teeth on the exported readers.**
`readDataFile` is a closure defined inside `modInputServer` — not
callable without standing up a Shiny session — so the practical seam is
a `deparse(body(modInputServer))` grep that the body references the
helper (honest structural lock, weaker than behavioral). The behavioral
teeth live where the functions are directly callable: the helper unit
tests and `getPedigree`/`getGenotypes` (no external deps, return data +
assert no warning + rows preserved). **Phase-3E** for an exported-reader
fix = call the readers in the INSTALLED package on a no-newline input
(warning gone, rows preserved) PLUS a control file WITH a trailing
newline (still reads cleanly — no regression) PLUS the surgical proof
(unrelated warning still propagates). **Issue left OPEN** pending owner
confirmation (standing close-only-on-owner-confirmation rule — the owner
picked \#4 to fix but has not yet accepted the fix). **Right-size:**
correctly SOLO even under **ultracode “on”** — a one-bug fix gated by
interactive TDD is not a breadth fan-out; a Workflow would be theater
(project methodology + Learning 80c/84/85/86 govern). **Reflexes:**
\[REPRODUCE a “noisy warning” bug firsthand FIRST — noise-vs-data-loss
decides the whole fix shape (suppress the warning vs recover a
row)\]\[recompute-don’t-inherit applies to the bug’s actual behavior,
not just the report’s wording\]\[surgical muffle = withCallingHandlers +
message-matched invokeRestart(“muffleWarning”), grepl(…,
fixed=TRUE)\]\[NEVER blanket suppressWarnings — it hides real
problems\]\[teeth for “surgical”: an UNRELATED warning must STILL
propagate (RED test + Phase-3E runtime proof)\]\[for a
DB/config-dependent reader assert ABSENCE of the SPECIFIC warning, not
zero warnings — the config-missing warning legitimately fires without a
DB\]\[withCallingHandlers(expr,…) lazy-eval promise idiom — handler
registered before force, no substitute/eval needed\]\[consolidate across
readers via ONE shared @noRd internal helper — the package’s
non-exported convention → document() no-op, scope-check git
status\]\[server-internal closure (readDataFile in modInputServer) →
structural deparse-grep seam; behavioral teeth on the directly-callable
exported readers + the helper\]\[non-exported internals referenced in
tests as nprcgenekeepr:::\]\[scope is a SEPARATE pre-RED
AskUserQuestion: all-readers-via-helper vs named-readers vs app-only;
owner picks root-cause over symptom\]\[Phase-3E = call INSTALLED readers
on no-newline + a control with-newline file (no regression) + the
surgical proof\]\[leave the issue OPEN pending owner
confirmation\]\[declare-phase-every-response\]\[gate-every-transition-via-AskUserQuestion\]\[news-vs-changelog:
a file-reading bug fix is user-facing → BOTH (render NEWS.Rmd→NEWS.md,
diff = only the new bullet; curly-quote/en-dash conversion is expected,
not churn)\]\[right-size-SOLO-even-under-ultracode\]\[macos-dupe-scan\].
**Apply:** to fix a “noisy but harmless warning” bug under strict TDD —
first reproduce firsthand to confirm it is noise (data preserved) so the
fix is suppression not recovery; suppress it surgically with
`withCallingHandlers` + a message-matched
`invokeRestart("muffleWarning")` (never blanket `suppressWarnings`), and
write RED teeth that an unrelated warning still propagates; consolidate
across every affected reader through one shared `@noRd` internal helper
(document() stays a no-op); test any server-internal closure
structurally (deparse-grep) while putting behavioral teeth on the
directly-callable exported functions; and in Phase-3E exercise the
installed readers on the bad input, a clean control input, and confirm
the surgery left other warnings intact.

#### Learning 88 — Writing a BEHAVIORAL test for an already-shipped fix: DE-RISK THE FIXTURE before the mechanism — validate firsthand that your fixture actually reproduces the bug condition in plain code, or you burn cycles blaming the app for a fixture artifact; the `"incomplete final line"` warning only fires for SMALL files (the `readTableHeader` scan must reach the unterminated line) AND is a console-only artifact unobservable in the assembled Shiny app, so the warning-suppression teeth live in an in-process `shiny::testServer` test (tiny fixture, `withCallingHandlers`) while the browser E2E owns end-to-end data integrity; the un-muffle teeth round-trip is what exposes a toothless assertion (S90, behavioral upload-path tests for \#4 + close \#4)

**The cycle-burning mistake, and the lesson that prevents it.** The
deliverable was “a behavioral E2E for the modInput upload path” for \#4
(S89 covered it only structurally). I built the browser E2E and the
testServer test on a convenient fixture — a no-trailing-newline copy of
`ExamplePedigree.csv` (3694 rows) — and the un-muffle teeth round-trip
kept coming back GREEN (the warning-absence assertion passed even with
the muffle removed). I spent SIX browser diagnostics + multiple
install/`load_all` round-trips hypothesizing that the assembled Shiny
app *swallows* the deferred warning (it doesn’t), before finally
checking the FOUNDATIONAL assumption I had never validated: **does the
no-trailing-newline `ExamplePedigree` even emit the warning in a plain
`read.csv`?** It does NOT. **Root cause:** `read.table`/`read.csv` emit
`"incomplete final line found by readTableHeader"` only when the header
/ type-detection scan (~the first few lines) actually REACHES the
unterminated final line — i.e. for SMALL files (≤ ~5 lines, the
condition the user hit with `0.txt`); a 3694-row file’s scan never
reaches the end, so no warning. Every “the app swallows it” conclusion
was a FIXTURE ARTIFACT. Swapping to a TINY 4-line fixture (header + 3
founder rows of `ExamplePedigree`) made the warning fire and the teeth
appear instantly. **Lesson:** before building ANY teeth (browser
`get_logs`, `testServer` `withCallingHandlers`) on a fixture, prove
FIRST — in plain code, no Shiny — that THAT fixture reproduces the exact
failure condition (here: a `withCallingHandlers` around a plain
`read.csv(fixture)` capturing the message). De-risk the fixture, not
just the observation mechanism. A teeth round-trip that won’t go RED
means EITHER the assertion is toothless OR the fixture doesn’t trigger
the bug — check the fixture first; it is the cheaper, more common
culprit.

**(1) \[the muffle’s effect is NOT browser/log-observable in the
assembled app → the warning-suppression teeth belong in an in-process
testServer test, not the browser E2E\] Two independent reasons the
browser can’t teeth-test this muffle:** the `"incomplete final line"`
warning is a console-only artifact (it never reaches the DOM, and
`app$get_logs()` did not surface it from the modInput getData path), AND
a realistic-size fixture doesn’t even fire it. So the browser
`expect_false(grepl("incomplete final line", logs_blob))` was a
TAUTOLOGY (green with or without the muffle — the un-muffle round-trip
proved it). The vehicle that CAN observe it is
[`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
(in-process, `warn` reaches an R-level handler): drive
`modInputServer`’s `getData` with a simulated upload —
`session$setInputs(fileType=, fileContent="pedFile", minParentAge="2.0", pedigreeFileOne=data.frame(name=, size=, type=, datapath=fixture))`
then
`withCallingHandlers(session$setInputs(getData=1), warning=\(w){ capture; invokeRestart("muffleWarning") })`
— and assert the captured warnings exclude `"incomplete final line"`
(read the module’s `session$returned$qcSummary()$records`/`$errors` for
the data-integrity half). **Teeth PROVEN by round-trip:** un-muffle BOTH
`read.table`+`read.csv` sites in `modInput.R`, `load_all`, run → both
blocks RED (`warned=TRUE`); `git checkout` → green. **Lesson:** when a
fix suppresses an R-process-internal signal (a console warning) that
never reaches the browser, the browser E2E cannot give it teeth — put
the suppression teeth in a `testServer` (or pure-helper) test where the
signal is observable, and let the browser E2E carry the end-to-end
*user-visible* behavior.

\*\*(2) \[browser E2E owns end-to-end data integrity, read via a
TOP-LEVEL consumer because modInput’s own QC outputs are SUSPENDED in
hidden nested tabs\] The modInput QC outputs (`qcSummaryUI`,
`cleanedDataTable`, `downloadCleaned`) live in non-active nested tabs of
`dataInput-mainTabs`, so Shiny `suspendWhenHidden=TRUE` leaves them
empty / the download link `disabled href=""` — and neither
`set_inputs(\`dataInput-mainTabs\`=…)`nor a JS anchor-click reliably un-suspends them under this app's bslib BS4 + (broken) shinyBS JS.** The robust count signal is a TOP-LEVEL navbar consumer: after upload+ready,`navigate_to_tab(app,
“Pedigree Browser”,
“Pedigree”)`(the proven sibling mechanism) materializes the pedigree, and`\#pedigree-pedigreeTable`renders`of
3,694
entries`on the ACTIVE pane (DataTables formats the count WITH a comma — match`“of
3,694
entries”`, not`3694`).`data-ready=true`is set server-side and does NOT imply the hidden-tab outputs rendered. **Lesson:** to read a count/state from a Shiny module whose own outputs sit in hidden (suspended) nested tabs, don't fight tab-suspension — assert via a top-level navbar tab that CONSUMES the data on its active pane (the same`navigate_to_tab`/`assert_active_pane`idiom the e2e suite already trusts). **Right-size:** correctly SOLO even under **ultracode "on"** — a two-file test backfill gated by interactive TDD is not a breadth fan-out; a Workflow would be theater (project methodology + Learning 80c/84/85/86/87 govern), and a background Workflow cannot pause for the`AskUserQuestion`phase gates this project requires. The honest division of labor (testServer = warning-suppression teeth; browser = end-to-end) was surfaced to the owner via a mid-GREEN reframe`AskUserQuestion`rather than silently shipping a weaker-than-described test. **Reflexes:** [DE-RISK THE FIXTURE FIRST — prove in plain code (no Shiny) that the fixture reproduces the exact bug condition before building teeth on it][a teeth round-trip that won't go RED ⇒ toothless assertion OR fixture doesn't trigger the bug — check the fixture first, it's the cheaper culprit][read.table/read.csv emit "incomplete final line" only for SMALL files — the readTableHeader scan must reach the unterminated final line; a large file never warns][a console-only warning is NOT browser/get_logs-observable in the assembled app → its suppression can't be teeth-tested in a browser][put suppression teeth in shiny::testServer (in-process, warn reaches withCallingHandlers) with a TINY fixture; simulate the fileInput value as a 1-row data.frame(name,size,type,datapath)][read module return via session$returned$<reactive>()][prove teeth by un-muffling BOTH sites → both blocks RED → git checkout → green (load_all, no install needed)][browser E2E owns end-to-end: modInput QC outputs are SUSPENDED in hidden nested tabs (suspendWhenHidden) and don't reliably un-suspend via set_inputs/JS-click under bslib+shinyBS — read a TOP-LEVEL consumer (Pedigree Browser #pedigree-pedigreeTable) instead][DataTables formats the entry count WITH a comma — match "of 3,694 entries"][data-ready=true is server-side, does NOT imply hidden-tab outputs rendered][surface a mid-GREEN scope/teeth reframe to the owner via AskUserQuestion — don't silently ship a weaker test][close the issue only on owner confirmation][test-only → CHANGELOG only][declare-phase-every-response][gate-every-transition][right-size-SOLO-even-under-ultracode][macos-dupe-scan]. **Apply:** to write a BEHAVIORAL test for an already-shipped fix that suppresses a console-internal signal — first prove in plain code that your chosen fixture actually reproduces the failure (de-risk the fixture, not only the observation mechanism); recognize that a console-only warning is not browser-observable, so put the suppression teeth in an in-process`testServer`/pure-helper test (tiny fixture,`withCallingHandlers\`)
and let the browser E2E carry the end-to-end user-visible behavior read
from a top-level data consumer (not the module’s own suspended
nested-tab outputs); and ALWAYS run the un-muffle teeth round-trip — a
round-trip that won’t go RED is the alarm that catches both toothless
assertions and non-triggering fixtures.

#### Learning 89 — Strict TDD on a DOCS-ONLY fix to a `@noRd` internal: the only thing RED at HEAD is the documentation TEXT, so the RED driver is a doc-completeness test that reads `R/<fn>.R` (the S87 `tools::Rd2ex(man/<fn>.Rd)` pattern is UNAVAILABLE — `@noRd` generates no `man/*.Rd`) via `test_path("..","..","R","<fn>.R")` + `skip_if(!file.exists)` for the installed context, and SCOPES its assertions to the extracted `@return` block (not the whole file) so a pre-existing mention in the title/`\code{}` can’t false-pass; pair it with a behavioral return-contract guard (green at HEAD, honestly classified) so the docs are verified against real behavior (S92, complete `fillBins()` `@return` docs — \#33)

**The doc-text is the deliverable AND the only RED surface — so test the
doc text, scoped.** Issue \#33 was a single unfinished roxygen line:
`#' @return A list with two TODO: RMS provide description`. Under strict
TDD the question is “what fails before the fix and passes after?” — and
for a docs-only change the answer is NOT a behavioral test (the function
already returns the right thing; any return-contract assertion is GREEN
at HEAD) but a **doc-completeness** test. **(1) The S87 `Rd2ex` pattern
does not apply to `@noRd`.** `test_examples_invoke_documented_fn.R`
reads `man/<fn>.Rd` via
[`tools::Rd2ex`](https://rdrr.io/r/tools/Rd2HTML.html) — but a `@noRd`
internal generates NO `man/*.Rd` (confirmed: `document()` is a no-op for
it, scope-check `git status`). So the only artifact carrying the doc is
the SOURCE file `R/fillBins.R`; read it directly via
`testthat::test_path("..","..","R","fillBins.R")` (the same `..`/`..`
root-relative idiom S87 uses for `man/`) with
`skip_if(!file.exists(src), "R/ source not available (installed package)")`
so it’s RED in dev (where the fix lives) and inert under `R CMD check`
(where `R/*.R` source isn’t shipped). **(2) SCOPE the assertion to the
`@return` block, or it false-passes.** `fillBins.R`’s TITLE line already
says `list of two lists \code{males} and \code{females}`, so a naive
`grepl("males", whole_file)` would be GREEN even with the TODO still
present. The discriminating test extracts ONLY the `@return` block —
find the `@return` line, take following lines until the next `#' @` tag
— and asserts within it: no `"TODO"`, and `\bmales\b`/`\bfemales\b`
(word-boundaries so the `males` inside `females` doesn’t satisfy the
`males` assertion). All 3 assertions then go RED at HEAD for the right
reason, and the RED failure output literally prints the isolated
`@return` line — proof the extractor scoped correctly. **(3) Pair with a
behavioral contract guard, honestly classified.** A `test_that`
asserting `expect_named(res, c("males","females"))` + both
`expect_type "integer"` + `expect_length == length(lowerAges)` is GREEN
at HEAD — it is NOT the RED driver, it is a contract-LOCK that ties the
now-complete docs to real behavior and catches future drift (same
honest-degenerate-cycle classification as S87’s backfill tests and S89’s
`nrow` guards: declare it green-at-HEAD, don’t pretend it drove the
change). **(4) Verification appropriate to docs-only.** `document()` →
no NAMESPACE/`man/`/DESCRIPTION churn (the `@noRd` proof); `lintr` 0;
full clean-regression 0/0; and **Phase-3E is genuinely N/A** — a roxygen
comment on a `@noRd` internal changes NO runtime behavior, no man page
even renders — STATE that (FM \#24 doesn’t apply: there’s no
build-vs-runtime gap to mistake, the test suite IS the verification).
**Style:** match the package’s existing `\describe{\item{name}{...}}`
`@return` convention (4 files use it, e.g. `getPossibleCols.R`). **Issue
left OPEN** pending owner confirmation (standing rule). **Right-size:**
correctly SOLO even under **ultracode “on”** — a one-line doc fix gated
by interactive TDD is not a breadth fan-out; a Workflow would be theater
and cannot pause for the `AskUserQuestion` gates (Learning
80c/84/85/86/87/88 govern). **Reflexes:** \[docs-only fix under strict
TDD ⇒ the RED driver is a doc-COMPLETENESS test, not a behavioral one
(behavior is already correct → green at HEAD)\]\[`@noRd` internal ⇒ NO
`man/*.Rd` ⇒ the S87
[`tools::Rd2ex`](https://rdrr.io/r/tools/Rd2HTML.html) pattern is
unavailable; read the SOURCE `R/<fn>.R` via
`test_path("..","..","R","<fn>.R")` + `skip_if(!file.exists)`\]\[SCOPE
doc assertions to the extracted `@return` block — a pre-existing
title/`\code{}` mention false-passes a whole-file grep\]\[extract the
block: from the `@return` line to the next `#' @` tag\]\[use `\bword\b`
word-boundaries so `males` inside `females` doesn’t satisfy the `males`
assertion\]\[pair with a behavioral contract guard (named/type/length)
but classify it honestly as green-at-HEAD contract-lock, not the RED
driver\]\[`document()` is a no-op for `@noRd` — scope-check `git status`
for zero NAMESPACE/`man/`/DESCRIPTION churn\]\[Phase-3E N/A for a
`@noRd` doc edit — STATE it, FM \#24 doesn’t apply (no build-vs-runtime
gap)\]\[match the existing `\describe{\item{}}` `@return`
convention\]\[news-vs-changelog: `@noRd` internal docs never render to a
user-facing page → CHANGELOG only, no NEWS\]\[leave the issue OPEN
pending owner
confirmation\]\[declare-phase-every-response\]\[gate-every-transition-via-AskUserQuestion\]\[right-size-SOLO-even-under-ultracode\]\[macos-dupe-scan\].
**Apply:** to complete/repair the documentation of a `@noRd`
(non-exported) function under strict TDD — drive it with a
doc-completeness test that reads the SOURCE file (not a `man/*.Rd`,
which doesn’t exist) scoped to the relevant roxygen block with
word-boundary assertions and a `skip_if`-installed guard, pair it with
an honestly-classified behavioral contract guard, verify via
`document()` no-op + lint + full regression, and state Phase-3E N/A
because a `@noRd` comment changes no runtime behavior.

#### Learning 90 — Before asserting an open issue “needs implementation,” GREP FOR THE IMPLEMENTATION: a negative claim (“the work hasn’t been done”) demands a positive search, NOT an inference from issue metadata — \#49 read as fresh (created today, 0 comments, absent from the last-8 `git log`) but was already built, wired in UI+server, and fully tested in **S84** (`grep -rn ORIP R/ tests/` + `git log --diff-filter=A -- R/shouldShowOripTab.R` found it in seconds, surfacing `b980f998`); implemented-but-unclosed is a RECURRING shape in this repo (#4→impl S89/close S90, \#33→impl S92/close S93, \#49→impl S84/close S94), so “close \#N” usually means RECOMPUTE-VERIFY-THEN-administratively-close, not a TDD build — and the handoff chain must carry “implemented in SXX, OPEN pending close” forward or the done-but-open status goes invisible for many sessions (S94, close \#49 — the ONPRC-only ORIP tab gate already shipped S84)

#### Learning 91 — Before running OR proposing a recurring-shaped task (audit / sweep / inventory), CHECK THE PROJECT’S OWN PROCESS-HISTORY ARTIFACTS AT SCOPING TIME — `CHANGELOG.md`, `docs/audits/`, and the recent `SESSION_NOTES.md` handoffs are cheap and authoritative and tell you whether it was just done: a recurring audit is a DIFF against the last baseline, not a full re-run. S95 ran a full 14-agent / ~483k-token sweep classifying all 14 open issues for “implemented-but-open” when **S62 (`docs/audits/BACKLOG_STALENESS_AUDIT_2026-06-12.md`, 4 days prior) had already classified all 21 then-open issues with the identical question**, AND the `CHANGELOG.md [Unreleased]` entries (S89/S90/S92) + the S94 handoff already documented the implemented-but-open backlog being drained issue-by-issue (#4/#33/#49). The overlap surfaced only MID-EXECUTION (agents cited S62) and at report-writing (looking up the audits-dir naming convention) — never at scoping. The owner flagged it twice (“why was this in the backlog if already done?”, “you should have been able to check changelog also”). (S95, Learning 90 follow-through audit — 0 new closeable candidates found; the backlog was already drained)

**The audit designed to catch done-but-still-listed WORK was itself a
done-but-re-listed TASK — the same tracker-lags-reality failure, one
meta-level up.** The decisive miss: the AUDIT_WORKSTREAM’s own **Step 4
“Review Prior Audits”** fired too late — at report-writing, where it
produced a nice S62 comparison table — instead of at SCOPING/Phase 1,
where it would have collapsed the whole sweep into a 7-issue delta (the
closures since S62) plus the new \#49 data point, or an owner “do you
want the full re-run or just the diff?” before any fan-out. Under
ultracode, token cost is explicitly not the constraint — but
proposing/running REDUNDANT work is a judgment defect independent of
budget (FM \#5 helpfulness-as-volume / FM \#21 greenfield-assumption
applied to *process artifacts*: I acted as if the backlog had never been
audited). **(1) The cheap pre-checks were all available at
orientation.** `docs/audits/` is one `ls`; the CHANGELOG `[Unreleased]`
section is at the top of the file; the recent handoffs were already read
in Phase 0. Any one of the three would have shown the work was recent or
in-progress. **(2) Recurring tasks need a baseline check, not a fresh
start.** When a task is audit/sweep/inventory-SHAPED (whole-backlog,
whole-codebase, whole-corpus), the first scoping move is “has this been
done recently, and what’s the smallest delta that updates it?” — grep
the process-history artifacts for a prior run before deciding scope.
**(3) The handoff-chain corollary (mirrors Learning 90).** Just as a
session that implements-but-leaves-OPEN must carry “impl SXX, OPEN
pending close” forward, a handoff that PROPOSES an audit/sweep candidate
must cite the most recent prior run of that shape (or state “none
exists”) so the next session scopes it as a delta rather than
re-proposing it as novel. S94’s candidate (2) framed this audit as
“cheap, high-value” without referencing S62 — the proximate cause of the
redundancy. **(4) Honest recovery beats a defended sunk cost.** When the
owner questioned the overlap, the right move was to own it plainly (yes,
S62 did this; yes, I should have checked CHANGELOG and `docs/audits/` at
Phase 1), give an honest marginal-value accounting (not zero — 7
closures + the \#49 data point + a firsthand “no second \#49”
confirmation since S62 — but a delta paid for as a full sweep), and let
the owner decide keep-vs-trim, rather than rationalizing the spend.
**Reflexes:** \[task is audit/sweep/inventory-SHAPED ⇒ at SCOPING (Phase
1), `ls docs/audits/` + scan `CHANGELOG.md [Unreleased]` + recent
handoffs for a prior run BEFORE fanning out\]\[a recent prior run exists
⇒ scope to the DELTA since that baseline; offer the owner the diff-only
option before spending a full sweep\]\[AUDIT_WORKSTREAM Step 4 “Review
Prior Audits” belongs at scoping, not report-writing\]\[a handoff that
proposes a recurring-task candidate must cite the most recent prior run
of that shape, or “none”\]\[redundant work is a judgment defect even
when token budget is unconstrained — FM \#5/#21\]\[own an overlap to the
owner with an honest marginal-value accounting; don’t defend the sunk
cost\]. **Apply:** whenever you’re about to run — or propose in a
handoff — anything that classifies/reviews a whole set (all open issues,
all files in a module, all citations), first check the project’s
process-history (`docs/audits/`, `CHANGELOG.md`, recent
`SESSION_NOTES.md`) for when it was last done; if recent, do the delta
and say so, and only do the full sweep if the baseline is stale or the
owner asks for it.

**A “this issue is open so it must need work” assumption is a negative
claim — verify it the way you’d verify any claim: search for the
disproof first.** This session’s near-miss: asked “why is \#49 open,” I
(previous turn) answered “real implementation remains /
implementation-ready TDD candidate” after checking only the *issue*
surface — sibling-issue states (#47 closed) and the S86 commit *message*
— and concluded “no commit implements it” because it wasn’t in the last
8 commits and had 0 comments. **That was an unsearched negative.** When
the owner then said “work on closing \#49,” the recompute-don’t-inherit
reflex (applied *before* declaring any RED) is what caught it: a
2-second `grep -rn "ORIP\|orip" R/ tests/` revealed
`R/shouldShowOripTab.R`, the conditional `appUI.R:177-183` mount, the
`appServer.R:281-292` gate, and three test files;
`git log --diff-filter=A -- R/shouldShowOripTab.R` dated the whole
feature to **S84 `b980f998`** (“gate ORIP Reporting tab to ONPRC-only
(#49)”). The feature was DONE — including the issue’s flagged “open
product fork” (no-config case), resolved as
`shouldShowOripTab(center, hasConfigFile) <- isTRUE(hasConfigFile) && isTRUE(center == "ONPRC")`
(the
[`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
default ONPRC fallback does NOT show the tab). **(1)
Implemented-but-unclosed is this repo’s default, not the exception.**
\#4, \#33, and \#49 all followed impl-in-session-X → left-OPEN →
administratively-closed-in-session-Y on owner confirmation. So when the
deliverable is “close \#N,” the FIRST move is recompute:
`grep`/`git log` for the implementation, read the code firsthand, run
its tests — only then decide whether “close” means an admin close (the
common case) or a real build. Treating “close \#N” as “build \#N” risks
duplicating shipped work (a scope + volume violation, FM \#5/#8). **(2)
Verify firsthand before a PUBLIC assertion of completeness.** The close
comment asserts to the world that the gate is correct, so I re-read the
predicate + UI gate + server gate AND re-ran `test_shouldShowOripTab.R`
(5/5), `test_modORIPReporting.R` (9/9, behavioral — renders real
`appUI(siteInfo=)` HTML for ONPRC/SNPRC/no-config),
`test_modSiteConfig.R` (30/30) green at HEAD — did not trust S84’s green
claim blindly. **(3) A changed premise is the owner’s to ratify — don’t
improvise the pivot.** Because the owner directed the close under a
premise I had mis-stated (that it needed implementing), I surfaced the
corrected finding and confirmed the close path via `AskUserQuestion`
rather than silently switching from “build” to “close.” Owning the prior
error explicitly is part of the recovery, not optional. **(4) The
handoff chain dropped \#49.** Unlike \#4/#33 (whose “left OPEN pending
confirmation” was carried in every subsequent handoff), \#49 was
implemented in S84 without recording “done-but-open,” and ~10 handoffs
never surfaced it — which is *why* my metadata-only read looked
plausible. Fix: when a session implements an issue but leaves it OPEN,
the handoff’s gotchas/suggested-next MUST list it as “implemented SXX,
OPEN pending close,” and that line must propagate until the issue
closes. **Reflexes:** \[deliverable is “close \#N” ⇒ recompute FIRST:
`grep`/`git log --diff-filter=A -- <likely files>` for the
implementation before assuming it needs building\]\[a negative claim
(“not done”, “no caller”, “doesn’t exist”) requires a positive search,
not an inference from metadata (0 comments / recent creation / absent
from recent `git log`)\]\[implemented-but-unclosed is the repo default
(#4/#33/#49) — “close” usually = admin close on owner
confirmation\]\[verify firsthand (re-read code + re-run tests green)
before asserting completeness in a PUBLIC close comment —
recompute-don’t-inherit applied to a prior session’s green claim\]\[own
a mis-statement to the owner explicitly; confirm a changed-premise pivot
via `AskUserQuestion`, don’t improvise it\]\[a session that
implements-but-leaves-OPEN must carry “impl SXX, OPEN pending close” in
its handoff until close\]\[closing an issue adds no new software work ⇒
no new CHANGELOG/NEWS (logged at impl time) —
\[\[backlog-vs-changelog-placement\]\]\]\[Phase-3E N/A for a pure
issue-close — STATE it, verify the issue transitioned to
CLOSED\]\[right-size-SOLO for an operational close even under
ultracode\]\[macos-dupe-scan\]. **Apply:** whenever the task is “close
issue \#N” or you’re about to claim an open issue still needs work —
grep + `git log` for the implementation FIRST; if it already shipped
(the repo’s common case), recompute-verify it firsthand (read the code,
run its tests green), confirm the close with the owner if the premise
changed, then `gh issue close` with an evidence comment citing the impl
commit + verification, and carry any other implemented-but-open issues
forward in the handoff.

#### Learning 92 — Re-verifying \#37’s “exported-but-app-unused” inventory: (a) compute reachability WITHOUT loading the package — source `R/*.R` into a throwaway env + `codetools::findGlobals` (base lib), because the renv project library isn’t materialized in this checkout (`pkgload::load_all` bootstraps an empty renv and dies); and (b) use `findGlobals(f, merge = TRUE)`, NOT `$functions`-only — a function passed AS A VALUE to a higher-order call (`Map(chooseDate, …)` at `setExit.R:54`) lands in `$variables`, so a call-position-only graph FALSE-FLAGS it unused. The genuine S97 delta vs S78: both wire-ins discharged (#47 ORIP + \#48 `getPotentialParents`/`modPotentialParents`, both CLOSED + mounted), the surfaced docfix fixed (S87 `2a64770f`), the logging island still 0 live callers → 39 unused = **0 wire-in · 39 keep-as-public-API · 0 retire**; \#37’s actionable surface is fully drained (S97, audit of \#37)

**The recompute caught a method bug — which is the whole point of
recompute-don’t-inherit.** First pass used
`findGlobals(merge = FALSE)$functions` and flagged `chooseDate` unused,
contradicting S78’s “`chooseDate` is no longer unused.” Firsthand check
found `Map(chooseDate, ped$death, ped$departure)` in `setExit.R:54` —
`chooseDate` is an *argument*, not a call, so it’s in `$variables`.
`merge = TRUE` (any global reference, any position — the correct
conservative “the app uses this” test) reconciled it and moved exactly
one function into the reached set. **(1) Environment gotcha:** this
checkout has `renv.lock` + `renv/activate.R` but **no `renv/library`**,
so the `.Rprofile`’s `source("renv/activate.R")` re-bootstraps renv into
an empty lib and any `pkgload`/`devtools` call fails — but `findGlobals`
is pure static parse-tree analysis needing only base `codetools`, so
`Rscript --vanilla` + `sys.source` over `R/*.R` reproduces the issue’s
documented method with zero deps and zero install. **(2) Scoping
discipline (Learning 91 applied correctly this time):** before any
fan-out I read the issue body + its two triage comments (S65, S78), both
prior audit reports (`BACKLOG_STALENESS`, `IMPLEMENTED_BUT_OPEN`), and
the CHANGELOG — establishing that S78 had already verified the
per-function disposition (2 wire-in · 37 keep · 0 retire) with an
adversarial completeness critic two days prior. So the deliverable was a
**delta re-verification** (recompute the set, diff against S78, confirm
wire-in/docfix status), NOT a re-run of S78’s triage. **(3) Right-size
SOLO even under ultracode:** the 37 keep-as-public-API dispositions were
already verified by S78; re-investigating each would be the exact
Learning-91 redundancy. A Workflow fan-out would be theater — the
genuinely-new work is one deterministic recompute + a handful of
targeted firsthand grep/`gh` checks, and the adversarial check that
mattered (is my recompute correct?) I did inline by catching the `merge`
bug. **(4) The disposition finding:** \#37’s only ever-actionable items
(#47, \#48, the `getPedDirectRelatives` docfix) are all shipped/fixed
and CLOSED; the remaining 39 are intended public API by repeated owner
decision (0 retire, `safeExecute` the lone conditional
future-candidate). So \#37 is now a pure standing inventory — close (no
work left) or keep + update the now-stale body (it predates the
wire-ins; lists 3 S3 methods, not 4) is an owner judgment call, not an
auto-close. **Reflexes:** \[#37 reachability recompute ⇒ source
`R/*.R` +
[`codetools::findGlobals`](https://rdrr.io/pkg/codetools/man/findGlobals.html)
under `Rscript --vanilla`; do NOT rely on
[`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)
(renv lib unmaterialized in this checkout)\]\[use
`findGlobals(f, merge = TRUE)` — call-position-only `$functions`
false-flags functions passed to `Map`/`apply`/`do.call` as unused
(e.g. `chooseDate` via `Map` in `setExit.R`)\]\[recurring inventory ⇒
delta against the last triage (S78), not a fresh per-function re-run —
read the issue comments + `docs/audits/` + CHANGELOG at scoping
(Learning 91)\]\[a prior session verified the dispositions with an
adversarial critic ⇒ re-verifying them is redundant; do the DELTA and
right-size SOLO even under ultracode\]\[confirm a “wire-in shipped”
claim by grepping the mount site (`appUI.R`/`appServer.R`) AND the
tracking issue’s CLOSED state — not the issue list alone\]\[S3 methods
can’t be proven unused statically — flag as “cannot-prove-used,” not
“dead”\]\[read-only audit ⇒ Phase-3E N/A, no `R/`/test/issue-state
change, CHANGELOG-only\]\[macos-dupe-scan\]. **Apply:** when
re-verifying \#37 (or any “exported-but-app-unused” reachability
inventory) — recompute statically with
`codetools::findGlobals(merge = TRUE)` over sourced `R/*.R` (no package
load needed, and `merge = TRUE` avoids the higher-order-argument
false-unused), but first read the most recent prior triage and audit
reports so you scope a delta rather than re-running verified
per-function dispositions; the disposition of the *issue* (close vs
keep-and-update) is the owner’s judgment call once its actionable
wire-in/docfix surface is confirmed drained.

#### Learning 93 — Updating a STALE inventory/catalog (e.g. an issue body) ⇒ reconcile against the FULL recomputed truth, NOT the handoff’s delta-list: a handoff’s “delta” is anchored to the handoff’s OWN baseline, but the artifact you’re editing may sit at an OLDER baseline, so the handoff’s recommendation list is necessary-but-not-sufficient. S97’s handoff listed the delta-since-S78 for \#37’s body (strike `modORIPReporting*`/`getPotentialParents`, mark `removeAutoGenIds` transitive, add the 4th S3 `summary.nprcgenekeeprGV`, note the `getPedDirectRelatives` docfix) — but \#37’s BODY was last re-verified at **S65 (2026-06-12), older than S78**, so two MORE entries were stale that a delta-since-S78 cannot name: `chooseDate` (left the unused set AT S78 → already-gone from S78’s frame, so absent from “what changed since S78”) and `setAutoIdFormat` (a newer \#44/#38 export never catalogued at all). Recomputing the authoritative 39-set firsthand and reconciling the WHOLE body against it (a programmatic exact-match check) caught both, plus a pre-existing arithmetic error (the body’s own breakdown summed to 42, not 39) and a grep false-negative (NAMESPACE declares S3 methods as `S3method(print,summary.x)` — comma form — not `print.summary.x`). (S98, keep \#37 open + update its stale body)

**A handoff delta is relative to the handoff’s baseline; the artifact
may be at a different one — so recompute the full current truth and
reconcile the whole artifact, don’t hand-apply the delta list.** The
deliverable was the owner’s choice of “keep \#37 open + update the stale
body” over “close \#37.” The trap: treat S97’s tidy recommendation list
as the complete change-set. It wasn’t — not because S97 erred, but
because a “delta since S78” is silent about anything that changed
*before* S78, and the body lagged to S65. **(1) The
recompute-don’t-inherit reflex applies to PUBLICATION, not just to
“close \#N” / RED-gating.** Editing a public issue body asserts the
inventory to the world, so the right basis is a fresh authoritative
computation, not an inherited list. I re-ran the issue’s own documented
method (`codetools::findGlobals(merge = TRUE)` over all 202 sourced
`R/*.R` under `Rscript --vanilla`, per Learning 92) and got 166 / 127 /
**39 unused** (35 fn + 4 S3) — independently reproducing S97 — THEN
reconciled every non-struck body entry against that set with a tiny R
check asserting `identical(body_nonstruck, authoritative)`. That
exact-match gate (not eyeballing) is what surfaced `chooseDate` (body
said unused; recompute said REACHED via the higher-order
`Map(chooseDate,…)` at `setExit.R:54`) and `setAutoIdFormat` (in the
truth-set, absent from BOTH body tables). **(2) Verify each load-bearing
claim firsthand before it goes public — even on a “trivial” edit.** A
grep for the S3 exports returned EMPTY at first (my regex assumed
`print.summary.x`; NAMESPACE uses `S3method(print,summary.x)`), which
would have falsely “confirmed” the 4th S3 didn’t exist — re-grepping the
real form confirmed all four. Confirmed the 5 strikes (mount sites in
`appUI.R`/`appServer.R`, the transitive `removeAutoGenIds` at
`getPotentialParents.R:42`, the `Map` site) and the 2 additions
(`setAutoIdFormat` has no direct callers; app reads format via
`getAutoIdFormat` in `addUIds.R`) before writing them. **(3) “Update the
stale body” includes fixing the body’s OWN internal inconsistencies, not
only the named items.** The body claimed 39 unused but its
origin-breakdown summed to 42; I rebuilt the Summary so 22 (of original
70) + 17 (added since) = 39 holds and matches the 35-fn/4-S3 split. An
updated doc with wrong arithmetic is still stale. **(4) Leave a dated
thread marker for a silent body edit.** GitHub issue-body edits don’t
appear in the timeline, so a long-lived catalog issue needs a short
dated comment (“body re-verified & updated 2026-06-16 (S98): struck 5,
added 2, see audit doc”) or the change is invisible to anyone reading
the thread. **(5) news-vs-changelog + right-size:** an issue-body edit
is dev-process bookkeeping (the underlying audit was already logged by
S97) → **no CHANGELOG/NEWS** entry
(\[\[backlog-vs-changelog-placement\]\]); and it’s correctly **SOLO even
under ultracode** — one recompute + targeted firsthand checks + a body
rewrite is not a breadth fan-out (the audit fan-out already happened
S95/S97; a Workflow would be theater). **Phase-3E N/A** — editing an
issue body changes no runtime behavior (no `R/`/test change); FM \#24
inapplicable (no build step). **Reflexes:** \[updating a stale
catalog/inventory ⇒ recompute the FULL authoritative set and reconcile
the WHOLE artifact against it (programmatic exact-match), don’t
hand-apply a handoff’s delta list\]\[a handoff “delta” is anchored to
the HANDOFF’s baseline — if the artifact lags to an OLDER baseline, the
delta is necessary-but-not-sufficient; compute the diff from the
ARTIFACT’s baseline to now\]\[recompute-don’t-inherit applies to
PUBLICATION (editing a public body), not just to “close \#N” or
RED-gating — a fresh authoritative compute, not an inherited list, is
the basis\]\[verify each load-bearing claim firsthand before it goes
public — a failed grep may be a regex artifact (NAMESPACE S3 form is
`S3method(print,summary.x)`, comma not dot), not a true negative\]\[gate
the edit with `identical(body_entries, authoritative_set)` — eyeballing
a 70-row table misses entries that changed before the handoff’s baseline
(`chooseDate`) or were never catalogued (`setAutoIdFormat`)\]\[fix the
artifact’s OWN internal inconsistencies too (the body’s breakdown summed
to 42≠39) — “update the stale body” ⊇ “make it self-consistent”\]\[leave
a dated comment for a silent issue-body edit — GitHub body edits don’t
show in the timeline\]\[keep the issue OPEN per owner choice; the audit
doc is the durable per-export evidence\]\[issue-body edit ⇒ dev-process
bookkeeping, CHANGELOG/NEWS not warranted\]\[Phase-3E N/A — no runtime
surface\]\[right-size-SOLO-even-under-ultracode\]\[macos-dupe-scan\].
**Apply:** when the task is to refresh a stale catalog/inventory
artifact (an issue body, a ROADMAP table, a generated index) — recompute
the authoritative current set with the artifact’s own documented method,
reconcile the FULL artifact against it programmatically (not by applying
the most-recent handoff’s delta, which is blind to anything that changed
before its baseline), fix any internal arithmetic/consistency errors you
find, verify each published claim firsthand, and leave a dated marker if
the edit is otherwise invisible.

#### Learning 94 — Re-merging the long-lived `add-methodology` branch into `master` (the standing branch model): the safety check is NOT the ahead/behind count — prior PRs merged via MERGE COMMITS, so those merge-commit nodes show up as “master-only” commits and make `master` look “N ahead” when it has ZERO unique content. Verify a re-merge with a THREE-part recipe instead: (1) `git merge-tree --write-tree origin/master origin/add-methodology` → exit 0 = no conflicts; (2) `git log origin/add-methodology..origin/master --oneline` → confirm the only master-only commits are `Merge pull request #NN` nodes (add-methodology’s own work merged back), NOT independent work; (3) confirm master is strictly behind — `comm -23 <(git ls-tree -r --name-only origin/master|sort) <(... add-methodology|sort)` is empty (no master-only files) AND the tip-to-tip diff is an exact mirror (master-vs-add-methodology = the inverse of add-methodology-vs-master). All three held for PR \#51 (S52–S99, 54 commits, +6001/−406, clean): merge-tree exit 0, the 2 master-only commits were `Merge pull request #43/#41`, no master-only files, mirror diff. (S100, PR \#51 add-methodology → master)

**The “2 ahead / 54 behind” divergence looked alarming and was
completely benign — because `master`‘s 2 unique commits were the GitHub
merge nodes from PRs \#41/#43, i.e. add-methodology’s own prior work
merged back, not new work done on master.\*\* A long-lived feature
branch that is periodically PR-merged (not deleted-and-recreated)
accumulates this pattern: every prior merge-commit lives on master’s
first-parent line but not on the branch line, so
`git rev-list --left-right --count master...add-methodology` reports
master as “ahead” by the count of prior merges. Reading that number as
“master has work I’d regress” is the trap. **(1) The decisive safety
signal is `merge-tree` + content subsumption, not the commit count.**
merge-tree’s clean exit proves a 3-way merge applies with no conflicts;
a clean 3-way merge preserves all of master’s content unless
add-methodology explicitly reverted the same lines (which would surface
AS a conflict). Pair it with the mirror-diff / no-master-only-files
check to prove master is strictly behind (zero unique content), and the
merge is provably safe and purely additive. **(2) This is the repo’s
standing model, so it recurs — Learning 91’s “cite the prior run”
corollary applies to the branch topology too.** The branch model is
“work on `add-methodology`; `master` gets it via a PR” (S51 = PR \#41,
S52-ish = PR \#43, S100 = PR \#51). Each future
`add-methodology → master` PR will show the same growing “master ahead
by K merge-commits” divergence; the next session should expect it and
run the three-part recipe rather than re-discovering that the divergence
is benign. **(3) Right-size SOLO even under ultracode (same call as the
S96/S99 pushes).** A PR is one `gh pr create` after pre-flight
investigation; the investigation is a handful of deterministic git/`gh`
reads, and the adversarial check that matters (will this merge cleanly /
lose anything?) is answered by merge-tree + the mirror-diff, done
inline. A Workflow fan-out would be theater. **(4) Outward-facing ⇒
confirm the exact public title/body once before `gh pr create`.** A PR
body is published to the world; per SAFEGUARDS’ outward-facing caution,
draft the title/body, ground the user-facing summary in the canonical
`NEWS.md`/`CHANGELOG.md` (not from memory of the commits), and confirm
via `AskUserQuestion` before creating — then leave it OPEN (merging
master is a separate owner decision).** (5) news-vs-changelog:\*\*
opening a PR publishes already-committed, already-logged work (the 54
commits each carry their own CHANGELOG/NEWS entries) → it is not itself
a new software change → **no new CHANGELOG/NEWS entry**
(\[\[backlog-vs-changelog-placement\]\], the S96/S99 push precedent).
**Phase-3E N/A** — creating a PR changes no runtime behavior on this
machine (no `R/`/test change); FM \#24 inapplicable (no build step).
**Reflexes:** \[re-merging `add-methodology`→`master` ⇒ verify with
merge-tree (exit 0) + master-only-commits-are-merge-nodes +
strictly-behind (no master-only files, mirror diff), NOT the
ahead/behind count\]\[a long-lived PR-merged branch shows prior
merge-commits as “base ahead” — benign; the count is not the safety
signal\]\[clean `git merge-tree --write-tree` = the authoritative
“applies cleanly, loses nothing” proof — pair with content-subsumption
check\]\[branch model is work-on-add-methodology / master-via-PR (S51
\#41, \#43, S100 \#51) — expect the divergence to grow each PR; run the
recipe, don’t re-discover it’s benign\]\[ground the PR body’s
user-facing summary in `NEWS.md`/`CHANGELOG.md`, not commit-message
memory\]\[outward-facing PR ⇒ draft + confirm title/body via
`AskUserQuestion` before `gh pr create`; leave OPEN unless told to
merge\]\[PR creation = publishing already-logged work ⇒ no new
CHANGELOG/NEWS (push precedent S96/S99)\]\[Phase-3E N/A — no runtime
surface\]\[right-size-SOLO-even-under-ultracode\]\[macos-dupe-scan\].
**Apply:** when the task is “PR `add-methodology` to `master`” (or
re-merging any long-lived periodically-PR-merged branch) — don’t be
alarmed by the “master is N ahead” divergence; prove safety with
`git merge-tree --write-tree` (no conflicts) + confirming master’s only
unique commits are prior merge nodes + master is strictly behind (no
unique files, mirror diff), draft the PR body from
`NEWS.md`/`CHANGELOG.md`, confirm the public title/body once via
`AskUserQuestion`, create it, leave it OPEN, and add no CHANGELOG/NEWS
entry.

#### Learning 95 — Before planning a CRAN “update/submission,” VERIFY THE PACKAGE’S ACTUAL CRAN STATUS FIRSTHAND (it may be ARCHIVED, which reshapes the whole submission path), and treat a clean one-time local `R CMD check` as necessary-but-NOT-sufficient — CRAN’s PERIODIC re-checks (not the submission check) archive established packages for timing/policy drift, so the deliverable is “fast/clean under `--as-cran` on an ongoing basis,” not “passed once.” `nprcgenekeepr` reads in CLAUDE.md and the repo as an established CRAN package (8 dated `cran-comments.md`, a `CRAN-SUBMISSION` marker, `revdep/`), and the owner framed the task as a routine “version bump + NEWS rewrite.” A firsthand `WebFetch` of `cran.r-project.org/web/packages/nprcgenekeepr/index.html` proved otherwise: **“Archived on 2025-07-29 as issues were not corrected in time”** — and the Archive dir + R-pkg-devel thread showed it had a 1.0.8 publish (2025-07-26) RE-archived ~3 days later over *tested elapsed times*, plus a prior 2022-11-03 archive/2025-04-24 unarchive cycle. (S101, CRAN 2.0.0 submission plan)

**The status determines the plan’s spine, so it is a Phase-0/scoping
check, not a detail.** Published-update vs first-submission vs
archived-resubmission are three different checklists (the archived path
adds a mandatory root-cause fix + an explicit archival cover-note in
`cran-comments.md` + stricter human review for a multiply-archived
package). **(1) A positive, plan-shaping claim demands a firsthand probe
(Learning 90, applied to external state).** The whole plan pivots on “is
it on CRAN?”; the research agent quoted the page, but I re-fetched it
myself before anchoring six phases on it — the same discipline as
grepping for an implementation before calling an issue “unbuilt,”
extended to a remote authority. **(2) “Build/check passes” ≠
“CRAN-stable” (FM \#24 at CRAN scale).** The repo’s `cran-comments.md`
honestly recorded `0 errors | 0 warnings | 0 note` for the 1.0.8
submission — and the package was archived anyway, because CRAN’s
recurring flavor checks later exceeded elapsed-time limits the one-time
submission check tolerated. So the timing fix is the critical path and
must be *measured* (profile examples/tests/vignettes under `--as-cran`),
not assumed from the mailing-list reason — the index page only says the
generic “issues were not corrected in time.” **(3) Right-size the
research as a Workflow, but OWN the synthesis.** A CRAN-prep plan has
genuinely independent research angles (CRAN Policy / R-exts, the named
skills, the devtools/usethis pipeline, CRAN status, NEWS conventions)
and codebase-audit angles (DESCRIPTION+version-string inventory, NEWS
structure, check readiness, build cruft) — a 9-agent fan-out
(`wy9xitgt6`) is the correct breadth tool under ultracode, and keeping
the 396k-token research/file-dump out of the main context is the point.
But the plan document itself is the deliverable I author and must
internalize (the SESSION_RUNNER planning rules: grep-based evidence
inventory, per-phase completion criteria + verification commands +
session boundaries, here-be-dragons). **(4) When a named external source
is bot-blocked, fall through to its canonical upstream and SAY SO.** The
`agent-almanac submit-to-cran` skill’s lobehub mirror was JS-blocked, so
the agent fetched the real `SKILL.md` from
`raw.githubusercontent.com/pjt222/agent-almanac`; the `mcpmarket` skill
stayed blocked (HTTP 429 Vercel checkpoint) and was reconstructed from
r-pkgs.org + the marinedatascience checklist — both flagged in the
plan’s Sources as verified-vs-reconstructed so the executor knows what’s
authoritative. **(5) Honor the project’s own NEWS convention over a
general one.** The owner asked for “Major changes / Minor changes” —
which is *also* every prior NEWS entry’s structure — so the plan keeps
it (with `(breaking)` lead-tags inside Major) rather than imposing
tidyverse’s “Breaking changes / New features / Minor improvements”
(\[\[consult-project-source-of-truth\]\]). **(6) The plan is the
deliverable — do NOT bump the version or touch NEWS this session** (FM
\#18 planning-to-implementation bleed): those are Phase 3 of the plan, a
separate session. **Phase-3E N/A** — writing a plan changes no runtime
behavior; the verification appropriate to the deliverable is the
firsthand CRAN-status probe + the evidence-based inventory.
**Reflexes:** \[before planning a CRAN update, `WebFetch` the package’s
CRAN index page firsthand — archived vs published vs first-submission
picks a different checklist\]\[archived-resubmission path = mandatory
measured root-cause fix + explicit archival cover-note + expect stricter
review (esp. multiply-archived)\]\[a one-time clean `R CMD check` is
necessary-not-sufficient — CRAN’s PERIODIC re-checks archive for
timing/policy; deliverable is clean under `--as-cran` ongoing, FM \#24
at CRAN scale\]\[measure the archival cause (profile
examples/tests/vignettes), don’t assume it from the mailing-list reason
— the index page reason is generic\]\[CRAN-prep plan ⇒ Workflow the
independent research+audit angles, but AUTHOR the plan yourself (grep
inventory, per-phase criteria/verify/boundary,
here-be-dragons)\]\[bot-blocked named source ⇒ fall through to canonical
upstream (GitHub `SKILL.md`) and mark verified-vs-reconstructed in
Sources\]\[NEWS section names = the project’s own historical convention
(Major/Minor here), not an imported one\]\[a speed-up that changes
simulation/sampling numbers is a correctness regression —
RED-first\]\[version-bump blast radius: don’t touch deprecation `when=`
markers or historical NEWS/inst strings;
[`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)-driven
files auto-track\]\[plan-is-the-deliverable — no version bump / NEWS
rewrite this session, FM \#18\]\[Phase-3E N/A — no runtime
surface\]\[macos-dupe-scan\]. **Apply:** when asked to “prepare for
CRAN” / “submit to CRAN” / “bump version for release” — FIRST `WebFetch`
the CRAN package page to learn the true status (don’t trust the repo’s
`cran-comments`/`CRAN-SUBMISSION` to mean “currently published”); if
archived, make the measured root-cause fix the critical path and write
the archival cover-note; fan out the research+audit as a Workflow but
author the phased plan yourself with grep-based inventory and per-phase
completion criteria; keep the version bump + NEWS rewrite as their own
later phases.

#### Learning 96 — CRAN Phase-1 static hygiene is VERIFIABLE WITHOUT `renv::restore()`, and `tar tzf` on a REAL build is the authoritative “no cruft ships” check (over any hand-rolled `.Rbuildignore` simulation): `R CMD build --no-build-vignettes --no-manual <pkg>` produces a valid source tarball using only base R (no Imports/Suggests needed once vignettes+manual are skipped) — refining Learning 92 (“static-only until renv is materialized” holds for code-reachability, NOT for tarball-content checks). (S102, CRAN Phase 1 static hygiene)

#### Learning 97 — Profiling CRAN example/test/vignette TIMING (CRAN Phase 2) has three traps that make raw `testthat` numbers lie, and the profile — not the assumption — names both the offender and the fix mechanism. **MEASURE FIRST, with the right harness, under the right conditions.** (S103, CRAN Phase 2a — skip_on_cran slow shiny-module tests + native pipe)

**(1) Harness trap — run the suite the way the package does, or
internals vanish.** Running tests via
`library(nprcgenekeepr) + testthat::test_dir()` does NOT expose
non-exported functions, so every test that calls an internal
(e.g. `addErrTxt`, confirmed internal: not in NAMESPACE, lives in
`R/addErrTxt.R`, reachable only via `:::`) errors with
`could not find function` — 52 false “errors” here that LOOK like
missing Suggests but are a harness mistake. The package’s own
`tests/testthat.R` uses `test_check()`; the dev equivalent is
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
(runs in the package namespace). With `load_all` the same suite was **0
failed / 0 errors**. *(The owner caught my misattribution — I had blamed
missing shinytest2/RSelenium/spelling.)* **(2) `skip_if_not(user)` trap
— raw-slowest ≠ CRAN-slowest.** The four raw-slowest test files
(`test_fillGroupMembersWithSexRatio/fillGroupMembers/groupAddAssign/makeExamplePedigreeFile`,
~17s) are guarded `skip_if_not(Sys.info()[["user"]] == "rmsharp")` →
they run ONLY on the owner’s machine, never on CI or CRAN; measuring AS
rmsharp overcounts CRAN cost by that ~17s. The genuinely CRAN-running
slow tests are the **shiny module `testServer` tests**
(`test_modGeneticValue` 4.4s, `test_modBreedingGroups` 4.6s,
`test_modInput` 2.7s, `test_modBreedingGroups_groupAddAssign` 2.2s,
`test_modPedigree_processing` 1.2s) — they use only
`skip_if_not_installed("shiny")` and shiny is an Import, so they run.
**(3) `NOT_CRAN` trap.** `skip_on_cran()` skips when
`Sys.getenv("NOT_CRAN") != "true"`; run `NOT_CRAN=false` to see
CRAN-effective cost, `NOT_CRAN=true` for CI cost. `NOT_CRAN=true` also
makes normally-skipped tests RUN and error on missing Suggests
(`shinyBS` for the modSummaryStats/ORIP/founder UI tests) — env gaps,
not regressions; install the dep (`shinyBS`) for a clean CI-mode read.

**The profile named the fix mechanism.** Per-BLOCK timing showed the
mod\* cost is spread across MANY
[`shiny::testServer()`](https://rdrr.io/pkg/shiny/man/testServer.html)
calls (~0.05–0.3s each), not a few heavy blocks — so surgical per-block
skipping buys nothing; the right move is **file-level top-of-file
[`testthat::skip_on_cran()`](https://testthat.r-lib.org/reference/skip.html)**
(verified empirically: a top-level skip halts the whole file cleanly,
even when a helper is defined AFTER it and tests reference it). These
are shiny module *integration* tests; the analytical functions they
exercise
(`reportGV`/`geneDrop`/`groupAddAssign`/`trimPedigree`/`qcStudbook`)
have their own unit tests that stay on CRAN, so file-level skip is
coverage-preserving in spirit. Result: ~15s of CRAN test time removed;
CI/local still runs everything (NOT_CRAN=true). **Examples were already
fine** (6.6s total, slowest `countLoops` 1.28s — none \> 5s, none flag);
**vignettes ~21s** (`ColonyManagerTutorial` 7.8s / `a2interactive` 7.5s
/ `simulatedKValues` 5.4s) were DEFERRED to Phase 2b because the only
iteration-reduction lever (the n=1000 gene-drop in `simulatedKValues`,
3.68s) would change the displayed kinship numbers (a correctness
regression) — the numeric-preserving fix is precompute, a larger
separate effort. The cited archival reason (“tested elapsed times”) =
the mod\* shiny tests, so Phase 2a (tests) is the high-confidence,
no-numeric-change fix; Phase 2b (vignette precompute) remains.

**build/check deps ≠ run deps, and they differ PER profiling surface
(owner-reinforced).** renv’s `snapshot.type="explicit"` over
`package.dependency.fields=[Imports,Depends,LinkingTo]`
(`renv/settings.json`) means
[`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html)
materializes ZERO Suggests — so profiling needs precise per-surface
installs: examples need only Imports (present); vignettes need their own
[`library()`](https://rdrr.io/r/base/library.html) set
(`kableExtra`/`png`/`magrittr`); tests need `testthat`/`mockery`/`withr`
(+`dplyr` for one) and the module UI tests need `shinyBS`;
`pkgload`/`roxygen2`/`devtools` are build-only tooling that belong in
`Config/Needs/build`, not Suggests. **`RSelenium` is UNDECLARED** (used
in the e2e tests, absent from DESCRIPTION Suggests — a real gap to fix
in a later phase).

**Native pipe.** The package floor is `R (>= 4.1.0)`, so the base `|>`
is always available; converting `%>%`→`|>` removed the only DIRECT
`magrittr` use ([`library(magrittr)`](https://magrittr.tidyverse.org) in
`simulatedKValues.Rmd`) so no Suggests entry was needed (the other `%>%`
came from dplyr/kableExtra re-exports). Every usage here was
`lhs %>% fn(...)` — natively convertible (no `.` placeholder, no
`%T>%`/`%$%`). Editing a roxygen `@examples` `%>%` means the generated
`.Rd` shows `\%>\%` (`%` is the Rd comment char) — convert it to plain
`|>` (no escaping) when hand-syncing. **Re-rendering `NEWS.md` from
`NEWS.Rmd`** (`rmarkdown::render(output_format="github_document")`)
cleanly appended only the new bullet (no whole-file reformat); `>`
renders as `\>` in github_document (benign). **TDD:** all edits were
REFACTOR/mechanical with NO numeric change (skip guards change only WHAT
runs on CRAN; pipe is syntactic) → RED-first did not apply; gated
PRE-RED→REFACTOR with one `AskUserQuestion` spelling out the edits +
verification, plus a separate pre-RED scope `AskUserQuestion` (defer
vignettes; convert all pipes). **Phase-3E:** the changed code IS
executed (vignette/example/test) — verified by rendering
`simulatedKValues.Rmd`, running the `makeRelationClassesTable` example,
and the affected tests passing — so “runtime” was checked, not skipped.
**Reflexes:** \[profile package tests with
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
(namespace), NOT `library()+test_dir()` — the latter hides internals →
false `could not find function`\]\[raw-slowest ≠ CRAN-slowest: check
each slow test for
`skip_if_not(user==…)`/`skip_on_cran`/`skip_if_not_installed` before
blaming it — `skip_if_not(rmsharp)` tests never run off the owner’s
machine\]\[`NOT_CRAN=false` = CRAN cost, `NOT_CRAN=true` = CI cost;
NOT_CRAN=true surfaces missing-Suggests errors (env, not
regressions)\]\[per-block timing decides surgical-vs-file-level skip —
spread-out testServer overhead ⇒ file-level top-of-file `skip_on_cran()`
(it halts the whole file cleanly, even past a later helper def)\]\[skip
shiny module *integration* tests on CRAN; their analytical functions
have own unit tests that stay\]\[vignette speed-up that reduces
simulation iterations changes displayed numbers = correctness regression
⇒ defer to numeric-preserving precompute, RED-first\]\[renv
explicit-snapshot omits ALL Suggests ⇒ install the precise per-surface
set; build-only tooling (pkgload/roxygen2/devtools) ⇒
`Config/Needs/build`\]\[R\>=4.1 floor ⇒ `|>` always available;
`%>%`→`|>` removes magrittr if it was the only direct user; `\%>\%` in
`.Rd` ⇒ plain `|>`\]\[re-render NEWS.md from NEWS.Rmd, never hand-edit
NEWS.md\]\[use plain descriptive language, not jargon like
“dragon-prone” — user-flagged S103, see
\[\[avoid-jargon-use-plain-language\]\]\]\[macos-dupe-scan\]. **Apply:**
for any CRAN timing work — profile each surface (examples via
`R CMD check` `-Ex.timings`; tests via
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)+`test_dir`
under both NOT_CRAN settings; vignettes via per-vignette render +
isolate the heavy compute) BEFORE concluding; let the per-unit/per-block
data name the offender; gate slow shiny-module integration tests with
file-level `skip_on_cran()` (no numeric risk); defer iteration-reducing
vignette fixes to a numeric-preserving precompute pass; install only the
precise per-surface deps, recognizing build/check/run are three
different sets.

**A file-path-only `.Rbuildignore` simulation UNDER-reports exclusions;
only a real build models directory pruning.** A naive per-file
`grepl(pattern, path)` check reported
`inst/extdata/code_under_development/combinerKinshipTriangles.R` as
“kept” — but R CMD build excludes it, because the existing pattern
`^inst/extdata/code_under_development$` is end-anchored to the DIRECTORY
and the build prunes the whole dir (it walks with `include.dirs=TRUE`),
whereas a per-file grep needs the pattern to match each contained file.
So a static sim is a useful pre-check but `tar tzf` on an actual
`R CMD build` is authoritative (708 entries here, 0 cruft, 0 hidden
files). **(1) macOS/R junk was TRACKED in git, not just working-tree
litter.** `git ls-files` showed `.DS_Store`, `man/.DS_Store`,
`.Rapp.history`, `inst/extdata/.Rapp.history` all tracked — and the
plan’s root-anchored `^\.DS_Store$` would have MISSED `man/.DS_Store`.
An END-anchored, front-UNanchored `\.DS_Store$` / `\.Rapp\.history$`
(paren-free, per the `.Rbuildignore` perl-regex hazard) catches every
copy in any subdir. Build-ignoring keeps them out of the tarball WITHOUT
`git rm`, preserving the owner’s standing `.DS_Store` keep-call
(de-tracking via `git rm --cached` is a separate, owner’s-call tidy).
**(2) `\value` for the two exported functions lacking it, with roxygen2
unavailable:** add `@return` to the roxygen source AND hand-sync the
`.Rd` (modern roxygen2 places `\value` between `\arguments` and
`\description`); Phase 4’s `roxygenise()` (post
[`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html))
canonicalizes any cosmetic whitespace diff.
[`appServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/appServer.md)
= “No return value, called for side effects” (a Shiny server, invoked
for side effects — confirmed it ends in module-server calls with no
explicit return);
[`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
returns a `shiny.tag.list`. **(3) Phase 1 has no RED/GREEN** —
metadata + docs + build-ignore config have no behavioral test surface
(verified by `R CMD build` + `read.dcf` +
[`tools::parse_Rd`](https://rdrr.io/r/tools/parse_Rd.html), not
testthat); the named guard tests (`test_appUI_version.R`,
`test_getVersion.R`) are unaffected because no version/logic changed —
verified by READING them (the full suite is deferred to Phase 4’s renv
gate, not skipped). The PRE-RED→REFACTOR transition still went through
ONE `AskUserQuestion` gate spelling out every edit (the contract’s
permission requirement holds even when RED/GREEN don’t apply).
**Phase-3E N/A** — no runtime/app behavior changed (roxygen additions
are comments; DESCRIPTION/LICENSE/`.Rbuildignore` aren’t loaded at
runtime); the build-equivalent (`R CMD build` + tarball inspection) IS
the appropriate verification and was run (NOT FM \#24 — there is no
untested runtime behavior being masked, and the actual deliverable was
verified). **news-vs-changelog:** packaging/metadata hygiene =
dev-process history → CHANGELOG only; the user-facing NEWS rewrite is
Phase 3 (\[\[backlog-vs-changelog-placement\]\]). **Reflexes:** \[CRAN
Phase-1 hygiene ⇒ verify with
`R CMD build --no-build-vignettes --no-manual` (base-R only, no renv) +
`tar tzf`, not a hand-rolled ignore sim\]\[`tar tzf` on a real build is
authoritative over file-path `.Rbuildignore` simulation — the sim can’t
model directory pruning\]\[end-anchored front-unanchored `\.DS_Store$`
catches subdir copies (e.g. `man/.DS_Store`); root-anchored
`^\.DS_Store$` misses them\]\[macOS/R junk may be TRACKED — build-ignore
keeps it out of the tarball without `git rm`; de-tracking is a separate
owner’s-call\]\[`\value` with roxygen2 unavailable ⇒ edit roxygen
source + hand-sync `.Rd` (between and ); Phase 4 roxygenise
canonicalizes\]\[Phase-1 metadata/docs = REFACTOR, no RED/GREEN, but
still gate the change with one AskUserQuestion\]\[Phase-3E N/A — no
runtime surface\]\[news-vs-changelog: packaging hygiene → CHANGELOG,
NEWS rewrite is Phase 3\]\[right-size-SOLO-even-under-ultracode\].
**Apply:** when executing CRAN-prep Phase 1 (build cruft + DESCRIPTION +
`\value`) — don’t wait on
[`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html);
make the edits, then prove cleanliness with
`R CMD build --no-build-vignettes --no-manual` + `tar tzf`
(authoritative over any ignore-simulation), use end-anchored
`\.DS_Store$`/`\.Rapp\.history$` to catch subdir junk, build-ignore
rather than `git rm` tracked junk you weren’t asked to de-track, and
hand-sync the `.Rd` when roxygen2 isn’t installed.

#### Learning 98 — A “should we adopt technology X to future-proof?” decision splits into THREE independent questions — (1) is the incumbent actually dying? (2) what does X concretely buy ON OUR constrained surface? (3) what does X cost there? — and the answer is frequently HYBRID (adopt X where it’s unconstrained and free; stay on the incumbent where the constraint lives), not all-or-nothing. Verify every external-ecosystem claim by adversarial web research, never from model memory. (S104, Quarto-vs-R-Markdown documentation future-proofing analysis — `docs/planning/quarto-documentation-future-proofing-analysis.md`)

**Don’t answer “convert to X?” as one question.** The owner asked
whether to migrate the package’s docs from R Markdown to Quarto “to
future-proof.” The naive framing is binary (convert / don’t). The
correct decomposition is three separable questions, each with a
different evidence base: **(1) Is the incumbent a dead end?** — for R
Markdown, NO: Posit’s on-record line is “not going away, no plans for
deprecation, actively supported for a long time to come”; `rmarkdown`
2.31 (2026-03, with a GPLv3→MIT relicense) and `knitr` 1.51 (2025-12)
are actively maintained CRAN-critical infrastructure (~800
reverse-imports; it’s the engine Quarto itself runs R with). The real
cost of staying is *feature stagnation* (“new features may only exist in
Quarto”), not breakage. **(2) What does X buy on OUR surface?** — for a
single-language R package’s CRAN HTML vignettes, the gain is NARROW
because the CRAN vignette engine is deliberately minimal (`theme:none`,
`minimal:true`): callouts/tabsets/Bootstrap-5/multi-language are
irrelevant or disabled; only native cross-references is realized. The
differentiators that make Quarto compelling (books, websites,
multi-format single-source, multi-language) apply to the
*manual/website*, not to four simple vignettes. **(3) What does X cost
there?** — a Quarto vignette adds a `SystemRequirements` Quarto-CLI
dependency that CRAN’s check machines DON’T guarantee (confirmed missing
on macOS flavors in 2025), with a documented transient “no vignettes”
NOTE — a bad trade for an *already-archived* package. The Quarto
maintainer himself (cderv) “would not advise” the Quarto vignette engine
for CRAN vignettes.

**The hybrid answer is usually the right one, and it’s a real “yes to
X,” not a dodge.** Recommendation: keep CRAN vignettes on
knitr/rmarkdown (zero CRAN risk, officially supported indefinitely)
while adopting Quarto on the unconstrained surface where it pays off and
carries no CRAN dependency — the pkgdown site, new long-form docs, slide
decks, and the `inst/extdata/` dev docs (two already `.qmd`). This is
enabled by fact, not wish: pkgdown supports MIXED `.qmd`/`.Rmd` (since
2.1.0, 2024-07) via `project: render: ['*.qmd']`. The one genuine
strategic fork worth surfacing to the owner (not deciding for them): the
long-form *manual* is both a CRAN vignette AND the doc that most rewards
Quarto — it could be repositioned off the CRAN vignette set onto the
website. Conversion is mechanical and reversible (Quarto renders most
`.Rmd` unmodified), which is itself an argument against rushing: the
switching cost stays low whenever (if ever) chosen.

**Process notes that held.** (1) **The owner reframed mid-session**
(timing → future-proofing); the right move was to KEEP pass 1’s
already-running CRAN-viability/timing research (still load-bearing as
the guardrail for the new framing) and ADD a targeted pass 2 on the
strategic/longevity dimension — not discard and restart. (2)
**Adversarial verification earns the confidence:** across two Workflows
(9 + 8 agents, ~900k subagent tokens kept out of main context), all six
load-bearing claims survived an explicit attempt to refute them at high
confidence — far stronger than asserting “Quarto is heavier” from
memory. (3) **Ground the inventory firsthand too:** I read the vignette
engine headers, the `a3manual` child-include structure,
`simulatedKValues.Rmd` (set.seed before each sim → deterministic), and
confirmed the `vignettes/*.html|.R|.md` are git-ignored stale renders
(no precompute pattern) — not just trusting the audit agent. (4)
**Right-size as Workflow-for-research + SOLO-for-synthesis:** research
breadth (CRAN policy, build-time, ecosystem trajectory, migration
mechanics) is genuine independent fan-out; the recommendation document
is mine to author per the planning rules (like S101’s CRAN plan). (5)
**Timing fix is orthogonal to this decision:** the CRAN plan’s deferred
Phase 2b vignette timing is fixed by precompute on the EXISTING engine
(`.Rmd.orig`→committed `.Rmd`), NOT by Quarto — keep the two efforts
separate. **\[news-vs-changelog\]:** an analysis/planning doc =
dev-process history → **CHANGELOG only**, no NEWS
(\[\[backlog-vs-changelog-placement\]\], S101 plan precedent).
**Phase-3E N/A** — an analysis document changes no runtime behavior; the
verification appropriate to the deliverable is the
adversarially-verified research + firsthand inventory (NOT FM \#24 — no
build step mistaken for correctness). **Used plain language, not
jargon** (\[\[avoid-jargon-use-plain-language\]\] — no “here be
dragons”/“dragon-prone” in the new doc). **Reflexes:** \[decompose
“adopt X to future-proof?” into is-incumbent-dying /
what-X-buys-on-our-constrained-surface / what-X-costs-there — three
different evidence bases\]\[the future-proofing answer is often HYBRID:
adopt X on the unconstrained/author-controlled surface, stay on the
incumbent where the hard constraint (here, CRAN’s guaranteed toolchain)
lives\]\[verify external-ecosystem trajectory claims (deprecation
status, maintenance, CRAN support) by adversarial web research with
refutation, never from model memory\]\[rmarkdown/knitr are maintained
CRAN-critical infrastructure — “not going away, no deprecation”; staying
is safe, the only cost is feature stagnation\]\[Quarto CRAN vignette =
`SystemRequirements` Quarto-CLI NOT guaranteed on CRAN machines +
minimal engine disables most Quarto features ⇒ narrow benefit, real
risk, esp. for an archived package\]\[pkgdown supports MIXED .qmd/.Rmd
(2.1.0) — the hybrid split is officially enabled\]\[owner reframes
mid-task ⇒ keep still-relevant in-flight research as the guardrail, ADD
a pass for the new axis; don’t discard\]\[ground the inventory firsthand
(engine headers, child includes, gitignored renders), not just the audit
agent\]\[Workflow the research breadth, author the recommendation SOLO
(planning rules)\]\[CRAN vignette timing fix = precompute on existing
engine, orthogonal to a Quarto decision\]\[analysis/planning doc →
CHANGELOG only, no NEWS\]\[Phase-3E N/A — no runtime surface\]\[use
plain language, not
jargon\]\[right-size-Workflow-for-research-SOLO-for-synthesis\].
**Apply:** when asked “should we adopt/convert to to future-proof?” —
split it into (1) is the incumbent actually being retired (verify
firsthand, don’t assume), (2) what does the new thing concretely buy on
the specific constrained surface we ship (often little, if the
constraint strips its differentiators), (3) what does it cost there (new
dependency / risk); expect the answer to be a deliberate HYBRID — adopt
it where it’s free and pays off, keep the incumbent where the constraint
lives — and present the options with a clear recommendation as the
owner’s decision, authored as one analysis doc (CHANGELOG only), with
all external claims adversarially web-verified.

#### Learning 99 — RECORDING an adopted decision is not the same as STAMPING it “adopted”: when the owner picks a recommendation that has open sub-options, resolving a sub-option can invalidate a top-level claim the source doc made under a *different* sub-choice — so propagate the chosen sub-option’s consequences and CORRECT the now-stale claims, don’t just flip a Status line. (S105, adopt Hybrid documentation strategy — `docs/planning/quarto-documentation-future-proofing-analysis.md`)

**The trap.** S104’s analysis recommended Hybrid (Option B) and, in §8,
stated “only Option A would intersect the CRAN submission; under B/C the
plan is unaffected” — TRUE *only if* the §6.3 manual sub-decision stayed
at (a) keep-as-knitr-vignette. When the owner adopted B **with §6.3 →
(b)** (reposition the manual onto the website, dropping it from the CRAN
vignette set), that removes a CRAN vignette = changes the package
contents `R CMD check` sees, so the adopted path now DOES intersect the
resubmission. Flipping the Status to “ADOPTED” without fixing §8 would
have left a self-contradicting policy doc — the kind of stale
load-bearing claim FM \#11/#20 warn about, here introduced by the act of
recording rather than by memory drift.

**What “record the decision” actually entails (the checklist that
worked):** (1) flip the doc’s own decision surfaces — Status header,
TL;DR, the §7 options-table verdict, the “default if unaddressed” line —
so it reads as policy, not a pending recommendation; (2) RESOLVE every
open sub-decision the chosen option carried (here §6.3 → (b)) and mark
it inline where the option is described; (3) re-derive and CORRECT any
consequence the source doc asserted conditional on a *different*
sub-choice (§8’s “only A intersects”); (4) record the implementation
slices where future sessions look — for this project, the analysis doc
(a new §7.1 slices table with per-slice CRAN-risk + ordering) + ROADMAP
“Planned”; (5) CHANGELOG entry (a documentation-process decision =
dev-process history → CHANGELOG only, no NEWS —
\[\[backlog-vs-changelog-placement\]\]); (6) NO auto-memory — the
decision now lives in the repo, so a memory would duplicate the source
of truth (\[\[consult-project-source-of-truth\]\]).

**The deliverable boundary held (FM \#18).** “Adopt Hybrid” is a
DECISION-recording session; it converts NOTHING. The first conversion
slice is a separate, owner-approved session. The owner’s own menu
framing (“(A) Decide the recommendation … the first implementable slice
is a separate session”) made this explicit, and recording the slices as
a §7.1 table (with the slice-4 resubmission-coordination gate) sets up
those sessions without starting them. The one CRAN-touching slice (the
manual) is flagged as gated on the CRAN plan, not free-standing. **Two
`AskUserQuestion`s up front** pinned the two genuine owner sub-decisions
(§6.3 manual disposition; file-issues-or-not) *before* writing — they
changed exactly what got recorded. **Right-sized SOLO under ultracode:**
editing 4–5 docs to record a decision the owner just made — facts
already established and already adversarially verified in S104 — has no
breadth to fan out and no fresh claims to verify; a Workflow would be
theater (the S101/S102/S103/S104 call). Verification = a firsthand
cross-document consistency re-read (does §6.3 = §7 = §7.1 = §8 = ROADMAP
= CHANGELOG tell ONE story?). **Reflexes:** \[recording an adopted
decision ≠ stamping “adopted” — resolve open sub-options and CORRECT any
source claim that assumed a different sub-choice\]\[flip ALL the doc’s
decision surfaces: Status, TL;DR, options-table verdict, default
line\]\[record slices where future sessions look: analysis doc +
ROADMAP + CHANGELOG entry, no NEWS\]\[no auto-memory for a decision now
recorded in the repo\]\[decision-recording converts nothing — FM \#18;
slices are separate owner-approved sessions\]\[gate the one
CRAN-touching slice on the CRAN plan, keep the zero-risk slices
independent\]\[ask the genuine owner sub-decisions up front via
AskUserQuestion\]\[verify a decision-recording deliverable by
cross-document consistency re-read,
SOLO\]\[right-size-SOLO-even-under-ultracode\]. **Apply:** when the
owner says “adopt ” — treat it as a decision-recording deliverable
(convert nothing); ask the option’s open sub-decisions first; then flip
every decision surface in the source doc, resolve the sub-decisions
inline, re-derive and fix any consequence the doc stated under a
different sub-choice, record the implementation slices in the doc +
ROADMAP + CHANGELOG (no NEWS, no auto-memory), and verify by reading all
the touched docs as one consistent story.

#### Learning 100 — Converting a doc Rmd → Quarto `.qmd` is not just a rename: (a) the target format has SEMANTIC differences the source didn’t (Quarto treats `:::` as fenced-div/callout syntax; R Markdown doesn’t), so you must RENDER to catch them — a static rename hides them; (b) verify the conversion changes no *package* contents by applying the `.Rbuildignore` regexes to BOTH filenames, don’t assume “it was ignored so the new one is too”; (c) when the doc isn’t reproducibly renderable (dead hardcoded paths, unmaterialized packages), render with `--no-execute` to verify FORMAT validity and STATE the execution limitation — do not fake a full render, and do NOT “fix” the doc into being executable (that’s a behavior change, not a format conversion); (d) preserve the author’s historical prose byte-for-byte rather than rewrite it to silence a cosmetic warning whose output is verified correct (FM \#22). (S106, Quarto Hybrid §7.1 slice 1 — `inst/extdata/meeting_notes.Rmd` → `.qmd`)

**What happened.** Slice 1 of the adopted Hybrid doc policy: convert the
build-ignored developer doc `inst/extdata/meeting_notes.Rmd` to `.qmd`.
The mechanical change is tiny — `git mv` + one YAML line
(`output: html_document` → `format: html`, matching the two
already-`.qmd` sibling dev docs); `git diff -M` reported
`similarity index 99%`, body byte-for-byte. The *value* was in the
verification, which surfaced three things a rename-only “conversion”
would have missed: - **A real Rmd→qmd semantic difference.** Rendering
the `.qmd` (Quarto 1.7.33) emitted a warning that the string
`nprcgenekeepr:::` “looked like a fenced div.” Quarto treats `:::` as
fenced-div / callout syntax; R Markdown does not. The token was R’s
internal-function operator quoted from a 2020 CRAN-review reply, sitting
in prose. Checking the rendered HTML proved it rendered correctly
(mid-line `:::` is not a div delimiter — a heuristic false-positive), so
it was left byte-faithful. But the general point holds: **a static
rename would never have revealed it; only the render did.** Other latent
Quarto-vs-Rmd differences (header attributes
[`{}`](https://rdrr.io/r/base/Paren.html), raw-HTML/`$math$` handling,
callouts) live in the same blind spot. - **The doc isn’t reproducibly
renderable — and that’s not mine to “fix.”** Five embedded R chunks
hardcode 2020-era absolute paths
(`/Users/rmsharp/.../20160816_GeneticManagementTools`) and need packages
absent from the default library (the standing renv-not-materialized
condition). `include=FALSE` hides output but the chunk still *executes*,
so a full render fails on the dead paths even with packages. This is a
historical meeting-notes log, not a live computational document. The
build-equivalent (SAFEGUARDS “Verify the Build Equivalent”) was
therefore satisfied by `quarto render --no-execute` (verifies YAML +
markdown + structure → 81 KB HTML, code shown not run) with the
execution limitation **stated, not silently skipped**. Making it
re-executable (e.g. `eval: false` globally, or repointing the paths)
would have been a behavior/content change masquerading as a format
conversion — FM \#8 / the SAFEGUARDS two-mode “while I’m at it” trap. -
**“It was build-ignored” is not proof the new file is.** I confirmed it
by reading both relevant `.Rbuildignore` regexes
(`^inst/extdata/meeting_notes\.` — extension-agnostic — and
`^inst/extdata/.*\.qmd$`) AND by running every `.Rbuildignore` pattern
against both `meeting_notes.Rmd` and `meeting_notes.qmd` in R
(`ships=FALSE` for both). Had the ignore pattern been extension-specific
(`...\.Rmd$`), the conversion would have started *shipping* the new
`.qmd` into the CRAN tarball — a silent package-contents change. For an
archived package mid-resubmission (Learning 95), that’s exactly the kind
of invisible regression to rule out, not assume.

**Reflexes:** \[Rmd→qmd is a format change with SEMANTIC differences
(`:::` fenced divs), not just a rename — RENDER to catch them\]\[verify
a doc conversion changes no package contents by running the
`.Rbuildignore` regexes against BOTH old and new filenames, not by
assuming\]\[when a doc isn’t reproducibly renderable (dead paths /
unmaterialized packages), render `--no-execute` to verify FORMAT and
STATE the execution limitation — never fake a full render\]\[do NOT
“fix” a historical doc into being executable during a format conversion
— that’s a behavior change (FM \#8)\]\[preserve the author’s historical
prose byte-faithful; don’t rewrite it to silence a cosmetic warning
whose output is verified correct (FM \#22)\]\[`git mv` for doc renames —
preserves history, fully reversible\]\[1-and-done: one slice, do not
bundle the next (FM \#18/#25)\]\[right-size SOLO for a single-file
mechanical conversion even under ultracode\]. **Apply:** when converting
any doc between markup engines — do the minimal faithful change
(`git mv` + the format-line), then RENDER (using `--no-execute` if the
doc isn’t reproducibly executable) to catch target-format semantic
differences, confirm via the ignore/build rules that no shipped-contents
changed, state any verification you could not perform, and leave the
author’s content byte-faithful unless a real output defect (not a
cosmetic warning) forces a change.

#### Learning 101 — A “make it render/build” doc deliverable is verified by building it through the REAL consumer’s integration path, not a proxy renderer — and an adversarial reviewer’s “correction” is a claim to check against ground truth, not a verdict to act on. (S107, Quarto Hybrid §7.1 slice 2 — pkgdown mixed mode + `vignettes/articles/breeding-group-formation.qmd`)

**What happened.** Slice 2 of the adopted Hybrid doc policy: stand up
pkgdown mixed `.qmd`/`.Rmd` mode and author the first Quarto pkgdown
article (a scripted breeding-group-formation walkthrough on shipped
`examplePedigree` data). Three things made the verification the real
work: - **Recon against the canonical source corrected an imprecise plan
instruction.** The §7.1 policy note said “add a `_quarto.yml`
(`project: render: ['*.qmd']`)” without saying *where*. The
authoritative pkgdown docs (+ usethis `use_article()`) say the
`_quarto.yml` and the `.qmd` both live **inside `vignettes/articles/`**
(pkgdown turns that dir into a Quarto project), and a single
`.Rbuildignore` line `^vignettes/articles$` then makes the whole dir
website-only — covering the article, the `_quarto.yml`, and any
`.quarto/` cache. A root `_quarto.yml` (my Phase-1 assumption) would
have needed its own ignore entry and could have pulled the `.Rmd`
vignettes into a Quarto project. Reading the source of truth beat acting
on the plausible-sounding policy paraphrase. - **Render-only is a proxy;
build through the real consumer.** `quarto render` proves the article’s
R chunks execute (they did, ~1.7 s, deterministic via `set_seed(1L)`).
But the deliverable’s actual claim is “**pkgdown** mixed mode works.” So
I installed pkgdown 2.2.0 + the `quarto` R package locally and ran
[`pkgdown::build_article`](https://pkgdown.r-lib.org/reference/build_articles.html)
— which surfaced an integration detail a renderer never would: pkgdown’s
name for the article is `articles/breeding-group-formation` (with the
`articles/` prefix), and the build only succeeded once I used it (the
bare stem errored “Can’t find article”). The two-path verification
(quarto render AND pkgdown build) is what makes “mixed mode is stood up”
a tested claim rather than a hopeful one. Zero CRAN risk was likewise
*proven* (a real `R CMD build` tarball shows the `vignettes/articles/`
tree absent and the shipping vignettes unaffected), not assumed. -
**Verify the verifier.** A fresh adversarial reviewer flagged the
article’s “threshold 0.015625 = 1/64 = second cousins” as wrong,
asserting 1/64 is *third* cousins. Checked before acting: it confused
the **coefficient of relationship** (r; second cousins = 1/32) with the
**kinship coefficient** (φ = r/2; second cousins = 1/64) — and this
package computes φ. The package’s own manual
(`vignettes/manual_components/_breeding_group_formation.Rmd`) says the
default ignores “relatedness more distant than second cousins.” The
original was correct; I left it unchanged. An adversarial pass is only
as trustworthy as the check you run on *its* claims.

**Reflexes:** \[verify a doc/render deliverable through the REAL
consumer’s build path (here
[`pkgdown::build_article`](https://pkgdown.r-lib.org/reference/build_articles.html)),
not just a standalone renderer — the integration path catches
discovery/naming/wiring the renderer can’t\]\[read the
canonical/authoritative source for config placement; don’t act on a
plan’s paraphrase of it\]\[prove zero-CRAN-risk for a website artifact
with a real `R CMD build` tarball + build-ignore the whole
`vignettes/articles/` dir — don’t assume\]\[an adversarial reviewer’s
“correction” is a candidate, not a verdict — check it against ground
truth (the math AND the package’s own docs) before changing anything;
distinguish kinship coefficient φ from coefficient of relationship
r\]\[build a how-to article on the function’s own roxygen `@examples`
pipeline so it exercises the same code `R CMD check` runs\]\[seed once
up front (`set_seed`) for reproducible rendered stochastic
output\]\[right-size: recon as a Workflow for breadth/context-economy,
author the prose SOLO, verify through real build paths\]. **Apply:**
when a deliverable is “make X render/build on surface Y,” verify by
building it on Y itself (install Y’s real toolchain if needed), prove
any “won’t ship / no risk” claim with the actual build artifact, ground
config choices in the authoritative docs rather than a plan’s
restatement, and treat every adversarial finding — including a
reviewer’s — as a claim to verify, not accept.

#### Learning 102 — When documenting a function’s outputs/scoring, the GROUND TRUTH is the implementation run on real data plus the scoring source — NOT the function’s own roxygen, which can drift. Run the pipeline first; read the ordering/scoring code; treat `@return`/`@param` prose as a hint. (S108, Quarto Hybrid §7.1 — second article `vignettes/articles/genetic-value-analysis.qmd`, a scripted `reportGV()` walkthrough)

**What happened.** Authoring an accurate how-to for
[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
meant getting three things right that the package’s OWN roxygen states
incorrectly — caught only by reading the implementation: (1)
`orderReport.R` `@return` says the High-Value mean-kinship tier is “mean
kinship less than 0.25,” but the code (`orderReport.R:63`) gates on the
**z-score** (`zScores <= 0.25`), not raw mean kinship; (2) `calcFEFG.R`
roxygen calls the founder weight `p` the “average number of
descendants,” but the code computes Mendelian-halved proportional
**contributions** (`calcFounderContributions.R`); (3) `reportGV.R`
`@return` says it returns “A dataframe,” but it returns a **list** of
class `nprcgenekeeprGV`. The article is correct in all three because it
was written from the code + a real run, not from the roxygen.

**Run-the-pipeline-first paid off.** Executing the GVA on shipped
`examplePedigree` (deterministic via `set_seed(1L)` — the gene-drop
behind genome uniqueness / `fe` / `fg` is stochastic; mean kinship is
not) produced the real numbers the prose describes (327-animal
population of interest, 199/128 High/Low Value, `fe` 109.67 / `fg`
47.62) and surfaced the teaching example for free: the rank-1 animal has
higher genome uniqueness but NOT the lowest mean kinship — which is
exactly why the ranking uses both metrics. The article prints computed
values in chunks rather than hardcoding them, so the rendered output is
the ground truth.

**Verify-the-verifier held again (Learning 101).** This time the
adversarial reviewer’s flags were ALL real — I confirmed each against
the code before applying three precision fixes: `meanKinship.R` is
`colMeans` over the whole matrix incl. the diagonal → “all animals
incl. itself,” not “every other”; `orderReport.R:59` tier-2 sort breaks
ties on ascending z-score; `orderReport.R:32` imports tier also requires
`id %in% founders`. An adversarial pass that returns “no must-fix” still
earns its cost: it converted three latent imprecisions into fixes and
independently confirmed the article out-corrects the roxygen.

**Discovered, not mine (flagged, not fixed — FM \#8).** The sibling S107
article `breeding-group-formation.qmd` comments its focal set is “the
founders still in the colony,” but the filter
`!(is.na(sire) & is.na(dam))` selects **non-founders** (≥ 1 known
parent). A one-line prose inversion; left for an owner-approved session.

**Reflexes:** \[run the function’s real pipeline on shipped data and let
the printed output be the ground truth before writing a descriptive
sentence\]\[read the scoring/ordering implementation
(`orderReport`/`rankSubjects`/`calcFEFG`), not the function’s `@return`,
when the doc’s whole job is to explain behavior — roxygen drifts\]\[seed
once up front for reproducible stochastic rendered output\]\[an
adversarial reviewer’s flags are claims to verify against code, even
when they all turn out right\]\[a how-to built on the function’s own
`@examples` shape exercises the code `R CMD check` runs\]\[right-size:
recon Workflow for breadth, author SOLO, verify through real build
paths\]. **Apply:** documenting any function’s outputs/scoring — derive
every claim from a real run + the implementation; where the roxygen is
wrong, FIX-FORWARD in the doc and note the roxygen for a future repair
session; flag, don’t fix, errors you find in sibling artifacts.

#### Learning 103 — Ground-truth-first documentation also means running the UNHAPPY paths: a function’s error/edge behavior is part of what you are documenting, and running it can refute an assumption you would otherwise have written down as fact. (S109, Quarto Hybrid §7.1 — third article `vignettes/articles/studbook-quality-control.qmd`, a scripted `qcStudbook()` walkthrough)

**What happened.** Documenting
[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
meant describing two modes (`reportErrors = FALSE` production vs `TRUE`
diagnostic) and how each handles every category of bad input. From
reading the code I had *assumed* invalid dates were silently coerced to
`NA` in production mode. Running `qcStudbook(pedInvalidDates)` showed it
actually **stops** (“invalid dates on row(s) 3 and 4”). Running each
shipped error-demo set in both modes produced the exact, verified
behavior table the article rests on — auto-corrected
(female-sire/male-dam, exact duplicates), fatal (missing column, invalid
date, sire==dam, young parent, period-in-ID), and the diagnostic list’s
named elements (returning `NULL` when clean). The shipped
`pedGood`/`pedFemaleSireMaleDam`/`pedInvalidDates`/`pedDuplicateIds`/`pedMissingBirth`/`pedSameMaleIsSireAndDam`
data sets are purpose-built worked examples — find and use them rather
than constructing inputs.

**Determinism by reading, not hoping.**
[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
has no random component (no seed needed — unlike the GVA/breeding
siblings whose `reportGV`/`groupAddAssign` gene-drop is stochastic), and
its one [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html) dependency
(`calcAge` for living animals) is bypassed because `examplePedigree`
ships an `age` column, so no live-date value enters the displayed
output. Confirmed empirically by the render-determinism review lens: two
render passes produced byte-identical HTML. When a fatal call must
appear in a render, wrap it in
`tryCatch(..., error = function(e) cat(conditionMessage(e)))` so the
real message is shown without breaking the build (vs an `#| error: true`
chunk whose toolchain support I had not proven here).

**Two-lens adversarial review + verify-the-verifier (Learning
101/102).** Ran the review as two parallel lenses (code-correctness vs
the implementation; pedagogy + render-determinism). No must-fix; I
confirmed each flag against the code before acting — the `H` sex-code
flag was real (`qcStudbook` calls `convertSexCodes(ignoreHerm = TRUE)` →
`H`/`HERMAPHRODITE`/`4` fold to `U`, never output), so I fixed the
article (out-correcting an over-broad “M/F/U/H” claim) and added a
`## Setup` section for house-style parallelism with the siblings; left
the “defensible digest” column-rename nit as-is.

**Reflexes:** \[run the unhappy paths, not just the happy path —
error/edge behavior is part of the documentation surface, and running it
can refute a code-reading assumption\]\[prefer shipped purpose-built
example data sets over constructed inputs\]\[prove render determinism
both by reading for RNG +
[`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html) reachability AND by
a byte-identical double render\]\[show a fatal call via `tryCatch` +
`cat(conditionMessage(e))` so the build stays clean\]\[two adversarial
lenses (correctness vs pedagogy/render) beat one for a doc article;
still verify every flag against code\]. **Apply:** documenting any
function with modes/error handling — exercise every mode on real data
and let the output be the table; a behavior you only read in the source
is a hypothesis until you run it.

#### Learning 104 — When the documentation IS a data visualization, the figure’s input filter is part of the truth: read what the plot actually includes/excludes, and run it on the example data — a plot built from incomplete data can show the OPPOSITE of reality, not just an attenuated version. (S110, Quarto Hybrid §7.1 — fourth article `vignettes/articles/age-sex-pyramid.qmd`, a scripted `getPyramidPlot()` walkthrough)

**What happened.** `getPyramidPlot(qcPed)` looked like it would plot
“the living colony,” and a naive article would have said so. Running it
(and `fillBins`) showed the pyramid plots only living animals **with a
known age** — 46 of 89 living, because 43 living animals lack a birth
date and so cannot be aged. Those 43 are *all male*, so the plot shows
35 F / 11 M (≈ 3:1 female) while the living colony is actually 35 F / 54
M (male-majority). The visualization shows the **reverse** of the real
sex ratio. The article was built on the verified numbers and turned this
into its central lesson (missing birth dates can *invert* a demographic
plot, not just shrink it — quality-control first), which the second
adversarial lens then sharpened from “under-counts males” to “the skew
is reversed.”

**Determinism for a base-graphics figure.** The pyramid is
[`plotrix::pyramid.plot()`](https://plotrix.github.io/plotrix/reference/pyramid.plot.html)
(base graphics), so the plotting call must be the chunk’s last
expression, and `#| results: hide` keeps the function’s (non-plot)
return value out of the rendered output. The render is deterministic in
*shape* — no RNG, no seed (unlike the GVA/breeding siblings), and
`qcPed` ships a frozen `age` column — but the title embeds
[`lubridate::now()`](https://lubridate.tidyverse.org/reference/now.html),
so the date label is the build date. I characterized that honestly
rather than trying to force byte-identical output.

**Two-lens review + verify-the-verifier (Learning 101/102/103).**
Code-correctness re-ran every number against `qcPed` (all held). The
pedagogy lens caught the reversed-skew understatement and the V&R
reference over-attribution; I confirmed both against the data (living
35F/54M) and the paper’s actual subject before applying. Found (not
fixed, FM \#8) a `getPyramidPlot` `@return` roxygen drift (claims
`par('mar')`; returns `pyramid.plot()`’s value) — flagged for the
roxygen-repair session.

**Reflexes:** \[for documentation-of-a-plot, read the plot’s input
filter (`fillBins`: living + non-NA age) and run it on the example data
— the figure’s coverage is part of the claim\]\[a plot from incomplete
data can show the OPPOSITE of reality, not just an attenuated version —
check stratum-by-stratum (here the dropped 43 are all male, flipping the
sex ratio)\]\[base-graphics chunk: plot is the last expression +
`#| results: hide` to drop the return value\]\[a `now()` title is an
honest “as of render date,” not a determinism defect to hide\].
**Apply:** documenting any plotting function — derive the description
from what the function actually plots on real data, and stress-test
whether missing data could invert (not merely shrink) the visual
conclusion.

#### Learning 105 — A flagged error from a previous session is a claim to re-verify, not a fact to action: confirm it two ways (internal corroboration + ground truth on the example data) before correcting, and right-size a one-line fix as SOLO. (S111, doc fix `vignettes/articles/breeding-group-formation.qmd` — corrected the inverted “founders” → “non-founders” focal-population description)

**What happened.** S108 discovered, and S109/S110 carried forward, that
the breeding-group article called its focal set “the founders still in
the colony” while the filter `!(is.na(sire) & is.na(dam)) & is.na(exit)`
actually selects **non-founders**. Rather than trust the prior-session
flag and swap the word, I confirmed it two independent ways: (1)
**internal corroboration** — the same sentence trims the pedigree to the
focal set “plus the ancestors needed to compute their kinships,” and
founders by definition have no ancestors, so the focal set logically
*must* be non-founders; (2) **ground truth** — ran
`qcStudbook(examplePedigree)` + the article’s own filter: 327 focal
animals, none founders, all with ≥ 1 known parent (1,668 founders in the
studbook, zero in the focal set). Both agreed with the flag, so the fix
was safe. The correction also adds an inline definition (“those with at
least one known parent”) so the term is clear without the reader
cross-referencing the code.

**Right-sizing under ultracode.** A one-line prose correction with a
deterministic two-way verification has no breadth to fan out and no
competing claims to adjudicate — it was done SOLO. Spawning a Workflow
would have been theater (the same S100/S106 call for genuinely
single-threaded mechanical work). Ultracode means *exhaustive and
correct*, not *always multi-agent*; here exhaustiveness was the two-way
verification, not parallelism.

**Reflexes:** \[a flagged error inherited from a predecessor is a
hypothesis to verify against code + data, not a fact to action blindly —
even when the predecessor was reliable\]\[confirm a prose-vs-logic
mismatch two ways: internal corroboration (does the surrounding text
agree?) + ground truth (run the actual filter on the example
data)\]\[when correcting an inverted term, add an inline definition so
the fix also removes the ambiguity that allowed the
inversion\]\[right-size: a one-line fix with deterministic verification
is SOLO, not a Workflow\]. **Apply:** actioning any “discovered, not
mine” flag from a prior session — re-verify it firsthand before editing;
the discoverer couldn’t fix it precisely because it wasn’t their
deliverable, so the claim has never itself been re-checked.

#### Learning 106 — Regenerating a generated artifact (here `man/` via `roxygenise()`) with a dev tool newer than the committed baseline silently reformats EVERY file and migrates config — read `git diff --stat` after any codegen step, and if it touches files beyond your edits, revert the version migration and apply the change surgically rather than bundling a tooling bump into a content fix. And: re-verifying inherited flags can REFUTE them, not just confirm them. (S112, roxygen-repair pass — fixed 3 of 4 inherited `@return`/`p` drifts across `orderReport`/`calcFEFG`/`reportGV` + the `calcFE`/`calcFG` siblings)

**What happened (the blast-radius trap).** The deliverable was a 5-line
roxygen prose fix + a `man/` regen. Running
[`roxygen2::roxygenise()`](https://roxygen2.r-lib.org/reference/roxygenize.html)
rewrote ~30 `.Rd` files and changed `DESCRIPTION` — far beyond the 4
functions I edited. Cause: the committed `man/` was generated with
roxygen2 **7.3.2** (`RoxygenNote: 7.3.2`), but the dev library has
**8.0.0**, which reformats every page (data-doc `\usage` `qcPed` →
`data(qcPed)`, re-wrapped `\value`) and migrates the field
(`RoxygenNote:` → `Config/roxygen2/version:`). Committing it would have
bundled a tooling-baseline migration — a deliberate, CRAN-coordinated
decision — into a doc fix. Countermeasure:
`git checkout -- man/ DESCRIPTION` to drop the version artifacts, then
hand-edited the four affected `\value` blocks to match source, keeping
the diff to exactly 5 `R/` + 4 `man/` files. The 7.3.2→8.0.0 migration
was flagged as a separate task. **General rule: after any
codegen/regeneration step, read `git diff --stat`; if it touches files
you did not intend, a version/tooling mismatch is reformatting them — do
not commit it as part of a content change.** (This is the codegen
sibling of SAFEGUARDS “Verify Render-Dependency Completeness” — a tool’s
*version* is a render dependency.)

**Re-verifying inherited flags can refute, not just confirm (extends
Learning 105).** Four `@return`/param drifts were inherited as code-read
claims (three from S108, one from S110) never confirmed against runtime.
An 8-agent verification workflow (one verifier + one adversarial
cross-checker per claim) confirmed three and **refuted the fourth**:
`getPyramidPlot.R`’s `@return` (“the return value of `par('mar')`”) is
correct — the function returns
[`plotrix::pyramid.plot()`](https://plotrix.github.io/plotrix/reference/pyramid.plot.html)’s
value, but `pyramid.plot` ends with `return(oldmar)` where
`oldmar <- par("mar")`, so the returned value *is* a `par("mar")` vector
(verified: returns `c(5.1, 4.1, 4.1, 2.1)`). S110’s flag was a
false-dichotomy code-read (“returns pyramid.plot, not par(‘mar’)”) that
never ran the function. Trusting it would have replaced a correct
`@return` with a wrong one. The cross-check also surfaced same-defect
instances beyond the named scope (the `p` description in sibling
`calcFE`/`calcFG`; a second `orderReport` `@return` bullet), which the
owner approved folding in.

**Right-sizing: this one earned a Workflow where S111 did not.**
Adjudicating four independent inherited claims that ship to CRAN — each
needing a code trace + an adversarial check — has real breadth and
competing claims, so the verify+refute fan-out was warranted (contrast
Learning 105’s single deterministic one-liner, correctly SOLO).
Verification fans out; the mutation (edits + regen) stays
single-threaded in the main loop to keep control and avoid worktree
conflicts.

**Scope discipline held with one disclosed extension.** Fixed exactly
the agreed `p`-description in `calcFE`/`calcFG` (kept their `r` clause),
and flagged — did not fix — adjacent pre-existing defects (`calcFE`’s
`@return` mentions `r` though `FE = 1/sum(p^2)` has none; the
`sum( (p^2) / r}` formula has unbalanced parens; the pre-existing
`reportGV.Rd` `\title`-ends-in-period `checkRd` note).

**Reflexes:** \[after ANY codegen/regeneration step, read
`git diff --stat` before trusting it — a diff touching files beyond your
edits means a tool/version mismatch is reformatting them; revert and
apply surgically\]\[never bundle a generated-tooling version migration
(here roxygen 7.3.2→8.0.0) into a content fix — it’s a separate,
deliberate decision\]\[a generated artifact (`man/*.Rd`) may be
hand-edited as a scoped, disclosed exception when regenerating would
force a version migration — the content matches source, so a later
proper regen reconciles cleanly\]\[re-verify inherited flags against
runtime, not just code-read — they can be WRONG, not merely unconfirmed;
one of four here was\]\[verification fans out (verifier + adversarial
refuter per claim), mutation stays single-threaded\]\[doc-change
build-equivalent =
[`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html) +
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html) +
render the `\value`, not full `R CMD check`; `devtools` is NOT in the
renv lib, `roxygen2`/`pkgload`/`pkgbuild` ARE\]. **Apply:** any task
editing roxygen/generated docs — check the regen blast radius, keep
tooling migrations out of content fixes, and re-verify every inherited
claim firsthand before acting on it.

#### Learning 107 — A generated-tooling version migration, taken as its OWN deliverable, is the clean inverse of the blast-radius trap (Learning 106): the diff is small and reviewable, and regenerating with the newer tool also REPAIRS content that had silently drifted between the source and the committed artifact. Adopt it safely by reading the COMPLETE regen diff (every change must be an intended kind) and confirming the new tool introduces ZERO new linter findings — not by spot-checking. (S113, owner pick A — adopted roxygen2 8.0.0, regenerated `man/`)

**What happened.** S112 hit roxygen2 8.0.0 reformatting `man/` mid-way
through a content fix and correctly isolated the version migration as a
separate, deliberate task. S113 executed that task as its whole
deliverable. Counter to the “blast radius” framing, the isolated
migration was *small*: **26 of 190 `.Rd` files + `DESCRIPTION`**, 31
insertions / 29 deletions, `NAMESPACE` untouched. The changes were
exactly three kinds — the `Config/roxygen2/version` field rename
(`RoxygenNote: 7.3.2` retired), 24 dataset docs adopting 8.0.0’s
canonical `\usage{ data(name) }` form, and a cosmetic `\value` re-wrap —
plus a fourth, unexpected and *beneficial*: regenerating
`man/nprcgenekeepr-package.Rd` repaired a shipped typo (`'mulatto'` →
`'mulatta'`, already correct in `DESCRIPTION`) and added the maintainer
to the Authors list. The committed 7.3.2 `.Rd` had drifted from its
source; the regen reconciled it.

**The migration IS the point, so verification is “is the WHOLE diff
intended?”, not “did I break anything?”** The adversarial check that
mattered was reading the complete diff (all 27 files) and tallying every
added line — confirming there were no surprise edits hiding among the
mechanical ones — and proving the new tool added ZERO new `checkRd`
problems by checking all 26 pages and confirming the 11 flagged
`\title`-period NOTEs were already present on the committed HEAD (62 of
190 package-wide). A spot-check of a few files would have missed either
a stray change or mistaken a pre-existing NOTE for a regression.

**Right-sizing: SOLO, but with a full-diff audit, not a fan-out.** A
deterministic regen whose diff is fully inspectable has no competing
claims to adjudicate, so a multi-agent workflow would be theater (the
S111/S106 call). The rigor lived in reading 100% of the diff and the
HEAD-vs-working `checkRd` comparison, not in parallelism. Pinning the
old tool was the rejected alternative: roxygen2 isn’t in `renv.lock`
(dev-only dep), so a pin needs a manual downgrade and doesn’t survive
[`renv::restore`](https://rstudio.github.io/renv/reference/restore.html)
— adopting was both less work and durable.

**Reflexes:** \[a tooling version migration is a legitimate standalone
deliverable — isolate it from content fixes (Learning 106), then DO it
deliberately when it’s the chosen task\]\[verify a regen by reading the
COMPLETE diff and classifying every change as an intended kind — a
regen’s correctness is “is the whole diff intended?”, not “spot-check
looks fine”\]\[prove a new codegen tool adds no regressions by running
the linter (`checkRd`) on every changed artifact AND confirming any
findings pre-exist on HEAD — don’t assume a NOTE on a changed file is
new\]\[a newer codegen tool can repair drift between source and a stale
committed artifact — treat it as a benefit, but disclose it (it
ships)\]\[prefer adopting over pinning when the tool isn’t snapshotted
in the lock — a pin isn’t durable across
[`renv::restore`](https://rstudio.github.io/renv/reference/restore.html)\].
**Apply:** any deliberate regeneration-tool or formatter version bump
(roxygen2, styler, a codegen) — take it as its own commit, audit the
entire diff, and confirm zero new linter findings against HEAD.

#### Learning 108 — A large-but-uniform mechanical doc sweep (here 62 `\title`-ends-in-period `checkRd` NOTEs) is a legitimate SINGLE deliverable when the edit is ONE kind and the verification is an ORACLE: dry-run a deterministic script and audit every before/after BEFORE writing, then prove via a per-page HEAD-vs-working `checkRd` diff that ONLY the target NOTE disappeared and NOTHING was added. (S114, owner pick A2 — title-period mop-up across 52 title files + 3 GV `@return` files = 55 `R/` total)

**What happened.** The flagged work — 62 of 190 `.Rd` carrying
`\title should not end in a period`, plus `calcFE`’s spurious `r` clause
and the unbalanced-paren `fg` formula in `calcFEFG`/`calcFG` — all
re-verified true against the current tree (a flag is a claim, not a
fact; Learning 105/106). The blast radius (~55 source files) *looks*
like it violates the SAFEGUARDS “5 files” rule, but the rule targets
unrelated multi-file scope creep; a single uniform mechanical change
(remove one trailing period per title) verified by an oracle is a
different shape. Right-sized as ONE deliverable after the owner blessed
the scope via a pre-RED `AskUserQuestion` (full sweep vs. narrower;
concrete previews; ASCII-only labels per
\[\[ascii-only-in-question-options\]\]).

**Why SOLO + script + oracle, not a fan-out.**
[`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html) is a
ground-truth oracle: if 0 title-period NOTEs remain and no changed page
gained a new note, the titles are correct. When the check is an oracle,
parallel agents add variance, not safety, for “remove one character” — a
deterministic script is *more* reliable than 51 hand-edits or 51
sub-agents. Edits were made at the roxygen SOURCE and `man/` regenerated
(never hand-edit `.Rd`). The rigor lived in two places: (1) a
**dry-run** of the title script that printed every title paragraph + its
before/after so all 51 were audited *before* any write (each correctly
identified the title = first roxygen paragraph, including multi-line
titles); (2) a **per-page HEAD-vs-working `checkRd` comparison**
(normalize away line numbers, set-diff the messages) proving 62 pages
had ONLY the period NOTE removed and 0 pages gained anything — the
precise “no new problems” proof, scoped to the 65 changed pages (the
other 125 are byte-identical to HEAD). Confirmed `load_all` (162
exports) + `NAMESPACE`/`DESCRIPTION` unchanged. This extends Learning
107 (deterministic regen → SOLO full-diff audit) to a deterministic
*source sweep*.

**The shell backslash trap (recurring — bit S112/S113 too).**
`Rscript -e '... pattern="\\.Rd$" ...'` and `grep("^\\\\title", ...)`
get mangled through the Bash tool layer — a backslash level is stripped,
so R sees an invalid escape (`'\.' is an unrecognized escape`) or a `\t`
tab that matches nothing. Fix: WRITE the R probe to a file (Write tool)
and run `Rscript file.R` — file contents are passed verbatim, no shell
re-escaping — and/or use backslash-free constructs: `endsWith(f, ".Rd")`
not a regex, `[.]` not `\\.`, `fixed = TRUE`, POSIX `[[:space:]]`. Reach
for the file-based probe FIRST given the documented history.

**Scope discipline.** Period-removal is mechanical, so it left adjacent
CONTENT bugs intact, which were FLAGGED not fixed (FM \#8):
`findPedigreeNumber`’s title is a copy-paste of `findGeneration`’s;
`pedMissingBirth`/`pedSameMaleIsSireAndDam` data docs claim “no errors”
though they are error-demo sets; `focalAnimals`/`convertSexCodes`
grammar. The minimal-vs-proper fork for data-doc titles (remove period
vs. rewrite the run-on into a short title + `@description`) was surfaced
to the owner as part of the scope question; the owner chose minimal, so
the long titles are now checkRd-clean but a proper rewrite is deferred.

**Reflexes:** \[a large-but-UNIFORM mechanical doc change is one
deliverable when the edit is a single kind AND a linter/oracle can
confirm it — the SAFEGUARDS “5 files” rule targets unrelated scope
creep, not one verified uniform sweep\]\[prefer a deterministic script
over hand-edits or sub-agents when the change is “remove/replace one
token” — but DRY-RUN it and audit every before/after before
writing\]\[prove “no regressions” by a per-page HEAD-vs-working linter
diff (normalize line numbers, set-diff messages), scoped to changed
files — don’t eyeball\]\[when a linter is a ground-truth oracle, SOLO +
script + oracle beats a fan-out; parallel agents add variance not safety
for trivial mechanical edits\]\[write R probes to a FILE to dodge the
recurring shell backslash-mangling trap, or use
`endsWith`/`[.]`/`fixed=TRUE`/POSIX classes\]\[edit roxygen SOURCE
titles + regenerate; never hand-edit `.Rd`\]\[period-removal leaves
CONTENT bugs intact — flag the copy-paste/garbled titles, don’t fix them
in a mechanical pass\]. **Apply:** any mechanical lint-cleanup sweep
(trailing periods, deprecated tags, formatting) across many files — pose
the scope to the owner, dry-run + audit a deterministic fixer,
regenerate, and prove via a per-file before/after linter diff that only
the target finding cleared and nothing new appeared.

#### Learning 109 — A flagged doc “bug” is often one token inside a larger wrong claim; the correct fix verifies and repairs the WHOLE sentence against ground-truth data, and a regenerated data-doc’s auto-computed `\format` block is a free oracle for shape claims. (S115, owner pick A — repaired the 4 content bugs S114 flagged)

**What happened.** S114 flagged `pedMissingBirth`’s data doc for saying
“representing a full pedigree with no errors” (it is an error-demo set).
Loading the data to verify (Learning 105/106) showed the demonstrated
error is that the `birth_date` column is ABSENT entirely — and that the
same sentence’s “5 columns (ego_id, sire, dam_id, sex, birth_date)” was
therefore ALSO wrong (the object has 4 columns). The flagged token (“no
errors”) sat inside a larger inaccurate claim; fixing only the token
would have left “missing the birth_date column” contradicting “5 columns
including birth_date” in the same sentence. Surfaced the fork (minimal
touch vs. full accuracy) to the owner via `AskUserQuestion` grounded in
the probe output (concrete before/after previews, ASCII-only labels per
\[\[ascii-only-in-question-options\]\]); owner chose full accuracy. The
regenerated `.Rd`’s auto-generated `\format` line already read “8 rows
and 4 columns” — independent corroboration that the hand-written “5
columns” prose had drifted from the data object.

**Verify the claim, not the flag.** All four flags re-checked against
ground truth before editing: `pedSameMaleIsSireAndDam` row `o3` has
`dam_id = s1` (a male) and `s1` sires `o1`/`o2` (the same male is both
sire and dam; 5 columns correct, so only the error clause changed);
`focalAnimals` is 1 column (`id`) / 327 rows; `findPedigreeNumber`
assigns a connected-component number (the `pedNum` vector), not a
generation (its title was a verbatim copy of `findGeneration`’s);
`convertSexCodes`’s “to a standardized codes” is a number-agreement
error. Each fix states what the data/function actually is.

**A mid-session owner constraint can be already-satisfied — confirm,
don’t re-do.** The owner interjected that `pedMissingBirth` must “retain
the characteristic of not having a Birth column.” Because the
deliverable touched only documentation (never `data/`), the constraint
was already met; the right response was to verify the data object
post-edit (4 columns, `birth_date` absent) and confirm, not to change
anything (FM \#23 inverse — don’t manufacture work from a constraint
that’s already honored).

**Right-sizing: SOLO with firsthand data probes + a `checkRd` oracle.**
Five deterministic prose fixes whose correctness is established by
printing the actual data objects — a fan-out of agents to re-print data
I already printed would be theater (the S111/S113/S114 call).
Verification = per-page `checkRd` HEAD-vs-working diff (0 problems, 0
new) + `load_all` (162 exports) + a `data/`-unchanged check. Edits at
the roxygen SOURCE, `man/` regenerated; never hand-edit `.Rd`. Used
file-based R probes from the first command, dodging the recurring
shell-backslash trap (Learning 108) that bit S112–S114.

**Scope discipline.** Fixed exactly the four flagged items; FLAGGED but
did not fix newly-discovered adjacent bugs (FM \#8): the
`\code{pedgood}` wrong-case cross-reference in all six error-set docs
(dataset is `pedGood`), the `si.re`-vs-`sire` data/doc column-name
mismatch across the qc data family, and roxygen 8.0.0’s
`@importFrom must be only 1 line long` errors in `mod*.R`.

**Reflexes:** \[a flagged doc bug is a claim about one token — verify
the WHOLE surrounding sentence against ground-truth data, because the
correct fix often must repair a second, unflagged inaccuracy for
coherence\]\[load the actual data object and read its columns/rows
before describing a dataset — names lie, `\format` is computed\]\[a
regenerated data-doc’s auto-generated `\format` block is a free oracle
for shape claims (row/column counts) — cross-check hand-written prose
against it\]\[a mid-session owner constraint may already be satisfied by
the deliverable’s scope — verify and confirm, don’t re-open
work\]\[SOLO + firsthand probes + `checkRd` oracle for deterministic
prose fixes; flag (don’t fix) adjacent bugs found along the way\].
**Apply:** any task fixing a flagged documentation error — re-verify the
flag against data, repair the entire inaccurate claim (not just the
flagged word), cross-check counts against the generated `\format`, and
flag adjacent bugs for a separate pass.

#### Learning 110 — A flag can be wrong about a bug’s NATURE and SCOPE, not just its existence; before fixing, disprove your own hypothesis with the oracle, scan the whole codebase for the pattern, and trace “messy” data through its consumer — the principled fix sometimes INVERTS the obvious one. (S116, owner pick A — fixed the 3 adjacent doc/data-doc bugs S115 flagged)

**What happened.** S116 inherited three flags from S115 and each needed
re-examination beyond “is it real?”: (1) **Nature was wrong.** S115’s
flag — and my own restatement — called the wrapped `@importFrom` tags a
“latent NAMESPACE-drop hazard.” A fully-reverted regen probe
(`roxygenise()` on the current source, then `git diff NAMESPACE` +
count, then `git checkout`) disproved it: roxygen 8.0.0 prints
`✖ @importFrom must be only 1 line long` for all of them but still
parses every continuation line — `NAMESPACE` came back byte-identical
(140 `importFrom`, 0 removed). The bug was cosmetic lint, not a
regression. (2) **Scope was undercounted 3×.** The flag named 3 `mod*.R`
files; a file-based detector scanning every `@importFrom` in `R/`
(checking whether the next roxygen line is a non-tag continuation) found
**20 wrapped tags across 10 files**, including non-`mod` files
(`appServer.R`, `appUI.R`). (3) **The obvious fix was inverted.**
`si.re` (and `pedOne`’s `si re`) looked like a corrupted `sire` to
rename in the data; tracing it through its consumer showed
`fixColumnNames` strips spaces then periods (`si re` → `si.re` → `sire`)
and `qcStudbook(pedGood)` returns canonical `sire` — so `si.re` is an
*intentional raw QC-demo fixture* (`make.names("si re")` at `.rda`
creation), and renaming it would gut the fixture it exists to exercise.
The correct fix was the docs, not the data.

**Disprove your own hypothesis with the oracle, cheaply and
reversibly.** The single most valuable step was a throwaway regen whose
entire output I reverted (`git checkout -- man/ NAMESPACE DESCRIPTION`).
It converted a plausible-sounding inherited claim (“hazard”) into a
measured fact (“cosmetic; NAMESPACE byte-identical”) before I touched
anything — and I reported the correction to the owner rather than
quietly proceeding. Verify-the-claim-not-the-flag (Learning 105/106/109)
applies to *your own* characterization too, not just to a predecessor’s.

**Trace “messy” data through its consumer before cleaning it.** A value
that looks like corruption (`si.re`) can be a deliberate test input.
Read the normalization/validation function (`fixColumnNames`) and run
the end-to-end consumer (`qcStudbook`) to see what the messy form is
*for*. If it round-trips to the canonical value, it’s load-bearing — fix
the description, not the datum.

**Two owner-decisions → two pre-RED gates, each grounded in evidence.**
The data-vs-doc fork (item 2) and the 3-vs-10-file boundary (item 3,
surfaced *after* the scope/nature discovery) were each posed as a
separate `AskUserQuestion` with a recommendation and concrete tradeoffs
(ASCII-only labels per \[\[ascii-only-in-question-options\]\]); owner
chose full-accuracy docs and all-10-files. A discovery that changes what
a chosen option *means* (scope tripled, hazard→cosmetic) warrants
re-surfacing, not silent expansion (FM \#8) or a silent half-fix.

**Prove the neutral claim with the oracle, and match surrounding
style.** Item 3’s safety rested on `NAMESPACE` being byte-identical
after the real regen (`git diff --quiet -- NAMESPACE`), not on
reasoning. And the reformat split each over-long list into *multiple*
single-line `@importFrom pkg ...` tags wrapped at ≤80 chars (a
deterministic dry-run-first script, audited before writing, per Learning
108) — matching the authors’ existing wrapping rather than collapsing to
one 180-char line. Regression read confirmed 0 new failures (no
executable line changed — only `#'` comments).

**Reflexes:** \[run a reverted regen/build probe to measure a codegen
tool’s ACTUAL behavior before believing a flag about its effect — “✖”
lint is not the same as a functional change\]\[scan the whole codebase
for the flagged pattern with a deterministic detector — a flag’s file
list is a sample, not an inventory (SESSION_RUNNER
evidence-based-inventory applies to bug-fix scope too)\]\[before
“cleaning” a value that looks corrupt, read its consumer/normalizer and
run it end-to-end — an ugly raw value may be an intentional fixture that
round-trips to canonical\]\[correct your OWN mis-characterization to the
owner and re-pose scope when a discovery changes what the chosen option
means\]\[prove a “won’t change X” claim with the byte-level oracle
(`git diff --quiet`), not reasoning\]\[reformat to match surrounding
style — multiple ≤80-char single-line tags, not one mega-line\].
**Apply:** any inherited-flag fix touching generated artifacts
(roxygen/NAMESPACE/codegen) or example/test data — probe the tool’s real
behavior, inventory the pattern across the repo, trace messy data
through its consumer, gate genuine owner-forks, and verify neutrality
with the artifact oracle.

------------------------------------------------------------------------

#### Learning 111 — For a doc-rewrite that is structurally oracle-checkable but whose QUALITY is not, split the verification: do the edits SOLO with firsthand probes + oracle (checkRd/load_all/tests), then fan out an adversarial critic panel for the subjective dimension (title aptness, completeness, cross-doc consistency) that no oracle can judge. (S117, owner pick A2 — short-`@title` rewrite of all 24 data docs)

**What happened.** The deliverable was rewriting all 24 `R/data.R`
data-doc titles from “X is a …” run-ons into short noun-phrase titles,
with the detail moved to `@description`. Structural correctness — does
it render, is it `checkRd`-clean, are `NAMESPACE`/exports/tests
unchanged? — is fully oracle-decidable, so fanning *that* out would be
theater (Learnings 108–110). But title *quality* — is “Example studbook
with sex-mismatched parents” apt, accurate, non-duplicative? — is
**not** oracle-checkable. So I made the 24 edits solo (serial edits to
one file) and verified structure with the oracle, then ran a 3-lens
critic workflow (accuracy / completeness / style+consistency) over the
24 before/after pairs, each lens grounding itself in
`git show HEAD:R/data.R` plus the loaded objects. It returned **0 block,
0 should-fix, 3 nits**: a pre-existing `recordStats`→`recordStatus`
`\describe` drift (flagged, out of scope, FM \#8), a confusable
near-duplicate title prefix (`smallPed` vs `lacy1989Ped` — fix applied),
and a studbook-vs-pedigree term split (kept — owner-approved in the
preview).

**Verify every count-bearing claim before authoring it; a
self-contradicting auto-`\format` is a free oracle.** Before moving any
“N rows and M columns” sentence into a description I checked each
against the live object. Exactly one was wrong: `qcPed` said “277 rows
and 6 columns” but is 280×8 — and roxygen’s auto-generated `\format`
already read “280 rows and 8 columns”, so the page literally
contradicted itself. Authoring the moved sentence verbatim would have
perpetuated a falsehood; I wrote the accurate 280×8 and flagged the
correction (the S115/S116 verify-and-correct pattern, now extended to
title-rewrites).

**A critic suggestion that reverses an owner-approved previewed choice
is a note, not a mandate; improving your own un-previewed draft is
within latitude.** The style lens flagged “studbook” (the 6 QC fixtures)
as inconsistent with the file’s dominant “pedigree” — but the owner had
explicitly selected the “studbook” preview when choosing the style, so I
kept it (defensible: studbook-style input fixtures that *represent*
pedigrees and feed `qcStudbook`) and recorded the observation for the
future rather than silently flipping approved text. The `smallPed`
near-duplicate, by contrast, was my own un-previewed draft — I applied
the disambiguation directly.

**Reflexes:** \[for a rewrite whose structure is oracle-checkable but
whose quality is not, do edits solo+oracle and fan out ONLY the
subjective dimension — that’s the non-theater use of a critic
panel\]\[give each critic lens ground truth (HEAD diff + loaded
objects), not your summary, so it verifies independently\]\[verify every
count/column claim against the live object before moving it into prose;
a self-contradicting auto-`\format` is a free oracle\]\[keep an
owner-approved previewed choice when a critic merely *prefers* an
alternative — note it, don’t flip it; freely improve your own
un-previewed drafts\]\[flag pre-existing adjacent content bugs the panel
surfaces (FM \#8), don’t fix them mid-task\]. **Apply:** any bulk
documentation/content rewrite where rendering + lint prove structure but
not aptness — pair solo oracle verification with an adversarial quality
panel grounded in source-of-truth, verify factual claims firsthand, and
respect the owner-decision boundary.

------------------------------------------------------------------------

#### Learning 112 — “Merge X to master” is about `origin/master`, not the local `master` branch — `git fetch` first and reason about the REMOTE topology; a local mainline branch can be far behind, and the repo’s real merge mechanism (PR vs direct push) is encoded in its history. (S118, owner pick C — merge `add-methodology` → `master`)

**What happened.** Asked to “merge add-methodology to master”, the naive
read was a local fast-forward: local `master` (4790b64f) was a clean
ancestor of `add-methodology`, 183 behind. But `git branch -vv` showed
local `master` as `[origin/master: behind 168]` — the LOCAL master was a
stale red herring; the real target is `origin/master` (7a8433b3 = “Merge
pull request \#51 from rmsharp/add-methodology”). After `git fetch`,
`add-methodology` and `origin/master` were DIVERGED: 18 ahead / 3 behind
— and the 3 “behind” commits are merely the PR \#41/#43/#51 merge
bubbles (master accumulates merge commits; add-methodology stays linear
and never pulls them back). Fork point `14032640` (S100); the unmerged
work was S101–S117 (18 commits). The repo’s established mechanism is
GitHub PRs (a commit on add-methodology, 6175fe66, even records “PR \#51
merged to master”). So the correct action was a fresh PR \#52, not a
local merge.

**Fetch before reasoning about remote branches; trust `origin/<branch>`,
not local.** Remote-tracking refs are only as fresh as the last fetch,
and a local mainline branch can sit hundreds of commits behind its
remote (here 168). The first move for any “merge/compare/rebase against
master” task is `git fetch`, then reason about `origin/master`. The
`[behind N]` annotation in `git branch -vv` is the tell that a local
branch is stale.

**Read the merge mechanism out of the history before choosing one.** A
run of “Merge pull request \#N from ” commits on the target — plus a
feature branch that stays linear and never contains those merge nodes —
means the project merges via PRs and never reconciles the feature branch
backward. Matching that (open PR \#52) keeps history consistent; a local
`--no-ff` merge + direct push would deviate and may hit branch
protection.

**Confirm the mechanism on an outward main-branch action even under an
explicit instruction.** “Merge to master” authorizes the goal, but
pushing/merging the main branch is hard to reverse and the *who-merges*
split is a real choice — a one-question gated `AskUserQuestion` (I-merge
vs you-merge vs local) resolved it (owner: push + open PR, owner
merges). \[\[ascii-only-in-question-options\]\]

**Reflexes:** \[`git fetch` before comparing against any remote branch;
reason about `origin/<branch>`, never a possibly-stale local
mainline\]\[a `[behind N]` in `git branch -vv` means the local branch is
a red herring — use the remote\]\[detect PR-based vs direct-push
workflow from the merge-commit pattern in the target’s history and match
it\]\[on an outward main-branch action, confirm the mechanism and
who-merges with one gated question even when the goal is explicitly
authorized\]. **Apply:** any “merge/sync/compare branch X into mainline”
task — fetch first, target `origin/<mainline>`, identify the established
merge mechanism from history, and gate the outward step.

------------------------------------------------------------------------

#### Learning 113 — When the task is to fix an AUTHORIZED SET of flagged bugs, treat that list itself as a sample, not an inventory: after fixing exactly the authorized items, run a completeness scan of the WHOLE artifact for the same bug CLASS and FLAG (don’t fix) the siblings. (S120, owner pick A — fixed the 3 adjacent data-doc content bugs flagged in S117)

**What happened.** The owner authorized fixing exactly three
S117-flagged data-doc content bugs in `R/data.R`: `examplePedigree`’s
`\item{recordStats}` → `\item{recordStatus}` (real 12th column is
`recordStatus`, `recordStats` absent); `rhesusGenotypes`’s garbled
“There are object.” → “There are 31 rows and 3 columns.” (`dim` = 31×3,
31 unique ids, consistent with the neighboring “Represents 31 animals”
and the auto-`\format`); and `exampleNprcgenekeeprConfig`’s “…file
created the SNPRC.” → “…created at the SNPRC.” (missing locative
preposition). Each was verified against the live object before authoring
(Learning 109/111), edited at the roxygen source, regenerated (3 `man/`
pages, `NAMESPACE` byte-identical), and adversarially confirmed by three
independent refutation agents. But the highest-value step was a
**completeness critic** that scanned all 24 `\docType{data}` blocks
against their loaded objects for the same *class* of bug — and found
**two more not in the authorized list**: `ped1Alleles`’s V2/V3/V4
`\item`s all say “iteration 1” though V1≠V2≠V3≠V4 and the block itself
says “4 iterations” (R/data.R 134–142), and a missing-space
“column.Unknown dams” in the `dam` item of
`examplePedigree`/`lacy1989Ped`/`rhesusPedigree` whose parallel `sire`
items are correctly spaced (R/data.R 24/97/365). Both confirmed
firsthand, then **flagged for a future session, not fixed** (FM \#8, “1
and done”).

**An authorized list of flags is a sample of a bug class.** Learning 110
established that a single flag’s *file list* is a sample of one
pattern’s scope. This extends it one level up: a *set* of authorized
flags is a sample of a bug *class*. Fixing only the named items leaves
same-kind siblings in the artifact. A cheap whole-artifact scan for the
class — grounded in the live data (garbled/templated fragments,
`\item{}` names that aren’t real columns, grammar gaps, prose counts vs
[`dim()`](https://rdrr.io/r/base/dim.html)) — turns “fixed what I was
told” into “found everything of this kind.” Scope discipline means you
FLAG the extras, you do not fix them.

**Right-sizing under ultracode (where the fan-out is non-theater vs
theater).** Three one-line fixes whose structural correctness is
oracle-decidable (`checkRd`/`load_all`/regression/`NAMESPACE` byte-diff)
were edited SOLO+oracle. The workflow’s agents added information the
oracle cannot: independent re-derivation of each fix’s ground truth
(adversarial refutation) and the class-completeness scan. Honestly,
three identical verifiers re-deriving dims I already derived sit near
the theater line (Learnings 108–110); the **completeness scan is the
part that earned the fan-out** — it found two real bugs the flag-list
missed.

**Gate only the genuine fork.** Two of the three fixes were fully
determined by ground truth (a real column name; a missing preposition
S117 had already diagnosed) and needed no question. Only the garbled
`rhesusGenotypes` fragment had \>1 reasonable repair (fill in the real
count vs. delete the redundant sentence), so that single editorial
choice was the one gated `AskUserQuestion` (owner: fill in). Determined
fixes do not need a gate; over-gating is its own failure.

**Reflexes:** \[treat an authorized SET of flagged bugs as a sample of a
bug CLASS — after fixing the named items, scan the whole artifact for
the same class against live data and FLAG the siblings (extends Learning
110’s “a flag’s file list is a sample”)\]\[the completeness critic
grounded in live data is the non-theater half of a verify workflow for a
fix task — adversarial re-derivation confirms YOUR fixes, the scan finds
what the flag-list missed\]\[gate ONLY the genuine editorial fork — a
fix determined by ground truth (a real column, a real dim, a missing
word) needs no question; a garbled fragment with \>1 reasonable repair
does\]\[verify every flagged item firsthand before putting it in a
handoff — a flag must be confirmed, not relayed\]. **Apply:** any task
that fixes a list of flagged content/doc bugs — verify each against
ground truth, gate only genuine forks, fix exactly the authorized set,
then run a class-completeness scan of the whole artifact and flag (don’t
fix) the adjacents.

------------------------------------------------------------------------

#### Learning 114 — Verify a completeness-scanner’s flag firsthand against ALL parallel siblings — a per-group scanner’s finding is itself a sample and can miss a same-text sibling in another scan group. And when one bug CLASS recurs across many sessions, propose a single batch sweep as the better deliverable. (S121, owner pick A4 — fixed the 2 same-class data-doc bugs S120 flagged)

**What happened.** (A4) fixed exactly the two bugs S120’s completeness
scan had flagged: `ped1Alleles` `\item{V2}/{V3}/{V4}` “iteration 1” →
2/3/4 (object 554×6; V1–V4 distinct — all 6 pairwise
[`identical()`](https://rdrr.io/r/base/identical.html)=FALSE, 290/554
rows differ; `\item{parent}` says “4 iterations”; V1 correctly stays
“iteration 1”), and the missing-space “column.Unknown dams” in three
`dam` items. Both were ground-truth-determined → no gate (Learning 113),
edited SOLO+oracle (checkRd 0×4, NAMESPACE byte-identical, load_all 162,
regression 0/0, rendered-`.Rd` diff matches intent), and adversarially
CONFIRMED (2 refuters, refuted 0/2 each). The fresh completeness scan (4
agents over the 24 data docs) flagged a third same-class bug —
`examplePedigree`’s `\item{sex}` claims levels “M,F,U” but the factor is
`F,M,H,U`.

**A completeness-scanner’s flag is a sample too — verify it firsthand
against every parallel sibling.** Before writing the sex-levels flag
into the handoff I probed every data object’s `sex` column and grepped
every doc claiming “factor with levels”. The scanner (which only saw its
own 6-doc group) flagged `examplePedigree` but MISSED that
`rhesusPedigree` carries the identical doc text and is ALSO wrong — in
the opposite direction (its factor is just `F,M`; the doc over-claims a
`U` level that doesn’t exist). Firsthand verification turned a one-doc
flag into the correct two-doc scope. This is Learning 113’s “a flag is a
sample” applied to the verification agent’s OWN output: a fan-out
partitioned by group is structurally blind to a cross-group sibling, so
confirm-firsthand must check the whole sibling set (every doc sharing
the claim), not just the flagged instance.

**When a bug CLASS keeps recurring, the one-bug-at-a-time cadence is the
wrong shape — propose a batch sweep.** Data-doc factual-accuracy bugs
have now been found and fixed across S114/S115/S116/S117/S120/S121
(counts, column names, item labels, prose typos, and now factor levels).
Each session fixes the named instance and the completeness scan finds
the next. That pattern says the higher-ROI deliverable is a single
owner-gated sweep that audits EVERY factual claim in all 24 data docs
against the live objects (dims, column names/order, factor levels,
counts, prose) and fixes them as one batch — rather than discovering one
more each session. Flagged as a suggested next deliverable (not started
— “1 and done”).

**Reflexes:** \[a completeness-scanner’s finding is a sample — before
relaying it, verify firsthand against ALL parallel siblings (other docs
sharing the same claim text), because a group-partitioned fan-out is
blind to cross-group siblings\]\[when the same bug CLASS surfaces across
many sessions, stop fixing one-at-a-time and propose a single batch
audit-and-fix sweep as the deliverable\]\[both fixes determined by
ground truth → no gate (Learning 113); adversarial refuters confirm YOUR
fixes, the scan finds the next sibling\]. **Apply:** any session fixing
flagged content/doc bugs whose verification fans out by group — confirm
each flag against the whole sibling set firsthand, and if the bug class
is recurring, recommend a batch sweep instead of serial one-offs.

#### Learning 115 — The batch sweep that Learning 114 proposed paid off: one oracle-grounded audit of all 24 data docs found 10 discrepancies where the serial cadence found ~1-2/session. An accuracy audit also surfaces a 2nd-order class — “data-artifact” bugs (the data itself looks degraded), which is the OWNER’s call, not the auditor’s — and the adversarial pass must BOUND scope (reject non-claims), not just confirm. (S122, owner pick A5 promoted to a full 24-doc audit + fix)

**What happened.** S121’s Learning 114 recommended replacing the
one-bug-at-a-time data-doc cadence (S114–S121) with a single owner-gated
sweep. Owner picked it. I computed authoritative ground truth for all 24
objects once
([`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
direct inspection), then ran a workflow: 5 independent lens scanners
(dims/counts, column-names, types/levels, prose/crossref, free-roam)
over all 24 docs for completeness, then an adversarial refuter per
unique discrepancy. Result: **12 candidates → 10 confirmed, 2
rejected**, fixed in one pass (9 doc edits across 4 objects; checkRd
0×4, NAMESPACE byte-identical, load_all 162, regression 0/0,
rendered-`.Rd` diffs match intent). The serial sessions had been
clearing ~1–2 of these per session; the batch found the whole remaining
set at once. **The recurring-class signal was right — when a bug class
keeps reappearing, the fix is a class-complete sweep, not another single
fix.**

**An accuracy audit surfaces a 2nd-order bug class the auditor must NOT
silently resolve — gate it.** Seven findings were plain “doc-bugs” (the
object is legitimate; the doc is wrong — e.g. `sex` factor levels
`"M","F","U"` vs the live `F,M,H,U`; `ancestry` documented as free-form
character but actually a closed factor; `id`/`qcBreeders` mistyped). But
two were different in KIND: `rhesusPedigree`’s `birth` ships as a
factor-of-strings (not Date) and `exit` as all-NA logical (no dates at
all) — the *data itself* looks degraded by obfuscation, so “make the doc
match the object” would enshrine what may be a data defect. That is the
owner’s decision (document the degraded reality now vs. leave the
aspirational doc and queue a data re-export), not a default the auditor
should pick. I split the deliverable: fixed the 7 unambiguous doc-bugs,
and posed ONE focused gate for the 2 data-artifacts (owner chose
“document actual types now”). **Naming the doc-bug vs data-artifact
distinction is what turns an over-reaching “I rewrote everything to
match” into a faithful audit.**

**The adversarial pass must BOUND scope, not just confirm.** The
refuters didn’t only re-derive and confirm my candidates — they REJECTED
two (`rhesusPedigree` `sire`/`dam`), correctly ruling that those items
make no type claim at all (“the male/female parent … NA for unknown”),
so “correcting” them to say “factor” would invent a fix for a non-bug.
In a fix-audit the skeptic’s job is symmetric: confirm real mismatches
AND veto claimed mismatches that aren’t, so the sweep doesn’t
manufacture churn on accurate-but-untyped prose. Method note: compute
the oracle ground truth ONCE yourself (deterministic, not delegated),
have the fan-out reason over it for completeness + adversarial verify,
and keep R execution with the orchestrator to avoid concurrent-temp-file
races.

**Reflexes:** \[a recurring bug CLASS is best closed by one
oracle-grounded, class-complete sweep — compute ground truth once
yourself, fan out independent lenses for completeness, adversarially
verify each finding\]\[an accuracy audit can surface a 2nd-order class
where the DATA, not the doc, is the suspect — classify doc-bug vs
data-artifact and GATE the data-artifacts (owner’s call); fix the plain
doc-bugs\]\[the adversarial pass must veto non-claims too (reject
“fixing” prose that makes no factual assertion), not only confirm real
mismatches\]\[gate the genuine forks (scope: narrow vs full; how to
treat data-artifacts) but don’t re-gate ground-truth-determined doc
fixes — Learning 113\]. **Apply:** any whole-artifact factual-accuracy
audit — derive the oracle once, fan out for completeness + adversarial
verify, separate “doc is wrong” from “data looks wrong” and gate the
latter, and let the skeptic bound scope on both ends.

------------------------------------------------------------------------

#### Learning 116 — Re-exporting an opaque / non-reproducible bundled data object = COERCE the existing object’s types in place (preserve every value) via a committed `data-raw/` script — never re-derive from source. Investigate provenance + dependents FIRST to prune unsafe options before the scope gate, and keep the .rda + its doc + man/ + tests in ONE deliverable so you don’t reopen the doc-mismatch class. (S123, owner pick A6 — re-export `rhesusPedigree` with corrected column types)

**What happened.** Learning 115’s flagged “data-artifact” (the owner’s
deferred A6) became this session’s deliverable: `rhesusPedigree` shipped
degraded types — `id`/`sire`/`dam`/`birth` as factors, `exit` as all-NA
logical — a `stringsAsFactors`/obfuscation-era artifact. The fix
re-exported the object with canonical types matching `examplePedigree`
(`id`/`sire`/`dam` → character, `birth` → `Date`, `exit` → `Date`
all-NA), preserving **every value** (dim 375×8, all ids, NA patterns,
BRI2MW birth 1998-12-06, date range). Strict TDD: a pre-RED scope gate
(Type-correctness, not full canonical match — no gratuitous `sex`
widening), a pre-RED reproducibility gate (add `data-raw/`), then RED
(31 assertions, confirmed failing) → GREEN (coerce + doc + man regen,
all green) → REFACTOR (N/A; flagged the adjacent redundant test
conversions). Verified: new tests pass, full suite 0/0, checkRd 0,
NAMESPACE byte-identical, 162 exports, and a real runtime smoke test.

**Coerce-in-place, never re-derive, when the generator is
non-reproducible.** A read-only provenance investigation (workflow)
established the `.rda` has NO committed generator: it was obfuscated
from `inst/extdata/rhesusPedigree_fromCenter.csv` via
[`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)
and hand-saved in 2020, never scripted or seeded. Obfuscation is
non-deterministic — re-running it from the CSV would produce DIFFERENT
obfuscated ids/dates than the shipped object (and could desync sibling
objects like `rhesusGenotypes` that share those ids). So the only sound
re-export is to load the existing object and coerce its column TYPES
while leaving VALUES untouched (`as.character`,
`as.Date(as.character(...))`, typed all-NA `Date`). The committed
`data-raw/rhesusPedigree.R` encodes exactly that constraint, is
idempotent, and establishes a reproducibility pattern other opaque
`.rda`s can follow. Lesson: “re-export the data” does not mean
“regenerate from source” — for an opaque/obfuscated artifact it means a
value-preserving type coercion, and the data-raw script’s job is to make
that transform reproducible, not to reinvent the original generation.

**Investigate provenance + dependents BEFORE the scope gate, so the
owner is never offered a foot-gun.** The pre-RED investigation pruned
the option set: “re-derive from CSV” was eliminated by non-determinism,
and “drop the `exit` column” was eliminated because
[`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
reads `ba$exit` (dropping it breaks the object’s main consumer). Both
were plausible-sounding options that an un-investigated gate might have
offered. By verifying firsthand that no test asserts the *current*
factor/logical types (so a fix breaks nothing) and that `exit` is
required, the gate I posed contained only genuinely-safe choices.
Pruning unsafe options before asking is part of right-sizing a gate —
don’t make the owner the safety check on options you could have ruled
out yourself.

**A data re-export and its documentation are ONE deliverable.**
S114–S122 spent eight sessions fixing data-doc mismatches; changing a
data object’s types without updating its `R/data.R` doc + regenerating
`man/` in the SAME session would immediately reopen that exact bug class
(the doc would now describe the old degraded types). So the deliverable
bundled: `.rda` + `data-raw/` + `R/data.R` doc reversal (id
`factor`→`character`, birth/exit → `Date`) + `man/` regen + tests +
`.Rbuildignore`. This is not scope creep — it is the minimum coherent
unit; splitting it would ship a known inconsistency.

**Test value-preservation, not just types; smoke-test the real consumer
on the SHIPPED object.** RED pinned both the corrected types AND
preserved values (dim, NA counts, a known id→date pair, min/max range) —
because a botched coercion can silently lose or reorder data while
satisfying type checks. For Phase 3E, “the suite passes” was necessary
but insufficient: the potential-parents tests do their own
`as.character`/`as.Date` conversions (now no-ops), which could mask a
type that’s still wrong. The conclusive smoke test ran
[`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
on the shipped object **directly, with no conversions** — proving the
corrected types are usable as-shipped.

**Reflexes:** \[re-exporting an opaque/non-reproducible data object =
coerce the existing object’s TYPES in place, preserve all VALUES, via a
committed idempotent `data-raw/` script — never re-derive from source
(non-deterministic obfuscation changes shipped values and desyncs
sibling objects)\]\[investigate provenance + dependents before the scope
gate and PRUNE unsafe options (here: re-derive-from-CSV,
drop-required-column) so the owner only chooses among safe ones\]\[a
data change and its `R/data.R` doc + `man/` regen are ONE deliverable —
splitting them reopens the data-doc-mismatch class (S114–S122)\]\[RED
tests for a type fix must pin VALUE preservation (dim, NA counts, known
id→value pairs, ranges), not only types\]\[Phase 3E for a DATA change =
run the real consumer on the SHIPPED object with no test-harness
conversions — “suite passes” can be masked by now-no-op conversions\].
**Apply:** any task that re-exports / corrects a bundled data object —
check whether a reproducible generator exists (if not, coerce-in-place
via data-raw), investigate dependents to prune unsafe options before
gating, bundle the doc+man+tests with the data change, and
value-preserve in both the tests and a consumer-on-shipped-object smoke
test.

------------------------------------------------------------------------

#### Learning 117 — When re-exporting a SIBLING opaque object on a predecessor’s one-line characterization, re-derive the FULL degradation firsthand — the named symptom (“id still factor”) can be the least consequential of several, and a “cosmetic type fix” can intersect downstream code semantics (factor-indexing) so scope becomes a CORRECTNESS decision, not a cosmetic one. Flag the surfaced code fragility; keep the data change atomic. (S124, owner pick A7 — re-export `rhesusGenotypes` with corrected column types)

**What happened.** S123’s handoff flagged A7 as “de-factor
`rhesusGenotypes$id`→character (id still factor) to match the
convention.” The firsthand investigation found the object ships ALL
THREE columns as factors (`id` 31 levels, `first_name` 18, `second_name`
23), and — crucially — that the `id` type is the one that does NOT
matter (merge coerces it either way; every consumer is id-agnostic,
confirmed independently by the dependents scan), while the two allele
columns being factors silently corrupts `addGenotype`’s output. Its
dictionary lookup `genoDict[genotype[, 2L]]` indexes a name-keyed vector
by a factor, so R uses the factor’s INTEGER CODES instead of its labels,
producing an inconsistent encoding (the same allele gets different codes
in the first vs second column). With character columns the lookup is by
name and the encoding is consistent (verified: same allele → same code =
TRUE for character / FALSE for factor; the combined dictionary is 35
alleles, codes 10001–10035 — vs the buggy per-column-levels ranges
10001–10018 / 10001–10023 under factors). The package’s own
`test_addGenotype.R` feeds `stringsAsFactors = FALSE` input, so the
shipped factor object was the anomaly, not the function’s contract.
Owner chose to coerce all three columns (full type-correctness). Same
coerce-in-place + `data-raw/` + atomic doc/man/test pattern as Learning
116; full suite 0/0, checkRd 0, NAMESPACE byte-identical, idempotent,
and an independent CSV cross-check (all three columns identical to the
shipping `inst/extdata/obfuscated_rhesus_mhc_breeder_genotypes.csv`).

**A predecessor’s one-line characterization is a lead, not a spec —
re-derive the full degradation against the live object.** “id still
factor” was true but framed the task as cosmetic id-only. Probing the
object showed the real degradation was three columns; probing the
*consumer* (`addGenotype`) showed the named column was the irrelevant
one. Had I implemented the literal flag, I’d have shipped a
half-degraded object that still produced inconsistent genotype codes.
Learnings 110/113/114’s “a flag / file-list is a sample” extends to a
predecessor’s scope LABEL: confirm the whole degradation firsthand
before fixing scope.

**A “type cleanup” can be a correctness fix in disguise — check how each
column flows through its consumers before calling it cosmetic.** What
looked like stringsAsFactors hygiene was, for the allele columns, the
difference between a correct and an inconsistent genotype encoding,
because factor-vs-character changes how a value is used as an index (and
as a [`c()`](https://rdrr.io/r/base/c.html) argument) downstream. That
made the scope gate a correctness decision (does the shipped example
produce right codes?), not a style preference — which is exactly why it
warranted the owner’s call rather than a silent default.

**Flag the surfaced code fragility; keep the data change atomic.** The
investigation exposed that `addGenotype` is itself fragile to factor
inputs — it would mis-encode ANY factor-columned genotype, not just the
bundled one. Hardening `addGenotype.R`
(e.g. [`as.character()`](https://rdrr.io/r/base/character.html) on the
allele columns inside the function, or in `checkGenotypeFile`) is a
separate code-fix deliverable with its own tests — flagged for a future
session, NOT bundled (FM \#8). Fixing the data made the shipped example
correct; it did not make the function robust.

**Reflexes:** \[a predecessor’s one-line scope label (“X still factor”)
is a lead — re-derive the FULL degradation firsthand; the named symptom
may be the least consequential column\]\[before calling a type coercion
“cosmetic,” trace how each affected column flows through its consumers —
factor-vs-character changes index/[`c()`](https://rdrr.io/r/base/c.html)
semantics, so a hygiene fix can secretly be a correctness fix\]\[when
the data fix exposes a latent CODE fragility (here: addGenotype
mis-indexing factor allele columns), FLAG it as a separate deliverable —
keep the data re-export atomic (FM \#8)\]\[reuse the Learning 116
pattern: coerce-in-place via idempotent data-raw, bundle doc+man+tests,
value-preserve in tests + an independent cross-check (the shipping
CSV) + a consumer-on-shipped-object smoke test\]. **Apply:** any session
re-exporting a sibling/related opaque data object on a prior session’s
characterization — verify the full set of degraded columns AND how each
flows through consumers before fixing scope; a column the predecessor
named may matter less than one it didn’t.

------------------------------------------------------------------------

#### Learning 118 — When realizing a predecessor’s flagged CODE fix, decide the fix’s HOME by the call graph, not the doc contract — direct callers that bypass the documented “gate” mean the only complete fix lives at the point of use. Coerce at the TOP of the function (not just at the buggy index expression) to also neutralize an adjacent version-fragile path. Drive the RED test from a minimal fixture whose per-column factor codes DIVERGE from the global sort. (S125, owner pick A9 — harden `addGenotype()` against factor allele columns)

**What happened.** S124’s Learning 117 flagged that
[`addGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/addGenotype.md)
is fragile to factor allele columns — `genoDict[genotype[, 2L]]` indexes
a name-keyed integer vector by a factor, so R uses the factor’s INTEGER
CODES not its labels, giving an encoding that is inconsistent between
the two allele columns. S124 deliberately did NOT fix the function (FM
\#8 — kept the data re-export atomic) and pre-named the code fix as A9.
This session realized it. Strict TDD: a pre-RED scope gate
(addGenotype-only vs also-checkGenotypeFile), then RED (two failing
tests, 2 failed / 0 error) → GREEN (2-line coercion; all green) →
REFACTOR (one-line `@details` note + `man/` regen). Verified: full suite
0/0, checkRd 0, NAMESPACE byte-identical, diff confined to three files,
and a Phase-3E smoke on a factor-coerced copy of the real
`rhesusGenotypes` (first/second identical to the character path; max
distinct codes per allele = 1; the 35-allele dictionary 10001–10035).

**The fix’s HOME is decided by the call graph, not the doc contract.**
`addGenotype`’s own roxygen says genotype “is to be provided by
`checkGenotypeFile` so it is not checked” — which reads as an invitation
to harden the upstream gate. A read-only breadth scan refuted that as
the complete answer: `addGenotype` has DIRECT callers that never touch
`checkGenotypeFile` (the roxygen example passing `rhesusGenotypes`,
`test_addGenotype.R`, `test_geneDrop.R`), so a gate-only coercion would
leave every direct caller exposed. The only fix that closes the bug for
all callers is at the point of use, inside `addGenotype`. The breadth
scan also confirmed the bug is isolated (no sibling function indexes a
named vector by a possibly-factor column), so the scope stayed narrow.
Lesson: when a function’s doc says “input is pre-validated upstream,”
verify who actually calls it before locating the fix at the gate — an
unenforced contract is a comment, not a guarantee.

**Coerce at the TOP, not only at the buggy index expression.** The
breadth agent’s suggested patch wrapped just the two index lookups
(`genoDict[as.character(genotype[, 2L])]`). That fixes the lookup, but
the dictionary BUILD a few lines up
(`sort(unique(c(genotype[, name1], genotype[, name2])))`) still relies
on [`c()`](https://rdrr.io/r/base/c.html) combining two factors —
behavior that differs across R versions (pre-4.1
[`c()`](https://rdrr.io/r/base/c.html) dropped factor attributes and
returned integer codes, which would then mis-name the dictionary).
Coercing both columns to character once at the top of the function makes
BOTH the build and the lookup operate on labels, in one place,
version-robustly. When a hardening fix has more than one downstream use
of the unsafe value, normalize at the source rather than patching each
use site.

**A minimal RED fixture for an index-by-factor bug must make the
per-column codes DIVERGE from the global order.** The naive fixture
(both columns the same allele set in sorted order) does NOT reproduce
the bug — each column’s factor codes happen to align with the global
`sort(unique())` positions, so the buggy and correct encodings coincide.
The bug only manifests when a column’s factor level set/order differs
from the global combined order. The minimal trigger:
`first_name = c("a","b")`, `second_name = c("b","c")` — globally
a→10001, b→10002, c→10003, but the per-column factor codes (a,b→1,2 and
b,c→1,2) make allele “b” encode as 10002 in one column and 10001 in the
other. Designing the fixture required tracing the exact index
arithmetic, not just “make it a factor.” Character input is the oracle:
assert the factor-input output is identical to the character-input
output.

**Reflexes:** \[locate a flagged fix by the CALL GRAPH — if direct
callers bypass the documented validation “gate,” the complete fix lives
at the point of use, not the gate (an unenforced “input is pre-checked”
doc is a comment, not a guarantee)\]\[confirm the bug is isolated with a
breadth scan before sizing scope, but verify the scan’s load-bearing
claims firsthand\]\[when an unsafe value has multiple downstream uses,
normalize at the SOURCE (top of the function) — patching only the
obviously-buggy use site can leave an adjacent version-fragile path
(here [`c()`](https://rdrr.io/r/base/c.html)-on-factors in the dict
build)\]\[a RED fixture for an index-by-factor bug must make per-column
codes DIVERGE from the global sort — equal/aligned sets won’t reproduce
it; use character-input output as the oracle\]\[realize a predecessor’s
deferred code-fix flag as its own RED→GREEN→REFACTOR deliverable — do
not bundle it with the data change that surfaced it (FM \#8/#18)\].
**Apply:** any session implementing a fix a prior session
flagged-but-deferred — re-derive the bug firsthand, decide the fix’s
home by who actually calls the function (not its doc), normalize unsafe
inputs at the source, and build the RED fixture to actually reproduce
(for index-by-factor bugs, diverge the per-column codes).

------------------------------------------------------------------------

#### Learning 119 — A data-doc `@source`/provenance citation is NOT an attribute of the live object, so an audit-vs-live-object pass structurally cannot catch it — verify it against the FILESYSTEM (cited file exists AND is value-identical to the object), and drive the RED probe off the GENERATED `man/.Rd` so the failing assertion binds to the rendered artifact (which also proves the regen ran). The phantom-citation class is plural — grep every sibling citation. (S126, owner pick A10 — correct the `rhesusGenotypes` `@source`)

**What happened.** S124/S125 flagged A10: the `rhesusGenotypes` doc
(`R/data.R:345`) cited a source file `rhesusGenotypes.csv` that does not
exist; the real value-identical export is
`inst/extdata/obfuscated_rhesus_mhc_breeder_genotypes.csv`. Strict TDD:
a pre-RED scope gate (filename-swap-only vs +grammar-clarify; owner
chose swap-only) + the three transitions. RED: a probe parsing
`man/rhesusGenotypes.Rd` for its `\emph{}` source token, asserting the
cited file exists in `inst/extdata` + is value-identical to
`rhesusGenotypes`, and that the wrong name is absent from both
`R/data.R` and the man page — 4 failures against the current doc. GREEN:
swap one token, regen `man/` (rd roclet only), 0 failures. Verified:
full suite 0/0, checkRd 0, NAMESPACE byte-identical, diff confined to
two lines. Phase-3E N/A (doc-only). 0 stakeholder corrections.

**A provenance citation needs a different verification target than a
value claim.** The S114–S122 data-doc audits checked doc claims “vs live
objects” — dims, column types, NA counts, spot-checked values — every
one an attribute you can read off the bundled object. A `@source`
filename is NOT such an attribute: nothing in the loaded
`rhesusGenotypes` records where it came from, so a live-object audit
cannot, even in principle, catch a phantom source file. That is exactly
why `rhesusGenotypes.csv` survived nine sessions of data-doc work. The
right check for a provenance citation is against the FILESYSTEM: does
the named file exist under `inst/extdata`, and is it value-identical to
the object? Do not assume a prior “full data-doc audit” covered source
citations — by construction it didn’t.

**Bind the RED probe to the generated artifact, not the source
comment.** The fix lives in a roxygen comment (`R/data.R`), but the
thing the user reads is the generated `man/.Rd`. A probe that parses
`man/rhesusGenotypes.Rd` for the `\emph{}` token and checks the cited
file (a) fails now and (b) passes only after BOTH the roxygen edit AND
the `man/` regen — so it doubles as a regen check, catching the easy
mistake of editing the comment and forgetting to regenerate. Verifying
the rendered artifact is strictly stronger than verifying the source it
is generated from.

**The phantom-citation class is plural — sweep the siblings before
closing out.** A single read-only sweep of every `\emph{...}` citation
in `R/data.R` found the sibling `rhesusPedigree` doc (`R/data.R:358`)
cites `rhesusPedigree.csv`, which also does NOT exist (candidate real
source: `rhesusPedigree_fromCenter.csv` or
`obfuscated_rhesus_mhc_ped.csv`), while `ExamplePedigree.csv` (`:18`)
does exist. Flagged as A11, not fixed (FM \#8 — A10 was the
deliverable). When you fix one instance of a documentation-claim class,
grep the whole class so the next session inherits a precise, pre-located
list instead of rediscovering it.

**Reflexes:** \[a `@source`/provenance citation is NOT a live-object
attribute — verify it against the FILESYSTEM (cited file exists +
value-identical), since an audit-vs-live-object pass cannot catch a
phantom source file\]\[bind the RED probe to the GENERATED `man/.Rd`
(parse the `\emph{}`/source token), not the roxygen source — it then
doubles as a regen check\]\[when fixing one doc-claim instance, sweep
the whole class (grep every sibling citation) and flag the others with
candidate fixes, don’t fix them (FM \#8)\]\[a doc-only `@source` fix is
Phase-3E-N/A — no runtime behavior changes; the proportionate
build-equivalent is checkRd + load_all + suite + NAMESPACE byte-diff +
the man-source probe\]. **Apply:** any data-doc or provenance-citation
fix — verify the cited file on disk (existence + value-identity), drive
RED off the rendered man page, and grep every sibling citation to hand
the next session a located list.

------------------------------------------------------------------------

#### Learning 120 — When more than one shipped file is value-identical to an opaque data object, a filename-based provenance guess can mislead — verify each candidate against the object firsthand and cite the exact-shape value-identical export, not a superset. To close the LAST instance of a doc-claim class, re-run the class sweep after the fix to PROVE closure; don’t inherit “this is the only one left” from a predecessor’s note. (S127, owner pick A11 — correct the `rhesusPedigree` `@source`)

**What happened.** S126 (Learning 119) flagged A11: the `rhesusPedigree`
doc (`R/data.R:358`) cited a phantom `rhesusPedigree.csv`, with two
candidate real sources — `rhesusPedigree_fromCenter.csv` (which the
predecessor and `data-raw/rhesusPedigree.R` both call “the obfuscation
source”) or `obfuscated_rhesus_mhc_ped.csv`. Strict TDD: a pre-RED scope
gate (which file + swap-only vs grammar-clarify; owner chose
`obfuscated_rhesus_mhc_ped.csv`, swap-only) + the three transitions.
RED: a probe parsing `man/rhesusPedigree.Rd` for its `\emph{}` token,
asserting the phantom is absent and the cited file is present (both
`R/data.R` and the man page), exists, and is value-identical — 4
failures (A1–A4) against the current doc, preconditions A5–A6 passing.
GREEN: swap one token, regen `man/` (rd roclet only), 0 failures.
Verified: full suite 0/0, checkRd 0, NAMESPACE byte-identical, diff
confined to two lines. Phase-3E N/A (doc-only). 0 stakeholder
corrections.

**A filename is a hypothesis about provenance, not provenance.** The
name `rhesusPedigree_fromCenter.csv` reads as “the center’s original,
pre-obfuscation pedigree,” and `data-raw/rhesusPedigree.R` even narrates
it as the file the object “was obfuscated from.” Firsthand probing
overturned that: BOTH shipped candidate CSVs carry the SAME obfuscated
ids as the bundled object (BRI2MW, 677E7M, …), so neither is
pre-obfuscation real data — the un-obfuscated source is simply not
shipped (de-identification). `_fromCenter` is a post-obfuscation export
with an extra flag column, not the input. The only reliable way to know
which shipped file the `@source` should name is to compare values
firsthand; the filename, and even a prior provenance comment, can be
loose.

**When two files are both value-identical, cite the exact-shape twin,
not a superset.** `obfuscated_rhesus_mhc_ped.csv` is 375×8 and
value-identical to the object across all 8 columns.
`rhesusPedigree_fromCenter.csv` is value-identical only on the 8
*shared* columns but is 375×9 (extra `fromCenter` column) — a superset.
`@source` should name the file whose shape and values ARE the object,
and it keeps the citation consistent with the sibling genotypes doc
(S126, which cited the exact value-identical export). Cite the minimal
exact match.

**To close the LAST instance of a doc-claim class, prove it — don’t
inherit it.** S126 closed `rhesusGenotypes` and flagged `rhesusPedigree`
as the last sibling phantom. Rather than trust that note, I re-ran the
`\emph{...csv}` sweep over `R/data.R` after the fix: all three citations
(`ExamplePedigree.csv`, `obfuscated_rhesus_mhc_breeder_genotypes.csv`,
`obfuscated_rhesus_mhc_ped.csv`) now resolve to existing files. The
class is closed by demonstration, not by inheritance. A predecessor’s
“this is the only one left” is a lead; a fresh post-fix sweep is the
proof.

**Reflexes:** \[a filename — even one a prior script calls “the source”
— is a HYPOTHESIS about provenance; confirm which shipped file is
value-identical by comparing values firsthand before citing it\]\[when
multiple files are value-identical, cite the exact-shape twin (same
columns), not a superset with extra columns\]\[to close the LAST
instance of a doc-claim class, re-run the class sweep AFTER the fix and
show every member resolves — prove closure, don’t inherit it from a
predecessor’s note\]\[reuse Learning 119: provenance = filesystem
check + value-identity, and the RED probe binds to the generated
`man/.Rd`\]. **Apply:** any provenance/`@source` fix where more than one
candidate file exists — verify value-identity firsthand (don’t trust the
filename or a prior provenance note), cite the minimal exact match, and
re-sweep the class to prove it is fully closed.

------------------------------------------------------------------------

#### Learning 121 — A REFACTOR-only deliverable (delete provably-redundant code) still runs the strict-TDD gate, but with NO RED phase — the existing green suite IS the safety net; you need only a pre-REFACTOR scope gate + the GREEN→REFACTOR gate. Prove “no-op” by whole-frame `identical(with, without)`, not per-column class checks, and sweep the file with a robust single-quoted ERE grep — the handoff’s named line-ranges can be incomplete, and a BRE `\|`/`\$` sweep silently matches nothing on macOS (BSD) grep. (S128, owner pick A8 — remove redundant test no-op conversions)

**What happened.** S123 flagged A8: `test_getPotentialParents.R` and
`test_modPotentialParents.R` re-coerced `rhesusPedigree`-sourced
fixtures’ `id`/`sire`/`dam` to character and `birth` to Date —
conversions that became no-ops once S123 re-exported `rhesusPedigree`
with canonical column types (Learning 116). The deliverable was to
delete them. Strict TDD with no RED: established the GREEN baseline
(both files pass), proved the no-op precondition firsthand, gated the
scope (which blocks) then GREEN→REFACTOR, deleted 12 lines across three
identical-class blocks, and re-verified (both files pass, full suite
0/0, diff confined to the deletions). 0 stakeholder corrections.

**A pure refactor has no RED phase — the existing passing suite is the
test.** TDD’s “never refactor without a test” is already satisfied: the
code being cleaned is itself test code that passes before and must pass
after. There is no new behavior to drive with a failing test, so writing
one would be theater. What DOES apply is the gate sequence: a separate
pre-REFACTOR scope decision (the author’s call) plus the GREEN→REFACTOR
transition gate. Declaring RED here would be a phase-invention error;
skipping the gates would be a discipline error. Correct shape: GREEN
(prove baseline) → scope gate → GREEN→REFACTOR gate → REFACTOR →
re-prove GREEN.

**Prove “no-op” by whole-frame identity, not column class.**
`class(col) == "character"` shows the conversion is *probably* idle; the
airtight proof that removing it preserves behavior is
`identical(frame-after-all-conversions, frame-before)`. That one check
covers every column and attribute at once and generalizes: any fixture
sourced from the same object inherits the proof (here both `pedOne` and
`pedDF` draw from
[`nprcgenekeepr::rhesusPedigree`](https://github.com/rmsharp/nprcgenekeepr/reference/rhesusPedigree.md),
so one identity check licensed deleting all three blocks).

**The handoff’s named line-ranges are a lead, not a census — sweep the
file yourself.** S127’s handoff named two blocks; a robust ERE sweep
found a THIRD identical block in the same file (`pedDF`, lines 116-119)
it never enumerated, plus two look-alikes that were NOT the class (an
`as.Date` inside age arithmetic at `test_fillBins.R:22`; an
`as.character` inside an `expect_setequal` at
`test_modGeneticValue.R:1274`). Leaving the third would have left the
file internally inconsistent. The first sweep used double-quoted BRE
(`as.character(pedOne\$...\|...`) and matched NOTHING — macOS `grep`
(BSD) does not honor `\|` alternation or treat `\$` as intended — the
same shell/backslash trap that drives this project to file-based R
probes (Learnings 108/109), now seen in grep. Fix: single-quoted
`grep -rEn` with a real ERE.

**Reflexes:** \[a delete-redundant-code refactor has NO RED phase — the
existing green suite is the safety net; run only the pre-REFACTOR scope
gate + GREEN→REFACTOR gate, don’t invent a RED probe\]\[prove a
conversion/transform is a true no-op by whole-frame
`identical(with, without)`, not per-column class checks — one identity
check licenses every fixture drawn from that object\]\[treat a handoff’s
named line-ranges as a lead, not a census — sweep the file/dir for the
same class with a single-quoted `grep -rEn` ERE; classify look-alikes
(coercions inside arithmetic/assertions are NOT redundant
self-assignments) and leave them\]\[the shell-backslash trap extends to
grep: double-quoted BRE `\|`/`\$` silently matches nothing on macOS BSD
grep — use single quotes + `-E`\]\[a test-only refactor is Phase-3E-N/A
— no runtime/production code changes; the proportionate build-equivalent
is targeted files green + full suite 0/0 + diff confined to the intended
deletions\]. **Apply:** any “remove now-redundant code” cleanup — prove
the redundancy is a true no-op (whole-frame identity), sweep the
file/dir yourself with a robust ERE grep rather than trusting the
handoff’s line list, and run the scope + GREEN→REFACTOR gates without
inventing a RED phase.

------------------------------------------------------------------------

#### Learning 122 — A carried documentation nit’s wording is a LEAD, not a spec — verify the ground truth before applying it literally; the literal fix can be wrong. A vignette doc-fix binds RED to the `.qmd` source + the live object (not a generated `man/.Rd`), and its build-equivalent is a pkgdown/Quarto render — which writes HTML to the gitignored `pkgdown_site/` but LITTERS the tracked tree (`pkgdown/` favicons, a `*.rmarkdown` intermediate, an auto `vignettes/articles/.gitignore`); clean those before commit. (S129, owner pick A3 — fix the studbook-QC vignette’s `pedGood` column description)

**What happened.** S116 flagged A3 (carried through S117–S128): the
*Studbook Quality Control* article said `pedGood` “has deliberately
messy headers (`ego_id`, `si.re`, `dam_id`, `birth_date`)” — and the
one-line carried framing was “omits the `sex` column.” Strict TDD: a
pre-RED approach gate (rewrite the lead-in vs append a clause; owner
chose the rewrite) + `PRE-RED→RED`, `RED→GREEN`, and `GREEN→REFACTOR`
(N/A — prose, structure preserved). RED: a file-based probe parsing the
lead-in paragraph from the `.qmd` and binding to `names(pedGood)` — 3
ground-truth preconditions pass, 2 RED assertions (lead-in mentions
`sex`; states “five”) fail. GREEN: a 3-line rewrite → 0 failures.
Build-equivalent: `pkgdown::build_article(...)` rendered clean; the new
sentence and the unchanged 4-rename `changedCols` output both verified
in the HTML. 0 stakeholder corrections.

**The literal carried wording would have produced a WRONG fix.** “Omits
the `sex` column” reads as “add `sex` to the parenthetical.” But a probe
on the live object showed `sex` is NOT a messy header: `names(pedGood)`
= `ego_id`, `si.re`, `dam_id`, `sex`, `birth_date`, and the article’s
own `changes` chunk renames exactly the four non-`sex` columns — `sex`
is absent from `changedCols` because it already uses the canonical name.
Inserting `sex` into the “deliberately messy headers” list would have
mislabeled it AND contradicted the chunk’s rendered output two lines
below. The accurate fix conveys “five columns: four messy + an
already-clean `sex`.” The earlier, richer S116 framing (“the dataset is
5 columns”) survived in the notes 350 lines down; the compressed
one-liner that propagated forward lost the nuance. Verify the claim
against the live object before applying it.

**A vignette doc-fix binds RED to the source `.qmd` + the live object —
there is no generated `man/.Rd` to bind to.** Learning 119’s
man-page-binding pattern does not transfer directly: a vignette has no
checked-in generated artifact. The strongest available binding is (a)
ground-truth preconditions read from the live object (`names(pedGood)`),
so the test fails if the data ever diverges from the prose, plus (b) RED
assertions on the source paragraph’s text. The render is the separate
build-equivalent that proves the `.qmd` still compiles and the prose now
matches the chunk output.

**[`pkgdown::build_article`](https://pkgdown.r-lib.org/reference/build_articles.html)
writes to the gitignored output dir but litters the tracked tree — clean
before commit.** The HTML landed in `pkgdown_site/articles/...`
(gitignored, line 39), so it never showed in `git status`. But the same
render created three NEW untracked items in the tracked tree: `pkgdown/`
(generated favicons),
`vignettes/articles/studbook-quality-control.rmarkdown` (a Quarto
intermediate), and `vignettes/articles/.gitignore` (Quarto
auto-created). Capture `git status --porcelain` BEFORE the render, then
`rm -rf pkgdown && rm -f vignettes/articles/.gitignore vignettes/articles/*.rmarkdown`
after, and re-check that the tree is back to the intended set. (Same
family as the stray-`Rplots.pdf` gotcha — a build step can drop
artifacts the commit must exclude.)

**Reflexes:** \[treat a carried/handoff nit’s wording as a HYPOTHESIS —
verify it against the live object before applying it; the literal fix
can be wrong (here, `sex` is not a messy header, so it must not join the
“messy headers” list)\]\[for a vignette/`.qmd` doc-fix, bind RED to the
source paragraph + live-object ground truth
([`names()`](https://rdrr.io/r/base/names.html)), since there is no
generated `man/.Rd`; the pkgdown/Quarto render is the separate
build-equivalent\]\[render the changed article and verify BOTH the new
prose AND that any nearby executed chunk’s output stays consistent with
it\]\[[`pkgdown::build_article`](https://pkgdown.r-lib.org/reference/build_articles.html)/`quarto render`
writes HTML to the gitignored `pkgdown_site/` but litters the tracked
tree (`pkgdown/`, `*.rmarkdown`, an auto `.gitignore`) — snapshot
`git status` before, clean after, re-check\]\[`vignettes/articles/` is
website-only (`.Rbuildignore`d) — no CRAN ship, no NEWS line,
quarto/pkgdown are dev-lib only\]. **Apply:** any documentation/vignette
fix carried as a one-line nit — re-derive the ground truth firsthand,
drive RED off the source + live object, render as the build-equivalent,
and clean the render’s tracked-tree litter before committing.

------------------------------------------------------------------------

#### Learning 123 — To rewrite a large doc section deterministically, write the new section to a FILE and SPLICE it in by heading boundaries with R (read lines, find the start heading + the next heading, recombine head/new/tail) — far more robust than a fragile multi-hundred-line Edit match. For a NEWS rewrite: bind RED to the rendered `NEWS.md`; fold the user-facing delta from the per-session CHANGELOG/handoffs (DROP internal/test/VCS sessions); then adversarially verify completeness (vs `git show HEAD:NEWS.md` + the plan’s classification), accuracy (every named function exists/exported), and dedup/style BEFORE tightening prose. `rmarkdown::render(output_format="github_document")` drops an untracked `NEWS.html` preview — clean it before commit. (S130, owner pick B — CRAN Phase 3a, the NEWS 2.0.0 rewrite)

**What happened.** The CRAN plan’s Phase 3 headline was to rewrite the
single verbose, internally-doubled `1.1.0.9000` NEWS section into a
terse `# nprcgenekeepr 2.0.0` Major/Minor entry and fold in the
S112–S129 user-facing changes. The plan (line 154) authorized splitting
content-rewrite from version-bump+regenerate; the owner chose the split,
so this session delivered only the NEWS rewrite + re-render (Phase 3a).
Strict TDD: scope gate (full vs split) + the three transitions. RED: a
probe bound to the rendered `NEWS.md` (one 2.0.0 heading; 1.1.0.9000
gone; Major+Minor; no NEW-/PED-/XARCH-; `addGenotype` + rhesus data
folded in; module mechanics dropped) — 6 fail → 0 after rewrite+render.
A 3-lens adversarial workflow (completeness/accuracy/dedup-style)
returned 0 completeness, 0 accuracy, 0 dedup findings and 6 style nits;
the REFACTOR tighten resolved them with the probe staying 7/7. 0
stakeholder corrections.

**Splice by heading boundary, do not Edit-match hundreds of lines.** The
old section spanned 178 lines. An `Edit` requires the entire
`old_string` to match byte-for-byte — fragile and error-prone at that
size. Instead: `Write` the new section to a scratch file, then an R
splice —
`x <- readLines("NEWS.Rmd"); v <- grep("^# nprcgenekeepr 1\\.1\\.0\\.9000", x); w <- grep("^# nprcgenekeepr 1\\.0\\.8 ", x); writeLines(c(x[seq_len(v-1)], readLines(newfile), "", x[w:length(x)]), "NEWS.Rmd")`.
Deterministic, keys only on stable heading anchors, and leaves all prior
history untouched. The REFACTOR re-splice keyed on the new `2.0.0`
heading the same way. (This is the document-section cousin of the
dry-run-first R-script edits used for the roxygen sweeps in S114/S116.)

**Fold the user-facing delta from the per-session CHANGELOG, classifying
ship-vs-internal.** The plan’s §6.3 classification predated S112–S129,
so the recent sessions had to be folded in. The per-session CHANGELOG
entries are the source: the ship/user-facing ones (S123/S124 data-type
re-exports; S125 `addGenotype` behavior) became their own Minor bullets,
and the many shipped help/data-doc corrections
(S112/S114–S117/S120–S122/S126/S127) collapsed into ONE omnibus
“Documentation” Minor bullet rather than 12 lines. The non-shipping
sessions — S113 (roxygen tooling), S118/S119 (PR/VCS), S128
(test-fixture cleanup), S129 (website-only article) — were correctly
DROPPED. Each handoff’s own `[news-vs-changelog]` note (“this ships →
fold into NEWS” vs “website-only → no NEWS line”) is the classification
signal; trust it but confirm against what the change actually touches.

**Bind RED to the rendered artifact, and adversarially verify a
user-facing release artifact before polishing.** As with the man-page
doc fixes (Learning 119), the probe binds to the GENERATED `NEWS.md`
(not just `NEWS.Rmd`), so it also proves the re-render ran. For a
CRAN-facing release note, a 3-lens workflow earned its keep:
completeness compared the draft against the OLD content
(`git show HEAD:NEWS.md`), the plan’s Major/Minor lists, AND the
CHANGELOG delta; accuracy grepped `NAMESPACE`/`R/` to confirm every
named function exists and is exported and cross-checked each behavior
claim; dedup/style checked the house convention. Run the verify BEFORE
the style-tighten so the tighten can’t silently drop a fact — then a
token-presence sweep confirms it did not.

**`github_document` render litters `NEWS.html`.**
`rmarkdown::render(output_format = "github_document")` has
`html_preview = TRUE` by default, which drops an untracked `NEWS.html`
next to `NEWS.md` (the shipped artifact). `NEWS.html` is not gitignored
— remove it before commit (or render with `html_preview = FALSE`). Same
family as the `pkgdown` render litter (Learning 122) and the stray
`Rplots.pdf`: a build step can emit artifacts the commit must exclude —
snapshot `git status` before, clean after.

**Reflexes:** \[to replace a large contiguous doc region, Write the
replacement to a file and splice by stable heading anchors in R — never
hand-match hundreds of lines in one Edit\]\[fold a NEWS/changelog delta
from the per-session CHANGELOG, using each handoff’s news-vs-changelog
note to classify ship-vs-internal; collapse many small shipped doc fixes
into one omnibus bullet\]\[bind the RED probe to the rendered `NEWS.md`
so it also proves the re-render ran\]\[adversarially verify a
user-facing release artifact (completeness vs `git show HEAD:` + plan +
CHANGELOG; accuracy vs `NAMESPACE`/`R/`; dedup/style) BEFORE tightening
prose, then token-sweep to confirm the tighten dropped no
fact\]\[`rmarkdown::render(github_document)` drops an untracked
`NEWS.html` preview — clean it before commit\]. **Apply:** any large
documentation-section rewrite, especially a NEWS/release-notes rewrite —
splice deterministically, fold the delta from per-session history,
RED-bind to the rendered file, adversarially verify, then tighten and
clean render litter.

------------------------------------------------------------------------

#### Learning 124 — For a version bump / metadata change with NO new behavior, do strict TDD by binding RED to the *version-consistency invariant* (every version-bearing artifact == target; stale strings absent), not to a function’s behavior. Re-render generated docs with `rmarkdown::render(output_format = <fmt>(html_preview = FALSE))` to avoid the HTML-preview litter outright (improves on Learning 123’s clean-up-after). `getVersion()` tracks DESCRIPTION under `load_all`, so re-rendering README auto-updates its version line; its *date* is `sessioninfo`-derived (provisional, not literal-today). A version *retitle* in one file leaves *dangling cross-references* in other docs — sweep for them. (S131, owner pick B-cont — CRAN Phase 3b, the 2.0.0 version bump)

**What happened.** CRAN plan Phase 3 was split (Learning 123): S130 did
the NEWS rewrite (Phase 3a), leaving the version bump as Phase 3b. The
deliverable was purely mechanical — `DESCRIPTION:4` Version `1.1.0.9000`
→ `2.0.0`, re-render `README.md`, `CITATION.cff` version `1.0.7` (stale)
→ `2.0.0` + a `date-released` field — and the two version-dependent
tests (`test_getVersion.R`, `test_appUI_version.R`) are both *dynamic*
(they read
[`packageVersion()`](https://rdrr.io/r/utils/packageDescription.html)),
so the bump does not make any existing test go red-then-green. There was
no new behavior. Strict TDD still applied: two pre-RED scope gates
(version-consistency only; defer the carried NEWS Minor→Major
promotion) + the three transitions, `GREEN→REFACTOR` declared N/A. Full
suite stayed 191 files / 0-0. 0 stakeholder corrections.

**The RED surface for a no-new-behavior change is an invariant, not a
behavior.** When the deliverable changes configuration/metadata rather
than logic, bind RED to the *property the change must establish*. Here
that property is the version-string inventory being consistent: a
file-based probe parsed `DESCRIPTION`
(`read.dcf(..., fields="Version")`), `CITATION.cff` (the `version:`
line), and `README.md` (the rendered version line) and asserted all
three equal the target and that the stale strings (`1.1.0.9000`,
`1.0.7`) are gone, plus a `date-released` field exists — 7 assertions,
all failing on the current tree, all passing after the edits +
re-render. This is the metadata-bump analog of binding RED to a rendered
`NEWS.md` (Learning 123) or a generated `man/.Rd` (Learning 119): the
probe verifies the *deliverable’s invariant*, and the existing dynamic
tests verify the *runtime path* (the
[`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
About-tab render = Phase 3E). The probe is transient (removed before
commit); no permanent test is added unless the owner asks (offered,
declined).

**`html_preview = FALSE` beats clean-up-after.** Learning 122/123 note
that `rmarkdown::render(github_document)` drops an untracked
`NEWS.html`/preview that must be cleaned. Passing
`output_format = rmarkdown::github_document(html_preview = FALSE)`
suppresses it at the source — the render produced *only* the intended
`README.md` change, no litter to remove. Prefer this over
snapshot-and-clean when re-rendering a github_document.

**[`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)
tracks DESCRIPTION under `load_all`; the README date is
`sessioninfo`-derived.** `README.Rmd:10` calls
[`nprcgenekeepr::getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md),
and under
[`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)
`packageVersion("nprcgenekeepr")` returns the *dev DESCRIPTION* version
— so editing DESCRIPTION then re-rendering README auto-updates the
version line; README.Rmd needs NO edit (it is on the §3.1 “NO edit —
auto-tracks” list, like the `appUI` About panel). But
[`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)’s
date comes from
[`sessioninfo::package_info()`](https://sessioninfo.r-lib.org/reference/package_info.html),
which for a source package is an environment-derived date (here
`2026-06-17`, not the literal today `2026-06-18`) — so the README date
can differ from a hand-set `date-released`. Both are provisional and
reconfirmed at the actual submission (Phase 5); do not force them to
match.

**A version retitle leaves dangling pointers.** S130 retitled the NEWS
`1.1.0.9000` section to `2.0.0`; a closing sweep for the old version
string found `ROADMAP.md:6` still says “see `NEWS.md` 1.1.0.9000” — now
a *dangling* cross-reference to a section that no longer exists. Also
`CLAUDE.md:18` carries stale “(Version 1.1.0.9000)” prose and
`nprcgenekeepr_notes.txt:5` a now-resolved TODO. These are
`.Rbuildignore`d dev docs (not CRAN artifacts) and out of a locked
three-file scope — flagged for follow-up, not fixed mid-session (FM
\#8). The lesson: after any version *rename* (not just a numeric bump),
grep the whole tree for the old string and triage hits into bumpable /
historical-keep / dangling-pointer.

**Reflexes:** \[for a config/metadata change with no new behavior, bind
RED to the change’s invariant (version-string inventory consistent;
stale strings absent), not to a function’s behavior — the metadata-bump
cousin of RED-binding to a rendered artifact\]\[verify the plan’s
version-string inventory (§3.1) against the live tree with a `git grep`
before editing, and split hits into bumpable vs historical-must-not-bump
vs dangling-pointer\]\[re-render a github_document with
`html_preview = FALSE` to avoid the preview litter
outright\]\[[`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)/[`packageVersion()`](https://rdrr.io/r/utils/packageDescription.html)
track DESCRIPTION under `load_all`, so re-rendering README auto-updates
its version line — README.Rmd needs no edit; its date is
`sessioninfo`-derived and provisional\]\[after a version *retitle*,
sweep the whole tree for the old string — a rename leaves dangling
cross-references in dev docs\]. **Apply:** any version bump or
metadata-only change — drive RED off the consistency invariant, verify
the inventory against the tree, re-render with `html_preview=FALSE`, and
triage every lingering old-version hit.

------------------------------------------------------------------------

#### Learning 125 — When a plan marks a phase “open,” a prior session may have already executed it — verify against process history (`git log` on the phase’s target files + the CHANGELOG + the handoff chain) BEFORE re-running; a stale status propagates through many handoffs unreconciled. And a string fixed only at its canonical source can survive in its DOWNSTREAM SINKS — a generated file, a child-include rendered into multiple places, and a hand-maintained mirror — so sweep the whole tree and scope the invariant probe to git-TRACKED files (an unscoped sweep flags untracked render litter as false offenders). (S132, owner pick B-Phase1 re-scoped — finish the `mulatto`→`mulatta` typo across README/vignette/CITATION)

**What happened.** The owner picked “CRAN Phase 1 static hygiene.”
Orientation’s process-history check (memory
\[\[check-process-history-before-rerunning-work\]\]) found **Phase 1 was
already executed by S102** (commit `a3cf3623`) — the `.Rbuildignore`
cruft lines, the DESCRIPTION `mulatto`→`mulatta` typo, the renv
`Config/*` reordering, `VignetteBuilder: knitr`, the `@return`/`\value`
docs, and the LICENSE-year reconcile — all verified in place against the
live tree. Yet the plan (authored S101) was never marked done, and the
handoff chain S102→…→S131 carried “Phase 1 … still open” forward; S131’s
gotcha even named `DESCRIPTION:23` as still carrying the typo, which
S102 had fixed. A tree-wide `mulatto` sweep then showed S102 fixed the
typo **only in DESCRIPTION**: it survived in `README.Rmd:48` (→ shipped
`README.md`, twice), the shipped vignette child
`vignettes/manual_components/_introduction.Rmd:48`, and
`CITATION.cff:16`. Re-scoped with the owner to finishing the typo
tree-wide; strict TDD throughout (3 transition gates + a pre-RED scope
gate; REFACTOR N/A); RED probe 9 failures → 0; full suite 0/0; 0
stakeholder corrections.

**A plan’s phase *status* is a claim, not ground truth — verify it
against process history before executing.** SESSION_RUNNER’s planning
discipline says a plan’s “files to change” come from search results, not
architectural memory; the dual at *execution* time is that a plan’s
*completion* status comes from the commit record, not the plan’s own
text. Before re-running any phase a plan calls “open,”
`git log --oneline -- <the phase's target files>`, `grep` the CHANGELOG,
and scan the handoff chain for evidence it is already done. Here two
commands (`git log -- .Rbuildignore DESCRIPTION` →
`a3cf3623 … CRAN Phase 1 static hygiene (S102)`, and
`grep -ni 'phase 1' CHANGELOG.md`) proved Phase 1 was complete and saved
the session from re-doing settled work. A stale status propagates:
S101’s plan said open, S102 did the work without marking the plan done,
and every handoff since copied “Phase 1 open” forward. The fix is
twofold — verify before executing, AND reconcile the artifacts (the
plan + CHANGELOG) when you find the drift, so the next session inherits
truth instead of re-discovering it.

**A fix at the canonical source can survive in its downstream sinks.**
S102 corrected the typo in DESCRIPTION (the canonical Description field)
and reasonably treated it as handled. But the same species name lives in
**five** independent sinks: (1) a hand-maintained *mirror* —
`CITATION.cff`’s abstract duplicates the Description prose (cffr would
regenerate it from DESCRIPTION, but cffr is absent, so it drifted); (2)
a *generated* file — `README.md` is knit from `README.Rmd`; (3) a
*child-include* — `README.Rmd` states the reference directly (line 48)
AND `child`-includes `_introduction.Rmd` (line 32), which carries the
same block, so the typo renders into README.md *twice*; (4) that same
child ships into the `a3manual.Rmd` vignette; (5) a *website-config
mirror* — `_pkgdown.yml`’s `description:` field also copies the
Description prose, so the typo would appear on the published pkgdown
site. The plan’s own location list (“DESCRIPTION:23 + CITATION.cff:15”)
missed the README, vignette, AND `_pkgdown.yml` sinks. Lesson: when
fixing a string that appears in user-facing prose, sweep the *whole
tree* for it and trace generation/include/mirror chains — fixing the
source is not fixing the output.

**Scope a tree-wide invariant probe to git-tracked files — but ALL of
them, not a curated dir list.** Two opposite scoping errors bit this
session and both were caught. (a) *Too broad:* the RED probe’s first
sweep flagged untracked, git-ignored local render litter
(`vignettes/a3manual.html|md`, stale builds) as offenders; filtering to
`git ls-files` fixed it — the invariant is about *committed/shipped*
content, not the working tree. (b) *Too narrow:* I then scoped the sweep
to a hand-picked dir list (`R/`/`man/`/`vignettes/` + `README.md` +
`DESCRIPTION`) — which **missed `_pkgdown.yml`**, the fifth sink. The
miss was caught only by a close-out belt-and-suspenders
`git ls-files | grep mulatto` over **all** tracked files. The lesson: a
curated dir list embeds the same blind spot that let the typo survive in
the first place. Sweep **every** tracked file (`git ls-files`), and
*subtract* only the dev-process-history docs that legitimately
*describe* the fix (CHANGELOG, SESSION_NOTES, PROJECT_LEARNINGS,
`docs/planning/*`, dev notes) — don’t *add back* a curated content
subset.

**Reflexes:** \[before re-running any phase a plan calls “open,” verify
against process history — `git log --oneline -- <phase target files>`,
`grep` the CHANGELOG, scan the handoff chain — a stale status propagates
through many handoffs unreconciled\]\[when you find plan/CHANGELOG
drift, reconcile the artifacts (mark the phase done; correct the false
status transparently) so the next session inherits truth, don’t just
route around it\]\[a typo/string fixed at its canonical source can
survive in downstream sinks — a generated file, a child-include rendered
into multiple places, a hand-maintained mirror, a website-config copy —
sweep the whole tree and trace generation/include/mirror chains\]\[scope
a tree-wide invariant sweep to `git ls-files` (excludes git-ignored
render litter) but over ALL tracked files minus only the fix-describing
dev docs — a curated dir list re-creates the original blind spot; always
run a close-out `git ls-files | grep` belt-and-suspenders pass\].
**Apply:** any “resume the plan / do Phase N” pickup (verify N isn’t
already done before executing) and any single-location content/typo fix
(sweep ALL tracked files, subtract only the fix-describing docs, run the
close-out grep).

#### Learning 126 — A plan’s named root cause is a *hypothesis*: measure before fixing. The documented cause (“timing”) may not reproduce in the current tree, and the profile may instead surface a *different* real defect the owner re-scopes to. Verify a handoff’s environment/feasibility claim firsthand (the “Phase 2 blocked — devtools/renv absent” premise was stale; base-R `R CMD build`/`check --as-cran` need no devtools). Don’t invent a fix where the measurement shows no problem. And encode a check’s invariant with the tool’s OWN mechanism (R’s parser `SYMBOL_PACKAGE` tokens for `pkg::`), not a fragile text regex. (S133, owner pick B-Phase2 re-scoped — CRAN Phase 2 archival timing root cause)

**What happened.** The owner picked “CRAN Phase 2 — archival timing root
cause.” The plan named example/test/vignette elapsed time as the cause
and listed the gene-drop vignettes + LabKey examples as “prime
suspects,” but it also (dragon \#1) said *measure first; let the profile
name the offender*. Profiling — an authoritative
`R CMD check --as-cran --timings` — showed the timing defect **does not
reproduce** in the 2.0.0 tree: examples 20s, vignettes 16s, slowest
example `countLoops` 1.43s, zero examples ≥ 5s; the “prime suspect”
gene-drop vignettes rebuild in 16s total (cheap on the tiny `smallPed`).
What the profile *did* expose was a different, genuinely CRAN-blocking
finding: `Status: 1 WARNING` for an undeclared `withr` test dependency.
Per the plan’s STOP-and-re-scope rule, the owner re-scoped the session
to fixing that (one `Suggests` line, strict TDD); the re-run `--as-cran`
dropped to 0 ERROR / 0 WARNING. 0 stakeholder corrections.

**A phase’s *premise* is a claim too — measure it before executing, just
as you verify a phase’s *status* (Learning 125).** Learning 125 said a
plan’s open/done status is a claim to verify against process history.
Its sibling at execution time: a plan’s named *root cause* is a
hypothesis to verify against a measurement. A plan that says “fix
timing” can be wrong about *whether timing is still broken* — the
archived defect was at 1.0.7/1.0.8, and the post-1.0.8 work (or merely
faster hardware here) may have resolved it. The plan anticipated exactly
this (dragon \#1, “let the profile name the offender”) and gave a
STOP-and-re-scope boundary; honoring it — running the gold-standard
measurement and surfacing the changed premise to the owner with a
grounded re-scope question — is what kept the session from inventing a
timing “fix” for a non-problem.

**Verify a handoff’s environment/feasibility claim firsthand before
accepting a “blocked.”** Both the S131 and S132 handoffs said Phase 2
was “blocked here — needs devtools +
[`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html),
absent in this env.” A 20-line env probe disproved it: R 4.6.0 with the
renv library already materialized, all 18 Imports present, pandoc
present — and crucially `R CMD build`/`R CMD check --as-cran` are
*base-R binaries* that need no devtools. The only real gap was a couple
of missing build-only Suggests (`markdown` for a vignette; installed in
seconds). A “blocked” inherited from a handoff is a hypothesis, not a
fact — the cost to test it (one probe script) is far below the cost of
deferring a runnable, critical-path phase.

**Don’t invent a fix where the measurement shows no problem.** The plan
offered timing mechanisms (`\donttest`, `skip_on_cran()`, reduce
iterations). With the profile showing no unit near the limit, applying
them would *solve a non-problem* — and reducing simulation iterations
risks dragon \#2 (a “speed-up” that silently changes GVA/kinship
numbers). The disciplined output when the measurement is clean is to
*say so with evidence and stop*, not to perform the plan’s listed
actions for their own sake. (The owner was offered a “+guard the
heaviest examples as machine-speed insurance” option and declined it;
honest framing flagged it as belt-and-suspenders that slightly reduces
CRAN example coverage.)

**Encode a check’s invariant with the tool’s own mechanism, not a
hand-rolled text scan.** The RED probe had to mirror `R CMD check`’s
“unstated dependencies in tests” check. A first-draft regex over raw
test text false-flagged two non-deps: `devtools` (appears only in `#'`
comments) and `shinytest2.R` (a filename in a comment). `R CMD check`
ignores both because it parses *code*. Rewriting the probe to use
`getParseData(parse(f))` and collect `SYMBOL_PACKAGE` tokens — exactly
what the parser resolves the package half of `pkg::` to — made it
comment/string/filename-immune and yielded precisely the one real
offender (`withr`), matching the check. When a probe must reproduce a
tool’s code-level judgment, reach for the tool’s own parser/AST, not a
regex approximation of it.

**Reflexes:** \[a plan’s named root cause is a hypothesis — run the
gold-standard measurement (here `R CMD check --as-cran --timings`)
BEFORE applying the plan’s fix; the documented cause may not
reproduce\]\[honor a plan’s STOP-and-re-scope boundary: when the profile
contradicts the premise, surface it to the owner with evidence + a
grounded re-scope question — don’t barrel into the listed fix or
silently narrow\]\[verify a handoff’s “blocked / tool absent” claim
firsthand with a quick env probe — base-R
`R CMD build`/`check --as-cran` need no devtools; renv may already be
materialized\]\[when the measurement is clean, say so with evidence and
STOP — don’t apply timing fixes to units that aren’t slow (non-problem +
dragon \#2 risk)\]\[to reproduce a tool’s code-level judgment in a
probe, use the tool’s own parser (`getParseData`/`SYMBOL_PACKAGE`), not
a text regex that scans comments/strings\]. **Apply:** any “fix \[named
root cause\]” pickup (measure that the cause reproduces first) and any
probe that must mirror an `R CMD check` finding (parse, don’t regex).

#### Learning 127 — Verify a spell-flagged word before adding it to WORDLIST: a “misspelling” can be the *symptom of a real defect*, and adding it masks the defect. A dictionary the plan calls “nearly clean” can be far off — reconcile against the live tool output, not the plan’s guess. And `R CMD check --as-cran` is a base-R gate that needs no devtools wrappers; for a *true* gate, install the missing Suggests so nothing is skipped. (S134, owner pick A — CRAN Phase 4 full `--as-cran` gate)

**What happened.** Phase 4’s gate came back clean on the first run —
`Status: 2 NOTEs` = 0 ERROR / 0 WARNING (NOTE 1 = expected
archived/new-submission incoming-feasibility; NOTE 2 = local-only
old-HTML-Tidy/no-V8, CRAN-absent), timings all comfortable, regression
read 0 failed / 0 error. The interesting work was the `inst/WORDLIST`
reconciliation the plan listed almost as an afterthought (“confirm only
EHR/Raboin/kinships remain after the `mulatta` fix”). Reality:
[`spelling::spell_check_package()`](https://docs.ropensci.org/spelling//reference/spell_check_package.html)
flagged **37** words — the dictionary had drifted ~35 legitimate code
identifiers behind the S100–S133 work (`changedCols`, `femaleSires`,
`qcResult`, …) — i.e. the plan’s stated expectation was wrong by an
order of magnitude. Verifying each flagged word against its source
location (not blindly running `update_wordlist()`) paid off twice: it
isolated a curly-quote tokenizer artifact (`names'` from the quoted
base-R error `'row.names'` in NEWS — a faithful quote, not a word) and,
more importantly, surfaced a **real data defect**.

**A spell flag can be the visible symptom of a defect that has nothing
to do with spelling.** The flagged token `si` traced to a column
literally named **`si.re`** in 5 of the 6 example pedigree datasets
(`pedGood`, `pedDuplicateIds`, `pedFemaleSireMaleDam`,
`pedMissingBirth`, `pedSameMaleIsSireAndDam`); the 6th
(`pedInvalidDates`) correctly uses `sire`. `si.re` is almost certainly a
data defect (should be `sire`/`sire_id`, to pair with `ego_id`/`dam_id`)
— `spell_check` split it on the period and flagged the `si` fragment.
Had I run `update_wordlist()` (which adds *all* flagged words), `si`
would have been enshrined in the dictionary and the defect masked
forever. Instead I added the 35 clean terms and **deliberately left `si`
flagged** so it stays visible, then documented the `si.re` finding for
its own session. Lesson: before adding a flagged word to a project
dictionary, look at where it occurs — if it’s a fragment of a malformed
identifier, the right fix is upstream, not the WORDLIST.

**The owner-approved scope can be refined by what verification reveals —
transparently, and more conservatively.** The owner approved “add the 36
legitimate terms” before I’d traced `si` to `si.re`. Discovering `si`
was a defect symptom, I narrowed to 35 (excluding both `names'` and
`si`) — *more* conservative than approved, serving the same stated
intent (“don’t enshrine artifacts”), and reported the deviation
explicitly so the owner could redirect. New information that post-dates
an approval should refine the action toward the approval’s intent, with
the change surfaced — not silently, and not by rigidly executing the
now-outdated literal instruction.

**A “true” `--as-cran` gate installs the Suggests; the forced check is a
weaker proxy.** S133’s check used `_R_CHECK_FORCE_SUGGESTS_=false`
because `covr`/`shinytest2`/`shinyWidgets`/`spelling` were absent (a
real but partial gate). S134 installed all four (+ `urlchecker`) into
the renv library — installing the *package* `shinytest2` does **not**
install Chrome (chromote fetches it lazily, and the e2e tests
`skip_on_cran` so the check never launches a browser), so it was safe —
and ran with no forcing flag, the condition CRAN itself checks under.
Pre-gate hygiene that the single `R CMD check` subsumes anyway is still
worth running explicitly for the captured evidence: `roxygenise()` (zero
diff → docs in sync), `urlchecker::url_check()` (17/17 correct),
`spell_check_package()` (the WORDLIST reconcile). WORDLIST is
*gate-invariant* (consumed only by the `skip_on_cran`
`tests/spelling.R`), so changing it cannot alter the check result —
confirmed by a second rebuild+recheck (identical `2 NOTEs`).

**Reflexes:** \[before adding a spell-flagged word to `inst/WORDLIST`,
read its source location — a fragment of a malformed identifier (`si` ←
`si.re`) is a defect symptom; `update_wordlist()` would mask it, so add
the clean terms by hand and leave the symptom flagged\]\[treat a plan’s
“the dictionary should be nearly clean” as a guess — reconcile against
the live `spell_check_package()` output; drift accumulates silently as
code adds identifiers\]\[installing the R package `shinytest2` does not
install Chrome — safe to add for a true `--as-cran` gate when the e2e
tests `skip_on_cran`; install the missing Suggests rather than
`_R_CHECK_FORCE_SUGGESTS_=false`\]\[WORDLIST is gate-invariant (only the
`skip_on_cran` spell test reads it) — don’t re-run the full check “to be
safe” on a WORDLIST-only change unless the session is itself the
submission gate\]\[the HTML-manual NOTE (`'tidy' not recent enough` /
`package 'V8' unavailable`) is a local-toolchain artifact, CRAN-absent —
document it, don’t chase it\]. **Apply:** any WORDLIST/spell
reconciliation (verify each word’s source before adding) and any local
`--as-cran` gate (install Suggests for a true gate; know which NOTEs are
CRAN-absent).

#### Learning 128 — A guessed future identifier (a PR number, a branch name, a “next” version) is a claim that propagates through handoffs unverified — confirm branch/PR/remote state firsthand (`gh pr view N`, `gh pr list --state all`, `git show origin/<branch>:DESCRIPTION`, `git merge-base --is-ancestor`) before citing it in a runbook or handoff. And adversarially verify an external-facing submission document (a CRAN cover note) with a skeptical fresh-eyes pass — the author, close to the work, misses implied-passes framing, “delete-before-pasting” foot-guns, and over-scoped quantitative claims. (S135, owner pick B-Phase5 scope A — CRAN Phase 5 cover note + runbook)

**What happened.** Phase 5’s local half (rewrite `cran-comments.md`;
write the win-builder/R-hub runbook) was authored from verified repo
facts, then run through a 3-lens adversarial verification (repo
fact-check + runbook-command/API + skeptical-CRAN-reviewer). Every
*factual* claim in the cover note confirmed against the tree, but the
pass caught three classes of author-blind defect — and one was a
long-propagated false premise.

**A guessed identifier rides the handoff chain as if it were a fact.**
Every handoff since ~S112 said the branch “rides a future **PR \#53**
(Learning 112).” It does not: `gh pr view 53` → “Could not resolve to a
PullRequest,” because GitHub shares one number space between issues and
PRs and issues \#45/#46 consumed that range — the next PR will be some
later number, not 53. Worse, `gh pr list --state all` showed **PR \#52
is already merged** but carried only S101-S117, and
`git show origin/master:DESCRIPTION` is still `Version: 1.1.0.9000` with
`git merge-base --is-ancestor e24a53a2 origin/master` = NO — so `master`
has **none** of the 2.0.0 commits. The runbook’s first draft repeated
the “PR \#53 / merge to master” framing and miscast the branch risk as
“an older tree, not 2.0.0” when `origin/add-methodology` is in fact
already 2.0.0 but missing S133’s `withr` fix (so R-hub on the unpushed
tree would re-report the WARNING win-builder won’t). Lesson: a future PR
number, a “rides PR \#N” note, or “merge to master” is a *prediction*;
verify it against `gh`/`git` the moment you depend on it, and never let
a guessed number sit in a handoff as settled fact (Learning 125/126 —
verify inherited status/premises — applied to repository plumbing).

**Adversarially verify the external-facing artifact, not just the
code.** A CRAN cover note is read by a skeptical human reviewer; its
failure modes are rhetorical, not compilable, so the build-equivalent
(it’s valid markdown) tells you nothing. The reviewer-lens agent caught
what I, close to the draft, did not: (1) listing win-builder/R-hub under
“## Test environments” with no results reads as *implied passes* for a
twice-archived package — fixed by explicit “to be run before submission”
markers; (2) a “NOTE TO MAINTAINER (delete before pasting)” block with
placeholder result numbers *inside the file pasted to CRAN* is a
foot-gun (if left in, you ship fake numbers + an internal path) — moved
entirely into the runbook so the cover note is CRAN-facing-only; (3)
“3-5x headroom” is true per-example (~1.4s vs ~5s) but false per-phase
(the tests phase ~43s is ~1.4x under a minute) — scoped the claim; (4)
wording that implies a deliberate timing *fix* when the measured truth
is “the cause does not reproduce” overclaims for a timing-archived
package — reworded to state what’s true and point at win-builder/R-hub
(independent, slower hardware) as the confirming evidence. None were
factual errors; all were framing/honesty risks a fresh adversarial
reader surfaces and the author misses.

**Reflexes:** \[before citing a PR number / “merge to master” / “rides
PR \#N” in a runbook or handoff, run `gh pr view N` and
`gh pr list --state all`, and check the target branch’s real version
with `git show origin/<branch>:DESCRIPTION` +
`git merge-base --is-ancestor <commit> origin/<branch>`\]\[a guessed
future PR number is unreliable — GitHub shares the issue/PR number
space, so intervening issues shift it; don’t enshrine a specific number
in a handoff\]\[R-hub v2 checks the pushed GitHub tree, win-builder
uploads the local tarball — if the local branch is ahead, push before
`rhub_check()` or R-hub re-reports already-fixed problems\]\[keep a CRAN
cover note CRAN-facing-only: no “delete-before-pasting” blocks, no
placeholder numbers, no internal paths — stage those in the
runbook\]\[never list a test platform under “Test environments” without
a result or an explicit “pending” marker — for an archived package it
reads as an implied pass\]\[scope a quantitative headroom/limit claim to
the unit it actually holds for (per-example vs per-phase); don’t imply a
deliberate fix the measurement shows was never needed\]. **Apply:** any
runbook/handoff referencing branch/PR/remote state (verify firsthand),
and any external-facing submission/correspondence document (run a
skeptical fresh-eyes adversarial pass before it ships).

#### Learning 129 — A firsthand-verified remote-state claim still has a shelf life: a branch can be pushed or changed between sessions, so a prior session’s *correct* “push first / N commits behind” snapshot can be stale by the time you act on it. `git status` “up to date with origin/” compares only against the LOCAL tracking ref, which updates **only on fetch** — so it reads “up to date” both when you already pushed and when your view of the remote is merely stale. Run `git fetch` THEN `git rev-list --left-right --count origin/<branch>...HEAD` to get ground truth before acting on an inherited “push first” prerequisite. (S136, owner pick Phase5-finish scope “prep + hand off” — CRAN Phase 5 local prep)

**What happened.** S135’s handoff and the runbook both said
`origin/add-methodology` was “2 commits behind — `git push` before
`rhub_check()` or R-hub re-reports the already-fixed `withr` WARNING.”
That was *true when S135 verified it* (Learning 128 was about getting
exactly this right). But between S135 and S136 the branch was pushed, so
by the time S136 ran the prerequisite was **already satisfied** —
`git fetch` +
`git rev-list --left-right --count origin/add-methodology...HEAD` →
`0 / 0`, fully in sync at HEAD `24175785`. The session’s job flipped
from “push” to “confirm and supersede the caveat.” The trap that nearly
hid this: the orientation `git status` said “Your branch is up to date
with ‘origin/add-methodology’”, which I could not safely read as
“already pushed” — it equally means “your tracking ref hasn’t been
fetched.” Only the explicit `fetch` + `rev-list` disambiguated. This is
Learning 128’s sibling pointed at *time* rather than *guessing*: 128
says verify an inherited/guessed identifier; 129 says even a
**correctly-verified** remote snapshot expires — re-fetch at the moment
you depend on it, and when you retire an inherited caveat, mark it
**superseded** in the doc (with the command + result that retired it) so
the next reader doesn’t re-run the obsolete step.

**Reflexes:** \[before acting on any inherited “push first / N commits
behind / unpushed commits” prerequisite, run `git fetch` THEN
`git rev-list --left-right --count origin/<branch>...HEAD` — a remote
can change between sessions, and `git status` “up to date” reflects only
the last-fetched tracking ref\]\[distinguish “I already pushed” from “my
local view of the remote is stale” — both surface as “up to date”; the
fetch is what disambiguates\]\[when superseding a prior caveat in a
runbook/plan, write “superseded by on ” with the exact command + result,
not just a silent deletion, so the supersession is auditable\]\[a
documentation/prep deliverable’s build-equivalent is still real:
`R CMD build .` to confirm the artifact assembles + re-confirm every
external-doc fact firsthand against the current tree, even when “nothing
changed since the gate” — verify the *unchanged* claim too
(`git diff --name-only <gate>..HEAD`)\]. **Apply:** any session that
inherits a branch/remote/push prerequisite, or that hands off a “do X to
the remote first” instruction to a later session.

#### Learning 130 — An adversarial verify pass can itself be wrong — cross-check ITS corrections firsthand, not just the synthesis it attacks; and when the evidence genuinely splits, FRAME the decision for the owner instead of manufacturing one “correct” answer. A fan-out’s skeptic struck the synthesis’s recommended target name and argued for a different one, citing the package’s own `@example` as its evidence — but reading that example firsthand showed it used the *opposite* form, undercutting the skeptic’s own claim. Both the proposer and its adversary were partly right; only the firsthand file read settled the ground truth. Also re-derive inherited magnitudes: the carried “`si.re` in 5 of 6 pedigrees” note undercounted — 6 datasets are malformed (a second, space-form variant was missed). (S137, owner pick F — investigate + file the `si.re` example-data defect as GitHub issue \#53)

**What happened.** Auditing the `si.re` malformed-sire-column defect for
a GitHub issue, I ran a 4-reader → synthesize → adversarial-verify
workflow. The synthesis recommended renaming the malformed column to
**`sire_id`** (symmetric with the sibling `ego_id`/`dam_id`). The
adversarial pass *correctly* caught that the synthesis had overstated
its case (its headline “the period header contradicts the package’s
value-level period-rejection rule” was false — headers and data values
are separate code paths in `qcStudbook`), and it argued the
convention-consistent target was instead the **space form `si re`**,
citing `R/fixColumnNames.R`’s documented `@example` as evidence the
package’s own sire exemplar uses a space. I did **not** take that at
face value: reading `R/fixColumnNames.R:16` firsthand, the `@example`
actually uses **`Sire_ID`** (underscore) — the opposite of what the
skeptic claimed, and evidence *for* the synthesis’s underscore idea, not
the skeptic’s space idea. The real ground truth (from reading the files,
not either agent’s summary): the repo ships **three** messy-sire
conventions — `si re` (space, in `createPedOne` + ~8 local fixtures),
`Sire_ID` (underscore, the `@example`), and `si.re` (period, the five
`.RData` files) — and the period form matches none. So neither the
proposer’s nor the adversary’s single “correct name” was right; the
honest deliverable was to document the defect and **present the
target-name choice (`si re` / `sire_id` / `sire`) with trade-offs as a
maintainer decision** in the issue. Separately, the inherited handoff’s
“5 of 6” framing undercounted: a firsthand
[`names()`](https://rdrr.io/r/base/names.html) scan of every dataset
found `pedOne` *also* carries a malformed `si re` (space) sire column,
making it 6 — and
[`fixColumnNames()`](https://github.com/rmsharp/nprcgenekeepr/reference/fixColumnNames.md)
empirically normalizes all forms to canonical `sire`, so the defect is
internal inconsistency, not a functional break (confirmed not a CRAN
blocker). Filed as issue \#53 with `bug` + `low priority`.

**Reflexes:** \[when an adversarial/verification agent CORRECTS a
synthesis, re-verify the correction’s *cited evidence* firsthand before
adopting it — a skeptic can be confidently wrong, and “the verifier said
so” is not ground truth\]\[when two passes disagree on a decision and
both have partial evidence, read the primary source yourself; if the
evidence genuinely splits, the deliverable is to frame the choice with
trade-offs for the owner, not to assert a false single answer (FM \#23 —
a contested call is the owner’s)\]\[re-derive any inherited
count/magnitude (“N of M”, “5 files”, “~35 words”) firsthand — a carried
characterization drifts in magnitude, not just in truth value\]\[for a
shipped-DATA defect, separate “functionally broken” (does
ingestion/mapping still produce the canonical schema?) from “internally
inconsistent / typo-looking” — run the normalizer (`fixColumnNames`) on
each variant to prove which it is before calling it a blocker\]\[an
audit/issue deliverable’s “build-equivalent” is firsthand verification
of every <file:line> claim it makes + running the relevant code path
(here
[`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
`fixColumnNames`), not just assembling prose\]. **Apply:** any session
that runs a verify/adversarial pass over its own findings (standing
practice under ultracode), any issue/audit that must recommend a
contested decision, and any fix scoping that inherits a count or “it’s
broken” claim.

#### Learning 131 — A data/fixture change can break a test that asserts on the SHAPE of derived output (a count, a row total, a newline tally) without that test ever referencing the changed value literally — so a grep-for-the-changed-token pre-flight scan will miss it; the full test suite is the only reliable breakage check. (S138, owner pick — the real fix for issue \#53: rename the example datasets’ sire column to `sire.id`)

**What happened.** Before regenerating the 6 example pedigrees
(`si.re`/`si re` → `sire.id`), I ran a breakage scan: grep `tests/` for
the literal `si.re`/`si re` and for change-log bucket names. It reported
“no test breaks” — every `si re` in tests was a self-contained local
fixture, and no test referenced the shipped data’s sire column by its
literal name. That was *true* yet incomplete: the full-suite VERIFY
surfaced one real failure in `test_summary.nprcgenekeeprErr.R`, which
counts newlines in a qcStudbook summary
(`stri_count_regex(...$txt, "\\n") == 9L`). Renaming the column to
`sire.id` makes normalization fire one EXTRA step (`sireIdToSire`,
because `sire.id`→`sireid`→`sire`, whereas `si re`→`sire` was already
canonical), so the summary gained a line and the count became 10. The
test never mentions `si.re`/`si re`/`sire.id` — it asserts on the
*shape* of output derived from the data — so no token grep could have
found it. Updated `9L`→`10L` after confirming the new output is correct
(it reports one more real normalization step). The fix was otherwise
clean (full suite 0/0, `R CMD check` Status: OK).

**Reflexes:** \[a fixture/data change’s breakage check is the FULL test
suite, not a grep for the changed token — tests asserting on counts, row
totals, lengths, or formatted-text shape break invisibly to grep\]\[when
changing example data that flows through a reporting/summary/format
function, expect output-shape assertions (newline counts, “N rows”,
`nrow(...)`) to shift; re-run them\]\[pin the data CONTRACT in a RED
test (exact column names) rather than trusting a pre-flight grep to
predict breakage — the contract test is deterministic, the grep is
heuristic\]\[when an output-shape count changes, verify the NEW value is
correct before updating the literal — don’t just bump the number to make
it pass\]. **Apply:** any session that regenerates shipped/example data
or fixtures consumed by reporting/summary/format functions.

#### Learning 132 — A spell/lint flag on a GENERATED file can be a render-time artifact, not a source defect: pandoc’s smart-quotes turn straight `'...'` in an `.Rmd` into curly `'...'` in the `.md`, and a quote sitting against a word (`'row.names'` → `names'`) becomes a bogus token. Fix it at the SOURCE in a way the renderer can’t undo — a code span (backticks) bypasses smart-quotes — then RE-RENDER and confirm the regenerated-file diff is confined to the one intended line. Never hand-edit the generated `.md`. (S139, owner directive — clear S138’s punch-list)

**What happened.** S138 flagged a lone `names'` spell hit at
`NEWS.md:51` (“fix the quote, don’t whitelist”). The obvious read —
“there’s a curly quote to straighten in the source” — was wrong:
`NEWS.Rmd:53` *already* used straight ASCII quotes
(`"duplicate 'row.names' are not allowed"`). The curl is introduced by
pandoc’s `smart` extension at render time (github_document); because the
closing `'` sits directly against `names`, the tokenizer emits the bogus
`names'`. So there was nothing to “straighten” at the source. Two
tempting wrong fixes: editing `NEWS.md` directly (it’s generated from
`NEWS.Rmd` — would be overwritten, plan gotcha \#3), or disabling
`smart` globally (would curl-strip every other quote in the 500-line
file — a huge unwanted diff). The right fix wraps the literal base-R
message in backticks in `NEWS.Rmd`
(`` `duplicate 'row.names' are not allowed` ``): code spans are exempt
from smart-quotes, the straight quotes survive, and it reads better (a
verbatim error message *is* code). Re-rendered `NEWS.md`
(github_document, `html_preview=FALSE`) → exactly a one-line diff;
`spell_check_package()` 1 flag → 0. Same discipline on the README
de-dup: edited the `.Rmd` source (removed README.Rmd’s own hardcoded
citation block, leaving the copy that renders from the shared
`_introduction.Rmd` child so the manual/tutorial vignettes were
untouched), re-rendered via `build_readme()`, and read the `git diff` to
confirm it was confined to the removed block (+ a correct incidental
[`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)
date refresh) before committing.

**Reflexes:** \[a spell/URL/lint flag on a generated file (`NEWS.md`,
`README.md`, `man/*.Rd`) — trace it to the SOURCE (`.Rmd`/roxygen) and
fix there, then re-render; never hand-edit the generated file (it’s
overwritten)\]\[a `name'`-style bogus token usually comes from pandoc
smart-quotes curling a straight quote that sits against a word — the
source may already be “correct”; wrap the literal in a code span
(backticks) so the renderer leaves it alone, rather than disabling
`smart` globally (which rewrites every quote in the file)\]\[after
editing a generated file’s source, RE-RENDER and `git diff` the
generated file — confirm the diff is confined to the intended change; an
incidental-but-correct refresh (a
[`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)
date) is fine, a storm of formatting changes means the committed file
had drifted from its source — investigate before committing\]\[when a
duplicate renders from a shared child doc + a local block, remove the
LOCAL block to keep blast radius to the one file — deleting the shared
child changes every consumer (here `a3manual.Rmd` +
`ColonyManagerTutorial.Rmd`)\]\[re-run the checker after the fix
(`spell_check_package()` → 0) — don’t assume the edit worked\].
**Apply:** any fix to a flag/warning on a knitr/pandoc/roxygen-generated
artifact, and any edit that requires re-rendering `NEWS.md` /
`README.md`.

#### Learning 133 — Before merging a PR, triage its CI checks: a red check is not automatically a merge-blocker. `gh pr view --json mergeStateStatus` distinguishes **BLOCKED** (a *required* check is failing — do not merge) from **UNSTABLE** (mergeable; only non-required checks are red). When a check is red, read its log and CLASSIFY it — required vs optional, correctness vs style, introduced-by-this-PR vs pre-existing — and report that classification; don’t merge blind, and don’t refuse a merge the owner directed just because a non-required style check is red. (S140, owner directive “merge \#54”)

**What happened.** PR \#54 (the 2.0.0 merge) came back
`mergeable: MERGEABLE` but `mergeStateStatus: UNSTABLE`.
`gh pr checks 54` showed every R-CMD-check (macOS / Windows / Ubuntu
devel+oldrel+release), test-coverage, codecov, and pkgdown **PASS** —
and exactly one red: `lint`. Reading the failed job log, the lint
failure was ~30 `lintr` STYLE warnings (`return_linter` “explicit
return() not needed”, `seq_linter` “use seq_along”, `coalesce_linter`
“use %\|\|%”, `nonportable_path_linter`, `boolean_arithmetic_linter`) in
long-standing core files (`qcStudbook.R`, `geneDrop.R`,
`removeDuplicates.R`, `makeFounderStatsTable.R`, the `mod*.R` modules,
…) plus a CI config wart (`cyclocomp` package not installed → exit 31).
None were correctness issues, none were introduced by S139 (docs only —
zero R code), and `lint` is **non-required** (hence UNSTABLE not BLOCKED
— GitHub allowed the merge). So the disciplined output was to **surface
the finding** (“the only red check is non-required pre-existing style
lint; all correctness checks pass”) and **proceed with the
owner-directed merge** — neither merging silently over a red check nor
refusing it. Merge landed: merge commit `46dfc766`, `origin/master` now
`Version: 2.0.0`. A trap en route: `gh pr view 54 --json merged` errors
(`merged` is not a field — use `state` / `mergedAt`); the field error
made a *successful* merge look failed until I re-checked with
`state: MERGED`.

**Reflexes:** \[before merging, run `gh pr checks <N>` and
`gh pr view <N> --json mergeStateStatus,mergeable` — BLOCKED = a
required check failing (stop), UNSTABLE = mergeable with only
non-required checks red\]\[when a check is red, open its log and
CLASSIFY it (required vs optional, correctness vs style, introduced vs
pre-existing) and report that — merging blind and refusing-on-any-red
are both wrong\]\[a non-required lint/style check failing is
informational debt, not a correctness gate — an explicit owner merge
directive proceeds, with the finding surfaced\]\[use a merge commit (not
squash) to preserve a long-lived branch’s per-session history; never
`--delete-branch` unless told\]\[verify the merge actually landed
(`git fetch` + `git show origin/master:DESCRIPTION` +
`git merge-base --is-ancestor <head> origin/master`) — don’t trust the
`gh pr merge` exit alone; a bad `--json` field query can mask success,
so confirm `state: MERGED` / `mergedAt`\]. **Apply:** any PR merge,
especially into a protected/default branch with mixed required +
informational CI checks. (Records a known state: `lint` is RED on
`master` — pre-existing lintr style debt; a future REFACTOR session
could clear it to green.)

#### Learning 134 — Clearing a lint check is a FIXPOINT problem, not a one-pass edit: an autofix that satisfies its TARGET linter can TRIGGER other linters (a cascade), so the only reliable completion signal is re-running `lint_package()` over the WHOLE tree after the per-file fixes and repeating until 0 — never trust a per-file fixer’s “done.” And a linter message is a suggestion, not a mandate: `nonportable_path_linter` fires on any `/`-bearing string (incl. MIME types), `coalesce_linter` assumes `%||%` exists — when the literal fix is wrong or unavailable, prefer `# nolint` (extending the author’s intent) or disabling the linter in `.lintr`, not the transformation the message names. (S141, owner pick — Lint cleanup → green CI; this clears the exact state Learning 133 flagged)

**What happened.** The CI lint log showed “~30” warnings (Learning 133’s
count); a firsthand `lint_package()` found **57** across 33 files. Owner
picks: disable `coalesce_linter` (11), fix `data-raw` (5), continue on
`add-methodology`. After `.lintr` got `coalesce_linter = NULL`, 46 code
fixes remained across 28 files; I ran a fix→adversarial-review workflow
(one fixer + one independent behavior-neutrality reviewer per file, 56
agents). 27 files came back clean; the central re-lint then read **5,
not 0** — all in `removeDuplicates.R`: the `boolean_arithmetic` autofix
`sum(duplicated(x)) == 0L` → `!any(duplicated(x))` *cleared its target*
but *triggered three new linters* (`if_not_else`, `any_duplicated`,
`unnecessary_nesting`). The per-file fixer could not see this — it only
knew its assigned lints. I rewrote the function to
`if (anyDuplicated(x) > 0L) <dups> else NULL` and converted the
[`stop()`](https://rdrr.io/r/base/stop.html) branch to a guard clause
(`if (anyDuplicated(p$id) > 0L) stop(...); p`), which satisfied all four
linters and preserved exact behavior (`sum(duplicated)==0` ⟺ no dups ⟺
`anyDuplicated > 0` false, including the empty-vector edge:
`duplicated(character(0))` → no dups, `anyDuplicated` → 0). Re-lint →
**0**. Two more context-blind-linter judgments: (a)
`nonportable_path_linter` flagged a **MIME-type** string in
`modPedigree`’s `fileInput(accept = c(...))` — the author had *already*
put `# nolint: nonportable_path_linter` on the adjacent `"text/csv"`
line (clear intent: false positive) but missed the second string; the
fixer “fixed” it by wrapping the MIME type in
[`file.path()`](https://rdrr.io/r/base/file.path.html) (output
identical, semantically wrong), so I restored the readable string +
extended the `# nolint`. (b) `coalesce_linter` wants `%||%`, but base R
only added it in 4.4, the package `Depends: R (>= 4.1.0)`, and shiny
1.13 dropped its export — adopting it would silently break R 4.1–4.3, so
disabling (consistent with the 7 linters `.lintr` already disables) was
correct, not a transformation. The `cyclocomp` wart: `.lintr` already
NULLs `cyclocomp_linter`, but `linters_with_tags()` constructs it at
config-load and warns when `cyclocomp` is absent (non-fatal — clearing
the lints alone makes CI green); added `any::cyclocomp` to `lint.yaml`
to silence the log noise. The one `line_length` fix on a roxygen comment
(`R/data.R:358`) meant the generated `.Rd` was stale, so I regenerated
`man/` (installed roxygen2 == the pinned
`Config/roxygen2/version: 8.0.0`, so no version-churn) — diff confined
to `man/rhesusPedigree.Rd`’s one reflowed line. Final triple:
`lint_package()` = 0, full suite 0/0, `R CMD check` Status OK (0/0/0),
plus a firsthand read of the entire diff.

**Reflexes:** \[a lint sweep is iterative — after applying fixes, re-run
the linter over the WHOLE package and repeat until 0; an autofix can
clear its target and trigger others (`boolean_arithmetic` →
`if_not_else` + `any_duplicated` + `unnecessary_nesting`), and per-file
fixers are blind to the cascade\]\[don’t trust a fan-out’s per-file
“fixed” as the completion signal — the authoritative checks are the
central re-lint + the full test suite, run by you\]\[a linter message is
a suggestion, not a mandate: `nonportable_path_linter` fires on MIME
types / URLs, `coalesce_linter`/`undesirable_*` assume an idiom exists —
when the literal fix is wrong (MIME-as-path) or unavailable (`%||%`
below the R floor), prefer `# nolint` (extend the author’s existing
intent) or disable the linter in `.lintr` (consistent with its
already-disabled set)\]\[check the package’s R-version floor before
adopting a “newer idiom” autofix — `%||%` is base only since R 4.4; the
pkg Depends R≥4.1 and shiny 1.13 no longer exports it\]\[if a style fix
touches a roxygen comment, regenerate `man/` (confirm installed
`roxygen2` == the pinned `Config/roxygen2/version` first, to avoid
version-churn) and diff `man/` to confirm the regeneration is
confined\]\[a behavior-neutral REFACTOR’s build-equivalent is the full
triple — `lint_package()`=0, full suite 0/0, `R CMD check` Status OK —
plus a firsthand read of the entire `git diff`, not the fixers’
summaries\]. **Apply:** any lint/style/formatter cleanup, any session
acting on linter autofixes, and any fan-out whose per-agent outputs need
a central re-verification.

#### Learning 135 — To make a CI check’s fix demonstrably green you may have to MERGE it where the workflow runs: a check whose workflow triggers only on `pull_request` / push-to-default is invisible on a feature-branch push, so the fix’s green status is unverifiable until a PR runs — open the PR, watch all checks, then merge (do not merge blind). And when adopting a default-branch workflow, the local default branch is often badly STALE and `git pull` may be reconfigured to rebase (`pull.rebase=true`) — which a standing junk modification (`.DS_Store`) will block; sync a stale-but-ancestor local branch with `git fetch` + `git reset --hard origin/<branch>` (after `git merge-base --is-ancestor HEAD origin/<branch>` proves it’s an ff), NOT `git pull`. (S142, owner directive “work on 1, 2, and 3” + branch plan “merge now, switch to master”)

**What happened.** S141 cleared all `lintr` lints on `add-methodology`,
but the repo’s `lint` GitHub Actions workflow triggers only on
`pull_request` and push to `main`/`master` — NOT on push to
`add-methodology` — so the fix was green *locally* yet the `lint` check
stayed RED on `master` and there was no CI run anywhere to prove the fix
worked. The only way to see it pass was to open a PR. I pushed S141’s 2
commits, opened **PR \#55** (`add-methodology`→`master`), and watched
all checks via a background `gh pr checks 55 --watch` → 11/11 PASS,
including **`lint` PASS** and `mergeStateStatus: CLEAN` (vs PR \#54’s
UNSTABLE when lint was red) — only *then* merged (`--merge`, merge
commit `f44a5322`), verifying it landed firsthand
(`merge-base --is-ancestor 507de407 origin/master`). Then, executing the
owner’s “switch to master”, I hit two git traps in sequence: (a) local
`master` was **215 commits stale** (it had never been the working branch
— all work was on `add-methodology`), and (b) `git pull` failed with
“cannot pull with rebase: You have unstaged changes” because the repo
has `pull.rebase=true` and the standing `.DS_Store` modification (a
never-commit keep) was in the tree. Rather than stash-juggling or
force-flailing, I confirmed local master was a **strict ancestor** of
`origin/master` (`git merge-base --is-ancestor HEAD origin/master` = YES
→ a hard reset is exactly a fast-forward of tracked content, and
`git status --untracked-files=no` showed `.DS_Store` was the *only*
tracked modification, so nothing real to lose), then
`git reset --hard origin/master` → clean at the merge tip. The
disposable Phase-1B stub was discarded before the switch (it gets
rewritten as the full handoff anyway). The standing keeps were
respected: `PED_GV_AUDIT_2026-05-30.html` (untracked) untouched by the
reset; `.DS_Store` reset to its committed bytes (the keep is “never
*commit* it”, not “preserve this exact local modification”).

**Reflexes:** \[a CI check that is RED because its fix lives on a branch
the workflow doesn’t run on is only PROVABLE-green via a PR (or a push
to the trigger branch) — open the PR, watch ALL checks
(`gh pr checks <N> --watch`), confirm the target check PASS +
`mergeStateStatus: CLEAN`, THEN merge; never merge blind (Learning
133)\]\[use a background `gh pr checks <N> --watch` so the harness
re-invokes you when CI finishes — don’t poll\]\[after merging, verify
firsthand it landed: `state: MERGED` +
`git merge-base --is-ancestor <fix-commit> origin/<base>` + the expected
`DESCRIPTION` version — not the `gh` exit alone\]\[a local default
branch you’ve never used is probably FAR behind origin — `git fetch`
then check `git merge-base --is-ancestor HEAD origin/<branch>`; if YES
it’s a safe fast-forward\]\[this repo has `pull.rebase=true` —
`git pull` becomes a rebase and ABORTS on any unstaged change (the
standing `.DS_Store`); to sync a stale-but-ancestor local branch use
`git reset --hard origin/<branch>` (provably ff-equivalent) instead of
`git pull`\]\[before any `reset --hard`, prove safety: confirm
strict-ancestor AND that `git status --untracked-files=no` shows only
throwaway tracked modifications — `reset --hard` discards tracked-file
changes but leaves genuinely-untracked files (so the `PED_GV_AUDIT` keep
survives)\]\[a “standing keep” of a junk file (`.DS_Store`) means never
COMMIT it, not preserve its exact local bytes — resetting it is fine\].
**Apply:** any session that pushes/merges to make a CI check green, any
branch-strategy switch to a long-dormant local default branch, and any
`git pull`/`reset` on this repo (mind `pull.rebase=true`).

#### Learning 136 — A technical-EVALUATION research deliverable still obeys the RESEARCH_DOCUMENTATION workstream’s claim-source discipline — every technical claim must trace to a `file:line` / `repo:path` / CRAN page, not a recollection — and the right machine for it is a multi-agent investigate → ADVERSARIALLY-verify → synthesize pipeline, where the author then independently re-verifies the firsthand-checkable subset (the codebase baseline). The verify stage is not ceremony: it caught 3 nuance refutations + 1 uncertain among 37 load-bearing claims, and the synthesis carried the *corrected* claims, not the originals. (S143, owner directive — delete `add-methodology` + research LabKey integration options)

**What happened.** The deliverable was an evaluation doc (“how does
nprcgenekeepr integrate with LabKey; what to change”) — not a paper, but
the workstream applies: I treated the codebase, the four LabKey
EHR-module repos (owner-supplied as primary sources), and the Rlabkey
CRAN/LabKey docs as the corpus, and required every claim to cite a
`file:line` / `repo:path` / URL. I ran a Workflow: 5 parallel
investigators (Rlabkey/CRAN; base `ehrModules`; ONPRC; SNPRC/NIRC;
architecture) each returning structured
`{claim, evidence, source, confidence, loadBearing}`; a `pipeline()`
stage that adversarially RE-CHECKED each load-bearing claim against its
primary source (prompted to *refute*); then a synthesis agent that
drafted the full doc, instructed to drop/caveat refuted claims and flag
uncertain ones. Of 37 load-bearing claims: 33 confirmed, **3 refuted, 1
uncertain** — and the refutations were not “wrong” so much as *imprecise
mechanism* (e.g. one thread sourced the `Id/parents/dam` lookup to
`ParentsDemographicsProvider`/`study.parentageSummary`; the verifier
traced it firsthand to `DefaultEHRCustomizer.java` →
`study.demographicsParents`, a NOT_IN_DB query; another mis-sourced
`lastDayAtCenter`’s computation; another mis-classified
`httr`/`jsonlite` as Imports when CRAN lists them as Depends). The
synthesis carried the corrected versions with explicit “Correction from
review” notes + an appendix marking verdicts. **I did not ship the
fan-out’s synthesis on trust:** I had already read the LabKey-touching R
files firsthand to build the ground-truth anchor (and fed it to every
agent as fact), and after the draft I re-verified the codebase claims
the recommendations rest on — the `getPedDirectRelatives`
source-agnostic seam (`R/getPedDirectRelatives.R:41-43`),
`test_getDemographics.R`’s skip-on-CRAN/skip-on-network (so the
integration is never deterministically tested), `mockery` already in
`test_getFocalAnimalPed.R`, and that `getLkDirectRelatives` does NOT yet
delegate to the seam. Placed the doc in a new `docs/research/` dir (no
prior LabKey doc existed — checked first, per the “check process
history” reflex), named `labkey-integration-options-2026-06-19.md`.
Project facts worth not re-deriving (all in the doc): the entire LabKey
surface is ONE `labkey.selectRows()` of `study.demographics` + a pure-R
walk; auth is the implicit `.netrc`/API-key default (the example config
explicitly requires `.netrc`); `Rlabkey` is unversioned in `Imports`
while `Rlabkey` 3.x ratchets a LabKey-server floor; ONPRC curates
genetic-preferred parentage (overridden `demographicsParents.sql`) while
SNPRC/NIRC collapse to `'Observed'`.

**Reflexes:** \[a technical-evaluation / architecture-research
deliverable is a RESEARCH_DOCUMENTATION pass — require every claim to
cite `file:line` / `repo:path` / a fetched URL, build a claim-source
appendix, and stamp time-relative claims with the date\]\[for a research
fan-out, ALWAYS interpose an adversarial per-claim verification stage
between investigate and synthesize — prompt the verifier to REFUTE
against the primary source and default to “uncertain” when it can’t
check; fan-out investigators confidently mis-source mechanism even when
the high-level fact is right\]\[instruct the synthesizer to carry the
CORRECTED claim (not the original) for anything refuted, flag
“uncertain” inline, and never invent a version/date/path absent from the
inputs\]\[the author still owns verification: build the ground-truth
anchor by reading the primary files FIRSTHAND before the fan-out (and
feed it to the agents as fact), and after the draft re-verify firsthand
the subset the recommendation rests on — don’t ship synthesized claims
on trust\]\[read EHR-module repos without cloning:
`gh api "repos/<org>/<repo>/git/trees/HEAD?recursive=1"` to list, grep
the tree, fetch single files via `gh api .../contents/<path>`; note the
default branch (`develop` for LabKey)\]\[mark anything checkable only
against a live server “(unverified — requires confirmation)” and collect
it in an Open Questions section — don’t launder it into fact\]\[new doc
category → new `docs/<kind>/` dir (`docs/research/`), date-suffixed
filename, after confirming no prior doc covers it\]. **Apply:** any
research/evaluation/architecture deliverable, any multi-agent
investigation whose synthesized output will be acted on, and any future
work on nprcgenekeepr’s LabKey/`Rlabkey` data-source layer (start from
`docs/research/labkey-integration-options-2026-06-19.md`).

#### Learning 137 — A freshly-added package function makes `lintr::object_usage_linter` FALSELY report “no visible global function definition” — because lint resolves global symbols against the INSTALLED/loaded namespace, which doesn’t yet contain it; the fix is to re-lint after `load_all()` (or install), NOT `# nolint` on correct code. (S144, owner pick — LabKey research Rec \#3: explicit optional API-key auth with `.netrc` fallback)

**What happened.** Implementing
[`setLabKeyDefaults()`](https://github.com/rmsharp/nprcgenekeepr/reference/setLabKeyDefaults.md)
(+ internal `getConfigApiKey()`/`hasNetrc()`, + a call to it from
[`getDemographics()`](https://github.com/rmsharp/nprcgenekeepr/reference/getDemographics.md)),
a fresh `lintr::lint_package()` reported 4 `object_usage_linter`
warnings — but ONLY on the four NEW cross-references
(`getDemographics→setLabKeyDefaults`;
`setLabKeyDefaults→{getConfigApiKey, hasNetrc, labkey.setDefaults}`);
every pre-existing internal cross-reference
(e.g. `getSiteInfo→getParamDef`) was clean. That asymmetry is the tell:
`object_usage_linter` resolves globals against the package namespace as
built from the **installed** package, and my new functions weren’t
installed yet, so they read as undefined while the stale install’s
functions resolved fine. Re-running `lint_package()` after
`pkgload::load_all(".")` → **0 lints**; and CI `lint.yaml` uses
`setup-r-dependencies` with `extra-packages: ... local::.`, which
installs the current source before linting, so CI is clean too (verified
the workflow firsthand). The wrong move would have been `# nolint` on
correct, already-exported code — Learning 134’s “a linter message is a
suggestion” cuts both ways: sometimes the message is an environment
artifact, not a code problem. Two project constraints shaped the design,
both found by reading firsthand BEFORE coding: (a) `getParamDef()`
[`stop()`](https://rdrr.io/r/base/stop.html)s on an absent token, so an
OPTIONAL `apiKey` token needed a soft reader (`getConfigApiKey`), not
`getParamDef`; (b) `test_getSiteInfo.R` asserts
[`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)’s
EXACT field-name vector — adding an `apiKey` field there would have
broken that test and rippled through the ~10 Shiny-module callers, so
the credential reader stays self-contained. Testability: every external
dependency of `setLabKeyDefaults` (the env var, the config-file path,
the netrc location, the `baseUrl`) is routed through an INJECTED
`siteInfo` list + `withr`-controlled env vars, and only the true
side-effect
([`Rlabkey::labkey.setDefaults`](https://rdrr.io/pkg/Rlabkey/man/labkey.setDefaults.html))
is [`mockery::stub`](https://rdrr.io/pkg/mockery/man/stub.html)-bed — so
all seven branch tests are deterministic regardless of the host’s real
`.netrc`/env (the owner’s real netrc can’t perturb them). Final triple:
suite 0/0, `lint_package()` 0 (loaded), `R CMD check` Status OK; plus a
runtime smoke of the real un-stubbed function across all three branches
(apiKey/netrc/no-cred). Process slip caught: I wrote “`R CMD check`
Status OK” into the CHANGELOG BEFORE running it — caught it, ran the
check (first run failed in `/tmp` on a libpath that couldn’t see the
renv library; re-ran with
`R_LIBS="$(Rscript -e 'cat(paste(.libPaths(),collapse=\":\"))')"` →
genuine Status OK). Never let a claim precede its evidence.

**Reflexes:** \[a fresh `lint_package()` flagging `object_usage_linter`
“no visible global function” on ONLY the functions you just added =
stale-install artifact, not a real lint — re-lint after
`pkgload::load_all(".")`; if 0, it’s clean (and CI that installs
`local::.` before linting is clean too — verify the workflow)\]\[never
`# nolint` a symbol that genuinely exists in the package just to silence
object_usage; fix the resolution context, not the code\]\[an OPTIONAL
config token can’t reuse `getParamDef()` (it
[`stop()`](https://rdrr.io/r/base/stop.html)s on absent) — write a soft
reader returning `""`/`NULL`\]\[before adding a field to a widely-used
accessor like
[`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md),
grep its callers AND check for a test asserting its EXACT shape
(`test_getSiteInfo.R` does) — prefer a self-contained helper over
widening a contract\]\[make a credential/IO function deterministically
testable by INJECTING its environment (a `siteInfo` arg +
[`withr::local_envvar`](https://withr.r-lib.org/reference/with_envvar.html))
and stubbing ONLY the side-effecting external call with `mockery` —
host-machine state then can’t perturb the tests\]\[run `R CMD check`
against an renv project with
`R_LIBS="$(Rscript -e 'cat(paste(.libPaths(),collapse=\":\"))')"` so the
clean check R sees the renv library — a bare `R CMD check` in `/tmp`
reports all deps “not available”\]\[never write a verification result
(Status OK, tests pass) into a file before the command has actually
produced it\]. **Apply:** any session adding new exported/internal R
functions (expect the object_usage artifact), any new optional config
token, any test of a credential/server/IO function, and any future work
on nprcgenekeepr’s LabKey auth (start from `R/setLabKeyDefaults.R` +
`docs/setup/labkey-authentication.md`).

#### Learning 138 — Pinning a dependency VERSION FLOOR: derive the client-correctness minimum from the dependency’s OWN changelog matched to the EXACT call you make (every argument, not just the headline feature), and resolve a “what version does the site run” gate by mining the vendor’s open-source module repos (highest non-SNAPSHOT release branch = targeted version) — but a `>=` floor only enforces client-correctness + CRAN hygiene, NOT server-compat (a too-new client outrunning an old server needs an upper bound, which CRAN discourages). (S146, owner “1 then 2” — delete merged `labkey-apikey-auth` branch + `Rlabkey` version floor)

**What happened.** Pinning the unversioned `Rlabkey,` in `DESCRIPTION`.
The S143 research doc said the API-key arg landed in `Rlabkey` 2.1.130,
but the package’s actual S144 call passes BOTH args —
`labkey.setDefaults(apiKey=, baseUrl=)` — and `Rlabkey`’s own installed
NEWS shows `baseUrl=` support landed one version LATER, at **2.1.131**
(apiKey 2.1.130, baseUrl 2.1.131). So the true minimal
client-correctness floor is 2.1.131, not 2.1.130 — a one-version
off-by-one the doc would have led me into; reading the dependency’s
changelog firsthand against the EXACT call (all arguments) caught it.
The doc’s headline RISK was the opposite direction — a client too NEW
for the live server (`Rlabkey` 3.x ratchets a LabKey-SERVER minimum:
3.2.0 needs server ≥ 24.1, 3.4.1 ≥ 24.12) — but a `>=` floor cannot
defend against that (only an upper bound would, and CRAN discourages
upper bounds; server-compat is a deployment matter, not a DESCRIPTION
constraint). To resolve the gated “what version do ONPRC/SNPRC run?”
(research doc Open Q §8.1, previously framed as answerable only against
the live server), I mined the four vendor EHR-module repos via a
workflow: none pins a server version in-file (module versions are
build-injected via `ManageVersion`/centralized Gradle), so the
authoritative signal is the highest non-SNAPSHOT `release` branch name
under LabKey’s `YY.M` scheme — **all four (base + ONPRC + SNPRC + NIRC)
target 26.6** (corroborated by the newest `*-26.000-26.001.sql`
dbscripts), adversarially verified per repo. Caveat carried into the
handoff: a maintained release branch = the version the module code is
BUILT FOR, NOT proof of the DEPLOYED production version (a center can
run older) — bounded by the maintained range (~19.x..26.6) but not
pinned. Net: the floor’s real job is client-correctness + CRAN hygiene,
so the owner’s pick of a conservative `>= 3.2.0` (server ≥ 24.1,
consistent with the 26.6 evidence) is a defensible POLICY bump above the
2.1.131 correctness minimum, not a correctness necessity. Before writing
“3.2.0” I confirmed firsthand it is a real release header in NEWS
(`Changes in 3.2.0`, “only supported for LabKey Server v24.1 or later”)
and that installed 3.4.6 ≥ 3.2.0 (claim never precedes evidence —
Learning 137). Verified as a CONFIG change (owner pick “Config change, R
CMD check”): `devtools::check()` Status OK 0/0/0 — a satisfied floor
bump is runtime-inert, so no RED→GREEN→REFACTOR (no behavioral logic to
test; the build equivalent IS the verification, and a guard test
asserting the floor’s mere presence would be near-tautological).

**Reflexes:** \[pin/bump a dependency floor against the dependency’s OWN
NEWS/changelog, matched to the EXACT call you make — check EVERY
argument’s introduction version, not just the headline feature (here
`baseUrl=` at 2.1.131 was one past the `apiKey=` 2.1.130 a research doc
cited)\]\[a `>=` floor protects only against a too-OLD client
(client-correctness) + satisfies CRAN’s version-your-deps preference —
it CANNOT stop a too-NEW client outrunning an old server; that’s a
deployment concern, and CRAN discourages the `<=` upper bound that
would\]\[resolve a “what server/site version is running” gate by mining
the vendor’s open-source module repos: highest non-SNAPSHOT `release`
branch = targeted version (LabKey = `YY.M`); `module.properties`
`ManageVersion:true`/centralized-Gradle ⇒ NO in-file version pin, so the
branch name is the signal — corroborate with dbscript version
ranges\]\[ALWAYS distinguish module-TARGET (release branch) from
DEPLOYED production version — a maintained branch proves what the code
is built for, not what’s running; bound it by the maintained range and
mark the residual unobserved\]\[confirm a specific version is a REAL
release (changelog header) AND that the installed copy satisfies it
BEFORE writing it into DESCRIPTION\]\[a DESCRIPTION version-floor change
has no behavioral logic to unit-test — verify it as a CONFIG change via
`R CMD check`/`devtools::check()` (the build equivalent); a satisfied
floor bump is runtime-inert, so no RED→GREEN→REFACTOR and a
presence-asserting guard test is near-tautological\]. **Apply:** any
time you pin or bump a dependency version constraint, any “what version
is the server/site on” question (mine the vendor repos), and any future
`Rlabkey`/LabKey floor revisit on nprcgenekeepr (start from
`DESCRIPTION` + `docs/research/labkey-integration-options-2026-06-19.md`
§3.4 / §7 Rec 1 / §8.1).

#### Learning 139 — Re-rendering a `github_document` Rmd (e.g. `NEWS.Rmd`) drops a `<name>.html` PREVIEW byproduct (`github_document`’s `html_preview: true` default) at the top level, which `R CMD check` then flags as a “Non-standard file/directory found at top level” NOTE — so after rendering NEWS, delete the stray `NEWS.html` (and any `*_files/` dir) BEFORE checking/committing. (S147, LabKey research Rec \#2)

**What happened.** REFACTOR re-rendered `NEWS.Rmd` → `NEWS.md` via
`rmarkdown::render("NEWS.Rmd")`. The Rmd’s
`output: github_document: default` carries `html_preview = TRUE`, so the
render ALSO wrote a `NEWS.html` preview (untracked, not git-ignored).
The first `devtools::check()` came back **0 errors / 0 warnings / 1
NOTE** — the NOTE being exactly “Non-standard file/directory found at
top level: ‘NEWS.html’”, which would have broken the project’s standing
0/0/0 bar. `rm -f NEWS.html` (it was untracked, never part of the
intended change set) and a re-run of `devtools::check()` → **0/0/0**.
(S144 also re-rendered NEWS but its handoff never flagged this — either
it cleaned the artifact silently or the artifact predated its check
baseline; recording it now so the next NEWS-rendering session expects
it.) Permanent fixes exist but were left as candidates to avoid scope
creep: set `html_preview: false` in the NEWS.Rmd YAML, or add
`NEWS.html` to `.Rbuildignore` (the NOTE is about presence in the build,
so `.Rbuildignore` is the real fix) and `.gitignore`.

**Reflexes:** \[after
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
of a `github_document` Rmd, expect a `<name>.html` preview byproduct
(`html_preview` defaults TRUE) + possibly a `<name>_files/` dir — delete
them before `R CMD check`/commit, or they surface as a top-level NOTE
and flip OK→1-NOTE\]\[always re-run `devtools::check()` after removing
any stray artifact before claiming 0/0/0\]\[permanent fixes (candidates,
not done S147): `html_preview: false` in the Rmd YAML, or
`.Rbuildignore` + `.gitignore` entries for `NEWS.html`\]. **Apply:** any
session that re-renders `NEWS.Rmd` (or any `github_document`) and then
runs `R CMD check`.

#### Learning 140 — A research/recommendation doc can be internally inconsistent — its Recommendation prose can contradict its OWN ground-truth sections and the live codebase — so before implementing a recommendation, ground it firsthand against (a) the doc’s evidence sections and (b) the actual code; here BOTH of Rec \#2’s literal sub-instructions were unsafe for this repo. (S147, LabKey research Rec \#2)

**What happened.** Implementing the LabKey research doc’s Rec \#2 (“move
hardcoded ONPRC defaults into config; reconcile the example-config
drift”), firsthand grounding showed both literal phrasings were wrong
for this codebase: (1) the doc’s alternative “reduce the no-config
fallback to a clear error” is a BREAKING change, not a quick win —
`getSiteInfo(expectConfigFile = FALSE)`’s ONPRC fallback is
load-bearing: it backs the Shiny app’s default launch
(`appUI`/`appServer`/`modORIPReporting`) and its values/structure are
pinned by 5 test files (`test_getSiteInfo`, `test_modSiteConfig`,
`test-e2e-orip-module`, `test_shouldShowOripTab`,
`test_modORIPReporting`) + the exported examples + the
silent-`expectConfigFile = FALSE` contract; (2) the doc’s “align the
example’s flat `dam`/`sire` to the `Id/parents/dam` lookup form” would
make the SNPRC example WRONG — the SAME doc’s §4.3 establishes flat
`dam`/`sire` is the CORRECT form for SNPRC (direct columns) and the
lookup form is ONPRC-specific. I surfaced both contradictions to the
owner via a pre-RED scope `AskUserQuestion`; the owner chose the safe
readings — “Centralize, no behavior change” (extract the fallback into
internal `defaultSiteParams()` as a single source of truth; return
byte-identical) and “Document the center-specific form” (comment the
example so a reader sees WHY SNPRC ≠ ONPRC, rather than unify it). Net
deliverable matched the recommendation’s INTENT (one source of truth + a
clear example) while rejecting its literal STEPS. The blast-radius
inventory (grep every `getSiteInfo` caller + every test asserting its
shape) was the load-bearing step that decided refactor-vs-breaking — the
same evidence-based-inventory discipline a deletion/migration plan
requires.

**Reflexes:** \[before implementing a recommendation from a
research/plan doc, ground it firsthand against BOTH the doc’s own
evidence sections AND the live code — a Recommendation can contradict
the same doc’s ground-truth (Rec \#2 vs §4.3) and the codebase (a “quick
win” that’s actually breaking)\]\[for any change to a widely-used
accessor’s fallback/shape, grep ALL callers + every test asserting its
structure FIRST (here 5 test files + the app default-launch path +
examples) — that inventory decides refactor vs breaking change\]\[when a
recommendation’s literal steps are unsafe but its intent is sound,
surface the contradiction via a pre-RED scope `AskUserQuestion` with the
safe interpretations as options, then implement the intent, not the
wrong literal step\]\[centralize-without-behavior-change = extract to
one internal source + a fallback-equals-source agreement test + a
characterization guard pinning the documented invariant; verify the
consumer’s output is byte-identical to the pre-change literals\].
**Apply:** any session acting on a recommendation from `docs/research/`
or a plan doc (next up: Rec \#4, the data-source adapter), and any
change to a shared accessor’s default/fallback.

#### Learning 141 — Two functions that look like the “same walk” can diverge in result, so a recommendation to “make A delegate its walk to B” is a BEHAVIOR change, not a refactor — read BOTH algorithms and diff their results on a worked example before unifying them. (S148, LabKey research Rec \#4 — data-source adapter)

**What happened.** Rec \#4 of the LabKey research doc said to formalize
a data-source adapter AND “make
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
delegate its walk to the source-agnostic
[`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md).”
Reading both walks firsthand showed they are NOT equivalent:
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
re-seeds `parents`/`offspring` from the PREVIOUS generation only
(`parents <- getParents(ped, parents)`) — a strict ancestors-up +
descendants-down lineage;
[`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)
re-seeds from the FULL accumulated id set each iteration
(`parents <- getParents(ped, ids)`, `ids` growing) — the full
connected-component closure, which pulls in collaterals (siblings,
cousins) because once a parent is added, the next iteration collects
that parent’s other offspring. So “delegate the walk” would ENLARGE the
live LabKey result set: a behavior change, not a refactor. The doc even
hedged (“functionally analogous, not byte-identical; differ in seeding
and accumulation”) — the code confirmed it materially. I scoped the
session to the FETCH boundary only (extract the pull+normalize into
internal `getPedigreeSource()`;
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
keeps its exact walk), surfaced the walk-unification as a separate
behavior-changing decision via a pre-RED scope `AskUserQuestion` (owner
chose the true-refactor slice + an internal `@noRd` adapter via a second
approach `AskUserQuestion`), and the deterministic RED test asserts the
strict-lineage id set {O1,S1,D1,GC1,X1} while EXCLUDING the collateral
sibling O2 — a guard that fails if anyone later swaps in the
full-component walk.

**Reflexes:** \[before unifying/delegating two similarly-named
functions, read BOTH algorithms and diff their RESULTS on a worked
example — superficial structural similarity (“both walk a pedigree”)
hides a different result set\]\[a recommendation that says “make A
delegate to B” is a behavior-change proposal until you have PROVEN A and
B produce identical output — treat it like a breaking change, not a
cleanup; this is Learning 140’s “ground the recommendation firsthand”
applied to a refactor\]\[the true-refactor slice of “formalize the
adapter” is the FETCH boundary (swap how data is OBTAINED) with the
consuming algorithm byte-identical; lock the existing behavior with a
characterization test (here: the id set incl. the deliberately-EXCLUDED
collateral) before touching it\]\[an internal `@noRd` adapter that
declares its own `@import`/`@importFrom` tags keeps NAMESPACE stable
even when you remove those tags from the function it was extracted from
— verify with `git diff NAMESPACE` after `roxygenise`\]\[a parameter
named `source` trips `undesirable_function_linter` (the bare symbol
resolves to base [`source()`](https://rdrr.io/r/base/source.html));
rename it (e.g. `sourceType`) rather than scatter `# nolint`\].
**Apply:** any “make X use/delegate-to Y” or “consolidate these two”
task; any data-source/adapter extraction; any refactor claiming “no
behavior change” over two non-identical code paths.

#### Learning 142 — When you EXECUTE a behavior change a prior session deliberately deferred and GUARDED, the guard/characterization test IS the RED spec — flip its assertion to the new behavior; and before choosing between a “delegate” and an “in-place” implementation, PROVE they are result-equivalent (or characterize where they differ) instead of assuming. (S149, LabKey research Rec \#4 — walk-unification)

**What happened.** S148 deferred unifying
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)’s
strict ancestor/descendant walk with
[`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)’s
full-connected-component walk (a behavior change — the live LabKey
result set grows to include collaterals; Learning 141) and left a
characterization test pinning the OLD behavior (focal O1 →
`{O1,S1,D1,GC1,X1}`, asserting the collateral sibling O2 was EXCLUDED).
Executing the change this session, the RED step was simply to FLIP that
guard: assert the full component `{S1,D1,X1,O1,O2,GC1}` INCLUDING O2
(plus equivalence to `getPedDirectRelatives(ids="O1", ped=fixture)$id`).
The deferred-and-guarded behavior change made its own RED test — the
guard’s inverted assertion was the spec, and it failed against the
current code exactly where predicted (Absent: O2). On approach: the
research doc’s “delegate to `getPedDirectRelatives`” and a “widen the
walk in-place” rewrite LOOK different, but I proved them
result-IDENTICAL in all cases before asking the owner — after a
full-component walk the trailing `addIdRecords(unrelated, …)` is a
guaranteed no-op, because that walk’s fixpoint is exactly
`getParents(ids) ⊆ ids` (the loop runs until
`setdiff(union(getParents(ids), getOffspring(ids)), ids)` is empty), so
every non-NA sire/dam reference is already in the set and `unrelated` is
always empty. With equivalence proven, “delegate” is the clearly-cleaner
choice (one walk implementation, matches the research doc) and the owner
picked it via a pre-RED approach `AskUserQuestion`. Blast-radius check
first (the Learning 140 reflex): the sole production consumer is
[`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md)
(a larger pedigree is more complete for kinship/GVA, not breaking; it
renames 7 positional columns — preserved by `getPedDirectRelatives`’s
`ped[ped$id %in% ids, ]` return), and every other reference mocks
`getLkDirectRelatives` wholesale (walk-agnostic), so no other test
moved. Verified end-to-end: suite 0/0 (1960 passed), lint 0,
`devtools::check()` 0/0/0, and a Phase-3E smoke of the REAL
`getLkDirectRelatives` (full component incl. O2, fail-soft NULL path
intact, body delegates). NEWS render trap recurred: `--` in the Rmd
smart-rendered to an en-dash in NEWS.md (Learning 132) — reworded the
source to drop `--` (the rest of NEWS avoids it) and re-verified NEWS.md
is pure ASCII; deleted the `NEWS.html` byproduct (Learning 139).

**Reflexes:** \[when you execute a behavior change a prior session
deferred-and-guarded with a characterization test, the RED step is to
FLIP that guard’s assertion to the new behavior — the deferred change
carries its own spec; don’t write a brand-new test from scratch and
leave the stale guard to fail confusingly\]\[before choosing between
“delegate to an existing function” and “reimplement in-place” for a
behavior change, PROVE the two produce identical results (or
characterize the difference) — here the proof was that a full-component
walk’s fixpoint (`getParents(ids) ⊆ ids`) makes the trailing
`addIdRecords(unrelated,…)` a guaranteed no-op, so delegate ≡ in-place
in ALL cases; with equivalence proven, pick the cleaner one and confirm
via a pre-RED approach `AskUserQuestion`\]\[run the blast-radius
inventory before a behavior change (grep all callers + which tests MOCK
vs EXERCISE the function) — if the only real consumer tolerates the
larger output and every other reference mocks the function, the change
is contained to the one characterization test\]\[a NEWS.Rmd `--`
smart-renders to a non-ASCII en-dash in NEWS.md — reword the source to
avoid `--` (parentheses/commas) and re-verify NEWS.md is pure ASCII
(`LC_ALL=C grep -P '[\x80-\xFF]'`), then delete the `NEWS.html`
byproduct\]. **Apply:** any session that executes a behavior change a
prior session deferred (flip its guard test); any “delegate vs
reimplement” choice (prove equivalence first); any NEWS.Rmd re-render
(mind the `--`→en-dash + `NEWS.html` traps).

#### Learning 143 — When an owner offers a scope fork (“do A or B”), ground BOTH directions before recommending (a read-only parallel sweep is the right tool — keep file-mutating work solo), and weight OFFLINE TESTABILITY heavily; and when you EXTEND a pluggable seam, derive the new provider’s contract by mirroring its sibling branches, not by inventing one. (S150, LabKey research Rec \#4/#5 — `getPedigreeSource()` `"file"` provider)

**What happened.** The owner’s directive named item 3 as “add a
`file`/other-EHR provider on the `getPedigreeSource()` seam; or
server-side filtering / `executeSql`.” Rather than pick, I treated the
“or” as a scope decision to ground: a read-only 4-agent workflow (the
`getPedigreeSource` seam + its callers; the research doc’s Rec \#4/#5;
the package’s existing file-ingestion subsystem; the LabKey fetch path +
offline testability) plus firsthand reads. The evidence came back
lopsided, and that asymmetry drove a fast, confident scope
`AskUserQuestion`: **Direction A (file provider)** is the doc’s
prioritized Rec \#4 (the walk-delegation half was S149), reuses the
exported
[`getPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedigree.md),
is additive/low-risk, and is **fully offline-deterministic**;
**Direction B (server-side filtering/`executeSql`)** is **explicitly
deferred** by the doc (benefit unmeasured; `executeSql` needs per-center
dot-notation SQL), **cannot be tested or observed without a live LabKey
server** (absent here), and carries a landmine — a naive focal-id server
filter is incompatible with the client-side connected-component walk
(filtering to focal rows leaves the walk nothing to traverse; it’s a
re-architecture, not a drop-in optimization). Owner picked A. For the
implementation contract, I did NOT invent how `"file"` should behave — I
read its siblings: the `"labkey"` branch fails soft (NULL) because it is
a flaky network fetch; the `"dataframe"` branch errors loudly on bad
input; **neither runs `qcStudbook`** (both return un-curated,
column-shaped peds — downstream
[`runQcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/runQcStudbook.md)
curates). A file is the on-disk twin of the `"dataframe"` source, so
`"file"` mirrors it: delegate to `getPedigree(fileName, sep)`, validate
id/sire/dam, return the un-curated ped, error loudly on
NULL/missing-file/missing-columns. Strict TDD held clean on the first
pass: 5 RED tests (CSV round-trip + 3 **constrained-message** error
paths + a `mockery` delegation/`sep`-threading check) failed genuinely
(`match.arg`/unused-argument + message mismatch — not false-passes; the
S148 RED-discipline lesson), GREEN added one branch + two defaulted
params (backward-compatible), REFACTOR extracted the duplicated
id/sire/dam check into a local helper preserving both exact messages.
Proactively whitelisted the words my rendered docs introduced
(`pluggable`, plus S149’s never-listed `collaterals`) in `inst/WORDLIST`
**before** `devtools::check()`, so the build came back 0/0/0 in a single
pass (no spelling-NOTE iteration). Verified: suite 0/0 (1979 passed),
lint 0, check 0/0/0, Phase-3E smoke of the real un-mocked `"file"`
branch. The provider is a new internal capability on the seam, not yet
wired to a production caller — an honest tracer-bullet (end-to-end
working + tested, but
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
still hardcodes `"labkey"`).

**Reflexes:** \[when the owner offers “A or B”, treat it as a scope
decision to GROUND, not a coin-flip — sweep both directions and bring a
recommendation backed by doc priority + reuse surface + offline
testability + blast radius; a read-only parallel workflow grounds both
while keeping the file-mutating TDD solo (the right ultracode
hybrid)\]\[weight OFFLINE TESTABILITY heavily: a direction that “cannot
be tested or observed in this environment” (needs a live
server/credential) is a weak near-term deliverable vs one that is fully
deterministic offline\]\[when extending a pluggable
seam/adapter/strategy, READ THE SIBLING branches and mirror their
contract — return shape, error-vs-fail-soft, curated-vs-raw —
consistency across providers is the spec, not invention; here `"file"`
mirrors `"dataframe"` (loud errors, un-curated return), not `"labkey"`
(fail-soft NULL)\]\[a naive server-side focal-id filter is incompatible
with a downstream client-side connected-component walk — filtering to
focal rows leaves nothing to traverse; “push the filter down” is a
re-architecture, not a drop-in\]\[adding defaulted params
(`fileName = NULL`, `sep = ","`) to an internal adapter is
backward-compatible — existing callers are unaffected\]\[when your
rendered NEWS/Rd introduces a domain word, add it to `inst/WORDLIST` in
the SAME pass so `devtools::check()` is 0/0/0 on the first run — no
spelling-NOTE iteration\]. **Apply:** any owner “A or B” scope fork; any
new provider on an existing adapter/strategy seam; any “optimize the
fetch/push it server-side” proposal that interacts with downstream
client-side traversal; any NEWS/Rd change that introduces new
vocabulary.

#### Learning 144 — To WIRE a new provider/capability to a caller, prefer adding a clean SYMMETRIC SIBLING over parameterizing a domain-named function: a new wrapper costs one export but has zero blast radius on existing signatures and avoids a naming smell (a LabKey-named function that also reads files); the “but a user can already compose it” critique is answered by PARITY — the sibling gives the new source the same first-class entry point the old source already has (the existing function is itself just a thin fetch→delegate wrapper). And a wrapper inherits its source’s contract, so do NOT copy a guard that can’t fire (no NULL guard on a loud-erroring source = no untested dead code). (S151, owner “publish + delete + wire the file provider”)

**What happened.** S150 added a `"file"` provider to the internal
`getPedigreeSource()` seam but left it capability-only —
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
hardcodes `getPedigreeSource("labkey")`, so the file source was
unreachable in production. Item 3 was to wire it to a caller. A
read-only 4-agent grounding sweep + firsthand reads surfaced four wiring
shapes with very different blast radius/value: (A) **new sibling**
[`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md);
(B) **parameterize** `getLkDirectRelatives(sourceType=…)`; (C) wire into
the **focal-animal app pipeline** (`getFocalAnimalPed`/`modInput.R`);
(D) **reconsider** (the doc framed the file source as a test/offline
provider; an offline focal-subset is already composable via
`getPedDirectRelatives(ids, getPedigree(file))`; the app already reads
pedigree files directly). I surfaced all four via a pre-RED **scope**
`AskUserQuestion` with an evidence-backed recommendation; the owner
chose **A**. The decisive arguments for A over B: B makes a LabKey-named
function (`getLk…`) read files — a genuine naming smell, not cosmetic —
and would add params to an existing signature; A costs only one new
export and yields a clean symmetric **family** — `getPedDirectRelatives`
(in-memory engine) / `getLkDirectRelatives` (LabKey wrapper) /
`getFileDirectRelatives` (file wrapper). The “composition already works,
so a sibling is duplicative” objection is real but answered by PARITY:
`getLkDirectRelatives` is ITSELF just `getPedigreeSource("labkey")` →
`getPedDirectRelatives`, i.e. a thin wrapper whose value is a named,
tested, discoverable entry point — `getFileDirectRelatives` gives the
file source that same first-class status, and routes through the
internal validated seam (id/sire/dam) that a bare composition skips.
Contract: the wrapper inherits its source’s behavior, so
`getFileDirectRelatives` has **no NULL guard** (unlike
`getLkDirectRelatives`, whose guard exists only because the LabKey
source fails soft to NULL on a flaky fetch) — the file source errors
loudly, so a NULL guard would be untested dead code; I documented the
loud-error contract instead. Strict TDD held clean on the first pass: 7
RED tests (CSV full-component read incl. collateral O2; equivalence to
`getPedDirectRelatives` over the same file; a `mockery` delegation check
pinning `getPedigreeSource(sourceType="file", fileName, sep)` then
`getPedDirectRelatives(ids, ped, unrelatedParents)` with
`unrelatedParents` threaded; constrained-message errors for NULL/missing
`fileName`, missing file, missing id/sire/dam; a `sep=";"` round-trip)
all failed genuinely — the error-contract regexps
(`fileName`/`not found`/`column`) were NOT matched by “could not find
function” (no false-pass; the S148 lesson). GREEN was a 5-line exported
wrapper (no NULL guard); `roxygenise` added
`export(getFileDirectRelatives)` + the man page (an EXPORT, unlike
S148-S150’s `@noRd` work, so NAMESPACE/man DID change — expected).
REFACTOR needed no structural code change (the wrapper is already
minimal). Verified: new file 7/7, suite 0/0, lint 0, `devtools::check()`
0/0/0, Phase-3E smoke of the real un-mocked function. Honest scope note:
this is capability/plumbing parity (a first-class file entry point), not
the higher-value app-pipeline wiring (C, deferred) that would let the
Shiny focal-animal path run offline.

**Reflexes:** \[to wire a new provider/source/capability to a caller,
prefer a clean SYMMETRIC SIBLING function over adding a `type=` param to
a domain-named function — the sibling has zero blast radius on existing
signatures and avoids the smell of a `getLk…`/`getOracle…`/etc. function
doing something off-name; the cost is one new export\]\[answer the “a
user can already compose this, so the wrapper is duplicative” objection
with PARITY, not novelty: if the EXISTING wrapper for the old source is
itself a thin fetch→delegate, a sibling for the new source is the same
legitimate pattern — its value is a named, tested, discoverable,
validated entry point, and it routes through the internal seam a bare
composition skips\]\[a wrapper INHERITS its source’s contract — do not
copy a guard that cannot fire (no NULL guard on a loud-erroring source;
the LabKey NULL guard exists only because that source fails soft) — an
unreachable guard is untested dead code; document the differing contract
in roxygen instead\]\[when several wiring shapes exist with different
blast radius/value (new sibling vs parameterize vs full-pipeline vs
reconsider), enumerate them in a pre-RED SCOPE `AskUserQuestion` with an
evidence-backed recommendation — don’t assume the owner’s example
function names the implementation site\]\[an EXPORTED new function
changes NAMESPACE + adds a man page (expect the `roxygenise` diff),
unlike an `@noRd` internal — verify the diff is confined to the export
line + the new `.Rd`\]\[a runnable `@examples` that writes a tempfile,
calls the function, and
[`unlink()`](https://rdrr.io/r/base/unlink.html)s keeps the example real
(exercised by `R CMD check`) without depending on a fixture file\].
**Apply:** any task that wires a new provider/source on an existing
adapter/strategy seam to a caller; any “add a `type`/`source` switch vs
add a parallel function” decision; any thin wrapper over a
fetch→delegate pattern; any new EXPORTED R function (expect the
NAMESPACE/man diff + the object_usage stale-install artifact, Learning
137).

#### Learning 145 — When wiring a capability THROUGH an app pipeline (not just adding a sibling fn), the wiring SHAPE is decided by concrete data-shape and error-contract mismatches found in grounding, not by abstract preference: a source-shaped transform can’t be shared by a differently-shaped source, and the new fn’s fail contract should match the CALLER’s modality (so it reuses the most existing caller code). (S152, Option C — file pedigree source through the focal-animal app pipeline)

**What happened.** S151 left
[`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md)
as a first-class file capability but unwired to the app; Option C was to
wire a file pedigree source THROUGH the focal-animal pipeline so the
Shiny app’s focal path runs offline. A read-only 4-agent grounding
sweep + firsthand reads surfaced two CONCRETE constraints that decided
the design — beyond Learning 144’s naming-smell argument for a sibling
over parameterizing. (1) **Data-shape incompatibility:**
`getFocalAnimalPed.R:76` does a POSITIONAL 7-column rename
(`c("id","sex","birth","death","departure","dam","sire")`) that is
LabKey-shaped; a file pedigree read by
[`getPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedigree.md)
carries its OWN named columns in the file’s order
(e.g. `id,sire,dam,sex,gen,birth,exit,...`), so sharing that rename
would CORRUPT a file pedigree — a concrete reason a separate
[`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
is correct, not just stylistic. (2) **Error-contract direction:**
[`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md)
errors loudly, but the app needs fail-soft. Rather than mirror the
sibling
[`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md)
(which returns an `nprcgenekeeprErr` for the DB modality), I made
[`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
return **NULL** on a bad pedigree file — matching the app’s FILE
modality (`readDataFile()` returns NULL → the existing
`is.null(rawData)` “File Read Error” handler), so the dispatch reused
the most existing caller code and added ZERO new error branches. The
deliverable was a genuine VERTICAL slice (FM \#25): new fn + `modInput`
server dispatch + an optional UI `fileInput`, end-to-end. The testable
core held under strict TDD — 7 function unit tests (offline fixtures) +
2 [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
dispatch tests, the offline test mocking `getLkDirectRelatives` to
[`stop()`](https://rdrr.io/r/base/stop.html) to PROVE the file path
never touches the EHR; the one-line UI input was Phase-3E
smoke-verified. RED was genuine (function: “could not find function”;
modInput: the EHR [`stop()`](https://rdrr.io/r/base/stop.html) fired
because dispatch didn’t exist yet — 163 existing modInput tests stayed
green as the regression guard). REFACTOR safely touched the WORKING
sibling: extracted the duplicated focal-id read into a shared internal
`readFocalAnimalIds()` used by both focal functions (behavior-neutral,
both test files + the 168-test modInput suite re-verified green); moving
the `@importFrom readxl excel_format`/`utils read.csv` tags to the
extracted helper kept NAMESPACE stable (verified the imports survived).
Verified: new file 7/7, `getFocalAnimalPed` 62, `modInput` 168, full
suite 0/0, lint 0, `devtools::check()` 0/0/0, Phase-3E smoke of the real
un-mocked function + the rendered UI input.

**Reflexes:** \[when wiring a capability THROUGH a pipeline, let
GROUNDING (not abstract design taste) pick the shape — look specifically
for a source-shaped transform (a positional rename, a date format, a
column map) that the new source would break: that concrete
incompatibility, not just a naming smell, is the decisive argument for a
separate sibling over parameterizing\]\[choose the new function’s fail
contract to match the CALLER’S modality, not reflexively its sibling’s —
here NULL (file modality → reuse the app’s existing “File Read Error”
path) beat `nprcgenekeeprErr` (DB modality), adding zero new caller
code; ask “which contract lets the caller reuse the most existing
handling?”\]\[make a function+server+UI change a real VERTICAL slice (FM
\#25): unit-test the function, `testServer`-test the dispatch,
smoke-test the one-line UI — and PROVE a “no longer needs X” claim by
mocking X to [`stop()`](https://rdrr.io/r/base/stop.html) so any X call
is a loud failure\]\[a behavior-neutral REFACTOR may touch a WORKING
sibling (extract a shared helper) when BOTH are test-covered, BUT
extracting a helper RELOCATES the calls it absorbs, so any
implementation-coupled test that
`mockery::stub(where = sibling, what = movedFn)`s those calls SILENTLY
BREAKS — the stub no longer intercepts (it patches only the `where`
function’s body), the real fn runs, and it surfaces as an ERROR not a
FAIL; re-point such tests to the new owner (`stub(where = helper, ...)`,
or test the helper directly) AND re-verify the **ERROR** column, not
just FAIL/SKIP (testthat counts a thrown error separately — a re-verify
that prints only PASS/FAIL/SKIP will miss it; `devtools::check()`
won’t)\]\[when moving `@importFrom` tags to an extracted helper, confirm
`roxygenise` keeps NAMESPACE imports intact (the symbols just need ONE
declarer in the package)\]\[R-package test files gated by top-level
`skip_on_cran()` need `NOT_CRAN=true` to actually run via
`Rscript`/`test_file` — a “0 failed, all skipped” result is the gate,
not a pass\]. **Apply:** any task wiring a capability through an app/UI
pipeline; any “new sibling vs parameterize” decision where the sources
differ in column shape or error contract; any change spanning function +
server + UI; any behavior-neutral helper extraction across two
functions; any `skip_on_cran()`-gated test run.

#### Learning 146 — After `gh pr merge`, the `git fetch` that precedes `git reset --hard origin/<branch>` MUST be verified to have SUCCEEDED before resetting — a transient network/DNS failure leaves the local `origin/<branch>` ref STALE, and `reset --hard origin/<branch>` then resets to the OLD pre-merge commit *without any error*, silently leaving the local branch BEHIND the real remote. Gate the reset on a post-fetch assertion that the just-merged commit is now an ancestor of `origin/<branch>`. (S153, publish S152 — focal-file source merge)

**What happened.** Publishing S152: pushed `wire-focal-file-source`,
opened PR \#63, watched CI to 10/10, confirmed `CLEAN`/`MERGEABLE`,
`gh pr merge 63 --merge` → merge commit `e1780c02` (verified
`state: MERGED` firsthand). Then the standard reconcile (Learning 135:
`fetch`+`reset`, not `pull`). I ran the post-merge `git fetch` and the
`git reset --hard origin/master` in the SAME command block — and the
fetch hit a transient `Could not resolve host: github.com`. Because the
fetch failed, local `origin/master` stayed STALE at the pre-merge
`cb46616e`, and `git reset --hard origin/master` happily reset local
`master` to that OLD commit, exit 0, NO error. The only reason I caught
it: the same block also asserted “is the merged commit `4f362be9` an
ancestor of `origin/master`?” and it printed **NO** — which is
*impossible* right after a confirmed merge, so the ref had to be stale.
Recovered: retried `git fetch` in a loop (succeeded attempt 1) →
`origin/master` advanced `cb46616e..e1780c02`; re-asserted `4f362be9` IS
now an ancestor (YES); `git reset --hard origin/master` → local `master`
= `e1780c02`; confirmed `R/getFocalAnimalPedFromFile.R` +
`R/readFocalAnimalIds.R` present. The trap:
`git reset --hard origin/<branch>` operates on whatever the LOCAL
remote-tracking ref currently is — a failed/skipped fetch makes it a
no-op-to-stale, not an error, so “exit 0” is NOT evidence the reconcile
worked.

**Reflexes:** \[never chain `git fetch` and
`git reset --hard origin/<branch>` as if the fetch can’t fail — verify
the fetch SUCCEEDED (its exit status / its `old..new` ref update line)
before resetting\]\[after `gh pr merge`, assert the merged commit is an
ancestor of `origin/<branch>`
(`git merge-base --is-ancestor <mergedSHA> origin/<branch>`) BOTH before
and after the reset — a NO post-merge means a stale ref, not a missing
merge\]\[retry a transient `git fetch` (DNS / `Could not resolve host`)
in a short loop rather than treating the first failure as
terminal\]\[treat “exit 0” from `git reset --hard origin/<branch>` as
necessary-not-sufficient — confirm `git rev-parse origin/<branch>`
actually advanced to the expected SHA\]. **Apply:** every post-merge
local reconcile; any `reset --hard origin/<branch>` that depends on a
just-run fetch; sandboxed/flaky-network sessions where `git fetch` can
fail transiently.

#### Learning 147 — To enrich a fail-soft boundary that swallows WHY into a bare NULL, return a DEDICATED classed error carrying the reason (do NOT overload the shared error/QC object with a different concern); wrap EVERY read the boundary performs (a read left outside the `tryCatch` is a latent UNCAUGHT throw, not fail-soft); MAP low-level `stop()` text to clean user-facing messages rather than leaking an internal `fnName(): ...` prefix; and treat a “silent empty” result (0-row / opaque NULL) as its own reported failure. (S155, richer offline-focal error messages)

**What happened.** S152 made
[`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
fail-soft by returning `NULL` → the app’s generic “File Read Error” /
“Could not read the uploaded file.” S155’s deliverable was to surface
WHY. A read-only 4-agent grounding sweep + firsthand reads found three
things that shaped the work, none of which the deliverable’s one-line
description (“missing file vs missing columns”) had named: (1) the
focal-id read at `getFocalAnimalPedFromFile.R:50` was OUTSIDE the
`tryCatch`, so a bad focal-id file threw UNCAUGHT inside `observeEvent`
— a latent app crash, strictly worse than a generic message, so “richer
errors” had to also CATCH it; (2) the specific reasons already existed
as `getPedigreeSource()` [`stop()`](https://rdrr.io/r/base/stop.html)
strings (e.g. “…must contain columns id, sire, and dam”) but were
discarded by the catch (logged only to `flog.debug`); (3) the
focal-IDs-absent case returned a SILENT 0-row data.frame. The app
already renders a per-error `Details` column (the LabKey path shows
`failedDatabaseConnection` there), so the richer “why” had a natural
home. Owner chose (pre-RED `AskUserQuestion`) a DEDICATED
`nprcgenekeeprFileErr` class over (A) adding a sibling field to the
shared `nprcgenekeeprErr`/`getEmptyErrorLst` studbook-QC object —
symmetric with `failedDatabaseConnection` but a category stretch that
widens blast radius across
`checkErrorLst`/`summary`/`processQcStudbookResult` — and over (C)
making the function throw and catching in `modInput` (smallest code, but
leaks the raw “getPedigreeSource(): …” prefix and flips the documented
fail-soft contract). Implementation wrapped BOTH reads, returned the
classed object with a `pedigreeReadReason()` mapper turning internal
stop() text into clean user-facing messages, and converted the silent
0-row walk into a reported “None of the focal IDs were found” error;
`modInput` got one [`inherits()`](https://rdrr.io/r/base/class.html)
branch mirroring the existing one. RED was genuine (function returned
NULL / threw / 0-row; modInput showed the generic detail — no “could not
find function” false-pass) with the regression guard (4 unchanged
function tests + 167 modInput tests) green. Two self-caught process
slips: (i) I first ran `lintr::lint_package(linters = default_linters)`,
which BYPASSES the project `.lintr` (camelCase + `line_length(80)` +
bans `structure`/`source`) and flooded camelCase/line-length false
positives — masking that the real count is tiny; running BARE
`lint_package()` showed exactly 4 real lints, all mine; (ii) the new
constructor’s `structure(list(...), class = ...)` tripped the project’s
`undesirable_function_linter` → switched to the package’s
`class(x) <- ...` idiom. Verified: focal 27, modInput 173, full suite
0/0 via check, lint 0, `devtools::check()` 0/0/0, Phase-3E smoke of all
7 real paths + a `testServer` Details check.

**Reflexes:** \[enriching a fail-soft boundary = return a DEDICATED
classed error object carrying the reason; do NOT overload a shared/QC
error type with a different concern — sibling-field symmetry is tempting
but stretches the category and widens blast radius across that type’s
readers\]\[audit the boundary for reads/calls left OUTSIDE the
`tryCatch` — an “uncaught throw” path masquerading as fail-soft is a
latent crash; fix it as part of “richer errors,” do not just add a
message to the already-caught path\]\[map low-level
[`stop()`](https://rdrr.io/r/base/stop.html) text to clean user-facing
messages with a small reason-mapper; never surface an internal
`fnName(): ...` prefix to the user\]\[a “silent empty” result (0-row,
opaque NULL) is a failure to REPORT, not a success — convert it to a
named error\]\[on THIS repo run BARE `lint_package()` so `.lintr`
applies — `linters = default_linters` bypasses it and floods false
positives; use `class(x) <- ...` not `structure(...)`\]\[a
behavior-neutral REFACTOR can decline to DRY working sibling branches
when touching them adds blast radius for cosmetics (Learning 145)\].
**Apply:** any “improve/enrich error messages” or “surface why X failed”
task; any fail-soft boundary that collapses distinct failures into one
opaque value; any lint run on this repo.

#### Learning 148 — When publishing a PR, `codecov/project` can red on a fractional total-coverage dip even when `codecov/patch` is 100% — diagnose before deciding: confirm it is NON-BLOCKING (master unprotected) + ADVISORY (the coverage-generating workflow passed; patch is the meaningful signal), surface the real-but-non-blocking merge call via `AskUserQuestion`, and log any config fix as its OWN issue, not a scope-crept edit. (S156, publish S155 — PR \#64)

**What happened.** Publishing S155 (PR \#64), the 8 real CI jobs (lint +
`R CMD check` ×5 incl. ubuntu-devel + pkgdown + test-coverage) all
passed and `codecov/patch` passed at **100.00% of diff hit** — but
`codecov/project` **FAILED**: “89.66% (−0.18%) vs 791c51e”. The instinct
to “merge, it’s just codecov” and the opposite instinct to “refuse, a
check is red” are both wrong; the disciplined move was to diagnose the
red, then surface the decision. Diagnosis: the repo has **two** codecov
configs at root — `codecov.yml`
(`coverage.status.project.default.threshold: 1%`) and `.codecov.yml`
(“Team/Repository Yaml” with only `round`/`range`/`precision`, **no
`status` block**). Under the intended 1% threshold (`target: auto`, base
89.84% → floor 88.84%) a −0.18% dip (head 89.66%) would **PASS**; it
failed → the 1% is **not applied** (codecov default **0%** in effect,
any dip fails), consistent with the two files conflicting. `master` is
**unprotected** (`gh api .../branches/master/protection` → 404) so
`codecov/project` is **non-blocking** (`mergeStateStatus: UNSTABLE`,
`mergeable: MERGEABLE` — `gh pr merge --merge` goes through). This is
the same class S41’s `[triage-to-root-cause]` named (“codecov status
checks are external advisory; the `test-coverage` workflow that
GENERATES coverage passed”), now with the precise config mechanism.
Surfaced it via `AskUserQuestion` with a grounded recommendation (merge
— patch 100%, dip within the *intended* tolerance, config artifact);
owner chose merge. Mid-session the owner asked whether the degradation
was a backlog item — answered by reading
BACKLOG/issues/PROJECT_LEARNINGS/ROADMAP **firsthand** (not tracked;
only the S41 reflex + a ROADMAP \>80% aspiration), then logged the
**config** fix as its own **issue \#65** rather than fixing it inline
(FM \#8 — a config change is a separate, verify-on-next-PR deliverable).
One honesty-calibration slip: I first stated “the red is a config
artifact” with more certainty than the (strong) evidence warranted
before confirming codecov’s file-precedence rule — frame such a
diagnosis as “evidence strongly indicates” from the first mention.

**Reflexes:** \[a red `codecov/project` with a green `codecov/patch` and
all real CI jobs green is almost always advisory, not a correctness
failure — diagnose to root cause before merging OR refusing\]\[before
treating a failing check as blocking, check branch protection
(`gh api .../branches/<b>/protection` → 404 = unprotected =
non-required); an UNSTABLE+MERGEABLE PR merges\]\[a fractional
total-coverage dip failing despite a configured threshold is evidence
the threshold is not applied — look for duplicate/misplaced config
files; the `target: auto` floor = base − threshold\]\[surface a
real-but-non-blocking merge decision via `AskUserQuestion`
(\[author-decision\]); do not merge silently over a red check and do not
refuse the owner’s directive\]\[log a config/infra fix as its OWN issue
(#65) — do not scope-creep it into a publish (FM \#8)\]\[when asked
whether a recurring CI annoyance is tracked, read
BACKLOG/issues/learnings/ROADMAP firsthand before answering — do not
answer from memory\]\[frame a confident-but-unconfirmed diagnosis as
“evidence strongly indicates”, not as fact, from the first mention\].
**Apply:** any publish/merge session where a codecov (or other advisory)
check reds; any “is X tracked?” question; any time you state a
root-cause diagnosis before fully confirming the mechanism.

#### Learning 149 – After ANY renv bump / self-upgrade, run a fresh-R-startup smoke test (Phase 3E): an renv self-upgrade can leave `renv/activate.R` with an UNSUBSTITUTED `..md5..` template placeholder, which throws `object '..md5..' not found` the moment `.Rprofile` sources it – breaking every R session started in the project. The lockfile looks correct and a check that does not cold-start R in the project root will not catch it. Fix by regenerating with the installed renv (`renv::activate()`), which fills in the md5; then re-source to confirm. (S157, commit the renv 1.1.4-\>1.2.3 bump)

**What happened.** Orientation found `renv.lock` + `renv/activate.R`
modified – an renv self-upgrade (1.1.4 -\> 1.2.3) the owner ran between
sessions. The task was “just commit it.” I committed the two files, then
– because the regenerated `activate.R` runs at every R startup (runtime
behavior) – ran the Phase 3E smoke test: `Rscript -e '...'` from the
project root. It FAILED: `object '..md5..' not found`, halted, from
`source("renv/activate.R")` (called by `.Rprofile`). Diagnosis: line 6
of the new `activate.R` was `attr(version, "md5") <- ..md5..` – the
literal `..md5..` template token, never substituted (the sibling
`version <- "1.2.3"` WAS substituted; only the md5 placeholder leaked).
Confirmed it a REGRESSION, not pre-existing: the old 1.1.4 `activate.R`
sourced cleanly under `--vanilla` (only warning installed!=recorded
renv, the very mismatch the bump was meant to fix); the new one threw on
`..md5..`. renv 1.2.3 was installed in the system library, so I
regenerated via `Rscript --vanilla -e 'renv::activate(project=getwd())'`
(no `.Rprofile`, so the broken file is not auto-sourced; no
restore/snapshot side effects – only `activate.R` changed, `renv.lock`
untouched). Line 6 became `attr(version, "md5") <- "1bd9f58e..."` and a
fresh `.Rprofile` startup then printed “renv: 1.2.3 – startup OK”. The
broken `activate.R` lived only in a local-unpushed commit, so I
`--amend`ed it away (the renv.lock half was already correct; only
`activate.R` needed the md5). Net: the broken artifact never entered
shared history.

**Reflexes:** \[an renv lockfile bump is a RUNTIME change (`activate.R`
runs at every R startup via `.Rprofile`) -\> Phase 3E applies:
cold-start R in the project root and watch for startup errors, do not
treat “lockfile committed” as done\]\[a leftover `..xxx..` template
token in a generated file = the generator did not substitute it;
`grep -nE '\.\.[a-zA-Z0-9_]+\.\.'` the file to find unsubstituted
placeholders\]\[regenerate renv infra with the INSTALLED renv via
`renv::activate(project=getwd())` under `--vanilla` (skips the broken
`.Rprofile`; no restore/snapshot); it rewrites only `activate.R`, not
`renv.lock`\]\[when a just-committed, still-local artifact is found
broken, `--amend` the fix in so the broken bytes never reach the remote
– do not ship-then-fix\]\[isolate regression-vs-pre-existing by sourcing
the OLD file (`git show <ref>:path`) the same way before blaming the
change\]. **Apply:** any session that touches `renv.lock` /
`renv/activate.R` (bump, self-upgrade, snapshot); any “just commit this
generated file” task – verify it actually works before calling it done.

#### Learning 150 – When a duplicate-config-file precedence bug is the diagnosis, the fix is exactly ONE file (eliminate the precedence question entirely) – and you can verify the fix AT THE CONFIG LAYER this session rather than deferring to “the next PR”: codecov exposes `https://codecov.io/validate`, which echoes the PARSED config (so you see the actual thresholds it will apply); POST a SECRET-REDACTED copy so no committed token leaves the machine. Do the complete job (remove the now-dead `.Rbuildignore` entry for the deleted file), and PRESERVE – do not silently strip – an embedded credential you happen to be rewriting (rotation is a separate owner decision; FM \#8). (S158, fix issue \#65 – consolidate the two codecov configs)

**What happened.** Issue \#65 (logged by S156 during the PR \#64
publish): the repo had **two** root codecov configs – `codecov.yml` (the
real one: `comment: false`, an embedded `token:`, and a
`coverage.status.project/patch.default.threshold: 1%` block) and
`.codecov.yml` (a junk template artifact – its comments `# Team Yaml` /
`# Repository Yaml` / `# Used in Codecov after updating` are copied
verbatim from codecov’s *documentation example* explaining YAML
layering, and it has THREE duplicate `coverage:` keys \[last-wins -\>
`round: up`, `range: 20..100`, `precision: 2`\] and **no `status`
block**). With both present the status-less `.codecov.yml` won
precedence, so codecov never applied the 1% threshold (default 0% in
effect -\> PR \#64’s -0.18% dip failed `codecov/project` despite a
100%-covered patch). **Evidence-based inventory before deleting**
(SAFEGUARDS): `git log -- .codecov.yml` proved it committed
(`58a9db26`); a repo-wide `grep -i codecov` found only two functional
references – both in `.Rbuildignore` (`^codecov\.yml$` +
`^\.codecov\.yml$`); the README hit is the badge (app.codecov.io, not a
config ref); no CI workflow names a config path (`test-coverage.yaml`
uploads `cobertura.xml` via `codecov/codecov-action@v4`, authenticating
with `secrets.CODECOV_TOKEN` – so the YAML config is read SERVER-SIDE by
codecov.io to compute the status checks, and the YAML’s embedded
`token:` is redundant with the action’s secret). Fix: rewrote
`codecov.yml` as the single source (folded in `.codecov.yml`’s display
settings, kept the 1% status block, added a why-one-file header
comment), `git rm .codecov.yml`, removed the dead `^\.codecov\.yml$`
from `.Rbuildignore`. **Verified this session, not deferred:** local
`yaml.safe_load` confirmed valid + no duplicate keys (the root cause);
`curl --data-binary @<token-redacted-copy> https://codecov.io/validate`
returned `Valid!` and echoed `threshold: 1.0` for both project and patch
– conclusive that codecov now reads and applies the 1%. Preserved the
embedded token verbatim and flagged it (redundant with the GH secret,
low-sensitivity for a public repo, but a committed credential -\>
rotation is the owner’s separate call, not a \#65 scope-creep). Direct
to `master` (CI/build config + bookkeeping, `.Rbuildignore`d out of the
package, cannot break `R CMD check`; the S156/S157 hygiene-to-master
pattern).

**Reflexes:** \[when the diagnosis is “duplicate config files -\> wrong
precedence”, the fix is ONE file – not “fix the loser”; one file makes
the precedence question moot regardless of the host’s documented
precedence order\]\[verify a config fix AT THE CONFIG LAYER instead of
deferring to “next PR” when the tool offers a validator – codecov’s
`https://codecov.io/validate` echoes the parsed thresholds; many CI
services have an equivalent (`gitlab-ci/lint`,
`circleci config validate`, `actionlint`)\]\[REDACT secrets before
POSTing a config to any external validator –
`sed 's#token:.*#token: REDACTED#'`; the schema check does not need the
real secret\]\[a config-file change that is `.Rbuildignore`d / not
package code cannot break `R CMD check`, so a feature-branch+PR adds no
CI-gating value and a config-only PR has ~no coverage delta to
demonstrate the dip-tolerance fix -\> direct-to-master (S156/S157
hygiene pattern) is correct\]\[complete the job: deleting a file means
removing its now-dead `.Rbuildignore` / `.gitignore` / manifest entries
too (anti-FM \#13)\]\[when rewriting a file that contains an embedded
credential, PRESERVE it verbatim and FLAG it – removing/rotating a
committed secret is a separate, hard-to-reverse, owner’s-call decision;
do not fold it into an unrelated config fix (FM \#8)\]\[a `.codecov.yml`
full of `# Team/Repository Yaml` comments with duplicate `coverage:`
keys is codecov’s DOC EXAMPLE pasted in by mistake, not an intentional
config\]. **Apply:** any “consolidate/duplicate config” or CI-config
fix; any task touching codecov / CI YAML; any time a configured
threshold is provably not being applied; any file rewrite that happens
to contain a secret.

#### Learning 151 – To silence a benign warning that a fail-soft boundary’s underlying read emits BEFORE the error that gets caught, add a TARGETED warning muffler at the READ SITE (`withCallingHandlers` + `invokeRestart("muffleWarning")` matched to the specific message) – do NOT broaden the shared muffler (widens blast radius across all its callers) and do NOT pre-check `file.exists()` (that changes a SHARED helper’s THROWN error and misses the exists-but-unreadable case). The muffle is control-flow-neutral: the error still propagates, so the caught classed result is unchanged – assert BOTH “no warning” AND “error still thrown”. (S159, quiet the offline focal-id read’s `read.csv` “cannot open file” warning)

**What happened.** S155 left a benign residual: a missing/unreadable
focal-id file made
[`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
return the correct classed `nprcgenekeeprFileErr`, but
[`read.csv()`](https://rdrr.io/r/utils/read.table.html) (inside
`readFocalAnimalIds()`) signals a `cannot open file '...'` WARNING *and
then* an error – and the existing `muffleIncompleteFinalLine()` wrapper
muffles only the “incomplete final line” warning, so the “cannot open
file” warning deferred to the top level and printed to the console even
though the error was already caught and reported. Grounding pinned the
leak to the FOCAL-ID read only: the pedigree read is already guarded by
`getPedigreeSource()`’s
[`file.exists()`](https://rdrr.io/r/base/files.html) pre-check (a
not-found pedigree never reaches `read.table`, so it never warns). Two
fix shapes were on the table: (a) a
[`file.exists()`](https://rdrr.io/r/base/files.html) pre-check + clean
[`stop()`](https://rdrr.io/r/base/stop.html) mirroring
`getPedigreeSource` – rejected because `readFocalAnimalIds()` is SHARED
with the online
[`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md),
so it would change that helper’s thrown error AND it misses the
exists-but-unreadable (permission) case; (b) a targeted warning muffler
at the read site – chosen (owner-approved). Added a small `@noRd`
sibling `muffleCannotOpenFile()` (a `withCallingHandlers` that
`invokeRestart("muffleWarning")`s only when `conditionMessage(w)`
matches “cannot open file”) and nested it around the existing
`muffleIncompleteFinalLine(read.csv(...))`. Because the muffler handles
only the warning, the error still propagates to the caller’s `tryCatch`
– so the classed result is byte-identical; ONLY the console noise is
gone. The shared `muffleIncompleteFinalLine` and its 4 call sites stayed
untouched (Learning 145 – do not broaden working shared code for a
one-site need). RED asserted BOTH facets: a boundary test
(`expect_no_warning` + still-classed-error) AND a helper test (still
throws, via an explicit `withCallingHandlers`/`tryCatch` recorder, +
asserts no warning) – both failed for the right reason (warning leaked;
function resolved, 0 errored, Learning 145), then passed GREEN, and the
pre-existing test’s leaked-warning count dropped 1 -\> 0 (independent
confirmation). Incidental: the standard `document()` step re-synced a
stale `man/getFocalAnimalPedFromFile.Rd` (an S155-era `@return` reword
never re-documented; pure text reflow, no semantic change) – included +
flagged, not scope creep.

**Reflexes:** \[a fail-soft boundary that already returns a classed
error can STILL leak a console warning – the underlying
`read.*`/[`file()`](https://rdrr.io/r/base/connections.html) signals a
warning BEFORE the error; muffle the warning, the error still
flows\]\[muffle at the READ SITE with a message-matched
`withCallingHandlers`/`invokeRestart("muffleWarning")`, NOT by
broadening a shared muffler (blast radius across its callers) and NOT by
[`file.exists()`](https://rdrr.io/r/base/files.html)-pre-checking a
SHARED helper (changes its thrown error; misses
exists-but-unreadable)\]\[a warning muffle is control-flow-neutral –
PROVE it: assert BOTH “no warning” AND “error/return unchanged”, so a
later refactor that accidentally swallows the error fails the
test\]\[when two siblings share an internal helper, fix the one site
without touching the helper unless BOTH need it (Learning 145)\]\[a
stale generated artifact surfaced by the standard `document()` step is a
sync, not scope creep – include it and flag the pre-existing drift\].
**Apply:** any “quiet a benign warning” / “silence console noise” task
on a fail-soft read path; any place a caught error is preceded by a
leaked
`read.csv`/`read.table`/[`file()`](https://rdrr.io/r/base/connections.html)
warning.

#### Learning 152 – A config/threshold fix verified only AT THE CONFIG LAYER (e.g. codecov’s `/validate` echoing the parsed threshold, S158/Learning 150) is verified but not yet CONFIRMED: the live signal is the first real PR whose coverage delta actually exercises the check. When a prior session “verified but deferred confirmation to the next PR”, that next publish IS the confirming experiment – watch the SPECIFIC check that was failing (not just “all green”), and record the before/after so a multi-session infra saga (diagnose -\> fix -\> confirm) is auditably closed. (S160, publish S159 – PR \#66, the live \#65 confirmation)

**What happened.** S158 fixed issue \#65 – two root codecov configs
meant the intended 1% threshold was not applied (default 0% in effect,
so any total-coverage dip failed `codecov/project`; empirically PR
\#64’s -0.18% dip with a 100%-covered patch) – by consolidating to a
single `codecov.yml`, and verified it at the config layer (codecov’s
`https://codecov.io/validate` echoed `threshold: 1.0` for project and
patch). But Learning 150 itself conceded the full PR-level confirmation
could only come from “the next PR with a coverage delta.” S160 published
S159’s warning-muffle, which adds 2 tests (a small positive coverage
delta) – the first coverage-changing PR since the fix. The standard safe
publish ran (pre-flight: clean fast-forward, `merge-tree` 0 conflicts,
exact-commit + 8-file check; pushed; opened PR \#66; watched all checks
via a background `gh pr checks 66 --watch`), and `codecov/project` came
back **PASS** – versus its **FAIL** on PR \#64 under the old two-config
state. That is the live experiment confirming the \#65 fix end-to-end
(S156 diagnosed -\> S158 fixed + config-layer-verified -\> S160
PR-confirmed). The merge itself used full carried discipline
(don’t-merge-blind fresh re-check; `AskUserQuestion` for the
irreversible merge; Learning-146 ancestor-gated `reset --hard`;
verified-merged-before-delete branch cleanup with a `gh api` 404 check)
– no new wrinkle there; the new lesson is purely about *when a config
fix counts as confirmed*.

**Reflexes:** \[a config/threshold fix verified only at the config layer
is verified, NOT yet confirmed – the confirming signal is the first live
PR whose delta exercises the check; when a prior handoff says “verified,
confirm on the next PR”, that next publish IS the experiment, so run it
deliberately\]\[when publishing the PR that confirms a prior fix, watch
the SPECIFIC check that was failing (here `codecov/project`), not just
“all green” – and record the before/after (PR \#64 FAIL -\> PR \#66
PASS) so the loop is auditably closed\]\[a multi-session infra saga
(diagnose -\> fix -\> confirm) is only “closed” once the live
confirmation lands; update the standing gotcha from “X will keep failing
until fixed” to “X confirmed resolved (PR \#N)” so successors stop
carrying a stale warning\]. **Apply:** any session that publishes the
first coverage/threshold-changing PR after a CI-config fix; any
“verified at the config layer, confirm on next PR” carryover; closing
out any multi-session infra fix.

#### Learning 153 – To DOCUMENT/EXPOSE an already-exported-but-undocumented function, the right artifact is a WEBSITE-ONLY Quarto article in the existing scripting series (`vignettes/articles/*.qmd`, which is `.Rbuildignore`d) – NOT a NEWS line, and NOT a shipped CRAN vignette unless the owner asks. Copy a sibling article’s EXACT shape (`genetic-value-analysis.qmd`: YAML `title:`-only, a hidden `setup` chunk `knitr::opts_chunk$set(collapse=TRUE, comment="#>")`, `## X {#sec-x}` sections, then `Key arguments` + `See also` + `References`), and ALSO add the function to `inst/_pkgdown.yml`’s reference list(s) so `pkgdown` does not warn “topic missing from index”. Verify the EXECUTABLE doc in two steps: (1) run every intended chunk in-session under `pkgload::load_all` to confirm REAL outputs BEFORE writing prose; (2) render via `quarto render <file>.qmd` as the doc build-equivalent, then REMOVE the render litter (`.html`, `_files/`, the quarto-created `.gitignore`, `.quarto/`) – only the `.qmd` is tracked. A website-only article earns a CHANGELOG entry but NO NEWS entry (NEWS is for SHIPPED package changes; S116 precedent + \[\[news-vs-changelog\]\]), which also sidesteps the NEWS smart-quote/en-dash render traps (132/139) – keep the `.qmd` pure ASCII regardless. (S161, document/expose the offline focal-animal workflow)

**What happened.** Owner picked the S159/S160-queued 2nd item:
document/expose the offline focal workflow. Grounding (a read-only
4-agent sweep) found
[`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
was already EXPORTED with a full man page but covered by zero
vignette/article AND missing from the `inst/_pkgdown.yml` reference
index – so “expose” meant DISCOVERABILITY (docs), not a NAMESPACE/code
change (TDD therefore N/A throughout). The sweep mapped: the app
exposure (Input tab “Focal animals only; pedigree built from database”
radio -\> the “Optional: Pedigree File (build offline; no database)”
upload, `modInput.R:331-343`; an `nprcgenekeeprFileErr` surfaces as a
“File Read Error” row); two parallel doc systems (4 website-only `.qmd`
scripting articles vs 4 shipped `.Rmd` CRAN vignettes); the exact input
formats (focal-id file: first column = IDs; pedigree file: requires
`id`/`sire`/`dam`) and all SIX `nprcgenekeeprFileErr` messages; and the
shipped example pair (`focalAnimalsShortList.csv` +
`ExamplePedigree.csv`). A pre-RED scope `AskUserQuestion` offered three
homes (website article / new CRAN vignette / section in
`a2interactive.Rmd`); owner chose the **website article**. Wrote
`vignettes/articles/offline-focal-animal-workflow.qmd` (5th in the
series), cross-linked it from `studbook-quality-control.qmd`’s See also,
and added `getFocalAnimalPedFromFile` to BOTH `inst/_pkgdown.yml`
reference lists. Verified every chunk under `load_all` FIRST (focal
`"C"` -\> 4 rows incl. the full-sibling collateral `D`; the shipped 5-ID
list -\> a **2922 x 11** connected component; all 6 error messages
reproduced verbatim) THEN `quarto render` (all 19 steps clean; HTML
contained the outputs; `.qmd` pure ASCII; no unresolved `@sec-` ref
after I swapped the one prose cross-ref to plain text), then removed the
render litter. No NEWS line (website-only; S116 precedent).

**Reflexes:** \[a task to “document/expose function X” where X is
already exported = a DISCOVERABILITY gap (vignette/article + reference
index), not a code change – confirm export status FIRST; if exported,
TDD is N/A (pure docs)\]\[default home for “script function X directly”
docs on this repo = a NEW website-only `vignettes/articles/*.qmd`
mirroring `genetic-value-analysis.qmd`; offer the owner the home
(website article vs shipped CRAN vignette vs extend an existing
vignette) as a pre-RED scope `AskUserQuestion` – it changes who can read
it and the `R CMD check` surface\]\[an exported function absent from
`inst/_pkgdown.yml` makes `pkgdown` warn “topic missing from index” –
add it next to its sibling when you document it\]\[verify an executable
doc in two steps: run EVERY chunk in-session under `load_all` to capture
real outputs before writing prose, THEN `quarto render` as the
build-equivalent – and CLEAN the litter (`.html`, `_files/`, quarto’s
`.gitignore`, `.quarto/`); only the `.qmd` is tracked\]\[website-only
article -\> CHANGELOG yes, NEWS no (S116 precedent +
\[\[news-vs-changelog\]\]); keep the `.qmd` ASCII to dodge the
NEWS-class smart-quote/en-dash traps\]\[a tiny self-contained
[`tempfile()`](https://rdrr.io/r/base/tempfile.html) example FIRST
(reader sees the structure, install-independent) THEN the realistic
shipped pair is the clearest worked-example pattern\]. **Apply:** any
“document/expose function X”, “write a vignette/article”, or “add an
example for X” task on this repo.

#### Learning 154 – When the deliverable is “make X CONSISTENT across a SET of parallel docs/files”, it is ONE coherent deliverable (single theme + single definition-of-done), NOT bundling – but only if the items genuinely share that theme; stitching unrelated small carryovers together IS bundling (FM \#18/#25). Do it in this order: (1) build the actual coverage MATRIX first by firsthand reads (FROM-\>TO) so “consistent” is a measurable target, not a vibe; (2) MATCH the existing convention – do not redesign the mechanism (here: bold-title prose mentions, not hyperlinks; switching to links would be a separate out-of-scope mode switch); (3) pick a single canonical order + a per-item description policy so consistency is verifiable, not just asserted; (4) verify completeness with a GREP over the matrix, not by eyeballing; (5) the build-equivalent is proportionate to WHAT CHANGED – a prose-only edit needs the markdown-\>HTML render to pass, not a re-derivation of unchanged simulation outputs. (S162, cross-link the five `vignettes/articles/*.qmd` scripting articles)

**What happened.** Orientation surfaced five carried-over “suggested
next” items, several tiny; the owner asked whether more than one could
be done in a session under 1-and-done. Answered from the protocol’s OWN
rules (`SESSION_RUNNER.md`): “1 and done” constrains ONE *deliverable*,
not one file/commit – the test is COHERENCE, not size. So several small
items can ship together ONLY if they collapse into one deliverable with
a single definition-of-done. Among the five, only the
documentation-completeness items cohered (the back-link follow-on S161
flagged, generalized to a full consistency pass); the NEWS render fix,
the codecov-token removal, and any feature issue are each their own
deliverable in their own workstream – stitching them would be exactly
the bundling FM \#18/#25 forbids. Owner picked the cross-link pass.
Grounding read all five articles and built the real See-also matrix: it
was uneven – **Forming Breeding Groups linked to ZERO siblings**,
Offline Focal and Genetic Value one each, Studbook QC and Age-Sex
Pyramid three; two articles named siblings only as bare functions, not
as the article. The five files already shared a convention –
**bold-title prose mentions, not hyperlinks** (S161 had deliberately
swapped its one crossref to plain text) – so the consistent fix was to
MATCH that convention and complete coverage, NOT to convert everything
to links (that would be a redesign, a mode switch beyond “make
consistent”). Set a single canonical workflow order (QC -\> Offline -\>
GV -\> Breeding -\> AgeSex, each omitting itself), gave each sibling
bullet a short relationship line naming the article + its primary
function, and preserved each article’s own functions +
[`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md).
Verified with a grep that each See-also names exactly its four siblings
(5/5), confirmed pure ASCII, ran `quarto render` (all five HTML
produced, sibling links present, zero error markers – and the heavy R
chunks executed even though I passed `--no-execute`, so I got a full
render), then removed the render litter with `git clean -fd` +
`git clean -fdX` on the articles dir (which also swept a pre-existing
empty `_files` litter dir). Direct to `master` (website-only docs;
S160/S161 pattern), CHANGELOG not NEWS (S116 +
\[\[news-vs-changelog\]\]).

**Reflexes:** \[a “make X consistent across a set” deliverable is ONE
coherent unit (shared theme + single definition-of-done), not bundling –
but answer the owner’s “can I batch these?” from the protocol’s own
COHERENCE test, not size: several items ship together only if they
collapse into one definition-of-done\]\[before editing for
“consistency”, build the actual coverage MATRIX (FROM-\>TO) by firsthand
reads so the target is measurable – “consistent” without a matrix is a
vibe, and you will miss the worst offender (here one article linked to
zero siblings)\]\[match the EXISTING convention, do not redesign the
mechanism while “making it consistent” – bold-prose-vs-hyperlink,
ordering, bullet style are all conventions to MATCH; switching them is a
separate mode switch needing its own approval\]\[verify completeness
with a grep over the matrix (each item references exactly its N
siblings), not by eyeballing the diff\]\[scope the build-equivalent to
what changed: a prose-only docs edit is validated by the markdown-\>HTML
render passing with the new text present + zero error markers – you do
NOT need to re-derive unchanged executable
outputs\]\[`quarto render --no-execute` (quarto 1.7.33) did NOT skip
chunk execution in this articles project – do not rely on it to dodge
heavy sims; either accept the full render or use `freeze`\]. **Apply:**
any “make X consistent / uniform across these files”, “cross-link these
docs”, “standardize the See-also / front-matter / headers” task; any
time an owner asks whether several small items fit one 1-and-done
session.

#### Learning 155 – A recurring render-time artifact that a standing gotcha tells you to “work around on every render” should be eliminated at the RENDERER-CONFIG SOURCE so the workaround is never needed again – this turns a standing gotcha into a CLOSED one. Here two NEWS render traps that S139/S147 had been hand-mitigating every time were fixed permanently with two `NEWS.Rmd` `github_document` knobs: `html_preview: false` (no top-level `NEWS.html` byproduct -\> no “non-standard file at top level” `R CMD check` NOTE; Learning 139) and `md_extensions: "-smart"` (pandoc’s `smart` extension OFF -\> source `--` and straight quotes render to ASCII `--`/`"` instead of en-dash/curly; Learning 132). Three execution rules that made it clean: (1) VERIFY both knobs on throwaway `/tmp` Rmds BEFORE touching anything tracked – prove `-smart` yields ASCII output and `html_preview:false` suppresses the `.html`; you then present a verified plan, not a hypothesis. (2) Smart-off fixes FUTURE renders, but pre-existing LITERAL curly quotes baked into the SOURCE survive a re-render – find them with `grep -nP '[^\x00-\x7F]'` on the `.Rmd` (here `NEWS.Rmd:189`/`:213`) and fix each at the source. (3) When re-rendering to clean historical bytes, prove the regenerated file is CONTENT-INVARIANT by normalizing the OLD file’s smart-bytes back to ASCII (`perl -CSD -pe 's/\x{201C}|\x{201D}/"/g; s/\x{2018}|\x{2019}/\x27/g; s/\x{2013}/--/g; s/\x{2014}/---/g; s/\x{2026}/.../g'`) and diffing vs the new render – the residual should be EMPTY or only a benign SOFT-WRAP shift (an en-dash is 1 column, `--` is 2, so a line near pandoc’s ~79-col wrap can break one word later – same words, different newline; NOT a content change). The NEWS-encoding change earns a CHANGELOG entry, NOT a NEWS line (NEWS infrastructure is not a user-facing package change; \[\[news-vs-changelog\]\]). (S163, permanent NEWS render fix)

**What happened.** Orientation’s S162 handoff listed “Permanent NEWS
render fix” as the first suggested-next, naming the exact mechanism
(`html_preview:false` + smart-off, ends both Learning 139 and 132,
cleans the pre-existing curly bytes). Owner picked it. Grounding read
`NEWS.Rmd` + `NEWS.md` firsthand and Learnings 132/139 verbatim: the
`github_document` output was `github_document: default` (so
`html_preview` defaulted true; the dev had to delete `NEWS.html` after
every render) and `NEWS.md` carried **40** non-ASCII lines (curly
quotes + en-dashes from pandoc smart). Crucially,
`grep -P '[^\x00-\x7F]'` on the SOURCE showed `NEWS.Rmd` itself had 2
lines (`:189` `lint_dir(`+curly`R`+curly`)`, `:213` curly `Y`/`YES`/…)
with LITERAL curly quotes – a smart-off re-render would leave those, so
they needed their own source edit. Verified the mechanism on two `/tmp`
Rmds before touching the repo: default output produced `– none`/`“Y”`,
while `md_extensions:"-smart"` + `html_preview:false` produced ASCII
`-- none`/`"Y"` and NO `.html`. Then on branch `fix-news-render`: 4
edits to `NEWS.Rmd` (the 2 YAML knobs + the 2 source-curly lines),
re-rendered
([`rmarkdown::render`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)).
Result: `NEWS.md` 0 non-ASCII (was 40), no `NEWS.html` created, title
block reproduced faithfully. Content-invariance proof: normalized the
old `NEWS.md`’s smart-bytes to ASCII and diffed vs the new render -\>
the ONLY residual was one soft-wrap
(`Checking (--as-cran --run-donttest) ... on my system.` – `--as-cran`
is 4 cols wider than the old `–as-cran`, so pandoc wrapped “system.” to
the next line; identical words). Package build-equivalent:
`R CMD build` + `R CMD check --as-cran` (exit 0) -\> tarball has
`NEWS.md` only (no `NEWS.Rmd`/`NEWS.html`), no top-level-`NEWS.html`
NOTE, full `testthat` suite OK; the 2 WARNINGs + vignette-index NOTE
were artifacts of my fast `--no-build-vignettes` build, the rest
standing (archived-on-CRAN/new-submission) – zero NEWS-related findings.
CHANGELOG not NEWS (S139 precedent + \[\[news-vs-changelog\]\]).

**Reflexes:** \[eliminate a recurring render/tooling artifact at the
renderer-config SOURCE rather than re-applying the manual workaround
each time – a standing “delete X / reword Y every render” gotcha is a
signal to close it permanently\]\[verify a tooling-config fix on
throwaway files BEFORE touching tracked files, so the phase gate
presents a proven plan not a hypothesis
(\[\[consult-project-source-of-truth\]\]/verify-first)\]\[a `smart`-off
re-render fixes FUTURE output but pre-existing LITERAL non-ASCII baked
into the SOURCE survives – grep the SOURCE for `[^\x00-\x7F]` and fix
each at the source\]\[prove a bulk re-render is content-invariant by
normalizing the OLD file’s smart-bytes to ASCII and diffing vs the new
render; expect EMPTY or only a benign soft-wrap shift (en-dash 1 col vs
`--` 2 cols moves a wrap), never new/changed words – Learning 132’s
“confirm the diff is confined” made rigorous\]\[a NEWS
encoding/infrastructure change is CHANGELOG-not-NEWS
(\[\[news-vs-changelog\]\])\]\[scope the build-equivalent honestly: a
`--no-build-vignettes` fast check introduces vignette-index WARNINGs
that are build-flag artifacts, not regressions – say so rather than
treating them as findings, and note CI’s full build won’t have them\].
**Apply:** any “fix the render config / make the rendered output clean”
task for an `.Rmd`/`.qmd`/templated generated file; any standing gotcha
of the form “after rendering X, delete/reword Y” – prefer closing it at
the config source; any bulk re-render where you must prove no content
changed.

#### Learning 156 – When “make X a FIRST-CLASS column/field” lands in a pipeline that ALREADY retains unknown inputs (here `qcStudbook()` keeps any unrecognized header as a trailing `novelCol` via `intersect(getPossibleCols(), cols)` then `c(cols, novelCols)`), the discriminator between first-class and retained-but-orphaned is CANONICAL ORDER + DECLARED TYPE, never mere presence – so the RED tests must assert PLACEMENT (the new column sorts into its registry position, e.g. immediately after `sex`) and TYPE-COERCION (a factor input becomes character), because “is in the output” and “is character (from a CSV read)” already pass for a novelCol and would be false-GREEN. The minimal GREEN was two edits: add `"species"` to `getPossibleCols()` (which alone fixes presence + ordering, since the intersect orders by the registry) and one `if (any("species" %in% cols)) sb$species <- as.character(sb$species)` beside the sibling optional-column conversions (which fixes the factor case). (S165, issue \#46 item 1 – species as a first-class column)

**What happened.** Owner picked issue \#46 (“make species a first-class
attribute”). \#46 has 3 parts; a read-only 4-agent grounding workflow +
firsthand reads established that only item 1 (the species column) is
self-contained: item 2 (species-keyed gestation) builds on it, and item
3 (species-keyed postnatal co-housing window) is **premature** – its
only consumer, \#28’s colocation/missing-dam model, has **zero code**
(S76 spec + S77 ratification only; no
colocation/co-housing/postnatal/location logic anywhere in `R/` or
`tests/`). **Dependency-direction correction (owner-flagged):** I
initially framed “item 3 depends on \#28”, but the issue’s own
“**Dependency for:** \#28” wording means **\#28 depends on \#46**, not
the reverse (and \#28 v1, rhesus-only, does not block on \#46 at all).
The only thing that read like a reverse dependency was item 3’s phrasing
“the multi-species *generalization of* \#28’s missing-dam parameter” –
but a generalization of an UNBUILT thing is premature groundwork, not a
blocking dependency. Owner chose item 1 only. Grounding facts that
shaped the tests: a `species` column already SURVIVES ingestion as a
trailing novelCol (retained, untyped, ordered last), so the new behavior
to pin is ORDER (registry placement) and TYPE; the shipped
`deidentified_jmac_ped.csv` is the only example data with a species
column (all “JAPANESE MACAQUE”) but its full
[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
run HALTS on a pre-existing, \#46-unrelated “Subject(s) listed as both
sire and dam” QC error – so the real-data RED test asserts on the IMPORT
COLUMN-MAPPING layer
([`fixColumnNames()`](https://github.com/rmsharp/nprcgenekeepr/reference/fixColumnNames.md) +
`intersect(getPossibleCols(), fixed)`) rather than the full pipeline,
which both dodges the unrelated defect AND is exactly the
“recognized/retained as first-class” requirement. Two test-authoring
bugs surfaced in the first RED run and were fixed BEFORE declaring RED
clean (the discipline that RED must fail for the RIGHT reason): (1)
[`fixColumnNames()`](https://github.com/rmsharp/nprcgenekeepr/reference/fixColumnNames.md)
lowercases every header, so a `zNovelNote` fixture column became
`znovelnote` and [`match()`](https://rdrr.io/r/base/match.html) returned
NA – fixed by using a lowercase novel name; (2) the full-pipeline JMAC
test errored on the sire/dam conflict – replaced with the column-mapping
assertion. RED then failed cleanly on all 6 expectations for the right
reason; GREEN (the 2 edits above) made them pass with the full suite at
0 failed / 0 errors; REFACTOR added a roxygen `\item{species}` +
`document()` (confined to `man/getPossibleCols.Rd`). Scoped OUT
(deferred, evidence-based, not guessed): speculative
[`fixColumnNames()`](https://github.com/rmsharp/nprcgenekeepr/reference/fixColumnNames.md)
aliases (the literal “species” header already normalizes) and the LabKey
`mapPedColumns` species mapping (the source column name is unknown).

**Reflexes:** \[to “make X first-class” in a pipeline that already
RETAINS unknowns, pin the discriminator – canonical ORDER + declared
TYPE – not presence; presence/character-from-CSV already pass for a
retained novelCol and would be a false-GREEN\]\[read the dependency
ARROW from the issue’s own words: “Dependency FOR Y” means Y depends on
this, not this depends on Y – state it back and let the owner correct
before scoping (\[\[observation-vs-decision\]\])\]\[a
“multi-species/general version of an UNBUILT single-species thing” is
premature groundwork for an absent consumer -\> defer, do not treat as a
blocking dependency; confirm the consumer’s code exists before
generalizing it\]\[a real example dataset can carry an unrelated
PIPELINE-HALTING defect (here a sire/dam conflict) – test the LAYER YOU
CHANGED (column mapping) not the whole pipeline run, which also keeps
the test honest about what it
proves\]\[[`fixColumnNames()`](https://github.com/rmsharp/nprcgenekeepr/reference/fixColumnNames.md)
lowercases ALL headers -\> test fixtures for “novel”/passthrough columns
must use lowercase names or
[`match()`](https://rdrr.io/r/base/match.html) silently returns NA – a
spurious RED, not a real one\]\[RED must fail for the RIGHT reason:
re-run, read each failure, and fix test-authoring bugs (NA matches,
data-defect errors) before declaring RED clean\]. **Apply:** any
“promote/recognize field X as first-class / canonical” task, especially
where unknown inputs are already passed through; any feature whose scope
item references “the multi-species/general version of” another issue –
check that issue’s CODE state first; any test that ingests a real
shipped dataset end-to-end.
