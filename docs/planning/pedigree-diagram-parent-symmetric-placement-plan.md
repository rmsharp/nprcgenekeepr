# Pedigree Diagram: Symmetric Parent Placement Plan

**Status: DESIGN RATIFIED, session 665 (2026-09-02, owner-confirmed via `AskUserQuestion`
after the finding below was presented with full evidence).** Read **"CHAIN RULE — RESOLVED
(Session 665)"** below before "ITEM 4 CONFIRMED TO FAIL" — it corrects that section's own
conclusion with a code-and-kinship2-verified re-derivation. No code in `R/` was touched
this session either (every number below comes from either kinship2's own `align.pedigree()`
run directly, or from calling this project's own real, unmodified internal functions
— `.buildMatingUnitForest()`, `.positionTreeApportion()` — to read their actual raw output,
never from hand-simulated/assumed values). **Ready for implementation (RED/GREEN/REFACTOR)
in a future session** — see "What the implementing session needs to do" at the end of the
new section.

Original ratified choice (Option 1, "symmetric half-offset") was **incomplete**: it only
specified the root-anchor case and left the current, on-anchor union position for a
NESTED qualifying pair unaddressed, which is exactly where the dogleg/off-center-bar
problem actually lives once fixed for roots.

**Owner-directed correction (live, via direct visual review of the "recentered simulation"
image): "Conditional shift" — RATIFIED, verified bit-exact against kinship2 ground truth.**
For every qualifying union, the union point must equal both (a) the true parent midpoint
and (b) the mean of the union's real children — today these coincide only by accident (an
unconstrained root anchor). Shift whichever side is not pinned by an outside constraint:

- **Anchor is a root** (no parent of her own, free to move): shift **both** parents equally
  so their midpoint lands exactly on the (unchanged) children's mean.
- **Anchor is NOT a root** (already positioned as someone else's real child elsewhere in
  the tree): shift the union's own children instead — in general, each child's **entire
  subtree, rigidly** — so their mean lands exactly on the (unchanged) true parent midpoint.

**Verified, same session:** applied by hand (a safe return-value-override monkey-patch —
`.positionMatingUnitForest()`'s real, unmodified computation is called first, then only
the specific rows this rule identifies are corrected) to Track B's full 16-subject
fixture: `P1/P2` and `P3/P4` (root anchors) shift `-0.5`; `L1/L2/L3` and `C4a` (children of
the two NESTED qualifying pairs, `M1×G3` and `C4×P6`) shift `+0.5`; every other node
(`C1/C2/C3/C4/G3/M1/P6`) is untouched. Result, measured from the actual final rendered
node table (not an intermediate value — Learning from this same session's own `P4`
measurement mistake, see below): **max abs diff vs. `kinship2::align.pedigree()` = 1.8e-7
(floating-point noise) across all 15 placed individuals.** Rendered image confirms every
union dot centered and every descent line straight, including the `M1×G3` sibling bar.

**This directly overturns the prior Track 7 Phase 3 design doc's own §1.4 conclusion**
("a hard binary... no intermediate value achieves partial descent-line fidelity without
proportionally re-approaching the same original defect") — that analysis considered only
moving the union marker itself; it did not consider moving the parent pair or the
children instead. Not a flaw in that session's rigor (Finding A/B were real, measured
facts about the union-marker-only formula) — a gap in the SOLUTION SPACE it searched, not
in the diagnosis.

**Not yet verified — explicitly the RED phase's job, not assumed to already work:**
1. Every shifted child in this fixture is a childless leaf. A general implementation must
   translate a shifted child's **entire subtree** rigidly, not just her own point —
   untested here.
2. Re-verification against the real 375-individual production fixture
   (`inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`) — this project's own established
   discipline for any change to this function, and not optional given how many of this
   session's own earlier measurements needed correction along the way.
3. Interaction with Track 7 Phase 2's union-vs-node collision-avoidance push, and with B3
   duplicate nodes — both untouched by this fixture's own qualifying units.
4. A chain of 2+ nested qualifying pairs (a shifted child who is herself the root of
   another qualifying pair further down) — not present in this fixture.

---

## CHAIN RULE — RESOLVED (Session 665, 2026-09-02)

**Finding: no new chain-specific rule is needed. Option 3's existing two cases (root /
non-root), applied to every qualifying pair in ascending-generation order and always
reading each anchor's *current* (possibly already-corrected) position rather than a cached
Tier-1 value, already reproduce kinship2 exactly — including Track B shrunk, the very
fixture "ITEM 4" below found this rule wrong for.** The "wrong" result recorded there
(`M1=0` where kinship2 gives `0.5`) traces to arithmetic errors in that session's own naive
hand-simulation, not a gap in the rule. Both are diagnosed below with real numbers so a
future session does not need to take this claim on faith.

### Why "ITEM 4" got M1 wrong — diagnosed, not guessed

ITEM 4's naive result: `P1=-1, C4=0, M1=0, P2=1, C4a=1, L3=1, P6=2, G3=2`. Two concrete
arithmetic errors, found by comparing against what Option 3's own ratified text actually
specifies:

1. **The root case's own text says "shift BOTH parents equally"** — the naive computation
   shifted only the anchor (`P1: 0→-1`, `C4: 1→0`, both by a full `-1*minSep`) and left
   the mate entirely at her raw Tier-3 value (`P2` stayed `1`, `P6` stayed `2`). A correct
   symmetric split moves the anchor by half the needed delta and the mate by the same half
   in the same direction — e.g. `P1: 0→-0.5`, `P2: 1→0.5` (verified below) — never moves
   only one side, and never by a full `minSep`.
2. **`G3` (M1's Tier-3-derived mate) was computed inconsistently with M1's own naive
   value** — the existing, unmodified Tier-3 formula is `G3 = M1 + sign*minSep`; with the
   naive session's own `M1=0` that gives `G3=1`, not the `G3=2` it recorded. `L3=1`
   (naive) is exactly `mean(M1=0, G3=2)` — i.e. the child-shift step correctly followed
   *its own* (already-wrong) `G3`, so this is a downstream consequence of error 2, not a
   third independent bug.

Neither error is a property of the rule itself — both are places the ad hoc, never-tested
monkey-patch script deviated from what "shift both parents equally" / "the union's own
Tier-3 mate formula" already say. This is exactly the kind of claim `SESSION_RUNNER.md`
Failure Mode #11 (gaps from memory) warns against carrying forward uncritically — re-derived
from scratch this session, against real numbers, rather than trusted.

### Re-derivation: kinship2's own QP, read directly

`scratchpad/alignped4.R` (kinship2's real `alignped4()`, extracted a prior session, read in
full this session) builds one joint quadratic program over ALL individuals at once:
- a **spousal term** per mated pair, weight `sqrt(align[2])` (default `align[2]=2`),
  penalizing `pos[spouse1] - pos[spouse2]` — wants mates coincident, but a **hard**
  ordering constraint (`cmat`/`dvec`) forces every pair of same-level adjacent nodes
  `>= 1` (`= minSep`) apart, so in practice mates always land pinned at exactly that floor
  (matching this project's own already-established, already-verified "achieved spousal
  separation is exactly `minSep`-equivalent" finding, `BACKLOG.md`'s Track 7 design record).
- a **family term**, one row *per child*, weight `sqrt(k^-align1)` (`k` = that family's
  child count, default `align1=1.5`), penalizing `child - mean(parent1, parent2)` — wants
  each child at the true parent midpoint.

Solving this system by hand for an isolated chain (`A×B → sole child C → C×D →
children`), with the spousal constraint active (`d = c + minSep`, matching the
already-established finding above) collapses cleanly: **the child-family term's own
first-order condition always sets the children's mean to exactly `(c+d)/2`, for *any*
weight and *any* child count `m`** (the cross term vanishes because `mean(children)` is a
free variable coupled to `(c+d)/2` by nothing else) — which in turn means the *children*
term contributes nothing to `c`'s own gradient at the optimum, leaving `c`'s value set
purely by upstream terms. Concretely, when `A×B` are anchored (their own position fixed by
context elsewhere in the pedigree), **`C` lands exactly at `mean(A,B)` regardless of `m`,
`k`, or the weight formula** — confirmed empirically (not just algebraically) against real
`kinship2::align.pedigree()` runs, `m` = 1..4:

```
m=1: A=0.0 B=1.0 C=0.5 D=1.5 E1=1.0
m=2: A=0.0 B=1.0 C=0.5 D=1.5 E1=0.5 E2=1.5
m=3: A=0.0 B=1.0 C=0.5 D=1.5 E1=0.0 E2=1.0 E3=2.0
```
(`m=4` breaks this — the children's own level becomes *wider* than the parents' level,
flipping which level kinship2's QP anchors near zero. This is a kinship2-QP-internal
artifact of its single global joint optimization; it doesn't transfer to this project's
own architecture, which never does a global joint solve — see "Why this doesn't need a
kinship2-style QP" below. Noted as a theoretical corner case, not required for this
design: the real target fixture always has other width at the anchoring level.)

### Re-derivation: through this project's own real code, not assumed values

Calling this project's real, unmodified `.buildMatingUnitForest()` +
`.positionTreeApportion()` on the actual Track B shrunk fixture (reconstructed via
`shrinkPedigree()`, byte-identical to `data-raw/kinship2FidelityValidation.R`) gives the
real raw values feeding into any correction — not assumed ones:

```
Raw tier1X:  M1=0  C4a=1  L3=0  C4=1  P1=0        (P2/P6/G3 are B1 free-pass mates —
Raw unitX:   __union_1(C4xP6)=1  __union_2(P1xP2)=0  __union_3(M1xG3)=0     excluded from Tier 1 entirely)
```

Applying Option 3's own two cases, unmodified, in ascending-generation order (`__union_2`
gen 0 before `__union_3` gen 1), reading each anchor's live value:

| Unit | Case | Computation | Result |
|---|---|---|---|
| `__union_2` (`P1×P2`) | root | shift both by `childrenMean(0) - (rawP1(0)+0.5) = -0.5` | `P1=-0.5, P2=0.5` |
| `__union_3` (`M1×G3`) | non-root | `M1` untouched by any correction (only ever a "child" argument for shift, never a root's own pair-member) → stays raw `0`; `G3 = M1+minSep = 1`; `trueMid = 0.5`; shift `L3` by `0.5 - unitX(0) = +0.5` | `M1=0` (unchanged), `G3=1`, `L3=0.5` |

Aligning to kinship2's own coordinate origin (`P1=0`, i.e. adding `0.5` to every value
above): `P1=0, P2=1.0, M1=0.5, G3=1.5, L3=1.0` — **bit-exact match to the kinship2 ground
truth this whole investigation started from** (`P1=0, M1=0.5, L3=1.0, P2=1.0, G3=1.5`).
No chain-specific logic was used — `M1` simply never moves, and by construction the
corrected `P1`/`P2` midpoint always equals `M1`'s raw value already (`childrenMean` in the
root case *is* `M1`'s raw `tier1X`, since `M1` is `P1`'s sole child) — the two cases already
compose correctly for this depth.

**Why a real chain rule is still needed for 3+ links, even though 2 links worked above:**
`M1` above was never itself the target of a shift (only ever read). In a 3-link chain
(`F1×F2(root) → A → A×B → C → C×D → children`), the *middle* link (`A`) **is** shifted —
she's one of `A×B`'s own children being moved by the `F1×F2` correction. If the `A×B`
non-root correction then reads `A`'s **stale, pre-shift** raw value instead of her
already-corrected one, the result is wrong. Verified directly, both ways, using this
project's own real raw values (`F1=0.5(collapsed with A/C at raw 0.5 pre-correction, W1/W2
providing width), rootIds=F1,W1,W2`):

```
ROOT   __union_1 (F1xF2): shift both -0.5  -> F1=0.0,  F2=1.0
NON-ROOT __union_2 (AxB):  A read FRESH (0.5, unshifted by the F1 correction since A
                            was never one of F1xF2's own two parent-members) -> B=1.5,
                            trueMid=1.0 -> shift C (A's child) to 1.0
NON-ROOT __union_3 (CxD):  C read FRESH (1.0, the JUST-corrected value from the line
                            above, not C's stale raw 0.5) -> D=2.0, trueMid=1.5 ->
                            shift E1,E2 to 1.0,2.0
```
Result: `A=0.5, C=1.0, F1=0, F2=1, B=1.5, D=2, E1=1, E2=2` — **bit-exact match against a
real `kinship2::align.pedigree()` run of the identical structure** (`F1=0,F2=1,A=0.5,
B=1.5,C=1.0,D=2.0,E1=1.0,E2=2.0`). Using `C`'s *stale* raw value (0.5) instead of the
just-corrected one (1.0) in the third step would have produced a visibly wrong `D`/child
placement — this is the one genuinely chain-specific requirement, and it generalizes to
any chain depth by the same generation-ascending, always-read-current-value discipline.

### General rule (supersedes "ITEM 4"'s per-pair-independent framing)

**Process every qualifying unit once, in ascending order of the anchor's `gen`. For each,
read the anchor's *current* position (its Tier-1 raw value, or an already-updated value
from an earlier iteration of this same pass — never a cached/stale copy) and apply
Option 3's existing two cases unmodified:**
- **Root anchor:** shift anchor and mate by the same amount, in the same direction, so
  their midpoint equals the union's existing children-mean (`unitX`, Tier 2). Children
  are not touched.
- **Non-root anchor:** compute the mate's position from the anchor's *current* value via
  the existing, unmodified Tier-3 formula (`anchor + sign*minSep`); shift the union's real
  children — each child's entire subtree, rigidly (untested by this session, see below) —
  so their mean equals the true parent midpoint (`mean(anchor, mate)`). The anchor and
  mate are not touched by this case.
- After either case, the union's own rendered `x` (Tier 2's `unitX`) must be recomputed
  from the (possibly now-shifted) children, so the dot continues to track its own
  children exactly (the pre-existing Track 6 invariant) — a mechanical consequence, not a
  new decision.

Since generation number already totally orders any chain (a chain parent is always a
strictly lower generation than the pair she anchors), sorting by `gen` ascending and
processing each qualifying unit exactly once is sufficient — no separate "detect a chain"
step is needed; the ordering alone makes "root" and "non-root, using a fresh anchor value"
compose correctly at any depth.

### Why this doesn't need a kinship2-style joint QP

kinship2 solves one global optimization; this project's architecture never does (Tier 1 is
a local, recursive, generation-by-generation apportion, not a joint solve). The rule above
stays entirely inside that existing architecture — it only asks that the correction pass
walk qualifying units in generation order and read live values, which is a straightforward,
local, single-pass computation (no QP, no solver dependency), not the "compound couple
node in tree apportion" Option 2 this plan's own Alternatives table already flagged as
higher-risk. Confirms Option 3 (not Option 2) remains the right choice.

### A real, separate problem this rule does NOT fix — confirmed, not assumed

Applying the corrected rule to *both* of Track B shrunk's qualifying pairs (the chain
`P1×P2 → M1 → M1×G3` above, AND the disconnected `C4×P6` root pair, independently
computed via the identical root case: `C4` raw `1` → shift `-0.5` → `C4=0.5, P6=1.5`)
produces **`P2=0.5` and `C4=0.5` — an exact collision between two unrelated families at
the same generation**, confirmed by direct computation, not assumed. kinship2 itself never
hits this (its one global joint solve spaces the whole level via a single hard ordering
constraint spanning every node, not per-family). This is exactly why the plan's own
"what a future session needs to do" item 2 (below) already says the corrected targets
must flow **through** `.deCollideIndividualPoints()`/Track 7 Phase 2's push-search, never
around them — this session's own arithmetic-correct rule still produces this exact
collision on this exact fixture, confirming that requirement is real and necessary, not
speculative.

### What the implementing session needs to do

1. Implement the rule above in `.positionMatingUnitForest()`: a single pass over
   qualifying units in ascending-`gen` order, reading live anchor values (no chain
   detection needed — see "General rule" above).
2. Feed the corrected targets **through** the existing collision-avoidance machinery
   (`.deCollideIndividualPoints()`, Track 7 Phase 2's push-search) — never write them
   directly to the final position table, confirmed necessary by this session's own
   `P2`/`C4` collision finding above.
3. Subtree-rigid translation for a shifted child who is not a leaf (this session tested
   only leaf children and one further sole-child link, both cases already covered by
   "shift the whole subtree" in the original ratified text — a real non-leaf, multi-
   descendant shifted child is still untested and is RED's job, not assumed to already
   work).
4. Re-verify Track B full stays bit-exact (already proven achievable, S664; do not
   regress it — full's `M1` has 3 siblings, so `k_top>1`, meaning it is NEVER a chain
   link under this rule's own root/non-root gate; only the ordering/live-value discipline
   is new, not the cases themselves).
5. Re-verify Track B shrunk matches kinship2 exactly using the ACTUAL implementation (not
   this session's by-hand recomputation) — target: `P1=0, M1=0.5, L3=1.0, P2=1.0,
   G3=1.5, C4=2.0, C4a=2.5, P6=3.0` (order/scale as originally recorded; this session's
   own relative-offset check above already confirms the shape is right).
6. Re-verify against the real 375-individual production fixture (not attempted this
   session — this project's own established discipline for any change to this
   function, and the fixture most likely to contain a 3+-link chain this session's
   2-fixture verification did not exercise).
7. Then RED/GREEN/REFACTOR.

---

## ITEM 4 CONFIRMED TO FAIL — session paused here, 2026-09-02, handed to a future session

**Corrected by "CHAIN RULE — RESOLVED" above (Session 665) — left unedited below as the
historical record of what S664 found, matching this file's own precedent for the
superseded Option 1. Do not re-read this section as current guidance; read the section
above first.**

**Do not re-attempt "Option 3 as specified above" without reading this section first.** It
is verified correct only for a qualifying pair with normal sibling width (Track B full). It
is verified WRONG for Track B **shrunk** — the fixture that started this entire
investigation — because `shrinkPedigree()` collapses `P1×P2`'s four children down to a
single surviving child, `M1`, and `M1` is simultaneously the anchor of her own nested
qualifying pair (`M1×G3`). This is exactly the "chain of 2+ nested qualifying pairs" case
item 4 above flagged as untested, found by actually testing it rather than assuming it
would generalize.

**Ground truth (`kinship2::align.pedigree()`) for Track B shrunk:**
`P1=0, M1=0.5, L3=1.0, P2=1.0, G3=1.5, C4=2.0, C4a=2.5, P6=3.0`.

**Applying Option 3's two cases independently ("root shifts to match children" /
"nested pair's children shift to match parents") to each qualifying pair separately
produces:** `P1=-1, C4=0, M1=0, P2=1, C4a=1, L3=1, P6=2, G3=2`.

`M1` is wrong (`0`, not kinship2's `0.5`) — proof the two-case rule does not fully solve a
single-child chain. kinship2's real joint solver resolves the whole `P1×P2 → M1 → M1×G3`
chain together and lands on a different, better-optimized value than treating the two
qualifying pairs as independent problems reaches. **Why the full fixture didn't show this:**
there, `P1×P2` has 4 children, giving `P1`'s position enough slack to decouple cleanly from
`M1`'s specifically — the chain-coupling only bites when an anchor's position is *entirely*
determined by a single child who is herself a nested anchor.

**Second, independent problem, found rendering the above to check it visually:** applying
the two per-pair corrections **independently, with no cross-pair awareness**, and writing
the result directly into the final position table (bypassing this project's own existing
collision-avoidance machinery — Track 7 Phase 2's push-search, `.deCollideIndividualPoints()`
— which normally runs *before* that point and would never see these post-hoc overrides) put
`P1×P2`'s union dot exactly on top of `C4`'s own position, and `C4×P6`'s union dot exactly
on top of `P2`'s own position — two completely unrelated families visually merging. Rendered
image: see this session's own transcript (`trackB-shrunk-NAIVE-rule.png`, not committed —
a throwaway diagnostic, not evidence of a real regression, since it was never run through
the real collision-avoidance pipeline at all). This reintroduces, in a new form, the exact
problem the original superseded plan
([`pedigree-diagram-disconnected-component-separation-plan.md`](pedigree-diagram-disconnected-component-separation-plan.md))
set out to fix — confirming that fixing union-midpoint placement and keeping disconnected
components visually separated are **not independent problems for this fixture**; a real fix
needs to address both together, not sequentially.

**What a future session needs to do, in order:**
1. Design a general rule for a chain of 2+ nested qualifying pairs sharing a single-child
   link — not yet attempted. Candidates not yet evaluated: resolving bottom-up (innermost
   nested pair first, propagating each result up the chain); an iterative relaxation:
   reading kinship2's own `alignped4.R` QP formulation directly (already read once this
   session's history, `pedigree-diagram-track7-phase3-child-centering-plan.md` §1.3) for
   how it actually weights/resolves a shared-child chain, rather than guessing.
2. Decide how this rule integrates with (not bypasses) the existing collision-avoidance
   machinery — the corrected raw targets must feed INTO
   `.deCollideIndividualPoints()`/Track 7 Phase 2's push-search, not override their output.
3. Re-verify Track B full is still bit-exact after any change to (1)/(2) — do not regress
   the one case already proven correct.
4. Re-verify Track B shrunk matches kinship2 exactly (the actual target: `P1=0, M1=0.5,
   L3=1.0, P2=1.0, G3=1.5, C4=2.0, C4a=2.5, P6=3.0`).
5. Only then proceed to items 1–3 of the original "not yet verified" list above (subtree-
   rigid translation, the real 375-individual fixture, B3/Phase-2 interaction) and RED.

**This is a genuinely bigger design problem than originally scoped** — discovered only by
insisting on checking the rule against a second real fixture and a rendered image, not by
assuming a mechanism verified on one case generalizes. Treat this as its own PRE-RED design
question for a future session, not a continuation of "Option 3 as ratified" — that
ratification covered only the case it was tested against.

---

**Supersedes:**
[`pedigree-diagram-disconnected-component-separation-plan.md`](pedigree-diagram-disconnected-component-separation-plan.md)
(same session, before implementation started — see that file's own superseded notice).

**Found:** 2026-09-01, Session 664, continuing the same owner-directed pedigree-fidelity
re-verification. The owner spotted, live, that `trackB-nprc-full.png`'s mating-union dots
sit on top of one parent instead of centered between the pair — a fixture this session had
already (wrongly) called "clean."

## Context

### Problem statement

`makePedigreeMatingLayout()` positions a mating pair asymmetrically: the "anchor" parent
(`.buildMatingUnitForest()`'s deterministic pick between the two, D2) is placed exactly at
the midpoint of their children, and the *other* parent ("B1" non-anchor mate) is placed a
fixed `minSep` (1 unit) away from the anchor — not at a matching, symmetric offset on the
opposite side. kinship2 (ground truth) places **both** parents symmetrically around the
true center, so the couple visually straddles the point their children descend from.

This was found as a cosmetic complaint (union dot off-center) but traces to the same
mechanism as two more serious symptoms, confirmed this session against kinship2's own
`kinship2::align.pedigree()` coordinates on the article's own committed Track B full
16-subject fixture (`data-raw/kinship2FidelityValidation.R`):

| Symptom | Example (Track B full) | Evidence |
|---|---|---|
| Union dot not at true parent midpoint | Every one of the 4 mating units in this fixture | See prior evidence table, this session's transcript |
| Children centered under the anchor alone, not the true pair midpoint | `M1`×`G3`→`L1,L2,L3`: nprc centers them at 3.0 (`M1`'s own x); kinship2 centers them at 3.5 (`M1`/`G3`'s true midpoint) — every descendant is shifted a consistent 0.5 left of kinship2's placement | Coordinate comparison, this session |
| Gross mispositioning via collision cascade, **in a fully connected pedigree, no disconnected families involved** | `P4` (`P3`×`P4`→`C4`) lands at x=7.0; kinship2 places it at 5.5 — a 1.5-unit miss | Same coordinate comparison |

The third symptom is the one the now-superseded plan mis-attributed to "disconnected
components." The real trigger: `P4`'s fixed "+1 from anchor `P3`" target (x=6.0) collides
with `P6` — `C4`'s own mate, independently computed via the identical "+1 from anchor `C4`"
formula, also landing on x=6.0, because `P3` and `C4` happen to be centered on the same
single-child descent chain (`P3`→`C4`→`C4a`, no siblings at any level). The generic
collision-bump (`.deCollideIndividualPoints()`) then shoves the loser an extra, disruptive
distance. This can happen in **any** long, narrow, single-child descent chain with a B1
mate at more than one generation — disconnected components are one way to produce such a
chain, but not the only way, and not the actual mechanism.

### Root cause, precisely

1. **Tier 1** (`.positionTreeApportion()`) places a real tree node (an anchor with real
   children) at the exact midpoint of those children's own final x. The non-anchor mate is
   never part of this recursion at all.
2. **Tier 3** (`b1AnchorRelativeX()`, `R/makePedigreeDiagramData.R:805-810`) places the
   non-anchor mate at `tier1X[[anchor]] + sign * minSep` — a fixed full-`minSep` offset
   from wherever the anchor ended up, with no reference to a shared, symmetric center.
3. Because the anchor sits at offset 0 from the children's center and the mate sits at a
   full `minSep` away, (a) the union dot (itself centered on the same children, per the
   existing "Track 6" rule) coincides with the anchor, never the pair's true center; (b)
   any node whose own position is later derived as "centered under this couple" inherits
   the anchor-only center, not the true pair center, silently drifting every deeper
   generation reachable through a B1-mated union; and (c) two independent B1 placements
   that happen to target the same slot (as in `P4`/`P6` above) trigger the generic
   collision-bump, which has no awareness that the resulting displacement is far larger
   than the symmetric placement kinship2 uses would have ever needed.

## Decision (options)

**Superseded — Option 1 below was ratified first, then found incomplete before any code was
written (see the status notice at the top of this file): it specified only the root-anchor
case and left the nested-qualifying-pair case (the on-anchor union position) unaddressed.
Left unedited as the historical record of what was tried first.**

### Option 3 — Conditional shift (RATIFIED, replaces Option 1)

For every qualifying union: shift whichever side is not pinned by an outside constraint so
the true parent midpoint and the children's mean become the same point again.
- Anchor is a root → shift both parents equally toward the (unchanged) children's mean.
- Anchor is not a root → shift the union's own children (whole subtree, rigidly) toward the
  (unchanged) true parent midpoint.

See the status notice at the top of this file for the full mechanism, the verification
already done (bit-exact against kinship2 on Track B full), and the 4 items the RED phase
still owes before this is more than "works on one hand-built fixture."

### Option 1 — Symmetric half-offset, keep the Tier 1 / Tier 3 split (SUPERSEDED — see above)

Change the anchor's own Tier 1 position, for any anchor with a qualifying B1 mate, to sit
`0.5 * minSep` off the raw children-midpoint (toward the side opposite the mate), and place
the mate at the mirrored `+0.5 * minSep` on the other side — so the two parents' own
midpoint is the union point, by construction, matching kinship2 exactly for the simple
case. Any node derived as "centered under this couple" downstream must be updated to use
that same true center, not the anchor's raw value, so the generation-propagation symptom
(item (b) above) is fixed at its source rather than patched per-callsite.

- **Pros:** Touches only the already-identified formula and its immediate consumers,
  not the tree-apportion recursion or the collision-search machinery. Directly halves the
  worst-case B1 collision distance (1 unit → 0.5 unit each direction), which may be enough
  to avoid the `P4`-style cascade in this fixture — must be verified, not assumed.
- **Cons:** Still fundamentally a "real tree node + bolted-on mate" architecture; a
  sufficiently adversarial fixture (multiple chained B1 mates at consecutive generations)
  could still produce a collision requiring the generic bump, just at a smaller magnitude.
  Requires auditing every place downstream that reads an anchor's Tier 1 x and assumes it
  is already the "couple center" (the children-of-children propagation found above) —
  scope of that audit not yet fully enumerated.

### Option 2 — Treat a mating pair as a compound "couple" node inside the tree apportion (broader, higher risk)

Modify the tree-apportion recursion itself so that an anchor with exactly one qualifying
B1 mate is represented as a 2-wide leaf-cluster occupying its own reserved span, laid out
by the *same* contour/collision machinery already proven correct for arbitrary subtree
widths (the existing "8-mate wide fan-out" test already exercises this machinery for a
different shape). The union point is the midpoint of the cluster's own 2 slots, which is
also the midpoint the couple's children attach beneath — one mechanism, no separate Tier 3
formula for this case at all.

- **Pros:** Architecturally the most correct fix — eliminates the split between Tier 1's
  robust, already-hardened collision handling and Tier 3's separate, weaker ad hoc
  formula, for this specific shape. Should generalize to chained/adversarial cases without
  a new bespoke fix each time one is found.
- **Cons:** Touches `.positionTreeApportion()`/`.buildForestChildrenOf()` — the most
  heavily-scarred code in this file (the old Reingold-Tilford/Walker implementation was
  already replaced outright by the current BJL engine, per this file's own header
  comments). Highest risk of an unintended regression on the real 375-individual
  production fixture referenced throughout this file's commit history. Larger change
  surface for RED/GREEN to cover.

**RATIFIED: Option 3** (owner-directed live, via direct visual review, Session 664,
2026-09-01/09-02 — supersedes the earlier Option 1 ratification, before any code was
written).

## Alternatives Considered

| Alternative | Pros | Cons |
|---|---|---|
| 1 — symmetric half-offset, keep tier split | Localized, smaller change surface | May not fully close chained/adversarial collision cases |
| 2 — compound couple node in tree apportion | Architecturally correct, likely generalizes | Touches the highest-risk code in the file |
| Keep current asymmetric formula, patch only the disconnected-family symptom (the now-superseded plan) | Smallest possible change | Confirmed insufficient — reproduces in a fully connected fixture too; already rejected this session |

## Impact Analysis

| Surface | Impact | Action Required |
|---|---|---|
| `R/makePedigreeDiagramData.R` | `b1AnchorRelativeX()` and/or `.positionTreeApportion()`/`.buildForestChildrenOf()`, depending on option chosen | New internal logic, `@noRd` |
| `tests/testthat/test_positionMatingUnitForest.R` | New assertions: union dot at true parent midpoint; children of a B1-involving union centered on true pair midpoint, not anchor alone; the `P3`/`P4`/`C4`/`P6`-shaped chain no longer produces a >0.5-unit miss vs. a direct kinship2 comparison | RED phase |
| `tests/testthat/test_makePedigreeMatingLayout.R` | End-to-end assertion using Track B full itself, compared numerically against `kinship2::align.pedigree()` (the exact method used to find this defect) rather than only structural edge-list comparison | RED phase |
| `data-raw/kinship2FidelityValidation.R` Track B images (full and shrunk) | Will change once fixed — regenerate and re-commit, send fresh images for confirmation before considering this closed | Same session as GREEN |
| The disconnected-component interleaving symptom (superseded plan) | Must be re-checked after this fix lands — may already be resolved, may need the superseded plan's Option C after all as a residual fix | Re-verify, do not assume either outcome |
| Real 375-individual production fixture | Must be re-verified — this is the highest-traffic real data this algorithm renders | Full clean regression + visual spot-check before close-out |

## Verification Plan

- Full clean regression (0 failed/0 error beyond the one pre-existing unrelated
  `test_wordlist_coverage.R` failure) and `lintr::lint_package()` (0 lints).
- Numeric comparison against `kinship2::align.pedigree()` coordinates — not just structural
  edge-list comparison — for Track B full and Track B shrunk, to the same precision used to
  find this defect. This is the verification method that actually caught the bug; a looser
  check would not prove the fix.
- Regenerate and send the actual images (this session's own established practice) for every
  affected fixture before calling any of them correct — no fixture gets marked done on this
  session's own visual impression alone.

## Scope boundary

**In scope:** the parent-placement asymmetry and its two downstream propagation effects
(union-dot centering, descendant-centering drift) described above.
**Out of scope:** whether the now-superseded disconnected-component symptom is fully
resolved by this fix or needs a residual follow-up — to be determined by re-verification
after this fix lands, not assumed either way; Track C's duplicate-node placement
(already investigated this session, found structurally valid); the live Shiny app demo
(still deferred, per the owner's own staged request).
