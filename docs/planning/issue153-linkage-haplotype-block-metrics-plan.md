## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Issue #153 — Linkage-Aware and Haplotype-Block Metrics for Marker Data

**Status:** Pre-RED design/architecture document. Design-only session (Session 519,
2026-08-11) — zero `R/`/`tests/`/`man/` changes. Matches the #133/#136/#137/#145/
#146/#147/#149/#150/#151/#152 precedent: a design document is written and ratified
first; implementation happens in one or more later, separate sessions.

---

## 1. Context

### 1.1 What issue #153 says

Verbatim issue body:

> **Source:** `GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`: missing linkage-aware metrics.
>
> Current marker analyses treat loci independently; there is no LD-block, haplotype-block, or
> recombination-aware analysis.
>
> Design an optional linkage-aware marker layer that defines and validates locus-order/linkage
> metadata; selects colony-management-relevant block or linkage metrics; reports coverage and
> assumptions; and leaves independent-locus workflows unchanged by default. It should be
> independently scoped for curated marker panels even if future sequence support informs it.

Four explicit requirements, each mapped to a design decision below:
1. "Defines and validates locus-order/linkage metadata" → D1 (vocabulary), D2 (realism), D7
   (schema reuse).
2. "Selects colony-management-relevant block or linkage metrics" → D3 (the central metric-choice
   decision).
3. "Reports coverage and assumptions" → D2 (three-state coverage reporting), threaded through the
   interface catalog and Slice 5's UI.
4. "Leaves independent-locus workflows unchanged by default" → D6 (opt-in tab, zero changes to the
   5 existing tabs).

The closing sentence — "independently scoped for curated marker panels even if future sequence
support informs it" — is the direct textual source for the scope boundary against issue #152
(§1.2): #153 must work standalone against the *existing* marker family's scale (tens to low
hundreds of loci), not #152's ~50,000-locus sparse-SNP-panel tier, and must not require #152 to
ship first.

### 1.2 Already decided

- **Sequencing audit placement** (`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md`):
  #153 is Deferred-tier item 2 of 3 (#152 → #153 → #148), "sequenced second so its design can draw
  on #152's vocabulary if useful, and so a haplotype-vocabulary disambiguation exists before #148
  is picked up next" (`:268-269`). #152's design shipped and was ratified S517
  (`docs/planning/issue152-sequence-input-genetic-metrics-plan.md`); this document is the next
  item in that order, per S517's own explicit handoff (`BACKLOG.md:2205-2207`).
- **Vocabulary reservation** — #152's own D4 (ratified): "do not use 'haplotype' (reserved for
  #148's classical named-MHC-allele meaning) or 'block' (reserved for #153's LD-block meaning)"
  (`docs/planning/issue152-sequence-input-genetic-metrics-plan.md:300-304`). This design therefore
  **may** use "block"/"LD block"/"linkage block" freely, but must **never use bare "haplotype"**
  — the sequencing audit's own disambiguating phrase, "haplotype block" (a statistically-inferred
  LD-linked segment, vs. #148's "haplotype" = a classical named MHC allele combination), is adopted
  throughout this document as the qualified term (§2.2 confirms the audit's exact wording).
- **`locusMetadata` sidecar schema** — #152's D3 (ratified): `locus, chrom, pos` required,
  `cM` optional (`docs/planning/issue152-sequence-input-genetic-metrics-plan.md:289-298`),
  explicitly "shaped to be the shared vocabulary issue #153 ... can extend rather than reinvent."
  Reused verbatim here (D7) — not redefined.
- **Zero-Bioconductor policy** — issue #130's D2 (ratified Session 441): no Bioconductor
  dependency, CRAN-only (`docs/planning/issue130-marker-kinship-crosscenter-identity-plan.md:292-305`,
  reconfirmed directly this session, §2.4/§2.5).

### 1.3 This session's research confirmed

Two parallel background agents — a codebase-inventory agent (direct reads of
`R/modMarkerGenetics.R`, the full marker function family, #152's and #130's plans, `DESCRIPTION`,
both audits, existing fixtures, and the module contract) and a domain-research agent (locus-order
metadata realism, rhesus genetic-map resources, classical LD/haplotype-block methods and their
population-sample assumptions, CRAN package survey, recombination-aware kinship literature,
coverage-reporting precedent from other genetics software, and privacy implications of
haplotype-level data) — plus this session's own direct re-verification of the single most
load-bearing finding (`R/checkMarkerGenotypeFile.R:68-78`, quoted in full in §2.2). The headline
findings, in order of design impact:

1. **No function in the existing marker family treats loci as ordered or positioned** — confirmed
   by direct reads of all six functions (§2.2). Issue #153's stated premise is correct, not
   assumed.
2. **The existing marker-genotype ingestion path hard-rejects multiallelic loci** — but the one
   directly-sourced example of a real captive-colony STR panel in current use (de Groot et al.
   2025, §2.10) is 23 microsatellite markers, which are inherently multiallelic. This is a genuine,
   previously-undiscovered tension between this package's current ingestion contract and the data
   type colony genetics programs actually use — addressed head-on in D4, not glossed over.
3. **Genetic-map (cM) position is essentially unavailable for real colony marker panels** — de
   Groot et al. 2025's own 23-STR panel reports chromosome location only, no cM anywhere (§2.10).
   The design must treat sparse/absent locus-order metadata as the *common* case, not an edge case
   (D2).
4. **Every classical population-genetics LD/haplotype-block method surveyed assumes an unrelated,
   randomly-mating sample** — a captive pedigreed colony violates this by construction, and the
   violation is not theoretical: Excoffier & Slatkin (1998) is a named, peer-reviewed source
   showing that including relatives measurably biases these estimators (§2.11). The one genuinely
   pedigree-native computational method (Lander-Green multipoint IBD / MERLIN) is not
   CRAN-available (§2.11, §2.12).
5. **Haplotype/block-level statistics are more re-identifying than single-locus statistics, not
   less** — directly relevant to #152's already-established Homer et al. (2008) privacy finding;
   compounds it rather than being a separate concern (§2.15, D9).

---

## 2. Evidence-based inventory

### 2.1 `R/modMarkerGenetics.R` — module shape and plug-in point

One module, `modMarkerGeneticsUI(id)` / `modMarkerGeneticsServer(id, kinshipMatrix, pedigree)`
(`R/modMarkerGenetics.R:20-58`, `:135-330`). Root reactives: `rawGenotype` (`:146-151`, reads the
uploaded file via `getGenotypes()`) → `genotypeMatrixR` (`:153-160`, `checkMarkerGenotypeFile()` →
`buildMarkerGenotypeMatrix()`) → `markerKmat` (`:162-168`, `markerKinship(gmat)`). Five existing
tabs, each independently added by a prior slice: Kinship Comparison, Heterozygosity, Parentage
Exclusion, Cross-Center, Candidate Parent Assignment (`:43-54`). Wired into `appServer.R:438-442`;
`markerResults$markerKinshipMatrix` is the only reactive currently consumed outside the module
(by `modMatePairServer()`, issue #151 Slice 2). Mounted as a top-level tab in `R/appUI.R:251-255`.

A sixth tab, backed by a sixth returned reactive sourced from the same `genotypeMatrixR`/
`rawGenotype` root reactives, is the natural plug-in point — the exact shape #152's own D8 already
recommended for its sibling "Sequence Genetics" work, confirmed directly against this file rather
than assumed by analogy (D5).

### 2.2 The marker function family — independent-locus confirmed, biallelic-only confirmed

All six functions (`markerKinship()`, `markerObservedHeterozygosity()`,
`markerExpectedHeterozygosity()`, `markerFst()`, `markerParentageExclusion()`,
`markerParentageLikelihood()`) consume the same wide genotype-matrix shape produced by
`buildMarkerGenotypeMatrix()` and treat every locus independently — confirmed by direct reads of
each (kinship's KING-robust sum, `R/markerKinship.R:82-107`; heterozygosity's per-locus fraction
and unweighted mean, `R/markerHeterozygosity.R:41-111`; Fst's per-locus pooled-ratio estimator,
`R/markerFst.R:130-188`; parentage exclusion/likelihood's per-locus conflict/LOD sums,
`R/markerParentageExclusion.R:100-149`, `R/markerParentageLikelihood.R:160-313`). No `chrom`/
`pos`/`cM` concept exists anywhere in `R/` or `tests/` (`grep -rn "F_ROH|markerFROH|locusMetadata"
R/ tests/` returns zero hits — #152's own proposed `locusMetadata`/`F_ROH` work is design-only,
not yet implemented).

**The ingestion validator hard-rejects multiallelic loci — the load-bearing conflict for D4.**
`R/checkMarkerGenotypeFile.R:68-78`, read in full this session:

```r
alleleCounts <- tapply(
  c(genotype$allele1, genotype$allele2),
  rep(genotype$locus, 2L),
  function(a) length(unique(a[!is.na(a)]))
)
offendingLoci <- names(alleleCounts)[alleleCounts > 2L]
if (length(offendingLoci) > 0L) {
  stop("Marker genotype file has one or more loci with more than two ",
       "distinct alleles (the KING-robust estimator requires biallelic ",
       "markers): ", toString(offendingLoci), ".")
}
```

The function's own roxygen `@details` states why: "The KING-robust kinship estimator (Manichaikul
et al. 2010) is defined for biallelic markers only ... A locus with more than two distinct alleles
observed anywhere in the input is therefore rejected outright." This is a correct, deliberate
constraint *for `markerKinship()`* — but `buildMarkerGenotypeMatrix()` itself has no allele-count
logic (it only pivots to a wide `"lo/hi"`-string matrix, `R/buildMarkerGenotypeMatrix.R:38-52`),
meaning the biallelic restriction lives entirely in `checkMarkerGenotypeFile()`'s validation step,
not downstream — a new, sibling validator can bypass it without touching `markerKinship()`'s
existing contract at all (D4).

### 2.3 #152's `locusMetadata` schema — reused verbatim (D7)

`docs/planning/issue152-sequence-input-genetic-metrics-plan.md:289-298` (D3, ratified): a new,
additive, `id`-free sidecar table, columns **`locus, chrom, pos`, optionally `cM`**. Not yet
implemented (#152 Slice 1, which would create it, has not been built). #153 depends on this schema
existing eventually, addressed as an explicit ordering risk (§7 Dragon 1) rather than assumed away.

### 2.4 Issue #130 D2 — Bioconductor decline, reconfirmed

`docs/planning/issue130-marker-kinship-crosscenter-identity-plan.md:292-305`: native KING-robust
kinship implemented in base R specifically to avoid a Bioconductor dependency (`SNPRelate`/
`GENESIS` both Bioconductor-only); "a hard Bioconductor `Imports` is a real publishability risk."
§6 P5 (`:553-557`) states the decline is durable, revisitable only via a fresh `AskUserQuestion`
round, never silently. Directly relevant to D8 (CRAN-only package survey below).

### 2.5 `DESCRIPTION` — dependencies, reconfirmed

`DESCRIPTION:37-58`. Zero Bioconductor packages; zero genetics-specific CRAN packages (no
`kinship2`, `pedigree`, `genetics`, `adegenet`, `pegas`, `gap`, `poppr`). All existing marker
genetics (kinship, heterozygosity, Fst, parentage exclusion/likelihood) is hand-implemented in
base R. `Matrix` is already an `Import` (`:49`).

### 2.6 Source audit finding

`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md:70-76`, "Remaining priority gaps,"
item 2, verbatim, duplicated into issue #153's own body: "Linkage-aware metrics — current marker
analyses treat loci independently; there is no LD-block, haplotype-block, or recombination-aware
analysis." Framed by the same audit (`:58-60`) as "a capability boundary rather than a failure to
meet a present-day 2015 requirement" — i.e., new-ground work, not a regression fix.

### 2.7 Sequencing audit — vocabulary-overlap risk, quoted in full

`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md:100-103`: "**Vocabulary-overlap
risk:** #148 ('haplotype' = classical named MHC allele combinations) and #153 ('haplotype block' =
a statistically-inferred LD-linked segment) use the same word for different concepts — a future
session touching both should disambiguate rather than let two ad hoc representations diverge."
This document adopts exactly the audit's own resolution: "haplotype block" (qualified) or "LD
block"/"linkage block," never bare "haplotype," throughout (D1).

### 2.8 Existing fixtures — no bundled long-format panel exists at any scale

Confirmed via direct grep (`chrom|position|pos|genetic.map|cM` across every `test_marker*.R` file):
zero hits. The only bundled genotype fixture,
`inst/extdata/examples/obfuscated_rhesus_mhc_breeder_genotypes.csv`, is a single-locus wide-format
MHC file (Pathway A, pre-#130) — not the D1 long-format schema (`id, locus, allele1, allele2`)
#153 would extend. Every long-format test fixture is a tiny hand-built inline matrix (2-10 loci,
2-4 individuals, e.g. `tests/testthat/test_markerKinship.R:26-33`). **No fixture anywhere
exercises a multiallelic locus** — Slice 1 must build one from scratch (§5).

Upload path: `getGenotypes()` (`R/getGenotypes.R:19-43`) → `checkMarkerGenotypeFile()` (§2.2) →
`buildMarkerGenotypeMatrix()`. `accept = ".csv"` only (`R/modMarkerGenetics.R:32-38`); no
`shiny.maxRequestSize` configured anywhere (Shiny's 5 MB default applies silently).

### 2.9 Module contract — `docs/architecture/module-contract.md`

Six rules (`:24-46`): every server-argument-carrying-data must be `reactive()`; every returned
element must be `reactive()` (the only mechanically enforced rule, `tests/testthat/
test_moduleContract.R`); the returned vocabulary is stable/canonical, never per-consumer renamed;
return only what's read; upstream absence is `req()`, upstream malformedness surfaces as a real
error (no blanket `tryCatch`); every parameter is read and every return documented. A new module/
tab must add itself to `test_moduleContract.R`'s `moduleContractServers` list.

### 2.10 Domain research — locus-order metadata realism for curated marker panels

**de Groot, de Vos-Rouweler, Heijmans, Louwerse, Massen, Langermans, Bontrop & Bruijnesteijn
(2025), "Genetic Conservation and Population Management of Non-Human Primates: Parentage
Determination Using Seven Microsatellite-Based Multiplexes," *Ecology and Evolution* 15(4):e71216**
— a directly current (2025), directly on-point real captive-macaque-colony STR panel: 23
microsatellite markers across 15 of 20 rhesus autosomes (several markers necessarily share a
chromosome), mapped against Mmul_10 for chromosome location **only** — no cM/genetic-map distances
reported anywhere, including the supplement. Despite shared chromosomes, markers are explicitly
treated as independent for parentage determination; the "multiplex" groupings are PCR-amplification
convenience, not linkage. **This is strong, current evidence that the realistic default case for a
curated marker panel is little-to-no locus-order metadata, and that even panels with known
chromosome co-location are analyzed as independent today** — directly informing D2.

A secondary source, **Rogers et al. (2006), *Genomics* 87(1):30-38**, built a genuine cM-scale
linkage map from 241 rhesus microsatellite loci (2048 cM, 20 autosomes, 9.3 cM average spacing) —
confirming cM data *can* exist for rhesus microsatellites in principle, but no evidence was found
that current colony parentage panels (e.g., de Groot et al. 2025's 23 STRs) draw from or
cross-reference this map; panels are typically selected for heterozygosity/informativeness, not
coincidence with a 2006 linkage-mapping panel. **Flagged as uncertain**, not assumed either way.

Fine-scale rhesus recombination-map resources exist (Xue et al. 2020, *PLOS ONE* 15(8):e0236285,
LD-based from 18M SNPs; Versoza et al. 2023/2024, *Genome Biology and Evolution* 16(1):evad223,
pedigree-based, male-only) but require assembly reconciliation (rheMac2/8 vs. current Mmul_10) and
marker-position cross-referencing outside this package's scope to use as a curator-facing lookup.

### 2.11 Domain research — classical LD/haplotype-block methods and the pedigree-sample problem

Every classical method surveyed — pairwise **D′** (Lewontin 1964; caution paper: Hedrick 1987,
*Genetics* 117(2):331-341), pairwise **r²** (Hill & Robertson 1968), the **four-gamete rule**
(biallelic-only by definition), and the **Gabriel et al. (2002) confidence-interval block method**
(the Haploview default; Barrett, Fry, Maller & Daly 2005, *Bioinformatics* 21(2):263-265) —
implicitly assumes the sample is drawn at random from a population in linkage/gametic equilibrium
modulo the LD being measured. **A captive pedigreed colony genuinely violates this**, and the
violation is not merely theoretical: **Excoffier & Slatkin (1998), *American Journal of Human
Genetics* 62(1):171-180**, "Incorporating Genotypes of Relatives into a Test of Linkage
Disequilibrium," directly establishes that including known relatives biases/inflates population LD
test statistics, and proposes correcting for relative-genotype information explicitly rather than
ignoring or naively pooling it.

The one genuinely pedigree-native method found — multipoint IBD via the **Lander-Green algorithm**
(Lander & Green 1987, *PNAS*), implemented in **MERLIN** (Abecasis, Cherny, Cookson & Cardon 2002,
*Nature Genetics* 30:97-101), explicitly designed for "tens to thousands of markers" (squarely
#153's realistic scale) — conditions on the known pedigree rather than assuming population random
mating, and is therefore methodologically appropriate for exactly this data shape. **It is not
CRAN-available** (a standalone C/C++ tool, no maintained R interface confirmed) — directly relevant
to D3/D8's CRAN-only constraint.

### 2.12 Domain research — CRAN-only package survey

| Package | CRAN/Bioconductor | Pedigree-aware? | Multiallelic-capable? |
|---|---|---|---|
| `genetics` | CRAN, current | No — population-sample framing | Yes (genotype-class objects, general) |
| `LDheatmap` | **Archived on CRAN 2023-01-22**; hard transitive Bioconductor dep (`snpStats`) | N/A — disqualified | N/A — disqualified |
| `haplo.stats` | CRAN, current | No — vignette explicitly states subjects assumed unrelated | Yes, in principle, but built for phased-haplotype EM, not raw LD |
| `pegas` | CRAN, current | No — population-sample framing | Biallelic-only (`LDscan()`'s own stated constraint) |
| `gap` | CRAN, current; no Bioconductor Import/Depends | Mixed — family functions exist (kinship, `fbsize`) but LD/haplotype-EM functions (`genecounting`/`gc.em`) show no explicit relatedness correction in available docs (flagged uncertain, PDF manual not machine-readable) | Not confirmed either way |
| `adegenet` / `poppr` | Both CRAN | No — population/clonal-lineage framing (index-of-association family) | **Yes** — explicitly designed for multiallelic microsatellite data, unlike the SNP-oriented tools above |

**Net: no CRAN package is both pedigree-aware and multiallelic-capable.** `poppr`/`adegenet` is the
only multiallelic-native family; none corrects for relatedness the way Excoffier & Slatkin (1998)
recommends. This directly informs D8 (hand-roll vs. adopt) — no existing package cleanly solves
#153's actual data shape (pedigreed + multiallelic) without its own caveats.

### 2.13 Domain research — recombination-aware kinship (the D3 primary-metric source)

**Hill & Weir (2011), "Variation in Actual Relationship as a Consequence of Mendelian Sampling and
Linkage," *Genetics Research* 93(1):47-64** (PMC3070763) — the central citation for D3's primary
metric. Establishes that pedigree-*expected* relatedness (what this package's existing
`kinship2`-based pedigree kinship already computes) and the *actual, realized* proportion of
genome shared IBD diverge because of Mendelian sampling variance and linkage (finite chromosome
number/map length creates covariance in IBD status among nearby loci) — the variance of realized
relatedness around its pedigree-expected value depends on genetic-map length, not just pedigree
topology. **This is exactly the gap issue #153 names** ("recombination-aware... as opposed to
treating markers as independent") and, critically, **it is valid for a pedigreed sample by
construction** — it does not carry the random-mating-population assumption that invalidates §2.11's
classical methods for this project's data. It extends the kinship this package already computes
(`kinship()`) rather than requiring a new population-genetics framework. A companion paper (Hill &
Weir, PMC4694724) extends the same framework to inbred pedigrees.

Complementary grounding: **Powell, Visscher & Goddard (2010), *Nature Reviews Genetics*
11:800-805** clarifies IBD-vs-IBS reconciliation; **Browning & Browning (2013), *Genetics*
194(2):459-471** (Refined IBD/Beagle) is a named alternative for dense-SNP-scale population data,
not CRAN-available and not built for #153's modest-panel scale.

**Explicit research gap, carried into §7 Dragon 4:** this session's domain research named Hill &
Weir (2011) and its conceptual framework but did **not** extract the paper's actual closed-form
variance formula. Implementing D3's primary metric requires a literature deep-dive at the
implementing session, not a straightforward lift from this design document.

### 2.14 Domain research — coverage/assumptions reporting precedent

**PLINK** (Purcell et al. 2007, *American Journal of Human Genetics* 81(3):559-575): its
`.map`/`.bim` format structurally distinguishes "no genetic-map info" (cM column explicitly
allowed to be `0`/unknown) from "no physical-map info" (separate, mandatory bp column) — three
distinct, explicitly-reportable per-locus states, not a single pass/fail flag. PLINK's `--cm-map`
flag linearly interpolates missing cM from flanking markers with known genetic + physical position
— a concrete precedent for "fill the gap and report what was interpolated vs. observed," not
silent exclusion.

**Haploview** (Barrett et al. 2005): requires marker position in a separate info file; missing/
unparseable position → hard exclusion from block/LD analysis (exact warning wording unverified,
source page returned HTTP 403, but the exclusion behavior is corroborated by the paper's own
description).

**Design implication, directly informing D2 and the Slice 5 UI:** treat "has cM," "has chrom/pos
only," and "has neither" as three distinct, always-visible per-locus states (PLINK's model), and
where physical position exists but cM doesn't, an explicit, *labeled* interpolation option is
preferable to either silently treating interpolated cM as directly measured, or Haploview's harder
exclusion-only behavior — though given §2.10's finding that cM is essentially unavailable for real
colony panels, the interpolation path is likely to see little practical use; documented as a
possible enhancement, not a Slice 1-5 commitment (§7 Dragon 5).

### 2.15 Domain research — privacy: haplotype/block-level data is more identifying, not less

**Lin, Owen & Altman (2004), *Science* 305(5681):183**: genotype at only 30-80 statistically
independent SNP positions, considered *jointly*, is sufficient to uniquely identify a person from a
population reference — a multi-locus-combination argument structurally identical to what a
haplotype/LD-block statistic computes, as distinct from a single-locus allele-frequency table (the
shape #152's plan already established is not a privacy safe-harbor per Homer et al. 2008, but which
is markedly *less* identifying per this joint-combination logic). **Erlich & Narayanan (2014),
*Nature Reviews Genetics* 15:409-421** (the comprehensive, current review) catalogs several
identification routes that specifically exploit multi-marker/haplotype-scale patterns (e.g.,
Y-STR-haplotype surname inference). **Mechanistic conclusion:** a haplotype/block-level statistic
is, definitionally, a *joint* statistic over correlated loci; the number of distinguishable
combinations grows far faster than single-locus genotype counts — directly informing D9 (export
gating must be at least as strict as #152's single-locus exports, arguably stricter).

---

## 3. Design decisions

Nine decisions. D1, D2, D6, D7, D9 are **forced** by evidence already established (either directly
by prior ratified decisions this design must honor, or by directly-sourced literature with no real
alternative reading). D3, D4, D5, D8 are **judgment calls**, to be ratified via a single
`AskUserQuestion` round (§11).

**D1 (forced). Vocabulary: "LD block"/"linkage block"/"haplotype block" (qualified) throughout;
never bare "haplotype."** Directly required by #152's own ratified D4 (§1.2) and the sequencing
audit's vocabulary-overlap finding (§2.7). Applies to every UI label, roxygen doc, exported column
name, and this document itself.

**D2 (forced). Treat locus-order metadata (`chrom`/`pos`/`cM`) as typically sparse or absent, not
typically complete.** Directly grounded in de Groot et al. 2025 (§2.10) — the one directly-sourced
real colony STR panel reports chromosome only, no cM, and is analyzed as independent-locus despite
known chromosome co-location. The design (interface catalog, coverage reporting, and every metric)
must degrade gracefully through three explicit per-locus states — full (chrom+pos[+cM]), partial
(chrom or pos only), none — per the PLINK/Haploview precedent (§2.14), not assume a curator can
typically supply complete metadata.

**D3 (judgment call — the central metric-choice decision). Build two complementary metrics, not
one: (a) a genuinely pedigree-valid primary metric — a Hill & Weir (2011)-style realized-relatedness-
variance estimate, extending the existing pedigree `kinship()` with linkage/Mendelian-sampling
information; and (b) a clearly-caveated, secondary descriptive pairwise LD/block-flag statistic
(D′/r², same-chromosome pairs only, founder-restricted where identifiable) for exploratory use.**
Rationale: §2.11 establishes that every classical LD/block method is statistically inappropriate as
a *headline* metric for a pedigreed sample (Excoffier & Slatkin 1998), while §2.13 establishes that
Hill & Weir's framework is valid for exactly this data shape and extends work this package already
does. Building only (a) would leave "block" metrics — half the issue's own stated deliverable — with
no artifact at all; building only (b) would ship a metric with a known, cited statistical bias as
the tool's sole offering. **Recommended: build both, with (a) as the primary/headline artifact and
(b) explicitly labeled non-population-genetics-calibrated.** **Declined alternative:** restrict (b)'s
population estimation strictly to founder/unrelated individuals only (fully resolving the Excoffier
& Slatkin bias) — considered, but a small pedigreed colony may have very few identifiable founders,
risking a sample too small to be useful; adopted instead as an *optional* restriction within (b),
reported in the coverage/assumptions output, not a hard requirement.

**D4 (judgment call). Add a new, sibling ingestion validator (`checkLinkageMarkerGenotypeFile()` or
similar) that tolerates multiallelic loci, rather than reusing `checkMarkerGenotypeFile()`
unchanged.** §2.2 confirms the multiallelic rejection lives entirely in `checkMarkerGenotypeFile()`
— `buildMarkerGenotypeMatrix()` itself has no allele-count logic, so a sibling validator can be
added with **zero changes to `markerKinship()`'s existing biallelic contract**. §2.10's de Groot et
al. 2025 evidence establishes that real colony STR panels — the actual data type a "colony-
management-relevant" feature must handle — are multiallelic. **Recommended: build the sibling
validator (option b).** **Declined alternative:** reuse the existing biallelic-only path unchanged
(option a) — simplest, zero new code, but would make this feature literally inapplicable to the one
real-world panel type this session found direct evidence for, undermining the issue's own
"colony-management-relevant" requirement in practice, not just in principle.

**D5 (judgment call). Module boundary: a sixth tab inside the existing `modMarkerGenetics.R`, not a
new standalone module.** Matches #152's own D8 precedent (`docs/planning/issue152-sequence-input-
genetic-metrics-plan.md:346-357`) and this session's own confirmation (§2.1) that the upload/
reactive-wiring shape needed is already owned by this module. **Declined alternative:** a dedicated
`modLinkageGenetics.R` — rejected for the same reason #152 rejected it: duplicates tested scaffolding
with no functional reason to keep the concerns apart.

**D6 (forced). Default-off, independent-locus workflows unchanged.** Directly required by the
issue's own text. Implemented as a new, opt-in sixth tab; zero changes to the five existing tabs,
their reactives, or `markerKinship()`/`markerObservedHeterozygosity()`/etc.

**D7 (forced). Reuse #152's `locusMetadata` schema (`locus, chrom, pos[, cM]`) exactly — do not
redefine it.** §2.3/§1.2. Whichever of #152 or #153 ships its ingestion Slice first defines the
canonical validator; the other reuses it. If #153 is implemented before #152's own Slice 1 ships,
#153's Slice 1 authors a validator against the identical column names/schema so no divergent second
copy is created either way (§7 Dragon 1).

**D8 (judgment call). Hand-roll the pairwise D′/r² computation for D3(b) in base R, rather than
adding a CRAN dependency (`pegas`/`genetics`/`gap`).** §2.12 found no CRAN package that is both
pedigree-aware and multiallelic-capable, so no candidate package cleanly solves #153's actual data
shape without its own caveats regardless — adopting one would trade a small amount of formula-
writing effort for a new dependency without eliminating the need for this design's own caveat/
coverage layer. Matches this package's established self-contained-implementation philosophy
(kinship/heterozygosity/Fst are all hand-implemented; issue #130 D2's rationale, §2.4).
**Recommended: hand-roll.** **Declined alternative:** adopt `pegas` (closest fit, but biallelic-only
per its own `LDscan()` constraint — would reintroduce D4's exact problem) or `poppr`/`adegenet`
(multiallelic-capable, but a new dependency for a formula this package already has direct precedent
for writing itself) — revisitable at implementation time if hand-rolling proves materially harder
than expected (e.g., missing-data handling edge cases).

**D9 (forced). Any exported block/LD statistic table routes through the existing curator-controlled
de-identification gate (issue #150's pattern), at least as strictly as #152's single-locus
exports.** §2.15 establishes, via directly-named literature (Lin, Owen & Altman 2004; Erlich &
Narayanan 2014), that haplotype/block-level (joint, multi-locus) statistics carry *more*
identifying power than single-locus summary statistics, not less or the same — the #152 plan's
already-ratified D7 (which itself cites Homer et al. 2008 to establish single-locus summary
statistics are not a safe harbor) sets the floor, not the ceiling, for this feature's export
gating.

---

## 4. Interface catalog

| Function (proposed) | Slice | Input | Output | Error contract | New dependency? |
|---|---|---|---|---|---|
| `checkLocusMetadata()` | 1 | `data.frame(locus, chrom, pos[, cM])`, reused from #152 if shipped, else authored here to the identical schema | validated data frame + a 3-tier per-locus coverage classification (full/partial/none), per D2 | `stop()` on malformed schema (wrong columns, duplicate `locus` rows) — matches `checkMarkerGenotypeFile()`'s fail-fast convention | None |
| `checkLinkageMarkerGenotypeFile()` | 2 | Same 4-column long-format genotype table as `checkMarkerGenotypeFile()`'s input | Validated data frame, `>2`-allele-per-locus check **omitted** (D4); all other checks (column count/names, duplicate id×locus rows) retained | `stop()` on the retained checks only | None |
| `markerRealizedRelatednessVariance()` (name provisional) | 3 | Pedigree (existing `kinship2`-shaped object) + chromosome count or approximate genome map length (does **not** require per-locus `pos`, per D2's low-metadata-bar design) | Per-candidate-pair (or pedigree-wide) estimate of realized-relatedness variance around pedigree-expected kinship, D3(a) | `stop()` on missing/malformed pedigree input, matching existing `markerKinship()`-family conventions | None (formula TBD at implementation, §7 Dragon 4) |
| `markerLdBlock()` (name provisional) | 4 | Genotype matrix (from `checkLinkageMarkerGenotypeFile()` → `buildMarkerGenotypeMatrix()`, unchanged) + `locusMetadata` (same-chromosome pairs only) | Per-locus-pair D′/r² table with an explicit non-population-genetics-calibrated caveat field (module-contract rule 3: canonical, not droppable, vocabulary) + optional founder-only restriction flag, D3(b) | `stop()` if `locusMetadata` coverage is `none` for all loci (nothing computable); a documented, non-fatal per-pair `NA` for cross-chromosome/insufficient-coverage pairs | None (D8) |
| `obfuscateLdBlocks()` (name provisional) | 4 | An `markerLdBlock()` result table | De-identified sidecar, following the `obfuscateTwinRelations()` pattern | Matches existing `obfuscate*` family conventions | None |
| 6th tab in `modMarkerGeneticsUI`/`Server` | 5 | Wires the above into the existing module (D5) | New returned reactive(s), added to `test_moduleContract.R`'s server list (§2.9) | Module-contract rules 1-6 apply unchanged | None |

---

## 5. Implementation plan (5 slices, each its own future session)

**Slice 1 — Locus-metadata ingestion + coverage validator + fixture.** `checkLocusMetadata()` (D7,
reused/adapted from #152 if shipped by then); the 3-tier coverage classifier (D2); and — critically
— a **new, realistic multiallelic STR fixture** (`data-raw/` generator + a committed
`inst/extdata/examples/` CSV pair: long-format genotype + `locusMetadata`), since §2.8 confirms no
bundled fixture for the D1 long-format schema exists at any scale today, let alone a multiallelic
one. Done when: `checkLocusMetadata()` correctly classifies a hand-built mixed-coverage fixture
(some loci full, some partial, some none) into all three tiers; the new STR fixture round-trips
through the existing `buildMarkerGenotypeMatrix()` unchanged. Verification: new test file, existing
regression suite unchanged.

**Slice 2 — Multiallelic-tolerant ingestion path.** `checkLinkageMarkerGenotypeFile()` (D4), proven
against Slice 1's STR fixture; explicit regression proof that `checkMarkerGenotypeFile()`/
`markerKinship()`'s existing biallelic contract is completely untouched (a `git stash`-style
byte-identical comparison, matching this project's own established verification discipline). Done
when: the new validator accepts the multiallelic STR fixture that the existing validator correctly
rejects, and the full existing marker-family regression suite is unchanged.

**Slice 3 — Realized-relatedness-variance metric.** The primary new statistic (D3a). **Requires its
own literature deep-dive first** — this design document names Hill & Weir (2011) and its conceptual
framework but does not extract the closed-form variance formula (§2.13, §7 Dragon 4); the
implementing session's own PRE-RED step must do that derivation/verification before RED tests can be
written. Done when: the function produces a validated estimate against a hand-derived small-pedigree
case (e.g., full-sib vs. half-sib comparison) with a cited, checkable formula.

**Slice 4 — Descriptive LD/block statistic + de-identification primitive.** `markerLdBlock()` (D3b,
D8: hand-rolled D′/r², same-chromosome pairs, optional founder restriction) and `obfuscateLdBlocks()`
(D9). Done when: the pairwise statistic matches a hand-computed small-case reference value; the
de-identification primitive round-trips through the existing `obfuscate*` test pattern.

**Slice 5 — Full module tab, wiring, documentation.** Sixth tab in `modMarkerGenetics.R` (D5, D6);
UI coverage-report panel (three-tier, D2/§2.14) and a persistent, non-dismissable caveat banner on
D3(b)'s output; curator-controlled export wiring reusing #150's confirm-gate pattern (D9);
`NEWS.Rmd` entry; tutorial/article update (`vignettes/articles/colony-manager-guide.qmd`); citation
checklist (`population_genetics_terms.html` + roxygen `@references` for Hill & Weir 2011, and
whichever D′/r² source formula Slice 4 actually implements against); `_pkgdown.yml` entry; add the
new server to `test_moduleContract.R`'s list (§2.9). Done when: the tab is reachable in a running
app, `devtools::check()` is clean, and every close-out checklist in §9 is satisfied.

---

## 6. Impact analysis

| System | Impact | Action required |
|---|---|---|
| Existing 5 `modMarkerGenetics.R` tabs / 6 marker functions | None — D6 | None |
| `checkMarkerGenotypeFile()` / `markerKinship()` | None — new sibling validator only, D4 | Regression-prove untouched (Slice 2) |
| `DESCRIPTION` | None, if D8's hand-roll recommendation holds | None (revisit only if D8 is overturned at implementation) |
| Issue #152's `locusMetadata` | Consumed/extended, not duplicated (D7) | Coordinate whichever slice ships first defines the canonical validator |
| Issue #150's de-identification gate | Extended with a new sidecar primitive (D9), not modified | None to the existing gate itself |
| `test_moduleContract.R` | New server added to its list (§2.9) | Slice 5 |

---

## 7. Here be dragons

1. **Ordering/schema-coupling risk with #152.** `locusMetadata` (D7) is currently unimplemented in
   both plans. If #153 is picked up before #152's own Slice 1 ships, #153's Slice 1 must author a
   compatible validator to the identical schema, not a divergent one — and if #152 ships first,
   #153 must actually reuse it, not silently re-derive a second copy. Needs active coordination
   at whichever slice ships second.
2. **The multiallelic-tolerant ingestion path (D4) is new, untested code on a data shape this
   package has never processed at panel scale before.** The only existing bundled genotype fixture
   is single-locus. Slice 1's new STR fixture needs deliberate realism — consulting de Groot et al.
   2025's panel design (not necessarily its literal data, which may not be freely redistributable;
   verify licensing before copying any real published genotypes) rather than an arbitrary
   placeholder.
3. **No CRAN-available, pedigree-aware, rigorous LD-block/multipoint-IBD method exists** (§2.11,
   §2.12). D3(b)'s descriptive statistic is a genuine compromise, not a rigorous
   population-genetics-valid haplotype-block caller — this is an inherent statistical limitation of
   what's buildable without a new dependency or a much larger research investment, not an
   implementation gap. The Slice 5 UI caveat is the only safeguard against a user over-trusting it;
   do not let a future session quietly drop or soften that caveat.
4. **D3(a)'s Hill & Weir formula has not been derived or verified in this session** (§2.13) — real
   research risk carried forward to Slice 3, flagged explicitly rather than assumed straightforward.
5. **cM data realism (D2) means most real-world use likely lands in the "chrom-only" or "no
   metadata" coverage tier**, not genuine cM-distance-aware block calling — the design should not
   oversell "block" detection as a headline capability given this; D3(b)'s same-chromosome-pairs-
   only scope is a deliberate, evidence-grounded downgrade from a full recombination-distance-aware
   block caller, not an oversight.
6. **D9's exact export-gating mechanism is deferred to Slice 4** — this document names the
   requirement (route through #150's pattern, at least as strictly as #152), not the specific new
   primitive's shape.
7. **Vocabulary discipline (D1) requires ongoing vigilance** — a future editing pass (e.g. a global
   rename) could accidentally reintroduce the "haplotype" collision with #148 if not deliberately
   checked at each slice's close-out.

---

## 8. Alternatives considered

| Alternative | Pros | Cons | Why rejected |
|---|---|---|---|
| Full multipoint-IBD via a Lander-Green/MERLIN wrapper | Rigorous, genuinely pedigree-native, field gold-standard | Not CRAN-available (standalone C/C++ tool); would require shelling out to an external binary or a from-scratch HMM reimplementation | Exceeds design-only/self-contained-R scope; reopens the no-external-genetics-tool precedent (issue #130 D2) this package has consistently held |
| Classical Gabriel et al. 2002 / Haploview-style block calling as the *primary* (not secondary) metric | Familiar, field-standard | Assumes an unrelated/random-mating sample — directly biased by relatedness (Excoffier & Slatkin 1998); needs cM/dense positions rarely available for colony panels (§2.10) | Statistically inappropriate as the headline metric for this data (D3) |
| Adopt `LDheatmap` | Purpose-built, decades of field use | Archived on CRAN (2023-01-22); hard transitive Bioconductor dependency (`snpStats`) | Disqualified twice over — CRAN availability and the zero-Bioconductor policy (§2.12) |
| Keep the existing biallelic-only ingestion path unchanged (D4 option a) | Zero new validator code | The one directly-sourced real colony panel type (STRs) is multiallelic — feature would be unusable against realistic data | Fails the issue's own "colony-management-relevant" requirement in practice, not just in principle |
| A dedicated `modLinkageGenetics.R` module (D5 alternative) | Matches the #149/#150/#151 one-feature-one-module convention | Duplicates tested upload/reactive scaffolding `modMarkerGenetics.R` already owns, with no functional reason to keep concerns apart | Same rationale #152's own D8 already established |
| Adopt `pegas`/`gap`/`poppr` instead of hand-rolling D′/r² (D8 alternative) | Mature, tested edge-case handling | `pegas` is biallelic-only (reintroduces D4's problem); `poppr`/`gap` add a dependency for a formula this package already has direct precedent for hand-writing | Consistent with existing self-contained-implementation philosophy; revisitable at implementation time |

---

## 9. Close-out checklist mapping

Design-only session — zero `R/`/`tests/`/`man/` changes. All checklists below are **N/A this
session**, each owed at the specific future slice that first triggers it:

- **Citation checklist (issue #120)** — owed at Slice 3 (Hill & Weir 2011) and Slice 4 (whichever
  D′/r² source formula is actually implemented against): update
  `inst/extdata/ui_guidance/population_genetics_terms.html` + roxygen `@references`.
- **`NEWS.Rmd` entry checklist** — owed at Slice 1 or 2, whichever first ships an exported function.
- **Tutorial/article checklist** — owed at Slice 5 (new Shiny tab):
  `vignettes/articles/colony-manager-guide.qmd`.
- **`_pkgdown.yml` reference-coverage checklist** — owed at Slice 1 or 2, whichever first ships an
  exported function.
- **`a2interactive.Rmd` script-callable-function checklist** — deferred further per its own standing
  rule (after the feature stabilizes, not same-session even at implementation).
- **GitHub issue close-out** — N/A: issue #153 stays open, design ratified not implemented, matching
  every precedent in this cluster.
- **Lint close-out** — N/A this session, no `.R` files touched.

---

## 10. Provenance

- **Session:** 519, 2026-08-11.
- **Research:** two parallel background agents — an `Explore`-type codebase-inventory agent (direct
  reads of `R/modMarkerGenetics.R`, the full marker function family, #152's and #130's plans,
  `DESCRIPTION`, both audits, existing fixtures, `docs/architecture/module-contract.md`, and five
  sibling design documents' structural templates) and a `general-purpose` domain-research agent
  (locus-order metadata realism, rhesus genetic-map resources, classical LD/haplotype-block methods
  and their population-sample assumptions, CRAN package survey, recombination-aware kinship
  literature, coverage-reporting precedent, and privacy implications of haplotype-level data) —
  plus this session's own direct re-verification of the single most load-bearing finding
  (`R/checkMarkerGenotypeFile.R:68-78`) and re-read of #152's D3/D4 decisions verbatim.
- **Issues referenced:** #153 (this document), #152 (vocabulary/schema source), #148 (vocabulary
  boundary, not designed here), #130 (Bioconductor decline), #150 (de-identification pattern),
  #147 (LOD-statistic precedent for Slice 3's own future citation-style template).
- **Audits referenced:** `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`,
  `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md`.

---

## 11. Ratification status

**Forced (no owner decision needed):** D1 (vocabulary), D2 (metadata-sparsity assumption), D6
(default-off), D7 (schema reuse), D9 (export-gating floor).

**Judgment calls (owner ratification via a single `AskUserQuestion` round):** D3 (build both a
pedigree-valid primary metric and a caveated descriptive secondary metric, vs. one or the other
alone), D4 (add a multiallelic-tolerant sibling validator, vs. keep biallelic-only), D5 (sixth tab
in `modMarkerGenetics.R`, vs. a dedicated new module), D8 (hand-roll D′/r², vs. adopt a CRAN
package).

### Ratification outcome

Owner selected this document's own recommended option in all four judgment calls, via a single
`AskUserQuestion` round (Session 519, 2026-08-11):

- **D3:** Build both metrics — the Hill & Weir (2011)-style pedigree-valid primary metric AND the
  caveated descriptive secondary LD/block statistic.
- **D4:** Add the multiallelic-tolerant sibling ingestion validator (`checkLinkageMarkerGenotypeFile()`
  or similar) — real colony STR panels must be ingestible.
- **D5:** Sixth tab inside the existing `modMarkerGenetics.R`, not a dedicated new module.
- **D8:** Hand-roll the D′/r² computation in base R — no new CRAN dependency.

All nine design decisions (D1-D9) are now ratified. This document is ready for pickup by a future
implementation session, starting with Slice 1 (§5).
