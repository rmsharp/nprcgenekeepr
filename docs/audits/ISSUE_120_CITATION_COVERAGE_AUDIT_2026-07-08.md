# Issue #120 — Citation Coverage Audit (computed quantities / statistics / estimators)

**Issue:** #120 ("Audit: are there reference citations for each calculation in the package?")
**Date:** 2026-07-08 (Session 315)
**Scope gate (owner):** Broad — classify all 50 candidate files (the issue's 8 named
items plus every other `R/calc*.R`, kinship, demographic, and breeding-group-formation
file), not just the 8 the issue body names by name.
**Status:** Assessment complete. This report is the deliverable; **no code or docs were
changed in this session** — fixes are a separate, owner-gated follow-on (per
AUDIT_WORKSTREAM, the audit and the fix are different sessions).

---

## 1. Audit Summary

- **Criteria.** For every function that computes an independent, formula-bearing
  statistic or estimator (not a data-reshaping/plumbing helper), does its documentation
  cite a source (paper, textbook, or named algorithm) **somewhere**, and is that citation
  **consistent** across the package's parallel documentation surfaces: roxygen
  `@references`, the built vignette manual (`vignettes/manual_components/*.Rmd`, only the
  files actually `child`-included by `vignettes/a3manual.Rmd`), and the in-app UI guidance
  pages (`inst/extdata/ui_guidance/*.html`)?
- **Method.** (a) Firsthand read of every candidate file's roxygen block (title,
  `@details`, `@references`) via `grep "^#'"`; (b) firsthand read of all 8
  `inst/extdata/ui_guidance/*.html` guidance pages and the 8 built
  `vignettes/manual_components/*.Rmd` files, cross-checked against which are actually
  `child`-included by `a3manual.Rmd` (two are dead orphans — §4); (c) a targeted grep for
  every citation author/year already known to exist in the package (Lacy, Ballou, Crow,
  Kimura, Vinson, Raboin, Lange, MacCluer, Nei, Wright) across all doc surfaces to
  establish presence/absence and cross-surface consistency; (d) cross-checked the
  truncated in-code citation against `DESCRIPTION` and `CITATION.cff`, which carry the
  full form.
- **Coverage.** 50 / 50 candidate files classified (44 from the issue's named source
  directories + 6 breeding-group/ranking files the issue's own scope language implies
  but doesn't name: `groupAddAssign`, `filterThreshold`, `rankSubjects`,
  `getProductionStatus`, `getProportionLow`, `getIndianOriginStatus`). 8 / 8 UI guidance
  HTML pages read in full. 8 / 8 built vignette `manual_components` files read or
  grep-checked; the 2 non-built orphans were also read for the duplicate-file finding.
- **Finding count.** **12 findings** — 5 High, 5 Moderate, 2 Minor. Two functions the
  issue explicitly names by name (`meanKinship()`, and implicitly the sex-ratio Ne added
  in #118) have **zero citation anywhere in the package**.

**Headline.** The package's citation practice is **inconsistent, not absent**: two
estimators (Founder Equivalents/Genome Equivalents via Lacy 1989, Variance Ne via Crow &
Kimura 1970) are cited correctly and consistently in the authoritative glossary
(`population_genetics_terms.html`). But **five statistics — sex-ratio Ne, gene diversity,
mean kinship, the genetic-value ranking scheme, and the breeding-group MIS algorithm —
have no citation in any doc surface**, including two that sit in the *same glossary
panel*, immediately next to a correctly-cited neighbor. The dominant root cause is that
the two newest additions to the glossary panel (issue #118, S311–S313) added citations
for the new metrics they introduced (Variance Ne) but not for the metric that shipped
alongside it without one (Sex-Ratio Ne), and pre-existing central metrics (GD, mean
kinship, the ranking scheme, the MIS algorithm) were never retrofitted when the citation
convention was established for FE/FG/GU.

---

## 2. Findings

### High (5)

#### F1. Sex-ratio effective size (`calcNeSexRatio`) has no citation anywhere
- **Severity:** High
- **Location:** `R/calcNeSexRatio.R` (no `@references`); `inst/extdata/ui_guidance/population_genetics_terms.html` lines 71–92 (Sex-Ratio Ne section, no citation); `vignettes/manual_components/_summary_statistics.Rmd` lines 69–71 (narrates the formula, no citation)
- **Evidence:** `calcNeVariance.R`, added in the same #118 slice sequence (S311 sex-ratio, S312 variance) and displayed immediately below sex-ratio Ne in every surface, carries `@references Crow, J. F. and Kimura, M. (1970)...` in roxygen and a matching full citation in the glossary. `calcNeSexRatio.R` has neither. The glossary panel presents Founder Equivalents (cited), Founder Genome Equivalents (cited), Gene Diversity (uncited — F2), **Sex-Ratio Ne (uncited)**, Variance Ne (cited) in that order — a reader scanning top to bottom sees the pattern break twice.
- **Impact:** A reader (or reviewer) checking "does this estimator have a source" for sex-ratio Ne finds nothing in the package, even though the formula `Ne = 4*Nm*Nf/(Nm+Nf)` is exactly the kind of classical result the package cites elsewhere (Crow & Kimura 1970 covers this form too, in the same chapter as the variance form).
- **Recommendation:** Add `@references Crow, J. F. and Kimura, M. (1970) An Introduction to Population Genetics Theory. Harper and Row, New York.` to `calcNeSexRatio.R` (same citation `calcNeVariance.R` already uses — both forms are standard results from that text), and add the matching citation line to the `population_genetics_terms.html` Sex-Ratio Ne section and `_summary_statistics.Rmd`.

#### F2. Gene diversity (`calcGeneDiversity`) has no citation anywhere
- **Severity:** High
- **Location:** `R/calcGeneDiversity.R` (no `@references`); `inst/extdata/ui_guidance/population_genetics_terms.html` lines 51–69 (Gene Diversity section, no citation); `inst/extdata/ui_guidance/genetic_value.html` lines 34–41 (narrates GD, no citation); `vignettes/manual_components/_summary_statistics.Rmd` lines 61–63 (no citation)
- **Evidence:** GD (`GD = 1 - 1/(2*FG)`) is a direct function of FG, whose source (Lacy 1989) is cited immediately above it in the same glossary panel — but the citation is not carried forward to GD, even though GD is arguably the more commonly cited quantity in the population-management literature (the concept traces to Nei 1973's expected-heterozygosity formulation, applied here via Lacy's FG).
- **Impact:** Same as F1 — GD is issue #118's own headline deliverable (E1) and has zero traceable source in the shipped package across three surfaces.
- **Recommendation:** Add a `@references` note deriving GD from Lacy (1989) via FG (the package's own derivation, so citing Lacy is defensible and consistent with the FE/FG citation already present), or — if the owner prefers the more standard heterozygosity attribution — add Nei RC. 1973. "Analysis of gene diversity in subdivided populations." *PNAS* 70(12):3321-3323. Apply consistently to roxygen + both HTML/Rmd surfaces.

#### F3. Mean kinship (`meanKinship`) has no citation anywhere
- **Severity:** High
- **Location:** `R/meanKinship.R` (no `@references`, despite giving the explicit formula `MK_i = Σf_ij / N` in `@details`); no doc surface at all — `population_genetics_terms.html` does not define "Mean Kinship" (structural gap, see F9); `genetic_value.html` and `gvAndBgDesc.html` describe it narratively but cite nothing for it (the one nearby citation, "Vinson & Raboin 2015" in `genetic_value.html` line 71, supports an unrelated claim about missing-parent bias, not the mean-kinship metric itself)
- **Evidence:** `meanKinship()` is the issue's own first named example ("mean kinship (`meanKinship()`)"). It sits alongside `calcGU()` (which correctly cites Ballou & Lacy 1995) in the genetic-value-analysis family, but has no analogous citation of its own. Mean kinship as a genetic-management selection criterion is conventionally attributed to Ballou (1989) / Ballou & Lacy (1995) — the same source already used for genome uniqueness in this package.
- **Impact:** The package's central ranking input (mean kinship, feeding directly into `rankSubjects()` — see F4) has no documented provenance anywhere a reader can find.
- **Recommendation:** Add `@references Ballou JD, Lacy RC. 1995. ...` (same full citation `calcGU.R` already carries) to `meanKinship.R`, and add a Mean Kinship definition to the `population_genetics_terms.html` glossary (currently absent — see F9) with the same citation.

#### F4. The genetic-value ranking scheme (`rankSubjects`) has no citation anywhere
- **Severity:** High
- **Location:** `R/rankSubjects.R` (no `@references`, no `@details` beyond a one-line description); `inst/extdata/ui_guidance/gvAndBgDesc.html` lines 59–86 (the manual's own dedicated step-by-step description of the z-score ranking algorithm — no citation attached to the ranking method itself, only to genome uniqueness within it)
- **Evidence:** This is the package's flagship algorithm — CLAUDE.md's Core Function #4 ("Genetic Value Analysis Reports — Ranking scheme using mean kinship... genome uniqueness..."). `gvAndBgDesc.html` spells out the z-score-vs-grand-mean methodology and the 10%-GU / 0.25-z-score thresholds in detail but attributes it to no source. It is plausible this ranking scheme is ONPRC's own original method (in which case the correct fix is a documentation note saying so, not a citation), but that has not been stated anywhere either — the current state is silent, not "documented as original."
- **Impact:** A reader cannot tell whether the ranking scheme is a published method they could look up, or an ONPRC-original design decision. Both are legitimate; only one is currently true, and it isn't written down.
- **Recommendation:** Owner-gated decision: (a) if the scheme derives from a specific source (a plausible candidate is Vinson & Raboin 2015, since that paper describes the colony's practical genetic-management workflow), cite it explicitly in `rankSubjects.R` and `gvAndBgDesc.html`; (b) if it is ONPRC-original, add one sentence to `gvAndBgDesc.html` and `rankSubjects.R`'s `@details` stating so, so "no citation" reads as a documented fact rather than a gap.

#### F5. The breeding-group MIS algorithm (`groupAddAssign`) has no citation
- **Severity:** High
- **Location:** `R/groupAddAssign.R` (no `@references` at all — the function implementing the maximal-independent-set algorithm that *is* the Vinson & Raboin (2015) paper's central contribution)
- **Evidence:** The only citation to Vinson & Raboin (2015) anywhere in the package's roxygen is a truncated stub on `modBreedingGroups.R` (F6) — the Shiny UI wrapper, not the algorithm itself. `groupAddAssign.R`'s own `@details` describes the MIS sampling procedure in full but cites nothing. A reader landing on `?groupAddAssign` (the function they'd actually call from the exposed API, per this package's stated design goal of "expose functions for use... in R scripts") sees no source at all.
- **Impact:** The single most citation-relevant function in the package (the namesake algorithm of the package's own key reference, per CLAUDE.md) carries no citation on the function itself.
- **Recommendation:** Add the full `@references Vinson, A; Raboin, MJ. "A Practical Approach for Designing Breeding Groups to Maximize Genetic Diversity in a Large Colony of Captive Rhesus Macaques (Macaca mulatta)" Journal of the American Association for Laboratory Animal Science, 2015 Nov, Vol.54(6), pp.700-707` to `groupAddAssign.R` (the same full form recommended for F6).

### Moderate (5)

#### F6. `modBreedingGroups.R`'s citation is truncated
- **Severity:** Moderate
- **Location:** `R/modBreedingGroups.R` lines 15-16: `@references Vinson, A. and Raboin, M.J. (2015)` — no title, journal, volume, or pages
- **Evidence:** The full citation is readily available in-repo: `DESCRIPTION` ("A Practical Approach for Designing Breeding Groups to Maximize Genetic Diversity in a Large Colony of Captive Rhesus Macaques ('Macaca' 'mulatta')", with a PMC URL) and `CITATION.cff` carry it verbatim, and CLAUDE.md's "Key References" section has the full journal citation.
- **Impact:** Low on its own (a reader can find the full citation via `citation("nprcgenekeepr")` or DESCRIPTION), but it's the *only* @references instance of this citation in the codebase today, and it's the incomplete one.
- **Recommendation:** Replace with the full form (see F5's recommendation text) — same edit applies to both F5 and F6.

#### F7. The manual's own "Breeding Group Algorithm" page cites nothing
- **Severity:** Moderate
- **Location:** `vignettes/manual_components/_breeding_group_algorithm.Rmd` (built into the manual via `a3manual.Rmd` line 51) — no citation anywhere in its 75 lines describing the MIS algorithm in full narrative + pseudocode detail
- **Evidence:** Same gap as F5, on the user-facing manual page rather than the roxygen page.
- **Recommendation:** Add a closing citation line to Vinson & Raboin (2015), matching the pattern already used in `population_genetics_terms.html` (citation text placed after the formula/description block).

#### F8. Lacy (1989) is documented only in `@examples` comments for FE/FG/FEFG/Retention, not as a formal `@references` field
- **Severity:** Moderate
- **Location:** `R/calcFE.R`, `R/calcFG.R`, `R/calcFEFG.R`, `R/calcRetention.R` — each has a `## Example from Analysis of Founder Representation in Pedigrees... Zoo Biology 8:111-123, (1989) by Robert C. Lacy` comment inside `@examples`, but no `@references` tag
- **Evidence:** Roxygen's `@references` field is what renders in the man page's "References" section and in the pkgdown reference index; a comment inside `@examples` renders only as inline example code, easy to miss and not indexed as a reference. `population_genetics_terms.html` correctly carries the full formal citation for FE/FG — so the citation exists and is accurate, it just isn't in the field designed to hold it, in 4 of the 5 functions built on it (`calcFGSE.R` is the exception — its `@seealso` chain to `calcFG`/`calcFEFG` is a reasonable indirect path).
- **Impact:** Mechanical/low-risk — the fix is moving text that already exists into the right roxygen field, not researching a new citation.
- **Recommendation:** Add `@references Lacy RC. 1989. Analysis of founder representation in pedigrees: founder equivalents and founder genome equivalents. Zoo Biol 8:111-123.` to all four files (the exact citation text already used in `population_genetics_terms.html` line 47-48).

#### F9. Genome uniqueness and mean kinship are absent from the `population_genetics_terms.html` glossary; the dedicated gene-drop algorithm vignette cites nothing
- **Severity:** Moderate
- **Location:** `inst/extdata/ui_guidance/population_genetics_terms.html` (covers FE, FG, GD, Sex-Ratio Ne, Variance Ne — not GU or mean kinship); `vignettes/manual_components/_genome_uniqueness_algorithm.Rmd` (built into the manual via `a3manual.Rmd` line 53) — 85 lines describing the gene-drop algorithm in full, zero citations
- **Evidence:** `gvAndBgDesc.html` (a *different* built HTML page) correctly attributes genome uniqueness to **"MacCluer et al. (1986) and Ballou & Lacy (1995)"** — so the correct, more complete citation (including MacCluer, which doesn't appear in `calcGU.R`'s roxygen at all — see F10) exists in exactly one of the four surfaces that discuss GU, and is missing from the other three (roxygen, `genetic_value.html`, and the dedicated algorithm vignette).
- **Impact:** `population_genetics_terms.html` is the panel the app links to as "the" glossary/reference panel (embedded at the bottom of the Summary Statistics tab per `_summary_statistics.Rmd` line 93-96); its silence on GU and mean kinship means the two original, most-central GVA metrics have no formula+citation home in the one surface built for exactly that purpose.
- **Recommendation:** Add Genome Uniqueness and Mean Kinship entries to `population_genetics_terms.html`, matching the existing FE/FG/GD/Ne format (formula, one-paragraph explanation, citation line), and add a closing citation line to `_genome_uniqueness_algorithm.Rmd`.

#### F10. `calcGU.R`/`calcA.R` roxygen cites Ballou & Lacy (1995) only — missing the MacCluer et al. (1986) co-citation `gvAndBgDesc.html` gives the same algorithm
- **Severity:** Moderate
- **Location:** `R/calcGU.R` `@references` (Ballou & Lacy 1995 only); `R/calcA.R` (no `@references` at all — it computes the per-simulation rare-allele counts underlying `calcGU`)
- **Evidence:** `gvAndBgDesc.html` line 37-38: "genome uniqueness values are calculated using a gene-drop simulation according to **MacCluer et al. (1986) and Ballou & Lacy (1995)**" — MacCluer et al. 1986 is the original gene-drop-simulation methodology paper; Ballou & Lacy 1995 is the genome-uniqueness-specific application of it. The roxygen citation is accurate but incomplete relative to the manual's own account.
- **Recommendation:** Add MacCluer JW, et al. (1986) "Pedigree analysis by computer simulation." *Zoo Biology* 5:147-160 (or the owner's preferred exact form) as a second `@references` line in `calcGU.R`, and add a matching `@references` line to `calcA.R` (currently silent).

### Minor (2)

#### F11. `kinship.R` cites Lange (1997); `gvAndBgDesc.html` cites Lange (2002) for the same algorithm — and `kinship.R`'s primary URL is self-flagged stale
- **Severity:** Minor
- **Location:** `R/kinship.R` `@references`: "K Lange, Mathematical and Statistical Methods for Genetic Analysis, Springer, **1997**, p 71-72" plus a Mayo Clinic URL the roxygen itself notes "is now (2019-10-03) stale"; `inst/extdata/ui_guidance/gvAndBgDesc.html` line 11: "according... to the algorithm of Lange (**2002**)"
- **Evidence:** Kenneth Lange's *Mathematical and Statistical Methods for Genetic Analysis* (Springer) has both a 1997 first edition and a 2002 second edition — both are real, so this isn't a fabricated citation, but the two doc surfaces name different editions of the same source for the same algorithm without acknowledging it's the same work.
- **Impact:** Cosmetic — doesn't block a reader from finding the source, but a careful reader cross-referencing the two pages would notice the mismatch.
- **Recommendation:** Pick one edition (owner's call — 1997 matches the original implementation date per the `$Id:` comment in `kinship.R`) and use it consistently in both surfaces; separately, either update or drop the stale Mayo Clinic URL (dead since at least 2019) since the roxygen already gives the durable alternative (`kinship2` on CRAN).

#### F12. Two orphan duplicate vignette source files are not built but sit alongside the live ones
- **Severity:** Minor (structural, not a citation gap)
- **Location:** `vignettes/manual_components/_bg_algorithm.Rmd` (byte-identical duplicate of the built `_breeding_group_algorithm.Rmd`); `vignettes/manual_components/_bg_formation.Rmd` (a stale 2017 draft of the built, 2025-updated `_breeding_group_formation.Rmd` — genuinely different content, not a byte-duplicate)
- **Evidence:** `grep child= vignettes/a3manual.Rmd` includes `_breeding_group_algorithm.Rmd` and `_breeding_group_formation.Rmd`; neither `_bg_algorithm.Rmd` nor `_bg_formation.Rmd` is referenced anywhere in `a3manual.Rmd`.
- **Impact:** No live doc-accuracy defect (the orphans are never rendered), but they are maintenance/confusion risk — a future editor could mistakenly edit the dead twin (especially `_bg_formation.Rmd`, whose stale 2017 content describes the pre-modular Shiny app UI, not the current `modBreedingGroups` module).
- **Recommendation:** Delete both orphan files (owner-gated — outside this audit's citation scope, noted here because it surfaced during the doc-surface inventory).

---

## 3. Items Audited (Coverage Table)

**Legend:** PASS = independently citable, correctly cited and consistent · GAP = independently citable, citation missing/incomplete/inconsistent (see Findings) · N/A = internal plumbing / operational helper, no independent citation expected.

| Item | Verdict | Findings |
|------|---------|----------|
| `R/calcGU.R` | GAP (partial — missing co-citation) | F10 |
| `R/calcA.R` | GAP | F10 |
| `R/calcGUSE.R` | N/A (Monte Carlo SE, general statistics) | — |
| `R/calcFE.R` | GAP (roxygen-only) | F8 |
| `R/calcFG.R` | GAP (roxygen-only) | F8 |
| `R/calcFEFG.R` | GAP (roxygen-only) | F8 |
| `R/calcFGSE.R` | N/A (delta-method SE, inherits via `@seealso`) | — |
| `R/calcFounderContributions.R` | N/A (`@noRd` internal) | — |
| `R/calcRetention.R` | GAP (roxygen-only) | F8 |
| `R/calcGeneDiversity.R` | GAP | F2 |
| `R/calcNeSexRatio.R` | GAP | F1 |
| `R/calcNeVariance.R` | PASS | — |
| `R/calcAge.R` | N/A (arithmetic) | — |
| `R/calculateSexRatio.R` | N/A (count ratio utility) | — |
| `R/meanKinship.R` | GAP | F3 |
| `R/kinship.R` | PASS (minor inconsistency) | F11 |
| `R/addKinshipValueCount.R` | N/A (`@noRd`) | — |
| `R/applyKinshipOverrides.R` | N/A (data transform, not an estimator) | — |
| `R/applyKinshipOverridesToMatrix.R` | N/A (`@noRd`) | — |
| `R/checkKinshipOverrides.R` | N/A (validation, not an estimator) | — |
| `R/correctUnknownParentMeanKinship.R` | N/A (`@noRd`; explicitly self-documented ONPRC-original 2020 remedy) | — |
| `R/countKinshipValues.R` | N/A (plumbing) | — |
| `R/createSimKinships.R` | N/A (plumbing) | — |
| `R/cumulateSimKinships.R` | N/A (summary plumbing) | — |
| `R/getAnimalsWithHighKinship.R` | N/A (filter utility) | — |
| `R/getKinshipWithMaleStatus.R` | N/A (`@noRd`, operational heat-map threshold) | — |
| `R/kinshipMatricesToKValues.R` | N/A (reshape) | — |
| `R/kinshipMatrixToKValues.R` | N/A (reshape) | — |
| `R/prepareKinshipOverrides.R` | N/A (`@noRd`) | — |
| `R/readKinshipOverrides.R` | N/A (I/O) | — |
| `R/summarizeKinshipValues.R` | N/A (five-number summary, cites `stats::fivenum` already) | — |
| `R/getGeneticDiversityStats.R` | N/A (internal heat-map scoring, components already cited) | — |
| `R/makeGeneticDiversityHeatmap.R` | N/A (rendering) | — |
| `R/modGeneticDiversity.R` (UI+Server) | N/A (Shiny wrapper) | — |
| `R/reportGV.R` | N/A (orchestrator; delegates via `@seealso` to each cited component — good pattern) | — |
| `R/getDemographics.R` | N/A (LabKey I/O wrapper) | — |
| `R/getPedMaxAge.R` | N/A (arithmetic) | — |
| `R/getPyramidAgeDist.R` | N/A (age/status derivation) | — |
| `R/getPyramidPlot.R` | N/A (visualization) | — |
| `R/modPyramid.R` (UI+Server) | N/A (Shiny wrapper) | — |
| `R/getLivingBreeders.R` | N/A (`@noRd` filter) | — |
| `R/getSpeciesMinBreedingAge.R` | N/A (operational default lookup) | — |
| `R/modBreedingGroups.R` (UI+Server) | GAP (truncated) | F6 |
| `R/resolveBreedingAge.R` | N/A (`@noRd`) | — |
| `R/groupAddAssign.R` | GAP | F5 |
| `R/filterThreshold.R` | N/A (supporting utility, part of Group Formation) | — |
| `R/rankSubjects.R` | GAP | F4 |
| `R/getProductionStatus.R` | N/A (`@noRd`, internal colony-ops threshold) | — |
| `R/getProportionLow.R` | N/A (`@noRd`) | — |
| `R/getIndianOriginStatus.R` | N/A (`@noRd`) | — |
| `inst/extdata/ui_guidance/population_genetics_terms.html` | GAP (2 metrics missing entirely; GD/Sex-Ratio-Ne entries uncited) | F1, F2, F9 |
| `inst/extdata/ui_guidance/genetic_value.html` | GAP (GU, mean kinship, GD narrated, none cited) | F2, F3 |
| `inst/extdata/ui_guidance/gvAndBgDesc.html` | PASS (GU) / GAP (ranking scheme, MIS algorithm) | F4, F5, F11 |
| `inst/extdata/ui_guidance/summary_stats.html` | N/A (no formulas stated; delegates to the terms panel) | — |
| `inst/extdata/ui_guidance/group_formation.html` | N/A (relatedness table is standard textbook content) | — |
| `vignettes/manual_components/_genetic_value_analysis.Rmd` | N/A (narrative only, no formulas/citations claimed) | — |
| `vignettes/manual_components/_summary_statistics.Rmd` | GAP (mirrors F1/F2) | F1, F2 |
| `vignettes/manual_components/_breeding_group_formation.Rmd` (built) | N/A (UI walkthrough, no algorithm claims) | — |
| `vignettes/manual_components/_breeding_group_algorithm.Rmd` (built) | GAP | F5, F7 |
| `vignettes/manual_components/_genome_uniqueness_algorithm.Rmd` (built) | GAP | F9 |
| `vignettes/manual_components/_gv_and_bg_desc.Rmd` | N/A (thin wrapper; content lives in `gvAndBgDesc.html`) | — |
| `vignettes/manual_components/_bg_algorithm.Rmd` (orphan) | N/A for citations; structural finding | F12 |
| `vignettes/manual_components/_bg_formation.Rmd` (orphan) | N/A for citations; structural finding | F12 |

**Coverage: 50/50 R files + 8/8 UI guidance pages + 8/8 built/orphan vignette components examined (100%).**

---

## 4. Structural Observations

1. **Citation completeness correlates with recency, not centrality.** The two
   estimators added in the most recent work (issue #118, Variance Ne) and the two
   established earliest with deliberate citation care (FE/FG via Lacy 1989, GU via
   Ballou & Lacy 1995) are correctly cited. The estimators that are either
   older-and-assumed-obvious (mean kinship, the MIS algorithm, the ranking scheme) or
   added as a same-slice sibling without its own citation pass (Sex-Ratio Ne, GD) are
   the ones missing coverage. This suggests the structural fix is a **standing citation
   checklist** at the close of any slice that adds a new displayed statistic — "does
   this quantity's roxygen carry `@references`, and does the glossary panel entry beside
   it?" — rather than a one-time backfill (which this report's fixes would only
   partially be, until the next new metric repeats the pattern).
2. **`population_genetics_terms.html` is the de facto single source of truth for
   citations**, embedded into the app UI and cross-linked from `genetic_value.html`
   ("These, with their formulas and idealizing assumptions, are defined in the
   Population Genetics Terms reference panel"). Its 5-of-7-metric coverage (missing GU
   and mean kinship — F9) is the most consequential single gap in this audit, since it's
   the one place a user is actually pointed to for "why does this number look like
   this."
3. **`@examples`-buried citations (F8) are an easy, low-risk mechanical fix** — the
   correct text already exists in the package in three places (roxygen examples,
   `population_genetics_terms.html`, and this report); promoting it to `@references` is
   copy-paste, not research.
4. **The manual has two live built pages describing algorithms with zero citations**
   (`_breeding_group_algorithm.Rmd`, `_genome_uniqueness_algorithm.Rmd`) even though a
   *third*, separately-built page (`gvAndBgDesc.html`) correctly cites both algorithms.
   The citations exist in the package; they are simply not present on the pages
   dedicated to explaining the very algorithms they describe.

---

## 5. Comparison with Prior Audits

No prior audit of citation coverage exists for this package — this is the first pass of
this kind. The most relevant comparable prior audit is
`docs/audits/ISSUE_109_DOC_ERROR_AUDIT_2026-07-04.md` (roxygen factual-accuracy, not
citation coverage); no overlap in findings (that audit's scope explicitly excluded
citation completeness).

| Metric | Prior | Current | Trend |
|--------|-------|---------|-------|
| Total findings | N/A (first audit) | 12 | — |
| High findings | N/A | 5 | — |
| Coverage | N/A | 50 R files + 16 doc surfaces (100%) | — |

---

## 6. Recommendations (priority order)

1. **F1–F5 (High, 5 items):** add the missing citations to `calcNeSexRatio.R`,
   `calcGeneDiversity.R`, `meanKinship.R`, `groupAddAssign.R`, and resolve the
   ranking-scheme provenance question for `rankSubjects.R` (owner decision: cite or
   document-as-original) — these are the five statistics with literally no traceable
   source anywhere in the shipped package.
2. **F6, F8 (Moderate, mechanical):** complete the truncated `modBreedingGroups.R`
   citation and promote the four `@examples`-buried Lacy 1989 citations to formal
   `@references` fields — both are copy-paste fixes using text that already exists
   in-repo.
3. **F7, F9, F10 (Moderate, doc-surface sync):** add citations to the two live manual
   pages that currently have none (`_breeding_group_algorithm.Rmd`,
   `_genome_uniqueness_algorithm.Rmd`), add GU + Mean Kinship entries to
   `population_genetics_terms.html`, and add the MacCluer et al. (1986) co-citation to
   `calcGU.R`/`calcA.R`.
4. **F11, F12 (Minor):** reconcile the Lange 1997-vs-2002 edition mismatch and the
   stale Mayo Clinic URL; delete the two orphan vignette files (`_bg_algorithm.Rmd`,
   `_bg_formation.Rmd`) as a separate, non-citation housekeeping item.
5. **Process (structural):** adopt a standing rule (candidate location: a
   `CONTRIBUTING.md` / `PROJECT_LEARNINGS.md` note) that any new slice adding a
   displayed statistic updates `population_genetics_terms.html` and its own
   `@references` in the same session that ships the statistic, per Structural
   Observation 1.
