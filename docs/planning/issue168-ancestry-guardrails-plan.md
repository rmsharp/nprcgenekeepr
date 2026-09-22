## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Issue #168 Plan — Ancestry Guardrails for Breeding-Group Formation

**Session:** S762 (2026-09-22) · **Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`
· **Type:** design/architecture document, matching the #133/#136/#137/#145/#146/#147/#149/#150/
#151/#152/#153/#167 precedent — **zero `R/`/`tests/`/`man/` changes this session.** This plan
answers the nine open design questions (Q1–Q9) recorded in the S761 scope-narrowing record
(`docs/planning/issue168-ancestry-guardrails-scoping-2026-09-22.md` §4) as ratified, numbered
decisions. Implementation is gated on §11's ratification; each §5 slice is a separate
strict-TDD session.

---

## 1. Context

### 1.1 What issue #168 asks for

The verbatim issue body is quoted in full in the scoping record (§2.1) and is not repeated
here. In one sentence: group formation is ancestry-blind today — the Origin color is computed
only after groups exist, in a different module — and #168 asks for center-configurable
ancestry compatibility rules evaluated **during** candidate-group construction, blocking or
flagging incompatible pairings as configured, with an explicit override mechanism and an
audit trail recording which rule was overridden and why, so the guardrail informs decisions
without silently vetoing curator judgment. The issue's own closing gate line requires this
design before implementation; the S761 narrowing comment (issue #168 comment 5781230607)
records that design and implementation stay under this one issue number.

### 1.2 What is already decided (do not re-litigate)

- **Design-first, same issue** (S761 owner decision, scoping record §1): this plan is the
  gate being satisfied; implementation slices follow only after §11 ratification.
- **Hard constraints carried in regardless of any Q answer** (scoping record, end of §4):
  with no rules configured, all existing behavior — `groupAddAssign()` results, module
  outputs, existing tabs — changes zero; no writes outside user-designated locations (CRAN
  policy — user-directed persistence only, the #150 manifest mold); the guardrail informs
  and records, it never silently vetoes curator judgment (an override path is part of the
  feature's definition); ancestry vocabulary goes through `convertAncestry()`'s standardized
  levels, with the Q6 discrepancy resolved explicitly; any new displayed statistic triggers
  the citation checklist (issue #120); NEWS.Rmd entries use plain colony-manager language
  (S628); module changes respect `docs/architecture/module-contract.md` (enforced by
  `test_moduleContract.R`).
- **The reader/validator mold** (`readKinshipOverrides()`/`checkKinshipOverrides()`,
  `readTwinRelations()`/`checkTwinRelations()`, `checkMhcHaplotypeFile()`,
  `checkSnapshotHistory()`) is the established shape for a user-maintained table: reader
  handles CSV/Excel, validator `stop()`s with a specific violation and returns the coerced
  table, written nowhere by the app.
- **The override/audit mold** is #150's confirm gate + downloadable manifest
  (`R/modDeidentifiedExport.R:30` `.buildDeidentificationManifest`, `:49` warning-text
  constant, `:132` Confirm button): session-scoped, user-directed, CRAN-safe, including a
  verbatim copy of the warning shown at the gate.

### 1.3 What this session verified directly

Every load-bearing claim below was re-read from source this session (not trusted from the
scoping record). `R/`, `tests/`, and `inst/` are unchanged since the scoping inventory
(`git log 4310d820..HEAD -- R/ tests/ inst/` is empty), and the inventory's line pins held
on re-read. Additional facts and **one new discovery**:

- **The conflict-list mechanics the block seam relies on:** `groupAddAssign()` builds `kin`
  via `getAnimalsWithHighKinship()` (`R/groupAddAssign.R:176`), which long-forms the kinship
  matrix with `kinMatrix2LongForm(kmat)` — `removeDups = FALSE` default
  (`R/kinMatrix2LongForm.R:28`), so **both directions of every pair are present** and the
  resulting `tapply(kin$id2, kin$id1, c)` list is symmetric. `fillGroupMembers()` consumes
  it one-directionally at the seam (`available[[i]] <- setdiff(available[[i]], kin[[id]])`,
  `R/fillGroupMembers.R:75`), so a blocked-pair merge **must preserve symmetry** (add id2
  under id1 AND id1 under id2). `addAnimalsWithNoRelative()` pads `kin` with `NA` entries
  for conflict-free candidates (`R/groupAddAssign.R:189`); `setdiff` tolerates the `NA`s.
- **Both search modes consume the same `kin`:** the exhaustive branch
  (`.groupAddAssignExhaustive`, `R/groupAddAssign.R:316`) receives the already-built `kin`,
  so one merge point upstream of the mode fork (`R/groupAddAssign.R:194`) covers sampling
  AND exhaustive enumeration with no second implementation.
- **The sampling loop's RNG discipline:** `sample()` calls live inside the `iter` loop
  (`R/groupAddAssign.R:228-262`) and in `fillGroupMembers()`; an E2E determinism hook exists
  (`gatedSeed("nprcgenekeepr.bg_seed", "NPRC_BG_SEED")`, `R/modBreedingGroups.R:301`,
  helper at `R/set_seed.R:41`) — the RNG-neutrality test (D7) can be seeded through it or
  plain `set.seed()` in unit tests.
- **The module already receives validated sidecar tables as reactives**
  (`kinshipOverrides`, `twinRelations` — `R/modBreedingGroups.R:231-234`), and the
  in-module upload-validate mold is `checkKinshipOverrides(readKinshipOverrides(...))`
  inside `tryCatch` + `showNotification` (`R/modGeneticValue.R:249-250`). The results
  surface is a `tabsetPanel` (Groups / Statistics / Group Detail,
  `R/modBreedingGroups.R:123-140`) with `downloadHandler` exports via `getDatedFilename()`.
- **`reportMatePairs()`** (`R/reportMatePairs.R:96`) already returns an `excluded`
  data.frame with a per-pair `reason` column — the natural additive shape for a future
  mate-pair guardrail column (D5).
- **NEW DISCOVERY — `convertAncestry()` is not idempotent for UNKNOWN.** The raw
  `examplePedigree$ancestry` factor counts JAPANESE 2322 / UNKNOWN 1372 (zero
  INDIAN/CHINESE/HYBRID — the scoping §3 fixture gap confirmed by measurement). But after
  `qcStudbook()` re-standardizes (`R/qcStudbook.R:257`), the literal string `"UNKNOWN"` is
  not `NA` and matches no keyword, so it lands in **OTHER**: the QC'd pedigree the app
  actually hands the modules carries **JAPANESE 2322 / OTHER 1372, UNKNOWN 0** (measured
  this session). Consequence for D6: UNKNOWN and OTHER are operationally interchangeable
  "no usable ancestry information" classes, and a center writing a rule that names UNKNOWN
  almost always wants OTHER too. Recorded as a design input, not fixed (Learning 382);
  D6 and Dragon 3 carry it.
- **Collision greps clear:** no symbol matching `ancestryRule|ancestryCompat|guardrail|`
  `compatibilityRule|AncestryViolation|ancestryConflict|readAncestryRules|`
  `checkAncestryRules|reportAncestry` exists in `R/`, `tests/`, `NAMESPACE`, or
  `_pkgdown.yml` — every name proposed in §4 is collision-free.
- **`qcPed` has no `ancestry` column** (measured: id, sire, dam, sex, gen, birth, exit,
  age) — the D6 no-column degradation path has a shipped fixture exercising it for free.

---

## 2. Evidence-based inventory

The scoping record §3 carries the full 14-row grep-verified inventory (2026-09-22, S761);
this session re-verified the load-bearing rows directly rather than duplicating the table
(§1.3). Net: **the entire group-formation kernel is ancestry-blind (zero grep matches);
the standardized 6-level vocabulary, the optional `ancestry` schema column, the post-hoc
Origin color, the reader/validator mold, the #150 override/audit mold, and the pairwise
conflict-list seam all exist; the compatibility rules, construction-time enforcement,
override mechanism, and audit trail do not.** The additional facts this plan rests on
beyond that table are exactly the §1.3 verifications above.

---

## 3. Design decisions

Nine decisions, answering Q1–Q9 one-for-one. D4, D6, D7, D9 are **forced or
evidence-determined** — listed with their reasoning for the implementing sessions' benefit.
D1, D2, D3, D5, D8 are **genuine judgment calls**, ratified via a single `AskUserQuestion`
round in §11 (five questions — one more than the #167 round; posed as one round in two
tool calls, the tool's 4-question cap being mechanical).

**D1 (judgment call — answers Q1). Rule model: a symmetric pairwise compatibility table
over the standardized ancestry levels, each rule declaring its own severity
(`block` | `flag`); no rules ship active — an example rules file ships as documentation
and fixture only.** One rule is one unordered level pair plus a severity: e.g.
INDIAN × CHINESE → block; INDIAN × HYBRID → flag. Group-level composition rules of the
kind the audit motivates ("a group may not mix INDIAN and CHINESE animals") are exactly
pairwise rules — a group contains no INDIAN×CHINESE pair iff it does not mix them — so the
pairwise primitive covers the issue's and the PDF's named aims with one mechanism that
plugs directly into the existing pairwise conflict seam (§1.3). Proportion/count-style
composition rules ("≤ 20% HYBRID") are not asked for by the issue, the audit, or the PDF
summary and are additive later (a severity or rule-type column extension behind its own
design gate). The exact final column list (names, order, types) is Slice 1's RED-phase
deliverable; this decision fixes the shape: unordered level pairs over `convertAncestry()`'s
6 levels (D6), per-rule severity, symmetric by construction (validator rejects unordered
duplicates, the `checkKinshipOverrides()` mold). **A shipped ACTIVE default rule set is
ruled out by the zero-behavior-change hard constraint** — an ancestry-bearing pedigree
would form different groups out of the box — so the motivating rhesus Indian-origin case
ships as `inst/extdata/examples/example_ancestry_rules.csv` (adopt-by-upload), not as
behavior. **Recommended: pairwise table, example-file-only default.** **Declined
alternatives:** group-composition rule DSL (Q1b — a second evaluation engine with no
pairwise seam to plug into, for rules nobody has asked for); both models at once (Q1c —
doubles Slice 1's schema and validator surface for the same v1 coverage).

**D2 (judgment call — answers Q2). Configuration surface: a user-supplied rules file read
at analysis time through a `readAncestryRules()`/`checkAncestryRules()` sibling pair (the
kinship-overrides mold, CSV/Excel), uploaded in-app and script-callable; NOT the
machine-level site-config file.** "Center-configurable" operationally means: the center
maintains one rules file, distributes it to its colony managers, and it travels between
machines as a file — exactly how every other outside-information table in this app already
works (kinship overrides, twin relations, MHC haplotypes, genotypes, snapshot history).
The site-config file (`getSiteInfo()`) is LabKey-connection-oriented, per-machine, and no
analysis input reads from it today; putting the first one there would make rules invisible
to script users and untestable without machine state. In-app-controls-only (Q2c) has no
between-machine story at all and builds rule entry UI (level pickers, severity toggles)
that the file mold gets for free. **Recommended: rules file.** **Declined alternatives:**
site-config residence (Q2b), in-app controls only (Q2c) — both above; a hybrid
(file + in-app editing) is additive later without schema change.

**D3 (judgment call — answers Q3, enforcement scope half). Rules apply sex-blind — to
every within-group pair, regardless of sex; there is no per-rule sex column in v1.**
Geographic genetic composition is a group-level property: an INDIAN×CHINESE co-housing
violates a purity rule whether or not the two animals can breed. This is deliberately
DIFFERENT from the kinship machinery's `ignore = list(c("F","F"))` female-female
exemption, which exists because female-female kinship poses no inbreeding risk; ancestry
conflicts therefore merge into the `kin` structure WITHOUT passing through
`filterPairs()`'s exemptions, and Slice 2 tests pin exactly that (an F-F INDIAN×CHINESE
pair IS blocked while F-F kinship is still ignored). Breeding-pair-only enforcement
(male × female) remains expressible later as a per-rule column addition behind its own
gate; the mate-pair surface (D5) is inherently M×F. **Recommended: sex-blind.**
**Declined alternatives:** M×F-only enforcement (under-blocks the PDF's composition aim —
an all-female group could still mix origins invisibly); a per-rule sex column in v1
(schema surface for a scope nobody has requested).

The other half of Q3 — block vs. flag placement — is evidence-forced and shared with D7:
**block** rules merge their conflicting pairs into `kin` at one point upstream of the
sampling/exhaustive fork (§1.3), so candidate selection can never co-place them, in both
search modes, with the search machinery untouched; **flag** rules never touch the search —
violations are computed post-formation over the formed groups (script surface:
`reportAncestryViolations()`, §4) and annotated in the results views.

**D4 (forced — answers Q4). Override granularity is per-rule, per-run; a free-text reason
is required at override time; the audit trail is the #150 confirm-gate + downloadable
manifest mold, session-scoped; no persistent log; overridden state stays visible in the
run's outputs.** The issue's own words fix the granularity: the audit trail records
"which rule was overridden and why" — the unit is the RULE. Per-pairing override is
inoperable in a stochastic group former (the curator never chooses pairings, the sampler
does), and whole-guardrail override erases exactly the record the issue demands. Concretely:
a curator overrides a specific block rule for the next formation run through a
`modalDialog()` confirm gate (mold: `R/modDeidentifiedExport.R:132`) that requires a
non-empty reason; the run then treats that rule as inactive for BLOCKING but still reports
its violations as `overridden` rows (never silently absent) in the violations view; the
downloadable audit manifest (mold: `.buildDeidentificationManifest`,
`R/modDeidentifiedExport.R:30`) records timestamp, `packageVersion`, the rules table in
effect, each overridden rule with its stated reason, the affected-pair counts, and a
verbatim copy of the gate's warning text. A persistent on-disk audit log is ruled out by
the CRAN write-policy hard constraint — the manifest is user-directed (`downloadHandler`),
like every other write in this app. Script users overriding by editing their rules file
carry their own audit responsibility; the manifest is the APP workflow's record.

**D5 (judgment call — answers Q5). Enforcement surfaces in v1: `groupAddAssign()` (a new
optional `ancestryRules = NULL` argument — the script API for enforcement) and
`modBreedingGroups` (the app surface); plus `reportAncestryViolations()` as the
script-callable flag/inspection API usable on ANY group list. The mate-pair surface
(`modMatePair`/`reportMatePairs()`) is deferred as a recorded additive follow-up, not
part of this ratification.** Script-API parity is satisfied at Slice 2 (both exported
entry points ship before any UI — the pattern every recent feature followed).
`reportMatePairs()` already returns an `excluded` data.frame with a per-pair `reason`
column (§1.3), so the future mate-pair integration is a purely additive column/rows
change behind its own small gate once the rule machinery exists and has settled —
deliberately sequenced after v1 rather than widening this cluster's blast radius across
two modules and two issues' molds (#151's module contract would need its signature
re-opened for a rules reactive). **Recommended: group-formation + script API in v1;
mate-pair deferred.** **Declined alternative:** wiring `modMatePair` in v1 — adds a
5th slice touching a second module for a surface the issue does not name.

**D6 (evidence-determined — answers Q6). The rule vocabulary is exactly
`convertAncestry()`'s 6 levels (CHINESE, INDIAN, HYBRID, JAPANESE, OTHER, UNKNOWN); the
guardrail is independent of `getIndianOriginStatus()`; the package takes NO hardcoded
stance on unknown-ancestry animals — a center opts into conservatism by writing rules
that name UNKNOWN/OTHER explicitly, and every guardrail surface reports rule coverage so
permissive silence is visible; a pedigree with no `ancestry` column degrades loudly to
today's behavior.** Mechanics: an animal whose ancestry level appears in no rule
participates in no conflict (permissive by construction — unlisted pairs are compatible);
because scoping Q6 is right that a permissive default can silently defeat the guardrail
in sparse-ancestry colonies, every surface that evaluates rules (the Slice 4 status
panel, `reportAncestryViolations()`'s attributes/summary, and the audit manifest) states
how many animals carry each level and how many carry levels no rule names. The
**BORDERLINE_HYBRID discrepancy** (scoping §3: `getIndianOriginStatus()`'s yellow branch
is unreachable from `convertAncestry()`'s levels) is resolved by INDEPENDENCE: the rule
model neither extends `convertAncestry()` (a vocabulary change would ripple through QC
and the Origin heatmap — its own issue if ever wanted) nor reads
`getIndianOriginStatus()` (zero-behavior-change: the Origin metric and its unreachable
branch stay untouched, discrepancy documented where it was found). The **non-idempotency
discovery** (§1.3) folds in here: because a re-standardized `"UNKNOWN"` string lands in
OTHER, UNKNOWN and OTHER are operationally one "no usable information" class —
`checkAncestryRules()` warns (not stops) when a rules table names one of UNKNOWN/OTHER
but not the other, and the example rules file + article text model naming both. **No
`ancestry` column at all** (the `qcPed` case): `groupAddAssign(ancestryRules = <rules>)`
on such a pedigree `stop()`s naming the missing column (a script user who passed rules
gets truth, not silence), while the module's guardrail section shows "pedigree has no
ancestry column — guardrails inactive" and forms groups exactly as today (the app's
loud-but-not-fatal reading of the same fact; with no rules uploaded neither surface says
anything, preserving D7).

**D7 (forced — answers Q7). Zero-behavior-change default and RNG-stream neutrality, made
mechanical:** `ancestryRules = NULL` (the default) leaves `groupAddAssign()`'s behavior
byte-identical — no code path touches rules before the NULL check; with **flag-only**
rules, the formed groups are identical to no-rules under the same seed, because flag
evaluation runs entirely AFTER the search loop (block-merge is the only pre-search step,
and it runs only for block rules); with **block** rules, the merge happens ONCE, upstream
of the sampling/exhaustive fork, never inside the `iter` loop — the RNG stream consumed
by `sample()` differs from no-rules only through the (deliberately) changed candidate
conflict structure. Slice 2 pins all three properties: a same-seed no-rules vs.
`NULL`-rules identity test, a same-seed flag-only-rules identity test, and a
block-rules-never-co-placed property test; performance is a non-concern by construction
(the merge shrinks the candidate graph before iteration; flag computation is one pass
over ≤ `numGp` formed groups).

**D8 (judgment call — answers Q8). UI placement: a collapsible "Ancestry Guardrails"
sub-section inside `modBreedingGroups`' existing Configuration panel (upload + status +
per-rule override controls), a new "Ancestry" results tab in the module's existing
`tabsetPanel` (violations table + coverage summary + manifest download), and the #150
confirm-gate modal for overrides; no formation-time interruption for flag-only results
and no companion view in other modules.** The guardrail is a group-formation input, so it
lives where formation is configured — beside the kinship threshold it parallels — and its
results are formation results, so they join Groups/Statistics/Group Detail
(`R/modBreedingGroups.R:123-140`). The panel-density concern (scoping Q8) is met by the
sub-section defaulting collapsed with a one-line status ("no rules loaded" / "N block,
M flag rules; K animals uncovered"); the module's control column is already the densest
in the app, and a collapsed-by-default section adds one visible line to it. Fixture
consequence (rides Q8): ancestry-bearing test fixtures are NEW files/test-local objects —
`examplePedigree` and `qcPed` are exported data objects whose modification would be a
user-visible data change (Dragon 6); the example rules file (D1) plus a small
INDIAN/CHINESE/HYBRID-bearing test pedigree fixture ship at Slice 1. Tutorial/article
checklist (S436) applies at Slice 4. **Recommended: in-module section + results tab +
confirm modal.** **Declined alternatives:** formation-time modal as the primary surface
(interrupts every run; the #150 gate is for the override decision, not routine status);
a companion view beside the Genetic Diversity heatmap (splits the workflow across tabs
and modules — the heatmap is post-hoc reporting, exactly what #168 exists to move beyond).

**D9 (forced shape — answers Q9). Slice decomposition: four v1 slices (rule table + IO →
enforcement kernel → override/audit primitives → UI wiring + docs), each one session,
strict TDD, `AskUserQuestion`-gated phases.** Detailed in §5. The order is
dependency-forced: enforcement consumes what the validator defines; override/audit
decorates enforcement's outputs; the UI wires all three. Script-callable value accrues
from Slice 2 onward, before any UI exists — the vertical-slicing FM #25 test ("if I stop
here, is something working?") passes at every boundary.

---

## 4. Interface catalog (proposed — for the implementing sessions, not built this session)

| Interface | Kind | Input | Output | Error | Consumers |
|---|---|---|---|---|---|
| `readAncestryRules(fileName, sep = ",")` | New `@export`ed reader (D2), `readKinshipOverrides()` mold (CSV/Excel) | file path | raw data.frame (validated separately by `checkAncestryRules()`, the sibling-pair convention) | file-level read errors surface as-is | Slice 4 upload, script users |
| `checkAncestryRules(rules)` | New `@export`ed validator (D1/D2/D6), `checkKinshipOverrides()` mold | rules data.frame (unordered level pair + severity per row; exact columns fixed at Slice 1 RED) | the coerced rules table; `stop()` with a specific violation otherwise | missing columns; a level outside `convertAncestry()`'s 6; unknown severity (not `block`/`flag`); duplicate unordered pair; self-pair policy fixed at Slice 1 RED (a level paired with itself is legal — e.g. HYBRID × HYBRID — but duplicated rows are not); **warning** (not stop) when exactly one of UNKNOWN/OTHER is named (D6, §1.3 discovery) | `readAncestryRules()` callers, `groupAddAssign()`, `reportAncestryViolations()`, Slice 4 |
| `groupAddAssign(..., ancestryRules = NULL)` | New optional argument on the existing `@export` (D3/D5/D7) | validated rules table or `NULL` | unchanged return shape; block-rule conflicts merged into `kin` upstream of the mode fork | `stop()` when rules are non-NULL and `ped` has no `ancestry` column (D6); `NULL` = byte-identical to today | `modBreedingGroups`, script users |
| `reportAncestryViolations(groups, ped, rules, overriddenRules = NULL)` | New `@export`ed flag/inspection function (D3/D4/D5) | list of id vectors (any formed groups); pedigree with `ancestry`; validated rules; optionally the rules overridden this run | data.frame, one row per violating within-group pair: group index, both ids, both ancestry levels, the matched rule, severity, `status` (`violation` \| `overridden`); plus a coverage summary (animals per level, animals under no rule — D6) as attributes or a second list element (fixed at Slice 2 RED) | `stop()` on missing `ancestry` column or malformed inputs; zero-row result on no violations | Slice 4 "Ancestry" tab, audit manifest, script users |
| `.ancestryConflictPairs(ids, ped, rules, severity)` | New `@noRd` helper (D3) | candidate ids, pedigree, rules, which severity class to extract | the pairs matching rules of that severity, in the shape each caller merges/reports | (internal) | `groupAddAssign()` (block), `reportAncestryViolations()` (both) |
| `.buildAncestryOverrideManifest(rules, overrides, violations, warningText)` | New `@noRd` manifest builder (D4), `.buildDeidentificationManifest` mold (`R/modDeidentifiedExport.R:30`) | rules in effect; overridden rules + reasons; the run's violations/coverage; gate warning text | manifest data.frame: timestamp, `packageVersion`, rules, per-override reason, counts, verbatim warning text | (internal) | Slice 4 manifest `downloadHandler` |
| `modBreedingGroupsUI/Server` additions | Extended existing module (D8) — no new server arguments; the module owns upload → validate → status → override gate → formation → violations | (existing reactives unchanged) | existing return list unchanged (module contract rule 4: nothing new is returned until a consumer exists) | upload malformedness via `tryCatch` + `showNotification` (the `R/modGeneticValue.R:249` mold); module-contract rule 5 | `R/appUI.R`/`R/appServer.R` (no wiring change — verified: the module is self-contained for this feature) |

Vocabulary notes: rule levels are exactly `convertAncestry()`'s 6 (D6); "override" always
means the per-rule, per-run mechanism (D4) — never a data edit; the word "guardrail" is
UI/documentation language, not an API name.

---

## 5. Implementation plan — vertical slices (each its own future session)

**This design session implements no slice.** Every slice: strict TDD (RED→GREEN→REFACTOR,
`AskUserQuestion`-gated), full-suite regression + lint close-out checklists per
`CLAUDE.md`. Per-slice completion criteria name their verification surface; none of these
surfaces exercises LabKey-connected operation, which no slice claims.

### Slice 1 — Rule table schema + reader/validator + fixtures (script-callable only)
**Touches:** new `R/readAncestryRules.R`, `R/checkAncestryRules.R` + tests; the example
rules file `inst/extdata/examples/example_ancestry_rules.csv` (hand-authored: the
motivating rhesus Indian-origin case — INDIAN × CHINESE block, INDIAN × HYBRID block or
flag, UNKNOWN **and** OTHER conservatively named per D6's warning — plus at least one
flag-severity rule so both severities have fixture coverage); a small ancestry-bearing
test pedigree fixture (INDIAN/CHINESE/HYBRID/JAPANESE/OTHER/UNKNOWN rows — new file or
test-local constructor, never an edit to `examplePedigree`/`qcPed`, Dragon 6);
`_pkgdown.yml` entries; NEWS.Rmd entry (plain-language, S628). RED fixes the exact rule
column list and the self-pair policy (§4).
**Done when:** validator accepts the example file and rejects each violation class with a
specific message (per-violation tests, incl. the UNKNOWN/OTHER-asymmetry warning);
reader round-trips CSV and Excel; full suite + `lintr` clean.
**Surface:** local test suite (`NOT_CRAN=true`, `load_all()` first) + `devtools::check()`.
This surface cannot demonstrate app behavior — none is claimed until Slice 4.

### Slice 2 — Enforcement kernel (script-callable only)
**Touches:** `R/groupAddAssign.R` (the `ancestryRules = NULL` argument + the one
block-merge call upstream of the mode fork), new `R/reportAncestryViolations.R`, new
`.ancestryConflictPairs()` helper (file placement the implementing session's choice) +
tests; NEWS.Rmd; `_pkgdown.yml`.
**Done when:** (1) same-seed identity tests pass — `ancestryRules = NULL` vs. the argument
omitted vs. pre-change behavior byte-identical, and flag-only rules vs. no rules
group-identical (D7); (2) a block rule is never violated in any formed group across a
seeded property test, in BOTH sampling and exhaustive modes, and an F-F pair matching a
block rule is excluded while F-F kinship remains ignored (D3's pinned distinction);
(3) `reportAncestryViolations()` matches hand-derived violations on the Slice 1 fixture,
reports `overridden` status rows when `overriddenRules` is supplied, and its coverage
summary counts match hand-derived level counts (D6); (4) `stop()` paths tested (rules with
no `ancestry` column, malformed rules); (5) full suite + lint clean — the existing
`groupAddAssign()` test corpus passes unchanged with the argument absent.
**Surface:** local test suite + `devtools::check()`, as Slice 1.

### Slice 3 — Override + audit-manifest primitives (script-callable/module-internal)
**Touches:** new `.buildAncestryOverrideManifest()` (+ the gate warning-text constant, the
`.deidentifiedExportWarningText` mold) + tests; the override-state plumbing
`reportAncestryViolations()` consumes (already argument-shaped in §4 — this slice proves
the full override → enforcement → report → manifest path headlessly); NEWS.Rmd if any
export lands (expected none — internals only; record the N/A).
**Done when:** the manifest contains timestamp, `packageVersion`, the rules in effect,
each overridden rule with its non-empty reason, violation/coverage counts, and the
verbatim warning text (field-equality tests, #150 mold); an overridden block rule's
violations appear as `overridden` rows, never silently absent (D4); a manifest built from
a no-override run says so explicitly; full suite + lint clean.
**Surface:** local test suite + `devtools::check()`. The confirm-gate UI is NOT this
slice's surface — the gate itself ships and is exercised in Slice 4; this slice proves
everything behind it.

### Slice 4 — UI wiring, downloads, documentation
**Touches:** `R/modBreedingGroups.R` (collapsible "Ancestry Guardrails" configuration
sub-section: rules upload via the `modGeneticValue.R:249` validate-notify mold, status
line, per-rule override controls behind the #150 `modalDialog` confirm gate with required
reason; new "Ancestry" results tab: violations DT table with `status` column, coverage
summary, manifest `downloadHandler` via `getDatedFilename()`; formation call passes the
effective rules); tests incl. `test_moduleContract.R` (return vocabulary unchanged —
rule 4) and wiring tests; `shinytest2` e2e (new `test-e2e-*` file — register its group
regex in `.github/workflows/shinytest2.yaml` in the SAME session, the S760 gotcha);
NEWS.Rmd (plain-language, S628); tutorial/article checklist (S436:
`vignettes/articles/colony-manager-guide.qmd` and/or matching manual component — include
the D6 guidance to name UNKNOWN and OTHER together); `_pkgdown.yml` (if any new export);
issue #120 citation checklist run on the shipped UI (expected N/A — violations and
coverage counts are rule bookkeeping, not statistics/estimators; record the check, not
the expectation).
**Done when:** `shinytest2` drives the full path — load example pedigree → upload example
rules → status shows counts → form groups → blocked pair never co-placed → "Ancestry"
tab shows flag violations → override one block rule through the gate with a reason →
re-form → overridden rows visible → download manifest and verify its content — with zero
console errors; with no rules uploaded, all existing module behavior and every other tab
byte-unchanged (D7, verified by diff scope + the existing test corpus); no-ancestry-column
pedigree shows the inactive notice (D6); full suite + lint clean.
**Surface:** `shinytest2` headless Chrome (the Phase 3E bar for this cluster) + local
suite + `devtools::check()`. This surface cannot enforce LabKey-connected behavior or
non-headless browser quirks; neither is claimed. **Close-out includes the explicit issue
#168 open/close call** (v1 complete vs. mate-pair follow-up tracked separately — that
session's owner call, made explicitly at its close-out).

### Deferred (recorded, NOT ratified by this plan) — Mate-pair surface integration
Additive `reportMatePairs()`/`modMatePair` annotation using the same rules machinery
(D5): a violations/`reason` extension of the existing `excluded`/`pairs` frames. Needs
its own small design gate once v1 has settled; do not start it from this plan alone.

---

## 6. Impact analysis

| System | Impact | Action required |
|---|---|---|
| `groupAddAssign()` | One new optional argument, `NULL` default byte-identical (D7); one block-merge call upstream of the mode fork. | Slice 2; same-seed identity tests are the guard. |
| `fillGroupMembers()` / `makeGroupMembers()` / `fillGroupMembersWithSexRatio()` / `getAnimalsWithHighKinship()` / `filterPairs()` | **Unchanged** — blocking rides the existing `kin` structure; the sex-ratio and harem paths inherit it through the same list. | Slice 2 property test covers harem/sexRatio modes too. |
| Exhaustive mode (`.groupAddAssignExhaustive`) | **Inherits blocking unchanged** — consumes the same merged `kin` (§1.3). | Covered by the Slice 2 both-modes property test. |
| `modBreedingGroups` | New collapsed-by-default config sub-section + one new results tab at Slice 4; return list unchanged (contract rule 4). | Module-contract test must pass unchanged. |
| `modMatePair` / `reportMatePairs()` | **Unchanged in v1** (D5); additive follow-up recorded in §5. | None this cluster. |
| `getIndianOriginStatus()` / `modGeneticDiversity` (Origin heatmap) | **Unchanged** — D6 independence; the BORDERLINE_HYBRID discrepancy stays documented, unreachable, and untouched. | None; a future Origin-metric issue owns it. |
| `convertAncestry()` / `qcStudbook()` | **Unchanged** — the vocabulary is consumed, never modified; the non-idempotency discovery (§1.3) is documented behavior the D6 warning works around. | None; Slice 4 article text carries the guidance. |
| `examplePedigree` / `qcPed` data objects | **Unchanged** (Dragon 6) — fixtures are new files/test-local. | Slice 1. |
| `appUI.R` / `appServer.R` | **Unchanged** — the module is self-contained for this feature (§4). | Slice 4 verifies by diff scope. |
| `DESCRIPTION` | **Unchanged** — reader uses the existing readxl/utils path; UI uses shiny/DT already imported. | Re-confirm no new dependency at each slice close-out. |
| CRAN policy posture | No new write path: the manifest and every export are `downloadHandler`s (D4). | Slice reviewers check no `write.*` lands outside tests/examples' tempdir. |
| Issue #167 machinery (snapshots/trends) | No shared surface. | None — informational. |

---

## 7. Here be dragons

1. **RNG-stream discipline is the whole D7 guarantee.** Any rule evaluation inside the
   `iter` loop — even an innocent-looking `sample()`-free check that calls something
   consuming RNG — breaks flag-neutrality. Block-merge runs once before the loop; flag
   computation runs after formation, full stop. The same-seed identity tests exist to
   catch exactly a future "just one small check in the loop" regression.
2. **The `kin` list's shape is subtler than it looks.** It is symmetric only because
   `kinMatrix2LongForm(removeDups = FALSE)` emits both directions; `tapply` drops
   candidates with no conflicts (padded later with `NA` by `addAnimalsWithNoRelative()`);
   names matter, `NA` entries are legal values. The merge must add BOTH directions, append
   to possibly-`NA` entries correctly, and cover blocked animals that had no kinship
   conflicts at all (their entries may not exist yet at merge time). Slice 2's RED should
   pin a hand-built `kin` before/after merge.
3. **UNKNOWN vs. OTHER will bite a center that names only one** (§1.3 discovery): raw
   `NA` ancestry → UNKNOWN, but any unrecognized or re-standardized string (including the
   literal `"UNKNOWN"`) → OTHER. The D6 validator warning and the article guidance are the
   countermeasures; do not "fix" `convertAncestry()`'s idempotency mid-slice — that is a
   QC-behavior change touching every ancestry-bearing pedigree, its own issue if ever
   wanted.
4. **Block rules can starve formation.** A dense block graph shrinks groups legitimately —
   low scores are the truthful outcome, not a bug. The Slice 4 status line's blocked-pair
   count (computed pre-formation from the candidate set) is the curator's early warning;
   never auto-relax a rule to "help."
5. **Never encode blocking as fake kinship.** Inflating `kmat` entries would corrupt
   `groupKin` displays, scores, and every downstream kinship view. Blocking lives in the
   `kin` conflict list only.
6. **`examplePedigree` and `qcPed` are exported data objects** — adding INDIAN/CHINESE
   rows for fixture convenience is a user-visible data change (and `examplePedigree`'s
   ancestry counts are pinned in this plan's own provenance). New fixture files/test-local
   constructors only.
7. **The override gate must not become a formation-time toll.** Flag-only runs and
   no-rules runs never see a modal (D8); the gate appears only when the curator initiates
   an override. A gate on every run would train click-through — the exact opposite of an
   audit culture.
8. **Panel density** (scoping Q8): the config column is the app's densest. The sub-section
   ships collapsed with a one-line status; if it still crowds narrow viewports at Slice 4's
   e2e pass, that is a note for the app-navigation Housekeeping thread, not a reason to
   relocate the feature mid-slice.

---

## 8. Alternatives considered

| Alternative | Pros | Cons | Why rejected |
|---|---|---|---|
| Group-composition rule DSL (Q1b) | Direct expression of "don't mix X and Y" | Needs its own evaluation engine; no pairwise seam to plug into; proportion rules unrequested | D1 — pairwise table covers every named aim through the existing seam |
| Both rule models in v1 (Q1c) | Maximum expressiveness | Double schema/validator surface for identical v1 coverage | D1 — additive later behind its own gate |
| Shipped ACTIVE default rules | Guardrail works out of the box | Violates the zero-behavior-change hard constraint for ancestry-bearing pedigrees | D1 — example file ships, behavior does not |
| Site-config residence (Q2b) | Literally "center-level" configuration | LabKey-oriented, per-machine, invisible to script users, no analysis input lives there today | D2 — rules file travels as a file, the app's universal mold |
| In-app rule controls only (Q2c) | No file to manage | No between-machine story; bespoke entry UI; nothing for script users | D2 — file first; in-app editing additive later |
| M×F-only enforcement (Q3) | Mirrors the kinship exemption's breeding logic | Under-blocks the group-composition aim (same-sex mixing invisible) | D3 — sex-blind; per-rule sex column additive later |
| Per-pairing override (Q4) | Finest granularity | Curator never chooses pairings in a stochastic former; unrecordable "which rule" story | D4 — per-rule per-run, the issue's own unit |
| Persistent audit log (Q4) | Cross-session record | CRAN write policy; the app's one write path is user-directed download | D4 — #150 manifest mold |
| Mate-pair surface in v1 (Q5) | One rollout for both surfaces | Second module's contract re-opened; 5th slice; surface the issue doesn't name | D5 — deferred additive follow-up |
| Extend `convertAncestry()` with BORDERLINE_HYBRID (Q6) | Makes the yellow branch reachable | QC vocabulary change rippling through every ancestry-bearing pedigree and the Origin heatmap | D6 — independence; discrepancy documented, its own issue if wanted |
| Hardcoded conservative UNKNOWN handling (Q6) | Guardrail can't be silently defeated | Blocks most formations in sparse-ancestry colonies; package owns a stance centers should own | D6 — centers write UNKNOWN/OTHER rules; coverage is always surfaced |
| Formation-time modal as primary UI (Q8) | Impossible to miss | Interrupts every run; trains click-through | D8 — collapsed section + results tab; modal reserved for overrides |
| Companion view beside the Origin heatmap (Q8) | Reuses an ancestry-aware surface | Splits the workflow across modules; the heatmap is the post-hoc reporting #168 moves beyond | D8 — guardrails live where formation lives |

---

## 9. Close-out checklist mapping

Design-only session — no `R/`/`tests/`/`man/` changes, so every checklist is **N/A this
session**, owed at the §5 slices:

- **NEWS.Rmd (plain-language, S628):** owed at Slices 1, 2, 4 (exported functions / the
  UI); Slice 3 expected internals-only (record the N/A).
- **`_pkgdown.yml` reference coverage:** owed at Slices 1 and 2 (each new `@export`);
  Slice 4 if any export lands.
- **Citation checklist (issue #120):** run at Slice 4; expected N/A (violations/coverage
  are rule bookkeeping, not statistics) — recorded, not assumed.
- **Tutorial/article checklist (S436):** owed at Slice 4 (the user-facing UI), including
  the D6 UNKNOWN/OTHER guidance.
- **`a2interactive.Rmd` checklist:** deferred to the standing documentation pass, per its
  own rule (new exported functions from Slices 1–2 and the `groupAddAssign()` argument
  join that pass's inventory).
- **Lint close-out:** every slice (each touches `.R` files).
- **CI e2e group registration:** Slice 4's new `test-e2e-*` file registers its
  `.github/workflows/shinytest2.yaml` group regex in the same session (S760 gotcha 7).
- **Issue close-out:** #168 stays open through the slices; the Slice 4 close-out makes
  the explicit open/close call (§5).

---

## 10. Provenance

Built from the S761 scoping record
(`docs/planning/issue168-ancestry-guardrails-scoping-2026-09-22.md`) — issue body, audit
gate context, 14-row evidence inventory, Q1–Q9 — plus this session's direct source
verification of every load-bearing claim (§1.3): `R/groupAddAssign.R` (signature, `kin`
construction, mode fork, sampling loop, exhaustive branch), `R/fillGroupMembers.R:75`
(the seam), `R/getAnimalsWithHighKinship.R` + `R/filterPairs.R` +
`R/kinMatrix2LongForm.R:28` + `R/addAnimalsWithNoRelative.R` (conflict-list mechanics and
symmetry), `R/convertAncestry.R:19,42-45` (vocabulary; non-idempotency measured),
`R/getIndianOriginStatus.R:18-46` (unreachable yellow branch),
`R/getGeneticDiversityStats.R:81-118` (post-hoc Origin), `R/qcStudbook.R:256-257`
(re-standardization call site), `R/modBreedingGroups.R` in full (UI density, server flow,
sidecar reactives, formation call, results tabset, downloads, `gatedSeed` hook),
`R/modDeidentifiedExport.R:1-160` (manifest + warning text + confirm gate mold),
`R/modGeneticValue.R:249-250` (upload validate-notify mold), `R/reportMatePairs.R:60-130`
(signature, `excluded`/`reason` shape), `R/appServer.R:340-470` (module wiring; no change
needed), `R/set_seed.R:41` (`gatedSeed`), `docs/architecture/module-contract.md` (rules
1–6), and measured fixture facts (`examplePedigree$ancestry` raw JAPANESE 2322 / UNKNOWN
1372 and post-QC JAPANESE 2322 / OTHER 1372; `qcPed` column list). Repo-wide collision
greps for every §4 name: clear. Mold document read in full:
`docs/planning/issue167-longitudinal-monitoring-plan.md` (structure and ratification
shape). No decision above rests on an unverified claim.

---

## 11. Ratification status — forced vs. judgment-call decisions

**Forced / evidence-determined (no vote; listed for the implementing sessions):** D4
(the issue's own words fix per-rule granularity; CRAN policy + the #150 mold fix the
manifest shape), D6 (vocabulary and independence are evidence-determined; the
no-hardcoded-stance unknown handling is the only variant that neither silently defeats
the guardrail nor blocks sparse-ancestry colonies, with coverage surfacing as the
countermeasure; loud degradation split script-`stop()` / app-notice by each surface's
contract), D7 (direct consequence of the zero-change hard constraint + the RNG mechanics
in §1.3), D9 (dependency-forced order). The active-default question inside Q1 is also
evidence-determined (ruled out by the zero-change constraint — example file only).

**Genuine judgment calls put to the owner in one `AskUserQuestion` round:** D1 (rule
model: pairwise table vs. composition DSL vs. both), D2 (configuration surface: rules
file vs. site-config vs. in-app only), D3 (enforcement scope: sex-blind vs. M×F-only vs.
per-rule sex column), D5 (v1 surfaces: group formation only vs. + mate-pair), D8 (UI
placement: in-module section + tab vs. formation-time modal vs. companion view).

### Ratification outcome (2026-09-22, this session)

Owner selected this document's own recommended option in all five cases, via a single
`AskUserQuestion` round (two tool calls, 4 + 1 questions — the tool's 4-question cap):

- **D1 — pairwise compatibility table; example rules file ships, active behavior does
  not.** Per-rule `block` | `flag` severity; unordered pairs over the 6 standardized
  levels; composition DSL and proportion rules stay out of v1.
- **D2 — user-supplied rules file** through `readAncestryRules()`/`checkAncestryRules()`
  (CSV/Excel, the kinship-overrides mold), uploaded in-app and script-callable;
  site-config residence declined.
- **D3 — sex-blind enforcement.** Rules bind every within-group pair regardless of sex;
  ancestry conflicts deliberately bypass the F-F kinship exemption (pinned by test);
  per-rule sex scoping remains additive later.
- **D5 — v1 surfaces are `groupAddAssign()` + `modBreedingGroups` + the script API**
  (`reportAncestryViolations()`); the mate-pair integration is recorded as a deferred
  additive follow-up with its own future gate, not ratified here.
- **D8 — collapsible in-module "Ancestry Guardrails" section + "Ancestry" results tab +
  #150-mold confirm gate for overrides.** No formation-time interruption for flag-only
  results; fixtures are new files, never edits to shipped data objects.

No changes requested to any recommended design. **This design is ratified and ready for
Slice 1 implementation in a future session** — matching the
#133/#136/#137/#145/#146/#147/#149/#150/#151/#152/#153/#167 precedent of a design-only
session with zero `R/`/`tests/`/`man/` changes. Issue #168 stays intentionally open
(design ratified, not yet implemented); no `gh issue close` this session.
