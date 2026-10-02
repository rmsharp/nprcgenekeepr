# Docs staleness audit, slice 7b: the living internal docs (2026-10-01, S852)

Read-only audit. Nothing in the repo was changed except this report and the session records.

## Audit summary

- **Scope (owner-chosen):** `ROADMAP.md` (57 lines), `CLAUDE.md` (266), `BACKLOG.md` (599),
  `docs/architecture/module-contract.md`, `docs/conventions/CLOSEOUT_CHECKLISTS.md`,
  `docs/conventions/ROXYGEN_EXAMPLES_POLICY.md`, `docs/setup/labkey-authentication.md`.
  **Not covered:** `docs/planning/` (84 files), `docs/research/`, the older `docs/audits/` reports; they are
  dated records, a later slice.
- **Criterion:** does each checkable claim (path, line number, count, function or argument name, status word,
  issue state, version, date) still match today's repo? Does `BACKLOG.md` hold only open work?
- **Method:** four read-only subagents (ROADMAP + CLAUDE.md; BACKLOG halves 1-300 and 300-599; the four `docs/`
  files). This session then re-ran or re-read the evidence for 9 of the 10 moderates and most minors (column
  "Check": **S** = this session re-checked; **A** = agent only).
- **Coverage:** 7 of 7 files. About 270 claims checked by the agents (62 + 60 + 55 + 95); the great majority hold.
  `labkey-authentication.md`: no discrepancy. No wrong function name, default or credential order was found in the
  `docs/` files.
- **Findings:** 0 critical, **10 moderate, 25 minor** (35). The staleness is of three kinds: (a) `ROADMAP.md` is
  mostly a 2026-06 snapshot (reversed alias, a "planned" list that has shipped); (b) `BACKLOG.md` line citations
  and a regrowth figure have drifted, and its docs-audit item still describes a state S831 changed; (c) small
  slips in the conventions and architecture docs.
- **No code defects found.** Two code-side candidates are noted at the end.

## Findings: Moderate

| ID | Location | Claim | Evidence | Fix | Check |
|---|---|---|---|---|---|
| RO1 | `ROADMAP.md:10` | "`runGeneKeepR()` is a deprecated alias for `runModularApp()`" | Reversed. `R/runModularApp.R:28-38` is the deprecated one (`lifecycle::deprecate_soft`, then calls `runGeneKeepR()`). `CLAUDE.md` states it correctly. | Swap the names | S |
| RO2 | `ROADMAP.md:10-11, 15-16` | "Remaining work is integration testing and CRAN-submission preparation"; Planned: "CRAN submission preparation" | Tag `v2.0.0` exists; `NEWS.md` has `2.0.0 (20260721)`; the CRAN plan and runbook are in `docs/planning/`. The package is at 2.0.0.9000. Acceptance on CRAN not verifiable offline | Restate or drop; re-check the integration-testing item | S |
| RO3 | `ROADMAP.md:30-34` | Audit follow-ups list "NEW-20 (delete dead `makeGeneticDiversityDashboard.R`)" and "`create_test_app` test-infrastructure debt" | `R/makeGeneticDiversityDashboard.R` does not exist (NEW-20 done); `create_test_app()` is defined at `tests/testthat/helper-shinytest2.R:200`. Of the listed ids only NEW-53 is in `BACKLOG.md` (as fixed), though the sentence says "open items in `BACKLOG.md`". NEW-45, PED-1, NEW-17, NEW-13, NEW-23 not checked against code | Remove the two done items; re-verify the rest or drop the list | S (A for the other ids) |
| RO4 | `ROADMAP.md:28-30` | "Articles so far (S107-S110): ... four articles" | `vignettes/articles/` has 10 `.qmd` files | Point to the directory instead of listing | S |
| BA1 | `BACKLOG.md` docs-audit item, "Measured 2026-09-26" | "both PDFs are UNTRACKED renders ... `.gitignore:21` ignores ... not `vignettes/articles/*.pdf`" | `kinship2-fidelity-validation.pdf` is TRACKED (`git ls-files`). `pedigree-diagram.pdf` was untracked by `3a8c026bb` (S831) and is gone from disk. The slice-1 "Open" still says the owner decides delete-or-ignore for "the two PDFs" | Rewrite: one PDF remains and it is tracked; narrow the owner decision to it | S |
| BA2 | `BACKLOG.md` docs-audit item, slice 1 "Open" | "fix the stale 'defaulting to direct' comment at `R/modPedigree.R:440-443`" | Lines 440-443 now hold the 962-individual focal-trim comment. The "direct" default comment is at about `:458-461`. Still present | Cite `:458-461` | S |
| BB1 | `BACKLOG.md:448` | "Regrowth check: 378 lines now; the file was 480 lines after S752 and 561 before this pass" | `wc -l BACKLOG.md` = 599, so it has regrown 221 lines since 2026-09-24 | Update to 599 and say it regrew | S |
| BB2 | `BACKLOG.md` ledger-size item, "Candidates for the next pass: none" | "every remaining `##` section holds open items" | Follows from BB1: the heavy narrative items (the docs-audit item, the chromote item) are the next compression candidates | Re-measure at pick time, or reword | A |
| BB3 | `BACKLOG.md:345` | "incidental to the chromote CDP-timeout fallback fix below, READY" | No such item below; `grep chromote` hits only lines 345-365. The item is tagged READY but headed "Optional, low priority ... not required" | Drop "below" or cite the CHANGELOG entry; tag "READY (optional)" | S |
| BB4 | `BACKLOG.md` kinship2-package item | "`R/shrinkPedigree.R:227-380`" and "`R/modPedigree.R:675-790`: legend/image-export/tooltips" | `shrinkPedigree.R` is 368 lines, so 227-380 is out of range; helpers are `.bitSizeOf` (:203), `.findUnavailable` (:226), `.findAvailAffected` (:339), and `bitSize` is a returned field. `modPedigree.R:675` is a comment; the legend/export code is about 689-806 | Cite by function name, or the current ranges | S (shrink) / A (modPedigree) |

## Findings: Minor

| ID | Location | Claim / problem | Evidence / fix | Check |
|---|---|---|---|---|
| RO5 | `ROADMAP.md:24` | "`inst/extdata/meeting_notes.Rmd` → `.qmd`" | Now `dev/extdata-scratch/meeting_notes.qmd` (moved by `e161dd02b`). Fix the path | A |
| RO6 | `ROADMAP.md:6` | "(see `NEWS.md` 1.1.0.9000)" | No such heading in `NEWS.md` (re-grepped: only nprcmanager 0.5.x and 1.0.x/2.0.x). Cite the real heading or drop | S |
| RO7 | `ROADMAP.md:6-8` | Module list names 7 modules | `R/` has 15 `mod*.R` files. Say "and others" | A |
| RO8 | `ROADMAP.md:17-23` | Quarto slices 3 and 4 (the manual leaving the CRAN set) | `a3manual.Rmd` is still a CRAN vignette; slice status not stated and not determinable here. Add a status line | A |
| RO10 | `ROADMAP.md:54-57` | "Completed Milestones ... Details in `CHANGELOG.md`" | The NEW-/PED- ids are only in `docs/archive/CHANGELOG-legacy-pre-S325.md` | A |
| CL1 | `CLAUDE.md:123` | "`Suggests`-only package (`testthat`, `dplyr`, `mockery`, `roxygen2`, `shinytest2`, `shinyBS`, `devtools`, `quarto`)" | `DESCRIPTION` Suggests has no `roxygen2`, `devtools` or `quarto` (re-read). Say "dev-only packages" or fix the list | S |
| CL2 | `CLAUDE.md:129` | "so `bin/sync` stays friction-free" | No `bin/` directory in this repo; it is the upstream methodology tool. Say so | S |
| CL3 | `CLAUDE.md:218-221` | "Expected state ...: no file over its ceiling" | Today `SESSION_NOTES.md` is red on the 280 B per-line ceiling (one 359 B line), not the size ceiling; the text names only the size trim | Add the line-ceiling case | S |
| BA3 | `BACKLOG.md` isAddedRecord / convertDate items | `R/convertDate.R:103`, `R/removeDuplicates.R:46` | The masks are at `:113` and `:48` (`:103` and `:46` are an example and a comment) | Update cites | A |
| BA4 | `BACKLOG.md` convertDate reportErrors item | `R/getDateErrorsAndConvertDatesInPed.R:36`, `:37-41` | Assignment is at `:38`; `invalidAndAdded` `:39-42`, `sb[-invalidAndAdded, ]` `:43` | Update cites | A |
| BA5 | `BACKLOG.md` "Found S789" | "`_pedigree_browser.Rmd:56` words the Diagram limit as ... 750 ..." | Fixed S828; the text is now at `:65` | Mark fixed S828, drop the cite | A |
| BA6 | `BACKLOG.md` PED_GV item | "28 bare-literal comparison lines in 10 files remain" | An agent grep (not the report's own regex) found 32 lines in 13 files. Not a firm contradiction | Date the count ("measured S781") | A |
| BA7 | `BACKLOG.md` kinship2-package item | `R/shrinkPedigree.R:227-380` | Same as BB4 (the `.bitSizeOf` helper at `:203` is outside the range) | Cite by name | S |
| BB5 | `BACKLOG.md` | "`makePedigreeMatingLayout(kinshipMatrix = )` (`R/makePedigreeDiagramData.R:1685`)" | Defined at `:1661`, argument `:1664`; `:1685` is a comment | Cite `:1661` | A |
| BB6 | `BACKLOG.md` | "`vignettes/a2interactive.Rmd:4-7`" | `output:` at `:4`, `df_print: paged` at `:6` | `:4-6` | A |
| BB8 | `BACKLOG.md` ledger-trimmer item | "`docs/planning/ledger-trimmer-design.md` §10.2" | File does not exist in `docs/planning/` (re-listed) | Fix the path or say it lives upstream | S |
| BB11 | `BACKLOG.md:461` | "the Diagram section of `NEWS.Rmd` says 'most of kinship2's conventions' until both ship" | The phrase is not in `NEWS.Rmd` (grepped; S851 reworded the section) | Quote the actual sentence (`NEWS.Rmd:33-35`) | S |
| BB13 | `BACKLOG.md` pass history | Cites S529, S530, S531, S606, S752, S738/S744-746 and says "see CHANGELOG.md" | Those entries are in `docs/archive/CHANGELOG-through-*.md`, not the live file | Name the archive | A |
| AR1 | `module-contract.md:62-67` | "`gestationTable` is passed ... as a bare `reactiveValues` read" | `R/appServer.R:507-508` passes two bare reads, `gestationTable` and `gestationDefault` (re-read); the in-code comment at `modPotentialParents.R:241-244` is about `gestationDefault` | Name both | S |
| AR2 | `module-contract.md:79-80` | "does not mechanically check rules 1, 3, 5, or 6" | Header (`:12-13`) says rules 1 and 3-6 (re-read); rule 4 is missing here | "1 and 3-6" | S |
| AR3 | `module-contract.md:36-38` | "~53 real test assertions across 4 files" | Matches Learning 347, but an agent grep could not reproduce it | Re-count or drop the number | A |
| CV1 | `ROXYGEN_EXAMPLES_POLICY.md:16` | "Every directly callable exported function carries an `@examples` block" | Of 234 exports, 35 of the 36 without `@examples` are in the exempt categories; `getGeneticDiversityStats()` (`R/getGeneticDiversityStats.R:51` `@export`) is directly callable and has none | Add an example, or a note | S (export) / A (count) |
| CV2 | `ROXYGEN_EXAMPLES_POLICY.md:59-65` | `\dontrun{}` only for LabKey/network, app launch, or an unshipped resource | `savePlotToFile` uses it for a local write that could use `tempdir()`; `readTwinRelations` and `readKinshipOverrides` are borderline | Fix the `savePlotToFile` example, or note the borderline cases | A |
| CV3 | `ROXYGEN_EXAMPLES_POLICY.md:31` | "A deprecated *launcher* (`runGeneKeepR`)" | `runGeneKeepR` is the current launcher; the deprecated one is `runModularApp` (same as RO1) | Rename | S |
| CV4 | `CLOSEOUT_CHECKLISTS.md:27` | "(Sessions 1-324, ~935 KB)" | The archive file is 936,976 B, about 937 KB | "~937 KB" or leave | A |

## Not verified

- Whether 2.0.0 is accepted on CRAN (RO2); whether Quarto slices 3 and 4 shipped (RO8); the NEW-45, PED-1, NEW-17,
  NEW-13 and NEW-23 ids against code (RO3).
- The PED_GV triage tallies, the S789 male-left measurements, the `getAncestors` probe figures, the "14 analysis
  tabs" count (a loose grep gave 20, not the report's definition), the tarball sizes (4.38 / 3.49 MB), the Row-order
  node counts, `inst/doc/` size (the directory does not exist in the working tree), and the claims about `moments`
  and `e1071` not being installed.
- The LabKey admin-console menu path and the netrc URL (external); `R CMD check --as-cran` claims in the roxygen
  policy (not run); whether other modules make bare `reactiveValues` reads beyond `appServer.R:507-508`.
- Line numbers in the second-half BACKLOG agent's report were off by about 45 against the file; only citations
  re-read by this session carry an **S**.

## Code candidates (owner decisions, not part of the doc fixes)

1. `getGeneticDiversityStats()` is exported and directly callable but has no `@examples` (CV1): add an example, or
   record it as an exemption.
2. `savePlotToFile` example uses `\dontrun` for a local write (CV2).

## Slice status

Slice 7b audited. Fixes are not applied in this session (the item is one audit report per session). Next: apply the
35 findings (separate session, docs only; BACKLOG.md edits last, since it is also the hand-off ledger), then slice 7c
(`docs/planning/`, `docs/research/`, older `docs/audits/`).
