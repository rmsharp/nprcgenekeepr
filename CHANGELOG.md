# Changelog

Development / process history for the **nprcgenekeepr** project,
following the [methodology](https://github.com/rmsharp/methodology)
model: `BACKLOG.md` holds open work, **this file** holds completed
history, and `ROADMAP.md` holds the feature inventory and future plans.

> **Note:** User-facing R-package release notes (the CRAN / pkgdown
> “Changelog”) live in `NEWS.md` / `NEWS.Rmd`. This file tracks the
> development *process* and methodology history, not package releases.

Format loosely follows [Keep a Changelog](https://keepachangelog.com/).
When completing work, remove the item from `BACKLOG.md` and add an entry
here.

## \[Unreleased\]

### 2026-06-17 — Data-doc short-`@title` rewrite: all 24 datasets given proper short titles, detail moved to `@description` (Session 117)

- **Deliverable (owner pick A2):** rewrote the roxygen TITLE of all 24
  datasets in `R/data.R` from long “X is a …” run-on sentences into
  short noun-phrase titles, moving the descriptive detail into
  `@description`; regenerated the 24 data `man/` pages. Owner chose
  **all 24 docs** (scope) and **short noun phrase, no object-name
  prefix** (style) via a gated pre-RED `AskUserQuestion`. Scoped to
  **`R/data.R` + 24 data `man/` pages**; `NAMESPACE`, `DESCRIPTION`,
  `data/` unchanged. **TDD phase N/A** (roxygen prose; no executable R
  line changed — only `#'` comments; RED vacuous; declared every
  response). **0 stakeholder corrections.**
- **The 24 new titles** span the worst offenders (`finalRpt`’s
  4-sentence title with no `@description` at all; the 6 QC error-set “…N
  rows and M columns (…) representing a full pedigree with…” run-ons) to
  the moderate “X is a …” one-liners. Examples: `pedGood` → “Valid
  example studbook (no QC errors)”; `finalRpt` → “Genetic-value report
  list prior to ranking”; `qcPed` → “Example quality-controlled baboon
  pedigree”; `smallPed` → “Hypothetical 17-animal pedigree”.
- **`qcPed` dimension claim corrected (verify-and-correct, Learning
  109/111):** the old title said “277 rows and 6 columns”; the object is
  **280×8** (and roxygen’s auto-`\format` already read 280×8 — the page
  contradicted itself). The new description states the accurate 280×8.
  Every other count-bearing doc was verified accurate against the loaded
  object before authoring.
- **`ped1Alleles` block made well-formed:** the two `## Copyright`
  comment lines that interrupted its roxygen block (between title and
  `@format`) were relocated above the block, so the block is contiguous.
- **Adversarial quality review (3-lens critic panel — accuracy /
  completeness / style+consistency):** returned **0 block, 0 should-fix,
  3 nits**. Acted on: `smallPed` retitled “Hypothetical 17-animal
  pedigree” (was a confusable near-duplicate of `lacy1989Ped`’s “Small
  hypothetical pedigree (Lacy 1989)”). Kept (owner-approved in the style
  preview): “studbook” for the 6 QC fixtures (panel preferred “pedigree”
  for file consistency — noted for future).
- **Verified (build-equivalent for a generated-doc change):**
  `roxygenise()` regen confined to exactly the 24 intended data pages
  (`git diff --stat`); **`NAMESPACE` byte-identical** to HEAD
  (`git diff --quiet`); `DESCRIPTION`/`data/` untouched;
  [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html) on all 24
  changed pages — **0 problems**;
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  OK (**162 exports**); full-suite regression read **failed=0 error=0**
  (incl. the usually-noisy app/e2e files); no stray `Rplots.pdf`.
  **Phase-3E N/A** — roxygen/Rd prose changes no package/app runtime
  behavior. Full `R CMD check` not run (`devtools` absent; the above is
  the proportionate equivalent).
- **\[news-vs-changelog\]:** dev-process history → CHANGELOG here. These
  help pages **ship**, so fold the new titles into the CRAN Phase 3 NEWS
  rewrite at 2.0.0 (flagged, not edited now).
  \[\[backlog-vs-changelog-placement\]\]
- **Out of scope (flagged, FM \#8 — not fixed):** (1)
  `examplePedigree`’s `\describe` documents `\item{recordStats}` but the
  actual column is `recordStatus` (pre-existing; surfaced by the critic
  panel and verified against the data); (2) the “studbook” vs “pedigree”
  term split for the 6 QC fixtures (owner-approved “studbook” kept;
  revisit if uniform “pedigree” preferred); (3) pre-existing wording
  bugs preserved verbatim — `rhesusGenotypes`’s garbled “There are
  object.” and `exampleNprcgenekeeprConfig`’s “created the SNPRC”; (4)
  `vignettes/articles/studbook-quality-control.qmd:91` still omits the
  `sex` column (S116’s A3 nit).
- **PROJECT_LEARNINGS.md:** Learning 111 added.

### 2026-06-17 — Adjacent doc/data-doc repair: pedGood cross-ref case, data-doc column accuracy, and 20 wrapped `@importFrom` tags (Session 116)

- **Deliverable (owner pick A):** repaired the three adjacent
  doc/data-doc bugs S115 flagged but deliberately left (FM \#8), then
  regenerated the affected `man/`. Scoped to **`R/data.R` + 10 `R/`
  source files + 6 data `man/` pages**; `NAMESPACE`, `DESCRIPTION`, and
  `data/` unchanged. **TDD phase N/A** (roxygen/data-doc prose +
  `@importFrom` source reformatting; no executable R line changed — only
  `#'` comments — so no package logic or test surface; RED vacuous;
  declared every response). **Two gated pre-RED `AskUserQuestion`s**
  (the item-2 data-vs-doc fork; the item-3 3-vs-10-file scope, posed
  after the scope/nature discovery). **0 stakeholder corrections.**
- **Item 1 — `pedgood` -\> `pedGood` cross-reference case (6×):** the
  “one of six pedigrees” boilerplate in all six error-set data docs
  (`pedDuplicateIds`, `pedFemaleSireMaleDam`, `pedGood`,
  `pedInvalidDates`, `pedMissingBirth`, `pedSameMaleIsSireAndDam`) wrote
  `\code{pedgood}`; the dataset is `pedGood`. Fixed in `R/data.R`,
  regenerated the 6 pages.
- **Item 2 — data-doc column lists corrected to the ACTUAL columns
  (owner chose full accuracy):** the five raw-fixture datasets store
  column `si.re` (and `pedOne` stores `si re`), not `sire`; the docs
  said `sire`. `si.re`/`si re` is an **intentional raw studbook-input
  fixture** — `fixColumnNames` strips spaces then periods (`si re` -\>
  `si.re` -\> `sire`) and `qcStudbook(pedGood)` returns canonical
  `sire`, confirming the messy header is what the QC pipeline exists to
  normalize. So the fix is doc-only (renaming the data would gut the
  fixture): `sire` -\> `si.re` in
  `pedGood`/`pedDuplicateIds`/`pedFemaleSireMaleDam`/`pedMissingBirth`/`pedSameMaleIsSireAndDam`.
  Also fixed `pedInvalidDates`’ separate divergence (doc said
  `(ego_id, sire, dam_id, sex, birth_date)`; data is
  `(id, sire, dam, sex, birth)` — corrected the column list and the
  `\code{birth_date}` -\> `\code{birth}` reference). Row counts verified
  already-correct. `pedOne`’s doc makes no column claim, so it needed no
  edit.
- **Item 3 — split 20 wrapped `@importFrom` tags across 10 files (owner
  chose all 10):** the flag named 3 `mod*.R` files; a codebase scan
  found **20 multi-line `@importFrom` tags across 10 files** (every
  `mod*.R` plus `appServer.R` and `appUI.R`) triggering roxygen 8.0.0’s
  `@importFrom must be only 1 line long`. **Corrected the inherited
  characterization: this is cosmetic lint, NOT a NAMESPACE hazard** — a
  reverted regen probe proved roxygen 8.0.0 still captures every
  continuation line (`NAMESPACE` byte-identical, 140 `importFrom`, 0
  removed). Split each wrapped tag into multiple single-line
  `@importFrom pkg ...` tags wrapped at \<=80 chars (matching the
  authors’ style; deterministic dry-run-first script, every before/after
  audited before writing). Regen emits **0** `@importFrom` errors.
- **Verified (build-equivalent for a generated-doc/source change):**
  `roxygenise()` regen confined to exactly the 6 intended data pages
  (`git diff --stat`); **`NAMESPACE` byte-identical** to HEAD
  (`git diff --quiet`) — proving the item-3 reformat is import-neutral;
  `DESCRIPTION` and `data/` untouched; per-page
  [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html)
  HEAD-vs-working on all 6 changed pages — **0 problems, 0 new**;
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  OK (**162 exports**); full-suite regression read **failed=0 error=0**
  (incl. the usually-noisy app/e2e files); 0 wrapped `@importFrom` tags
  remain; no stray `Rplots.pdf`. **Phase-3E N/A** — no runtime behavior
  change (doc prose + `NAMESPACE`-neutral `@importFrom` reformat; proven
  byte-identical). Full `R CMD check` not run (`devtools` absent;
  `checkRd` + `load_all` + the `NAMESPACE`/man diff + the regression
  read is the proportionate equivalent).
- **\[news-vs-changelog\]:** dev-process history -\> CHANGELOG here.
  These help pages **ship**, so fold these corrections into the CRAN
  Phase 3 NEWS rewrite at 2.0.0 (flagged, not edited now).
  \[\[backlog-vs-changelog-placement\]\]
- **Out of scope (flagged, FM \#8 — not fixed):**
  `vignettes/articles/studbook-quality-control.qmd:91` lists
  `(ego_id, si.re, dam_id, birth_date)` (correct `si.re`, but omits the
  `sex` column) — a vignette accuracy nit, separate artifact; S114’s
  still-deferred data-doc short-title rewrite (A2) — several titles
  remain long run-ons.
- **PROJECT_LEARNINGS.md:** Learning 110 added.

### 2026-06-17 — Roxygen content-bug repair: corrected 4 wrong/garbled doc descriptions S114 flagged (Session 115)

- **Deliverable (owner pick A):** repaired the four adjacent roxygen
  CONTENT bugs S114 flagged but deliberately left (FM \#8), then
  regenerated the affected `man/` pages. Scoped to **3 `R/` files (5
  edits) + 5 `man/` pages**; `data/`, `NAMESPACE`, `DESCRIPTION`
  unchanged. **TDD phase N/A** (roxygen prose; no package logic or test
  surface, so RED is vacuous; declared every response). **One gated
  `AskUserQuestion`** (a pre-RED wording/scope decision for
  `pedMissingBirth`; owner chose full accuracy). **0 stakeholder
  corrections** (one mid-session owner constraint, already satisfied —
  see below).
- **What changed (5 source edits):**
  - `R/findPedigreeNumber.R` title — was byte-identical to
    `findGeneration`’s (“Determines the generation number for each id”);
    now “Determines the pedigree number for each id” (the function
    numbers disjoint connected sub-pedigrees, the `pedNum` vector).
  - `R/convertSexCodes.R` title — “Converts sex indicator for an
    individual to a standardized codes” (number-agreement error) →
    “Converts a sex indicator for an individual to a standardized code”.
  - `R/data.R` `focalAnimals` — “containing the of animal Ids” (stray
    word) → “containing the animal Ids”.
  - `R/data.R` `pedMissingBirth` — “8 rows and 5 columns (ego_id, sire,
    dam_id, sex, birth_date) representing a full pedigree with no
    errors” → “8 rows and 4 columns (ego_id, sire, dam_id, sex)
    representing a full pedigree that is missing the birth_date column”.
    It is an error-demo set, not error-free; and the data object
    genuinely has only 4 columns (`birth_date` absent), so the old “5
    columns” was itself wrong — the auto-generated `\format` block
    already read “4 columns”, confirming the correction.
  - `R/data.R` `pedSameMaleIsSireAndDam` — “…representing a full
    pedigree with no errors” → “…representing a full pedigree in which
    the same male animal is listed as both a sire and a dam” (verified:
    male `s1` sires `o1`/`o2` and is the dam of `o3`). Column count (5)
    is correct, unchanged.
- **Ground-truth verification before editing (Learning 105/106).**
  Loaded the data objects: `pedMissingBirth` has columns
  `ego_id, si.re, dam_id, sex` and NO `birth_date` (4 columns, 8 rows);
  `pedSameMaleIsSireAndDam` row `o3` has `dam_id = s1` (a male);
  `focalAnimals` is 1 column (`id`), 327 rows. `findPedigreeNumber`
  source confirmed to assign a connected-component number, not a
  generation. Each fix states what the data actually is — not just what
  the flag named.
- **Owner constraint addressed:** mid-session the owner required
  `pedMissingBirth` to **retain the characteristic of not having a Birth
  column**. Only documentation changed — the data object is untouched
  and still has no `birth_date` column (verified post-edit: 4 columns,
  `birth_date` absent). The new doc accurately states this intended demo
  characteristic.
- **Verified (build-equivalent for a generated-doc change):** per-page
  [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html)
  HEAD-vs-working comparison on all 5 changed pages — **0 problems, 0
  new vs HEAD**;
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  OK (**162 exports** — NAMESPACE consistent); `data/` unchanged; no
  stray `Rplots.pdf`; regen confined to the 5 intended pages
  (`git diff --stat`), no roxygen version blast radius (baseline 8.0.0).
  **Phase-3E N/A** — roxygen/Rd prose changes no package/app runtime
  behavior. Full `R CMD check` not run (`devtools` absent; `checkRd` +
  `load_all` + the per-page HEAD-vs-working diff is the proportionate
  equivalent for an artifact-only change).
- **\[news-vs-changelog\]:** dev-process history → CHANGELOG here. These
  help pages **ship**, so fold these corrections into the CRAN Phase 3
  NEWS rewrite at 2.0.0 (flagged, not edited now).
  \[\[backlog-vs-changelog-placement\]\]
- **Out of scope (flagged, FM \#8 — newly discovered this session, not
  fixed):** (1) the cross-reference boilerplate in all six error-set
  data docs writes `\code{pedgood}` (wrong case; the dataset is
  `pedGood`); (2) the data objects’ actual sire column is named `si.re`
  though every doc says `sire`; (3) roxygen2 8.0.0 emits
  `@importFrom must be only 1 line long` errors for `mod*.R`
  (`modPotentialParents`, `modPyramid`, `modSummaryStats`) — multi-line
  `@importFrom` tags need splitting; (4) several data-doc titles remain
  long run-ons (S114’s deferred A2 short-title rewrite).
- **PROJECT_LEARNINGS.md:** Learning 109 added.

### 2026-06-17 — Roxygen doc-nit mop-up: cleared all 62 `\title`-period checkRd NOTEs + 3 genetic-value `@return` nits (Session 114)

- **Deliverable (owner pick A2 — full sweep):** removed the trailing
  period from every roxygen title flagged by
  [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html) as
  `\title should not end in a period` (**62 of 190 `.Rd`**: 51 function
  docs + 11 data docs), and fixed three genetic-value `@return` nits
  S112 had flagged. Then regenerated `man/`. **TDD phase N/A** (roxygen
  prose; no package logic or test surface, so RED is vacuous; declared
  every response). **One gated `AskUserQuestion`** (a pre-RED *scope*
  decision — full sweep vs. a narrower bite; owner chose the full
  sweep). **0 stakeholder corrections.**
- **What changed:** **`R/` (55 files):** 51 function files lost one
  trailing title period each; `R/data.R` lost it from 11 data-doc
  titles; `R/calcFE.R` `@return` dropped the spurious `\code{r}` clause
  (`FE = 1/sum(p^2)` uses only `p`); `R/calcFEFG.R` + `R/calcFG.R`
  `@return` closed the unbalanced paren in the FG formula
  (`sum( (p ^ 2) / r}` → `sum( (p ^ 2) / r)`). **`man/` (65 pages
  regenerated):** the 62 title pages + the 3 GV `\value` pages.
  `NAMESPACE` and `DESCRIPTION` unchanged.
- **Method (deterministic + dry-run + oracle).** The 51 single-block
  function titles were de-periodized by a dry-run-first script whose
  every before/after was audited before writing (each picked the correct
  title paragraph, incl. multi-line); `R/data.R` (11 titles) and the 3
  `@return` blocks were hand-edited. Each function file changed exactly
  one line (51 insertions / 51 deletions, no encoding rewrite).
- **Verified (build-equivalent for a generated-doc change):** a per-page
  `checkRd` comparison of all **65** changed pages vs their HEAD
  versions proved **62 pages had ONLY the title-period NOTE removed and
  0 pages gained any new problem** (the 3 GV pages changed `\value`
  prose with no `checkRd` impact). Title-period NOTEs package-wide: **62
  → 0**.
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  OK (**162 exports** — NAMESPACE consistent). No stray `Rplots.pdf`.
  **Phase-3E N/A** — roxygen/Rd prose changes no package/app runtime
  behavior. Full `R CMD check` not run (`devtools` absent; `checkRd` +
  `load_all` + the per-page HEAD-vs-working diff is the proportionate
  equivalent for an artifact-only change).
- **\[news-vs-changelog\]:** dev-process history → CHANGELOG here. These
  help pages **ship**, so fold the title/return corrections into the
  CRAN Phase 3 NEWS rewrite at 2.0.0 (flagged, not edited now).
  \[\[backlog-vs-changelog-placement\]\]
- **Out of scope (flagged, FM \#8 — period-removal left these intact):**
  copy-paste/garbled CONTENT in titles & data docs —
  `R/findPedigreeNumber.R` title duplicates `findGeneration`’s
  (“Determines the generation number for each id”);
  `pedMissingBirth`/`pedSameMaleIsSireAndDam` data docs say
  “representing a full pedigree with no errors” though they are
  error-demo sets; `focalAnimals` “containing the of animal”;
  `convertSexCodes` “to a standardized codes”. Several data-doc titles
  are now checkRd-clean but still long run-ons (a proper short-title
  rewrite is a separate task).
- **PROJECT_LEARNINGS.md:** Learning 108 added.

### 2026-06-17 — Roxygen tooling migration: adopted roxygen2 8.0.0, regenerated `man/` (Session 113)

- **Deliverable (owner pick A):** the deliberate, gated roxygen
  `7.3.2 → 8.0.0` migration that S112 isolated and deferred. Regenerated
  `man/` with the installed roxygen2 8.0.0 and migrated the
  `DESCRIPTION` version field — a small, reviewable diff (**26 `.Rd`
  pages + `DESCRIPTION`; `NAMESPACE` unchanged**), taken as its own
  deliverable rather than bundled into a content fix. **TDD phase N/A**
  (regenerating generated artifacts + a `DESCRIPTION` field migration;
  no package logic or test surface, so RED is vacuous; declared every
  response). **One gated `AskUserQuestion`** (adopt 8.0.0 vs pin 7.3.2 —
  a pre-implementation *approach* decision, not a TDD gate); owner chose
  **adopt**. **0 stakeholder corrections.**
- **What changed:** `DESCRIPTION` — `RoxygenNote: 7.3.2` →
  `Config/roxygen2/version: 8.0.0` (the 8.0.0 field rename) and the
  `Suggests` floor `roxygen2 (>= 7.3.2)` → `(>= 8.0.0)`. `man/` (26
  pages): **24 dataset docs** adopt 8.0.0’s canonical usage form
  (`\usage{ qcPed }` → `\usage{ data(qcPed) }`); `man/appUI.Rd` re-wraps
  its `\value` text (cosmetic, identical content).
- **The regen also repaired stale committed content** (drift between
  source and the committed 7.3.2 `.Rd`): `man/nprcgenekeepr-package.Rd`
  now reads `'Macaca' 'mulatta'` (the committed page had the typo
  `'mulatto'`; `DESCRIPTION` already read `mulatta`) and lists the
  maintainer **R. Mark Sharp** under Authors (he is `aut` in
  `DESCRIPTION` but was absent from the rendered list). No content was
  lost; S112’s four hand-edited `\value` pages produced **zero diff** —
  their content already matched source, the clean reconciliation S112
  predicted.
- **Verified (build-equivalent for a generated-doc change):** the
  **complete** 27-file diff was read line-by-line — every change is one
  of the four intended kinds, nothing unexpected; `NAMESPACE` unchanged
  (162 exports,
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  OK); [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html) on
  **all 26** changed pages introduces **zero new problems** — the 11
  reported `\title`-ends-in-period NOTEs are pre-existing (confirmed
  identical on the committed HEAD versions; **62 of 190** `.Rd` carry it
  package-wide). `renv.lock` unchanged (roxygen2 is a dev-only dep, not
  snapshotted). **Phase-3E N/A** — Rd/`DESCRIPTION` regeneration changes
  no package/app runtime behavior; the appropriate verification is Rd
  validity + load + full-diff audit, done. Full `R CMD check` not run
  (`devtools` absent; `checkRd` + `load_all` is the proportionate
  equivalent for an artifact-only change).
- **\[news-vs-changelog\]:** dev-process history → CHANGELOG here. These
  help pages **ship**, so fold the content repairs (typo + author list)
  into the CRAN Phase 3 NEWS rewrite at 2.0.0 (flagged, not edited now —
  the CRAN plan owns the NEWS pipeline).
  \[\[backlog-vs-changelog-placement\]\]
- **Out of scope (flagged, FM \#8):** the **62** pre-existing
  `\title`-period `checkRd` NOTEs and S112’s other A2 mop-up nits
  (`calcFE.R` `@return` mentions `r`; the unbalanced-paren `fg` formula)
  — a separate A2 session.
- **PROJECT_LEARNINGS.md:** Learning 107 added.

### 2026-06-17 — Roxygen repair: corrected drifted `@return`/`p` descriptions for the genetic-value functions (Session 112)

- **Deliverable (owner pick A2):** corrected long-drifted roxygen
  documentation, and regenerated the affected `man/` pages, for the
  genetic-value functions — fixing three confirmed `@return`/parameter
  drifts plus the identical defect in two sibling files, and **refuting
  the fourth inherited flag**. Scoped to **5 `R/` + 4 `man/` files**.
  **TDD phase N/A** (roxygen prose corrected to match already-correct
  behavior — the code was right, only the docs were wrong, so RED is
  vacuous; declared every response).
  - `R/orderReport.R` `@return` — the High-Value tier was described as
    raw “mean kinship less than 0.25, ranked by ascending mk”; it
    actually gates on the **z-score** of mean kinship
    (`zScores <= 0.25`) and orders by ascending `zScores`. Both
    `@return` bullets carried the “ascending mk” error (the second tier
    is also sorted by `zScores`); both corrected.
  - `R/calcFEFG.R`, `R/calcFG.R`, `R/calcFE.R` `@return` — `p` was
    described as “average number of descendants”; it is the vector of
    each founder’s **mean genetic contribution** to the current
    descendants (`colMeans` of the contributions matrix; verified
    `sum(p) = 1` on `lacy1989Ped`). Fixed in all three — the owner
    approved extending the agreed fix to the two `calcFE`/`calcFG`
    siblings, which share the `calcFounderContributions()` helper and
    carried the identical wording.
  - `R/reportGV.R` `@return` — said “A dataframe”;
    [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
    returns a **list** of class `nprcgenekeeprGV` with 10 named elements
    (`report`, `kinship`, `gu`, `fe`, `fg`, `maleFounders`,
    `femaleFounders`, `nMaleFounders`, `nFemaleFounders`, `total`). Now
    documents the list and its elements (verified against the
    `list(...)` constructor and the function’s own examples).
- **Re-verified the inherited flags before acting (Learning 105/106).**
  The four drifts were code-read claims (three from S108, one from S110)
  never confirmed against runtime. An 8-agent workflow (one verifier +
  one adversarial cross-checker per claim) confirmed three and **refuted
  the fourth**: `getPyramidPlot.R`’s `@return` (“the return value of
  `par('mar')`”) is **correct** — the function returns
  [`plotrix::pyramid.plot()`](https://plotrix.github.io/plotrix/reference/pyramid.plot.html)’s
  value, and `pyramid.plot` ends with `return(oldmar)` where
  `oldmar <- par("mar")`, so the returned value *is* a `par("mar")`
  vector (verified: returns `c(5.1, 4.1, 4.1, 2.1)`). Left unchanged.
  Trusting the flag would have replaced a correct `@return` with a wrong
  one.
- **`man/` regenerated without a tooling migration.** The dev `roxygen2`
  (8.0.0) is newer than the committed baseline (`RoxygenNote: 7.3.2`),
  so a full `roxygenise()` reformatted all 30 `.Rd` files and migrated
  the DESCRIPTION field. That version migration was reverted
  (`git checkout -- man/ DESCRIPTION`) and the four affected `\value`
  sections were edited surgically to match the source — keeping the
  change scoped. The 7.3.2→8.0.0 roxygen migration is flagged as a
  separate, deliberate task (coordinate with the CRAN plan).
- **Verified (build-equivalent for a doc change):**
  [`tools::checkRd()`](https://rdrr.io/r/tools/checkRd.html) clean on
  all four changed pages (the one note — `reportGV.Rd` `\title` ends in
  a period — is pre-existing, on a line not touched);
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
  succeeds; the rendered `\value` text reads correctly. **Phase-3E N/A**
  — documentation prose changes no package/app runtime behavior; the
  appropriate verification is Rd validity + render, done.
- **\[news-vs-changelog\]:** dev-process history → CHANGELOG here.
  Unlike the website articles, these help pages **do ship**, so this
  correction should be folded into the CRAN Phase 3 NEWS rewrite at
  2.0.0 (flagged, not edited now — the CRAN plan owns the NEWS
  pipeline). \[\[backlog-vs-changelog-placement\]\]
- **Discovered, not fixed (flagged, FM \#8):** (a) `R/calcFE.R`
  `@return` still mentions `r`, which does not appear in its
  `FE = 1/sum(p^2)` formula; (b) the formula `sum( (p ^ 2) / r}` has
  unbalanced parentheses in `calcFEFG`/`calcFG`; (c) `reportGV.Rd`
  `\title` ends in a period (`checkRd` -5).
- **PROJECT_LEARNINGS.md:** Learning 106 added.

### 2026-06-17 — Doc fix: corrected inverted focal-population description in the breeding-group article (Session 111)

- **Deliverable:** one prose fix in
  `vignettes/articles/breeding-group-formation.qmd` — the focal
  population was described as “the founders still in the colony,” but
  the filter `!(is.na(sire) & is.na(dam)) & is.na(exit)` selects
  **non-founders** (animals with at least one known parent) still in the
  colony. Corrected to “the non-founders still in the colony (those with
  at least one known parent).” Resolves the S108-discovered inversion
  (open since then; carried forward as option A’ through S109/S110).
  **One-line fix only** (FM \#18/#25). **TDD phase N/A** (documentation
  prose; no `R/` logic or test surface; declared every response).
- **Verified two ways:** (1) internal corroboration — the same sentence
  trims the pedigree to the focal set “plus the ancestors needed to
  compute their kinships,” and founders have no ancestors, so the focal
  set must be non-founders; (2) ground truth on the example data —
  `qcStudbook(examplePedigree)` then the article’s own filter yields 327
  focal animals, **none** of which are founders and **all** of which
  have at least one known parent (the studbook has 1,668 founders, zero
  in the focal set). The article re-rendered cleanly (`quarto render` —
  all 19 chunks executed; prose-only change, output unchanged).
- **\[news-vs-changelog\]:** website-only documentation = dev-process
  history → CHANGELOG only, no NEWS (the article never ships;
  \[\[backlog-vs-changelog-placement\]\]). **Phase-3E N/A** — a
  build-ignored website article changes no package/app runtime behavior;
  the appropriate verification is the render, done.
- **PROJECT_LEARNINGS.md:** Learning 105 added.

### 2026-06-17 — Quarto Hybrid §7.1: fourth Quarto article — Age-Sex Pyramid Plots (Session 110)

- **Deliverable:** a fourth Quarto pkgdown article,
  `vignettes/articles/age-sex-pyramid.qmd` — a scripted
  [`getPyramidPlot()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPyramidPlot.md)
  demographic walkthrough on the shipped `qcPed` data: building the
  pyramid, reading colony age/sex structure, the `binWidth` /
  `colorScheme` / `ageUnit` options, and the living-and-aged animal
  selection. Drop-in `.qmd` on the slice-2 mixed-mode infra (S107) — no
  new config. **One article only** (FM \#18/#25). **TDD phase N/A**
  (documentation using an existing exported function + shipped data; no
  `R/` logic or test surface; declared every response).
- **Authored ground-truth-first:** ran
  [`getPyramidPlot()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPyramidPlot.md)
  (and `fillBins`) on `qcPed` and let the actual numbers drive the
  prose. The key catch the run surfaced: the pyramid plots only the
  **living animals with a known age** — 46 of `qcPed`’s 89 living
  animals — because 43 living animals (all male) lack a birth date and
  so cannot be aged or placed. That makes the example’s apparent ~3:1
  *female* skew **reversed** from the true living population (54 males
  to 35 females) — used as the article’s honesty / QC-tie-in lesson
  (missing data can *invert* a pyramid, not just shrink it).
- **Verified end-to-end through the same paths as S107–S109:**
  `quarto render` (Quarto 1.7.33) executes the chunks on shipped data →
  clean HTML with both figures (deterministic *shape*:
  [`getPyramidPlot()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPyramidPlot.md)
  runs no simulation, needs no seed, and `qcPed` ships a fixed `age`
  column; the only nondeterministic element is the plot **title date**
  via
  [`lubridate::now()`](https://lubridate.tidyverse.org/reference/now.html)
  — a cosmetic “census on render date” label);
  `pkgdown::build_article("articles/age-sex-pyramid")` (pkgdown 2.2.0)
  wraps it in the site template; an `R CMD build` tarball confirms
  `vignettes/articles/` does **not** ship — zero CRAN risk, the 21
  shipping vignette files unaffected.
- **Adversarial review (two independent lenses — code-correctness +
  pedagogy/render-determinism):** code-correctness = ship (all 8
  challenged claims verified by re-running against `qcPed`: 280/89/46,
  35F/11M, the 43 all-male-no-birth chain, the title / left-right /
  defaults). Pedagogy = ship-with-fixes; two grounded honesty fixes
  applied + re-rendered: strengthened the sex-skew caveat to state the
  apparent skew is *reversed* (not merely inflated), and reframed the
  Reference so V&R 2015 is the *package’s* origin rather than implying
  the pyramid method derives from it (the pyramid is general demography
  via
  [`plotrix::pyramid.plot()`](https://plotrix.github.io/plotrix/reference/pyramid.plot.html)).
- **Discovered, not mine — flagged for a future session:**
  `getPyramidPlot.R` `@return` roxygen says “the return value of
  `par('mar')`” but the function actually returns
  [`plotrix::pyramid.plot()`](https://plotrix.github.io/plotrix/reference/pyramid.plot.html)’s
  value — a roxygen drift (joins the S108-discovered set); left
  untouched (FM \#8; the article documents no return value).
- **\[news-vs-changelog\]:** website-only documentation = dev-process
  history → CHANGELOG only, no NEWS (the article never ships;
  \[\[backlog-vs-changelog-placement\]\]). **Phase-3E N/A** — a
  build-ignored website article changes no package/app runtime behavior;
  the appropriate verification is render + pkgdown build + tarball, all
  done.
- **PROJECT_LEARNINGS.md:** Learning 104 added. **ROADMAP.md / analysis
  §7.1:** articles-so-far note extended to record the fourth article.

### 2026-06-17 — Quarto Hybrid §7.1: third Quarto article — Studbook Quality Control (Session 109)

- **Deliverable:** a third Quarto pkgdown article,
  `vignettes/articles/studbook-quality-control.qmd` — a scripted,
  non-Shiny walkthrough of studbook quality control
  ([`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md))
  on the shipped `examplePedigree` plus the purpose-built error-demo
  data sets: the required-column / sex-consistency / date / duplicate /
  parent-age checks, the production vs diagnostic (`reportErrors`)
  modes, and column/code standardization. Drop-in `.qmd` on the slice-2
  mixed-mode infrastructure (S107) — no new config. **One article only**
  (FM \#18/#25). **TDD phase N/A** (documentation using existing
  exported functions + shipped data; no `R/` logic or test surface;
  declared every response).
- **Authored ground-truth-first:** ran
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  on real data in BOTH modes and let the actual output drive the prose —
  `examplePedigree` (3,694 rows) → standardized 3,694-row data frame;
  `reportErrors = TRUE` returns a diagnostic list (or `NULL` when the
  studbook is clean) and each shipped error-demo set triggers exactly
  one finding (`pedFemaleSireMaleDam` → `femaleSires`/`maleDams`;
  `pedInvalidDates` → `invalidDateRows = 3,4`; `pedDuplicateIds` →
  `duplicateIds`; `pedMissingBirth` → `missingColumns`;
  `pedSameMaleIsSireAndDam` → `sireAndDam`); `reportErrors = FALSE`
  (production) auto-corrects female-sire/male-dam and removes exact
  duplicates but **stops** on missing column, invalid date, sire==dam,
  young parent, and period-in-ID. Running it corrected a wrong
  assumption — invalid dates *stop* the function; they are not silently
  coerced to `NA`.
- **Verified end-to-end through the same paths as S107/S108:**
  `quarto render` (Quarto 1.7.33) executes the chunks on shipped data →
  clean HTML (deterministic —
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  runs no simulation, needs no seed, and `examplePedigree` ships an
  `age` column so no
  [`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html) value enters the
  output; confirmed byte-identical across two renders);
  `pkgdown::build_article("articles/studbook-quality-control")` (pkgdown
  2.2.0) wraps it in the site template; an `R CMD build` tarball
  confirms `vignettes/articles/` does **not** ship — zero CRAN risk, the
  21 shipping vignette files unaffected.
- **Adversarial review (two independent lenses — code-correctness +
  pedagogy/render-determinism):** no must-fix; all nine challenged
  behavioral claims confirmed against `qcStudbook.R` + ~18 helpers, and
  render determinism confirmed empirically. Two grounded fixes applied
  and re-rendered: corrected the sex-standardization claim
  ([`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  calls `convertSexCodes(ignoreHerm = TRUE)`, folding `H` into `U` — it
  never *outputs* `H`), and added a `## Setup {#sec-setup}` section
  (house-style parallel with the two sibling articles) noting QC needs
  no seed. Left the “defensible digest” column-rename nit as-is.
- **\[news-vs-changelog\]:** website-only documentation = dev-process
  history → CHANGELOG only, no NEWS (the article never ships;
  \[\[backlog-vs-changelog-placement\]\]). **Phase-3E N/A** — a
  build-ignored website article changes no package/app runtime behavior;
  the appropriate verification is render + pkgdown build + tarball, all
  done.
- **PROJECT_LEARNINGS.md:** Learning 103 added. **ROADMAP.md / analysis
  §7.1:** articles-so-far note extended to record the third article.

### 2026-06-17 — Quarto Hybrid §7.1: second Quarto article — Genetic Value Analysis (Session 108)

- **Deliverable:** a second Quarto pkgdown article,
  `vignettes/articles/genetic-value-analysis.qmd` — a scripted,
  non-Shiny walkthrough of the genetic value analysis
  ([`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md))
  on the shipped `examplePedigree` data: quality control → population of
  interest → mean kinship and genome uniqueness → the ranked report,
  plus the colony-level founder-equivalent (`fe`) /
  founder-genome-equivalent (`fg`) diversity summaries. Content
  production enabled by the slice-2 mixed-mode infrastructure stood up
  in S107 — adding an article is a drop-in `.qmd` in
  `vignettes/articles/`, no new config. **One article only** (FM
  \#18/#25). **TDD phase N/A** (documentation using existing exported
  functions + shipped data; no `R/` logic or test surface; declared
  every response).
- **Authored ground-truth-first:** ran the actual
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  pipeline on `examplePedigree` and let the real output drive the prose
  (327-animal population of interest; 199 High Value / 128 Low Value;
  `fe` 109.67 / `fg` 47.62; the rank-1 animal has higher genome
  uniqueness but *not* the lowest mean kinship — used to illustrate why
  the ranking uses both metrics). Source-checked the scoring scheme
  directly in `orderReport.R` + `rankSubjects.R` (the High-Value
  mean-kinship tier is gated on the **z-score** ≤ 0.25, not raw mean
  kinship — the article is correct where the `orderReport` roxygen
  wording is not) and the fe/fg formulas in `calcFEFG.R` (Lacy 1989).
- **Verified end-to-end through the same two build paths as S107 + a
  tarball:** `quarto render` (Quarto 1.7.33, knitr engine) executes the
  chunks on shipped data → clean HTML, deterministic via `set_seed(1L)`
  (the gene-drop behind genome uniqueness / fe / fg is stochastic);
  `pkgdown::build_article("articles/genetic-value-analysis")` (pkgdown
  2.2.0) wraps it in the site template; an `R CMD build` tarball
  confirms `vignettes/articles/` (hence this article) does **not** ship
  — **zero CRAN risk** proven, shipped CRAN vignettes unaffected.
- **Adversarial review:** a fresh reviewer checked every
  technical/genetics claim against the code — **no must-fix errors**;
  the article is *more* correct than the package’s own roxygen in three
  places (the z-score gate, the meaning of founder contribution `p`, and
  `reportGV` returning a list rather than a data frame). Three
  low-severity precision fixes applied and re-verified against the code:
  mean kinship averages over *all* animals including self
  (`meanKinship.R`), tier-2 ranking ties break on ascending mean kinship
  (`orderReport.R`), and the imports tier also requires the animal to be
  a founder.
- **Discovered, not mine — flagged for a future session:** the sibling
  article `breeding-group-formation.qmd` (S107) comments that its focal
  set is “the founders still in the colony,” but the same filter
  `!(is.na(sire) & is.na(dam))` actually selects **non-founders**
  (animals with ≥ 1 known parent). A one-line prose inversion; left
  untouched (not this session’s deliverable; FM \#8).
- **\[news-vs-changelog\]:** website-only documentation = dev-process
  history → **CHANGELOG only**, no NEWS (the article never ships;
  \[\[backlog-vs-changelog-placement\]\]). **Phase-3E N/A** — a
  build-ignored website article changes no package/app runtime behavior;
  the appropriate verification is render + pkgdown build + tarball, all
  done.
- **PROJECT_LEARNINGS.md:** Learning 102 added. **ROADMAP.md / analysis
  §7.1:** slice-2 note extended to record the second article.

### 2026-06-17 — Quarto Hybrid §7.1 Slice 2: stand up pkgdown mixed mode + first Quarto article (Session 107)

- **Deliverable:** the second implementation slice of the adopted Hybrid
  documentation policy (analysis doc §7.1, slice 2) — stood up pkgdown
  **mixed `.qmd`/`.Rmd` mode** and authored the first Quarto pkgdown
  article, `vignettes/articles/breeding-group-formation.qmd` (a
  scripted, non-Shiny walkthrough of breeding-group formation via
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  — harem and target-sex-ratio strategies — on the shipped
  `examplePedigree` data). **One slice only** (FM \#18/#25) — slices 3–4
  are separate, owner-approved sessions. **TDD phase N/A**
  (documentation + website-config deliverable; no `R/` logic or test
  surface; declared every response).
- **What changed (zero CRAN risk):** new
  `vignettes/articles/breeding-group-formation.qmd` +
  `vignettes/articles/_quarto.yml` (`project: render: ['*.qmd']`, so
  RMarkdown keeps building the `.Rmd` vignettes); `.Rbuildignore` gained
  the single line `^vignettes/articles$` (covers the article AND the
  `_quarto.yml` AND any `.quarto/` cache — the whole dir is
  website-only); `DESCRIPTION` gained `Config/Needs/website: quarto` and
  `.github/workflows/pkgdown.yaml` a
  `quarto-dev/quarto-actions/setup@v2` step so the pkgdown CI job
  installs Quarto; `.gitignore` gained `.quarto/`.
- **Config placement corrected from the general policy note:** the
  `_quarto.yml` belongs **inside `vignettes/articles/`** (pkgdown turns
  that dir into a Quarto project), not at the package root — so one
  `.Rbuildignore` line excludes everything and the root/`.Rmd` vignettes
  are untouched.
- **Verified end-to-end through two independent build paths:** (1)
  `quarto render` (Quarto CLI 1.7.33, knitr engine) executes the
  article’s R chunks on shipped `examplePedigree` data → clean HTML,
  ~1.7 s, deterministic via `set_seed(1L)`; (2)
  `pkgdown::build_article("articles/breeding-group-formation")`
  (installed pkgdown **2.2.0** + `quarto` R pkg locally) discovers the
  `.qmd`, runs `quarto render`, and wraps it in the pkgdown template →
  clean HTML with navbar. **Zero CRAN risk proven by a real
  `R CMD build` tarball** (the `vignettes/articles/` tree is absent; the
  shipping vignettes are unaffected).
- **Article accuracy:** built around
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)’s
  own roxygen `@examples` pipeline (the code `R CMD check` already
  exercises) and source-checked — `threshold` default `0.015625` (=
  1/64, second-cousin kinship),
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  does not seed internally (hence
  [`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)),
  `$group` is a `numGp + 1`-element list (last = unplaced pool). One
  owner correction applied (`minParentAge = 2.0` as a float). The
  unverified “`sexRatio` in steps of 0.5” claim (an app-UI constraint,
  not enforced by the function) was removed after reading the source.
- **\[news-vs-changelog\]:** website-only documentation/config =
  dev-process history → **CHANGELOG only**, no NEWS (the article never
  ships; \[\[backlog-vs-changelog-placement\]\]). **Phase-3E N/A** — a
  build-ignored website article changes no package/app runtime behavior;
  the appropriate verification is the render + pkgdown build + tarball,
  all done.
- **PROJECT_LEARNINGS.md:** Learning 101 added. **ROADMAP.md / analysis
  §7.1:** slice 2 marked done.

### 2026-06-17 — Quarto Hybrid §7.1 Slice 1: standardize a dev doc to `.qmd` (Session 106)

- **Deliverable:** the first implementation slice of the adopted Hybrid
  documentation policy (analysis doc §7.1, slice 1) — converted the
  developer doc `inst/extdata/meeting_notes.Rmd` →
  `inst/extdata/meeting_notes.qmd` (Quarto), making the three
  `inst/extdata/` dev docs uniformly `.qmd` (`claude_code.qmd` +
  `software_design_doc.qmd` were already converted). **One slice only**
  (FM \#18/#25) — slices 2–4 are separate, owner-approved sessions.
  **TDD phase N/A** (format conversion; no code/test surface; declared
  every response).
- **Faithful, reversible change:** `git mv` (preserves history) + a
  single YAML line, `output: html_document` → `format: html` (matching
  the two sibling `.qmd`); the document body is byte-for-byte unchanged
  (`git diff -M` reports `similarity index 99%`).
- **Zero CRAN risk — verified, not assumed:** both the old `.Rmd` and
  the new `.qmd` are build-ignored (`.Rbuildignore` line
  `^inst/extdata/meeting_notes\.` is extension-agnostic, plus
  `^inst/extdata/.*\.qmd$`), so the package source tarball contents are
  unchanged. Confirmed authoritatively by applying every `.Rbuildignore`
  regex to both filenames (`ships=FALSE` for both). No `.Rbuildignore`
  edit was needed.
- **Build-equivalent (render) verified honestly:** Quarto 1.7.33 renders
  the `.qmd` to HTML via `--no-execute`. The five embedded R chunks are
  *not* reproducibly executable in any current environment — they
  hardcode 2020-era absolute machine paths
  (`/Users/rmsharp/.../20160816_GeneticManagementTools`) and need
  packages that aren’t in the default library — so this is a historical
  meeting-notes log, not a live computational document; making it
  re-executable would be a behavior change beyond a format
  standardization and was deliberately *not* done (FM \#8). The render
  limitation is stated, not silently skipped.
- **Rmd→qmd semantic difference caught by the render:** Quarto warned
  that `nprcgenekeepr:::` (an R internal-function token quoted from a
  2020 CRAN review, in prose) looked like a malformed `:::` fenced div —
  `:::` is meaningful in Quarto but inert in R Markdown. Verified in the
  rendered HTML that the text renders correctly (a heuristic
  false-positive, no output defect); left byte-faithful rather than
  rewrite the author’s historical prose for a cosmetic warning (FM
  \#22).
- **\[news-vs-changelog\]:** a developer-doc format standardization is
  dev-process history → **CHANGELOG only**, no NEWS (the file is
  build-ignored, never user-facing;
  \[\[backlog-vs-changelog-placement\]\]). **Phase-3E N/A** — converting
  a build-ignored doc changes no package/app runtime behavior; the
  appropriate verification is the render + build-ignore check, both
  done.
- **PROJECT_LEARNINGS.md:** Learning 100 added. **ROADMAP.md / analysis
  §7.1:** slice 1 marked done.

### 2026-06-17 — Decision: adopt the Hybrid documentation strategy (Quarto analysis §7 Option B) (Session 105)

- **Deliverable:** recorded the owner’s decision to adopt **Option B
  (Hybrid)** from the Session 104 analysis. Flipped
  `docs/planning/quarto-documentation-future-proofing-analysis.md` from
  “recommendation awaiting a decision” to **ADOPTED policy** (Status
  header + TL;DR + §7 table), resolved the open §6.3 manual
  sub-decision, corrected §8, and added a §7.1 implementation-slices
  table. **No documents were converted** — each slice is a separate,
  owner-approved session (FM \#18). **TDD phase N/A**
  (decision-recording / documentation deliverable, no code surface;
  declared every response).
- **Adopted policy:** the four CRAN vignettes stay on
  `knitr`/`rmarkdown` (officially supported, zero CRAN risk); new and
  non-CRAN documentation moves to Quarto — pkgdown articles via mixed
  mode, slide decks (`revealjs`), the `inst/extdata/` dev docs.
- **§6.3 manual — resolved to option (b):** the long-form manual
  (`a3manual.Rmd` + 13 `manual_components/_*.Rmd`) is repositioned onto
  the Quarto website and dropped from the CRAN vignette set. Because
  this changes what ships to CRAN, the §8 claim that “only Option A
  intersects the submission” was **corrected**: the adopted path now
  does touch the resubmission via the manual, and that slice must be
  sequenced with `cran-2.0.0-submission-plan.md`.
- **Implementation slices (analysis §7.1), recorded in the doc + ROADMAP
  only — no GitHub issues (owner’s call):** (1) standardize the third
  `inst/extdata` dev doc to `.qmd` — no CRAN risk; (2) author new
  pkgdown articles in Quarto via mixed mode — no CRAN risk; (3) slide
  decks in Quarto `revealjs` as needed — no CRAN risk; (4) reposition
  the manual — CRAN-touching, gated on resubmission coordination.
- **ROADMAP.md:** added the documentation-engine policy under “Planned.”
- **\[news-vs-changelog\]:** a documentation-process decision is
  dev-process history → **CHANGELOG only**, no NEWS (the S104
  analysis-doc precedent; \[\[backlog-vs-changelog-placement\]\]).
  **Phase-3E N/A** — recording a decision changes no runtime behavior
  (stated, not skipped).
- **PROJECT_LEARNINGS.md:** Learning 99 added.

### 2026-06-17 — Analysis: Quarto vs. R Markdown documentation future-proofing (Session 104)

- **Deliverable:**
  `docs/planning/quarto-documentation-future-proofing-analysis.md` — an
  analysis + recommendation answering the owner’s question: should the
  package’s documentation migrate from R Markdown to Quarto to
  **future-proof** it? (Owner reframed away from build timing.)
  Research-only session; **no documents were converted** (conversion
  would be a separate, owner-approved session — FM \#18).
- **Recommendation: hybrid / partial adoption.** Keep the four CRAN
  vignettes on `knitr`/`rmarkdown` (officially supported indefinitely,
  zero CRAN risk); adopt Quarto on the non-CRAN surface where it carries
  no CRAN dependency and its benefits land — the pkgdown site, new
  long-form docs, slide decks, and the `inst/extdata/` dev docs (two
  already `.qmd`). The long-form manual is flagged as a deliberate owner
  fork (keep as a knitr vignette vs. reposition onto the website as
  Quarto).
- **Evidence base:** two adversarial research Workflows (9 + 8 agents).
  All six load-bearing claims survived an explicit attempt to refute
  them at high confidence: (a) R Markdown is *not* being deprecated —
  `rmarkdown` 2.31 / `knitr` 1.51 are actively maintained CRAN-critical
  infrastructure (“not going away, no deprecation”); the only cost of
  staying is feature stagnation. (b) A Quarto CRAN vignette adds a
  `SystemRequirements` Quarto-CLI dependency that CRAN’s check machines
  don’t guarantee (missing on macOS flavors in 2025), with a documented
  transient “no vignettes” NOTE; the Quarto maintainer himself advises
  against it for CRAN vignettes. (c) For simple single-language HTML
  vignettes the realized Quarto benefit is narrow (the CRAN engine
  disables callouts/tabsets/Bootstrap/multi-language). (d) Migration is
  mechanical and reversible; pkgdown supports a mixed `.qmd`/`.Rmd` set.
- **Relationship to the CRAN plan:** does NOT change Phases 1–6 of
  `cran-2.0.0-submission-plan.md`. The deferred Phase 2b vignette-timing
  fix is precompute on the existing `knitr` engine (`.Rmd.orig` →
  committed `.Rmd`), orthogonal to a Quarto decision; Quarto cannot help
  timing (same knitr R-chunk cost + added overhead).
- **\[news-vs-changelog\]:** an analysis/planning document is
  dev-process history → **CHANGELOG only**, no NEWS (S101 plan
  precedent). **Phase-3E:** N/A — an analysis doc changes no runtime
  behavior; verification is the adversarially-verified research +
  firsthand vignette inventory, stated not skipped.
- **PROJECT_LEARNINGS.md:** Learning 98 added.

### 2026-06-17 — CRAN Phase 2a: archival timing root cause (tests) + native pipe (Session 103)

- **Deliverable:** Phase 2 of
  `docs/planning/cran-2.0.0-submission-plan.md` (§4 Phase 2) — the
  archival root cause (CRAN “tested elapsed times”). Scoped with the
  owner to **Phase 2a (tests + native pipe + NEWS)**; **Phase 2b
  (vignette rebuild timing) deferred** to a numeric-preserving
  precompute pass. **TDD phase = REFACTOR/mechanical** (no numeric
  change → RED-first did not apply; the plan’s simulation-number risk
  was avoided, not triggered).
- **Measure-first profile (cause named by data, not assumption):**
  examples 6.6s total (slowest 1.28s — none flag); the CRAN-running slow
  tests are the **shiny module `testServer` tests** (`modGeneticValue`
  4.4s / `modBreedingGroups` 4.6s / `modInput` 2.7s /
  `modBreedingGroups_groupAddAssign` 2.2s / `modPedigree_processing`
  1.2s; no `skip_on_cran`); the raw-slowest test files are
  `skip_if_not(user=="rmsharp")` (owner-only, never on CRAN); vignettes
  ~21s (deferred to 2b). Three profiling traps documented in Learning 97
  (test harness must be
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html);
  `skip_if_not(rmsharp)` guards; `NOT_CRAN`).
- **Tests:** added file-level
  [`testthat::skip_on_cran()`](https://testthat.r-lib.org/reference/skip.html)
  to the 5 slow shiny-module integration test files — removes ~15s of
  CRAN check time; they still run on CI/locally (`NOT_CRAN=true`). The
  analytical functions they exercise have their own unit tests that stay
  on CRAN.
- **Native pipe (owner-directed):** replaced the magrittr pipe `%>%`
  with the base R native pipe `|>` throughout —
  `vignettes/simulatedKValues.Rmd` (5; dropped
  [`library(magrittr)`](https://magrittr.tidyverse.org)),
  `vignettes/ColonyManagerTutorial.Rmd` (3),
  `tests/testthat/test_makeRelationsClasses.R` (2), and the
  [`makeRelationClassesTable()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeRelationClassesTable.md)
  `@examples` (2) + hand-synced `man/makeRelationClassesTable.Rd`. R≥4.1
  floor guarantees `|>`; magrittr was the vignette’s only direct user
  (never declared), so no Suggests entry was needed.
- **NEWS (owner-directed):** added a Minor-changes “Code modernization”
  bullet for the native-pipe adoption to `NEWS.Rmd`; re-rendered
  `NEWS.md` (only the new bullet changed — no reformat).
- **Verification:** full core suite via
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)
  at `NOT_CRAN=true` (CI): **169 files, 0 failed, 0 errors** (after
  installing the missing `shinyBS` Suggest in the dev lib); at
  `NOT_CRAN=false` (CRAN): the 5 mod files skip, affected-file test time
  **14.82s → 0.01s**. `simulatedKValues.Rmd` renders with the native
  pipe (no magrittr); the `makeRelationClassesTable` example runs;
  `man/*.Rd` parses; no `%>%` remains in any converted file.
- **\[news-vs-changelog\]:** the native-pipe adoption is user-facing →
  **NEWS** (done, owner-directed); the test `skip_on_cran` is dev/CI
  infrastructure → **CHANGELOG only**. **Phase-3E:** the changed code is
  executed (vignette/example/test) and was run-verified; no `R/`
  function body or app/runtime path changed (the
  `makeRelationClassesTable` edit is roxygen only) — N/A for an app
  launch, stated not skipped.
- **Discovered (NOT done — owner’s call):** `RSelenium` is
  **undeclared** (used in e2e tests, absent from Suggests); the
  `skip_if_not(user=="rmsharp")` tests run only on the owner’s machine
  (an anti-pattern); **Phase 2b (vignette rebuild timing)** remains.
- **PROJECT_LEARNINGS.md:** Learning 97 added.

### 2026-06-17 — CRAN Phase 1: static hygiene (Session 102)

- **Deliverable:** Phase 1 of
  `docs/planning/cran-2.0.0-submission-plan.md` (§4 Phase 1) — static
  CRAN hygiene (build cruft + DESCRIPTION/metadata defects + `\value`
  docs), verified by a real `R CMD build` source tarball. **No version
  bump** (Phase 3; FM \#18/#25 held — Version stays `1.1.0.9000`,
  NEWS/CITATION.cff untouched). **TDD phase = REFACTOR/mechanical** (no
  behavioral test surface).
- **`.Rbuildignore`** (+13 lines, end-anchored & paren-free per the
  perl-regex hazard): excludes macOS/R junk via `\.DS_Store$` and
  `\.Rapp\.history$` (front-unanchored, so they also catch
  `man/.DS_Store` + `inst/extdata/.Rapp.history` — the plan’s
  root-anchored form would have missed `man/.DS_Store`) plus dev-only
  `inst/extdata` files (`*.qmd`, `README_modules.md`, `example_usage.R`,
  `trulyUnknownParents.R`, `submission.txt`) and `inst/_pkgdown.yml`.
  Deleted the stale untracked `..Rcheck/` build artifact
  (owner-approved).
- **DESCRIPTION:** fixed species typo `'Macaca' 'mulatto'` →
  `'mulatta'`; moved the renv `Config/...` field from line 1 (illegally
  before `Package:`) to the end + normalized spacing;
  `VignetteBuilder: knitr, rmarkdown` → `knitr` (rmarkdown stays in
  Suggests).
- **Docs:** added `@return`/`\value` to the two exported functions that
  lacked it —
  [`appServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/appServer.md)
  (side-effect Shiny server) and
  [`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
  (returns a `shiny.tag.list`); roxygen source + hand-synced `.Rd`
  (roxygen2 unavailable until renv; Phase 4 will canonicalize).
- **LICENSE:** reconciled copyright year — `LICENSE` `2017-2021` and
  `LICENSE.md` `2017-2024` → both `2017-2026`.
- **Verification:** `R CMD build --no-build-vignettes --no-manual`
  (base-R only, no
  [`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html))
  → tarball (708 entries) ships **0 cruft, 0 hidden files**; `read.dcf`
  parses with `Package:` first; both `.Rd` parse with `\value`; guard
  tests `test_appUI_version.R`/`test_getVersion.R` unaffected (verified
  by reading — no version/logic change; full suite deferred to Phase 4
  renv gate). See Learning 96.
- **\[news-vs-changelog\]:** packaging/metadata hygiene → **CHANGELOG
  only**; the user-facing NEWS rewrite is Phase 3. **Phase-3E N/A** — no
  runtime/app behavior changed (stated, not skipped).
- **PROJECT_LEARNINGS.md:** Learning 96 added.

### 2026-06-16 — CRAN 2.0.0 submission plan (Session 101)

- **Deliverable:** `docs/planning/cran-2.0.0-submission-plan.md` — a
  planning-workstream document to prepare `nprcgenekeepr` for CRAN:
  version → 2.0.0, `NEWS.Rmd` reorganized into user-facing Major/Minor
  changes since 1.0.8, and full CRAN readiness. **The plan is the
  deliverable** — no `R/`, test, `DESCRIPTION`, `NEWS.Rmd`, or
  `.Rbuildignore` change this session (FM \#18). **TDD phase N/A**
  (planning doc, no code surface).
- **Headline (firsthand-verified, reshapes the task):** the package is
  **ARCHIVED on CRAN** — `WebFetch` of the CRAN index page shows
  “Archived on 2025-07-29 as issues were not corrected in time” (last
  published 1.0.8, 2025-07-26; prior 2022-11-03 archive / 2025-04-24
  unarchive cycle). So this is a **resubmission of an archived package**
  whose root cause (CRAN example/test/vignette ELAPSED-TIME limits, per
  the R-pkg-devel thread) must be measured-and-fixed — a clean one-time
  local check is necessary-but-not-sufficient (FM \#24 at CRAN scale).
- **Method:** a 9-agent research+audit Workflow (`wy9xitgt6`, 5
  web-research over CRAN Policy / Writing R Extensions / r-pkgs.org /
  the two named skills / CRAN status + 4 read-only codebase auditors
  over DESCRIPTION+version-strings, `NEWS.Rmd`, R-CMD-check readiness,
  build cruft); the author re-fetched the pivotal CRAN-status claim
  firsthand. Plan = 6 phases (hygiene → timing root-cause → NEWS+2.0.0 →
  local `--as-cran` gate → cross-platform+cran-comments →
  post-acceptance), each a separate strict-TDD session with completion
  criteria, verification commands, and a STOP point; owner performs the
  actual CRAN upload (Phase 5 STOP).
- **Evidence-based inventory** included: every version-string location
  for the bump (+ the historical markers NOT to bump),
  DESCRIPTION/metadata defects (incl. the `'mulatta'` typo and missing
  `\value` on
  [`appServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/appServer.md)/[`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)),
  the `.Rbuildignore` gaps (`.DS_Store`, `.Rapp.history`, loose
  `inst/extdata` dev files), the three recurring false-positive NOTEs to
  pre-explain, and the no-reverse-dependencies fact.
- **\[news-vs-changelog\]:** a planning document is dev-process history
  → **CHANGELOG only**, no `NEWS` (no user-facing or package change; the
  actual NEWS rewrite is Phase 3). **Phase-3E N/A** — writing a plan
  changes no runtime behavior (stated, not silently skipped).
- **PROJECT_LEARNINGS.md:** Learning 95 added.

### 2026-06-16 — Audit of issue \#37 (exported functions not used by the app) — delta re-verification (Session 97)

- **Deliverable:**
  `docs/audits/ISSUE_37_UNUSED_EXPORTS_AUDIT_2026-06-16.md` — a
  read-only delta re-verification of \#37 against the S78 triage
  (2026-06-14). **TDD phase N/A** (no `R/`, test, `NAMESPACE`, `man/`,
  or issue-state change). **0 closes performed** (closing \#37 requires
  owner confirmation).
- **Headline — \#37’s actionable surface is fully drained:** both S78
  wire-in candidates shipped + their tracking issues CLOSED (**\#47**
  ORIP module mounted at `appUI.R:181`/`appServer.R:286`; **\#48**
  `getPotentialParents` via new `modPotentialParents` at
  `appUI.R:200`/`appServer.R:302`); the one docfix \#37 surfaced is
  fixed (`getPedDirectRelatives` `@examples`, S87 `2a64770f`); the
  logging island (`safeExecute`/`logModuleEvent`/`savePlotToFile`) still
  has **0 live callers**. Current reachability: **127 app-used / 39
  unused** = **0 wire-in · 39 keep-as-public-API · 0 retire**
  (`safeExecute` the lone conditional future-retire candidate).
- **Method note (→ Learning 92):** the renv project library isn’t
  materialized in this checkout
  ([`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)
  bootstraps an empty renv and fails), so reachability was recomputed
  statically — `sys.source` the 202 `R/*.R` files +
  [`codetools::findGlobals`](https://rdrr.io/pkg/codetools/man/findGlobals.html)
  under `Rscript --vanilla` (base lib only). **A method bug was
  caught:** `findGlobals(merge = FALSE)$functions` false-flagged
  `chooseDate` unused (it’s passed as a value to
  [`Map()`](https://rdrr.io/r/base/funprog.html) in `setExit.R:54` →
  lands in `$variables`); `merge = TRUE` is the correct conservative
  test and reconciled the result with S78.
- **Scope (Learning 91 applied at scoping):** read the issue body + its
  S65/S78 triage comments + both prior audit reports + CHANGELOG
  **before** any work → scoped a delta, not a re-run of S78’s verified
  per-function disposition. Right-sized **SOLO** under ultracode (a
  fan-out would repeat S78’s adversarially-verified triage = the
  Learning-91 redundancy).
- **Recommendation:** owner judgment — **close \#37** (no actionable
  work remains) **or keep it open + update the now-stale body** (it
  predates the wire-ins; lists 3 unused S3 methods, not the verified 4 —
  adds `summary.nprcgenekeeprGV`).
- **\[news-vs-changelog\]:** internal audit findings doc = dev-process
  history, **CHANGELOG only**, no `NEWS` (no user-facing or package
  change). **Phase-3E N/A** — read-only audit changes no runtime
  behavior (stated, not silently skipped).
- **PROJECT_LEARNINGS.md:** Learning 92 added.

### 2026-06-16 — Implemented-but-open audit of all 14 open issues (Learning 90 follow-through) (Session 95)

- **Deliverable:**
  `docs/audits/IMPLEMENTED_BUT_OPEN_AUDIT_2026-06-16.md` — a read-only
  audit classifying every open GitHub issue by implementation status to
  find any \#49-style work that shipped but was never closed. Motivated
  by S94’s discovery that \#49 had been fully implemented in S84 yet
  stayed OPEN ~10 sessions. Method: a 14-agent
  classify→adversarial-verify workflow; the two “criteria appear met”
  findings (#45, \#37) re-verified firsthand by the session. **TDD phase
  N/A** (read-only audit, no code surface). **0 closes performed**
  (closing requires owner confirmation).
- **Headline result — the implemented-but-open backlog is DRAINED:**
  **0** fully-implemented-but-open closeable candidates (no second
  \#49). Classifications: not-implemented **9** (#2, \#10, \#11, \#12,
  \#13, \#28, \#29, \#36, \#46 — genuinely unbuilt, mostly
  external-system/methodology features), policy-hold **4** (#45, \#9,
  \#5, \#1), ambiguous **1** (#37). Coverage 14/14 (100%).
- **Two owner-judgment items surfaced (not auto-closes):** **\#45**
  (umbrella — its four written acceptance criteria are met via closed
  sub-task \#31 `0eeee3f6` + spec on \#28, but it intentionally parents
  still-deferred \#28 → owner decides whether the umbrella closes);
  **\#37** (standing inventory — its only actionable wire-ins \#47/#48
  are both shipped and closed, the rest are keep-as-public-API by
  decision → owner decides whether to retire the inventory issue).
  **\#1/#5/#9** confirmed genuinely partial (a tested first increment
  shipped; a specific owner-named criterion still unmet) — correctly
  open.
- **Process note (→ Learning 91):** this audit substantially re-ran
  S62’s `docs/audits/BACKLOG_STALENESS_AUDIT_2026-06-12.md` (same
  question, all then-open issues, 4 days prior). The right scope was a
  delta against that baseline; the prior audit + the CHANGELOG/handoff
  record of the issue-by-issue drain (#4/#33/#49) should have been
  checked at Phase 1 before a full sweep. Owner directed: keep the
  report as-is (it stands as the firsthand “no second \#49”
  confirmation + S62 trend comparison).
- **\[news-vs-changelog\]:** internal audit findings doc = dev-process
  history, **CHANGELOG only**, no `NEWS` (no user-facing or package
  change). **Phase-3E N/A** — read-only audit changes no runtime
  behavior (stated, not silently skipped).
- **PROJECT_LEARNINGS.md:** Learning 91 added.

### 2026-06-16 — Complete the `fillBins()` `@return` documentation (#33) (Session 92)

- **Deliverable:** Completed the `@return` roxygen for the `@noRd`
  internal `fillBins()` (`R/fillBins.R:6`) — replaced the
  `#' @return A list with two TODO: RMS provide description` placeholder
  with a `\describe{}` block documenting both returned elements
  (`males`/`females` = integer vectors of counts per age bin).
  **Docs-only on a non-exported internal** (no `R/` behavior, NAMESPACE,
  `man/`, or DESCRIPTION change). Workstream = development under
  **Strict TDD** — phase declared every response; gates via
  `AskUserQuestion` (pre-RED test-approach scope, PRE-RED→RED,
  RED→GREEN, GREEN→REFACTOR); **0 stakeholder corrections**.
- **RED driver (since `@noRd` ⇒ no `man/*.Rd` for the S87 `Rd2ex`
  pattern):** a doc-completeness test in
  `tests/testthat/test_fillBins.R` reads `R/fillBins.R` via
  `testthat::test_path("..","..","R","fillBins.R")` with
  `skip_if(!file.exists(...))` for the installed context, **extracts
  only the `@return` block** (between the `@return` tag and the next
  roxygen tag), and asserts no `TODO` plus both
  `\bmales\b`/`\bfemales\b` — scoping to the block so the title’s
  existing `\code{males}`/`\code{females}` can’t falsely satisfy it (3
  failures RED at HEAD, all for the right reason; the failure output
  proved the extractor isolated only the `@return` line).
- **Contract-lock guard (green at HEAD, honestly classified):** a
  behavioral `test_that` asserting `fillBins(pedOne, seq(0L,20L,5L))`
  returns a list named `c("males","females")`, both `expect_type`
  `"integer"`, `expect_length == length(lowerAges)` — verifies the docs
  match real behavior and guards future drift.
- **Verification:** `test_fillBins.R` 11/11 green;
  `devtools::document()` produced **no** NAMESPACE/`man/`/DESCRIPTION
  change (confirms the `@noRd` path); `lintr` 0 on `R/fillBins.R` and
  the test file; full clean-regression read **0 failed / 0 error** (5
  warnings = the designed `loadSiteConfig` safety-net logs; 169 skips).
  **\[news-vs-changelog\]:** `@noRd` internal docs never render to a
  user-facing man page → **CHANGELOG only**, no `NEWS`. Phase-3E
  (runtime smoke test) **N/A** — a roxygen comment on a `@noRd` internal
  changes no runtime behavior (stated, not silently skipped). \#33 left
  OPEN pending owner confirmation.

### 2026-06-16 — Behavioral upload-path regression tests for \#4; close \#4 (Session 90)

- **Deliverable:** Finalized issue **\#4** — CLOSED it on owner
  confirmation (the fix shipped in S89, `8a3e3631`, was
  Phase-3E-verified) and added behavioral regression coverage for the
  Shiny UPLOAD path that S89 had covered only structurally (a
  `deparse(body(modInputServer))` grep). Two NEW test files;
  **test-only** (no `R/`/NAMESPACE/`man/`/DESCRIPTION change).
  Workstream = development under **Strict TDD** — phase declared every
  response, gates via `AskUserQuestion` (pre-RED scope, PRE-RED→RED,
  RED→GREEN, GREEN→REFACTOR, **+ a mid-GREEN reframe** when
  investigation changed what was testable), **0 stakeholder
  corrections**.
- **NEW `tests/testthat/test_modInput_incomplete_final_line.R` (normal
  suite, in-process):** drives `modInputServer`’s `getData` observer via
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
  with a TINY (4-line) no-trailing-newline upload through both reader
  branches (read.csv + read.table) and asserts (a) the
  `"incomplete final line"` warning does NOT escape the read and (b) all
  3 founder records survive QC. **Carries the fix-specific teeth:**
  un-muffling either read site makes both blocks RED (round-trip
  verified S90); restoring → green.
- **NEW `tests/testthat/test-e2e-input-incomplete-final-line.R` (opt-in
  `NPRC_RUN_E2E`, browser):** drives the assembled app via
  [`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html),
  uploads a no-trailing-newline copy of `ExamplePedigree.csv` through
  both reader paths, and asserts the cleaned studbook flows end-to-end
  into the Pedigree Browser table (all **3,694** records). Full-stack
  data-integrity net.
- **Key discovery (drove the two-test design; cost several cycles):**
  the `"incomplete final line"` warning is (1) a *console-only* artifact
  that never reaches the DOM or `app$get_logs()` in the assembled app,
  AND (2) only fires for *small* files — `read.table`/`read.csv` warn
  only when the header/type-detection scan actually reaches the
  unterminated final line, so a realistic-size file (e.g. 3694-row
  `ExamplePedigree.csv`) never triggers it. ⇒ the warning-suppression
  cannot be teeth-tested in a browser; the **testServer** test (tiny
  fixture, in-process where the warning IS observable) owns that teeth,
  and the **browser E2E** owns end-to-end processing.
- **Verification:** testServer test 6/6 green; teeth round-trip
  (un-muffle both sites → both blocks RED → restore → green) confirmed;
  browser E2E 2/2 green (opt-in, drives the INSTALLED app via real
  Chrome); full clean-regression read **0 failed / 0 error** (195 files;
  5 warnings = the designed `loadSiteConfig` safety-net logs); all test
  lines ≤80. **Phase-3E:** the browser E2E IS the runtime verification
  (drove the installed app); the testServer test drives the real module
  server. **Issue \#4 CLOSED.**
- **\[news-vs-changelog\]:** test-only (the user-facing fix landed in
  NEWS at S89) → **CHANGELOG only**.
- **PROJECT_LEARNINGS.md:** Learning 88 added.

### 2026-06-16 — Fix \#4: suppress the “incomplete final line” warning on files with no trailing newline (Session 89)

- **Deliverable:** Fixed issue **\#4** — reading an animal list or
  pedigree file whose final line lacks a trailing newline emitted
  `"incomplete final line found by readTableHeader on '...'"`
  (originally reported from a Shiny text upload, `0.txt`). Reproduced
  firsthand that this is **noise, not data loss**: every row, including
  the last, is read correctly (`nrow == 3`); only the warning is the
  problem. Owner chose the **root-cause fix across all readers via a
  shared helper** (over fixing only the reported upload path).
  Workstream = development under **Strict TDD** — phase declared every
  response, **3 gates** via `AskUserQuestion` (PRE-RED→RED, RED→GREEN,
  GREEN→REFACTOR) **+ a separate pre-RED scope question**
  (all-readers-via-helper vs named-readers vs app-only), **0 stakeholder
  corrections**.
- **RED:** NEW `tests/testthat/test_muffleIncompleteFinalLine.R` (7
  tests): helper unit teeth — a no-trailing-newline read emits **no**
  warning *and* preserves every row; an unrelated `warning("...")`
  **still propagates** (proves it is surgical, not blanket
  `suppressWarnings`); the helper returns `expr`’s value unchanged.
  Integration —
  [`getPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedigree.md)/[`getGenotypes()`](https://github.com/rmsharp/nprcgenekeepr/reference/getGenotypes.md)
  emit no warning + preserve rows;
  [`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md)
  emits no `"incomplete final line"` warning (its post-read LabKey call
  returns an error list without a DB; the unrelated config-missing
  warning is acceptable); and `modInputServer`’s body references the
  helper (structural lock for the server-internal `readDataFile`
  closure). All 7 failed at HEAD for the right reason (helper missing →
  3 errors; readers still warn → fail; body lacks the wrap → fail).
- **GREEN:** NEW non-exported `@noRd` internal helper
  `R/muffleIncompleteFinalLine.R` =
  `withCallingHandlers(expr, warning = ...)` that
  `invokeRestart("muffleWarning")` **only** when `conditionMessage`
  matches `"incomplete final line"` (all other warnings propagate).
  Wrapped the read call at each of the four sites: `getPedigree.R`,
  `getGenotypes.R` (`read.table`), `getFocalAnimalPed.R` (`read.csv`),
  and `modInput.R`’s `readDataFile` (both the text `read.table` and CSV
  `read.csv` branches). No new imports (base functions). `document()`
  produced **no** NAMESPACE/`man/`/DESCRIPTION change (helper is
  `@noRd`; reader signatures unchanged). **REFACTOR = confirmed no-op**
  (helper + wraps already minimal/idiomatic/lint-clean).
- **Verification:** new file **7/7 green** (12 expectations); full
  clean-regression read **0 failed / 0 error** (192 files, 1046 tests,
  167 skips; the 5 warnings are S85’s designed `loadSiteConfig`
  safety-net logs); `lintr` **0 lints** on all 5 changed `R/` files.
  **Phase-3E = PERFORMED, PASS:** `devtools::install()` then exercised
  the exported readers in the **installed** package —
  `getPedigree`/`getGenotypes` on no-newline files emit no warning and
  preserve all rows; `getFocalAnimalPed` no longer emits the
  incomplete-final-line warning **but its unrelated config-missing
  warning still propagates** (surgical proof); a control file *with* a
  trailing newline still reads cleanly.
- **\[news-vs-changelog\]:** user-facing file-reading bug fix → **BOTH**
  `NEWS.Rmd`→`NEWS.md` (new bullet under `1.1.0.9000` → Data input /
  quality control; rendered from source, diff = only that bullet)
  **and** this CHANGELOG entry. **Issue \#4 left OPEN** pending owner
  confirmation (standing close-only-on-owner-confirmation rule).
- **PROJECT_LEARNINGS.md:** Learning 87 added.

### 2026-06-16 — Housekeeping: About-tab version derived from DESCRIPTION (stale “Version 1.0.8” → dynamic getVersion()) (Session 88)

- **Deliverable:** Replaced the stale hard-coded `Version 1.0.8` strings
  (carried since S56) with the current package version. The runtime fix:
  the Shiny **About** panel (`R/appUI.R:230`) now renders
  `paste("Version", getVersion(date = FALSE))`, reusing the existing
  exported
  [`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)
  helper (which reads `packageVersion("nprcgenekeepr")`) so the
  displayed version tracks `DESCRIPTION` (`1.1.0.9000`) and can never
  drift again — the root-cause fix the owner chose over a hard-coded
  literal. The `CLAUDE.md` project-overview prose was updated to
  `1.1.0.9000` as a plain doc edit. Workstream = development under
  **Strict TDD** — phase declared every response, 3 gates via
  `AskUserQuestion` (PRE-RED→RED, RED→GREEN, GREEN→REFACTOR) + a
  separate pre-RED approach question (dynamic vs hard-coded), **0
  stakeholder corrections**.
- **RED:** NEW `tests/testthat/test_appUI_version.R` renders
  `as.character(appUI())` and, **scoped to the About panel** (the region
  following its `About GeneKeepR` heading), asserts it shows
  `Version <packageVersion>` and not the stale `Version 1.0.8`. Scoping
  was essential: the app already shows a *dynamic* version in its title
  bar (`appUI.R:47`,
  [`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)
  with build date), so an un-scoped positive assertion was a **false
  pass** at HEAD — it matched the title-bar string, not the About tab.
  After scoping, both assertions failed for the right reason at HEAD.
- **GREEN (2 edits, no `document()`):** `R/appUI.R:230`
  `p("Version 1.0.8")` →
  `p(paste("Version", getVersion(date = FALSE)))`; `CLAUDE.md` overview
  `(Version 1.0.8)` → `(Version 1.1.0.9000)`. Body-only change to
  [`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
  → no `.Rd`/NAMESPACE/DESCRIPTION change (`utils` already imported;
  `getVersion` already exported). **REFACTOR = confirmed no-op** (the
  fix reuses the existing helper and is minimal/idiomatic).
- **Verification:** new test 3/3 green; full clean-regression read **0
  failed / 0 error** (5 warnings = the designed `loadSiteConfig`
  safety-net logs from S85); `lintr` **0 lints** on `R/appUI.R`.
  **Phase-3E = PERFORMED, PASS:** `devtools::install()` + a
  [`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html)
  boot of the **installed** stock app confirmed the live About panel
  renders `<p>Version 1.1.0.9000</p>` with the stale `1.0.8` absent.
- **\[news-vs-changelog\]:** user-facing (the displayed app version) →
  **BOTH** `NEWS.Rmd`→`NEWS.md` (new bullet under `1.1.0.9000` → Shiny
  application; rendered from source, diff = only that bullet) **and**
  this CHANGELOG entry.
- **PROJECT_LEARNINGS.md:** Learning 86 added.

### 2026-06-16 — Docfix sweep: roxygen @examples corrections + dedicated tests for two zero-coverage functions (Session 87)

- **Deliverable:** Owner-scoped **full sweep + tests**. (1) Corrected
  the roxygen `@examples` for three exported functions whose documented
  example never invoked the function it documents; (2) added dedicated
  unit tests for
  [`kinshipMatrixToKValues()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinshipMatrixToKValues.md)
  and
  [`getAncestors()`](https://github.com/rmsharp/nprcgenekeepr/reference/getAncestors.md),
  which previously had **zero direct test references** in
  `tests/testthat/`. Workstream = development (documentation + test
  backfill) under **Strict TDD** — phase declared every response, 3
  gates via `AskUserQuestion` (PRE-RED→RED, RED→GREEN, GREEN→REFACTOR) +
  a separate pre-RED scope question, **0 stakeholder corrections**.
- **Evidence-based scope (read-only sweep across all exported
  functions):** 5 functions had an `@examples` block that never calls
  its own function; 3 are real defects, 2 are S3-dispatch false
  positives (`summary.nprcgenekeeprErr` /
  `print.summary.nprcgenekeeprErr`, correctly demonstrated via the
  [`summary()`](https://rdrr.io/r/base/summary.html)/auto-print generic
  — left untouched).
- **@examples fixes (3, GREEN):** `getPedDirectRelatives` (severe —
  example called `getLkDirectRelatives(ids = ...)`, the wrong function,
  and omitted the required `ped`; now
  `getPedDirectRelatives(ids = "E", ped = nprcgenekeepr::lacy1989Ped)`);
  `cumulateSimKinships` (final call was `createSimKinships(...)` → now
  `cumulateSimKinships(ped, allSimParents, pop, n = 10)`);
  `getIdsWithOneParent` (added a closing `getIdsWithOneParent(p)` call).
  `document()` regenerated only the 3 corresponding `man/*.Rd`;
  NAMESPACE unchanged (no new exports).
- **RED:** NEW `tests/testthat/test_examples_invoke_documented_fn.R`
  extracts each function’s `@examples` from `man/<fn>.Rd` via
  [`tools::Rd2ex`](https://rdrr.io/r/tools/Rd2HTML.html) (skips under an
  installed package with no `man/`) and asserts the example calls
  `<fn>(`, plus that `getPedDirectRelatives` does **not** call
  `getLkDirectRelatives(`. 4 assertions failed for the right reason at
  HEAD; all GREEN after the fixes.
- **Coverage backfill (honest degenerate cycle, declared):** NEW
  `tests/testthat/test_kinshipMatrixToKValues.R` (shape, `n + n(n-1)/2`
  row count, orientation-agnostic coefficient lookups, named/unnamed
  matrices) and `tests/testthat/test_getAncestors.R` (founder/NA →
  `character(0)`, one- and multi-generation lineages with exact order +
  setequal, and a `createPedTree(lacy1989Ped)` integration check). The
  functions already ship correctly, so these pass from the start;
  expected values were independently hand-derived and **teeth-checked**
  (perturbing an expected value fails).
- **Verification:** all 3 fixed examples run clean end-to-end
  ([`tools::Rd2ex`](https://rdrr.io/r/tools/Rd2HTML.html) → `source`),
  the docs build-equivalent per SAFEGUARDS; full clean-regression read
  **0 failed / 0 error** (the 5 warnings are the designed
  `loadSiteConfig` safety-net logs from S85); `lintr` **0 lints** on the
  3 changed `R/` files; new test files ≤80 cols by hand (`.lintr`
  excludes `tests/`). **REFACTOR = confirmed no-op** (edits and tests
  already minimal and idiomatic). **Phase-3E runtime smoke = N/A** —
  documentation + tests only, no runtime behavior change (stated, not
  silently skipped).
- **\[news-vs-changelog\]:** the `getPedDirectRelatives` example was a
  user-facing help defect (wrong function shown in
  [`?getPedDirectRelatives`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md))
  → **BOTH** `NEWS.Rmd`→`NEWS.md` (new Documentation bullet under
  `1.1.0.9000` Minor changes; rendered from source, diff = only that
  bullet) **and** this CHANGELOG entry.
- **PROJECT_LEARNINGS.md:** Learning 85 added.

### 2026-06-16 — Durable opt-in E2E for the ONPRC-gated ORIP Reporting tab (#47, \#49, Session 86)

- **Deliverable:** NEW `tests/testthat/test-e2e-orip-module.R` — a
  durable, opt-in (`NPRC_RUN_E2E=true`) browser-driven regression test
  for the **ORIP Reporting** tab wired in S83 (#47) and ONPRC-gated in
  S84 (#49). Drives the assembled modular app
  ([`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)/`appServer`)
  through
  [`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html)
  and asserts the build-time gate **end-to-end, both polarities**.
  Workstream = development (regression backfill) under **Strict TDD** —
  phase declared every response, 3 gates via `AskUserQuestion`, **0
  stakeholder corrections**. **Test-only — no `R/`, `man/`, `NAMESPACE`,
  or `NEWS` changes.**
- **Four opt-in blocks** (each
  `skip_if_not_installed("shinytest2"/"chromote")` + `skip_on_cran()` +
  the `create_test_app()` opt-in gate): (1) **ONPRC config → tab
  accessible** (active pane + the module’s unique body text); (2)
  **ONPRC → content + download** — `#oripReporting-siteInfo` reports
  `Center=ONPRC`, the Export ORIP Report button is present, and
  `app$get_download("oripReporting-downloadORIPReport")` yields a
  `Category/Metric/Value` CSV with a `Center=ONPRC` Site row
  (deterministic — the handler writes the Site section even with no
  pedigree loaded); (3) **no config (stock app) → tab ABSENT**
  (`navigate_to_tab` returns FALSE AND `oripReporting-` absent from the
  body); (4) **SNPRC config → tab ABSENT** (proves the gate keys on
  `center`, not mere config presence).
- **Config-injecting fixture:** a local `build_config_app_dir(center)`
  writes a temp `app.R` that
  `Sys.setenv(HOME=<temp dir with a complete documented-format .nprcgenekeepr_config>)`
  BEFORE `shinyApp(appUI(), appServer)` — S84/S85’s HOME-override
  Phase-3E recipe promoted to a reusable test fixture (the positive case
  can’t use the stock app, which has no config → tab hidden; the
  no-config negative case rides the stock `create_test_app()` app for
  free). It reuses the opt-in gate by calling `create_test_app()` for
  its skip side-effect — **no change to the shared
  `helper-shinytest2.R`**.
- **RED (honest degenerate cycle):** behavior already ships, so RED =
  author teeth-bearing assertions + confirm all 4 blocks self-skip
  cleanly with opt-in OFF (`SSSS`, 0 fail/error) — no literal
  red-to-green.
- **GREEN:** independently confirmed the three gate outcomes in-process
  FIRST
  ([`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
  parse →
  [`shouldShowOripTab()`](https://github.com/rmsharp/nprcgenekeepr/reference/shouldShowOripTab.md):
  ONPRC→TRUE, SNPRC→FALSE, no-config→FALSE),
  `devtools::install(quick=TRUE)`, then ran all 4 blocks with
  `NOT_CRAN=true NPRC_RUN_E2E=true` against the installed app → **9/9
  expectations PASS** (real Chrome via `chromote`).
- **REFACTOR:** reflowed 6 over-length lines to ≤80 (split the long
  `lkPedColumns` config line into the shipped example config’s
  multi-line format); re-verified parsing + a fresh 9/9 browser run.
- **Verification:** full clean-regression read **0 failed / 0 error**
  with this file **4-skipped** in the normal (opt-in-off) run; `lintr`
  clean (`tests/` is excluded in `.lintr`, consistent with prior
  sessions). The browser E2E run IS the Phase-3E runtime verification
  (FM \#24 answered head-on).
- **\[news-vs-changelog\]:** test-only addition (no `R/` code, no
  user-facing feature; the ORIP feature itself landed in `NEWS.md` at
  S83/S84) → **CHANGELOG only**.
- **PROJECT_LEARNINGS.md:** Learning 84 added.

### 2026-06-15 — Fix modular-app boot crash on a documented-format config file (#50, Session 85)

- **Deliverable:** Fixed **\#50** — the modular app’s config-loading
  observer (`R/appServer.R:58-68`) used
  `read.table(configFile, header=TRUE, sep="=")`, which cannot parse the
  **documented** config format
  (`inst/extdata/example_nprcgenekeepr_config`: comment lines, blank
  lines, multi-line / quoted / comma-separated values) and stopped with
  *“line N did not have 2 elements”*. The observer was not wrapped in
  `tryCatch`, so the error propagated and
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  failed to reach a stable state on boot for any deployment with such a
  config file present. Workstream = development under **Strict TDD** —
  phase declared every response, 3 gates via `AskUserQuestion` + a
  separate pre-RED approach question, 0 stakeholder corrections.
- **Decision (owner, via `AskUserQuestion`):** **Single source of
  truth** (issue’s suggested fix \#1) over a minimal `tryCatch`-only
  patch — parse via the tolerant
  [`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
  path so documented-format configs actually load, not merely fail-soft.
  Safe because `shared$config` is passed to
  `modInputServer`/`modPedigreeServer` but **referenced by neither
  module body** (verified by grep), so changing its shape from
  data.frame to the
  [`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
  named list has no runtime consumer impact.
- **RED:** NEW `tests/testthat/test_loadSiteConfig.R` (5 tests / 8
  expectations): no-file → `NULL`; documented
  `example_nprcgenekeepr_config` → list with `center=="SNPRC"` &
  `lkPedColumns>=6` (THE crash case); malformed config (missing
  `center`) → `NULL`, no throw (`tryCatch` safety net); a
  characterization guard that `read.table(sep="=")` errors on the
  documented file (root-cause lock, green throughout); and a structural
  `deparse(appServer)` assertion (uses `loadSiteConfig`, not
  `read.table`). The behavioral + structural assertions failed for the
  right reason at HEAD (undefined function / observer still on
  `read.table`); the characterization guard passed.
- **GREEN (2 edits + document()):** NEW exported `R/loadSiteConfig.R` =
  `getConfigFileName(Sys.info())` → `NULL` if no file, else
  `tryCatch(getSiteInfo(expectConfigFile = FALSE), error → flog.warn + NULL)`;
  rewrote the `appServer` observer to
  `shared$config <- loadSiteConfig()`. `document()` regenerated
  NAMESPACE export + `man/loadSiteConfig.Rd`. **REFACTOR:** added a
  bidirectional `@seealso \link{loadSiteConfig}` to `appServer`’s
  roxygen (re-documented); no behavior change.
- **Verification:** new tests 8/8 green; full clean-regression read **0
  failed / 0 error**; `lintr` **0 lints** on all 3 changed files (the
  transient `object_usage` warning for the brand-new function cleared
  after `devtools::install()`).
- **Phase-3E (runtime smoke): PERFORMED — PASS.** `AppDriver` boot of
  the installed app with the **real documented
  `example_nprcgenekeepr_config` (SNPRC) present**
  (HOME-override-in-`app.R` recipe) — the exact file that crashed boot
  before. App reached a stable state (`mainNavbar`=“Home”), navigation
  to “Genetic Value Analysis” worked, **0** `read.table`/“did not have 2
  elements” crash lines, **0** non-`shinyBS` error-level logs. This is
  the boot S84 had to sidestep with a stripped single-line config; the
  documented format now boots clean.
- **\[news-vs-changelog\]:** user-facing (a startup-crash bug fix) →
  **BOTH** `NEWS.Rmd`→`NEWS.md` (new bug-fix bullet under `1.1.0.9000`,
  rendered from source; diff = only that bullet) **and** this CHANGELOG
  entry.
- **PROJECT_LEARNINGS.md:** Learning 83 added.

### 2026-06-15 — Gate the ORIP Reporting tab to ONPRC-only (#49) + owner-confirmed close of \#47 (Session 84)

- **Deliverable (1):** Owner-confirmed close of **\#47** (the ORIP
  wire-in shipped S83). The owner accepted the always-visible v1; **\#47
  CLOSED** with a comment referencing commit `6fd16715` and the 13/13
  Phase-3E smoke, noting the ONPRC-gating follow-up is \#49.
- **Deliverable (2):** Implemented **\#49** — the **ORIP Reporting** tab
  is now shown **only for ONPRC**. Workstream = development under
  **Strict TDD** — phase declared every response, 3 gates via
  `AskUserQuestion` + a separate pre-RED scope/approach question, 0
  stakeholder corrections.
- **Decisions (owner, via `AskUserQuestion`):** (a) **Hide unless a real
  ONPRC config** — show only when an actual config file exists AND its
  `center` is ONPRC; the
  [`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
  default fallback (`center="ONPRC"` with no file, true in dev/CI) hides
  the tab. (b) **Build-time conditional `tabPanel`** (not dynamic
  `insertTab`) — the deployment center is fixed per server and
  [`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
  is evaluated once at construction, so the tab’s presence is a
  per-deployment constant.
- **RED:** NEW `tests/testthat/test_shouldShowOripTab.R` (5
  pure-predicate cases) + rewrote
  `tests/testthat/test_modORIPReporting.R` to inject a `siteInfo` list
  and assert the tab is PRESENT under ONPRC+real-file and ABSENT under
  SNPRC / no-file, plus a `deparse(appServer)` assertion that the server
  mount is gated on `shouldShowOripTab`. All failed for the right reason
  (undefined function / unused `siteInfo` arg / un-gated mount).
- **GREEN (3 edits):** NEW exported `R/shouldShowOripTab.R`
  (`isTRUE(hasConfigFile) && isTRUE(center == "ONPRC")`, mirroring
  `shouldShowChangedColsTab`); parameterized
  `appUI(siteInfo = getSiteInfo(expectConfigFile = FALSE))` with a
  conditional ORIP `tabPanel`; gated the `modORIPReportingServer` mount
  in `appServer.R` on the same predicate. `document()` regenerated
  NAMESPACE + `man/`. REFACTOR = no-op (kept the inline-call idiom; no
  helper extraction).
- **Verification:** new tests pass (5/5 + 4/4); full clean-regression
  read **0 failed / 0 error**; `lintr` **0 lints** on all 5 changed
  files (the transient `object_usage` warning for the brand-new function
  clears once the package is installed).
- **Phase-3E (runtime smoke): PERFORMED — PASS (3/3 scenarios).**
  `AppDriver` boots of the installed app under three real config-file
  scenarios (each generated `app.R` sets `HOME` to a temp config dir):
  **ONPRC** → tab present, navigable, all 5 ORIP outputs register
  values, 4 siblings intact; **SNPRC** → tab absent (UI + server),
  siblings intact; **no config** → tab absent, siblings intact. 0
  ORIP-namespaced errors (only the pre-existing app-wide `shinyBS`
  noise).
- **Discovered (out of scope) → filed \#50:** the pre-existing
  config-loading observer (`appServer.R:63`, from commit `6457a3a3`)
  calls `read.table(configFile, header=TRUE, sep="=")`, which CANNOT
  parse the documented config format (comments, blank lines, multi-line
  quoted values) and **crashes the modular app on boot** whenever such a
  config file is present. Surfaced by this session’s Phase-3E (first app
  boot WITH a config file). NOT fixed here (unrelated to \#49); filed as
  **\#50**.
- **\[news-vs-changelog\]:** user-facing (visible-tab behavior change) →
  **BOTH** `NEWS.Rmd`→`NEWS.md` (ORIP bullet augmented with the
  ONPRC-gating note, rendered from source; diff = only that bullet)
  **and** this CHANGELOG entry.
- **PROJECT_LEARNINGS.md:** Learning 82 added.

### 2026-06-15 — Wire in the ORIP Reporting module (#47, Session 83)

- **Deliverable:** Mounted the existing-but-unwired `modORIPReporting`
  module pair into the application — a new **ORIP Reporting** tab (after
  Summary Statistics). Two production edits: `R/appUI.R` (`tabPanel`
  with `modORIPReportingUI("oripReporting")`) and `R/appServer.R`
  (`modORIPReportingServer("oripReporting", pedigree=…, geneticValues=…, siteConfig=…)`).
  Implements **\#47** (left OPEN pending owner-confirmed close, per the
  standing rule + the \#48 precedent). Workstream = development under
  **Strict TDD** — phase declared every response, 3 gates via
  `AskUserQuestion` + a separate PRE-RED UX-fork question (tab
  placement), 0 stakeholder corrections.
- **RED:** New `tests/testthat/test_modORIPReporting.R` — 2 wiring tests
  (4 expectations) mirroring `test_modGvAndBgDesc.R`’s mount idiom: (1)
  `as.character(appUI())` must contain the `oripReporting-` namespace
  **and** “Office of Research Infrastructure Programs”; (2)
  `deparse(appServer)` must contain `modORIPReportingServer` **and**
  `oripReporting`. All 4 failed for the right reason at HEAD (markers
  absent); no module unit tests needed (the module is already tested in
  `test_modSiteConfig.R`).
- **GREEN/REFACTOR:** 2 edits matching the 7 sibling
  tabPanel/server-call idioms → 4/4 pass; full suite 0 failed / 0 error;
  `lintr` 0 lints on all 3 changed files; `document()` no-op (module
  already `@export`’d, NAMESPACE/man unchanged). REFACTOR was a
  confirmed no-op (edits already idiomatic).
- **Phase-3E (runtime smoke): PERFORMED — PASS (13/13).** Headless
  `AppDriver` boot of the installed app: ORIP tab link + all 5
  namespaced outputs/buttons + body text render; `mainNavbar` navigates
  to it (active pane shows “Export ORIP Report”); 4 sibling tabs intact;
  **0 `oripReporting`-namespaced JS errors** (the 12 `shinyBS` errors
  are pre-existing app-wide noise, separated by namespace grep). Reused
  Learning 78’s recipe (`NOT_CRAN=true` + `devtools::install()` first).
- **Owner-clarified follow-up → \#49 filed:** the tab ships
  **always-visible** this session; the owner clarified ORIP reporting is
  **ONPRC-specific** and the tab should be **gated on an Oregon-specific
  config**. That conditional-presentation change is deferred to new
  issue **\#49** (out of scope here, per 1-and-done).
- **\[news-vs-changelog\]:** user-facing (a new visible tab) → **BOTH**
  `NEWS.Rmd`→`NEWS.md` (new “Shiny application” bullet under
  `1.1.0.9000`, rendered from source) **and** this CHANGELOG entry. The
  module was previously listed in NEWS only as an existing *module
  file*, never as a reachable feature.

### 2026-06-15 — Durable opt-in E2E test for the Potential Parents tab (Session 82)

- **Deliverable:** Added
  `tests/testthat/test-e2e-potential-parents-module.R` — a durable,
  opt-in browser E2E test for the shipped **\#48** “Potential Parents”
  tab, mirroring the sibling `test-e2e-*-module.R` pattern. Closes the
  literal full-browser-chain gap S80 (mount-only AppDriver smoke +
  `testServer`) and S81 (one owner click-through) both flagged.
  Workstream = development (test backfill) under **Strict TDD** — phase
  declared every response, 3 gates via `AskUserQuestion`, 0 stakeholder
  corrections.
- **Regression backfill ⇒ no production code:** the feature already
  shipped (S80) and was owner-verified (S81), so this adds only a test
  (no `R/`, `man/`, `NAMESPACE`, or `NEWS.md` changes). The degenerate
  RED→GREEN was declared honestly at the gate: RED = assertions with
  teeth that self-skip when `NPRC_RUN_E2E` is off; GREEN = run against
  the shipped feature; REFACTOR = lint.
- **4 opt-in `AppDriver` blocks:** (1) tab accessible; (2) controls
  present (gestation input / Find button / Download CSV); (3)
  **populated path** — upload `rhesusPedigree_fromCenter.csv` → Pedigree
  Browser → Potential Parents → `maxGestationalPeriod=210` → Find →
  assert status *“Found candidate parents for 50 animal”* + table *“of
  50 entries”* + downloaded CSV = 50 rows & header
  `id,nSires,nDams,sires,dams`; (4) graceful degradation —
  `ExamplePedigree.csv` → Find → *“colony-origin”* warning. The `50`
  regression lock was independently re-derived through the app’s exact
  pipeline (both the filtered `pedigreeData` and full
  `processedPedigree` variants give 50) before the browser run.
- **Verification:** `devtools::install(quick=TRUE)` (E2E drives the
  installed copy) → `NOT_CRAN=true NPRC_RUN_E2E=true` single-file run →
  **7/7 expectations PASS, 0 fail/skip/error** in a real Chrome browser
  (this is the Phase-3E runtime verification) → clean-regression read
  **0 failed / 0 error / 0 true offenders** with the file skipping
  cleanly in the normal suite → `lintr` 0 lints.
- **PROJECT_LEARNINGS.md:** Learning 80 added (backfilling a regression
  E2E under strict TDD: honest degenerate cycle, re-derive the locked
  value through the exact pipeline, browser-E2E-is-Phase-3E, preserve
  the sibling idiom).

### 2026-06-15 — Owner-confirmed close of \#48 + clean fromCenter example dataset (Session 81)

- **Deliverable:** Owner-confirmed close of **\#48** (the
  getPotentialParents “Potential Parents” tab shipped S80), gated on a
  **live owner click-through** verified end-to-end. Workstream =
  verification + issue-management (**TDD phase = N/A** — added an
  example dataset + diagnosis, no production logic/tests).
- **Live click-through (Phase 3E, owner-run): PASS.** Part A graceful
  degradation (`ExamplePedigree.csv` → “no fromCenter field”
  empty-state); Part B populated path (new fromCenter file → 50-animal
  sortable table, status “Found candidate parents for 50 animal(s)…”,
  CSV downloaded as `potential_parents_2026-06-15.csv`). Existing tabs
  intact.
- **New shipped data:** `inst/extdata/rhesusPedigree_fromCenter.csv`
  (`rhesusPedigree` + `fromCenter=TRUE`, 375 animals, unknown parents as
  **literal `NA`**) — a purpose-built clean fixture, because every
  shipped pedigree example is a deliberate input-error QC fixture and
  none reaches the feature’s happy path. Owner chose the
  `rhesusPedigree` source via `AskUserQuestion`.
- **Defect caught by the click-through (FM \#24):** the first staged
  file wrote unknowns as **empty cells**; the app’s reader (`read.table`
  default `na.strings="NA"`, `modInput.R:274`) reads `""` as the empty
  string, so `""` landed in both the sire and dam columns →
  `correctParentSex.R:71` *“both sire and dam”* error. My headless
  pre-check had used `na.strings=c("","NA")`, masking it. Rewrote with
  literal `NA` and re-verified against the app’s exact reader → clean +
  50 candidates.
- **Diagnosed non-defects firsthand:** the *“fromCenter → fromcenter”*
  case-change warning is cosmetic (`fixColumnNames.R:20` lowercases all
  headers, `:61` restores `fromCenter`; the cleaned studbook keeps
  `fromCenter`); *“No data available in table”* = the empty Errors-tab
  placeholder.
- **GitHub:** **\#48 CLOSED** (owner-confirmed). Umbrella **\#45**’s
  getPotentialParents line now delivers verified app value. Open issues
  18 → 17.
- **PROJECT_LEARNINGS.md:** Learning 79 added (click-through-first +
  replicate-the-app’s-exact-reader).

### 2026-06-15 — Implement \#48: wire getPotentialParents into a new Potential Parents tab (Session 80)

- **Deliverable:** Implemented the owner-ratified (S79)
  `getPotentialParents` Shiny wire-in under **Strict TDD** (RED → GREEN
  → REFACTOR with phase gates). Turns shipped package-API logic (the S74
  \#31 gestation-derived dam window) into user-visible app value. The
  build-from-scratch second session that S79’s Learning 77 predicted.
- **TDD phase: full RED → GREEN → REFACTOR**, every transition gated via
  `AskUserQuestion` (PRE-RED→RED, RED→GREEN, GREEN→REFACTOR). 0
  stakeholder corrections.
- **New code:** `R/modPotentialParents.R` — a pure
  `flattenPotentialParents()` helper (list-of-lists → render/CSV-ready
  data.frame, `NULL`/empty → 0-row),
  [`modPotentialParentsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsUI.md)
  (numeric `maxGestationalPeriod` input default 210, “Find Potential
  Parents” button, sortable `DT` table, CSV download, graceful
  empty-state messages), and
  `modPotentialParentsServer(id, pedigree, minParentAge = 2.0)`.
- **Tests:** `tests/testthat/test_modPotentialParents.R` — 14 tests / 43
  expectations covering the helper (cols, NULL/empty, multi-animal
  flatten, empty-sires, CSV round-trip), the UI (controls + namespace +
  default 210), and the server via
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
  (happy path on the rhesus fixture, no-`fromCenter` empty state,
  no-unknowns empty state, return shape). All pass.
- **Wiring (2 edits):** `appUI.R` —
  `tabPanel("Potential Parents", icon("search"), modPotentialParentsUI("potentialParents"))`
  after Breeding Groups; `appServer.R` —
  `modPotentialParentsServer("potentialParents", pedigree = reactive(shared$currentPedigree))`.
- **Data seams honored** (from \#48): no `fromCenter` column →
  `getPotentialParents` returns `NULL` → empty-state, not error;
  `minParentAge` reuses the QC 2-year default as a server param (owner
  ratified only the gestation UI input, so no second UI input added —
  scope held); empty results → empty-state message.
- **Verification:** `devtools::check()` clean (0 errors / 0 warnings / 0
  notes); full clean-regression read 0 real failed/error; `lintr` clean
  on the new module + test files; docs regenerated
  (`modPotentialParents*` exported, `flattenPotentialParents` kept
  internal via `@noRd`).
- **Phase-3E runtime smoke test (mandatory, performed):** booted the
  assembled app headlessly via
  [`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html)
  (`inst/shinytest/app.R`, `NOT_CRAN=true` to bypass the CRAN guard, dev
  package installed first). Confirmed: app boots with full server init
  (incl. the new module), the tab + all four controls mount, default 210
  set, navigation works, existing tabs intact, module outputs
  (`statusMessage`/`resultsTable`/`downloadParents`) register
  error-free. The only log “errors” are pre-existing
  `shinyBS is not defined` JS reference errors (app-wide, not from this
  module).
- **\[news-vs-changelog\]:** user-facing feature → **also** `NEWS.md`
  (new “Shiny application” bullet under `1.1.0.9000`), plus this
  CHANGELOG process entry. \#48 remains OPEN pending owner-confirmed
  close; umbrella \#45 unchanged.
- **NEWS source-sync fix (owner-flagged mid-session):** `NEWS.md` is
  generated from `NEWS.Rmd` (`github_document`), but prior sessions had
  edited the generated `NEWS.md` directly, leaving `NEWS.Rmd` missing
  three shipped entries — **NEW-47** (`getDescendantPedigree`),
  **NEW-48/#44/#38** (`getAutoIdFormat`/`setAutoIdFormat`),
  **NEW-49/#31** (`getPotentialParents` gestation window). Back-ported
  all three into `NEWS.Rmd`, added the \#48 entry to the source, and
  regenerated `NEWS.md` via
  [`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html);
  verified `NEWS.md == render(NEWS.Rmd)` (escaping now consistently
  `\#`). Going forward, edit `NEWS.Rmd` and regenerate — not `NEWS.md`
  directly.

### 2026-06-14 — Resolve UX forks for the getPotentialParents wire-in; deprioritize ORIP (Session 79)

- **Deliverable:** Resolved the three UX/design forks for the
  **getPotentialParents wire-in** (the \#37 integration of the S74 \#31
  logic, scoped under umbrella \#45) with the owner via
  `AskUserQuestion`, and recorded the ratified design on a new tracking
  issue **\#48** so a following session can implement under TDD.
  Design/decisions only — **no code**. Also deprioritized **\#47
  (ORIP)** per owner direction. Open issues **17 → 18** (one new issue,
  \#48).
- **TDD phase = N/A** (design/decisions; no production code or tests —
  same classification as S76/S77/S78).
- **Owner decisions (via `AskUserQuestion`, all applied, 0
  corrections):** (1) **`maxGestationalPeriod` source** = a **numeric
  input** prefilled with the rhesus default 210, user-overridable (v1
  single-species per \#45; species-keyed gestation stays \#46); (2)
  **location** = a **new top-level “Potential Parents” tab** (peer to
  the 8 existing module tabs); (3) **trigger/output** = a **“Find
  Potential Parents” button** → sortable table (animal → candidate
  sires/dams) → **CSV download** (the app’s `downloadHandler` idiom).
- **Firsthand grounding (recompute-don’t-inherit):** read
  `getPotentialParents.R` in full (gestation dam window `:83-85`,
  exclusion `:106`; zero production callers), `appUI.R` (8 mounted
  module tabs), `appServer.R:104-293` (the
  `modXxxServer(id, <reactives>)` wiring + `shared$currentPedigree`
  flow), and the `fromCenter` producers (`convertFromCenter` /
  `qcStudbook`). Confirmed the data seams for the implementer
  (`fromCenter`-absent → `NULL`; `minParentAge` has no signature
  default; empty-results state). Noted \#45’s body line-map predates S74
  and is stale.
- **Deprioritization (#47 ORIP):** the repo had **no priority labels**
  and no `BACKLOG.md` (Issues are the backlog), so created a
  `low priority` label and applied it to \#47 (owner-directed). ORIP’s
  module already exists — a **mount-only** wire-in, correctly deferred
  behind the larger **build-from-scratch** \#48 (→ Learning 77).
- **New issue:** **\#48** “Wire in getPotentialParents — new Shiny
  surface for animals with unknown parents” (`enhancement`) — captures
  the three ratified forks, the from-scratch module/test/wiring task,
  the data seams, the \#28/#46 out-of-scope boundary, and the mandatory
  Phase-3E smoke test; references \#37/#45.
- **Issue tracker:** \#48 filed; register-ratified **link comment** on
  umbrella **\#45** (additive — prior comments preserved, FM \#22).
  Nothing closed; \#45 stays OPEN. Verified: \#48 OPEN, \#45 OPEN (3
  comments), \#47 labeled `low priority`, open count 18.
- **\[news-vs-changelog\]:** CHANGELOG only — resolving design forks +
  filing an issue is dev-process history, not a user-facing release note
  (no `NEWS.md` entry); no `BACKLOG.md` file (open work lives in GitHub
  Issues).

### 2026-06-14 — Triage \#37: wire-in / keep / retire the unused exports (Session 78)

- **Deliverable:** Triaged GitHub issue **\#37** (“Exported functions
  not currently used by app”) — a firsthand, clustered disposition of
  every exported-but-app-unreachable function as **wire-in /
  keep-as-public-API / retire**, recorded as an [additive triage
  comment](https://github.com/rmsharp/nprcgenekeepr/issues/37#issuecomment-4703983124).
  Grooming/triage only — **no code**. \#37 stays **OPEN** (the standing
  inventory). One new issue filed (#47). Open issues **16 → 17**.
- **TDD phase = N/A** (grooming/triage; no production code or tests —
  same classification as S73/S76/S77).
- **Recompute-don’t-inherit:** re-ran the issue’s own documented method
  firsthand (call-graph reachability seeded at
  `runModularApp`/`runGeneKeepR`/`appUI`/`appServer`, transitive closure
  of
  [`codetools::findGlobals`](https://rdrr.io/pkg/codetools/man/findGlobals.html)).
  **The S65 (2026-06-12) snapshot had drifted:** now **158 exports / 119
  reached / 39 unused** (was 155/116/39); `setAutoIdFormat` (S71
  \#44/#38) is a new unused export the issue body predates; `chooseDate`
  is no longer unused. Reachability confirmed clean (no
  S3/`do.call`/`match.fun`/[`get()`](https://rdrr.io/r/base/get.html)
  path reaches any of the 39).
- **Method:** a Workflow (`wf_be838846-794`) — **9 parallel cluster
  investigators** (each gathering firsthand: definition,
  roxygen/`@examples`, tests, vignette/`inst` use, non-app package
  callers, git provenance, related issue) + an adversarial
  **completeness critic**. The critic earned its keep (→ **Learning
  76**): it (1) **overturned a fabricated caller-edge** —
  `calcFE`/`calcFG` were claimed “called by `calcFEFG`” but have **no
  live callers** (`calcFEFG` computes via
  `calcFounderContributions`+`calcRetention`; `reportGV` calls
  `calcFEFG`); (2) surfaced two **closed islands** (obfuscation trio
  rooted at `obfuscatePed`; logging/error/export trio
  `logModuleEvent`←`safeExecute`/`savePlotToFile`, reachable from
  nothing live) whose dispositions are coupled; (3) downgraded the
  investigators’ uniform “high-confidence wire-in” on the infra island
  to a genuine owner-decision; (4) corrected the cluster’s roadmap issue
  (#8 is CLOSED; **\#10** is the open sim-kinship home). Every
  load-bearing critic claim re-verified firsthand against the working
  tree before recording.
- **Result: 2 wire-in · 37 keep-as-public-API · 0 retire.** “Exported
  but app-unreachable” is not “dead code” — the package deliberately
  exposes script/interactive API, so the default is
  **keep-as-public-API** and nothing reached the breaking-change retire
  bar.
- **Owner decisions (via `AskUserQuestion`, applied):** (1) **ORIP
  reporting module** (`modORIPReportingUI`+`modORIPReportingServer`, a
  complete-but-never-mounted module) → **wire-in** as a grant-reporting
  tab (filed as **\#47**); (2) **logging/error/plot-export island** →
  **keep as-is / defer** (adopt incrementally; `safeExecute`, zero
  callers, is a future-cleanup retire candidate); (3) **founder/genetic
  summary table helpers**
  (`makeFounderStatsTable`/`makeGeneticSummaryTable`) →
  **keep-as-public-API** (the app already renders founder stats inline
  at `modSummaryStats.R:583-638`; wiring in = DRY refactor of working
  code, no functional gain). The other wire-in —
  **`getPotentialParents`** — is the S74 \#31 feature already homed
  under umbrella **\#45** (#37 wiring gates its app value).
- **Docfixes surfaced (not done — separate session):**
  `getPedDirectRelatives` `@examples` (`R/getPedDirectRelatives.R:27`)
  calls `getLkDirectRelatives`, not itself; optional dedicated tests for
  `kinshipMatrixToKValues` and `getAncestors` (currently
  transitive-only).
- **New issue:** **\#47** “Wire in the ORIP reporting module (mount
  modORIPReporting\* in appUI/appServer)” (`enhancement`) — captures the
  owner-ratified wire-in; references \#37.
- **Issue tracker:** triage posted as an **additive comment** on \#37
  (the owner’s S65 re-verification body/comment preserved — FM \#22);
  \#47 filed. Nothing closed; \#37 remains OPEN. Verified: \#37 OPEN (2
  comments), \#47 OPEN, open count 17.
- **\[news-vs-changelog\]:** CHANGELOG only — a triage recorded on an
  issue + filing an issue is dev-process history, not a user-facing
  release note (no `NEWS.md` entry); no `BACKLOG.md` file (open work
  lives in GitHub Issues).

### 2026-06-14 — Ratify \#28 open-decisions register (Session 77)

- **Deliverable:** Ratified the **8 `[OPEN]` items** in \#28’s §13
  open-decisions register (the S76 colocation data-model spec) via owner
  sign-off, and recorded the decisions back onto **\#28** ([ratification
  comment](https://github.com/rmsharp/nprcgenekeepr/issues/28#issuecomment-4703716881))
  — every item moves **\[OPEN\] → \[DECIDED\]**. Design/grooming only —
  **no code**. \#28 stays **OPEN** (the register clears the
  *design/semantics* gate; implementation remains gated on
  \#11/#12/#37/#46). Open issues **15 → 16** (one new issue filed —
  \#46, below).
- **TDD phase = N/A** (design/grooming; no production code or tests —
  same classification as S73/S76).
- **Method:** a verify-and-sharpen Workflow (`wf_b8035a53-5be`) — **8
  parallel item-verifiers** (one per register item, each re-reading the
  spec’s code claims firsthand against the working tree and
  adversarially stress-testing its `[REC]`) + an adversarial
  **completeness critic**. The critic reduced an over-asked 8-item
  register to **4 genuine owner-decisions** (items 1/2/3 + item 6’s
  provenance half), with the rest as ratifiable corollaries/deferrals;
  it also surfaced two §7 policy gaps absent from §13. Decisions posed
  via `AskUserQuestion` (2 rounds, staggered so item 2 could be informed
  by item 1’s answer); rubber-stamps folded into one batch ratification.
- **Owner decisions (all ratified as recommended):** (1) **missing-dam
  inference** = mother–infant co-housing model with a required,
  no-default, species-tunable `postnatalCoHousingWindow` +
  gestation-presence, strictly **soft-rank** (hard-filter rejected); (2)
  **both-unknown** = **dam-side only** via the focal-animal anchor
  (soft-rank), sire side unranked; (3) **output** = additive-only
  invariant locked, concrete carrier deferred to implementation; (4)
  **coherent obfuscation** = one shared per-animal delta + alias
  FK-remap, built with \#28; (5) **v1 single-species**, \#28 does not
  block on first-class species; (6) **provenance** = stamp pull-date +
  source id (full bitemporal deferred); (7+8) **defer flat-file
  ingestion & POSIXct** (LabKey-only, Date resolution) pending a
  concrete source; **§7 QC policy** = open-start contributes no overlap,
  contradictory rows raise a QC warning.
- **Two firsthand corrections to the S76 spec** (caught by the
  verification workflow): **(a)** item 2’s written `[REC]` (“require ≥1
  known parent — case 3 is anchorless”) is **unsound** —
  `getPotentialParents.R:46-48`’s inclusive-OR filter means a
  both-unknown infant’s *own* birth-time location is a valid
  **dam-side** anchor (only the sire side is anchorless); so the
  decision flips to dam-side colocation. **(b)** §10 **mis-cited \#36**
  as the “make species first-class” prerequisite — \#36 is actually the
  chimpanzee age-pyramid *display* ticket; first-class species support
  was un-ticketed and is now **\#46**.
- **Sizing notes recorded for the eventual \#28 implementer:**
  `postnatalCoHousingWindow` is a NEW required, species-dependent
  parameter (no default, mirrors `maxGestationalPeriod`);
  `obfuscateDate.R:49-57`’s per-element re-draw-to-floor must be
  reworked into a per-animal draw (changes existing obfuscation output,
  breaks current `obfuscatePed`/`obfuscateDate` test expectations); the
  scored-output carrier/columns are deferred until \#37’s app consumer +
  items 1/2 are concrete.
- **New issue:** **\#46** “Make species a first-class attribute
  (ingestion + species-keyed gestation/postnatal window)”
  (`enhancement`) — the real multi-species dependency, distinct from
  \#36’s display scope; owns the corrected §10 dependency.
- **Issue tracker:** ratification posted as an **additive comment** on
  \#28 (S76 spec body/comments preserved — FM \#22); register-ratified
  link comment on **\#45**; **\#46** filed. Nothing closed; \#45/#28
  remain OPEN. Verified: \#28 OPEN (3 comments), \#45 OPEN (2 comments),
  \#46 OPEN, open count 16.
- **\[news-vs-changelog\]:** CHANGELOG only — ratifying a register on an
  issue + filing an issue is dev-process history, not a user-facing
  release note (no `NEWS.md` entry); no `BACKLOG.md` file (open work
  lives in GitHub Issues).

### 2026-06-14 — Spec \#28: colocation data model (Session 76)

- **Deliverable:** Wrote a colocation data-model spec onto GitHub issue
  **\#28** (the deferred sub-task under umbrella **\#45**), satisfying
  umbrella **acceptance criterion \#4** (“#28 has a written data-model
  spec — grain of colocation; source query — recorded on \#28 before any
  implementation”). Design/grooming only — **no code**. \#28 stays
  **OPEN** (a spec clears the design gate; it does not complete the
  data-dependent sub-task). Open issues unchanged at **15**.
- **TDD phase = N/A** (design/grooming; no production code or tests —
  same classification as S73’s consolidation).
- **Method:** firsthand subsystem map via a Workflow (5 parallel facet
  readers — conception primitive / pedigree data-model+ingestion /
  LabKey-Oracle-ARMS sourcing / existing location+temporal constructs /
  colocation semantics — + an adversarial completeness critic), then
  firsthand re-verification of every load-bearing claim before the
  outward-facing post (Learning 70 / recompute-don’t-inherit → new
  **Learning 74**). Re-read firsthand: `getPotentialParents.R` (full,
  post-S74), `getPossibleCols`, `getDateColNames`, `getSiteInfo`,
  `getDemographics`, `obfuscateDate`, `obfuscatePed`, `fixColumnNames`,
  `qcStudbook` column-handling.
- **Owner decisions (via `AskUserQuestion`, applied):** temporal model =
  **Date-ranged residency intervals** (day resolution, matching every
  existing date column); colocation grain = **configurable,
  finest-available default** (cage/room/enclosure/building); colocation
  effect = **soft rank with fallback** (never empties an age-eligible
  set; no-location candidates retained as `colocation-unknown`); v1
  scope = **source-agnostic model + optional `location` arg that
  degrades to byte-identical (`location = NULL`) behavior** — not
  hard-blocked on \#11/#12.
- **Spec content (13 sections + acceptance criteria):** a separate
  many-rows-per-id location entity `{id, location, grain, start, end}`
  (exempt from `removeDuplicates`); the
  interval-overlap-vs-conception-window predicate reusing the existing
  `maxGestationalPeriod` primitive; ingestion mirroring
  `getDemographics`/`getSiteInfo` (new
  `lkLocationColumns`/`mapLocationColumns`/`locationQueryName`); a
  null/partial-coverage matrix; and the **obfuscation-coherence
  requirement** (the critic+firsthand finding — `obfuscatePed` jitters
  each Date column independently ±30 d and covers only the pedigree,
  which would corrupt overlap math). Carries an **open-decisions
  register** (missing-dam inference model + postnatal co-housing window
  — flagged as *invented design awaiting husbandry ratification*, not
  derived; output reshape coordinated with \#37; species/#36 ordering;
  bitemporal handling; flat-file ingestion) for sign-off before sizing.
- **Honest scope notes recorded on \#28:** \#11 (Oracle) is
  demographic-only/unspecified and \#12 (ARMS) is an empty stub, so the
  gating is *nominal* — the spec defines the model source-agnostically;
  “source query” is satisfied at the idiom level (mirror
  `getDemographics`), not a concrete query; the JMAC `species` column
  survives ingestion as a trailing `novelCol` (`qcStudbook.R:281-283`)
  but is read nowhere.
- **Issue tracker:** spec posted as a **comment** on \#28 (additive —
  owner’s body/comment preserved, FM \#22); criterion-#4-satisfied link
  comment on **\#45**. Nothing closed; no issue state changed.
- **\[news-vs-changelog\]:** CHANGELOG only — a spec recorded on an
  issue is dev-process history, not a user-facing release note (no
  `NEWS.md` entry); no `BACKLOG.md` file (open work lives in GitHub
  Issues).

### 2026-06-13 — Close \#31: gestation-derived dam-exclusion window (Session 75)

- **Deliverable:** Closed GitHub issue **\#31** (“Use gestational length
  instead of hack for dam identification”) as completed — the
  gestation-derived dam-exclusion window shipped in S74 (`0eeee3f6`) and
  the owner confirmed the close this session. Open issues **16 → 15**.
  Completes the \#31 lifecycle: S73 consolidate (under umbrella \#45) →
  S74 implement → S75 close (one deliverable per session).
- **TDD phase = N/A** (administrative issue-close; no production code —
  same classification as S69/S72).
- **Firsthand verification before the irreversible close** (per the
  standing “don’t close an OPEN issue without firsthand evidence” rule +
  Learning 69): mapped the committed tree (`0eeee3f6`) against umbrella
  \#45’s acceptance criteria 1–3 (#31’s scope) — (1) the dam window is
  driven by the existing `maxGestationalPeriod` scalar, no parallel
  param (`getPotentialParents.R:83-85`, signature unchanged); (2) two
  tests demonstrate dam selection responds to `maxGestationalPeriod`
  (synthetic-exclusion + the explicitly-named criterion-2 test,
  `test_getPotentialParents.R:131-190`); (3) the `:92-93` “hack” TODO is
  resolved, the roxygen documents the dual use + intentional sire/dam
  asymmetry, and every dropped-dam fixture delta carries a per-delta
  biological justification. Re-ran the target file (21/21) and the full
  suite (0 failed / 0 error) firsthand.
- **Close comment** (with `0eeee3f6` pointer): criterion-by-criterion
  map + honest scope notes — \#31’s original “add a `gestationalLength`
  parameter” suggestion was intentionally superseded by the owner’s S73
  decision to extend the existing `maxGestationalPeriod`;
  species-specific gestation remains a documented dependency under \#45;
  the function is exported-but-unwired (#37).
- **Issue tracker:** **15 open** (was 16). \#31 `state=CLOSED`
  (verified). Umbrella \#45 + sub-task \#28 remain OPEN.
- **\[news-vs-changelog\]:** CHANGELOG only — closing an issue is
  dev-process history, not a user-facing release note (no `NEWS.md`
  entry); no `BACKLOG.md` file (open work lives in GitHub Issues).

### 2026-06-13 — Implement \#31: gestation-derived dam-exclusion window in getPotentialParents (Session 74)

- **Deliverable:** Replaced the “hack” in
  [`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
  (a fixed ±½-year birth window for excluding candidate dams, flagged
  with a TODO at `:92-93`) with a principled gestation-derived window
  driven by the **existing** `maxGestationalPeriod` parameter — the dam
  side now gets the gestation treatment the sire side already had.
  Resolves the near-term, low-lift sub-task of umbrella **\#45**.
  `devtools::check()` clean (0/0/0); full suite 0 failed / 0 error.
- **TDD phase = RED→GREEN→REFACTOR(skipped)** — a real TDD code session
  (first since S71). All three transition gates + a separate pre-RED
  scope decision posed via `AskUserQuestion`; phase declared atop every
  response; **0 stakeholder corrections**.
- **The change (one rule):** a female who delivered another offspring
  within `maxGestationalPeriod` days of the focal birth cannot have
  gestated the focal animal (a female bears one offspring at a time), so
  she is excluded as a candidate dam. The `births` window
  (`getPotentialParents.R`) now uses
  `pUnknown$birth[i] ± maxGestationalPeriod` instead of `± dYear/2L`
  (182.5 d).
- **Scope (owner-decided, minimal):** only the `births` exclusion window
  changed. The sire/dam exit-check asymmetry (`exit ≥ birth − gestation`
  for sires vs `exit ≥ birth` for dams) is **biologically correct**
  (sire→conception, dam→birth) and was documented, not changed. The
  preferential band (`births_plus_minus_one`) was left untouched —
  analysis proved moving its inner edge is a behavioral no-op (the wider
  exclusion always removes the overlap region first).
- **Behavior change, verified + justified firsthand (not silently
  regenerated):** the exact-set fixtures `dams_1` (BRI2MW) drop `0B7XRI`
  (−193 d) / `PHCADH` (+195 d); `dams_4` (FEEN9W) drop `1SIP4V` (+183 d)
  / `DMI0QY` (+192 d) / `HV7LZ3` (−192 d) — each delivered another
  offspring inside the new ±210 d window. No dams added, no fallback
  triggered, sires unchanged. Backed by two from-first-principles
  driving tests: a hand-verifiable synthetic-pedigree exclusion test and
  a differential-responsiveness test (acceptance criterion \#2).
- **\[news-vs-changelog\]:** BOTH — a behavior change to an exported
  function is user-facing → `NEWS.md` NEW-49; this entry is the
  dev-process record. \#31 left **OPEN** (implemented, check-green;
  close is a separate owner-confirmed step).

### 2026-06-13 — Consolidate parent-ID cluster \#31 + \#28 → umbrella \#45 (Session 73)

- **Deliverable:** Created umbrella design issue **\#45** (“Principled
  parent identification in getPotentialParents via estimated conception
  date”) consolidating the two open parent-identification issues —
  **\#31** (replace the dam-exclusion “hack” with gestational length)
  and **\#28** (timestamped colocation at birth − gestation). Both kept
  **OPEN** as distinct, cross-linked sub-tasks — they are **not**
  duplicates. Open issues **15 → 16**. Analogous to S70’s \#44
  consolidation, but the disposition differs: the research showed
  \#31/#28 are distinct work (a linking umbrella), not
  duplicates-to-close.
- **TDD phase = N/A** (grooming/design; no production code or tests —
  same classification as S70).
- **Method:** firsthand subsystem map via a Workflow (4 parallel facet
  readers — core fn / callers / gestation+location data infra / tests
  — + an adversarial completeness critic), then firsthand
  re-verification of every load-bearing claim before the outward-facing
  create/link (Learning 70 / recompute-don’t-inherit). The verification
  corrected an overstatement (a `species` column DOES exist in some
  example inputs, just not the canonical fixtures).
- **Key findings (verified firsthand):** the shared primitive
  (conception date = birth − gestation) is **already half-implemented**
  as the existing `maxGestationalPeriod` param, applied sire-side only
  (`getPotentialParents.R:62`); \#31 is a bounded in-function refactor
  (the dam side never got the treatment) while \#28 needs a
  timestamped-colocation data model the package **lacks** (blocked on
  \#11/#12); `getPotentialParents` is experimental + **unwired** (→
  \#37); \#31 is a **behavior change** (the test asserts exact dam/sire
  sets via `expect_identical`), not a pure refactor.
- **Owner decisions (via `AskUserQuestion`):** linking umbrella with
  both sub-tasks open; narrow scope (`getPotentialParents` only);
  reuse/extend the existing `maxGestationalPeriod` (no parallel
  parameter).
- **\[news-vs-changelog\]:** CHANGELOG only — issue consolidation is
  dev-process history, not a user-facing release note (no `NEWS.md`
  entry); no `BACKLOG.md` file (open work lives in GitHub Issues).

### 2026-06-13 — Close \#44 + \#38: configurable auto-ID format (Session 72)

- **Deliverable:** Closed GitHub issues **\#44** (umbrella) and **\#38**
  (generation sub-task) as completed — the configurable auto-ID feature
  shipped in S71 (`14c8e84d`) and the owner confirmed the close this
  session. Open issues **17 → 15**. Completes the \#44 lifecycle: S70
  consolidate → S71 implement → S72 close (one deliverable per session).
- **TDD phase = N/A** (administrative issue-close; no production code —
  same classification as S69/S70).
- **Firsthand verification before the irreversible close** (per the
  standing “don’t close an OPEN issue without firsthand evidence” rule +
  Learning 69): confirmed the committed tree (`14c8e84d`) against
  **each** of \#44’s 8 acceptance criteria — exports in `NAMESPACE`, the
  predicate routing all 7 detection sites + 2 generators, the round-trip
  tests, the docstring/tooltip updates — and that the full suite +
  `devtools::check()` passed on exactly that state. Mapped criteria →
  code in the close comment.
- **Close comments** (with `14c8e84d` pointer): \#44 carries the
  criterion-by-criterion map + the documented known limitation
  (prefix-only detection still over-matches real prefix-IDs — the
  owner-approved byte-identical tradeoff); \#38 maps
  `setAutoIdFormat`/`getAutoIdFormat`/`addUIds`-format-param to its
  asks. `gh issue close --reason completed`.
- **Issue tracker:** **15 open** (was 17). \#44/#38 `state=CLOSED`
  (verified).

### 2026-06-13 — Implement \#44/#38: configurable auto-generated unknown-ID format (Session 71)

- **Deliverable:** Implemented umbrella issue **\#44** (and its **\#38**
  sub-task) via strict TDD (RED→GREEN→REFACTOR-skipped). The
  auto-generated placeholder-ID format for unknown parents is now
  configurable from a single source of truth, default `"U%04d"`,
  **byte-identical with no configuration**. Executes S70 SUGGESTED-NEXT
  candidate (1). Owner decisions (via `AskUserQuestion`): **full \#44**
  scope; **prefix-only byte-identical** detection; **case-sensitive**
  reconciliation.
- **TDD:** first code session since S68. Three phase gates posed via
  `AskUserQuestion` (PRE-RED→RED, RED→GREEN, GREEN→REFACTOR-skipped)
  plus a separate pre-RED scope/approach decision (3 questions). **0
  stakeholder corrections.**
- **New code:** `R/autoIdFormat.R` —
  [`getAutoIdFormat()`](https://github.com/rmsharp/nprcgenekeepr/reference/getAutoIdFormat.md)
  /
  [`setAutoIdFormat()`](https://github.com/rmsharp/nprcgenekeepr/reference/setAutoIdFormat.md)
  (exported, over `getOption("nprcgenekeepr.autoIdFormat", "U%04d")`,
  mirroring the `.debug`/`.verbose`/`.gva_seed` convention) + internal
  `getAutoIdPrefix()` and `isGeneratedUnknownId()` (case-sensitive,
  NA-preserving like the `startsWith`/`stri_sub` it replaces).
- **Threaded through:**
  [`addUIds()`](https://github.com/rmsharp/nprcgenekeepr/reference/addUIds.md)
  gains a `format =` param and mints via `sprintf(format, …)` (≡
  default);
  [`obfuscateId()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateId.md)
  mints with `getAutoIdPrefix()` and detects via the predicate;
  [`removeAutoGenIds()`](https://github.com/rmsharp/nprcgenekeepr/reference/removeAutoGenIds.md)
  (×3), `modPedigree.R` display filter, and
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  founder counts all route detection through the single predicate —
  replacing all 7 detection literals + 2 generators.
  [`removeAutoGenIds()`](https://github.com/rmsharp/nprcgenekeepr/reference/removeAutoGenIds.md)’s
  standing “use a function call” TODO is resolved.
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  unchanged (its `addUIds(sb)` picks up the option via the default —
  smallest blast radius). Out-of-scope conventions (textual
  `"UNKNOWN"`/`unknown2NA`, `recordStatus`/`getRecordStatusIndex`)
  deliberately untouched.
- **Tests (TDD):** NEW `tests/testthat/test_autoIdFormat.R`
  (default/set/validation/predicate/prefix + a non-default-format
  `"AUTO%05d"` round-trip: configure→generate→detect→remove); NEW
  `tests/testthat/test_removeAutoGenIds.R` (none existed — default
  removal + case-sensitivity + non-default prefix);
  `test_obfuscateId.R:27-32` updated to the case-sensitive contract
  (lowercase `"u001"` is now a real ID, the **only** existing test that
  changed — `test_addUIds.R`/`test_qcStudbook.R`/`test_modPedigree.R`
  pass unchanged = back-compat proof). **Full suite: 0 failed, 0 error,
  159 skip** (985 results); the 5 warnings are pre-existing
  `test_modPyramid.R` baseline. Lint clean under `load_all` (the
  [`options()`](https://rdrr.io/r/base/options.html) setter carries
  `# nolint: undesirable_function_linter` per the project’s
  `getPyramidPlot.R` precedent — a public permanent setter, not a scoped
  change).
- **Docs/exports:** `devtools::document()` → `man/getAutoIdFormat.Rd` +
  `man/setAutoIdFormat.Rd` + NAMESPACE exports;
  `man/addUIds.Rd`/`man/removeAutoGenIds.Rd` regenerated. **NEWS.md**
  NEW-48 (user-facing). `modPedigree.R:112` tooltip notes the format is
  configurable.

### 2026-06-13 — Consolidate the ID cluster into umbrella \#44 (Session 70)

- **Deliverable:** Consolidated the three overlapping
  auto-generated-unknown-ID issues — **\#26**, **\#32**, **\#38** — into
  one umbrella design issue **\#44** (*“Configurable auto-generated
  unknown-ID format (default `"U%04d"`) — single source of truth for
  generation + detection”*). Executes S69 SUGGESTED-NEXT candidate (1).
  Per owner decisions (via `AskUserQuestion`): configurability =
  **prefix + number format**, default `"U%04d"`; scope = the
  `"U"`-prefix convention only; **\#26 + \#32 closed** as duplicates of
  \#44, **\#38 kept open** and linked as the concrete generation
  sub-task. Open issues **18 → 17** (−2 closed, +1 umbrella created).
- **TDD phase = N/A** (grooming/design; no production code or tests —
  same classification as S57/S61–S67/S69).
- **Firsthand subsystem map (Workflow under ultracode):** 4 parallel
  facet readers (generation / detection / callers-config / tests) + an
  adversarial completeness critic. The critic overturned the mappers on
  two material points: the package has **three** independent
  unknown/auto-gen conventions (textual `"UNKNOWN"` in `unknown2NA`; the
  `"U%04d"` prefix with **two** producers — `addUIds.R:47,54` +
  `obfuscateId.R:38-43` — and **7** case-divergent detection sites with
  no centralized predicate; and `recordStatus="added"` in `addParents.R`
  with the already-centralized `getRecordStatusIndex()`), coupled only
  by ordering in `qcStudbook.R:188→198→199`.
- **Verify-before-publish:** re-read the 8 load-bearing files firsthand
  (`addUIds`, `removeAutoGenIds`, `addParents`, `getRecordStatusIndex`,
  `obfuscateId`, `unknown2NA`, the `qcStudbook` ordering, the
  `modPedigree.R:112` tooltip) before creating \#44 / closing \#26/#32 —
  did not publish subagent findings unverified.
- **\#44** captures the verified current-state map, a
  single-source-of-truth design
  ([`getAutoIdFormat()`](https://github.com/rmsharp/nprcgenekeepr/reference/getAutoIdFormat.md)/[`setAutoIdFormat()`](https://github.com/rmsharp/nprcgenekeepr/reference/setAutoIdFormat.md)
  per \#38 + an internal `isGeneratedUnknownId()` predicate replacing
  the 8 literals), acceptance criteria (incl. byte-identical back-compat
  with no config, and a non-default-format round-trip test), the tests
  that bake in `"U"`, and an explicit **out-of-scope** section for the
  textual-`"UNKNOWN"` and `recordStatus` conventions.
- **Issue tracker:** **17 open** (was 18). \#26/#32 `state=CLOSED`
  (verified); \#38 OPEN with link comment; \#44 OPEN, label
  `enhancement`.

### 2026-06-13 — Close \#35: descendants in pedigree filtering (Session 69)

- **Deliverable:** Closed GitHub issue \#35 (*“Include descendants in
  pedigree filtering (ancestors already implemented)”*) as completed —
  the feature shipped in S68 (`d4320643`) and the owner confirmed the
  close this session. Open issues **19 → 18**. Completes the \#35
  lifecycle: S67 re-scope → S68 implement → S69 close (one deliverable
  per session).
- **TDD phase = N/A** (administrative issue-close; no production code or
  tests — same classification as S57/S61–S67).
- **Firsthand verification before the irreversible close** (per the
  standing “don’t close an OPEN issue without firsthand evidence” rule):
  ran the three covering test files — `test_getDescendantPedigree.R`,
  `test_modPedigree_processing.R`, `test_modPedigree.R` — **all pass**;
  read the implementation (`R/getDescendantPedigree.R`, the union at
  `R/modPedigree.R:299-305`, the help text at `:124-126`) and confirmed
  it satisfies **each** of the issue’s re-scoped asks: descendant set
  unioned with the existing ancestor set; **Option A** strict-lineal (no
  collaterals); UI label aligned from “only relatives” to “ancestors and
  descendants”.
- **Close comment** posted with a commit pointer (`d4320643`) mapping
  the shipped code to the issue’s acceptance criteria;
  `gh issue close --reason completed`.
- **Issue tracker:** **18 open** (was 19).

### 2026-06-13 — Implement \#35: descendants in pedigree filtering (Session 68)

- **Deliverable:** Implemented GitHub issue \#35 (*“Include descendants
  in pedigree filtering (ancestors already implemented)”*) via strict
  TDD (RED→GREEN→REFACTOR-skipped). The Pedigree Browser’s “Trim
  pedigree based on focal animals” option now includes both the
  **ancestors and descendants** of the focal animals (previously
  ancestors only). Owner chose **Option A — strict lineal** (no
  collateral relatives). Executes S67 SUGGESTED-NEXT \#1.
- **TDD:** first real code session after S57–S67’s non-code run. Three
  phase gates posed via `AskUserQuestion` (PRE-RED→RED, RED→GREEN,
  GREEN→REFACTOR) plus a separate pre-RED Option A/B approach decision.
  **0 stakeholder corrections.**
- **New/changed code:** `R/getDescendantPedigree.R` — new exported
  transitive-offspring closure, the downward mirror of
  [`getProbandPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getProbandPedigree.md).
  `R/modPedigree.R:292-307` — trim block now unions the ancestor closure
  (`trimPedigree`) with the descendant closure:
  `ped[ped$id %in% union(ancestors$id, descendants$id), ]`. UI help text
  (`:125`) and module docstring (`:166`) updated from the “only
  relatives” over-promise to “ancestors and descendants”.
- **Tests (TDD):** NEW `tests/testthat/test_getDescendantPedigree.R` (6
  unit tests on `lacy1989Ped`: transitive offspring, leaf,
  multi-proband, empty, absent, circular-terminates); 2 integration
  tests added to `test_modPedigree_processing.R` (descendants included;
  strict-lineal excludes sibling + mate). One stale pre-existing test in
  `test_modPedigree.R` updated to the new contract — surfaced by the
  full-suite clean-regression read (Learning 68). **Full suite: 972
  tests, 0 failed, 0 error, 159 skip.**
- **Docs/exports:** `devtools::document()` →
  `man/getDescendantPedigree.Rd` + NAMESPACE export;
  `man/modPedigreeServer.Rd` regenerated. **NEWS.md** NEW-47 entry
  (user-facing). Lint clean (lone `object_usage_linter` warning proven
  an install-staleness artifact). Phase 3E:
  `shiny::testServer(modPedigreeServer, …)` integration tests exercise
  the changed reactive.
- **Issue tracker:** \#35 implemented — to be closed (19 → 18 open) once
  the owner confirms.

### 2026-06-13 — Re-scope \#35 to descendants (ancestor-inclusion verified done) (Session 67)

- **Deliverable:** Re-scoped GitHub issue \#35 (was *“Include ancestors
  and descendants in pedigree filtering”*) to **“Include descendants in
  pedigree filtering (ancestors already implemented)”** and kept it
  **open**. Firsthand-verified that ancestor-inclusion is live and
  descendants are not, rewrote the body to current reality, corrected
  two stale references, documented two implementation options, and
  posted a dated verification comment (`#issuecomment-4699260833`).
  Executes S66 SUGGESTED-NEXT \#1.
- **TDD phase = N/A** (issue-grooming; no production code or tests —
  same classification as S57/S61–S66).
- **What’s verified (firsthand):** Ancestors **DONE** —
  `R/modPedigree.R:292-302`: when the “Trim pedigree” checkbox is on it
  calls `trimPedigree(probands, ped, …)` →
  [`getProbandPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getProbandPedigree.md)
  (`R/getProbandPedigree.R:24-40`), an upward `sire`/`dam` closure
  (ancestors only; the module docstring at `:166` already says
  “ancestors”). Descendants **NOT** implemented — neither function walks
  downward.
- **Two stale references corrected in the body:** (1) the issue’s cited
  “Current Code” (lines 246-253, a
  `# TODO: Include ancestors and descendants` placeholder) no longer
  exists — replaced by the ancestor logic at 292-302; (2) its “Suggested
  Implementation” called
  `trimPedigree(…, ancestors = TRUE, descendants = TRUE)` — a signature
  that **does not exist**
  (`trimPedigree(probands, ped, removeUninformative, addBackParents)`).
- **Implementation options documented (owner chose “document
  both”):** (A) strict lineal — add a downward closure mirroring
  `getProbandPedigree`’s loop (repeated
  [`getOffspring()`](https://github.com/rmsharp/nprcgenekeepr/reference/getOffspring.md)
  to closure) and union with the ancestor set; (B) reuse
  [`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)
  (`R/getPedDirectRelatives.R:46-59`), which already loops
  parents+offspring to closure but also pulls in collateral relatives
  (sibs/cousins/mates), broadening beyond lineal. Left for the
  implementation session.
- **Form (owner-chosen via `AskUserQuestion`):** rewrite the body +
  retitle + dated verification comment; issue kept open.
- **Issue tracker:** 19 open issues (unchanged — \#35 updated, not
  closed).

### 2026-06-13 — Merge methodology PR \#25/#27 wording branch into add-methodology (Session 66)

- **Deliverable:** Merged the local out-of-band branch
  `chore/methodology-pr2527-wording` (one wording-only commit
  `ce7d6779`) into `add-methodology`, then deleted it. Adopts the
  merged-upstream methodology PR \#25/#27 wording — **no migration**
  (this repo’s learnings extraction was done in Sessions 10/28; it is
  the reference end-state).
- **TDD phase = N/A** (docs/methodology merge; no `R/`, `tests/`,
  `man/`, or `NEWS.md` changes — same non-code classification as
  S57/S61–S65).
- **What landed (4 files, +10/−5):** SESSION_RUNNER.md §3C body → the
  canonical adopter-vs-canonical learnings-routing text + the
  Learnings-table caption reworded (3C section now byte-identical to
  canonical; the 6 seed rows already matched);
  `docs/methodology/HOW_TO_USE.md` 3C bullet → matching routing text;
  CLAUDE.md + PROJECT_LEARNINGS.md → replace the empirical “40k-char
  limit” justification with the documented size-budget language (“Claude
  Code targets ~200 lines / ~25 KB”); counts and history preserved.
- **Merge mechanics:** true merge commit `0f9728e3` (`--no-ff`; the base
  had diverged — Sessions 63–65 added commits after the branch point
  `b7f45901`). Pre-merge `git merge-tree` dry run showed **0** conflict
  markers; 3 of 4 files were byte-identical to the branch base, and
  PROJECT_LEARNINGS.md auto-merged **keep-both** (branch’s line-3 header
  rewording + the S63/64/65 tail-appended Learning rows —
  non-overlapping hunks).
- **Verified:** all 4 task-spec greps pass — “Adopter project” in
  SESSION_RUNNER.md (3C body + table caption), no “40k” in
  CLAUDE.md/PROJECT_LEARNINGS.md, one “200 lines” in each, and the
  HOW_TO_USE.md 3C routing bullet. Branch deleted with safe
  `git branch -d` (confirmed merged).
- **Build impact:** none — all 4 files are build-ignored
  (`.Rbuildignore` patterns `^CLAUDE.*\.md$`,
  `^PROJECT_LEARNINGS.*\.md$`, `^SESSION_RUNNER.*\.md$`, `^docs$`),
  verified firsthand; `R CMD check` unaffected.
- **Issue tracker:** 19 open issues (unchanged — no issue activity this
  session).

### 2026-06-12 — Update \#37 (exported-functions-unused inventory: 45 of 70 now used) (Session 65)

- **Deliverable:** Updated GitHub issue \#37 (“Exported functions not
  currently used by app”) to current reality and **kept it open**.
  Struck the **45 of 70** listed functions now reached by the app, kept
  the 22 still-unused + 3 S3 methods, corrected the totals (**116 / 155
  used, 39 unused**; was 38 / 108 / 70), fixed the 5 “Notable findings”,
  added a dated re-verification note, and folded in the **17 unused
  exports created since** the issue was filed (2026-01-25). Executes S64
  SUGGESTED-NEXT \#1.
- **TDD phase = N/A** (issue-grooming; no production code or tests
  written — same classification as S57/S61/S62/S63/S64).
- **Method (firsthand, reproducible):** app reachability by call-graph
  closure —
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html),
  seed at `{runModularApp, runGeneKeepR, appUI, appServer}`, transitive
  closure of
  [`codetools::findGlobals`](https://rdrr.io/pkg/codetools/man/findGlobals.html)
  over package functions; exported names outside the closure are
  “unused.” Concrete call paths were produced for the flipped set
  (e.g. `rankSubjects` via
  `appServer → modGeneticValueServer → reportGV → orderReport`; the 4
  Shiny modules called directly by `appServer`; the genotype trio via
  `modInputServer`; `filterKinMatrix/Report/Threshold` via the
  breeding-group + GV modules).
- **Adversarial check of the static method’s blind spots:** the only
  string-dispatched call in `R/` is `do.call("rbind", …)`, and none of
  the 22 still-unused names appear as string literals → no
  dynamic-dispatch invocation the closure missed; the S3 methods aren’t
  dispatched on the app path (the app’s
  [`summary()`](https://rdrr.io/r/base/summary.html) calls hit
  `summary.default` on numeric vectors).
- **Re-grade vs the handoff:** S64 (inheriting the S62 audit) framed
  \#37 as “strike the resolved Shiny-module + genotype rows; keep the
  still-accurate inventory” — implying ≈7 functions flipped and the bulk
  held. Firsthand recomputation found **45/70 flipped** — ~64% stale,
  not 2 clusters. Same classifier-stops-at-the-headline calibration miss
  documented for S62→#14 and S63→#8.
- **Applied form (owner-chosen via `AskUserQuestion`):**
  strikethrough-in-place + dated verification note in the body
  (`gh issue edit 37 --body-file`), plus the 17 newer unused exports; a
  timeline pointer comment (`#issuecomment-4696756359`) makes the
  correction visible to watchers. Issue kept **open** — the 39
  genuinely-unused exports remain the actionable surface (largest
  clusters: the simulated-kinship subsystem and the ORIP reporting
  module).
- **Issue tracker:** 19 open issues (unchanged — \#37 updated, not
  closed).

### 2026-06-12 — Verify + close \#8 (non-founder no-parents handling — caveated close) (Session 64)

- **Deliverable:** Closed GitHub issue \#8 (“Improve handling of
  non-founder animals without either parents assigned”) as
  **implemented**, with a strengthened-caveat resolution comment.
  Executes S63 SUGGESTED-NEXT \#1 (the other STALE candidate from the
  S62 audit) — but firsthand verification + a reproduction re-graded it
  from the audit’s footnote-caveat to a **strengthened caveat with a
  reproduced silent-failure case**.
- **TDD phase = N/A** (verify-and-close; no production code or tests
  written — same classification as S57/S61/S63).
- **What’s implemented (verified firsthand):** both of the issue’s
  proposed solutions are live in the GVA report-ordering path. Solution
  1 (origin/“From Center” segregation) — ONPRC-born founders with no
  offspring are split into a `noParentage` bucket
  (`R/orderReport.R:31,44-54`). Solution 2 (don’t rank them) — those
  animals get `value = "Undetermined"`, `rank = NA`
  (`R/rankSubjects.R:38,44`). Live wiring:
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  → `orderReport(finalData, ped)` (`R/reportGV.R:146`). Tests green
  against source via
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html):
  `test_orderReport.R` 8/0/0/0, `test_rankSubjects.R` 5/0/0/0.
- **The caveats (firsthand, beyond the audit’s note):** (1) **The fix is
  gated on the optional `origin` column and silently does nothing
  without it.** The whole `noParentage` block is wrapped in
  `if ("origin" %in% names(rpt))` (`R/orderReport.R:31`); `origin`
  reaches the report only when the source pedigree carries it
  (`R/reportGV.R:119` `intersect(getIncludeColumns(), names(ped))`) and
  is documented optional. **Reproduced:** a no-parent founder with no
  offspring → `value = "High Value", rank = 1` (the original bug)
  without `origin`, vs `"Undetermined"/NA` with it — no warning when the
  safeguard doesn’t apply. (2) **No regression test pins the
  `Undetermined`/`rank = NA` branch** — `test_orderReport` exercises the
  path but asserts only positional unknown-ID counts;
  `test_rankSubjects` never exercises `noParentage`. (3) **The 2021
  simulated-kinship subsystem is orphaned** — `getPotentialParents`,
  `createSimKinships`, `kinshipMatricesToKValues`,
  `summarizeKinshipValues`, `countKinshipValues`,
  `addKinshipValueCount`, `cumulateSimKinships` are exported but have no
  live caller in `R/` (present only in tests,
  `inst/extdata/trulyUnknownParents.R`,
  `vignettes/simulatedKValues.Rmd`); the issue’s “discuss with Matt”
  design item is unresolved. These remaining items are recorded in the
  close comment as candidate enhancements but **not filed** (new-issue
  creation outside the approved “close with caveat” scope — S63 lesson).
- **Method (right-sized under ultracode):** firsthand source read + a
  direct **reproduction** of the origin-gating failure + `load_all` test
  runs + a 3-lens adversarial refute-the-close workflow
  (`wf_f37f1b72-b6a`). The gate split 1 hold-open / 2 close-with-caveat;
  the hold-open verdict (origin-gating makes the fix illusory in the
  common case) was reconciled firsthand via the reproduction, which
  upgraded the caveat and was surfaced to the owner via
  `AskUserQuestion` before the irreversible close.
- **Issue tracker:** 19 open issues remain (was 20).

### 2026-06-12 — Verify + close \#14 (genotype provide+track — caveated close) (Session 63)

- **Deliverable:** Closed GitHub issue \#14 (“Add ability to provide
  genotypes for animals within the pedigree and track them”) as
  **implemented**, with a caveat resolution comment. Executes S62 audit
  recommendation \#1 — but firsthand verification re-graded it from the
  audit’s “clean” classification to **close-with-caveat**.
- **TDD phase = N/A** (verify-and-close; no production code or tests
  written — same classification as S57/S61).
- **Verified firsthand:** the genotype provide+track ability is
  live-wired and test-pinned.
  `getGenotypes`/`checkGenotypeFile`/`addGenotype` read + integer-code +
  merge in the modular app’s separate-genotype-file mode
  (`R/modInput.R:384-396`); the integer `first`/`second` columns ride
  the cleaned studbook into
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  → `getGVGenotype` (`R/reportGV.R:78`) → `geneDrop(genotype=…)` (`:92`)
  → `calcGU`/`calcFG`; the functions are exported for scripting; **278
  genotype-path assertions pass (0 fail / 0 err / 0 skip)**, including
  the end-to-end `modInputServer` separate-file test
  (`tests/testthat/test_modInput_qcStudbook.R:536-545`). Live entry
  point:
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  → `shinyApp(appUI(), appServer)` → `modInputUI/Server("dataInput")`.
- **The caveat (deliberate, owner-authored):** the combined-file UI mode
  (`commonPedGenoFile`) does **not** integer-code string alleles, so
  genotypes supplied in a single combined file don’t reach gene-drop —
  at parity with the legacy monolith (per commit `c9019d51`’s own
  rationale). Documented in the close comment; extending tracking to the
  combined-file mode is noted there as a candidate future enhancement
  (not filed — new-issue creation was outside the approved scope).
- **Method (right-sized under ultracode):** firsthand source read +
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)
  test run + a 3-lens adversarial refute-the-close workflow
  (`wf_9d00a37a-6d0`). The refute pass earned its keep: the
  intent-completeness lens surfaced the combined-file caveat that
  re-graded the close, and a test-authenticity “tests are failing”
  refutation was correctly traced to a **stale installed binary** (the
  source tests pass green) rather than a real regression.
- **Issue tracker:** 20 open issues remain (was 21).

### 2026-06-12 — Backlog-staleness audit of all 21 open GitHub issues (Session 62)

- **Deliverable:** `docs/audits/BACKLOG_STALENESS_AUDIT_2026-06-12.md` —
  a read-only audit classifying every open issue as **STALE** (already
  implemented), **PARTIAL**, or **OPEN** against the current code,
  motivated by S61’s finding that \#34 was resolved in code but stayed
  open. Generalizes that one-issue check to the whole tracker. **No
  code, tests, or issues changed** (closing is a recommended follow-up,
  not executed — 1-and-done).
- **TDD phase = N/A** (read-only audit; no production code or tests
  written — same classification as the S57/S61 non-code sessions).
- **Result:** **2 STALE / close candidates** (#14 genotype provide+track
  — clean close, \#34-grade; \#8 non-founder no-parents handling — close
  *with caveat*: both proposed solutions are live but gated on the
  optional `origin` column and lack a direct test assertion); **5
  PARTIAL** (#1, \#5, \#9, \#35, \#37 — keep open with narrowed scope;
  \#37 should be *updated*, not closed); **14 genuinely OPEN** (#2, \#4,
  \#10, \#11, \#12, \#13, \#26, \#28, \#29, \#31, \#32, \#33, \#36, \#38
  — cited TODOs still present verbatim or no implementation exists).
- **Method:** 24-agent classify→adversarial-verify workflow (one
  classifier per issue, searching by *content* not stale line numbers;
  every STALE call handed to an independent skeptic told to refute it).
  The adversarial pass **knocked down a false-STALE on \#1** — its
  `Clear Focal Animals` checkbox clears the IDs reactive but not the
  file-browser input, exactly as the owner’s own 2020 GitHub comment
  notes — and downgraded \#8 to a caveated close. All close-relevant
  calls (#14, \#8, \#1) were re-verified firsthand by the session
  against source + `gh api`.
- **Structural findings:** the issue tracker lags the code only in the
  resolved→still-open direction (no false “open”); the auto-generated-ID
  cluster (#38/#32/#26 + dam-ID \#31) is one feature split across four
  issues — recommend consolidating; the old external-system requests
  (#10/#11/#12/#13/#28) are correctly open and large. Report placed
  under `docs/audits/` (build-ignored via `^docs$`) so it does not
  regress S60’s top-level-files-NOTE elimination.

### 2026-06-12 — Verify and close issue \#34 (`qcStudbook` already integrated in `modInput`) (Session 61)

- **Closed issue \#34** (“Integrate qcStudbook() in modInput Shiny
  module”, bug/high). The placeholder QC logic the issue describes
  (`# TODO: Replace with actual qcStudbook() call` +
  `results$cleaned <- rawData`) was already replaced by a real
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)/[`runQcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/runQcStudbook.md)
  integration during the Shiny-module conversion (commit `7da01afe`,
  extended `c9019d51`/`bb7f2be6`); CHANGELOG’s Session-20 entry already
  noted \#34 as “stale (already integrated)” but the GitHub issue was
  never formally closed. This session verified the resolution firsthand
  and closed it with a resolution comment. **No code changed.**
- **TDD phase = N/A** (verify-and-close; no production code or tests
  written — same classification as the S57 close of \#30).
- **What’s wired:** `R/modInput.R:408` calls
  `qcStudbook(rawData, minParentAge, reportChanges=TRUE, reportErrors=TRUE)`;
  `:423` calls the two-pass wrapper
  [`runQcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/runQcStudbook.md)
  (`R/runQcStudbook.R`); `R/processQcStudbookResult.R` shapes results
  for the UI; `minParentAge` is read from the UI input with safe
  coercion (`:398-404`); live path confirmed `appUI.R:123`
  (`modInputUI("dataInput")`) → `appServer.R:104` (`modInputServer`).
- **Verification (firsthand):** `test_qcStudbook.R` 38/0/0/0 +
  `test_modInput_qcStudbook.R` 90/0/0/0 (pass/fail/err/skip). The
  [`shiny::testServer`](https://rdrr.io/pkg/shiny/man/testServer.html)
  module tests ran (**0 skips**; `shiny` installed), driving
  `modInputServer` and asserting the cleaned studbook carries the `gen`
  column that only
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  adds (`test_modInput_qcStudbook.R:296`) — that assertion would FAIL if
  the module were reverted to the placeholder, so the integration is
  regression-pinned. A 3-lens adversarial refute-the-close workflow
  (residual-placeholder/live-path ‖ functional-completeness ‖
  test-authenticity) returned refuted=false / high confidence / 0 gaps
  on all three lenses.

### 2026-06-12 — `.Rbuildignore` excludes all non-shipping top-level dev/audit files — “non-standard top-level files” NOTE eliminated (Session 60)

- **Deliverable:** added `.Rbuildignore` patterns for the 8
  currently-shipping non-standard top-level files so they are dropped
  from the build tarball, **eliminating** the R CMD check “non-standard
  files/directories found at top level” NOTE entirely — the built
  tarball’s top level is now only the 5 standard files (`DESCRIPTION`,
  `NAMESPACE`, `NEWS.md`, `README.md`, `LICENSE`). Excluded:
  `20250504_cran-comments.md` (the 8th dated cran-comments file — its 7
  siblings were already individually ignored),
  `methodology_dashboard.py`, `dashboard.html`,
  `nprcgenekeepr_notes.txt`, `RECOMMENDED_SKILLS.md`,
  `PED_GV_AUDIT_2026-05-30.{md,html}`, `TECH_DEBT_AUDIT_2026-05-30.md`.
  This is the deferred “scope-B” follow-up S58/S59 surfaced (a
  tarball-contents change, distinct from the pure dupe-guards of
  S58/S59).
- **Owner decisions (`AskUserQuestion`):** (1) scope = exclude **all 8**
  (none are package content) → eliminate the NOTE; (2) style = broad
  dupe-guarded + consolidate — the 7 dated
  `^YYYYMMDD_cran-comments\.md$` exact lines replaced by one
  `^[0-9]+_cran-comments\.md$` regex (covers 20250504 + any future dated
  file, so a new one never silently ships again), and the synced
  methodology/audit files use `<NAME>.*` forms
  (`^RECOMMENDED_SKILLS.*\.md$`, `^PED_GV_AUDIT.*`,
  `^TECH_DEBT_AUDIT.*`) that also catch macOS sync dupes; the non-synced
  files (`methodology_dashboard.py`, `dashboard.html`,
  `nprcgenekeepr_notes.txt`) use tight exact-match.
- **TDD phase = N/A** (build-config only; `.Rbuildignore` is dropped
  from the built tarball → no shippable `testthat` assertion; same
  rationale as S58/S59).
- **Verification (firsthand, authoritative at the build level):** staged
  3 real spaced dupes (`RECOMMENDED_SKILLS 2.md`,
  `PED_GV_AUDIT_2026-05-30 2.md`, `TECH_DEBT_AUDIT_2026-05-30 2.md`),
  ran `R CMD build --no-build-vignettes --no-manual .` (RC=0 → no
  regex-comment abort); the resulting tarball’s top level contained
  **exactly** the 5 standard files — none of the 8 excluded files and
  none of the 3 staged dupes (685 files, down from the 693-file baseline
  = the 8 removed). The “non-standard top-level files” NOTE is a pure
  function of the tarball’s top-level entries, so this directly confirms
  the NOTE is gone (full `devtools::check()` not re-run — nothing
  affecting tests/examples/metadata changed; consistent with S58/S59).
  The complete 8-file set was enumerated by building the baseline
  tarball first (S59’s candidate list named only 4 of the 8). Temp
  dupes + tarballs removed via `trap cleanup`; tree clean.

### 2026-06-12 — `.Rbuildignore` macOS-dupe guard generalized to the whole methodology `.md` cluster (Session 59)

- **Deliverable:** generalized Session 58’s SESSION_NOTES dupe-guard to
  the rest of the top-level methodology/doc `.md` files. Broadened 7
  exact-match `.Rbuildignore` patterns to the `<NAME>.*\.md$` form —
  `PROJECT_LEARNINGS`, `CLAUDE`, `SESSION_RUNNER`, `SAFEGUARDS`,
  `BACKLOG`, `ROADMAP`, `CHANGELOG` (`.Rbuildignore:78-85`) — so macOS
  file-sync duplicates (`CLAUDE 2.md`, `CHANGELOG copy.md`, …) of any of
  them are build-ignored and can never re-raise the R CMD check
  “non-portable file names” WARNING. After S58 only `SESSION_NOTES` was
  `.*`-guarded; this kills the dupe-WARNING class for the whole
  methodology cluster. (Owner decisions via `AskUserQuestion`: loose
  `.*` style to match the S58 line; scope limited to the already-ignored
  cluster — adding currently-unignored docs such as
  `RECOMMENDED_SKILLS.md` deferred as a separate tarball-contents
  change.)
- **TDD phase = N/A** (build-config only; same rationale as S58 —
  `.Rbuildignore` is dropped from the built tarball, so there is no
  shippable `testthat` assertion).
- **Verification (firsthand, both levels):** (1) regex probe across all
  7 names — OLD exact patterns miss every dupe form (the leak); NEW `.*`
  form matches `<NAME> 2.md` and `<NAME> copy.md` while NOT
  over-matching `<NAME>.Rmd` / `<NAME>_archive.txt`, and canonical names
  stay excluded. (2) build-equivalent (authoritative) — staged 14 real
  spaced dupes (both forms × 7 names), ran
  `R CMD build --no-build-vignettes --no-manual` (RC=0); the resulting
  tarball (693 files) contained **zero** of the 7 names as `.md` → all
  dupes + canonicals excluded, real content (DESCRIPTION/NAMESPACE)
  present. Temp files + tarball removed via `trap cleanup`; tree clean.
- **In-flight finding (caught by the build step, not shipped):**
  `.Rbuildignore` lines are *all* perl regexes — including `#` comment
  lines (they simply match no real path). An initial multi-line comment
  with an unbalanced `(` made `R CMD build` abort with
  `invalid regular expression`; fixed to regex-safe comment lines, plus
  an inline NOTE warning future editors. (See PROJECT_LEARNINGS Learning
  59.)

### 2026-06-12 — `.Rbuildignore` permanent macOS-dupe fix (Session 58)

- **Deliverable:** broadened `.Rbuildignore`’s `^SESSION_NOTES\.md$` →
  `^SESSION_NOTES.*\.md$` so macOS file-sync duplicates
  (`SESSION_NOTES 2.md`, `SESSION_NOTES 3.md`, `SESSION_NOTES copy.md`,
  …) are build-ignored and can never again re-enter the build tarball to
  re-raise the R CMD check “non-portable file names” WARNING that
  Session 57 had to clear by hand. This is the permanent fix S57
  deferred (root cause: an exact-match build-ignore pattern doesn’t
  cover the space-name); the prior `^\.Rhistory\ 2$` entry shows the
  same class was patched narrowly once before.
- **TDD phase = N/A** (build-config only; no R code, no shippable unit
  test — `.Rbuildignore` is dropped from the built tarball, so a
  `testthat` assertion on it can’t run under R CMD check).
- **Verification (firsthand):** (1) regex probe — OLD pattern matches
  `SESSION_NOTES.md` only; NEW matches all dupe variants and
  over-matches nothing (`CHANGELOG.md`, `SESSION_NOTES_archive.txt` stay
  excluded; canonical `SESSION_NOTES.md` still excluded). (2)
  build-equivalent — staged a real `SESSION_NOTES 2.md`, ran
  `R CMD build` (RC=0); the resulting tarball contained **zero**
  SESSION_NOTES entries → the dupe is excluded and the WARNING cannot
  fire. Temp file + tarball removed; tree clean. (Full
  `devtools::check()` intentionally skipped — the WARNING is a pure
  function of tarball contents, verified directly.)

### 2026-06-12 — Close issue \#30 + repo hygiene (Session 57)

- **Closed issue \#30** (“work on use of lintr until satisfied with code
  style”). The plan deliverable
  (`docs/planning/issue30-lintr-exclusion-cleanup-plan.md`) is complete:
  `lintr::lint_package()` = **0** (re-verified firsthand this session),
  every `R/`-file `.lintr` line-specific exclusion removed except the
  deliberately-kept `makeGeneticDiversityDashboard` (author
  won’t-delete, `.Rbuildignore`’d). The CI `lint` check is GREEN. Closed
  with a resolution comment summarizing Phases 1–4 (Sessions 53–56).
  Optional trivial follow-up noted on the issue: convert the lone
  remaining range-exclusion to an inline `# nolint start/end` block
  (plan §4C \#16).
- **Repo hygiene:** removed the untracked macOS-duplicate
  `SESSION_NOTES 2.md` (563 KB, never committed, content fully contained
  in `SESSION_NOTES.md`). Its space-in-filename was the sole cause of
  the `devtools::check()` “portable file names” **WARNING**
  (`.Rbuildignore`’s `^SESSION_NOTES\.md$` exact-match does not cover
  the space-name, so the dupe entered the build tarball). **Verified
  firsthand:** post-removal `devtools::check()` = **0 errors / 0
  warnings / 3 NOTEs** (was 1 WARNING at S56) → the WARNING is cleared.
  The 3 residual NOTEs are all pre-existing/environmental (clock-skew
  future-timestamps, spelling, and “non-standard top-level files” — the
  latter now lists only no-space methodology/audit files:
  `20250504_cran-comments.md`, `PED_GV_AUDIT_2026-05-30.{html,md}`,
  `RECOMMENDED_SKILLS.md`, `TECH_DEBT_AUDIT_2026-05-30.md`,
  `dashboard.html`, `methodology_dashboard.py`,
  `nprcgenekeepr_notes.txt`; the build-ignored `..Rcheck/` does not
  appear).

### 2026-06-12 — Issue \#30 Phase 4: behavior-sensitive lint refactors + de-exclude (Session 56)

- **Deliverable:** implemented Phase 4 (the final exclusion-cleanup
  phase) of the issue \#30 plan — the **6 behavior-sensitive `.lintr`
  line-exclusions** (5 §4B + the reclassified `checkRequiredCols`).
  After this, the **only** `R/`-file line exclusion left is
  `makeGeneticDiversityDashboard` (deliberately kept);
  `lintr::lint_package()` stays **0**.
- **`checkRequiredCols.R` (RED→GREEN→REFACTOR, commit `17e3fa06`):**
  `as.character(unlist(sapply(...)))` →
  `requiredCols[!requiredCols %in% cols]`. Owner-chosen robust contract:
  on out-of-contract `NA`-in-`cols` (reportErrors=TRUE) it now returns
  the missing cols cleanly instead of erroring
  (`"missing value where TRUE/FALSE needed"`); non-NA output
  byte-identical, `reportErrors=FALSE` untouched. Pinned by a RED
  NA-contract test; `@details` documents it.
- **4 behavior-none REFACTORs (commit `69c8d759`, all adversarially
  verified):** `correctParentSex.R` (if/else inverted to a guard clause;
  6000-iter fuzz identical incl. error messages);
  `fillGroupMembersWithSexRatio.R` (`else { if }` → `else if`, inline
  `# nolint` deleted; 146 seeded cases identical); `setExit.R` (`mapply`
  → `unlist(Map(...))`, `chooseDate` always length-1; 21 inputs
  identical).
- **`addSexAndAgeToGroup.R` (adopted-robust REFACTOR, commit
  `69c8d759`):** `sapply` → `ped$sex[match(ids, ped$id)]`. Adversarial
  verification found that on **empty `ids`** the old `sapply` form
  dropped the `sex` column (2-col result), which **crashed** the one
  caller (`modBreedingGroups.R:438` `colnames(gp) <- c(<3 names>)`) on
  an empty group; the [`match()`](https://rdrr.io/r/base/match.html)
  form returns the documented 3-column schema (sex an empty factor) and
  renders an empty table. Owner adopted the new behavior as intentional;
  pinned by an empty-ids contract test + a happy-path characterization
  test; `@details` documents it.
- **`create_wkbk.R` (accepted-divergence REFACTOR, commit `69c8d759`):**
  inner `if (replace)` → guard clause `if (!replace)`. Owner-accepted
  cosmetic divergence: on a non-logical non-coercible `replace` while
  the file exists, both versions error but the message text differs
  (`"argument is not interpretable as logical"` →
  `"invalid argument type"`); `replace` is documented logical, coercible
  values identical.
- **Verification:** `lint_package()` = 0; the 6 files lint-clean
  (`parse_settings=FALSE`); full suite **0 fail / 0 err / 159 skip**
  (S49 baseline + 5 new passing expectations from the
  contract/characterization tests → zero regression);
  `devtools::check()` **0 errors** (1 pre-existing-environmental
  WARNING + 2 NOTEs from stray top-level files incl. the macOS
  `SESSION_NOTES 2.md` dupe — not from this change); adversarial
  behavior-verification workflow `wf_168f8dcf-1e5` (6 skeptics, each
  told to refute). Phase-3E: `addSexAndAgeToGroup`’s runtime integration
  is covered by `test_modBreedingGroups.R:1015-1122` (the
  breeding-groups member view), green in the full suite.

### 2026-06-11 — Issue \#30 Phase 3: behavior-none lint refactors + `.lintr` casing fix (Session 55)

- **Deliverable:** implemented Phase 3 of the issue \#30 plan — **6
  behavior-none lint refactors**, each removing its `.lintr`
  line-exclusion in the same change (\[lint-net-zero\]).
  `lintr::lint_package()` stays **0**.
- **Refactors (all adversarially verified behavior-preserving):**
  `convertFromCenter.R` + `fillGroupMembers.R` + `hasGenotype.R`
  (`unnecessary_nesting` collapses — drop an `else` after an
  unconditional
  [`stop()`](https://rdrr.io/r/base/stop.html)/[`return()`](https://rdrr.io/r/base/function.html);
  `else { if }` → `else if`); `getLkDirectAncestors.R` +
  `getLkDirectRelatives.R` (rename local var `source` → `msgSource`,
  which `undesirable_function_linter` flagged as shadowing
  [`base::source`](https://rdrr.io/r/base/source.html); also dropped 2
  now-redundant inline nolints); `saveDataframesAsFiles.R`
  (`unnecessary_lambda` →
  `vapply(dfList, inherits, logical(1L), what = "data.frame")`).
- **`.lintr` casing bug fixed** (owner-flagged): `R/CheckRequiredCols.R`
  → `R/checkRequiredCols.R` — the capital-`C` entry matched nothing on
  case-sensitive CI, so the L34 lint would fire on the Linux `lint`
  runner.
- **`checkRequiredCols.R` (planned Phase 3 \#1) reclassified to Phase
  4:** adversarial verification + firsthand repro proved its
  `sapply`→`%in%` fix is NOT behavior-none — on out-of-contract
  `NA`-in-`cols` it turns a thrown error into a clean missing-columns
  return (exported fn). Owner-approved deferral (`AskUserQuestion`) to a
  RED→GREEN→REFACTOR slice in Phase 4; the file’s code + `.lintr` entry
  left as-is (casing now correct).
- **Verification:** `lint_package()` = 0; the 6 files lint-clean
  (`parse_settings=FALSE`); full suite **2140 pass / 0 fail / 0 err /
  159 skip** (= S49 baseline → zero regression); `devtools::check()` **0
  errors** (1 pre-existing-environmental WARNING + NOTE from stray
  top-level files incl. a macOS `SESSION_NOTES 2.md` dupe — not from
  this change); `man/` untouched.

### 2026-06-11 — Implement issue \#30: drive the R/ lint check to GREEN (Session 54)

- **Deliverable:** implemented the issue \#30 cleanup plan;
  `lintr::lint_package()` now reports **0 lints** in `R/` (was 193 = 41
  suppressed by `.lintr` line-excludes + 152 residual) → the CI `lint`
  check goes green.
- **Phase 1 (commit `74a46d4c`):** removed dead commented code in
  `getErrorTab.R`, `get_elapsed_time_str.R`,
  `print.summary.nprcgenekeeprErr.R`; stripped a stray `#'` in
  `set_seed.R` (also fixed a `#'` leak into `man/set_seed.Rd`); removed
  the 4 now-unneeded `.lintr` line exclusions + the dead
  `#commented_code_linter = NULL` no-op; kept
  `makeGeneticDiversityDashboard` (author won’t-delete, NEW-20).
- **Residual (this commit):** fixed the 154 firing lints across 17 `R/`
  files + `inst/shinytest/app.R` via a per-file
  editor→adversarial-verifier workflow (one editor + one verifier per
  file; 150+ fixes, all 18 files verified behavior-preserved). **Owner
  decisions (`AskUserQuestion`):** (1) keep `implicit_integer_linter` ON
  and fix all 74 with `L` (counts/indices/widths) or `.0` (reals,
  e.g. `ped$age * 12.0`) — NOT disable;
  2.  targeted inline `# nolint` for the 16 verified false-positives /
      justified idioms. Mechanical fixes: `line_length` wraps, `brace`,
      `keyword_quote`, `return`,
      `paste(collapse=)`→[`toString()`](https://rdrr.io/r/base/toString.html),
      `sapply`→`vapply`, `if`/`else if` chain →
      [`switch()`](https://rdrr.io/r/base/switch.html) in
      `logModuleEvent.R`; removed the stale `getPyramidPlot.R = 25:27`
      exclusion.
- **`# nolint` (verified non-bugs):** `object_usage` ×6
  (package-internal `calcFounderContributions`/`gatedSeed` lintr can’t
  resolve + `founderStats` which IS a `modSummaryStatsServer` formal),
  `nonportable_path` ×3 (MIME strings), `object_name` ×2 (base-R
  `launch.browser` arg),
  [`library()`](https://rdrr.io/r/base/library.html) ×2 (shinytest
  harness), [`par()`](https://rdrr.io/r/graphics/par.html) ×3 (CRAN
  save/restore idiom).
- **Verification (firsthand):** `lint_package()` = 0; full test suite
  **2140 pass / 0 fail / 0 err / 159 skip** (S49 baseline held exactly —
  zero behavior regression); `document()` regenerated 3 man pages
  (roxygen reflow, content identical); **Phase-3E** — booted the app
  from `load_all` source: all 7 module UI builders constructed and
  `runModularApp` served HTTP 200 / 92 KB.
- Issue \#30 remains OPEN pending owner confirmation to close (the
  `lint` check is now green).

### 2026-06-11 — Plan issue \#30: resolve the `.lintr` line-specific exclusions (Session 53)

- **Deliverable (planning):**
  `docs/planning/issue30-lintr-exclusion-cleanup-plan.md` — an
  evidence-based plan to remove most of the 18 `"file" = line` entries
  in `.lintr`’s `exclusions: list()` by fixing the underlying lint, plus
  a strategy for the 152 residual lints. **No `R/`, `tests/`, or
  `.lintr` content changed** (plan only; implementation is the
  subsequent sessions, one phase at a time — FM \#18/#25).
- **Evidence base:** firsthand `lint_package(parse_settings=FALSE)`
  (bypassing the exclusions so the suppressed lints are visible) = **41
  lints suppressed by the 18 line-excludes + 152 residual = 193 total in
  `R/`**; cross-checked by an 18-file parallel examination workflow
  (`wf_c7863094-8f1`, one agent per file proposing the exact fix + risk
  rating) with adversarial verification of every behavior-affecting fix
  and commented-code deletion. **Three agent conclusions were
  corrected** by verification/reproduction (see plan §6).
- **Dispositions:** FIX 15 entries (~38 lints; 10 behavior-none, 5
  low-risk verified-safe), KEEP-EXCLUDE 1
  (`makeGeneticDiversityDashboard.R` — author won’t-delete, NEW-20),
  REMOVE-STALE + fix real lints 1 (`getPyramidPlot.R = 25:27` suppressed
  0 lints).
- **Config bugs found:** (1) `.lintr` lists `"R/CheckRequiredCols.R"`
  (wrong case) → the exclusion misses on case-sensitive CI; (2) the
  `getPyramidPlot.R = 25:27` exclusion is dead config; (3) the `source`
  “undesirable function” hits are a local variable named `source`,
  fixable by rename (zero behavior change); (4) `commented_code_linter`
  IS active via the tag set — the `#commented_code_linter = NULL` line
  is a dead no-op (resolves the issue \#30 confusion).
- **Learning \#53** (parse_settings=FALSE auditing trap; line-number
  drift both ways; verify-first over agent headlines). \#30 stays OPEN
  (planning deliverable; implementation pending).

### 2026-06-11 — Fix issue \#42: repoint pkgdown output off `docs/`; fix unmasked vignette bug; pkgdown GREEN on master (Session 52)

- **Deliverable (CI config + vignette fix / run-and-observe):** the
  `pkgdown` workflow failed its Build-site step on a fresh CI clone
  because `docs/methodology/` + `docs/planning/` are git-tracked inside
  pkgdown’s default `docs/` output dir (no `pkgdown.yml` sentinel →
  `clean_site()` refuses to wipe a dir it didn’t build → exit 1).
- **Fix = Option 2 (repoint pkgdown), not the issue’s recommended Option
  1 (relocate the doc trees).** Surfaced the choice via
  `AskUserQuestion`: Option 1 conflicts with the methodology framework’s
  own `docs/methodology/` convention — the synced
  `methodology_dashboard.py` scores that path and the synced
  `SESSION_RUNNER.md`/ `SAFEGUARDS.md` cross-link it (none durably
  editable in-repo). Verified from pkgdown 2.1.1 source + empirically
  that `build_site_github_pages()` overrides `_pkgdown.yml`’s
  `destination:` via `override = list(destination = dest_dir)`, so the
  yml alone is insufficient for CI. Commit `fcc154e8`: workflow
  `dest_dir = "pkgdown_site"` + deploy `folder: docs → pkgdown_site`;
  `_pkgdown.yml destination: pkgdown_site`;
  `.gitignore += pkgdown_site/`; `.Rbuildignore += ^pkgdown_site$`. No
  file moves; `docs/methodology`/`docs/planning`/dashboard/synced
  cross-refs untouched; gh-pages URL unchanged; no `R/` or `tests/`
  change.
- **Unmasked + fixed a separate latent bug** (commit `e89975c8`): with
  `clean_site` resolved, the build reached vignette rendering and failed
  on `ColonyManagerTutorial.Rmd` — its error table paired
  `names(getEmptyErrorLst())` (10 types) with 9 hardcoded descriptions
  (“arguments imply differing number of rows: 10, 9”). The NEW-45 “no
  period in IDs” feature added the `invalidIdChars` type without
  updating the vignette; added the missing description. This vignette is
  `.Rbuildignore`’d, so R CMD check never builds it — only pkgdown does
  (it ignores `.Rbuildignore`) — which is why it was green on all 5
  R-CMD-check platforms yet fatal to pkgdown.
- **Validation (firsthand):** PR \#43 pkgdown run `27361729368`
  (fresh-clone) SUCCESS → merged `--merge` to master `c6ad23dd` → master
  push run `27362288625` Build site **SUCCESS** + Deploy **SUCCESS**.
  **Closed issue \#42.** Remaining CI red is lint (#30, known/accepted).

### 2026-06-11 — Promote `add-methodology` → master (PR \#41) and live-validate `shinytest2`; close issue \#40 (Session 51)

- **Deliverable (integration / run-and-observe):** promoted the
  long-lived `add-methodology` branch (105 commits / 356 files /
  +44,473−2,892; master a strict ancestor → 0 behind → clean
  conflict-free merge) to **master via PR \#41** (merge commit
  `0363ffe3`, `--merge` to preserve the multi-session TDD history —
  never squashed). Pre-flight build-equivalent gate (non-e2e
  clean-regression read) = **2140 pass / 0 fail / 0 err / 0 non-e2e
  offenders** (S49 baseline held); no branch protection on master.
- **Held the merge for the PR’s first-ever remote CI**, triaging each
  red to root cause: **R-CMD-check passed on all 5 platforms** (macOS,
  Windows, ubuntu release/devel/oldrel-1) + test-coverage passed →
  package correctness intact; **pkgdown FAIL** = real but
  doc-site-deploy-only (`docs/methodology`+`docs/planning` tracked
  inside pkgdown’s `docs/` output dir → `clean_site()` refuses to clean
  a non-pkgdown `docs/`) → logged as **issue \#42**; **lint FAIL** =
  known style debt (#30); **codecov/patch+project FAIL** =
  external/advisory thresholds. Owner decision (`AskUserQuestion`):
  “merge now, fix pkgdown later”.
- **Live validation (owner-designated gate):** `workflow_dispatch`-ed
  `shinytest2` on master → run `27356752221` **SUCCESS** (~19 min). All
  **13 per-module groups** (fresh `Rscript` each) reported
  `passed>0 failed=0 error=0` (“All 13 E2E module groups passed.”). Both
  Session-34 live-runner watch items resolved on the first run:
  1.  renv lib-path resolution under
      `RENV_CONFIG_AUTOLOADER_ENABLED=false` (`R CMD INSTALL` + every
      AppDriver subprocess booted the app); (2) the 23-in-one-process
      Chrome flake — the 8e-7 per-module fresh-process grouping produced
      ZERO transient errors (first environmental confirmation; per-group
      isolation contains any future transient).
- **Closed issue \#40** (“Strengthen shinytest2 E2E assertions”) with a
  full validation comment — the §8e assertion-strengthening +
  CI-stability campaign is code-complete and live-validated on master.
- **Follow-ups logged (not done this session):** **\#42** (relocate
  methodology docs out of pkgdown’s `docs/`), **\#30** (lintr cleanup) —
  both independent of package correctness.

### 2026-06-10 — Phase 8e-7 (CI per-module fresh-process grouping): run the 23-file shinytest2 E2E tier in 13 per-module groups, each in a fresh R process, to defang the 23-in-one-process Chrome flake (issue \#40, Session 50)

- **Deliverable (CI config / run-and-observe):** plan slice **8e-7**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §8/§8e-7 —
  the FINAL §8e slice) — replaced the single
  `test_dir(filter = "^(app|e2e)-", stop_on_failure = TRUE)` run step in
  `.github/workflows/shinytest2.yaml` with a **single job that loops
  over 13 per-module group regexes, each run in a fresh `Rscript`
  process**, so no one process accumulates 23 Chrome/AppDriver instances
  (the S34 “process-count dragon”: ~1 transient error / 5 full-tier
  single-process runs). Caps any process at ≤3 files.
- **Per group:** `test_dir(filter = rx, stop_on_failure = FALSE)` → a
  `passed/failed/skipped/error` report → fail/error \> 0 ⇒
  `quit(status = 1)` (checked FIRST, so a real failure is never
  mislabeled) → passed == 0 ⇒
  [`stop()`](https://rdrr.io/r/base/stop.html) **per-group silent-skip
  guard** (stronger than the old whole-run guard; a zero-match regex is
  caught separately by `test_dir`’s own “No test files found” abort).
  The bash loop runs ALL groups (full signal, one flake doesn’t skip the
  rest) and reds the job if ANY group failed — preserving
  `stop_on_failure` semantics + the job env / Chrome provisioning /
  `R CMD INSTALL` / `timeout-minutes: 30` / removed `continue-on-error`
  (R6).
- **Owner-gated topology** (`AskUserQuestion`): single-job loop chosen
  over a 13-leg `strategy.matrix` (cheapest, plan-faithful,
  root-cause-sufficient — the matrix’s 13× setup wasn’t worth it for a
  nightly job). TDD = run-and-observe (CI config; no RED→GREEN, plan
  §6), gated `PRE-RED→run-and-observe`.
- **Verified locally:** the COMMITTED 13-regex partition selects EXACTLY
  the 23 `^(app|e2e)-` files — union == tier, no overlap / gap / stray —
  against the full 182-file dir (replicating testthat’s stripped-name
  match, Learning \#33c); YAML parses (`yaml.safe_load`); run-step
  `bash -n` clean; the `Rscript -e '...'` block is single-quote-free;
  the run-step logic smoked on a throwaway dir (pass→exit 0, fail→exit
  1, skip / nomatch → nonzero) — all four branches.
- **⚠ Live-runner-only (FM \#24’s cousin):** the flake mitigation is
  environmental — the partition / guard / exit logic is proven locally,
  but the 23-in-one-process flake can only be confirmed gone on the
  first live GitHub run (which requires the workflow on `master`). Ships
  UNVALIDATED locally; not claimed fixed until a live run shows it.
  Pushing `add-methodology` → master remains a SEPARATE deliverable.
- **Scope:** CI-config only (no `R/` / `tests/` change → the test suite
  is byte-identical). CHANGELOG-only (no package/source change).

### 2026-06-10 — Phase 8e-6c (real breeding-group flow): the 3 export-NULL’d Breeding-Groups E2E blocks become genuine data-bearing assertions → 8e-6 COMPLETE (issue \#40, Session 49)

- **Deliverable (implementation):** plan slice **8e-6c**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §5/§8e-6)
  — the **third and final vertical 8e-6 flow**, completing the triad
  (pedigree ✓8e-6a, GVA ✓8e-6b, breeding ✓8e-6c). Drives the real
  breeding pipeline opt-in:
  `upload_and_wait(app, obfuscated_rhesus_mhc_ped.csv)` →
  `navigate_to_tab("Breeding Groups")` →
  `set_inputs(animalSource = "all", nIterations = 5)` →
  `click_element_safe("#breedingGroups-formGroups")` →
  `wait_for_module_ready("breedingGroups")` →
  `click_element_safe("a[data-value='Group Detail']")`, then asserts the
  rendered Group-Detail export buttons + DTs. Revives the 3
  export-NULL’d Breeding-Groups blocks from Session 43 (D5
  `test-e2e-breeding-groups-detailed.R:89` export functionality, T7
  `-tutorial.R:135` group export options, T9 `-tutorial.R:178`
  kinship-matrix export per group) from pane-active-only into
  data-bearing checks. Scope fixed by the owner’s “8e-6c” instruction;
  full **RED→GREEN** (3 `AskUserQuestion` phase gates), REFACTOR
  declined (precedent + the GVA and breeding run-flows diverge on the
  nested-tab activation, so a “shared” run-flow helper is messier than a
  clean abstraction).
- **Hard gate first (the breeding spike):** a live-browser spike
  captured the recon’s two open items firsthand before any RED. The
  Group-Detail nested `tabsetPanel` (`modBreedingGroups.R:72`) has **no
  `id`**, so it cannot be driven by `set_inputs` — it is activated via
  the unique DOM link `a[data-value='Group Detail']` (spike:
  `count == 1`). The spike proved both steps are required:
  post-formation but pre-activation, the export labels and rendered
  tables are still absent (the nested pane is `display:none`); only
  after the tab click do they enter the top-level active pane’s
  innerText. `animalSource = "all"` uses `ped$id` directly, isolating
  breeding from the GVA dependency (the `topRanked` branch’s
  `req(geneticValues())`, `appServer.R:272`).
- **Assertions (mutation-proven discriminating, RNG/seed-independent):**
  a static-UI download button is made data-bearing by PAIRING its
  visibility-gated label (matched via active-pane innerText, absent
  until the nested tab is activated) with a `suspendWhenHidden` rendered
  DT (which needs both group formation AND tab visibility). D5:
  `"Export Current Group"` + `grepl("Ego ID",` rendered
  `#breedingGroups-groupMemberTable)`. T7: `"Export Current Group"` +
  `"Age in Years"` member-table header. T9:
  `"Export Current Group Kinship Matrix"` + `grepl("<table",` rendered
  `#breedingGroups-groupKinTable)`. All tokens are static labels /
  rendered column-headers / table structure → verified GREEN with **no
  `NPRC_BG_SEED`** set. Group count and the within-group kinship
  invariant are deliberately NOT asserted (the algorithm formed one
  large MIS group from `numGp = 3`, and the strict kinship bound is
  unattainable because the module hardcodes `ignore = F–F`).
- **Verification:** D5/T7/T9 all GREEN live
  (`test-e2e-breeding-groups-detailed.R` 8/0/0,
  `test-e2e-breeding-groups-tutorial.R` 11/0/0); **\[mutation-check\]
  13/13 all pass** (correct tokens → TRUE; wrong export label +
  imaginary column + right-token-wrong-table `"Ego ID"`-in-kin → FALSE;
  foreign pane (Pedigree Browser) → FALSE; pre-flow RED re-confirmed →
  FALSE). Non-e2e regression **2140 `expectation_success` / 0 failed / 0
  error / 159 skipped / 5 pre-existing `modPyramid` warnings / 0 non-e2e
  offenders**, proven byte-identical with and without the edit via a
  `git stash` diff (the edit touches only e2e blocks, which skip at
  `create_test_app()` before any assertion). The
  2140-vs-Session-48’s-2180 figure is a measurement-method difference
  ([`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)
  under renv vs the bare system lib’s missing Suggests deps), not a
  regression. Phase-3E = the live GREEN AppDriver runs (the real
  upload→QC→kinship→group-formation→Group-Detail render) + the mutation
  spike ARE the runtime check (#31). Test-tree-only → no
  `document()`/NEWS; `tests/` lint-exempt.

### 2026-06-10 — Phase 8e-6b (real GVA-run flow): the 2 NULL’d Genetic-Value E2E blocks become genuine data-bearing assertions (issue \#40, Session 48)

- **Deliverable (implementation):** plan slice **8e-6b**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §5/§8e-6)
  — the **second of three vertical 8e-6 flows** (upload+QC ⊂ GVA ⊂
  breeding). Drives the real Genetic Value Analysis pipeline opt-in:
  `upload_and_wait(app, obfuscated_rhesus_mhc_ped.csv)` →
  `navigate_to_tab("Genetic Value Analysis")` → set `nIterations = 100`
  (minimum allowed, for speed) →
  `click_element_safe("#geneticValue-runAnalysis")` →
  `wait_for_module_ready("geneticValue")`, then asserts the **rendered
  `#geneticValue-rankingsTable`** DOM. Revives the 2 NULL’d
  Genetic-Value blocks from Session 42 (B1
  `test-e2e-genetic-value-tutorial.R:99` Value Designation, B2 `:144`
  Z-score) from pane-active-only into data-bearing checks. Scope fixed
  by the owner’s “8e-6b” instruction; full **RED→GREEN** (3
  `AskUserQuestion` phase gates), REFACTOR declined (a reusable GVA-run
  helper should co-design with 8e-6c).
- **Hard gate first (the GVA spike):** a live-browser spike settled the
  rendered-table facts before any RED, correcting a static-read trap:
  `reportGV.R:144`
  `cbind(demographics, indivMeanKin, zScores, gu, offspring)` shows no
  `value` column, but `reportGV.R:146` wraps it as
  `orderReport(finalData, ped)`, which splits the frame →
  [`rankSubjects()`](https://github.com/rmsharp/nprcgenekeepr/reference/rankSubjects.md)
  adds the `value` (“High/Low/Undetermined”) + `rank` columns → `rbind`
  re-flattens, so the rendered DT carries both `value` and `zScores`.
  The spike confirmed the default `topN = 20` view
  (`modGeneticValue.R:240`) truncates to the top-ranked (best) rows,
  which are **all “High Value”** — “Low Value”/“Undetermined” are
  truncated away, so the only faithful Value-designation token in the
  default render is `"High Value"`.
- **Assertions (mutation-proven discriminating, RNG/seed-independent):**
  B1 `"High Value"` (the Value designation rendered for the top-ranked
  rows); B2 `"zScores"` (the z-score DT column header). Both are
  structural invariants (a fixed column header; a designation guaranteed
  for the top rows) — verified by running GREEN with **no
  `NPRC_GVA_SEED`** set, so neither the 8e-5 seed hook nor value-stable
  RNG is required.
- **Verification:** 8/8 blocks GREEN in
  `test-e2e-genetic-value-tutorial.R` (the 6 static-UI blocks
  unaffected); **\[mutation-check\] all pass** (correct
  `"High Value"`/`"zScores"` → TRUE; wrong designation
  `"Low Value"`/`"Undetermined"` → FALSE; foreign-pane `"Form Groups"`
  (Breeding Groups) / `"Focal Animals"` (Pedigree) → FALSE; RED
  re-confirmed pre-run → both FALSE). Non-e2e regression **2180
  `expectation_success` / 0 failed / 0 error / 156 skipped / 5
  pre-existing `modPyramid` warnings / 0 non-e2e offenders** — Session
  47 baseline held exactly (test-only change; the e2e file self-skips
  without `NPRC_RUN_E2E`). Phase-3E = the live GREEN AppDriver run (the
  real upload→QC→GVA pipeline) + the mutation spike ARE the runtime
  check (#31). Test-tree-only → no `document()`/NEWS; `tests/`
  lint-exempt.
- **Lib currency:** the AppDriver subprocess resolves the package from
  the SYSTEM lib (`/Library/Frameworks/.../R-4.5/...`) under
  `RENV_CONFIG_AUTOLOADER_ENABLED=false`; that install was already
  current (`gatedSeed` present, v1.1.0.9000) because `R/` was unchanged
  since Session 47’s reinstall → no reinstall needed this session
  (verified currency firsthand; did not assume).

### 2026-06-10 — Phase 8e-6a (real upload+QC → pedigree-table flow): the 3 NULL’d pedigree E2E blocks become genuine data-bearing assertions (issue \#40, Session 47)

- **Deliverable (implementation):** plan slice **8e-6a**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §5/§8e-6)
  — the **first of three vertical 8e-6 flows** (upload+QC ⊂ GVA ⊂
  breeding). Drives the real pipeline opt-in for the first time in the
  E2E suite: `upload_and_wait(app, obfuscated_rhesus_mhc_ped.csv)` →
  `#dataInput-getData` → `navigate_to_tab("Pedigree Browser")`, then
  asserts the **rendered `#pedigree-pedigreeTable`** DOM. Revives the 3
  NULL’d pedigree blocks from Session 40 (A1
  `test-e2e-pedigree-module.R`, A2 `-detailed.R`, A3 `-tutorial.R`) from
  pane-active-only into data-bearing checks. Owner-gated scope (8e-6a
  only); full **RED→GREEN** (4 `AskUserQuestion` gates), REFACTOR
  declined (idiomatic 3-line driver, no helper).
- **Hard gate first (the 8e-6 spike):** a live-browser spike settled the
  recon critic’s blockers before any RED — (G4) the default
  `pedFile`/`pedigreeFileOne` upload flips `dataInput` ready and QC runs
  clean; (G5) the pedigree output is `suspendWhenHidden` (NULL until the
  Pedigree Browser tab is active, then renders all 375 rows — so the
  driver must `navigate` AFTER upload); (G2)
  `get_value(output="pedigree-pedigreeTable")` is a `json`-class string
  that **un-suspends to non-NULL even without data**, so the genuine
  data discriminator is the rendered-DOM content via
  `get_html_safe(app, "#pedigree-pedigreeTable")` — a refinement of the
  plan’s §2.3 “output tier”.
- **Assertions (all mutation-proven discriminating):** A1
  `"of 375 entries"` (row count) + `"sire"` column; A2 + `"dam"` column;
  A3 `"dataTables_length"` (the “Show N entries” length menu) +
  `"of 375 entries"`. A4 (“status filter”) left honest pane-active — no
  filter control exists (the table does render a `recordStatus` column,
  a future data-bearing option).
- **Fixture:** `inst/extdata/obfuscated_rhesus_mhc_ped.csv` (375 rows,
  canonical CSV; recon-verified to flow clean QC→GVA→breeding and
  already asserted error-free through the real `modInputServer`).
- **Verification:** 3/3 files GREEN (module 6/6, detailed 8/8, tutorial
  9/9); **\[mutation-check\] all pass** (correct content TRUE; wrong
  row-counts 999/374, foreign column `genotype`, foreign-pane
  `Breeding Groups`, and the same pattern on a different element → all
  FALSE). Non-e2e regression **2180 `expectation_success` / 0 failed / 0
  error / 156 skipped / 5 pre-existing `modPyramid` warnings / 0 non-e2e
  offenders** — Session 46 baseline held exactly (test-only change; the
  e2e files self-skip without `NPRC_RUN_E2E`). Phase-3E = the live GREEN
  AppDriver run (the real upload→QC→pedigree-render pipeline) + a
  mutation-check spike. Test-tree-only → no `document()`/NEWS; `tests/`
  is lint-exempt.
- **Environment note:** the AppDriver subprocess resolves
  `nprcgenekeepr` from the **system library**
  (`/Library/Frameworks/...`), not the renv cache, under
  `RENV_CONFIG_AUTOLOADER_ENABLED=false`; current source was reinstalled
  there first (the prior system-lib install was from Jul 2025).
- **Scope boundary:** GVA (8e-6b) and breeding-group (8e-6c) flows +
  their deferred blocks (2 GV from S42, 3 BG from S43) are deliberately
  deferred to their own sessions (FM \#18/#25). `add-methodology` still
  not on remote.

### 2026-06-10 — Phase 8e-5 (Stochastic determinism hook): env/option-gated `set_seed()` in the GVA + breeding-group module servers — the FIRST 8e PRODUCTION `R/` change (issue \#40, Session 46)

- **Deliverable (implementation):** plan slice **8e-5**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §7) — the
  **only 8e slice that edits production `R/`**
  (`modGeneticValueServer` + `modBreedingGroupsServer`, both exported).
  Adds an **env/option-gated
  [`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)
  hook** (Option A) so the stochastic GVA / breeding-group engines can
  be made reproducible on demand for E2E exact-value assertions, while
  the **default path is provably unchanged** (gate unset ⇒ no-op).
  Owner-gated (`AskUserQuestion` go/no-go chose Option A over Option B’s
  user-facing UI seed input and Option C-only’s no-production-change
  invariants), then full **RED→GREEN→REFACTOR**, every transition gated.
- **The gate (Option A):** at the top of each `eventReactive` body,
  immediately after `req()` and ahead of `withProgress` (so nothing
  between the seed and the engine consumes RNG):
  `seed <- getOption("nprcgenekeepr.gva_seed", as.integer(Sys.getenv("NPRC_GVA_SEED", NA))); if (!is.na(seed)) set_seed(seed)`
  — `modGeneticValue.R` ahead of
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  (gene-drop `sample`), `modBreedingGroups.R` ahead of
  [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  (MIS `sample`), with `nprcgenekeepr.bg_seed` / `NPRC_BG_SEED`. Uses
  the existing **exported
  [`set_seed()`](https://github.com/rmsharp/nprcgenekeepr/reference/set_seed.md)**
  (pins `sample.kind="Rounding"`). Option precedence over the env-var
  fallback; both unset ⇒ `NA` ⇒ no seed.
- **REFACTOR:** the duplicated 3-line gate factored into one internal
  `@noRd` helper `gatedSeed(optionName, envName)` in `R/set_seed.R`;
  both module call sites now call it. Structure only — no behavior
  change, no new tests (the 8 tests validate the refactored helper via
  the `set_seed` mock + determinism). `gatedSeed` is `@noRd` ⇒ **no
  NAMESPACE / man delta**.
- **Tests (8 new, browser-free `testServer`; 3 RED + 1 guard per
  module):** determinism — with the option set, two `gvResults()` /
  `groups()` runs are `identical` (RED at HEAD: unseeded runs differ
  because RNG state carries across `testServer` invocations; a
  `length(.) > 0` assertion proves the capture is non-vacuous);
  `set_seed` mock — called once with the seed when the option is set
  (RED at HEAD: never called); env-var fallback — `NPRC_GVA_SEED` /
  `NPRC_BG_SEED` read when the option is absent (RED at HEAD); and the
  default-path **guard** — neither option nor env set ⇒ `set_seed` not
  called (green-on-arrival). RED confirmed firsthand (6 genuine
  failures + 2 guards passing) before GREEN; no synthetic RED.
- **Enabling baseline commit (separate, `d0989408`):** committed the
  owner’s concurrent 14-file `R/`
  - `test_modPyramid.R` automated formatter pass (integer literals,
    quote style) on owner request, to give 8e-5 a clean baseline;
    re-verified behaviorally inert (regression held at 2166). A
    follow-on `docs:` commit regenerated 3 man pages (`appServer`,
    `modSummaryStatsServer`, `savePlotToFile`) the reformat desynced —
    the formatter had also rewrapped `#'` roxygen comments and changed
    `savePlotToFile`’s defaults to integer (`width=8L`), which would
    have tripped `R CMD check` codoc.
- **Verify:** non-e2e regression **2180 `expectation_success` / 0 failed
  / 0 error / 156 skip / 5 pre-existing `modPyramid` warnings / 0
  non-e2e offenders** (= the 2166 baseline + 14 new expectations;
  default analytical path unchanged — every existing test passes with
  the gate unset). **`devtools::check()` = 0 errors / 0 warnings / 3
  NOTEs** (all pre-existing or environmental: the stale
  `spelling.Rout.save` baseline, “future file timestamps”, non-standard
  top-level dev files — the S35 baseline; no new `gatedSeed` “no visible
  global” NOTE, confirming the lintr single-file flag is a
  stale-namespace artifact resolved by full-package analysis). Phase-3E
  runtime smoke:
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  (working-tree source via `load_all`, so the hook is active) serves
  **HTTP 200** on the default gate-unset path. Lint net-zero on the
  changed `R/`.
- **Scope / docs:** the default analytical numerics are unchanged (gate
  is a no-op by default) → **CHANGELOG only, no `NEWS.md` bullet**
  (consistent with the modular-parity precedent). 8e-5 enables the
  *optional exact-value* assertion tier in 8e-6 but does not block it
  (8e-6 can use Option-C structural invariants regardless).

### 2026-06-10 — Phase 8e-4 (Error-States + Boundary-Conditions): namespace fix + interaction revival; boot tautologies → behavioral active-pane assertions (issue \#40, Session 45)

- **Deliverable (implementation):** plan slice **8e-4**
  (`docs/planning/phase8e-assertion-strengthening-subplan.md` §5) — the
  FIRST 8e slice that is **not pure run-and-observe**: a HYBRID of
  **RED→GREEN** (the `input-`→`dataInput-` namespace fix) and
  **run-and-observe** (the assertion conversions). Two files:
  `test-e2e-error-states.R` (13) + `test-e2e-boundary-conditions.R` (13)
  = **26** browser-booting `test_that` blocks, plus the
  `upload_and_wait` helper + its browser-free unit tests.
- **Namespace fix (§2.4, RED→GREEN, 5 sites):** the input module is
  mounted under the **`dataInput`** namespace (`appUI.R:123`
  `modInputUI("dataInput")`); `data-module="input"` (`modInput.R:31`) is
  a label, not the namespace. Fixed: `helper-shinytest2.R`
  `upload_and_wait` default `module_id` `"input"`→`"dataInput"` + the
  hardcoded `input-pedigreeFileOne` now DERIVED from
  `module_id`/`file_input_id` via `do.call`; `error-states`
  `#input-getData`→`#dataInput-getData` and
  `input-minParentAge`→`dataInput-minParentAge`; `boundary`
  `input-minParentAge`→ `dataInput-minParentAge`. A new browser-free
  recording-stub unit test in `test_helper_shinytest2.R` anchors the
  helper fix in the always-run layer (+4 expectations).
- **Discriminators (firsthand-spiked):** for a namespaced **textInput**
  the wrong-id discriminator is the **value read-back** — shinytest2
  `set_inputs` on an unbound id WARNS and never sets (it does NOT
  throw), so `get_value("dataInput-minParentAge")` stays at the default
  with the wrong id; for the **actionButton** it is the `app$click`
  **throw** (→ `click_element_safe`→FALSE). A no-file `getData` click
  surfaces the transient
  `showNotification("Please select a file first.")` warning, asserted
  via `#shiny-notification-panel`.
- **Conversions (23, run-and-observe):** the `nchar(html)>100`
  near-tautologies + dead-grepl + `interaction-noop-tryCatch` blocks now
  call `assert_active_pane(app, <pane>, <static-label>)` —
  Input/Pedigree/Pyramid/GV/BG control labels confirmed against the real
  active-pane innerText. The rapid-switch / repeat-click blocks assert
  the final pane (Home / Input); the narrow/short-window blocks assert
  Home active on boot. **Zero blocks deferred to 8e-6** (all static-pane
  assertions are available pre-data).
- **Verification:** helper unit tests **63/0/0** (the 2 new
  `upload_and_wait` tests green); e2e error+boundary browser run **26
  blocks / 29 expectations GREEN, 0 failed / 0 error / 0 skip**
  (`filter="^e2e-(error|boundary)"`, `NPRC_RUN_E2E=true NOT_CRAN=true`).
  **\[mutation-check\] PASS** (correct GV pane→TRUE; wrong-pane /
  foreign-content “Number of groups”→FALSE; OLD whole-body grepl→TRUE
  content-blind contrast; namespace read-back + notification +
  wrong-selector→FALSE). Non-e2e regression **2166 `expectation_success`
  / 0 failed / 0 error / 156 skip / 5 pre-existing `modPyramid` warn / 0
  non-e2e offenders** — S40–S44 baseline + exactly the +4 new helper
  expectations. Phase-3E satisfied (the live browser run + 2 spikes ARE
  the runtime, \#31).
- **⚠ Concurrent formatter (not part of this deliverable):** at session
  start the tree was clean; mid-session an external automated style pass
  (`'…'`→`"…"`, `0`→`0L`) rewrote **14 `R/` production files** and
  briefly broke 2 (`makeFounderStatsTable.R:68`,
  `makeGeneticSummaryTable.R:58` — inner HTML quotes unescaped). Per
  SAFEGUARDS / FM \#22 those unauthored uncommitted edits were NOT
  touched; the formatter self-healed both files and settled, and the
  regression confirmed the reformat is behaviorally inert. The 8e-4
  commit stages ONLY the test-tree files + docs via explicit `git add`,
  leaving the owner’s reformat as their in-progress work.
- **Scope:** test-tree-only (2 e2e files + helper + helper unit test) →
  no `document()`/NEWS; `tests/` is `.lintr`-excluded. Strict TDD, gated
  `PRE-RED→RED` then `RED→GREEN` via `AskUserQuestion`.

### 2026-06-09 — Phase 8e-3 FINAL (Settings-About + Workflow-Integration): boot-level tautologies → behavioral active-pane assertions; navbarMenu finalized (issue \#40, Session 44)

- **Deliverable (implementation):** the **LAST two 8e-3 files** of plan
  slice 8e-3
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`) —
  `test-e2e-settings-about.R` (4) +
  `test-e2e-workflow-integration.R` (7) = **11 browser-booting
  `test_that` blocks**. Converts the content-blind
  `navigate_to_tab → grepl(get_html_safe(app,"body"))` idiom to
  behavioral `assert_active_pane(...)`. **8e-3 is now COMPLETE**
  (genetic-value S42 + breeding-groups S43 + settings-about/workflow
  S44).
- **Dragon resolved firsthand (R1 / §2.3 item 4, carried as a 🐉 by
  S42/S43):** a live-DOM spike (Rscript→AppDriver) confirmed a
  `navbarMenu("More")` child **becomes the lone active top-level
  `.tab-pane`** via `set_inputs(mainNavbar=child)` — top-level
  `.tab-content` count == 1, `get_active_pane_value`/innerText == the
  child (Settings/About/Help) content. So `navigate_to_menu_item`’s
  delegate body was already a genuine visible-pane switch; **only its
  docstring’s shallow-coverage caveat needed retiring**
  (`helper-shinytest2.R:283-292`, body unchanged) → PURE
  run-and-observe, not a helper RED→GREEN.
- **Strict TDD — PURE run-and-observe** (no defect; all panes already
  render) → green-on-arrival `[refactor-only]` conversion, gated
  `PRE-RED→run-and-observe` via `AskUserQuestion`; rigor from a
  `[mutation-check]` (no synthetic RED).
- **Conversion map — 10 keep-regex-rescope · 1 navbar-chrome
  carve-out:**
  - **settings-about (4): all genuine grepl → keep verbatim, rescope to
    the navbarMenu child pane** — S1
    `(Settings,"Settings|Configuration|options")`, S2
    `(About,"About|Version|GeneKeepR|Oregon|Primate")`, S3
    `(Help,"Help|Documentation|Online")`, S4
    `(About,"NIH|funded|grant")`.
  - **workflow-integration (7):** W1 “visits N tabs” loop → 6 per-pane
    `assert_active_pane` checks with the threshold raised `>= 3` →
    `== 6L` (so a single failed nav reds the block); W2/W3
    [`is.list()`](https://rdrr.io/r/base/list.html) responsiveness
    tautologies → genuine pane-switch asserts (Input-then-Home;
    final-pane after a 4-switch loop); W4 navbar brand → **CARVE-OUT**
    scoped to `.navbar-brand`
    (`grepl("GeneKeepR", get_html_safe(app, ".navbar-brand"))` —
    strictly stronger than the old whole-body grepl, since the brand
    lives outside any pane); W5 `(Input,"upload|file|browse")`, W6
    `(Genetic Value Analysis,"Genetic|Value|Analysis|kinship|population")`,
    W7 `(Breeding Groups,"Breeding|Groups|formation|animals")`.
- **Helper:** `navigate_to_menu_item` docstring finalized (records the
  8e-3 navbarMenu confirmation; no body change).
- **Verification:** browser run **11/11 GREEN / 12 expectations** (net-0
  swap), 0 error / 0 skip (`filter="^e2e-(settings|workflow)"`).
  `[mutation-check]` PASS — settings-about arms via the spike
  (wrong-pane→FALSE, wrong-content→FALSE); workflow arms: W1
  wrong-pane→FALSE (count would miss 6L), W4 scoped
  `grepl("Breeding", brand)`→FALSE while old whole-body
  `grepl("Breeding", body)`→TRUE (proves the old check was
  content-blind). Non-e2e regression **2162 `expectation_success` / 0
  failed / 0 error / 156 skipped / 5 pre-existing `modPyramid` warnings
  / 0 non-e2e offenders** — S40–S43 baseline held EXACTLY (read via
  `expectation_success`, not `sum(nb)`, per Learning \#43e). Phase-3E:
  the live browser run + two DOM spikes + the mutation-check spike ARE
  the runtime (#31 pattern).
- **Scope:** test-tree only (3 files: 2 test files + a test-helper
  docstring); `tests/` `.lintr`-excluded → lint-exempt; no `R/` change →
  no `document()`/NEWS (CHANGELOG only). Next: **8e-4** (namespace
  `input-`→`dataInput-` fix + error-states/boundary interaction
  revival), a separate session.
- See `PROJECT_LEARNINGS.md` Learning \#44 for the full per-block detail
  and the navbarMenu/brand/threshold findings.

### 2026-06-09 — Phase 8e-3 part B-2 (Breeding-Groups family): boot-level tautologies → behavioral active-pane assertions (issue \#40, Session 43)

- **Deliverable (implementation):** the **Breeding-Groups family** of
  plan slice 8e-3
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`) —
  `test-e2e-breeding-groups-module.R` (7),
  `test-e2e-breeding-groups-detailed.R` (7),
  `test-e2e-breeding-groups-tutorial.R` (9) = **23 browser-booting
  `test_that` blocks**. All converted from the content-blind
  `navigate_to_tab → grepl(get_html_safe(app, "body"))` idiom to
  `assert_active_pane(app, "Breeding Groups", <pattern>)`. The 2nd of
  three 8e-3 cuts (genetic-value done S42; settings-about +
  workflow-integration remain).
- **Strict TDD — PURE run-and-observe** (no defect; the Breeding Groups
  pane already renders and “Breeding Groups” IS the `tabPanel` title
  `appUI.R:166`) → green-on-arrival `[refactor-only]` conversion, gated
  `PRE-RED→run-and-observe` via `AskUserQuestion`; rigor from a
  `[mutation-check]` (no synthetic RED).
- **Conversion map by the Learning \#40/#41/#42 split — 12 KEEP · 6
  REVIVE · 1 ANCHOR · 4 NULL:**
  - **12 genuine `grepl` asserts → keep regex verbatim, rescope haystack
    to the active pane** (module M1–M7; detailed D1🐉/D3/D7; tutorial
    T2/T3).
  - **6 tautologies with a dead computed grepl → REVIVE that pattern,
    rescoped + pruned** (Learning \#42a): D2 `harem` (✓“Harem (1M:NF)”),
    D4 `result|group|table|output|formed` (✓“group”; rest data-dependent
    → 8e-6), T1 `group.*formation|source.*animal` (✓h3/guidance), T4
    `Seed.*Group|seed.*animal|specific.*animal` (✓“Seed groups with
    specific animals”), T6 `Include.*kinship|kinship.*display`
    (✓“Include kinship in display of groups”), T8 `top.*ranked` (✓“Top
    ranked”). Pruned: inputId artifacts (`seedGroups`, `showKinship`),
    never-rendered framing words (`workflow`, `Choose.*group`,
    `pre.*seed`), and the foreign-module token `genetic.*analysis`.
  - **1 content-length tautology (`nchar(html) > 200`) → ANCHOR** to the
    always-visible guidance phrase “algorithm” (D6;
    `inst/extdata/ui_guidance/group_formation.html` “The algorithm
    ignores…”).
  - **4 NULL-pattern (pane-active only):** D5/T7 (export) + T9 (export
    kinship matrix) — the `downloadButton`s live in the INACTIVE “Group
    Detail” nested tab (`display:none`, not in active-pane `innerText`;
    guidance has no export tokens) → defer to 8e-6 / nested-tab
    navigation; **T5** (infants-with-dam) — no such control exists in
    the modular UI (tutorial-only concept). Each NULL still upgrades the
    old `expect_true(TRUE)` by confirming the Breeding Groups pane is
    the active/visible one.
- **1 dragon kept verbatim, flagged in a comment, never renamed**
  (Learning \#41a): D1 `size|number|count| animals` — no literal “size”
  control; matches via “number”/“animals” (“Number of groups:”, “Number
  of top animals:”, “Seed groups with specific animals”).
- **Nested-tab visibility distinction (new this cut):** the nested
  tabsetPanel’s NAV labels (“Groups”, “Statistics”, “Group Detail”) ARE
  in the active-pane `innerText` (always visible), so M7 `statistic`
  anchors on the “Statistics” nav label and D4 “group” on the “Groups”
  nav label — but the inactive nested tabs’ CONTENT (the export buttons)
  is hidden. The pre-gate critic settled this by RENDERING the actual
  Shiny `navbarPage`+`tabsetPanel` DOM; the browser run confirmed it
  firsthand (M7 GREEN).
- **Pre-gate adversarial verification (0 corrections, dispute resolved
  firsthand):** a 4-agent refutation workflow (3 source-grounded
  skeptics defaulting-to-refuted + a cross-checking critic) over the
  23-block map BEFORE the TDD gate confirmed all 23 verdicts. It earned
  its keep by resolving the one genuine dispute (M7: is the nested nav
  label in `innerText`?) via a real Shiny DOM render and dismissing two
  skeptic refutations that rested on the opposite false premise — robust
  to 2/3 skeptics hitting stream-idle timeouts (1 full skeptic + 1
  partial + the critic sufficed).
- **Verification:** browser run **23/23 blocks GREEN / 23 expectations**
  (1:1 swap, net 0), 0 error / 0 skip (`filter="^e2e-breeding-groups"`,
  env
  `NPRC_RUN_E2E=true NOT_CRAN=true RENV_CONFIG_AUTOLOADER_ENABLED=false`).
  **\[mutation-check\] PASS** (inverted — Breeding Groups is the TARGET
  pane): correct `(Breeding Groups,"Form Groups")`→TRUE; wrong-pane
  `(Pedigree Browser,"Form Groups")`→FALSE; wrong-content
  `(Breeding Groups,"Focal Animals")`→FALSE (“Focal Animals” is
  Pedigree/Input-only `modPedigree.R:52`/`modInput.R:114`,
  grep-confirmed foreign to BG); old whole-body
  `grepl("Focal Animals",body)`→TRUE (content-blind contrast);
  active-pane innerText grepl→FALSE (sanity). Non-e2e regression
  (`NOT_CRAN=true`) — canonical testthat tally **2162
  `expectation_success` / 0 failed / 0 error / 156 skipped / 5
  pre-existing `modPyramid` warnings / 0 non-e2e offenders** — the
  S40–S42 baseline held EXACTLY (the 3 BG files self-skip at
  `create_test_app()`).
- **⚠ Measurement note (refines Learning \#42d):**
  `sum(res$nb) - sum(res$failed)` is NOT the passed count — `nb` counts
  skip and warning rows too (2162 success + 156 skip + 5 warning =
  2323). The canonical passed count is `expectation_success` (or the
  testthat reporter’s `PASS` line). A “+161 pass” delta from a test-only
  e2e edit (provably impossible) was this formula artifact, diagnosed
  firsthand, not a regression.
- **Phase 3E:** test-tree-only deliverable — the live browser run (23
  blocks via real AppDriver) + the live mutation-check spike ARE the
  runtime (#31 pattern); drove the real app, not just build-clean. No
  `R/` change → no `document()`/NEWS; `tests/` is `.lintr`-excluded.

### 2026-06-08 — Phase 8e-3 part B-1 (Genetic-Value family): boot-level tautologies → behavioral active-pane assertions (issue \#40, Session 42)

- **Deliverable (implementation):** the **Genetic-Value family** of plan
  slice 8e-3
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`) —
  `test-e2e-genetic-value-module.R` (7),
  `test-e2e-genetic-value-detailed.R` (7),
  `test-e2e-genetic-value-tutorial.R` (8) = **22 browser-booting
  `test_that` blocks**. All converted from the content-blind
  `navigate_to_tab → grepl(get_html_safe(app, "body"))` idiom to
  `assert_active_pane(app, "Genetic Value Analysis", <pattern>)`.
- **Owner-scoped to ONE family** (`AskUserQuestion`): 8e-3 censused
  firsthand at **8 files / ~56 blocks** (~3× an 8e-2 session) — far past
  the family-per-session boundary the 8e-2 sessions (S38–S41)
  established — so it is split per the plan §5 “may split if
  oversized” + the don’t-bundle dragon (FM \#18/#25). This session did
  genetic-value only; **deferred to follow-on sessions:**
  breeding-groups family (3 files, ~23) and settings-about +
  workflow-integration (the navbarMenu finalization of
  `navigate_to_menu_item` + visit-N conversion, 2 files, ~11).
- **Strict TDD — PURE run-and-observe** (no defect; the GV pane already
  renders and
  `navigate_to_tab(app, "Genetic Value Analysis", "Genetic Value")`
  already targets the right tab — “Genetic Value Analysis” IS the
  `tabPanel` title `appUI.R:148` == the module h3
  `modGeneticValue.R:32`) → green-on-arrival `[refactor-only]`
  conversion, gated `PRE-RED→run-and-observe` via `AskUserQuestion`;
  rigor from a `[mutation-check]` (no synthetic RED).
- **Conversion map by the Learning \#40/#41 split** — 16 KEEP · 3 REVIVE
  · 1 ANCHOR · 2 NULL:
  - **16 genuine `expect_true(grepl(orig))` → keep regex verbatim,
    rescope haystack to the active pane** (module M1–M7; detailed
    D1/D2/D4/D5; tutorial T1–T4/T6).
  - **3 tautologies with a DEAD computed grepl pattern → REVIVE that
    exact pattern, rescoped** (new sub-case vs S41’s “tautology → fresh
    anchor”): D3 `founder|equivalent|FE|genetic` (✓“founder” in the
    guidance “rare founder alleles” + “genetic” in the h3), D6
    `report|export|download|summary` (✓“Export All/Subset” + “Summary”
    nested-tab label), T8 narrowed to `filter` (✓“Filter View”/“Filter
    by IDs”).
  - **1 content-length tautology (`nchar(html) > 200`) → ANCHOR** to the
    distinctive always-rendered guidance phrase “ranks animals” (D7;
    `inst/extdata/ui_guidance/genetic_value.html`).
  - **2 NULL-pattern (pane-active only, data-bearing deferred to
    8e-6):** T5 “Value Designation” and T7 “Z-score” are data-dependent
    results concepts absent from the static UI/guidance — no faithful
    default-visible pattern exists, so assert only that the GV pane is
    active (Learning \#41a).
- **4 dragons keep their genuine regex verbatim** (Learning \#41a — flag
  in a comment, never rename): M4 `minimum|breeding|age` (no min-age
  control in GV; “breeding” matches guidance “breeding colony”); D1
  `population|select|animals|subset` (population is server-derived
  `modGeneticValue.R:148-162`; “animals” matches guidance “ranks
  animals” and “subset” matches “Export Subset”); T4
  `dataTable|DTOutput|table| results|ranking` (the rendered table is
  `req(gvaView())`-gated → 8e-6; “ranking” matches the static “Rankings”
  nested-tab label).
- **Pre-gate adversarial verification narrowed the map** (Learning
  \#40d/#41d): a 4-agent refutation workflow (3 source-grounded skeptics
  defaulting-to-refuted + a cross-checking critic) over the 22-block map
  BEFORE the TDD gate confirmed 21/22 and corrected **T8** — the revived
  dead pattern carried four alternatives
  (focal/display/Show.\*entries/search) FOREIGN to the GV pane
  (copy-paste from another module); only “filter” matches
  default-visible innerText, so the revive was narrowed to `filter`. The
  critic also dismissed a skeptic’s bogus newline-spanning false
  positive (R `grepl` `.` does not cross the newlines `innerText`
  inserts) and confirmed the two NULLs.
- **Verification:** browser run **22/22 blocks GREEN / 22 expectations**
  (1:1 swap, net 0), 0 error / 0 skip (`filter="^e2e-genetic-value"`,
  env
  `NPRC_RUN_E2E=true NOT_CRAN=true RENV_CONFIG_AUTOLOADER_ENABLED=false`).
  **`[mutation-check]` PASS** (inverted — Genetic Value Analysis is the
  TARGET pane): correct `(Genetic Value Analysis,"Run Analysis")`→TRUE;
  wrong-pane `(Pedigree Browser,"Run Analysis")`→FALSE; wrong-content
  `(Genetic Value Analysis,"Focal Animals")`→FALSE (Pedigree-only label
  `modPedigree.R:52`, absent from the GV pane); old whole-body
  `grepl("Focal Animals")`→TRUE (content-blind contrast); active-pane
  innerText grepl→FALSE (sanity). Non-e2e regression **2162 passed / 0
  failed / 0 error / 0 non-e2e offenders** (156 skipped, 5 pre-existing
  `modPyramid` warnings; the e2e-only change self-skips at
  `create_test_app()` `helper-shinytest2.R:196` — the 3 GV files showed
  0/0/0/22-skip — so non-e2e counts are unaffected; S40/S41 baseline
  held EXACTLY).
- **Static UI only** (data-bearing GV outputs — rankings table, scatter
  plot, Summary table incl. Founder Equivalents/Value-Designation — are
  `req()`-gated and deferred to 8e-6). Test-tree-only → no
  `document()`/NEWS; `tests/` is lint-exempt (`.lintr:35`).

### 2026-06-08 — Phase 8e-2 (Pyramid family — the LAST 8e-2 cut → 8e-2 COMPLETE): boot-level tautologies → behavioral active-pane assertions (issue \#40, Session 41)

- **Deliverable (implementation):** the **Pyramid family** of plan slice
  8e-2 (`docs/planning/phase8e-assertion-strengthening-subplan.md`) —
  `test-e2e-pyramid-module.R` (6), `test-e2e-pyramid-detailed.R` (6) =
  **12 browser-booting `test_that` blocks**. Completes 8e-2
  (home-nav+app S38 + Input S39 + Pedigree S40 + Pyramid S41); the next
  slice is **8e-3** (genetic-value / breeding-groups / menu / workflow),
  a separate session.
- **Strict TDD — PURE run-and-observe** (no defect; the Pyramid pane
  already renders and
  `navigate_to_tab(app, "Age-Sex Pyramid", "Pyramid")` already targets
  the right tab — “Age-Sex Pyramid” IS the `tabPanel` title
  `appUI.R:139`, 3rd `fallback` arg a documented no-op
  `helper-shinytest2.R:250`) → green-on-arrival `[refactor-only]`
  conversion, gated `PRE-RED→run-and-observe` via `AskUserQuestion`;
  rigor from a `[mutation-check]` (no synthetic RED).
- All 12 blocks converted from the content-blind
  `navigate_to_tab → grepl(get_html_safe(app,"body"))` idiom to
  `assert_active_pane(app, "Age-Sex Pyramid", <pattern>)`, by the
  Learning \#40 principled split: **(i) 10 genuine
  `expect_true(grepl(orig))` asserts** keep their original regex
  verbatim, only rescoping the haystack to the active pane (module
  L6/L25/L42/L59/L76/L93; detailed L6/L25\[🐉\]/L44\[🐉\]/L80); **(ii) 2
  tautologies** upgrade to a precise default-visible anchor — detailed
  L63 `expect_true(TRUE)` → “Download Plot”, detailed L99
  `nchar(html) > 100` → “Age Plot”.
- **0 NULL-pattern blocks** — unlike the Pedigree family (4 NULLs). The
  pyramid pane’s static content is rich enough (sidebar controls + an
  UNCONDITIONAL guidance HTML panel) that every block has a
  default-visible anchor; none of the 12 blocks targets the
  data-dependent rendered plot / Statistics table (those
  `req(pedigreeData())`-gated outputs, `modPyramid.R:90-118`, are not
  what these tests assert), so nothing defers to 8e-6.
- **The two dragons** keep their keywords against always-rendered static
  text: detailed:25 `male|female|sex` is satisfied by the guidance HTML
  (“…males are plotted on the left and females on the right”,
  `inst/extdata/ui_guidance/pyramidPlot.html` via
  `modPyramid.R:55-58`) + the h3 “Age-Sex Pyramid Analysis” — NOT the
  data-dependent plot axis labels; detailed:44 `max|maximum|age|limit`
  (“maximum age setting”) is satisfied by the always-visible age labels
  (“Age Unit:”, “Age Label Size:”) — there is NO dedicated max-age
  control, so the genuine regex is kept verbatim and rescoped rather
  than renamed (out of scope for a haystack-rescope slice).
- **Pre-gate adversarial verification materially CORRECTED the map** (vs
  S40’s 0/19-refuted confirmation): a 4-agent refutation workflow (3
  source-grounded skeptics defaulting-to-refuted + a critic) over the
  12-block map BEFORE the TDD gate flagged **2/12** — both proposed
  NULLs (D3 “maximum age setting”, D6 “data requirement message”).
  Correctly: D3’s regex matches static “age” (→ KEEP, don’t NULL) and
  D6’s pane has always-rendered guidance (→ anchor “Age Plot”, don’t
  NULL+defer). Adopting both corrections yielded the 0-NULL outcome. The
  browser run remained the authoritative `[verify-first]`.
- **Static UI only** (data-bearing plot/table deferred to 8e-6 by virtue
  of not being targeted here).
- **Verification:** browser run **12/12 blocks GREEN / 12 expectations**
  (1:1 swap, net 0), 0 error / 0 skip (`filter="^e2e-pyramid"`, env
  `NPRC_RUN_E2E=true NOT_CRAN=true RENV_CONFIG_AUTOLOADER_ENABLED=false`).
  **`[mutation-check]` PASS** (inverted vs the Pedigree slice — Pyramid
  is now the TARGET pane) — correct `(Age-Sex Pyramid,"Bin Size")`→TRUE;
  wrong-pane `(Pedigree Browser,"Bin Size")`→FALSE; wrong-content
  `(Age-Sex Pyramid,"Focal Animals")`→FALSE (Pedigree-only label
  `modPedigree.R:52`, absent from the Pyramid pane); old whole-body
  `grepl("Focal Animals")`→TRUE (content-blind contrast); active-pane
  innerText grepl→FALSE (sanity). Non-e2e regression **2162 passed / 0
  failed / 0 error / 0 non-e2e offenders** (156 skipped, 5 pre-existing
  `modPyramid` warnings; the e2e-only change self-skips at
  `create_test_app()` so non-e2e counts are unaffected — S40 baseline
  held exactly).
- **Test-tree-only** → no `document()`/NEWS bullet, `tests/`
  lint-exempt. Phase-3E satisfied by the live browser run +
  mutation-check spike (the \#31 pattern — drove the real app).

### 2026-06-08 — Phase 8e-2 (Pedigree family): boot-level tautologies → behavioral active-pane assertions (issue \#40, Session 40)

- **Deliverable (implementation):** the **Pedigree family** of plan
  slice 8e-2
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`) —
  `test-e2e-pedigree-module.R` (5), `test-e2e-pedigree-detailed.R` (6),
  `test-e2e-pedigree-tutorial.R` (8) = **19 browser-booting `test_that`
  blocks**. Continues S38 (home-nav+app) and S39 (Input); 8e-2 now has
  only the **Pyramid family** (module/detailed = 12) left, as a separate
  session (plan R3 / FM \#18/#25).
- **Strict TDD — PURE run-and-observe** (no defect; the Pedigree pane
  already renders and
  `navigate_to_tab(app, "Pedigree Browser", "Pedigree")` already targets
  the right tab — “Pedigree Browser” IS the `tabPanel` title
  `appUI.R:130`, and the 3rd `fallback` arg is an explicit no-op,
  `helper-shinytest2.R:250`) → green-on-arrival `[refactor-only]`
  conversion, gated `PRE-RED→run-and-observe` via `AskUserQuestion`;
  rigor from a `[mutation-check]` (no synthetic RED).
- All 19 blocks converted from the content-blind
  `navigate_to_tab → grepl(get_html_safe(app,"body"))` idiom to
  `assert_active_pane(app, "Pedigree Browser", <pattern>)`, by a
  principled split: **(i) genuine `expect_true(grepl(orig))` asserts**
  keep their original regex verbatim, only rescoping the haystack to the
  active pane (module L6/L25/L42/L76; detailed L6/L25/L44\[🐉\]/L82;
  tutorial L155\[🐉\]); **(ii) `expect_true(TRUE)` tautologies** upgrade
  to a precise default-visible anchor — “Display Unknown IDs”, “Focal
  Animals”, “Choose CSV file”, “Trim pedigree”, “Update Focal Animals”,
  “Clear Focal Animals” (`modPedigree.R:52,72,79,86,105,118`); **(iii)
  honest NULL-pattern** `assert_active_pane(app, "Pedigree Browser")`
  for 4 blocks whose target is data-dependent or nonexistent — the DT
  table (module L59, detailed L63: renders only after
  `req(pedigreeData())` → deferred to 8e-6), DataTables “Show X entries”
  pagination (tutorial L28 → 8e-6), and the “status filter” (detailed
  L101: no such static control exists).
- **The two dragons** (`pedigree-detailed:57`
  `sire|dam|parent|offspring|ancestor|descendant`,
  `pedigree-tutorial:174` `sire|dam|sex|birth|exit|age|gen|population`)
  keep their keywords — the column names are listed in the
  always-rendered `inst/extdata/ui_guidance/pedigree_browser.html`
  guidance panel (“Ego ID, Sire ID, Dam ID, Sex, Generation, and
  Population… Birth Date, Exit Date, Age”).
- **Pre-gate adversarial verification:** ran a 4-agent refutation
  workflow (3 per-file skeptics + critic) over the 19-block map BEFORE
  posing the TDD gate — **0/19 refuted**, critic GO, all patterns
  confirmed default-visible, the 4 NULLs confirmed honest, and the
  mutation labels “Color Scheme”/“Bin Size” confirmed foreign
  (Pyramid-only). De-risks a slow browser cycle
  (`[right-sized-orchestration]` / `[completeness-workflow]`).
- **Static UI only** (data-bearing tables/plots deferred to 8e-6).
- **Verification:** baseline browser run 19/19 green → post-conversion
  **19/19 blocks GREEN / 19 expectations** (1:1 swap, net 0), 0 error /
  0 skip (`filter="^e2e-pedigree"`, env
  `NPRC_RUN_E2E=true NOT_CRAN=true RENV_CONFIG_AUTOLOADER_ENABLED=false`).
  **`[mutation-check]` PASS** — correct
  `(Pedigree Browser,"Focal Animals")`→TRUE; wrong-pane
  `(Age-Sex Pyramid,…)`→FALSE; wrong-content
  `(Pedigree Browser,"Color Scheme")`→FALSE (Pyramid-only label, absent
  from the Pedigree pane); old whole-body `grepl("Color Scheme")`→TRUE
  (content-blind contrast); active-pane innerText grepl→FALSE (sanity).
  Non-e2e regression **2162 passed / 0 failed / 0 error / 0 non-e2e
  offenders** (156 skipped, 5 pre-existing `modPyramid` warnings; the
  e2e-only change self-skips at `create_test_app()` so non-e2e counts
  are unaffected).
- **Test-tree-only** → no `document()`/NEWS bullet, `tests/`
  lint-exempt. Phase-3E satisfied by the live browser run +
  mutation-check spike (the \#31 pattern — drove the real app).

### 2026-06-08 — Phase 8e-2 (Input family): boot-level tautologies → behavioral active-pane assertions (issue \#40, Session 39)

- **Deliverable (implementation):** the **Input family** of plan slice
  8e-2 (`docs/planning/phase8e-assertion-strengthening-subplan.md`) —
  `test-e2e-input-module.R` (5), `test-e2e-input-detailed.R` (6),
  `test-e2e-input-tutorial.R` (8) = **19 browser-booting `test_that`
  blocks**. Continues S38’s home-nav+app sub-slice; 8e-2 is now ~half
  done. Pedigree and Pyramid families remain for later 8e-2 sessions
  (owner-directed scope: Input family only — plan R3 / FM \#18/#25).
- **Strict TDD — PURE run-and-observe** (no defect; the Input pane
  already renders and `navigate_to_tab("Input")` already targets the
  right tab — “Input” IS the `tabPanel` title, `appUI.R:120-124`) →
  green-on-arrival `[refactor-only]` conversion, gated
  `PRE-RED→run-and-observe` via `AskUserQuestion`; rigor from a
  `[mutation-check]` (no synthetic RED).
- All 19 blocks converted from the content-blind
  `navigate_to_tab → grepl(get_html_safe(app,"body"))` idiom to
  `assert_active_pane(app, "Input", <static pattern>)`. Patterns sourced
  firsthand from the **`innerText` visibility-map** of the Input pane —
  default-visible sidebar controls (h3 “Data Input and Quality Control”,
  “File Type”, “Select Pedigree File”, “Minimum Parent Age”, “Read and
  Check Pedigree”), the nested-tab nav labels (“QC Summary”, “Errors”,
  “Cleaned Data”, “Input Format”), and the active “Input Format” tab’s
  `includeHTML(input_format.html)` guidance (“comma-delimited”,
  “tab-delimited”, “Excel”, “genotype”). Conditionally-hidden controls
  (the Separator radio, non-default fileInputs) and non-active nested
  tabs are `display:none` → deliberately avoided.
- **Honest tautology conversion:** `input-detailed` “has example data
  option” (`expect_true(TRUE)`) names a feature the module does NOT have
  → converted to NULL-pattern `assert_active_pane(app, "Input")`
  (asserts navigation genuinely landed on the visible Input pane), not a
  forced match on incidental doc text. `input-tutorial` “genotype file
  support” (also a tautology) DOES have real backing → real
  `"genotype"`.
- **Static UI only** (data-bearing tables/plots deferred to 8e-6).
- **Verification:** baseline browser run 19/19 green → post-conversion
  **19/19 blocks GREEN / 19 expectations**, 0 error / 0 skip
  (`filter="^e2e-input"`, env
  `NPRC_RUN_E2E=true NOT_CRAN=true RENV_CONFIG_AUTOLOADER_ENABLED=false`).
  **`[mutation-check]` PASS** — correct→TRUE; wrong-pane
  `(Age-Sex Pyramid)`→FALSE; wrong-content
  `(Input,"Color Scheme")`→FALSE (Pyramid-only label, absent from the
  Input pane); old whole-body `grepl("Color Scheme")`→TRUE
  (content-blind contrast — exactly the defect the conversion closes).
  Non-e2e regression **2122 passed / 0 failed / 0 error** (159
  e2e-skipped, 5 pre-existing `modPyramid` warnings — unchanged S38
  baseline).
- **Test-tree-only** → no `document()`/NEWS bullet, `tests/`
  lint-exempt. Phase-3E satisfied by the live browser run +
  mutation-check spike (the \#31 pattern — drove the real app).

### 2026-06-07 — Phase 8e-2 (home-nav + app-file sub-slice): boot-level tautologies → behavioral active-pane assertions (issue \#40, Session 38)

- **Deliverable (implementation):** the home-navigation + light-app-file
  sub-slice of plan slice 8e-2
  (`docs/planning/phase8e-assertion-strengthening-subplan.md`). 8e-2
  spans 11 files / 64 browser-booting `test_that` blocks (plan risk R3 /
  §5 8e-2 dragon = oversized) → split by owner `AskUserQuestion`; this
  session did **home-navigation (10 blocks) + test-app-loading (2) +
  test-app-navigation (2)**. Input, pedigree, and pyramid families
  remain for later 8e-2 sessions.
- **Strict TDD — PURE run-and-observe** (no defect in scope; the app
  already behaves and every navigation targets the correct tab) →
  green-on-arrival `[refactor-only]` conversion, gated
  `PRE-RED→run-and-observe` via `AskUserQuestion`; rigor supplied by a
  `[mutation-check]` (no synthetic RED).
- **`test-e2e-home-navigation.R`** — 5 Home-pane content checks →
  `assert_active_pane(app, "Home", …)`; the 3 `#goto_*` clicks →
  `assert_active_pane(app, "Input" / "Pedigree Browser" / "Age-Sex Pyramid", …)`,
  turning a no-op-tolerant body-grepl into a real pane-switch assertion
  (the buttons are wired to `updateNavbarPage(...)`,
  `appServer.R:72-94`). The 2 navbar-label tests (“Navbar has all main
  tabs”, “More menu exists”) stay whole-DOM `grepl` **carve-outs**
  (navbar `<ul>`/dropdown labels live outside every `.tab-pane`;
  documented inline).
- **`test-app-loading.R`** — block 1 now also asserts the app boots to
  the **Home pane** (`assert_active_pane`); block 2’s navbar body-grepl
  strengthened **structurally** to assert the real tab anchors exist
  (`wait_for_element(app, 'a[data-value="Input"]')` …), not a substring
  the Home pane’s “Go to Input” button also satisfies.
  **`test-app-navigation.R`** — the two `nchar>0` tautologies become a
  real Input tab-anchor click → pane-switch assertion; the
  `is.list(values)` check gains
  `expect_identical(app$get_value(input="mainNavbar"), "Home")`.
- **Static UI only** (data-bearing tables/plots deferred to 8e-6);
  patterns sourced from each pane’s module UI (`modInput.R:42`,
  `modPedigree.R:52,103`, `modPyramid.R:25-32`).
- **Verification:** opt-in browser run of the 3 files **14/14 blocks
  GREEN, 22 expectations** (net +2 vs the 20-expectation baseline), 0
  error / 0 skip. **Mutation check passed** — after `#goto_input`,
  asserting the wrong pane (`"Home"`/`"Age-Sex Pyramid"`) returns FALSE
  and a Pyramid-only pattern (`"Color Scheme"`) returns FALSE, while the
  old whole-body `grepl` for a Pyramid keyword passes on Input
  (content-blind). Non-e2e regression unchanged: **2122 passed / 0
  failed / 0 error** (159 e2e-skipped, 5 pre-existing `modPyramid`
  warnings). Test-tree-only → no `document()`, no `NEWS.md` bullet,
  `tests/` is lint-exempt.

### 2026-06-07 — Phase 8e-1: active-pane assertion foundation + summary-statistics conversion (issue \#40, Session 37)

- **Deliverable (implementation):** slice 8e-1 of
  `docs/planning/phase8e-assertion-strengthening-subplan.md` — the
  load-bearing foundation for converting the shinytest2 E2E suite from
  boot-level tautologies to behavioral active-pane assertions. Strict
  TDD (PRE-RED→RED, RED→GREEN gated) + a spike-failure scope-fork owner
  gate.
- **4 active-pane helpers** added to
  `tests/testthat/helper-shinytest2.R` — `get_active_pane_text`,
  `get_active_pane_value`, `wait_for_active_pane`, `assert_active_pane`
  (+ an internal `.active_pane_js()` builder), following the existing
  `*_safe` never-throw convention. `assert_active_pane()` is the drop-in
  replacement for the `get_html(app,"body")` +
  [`grepl()`](https://rdrr.io/r/base/grep.html) tautology: it asserts
  the NAMED top-level navbar pane is the single visible/active one
  (catching a wrong-tab or silent-no-op navigation) and optionally that
  its visible `innerText` matches a pattern. **11 browser-free unit
  tests / 59 expectations** in `test_helper_shinytest2.R`
  (fake-AppDriver stubs, the Phase-8a idiom).
- **Spike-corrected mechanism (HARD GATE).** The live-Chrome spike
  FALSIFIED the plan’s §2.3/§4 selector
  (`.tab-content > .tab-pane.active`): the modules nest their own
  `tabsetPanel`s, so `.tab-content` is non-unique (5 containers;
  first-match `querySelector` latches onto a nested pane). Corrected to
  the only `.tab-content` not inside a `.tab-pane` → its direct-child
  `.tab-pane.active` (structural; no dependence on the dynamic
  `data-tabsetid`). Owner-approved deviation; re-confirmed 17/17 through
  the real helpers (all navs incl. the navbarMenu “More” children;
  innerText honors visibility when correctly scoped).
- **`test-e2e-summary-statistics-module.R` converted** — fixed the 7
  wrong-tab navigations (tests 2–8 went to “Genetic Value Analysis”;
  “Summary Statistics” is its own `tabPanel`, appUI.R:156-159) + dropped
  the false “embedded in another tab” fallback, and replaced all 8
  tautologies/hidden-DOM asserts with `assert_active_pane()` on STATIC
  UI (export-button labels, the heading, the population-genetics
  guidance). Data-bearing content (summary/founder tables, rendered
  plots) deferred to slice 8e-6.
- **Verification:** helper unit tests 59/0/0; live spike 17/17;
  converted e2e file 8/8/0 (opt-in); mutation check PASS
  (wrong-tab→FALSE, correct-tab→TRUE — the old `expect_true(TRUE)`
  passed both); non-e2e regression 2122 passed / 0 failed / 0 error (159
  e2e-skipped, 5 pre-existing `modPyramid` warnings).
- **Scope:** test-infra only (no `R/` change) → `document()` N/A,
  `tests/` lint-exempt, CHANGELOG only (no NEWS). See
  `PROJECT_LEARNINGS.md` Learning \#37 + glossary `[hard-gate-spike]`.

### 2026-06-06 — Phase 9: retire the legacy monolithic Shiny app (declare modular canonical) + \#27 CLOSED (Session 35)

- **Deliverable (implementation):** the FINAL phase of the shiny-module
  conversion (`docs/planning/shiny-module-conversion-plan.md` §9
  Phase 9) — retire the monolith now that the modular app is canonical
  and at parity (Phases 1–8). Strict TDD (RED→GREEN gated) + 4 owner
  `AskUserQuestion` gates + the pre-RED→RED / RED→GREEN TDD gates.
  **This completes the entire XARCH-1 / issue-#27 modularization
  campaign (Phases 1–9).**
- **[`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
  → deprecated alias.** Rewrote it as a
  [`lifecycle::deprecate_soft()`](https://lifecycle.r-lib.org/reference/deprecate_soft.html)
  alias launching `runModularApp(port=6013L, launch.browser=TRUE)`;
  zero-arg callers keep working. New
  `tests/testthat/test_runGeneKeepR_alias.R` (deprecation + delegation +
  port/launch.browser forwarding) and `test_monolith_removed.R`
  (`system.file("application")==""`).
- **Deleted `inst/application/`** (server.r, ui.r, global.R, 8 uitp\*.R,
  example_1.R, the dead modPyramid.R stub, www/ — 17 tracked files) as
  its own revertible commit (§15). `inst/www/` (the modular app’s
  `data-ready.js`) preserved.
- **Removed confirmed orphans (owner-approved):** `getMinParentAge`
  (unexported, 0 callers), `getLogo` (exported, monolith-only — a
  public-API removal), `shouldShowErrorTab` (exported but bypassed by
  `checkErrorLst`; also dropped the dead `qcResults` build in
  appServer.R + the `@seealso` refs), `modMinimalTest` (unmounted
  scaffold) + their tests. `document()` dropped 4 exports + 4 man pages.
- **NAMESPACE fallout fixed:** `getMinParentAge.R` was the SOLE carrier
  of `@import shiny`, so its deletion dropped `import(shiny)` and the
  modular UI failed (`h5` not found); relocated `@import shiny` to
  `R/nprcgenekeepr-package.R`. Caught by the regression run, not the
  inventory (Learning \#35).
- **Pre-flight (irreversible delete):** re-ran the §10 grep-inventory as
  a read-only multi-modal sweep + completeness critic
  (`wf_48a6f152-f0f`); firsthand-verified the sole `system.file`
  reference, `inst/www` ≠ `inst/application/www`, the lifecycle dep, and
  that all 17 files are tracked/revertible.
- **Docs:** `_pkgdown.yml` (drop getLogo/getMinParentAge),
  `inst/WORDLIST`, `CLAUDE.md`, `ROADMAP.md` (milestone marked
  complete), `NEWS.Rmd`/`NEWS.md` (monolith-retirement bullet), vignette
  `_running_shiny_application.Rmd` →
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md);
  `README.md` re-knit. (`a3manual`/`a2interactive` `.md/.html/.R` are
  stale-by-design release artifacts — rebuilt from source at release;
  `check()` builds vignettes from source regardless.)
- **Verification:** non-e2e regression **2135 passed / 0 failed / 0
  error** (5 pre-existing modPyramid warnings); runtime smoke
  [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
  → modular app **HTTP 200**; **`devtools::check()` = 0 errors / 0
  warnings**, `creating vignettes ... OK` (pre-existing NOTEs only:
  non-standard top-level dev files; a stale `spelling.Rout.save`
  baseline); grep confirms no `system.file("application")`.
- **Pre-existing fix (separate `fix:` commit, owner-approved):**
  `a2interactive.Rmd` error-list table was missing the `invalidIdChars`
  description (NEW-45 drift:
  [`getEmptyErrorLst()`](https://github.com/rmsharp/nprcgenekeepr/reference/getEmptyErrorLst.md)
  has 10 fields vs 9 hardcoded) — failed the vignette build; surfaced by
  the full `check()`.
- **Issue \#27 (Modularize code using shiny modules) CLOSED.**
- Commits: `3db018d1` (refactor!: alias + orphans), `24992e0b` (feat!:
  delete monolith), `53a9e5e0` (docs), `a1618c48` (fix: a2interactive
  vignette), + this `docs:` close-out.

### 2026-06-06 — Implement Phase 8d of the conversion E2E harness: interaction/menu tier green + CI filter broadened to the full tier + \#39 CLOSED (Session 34)

- **Deliverable (implementation):** the FINAL sub-phase of the Phase 8
  E2E mini-campaign (`docs/planning/phase8-e2e-harness-subplan.md`
  §5(8d)) — the **5 interaction/menu E2E files** (home-navigation,
  settings-about, workflow-integration, error-states,
  boundary-conditions; 47 blocks / 53 expectations) green-or-clean-skip
  opt-in, **broaden the CI run-step filter** to the full `^(app|e2e)-`
  tier (all 23 files), **close issue \#39**, and file the 8e follow-on
  (#40). **Config / run-and-observe** (TDD code-phases INAPPLICABLE —
  owner-approved gate, like 8b/8c): the §8.2 navbarMenu spike + the
  53/53 green run proved the provisional `navigate_to_menu_item` is
  already correct, so the only code touch is a comment-only docstring +
  the CI YAML filter — no R unit to write test-first.
- **§8.2 navbarMenu spike — RESOLVED (verify-first, before
  classifying).** `set_inputs(mainNavbar="Settings"/"About"/"Help")` →
  `get_value(input="mainNavbar")` reads back the child label TRUE for
  all 3 → `navigate_to_menu_item`’s delegate-to-`navigate_to_tab` body
  is final (no DOM dropdown-open+click). `click("#goto_input")`
  navigates for real. **Honesty nuance (→ 8e/#40):** the input value
  reaches the navbarMenu child but the VISIBLE pane does not truly
  switch — `grepl(body)` passes only via the §2.3 hidden-DOM (§8.3
  navigation-false-positive).
- **The 5 8d files — green opt-in.** `NPRC_RUN_E2E=true NOT_CRAN=true` →
  47 test_that blocks / 53 expectations, 0 fail / 0 error / 0 skip. All
  four S33 Watch items confirmed benign firsthand (E2E_TIMEOUT defined +
  only used inside test blocks; the 6 `#goto_*` observers wired
  `appServer.R:73-95`; boundary’s named `height/width` handled by
  `create_app_driver`; the `input-` selectors stay tryCatch-swallowed
  no-ops — 8e).
- **CI filter broadened** to `^(app|e2e)-` (verified firsthand it
  selects EXACTLY the 23 test-{app,e2e}-\* files — replicating
  testthat’s stripped-name match in R — and excludes the `appServer`
  near-miss via the trailing `-`); job env + `stop_on_failure=TRUE` +
  the `sum(passed)==0` silent-skip guard unchanged. Full tier
  re-validated in ONE process: **193 passed / 0 fail / 0 error / 0
  skip**, 23 files.
- **⚠ Low-rate Chrome process-count FLAKE found + handled.** An
  ultracode 4-lens adversarial review (`wf_ef031b1d-edc`) caught that
  the 23-in-one-process run is intermittently flaky — ~1 transient
  Chrome error in 5 local full-tier runs (`workflow-integration.R` “App
  maintains state when switching tabs”; isolated 8/8/8) — the §5(8c)/R2
  dragon; under `stop_on_failure=TRUE` it can red the scheduled job.
  Reproduced firsthand (2 fresh dedicated runs clean → low-rate +
  contention-sensitive). **Owner decision (`AskUserQuestion`): close
  \#39 now + document the flake**; CI-stability hardening (per-group
  fresh processes) routed to \#40.
- **Issue tracker:** **\#39 CLOSED** (`--reason completed`, with a
  validation/watch-item comment). **8e filed as \#40** (“Strengthen
  shinytest2 E2E assertions…”, label `enhancement`) capturing the
  §2.4/§2.5/§6 deferred items + today’s navbarMenu false-positive, plus
  a CI-stability comment for the flake.
- **Validation:** §8.2 read-backs TRUE; 53/53 8d green; 193/0/0/0
  full-tier single-process; non-e2e regression (`NOT_CRAN=true`,
  NPRC_RUN_E2E unset → e2e clean-skip) = **0 failed / 0 error**, 0
  non-e2e offenders, 2159 passed, 156 e2e-skipped, 5 pre-existing
  `modPyramid` warnings (unchanged S31/S32/S33 baseline). Diff is
  comment-only (helper docstring) + the CI filter → `document()` N/A,
  `tests/`+`.github` lint-exempt, no `* 2.*` source dupes; committed
  `d254a91c` with **explicit `git add`** of only the 2 files (the
  review’s `.DS_Store` BLOCKER). **Live GitHub run DEFERRED** (branch
  not on remote) — TWO watch items now (renv lib-path + the flake).
- **Next:** parent **Phase 9** (declare the modular app canonical +
  DELETE the monolith — IRREVERSIBLE, its own session, do NOT bundle;
  confirm with the owner + grep-inventory first). The \#39 E2E
  mini-campaign (8a–8d) is COMPLETE.

### 2026-06-05 — Implement Phase 8c of the conversion E2E harness: per-module shallow tier green + CI filter broadened (issue \#39) (Session 33)

- **Deliverable (implementation):** the third sub-phase of the Phase 8
  E2E mini-campaign (`docs/planning/phase8-e2e-harness-subplan.md`
  §5(8c)) — run-and-observe the **15 shallow per-module E2E files** (103
  tests) green opt-in, and **broaden the CI run-step filter** in
  `.github/workflows/shinytest2.yaml` from the 3 boot-smoke files to the
  **18 verified 8b+8c files**. **Config / run-and-observe** (TDD
  code-phases INAPPLICABLE — approved gate, like 8b): the 15 files + the
  8a helpers already exist and pass trivially via the §2.3 navbarPage
  hidden-DOM, so there is **no new R unit to write test-first**; the
  browser spike is the verification and the only artifact change is the
  CI YAML filter.
- **8c browser spike — green opt-in.** With
  `NPRC_RUN_E2E=true NOT_CRAN=true`, run per module-group: `e2e-input`
  (19), `e2e-pedigree` (19), `e2e-pyramid` (12), `e2e-genetic-value`
  (22), `e2e-summary-statistics` (8), `e2e-breeding-groups` (23) = **103
  tests across 15 files, 0 fail / 0 error / 0 skip.** Chrome launches
  and the modular app boots for every test.
- **Helper corner-cases verified firsthand (§5(8c) DONE):** (a)
  `navigate_to_tab`’s 3rd arg is the ignored `fallback` — the pyramid
  files navigate to the top-level “Age-Sex Pyramid” tab and pass
  (modPyramid’s “Plot”/“Statistics” sub-tabs are never targeted); (b)
  the only content-coupled assertions (`pedigree-detailed.R:57`,
  `pedigree-tutorial.R:169`) pass on the always-rendered
  `pedigree_browser.html` guidance — noted, not changed; (c)
  `summary-statistics-module`’s wrong-tab navigation (7/8 tests go to
  “Genetic Value Analysis”, §2.4) still passes via the hidden-DOM — a
  known 8e item, not an 8c blocker.
- **CI filter broadened** (owner-approved): the run-step `filter` goes
  from `^(app-loading|app-navigation|e2e-data-ready)$` to
  `^(app-loading|app-navigation|e2e-data-ready|e2e-input|e2e-pedigree|e2e-pyramid|e2e-genetic-value|e2e-summary-statistics|e2e-breeding-groups)`.
  Verified firsthand the regex selects **exactly the 18 files** (3 8b +
  15 8c) and **excludes exactly the 5 Phase-8d files** (home-navigation,
  settings-about, workflow-integration, error-states,
  boundary-conditions) — those enter CI only once 8d verifies them. The
  `stop_on_failure=TRUE` + `sum(passed)==0` silent-skip guard and the
  job env block are unchanged.
- **Validation:** the **exact broadened run-step re-run locally in a
  single process** (the §5(8c) AppDriver-process-count dragon — 18 files
  × drivers in one `test_dir`) → **18 files, passed=140 / failed=0 /
  skipped=0 / error=0** (37 8b + 103 8c), exit 0. Full non-e2e suite
  under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)+`NOT_CRAN=true`
  = **0 failed / 0 error**, 0 non-e2e offenders, 156 e2e-skipped, 2154
  passed, 5 pre-existing `modPyramid` warnings (unchanged S31/S32
  baseline). YAML parses; no R/test code changed → `document()` N/A,
  `tests/`+`.github` lint-exempt, no `* 2.*` source dupes. **Live GitHub
  run deferred** (branch not on remote; same posture as S32) — the
  run-step is validated locally end-to-end. **No adversarial workflow**
  (no ultracode opt-in; a one-line filter broadening validated
  end-to-end is “already verified” — a multi-agent review would be
  ceremony for this change surface).
- **Next:** Phase 8d (5 interaction/menu files, 47 tests — needs the
  secondary helpers + the navbarMenu spike → **close \#39** + file the
  8e assertion-strengthening issue). Then parent Phase 9 (monolith
  deletion, irreversible).

### 2026-06-05 — Implement Phase 8b of the conversion E2E harness: first browser run + CI rewire (issue \#39) (Session 32)

- **Deliverable (implementation):** the second sub-phase of the Phase 8
  E2E mini-campaign (`docs/planning/phase8-e2e-harness-subplan.md`
  §5(8b)) — the **first-ever real browser run** of the modular GeneKeepR
  app under `shinytest2`/`chromote`, plus the **CI rewire** of
  `.github/workflows/shinytest2.yaml`. **Config-only** (TDD code-phases
  INAPPLICABLE — approved gate): the 3 boot-smoke files use
  `create_test_app()` + `AppDriver$new` directly / `testServer` (no new
  helpers), so the deliverable is the empirical spike + the CI YAML, not
  RED→GREEN code.
- **🐉 First browser run — green opt-in.** With
  `NPRC_RUN_E2E=true NOT_CRAN=true`, all 3 boot-smoke files run green:
  `test-app-loading.R` (2), `test-app-navigation.R` (3),
  `test-e2e-data-ready.R` (32) = **37 tests, 0 fail / 0 error / 0
  skip.** Chrome launches and the modular app boots. The **navigation
  spike (§8.1) resolved positively** — `a[data-value="Input"]` clicks
  against the live bslib navbar (no self-skip).
- **CI `shinytest2.yaml` rewired** (owner decision: scheduled + manual):
  triggers → `schedule` (`0 7 * * *`) + `workflow_dispatch` (dropped
  per-PR push/pull_request); `NPRC_RUN_E2E:'true'` at **job-level
  `env:`**; `continue-on-error` **removed**; Chrome via
  **`browser-actions/setup-chrome@v2`** (`install-dependencies:true`) +
  `CHROMOTE_CHROME` via `$GITHUB_ENV` + a `find_chrome()`
  resolve-assert; runs only the 3 smoke files with
  `stop_on_failure=TRUE`; `_snaps/`+`*.png` artifact upload kept.
- **Adversarial review caught a HIGH blocker I missed** (4-lens +
  completeness-critic workflow, re-verified firsthand): the rewrite
  added `NPRC_RUN_E2E` but **not `NOT_CRAN`** → on the non-interactive
  `Rscript` runner `skip_on_cran()` fires → all 3 files **silently
  skip** → `stop_on_failure` doesn’t catch skips → the job goes green
  having run nothing. Reproduced firsthand (NOT_CRAN unset → 4 skipped,
  0 run). Fixed: `NOT_CRAN:'true'` at job env. Also hardened: (a)
  `RENV_CONFIG_AUTOLOADER_ENABLED:'false'` so the package installs to
  the **site** lib (the renv autoloader otherwise targets renv’s private
  lib, which the AppDriver subprocess can’t see); (b) an
  **executed-count guard** ([`stop()`](https://rdrr.io/r/base/stop.html)
  if `sum(res$passed)==0`) to make the silent-skip class fail loud; (c)
  a stronger `find_chrome()` assert (single existing path, not bare
  `nzchar` which passes vacuously on `NULL`).
- **Package-install step added** (was missing): `R CMD INSTALL .` after
  `setup-r-dependencies`, since the app subprocess does
  [`library(nprcgenekeepr)`](https://rmsharp.github.io/nprcgenekeepr/)
  and `create_test_app()` uses `system.file(package=)`.
- **No R/test code changed** (sub-plan §11 — the E2E files are
  run/triaged, not rewritten). Full non-e2e suite under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html)+`NOT_CRAN=true`
  = **0 failed / 0 error**, 0 non-e2e offenders, e2e skipped (156), only
  the 5 pre-existing `modPyramid` warnings — unchanged from the S31
  baseline.
- **Verification limit (stated, not skipped — not FM \#24):** the CI
  YAML is verified **statically** (YAML parse + 4-lens adversarial
  review + the exact run-step R validated locally) but **not by a live
  GitHub run** — branch `add-methodology` isn’t on the remote and a live
  run would create a remote feature branch (owner chose static +
  adversarial only). The renv lib-path / AppDriver-subprocess
  interaction is the \#1 item to confirm on the first live run.
  `schedule`/`workflow_dispatch` activate once merged to master.
- **Files:** `.github/workflows/shinytest2.yaml` (rewritten);
  `docs/planning/phase8-e2e-harness-subplan.md` §7 (synced — the spec
  had omitted `NOT_CRAN`). Next: **Phase 8c** (15 shallow per-module
  files).

### 2026-06-05 — Implement Phase 8a of the conversion E2E harness: define the 6 driver helpers + E2E_TIMEOUT (issue \#39) (Session 31)

- **Deliverable (implementation):** the first sub-phase of the Phase 8
  E2E mini-campaign (`docs/planning/phase8-e2e-harness-subplan.md`
  §5(8a)) — defined the 6 shinytest2 driver helpers
  - the `E2E_TIMEOUT` constant in `tests/testthat/helper-shinytest2.R`,
    **browser-free RED→GREEN** under strict TDD (resumed after the two
    planning sessions \#21/#30).
- **Helpers added:**
  `create_app_driver(app_dir, name, height=800, width=1200, ...)`,
  `navigate_to_tab(app, tab_label, fallback=NULL)` (sets `mainNavbar`,
  returns TRUE only if the tab reads back — catches a silent no-op nav),
  `get_html_safe`/`get_values_safe`/`click_element_safe`
  (`tryCatch`-guarded →
  `""`/[`list()`](https://rdrr.io/r/base/list.html)/`FALSE`),
  `navigate_to_menu_item` (provisional delegate to `navigate_to_tab`;
  finalized in 8d), and `E2E_TIMEOUT <- 30000L`.
- **Caught a latent bug in the plan’s §4 pseudo-code** (\[verify-first\]
  on the approved plan): the literal
  `create_app_driver(app_dir, name, ...)` hardcodes `height`/`width`
  then splices `...`, so the 2 `test-e2e-boundary-conditions.R` calls
  passing `height=`/`width=` would duplicate-crash `AppDriver$new`
  (*“formal argument ‘height’ matched by multiple actual arguments”* —
  verified that `AppDriver$new` has explicit `height`/`width` formals).
  Fixed by exposing them as named formals; the deviation was approved in
  the PRE-RED→RED phase gate.
- **Tests (browser-free, new file
  `tests/testthat/test_helper_shinytest2.R`):** 14 `test_that` / 32
  assertions using fake-AppDriver
  [`list()`](https://rdrr.io/r/base/list.html) stubs (throwing /
  recording-ok / silent-no-op) to discriminate the existence, signature,
  `*_safe` error, success, and read-back contracts — no Chrome needed
  (mirrors `test_create_test_app.R`). All RED at HEAD, GREEN after.
- **Verification:** full non-e2e suite `0 failed / 0 error`, **2154
  passed** (+32), e2e skipped (156), only the 5 pre-existing
  `modPyramid` warnings; `document()` zero `man/`/`NAMESPACE` delta;
  `tests/` is `.lintr`-excluded → lint-exempt. Phase 3E N/A (helpers
  live only in the test tree — the suite is the runtime). Learning \#31.
  **Next: Phase 8b** (boot-smoke tier + CI rewire — first browser run).

### 2026-06-05 — PLAN: Phase 8 sub-plan — enable the shinytest2 E2E harness (XARCH-1 / issue \#39) (Session 30)

- **Deliverable (planning, not implementation):**
  `docs/planning/phase8-e2e-harness-subplan.md` — a sub-plan for the
  conversion campaign’s Phase 8 (make the dormant shinytest2 browser E2E
  tier executable). The campaign’s second planning/architecture
  deliverable. No code written (FM \#18/#19).
- **Corrected the parent plan §9 Phase 8** via firsthand discovery
  (greps + R one-liners + a read-only workflow: 5-agent census of all 23
  E2E files + adversarial completeness-critic, 16 findings re-verified
  firsthand): the gap is **6 undefined helpers + 1 undefined constant**
  (`create_app_driver` with `...`→height/width,
  `navigate_to_tab(app, label, fallback=NULL)` \[109/137 calls 3-arg\],
  `get_html_safe`, `click_element_safe`, `navigate_to_menu_item`,
  `get_values_safe`, `E2E_TIMEOUT`), **not the “3 helpers”** the parent
  plan claimed — and Phase 8 is a **4-session mini-campaign (8a–8d)**,
  not one session.
- **Key findings:** the `navbarPage` renders ALL tabs’ static UI into
  the DOM at boot
  ([`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
  = 85 KB), so the suite’s dominant `grepl(keyword, "body")` checks
  **pass trivially once the app boots** → “harness runs green” ≠
  “validates behavior” (41 `expect_true(TRUE)` tautologies;
  `summary-statistics-module` navigates to the wrong tab in 7/8 tests
  yet passes). The `input` vs `dataInput` namespace mismatch is real but
  **inert** (polling helpers never called).
- **Owner decisions (`AskUserQuestion`):** (1) scope = **harness-enable
  (8a–8d)** → assertion-strengthening filed as a separate follow-on
  issue (“8e”); (2) CI gating = **scheduled + manual dispatch** (not
  per-PR), drop `continue-on-error`, keep fast unit CI as the per-PR
  gate.
- **Plan structure:** 8a helpers/constant (browser-free RED→GREEN) · 8b
  boot-smoke + CI rewire (first browser run) · 8c 15 shallow per-module
  files · 8d 5 interaction/menu files → close \#39. Each sub-phase has
  DONE + verify-command + session boundary; 23 files / 159 tests fully
  assigned. Updated parent plan §9 + `BACKLOG.md` to point at the
  sub-plan. Learning \#30.

### 2026-06-05 — Implement Phase 7 of the Shiny-module conversion: Input parity, focal-animal / LabKey pedigree build (Session 29)

- **Deliverable (implementation):** wired the modular **Data Input**
  module’s “Focal animals only; pedigree built from database” path so an
  uploaded focal-animal ID list builds a pedigree from the ONPRC LabKey
  EHR — bringing modular `modInput` to monolith parity (plan §9 Phase 7;
  monolith server.r:86-113). All in `R/modInput.R`, inside
  `observeEvent(input$getData)`:
  1.  **Server-side gap fixed.** The UI option already existed
      (`modInput.R:70` radio / `:111-116` `breederFile` / `:244`
      `activeFile`) but was **broken**: the focal-ID file was read *as a
      pedigree* by `readDataFile()` → a spurious “missing columns” QC
      error. Now, when `input$fileContent == "focalAnimals"`, the module
      calls `getFocalAnimalPed(file$datapath, sep)` to build the
      pedigree from the EHR, then feeds it into the existing
      `qcStudbook`/`runQcStudbook` machinery unchanged.
  2.  **DB-failure routing.** A `getLkDirectRelatives` connection
      failure makes `getFocalAnimalPed` return an `nprcgenekeeprErr`
      errorLst; the module routes it to `storedErrorLst()` (cleaned =
      NULL, early return) so the already-wired appServer dynamic **Error
      List** tab surfaces `failedDatabaseConnection` (“Database
      connection failed…”). No new renderer/appServer code.
- **Built more correctly than the monolith.** The monolith detects the
  error shape with `is.element("nprckeepErr", class(...))` — a **typo**
  (the real class is `nprcgenekeeprErr`), so its DB-failure branch never
  fired. The modular wiring uses `inherits(built, "nprcgenekeeprErr")`
  and drops the monolith’s dead bare-`NULL` branch (`getFocalAnimalPed`
  only returns a data.frame or an errorLst).
- **Strict TDD** (RED→GREEN→REFACTOR, all gated + 2 pre-RED
  author-decision `AskUserQuestion`s — the owner-consult fork
  \[mock-wire vs live-integration vs descope\] → **mock-wire/full
  parity**): 2 new tests in `tests/testthat/test_modInput.R` drive
  `testServer(modInputServer)` and mock the LabKey seam via
  `testthat::local_mocked_bindings(getLkDirectRelatives = …, .package = "nprcgenekeepr")`
  so the real `getFocalAnimalPed` body runs (no live EHR). Both **RED at
  HEAD** (happy: `cleaned` NULL because the focal file is read as a
  1-column pedigree; sad: `failedDatabaseConnection` never set),
  **GREEN** after. REFACTOR gated, skipped (minimal/idiomatic).
- **Verification:** `test_modInput.R` 0/0/0 (162 passed); full suite
  under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  `NOT_CRAN=true` = **0 failed / 0 error**, 0 non-e2e offenders, e2e
  skipped (156), only the 5 pre-existing `modPyramid` warnings (added
  zero), **2122 passed**. Lint **net-zero** on `R/modInput.R` (41 = 41,
  touched-file stash; explicit-`L` on the copied empty-warnings df),
  `document()` **zero** man/NAMESPACE delta, no macOS `* 2.*` dupes,
  **Phase-3E runtime smoke** —
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  binds + HTTP 200, served HTML renders
  `dataInput-breederFile`/`-fileContent`/`-getData` +
  `value="focalAnimals"`. **Verification is environmentally limited**
  (no live EHR): the mock covers everything on the module’s side of the
  ONPRC boundary; the live `getLkDirectRelatives` → `getDemographics`
  call is owner-verifiable only (stated, not skipped — not FM \#24).
  **No NEWS bullet** — input-wiring/display parity for the modular app,
  no analytical-pipeline numeric change (consistent with S22/S23/S25).

### 2026-06-04 — Implement Phase 6 of the Shiny-module conversion: Breeding Groups parity B (Session 27)

- **Deliverable (implementation):** brought the modular **Breeding Group
  Formation** module to monolith parity for seed-group pre-seeding and
  the previously-inert formation controls, all in
  `R/modBreedingGroups.R` (plan §9 Phase 6):
  1.  **Seed-group “current groups” widget** — a `seedGroups` checkbox
      reveals one per-group `textAreaInput` (`curGrp1..N`, count driven
      by `nGroups`). Their IDs build a length-`numGp` `currentGroups`
      list passed to
      [`groupAddAssign()`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
      in place of the hardcoded `list(character(0L))`, so groups can be
      pre-seeded (the monolith’s `textAreaWidget`/ `getCurrentGroups`,
      server.r:1019-1056).
  2.  **Exposed three previously-inert controls** the server already
      read (`modBreedingGroups.R` L201-203) but no UI declared, so they
      had silently defaulted: `minAge` (numericInput, value 1),
      `nIterations` (numericInput, value 10L), `withKinship` (checkbox).
      The new control ids match the server reads
      (`minAge`/`nIterations`/`withKinship`), **not** the monolith’s
      `gpIter`/`withKin`.
  3.  **Breeding-sim iteration default `1000L → 10L`** — the modular
      fallback was a 100× drift from the monolith’s `gpIter`
      (value=10L); now matches. This is a **real numeric change** to
      formed groups (the MIS sampler runs 100× fewer iterations by
      default).
- **Built robustly, not faithfully.** The monolith’s `getCurrentGroups`
  is doubly buggy (`seq_along(input$numGp)` is a length-1 scalar → only
  `curGrp1` is ever read; `vapply(...)` yields a matrix not a list); the
  modular widget uses `seq_len(numGp)` so every group’s textarea is
  honored (RED test asserts the 2nd seed group is honored).
  `length(currentGroups)` can never exceed `numGp` (built with
  `seq_len(numGp)` + truncation), so `groupAddAssign`’s length guard is
  unreachable.
- **More robust than the monolith — validate-and-block.** Seed IDs
  absent from the pedigree are rejected with a notification and
  formation aborts. Verified: a phantom seed otherwise survives into the
  group and **crashes** the Phase-5 Group Detail member view
  (`addSexAndAgeToGroup` → `getCurrentAge` on a length-0 birth). The
  monolith has only a partial `validate(need())` guard
  (server.r:1124-1133); the modular module previously had none.
- **Strict TDD** (RED→GREEN→REFACTOR, all gated + 4 pre-RED
  author-decision `AskUserQuestion`s): 7 new tests — 5 RED at HEAD (UI
  controls present; `nIterations` renders `value="10"`; seeding lands
  animals in their group; multi-group seeding \[proves the
  `curGrp1`-only bug not copied\]; phantom seed blocks formation) + 2
  green-at-HEAD coverage (blank-seed no-op; `withKinship=TRUE`→non-NULL
  kinship, green-at-HEAD because the server already reads
  `input$withKinship`). REFACTOR considered + skipped.
- **Verification:** `test_modBreedingGroups.R` 41 tests **0 failed / 0
  error / 0 warning**; full suite under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  `NOT_CRAN=true` **0 failed / 0 error**, e2e skipped (156), only the 5
  pre-existing `modPyramid` warnings. R6 validate-and-block guard
  **mutation-verified** (disabling it lets the phantom seed survive).
  Lint **net-zero** on `R/modBreedingGroups.R` (31 = 31, touched-file
  stash); `document()` zero man/NAMESPACE delta (`import(shiny)` covers
  the new controls); **Phase 3E runtime smoke** —
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  HTTP 200 with `seedGroups`/`minAge`/`nIterations` (value 10)/
  `withKinship`/`seedTextareas` rendered and the Phase-5 Group Detail
  tab intact.
- A read-only 5-agent discovery + adversarial-completeness recon
  (`wf_e8e1176c-320`) confirmed the parity surface and sharpened the
  dragon (the phantom-seed crash); every load-bearing claim was verified
  firsthand.
- **Files:** `R/modBreedingGroups.R`,
  `tests/testthat/test_modBreedingGroups.R`. **Next: Phase 7**
  (focal-animal / LabKey pedigree build — risk HIGH 🐉, owner consult at
  phase start; see plan §9).

### 2026-06-04 — Implement Phase 5 of the Shiny-module conversion: Breeding Groups parity A (Session 26)

- **Deliverable (implementation):** brought the modular **Breeding Group
  Formation** module to monolith parity for the per-group display/export
  half, all in `R/modBreedingGroups.R` (plan §9 Phase 5). A new **“Group
  Detail” tab** (additive — the existing all-groups “Groups” and
  “Statistics” tabs are untouched) adds:
  1.  **`viewGrp` group selector** (`selectInput`), populated when
      groups form (“Group 1..N”, with the last labelled “Unused” only
      when the appended unused-animals group is non-empty).
  2.  **Per-group annotated member view** —
      [`addSexAndAgeToGroup()`](https://github.com/rmsharp/nprcgenekeepr/reference/addSexAndAgeToGroup.md)
      → rounded age → columns “Ego ID”/“Sex”/“Age in Years”, ordered by
      ID (the monolith’s `bgGroupView`).
  3.  **Per-group kinship matrix view** —
      `filterKinMatrix(groupIds, kmat)` rounded to 6 dp (the monolith’s
      `bgGroupKinView`).
  4.  **`downloadGroup`** (member CSV, `na=""`/`row.names=FALSE`) and
      **`downloadGroupKin`** (kinship CSV, `na=""`/`row.names=TRUE`)
      handlers.
- **Dragon (threading the kinship matrix) discharged.** The kinship view
  computes each group’s submatrix from the module’s already-computed
  full `kmat` (now retained in `groupResults` with a `hasUnused` flag),
  NOT from `result$groupKin` (still NULL — `withKin` defaults FALSE
  until the Phase-6 `withKinship` control). This is **byte-identical**
  to the monolith’s `groupKin[[i]]` (each group’s members ⊆ candidates),
  and the group-**formation** compute path is **unchanged** — proven
  [`identical()`](https://rdrr.io/r/base/identical.html) across three
  `set.seed`ed scenarios (nGroups 3/4/1) vs a pre-change reference
  (`groups`/`score`/`unassigned`/`nGroups`). Display/download only.
- **More robust than the monolith.** Both views clamp `viewGrp` via
  `withinIntegerRange(., 1, length(breedingGroups()))` (the monolith
  clamps the member view to the *requested* `numGp` and leaves the
  kinship view unclamped — a latent out-of-range bug). The
  selector-populating `observe` guards on
  `length(breedingGroups()) >= 1L` (an empty result is a zero-length
  list, which `req()` treats as truthy — the naive guard warned on the
  degenerate harem-with-no-eligible-sires case).
- **TDD:** 5 new tests in `tests/testthat/test_modBreedingGroups.R` (UI
  structure; member-download content; kinship-download content +
  `filterKinMatrix`-equivalence; selector switches group; out-of-range
  clamp) — all red at HEAD, green after. Founders-with-birth fixture
  gives a deterministic kinship submatrix (0.5 diagonal / 0
  off-diagonal); assertions key on the *actual* formed group. Full suite
  under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  `NOT_CRAN=true`: **0 failed / 0 error**, 156 e2e skipped, 5
  pre-existing `modPyramid` warnings, 2264 passed. Lint net-zero on
  `R/modBreedingGroups.R` (31 = 31); `document()` zero man/NAMESPACE
  delta; **Phase 3E runtime smoke** —
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  HTTP 200 with the Group Detail tab + selector + downloads rendered.
- **Housekeeping:** removed two stray untracked macOS “filename 2”
  duplicates (`R/modBreedingGroups 2.R`,
  `tests/testthat/test_modBreedingGroups 2.R`) that had appeared
  mid-session and were doubling the generated `.Rd` docs and
  double-running the test file (moved aside to `/tmp`, not in git).
- **No `NEWS.md` bullet** — this is display/download parity for the
  not-yet-canonical modular app with no change to the analytical
  pipeline (NEWS is reserved for numeric changes + the Phase 9
  deprecation). Plan §9 Phase 5 → DONE; next is Phase 6 (seed-groups +
  inert controls).

### 2026-06-04 — Implement Phase 4 of the Shiny-module conversion: genotype file merge in modInput (Session 25)

- **Deliverable (implementation):** brought the modular **Data Input**
  module to monolith parity for the **separate pedigree/genotype**
  upload path, all in `R/modInput.R` (plan §9 Phase 4).
  1.  **Genotype file merge.** Inside `observeEvent(input$getData)`,
      before the `qcStudbook`/ `runQcStudbook` calls, the
      `separatePedGenoFile` path now reads `input$genotypeFile` via
      [`getGenotypes()`](https://github.com/rmsharp/nprcgenekeepr/reference/getGenotypes.md),
      validates with
      [`checkGenotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkGenotypeFile.md)
      (degrading to no-merge on warning/error, mirroring the monolith),
      and merges it into the raw pedigree via
      [`addGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/addGenotype.md).
      The integer `first`/`second` columns then ride the cleaned
      studbook into
      [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
      (via
      [`getGVGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/getGVGenotype.md)/[`hasGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/hasGenotype.md)),
      so genome-uniqueness uses the real genotypes. Previously
      `activeFile()` silently dropped `input$genotypeFile`.
  2.  **`genotypeData()` populated.** Added
      `genotype = getGVGenotype(qcResult$cleaned)` to the module’s
      stored results, so the `genotypeData()` reactive (formerly always
      NULL) returns the id/first/second extract (NULL when no genotype,
      preserving the prior contract).
  3.  **More robust than the monolith.** The merge is **NULL-guarded** —
      `addGenotype(ped, NULL)` crashes
      (`"'by' must specify a uniquely valid column"`), a latent
      unguarded crash in the monolith; a malformed genotype file now
      degrades to no-merge instead of crashing the QC run.

  - **Common-mode unchanged (proven at parity):** neither app
    integer-codes string allele names for a combined ped+genotype file,
    so common-mode genotypes never reach `reportGV`’s gene-drop in
    either app — adding `addGenotype` to the common branch would be a
    behavior change beyond parity. Phase 4 touches only the
    `separatePedGenoFile` path.
- **Tests:** 2 new tests in `tests/testthat/test_modInput_qcStudbook.R`
  — a discriminating happy-path (upload the shipped
  `obfuscated_rhesus_mhc_ped.csv` + `…_breeder_genotypes.csv`; assert
  the cleaned studbook gains `first`/`second`,
  [`hasGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/hasGenotype.md)
  TRUE, `genotypeData()` populated) and a malformed-genotype
  graceful-degradation test (NULL-guard mutation-verified).
- **Method (TDD, ultracode):** RED→GREEN→REFACTOR with all gates + 2
  pre-RED author decisions via `AskUserQuestion` (populate
  `genotypeData()` too; reader =
  [`getGenotypes()`](https://github.com/rmsharp/nprcgenekeepr/reference/getGenotypes.md));
  a 5-agent read-only discovery + adversarial-completeness recon
  (`wf_37c91d78-d24`) settled the
  common-mode/NULL-crash/testServer-harness questions, all verified
  firsthand.
- **Verification:** full suite under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  `NOT_CRAN=true` = 0 failed / 0 error, 0 non-e2e offenders, 2085
  passed, e2e skipped (156); lint net-zero on `R/modInput.R` (41 = 41);
  `devtools::document()` no man/NAMESPACE delta; **Phase 3E runtime
  smoke**
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  binds + HTTP 200 (modInput mounts with the `genotypeFile` input). No
  NEWS bullet (modular app not yet canonical; no analytical-pipeline
  numeric change).
- **Files:** `R/modInput.R`,
  `tests/testthat/test_modInput_qcStudbook.R`. **Next: Phase 5**
  (Breeding Groups downloads + per-group kinship + group selector).

### 2026-06-04 — Implement Phase 3 of the Shiny-module conversion: GVA genome-uniqueness threshold + subset/filter export (Session 24)

- **Deliverable (implementation):** brought the modular **Genetic Value
  Analysis** tab to monolith parity across four verified gaps, all in
  `R/modGeneticValue.R` (plan §9 Phase 3).
  1.  **Genome-uniqueness threshold control.** Added a
      `selectInput(ns("threshold"))` (choices 1–5, default 4) threaded
      via a new `guThreshold()` reactive into
      [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md),
      replacing the hard-coded `guThresh = 1L`. This changes default
      genome-uniqueness output for the modular app (intended parity —
      the monolith default is the threaded integer 4).
  2.  **Subset/filter view.** Added a `viewIds` textarea + “Filter View”
      button + a `gvaView()` reactive that filters the report by entered
      IDs via the exported
      [`filterReport()`](https://github.com/rmsharp/nprcgenekeepr/reference/filterReport.md)
      (monolith `gvaView`/`filterReport`, server.r:462-477); the
      rankings table now reflects the filter.
  3.  **Export Subset.** Added `downloadGVASubset` (writes the filtered
      view, `na=""`); relabeled the existing `downloadRankings`
      “Download” → “Export All” to pair with it.
  4.  **Gene-drop iterations default** 5000 → 1000 (monolith parity);
      **removed** the inert `minAge` slider (never read; no monolith GVA
      counterpart).
- **Author decisions (USER, via `AskUserQuestion`):** direct threshold
  mapping (choices 1–5, default 4 — drops the monolith’s confusing
  label-offset while keeping the threaded integer 4); iterations default
  1000; remove minAge only (the 2 sibling inert checkboxes
  `calcGenomeUniqueness`/`calcMeanKinship` deferred); whole Phase 3 in
  one session.
- **TDD:** strict RED→GREEN→REFACTOR with phase gates (each via
  `AskUserQuestion`). 6 new discriminating tests in
  `tests/testthat/test_modGeneticValue.R`; minAge removal in REFACTOR
  deleted 2 tautological tests + 3 assertion lines (no real coverage
  lost — they only echoed the inert input back).
- **Discriminating-RED traps (verify-first, Learnings \#15/#20):** (a)
  no existing test pinned the threshold, so all pass on the buggy
  `guThresh=1L` — the RED keys on the threaded integer via an internal
  `guThreshold()` reactive (empirically guThresh 1 vs 4 changes every
  `gu` row); (b) the flipped iterations assertion `grepl("1000")` first
  PASSED on the bug because `max="10000"` contains “1000” — re-keyed on
  the rendered `value="1000"` attribute.
- **Recon:** a read-only discovery + adversarial-completeness workflow
  (`wf_a1f5fdb4-b8e`, 4 agents) re-derived the parity surface and
  flagged three implementation blockers, all verified firsthand: `%||%`
  is not portable (not in shiny/this package; base only since R 4.4) →
  used an explicit `is.null` guard; `stri_trim` is not the imported
  symbol (`stri_trim_both` is) → used base `trimws`; `import(shiny)`
  (NAMESPACE:168) covers the new `selectInput`/`textAreaInput`.
- **Verification:** `test_modGeneticValue.R` 53/53; full suite under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  `NOT_CRAN=true` = 0 failed / 0 error, 0 non-e2e offenders, e2e skipped
  (156), 5 pre-existing `modPyramid` warnings; lint net-zero on
  `R/modGeneticValue.R` (HEAD 23 = NOW 23, via touched-file stash);
  `document()` no man/NAMESPACE delta; Phase 3E runtime smoke —
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  binds + HTTP 200, the new threshold/viewIds/Export-Subset controls
  render and the minAge slider is gone. NEWS bullet added (the plan
  reserves NEWS for this numeric change). Commit `280d1df0` (impl) + the
  `docs:` close-out.

### 2026-06-03 — Implement Phase 2 of the Shiny-module conversion: wire the GvAndBgDesc description tab (Session 23)

- **Deliverable (implementation):** mounted the already-built
  `modGvAndBgDesc` module as a navbar tab so the modular app gains the
  monolith’s **Genetic Value Analysis and Breeding Group Description**
  tab (plan §9 Phase 2).
  - `R/appUI.R`: a `tabPanel` after “Breeding Groups” (monolith-parity
    placement, per `inst/application/ui.r`) calling
    `modGvAndBgDescUI("gvAndBgDesc")`.
  - `R/appServer.R`: `modGvAndBgDescServer("gvAndBgDesc")`
    (informational module — returns NULL, no reactive state).
- **TDD:** strict RED→GREEN (REFACTOR skipped — author decision; the
  change is minimal/idiomatic). Two new integration tests in
  `tests/testthat/test_modGvAndBgDesc.R`.
- **Discriminating-RED gotcha (verify-first, Learning \#15/#20/#23):**
  the module’s H3 heading (“Genetic Value Analysis and Breeding Group
  Description”) is NOT a discriminating marker — `genetic_value.html`,
  already mounted by `modGeneticValue`, contains that exact phrase, so a
  naive heading assertion is a tautology that passes at HEAD. The
  discriminating marker is `gvAndBgDesc.html`’s own body text
  (`"kinship coefficients"` / `"genetic value analysis proceeds"`),
  unique among the mounted guidance HTML and absent from
  [`appUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
  at HEAD. (`modGvAndBgDescUI` does not call `NS()`, so there is no
  namespaced container to assert on — the included content IS the mount
  marker.)
- **Verification:** `test_modGvAndBgDesc.R` 10/10,
  `test_appServer_dynamicTabs.R` 23/23 (the dynamic insert/remove-tab
  interaction is unaffected — the new tab is far from the “Input” insert
  target); full suite under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  `NOT_CRAN=true` = 0 failed / 0 error, 2073 passed (+2), e2e skipped
  (156), 5 pre-existing `modPyramid` warnings; lint net-zero (appUI 0=0,
  appServer 18=18); `document()` no man/NAMESPACE delta; Phase 3E
  runtime smoke —
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  binds + HTTP 200. Commit `ef6a9f4c`.
- **NEWS deferred** to the Phase 9 canonical switch (modular app not yet
  canonical).

### 2026-06-03 — Implement Phase 1 of the Shiny-module conversion: Summary Statistics tab parity (Session 22)

- **Deliverable (implementation):** brought the modular app’s **Summary
  Statistics tab** (`R/modSummaryStats.R`) to legacy-monolith parity
  across four verified gaps (plan §9 Phase 1):
  1.  **Z-score plots** now render.
      [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
      emits the column `zScores` (plural), but `modSummaryStats` checked
      `zScore` (singular) — so the z-score histogram + boxplot were
      always NULL (“Z-scores not available”). Fixed with a dual-name
      lookup (prefer `zScores`, fall back to `zScore`), matching
      `modGeneticValue`’s existing `indivMeanKin`/`meanKinship` idiom.
      (Real column name confirmed empirically before the fix.)
  2.  **Mean-Kinship / Genome-Uniqueness quartile tables**
      (Min/1st-Q/Mean/Median/3rd-Q/Max) rendered on the Summary tab
      (monolith `server.r:545-630`); previously only 3 scalars showed.
  3.  **Founder table** (Known/Female/Male counts + FE + FG) rendered on
      the Summary tab (monolith `server.r:558-570`) by threading
      `modGeneticValue`’s `founderStats` reactive into
      `modSummaryStatsServer` (new `founderStats` param; wired in
      `R/appServer.R`).
  4.  **Kinship-matrix download** fixed: was a dead button (`req()` on a
      NULL `kinshipMatrix` arg with `appServer.R` passing `NULL`); now
      writes the module’s internal `getKinshipMatrix()`.
- **TDD:** strict RED→GREEN (REFACTOR skipped — author decision). New
  discriminating tests in `tests/testthat/test_modSummaryStats_parity.R`
  (6 tests / 22 expectations); the z-score test uses ONLY the real
  `zScores` column so it fails on the singular-name bug — a pre-existing
  `_ggplots` test passed on the bug because its fixture injects both
  names (Learning \#15/#20).
- **Author decisions (`AskUserQuestion`):** founder table → add to
  Summary tab (keep GVA subtab); kinship download → use the module’s
  internal kinship (smallest change, no relationship-basis change —
  avoided the plan’s “thread reportGV kinship” dragon).
- **Verification:** full suite under
  [`pkgload::load_all`](https://pkgload.r-lib.org/reference/load_all.html) +
  `NOT_CRAN=true` = 0 failed / 0 error, 2071 passed (+22), e2e skipped;
  lint net-zero (modSummaryStats 60=60, appServer 18=18);
  `devtools::document()` (only `man/modSummaryStatsServer.Rd`); runtime
  smoke —
  [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
  binds + HTTP 200. NEWS deferred to the Phase 9 canonical switch
  (modular app not yet canonical).
- **Files:** `R/modSummaryStats.R`, `R/appServer.R`,
  `man/modSummaryStatsServer.Rd`,
  `tests/testthat/test_modSummaryStats_parity.R`. Plan:
  `docs/planning/shiny-module-conversion-plan.md` §9 Phase 1.

### 2026-06-02 — PLAN: complete the Shiny-module conversion (XARCH-1 / issue \#27) (Session 21)

- **Deliverable (planning, not implementation):**
  `docs/planning/shiny-module-conversion-plan.md` — a 9-phase,
  vertical-slice plan to declare the modular app
  (`runModularApp`/`appUI`/ `appServer`/`mod*`) canonical, reach feature
  parity with the legacy monolith (`inst/application/`), enable the
  shinytest2 E2E tier, then delete the monolith and make
  [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
  a
  [`lifecycle::deprecate_soft`](https://lifecycle.r-lib.org/reference/deprecate_soft.html)
  alias. Followed the ARCHITECTURE workstream + the SESSION_RUNNER
  Planning protocol (evidence-based grep inventory, per-phase
  done-criteria, vertical slices). The project’s first
  planning/architecture deliverable.
- **Method:** a read-only 8-mapper discovery workflow + firsthand
  verification of every load-bearing claim + a 3-agent
  completeness-critic that caught 4 real parity gaps the single-pass
  synthesis missed (dead kinship-download button; dropped MK/GU quartile
  tables; FE/FG founder-table placement; a 100× breeding-`gpIter`
  default drift).
- **Author scope decisions (via `AskUserQuestion`):** full conversion
  (parity + E2E + retire); exclude ORIP/Settings (parity = match the
  monolith); re-expose the GU-threshold selector (default 4).
- **Key findings (reframe the audit):** the modular app is far more
  complete than `TECH_DEBT_AUDIT_2026-05-30.md` implied; the audit’s “do
  XARCH-3/4/7 before XARCH-1” sequencing is moot (verified); the E2E
  suite is unwritten scaffolding (its driver helpers are defined
  nowhere) — this is the real scope of issue \#39; issue \#34
  (“integrate qcStudbook in modInput”) is stale (already integrated). No
  code changed this session.
- **Next:** implement **Phase 1 only** (Summary Statistics tab parity)
  under strict TDD.

### 2026-06-02 — Fix vacuous “no potential parent” assertion in `test_getPotentialParents.R` (Session 20)

- **Defect (found Session 4, fixed now):** the test “works with records
  with no potential parent” pushed BRI2MW’s birth to 1950 into a local
  `ped` but then asserted the old top-level `potentialParents[[1L]]$id`
  from the *unmodified* fixture — a tautology already covered by the
  first test that never inspected `ped` and verified nothing about its
  named scenario (copy/paste slip).
- **Fix (REFACTOR-only under strict TDD; no production change):**
  replace the assertion with a discriminating one. BRI2MW is a
  from-center founder with both parents unknown that normally appears in
  the output; with its birth at 1950 its breeding-age candidate set is
  empty, so `getPotentialParents` correctly drops it via the
  no-breeding-age-candidate skip. The test now asserts BRI2MW is present
  in the unmodified fixture (precondition), absent from the scenario
  result, and that the result has exactly one fewer entry (50 → 49).
- **Why REFACTOR-only:** `getPotentialParents` is already correct, so a
  correct assertion is green-on-arrival; strict TDD forbids declaring
  RED on a passing test, and forcing a fail with a wrong expectation
  would be a synthetic RED (Learning \#18c). Rigor instead came from a
  mutation check: disabling the skip makes both new assertions fail,
  proving the test discriminates (the old assertion passed against that
  same mutant).
- **Verification:** full suite under `load_all` + `NOT_CRAN=true`: **0
  failed / 0 error**, zero non-e2e offenders, **2049 passed** (+2 vs
  Session 19), 5 pre-existing `modPyramid` warnings, e2e files skipped.
  Commit `6049445d`.

### 2026-06-02 — Resolve the E2E test-infra debt: add `create_test_app()` with an opt-in gate (Session 19)

- **Root cause:** the 23 `test-app-*`/`test-e2e-*` files call
  `create_test_app()` at **154 sites**, but the helper was never defined
  (it never existed in git history; the e2e scaffolding landed in
  `7da01afe` without it). Result: **154 suite ERRORS** under
  `devtools::test()`/CI (`NOT_CRAN=true`), masked only by
  `skip_on_cran()` under a bare
  [`testthat::test_dir()`](https://testthat.r-lib.org/reference/test_dir.html)
  — a suite that was clean or broken depending on the runner.
- **Fix (strict TDD, RED→GREEN; no REFACTOR needed):** define
  `create_test_app()` in `tests/testthat/helper-shinytest2.R`. It
  **skips** the calling test unless `NPRC_RUN_E2E=true`, and when opted
  in returns the existing `inst/shinytest` app dir (`app.R` =
  `shinyApp(appUI(), appServer)`) for
  [`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html).
  The browser E2E suite stays **opt-in** (slow, needs Chrome, and
  depends on the modular-vs-monolith consolidation, XARCH-1) but is now
  one env var away from running; the default suite is honestly clean
  (154 errors → skips).
- **Discovery:** the prior E2E effort was ~90% complete, not lost
  scaffolding — the app is instrumented (`data-ready.js` + all six
  modules signal readiness), 159 `test_that` blocks + wait/upload
  helpers + `.github/workflows/shinytest2.yaml` CI all exist; only
  `create_test_app()` was missing. Captured the remaining campaign
  (validate the 159 tests; wire CI; sequence with XARCH-1) as **GitHub
  issue \#39** so the plan can’t be lost again.
- **Verification:** new browser-free
  `tests/testthat/test_create_test_app.R` (opt-in returns app dir; gate
  raises a `skip` condition). Full suite under `load_all` +
  `NOT_CRAN=true`: **0 failed / 0 error**, 154 e2e errors → skips, zero
  non-e2e offenders, 2047 passed, 5 pre-existing `modPyramid` warnings.
  Lint net-zero (helper-shinytest2.R = 0 in-place). No `document()`
  (test helper, not package API).
- Commits: `a1ee8497` (test: helper + tests), + this `docs:` close-out.

### 2026-06-01 — Document the Mendelian ½ factor; drop the dead UID.founders block (NEW-22/NEW-30, Session 18)

- **NEW-22 (Mendelian ½ “hardcoded in 5 places”):** Session 17’s
  NEW-13/NEW-23 consolidation already removed the
  `calcFE`/`calcFG`/`calcFEFG` triplication, so the remaining `/ 2L`
  sites are *distinct* Mendelian formulas (parental- contribution
  average, parental-kinship average, self-kinship `(1+f)/2`, founder
  self-kinship init), **not** duplicated logic. Per the package author’s
  decision the self-documenting literals are kept and a one-line
  Mendelian-½ comment is added at each site in
  `calcFounderContributions.R` and `kinship.R`; **no** named constant —
  one would over-couple distinct formulas across the GV compute and the
  kinship engine.
- **NEW-30 (dead/unused computed variables):** removed the
  genuinely-dead `## UID.founders <- …` commented block (and its
  `# nolint: commented_code_linter` wrapper) from
  `calcFounderContributions.R`. **Kept** `founderMatrix <- NULL` — it is
  an intentional memory free (drops the founders×founders identity block
  before the generation loop), not a dead variable as the audit claimed
  — now annotated.
- Comment + dead-code only; **zero behavior change**, proven
  byte-[`identical()`](https://rdrr.io/r/base/identical.html) on
  `calcFE`/`calcFG`/`calcFEFG` (character+factor),
  `calcFounderContributions` `$p` and `$ped`,
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  dense+sparse, and the full `set.seed(42)`
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  object. Full suite under `load_all`: 0 failed / 0 error, 2001 passed;
  lint net-zero on both files; `document()` produced no man/NAMESPACE
  change. No `NEWS.md` entry — the change is internal-only with no
  user-facing effect. Commit `04115d97`.

### 2026-06-01 — Consolidate calcFE/calcFG/calcFEFG founder-contribution code (NEW-13/NEW-23, Session 17)

- The founder-contribution algorithm that
  [`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
  [`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
  and
  [`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md)
  shared near-verbatim (~45 lines each), together with the triplicated
  Session-7 partial-parentage
  [`stop()`](https://rdrr.io/r/base/stop.html) guard, now lives once in
  a new `@noRd` helper `calcFounderContributions(ped, caller)` that
  returns `list(p, ped)`. The three functions become thin wrappers (net
  -118 lines).
- Behaviour-preserving with no public-API change: signatures, return
  types, and the per-function error messages are byte-identical, and
  [`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md)
  stays gene-drop-free. Proven
  [`identical()`](https://rdrr.io/r/base/identical.html) on FE/FG over
  lacy1989Ped (character AND factor), the full `set.seed(42)`
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  object (the live `calcFEFG` caller), and all three guard messages;
  independently re-verified by a 3-agent adversarial equivalence
  workflow (static body-diff, 20 empirical OLD-vs-NEW edge tests,
  contract/guard/namespace) with 0 divergences.
- Full suite under `load_all`: 0 failed / 0 error, 2001 passed (+10
  helper assertions). Lint net-zero; no man/NAMESPACE churn (`@noRd`).
- Out of scope (sibling audit items, not opted into): NEW-22 (hardcoded
  Mendelian 1/2), NEW-30 (dead vars - the `UID.founders` comment block
  was relocated intact), NEW-29/61 (founder-definition `^U` handling).
- Done under strict TDD (RED-\>GREEN-\>REFACTOR). Commits: `022afc8b`
  (helper + tests, GREEN), `2b27f4c3` (thin wrappers, REFACTOR), plus
  this close-out.

### 2026-06-01 — Extract getFounders()/isFounder() founder-detection helpers (PED-1/NEW-17, Session 16)

- Added two exported helper functions that define the founder predicate
  (an animal whose sire and dam are both unknown) in a single place:
  `isFounder(ped)` returns the logical mask
  `is.na(ped$sire) & is.na(ped$dam)`, and `getFounders(ped)` returns
  `ped$id[isFounder(ped)]`.
- Replaced the inline founder-detection idiom at 12 call sites across 9
  files:
  [`getFounders()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFounders.md)
  in
  [`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
  [`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md),
  [`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
  [`calcRetention()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md),
  `orderReport()`, and
  [`removeUninformativeFounders()`](https://github.com/rmsharp/nprcgenekeepr/reference/removeUninformativeFounders.md);
  [`isFounder()`](https://github.com/rmsharp/nprcgenekeepr/reference/isFounder.md)
  for the founder-row subset in
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md),
  the male/female founder exports in `modSummaryStats` (×2), and the
  founder counts in `modORIPReporting` (×4).
  [`findPedigreeNumber()`](https://github.com/rmsharp/nprcgenekeepr/reference/findPedigreeNumber.md)
  was left as-is: it operates on bare `id`/`sire`/`dam` vectors with no
  `ped` object, so the `ped`-argument helpers do not fit it.
  [`calcRetention()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcRetention.md)’s
  adjacent `descendants` line was deliberately untouched — it alone
  filters by `ped$population`.
- Behaviour-preserving by construction and verified empirically: every
  refactored output proven
  [`identical()`](https://rdrr.io/r/base/identical.html) to a
  pre-refactor reference — the four `calc*` functions on the lacy1989
  fixture, the full seeded
  [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
  output, and the Shiny-module expressions on the qcPed fixture. Full
  suite 0 failed / 0 error / 1991 passed; lint net-zero on all 11 files
  (the two new files and the seven compute files are lint-free; the two
  Shiny modules carry only pre-existing style debt, count unchanged
  between HEAD~1 and HEAD).
- An independent 4-angle completeness sweep (read-only workflow)
  re-derived the founder-detection inventory and converged on a single
  remaining inline site — `findPedigreeNumber.R:35`, the intentional
  exclusion — confirming no `R/` site was missed.
- Done under strict TDD (RED→GREEN→REFACTOR). Commits: `2758ffe6`
  (helpers + tests + NAMESPACE + man), `77f13d51` (calc\* +
  orderReport), `a95828d6` (reportGV + removeUninformativeFounders +
  Shiny modules), plus this close-out.

### 2026-06-01 — Fix lower-quartile mislabel + bind-once refactor in summarizeKinshipValues (NEW-16, Session 15)

- Fixed NEW-16:
  [`summarizeKinshipValues()`](https://github.com/rmsharp/nprcgenekeepr/reference/summarizeKinshipValues.md)
  reported the `secondQuartile` column as `fivenum()[1]` (the minimum)
  instead of `fivenum()[2]` (the lower hinge), so the lower-quartile
  column silently duplicated `min`. It affected 5 of 153 rows in the
  documented example pipeline. As with NEW-45, the audit’s mechanism and
  prescribed fix were both correct; the pre-existing test happened to
  pass on the buggy output (its row-10 lower hinge equals that row’s
  min), so a new synthetic test (`numbers = 1:5`, where the lower hinge
  2 ≠ the min 1) was added to detect the mislabel. Fixed by `tukeys[1L]`
  → `tukeys[2L]` (`R/summarizeKinshipValues.R:106`); `thirdQuartile`
  (the upper hinge) was already correct.
- Refactored the O(n²) `rbind`-in-loop into a preallocated row list
  bound once with `do.call(rbind, …)` (O(n)). Proven
  behaviour-preserving:
  [`identical()`](https://rdrr.io/r/base/identical.html) output on the
  seeded example pipeline, the synthetic input, and the
  all-skipped/empty case (which still returns an empty
  [`data.frame()`](https://rdrr.io/r/base/data.frame.html)).
- Decision (author): `R/makeGeneticDiversityDashboard.R` (NEW-20) is
  **retained** as early-development work rather than deleted. It is
  already excluded from the package build via `.Rbuildignore` and
  defines no live function, so NEW-20 is closed as won’t-delete (not the
  audit’s “delete dead code”). A whitespace-only comment realignment in
  that file was committed first (`926f4606`).

### 2026-06-01 — Reject duplicate animal IDs in geneDrop (NEW-46, Session 14)

- Fixed NEW-46:
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
  crashed with the cryptic base-R error “duplicate ‘row.names’ are not
  allowed” (at `rownames(ped) <- ids`, `geneDrop.R:97`) when given
  duplicate animal ids — before any allele logic ran. The audit’s
  “parent lookup by rowname; duplicate ids → wrong values” was
  empirically a hard crash, not silent corruption, and at the rownames
  assignment rather than the lookup (the NEW-48 pattern: audit mechanism
  wrong).
- Added an upfront guard (alongside the NEW-45 period guard) that
  rejects duplicate ids with a clear, actionable message (“animal IDs
  must be unique; duplicated id(s): …”), consistent with
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
  (“All id values must be unique”) and
  [`removeDuplicates()`](https://github.com/rmsharp/nprcgenekeepr/reference/removeDuplicates.md).
  The unique-id invariant is a domain rule.
- Reachability was
  direct-[`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)-call
  only: the canonical `qcStudbook → reportGV → geneDrop` path is doubly
  masked —
  [`removeDuplicates()`](https://github.com/rmsharp/nprcgenekeepr/reference/removeDuplicates.md)
  (qcStudbook) and
  [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)’s
  own unique-id guard (called in `reportGV` before `geneDrop`). So no
  reportGV change was needed.
- Contract-preserving: today’s behavior is already a crash, so no
  currently-succeeding call changes — only the diagnostic improves
  (Learning \#8b).
- Strict TDD (RED→GREEN→REFACTOR). Full suite 0 failed / 0 error / 1971
  passed; lint net-zero; `man/geneDrop.Rd` regenerated; no NAMESPACE
  change.

### 2026-05-31 — Enforce “no period in IDs” rule (NEW-45, Session 13)

- Fixed NEW-45:
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
  silently corrupted allele assignment for any `id` containing a period
  (“.”) — it rebuilt the id/parent columns by splitting flattened
  data.frame rownames on “.”, so a period-bearing id was truncated and
  lost its sire/dam distinction. The documented ID domain forbids “.”
  (`inst/extdata/ui_guidance/input_format.html`: id/sire/dam are
  “Alphanumeric characters (no symbols)”).
- Enforced the rule rather than re-engineering `geneDrop` to support
  periods. New internal `hasInvalidIdChar()` defines the rule once and
  is used by:
  [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  (rejects period-bearing `id`/`sire`/`dam` at data input —
  [`stop()`](https://rdrr.io/r/base/stop.html) in default mode,
  `errorLst$invalidIdChars` when `reportErrors = TRUE`) and
  [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
  (defense-in-depth [`stop()`](https://rdrr.io/r/base/stop.html) for
  callers that bypass `qcStudbook`, e.g. the genetic-value Shiny
  module). Auto-generated IDs (`addUIds` `U####`, `obfuscateId`) are
  already period-free; locked with tests.
- Documented the feature with rationale (periods break across software
  environments) in roxygen, the live `input_format.html` spec, and
  `NEWS`.
- Strict TDD (RED→GREEN→REFACTOR). Full suite 0 failed / 0 error / 1961
  passed; lint 0. Code commit `5e228bd9` (fix) + docs commit.

### 2026-05-31 — Methodology framework update (Session 10)

- Updated the embedded methodology to canonical `rmsharp/methodology`
  `f32d780`: synced `SESSION_RUNNER.md`, `SAFEGUARDS.md`, and
  `methodology_dashboard.py` byte-identical to canonical via `bin/sync`.
- Refreshed `docs/methodology/` framework docs
  (`ITERATIVE_METHODOLOGY.md`, `HOW_TO_USE.md`, `README.md`) and
  workstreams; added 4 new upstream workstreams
  (`INHERITED_CODEBASE_FAMILIARIZATION_CAMPAIGN`,
  `RESEARCH_DOCUMENTATION_WORKSTREAM`,
  `RESEARCH_EXHAUSTIVE_VERIFICATION_CAMPAIGN`, `TEMPLATE_CAMPAIGN`).
- Relocated the 10 project Learnings (from `SESSION_RUNNER.md`) and the
  R-package build-equivalent (from `SAFEGUARDS.md`) into `CLAUDE.md`’s
  “Project-Specific Methodology Adaptations” and “Build / Test / Verify”
  sections, so the synced files stay byte-identical to canonical.
- Created `CHANGELOG.md`, `ROADMAP.md`, `RECOMMENDED_SKILLS.md`; split
  `BACKLOG.md` (completed work → here; feature inventory →
  `ROADMAP.md`).

### 2026-05-30 – 2026-05-31 — PED/GV audit-fix campaign (Sessions 1–9, strict TDD)

- **Audits produced:** `TECH_DEBT_AUDIT_2026-05-30.md` (Session 1,
  read-only) and `PED_GV_AUDIT_2026-05-30.md` (Session 2 — re-audit of
  the PED & GV clusters; 61 confirmed / 2 refuted findings).
- **Correctness bugs fixed** (each test-first under strict TDD, with
  regression tests):
  - NEW-15 — `countKinshipValues` wrong loop index corrupted accumulated
    kinship counts (the audit’s only HIGH-severity bug). `b05133ca`
  - NEW-34 — `getPotentialParents` unbound-`j` crash when `pUnknown` is
    empty. `dc695a3b`
  - NEW-40 — `findGeneration` returned silent NA generations on cyclic
    pedigrees; now warns at the choke point. `ea5d28fa`
  - NEW-37 — `correctParentSex` silently overwrote recorded H/U parent
    sex to M/F. `6b0ae333`
  - NEW-48 — `calcFEFG`/`calcFE`/`calcFG` crashed on partial parentage;
    now a clear [`stop()`](https://rdrr.io/r/base/stop.html). `19350559`
  - NEW-25 — `getProportionLow` crashed on empty input; now a clear
    [`stop()`](https://rdrr.io/r/base/stop.html). `587ba042`
  - NEW-52 — `cumulateSimKinships` standard deviation undefined for
    n\<2: n=1 → NA matrix + warning, n\<1 → clear
    [`stop()`](https://rdrr.io/r/base/stop.html). (Audit’s
    catastrophic-cancellation mechanism empirically disproved as
    unreachable for dyadic-rational kinship values.) `e3c7e8b3`

## Earlier work (pre-methodology, migrated from BACKLOG.md history)

- Pyramid plot module update.
- Lint cleanup and unused-code removal.
- Changed package name to mprcgenekeepr for side-by-side development.
- Initial Shiny module commit structure.
