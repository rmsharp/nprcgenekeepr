# Issue #95 Plan — Option C: targeted suppression of the kinship-override / unknown-parent (#9) correction

**Tracks:** GitHub issue **#95** ("Refine kinship-override / unknown-parent (#9) correction interaction beyond v1 blanket supersession (D11 follow-ups)"), **follow-up 1 (option C)**. Filed Session 225 (2026-06-28). Issue #95 also tracks two genetics-methodology follow-ups (both-unknown→one-unknown promotion; shared-unknown-parent sib-pair coupling) that are **out of scope for this plan** (see §1, "What this plan does NOT cover").

**Tracks (parent):** issue **#13** (kinship overrides) decision **D11**, ratified Session 214. This plan extends `docs/planning/issue13-kinship-overrides-plan.md` (the D1–D11 decision record). Option C was explicitly deferred at D11 ratification with the note *"track targeted option C as a follow-up — needs override-side metadata the `id1/id2/kinship` schema does not carry"* (`issue13-kinship-overrides-plan.md:153,212`).

**Authored:** Session 226 (2026-06-28), **planning/architecture session.** The owner picked this as the session deliverable. The TDD code-phases (RED / GREEN / REFACTOR) are **inapplicable to this document** — it is a design doc, not code. Each implementation slice in §4 is its own strict-TDD session (RED → GREEN → REFACTOR), one slice per session (FM #18/#25: do not bundle plan + implementation, do not bundle slices).

> **STATUS: DRAFT — NOT RATIFIED. Two decisions are the owner's / geneticist's to make and must be settled BEFORE any RED.** Option C is the *genetically ideal end state* but its core rule (**C2 — the residual genetics-modeling rule**) is a genetics-methodology call of exactly the kind that gated D11; like D11 it should be settled via a `/grill-me` session grounded in a firsthand numeric check, not decided by the planner. The schema-encoding decision (**C1**) is an irreversible public-contract change (a 4th override column). This plan surfaces options with a planner recommendation for each; the §7 checklist is **UNRATIFIED** until the owner signs off. Do not open a Slice-1 RED session against any unratified decision (issue #95 gotcha 2; FM #19 — plan-mode output is a draft).

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

## 3. Design decisions (option C) — DRAFT, **UNRATIFIED**

Each shows the options, the **planner's recommendation**, and the kind of sign-off required. **C1 and C2 are the gates**; C3–C6 are architectural/test-design choices the planner can recommend and the owner confirms. None is ratified.

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

## 7. Owner ratification checklist — **UNRATIFIED (DRAFT)**

Fill in via a `/grill-me` session (Phase 0), grounded in a firsthand numeric check on real `qcPed`. Until every box is checked, no Slice-1 RED.

- [ ] **C1** — 4th-column encoding: **(a)** side-annotation bound to a focal animal *(planner rec)* vs **(b)** surrogate-parent id. Plus: **C1.1** two opposite defaults (whole-file-absent ⇒ blanket-A; per-row-blank ⇒ known-side); **C1.2** the "both / diffuse" answer (encode / two rows / document as a v1 limitation); **C1.3** optional column *(planner rec)*.
- [ ] **C2** — residual rule: **(i)** full-drop-on-any-missing-side-override *(planner rec — but a judgment; note its scoped over-credit, OC-R12)* vs **(ii)** partial-residual scaled add-back. **[genetics call — `/grill-me` against a numeric check]**
- [ ] **C3** — threading: caller-computes-the-suppress-set (redefine `overriddenIds`'s contract; no new param, no `NULL`/empty trap) *(planner rec)*.
- [ ] **C4** — pin the existing `(X,Y)=0.25` regression fixture as **case (a)** *(planner rec)* so option C is additive.
- [ ] **C5** — shared `classifyOverrideMissingSide()` helper using `isU(ped$sire/dam)` (NOT `classifyParentage`), called at the top of both callers *(planner rec)*.
- [ ] **C6** — relationship-table side display: **defer** *(planner rec)* vs include.
- [ ] **Slice order** — Phase 0 (ratify) → Slice 1 (script core) → Slice 2 (diagnostic lockstep + app + close).
- [ ] **D10** — no side column ⇒ caller passes the full set ⇒ byte-identical (blanket-A) is a hard acceptance test in every slice. *(invariant)*

---

*Authored Session 226 (2026-06-28), planning/architecture session. Firsthand inventory via a 9-agent read-only workflow (`wf_4012d83a-551`) + completeness grep + a firsthand read of `correctUnknownParentMeanKinship.R`. Extends `issue13-kinship-overrides-plan.md` (D11) and issue #95 follow-up 1. The plan is a DRAFT — C1 and C2 are owner/geneticist ratification gates.*
