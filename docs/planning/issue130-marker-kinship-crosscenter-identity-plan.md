# Issue #130 Plan — Marker-based kinship/heterozygosity/parentage-verification + cross-center identity resolution

**Tracks:** GitHub issue **[#130](https://github.com/rmsharp/nprcgenekeepr/issues/130)**
(filed S422, 2026-07-29, from
`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md` Dimensions 5 &
6, Recommendation #3). Last of the six issues (#125-#130) filed from that
audit's triage session; #126/#127/#129 are DONE (owner-ratified sequencing,
`BACKLOG.md:479-485`); this is the only one the audit itself flagged as
needing "its own scoping/design session" (Recommendation #3) rather than a
quick addition — this document is that session's deliverable.

**Authored:** Session 441 (2026-07-30), planning session, following
`ARCHITECTURE_WORKSTREAM.md` (a technology-fit / data-model / dependency /
module-boundary decision — same reasoning class that put issues #126/#127/#129
under this workstream rather than `DESIGN_WORKSTREAM.md`). TDD phases
(RED/GREEN/REFACTOR) are inapplicable to this document — it is a plan, per
this project's established precedent. Implementation is **five** separate
future TDD sessions (RED → GREEN → REFACTOR), one per slice (§4).

**Evidence base:** a 5-agent parallel research `Workflow` this session
(issue #130's own text; the audit's Dimension 5/6 findings + the S422 triage
trail; the existing kinship/genetic-diversity code inventory; the
cross-center/LabKey architecture inventory; a domain-standards survey of
marker-kinship/parentage/cross-institution-identity methods), followed by
firsthand verification of every load-bearing claim before writing this
document — `DESCRIPTION`, `R/columnSchema.R`, `R/kinship.R`,
`R/addGenotype.R`, `R/checkGenotypeFile.R`, `R/hasGenotype.R`,
`R/getGVGenotype.R`, `R/reportGV.R:142-229`, `R/meanKinship.R`,
`R/getPedigreeSource.R`, `R/convertFromCenter.R`, and
`docs/architecture/module-contract.md` were all read directly, not trusted
from agent output alone — per `PROJECT_LEARNINGS.md` Learning 399's named
precedent for this issue family (a 2-for-2 citation-drift hit rate in
#118/#126 that #127/#129's own checks, and this session's, found clean).

> **Scope.** This is the planning deliverable. **No `R/`, `tests/`, `man/`,
> `NAMESPACE`, or `data/` content is changed by writing it.**

> **RATIFIED this session (2026-07-30), via `AskUserQuestion`** — two rounds,
> six decisions, every recommended option accepted. See §3 for the record.

---

## 1. Context

### What issue #130 says (verbatim)

> **Source:** `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md`, Dimensions 5 & 6 (Recommendation #3).
>
> The 2015 NHP Genetics and Genomics Working Group PDF describes several capabilities that were already standard practice in 2015 and that `nprcgenekeepr` does not implement, because the package's entire genetic-analysis engine is pedigree-driven by design rather than marker/genotype-driven:
>
> - **Marker-based (SNP/STR) kinship estimation independent of pedigree** — `R/kinship.R` computes kinship purely from pedigree structure; uploaded genotype data is never used for a marker-based kinship estimate (its only consumer is the gene-drop simulation).
> - **Expected-vs-actual heterozygosity diagnostic from real genotype data** — the only "heterozygosity" hit (`R/calcGeneDiversity.R`) computes gene diversity from founder genome equivalents (a pedigree/gene-drop quantity), not an observed-vs-expected comparison from real genotype data.
> - **Genetic parentage verification from lab genotyping** — no function compares an animal's own genotype against a candidate parent's, so the package cannot catch the ~5% dam-misidentification problem the PDF specifically names; QC checks pedigree self-consistency only.
> - **Cross-center integration** — `R/getSiteInfo.R`/`R/defaultSiteParams.R` model exactly one center per running instance; no function resolves two ID strings for the same physical animal across sites (the PDF's literally-named failure mode: a transferred animal becomes an artificial "founder" at its new center), and no function computes an identity-by-state / allele-frequency differentiation statistic between two centers' genotype datasets.
>
> **Why these four are one issue:** all four require ingesting and analyzing real genotype/multi-center data as a primary analytical input, which is an architecturally distinct engine from the package's current pedigree-simulation core.
>
> **Explicitly out of scope for this issue** (per the audit's own Recommendation #5): NGS/whole-genome sequencing support, MHC-haplotype-specific analysis, and linkage-disequilibrium-block metrics (Dimension 5) are not tracked here or elsewhere.

**Zero comments** on the live issue. Label: `enhancement`. State: open.

### What the audit says (Dimensions 5 & 6, condensed)

`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md:112-152`:

| # | Finding | Status | In scope for #130? |
|---|---|---|---|
| 1 | Marker-based (SNP) pairwise kinship, independent of pedigree | Missing | **Yes** |
| 2 | Expected-vs-actual heterozygosity from genotype data | Missing | **Yes** |
| 3 | NGS/whole-genome/whole-exome support | Missing | **No — declined (Recommendation #5)** |
| 4 | MHC haplotype-specific analysis (frequency reporting, rare-haplotype flagging) | Partial | **No — declined (Recommendation #5)** |
| 5 | Linkage-disequilibrium-block metrics | Missing | **No — declined (Recommendation #5)** |
| 6 | A single pedigree spanning multiple centers | Missing | **Yes (partially — see §2D)** |
| 7 | Identity-by-descent cross-referencing on transfer (the "artificial founder" failure mode) | Missing | **Yes** |
| 8 | Identity-by-state / allele-frequency differentiation between centers | Missing | **Yes** |

Row 3-5 are the **declined** cluster — the audit's own Recommendation #5:
*"No action item is implied for NGS/MHC-specific/LD-block methods — the
source document itself treats these as speculative future work, not a
present-day gap."* Not tracked by this plan, this issue, or any other open
issue.

The audit's own structural framing (`:252-267`) is the reason this cluster
got a dedicated planning session instead of a quick fix: *"anything that
requires molecular/marker data as a primary input rather than a gene-drop
simulation seed... is uniformly absent, because the package's entire
genetic-analysis engine is pedigree-driven by design."*

### Prior process history

- S422 triaged the audit's 6 recommendation clusters via owner
  `AskUserQuestion` picks, filing GitHub issues #125-#130 for all of them;
  #130 was the only one the audit's own Recommendation #3 called out by
  name as needing "a separate future initiative requiring its own scoping/
  design session" (`CHANGELOG.md:723-745`, `PROJECT_LEARNINGS.md`
  Learning 387).
- #126 (DONE S429), #127 (DONE S431), #129 (DONE S434) all shipped under
  the owner-ratified sequencing (S428); #130's planning was next
  (`BACKLOG.md:479-485`, `SESSION_NOTES.md` S437-S440 handoffs). This
  session is that planning step.
- Learning 399 named #127/#129/#130 as sharing a standing risk — evidence
  cited in a plan pointing at a dead/renamed helper — after finding it in
  #126's own planning session. #127 and #129's own checks came back clean;
  this session's firsthand re-verification (above) likewise found every
  cited file/line accurate — no drift.

---

## 2. Evidence-based inventory

### 2A. The pedigree data model today

One flat `data.frame`, keyed by `id`, with `sire`/`dam` self-referencing
parent pointers — no separate "individual" object, no locus/marker
dimension anywhere in the schema.

- `R/columnSchema.R:15-24` (`.nprcColumnSchema`) is the single source of
  truth: `required = c("id","sire","dam","sex","birth")`; `possible`
  reserves exactly `first`, `second`, `first_name`, `second_name`
  (singular) for genotype data — **no multi-locus slot exists**.
- `data/pedWithGenotype.RData` (`R/data.R:251-260`) shows the one-locus
  genotype-bearing shape in practice: the pedigree columns plus
  `first, second, first_name, second_name` — 4 extra columns total, for
  one locus.

### 2B. Kinship is 100% pedigree-derived — and the extension point is exact

- `R/kinship.R:62-104` — Therneau/Lange recursive additive-kinship
  algorithm. Input is purely `id`/`father.id`/`mother.id`/`pdepth`. Output:
  an `id × id` numeric matrix.
- `R/reportGV.R:159-178` (verified directly this session) — the two paths
  are **computed independently and never touch each other** before the
  report line: `genotype <- getGVGenotype(ped)` (line 159) is fetched, but
  the kinship matrix at line 162-165,
  `kmat <- filterKinMatrix(probands, kinship(ped$id, ped$sire, ped$dam, ped$gen))`,
  never references `genotype` at all. `genotype` isn't consumed until line
  203-207, as `geneDrop()`'s seed input — an entirely separate,
  simulation-based pipeline (§2C).
- `R/meanKinship.R:28-30` — `meanKinship <- function(kmat) colMeans(kmat, na.rm = TRUE)`.
  This is **agnostic to how `kmat` was built** — it operates on the matrix
  shape alone (`id`-named rows/cols).

**This is the exact seam**: a marker-based kinship function that returns
an `id × id` matrix of the same shape `kinship()` returns can be
substituted or blended at `reportGV.R:162-165`. Everything downstream
(`meanKinship()`, `prepareKinshipOverrides()`/
`applyKinshipOverridesToMatrix()`, `correctUnknownParentMeanKinship()`,
`scale()` → z-scores) is written against the matrix shape, not against
`kinship()`'s pedigree-recursion internals, and needs zero changes.

### 2C. The existing genotype path is single-locus, gene-drop-only, and never reaches kinship

- `data-raw/rhesusGenotypes.R:4-22` — `rhesusGenotypes` is a hand-saved,
  non-reproducible, **31-animal, one-MHC-locus, two-haplotype** table
  (verified: `data/rhesusGenotypes.RData` is 31 × 3, columns
  `id, first_name, second_name`). Not a SNP panel.
- `R/checkGenotypeFile.R:39-68` (verified) requires exactly 3 columns
  (`id` + 2 allele columns) and explicitly **forbids** columns literally
  named `first`/`second` (reserved for internal integer encoding).
- `R/addGenotype.R:30-50` (verified) builds a name→integer allele
  dictionary from the union of both allele columns and merges `first`/
  `second` integer columns onto the pedigree by `id`.
- `R/hasGenotype.R` / `R/getGVGenotype.R` (verified) gate/extract exactly
  `id, first, second` — one locus, hardcoded column names.
- `grep -rn "rhesusGenotypes" R/ tests/` shows it used only in roxygen
  `@examples` and its own structural contract test — **never** in
  `R/kinship.R`, `R/meanKinship.R`, or `R/reportGV.R`'s kinship path.
- Sole live consumer: `geneDrop()` (`R/geneDrop.R`, MacCluer/Vandeberg/
  Ryder 1986 Monte Carlo gene-drop, cited `R/geneDrop.R:8-10`) — an
  animal's known `first`/`second` alleles seed that animal's draw instead
  of a random one; `calcGU()`/`calcGeneDiversity()` operate on the
  *simulated* allele-transmission output, not on real marker data.

**Conclusion:** this plan's marker-based capabilities are **new,
additive, sibling functions** — `checkGenotypeFile()`, `addGenotype()`,
`hasGenotype()`, `getGVGenotype()`, and the whole gene-drop path stay
**completely untouched**. They are a different concern (simulation seed
data), not a smaller version of what this plan builds.

### 2D. Cross-center is whole-instance config, not per-record data — and zero identity-resolution code exists

- `R/getSiteInfo.R:37-99` / `R/defaultSiteParams.R:23-36` (verified) —
  **one** center (`center`, `baseUrl`, `schemaName`, ...) per running
  instance. No column, field, or key anywhere tags an individual animal
  record with which center it came from beyond one binary flag.
- `R/convertFromCenter.R:23-50` (verified) — `convertFromCenter()`
  normalizes a `fromCenter` yes/no column into a logical. This answers
  "was this animal born at *this* center" — a same-center provenance
  flag, **not** an identity key distinguishing *which other* center a
  transferred animal came from.
- `grep -rniE "cross-center|cross center|identity resolution|record linkage"` —
  every hit is in `docs/`, describing the gap; **zero hits in `R/`**. The
  only `duplicate` hits in `R/` (`R/removeDuplicates.R` etc.) are
  intra-source exact-duplicate-row detection, not cross-source
  reconciliation.

**Conclusion:** this is a real, from-scratch gap — no seam, stub, or
placeholder exists anywhere in `R/`.

### 2E. `getPedigreeSource()` — the precedent shape for a new data-source seam

`R/getPedigreeSource.R:38-122` (verified in full):

- Single `match.arg`-dispatched, `@noRd` internal function,
  `sourceType = c("labkey", "dataframe", "file")`.
- **Uniform output contract** regardless of provider (a normalized
  `data.frame`); each branch validates its own inputs and either
  early-returns or `stop()`s.
- **Fail-soft vs. fail-loud is provider-specific by design**: the live
  network provider (`"labkey"`) returns `NULL` on fetch failure
  (preserving `getLkDirectRelatives()`'s existing fail-soft contract);
  the offline/deterministic providers (`"dataframe"`, `"file"`) `stop()`
  loudly on invalid input.
- Callers (`getLkDirectRelatives()`, `getFileDirectRelatives()`) are thin,
  source-agnostic wrappers delegating to the same
  `getPedDirectRelatives()` walk — they never branch on `sourceType`.

This is the direct precedent for D5 (§3) — a new provider/seam for
cross-center linking should follow the same shape: one dispatcher, one
normalized output contract, provider-specific fail behavior, source-
agnostic consumers.

### 2F. Module-contract rules a new module must satisfy

`docs/architecture/module-contract.md` (verified in full), governing all
`mod*UI`/`mod*Server` pairs:

```
modXUI(id)                      -> a tagList. No exceptions.
modXServer(id, <named args>)    -> a NAMED LIST OF REACTIVES, over a stable vocabulary.
```

Six rules (only rule 2 — named list of reactives — is mechanically
enforced, by `tests/testthat/test_moduleContract.R`); reference
implementation `modInput` (`R/modInput.R`). A new module must add itself
to `test_moduleContract.R`'s `moduleContractServers` list.

### 2G. Domain-standard methods surveyed

**Marker-based kinship** (grounds D2, §3): **KING-robust** (Manichaikul
et al. 2010) — moment-based, robust to population substructure, no
reference-population model needed, mature and cheap; **PC-Relate**
(Conomos et al. 2016, Bioconductor `GENESIS`) — heavier, needs a correct
PC-AiR ancestry-PCA run first, best when real substructure exists; **GCTA
GRM** — heavyweight, built for GREML variance-component work, not
primarily a pairwise-relatedness tool; **PLINK `--genome`/PI_HAT** —
simplest, but biased under population substructure/inbreeding (exactly
the captive-colony scenario).

**Heterozygosity** (grounds §4 Slice 2): `VCFtools --het` / `PLINK --het`
compute observed-vs-expected homozygosity/heterozygosity per individual
from allele frequencies and genotype calls — the standard, lightweight
approach.

**Parentage verification** (grounds D4, §3): **Mendelian exclusion**
(deterministic, auditable, the ISAG/livestock-registry model) vs.
**CERVUS** (pairwise LOD-score likelihood) vs. **COLONY** (full-pedigree
joint maximum-likelihood — more powerful, heavier, more complex to
configure).

**Cross-institution identity resolution** (grounds D5, §3): the field's
actual production model is **deterministic ID matching** — Species360
ZIMS's persistent **Global Accession Number (GAN)**, or the ISO
11784/11785 microchip standard — with a **human-in-the-loop** confirmation
step (ZIMS's "Suggested Animals" candidate list, curator-reviewed, not an
automatic merge). Probabilistic/fuzzy record linkage (Fellegi-Sunter,
e.g. the `Splink` library) is a real general-purpose technique but **not**
the documented default in any studbook/colony-management system found.

**Real, directly relevant precedent**: the NPRC Genomics and Genetics
Working Group already runs Ancestry-Informative-Marker (AIM) and
Genetic-Management (GM) SNP panels on rhesus macaques (96-SNP Fluidigm
BioMark HD assay) at Tulane/TNPRC and OHSU/ONPRC, specifically for
parentage, inbreeding/kinship, heterozygosity, and colony genetic-
subdivision — i.e., exactly this plan's four capabilities, already
operating in the wild for this package's actual user base.

---

## 3. Design decisions — RATIFIED (Session 441, 2026-07-30, via `AskUserQuestion`)

- **D1 — Genotype data format: long/tidy.** New multi-locus genotype
  input is a long-format table — one row per `id` × `locus` × allele pair
  (`id, locus, allele1, allele2`). Rationale: arbitrary marker-panel size
  with no header explosion; validated the same simple way as the existing
  `checkGenotypeFile()` (structural + legal-domain checks, not a schema
  per panel size). **Declined:** wide format (column count grows with
  panel size, needs per-panel header validation); adopting a standard
  genetics file format like PLINK bed/bim/fam (interoperable, but a much
  heavier parsing/validation dependency and a sharp departure from the
  package's plain-CSV philosophy).
- **D2 — Marker kinship: native KING-robust, implemented in base R, no
  new hard dependency.** Rationale: matches the package's existing
  self-contained-implementation philosophy (`kinship()`/`geneDrop()` are
  both hand-written, §2B/§2C); KING-robust is specifically robust to
  population substructure (§2G); produces the same `id × id` matrix shape
  `kinship()` already returns, so it plugs into `reportGV()`'s existing
  downstream pipeline (§2B) with zero changes there. **Declined:**
  depending on `SNPRelate`/`GENESIS` — both **Bioconductor-only**;
  `nprcgenekeepr` is CRAN-published (v2.0.0, accepted 2026-07-26,
  `BACKLOG.md`) and every current `Imports:` entry resolves on CRAN
  (verified, `DESCRIPTION:39-58` — zero Bioconductor deps today); a hard
  Bioconductor `Imports` is a real publishability risk this plan avoids
  outright. Native PLINK-style IBS/PI_HAT — simpler, but biased under
  substructure (§2G), which a captive breeding colony plausibly has.
- **D3 — Heterozygosity: derived from D1, not separately ratified.**
  Observed heterozygosity (fraction of heterozygous loci per animal) and
  expected heterozygosity (from population allele frequencies, the
  standard `He = 1 - Σp²` form) computed directly from D1's long-format
  table — the standard `VCFtools`/`PLINK --het` approach (§2G) has no
  reasonable contested alternative, so this was not put to a ratification
  question.
- **D4 — Parentage verification: Mendelian exclusion, implemented in base
  R.** Rationale: deterministic locus-by-locus check that a candidate
  parent could have contributed an allele to the offspring; auditable;
  matches the package's existing deterministic-QC philosophy
  (`qcStudbook()` already flags pedigree self-consistency the same way).
  **Declined:** likelihood-based scoring (CERVUS/COLONY-style LOD scores)
  — more statistically powerful (handles genotyping error, ranks
  candidates) but a materially larger implementation (error-rate
  modeling, LOD calibration) — a plausible future enhancement, explicitly
  not in this plan's scope.
- **D5 — Cross-center identity linking: deterministic cross-reference
  table.** A new pedigree-source-style provider (extending the
  `getPedigreeSource()` pattern, §2E) accepting a curator-supplied
  mapping table linking a center-A id to its center-B id. Rationale:
  matches real production practice (§2G — ZIMS's GAN, microchip/studbook-
  ID matching, always with human confirmation); deterministic and
  auditable. **Declined:** probabilistic/fuzzy record linkage — heavier,
  less auditable, and not what any real studbook system defaults to.
- **D6 — Module structure: new dedicated `modMarkerGenetics` module.**
  Rationale: matches the existing one-module-per-analytical-concern
  pattern (`modGeneticDiversity`, `modBreedingGroups`, `modPedigree` each
  own one concern, §2F); the issue's own text frames this as "an
  architecturally distinct engine" (§1), not a small addition to an
  existing tab. **Declined:** extending `modGeneticDiversity` — couples a
  genuinely new, real-genotype-driven engine onto a module whose current
  contract and reactive vocabulary are entirely pedigree/gene-drop-
  simulation-based.
- **D7 — Slicing: five vertical slices, dependency order.** See §4 for
  the full breakdown and dependency graph. Rationale: each slice ships
  one real, end-to-end, independently valuable capability — matching the
  vertical-slice discipline (`SESSION_RUNNER.md` FM #25/#26). **Declined:**
  two larger bundled slices ("marker genetics" then "cross-center") —
  fewer sessions, but each bundle mixes multiple independently-shippable
  capabilities into one session, the exact shape FM #26 warns against.

---

## 4. Implementation plan — vertical slices (one session each)

**Dependency graph** (a genuine finding of this session's inventory, not
just the issue's own Dimension-5/6 ordering): Slice 1 is the only hard
prerequisite for Slices 2, 3, and 5 (they all reuse its multi-locus
genotype model). **Slice 4 (cross-center linking) needs none of the
genotype infrastructure at all** — it is a pure pedigree/config-data-model
capability and can be done in any order relative to the others. Slice 5
(the cross-center *differentiation statistic*) needs Slice 1's genotype
model but **not** Slice 4's linking — the audit's own Dimension-6 wording
("no function accepts two centers' genotype datasets and computes a
between-population differentiation statistic") is a population-level,
two-dataset comparison, not a per-animal-identity operation.

```
Slice 1 (marker kinship + genotype foundation)
  |-- Slice 2 (heterozygosity)
  |-- Slice 3 (parentage verification)
  `-- Slice 5 (cross-center differentiation stat)
Slice 4 (cross-center linking) -- independent, any time
```

### Slice 1 = Marker-based kinship (KING-robust) + the multi-locus genotype foundation

**Scope.** Establish the D1 long-format genotype ingestion/validation
(new, sibling to — not a modification of — `checkGenotypeFile()`/
`addGenotype()`, §2C), a marker-based kinship function returning an
`id × id` matrix (D2), and a new `modMarkerGenetics` module (D6)
surfacing a per-animal comparison: pedigree-based mean kinship (already
in the GVA report, §2B) alongside the new marker-based mean kinship. This
is the capability's actual user value — an *independent* check on the
pedigree-implied relatedness, not a replacement for it (matching the
issue's own "independent of pedigree" framing).

**What does NOT change:** `R/kinship.R`, `R/meanKinship.R`,
`R/reportGV.R`'s existing pedigree-kinship call at line 162-165 (a marker
matrix is a new, separate output — not substituted in place, so pedigree
-based reports are unaffected); `checkGenotypeFile()`/`addGenotype()`/
`hasGenotype()`/`getGVGenotype()`/`geneDrop()` (the single-locus gene-drop
path, §2C) — completely untouched.

**Files to touch (proposed; confirm exact names at Pre-RED):**
- `R/checkMarkerGenotypeFile.R` — validates the D1 long-format table
  (`id, locus, allele1, allele2`), same validation style as
  `checkGenotypeFile()` (first column forced to `id`, legal-domain
  checks) but a distinct function/contract — the existing function's
  callers and tests must not change.
- A matrix-builder (e.g. `R/buildMarkerGenotypeMatrix.R`) pivoting the
  long-format table into whatever shape the kinship estimator needs.
- `R/markerKinship.R` (or similar) — the KING-robust estimator, returning
  an `id × id` matrix with the same `dimnames` contract as `kinship()`.
- `R/modMarkerGenetics.R` — new `mod*UI`/`mod*Server` pair (module
  contract, §2F): upload/select a marker genotype file, compute, display
  a pedigree-vs-marker mean-kinship comparison table.
- `tests/testthat/test_moduleContract.R` — add `modMarkerGenetics` to
  `moduleContractServers`.
- `DESCRIPTION` — confirm no new `Imports:` needed (D2 commits to base R).

**RED:** unit tests for the validator, the matrix-builder, and
`markerKinship()` against a small, hand-built multi-locus fixture with a
known trio (parent/offspring/unrelated-founder) so kinship values are
hand-verifiable; module-contract test entry.

**GREEN:** implement; wire `modMarkerGenetics`.

**DONE looks like:** `devtools::check()` 0/0/0; new unit tests pass; live
`shinytest2`/`chromote` smoke test confirms the module renders a real
computed comparison table with no console errors.

**Verify:** targeted test file; full clean regression read; `devtools::check()`;
Phase 3E live smoke test.

**Session boundary:** one session. Slices 2/3/5 are separate future
sessions and depend on this one; Slice 4 does not.

### Slice 2 = Heterozygosity diagnostic (observed vs. expected)

**Scope.** New function(s) computing per-animal observed heterozygosity
and population-level expected heterozygosity (D3) from Slice 1's D1
long-format genotype table; surfaced as a new tab/section in
`modMarkerGenetics`.

**DONE looks like:** hand-verifiable unit tests against a small fixture
with a known Ho/He answer; live smoke test shows the new tab with real
computed values.

**Session boundary:** one session, after Slice 1.

### Slice 3 = Genetic parentage verification (Mendelian exclusion)

**Scope.** New function comparing an offspring's genotype (D1 format)
against a candidate parent's, per locus, flagging loci where no shared
allele is possible under simple Mendelian inheritance; aggregates to a
per-pair exclusion count/flag. Directly targets the issue's named ~5%
dam-misidentification problem: specifically highlight cases where the
*pedigree's recorded* dam or sire is excluded by the genotype evidence.
Surfaced via `modMarkerGenetics` as a flagged-pairs table, echoing
`qcStudbook()`'s existing flagged-issue-list vocabulary (module-contract
§2F canonical-naming rule) rather than inventing new terminology.

**Session boundary:** one session, after Slice 1. Independent of Slice 2.

### Slice 4 = Cross-center identity linking (deterministic cross-reference table)

**Scope.** A new provider in the `getPedigreeSource()` style (§2E, D5):
accepts a curator-supplied mapping table (local id, other-center id,
other-center name) and merges/rewrites two centers' pedigrees so a
transferred animal collapses to one node with its real parents intact,
instead of appearing as an artificial founder at the new center (the
issue's literally-named failure mode). This is a pure pedigree/data-model
operation — **no genotype data involved at all**.

**Files to touch (proposed):** a new merge/resolve function (e.g.
`R/resolveCrossCenterIds.R`), consumed first as an exported,
script-callable utility (matching the package's existing dual Shiny +
scriptable-function design intent, and the precedent of
`getFileDirectRelatives()` shipping standalone before any UI wiring) —
whether Shiny wiring (e.g. a second-pedigree-file input on `modInput`) is
in this slice's scope or deferred further is an open call for this
slice's own Pre-RED, not fixed here.

**DONE looks like:** given two small pedigree fixtures + a mapping table,
the merged pedigree treats the transferred animal as one node with
correct parentage; `kinship()`/`reportGV()` run against the merged
pedigree produce non-zero, correct kinship for the transferred animal's
relatives at both centers (the concrete proof the "artificial founder"
bug is actually fixed, not just that a merge function exists).

**Session boundary:** one session. Independent of Slices 1/2/3/5 —
schedulable at any point.

### Slice 5 = Cross-center identity-by-state differentiation statistic

**Scope.** A new function accepting **two centers' Slice-1-format
genotype tables** (no per-animal linkage needed — a population-level
comparison, confirmed independent of Slice 4 by this session's own
re-reading of the audit's Dimension-6 wording, §4 dependency graph) and
computing a named, real between-population allele-frequency
differentiation statistic. Surfaced via `modMarkerGenetics` as a new
"Cross-Center" tab, reusing Slice 1's upload pattern twice (once per
center).

**Session boundary:** one session, after Slice 1. Independent of Slice 4.

---

## 5. Cross-slice notes

- All of Slices 1/2/3/5 share D1's long-format genotype schema — Slice 1
  must design it generally enough for the others' needs (arbitrary locus
  count, arbitrary allele count per locus at the *schema* level, even
  where a given slice's estimator constrains itself further — see Dragon
  below).
- The existing single-locus genotype path (§2C) is untouched by all five
  slices — a parallel, independent concern, not a smaller version of this
  work.
- Per `CLAUDE.md`'s citation checklist (issue #120): **every** slice here
  ships a new displayed statistic (marker kinship, heterozygosity,
  exclusion rate, differentiation statistic) — each slice's own session
  must update `inst/extdata/ui_guidance/population_genetics_terms.html`
  and the new function's own roxygen `@references` in the **same**
  session it ships, not deferred.
- Per `CLAUDE.md`'s tutorial/article documentation checklist (S436): each
  slice ships a new Shiny tab/control — each slice's session must update
  the relevant tutorial/article in the same session. Issue #139 (zero
  tutorial coverage for #129's Diagram tab, caught two sessions late) is
  the standing cautionary precedent — do not repeat it five times.
- `modMarkerGenetics` needs its own entry in
  `tests/testthat/test_moduleContract.R` — Slice 1's job, since it is the
  module's first appearance.

---

## 6. Here be dragons (consolidated load-bearing risks)

- **P1 — Biallelic-vs-multiallelic mismatch.** KING-robust, as classically
  formulated, assumes biallelic SNP markers. The package's own bundled
  example data (`rhesusGenotypes`, §2C) is MHC-haplotype-labeled and
  plausibly **multiallelic**, not biallelic SNPs. Slice 1's Pre-RED must
  resolve this explicitly — either document a biallelic-only input
  constraint, or verify/derive a multiallelic-compatible formula from a
  citable source — rather than silently assuming the bundled example data
  is valid input.
- **P2 — Exact statistical formulas are deliberately not reproduced
  here.** Neither KING-robust's exact closed form nor a specific
  cross-center differentiation-statistic formula (Fst has multiple
  competing estimators, e.g. Weir & Cockerham 1984) is asserted in this
  document — doing so from memory without in-session verification would
  risk propagating an unverified derivation into an implementation
  session that trusts the plan. **Slice 1 and Slice 5's own Pre-RED must
  each pull the exact formula from a primary or citable secondary source**
  before writing RED tests.
- **P3 — No real multi-locus fixture exists yet.** `rhesusGenotypes` is
  single-locus. Slice 1 must either hand-build a small synthetic
  multi-locus fixture (values chosen so kinship/heterozygosity are
  hand-verifiable) or extend the bundled example data — this plan does
  not commit to which; that choice belongs to Slice 1's Pre-RED.
- **P4 — Slice 3's genotyping-error tolerance is not fixed by this plan.**
  A real production panel's per-locus error rate is unknown to this
  session; a naive zero-tolerance Mendelian-exclusion rule risks false
  conflicts from single genotyping errors. Slice 3's Pre-RED should pick
  a conservative, documented, tunable threshold rather than a hardcoded
  magic number.
- **P5 — CRAN-publishability guardrail.** D2 exists specifically to avoid
  a Bioconductor dependency. If a future slice's implementing session is
  tempted to reach for `SNPRelate`/`GENESIS` "just for this one thing," that
  reopens a decision this plan explicitly closed — flag it loudly and
  bring it back to an `AskUserQuestion`, don't quietly add the dependency.
- **P6 — Slice 4's Shiny-wiring scope is open.** Whether cross-center
  linking gets a UI in the same session it ships as an exported function,
  or is deferred further, is Slice 4's own Pre-RED call, not fixed here.
- **P7 — Five slices is real surface for one issue.** If a future
  session's Pre-RED discovers Slice 1's genotype-schema design doesn't
  actually generalize cleanly to Slice 3 or Slice 5's needs, that is
  grounds to revisit D1 via a fresh `AskUserQuestion` before proceeding —
  not to quietly patch around a mismatch.

---

## 7. Owner ratification record

- [x] D1 — Genotype data format: long/tidy.
- [x] D2 — Marker kinship: native KING-robust, base R, no new hard
      dependency.
- [x] D4 — Parentage verification: Mendelian exclusion, base R.
- [x] D5 — Cross-center identity linking: deterministic cross-reference
      table.
- [x] D6 — Module structure: new dedicated `modMarkerGenetics`.
- [x] D7 — Slicing: five vertical slices in dependency order (§4).

(D3 — heterozygosity approach — was derived from D1, not independently
ratified; see §3.)
