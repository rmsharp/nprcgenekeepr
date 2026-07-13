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
STOP.

`SESSION_RUNNER.md` documents known failure modes and their
countermeasures. The protocol compensates for documented tendencies to
skip orientation, skip close-out, and continue past the deliverable.

------------------------------------------------------------------------

## Project Overview

**nprcgenekeepr** (Version 1.1.0.9000) is an R package implementing
Genetic Tools for Colony Management. Initially conceived and developed
as a Shiny web application at the Oregon National Primate Research
Center (ONPRC), it has been enhanced to have more capability as a Shiny
application and to expose functions for use either interactively or in R
scripts.

This work has been supported in part by NIH grants P51 RR13986 to the
Southwest National Primate Research Center and P51 OD011092 to the
Oregon National Primate Research Center.

### Core Functions

1.  **Quality Control** - Validation of studbooks from text files, Excel
    workbooks, and LabKey EHR pedigrees. Checks include:

    - Parent record verification
    - Sex validation (no male dams, female sires)
    - Duplicate detection
    - Date validation
    - Minimum parent age verification (default 2 years)

2.  **Pedigree Creation** - Building pedigrees from animal lists using
    LabKey EHR integration via `Rlabkey` package

3.  **Age-Sex Pyramid Plots** - Visual display of living animals by age
    and sex for demographic analysis

4.  **Genetic Value Analysis Reports** - Ranking scheme using:

    - Mean kinship (indicates inter-relatedness with colony)
    - Genome uniqueness (indicates presence of rare alleles)
    - Animals with low mean kinship or high genome uniqueness rank
      higher

5.  **Breeding Group Formation** - Creating potential breeding groups
    that:

    - Avoid mating of closely related animals
    - Support optional sex ratio constraints
    - Support harem group configuration
    - Maximize genetic diversity

### Package Structure

- `R/` - Package functions and Shiny modules (`appUI.R` +
  `appServer.R` + `mod*.R` are the canonical modular Shiny application,
  launched by
  [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md))
- `inst/extdata/` - Example data and configuration files
- `tests/testthat/` - Unit tests

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

### Online Documentation

<https://rmsharp.github.io/nprcgenekeepr/>

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
`Rscript -e 'suppressMessages(pkgload::load_all(".", quiet=TRUE)); testthat::test_file("tests/testthat/test_X.R", reporter="summary")'`

**Clean regression read** (the `test-app-*`/`test-e2e-*` files are
pre-existing baseline noise — see Learning \#2/#4 below):
`as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))`,
then check `sum(failed)` **and** `sum(error)`, isolating true offenders
with `!grepl("test-app-|test-e2e-", file)`.

------------------------------------------------------------------------

## Project-Specific Methodology Adaptations

*Additions and overrides to the base methodology at `SESSION_RUNNER.md`
and `SAFEGUARDS.md` (synced from
<https://github.com/rmsharp/methodology>, not project-owned). The base
files govern unless explicitly overridden here. **Do not edit the synced
files** — put customizations here so `bin/sync` stays friction-free (see
BOOTSTRAP “Updating an existing project”).*

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

### Additional task-to-workstream mappings

(none — but see the Development Process Contract override below.)

### Additional close-out checks

**Citation checklist (issue \#120, 2026-07-08):** any session that adds
a new displayed statistic/estimator to the package must update
`inst/extdata/ui_guidance/population_genetics_terms.html` (or the
relevant UI guidance page) and the statistic’s own roxygen `@references`
in the same session that ships it, rather than deferring to a later
audit. (Source:
`docs/audits/ISSUE_120_CITATION_COVERAGE_AUDIT_2026-07-08.md` Structural
Observation 1 — citation gaps correlated with recency, not centrality:
the metrics missing coverage were consistently the ones added without
their own citation pass.)

**CHANGELOG.md ledger-format resolution (2026-07-08, Session 325 —
“freeze legacy, go forward”):** canonical v3.1+ defines `CHANGELOG.md`
as an “Authoritative Action Ledger” — dated
`### YYYY-MM-DD · [issue #N] | [BL-N] | [ad hoc]` entries, one per
action. This project’s pre-existing ~30+-session history (dated
subsections, no source tag) was **not** retroactively migrated — owner
chose (via `AskUserQuestion`) to freeze it as-is rather than run a
multi-session migration campaign to re-tag 303 already-closed entries.
`CHANGELOG.md` now has a
`## Legacy history (pre-ledger format, Sessions 1-324)` marker:
everything below it is untouched original-format history; everything
above it (from Session 325 forward) uses the canonical `[SOURCE]`-tagged
format. New entries always go above the marker, never inside it.

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

Project institutional memory (Sessions 1–374+; 345 learnings, ~1.5 MB)
lives in
[`PROJECT_LEARNINGS.md`](https://github.com/rmsharp/nprcgenekeepr/PROJECT_LEARNINGS.md)
— extracted from this file to keep `CLAUDE.md` within its size budget
(Claude Code targets ~200 lines / ~25 KB). **Read it when you need
prior-session context; append new learnings there, not here.** Base
methodology-level learnings remain in `SESSION_RUNNER.md`.

### Project-specific Failure Modes

(none — the base failure modes \#1–27 in `SESSION_RUNNER.md` apply,
including \#26 “mega-session masquerading as a vertical slice” and \#27
“unrecorded action,” added by the 2026-07-08 methodology sync to v3.4.)
