# Genetic Metrics PDF vs. Package Capability Audit

**Date:** 2026-07-29 · **Session:** S419 · **Type:** capability-comparison audit (not a
code-defect audit — no severity ratings; findings are implemented / partial / missing)

**Source document:** `inst/extdata/reference/Master_Genetic_metrics_2_14_15.pdf` —
"Recommendations for the genetic management of nonhuman primate colonies at the National
Primate Research Centers," NHP Genetics and Genomics Working Group, February 2015 (10
pages; read in full for this audit).

**Question asked:** how do this document's recommendations compare with what
`nprcgenekeepr` actually does? What does the package do beyond the document, and what
does the document ask for that the package doesn't (yet) do?

---

## Method

Read the PDF in full, then ran a 14-agent workflow: one agent per recommendation area
("dimension" below) read the actual R source (`R/`), tests, vignettes, and `man/` pages
and reported each recommendation as **implemented** / **partial** / **missing** /
**not-applicable-to-software**, with a file:line citation — then a second, independent
agent per dimension adversarially re-verified every claim against the source before it
was accepted (this project's own `PED_GV_AUDIT_2026-05-30.md` used the same
workflow-plus-adversarial-verification method for a prior capability/defect audit). One
verifier's claim that `readKinshipOverrides`/`checkKinshipOverrides` don't exist was
itself checked against `NAMESPACE`/`ls R/` directly by the author and found to be
**wrong** — both files and exports exist — and is corrected below. No other
verifier claim was found to be in error on spot-check.

**Coverage:** all distinct recommendations identified in the PDF, grouped into 7
dimensions; 37 individual findings.

**Finding counts:** 16 implemented · 9 partial · 12 missing (0 formally
not-applicable-to-software, though one governance recommendation is analyzed as
policy-not-code with a software-realizable analog noted).

---

## Findings by dimension

### 1. Genetic Value Analysis & Ranking

| Recommendation | Status | Evidence |
|---|---|---|
| Mean kinship per animal | **Implemented** | `R/meanKinship.R:28-30` (`colMeans` over the kinship matrix); used in `R/reportGV.R:156` |
| Z-score (mean kinship standardized across the population) | **Implemented** | `R/reportGV.R:173` — `zScores <- scale(indivMeanKin)` |
| Genome uniqueness (probability of rare alleles) | **Implemented** | `R/calcGU.R:90-105` — gene-drop-based rare-allele percentage, with `R/calcGUSE.R` computing its Monte Carlo standard error |
| Configurable ranking scheme (center chooses priority: kinship+z-score / GU / a blend) | **Partial** | `R/orderReport.R:31-98` implements one **fixed** tier order with hardcoded cutoffs (`gu > 10`, `zScores <= 0.25`, lines 73/75/78/81) — no argument or UI control lets a center reprioritize, as the PDF explicitly says should be a per-center choice |
| Threshold-based retain/remove recommendation | **Partial** | `R/rankSubjects.R:41-47` labels animals High Value / Low Value / Undetermined, but the boundary is the same hardcoded `gu>10`/`zScores<=0.25` cutoff — no adjustable threshold value |

**Notable additional capabilities in this area:** `gvaConvergence()` (automatically
recommends how many gene-drop iterations are needed for stable rankings); Monte Carlo
standard errors for both genome uniqueness and founder genome equivalents
(`calcGUSE`/`calcFGSE`); a kinship-override system letting outside genetic information
refine the pedigree-derived kinship matrix before ranking; `correctUnknownParentMeanKinship()`,
a bias correction for animals with one unknown parent that the PDF doesn't describe;
colony-level diversity metrics (founder equivalents, founder genome equivalents, gene
diversity, two effective-population-size estimators) bundled into the same report; an
interactive Shiny scatter plot and CSV export.

### 2. Breeding Group Formation

| Recommendation | Status | Evidence |
|---|---|---|
| Threshold-based exclusion of low-genetic-value animals | **Partial** | `R/modBreedingGroups.R:40-53,253-258` only offers a **top-N** cutoff (default 20) on the ranked id list, not a genetic-value floor — a mediocre top-20 all pass regardless of absolute value |
| Pairwise relatedness screening (kinship coefficient ≈0.015 / relatedness ≈0.03) against all other breeding-age adults | **Implemented** | `R/groupAddAssign.R:121-140` (default threshold `0.015625`, user-configurable, exposed in the Shiny UI); `R/filterThreshold.R`, `R/filterPairs.R`, `R/filterAge.R` build the exclusion set, restricted to breeding-age pairs |
| Matriline-aware exception (tolerate related females, avoid related males/male-female) | **Implemented** | `R/filterPairs.R:34-64` — F-F pairs are ignored by default; the packaged Shiny app hardcodes F-F-only (`R/modBreedingGroups.R:338`) with no UI toggle to change it, though the underlying `groupAddAssign()`/`filterPairs()` API accepts any sex-pair list |
| Sex-ratio constraints / harem group configuration | **Implemented** | `R/initializeHaremGroups.R` (one-sire-per-group seeding), `R/calculateSexRatio.R`, `R/fillGroupMembersWithSexRatio.R`; exposed as "Harem (1M:NF)" vs. "Custom" ratio in the Shiny UI |
| Multiple candidate group combinations for a human to apply behavioral/dominance criteria against | **Missing** | `R/groupAddAssign.R:164-186` runs up to 1000 random trials internally but keeps **only the single highest-scoring trial** (`R/groupMembersReturn.R:19-33`) — every other candidate grouping is discarded, so there is no way to compare/choose among valid genetic options using non-genetic criteria |

**Notable additional capabilities:** seeding groups with specific pre-decided animals;
kinship overrides feeding into group formation; per-group CSV export of membership and
kinship submatrix; a trailing "unused animals" pseudo-group so every candidate's
disposition stays visible; a minimum-breeding-age filter layered onto the kinship/sex
screening.

### 3. Colony/Population Genetic Health Reporting Metrics

| Recommendation | Status | Evidence |
|---|---|---|
| Grand/overall mean kinship for the whole colony | **Implemented** | `R/makeGeneticSummaryTable.R:39-46`, also in `R/modGeneticValue.R` and `R/modORIPReporting.R` |
| Kinship-distribution shape statistics (skewness, kurtosis) | **Missing** | Repo-wide grep for "skew"/"kurtosis" finds only unrelated colloquial uses (e.g. "reproductive skew," "ratio skews"); `R/summarizeKinshipValues.R` reports only min/quartiles/mean/median/max/sd — no third or fourth moment |
| Genome-uniqueness distribution (mean, skewness, kurtosis) | **Partial** | Mean is reported (`R/makeGeneticSummaryTable.R:47-53`); skewness/kurtosis are absent for the same reason as above |
| Founder genome equivalents (Lacy 1989) | **Implemented** | `R/calcFE.R`, `R/calcFounderContributions.R`, `R/calcRetention.R`, `R/calcFG.R` re-derive the Lacy (1989) formula exactly, with the paper cited in roxygen (`@references Lacy RC. 1989...`) and validated against Lacy's own worked 7-animal example; `R/calcFGSE.R` adds a Monte Carlo standard error |
| Mechanism to specify/label which population subset a set of metrics describes | **Implemented** | `R/setPopulation.R`/`R/getGVPopulation.R` (user supplies an ID list defining "the population"), surfaced with explicit labels like "Population: current living breeders" (`R/modSummaryStats.R:683`) |

**Notable additional capabilities:** two effective-population-size estimators
(sex-ratio-based and variance-based, `R/calcNeSexRatio.R`/`R/calcNeVariance.R`); Monte
Carlo standard errors for founder genome equivalents and genome uniqueness; the same
kinship-override and unknown-parent-correction mechanisms noted above; a genetic-diversity
heatmap that scores breeding groups red/yellow/green across four axes (Value, Origin,
Production, Inbreeding) — an operational reporting layer the PDF doesn't ask for.

### 4. Pedigree Data Collection, QC, and Parentage Verification

| Recommendation | Status | Evidence |
|---|---|---|
| Minimum pedigree schema (id/sire/dam/sex) | **Implemented** | `R/columnSchema.R:16-24` — the package's required set (`id, sire, dam, sex, birth`) is a **superset** of the PDF's minimum (it also requires birth date) |
| Optional fields (species/population/location/time-block/birth-death dates) | **Implemented** | `R/columnSchema.R:20-23` (`species, gen, exit, death, ancestry, population, origin, ...`) — no field literally named "location" or "time-block," but `gen`/`origin`/`ancestry`/`population` serve the same grouping role |
| QC: parent-record verification, sex validation, duplicate detection, date validation, minimum-parent-age check | **Implemented** | `R/qcStudbook.R` orchestrates `addParents()`, `R/correctParentSex.R`, `R/removeDuplicates.R`, `R/getDateErrorsAndConvertDatesInPed.R`, and `R/checkParentAge.R` (species-specific minimum breeding age via `R/getSpeciesMinBreedingAge.R`) |
| Handling of the PDF's stated bias (an unknown/missing parent artificially lowers mean kinship) | **Implemented** | `R/correctUnknownParentMeanKinship.R` raises a one-unknown-parent animal's mean kinship toward a contemporaneous breeding-age peer-cohort mean — directly counteracts the bias the PDF describes. **Gap noted:** when no peer cohort exists, the function returns a `flagged` list of uncorrected ids, but nothing in the codebase reads or surfaces that flag to the user — those animals are silently left uncorrected |
| Genetic-marker-based (SNP/STR) parentage **verification** from lab genotyping, distinct from simulation | **Missing** | The package's genotype-handling code (`R/addGenotype.R`, `R/assignAlleles.R`, `R/geneDrop.R`) never compares an animal's own genotype against a candidate parent's — see Dimension 5 |

**Notable additional capabilities:** genotype-seeded gene-drop simulation (real known
genotypes can sharpen the simulation for a subset of animals); automatic placeholder-ID
generation for unknown parents; per-animal parentage-completeness classification surfaced
directly in genetic-value reports; species-aware minimum-breeding-age and
gestation-window tables (the package isn't rhesus-only); animal-ID character-legality
validation reused across the pedigree and gene-drop code paths.

### 5. Marker/Genomics-Based Methods Beyond Pedigree

| Recommendation | Status | Evidence |
|---|---|---|
| Estimating pairwise kinship directly from genetic markers, independent of pedigree | **Missing** | `R/kinship.R` computes kinship purely from pedigree structure (id/sire/dam); uploaded genotype data is never used for a marker-based kinship estimate — its only consumer is the gene-drop simulation |
| Expected vs. actual heterozygosity from genotype data (inbreeding/substructure diagnostic) | **Missing** | The only "heterozygosity" hit, `R/calcGeneDiversity.R`, computes gene diversity from founder genome equivalents (a pedigree/gene-drop quantity), not an observed-vs-expected comparison from real genotype data |
| Whole-genome/whole-exome (NGS) sequence data support | **Missing** | Zero hits for "NGS," "sequencing," "whole genome/exome" anywhere in source, docs, or tests |
| MHC haplotype-specific tracking | **Partial** | A real, bundled example dataset (`rhesusGenotypes`, from `inst/extdata/examples/obfuscated_rhesus_mhc_breeder_genotypes.csv`) uses genuine Mamu MHC-haplotype labels and can be uploaded as gene-drop seed data — but there is no MHC-specific analysis, haplotype-frequency reporting, or rare-haplotype flagging; it's handled by the same generic two-allele-locus machinery as any other genotype file |
| Linkage-disequilibrium-block-based metrics | **Missing** | Zero hits for "linkage disequilibrium"/"LD block"; the gene-drop simulation treats every locus as an independent 50/50 Mendelian draw, with no concept of linked marker blocks |
| Nature of the genotype/allele code surface (real data vs. simulation) | **Clarified (partial)** | The package **can** ingest real empirical genotype/MHC data (`R/getGenotypes.R`, `R/checkGenotypeFile.R`, `R/addGenotype.R`), but its **sole use** is as seed input to the classic MacCluer/Vandeberg/Ryder (1986) pedigree gene-drop Monte Carlo simulation (cited in `R/geneDrop.R:8-10`) — genome uniqueness and related metrics remain fundamentally pedigree-driven simulations, not empirical marker-based population-genetics estimates |

**Note on scope:** the PDF itself frames NGS/MHC-specific/LD-block methods as a
speculative *future direction*, explicitly stating these tools were "developed somewhat
for recombinant mouse lines" and would "need to be further explored" for outbred NHP
colonies — even in 2015 the working group did not treat these as a present-day
requirement. Their absence here is a real capability gap relative to where the field
has moved since, but not a failure to meet the 2015 document's own recommendation.

**Notable additional capabilities:** founder equivalents/founder genome equivalents with
Monte Carlo standard errors (conceptually adjacent to the "future" founder-representation
metrics the PDF speculates about, but delivered via pedigree simulation rather than NGS
data); a hybrid pedigree-plus-partial-marker-data seeding approach; a Shiny upload
workflow with graceful degradation if a genotype file is invalid; a distinct Monte Carlo
technique for handling **parentage uncertainty** (`createSimKinships`/`cumulateSimKinships`/
`makeSimPed`) — simulating across candidate-parent lists rather than known pedigrees,
which the PDF doesn't describe at all.

### 6. Cross-Center Integration & Data Governance

| Recommendation | Status | Evidence |
|---|---|---|
| A single pedigree spanning multiple centers | **Missing** | `R/getSiteInfo.R`/`R/defaultSiteParams.R` model exactly **one** center per running instance (one `baseUrl`, one `schemaName`); nothing merges or reconciles two centers' data automatically |
| Identity-by-descent cross-referencing when a transferred animal is re-identified at a new site | **Missing** | This is literally the PDF's stated failure mode (transferred animals become artificial "founders" at the new center) — no function anywhere resolves two ID strings for the same physical animal across sources |
| Identity-by-state / allele-frequency differentiation between centers | **Missing** | No function accepts two centers' genotype datasets and computes a between-population differentiation statistic; all genetic-diversity statistics in the package are single-colony |
| Make pedigree data available to approved researchers with no restriction | **Partial** (policy recommendation, not a software feature per se) | Not something software enforces directly, but the package provides a real, tested de-identification pathway — `R/obfuscateId.R`, `R/obfuscateDate.R`, `R/obfuscatePed.R`, `R/mapIdsToObfuscated.R` — that is the natural software-side building block for sharing pedigree data outside the home institution while preserving relationship structure |

**Notable additional capabilities:** a LabKey credential-precedence chain (env var →
config file → `.netrc`) for authenticating to a center's EHR; a pluggable pedigree-source
adapter (`labkey` / `dataframe` / `file`) that at least allows a user to feed in an
already-merged multi-center table, even though the package does no reconciliation itself;
per-site customization of species breeding-age/gestation overrides via config file.

### 7. Tooling Comparison & Additional Package Capabilities

The PDF names six external tools colony managers might already use. How `nprcgenekeepr`
compares:

| Tool (PDF's stated function) | Status | Evidence |
|---|---|---|
| **PMX** — studbook demographic/genetic management | **Partial (complements)** | Overlaps on QC, kinship, and group formation, but has no multi-generation demographic-projection/forecast engine |
| **Pedigree/Draw** — pedigree diagram visualization | **Missing** | The package renders pedigrees as a sortable **data table** (`DT::renderDT`), not a graphical family tree; no diagram-drawing dependency exists in `DESCRIPTION` |
| **MateRx** — optimal individual mate-pair analysis | **Partial** | `nprcgenekeepr` optimizes **groups** of unrelated animals (a maximal-independent-set algorithm), not pairwise mate-selection — structurally different from MateRx's stated per-pair analysis |
| **Cervus** — molecular-marker parentage assignment/verification | **Missing** | No STR/SNP genotype-matching, exclusion analysis, or likelihood-based parentage assignment anywhere (consistent with Dimension 5's finding) |
| **Pedscope** — kinship and genome uniqueness | **Implemented** | Both are implemented; the package's own documentation explicitly notes its genome-uniqueness results will differ slightly from Pedscope's due to a methodological difference |
| **PedSys** — kinship coefficients | **Implemented** | `R/kinship.R` is the shared kinship engine used throughout the package |
| Custom in-house kinship scripts | **Implemented** | Replaced by a packaged, tested kinship toolchain |

**Additional capabilities with no counterpart in any of the six named tools** (confirmed
by direct read): direct LabKey EHR integration for building pedigrees from live colony
databases; a complete Shiny web application (10 modules, not just a function library);
first-class studbook QC as a standalone pre-analysis gate; age-sex demographic pyramid
plots; the kinship-override/correction system (`applyKinshipOverrides`,
`applyKinshipOverridesToMatrix`, `checkKinshipOverrides`, `readKinshipOverrides`,
`prepareKinshipOverrides`, `flagOverriddenRelationships` — all six confirmed present in
`R/` and exported via `NAMESPACE`); ORIP (NIH Office of Research Infrastructure Programs)
grant-reporting support; a fully offline file-based pedigree workflow requiring no
database connection; a founder-equivalent statistics suite with formal standard-error
quantification; a genetic-diversity heatmap visualization.

---

## Summary: notable missing features

In rough order of how closely they match something the PDF explicitly recommends:

1. **Multiple candidate breeding groups are never surfaced to the user** (Dimension 2) —
   the PDF's core best-practice ("derive all possible combinations... because behavioral
   compatibility and dominance rank also matter") isn't met; the algorithm explores many
   internally but discards all but the single top-scoring one.
2. **No configurable ranking-priority scheme** (Dimension 1) — the PDF explicitly frames
   this as a per-center choice (kinship+z-score vs. genome uniqueness vs. a blend);
   `nprcgenekeepr` hardcodes one fixed tier order and two magic-number cutoffs.
3. **No kinship or genome-uniqueness distribution-shape statistics** (skewness, kurtosis)
   for colony-health reporting (Dimension 3) — an explicit PDF recommendation with zero
   coverage.
4. **No marker-based (SNP/STR) kinship estimation or real observed-vs-expected
   heterozygosity diagnostic** independent of pedigree (Dimension 5) — the PDF describes
   this as already standard practice in 2015; the package's genotype machinery is
   simulation-seeding only.
5. **No genetic parentage verification from lab genotyping** to catch the ~5%
   dam-misidentification problem the PDF specifically names (Dimension 4) — QC checks
   pedigree self-consistency, never cross-checks against molecular data.
6. **No cross-center integration** — no identity-by-descent linking when animals
   transfer between centers (literally the PDF's flagged failure mode) and no
   identity-by-state comparison between centers (Dimension 6).
7. **No pedigree-diagram/tree visualization** (Dimension 7) — only a sortable table.
8. **Breeding-group value-based exclusion is actually rank-based (top-N)**, not a
   genetic-value floor (Dimension 2) — could admit a colony-wide-mediocre top-20 or
   exclude a genuinely viable animal, depending on pool size/composition.
9. NGS/whole-genome, MHC-specific analysis, and linkage-disequilibrium metrics
   (Dimension 5) are absent, but the PDF itself frames these as speculative future work
   even in 2015 — a real gap relative to where the field has since moved, not a failure
   against the document's own ask.
10. A smaller, silent gap: `correctUnknownParentMeanKinship()`'s `flagged` output (ids
    left uncorrected for lack of a peer cohort) is computed but never surfaced anywhere
    in the codebase (Dimension 4).

## Summary: notable additional capabilities

Capabilities the package has that the PDF never asked for at all:

- A **complete Shiny web application** (`runGeneKeepR()`, 10 modules) — the PDF discusses
  metrics and methodology, not software delivery.
- **Direct LabKey EHR integration** for building pedigrees from a center's live
  colony-management database, plus a fully **offline file-based** alternative workflow.
- **First-class studbook quality control** (parent-record, sex, duplicate, date, and
  minimum-parent-age validation) as a standalone pre-analysis gate.
- **Age-sex demographic pyramid plots** for colony demographic visualization.
- A **kinship-override/correction system** letting outside genetic information (e.g.
  from genotyping) refine a pedigree-derived kinship matrix before analysis.
- **ORIP (NIH) grant-reporting support** — a US-federal-grant-specific compliance
  feature.
- **Formal uncertainty quantification** (Monte Carlo standard errors) for genome
  uniqueness and founder genome equivalents — the PDF's metrics are described as point
  estimates only.
- **Two effective-population-size estimators** (sex-ratio-based and variance-based).
- A **genetic-diversity heatmap** scoring breeding groups across four axes (Value,
  Origin, Production, Inbreeding).
- **De-identification/obfuscation utilities** (`obfuscateId`, `obfuscateDate`,
  `obfuscatePed`, `mapIdsToObfuscated`) — a real software-side building block relevant to
  the PDF's data-sharing-governance recommendation, which the PDF itself never proposes
  as a software feature.
- **Species-aware** minimum-breeding-age and gestation tables — generalized beyond
  rhesus macaques to other NHP species with per-site override support.
- A distinct **Monte Carlo parentage-uncertainty simulation** (`createSimKinships`,
  `cumulateSimKinships`, `makeSimPed`) for animals with only candidate (not confirmed)
  parents — a technique the PDF doesn't describe at all.

---

## Structural observation

The package's core genetic-value machinery (mean kinship, z-score, genome uniqueness,
founder genome equivalents) is a faithful, well-cited implementation of exactly what the
PDF specifies, and goes further in several directions the PDF doesn't ask for
(uncertainty quantification, bias correction for unknown parents, effective-population-size
estimators). The gaps cluster in two distinct places: (a) **configurability/multiplicity**
— the ranking scheme, retain/remove threshold, and breeding-group candidate set are all
hardcoded to a single fixed outcome where the PDF explicitly wants center-specific choice
or multiple options for a human to pick among; and (b) **anything that requires
molecular/marker data as a primary input rather than a gene-drop simulation seed** —
marker-based kinship, empirical heterozygosity, parentage verification, and cross-center
identity resolution are uniformly absent, because the package's entire genetic-analysis
engine is pedigree-driven by design. Both clusters are coherent with the package's
apparent design intent (a pedigree-focused colony-management tool, not a
population-genomics analysis platform) rather than scattered oversights.

## Recommendations

1. If center-specific ranking priority or multiple breeding-group candidates are wanted,
   they are the two highest-value, most PDF-aligned feature additions — both would need
   new BACKLOG/issue items and design discussion (which ranking dimensions are
   swappable; how many candidate groups to retain and how to present them) before any
   implementation session.
2. Kinship/genome-uniqueness distribution shape statistics (skewness, kurtosis) would be
   a comparatively small, well-scoped addition to `R/makeGeneticSummaryTable.R` /
   `R/summarizeKinshipValues.R` if wanted.
3. Marker-based kinship/heterozygosity/parentage-verification and cross-center identity
   resolution are large, architecturally distinct features (would require ingesting and
   analyzing real genotype data as a primary signal, not a gene-drop seed) — treat as
   separate future initiatives requiring their own scoping/design session, not quick
   additions.
4. Surface `correctUnknownParentMeanKinship()`'s `flagged` (uncorrected-animal) output
   somewhere user-visible (report column, warning) — a small, low-risk fix.
5. No action item is implied for NGS/MHC-specific/LD-block methods — the source
   document itself treats these as speculative future work, not a present-day gap.

This document does not recommend committing to any of the above as this session's next
task — that is the owner's call, matching this project's own "ask, don't infer" and
"observation vs. decision" conventions.
