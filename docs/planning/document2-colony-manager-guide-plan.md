# Plan — Document 2: Purpose, Approach, and a Colony Manager's Guide to Practice
(public Quarto pkgdown article)

**Status:** Plan written Session 345 (DRAFT). Owner confirmed article form (new
`vignettes/articles/*.qmd`, not a README rewrite or external paper) and audience
(primate-center bioinformatics / colony managers) via `AskUserQuestion`, Session 345
(2026-07-10). Owner then confirmed the content strategy — **port and modernize
`ColonyManagerTutorial.Rmd`** rather than draft from scratch — via a second
`AskUserQuestion`, Session 345 (2026-07-10), after this session's research surfaced
that the target content already exists in two places (§1). Owner ratified §11
decisions 1/2/5 (tab-coverage extent, screenshot method, title/slug) via
`AskUserQuestion`, Session 346 (2026-07-10) — **Phase A DONE** (§3A, §6). **Phase B
(screenshot regeneration) is now DONE** (Session 347, 2026-07-10) — see §6 Phase B for
the capture script, corrected dispositions, and two new functional findings (Excel-upload
data corruption; non-functional Custom sex-ratio control) recorded to `BACKLOG.md`.
Phases C-D remain future, separately approved sessions each; no phase is bundled with
another (FM #26).

**Workstream:** Adapted `docs/methodology/workstreams/RESEARCH_DOCUMENTATION_WORKSTREAM.md`
(Phases 2/3/4/6), matching Document 1's own adaptation
(`docs/planning/v2-transformation-article-plan.md`) — substituting this project's own
artifacts (source tree, existing vignettes, `NAMESPACE`, live app structure) for the
workstream's external-bibliography model. Unlike Document 1, this document's claims are
almost entirely about **current static package structure and existing prose**, not a
historical commit range — see §5's reproducibility note for how that changes the
evidence-base approach.

**Companion documents (explicitly not re-scoped here):** Document 1
(`vignettes/articles/engineering-the-2.0.0-release.qmd`, DONE) is the engineering/process
narrative. The six existing feature articles
(`age-sex-pyramid.qmd`, `breeding-group-formation.qmd`, `fg-se-validation.qmd`,
`genetic-value-analysis.qmd`, `offline-focal-animal-workflow.qmd`,
`studbook-quality-control.qmd`) remain the feature-depth references this article points
to rather than duplicates.

---

## 1. Context and a load-bearing discovery

`BACKLOG.md` describes Document 2 as: "package purpose, how it addresses that purpose,
and how to put it into use." Explicitly deferred out of Document 1's plan (S330) to its
own future planning session per the owner's 2026-07-09 instruction; named as a next step
in five straight handoffs (S336, S339, S341, S343, S344) and never picked up until this
session.

**Before drafting anything, this session surveyed what documentation already exists**
(per the "check process history before re-running work" discipline) and found that the
content Document 2 is meant to cover is **not greenfield** — it already exists, in two
different places, in two different states of completeness and visibility:

1. **`vignettes/a3manual.Rmd` + `vignettes/manual_components/*.Rmd`** (13 child files) —
   a CRAN-shipped manual (not `.Rbuildignore`d), actively maintained (edits as recent as
   2026-07-08, two days before this session — `git log -1 -- vignettes/manual_components/`).
   Its `_introduction.Rmd` and `_summary_of_major_functions.Rmd` components are the
   **same source files** `README.Rmd` builds from (`README.Rmd:32-44` `child=`s the
   identical paths) — README and this manual already share one source of truth for
   *purpose* and *approach*. Beyond that shared core, the manual adds real per-feature
   usage sections (`_input.Rmd`, `_pedigree_browser.Rmd`, `_genetic_value_analysis.Rmd`,
   `_summary_statistics.Rmd`, `_breeding_group_formation.Rmd`, `_gv_and_bg_desc.Rmd`,
   `_orip_reporting.Rmd`) plus two algorithm appendices
   (`_breeding_group_algorithm.Rmd`, `_genome_uniqueness_algorithm.Rmd`) and
   `_software_development.Rmd`.
2. **`vignettes/ColonyManagerTutorial.Rmd`** (748 lines) — a screenshot-illustrated,
   step-by-step tutorial literally titled *"GeneKeepR: A Colony Manager's Tutorial"* —
   the exact audience confirmed for Document 2. Covers: Introduction, Installation,
   Uploading a Pedigree File, Pedigree Browser (incl. Unknown IDs, focal-animal
   selection/trimming), Pedigree Age Plot, Genetic Value Analysis, Summary Statistics,
   Breeding Group Formation. **Excluded from the CRAN build**
   (`.Rbuildignore:31`, `^vignettes/ColonyManagerTutorial\.Rmd$`) and not part of the
   public `vignettes/articles/` set either — so despite being actively kept in sync with
   API changes (`git log`: last touched 2026-07-07, migrating `minParentAge` references
   to `minSireAge`/`minDamAge` per issue #119 — the prose at L171-181 explicitly notes
   the current split-field UI while acknowledging the *screenshot* still shows the old
   single-field layout), **it is currently invisible to any reader.**
   Its screenshots (`vignettes/shiny_app_use/*.png`) were last regenerated 2024-12-16
   (`git log -1 -- vignettes/shiny_app_use/`) — **before** the Shiny-module migration
   (Session 22-35, 2026-06-03 to 2026-06-06) — so republishing as-is would show a UI that
   no longer exists.

**Owner-ratified conclusion (this session):** Document 2's plan targets **porting and
modernizing `ColonyManagerTutorial.Rmd`** into a new `vignettes/articles/*.qmd`, using it
(and the shared `_introduction.Rmd`/`_summary_of_major_functions.Rmd` purpose/approach
content) as **primary source material to adapt and re-verify**, not a blank page to
draft from scratch. This closes the "good content, not public" gap directly, and
directly satisfies all three parts of `BACKLOG.md`'s framing (purpose / approach /
usage) using material that already exists and is already mostly accurate.

### A separate, smaller finding (flagged, not fixed here)

`inst/_pkgdown.yml`'s curated Reference-page grouping ("Data objects" / "Major Features
and Functions" / "Primary interactive functions" / "All exposed functions") is **dead
configuration** — confirmed this session via `pkgdown:::pkgdown_config_path`
(`asNamespace("pkgdown")$pkgdown_config_path`), which resolves the **first existing**
file from `_pkgdown.yml`, `_pkgdown.yaml`, `pkgdown/_pkgdown.yml`,
`pkgdown/_pkgdown.yaml`, `inst/_pkgdown.yml`, `inst/_pkgdown.yaml` in that order; the
project's root `_pkgdown.yml` exists (and has no `reference:` key), so
`inst/_pkgdown.yml` is never reached. Confirmed live on the deployed site
(`https://rmsharp.github.io/nprcgenekeepr/reference/index.html`, fetched this session):
a single flat "All functions" alphabetical list, not the grouped structure
`README.md:86-94` describes. Independently, `inst/_pkgdown.yml`'s own lists have drifted
from `NAMESPACE`: of 182 current exports, 64 are absent from its "All exposed functions"
list (incl. every `mod*Server`/`mod*UI` pair, `appServer`/`appUI`, `runModularApp`, and
newer functions like `getPotentialParents`, `applyKinshipOverrides`,
`setLabKeyDefaults`) — yet `git log` shows this file has been genuinely, actively
maintained (S161, S171, S205, S285, S300), so it is shadowed *and* independently stale,
not abandoned.

This matters to Document 2 because the natural next step for a reader after this article
is "browse the Reference page" — citing the intended grouped structure as live would be
a claim-source-audit failure baked into the article at birth. **Not fixed in this
session** — out of this session's declared scope (planning Document 2, not fixing
pkgdown config). Recorded as a new `BACKLOG.md` item at close-out. Document 2's own
drafting phase must re-verify the Reference page's live state at draft time (§9 dragon
5) rather than assume either the stale grouped structure or today's flat list.

---

## 2. Scope decisions (owner-confirmed this session)

- **Article form: new standalone public `vignettes/articles/*.qmd`** (`AskUserQuestion`,
  2026-07-10) — not a README rewrite, not an external software paper. Same pkgdown
  pattern as Document 1 and the six existing feature articles
  (`docs/planning/quarto-documentation-future-proofing-analysis.md` §6-7, S105 — format
  already decided, not reopened here).
- **Audience: primate-center bioinformatics / colony managers evaluating or learning to
  use the package** (`AskUserQuestion`, 2026-07-10) — matches `ColonyManagerTutorial.Rmd`'s
  own stated audience and Document 1's domain-expert framing.
- **Content strategy: port and modernize `ColonyManagerTutorial.Rmd`**
  (`AskUserQuestion`, 2026-07-10, after this session's research — §1) — treat it (plus
  the shared `_introduction.Rmd`/`_summary_of_major_functions.Rmd` components) as primary
  source to adapt, not draft from scratch. Screenshots need regeneration against the
  current modular app (§9 dragon 1); prose needs re-verification against current package
  behavior, not carried forward uncritically (§9 dragon 2); coverage should extend to
  tabs added since the tutorial was last substantively written (§9 dragon 3, §12
  decision 1).
- **Toolchain: Quarto**, not an open decision (§1, matching Document 1 §1).
- **Reproducibility model differs from Document 1.** Document 1's claims spanned a
  historical commit range and needed frozen data files to prevent silent drift on
  re-render. Document 2's claims are almost entirely about **current static package
  structure** (tab list, export counts, article inventory) with no time-series element,
  so each claim's evidence is a directly re-runnable command (`grep`, `wc -l`,
  `NAMESPACE` inspection, live app inspection), date-stamped "(as of 2026-07-10)" per
  anti-pattern #16, rather than frozen into a CSV. **Exception:** any numeric claim
  carried over from `ColonyManagerTutorial.Rmd` that depends on the specific contents of
  the example pedigree used (row counts, living-animal counts, computation timings — §9
  dragon 2) must be **re-derived from the current example data**, not copied from the
  2019-2020-era tutorial text.

---

## 3. Evidence base (what this session verified directly)

| # | Claim | Verified value | Evidence |
|---|---|---|---|
| E1 | `vignettes/a3manual.Rmd` composes 13 child files from `vignettes/manual_components/` | Confirmed by direct read of `a3manual.Rmd` (57 lines, all `{r child=...}` includes) | `vignettes/a3manual.Rmd:29-56`, verified 2026-07-10 |
| E2 | `README.Rmd` and `a3manual.Rmd` share `_introduction.Rmd` and `_summary_of_major_functions.Rmd` as a single source | Both files `child=` the identical paths | `README.Rmd:32,43`; `vignettes/a3manual.Rmd:29-31` (via `manual_components/_summary_of_major_functions.Rmd`), verified 2026-07-10 |
| E3 | `manual_components/*.Rmd` actively maintained | Most recent touch 2026-07-08 (`_breeding_group_algorithm.Rmd`, `_genome_uniqueness_algorithm.Rmd`); others 2026-06-19 to 2026-07-07 | `git log -1 --format=%ad --date=short -- vignettes/manual_components/`, verified 2026-07-10 |
| E4 | `ColonyManagerTutorial.Rmd` is 748 lines, excluded from CRAN build, actively maintained | File read in full this session; `.Rbuildignore:31`; last touch 2026-07-07 (issue #119 slice 5 minParentAge migration) | `vignettes/ColonyManagerTutorial.Rmd` (full read); `.Rbuildignore`; `git log`, verified 2026-07-10 |
| E5 | `ColonyManagerTutorial.Rmd`'s prose is partially, not fully, current — e.g. it explicitly documents the current Minimum Sire/Dam Age split fields while noting the referenced screenshot still shows the old single-field layout | Direct read | `vignettes/ColonyManagerTutorial.Rmd:171-181`, verified 2026-07-10 |
| E6 | `vignettes/shiny_app_use/*.png` screenshots predate the Shiny-module migration | Last touch 2024-12-16, vs. migration Session 22-35 (2026-06-03 to 2026-06-06) | `git log -1 --format=%ad -- vignettes/shiny_app_use/`, verified 2026-07-10; migration dates per `docs/planning/v2-transformation-article-plan.md` §7 Phase B closure note |
| E7 | The current modular app mounts 10 tabs unconditionally plus 1 conditional (ORIP, ONPRC-only), grouped under a "More" menu for Settings/About/Help | Direct read of `R/appUI.R` tab structure | `R/appUI.R:137-260`, verified 2026-07-10 |
| E8 | `ColonyManagerTutorial.Rmd` covers 6 of those 10-11 tabs (Input, Pedigree Browser, Age-Sex Pyramid ["Pedigree Age Plot"], Genetic Value Analysis, Summary Statistics, Breeding Groups); it predates and does not cover Genetic Diversity (#112), Potential Parents (#48), the GV & BG Description tab, or Settings/About/Help | Cross-referenced E4's full read against E7's tab list | Direct comparison, verified 2026-07-10 |
| E9 | 182 exported functions in `NAMESPACE`; `inst/_pkgdown.yml`'s "Primary interactive functions" list names 58, its "All exposed functions" list names 159 (64 short of 182) | `grep -c "^export(" NAMESPACE` = 182; per-section `grep -c "^  - "` on `inst/_pkgdown.yml`; `comm -23` diff of sorted export lists | Verified 2026-07-10 (commands in this session's transcript) |
| E10 | `inst/_pkgdown.yml`'s reference grouping is dead configuration, shadowed by root `_pkgdown.yml`, confirmed live on the deployed site | `pkgdown:::pkgdown_config_path` inspected directly; live site fetched and confirmed flat "All functions" list only | Verified 2026-07-10 — see §1 sub-section |
| E11 | Issue #37 ("Exported functions not currently used by app") documents 127/182 exports reached by the app, 39 not, "by repeated owner decision... intended public API, not dead code" except one lone conditional-retire candidate (`safeExecute`) | `gh issue view 37 --json body` | Verified 2026-07-10 — informs the "two usage modes" framing (§4) without overclaiming API completeness |
| E12 | Six existing feature articles already exist and cover per-feature depth | `ls vignettes/articles/*.qmd` | Verified 2026-07-10 |

**Do not draft any section from this table's summary column alone** — each row points
to a re-runnable command or a specific file:line; the drafting session re-verifies
firsthand, matching Document 1's own claim-source discipline (its plan §3, "Do not draft
any section from the summary table alone").

---

## 3A. Phase A deliverable: Screenshot Gap Inventory and Numeric Claims Re-derivation
(Session 346, 2026-07-10)

### Screenshot Gap Inventory

Every `readPNG(...)`/`grid.raster(...)` reference in `ColonyManagerTutorial.Rmd` was
enumerated (34 distinct files in `vignettes/shiny_app_use/`) and cross-checked against
the current modular UI (`R/appUI.R`, `R/modInput.R`, `R/modPedigree.R`,
`R/modPyramid.R`, `R/modGeneticValue.R`, `R/modSummaryStats.R`,
`R/modBreedingGroups.R`) to assign a disposition. **"As-is" means the described control
still exists under the same label in the same conceptual location; "updated framing"
means the control exists but the surrounding layout, label, or feature set changed
enough that a straight re-shoot would misrepresent the current app.**

| Tutorial section | Screenshot(s) | Disposition | Evidence |
|---|---|---|---|
| Opening/Input (file-format info) | `opening_screen_top/middle/bottom.png` | **Retire these 3 crops; replace with 2 new captures** (Home tab landing + Input tab's "Input Format" sub-tab) | The tutorial's single long scrolling "opening screen" no longer exists — `R/appUI.R:43-134` now shows a separate Home dashboard tab, and format documentation moved into `R/modInput.R:178-193`'s dedicated "Input Format" sub-tab |
| Uploading a Pedigree (file examples) | `examplePedigreeTutorial.png`, `examplePedigreeTutorial_with_alleles.png` | Regenerate as-is | Static illustrations of the data file itself (opened in Excel/CSV), not app UI — unaffected by the Shiny-module migration |
| Uploading a Pedigree (browse control) | `opening_screen_top_red_oval.png`, `input_example_pedigree_xlsx.png` | Regenerate with updated framing | File selection is now a `conditionalPanel` `fileInput` gated on a "File Content" radio choice (`R/modInput.R:80-148`) that didn't exist in the tutorial's single "gray box" |
| Uploading a Pedigree (min. breeding age) | `input_minParentAgeSequence.png` | Regenerate with updated framing (already flagged stale by the tutorial's own prose, L178-181) | `R/modInput.R:152-157` confirms two separate `textInput`s (`minSireAge`/`minDamAge`), matching issue #119 |
| Upload/Check | `read_and_check_pedigree.png` | Regenerate as-is | Button label unchanged: `R/modInput.R:167` `"Read and Check Pedigree"` |
| Pedigree Browser (table/unknown IDs) | `pb_10_rows_display_unknown_ids.png`, `pb_unknown_displayed.png`, `pb_no_unknown_displayed.png` | Regenerate with updated framing | Sequential single-column layout replaced by a 3-column layout (docs / focal-animal input / display options) + `DT` table below, `R/modPedigree.R:29-153` |
| Pedigree Browser (focal animals, small example) | `pb_focal_animal_text_box.png`, `pb_5_focal_animals_small.png` | Regenerate with updated framing | Same textarea control (`R/modPedigree.R:62-66`), new 3-column surrounding layout. **The underlying "54 animals" number reproduces exactly (N2 below) — keep it.** |
| Pedigree Browser (large focal group) | `pb_selection_large_focal_group.png`, `pb_select_trim_for_focal_animals.png`, `pb_trimmed_for_focal_animals.png` | Regenerate with updated framing; **new focal-ID list required** | **The "85 animals" number does not reproduce (N3 below)** — the tutorial never records which IDs it used; Phase B/C must pick and explicitly record a new list |
| Pedigree Browser (clear focal animals) | `pb_cleared_focal_animals_combined.png` (+ `.idraw` source) | Regenerate with updated framing; **Phase B tooling decision** | Original is a hand-composed side-by-side image built from a `.idraw` source file — decide in Phase B whether to keep that hand-composition step or simplify to two plain captures |
| Pedigree Age Plot | `age_plot.png` | Regenerate with updated framing | `R/modPyramid.R` adds `ageUnit`/`colorScheme`/`showCounts` options and a `tabsetPanel` not described in the tutorial; core pyramid concept unchanged. **"332 living animals" reproduces exactly (N4) — keep it.** |
| Genetic Value Analysis (run controls) | `gva_calculating.png` | Regenerate with updated framing (mandatory) | Button renamed "Begin Analysis" -> "Run Analysis" (`R/modGeneticValue.R:48`); a new "Kinship Overrides" panel now sits alongside it (`R/modGeneticValue.R:52-82`) — genuinely new functionality absent from the tutorial |
| Genetic Value Analysis (results table) | `gva_first_high_value.png` | Regenerate with updated framing | "Show entries" replaced by an explicit "Show top N:" `numericInput` + an ID-filter textarea (`R/modGeneticValue.R:108-118`) |
| Genetic Value Analysis (High/Low Value cutover) | `gva_high_and_low_value.png` | Regenerate with updated framing; **prose must be rewritten, not just re-shot** | The ranking algorithm's treatment of parentage-less ("Undetermined") animals changed (issue #9 Slice 3, `R/modGeneticValue.R:289-301`): they are now demoted to the bottom of the ranking, directly contradicting the tutorial's claim that "Founders... are high value by definition." See N6 below — do not pre-guess a row number. |
| Summary Statistics | `ss_first_view.png`, `ss_kinship_matrix.png`, `ss_first_order_relationships.png`, `ss_female_founders.png`, `ss_trimmed_all_plots.png`, `ss_export_mean_kinship_coefficient_histogram.png` | Regenerate as-is | Tab title ("Summary Statistics and Plots") and every export button label confirmed unchanged verbatim or near-verbatim: `R/modSummaryStats.R:31,56,66,76,86` |
| Breeding Group Formation (initial view) | `breeding_group_first_view.png` | Regenerate with updated framing (mandatory — largest structural change of any covered tab) | New third sex-ratio option "Harem (1M:NF)" (`R/modBreedingGroups.R:55-58`, matching the Core Functions "harem group configuration" capability) not in the tutorial; results now shown in a `tabsetPanel` (Groups/Statistics/Group Detail, `R/modBreedingGroups.R:77-96`) replacing a single view. Port must add new prose for the Harem option, not just re-shoot. |
| Breeding Group Formation (number of groups) | `breeding_group_1.png` | Regenerate with updated framing | "Number of Groups Desired" -> "Number of groups:" (`R/modBreedingGroups.R:51`), same concept |
| Breeding Group Formation (seeded groups) | `breeding_group_6_infants_with_dam.png`, `breeding_group_first_group_no_kinship_seeds_indicated.png`, `breeding_group_6_seed_grps_grp_6_kinship.png` | Regenerate with updated framing | Checkbox labels essentially unchanged (`R/modBreedingGroups.R:65-70`); now rendered under the new "Groups" sub-tab |
| Breeding Group Formation (sex ratio) | `breeding_group_sex_ratio_specification.png` | Regenerate with updated framing; **number must be captured live, not pre-computed** | "User specified sex ratio of breeders" -> "Custom" choice alongside the new "Harem" option (`R/modBreedingGroups.R:55-58`). See N7 below. |

**Orphaned screenshots (in `vignettes/shiny_app_use/`, referenced by nothing — zero
hits searching `R/`, `vignettes/`, `docs/` outside the pkgdown build output):**
`bg_1.png`, `bg_6_infants_with_dam.png`, `bg_6_seed_grps_grp_6_kinship.png`,
`bg_first_group_no_kinship_seeds_indicated.png`, `bg_first_view.png`,
`bg_sex_ratio_specification.png` (6 files — stale pre-rename duplicates of the
`breeding_group_*` files above), `pb_clear_focal_animal_list.png`,
`pb_cleared_focal_animal_list.png` (2 files — superseded by
`pb_cleared_focal_animals_combined.png`). **Recommend deleting all 8 (+ evaluating the
`.idraw` source's fate) in Phase B**, after Phase B re-confirms zero references at that
time — not deleted in this planning-adjacent phase per `SAFEGUARDS.md` scope
discipline.

### Numeric Claims Re-derivation

Every number in `ColonyManagerTutorial.Rmd` tied to the specific example
pedigree/hardware (dragon 2, §8) was re-derived this session using the currently
shipped `data(examplePedigree)` (3,694 rows) and current package functions —
`Rscript -e` commands run 2026-07-10, reproduced in this session's transcript.

| # | Claim (location) | Re-derivation result | Verdict |
|---|---|---|---|
| N1 | L288: "reduces from 3,694 to 2,322... 1,372 UNKNOWN animals" | `nrow(examplePedigree)` = 3694; `sum(isGeneratedUnknownId(examplePedigree$id))` = 1372; non-unknown = 2322 | **Reproduces exactly — carry forward unchanged.** |
| N2 | L328: "You will end up with 54 animals" (focal IDs FJS7RQ, H6T2FF, HEVL3L, I04JZV, S63QDN) | 54, **only** when replicating the app's exact operation order: filter `isGeneratedUnknownId()` rows out first, **then** `trimPedigree(..., removeUninformative = FALSE, addBackParents = FALSE)` ancestors unioned with `getDescendantPedigree()` descendants (`R/modPedigree.R:329-343`). Filtering unknowns *after* trimming instead gives 87, not 54. | **Reproduces exactly given the correct order — carry forward, and state the order explicitly in Phase C's prose** (a plausible-looking but wrong 87 is one operation-order mistake away). |
| N3 | L379: "a total of 85 focal animals and their relatives" (unlisted "large focal group") | The shipped `focalAnimals` data object (327 ids) gives 962 after the same trim procedure, not 85. The tutorial never records which IDs produced 85. | **Not re-verifiable, remove.** Phase C must pick and explicitly record its own new focal-ID list for this example so the number is reproducible going forward. |
| N4 | L425: "332 living animals from the entire example pedigree" | `sum(examplePedigree$status == "ALIVE")` = 332 | **Reproduces exactly — carry forward unchanged.** |
| N5 | L491-493: "1000 iterations... 1 minute 38 seconds... example pedigree of 3,691 animals... MacBook Pro (Mid 2014)..." | 3,691 matches no current subset (3,694 total / 2,322 non-placeholder / 332 living) — a pre-existing inconsistency in the original 2019-2020 text, not something recent changed. Hardware-specific timing is inherently non-portable. | **Not re-verifiable as stated, remove.** Replace the animal count with the verified 3,694/2,322 (matching whichever population Phase C's walkthrough uses) and drop the hardware/timing sentence — or replace with a qualitative note pointing to `gvaConvergence()` (the tutorial's own already-current guidance at L460-477). |
| N6 | L510-515: "row 268 the values change from High Value to Low Value... Founders... are high value by definition" | Not a fixed fact even in principle: `R/modGeneticValue.R:289-301` (issue #9 Slice 3, D7) shows "Undetermined" (parentage-less, no recorded origin) animals are now deliberately demoted to the **bottom** of the ranking, not treated as automatically high-value. | **Not re-verifiable as stated, must rewrite.** Phase C corrects the prose to describe current demote-to-bottom behavior (cite `R/modGeneticValue.R:289-301`) and captures whatever row number the live run actually shows — do not pre-guess a number in Phase A. |
| N7 | L741-743: "sex ratio of 2.5 with 6 groups... 5 groups of 20 (14:6)... 1 group of 23 (16:7)" | Depends on `nIterations` and the exact ranked input population, neither pinned down by the tutorial's text; the tab has also gained the new "Harem" mode since this example was written. | **Defer to live capture in Phase C** — do not pre-compute in Phase A. Capture the number together with its Phase B screenshot from one live run, and state the `nIterations`/population choice explicitly in the article (the tutorial never did). |

---

## 4. Proposed document outline

1. **Abstract / TL;DR** (100-200 words — shorter than Document 1's, since this document
   is more a practical guide than a synthesis argument; written last)
2. **Introduction** — what this article is and who it's for; how it relates to Document
   1 (process/engineering) and the six feature articles (depth); explicit scope stamp
   ("as of 2026-07-10")
3. **Section 1 — Purpose: Why nprcgenekeepr Exists** — adapted from
   `manual_components/_introduction.Rmd` / `README.Rmd`'s shared source: the captive
   colony genetic-diversity management problem, the Vinson & Raboin (2015) methodology,
   the NIH grant acknowledgment
4. **Section 2 — Approach: The Five Function Groups and Two Ways to Use Them** — adapted
   from `_summary_of_major_functions.Rmd`; the five function groups (QC, pedigree
   creation, age-sex pyramid, GVA, breeding groups) mapped to the current app's tabs
   (E7/E8) and to the six existing feature articles (T1); the Shiny-app-vs-R-API framing
   informed by E9/E11 (stated carefully — "additional public API for specialized
   workflows," matching the project's own established framing, not "39 broken/unused
   functions")
5. **Section 3 — Practice: A Colony Manager's Walkthrough** (the bulk of the article,
   ported/modernized from `ColonyManagerTutorial.Rmd`) — Installation, Uploading a
   Pedigree, Pedigree Browser (incl. focal-animal selection), Age-Sex Pyramid, Genetic
   Value Analysis, Summary Statistics, Breeding Group Formation, plus **new subsections**
   for Genetic Diversity and Potential Parents (not in the source tutorial — §9 dragon 3,
   §12 decision 1)
6. **Conclusion** — pointers to the six feature articles for depth, to Document 1 for the
   engineering story, to the GitHub issue tracker for questions/bugs (matching
   `ColonyManagerTutorial.Rmd`'s own existing framing at L35-38), NIH grant
   acknowledgment

---

## 5. Proposed tables and figures

| # | Item | Purpose | Source | Generation |
|---|---|---|---|---|
| T1 | Function-group -> tab -> companion-article map (5 rows) | Orient the reader: which tab does which job, and where to read more | E7, E8, E12 | Hand-authored markdown table from verified current structure |
| T2 *(optional)* | API surface snapshot: Data objects / Primary interactive / All exposed counts, with the "as of 2026-07-10" stamp and a one-line pointer to issue #37's framing | Grounds the "two usage modes" claim without overclaiming | E9, E11 | Hand-authored, small — not worth a computed table for 3 numbers |
| F1 | Pipeline diagram: Studbook -> QC -> Pedigree -> {Age-Sex Pyramid, Genetic Value Analysis} -> Breeding Groups | Visual companion to Section 2, orients the walkthrough in Section 3 | Original construction from E7/T1 | Mermaid flowchart embedded in the `.qmd` (matches Document 1 F2's approach — no external image dependency) |
| Screenshots | Regenerated per-tab screenshots for every tab covered by Section 3 | The walkthrough's core illustrative material | Live modular app + example pedigree data | **Method to decide at Phase A kickoff (§9 dragon 1, §12 decision 2):** `shinytest2::AppDriver$get_screenshot()` driven by a checked-in script (reproducible, matches this project's existing E2E infrastructure) vs. manual capture. Either way, the generating script or manual-capture note must be checked into version control per the workstream's Figure Provenance rule. |

No frozen CSV data files are needed (§2's reproducibility note) — this article has no
historical time-series claims.

---

## 6. Phased session breakdown

Each phase is one session (`SESSION_RUNNER.md` "1 and done"). No phase may be bundled
with another (FM #26).

### Phase A — Finalize scope, gap inventory, and screenshot method · risk MEDIUM (foundational) · ✅ DONE (Session 346)

> **✅ Implemented in Session 346 (2026-07-10), whole phase, no split.** Resolved §11
> decisions 1/2/5 via `AskUserQuestion`: tab coverage extends to **both** new tabs
> (Genetic Diversity #112, Potential Parents #48); screenshot method is **automated**
> (`shinytest2::AppDriver`-driven, checked-in script, manual post-processing only where
> a specific illustrative point needs it); title/slug confirmed as proposed
> (`vignettes/articles/colony-manager-guide.qmd`). Completed the Screenshot Gap
> Inventory (§3A) — all 34 screenshots referenced by `ColonyManagerTutorial.Rmd`
> individually dispositioned against the current modular UI, plus 8 orphaned
> pre-rename duplicate screenshots identified for Phase B deletion. Completed the
> Numeric Claims Re-derivation (§3A) — 7 example-data-dependent claims individually
> re-derived: 3 reproduce exactly and carry forward unchanged (N1, N2, N4), 2 do not
> reproduce and are flagged not-re-verifiable/remove (N3, N5), 2 are deferred to live
> capture in Phase C because they are simulation/algorithm-output artifacts that a
> pre-computed Phase A number could not actually pin down (N6, N7). **One correction to
> §1's own framing surfaced by this session's firsthand code reading (not carried
> forward uncritically):** the Genetic Value Analysis ranking algorithm's treatment of
> parentage-less "Undetermined" animals has genuinely changed since the tutorial was
> written (issue #9 Slice 3) — the tutorial's "Founders... are high value by
> definition" claim is now factually wrong, not merely stale wording; Phase C must
> rewrite that prose, not just refresh its screenshot. **Next: Phase B** (screenshot
> regeneration — highest-risk phase, dragon 1).
>
> **What DONE looks like (original criteria — all three met):** (1) `AskUserQuestion`
> at kickoff resolving §11 decisions 1-2 (tab coverage extent, screenshot-regeneration
> method) and confirming the proposed title/slug; (2) a completed gap inventory — for
> every screenshot in `vignettes/shiny_app_use/` referenced by
> `ColonyManagerTutorial.Rmd`, a stated disposition (regenerate as-is / regenerate with
> updated framing / retire because the UI element no longer exists); (3) for every
> numeric claim in `ColonyManagerTutorial.Rmd` tied to example-data specifics (row
> counts, living-animal counts, timing claims), a re-derived current value or an
> explicit "not re-verifiable, remove" verdict.
> **Verification:** the gap inventory (§3A table 1) and re-derived numbers (§3A table
> 2) are the artifact — no render yet, matching the session boundary below.
> **Session boundary respected:** produced the inventory and decisions only; no `.qmd`
> prose, no screenshots — those are Phases B/C.

### Phase B — Regenerate screenshots · risk HIGH 🐉 (see §9 dragon 1) · ✅ DONE (Session 347)

> **✅ Implemented in Session 347 (2026-07-10), whole phase, no split.** Spike-tested
> `shinytest2::AppDriver$get_screenshot()` against the running modular app first (per
> S346's handoff) — it works cleanly; dragon 1's raciness concern was about *client-side
> stability waits* on long-running computations (GVA, breeding-group formation), not the
> screenshot mechanism itself, and was resolved with `wait_ = FALSE` / selector-based
> clicks (`click_element_safe()`, this project's own E2E helper) plus explicit
> `wait_for_module_ready()` polling — matching the project's established E2E-test
> convention exactly. Built the checked-in capture script
> (`vignettes/articles/colony-manager-guide-screenshots.R`), driven against
> `data(examplePedigree)` via the live modular app. **Filename disposition:** the 25
> screenshots Phase A dispositioned "regenerate as-is"/"regenerate with updated framing"
> keep their original filename (replaced in place); 4 NEW filenames were introduced only
> where Phase A's inventory said "retire" (`home_tab_landing.png`,
> `input_format_subtab.png` replacing the 3 retired `opening_screen_top/middle/bottom.png`
> crops; `pb_focal_animals_before_clear.png`/`pb_focal_animals_after_clear.png` replacing
> the retired hand-composed `pb_cleared_focal_animals_combined.png` + its `.idraw`
> source — simplified to two plain sequential captures, since this project's toolchain has
> no crop/annotate tool). **Framing decision (resolves dragon 1's other half):** every
> screenshot captures the relevant module's whole panel
> (`#<module>-moduleContainer`, or the full viewport for Home) rather than reproducing the
> old tutorial's hand-cropped/annotated style — documented in the script's header comment.
> Deleted the 8 confirmed-orphaned pre-rename duplicate screenshots (§3A) after
> re-confirming zero references outside this plan document itself.
>
> **Two Phase-A dispositions corrected this session, on firsthand evidence (not carried
> forward uncritically):** (1) `ss_kinship_matrix.png`, `ss_first_order_relationships.png`,
> and `ss_female_founders.png` are — like `examplePedigreeTutorial.png` — illustrations of
> an *exported CSV's contents opened in a spreadsheet program*
> (`ColonyManagerTutorial.Rmd` L549/L564/L580, "The first few rows of such a file are
> shown below"), not app UI; `shinytest2::AppDriver` cannot produce them and Phase A's
> "regenerate as-is" disposition for these 3 was a category miss. Left untouched,
> matching the treatment already given the 2 `examplePedigreeTutorial*` files. (2) the
> Pedigree Browser table's client-side DT search box
> (`app$set_inputs("pedigree-pedigreeTable_search", ...)`) is not a bound Shiny input in
> this table's configuration (confirmed: errors "Unable to find input binding") — so
> `pb_unknown_displayed.png` captures the same default view as
> `pb_10_rows_display_unknown_ids.png` rather than a rows-filtered-to-UNKNOWN-only view;
> documented duplication, not a silent gap.
>
> **Two NEW functional findings this session, out of Phase B's scope to fix, recorded to
> `BACKLOG.md`:** (1) **Excel-upload data corruption (high priority).**
> `R/modInput.R`'s `readDataFile()` calls `readxl::read_excel(file$datapath)` with no
> `col_types` argument; `readxl` infers each column's type from an early row sample, sees
> mostly-blank early sire/dam values, guesses `logical`, then silently converts every
> later alphanumeric sire/dam ID it cannot parse as logical to `NA`. Confirmed this
> session on an Excel round-trip of the shipped `data(examplePedigree)`: **2026/2026
> (100%) of non-blank sire values and 2023/2026 dam values become `NA`**, with 4049
> `readxl` warnings never surfaced to the user — the pedigree silently becomes almost
> entirely founders. This is the *same* code path any real user's Excel-format upload
> goes through, not specific to this script; the CSV path is unaffected (byte-identical
> round-trip, verified). This script therefore uploads CSV instead of Excel (the
> tutorial's own acknowledged alternative format) so the captured screenshots reproduce
> Phase A's confirmed numbers rather than depicting a silently-broken pedigree — Phase C
> must account for this when drafting Section 3's upload narrative (wait for a fix, or
> explicitly narrate CSV as the demonstrated format). (2) **Breeding Groups "Custom" sex
> ratio has no numeric-value input anywhere in `modBreedingGroupsUI()`** — the
> server's `parseSexRatio(input$sexRatio)` tries `as.numeric("custom")`, which is `NA`
> and silently falls back to `0.0`, identical to "None". The tutorial's "sex ratio of
> 2.5" demonstration (N7) cannot currently be reproduced through the UI at all;
> `breeding_group_sex_ratio_specification.png` shows the option selected (it exists) but
> not a working numeric demonstration.
>
> **Numeric reproductions confirmed live, matching Phase A exactly:** QC Summary
> reports "Records Processed: 3694, Errors: 0, Warnings: 1" (N1); the 5-focal-animal
> trim shows "Showing 1 to 15 of **54** entries" (N2, `pb_5_focal_animals_small.png`);
> the large-focal-group trim — using the shipped `focalAnimals` example object (327 ids)
> per Phase A's N3 verdict, uploaded via CSV matching the tutorial's own described
> method — shows "Showing 1 to 15 of **962** entries" (`pb_trimmed_for_focal_animals.png`;
> this required explicitly keeping Display Unknown IDs unchecked through the large-group
> sequence too, matching N2's filter-then-trim order — an inconsistency this session
> caught and fixed after an initial run gave 1,144, not 962); the Age-Sex Pyramid shows
> "Total on 2026-Jul-10: **332**" (N4, Male=123 + Female=209). N6 (GVA cutover row) and N7
> (breeding-group sex-ratio split) remain deliberately uncaptured as specific numbers —
> `gva_high_and_low_value.png` widens "Show top N" to 500 rather than pinning a row
> number, and N7 cannot currently be captured at all (see the sex-ratio finding above).
>
> **Scope-limiting decision (not a gap, a deliberate Phase C handoff):** the 6-seed-group
> screenshot (`breeding_group_6_infants_with_dam.png`) shows the current UI's dynamic
> per-group seed textareas with real structure but empty content — hand-picking real
> infant/dam ID pairs across 6 groups is content-authoring work for whoever drafts
> Section 3's actual narrative (Phase C), not something to invent sight-unseen in a
> screenshot-only phase.
>
> **What DONE looks like (original criteria — all three met):** (1) checked-in capture
> script — met; (2) current-UI screenshots for every covered tab — met, all 34 files
> (25 regenerated in place + 4 new + 5 left untouched as non-app-UI); (3) old-screenshot
> disposition resolved — met (8 deleted, 4 retired-and-replaced, the rest kept in place).
> **Verification:** every screenshot visually spot-checked this session (Read tool image
> review) against expected UI structure and, where numeric, against Phase A's confirmed
> values — see the reproductions above. **Next: Phase C** (port and draft Sections 1-3).
>
> **What DONE looks like:** a checked-in, regeneratable capture script (or a documented
manual-capture procedure, per Phase A's method decision) produces current-UI screenshots
for every tab Section 3 will cover, driven against the current modular app and a stated
example dataset; old screenshots' disposition (replace in place vs. new dated files)
resolved per Phase A's inventory.
**Verification:** each new screenshot visually spot-checked against the live app
(matching Document 1's Learning 311 precedent — a rendering defect invisible to
`quarto render`/exit-code-0 was only caught by inspecting the actual image).
**Session boundary:** screenshots only — no article prose yet.

### Phase C — Port and draft Sections 1-3 · risk MEDIUM (highest claim-density phase)

**What DONE looks like:** `vignettes/articles/<slug>.qmd` created with Sections 1-2
(adapted from `_introduction.Rmd`/`_summary_of_major_functions.Rmd`, T1, F1) and Section
3 (ported/modernized from `ColonyManagerTutorial.Rmd` using Phase B's screenshots, plus
new Genetic Diversity and Potential Parents subsections per Phase A's coverage
decision); every carried-forward numeric claim traces to Phase A's re-derivation, not
the original tutorial text.
**Verification:** `quarto render` on the article in isolation; every claim in Section 3
either matches Phase A's re-derived value or is flagged for the Phase D audit.

### Phase D — Assemble, verify, decide `ColonyManagerTutorial.Rmd`'s fate, publish · risk MEDIUM (irreversible-ish: public visibility, see §9 dragon 4)

**What DONE looks like:** Abstract, Introduction, Conclusion drafted; full claim-source
audit (workstream Phase 6) over the whole article; complete render verification matching
the S107-110 / Document-1 pattern (`quarto render` + `pkgdown::build_article()` +
`R CMD build .` + `tar tzf` tarball check confirming zero CRAN risk); spot-check 2-3
unmodified existing articles still render; `AskUserQuestion` resolving §12 decision 3
(retire/redirect `ColonyManagerTutorial.Rmd` now that its content is public, or keep both
— avoiding anti-pattern #14 companion-paper drift either way); cleanup of render
artifacts before staging.
**Verification:** the full Verification Checklist, §10.
**Session boundary:** this is the publish gate — the article should not be considered
public-ready until this phase's checklist is green.

---

## 7. Toolchain / mechanics reference

Same as Document 1's plan §8 (`docs/planning/v2-transformation-article-plan.md`) —
Quarto, no `.bib`, `quarto render` + `pkgdown::build_article()` + `R CMD build .` /
`tar tzf` for the CRAN-risk check. Not restated in full here; see that plan for the
per-concept table. One addition: **screenshot regeneration**, which Document 1 did not
need — `shinytest2::AppDriver` (already a `Suggests` dependency, already used by this
project's E2E test tier) is the recommended mechanism if Phase A selects automated
capture (§5, §9 dragon 1).

---

## 8. Dragons (Learning #3 — not all phases are equally risky)

1. **Screenshot regeneration (Phase B) is the highest-risk phase.** The existing
   screenshots are hand-cropped to specific UI regions (e.g., three separate crops of
   one opening screen: top/middle/bottom; a red-oval annotation highlighting one field).
   `shinytest2::AppDriver$get_screenshot()` captures full-viewport or full-element
   screenshots, not curated crops or annotations — achieving equivalent illustrative
   framing may need a post-processing step (crop/annotate) that doesn't currently exist
   in this project's toolchain. Resolve the method at Phase A kickoff, not mid-Phase-B.
2. **Numeric claims tied to the specific example pedigree are a claim-source-audit
   trap.** `ColonyManagerTutorial.Rmd`'s row counts ("3,694 rows... reduces to 2,322"),
   living-animal counts ("332 living animals"), and computation-timing claims ("1 minute
   38 seconds... MacBook Pro (Mid 2014)") are all specific to the exact example data and
   hardware used when the tutorial was written (2019-2020). Carrying these forward
   uncritically would repeat Document 1's own corrected mistake pattern (its Phase F
   audit found real mismatches from trusting prior text) — Phase A must re-derive every
   one against current example data, not copy them.
3. **Coverage-extent scope creep risk.** The current app has 2 tabs
   (Genetic Diversity #112, Potential Parents #48) the source tutorial never covered,
   because they postdate it. Writing genuinely new content for these (not a port) is a
   different kind of work than modernizing existing prose — the temptation is to either
   silently skip them (leaving the article incomplete relative to the current app) or to
   let their drafting balloon Phase C into two capabilities bundled as one (FM #26).
   Resolve the coverage decision explicitly at Phase A kickoff (§12 decision 1); if both
   new tabs are in scope, budget Phase C accordingly rather than discovering the overrun
   mid-session.
4. **Phase D publishes to a public URL** — same caution as Document 1's plan §9 dragon
   3: not fully reversible in practice even though the underlying file is a normal git
   file.
5. **The pkgdown Reference-page staleness (§1) is a live trap regardless of this
   article's own drafting quality.** If Section 2 or the Conclusion points readers to
   "the Reference page's grouped sections," that claim must be re-verified fresh at
   Phase C/D draft time (fetch the live site), not assumed from README's current (also
   stale) description or from this plan's snapshot. Whether the underlying pkgdown
   config gets fixed before or after this article ships is an independent decision
   (§12 decision 4) — the article's own claim must be correct regardless of that
   decision's timing.

---

## 9. Verification Checklist (adapted from the workstream, Quarto row)

Before Phase D closes:

- [ ] Every numeric or dated claim in the article traces to a re-derived-this-session
      value (Phase A) or an original-construction figure, not carried forward
      uncritically from `ColonyManagerTutorial.Rmd`
- [ ] No claim uses present-relative dating without an explicit "(as of 2026-07-10)"
      (or later drafting-session date)-style stamp
- [ ] Every figure/screenshot has stated provenance (capture script + date, or
      "original construction" for the Mermaid diagram)
- [ ] `quarto render` succeeds with no warnings; no unresolved `?@fig-x`/`?@tbl-x`
- [ ] `pkgdown::build_article()` succeeds
- [ ] `R CMD build .` + `tar tzf` confirms the new article and any new data/screenshot
      subfolder do not ship (zero CRAN risk, matching S107-110 and Document 1)
- [ ] The six existing `vignettes/articles/*.qmd` plus Document 1 still render
      (spot-check, workstream Phase 6 discipline)
- [ ] No search/extraction artifacts left anywhere touched this session
- [ ] The article does not cite the pkgdown Reference page's grouped structure unless
      independently re-verified live at draft time (§8 dragon 5)
- [ ] `ColonyManagerTutorial.Rmd`'s fate (§12 decision 3) is resolved, not left
      ambiguous — either explicitly retired/redirected or explicitly kept with a stated
      reason

---

## 10. Planning Session Checklist (`SESSION_RUNNER.md`)

- [x] Plan document written with file paths and line numbers
- [x] Evidence gathered directly this session for every claim in §1/§3 — `a3manual.Rmd`,
      `manual_components/*.Rmd`, `ColonyManagerTutorial.Rmd` (full read), `README.Rmd`,
      `R/appUI.R`, `NAMESPACE`, `inst/_pkgdown.yml`, the live pkgdown site, and issue #37
      all read or queried directly this session, not assumed from memory
- [x] A genuine pre-drafting scope discovery (§1) was surfaced to the owner via
      `AskUserQuestion` rather than silently assumed or silently ignored — this is the
      load-bearing decision of this planning session
- [x] Each phase (§6) has explicit completion criteria, verification commands, and a
      stated session boundary
- [x] Each phase marked as a separate session with a STOP point; no phase pre-bundles
      into another
- [ ] Deepest available reasoning mode set at session start — not explicitly confirmed;
      this session ran at whatever effort level the harness resolved by default,
      matching Document 1's own plan's identical caveat (its §11). Flag for the owner:
      Phase B (screenshot regeneration, dragon 1) and Phase A (scope/method decisions)
      are where it would matter most.
- [ ] Close-out: evaluate predecessor, self-assess, write the `HANDOFFS.md` receipt,
      record the `CHANGELOG.md` ledger entry, commit, STOP — pending, this session's
      Phase 3 (imminent, not yet done as of this plan's drafting).

---

## 11. Open decisions for the owner (not blocking plan approval, but not silently assumed)

1. ~~**Tab-coverage extent (§8 dragon 3).**~~ **RESOLVED — Session 346
   (`AskUserQuestion`, 2026-07-10): include both new tabs** (Genetic Diversity #112,
   Potential Parents #48) alongside the 6 the source tutorial already covers. Budget
   Phase C accordingly (§8 dragon 3).
2. ~~**Screenshot regeneration method (§8 dragon 1).**~~ **RESOLVED — Session 346
   (`AskUserQuestion`, 2026-07-10): automated** (`shinytest2::AppDriver`-driven,
   checked-in, reproducible), with manual post-processing (crop/annotate) only where a
   specific illustrative point (e.g., the red-oval highlight) genuinely needs it.
3. **Fate of `ColonyManagerTutorial.Rmd` after porting (§8 dragon 4).** Retire it (e.g.,
   replace its content with a redirect note to the new public article) once Document 2
   ships, or keep both in parallel? Recommend: retire/redirect, to avoid anti-pattern
   #14 companion-paper drift (a source vignette silently diverging from its port over
   time) — but this is the owner's call, resolve at Phase D.
4. **Timing of the pkgdown Reference-index fix (§1's separate finding).** Independent of
   Document 2's own timeline — fix before Document 2 references the Reference page, or
   let Document 2 ship first and fix separately? Either is fine as long as Document 2's
   own citation is verified live at draft time regardless (§8 dragon 5). Recorded as its
   own `BACKLOG.md` item at this session's close-out; no ordering dependency imposed
   here.
5. ~~**Article title/slug**~~ **RESOLVED — Session 346 (`AskUserQuestion`, 2026-07-10):
   confirmed as proposed** — `vignettes/articles/colony-manager-guide.qmd` —
   "nprcgenekeepr: Purpose, Approach, and a Colony Manager's Guide to Practice."

**Remaining open: decisions 3 and 4 only**, both explicitly deferred (3 to Phase D, 4
independent of this plan's own timeline) — neither blocks Phase B from starting.
