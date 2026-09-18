## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Issue #148 — MHC Haplotype Reporting: Design Plan

**Status:** Pre-RED design/architecture document. Design-only session (Session 704,
2026-09-17) — zero `R/`/`tests/`/`man/` changes. Matches the #133/#136/#137/#145/#146/
#147/#149/#150/#151/#152/#153 precedent: a design document is written and ratified first;
implementation happens in one or more later, separate sessions. Written through the
scope-narrowing gate the owner ratified in S703
(`docs/planning/issue148-mhc-haplotype-scoping-2026-09-17.md`: design-first, same issue,
no sub-issue split).

---

## 1. Context

### 1.1 What issue #148 says (verbatim body, filed 2026-08-06)

> **Source:** `GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`: MHC-specific reporting
> is partial.
>
> MHC-style alleles are accepted through the generic genotype pipeline, but the package
> does not identify MHC loci/haplotypes, report their frequencies, or flag rare
> haplotypes.
>
> Add an optional MHC-aware analysis with an explicit input designation or validated
> metadata, per-haplotype counts/frequencies and missingness, configurable rarity
> flagging, affected-animal reporting and CSV export. Make clear this is descriptive
> haplotype reporting, not a replacement for pedigree/genome-uniqueness metrics. Do not
> infer MHC semantics from arbitrary locus names.

Five explicit requirements, each mapped to a design decision below:

1. "Explicit input designation or validated metadata" → D2 (the central input-designation
   decision), D9 (labels are opaque).
2. "Per-haplotype counts/frequencies and missingness" → D3 (uncertain calls), D4
   (denominator transparency), interface catalog §4.
3. "Configurable rarity flagging" and "affected-animal reporting" → D4 (rarity
   semantics), D5 (reporting shape).
4. "CSV export" → D6 (export gating).
5. "Descriptive haplotype reporting, not a replacement for pedigree/genome-uniqueness
   metrics" + "do not infer MHC semantics from arbitrary locus names" → D7 (caveat), D9
   (opaque labels), D1 (vocabulary).

### 1.2 Already decided (do not re-litigate)

- **S703 scope decision (owner, via `AskUserQuestion`):** design-first, same issue, no
  sub-issue split — this document is that design; implementation slices follow only after
  it is ratified (`docs/planning/issue148-mhc-haplotype-scoping-2026-09-17.md` §1).
- **Vocabulary reservation (#152 D4 / #153 D1, both ratified):** bare **"haplotype"
  belongs to #148** — this feature's classical named-MHC-allele meaning; **"block"/"LD
  block" belongs to #153** and must never appear in this feature's names, labels, or
  docs (`R/modMarkerGenetics.R:6-13`;
  `docs/planning/issue152-sequence-input-genetic-metrics-plan.md:300-304`;
  `docs/planning/issue153-linkage-haplotype-block-metrics-plan.md` §1.2).
- **The biallelic gate is untouchable:** `checkMarkerGenotypeFile()`'s
  more-than-two-distinct-alleles rejection (`R/checkMarkerGenotypeFile.R:68-78`) is a
  correct, deliberate KING-robust correctness constraint for every existing caller
  (audit Finding #4's named landmine,
  `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md:171-188`). The
  sibling-validator pattern (#153 D4 → `checkLinkageMarkerGenotypeFile()`; #152 →
  `checkSequenceGenotypeFile()`) is the established defusal: purpose-specific validators
  per input family, never a change to the gate.
- **No MHC inference from arbitrary locus names, ever** (issue-body hard requirement,
  restated by the S703 decision record §4).
- **Curator-controlled export gating for identifying tables** (issue #150's pattern,
  reused by #152 D7 and #153 D9): Generate-Preview → Confirm modal → Confirm-OK,
  snapshot-at-preview-time, id aliasing through `obfuscatePed(..., map = TRUE)$map`,
  export-specific warning text, explicitly "confirmation dialog and warning text, not
  real access control."

### 1.3 What this session's research confirmed

Direct reads of every load-bearing file (provenance §10) plus one background
domain-research agent, building on the S703 scoping doc's own grep-verified inventory
(re-validated: `git log fcf94807..HEAD -- R/ tests/` is empty — zero package-path
changes since that inventory was taken). Headline findings, in order of design impact:

1. **The real MHC data is not a per-locus genotype panel at all.** The bundled real file
   (`inst/extdata/examples/obfuscated_rhesus_mhc_breeder_genotypes.csv` =
   `rhesusGenotypes`, §2.1) is a wide per-animal table — one row per animal, two named
   haplotype designations (`A004_B002`-style labels, one per chromosome copy). Under D2's
   recommended dedicated-upload design this data **never enters the marker long-format
   pipeline** (`checkMarkerGenotypeFile()`/`buildMarkerGenotypeMatrix()`) — the
   biallelic-gate landmine is defused *by construction*, not by a tolerant sibling
   validator: there is no locus column to count alleles over.
2. **No single rarity criterion behaves across colony scales — measured, not assumed.**
   On the real 31-animal file: 33 distinct haplotypes over a 60-certain-call
   denominator; a frequency < 0.05 flag marks **26 of 33** (79%), while the published
   NHP-MHC rare cutoff (≤ 0.01, §2.8) marks **0** — a singleton is already 1/60 ≈ 0.017
   — and carrier count ≤ 2 marks 26 (§2.1). So a frequency criterion either saturates
   or never fires at small-colony scale depending on the cutoff, while a carrier-count
   criterion stays meaningful there but fades at registry scale — the case for D4's
   dual criterion, and for the UI presenting the flag as a configurable working filter,
   not an alarm (D4, Dragon 1).
3. **Pathway A's only current use of this data is gene-drop seeding.** The genotype file
   merges into the raw pedigree *before* QC (`R/modInput.R:469-488`), with validation
   errors silently degraded to `NULL` (`tryCatch(..., error = function(e) NULL)`,
   `:480-484`), so the integer-encoded alleles can seed `geneDrop()` via
   `getGVGenotype()`/`hasGenotype()`. No frequency, missingness, or rarity output exists
   anywhere downstream — confirming the issue body. The degrade-to-NULL contract makes
   this path structurally unsuitable as the attachment point for a *reporting* feature
   (a malformed file would silently produce no report rather than a diagnosable error,
   violating module-contract rule 5's spirit).
4. **The module surface and every needed pattern already exist.** `modMarkerGenetics.R`
   has 7 tabs, 4 file inputs, two shipped confirm-gate exports (LD block :572-600;
   sequence :639-677), a manifest builder (`.buildSequenceExportManifest`, :75-87), and
   two persistent-caveat precedents (:15-21). The de-identification primitive mold
   (`obfuscateTwinRelations()`: alias through the standard map, `stop()` on an unknown
   id, never silently drop) is exported and tested.
5. **Domain research** (background agent with verified/unverified tagging, full
   findings §2.8): the IPD-MHC NHP database is the nomenclature authority; the bundled
   file's abbreviated haplotype labels (`A004`, `B015b`) follow the published
   macaque-community designation convention — including the meaningful trailing
   lowercase variant letter — while the underscore *pairing* form (`A004_B002`) is
   unpublished, a local records format (both facts support D9's opacity); colonies track
   MHC haplotypes for documented research-demand and haplotype-loss-prevention reasons;
   published rarity usage exists (NHP-MHC "rare" ≈ frequency ≤ 0.01) but at small-colony
   scale that threshold cannot fire (§2.1), and the one directly-on-point HLA catalogue
   standard (CIWD 3.0) mixes a frequency criterion with a minimum-observation-count
   criterion — direct precedent for D4's dual criterion; HLA/NHP practice never silently
   discards ambiguous typings (it models, bins, or discloses them); and the MHC is the
   most polymorphic region of the genome, with HLA data formally classified as
   identifiable — a paired-haplotype MHC type is a near-unique per-animal fingerprint
   (D6).

---

## 2. Evidence-based inventory

### 2.1 The bundled real data — `rhesusGenotypes` / `obfuscated_rhesus_mhc_breeder_genotypes.csv`

31 animals, wide format `id, first_name, second_name`, documented as "two haplotypes per
animal" (`R/data.R:349-364`); the 31 ids are also in the companion obfuscated
`rhesusPedigree` (`R/data.R:366+`) — a ready-made real fixture *pair* for every slice.
Measured this session (script re-runnable; numbers verified against the file):

- 62 haplotype calls, **0 missing** (no `NA`/empty cells — synthetic fixtures must supply
  the missing-call cases, Dragon 6).
- **2 uncertain calls**, both trailing-`?` suffixed: `A002a_B015?`, `A008_B015b?` — and
  both have certain counterparts elsewhere in the file (`A008_B015b` ×2 certain,
  `A002a_*` family present), so the "distinct label vs. merged" choice (D3) has a real,
  visible consequence in the bundled data.
- Excluding the 2 uncertain calls: **33 distinct haplotype labels over a denominator of
  60**; top frequency 0.100 (`A004_B001a`, 6 copies); 21 singletons; frequency < 0.05
  flags 26/33, frequency < 0.02 flags 21/33, frequency ≤ 0.01 flags **0**/33 (a
  singleton is 1/60 ≈ 0.017), carriers ≤ 2 flags 26/33.
- Labels are composite `A<nnn>[letter]_B<nnn>[letter]` designations (e.g. `A004_B012b`,
  `A224a_B045a`) — colony-record MHC haplotype names pairing a Mamu-A-region and a
  Mamu-B-region abbreviated haplotype designation (§2.8), treated by this design as
  **opaque strings** (D9). Corroboration that these follow the published community
  convention: `A004`, `A008`, and `A002a` — three of the five common Indian-origin
  Mamu-A haplotypes that together account for roughly two-thirds of rhesus MHC
  chromosomes in surveyed colonies (Wiseman et al. 2013, §2.8) — all appear in the
  file, and the two-labels-per-animal shape matches the published "two pairs of Mamu-A
  and Mamu-B haplotypes describe each animal's MHC class I genotype" framing. The
  underscore *pairing* separator itself is unpublished (the literature concatenates
  with `/`) — a local file-format variant, one more reason the labels stay opaque.

### 2.2 Pathway A — the "generic genotype pipeline" the issue body names

`checkGenotypeFile()` (`R/checkGenotypeFile.R:39-68`): ≥ 3 columns, first forced to
`id`, columns named `first`/`second` reserved, and a collision guard rejecting alleles
parsing to integers > 10000 (because `addGenotype()` encodes each unique allele string as
`10000L + i`, `R/addGenotype.R:38-47`). `addGenotype()` merges the genotype into the
pedigree data frame; `getGVGenotype()`/`hasGenotype()` extract the integer columns for
`reportGV()`'s `geneDrop()` seeding. Wired at `R/modInput.R:469-488` (pre-QC merge,
degrade-to-NULL validation). **This path is read-only context for this design: D2's
recommendation leaves every line of it untouched.**

### 2.3 Pathway B and the biallelic gate — adjacent, untouched

`checkMarkerGenotypeFile()` hard-rejects any locus with > 2 distinct alleles
(`R/checkMarkerGenotypeFile.R:68-78`), a correct KING-robust constraint
(Manichaikul et al. 2010, per its own roxygen). Two shipped sibling validators already
demonstrate the defusal pattern: `checkLinkageMarkerGenotypeFile()` (same structure,
biallelic check deliberately omitted — #153 D4) and `checkSequenceGenotypeFile()`
(superset: literal-`"."` rejection + `maxLoci` soft warning — #152). Under D2(a) the MHC
feature is not even adjacent to this family: its input has no `locus` column, so no
validator in the marker family is reused or modified.

### 2.4 `modMarkerGenetics.R` — surface, patterns, and one stale doc

One module, 860 lines. 7 tabs (`:136-229`): Kinship Comparison, Heterozygosity,
Parentage Exclusion, Cross-Center, Candidate Parent Assignment, Linkage and LD Block
Metrics, Genomic ROH (F_ROH). 4 file inputs (`:116-131`). Patterns this design reuses:

- **Persistent, non-dismissable caveat** as static UI markup: `.linkageLdBlockCaveatText`
  (`:15-21`), rendered as an always-present `div(class = "alert alert-warning")`
  (`:170-171`) — "a caveat a curator can dismiss is not persistent" (`:12-13`).
- **Confirm-gate export**, twice shipped: `reactiveVal` snapshot at Generate-Preview
  click time, modal with export-specific warning text, Confirm-OK unlocks downloads
  (LD block `:572-600`; sequence `:639-677`). Export-specific warning texts at `:28-35`
  and `:42-49`.
- **Manifest artifact**: `.buildSequenceExportManifest()` (`:75-87`) — timestamp, package
  version, the parameters used, row counts, and the warning text shown; "deliberately
  never includes the id map or any raw pre-obfuscation value."
- **Dedicated-upload lesson (#153 Slice 5, found empirically):** Shiny renders every
  `tabPanel`'s output bindings regardless of which tab is visible, so a file that fails
  one tab's validator *must not* enter another tab's shared input (`:490-498`). The MHC
  tab therefore gets its own `fileInput`, like `linkageGenotypeFile`.
- **Incidental (pre-existing, routed to Slice 4, not fixed this session):** the server's
  roxygen `@return` says "A list with fourteen reactive elements" (`:305`) and describes
  only 14, but the actual return list (`:829-858`) has **19** — the five #152 Slice 5
  sequence-export reactives are undocumented. Slice 4 touches this exact roxygen block to
  add its own reactives and must repair the inventory as part of that documented change
  (module-contract rule 6).

### 2.5 Existing frequency machinery — wrong shape, right precedent

`.markerAlleleFrequencyTable()` (`R/markerAlleleFrequency.R:25-31`) computes per-allele
frequencies — but from the wide `"lo/hi"` genotype-string matrix, a shape D2(a)'s input
never takes. Its own roxygen records the precedent this design follows instead: an
"independent, non-exported helper rather than modifying [an] already-shipped statistical
function's internals" (#147 D9 — a deliberate fourth independent reimplementation). The
MHC tabulation (a `table()` over parsed haplotype labels) is implemented independently.

### 2.6 De-identification family — the primitive mold

`obfuscateTwinRelations(twinRelations, map)` (`R/obfuscateTwinRelations.R`): remaps id
columns through the alias vector `obfuscatePed(..., map = TRUE)$map` returns; an id
absent from the map `stop()`s — "rather than silently dropping or leaking the real id."
`obfuscateLdBlocks()`/`obfuscateGenomicROH()` repeat the mold. D6's
`obfuscateMhcHaplotypes()` is the same shape. Operational consequence carried to the
interface contract: **a carrier-list export requires every MHC-file id to be present in
the loaded pedigree's alias map** — an MHC file covering animals outside the loaded
pedigree fails the export loudly (Dragon 5).

### 2.7 Module contract

`docs/architecture/module-contract.md` (summarized in both mold plans, re-confirmed
against the module source): reactive-in/reactive-out; every returned element a
`reactive()` (mechanically enforced by `test_moduleContract.R`); stable canonical return
vocabulary; `req()` for upstream absence vs. surfaced error for malformedness (no
blanket `tryCatch` — `modMarkerGeneticsServer()`'s own `:351-357` comment restates this);
every parameter read and every return documented. `modMarkerGeneticsServer` is already in
`test_moduleContract.R`'s server list — a new *tab* adds no new server, so the only
contract work is documenting the new returned reactives (Slice 4).

### 2.8 Domain research — nomenclature, colony practice, thresholds, ambiguity, identifiability

Findings from this session's background domain-research agent, which tagged each claim
DIRECT (source states it) / INFERENCE / UNVERIFIED (method and confidence notes §10;
every load-bearing claim below carries its named source and survived that tagging):

- **Nomenclature authority.** Official designations for nonhuman-primate MHC
  polymorphisms are assigned by the curators of the IPD-MHC NHP database (nomenclature
  reports: de Groot et al. 2012, *Immunogenetics* 64(8):615-631,
  doi:10.1007/s00251-012-0617-1; de Groot et al. 2020, *Immunogenetics* 72(1-2):25-36,
  doi:10.1007/s00251-019-01132-x), with database curation under the Comparative MHC
  Nomenclature Committee (Maccari et al. 2017, IPD-MHC 2.0, *Nucleic Acids Research*
  45(D1):D860-D864). Rhesus MHC = **Mamu**.
- **The abbreviated haplotype-label convention is published — and the bundled file
  follows it.** Wiseman, Karl, Bohn, Nimityongskul, Starrett & O'Connor 2013,
  "Haplessly Hoping: Macaque Major Histocompatibility Complex Made Easy," *ILAR
  Journal* 54(2):196-210, doi:10.1093/ilar/ilt036, documents the convention directly:
  abbreviated labels (`A001`, `B012a`) name a haplotype by its diagnostic major
  transcript; **the trailing lowercase letter is meaningful, not decorative** (variants
  sharing a major transcript but differing in secondary alleles — `B012a` vs `B012b` is
  the paper's own example, directly explaining the bundled file's `A008_B015b`); "two
  pairs of Mamu-A and Mamu-B haplotypes describe each animal's MHC class I genotype";
  and five common Mamu-A haplotypes (`A004`, `A002a`, `A001`, `A008`, `A023`) account
  for roughly two-thirds of rhesus MHC chromosomes in surveyed Indian-origin colonies.
  The published concatenation uses `/` separators (`A004/A023/B001a/B017a`); the
  underscore-paired `A004_B002` form is **unpublished** — a local records variant — and
  the short labels themselves are a community/lab convention layered on top of official
  IPD allele nomenclature, not IPD-registered names, so the same label is not
  guaranteed stable across labs (both points feed D9 and Dragon 2). Region-level
  haplotyping at colony scale is likewise published: microsatellite-based Mamu
  haplotyping (Doxiadis et al. 2005, *Immunogenetics*, doi:10.1007/s00251-005-0787-1,
  PMID 15900491) and 2,377 defined Mamu core haplotypes — **defined as Mhc-A, Mhc-B
  *and* -DRB** — across 1,529 rhesus (Doxiadis et al. 2013, *Immunogenetics*
  65(8):569-584, doi:10.1007/s00251-013-0707-8; the DRB component matters for Dragon
  2).
- **Why colonies track MHC haplotypes.** Research demand for specific restriction
  alleles in SIV/AIDS models: Mamu-B\*08-positive animals dominate elite controllers
  (Loffredo et al. 2007, *J Virol* 81(16):8827-8832, doi:10.1128/JVI.00895-07);
  Mamu-B\*17 is associated with a 26-fold reduction in plasma virus (Yant et al. 2006,
  *J Virol* 80(10):5074-5077); Wiseman et al. 2013 states the Mamu-A1\*001/B\*017/B\*008
  control associations and MHC-defined selection/exclusion of study animals as the
  operational rationale. MHC-simplified breeding populations are established practice:
  the Mauritian cynomolgus M1-M7 haplotype system (Budde et al. 2010, *Immunogenetics*
  62(11-12):773-780, doi:10.1007/s00251-010-0481-9). Haplotype-loss prevention is a
  stated colony-management objective in the directly-on-point current literature:
  "changes in genetic diversity within the MHC can inform colony management by
  preventing haplotype loss" (Kanthaswamy et al. 2026, *American Journal of
  Primatology* 88(1):e70108, doi:10.1002/ajp.70108), and colony-wide MHC
  characterization "facilitates the breeding and selection of animals bearing desired
  haplotypes" (Kanthaswamy et al. 2018, *J Med Primatol*, doi:10.1111/jmp.12353, PMID
  29971797 — 379-animal SPF colony).
- **Rarity thresholds: published NHP-MHC usage exists but no management standard
  does.** Kanthaswamy et al. 2026 uses an explicit cutoff in prose — "rare haplotypes
  (with frequencies of 0.01 or lower)" — and Doxiadis et al. 2013 likewise treats ~1%
  as rare; the general rare-variant MAF partition (< 0.01 rare, 0.01-0.05
  low-frequency) is field convention. Critically, the one directly-on-point HLA
  catalogue standard **mixes a frequency criterion with a minimum-observation-count
  criterion in a single scheme**: CIWD 3.0 bins alleles as common (≥ 1 in 10,000),
  intermediate (≥ 1 in 100,000), or well-documented (**≥ 5 occurrences**) (Hurley et
  al. 2020, *HLA*, doi:10.1111/tan.13811, PMID 31970929) — direct published precedent
  for D4's dual frequency + carrier-count criterion. Conservation genetics establishes
  rare-allele retention as a management objective distinct from heterozygosity
  (Allendorf 1986, *Zoo Biology* 5:181-190 — bottlenecks cut allele number far faster
  than heterozygosity; Lacy, Ballou & Pollak 2012, PMx, *Methods Ecol Evol*,
  doi:10.1111/j.2041-210X.2011.00148.x — founder-allele retention by transmission
  simulation), but the agent found **no numeric rare-allele threshold in studbook/PMx
  management documentation** — supporting configurability over canonizing any cutoff.
- **Ambiguous typings are never silently discarded — they are modeled, binned, or
  disclosed.** Ambiguity is intrinsic to macaque MHC typing (Wiseman et al. 2013;
  lineage-level reporting is often the honest resolution and "can be sufficient" for
  study design — Caskey et al. 2019, *Immunogenetics* 71(8-9):531-544,
  doi:10.1007/s00251-019-01125-w). Current NHP practice retains ambiguous allele groups
  as explicit labelled categories ("g#" suffixes, Kanthaswamy et al. 2026). HLA registry
  practice feeds ambiguous typings into EM-based frequency estimation rather than
  dropping them (Gragert et al. 2013, *Hum Immunol*, PMID 23806270), with formal
  grammars for recording ambiguity losslessly (GL String — Milius et al. 2013, *Tissue
  Antigens* 82(2):106-112; ambiguity measurement — Paunić et al. 2012, *PLOS ONE*
  7(8):e43585). For a descriptive (non-EM) report the defensible policies are inclusive
  counting, exclusive counting, or a distinct disclosed category — with the one clearly
  indefensible reading being to treat `X?` as a haplotype *distinct from* `X` (D3). The
  trailing-`?` convention itself is **unpublished** — a local records annotation (D3's
  validator-level rule documents this design's own reading; Dragon 2).
- **MHC data is strongly identifying.** "The MHC region is the most polymorphic region
  of the human genome" (Robinson et al. 2020, IPD-IMGT/HLA, *Nucleic Acids Research*
  48(D1):D948-D955, PMID 31667505); HLA data is formally classified as identifiable
  personal health information on singularity/correlation/inference grounds (Kim et al.
  2025, *iScience* 28(9):113442, doi:10.1016/j.isci.2025.113442). At colony scale the
  same property holds per-animal: in the bundled file, 27 of 31 animals have a unique
  unordered haplotype pair (measured this session), so a carrier list is identifying
  *even before* the id column, and the aggregate-statistics floor (Homer et al. 2008,
  *PLoS Genetics* 4(8):e1000167, already ratified into #152 D7) applies to the summary
  table too (D6).
- **Frequency denominators and missingness.** The HLA meta-analytic standard computes
  frequencies over **2N chromosomes**, and treats missingness/low-resolution above ~5%
  as an explicit exclusion gate (Solberg et al. 2008, *Hum Immunol* 69(7):443-464,
  doi:10.1016/j.humimm.2008.05.001); NHP-MHC practice matches (Doxiadis et al. 2013
  reports frequencies over chromosome counts, N = 2,377/2,156, not individuals).
  Direct support for D4's chromosomes-among-genotyped denominator with `nAnimals`/
  `nCalls`/`nMissing`/`nUncertain` reported alongside every frequency table.

---

## 3. Design decisions

Ten decisions. D1, D5, D6, D7, D9, D10 are **forced** by evidence already established
(prior ratified decisions this design must honor, the issue body's own hard requirements,
or directly-sourced evidence with no real alternative reading). D2, D3, D4, D8 are
**judgment calls**, ratified via a single `AskUserQuestion` round (§11). Each decision
names the scoping doc's question (Q1-Q8) it answers.

**D1 (forced — hard constraint). Vocabulary: bare "haplotype" is this feature's term;
"block" never appears.** The function family is `checkMhcHaplotypeFile()` /
`mhcHaplotypeFrequency()` / `mhcHaplotypeCarriers()` / `obfuscateMhcHaplotypes()`; UI
labels say "MHC haplotype." Never "block"/"LD block" (reserved to #153), and #153's
surfaces must not acquire bare "haplotype" through this work — a grep check at every
slice close-out (Dragon 3). Applies to this document itself.

**D2 (judgment call — Q1, the central input-designation decision). A dedicated MHC
haplotype upload — wide `id, haplotype1, haplotype2`, one row per animal — behind its own
`checkMhcHaplotypeFile()` validator, inside the MHC tab.** "Explicit input designation"
is satisfied *by construction*: the curator designates the data as MHC by uploading it
into the MHC-specific control (the same designation-by-upload logic as #153's dedicated
`linkageGenotypeFile`, `R/modMarkerGenetics.R:490-498`), and no locus-name inference can
occur because the format has no locus names. The bundled real file is byte-for-byte this
shape (§2.1) — column names are not prescribed (forced to
`id, haplotype1, haplotype2` on validation, mirroring `checkMarkerGenotypeFile()`'s
name-forcing), so `first_name`/`second_name` files load unchanged. **Recommended: this
option (a).** **Declined alternatives:** (b) the marker family's long format
(`id, locus, allele1, allele2`) plus an MHC-designation metadata sidecar — forces
curators to reshape colony records into a per-locus fiction (a region-level haplotype
designation is not a locus genotype), routes the data back through
`buildMarkerGenotypeMatrix()` adjacency it doesn't need, and reopens the landmine's
neighborhood for zero benefit at the single-super-locus scale; kept as the documented
*future* path if multi-locus allele-level MHC panels (per-locus Mamu-A/-B typing) ever
become a real input — a new design round, not a silent extension. (c) Reuse Pathway A's
`checkGenotypeFile()` format with a "treat as MHC" opt-in — couples a reporting feature
to the pre-QC merge path whose validation degrades to `NULL` (§1.3 finding 3), puts an
MHC toggle in `modInput` far from the reporting surface, and inherits the
integer-collision guard designed for `addGenotype()`'s encoding, which is irrelevant
here.

**D3 (judgment call — Q2). Uncertain calls: a trailing `?` is the documented,
validator-level uncertainty marker, read as "this haplotype, provisionally called";
uncertain calls are excluded from the frequency denominator and reported as their own
visible count — never counted as a distinct haplotype.** The parse rule (internal
`.parseMhcHaplotypeCalls()`): `NA`/empty = missing; a call matching `^(.+)\?$` = an
*uncertain* call of haplotype `\1`; anything else = a certain call. The summary table
carries a per-haplotype `nUncertain` column and the counts output carries file-level
`nMissing`/`nUncertain`, so nothing is discarded from the record — the statistic
excludes what it excludes *visibly*, honoring the literature's one consistent rule:
ambiguity is modeled, binned, or disclosed, never silently dropped (§2.8: Gragert et
al. 2013's EM treatment; Kanthaswamy et al. 2026's explicit "g#" ambiguity categories;
Caskey et al. 2019's lineage-level reporting). **Recommended: exclude-and-disclose.**
**Presented alternative (the close runner-up):** additionally display an
inclusive-denominator frequency column (`frequencyInclusive`, uncertain calls counted
at their named haplotype) beside the certain-only frequency — the descriptive-report
analogue of HLA practice's keep-and-model instinct; strictly more informative, at the
cost of two frequency columns for a table whose audience is colony managers, and
derivable by hand from `nCopies`/`nUncertain`/`counts` in either direction.
**Declined alternatives:** count `A008_B015b?` as a haplotype distinct from
`A008_B015b` — fabricates diversity and would flag spurious "rare" haplotypes, the
worst failure mode for a rare-haplotype report (visibly wrong on the bundled file,
where both uncertain calls have certain counterparts, §2.1, and contrary to every
surveyed practice, §2.8); strip-the-`?`-and-count-silently — upgrades uncertainty to
certainty with no disclosure. **Boundary notes:** parsing the `?` suffix is a
documented *format* convention of this input (like VCF's `"."` in
`checkSequenceGenotypeFile()`), not MHC-semantics inference from a name — the issue's
prohibition (D9) is untouched. And the `?` convention is a local records annotation
with no published counterpart (§2.8) — the validator documents this design's reading,
and the owner (as the data's curator) is the authority on whether that reading matches
the records' intent (the ratification round is the check).

**D4 (judgment call — Q3). Rarity flag: a dual, independently configurable criterion —
`isRare` when frequency ≤ `rareFrequencyThreshold` (default 0.01) OR carrier count ≤
`rareCarrierThreshold` (default 2) — with both statistics always displayed and the
denominator reported.** The frequency denominator is **certain calls among genotyped
animals** (2 × animals − missing − uncertain; on the bundled file, 60 — §2.1): the 2N-
chromosomes standard of HLA/NHP frequency practice (Solberg et al. 2008; Doxiadis et
al. 2013 — §2.8) and the genotyped-only convention `.markerAlleleFrequencyTable()`
already set, made transparent by the counts output. The dual criterion has direct
published precedent — CIWD 3.0 bins HLA alleles by a frequency criterion AND a
minimum-observation-count criterion in one scheme (§2.8) — and each leg is anchored:
0.01 is the published NHP-MHC "rare" usage (Kanthaswamy et al. 2026; Doxiadis et al.
2013), and carriers ≤ 2 is the management framing (a haplotype carried by ≤ 2 animals
can be lost to two removals regardless of frequency — the Allendorf/PMx
allele-retention rationale, §2.8). **The measured consequence shows why one criterion
alone fails at some scale (§2.1):** at 2N = 60 no observed haplotype can have
frequency ≤ 0.01 (a singleton is 1/60 ≈ 0.017), so the frequency leg alone flags **0**
on the bundled file, while carriers ≤ 2 flags 26/33 — and conversely, at registry
scale (Kanthaswamy 2026's 2,258 animals) the frequency leg is the meaningful one while
a fixed carrier count fades. The dual OR keeps the flag meaningful across colony
sizes. Both defaults are working-filter defaults, presented in the UI as visible,
adjustable thresholds next to a sortable table (D8), not scientific claims — 26/33
flagged on a breeder file is arguably its true state (Dragon 1). **Recommended: dual
criterion, defaults 0.01 / 2.** **Declined alternatives:** frequency-only (flags
nothing at small-colony scale, per the measurement — the feature's primary audience);
carrier-count-only (discards the framing that scales to larger colonies,
cross-colony comparison, and the published rare-usage anchor); flag-on-BOTH-criteria
(on the bundled file flags 0 — the frequency leg gates everything out; strictly weaker
than either alone at every scale).

**D5 (forced by cheapness — Q4, folded, not voted). Affected-animal reporting ships in
both shapes: the per-haplotype summary table AND a carrier detail table (one row per
haplotype × carrier, with the carrier's `uncertain` status).** Both derive from the same
parsed call table at negligible cost; picking one would save nothing and lose a real
use (the summary answers "what is rare," the carrier list answers "which animals do I
manage"). A homozygous animal contributes two copies and one carrier — stated in the
interface contract. Folded into the design as structural rather than presented as a
vote, matching #152's own D7-folding precedent (its §11).

**D6 (forced — Q5). Every MHC export — carrier detail AND summary — routes through the
#150 curator confirm-gate, with ids aliased via a new `obfuscateMhcHaplotypes()`
primitive and an MHC-specific manifest.** The carrier list is an identifying table
(id + MHC type); the paired-haplotype type is near-unique per animal in the bundled file
(27/31 — §2.8) so the *type itself* identifies, and the aggregate floor (Homer et al.
2008, ratified into #152 D7) covers the summary table. The primitive follows
`obfuscateTwinRelations()`'s mold exactly: alias through
`obfuscatePed(..., map = TRUE)$map`, `stop()` on any id absent from the map (§2.6,
Dragon 5). The manifest follows `.buildSequenceExportManifest()`'s mold (`:75-87`) and
records the rarity thresholds and denominator counts in force at export time — without
them an exported rare-haplotype report is uninterpretable. Warning text
(`.mhcExportWarningText`) follows the established institutional-responsibility wording
(`:28-35`, `:42-49`), plus one MHC-specific sentence: haplotype designations themselves
are never altered (there is no validity-preserving obfuscation of an MHC type — the
same rationale as `.sequenceExportWarningText`'s allele-call sentence).

**D7 (forced — Q6). A persistent, non-dismissable descriptive-only caveat, as static UI
markup.** `.mhcHaplotypeCaveatText`, rendered exactly like `.linkageLdBlockCaveatText`
(`:15-21`, `:170-171`): this tab is descriptive haplotype reporting from
curator-supplied designations — counts, frequencies, missingness, and rarity flags. It
is not a replacement for the pedigree-based kinship, founder-representation, or
genome-uniqueness metrics elsewhere in this application, and it performs no MHC
inference of its own. (Wording finalized at Slice 4; the two sentences above are the
required content, per the issue body's own demand.)

**D8 (judgment call — Q7). Surface placement: an eighth tab, "MHC Haplotype Reporting,"
inside `modMarkerGenetics`, with its own dedicated `fileInput` — zero changes to the
existing seven tabs.** The module already owns every pattern this tab needs (§2.4):
genotype-shaped uploads, DT report tabs, the confirm-gate export, caveat markup, and the
pedigree/kinship reactives (for the pedigree-coverage line and the export alias map).
The #153 empirical lesson mandates the dedicated upload (§2.4). The zero-changes
constraint carries #153 D6's precedent forward. **Recommended: eighth tab.** **Declined
alternatives:** a dedicated `modMhcHaplotype.R` module — declined twice already in this
exact cluster (#152 D8, #153 D5) for duplicating tested upload/export scaffolding with
no functional reason; attaching to the Genetic Value / `modInput` surface where Pathway
A's MHC data already enters — couples reporting to the pre-QC merge and its
degrade-to-NULL contract (§1.3 finding 3), and `modInput` has no report-tab surface;
leaving it script-callable-only with no UI — fails the issue's own "affected-animal
reporting and CSV export" requirement for the app's actual users (colony managers, not
R programmers).

**D9 (forced — issue hard requirement). Haplotype labels are opaque identifiers.** No
substructure parsing, ever: the feature never splits `A004_B002` into Mamu-A/Mamu-B
components, never matches label prefixes against locus or region names, and never
derives MHC semantics from any name (the label grammar is a colony-records convention,
not an IPD-issued name — §2.8). The one documented format marker is D3's trailing `?`.
Per-region reporting from label substructure is explicitly rejected (§8) — if
region-level reporting is ever wanted, it arrives as explicit input columns through a
new design round.

**D10 (structural — Q8). Slice decomposition: four slices, each one future strict-TDD
session (§5): validator + parse rule → statistics → de-identification primitive → UI
tab + export + documentation.** The #152/#153 mold (ingestion → metrics → de-id → UI),
scaled down to this feature's single-super-locus scope. Slice count is a plan, not a
cap-of-one-session-each guarantee — each slice closes out independently and FM #18/#19
gates apply at every boundary.

---

## 4. Interface catalog (proposed — for the future implementing sessions; names provisional)

| Interface | Slice | Input | Output | Error contract | New dependency? |
|---|---|---|---|---|---|
| `checkMhcHaplotypeFile(genotype)` | 1 | data.frame, exactly 3 columns: `id` first (case-insensitive match, forced), then two haplotype-designation columns (any names, forced to `haplotype1`, `haplotype2`) — one row per animal | The validated data frame, names forced | `stop()` on: column count ≠ 3; first column not id-like; duplicate `id` rows. `NA`/empty cells pass (missing calls are the statistics layer's concern, not a validation error) | None |
| `.parseMhcHaplotypeCalls(genotype)` (internal) | 1 | `checkMhcHaplotypeFile()` output | Long call table: `id`, `haplotype` (with any trailing `?` stripped), `uncertain` (logical), `missing` (logical) — 2 rows per animal | none (total function over validated input) | None |
| `mhcHaplotypeFrequency(genotype, rareFrequencyThreshold = 0.01, rareCarrierThreshold = 2L)` | 2 | `checkMhcHaplotypeFile()`-validated data frame; thresholds per D4 | `list(summary, counts)`: `summary` = one row per distinct certain haplotype — `haplotype, nCopies, nCarriers, nUncertain, frequency, isRare` (frequency over the D4 denominator; `isRare` = frequency ≤ threshold OR carriers ≤ threshold; a homozygote adds 2 copies / 1 carrier; `nUncertain` = uncertain calls of this haplotype, excluded from `nCopies`/`frequency`); `counts` = `nAnimals, nCalls, nMissing, nUncertain, denominator` | `stop()` on malformed thresholds (non-numeric, negative); validation itself is `checkMhcHaplotypeFile()`'s job (function re-runs it defensively, matching the family convention) | None |
| `mhcHaplotypeCarriers(genotype, rareOnly = TRUE, rareFrequencyThreshold = 0.01, rareCarrierThreshold = 2L)` | 2 | as above | Carrier detail table: `haplotype, id, uncertain` — one row per (haplotype × carrying animal); `rareOnly = TRUE` restricts to D4-flagged haplotypes, `FALSE` lists all | as above | None |
| `obfuscateMhcHaplotypes(carriers, map)` | 3 | a `mhcHaplotypeCarriers()` table; the alias map from `obfuscatePed(..., map = TRUE)$map` | The table with `id` aliased; haplotype labels unchanged (D6) | `stop()` on any `id` absent from `map` (the `obfuscateTwinRelations()` mold — never silently drop or leak) | None |
| `.buildMhcExportManifest(...)` (internal) | 4 | exported tables' dimensions + the D4 thresholds + counts + warning text | One-row manifest data frame (timestamp, package version, thresholds, denominator counts, warning text) — the `.buildSequenceExportManifest()` mold | none | None |
| 8th tab in `modMarkerGeneticsUI`/`Server` | 4 | new `fileInput` (`mhcHaplotypeFile`, CSV); two `numericInput`s (the D4 thresholds); reuses the module's existing `pedigree` reactive | D7 caveat div; summary + carrier DT tables; a pedigree-coverage line when `pedigree` is available ("N of M pedigree animals have MHC designations" — module-level `setdiff`, no new exported function); confirm-gate export (preview → confirm modal → 3 downloads: summary, carrier list, manifest). New returned reactives: `mhcHaplotypeSummaryTable`, `mhcHaplotypeCarrierTable`, `mhcExportTables`, `mhcExportConfirmed` — added to the return list AND to the `@return` roxygen, repairing its stale count (§2.4) | Module-contract rules 1-6 unchanged; malformed upload surfaces as a real reactive error (no blanket `tryCatch`) | None |

---

## 5. Implementation plan (4 slices, each its own future strict-TDD session)

**Slice 1 — Validator + parse rule.** `checkMhcHaplotypeFile()` +
`.parseMhcHaplotypeCalls()` (D2, D3, D9). Fixtures: the bundled real pair
(`rhesusGenotypes`, already shipped — §2.1) plus small synthetic inline fixtures
covering what the real file lacks (missing calls, duplicate ids, wrong column counts,
an all-uncertain animal, a homozygous animal). **Done when:** the validator accepts the
bundled CSV unchanged and rejects each malformed shape with its specific message; the
parse classifies the file's 2 uncertain + 60 certain calls exactly; homozygote and
missing-call semantics match §4's contract. **Verification:** new test file green; full
suite unchanged; `NEWS.Rmd` + `_pkgdown.yml` entries for the new export (same-session
checklists); lint clean.

**Slice 2 — Statistics.** `mhcHaplotypeFrequency()` + `mhcHaplotypeCarriers()` (D4,
D5). **Done when:** hand-computed reference values on a small synthetic fixture match
exactly (including denominator arithmetic with missing + uncertain calls present, and a
homozygote's 2-copies/1-carrier accounting), and the bundled-file totals reproduce this
plan's own measured numbers (33 distinct / denominator 60 / 26 flagged at the D4
defaults, all via the carrier leg — the frequency leg flags 0 at 2N = 60 — §2.1, D4). **Verification:** new test file green; full suite unchanged;
`NEWS.Rmd` + `_pkgdown.yml` for the two new exports; roxygen `@references` carrying the
§2.8 nomenclature/practice citations (citation checklist, issue #120 — owed here, where
the statistics ship); lint clean.

**Slice 3 — De-identification primitive.** `obfuscateMhcHaplotypes()` (D6). **Done
when:** round-trips the `obfuscateTwinRelations()` test mold — aliases every id through
the standard map, `stop()`s on an unknown id, leaves haplotype labels byte-identical.
**Verification:** new test file green; full suite unchanged; `NEWS.Rmd` +
`_pkgdown.yml`; lint clean.

**Slice 4 — UI tab, export gate, documentation.** The 8th tab per §4's last row (D7,
D8), the confirm-gate export with `.buildMhcExportManifest()` and
`.mhcExportWarningText` (D6), the pedigree-coverage line, and the module `@return`
repair (§2.4). **Done when:** the tab is reachable in a running app with the bundled
file end to end (upload → tables → rare flags at visible thresholds → confirm-gated
de-identified export downloading all 3 artifacts), with zero console errors — the
cluster's established Phase 3E bar (live `shinytest2` smoke). **Verification:**
module-contract mechanical test green with the new reactives documented; `NEWS.Rmd`
(user-facing feature, plain-language criterion); tutorial/article checklist
(`vignettes/articles/colony-manager-guide.qmd`); UI-guidance/terms page entry
(`inst/extdata/ui_guidance/population_genetics_terms.html` — "MHC haplotype," rarity
flag semantics); `devtools::check()` clean; lint clean.

---

## 6. Impact analysis

| System | Impact | Action required |
|---|---|---|
| Existing 7 `modMarkerGenetics` tabs, 4 file inputs, 19 returned reactives | None — D8's zero-changes constraint | Slice 4 adds; never modifies |
| `checkMarkerGenotypeFile()` / biallelic gate / `buildMarkerGenotypeMatrix()` / all 6+ marker functions | None — D2(a)'s input never enters this family (§2.3) | None (regression suite already proves non-interference) |
| Pathway A (`checkGenotypeFile()`/`addGenotype()`/`getGVGenotype()`/`geneDrop()` seeding, `modInput.R:469-488`) | None — read-only context (§2.2); the same CSV remains uploadable there for gene-drop seeding, independently | None |
| `obfuscate*` family / #150 export gate | New sibling primitive (Slice 3), mold unchanged | None to existing functions |
| `test_moduleContract.R` | No new server; new returned reactives documented | Slice 4 |
| `DESCRIPTION` | Unchanged — base-R tabulation, zero new dependencies | Re-confirm at each slice close-out |
| `rhesusGenotypes` / bundled CSV / `R/data.R` docs | Reused as the real fixture; dataset docs gain a pointer to the new feature | Slice 1 (docs pointer optional, if touched) |
| Module `@return` roxygen (stale "fourteen", §2.4) | Repaired as part of Slice 4's documented additions | Slice 4 |

---

## 7. Here be dragons

1. **Rarity flags saturate at colony scale — by measurement, not conjecture.** The D4
   defaults flag 26/33 haplotypes on the bundled breeder file, entirely via the carrier
   leg (the frequency leg cannot fire below 2N ≈ 100 — §2.1, D4). That is arguably the
   true state of a breeder file, but a UI that renders 79% of rows flagged reads as an
   alarm, not a filter. Slice 4's UI must keep both thresholds visible next to the
   table and the D7 caveat adjacent; Slice 2's tests must pin the measured numbers so a
   future "fix" to the defaults is a visible, deliberate change.
2. **The label and uncertainty conventions are local, and partially unpublished.** The
   abbreviated haplotype labels follow the published community convention (Wiseman et
   al. 2013, §2.8) but are not IPD-registered names — the same short label is not
   guaranteed stable across labs, so cross-center aggregation of these tables is a
   label-matching risk, not just an id-matching one (Dragon 5). The underscore pairing
   form and the trailing `?` are local records conventions with no published
   counterpart (§2.8). Another center's export might encode uncertainty differently
   (multiple candidate labels, `g#`-style ambiguity groups, blank-vs-`unk`
   distinctions) or carry a third region component (the published "core haplotype" is
   Mhc-A/-B/-DRB — Doxiadis et al. 2013) or a different region order. D9's opacity
   makes the *reporting* robust to all of this (a three-region label is just another
   string; column order never matters), but D3's `?` rule is this design's own
   documented reading — anything else arrives as a new, explicit format decision, never
   a silent regex broadening.
3. **Vocabulary discipline cuts both ways and needs a grep at every slice close-out.**
   This feature legitimately floods the codebase with "haplotype"; the check is that
   none of it lands on #153's LD-block surfaces (and no "block" lands here). `grep -rn
   -i "haplotype" R/ | grep -i -v mhc` against the #153 file set is the cheap per-slice
   audit.
4. **The summary table is aggregate data, not a safe harbor.** Homer et al. 2008's
   floor (already ratified into #152 D7) plus near-unique paired types (27/31 in the
   bundled file, §2.8) is why D6 gates *all* MHC exports, not only the carrier list. Do
   not let a future slice "simplify" by exempting the summary download from the gate.
5. **The export alias map covers pedigree ids only.** An MHC file with an animal absent
   from the loaded pedigree makes `obfuscateMhcHaplotypes()` `stop()` at export (the
   mold's correct loud failure, §2.6) — the tab's report views still work (no pedigree
   needed), so a curator can be surprised late. Slice 4's export-guidance text must name
   this precondition; cross-center id resolution (#149's `resolveCrossCenterIds()`)
   exists but wiring it in is out of scope for this design.
6. **The real fixture has zero missing calls (§2.1).** Every missing-call code path
   exists only through synthetic fixtures — Slice 1 must build them deliberately, or
   missingness reporting ships tested only against "0 missing."
7. **Two uncertain calls is a thin real-data sample for D3.** The bundled file
   exercises the parse rule but not at volume; the synthetic fixtures carry the load
   (all-uncertain animal, uncertain homozygote `X?/X?`, uncertain call of a haplotype
   with no certain counterpart — each has a defined expected output in §4's contract).

---

## 8. Alternatives considered

| Alternative | Pros | Cons | Why rejected |
|---|---|---|---|
| Long-format + MHC-designation metadata sidecar (D2 option b) | Reuses the marker family's machinery; extensible to multi-locus MHC panels | Forces a per-locus fiction onto region-level colony records; reopens biallelic-gate adjacency; no bundled or evidenced real input of that shape | D2 — dedicated wide upload; multi-locus MHC typing is a future design round if it ever materializes |
| Pathway A reuse + "treat as MHC" opt-in (D2 option c) | The data already enters there; zero new upload | Couples reporting to pre-QC merge with degrade-to-NULL validation; designation toggle far from the reporting surface; inherits an irrelevant integer-collision guard | D2 — designation-by-upload in the reporting module itself |
| Count `X?` as a distinct haplotype (D3 alternative) | Zero parse logic | Fabricates diversity; spurious rare flags — the report's worst failure mode; visibly wrong on the bundled file | D3 — exclude-and-disclose |
| Strip `?` and count as certain (D3 alternative) | Maximizes the denominator | Silently upgrades uncertainty to certainty in a descriptive report | D3 — exclude-and-disclose |
| Frequency-only or carrier-only rarity flag (D4 alternatives) | Single, simple criterion | Frequency-only flags nothing below 2N ≈ 100 (measured, §2.1); carrier-only discards the leg that scales up and the published rare-usage anchor; the on-point HLA catalogue standard itself uses both criteria (CIWD 3.0, §2.8) | D4 — dual criterion, both displayed, both configurable |
| `frequencyInclusive` second frequency column (D3 runner-up) | Strictly more informative; closest to HLA keep-and-model practice | Two frequency columns for a colony-manager audience; derivable by hand from the disclosed counts either way | D3 — presented to the owner as the live runner-up in the ratification round, not silently dropped |
| Parse `A004_B002` into Mamu-A/Mamu-B components for per-region reporting | Richer report for free | Infers MHC semantics from a label's internal grammar — the issue's hard prohibition in spirit; label grammar is a colony convention, not a standard (§2.8) | D9 — labels are opaque; per-region reporting would need explicit input columns and a new design round |
| Dedicated `modMhcHaplotype.R` module (D8 alternative) | One-feature-one-module symmetry (#149/#150/#151) | Duplicates upload/export/caveat scaffolding `modMarkerGenetics` owns; declined twice already in this cluster (#152 D8, #153 D5) | D8 — eighth tab |
| Script-callable only, no UI (D8 alternative) | Smaller scope | Fails the issue's affected-animal-reporting + CSV-export requirement for the app's real users | D8 — the tab ships (Slice 4) |
| Exempt the no-id summary table from the export gate (D6 alternative) | One less click for an "anonymous" table | Aggregate statistics are not a safe harbor (Homer et al. 2008, ratified precedent); near-unique paired types identify without ids | D6 — all MHC exports gated |

---

## 9. Close-out checklist mapping

Design-only session — zero `R/`/`tests/`/`man/` changes. All checklists below are **N/A
this session**, each owed at the specific future slice that first triggers it:

- **`NEWS.Rmd` checklist** (plain-language criterion) — owed at Slices 1, 2, 3 (each
  ships exported functions) and Slice 4 (the user-facing tab).
- **`_pkgdown.yml` reference-coverage checklist** — owed at Slices 1, 2, 3.
- **Citation checklist (issue #120)** — owed at Slice 2 (roxygen `@references`: §2.8
  nomenclature/practice sources) and Slice 4 (the
  `population_genetics_terms.html` UI-guidance entry).
- **Tutorial/article checklist (Session 436)** — owed at Slice 4
  (`vignettes/articles/colony-manager-guide.qmd`).
- **`a2interactive.Rmd` script-callable-function checklist** — deferred per its own
  standing rule (a later documentation pass after the feature stabilizes, not any
  individual shipping slice).
- **Lint close-out** — owed at every slice (each touches `.R` files).
- **GitHub issue close-out** — N/A throughout: issue #148 stays open through design AND
  implementation (S703 decision record; the issue closes only when the last slice
  ships).

---

## 10. Provenance

- **Session:** 704, 2026-09-17. Planning session under `SESSION_RUNNER.md` §Planning
  Sessions (the plan is the whole deliverable; FM #18/#19).
- **Starting inventory:** the S703 scoping doc's grep-verified evidence table
  (`docs/planning/issue148-mhc-haplotype-scoping-2026-09-17.md` §3), re-validated this
  session: `git log fcf94807..HEAD -- R/ tests/` is empty, so the inventory's ground
  truth is unchanged; every load-bearing file was nonetheless re-read directly rather
  than trusted (below).
- **Direct reads this session:** `R/modMarkerGenetics.R` (all 860 lines),
  `R/checkMarkerGenotypeFile.R`, `R/checkLinkageMarkerGenotypeFile.R`,
  `R/checkSequenceGenotypeFile.R`, `R/markerAlleleFrequency.R`, `R/checkGenotypeFile.R`,
  `R/addGenotype.R`, `R/getGenotypes.R`, `R/getGVGenotype.R` (roxygen),
  `R/modInput.R:455-509`, `R/obfuscateTwinRelations.R`, `R/data.R:340-380`, the bundled
  CSV itself, `_pkgdown.yml` (marker group), `NAMESPACE` (obfuscate exports), and both
  mold plans (#152, #153) in full.
- **Measurement:** the §2.1 frequency-distribution numbers were computed this session by
  script against the bundled CSV (31 animals / 62 calls / 0 missing / 2 uncertain / 33
  distinct / denominator 60 / 26 flagged at frequency < 0.05 / 0 flagged at frequency
  ≤ 0.01 / 26 flagged at carriers ≤ 2 / 21 singletons / 27 of 31 unique unordered
  pairs) — Slice 2 re-derives them as pinned test expectations.
- **Domain research:** one background `general-purpose` web-research agent (IPD-MHC
  nomenclature and curation, haplotype-designation practice, colony MHC-tracking
  rationale, rarity-threshold conventions, ambiguous-typing handling, MHC
  identifiability, frequency denominators), instructed to tag every claim
  DIRECT/INFERENCE/UNVERIFIED and to prefer a gap over a fabricated citation; findings
  integrated as §2.8 with named sources. Claims the agent could NOT verify were treated
  accordingly: several candidate citations in this document's own working draft
  (a *Tissue Antigens* Mamu-A\*01 paper, a 2007 *J Virol* MCM paper, a chromosome-4
  localization source, a Ballou & Lacy 1995 chapter, and an HLA reporting-standards
  characterization of Hurley et al. 2020, which is actually the CIWD catalogue) were
  **dropped or replaced** with the agent's verified sources rather than carried
  unverified; the underscore label-pairing form and the trailing-`?` convention are
  recorded as *unpublished local conventions* on the agent's explicit
  could-not-verify findings, not as sourced claims. Exact volume/page numbers the agent
  flagged as partly unverified (Yant 2006 PMID; Gragert 2013 and Hurley 2020
  volume/pages; Lacy 2012 volume/pages; Doxiadis 2005 volume/pages) are cited here by
  DOI/PMID where verified and omitted where not — Slice 2's citation checklist re-
  verifies whatever it puts into roxygen `@references`. No design decision rests on an
  unverified agent claim — D2/D3/D4/D6/D8/D9 each stand on the codebase evidence and
  this session's own measurements, with the literature as corroboration.
- **Issues referenced:** #148 (this design), #152/#153 (vocabulary + molds), #150
  (export gate), #147 (independent-helper precedent, D9 there), #149 (cross-center ids,
  named out of scope), #120 (citation checklist).

---

## 11. Ratification status

**Forced (no owner decision needed):** D1 (vocabulary), D5 (both reporting shapes —
folded, cheapness), D6 (export gating + manifest), D7 (descriptive-only caveat), D9
(opaque labels), D10 (slice decomposition — structural).

**Judgment calls (owner ratification via a single `AskUserQuestion` round):** D2 (input
designation: dedicated wide upload vs. long-format + sidecar vs. Pathway A opt-in), D3
(uncertain calls: exclude-and-disclose vs. additionally displaying an
inclusive-frequency column vs. counting uncertain calls in the main frequency), D4
(rarity flag: dual criterion vs. frequency-only vs. carrier-only), D8 (placement: eighth
tab vs. dedicated module vs. Genetic Value surface).

### Ratification outcome (2026-09-17, this session)

Owner selected this document's own recommended option in all four judgment calls, via a
single `AskUserQuestion` round (Session 704, 2026-09-17):

- **D2 — Dedicated wide upload.** `id, haplotype1, haplotype2` behind its own
  `checkMhcHaplotypeFile()` validator inside the MHC tab; designation-by-upload; the
  marker family's validators and the biallelic gate are never touched or adjacent.
- **D3 — Exclude and disclose.** Trailing-`?` calls are excluded from the frequency
  denominator and always visibly counted (`nUncertain` per haplotype, file-level
  counts); never a distinct haplotype. (The inclusive-frequency second column stays a
  recorded, unchosen runner-up — §8.)
- **D4 — Dual criterion.** `isRare` = frequency ≤ 0.01 OR carriers ≤ 2, both thresholds
  configurable, both statistics displayed, denominator reported.
- **D8 — Eighth tab.** "MHC Haplotype Reporting" inside `modMarkerGenetics`, own
  dedicated `fileInput`, zero changes to the existing seven tabs.

No changes requested to any recommended design. All ten design decisions (D1-D10) are
now ratified. This document is ready for pickup by a future implementation session,
starting with Slice 1 (§5) — matching the #133/#136/#137/#145/#146/#147/#149/#150/#151/
#152/#153 precedent of a design-only session with zero `R/`/`tests/`/`man/` changes.
Issue #148 stays intentionally open (design ratified, not yet implemented); no
`gh issue close` this session.
