# Issue #147 Plan — Likelihood-Based Candidate-Parent Assignment After Marker Parentage Exclusion

**Status:** RATIFIED (2026-08-09, this session). All four judgment-call decisions (Q1-Q4) were ratified via a single `AskUserQuestion` round; the owner selected this document's own recommended option in all four cases, with no changes requested. See §11 for the recorded outcome. This plan is ready for Slice 1 implementation in a future session.
**Session:** S495 (2026-08-09)
**Origin:** GitHub issue #147, Tier 1 ("High-Priority Design Launch") of the `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` — the batch's sole High-priority item, named there as needing "a Pre-RED design/scoping session (statistical method choice, reference-population choice for allele frequencies, report-only vs. write-back architecture)... not a single-session build, mirroring issue #130's own dedicated-planning-session precedent." This document is that session.
**Touches (planned, future sessions):** `R/markerParentageLikelihood.R` (new), `R/markerAlleleFrequency.R` (new, internal helper), `R/markerParentageExclusion.R` (behavior-preserving extract-method refactor only — see D7), `R/modMarkerGenetics.R` (new tab, Slice 2, pending Q4), `tests/testthat/test_markerParentageLikelihood.R` (new), `tests/testthat/test_markerParentageExclusion.R` (regression tests pinning the D7 refactor's behavior-preservation), `tests/testthat/test_modMarkerGenetics.R` (Slice 2), `inst/extdata/examples/` (new fixture including a related-candidate scenario, per §7 Dragon 3), `NEWS.Rmd`, `inst/extdata/ui_guidance/population_genetics_terms.html`, `vignettes/articles/colony-manager-guide.qmd` and/or `vignettes/manual_components/*.Rmd` (Slice 2).
**Does NOT touch:** `R/getPotentialParents.R` (consumed as-is — its demographic/age/sex/gestation filter is reused unmodified as the default candidate source, §2.1); `R/markerKinship.R`, `R/markerFst.R`, `R/markerHeterozygosity.R` (each has its own private, embedded allele-frequency/opposite-homozygote logic; none is touched — a new, independent helper is added instead, D9, to keep blast radius small; the duplication across these three plus the new function is flagged as a future refactor opportunity, §7 Dragon 9, not fixed here per the Refactor Heuristics' "not during feature implementation" rule); `R/columnSchema.R` and the five files in its family (no new pedigree column — this feature's output is a standalone report, never merged into the pedigree data frame).
**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` — a new statistical estimator plus a data-flow/architecture decision (report-only vs. write-back), not a `DESIGN_WORKSTREAM.md` visual-layout question, matching the #136/#137 precedent.

> **Scope.** Design (not implement) the statistical method, reference-population choice, and report-vs-write-back architecture for ranking candidate replacement parents after `markerParentageExclusion()` flags a recorded parent as genetically inconsistent — per the issue's own instruction, "Design the statistical method before implementation; retain the existing exclusion check independently."

---

## 1. Context

### 1.1 What issue #147 says (verbatim)

> ## Source
>
> `GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`: parentage assignment after exclusion; also the partial Cervus-like comparison.
>
> `markerParentageExclusion()` can flag a contradictory recorded parent but cannot propose a replacement.
>
> Add a separate, evidence-aware workflow that constructs candidates from pedigree, age/gestation, sex, and genotype constraints; scores and ranks them using a documented multilocus method; reports marker coverage, exclusions, and confidence; distinguishes a flagged record from an assigned replacement; and requires curator review rather than silently rewriting a pedigree.
>
> Design the statistical method before implementation; retain the existing exclusion check independently.

Confirmed verbatim via `gh issue view 147 --json title,body,comments` at this session's Phase 1 (zero comments on the issue).

### 1.2 What is already decided (do not re-litigate)

- **Priority:** #147 is the sole High-priority item across the #146-153 batch (`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` line 59), placed first in that batch's recommended order specifically because it is a Pre-RED design gate, not a ready-to-build feature.
- **Scope boundary named by the issue itself:** (a) candidate construction from "pedigree, age/gestation, sex, and genotype constraints"; (b) a "documented multilocus method" for scoring/ranking; (c) reporting "marker coverage, exclusions, and confidence"; (d) "distinguishes a flagged record from an assigned replacement"; (e) "requires curator review rather than silently rewriting a pedigree." All five are addressed in §3 below.
- **`markerParentageExclusion()` stays independent:** the issue explicitly requires retaining it. This document's own D7 (§3) confirms zero change to that function's exported signature, behavior, or documented contract — only an internal, behavior-preserving extract-method refactor, regression-tested.

### 1.3 What this session's research confirmed

This session ran a 4-agent research `Workflow` (three independent literature angles — CERVUS/LOD-score methods; COLONY/sibship-reconstruction methods; captive-primate/colony-specific precedent — plus an adversarial synthesis pass cross-checking all three for contradictions and stress-testing the leading candidate against this package's realistic marker-panel size) and a separate codebase-inventory `Explore` agent (nine numbered items covering `getPotentialParents()`, the allele-frequency internals, the genotype-matrix contract, `modMarkerGenetics.R`'s tab structure, every `pedigree$sire`/`$dam` write site in the package, the `flagged` vocabulary, the biallelic-only enforcement, the citation style, and `modBreedingGroups.R`'s scored-candidate UI precedent). Both are quoted with attribution throughout §2-§3 below; full transcripts are preserved in this session's workflow journal (§10).

**Headline finding:** the field's own answer, independently corroborated by all three research angles and directly validated by a captive-macaque-colony paper this package already cites, is a **CERVUS-style multilocus likelihood-ratio (LOD) score** — not full-pedigree/sibship reconstruction (COLONY/FRANz), which solves a categorically harder and different problem. The adversarial synthesis pass additionally found one **unresolved verification gap** (the genotyping-error-tolerant formula's Appendix has a spotted internal inconsistency and the corrigendum that would settle it was Cloudflare-blocked on every retrieval attempt) and one **quantified stress-test finding specific to this package** (this package's realistic 2-10-locus marker panels sit inside the literature's own documented under-powered zone for confident CERVUS-style assignment, and a full/half sibling of the true parent can plausibly outrank the true parent at small panel sizes). Both are load-bearing for §3's design decisions and are not glossed over.

---

## 2. Evidence-based inventory

### 2.1 `getPotentialParents()` — the existing demographic candidate filter, reused unmodified

`R/getPotentialParents.R:64-67` — signature: `getPotentialParents(ped, minSireAge = NULL, minDamAge = NULL, minParentAge = lifecycle::deprecated(), maxGestationalPeriod = NULL, gestationTable = NULL)`.

Confirmed filtering pipeline (full read, `:87-199`): drops animals with no birth record; requires a `fromCenter` column; strips auto-generated ids; applies a per-species/sex breeding-age floor (`resolveBreedingAge()`); restricts focal animals to in-colony records missing ≥1 parent; applies a per-species gestation window (`getSpeciesGestation()`); splits candidates by sex with an asymmetric presence test (sires: alive/present at conception; dams: alive/present at birth); excludes dam candidates who gave birth to another offspring within one gestation window of the focal birth; prefers "proven breeders" (a birth within ±1.5 years but outside ±0.5 years of the focal birth) before falling back to all age-eligible females.

**No relatedness/kinship exclusion of any kind exists in this filter** — confirmed by `grep -n "likelihood" R/getPotentialParents.R` (zero hits) and by direct read: only age, sex, presence-date, and one-offspring-at-a-time gestation-window logic gate candidates. This is exactly why §7's stress-test-derived Dragon 3 (a full/half sibling of the true parent can be demographically eligible and can outrank it at small panel sizes) is not a hypothetical edge case for this package — `getPotentialParents()`'s candidate lists routinely include relatives in a multi-generation captive colony.

**Return shape:** a plain list of `list(id=, sires=, dams=)`, unranked character-vector candidate ids, no score. This is the function this design reuses as the *default* candidate source (§3 D8's interface), unmodified.

### 2.2 Allele-frequency computation — embedded three times, no reusable helper

`markerExpectedHeterozygosity()` (`R/markerHeterozygosity.R:98-108`) computes per-locus allele frequencies inline inside an anonymous `vapply` closure:
```r
col <- genotypeMatrix[, locus]; col <- col[!is.na(col)]
alleleCalls <- unlist(strsplit(col, "/", fixed = TRUE))
freqs <- table(alleleCalls) / length(alleleCalls)
```
`freqs` is discarded immediately — only the derived `He = 1 - Σp²` scalar survives. `R/markerFst.R:149-156` reimplements the identical `strsplit(..., "/", fixed=TRUE)` + ratio idiom independently for its own per-locus allele-A frequency. `markerKinship()` (`R/markerKinship.R:68-73`) does the same `strsplit` step for its own opposite-homozygote (IBS0) detection. **Three separate call sites, three independent reimplementations of the same "parse alleles out of the `lo/hi` genotype string" step — no shared, exported, or even internal reusable helper exists.** A fourth reimplementation (this design's own LOD function) would extend that pattern; §3 D9 instead adds one new, independent, non-exported helper rather than fork a fourth copy or touch three already-shipped, already-tested files' internals.

A differently-shaped helper, `alleleFreq()` (`R/alleleFreq.R:26-34`), exists but operates on the legacy single-locus STR simulation format (`alleles`/`ids` vectors used by gene-drop machinery) — not the `genotypeMatrix` shape this design needs, and not callable without an adapter.

### 2.3 The genotype matrix contract — confirmed zero-adapter reuse

`buildMarkerGenotypeMatrix()` (`R/buildMarkerGenotypeMatrix.R:38-52`): rows = individual `id` (first-appearance order), columns = `locus` (first-appearance order), cells = a character string `"lo/hi"` (two alleles, alphabetically sorted, joined by `/`), `NA_character_` where ungenotyped. `markerKinship()`, `markerParentageExclusion()`, `markerHeterozygosity.R`'s two functions, and `markerFst()` all consume this exact shape with zero adapter. This design's new function consumes the identical shape — package-wide convention, no new contract introduced.

### 2.4 `markerParentageExclusion()`'s existing opposite-homozygote logic — the reuse target for D7

`R/markerParentageExclusion.R:100-160`: per (offspring, recorded-parent, role) triple, counts loci where both are homozygous for *different* alleles (`isHet()` helper, `:109-113`; core comparison, `:143-145`); flags when `exclusionCount > maxExclusions` (default `2L`, i.e. flag at 3+, citing Cifuentes et al. 2006 and de Groot et al. 2025). This operates only against the pedigree's **recorded** parent — there is no parameterization to run the identical comparison against an arbitrary **candidate** parent. §3 D7 extracts this comparison into a small internal helper both functions call, rather than forking a second, independently-written comparison routine (a risk the research explicitly flagged, §7 Dragon 10 below).

### 2.5 Zero existing pedigree-mutation precedent — issue #147's write-back question is genuinely greenfield

Full grep sweep (`pedigree\$sire\s*<-|pedigree\$dam\s*<-` and broader `\$sire\[.*<-|\$dam\[.*<-` variants across `R/`) found **zero** hits against a variable literally named `pedigree`, and every hit against `ped`/`pedB`/`addToPed`/`a1` is QC/normalization/simulation, never a "record a chosen candidate parent" write: `removeUninformativeFounders.R:52-53` (blanking removed founders), `removeAutoGenIds.R:24-25` (stripping auto-generated ids), `unknown2NA.R:17,20` (normalizing literal "UNKNOWN"), `makeSimPed.R:65,70,77,82` (synthetic test-data generation), `obfuscatePed.R:32-33` (anonymization aliasing, not assignment), `addIdRecords.R:38-39`/`addParents.R:48-49,56-57`/`getPedDirectRelatives.R:69-70` (placeholder-row initialization). `resolveCrossCenterIds()` (`R/resolveCrossCenterIds.R:162-163`) rewrites ids for cross-center identity linkage — a curator-confirmed-mapping *pattern* worth citing in spirit, but it is an identity merge, not a parentage decision, and should be read directly (not assumed as a literal template) by whichever session eventually scopes a write-back feature. **No code anywhere in this package writes an algorithmically-computed or curator-chosen candidate id into `pedigree$sire`/`pedigree$dam`.** This is the central fact behind D4's recommendation (§3): a first-ever pedigree-mutation code path is a substantially bigger, separately-gated decision than the ranking feature itself.

### 2.6 The `flagged` vocabulary — reuse the boolean pattern, do not reuse the name for a different concept

`reportGV()`'s `flagged` column (`R/reportGV.R:200`, cited explicitly at `R/markerParentageExclusion.R:67-68` as "the canonical boolean vocabulary") is a plain `TRUE`/`FALSE`, no enum, no pending/accepted/rejected state machine. Grep for review-state vocabulary (`accepted|rejected|pending[_ ]?review|reviewStatus|curatorReview|approv(ed|al)`) across `R/` returns zero relevant hits — **no accepted/rejected/pending-review status field exists anywhere in the package.** This design's own output needs two conceptually distinct booleans per candidate row — "this candidate is Mendelian-excluded" and "this candidate's score rests on too few shared loci to trust" — and must NOT overload the single word `flagged` for both, or collide it with `markerParentageExclusion()`'s own existing `flagged` semantics (a live naming-collision risk this project has hit before with `zygosity`, `docs/planning/issue137-...-plan.md` §2.4). §3 D6/D8 name these `excluded` and `lowPower` instead.

### 2.7 `checkMarkerGenotypeFile()` — biallelic loci are guaranteed downstream

`R/checkMarkerGenotypeFile.R:68-78` hard-`stop()`s on any locus with more than two distinct alleles anywhere in the input ("the KING-robust kinship estimator requires biallelic markers"). Every `genotypeMatrix` reaching this design's function has already passed that gate — **the transmission-probability/Hardy-Weinberg arithmetic in §3 D2 can safely assume exactly two alleles per locus**, no multiallelic branch needed or currently possible downstream of ingestion.

### 2.8 `modMarkerGenetics.R` — the existing 4-tab pattern, and the one real "scored candidate" UI precedent in the app

Four existing tabs (`R/modMarkerGenetics.R:43-52`), each a **read-only** `DT::DTOutput` backed by one reactive: Kinship Comparison, Heterozygosity, Parentage Exclusion (`exclusion` reactive calling `markerParentageExclusion(gmat, ped)` at `:206`), Cross-Center. None has any `actionButton`, row-selection, or accept/reject affordance — zero precedent in this module for a curator-driven selection UI.

The one real precedent for "scored candidates + a selection mechanism a curator drives" lives elsewhere: `R/modBreedingGroups.R` (issue #125). Up to 5 whole-solution candidates, each carrying a numeric `score` (`:418-436`); a `selectInput` dropdown whose choices bake the score directly into the visible label (`"Candidate 1 (score 7)"`, `:467-477`); a plain `renderTable` comparison table showing all scores side by side (`:499-509`); the curator's dropdown choice drives every downstream reactive. This is a **selection among a handful of whole-solution candidates**, not a per-row pick-one-of-N-parents table — the pattern (score-labeled control + comparison table) is the reusable precedent, not the code itself. §3 D10/§11 Q4 weighs this against the simpler 4-tab read-only pattern.

### 2.9 Citation style precedent

`R/markerFst.R:100-106` and `R/markerParentageExclusion.R:73-82` both follow: `@references` tag, one citation per entry (`Author, A. B., ... (Year). Title, sentence case. \emph{Journal Name}, volume(issue), pages. \doi{10.xxxx/...}`), blank `#'` line between multiple citations, journal name in `\emph{}`, DOI always via `\doi{}`, never a bare URL — plus a substantial `@details` block arguing *why* this estimator was chosen over named alternatives. §3's design decisions below, and any implementing session's roxygen, should match this exactly.

---

## 3. Design decisions

Ten decisions, D1-D10. Each states whether it is forced by the evidence above or a genuine judgment call; §11 collects the judgment calls into a ratification round.

**D1 — Method family: CERVUS-style multilocus likelihood-ratio (LOD) "categorical allocation" scoring, not full-pedigree/sibship reconstruction (COLONY/FRANz). Forced by problem-shape, corroborated independently by all three research angles.**

Issue #147's actual problem — rank a short, already demographically-filtered candidate list (§2.1) against ONE flagged pedigree slot, inside an otherwise fully-known pedigree — is categorically narrower than what COLONY (Wang 2004) or FRANz (Riester, Stadler & Klemm 2009) solve: joint reconstruction of unknown sibship/pedigree structure across an entire unsampled or partially-sampled cohort, via combinatorial partition search (simulated annealing/MCMC) layered with EM-style allele-frequency refinement. The research angle dedicated to this comparison concluded plainly: "Full-pedigree/sibship reconstruction... is not competitive for this scope — solves a different, harder problem at disproportionate implementation cost... none of it a base-R-proportionate build," and this package's own `no-new-hard-dependency` constraint (established by `markerFst()`'s own Pre-RED precedent) rules it out independent of accuracy considerations. CERVUS-style categorical allocation (Meagher & Thompson 1986; operationalized by Marshall, Slate, Kruuk & Pemberton 1998) is the field's own answer to exactly #147's problem shape, and is independently validated as the captive-primate-colony domain's de facto standard by de Groot et al. (2025) — already cited in this package's `markerParentageExclusion()` — which used CERVUS on a real captive macaque colony (§2.9's Q2 finding: "I did not find a distinct 'primate-colony parentage assignment industry standard' that differs from the general wildlife-genetics CERVUS/COLONY toolset — the domain borrows the general method rather than having invented its own").

**D2 — LOD formula: implement the no-genotyping-error base formula in v1; the genotyping-error-tolerant extension is explicitly out of this plan's implementation scope, pending independent re-verification. Judgment call on scope; the underlying evidence gap is forced. Requires ratification (§11 Q1).**

The formula, corroborated with no contradiction across all three research reports:

```
LOD = Σ_loci  ln[ T(g_offspring | g_candidate [, g_other_known_parent]) / T(g_offspring | H2: candidate unrelated, population allele frequencies) ]
```

— a per-locus Mendelian transmission-probability ratio (H1: candidate is the true parent, vs. H2: candidate is an unrelated individual drawn at random from the reference population), summed as logs across loci genotyped in both the offspring and the candidate. `T(·)` uses ordinary Mendelian/Punnett-square transmission probabilities; `P(·)` (Hardy-Weinberg genotype frequencies from population allele frequencies) is well-defined because §2.7 guarantees exactly two alleles per locus. **When the offspring's other recorded parent is genotyped and not itself flagged/excluded, it is incorporated as a known second parent (a trio likelihood, matching Marshall et al. 1998's own formula, which explicitly conditions on a known mother when scoring candidate fathers); otherwise the function falls back to a candidate-only (dyad) likelihood.** This conditioning rule is automatic, internal behavior — not a user-facing parameter — forced directly by the literature's own formula shape.

This no-error-model formula is the one part of the entire formula corpus **all three independent research reports converge on with zero internal inconsistency found by any of them.** The genotyping-error-tolerant extension (Kalinowski, Taper & Marshall 2007, eqns 1-3) is the more realistic long-run target — microsatellite genotyping error is real, and de Groot et al. (2025) works with exactly this kind of data — but the research explicitly flagged an internal inconsistency in the 2007 paper's own Appendix (an exponent pattern break in the simplified special-case forms) and could not retrieve the 2010 corrigendum (Kalinowski, Taper & Marshall, *Mol. Ecol.* 19:1512) that would resolve it — every retrieval route was Cloudflare-blocked. This is exactly the situation this project's own house rule exists for: a prior session shipped a formula 40% off under a mis-attributed citation before an adversarial check caught it (`markerFst()`'s own Pre-RED history). §11 Q1 asks whether to (a) ship the verified no-error formula now and scope the error-tolerant extension as a separate, later, independently-re-verified slice — this document's recommendation — or (b) block all implementation until the error-tolerant formula is independently re-verified, or (c) treat the error-tolerant extension as permanently out of scope (this package tracks no genotyping-error-rate parameter anywhere today, so a fixed default would itself need sourcing).

**D3 — Reference population for allele frequencies: colony-wide, computed from whatever subset of the genotype matrix is passed in. Forced by direct captive-colony precedent plus reuse discipline.**

de Groot et al. (2025) — already cited in this package — used colony-wide allele frequencies computed from their own captive cohort via CERVUS's built-in module, not an external/wild-type reference population; this is a direct, on-point precedent for a colony-management package. Colony-wide computation also lets this design reuse the *shape* of computation `markerExpectedHeterozygosity()`/`markerObservedHeterozygosity()` already perform (§2.2) rather than invent a second, independently-fabricatable frequency estimator. **Known limitation, documented rather than silently absorbed:** captive colony pedigrees are commonly structured/inbred, which violates the Hardy-Weinberg assumption underlying `P(g)` and biases the H2 null; a future per-subpopulation (per-center) frequency refinement is reasonable follow-on work, not a v1 requirement.

**D4 — Report-only architecture: this issue ships a ranked-candidate-table function with zero code path that writes `pedigree$sire`/`pedigree$dam`. Judgment call, but strongly evidenced. Requires ratification (§11 Q3) given its stakes.**

§2.5 established this package has **zero** existing pedigree-mutation precedent of any kind — introducing the first-ever such code path is a substantially bigger, higher-blast-radius architectural decision than the statistical-ranking feature itself, and bundling "give the curator information" with "let the curator commit a change to ground truth" in one issue mixes a statistics-correctness review with a data-integrity/mutation-safety review that this project's own vertical-slice/one-deliverable discipline argues against combining. A report-only function trivially and directly satisfies the issue's own explicit requirement ("requires curator review rather than silently rewriting a pedigree," "distinguishes a flagged record from an assigned replacement" — a function that cannot write cannot silently rewrite). If a curator-confirmed write-back is wanted later, it should be its own explicit, separately-gated follow-on issue with its own Pre-RED scope discussion, informed by (but not assumed identical to) `resolveCrossCenterIds()`'s curator-confirmed pattern.

**D5 — No simulation-calibrated percentage confidence in v1; report raw LOD + Δ (gap to the next-best candidate) + per-candidate `nLociUsed`, explicitly labeled as an uncalibrated relative-ranking signal. Forced by disproportionate cost plus the adversarial stress-test's overconfidence finding.**

CERVUS's own confidence statistic (Δ, calibrated against simulation-derived critical values from ~100,000 Monte Carlo true/false parent-offspring simulations per parameter set) is explicitly separable from the LOD score itself and is a materially larger, independent engineering investment — not proportionate to a "propose ranked candidates for curator review" scope. More importantly, the adversarial synthesis pass stress-tested this package's *specific* realistic panel size against the literature's own numbers and found this package's stated realistic range (2-10 loci) sits **entirely inside the zone both Kalinowski et al. (2007) and Harrison et al. (2013) independently characterize as underpowered** for confident CERVUS-style assignment (73% confident assignment at 6 loci even with the corrected formula; CERVUS-family methods measurably less accurate than full-probability sibship methods in Harrison et al.'s independent 60-scenario comparison). Presenting a simulation-calibrated percentage confidence at this package's realistic panel sizes would overstate certainty the underlying data does not support. Reporting raw LOD + Δ + coverage, explicitly labeled uncalibrated, directly satisfies the issue's own "reports marker coverage, exclusions, and confidence" requirement without that overstatement risk.

**D6 — Minimum-loci gate: a distinct `lowPower` boolean per candidate row (not silent ranking) when `nLociUsed` falls below a threshold. Mechanism forced to exist; the exact threshold/mechanism is a genuine judgment call. Requires ratification (§11 Q2).**

The adversarial stress test found that at 1-2 informative loci, ranking is "not just weak — it can be actively misleading": an unrelated candidate sharing common alleles by chance can post a LOD comparable to or higher than the true parent's. The design must not present a 1-2-locus ranking as if it carries assignment-grade meaning — some explicit low-power signal, separate from a merely low-but-computed score, is required by the issue's own "reports... confidence" language read honestly. The research explicitly could not settle an exact numeric threshold from the literature ("exact threshold not settled by the reviewed literature"). §11 Q2 offers three mechanisms: a fixed, literature-informed, user-overridable default (mirroring `markerParentageExclusion()`'s own `maxExclusions = 2L` precedent — a documented heuristic, not a mathematically-derived cutoff); no fixed gate at all (rely entirely on transparent `nLociUsed`/`delta` reporting); or a data-driven panel-specific power computation (heavier implementation lift, a plausible future refinement rather than a v1 requirement).

**D7 — Extract `markerParentageExclusion()`'s opposite-homozygote comparison into a small internal helper both it and the new function call; zero change to `markerParentageExclusion()`'s exported signature, behavior, or documented contract. Forced by the reuse-discipline finding below; behavior-preservation is verified by a required regression test.**

The adversarial synthesis pass flagged this explicitly as a dragon (§7 #10): "Do not fork a second Mendelian-inconsistency counter... reuse/generalize `markerParentageExclusion()`'s existing opposite-homozygote logic... rather than a second, independently written comparison routine — a duplication/divergence risk RED tests should guard against directly." The new function's per-candidate `excluded` diagnostic column (§3 D8) needs the identical comparison `markerParentageExclusion()` already implements (`R/markerParentageExclusion.R:143-145`), just parameterized against a candidate rather than the recorded parent. Extracting a small internal (`.`-prefixed, non-exported) helper both functions call is a behavior-preserving refactor — the issue's own "retain the existing exclusion check independently" requirement is read as preserving `markerParentageExclusion()`'s **exported interface, behavior, and independence as a distinct check**, not as forbidding an internal, verified, no-behavior-change extraction. A required Slice 1 deliverable is a regression test proving `markerParentageExclusion()`'s existing test suite output is byte-identical before and after the extraction.

**D8 — New function `markerParentageLikelihood()`, auto-detecting flagged (offspring, role) pairs from `markerParentageExclusion()`'s own output by default, with an override for ad hoc single-slot scoring. Judgment call on the exact interface shape; the naming-family match is forced.**

Proposed signature (matching this package's `marker*` naming family — `markerKinship`, `markerFst`, `markerParentageExclusion`, `markerObservedHeterozygosity`/`markerExpectedHeterozygosity` — and deliberately named as `markerParentageExclusion()`'s companion, per the issue's own "retain... independently" framing):

```r
markerParentageLikelihood(genotypeMatrix, pedigree, id = NULL, role = NULL,
                           candidates = NULL, minLoci = <TBD, §11 Q2>,
                           maxExclusions = 2L)
```

- `id`/`role` default `NULL`: auto-detects every (offspring, role) pair `markerParentageExclusion(genotypeMatrix, pedigree, maxExclusions)` flags, and ranks candidates for each — directly matching the issue's own framing ("a separate, evidence-aware workflow" operating on the exclusion result, not a tool the curator must manually target). Supplying `id`/`role` explicitly scores one slot on demand (useful for a curator's proactive check on an animal that isn't (yet) flagged).
- `candidates` defaults to `getPotentialParents(pedigree)`'s corresponding `sires`/`dams` list for that `id` (§2.1, reused unmodified); an explicit override lets a curator supply a narrower or hand-picked list.
- **Return:** one row per (offspring `id`, `role`, `candidateId`): `LOD`, `delta` (gap to the next-best candidate within the same (id, role) group; `NA` for a sole candidate), `nLociUsed`, `excluded` (the D7-shared opposite-homozygote diagnostic, parameterized against this candidate — distinct from and never overloading `markerParentageExclusion()`'s own `flagged` column, §2.6), `lowPower` (`nLociUsed` below the D6/§11-Q2 threshold), ranked by `LOD` descending within each (id, role) group. Two distinctly-named booleans, never a single overloaded `flagged`, per §2.6's confirmed collision risk.
- **Contract, tested directly (not just documented):** the function's own test suite includes a RED-phase assertion that its `pedigree` input is returned/observed byte-identical after the call — enforcing D4's report-only architecture as a checked contract, not merely a description (§7 Dragon 12).

**D9 — Allele-frequency helper: one new, non-exported function in a new file (`R/markerAlleleFrequency.R`), not an extraction from `markerHeterozygosity.R`/`markerFst.R`'s existing internals. Judgment call on blast radius, resolved in favor of the smaller change.**

§2.2 found three independent, private reimplementations of the same "parse alleles, compute per-locus frequency table" step. Extracting a fourth, *shared* implementation touching all three existing files would be the more thorough DRY fix, but it means modifying three already-shipped, already-tested statistical functions' internals as a side effect of an unrelated feature — exactly the kind of scope-creep `SAFEGUARDS.md`'s Two-Mode Problem and this project's Refactor Heuristics warn against mid-feature ("spotting a shallow module mid-feature is a Mode-Switch trigger... commit the feature, note the heuristic finding for a future architecture session, do not refactor inline"). This design instead adds one new, small, independent, non-exported helper that only the new `markerParentageLikelihood()` calls; the three-way (soon four-way) duplication is flagged as a future refactor opportunity (§7 Dragon 9), not fixed here.

**D10 — UI integration: if a UI ships at all, it belongs as a new surface in `modMarkerGenetics.R`. Exact shape (read-only tab vs. deferred entirely vs. a scored-selection pattern) is a genuine judgment call. Requires ratification (§11 Q4).**

Given D4's report-only architecture, there is no confirm/apply action for a UI to wire up — only display. If a UI ships, `modMarkerGenetics.R`'s own existing 4-tab, read-only `DT::DTOutput` pattern (§2.8) is the natural fit, requiring no new interaction idiom. `modBreedingGroups.R`'s scored-selection pattern (§2.8) was built for a different interaction shape — selecting among a handful of whole-solution candidates with a downstream consequence for every other reactive in that module — and adapting it here would add UI complexity with no corresponding behavioral need, since D4 means there is nothing for a selection to *do*. §11 Q4 also weighs deferring all UI to a separate, later issue entirely, matching `resolveCrossCenterIds()`'s own Slice-4 precedent (Session 446: script-callable only, no UI change that session).

---

## 4. Interface catalog

| Interface | Input | Output | Error contract | Consumers |
|---|---|---|---|---|
| `markerParentageLikelihood()` (new, exported) | `genotypeMatrix` (standard shape, §2.3), `pedigree` (standard `id`/`sire`/`dam`/`sex`/`gen` shape), optional `id`/`role`/`candidates`/`minLoci`/`maxExclusions` | One row per (offspring, role, candidateId): `id`, `role`, `candidateId`, `LOD`, `delta`, `nLociUsed`, `excluded`, `lowPower` — ranked descending by `LOD` within each (id, role) group; a zero-row frame (full column shape) when nothing is checkable | Errors loudly (not silently) on a malformed `genotypeMatrix`/`pedigree` shape, matching `markerParentageExclusion()`'s own precedent; a candidate/offspring pair sharing zero genotyped loci is reported with `nLociUsed = 0L`, `lowPower = TRUE`, `LOD = NA_real_` (never silently dropped, matching the issue's own "reports marker coverage" requirement) | `R/modMarkerGenetics.R` (Slice 2, pending §11 Q4); script-callable directly, matching `resolveCrossCenterIds()`'s own script-only precedent |
| `.markerAlleleFrequencyTable()` (new, internal) | `genotypeMatrix`, a `locus` name | Named numeric vector, allele → frequency, computed from non-`NA` cells only | N/A (internal) | `markerParentageLikelihood()` only |
| `.markerOppositeHomozygoteCount()` (D7, new, internal, extracted) | two genotype-string vectors (same shape `markerParentageExclusion()` already indexes) | integer exclusion count + the loci-compared count | N/A (internal) | `markerParentageExclusion()` (unchanged behavior) and `markerParentageLikelihood()` |

---

## 5. Implementation plan — vertical slices (one session each)

```
Slice 1 (core statistical function: markerParentageLikelihood(), allele-frequency helper,
         D7 extraction + regression test, no-error LOD formula, minLoci gate, report-only contract test)
  `-- Slice 2 (UI: read-only tab in modMarkerGenetics.R, citation/NEWS.Rmd/tutorial-article documentation)
```

### Slice 1 — Core statistical function

**Scope:** `R/markerParentageLikelihood.R` (new, exported, D8's signature); `R/markerAlleleFrequency.R` (new, internal, D9); the D7 extract-method refactor of `R/markerParentageExclusion.R`'s opposite-homozygote comparison into a shared internal helper, with a regression test proving `markerParentageExclusion()`'s own behavior is byte-identical before/after. No-genotyping-error LOD formula only (D2, per §11 Q1's ratified outcome). `minLoci` fixed default per §11 Q2's ratified outcome. Script-callable only — no Shiny UI.

**What does NOT change:** `markerParentageExclusion()`'s exported signature or documented behavior (D7); `getPotentialParents()` (consumed as-is, §2.1); `markerKinship.R`/`markerFst.R`/`markerHeterozygosity.R` (D9 — their own private allele-frequency logic is untouched); `R/modMarkerGenetics.R` (Slice 2).

**Files to touch:**
- `R/markerParentageLikelihood.R` (new) — the core function, D2/D8.
- `R/markerAlleleFrequency.R` (new) — `.markerAlleleFrequencyTable()`, D9.
- `R/markerParentageExclusion.R` — extract `.markerOppositeHomozygoteCount()` (D7); zero behavior change to the exported function.
- `tests/testthat/test_markerParentageLikelihood.R` (new) — LOD formula correctness (hand-verified fixture, matching `markerFst()`'s own precedent of a hand-computed check before trusting the implementation); trio-vs-dyad conditioning (D2); `nLociUsed`/`delta`/`excluded`/`lowPower` column correctness; the report-only "does not mutate its pedigree input" contract test (D8, §7 Dragon 12); the related-candidate scenario (§7 Dragon 3) — a demographically-eligible full/half sibling of the true parent must appear in the ranked output, not be silently excluded, even where it scores competitively.
- `tests/testthat/test_markerParentageExclusion.R` — new regression tests pinning D7's behavior-preservation (existing test assertions must still pass unchanged; a direct before/after comparison of `markerParentageExclusion()`'s own output on its existing fixtures).
- `inst/extdata/examples/` — a new fixture including at least one flagged (offspring, role) pair, a related-candidate scenario (§7 Dragon 3), and a low-loci-coverage candidate (to exercise `lowPower`).

**RED:** all unit tests above, written against functions/helpers that don't exist yet or (for the exclusion regression tests) against the not-yet-extracted helper; confirm failures are genuinely "could not find function" / assertion mismatches, not setup/typo errors.

**GREEN:** implement exactly enough to pass — the LOD function, the allele-frequency helper, the D7 extraction. No UI, no documentation beyond roxygen (Slice 2).

**DONE looks like:** `markerParentageLikelihood()` correctly auto-detects flagged pairs and ranks candidates by LOD; a hand-verified fixture's LOD values match a manually-computed check (mirroring `markerFst()`'s own Pre-RED verification discipline); the related-candidate scenario is observed at least once (§7 Dragon 3 — not merely predicted); the report-only contract test passes; `markerParentageExclusion()`'s existing test suite passes unchanged after the D7 extraction; `devtools::check()` 0 errors/0 warnings; full clean regression read shows no new failures.

**Verify:** targeted test file runs (both new/changed files); full clean regression read; full `devtools::check()`; `lintr::lint_package()` on touched files.

**Session boundary:** one session. Close out when Slice 1's DONE criteria are met. Slice 2 is a separate future session.

### Slice 2 — UI, citation, and documentation

**Scope:** a 5th, read-only "Candidate Parent Assignment" tab in `R/modMarkerGenetics.R` (D10, §11 Q4's ratified outcome), matching the existing 4-tab `DT::DTOutput` pattern exactly — a new reactive calling `markerParentageLikelihood()` against the module's already-wired `genotypeMatrix`/`pedigree` reactives (§2.8, no new file input needed). Citation checklist (`inst/extdata/ui_guidance/population_genetics_terms.html`), NEWS.Rmd entry, and tutorial/article documentation (`vignettes/articles/colony-manager-guide.qmd` and/or the matching `vignettes/manual_components/*.Rmd` component), all in the same session.

**What does NOT change:** `markerParentageLikelihood()`'s own signature or behavior (Slice 1 is complete and stable before Slice 2 begins); the existing 4 tabs' behavior.

**Files to touch:**
- `R/modMarkerGenetics.R` — new tab, new reactive.
- `tests/testthat/test_modMarkerGenetics.R` — new tab renders; reactive calls `markerParentageLikelihood()` correctly; absent flagged pairs renders an empty-but-valid table (not an error).
- `inst/extdata/ui_guidance/population_genetics_terms.html` — LOD/Δ/marker-coverage explained in user-facing terms (citation checklist, issue #120).
- `NEWS.Rmd` → re-rendered `NEWS.md`.
- `vignettes/articles/colony-manager-guide.qmd` and/or `vignettes/manual_components/*.Rmd`.

**DONE looks like:** the new tab renders a ranked candidate table for every flagged (offspring, role) pair in a live pedigree + genotype file, with `LOD`/`delta`/`nLociUsed`/`excluded`/`lowPower` all visible; a live `shinytest2`/`chromote` smoke test confirms real, correctly-computed values (byte-exact match to a hand-verified fixture, matching this project's established Marker Genetics precedent) with zero console errors; citation/NEWS.Rmd/tutorial-article documentation all present in the same session's close-out; `gh issue close 147` in this session, citing the `CHANGELOG.md` entry.

**Verify:** targeted test file runs; full clean regression read; full `devtools::check()`; live `shinytest2`/`chromote` E2E smoke test; `lintr::lint_package()` on touched files.

**Session boundary:** one session, separate from Slice 1.

---

## 6. Impact analysis

**Blast radius is small and additive for the statistical core (Slice 1); Slice 2's UI addition is the larger surface.** No existing exported function's signature or documented behavior changes — `markerParentageExclusion()`'s D7 refactor is internal-only and regression-tested; `getPotentialParents()` is consumed, not modified. The new function and its one new internal helper file are pure additions.

**Performance:** candidate lists from `getPotentialParents()` are typically short (a handful of demographically-eligible animals per flagged slot); the LOD computation itself is closed-form, no iteration/optimization — no performance concern identified.

**Backward compatibility:** trivially preserved — nothing existing changes shape or behavior except the D7 internal refactor, which Slice 1's own regression test must prove byte-identical.

**Close-out checklists triggered** (`CLAUDE.md`): citation checklist (#120) applies at Slice 1 (new roxygen `@references`, matching §2.9's style) and again at Slice 2 (`population_genetics_terms.html`); NEWS.Rmd entry required at Slice 1 (new exported function) and Slice 2 (new UI control); tutorial/article documentation checklist applies at Slice 2; `a2interactive.Rmd` checklist is deferred per its own standing rule; lint on touched files each slice; a `CHANGELOG.md` `[issue #147]`-tagged entry each slice; `gh issue close 147` at Slice 2's close-out.

---

## 7. Here be dragons

Carried forward, largely verbatim, from the adversarial synthesis pass's own dragon-flagging (its findings are reproduced here rather than re-derived, since re-deriving them would risk losing precision):

1. **Small panels (2-10 loci) sit inside the literature's own documented underpowered zone.** Kalinowski et al. (2007): 73% confident assignment at 6 loci even post-correction (51% pre-correction). Harrison et al. (2013): 89.0% ± 11.3% SD accuracy for CERVUS-family LOD methods vs. 98.4% ± 4.0% for full-probability sibship methods, worse at low loci + low allelic diversity. D5 (no percentage confidence, raw LOD+Δ+coverage instead) is the design's direct answer; the implementing session must not soften this into a percentage-confidence claim later without re-opening D5.
2. **1-2 informative loci can produce a ranking that is statistically meaningless, not just low-confidence.** D6's `lowPower` gate exists specifically for this; §11 Q2 has settled its default mechanism (a fixed, literature-informed, user-overridable `minLoci`) — Slice 1's RED tests must exercise it directly.
3. **Related candidates (full/half sibs of the true parent) can outrank the true parent, and this risk grows as locus count shrinks.** `getPotentialParents()` (§2.1) applies zero relatedness filtering, and eligible relatives are routine, not edge-case, in a multi-generation captive colony. Slice 1's fixture (per the "Touches" list) must include at least one scenario where a demographically-eligible relative of the true parent is also a genotyped candidate, so this behavior is observed at least once, not merely predicted.
4. **De Groot et al. (2025)'s captive-macaque validation used 23 STR loci** — well above this package's realistic panel size; its own LOD range (13.30-49.75) validates the *method*, not *expected performance at this package's scale*. Do not cite those numbers as a benchmark in this feature's own roxygen/UI text.
5. **Uneven per-candidate marker coverage is a comparability problem, not cosmetic.** `nLociUsed` must sit directly next to `LOD` in every output row (already reflected in D8's return shape) — never a separate diagnostic a curator could overlook.
6. **Colony-wide allele frequencies likely violate Hardy-Weinberg equilibrium** given typical pedigree structure/inbreeding, biasing the H2 null the LOD depends on. A documented limitation (D3), not a solvable v1 defect.
7. **The genotyping-error-tolerant formula (Kalinowski et al. 2007, eqns 1-2) is NOT independently re-verified by this session's research** — a spotted internal inconsistency in the paper's own Appendix, and the 2010 corrigendum that would resolve it could not be retrieved (Cloudflare-blocked on every route tried this session). Any future session implementing the error-tolerant extension MUST independently re-verify eqn 1-2 against the primary PDF directly (not this document's or the research agent's transcription) before it reaches code or roxygen citations — this is exactly the failure class this project's prior wrong-formula incident (`markerFst()`'s own Pre-RED history) warns against.
8. **Ties are plausible at small panel sizes** — near-identical or exact LOD ties among top candidates must be surfaced explicitly (list all tied candidates in the ranked output), never silently broken by row order.
9. **The allele-frequency-computation duplication now spans four sites** (`markerHeterozygosity.R` ×2 logically, `markerFst.R`, and this design's own new helper) with no shared implementation. Flagged for a future, dedicated refactor session (Deletion Test analysis per `ARCHITECTURE_WORKSTREAM.md`'s Refactor Heuristics) — not addressed here, per D9's own blast-radius reasoning.
10. **Do not fork a second Mendelian-inconsistency counter** — D7 resolves this via extraction, but the implementing session's RED tests must include the byte-identical-behavior regression check on `markerParentageExclusion()`, not just new tests for the new function.
11. **No genotyping-error-rate (ε) parameter exists anywhere in this package today.** If/when the D2-deferred error-tolerant extension ships, ε needs an independently-sourced, cited default, must be user-overridable, and its roxygen must state that Δ/confidence-style outputs are sensitive to ε misspecification even though relative rank order is comparatively robust to it (Jones, Small, Paczolt & Ratterman 2010).
12. **D4's report-only architecture must be enforced by an actual absence of a write path, and tested for it** — a RED-phase "does not mutate its pedigree input" contract test (already specified in D8's return-shape note), not merely a documented intention.
13. **This session's captive-primate-precedent research (de Groot et al. 2025's exact LOD-range numbers and quoted phrases) came from an automated full-text fetch/summarization**, not a reviewer's own line-by-line PDF read. Re-confirm against the primary PDF before citing exact figures or quotes in any roxygen/vignette text this feature ships.

---

## 8. Alternatives considered

| Decision | Recommended | Rejected alternative(s) | Why rejected |
|---|---|---|---|
| D1 method family | CERVUS-style categorical-allocation LOD scoring | Full-pedigree/sibship reconstruction (COLONY, Wang 2004; FRANz, Riester et al. 2009) | Solves a different, harder problem (joint reconstruction of unknown structure across an entire cohort); computational core (annealing/MCMC/EM) is disproportionate and not a base-R-proportionate build |
| D3 reference population | Colony-wide, reusing the existing per-locus frequency computation shape | An external/wild-type reference population | No precedent in the captive-colony literature reviewed (de Groot et al. 2025 used colony-wide); would need external data this package has no ingestion path for |
| D3 reference population | Colony-wide | Equal-frequency null assumption | Literature treats this as a fallback only for panels/samples too small for stable frequency estimation, not a preferred default |
| D5 confidence reporting | Raw LOD + Δ + coverage, explicitly uncalibrated | CERVUS's own simulation-calibrated Δ-critical-value percentage confidence | Materially larger, separable engineering investment (~100,000-simulation Monte Carlo runs per parameter set); risks overstating certainty given this package's stress-test-confirmed under-powered realistic panel range |
| D9 allele-frequency helper placement | New, independent, non-exported helper | Extract a shared helper from `markerHeterozygosity.R`/`markerFst.R`'s existing internals | Would modify three already-shipped, already-tested files' internals as a side effect of an unrelated feature — scope creep under this project's own Two-Mode Problem / Refactor Heuristics discipline |
| D10 UI shape | A 5th read-only tab in `modMarkerGenetics.R` | Adapt `modBreedingGroups.R`'s scored-selection pattern | D4's report-only architecture means there is nothing for a selection control to act on; the pattern was built for a different interaction shape (choosing among whole-solution candidates with downstream consequences) |

---

## 9. Close-out checklist mapping

1. **Citation checklist (issue #120)** — applies. Slice 1's roxygen `@references` must cite Meagher & Thompson (1986), Marshall, Slate, Kruuk & Pemberton (1998), and Kalinowski, Taper & Marshall (2007) (the last cited for its correction history even though its error-tolerant formula itself is deferred, D2) in the established citation style (§2.9). Slice 2 additionally updates `inst/extdata/ui_guidance/population_genetics_terms.html`.
2. **Tutorial/article documentation checklist (Session 436)** — applies at Slice 2; `vignettes/articles/colony-manager-guide.qmd` and/or the matching `vignettes/manual_components/*.Rmd` component.
3. **NEWS.Rmd entry checklist (Session 448)** — applies at Slice 1's own close-out (new exported function `markerParentageLikelihood()`), and again at Slice 2 (new UI control).
4. **`a2interactive.Rmd` script-callable-function checklist (Session 450/478)** — deferred, not same-session, per its own standing rule; a future dedicated documentation pass once the feature has stabilized.
5. **GitHub issue close-out checklist** — `gh issue close 147 --reason completed --comment "..."` citing the `CHANGELOG.md` entry and verification evidence, at Slice 2's own close-out (the final planned slice).
6. **Lint close-out checklist** — `lintr::lint_package()` on touched files, each slice.
7. **CHANGELOG.md ledger-format resolution (Session 325)** — each slice's own close-out prepends a dated `### YYYY-MM-DD · [issue #147] ...` entry above `## Legacy history`.

---

## 10. Provenance

This document synthesizes two research inputs gathered in Session S495 (2026-08-09):

1. A 4-agent research `Workflow` — three independent literature-research angles run in parallel (CERVUS/LOD-score exclusion-compatible methods; COLONY/FRANz full-pedigree/sibship-reconstruction methods; captive-primate/captive-colony-specific precedent, including a direct check of what de Groot et al. 2025 — already cited in this package — actually uses), followed by a fourth agent running an adversarial synthesis pass across all three (cross-checking for contradictions/fabrication risk, stress-testing the leading candidate method against this package's own realistic marker-panel size, and answering the three open design questions the sequencing audit named). All four agents' full text is preserved in this run's workflow journal; every citation, formula, and confidence qualifier in §1.3, §3, and §7 above is drawn directly from that output, not re-derived or paraphrased from memory.
2. A codebase-inventory `Explore` agent — nine numbered items covering `getPotentialParents()`, the allele-frequency internals (§2.2), the genotype-matrix contract (§2.3), the exclusion-comparison logic (§2.4), every `pedigree$sire`/`$dam` write site in the package (§2.5, confirming the write-back question is genuinely greenfield), the `flagged` vocabulary (§2.6), the biallelic-loci guarantee (§2.7), `modMarkerGenetics.R`'s tab structure and `modBreedingGroups.R`'s scored-candidate UI precedent (§2.8), and the citation style (§2.9) — each item cites exact file:line evidence, not paraphrase from memory. This session independently spot-checked six of the agent's most load-bearing citations directly against source (`getPotentialParents()`'s signature, `markerHeterozygosity.R`'s allele-frequency computation, `buildMarkerGenotypeMatrix()`'s cell format, `modMarkerGenetics.R`'s tab structure, the `pedigree$sire`/`$dam` write-grep zero-result, and `checkMarkerGenotypeFile()`'s biallelic enforcement) — all six matched exactly.

Both agents' reported confidence levels are preserved rather than flattened to certainty: the no-error-model LOD formula (D2) is reported at high confidence by all three research angles; the genotyping-error-tolerant extension carries an explicit, self-flagged, unresolved verification gap (§7 Dragon 7) that this document does not attempt to resolve, matching this project's own "an unverified formula must not silently ship" convention (established by `markerFst()`'s own Pre-RED history, where a first-pass "Weir & Cockerham" attribution turned out ~40% wrong before an adversarial check caught it).

No `PROJECT_LEARNINGS.md` entries exist yet specific to likelihood-based parentage assignment (confirmed by grep for "LOD," "CERVUS," and "parentage assignment" — only unrelated homonyms and this issue's own prior audit/sequencing mentions). This document is the first substantive design work on #147's actual topic.

---

## 11. Ratification status — forced vs. judgment-call decisions

**Forced by the evidence (no real choice, not put to a vote):** D1 (method family — problem-shape argument, corroborated three ways), D3 (reference population — direct captive-colony precedent), D5 (no simulation-calibrated confidence — disproportionate cost plus overconfidence risk), D7 (extraction — reuse-discipline finding, behavior-preserving and regression-tested), D9 (helper placement — blast-radius/scope discipline).

**Genuine judgment calls requiring an `AskUserQuestion` ratification round:**

**Q1 (D2) — What scope should the LOD formula have in this plan's implementation?**
- **Option A — Implement the verified no-error-model formula now; scope the genotyping-error-tolerant extension (Kalinowski et al. 2007) as a separate, later, independently-re-verified slice or follow-on issue.** *(This document's recommendation — ships a fully-verified core now without blocking on an unretrievable corrigendum.)*
- **Option B — Block all implementation until the error-tolerant formula (eqn 1-3) is independently re-verified** (via the 2010 corrigendum, once retrievable, or an independent from-scratch derivation), then implement the full error-tolerant version directly in Slice 1. *(More complete, but stalls the whole feature on a currently-unretrievable source and increases Slice 1's own correctness-risk surface.)*
- **Option C — Treat the error-tolerant extension as permanently out of scope**, not merely deferred — the no-error-model formula only, indefinitely. *(A legitimate simplification given this package tracks no genotyping-error-rate parameter anywhere today, but forecloses a real accuracy improvement without revisiting it.)*

**Q2 (D6) — What mechanism/default should the minimum-loci ("low power") gate use?**
- **Option A — A fixed, literature-informed, user-overridable default** (e.g. `minLoci = 4L`), documented as a heuristic (not a mathematically-derived cutoff), mirroring `markerParentageExclusion()`'s own `maxExclusions = 2L` precedent. *(This document's recommendation — matches an established in-package pattern for "defensible heuristic, not a proven constant.")*
- **Option B — No fixed gate at all** — always compute and report `LOD`/`delta`/`nLociUsed`, relying entirely on transparent per-row reporting for the curator to judge case by case. *(Simpler, but risks a curator over-trusting a 1-2-locus ranking exactly as Dragon 2 warns against.)*
- **Option C — A data-driven, panel-specific power computation** (extending Cifuentes-style combined-exclusion-probability machinery to compute actual discriminatory power from the real allele frequencies at call time, rather than a fixed loci count). *(More rigorous, meaningfully larger implementation lift — a plausible future refinement rather than a v1 requirement.)*

**Q3 (D4) — Report-only vs. write-back architecture?**
- **Option A — Report-only in this issue.** A ranked-candidate-table function only; zero code path writes `pedigree$sire`/`pedigree$dam`. Any future write-back is a separate, later, explicitly-scoped follow-on issue. *(This document's recommendation — directly satisfies the issue's own "curator review, not silent rewrite" language at the lowest possible blast radius, given §2.5's confirmed zero existing precedent for pedigree mutation.)*
- **Option B — Include a curator-confirmed write-back function in this same issue's slices**, informed by (not assumed identical to) `resolveCrossCenterIds()`'s curator-confirmed-mapping pattern. *(Larger scope; introduces this package's first-ever pedigree-mutation code path bundled with a statistics-correctness review, mixing two different risk categories in one issue.)*

**Q4 (D10) — What shape should Shiny UI wiring take, if any, and in which slice?**
- **Option A — A 5th read-only "Candidate Parent Assignment" tab in `modMarkerGenetics.R`**, matching the existing 4-tab `DT::DTOutput` pattern (§2.8) — since D4 (report-only) means there is no confirm/apply action to support, a plain diagnostic table is the right-sized UI, added in Slice 2. *(This document's recommendation — matches the module's own established shape exactly.)*
- **Option B — Defer all UI wiring to a later, separate slice or issue; ship only the script-callable function in this plan's scope**, matching `resolveCrossCenterIds()`'s own Slice-4 precedent (Session 446: "script-callable function only this session, no `modInput.R`/UI change"). *(Narrower Slice 1-only scope for this plan; a future session adds the UI once the statistical core has stabilized.)*
- **Option C — Adapt `modBreedingGroups.R`'s scored-selection UI pattern** (dropdown + comparison table, §2.8) even though D4 means there is no "confirm" action to wire up. *(A richer per-offspring drill-down UX, but adapts a pattern built for a different interaction shape — selecting among whole-solution candidates, not viewing a diagnostic ranking — for no clear behavioral gain given D4.)*

Until Q1-Q4 are answered via `AskUserQuestion` (or the owner's plain-language equivalent), this document remains a **draft proposal**, not a ratified plan.

### Ratification outcome (2026-08-09, this session)

All four questions were posed via a single `AskUserQuestion` call. The owner selected **this document's own recommended option in all four cases, with no changes requested**:

- **Q1 (D2):** Option A — implement the verified no-error-model LOD formula now; scope the genotyping-error-tolerant extension (Kalinowski et al. 2007) as a separate, later, independently-re-verified slice or follow-on issue. **RATIFIED.**
- **Q2 (D6):** Option A — a fixed, literature-informed, user-overridable `minLoci` default (e.g. `minLoci = 4L`), documented as a heuristic, mirroring `markerParentageExclusion()`'s own `maxExclusions = 2L` precedent. **RATIFIED.**
- **Q3 (D4):** Option A — report-only architecture; zero code path writes `pedigree$sire`/`pedigree$dam` in this issue. **RATIFIED.**
- **Q4 (D10):** Option A — a 5th read-only "Candidate Parent Assignment" tab in `modMarkerGenetics.R`, matching the existing 4-tab `DT::DTOutput` pattern, added in Slice 2. **RATIFIED.**

This plan is now **RATIFIED** in full (all forced decisions D1/D3/D5/D7/D9 plus all four judgment calls D2/D4/D6/D10). Implementation begins with Slice 1 in a future session, per the vertical-slice plan in §5. This document itself changes no `R/`, `tests/`, or `man/` content — ratification closes the *design* session, not an implementation one, matching the #133/#136/#137 precedent.
