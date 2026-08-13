# kinship2 Supplementary-Material Reproducibility Audit

**Date:** 2026-08-13 · **Session:** S549 · **Type:** capability-comparison / reproducibility
audit (not a code-defect audit — no severity ratings; findings carry a **gap direction**
instead, matching the `ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md` precedent)

**Source document:** `inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf` —
Sinnwell, Therneau & Schaid, "The kinship2 R Package for Pedigree Data: Supplementary
Material" (Mayo Clinic; PMC manuscript NIHMS593658), 6 pages. Text extracted via
`pdftotext -layout` (not read visually) to avoid transcription error in the numeric tables
that are this audit's ground truth.

**Question asked (`BACKLOG.md` Housekeeping, found S545, owner-directed):** can
`nprcgenekeepr`'s existing exported functions reproduce the results and plots in this PDF?
It covers 3 capability areas against a small, fully worked 17-subject example pedigree
(`fam1`): pedigree plots, pedigree trimming/shrinking, and a kinship-matrix worked example
with named expected values.

---

## Scope caveat (read this before the findings)

**The full 17-subject `fam1` pedigree cannot be exactly reconstructed from this repository's
materials.** The supplement states `fam1` is built from "Figure 1 of the main document" —
the *main* kinship2 application note (Sinnwell et al. 2014, *Bioinformatics*), which is
**not** among this repo's bundled reference PDFs (confirmed: `5201430.pdf` is an unrelated
2005 *EJHG* paper on CraneFoot; `bioinformatics_24_2_279.pdf` is an unrelated 2008 PedVizApi
paper — neither is the kinship2 application note). It is also not shipped as data anywhere
in the installed `kinship2` package (v1.9.6.2): its 3 bundled datasets (`sample.ped`,
`testped1`, `minnbreast`) were checked directly and are all structurally unrelated to
`fam1` (different ids, no matching twin/consanguinity pattern); no vignette source file
references `fam1` by name.

What **is** fully, numerically specified in this supplement is the **10-subject subset**
shown in **Figure S1** — the worked example the pedigree-trimming and kinship-matrix
sections actually use. Its structure was reconstructed **from the kinship values in Table
S1 themselves** (e.g., `kinship(1,3) = kinship(1,4) = 0.25` establishes 1×2 as parents of
3 and 4; `kinship(7,8) ≈ 0.28` — inflated above the 0.25 avuncular/parent baseline —
establishes 7×8 as the pedigree's stated consanguineous mating), not guessed from the
rendered figure, and cross-checked against every relationship the supplement's own prose
names explicitly (self/parent-offspring/grandparent/avuncular/cousin/twin coefficients).
This audit's scope is therefore **the fully-specified Figure S1 subset**, not the full
17-subject pedigree; the subjects `pedigree.shrink()` trims away (11–17) are named only by
id and trim-category in the supplement, never by relationship, so no capability can be
checked against them.

Reconstructed fixture (id / sire / dam / sex; not committed to the package — audit-only):

```r
fam1 <- data.frame(
  id   = as.character(1:10),
  sire = c(NA, NA, "1", "1", NA, NA, "3", "6", "6", "8"),
  dam  = c(NA, NA, "2", "2", NA, NA, "5", "4", "4", "7"),
  sex  = c("M","F","M","F","F","M","F","M","M","F")
)
```

---

## Findings

### Finding #1: `kinship()` has no mechanism to model monozygotic-twin genetic identity — gap direction: nprcgenekeepr narrower than kinship2

- **Location:** `R/kinship.R:62` (`kinship(id, father.id, mother.id, pdepth, sparse)`)
- **Description:** kinship2's own `kinship()` takes a `pedigree` object built with an
  optional `relation` argument that declares MZ/DZ/UZ twin pairs; when two individuals are
  declared MZ twins, kinship2 overrides their pairwise coefficient to equal their
  self-kinship (genetic identity) and propagates that identity to every relative computed
  through either twin. `nprcgenekeepr::kinship()` takes only `id`/`father.id`/`mother.id`/
  `pdepth` — there is no parameter through which twin identity (or any other `relation`)
  can be supplied, and no post-processing step applies one.
- **Evidence:** Ran the Figure S1 fixture through **both** functions.
  `nprcgenekeepr::kinship()`'s full 10×10 output matches Table S1 for every cell **except**
  the two twin-linked ones (all other cells differ from the PDF's printed value by at most
  0.01 — reproduced as R's own `round()` "round-half-to-even" vs. the paper's
  round-half-away-from-zero print convention, confirmed by reproducing the *same* 0.01
  drift when running `kinship2::kinship()` itself on this fixture *without* declaring the
  twin relation):

  | Pair | PDF (Table S1) | `nprcgenekeepr::kinship()` | `kinship2::kinship()` — twins declared |
  |---|---|---|---|
  | kinship(8, 9) | **0.50** | 0.2500 (ordinary full-sib) | **0.5000** |
  | kinship(9, 10) | **0.28** | 0.1562 | **0.2812** |
  | kinship(10, 10) (self, inbred) | 0.53 | 0.5312 (matches) | 0.5312 (matches) |

  Feeding the identical fixture to `kinship2::pedigree(..., relation = data.frame(id1=8,
  id2=9, code=1))` then `kinship2::kinship()` reproduces the PDF's twin-linked cells
  exactly (0.50, 0.2812 ≈ printed 0.28) — confirming kinship2 achieves this via the
  `relation` argument specifically, not some other mechanism, and confirming
  `nprcgenekeepr`'s divergence is a missing feature, not a computation error (subject 10's
  own self-kinship, which depends on the *sire/dam* consanguinity path rather than the
  twin shortcut, matches exactly in both packages).
- **Impact:** `nprcgenekeepr` already has a twin-declaration data model —
  `checkTwinRelations()` / a `twinRelations` sidecar table (issue #137, shipped S492-494)
  — but it is wired **only** to the Diagram tab's rendering (`makePedigreeDiagramData()`,
  `makePedigreeMatingLayout()`; confirmed by grep — `twinRelations` appears in exactly those
  2 files plus `modPedigree.R`/`obfuscateTwinRelations.R`/`readTwinRelations.R`, never in
  `kinship.R` or any of its 15 call sites). Every kinship-driven calculation in the package
  — `meanKinship()`, `getAnimalsWithHighKinship()`, genetic-value/GVA scoring
  (`gvaConvergence.R`, `reportGV.R`), breeding-group formation (`modBreedingGroups.R`),
  mate-pair analysis (`reportMatePairs.R`) — silently treats a declared MZ-twin pair as
  ordinary full siblings (understating their kinship by exactly 0.25) and understates the
  kinship of every relative reached *through* either twin. This is a real, if
  narrow-trigger, scientific-accuracy gap for any colony pedigree with a genuine
  monozygotic-twin pair (naturally-occurring MZ twins are rare but documented in captive
  macaque colonies — the very use case issue #137's diagram encoding already targets).
- **Recommendation:** file a follow-up issue to thread `twinRelations` into `kinship()`
  (or a wrapper) so an MZ-declared pair's coefficient is overridden to self-kinship,
  matching kinship2's own mechanism; scope should explicitly include propagating the
  override transitively (as kinship2 does for subject 9→10 above), not just the direct
  pair. Not implemented this session — an audit finding, not same-session scope, per this
  project's established "report, don't fix mid-session" precedent (`PROJECT_LEARNINGS.md`
  Learning 382).

### Finding #2: No visual signal for a consanguineous mating in the Pedigree Diagram tab — gap direction: nprcgenekeepr narrower than kinship2

- **Location:** `R/makePedigreeDiagramData.R:1032` (`makePedigreeMatingLayout()`)
- **Description:** kinship2's own plot method draws a mating between two blood-related
  individuals with a doubled/thickened connecting line (visible in the PDF's own Figure S1
  image, between subjects 7 and 8) — a standard medical/genetic-pedigree convention
  signaling "this couple is consanguineous" at a glance. Ran the Figure S1 fixture (with
  its one genuinely consanguineous mating, 7×8) through `makePedigreeMatingLayout()`:
  the mating unit is structurally correct (a `__union_4` node connecting sire 8 and dam 7
  to child 10, alongside the other 3 non-consanguineous unions) but is rendered with
  **exactly the same styling** as every other union — no distinguishing color, dash, or
  title. Confirmed via `grep -in "consang" R/*.R`: zero matches anywhere in the package.
- **Distinct from 2 items already in `BACKLOG.md`/GitHub, checked directly, not assumed:**
  issue #134 ("Verify inbreeding-loop/consanguinity rendering," closed S453) verified the
  *layout doesn't break* for a consanguineous-loop fixture — a structural/robustness
  check, not a visual-signaling one; its own closing comment describes node/edge counts,
  not styling. `BACKLOG.md`'s "Candidate C" item (found S473) proposes dashed/colored
  styling for cross-generation mate-line **doglegs** specifically (a geometry-signposting
  problem — a mate-line that visually looks like a layout bug) — a different trigger
  condition than "these two mates happen to be blood relatives," and its own text never
  mentions consanguinity.
- **Impact:** Minor — a diagram-readability gap, not a computational-correctness one. A
  colony manager viewing the Diagram tab for a pedigree with a consanguineous mating gets
  no visual cue distinguishing it from an unrelated mating, unlike kinship2's convention.
- **Recommendation:** a future session could detect consanguinity directly from the
  existing kinship matrix (`kinship(sire, dam) > 0`) and apply a distinct edge style to
  that union's 2 spouse-to-union edges — likely a small, `edgeStyle`-orthogonal addition
  to `makePedigreeMatingLayout()`. Not implemented this session — logged as a new
  recommendation, not filed as a GitHub issue yet (see Recommendations below).

### Finding #3: `trimPedigree()`/`removeUninformativeFounders()` are not a `pedigree.shrink()` equivalent — gap direction: different problem, not a missing feature

- **Location:** `R/trimPedigree.R:51`, `R/removeUninformativeFounders.R:30`
- **Description:** kinship2's `pedigree.shrink()` iteratively removes subjects by
  **availability** (genetic-data-available) and **affected** status, in a fixed 5-step
  priority order, until a pedigree reaches a target **bit size** (a linkage-analysis /
  genotyping-cost concept: `bits = 2 × founders − 1`-style capacity). `nprcgenekeepr`'s
  `trimPedigree()` solves a different problem: given a set of **probands**, keep exactly
  their ancestors, optionally dropping founders that appear only once (uninformative for
  *pedigree completeness*, not genotyping cost). Ran the Figure S1 fixture's own
  10-subject pedigree through `trimPedigree()` with `probands = "10"`: it correctly keeps
  all 10 ancestors (no founder in this fixture appears only once, so
  `removeUninformativeFounders()` removes nothing here) — behaving exactly as designed,
  but answering "who are 10's ancestors," never kinship2's actual question, "shrink this
  pedigree to bit size N given availability/affected status."
- **Impact:** None identified — `nprcgenekeepr`'s stated mission is breeding/genetic-
  diversity management (mean kinship, genetic value, breeding-group formation), not
  linkage-analysis genotyping-cost optimization, so a `pedigree.shrink()` equivalent
  serves a use case this package does not appear to target. This is a capability-**fit**
  observation, not a gap to close.
- **Recommendation:** no action. Documented here so a future session doesn't mistake
  `trimPedigree()` for kinship2 parity and doesn't re-investigate this same question.

### Finding #4: No X-chromosome-specific kinship computation — gap direction: nprcgenekeepr narrower than kinship2, likely out of scope

- **Location:** `R/kinship.R` (package-wide — grepped for `chrtype`/`x.chrom`/`sex.linked`/
  `xlinked`, zero matches)
- **Description:** the supplement's Table S2 gives an X-chromosome kinship matrix for the
  same 10-subject pedigree (autosomal and X-linked kinship differ substantially — e.g.
  father-daughter X-kinship is 0.50, not 0.25, since a father transmits his single X
  intact). `nprcgenekeepr` computes autosomal kinship only.
- **Impact:** Low priority / likely non-issue. NPRC colony-management use cases in this
  package (mean kinship, genetic value, breeding recommendations) are framed around
  genome-wide/autosomal relatedness; no existing `BACKLOG.md`/GitHub item requests
  X-linked-specific analysis. Noted for completeness of this comparison, not as an
  actionable gap.
- **Recommendation:** no action unless a future use case specifically needs sex-linked
  kinship (e.g., an X-linked disease-risk feature).

---

## Items Audited

| Capability area (PDF section) | Reproducible with existing exported functions? | Finding(s) |
|---|---|---|
| Kinship matrix — autosomal (Table S1) | **Yes, exactly**, except MZ-twin-linked cells (2 of 100) | #1 |
| Kinship matrix — X chromosome (Table S2) | No — capability doesn't exist | #4 |
| Pedigree plots (Figure S1: shapes by sex, generation layout, consanguineous mate signposting) | Partially — node/edge/generation/twin-connector structure all correct (`makePedigreeDiagramData()`/`makePedigreeMatingLayout()`); consanguinity has no visual marker | #2 |
| Pedigree trimming (`pedigree.shrink`, bit-size-driven) | No — `trimPedigree()` solves a different (proband-ancestor) problem, not a gap given package scope | #3 |

**Coverage:** all 3 capability areas named in the `BACKLOG.md` item examined; the 4th area
implicit in Table S2 (X-linked kinship) examined incidentally. Not examined: the full
17-subject `fam1` pedigree (out of scope — not reconstructible, see caveat above); pedigree
subsetting via `ped1[-c(...)]`-style R indexing (a `kinship2`-internal S3-class mechanic
with no direct `nprcgenekeepr` analogue to compare against, since `nprcgenekeepr` pedigrees
are plain data frames, not a dedicated S4/S3 pedigree class).

---

## Comparison with Prior Audits

`ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md` (S435) compared the Diagram tab's
*rendering feature set* against kinship2's broadly, from documentation and code reading —
it did not exercise `kinship()` against any numeric ground truth. This audit is
complementary: it verifies the *computational engine* against a concrete, published
worked example with known expected values, and found one finding (#1) entirely outside
that prior audit's scope (it never examined `kinship.R`). Finding #2 refines, rather than
duplicates, that prior audit's own Finding #1 / issue #134: #134 verified *layout
robustness* for consanguineous loops (already closed, no further action); this audit's
#2 is specifically about the *absence of a visual marker*, a distinct question #134 never
asked.

| Metric | Prior (`ISSUE_129...`, S435) | Current (S549) |
|---|---|---|
| Scope | Diagram-tab feature checklist (17 points) | Kinship computation + diagram structure, against 1 worked numeric example |
| Findings | 8 | 4 |
| New ground covered | Diagram-tab rendering only | `kinship()`'s numeric engine (not examined by any prior audit) |
| Coverage | 100% of the 17-point checklist | 3 of 3 requested capability areas + 1 incidental (X-linked) |

---

## Recommendations

1. **File a follow-up issue for Finding #1** (thread `twinRelations` into `kinship()`'s
   computation, not just diagram rendering) — the only finding with a real scientific-
   accuracy impact on this package's actual analysis pipeline. Recommend scoping this as
   its own design session given it touches a widely-called core function (15 call sites).
2. **File a follow-up issue for Finding #2** (consanguineous-mating visual marker) — small,
   diagram-only, no dependency on #1.
3. **No action** on Findings #3/#4 — both are capability-fit observations, not gaps; kept
   in this report so a future session doesn't re-ask the same question from scratch.
4. Both new issues should go through this project's normal triage (`AskUserQuestion`
   owner picks), matching how the `GENETIC_METRICS_PDF_CAPABILITY_AUDIT`/`ISSUE_129_...`
   audits' own findings were triaged in a dedicated follow-up session, not filed
   unilaterally in the audit session itself.
