## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Issue #168 — Ancestry Guardrails for Breeding-Group Formation: Scope-Narrowing Decision Record

**Status:** Scope-narrowing decision record (Session 761, 2026-09-22). Docs-only session —
zero `R/`/`tests/`/`man/` changes. This document is **not** the issue #168 design plan; it
records the owner's scope decision that #168's own closing gate line requires before any
implementation, plus the evidence inventory the future design-plan session starts from. The
design plan itself (`docs/planning/issue168-ancestry-guardrails-plan.md`) is a separate,
later session's deliverable, and implementation is gated on that plan being ratified —
matching the #167 scoping precedent
(`docs/planning/issue167-longitudinal-monitoring-scoping-2026-09-21.md`), the #148 precedent
(`docs/planning/issue148-mhc-haplotype-scoping-2026-09-17.md`), and the
#133/#136/#137/#145/#146/#147/#149/#150/#151/#152/#153/#167 design-first mold.

---

## 1. The decision

**Owner decision (2026-09-22, S761, via `AskUserQuestion`): "Design-first, same issue."**

Issue #168 advances design-first *without* filing a new sub-issue: the next #168 session
writes `docs/planning/issue168-ancestry-guardrails-plan.md` in the #152/#153/#167 mold
(numbered design decisions, vertical-slice list, per-slice completion criteria, each slice a
separate strict-TDD session), and implementation slices follow only after that plan is
ratified. An issue comment on #168 records this narrowing so the issue's full-feature body
is read through this gate from now on.

**Rejected alternatives** (recorded so a future session doesn't re-litigate from scratch):

- **Split into a design-only sub-issue:** same work plus one more issue to track and close.
  Declined for #148 (S703) and #167 (S755) as unnecessary ceremony and declined again here —
  every prior design-first issue in this family kept design + implementation under one issue
  number with a plan doc in `docs/planning/`.
- **Implement as filed:** against the issue's own closing gate line ("Define the
  center-configurable rule model and the override/audit-trail design in a Pre-RED design
  session before implementation") — the rule-model/override/audit decisions in §4 would
  otherwise be made ad hoc mid-implementation.
- **Defer / park:** not chosen — the capability audit rates this gap **High** (tied with
  #167, above every Medium item), and with #167 closed (S760), #168 is the sequencing-audit
  Finding-#1 cluster's last unstarted High item.

**Divergence from the S703 precedent, deliberate (matching S755):** no new `BACKLOG.md` item
is added for the design-plan session. S753 (which filed #167/#168) moved this cluster's
tracking out of `BACKLOG.md` and onto the issues themselves; the issue plus this record plus
the session handoff make the next step discoverable without regrowing a mandated-read file
(FM #28).

## 2. Source context

### 2.1 What issue #168 asks for (verbatim body, filed 2026-09-21, S753)

> **Source:** `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-06.md`: Priority gap
> analysis, High — "Ancestry guardrails in breeding decisions"; filed per
> `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` Finding #1 /
> Recommendation 2.
>
> The PDF's stated primary aim includes preserving geographic genetic composition. The
> package currently reports ancestry (an Origin color) after a breeding group is
> constructed; reporting after construction is weaker than preventing a problematic grouping
> in the first place.
>
> Add ancestry guardrails to group formation: center-configurable ancestry compatibility
> rules evaluated during candidate-group construction, blocking or flagging incompatible
> pairings as configured, with an explicit override mechanism and an audit trail recording
> which rule was overridden and why — so the guardrail informs decisions without silently
> vetoing curator judgment.
>
> Define the center-configurable rule model and the override/audit-trail design in a Pre-RED
> design session before implementation (same gate as #147).

### 2.2 Why the gate exists

The capability audit's priority table
(`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-06.md:87`) names the appropriate
next step itself: *"Define center-configurable ancestry compatibility rules and an
override/audit trail."* Its checklist row for the PDF aim ("Preserve geographic genetic
composition and avoid inappropriate cross-breeding," `:36`) scores the package **Partial**:
*"Origin is reported, not enforced. Group formation and ranking do not prevent or explicitly
warn on incompatible ancestry combinations."* The sequencing audit's Recommendation 2
(`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md:309`) directed that both
unticketed High gaps be *"filed as full-feature requests gated on a Pre-RED design session,
matching #147's own shape."* S753 filed the issue with exactly that gate line; this record
is the gate being exercised.

## 3. Evidence inventory — what exists now (grep-verified 2026-09-22)

The audit's "reported, not enforced" claim is grep-true: `grep -rn -iE "ancestry|origin"`
over the entire group-formation kernel — `R/groupAddAssign.R`, `R/fillGroupMembers.R`,
`R/makeGroupMembers.R`, `R/fillGroupMembersWithSexRatio.R`, and `R/modBreedingGroups.R` —
returns **zero matches**. Group formation is ancestry-blind today; the Origin color is
computed only after groups exist, in a different module.

| Building block | Status | Evidence |
|---|---|---|
| Standardized ancestry vocabulary | **Exists.** `convertAncestry()` normalizes free-form text to a 6-level factor: CHINESE, INDIAN, HYBRID, JAPANESE, OTHER, UNKNOWN; applied during QC | `R/convertAncestry.R:19` (function), `:42-45` (levels); `R/qcStudbook.R:257` (call site) |
| `ancestry` as an optional schema column | **Exists.** Optional pedigree column ("geographic population to which the individual belongs"); `geographicorigin` header auto-renamed | `R/getPossibleCols.R:28-29`, `R/columnSchema.R:20`, `R/fixColumnNames.R:66-67`, `R/qcStudbook.R:34-35` |
| Post-hoc Origin metric (the "reported" half) | **Exists.** `getGeneticDiversityStats()` computes a per-group Origin color via `getIndianOriginStatus()` — red when any CHINESE/HYBRID present, yellow for BORDERLINE, green otherwise — **only when the pedigree has an `ancestry` column**, and only for already-constructed groups | `R/getGeneticDiversityStats.R:81,109-118`; `R/getIndianOriginStatus.R:18` (`@noRd` internal) |
| Where Origin surfaces in the app | **Exists.** The Genetic Diversity dashboard heatmap (issue #112), a separate module downstream of group formation | `R/modGeneticDiversity.R:96` (stats), `:105` (heatmap) |
| Group-formation kernel | **Exists, ancestry-blind.** `groupAddAssign(candidates, kmat, ped, ..., threshold, ignore, minAge, iter, numGp, harem, sexRatio, ...)` — stochastic search plus optional exhaustive mode with a time limit | `R/groupAddAssign.R:156` (signature); greps above |
| The pairwise-conflict seam | **Exists.** One conflict structure governs candidate exclusion: `getAnimalsWithHighKinship()` builds a per-animal conflict list (`kin`) from kinship > threshold, filtered by `filterPairs()` (sex-pair `ignore`, default F-F) and `filterAge()`; `fillGroupMembers()` excludes via `setdiff(available[[i]], kin[[id]])` — the single choke point where "block" semantics would live | `R/getAnimalsWithHighKinship.R:41`, `R/filterPairs.R:34`, `R/fillGroupMembers.R:75` |
| Center-configurable settings precedent | **Exists.** Site-config file discovered per-OS, parsed to `center`/`baseUrl`/`lkPedColumns`/... with `defaultSiteParams()` fallback; example config ships | `R/getSiteInfo.R:37`, `R/getConfigFileName.R:15`, `inst/extdata/examples/example_nprcgenekeepr_config` |
| User-supplied outside-information table + sibling-validator mold | **Established.** `readKinshipOverrides`/`checkKinshipOverrides` (id1, id2, kinship), `readTwinRelations`/`checkTwinRelations`, `checkMhcHaplotypeFile`, `checkSnapshotHistory` — the mold for a rules table read at analysis time, validated loudly, written nowhere | `R/readKinshipOverrides.R:35`, `R/checkKinshipOverrides.R:35-36`, `R/readTwinRelations.R:35`, `R/checkMhcHaplotypeFile.R`, `R/checkSnapshotHistory.R` |
| Override + audit-trail precedent | **Exists.** #150's de-identified export: modal **confirm gate** (curator sees warning text before Confirm) + a downloadable **transformation manifest** — "a non-sensitive … auditable record," including a verbatim copy of the warning shown at the gate | `R/modDeidentifiedExport.R:30` (`.buildDeidentificationManifest`), `:47-51` (gate text), `:132` (Confirm button) |
| Mate-pair surface (possible second enforcement site) | **Exists.** `modMatePair` (issue #151) evaluates pairings outside group formation | `R/modMatePair.R:23` (UI), `:152` (server) |
| Ancestry-bearing test fixtures | **Gap.** `qcPed` has **no** `ancestry` column; `examplePedigree$ancestry` populates only JAPANESE/UNKNOWN (no INDIAN/CHINESE/HYBRID rows to exercise the canonical rhesus rules) | measured via `examplePedigree`/`qcPed` inspection, 2026-09-22 |
| Ancestry compatibility rules, enforcement during construction, override mechanism, audit trail | **Missing** — the actual #168 gap | greps above |

**Vocabulary discrepancy found during inventory (design input, not fixed here):**
`getIndianOriginStatus()` tests for a `BORDERLINE_HYBRID` category (`R/getIndianOriginStatus.R`,
yellow branch), but `convertAncestry()` can never produce it — its factor levels are exactly
the 6 above, and a `BORDERLINE_HYBRID` string would also not match the hybrid branch's
`stri_startswith_fixed(origin, "HYBRID")`. So the yellow/borderline branch is unreachable
for any pedigree standardized by `qcStudbook()`. The design plan must decide the rule
model's level vocabulary explicitly (Q6) rather than inheriting this quietly.

## 4. Open design questions the plan session must decide (not decided here)

Numbered as questions (Q), deliberately *not* as ratified decisions (D) — ratifying them is
the design-plan session's deliverable, in the #152/#153/#167 mold:

1. **Q1 — Rule model.** What is a "center-configurable ancestry compatibility rule"?
   Candidates: (a) a pairwise compatibility table over the standardized ancestry levels
   (e.g., INDIAN × CHINESE → block; INDIAN × HYBRID → flag), symmetric by construction;
   (b) group-composition rules (e.g., "a group may not mix INDIAN and CHINESE animals" —
   closer to `getIndianOriginStatus()`'s any-Chinese-present logic and to the PDF's
   group-level "geographic composition" aim); (c) both, with pairwise rules as the
   enforcement primitive and composition rules derived. Also: is a default rule set shipped
   (the audit's motivating rhesus Indian-origin case) or is the table empty until a center
   configures it?
2. **Q2 — Rule configuration surface.** Where do center-configurable rules live?
   Candidates: (a) a user-supplied rules file read at analysis time with a sibling
   validator (`readKinshipOverrides` mold — per-session, CRAN-safe, testable, matches every
   other outside-information table in the app); (b) the machine-level site-config file
   (`getSiteInfo()` mold — genuinely "center-configurable," but that file is LabKey-oriented
   and per-machine, and no analysis input currently lives there); (c) in-app controls only.
   The choice decides what "center-configurable" means operationally and how a
   configuration travels between a center's machines.
3. **Q3 — Enforcement semantics: block vs. flag, and where each acts.** "Block" has a
   natural seam: merge ancestry-incompatible pairs into the `kin` conflict structure
   (`fillGroupMembers.R:75`) so candidate selection can never co-place them — cheap, and
   the search machinery is untouched. "Flag" needs a different surface: groups form, and
   incompatible pairings are annotated afterward (a violations table, a group-view column,
   the Genetic Diversity heatmap, or a formation-time notice). Is severity per-rule
   (each rule declares block|flag, per the issue's "blocking or flagging … as configured")?
   And are rules sex-aware — enforced only on potential breeding pairs (male × female,
   mirroring how `ignore = list(c("F","F"))` already exempts female-female kinship), or on
   whole-group composition regardless of sex, since geographic composition is a group-level
   property? The two readings produce different groups.
4. **Q4 — Override mechanism and audit trail.** What is overridden — one rule for one
   pairing, one rule for one run, or the whole guardrail? Is a free-text reason required at
   override time? For the audit trail, the established mold is #150's confirm gate +
   downloadable manifest (session-scoped, user-directed, CRAN-safe): a record naming the
   rule, the animals, the timestamp/user, and the stated reason, riding the group-formation
   download outputs. A *persistent* audit log would be new ground (CRAN forbids writes
   outside user-designated locations) — if wanted, it must be user-directed like every
   other write. The plan must also decide whether an overridden-flag state is visible in
   the group views themselves, so the override is not invisible downstream.
5. **Q5 — Enforcement surfaces.** The issue names candidate-group construction
   (`groupAddAssign()` / modBreedingGroups). Does the same rule model also apply to the
   mate-pair surface (`modMatePair`, #151), which evaluates exactly the pairings the
   guardrail is about? And script-API parity: which exported, script-callable functions
   carry the guardrail (the app-only pattern is a module-contract smell; every recent
   feature shipped exported functions first)?
6. **Q6 — Level vocabulary and unknowns.** Does the rule model operate on
   `convertAncestry()`'s 6 levels only? Resolve the `BORDERLINE_HYBRID` discrepancy (§3):
   extend `convertAncestry()`, drop the branch, or keep the rule model independent of
   `getIndianOriginStatus()`. How do UNKNOWN/NA ancestries behave — compatible with
   everything (permissive), incompatible with rule-bearing classes (conservative), or
   configurable per-rule? A permissive default silently defeats the guardrail in colonies
   with sparse ancestry data; a conservative default may block most formations in the same
   colonies. Also: pedigrees with **no** `ancestry` column at all (the `qcPed` case) — the
   guardrail must degrade to today's behavior loudly or quietly, and the plan must say
   which.
7. **Q7 — Zero-behavior-change default and performance.** With no rules configured,
   group formation must be byte-identical to today (the #153 D6 / #167 D7 precedent —
   existing tabs and existing function results unchanged). Block-mode rules shrink the
   candidate graph (cheap); flag-mode annotation must not perturb the stochastic search or
   its RNG stream (same seed path ⇒ same groups, with or without flag-only rules) — the
   plan needs an explicit test for RNG-stream neutrality.
8. **Q8 — UI surface placement.** `modBreedingGroups`' control panel is already dense
   (`R/modBreedingGroups.R:40-128`). Where do rule status, violations, and override
   controls live — a collapsible section in the existing tab, a formation-time modal
   (confirm-gate mold), or a companion view beside the Genetic Diversity heatmap? Fixture
   and tutorial implications ride Q8: ancestry-bearing test fixtures must be added or
   extended (§3 gap), and the tutorial/article checklist (S436) applies to whatever UI
   ships.
9. **Q9 — Slice decomposition.** Expected shape (subject to the plan): rule-model +
   reader/validator slice (fixtures first, exported functions, no UI); enforcement slice
   (block semantics through the conflict-list seam + flag computation, script-callable);
   override + audit-manifest slice (confirm gate, manifest, downloads); UI wiring + docs
   slice (modBreedingGroups integration, legend/status, tutorial). Each slice one session,
   strict TDD, `AskUserQuestion`-gated phases.

**Hard constraints carried into the plan regardless of Q answers:** with no rules
configured, all existing behavior — `groupAddAssign()` results, module outputs, existing
tabs — changes zero; no writes outside user-designated locations (CRAN policy —
user-directed persistence only, the #150 manifest mold); the guardrail informs and records,
it never silently vetoes curator judgment (the issue's own language — an override path is
part of the feature's definition, not an add-on); ancestry vocabulary goes through
`convertAncestry()`'s standardized levels, with the Q6 discrepancy resolved explicitly, not
inherited; any *new* displayed statistic triggers the citation checklist (issue #120), and
NEWS.Rmd entries use plain colony-manager language (S628); module changes respect
`docs/architecture/module-contract.md` (enforced by `test_moduleContract.R`).

## 5. Next actions

1. **Next #168 session:** write `docs/planning/issue168-ancestry-guardrails-plan.md`
   answering Q1–Q9 as ratified, numbered decisions with a vertical-slice list and per-slice
   completion criteria (the #152/#153/#167 mold). That session is a planning session: the
   plan is the deliverable; close out without implementing (SESSION_RUNNER FM #18/#19).
2. **Implementation sessions:** one slice per session, strict TDD, only after the plan is
   ratified.
3. This session (S761) comments the narrowing onto issue #168 (owner-ratified via the §1
   `AskUserQuestion`) and closes out. Deliberately no new `BACKLOG.md` item (§1, divergence
   note).
