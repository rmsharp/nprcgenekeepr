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

### Track 2 -- Flip the default `edgeStyle` to `"rectilinear"` (Claim 1) -- DONE S574

**DONE S574 (2026-08-14):** implemented exactly as scoped below, after Track 4 landed (S573) per
the sequencing note. `makePedigreeMatingLayout()`'s `edgeStyle` argument default reordered to
`c("rectilinear", "direct")`; `R/modPedigree.R`'s `.currentEdgeStyle()` NULL-input fallback
(what the radio's own `selected =` reads before any user interaction) flipped `"direct"` ->
`"rectilinear"` -- a 2-line source diff. Test blast radius: 1 helper fix
(`test_addRectilinearWaypoints.R`'s `.buildLayoutAndForest()`, which must still build direct-style
preconditions since it feeds the function that ADDS rectilinear waypoints), 8 blocks in
`test_makePedigreeMatingLayout.R` and 5 in `test_modPedigree.R` pinned to `edgeStyle = "direct"`
explicitly (they test direct-style-specific structural invariants that previously rode the
implicit default), 2 central "defaults to..." tests rewritten to assert the new default, plus 2
new assertions (a true-implicit-default 400-cap test, a true-implicit-default highlightNearest
degree:6 check) closing gaps the original scan missed. A 9th, previously-uncaught gap
(`test-e2e-pedigree-module.R`'s own trio-edge-structure test, pinned to `"direct"` explicitly) was
found only after re-installing the dev package into the `renv` library -- `shinytest2::AppDriver`
spawns a genuinely separate `Rscript` process that reads the *installed* package, not whatever
`pkgload::load_all()` shadows in the calling session, so the first full-regression pass had
silently exercised the E2E suite against the pre-flip installed code. Verified: full clean
regression 0 failed/0 error among true offenders (1 pre-existing unrelated
`test_wordlist_coverage.R` spelling failure only); `devtools::check()` 0 errors/0 warnings/1
pre-existing unrelated NOTE (`vignettes/figure/` knitr leftover); `lintr::lint_package()` 0 lints
on all 5 touched `.R` source files. All 6 named must-not-regress features live-verified against
the real bundled fixture, post-reinstall: click-to-navigate (#129) and shape-to-sex legend (#132)
via the corrected `test-e2e-pedigree-module.R` re-run; PNG export (#131) and the search/highlight
control (#135) confirmed present in the live full-page DOM; inbreeding-loop/consanguineous marking
(#134) confirmed live via JS DataSet query (56 marked edges, color `#D55E00`, width 4, on the real
fixture); the node cap (#138) confirmed both at the unit level (400/401 boundary, implicit default)
and live (radio pre-selection reads back `"rectilinear"` with zero interaction). Timed render of
the real/bundled 375-individual fixture (upload -> Diagram tab idle): 3.05 seconds -- no
regression, consistent with node counts having *dropped* since Track 4 (714/1202, not risen).
Documentation debt: `vignettes/a2interactive.Rmd` (routing-choice prose, the "Direct Edge Style"
code chunk explicitly pinned, a stale in-code comment, the "Rectilinear Edge Style" section's
stale default claim) and `vignettes/articles/colony-manager-guide.qmd` (the edge-style toggle
description, the now-style-dependent 750/400 node-cap claim) both updated. `NEWS.Rmd`/`NEWS.md`
and the `makePedigreeMatingLayout()` roxygen docstring (+ regenerated `man/`) updated. A 3rd
vignette, `vignettes/articles/pedigree-diagram.qmd`, also had stale default/cap claims corrected
(found during the doc pass, not named in this Track's original "documentation debt" note above).
REFACTOR phase skipped (owner-confirmed via `AskUserQuestion`, diff already minimal). See
`CHANGELOG.md`.

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

### Track 4 -- Anchor/founder generation-row alignment (Claim 4a) -- DONE S573 (design S572, implementation S573)

**DESIGN RATIFIED S572, IMPLEMENTED S573 (2026-08-14):** see
`docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` for both the ratified decision
and the full implementation record. Reframed the (a)/(b) choice below using issue #144's own
already-validated Candidate A/B/C characterization (not re-derived from scratch): (a) below
corresponds to the status quo (Candidate B, already shipped) optionally layered with Candidate
C's signposting; (b) below corresponds to Candidate A (gen-aware D2 anchor selection).
**Candidate A was ratified** via `AskUserQuestion` -- provably (not just empirically) closes the
row-mismatch defect class as a structural invariant, and as a direct consequence let `effGenOf`
(issue #144's own compensating mechanism) be deleted rather than layered further. **Implemented
S573:** `preferAnchor()` rewritten gen-first, the elimination/`used` shortcut and `effGenOf`/
anchor `dispGenOf` override removed -- a net-simplifying single commit (24 insertions / 69
deletions). Final measured cost on the real fixture: duplicate-node count 128->**102** (-20.3%,
the plan's own throwaway-script estimate of 103 was off by 1 as predicted), multi-anchor
individuals 2->**22** (max 5, `WCPXHD`, the plan's own estimate of 21 was likewise off by 1).
Rectilinear-style node count 1,228->**1,202**. Full clean regression, `devtools::check()` (0
errors/0 warnings/1 pre-existing unrelated NOTE), 0 lints, and a live `shinytest2` render (both
`edgeStyle` values, zero console errors, the existing 15-test/52-assertion live E2E suite
unchanged) all confirm the fix. Candidate C is not precluded -- remains available as a future,
separately-scoped enhancement (see the plan's own §5/§8).

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

### Track 5 -- Broaden rectilinear routing coverage (Claim 4b) -- RE-MEASURED S575, NO GAP FOUND

- **Scope:** Re-measure, after Tracks 3 and 4 land, how much diagonal-edge residue remains in
  `edgeStyle = "rectilinear"` mode. Track 4a's resolution in particular may eliminate most of the
  doglegs that currently motivate this; Track 3's spacing fix changes nothing about edge routing
  directly. If genuine gaps remain (e.g., a same-row direct edge that should still be routed
  through a waypoint for some other reason), scope a follow-up to `.addRectilinearWaypoints()`.
- **Effort:** unknown until re-measured -- do not scope further in this document (this project's
  own "report, don't estimate speculatively" precedent).
- **Session boundary:** explicitly deferred; re-open only after Tracks 3-4 land and a fresh
  side-by-side render is taken.

**RE-MEASURED S575 (2026-08-14) -- zero genuine diagonal-edge gap found; no follow-up needed.**
Owner scoped this session (via `AskUserQuestion`) to pure re-measurement: render the real fixture
live in `edgeStyle = "rectilinear"` mode, inventory any remaining diagonal/non-orthogonal edges,
and report -- stop rather than implement if genuine gaps are found. None were.

Measured three ways, all in exact agreement:

1. **Offline, the real bundled 375-individual fixture**
   (`obfuscated_rhesus_mhc_ped.csv`, via `makePedigreeMatingLayout(ped, edgeStyle =
   "rectilinear")` directly): of 1,315 edges, 1,265 are orthogonal (`from.x == to.x` or
   `from.y == to.y`) and 50 are not. **All 50 of the non-orthogonal edges are duplicate-individual
   dashed connector arcs** (`dashes == TRUE`, `smooth.enabled == TRUE`, `smooth.type ==
   "curvedCW"`) -- the Claim 4c connector, already confirmed present and intentionally curved, not
   a straight-line routing target of D1/D2 at all. Zero non-dashed diagonal edges. By comparison,
   `edgeStyle = "direct"` on the same fixture has 237 non-dashed diagonal edges (28.7% of its 827
   total) -- the routing problem rectilinear mode exists to solve, now fully closed on real data.
2. **Structural, not just empirical:** D1 (sibship-bar) waypoint-routes every `childEdges` entry
   unconditionally, so every child edge is orthogonal by construction. D2 (mate-line dogleg) keeps
   a mate edge direct only when the side's own gen already equals the mating unit's gen -- which
   means same row, hence automatically horizontal -- and otherwise replaces it with two new legs
   that are each, by construction, one pure-vertical and one pure-horizontal segment. Every mate
   edge is therefore orthogonal too, either directly or via the dogleg, for **any** pedigree shape,
   not only fixtures actually tested. Track 4's own landed invariant
   (`tests/testthat/test_makePedigreeMatingLayout.R:1131-1144`, `genOf[[anchor]] == unitGen`
   unconditionally) additionally makes the anchor-side D2 dogleg permanently unreachable --
   confirmed by re-running the exact synthetic fixture that originally demonstrated the "P1-to-A",
   "X-to-C1" diagonal-edge scenario in Claim 4b (`P1/P2/A/Y/X/W/C1/C2/GC`,
   `test_makePedigreeMatingLayout.R:1145-1191`): 23 of 24 edges orthogonal, the 1 exception again a
   `__dup_A_1 -> A` dashed connector arc, not a straight diagonal line.
3. **Live app, real fixture** (`shinytest2`/`chromote`, dev package reinstalled first to avoid the
   stale-install trap `PROJECT_LEARNINGS.md` flagged for S574): true implicit default (no
   `pedigreeEdgeStyle` input ever set) reads back `"rectilinear"`; a live JS query of the rendered
   `visNetwork` widget's own node/edge `DataSet`s reproduces the offline figures **exactly** --
   `{nNodes: 1202, nEdges: 1315, orth: 1265, diag: 50, diagDashed: 50, diagNonDashed: 0}` -- with
   zero diagram-related console errors. `visEdges(smooth = FALSE)` is the app's global default
   (`R/modPedigree.R:614`), so every non-dashed edge (no per-edge `smooth` override) renders as a
   literal straight segment between its exact coordinates; only the dup connectors carry their own
   `smooth.enabled = TRUE` override, confirming the geometric measurement matches what actually
   paints on screen, not just the underlying data.

**Conclusion (narrow, Track 5's own question only):** the plan's own contingency ("if genuine gaps
remain... scope a follow-up") does not trigger *for Track 5's specific question* -- Track 4a's
generation-row-alignment fix eliminated the dogleg-forcing scenario that motivated this track, and
D1/D2 already cover 100% of non-connector edges by construction. No `.addRectilinearWaypoints()`
change is warranted **for diagonal-edge routing specifically**.

**CORRECTION (S575, same session, caught by owner review of the published comparison artifact):**
this narrow conclusion does NOT mean the rectilinear diagram is now fully legible or that no
follow-up is needed overall -- that broader framing, stated in this session's original close-out,
was an overreach beyond what Track 5 actually measured. Reviewing the published comparison
artifact, the owner identified 2 real, previously-uncaught issues neither Track 5 nor any prior
Claim (1-4c) checked for. See §7 below for the full record. **Both are filed as new `BACKLOG.md`
items for a dedicated future session; neither is fixed here.**

### Track 6 -- Child-centered mating-unit position (§7b) -- DESIGN RATIFIED S576, IMPLEMENTATION PENDING

**DESIGN RATIFIED S576 (2026-08-14):** `docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md`
decides (Extended Candidate A, owner-ratified via `AskUserQuestion`): recompute a mating unit's
final `x` as the midpoint of its own children's final `x`-span (not the midpoint of its two
parents, today's formula) at `R/makePedigreeDiagramData.R:896-926`; recompute the duplicate
(non-anchor-parent) node's `x` from that new union `x` instead of the pre-sweep provisional
position; broaden the existing final de-collision pass to cover duplicate nodes, closing a side
effect the first change alone would introduce. Measured on the real 375-individual fixture:
violating child-edges (>200 scaled-unit horizontal offset) 100/251 -> 9/251 (91% reduction),
worst-case offset 10,687 -> 4,121 scaled units (61% reduction), duplicate-to-union distance
tightens from mean 62/max 120 to a constant 48. The 9 residual edges trace to a distinct,
out-of-scope phenomenon (sibling subtree-width asymmetry -- 2-3 direct children of one union whose
own descendant-subtree sizes differ enough that they land far apart in `x` regardless of the
union's position) -- flagged for its own future `BACKLOG.md` item at implementation close-out, not
folded into this decision's completion criteria. **Implementation is a separate future session**
(the design document's own §6 Migration Path / §7 Verification Plan), matching Track 4's own
design/implementation split (S572/S573).

## 5. Recommended pickup order

**Status as of S575 (2026-08-14): Tracks 1-5 are each resolved for their own originally-scoped
question** (1: S570, 2: S574, 3: S571, 4: S572/S573, 5: S575 -- diagonal-edge coverage
specifically). **This does NOT mean the plan's overall goal (kinship2 visual-fidelity parity) is
fully achieved** -- §7 below records 2 new findings surfaced the same session, after this status
line was first written, that remain open. This original recommended order (below) is left as
written -- historical planning narrative, not retroactively edited.

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

## 7. Post-close-out findings (S575) -- 2 new gaps, neither covered by Claims 1-4c or any Track

S575 originally closed this plan out as fully resolved after Track 5's own measurement. The owner
then reviewed the session's published comparison artifact directly and identified 2 real issues,
neither of which any prior Claim (1, 2, 3, 4a, 4b, 4c) or Track (1-5) checked for. Both are filed
as new `BACKLOG.md` items (Housekeeping) for a dedicated future session -- **not fixed here**, per
this project's "report, don't fix mid-session" precedent (`PROJECT_LEARNINGS.md` Learning 382), and
because the 2nd finding touches the core positioning algorithm (plan-mode / design-session
territory, not a same-session patch).

### 7a. Duplicate-connector arc curves the wrong way relative to kinship2 -- FIXED S577

Claim 4c (§2.4 above) verified the dashed duplicate-individual connector is *present*
(`dashes = TRUE, smooth.type = "curvedCW"`) but never checked *which way* it bows relative to
kinship2's own `arcconnect()` convention -- a gap in the original audit, not a regression. Owner's
direct visual comparison of the published artifact's screenshots: kinship2 draws this arc convex,
nprcgenekeepr draws it concave.

**Root-caused and fixed S577.** kinship2's own `arcconnect()` (a function nested in `plot.pedigree`)
always sorts its pair by x first (`tx <- sort(tx)`) before drawing, so its arc always bows toward
ancestors regardless of which occurrence is the duplicate. vis-network's `curvedCW` bow direction
(`Edge._getViaCoordinates` in the bundled `vis-network.min.js`) is a function of which endpoint is
`from` -- so the old always-`from = dupId, to = realId` convention bowed the wrong way whenever the
duplicate happened to land to the right of its real self. Measured on the real 375-individual
bundled fixture: 33 of 52 same-row connectors bowed the wrong way pre-fix; a naive blanket
`from`/`to` swap or `curvedCW`/`curvedCCW` swap would NOT have fixed this correctly (it is
position-dependent, not a uniform flip -- it would just invert which 33 vs. 19 were wrong). Fix:
x-order the pair (smaller-x endpoint becomes `from`) instead of a fixed dup/real assignment, mirroring
kinship2's own sort -- verified self-contained (`from`/`to`'s color/width are unconditionally NA for
this edge type, and no downstream `.addRectilinearWaypoints()` logic keys off a duplicate
connector's `from`/`to`, despite the caution above). Post-fix: 52/52 same-row connectors bow toward
ancestors, matching kinship2 exactly (visually confirmed via a live `visNetwork`/chromote render of
a same-row duplicate case). See `tests/testthat/test_makePedigreeMatingLayout.R` and
`R/makePedigreeDiagramData.R` (`dupEdges` construction, ~line 1342) for the implementation.

### 7b. Children are frequently rendered far from their own parent union -- a real, widespread legibility gap

Discovered investigating the owner's report that, in the published comparison artifact's
rectilinear image, the right-side unions' children were not positioned under their parents and were
hard to attribute, with horizontal runs crossing near other parents' children. Re-measured on the
**real 375-individual bundled fixture** (not just the small demo): of 251 child-edge groups, **100
(40%) have a parent-union-to-child horizontal offset exceeding 200 layout units, 73 (29%) exceed 500
units, and the maximum offset is 10,687 units.**

**Root cause**, read directly from `.positionMatingUnitForest()` (`R/makePedigreeDiagramData.R:584`
onward): a mating unit's *final displayed* x is computed as the midpoint of its two real parents'
positions (`finalUnitX <- (anchorX + nonAnchorX) / 2`, line 924) -- entirely decoupled from where
its own child was positioned during the earlier recursive descent. Track 3's minimum-spacing sweep
(`sweepMinSep()`, §Track 3 above) then runs independently **per generation row**. A highly-polygamous
individual crowds many nodes (himself plus every duplicate copy plus every mate) onto the *parent*
row, which needs substantial spreading to satisfy `minSep`; the *child* row, with proportionally
fewer nodes, needs much less. The two rows stretch at different rates, and the resulting union-vs-
child mismatch compounds across a fan-out -- confirmed on the small demo fixture (L31S6S, 6 mates)
where the offset grows roughly monotonically from -60 to -540 units across his 6 unions in x-order.

Every individual **edge** is still orthogonal (Track 5's own claim is unaffected) -- this is a
distinct failure mode: the routed right-angle path has to travel a long, visually-confusable
horizontal distance to reach a child that is not under its own parent, which is what produced the
"horizontal lines connecting progeny from different parents" the owner observed. Not investigated
further this session (no candidate fix evaluated, no correlation with `orderBySex` or sweep order
checked) -- flagged for a dedicated design session given the change surface (the core recursive
positioning algorithm, shared by every diagram render regardless of `edgeStyle`).

**Design session held S576 (2026-08-14):** see §4 Track 6 above and
`docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md` for the ratified
decision, measured trade-offs, and the explicit residual scope (a distinct, out-of-scope
sibling-subtree-width-asymmetry phenomenon affecting 9/251 edges, not resolved by this decision).
Implementation is a separate future session.
