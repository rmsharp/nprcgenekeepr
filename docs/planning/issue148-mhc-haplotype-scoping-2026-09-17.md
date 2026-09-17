## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Issue #148 — MHC Haplotype Reporting: Scope-Narrowing Decision Record

**Status:** Scope-narrowing decision record (Session 703, 2026-09-17). Docs-only session —
zero `R/`/`tests/`/`man/` changes. This document is **not** the issue #148 design plan; it
records the owner's scope decision that audit Finding #4 required before any #148 work, plus
the evidence inventory the future design-plan session starts from. The design plan itself
(`docs/planning/issue148-mhc-haplotype-reporting-plan.md`) is a separate, later session's
deliverable, and implementation is gated on that plan being ratified — matching the
#133/#136/#137/#145/#146/#147/#149/#150/#151/#152/#153 design-first precedent.

---

## 1. The decision

**Owner decision (2026-09-17, S703, via `AskUserQuestion`): "Design-first, same issue."**

Issue #148 advances design-first *without* filing a new sub-issue: the next #148 session
writes `docs/planning/issue148-mhc-haplotype-reporting-plan.md` in the #152/#153 mold
(numbered design decisions, vertical-slice list, per-slice completion criteria, each slice a
separate strict-TDD session), and implementation slices follow only after that plan is
ratified. An issue comment on #148 records this narrowing so the issue's full-feature body is
read through this gate from now on.

**Rejected alternatives** (recorded so a future session doesn't re-litigate from scratch):

- **Split into a design-only sub-issue** (the audit's literal wording, Finding #4
  `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md:186-188`): same work
  plus one more issue to track and close. Declined as unnecessary ceremony — every prior
  design-first issue in this family (#146–#153) kept design + implementation under one issue
  number with a plan doc in `docs/planning/`, and that shape worked eleven times.
- **Implement as filed:** against Finding #4's explicit recommendation; leaves the
  input-format/validator decisions (§4) to be made ad hoc mid-implementation.
- **Defer / park:** legitimate (lowest audit tier, descriptive-only feature) but not chosen —
  #148 is the sequencing audit's last open item and the owner elected to queue its design.

## 2. Source context

### 2.1 What issue #148 asks for (verbatim body, filed 2026-08-06)

> **Source:** `GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`: MHC-specific reporting is
> partial.
>
> MHC-style alleles are accepted through the generic genotype pipeline, but the package does
> not identify MHC loci/haplotypes, report their frequencies, or flag rare haplotypes.
>
> Add an optional MHC-aware analysis with an explicit input designation or validated
> metadata, per-haplotype counts/frequencies and missingness, configurable rarity flagging,
> affected-animal reporting and CSV export. Make clear this is descriptive haplotype
> reporting, not a replacement for pedigree/genome-uniqueness metrics. Do not infer MHC
> semantics from arbitrary locus names.

### 2.2 Why a scope gate existed (audit Finding #4, 2026-08-08)

`GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md:171-188`: #148 was filed as a full
shippable feature while the audit's own recommendation for its (Deferred/scientific) tier was
"advance only through separately scoped research/design work" — the design-only framing
#152/#153 were filed with and #148 was not. The audit also named a concrete technical
landmine: `checkMarkerGenotypeFile()` hard-rejects any locus with more than two distinct
alleles, real MHC haplotype panels are highly polymorphic, and a careless implementation
would either always error on real MHC input or weaken the biallelic check globally —
silently breaking the KING-robust kinship estimator's correctness assumption for every other
caller. #148 was deliberately sequenced last (#152 → #153 → #148,
`GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md:270-273`) so a haplotype-vocabulary
disambiguation would exist first.

## 3. Evidence inventory — what exists now (grep-verified 2026-09-17)

The audit's preconditions have all been satisfied since it was written; every sibling issue
in the 2026-08-06 batch (#146/#147/#149/#150/#151/#152/#153) is shipped and closed.

| Precondition / building block | Status | Evidence |
|---|---|---|
| Haplotype-vocabulary disambiguation | **Exists.** "haplotype" is *reserved* for #148's classical named-MHC-allele meaning; the LD work says "block"/"LD block" throughout | `R/modMarkerGenetics.R:6-9` (D1 vocabulary discipline comment); `docs/planning/issue152-sequence-input-genetic-metrics-plan.md:300-304` (D4, ratified); `docs/planning/issue153-linkage-haplotype-block-metrics-plan.md` §1.2 |
| Validator-landmine defusal pattern | **Established.** Purpose-specific sibling validators per input family, never touching the biallelic gate | `R/checkLinkageMarkerGenotypeFile.R`, `R/checkSequenceGenotypeFile.R` (both shipped); the biallelic rejection itself unchanged at `R/checkMarkerGenotypeFile.R:68-77` |
| Per-locus allele-frequency machinery | **Exists** (internal, deliberately independent per #147 Slice 1 D9) | `R/markerAlleleFrequency.R:26` (`.markerAlleleFrequencyTable`: genotype matrix + locus → named allele→frequency vector) |
| Curator-controlled export gate for identifying tables | **Exists and reused twice** (#150 established; #152 D7 and #153 D9 route through it) | `R/modDeidentifiedExport.R`; `R/modMarkerGenetics.R` (`.linkageExportWarningText`, D7/D9 comments) |
| UI surface to extend | **Exists.** `modMarkerGenetics` tabsetPanel with 7 tabs; opt-in-tab pattern (#153 D6: "zero changes to existing tabs") | `R/modMarkerGenetics.R:136-189` (Kinship Comparison, Heterozygosity, Parentage Exclusion, Cross-Center, Candidate Parent Assignment, Linkage and LD Block Metrics, Genomic ROH) |
| Real MHC-shaped example data | **Exists**, currently flowing through the generic pipeline exactly as the issue body says | `inst/extdata/examples/obfuscated_rhesus_mhc_breeder_genotypes.csv` (31 animals; wide `id, first_name, second_name`; free-text labels like `A004_B002`, incl. `?`-suffixed uncertain calls, e.g. `A008_B015b?`); documented as `rhesusGenotypes` in `R/data.R:352-364` |
| The generic pipeline the issue references ("Pathway A") | **Exists**, MHC-unaware by design | `R/checkGenotypeFile.R` (≥3 columns, id + two name columns) → `R/addGenotype.R` (gene-drop seeding); no frequency/rarity/missingness reporting |
| MHC-specific identification, per-haplotype counts/frequencies/missingness, rarity flagging, affected-animal report, CSV export | **Missing** — the actual #148 gap | `grep -rn -i "mhc" R/` matches only the vocabulary-reservation comment in `R/modMarkerGenetics.R` and the `R/data.R` dataset docs |

## 4. Open design questions the plan session must decide (not decided here)

Numbered as questions (Q), deliberately *not* as ratified decisions (D) — ratifying them is
the design-plan session's deliverable, in the #152/#153 mold:

1. **Q1 — Input designation mechanism.** The issue forbids inferring MHC semantics from
   locus names, so designation must be explicit. Candidates: (a) a dedicated MHC upload
   (wide `id, haplotype1, haplotype2` matching the existing `rhesusGenotypes` shape) behind
   its own `checkMhcHaplotypeFile()`-style validator — the sibling-validator pattern; (b) the
   D1 long format (`id, locus, allele1, allele2`) plus a validated MHC-designation metadata
   sidecar (the `locusMetadata` precedent, #152 D3); (c) reuse of Pathway A's
   `checkGenotypeFile()` format with an explicit "treat as MHC haplotypes" opt-in. The
   existing example file favors (a) or (c); multi-locus MHC panels would favor (b).
2. **Q2 — Uncertain-call handling.** The real example data contains `?`-suffixed haplotype
   labels. Distinct label, dropped, or counted with a caveat? Whatever is chosen must be a
   validator-level, documented rule.
3. **Q3 — Rarity-flag semantics.** Configurable threshold on frequency, on carrier count, or
   both; default value; whether missingness affects the denominator (frequency among
   genotyped animals vs. all animals — the `.markerAlleleFrequencyTable` precedent uses
   genotyped-only).
4. **Q4 — Affected-animal reporting shape.** Per-rare-haplotype carrier list vs. per-animal
   flag column; interaction with the first-column-identity conventions of the marker family.
5. **Q5 — Export gating.** A per-haplotype carrier list is an identifying table; presumably
   routes through the #150 curator-controlled gate like #152 D7 / #153 D9 — confirm, and
   write the tab-specific warning text.
6. **Q6 — Descriptive-only caveat.** The issue demands "descriptive haplotype reporting, not
   a replacement for pedigree/genome-uniqueness metrics" — follow the persistent
   (non-dismissable) caveat precedent (`.linkageLdBlockCaveatText`,
   `R/modMarkerGenetics.R:15-21`).
7. **Q7 — Surface placement.** A new opt-in tab inside `modMarkerGenetics` (the #152/#153
   choice) vs. anything else; #153 D6's "zero changes to the existing tabs" constraint
   presumably carries over.
8. **Q8 — Slice decomposition.** Expected shape (subject to the plan): validator + fixtures
   slice; statistics slice (counts/frequencies/missingness/rarity); UI + affected-animal +
   export slice. Each slice one session, strict TDD, `AskUserQuestion`-gated phases.

**Hard constraints carried into the plan regardless of Q answers:**
`checkMarkerGenotypeFile()`'s biallelic gate is untouchable (KING-robust correctness for all
existing callers); bare "haplotype" vocabulary is #148's to use, "block" remains #153's; no
MHC inference from arbitrary locus names, ever.

## 5. Next actions

1. **Next #148 session:** write `docs/planning/issue148-mhc-haplotype-reporting-plan.md`
   answering Q1–Q8 as ratified, numbered decisions with a vertical-slice list and per-slice
   completion criteria (the #152/#153 mold). That session is a planning session: the plan is
   the deliverable; close out without implementing (SESSION_RUNNER FM #18/#19).
2. **Implementation sessions:** one slice per session, strict TDD, only after the plan is
   ratified.
3. This session (S703) comments the narrowing onto issue #148 and updates `BACKLOG.md`
   (the batch narrative's "#148 remains unstarted, still needing its scope-narrowing
   conversation" line, plus a new Up Next item for the design-plan session).
