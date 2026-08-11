# Issue #152 Plan — Whole-Genome/Whole-Exome Sequence Input + Sequence-Based Genetic Metrics

**Session:** S517 (2026-08-11) · **Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`
· **Type:** design/architecture document, matching the #133/#136/#137/#145/#146/#147/#149/#150/#151
precedent — **zero `R/`/`tests/`/`man/` changes this session.**

---

## 1. Context

### 1.1 What issue #152 says (verbatim)

> ## Source
>
> `GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`: missing NGS / whole-genome / whole-exome
> input and analysis.
>
> No sequence-data model, ingestion path, or sequence-based metric currently exists.
>
> Create a design plan covering supported input forms and preprocessing boundaries; animal identity
> and QC metadata; an initial scientifically justified metric set; interaction with pedigree/marker
> analyses; storage, privacy, and compute constraints; and realistic validation fixtures. This is
> design/discovery work, not a request for an unbounded sequence-analysis platform.

Confirmed via direct `R/` search: zero hits for "VCF"/"whole genome"/"whole exome"/"sequence-based"
anywhere in source, docs, or tests. This is genuinely new ground, not an extension of an
under-documented existing feature.

### 1.2 What is already decided (do not re-litigate)

- **`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md`** places #152 in the
  "Deferred/scientific" tier, ranked ahead of sibling #153 (linkage-aware/haplotype-block metrics)
  specifically *"since its output could usefully inform #153's linkage-metadata vocabulary"* — this
  design should define locus/position vocabulary #153 can reuse, not invent a second, divergent one.
  Both #152 and #153 are explicitly filed as **design-only asks**, distinct from #148 (MHC), which
  the same audit flags as filed *too broad* and needing its own scope-narrowing conversation before
  any design work (Finding #4) — #152 does not touch MHC/haplotype-naming territory at all.
- **`docs/planning/issue130-marker-kinship-crosscenter-identity-plan.md` D2 (ratified, Session 441)
  is the single most load-bearing prior decision for this design:** marker kinship is native
  KING-robust, hand-implemented in base R, **explicitly declining `SNPRelate`/`GENESIS` because both
  are Bioconductor-only** and `nprcgenekeepr` is CRAN-published (v2.0.0) with zero Bioconductor
  dependencies today (`DESCRIPTION:39-58`, reconfirmed this session, still zero). The plan's own P5
  warns explicitly: *"If a future slice's implementing session is tempted to reach for
  `SNPRelate`/`GENESIS` 'just for this one thing,' that reopens a decision this plan explicitly
  closed — flag it loudly and bring it back to an `AskUserQuestion`."* §3 D1 below addresses this
  directly, not silently.
- **Issue #150's de-identification precedent** (`obfuscateId()`, `obfuscateDate()`, `obfuscatePed()`,
  `obfuscateTwinRelations()`, `R/modDeidentifiedExport.R`) is the established curator-controlled
  -export pattern: named-vector alias maps, a distinctly-labeled separate re-identification-key
  download, a transformation manifest, and an explicit disclaimer that "curator-controlled" means a
  confirmation dialog and warning text, **not real access control** — there is no auth/role
  infrastructure anywhere in this codebase (confirmed independently by the sequencing audit's own
  Finding #3). Any sequence-data privacy design must interact with this pattern, not invent a
  parallel one.
- **`docs/architecture/module-contract.md`** (issue #122) governs any new Shiny module: reactive-in
  /reactive-out only, a stable return vocabulary, `req()` for upstream absence vs. a surfaced error
  for upstream malformedness (never a blanket swallowing `tryCatch`), every parameter read and every
  returned reactive documented. `modInput.R` is the reference implementation.
- **No performance/benchmark test exists anywhere in the package** for any marker-genetics function
  (confirmed: zero hits for `system.time`/`microbenchmark`/`bench::` across `R/`/`tests/testthat/`).
  Every existing marker test uses 2-4-locus, 2-4-individual toy fixtures. The existing functions have
  never been exercised at any scale beyond a hand-built example — this design cannot assume they
  "just work" at panel scale; §2.2 quantifies exactly which ones would not.

### 1.3 What this session's research confirmed

Two parallel research passes this session (a codebase-inventory `Explore` agent, a domain-research
`general-purpose` agent), cross-checked against direct reads of the issue #130 plan and
`DESCRIPTION`:

- The package has **two separate, non-interoperable genotype-input pathways today**, neither of which
  can represent whole-genome-scale data (§2.1).
- The existing marker function family's algorithmic complexity is dominated by `markerKinship()`'s
  **O(n²·L) nested-pair R loop** and `markerParentageLikelihood()`'s **O(F·C·L·n) redundant
  per-candidate allele-frequency rescan** — both untested at any real scale, both structural
  bottlenecks independent of the biallelic-vs-multiallelic question (§2.2).
- The captive-pedigreed-macaque-colony literature already answers the "how much sequence data is
  realistic" question with a concrete, directly-applicable precedent: a **sparse genotyping-by
  -sequencing (GBS) panel (~22,455 markers) plus pedigree-aware imputation from a handful of
  full-WGS-depth animals** (Bimber et al. 2016) — not per-animal whole-genome sequencing (§2.8).
- Raw VCF ingestion is off the table on **pure scale grounds**, independent of any privacy argument:
  a 1000-Genomes-scale joint VCF is a 144 GB file (§2.8).
- Summary statistics computed from genotype data (exactly the shape of kinship/heterozygosity/Fst/ROH
  outputs this design would produce) are **not automatically a privacy safe-harbor** — Homer et al.
  2008 showed re-identification is possible from aggregate statistics alone (§2.8) — so this design's
  privacy treatment must cover derived outputs, not just raw genotypes.

---

## 2. Evidence-based inventory

### 2.1 Existing genotype-input pathways — read in full, both are structurally incompatible with genome-scale data

**Pathway A — single-locus wide format** (`R/checkGenotypeFile.R:39-68`, `R/getGenotypes.R:19-43`,
`R/addGenotype.R:30-55`) — the original, pre-#130 path, feeding `geneDrop()`.

- Format: `id` + exactly two more columns (any names except the reserved `"first"`/`"second"`),
  interpreted as the two alleles of **one locus only**. No multi-locus support at all — structurally
  a single-locus format, not a small-panel one.
- `addGenotype()` (`R/addGenotype.R:42`) encodes each unique allele string as an arbitrary integer
  starting at `10000L + 1`; `checkGenotypeFile()`'s validation is a collision guard against that
  encoding space (rejects any allele value parsing as an integer > 10000), not a locus- or
  allele-count cap.
- The only real bundled example fixture in the repo touching genotype data at all
  (`inst/extdata/examples/obfuscated_rhesus_mhc_breeder_genotypes.csv`, 31 rows) uses this pathway —
  columns `id, first_name, second_name`, free-text MHC-haplotype-nomenclature allele labels like
  `"A004_B002"`. This is real captive-colony data, but it is single-locus and out of scope for a
  variant/SNP-panel design.

**Pathway B — long-format multi-locus marker schema** (`R/checkMarkerGenotypeFile.R:49-81`,
`R/buildMarkerGenotypeMatrix.R:38-52`) — from issue #130, the schema this design must extend.

- Format: `id, locus, allele1, allele2`, one row per (individual × locus).
- Validation hard-rejects any locus with more than 2 distinct alleles anywhere in the file
  (`checkMarkerGenotypeFile.R:73-78`) — a real, load-bearing constraint the KING-robust math depends
  on (§2.2), and one this design deliberately does not need to relax: real biallelic-SNP panels are
  the target input shape (§2.8), not multiallelic microsatellite/MHC panels (#148's territory).
- `buildMarkerGenotypeMatrix()` pivots the long table into a **dense `id × locus` character matrix**,
  each cell a sorted `"lo/hi"` allele string — the shared input every marker function below consumes.
- **No bundled example fixture exists anywhere in the repo for this schema** — confirmed by direct
  search; only inline 2-4-row test fixtures exist. This is a pre-existing gap from issue #130's own
  plan (its own P3 note: "this plan does not commit to which [fixture]; that choice belongs to Slice
  1's Pre-RED") that was apparently never resolved. §5 Slice 1 below treats generating one as a
  required deliverable — useful beyond #152 alone.

### 2.2 The marker function family — complexity, scale ceiling, and biallelic-assumption audit

All six consume `buildMarkerGenotypeMatrix()`'s dense `id × locus` matrix.

| Function | Method (citation) | Complexity | Biallelic-hardcoded? | Genome-scale verdict |
|---|---|---|---|---|
| `markerKinship()` (`R/markerKinship.R:64-109`) | KING-robust (Manichaikul et al. 2010) | **O(n²·L)** — explicit nested nested `for (i) for (j)` pair loop (`:82-107`) plus an up-front `strsplit()` over the *entire* n×L matrix (`:68`) | Yes — het/hom classification terms only defined for 2 alleles | **Breaks first.** At a few hundred individuals and a 20K-100K-locus panel, pairs alone run to the hundreds of thousands, each doing work over up to 100K loci. Must be rewritten before any genome-scale claim ships (§3 D3). |
| `markerParentageLikelihood()` (`R/markerParentageLikelihood.R:160-313`, issue #147) | CERVUS-style multilocus LOD (Meagher & Thompson 1986; Marshall et al. 1998) | **O(F·C·L·n)** — rescans the *entire* locus column from scratch for every (offspring, candidate, locus) triple (`:236`), with zero caching across candidates sharing the same locus | Yes — 2-allele Hardy-Weinberg genotype-probability model hardcoded (`:371-406`) | **Second-worst.** Invisible at panel scale (tens of loci); a severe, purely structural inefficiency at genome scale — the redundant rescan, not the algorithm itself, is the problem (§3 D3). |
| `markerObservedHeterozygosity()` / `markerExpectedHeterozygosity()` (`R/markerHeterozygosity.R:41-111`) | Fraction-heterozygous per animal; Nei's gene diversity `He = 1-Σpᵢ²` | O(n·L), linear | No — math is allele-count-agnostic; only ever *receives* biallelic input via the upstream gate | Tractable; still worth a single scale benchmark before claiming it works at target scale, not assumed (§3 D5). |
| `markerFst()` (`R/markerFst.R:130-188`) | Hudson's estimator (Hudson, Slatkin & Maddison 1992; Bhatia et al. 2013's ratio-of-sums pooling) | O(L), linear, best-scaling in the family | Yes — `pA(1-pB)+pB(1-pA)` is the 2-allele closed form | Tractable at target scale (§3 D5). |
| `markerParentageExclusion()` (`R/markerParentageExclusion.R:100-149`) | Deterministic Mendelian opposite-homozygote exclusion (Cifuentes et al. 2006; de Groot et al. 2025) | O(n·L), linear | No — logic is allele-count-agnostic | Tractable; `maxExclusions` default (2L) is explicitly documented as calibrated for small panels and would need retuning at genome scale (`markerParentageExclusion.R:36-40`) — flagged, not solved, by this design (§7 Dragon 3). |
| `resolveCrossCenterIds()` (`R/resolveCrossCenterIds.R`, issue #149) | Pedigree merge, not a genotype-statistics function | O(mapping rows), unrelated to locus count | n/a | Orthogonal — operates on pedigrees, not genotypes. Not in this design's scope. |

### 2.3 `modMarkerGenetics.R` module shape and `appServer.R` wiring

Five passive read-only `DT` tabs (Kinship Comparison, Heterozygosity, Parentage Exclusion,
Cross-Center, Candidate Parent Assignment; `R/modMarkerGenetics.R:43-54`). Two `fileInput()`s,
`accept = ".csv"` only (`:32-38`). **No file-size limit configured anywhere in the app** — confirmed
zero hits for `shiny.maxRequestSize` repo-wide — so Shiny's built-in 5 MB default upload cap silently
applies today, including here. `modMarkerGeneticsServer()` deliberately does **not** wrap
`checkMarkerGenotypeFile()`/`buildMarkerGenotypeMatrix()`/`markerKinship()` in a swallowing
`tryCatch` (`:140-143`, matching module-contract rule 5). Returns 9 named reactives, including
`markerKinshipMatrix` — wired into `appServer.R:430-455` and, since issue #151, threaded onward into
`modMatePairServer()`. Any new sequence-data surface must preserve this contract, not bypass it.

### 2.4 De-identification pattern (established, issue #150)

`obfuscateId()` returns a named-vector alias map (`names = originalId, values = alias`) — the
recurring convention. `obfuscatePed()` orchestrates: alias `id`/`sire`/`dam`, **drop** (not alias)
`name` as the one field treated as irreducibly PII, shift Date columns. `obfuscateTwinRelations()`
is the existing precedent for **extending de-identification to a sidecar table** `obfuscatePed()`
itself cannot reach: it consumes the same alias map and `stop()`s (never silently drops) on an id
missing from that map. `R/modDeidentifiedExport.R` is the shipped UI shape: Configure & Preview →
`modalDialog()` confirm gate → separately-labeled downloads (data, manifest, re-identification key),
explicitly documented as "confirmation dialog + warning text, not real access control."

### 2.5 `DESCRIPTION` dependencies

`Imports`: `anytime, bslib, data.table, DT, futile.logger, ggplot2, htmlTable, lifecycle, lubridate,
Matrix, openxlsx, plotrix, readxl, Rlabkey (>= 3.2.0), sessioninfo, shiny, stringi, utils, visNetwork`.
**Zero genomics-specific dependencies** — no Bioconductor package, no `vcfR`/`SNPRelate`/`GENESIS`/
`Rsamtools`/`GenomicRanges`. This is the deliberate, ratified §1.2 D2 decision, not an oversight.
**`Matrix` is already an Import** — directly relevant to §3 D3's proposed matrix-algebra rewrite of
`markerKinship()`, which needs no new dependency to become vectorized.

### 2.6 `module-contract.md` requirements (summary)

`modXUI(id) -> tagList`; `modXServer(id, <reactive args>) -> named list of reactive()s` over a stable
vocabulary. Six binding rules: (1) every server data argument is a `reactive()`; (2) every returned
element is a `reactive()` (the only mechanically enforced rule, via `test_moduleContract.R`); (3)
stable/canonical return vocabulary; (4) no unread returned reactives; (5) `req()` for upstream
absence, a surfaced error for upstream malformedness — no blanket swallowing `tryCatch`; (6) every
parameter read, every return documented. Reference implementation: `modInput.R`.

### 2.7 Domain grounding — sequence data reality

**Input format.** VCF (Danecek et al. 2011, *Bioinformatics* 27(15):2156-2158) is the confirmed
standard downstream artifact from any alignment+variant-calling pipeline: `CHROM, POS, ID, REF, ALT,
QUAL, FILTER, INFO` fixed fields, then `FORMAT` + one column per sample; genotypes (`GT`) are
**allele indices** (`0`=REF, `1`/`2`/…=ALT in `ALT`'s listed order — this is how multiallelic sites
are represented); ploidy = index count in `GT` (diploid macaques: two, exactly like human VCF);
missingness is a literal `.`/`./.`. A colony-management tool has no reason to ingest this directly —
the realistic handoff is a **pre-filtered, pre-flattened tabular genotype matrix** (biallelic-SNP
subset, MAF/missingness-filtered, `bcftools`/PLINK-style preprocessing already applied upstream by a
genetics core), not raw VCF, not raw PLINK BED/BIM/FAM.

**Scale.** Order-of-magnitude figures, weakest-to-strongest evidence at the top:

| Data type | Order of magnitude | Source |
|---|---|---|
| Existing in-package marker panel | 2-10 loci | package as shipped |
| **Captive/pedigreed macaque-colony GBS sparse panel (direct precedent)** | **~22,455 markers**, ~125 kb spacing, imputed from 4 full-WGS animals to >14M variants (~85-88% imputation accuracy) | Bimber et al. 2016, *BMC Genomics*, PMC4997765 |
| Rhesus macaque WES (exome-targeted) | ~84,000 SNVs/sample within capture | Belkadi et al. 2015 (human proxy); Chan et al. 2021, *J Med Primatol*, PMC8407272 (NHP capture feasibility, human reagents) |
| Rhesus macaque WGS, early study | ~3-5.5M variants | Chinese rhesus resequencing, PMC3218825 |
| Rhesus macaque WGS, large cohort | **>43.7M SNVs** (133 animals, 26.7× mean coverage) | Xue et al. 2016, *Genome Research* 26(12):1651 |
| `SNPRelate`'s own stated design envelope | "tens of thousands of samples with millions of SNPs" | Zheng et al. 2012, *Bioinformatics* 28(24):3326 |

The scale mismatch versus the existing 2-10-locus design is **3-5 orders of magnitude**. Critically,
the one directly-relevant captive-pedigreed-NHP-colony precedent (Bimber et al. 2016) does **not**
sequence every animal at full WGS depth — it uses a sparse GBS panel on most animals, WGS on only a
handful of "informative" individuals, and pedigree-aware imputation for the rest. This is a strong,
domain-native answer to "what scale is realistic," not an arbitrary cutoff this design invents.

**Sequence-based metrics literature (captive/managed-population genetics, not human GWAS):**

- **Genome-wide SNP kinship (KING-robust)** — already implemented (`markerKinship()`); the same
  estimator PLINK2/`SNPRelate::snpgdsIBDKING()`/`GENESIS::kingToMatrix()` run at genome-wide scale.
  Generalizes directly; only the *implementation strategy* needs to change (§3 D3), not the math.
- **Genomic inbreeding coefficient / Runs of Homozygosity (F_ROH)** — Ceballos, Joshi, Clark, Ramsay
  & Wilson 2018, *Nature Reviews Genetics* 19:220-234 (standard review); direct captive-
  breeding-program precedent in scimitar-horned oryx, *PNAS* 2022, doi:10.1073/pnas.2210756120. The
  single highest-leverage **new** capability: a sequence-verified inbreeding estimate independent of
  (often incomplete) pedigree records, complementing rather than duplicating the package's existing
  pedigree-based kinship/founder metrics.
- **Genome-wide observed/expected heterozygosity** — existing per-locus formulas generalize directly;
  no new estimator needed, only more loci.
- **Fst** — `markerFst()`'s Hudson estimator likewise generalizes trivially.
- **Effective population size (Ne) from LD decay** — Waples & Do 2008; Do et al. 2014 (*NeEstimator
  v2*); Waples 2024. Requires pairwise LD, which requires chromosome/locus-order/genetic-map
  metadata — **exactly** issue #153's own stated deliverable. This is the explicit #152/#153 scope
  boundary (§3 D8).

**Storage/privacy/compute.** A 1000-Genomes-scale joint VCF (1,092 individuals, 39.7M variants) is
144 GB; a 150,000-genome joint VCF would occupy ~900 TiB (PMC10802441) — raw VCF ingestion is
infeasible for a Shiny `fileInput`/in-process-R workflow on scale grounds alone, independent of any
privacy argument. Shiny's documented default upload limit is 5 MB, raised only via
`shiny.maxRequestSize`; reverse-proxy layers impose independent caps that must also be raised. A
filtered/summarized tabular genotype matrix in the tens-of-MB range is realistic for a `fileInput`;
raw multi-GB VCF is not. On privacy: **Homer et al. 2008** (*PLoS Genetics* 4(8):e1000167) showed
that even *aggregate* statistics (allele frequencies, genotype counts) computed from a genotyped
cohort can reveal whether a specific individual's genotype was part of the study — summary statistics
derived from sequence data are **not** an automatic privacy safe-harbor. **Gymrek et al. 2013**
(*Science* 339(6117):321-324) showed genomic data can be traced to real identities via public
genealogy resources even after superficial anonymization. This directly grounds §3 D7's requirement
that derived summaries, not just raw genotypes, route through the curator-controlled export gate.

**Precedent software.** **PMx** (Lacy, Ballou & Pollak 2012) — the field's dominant zoo/aquarium
studbook-genetics tool — remains pedigree/kinship-based and does **not** natively ingest WGS/WES
data; the dominant real-world managed-population tool has not already solved this, so #152 is
genuinely new ground for this niche. **`SNPRelate`** (Zheng et al. 2012) is the most directly
transferable *engineering* precedent — it converts PLINK BED/VCF into a packed 2-bit-per-genotype GDS
file specifically because naive per-cell representations don't scale — but it is Bioconductor-only
and therefore declined for this design's in-scope tier (§1.2, §3 D1). **Bimber et al. 2016**'s
GBS+GIGI-imputation pipeline is the strongest captive-macaque-specific precedent but is a wet-lab/
bioinformatics pipeline, not a web tool. **`sequoia`** (Huisman 2017) and **COLONY** independently
reinforce the "hundreds-to-thousands of SNPs, not millions" sparse-panel scale for managed-population
SNP-based analysis. **No software was found that has already solved "ingest sequence-derived genotype
data inside a general-purpose captive-colony Shiny management tool"** — this absence is itself a
finding: #152 extends existing patterns (SNPRelate's packed-representation idea, Bimber's
sparse-panel-plus-imputation practice) into an domain with no ready-made analog to simply adopt.

---

## 3. Design decisions

Ten decisions. D2, D4, D6, D9, D10 are **forced** by the evidence above — not owner choices, listed
for completeness and to make the "why" explicit for the implementing session(s). D1, D3, D5, D7, D8
are **judgment calls**, ratified via a single `AskUserQuestion` round in §11.

**D1 (judgment call — the session's central scope decision). Commit to a "sparse/GBS-style panel"
scope tier now — target ceiling ~50,000 biallelic SNP loci — explicitly deferring dense/near
-complete-WGS ingestion (100K to tens of millions of loci) to a future, separately-scoped re-design.**
§2.7's own captive-pedigreed-macaque precedent (Bimber et al. 2016, ~22,455 markers) sits comfortably
inside this ceiling with headroom; the ceiling is chosen to stay inside the existing dense
character-matrix representation's practical memory envelope (§7 Dragon 1) without forcing a packed
/GDS-style rewrite or reopening the Bioconductor decline (§1.2). **Recommended: adopt this tier.**
**Declined alternative:** design directly for dense/whole-genome scale now (100K-40M+ loci, per
Xue et al. 2016) — this would require either a packed/on-disk representation (SNPRelate-style GDS,
`Matrix`'s own sparse classes, or a `data.table`-backed columnar store) or reopening the ratified
Bioconductor decline outright; neither is warranted by any real requirement in the issue itself
("realistic validation fixtures," not "ingest a full 43.7M-SNV genome"), and doing so now would be
exactly the "unbounded sequence-analysis platform" the issue explicitly disclaims building.

**D2 (forced). Input format: extend the existing long-format schema, do not accept raw VCF/PLINK
-binary files.** A curator/genetics-core hands off an already-QC'd, already-biallelic-filtered
tabular genotype matrix — either the existing `id, locus, allele1, allele2` long format (§2.1
Pathway B, unchanged) at panel scale, or (new) an equivalent wide `id × locus` dosage/allele-string
matrix for larger panels where long-format's row count (`individuals × loci`) becomes unwieldy to
hand-author or review. Alignment, variant calling, joint genotyping, and QC filtering
(`bcftools`/PLINK-style) are explicitly **out of scope** — an upstream genetics-core responsibility,
matching the issue's own "preprocessing boundaries" framing and the scale evidence in §2.7 that raw
VCF is categorically incompatible with in-process R/Shiny handling regardless of policy.

**D3 (judgment call). Add a new, additive locus-metadata sidecar: `id`-free table of
`locus, chrom, pos` (optionally `cM` if a genetic map is available).** Required for F_ROH (D6, needs
locus order along a chromosome to define contiguous homozygous runs) and deliberately shaped to be
the shared vocabulary issue #153 (linkage-aware/haplotype-block metrics) can extend rather than
reinvent — the sequencing audit's own stated rationale for ordering #152 ahead of #153 (§1.2).
**Recommended: build this now, even though #152 itself uses only `chrom`/`pos`,** so #153 does not
have to retrofit locus-ordering metadata into an already-shipped ingestion path. **Declined
alternative:** defer locus-metadata entirely to #153 — cheaper for #152 alone, but reopens exactly
the vocabulary-duplication risk the sequencing audit flagged (§1.2), and blocks F_ROH (D6), the
design's own highest-leverage new metric, which needs `pos` regardless.

**D4 (forced). Vocabulary: use `locus`/`variant` precisely; do not use "haplotype" (reserved for
#148's classical named-MHC-allele meaning) or "block" (reserved for #153's LD-block meaning).**
The new locus-metadata table (D3) is named `locusMetadata`, not anything containing "haplotype" or
"block" — directly avoiding the vocabulary-collision risk the sequencing audit already flagged
between adjacent Deferred-tier issues (§2.7, §1.2).

**D5 (judgment call). Rewrite `markerKinship()`'s pairwise loop as vectorized matrix algebra before
claiming genome-scale kinship works; fix `markerParentageLikelihood()`'s redundant per-candidate
allele-frequency rescan by precomputing each locus's frequency table once.** Both are the same KING
-robust/CERVUS-LOD *math* already implemented and already ratified (§1.2 D2 for kinship;
`docs/planning/issue147-likelihood-parentage-assignment-plan.md` for LOD) — this is an
**implementation-strategy change, not a new statistical method**, and needs no new dependency
(`Matrix` is already an Import, §2.5). **Recommended: required prerequisite work, scoped as its own
slice (§5 Slice 2), before any genome-scale panel is claimed to work through either function.**
**Declined alternative:** ship genome-scale ingestion without touching either function and let users
discover the O(n²·L)/O(F·C·L·n) cost empirically — untested cost at 20K-50K loci could mean
multi-hour or non-terminating Shiny sessions; unacceptable given the package's own reliability bar
elsewhere (every other marker function shipped with a `git stash`-verified clean regression pass).

**D6 (judgment call). Initial "scientifically justified metric set" for #152's own scope: genome
-wide F_ROH (new) + genome-wide reruns of the existing kinship/heterozygosity/Fst functions (post-D5
rewrite) fed through the new ingestion path.** F_ROH is computed per individual per chromosome:
consecutive homozygous genotypes (ordered by `pos` from the D3 sidecar) exceeding both a minimum SNP
count and a minimum bp span are called an ROH segment (matching the field-standard PLINK
`--homozyg`-style dual threshold, per Ceballos et al. 2018 §2.7); `F_ROH` = total ROH length ÷ total
genome length covered by genotyped loci. **Recommended: this set.** **Declined alternative:** also
attempt a first-pass Ne-from-LD estimator in #152's own scope — explicitly ceded to #153 instead
(§2.7), since LD estimation is #153's own stated deliverable and folding it in here would blur the
#152/#153 boundary the sequencing audit already drew.

**D7 (judgment call). Any sequence-derived export — raw genotype matrix AND derived summary tables
(kinship/heterozygosity/Fst/F_ROH) — routes through a new de-identification primitive following the
`obfuscateTwinRelations()` sidecar pattern (§2.4), gated by the same curator-controlled confirm/export
UI shape as issue #150, not a separate or weaker path.** Grounded directly in Homer et al. 2008's
finding that summary statistics are not an automatic privacy safe-harbor (§2.7) — a curator exporting
"just the kinship table" is exporting exactly the kind of aggregate statistic that finding covers.
Concretely: id columns alias through the existing map (reuse, do not reinvent); **genotype/allele
values themselves are never perturbed** — unlike a date, there is no "obfuscation" of an allele call
that preserves scientific validity while hiding identity, so the only real protection is which people
see the file at all (the confirm-gate/labeling pattern, not a data transform). **Recommended: build
this now, as part of the eventual full-module slice (§5 Slice 4), not deferred past initial ship.**
**Declined alternative:** ship v1 without any sequence-data de-identification path (script-callable
functions only, no export UI at all) — defers a real, literature-grounded re-identification risk
past the point real users would plausibly use the feature, and contradicts this project's own
established "same-session checklist, not audited later" discipline for user-facing features.

**D8 (judgment call). Module boundary: a new tab inside the existing `modMarkerGenetics.R`, not a
new standalone module.** The genotype-matrix → kinship/heterozygosity/Fst reactive shape this design
needs is extremely close to what `modMarkerGenetics.R` already owns (§2.3) — a new tab reuses its
existing upload/validation/reactive-wiring conventions directly, including the already-shipped
`markerKinshipMatrix` reactive issue #151 already consumes. **Recommended: new tab.** **Declined
alternative:** a dedicated new module (e.g. `modSequenceGenetics.R`), mirroring this cluster's own
one-feature-one-module convention (#149/#150/#151 each got their own module) — a defensible, real
alternative given this feature's XL scope, but would duplicate upload/validation scaffolding
`modMarkerGenetics.R` already has working and tested, and fragment "genotype-shaped data" handling
across two modules with no functional reason to keep them apart (unlike Cross-Center Identity vs.
De-Identified Export, which are genuinely different concerns sharing only a UI *pattern*, not a data
shape).

**D9 (forced). No new module-contract exception is needed.** The new tab's reactive contract
(genotype matrix in, kinship/heterozygosity/Fst/F_ROH tables + `isReady` out) fits
`modMarkerGenetics.R`'s existing return vocabulary and rule set (§2.6) without modification.

**D10 (forced). Fixture: a synthetic multi-locus genotype fixture must be generated as part of the
first implementing slice — none exists in the repo today (§2.1), a pre-existing gap from issue
#130's own unresolved P3 note.** Sized to the D1 scope tier's lower-middle range (recommend
1,000-5,000 loci over 50-100 synthetic animals) — large enough to exercise real scale behavior and
validate D5's rewrite, small enough to keep as a committed test fixture. This closes a gap that
predates and outlives #152 specifically; useful to every function in §2.2, not just this design's
own new work.

---

## 4. Interface catalog (proposed — for the future implementing session(s), not built this session)

| Interface | Kind | Input | Output | Error | Consumers |
|---|---|---|---|---|---|
| `checkSequenceGenotypeFile(genotype, locusMetadata = NULL)` | New `@export`ed validator, extends `checkMarkerGenotypeFile()`'s rule set (D2) | long-format `id, locus, allele1, allele2` genotype table; optional `locusMetadata` sidecar (D3) | `TRUE` invisibly, or `stop()` with a specific violation | biallelic-only (unchanged from D2 precedent), duplicate `(id, locus)`, panel size above the D1 ceiling (soft warning, not a hard stop — see §7 Dragon 2) | New module tab; script callers |
| `computeGenomicROH(genotypeMatrix, locusMetadata, minSnp, minBp)` | New `@export`ed metric function (D6) | `buildMarkerGenotypeMatrix()`'s existing dense matrix shape + `locusMetadata` (D3) | per-individual `data.frame`: `id, nSegments, totalRohLength, fRoh` | `req()`-style — absent `locusMetadata` is a clear early `stop()`, not a silent `NA` | New module tab; script callers |
| `markerKinship()` (rewritten, D5) | Modified existing `@export`ed function — **signature unchanged**, internals vectorized via `Matrix`-based matrix algebra | unchanged | unchanged shape (`id × id` matrix) | unchanged | All existing callers, byte-identical results required (regression-tested against the current O(n²·L) implementation's own output on the existing small fixtures) |
| `markerParentageLikelihood()` (rewritten, D5) | Modified existing `@export`ed function — **signature unchanged**, internals precompute per-locus allele-frequency tables once | unchanged | unchanged | unchanged | All existing callers, byte-identical results required |
| `obfuscateGenotypeMatrix(genotypeMatrix, map)` | New `@export`ed de-identification primitive (D7), mirrors `obfuscateTwinRelations()`'s sidecar shape | a genotype matrix/table keyed by `id`; the alias `map` from `obfuscateId()`/`obfuscatePed(..., map = TRUE)` | the same table with `id` aliased; allele/genotype values **unchanged** (D7) | `stop()` on any `id` missing from `map` (matches `obfuscateTwinRelations()` precedent, never silently drops) | New module tab's export path |
| New tab inside `modMarkerGeneticsUI(id)` | UI addition, module-contract-compliant (D8) | namespace id (unchanged function signature) | adds a "Sequence Genetics" tab to the existing `tabsetPanel` | n/a | `appUI.R` (no new wiring point needed) |
| New reactives inside `modMarkerGeneticsServer(id, ...)` | Server addition, module-contract-compliant (D8/D9) | new `fileInput`s for the genotype matrix + optional `locusMetadata`; reuses the module's existing `pedigree`/`kinshipMatrix` args | new named reactives added to the existing 9-element return list: `sequenceGenotype`, `sequenceRohTable`, plus reruns of `markerKinshipMatrix`/heterozygosity/Fst tables when sequence-scale input is present | `req()` for absence; surfaced errors for malformed input (rule 5, §2.6) | `appServer.R` (extends existing wiring, no new call site) |

---

## 5. Implementation plan — vertical slices (each its own future session)

Matches this cluster's own established "XL item, multiple slices" precedent (issue #130's
marker-genetics family split across Sessions 442-447; the sequencing audit's own explicit
"Structural observations" note that anything in this batch is realistically multi-session). **This
design session does not implement any slice.**

### Slice 1 — Ingestion + fixture (script-callable only, no UI, no metric changes)
**Touches:** a new `R/checkSequenceGenotypeFile.R` (D2/D4), a new `locusMetadata` validation helper
(D3), a new `data-raw/` script generating the D10 synthetic fixture + its committed
`inst/extdata/examples/` CSV pair (genotype matrix + locus metadata sidecar).
**Done when:** the new validator round-trips the new fixture; `checkMarkerGenotypeFile()`'s existing
behavior is unchanged (regression-tested); the fixture is reusable by every later slice.

### Slice 2 — Performance rework (script-callable only, D5)
**Touches:** `R/markerKinship.R` (matrix-algebra rewrite), `R/markerParentageLikelihood.R`
(allele-frequency precomputation).
**Done when:** both functions produce byte-identical output to their current implementation on every
existing small fixture (regression proof, not just "still passes"); a new benchmark test
(`system.time`/`bench::mark`, precedent-setting — none exists yet, §1.2) demonstrates tractable
runtime against the Slice 1 fixture at its full 1,000-5,000-locus scale.

### Slice 3 — F_ROH metric (script-callable only, D6)
**Touches:** a new `R/computeGenomicROH.R`.
**Done when:** produces correct, literature-consistent ROH segments/`F_ROH` on the Slice 1 fixture
(validated against a hand-computed small synthetic case, mirroring every prior metric slice's own
"prove it against a hand-derived example" convention, e.g. `markerFst()`'s exact-fraction fixture).

### Slice 4 — De-identification primitive (script-callable only, D7)
**Touches:** a new `R/obfuscateGenotypeMatrix.R`.
**Done when:** round-trips through the existing `obfuscateId()`/`obfuscatePed(map=TRUE)` alias-map
convention; `stop()`s correctly on a missing id (mirroring `obfuscateTwinRelations()`'s own test
shape).

### Slice 5 — Full module tab, wiring, curator-controlled export, documentation (D8/D9)
**Touches:** `R/modMarkerGenetics.R` (new tab, new `fileInput`s, new reactives per §4's interface
catalog), `R/appServer.R` (if any new reactive needs threading beyond the module boundary — likely
none, per D9), a curator-controlled export UI reusing issue #150's confirm-gate/manifest/
re-identification-key pattern for sequence data specifically, `NEWS.Rmd`, the tutorial/article
checklist (Session 436), citation checklist (issue #120 — F_ROH is a new displayed statistic,
**applicable** this slice), `_pkgdown.yml` reference coverage.
**Done when:** live `shinytest2` smoke test against the Slice 1 fixture shows the full path (upload →
validate → compute kinship/heterozygosity/Fst/F_ROH → confirm-gated de-identified export) working
end to end with zero console errors, matching this cluster's own established Phase 3E bar.

---

## 6. Impact analysis

| System | Impact | Action required |
|---|---|---|
| `checkMarkerGenotypeFile()` / `buildMarkerGenotypeMatrix()` | **Unchanged.** D2 extends via a new, separate validator (`checkSequenceGenotypeFile()`), not a modification. | None — existing panel-scale callers unaffected. |
| `markerKinship()` / `markerParentageLikelihood()` | **Internals rewritten (D5); public signature and output shape unchanged.** | Byte-identical regression proof required at Slice 2 (§5). |
| `markerObservedHeterozygosity()` / `markerExpectedHeterozygosity()` / `markerFst()` | Unchanged code; newly benchmarked at target scale (§3 D5's "not assumed" note). | A scale benchmark, no code change, at Slice 2. |
| `modMarkerGenetics.R` / `appServer.R` | New tab + new reactives added (D8/D9); existing 5 tabs and 9 reactives unchanged. | Module-contract compliance check (rule 2's mechanical test) at Slice 5. |
| De-identification family (`obfuscate*`) | New sibling primitive added (D7); no existing function modified. | None to existing callers. |
| `DESCRIPTION` | **Unchanged** — D1's scope tier is chosen specifically to avoid a new dependency. | Re-confirm zero Bioconductor deps at each slice's close-out, matching the issue #130 precedent's own P5 warning. |
| Issue #153 (future) | Can reuse the D3 `locusMetadata` schema (`locus, chrom, pos[, cM]`) directly rather than defining its own. | None this session — informational for whoever picks up #153. |
| Issue #148 (future) | No overlap — D4's vocabulary choices explicitly avoid colliding with #148's "haplotype" usage. | None. |

---

## 7. Here be dragons

1. **The D1 scope ceiling (~50,000 loci) is a judgment call grounded in one literature precedent
   (Bimber et al. 2016), not a measured limit of this package's own code.** No benchmark exists yet
   (§1.2) — Slice 2's own benchmark (§5) is the first real test of whether 50,000 loci is actually
   comfortable post-rewrite, or whether the true practical ceiling is lower (or higher). Treat the
   number as a target to validate, not a guarantee.
2. **`checkSequenceGenotypeFile()`'s panel-size check is proposed as a soft warning, not a hard stop
   (§4), because the "right" ceiling is not yet empirically known** — a hard stop at an unvalidated
   number risks blocking legitimate data; a pure warning risks a curator uploading something that
   silently takes hours. Slice 1's own Pre-RED should revisit this once Slice 2's benchmark exists,
   since Slice 2 is designed to run before Slice 5 (the actual UI) ships.
3. **`markerParentageExclusion()`'s `maxExclusions = 2L` default is explicitly documented
   (`markerParentageExclusion.R:36-40`) as calibrated for small panels** and is **not** addressed by
   this design (out of the D6 metric set) — a future genome-scale user of parentage exclusion would
   need to retune it themselves; flagged here so it is not silently assumed to "just work" at scale
   alongside the metrics this design does address.
4. **Ploidy and missingness edge cases from real VCF-derived data are not fully worked through.**
   §2.7 confirms VCF's `.`/`./.` missingness convention and diploid `GT` encoding, but this design
   assumes the upstream preprocessing (D2) already resolves these into the existing `allele1`/
   `allele2` (or `NA`/`NA`) shape `buildMarkerGenotypeMatrix()` expects — a real curator's
   preprocessing script could plausibly get this wrong (e.g. leaving a literal `"."` string rather
   than `NA`). Slice 1's validator (§4) should treat this as a first-class malformed-input case to
   test against, not an afterthought.
5. **Genomic re-identification risk does not vanish after D7's export gate** — D7 explicitly does
   *not* perturb genotype/allele values (there is no scientifically-valid "obfuscation" of an allele
   call), so the confirm-gate/labeling protection is weaker for sequence data than it is for dates
   (issue #150) or names (issue #136), which *can* be genuinely altered. This should be stated
   plainly in whatever warning text Slice 5 ships, not glossed over as equivalent to the pedigree
   -export case.

---

## 8. Alternatives considered

| Alternative | Pros | Cons | Why rejected |
|---|---|---|---|
| Design directly for dense/near-complete WGS scale (100K-40M+ loci) now | Matches the field's eventual ceiling; avoids a second re-design later | Reopens the ratified Bioconductor decline (§1.2); requires a packed/on-disk representation this codebase has no precedent for; far exceeds the issue's own "not an unbounded platform" framing | D1 — stay in the sparse/GBS-scale tier that has a real, directly-applicable field precedent (Bimber et al. 2016) |
| Accept raw VCF or PLINK BED/BIM/FAM directly | Interoperable with standard genomics tooling; no bespoke schema | Categorically incompatible with in-process R/Shiny at realistic file sizes (§2.7, 144 GB-900 TiB class); would require streaming/chunked I/O this codebase has zero precedent for anywhere | D2 — require pre-filtered, pre-flattened tabular input; alignment/calling/QC stay an upstream responsibility |
| Adopt `SNPRelate`/`GENESIS` (Bioconductor) for genome-scale kinship | Battle-tested, purpose-built for exactly this scale problem; avoids hand-rewriting `markerKinship()` | Bioconductor-only — a real CRAN-publishability risk this project has already explicitly and recently declined (§1.2); the issue #130 plan explicitly names this exact temptation and asks any future session to re-litigate it via `AskUserQuestion`, not adopt it quietly | D5 — vectorize the existing hand-implemented KING-robust math in base R using the already-available `Matrix` package instead |
| A dedicated new `modSequenceGenetics.R` module | Matches this cluster's own one-feature-one-module convention (#149/#150/#151); keeps XL scope cleanly separable | Duplicates upload/validation/reactive scaffolding `modMarkerGenetics.R` already has, tested and working; fragments "genotype-shaped data" handling across two modules with no functional reason to keep them apart | D8 — a new tab inside the existing marker-genetics module |
| Ship v1 with no sequence-data export/de-identification path at all (script-callable only) | Smaller initial scope; defers a genuinely hard privacy question | Homer et al. 2008/Gymrek et al. 2013 make the re-identification risk concrete and real, not speculative; contradicts this project's own established same-session-checklist discipline for user-facing features | D7 — build the export/de-identification path as part of the eventual full-module slice, not deferred indefinitely |

---

## 9. Close-out checklist mapping

This is a design-only session — no `R/`/`tests/`/`man/` changes, so most checklists are **N/A this
session**, owed at the future implementing slices named in §5:

- **Citation checklist (issue #120):** N/A this session (no displayed statistic shipped). **Owed at
  Slice 3** — F_ROH is a new displayed statistic once it ships.
- **NEWS.Rmd checklist:** N/A this session (no exported function or Shiny feature shipped). **Owed at
  every slice that ships one** (Slices 1, 3, 4 each add an `@export`ed function; Slice 5 ships the
  user-facing tab).
- **Tutorial/article checklist (Session 436):** N/A this session. **Owed at Slice 5** (the only slice
  that ships a user-facing Shiny tab).
- **`a2interactive.Rmd` checklist:** deferred per its own standing rule (a future documentation pass,
  not any individual shipping slice) — matching every precedent in this cluster.
- **`_pkgdown.yml` reference-coverage guard:** N/A this session. **Owed at Slices 1, 3, 4** (each adds
  a new `@export`ed function).

---

## 10. Provenance

Research method: two parallel background research agents this session — (1) an `Explore` agent doing
a direct-source codebase inventory (genotype-input pathways, the full marker function family with
complexity analysis, the module/wiring shape, the de-identification pattern, dependencies,
module-contract rules, and the existing fixture gap — all with file:line citations, §2.1-§2.6), and
(2) a `general-purpose` agent grounding sequence-data format/scale/metrics/privacy/precedent-software
facts against real, citable literature (§2.7) — plus this session's own direct verification of the
single most load-bearing prior decision (`docs/planning/issue130-marker-kinship-crosscenter-identity
-plan.md` D2's Bioconductor decline, §1.2, re-read directly rather than trusted from the agent
summary alone). No design decision in §3 rests on an unverified agent claim; every citation in §2.7
came back from the domain-research agent with a named paper/tool and year, cross-checked for internal
consistency against the codebase agent's independent finding that `DESCRIPTION` carries zero
genomics dependencies today.

---

## 11. Ratification status — forced vs. judgment-call decisions

**Forced (no vote needed, listed for the implementing session's benefit):** D2 (structural — scale
evidence in §2.7 makes raw-file ingestion a non-option), D4 (structural — avoids a vocabulary
collision the sequencing audit already flagged), D9 (structural — the module contract already
accommodates this shape), D10 (structural — the fixture gap predates this design and blocks every
slice's own verification regardless of any other decision).

**Genuine judgment calls put to the owner in one `AskUserQuestion` round:** D1 (scope tier: sparse
/GBS-scale now vs. dense/WGS-scale architecture now), D3 (build the `locusMetadata` sidecar now vs.
defer it to #153), D5 (require the `markerKinship()`/`markerParentageLikelihood()` performance
rewrite as a prerequisite slice vs. ship ingestion first and defer performance work), D6 (initial
metric set: F_ROH + reruns of existing metrics vs. also attempting a first-pass Ne-from-LD), D7
(build the de-identification/export path now, as part of the full module slice, vs. ship
script-callable functions only for v1), D8 (new tab in `modMarkerGenetics.R` vs. a dedicated new
module).

That is six candidate judgment calls — above the tool's 4-option cap for a single round. D5 and D10
both reduce to the same underlying fact (no benchmark exists, §1.2) and D5's "defer performance work"
alternative was already shown in §3 D5's own rationale to be operationally unacceptable (an untested
O(n²·L) cost with no proof of tractability) rather than a genuinely live choice — **D5 is presented
to the owner as context, not as one of the four voted options**, consistent with "recommended, not
truly contested" framing already used for several of the *forced* decisions above. The four presented
for a vote are **D1, D3, D6, D8** — the four with real, defensible alternatives and no evidence-based
case that one option is simply correct. D7's "ship without an export path" alternative is real but
narrower in consequence than the other four (it only delays, rather than reshapes, later work), so it
is folded into the D8 vote's own framing (a "new tab" answer implies the export path ships alongside
it at Slice 5; a future session could still choose to delay D7 independently without reopening D8).

### Ratification outcome (2026-08-11, this session)

Owner selected this document's own recommended option in all four cases, via a single
`AskUserQuestion` round:

- **D1 — sparse/GBS-scale tier, ~50,000-locus ceiling.** Dense/near-complete-WGS ingestion stays
  explicitly out of scope; the ratified Bioconductor decline (issue #130 D2) is not reopened.
- **D3 — build the `locusMetadata` (`locus, chrom, pos[, cM]`) sidecar now.** Ships as part of
  Slice 1's ingestion path, giving issue #153 a ready vocabulary to extend rather than re-derive.
- **D6 — F_ROH + genome-scale reruns of the existing kinship/heterozygosity/Fst functions.**
  Effective-population-size-from-LD stays explicitly ceded to issue #153.
- **D8 — new tab inside `modMarkerGenetics.R`, not a dedicated new module.** Reuses the existing
  module's upload/validation/reactive-wiring conventions, including the already-shipped
  `markerKinshipMatrix` reactive issue #151 already consumes.

No changes requested to any recommended design. D5's "required prerequisite" framing (§3, presented
as context rather than a fifth vote) stands as written — the future Slice 2 implementing session
still owes a `markerKinship()`/`markerParentageLikelihood()` performance rewrite before any
genome-scale claim ships. **This design is ratified and ready for Slice 1 implementation in a future
session** — matching the #133/#136/#137/#145/#146/#147/#149/#150/#151 precedent of a design-only
session with zero `R/`/`tests/`/`man/` changes. Issue #152 stays intentionally open (design ratified,
not yet implemented); no `gh issue close` this session.
