# Issue #119 Triage — `minParentAge` vs. sex-specific minimum reproductive ages

**Issue:** #119 — "Use of `minParentAge` seems to conflict with newer sex specific minimum reproductive ages"
**Date:** 2026-07-07 (Session 301)
**Type:** Triage / scoping (analysis only — no code changed)
**Status of issue:** OPEN, untriaged, no body/labels/comments

---

## 1. Verdict

**The conflict is real, already known, and was deliberately deferred.** The package
now holds **two independent notions of "minimum age at which an animal can be a
parent,"** and they disagree:

- **(A) Legacy scalar `minParentAge`** — one number (default `2.0`), applied
  identically to sires and dams and to every species. Used by the **QC path**, the
  **potential-parent finder**, and **production status**.
- **(B) Newer species+sex table** — `speciesGestation$minMaleBreedingAge` /
  `minFemaleBreedingAge`, read via `getSpeciesMinBreedingAge(species, sex)`. Used by
  **exactly one** subsystem: the GVA unknown-parent mean-kinship correction
  (`correctUnknownParentMeanKinship`, added for #9).

This is **not a bug to fix in one edit** — it is a **design-unification decision**
that the owner already anticipated. The plan that introduced table (B) explicitly
wrote (issue9 plan §8-D, line 229):

> **Scope:** Slice 2 only. **Do NOT** retrofit `getPotentialParents`/`checkParentAge`
> (they run on a scalar `minParentAge` today; changing them touches breeding-group
> formation — out of scope). **Unifying breeding-age determination package-wide is a
> follow-up.**

**Issue #119 is that follow-up.** No code defect was found; the deliverable of any
future implementation session is unification, not a patch.

---

## 2. The two notions, side by side

### (A) Scalar `minParentAge`
- Single numeric, default **2.0** (but **3.0** in one consumer — see §4).
- Sex-agnostic and species-agnostic.
- User-set via the Shiny **Input** tab (`R/modInput.R:127`, default `"2.0"`,
  coerced with a fallback of `2.0` at `R/modInput.R:449-453`).

### (B) Species+sex table (`speciesGestation`, columns added for #9)
Current bundled values (`getSpeciesMinBreedingAge`, fallback `2.0` for unknown/absent
species or a sex that is not `"M"`/`"F"`):

| species | minMaleBreedingAge | minFemaleBreedingAge |
|---|---|---|
| RHESUS | 4.0 | 2.5 |
| CYNOMOLGUS | 4.0 | 2.5 |
| JAPANESE MACAQUE | 5.0 | 4.0 |
| PIG-TAILED MACAQUE | 4.0 | 3.0 |
| BABOON | 6.0 | 4.0 |
| VERVET | 4.0 | 3.0 |
| AFRICAN GREEN MONKEY | 4.0 | 3.0 |
| SQUIRREL MONKEY | 3.5 | 2.5 |
| COMMON MARMOSET | 1.0 | 1.0 |
| COTTON-TOP TAMARIN | 1.5 | 1.5 |
| OWL MONKEY | 2.0 | 2.0 |
| CAPUCHIN | 6.0 | 4.0 |
| CHIMPANZEE | 12.0 | 8.0 |
| BONOBO | 12.0 | 8.0 |

Source of truth: `data-raw/speciesGestation.R` → `data/speciesGestation.RData`;
documented in `R/data.R:402-404`.

---

## 3. The conflict, concretely

**Example — a rhesus male recorded as a sire at age 3.0:**
- `checkParentAge(minParentAge = 2.0)` → **not flagged** (3.0 ≥ 2.0). QC accepts it.
- `getSpeciesMinBreedingAge("RHESUS", "M")` → **4.0**. The GVA correction treats 4.0
  as the floor, so a 3-year-old male is below breeding age for that subsystem.

One subsystem accepts a parentage the other regards as biologically implausible. The
same pedigree is judged by two different rulers.

**Internal inconsistency inside a single function** —
`getPotentialParents()` (`R/getPotentialParents.R`) already keys **gestation** to
species (`getSpeciesGestation`, line 82) but gates **breeding age** with the flat
scalar (line 97: `birth <= focal_birth - 365*minParentAge`) *before* splitting the
survivors into sires (`sex == "M"`, line 104) and dams (`sex == "F"`, line 112). So
it knows the species but ignores the species/sex breeding age it could look up — it
would happily propose a 2-year-old rhesus male as a potential sire.

---

## 4. Affected code — evidence-based inventory

Scalar `minParentAge` is threaded through many signatures, but only a few sites make a
**decision** with it. The rest are pass-throughs, docs, or tests.

### Decision sites (where a retrofit would actually change behavior)

| Site | What it does with the scalar | Sex-aware? | Default |
|---|---|---|---|
| `R/checkParentAge.R:94-95` | Flags offspring whose `sireAge` **or** `damAge` `< minParentAge` (same number both) | No | 2 |
| `R/getPotentialParents.R:97` | Flat breeding-age cutoff, applied before the M/F split at :104/:112 | No | (caller-supplied) |
| `R/getProductionStatus.R:64` | Counts females `age >= minParentAge` (dam capacity) | Females only, but flat | **3** |

### Default-value discrepancy (a smaller, related inconsistency)
- `checkParentAge` / `qcStudbook` / `getPotentialParents` convention: **2**
  (`R/checkParentAge.R:40`, `R/qcStudbook.R:177`, `R/runQcStudbook.R:40`).
- `getProductionStatus`: **3** (`R/getProductionStatus.R:55`), and its only in-package
  caller passes **3** explicitly (`R/getGeneticDiversityStats.R:99`).
- `getSpeciesMinBreedingAge` fallback for unknown/absent species: **2**
  (`R/getSpeciesMinBreedingAge.R:37`).

So even *within* the scalar world there are two "defaults" (2 and 3) with no single
documented rationale. Any unification should reconcile these too.

### Pass-through / plumbing (change only if the signature changes)
`R/qcStudbook.R:177,251`, `R/runQcStudbook.R:40,87,173`,
`R/modInput.R:127,449-472,659-660`, `R/modPotentialParents.R:223,264`.

### Docs / examples / tests (follow whatever the code decides)
`man/*.Rd` (many), `R/data.R` (table description), vignettes
(`a2interactive.Rmd`, `articles/studbook-quality-control.qmd`, etc.),
`tests/testthat/test_checkParentAge.R`, `test_getPotentialParents.R`,
`test_getProductionStatus.R`, `test_modInput*.R`, `test_qcStudbook.R`.

### Already sex-aware (the model to converge on)
`R/getSpeciesMinBreedingAge.R`, `R/getSpeciesGestation.R`,
`R/correctUnknownParentMeanKinship.R:54-58`, data in
`data-raw/speciesGestation.R` / `data/speciesGestation.RData`.

---

## 5. Severity & impact

- **Correctness of QC:** Moderate. With the flat default of 2, QC **under-flags**
  young parents for species whose true minimum is higher (rhesus male 4, baboon male
  6, chimp male 12). A biologically impossible sire can pass QC silently. It does not
  crash or corrupt data; it fails to warn.
- **Potential-parent finding:** Moderate. Can propose too-young animals of one sex as
  candidate parents, feeding downstream parentage inference / breeding-group work.
- **Blast radius of a fix:** **High.** `checkParentAge` sits inside `qcStudbook`,
  which is the front door for nearly every workflow; `getPotentialParents` feeds
  breeding-group formation. This is why #9 fenced it off. A retrofit needs strict TDD,
  full-suite + `--as-cran`, and careful handling of the **absent `species` column**
  (neither `qcPed` nor the `breederPed` fixture carries one — see issue9 plan §8-D
  lines 227-228; absent species must fall back to the scalar/default, not error).
- **Not blocked:** unlike #116, no missing data source. This is implementable now.

---

## 6. Resolution options

Ordered by increasing scope. All are **implementation-session** work; this triage
does not implement any of them.

### Option 1 — Unify on the species/sex table (recommended direction)
Make `getSpeciesMinBreedingAge(species, sex)` the single source of truth. `minParentAge`
becomes an **optional override**: when the user supplies a value it wins (back-compat);
when `NULL`/absent, breeding age is looked up per species+sex, falling back to the
current default for unknown/absent species.
- **Pros:** removes the conflict at its root; QC and potential-parent finding become
  species/sex-correct; preserves the user override; reuses the tested table +
  accessor.
- **Cons:** largest change; touches `checkParentAge` (hence `qcStudbook`) and
  `getPotentialParents` (hence breeding-group formation); needs the absent-`species`
  guard everywhere; multiple man/vignette updates. Best delivered as **vertical
  slices** (one consumer at a time: QC first, then potential parents, then production
  status), each its own session.

### Option 2 — Sex-specific scalars only (no species table in QC)
Split `minParentAge` into `minSireAge` / `minDamAge` (or a length-2 value) in
`checkParentAge` / `getPotentialParents`, without consulting the species table.
- **Pros:** smaller; addresses the sex half of the title directly; no dependence on a
  `species` column.
- **Cons:** leaves the **species** half unsolved and creates a *third* notion of
  breeding age (sex scalars) alongside the species/sex table — arguably makes the
  divergence worse, not better.

### Option 3 — Document-only reconciliation (minimal)
Leave code as-is; document that `minParentAge` (QC/candidate-finding) and the
species/sex table (GVA) are intentionally separate tools with different purposes, and
reconcile the 2-vs-3 default wording.
- **Pros:** near-zero risk; closes the "seems to conflict" confusion if the owner
  decides the separation is acceptable.
- **Cons:** the biological under-flagging in QC remains.

### Option 4 — Won't-fix / close
If the owner judges that QC should stay a simple, user-tunable flat gate and the
species/sex table is only ever a GVA-internal concept, close #119 with that rationale.

**Recommendation:** **Option 1**, delivered as vertical slices, is the direction most
consistent with where the codebase is already heading (the table + accessor exist and
are tested; #9 §8-D called unification the planned follow-up). But the *scope* and
*default policy* (does a user override always win? what is the unknown-species
fallback — 2, 3, or the old scalar?) are the owner's calls and should be settled
before any RED. Option 3 is a legitimate low-cost outcome if the owner wants the two
notions to stay separate.

---

## 7. Dragons / load-bearing assumptions for the executor

1. **Absent `species` column** — `qcPed` and the `breederPed` fixture have none.
   `getSpeciesMinBreedingAge` already handles this (returns the `default`), but every
   new call site must build the species vector defensively
   (`if ("species" %in% names(ped)) ped$species else rep(NA_character_, nrow(ped))`,
   mirroring `getPotentialParents.R` / issue9 §8-D). A missing column must degrade to
   the scalar/default, never error.
2. **`qcStudbook` is the front door** — any behavior change in `checkParentAge`
   ripples through the whole app. Strict TDD + full suite + `--as-cran`.
3. **Back-compat of the user override** — `minParentAge` is a documented, exported
   parameter and a Shiny input. Removing it outright would break callers; prefer
   "override wins, else table."
4. **Two current defaults (2 and 3)** must be reconciled deliberately, not silently.
5. **Vignette footnote** (`a2interactive.Rmd:138`): "Setting `minParentAge` to 3.5 and
   above will cause an error [on the example data]" — any change to thresholds may
   move which example animals get flagged; vignette prose/goldens may need updates.

---

## 8. Recommended next step

**Owner decision (S301):** the resolution direction (Options 1-4) is **deferred to a
dedicated planning session** — not chosen in this triage. The direction below is
therefore the ratified next step.

Not implementation. The natural successor is **one planning session** (or a
`/grill-me` with the owner) that ratifies:
- which Option (1-4),
- the override-vs-table precedence and the unknown-species fallback default,
- the slice order (which consumer first),
- whether the 2-vs-3 default gets unified,

then writes `docs/planning/issue119-*-plan.md` with an evidence-based inventory
(this document is the seed of that inventory) and per-slice completion criteria.
Implementation follows in later, one-slice-per-session work under strict TDD.
