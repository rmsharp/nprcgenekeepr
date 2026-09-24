## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Mate-Pair Ancestry Guardrails Plan — extending the #168 rules machinery to `reportMatePairs()` / `modMatePair`

**Session:** S773 (2026-09-23) · **Workstream:**
`docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` · **Type:** design/architecture
document, matching the #133/#136/#137/#145–#153/#167/#168 precedent — **zero `R/`/`tests/`/`man/`
changes this session.** Tracked by GitHub issue **#169** (opened this session; see §11).
This is the "small design gate" that `docs/planning/issue168-ancestry-guardrails-plan.md` §5
("Deferred (recorded, NOT ratified)") and D5 said the mate-pair surface needed before any code,
and that `BACKLOG.md` carried as a DECISION NEEDED item from S762 (extracted S769 when #168
closed). Implementation is gated on §11's ratification; each §5 slice is a separate strict-TDD
session.

---

## 1. Context

### 1.1 What is being asked

#168 (closed S769, v1 complete) made breeding-group **formation** ancestry-aware: a center
uploads a rules file (unordered pairs of the six standardized ancestry levels, each `block` or
`flag`), `groupAddAssign(ancestryRules =)` never co-places a blocked pair, an "Ancestry" tab
reports what the rules matched, and a per-rule, per-run override with a required reason plus a
downloadable audit manifest keeps the guardrail from silently vetoing curator judgment. The
**Mate Pair Analysis** tab (issue #151) answers a different question — "which individual
male × female pairs are eligible" — and is still ancestry-blind: a curator can be shown an
INDIAN × CHINESE pair as eligible even though the same center's rules forbid those animals
sharing a group. This plan extends the shipped rules machinery to that surface.

### 1.2 What is already decided (do not re-litigate)

Carried verbatim from #168's hard constraints (its plan §1.2), because this feature inherits them:

- **Zero behavior change with no rules configured** — `reportMatePairs()` results and the
  Mate Pair Analysis module's outputs are unchanged when no rules are supplied.
- **No writes outside user-designated locations** (CRAN policy) — the manifest is a
  `downloadHandler`, like every other export in the app.
- **The guardrail informs and records; it never silently vetoes curator judgment** — an
  override path is part of the feature's definition.
- **Vocabulary is `convertAncestry()`'s six standardized levels** (D6 of #168), independent of
  `getIndianOriginStatus()`; the package takes no hardcoded stance on UNKNOWN/OTHER animals.
- **Issue #120 citation checklist**, **plain-language NEWS (S628)**, **module contract**
  (`docs/architecture/module-contract.md`, enforced by `test_moduleContract.R`).

### 1.3 What this session verified directly

Every load-bearing claim below was read from source or measured this session (HEAD `aa5bfde9`).

- **`reportMatePairs()`** (`R/reportMatePairs.R:96`) composes `kinMatrix2LongForm(removeDups =
  TRUE)` → `filterPairs()` (same-sex pairs dropped, `:118-122`) → an age screen (`:142-149`) →
  a user-exclude screen (`:151-154`), then enriches the survivors with marker kinship and
  per-parent genetic-value columns (`:165-188`) and returns `list(pairs, excluded)` (`:191`).
  `excluded` has columns `sireId, damId, reason` and a **closed two-reason vocabulary** — a pair
  failing the age screen never reaches the user-exclude screen, so each dropped pair carries
  exactly one reason (roxygen "Exclusion transparency (D5)", `:31-36`).
- **`modMatePairServer`** (`R/modMatePair.R:152`) takes `pedigree, kinshipMatrix,
  markerKinshipMatrix, geneticValues`; its `analyze` observer (`:176-222`) calls
  `reportMatePairs()` once per click and stores the result in `matchResults`; the Eligible Pairs
  export writes exactly the DT-filtered rows (`:236-253`, `pairsTable_rows_all`); **the Excluded
  tab has no download button** (`:75-80`); it returns `list(pairs, excluded, isReady)` (`:274-284`).
- **The #168 v1 machinery is shipped and reusable unchanged:** `checkAncestryRules()`
  (`R/checkAncestryRules.R:41`), `readAncestryRules()`, `.ancestryPairKey()`
  (`R/ancestryOverrides.R:33`), `.checkAncestryOverrides()` (`:53`), `.effectiveAncestryRules()`
  (`:125`), `.buildAncestryOverrideManifest()` (`:160`, needs only `report$violations$rule` and
  `report$coverage`, `:170-176,188-193`), `reportAncestryViolations()`
  (`R/reportAncestryViolations.R:65`; returns `list(violations, coverage)`).
- **THE architectural fact: the rules live only inside `modBreedingGroups`.** They are read from
  that module's own `input$ancestryRulesFile` into a module-local reactive
  (`R/modBreedingGroups.R:352-377`, `ancestryRulesForRun` `:384-392`); the module's return list
  (`:1110-1128`) carries no rules (`groups, nGroups, score, unassigned, groupKinship`);
  `appServer.R` has **zero** ancestry wiring (its only consumer of `bgResults` is
  `bgResults$groups()`, `R/appServer.R:433`); and #168's own plan declared "no wiring change —
  the module is self-contained" (its §4). So `modMatePairServer` has today no way to receive
  rules.
- **The override path in #168 is a two-call contract** (Learning 780: enforcement takes the
  EFFECTIVE rules, reporting takes the ORIGINAL rules plus overrides). That contract exists
  because `groupAddAssign()` (search) and `reportAncestryViolations()` (report) are two
  functions. `reportMatePairs()` is one function that both screens and reports, so the trap can
  be designed out (D6).
- **The shipped fixtures are sufficient — no new fixture file is needed.**
  `inst/extdata/examples/example_ancestry_pedigree.csv` (10 animals) and
  `example_ancestry_rules.csv` (INDIAN×CHINESE block, INDIAN×HYBRID block, INDIAN×UNKNOWN flag,
  INDIAN×OTHER flag), run through `qcStudbook()` + `kinship()` + `reportMatePairs(minAge = 1)`
  (measured), give **25 male×female pairs, 0 excluded**; matching the rules by hand-derivable
  level keys gives **5 block** (C1×I2 [CHINESE male × INDIAN female], I1×C2, A1×C2, I1×H1,
  A1×H1), **3 flag** (I1×U1, A1×U1, O1×I2) and **17 unmatched** — both orientations of an
  unordered rule are present. Post-QC ancestry counts: CHINESE 2, INDIAN 3, HYBRID 1, JAPANESE
  2, OTHER 1, UNKNOWN 1 (all ten animals appear in a candidate pair); every animal is age ≥ 21,
  so no age exclusion interferes.
- **Composing today with `reportAncestryViolations()` does not scale.** A mate pair is a
  two-animal "group", so `reportAncestryViolations(<one 2-vector per pair>, ped, rules)` works
  today with zero code changes — measured **2.39 s for 5,000 two-animal groups** (≈ 0.48 ms per
  pair; the function loops per group and rbinds). #151's benchmark (its §2.6) measured
  **315,023** candidate pairs for the alive-scoped `examplePedigree` and **1,744,722** unscoped;
  linear extrapolation (an **estimate**, not a measurement) is ≈ 150 s and ≈ 14 min. Result: a
  vectorized pair matcher is required, not a loop over the group reporter (D6).
- **Collision greps (§4's proposed names):** `matchAncestryPairs`, `matePairAncestry*`,
  `ancestrySeverity`, `ancestryRule` (as a column) — no hits in `R/`, `tests/`, `NAMESPACE`,
  `_pkgdown.yml`. **Two overlaps, both harmless but recorded:** `ancestryStatus` and
  `ancestryCoverage` already occur as module-local Shiny output ids in `R/modBreedingGroups.R`
  (a different module namespace from a data-frame column or a list element).

---

## 2. Evidence-based inventory

| Symbol / file | Location | Role in this feature | Changed? |
|---|---|---|---|
| `reportMatePairs()` | `R/reportMatePairs.R:96` | the kernel being extended (D3, D6) | **yes** — 2 optional args |
| `emptyMatePairsFrame()` / `emptyMateExcludedFrame()` | `R/reportMatePairs.R:195,206` | zero-row shape helpers; must gain the ancestry columns when rules are active | yes (internal) |
| `modMatePairServer` / `modMatePairUI` | `R/modMatePair.R:152,23` | the app surface (D7, D9) | **yes** |
| `modBreedingGroupsServer` return list | `R/modBreedingGroups.R:1110` | must expose the loaded rules (D7) | **yes** — +1 reactive |
| `appServer()` | `R/appServer.R:420-427,466-472` | thread `bgResults$ancestryRules` into `modMatePairServer` | **yes** — 1 arg |
| `test_moduleContract.R` | `tests/testthat/test_moduleContract.R:54-58,97-104` | BG `names` gains `ancestryRules`; matePair `args` gains `ancestryRules` | yes |
| `checkAncestryRules()` / `readAncestryRules()` | `R/checkAncestryRules.R`, `R/readAncestryRules.R` | reused unchanged (D1) | no |
| `.ancestryPairKey()`, `.checkAncestryOverrides()`, `.effectiveAncestryRules()` | `R/ancestryOverrides.R:33,53,125` | reused unchanged (D6, D8) | no |
| `.buildAncestryOverrideManifest()` | `R/ancestryOverrides.R:160` | reused; fed a mate-pair-derived `report` (D8) | no (BG manifest byte-identical) |
| `.ancestryOverrideWarningText` | `R/ancestryOverrides.R:14` | group-formation wording — NOT reused; a sibling constant is added (D8) | no |
| `reportAncestryViolations()`, `.ancestryConflictPairs()` | `R/reportAncestryViolations.R:65,178` | group-shaped; NOT reused as the mate-pair kernel (measured cost, §1.3); coverage shape mirrored | no |
| `groupAddAssign()`, `fillGroupMembers()` & seam | `R/groupAddAssign.R` | the group surface | **no** |
| Example fixtures | `inst/extdata/examples/example_ancestry_{pedigree,rules}.csv` | sufficient as-is (§1.3) | no |
| E2E CI group regex | `.github/workflows/shinytest2.yaml:149` (`^e2e-mate-pair-analysis-module`) | a new file named `test-e2e-mate-pair-analysis-module-ancestry.R` is in an existing group **by construction** (the #168 mold) | no |
| User docs | `NEWS.Rmd:424-428` (Mate Pair Analysis), `vignettes/articles/colony-manager-guide.qmd:523-566` (ancestry) and `:560` (Mate Pair Analysis) | updated at the slices that ship visible behavior (§9) | yes (docs) |
| Callers (grep, R/tests/inst/vignettes/docs) | `reportMatePairs(`: `R/modMatePair.R`, `tests/testthat/test_{modMatePair,reportMatePairs,reportAncestryViolations}.R`, `vignettes/a2interactive.{Rmd,R}`, `NEWS.Rmd`; `modMatePairServer(`: `R/appServer.R`, `tests/testthat/test_modMatePair.R`; `modBreedingGroupsServer(`: `R/appServer.R` only | blast-radius list for the slices | — |

Net: **everything the rules need already exists; what is missing is the pair-level kernel, a way
for rules to reach the Mate Pair module, and the module's own override/results surface.**

---

## 3. Design decisions

Ten decisions. D1, D4, D5, D6, D8, D10 are **forced or evidence-determined** (reasoning listed
for the implementing sessions). D2, D3, D7, D9 are **genuine judgment calls**, ratified in §11
via one `AskUserQuestion` round (four questions, one call); the owner selected this document's
recommended option in all four.

**D1 (forced — inherit). The rule model, vocabulary, validator and degradation behavior are
#168's, unchanged.** Rules are `checkAncestryRules()`'s table — unordered pairs of the six
standardized levels, each `block` or `flag`, self-pairs legal — so a rule matches a pair
whichever animal is the sire and whichever the dam (both orientations are in the §1.3
fixture). #168's D3 sex-blind question has **no separate mate-pair answer**: every candidate
pair is male × female by construction (`filterPairs()`, `:119-122`), so sex-blind and
M×F-only coincide. An animal whose level no rule names, or whose level is `NA`, participates in
no conflict (permissive by construction, D6 of #168) and is counted as *uncovered* in the
coverage summary. **Script surface:** non-`NULL` rules on a `ped` with no `ancestry` column
`stop()`s, message parity with `reportAncestryViolations()` (`R/reportAncestryViolations.R:69`).
**App surface:** the module shows the inactive notice and runs exactly as today (never fatal).
The validator's UNKNOWN/OTHER asymmetry warning is inherited free.

**D2 (judgment call — ratified). `block` in a *report* means: the pair leaves `pairs` and enters
`excluded` with reason `"ancestry rule"` and the matched rule; `flag` keeps the pair in `pairs`,
annotated.** `checkAncestryRules()`'s own documentation defines `block` as "exclude the pairing"
and `flag` as "annotate it afterward"; Mate Pair Analysis has no formation loop, so the faithful
mapping of exclude is "not in the Eligible list", and the Excluded tab already exists for exactly
"pairs dropped, with a reason". An overridden block rule's pairs stay in `pairs`, annotated
`overridden` — never silently absent, never silently vetoed (D8). **Declined:** annotate-only
(nothing is ever removed) — makes `block` meaningless on this surface and leaves an "Eligible
Pairs" list that can contain pairs the center's own rule says must never breed.

**D3 (judgment call — ratified). The script API is an extension of `reportMatePairs()`: two new
optional arguments, `ancestryRules = NULL` and `overriddenRules = NULL`; no new exported
function.** This mirrors how `groupAddAssign()` gained `ancestryRules` (the shipped #168
precedent), keeps one call for script users, and satisfies script-API parity before any UI
(Slice 1 ships the function; the module comes after). `overriddenRules` follows
`reportAncestryViolations()`'s convention (a data frame naming rules by `ancestry1`/`ancestry2`;
an override that names no real rule must fail loudly, D4 of #168); whether a `reason` column is
accepted/required at the exported layer, and whether a *flag*-rule override is rejected, is
fixed at Slice 1 RED (the GUI gate and manifest always require a reason). **Declined:** a new
post-processing function taking `reportMatePairs()`'s result — more composable and
zero-risk to the existing function, but one more export (`NAMESPACE`/`_pkgdown`/NEWS surface) and
a two-step call for every script user, for a screen that is not independently useful.

**D4 (forced — invariants, made mechanical).** These are the properties Slice 1's RED must pin;
they are the whole safety story:
1. **Zero change:** `ancestryRules = NULL` (default) ⇒ `identical()` to today's result — the
   frames, their column names and order, and the list's names.
2. **Additivity:** with rules, every `excluded` row whose reason is `"under minimum age"` or
   `"user-excluded"` is identical to the no-rules `excluded` row; ancestry only ever *takes rows
   out of what would have been `pairs`* (block) or *annotates* them (flag/overridden).
3. **Conservation:** the set of `(sireId, damId)` pairs in `pairs ∪ excluded` is the same with
   and without rules — rules move and label pairs, never drop or invent them.
4. **Shape depends on the argument, never on the data:** any non-`NULL` `ancestryRules` — even a
   valid zero-rule table (`checkAncestryRules()` accepts one) — yields the ancestry columns and
   the coverage element, all `NA`/zero-effect when nothing matches. A result whose shape changed
   with the *content* of the pedigree would be a silent-shape-drift trap for the module and for
   scripts.
5. **Classification:** every block-matched, non-overridden pair is absent from `pairs` and
   present in `excluded` with reason `"ancestry rule"`; every overridden pair is in `pairs` with
   status `overridden`; every flag pair is in `pairs` with status `violation`.

**D5 (forced — screen order and evaluation universe).** The ancestry screen runs **last**: after
the age screen and the user-exclude screen, on the surviving pairs only — inserted between
`R/reportMatePairs.R:154` and the enrichment block at `:165`, so marker/GV enrichment is never
computed for blocked pairs. Forced by D4-2 and the closed-vocabulary invariant: a pair that
fails several screens keeps the reason it would have had without rules, and each dropped pair
still carries exactly one reason. Consequence, to be documented and test-pinned: a pair excluded
for age or user reasons is **not counted** as an ancestry match (manifest pair counts mean
"otherwise-eligible pairs the rule matched"). **Coverage universe:** the distinct animals in
`pairs ∪ excluded` — the animals the report actually considered (in the §1.3 fixture: all ten;
`JAPANESE` 2 animals is the only uncovered level, so `nUncovered` = 2).

**D6 (forced — kernel mechanics).** (a) A **vectorized pair matcher**, not a per-pair loop and
not `reportAncestryViolations()` over 2-animal groups (measured cost, §1.3): look up both
animals' levels with the same normalization as the group reporter
(`toupper(trimws(as.character(ped$ancestry[match(id, ped$id)])))`, since post-QC ancestry is a
factor), key the pair with `.ancestryPairKey()`, and `match()` against the rules' keys — O(n)
over ≥ 10^6 rows, self-pairs (`HYBRID`×`HYBRID`) handled by the same key. (b) **One call, one
rules input:** `reportMatePairs()` receives the ORIGINAL rules plus `overriddenRules` and applies
the downgrade internally, so Learning 780's miswiring class (passing effective rules to the
reporter, or original rules to the enforcer) **cannot occur by construction** on this surface;
the manifest, likewise, is fed the original rules plus the overrides. (c) New columns are
appended **after** the existing eight (`damGu` stays column 8), so consumers indexing the
existing columns are undisturbed when rules are active. Proposed vocabulary (exact list fixed at
Slice 1 RED; names follow `reportAncestryViolations()` verbatim so no consumer renames a
concept, module-contract rule 3's spirit): `pairs` gains `ancestryRule` (the matched rule's
sorted `"LEVEL-LEVEL"` key, else `NA`), `ancestrySeverity` (`block`/`flag`, else `NA`),
`ancestryStatus` (`violation`/`overridden`, else `NA`); `excluded` gains `ancestryRule`
(`NA` for the age/user reasons); the return list gains `ancestryCoverage`
(`ancestry`, `n`, `covered` — the group reporter's coverage shape and level order).

**D7 (judgment call — ratified). Rules reach the Mate Pair Analysis module from Breeding
Groups' upload; each surface owns its own overrides.** `modBreedingGroupsServer` returns one new
reactive, `ancestryRules` (the validated rules table, `NULL` before an upload — the value it
already computes as `ancestryRulesData`, `R/modBreedingGroups.R:352`); `appServer` passes it as
a new `ancestryRules` argument of `modMatePairServer`; each module applies its own
column-present check (`ancestryRulesForRun`-style). One upload means one policy file per
session — the #168 D2 premise ("the center maintains one rules file"), and it keeps the audit
manifest's "rules in effect" unambiguous. Overrides, gate, reasons and manifest are **per
surface**: a decision to relax a rule for group housing and a decision to allow a breeding pair
are different decisions needing different audit records; the shipped primitives are reused
unchanged. Contract accounting: the new BG return element has a consumer (rule 4 — it is read by
`appServer`, then by `modMatePairServer`); `test_moduleContract.R`'s two rows are updated in the
same slice; the new `modMatePairServer` parameter is read (rule 6). **Declined:** shared
overrides with Breeding Groups owning the gate (coupled audit story; the shipped gate wording is
about "group formation"; a Breeding Groups-tab action silently changing another tab's results);
an independent upload in the Mate Pair tab (smallest blast radius, but the same file uploaded
twice, two tabs able to hold different policies, and ≈150 lines of upload/status/override UI
duplicated).

**D8 (forced — override/audit primitives).** Per-rule, per-run overrides with a required
non-empty reason, block rules only, unordered/case-insensitive rule match, session-scoped,
stale overrides cleared when the rules change — #168's D4 semantics through
`.checkAncestryOverrides()` and `.buildAncestryOverrideManifest()` **unchanged** (Breeding
Groups' manifest stays byte-identical). New for this surface: (a) a sibling gate-warning
constant naming the Mate Pair report rather than group formation — **proposed text**, owner
ratifies at Slice 3's RED gate (the existing constant's own comment requires owner
ratification of wording): *"Overriding this ancestry rule lets the Mate Pair Analysis list pairs
the rule would otherwise exclude, for this run only. The rule stays in your rules file, and every
pair it matches is still reported, marked "overridden". Your stated reason is saved in the
downloadable audit manifest. Confirming that this override fits your colony's genetic-management
and research commitments is your responsibility, not this tool's."*; (b) the module assembles the
manifest's `report` argument as `list(violations = <the ancestry-matched pairs' rule keys>,
coverage = <the run's ancestryCoverage>)` (the builder reads only those, `:170-176`); (c) each run
**snapshots** the rules and overrides in effect at the "Find Eligible Pairs" click (the #150
params-snapshot mold, Learning 780/#150) so a later override or upload can never rewrite an
earlier run's tables or manifest.

**D9 (judgment call — ratified). UI: inline annotations plus a small Ancestry tab.** Flagged
and overridden pairs show as sortable/filterable columns in Eligible Pairs (and so flow into the
existing CSV export with no export change — the export writes the DT-filtered frame); a blocked
pair appears on the Excluded tab with reason `"ancestry rule"` and its rule; a **collapsed
"Ancestry Guardrails" section** in the configuration panel carries the one-line status ("No
ancestry rules loaded" / "N block, M flag rule(s); K animal(s) uncovered" / the no-column
inactive notice) and the per-rule override control (behind the confirm gate; the status must say
the override applies to *this tab*); a new **"Ancestry" tab** holds the coverage summary and the
audit-manifest download. Violations are **not** re-listed in a separate table — the inline
columns are the list. **Declined:** mirroring Breeding Groups fully (a duplicate violations
table); config-section-only (results too easy to miss).

**D10 (forced shape — slices).** Three slices, each one session, strict TDD,
`AskUserQuestion`-gated phases (§5). Order is dependency-forced: the module consumes the kernel;
the override/audit surface decorates the module. Script-callable value accrues from Slice 1,
the app applies rules from Slice 2, and Slice 3 completes parity — the FM #25 test ("if I stop
here, is something working?") passes at every boundary.

---

## 4. Interface catalog (proposed — for the implementing sessions, not built this session)

| Interface | Kind | Input | Output | Error | Consumers |
|---|---|---|---|---|---|
| `reportMatePairs(ped, kmat, markerKmat, geneticValues, minAge, populationIds, exclude, ancestryRules = NULL, overriddenRules = NULL)` | Extended existing `@export` (D3) | existing args + validated-or-raw rules table (re-validated via `checkAncestryRules()`) + optional overrides | with `NULL` rules: today's `list(pairs, excluded)` byte-identical (D4-1). With rules: `pairs` +`ancestryRule/ancestrySeverity/ancestryStatus`, `excluded` +`ancestryRule` and reason `"ancestry rule"`, list +`ancestryCoverage` (D6; exact columns fixed at Slice 1 RED) | `stop()` on non-`NULL` rules when `ped` has no `ancestry` column (D1); malformed rules (`checkAncestryRules()` errors); an override naming no real rule (D3) | `modMatePairServer`, script users |
| `.matchAncestryPairs(id1, id2, ped, rules)` | New `@noRd` vectorized helper (D6a; file placement the implementing session's choice) | two id vectors of equal length, `ped` with `ancestry`, validated rules | per-row matched rule key and severity (both `NA` when no match), plus the normalized levels | (internal) | `reportMatePairs()` |
| `modBreedingGroupsServer` return gains `ancestryRules` | Extended existing module return (D7) | (no new inputs) | reactive: the validated rules table, or `NULL` before an upload | none new (upload failures already notify and yield `NULL`, `:369-375`) | `appServer` → `modMatePairServer` |
| `modMatePairServer(id, pedigree, kinshipMatrix, markerKinshipMatrix, geneticValues, ancestryRules = NULL)` | Extended existing module (D7, D9) | new optional reactive `ancestryRules` | existing return list unchanged (`pairs`, `excluded`, `isReady`) — **module-contract rule 4: nothing new is returned until a consumer exists** | upstream absence is `req()`, malformedness surfaces (rule 5) | `appServer` |
| `.matePairAncestryOverrideWarningText` | New internal constant (D8a), `.ancestryOverrideWarningText` mold | — | the ratified gate wording, shown in the modal and copied verbatim into each manifest row | — | Slice 3 gate + manifest |
| `.buildAncestryOverrideManifest()` | **Unchanged** (D8) | rules as written; overrides; a `list(violations, coverage)`-shaped report; the mate-pair warning text | the per-rule audit manifest | as today | Slice 3 manifest `downloadHandler` |

Vocabulary notes: "override" always means the per-rule, per-run mechanism (never a data edit);
"guardrail" is UI/documentation language, not an API name; on this surface `block` means
"excluded from the Eligible list", which the article and NEWS must say in plain words because it
differs from group formation's "never placed together".

---

## 5. Implementation plan — vertical slices (each its own future session)

**This design session implements no slice.** Every slice: strict TDD (RED→GREEN→REFACTOR,
`AskUserQuestion`-gated), full-suite regression + lint close-out per `CLAUDE.md`, and the 5-file
per-commit cap (a slice touching more files lands as several commits; the RED commit is
tests-only). Per-slice completion criteria name their verification surface; none of these
surfaces exercises LabKey-connected operation, which no slice claims.

### Slice 1 — Kernel: `reportMatePairs(ancestryRules, overriddenRules)` (script-callable only)
**Touches:** `R/reportMatePairs.R` (+ the `.matchAncestryPairs()` helper, placement free),
`tests/testthat/test_reportMatePairs.R` or a new `test_reportMatePairsAncestry.R`, regenerated
`man/reportMatePairs.Rd` (`devtools::document()`), `NEWS.Rmd` (plain-language, S628).
**Done when:** (1) D4-1 identity test — `NULL` rules vs. argument omitted vs. pre-change output,
`identical()`; (2) D4-2/D4-3 — age/user `excluded` rows and the `pairs ∪ excluded` pair set are
unchanged by rules; (3) hand-derived fixture counts (§1.3): no override ⇒ `pairs` 20 (3 flagged,
`violation`), `excluded` 5 (each with its rule key); overriding CHINESE×INDIAN ⇒ `pairs` 23 (3
`overridden`, 3 flagged), `excluded` 2; both orientations of the unordered rule matched; (4) a
valid zero-rule table yields the columns/element with nothing moved (D4-4); (5) coverage equals
the hand-derived census (CHINESE 2, INDIAN 3, HYBRID 1, JAPANESE 2, OTHER 1, UNKNOWN 1;
`covered` FALSE only for JAPANESE); (6) `stop()` paths — no `ancestry` column, malformed rules,
an override naming a non-existent rule; (7) a scaling guard — no per-pair R loop (a synthetic
≥ 10^5-pair frame completes within a generous, deterministic bound); (8) the existing
`reportMatePairs` and `modMatePair` test corpus passes **unchanged**; full suite + `lintr`
clean.
**Surface:** local test suite (`NOT_CRAN=true`, `load_all()` first) + `devtools::check()`. This
surface cannot demonstrate app behavior — none is claimed until Slice 3.

**Outcome (S774, shipped — `eb104544`, `f4ca894f`, `f852fcb9`):** as designed, with these facts
fixed at RED/GREEN by owner gates. `overriddenRules` takes `ancestry1`/`ancestry2` like
`reportAncestryViolations()`; an optional `reason` column is accepted and **ignored**; an
override naming no rule, a **flag** rule, a duplicated rule, or given without `ancestryRules` is an
error (messages pinned in `tests/testthat/test_reportMatePairsAncestry.R`). Columns are exactly
D6c's proposal (`pairs` +`ancestryRule`/`ancestrySeverity`/`ancestryStatus` after `damGu`;
`excluded` +`ancestryRule`; the list +`ancestryCoverage`, six fixed level rows). An
`NA`/unrecognised-level animal matches nothing and is counted in **no** coverage row (this refines
D1's looser "counted as uncovered"). Validation runs once, before the early returns, so the
UNKNOWN/OTHER warning fires once. Helpers `checkMatePairAncestryArgs()`, `emptyMateResult()` and
`matchAncestryPairs()` (no leading dot) live in `R/reportMatePairs.R`; `.ancestryCoverage()` is
shared with `reportAncestryViolations()` (`R/reportAncestryViolations.R`). Measured: 102,400 pairs
in 0.77 s with rules vs 0.89 s without. **For Slice 2:** `reportMatePairs()` now `stop()`s on rules
with no `ancestry` column, so the module must check for the column FIRST and show the inactive
notice instead of passing the rules (D1, app surface). The manifest `report` adapter (D8b) can be
built from `pairs$ancestryRule` plus `excluded$ancestryRule` (overridden pairs stay in `pairs`).

### Slice 2 — Rules delivery + applying rules in the Mate Pair module (no override gate yet)
**Touches:** `R/modBreedingGroups.R` (return `ancestryRules`), `R/modMatePair.R` (new argument,
collapsed "Ancestry Guardrails" status section, rules snapshot at "Find Eligible Pairs", results
tables), `R/appServer.R` (thread the reactive), `tests/testthat/test_moduleContract.R` (BG
`names` +`ancestryRules`; matePair `args` +`ancestryRules = shiny::reactive(NULL)`),
`tests/testthat/test_modMatePair.R`, an `appServer` wiring test (mold: the `bgResults$groups()`
test at `tests/testthat/test_appServer_server.R:606`), `NEWS.Rmd`. (>5 files ⇒ several commits.)
**Done when:** BG returns the loaded rules (`NULL` before upload) and the contract test passes
with the updated rows; with rules loaded and a pedigree carrying `ancestry`, a run shows blocked
pairs on Excluded (rule visible) and flags as columns in Eligible Pairs; **with no rules loaded,
`pairs()`/`excluded()` and every existing tab are byte-unchanged** (D4-1 at module level); a
pedigree with no `ancestry` column shows the inactive notice and runs exactly as today; a rules
upload or override-free state change *after* a run does not rewrite that run's tables (snapshot,
D8c); the Breeding Groups tab's own behavior and e2e are unchanged; full suite + lint clean.
**Surface:** `shiny::testServer()` tests + local suite + `devtools::check()`. `testServer` cannot
prove the live cross-tab reactive graph through `appServer` — that is Slice 3's e2e, and no
live-wiring claim is made before it.

**Outcome (S775, shipped — RED `53e172d6`, correction `fdb705bd`, GREEN `402549a7`/`e4401806`,
REFACTOR `4be16a12`):** as designed, with these facts fixed by owner gates. The Mate Pair config
panel carries a collapsed "Ancestry Guardrails" toggle (Breeding Groups' layout) with the status
line ALWAYS visible and an explainer inside the collapsed panel — **Slice 3 puts the override
control inside that same panel; nothing moves.** Status texts: none = "No ancestry rules loaded. Load
a rules file on the Breeding Groups tab to apply it here." (module-local); active / inactive are
Breeding Groups' own texts via one shared `.ancestryStatusLine()` (`R/reportAncestryViolations.R`).
`modBreedingGroupsServer` returns `ancestryRules = reactive(ancestryRulesData())` — the validated
table as loaded, deliberately NOT `ancestryRulesForRun()`; `appServer` passes `bgResults$ancestryRules`
verbatim (a BG return without the element gives an explicit NULL). The module's own
`ancestryRulesForRun()` (rules only when loaded AND the pedigree has an `ancestry` column) feeds
`reportMatePairs(ancestryRules =)` at the click, so the stored `matchResults` IS the run snapshot
(D8c). **For Slice 3:** `matchResults` holds ONLY the kernel result today (its `ancestryCoverage` is
in it) — the manifest also needs the run's rules and overrides, so extend what the click stores (or
add a sibling `reactiveVal` set at the click); never read the live reactives at download time. The
zero-pairs alert keeps its text byte-for-byte and appends "N pair(s) were excluded by ancestry rules
-- see the Excluded tab." only when at least one pair was excluded by a rule. Dragon 10 resolved:
the run-time re-validation warning is left unmuffled, as Breeding Groups does (console only; the
upload notification is the user-facing surface), and pinned. Dragon 5 stands: `test_modMatePair.R`'s
two-reason assertion is untouched (it supplies no rules). Two measured non-obvious facts: an observer
error under `testServer()` destroys the module session, so a click-time error test can pin only the
surfaced warning (Learning 786); and the scratch live run (a scratch-installed build, one-off, not
committed) confirmed the real cross-tab graph — 20 eligible / 5 excluded, the 11-column CSV, the
live status after loading rules on Breeding Groups, zero console errors — which Slice 3's committed
e2e must still own.

### Slice 3 — Override gate + audit manifest + e2e + documentation
**Touches:** `R/modMatePair.R` (per-rule override select + confirm-gate modal with required
reason, per-surface override state, the "Ancestry" tab: coverage + manifest `downloadHandler`
via `getDatedFilename()`), `.matePairAncestryOverrideWarningText` (+ the `report` adapter),
tests, a new `tests/testthat/test-e2e-mate-pair-analysis-module-ancestry.R`, `NEWS.Rmd`,
`vignettes/articles/colony-manager-guide.qmd`. **Owner ratifies the gate wording at this
slice's RED gate** (D8a).
**Done when:** `shinytest2` drives: load the ancestry fixture → upload the example rules on the
Breeding Groups tab → Mate Pair status shows the counts → run → 5 blocked pairs on Excluded with
their rules, 3 flagged in Eligible → override CHINESE×INDIAN with a reason (gate blocks an empty
reason) → re-run → 3 `overridden` rows visible in Eligible → download the manifest and verify
its content (rule rows, the override and its reason, the verbatim gate wording, pair counts,
census) — zero console errors; Breeding Groups behavior and manifest unchanged; the e2e file is
in the `^e2e-mate-pair-analysis-module` CI group by name (statically pinned by
`test_shinytest2_workflow_coverage.R`); full suite + lint clean. **Close-out includes the
explicit issue #169 close** (v1 complete; any further follow-up is a new item).
**Surface:** `shinytest2` headless Chrome (the Phase 3E bar for this cluster) + local suite +
`devtools::check()`. This surface cannot enforce LabKey-connected behavior or non-headless
browser quirks; neither is claimed.

**Outcome (S776, Slice 3a shipped — RED `09b85a5a`, GREEN `f65410f2`/`15addc42`, REFACTOR
`ae41927b`; 3b remains):** the owner split Slice 3 as the plan's own estimate suggested — **3a =
the module layer (gate + manifest + Ancestry tab, `testServer`-verified), 3b = committed e2e +
article + the #169 close** — and ratified the D8a gate wording **verbatim as proposed**
(`.matePairAncestryOverrideWarningText`, `R/ancestryOverrides.R`). As built: the override
controls (select of not-yet-overridden BLOCK rules, "Override rule...", status, "Clear
overrides") sit inside the collapsed Ancestry Guardrails panel after the explainer; the modal is
the #150/#168 mold (verbatim text, required reason, Cancel/Confirm; a blank reason is an error
notification and the gate stays open); overrides are per tab, reset when the rules reaching the
module change, and stored trimmed; the status reads "N block rule(s) overridden on this tab
this session: ..." (D9's "must say this tab"). The click stores `list(rules, overrides)` in a
sibling `ancestryRun` next to `matchResults` (rules `NULL`, hence no manifest, when the
guardrails were inactive) and passes the ORIGINAL rules plus `overriddenRules` to the kernel —
zero-row overrides when inactive, since the kernel stops on overrides without rules. The
manifest `report` adapter (D8b) is `.matePairAncestryReport(result)`: `violations$rule` =
every ancestry-matched pair's rule key from `pairs` UNION `excluded`, `coverage` = the
result's `ancestryCoverage`. The Ancestry tab holds the guidance / coverage table / "Download
Audit Manifest" (`MatePairAncestryAuditManifest.csv`); guidance is `NULL` once a rules-run is
displayed, else the status line's own no-rules / inactive text, else "Find eligible pairs with
ancestry rules loaded to see the coverage summary and audit manifest here." Testing facts:
a `testServer()` gate is observable only by mocking the package's imported `showModal` /
`showNotification` / `removeModal` (Learning 788). **The live path differs from the fixture
numbers above (Learning 787):** through the real upload a blank ancestry cell is OTHER, not
UNKNOWN (the Input module reads without `na.strings`), so the live counts are INDIAN-UNKNOWN 0 /
INDIAN-OTHER 3 and census OTHER 2 / UNKNOWN 0 — **3b's e2e pins those** (all block/eligible/
excluded counts, 20/5 -> 23/2, are unchanged). Known edges left: a valid zero-rule table makes
the manifest builder stop (Breeding Groups identical); the select-choices builder and modal
are duplicated between the two modules (the REFACTOR shared only the two pure helpers).

**Outcome (S777, Slice 3b shipped — RED `ad5dd344`, GREEN `8526e56b`, REFACTOR `2b59fde6`;
issue #169 complete):** the committed live e2e `tests/testthat/test-e2e-mate-pair-analysis-module-ancestry.R`
(one block, 38 expectations in 13 tagged groups A1-A13) drives this section's done-when list end
to end and pins the LIVE numbers 3a measured (20 / 5 -> override CHINESE-INDIAN -> 23 / 2, a
23 x 11 CSV with 3 `overridden` rows, manifest pair counts 3-2-0-3, census, the verbatim Mate
Pair gate wording, a blank reason refused, the displayed run's manifest not rewritten by a late
override, zero console errors). It passes on the real tree (63/63 with the two sibling ancestry
e2e files) and is in the `^e2e-mate-pair-analysis-module` CI group by name. Because it
characterizes behavior that already existed it could not start RED: the owner chose a
**mutation-proof RED** at the Pre-RED gate — 20 planted seams in 5 throwaway trees, each
caught for its intended cause (unproved by an independent seam: A13 and three manifest shape
checks). The article passage "Ancestry guardrails on this tab" in `colony-manager-guide.qmd`
documents the override step, the Ancestry tab and the manifest. The five generic helpers now
live in `helper-shinytest2.R` (`poll_js()` and friends). **Testing fact (Learning 789):**
shinytest2 0.5.1 `load_all()`s the CHECKOUT from the working directory in the app subprocess, so
scratch-installed mutants are never loaded — a mutant must be a whole tree containing its own
`tests/testthat`. Follow-ups (BACKLOG residue item, none started): the `a2interactive`
demonstration, the zero-rule manifest edge, an Excluded-tab export, and the duplicated gate
code.

---

## 6. Impact analysis

| System | Impact | Action required |
|---|---|---|
| `reportMatePairs()` | Two optional args; `NULL` default `identical()` to today (D4-1); one screen inserted at `:154`–`:165`. | Slice 1; identity test is the guard. |
| `modMatePair` module | +1 argument, +collapsed section, +Ancestry tab; return list unchanged (rule 4). | Slices 2–3; contract test. |
| `modBreedingGroups` | +1 returned reactive (`ancestryRules`); no behavior change; its manifest and e2e untouched. | Slice 2; its existing tests pass unchanged. |
| `appServer.R` | +1 argument on the existing `modMatePairServer` call. | Slice 2; wiring test. |
| `test_moduleContract.R` | Two rows updated (BG `names`, matePair `args`). | Slice 2. |
| `groupAddAssign()` / kernel / harem seam | **Unchanged.** (The harem-sire seam hole, Learning 778, is a separate BACKLOG item and does not apply — mate pairs are not formed by the fill loop.) | None. |
| `checkAncestryRules()`, `readAncestryRules()`, override/manifest primitives | **Unchanged** — reused (D1, D8). | Slice 1/3 verify byte-identity of BG's manifest. |
| `DESCRIPTION` / `NAMESPACE` / `_pkgdown.yml` | **Unchanged** under D3 (no new export); re-confirm at each slice close-out. | Re-verify per slice. |
| Marker/genetic-value enrichment columns | Unchanged; ancestry columns appended after them (D6c). | Slice 1 asserts columns 1–8 order. |
| CRAN write-policy posture | No new write path (manifest is a `downloadHandler`). | Reviewers check no `write.*` outside tests' tempdir. |
| Shipped fixtures / exported data | **Unchanged** — the example ancestry files suffice; `examplePedigree`/`qcPed` are not edited (Dragon 6 of #168 stands). | None. |
| e2e CI registration | By-construction (file-name prefix). | Slice 3. |

---

## 7. Here be dragons

1. **Pair tables are huge; loops are not an option.** #151 measured 315,023 alive-scoped and
   1,744,722 unscoped candidate pairs, and `filterAge()`'s NA-passes semantics means age does
   not bound the table. The matcher must be vectorized (D6a), and the ancestry columns are two
   or three more character columns on up to ~10^6 rows — measure memory at Slice 1 on the
   unscoped case, not only the fixture.
2. **Shape must depend on the argument, never the data (D4-4).** A `pairs` frame that gains
   columns only when something matched will break the DT table, the CSV export and every
   downstream `rbind`. Any non-`NULL` rules ⇒ columns present, even all-`NA`.
3. **Ancestry is a factor after `qcStudbook()`.** Normalize with
   `toupper(trimws(as.character()))` exactly as the group reporter does, or a factor's integer
   codes / stray case will silently mismatch every rule. An `NA` level matches nothing (and is
   *uncovered*, not *covered*).
4. **`convertAncestry()` is not idempotent for UNKNOWN** (§1.3 of #168): a re-standardized
   `"UNKNOWN"` becomes OTHER. The inherited validator warning and the article guidance are the
   countermeasures; do not "fix" the conversion here (QC-behavior change, its own issue).
5. **The `excluded$reason` vocabulary gains a third value.** Anything that enumerates the
   two-value vocabulary must be revisited deliberately: the `roxygen` "closed, enumerable
   vocabulary" text in `R/reportMatePairs.R:31-36`, the article's Excluded-tab description
   (`vignettes/articles/colony-manager-guide.qmd`, "under minimum age or explicitly excluded"),
   and `tests/testthat/test_modMatePair.R:261-263` (a `testServer()` assertion that every
   exclusion reason is one of the two) — the last stays valid untouched, because that test
   supplies no rules, and that is exactly the rules-off pin D4-1/D4-2 want kept.
6. **The override is per surface, and the UI must say so.** An override on the Breeding Groups
   tab does not affect Mate Pair results and vice versa (D7). The status line and the gate
   copy must name *this tab*; otherwise a curator will assume one override covers both.
7. **Snapshots, not live inputs (D8c).** The module reads the run's snapshot of rules and
   overrides for the tables, the manifest and the Ancestry tab. Reading the live reactive
   would let a later override rewrite an earlier run's manifest — a silently wrong audit trail
   (the L780/#150 class).
8. **The Excluded tab has no export.** A curator who wants the list of blocked pairs as a file
   cannot get one today; the manifest gives per-rule *counts*, not pairs. Adding an Excluded
   export is a UX gap this design surfaces but **does not fix** (Learning 382, report-don't-fix);
   record it if the owner wants it as its own item.
9. **Pairs excluded for age/user reasons are not counted in the manifest** (D5). Manifest
   `nPairs` means "otherwise-eligible pairs the rule matched"; the manifest/article text must not
   imply it counts every candidate pair, or a curator will misread a small count as a
   permissive rule set.
10. **Rules re-validation can re-emit the UNKNOWN/OTHER warning.** `reportMatePairs()` calls
    `checkAncestryRules()` (D3), and the module already validated the same rules once (with a
    notification). Verify at Slice 2 how Breeding Groups avoids double-notifying (it re-validates
    via `.effectiveAncestryRules()` at run time) and follow the same posture rather than
    inventing a new one.

---

## 8. Alternatives considered

| Alternative | Pros | Cons | Why rejected |
|---|---|---|---|
| Do nothing: document a recipe (`reportAncestryViolations()` over 2-animal groups) | Zero code | Measured 2.39 s / 5,000 pairs (est. minutes at real sizes); no exclusion, override, audit or app surface | Does not deliver the feature; kernel cost measured (§1.3) |
| Annotate-only (D2) | No override mechanism needed | `block` loses its meaning; Eligible list can hold prohibited pairs | D2 — `block` = "excluded", overridable |
| New post-processing function (D3) | Composable; existing function untouched | +1 export and docs surface; two-step call | D3 — extend the existing function (the `groupAddAssign()` precedent) |
| Always-present ancestry columns (`NA` without rules) | Fixed shape | Breaks D4-1 (zero change) and every `identical()`-style consumer | Ruled out by the hard constraint |
| Shared overrides, Breeding Groups owns the gate (D7) | Least new UI | Coupled audit story; group-formation wording; cross-tab silent change | D7 |
| Independent upload in the Mate Pair tab (D7) | Smallest blast radius | Double upload; per-tab policy drift; ~150 duplicated lines | D7 |
| Move the rules upload to a shared/Input-tab surface | One canonical home | Changes a shipped, ratified surface (#168 D8) — regression risk for a follow-up | Out of scope; revisit only if a third consumer appears |
| Directional (sire-level × dam-level) rules | Expresses "INDIAN sire with CHINESE dam only" | Doubles the vocabulary for a need nobody has stated; #168 D1 chose unordered | Additive later behind its own gate |
| Ancestry screen before the age/user screens | Ancestry counts every pair | Changes which reason existing excluded rows carry (breaks D4-2) | D5 |
| Mirror Breeding Groups' violations table (D9) | Consistency | Duplicates the inline columns | D9 |

---

## 9. Close-out checklist mapping

Design-only session — no `R/`/`tests/`/`man/` changes, so every code checklist is **N/A this
session**, owed at the §5 slices:

- **NEWS.Rmd (plain-language, S628):** at each slice that ships user-visible behavior (S1 the
  script arguments, S2 rules applied in the tab, S3 override/manifest) — say in one or two
  short sentences that `block` rules keep a matching pair off the Eligible list and how to
  override, never implementation phrasing.
- **`_pkgdown.yml` coverage:** N/A under D3 (no new export); re-confirm per slice.
- **Citation checklist (issue #120):** run at Slice 3; expected N/A (rule bookkeeping and
  counts, not statistics) — recorded, not assumed.
- **Tutorial/article checklist (S436):** Slice 3 — `vignettes/articles/colony-manager-guide.qmd`
  Mate Pair Analysis section, plus one sentence in the existing ancestry-guardrails paragraph
  (`:523-566`) that the same rules now apply on the Mate Pair Analysis tab, and the D7/D9
  behavior (one upload, per-tab overrides, what `block` means here).
- **`a2interactive.Rmd` checklist:** deferred to the standing documentation pass — the new
  parameters on the already-documented exported `reportMatePairs()` join that pass's inventory.
- **Lint close-out:** every slice (each touches `.R` files).
- **CI e2e group registration:** by construction (the file name matches
  `^e2e-mate-pair-analysis-module`); verify with `test_shinytest2_workflow_coverage.R`.
- **Issue close-out:** the tracking issue stays open through Slices 1–2 and closes at Slice 3's
  close-out (`gh issue close --reason completed`, citing the `CHANGELOG.md` entry).

---

## 10. Provenance

Built from: `docs/planning/issue168-ancestry-guardrails-plan.md` (read in full — the machinery,
D1–D9 and the "Deferred" note this plan answers); `docs/planning/issue151-individual-mate-pair-
analysis-plan.md` §2.6 (pair-table size benchmark) and its heading list; direct source reads of
`R/reportMatePairs.R` (in full), `R/modMatePair.R` (in full), `R/reportAncestryViolations.R` (in
full), `R/ancestryOverrides.R` (in full), `R/checkAncestryRules.R` (in full),
`R/modBreedingGroups.R:225-545,655-720,1085-1129` and a `grep -n` of every ancestry site,
`R/appServer.R:330-490`, `docs/architecture/module-contract.md` (rules 1–6),
`tests/testthat/test_moduleContract.R:54-58,97-104`, shape-pin greps of
`test_reportMatePairs.R`/`test_modMatePair.R`, `.github/workflows/shinytest2.yaml:120-175`,
`NEWS.Rmd:376-432`, `vignettes/articles/colony-manager-guide.qmd:519-566`, the two ancestry
fixtures, `PROJECT_LEARNINGS.md` Learnings 776–783 (776: render outward-facing drafts inline
before the gate; 780: two-call override contract; 781: formed-groups-only reporting, which does
not apply here because pairs are not groups). **Measured this session** (`Rscript` probe, HEAD
`aa5bfde9`, `pkgload::load_all()`): the fixture pair table (25 pairs, 5 block / 3 flag / 17
unmatched; post-QC ancestry counts; ages), and `reportAncestryViolations()` on 5,000 two-animal
groups (2.39 s). **Not measured:** the 315k/1.74M-pair extrapolations (estimates, labeled),
and any live-app behavior — no runtime surface changed. Repo-wide collision greps for every §4
name: clear (two recorded module-local overlaps, §1.3). No decision above rests on an unverified
claim.

---

## 11. Ratification status — forced vs. judgment-call decisions

**Forced / evidence-determined (no vote; listed for the implementing sessions):** D1 (inherit),
D4 (invariants follow from the zero-change constraint), D5 (screen order follows from D4-2 and
the closed vocabulary), D6 (measured kernel constraint; one-call design removes the L780 trap),
D8 (the shipped primitives are reused unchanged; only per-surface wording is new), D10
(dependency-forced order).

**Genuine judgment calls put to the owner in one `AskUserQuestion` round (4 questions, one
call):** D2 (what `block` does in a report), D3 (script-API shape), D7 (rules source and
override ownership), D9 (results UI placement).

### Ratification outcome (2026-09-23, this session)

Owner selected this document's own recommended option in all four cases:

- **D2 — `block` moves the pair to Excluded** with reason `"ancestry rule"` and the matched
  rule; overridden pairs stay in Eligible Pairs marked `overridden`; annotate-only declined.
- **D3 — extend `reportMatePairs()`** with `ancestryRules`/`overriddenRules`; a separate
  post-processing function declined.
- **D7 — shared rules, per-surface overrides:** Breeding Groups returns its loaded rules,
  `appServer` threads them to the Mate Pair module, which owns its own override gate, reasons
  and manifest; shared overrides and an independent upload declined.
- **D9 — inline annotations plus a small Ancestry tab** (coverage + manifest) and a collapsed
  config section; a full Breeding Groups mirror and config-section-only declined.

No changes requested to any recommended design. **This design is ratified and ready for Slice 1
implementation in a future session**, subject to the two items deliberately left to later gates:
the exact final column list (Slice 1 RED) and the owner's ratification of the mate-pair
confirm-gate wording (Slice 3 RED, D8a). The tracking issue (#169) stays open through
the slices; this session closes nothing.
