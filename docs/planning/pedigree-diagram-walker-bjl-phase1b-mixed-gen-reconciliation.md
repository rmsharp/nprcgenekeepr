# Pedigree Diagram Walker/BJL Redesign — Phase 1b: Forest/Mixed-Gen Reconciliation Design Note

**Session:** S612 (2026-08-19). **Parent plan:**
[`pedigree-diagram-walker-bjl-apportioning-redesign-plan.md`](pedigree-diagram-walker-bjl-apportioning-redesign-plan.md),
Phase 1b subsection under "Migration Path." **Supersedes/completes:** the Phase 1b deliverable
that plan requires before Phase 2 can begin.

## Executive summary — read this first

Phase 1b's own charter explicitly allows two honest outcomes: a chosen, tested mechanism, **or**
"more research needed... a clearly-scoped harder problem statement for a dedicated follow-up
session, not a forced, under-verified answer produced to keep the Migration Path moving." This
session's outcome is closer to the second, with substantial documented progress toward the first.

**What is validated and should be treated as settled, going into Phase 2 (or a Phase 1b
continuation):**

- **The core architecture (Candidate 2b — eliminate every 0-delta edge from the tree recursion by
  reattaching a mating union's real children directly onto its anchor, representing everything
  else as a strictly one-way-derived point) survived 3 independent adversarial critique rounds
  unchallenged at the structural level.** Every defect found across all 3 rounds was in the
  surrounding integration detail (which node gets a derived point and how, how a legacy pass like
  `orderBySex`/`sweepMinSep` interacts with the tiers) — never in the core idea itself.
- **This is independently corroborated by real-world precedent, not just this project's own
  reasoning:** direct reads of CraneFoot's actual C++ source and kinship2's own design vignette
  (not just their published papers) found both real, independently-developed pedigree-drawing
  tools made the *same* architectural choice — a mating union is never a first-class,
  recursively-positioned tree node in either implementation.
- **Candidates 1 (revived global per-level table fed into `apportion`) and 3 (same-rank/flat-edge
  treatment from Sugiyama literature) are conclusively ruled out**, the former on both mechanical
  and failure-shape grounds, the latter because every real implementation checked (Graphviz `dot`,
  the academic "extended level graphs" literature) treats flat edges as an *ordering* concern, not
  the *coordinate*-apportioning concern Phase 1b actually needs solved.
- **The B1/B2/B3 classification of non-anchor occurrences** (decorative-only fold-in; already has
  an independent genuine tree position; genuine duplicate marker) is sound and, after 3 rounds,
  unchallenged.
- **Case (d)** (multi-gen forest roots) is resolved for the Shiny app's own reactive chain, and —
  more importantly — is now covered as one instance of a *general* backstop (§3.1.1 below) rather
  than needing its own narrow proof.

**What is NOT yet resolved, and is this session's own honest conclusion, not glossed over:**

A **4th round of adversarial critique**, which this session ran specifically to probe the seam
between round 3's own two headline fixes, found — independently, via 3 different lenses, each with
an executed counter-example — that **reinstating `sweepMinSep()` as a safety net (fixing round 2's
finding that it was needed) breaks the invariant the new `orderBySex` sign-fold formula (fixing
round 2's other finding) depends on.** Concretely: when `sweepMinSep()` moves one of an
`orderBySex`-qualifying union's own real children, the union's midpoint can drift by more than the
sign-fold formula's own tolerance budget, inverting the male/female left-right ordering the fix
exists to preserve — the *opposite* of what it's supposed to guarantee. This is disclosed, not
hidden: round 3's own §6 items 4/5 (below) had already flagged this exact interaction as
"qualitatively bounded but not measured" — the round-4 critique measured it, and found it breaks.

**This is not a new failure mode — it is the same one, recurring a 4th time inside the design-note
stage alone** (on top of the 6 prior full implementation attempts and this plan's own first draft):
a locally-computed correction (here, `sweepMinSep()`'s reinstatement) interacts with another
locally-computed correction (the sign-fold formula) in a way neither fix's own author checked
against the other. Finding this *here*, before any implementation code exists, is exactly the
point of running Phase 1b as its own dedicated, adversarially-gated research phase rather than
discovering it as a 7th failed implementation attempt.

**Recommendation:** treat cases (a)/(b)/(c)/(d) and the core 2b architecture as settled inputs to a
short **Phase 1b continuation** (not a full restart) that resolves specifically the
`sweepMinSep()`-vs-`orderBySex`-sign-fold seam, using one of the 3 concrete candidate fixes the
round-4 critique itself proposed (§7 below) as a starting point — rather than proceeding to Phase 2
on an unresolved mechanism, or discarding the substantial, validated progress documented here.

---

## 1–6. Full design note (round 3, as adversarially critiqued)

Everything in sections 1 through 6 below is the round-3 document produced this session, carried
forward complete and unedited except for this heading and the annotations in §3.1.1/§3.1.2 and §6
flagging exactly where round 4's critique (§7) found a real defect. Do not implement §3.1.2's
sign-fold formula as specified without first resolving §7.

### 1. Enumerated instances of the "one level per edge" violation

| # | Case | Status | Where it lives in code today |
|---|---|---|---|
| (a) | An individual's own anchored mating union renders at the **same gen** as the individual (0-delta) | **Confirmed, must be handled** | `positionIndividual()`, `R/makePedigreeDiagramData.R:912–915`: `subIds <- c(unitSub, directSub)` mixes `unitSub` (mating units this individual anchors, rendered at `unitGenOf[[unitId]] == genOf[[id]]`, i.e. the individual's own gen) with `directSub` (D5 direct children, rendered at `id`'s gen + 1). Concrete fixture: founder `P` anchoring `P×M` (child `C2`) while also having a direct child `C1` — `CHILDREN(P) = {P×M-union (gen(P)), C1 (gen(P)+1)}`, literal tree-siblings at different rendered gens under one recursive step. Realism corroborated independently: `hasOwnDirectChild()` (`:836–838`) already exists specifically to detect this shape for a different purpose (`orderBySex`'s exclusion guard, `:1062`). |
| (b) | A mating unit's own non-anchor-parent occurrence renders at the **same gen** as the unit (0-delta, symmetric to (a)) — but **not uniformly**: which mechanism applies depends on whether that occurrence's underlying individual has an independent genuine tree position elsewhere. See the B1/B2/B3 split in §3.3. | **Confirmed, must be handled — non-uniformly** | `positionUnit()`, `R/makePedigreeDiagramData.R:889–899` (the true fold-in sub-case, B1 below): `subIds <- c(fpHere, kidIds)` mixes `fpHere` (the free-pass non-anchor parent, positioned via `leafContour(unitGenOf[[unitId]])` at `:895` — the unit's own gen) with `kidIds` (real children, one gen deeper). Already live in shipped code today. **But** `freePassIds <- Filter(function(id) !hasOwnDirectChild(id), neverAnchorIds)` (`:839–840`) *excludes* a non-anchor parent who independently has a real D5 direct child from ever being folded in this way — for that individual, today's shipped rendering instead falls back to their own, independently-computed real position (`nonAnchorNodeIds <- ifelse(is.na(dupIdx), matingUnits$nonAnchor, duplicates$id[dupIdx])`, `:1519–1523` — the `is.na(dupIdx)` branch is exactly this case, a long mate-line edge to the individual's real node, not a phantom leaf). Any 2b mechanism that treats every non-anchor occurrence identically reproduces a same-entity-multiple-tree-positions defect for this individual — confirmed live below (§3.3). |
| (c) | A duplicate/free-pass node's "real" position is elsewhere in the forest, reached only through its anchor occurrence | **Confirmed, distinct in kind — not a 0-delta tree edge at all today** | `duplicates` (`R/makePedigreeDiagramData.R:500–502`, D1 output) is never a `childEdges` member of anyone — it is not currently a tree-recursion node at all. `dupX = finalUnitX[unit] + minSep * 0.4` (`:1177–1180`) is computed **entirely outside** the recursive merge, as an inert, near-zero-width post-hoc marker with zero downstream dependents. |
| (d) | Forest roots under the synthetic super-root sit at different, nonzero gens post-trim | **Resolved narrowly, not generally** | Per the supplied gen-recompute trace (re-verified this session against `R/makePedigreeDiagramData.R:930–936`, `:456–458`, and `R/modPedigree.R:346–348`): `hasParentEdge <- realIds %in% childEdges$to; founderIds <- realIds[!hasParentEdge]; rootIds <- setdiff(founderIds, freePassIds)` (`:933–935`) is a **row-local string predicate** on a row's own `sire`/`dam` values — the *identical* predicate `findGeneration()` uses to assign `gen == 0`. No row-subsetting trim ever blanks a kept row's own `sire`/`dam` fields, so the two checks can never disagree *for the Shiny app's own reactive chain specifically*, where `R/modPedigree.R:346–348`'s own conditional recompute (`if (!"gen" %in% names(ped))`) is, in practice, always exercised because `R/qcStudbook.R:306` unconditionally recomputes `gen` via `findGeneration()` upstream before `modPedigreeServer` ever sees the pedigree. **What was overclaimed:** `.positionMatingUnitForest()`'s and `makePedigreeMatingLayout()`'s own documented contract (`required <- c("id","sire","dam","sex","gen")`, `R/makePedigreeDiagramData.R:722`, and the `@examples`-block direct-script-caller usage this function is `@export`ed for) takes `gen` as a **caller-supplied column, validated against nothing** internally. A direct script caller can hand in a `ped` whose `gen` disagrees with `sire`/`dam` at any row, including a founder row. §3.1.1's reinstated backstop, not a narrower proof, is what actually protects this case. |

**Consequence for the candidate evaluation below:** (a), (b), and (c) require an active
reconciliation mechanism (§3.3/§3.4). (d) is one instance of the general class §3.1.1's reinstated
backstop protects against, alongside the deeper-tree case that class also covers.

---

### 2. Evaluating the plan's three named candidate mechanisms

*(Unaffected by round 4's finding — that finding is about an integration detail of 2b's own
execution, not about the choice of 2b itself.)*

Each candidate is quoted verbatim from the plan (§Migration Path, Phase 1b, step 2) and checked
against: **(i)** does it graft a non-structural comparison partner into
`apportion`/`moveSubtree`/`executeShifts`'s sibling-indexed bookkeeping; **(ii)** does it cover all
of (a)/(b)/(c)/(d); **(iii)** does it reintroduce "a one-directional sweep with no reconciliation
between 2+ locally-computed corrections, first one wins, everyone else collapses."

#### Candidate 1 — a revived Walker-style global per-level table, kept strictly outside `moveSubtree`

**Does not survive.** Coverage (ii) fails for cases (a)/(b): the colliding node is a genuine,
non-independent tree node, so nudging it post-hoc reopens its own already-correct sibling spacing
or stales an ancestor's midpoint. Failure-shape (iii) fails: traversal-order registries reproduce
the six prior attempts' exact failure mode one layer later.

#### Candidate 2 — restructure `CHILDREN()` so 0-delta edges are never tree-recursion children

Ambiguous between two readings; they do not fare the same way.

- **Reading 2a** ("excise the whole 0-delta subtree, translate it as a rigid unit"): survives (i)
  but fails (ii) at scale — nothing in the recursion for the parent's *other* children ever
  reserved width against the excised subtree.
- **Reading 2b** ("eliminate the 0-delta node from the recursion altogether by reattaching its real
  children one level up; represent the eliminated node only as a pure, one-way derived point"):
  survives all three checks *as a structural pattern*. This is the reading adopted, with its
  execution detailed in §3.

**Verdict: fails as 2a, survives as 2b**, subject to §7's own open question about one part of its
execution.

#### Candidate 3 — a same-rank/"flat edge" treatment from layered-graph-drawing literature

**Disqualified**, independent of the failure-shape check — it operates at the *ordering* phase,
never the *coordinate* phase, and this project's sibling order is already fully fixed before
positioning begins. Real precedent checked directly: Graphviz `dot`'s own `flat_search()`/
`flat_breakcycles()`/`flat_reorder()` machinery, and the academic "extended level graphs" /
intra-level-edge literature (Bachmaier, Buchner, Forster, Hong 2010) — both real, both aimed at
crossing-minimization, neither at width-apportioning.

---

### 3. Recommended mechanism

**Adopt Candidate 2 in its 2b form: structurally eliminate every 0-delta edge from the tree the
BJL engine sees, by re-parenting a mating union's real children directly onto its anchor
individual; represent the union itself, and every non-anchor-parent/duplicate occurrence *that has
no other genuine tree position*, as a pure, one-way–derived decorative point — computed in two
strictly ordered tiers, each fully reconciled before the next tier is permitted to read it, after
the genuine-tree recursion (`firstWalk`/`secondWalk`) is completely finished, INCLUDING a
reinstated, gen-grouped minimum-separation backstop as that recursion's own terminal step.
`orderBySex` is no longer a separate post-hoc pass at all: it is either folded directly into Tier
3's own derivation formula (for a B1 non-anchor party) or removed entirely as a no-op exclusion
(for a B2 non-anchor party).**

> **⚠ §7 finding: the sign-fold formula below (§3.1.2 Step 2) is NOT SOUND AS SPECIFIED.** A 4th
> critique round found and executed a counter-example. Read §7 before treating this section as
> implementable.

#### 3.1 Why this is not Candidate 1 wearing a different hat

The load-bearing distinction: Candidate 1 (and 2a) take an already-positioned, non-independent
tree node and *nudge* it after the fact — unsafe because other already-finished values were
derived *from* its pre-nudge position. 2b never positions the union node via the tree recursion
**at all** — there is no pre-nudge position for anything to have been derived from.

```
Tier 1 (genuine tree, INCLUDING     Tier 2 (union points)      Tier 3 (free-pass / duplicate reps)
  its own backstop)                  U.x = midpoint(realKids.x)  M_repr.x = U.x(FINAL) + sign*minSep*0.4
  firstWalk / secondWalk (BJL)   →     + tier-2's OWN confluent →  + tier-3's OWN confluent sweep
  + sweepMinSep() backstop             sweep, resolving ALL         + (B1 only) a sex-aware SIGN
    (gen-grouped, real                 union-vs-genuine and          choice, folded directly into
    individuals only, run ONCE,        union-vs-union collisions     the formula itself [SEE §7] --
    §3.1.1)                            — nothing in tier 3 may       no separate swap step
  -- NO orderBySex swap step           read ANY union's x until      -- (B2 only) EXCLUDED from any
     lives here any longer --          EVERY union's x in this          reordering, §3.1.2 — renders
     see §3.1.2                        tier is done moving              at its own genuine position
```

##### 3.1.1 `sweepMinSep()` is reinstated as Tier 1's own terminal step — the invariant round 2 needed does not hold, proven by execution

Round 2 claimed BJL's cross-branch guarantee makes `sweepMinSep()` redundant "at the same gen."
**This is false, proven false by construction, not by an abstract counterexample.** Direct trace
of `R/positionTreeApportion.R` confirms `apportion()`/`moveSubtree()`/`executeShifts()` contain no
`gen` field anywhere — every comparison is recursion-depth-relative, never absolute-display-row.
`.positionMatingUnitForest()`'s own existing defensive code (`ped$gen[is.na(ped$gen)] <- 0L`, line
733) exists precisely because `findGeneration()` provably leaves a child's `gen` as `NA` (later
forced to `0`) whenever a recorded parent is a **dangling reference**. Executed reproduction this
session:

```
ped <- data.frame(id=c("F0","D","C"), sire=c(NA,"F0","S"), dam=c(NA,NA,"D"), sex=c("M","F","M"))
gen <- findGeneration(ped$id, ped$sire, ped$dam)   # => gen == c(0, 1, NA) -> forced to 0
```

Simulating 2b's own `CHILDREN()` for this fixture against the real, shipped Phase 1a engine (no
`sweepMinSep()` involved): `F0.x == 0`, `C.x == 0` — an **exact coincidence**, `C` being `F0`'s own
grandchild, never a competing sibling branch. This directly falsifies round 2's claim.

**Resolution: `sweepMinSep()` is reinstated, algorithmically unchanged from today's shipped
version, as the literal terminal step of Tier 1** — run once, immediately after `secondWalk`
completes, strictly before Tier 2 reads anything. One genuine simplification survives: today's
pipeline needs `sweepMinSep()` twice; under 2b's tiering, Tier 1 is never touched again once
finished, so it runs once.

> **§7 finding, not resolved by the paragraph below as originally written:** the next paragraph
> (carried forward from round 3, struck through in spirit though kept verbatim below for the
> record) claimed this interaction was bounded and immaterial to §3.1.2's own correctness. Round
> 4's critique proved, by execution, that it is **not** immaterial — see §7.

**A bounded, disclosed interaction with §3.1.2's own invariant [DISPUTED, SEE §7].** §3.1.2 below
proves that for an `orderBySex`-qualifying union, the anchor's Tier-1 `x` and the union's own Tier-2
`x_raw` are *exactly* equal, by construction. If `sweepMinSep()`'s reinstated backstop happens to
move one of that union's own real children, the anchor's own `x` — computed by `firstWalk` *before*
`sweepMinSep()` runs, and never recomputed afterward — can drift from the union's post-sweep
`x_raw` by "at most a handful of `minSep`-scaled units," which this document originally claimed
"does not affect the fix below, which only needs a coarse left/right decision, never exact
co-location." **§7 shows this reassurance is false**: the minimum possible drift from a single
`sweepMinSep()` push (≥ `minSep` = 1) already exceeds the sign-fold formula's own tolerance budget
(`minSep*0.4` = 0.4) in the typical case, not merely a rare tail.

#### 3.1.2 `orderBySex` — resolved by elimination, not relocation [SIGN-FOLD FORMULA UNSOUND, SEE §7]

Round 2 (following the parent plan) treated `orderBySex` as an unmodified pass "running once, after
`secondWalk` completes." This round's critique found this unsound for both non-anchor parties in a
qualifying pair: a B2 party gets teleported away from their real subtree by a literal value-swap; a
B1 party doesn't have an `x` to swap with at any point a single placement of the swap could run
without staling something else.

**The resolution eliminates the swap step entirely**, splitting on the same B1/B2 classification
§3.3 already establishes for a different purpose.

**Step 1 — a provable invariant, verified by execution.** For any mating unit `U` that qualifies
for `orderBySex` under its own existing, unmodified gate: let `P` be `U`'s anchor and `M` its
non-anchor party. Because `mateCount(P)==1` and `!hasOwnDirectChild(P)`, `CHILDREN(P)` under 2b is
*exactly* `U`'s own real children — the identical set Tier 2's `U.x_raw = midpoint(realKids.x)`
formula reads. Proven algebraically and confirmed by direct execution: **`P.x` (Tier 1, final) and
`U.x_raw` (Tier 2, pre-sweep) are identical by construction** for every `orderBySex`-qualifying
union.

**Step 2 — the B1 case: fold the swap into Tier 3's own formula.**

```
sign(M) = (sex(P) == "F" && sex(M) == "M") ? -1 : +1
M_repr.x = U.x(FINAL) + sign(M) * minSep * 0.4
```

Since `P.x == U.x_raw` exactly (Step 1), the default (`sign = +1`) already places `M` right of `P`
whenever `P` is male; only when `P` is female and `M` is male does the sign flip. **This step's own
soundness depends entirely on Step 1's invariant surviving to the point Tier 3 evaluates it — which
§7 shows it does not, whenever `sweepMinSep()` has touched one of `U`'s real children.**

**Step 3 — the B2 case: exclude, disclosed.** *(Unaffected by §7 — this step never reads `U.x` at
all.)* `orderBySex`'s qualifying test gains one more conjunct: `!hasParentEdge(nonAnchorId)`. A B2
pair is excluded from any reordering; each party renders at its own genuine position.

**Step 4 — the sweep-recurrence check this task requires.** *(This is exactly where round 4's
critique found the remaining gap — see §7: the check as originally performed verified no code
reads a value before its own **direct** upstream tier finishes, but did not verify that the
upstream tier's finished value still satisfies the formula's own load-bearing premise.)*

#### 3.2 CHILDREN(), redefined

*(Unaffected by §7.)*

```
CHILDREN(individual I):
    directRealChildren(I)                 -- childEdges$to where from == I,
                                              I not a union id           -- I.gen + 1
  ∪ unionRealChildren(I)                  -- for every mating unit U with
                                              U.anchor == I:
                                              childEdges$to where from == U
                                                                          -- I.gen + 1
  -- Ordering: group by originating union (D4/id order among the units I
  -- anchors) first, then direct children.

CHILDREN(mating-unit U), U an ORPHAN unit (anchor == NA, issue #154):
    childEdges$to where from == U          -- U.gen + 1, always a genuine edge.
    -- An anchored unit U is NEVER itself passed to firstWalk/apportion.

SUPER-ROOT: CHILDREN(SR) = rootIds ++ orphanUnitIds, D4 order, UNCHANGED
```

#### 3.3 Derived (non-participating) nodes — a gated formula, not a uniform one

*(Unaffected by §7.)*

##### 3.3.1 The three (not two) classes of non-anchor occurrence

For a mating unit `U` anchored by `P`, with non-anchor parent `M`:

- **B1 — true fold-in, decorative-only.** `M` never anchors any unit, is a founder
  (`!hasParentEdge(M)`), and `!hasOwnDirectChild(M)`. **Gets a derived point.**
- **B2 — already has an independent genuine tree position.** `hasOwnDirectChild(M)` or
  `hasParentEdge(M)`. **No derived point** — the render layer points directly at `M`'s own,
  already-final genuine `x`.
- **B3 — genuine duplicates.** Every row of `forest$duplicates` (D1's own logic, unchanged). **Gets
  a derived point**, by the same formula as B1, attached to its own `matingUnitId`.

```
tier3FreePassIds (renamed to avoid the dual-definition-under-one-name confusion round 2's own
  critique found; the ORIGINAL, UNPATCHED freePassIds -- used ONLY for rootIds, verbatim --
  keeps its original name unchanged):
    Filter(function(id) !hasOwnDirectChild(id) && !(id %in% childEdges$to), neverAnchorIds)
```

##### 3.3.1a Why B3 is deliberately *not* gated the way B1 is

A duplicate marker is a cross-reference annotation, not a claim to be "the" canonical position — an
individual's B1-or-B2 occurrence is their one primary position; every *additional* marriage gets
its own, always-additional duplicate marker by design, regardless of whether the primary occurrence
is B1 or B2. No gating needed for B3.

##### 3.3.2 Why B2 is not merely "skip it"

A B2 individual was always going to get a genuine tree position under 2b's own `CHILDREN()`/
`rootIds` rules — excluding B2 from derivation is 2b's own `CHILDREN()` promise, honored, not a
special case grafted on.

##### 3.3.3 Derivation formula for B1/B3, and its tiering

```
-- Tier 2 (union derivation -- reads ONLY tier-1 genuine values, INCLUDING tier 1's own §3.1.1
-- sweepMinSep() backstop, already finished):
for every ANCHORED mating unit U (anchor = P), independently:
    realKids = childEdges$to[childEdges$from == U]
    U.x_raw = midpoint(x[realKids])
    U.gen = P.gen
-- U.x_raw is NOT final -- see §3.4.

-- Tier 3 (free-pass / duplicate derivation):
for U's own B1 non-anchor parent M, or every B3 duplicate occurrence of M elsewhere (M_repr):
    sign(M) = (M is B1) && (sex(U.anchor) == "F" && sex(M) == "M") ? -1 : +1   -- [SEE §7]
    M_repr.x = U.x(FINAL) + sign(M) * minSep * 0.4
    M_repr.gen = U.gen
```

##### 3.3.4 A fourth case, found by execution in round 2, unchanged this round

Round 2 found, by execution, that **today's currently shipped code** (not 2b) has an undocumented
last-write-wins collision when an individual who qualifies for `freePassIds` under the unpatched
test also has her own real parent edge. This is a pre-existing, currently-shipped defect,
orthogonal to Phase 1b — recommend filing it as its own `BACKLOG.md`/GitHub issue item, alongside
§3.1.1's own `F0/D/C/G` counter-example (both trace to the same root cause: a dangling-parent-forced
NA `gen`).

#### 3.4 Tiered terminal reconciliation

*(Unaffected in mechanism by §7 — §7's finding is that Tier 3's own formula input, not the tiering
structure itself, is unsound in one specific case.)*

```
-- TIER 2: union-point reconciliation, immediately after Tier 1 (incl. the §3.1.1 backstop):
sort every ANCHORED unit's U.x_raw by (gen, id), radix, ascending
for each, in that fixed order: nudge x by the smallest positive epsilon needed to clear every
  OTHER already-placed node (genuine, invariant; or a prior union this pass) at the same gen
  -- exact-tie form ONLY, matching :1199-1210 (§3.4.3)
-- every U.x is now FINAL.

-- TIER 3: free-pass / duplicate reconciliation, only after every Tier-2 union has finished moving:
for every B1/B3 M_repr, per §3.3.3's formula, reading ONLY tier-2's now-FINAL U.x:
    M_repr.x = U.x(FINAL) + sign(M) * minSep * 0.4
sort every M_repr by (gen, id), radix, ascending; nudge to clear collisions, same exact-tie form.
```

##### 3.4.1–3.4.3

*(Unaffected by §7 — carried forward from round 3 unedited.)* `M_repr.x` is defined only in terms
of `U.x(FINAL)`, a value guaranteed complete by the time any `M_repr` formula runs — no code path
reads a union `x` that later moves. Tier 3 is strictly downstream of Tier 2, not mutually blind to
it. Exact-tie semantics (not general min-sep enforcement) is deliberately scoped for Tier 2/Tier 3
derived points, matching the current shipped pipeline's own already-validated guarantee for
union/duplicate positions — distinct from §3.1.1's reinstated `sweepMinSep()`, which *does* provide
general separation, but only for genuine tree individuals at Tier 1.

#### 3.5 Coverage confirmation against §1

- **(a)** — closed structurally.
- **(b)** — closed non-uniformly: B1 gets the derived-point treatment (sign-aware formula **unsound
  as specified, §7**); B2 is excluded and points at its own genuine position.
- **(c)** — unchanged in shape from today's working `dupX`, unified with B1's formula and
  consistently tiered.
- **(d)** — covered as one instance of the general class §3.1.1's backstop protects.
- **`orderBySex`'s own goal** — preserved for B1 **only if §7's gap is closed**; honestly dropped
  and disclosed for B2.

---

### 4. Required Phase 1b/Phase 2 test matrix

*(Carried forward from round 3. Tests 11 and 13 are individually correct but, per §7, were never
composed with each other — that composition is exactly where the defect lives. §7 adds Test 14.)*

1. The `P`/`C1`/`P×M-union`/`C2` fixture from §1(a): assert `P.x` equals the exact midpoint of `{C1.x, C2.x}` computed directly from those children's own final `x`, not stated in terms of `U.x`; separately confirm `U.x == C2.x`.
2. A mating unit with ≥3 real children plus a true B1 free-pass non-anchor parent: confirm `U.x` = midpoint of all 3, free-pass representative at `U.x(FINAL) + minSep*0.4`.
3. A duplicate (B3) occurrence of an individual anchoring elsewhere in a different branch.
4. A synthetic forest with roots spanning 2+ gens under the super-root — the well-formed-input case (§1(d)) and, separately, the malformed-caller-supplied-`gen` case (§3.1.1's backstop).
5. A grandchild simultaneously a reattached real child and an `orderBySex`-qualifying co-parent — labeled by which sub-case (B1 or B2) it exercises.
6. A `WCPXHD`-shaped fixture (one individual anchoring 5 unions).
7. A founder with a real D5 direct child who is also non-anchor parent of 2 other unions (one free-slot, one genuine duplicate) — assert exactly 2 renders total.
8. A founder who is the sole non-anchor mate in one union and separately has her own D5-fallback child — assert B2 classification, no separate derived node.
9. The `GGGP1/GGP1/X`×`GP1/GP2/M`×`C` fixture (§3.3.4) — assert exactly one write to `M`'s position.
10. A union whose `U.x_raw` exactly coincides with an unrelated genuine node — assert Tier 2's sweep resolves it before Tier 3 reads it.
11. An anchor `P` (female, qualifying) with union `U = P×M`, `M` a true B1 individual: assert `P.x` unmodified, `M_repr.x = U.x(FINAL) - minSep*0.4`, `M_repr.x < P.x`.
12. The `Yale`/`Mia` B2 worked example: assert exclusion from reordering, neither position altered.
13. The `F0→D→[S(dangling)×D]→C`/`G` fixture (§3.1.1): assert `sweepMinSep()`'s backstop separates `C` and `F0` by at least `minSep`.
14. **(New, per §7 — the composition neither Test 11 nor Test 13 alone exercises.)** A B1
    `orderBySex`-qualifying union `U = P×M` (as in Test 11) placed so that `sweepMinSep()`'s
    backstop is forced to move one of `U`'s own real children (as in Test 13, but touching `U`'s
    children specifically, not an unrelated branch). Assert the resulting `sign(M)` choice still
    places `M` on the historically-correct side of `P` — per §7, this test is expected to **fail**
    against §3.1.2's formula as currently specified, and is the required regression test for
    whichever fix a follow-up session adopts.

---

### 5. Consequences for the plan's own open decisions

- **Reverses the plan's tentative "full-width participation" preference for duplicate/free-pass
  nodes** — unaffected by §7.
- **`sweepMinSep()` is retained, not eliminated** — a disclosed reversal of the parent plan's own
  "Target: eliminated entirely" hope, exercising that hope's own stated contingency ("Phase 1b's
  mechanism... shown to actually deliver this... not merely for the genuine-tree core"). Runs once
  under 2b, not twice as today.
- **`orderBySex` (issue #145) is restructured, not "preserved unchanged"** — eliminated as a
  distinct pass; folded into Tier 3 for B1 **pending §7's resolution**; a disclosed, honest
  exclusion for B2. Real magnitude of the B2 behavior change is unmeasured — Phase 2 must measure
  it directly on the bundled fixture, not guess.
- **§1(d)'s closure is narrowed, honestly**: resolved for the Shiny app's reactive chain; the
  reinstated `sweepMinSep()` backstop, not a narrower proof, protects the exported contract.
- **Open Question 9** — a global per-level table is not needed for cases (a)/(b); it *is* needed,
  in the narrow, already-shipped `sweepMinSep()` form, for the gen/depth-mismatch case.
- **Open Question 10** (stale `gen` recomputation) — no longer load-bearing for this migration's
  own safety, though the underlying data-quality question (3 untraced call sites) stays open.
- File `F0/D/C/G` (§3.1.1) alongside §3.3.4's pre-existing defect as one `BACKLOG.md`/GitHub issue.

---

### 6. Fresh adversarial re-check invitation — items 4 and 5 are exactly what §7 confirmed

This design note's central claims were: a 3-stage acyclic chain, plus a provable invariant
(`P.x == U.x_raw`) a formula change depends on. A future adversarial pass was asked to specifically
try to construct a fixture where:

1. A tier-3 (`M_repr`) value is read by anything other than final rendering.
2. A tier-2 (`U.x`) value is read by anything other than a tier-3 formula or final rendering.
3. The exact-tie-only sweep semantics leave a derived point close enough to unrelated content to be
   a real, user-visible defect.
4. **The `P.x == U.x_raw` invariant is disturbed by more than a cosmetically-irrelevant amount by
   the reinstated `sweepMinSep()` backstop** — flagged as "qualitatively bounded but not measured."
   **§7: measured. It is not cosmetically irrelevant — it inverts the ordering guarantee.**
5. **A case where the backstop and the B1 sign-flip interact in an unanticipated way** —
   **§7: this is exactly what happened.**
6. Whether a dangling parent of an orphan unit can itself receive a `__dup_` entry — still
   unresolved, orthogonal.
7. Whether Track 3's clamp-to-parent-span needs a 2b-compatible equivalent — still open, left for
   Phase 2.
8. Whether the B2-exclusion behavior change is acceptable once measured — still open.

---

## 7. Round-4 adversarial critique: the seam confirmed broken, and 3 candidate fixes

A 4th round of critique (3 independent lenses, run specifically to probe §6 items 4/5 above) all
independently found and executed the same defect, converging from different constructed fixtures.

**The finding, in one sentence:** `sweepMinSep()`'s reinstatement (§3.1.1, fixing round 2's finding
that it was needed) and the B1 sign-fold formula (§3.1.2, fixing round 2's other finding about
`orderBySex`) were each proven sound *in isolation*, but nobody checked them **against each other**
— and when composed, `sweepMinSep()` moving a real child of an `orderBySex`-qualifying union drifts
that union's midpoint by an amount that reliably exceeds the sign-fold formula's own tolerance
budget, inverting the male/female ordering the fix exists to preserve.

**The executed counter-example (one lens's version, reproduced exactly):** `P` (female,
`orderBySex`-anchor) with a real child `C1` and `C2`; `P`'s union `U = P×M`, `M` a true B1
individual. Pre-sweep, `P.x == U.x_raw` exactly, as §3.1.2 Step 1 proves. An unrelated node `G`
elsewhere in the forest is given a colliding gen (legal — see §1(d)'s own concession that a
caller-supplied `gen` is unvalidated), forcing `sweepMinSep()` to push one of `C1`/`C2`. Midpoint
moves from `1.0` to `1.5` — a `0.5` drift. Applying Step 2's formula (`sign = -1`, since `P` is
female and `M` is male): `M_repr.x = 1.5 - 0.4 = 1.1`, which is **greater than** `P.x = 1.0` — `M`
renders to `P`'s right, not left. The formula's own required output (`M_repr.x < P.x`) is violated.
A second lens independently derived the identical inversion from a different starting fixture
(`U.x_raw` drifting `0.700` against a `0.400` tolerance budget, `M_repr.x = 5.300 > P.x = 5.000`).

**Precisely how large a drift this takes, stated carefully (not overclaimed):**
`sweepMinSep()`'s own push formula sets a colliding node's `x` to exactly `prevX + minSep`, so it
**guarantees** the pushed node ends up ≥ `minSep` away from its now-immediate left neighbor —
but the *size of the push itself* (`new_x - old_x`) is only as large as whatever gap was missing,
which can in principle be small if the pre-sweep gap was already almost `minSep`. What the
executed fixtures actually establish is narrower and fully sufficient: **for the adversarial case
`sweepMinSep()` exists to correct — two nodes forced into an exact or near-exact collision, exactly
the shape a dangling-parent-forced `gen` mismatch produces** — the push is large enough (both
executed examples: `0.5` and `0.700`) to exceed the sign-fold's `minSep*0.4 = 0.4` tolerance budget.
This is not a hypothetical worst case somewhere in the tail of the input space; it is the specific,
realistic scenario (§3.1.1's own `F0/D/C/G` counter-example, or a caller-supplied `gen` mismatch
under §1(d)) that motivated reinstating `sweepMinSep()` in the first place — so the two fixes'
failure modes are not independent tail risks, they are triggered by the same underlying condition.

**All 3 lenses independently found the same root cause, described identically across lenses in
different words:** this is the *same signature failure shape* named as the root cause of the 6
prior full implementation attempts and this plan's own first draft — "a value read before its own
upstream correction is final," or equivalently "2+ locally-computed corrections whose order/
magnitude interaction was never checked" — now recurring a 4th time, between this round's own two
fixes, each individually well-argued and individually verified, but never verified *together*.

**3 concrete candidate fixes, proposed by the critique lenses themselves, for a follow-up session
to evaluate (none adopted here — adopting one without its own adversarial pass would repeat exactly
the mistake this note exists to describe):**

1. **Compare `M_repr.x` against `P.x`'s own actual final value directly** (read-only, never
   swapped) instead of assuming `U.x(FINAL) ≈ P.x`. This keeps the "no swap step" simplification
   but computes the sign from a live comparison against ground truth rather than a static,
   pre-derived assumption.
2. **Extend the B2-style hard exclusion** to cover any B1 union whose real-child set was actually
   touched by the `sweepMinSep()` backstop — i.e., detect the specific condition that breaks the
   invariant and fall back to "no reordering" exactly there, rather than a blanket rule.
3. **Prevent `sweepMinSep()` from ever moving a real child of an `orderBySex`-qualifying B1 union**
   in the first place — scoping the backstop's own reach rather than the sign-fold formula's
   tolerance.

Each carries its own trade-off (fix 1 adds a read dependency the "elegant, no-swap" framing
specifically avoided; fix 2 further shrinks how often `orderBySex`'s guarantee actually holds,
compounding the already-disclosed B2 exclusion; fix 3 constrains the general-purpose safety net for
the benefit of one specific downstream consumer) that a follow-up session must weigh, not assume.

**Session outcome:** this session ran 3 full repair-and-critique rounds (plus the original research
phase) before reaching this point — a bounded, deliberate stopping point, not an unbounded chase.
Each round found genuinely new, substantive, previously-unconsidered defects, matching this
investigation's own well-documented history; stopping here rather than attempting a 4th repair
matches Phase 1b's own explicit charter that "more research needed... is an acceptable, honest
outcome, not a failure of the phase," and avoids compounding an already-long critique chain within
one session (`SESSION_RUNNER.md`'s own "1 and done" discipline). **Phase 2 must not begin until a
follow-up session resolves this specific seam** — the rest of this document (cases (a)/(b)/(c)/(d),
the B1/B2/B3 classification, the literature corroboration, `sweepMinSep()`'s necessity) is settled
enough to build on directly.
