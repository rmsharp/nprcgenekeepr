# Pedigree-drawing spike: does the two-constant fix resolve (a)/(b) without cascading?

**Session:** S669 (2026-09-02). **Feeds:** `BACKLOG.md` Up Next item 1 (owner's A-vs-C
decision). **Status:** measurement only -- no production code changed, no decision made.

## Question

`docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-02.md` Recommendation 1: spike
"recentre every union on its mate midpoint; 1.0-unit spousal separation for every pair"
and re-run the census -- if (a)+(b) fall to ~24 with no other class rising, (A) bounded
per-defect fixes is three bounded changes from a clean production drawing; if it
cascades, that is evidence for (C) a joint solver.

## Method

`data-raw/pedigreeDrawingSpikeTwoConstantFix.R` (throwaway, no TDD gate -- owner-confirmed
via `AskUserQuestion`, matching S668's own audit-workstream precedent). A full copy of
`.positionMatingUnitForest()` (`R/makePedigreeDiagramData.R:759-1529`, as of commit
`b8ae2114`) with exactly 2 formula edits:

1. `derivedX()`'s non-qualifying branch: `minSep * 0.4` &rarr; `minSep` (full 1.0-unit
   spousal separation for every B1/duplicate mate, not just the 34/237 qualifying ones
   S666 already corrects).
2. A new final recenter pass, added after Tier 3 and every collision-avoidance/proximity
   pass (so both sides' FINAL drawn x are known): every unit's x becomes the mean of its
   two sides' final positions -- generalizing the qualifying-only recenter Track 7 Phase 1
   shipped and S652 reverted to **every** unit, matching the census's literal wording
   ("recentre EVERY union," not "every qualifying union").

`R/` is untouched (`git diff --stat -- R/` empty throughout). The spike engine reaches
`makePedigreeMatingLayout()`'s own internal call site via a temporary
`assignInNamespace()` swap, restored on exit of each pipeline run -- verified necessary
live: a first draft computed the spiked positions but still called the exported
`makePedigreeMatingLayout()` for the "direct" layout step, which internally re-derives
positions via the **shipped** engine regardless of any externally-computed `pos` --
producing a byte-identical before/after scoreboard despite nodes visibly moving
(`nMoved > 0`). Caught by checking `nMoved` against the class counts before trusting
either result, not by accepting a "no effect" run as itself the finding. Every number
below reproduced identically across 3 independent runs; lint 0.

## Results

BEFORE (shipped) &rarr; AFTER (spiked), summed across all 7 fixtures:

| Class | Before | After | Delta |
|---|---:|---:|---:|
| (a) overlapping symbols | 293 | 154 | -139 |
| (a) touching (boundary) | 0 | 0 | 0 |
| (b) union dot off mate midpoint | 171 | 61 | -110 |
| (c2) segment through a symbol disc | 414 | **1,425** | **+1,011** |
| (c) curved-chord heuristic | 1,743 | 1,849 | +106 |
| (d) duplicate vs its own real occurrence | 1 | 1 | 0 |
| (e) mate off its union's row | 56 | 56 | 0 |
| (f) family interleaving | 0 | 0 | 0 |

**(a)+(b): 464 &rarr; 215.** Not the ~24 the optimistic scenario named, but still a real,
substantial reduction (54%). **Per fixture:** Track B full/shrunk and D1-D3 show 0
movement and 0 change on every class -- expected, not a bug: those fixtures' anchored
units are already the `qualifies()`-gated kind S666 already corrects, so the new
universal recenter is idempotent on them (recentring an already-correctly-centred union
on the same final values changes nothing). Track C (9 individuals): a 5&rarr;1, b 3&rarr;2,
d unchanged at 1 -- a small fixture, small movement (5 nodes). **Real 375 carries the
whole effect:** a 288&rarr;153, b 168&rarr;59, but c2 414&rarr;1,425 (3.4x) and curved-chord
1,743&rarr;1,849.

**Net, excluding the curved-chord heuristic** (labelled in both this spike and the
census as unverified without rendering): before 293+171+414+1+56+0 = 935 hard-class
findings; after 154+61+1,425+1+56+0 = 1,697. **The fix increases total hard findings by
762** -- it trades roughly 250 (a)/(b) defects for over 1,000 new (c2) ones on the one
fixture large enough to show the effect.

## Interpretation against the census's own decision criteria

This is the "cascades" branch, not the "(a)+(b) fall to ~24 with nothing else rising"
branch. Widening every mate's spacing to a full `minSep` and recentring every union
measurably **worsens** the drawing on the real fixture when applied uniformly, even
though it demonstrably fixes what it targets. The literal two-constant change, taken at
face value across every unit rather than scoped narrowly, is not "three bounded changes
from a clean production drawing" -- it needs its own further correction pass (most
likely re-running collision/jog repair against the new wider spacing, which this spike
deliberately did not attempt, to keep the two edits isolated and their effect legible).

This does not by itself decide (A) vs (C). It rules out the cheapest version of (A) (ship
the two constants as-is) and demonstrates concretely why S646-S652's own history
narrowed the same change to `qualifies()`-gated units only: the broader version's
interactions are exactly the kind of cross-cutting cascade a bounded per-defect approach
struggles with, and exactly what a joint solver would handle by construction. A narrower
(A) attempt -- e.g., the same two edits gated to a wider-but-still-restricted class, with
a follow-on jog-repair pass against the new positions -- is untested by this spike and
remains a live option; this result is evidence about the *naive, ungated* version only.

## Caveats

- This spike generalizes "every union"/"every pair" literally, per the recommendation's
  own wording -- it does not search for a narrower gate that might avoid the cascade.
  A smarter (A) implementation might restrict the widen/recentre to a subset and do
  better than this measurement; that subset is not identified here.
- No re-run of jog/collision repair against the new wider spacing was attempted (out of
  scope for this spike, to keep the two edits' own effect isolated and legible). A real
  (A) implementation would include that pass, which could recover some of the c2
  regression -- or fail to, at real engineering cost either way.
- The curved-chord metric remains an unverified heuristic (per the census's own
  disclosure) and is reported for completeness, not weighted into the "935 vs 1,697"
  net-hard-findings comparison above.
- Track B/D1-D3 showing exactly 0 change is itself evidence the spike engine is wired
  correctly (idempotent where the existing correction already applies), not that those
  fixtures are informative about the cascade -- only Track C and the real 375 fixture
  exercise the changed code paths at all.

## Reproduce

```
Rscript data-raw/pedigreeDrawingSpikeTwoConstantFix.R
```

Findings: `docs/audits/PEDIGREE_DRAWING_SPIKE_TWO_CONSTANT_FIX_2026-09-02_findings.csv`
(3,602 rows, AFTER state only; the census's own
`PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-02_findings.csv` remains the BEFORE reference).
