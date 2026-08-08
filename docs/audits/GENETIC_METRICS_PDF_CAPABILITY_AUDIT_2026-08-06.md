# Genetic Metrics PDF Capability Gap Analysis

**Date:** 2026-08-06  
**Reference:** `inst/extdata/reference/Master_Genetic_metrics_2_14_15.pdf`  
**Scope:** Fresh comparison of the PDF's desirable colony-management capabilities with the current `nprcgenekeepr` source, exports, Shiny UI, manual pages, and focused tests. This is a capability assessment, not a defect or implementation plan.

## Executive assessment

`nprcgenekeepr` is now a strong pedigree-centered colony-management package with meaningful empirical-marker extensions. It implements the PDF's core genetic-value workflow, group relatedness screening, colony summary statistics, pedigree QC, graphical pedigree browsing, marker-derived kinship, heterozygosity, recorded-parent contradiction screening, and between-center Fst.

The principal remaining gaps are no longer basic calculations. They are decision workflow and data-governance gaps:

1. No mechanism prevents or warns on ancestry mixing when groups or pairings are formed.
2. No longitudinal snapshot/trend workflow monitors whether a colony's metrics improve or decline over time.
3. Parentage testing can disqualify an inconsistent recorded parent, but cannot assign or rank a replacement.
4. Cross-center pedigree merging is safe but script-only and depends on a human-supplied identity map.
5. The package does not support MHC/functional-locus management, sequence data, or linkage-aware metrics.

The PDF treats NGS and linkage-block analyses as future directions, rather than immediate 2015 requirements. They are therefore real capability boundaries, but should be approached as separately designed initiatives rather than small feature additions.

## Method and interpretation

The PDF was read in full and visually checked after rendering. I then reviewed the current implementation and its public documentation, with particular attention to `reportGV()`, `groupAddAssign()`, `modBreedingGroups.R`, `makeGeneticSummaryTable()`, marker-genetics functions and module, pedigree QC, ancestry/origin functions, `resolveCrossCenterIds()`, and diagram functions. Focused tests for ranking, group assignment, reporting, marker kinship, heterozygosity, parentage exclusion, Fst, cross-center ID resolution, and group diversity statistics completed successfully.

Status meanings:

* **Implemented** - an appropriate, working package capability exists.
* **Partial** - meaningful coverage exists, but a decision-relevant limitation remains.
* **Missing** - no corresponding capability was found.
* **Policy/external** - the PDF asks for an institutional practice; the package can assist but cannot itself fulfill it.

## Capability comparison

| PDF-desired capability | Status | Current package evidence | Remaining gap or qualification |
|---|---|---|---|
| Preserve geographic genetic composition and avoid inappropriate cross-breeding | **Partial** | `convertAncestry()` standardizes ancestry labels; `getGeneticDiversityStats()` and the breeding-group heatmap expose an Origin condition. | Origin is reported, not enforced. Group formation and ranking do not prevent or explicitly warn on incompatible ancestry combinations. |
| Maintain/maximize within-population genetic diversity | **Implemented** | Pedigree kinship, genome uniqueness, founder metrics, gene diversity, and effective-population-size estimates are available through `reportGV()` and summary reporting. | Results remain only as sound as the underlying pedigree and selected population. |
| Identify effects of selecting animals for specific genotypes | **Partial** | Generic marker upload and ancestry/origin fields exist. | There is no functional-locus or targeted-genotype decision workflow that shows the diversity cost of a proposed selection. |
| Rank animals by mean kinship, z-score, and genome uniqueness | **Implemented** | `reportGV()` calculates all three; `modGeneticValue.R` exposes them in the Genetic Value Analysis workflow. | Genome uniqueness remains a pedigree/gene-drop estimate, not a direct sequence measure. |
| Let a center choose ranking priorities or combine metrics | **Implemented** | `reportGV()` accepts `guCutoff`, `zScoreCutoff`, and `axisPriority`; the UI exposes matching controls. | Defaults preserve legacy behavior, which is appropriate for reproducibility. |
| Apply a genetic-value threshold before forming breeding groups | **Implemented** | Breeding Group Formation offers the existing top-N option and a Genetic-value floor excluding Low Value animals. | The floor uses the report's categorical value classification rather than an arbitrary numeric threshold. |
| Use genetic value when assigning animals to sale or research purposes | **Partial** | Rankings and CSV exports make genetic value available for external decisions. | No workflow models a proposed removal/research allocation, records the decision, or shows its projected impact on colony diversity. |
| Exclude related breeding-age animals at about kinship 0.015 | **Implemented** | `groupAddAssign()` defaults to `threshold = 0.015625`; age and sex-pair filtering are part of the group workflow. | Threshold choice remains a curator decision. |
| Permit matriline-aware exceptions for related females | **Implemented** | `filterPairs()`/`groupAddAssign()` support ignored sex-pair combinations, with female-female treatment as the packaged default. | The operational policy still requires local biological judgment. |
| Present alternative valid group combinations for behavioral/dominance review | **Partial** | `groupAddAssign()` keeps up to five distinct, membership-deduplicated candidate solutions; the UI compares and selects them. | The PDF asks for all feasible combinations. The fixed cap may omit an option that is behaviorally preferable. |
| Incorporate behavioral compatibility and dominance rank in selection | **Partial** | Multiple alternatives give a human room to apply non-genetic judgment. | No behavior, social-rank, or compatibility data model is accepted or scored by the package. |
| Report grand mean kinship and distribution shape | **Implemented** | `makeGeneticSummaryTable()` and Summary Statistics report mean kinship with skewness and kurtosis via `calcSkewness()` and `calcKurtosis()`. | Shape statistics are descriptive; the PDF correctly provides no universal target values. |
| Report genome-uniqueness distribution and founder genome equivalents | **Implemented** | Summary reporting includes genome-uniqueness distribution shape; `calcFG()`/related functions estimate founder genome equivalents and gene diversity. | Founder measures have their usual pedigree and gene-drop assumptions. |
| State the population subset behind every colony metric | **Implemented** | `setPopulation()`/`getGVPopulation()` define analysis populations; the UI labels report populations. | There is no saved, reusable cohort-definition registry across reports. |
| Monitor a colony's genetic trajectory over time using consistent cohorts | **Missing** | One-run metrics, exports, and reports are available. | No snapshot store, time-series comparison, trend visualization, or cohort-consistency validation was found. Repeated analyses must be assembled outside the package. |
| Correct the artificial low-kinship bias of unknown parents | **Implemented** | `correctUnknownParentMeanKinship()` is used by `reportGV()`; the `flagged` report column identifies an uncorrected animal. | The correction is an informed pedigree-side adjustment, not a substitute for establishing parentage. |
| Validate parentage with STR/SNP data | **Partial** | `markerParentageExclusion()` compares recorded parent-offspring pairs and flags Mendelian contradiction; the Marker Genetics tab displays the result. | It neither assigns a missing parent nor ranks candidate parents by likelihood. |
| Maintain a usable pedigree schema and QC it | **Implemented** | `columnSchema.R`, `qcStudbook()`, parent-sex/age checks, date validation, duplicate detection, and placeholder handling supply a mature QC path. | Location and time-block semantics are not modeled as first-class analysis dimensions. |
| Use marker data to estimate relatedness when pedigree is absent or uncertain | **Implemented** | `markerKinship()` provides a genotype-only KING-robust matrix; the UI compares marker and pedigree mean kinship. | Current input is a biallelic, long-format marker table; it is not a general sequencing-data interface. |
| Compare observed and expected heterozygosity for inbreeding/substructure clues | **Implemented** | `markerObservedHeterozygosity()` reports individual observed heterozygosity and `markerExpectedHeterozygosity()` reports per-locus/mean expected heterozygosity. | The UI repeats one population expected-heterozygosity mean per animal; it does not estimate individual inbreeding coefficients or formally test substructure. |
| Assess genetic ancestry from markers | **Partial** | The package records/normalizes supplied ancestry and displays origin risk in breeding-group diversity statistics. | No marker-based ancestry inference, admixture estimate, reference-panel comparison, or ancestry-QC workflow exists. |
| Track MHC haplotypes and other functional loci for management | **Partial** | MHC-style labels can be loaded as generic genotype alleles. | No haplotype frequency, rarity, targeted-locus, or functional-variation report exists. |
| Support whole-genome/whole-exome data | **Missing** | No sequence input model or sequence-derived analysis was found. | This needs a separately scoped data, compute, and validation design. |
| Use linkage-disequilibrium blocks or inherited haplotype blocks | **Missing** | Current marker functions treat loci independently. | No locus-order metadata, LD/block estimation, or block-aware genome-uniqueness/founder-representation metric exists. |
| Visualize pedigree structure | **Implemented** | The Pedigree Browser Diagram view and `makePedigreeMatingLayout()` provide a mating-aware interactive diagram, including direct and rectilinear styles. | Rendering caps are deliberate practical limits for large pedigrees. |
| Support population projection/forward breeding simulation | **Partial** | A simulation subsystem exists and issue #10 tracks future GVA prediction from group configuration. | No user-facing multi-generation demographic/genetic projection comparable to PMX was found. |
| Analyze individual candidate mating pairs | **Partial** | Pairwise kinship filtering supports group formation. | There is no MateRx-style, curator-facing table that enumerates and ranks eligible individual mating pairs. |
| Maintain a unified cross-center pedigree and preserve transferred-animal lineage | **Partial** | `resolveCrossCenterIds(pedA, pedB, mapping)` merges records using a curator-confirmed mapping and fails safely on ambiguity/conflict. | It is script-only and cannot infer identities; mapping review/provenance need an operational workflow. |
| Monitor inter-center genetic differentiation with common markers | **Partial** | `markerFst()` computes Hudson's Fst from two uploaded genotype datasets; the Marker Genetics UI exposes a Cross-Center tab. | The package does not enforce a shared parentage panel, marker-version metadata, or a repeatable multi-center monitoring protocol. |
| Make pedigree data available to approved researchers | **Policy/external** | `obfuscatePed()`, `obfuscateId()`, `obfuscateDate()`, and `mapIdsToObfuscated()` are building blocks for relationship-preserving sharing. | Access approval, authorization, and no-restriction policy are institutional matters. No integrated, auditable sharing-export workflow exists. |

## Important distinctions

### Directly satisfied recommendations

The central 2015 workflow is present: define a population, produce a genetic-value ranking, select candidates, avoid excessive relatedness while respecting matrilines, and report colony-level diversity. The package also goes beyond the PDF in several useful ways: Monte Carlo uncertainty and convergence diagnostics for genome uniqueness, kinship overrides, unknown-parent bias correction, sex-ratio and variance effective population-size estimates, and a Shiny-based operational interface.

### Gaps that are workflow problems, not missing formulas

Several partial findings are not asking for another estimator. They need a reviewed decision process around existing data: exhaustive-or-transparent candidate-group search, behavior/rank information beside genetic alternatives, parentage assignment after an exclusion result, and a reviewed cross-center identity mapping workflow. These are high-value areas because they make genetic evidence usable in actual colony decisions.

### Gaps that require a new scientific/data architecture

Marker-based ancestry inference, functional/MHC management, NGS, and linkage-aware analysis require reference data, assay metadata, statistical choices, and validation datasets. They should not be folded into generic marker upload as unvalidated extensions.

## Priority gap analysis

| Priority | Gap | Why it matters | Appropriate next step |
|---|---|---|
| High | Parentage assignment after contradiction screening | A flagged parent record still leaves the pedigree incomplete and can distort downstream pedigree metrics. | Build a curator-reviewed candidate-parent and likelihood-ranking design around the existing exclusion result. |
| High | Longitudinal genetic-health monitoring | The PDF emphasizes trajectory within a colony; one-time summaries cannot show drift or improvement. | Define snapshot schema, consistent-cohort rules, and trend outputs before implementation. |
| High | Ancestry guardrails in breeding decisions | The PDF's stated primary aim includes preserving geographic genetic composition. Reporting an Origin color after group construction is weaker than preventing a problematic grouping. | Define center-configurable ancestry compatibility rules and an override/audit trail. |
| Medium | Cross-center mapping workflow and standard marker protocol | Safe merging exists, and Fst exists, but neither is yet an end-to-end operational program. | Add reviewed mapping/provenance UI and define panel/version metadata for repeatable monitoring. |
| Medium | Candidate-group completeness and behavioral inputs | The current top-five choices are useful but can conceal viable alternatives, and they contain no social evidence. | Design configurable retention/exhaustive modes with feasibility reporting and optional non-genetic annotations. |
| Medium | Individual mate-pair analysis | Some facilities need pair-level decisions rather than groups. | Add a distinct pair-analysis workflow rather than overloading group formation. |
| Deferred/scientific | MHC/functional, NGS, and LD/block methods | These may become strategically important but demand validated biological and computational assumptions. | Advance only through separately scoped research/design work. |

## Conclusion

The package satisfies the PDF's main pedigree-management recommendations and now covers several marker-based capabilities that the PDF describes as emerging. The strongest next improvements are not broad rewrites: protect ancestry in actual selection decisions, establish parentage rather than only finding contradictions, record and compare colony trajectories, and make cross-center workflows reviewable and reproducible. Sequence and linkage-aware genetics remain legitimate future initiatives, not unfinished implementation details.
