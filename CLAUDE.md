## SESSION PROTOCOL — FOLLOW BEFORE DOING ANYTHING

**Read and follow `SESSION_RUNNER.md` step by step.** It is your operating procedure for every session. It tells you what to read, when to stop, and how to close out.

**Three rules you will be tempted to violate:**
1. **Orient first** — Read SAFEGUARDS.md → SESSION_NOTES.md → check GitHub Issues (or BACKLOG.md if no repo) → run `methodology_dashboard.py` → git status → report findings → WAIT FOR THE USER TO SPEAK
2. **1 and done** — One deliverable per session. When it's complete, close out. Do not start the next thing.
3. **Auto-close** — When done: evaluate previous handoff, self-assess, document learnings, write handoff notes, commit, report, STOP.

`SESSION_RUNNER.md` documents known failure modes and their countermeasures. The protocol compensates for documented tendencies to skip orientation, skip close-out, and continue past the deliverable.

---

# nprcgenekeepr

<!-- budget:protected -->
## Project Overview

**nprcgenekeepr** is an R package implementing Genetic Tools for Colony Management. Initially conceived and developed as a Shiny web application at the Oregon National Primate Research Center (ONPRC), it has been enhanced to have more capability as a Shiny application and to expose functions for use either interactively or in R scripts.

This work has been supported in part by NIH grants P51 RR13986 to the Southwest National Primate Research Center and P51 OD011092 to the Oregon National Primate Research Center.

### Package Structure

- `R/` - Package functions and Shiny modules (`appUI.R` + `appServer.R` + `mod*.R` are the canonical modular Shiny application, launched by `runGeneKeepR()`)

### Running the Application

```r
library(nprcgenekeepr)
runGeneKeepR()   # runModularApp() is a deprecated alias that calls this
```

### Key References

Vinson, A; Raboin, MJ. "A Practical Approach for Designing Breeding Groups to Maximize Genetic Diversity in a Large Colony of Captive Rhesus Macaques (*Macaca mulatta*)" *Journal of the American Association for Laboratory Animal Science*, 2015 Nov, Vol.54(6), pp.700-707
<!-- /budget:protected -->

---

## Development Process Contract

This project uses **Strict Test-Driven Development (TDD)**.
Deviation is a defect.

### TDD Rules:
- Write tests before implementation code
- Each feature branch should include tests
- Ensure both happy paths and all non-happy paths are tested
- Ensure potential edge cases are tested
- Maintain >80% code coverage for new code
- Run full test suite before merging
- Tests should be fast, isolated, and deterministic

### TDD Phases

#### RED
- Write tests only
- Tests must fail
- No implementation code
- No production logic
- No refactoring

#### GREEN
- Write the minimum implementation required to pass tests
- No new functionality
- No refactoring
- No optimization

#### REFACTOR
- Improve structure and readability
- No behavior changes
- All tests must remain passing

### Enforcement Rules

- The assistant MUST declare the current phase at the top of every response.
- The assistant MUST refuse requests that violate the current phase.
- The assistant MUST ask permission before transitioning between phases — via `AskUserQuestion`, per the **Phase-gate format** below.
- Skipping phases is forbidden.
- Writing implementation code during RED is a violation.
- Ensure potential edge cases are tested
- Maintain >80% code coverage for new code
- Run full test suite before merging
- Tests must be fast, isolated, and deterministic

### Phase-gate format

The "ask permission before transitioning" rule above is satisfied with **`AskUserQuestion`** (the structured prompt), **not** a prose question, at **every** phase transition — so the choice and the exact planned actions are explicit and logged. This is a followed project convention, **not** a `settings.json` hook: there is no "phase transition" harness event, and a hook cannot author options describing the specific next-phase actions.

Each gate is **one** `AskUserQuestion` with this shape (the harness auto-appends a free-text "Other"):

- **Header:** `TDD: <FROM>→<TO>` (e.g. `TDD: RED→GREEN`).
- **Option 1 — "Yes, proceed to <TO>":** spell out the *exact* actions the next phase will take — files, the concrete change, how the failing tests / completion criteria get satisfied — then the downstream verification (full suite, lint, the build-equivalent per "Build / Test / Verify", and any E2E/integration).
- **Option 2 — "Hold / <alternative>":** a concrete alternative — pause to review the RED tests / classification first, OR a narrower next-phase scope (e.g. "docs only; leave X as-is").

**Gated transitions:** `PRE-RED→RED`, `RED→GREEN`, `GREEN→REFACTOR`. A pre-RED **scope or approach** decision that is the author's to make (e.g. which functions are in scope) is a *separate* `AskUserQuestion`, posed before declaring RED. The declare-phase-at-top-of-response and refuse-on-violation rules are unchanged.

### Error Handling

If a response violates TDD:
1. The assistant must acknowledge the violation.
2. The assistant must correct itself.
3. The assistant must reissue a compliant response.

This file supersedes general coding instincts.

---

## Build / Test / Verify

The build-equivalent for this R package (relocated here from `SAFEGUARDS.md` during the 2026-05-31 methodology update so the synced `SAFEGUARDS.md` stays byte-identical to canonical; see `SAFEGUARDS.md` "Verify the Build Equivalent"):

| Purpose | Command | Pass criteria |
|---|---|---|
| Full package check | `devtools::check()` or `R CMD check` | No errors, no warnings, no notes (ideally) |
| Test suite | `devtools::test()` or `testthat::test_local()` | All tests pass |

**Fast single-file test:** `Rscript -e 'Sys.setenv(NOT_CRAN = "true"); suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_X.R", reporter="summary")'` (sets `NOT_CRAN` first — without it, a file with a top-level `skip_on_cran()` silently bare-skips instead of running; see `PROJECT_LEARNINGS.md` Learning 417.)

**Clean regression read:** `Sys.setenv(NOT_CRAN = "true"); pkgload::load_all(".", quiet=TRUE); as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))`, then check `sum(failed)` **and** `sum(error)` directly, unfiltered. (`load_all()` must run first — without it this command produces mass-spurious failures unrelated to anything actually broken; see Learning 377. `NOT_CRAN` must be set too — without it, any file with a top-level `skip_on_cran()` [e.g. `test_wordlist_coverage.R`] silently bare-skips and its failure vanishes from `sum(failed)` instead of counting; see Learning 417 and Learning 594, which hit exactly this omission in this command.) **No `test-app-*`/`test-e2e-*` exclusion filter — removed S624 (2026-08-23).** Learning #2/#4 (Sessions 3-4) once documented those files as pre-existing baseline noise because `create_test_app()` was undefined at the time, so every such file errored or was skipped as a structural artifact rather than a real failure; `create_test_app()` has been defined (`tests/testthat/helper-shinytest2.R:200`) for a long time, and unfiltered runs report 0 failed/0 error across those files for weeks (S622/S623). A blanket `!grepl("test-app-|test-e2e-", file)` exclusion is now a live risk, not a convenience — it would silently hide a real regression landing in exactly those files, which issue #163 (S623) nearly demonstrated. Do not reintroduce the pattern; if a specific file ever develops a genuine, currently-true reason for exclusion, name that file and the reason explicitly in a fresh entry rather than reviving a permanent file-name-pattern amnesty. (Learning #2/#4 themselves are left unedited as the frozen historical record of what was true in Sessions 3-4.)

**`renv::snapshot()` always needs `dev = TRUE` in this project.** `renv/settings.json` sets `snapshot.type: "explicit"`, under which a **plain** `renv::snapshot()` only scans `DESCRIPTION`'s `Imports`/`Depends`/`LinkingTo` — every `Suggests`-only package (`testthat`, `dplyr`, `mockery`, `roxygen2`, `shinytest2`, `shinyBS`, `devtools`, `quarto`, plus their transitive deps like `pkgload`/`chromote`) is silently dropped from `renv.lock` on an ordinary snapshot, only to resurface as a missing-package crash the next time someone hits `renv::restore()` (a fresh clone, an R-version bump). Always run `renv::snapshot(dev = TRUE)` (and `renv::status(dev = TRUE)` to check consistency) instead of the bare form. See `PROJECT_LEARNINGS.md` Learning 473/476 for the root-cause diagnosis.

---

## Project-Specific Methodology Adaptations

*Additions and overrides to the base methodology at `SESSION_RUNNER.md` and `SAFEGUARDS.md` (synced from https://github.com/rmsharp/methodology, not project-owned). The base files govern unless explicitly overridden here. **Do not edit the synced files** — put customizations here so `bin/sync` stays friction-free (see BOOTSTRAP "Updating an existing project").*

### Additional Phase 0 steps

**Priorities list at Phase 0 step 7 (report findings, 2026-07-09):** render the "open
items" portion of the orientation report as a numbered, scannable priority list, not
prose -- sourced from `BACKLOG.md`'s per-item `(READY | BLOCKED | DECISION NEEDED,
Effort S|M|L)` tags (and open GitHub issues/PRs not yet mirrored into `BACKLOG.md`).
Format (adapted from a sibling project's convention):

```
Current priorities (from BACKLOG, in the order Session N left them):
1. [color] Title (READY, Effort M): one-line concrete context + any decision the
   picking session needs to make first.
2. [color] Title (BLOCKED -- <what it's blocked on>, Effort L): ...
3. Lower priority: short comma-separated items with no full write-up.
4. Informational: open PRs / issues not yet in BACKLOG.md -- untouched, FYI only.
```

- Color: :red_circle: reserved for something explicitly NOT a routine session's
  pickup (needs its own scoping/planning session first, or is otherwise high-stakes);
  :orange_circle: for ready-now, normal-priority items; no marker for "Lower
  priority"/"Informational" line items.
- `READY` = the next session can start with no unresolved decision. `BLOCKED` or
  `DECISION NEEDED` must name the blocker/decision in the one-line context, not just
  the tag.
- Effort is a rough S/M/L, not a time estimate -- lets the user pick by capacity as
  well as priority.
- **A flat `BACKLOG.md` tag grep is not sufficient on its own (found S507):** also
  check `docs/audits/*SEQUENCING_AUDIT*.md` (or any doc whose text establishes a
  ratified next-pickup order for still-open issues) and surface that cluster's next
  item as a first-class numbered option — never folded into "Informational" just
  because no inline tag exists. A ratified order lives in prose, so the tag-only
  grep misses it entirely (`PROJECT_LEARNINGS.md` Learning 506).
- This formats the *existing* Phase 0 step 7 report; it adds no new
  `SESSION_RUNNER.md` step and does not change the mandatory STOP-and-wait-for-the-user
  after the report.
- Keep the `(READY | BLOCKED | DECISION NEEDED, Effort S|M|L)` tag inline on each
  `BACKLOG.md` item itself (not only in the rendered report), so the tag survives
  between sessions instead of being reconstructed from memory each time a report is
  rendered.

**Present the priorities list via `AskUserQuestion` (owner-directed, 2026-07-11):**
immediately after rendering the priorities list above, follow it with one
`AskUserQuestion` call so the user can pick with a click instead of free-typing.
This *supplements* the prose list (which still renders in full, unchanged) — it
does not replace it, add a new `SESSION_RUNNER.md` step, or change the mandatory
Phase 0 STOP-and-wait-for-the-user: the question itself **is** the wait.

- **Which items get an option:** one option per priorities-list item that got its
  own numbered write-up (the `:red_circle:`/`:orange_circle:` `READY`/`BLOCKED`/
  `DECISION NEEDED` items) — never the "Lower priority" comma-separated bundle or
  the "Informational" GitHub-issues line, which stay prose-only (too terse /
  explicitly not a pickable task). Option `label` = the item's short title;
  `description` = the same one-line context already written in the prose report
  (blocker/decision named for `BLOCKED`/`DECISION NEEDED` items, not just the tag).
- **Cap at 4** (the tool's max option count), kept in the same order as the
  rendered list. If more than 4 numbered items exist, keep the first 4 in that
  order and say so in the prose report (e.g. "+N more below the picker — see the
  list above") rather than silently dropping the rest.
- **Skip the question if fewer than 2 numbered items exist** (0 or 1) — a forced
  2-option pick with nothing real to compare is worse than the plain prose
  report + wait; fall back to that instead.
- **The user is never locked into the listed options:** the harness auto-appends
  a free-text "Other" choice, and a plain prose reply (ignoring the question
  entirely) works exactly as it always has.
- `header` stays <=12 chars (e.g. `"Next task"`); `question` should ask which item
  to pick up this session, not restate the tags (those live in each option's
  description).

**Untracked-file ghost-session check (found S479, 2026-08-08):** step 6's ledger reconcile is
keyed on `git log` gaps and is blind to a session that produced real work but zero commits. At
Phase 0 step 7, treat any untracked file whose modification time predates today by more than one
session cycle, and whose content reads as a completed deliverable rather than scratch/config, as
a secondary ghost-session signal — cross-check newly-filed GitHub issues against such files.
Before bulk-acting on such a batch, open and date-check each file individually: grouping by
directory/extension alone misclassifies in both directions (two near-misses:
`PROJECT_LEARNINGS.md` Learning 479).

**GitHub Actions CI status check (decided S545, 2026-08-13, owner-directed):** run
`gh run list --branch master --limit 10` as part of Phase 0 step 4, **every session,
unconditionally** — never push-conditioned (a scheduled workflow can go red with no push) and
always the plain, unfiltered form, never `--workflow=<one>` (Learning 549: `test-coverage.yaml`
failed while `R-CMD-check.yaml` was green on the same commit). **Report, don't fix:** fold any
non-`completed success` run into the step 7 report; diagnosing/fixing it is its own session
deliverable ("1 and done"), never a Phase 0 inline repair. Origin (a red `R-CMD-check.yaml` run
unnoticed for 13 sessions) is Learning 547; rejected alternatives are recorded in Learning 770.

**Context-budget check (adopted S720, 2026-09-19, owner-ratified):** run `python3 context_budget.py`
at Phase 0 step 5, alongside the dashboard. **Report, don't fix** — fold findings into the step 7
report like any other health signal. Expected state since the S725 reduction campaign: **no file
over its ceiling** (`CLAUDE.md` may sit in the 24,000 B warn band — headroom, not a defect); a
`CLAUDE.md` red means new growth is owed a reduction, and a `SESSION_NOTES.md` red means a
`methodology_trim.py --budget-bytes 65536` trim is owed (the two ceilings are deliberately the
same number). A **missing `budget:protected` fence** finding on `CLAUDE.md` means someone
removed the Project Overview fence — restore it before anything else. The per-clone pre-commit
hook (`python3 context_budget.py install-hook`) refuses only commits that *grow* an over-ceiling
file; re-install it on a fresh clone, bypass with `--no-verify` only when a legitimate growth
commit is owed (the decision then lands as a `.context-budget.json` diff, not a silent override).
`.context-budget-history.jsonl` stays gitignored (S719 decision).

### Additional task-to-workstream mappings

(none — but see the Development Process Contract override below.)

### Additional close-out checks

**Citation checklist (issue #120, 2026-07-08):** any session that adds a new displayed statistic/estimator must update `inst/extdata/ui_guidance/population_genetics_terms.html` (or the relevant UI guidance page) and the statistic's own roxygen `@references` in the same session it ships. (Source: `docs/audits/ISSUE_120_CITATION_COVERAGE_AUDIT_2026-07-08.md`, Structural Observation 1.)

**Tutorial/article documentation checklist (owner-directed, S436, 2026-07-30):** a plan that ships a new user-facing Shiny feature (a new tab, control, or interaction pattern) must include a documentation phase updating the relevant tutorial/article (`vignettes/articles/colony-manager-guide.qmd` and/or the matching `vignettes/manual_components/*.Rmd`) describing the feature's purpose and use — not just code + tests + `NEWS.md`. Origin (issue #129's Diagram tab shipped with zero vignette/article mentions → issue #139): Learning 770; the report-don't-fix precedent it followed: Learning 382.

**NEWS.Rmd entry checklist (owner-directed, S448; plain-language criterion added S628):** any session that ships a new exported function or user-facing Shiny feature/control must add a `NEWS.Rmd` entry (current development-version section, matching existing style) in the same session it ships (origin — issue #130's five slices shipped with none: Learning 433). **Plain-language criterion:** the entry must read plainly for a colony-manager/veterinarian reader, not an R programmer — what changed and why it matters, in one or two short sentences; domain vocabulary ("kinship"/"genotype"/"heterozygosity") is fine, implementation-flavored phrasing ("vectorized matrix algebra," "KING-robust," "a CERVUS-style multilocus LOD score") is not. Deliberately a per-session judgment check, not an automated word list (a banned-term lint would false-positive on legitimate domain vocabulary). Drift history behind the criterion: Learnings 544/770.

**`a2interactive.Rmd` script-callable-function checklist (owner-directed S450; scope broadened S478):** any new exported, script-callable function **or new parameter added to an already-documented exported function** should get a demonstration section (or update) in `vignettes/a2interactive.Rmd` — **deferred, not same-session**: a dedicated documentation pass after the feature has been reviewed and stabilized, to avoid documenting what may still change. A session picking this up inventories exported functions (not Shiny-UI-only features — the tutorial/article checklist covers those) and new parameters on documented ones since the last such pass. Origins: Learning 435 (issue #130's marker-genetics family shipped undemonstrated), Learning 478 (the `edgeStyle` parameter gap that broadened the scope to parameters).

**GitHub issue close-out checklist (found S475, 2026-08-04):** a session whose close-out marks a `BACKLOG.md` item fully DONE, where the item names a GitHub issue number, must close the issue in the *same* session — `gh issue close --reason completed --comment "..."` citing the `CHANGELOG.md` entry and verification evidence — never "a future session should consider closing this." Ratified after 3 consecutive deferred closes (issues #142/#143/#144): Learning 475.

**CI-break tracking convention (owner-directed, S636, 2026-08-26):** a CI break found live in-session does **not** get its own GitHub issue. Fix it as found if the fix is in scope and clear; otherwise defer it via a `BACKLOG.md` "Up Next" item with full root-cause detail. (Deliberate contrast with the issue *close-out* checklist above, which governs closing issues on shipped DONE items, not opening ones for CI-health findings.) Full incident: Learning 669.

**Lint close-out checklist (found S477, 2026-08-04):** any session that adds or modifies a tracked `.R` file must run `lintr::lint_package()` — package loaded first via `pkgload::load_all()` (an unloaded run produces spurious `object_usage_linter` noise CI never sees: Learning 224) — on touched files before close-out, and fix or `# nolint`-suppress (with documented rationale: Learnings 224/461) anything flagged, never relying on the post-push `lint.yaml` CI run (`master` has no branch protection, so a red run blocks nothing). Origin (a red lint run unnoticed for 4 sessions): Learning 477.

**`_pkgdown.yml` reference-coverage checklist (found S496, 2026-08-09):** any session that adds a new exported function must add it to a `_pkgdown.yml` reference: group in the same session (any existing group satisfies `test_pkgdown_reference_config.R`'s coverage guard — the "All exposed functions" catch-all in alphabetical position is the default choice). The guard evaluates coverage collectively, so one missing entry blocks unrelated fixes. Origin (the gap hit twice, incl. `readTwinRelations()`) and the adjacent `devtools::document()` verification discipline: Learning 495.

**BACKLOG completed-item removal checklist (owner-directed, S686, 2026-09-11):** a session that completes a `BACKLOG.md` item REMOVES the item's block entirely in the same commit — never an inline `[x]`: the completed record goes to `CHANGELOG.md` (enriched with any load-bearing verification detail the block held); detail a live open item needs is written INTO that item's own description (forward-carrying, never a pointer back at a DONE block); any still-open sub-thread is extracted as its own item first. Rationale (a kept DONE block is a weaker record and compounds FM #28's mandated read) and the S687 backfill sweep: Learning 740.

**`CHANGELOG.md` legacy history (S325 froze it; S547 relocated it):** the pre-ledger-format history (Sessions 1-324, ~935 KB) lives in [`docs/archive/CHANGELOG-legacy-pre-S325.md`](docs/archive/CHANGELOG-legacy-pre-S325.md) — frozen as-is (S325 owner decision: no retroactive re-tagging), relocated out of the live ledger S547 after the S546 owner-directed decision and full verification (Learning 554 carries the record: `classify_zones()` proof, fence scan, shard discovery, the SRF-denominator side effect). New entries never go in it; decision chain detail: Learning 770.

**`methodology_trim.py` local-customization checklist (S518; corrected S617/S719):** the tool ships from the `rmsharp/methodology` fork's `main` (a sync against an official *tag* never touches it) and carries **one local modification** — this project's `SESSION_NOTES.md` `LedgerSpec` + `_session_notes_date` helper; a **`NO_CONFIG` result** from `python3 methodology_trim.py --file SESSION_NOTES.md --check` is the signal a sync dropped it. Every sync from the fork's `main`: (1) save the extension first — after S719, `git show 63b3286f -- methodology_trim.py` is the patch (re-derive from the latest re-apply commit after future syncs); (2) `bin/sync --force` and commit exactly the files the dry run listed; (3) `git apply --check` then `git apply` the patch, in its own commit; (4) confirm `--check` no longer says `NO_CONFIG` and a `--file SESSION_NOTES.md --cut 1 --force` dry run prints `L1_OK`/`L2_OK`/`L3_OK`. Stays until the framework supports project-supplied ledger configs (fork BL-32). **Budget (decided S720, owner-ratified): pass `--budget-bytes 65536` on every `methodology_trim.py` run, `--check` included** — the 1.5.0 default is 196,608 B and this project keeps the old 65,536 B cadence; `.context-budget.json`'s `SESSION_NOTES.md` ceiling is the same number so the two tools tell one story. Provenance history and rejected alternatives: Learning 770.

**`CHANGELOG.md` legacy forms under the current ledger rules (S719):** ledger-format: 2; the rules live in the synced `docs/methodology/FRAMEWORK_APPARATUS.md` §The Action Ledger. Two pre-existing shapes stay as written (nothing already written is retrofitted): (a) **13 headings use a bare `[BL]` tag** the anchored audit doesn't count — expected, not a defect; new entries use the closed vocabulary `[issue #<N>]`, `[BL-<id>]` (this project's own backlog ids only — methodology-fork work is `[ad hoc]`), or `[ad hoc]`. (b) **The empty `## 2026-08` sits ABOVE `## 2026-09`**, so read "prepend under the topmost month" as: prepend under the pointer blocks beneath the month the entry belongs to; open a new month's heading at the top. A claim commit's entry is marked *(in progress)* and close-out adds its own entry — an entry once committed is never edited.

**`SESSION_NOTES.md` archive fence-scanner defect (found S518; RESOLVED S527/S528) — historical:** two `methodology_trim.py` regex defects once hid most session-record headings from the archive partition; both fixes live in the tool's `SESSION_NOTES.md` `LedgerSpec` (Learning 533). No known defect blocks `SESSION_NOTES.md` archiving — every pass since S539 has verified L1/L2/L3. Expect the recurring `SRF_RED` small-denominator refusal pattern on any ledger whose last archive was small (Learnings 549/586/587; owner-directed `--force` is the established resolution).

### Development Process Contract override

This project runs **Strict Test-Driven Development** (see the "Development Process Contract" section above). This is a project-specific override of the base methodology's general development guidance: tests are written before implementation, every response declares its TDD phase (RED / GREEN / REFACTOR), and phase transitions require permission. It supersedes general coding instincts but operates *within* the SESSION_RUNNER protocol (orient → one deliverable → close out). Implementation and bug-fix sessions therefore follow the chosen workstream **and** the RED→GREEN→REFACTOR gates.

### Project-specific Learnings

Project institutional memory lives in [`PROJECT_LEARNINGS.md`](PROJECT_LEARNINGS.md) — extracted from this file to keep `CLAUDE.md` within its size budget (count entries with `grep -c '^#### Learning ' PROJECT_LEARNINGS.md`; never hand-maintain the number here). **Read it when you need prior-session context; append new learnings there, not here.** Base methodology-level learnings remain in `SESSION_RUNNER.md`.

### Project-specific Failure Modes

(none — the base failure modes #1–28 in `SESSION_RUNNER.md` apply, including #26
"mega-session masquerading as a vertical slice" and #27 "unrecorded action,"
added by the 2026-07-08 methodology sync to v3.4, and #28 "unbounded mandatory
read," added by the 2026-08-20 methodology sync to v3.7.)
