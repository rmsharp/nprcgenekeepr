# Genetic Metrics PDF vs. Package Capability Audit — Update

**Date:** 2026-08-05  
**Baseline:** [`GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md`](GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md)  
**Scope:** source-and-test-verified update of the 2026-07-29 comparison with `inst/extdata/reference/Master_Genetic_metrics_2_14_15.pdf`. This is a capability audit, not a defect audit.

## Executive result

The July audit identified two coherent capability clusters: decision flexibility (configurable ranking and multiple group options) and analyses that use empirical marker data rather than only pedigree/gene-drop simulation. Development since then has addressed most of both clusters.

Of the original 37 findings, the current assessment is **26 implemented, 9 partial, and 2 missing**. The July baseline was 16 implemented, 9 partial, and 12 missing. The remaining partial findings are deliberate boundaries: five retained rather than all possible breeding-group solutions; parentage *exclusion* rather than likelihood-based parentage assignment; and curator-supplied rather than automatically inferred cross-center identity links.

## Method

I reread the July audit, reviewed the development changelog and the current source, manual pages, exports, and Shiny-module wiring. I also ran the focused test files for marker kinship, marker heterozygosity, marker parentage exclusion, marker Fst, cross-center ID resolution, breeding-group assignment, and genetic-summary tables; they completed successfully.

* **Implemented** — the recommendation has a user-facing and/or exported, tested implementation appropriate to its stated scope.
* **Partial** — there is meaningful coverage, with a material limitation stated in the table.
* **Missing** — no corresponding capability was found.

## Changes to the July findings

| Dimension and July finding | Current status | Current evidence and boundary |
|---|---|---|
| Genetic-value ranking was fixed/hard-coded | **Implemented** | `reportGV()` now accepts `guCutoff`, `zScoreCutoff`, and `axisPriority`; `modGeneticValue.R` exposes a Ranking Scheme, priority axis, and both cutoffs. Defaults preserve the former behavior. |
| Breeding-group inclusion was only top-N | **Implemented** | `modBreedingGroups.R` now offers **Include animals by**, including a Genetic-value floor that excludes animals classified Low Value; top-N remains the compatibility default. |
| Multiple candidate groupings were discarded | **Partial** | `groupAddAssign()` retains up to five distinct, membership-deduplicated candidate partitions, ordered by score. The Breeding Group Formation UI provides a selector and comparison table. This fulfills human comparison of alternatives, but not the PDF's literal “all possible combinations” wording. |
| Kinship distribution skewness/kurtosis absent | **Implemented** | `calcSkewness()` and `calcKurtosis()` implement bias-adjusted Fisher–Pearson estimators; `makeGeneticSummaryTable()` and the Summary Statistics module display both. Degenerate inputs render as N/A. |
| Genome-uniqueness distribution shape only partly reported | **Implemented** | The same summary table and module now report mean, skewness, and kurtosis for genome uniqueness. |
| Uncorrected one-unknown-parent animals were silent | **Implemented** | `reportGV()` now includes `flagged`, identifying animals whose mean-kinship correction could not find an eligible peer cohort. The column is present in the rankings and CSV downloads. |
| No marker-derived pairwise kinship | **Implemented** | `checkMarkerGenotypeFile()`, `buildMarkerGenotypeMatrix()`, and `markerKinship()` ingest biallelic marker data and compute a genotype-only KING-robust kinship matrix. The Marker Genetics **Kinship Comparison** tab places it beside pedigree kinship. |
| No observed-versus-expected heterozygosity diagnostic | **Implemented** | `markerObservedHeterozygosity()` and `markerExpectedHeterozygosity()` calculate per-animal observed heterozygosity and population expected heterozygosity (Nei gene diversity); the Marker Genetics **Heterozygosity** tab surfaces them. |
| No molecular parentage verification | **Partial** | `markerParentageExclusion()` checks each genotyped recorded parent/offspring pair, flags three or more opposite-homozygote conflicts by default, and is surfaced in **Parentage Exclusion**. It verifies/excludes recorded parents; it does not search for or likelihood-rank replacement parents. |
| No cross-center pedigree integration / transferred animals became artificial founders | **Partial** | `resolveCrossCenterIds(pedA, pedB, mapping)` merges two pedigrees using an explicit curator-confirmed ID map, rewrites parent pointers, and fails on ambiguity or conflicting parents. It is exported/script-callable, but it neither infers identities nor yet has a Shiny workflow. |
| No between-center marker differentiation measure | **Implemented** | `markerFst()` computes per-locus and pooled Hudson's Fst from two marker-genotype matrices; the Marker Genetics **Cross-Center** tab accepts a second-center file and displays it. |
| No graphical pedigree/tree visualization | **Implemented** | The Pedigree Browser now has an interactive **Diagram** view. `makePedigreeMatingLayout()` supports mating-aware connectors, duplicate occurrences for multi-mating/looped pedigrees, and direct or rectilinear (kinship2-style) edge layouts. |
| Cervus-like molecular parentage functionality absent | **Partial** | The parentage-exclusion workflow now covers contradiction screening, but no likelihood-based assignment, candidate ranking, or multilocus parentage assignment engine is implemented. |
| Genotype data was only a gene-drop seed | **Implemented** | Empirical marker data is now also a primary analytical input for marker kinship, observed/expected heterozygosity, parentage exclusion, and between-center Fst. The existing gene-drop use remains available. |

## Current capability map

### 1. Genetic Value Analysis and ranking — 5 implemented

Mean kinship, standardized kinship (z-score), genome uniqueness, configurable priority/cutoffs, and value-based inclusion are implemented. The newly configurable ranking controls directly resolve the July finding that a center could not choose its own kinship-versus-uniqueness priority.

### 2. Breeding Group Formation — 4 implemented, 1 partial

Pairwise relatedness screening, matriline-aware female-pair treatment, sex-ratio/harem constraints, and value-based exclusion are implemented. Up to five distinct candidate solutions can now be inspected and compared; retaining a bounded top set rather than enumerating every possible partition remains the only partial item in this dimension.

### 3. Colony/population genetic-health reporting — 5 implemented

Overall mean kinship, mean/skewness/kurtosis summaries for mean kinship and genome uniqueness, founder genome equivalents, and explicit population-subset labeling are all implemented. The package also continues to supply gene diversity, two effective-population-size estimators, Monte Carlo uncertainty for genome uniqueness and founder genome equivalents, and diversity heatmaps.

### 4. Pedigree data, QC, and parentage verification — 4 implemented, 1 partial

The required pedigree schema, optional colony fields, QC checks, and the unknown-parent mean-kinship correction (including its newly visible failure flag) are implemented. Marker-based screening can now detect contradiction of a recorded dam or sire, but it is intentionally an exclusion check rather than a complete parentage assignment system.

### 5. Marker/genomics methods beyond pedigree — 3 implemented, 1 partial, 2 missing

Marker-derived kinship and observed/expected heterozygosity are implemented, and marker data is now genuinely analyzed rather than only used as a simulation seed. MHC labels remain supported only through the generic genotype pipeline, without haplotype-specific frequency or rare-haplotype reports (**partial**). Whole-genome or whole-exome sequence support and linkage-disequilibrium-block-aware metrics remain **missing**. As the source PDF characterized these as future directions, these are capability boundaries rather than failures to meet a present-day 2015 requirement.

### 6. Cross-center integration and governance — 1 implemented, 3 partial

Hudson's Fst now supplies an identity-by-state/allele-frequency differentiation measure across two uploaded center datasets (**implemented**). A merged cross-center pedigree and preservation of transferred-animal lineage are available with an explicit curator mapping (**partial** because there is no inference or UI workflow). The de-identification pathway remains a useful software-side building block for approved sharing, while the PDF's unrestricted-data-access recommendation is ultimately policy rather than a package feature (**partial**).

### 7. PDF-named tooling comparison — 4 implemented, 3 partial

The new mating-aware, interactive Diagram view resolves the Pedigree/Draw gap. Pedscope-like kinship/genome uniqueness, PedSys-like kinship calculation, and packaged replacement for custom kinship scripts remain implemented. PMX remains complementary because the package does not provide a multi-generation demographic-projection engine; MateRx remains partial because the package optimizes breeding groups rather than individual pairings; and Cervus remains partial for the reason above.

## Remaining priority gaps

1. **NGS / whole-genome / whole-exome input and analysis** — no sequence-data model, ingestion path, or sequence-based metric is present.
2. **Linkage-aware metrics** — current marker analyses treat loci independently; there is no LD-block, haplotype-block, or recombination-aware analysis.
3. **Parentage assignment after exclusion** — the package can flag incompatible recorded parents but cannot propose and statistically rank replacements.
4. **Cross-center workflow ergonomics** — the safe explicit mapping design should be retained, but a reviewed import/mapping UI and provenance report would make it operational for non-programmatic users.
5. **Candidate-group breadth** — five alternatives are a practical improvement, but requirements that genuinely need exhaustive enumeration would need a separate, scalability-conscious design.

## Conclusion

The current package no longer has the July audit's broad pedigree-only limitation. It now combines pedigree-based colony management with a focused empirical-marker workflow for independent kinship checks, heterozygosity, recorded-parent exclusion, and between-center differentiation. The remaining limits are specific and intelligible: sequence/linkage analytics, full parentage assignment, inferred cross-center identity, and exhaustive group-solution enumeration.
