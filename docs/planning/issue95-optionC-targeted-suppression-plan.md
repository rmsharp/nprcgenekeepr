# Issue #95 Plan — Option C: targeted suppression of the kinship-override / unknown-parent (#9) correction

> **⚠ SUPERSEDED — Session 234 (2026-06-28), via `/grill-me`.** A firsthand-verified reframing found that the targeted-suppression premise — and its parent, D11 blanket supersession — **over-corrects by ~N (≈280×)**. An override's value is already in `original` *before* the `+ sexMean / 2` correction runs (verified: `prepareKinshipOverrides.R:49` → `reportGV.R:148` → `:157`), so the prior should shrink by only ~1/N per override (~0.0048 SD), not be dropped (~1.33 SD). **Ratified disposition: revert the prior-suppression to keep-all and REMOVE the option-C machinery** (the `missingSideFor` column, `classifyOverrideMissingSide()`, the `suppressIds` path). **Rule (ii) / partial-residual and C1.2 are resolved here as won't-build**; issue #95 stays open for follow-ups 2/3 only. Sections §1–§8 below are retained as the historical record of option C *as it was built and shipped (Slices 1–2, S229–S233)*. **The current decision, evidence, and the revert plan are in §9 — read it first.**

**Tracks:** GitHub issue **#95** ("Refine kinship-override / unknown-parent (#9) correction interaction beyond v1 blanket supersession (D11 follow-ups)"), **follow-up 1 (option C)**. Filed Session 225 (2026-06-28). Issue #95 also tracks two genetics-methodology follow-ups (both-unknown→one-unknown promotion; shared-unknown-parent sib-pair coupling) that are **out of scope for this plan** (see §1, "What this plan does NOT cover").

**Tracks (parent):** issue **#13** (kinship overrides) decision **D11**, ratified Session 214. This plan extends `docs/planning/issue13-kinship-overrides-plan.md` (the D1–D11 decision record). Option C was explicitly deferred at D11 ratification with the note *"track targeted option C as a follow-up — needs override-side metadata the `id1/id2/kinship` schema does not carry"* (`issue13-kinship-overrides-plan.md:153,212`).

**Authored:** Session 226 (2026-06-28), **planning/architecture session.** The owner picked this as the session deliverable. The TDD code-phases (RED / GREEN / REFACTOR) are **inapplicable to this document** — it is a design doc, not code. Each implementation slice in §4 is its own strict-TDD session (RED → GREEN → REFACTOR), one slice per session (FM #18/#25: do not bundle plan + implementation, do not bundle slices).

> **STATUS: RATIFIED — Session 227 (2026-06-28), Phase 0.** C1 (+C1.1/C1.2/C1.3) and C2 were settled via a `/grill-me` session grounded in a firsthand numeric check on real `qcPed` (the D11 evidentiary bar; recorded in §8). C3/C4/C5/C6, the slice order, and the D10 invariant were confirmed as recommended. The §7 checklist below is now fully ratified, and §8 records the ratification (decisions, evidence, reproduction recipe, and the reframing the evidence surfaced). **Slice 1 RED is now unblocked** as a SEPARATE later session (FM #18 — do not bundle plan ratification with implementation; this session's deliverable is the ratified decisions only). The original draft framing is preserved below for the rationale that led to each call; where §3 still reads "planner recommendation," §7/§8 record the owner's ratification of it.

> **Scope of writing this doc.** This is the planning deliverable. **No `R/`, `tests/`, `man/`, `NAMESPACE`, or `data/` content is changed by writing it.** The evidence-based inventory in §2 is firsthand — every `file:line` was read (or grepped) during Session 226, and supersedes any drifted citation in the parent plan (e.g. the `+ sexMean / 2` add is **`correctUnknownParentMeanKinship.R:190`**, not the parent plan's stale `:175`).

> **Adversarial verification (S226).** This draft was put through a 3-agent verification workflow (`wf_38c97263-a2e`: citation accuracy — ~60 `file:line` refs checked; design red-team; consumer-inventory completeness), mirroring the parent plan's S213 verification. ~60 citations were exact; **the pass found and this revision fixes six substantive issues:** (1) a **high-severity D10 contradiction** in the C1 absent-column default (was "keep prior" — must be "blanket-A / suppress"); (2) the C3 NULL-default-param design (replaced with a cleaner *caller-computes-the-suppress-set* approach — no new param, no `NULL`-vs-empty ambiguity); (3) a **wrong claim** that `gvaConvergence` computes parentage *before* its correction call (it is *after*, `:169` vs `:157-163` — confirmed firsthand; **both** callers need the side classification, neither has parentage available); (4) the side classification needs `isU(ped$sire/dam)`, **not** a `classifyParentage` hoist (which returns the parentage *class*, not the side); (5) rule (i)'s genetics framing (it trades the case-(b) over-credit for a *scoped* missing-side over-credit — strengthening why C2 is a real genetics call); (6) an **expressiveness gap** (a single-id side column cannot encode a pair informing *both* endpoints' missing sides) and **three missed doc/test surfaces** (`genetic_value.html`, `summary_stats.html`, `test_kinshipOverrideDocs.R`). All are folded in below.

---

## 1. Context

### What blanket-A does today, and where it is genetically imperfect

D11 (shipped, ratified S214) settled the override/#9 interaction with **blanket supersession (option A)**: for any animal missing exactly one parent that *also* carries an outside-information kinship override, the issue-#9 `+ sexMean / 2` mean-kinship correction is **skipped entirely** — a known outside value supersedes the random-mating prior. The guard is a single id-set membership test:

```r
# R/correctUnknownParentMeanKinship.R:162-171 (current)
for (i in which(oneU)) {            # oneU = xor(sireMiss, damMiss), :152
  focalId <- candidateIds[i]
  if (focalId %in% overriddenIds) { # :164  blanket, id-level — NO side attribution
    next                            # :170  skip the +sexMean/2 add at :190
  }
  ...
}
```

The `+ sexMean / 2` prior models the animal's **entire missing parent** as a typical contemporaneous opposite-sex peer (`:189-190`). Blanket-A drops that prior whenever *any* override touches the animal — but an override is a pair-level kinship value with no record of *which side* it informs. Two genetically distinct cases collapse into one:

- **Case (a) — the override stands in for relatedness through the MISSING parent** (e.g. a known half-sib via the unrecorded dam). Here suppression is *correct*: real information about the missing side supersedes the average-peer prior.
- **Case (b) — the override corrects a KNOWN-parent-side pair** (e.g. an under-counted half-sib through the recorded sire), and says nothing about the missing side. Here blanket-A **wrongly discards** the missing-parent prior, so the animal's mean kinship is *under*-estimated — it looks rarer / higher genetic value than it is.

**Why it matters (firsthand magnitude, from the D11 grill, S214):** the `+ sexMean / 2` term is ≈ **1 SD** of the colony mean-kinship distribution (~8.4× an override's own raw effect); on real `qcPed` it flipped a worked animal from **GV rank #6 → #179**. So getting case (a) vs case (b) right has real ranking impact — which is exactly why option C is worth doing and why a wrong residual rule (C2) would itself mis-rank animals.

### Option C in one sentence

Suppress `+ sexMean / 2` **only** for one-unknown animals whose override stands in for the **missing** side (case a); **keep** the full prior for animals carrying only known-side overrides (case b).

### The blocker (why this is plan-mode-before-RED, not a drop-in slice)

The override schema is `id1`, `id2`, `kinship` (D2/D3 — a symmetric REPLACE-a-cell write). The missing parent is *unrecorded* — no id, no pedigree edges — and a kinship value is **path-agnostic** (0.125 could be a half-sib via the missing dam, an under-counted known-sire half-sib, or coincidence). The function already knows the focal animal's *own* missing side (`missingSex <- if (sireMiss[i]) "M" else "F"`, `:172`), but it cannot know **which side a given override informs**. Option C therefore needs **two prerequisites**, both decided before any code:

1. **A schema extension (C1)** — a 4th column that lets an override row say which side it stands in for, bound to a focal animal.
2. **A residual genetics-modeling rule (C2)** — how a (possibly partial) missing-side override combines with the leftover unknown-parent prior. This is the genetics call (the D11-equivalent dragon).

### What this plan does NOT cover (explicit scope boundary)

- **Issue #95 follow-up 2** (both-unknown → one-unknown promotion) — a *parentage-reclassification* decision; issue-13 v1 never reclassifies parentage. Out of scope; remains a separate genetics call.
- **Issue #95 follow-up 3** (shared-unknown-parent sib-pair joint modeling) — a *joint-modeling* decision; the per-focal loop is independent by design. Out of scope; separate genetics call.
- **The deferred descendant-propagation** (D3 limitation — overrides patch named cells only) — unchanged; option C is still a direct-cell feature.
- **The cross-module de-dup refactor** (have a shared helper return both the patched matrix and the override id-set, de-duping `reportGV` / `gvaConvergence` / `modSummaryStats`) — option C *touches* the same two call sites and should not *widen* their divergence (§2C, C5), but the full de-dup is its own plan-mode item carried since S221.

---

## 2. Evidence-based inventory (firsthand — Session 226, current line numbers)

### 2A. The behavior site — `correctUnknownParentMeanKinship` (the only place the rule changes)

| Construct | File:line | Fact |
|---|---|---|
| signature + params | `R/correctUnknownParentMeanKinship.R:127-132` | `indivMeanKin, ped, gestationTable=NULL, breedingTable=NULL, breedingAgeDefault=NULL, gestationDefault=NULL, overriddenIds=character(0L)` |
| `overriddenIds` param | `:132` | the **blanket** id-set (last arg); the only override info the fn has |
| unknown-parent test | `:149` | `isU <- function(x) is.na(x) | isGeneratedUnknownId(x)` |
| per-side miss flags | `:150-151` | `sireMiss <- isU(candPed$sire)`; `damMiss <- isU(candPed$dam)` |
| one-unknown detection | `:152` | `oneU <- xor(sireMiss, damMiss)` |
| uncorrected snapshot | `:160` | `original <- indivMeanKin` (cohorts average this) |
| per-focal loop | `:162` | `for (i in which(oneU))` |
| **blanket guard** | `:164-171` | `if (focalId %in% overriddenIds) { ... next }` — skips the add |
| **focal's missing side** | `:172` | `missingSex <- if (sireMiss[i]) "M" else "F"` — already known per focal |
| cohort `sexMean` | `:189` | `sexMean <- mean(original[cohort])` |
| **the `+ sexMean / 2` add** | `:190` | `corrected[focalId] <- min(original[focalId] + sexMean * 0.5, 1.0)` |

**Load-bearing fact:** the function already derives the focal's *own* missing side (`:172`) but has *no* per-override side attribution — `overriddenIds` is a flat character vector. Option C's gating needs the subset of overridden ids whose override informs the **missing** side.

### 2B. The two threading call sites — and their (non-obvious) asymmetry

`correctUnknownParentMeanKinship` has exactly **two** callers in `R/` (confirmed by grep — `reportGV.R`, `gvaConvergence.R`); they must stay in lockstep.

| Site | Build `overriddenIds` | Apply to matrix | Correction call | `classifyParentage` call |
|---|---|---|---|---|
| `reportGV` | `:140` init → `:142` `checkKinshipOverrides()` normalizes → `:143-156` warn-drop non-members → `:159` `unique(c(overrides$id1, overrides$id2))` | `:158` `applyKinshipOverrides(kmat, overrides)` | `:173-180` (`overriddenIds=` at `:179`) | `:258` (on `demographics` built `:227`) — **AFTER the correction call** |
| `gvaConvergence` | `:147` init → `:149-150` mask on **raw** `kinshipOverrides` (no `checkKinshipOverrides`) → `:151-153` `unique(c(...id1[inMatrix], ...id2[inMatrix]))` | `:155` `applyKinshipOverridesToMatrix(kmat, kinshipOverrides)` (**different wrapper**) | `:157-163` (`overriddenIds=` at `:162`) | `:169` (on `demographics` built `:168`) — **AFTER the correction call** |

**The side classification does NOT depend on `classifyParentage` (corrected per S226 verification).** `classifyParentage` returns the parentage *class* (`{both-known, one-unknown, both-unknown}`, `classifyParentage.R:24-26`), **not which side is missing**. Option C's per-animal missing side is `isU(ped$sire)` vs `isU(ped$dam)` — the exact `isU` logic the correction already runs internally (`correctUnknownParentMeanKinship.R:149-152`). `ped` (and `probands`) are in scope at the **top** of both callers, so the side classification can be computed there with no hoist of `classifyParentage` (and no dependency on `demographics`). Both callers compute `classifyParentage` *after* the correction; that ordering is irrelevant to option C.

**Three divergences option C must reconcile** (they produce the same id-set *today*, but option C makes them matter):
1. **Side classification must be added at BOTH callers** — each must compute, before its correction call, the subset of overridden one-unknown ids whose override informs the *missing* side, from `isU(ped$sire/dam)` + the new side column. Neither has it today (this is the behavior change). There is **no asymmetry** to exploit — both need the same new step (an earlier draft wrongly claimed gvaConvergence already had parentage in hand; it does not).
2. **Normalization** — `reportGV` runs `checkKinshipOverrides` (where the new column is validated/defaulted); `gvaConvergence` reads raw. To classify sides consistently, gvaConvergence must also see the validated/defaulted side column.
3. **Apply wrapper** — `applyKinshipOverrides` vs `applyKinshipOverridesToMatrix` (the latter delegates to the former internally, but the surrounding code differs).

### 2C. The schema choke points — what a 4th column touches

| Concern | File:line | What changes for a 4th column |
|---|---|---|
| **Validator — STRUCTURAL only (`checkKinshipOverrides`)** | `R/checkKinshipOverrides.R:34` (`required <- c("id1","id2","kinship")`), `:35-40` required-check, `:41-42` id-coerce, `:44-55` domain checks, `:56-64` unordered-pair dedup (`paste(lo,hi,sep="\r")`, `anyDuplicated`→`stop`), `:65-71` f-not-r warn | Add the side column to `required` (if mandatory) or an optional-presence test after `:40`; **structurally** validate its values (e.g. `side ∈ {id1, id2, ""}`); **fold side into the dedup key (`:57-64`)** IFF a pair may legitimately carry two sides (else the same pair + 2 sides is wrongly rejected). `applyKinshipOverrides.R:39` calls this validator — it is the single *structural* validation point. **It takes NO `ped`** (`checkKinshipOverrides(overrides)`), so it CANNOT verify the named focal is actually one-unknown or that relatedness plausibly flows through the missing side — those are **semantic** checks that belong at the caller (next row). |
| **Side classification — SEMANTIC (the caller, with `ped`)** | `R/reportGV.R` (top, where `ped`/`probands` are in scope) and `R/gvaConvergence.R` (likewise) | Build the missing-side suppress subset here: join each surviving override's side annotation against `isU(ped$sire/dam)` per focal one-unknown animal. This is where the structural side label becomes a genetics decision (is the named focal one-unknown? does the side match?). See C5. |
| **Matrix apply (side-agnostic — NO change)** | `R/applyKinshipOverrides.R:36-38` no-op guard, `:42`/`:49-51` columns by name, `:60-61` symmetric write; `R/applyKinshipOverridesToMatrix.R:23-42` guards + `:38` `overrides[inMatrix, , drop=FALSE]` (row filter keeps all cols) + `:43` delegates to `applyKinshipOverrides` | **None.** All column access is by name (`$id1/$id2/$kinship`); the only positional index is a row filter that carries extra columns through. A 4th column is silently ignored by the write. |
| **Reader (read-side — minimal)** | `R/readKinshipOverrides.R:34-46` (`read.table(... check.names=FALSE)` / Excel branch; passes ALL header columns through; no selection/validation) | **None to read.** The side column rides through; it is *accepted-and-defaulted* in the validator. |
| **Round-trip (export has NO side source)** | `R/kinMatrix2LongForm.R:36,41` emits exactly `id1,id2,kinship` | A matrix cell carries no side → the side column is **import/edit-only** (the user hand-adds it). Absent-column default in the validator preserves byte-identical behavior for every pre-existing file (D10). |
| **Upload UI (helpText)** | `R/modGeneticValue.R:53-56` helpText (3-col schema), `:59` `fileInput`, `:62-78` second helpText (**already flags the missing-parent limitation at `:74-77`**), `:178-203` parse (`readKinshipOverrides` `:185` wrapped in `checkKinshipOverrides` `:184`), `:271` threaded into `reportGV` | Document the side column in the helpText; the parse path is unchanged (validator handles it). **No downloadable template exists** (the module's only downloads are GVA exports, `:422,:427`) — so no template to update; burden is on the user to hand-author the side per row. |
| **Upload UI (guidance HTML — MISSED by file-scoped readers; found in verification)** | `inst/extdata/ui_guidance/genetic_value.html:50-61` — a **second** user-facing copy of the override doc; `:58-61` states the missing-parent edge cases are "a current limitation" (the exact text option C revises). `inst/extdata/ui_guidance/summary_stats.html` — relationship-table guidance (may not change, but is a pinned doc surface) | Update `genetic_value.html` in lockstep with the helpText (Slice 2). These HTML files are asserted by a doc-consistency test (next table, §2D) — editing them without updating the test breaks the suite. |
| **App wiring (pass-through)** | `R/appServer.R:293,316` thread `kinshipOverrides=gvResults$kinshipOverrides` into `modBreedingGroups`/`modSummaryStats`; consumed at `modBreedingGroups.R:229`, `modSummaryStats.R:379,392` (fallback matrix apply only — **no #9 correction**) | **None** (side-agnostic matrix apply); the extra column rides through as data. |
| **Relationship-table flag (optional)** | `R/flagOverriddenRelationships.R:33` (`relationships$overridden <- rowKeys %in% overrideKeys`) | **Optional / display-only.** Could append an `overriddenSide` column after `:33`; needs an extra arg or derivation. Non-load-bearing for the behavior change (defer — matches D9). |
| **Man pages (regenerate, never hand-edit)** | `man/applyKinshipOverrides.Rd:12`, `checkKinshipOverrides.Rd:10`, `readKinshipOverrides.Rd:17`, `gvaConvergence.Rd:70`, `reportGV.Rd:61`, `modBreedingGroupsServer.Rd:25`, `modSummaryStatsServer.Rd:36` | ~7 `.Rd` name the 3-column schema inline; all roxygen-generated → fix the `@param/@details/@examples` in the source `R/*.R` and run `devtools::document()`. |

### 2D. Tests that pin current (blanket-A) behavior — the regression to refine

| Test | File:line | What it pins | Option-C impact |
|---|---|---|---|
| independent base-R oracle | `tests/testthat/test_reportGV.R:506-525` (`i13_correctBlanketA`, switch `if (id %in% overridden) next` at `:513`) | the blanket-A model the regression checks against | becomes the **case-(a) oracle**; a new `i13_correctOptionC` oracle is needed for case (b) |
| D11 regression block | `:539-588` (fixture `(X="0K7VJN", Y="N2XF08")=0.25` at `:555`, Z one-unknown peer) | parts 1–4: X suppressed (`:581`), Z keeps (`:583`), no-cascade (`:584-587`) | **flips depend on C4** (see below) |
| cohort-peer part | `:590-610` | overridden X stays a valid `sexMean` peer (raw flows, spurious term does not) | unchanged under option C |
| gvaConvergence mirror | `tests/testthat/test_gvaConvergence_kinshipOverrides.R:174` ("honors an override on a one-unknown-parent animal") + `:68,:96,:125,:149` | the gvaConvergence override path reuses the identical correction call | **Slice 2 must update** when gvaConvergence gains the side classification |
| correction unit tests | `tests/testthat/test_correctUnknownParentMeanKinship.R:111-259` | the function's own unit home (the suppress-guard behavior) | **Slice 1** — the unit-level RED for the side-aware suppress set lives here |
| validator unit tests | `tests/testthat/test_checkKinshipOverrides.R:57-64` (dedup) + the rest | the validator's column/domain/dedup behavior | **Slice 1** — RED for the side column accept/default/dedup-key |
| **doc-consistency test (MISSED — found in verification)** | `tests/testthat/test_kinshipOverrideDocs.R:21-78` | asserts required phrases in `modGeneticValueUI()`, `genetic_value.html`, and `summary_stats.html` — incl. "current limitation" + the missing-parent wording | **Slice 2 — these assertions BREAK when the limitation text is rewritten for option C; update in lockstep with the HTML/helpText** |

**Critical test-design finding (C4):** the fixture override `(X,Y)=0.25` at `:555` has **no side annotation**. If option C declares it **case (a)** → assertions `:574/:581/:587` stand and option C is *purely additive* (one new case-(b) test). If **case (b)** → `:581` flips (`imk[[X]] > original[[X]]`), the `:574` backbone repoints to the refined oracle, and the `:587` no-cascade assertion flips. **Pinning the existing fixture as case (a) keeps the regression additive** — the planner's recommendation (C4).

---

## 3. Design decisions (option C) — **RATIFIED Session 227** (see §7/§8)

Each shows the options, the **planner's recommendation**, and the kind of sign-off required. **C1 and C2 are the gates**; C3–C6 are architectural/test-design choices the planner can recommend and the owner confirms. **All are now ratified** (Session 227, Phase 0): C1=(a) `missingSideFor`, C2=(i), C3/C4/C5 as recommended, C6 deferred — see the §7 checklist for the ratified values and §8 for the evidence and reasoning.

### C1 — The 4th-column schema encoding. **[SCHEMA-DESIGN call — irreversible public contract.]**
What does the new column carry?
- **(a) A missing-parent-side annotation bound to a focal animal.** A column (e.g. `missingSideFor`) naming which of the row's two ids is the one-unknown focal animal whose **missing-side** relatedness this override stands in for — or empty / `"known"` when the override informs a known-side (or non-focal) pair. Smallest change; stays inside the REPLACE-cell semantics (D3); does not reclassify parentage.
- **(b) A surrogate-parent id.** The override names a stand-in id for the missing parent. Richer (could later feed propagation), but **bleeds toward parentage reclassification** (issue #95 follow-up 2, which v1 explicitly never does) and toward descendant propagation (D3's deferred limitation) — a much larger surface.

**Planner recommendation: (a)** — minimal, additive, contract-preserving; defer (b). **RATIFICATION REQUIRED** (irreversible schema; also brushes the follow-up-2 boundary).

**C1 sub-decisions the owner must settle (the verification pass found these are NOT cosmetic):**
- **C1.1 — two distinct defaults, NOT one (this resolves a D10 contradiction the draft had).** There are two different "absence" situations and they need OPPOSITE defaults:
  - **whole-file: the side column is absent entirely** (a pre-existing 3-column file) ⇒ the caller cannot classify ⇒ **treat every override as missing-side ⇒ suppress all ⇒ blanket-A.** This is what D10 requires (byte-identical to today). The caller achieves it by passing the FULL overridden set as the suppress set (C3).
  - **per-row: the column is present but a row's cell is blank** (the user opted into option C) ⇒ that row is **known-side ⇒ do NOT suppress** for it. A blank means "this override does not inform a missing side."
  An earlier draft used one value ("not a missing-side override") for *both*, which would make a pre-existing file KEEP the prior and break D10. Keep the two defaults separate.
- **C1.2 — the missing/known dichotomy is not exhaustive; the column needs a "both / diffuse" answer (or a documented limitation).** A single-id `missingSideFor` cannot encode: an override pair where BOTH endpoints are one-unknown and the kinship flows through both missing sides (naming one focal leaves the other over-credited); or a diffuse/molecular kinship that does not cleanly decompose into "via sire" vs "via dam." Options: allow `missingSideFor` to be a set / a `"both"` sentinel; allow two rows per pair (one per focal — needs the C1 dedup-key fix, OC-R6); or **document these as option-C v1 limitations** (planner leaning — they are rarer than the case-(b) the feature targets, and a `"both"` value can be added later). Owner's call.
- **C1.3 — mandatory vs optional column.** Planner recommends **optional** (a present column opts into option C; an absent column is blanket-A per C1.1). Mandatory would break every existing override test/file (see §2D "maybe" rows). The validator's side check is **structural only** (no `ped`); the semantic side classification is the caller's job (§2C, C5).

### C2 — The residual genetics-modeling rule. **[GENETICS-METHODOLOGY call — the #1 dragon; settle via `/grill-me`, as D11 was.]**
Given the side is known, how does a missing-side override combine with the `+ sexMean / 2` prior?
- **(i) Full-drop-on-any-missing-side-override (binary, side-gated).** If a one-unknown focal has ≥1 override standing in for its missing side → suppress the whole `+ sexMean / 2` (blanket-A's mechanic, correctly scoped to the missing side). Known-side-only overrides → keep the full prior. Simplest; tractable in one slice. **Honest caveat (verification finding — do not gloss over this at the grill):** a single override pins relatedness to ONE animal through the missing side; it says nothing about the focal's relatedness to the *rest* of the colony through that same unknown parent. Dropping the WHOLE ≈1-SD prior on one sparse observation **under-estimates** mean kinship for the un-overridden missing-side relationships — i.e. rule (i) *trades* the case-(b) over-credit for a smaller, scoped version of the SAME over-credit (up to ~1 SD). It removes the clearly-wrong case (a known-side override should not touch the missing-side prior) but is **not** the genetically complete answer.
- **(ii) Partial-residual (scaled add-back).** A missing-side override covers only *some* of the missing-side relatedness; keep a *reduced* `+ sexMean / 2` for the unobserved remainder. Genetically ideal (it is what removes rule (i)'s scoped over-credit), but `sexMean` is a **scalar cohort aggregate**, not pair-decomposable — defining "the unobserved remainder" needs a model the package does not have today. Much larger; likely its own follow-up.

**Planner recommendation: (i) for option-C v1 — but as a JUDGMENT for the geneticist, not a slam-dunk;** track (ii) as a further follow-up under #95. **RATIFICATION REQUIRED — genetics call.** `/grill-me` this against a firsthand numeric check on real `qcPed` (the D11 rigor): quantify, on a worked case, how large rule (i)'s residual scoped over-credit is versus the case-(b) error it removes. If (i)'s residual error is itself large, (ii) may be required for v1 rather than deferred.

### C3 — How the behavior is threaded (the cleaner design the verification surfaced). **[Architecture — planner recommends.]**
The earlier draft added an `overrideMissingSideIds = NULL` param. The red-team showed that creates a load-bearing `NULL`-vs-`character(0L)` ambiguity (NULL ⇒ blanket; empty ⇒ suppress none — *opposite* behaviors differing only by `is.null()` vs `length()==0`, a trap on the main path because `reportGV` always passes a computed — possibly empty — subset), plus a double-guard no-op risk. The cleaner design **moves the classification to the caller and keeps the function dumb:**
- **`correctUnknownParentMeanKinship`'s guard is UNCHANGED:** `if (focalId %in% overriddenIds) next` (`:164`). What changes is the **meaning of what the caller passes as `overriddenIds`** — redefine its contract from "ids carrying an override" to **"the set of one-unknown ids whose `+ sexMean / 2` to suppress."** (Update the `:117-122` docstring; the "still serves as a peer" note stays true — suppression never removes an animal from cohorts.)
- **Blanket-A (today; and Slice-1 `gvaConvergence`):** the caller passes the FULL overridden set ⇒ suppress all ⇒ blanket-A. **Byte-identical to today** (D10 holds trivially — same input, same output; no signature change).
- **Option C (Slice-1 `reportGV`; Slice-2 `gvaConvergence`):** the caller computes the **missing-side subset** (via `isU(ped$sire/dam)` + the side column, see C5) and passes ONLY those.

**Planner recommendation: this caller-computes-the-suppress-set design.** No new param, no `NULL`/empty ambiguity, no double-guard, no function signature change. The whole behavior change lives in the caller's computation of the set; the function is untouched (possibly just its docstring). **Consequence (forces C4):** under option C a *known-side-only* override on a one-unknown animal is NOT in the suppress set, so it KEEPS the prior (today blanket-A suppresses it) — the intended fix.

### C4 — Classification of the existing D11 regression fixture. **[Test-design — planner recommends.]**
The current `(X,Y)=0.25` fixture (`test_reportGV.R:555`) is unannotated.
**Planner recommendation: pin it as case (a)** (annotate `(X,Y)` as covering X's missing side) so `i13_correctBlanketA` stays the valid **case-(a)** oracle, the existing assertions (`:574/:581/:587`) stand, and option C is **purely additive** — add a new `i13_correctOptionC` oracle + a **case-(b)** test (a known-side override that KEEPS `+ sexMean / 2`). Owner confirms.

### C5 — Where the missing-side subset is built. **[Architecture — planner recommends.]**
The per-focal missing-side subset must be built where the override frame meets the pedigree — **at each caller, before its correction call.**
**Planner recommendation:** a small shared helper, e.g. `classifyOverrideMissingSide(overrides, ped, oneUnknownIds)` → returns the subset of one-unknown focal ids whose override informs their missing side, called by **both** `reportGV` and `gvaConvergence`. **Correction to the earlier draft (verification finding):** this needs `isU(ped$sire/dam)` per focal (the missing SIDE), **not** `classifyParentage` — which returns only the parentage class (`{both-known, one-unknown, both-unknown}`), not the side — so there is **no `classifyParentage` hoist** and **no `demographics` dependency**. `ped`/`probands` are in scope at the top of both callers, so the helper is called there. Both callers need this new step equally (no asymmetry — both compute `classifyParentage` *after* their correction, §2B, but option C does not use it). This is also the cleanest moment to *not widen* the reportGV/gvaConvergence divergence (normalize both via `checkKinshipOverrides`); folding in the full cross-module de-dup refactor is optional and can stay deferred.

### C6 — Provenance / display. **[Optional — planner recommends defer.]**
Optionally surface the side in the relationship table via `flagOverriddenRelationships.R:33` (an `overriddenSide` column). **Planner recommendation: defer** (display-only, non-load-bearing; matches D9's "minimal provenance in v1").

### D10 (inherited invariant — hard, every slice)
No side column ⇒ the caller passes the full overridden set ⇒ **byte-identical to today (blanket-A).** An explicit acceptance test in every slice.

---

## 4. Implementation plan — vertical slices (one strict-TDD session each)

Vertical, not horizontal (FM #25): each slice ships a working end-to-end path. **Gated on Phase 0.**

### Phase 0 (GATE, not a coding session) = ratify C1 + C2 via `/grill-me`
**Why first / why separate:** C2 is a genetics-methodology decision of the same class as D11 (which was `/grill-me`'d, not batch-ratified). C1 is an irreversible schema contract. **No RED may begin until both are ratified.**
**DONE looks like:** the §7 checklist filled in (C1 encoding + the C1.1/C1.2/C1.3 sub-decisions; C2 rule; C3/C4/C5 confirmed), grounded in a firsthand numeric check on real `qcPed` quantifying (i) vs (ii) on a worked animal — the D11 evidentiary bar.
**Session boundary:** the grill + decision record is its own session (mirrors S214). Close out. Implementation is later.
**Dragon:** do not let the planner's recommendations stand in for ratification — C2 especially is the owner's (geneticist's) call.

### Slice 1 (script core) = option C changes GV rankings from a script
**Prerequisite:** Phase 0 ratified.
**Scope:** (1) `checkKinshipOverrides` accepts + STRUCTURALLY validates the new side column (C1); a present-but-blank cell ⇒ known-side (per-row default, C1.1); fold side into the dedup key (`:57-64`) only if C1.2 allows two sides per pair. (2) `correctUnknownParentMeanKinship` is essentially UNCHANGED — redefine `overriddenIds`'s contract to "the suppress set" and update its `:117-122` docstring (C3); the `:164` guard stays. (3) new shared helper `classifyOverrideMissingSide(overrides, ped, oneUnknownIds)` (C5) using `isU(ped$sire/dam)` — **NOT** `classifyParentage`; `reportGV` computes it at the top (from `ped`/`probands`) and passes the missing-side subset as `overriddenIds` (`:179`) when the side column is present, else the FULL overridden set (blanket-A, C1.1 / D10). (4) refined regression: pin the existing fixture as case (a) (C4); add an `i13_correctOptionC` oracle + a case-(b) test (known-side override KEEPS `+ sexMean / 2`). (5) `devtools::document()` for the touched roxygen.
**RED:** `test_checkKinshipOverrides.R` — accepts the side column, structurally validates its domain, blank cell ⇒ known-side, dedup honors side. `test_correctUnknownParentMeanKinship.R` — passing the FULL set ⇒ blanket-A (unchanged); passing a strict subset ⇒ only those suppressed, the excluded one-unknown animals KEEP `+ sexMean / 2`. `test_reportGV.R` — case-(b) override keeps the prior; case-(a) suppresses (existing assertions stand); **no side column ⇒ `reportGV(qcPed)` byte-identical to today (D10)**.
**GREEN:** implement (1)–(5) minimally.
**DONE looks like:** a script user supplies the side column and a known-side override no longer drops the missing-parent prior, while a missing-side override still does; no side column ⇒ byte-identical to today.
**Verify:** `Rscript -e '...test_file(...)'` per touched test; clean regression read (`as.data.frame(testthat::test_dir(...))`, `sum(failed)+sum(error)`, isolate `!grepl("test-app-|test-e2e-", file)`, `NOT_CRAN=true`); `devtools::check(vignettes=FALSE)` → 0/0/0; `spell_check_package(".")` = 0. **No `runModularApp()` smoke** (no Shiny wiring in Slice 1).
**Session boundary:** one session. Close out. NEWS entry; PR **"Relates to #95"**.
**Dragons:** keep `gvaConvergence` COMPILING and BEHAVING — it keeps passing the FULL overridden set as `overriddenIds` (blanket-A, unchanged) until Slice 2; the absent-side-column ⇒ full-set path is the D10 hinge (C1.1) — get it byte-identical; do NOT use a `classifyParentage` hoist for the side (use `isU`, C5); keep `i13_correctBlanketA` as the case-(a) oracle.

### Slice 2 (diagnostic lockstep + app delivery + close)
**Prerequisite:** Slice 1 merged.
**Scope:** (1) `gvaConvergence` builds the same missing-side subset via the Slice-1 helper and passes it as `overriddenIds` (`:162`); reconcile the §2B divergences (run `checkKinshipOverrides` so it sees the validated side column; reach lockstep with `reportGV`); update `test_gvaConvergence_kinshipOverrides.R:174` (+ the NULL/zero-row, warn-drop, PSD-bound cases as needed). (2) UI helpText: `modGeneticValue.R:54-56` documents the side column; the second helpText `:62-78` (already flagging the missing-parent limitation at `:74-77`) updated to describe option C. **(2b) Guidance HTML + its test (MISSED in the first inventory — do NOT skip):** update `inst/extdata/ui_guidance/genetic_value.html:50-61` (the parallel limitation copy) in lockstep, and update `tests/testthat/test_kinshipOverrideDocs.R:21-78` whose phrase assertions on the HTML/helpText WILL break when that text changes; check `summary_stats.html` for stale wording. (3) confirm the side column rides through `appServer.R:293,316` → `modBreedingGroups`/`modSummaryStats` unchanged (side-agnostic apply). (4) `devtools::document()` (gvaConvergence/reportGV/modGeneticValue + the ~7 schema `.Rd`); NEWS; **close issue #95 follow-up 1**.
**RED:** `test_gvaConvergence_kinshipOverrides.R` — option C honored in lockstep with `reportGV` (a known-side override keeps the prior on the convergence path too); `testServer(modGeneticValueServer, ...)` — an uploaded frame with the side column reaches `reportGV` and produces the option-C ranking; no side column ⇒ unchanged.
**GREEN:** implement minimally.
**DONE looks like:** the app and the convergence diagnostic honor option C identically; the user can supply the side column via upload; no side column ⇒ byte-identical.
**Verify:** targeted `testServer` + gvaConvergence tests (`NOT_CRAN=true`); clean regression read; 0/0/0; **Phase-3E runtime smoke REQUIRED** (Shiny helpText + parse change, FM #24) — launch `runModularApp()`, upload a side-annotated override, confirm the ranking reflects option C and a no-upload launch is unaffected.
**Session boundary:** one session. Close out. NEWS entry; PR **"Closes #95"** (or "Relates to #95" if follow-ups 2/3 keep it open — confirm at close-out).
**Dragons:** reportGV/gvaConvergence lockstep (the whole point of this slice); the no-side-column upload path stays byte-identical; **`test_kinshipOverrideDocs.R` pins the exact limitation phrasing — update it WITH the HTML/helpText or the suite breaks (OC-R13)**; FM #24 runtime smoke is mandatory.

---

## 5. Cross-slice notes

- **Ordering:** Phase 0 (ratify) → Slice 1 (script core, delivery-agnostic) → Slice 2 (diagnostic lockstep + app delivery + close). Slice 1 is independent of the app; Slice 2 brings the second correction caller and the UI into lockstep.
- **Each slice is a full RED → GREEN → REFACTOR session** with the phase-gate `AskUserQuestion` at every transition (Development Process Contract). NEWS per slice, folded into the same PR.
- **D10 is load-bearing across all slices:** the new param defaults to `NULL`, the new column defaults to "no missing-side claim"; no override / no side column ⇒ byte-identical to today; tested explicitly each slice.
- **`kinship()` is never modified** (inherited blast-radius boundary, D1/R1); the matrix apply layer is untouched (side-agnostic, §2C).
- **The two correction callers (`reportGV`, `gvaConvergence`) are the ONLY behavior-bearing sites** (grep-confirmed); everything else passes the side column through as inert data.

## 6. Here be dragons (consolidated)

- **OC-R1 — C2 is a genetics call, not the planner's.** The residual rule (full-drop vs partial-residual) materially re-ranks animals; settle via `/grill-me` + a firsthand numeric check, as D11 was. Shipping the wrong rule mis-ranks exactly the users supplying real data.
- **OC-R2 — The schema column is an irreversible public contract (C1).** Once shipped + documented, the 4th column is committed. Prefer the minimal side-annotation (a) over a surrogate-id (b) that bleeds toward parentage reclassification (follow-up 2).
- **OC-R3 — The side classification uses `isU(ped$sire/dam)`, NOT `classifyParentage` (corrected, C5/§2B).** `classifyParentage` returns the parentage *class*, not which side is missing, and BOTH callers compute it *after* their correction anyway (`reportGV:258`, `gvaConvergence:169` — an earlier draft wrongly said gvaConvergence had it before). Compute the missing side from `isU(ped$sire/dam)` at the top of each caller (where `ped`/`probands` are in scope). No hoist, no `demographics` dependency.
- **OC-R4 — Caller computes the suppress set; do NOT add a `NULL`-default param (C3).** Redefine `overriddenIds` to mean "the set to suppress." Blanket-A = caller passes the full set (byte-identical to today); option C = caller passes the missing-side subset. A separate `overrideMissingSideIds = NULL` param creates a `NULL`-vs-`character(0L)` trap (opposite behaviors) and a double-guard no-op risk — avoid it.
- **OC-R5 — Two OPPOSITE backward-compat defaults (C1.1 — was a D10 contradiction).** Whole-file absent side column ⇒ caller passes the FULL set ⇒ blanket-A (suppress) ⇒ byte-identical (D10). Present-but-blank cell ⇒ known-side ⇒ do NOT suppress. These need *opposite* values; do not collapse them to one. The side column has no source on matrix export (import/edit-only), which is *why* whole-file-absent must mean blanket-A.
- **OC-R6 — Dedup key vs side (validator `:56-64`).** If a pair may carry two sides (C1.2), fold side into the unordered-pair key or the validator wrongly rejects it as a duplicate. Decide in C1.2 whether two-sides-per-pair is even meaningful first.
- **OC-R7 — Existing regression may flip (C4).** Pin the existing `(X,Y)=0.25` fixture as case (a) to keep the blanket-A regression valid and option C additive; otherwise `test_reportGV.R:574/581/587` change.
- **OC-R8 — reportGV/gvaConvergence lockstep (§2B).** They diverge in normalization (`checkKinshipOverrides` vs raw) and apply wrapper. Option C must reconcile at least the side classification (run both through the same helper) or the convergence diagnostic and the GV ranking disagree on overridden one-unknown animals.
- **OC-R9 — Phase-3E for Slice 2 (FM #24).** Shiny helpText + parse change; build-clean is necessary but not sufficient — launch the app with and without a side-annotated override.
- **OC-R10 — Man pages are generated.** ~7 `.Rd` name the schema inline; fix the roxygen and `devtools::document()`; never hand-edit `.Rd`.
- **OC-R11 — The missing/known dichotomy is not exhaustive (C1.2).** A single-id `missingSideFor` cannot encode a pair informing BOTH endpoints' missing sides, or a diffuse/molecular kinship. Without a `"both"` value such rows default to known-side and KEEP a prior that should be (partly) suppressed → residual over-credit. Decide C1.2 (encode "both" / two rows / document as a v1 limitation) before RED.
- **OC-R12 — Rule (i) trades the case-(b) over-credit for a scoped one (C2).** Full-drop on one sparse missing-side override under-estimates the focal's other missing-side relationships (up to ~1 SD). Rule (i) fixes the clearly-wrong case but is not genetically complete; the `/grill-me` must weigh its residual error, not rubber-stamp (i).
- **OC-R13 — `test_kinshipOverrideDocs.R` will break (Slice 2 — MISSED in the first inventory).** It pins exact "current limitation" / missing-parent phrasing in `modGeneticValueUI()`, `genetic_value.html`, and `summary_stats.html`. Rewriting that text for option C breaks its assertions — update the test WITH the doc surfaces, not after.

## 7. Owner ratification checklist — **RATIFIED (Session 227, 2026-06-28, `/grill-me`)**

Settled via a `/grill-me` session (Phase 0), grounded in a firsthand numeric check on real `qcPed` (§8). All boxes checked — **Slice-1 RED is unblocked** (separate later session).

- [x] **Upstream judgment (gates the whole feature)** — real override use is a **genuine mix** of known-side corrections and missing-side stand-ins ⇒ option C is worth building, and rule (i) captures the case-(b) value now. (If it had been "mostly missing-side," rule (i) would equal today and (ii) would be required first — see §8.)
- [x] **C1** — 4th-column encoding: **(a)** side-annotation bound to a focal animal, column name **`missingSideFor`** (value = the id, id1 or id2, whose missing-parent side this override stands in for; blank = known-side; the sire/dam side is derived from the pedigree). **(b)** surrogate-parent id **REJECTED** (bleeds toward parentage reclassification / propagation). Plus: **C1.1** two opposite defaults RATIFIED (whole-file-absent ⇒ caller passes the full set ⇒ blanket-A; per-row-blank ⇒ known-side ⇒ do not suppress); **C1.2** the "both / diffuse" case ⇒ **document as a v1 limitation** (single-id column; a both-missing-sides pair names one focal, the other endpoint keeps its prior; validator unordered-pair dedup key UNCHANGED; a `"both"` value can be added later); **C1.3** **optional** column RATIFIED (present opts into option C; absent ⇒ blanket-A per C1.1).
- [x] **C2** — residual rule: **(i)** full-drop-on-any-missing-side-override **RATIFIED** for option-C v1. Rationale (§8): rule (i) suppresses a strict *subset* of blanket-A's suppressions, so it is a **strict improvement over today** — it newly fixes case (b) (the clearly-wrong ≈1.3 SD over-penalty) and leaves case (a) *exactly* as today. Its case-(a) residual (≈1.2 SD; a single override justifies only ≈10% of the dropped prior) is a **pre-existing blanket-A condition, not introduced by option C**. **(ii)** partial-residual scaled add-back **DEFERRED** to a #95 follow-up (needs a pair-decomposition model `sexMean`, a scalar cohort aggregate, does not provide). **[genetics call — settled via `/grill-me` against the §8 numeric check]**
- [x] **C3** — threading: caller-computes-the-suppress-set RATIFIED (redefine `overriddenIds`'s contract to "the set whose `+ sexMean / 2` to suppress"; no new param, no `NULL`/empty trap; function signature unchanged).
- [x] **C4** — pin the existing `(X,Y)=0.25` regression fixture as **case (a)** RATIFIED (annotate `missingSideFor=X`; X is sire-missing so its missing side is the sire, its known side the dam — confirmed firsthand `test_reportGV.R:545-555`) so `i13_correctBlanketA` stays the case-(a) oracle and option C is additive (add a new `i13_correctOptionC` oracle + a case-(b) test).
- [x] **C5** — shared `classifyOverrideMissingSide()` helper using `isU(ped$sire/dam)` (NOT `classifyParentage`), called at the top of both callers RATIFIED.
- [x] **C6** — relationship-table side display: **defer** RATIFIED (display-only, non-load-bearing; matches D9).
- [x] **Slice order** — Phase 0 (ratify — DONE Session 227) → Slice 1 (script core) → Slice 2 (diagnostic lockstep + app + close) RATIFIED.
- [x] **D10** — no side column ⇒ caller passes the full set ⇒ byte-identical (blanket-A) is a hard acceptance test in every slice. *(invariant — confirmed)*

---

## 8. Phase 0 ratification record (Session 227, 2026-06-28)

Settled via `/grill-me`, grounded in a firsthand numeric check on real `qcPed`. **The evidence is recorded here in-plan** because the parallel D11 evidence (S214) lived only in a scratchpad workflow output and was lost — this section is the durable record so a future session need not re-run the analysis (a [[check-process-history-before-rerunning-work]] / Learning-style fix).

### 8A. Firsthand numeric evidence (real `qcPed`, 280 probands, 43 one-unknown animals)

| Quantity | Value | Note |
|---|---|---|
| SD of mean-kinship distribution (uncorrected) | 0.003309 | the spread the prior is measured against |
| `+ sexMean / 2` prior (the term blanket-A / rule (i) drops) | median 0.004430, mean 0.004332, max 0.005025 | **median ≈ 1.34 SD**, max ≈ 1.52 SD — confirms S214's "≈ 1 SD" |
| Single override raw effect on focal mean kinship (worked animal `O4Z4IB`) | half-sib 0.125 → ΔMK 0.000446; full-sib 0.25 → ΔMK 0.000893 | **prior / raw = 9.9×** (half-sib), 5.0× (full-sib) — reproduces S214's "8.4×" |
| Fraction of the dropped prior one half-sib override justifies | **≈ 10%** | ⇒ rule (i) residual over-correction on case (a) ≈ **90% ≈ 1.2 SD** |
| Rank impact (mean-kinship rank, low = higher GV; dropping one animal's prior) | worked `O4Z4IB`: 187 → 105; across the 43: swing 49–121 of 280 (median 86) | the prior moves ranks by a large fraction of the colony — mis-ranking is real |

### 8B. Reproduction recipe (re-runnable — replicates `reportGV.R:118-180`)

```r
suppressMessages(pkgload::load_all(".", quiet = TRUE))
ped <- nprcgenekeepr::qcPed
ped$population <- getGVPopulation(ped, NULL)          # reportGV.R:118
probands <- as.character(ped$id[ped$population])      # :121
kmat <- filterKinMatrix(probands, kinship(ped$id, ped$sire, ped$dam, ped$gen))
original <- meanKinship(kmat)[probands]               # :164-165
corrected <- correctUnknownParentMeanKinship(original, ped)$indivMeanKin  # :173-180
term <- corrected - original                          # = + sexMean/2 per corrected one-unknown
# term / sd(original)  -> the ≈1.3 SD prior;  override a cell to 0.125 and re-meanKinship
# for the raw effect -> the ~9.9x ratio / ~10% justified / ~90% residual.
```

(Full script as run: scratchpad `c2_numeric_check.R`; cross-checked against S214 `wf_a3c184ee-92b`'s recorded numbers in `issue13-kinship-overrides-plan.md:151-152` — same order of magnitude, independently.)

### 8C. The load-bearing reframing the evidence surfaced (verified logically)

Rule (i) suppresses the prior **iff** the focal has ≥1 override informing its *missing* side; blanket-A suppresses for *any* override. So rule (i) suppresses a **strict subset** of blanket-A's suppressions:

- **case (a)** missing-side override → drop → **same as today**;
- **case (b)** known-side-only override → **keep** (today wrongly drops) → **the entire fix**;
- mixed (≥1 missing-side) → drop → same as today.

⇒ **Option C with rule (i) is a strict (Pareto) improvement over blanket-A**: it fixes case (b) and changes nothing else. The case-(a) ≈1.2 SD residual is pre-existing, not introduced here. This is *why* shipping (i) for v1 is safe even though it is not the genetically complete answer (which is (ii)).

### 8D. Decisions ratified (see §7 for the checklist form)

Upstream "mix" judgment ⇒ build option C. **C1=(a) `missingSideFor`** (+ C1.1 two opposite defaults, C1.2 document both/diffuse as a v1 limitation, C1.3 optional). **C2=(i)** full-drop side-gated; **(ii) deferred**. **C3** caller-computes-the-suppress-set; **C4** pin fixture as case (a); **C5** shared `classifyOverrideMissingSide()` via `isU`; **C6** deferred. Slice order Phase 0 → Slice 1 → Slice 2; **D10** invariant. **0 stakeholder corrections / 0 owner overrides** — every recommendation ratified as written.

### 8E. Tracked follow-ups (NOT this feature)

- **Rule (ii) — partial-residual** for the case-(a) ≈1.2 SD residual (needs a pair-decomposition model). New #95 follow-up.
- **#95 follow-up 2** (both-unknown → one-unknown promotion) and **follow-up 3** (shared-unknown-parent sib-pair coupling) — unchanged, still separate genetics calls.
- **C1.2 `"both"` / two-rows-per-pair** encoding (with the validator dedup-key fold) — deferred enhancement, naturally bundled with rule (ii).

> **RESOLVED — Session 234 (2026-06-28), via `/grill-me` (see §9).** Rule (ii) was grilled and found **moot**: at realistic override counts (1–4) the only principled "scaled add-back" collapses onto keep-all (gap ~0.0048 SD), so there is no reachable mid-keep fraction — the deeper finding is that the *whole* suppression (rule i + D11) over-corrects (§9A). **Disposition: revert to keep-all and remove the machinery; C1.2 and rule (ii) are won't-build; the PMx pair-level model is documented as considered-and-not-needed (§9B, D5).** Only #95 follow-ups 2 and 3 remain open.

---

*Authored Session 226 (2026-06-28), planning/architecture session; **ratified Session 227 (2026-06-28), Phase 0 `/grill-me`** (§7 checklist + §8 record). Firsthand inventory via a 9-agent read-only workflow (`wf_4012d83a-551`) + completeness grep + a firsthand read of `correctUnknownParentMeanKinship.R`; ratification grounded in a firsthand `qcPed` numeric check (§8). Extends `issue13-kinship-overrides-plan.md` (D11) and issue #95 follow-up 1. **Slice-1 RED is unblocked as a separate later session.***

---

## 9. Rule (ii) / partial-residual grill — RATIFIED Session 234 (2026-06-28); SUPERSEDES the suppression design (§1–§8)

Settled via `/grill-me` (the D11 / Phase-0 mechanism), grounded in a firsthand numeric re-check on real `qcPed` and a firsthand read of the live pipeline. **0 stakeholder corrections / 0 owner overrides** — every ratified value is the owner's call as recorded below. This section **supersedes the option-C suppression behavior** designed in §1–§8 and shipped in Slices 1–2 (S229–S233); §1–§8 are retained as the record of what was built. Grounding evidence: workflow `wf_1a1f64ba-976` (4 read-only agents: numeric on `qcPed`, code/math mechanics, C1.2 encoding scope, conservation-genetics methodology) + a firsthand verification of the load-bearing pipeline-ordering claim (this session).

### 9A. The reframing (firsthand-verified)

**The pipeline ordering (verified this session, not from a description):**
- `reportGV.R:130-133` builds `kmat` from `kinship()`.
- `reportGV.R:143` → `prepareKinshipOverrides.R:49` writes the override **values into `kmat`** via `applyKinshipOverrides(kmat, overrides)`.
- `reportGV.R:148` computes `meanKinship(kmat)` — **after** the overrides are in the matrix.
- `reportGV.R:157-164` applies `correctUnknownParentMeanKinship(..., overriddenIds = suppressIds)` — the `+ sexMean / 2` add/suppress — **after** that. (`gvaConvergence.R:151-161` is the identical sequence.)

**The math.** Mean kinship is `mean_i = (1/N) Σ_j f(i,j)` with N = 280 probands. For a one-unknown animal each missing-side pair is otherwise 0 (an unknown parent is an unrelated founder), and the flat scalar `+ sexMean / 2` estimates the *aggregate* of all N missing-side relationships (`(1/N) Σ_j (1/2) f(U,j) ≈ sexMean/2`). A **missing-side override** pins **one** of those N pairs to a real value — and because that value is written to `kmat` *before* `meanKinship`, it is **already inside `original`**. So observing one pair should remove only the prior's estimate *for that one pair*, `(1/N)(sexMean/2)`, i.e. shrink the prior by **~1/N**. Shipped rule (i) drops the **entire** `sexMean/2`, over-removing by a factor of ~N.

**The numbers (firsthand on `qcPed`, re-verified on current master; reproduces §8A):** 280 probands, 43 one-unknown animals; `SD(original)=0.00330929`; the prior `term` median `0.00442969` (≈1.34 SD), max `0.00502511` (≈1.52 SD). Worked animal `O4Z4IB`: one half-sib (0.125) missing-side override gives direct Δmean-kinship `0.0004464` (⇒ N≈280); the amount the prior actually double-estimates for that one pair is `(sexMean/2)/N = 1.58e-05` — **3.5%** of the override's own effect, **1/280** of the prior. Gaps: rule (i) vs the principled add-back ≈ **1.33 SD**; keep-all vs principled ≈ **0.0048 SD**. To shrink the prior even 10% would need **28** missing-side overrides on *one* focal (impossible — one animal has one missing parent; realistic counts are 1–4). Rank impact of the over-correction: dropping one animal's prior swings its GV rank by a median of **86 / 280**, in the **wrong direction** (override animals look *more* genetically valuable → *more* likely bred).

**Methodology bottom line (cited research, medium confidence — some primary texts paywalled).** The conservation-genetics literature offers **no** citable "rule (ii)" partial-residual estimator. PMx (Hauser et al. 2024, *J. Heredity* 115(1):19) keeps two separate mechanisms and never lumps the unknown-side prior into a scalar: a known pairwise value **replaces one cell** and recomputes (weight 1.0); unknown ancestry is weight-down / unique-founder. The `+ sexMean / 2` prior is itself a **package-only** addition — *not* in Vinson & Raboin 2015, which treats an unknown parent as an unrelated founder and accepts the resulting mean-kinship **underestimate** as a documented limitation. Full-drop amplifies exactly that underestimate. The literature supports two defensible postures: **document the bias**, or the **structural pair-level fix** — and the package *already does the pair-level fix for observed pairs* via issue-#13 override-the-cell (see D5).

### 9B. Decisions (ratified Session 234)

| # | Decision | Ratified value |
|---|----------|----------------|
| **D1** | Is full-drop directionally wrong? | **Accept the over-correction reframing.** A missing-side override pins 1 of N relationships, already in `original`; the prior should shrink by ~1/N per override, not be dropped. D11's "a known outside pair supersedes the prior" was a category error. |
| **D2** | Defensible v1 treatment of the prior | **(b) Revert the prior-suppression to keep-all, with good user documentation.** Every one-unknown animal keeps `+ sexMean / 2`; issue-#13 override-the-cell stays (the override value still refines `original`). Only the override-triggered *suppression* of the prior is removed. |
| **D3** | The `w` (keep-fraction) model | **Moot — resolved by D2.** No graded add-back is built, so there is no `w` to define. (The principled `w = n_obs/N` collapses onto keep-all at realistic counts.) |
| **D4** | The now-inert option-C machinery | **Remove it cleanly.** Delete the `missingSideFor` column, `classifyOverrideMissingSide()`, and the `suppressIds` path. This also **drops C1.2** (`"both"` / two-rows-per-pair) as won't-build — it only widened *which* focals were suppressed, and now none are. |
| **D5** | The PMx pair-level model + roadmap | **Document PMx as considered-and-not-needed.** Issue-#13 override-the-cell already does the PMx "replace observed cell + recompute" for observed pairs; keep-all covers the unobserved remainder; the residual is ~1/N (negligible). No new follow-up. **#95 stays open for follow-ups 2 and 3 only.** |

### 9C. Phase-3 revert design — implementation is a SEPARATE later session

**This document is the deliverable; do not implement it in the same session it was written (FM #18).** The implementation is a strict-TDD revert. Because it deletes/renames/reverts code, the evidence-based inventory below is **mandatory** and was produced firsthand (grep over `R/ tests/ man/ inst/`, Session 234).

#### Evidence-based inventory (firsthand grep, S234)

**Behavior-bearing R sources:**
- `R/correctUnknownParentMeanKinship.R` — **remove** the `overriddenIds` param (`:136`), its contract docstring (`:117-126`), and the suppress guard `if (focalId %in% overriddenIds) next` (`:166-175`). **Keep** the `+ sexMean / 2` add (`:193-194`) and all cohort logic — the function reverts to correcting *every* one-unknown animal (its pre-D11 issue-#9 form).
- `R/prepareKinshipOverrides.R` — **keep** the validate → warn-drop-absent-ids (D5) → `applyKinshipOverrides` cell-write (`:33-49`, issue #13). **Remove** the `suppressIds` computation and the `classifyOverrideMissingSide` branch (`:50-55`); simplify the return (no `suppressIds`).
- `R/reportGV.R` — remove `suppressIds <- prepared$suppressIds` (`:145`) and the `overriddenIds = suppressIds` arg (`:163`); rewrite the comment block (`:135-142`). **Keep** the `prepareKinshipOverrides` call (the cell-write).
- `R/gvaConvergence.R` — the identical edit (`:153`, `:160`; comment `:144-150`); **lockstep with `reportGV`** is mandatory (the shared helper exists for this reason).
- `R/classifyOverrideMissingSide.R` — **delete the whole file** (`@noRd`, so no exported `.Rd`; confirm it is not in `NAMESPACE`).
- `R/checkKinshipOverrides.R` — **remove** the `missingSideFor` accept/domain/validation (7 refs). **Keep** `id1`/`id2`/`kinship` validation + the unordered-pair dedup.
- `R/modGeneticValue.R` — remove the `missingSideFor` helpText mention (1 ref); **rewrite the limitation/upload helpText** to the D2 story (see "Documentation" below).

**Tests (`tests/testthat/`):**
- `test_classifyOverrideMissingSide.R` — **delete** (helper gone).
- `test_correctUnknownParentMeanKinship.R` — remove the `overriddenIds`-suppress tests; **add keep-all assertions** (every one-unknown animal corrected regardless of overrides).
- `test_reportGV.R` (11 refs), `test_gvaConvergence_kinshipOverrides.R` (7) — remove the case-a/case-b suppress oracles; re-pin the `i13_correct*` oracles to **keep-all** (the override refines `original`; all one-unknown animals keep `+ sexMean / 2`); lockstep.
- `test_prepareKinshipOverrides.R` (7) — drop suppress/side tests; keep cell-write + warn-drop.
- `test_modGeneticValue_kinshipOverrides.R` (3) — drop `missingSideFor` upload/parse; keep the override upload path.
- `test_checkKinshipOverrides.R` (10) — drop `missingSideFor` accept/domain tests; keep `id1`/`id2`/`kinship`.
- `test_kinshipOverrideDocs.R` (4) — **update the pinned phrases in lockstep** with the helpText/HTML (OC-R13 still applies in reverse).

**Generated / doc / man:**
- `man/checkKinshipOverrides.Rd`, `man/gvaConvergence.Rd`, `man/reportGV.Rd` — regenerate via `devtools::document()` (never hand-edit `.Rd`).
- `inst/extdata/ui_guidance/genetic_value.html` (1 ref) — rewrite the option-C copy; check `summary_stats.html` for stale wording.
- `NEWS.Rmd` → regenerate `NEWS.md` — remove/rewrite the option-C (Slices 1–2) entries (the feature never reached a release) and add the revert entry. **Edit `NEWS.Rmd`, not `NEWS.md` (generated).**

#### Behavior invariant (the new acceptance test, replaces D10)
- **No overrides ⇒ byte-identical to today** (the correction already runs for every one-unknown animal; unchanged).
- **With an override ⇒** the override cell is applied (#13) **and** every one-unknown animal **keeps** `+ sexMean / 2` (keep-all). Pin: an overridden one-unknown animal's final value **includes** `+ sexMean / 2` (the opposite of the shipped rule-(i) drop), and `reportGV`/`gvaConvergence` agree (lockstep).

#### Documentation (D2 "good user documentation")
The rewritten helpText (`modGeneticValue.R`) and `genetic_value.html` must say, in plain language: (1) a kinship override **refines** the focal's kinship to the named animal(s) directly; (2) the unknown-parent correction (`+ sexMean / 2`) is **kept for every animal missing one parent** — an override of one relationship does not remove it, because it informs only one of the animal's many colony relationships; (3) the honest limitation: mean kinship for a one-unknown animal is an **estimate** (the unknown parent's true relatives are unrecorded), tending to **underestimate** relatedness — consistent with Vinson & Raboin 2015.

#### Sequencing, completion criteria, session boundary
- **One implementation session (atomic revert).** Recommended over a script/app split because the doc-consistency test (`test_kinshipOverrideDocs.R`) couples the validator/helpText to the pinned doc phrases — a partial revert leaves the helpText advertising a column the validator rejects. If it proves too large, the only clean split is script-core vs app-docs, but `checkKinshipOverrides`/helpText/`test_kinshipOverrideDocs.R` must move **together**.
- **RED:** keep-all assertions in `test_correctUnknownParentMeanKinship.R`/`test_reportGV.R`/`test_gvaConvergence_kinshipOverrides.R`; `checkKinshipOverrides` rejects/ignores `missingSideFor`; doc phrases updated.
- **GREEN:** perform the removals/reverts above minimally.
- **DONE looks like:** an override no longer drops any one-unknown animal's `+ sexMean / 2`; the `missingSideFor` column and `classifyOverrideMissingSide` are gone; no-override runs are byte-identical.
- **Verify:** targeted `test_file` per touched test; clean regression read (`as.data.frame(testthat::test_dir(...))`, `sum(failed)+sum(error)`, isolate `!grepl("test-app-|test-e2e-", file)`, `NOT_CRAN=true`); `devtools::check(vignettes=FALSE)` → 0/0/0; `spell_check_package(".")` = 0; **Phase-3E runtime smoke REQUIRED** (Shiny helpText change, FM #24) — `runModularApp()`, upload an override, confirm keep-all ranking and an unaffected no-upload launch.
- **PR "Relates to #95"** (NOT "Closes" — follow-ups 2/3 keep it open).

#### Dragons
- **R1 — reportGV/gvaConvergence lockstep.** Revert both identically or the report and the convergence diagnostic disagree.
- **R2 — keep the issue-#13 cell-write.** `applyKinshipOverrides` in `prepareKinshipOverrides.R:49` STAYS; only the suppress computation goes. Removing the cell-write would discard the override's legitimate effect.
- **R3 — doc-consistency test couples code+docs (OC-R13, in reverse).** Update `test_kinshipOverrideDocs.R` with the helpText/HTML, not after.
- **R4 — `.Rd` are generated** — `devtools::document()`, never hand-edit.
- **R5 — NEWS.md is generated from NEWS.Rmd.**

### 9D. Issue #95 disposition

Rule (ii) / partial-residual and C1.2 are **resolved here as won't-build** (revert + remove). PMx is **documented as not-needed** (D5). **#95 stays OPEN** for the two untouched genetics-methodology follow-ups: **2** (both-unknown → one-unknown promotion) and **3** (shared-unknown-parent sib-pair coupling). The revert implementation is a separate later session (9C).

---

*§9 authored Session 234 (2026-06-28), `/grill-me` decision session. The reframing's load-bearing pipeline-ordering claim was verified firsthand (`prepareKinshipOverrides.R:49` precedes `reportGV.R:148`); the numeric evidence re-runs §8B on current master. **This session's deliverable is the decision record + revert plan only — no `R/`, `tests/`, `man/`, `NAMESPACE`, or `data/` content is changed (TDD code-phases N/A).** Implementation (9C) is unblocked as a separate later session.*

---

## 10. Follow-ups 2 & 3 — disposition (Session 236 `/grill-me`)

> **STATUS: RATIFIED — Session 236 (2026-06-28), via `/grill-me`.** The two remaining #95 follow-ups — **2** (both-unknown → one-unknown promotion) and **3** (shared-unknown-parent sib-pair coupling) — are settled. **FU2 = won't-build (not derivable); FU3 = accept (keep the independent per-focal correction) + document the limitation in the maintainer docstring.** Grounded by a read-only workflow (`wf_964f8ea1-4bb`, 6 agents) re-verified firsthand against current `master`. **0 stakeholder corrections / 0 owner overrides.** Decision/design session — no `R/`, `tests/`, `man/`, `NAMESPACE`, or `data/` change (TDD code-phases N/A); the FU3 docstring note is a separate small implementation session (§10C).

### 10A. Firsthand-verified grounding (current `master`, post-S235 revert)

**Code dataflow (re-read firsthand):**
- Both-unknown animals are excluded from the correction: `oneU <- xor(sireMiss, damMiss)` (`R/correctUnknownParentMeanKinship.R:145`) — `xor(TRUE, TRUE) = FALSE`. Both-unknown get **no** `+ sexMean / 2`.
- Each one-unknown animal is corrected **independently** in `for (i in which(oneU))` (`:155`): `corrected[focalId] <- min(original[focalId] + sexMean * 0.5, 1)` (`:175`). No coupling across focals.
- Pipeline ordering (the S234 reframing, still holds post-revert): the override is written into the matrix (`reportGV.R:140` `prepareKinshipOverrides`) **before** `meanKinship` (`:144`) **before** the correction (`:154`); `gvaConvergence.R` is in lockstep (`:148`→`:150`→`:151`). The override value is therefore already counted in the focal's mean kinship before the prior is added.
- Schema is path-agnostic `id1/id2/kinship`; all option-C side machinery removed (`grep -rn 'suppressIds|overriddenIds|classifyOverrideMissingSide|missingSideFor' R/` → 0 hits; `classifyOverrideMissingSide.R` deleted).

**Numeric reality (firsthand on `qcPed`, 280 probands — reproduces §8A):**
- 43 one-unknown (**all sire-missing**, 0 dam-missing), 124 both-unknown, 113 both-known.
- `+ sexMean / 2` prior: median 0.004430 (≈1.34 SD), max 0.005025 (≈1.52 SD), n=43; `SD(original)=0.003309`.
- FU3 candidate sib-pairs: **2 pairs (4 animals)** — `KY0D3C`/`HN5YTI` (known dam `6OL4PZ`); `JPKPJC`/`PUS6EL` (known dam `OOJ8A6`). **Each shares a known *dam* and both miss the *sire*** — so whether they share the *same* unknown sire is **unknowable** (two offspring of one dam can have different unknown sires). The "shared unknown parent" premise is itself undetectable.

### 10B. Ratified decisions

**D1 (FU2 — both-unknown → one-unknown promotion): WON'T-BUILD (not derivable).**
- *Rationale:* an override is path-agnostic (`id1/id2/kinship`) — a kinship value cannot identify which of the two missing parents it informs; the side-carrying column (`missingSideFor`) was removed in the S235 revert (the same blocker that killed follow-up 1). Promotion conflates "I have one relatedness observation" with "I now know a parent's identity" — a category error. Under the reframing the override is already in the matrix, so layering a whole ~1.34 SD prior on a "promoted" side over-credits. No conservation-genetics standard reclassifies parentage from a kinship value (PMx keeps parentage pedigree-only).
- *Disposition:* not built. A genuine promotion feature would be a **separate dedicated parentage-reclassification issue** (a side-identifying mechanism or molecular parentage + a two-missing-sides joint model + studbook-authority rules), out of scope for #95. Documented as considered-and-not-built in the maintainer docstring (§10C).

**D2 (FU3 — shared-unknown-parent sib coupling): ACCEPT (keep the independent per-focal loop) + DOCUMENT.**
- *Rationale:* the premise is undetectable (the unrecorded parent has no id; sharing a known dam does not establish a shared unknown sire — see 10A) and the effect is negligible (~9% of one-unknown animals in candidate pairs; over-count small vs. the prior's own magnitude and below the genome-uniqueness sampling-noise floor `guSE`; residual ~1/N under the reframing). No conservation-genetics standard couples sib priors; per-individual is the norm. Coupling would require turning scalar `sexMean` into a pair-decomposable model — the machinery S234 found moot for rule (ii).
- *Disposition:* behavior unchanged; document the limitation in the maintainer docstring (§10C).

**D3 (documentation surface): DOCSTRING ONLY (maintainer-facing).** Add the note to the `@noRd` docstring of `correctUnknownParentMeanKinship.R`; leave the user-facing helpText / `genetic_value.html` as-is (existing copy already states that one-unknown mean kinship is an estimate that tends to underestimate relatedness — Vinson & Raboin 2015). Avoids touching the pinned `test_kinshipOverrideDocs.R`. A user-facing note about a negligible, unactionable over-estimate would add noise, not clarity.

**D4 (issue #95 disposition): CLOSE after the FU3 docstring note lands.** This session records the decisions and posts a keyword-safe #95 comment (verify #95 OPEN after). The FU3 docstring session (§10C) adds the note and then **deliberately** closes #95 as its last step (authored keyword-safe, posted via `gh api`, state verified — Learning 215/217/218). A future molecular-parentage feature would be a fresh issue, not this one.

### 10C. FU3 docstring note — implementation plan (separate small session)

**Scope:** maintainer docstring only. One file: `R/correctUnknownParentMeanKinship.R`. No behavior change.

**What to add and where:** insert a short paragraph after the existing second prose paragraph (currently ending "… that is what `sexMean` averages." at `:102`), before the `@param` block. Recommended text (covers both FU2 and FU3 as considered-and-not-built):

> Each one-unknown animal is corrected independently. Two such animals that share the same unrecorded parent (for example two offspring of one known dam, each with an unknown sire) therefore each receive the full `sexMean / 2` prior, a small over-estimate of their joint relatedness. This shared-unknown-parent coupling is deliberately not modelled: the unrecorded parent has no id, so whether two animals share it cannot be determined from the pedigree, and the effect is negligible at colony scale (issue #95 follow-up 3 — considered, not built). For the same path-agnostic reason an outside kinship override never reclassifies a both-unknown animal to one-unknown: a kinship value cannot identify which parent it informs (issue #95 follow-up 2 — not derivable from the `id1`/`id2`/`kinship` schema).

**DONE looks like:** the docstring carries the note; no behavior change; the package still loads and documents.

**Verify:** `devtools::document()` is a no-op for `@noRd` (no `.Rd` generated — nothing to regenerate); `spell_check_package(".")` = 0 (hand-add any new technical word to the wordlist — do **not** run `update_wordlist`, per [[avoid-reconcile-tools-on-curated-files]]); a clean regression read (no test pins this `@noRd` docstring — confirm `test_kinshipOverrideDocs.R` does not reach into this file); `devtools::check(vignettes=FALSE)` → 0/0/0.

**TDD:** likely **N/A** (a `@noRd` docstring has no generated `.Rd` and no test pins it). If the implementer wants a RED, the only available pin is a `grep`-style content assertion — optional. **Phase-3E:** N/A (no runtime behavior change). **Then deliberately close #95** (keyword-safe `gh api` comment + close; verify state).

**Dragon:** do **not** touch the user-facing helpText / `genetic_value.html` — that trips `test_kinshipOverrideDocs.R` and pulls in a larger lockstep change. D3 scoped this to the docstring on purpose.

### 10D. Issue #95 disposition (summary)

All #95 follow-ups are now dispositioned: FU1 / rule (ii) / C1.2 = won't-build (§9, S234); **FU2 = won't-build (D1); FU3 = accept + document (D2).** #95 has no remaining design questions — only the FU3 docstring note (§10C). #95 **closes when that note lands** (D4). #9 and #13 stay closed.

---

*§10 authored Session 236 (2026-06-28), `/grill-me` decision session. Grounded by read-only workflow `wf_964f8ea1-4bb` (6 agents; the synthesis step degenerated to placeholder output and was recovered from the agent transcripts) and re-verified firsthand against current `master` (code dataflow + `qcPed` numerics). **Deliverable is the decision record only — no `R/`, `tests/`, `man/`, `NAMESPACE`, or `data/` change (TDD code-phases N/A).** The FU3 docstring note (§10C) is a separate small implementation session.*
