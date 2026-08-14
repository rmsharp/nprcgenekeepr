## SESSION PROTOCOL — FOLLOW BEFORE DOING ANYTHING

**Read and follow `SESSION_RUNNER.md` step by step.** It is your operating procedure for every session. It tells you what to read, when to stop, and how to close out.

**Three rules you will be tempted to violate:**
1. **Orient first** — Read SAFEGUARDS.md → SESSION_NOTES.md → check GitHub Issues (or BACKLOG.md if no repo) → run `methodology_dashboard.py` → git status → report findings → WAIT FOR THE USER TO SPEAK
2. **1 and done** — One deliverable per session. When it's complete, close out. Do not start the next thing.
3. **Auto-close** — When done: evaluate previous handoff, self-assess, document learnings, write handoff notes, commit, report, STOP.

`SESSION_RUNNER.md` documents known failure modes and their countermeasures. The protocol compensates for documented tendencies to skip orientation, skip close-out, and continue past the deliverable.

---

# nprcgenekeepr

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

**Clean regression read** (the `test-app-*`/`test-e2e-*` files are pre-existing baseline noise — see Learning #2/#4 below): `pkgload::load_all(".", quiet=TRUE); as.data.frame(testthat::test_dir("tests/testthat", reporter="silent", stop_on_failure=FALSE))`, then check `sum(failed)` **and** `sum(error)`, isolating true offenders with `!grepl("test-app-|test-e2e-", file)`. (`load_all()` must run first — without it this command produces mass-spurious failures unrelated to anything actually broken; see Learning 377.)

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
- **A flat `BACKLOG.md` tag grep is not sufficient on its own (found S507,
  2026-08-10):** also check `docs/audits/*SEQUENCING_AUDIT*.md` (or any doc whose own
  text establishes a ratified next-pickup order for a cluster of still-open GitHub
  issues) and surface that cluster's own next item as a first-class numbered option --
  never folded into the flat "Informational: open GitHub issues" bucket just because
  no inline `BACKLOG.md` tag exists for it. A ratified sequencing audit's order lives
  in prose, not a per-item tag, so the tag-only grep misses it entirely; this exact gap
  independently hit both S506's own handoff `next_steps` field and S507's own initial
  Phase 0 rendering before the owner caught it. See `PROJECT_LEARNINGS.md` Learning
  506.
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

**Untracked-file ghost-session check (found S479, 2026-08-08):** Phase 0 step 6's ledger reconcile
is keyed entirely on `git log` gaps, which is blind to a session that produces real work but makes
zero commits — that work is visible only as untracked files in `git status`, with nothing
distinguishing harmless local scratch from a completed deliverable nobody recorded. Found when 2
well-formed `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_*.md` docs (dated 2026-08-05,
2026-08-06) and 8 correspondent GitHub issues (#146-153) sat untracked/unmirrored for 1-4 days,
invisible to the standard commit-gap check (only S478's own self-referential sha-backfill commit
existed since the prior documented session). At Phase 0 step 7, alongside the standard `git
status`, treat any untracked file whose modification time predates today by more than one session
cycle, and whose content reads as a completed deliverable rather than scratch/config, as a
secondary ghost-session signal — cross-check newly-filed GitHub issues against whether their
content traces to such a file. Before bulk-acting on a batch of untracked files found this way,
open and date-check each one individually: grouping by directory/extension alone can wrongly
implicate unrelated old clutter (this session nearly did) or wrongly clear a copyright risk that
only surfaces by actually reading the file (also this session — see PROJECT_LEARNINGS.md Learning
479 for both near-misses). See `CHANGELOG.md` 2026-08-08.

**GitHub Actions CI status check (decided S545, 2026-08-13, owner-directed via `AskUserQuestion`):**
neither `SAFEGUARDS.md`'s Session Recovery Protocol nor `SESSION_RUNNER.md`'s Phase 0 checklist
inspects GitHub Actions at all, so a red CI run is invisible to orientation unless someone thinks
to check it directly. This let a genuinely failing `R-CMD-check.yaml` run sit unnoticed across 13
sessions (S526-S539) — `PROJECT_LEARNINGS.md` Learning 547 — until the owner asked directly.

Run `gh run list --branch master --limit 10` as part of Phase 0 step 4 (alongside `git status`/
`git log`/`git diff --stat`), **every session, unconditionally** — not conditioned on whether this
session (or the prior one) pushed. This project has 7 active workflows
(`R-CMD-check.yaml`/`lint.yaml`/`pkgdown.yaml`/`test-coverage.yaml`/`shinytest2.yaml`/`rhub.yaml`/
`R-CMD-check-scheduled.yaml`), 4 of which trigger on every push to `master`; an unconditional check
also catches a scheduled or manually-triggered workflow going red with no intervening local push at
all — a gap a push-conditioned check would miss entirely. Deliberately the plain, unfiltered form
(never `gh run list --workflow=<one>`, which only confirms that one workflow) — `PROJECT_LEARNINGS.md`
Learning 549's own practical rule, from the session that found `test-coverage.yaml` failing while
`R-CMD-check.yaml` was green on the same commit.

- **Report, don't fix.** Fold any non-`completed success` run into the Phase 0 step 7 report exactly
  like a ghost-session or ledger-reconcile finding — surfaced to the user, not silently repaired or
  silently ignored. Diagnosing/fixing a red run found this way is its own session deliverable (per
  `SESSION_RUNNER.md`'s "1 and done"), not something Phase 0 does inline.
- **Rejected alternatives** (recorded so a future session doesn't re-litigate from scratch): a
  push-conditioned cadence (misses scheduled-workflow-only drift, needs extra "since when" tracking
  logic); GitHub branch protection instead of an observation step (a repo-config change, not a
  `SESSION_RUNNER.md`/`CLAUDE.md` process change, and doesn't stop local commits stacking up
  unpushed in the first place — a different problem than "nobody looked"); holding with no change
  (rejected — 13 sessions of precedent was judged sufficient to act on).

### Additional task-to-workstream mappings

(none — but see the Development Process Contract override below.)

### Additional close-out checks

**Citation checklist (issue #120, 2026-07-08):** any session that adds a new displayed statistic/estimator to the package must update `inst/extdata/ui_guidance/population_genetics_terms.html` (or the relevant UI guidance page) and the statistic's own roxygen `@references` in the same session that ships it, rather than deferring to a later audit. (Source: `docs/audits/ISSUE_120_CITATION_COVERAGE_AUDIT_2026-07-08.md` Structural Observation 1 — citation gaps correlated with recency, not centrality: the metrics missing coverage were consistently the ones added without their own citation pass.)

**Tutorial/article documentation checklist (owner-directed, 2026-07-30, Session 436):** a plan that ships a new user-facing Shiny feature (a new tab, control, or interaction pattern) must include a documentation phase updating the relevant tutorial/article (`vignettes/articles/colony-manager-guide.qmd` and/or the matching `vignettes/manual_components/*.Rmd` component) describing the feature's purpose and use — not just code + tests + `NEWS.md`. Surfaced when a mid-session owner directive ("this plan needs to include augmenting articles and tutorials") prompted a check that found issue #129's already-shipped pedigree-diagram Diagram tab (S433/S434) has **zero** mentions in any vignette or article (`grep` across `vignettes/**/*.Rmd`/`vignettes/articles/*.qmd` returns nothing) — tracked as GitHub issue #139 rather than fixed retroactively in the triage session that found it, per the established "report an incidentally-discovered, unrelated pre-existing gap, don't fix it mid-session" precedent (`PROJECT_LEARNINGS.md` Learning 382).

**NEWS.Rmd entry checklist (owner-directed, 2026-08-01, Session 448):** any session that ships a new exported function or a new user-facing Shiny feature/control must add a `NEWS.Rmd` entry (in the current development-version section, matching the style of existing entries) in the same session it ships, rather than deferring to a later audit — mirroring the citation (issue #120) and tutorial/article (Session 436) checklists above. Ratified after issue #130's entire 5-slice sequencing chain (Slices 1-5, Sessions 442-447: `markerKinship()`, `markerObservedHeterozygosity()`/`markerExpectedHeterozygosity()`, `markerParentageExclusion()`, `resolveCrossCenterIds()`, `markerFst()`, plus the new Marker Genetics Shiny module) shipped with zero `NEWS.Rmd` entries between them, unlike sibling issues #125-#129 from the same audit-triage batch, each of which got one in its own shipping session (`BACKLOG.md` Housekeeping, `PROJECT_LEARNINGS.md` Learning 433). Slices 1-5 were backfilled retroactively this session (Session 448) as a one-time exception to the general no-retroactive-fix precedent above, since the gap spans the package's entire user-visible changelog for a shipped capability; the checklist applies prospectively, same-session, from here on.

**`a2interactive.Rmd` script-callable-function checklist (owner-directed, 2026-08-02, Session 450; scope broadened S478, 2026-08-04):** any new exported, script-callable function **or new parameter/argument added to an already-documented exported function** should eventually get a demonstration section (or a demonstration update) in `vignettes/a2interactive.Rmd` (the scriptable/interactive-R tutorial) — but unlike the citation, tutorial/article, and `NEWS.Rmd` checklists above, this coverage is **deferred, not same-session**: it happens in a dedicated documentation pass after the feature has been fully reviewed and has stabilized, not in the shipping session itself, to avoid documenting something that may still change. A future session picking up this work should identify any exported, script-callable functions (not Shiny-UI-only features, which the tutorial/article checklist already covers) — or existing documented functions that gained new parameters — added/changed since the last `a2interactive.Rmd` documentation pass and add matching demonstration sections. Ratified after issue #130's entire marker-genetics function family (`markerKinship()`, `markerObservedHeterozygosity()`/`markerExpectedHeterozygosity()`, `markerParentageExclusion()`, `resolveCrossCenterIds()`, `markerFst()`) shipped across Sessions 442-447 with zero `a2interactive.Rmd` mentions — discovered S447 (`BACKLOG.md` Housekeeping, `PROJECT_LEARNINGS.md` Learning 435) and backfilled this session as a one-time exception, matching the `NEWS.Rmd` checklist's own backfill precedent; the checklist itself applies prospectively, as a deferred obligation, from here on. Scope broadened S478 after finding the checklist's original "new function" wording missed exactly this shape of gap: issue #142 added an `edgeStyle` parameter to the *already-documented* `makePedigreeMatingLayout()` (S465/S468), and the existing `a2interactive.Rmd` "Pedigree Diagram" section silently went stale (including its own render code drifting out of sync with the app's actual reserved-node-id-prefix set) until the user directly asked for it — see `PROJECT_LEARNINGS.md` Learning 478.

**GitHub issue close-out checklist (found S475, 2026-08-04):** any session whose close-out marks a `BACKLOG.md` item fully DONE, where that item names a GitHub issue number, must close the issue in the *same* session — a `gh issue close --reason completed --comment "..."` citing the `CHANGELOG.md` entry and verification evidence, matching the established #131/#134/#135/#139 precedent — rather than deferring to "a future session should consider closing this." Ratified after finding 3 consecutive instances of this exact gap: issue #142 (implemented S468) stayed open 7 sessions before S475 closed it; issue #143 (implemented S472) stayed open 3 sessions, flagged-but-not-acted-on by 2 intervening orientation reports; issue #144 (implemented S474) stayed open 1 session. Each was caught only by a *later* session's Phase 0 orientation cross-checking `gh issue list` against `BACKLOG.md`'s own DONE markers, never by the shipping session's own close-out. See `PROJECT_LEARNINGS.md` Learning 475.

**Lint close-out checklist (found S477, 2026-08-04):** any session that adds or modifies a tracked `.R` file must run `lintr::lint_package()` — package loaded first via `pkgload::load_all()`, per `PROJECT_LEARNINGS.md` Learning 224's ground-truth methodology (an unloaded lint run produces spurious `object_usage_linter` noise CI never sees) — on touched files before closing out, and fix or `# nolint`-suppress (with a documented rationale, matching the established false-positive precedent, `PROJECT_LEARNINGS.md` Learnings 224/461) anything it flags there, rather than relying on `.github/workflows/lint.yaml`'s post-push CI run to catch it. Ratified after finding that CI job — which already exists and runs `lintr::lint_package()` on every push with `LINTR_ERROR_ON_LINT: true` — went red for 2 real violations S472 introduced in `R/makePedigreeDiagramData.R`, with S473-S476 all committing on top of the red run without noticing or fixing it: `master` carries no branch protection requiring the check to pass, so a failing run blocks nothing and is easy to never look at. Fixed S477; see `PROJECT_LEARNINGS.md` Learning 477.

**`_pkgdown.yml` reference-coverage checklist (found S496, 2026-08-09):** any session that adds a new exported function must add it to a `_pkgdown.yml` reference: group (any existing group satisfies `test_pkgdown_reference_config.R`'s coverage guard — the "All exposed functions" catch-all in alphabetical position is the simplest choice absent a more specific curated group) in the same session it ships, rather than relying on that guard's own full clean regression read to catch the gap later. Ratified after finding this exact gap hit twice: issue #130 Slice 1's own `markerKinship()` ("the gap class Slice 1 hit and had to fix retroactively," `BACKLOG.md`), and issue #147 Slice 1's `markerParentageLikelihood()` (S496) — the latter caught only because a `devtools::document()` run for an unrelated reason also surfaced a second, pre-existing instance (`readTwinRelations()`, shipped S494 with no NAMESPACE export or `_pkgdown.yml` entry either) failing the SAME guard, which cannot be fixed for only one entry since the test evaluates coverage collectively. See `PROJECT_LEARNINGS.md` Learning 495 for the adjacent `devtools::document()` verification discipline this same session established.

**CHANGELOG.md ledger-format resolution (2026-07-08, Session 325 — "freeze legacy, go forward"):** canonical v3.1+ defines `CHANGELOG.md` as an "Authoritative Action Ledger" — dated `### YYYY-MM-DD · [issue #N] | [BL-N] | [ad hoc]` entries, one per action. This project's pre-existing ~30+-session history (dated subsections, no source tag) was **not** retroactively migrated — owner chose (via `AskUserQuestion`) to freeze it as-is rather than run a multi-session migration campaign to re-tag 303 already-closed entries. `CHANGELOG.md` now has a `## Legacy history (pre-ledger format, Sessions 1-324)` marker: everything below it is untouched original-format history; everything above it (from Session 325 forward) uses the canonical `[SOURCE]`-tagged format. New entries always go above the marker, never inside it. **A direct consequence for `methodology_trim.py` (found S518, 2026-08-11): the frozen legacy block is a permanently-pinned FOOTER (935,292 B / 3,570 lines as of S518), which the trim tool structurally cannot archive — `CHANGELOG.md`'s byte trigger will fire indefinitely regardless of how aggressively the ~S325-onward tagged records are trimmed, since the footer alone already exceeds the 65,536 B budget 14×. Routine trims of the tagged-record portion are still worth doing (real, if small, reduction) but do not by themselves resolve the file's read-truncation risk; only re-opening the S325 decision (a migration campaign) would.**

**S325 reopened, decision only (S546, 2026-08-13, owner-directed via `AskUserQuestion`):** presented with 3 options — (a) scope a lighter bulk relocation of the frozen legacy block into its own archive file as-is, no per-entry re-tagging; (b) commit to the full multi-session re-tag campaign this note originally declined; (c) hold as a permanent known limitation — the owner picked (a). `BACKLOG.md` Housekeeping now carries the scoping/verification item (READY, Effort M): a future session must confirm the relocation doesn't break `methodology_trim.py`'s L1/L2/L3 losslessness invariants and that no script/audit expects the legacy block inline, before moving it. (b) and (c) remain valid fallbacks if that verification finds a blocker — not discarded, just not attempted first. This is a decision-only entry; no file has moved yet.

**S325 verified and executed (S547, 2026-08-13):** both verification checks passed, and the relocation was executed the same session (the item's own "if verification allows, execute" framing). **Check 1 (`methodology_trim.py` L1/L2/L3):** the legacy footer contains zero triple-or-more backtick/tilde fence markers anywhere (confirmed by grep and by walking the tool's own `fence_scan()` over the extracted content) — the fence-scanner defect class found against `SESSION_NOTES.md` (`CLAUDE.md`'s own note above) cannot occur here, there is nothing fence-shaped to misparse. `classify_zones()` run directly against the post-relocation content reports zero findings (footer cleanly empty, all 13 records intact), and a real `--check` run against the modified working tree (before commit) reports `[CHECK] trigger does not fire` at 20,929 B — down from 954,673 B. **Check 2 (nothing expects it inline):** grepped `docs/`, `bin/`, `*.py` for "Legacy history"/"pre-S325"/"pre-ledger format" — no script or tool has a live, mechanical dependency on the block's location; `methodology_trim.py`'s own `archive_events()` discovers shards by glob + a live-file-size-drop check, not by filename parsing, so the new shard's non-`-through-<date>` name (`CHANGELOG-legacy-pre-S325.md`, chosen because this is a one-time bulk move, not a dated cut) is still correctly picked up. The only references found were prose in already-closed planning docs (`docs/planning/issue{137,146,147,149,151}-*.md`, each with a stale "close-out prepends an entry above `## Legacy history`" checklist line) and historical narrative in frozen archive shards/`PROJECT_LEARNINGS.md` — left untouched, matching the project's standing precedent against retroactively editing completed/frozen documents. **Executed:** the block (935,287 B / 3,567 lines, byte-for-byte verified against what `classify_zones()` reported as the footer before any edit) moved to [`docs/archive/CHANGELOG-legacy-pre-S325.md`](docs/archive/CHANGELOG-legacy-pre-S325.md); `CHANGELOG.md`'s "shard convention" section and its live-pointer paragraph updated to describe the new location; `CHANGELOG.md` is now 20,929 B / 283 lines, both triggers clear. **Side effect, not previously anticipated:** because `archive_events()`'s SRF baseline is now this new shard (pre=954,673 B, post=20,929 B), the SRF denominator for future `CHANGELOG.md` archive-refusal checks becomes ~934,000 B — resolving, for a long while, the small-denominator `SRF_RED` false-refusal pattern Learnings 549/550 diagnosed. See `PROJECT_LEARNINGS.md` for the full verification record.

**`methodology_trim.py` local-customization checklist (found S518, 2026-08-11):** `methodology_trim.py` is a canonical-**overlay** file per `BOOTSTRAP.md`'s sync table ("Tracked (canonical owns them) ... overlay — replace with the latest"), but its `LEDGERS` config table is the tool's own documented per-adopter extension point (a file with no entry exits `NO_CONFIG` by design — "a generic rule is what would mis-zone a differently-shaped ledger"). This project has added a **local, uncanonical** `SESSION_NOTES.md` entry (verified against all 577 record-start headings in the file, zero shape variance) that the design doc names no mechanism for surviving a sync overlay. **Any session that runs `chore(methodology): sync framework update from canonical` on this file must re-diff it against the pre-sync copy first and re-add this project's `SESSION_NOTES.md` `LedgerSpec` entry (and its `_session_notes_date` helper) if the sync dropped it** — check `git log -p --follow -- methodology_trim.py` for the S518 commit (`feat(methodology): add local SESSION_NOTES.md ledger config`) if it's unclear what was lost. A `NO_CONFIG` result on `python3 methodology_trim.py --file SESSION_NOTES.md --check` after a sync is the signal this happened.

**`SESSION_NOTES.md` archive blocked by a fence-scanner defect (found S518, 2026-08-11):** the `SESSION_NOTES.md` `LedgerSpec` config above is verified structurally correct, but its first archive was **not run**: `methodology_trim.py`'s simplified fence-scanner (`_FENCE = re.compile(r"^(\`{3,}|~{3,})(.*)$")`, matched against fenced fenced *block* delimiters) misreads `SESSION_NOTES.md:23229`'s 4-backtick-delimited *inline code span* (`` ```` ```{r}/```{R}```` `` `` — a legitimate way to show literal triple-backtick text inline) as an unclosed block-fence opener, because it starts a physical line. This puts the entire remainder of the file (17,040 of 40,269 lines, 42%) into a false "inside a fence" state, hiding 349 of 513 real session-record headings from the partition — provably lossless if trimmed as-is (L1/L2/L3 still hold), but structurally wrong (real per-session record boundaries collapse into one oversized chunk). Not fixed S518: fixing it means either editing `SESSION_NOTES.md`'s own historical content (altering a frozen record, out of scope for a housekeeping session) or patching the canonical tool's fence-scanning logic (a deeper canonical-file edit than the config addition above, and this project's problem to raise upstream, not silently patch locally). **A future session should pick one of those two fixes — probably rewrapping the one offending paragraph so the 4-backtick sequence doesn't open a physical line, the smaller and more local change — then re-run `python3 methodology_trim.py --file SESSION_NOTES.md` and confirm the record count returns to something near 513 (not 164) before trusting `--write`.**

### Development Process Contract override

This project runs **Strict Test-Driven Development** (see the "Development Process Contract" section above). This is a project-specific override of the base methodology's general development guidance: tests are written before implementation, every response declares its TDD phase (RED / GREEN / REFACTOR), and phase transitions require permission. It supersedes general coding instincts but operates *within* the SESSION_RUNNER protocol (orient → one deliverable → close out). Implementation and bug-fix sessions therefore follow the chosen workstream **and** the RED→GREEN→REFACTOR gates.

### Project-specific Learnings

Project institutional memory (Sessions 1–572+; 577 learnings, ~2.4 MB) lives in [`PROJECT_LEARNINGS.md`](PROJECT_LEARNINGS.md) — extracted from this file to keep `CLAUDE.md` within its size budget (Claude Code targets ~200 lines / ~25 KB). **Read it when you need prior-session context; append new learnings there, not here.** Base methodology-level learnings remain in `SESSION_RUNNER.md`.

### Project-specific Failure Modes

(none — the base failure modes #1–27 in `SESSION_RUNNER.md` apply, including #26
"mega-session masquerading as a vertical slice" and #27 "unrecorded action,"
added by the 2026-07-08 methodology sync to v3.4.)
