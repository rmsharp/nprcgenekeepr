# Genetic Metrics Issues (#146-153) Sequencing Audit

**Date:** 2026-08-08 · **Session:** S483 · **Type:** capability-informed sequencing audit (not a
defect audit — recommends an implementation *order* for already-filed items; files no new issues
itself, per the established "audit recommends, a later session files" precedent set by
`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md` and reaffirmed in
`docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`'s own Recommendation 1)

**Question asked (owner-directed, this session):** "I asked you in a prior session to propose an
order to address the Issues... propose an order to address the issues and then follow that up by
presenting them as session topics to pick up." No prior session recorded this request in
`SESSION_NOTES.md`/`HANDOFFS.md`/`CHANGELOG.md` — it was not captured in the project's own written
record — so this audit treats it as newly assigned this session, scoped to GitHub issues **#146-153**
(the "Genetic Metrics PDF capability gap" cluster). This is the only cluster of open issues that has
sat with no sequencing across four consecutive session handoffs (S479-S482, each noting "Issues
#146-153 remain open, GitHub-only, unchanged") while every other open-issue cluster already has an
established order: the pedigree-diagram cluster via
`PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`, LabKey integration is BLOCKED pending a
live server, and NPRC outreach is DECISION NEEDED (owner-only). If this scoping assumption is wrong,
say so and this audit will be redone against the intended set.

---

## Method

Issues #146-153 were all filed by a prior ghost-session run (reconciled S479, see
`PROJECT_LEARNINGS.md` Learning 479) against `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`
(each issue's own "Source" field cites the 08-05 audit by name). A **newer, revised** capability
audit — `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-06.md`, one day later, an explicit
"fresh comparison" — replaced 08-05's flat, unordered "Remaining priority gaps" list with a formal
**High / Medium / Deferred-scientific** "Priority gap analysis" table. The issues were never
re-triaged against this newer table. This audit uses the 08-06 table as the authoritative priority
source, not the 08-05 text the issues happen to cite.

Ran a 3-phase background workflow rather than sequencing from memory or issue-filing order:

1. **Assess** — 8 parallel agents, one per issue, each given the issue's full title/body (fetched via
   `gh issue view <N> --json title,body`), its audit-tier classification, and instructed to actually
   `Grep`/`Read` the current `R/` source (not guess) before estimating effort (S/M/L/XL), codebase
   readiness, cross-issue dependencies, and risk flags.
2. **Synthesize** — one agent given all 8 structured assessments plus the audit's own priority table,
   producing a tiered recommended order with a per-item rationale, mirroring this document's own
   house style (`PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`).
3. **Verify** — one adversarial agent independently re-derived the ordering from the raw assessments
   and the audit table, checking for missing/duplicated issues, violated dependencies, misrepresented
   audit tiers, and unsupported claims, before the ordering was accepted.

**Coverage:** all 8 open GitHub issues in the cluster (#146-153). No item skipped. Verify found the
tier *ordering* itself sound (see Findings), but required correcting one recommendation clause and
softening two overstated claims in the synthesis narrative before write-up — those corrections are
applied directly in this document, not left as a caveat.

---

## Inventory

| # | Title | Audit tier (08-06) | Filed | Effort (this audit) |
|---|---|---|---|---|
| #147 | Likelihood-based candidate-parent assignment after marker parentage exclusion | **High** | 2026-08-06 | XL |
| #149 | Reviewed cross-center identity-mapping workflow with provenance export | Medium | 2026-08-06 | M |
| #146 | Configurable/exhaustive breeding-group candidate retention | Medium | 2026-08-06 | L |
| #151 | Individual mate-pair analysis alongside breeding-group optimization | Medium | 2026-08-06 | L |
| #150 | De-identified pedigree export workflow for approved data sharing | *Not ranked — "Policy/external"* | 2026-08-06 | L |
| #152 | Whole-genome/whole-exome sequence input + sequence-based metrics | Deferred/scientific | 2026-08-06 | XL (design-only ask) |
| #153 | Linkage-aware and haplotype-block metrics for marker data | Deferred/scientific | 2026-08-06 | XL (design-only ask) |
| #148 | MHC haplotype-specific frequency and rare-haplotype reporting | Deferred/scientific | 2026-08-06 | L (filed as a full feature — see Finding #3) |

**Two audit-table rows have no corresponding issue at all** — see Finding #1.

---

## Evidence base

### The authoritative priority table (`GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-06.md`, "Priority
gap analysis")

| Priority | Gap | Filed issue |
|---|---|---|
| High | Parentage assignment after contradiction screening | #147 |
| High | Longitudinal genetic-health monitoring | **none** |
| High | Ancestry guardrails in breeding decisions | **none** |
| Medium | Cross-center mapping workflow and standard marker protocol | #149 |
| Medium | Candidate-group completeness and behavioral inputs | #146 |
| Medium | Individual mate-pair analysis | #151 |
| Deferred/scientific | MHC/functional, NGS, and LD/block methods | #148, #152, #153 |

#150 (de-identified pedigree export) does not appear in this table at all. It maps instead to the
main capability-comparison table's row "Make pedigree data available to approved researchers,"
classified **Policy/external**: "Access approval, authorization, and no-restriction policy are
institutional matters. No integrated, auditable sharing-export workflow exists." The audit
deliberately excluded it from the engineering-priority ranking rather than ranking it low within it.

### Dependency shape of the batch

None of the 8 assessments reported a **hard** blocking dependency on another issue in this set —
every `dependencies` field returned is either empty or explicitly self-labeled non-blocking. The only
real coordination signals are:
- **Shared-file risk:** #146 and #151 both likely touch `R/modBreedingGroups.R`; #147 and #148 both
  likely touch `R/modMarkerGenetics.R`.
- **Vocabulary-overlap risk:** #148 ("haplotype" = classical named MHC allele combinations) and #153
  ("haplotype block" = a statistically-inferred LD-linked segment) use the same word for different
  concepts — a future session touching both should disambiguate rather than let two ad hoc
  representations diverge.
- **Soft design-reuse pairing:** #149 and #150 both need a "confirm + export with provenance" UI
  pattern; whichever ships first should design it reusably rather than let the app end up with two
  divergent one-off conventions.

So sequencing here is **priority/effort/readiness-driven, not dependency-driven** — unlike the
pedigree-diagram cluster's Tier 1, where 3 items shared one literal code region and had to be worked
together.

---

## Findings

### Finding #1: Two High-priority audit gaps were never filed as GitHub issues

The audit's own priority table rates **"Longitudinal genetic-health monitoring"** and **"Ancestry
guardrails in breeding decisions"** both **High** — tied with #147, and above every Medium and
Deferred item in this batch. Neither has a corresponding issue anywhere in #146-153 (confirmed via a
live `gh issue list` cross-check, independently reconfirmed by the adversarial verify pass). This is a
gap in the original ghost session's issue-filing pass, not an artifact of this audit's framing: all 8
per-issue assessments independently surfaced the same finding (though, per the verify pass, this
convergence is better read as "all 8 were given the same audit table as shared context and read it
consistently," not as independent corroboration in the stronger sense — the underlying gap is real
either way, confirmed directly against `gh issue list`).

**Recommendation:** file tracking issues for both in a dedicated future triage session — not from this
sequencing exercise itself, matching the established "audit recommends, a later session files"
precedent. Because both gaps are tied with #147 in audit priority, and #147 (the batch's other
High-priority item) was itself filed as a full-feature request whose own first actionable step is a
Pre-RED design session, the two new issues should be filed the **same way** — full-feature requests
gated on a design session — not shaped like the Deferred/scientific-tier issues (#148/#152/#153),
which were deliberately filed as narrower design-only asks. Filing them the same way as their own
priority-tier sibling keeps the tier vocabulary consistent; filing them like a lower tier would
understate their actual priority.

### Finding #2: The batch has no hard sequencing dependencies — order is priority/effort/readiness-driven

See "Dependency shape of the batch" above. This means the recommended order below is a genuine
priority call, not a topological necessity — an owner who weighs effort or codebase readiness
differently than this audit could reasonably reorder Tier 2's three items without breaking anything
structural. It also means, unlike the pedigree-diagram Tier 1, there is no item in this batch that
*must* be done before another can start.

### Finding #3: #150 is the batch's readiness/priority outlier and needs an explicit owner decision, not an engineering one

#150 has the **most complete existing codebase foundation of any item assessed in this batch** (not
necessarily the single highest in an unmeasured, precise sense — no formal readiness score exists to
support that superlative — but demonstrably among the most complete): `obfuscateId()`,
`obfuscateDate()`, `obfuscatePed()`, and `mapIdsToObfuscated()` are all already exported, documented,
and unit-tested, and `obfuscatePed()` already returns `list(ped=<de-identified pedigree>,
map=<alias map>)` in one call — most of the genetics-hard part is done. Yet the audit deliberately
left it **out of the priority table entirely**, classifying it "Policy/external" because the codebase
has zero auth/role/curator-identity infrastructure to hook a real access-control gate into — "curator-
controlled" can only be implemented as UX-only gating today, and whether that is an acceptable
implementation of "curator-controlled" is an institutional policy call, not an engineering one this
audit or any implementing session can make unilaterally.

This is a similar *shape* of gate to `PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`'s
treatment of its own B2 item (needs "a fresh, explicit owner product-level sign-off before it is even
a scoped backlog item") — illustrative of the same pattern (technical readiness ≠ license to proceed
without a sign-off), though the underlying gate itself is a different kind: B2 was a declined-design
revival needing product sign-off, #150 is an institutional data-governance/access-policy question.

**Recommendation:** surface #150 to the owner as a standalone decision — "the code to build this is
already 90% written and tested; do we want to formalize a curator-controlled de-identified sharing
export, understanding that 'curator-controlled' means a confirmation dialog and warning text, not
real access control?" — independent of its technical sequencing.

### Finding #4: #148 is filed broader than the audit itself recommends

The audit explicitly places MHC/functional work in its lowest ("Deferred/scientific") tier and
recommends it "advance only through separately scoped research/design work" — the same treatment it
gives NGS (#152) and LD/haplotype-block (#153). #152 and #153 were filed accordingly, as design-only
asks ("Create a design plan... This is design/discovery work, not a request for an unbounded... 
platform"). **#148 was not** — its issue body asks for the full shippable feature (per-haplotype
counts/frequencies, rarity flagging, affected-animal reporting, CSV export), with no design-only
framing. There is also a concrete technical landmine: `checkMarkerGenotypeFile()` hard-rejects any
locus with more than two distinct alleles, and real MHC haplotype panels are typically highly
polymorphic — the existing validator cannot gate this feature unmodified, and a careless
implementation risks either always erroring on real MHC input or weakening the biallelic check
globally (which would silently break the KING-robust kinship estimator's correctness assumption for
every other caller).

**Recommendation:** before implementation, hold a scope-narrowing conversation on #148 — likely
splitting it into a design-first sub-issue (matching #152/#153's own shape) and a later
implementation issue, rather than starting implementation directly from the issue as currently filed.

---

## Recommended implementation order

### Tier 1 — High-Priority Design Launch

**#147 — Likelihood-based candidate-parent assignment after marker parentage exclusion.** The sole
High-priority item in the batch. XL on all three effort drivers at once: no multilocus
likelihood/LOD-style parentage-scoring method exists anywhere in the codebase today (only
`markerParentageExclusion()`'s raw per-locus exclusion count against a single recorded parent); no
module anywhere writes to `pedigree$sire`/`pedigree$dam`, so "curator review, not silent rewrite" is
an open architectural question, not a known pattern to copy; and the existing `modMarkerGenetics.R`
tabs are all passive read-only tables with no ranked-candidate-drill-down interaction surface. Real
partial infrastructure exists (`getPotentialParents()`'s demographic candidate lists,
`markerParentageExclusion.R`'s Mendelian-inconsistency core as an adaptable filter,
`markerExpectedHeterozygosity()`'s internal per-locus allele frequencies as raw material for a LOD
score) but none of it resolves the statistical-method or data-model decisions the issue itself
demands be designed "before implementation." **Next action: a Pre-RED design/scoping session**
(statistical method choice, reference-population choice for allele frequencies, report-only vs.
write-back architecture) — not a single-session build, mirroring issue #130's own dedicated-planning-
session precedent.

### Tier 2 — Ready-to-Build Medium-Priority Features

Ordered by effort and shared-file coordination risk, not issue number (this order also happens to
match the audit table's own row order for these three Medium items):

1. **#149 — Reviewed cross-center identity-mapping workflow with provenance export.** Smallest of the
   three: the hard part (the merge algorithm and its fail-fast validation) is already exported,
   documented, and fully tested in `R/resolveCrossCenterIds.R`, covering every validation bullet the
   issue lists. Net-new work is a non-fail-fast "show all problems at once" validation surface, the
   app's first `showModal()`/`modalDialog()` confirmation gate, and a multi-artifact provenance
   export — none with any existing precedent to collide with. Sequenced first in this tier both as
   the most contained, highest-readiness item, and because it establishes confirm/export UI
   conventions #150 (Tier 3, if greenlit) can reuse.
2. **#146 — Configurable/exhaustive breeding-group candidate retention.** Splits into two very
   different pieces: (a) parameterizing the existing tested 5-candidate retention cap (issue #125's
   infrastructure) into a configurable N — a small, mechanical change against solid, already-tested
   code; and (b) an exhaustive-enumeration mode that is genuinely new combinatorial-search algorithm
   work with zero existing precedent (`fillGroupMembers.R` is a purely stochastic greedy sampler),
   which the issue itself demands be scoped via a documented feasibility/complexity guard "before
   implementation." **Recommendation: ship the configurable-retention slice now; treat exhaustive
   enumeration as its own separately-scoped pre-RED design spike**, not one bundled deliverable.
   Sequenced ahead of #151 to land the shared `R/modBreedingGroups.R` change first and avoid
   concurrent-session merge friction.
3. **#151 — Individual mate-pair analysis alongside breeding-group optimization.** Substantial reuse
   exists (`filterPairs()`/`filterAge()` for eligibility, the already-shipped marker-kinship reactive
   from issue #130, `reportGV()`'s genetic-value inputs — all already threaded as shared reactives
   into `appServer.R`'s dependency-injection pattern) but the core deliverable — a full, unfiltered,
   joined, rankable pair table with user-selected exclusions — has no existing analogue anywhere in
   `R/`, and needs its own pre-RED scope decisions (exclusion granularity, which ranking criteria to
   expose) before RED tests can be written. Sequenced after #146 specifically to let it branch from a
   settled `modBreedingGroups.R` rather than run concurrently against it.

### Tier 3 — Policy-Gated Quick Win (special case)

**#150 — De-identified pedigree export workflow.** See Finding #3. Not in the audit's own priority
table at all; among the highest codebase readiness of any item in this batch. Placement here reflects
that readiness lowers the *risk* of a session once picked up, but does not manufacture the *priority*
the audit deliberately withheld — the open question is an institutional policy decision (does the
project want to formalize this, and can "curator-controlled" mean UX-only gating), not an engineering
one. Positioned after the audit-ranked Medium tier and before the Deferred/scientific tier, but capable
of moving fast — plausibly ahead of remaining Tier 2 work — the moment an owner affirmatively answers
the policy question.

### Deferred — Scientific/Research Design-Only Work

All three are XL under the full-feature rubric but the issues themselves (or this audit's own
recommendation, for #148) scope the actionable near-term deliverable as a **design plan**, not code —
matching the audit's own explicit "advance only through separately scoped research/design work"
guidance for this tier.

1. **#152 — Whole-genome/whole-exome sequence input.** Broadest design scope of the three (storage/
   privacy/compute constraints, explicit interaction with pedigree/marker analyses) — sequenced first
   within this tier since its output could usefully inform #153's linkage-metadata vocabulary, even
   though #153 is explicitly written to remain independently viable without it.
2. **#153 — Linkage-aware and haplotype-block metrics.** No LD/haplotype-block/recombination code and
   no locus-order/chromosome/genetic-map metadata exist anywhere in the marker-genetics family today.
   Sequenced second so its design can draw on #152's vocabulary if useful, and so a haplotype-
   vocabulary disambiguation exists before #148 is picked up next.
3. **#148 — MHC haplotype-specific frequency reporting.** See Finding #4 — filed broader than the
   audit recommends. Sequenced last in this tier deliberately: picking it up as currently filed means
   building against a scope the audit says isn't ready yet. **First action: a scope-narrowing
   conversation**, likely producing a design-first sub-issue matching #152/#153's own shape.

---

## Structural observations

- **This is a fundamentally different sequencing shape than the pedigree-diagram cluster.** That
  cluster's Tier 1 was 3 items forced together by sharing one literal code region
  (`.positionMatingUnitForest()`/`.buildMatingUnitForest()`) — a real topological constraint. This
  batch has no such constraint anywhere; every item's `dependencies` came back empty or explicitly
  non-blocking. Treat the tiers above as a priority/readiness recommendation an owner can reorder
  within Tier 2 without breaking anything, not as a dependency chain that must be followed in order.
- **Audit priority and "is a GitHub issue filed" are two independent facts, and this batch shows they
  can diverge in both directions** — #150 has an issue but no audit-table ranking; "Longitudinal
  genetic-health monitoring" and "Ancestry guardrails" have audit-table High rankings but no issue at
  all. A future session picking "next issue by priority" purely from `gh issue list` order would
  silently work Medium-tier issues before two unticketed High-tier gaps (Finding #1) — this is exactly
  the failure mode this audit exists to prevent.
- **Every non-Deferred item in this batch is realistically multi-session, not single-session,** once
  this project's own close-out checklists are counted: a same-session `NEWS.Rmd` entry for any new
  exported function or Shiny feature, a same-session tutorial/article update for any new Shiny tab
  (Session 436 checklist), and — for anything introducing a new displayed statistic — a same-session
  citation-coverage update (issue #120 checklist). Combined with this project's strict-TDD Pre-RED
  scope-decision gate, none of #146/#147/#148/#149/#150/#151 fit a single session's "one deliverable"
  cleanly; each should be explicitly sliced (design/scope session, then one or more implementation
  slices) the way issue #130's marker-genetics family was split across Sessions 442-447, rather than
  attempted whole — attempting one whole risks Failure Mode #26 (mega-session masquerading as a
  vertical slice).

---

## Recommendations

1. **Adopt the tiered order above** as this cluster's sequencing, analogous to how the pedigree-
   diagram cluster's audit is being followed. A `BACKLOG.md` "Sequencing note" pointer is added in
   this session's close-out for discoverability, matching the established convention.
2. **File 2 new tracking issues** for "Longitudinal genetic-health monitoring" and "Ancestry
   guardrails in breeding decisions" in a dedicated future triage session (Finding #1) — filed as
   full-feature requests gated on a Pre-RED design session, matching #147's own shape as this batch's
   other High-priority item, not shaped like the Deferred-tier design-only issues.
3. **Surface #150 to the owner as a standalone policy decision** (Finding #3), independent of its
   technical sequencing — the engineering readiness is real, but the "should we build this" call is
   not this audit's or any implementing session's to make.
4. **Hold a scope-narrowing conversation on #148 before implementation** (Finding #4), likely
   producing a design-first sub-issue matching #152/#153's own shape.
5. **This session presents the resulting order as pickable session topics** (via the Phase 0
   priorities-list convention) rather than picking one to implement itself — proposing the order was
   this session's own one deliverable.
