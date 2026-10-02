# nprcgenekeepr

## SESSION PROTOCOL — FOLLOW BEFORE DOING ANYTHING

**Read and follow `SESSION_RUNNER.md` step by step.** It is your
operating procedure for every session. It tells you what to read, when
to stop, and how to close out.

**Three rules you will be tempted to violate:** 1. **Orient first** —
Read SAFEGUARDS.md → SESSION_NOTES.md → check GitHub Issues (or
BACKLOG.md if no repo) → run `methodology_dashboard.py` → git status →
report findings → WAIT FOR THE USER TO SPEAK 2. **1 and done** — One
deliverable per session. When it’s complete, close out. Do not start the
next thing. 3. **Auto-close** — When done: evaluate previous handoff,
self-assess, document learnings, write handoff notes, commit, report,
STOP. Read `docs/conventions/CLOSEOUT_CHECKLISTS.md` first (project
checklists).

`SESSION_RUNNER.md` documents known failure modes and their
countermeasures. The protocol compensates for documented tendencies to
skip orientation, skip close-out, and continue past the deliverable.

------------------------------------------------------------------------

## Project Overview

**nprcgenekeepr** is an R package implementing Genetic Tools for Colony
Management. Initially conceived and developed as a Shiny web application
at the Oregon National Primate Research Center (ONPRC), it has been
enhanced to have more capability as a Shiny application and to expose
functions for use either interactively or in R scripts.

This work has been supported in part by NIH grants P51 RR13986 to the
Southwest National Primate Research Center and P51 OD011092 to the
Oregon National Primate Research Center.

### Package Structure

- `R/` - Package functions and Shiny modules (`appUI.R` +
  `appServer.R` + `mod*.R` are the canonical modular Shiny application,
  launched by
  [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md))

### Running the Application

``` r

library(nprcgenekeepr)
runGeneKeepR()   # runModularApp() is a deprecated alias that calls this
```

### Key References

Vinson, A; Raboin, MJ. “A Practical Approach for Designing Breeding
Groups to Maximize Genetic Diversity in a Large Colony of Captive Rhesus
Macaques (*Macaca mulatta*)” *Journal of the American Association for
Laboratory Animal Science*, 2015 Nov, Vol.54(6), pp.700-707

------------------------------------------------------------------------

## Development Process Contract

This project uses **Strict Test-Driven Development (TDD)**. Deviation is
a defect.

### TDD Rules:

- Write tests before implementation code
- Each feature branch should include tests
- Ensure both happy paths and all non-happy paths are tested
- Ensure potential edge cases are tested
- Maintain \>80% code coverage for new code
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

- The assistant MUST declare the current phase at the top of every
  response.
- The assistant MUST refuse requests that violate the current phase.
- The assistant MUST ask permission before transitioning between phases
  — via `AskUserQuestion`, per the **Phase-gate format** below.
- Skipping phases is forbidden.
- Writing implementation code during RED is a violation.
- Ensure potential edge cases are tested
- Maintain \>80% code coverage for new code
- Run full test suite before merging
- Tests must be fast, isolated, and deterministic

### Phase-gate format

The “ask permission before transitioning” rule above is satisfied with
**`AskUserQuestion`** (the structured prompt), **not** a prose question,
at **every** phase transition — so the choice and the exact planned
actions are explicit and logged. This is a followed project convention,
**not** a `settings.json` hook: there is no “phase transition” harness
event, and a hook cannot author options describing the specific
next-phase actions.

Each gate is **one** `AskUserQuestion` with this shape (the harness
auto-appends a free-text “Other”):

- **Header:** `TDD: <FROM>→<TO>` (e.g. `TDD: RED→GREEN`).
- **Option 1 — “Yes, proceed to ”:** spell out the *exact* actions the
  next phase will take — files, the concrete change, how the failing
  tests / completion criteria get satisfied — then the downstream
  verification (full suite, lint, the build-equivalent per “Build / Test
  / Verify”, and any E2E/integration).
- **Option 2 — “Hold / ”:** a concrete alternative — pause to review the
  RED tests / classification first, OR a narrower next-phase scope
  (e.g. “docs only; leave X as-is”).

**Gated transitions:** `PRE-RED→RED`, `RED→GREEN`, `GREEN→REFACTOR`. A
pre-RED **scope or approach** decision that is the author’s to make
(e.g. which functions are in scope) is a *separate* `AskUserQuestion`,
posed before declaring RED. The declare-phase-at-top-of-response and
refuse-on-violation rules are unchanged.

### Error Handling

If a response violates TDD: 1. The assistant must acknowledge the
violation. 2. The assistant must correct itself. 3. The assistant must
reissue a compliant response.

This file supersedes general coding instincts.

------------------------------------------------------------------------

## Build / Test / Verify

The build-equivalent for this R package (relocated here from
`SAFEGUARDS.md` during the 2026-05-31 methodology update so the synced
`SAFEGUARDS.md` stays byte-identical to canonical; see `SAFEGUARDS.md`
“Verify the Build Equivalent”):

| Purpose | Command | Pass criteria |
|----|----|----|
| Full package check | `devtools::check()` or `R CMD check` | No errors, no warnings, no notes (ideally) |
| Test suite | `devtools::test()` or [`testthat::test_local()`](https://testthat.r-lib.org/reference/test_package.html) | All tests pass |

**Fast single-file test:**
`Rscript -e 'Sys.setenv(NOT_CRAN = "true"); suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_X.R", reporter="summary")'`
(sets `NOT_CRAN` first — without it, a file with a top-level
`skip_on_cran()` silently bare-skips instead of running; see
`PROJECT_LEARNINGS.md` Learning 417.)

**Clean regression read:**
`Sys.setenv(NOT_CRAN = "true"); pkgload::load_all(".", quiet=TRUE); as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))`,
then check `sum(failed)` **and** `sum(error)` directly, unfiltered.
(`load_all()` must run first — without it this command produces
mass-spurious failures unrelated to anything actually broken; see
Learning 377. `NOT_CRAN` must be set too — without it, any file with a
top-level `skip_on_cran()` \[e.g. `test_wordlist_coverage.R`\] silently
bare-skips and its failure vanishes from `sum(failed)` instead of
counting; see Learning 417 and Learning 594, which hit exactly this
omission in this command.) **No `test-app-*`/`test-e2e-*` exclusion
filter — removed S624 (2026-08-23).** Learning \#2/#4 (Sessions 3-4)
once documented those files as pre-existing baseline noise because
`create_test_app()` was undefined at the time, so every such file
errored or was skipped as a structural artifact rather than a real
failure; `create_test_app()` has been defined
(`tests/testthat/helper-shinytest2.R:200`) for a long time, and
unfiltered runs report 0 failed/0 error across those files for weeks
(S622/S623). A blanket `!grepl("test-app-|test-e2e-", file)` exclusion
is now a live risk, not a convenience — it would silently hide a real
regression landing in exactly those files, which issue \#163 (S623)
nearly demonstrated. Do not reintroduce the pattern; if a specific file
ever develops a genuine, currently-true reason for exclusion, name that
file and the reason explicitly in a fresh entry rather than reviving a
permanent file-name-pattern amnesty. (Learning \#2/#4 themselves are
left unedited as the frozen historical record of what was true in
Sessions 3-4.)

**[`renv::snapshot()`](https://rstudio.github.io/renv/reference/snapshot.html)
always needs `dev = TRUE` in this project.** `renv/settings.json` sets
`snapshot.type: "explicit"`, under which a **plain**
[`renv::snapshot()`](https://rstudio.github.io/renv/reference/snapshot.html)
only scans `DESCRIPTION`’s `Imports`/`Depends`/`LinkingTo` — every
dev-only package (`Suggests` in `DESCRIPTION`, e.g. `testthat`, `dplyr`,
`mockery`, `shinytest2`, `shinyBS`, plus the dev-profile tools
`roxygen2`, `devtools` and `quarto`, and their transitive deps like
`pkgload`/`chromote`) is silently dropped from `renv.lock` on an
ordinary snapshot, only to resurface as a missing-package crash the next
time someone hits
[`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html)
(a fresh clone, an R-version bump). Always run
`renv::snapshot(dev = TRUE)` (and `renv::status(dev = TRUE)` to check
consistency) instead of the bare form. See `PROJECT_LEARNINGS.md`
Learning 473/476 for the root-cause diagnosis.

------------------------------------------------------------------------

## Project-Specific Methodology Adaptations

*Additions and overrides to the base methodology at `SESSION_RUNNER.md`
and `SAFEGUARDS.md` (synced from
<https://github.com/rmsharp/methodology>, not project-owned). The base
files govern unless explicitly overridden here. **Do not edit the synced
files** — put customizations here so upstream’s `bin/sync` (not in this
repo) stays friction-free (see BOOTSTRAP “Updating an existing
project”).*

### Additional Phase 0 steps

**Priorities list at Phase 0 step 7 (report findings, 2026-07-09):**
render the “open items” portion of the orientation report as a numbered,
scannable priority list, not prose – sourced from `BACKLOG.md`’s
per-item `(READY | BLOCKED | DECISION NEEDED, Effort S|M|L)` tags (and
open GitHub issues/PRs not yet mirrored into `BACKLOG.md`). Format
(adapted from a sibling project’s convention):

    Current priorities (from BACKLOG, in the order Session N left them):
    1. [color] Title (READY, Effort M): one-line concrete context + any decision the
       picking session needs to make first.
    2. [color] Title (BLOCKED -- <what it's blocked on>, Effort L): ...
    3. Lower priority: short comma-separated items with no full write-up.
    4. Informational: open PRs / issues not yet in BACKLOG.md -- untouched, FYI only.

- Color: 🔴 reserved for something explicitly NOT a routine session’s
  pickup (needs its own scoping/planning session first, or is otherwise
  high-stakes); 🟠 for ready-now, normal-priority items; no marker for
  “Lower priority”/“Informational” line items.
- `READY` = the next session can start with no unresolved decision.
  `BLOCKED` or `DECISION NEEDED` must name the blocker/decision in the
  one-line context, not just the tag.
- Effort is a rough S/M/L, not a time estimate – lets the user pick by
  capacity as well as priority.
- **A flat `BACKLOG.md` tag grep is not sufficient on its own (found
  S507):** also check `docs/audits/*SEQUENCING_AUDIT*.md` (or any doc
  whose text establishes a ratified next-pickup order for still-open
  issues) and surface that cluster’s next item as a first-class numbered
  option — never folded into “Informational” just because no inline tag
  exists. A ratified order lives in prose, so the tag-only grep misses
  it entirely (`PROJECT_LEARNINGS.md` Learning 506).
- This formats the *existing* Phase 0 step 7 report; it adds no new
  `SESSION_RUNNER.md` step and does not change the mandatory
  STOP-and-wait-for-the-user after the report.
- Keep the `(READY | BLOCKED | DECISION NEEDED, Effort S|M|L)` tag
  inline on each `BACKLOG.md` item itself (not only in the rendered
  report), so the tag survives between sessions instead of being
  reconstructed from memory each time a report is rendered.

**Present the priorities list via `AskUserQuestion` (owner-directed,
2026-07-11):** immediately after rendering the priorities list above,
follow it with one `AskUserQuestion` call so the user can pick with a
click instead of free-typing. This *supplements* the prose list (which
still renders in full, unchanged) — it does not replace it, add a new
`SESSION_RUNNER.md` step, or change the mandatory Phase 0
STOP-and-wait-for-the-user: the question itself **is** the wait.

- **Which items get an option:** one option per priorities-list item
  that got its own numbered write-up (the
  `:red_circle:`/`:orange_circle:` `READY`/`BLOCKED`/ `DECISION NEEDED`
  items) — never the “Lower priority” comma-separated bundle or the
  “Informational” GitHub-issues line, which stay prose-only (too terse /
  explicitly not a pickable task). Option `label` = the item’s short
  title; `description` = the same one-line context already written in
  the prose report (blocker/decision named for
  `BLOCKED`/`DECISION NEEDED` items, not just the tag).
- **Cap at 4** (the tool’s max option count), kept in the same order as
  the rendered list. If more than 4 numbered items exist, keep the first
  4 in that order and say so in the prose report (e.g. “+N more below
  the picker — see the list above”) rather than silently dropping the
  rest.
- **Skip the question if fewer than 2 numbered items exist** (0 or 1) —
  a forced 2-option pick with nothing real to compare is worse than the
  plain prose report + wait; fall back to that instead.
- **The user is never locked into the listed options:** the harness
  auto-appends a free-text “Other” choice, and a plain prose reply
  (ignoring the question entirely) works exactly as it always has.
- `header` stays \<=12 chars (e.g. `"Next task"`); `question` should ask
  which item to pick up this session, not restate the tags (those live
  in each option’s description).

**Untracked-file ghost-session check (found S479, 2026-08-08):** step
6’s ledger reconcile is keyed on `git log` gaps and is blind to a
session that produced real work but zero commits. At Phase 0 step 7,
treat any untracked file whose modification time predates today by more
than one session cycle, and whose content reads as a completed
deliverable rather than scratch/config, as a secondary ghost-session
signal — cross-check newly-filed GitHub issues against such files.
Before bulk-acting on such a batch, open and date-check each file
individually: grouping by directory/extension alone misclassifies in
both directions (two near-misses: `PROJECT_LEARNINGS.md` Learning 479).

**GitHub Actions CI status check (decided S545, 2026-08-13,
owner-directed):** run `gh run list --branch master --limit 10` as part
of Phase 0 step 4, **every session, unconditionally** — never
push-conditioned (a scheduled workflow can go red with no push) and
always the plain, unfiltered form, never `--workflow=<one>` (Learning
549: `test-coverage.yaml` failed while `R-CMD-check.yaml` was green on
the same commit). **Report, don’t fix:** fold any
non-`completed success` run into the step 7 report; diagnosing/fixing it
is its own session deliverable (“1 and done”), never a Phase 0 inline
repair. Origin (a red `R-CMD-check.yaml` run unnoticed for 13 sessions)
is Learning 547; rejected alternatives are recorded in Learning 770.

**Context-budget check (adopted S720, 2026-09-19, owner-ratified):** run
`python3 context_budget.py` at Phase 0 step 5, alongside the dashboard.
**Report, don’t fix** — fold findings into the step 7 report like any
other health signal. Expected state since the S725 reduction campaign:
**no file over its ceiling** (`CLAUDE.md` may sit in the 24,000 B warn
band — headroom, not a defect); a `CLAUDE.md` red means new growth is
owed a reduction, and a `SESSION_NOTES.md` red means a
`methodology_trim.py --budget-bytes 65536` trim is owed (the two
ceilings are deliberately the same number); a per-line finding on
`SESSION_NOTES.md` (280 B ceiling) means an over-long line to wrap. A
**missing `budget:protected` fence** finding on `CLAUDE.md` means
someone removed the Project Overview fence — restore it before anything
else. The per-clone pre-commit hook
(`python3 context_budget.py install-hook`) refuses only commits that
*grow* an over-ceiling file; re-install it on a fresh clone, bypass with
`--no-verify` only when a legitimate growth commit is owed (the decision
then lands as a `.context-budget.json` diff, not a silent override).
`.context-budget-history.jsonl` stays gitignored (S719 decision).

### Additional task-to-workstream mappings

(none — but see the Development Process Contract override below.)

### Additional close-out checks

**At Phase 3 (close-out), read
[`docs/conventions/CLOSEOUT_CHECKLISTS.md`](https://github.com/rmsharp/nprcgenekeepr/docs/conventions/CLOSEOUT_CHECKLISTS.md)
and apply every checklist whose trigger matches what the session
shipped.** One line per checklist (full text in that file):

- **Citation checklist** — new displayed statistic/estimator → update
  the UI guidance page and roxygen `@references`, same session.
- **Tutorial/article documentation** — new user-facing Shiny feature →
  update the tutorial/article, not just code, tests and `NEWS.md`.
- **NEWS.Rmd entry** — new exported function or user-facing feature → a
  release-state, plain-language entry in the same session.
- **`a2interactive.Rmd` checklist** — new exported function or new
  parameter on a documented one → demonstrate it in a later, dedicated
  pass.
- **GitHub issue close-out** — a DONE `BACKLOG.md` item naming an issue
  → close that issue in the same session.
- **CI-break tracking** — a live-found CI break gets no issue of its
  own; fix it or defer via `BACKLOG.md`.
- **Lint close-out** — any tracked `.R` file added or changed →
  `lintr::lint_package()` (package loaded first) before close-out.
- **`_pkgdown.yml` reference coverage** — new exported function → add it
  to a `_pkgdown.yml` reference group, same session.
- **BACKLOG completed-item removal** — completing an item → remove its
  block entirely in the same commit; the record goes to `CHANGELOG.md`.
- **`CHANGELOG.md` legacy history** — pre-S325 history lives in
  `docs/archive/CHANGELOG-legacy-pre-S325.md`; never add entries there.
- **`methodology_trim.py` local customization** — after any sync from
  the fork’s `main`, re-apply the `SESSION_NOTES.md` ledger patch; pass
  `--budget-bytes 65536` on every run.
- **`CHANGELOG.md` legacy forms** — bare `[BL]` headings stay as
  written; new entries use `[issue #<N>]`, `[BL-<id>]` or `[ad hoc]`.
- **`SESSION_NOTES.md` archive fence-scanner defect** — resolved
  S527/S528; historical note only.

### Development Process Contract override

This project runs **Strict Test-Driven Development** (see the
“Development Process Contract” section above). This is a
project-specific override of the base methodology’s general development
guidance: tests are written before implementation, every response
declares its TDD phase (RED / GREEN / REFACTOR), and phase transitions
require permission. It supersedes general coding instincts but operates
*within* the SESSION_RUNNER protocol (orient → one deliverable → close
out). Implementation and bug-fix sessions therefore follow the chosen
workstream **and** the RED→GREEN→REFACTOR gates.

### Project-specific Learnings

Project institutional memory lives in
[`PROJECT_LEARNINGS.md`](https://github.com/rmsharp/nprcgenekeepr/PROJECT_LEARNINGS.md)
— extracted from this file to keep `CLAUDE.md` within its size budget
(count entries with `grep -c '^#### Learning ' PROJECT_LEARNINGS.md`;
never hand-maintain the number here). **Read it when you need
prior-session context; append new learnings there, not here.** Base
methodology-level learnings remain in `SESSION_RUNNER.md`.

### Project-specific Failure Modes

(none — the base failure modes \#1–28 in `SESSION_RUNNER.md` apply,
including \#26 “mega-session masquerading as a vertical slice” and \#27
“unrecorded action,” added by the 2026-07-08 methodology sync to v3.4,
and \#28 “unbounded mandatory read,” added by the 2026-08-20 methodology
sync to v3.7.)
