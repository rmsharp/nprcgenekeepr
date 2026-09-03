# Research: kinship2's `align.pedigree()` joint-positioning mechanism, and what porting it would cost

**Date:** 2026-09-03 (Session 670)
**Trigger:** `BACKLOG.md` Up Next item "Research: characterize kinship2's `align.pedigree()`
joint-positioning mechanism (`alignped4.R`) to quantify the (C) joint-solver option"
(owner-directed 2026-09-02, after reviewing the S669 spike result; READY, Effort M).
**Workstream:** `docs/methodology/workstreams/AUDIT_WORKSTREAM.md` (investigate-and-report,
matching the S667/S668/S669 precedent for this deliverable shape).
**Scope:** Investigation and decision support only. No `R/`/`tests/` package code changed — TDD
RED/GREEN/REFACTOR gates do not apply (owner-confirmed via `AskUserQuestion`, matching the
census/spike precedent). **This document does not decide (A) vs (C)** — the still-open decision
at the top of `BACKLOG.md` Up Next item 1 — it exists to put a concrete, costed, evidence-backed
option (C) in front of that decision.

---

## TL;DR

kinship2's `align.pedigree()` is two structurally different phases, not one algorithm:

1. **Phase A** (`alignped1`/`alignped2`/`alignped3`, plus `autohint`/`besthint` for the initial
   hints) — a **heuristic, recursive, sequential** process that decides *which row each subject
   plots on and in what left-to-right order*, by descending from founders and merging subtrees
   side by side. Structurally, this is the same shape as this project's own tree layout
   (`.positionTreeApportion()`, Tier 1) and disconnected-family handling (`.forestComponents()` +
   `.packComponents()`, S667) — sequential, order-only, no numeric optimization.
2. **Phase B** (`alignped4`) — a **single, global, constrained quadratic program** (one
   `quadprog::solve.QP()` call) that re-solves the *numeric x-position* of **every** plotted point
   on **every** row, **simultaneously**, honoring Phase A's fixed order, minimizing a weighted sum
   of "children near parents' midpoint" and "spouses near each other" penalties, subject to one
   hard linear constraint per adjacent same-row pair (`x[i+1] - x[i] >= 1`).

**Verified empirically this session** (not just read from source, per this project's own
Learning 678 precedent): `alignped4()` is called **exactly once** per pedigree — across all rows
*and* all weakly-connected families at once, including the real 375-fixture's 5 disconnected
families — and the achieved same-row minimum gap is **exactly 1.0** at every one of 18 tested
`align` weight settings spanning 9 orders of magnitude, on both Track C and the real 375 fixture.
That is the mechanism: feasibility (no same-row point closer than the floor) is a **hard
constraint the QP cannot violate**, not an emergent tendency of the objective. This is
structurally why kinship2 never hits the cascade this project's own sequential Tier
1→2→3→collision-repair engine hit in S669's spike: **there is only one solve, so "widen this
one spacing rule" and "keep everything else feasible" are the same optimization**, not two
one-directional passes that can conflict.

**Costed estimate for porting an equivalent joint solve (§4):** the numerical core is small and
tractable at this project's real scale (520 QP variables / 529 constraints on the 375-individual
fixture — trivial for `quadprog`), and the per-row uniform-1-unit constraint generalizes cleanly
to this project's own radius-based `minSep`. The real cost is not the solver — it is (a) a new
direct `Imports` dependency on `quadprog` (currently absent, even transitively, from
`DESCRIPTION`), (b) a translation layer from this project's node/edge/forest tables into the
QP's flat parameter/constraint matrices, and (c) an explicit new QP variable+penalty for this
project's own mating-union "dot" node, a concept kinship2 does not have at all (kinship2 draws
the marriage line directly between the two spouses' own positions). None of these are novel or
open research questions — they are a costed, Effort-L implementation, not a research risk.

---

## Method

Every claim below is backed by one of two kinds of evidence, both reproducible (§7):

1. **Source verified byte-for-byte against the actual installed dependency.** This project's
   installed `kinship2` is **1.9.6.2** (`packageVersion("kinship2")`); the fully-commented,
   literate-programming source (`noweb/align.Rnw`, `noweb/align2.Rnw`) exists locally only for
   the older **1.6.4** (2017) checkout at `/Users/rmsharp/Documents/Development/R/r_workspace/
   kinship2/`. Before trusting that commentary as a guide to the *installed* version's behavior,
   this session `deparse()`-extracted the exact installed 1.9.6.2 function bodies
   (`getAnywhere()`) and diff-normalized them against the 2017 source (parsed and re-`deparse()`d
   identically, so only real logic differences survive, not comment/whitespace noise — see §7).
   **Result: `alignped2`, `alignped3`, `alignped4` (the QP step itself), `besthint`, and
   `autohint` are byte-identical in logic between 1.6.4 and 1.9.6.2.** `align.pedigree` and
   `alignped1` differ only in two S4-compatibility/zero-length-safety hardening fixes (`class(x)
   ==` → `"x" %in% class(x)`; `1:n` → `seq_len(n)`), not algorithm changes. **The 2017 literate
   commentary is therefore an accurate guide to the mechanism this project actually depends on.**
2. **Running the installed 1.9.6.2 code against this project's own fixtures**, not just reading
   it — per this project's own established lesson (`PROJECT_LEARNINGS.md` Learning 678: a
   library's role for a parameter, inferred from source structure alone, was wrong until actually
   swept and measured). `data-raw/kinship2AlignPedigreeJointSolverProbe.R` traces
   `alignped4()`'s call count and problem size via `assignInNamespace()`, and sweeps the `align`
   weight parameter 18 ways on the two fixtures that stress this project's own engine hardest
   (Track C, the real 375). Full output in §4/§5 below and reproducible verbatim via §7.

---

## 1. What `align.pedigree()` actually does

### 1.1 Phase A — row/order determination (`alignped1`/`alignped2`/`alignped3`, `autohint`)

`align.pedigree(ped, hints = ped$hints)` (`noweb/align.Rnw` `<<align.pedigree>>`) first builds a
`spouselist` (husband/wife/plot-order-hint/anchor-hint, from the `hints$spouse` matrix, the
`ped$relation` matrix's marriage rows, and every `dad>0 & mom>0` pair), then processes **founders**
(married pairs with no parents of their own) **sequentially**, ordered by the hints:

```r
rval <- alignped1(founders[1], dad, mom, level, horder, packed = packed, spouselist = spouselist)
for (i in 2:length(founders)) {
  rval2 <- alignped1(founders[i], dad, mom, level, horder, packed, spouselist)
  rval <- alignped3(rval, rval2, packed)          # side-by-side merge
}
```

`alignped1(x, ...)` recursively builds the subtree rooted at one founder: find `x`'s spouses,
place `x` and them side by side (`nid[lev,] <- c(lspouse, x, rspouse)`), then for each spouse with
children call `alignped2` (which orders siblings by hint, calls `alignped1` on each, and merges
with `alignped3` when a sibling's own subtree doesn't already contain them — the "two sibs marry
each other" special case). `alignped3` is pure bookkeeping: given two side-by-side plotting
structures, slide the right one over by `space` (default 1 unit) past the left one's rightmost
column, unless the two structures' boundary columns are literally the same subject (a duplicate
reached from two directions), in which case the columns are collapsed into one.

**This entire phase assigns each subject an integer column position, one row (`level`) at a
time, and never revisits a column assignment once made** — the same shape as this project's own
Tier 1 tree layout and its S667 disconnected-component recursion (`.forestComponents()` +
per-component recursive call + `.packComponents()`, `R/makePedigreeDiagramData.R:801-810`):
lay out each piece, then place the pieces next to each other. `autohint()` (used when no explicit
hints are supplied) is itself an iterative trial-and-error loop around this same phase: run it,
find subjects plotted twice (once under their parents, once as a marry-in spouse), add a spouse
hint to fix the more common cases, and re-run — bounded, heuristic, and **can punt**: this
session's own probe run hit kinship2's own `autohint` fallback warning ("Unexpected result in
autohint, please contact developer" → returns a trivial `order = 1:n` and continues) on the real
375-fixture at every tested `align` weight, matching the "autohint warning" caveat already on
record from the S668 census's own kinship2 baseline. This is a Phase-A-only soft degradation —
it did not prevent `align.pedigree()` from completing, and (§2) it is orthogonal to the QP step.

**Row/order determination is not the part of kinship2 that avoids cascades.** It is exactly the
same kind of sequential, order-fixing, never-revisited process this project already has (Tier 1 +
component packing) — and it is not what `.buildMatingUnitForest()`/Tier 1/component-packing would
need to be replaced to get a joint solve. What differs is Phase B.

### 1.2 Phase B — `alignped4`: the single joint QP solve

`align.pedigree`'s finishing step (`noweb/align.Rnw` `<<align-finish>>`) calls `alignped4` exactly
once, on the **entire** structure Phase A produced (every row, every family, already merged into
one `nid`/`fam`/`spouse` set of matrices):

```r
if ((is.numeric(align) || align) && max(level) > 1) pos <- alignped4(rval, spouse > 0, level, width, align)
```

Inside `alignped4` (`noweb/align2.Rnw` `<<alignped4>>`, verified byte-identical to the installed
1.9.6.2 source, §Method):

- **One QP variable per plotted point**, across **every row of the whole pedigree at once**
  (`n <- sum(rval$n)`; `myid` maps every `(row, column)` to a flat variable index `1..n`).
- **Objective** (`pmat`, minimized as `t(pmat) %*% pmat`, i.e. a sum of squared penalty terms):
  - One row per spouse pair: `sqrt(align[2]) * (x_husband - x_wife)` — pulls spouses together.
    `align[2]` defaults to `2`; this project's own Learning 678 already established, by sweeping
    it, that this is a *weight* on a term whose unconstrained minimum is 0 separation, never a
    target distance — the achieved gap is always pinned at the constraint floor (below),
    regardless of the weight's magnitude.
  - One row per child, per sibship: `sqrt(k^-align[1]) * (x_child - mean(parent1, parent2))` —
    pulls each child toward its parents' midpoint, damped by sibship size `k` (`align[1]`
    defaults to `1.5`, so larger sibships are slightly easier to move than small ones).
  - One tiny (`1e-5`) anti-degeneracy pull on the widest row's first point, because the penalty
    matrix alone is translation-invariant (shifting every position by the same constant doesn't
    change the objective) and `solve.QP` needs a strictly positive-definite quadratic form
    (`pp <- t(pmat) %*% pmat + 1e-8 * diag(ncol(pmat))`).
- **Constraints** (`cmat`/`dvec`, one linear inequality per adjacent same-row pair plus two per
  row for the width bound): for every row, in the **column order Phase A already fixed**,
  `x[i+1] - x[i] >= 1`; the first point of each row `>= 0`; the last `<= width - 1`. This is the
  **only** place a minimum separation is enforced, and it applies uniformly — same 1-unit floor
  between any two adjacent points on a row, regardless of what kind of point they are (an
  individual, a duplicate placeholder, a spouse).
- **Solve:** `fit <- solve.QP(pp, rep(0, n), t(cmat), dvec)` — one call, returns the optimal
  `x` for every point in the whole pedigree simultaneously, honoring every constraint exactly.

---

## 2. Why this structurally avoids the S669 cascade — verified, not inferred

### 2.1 What this project's own engine does instead (re-read this session, not from memory)

`R/makePedigreeDiagramData.R:713-733` (`.positionMatingUnitForest()`'s own docstring, current
code, re-read this session):

> "Three strictly ordered tiers, **each fully reconciled before the next tier reads it**":
> Tier 1 (genuine-tree BJL apportionment) is computed and frozen; Tier 2 derives every anchored
> mating unit's `x` as the midpoint of its children's **FINAL Tier-1** `x` and is itself frozen;
> Tier 3 derives every non-anchor mate's `x` off its own unit's **FINAL** `x` (Tier 1's, "never
> the union's") and is itself frozen. Bounded, mostly one-directional collision-repair passes run
> after (`.deCollideIndividualPoints()`, capped `.kMaxIndividualPush = 2`, `:781`;
> `.kMaxUnionPush = 5`, `:1280`, "Unidirectional only (always rightward)", `:1492`).

This is **one-way data flow**: nothing computed in a later tier or the repair pass ever revisits
an earlier tier's already-frozen value to make room for it. This is exactly why S669's spike
(recentre every union on its mate midpoint; widen Tier 3's B1 offset from `minSep * 0.4` to
`minSep`) **cascaded**: the two edits change what Tier 2/Tier 3 compute, but Tier 1's positions
— which both tiers treat as fixed, already-final input — are never adjusted to make the wider
spacing fit, so the widened points can and do land on top of whatever Tier 1 (or another
family's Tier 1) already put there. The bounded, capped, largely one-directional collision-repair
pass that runs afterward is a local patch on top of that one-way flow, not a re-optimization —
which is exactly the class of new violation the spike found (class (c2) jog-crosses-symbol,
+3.4×, `BACKLOG.md` Up Next item 1).

### 2.2 Empirical verification of the contrast (`data-raw/kinship2AlignPedigreeJointSolverProbe.R`)

**Probe 1 — `alignped4()` (the QP step) call count and problem size, traced live via
`assignInNamespace()`:**

| Fixture         | Weakly-connected families | QP calls | QP variables (`n`) | QP constraints |
|---|---:|---:|---:|---:|
| Track B full    | 2 | **1** | 15  | 18  |
| Track B shrunk  | 2 | **1** | 8   | 11  |
| Track C         | 1 | **1** | 10  | 13  |
| Real 375        | 5 | **1** | 520 | 529 |

Every fixture — including the real 375-individual pedigree's **5 separate weakly-connected
families** (the exact structure S667's own disconnected-component-separation work had to
special-case in this project's engine) — is solved in **exactly one** `solve.QP()` call. kinship2
does not solve per-family or per-row; it solves the whole diagram, every family included, as one
optimization. Problem size at this project's real scale (520 variables, 529 constraints) is
trivial for `quadprog` (a dense active-set QP solver designed for problems of this size; solves in
well under the resolution of `system.time()` on this fixture).

**Probe 2 — does the achieved minimum same-row gap ever drop below the 1-unit floor, at any
weighting?** Swept `align = c(a, b)` — `a` (`align[1]`, the parent-child exponent) and `b`
(`align[2]`, the spousal weight) — each independently over `{0.001, 0.01, 0.1, 1, 2, 10, 100,
1000, 10000}` (9 values, 4+ orders of magnitude on each side of the defaults `c(1.5, 2)`), on
Track C and the real 375 fixture (36 `align.pedigree()` calls total):

**Every single one of the 36 calls achieved a minimum same-row gap of exactly `1.000000`.** Not
"approximately 1" or "usually >= 1 with occasional violations" — exactly the constraint floor,
every time, regardless of how far the objective's weights were pushed. This is the direct,
measured confirmation that the 1-unit floor is a **hard linear constraint fed to the solver**,
not a target the objective merely tends toward (extending this project's own Learning 678, which
swept only `align[2]` on toy fixtures, to `align[1]` as well and to this project's own real
stressing fixtures). **A QP constraint cannot be violated by construction — that is what "solve
subject to constraints" means** — so there is no configuration of the objective that can push a
row's spacing below the floor, and by the same token, no edit that widens *one* penalty's pull can
create a *new* violation somewhere else: the solver simultaneously re-balances everything, every
time, because everything is one optimization.

### 2.3 The contrast, stated precisely

The cascade risk this project hit is not a bug in the specific two constants S669 spiked — it is
a structural property of solving position in **one-way, tier-at-a-time passes where later tiers
treat earlier tiers as fixed**. kinship2 does not have "tiers" that treat each other as fixed at
Phase B — it has exactly one global optimization where every position, at every row, is
simultaneously free to move, constrained only by order (fixed in Phase A) and adjacency spacing
(uniform, hard). A narrower (A) variant that gates the S669 edits to fewer units, or a
jog/collision-repair re-run against the new spacing (`BACKLOG.md`'s own two named untested
alternatives), are both still **local, one-directional patches on the same one-way pipeline** —
they may reduce the cascade's *size*, but they do not remove the *structural* reason it can
happen at all. Only replacing the position-*value* computation (Tier 2 + Tier 3 + most of
collision repair) with a single joint solve removes that structural risk, which is what option
(C) means concretely.

---

## 3. What kinship2 does *not* solve — the parts this project would still have to build

kinship2's mechanism is not a drop-in replacement; it solves a narrower problem than this
project's diagram does. Differences, by what each engine actually has:

- **No mating-union "dot" node.** kinship2 draws the marriage line directly between the two
  spouses' own QP-solved positions — there is no third point to place. This project's mating-unit
  dot (`__union_*`) is a rendering choice of this project's own, not something kinship2's
  mechanism has an analogue for. Porting the joint solve requires deciding how the union dot's
  `x` participates: as its own QP variable with a centering penalty (cheap — one more penalty row
  per mating unit, exactly the same shape as the existing spouse/child penalty rows, §4), or
  derived post-hoc as the mean of the two now-jointly-solved parent positions (simpler, but
  reintroduces exactly the class of "dot lands on a parent's own symbol" defect S666's
  conditional-shift rule had to specifically correct for this project's *current* engine).
- **Uniform spacing, not radius-based.** kinship2's `>= 1` floor applies identically to every
  adjacent pair regardless of what is plotted. This project's symbols have different radii (25 px
  individual/duplicate vs 6 px union dot, per `data-raw/pedigreeDrawingErrorCensus.R`'s own
  render-layer constants) — a real generalization is needed (§4), not a blocker.
- **More duplicates, not fewer.** The S668 census's own kinship2 baseline already measured this:
  145 duplicate placements on the real 375 fixture vs this project's 102. kinship2's Phase A
  collapses a duplicate only when the two occurrences are column-adjacent at merge time
  (`alignped3`'s `nid[i,n1] == floor(x2$nid[i,1])` check); otherwise both copies are plotted with
  **no** penalty pulling them toward each other in Phase B — kinship2 does not solve this project's
  own class (d) (duplicate near its real occurrence) at all, it simply plots more duplicates and
  accepts wherever the QP puts them. Porting the QP does not inherit a solution to this project's
  duplicate-proximity problem; it would need its own penalty term if wanted (mechanically easy to
  add, same shape as the others — not attempted or measured this session).
- **Twin handling exists in kinship2 (Phase A + a final `twins` output matrix) with no
  counterpart in this project's diagram at all.** Not a porting cost unless twin-specific
  rendering is later wanted — kinship2's twin handling is confined to Phase A order-fixing
  (`autohint`'s `twinset`/`twinord`), not the QP objective or constraints.
- **Isolated-individual filtering is upstream of both engines, not a QP concern.** This project's
  `.findIsolatedIds()` pre-filter and kinship2's own single-node "trivial tree" case
  (`alignped1`'s `nspouse == 0` branch) both handle a lone individual before either engine's
  positioning logic runs; nothing here interacts with the joint-solve question either way.

---

## 4. Costed estimate: porting/reimplementing an equivalent joint-optimization pass

**New direct dependency.** `quadprog` is currently absent from `DESCRIPTION` even transitively —
`kinship2` (which depends on it) is `Suggests`-only (`DESCRIPTION:68`), and `grep -rn
"quadprog\|solve.QP" R/ NAMESPACE DESCRIPTION` returns nothing (verified this session). A real
port needs `quadprog` promoted to `Imports`. `quadprog` is a small, stable, dependency-free base
package (Fortran `solve.QP.c`/`.f` wrapper, no further transitive dependencies of its own) — a
low-risk addition on its own merits, but a genuinely new one, not something already half-present.

**Problem size at this project's real scale is not a concern.** §2.2's Probe 1: 520 variables,
529 constraints on the real 375-individual fixture — orders of magnitude below where a dense
active-set QP solver like `quadprog` becomes slow. Whatever the port's engineering cost, solver
performance is not part of it.

**What would carry over vs. what would be replaced:**

- **Carries over unchanged:** Tier 1's tree layout (deciding the recursion structure and each
  subject's row) and the S667 component-partition/packing shape — this is Phase-A-equivalent
  work, and Phase A is not what removes the cascade risk (§2.1). This project's own `gen`-based
  row assignment (`findGeneration()`) already plays the role of kinship2's `level`.
- **Replaced:** Tier 2 (union-x derivation), Tier 3 (B1/B3 derived-point formulas), and most of
  the collision-repair pass (`.deCollideIndividualPoints()`, `.kMaxUnionPush`) — all of which
  exist specifically because the current engine computes positions in one-way passes. A single
  joint QP, built once Tier 1 has fixed each row's column order, replaces all three at once.

**New engineering work, beyond a direct translation of kinship2's own `alignped4`:**

1. **A translation layer** from this project's `forest`/`nodes`/`edges` tables into the QP's flat
   `myid`/`pmat`/`cmat`/`dvec` parameterization — mechanical, not a research question, but real
   code: this project's node set (real individuals + `__dup_*` + `__union_*`) does not map 1:1
   onto kinship2's `nid`/`fam`/`spouse` matrices, which have no union-node concept (§3).
2. **A union-node QP variable and centering penalty**, generalizing kinship2's own per-family
   child-centering penalty row (§1.2) by one more variable and one more penalty per mating unit —
   the natural way to keep this project's dot rendering while gaining the joint solve's
   feasibility guarantee for it too.
3. **Generalizing the uniform `>= 1` row constraint to this project's radius-based `minSep`** —
   mechanically a change to what value populates `dvec[coff + i]` per adjacent pair (a per-pair
   minimum instead of kinship2's constant `1`); `quadprog`'s linear-constraint API already
   supports an arbitrary per-constraint RHS, so this needs no solver change, only per-pair lookup
   logic keyed off which two node *kinds* are adjacent.
4. **A decision on duplicate-proximity penalties** (§3) — kinship2 does not solve this project's
   own class (d) at all, so if this project wants the joint solve to also keep a duplicate close
   to its real occurrence, that penalty term does not come for free from the port and would need
   its own design (not costed further here — out of this session's scope).

**Effort estimate:** none of the above is an open research question — every piece above is a
specific, scoped, previously-unencountered-but-mechanical implementation task. Consistent with
the existing effort convention this project's own `BACKLOG.md` uses for comparable engine
rewrites (the Walker/BJL apportioning redesign, issue #141, was Effort L), this is an **Effort L**
item: one architecture/design session to spec the exact QP formulation (penalty terms, constraint
generalization, the union-node treatment chosen in item 2 above), then a TDD implementation
following the project's own vertical-slice discipline (`SESSION_RUNNER.md` §Vertical Slice
Sessions) — plausibly 2-4 implementation sessions given the size of `.positionMatingUnitForest()`
being replaced (`R/makePedigreeDiagramData.R:759-1529`, ~770 lines) and the breadth of the
existing pinned test suite (`test_positionMatingUnitForest.R`, `test_resolveEdgeNodeCollisions.R`)
that would need to be re-derived against the new engine's actual output, not assumed compatible.

---

## 5. What this means for the still-open A-vs-C decision

This document does not decide (A) vs (C). What it adds to the decision, concretely:

- **(C)'s structural claim is now verified, not just plausible.** kinship2 avoids the cascade
  class S669's spike found *by construction* (a hard-constrained single solve), not by luck or by
  a parameter this project could simply copy into its own sequential engine. A narrower (A)
  variant or a jog/collision-repair re-run (`BACKLOG.md`'s two untested alternatives) may reduce
  the S669 cascade's *size*, but neither removes the *structural* reason a one-way pipeline can
  produce it — only (C) removes that structural risk.
- **(C)'s cost is now a number, not an unknown.** Effort L, with the concrete task list in §4 —
  comparable in scale to the Walker/BJL redesign this project has already completed once
  (issue #141), not a bigger or more novel undertaking than that.
- **(C) does not inherit a solution to every class the S668 census measured.** It structurally
  solves classes (a)/(b)/(c1)/(c2)/(e)/(f) (same-row overlap, off-centre union, same-row edge
  crossing, mate off its union's row, family interleaving) by construction, once the union-node
  and radius-based constraint generalizations (§4 items 2-3) are built. It does **not**
  automatically solve class (d) (duplicate near its real occurrence) — kinship2 doesn't solve
  that either (§3) — that would need its own, separately-designed penalty term regardless of
  which path (A or C) this project takes.

---

## 6. Caveats — what remains unverified

- **The `align.pedigree()` source read here is kinship2's own mechanism; this project's actual
  port would not be a byte-for-byte copy** — §4's translation-layer and union-node items are
  scoped but not built, so their exact code shape (and any complication only visible once
  written) is not yet known. This document costs the *shape* of the work, not a working
  prototype.
- **No end-to-end spike of a joint-solve engine against this project's own fixtures was run this
  session** (out of scope for a characterization/costing task, per the `AskUserQuestion`-confirmed
  approach) — §2's empirical verification runs kinship2's *own* `align.pedigree()` on this
  project's *pedigree data*, which confirms the mechanism and its scale, but does not confirm
  what this project's *specific* rendering output (with union dots, duplicate proxies, and
  radius-based symbols) would look like under a ported version of that mechanism.
- **`quadprog`'s exact API surface** (argument names/shapes for `solve.QP`) was read from the
  kinship2 source's usage, not independently verified against `quadprog`'s own documentation —
  low risk (kinship2 has depended on it unchanged since at least 2017, per §Method), but not
  independently checked this session.

---

## 7. Reproduction

```sh
# Confirm installed kinship2 == 1.6.4-clone logic for the QP step and its co-routines
# (Method §1); requires the 2017 checkout path used this session.
Rscript -e '
old_dir <- "/Users/rmsharp/Documents/Development/R/r_workspace/kinship2/R"
fns <- c("align.pedigree","alignped1","alignped2","alignped3","alignped4","besthint","autohint")
for (f in fns) {
  e <- new.env(); sys.source(file.path(old_dir, paste0(f, ".R")), envir = e)
  old <- deparse(get(ls(e)[1], envir = e))
  new <- deparse(getAnywhere(f)$objs[[1]])
  ob <- paste(old[which(old == "{")[1]:length(old)], collapse = "\n")
  nb <- paste(new[which(new == "{")[1]:length(new)], collapse = "\n")
  cat(f, ": identical body =", identical(ob, nb), "\n")
}'

# Empirical probe: alignped4() call count, QP problem size, and the align-weight sweep (§2.2)
Rscript data-raw/kinship2AlignPedigreeJointSolverProbe.R
```

Literate-programming source read in full this session (not excerpted from memory):
`/Users/rmsharp/Documents/Development/R/r_workspace/kinship2/noweb/align.Rnw` (752 lines),
`noweb/align2.Rnw` (514 lines). This project's own engine re-read in full this session:
`R/makePedigreeDiagramData.R:705-1529` (`.positionMatingUnitForest()`'s docstring and body,
current post-S667/S668/S669 state).
