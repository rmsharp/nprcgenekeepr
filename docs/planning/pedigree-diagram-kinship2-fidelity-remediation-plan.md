# Pedigree Diagram: closing the remaining kinship2 visual-fidelity gaps

**Status:** DRAFT plan. No implementation code in this session (SESSION_RUNNER.md Planning
Sessions: "the plan is the deliverable; do not start implementing it").
**Session:** S569, 2026-08-14. **Deliverable:** this document.

## 1. Origin

The owner directly compared nprcgenekeepr's Pedigree Diagram tab (`makePedigreeMatingLayout()`,
`R/makePedigreeDiagramData.R`) against kinship2's `plot.pedigree()` and, separately, against
`vignettes/articles/kinship2-fidelity-validation.qmd`'s own "Graphic fidelity" sections (Tracks
A-C), and named 4 observations:

1. kinship2's default rendering is rectilinear (right-angle connectors); nprcgenekeepr's is not.
2. Unaffected individuals are not filled (kinship2's baseline convention).
3. Mate spacing and node size: nprcgenekeepr often places two mates much closer together than
   kinship2 does, and kinship2's spacing reads as far more uniform.
4. In the fidelity-validation article's Track C "Graphic fidelity" section: (a) kinship2 places
   `X, A, Y, W, Y` on one generation row, nprcgenekeepr does not; (b) nprcgenekeepr does not use
   rectilinear connectors; (c) nprcgenekeepr does not use a dashed arc to connect a duplicated
   individual's two occurrences.

This document verifies each claim directly against source, the actual rendered images, and this
project's own prior design decisions (not from memory of what the code "should" do), then proposes
a phased remediation plan. Per `CLAUDE.md`'s Development Process Contract, this is a planning
session -- no RED/GREEN/REFACTOR phase applies; implementation is 1 or more separate sessions.

## 2. Evidence-based comparison

Verified by: reading `R/makePedigreeDiagramData.R` in full (1,662 lines); viewing the actual
`vignettes/articles/kinship2-fidelity-validation-img/trackB-*.png` and `trackC-*.png` files (not
just their alt text); reading `tests/testthat/test_makePedigreeMatingLayout.R:1046-1069`'s own
fixture and root-cause comment for Track C; reading `R/findGeneration.R` in full; and reading the
2 prior ratified design docs governing this code
(`docs/planning/pedigree-diagram-option2-layout-design-plan.md`,
`docs/planning/pedigree-diagram-rectilinear-waypoint-design-plan.md`).

### 2.1 Claim 1 -- default edge style (CONFIRMED, well-scoped fix)

`makePedigreeMatingLayout(ped, edgeStyle = c("direct", "rectilinear"), ...)`
(`R/makePedigreeDiagramData.R:1061-1062`) defaults to `"direct"` -- `match.arg()` picks the first
listed choice. `R/modPedigree.R:521-527`'s `radioButtons(... selected = style)` mirrors this same
default in the live app (labeled "Rectilinear (kinship2-style)" in the UI itself -- the project
already names kinship2 as the reference for that option). kinship2's `plot.pedigree()` has no
"direct" mode at all; every mate-line and parent-to-sibship-bar connector is right-angle,
unconditionally (`trackB-kinship2-full.png`, `trackC-kinship2.png`).

**A `"rectilinear"` option already exists and already ships** (issue #142, closed) -- this is a
default-value question, not a missing-feature question.

### 2.2 Claim 2 -- unaffected individuals not filled (CONFIRMED, well-scoped fix, distinct from a
### previously-fixed case)

`.affectedColor()` (`R/makePedigreeDiagramData.R:171-173`) already implements kinship2's "unfilled
if 0/NA" convention correctly -- **but only when `hasAffected` is `TRUE`**
(`makePedigreeDiagramData()` line 104-115, `makePedigreeMatingLayout()` line 1197-1199/1214-1216).
When the input pedigree has no `affected` column at all, `color.background` is never set on any
node, and vis.js falls back to its own default fill (solid light blue) for every individual --
confirmed directly against `trackC-nprc-direct.png`/`trackC-nprc-rectilinear.png` (every node solid
blue) and `trackB-nprc-full.png` (same).

**This is not the same gap `BACKLOG.md`'s S552→S554 fix already closed.** That fix
(`BACKLOG.md:419-427`) made `FALSE`/`NA` render unfilled *when the `affected` column is present*,
verified against `obfuscated_rhesus_mhc_ped_affected.csv` (a fixture that has the column). The
no-column case was never touched by that fix and is not mentioned in its own scope text.

**This is the common case, not an edge case:** `nprcgenekeepr::examplePedigree` -- the package's
own bundled/documented example pedigree -- has no `affected` column (verified live: `names()`
returns `id, sire, dam, sex, gen, birth, exit, age, ancestry, origin, status, recordStatus,
fromCenter`). Most uploaded studbooks are pedigree/genealogy records without phenotype data, so
this default is what most users see, not a rare corner case.

### 2.3 Claim 3 -- mate spacing / uniformity (CONFIRMED, already a documented open gap)

Measured directly from `trackB-kinship2-full.png` vs. `trackB-nprc-full.png` (same 16-subject
fixture, same "full" state): kinship2 spaces every adjacent mate pair almost identically
(P1-P2 gap ≈ P3-P4 gap, both ≈113-115px). nprcgenekeepr's direct-style rendering of the *same*
fixture spans P1-P2 by roughly 2x the P3-P4/M1-G3/C4-P6 gap, because
`.positionMatingUnitForest()`'s `mergeSubtrees()`/`minSep` contour-merge (`:681-701`) only
guarantees adjacent subtrees do not exactly overlap -- it reserves however much width a
mate's own descendant subtree needs, not a fixed minimum "comfortable" gap between the two
mates themselves.

**This is not a new finding -- it is an already-documented, unresolved "dragon":**
`docs/planning/pedigree-diagram-option2-layout-design-plan.md:486-495` ("New dragon found S461")
states this precisely: *"D3's contour-merge guarantees only 'no exact collision' ... not a
minimum visual spacing... A future session revisiting D3 would need a genuine minimum-separation
guarantee (not just non-collision) to close this gap."* That future session has not yet happened.

Node **size** was also checked: every real/duplicate node is `size = 25L` and every mating-unit dot
is `size = 6L`, unconditionally (`R/makePedigreeDiagramData.R:1195-1246`) -- nprcgenekeepr already
uses one uniform size per node class, matching kinship2's own uniform sizing in the compared
images. No sizing gap was found; the "size" observation is better explained by the spacing gap
above (tightly-packed nodes read as visually smaller/crowded relative to widely-spaced ones, even
at an identical pixel size).

### 2.4 Claim 4 -- Track C findings

#### 4a. Generation-row alignment (CONFIRMED, and this is the single most consequential finding)

Verified directly against `tests/testthat/test_makePedigreeMatingLayout.R:1075-1082`'s own fixture
(the exact one behind `trackC-*.png`): `A` and `Y` are full siblings (gen 1); `A` also anchors an
unrelated union with founder `X`. In the rendered image, `A` and `X` sit on a **lower** row than
`Y`, `W`, and duplicate-`Y` -- below even `GC` (A's own child). kinship2 places `X, A, Y, W, Y`
on one row (`trackC-kinship2.png`).

Root cause, read directly from `.positionMatingUnitForest()` (`R/makePedigreeDiagramData.R:742-754`,
the issue #144 fix): an anchor's own displayed generation is
`effGenOf[id] = max(genOf[id], unitGenOf[every unit id anchors])` -- **the deepest of every union
they anchor**, not their own natural generation. `A` anchors both `A×Y` (gen 1) and `A×X`; in the
test fixture `X` is hand-assigned `gen = 3` specifically to force this scenario for a different
bug's regression test (color-marker propagation onto dogleg edges, S563). `R/findGeneration.R`
confirms a *real* founder always gets `gen = 0` (line 46-54: `is.na(sire) | sire %in% parents`,
true immediately for a 0-parent id) -- so `X`'s exact `gen = 3` cannot occur from
`findGeneration()`'s own output. **But the general mechanism is realistic and common, not
fixture-specific:** `docs/planning/pedigree-diagram-rectilinear-waypoint-design-plan.md:79-94`
measured, against the real 375-individual bundled fixture, that **147 of 237 mating units (62%)**
have their anchor and non-anchor parents at *different* generations -- "an outside/founder animal
mating into an established line is an ordinary breeding-colony pattern, not a synthetic edge case."
Any anchor with 2+ mating units spanning a meaningfully different generation gap is pulled away
from its own siblings' row exactly as `A` is here.

**This is a known, already-flagged, explicitly deferred design question, not an overlooked bug:**
`docs/planning/pedigree-diagram-rectilinear-waypoint-design-plan.md:101-117` ("Explicit scope
boundary: the founder-positioning defect is a separate, unpicked item") describes this precisely
and states the two possible framings are unresolved. `BACKLOG.md`'s "Candidate C" item
(`BACKLOG.md:782-794`, found S473) proposes *signposting* the resulting dogleg as intentional
(dashed/colored/titled styling) rather than eliminating it, and explicitly states it "requires its
own fresh, explicit owner product-level sign-off to pursue." Issues #143/#144 (both closed) fixed a
*different*, narrower sub-case each (respectively: a free-pass individual's own display gen, and an
anchor's display gen formula itself) -- neither one revisited whether "pull the anchor to its
deepest union's row" is the right rule in the first place. That question is still open.

#### 4b. Rectilinear connectors "not used" (PARTIALLY CONFIRMED -- scope gap, not absence)

`edgeStyle = "rectilinear"` exists and, per `.addRectilinearWaypoints()`
(`R/makePedigreeDiagramData.R:1429` onward), inserts true right-angle waypoint routing for (D1)
sibship-bar chains and (D2) off-row mate-line "doglegs." Viewing `trackC-nprc-rectilinear.png`
confirms this: the `A`-to-union edge IS a right angle. But the Track C fixture has only 1 child per
union, so D1's sibship-bar mechanism never exercises there, and several other edges
(`P1`-to-`A`, `X`-to-`C1`, etc.) render as plain diagonal/straight 2-node edges because they are
not part of a dogleg or a multi-child sibship -- they simply are not the target of any waypoint
insertion. kinship2, by contrast, routes **every** connector orthogonally, unconditionally. This
matches `docs/planning/pedigree-diagram-rectilinear-waypoint-design-plan.md:12-16`'s own framing:
issue #142 shipped *sibship-bar and mate-line dogleg* waypoints specifically, not a
"every edge is right-angle, no exceptions" guarantee -- so today's `"rectilinear"` mode is real but
narrower in scope than kinship2's own convention. Claim 1 (default) and claim 4a (generation
alignment, which is what forces most of the doglegs this mode exists to handle) are the larger
drivers of the visual gap; once those are addressed, re-measure how much true diagonal-edge residue
remains before deciding whether broader waypoint coverage is still needed.

#### 4c. Dashed arc for duplicated individuals (REFUTED as "missing" -- confirmed present, but hard
#### to see)

`dupEdges` (`R/makePedigreeDiagramData.R:1305-1315`) unconditionally builds a
`dashes = TRUE, smooth.type = "curvedCW"` edge from every duplicate node to its real individual,
for every fixture with `nrow(duplicates) > 0` -- confirmed shipped and tested (`BACKLOG.md`: "found
S468, fixed S469"). Both `trackC-nprc-direct.png` and `trackC-nprc-rectilinear.png` show a short
dashed segment between the two `Y` occurrences. It reads as far less visible than kinship2's own
wide, prominent dashed arc (`trackC-kinship2.png`) for one direct, explainable reason: **the two
`Y` occurrences in nprcgenekeepr's rendering sit close together** (with `W` squeezed directly
between them) -- the same root cause as Claim 3's spacing gap, not a second, independent defect.
Fixing 2.3's minimum-separation gap should make this connector legible without any change of its
own.

## 3. What is already decided (do not re-litigate here)

- D1-D6 of the mating-unit-forest transformation and contour-merge positioning algorithm
  (`docs/planning/pedigree-diagram-option2-layout-design-plan.md`) are ratified and shipped;
  this plan does not propose replacing them.
- `edgeStyle = "direct"` as the *current* default was a deliberate, owner-verified S461 choice
  (`docs/planning/pedigree-diagram-rectilinear-waypoint-design-plan.md:19-33`, "§1.1 What is
  already decided") at the time -- not a placeholder left unset by accident. Track 2 below
  proposes revisiting it now that a validated `"rectilinear"` alternative ships and the owner has
  independently asked for kinship2 parity.
- Issue #142 (full rectilinear waypoint style) is closed for its own ratified scope (sibship-bar +
  mate-line dogleg). §4.4 below proposes only extending that scope, not reopening its existing
  behavior.
- The founder-positioning/anchor-row question (§2.4a) has already been flagged twice
  (S463's `.qmd` discovery, the rectilinear-waypoint design doc's §1.5) as needing its own decision
  session -- this plan is that decision session's prerequisite evidence-gathering, not a
  substitute for it.

## 4. Proposed remediation tracks

Each track is independently shippable and independently session-boundable -- picking one does not
require picking another first, except where noted.

### Track 1 -- Default unaffected fill to unfilled/white (Claim 2) -- DONE S570

**DONE S570 (2026-08-14):** implemented exactly as scoped below. Scope decision (mating-unit
dot nodes) resolved via `AskUserQuestion` before RED: stay `NA`, matching this section's own
recommendation. `makePedigreeDiagramData()`'s `affected` and `makePedigreeMatingLayout()`'s
`affectedOf` are now computed unconditionally (all-`NA` when the column is absent) so
`.affectedColor()`/`.affectedColorForVec()` return an explicit `#FFFFFF` for every real/duplicate
node regardless of column presence; the Affected-tooltip-line gate is unchanged (still absent
without the column). `.addRectilinearWaypoints()` needed no change -- it already preserves a
pre-existing `color.background` rather than resetting it. New/modified tests:
`test_makePedigreeDiagramData.R:266-282`, `test_makePedigreeMatingLayout.R:660-683,716-742`,
plus one pre-existing test (`test_makePedigreeMatingLayout.R:420-450`) whose column-set
assertion also encoded the old contract, caught by the full regression run, not the original
RED-phase scoping. Verified: both targeted test files green; full clean regression 0
failed/0 error; `lintr::lint_package()` 0 lints on the touched file; `devtools::check()` 0
errors/0 warnings/1 pre-existing unrelated NOTE (`vignettes/figure/` knitr leftover, not
introduced this session); a live `chromote` render of the bundled `examplePedigree` (7,306
nodes, no `affected` column) and a small 8-individual fixture both confirm every real/duplicate
node renders visually unfilled (white interior, colored outline), not vis.js's own default
solid fill. `NEWS.Rmd` entry added. See `CHANGELOG.md`.

- **Scope:** `makePedigreeDiagramData()` and `makePedigreeMatingLayout()` both currently gate
  `color.background` entirely behind `hasAffected`. Change so every real/duplicate node gets an
  explicit `color.background` (white/`#FFFFFF` by default, `.affectedColor()`'s existing TRUE/FALSE
  logic when `affected` is present) regardless of whether the `affected` column exists at all.
  Mating-unit dot nodes are a separate visual class (not an individual) -- decide explicitly
  whether they stay `NA` (inherit vis.js default) or also go transparent/white; recommend keeping
  them visually distinct (small, unlabeled, already not part of the affected-status convention).
- **Effort:** S. **Risk:** low -- additive default, no existing `hasAffected = TRUE` behavior
  changes.
- **Completion criteria:** a pedigree with no `affected` column renders every real/duplicate node
  with an explicit white fill (not vis.js's own default); existing `hasAffected = TRUE` fixtures'
  rendered colors are unchanged (regression-tested). New `test_that()` blocks in
  `test_makePedigreeDiagramData.R`/`test_makePedigreeMatingLayout.R` asserting
  `color.background == "#FFFFFF"` on a no-`affected`-column fixture.
- **Verification:** `devtools::test()` targeted files; full clean regression
  (`CLAUDE.md`'s documented command); a live `chromote`/`shinytest2` render of the bundled
  `examplePedigree` (no `affected` column) confirming visually unfilled nodes.
- **Does this need its own PRE-RED scope AskUserQuestion?** Only the mating-unit-dot question above
  (small, single-decision) -- otherwise straightforward enough to go directly into a normal
  RED→GREEN cycle once picked up.

### Track 2 -- Flip the default `edgeStyle` to `"rectilinear"` (Claim 1)

- **Scope:** Change `makePedigreeMatingLayout()`'s `edgeStyle` default and `R/modPedigree.R`'s
  `radioButtons(selected = ...)` default from `"direct"` to `"rectilinear"`. This is a *behavior*
  change for every existing caller who does not pass `edgeStyle` explicitly, not just an additive
  option.
- **Effort:** S implementation, but M overall once the "must not regress" list below is honored.
- **Risk:** medium -- visual-default change, documentation staleness risk.
  `docs/planning/pedigree-diagram-rectilinear-waypoint-design-plan.md:118-125` ("What must not
  regress") names 6 already-shipped Diagram-tab features that were verified for `"direct"` style
  and must be **re-verified for `"rectilinear"`** before it becomes the default everyone sees:
  click-to-navigate (#129), PNG export (#131), shape-to-sex legend (#132), hover-tooltip +
  search/highlight (#135), inbreeding-loop rendering (#134), and the 750-individual node cap
  (#138) -- plus a previously-measured "~37% rectilinear performance regression" (found+fixed
  during issue #144's design) should be re-confirmed still fixed at the current node cap, since it
  now runs for every user by default, not opt-in.
- **Documentation debt owed the same session** (per `CLAUDE.md`'s checklists): any screenshot or
  described default behavior in `vignettes/a2interactive.Rmd`'s Pedigree Diagram section and
  `vignettes/articles/colony-manager-guide.qmd` needs updating to match the new default.
- **Completion criteria:** default (no explicit `edgeStyle` argument, and no prior UI selection)
  renders `"rectilinear"`; all 6 named features pass live verification under the new default; a
  full clean regression + `devtools::check()` is clean.
- **Verification:** live `shinytest2` covering each of the 6 named features against the bundled
  example fixture; a timed render of the real/bundled largest fixture at the 750-node cap.
- **Sequencing note:** worth doing *after* Track 4 (spacing) and re-assessing Track 5's outcome,
  since both change how much of the diagram a rectilinear default actually improves vs. how much
  residual distortion (crowded mates, pulled-anchor doglegs) would now be the *default* view every
  user sees. Doing Track 2 first is not wrong, just makes the still-open gaps more visible sooner
  rather than later -- a legitimate, valid ordering choice for the owner to make explicitly.

### Track 3 -- Minimum mate-spacing guarantee (Claim 3, and indirectly 4c) -- DONE S571

**DONE S571 (2026-08-14):** implemented exactly as scoped below. PRE-RED mechanism decision
(post-merge global sweep vs. widening the contour-merge's own per-leaf reservation) resolved via
`AskUserQuestion` before RED: the post-merge sweep, since the widen-leaf-width alternative only
strengthens spacing between subtrees directly compared within the SAME `mergeSubtrees()` call and
does not reach the motivating dragon (2 unrelated free-pass/duplicate nodes nested at different
recursion depths, never inputs to the same merge call). `.positionMatingUnitForest()`
(`R/makePedigreeDiagramData.R:919-939` `sweepMinSep()`) now sweeps every real/duplicate individual
node at each display-gen row left-to-right, pushing any node closer than the existing `minSep`
(1 unit) to its left neighbor out to exactly `minSep`; applied once before `finalUnitX` (:934-939,
so a mating unit's own midpoint-of-parents position reflects the swept parent positions) and once
more at the very end of the function (:1043-1053), after the final de-collision pass and the
`orderBySex` swap -- a real interaction found live against the bundled 375-individual
`examplePedigree` fixture (not the small hand-built fixtures): the de-collision pass's own
epsilon-nudge, resolving an unrelated real/mating-unit-dot exact coincidence, could erode an
already-swept gap by 1e-3 unit. Fixed by re-sweeping last; 0 residual violations across the real
fixture's 5,334 same-gen gaps (was 28, all exactly 0.001 under `minSep`) after the fix.
`dispGenOf`'s computation was moved earlier in the function (a pure reordering, no logic change)
so the sweep can group by display gen. The `nonAnchorX` free-pass lookup in the `finalUnitX` loop
(`:941-975`) now reads the swept position for a real free-pass individual, falling back to the
pre-Track-3 `absX` lookup only for a dangling (no own row in `ped`) free-pass id, which has no
visible node and so is not a sweep input. New test:
`tests/testthat/test_positionMatingUnitForest.R:278-308` (general property: every same-gen
real/duplicate gap `>= minSep`, reusing the file's own real `GA204Z`/`8LKBV9` loop fixture,
empirically confirmed failing against unmodified source at gen 0/1/2, gaps 0.5/0.5/0.4/0.4/0.6).
One pre-existing exact-value pinned test (`:191-260`) recomputed against the fixed
implementation's own verified output -- every one of its 5 same-gen gaps in that fixture is now
exactly `minSep = 1` apart. Verified: targeted file green; full clean regression 1 pre-existing
failure/33 pre-existing warnings (byte-identical to a `git worktree`-checked committed-HEAD
baseline -- confirmed nothing new); `lintr::lint_package()` 0 lints; `devtools::check()` 0
errors/0 warnings/1 pre-existing unrelated NOTE (`vignettes/figure/` knitr leftover). Numeric
spacing-variance, computed before/after on the Track B (16-subject) and Track C (9-subject)
fixtures from `data-raw/kinship2FidelityValidation.R`: Track B min gap 0.5->1.0, variance
0.839->0.733; Track C min gap 0.5->1.0, variance 0.397->0.2. Live `chromote` re-renders of both
fixtures (scratch location, not the shipped article images) confirm visibly uniform spacing and
the Track C consanguineous marker/duplicate dashed connector both remain legible. `NEWS.Rmd` entry
added. REFACTOR phase skipped (owner-confirmed via `AskUserQuestion`, diff already minimal). See
`CHANGELOG.md`.

**Not done this session:** the shipped `vignettes/articles/kinship2-fidelity-validation.qmd`
article's own `trackB-nprc-*`/`trackC-nprc-*` screenshots are now stale (captured before this
fix) -- re-rendering and committing fresh article images was judged out of Track 3's own scope
(matching Track 1's own precedent of not touching any vignette article); a future session should
regenerate them via `data-raw/kinship2FidelityValidation.R` if the article is revisited.


- **Scope:** `docs/planning/pedigree-diagram-option2-layout-design-plan.md`'s own S461 dragon:
  replace `mergeSubtrees()`'s "just enough to avoid exact overlap" contour math with a genuine
  minimum-separation guarantee between adjacent mates/siblings, closer to kinship2's fixed-width
  convention. This is **not** a small tweak to `minSep`'s numeric value (already tried implicitly
  via `xScale`/`minSep` tuning per the existing code comments) -- it needs its own short design
  pass to decide the actual guarantee (e.g., "no two adjacent same-row nodes closer than N layout
  units, added as a post-merge pass" vs. "reserve a fixed minimum width per leaf in the
  contour-merge itself") and confirm it does not reintroduce the ancestor/nested-descendant
  exact-coincidence bug the existing de-collision pass (`R/makePedigreeDiagramData.R:918-936`)
  already fixes.
- **Effort:** M. Needs a short PRE-RED design decision (which guarantee mechanism) before RED.
- **Risk:** medium -- touches the shared positioning core (`.positionMatingUnitForest()`), which
  both `edgeStyle` values and the node cap depend on; re-verify the full existing
  `test_positionMatingUnitForest.R`/`test_buildMatingUnitForest.R` suites plus a re-measurement of
  total layout width at the real 375-individual fixture (a uniform minimum spacing could widen the
  overall diagram meaningfully -- confirm this does not silently regress the effective node-count
  ceiling's *visual* legibility even if the node *count* itself is unaffected).
- **Completion criteria:** the Track B/Track C fixtures, re-rendered, show mate/sibling spacing
  visibly closer to kinship2's own uniform spacing (a numeric before/after spacing-variance
  comparison, not just "looks better"); the duplicate-node dashed arc (4c) is visibly legible on
  the Track C fixture without any change to `dupEdges` itself.
- **Verification:** new `test_that()` asserting a minimum x-gap between every pair of nodes at the
  same `gen`; a live re-render of Track B/C's own fixtures compared pixel-metrically against the
  existing article images.

### Track 4 -- Anchor/founder generation-row alignment (Claim 4a) -- DESIGN RATIFIED S572, implementation not yet started

**DESIGN RATIFIED S572 (2026-08-14):** the dedicated design session this Track called for is done
-- see `docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md`. Reframed the (a)/(b)
choice below using issue #144's own already-validated Candidate A/B/C characterization (not
re-derived from scratch): (a) below corresponds to the status quo (Candidate B, already shipped)
optionally layered with Candidate C's signposting; (b) below corresponds to Candidate A
(gen-aware D2 anchor selection). **Candidate A was ratified** via `AskUserQuestion` -- provably
(not just empirically) closes the row-mismatch defect class as a structural invariant, and as a
direct consequence lets `effGenOf` (issue #144's own compensating mechanism) be deleted rather
than layered further. Cost, disclosed and accepted: duplicate-node count -20% (128->103),
multi-anchor individuals 2->21 (up to 5-way) on the real fixture. Candidate C is not precluded --
remains available as a future, separately-scoped enhancement (see the plan's own §5/§8). **The
implementation itself is unstarted** -- this Track's own "L (design) + L (implementation)"
estimate carries forward unchanged for the remaining implementation session(s).

- **Scope (original framing, superseded by the ratified plan's own §2 above):** This is the
  architecturally significant item. It requires a **dedicated design
  session** (its own `AskUserQuestion`-gated PRE-RED scope decision, per `CLAUDE.md`'s Development
  Process Contract and this project's own established precedent for exactly this kind of choice --
  see §3) before any RED/GREEN work, because 2 genuinely different, defensible target designs
  exist and this project has never picked between them:
  - **(a) Keep the current "anchor tracks its deepest union" rule**, and adopt `BACKLOG.md`'s
    already-designed "Candidate C" signposting (dashed/colored/titled cross-generation dogleg
    styling, already validated including its own ~37% perf-regression fix) so the divergence reads
    as intentional rather than a rendering defect.
  - **(b) Change the rule so an individual's displayed row is always their own natural `gen`**
    (matching kinship2's own apparent convention in `trackC-kinship2.png`), and let a
    far-off-generation mate be duplicated onto the anchor's row instead (or vice versa) -- closer
    visual parity with kinship2, but a more invasive change to `.positionMatingUnitForest()`'s D3
    step 6 correction (issues #143/#144's own code) and to the anchor-selection rule (D2) that
    decides which of 2 real parents even becomes "the anchor" in the first place.
- **Effort:** L (design) + L (implementation), likely 2+ further sessions beyond this plan.
- **Risk:** high -- D2/D3 are shared foundation for both edge styles, the node-duplication model,
  and the 750-node cap; per this project's own Vertical Slice gates, this cannot be folded into a
  slice with Tracks 1-3 (different capability, its own pre-declared contract needed).
- **This track blocks nothing above.** Tracks 1-3 do not depend on how this question is resolved.
- **Completion criteria (for the *design* session, not this one):** a ratified decision between (a)
  and (b) (or a third option the design session surfaces), written as its own
  `docs/planning/*-plan.md`, following this document's own evidence in §2.4a as its starting
  inventory rather than re-deriving it from scratch.

### Track 5 -- Broaden rectilinear routing coverage (Claim 4b) -- reassess after Tracks 3-4

- **Scope:** Re-measure, after Tracks 3 and 4 land, how much diagonal-edge residue remains in
  `edgeStyle = "rectilinear"` mode. Track 4a's resolution in particular may eliminate most of the
  doglegs that currently motivate this; Track 3's spacing fix changes nothing about edge routing
  directly. If genuine gaps remain (e.g., a same-row direct edge that should still be routed
  through a waypoint for some other reason), scope a follow-up to `.addRectilinearWaypoints()`.
- **Effort:** unknown until re-measured -- do not scope further in this document (this project's
  own "report, don't estimate speculatively" precedent).
- **Session boundary:** explicitly deferred; re-open only after Tracks 3-4 land and a fresh
  side-by-side render is taken.

## 5. Recommended pickup order

1. **Track 1** (unaffected fill) -- smallest, lowest-risk, highest-visibility win; no dependency on
   anything else.
2. **Track 3** (minimum mate spacing) -- second-lowest risk of the remaining items, and its
   completion is a prerequisite for judging Track 2's default-flip fairly (a rectilinear default
   over a still-crowded layout undersells the change).
3. **Track 4's design session** (anchor/generation-row decision) -- the long-pole item; start it
   early since it is 2+ sessions on its own and gates how much residual work Track 5 turns out to
   need. Does not block 1-3.
4. **Track 2** (flip default to rectilinear) -- once spacing (3) is fixed and the generation-row
   question (4) is at least decided (implementation of 4 need not be complete first, but knowing
   the target design avoids re-verifying Track 2's "must not regress" list twice against two
   different underlying layouts).
5. **Track 5** (broaden rectilinear coverage) -- reassess scope after 3-4 land; may turn out to be
   small or unnecessary.

This order is a recommendation, not a requirement -- each track's own "Session boundary"/"Does this
block" notes above are what actually constrain sequencing; the owner may pick any track first via
this project's standard priorities-list `AskUserQuestion` at a future session's Phase 0.

## 6. What this plan does not do

No `R/` or `tests/` file was modified in this session. No `AskUserQuestion` phase-gate was crossed
(no RED phase was entered). The next session that picks up Track 1, 2, or 3 begins its own
PRE-RED→RED→GREEN cycle per `CLAUDE.md`'s Development Process Contract; the next session that picks
up Track 4 begins its own dedicated design session first.
