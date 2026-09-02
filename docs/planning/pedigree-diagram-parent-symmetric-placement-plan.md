# Pedigree Diagram: Symmetric Parent Placement Plan

**Status:** Fix approach RATIFIED (owner-directed via `AskUserQuestion`, Session 664,
2026-09-01): **Option 1 — symmetric half-offset, keep the Tier 1 / Tier 3 split.**
Implementation (RED/GREEN/REFACTOR) not yet started.

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

## Decision (options — not yet ratified)

### Option 1 — Symmetric half-offset, keep the Tier 1 / Tier 3 split (narrower, lower risk)

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

**RATIFIED: Option 1** (owner-directed via `AskUserQuestion`, Session 664, 2026-09-01).

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
