# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature
inventory & future plans → `ROADMAP.md`. (Methodology file model — see
`SESSION_RUNNER.md` Phase 0.)*

> **STANDING TOP PRIORITY (owner-directed, 2026-08-26, S643):**
> pedigree-drawing fidelity work stays at the top of this list, ahead of
> every other item below, until the owner explicitly says it’s done.
> This overrides the normal “pick whatever’s READY” Phase 0
> priorities-list convention for as long as this note stands — a future
> session’s Phase 0 report should surface pedigree-drawing work first
> regardless of other items’ tags, and should not remove this note
> without an explicit owner sign-off that the work is complete.

## Up Next

**[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
erroneously renders fully-isolated individuals (no sire, no dam, no
mate, no children) – reverses this project’s own prior “acceptable
difference” framing** (found live 2026-08-26, owner-directed via direct
visual review of `kinship2-fidelity-validation.qmd`’s Track B full
fixture. Design RATIFIED S643. **Phase 1 (core renderer fix) DONE S644
(2026-08-27), Effort M – commit `fc5ac928`. Phase 2 (test/article
correction) DONE S645 (2026-08-27), Effort M. Phase 3 (Shiny UX
messaging) DONE S650 (2026-08-29), Effort M – commits
`61e885d0`/`6336dabd`. All 3 phases shipped.**
`output$pedigreeDiagramUI` (`R/modPedigree.R`) now reads
`diagramLayout()$isolatedIds` and shows an `alert-info` banner naming
suppressed individuals (partial suppression) or an `alert-info`
empty-state message (singular/plural worked copy, plan §3 Dragon 4) in
place of the widget (suppression empties the diagram entirely).
Confirmed live via
[`shinytest2:: AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html)
(Phase 3E), including the Focal-Animal-trim-to-one-isolated-individual
scenario (plan §1.2’s 2nd trigger). Full clean regression 0 failed/0
error attributable (1 pre-existing unrelated `test_wordlist_coverage.R`
failure only); `lintr::lint_package()` 0 lints. 1 bug found in GREEN (3
pre-existing node-cap-boundary tests used all-founder fixtures that
Phase 1’s own isolation suppression made entirely isolated – fixed
minimally, see `CHANGELOG.md`) and 1 bug found in Phase 3E (the new e2e
fixture’s own `write.csv(na = "")` round-tripped a missing sire/dam as
`""`, which
[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
rejects as “both a sire and a dam” – unrelated to this item’s own code,
see `CHANGELOG.md`). `master`’s CI red
(`R-CMD-check.yaml`/`test-coverage.yaml`) was the DIRECT, PREDICTED
consequence of shipping Phase 1 alone (owner-confirmed via
`AskUserQuestion`, S644, to leave it red rather than stopgap) – **now
resolved by Phase 2**: the 2 `test_comparePedigreeStructure.R` Track B
blocks (plus a 3rd block, a synthetic “ISO” fixture test, found this
session – see below) updated to assert the correct, already-shipped
behavior; full clean regression 0 failed/0 error attributable, confined
to the 1 pre-existing unrelated `test_wordlist_coverage.R` failure.
`lint.yaml` is still separately red – see the already-tracked
Housekeeping item below (`data-raw/kinship2FidelityValidation.R:339`),
unrelated to this item. – `P5` in the article’s own published Track B
16-subject fixture has zero edges of any kind (no parents, no mate, no
children); kinship2’s own `plot.pedigree()` correctly omits it from the
drawing (confirmed live: `align.pedigree()`’s own `$nid` placement never
places it), while
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
used to render it as a disconnected node. **The owner has explicitly
ruled this an error** (“P5… is erroneously included”), overriding S641’s
own `kinship2-fidelity-validation.qmd` Verdict text, which called this
“the more useful default, not a bug to reconcile away.” **Full design
plan (ratified via `AskUserQuestion`, both judgment calls decided):**
[`docs/planning/pedigree-diagram-isolated-individual-suppression-plan.md`](https://github.com/rmsharp/nprcgenekeepr/docs/planning/pedigree-diagram-isolated-individual-suppression-plan.md).
Entangled with issue \#164
([`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
crashed outright on an all-isolated pedigree) – **RESOLVED by Phase 1,
issue \#164 closed S644** citing commit `fc5ac928`. The second, narrower
trigger this session’s research newly found (a user focal-trimming to
one isolated individual via the Focal Animals box hits the identical
“100% isolated” case) is also resolved by Phase 1’s same fix (both paths
flow through
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)).
**Ratified decisions (all shipped in Phase 1 except Shiny messaging,
still Phase 3):** isolation predicate (sire/dam/never-a-parent,
excluding `twinRelations`-connected ids – matches `P5`’s exact profile)
– new `.findIsolatedIds()` primitive, pre-filters `ped` at the top of
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md);
when suppression would empty the diagram, the function now returns a
fully-typed empty result + `isolatedIds` instead of crashing (3B).
**Phase 2 (S645, 2026-08-27) – DONE:**
`tests/testthat/test_comparePedigreeStructure.R`’s 2 Track B blocks
(§2.4) updated to assert `identical = TRUE`/both `individualsOnlyInA`,
`individualsOnlyInB` empty (Block A) and `expect_null()` on
`.formatStructuralDiscrepancy()`’s report (Block B), plus stale
doc-comment prose reworded. **A 3rd break the plan’s own §2.4 inventory
did not name, found empirically this session:** a synthetic “ISO”
fixture test (`compareAgainstKinship2` on a hand-built 4-subject
`F1/M1/C1/ISO` pedigree) exercises the identical isolation predicate as
Track B’s `P5` and needed the same update – not a plan defect in the
sense of being wrong, just an inventory gap (the plan’s own grep-based
inventory covered `.pedTrackBFixture()` call sites, and this test builds
its fixture inline instead). 4 passages + 1 table row + 2 fig-alt
captions in `vignettes/articles/kinship2-fidelity-validation.qmd`
corrected (Verdict changed from “PASS, with one known and expected
difference” to plain “PASS”), and
`data-raw/kinship2FidelityValidation.R` re-run, regenerating only
`trackB-nprc-full.png` (confirmed via `git status` – every other image
byte-identical, confirmed unaffected) – visually confirmed 15 nodes (not
16), structurally matching kinship2’s own rendering. `quarto render`
clean; `lintr::lint_package()` 0 lints. **Incidentally found, NOT fixed
(out of this item’s scope – Track C, not Track B):** the article’s own
Track C table claims 3 marked (vermillion) edges for the `rectilinear`
edge style, but a live re-run of `data-raw/kinship2FidelityValidation.R`
prints 2, and the committed `trackC-nprc-rectilinear.png` is
byte-identical to what regenerating it produces (confirmed via
`git status` – unaffected by this session’s changes, so this is
pre-existing, not a regression from Phase 1/2). Unrelated to
P5-suppression; filed as a new Housekeeping item below. **Phase 3 (S650,
2026-08-29) – DONE:** see the item’s own top summary above.

**Mating-unit marker (dot) renders on the sire’s own symbol instead of
centered between sire and dam; mates are not visibly spread apart,
unlike kinship2** (found live 2026-08-27, owner-caught via direct visual
review of the corrected Track B full-fixture image pair (S645
post-close-out, commit `1784abf6`); root-caused by a dedicated
investigation S645 – **Design RATIFIED S646, 2026-08-27, Effort M. Phase
1 (individuals) DONE S647, 2026-08-27, commit pending – see below. Phase
2 (union-dot proximity) design RATIFIED S648, 2026-08-28, Effort M –
Option A (radius-proportionate capped push, union side only).
Implementation READY, TOP PRIORITY, next pickup (standing
pedigree-fidelity directive).** Full design:
[`docs/planning/pedigree-diagram-track7-mate-spacing-plan.md`](https://github.com/rmsharp/nprcgenekeepr/docs/planning/pedigree-diagram-track7-mate-spacing-plan.md)
(ARCHITECTURE_WORKSTREAM, matching this project’s own precedent for
pedigree-positioning decisions). **Ratified scope (owner-picked via
`AskUserQuestion`, “Ratify as scoped”):** for `qualifies()`-gated pairs
only (60/237 = 25.3% of anchored units on the real 375-individual
fixture, but 4/4 = 100% of what the owner actually observed in Track B)
– widen Tier 3’s `derivedX()` B1-branch offset from `minSep * 0.4` to
`minSep` (drop the multiplier entirely; doubly justified: this project’s
own existing adjacency-floor convention, AND kinship2’s own real,
directly-measured achieved spousal separation, which the design
session’s own adversarial verification found is exactly
`minSep`-equivalent, never the `1.414` an early draft mistakenly
computed from a misread penalty-weight parameter), and recenter the
qualifying union’s `x` at the true anchor/mate midpoint. Broader
(drop-the-gate) and kinship2-QP-porting alternatives were considered and
explicitly deferred/rejected – see the plan’s own §4/§8. kinship2’s own
`align.pedigree()` spreads each mated pair apart and drops the descent
line to their children from the midpoint between the two symbols;
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
draws each pair close together with the mating-unit `__union_` node’s
own x essentially coincident with the sire’s (the anchor’s) x.
**Empirically confirmed across every mated pair in the Track B full
fixture** (P1×P2, P3×P4, C4×P6, M1×G3 all show the identical pattern):
the union’s x lands within 0.001 raw units (a deterministic de-collision
epsilon) of the anchor’s own x, and the non-anchor mate sits only
`minSep * 0.4` raw units away (48 scaled units, vs. node `size = 25`) –
a small, fixed, formula-driven offset, not a kinship2-comparable visual
gap. **Root cause, current code (Walker/BJL
`.positionMatingUnitForest()`, `R/makePedigreeDiagramData.R:627-851`,
post issue \#141/S620 cutover):** Tier 2
(`unitX[[u]] <- mean(tier1X[kids])`, `:757-760`) centers the union on
the SAME child span Tier 1’s BJL apportioning already centers the anchor
on – so anchor-x and union-x coincide by construction; Tier 3’s
`derivedX()` (`:792-801`) then places a “qualifying” free-pass mate only
`minSep * 0.4` raw units from the anchor, not at any comfortable-gap
target. **This is NOT a regression and NOT the same gap as prior tracks
that sound related** (do not cite them as “the fix that didn’t work” –
they addressed different things and are gone by construction): Track 3
(S571, `sweepMinSep()`/parent-span clamp) only ever guaranteed
no-exact-overlap among genuinely-recursively-positioned nodes, and its
own mechanism is explicitly deleted by the Walker/BJL rewrite
(`R/makePedigreeDiagramData.R:610-615` confirms “gone by construction”);
Track 6 (S578, “child-centered mating-unit position”) is about centering
the union among its OWN CHILDREN, not between its two parents – it
deliberately moved away from parent-centering, and its surviving formula
(Tier 2 above) is what actually produces the anchor/union x-coincidence.
Also distinct from 2 closed, unrelated issues:
[\#161](https://github.com/rmsharp/nprcgenekeepr/issues/161) (the dot’s
own visibility – “keep the dot,” S627, says nothing about position) and
[\#145](https://github.com/rmsharp/nprcgenekeepr/issues/145) (sire/dam
left-right ordering convention, not gap size or centering). Not
previously filed anywhere (BACKLOG.md or GitHub issues) as actionable
remediation – only documented as a vignette caveat until now
(`vignettes/articles/kinship2-fidelity-validation.qmd` §Graphic fidelity
/ §Caveats carried forward, S645). **S646’s design session resolved all
3 named judgment calls** (matching this project’s own established
practice for touching `.positionMatingUnitForest()` – Tracks 1-6 and the
Walker/BJL migration itself all went through dedicated planning): (a)
yes, genuinely center the union between its two parents’ `x` – but only
for `qualifies()`-gated pairs, not universally (a broader change
reintroduces Track 6’s own polygamous-anchor regression risk, see the
plan’s §2.4); (b) widen to `minSep` exactly, not an arbitrary constant
(§2.2); (c) the `qualifies()` gate itself is the answer – restricting
the change to it means no new interaction with BJL/de-collision/Track 5
D1-D2 to analyze, only a re-use of an already-safe existing boundary
(§2.4). **Phase 1 (S647, 2026-08-27) – DONE:** shipped §2’s core
formulas (widen B1 offset to `minSep`, recenter qualifying unions at the
true anchor/mate midpoint) via full TDD. Corrected the plan’s own §1.4
coverage figure from a naive 60/237 to the actually-gated 34/237
(`qualifies()` alone isn’t the real gate – the non-anchor member must
also be a genuine free-pass B1 individual; Track B unaffected, 4/4
either way). The collision-headroom live-render check §7 flagged found a
real gap (widening to `minSep` makes a mate land exactly on an unrelated
individual routinely, not rarely – 24 pairs on the real fixture) and
took 3 iterations to resolve without creating a worse problem elsewhere
(an uncapped fix caused 34 new D1 sibling-bar overlaps up to 540px) –
shipped a capped bidirectional search (`.kMaxIndividualPush = 2`) that
accepts a small, bounded residual (27 nodes still exact-tie, down from
24 pairs, disclosed) rather than an unbounded drift. Full detail, all 3
iterations and their measurements: plan §11. All touched test files’
pinned values re-measured live, never hand-derived; full clean
regression 0 failed/0 error (the 1 pre-existing
`test_wordlist_coverage.R` failure only); `lintr::lint_package()` 0
lints. Visual re-verification: Track B/C images regenerated and
inspected directly (not just re-rendered) – **correction (found by the
owner directly, post-close-out, reviewing the same regenerated image
this claim was based on): “confirmed correct” overstated it.**
Structurally correct (right people, right relationships, no overlaps)
but not free of cosmetic defects – see the 5th finding below, found
within minutes of this claim being written. **Phase 2 (union-dot
proximity) – design RATIFIED S648, 2026-08-28; implementation DONE S649,
2026-08-29 (commits `316b605f`/`e312774f`, capped bidirectional push,
`.kMaxUnionPush = 5L`). Full clean regression 0 failed/0 error
attributable (1 pre-existing unrelated `test_wordlist_coverage.R`
failure only); `lintr::lint_package()` 0 lints; visual re-verification
(Track B shrunk image regenerated, ground-truth-confirmed). A disclosed,
narrower residual (4 union-vs-duplicate proximity cases the fix cannot
see – new Housekeeping item above) and a +1 D1 bar-vs-bar residual
(5-\>6, `test_addRectilinearWaypoints.R`) are the only trade-offs.**
Found during Phase 1’s own visual re-verification (plan §11’s 4th
finding) – a mating-UNION dot (not an individual) can also land
immediately adjacent to an unrelated individual, the same root tension
surfacing in the one collision shape Phase 1 deliberately left alone
(§2.3’s “weaker guarantee for dots” posture). Deliberately NOT attempted
in Phase 1 (owner-directed, `AskUserQuestion`) – 3 compounding
iterations were already needed for the individual-circle case, each
surfacing a new problem elsewhere; a 4th in the same session risked
repeating that pattern blind. **S648’s Pre-RED measurement (plan §12.1),
independently re-verified by a 3-agent adversarial workflow (§12.8):**
on the real 375-individual fixture, 20/237 (8.4%) unions collide with an
unrelated node under current shipped code – vs. only 1/237 BEFORE Track
7 Phase 1, meaning Phase 1’s own widen-to-`minSep` change caused 19 of
the 20. Worst-case magnitude bounded to 30px (vs. Phase 1’s
individual-fix needing up to 660px), 15/20 at the pre-existing tie-break
epsilon floor, 5/20 in an 11.88-30px band. The Track B “shrunk” fixture
(the already-committed `trackB-nprc-shrunk.png`) is a WORSE case than
the single pair originally cited – correctly measured (matching
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
own isolation-filtering, a methodology correction found mid-session),
all 3/3 of its own mating unions collide post-Phase-1, vs. 0/3
pre-Track-7. **Ratified design (Option A, plan §12.2/§12.10):** a capped
bidirectional push sized to the actual union-dot/node radii (~31px, not
the flat `minSep` individuals use, which a preliminary simulation and
ground-truth rendering data both found displaces an unrelated individual
out of its own row on the shrunk Track B fixture – Option B, rejected).
Scoped to the union side only; `.deCollideIndividualPoints()` and
individuals/duplicates untouched. **Implementing session starts from
plan §12.6’s verification plan**, including its MANDATORY live-render D1
sibship-bar regression check (a moved union’s own `__drop_` waypoint
reshapes its bar span – confirmed by reading source, not assumed). **5th
finding (owner-caught, post-close-out, 2026-08-27), documented not
fixed:** recentering a qualifying union between its two parents
decouples its `x` from its own children’s positions, something the OLD
`mean(children)` formula guaranteed could never happen. On Track B:
`P3`x`P4`-\>`C4` and `C4`x`P6`-\>`C4a` (single-child unions) now need a
right-angle dogleg to reach their child, where the descent line was
always perfectly straight before Track 7; `M1`x`G3`-\>`L1`/`L2`/`L3`’s
drop point lands off-center on the sibship bar (`3.5` vs. the children’s
own mean, `3.0`). Confirmed directly against `trackB-kinship2-full.png`
(already committed): kinship2 shows straight drops and a centered bar
for the identical fixture, because its `alignped4()` solver positions
parents AND children jointly and can adjust either – this project’s
Walker/BJL engine positions children first, then derives a qualifying
union’s `x` from its already-fixed parents, and cannot reach back to
move the children. This is the SAME tension plan §3/§4 already
considered and rejected fixing via kinship2’s actual joint-optimization
mechanism (Alternative C, disproportionate) – this finding is further
evidence for that conclusion, not a new decision to make. See plan §11’s
5th finding for full detail. Not filed as a separate item – a future
session scoping Phase 2 (or a dedicated one after it) should read this
alongside the union-dot-proximity finding, since both stem from the same
local-vs-global positioning tension and a future fix attempt should
consider them together rather than in isolation.

**`R-CMD-check.yaml` CI is red on master, all 5 platforms** (found S636,
2026-08-26). **RESOLVED S637, 2026-08-26, per owner-directed “broader”
scope (a genuinely clean baseline, not just a green checkmark):** the
actual root cause was simpler than any of the 4 candidate fixes S636
listed – `kinship2` was never declared anywhere in `DESCRIPTION` at all
(confirmed via direct grep), despite 2 real, already-guarded
([`requireNamespace()`](https://rdrr.io/r/base/ns-load.html)/
`skip_if_not_installed()`) executable call sites. Adding `kinship2` to
`Suggests:` removed the “unstated dependencies in tests” WARNING
outright – no gate-loosening, no redesign, no reopening Track C’s “tests
call kinship2 live” decision (`PROJECT_LEARNINGS.md` Learning 667). Same
session also fixed a second, long-standing, previously-undiagnosed
issue: the `vignettes/figure` knitr-leftover NOTE (first documented
~S520, deferred as “pre-existing/ unrelated” across 80+ sessions) –
traced to a single dead, git-tracked PNG
(`plot-focal-age-sex-pyramid-1.png`, commit `c18b7fd6`) that nothing
actually reads (the same-named vignette chunk regenerates its own plot
live); `git rm` removed it. Both guarded by a new
`tests/testthat/test_r_cmd_check_clean_baseline.R`. **Live-verified on
real CI (matching this project’s own established bar for CI-workflow
fixes, e.g. S629):** pushed, then confirmed via direct per-platform
job-log inspection (not the abbreviated summary) – `macos-latest` and
`windows-latest` are a genuine `Status: OK` (0 errors/0 warnings/0
notes); the 3 `ubuntu-latest` legs (`release`/`oldrel-1`/`devel`) show
only the separate, already-flagged temp-detritus NOTE below, confirmed
reproducing on all 3 (previously seen on only 1). **Known,
previously-flagged consequence confirmed clean:** `check-r-package@v2`’s
`needs: check` installs `Suggests` packages, so `kinship2` is now
actually installed in CI – Track C’s 6
`skip_if_not_installed("kinship2")` live tests flipped from *skip* to
*actually run*, on all 5 platforms, for the first time ever, with 0
failures anywhere (grepped the full run log for `FAIL` – none). See
`PROJECT_LEARNINGS.md` Learning 670.

## Active

**Pedigree Diagram: consider hiding the mating-unit node marker to match
kinship2’s plain-intersection convention** (found live in conversation
2026-08-15, filed as [issue
\#161](https://github.com/rmsharp/nprcgenekeepr/issues/161)) —
**addressed S592: recommend deferring** until the same-row
collision-avoidance work (Tracks 1-3, S593/S595/ S596) shipped and
stabilized (plan §2.5). **Unblocked S625** (both deferral conditions
satisfied). **RESOLVED S627 (2026-08-23): owner decision, via
`AskUserQuestion` with visual evidence in hand — keep the dot (status
quo), no code change.** Read both
`vignettes/articles/shiny_app_use/diagram_rectilinear_edge_style.png`
(nprcgenekeepr’s own current rendering: a small blue dot at every mating
junction) and
`vignettes/articles/kinship2-fidelity-validation-img/trackC-kinship2.png`
(kinship2’s actual output: mate-line and sibship-drop meet as a plain,
marker-free right-angle intersection) to confirm the issue’s own framing
before presenting the decision. Also found a functional cost the issue
didn’t name: the `__union_N` node’s
`title = sprintf("%d offspring", ...)` hover tooltip
(`R/makePedigreeDiagramData.R:1067`) would be silently lost by the
established `size = 0` + transparent-color invisible-node technique —
confirmed by checking the D1/D2 waypoint nodes’ own construction
(`title = NA_character_`, since a zero-size vis.js node isn’t
hoverable). Presented via `AskUserQuestion` (4 options: keep / hide
everywhere / hide in “direct” style only / hold for a live comparison)
with both images and the tooltip finding; owner picked “keep the dot.”
Closed as [issue
\#161](https://github.com/rmsharp/nprcgenekeepr/issues/161) (decision
reached, not deferred). See `CHANGELOG.md`.

## Architecture follow-ups (from TECH_DEBT_AUDIT_2026-05-30.md, re-verified 2026-07-11)

*Resolves the former “Tracker reconciliation” decision item (S365) –
`docs/audits/XARCH_TRACKER_RECONCILIATION_AUDIT_2026-07-11.md`
re-verified all 8 XARCH-1..8 findings against current source rather than
trusting the six-week-old audit text. XARCH-1/3/7 are fully RESOLVED (no
further tracking). XARCH-2 (implicit/ inconsistent module contract) and
XARCH-5 (string-column-keyed pipeline, no validated seam) are STILL OPEN
and owner-directed to GitHub issues \#122 and \#123 respectively – track
them there, not here. XARCH-4 (sex-code literal centralization) is now
also fully RESOLVED – S367 (2026-07-12): see `CHANGELOG.md`. XARCH-6
([`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)/`modInput.R`
multi-call redundancy) is now also fully RESOLVED – S368 (2026-07-12):
see `CHANGELOG.md`. XARCH-8’s narrower remaining gap is now also fully
RESOLVED – S369 (2026-07-12): see `CHANGELOG.md`. The
`man/filterPairs.Rd` staleness this recurring collateral regen left
behind (S367 origin, flagged S368/S369) is now also RESOLVED – S370
(2026-07-12): see `CHANGELOG.md`. No items remain in this section.*

## Up Next

**Act on the LabKey integration research recommendations** (BLOCKED –
remainder needs a live LabKey server to test/observe, Effort M) —
research pass DONE
(`docs/research/labkey-integration-options-2026-06-19.md`, S143).
\*\*Rec \#3 (explicit optional API-key auth with `.netrc` fallback +
clear error) DONE — S144,
[`setLabKeyDefaults()`](https://github.com/rmsharp/nprcgenekeepr/reference/setLabKeyDefaults.md).
Rec \#1 (`Rlabkey` version floor) DONE — S146, `Rlabkey (>= 3.2.0)` in
`DESCRIPTION` (all four EHR-module repos target LabKey 26.6; the live
ONPRC/SNPRC server version, doc §8.1, is still unobserved). See
`CHANGELOG.md`. Rec \#2 (config-ize the ONPRC defaults) DONE — S147:
centralized into the internal `defaultSiteParams()` (single source of
truth for
[`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)‘s
no-config fallback; no behavior change) + documented the center-specific
`lkPedColumns` form in the example config (flat `dam`/`sire` = SNPRC
direct columns; `Id/parents/dam` = ONPRC curated lookup). All three
quick wins (Rec \#1/#2/#3) DONE. **Rec \#4/#5 (formalize a data-source
adapter on the `getPedDirectRelatives` seam + a deterministic mocked
integration test) DONE (fetch-boundary slice) — S148: internal
`getPedigreeSource()` (`labkey` \| `dataframe`) now backs
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)’s
fetch with the walk byte-identical, plus the first deterministic walk
test.** Walk-unification DONE — S149:\*\*
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
now delegates its pedigree walk to
[`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md),
so the LabKey/EHR path returns the full connected pedigree component
(collaterals included), consistent with the in-memory function — a
deliberate, owner-accepted behavior change; the deterministic test now
asserts the full component incl. the previously-excluded collateral
sibling. **`file` provider DONE — S150:** `getPedigreeSource()` gained a
`"file"` source (params `fileName`/`sep`) that reads a pedigree file
(CSV or Excel) via the exported
[`getPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedigree.md),
alongside `"labkey"` and `"dataframe"`; offline-deterministic, validates
id/sire/dam, errors loudly like the `dataframe` branch. **`"file"`
provider WIRED to a first-class caller DONE — S151:** new exported
`getFileDirectRelatives(ids, fileName, sep, unrelatedParents)`, a
file-sourced sibling of
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
(reads via the `"file"` provider, then the source-agnostic
[`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)
walk). The clean symmetric family is now `getPedDirectRelatives`
(in-memory) / `getLkDirectRelatives` (LabKey) / `getFileDirectRelatives`
(file). **Option C — file pedigree source through the focal-animal app
pipeline DONE — S152:** new exported
`getFocalAnimalPedFromFile(fileName, pedigreeFileName, sep)`, a
file-sourced sibling of
[`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md)
(reads focal Ids from one file, builds the connected component from a
separate pedigree file via
[`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md);
fail-soft to a classed `nprcgenekeeprFileErr` whose `message` names WHY
the read failed — bad focal-id list file, a
missing/not-found/unreadable/ wrong-column pedigree file, or no focal
IDs matched — surfaced as the app’s “File Read Error” detail (richer
error messages added S155). `modInput` gained an optional pedigree-file
input on the focal-animals path and dispatches to the offline function
when supplied, else the unchanged LabKey path — so the Shiny
focal-animal workflow can now run offline with no LabKey/EHR connection.
(The focal-id read was factored into a shared internal
`readFocalAnimalIds()`.) **Still deferred:** a non-LabKey other-EHR
provider on the same seam; server-side filtering / `executeSql` /
consuming the centers’ `study.Pedigree`/`ehr.kinship` (research doc
explicitly defers until pull size is measured + per-center query
availability/permissions are confirmed; needs a live LabKey server to
test/observe, and a naive focal-id server filter is incompatible with
the client-side connected-component walk).

**Investigate factoring out the pedigree-diagram drawing functionality
into a separate R package that `nprcgenekeepr` depends on** (found
2026-08-19, owner-directed, READY, Effort M – a research/scoping
session, not an implementation session) – look into the possibility,
advantages, and disadvantages of splitting the pedigree-diagram
layout/rendering code
(`.buildMatingUnitForest()`/`.positionMatingUnitForest()`/`.addRectilinearWaypoints()`/
`.resolveEdgeNodeCollisions()`/[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
in `R/makePedigreeDiagramData.R`, plus the Shiny Diagram-tab module) out
of `nprcgenekeepr` into its own standalone package, with `nprcgenekeepr`
then depending on it. A future session should weigh this independent of,
and probably after, the Walker/BJL apportioning redesign
(`docs/planning/ pedigree-diagram-walker-bjl-apportioning-redesign-plan.md`,
issue \#141) currently in progress – splitting mid-redesign would add
package-boundary churn on top of an already-large in-flight algorithm
change. Not scoped further this session (out of Phase 1a’s own
boundary); a future session should produce the actual
advantages/disadvantages analysis (reuse potential outside this project,
cleaner dependency graph, and versioning/release overhead, cross-package
test/CI complexity, `@noRd`/internal-function visibility loss across a
package boundary, etc.) before any decision to split.

**Simplify `NEWS.Rmd` entries for a non-technical audience, reorganized
by feature not chronologically, with guardrails against recurrence**
(found 2026-08-20, owner-directed, READY, Effort L) – a prior session
(S538, 2026-08-12) already trimmed the `2.0.0.9000` dev-section once
(386-\>134 lines, 26 entries, rewritten from multi-sentence technical
paragraphs to the terse pre-1.0.8 house style; `PROJECT_LEARNINGS.md`
Learning 544), but that fix had no guardrail: 8 days and ~80 sessions
later the section has regrown to 315 lines / 57 entries, most written
back in the SAME verbose/technical style S538 removed. **RESOLVED S628
(2026-08-23/24):** all 3 owner-stated requirements met across a
multi-round `AskUserQuestion` draft/review/revise loop, per requirement
(1). (2) Reorganized the `2.0.0.9000` section’s 58 entries into 10
feature groups (Package, Pedigree Diagram, Kinship & Pedigree
Calculations, Marker Genetics, Cross-Center Identity Matching, Genetic
Value Analysis, Breeding Group Formation, Mate Pair Analysis,
De-Identified Export, General Fixes), taxonomy approved by owner before
any rewrite. (3) Landed the guardrail as an extension to `CLAUDE.md`‘s
existing “NEWS.Rmd entry checklist” (Session 448) with an explicit
plain-language/ no-jargon criterion – docs-only, no in-file note and no
automated lint (both considered and explicitly declined via owner
discussion: the in-file note had no distinct beneficiary once traced
through – every edit is session-mediated and every session already reads
`CLAUDE.md`; an automated banned-term lint would false-positive on
legitimate domain vocabulary this audience already knows,
e.g. “kinship”/“genotype”). **2 defect classes found and fixed beyond
the 3 stated requirements, both owner-caught then generalized
project-wide:** (a) *forward-reference ordering* – entries within a
group were not reliably in true shipping order, so a later refinement to
a feature could sit before that feature’s own introduction (most visibly
issue \#141’s positioning-engine entry, which actually shipped
2026-08-20/21, sitting first in Pedigree Diagram ahead of everything it
depended on); researched and corrected via an 8-agent background
workflow doing real `git log`/`CHANGELOG.md` archaeology per group (also
caught a real mis-attribution: the “anchor generation mismatch” fix was
S573, not issue \#144/S473-474 as initially assumed) and a genuine
naming collision (Marker Genetics’ “Cross-Center” sub-tab vs. the
separate “Cross-Center Identity” tab – fixed with a disambiguating
clause, not an invented rename, after confirming the real UI label in
`R/modMarkerGenetics.R`). (b) *delta-language for a reader-invisible
“before”* – entries describing a feature as
“gained”/“Fixed:”/“Changed:”/“rebuilt” relative to a prior state, when
that entire feature is itself new within this still-unreleased dev
section (nothing before `2.0.0`, the package’s only actual CRAN-accepted
version, establishes any reader-known baseline) – reworded to state
final shipped behavior directly wherever the enclosing tab is itself new
(Pedigree Diagram: 11 entries; Marker Genetics: 5; Cross-Center Identity
Matching: 1), left untouched wherever the delta is legitimate (a
pre-existing tab/function gaining something new – Kinship & Pedigree
Calculations, Genetic Value Analysis, Breeding Group Formation, General
Fixes,
[`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)’s
`linkedDateShift`, each confirmed pre-existing via
`NAMESPACE`/`git log`/`NEWS.md`, not assumed). Fidelity verified
mechanically after every pass, not eyeballed: entry count held at 58
throughout; all 24 distinct issue-number citations preserved (6 were
accidentally dropped mid-rewrite and caught by a diff sweep before
presenting).
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
(this file’s own build-equivalent) run clean after every substantive
edit; `NEWS.md` regenerated to match. See `CHANGELOG.md`. \##
Housekeeping

**S649’s Track 7 Phase 2 (union-dot proximity fix, commits
`316b605f`/`e312774f`) shipped with no `NEWS.Rmd` entry** (found
incidentally S650, 2026-08-29, while adding S650’s own Phase 3 NEWS.Rmd
entry to the same Pedigree Diagram group, READY, Effort S) – violates
`CLAUDE.md`’s NEWS.Rmd entry checklist (a user-facing Shiny behavior
change: mating-union dots now sit closer to their true midpoint instead
of drifting toward one parent). Not fixed here (out of this session’s
own scope – a different session’s gap). A future session should add one
plain-language bullet to the Pedigree Diagram group, in true shipping
order (after the Phase 1 individuals-side bullet, i.e. right before
S650’s own new Phase 3 bullet), then regenerate `NEWS.md`.

**`kinship2-fidelity-validation.qmd`’s Track C table claims 3 marked
(vermillion) edges for the `rectilinear` edge style; a live run reports
2** (found incidentally S645, 2026-08-27, while regenerating Track B
images for the P5-suppression Phase 2 item above, READY, Effort S) –
`Rscript data-raw/kinship2FidelityValidation.R` prints
`rectilinear-style marked edges: 2`, but the article’s own table (§Track
C) says
`3 (A's 1 edge splits into 2 dogleg segments; Y's 1 edge is unaffected)`.
Confirmed pre-existing, not a regression from this session’s Phase 1/2
work: `git status` after regenerating shows
`trackC-nprc-rectilinear.png` byte-identical to the already-committed
image (only `trackB-nprc-full.png` changed) – this discrepancy has been
true since at least commit `36653242` (S636, the last commit to touch
that image) and was not caused by anything this session touched
(`R/makePedigreeDiagramData.R` was not edited this session). Unrelated
to P5-suppression (Track C’s own 9-subject dogleg fixture has no
isolated individuals). Not investigated further or fixed this session
(out of scope) – a future session should determine whether the
doubled-dogleg-segment counting logic changed (e.g. during the S592-S621
same-row-collision/Walker-BJL rectilinear-routing work) or the article’s
own “3” claim was always wrong, then correct whichever side is stale.

**`lint.yaml` CI failed on S642’s own close-out push, not
self-resolved** (found live S643, 2026-08-26, via Phase 0’s mandatory
`gh run list` CI-status check, READY, Effort S) – run `33022564528`:
`[object_usage_linter] no visible global function definition for '.formatStructuralDiscrepancy'`
at `data-raw/kinship2FidelityValidation.R:339`, exit code 31
(`LINTR_ERROR_ON_LINT: true`). Contradicts S642’s own close-out claim of
“0 lints on all 3 touched files.” `.formatStructuralDiscrepancy()` lives
in `tests/testthat/helper-comparePedigreeStructure.R` (a `testthat`
helper, not `R/` source), so it is outside
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)‘s
scope the way `CLAUDE.md`’s Lint close-out checklist (Learning 224)
prescribes – most likely explanation (not yet confirmed): S642’s local
interactive session already had `.formatStructuralDiscrepancy` bound in
its global environment (from an earlier `test_dir()`/`test_file()` run
in the same session) when `lintr::lint_package()` ran, masking exactly
the gap CI’s clean environment exposed. Not fixed this session (S643’s
own deliverable was the pedigree-drawing design plan above, per the
standing top-priority directive) – a future session should either (a)
confirm the stale-globalenv hypothesis and add a `# nolint` with that
rationale if the call is structurally fine (a `testthat` helper calling
another `testthat` helper is legitimate, just invisible to a
package-only lint), or (b) restructure so the reporting logic lives
somewhere `lintr::lint_package()` can see unconditionally. No GitHub
issue filed, matching this project’s CI-break tracking convention
(`CLAUDE.md`). **Confirmed identical on a 3rd consecutive push (S644,
2026-08-27, commit `44c9a15e`, run `33033005502`) – same single finding,
same line, same message, verbatim.** This weakens the stale-globalenv
hypothesis (option (a) above): a genuinely stale local binding would be
expected to vary session-to-session or eventually clear, not reproduce
identically 3 times running across 2 different sessions’ own interactive
work. A future session should weight option (b) (restructure) more
heavily, or at minimum re-examine whether (a) is still plausible before
adding a `# nolint` on that rationale.

**`.addRectilinearWaypoints()`’s `__jog_*` waypoint nodes (the
straight-edge jog pass) render as a full-size, filled default vis.js
circle instead of invisible** (found live S648, 2026-08-28, while
building a visual comparison for the Track 7 Phase 2 design item below –
READY, Effort S) – `R/makePedigreeDiagramData.R:2081-2127` constructs
each `__jog_%d_a`/ `__jog_%d_b` node with only `id`/`x`/`y` set, then
`.matchColumns()` (`:2000-2011`) fills every other column (`shape`,
`size`, `color.background`, `color.border`) with `NA` rather than an
explicit invisible style. This is inconsistent with the D1/D2
`__drop_`/`__bar_` waypoint nodes added earlier in the SAME function,
which are explicitly styled invisible (`shape = "dot"`, `size = 0`,
`color.background/color.border = "rgba(0,0,0,0)"`, `:1821-1829`) – the
jog pass (added later, for perfectly-straight/overlapping edge cases)
never received the same treatment. With `shape`/`size` left `NA`, vis.js
falls back to its own default node appearance (a filled, full-size
circle) instead of rendering nothing. **Visually confirmed on the
ALREADY-COMMITTED `trackB-nprc-shrunk.png`**: `P1`’s own edge jog
waypoint (`__jog_2_a`) lands at `(x=0, y=13.5)`, 13.5 raw-scaled units
below `P1` itself (`x=0, y=0`) – close enough to visually overlap/fuse
with `P1`’s own square, reproduced identically using the project’s own
unmodified `screenshot_layout()` methodology (no custom rendering code
involved). Not a regression from anything this session touched, and
unrelated to Track 7’s own union-position mechanism – confirmed present
under BOTH pre-Track-7 and current source. Likely affects any pedigree
where a jog waypoint’s computed position happens to land near a real
node’s own position, not only this one fixture. Not fixed this session
(out of scope for Track 7 Phase 2’s own design deliverable) – a future
session should add the same explicit invisible styling (`shape = "dot"`,
`size = 0`, transparent `color.background`/`color.border`) to the
jog-node construction at `:2094-2097`, matching the D1/D2 precedent
exactly, then re-verify against the real 375-individual fixture and
Track B images for any other jog-waypoint-vs-node collisions this same
gap may have hidden elsewhere.

**Track 7 Phase 2’s own union-side proximity push (S649) introduces 4
NEW union-vs-DUPLICATE proximity cases on the real 375-individual
fixture that did not exist before** (found live S649, 2026-08-29,
implementing
`docs/planning/pedigree-diagram-track7-mate-spacing-plan.md` §12.2 –
READY, Effort M; count corrected from an initial pre-fix spike’s 11
after a second GREEN-phase correction, plan §12.11, made the push itself
more targeted) – root cause: a duplicate node’s `x` is always
`unitX[[itsOwnUnion]] + minSep*0.4` (`R/makePedigreeDiagramData.R:816`),
a fixed offset that rides along whenever a union moves; §12.2’s own
occupied-set (`tier1X`/`b1AtGen`/`placedAtGen`) has no visibility into
duplicate positions, which are not computed until AFTER the union sweep
runs (a genuine data dependency – a duplicate’s own `derivedX()` reads
the union’s FINAL `unitX`, so duplicates cannot be positioned first).
Owner-directed (`AskUserQuestion`, S649): ship Phase 2 as scoped rather
than widen it – the owner’s own directly-reviewed Track B fixture is
fully resolved either way (no duplicates in play there). Full detail:
plan §12.11. A future session should design a fix (likely: track each
already-placed unit’s own prospective duplicate offset, if it has one,
as an additional occupied-set member during the union sweep – bounded,
not the full symmetric individual-side hardening §12.4 Alternative D
already rejected) and re-verify against the real fixture (currently
11/237 union-vs-duplicate proximity cases) and Track B.

**`R-CMD-check-scheduled.yaml` (the weekly-cron twin of
`R-CMD-check.yaml`) never received the S616/S618/S619 chromote
Chrome-provisioning fix, and nothing guarded against the drift** (found
live S629, 2026-08-24, via Phase 0’s mandatory `gh run list` CI-status
check – **RESOLVED S629, same session.**) – the scheduled run’s
`ubuntu-latest (release)` leg failed with the exact pre-fix
ambient-Chrome-discovery signature (`chromote:::launch_chrome()` -\>
`startup()` -\> “Chrome debugging port not open after 10 seconds”,
inside `test_positionMatingUnitForest.R:1645`’s
`getLiveRenderedPositions()` call) – because
`tests/testthat/test_r_cmd_check_workflow_chrome_setup.R` guarded only
`R-CMD-check.yaml` by hardcoded path, `R-CMD-check-scheduled.yaml` was
free to drift indefinitely with no test catching it. Confirmed the flake
was real-but-intermittent (not a code regression) by re-running the
failed job unmodified (`gh run rerun --job`), which passed clean – same
diagnostic method as the original S616 finding of this exact failure
class on this exact platform. Fixed via full TDD: RED parametrized the
test file’s existing 4 `test_that()` blocks to loop over both workflow
files (confirmed failing only for the scheduled file, for the right
reason); GREEN ported the identical 3-step pattern (pinned
`browser-actions/setup-chrome@v2` + `CHROMOTE_CHROME` + a
[`chromote::find_chrome()`](https://rstudio.github.io/chromote/reference/find_chrome.html)
pre-flight assertion, same `if: != macos-latest` guard) into
`R-CMD-check-scheduled.yaml`. Verified: all 8 guard tests pass; full
clean regression 0 failed/0 error;
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) 0
errors (1 warning + 2 notes, all pre-existing/unrelated
untracked-artifact noise); `lintr::lint_package()` 0 lints;
**live-verified on real CI** (owner-directed, matching this project’s
own established bar for CI-workflow fixes) – pushed, then a manual
`workflow_dispatch` of `R-CMD-check-scheduled.yaml` confirmed all 5
matrix legs GREEN. A deeper DRY fix (a shared `workflow_call` reusable
workflow so the 2 files can’t drift apart structurally again) was
considered and declined at the pre-RED gate as bigger scope than this
session’s one-off fix – not filed as a follow-up item, per owner
direction. Not filed as a GitHub issue, matching the established
“found-and-fixed same session” precedent (Tracks A/B/C, S563-S565). See
`CHANGELOG.md`.

**(Optional, low priority) Root-cause why the pinned Chrome-for-Testing
binary hangs on `macos-latest`’s `ChromoteSession$new()` bootstrap**
(found S619, 2026-08-20, incidental to the chromote CDP-timeout fallback
fix below, READY, Effort M – research only, not required) – the
practical problem is FULLY resolved: `macos-latest` reverts to ambient/
unpinned Chrome (`R-CMD-check.yaml`,
`if: matrix.config.os != 'macos-latest'` on the 3 Chrome-provisioning
steps), verified green on real CI. What remains unexplained: raising
chromote’s `default_timeout` to 60s did NOT resolve the pinned binary’s
hang (same exact failure, wall time roughly doubled, confirming the
session is genuinely wedged, not merely slow) – direct source inspection
confirmed the timeout-governed call is `ChromoteSession$new()`’s own
internal `Runtime.evaluate("window.devicePixelRatio", ...)` bootstrap
probe (`private$get_pixel_ratio()`, chromote 0.5.1), but WHY that
specific probe never gets a response on the pinned macOS ARM64 binary
specifically (vs. the SAME pinned binary working fine on
ubuntu-latest/windows-latest, and vs. ambient Chrome working fine on
macos-latest) is unconfirmed. A research workflow found a plausible but
NOT Chromium- confirmed analog (Mozilla Bugzilla \#1893921 – Firefox’s
own content-process spawn hitting a 5s AppKit/IOKit sandbox-denial stall
specific to GitHub’s *virtualized* macOS ARM64 hosts, fixed by widening
Firefox’s own sandbox allowlist) but found no matching Chromium tracker
entry. Only worth pursuing if pinned-Chrome reproducibility on macOS
specifically becomes valuable later (e.g. `xattr -l` on the extracted
`.app` on a live failing runner to rule out/in Gatekeeper quarantine,
which the same research found NOT evidenced for
`browser-actions/setup-chrome`’s actual download/unzip pipeline; or
filing a new `rstudio/chromote` upstream issue, since no existing issue
there matches this exact macOS+GHA+live-CDP-timeout signature).

**Sweep the 16 accumulated `[x]`-checked DONE items out of
`BACKLOG.md`** (found S619, 2026-08-20, owner-directed via chat after
noticing stale DONE entries) – **DONE S625 (2026-08-23).** Direct
re-count at claim found **18** `[x]` items, not 16 (2 more had been
checked since S619: S607’s MIT/REUSE badges, and S624’s own
`CLAUDE.md`-filter item). Confirmed, not spot-checked, every one of the
18 items’ cited session numbers (S574-S624) has a substantive
`CHANGELOG.md` entry (grepped `CHANGELOG.md` +
`docs/archive/CHANGELOG*.md`; spot-verified the largest deletion, the
S592-S621 pedigree same-row-collision/Walker-BJL chain, resolves to real
dedicated `[issue #141]`-tagged entries, not just incidental mentions).
All 18 deleted outright, matching S548’s own verification-then-delete
method: `BACKLOG.md` 2,192 -\> ~1,170 lines net (~1,020 removed after
this close-out’s own additions below, ~47% reduction). **Found and fixed
one dangling internal cross-reference this deletion created:** the kept
issue \#161 item (“hiding the mating-unit node marker”) referenced
“Tracks 1-3 above” and “the follow-up item below” – both pointed at
now-deleted items – rewritten in place with an S625 update noting both
of S592’s named deferral conditions are now satisfied (Tracks 1-3
shipped S596; the Track 3 trade-offs fully resolved by the unrelated
Walker/BJL migration, issue \#141 closed S621), unblocking \#161 for an
owner decision. Verified: `[x]` count 0 (pre-close-out), `[ ]` count
unchanged at 36 (no open item accidentally caught in a deletion range),
every remaining `##` section header intact, no double-blank-line or
truncated-sentence artifacts at any of the 18 seams (spot-checked
directly, not assumed; a full-file re-read confirmed no other
artifacts). Also found and filed (not fixed) an incidental gap:
`methodology_dashboard.py`’s size-risk check omits
`PROJECT_LEARNINGS.md`, itself past the 2,000-line FM \#28 cap – new
Housekeeping item below. See `CHANGELOG.md`.

**`PROJECT_LEARNINGS.md` is past the 2,000-line FM \#28 agent-`Read`
cap, but `methodology_dashboard.py`’s size-risk check doesn’t cover it**
(found S625, 2026-08-23) – **RESOLVED S626 (2026-08-23): confirmed NOT a
gap – the dashboard’s exclusion is correct by the tool’s own stated
design, not an oversight.** Direct grep of `SESSION_RUNNER.md`/
`SAFEGUARDS.md` found no step anywhere that mandates reading
`PROJECT_LEARNINGS.md` in full; `CLAUDE.md`’s own text (the
“Project-specific Learnings” section) says explicitly: “Read it when you
need prior-session context… Base methodology-level learnings remain in
`SESSION_RUNNER.md`” – i.e. read ON DEMAND (grep-by-`Learning N`, the
pattern every citation in `CLAUDE.md` actually uses), never read whole
to compute anything. That is the SAME excluded category
`methodology_dashboard.py`’s own `READ_CAP_WATCHED` comment already
names for `ROADMAP.md` (“cited as a pointer, never as a file read whole
to compute anything… flagging it would re-create the very false positive
BL-5’s ext filter… exists to kill”) – the S625 finding’s premise (“a
mandatory Phase 0 (`CLAUDE.md`) read”) does not hold, confirmed by
direct grep, not assumed. Separately confirmed
`methodology_dashboard.py` is itself a canonical **TRACKED** dest
(`bin/_manifest.py` in the sibling `methodology` checkout,
`starter-kit/methodology_dashboard.py` line 44) – this project’s copy is
already stale (v2.14.0 vs. canonical v2.15.2) – so even a warranted
local list edit would risk being lost or diverging on the next sync,
reinforcing that this was correctly left to the tool’s own design rather
than hand-patched. No dashboard code change made. `PROJECT_LEARNINGS.md`
Learning 659 records the finding and the “confirm the premise before
accepting a predecessor’s framing” reflex it demonstrates. See
`CHANGELOG.md`.

**Evaluate adopting `context_budget.py`, a new methodology tool shipped
in canonical v3.7** (found S617, 2026-08-20, incidental to the v3.7
methodology sync, READY, Effort S – a research/scoping session, not an
implementation session) – true upstream `KJ5HST/methodology` v3.7 ships
a new tracked file, `context_budget.py` (+ `.context-budget.json` seed),
that this project has never adopted (`bin/status` reports both
`missing`/`absent`). Per the methodology repo’s own `CHANGELOG.md`, it
addresses “Failure mode \#28 and context_budget.py – the artifacts Phase
0 mandates reading now have ceilings” – i.e. a token/context-budget
tracker, the tooling counterpart to the FM \#28 “unbounded mandatory
read” failure mode this session DID adopt into `SESSION_RUNNER.md`.
Deliberately not adopted this session (a new capability is a bigger
decision than syncing an existing file, out of “sync to v3.7”’s own
scope) – a future session should read `starter-kit/context_budget.py`
and its `HOW_TO_USE.md`/ `BOOTSTRAP.md` documentation in the sibling
`methodology/` checkout, decide whether it’s worth adopting given this
project already tracks file-size risk via `methodology_dashboard.py` and
`methodology_trim.py`, and if so run `bin/sync` (or manual copy) to add
it.

**`DESCRIPTION`’s `Suggests:` mixes real test/example/vignette
dependencies with dev-tooling-only packages that belong in a
`Config/Needs/...` field instead** (found 2026-08-20, incidental to
S615’s own DESCRIPTION edit, owner-directed via chat, READY, Effort S) –
owner-stated rule: `Suggests:` is for packages optional code in
`tests/`, `man/examples`, or `vignettes/` actually loads; anything
needed only by dev tooling (website building, linting, coverage, release
scripts) belongs in its own `Config/Needs/<name>:` field instead (`pak`
and similar tools understand these named dev-dependency groups), kept
out of `Suggests:` entirely. This session already fixed one instance
directly (`covr` moved to the new `Config/Needs/coverage: covr`,
matching the file’s own pre-existing `Config/Needs/ website: quarto`
precedent and confirmed via `.github/workflows/test-coverage.yaml:27`
already installing `covr` itself via `extra-packages: any::covr`,
independent of `DESCRIPTION`). Not fixed this session (out of Phase 2b’s
own scope, flagged not touched per owner direction): `devtools` and
`roxygen2` are also listed in `Config/renv/profiles/ dev/dependencies`
(line 88) as well as `Suggests` – redundant, or intentionally
dual-listed for a reason not investigated this session; `pkgdown` sits
in `Suggests` with no matching `Config/Needs/website` entry even though
`quarto` (already `Config/Needs/website`) is ALSO still separately
listed in `Suggests` – looks like the same
pkgdown-belongs-in-Config/Needs/ website gap, not confirmed. A future
session should audit every `Suggests:` entry against “does any file
under `tests/`, `vignettes/`, or a roxygen `@examples` block actually
load this via [`library()`](https://rdrr.io/r/base/library.html)/`::`”
and relocate anything that fails that test to the matching
`Config/Needs/<name>` group, verifying
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
still reports 0 new warnings/notes after.

**Register `rmsharp/nprcgenekeepr` with api.reuse.software so the REUSE
badge renders its real compliance status** (found S607, 2026-08-18,
DECISION NEEDED / owner action, Effort S) – the badge added above
currently renders gray **“unregistered,”** not green: hitting
`https://api.reuse.software/badge/github.com/rmsharp/nprcgenekeepr`
directly returns an “unregistered” SVG, and
`https://api.reuse.software/info/...` returns “Project not registered.”
This REUSE API service requires a one-time manual registration at
<https://api.reuse.software/register> (repo URL + an email address,
confirmed via a confirmation email) before it will crawl and report a
project’s actual compliance state – this is not something a session can
or should do on the owner’s behalf (it ties an email address to the
public registration and is a one-way “join the registry” action). The
repo itself IS `reuse lint`-compliant now (1234/1234, verified locally);
only the badge’s live display is blocked on this registration step. A
future session can verify the badge went green after the owner
registers, but cannot perform the registration itself.

(found S582, 2026-08-14, incidental to the `pb_diagram_legend.png`
reshoot above) **RESOLVED S630 (2026-08-25):** the staleness fear was
confirmed real (all 3 – plus `pb_diagram_legend.png` and
`diagram_rectilinear_edge_style.png` – had drifted to the pre-Track-2
“direct” default), but re-running `pedigree-diagram-screenshots.R`
surfaced something more serious first: the Diagram tab’s own default
(Rectilinear) edge style crashed with `Error: subscript out of bounds`
on a realistic focal-animal trim of the real bundled fixture – a real,
live regression, not a screenshot artifact (confirmed via a fresh
package reinstall from current `HEAD` and a standalone
[`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html)
run with full server-log capture, ruling out both a stale-build false
alarm and a screenshot-harness artifact). Root-caused to
`.detectStraight()` inside `.resolveEdgeNodeCollisions()`
(`R/makePedigreeDiagramData.R`, introduced by commit `c7bdbe4b`, issue
\#160 Track 2): `xOf`/`yOf` were named ATOMIC vectors, and `[[` on an
atomic vector throws for an unmatched name instead of returning `NULL`,
so the existing `is.null(yf)`/`is.null(yt)` guard (written for list
semantics) never fired whenever an edge referenced a node id genuinely
absent from `nodes` – exactly what a real ancestors+descendants
focal-trim union can produce. Fixed via full strict-TDD RED-\>GREEN (2
new tests: a minimal synthetic dangling-reference fixture, and a
real-fixture regression pinning the exact production crash),
`AskUserQuestion`-gated at PRE-RED/RED-\>GREEN/GREEN-\>REFACTOR (owner
confirmed no refactor needed – the fix is a 2-line change,
`stats::setNames(...)` -\> `as.list(stats::setNames(...))`). All 5
screenshots regenerated against the fixed app and confirmed correct. Not
filed as a GitHub issue, matching the established “found-and-fixed same
session” precedent. See `CHANGELOG.md` and `PROJECT_LEARNINGS.md`.

(found S508, 2026-08-10, re-surfaced S559, 2026-08-13, **RESOLVED
S561**. **`HANDOFFS.md`’s declared `methodology_trim.py` regenerated
field (“retained receipt count”) had no matching “This file currently
holds **N**” sentence in the file’s own front matter**, so the tool’s
own `apply_regenerated()` printed a soft `FRONTMATTER_FIELD_ABSENT`
finding on every real archive `--write` (not, it turns out, on every
`--check` too – corrected finding below). Owner picked the “add the
sentence” remedy via `AskUserQuestion`, over removing the `regenerated`
config entry. Added “This file currently holds **3** receipt(s).” to
`HANDOFFS.md`’s front matter, immediately after the last “Archived N
record(s)…” pointer block, matching
`SESSION_NOTES.md`’s/`CHANGELOG.md`’s own bold-number pointer
convention. Verified two ways since the live archive trigger doesn’t
fire this session (20-record headroom, well under the byte budget): (1)
a direct unit-check importing `methodology_trim`’s own
`LEDGERS["HANDOFFS.md"].regenerated[0]` regex against the new sentence
confirms it matches and extracts the correct old value; (2) a dry-run
`--cut @<sha>` (no `--write`) confirms the live file’s own record parser
counts exactly 3 records, matching the sentence. **Correction to the
original finding’s own framing:** re-reading `methodology_trim.py`’s
control flow shows `--check` returns immediately after reporting the
trigger status and never reaches `apply_regenerated()` at all – only a
real `--write` that actually builds an archive plan (trigger fires, or
an explicit `--cut`) does. The “every check/write run” framing in the
original S508 finding was inaccurate (or true only of an older tool
version); the field was absent only on the 3 real archive `--write`
passes to date, not on ordinary `--check` calls. See `CHANGELOG.md`.)

(found S555, incidental to the consanguineous-marker PRE-RED
investigation above, **FIXED S556**. **A dangling (no-own-row) parent
anywhere in a pedigree silently widened `.positionMatingUnitForest()`’s
`genOf` from integer to double, which could spuriously trigger
`.addRectilinearWaypoints()`’s D2 “dogleg” reroute on OTHER, unrelated,
correctly-matched mate-line edges elsewhere in the same diagram.** Root
cause: the dangling- parent gen fallback used
`vapply(danglingIds, ..., numeric(1L))` – forcing a double even though
the value it returns (`matingUnits$gen`) was already integer – and
`genOf <- c(genOf, ...)` then silently widened the WHOLE `genOf` vector
via R’s own type-promotion rule, corrupting
`.addRectilinearWaypoints()`’s strict, type-sensitive
`identical(side$gen, Ugen)` comparison. Fixed: `numeric(1L)` -\>
`integer(1L)` (matches the value’s actual source type). Empirically
confirmed on a 5-row reproduction fixture (an unrelated, already-on-row
union spuriously doglegged purely because a second, unrelated union
referenced a dangling parent – 0 spurious nodes after the fix). Scope
was `edgeStyle = "rectilinear"`-only; the bundled 375-individual real
fixture has no dangling parents and was never affected. 4 new/updated
unit tests (3 `expect_type(pos$gen, "integer")` assertions added to
existing `test_positionMatingUnitForest.R` dangling-parent tests –
existing `expect_equal()`-based assertions are type-blind to this class
of bug, `PROJECT_LEARNINGS.md` Learning 562 – plus 1 new end-to-end
regression test in `test_addRectilinearWaypoints.R`).
[`devtools:: check()`](https://devtools.r-lib.org/reference/check.html)
0 errors/1 pre-existing warning/1 pre-existing note (both unrelated);
full clean regression 0 failed/0 error; live E2E
(`test-e2e-pedigree-module.R`) 15/15, 0 regressions;
`lintr::lint_package()` 0 lints. Not filed as a GitHub issue.)

(found S552, **RESOLVED S558**. **Repository branch cleanup, all 12
stale branches now deleted.** S557 deleted 7 confirmed-safe branches (0
commits ahead of `master`, prior PR merged) via mechanical
mergedness/PR-history checks. The remaining 5 – `module`, `issue8`,
`issue8-fix`, `marks-broken-issue8`, `nprcmanager-master` – each had
real unmerged commits and no PR history, so mergedness alone couldn’t
establish “safe.” S558 read each branch’s actual diff content (commit
history, diffstats, merge-bases, and targeted function/file cross-checks
against `master`) rather than relying on mergedness status: `module`’s
merge-base with `master` sits exactly where master’s own modularization
work began (`3773e63b`, 2025-12-30) – master went on to independently
complete that same effort more thoroughly (incl. a `feat!: Phase 9`
commit deleting the legacy `inst/application` app that `module` never
got); of `module`’s 120 files absent from `master`, none were a
substantial unique capability (mostly the legacy app, superseded sample
data, and small 21-110-line scratch helpers/test modules with modern
equivalents already on `master`, e.g. `nprcgenekeeper.R` -\>
`R/nprcgenekeepr-package.R`). `issue8`/`issue8-fix`/
`marks-broken-issue8` all shared the same ancient 2021-04-21 merge-base;
`issue8-fix`/`marks-broken-issue8` were near-duplicates of each other (8
files differ); every named function traceable from their commits
(`createSimKinships`/`cumulateSimKinships`/`getPotentialParents`/
`summarizeKinshipValues`/`countKinshipValues`/`kinshipMatrixToKValues`/
`combinerKinshipTriangles`) already exists on `master` today, complete
with `man/` docs and `tests/testthat/` coverage. `nprcmanager-master`
shared **no merge-base at all** with `master` (a disjoint root) – the
project’s literal first 8 commits under its original “nprcmanager” name
(2017). Findings presented to the owner via `AskUserQuestion`; all 5
approved for deletion. Deleted: `module` (local+remote),
`issue8`/`issue8-fix`/`marks-broken-issue8`/`nprcmanager-master` (remote
only). `git branch -a` now shows only `master` and `gh-pages` (the live
`pkgdown.yaml` deploy target, confirmed live and excluded from cleanup
by S557). See `CHANGELOG.md`.)

(found S545, **verified S549** – see
`docs/audits/KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md`.
**Verify the results in
`inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf`
(kinship2’s supplementary material) can be reproduced with
`nprcgenekeepr`’s own exported functions.** Scope caveat found first:
the full 17-subject `fam1` pedigree cannot be exactly reconstructed from
this repo’s materials (its Figure 1 lives in the kinship2 *main* paper,
not this supplement, not among the repo’s other reference PDFs, and not
shipped in any installed `kinship2` dataset) – audited the
fully-specified 10-subject Figure S1 subset instead, reconstructed from
Table S1’s own kinship values (verified, not guessed from the figure).
Result:
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)’s
autosomal matrix reproduces Table S1 **exactly** except cells touching
the pedigree’s one MZ-twin pair (a real, if narrow-trigger, capability
gap – see the 2 new items below); pedigree-diagram structure
(nodes/edges/generations/twin-connector) is correct via
[`makePedigreeDiagramData()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeDiagramData.md)/
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md);
kinship2’s `pedigree.shrink()` (bit-size-driven,
availability/affected-status trimming) has no `nprcgenekeepr`
equivalent, judged a capability-fit non-issue (different problem domain,
not this package’s mission); no X-chromosome-specific kinship
computation exists (also judged out of current scope). See the audit doc
for the full evidence, including a `kinship2`-reproduced side-by-side
confirming the MZ-twin gap’s mechanism precisely. **Note, RESOLVED
S567:** the PDF’s copyright/licensing classification (untracked in git,
absent from `.gitignore`/`.Rbuildignore` unlike its copyrighted siblings
in the same directory) was unresolved since S545. Owner decision (via
`AskUserQuestion`, 2026-08-14): gitignore it, matching the S479/S497
precedent – it is an NIHMS/PMC deposit (free reading access under NIH’s
public-access policy) but that is not confirmed to carry third-party
redistribution rights, so it is excluded from this PUBLIC repo out of
the same caution as the other 3 files, not because it fails their “no
open-access marking” test. `.gitignore`/ `.Rbuildignore` both updated;
verified by an actual `R CMD build` that the file is now excluded from
the built tarball (the file remains on local disk, still usable by
`data-raw/kinship2FidelityValidation.R`). See `CHANGELOG.md`.)

**Thread `twinRelations` into
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)’s
computation, not just diagram rendering** (found S549, Finding \#1 of
the above audit; design RATIFIED S550; **all 3 slices DONE S551-S553,
RESOLVED**, see
`docs/planning/twin-relations-kinship-computation-plan.md`) –
`nprcgenekeepr` already had a twin-declaration data model
([`checkTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md),
issue \#137) but it feeds only the Diagram tab; every kinship-driven
calculation silently treats a declared monozygotic-twin pair as ordinary
full siblings, understating their kinship and understating every
relative reached through either twin (transitively, not just the direct
pair – kinship2’s own behavior). Ratified design: extend
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)’s
own signature with a new `twinRelations = NULL` parameter (porting
kinship2’s `mzgrp`/`mzindex` in-loop-correction mechanism directly – a
post-hoc single-pass patch on the finished matrix was proven
mathematically insufficient, since it cannot correctly propagate to a
twin’s descendants);
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
trusts a pre-validated `twinRelations` (documented precondition) rather
than re-validating internally, since its flat-vector signature has no
`sex` parameter to run
[`checkTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)’s
full rule set itself. **Slice 1 (core algorithm) DONE S551**:
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
gained the `twinRelations` parameter, verified against `kinship2`’s own
ground truth on the audit’s 10-subject fixture (`kinship(8,9)=0.5`,
`kinship(9,10)=0.28125`, exact matches) plus a 3-member transitive-group
fixture and a DZ/UZ-coded zero-treatment fixture;
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) 0
errors/0 warnings; full clean regression read 0 failed/0 error.
`R/applyKinshipOverrides.R`’s “never modified” roxygen sentence updated
per Dragon 2. **Slice 2 (the 4 script-callable functions) DONE S552**:
[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md),
[`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md),
[`createSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/createSimKinships.md),
[`cumulateSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/cumulateSimKinships.md)
each gained their own `twinRelations = NULL` parameter passed straight
through to their internal
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
call; `test_gvaConvergence.R` was confirmed to already exist (Dragon 4
resolved, no new file needed). Verified:
[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)’s
returned `$kinship` matches Slice 1’s own ground truth exactly with
twins declared;
[`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)
accepts the parameter and threads it without error (its own
convergence-curve output has no kinship-observable surface at this
fixture’s scale – the same documented limitation
`test_gvaConvergence_kinshipOverrides.R` already establishes for the
analogous `kinshipOverrides` parameter);
[`createSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/createSimKinships.md)/[`cumulateSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/cumulateSimKinships.md)
both directly reproduce the twin-corrected values in every
simulated/mean matrix.
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) 0
errors/0 warnings/1 pre-existing unrelated NOTE; full clean regression
read 0 failed/0 error; `lintr::lint_package()` 0 lints on all 8 touched
files. One combined `NEWS.Rmd` entry added covering Slices 1-2 together
(the plan’s own §8 item 3 open question, resolved this session). **Slice
3 (full Shiny wiring) DONE S553, closing this item:**
[`modPedigreeServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeServer.md)’s
return list gained a `twinRelations` reactive (the raw, ungated
`twinRelationsData()`, unaffected by the “Show Twin Connectors” toggle);
`R/appServer.R` gained `shared$twinRelations`, wired into
`sharedKinshipMatrix`’s own
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
call and threaded through to
`modGeneticValueServer`/`modBreedingGroupsServer`/`modSummaryStatsServer`
(each gained a matching `twinRelations` parameter on their own fallback
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
recompute path). Dragon 1 (the tab-order UX question) resolved via
Pre-RED `AskUserQuestion`: a single upload point (Diagram tab only) –
Shiny’s reactive graph runs every module from session start, not gated
by tab visibility, so “regardless of tab visit order” is satisfied
mechanically without a second, duplicate upload control; decision
recorded in the plan document’s own §6 Dragon 1. Verified live
end-to-end (Phase 3E, new `test-e2e-twin-relations-cross-tab.R`): a
`twinRelations` file uploaded on the Diagram tab is reflected in the
Summary Statistics kinship export for the declared MZ pair without ever
visiting Genetic Value Analysis; the pre-existing
`test-e2e-pedigree-module.R` twin-connector suite (13 tests/45
assertions) re-confirmed unaffected.
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) 0
errors/0 warnings/1 pre-existing unrelated NOTE; full clean regression 0
failed/0 error (2,155 test blocks); `lintr::lint_package()` 0 lints on
all touched files. Fixed 3 pre-existing test-double staleness gaps the
full regression (not the targeted run) surfaced in untouched files:
`test_appServer_logging.R`’s own local `modPedigreeServer` stub,
`test_modGeneticValue.R`’s 2 `local_mocked_bindings(reportGV = ...)`
signatures, and `test_moduleContract.R`’s `modPedigreeServer`
return-name whitelist – see `PROJECT_LEARNINGS.md` Learning 559.
`NEWS.Rmd` entry extended (one combined Slices 1-3 entry);
tutorial/article checklist applied
(`vignettes/manual_components/_pedigree_browser.Rmd` gained a paragraph
on the app-wide kinship correction). Not yet filed as a GitHub issue.

(found S549, Finding \#2 of the above audit, **FIXED S555 for
`edgeStyle = "direct"`**. **Add a visual marker for consanguineous
matings in the Pedigree Diagram tab** – kinship2 draws a
doubled/thickened mate-line for a blood-related couple;
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
rendered every mating unit identically regardless of
`kinship(sire, dam)`. Distinct from issue \#134 (verified layout
*doesn’t break* for consanguineous loops, closed S453 – a robustness
check, not a visual-signaling one) and from the “Candidate C”
cross-generation dogleg item below (a geometry-signposting problem, not
a blood-relation one). Fixed: a mating unit whose sire/dam pair has
`kinship(sire, dam) > 0` (computed via the function’s own
already-validated `twinRelations` parameter too, for correctness parity
with the twinRelations-into-
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
work above) now renders its 2 spouse-to-union edges with a distinct
color/ width (`"#D55E00"` Okabe-Ito vermillion, width 4) – always on, no
new UI toggle, since sire/dam are required columns (a structural fact of
the pedigree), unlike the optional name/twinRelations sidecars. `edges`
gains `color`/`width` columns unconditionally once any mating unit
exists. 6 new/updated unit tests (`test_makePedigreeMatingLayout.R`);
new live E2E test confirms 56 marked edges (28 genuinely consanguineous
unions x 2) at width 4 on the bundled 375-individual fixture.
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) 0
errors/0 warnings/ 1 pre-existing NOTE; full clean regression 0 failed/0
error; `lintr::lint_package()` 0 lints. Not filed as a GitHub issue.
**Deferred follow-up (owner-directed hold, S555):**
`edgeStyle = "rectilinear"` propagation – a marked mate edge whose
parent sits at a different gen than its own mating unit (the D2 “dogleg”
reroute; empirically confirmed live to require an anchor who anchors 2+
differently-gen’d units, a real but narrow-trigger scenario, e.g.
cross-generation consanguineous matings) currently falls back to the
generic routing- blue color/default width on its 2 replacement
projection edges instead of inheriting the marker.
`.addRectilinearWaypoints()` already defensively guards `width`/`color`
column presence (no crash), but does not yet propagate a dropped mate
edge’s own color/width onto its replacement edges. A future session
should extend the D2 dogleg loop in `R/makePedigreeDiagramData.R`
(`.addRectilinearWaypoints()`) to look up the original edge’s
color/width before dropping it and stamp both onto its 2 new projection
edges, falling back to the generic blue/default only when absent –
mirrors the color-preservation precedent already established there for
KEPT edges (issue \#137 D10). A verified 12-row fixture forcing this
exact scenario (an anchor double-anchoring 2 different-gen units, one of
them consanguineous) was constructed empirically this session and is a
ready-made starting point (see S555’s own `PROJECT_LEARNINGS.md` entry
for the fixture and the reasoning that got there). **FIXED S563** (Track
C of the kinship2 supplement full-reproduction plan below,
`docs/planning/kinship2-supplement-full-reproduction-plan.md` §5):
S555’s own 12-row fixture code was never committed, so a fresh,
independently-verified 9-row equivalent (a consanguineous full-sib
mating forced to dogleg by its anchor also anchoring an unrelated,
higher-gen union) was constructed and confirmed live this session.
`.addRectilinearWaypoints()`‘s D2 loop now looks up a dropped mate
edge’s own color/width (keyed by the dogleg’s `projId`) and stamps both
onto its 2 replacement projection edges via a post-hoc override after
the existing generic fallback assignment, applied only when a marker was
present – mirrors the KEPT-edges precedent exactly, no other edges
affected. 1 new `test_that()` block
(`tests/testthat/test_makePedigreeMatingLayout.R`, 5 assertions)
confirmed RED against unmodified source, then GREEN.
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) 0
errors / 1 warning + 1 note (both confirmed pre-existing/unrelated: the
untracked “Compounding Loop” clutter files’ non-portable names, and a
pre-existing `vignettes/figure/` knitr leftover); full clean regression
1 pre-existing failure unrelated to this change
(`test_wordlist_coverage.R`, confirmed via `git stash`);
`lintr::lint_package()` 0 lints on touched files. Not filed as a GitHub
issue.

**Fully reproduce kinship2 supplementary-material PDF’s results**
(owner-directed follow-up to the S549 audit above – “duplicate the work
done in that PDF,” overriding that audit’s own “no action” verdict on 2
of its 4 findings; plan RATIFIED S562, READY, Effort L overall) – plan
complete: `docs/planning/kinship2-supplement-full-reproduction-plan.md`.
3 independently session-sliceable tracks, no shared code: **Track A**
(X-chromosome kinship, Table S2 –
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
gains `chrtype`/`sex` params, ratified scope is the core algorithm only,
Effort M) – **DONE S564**, see below; **Track B** (a `pedigree.shrink()`
equivalent – new
[`shrinkPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/shrinkPedigree.md)
function, script-callable only, deterministic tie-break \[diverges from
kinship2’s own [`runif()`](https://rdrr.io/r/stats/Uniform.html)
non-determinism by design, ratified\], the most novel of the 3, Effort L
– 2 of kinship2’s own internal helpers
\[`excludeUnavailFounders`/`excludeStrayMarryin`\] were not yet deparsed
by the plan, left as an explicit Pre-RED item) – **DONE S565**, see
below; **Track C** (finish the `edgeStyle="rectilinear"`
consanguineous-marker color/width propagation from the deferred item
directly above – smallest of the 3, Effort S, no open design question) –
**DONE S563**, see the deferred-follow-up item above and `CHANGELOG.md`.
Plan’s own §6.2 suggests C -\> A -\> B pickup order
(smallest/lowest-risk first) but does not force it. **All 3 tracks are
now DONE** (C: S563, A: S564, B: S565). Verification caveat carried from
the S549 audit: the full 17-subject `fam1` pedigree still isn’t
reconstructible from this repo, and Track B additionally had no
PDF-printed worked example to check against at all (the PDF only names
*which* subjects a shrink would trim, never their relationships) – Track
B verified against the installed
[`kinship2::pedigree.shrink()`](https://rdrr.io/pkg/kinship2/man/pedigree.shrink.html)
directly instead. **RESOLVED S566:** filed and closed 3 GitHub issues
(#156 Track A, \#157 Track B, \#158 Track C), each citing its
implementing commit and verification evidence; published a new numeric+
graphic fidelity validation article,
[`vignettes/articles/kinship2-fidelity-validation.qmd`](https://github.com/rmsharp/vignettes/articles/kinship2-fidelity-validation.qmd)
(matching the `fg-se-validation.qmd` precedent), running the SAME
fixture from each track’s own committed test file through both packages,
live, side by side: Track A’s autosomal and X-linked kinship matrices
are bit-for-bit identical to kinship2’s own output (max abs diff = 0
across 200 compared cells); Track B’s
[`shrinkPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/shrinkPedigree.md)
reproduces kinship2’s exact surviving subject set and exact `bitSize`
trajectory on a 16-subject fixture, shown as before/after pedigree
diagrams from both packages; Track C’s consanguineous marker flags the
same union kinship2 flags under both edge styles. Generated by
`data-raw/kinship2FidelityValidation.R` (kinship2 installed locally,
offline, matching the established “no new Suggests dependency”
precedent) – see that script’s own header for the reproduction command.
See `CHANGELOG.md`.

(**Track A above, DONE S564.**
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
gained `chrtype = c("autosome", "x")` and `sex` arguments – X-chromosome
kinship (kinship2 supplement Table S2), core algorithm only per ratified
D-A2 Option A (no propagation to
[`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)/[`gvaConvergence()`](https://github.com/rmsharp/nprcgenekeepr/reference/gvaConvergence.md)/[`createSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/createSimKinships.md)/[`cumulateSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/cumulateSimKinships.md)
or the Shiny app). `chrtype = "autosome"` (the default) is
byte-identical to every prior call site – pinned by an
`expect_identical()` regression test. Full 10x10 Table S2 transcribed
directly from
`inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf` via
`pdftotext -layout` (not read visually) and cross-validated by
hand-porting kinship2’s own deparsed X-linked algorithm, run live
against the installed `kinship2` 1.9.6.2. PRE-RED finding beyond the
plan’s own framing: Table S2’s printed values already embed the MZ-twin
correction (Figure S1 declares subjects 8/9 identical twins), so one
fixture (the existing `fam1`/`twins` pair already in
`tests/testthat/test_kinship.R`, extended with a `sex` column) satisfies
both “reproduce Table S2” and the plan’s separately-listed “combined
X-linked + MZ-twin” coverage requirement. 6 new `test_that()` blocks
(Table S2 reproduction; twin-correction isolation; backward-compat
`expect_identical()` pin; `sex` validation; invalid-`chrtype`
validation; unknown-sex NA propagation), all confirmed failing for the
right reason against unmodified source before GREEN.
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) 0
errors, 1 warning + 1 note, both confirmed pre-existing/ unrelated via
`git stash` (the untracked “Compounding Loop” files’ non-portable names;
a pre-existing `vignettes/figure/` knitr leftover) – matching Track C’s
own S563 findings exactly. Full clean regression 1 pre-existing failure
(`test_wordlist_coverage.R`), confirmed via `git stash` unrelated
(`matings`/ `runnable`, from `.qmd` articles, untouched by this diff);
this session’s own 2 new spelling flags (`Schaid`/`Sinnwell`, from a new
roxygen `@references` citation) were fixed via `inst/WORDLIST`
additions, not left as new debt. `lintr::lint_package()` 0 new lints (2
introduced by new camelCase variable names `sexNum`/`founderDiag`
suppressed via `# nolint: object_name_linter`, matching the file’s own
established convention and the 5 pre-existing lints already in this
file, confirmed via `git stash`, left untouched). Not filed as a GitHub
issue, matching Track C’s own precedent. See `CHANGELOG.md`.)

(**Track B above, DONE S565.** New `R/shrinkPedigree.R`:
`shrinkPedigree(ped, genotyped, affected = NULL, maxBits = 16L)`, a
[`kinship2::pedigree.shrink()`](https://rdrr.io/pkg/kinship2/man/pedigree.shrink.html)
equivalent over this package’s own `id`/`sire`/`dam` data-frame pedigree
representation. All 8 of kinship2’s own internal helpers
(`pedigree.shrink`, `bitSize`, `findUnavailable`,
`excludeUnavailFounders`, `excludeStrayMarryin`, `findAvailNonInform`,
`findAvailAffected`, `pedigree.trim`) were deparsed directly from the
installed namespace (1.9.6.2) at Pre-RED – including the 2 the plan
itself flagged as not yet deparsed. 4 findings beyond the plan’s own
framing, all documented in the function’s own roxygen: (1)
`excludeStrayMarryin` ignores `genotyped` entirely – any childless
founder is removed unconditionally; (2) `excludeUnavailFounders`’s real
criterion requires the founder couple have exactly one child together
*and* neither parent married to anyone else, confirmed by a live
negative-case test; (3) kinship2’s own `all(x == 0, na.rm = TRUE)`
non-informative-affected check treats `NA` the same as unaffected; (4) a
real, empirically-confirmed divergence – kinship2’s own `pedigree()`
constructor forbids a single-known-parent individual (“Subjects must
have both a father and mother, or have neither”), so its algorithm never
has to define that case, but this package’s pedigrees allow partial
parentage as ordinary data
([`getIdsWithOneParent()`](https://github.com/rmsharp/nprcgenekeepr/reference/getIdsWithOneParent.md));
a literal port would divide a zero-length vector and error, so
[`shrinkPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/shrinkPedigree.md)
never marks such an individual non-informative instead (documented,
tested, no crash). A 5th finding: kinship2’s own
`idTrimmed`/`idList$affect` record only the single trial candidate per
affected-priority round even when its removal cascades further
(confirmed live: a fixture exists where kinship2’s own `pedSizeFinal`
drops by 2 in one round but `idTrimmed` names only 1) –
[`shrinkPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/shrinkPedigree.md)
deliberately fixes this, recording every id actually removed each round,
so `pedSizeOriginal - pedSizeFinal` always equals `length(idTrimmed)`
(does not change which individuals survive, only audit-trail
completeness). Deterministic lowest-id (string-sorted) tie-break (D-B2)
confirmed against a fixture proven live to be a genuine ~50/50 tie in
kinship2’s own [`runif()`](https://rdrr.io/r/stats/Uniform.html)-based
reference. 14 `test_that()` blocks (20 expectation markers incl. a
5-iteration determinism-repeat loop) in new
`tests/testthat/test_shrinkPedigree.R`, every hardcoded expected value
(id sets, `bitSize` trajectories, `idList` groupings) independently
verified live against the installed `kinship2` 1.9.6.2 this session (not
hand-derived), confirmed failing for the right reason against unmodified
source before GREEN – including one test added mid-GREEN after the
idTrimmed-completeness finding above surfaced.
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) 0
errors, 1 warning + 1 note, both confirmed pre-existing/unrelated via
`git stash` (matching Track A/C’s own findings exactly). Full clean
regression 1 pre-existing failure (`test_wordlist_coverage.R`,
`matings`/`runnable` from `.qmd` articles, confirmed via `git stash`);
this session’s own new spelling flag (`orchestrator`, from roxygen
prose) fixed via `inst/WORDLIST`, not left as new debt.
`lintr::lint_package()` 0 lints (no suppressions needed – an earlier
speculative round of `# nolint: object_name_linter` comments was found
unnecessary, since this project’s `.lintr` already allows camelCase, and
was removed). `_pkgdown.yml` reference-coverage checklist: added to both
the “Primary interactive functions” curated group and the “All exposed
functions” catch-all (a real gap `test_pkgdown_reference_config.R`
caught). **All 3 tracks of the kinship2 supplement full-reproduction
plan are now DONE** (C: S563, A: S564, B: S565). None filed as a GitHub
issue, matching the established “recommend, don’t unilaterally file”
precedent – the owner may wish to file one (or three) before further
related work. See `CHANGELOG.md`.)

(found S552, owner-reported live, **FIXED S554**. **Pedigree Diagram
tab’s affected-status shading fills unaffected individuals too, counter
to standard pedigree drawing convention** – issue \#133’s
`.affectedColor()` (`R/makePedigreeDiagramData.R`) set
`color.background` to `"#CC79A7"` when `affected == TRUE` and left it
`NA_character_` otherwise; in visNetwork an `NA` `color.background` does
not render as an *open/unfilled* node – it falls back to the library’s
own default fill, so unaffected/unknown-affected individuals still
rendered solid-filled. Fixed: `FALSE`/`NA` now get an explicit
`"#FFFFFF"` (open/unfilled), matching kinship2’s own “unfilled if 0/NA”
convention (verified against the issue \#133 plan document’s own
kinship2-source research). 6 existing unit-test assertions updated
(`test_makePedigreeDiagramData.R`, `test_makePedigreeMatingLayout.R`);
new live E2E test confirms the actual rendered color for a known
TRUE/FALSE/NA triple via the bundled
`obfuscated_rhesus_mhc_ped_affected.csv` fixture.
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) 0
errors/0 warnings/1 pre-existing NOTE; full clean regression 0 failed/0
error (2,156 test blocks); `lintr::lint_package()` 0 lints. Not filed as
a GitHub issue.)

**`CHANGELOG.md`’s own ~4-entries-per-session ledger convention (claim,
Phase 0 reconcile, deliverable, close-out) may be a `CHANGELOG.md`-side
analogue of the already-diagnosed `HANDOFFS.md` “Receipt Inflation” (H4)
rate problem** (found S543, 2026-08-12, Effort unknown, not
investigated) – incidental to the `SRF_RED` investigation: the tagged
region regrew ~105,000 B in roughly a day during an active multi-session
stretch (S536-S542), and a `grep -c '^### 2026-08-12'` on the pre-trim
file showed a large share of that region was same-day,
multiple-entries-per-session housekeeping (claim/reconcile/close-out
entries) rather than deliverable-content entries. Not confirmed as
causal, and not investigated further this session (out of the `SRF_RED`
decision’s own scope, per `PROJECT_LEARNINGS.md` Learning 382’s “report,
don’t fix mid-session” precedent). A future session could measure the
actual housekeeping-vs-deliverable entry-byte split and decide whether a
norm analogous to the canonical design’s own deferred H4 remedy
(`docs/planning/ledger-trimmer-design.md` §10.2, “the lever is receipt
size, and the mechanism would be a norm plus a check, not an archiver”)
is worth adopting for `CHANGELOG.md` specifically.

(found S461, **RESOLVED S560**. **Stale `pb_diagram_legend.png`
screenshot and its surrounding pre-Option-2 prose in
`colony-manager-guide.qmd`.** Regenerated the screenshot against a
small, legible, real 6-animal subgraph (the Option 2
mating-unit/duplicate-node convention, incl. a consanguineous marker);
rewrote the paragraph’s opening sentence to describe the mating-unit
convention and the `edgeStyle` toggle, and added a twin-connectors
mention. See `CHANGELOG.md`.)

(owner-directed, found S544, **RESOLVED S560**. **New dedicated article,
`vignettes/articles/pedigree-diagram.qmd`, covering the Pedigree Diagram
tab’s full current feature set** (node shapes/legend, `edgeStyle` direct
vs. rectilinear, consanguineous marker, affected-status shading, name
labels, twin/zygosity relations and their app-wide kinship correction,
hover/click/search/PNG-export interaction, and the script-callable
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)/
[`visNetwork::visNetwork()`](https://rdrr.io/pkg/visNetwork/man/visNetwork.html)
equivalent) – matches the established per-tab-article convention
(`age-sex-pyramid.qmd`, `genetic-value-analysis.qmd`,
`breeding-group-formation.qmd`), with 5 freshly-captured live-app
screenshots via a new
[`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html)
script (`pedigree-diagram-screenshots.R`). Cross-linked from
`colony-manager-guide.qmd`’s function-group table and
`a2interactive.Rmd`’s own “Pedigree Diagram” section. Subsumes the
stale-screenshot item above. See `CHANGELOG.md`.)

**iCloud “conflicted copy” duplicate `.R` files corrupt
[`devtools::document()`](https://devtools.r-lib.org/reference/document.html)/`R CMD check`
output** (found S461, Effort S, not a code defect) – `R/appServer 2.R`
and `R/modMarkerGenetics 2.R` (carried forward many sessions as passive
noise) are SOURCED by
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)/[`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
like any other `.R` file, silently merging their own stale roxygen
comments into the SAME generated `.Rd` page as the current source –
confirmed twice this session (`man/appServer.Rd`,
`man/modMarkerGeneticsServer.Rd`, `man/modMarkerGeneticsUI.Rd`, each
reverted via `git checkout --` immediately). See `PROJECT_LEARNINGS.md`
Learning 454. The owner is relocating this repository outside iCloud’s
purview specifically because of this and other iCloud-latency issues
(same session, out-of-band) – once moved, this item should self-resolve;
a future session should confirm the 2 duplicate files no longer reappear
and, if so, close this item without further action. **Recurred again
S462 (2026-08-03):** the owner rebuilt the package locally (outside this
session’s own tool calls) while reviewing a screenshot, which
re-corrupted the same 3 `.Rd` files the same way; reverted again via
`git checkout --`. As of this session’s Orient, the planned repository
relocation had NOT yet happened (`pwd` still resolves to the original
iCloud-synced path) – this item cannot be closed until the move actually
completes.

**[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)’s
spelling NOTE has drifted again – 6 new words, not caught by any session
since S461** (found S465, Effort S, incidental – confirmed pre-existing,
not caused by this session’s own diff via a stash test) –
`man/makePedigreeMatingLayout.Rd:40` (“sibship”, “waypoint”) and
`vignettes/a2interactive.Rmd:355,371,429, 437,440,441`
(“duplicateToReal”, “js’s”, “makePedigreeMatingLayout”, “vis”) are
flagged in
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)’s
`spelling.R` test diff (comparing fresh `spelling.Rout` against the
committed `spelling.Rout.save`) but are not yet in `inst/WORDLIST`.
Mirrors the S443/S448/S452 spelling-gap pattern (Learning 426,
`CLAUDE.md`’s own “Additional close-out checks” precedent) – a future
session should hand-add these 6 words to `inst/WORDLIST` in `LC_ALL=C`
byte-order position (not via
[`spelling::update_wordlist()`](https://docs.ropensci.org/spelling//reference/wordlist.html),
per S230 convention) and re-verify
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
drops to the pre-existing iCloud duplicate-file warning +
vignette-engine note only. **Count grown to 9 words as of S490
(2026-08-09), still not fixed** – incidental to issue \#136 Slice 2’s
own
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
verification pass. The original 6
(`sibship`/`waypoint`/`duplicateToReal`/`js's`/
`makePedigreeMatingLayout`/`vis`) are joined by 3 more: `discoverable`
(`NEWS.md:140`), a bare `js` (`a2interactive.Rmd:533`, distinct token
from `js's`), and `unshaded` (`_pedigree_browser.Rmd:55`) – all 3
confirmed via `git blame`/`git log -S` to trace to commit `100741ae`
(S487, 2026-08-08, issue \#133 Slice 2’s own NEWS/tutorial/article
commit), not this session’s diff. A future session fixing this item
should hand-add all 9 words, not just the original 6. **Count grown to
10 words as of S642 (2026-08-26)** – incidental to this session’s
`test_wordlist_coverage.R` full-regression run: `comparator`
(`R/comparePedigreeStructure.R:230`, a roxygen `@details`-block word,
likely introduced by S633-S636’s original `.comparePedigreeStructures()`
implementation). Confirmed pre-existing via a `git stash` test (fails
identically with this session’s own diff stashed out) – not caused by
this session’s `. formatStructuralDiscrepancy()` work. Not visible on
real CI (all recent `R-CMD-check.yaml` runs green), likely a local
hunspell/ dictionary-state difference from CI’s runner, matching this
item’s own established “local devtools::check() catches words CI’s own
spelling gate doesn’t” pattern.

**The “10 pre-existing baseline warnings” carried in every
full-regression report since S448 have never been root-caused, and were
introduced by a test-fixture gap, not a real production-code issue**
(found S487, incidental to issue \#133 Slice 2’s own regression read;
Effort S, low priority) – the owner asked directly (“we had zero at last
release”) after seeing `warning: 10` in this session’s clean regression
read, which no prior session had actually traced. Root cause: both
`tests/testthat/test_modMarkerGenetics.R` “cross-center” tests (added by
commit `a319e0c5`, S447, 2026-08-01, implementing issue \#130 Slice 5)
upload a hand-derived 2-locus toy fixture (Center A n=4, Center B n=6)
chosen for exact-fraction Fst arithmetic, not for kinship completeness.
`modMarkerGeneticsServer`’s reactive graph incidentally also computes
marker-based kinship (the Slice 1 feature) on any uploaded Center-A
file, and in this fixture `'CA1'`/`'CA2'` share no heterozygous locus –
[`markerKinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)
correctly warns and returns `NA` for that pair (working as designed, not
a bug), 5x per test x 2 tests = 10. **Confirmed CRAN v2.0.0 (released
2026-07-26) predates S447 (2026-08-01) and genuinely shipped with a
clean, 0-warning suite** – the owner’s recollection was correct. S447’s
own close-out reported “0 failed/0 error” but never actually stated a
warning count; S448 (the very next session) independently found S447’s
self-reported
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
“0/0/0” also didn’t hold up under re-verification (a missed spelling
gap) – the same kind of unverified self-report, in the same session, is
the most likely origin of this gap too, though this was never directly
confirmed against S447’s own raw test output (not preserved). Every
session from S448 through S486 (~40 sessions) carried “10 pre-existing …
warnings” forward as an accepted baseline without investigating what it
was. Not fixed this session (`PROJECT_LEARNINGS.md` Learning 382’s
“report, don’t fix mid-session” precedent – out of scope for a Slice 2
legend/documentation TDD session; owner directed file-and-continue via
`AskUserQuestion`). A future session should either (a) wrap the
`session$setInputs(genotypeFile = ...)` calls in these 2 tests with
[`suppressWarnings()`](https://rdrr.io/r/base/warning.html) (matching
the established `PROJECT_LEARNINGS.md` Learning 273(d) precedent: “a
degenerate out-of-contract input … often misbehaves further downstream –
suppress the incidental warning, not the branch”), or (b) adjust the
2-locus fixture so `CA1`/`CA2` share a heterozygous locus – but only
after re-verifying the exact-fraction Fst values (`58/1001`, `139/308`,
`614/2233`) still hold, since the fixture was hand-derived specifically
to produce those numbers. **Count grown from 10 to 15, found
incidentally S504 (2026-08-10), still not fixed** – a full clean
regression read during issue \#149 Slice 1 showed `warning: 15`,
confirmed via a `git stash` comparison to be pre-existing (identical on
unmodified `HEAD`), unrelated to that session’s own diff. The 3rd
5-warning source is `test_modMarkerGenetics.R`’s
“candidate-parent-assignment table is non-empty for a real (non-mocked)
recorded-but-wrong-parent fixture (issue \#155)” block, added S502
(2026-08-10) – a live, non-mocked genotype-file upload that incidentally
triggers the same
[`markerKinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)
NA-warning path as the 2 original cross-center tests. A future session
fixing this item should address all 3 test blocks, not just the original
2.

**`BACKLOG.md`’s own ledger-size housekeeping – editorial compression,
not a `methodology_trim.py` config** (found S518, 2026-08-11, READY,
Effort L) – `BACKLOG.md` itself is one of the dashboard’s 3-file
HIGH-risk ledger-size items but does not fit `methodology_trim.py`’s
chronological-record model: it has 10 `##` sections, each a large
*standing topical category* that accumulates resolved-item narrative
indefinitely, not dated newest-on-top records. The file’s own header
already states the right remedy: “Open, actionable work only… for
history see `CHANGELOG.md`.” **Housekeeping section DONE – S529
(2026-08-12):** an inventory pass (background agent, full read of all
2,501 then-current lines) found 62 top-level items file-wide, 48 fully
resolved, ~1,500 compressible lines total, concentrated in 3 oversized
sections (Housekeeping, “Pedigree diagram vs kinship2,” “Genetic-metrics
PDF audit”). Scoped to Housekeeping only for this session (owner-picked
via `AskUserQuestion`, over top-15-file-wide / single-biggest-item /
prep-only alternatives) – self-contained, bounded by clean section
headers. All 17 of its 19 fully-resolved items compressed to the file’s
own established short-pointer convention; the 8 genuinely-open items
(incl. this one) left untouched. **2 items had NO existing
`CHANGELOG.md` entry at all** (a real ledger gap, FM \#27 – not just
verbose narrative): the `inst/extdata/` reorg (Sessions 415-418) and the
non-portable-filename fix (Session 497). Backfilled proper
`CHANGELOG.md` entries for both before compressing, rather than compress
to a dangling pointer that would have destroyed the only detailed
record. Net: Housekeeping 147→389 lines (263 removed); file total
2,501→2,238 (263 removed). Zero information loss verified by re-reading
the full compressed section end-to-end before close-out. **“Pedigree
diagram vs kinship2 audit follow-ups” section DONE – S530
(2026-08-12):** the 2nd of the item’s 2 remaining sections. Compressed
all 12 fully-resolved bulleted items (issues \#131/#134/#135/#139,
Option 2 layout feasibility/design/3 implementation slices, the
duplicate-node-arc fix, issues \#143/#144) to the file’s own
short-pointer convention, and condensed the ~375-line unbulleted
S480-S500 Progress-narrative chain (Tier 1 crash-bug fixes + \#145
spike + doc refresh; Tier 2 issues \#133/#136/#137/#145, all closed)
into one ~50-line consolidated summary retaining every session number,
design-doc path, and Learning cross-reference. Verified `CHANGELOG.md`
(+ its `docs/archive/CHANGELOG-through-*.md` shards) actually carries an
entry for all 31 session numbers cited before compressing to a pointer –
0 gaps found this time (unlike the Housekeeping section’s 2). All
Learning cross-references and all 11 cited
`docs/planning|audits|research/*` file paths confirmed to resolve. The 4
genuinely -open items (Candidate C’s connector idea; the 3
dangling-parent-crash-bugs and free-pass-filter pointers, both already
short; the node-count-off-by-one gap; the docstring-mismatch gap; the
`highlightNearest` degree=6 bound) left untouched. Net: section
896-\>286 lines (610 removed); file total 2,254-\>1,658 (596 removed,
after this session’s own S518-item progress notes added lines back
elsewhere in the file). Zero information loss verified by re-reading the
full compressed section end-to-end before close-out. **“Genetic-metrics
PDF audit follow-ups” section DONE – S531 (2026-08-12):** the 3rd and
last of the item’s 3 oversized sections. Compressed 8 fully-resolved
issue chains (#126/#127/#129/#130’s shared sequencing-decision bullet,
plus the individually-tracked \#147/#149/#146/#151/#150/#153
design-\>slice narrative chains) to the file’s own short-pointer
convention; also condensed the S479-S483 re-audit/sequencing context
note (still relevant – it names the still-open items) without losing any
issue number, tier assignment, or audit-doc pointer. Left the still-open
issue \#152 chain (design S517, Slice 1 S525, Slice 2 S526, Slice 3
next) fully untouched, matching the S529/S530 “leave open items
untouched” precedent. An early compression pass left a real duplication
defect – the \#153 chain’s design paragraph was replaced but its 3
slice-by-slice progress paragraphs (S520/S521-523/S524) were missed and
briefly duplicated the new compressed bullet – caught by this session’s
own end-to-end re-read before close-out and fixed by removing the
now-redundant paragraphs. Verified `CHANGELOG.md` (+ both
`docs/archive/CHANGELOG-through-*.md` shards) carries an entry for all
39 session numbers cited before compressing to a pointer – 0 gaps found.
All Learning cross-references and all 13 cited `docs/planning|audits/*`
file paths confirmed to resolve. Net: section 753-\>267 lines (486
removed); file total 1,658-\>1,173 (485 removed, some absorbed by this
item’s own progress-note growth). Zero information loss verified by
re-reading the full compressed section end-to-end before close-out.
**The S518 item is now fully RESOLVED – all 3 oversized sections
compressed across 3 sessions:** Housekeeping (S529, 147-\>389 lines),
“Pedigree diagram vs kinship2” (S530, 896-\>286 lines), “Genetic-metrics
PDF audit follow-ups” (S531, 753-\>267 lines). File total: 2,501 lines
(S529 start) -\> 1,173 lines (S531 end), a 1,328-line/53% reduction
across 3 sessions, with zero information loss at any step (each
session’s own end-to-end re-read plus CHANGELOG.md/Learning/file-path
cross-reference verification). See `CHANGELOG.md`. **Correction (S606,
2026-08-18): “fully RESOLVED” held only as a snapshot – a standing
topical section regrows as later sessions append their own progress
narrative to it, exactly the accumulation pattern this item’s own
opening paragraph names as the root problem.** Between S531 and this
session, 3 further issue \#152 slice-completion sessions (S532/S533/
S535) each appended their own multi-paragraph progress update to
“Genetic-metrics PDF audit follow-ups,” regrowing it from S531’s 267
lines back to 304 – with issue \#152 now fully closed (S535), unlike at
S531’s compression time (then still open, Slice 3 pending). Owner picked
this section for re-compression this session via `AskUserQuestion` (over
“Pedigree diagram vs kinship2” and “both sections”). Re-compressed: the
6 progress paragraphs (S517 design + Slices 1-5) condensed into 1
consolidated summary retaining every session number, design-doc path,
and Learning cross-reference. Also corrected 2 stale claims found in the
same pass, not just compressed around them: the section’s own intro
paragraph still said “#152 (Deferred) is in progress (Slice 3 next)”
(superseded by S535’s close); and the S535 paragraph’s own
“shinytest2/chromote headless-modal-rendering harness limitation”
finding was never corrected in place after `PROJECT_LEARNINGS.md`
Learning 542 (S536) retracted it as a test-pedigree-fixture defect
(missing `birth` column), not a harness limitation. Verified
`CHANGELOG.md` (+ its `docs/archive/CHANGELOG-through-*.md` shards)
carries an entry for all 6 session numbers cited
(S517/S525/S526/S532/S533/S535) before compressing to a pointer – 0 gaps
found (1 apparent gap, S492, was a search-pattern false negative: the
archive heading reads “Session 492,” not “S492”). All 6 cited
`PROJECT_LEARNINGS.md` Learning cross-references
(532/538/539/540/541/542) and the 1 cited `docs/planning/*.md` path
confirmed to resolve; issues \#152/#153’s CLOSED state independently
confirmed via `gh issue view`, not assumed from prose. Net: section
304-\>80 lines (224 removed); file total 1,881-\>1,657 (224 removed).
Zero information loss verified by re-reading the full compressed section
end-to-end before close-out. **“Pedigree diagram vs kinship2” (S530’s
own prior compression target) was NOT re-checked this session for the
same regrowth pattern** – out of this session’s own scope; a future
session should check whether it, too, has regrown since S530, and should
treat this item’s own “fully RESOLVED” framing as describing a recurring
maintenance need, not a one-time fix. See `CHANGELOG.md`.

(found S567, 2026-08-14, incidental to a
[`pkgbuild::build()`](https://pkgbuild.r-lib.org/reference/build.html)/tarball-content
check while resolving the kinship2 PDF’s `.Rbuildignore` classification,
**RESOLVED S568**. **The untracked “Compounding Loop” files were bundled
into every built package tarball**, unlike the reference PDFs this
project deliberately `.gitignore`/`.Rbuildignore`s. Investigated before
presenting the decision: the 3 real files (`.html`/`.pdf`/`.webarchive`)
turned out to be a saved Claude Artifact about this project’s own
`SESSION_RUNNER.md`/`SAFEGUARDS.md` methodology
(`github.com/KJ5HST/methodology`) – personal reference material, not
genetics/package content, but also not the same as the existing 4
gitignored files (those are copyrighted scientific papers). The 4th
file, `~$e Compounding Loop.html`, was confirmed via byte inspection to
be a content-less Microsoft/LibreOffice editor lock file (162 B, just
the owner’s own name in the binary lock-file format), not reference
material at all. Presented via `AskUserQuestion`: owner picked
“gitignore + `.Rbuildignore` in place,” matching the established
precedent (over moving the files out of `inst/extdata/reference/`
entirely, tracking+shipping them, or deleting them outright); the lock
file was deleted unconditionally (never committed, confirmed via
`git log -- <file>` returning empty, zero content value). Verified via
an actual
[`pkgbuild::build()`](https://pkgbuild.r-lib.org/reference/build.html) +
tarball-content inspection that all 3 real files are now excluded (the
NIHMS precedent and the 1 tracked exception both re-confirmed
unaffected); `git check-ignore -v` confirms all 3 match the new
`.gitignore` rule.
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html):
0 errors, 0 warnings, 0 notes – this also resolved the long-standing
“checking for portable file names” WARNING every recent session had been
carrying forward as pre-existing (these exact files were its cause).
Incidental finding logged, not fixed: an empty
`inst/extdata/reference/untitled folder` directory (dated the same day
as the Compounding Loop files) surfaced during this session’s own
build-log inspection – new Housekeeping item below. See `CHANGELOG.md`.)

(found S568, 2026-08-14, incidental to this session’s own
[`pkgbuild::build()`](https://pkgbuild.r-lib.org/reference/build.html)
verification, Effort S, not fixed this session) **An empty, untracked
`inst/extdata/reference/untitled folder` directory** (dated 2026-08-13,
the same day as the now-resolved “Compounding Loop” files) sits in the
package source tree – `R CMD build` silently drops it during staging
(“Removed empty directory…”), so it has no build-correctness impact, but
it’s a stray Finder artifact with no content. A future session should
confirm with the owner it’s safe to delete and remove it (no
`.gitignore`/`.Rbuildignore` entry needed for an already-build-dropped
empty directory – just a filesystem cleanup).

## Pedigree diagram vs kinship2 audit follow-ups (from ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md)

*S435’s capability-comparison audit
(`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`)
compared the just-shipped issue \#129 pedigree-diagram feature against
kinship2’s pedigree-drawing feature set (17-point checklist, 8 findings,
8 recommendations). Triaged S436 (2026-07-30) via explicit owner
direction (free-text, not per-item `AskUserQuestion` picks): **all 8
recommendations** filed as GitHub issues, tracked there, not here –
including Recommendations 4-7, which the audit itself scored “no action”
(data-model-gated, or an already-ratified Dragon-P3 scope tradeoff);
filing tracks the idea for future consideration and does not reverse the
audit’s own assessment (each issue body preserves the audit’s original
disposition text verbatim). Owner set an explicit priority order that
**inverts** the audit’s own suggested ordering (which rated Finding \#1
highest): **\#131** (diagram image/print export, Finding \#3/Rec \#2,
priority 1) – **\#132** (in-app shape-to-sex legend, Finding \#6/Rec
\#3, priority 2, also resolves plan Dragon P5) – **\#133**
(affected/phenotype/genotype status encoding, Finding \#2/Rec \#4,
priority 3, data-model gated) – **\#134** (verify
inbreeding-loop/consanguinity rendering, Finding \#1/Rec \#1, priority
4, resolves plan Dragon P2 / `PROJECT_LEARNINGS.md` Learning 410) –
**\#135** (hover tooltips + search/highlight, Rec \#8, priority 5) –
**\#136** (name labels instead of ID-only, Finding \#8/Rec \#7, priority
6, data-model gated) – **\#137** (twin/zygosity encoding, Finding
\#5/Rec \#5, priority unranked by the owner, placed 7th as an inference
not a stated decision) – **\#138** (full-colony rendering beyond the
1,500-node cap, Finding \#7/Rec \#6, priority 8 – explicitly
deprioritized/delayed by the owner, `low priority` GitHub label
applied). Owner also directed (mid-session, 2026-07-30) a broader goal:
overlay kinship2’s genetics-domain naming conventions onto the pedigree
data model where applicable when these are implemented, and build test
pedigree fixtures with the corresponding added columns – folded into
\#133 (kinship2’s `affected` argument convention) and \#137 (kinship2’s
`relation` argument convention), the two data-model-adding items. Owner
also directed that any plan implementing one of \#131-#138 must include
a documentation phase (`vignettes/articles/ colony-manager-guide.qmd`
and/or `vignettes/manual_components/_pedigree_browser.Rmd`), now
recorded as `CLAUDE.md`’s “Tutorial/article documentation checklist” –
checking whether this was already true for the base feature found it was
not: **issue \#139** tracks that issue \#129’s already-shipped Diagram
tab has zero tutorial/article coverage today. See `PROJECT_LEARNINGS.md`
Learning 411 and `CHANGELOG.md` for the full S436 triage record. None
imply reopening issue \#129 or revisiting the visNetwork-vs-kinship2
technology decision (D2), which stands as ratified.* - \[ \]
(feasibility planning DONE – S457, 2026-08-02, see
`docs/planning/pedigree-diagram-mating-lines-plan.md`. **Pedigree
Diagram tab does not visually indicate mating/couple relationships**
(owner-observed S456, citing kinship2-convention references) – confirmed
empirically (3 `visNetwork` POCs via `chromote`) that a true
kinship2-style mate-line + sibship-bar convention is achievable inside
the ratified visNetwork (D2) choice via invisible union/waypoint nodes
with hand-computed coordinates. Owner ratified **Option 2 – full
kinship2-parity layout on visNetwork** via `AskUserQuestion`, over
reopening D2/switching to kinship2 or a smaller partial-repositioning
step. See `CHANGELOG.md`.) - \[ \] (design DONE – S458, 2026-08-02, see
`docs/planning/pedigree-diagram-option2-layout-design-plan.md`.
**Pedigree Diagram: full kinship2-parity layout (Option 2 design
session)** – designed and owner-ratified a mating-unit/individual
-duplication transformation (CraneFoot-derived) resolving
crossing-minimization ordering, multi-mate/half-sib fan-out, and
inbreeding-loop safety via one mechanism; a simplified
Reingold-Tilford/Walker contour-merge algorithm (not an off-the-shelf
package – `igraph`/`ggraph` are GPL) computes final coordinates. Owner
ratified via `AskUserQuestion` with one editorial direction:
non-human-centric terminology (`sire`/`dam`/`mate`/`mating`). See
`CHANGELOG.md`.)

**Sequencing note (S480, 2026-08-08):** the items below through the
`highlightNearest` degree=6 item, plus GitHub issues
\#133/#136/#137/#138/#141/#145, were jointly examined for implementation
order in
`docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`
(kinship2-capability- and nomenclature-reference-informed). Recommended
order: (1) the two dangling-parent crash bugs below + the
free-pass-filter reachability check, (2) issue \#145’s verification
spike, (3) refresh the stale `.qmd` comparison doc below, (4) the
owner’s existing \#133 \> \#136 \> \#137 \> \#138 order, (5) \#141 and
Candidate C stay deferred pending new evidence/owner sign-off.

**Tier 1 – DONE (S481, S482, S484):** the 2 dangling-parent crash bugs +
the free-pass-filter reachability check were filed and fixed as issue
\#154 (S481). Issue \#145’s verification spike (S482,
`docs/research/issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md`)
empirically confirmed (kinship2 v1.9.6.2 source read + 5
synthetic-pedigree tests, not inferred from docs) that kinship2
implements **neither** a hard male-left invariant **nor** a sex-aware
crossing-minimizing default – once an individual has multiple mates,
left/right is decided purely by pedigree-data discovery order; the
issue’s own cited sources were found unreliable on this point.
`docs/planning/pedigree-diagram- kinship2-reference-comparison.qmd` was
refreshed (S484) to reflect issues \#143/#144’s fixes and to add a new
Example 4 reproducing S482’s own kinship2 counter-example directly
(`quarto render` clean, 37 chunks).

**Tier 2 – DONE (S485-S494, S499-S500): issues \#133, \#136, \#137, and
\#145 are all now fully implemented and closed.** Each followed
design-document ratification (`AskUserQuestion`-gated judgment calls)
then 1-3 implementation slices, each slice a full strict-TDD
PRE-RED-\>RED-\>GREEN (-\>REFACTOR) cycle with clean regression +
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) +
live `shinytest2`/`chromote` verification, plus the
citation/tutorial/`NEWS.Rmd`/`a2interactive.Rmd` documentation
checklists applied per-slice: - **Issue \#133** (affected/phenotype
status): design S485
(`docs/planning/issue133-affected-status- pedigree-diagram-plan.md` –
new `affected` logical column, `color.background` + tooltip, no new
dependency). Slice 1 (data model + rendering) S486 – found and fixed a
gap where the rectilinear edge style would have silently erased the new
coloring. Slice 2 (legend + docs) S487. **Closed S487.** - **Issue
\#136** (name labels): design S488
(`docs/planning/issue136-name-labels-pedigree-diagram- plan.md` –
corrected 3 premises in the issue itself; found and closed a disclosure
defect,
[`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)
would have left `name` unscrubbed). Slice 1 (data model +
de-identification) S489. Slice 2 (label rendering + off-by-default
toggle + docs) S490 – found and fixed a real
toggle-discarded-on-rerender defect via live verification
(`PROJECT_LEARNINGS.md` Learning 490). **Closed S490.** - **Issue
\#137** (twin/zygosity encoding): design S491
(`docs/planning/issue137-twin-zygosity- pedigree-diagram-plan.md` – new
sidecar `twinRelations` table, zero schema.R changes; a
workflow-truncation tooling defect found and worked around,
`PROJECT_LEARNINGS.md` Learning 491). Slice 1 (data model +
de-identification,
[`checkTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)/[`obfuscateTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateTwinRelations.md))
S492. Slice 2 (core rendering, MZ/DZ/UZ connector styles) S493. Slice 3
(UI wiring, legend, docs) S494 – found and filed (not fixed) a Slice 2
color-wiring gap as its own Housekeeping item. **Closed S494.** -
**Issue \#145** (sire/dam left-right placement, deferred from Tier 1’s
spike): design S499
(`docs/planning/issue145-sire-dam-left-right-placement-plan.md` – a
3-agent adversarial review refuted the first proposed mechanism,
`orderBySex = TRUE` parameter ratified instead). Slice 1 (core
positioning) S500. **Closed S500** for the ratified simple-pair scope.

**Issue \#138** (full-colony rendering beyond the 1,500-node cap) is the
one item in the owner’s Tier 2 order this cluster did not reach – still
open, tracked as its own GitHub issue (`low priority` label), needing
its own scoping session first, matching \#133/#136/#137/#145’s own
precedent. See `CHANGELOG.md` for the full session-by-session record and
`PROJECT_LEARNINGS.md` Learnings 485, 488-499 for the individual
technical findings. - \[ \] **Candidate C’s connector/dogleg
visual-signposting idea** (found S473, designing the issue \#144 plan;
not adopted for \#144 itself, Effort unknown, low priority) – extends
the existing D2 mate-line “dogleg” (issue \#142) to `edgeStyle="direct"`
(which currently gets zero compensating treatment for any
cross-generation connector) and adds dashed/colored/titled styling to
both edge styles so a multi-generation-spanning mate-line reads as
intentional rather than a positioning bug. Fully validated (including a
real ~37% `edgeStyle="rectilinear"` performance regression found and
fixed during design) but requires its own fresh, explicit owner
product-level sign-off to pursue – independently valuable as a
diagram-readability enhancement, decoupled from \#144’s own resolution
(which does not need it). See
`docs/planning/issue144-anchor-row-mismatch-fix-plan.md` §5/§8. **Also
considered and again not adopted for the kinship2-fidelity remediation
plan’s Track 4 (design S572, implemented S573, 2026-08-14)** – Track 4
ratified and shipped Candidate A (gen-aware D2 anchor selection)
instead, see
`docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` §3/§8.
Live-rendered (S573, both `edgeStyle` values, zero console errors) with
the redistribution this decision predicted (duplicate nodes 128-\>102,
multi-anchor individuals 2-\>22, max 5). Still not precluded – remains
open as a future, separately-scoped enhancement if the owner judges,
from that live render, that remaining cross-generation mate-lines still
benefit from signposting for legibility. - \[ \] **The live app’s
uploaded/QC’d copy of `obfuscated_rhesus_mhc_ped.csv` produces one fewer
node than reading the same bundled CSV directly** (found S472,
incidental to issue \#143’s live verification, Effort unknown, low
priority) – `direct`-style Diagram node count is 739 live vs. 740 via
[`read.csv()`](https://rdrr.io/r/utils/read.table.html) +
`.buildMatingUnitForest()`/ `.positionMatingUnitForest()` directly (a
stable, already-tested figure, unaffected by this session’s fix); the
live rectilinear -style projection-node count is correspondingly 50
vs. an offline -computed 51. Not investigated further this session (out
of the issue \#143 fix’s own scope, per `PROJECT_LEARNINGS.md` Learning
382’s “report, don’t fix mid-session” precedent) – most likely explained
by the upload/QC pipeline (`modInput.R`’s
[`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
or similar) dropping or merging exactly one row relative to a raw
[`read.csv()`](https://rdrr.io/r/utils/read.table.html), but this was
not confirmed. A future session should identify which individual differs
and why, and decide whether the app’s own bundled -fixture test coverage
(`test-e2e-pedigree-module.R`, etc.) should assert this QC’d count
explicitly rather than relying on the raw-CSV-read count as a proxy for
what the live app actually renders. - \[ \]
**`data-raw/rhesusPedigree.R`’s docstring claims
`rhesusPedigree_fromCenter.csv` is an independent raw/pre-obfuscation
source for `obfuscated_rhesus_mhc_ped.csv`, but the two shipped fixtures
are byte-identical on every shared column** (found S470, incidental to
the founder-positioning audit above, Effort S, low priority) – confirmed
via [`identical()`](https://rdrr.io/r/base/identical.html) on
`id`/`sire`/`dam`/`sex`/`gen`/`birth`/`exit`/`age` between the two
files; `rhesusPedigree_fromCenter.csv` differs only by one added
`fromCenter` column (all `TRUE`). The documented
[`obfuscatePed()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscatePed.md)
id/date-obfuscation transform was evidently never applied to produce
this particular fixture, or produced a no-op. Not fixed this session
(reported per `PROJECT_LEARNINGS.md` Learning 382’s “report, don’t fix
mid-session” precedent – out of the founder-positioning audit’s own
scope). A future session should reconcile the docstring against the
shipped fixture (or regenerate `rhesusPedigree_fromCenter.csv` to match
the documented provenance). See
`docs/audits/FOUNDER_POSITIONING_DEFECT_AUDIT_2026-08-03.md` Finding
\#4, `PROJECT_LEARNINGS.md` Learning 468. - \[ \] **`highlightNearest`
degree=6 mitigation for the rectilinear style is bounded, not a full
fix** (found S468, Effort M, low priority) – a very wide sibship’s D1
sibship-bar chain can exceed 6 hops (chain length scales with the number
of children in one mating unit), so a hover on an individual in a very
large family could still light up nothing visible. A full fix would need
either a custom JS `highlightNearest` reimplementation that specifically
skips through invisible waypoint nodes regardless of hop count, or a
data-layer change that keeps degree-1 semantics correct (e.g. tagging
waypoint edges so a custom traversal treats them as zero-cost hops). Not
designed this session – the degree=6 mitigation was explicitly scoped as
a quick, bounded fix, owner-directed via `AskUserQuestion`. A future
session should measure the real fixture’s own maximum sibship size to
gauge how often 6 hops is actually insufficient in practice before
deciding whether a full fix is warranted.

## Outreach

**NPRC outreach & announcement plan** (DECISION NEEDED – owner
review/edit of drafts + send timing; Effort N/A, not a coding task) –
plan complete: `docs/planning/nprc-outreach-announcement-plan.md` (S413,
owner-directed, not from this backlog). Covers audiences (the NPRC
Genetics and Genomics Working Group, plus each of the 7 centers’
colony-manager/veterinarian contacts), tailored messaging, channels, a
sourced 7-center contact roster (director + colony-manager/
head-veterinarian-equivalent + genetics contact per center, each with a
source), a generic timeline, 5 named risks, and ready-to-edit draft
materials (WG email, colony-manager/vet email, one-page feature summary,
presentation outline). Two items remain genuinely unresolved after
dedicated research, not just undone: the Working Group’s current (2026)
chair could not be confirmed (recommended action: ask
`support@nhprc.org` directly, see the plan’s §3/§8); and a
colony-manager contact could not be named at 3 of 7 centers (Southwest,
Tulane, Washington – the role is undocumented by name on each center’s
own site). **Next steps are owner-executed, real-world actions**
(review/edit the drafts, confirm exact recipients, send) per the plan’s
own §7 – pick this up in a future session only if the owner wants help
drafting a specific follow-up, not as a general “send the emails” coding
task. See `CHANGELOG.md`.

## Architecture (issue \#122 / XARCH-2 – module contract)

*Resolved – S372 planning session through S377 execution (Phases 1-5,
all DONE); see `CHANGELOG.md` for the per-phase detail (S373
vocabulary-composition fix, S374 kinship dedup, S375 vocabulary
collapse, S376 dead-surface pruning, S377 contract doc + guard test).
The living contract is `docs/architecture/module-contract.md`; it is
enforced by `tests/testthat/test_moduleContract.R`. `modInput` is the
reference implementation.*

## Documents (v1.0.8 -\> v2.0.0 write-up)

## Audit follow-ups

*(From `PED_GV_AUDIT_2026-05-30.md`; all audit follow-up items are now
resolved — see `CHANGELOG.md`. Per-item reachability notes and traps
live in `CLAUDE.md` “Project-specific Learnings”.)*

## Genetic-metrics PDF audit follow-ups (from GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md)

*S419’s capability-comparison audit
(`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md`)
compared the package against the 2015 NHP Genetics and Genomics Working
Group PDF and found 12 missing / 9 partial findings (of 37 total).
Triaged S422 (2026-07-29) via owner `AskUserQuestion` picks – all 6
findings/clusters owner-directed to file as GitHub issues, tracked
there, not here: **\#125** (configurable ranking-priority scheme +
surface multiple breeding-group candidates, Dimensions 1 & 2), **\#126**
(kinship/genome-uniqueness distribution shape statistics – skewness,
kurtosis, Dimension 3), **\#127** (surface
`correctUnknownParentMeanKinship()`’s silently-dropped `flagged` list,
Dimension 4), **\#128** (breeding-group exclusion is top-N rank-based,
not a genetic-value floor, Dimension 2), **\#129**
(pedigree-diagram/tree visualization, currently table-only, Dimension
7), **\#130** (marker-based
kinship/heterozygosity/parentage-verification + cross-center identity
resolution, Dimensions 5 & 6). 1 finding (NGS/whole-genome/MHC-specific/
linkage-disequilibrium methods, Dimension 5) declined, no action – the
source PDF itself frames these as speculative future work even in 2015,
matching the audit’s own Recommendation \#5. The remaining findings
(PMX/MateRx/Pedscope/PedSys tool-comparison notes, the “make pedigree
available to researchers” governance recommendation) are descriptive or
already-adequately-served, not gaps requiring tracking. See
`CHANGELOG.md`.*

**Second-generation re-audit and issue-sequencing (S479-S483, 2026-08-05
to 2026-08-08):** a ghost session (reconciled S479,
`PROJECT_LEARNINGS.md` Learning 479) produced 2 further capability
audits
(`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`,
`..._2026-08-06.md`) and filed 8 new GitHub issues: **\#146**
(configurable/exhaustive breeding-group candidate retention), **\#147**
(likelihood-based candidate-parent assignment), **\#148** (MHC
haplotype-specific frequency reporting), **\#149** (cross-center
identity-mapping workflow with provenance export), **\#150**
(de-identified pedigree export workflow), **\#151** (individual
mate-pair analysis), **\#152** (whole-genome/whole-exome sequence
input + sequence-based metrics), **\#153** (linkage-aware/
haplotype-block metrics). Sequencing ratified S483
(`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md`,
owner-directed, 8-agent codebase-grounded workflow): Tier 1 \#147; Tier
2 \#149 \> \#146 \> \#151; Tier 3 (policy-gated) \#150; Deferred
(design-only) \#152 \> \#153 \> \#148, with \#148 flagged as needing its
own scope-narrowing conversation first (filed broader than the audit
recommends). **Also found, still not filed as of this compression:** 2
audit-table High-priority rows – “Longitudinal genetic-health
monitoring” and “Ancestry guardrails in breeding decisions” – have no
corresponding GitHub issue, despite ranking above every Medium/Deferred
item in this batch (Finding \#1/Recommendation 2); a future triage
session should file both. **Every Tier 1/2/3 item (#147, \#149, \#146,
\#151, \#150) plus Deferred-tier \#152 and \#153 are now fully shipped
and closed** – see the compressed entry below. \#148 remains unstarted,
still needing its scope-narrowing conversation. See `CHANGELOG.md`.

**Progress, issue \#152 (whole-genome/whole-exome sequence input +
sequence-based genetic metrics) – DONE, closed (design S517 through
close-out S535, Sessions 517-535).** Design ratified S517
(`docs/planning/issue152-sequence-input-genetic-metrics-plan.md` – two
parallel background research agents plus direct verification of the
load-bearing prior Bioconductor -Imports decline): sparse/GBS-scale
scope tier (~50,000-locus ceiling); a shared `locusMetadata`
(`locus, chrom, pos[, cM]`) sidecar reused by sibling issue \#153;
genome-wide F_ROH (new, Ceballos et al. 2018) plus genome-scale reruns
of the existing kinship/heterozygosity/Fst functions; a new tab inside
the existing `modMarkerGenetics.R` rather than a dedicated module.
Scoped as 5 vertical slices, each its own session, each a full
strict-TDD PRE-RED-\>RED-\>GREEN(-\>REFACTOR) cycle gated by
`AskUserQuestion`: - **Slice 1** (S525): new
[`checkSequenceGenotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkSequenceGenotypeFile.md)
structural validator (reuses issue \#153’s
[`checkLocusMetadata()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md));
`data-raw/generate_sequence_fixtures.R` (seeded 50-individual x
1,000-locus synthetic biallelic SNP panel + `locusMetadata` sidecar,
committed as `inst/extdata/examples/example_sequence_*.csv`). - **Slice
2** (S526):
[`markerKinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerKinship.md)/[`markerParentageLikelihood()`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageLikelihood.md)
performance rewrite – vectorized matrix algebra / precomputed per-locus
allele-frequency tables – _(2x/)2.4x speedups, output unchanged
(golden-master +
[`system.time()`](https://rdrr.io/r/base/system.time.html) benchmark
regression tests; the median-of-3 -reps timing-stability fix is
`PROJECT_LEARNINGS.md` Learning 532). - **Slice 3** (S532): new
[`computeGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/computeGenomicROH.md)
F_ROH metric (Ceballos et al. 2018 convention), reuses
[`checkLocusMetadata()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md)’s
coverage classification. `PROJECT_LEARNINGS.md` Learning 538 (a
lower-than-baseline
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
NOTE count needs the same direct verification as a higher one)
originates here. - **Slice 4** (S533): new
[`obfuscateGenotypeMatrix()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenotypeMatrix.md)
de-identification primitive, mirrors the established `obfuscate*` family
pattern. `PROJECT_LEARNINGS.md` Learning 539 (verification tools must be
invoked with the project’s own default config/args, not an override)
originates here; found (not fixed) the `.Rbuildignore`
`methodolog_trim.py` typo, fixed next session (Learning 540). - **Slice
5** (S535, closes \#152): new “Genomic ROH (F_ROH)” tab in
`R/modMarkerGenetics.R` (curator confirm-gate export: de-identified
genotype matrix + F_ROH table + manifest), new
[`obfuscateGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenomicROH.md).
Live Phase 3E verification found and fixed a real bug –
`sequenceRohTable` fed `locusMetadata()`’s
already-[`checkLocusMetadata()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkLocusMetadata.md)-processed
output back into
[`computeGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/computeGenomicROH.md),
which re-runs that same check internally, silently mislabeling a column
(`PROJECT_LEARNINGS.md` Learning 541). S535 also suspected a
`shinytest2`/`chromote` headless-modal-rendering harness limitation
blocking the export-confirm modal – **`PROJECT_LEARNINGS.md` Learning
542 (S536) corrects this: there was no harness limitation, the real
cause was a test pedigree fixture missing the required `birth` column,
which silently blocked `req()` upstream of `showModal()`; fixed by
completing the fixture.**

Each slice: full clean regression 0 failed/0 error,
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
clean modulo pre-existing NOTEs, citation/`NEWS.Rmd`/`_pkgdown.yml`
checklists applied per-slice (tutorial/article checklist satisfied at
Slice 5; `a2interactive.Rmd` deferred per its own standing rule). See
`CHANGELOG.md` for the full session-by-session record.
