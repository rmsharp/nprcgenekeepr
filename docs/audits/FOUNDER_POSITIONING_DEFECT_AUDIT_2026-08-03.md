# Pedigree Diagram Founder-Positioning Defect — Real-Fixture Characterization Audit

**Date:** 2026-08-03 · **Session:** S470 · **Type:** code-defect characterization audit
(investigation only — no code changes, no fix designed)

**Audited:** `R/makePedigreeDiagramData.R`'s `.buildMatingUnitForest()` (D1/D2) and
`.positionMatingUnitForest()` (D3/D4/D5) node-positioning logic, run against the
package's real bundled pedigree fixtures under `inst/extdata/examples/`.

**Question asked (BACKLOG.md, found S463, `DECISION NEEDED`):** the founder-positioning
defect — a founder who mates into a later generation renders at the wrong row — was
confirmed only against two synthetic kinship2 reference examples
(`docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`). That document
explicitly left open "how often it occurs in practice" against real data, and
recommended this be established before a fix is designed. This audit answers that
question, and (prompted by an owner observation mid-session) also asks whether the
defect is actually a gap in this codebase's own duplicate-node mechanism (D6) rather
than an isolated coordinate bug.

---

## Method

1. Read `.buildMatingUnitForest()` and `.positionMatingUnitForest()` in full
   (`R/makePedigreeDiagramData.R:134-614`) to establish the exact mechanism, before
   writing any detection code.
2. Re-read the prior synthetic findings in
   `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd` to confirm this
   audit's detection method operationalizes the same defect, not a different one.
3. Inventoried `inst/extdata/examples/*.csv` for genuinely **real** (not synthetic)
   bundled pedigree fixtures usable with `makePedigreeMatingLayout()`'s
   `id`/`sire`/`dam`/`sex`/`gen` contract.
4. Wrote and ran a detection script (`makePedigreeMatingLayout()` +
   `nprcgenekeepr:::.buildMatingUnitForest()`, no package code changes) that, for every
   mating unit, compares each parent's rendered node row (`y`) — the parent's own real
   node if no duplicate exists for that occurrence, or the specific duplicate node if
   one does — against the mating unit's own rendered row.
5. Manually spot-checked one finding by hand against the raw `ped` data before trusting
   the aggregate counts.
6. **Independently re-derived the finding via a separate Workflow agent** given only the
   mechanism (not this session's script or numbers), which wrote its own detection code
   from scratch and additionally established the general mechanistic rule (below) —
   used here as adversarial verification, not as the primary evidence.

---

## Audit Summary

- **Scope:** real bundled pedigree fixtures under `inst/extdata/examples/` runnable
  through the shipped Option 2 layout pipeline.
- **Criteria:** does every parent's rendered row match its own mating unit's rendered
  row?
- **Coverage:** 2 of 4 real-or-real-labeled fixtures yielded independent real-colony
  data (see Items Audited); 1 fixture (`ExamplePedigree.csv`) is explicitly documented
  synthetic and excluded; 1 fixture (`rhesusPedigree_fromCenter.csv`) turned out to be
  the same dataset as another fixture already in scope (Finding #4) and is not double
  counted.
- **Finding count:** 1 critical (confirmed, high-prevalence defect), 1 moderate
  (defect scope broader than previously characterized), 1 minor/incidental
  (unrelated fixture-provenance documentation gap).

## Findings

### Finding #1: Confirmed, high-prevalence — not a rare edge case
- **Severity:** Critical (for design-priority purposes; this is a characterization
  audit, not a code fix)
- **Location:** `R/makePedigreeDiagramData.R:585-591` (`nodes` construction in
  `.positionMatingUnitForest()`)
- **Description:** On the real 375-individual rhesus fixture
  (`obfuscated_rhesus_mhc_ped.csv`), **147 of 237 mating units (62%)** have at least one
  parent rendered at the wrong row.
- **Evidence:**
  ```
  individuals=375  matingUnits=237  duplicateNodes=128
  findings=147 (onDuplicateNode=57, onFreePassLeaf=90)
  rowMismatch magnitude: -1 (x75), -2 (x54), -3 (x12), -4 (x6)
  125 distinct individuals affected
  ```
  Manually confirmed example: `FD3BB6` is a genuine founder (`sire`/`dam` both `NA`,
  own `gen = 0`) who mates with `AU22BC` (`gen = 1`) in `__union_59`
  (`matingUnits$gen = 1`, matching `AU22BC`). `FD3BB6` renders at `y = 0` (row 0); the
  union and `AU22BC` render at `y = 150` (row 1). Independently re-derived by a
  from-scratch Workflow agent: identical counts (237 / 147 / 57 / 90), plus a clean
  general rule — **a parent-occurrence mismatch occurs if and only if that parent's own
  `ped$gen` differs from its mating unit's `gen` (`pmax(sireGen, damGen)`)**, with zero
  exceptions in either direction across all 474 parent-occurrences checked.
- **Impact:** the Diagram tab visually implies incorrect mating pairs for the majority
  of real mating units in the bundled rhesus fixture, not an occasional cosmetic
  glitch. A founder marrying into a later generation is an ordinary case in real
  breeding-colony pedigrees (age gaps between mates are routine), so this is expected
  to recur broadly on live colony data, not just this fixture.
- **Recommendation:** design a fix (not undertaken in this audit — see
  Recommendations below).

### Finding #2: Defect scope is broader than "founders" — it also affects genuine multi-mate duplicate nodes
- **Severity:** Moderate (a scoping correction to Finding #1 and to the prior
  synthetic-only characterization, not a new independent defect)
- **Location:** same as Finding #1 — `nodes$gen = c(unname(genOf[realIds]),
  unname(genOf[duplicates$realId]), matingUnits$gen)`. Note that duplicate nodes use
  `genOf[duplicates$realId]` — the same "parent's own global gen" lookup used for
  ordinary real nodes — with **no reference to which specific mating unit the
  duplicate represents**.
- **Description:** `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`
  characterized this only for **free-pass** individuals (a single-mate, never-anchor
  parent with no duplicate node at all). The real-fixture data shows **57 of the 147
  mismatches (39%) occur on genuine duplicate nodes** — i.e. individuals who *do* mate
  multiple times and *do* already get the existing D6 duplicate-node treatment still
  render at the wrong row whenever one of their several mating units sits at a
  different generation than their own. The root cause is not specific to founders or
  to the free-pass code path; it is that **no non-anchor parent occurrence, duplicated
  or not, is ever positioned using its own mating unit's row** — every such occurrence
  uses the parent's single, global tree-native `gen` instead.
- **Impact:** a design that fixes only the free-pass/founder case (e.g. by widening
  when a duplicate node gets created) would still leave 57 real-fixture instances
  (39% of the total) broken, because the existing duplicate mechanism's own row
  assignment has the identical bug.
- **Recommendation:** any future fix should correct the row assignment for **both**
  free-pass and duplicate non-anchor occurrences uniformly (see Structural
  Observations), not just widen the duplicate-creation trigger.

### Finding #3: Real Japanese macaque colony data shows the same pattern (small applicable N)
- **Severity:** Minor (confirmatory, not additional new evidence of prevalence — the
  fixture's pedigree completeness is too sparse to estimate a rate)
- **Location:** same mechanism, different fixture
  (`inst/extdata/examples/deidentified_jmac_ped.csv`, 2,791 individuals, a distinct
  real de-identified colony pedigree, different species).
- **Description:** only 2 of 2,791 individuals have **both** parents recorded (most
  records carry at most one known parent, so almost the entire fixture falls into the
  D5 one-known-parent direct-edge path, which this defect does not touch). Both of the
  2 resulting mating units show the defect (both on the `dam` side, magnitude -3 and
  -4 rows).
- **Impact:** confirms the defect is not specific to one species/fixture, but this
  fixture's own pedigree completeness is too low to add a meaningful second prevalence
  estimate.

### Finding #4 (incidental, out of scope — reported per this project's own
precedent for unrelated pre-existing gaps, not fixed here)
- **Severity:** Minor, documentation-only
- **Location:** `data-raw/rhesusPedigree.R:7-15`
- **Description:** the docstring claims `rhesusPedigree_fromCenter.csv` is the raw,
  pre-obfuscation source that `obfuscated_rhesus_mhc_ped.csv` was derived from via a
  non-deterministic id/date obfuscation. Directly comparing the two shipped CSVs
  (independently, via the verification Workflow) found they are **byte-identical on
  every shared column** (`id`, `sire`, `dam`, `sex`, `gen`, `birth`, `exit`, `age`) —
  `rhesusPedigree_fromCenter.csv` differs only by one added `fromCenter` column (all
  `TRUE`). As shipped, it is not an independent raw source; it carries no data the
  audit's primary fixture doesn't already have. This audit therefore does **not**
  double-count it as a second independent real sample for Finding #1.
- **Recommendation:** file as its own low-priority `BACKLOG.md` housekeeping item for
  a future session to reconcile the docstring against the shipped fixture (or
  regenerate the fixture to match the documented provenance) — not fixed in this
  audit-only session, consistent with `PROJECT_LEARNINGS.md` Learning 382.

## Items Audited

| Item | Type | Individuals | Real or synthetic | Status | Findings |
|---|---|---|---|---|---|
| `obfuscated_rhesus_mhc_ped.csv` | real bundled fixture | 375 | Real (obfuscated rhesus colony) | Audited | #1, #2 |
| `rhesusPedigree_fromCenter.csv` | real bundled fixture | 375 | Real (same data as above — Finding #4) | Audited, not double-counted | #4 |
| `deidentified_jmac_ped.csv` | real bundled fixture | 2,791 | Real (de-identified Japanese macaque colony) | Audited | #3 |
| `ExamplePedigree.csv` | bundled fixture | 3,694 | **Synthetic** — documented "not drawn from any real colony's records" | Excluded, reason recorded | N/A |

Coverage: 3 of 3 real-or-real-labeled bundled fixtures examined (100%); 1 synthetic
fixture explicitly excluded with reason.

## Structural Observations

- **The prior document's own framing under-scoped the fix.** It listed "founder
  positioning" and "narrower duplicate-trigger scope than kinship2" as two separate,
  unrelated gaps. Finding #2 shows they share one root cause: no per-occurrence row
  ever derives from its own mating unit's generation, whether that occurrence already
  gets a duplicate node or not. **This directly matches the owner's own mid-session
  framing** — this codebase's established convention for "one individual needs
  multiple-level representation" is node duplication (D6), and the cleanest fix
  direction is likely to make that convention consistently correct (assign every
  non-anchor occurrence's row from `unitGenOf[thatOccurrence'sMatingUnit]` rather than
  the parent's own global `genOf[realId]`) rather than treating founders as a special
  case.
- **This is a coordinate-assignment defect, independent of issue #142's edge-routing
  style**, confirmed again on real data — it would survive unchanged under either
  `edgeStyle`.
- **62% prevalence on the real fixture is a strong signal this is common, not rare**,
  reversing the uncertainty `BACKLOG.md` currently records ("not yet confirmed against
  a real bundled fixture").

## Comparison with Prior Audits

| Metric | `pedigree-diagram-kinship2-reference-comparison.qmd` (S463, synthetic only) | This audit (S470, real fixtures) |
|---|---|---|
| Cases confirmed | 2 (synthetic kinship2 `sample.ped` families) | 147 (real 375-individual fixture) + 2 (real 2,791-individual fixture) |
| Scope characterized | Free-pass founders only | Free-pass **and** genuine duplicate-node occurrences (Finding #2) |
| Real-world prevalence | Unknown, explicitly flagged as needing this follow-up | 62% of mating units in the real rhesus fixture |
| Fix designed | No (out of scope) | No (out of scope — audit only) |

## Recommendations

1. **Design a fix in a dedicated plan-mode session** (per `SAFEGUARDS.md` — this
   touches shared `.positionMatingUnitForest()` logic already used by Slices 1/2).
   Candidate direction surfaced by this audit (not designed or implemented here):
   assign every non-anchor parent occurrence's row (real-node free-pass **or**
   duplicate-node) from its own mating unit's `gen`, not the parent's global
   tree-native `gen`; separately decide whether the duplicate-creation trigger itself
   also needs widening (today: only created for individuals in >1 mating unit) or
   whether fixing the row formula alone resolves both Finding #1 and #2.
2. **File as its own GitHub issue, not folded into #142.** Issue #142's Slices 1-2
   (edge-routing style) are shipped/done; this is an analytically separate "where do
   nodes get placed" defect (confirmed independent of `edgeStyle` above), and now has
   confirmed high real-world prevalence that justifies its own tracked issue rather
   than remaining a `BACKLOG.md` line only.
3. **File Finding #4 (fixture-provenance documentation drift) as its own separate,
   low-priority housekeeping item** — unrelated to the founder-positioning defect,
   not fixed in this session.
