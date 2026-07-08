# Issue #118 Triage — "Add the effective population size estimate"

**Issue:** #118 — "Add the effective population size estimate"
**Date:** 2026-07-07 (Session 308)
**Type:** Triage / scoping (analysis only — no code changed)
**Status of issue:** OPEN, untriaged. Body in full: *"place to locate output
has not been determined."* No labels, no comments.

---

## 1. Verdict

**This is a well-motivated enhancement, not a bug — but it is under-specified in
two ways that must be settled before any RED.** The issue asks for one number
("*the* effective population size") as if it were a single quantity. It is not:
**"effective population size" (Ne) names a family of distinct estimators**, each
answering a different management question and requiring different inputs. Most of
the inputs already exist in the package; one common estimator needs data the
package does not currently store (generation length in years).

The two open decisions — **which Ne** and **where the output goes** ("place to
locate output has not been determined") — are the owner's calls. They are the
proper deliverable of a short planning / `/grill-me` session, exactly as the
#119 triage (S301) deferred its Option choice. **No code defect exists; nothing
here is blocked** (contrast #116, which lacks a data source). It is implementable
now, once a definition and a location are chosen.

---

## 2. What "effective population size" means here — the ambiguity

For a pedigreed, actively managed captive colony (the Lacy 1989 / Ballou & Lacy
1995 / Vinson & Raboin 2015 framework this package already lives in), at least
four standard estimators travel under the name "effective population size." They
can differ by large factors on the same colony, because each idealizes a
different departure from a Wright-Fisher population.

| # | Estimator | Formula (standard form) | Answers | Primary input |
|---|-----------|-------------------------|---------|---------------|
| E1 | **Founder-genome-equivalent / gene-diversity based** | FG itself is the "effective number of founder genomes"; retained gene diversity `GD = 1 - 1/(2*FG)` | How much of the founding gene pool's diversity survives | **FG — already computed** (`calcFG`) |
| E2 | **Demographic / sex-ratio** | `Ne = 4*Nm*Nf / (Nm + Nf)` | Loss of diversity from an unequal breeding sex ratio | Counts of breeding males `Nm` and females `Nf` |
| E3 | **Variance effective size (reproductive skew)** | `Ne ~= (4N - 4) / (Vk + 2)` for a ~stable population, `Vk` = variance in lifetime offspring number | Loss of diversity from unequal family sizes | Per-animal offspring counts |
| E4 | **Inbreeding / rate-of-coancestry effective size** | `Ne = 1 / (2*dCbar)` where `dCbar` is the increase in mean kinship (coancestry) per **generation** (equivalently from `dGD`) | The realized genetic rate of drift/inbreeding over time | Mean kinship (or FG) **plus a per-generation or per-year time baseline** |

These are not interchangeable. E2 on a harem colony (few sires, many dams) can be
a fraction of the census; E1 depends on founder representation; E4 is the number
most directly tied to "how fast are we losing diversity," and is the one most
conservation-genetics readers expect — but it is also the most data-hungry.

**The population is also unspecified.** Ne of *what*? The whole studbook, the
living animals, the current breeders, or a single breeding group? Each choice
changes both the inputs and the answer.

---

## 3. Existing machinery — evidence-based inventory

The package already carries most of the raw material. Nothing below is
hypothetical; each is a present, exported (or report-internal) function.

### Directly reusable inputs

| Input Ne needs | Already in package | Where |
|---|---|---|
| Founder genome equivalents (FG) + its sampling SE | **Yes** | `R/calcFG.R`, `R/calcFEFG.R`, `R/calcFGSE.R` |
| Founder equivalents (FE) | **Yes** | `R/calcFE.R` |
| Founder sex counts `nMaleFounders` / `nFemaleFounders` | **Yes** (in the report bundle) | `R/reportGV.R:205-245` |
| Per-animal offspring counts (for `Vk` in E3) | **Yes** | `R/findOffspring.R`, wired via `R/offspringCounts.R:37,42` |
| Mean kinship / mean coancestry (for `GD`, E1/E4) | **Yes** | `R/meanKinship.R`, `R/kinship.R` |
| Gene-drop allele retention (basis of FG) | **Yes** | `R/geneDrop.R`, `R/calcRetention.R` |
| Generation **number** per animal | **Yes** | `R/findGeneration.R` (assigns integer generations; see §4 gap) |

### The natural home for the output — answering the issue's open question

The issue says *"place to locate output has not been determined."* The package
already has the obvious home: **the Genetic Value Analysis founder-statistics
table.** `reportGV()` returns a colony-level bundle that already carries `fe`,
`fg`, `fgSE`, and the founder counts (`R/reportGV.R:61-69`), and
`makeFounderStatsTable()` renders exactly those as a one-row HTML table —
*Known Founders | Female Founders | Male Founders | FE | FG*
(`R/makeFounderStatsTable.R:80-108`), displayed by the `modFounderStats` Shiny
module (`tests/testthat/test_modFounderStats.R`). **Ne is a colony-level scalar
of the same kind as FE and FG.** Adding it as one more field in the `reportGV`
bundle and one more `<th>`/`<td>` pair in that table is the minimal, idiomatic
placement — it rides next to the metrics it is conceptually a sibling of.

---

## 4. Gaps — what is NOT already available

| Missing for | What's missing | Consequence |
|---|---|---|
| **E4** (rate-of-coancestry Ne) | A **time / generation baseline**: `findGeneration()` gives generation *numbers*, but there is **no generation length in years** and **no time series** of mean kinship or FG. `speciesGestation` stores gestation + min breeding ages only (`data-raw/speciesGestation.R`) — not a generation interval. | E4 cannot be computed rigorously today without either (a) a generation-length assumption per species, or (b) a longitudinal baseline. This is the highest-value but highest-cost estimator. |
| **E2 / E3** | A **definition of "breeder" / "the population"** — which animals count, over what window. The pedigree can supply this (any animal appearing as a sire/dam is a realized breeder; `findOffspring` gives family sizes), but the *policy* (living only? current breeders? whole studbook?) is a decision, not a lookup. | Cheap to compute once the population is defined; the definition is an owner decision. |
| **E1** | Essentially nothing — FG already is this. | Nearly free; mostly interpretation/labeling. |

No prior Ne work exists anywhere in the codebase or vignettes (grep for
"effective population"/"effective number"/"Ne =" across `R/`, `vignettes/`,
`inst/` finds nothing genetic). This is a genuinely new metric, not a
resurrection.

---

## 5. Severity & scope

- **Type:** Enhancement (new reported metric), not a correctness bug. Nothing is
  currently wrong; a number is absent.
- **Not blocked:** unlike #116, every estimator except E4 has its inputs present.
  E4 needs a modest data addition (generation length) or a scoped assumption.
- **Blast radius:** **Low–moderate.** E1/E2/E3 are additive — a new scalar in the
  `reportGV` bundle and a new column in one HTML table. They do **not** touch QC,
  candidate finding, or breeding-group formation. E4 is larger (introduces a
  temporal/generational model and possibly new bundled data).
- **Reference fidelity:** the package advertises the Lacy 1989 founder framework
  and Vinson & Raboin 2015. E1 (FG-based) is the most in-keeping with what the
  package already reports; E4 is what a population geneticist most often means by
  "Ne." Choosing among them is a genetics-management call, not an engineering one.
- **Vertical-slice friendly:** each estimator is an independent end-to-end slice
  (compute -> add to `reportGV` bundle -> add to founder-stats table -> test),
  deliverable one per session under strict TDD (mirrors the #82 FG-SE slices and
  the #119 slices).

---

## 6. Resolution options

Ordered by increasing scope. All are **implementation-session** work; this triage
implements none of them.

### Option 1 — Report FG-based Ne / gene diversity (E1). *Lowest cost.*
Surface the founder-genome-equivalent interpretation: report `GD = 1 - 1/(2*FG)`
and/or label FG explicitly as the effective founder-genome count, next to FE/FG.
- **Pros:** almost free (FG + its SE already computed); fully consistent with the
  package's existing Lacy framework; no new data, no new population definition.
- **Cons:** arguably "already there" — a reader wanting a demographic or
  rate-based Ne will not consider FG an answer. May not be what the requester
  means by "effective population size."

### Option 2 — Demographic sex-ratio Ne (E2). *Low cost.*
`Ne = 4*Nm*Nf/(Nm+Nf)` over a defined breeder set. Add as a founder-stats-table
scalar.
- **Pros:** the textbook "effective population size"; cheap; intuitive for colony
  managers reasoning about harem/sex-ratio effects; counts are derivable now.
- **Cons:** requires an explicit "who is a breeder / over what window" definition;
  ignores family-size variance (which harem management makes large).

### Option 3 — Variance effective size (E3). *Moderate cost.*
Use `findOffspring` to get `Vk`, then `Ne ~= (4N - 4)/(Vk + 2)`.
- **Pros:** reuses existing `findOffspring`; captures reproductive skew, which is
  the dominant Ne-reducer in managed harem colonies; well-defined demographic
  quantity.
- **Cons:** needs the same population/window definition as E2; the stable-
  population formula has assumptions (stated sex ratio, ~constant N) that must be
  documented so the number is not over-interpreted.

### Option 4 — Rate-of-coancestry / inbreeding Ne (E4). *Highest cost, highest value.*
`Ne = 1/(2*dCbar)`. Requires a generation baseline.
- **Pros:** the number most conservation-genetics readers expect; directly ties
  Ne to the diversity-loss rate the colony is managed to slow.
- **Cons:** needs generation length (new bundled data) or a longitudinal
  mean-kinship/FG series the package does not keep; largest design surface;
  best as its own multi-slice effort after E1–E3.

### Option 5 — Report several, clearly labeled. *Superset.*
Present a small "effective size" block (e.g., E1 + E2 + E3), each named for what
it is, rather than one ambiguous "Ne."
- **Pros:** avoids implying a single canonical Ne; each is cheap; honest about the
  differences. Matches how studbook software (PMx, etc.) reports multiple
  diversity metrics side by side.
- **Cons:** more UI/report surface; needs care so the labels teach rather than
  confuse.

**Recommendation (direction, not a decision):** the **cheapest honest win** is
**Option 2 or Option 3** (a real demographic Ne readers will recognize), or
**Option 5** if the owner wants the metric to be self-explaining. **Option 1** is
nearly free and worth including regardless, but on its own may not satisfy the
request. **Option 4** is the most valuable long-term but should be its own effort
once a generation-length data source is decided. The genetics-management choice —
*which* Ne, and for *which* population — is the owner's, and should be settled
before any RED.

---

## 7. Dragons / load-bearing assumptions for the executor

1. **"Effective population size" is not one number.** Do not implement a formula
   before the owner has named which estimator (E1–E4) and which population. A PR
   that silently picks one will answer a question the owner may not have asked.
2. **Population/breeder definition is load-bearing** for E2/E3. "Breeder,"
   "living," "current," and "whole studbook" give materially different Ne. Fix and
   document the definition; expose it as a parameter if in doubt.
3. **Generation length is absent** (`speciesGestation` has gestation + min
   breeding ages, not a generation interval; `findGeneration` gives integers, not
   years). E4 cannot be done rigorously without adding it — do not fake it with an
   unstated constant.
4. **Idealized-model caveats must be documented.** E2/E3/E4 all assume things
   (constant N, defined sex ratio, discrete generations) that a managed colony
   violates. The reported number needs a one-line "what this assumes" so it is not
   over-read. This is the same discipline #82 applied to the FG sampling SE.
5. **Degeneracy / small-sample behavior.** Guard `Nm==0` or `Nf==0` (E2 -> 0),
   `Vk` undefined for <2 breeders (E3), and FG's existing zero-retention
   degeneracy (E1 inherits `calcFG`'s `NA`-with-warning path,
   `R/checkFgDegeneracy.R`). Decide the sentinel (N/A) exactly as FG/FE already do
   in `makeFounderStatsTable`.
6. **Placement precedent:** if adding to the founder-stats table, follow the
   existing FG-SE cell pattern (`R/makeFounderStatsTable.R:60-108`) for the
   N/A-vs-value formatting rather than inventing a new one.

---

## 8. Recommended next step

**Not implementation.** The natural successor is **one short planning /
`/grill-me` session** (owner in the loop) that ratifies:

- **which estimator(s)** — E1 / E2 / E3 / E4 / a labeled set (Options 1–5);
- **which population** the Ne is computed over (studbook / living / current
  breeders / per group), and the "breeder" definition;
- **where it displays** — confirm the GVA founder-stats table
  (`makeFounderStatsTable` / `modFounderStats` / the `reportGV` bundle) as the
  home, or name another;
- **for E4 only:** whether to add generation-length data (and its source) or
  defer E4 to a later effort;

then writes `docs/planning/issue118-effective-population-size-plan.md` with an
evidence-based inventory (this document is the seed of that inventory) and
per-slice completion criteria. Implementation follows in later,
one-estimator-per-session slices under strict TDD, each adding its scalar to the
`reportGV` bundle and one cell to the founder-stats table.
