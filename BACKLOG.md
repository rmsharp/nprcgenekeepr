# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

## Active
- [x] **Planning session: address the shared "no collision-avoidance for same-row placement" root
      cause behind issues #160, #161, and the S583 union-position gap** (found 2026-08-15,
      incidental to this conversation's own live kinship2-fidelity review) — **DONE S592
      (2026-08-15).** A 12-agent research/design/judge `Workflow` produced 4 independently-scored
      candidate architectures (no single one won on all 3 judge lenses); synthesized into a
      3-track phased plan, owner-ratified via `AskUserQuestion`:
      [`docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`](docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md).
      Track 1 (D1 sibship-bar geometric row offset — unconditional guarantee, closes issue #160's
      2 originally-reported collisions), Track 2 (general same-row detect-and-jog framework, wired
      into `makePedigreeMatingLayout()` itself — closes issue #160 comment 1's broadened finding),
      Track 3 (parent-span clamp on `finalUnitX`, its own PRE-RED reopening gate — closes S583).
      Issue #161 addressed with a recommendation to defer (plan §2.5). The underlying
      duplicate-occurrence-selection root-cause fix (plan §2.4) is named, evidence-gathered, but
      deliberately deferred, not scheduled. See the 3 new READY items directly below for the
      implementation sessions this plan produced.
- [x] **Implement Track 1 (D1 sibship-bar row offset)** (found S592, Effort S) — **DONE S593
      (2026-08-15).** Plan §2.1/§6 Session A:
      [`docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`](docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md).
      `sibshipBarFraction = 0.4` constant added to `.addRectilinearWaypoints()`'s D1 loop
      (`R/makePedigreeDiagramData.R`); bar/drop waypoints now land on a genuine intermediate row
      instead of the child's own row. Reproduced issue #160's 2 originally-reported collisions
      byte-for-byte against the actual `kinship2::sample.ped` family 2 fixture cited in the
      collision-avoidance plan's own evidence (`204`=-270/`205`=-150/`__union_2`=-210,
      `209`=210/`__bar_207`=90/`__bar_208`=390) — both cleared. Correction to the plan's own
      estimate: only 2 test blocks (not ~11) hardcoded `y == childY`; direct inspection, not the
      inherited count, governed the actual test update. **Found during implementation, not
      anticipated by the plan:** no single fixed rational `sibshipBarFraction` is collision-free
      for every possible generation gap (a `p/q` fraction coincides with a pinned row whenever the
      gap is a multiple of `q`) — confirmed empirically on the real 375-individual bundled fixture
      (1 gap-5 D1 group, 2/488 waypoints). Owner-directed: disclosed and counted in the test suite
      rather than hidden by a weaker assertion; deferred to Track 2 below, which is gap-agnostic.
      **Second residual, matching S592's own flagged gotcha** (plan §8, checked this session per
      that handoff's explicit instruction): 2 different sibships sharing a generation gap can still
      land their bars on the identical row if their x-ranges overlap (a bar-vs-bar collision, not
      bar-vs-node). Track 1 substantially reduces this — the offset depends on both the parent's
      and child's own row, not just the child's, splitting most same-generation sibships onto
      different rows — but does not eliminate it: 42 such cases pre-Track1, 9 post-Track1 (79%
      reduction) on the real fixture. Also counted in the test suite; also deferred to Track 2.
      Full clean regression: 0 failed/0 error. `lintr::lint_package()`: no lints. Issue #160 not
      yet closed — Track 2 still required for the comment-1 duplicate-connector finding and both
      disclosed residuals above.
- [x] **Implement Track 2 (general same-row detect-and-jog framework)** (found S592, Effort L) —
      **DONE S595 (2026-08-15).** Plan §2.2/§6 Session B:
      [`docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`](docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md).
      New `.resolveEdgeNodeCollisions(nodes, edges)` (`R/makePedigreeDiagramData.R`), wired into
      `makePedigreeMatingLayout()`'s existing `edgeStyle == "rectilinear"` branch (not just the
      Shiny layer) so every caller benefits identically. Detection: strict interior containment on
      same-row (`y1==y2`), non-curved edges, excluding the edge's own 2 endpoints and any node
      directly graph-adjacent to either (derived from the edge graph alone, no `forest` parameter
      needed — correctly excludes a bar's own child even in Track 1's disclosed p/q-coincidence
      residual). Repair: a strictly rectilinear 2-waypoint "step" (`u -> J1 -> J2 -> v` at a
      parallel offset row), never a diagonal; new `__jog_` ids joining the reserved node-id-prefix
      set (`vignettes/a2interactive.Rmd:500` — deferred to that vignette's own standing checklist,
      not updated this session). The curved duplicate connector gets its own disclosed
      `smooth.roundness`-bump heuristic branch instead (rerouting it through rectilinear waypoints
      would destroy its established arc styling) — confirmed by rendered-image inspection
      (`chromote`), not coordinate math alone: visually clears the reported obstacle in the exact
      issue #160 comment-1 `P1`/`X`/`A`/`Y`/`W`/`C1`/`GC`/`C2` reproduction.
      **Found during implementation, not anticipated by the plan:** the real 375-individual bundled
      fixture already had 150 of 725 straight same-row edges (20.7%) colliding pre-fix — 3,081
      total edge-obstacle pairs, overwhelmingly (139/150) ordinary kept parent-to-union mate edges
      spanning a wide, many-founder generation-0 row (up to 89 simultaneous obstacles on one edge),
      not D1 bars (5) or D2 doglegs (0 — confirmed structurally unreachable under Track 4 + issue
      #143's shipped invariants, so the RED test's own "D2-dogleg-leg" fixture is a hand-built
      synthetic exercise of the general detector, not a pipeline reproduction). Owner-directed
      (`AskUserQuestion`) to fold this into Track 2 unchanged rather than re-scope. **2 real bugs
      found and fixed mid-REFACTOR, both via empirical/visual verification, not assumed:** (1) a
      single shared `jogY` offset for every colliding edge at one row created 132 NEW jog-vs-jog
      collisions among the repair waypoints themselves (150 → 184 residual edges, the opposite of a
      repair) — fixed with interval-scheduled multi-level jogging (greedy graph-coloring by x-span
      overlap), reducing straight-edge residuals to **0**; (2) an earlier version blanket-reset
      every replacement edge's `color` to the generic waypoint color, silently destroying a twin
      connector's or consanguinity marker's own identity — caught by the full regression
      (`test_makePedigreeMatingLayout.R`'s own twin-connector suite), fixed by copying every column
      from the original edge onto all 3 replacement segments (matching the established D2-dogleg
      color/width-preservation precedent, Track C/S563). Final real-fixture measurement: 150 → 0
      straight-edge residuals (1,202 → 1,502 nodes, 300 `__jog_` waypoints); 52 curved-heuristic
      residuals remain (disclosed, unconfirmed-by-coordinate-math nudges — the curved connector's
      own gen can differ from its real occurrence's, so not every one collides with something a
      rectilinear reroute could help). No id-based/character `order()` introduced (all sorting is
      numeric, `y`/`x`/`lo`), so the locale-determinism verification item (plan §7.5) is N/A this
      track. `devtools::check()`: 0 errors/0 warnings/1 pre-existing NOTE (`vignettes/figure/`);
      full clean regression 0 failed/0 error (2 initially-flagged failures in
      `test_markerKinship.R`/`test_markerParentageLikelihood.R` confirmed transient/unrelated —
      pass cleanly in isolation, timing-sensitive benchmarks untouched by this diff);
      `lintr::lint_package()`: no lints. `test_makePedigreeMatingLayout.R`'s own node-count and
      twin-connector golden-value tests updated to reflect the real, disclosed behavior change (not
      silently left broken). Closes issue #160 comment 1's broadened finding; issue #160 closed
      this session citing both Session A (S593) and this session's evidence.
- [x] **Implement Track 3 (S583 parent-span clamp)** (found S592, Effort M) — **DONE S596
      (2026-08-16).** Plan §2.3/§6 Session C:
      [`docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`](docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md).
      New clamp loop in `.positionMatingUnitForest()` (`R/makePedigreeDiagramData.R`): after the
      existing `finalUnitX` (child-centered midpoint) computation, each union's x is clamped into
      its own 2 parents' `[min, max]` range whenever the formula would otherwise place it outside
      that span — a disclosed, owner-ratified reopening of Track 6 §2.4's "unconditionally"
      wording (S592 §9, re-confirmed via this session's own PRE-RED `AskUserQuestion` per the
      plan's own additional gate). Skips a union whose sire or dam has no node of its own (a
      dangling free-pass reference) rather than propagating `NA` — found live this session,
      regressed 2 pre-existing tests before the guard was added. Reproduced BACKLOG's own S583
      example byte-for-byte via `trimPedigree(c("8LKBV9","FJIB3R","GA204Z"), ped)` against the
      real 375-individual bundled fixture (`__union_1` 120→60, now inside `[-60,60]`), plus the
      9-subject `P1/P2/A/Y/X/W/C1/C2/GC` consanguineous fixture BACKLOG names ("3 more times").
      **2 disclosed trade-offs found during REFACTOR, both owner-accepted via `AskUserQuestion`
      (not fixed this session):** (1) the plan's own §7 faithful child-centering metric worsens —
      9 of 251 child edges exceeded the 200-unit threshold pre-fix, 53 post-fix (max offset
      4,121→10,627) — a mechanical consequence of clamping a union off its child-centered
      position; (2) the already-disclosed D1 bar-vs-bar x-overlap residual (plan §8) worsens
      substantially — 42→348 pre-Track-1-equivalent baseline hits, 9→116 post-Track-1 hits — since
      pulling a runaway union back toward its own parents moves its sibship bar's drop point back
      into the x-region other relatives' subtrees occupy. Both trade for a higher-priority fix
      (parent-span containment / kinship2 parity). A beneficial side effect: Track 3 also reduces
      Track 2's own same-row collision baseline (150→105 edges, −30%; 3,081→1,431 obstacle-pairs,
      −53%; node count 1,502→1,412). Updated `test_positionMatingUnitForest.R` (2 new tests + the
      Track 6 §2.4 invariant loosened to "formula OR clamped," 2 pre-existing golden-value tests
      corrected), `test_resolveEdgeNodeCollisions.R`, `test_makePedigreeMatingLayout.R`, and
      `test_addRectilinearWaypoints.R` (all disclosed, behavior-driven churn, not silent). Full
      clean regression: 0 failed/0 error. `devtools::check()`: 0 errors/0 warnings/1 pre-existing
      NOTE. `lintr::lint_package()` on touched files: 0 lints. See the follow-up item below for the
      2 accepted trade-offs, filed per plan §8's own "file it as its own issue if found"
      instruction.
- [x] **Pedigree Diagram: rectilinear sibship bar can visually imply false parentage** (found live
      in conversation 2026-08-15, not a claimed session, filed as
      [issue #160](https://github.com/rmsharp/nprcgenekeepr/issues/160)) — **RESOLVED S595
      (2026-08-15), closed citing both Session A (S593, Track 1) and Session B (S595, Track 2)
      evidence.** Root-cause plan written S592 (see the 2 DONE implementation items above).
      Reproduced on the "cleanest comparison" 14-person fixture (no multi-mate ambiguity), 2
      independent collisions found in one render; not fixed here. **Update (same day):** a second,
      more severe reproduction (P1&times;P2's own
      union landing entirely outside their span, plus a duplicate-connector line rendering behind
      an unrelated node) traced the root cause one level deeper — see the issue's comment thread.
      The defect is broader than the sibship-bar D1 loop alone: any straight same-row edge
      (sibship bar OR duplicate-connector) can collide with an intervening unrelated node.
- [ ] **Pedigree Diagram: consider hiding the mating-unit node marker to match kinship2's
      plain-intersection convention** (found live in conversation 2026-08-15, not a claimed
      session, filed as [issue #161](https://github.com/rmsharp/nprcgenekeepr/issues/161)) —
      **addressed S592: recommend deferring** until Tracks 1-3 above ship and stabilize (plan
      §2.5) — hiding the marker would make any remaining, not-yet-repaired same-row collision
      harder to spot, not easier, while the collision-avoidance framework is still unproven on the
      real fixture. Mechanically easy (the `size = 0` + transparent-color technique already used
      for invisible D1/D2 waypoints applies directly) but a genuine design call, not an obvious
      fix — the dot may be a useful explicit anchor independent of kinship2 parity. Still needs a
      final decision before implementation, just not this session. **Tracks 1-3 all shipped as of
      S596 (2026-08-16)** — the deferral condition this recommendation named is now satisfied; a
      future session may pick up the #161 decision itself, though "stabilize" (S592's own word) may
      warrant some observation first given Track 3's own disclosed trade-offs (see the follow-up
      item below).

- [ ] **Track 3's 2 disclosed trade-offs (child-centering quality, D1 bar-vs-bar overlap) — accept
      as shipped, or investigate a narrower mechanism** (found S596, 2026-08-16 — **child-centering
      half: S602 (2026-08-17) implementation RETRACTED as a fix S603 (2026-08-18), verified to
      produce no visible correction; single-child union/parent-coincidence sub-thread (S608-609)
      redirected to a full algorithm-family redesign, **now SCOPED and READY to implement from
      Phase 1a — S610 (2026-08-19),
      [`docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md`](docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md),
      Effort L overall (5+ sessions); note Phase 1b is a genuine open research question the plan
      does not pretend to have solved — see the S610 entry below**;
      D1 bar-vs-bar half READY, Effort unknown, not scoped) — plan
      §2.3/§6 Session C's parent-span clamp
      (`docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`) was owner-accepted
      "as designed" this session via `AskUserQuestion`, but 2 costs were measured, not merely
      anticipated: (1) the plan's own §7 faithful child-centering metric on the real 375-individual
      bundled fixture worsens from 9/251 child edges exceeding a 200-unit threshold (3.6%, max
      offset 4,121) to 53/251 (21.1%, max offset 10,627); (2) the pre-existing, already-disclosed
      D1 bar-vs-bar x-overlap residual (plan §8) worsens from 9 to 116 post-Track-1 hits (42→348
      pre-Track-1-equivalent). Both trace to the same mechanism: clamping a runaway union back
      inside its own parents' span moves it (and its sibship bar's drop point) away from its
      children's true midpoint and back toward the x-region other relatives' subtrees occupy. A
      future session should decide whether this is acceptable as a permanent trade-off (matching
      plan §2.4's own deferred Track 4 — a narrower fix substituting the locally-relevant
      duplicate's x, estimated to bring the headline P1×P2 case to x≈-6 vs. the clamp's x=0, a
      materially tighter centering — was already designed and vetted but not adopted into this
      plan's scope) or warrants revisiting the clamp's own design (e.g. scoping it to single-child
      unions only, where Track 6's "centering" concept is arguably meaningless anyway, per the
      original S583 report's own framing; or a partial/soft pull instead of a hard clamp). Not
      filed as its own GitHub issue — matches this project's own precedent (`BACKLOG.md`'s S583
      item was itself "the same already-tracked gap, not a new one") of tracking a same-root-cause
      finding here rather than opening a new issue.

      **A third possibility, found live in conversation (2026-08-16, unclaimed session), for the
      separate D1 bar-vs-bar residual specifically** (not the child-centering cost, which only the
      Track 4 substitution above addresses): a future session could add a bar-aware detect-and-jog
      repair — conceptually closer to Track 2's `.resolveEdgeNodeCollisions()`, but applied to the
      D1 bar-chain edges themselves (currently excluded from Track 2's own detection, since that
      pass catches edge-vs-*node* collisions, not edge-vs-*edge* overlap between two different
      sibships' bars) — rather than trying to prevent the coincidence upstream by reserving extra
      horizontal margin during layout. Upstream prevention was considered and rejected as
      architecturally infeasible: `.positionMatingUnitForest()`'s contour-merge packs subtree
      spacing at integer generation rows only (no concept of the fractional bar row D1 waypoints
      occupy), and the 3 prior global-relayout investigations (S588 bounded-lookahead, S589
      barycenter/median, S590 `igraph::layout_with_sugiyama()`, plan §1) were all already closed as
      NOT FEASIBLE for exactly this reason — a high-mate-count "hub" individual's several subtrees
      compete for the same horizontal budget, so widening one gap to guarantee no future bar
      coincidence ripples into neighboring subtrees rather than localizing cleanly. A detect-and-jog
      repair sidesteps that by working after layout, on the already-placed bar geometry, matching
      Track 2's own established precedent for this class of residual.

      **Progress (S598, 2026-08-16), child-centering half only:** user picked this item, then
      narrowed scope to the child-centering cost specifically (the "Track 4" substitution named
      above), leaving the D1 bar-vs-bar residual as its own separate, still-untouched follow-up.
      A research/verify/adversarial-critique workflow re-derived the substitution design against
      current HEAD (confirmed exact insertion point `R/makePedigreeDiagramData.R:974-994`, live
      re-verified the -6 vs. 0.12 numbers) — **but found a genuine, live-verified correctness gap
      inside the design's own claimed scope**: when one individual mates 2+ different co-siblings
      of the same union, the substitution can move the union's center farther from true, not
      closer (verified with real fixture numbers, not just reasoned about). Presented via
      `AskUserQuestion`, owner chose **hold — needs a redesign session** over shipping either the
      flawed design (disclosed) or an unverified patch. Full evidence (code-state, live numbers,
      grep inventory, 3 adversarial critiques, open questions a redesign must resolve) written to
      [`docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md`](docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md)
      — explicitly an investigation, not a ratified plan; also flags that `BACKLOG.md`'s/the
      collision-avoidance plan's own "Track 4" shorthand for this fix collides with the
      already-shipped, unrelated `pedigree-diagram-track4-gen-aware-anchor-plan.md` and should not
      be reused as a name going forward. **Next: a future session runs a fresh design pass on the
      open questions in that document's §6**, then implementation (its own separate session,
      per this project's planning→implementation session-boundary discipline). D1 bar-vs-bar
      residual (the 3rd-possibility paragraph above) remains completely untouched.

      **Progress (S599, 2026-08-17), redesign attempt — still not sound:** ran a 12-agent
      design→synthesize→critique→repair→critique `Workflow` against S598's §6 open questions: 4
      independently live-verified candidate qualification rules, synthesized into one ("Sibling-
      Relationship-Count Abstention Guard"), adversarially critiqued (found a NEW compounding
      misfire — 2 different children of one union each substituting toward a shared 3rd sibling,
      swinging `0.5→3.775`), repaired (a "Layer 2" abstention ceiling neutralizing that), then
      critiqued again — **still `designStillSound: false` on 2 of 3 lenses**: (1) the substitution
      formula itself (inherited unchanged from the original S592 design by every candidate this
      session tried) has **unbounded magnitude** — a single, "legitimate" substitution can drift
      arbitrarily far (`-0.05→-16.238` live-measured) driven by unrelated ordinary breeding
      structure hanging off the sibling-mate union, collapsing the centered union onto one child
      and discarding the other; (2) both abstention branches produce output bit-identical to
      today's shipped behavior, so a naive black-box RED test would pass before any implementation
      exists, conflicting with this project's own TDD contract. Presented via `AskUserQuestion`
      again (repair-once-more / ship-disclosed / hold), owner again chose **hold — write
      investigation doc**. Full record (all 4 candidates, both critique rounds, 2 drafted PRE-RED
      question texts, updated open-questions list) appended as
      [`docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md`](docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md)
      §8 — **start at §8.6** for a future redesign session, not §6 (superseded). Two independent
      redesign attempts (S598, S599) have now both failed adversarial critique; §8.6 item 3
      explicitly flags that a future session should weigh continuing to refine this specific
      substitution mechanism against fixing child-centering quality at a different layer entirely.

      **Progress (S600, 2026-08-17), magnitude-bound attempt — still not sound, plus an independent
      finding:** owner picked up the §8.6 item 3 go/no-go explicitly (via `AskUserQuestion`: refine
      with magnitude bounded from round 1 / pivot to a post-hoc nudge / run both / accept as
      permanent) and chose to refine, scoping Layers 1/2 as given and requiring every candidate to
      pass a magnitude-stress fixture from round 1 (S599's own self-identified process gap). A 3rd
      12-agent `Workflow` produced 4 candidates, 2 of which independently converged on an identical
      "cap the substitution delta to `±K·minSep`" mechanism; synthesized, critiqued (3 lenses),
      repaired, critiqued again — **still `designStillSound: false` on 2 of 3 lenses after the
      repair**, this time at a deeper level: (1) the design's entire numeric success turns out to be
      contingent on silently reinterpreting Layer 1's own GIVEN qualification rule (marked
      off-limits this session) — under the literal rule, Pass 2 is dead code for exactly the 2-child
      mutual-mate shape both required fixtures use; (2) even granting that reinterpretation, the
      magnitude bound measures against the wrong reference frame and can overshoot the real
      children's own span by 50% in the *common*, tightly-spaced case, undetected across 2 full
      critique rounds; (3) `checkInvariant()`'s already-flagged dead-code trap (§8.6 item 4) was
      inherited unaddressed, and the design's own proposed RED test has a live 120x pixel-scale bug.
      **Three independent attempts (S598, S599, S600) have now all failed adversarial critique, each
      at a deeper layer.** Full record appended as
      [`docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md`](docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md)
      §9 — **start at §9.7** for a future session. §9.7 item 1 now recommends treating a 4th attempt
      at this same mechanism as the option needing justification, not the default.
      **Independent finding, not fixed here:** the workflow also discovered a real, pre-existing,
      standalone defect independent of this whole investigation — `preferAnchor()`'s
      (`R/makePedigreeDiagramData.R:403-411`) final tie-break is locale-dependent and already
      corrupts shipped pipeline output for any tied-generation full-sibling mate pair. Filed
      separately below (Housekeeping) and as a GitHub issue, per Learning 382's "report, don't fix
      mid-session" precedent.

      **Progress (S601, 2026-08-17), post-hoc-nudge pivot — also not sound, plus a zero-real-impact
      finding:** owner picked up §9.7 item 1's go/no-go via `AskUserQuestion` (accept Track 3
      trade-offs as permanent / pivot to post-hoc nudge / authorize a 4th pre-clamp attempt / hold)
      and chose to pivot — a mechanism shape untried by S598-S600, all of which stayed on a pre-clamp
      substitution. A 4th 12-agent `Workflow` produced 4 candidates applying a bounded correction
      *after* Track 3's clamp instead of before it; 2 of the 4 verified **zero** dependency on
      `preferAnchor()`/issue #162 (a genuine improvement no pre-clamp design could offer). Synthesized,
      critiqued (3 lenses) — **all 3 `designStillSound: false`** — repaired, critiqued again — **still
      `designStillSound: false` on 2 of 3 lenses**, and the edge-cases finding is *worse* than any
      prior round: on a nested/chained sibling-consanguineous shape, the nudge actively corrupts a
      union Track 3 alone already positioned correctly (no fix needed there at all), landing farther
      from the true center than either the nudge's own uncapped target or the shipped baseline.
      **New, independent finding: under this session's qualification rule, the fix never fires on
      either existing test corpus (0/4 `small`, 0/237 real 375-individual fixture)** — even a sound
      version of this mechanism would currently touch zero pedigrees this package tests or ships.
      **Four independent attempts across 2 structurally different mechanism families (S598, S599,
      S600 pre-clamp; S601 post-hoc) have now all failed adversarial critique.** Full record appended
      as
      [`docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md`](docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md)
      §10.

      **Progress (S601 continued, 2026-08-17), narrow repair converges — first sound design in this
      investigation:** owner chose a 5th, narrowly-scoped attempt (fix only the worse-than-erasure
      regression above; leave the separate, already-accepted erasure trade-off alone) rather than a
      full 6th redesign. A 5th `Workflow` (6 agents: 2 candidates, both independently converging on
      the same idea) produced a **"Track-3-Engagement Gate"**: the nudge fires for a union only if
      Track 3's own clamp actually altered that union's value (`|raw - clamped| > 1e-9`); a union
      Track 3 left untouched — the exact precondition for the regression — is a hard no-op instead.
      Live-verified: closes the regression on multiple nested/chained reconstructions (never worse
      than doing nothing), leaves F1/F2/F3 byte-identical to before, doesn't over-suppress a
      genuinely-needed inner correction (tested), and is provably a pure pass-through for the
      separate erasure trade-off (which requires the gate's own precondition to already be true).
      **Fresh 3-lens adversarial critique returned `designStillSound: true` on all 3 lenses** — zero
      major findings, only 3 minor ones (an unresolved `.computeDupNudge()` signature question with a
      live-verified no-new-parameter fix; a disclosed dangling-parent corollary; one untested corner).
      **This is the first design across 5 workflow attempts (S598, S599, S600, S601×2) in this
      investigation to survive a full adversarial critique cleanly.** Still PRE-RED — no production
      code written; a dedicated PRE-RED→RED `AskUserQuestion` remains this project's own standing
      requirement before any RED test is written. Full record:
      [`docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md`](docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md)
      §11 — **start at §11.4** for a future session.

      **Progress (S602, 2026-08-17), IMPLEMENTED — child-centering half DONE:** picked up §11.4's
      standing obligation via a dedicated `TDD: PRE-RED→RED` `AskUserQuestion` (owner: "full scope"),
      preceded by its own separate pre-RED scope `AskUserQuestion` (owner: full implementation now,
      over unit-tested-but-unwired or accepting the trade-offs as permanent). Recovered 2 gaps the
      investigation doc's own prose left unstated — the qualification rule's literal (a)/(b) clauses
      and the Stage-1 substitution formula, plus `.computeDupNudge()`'s full 6-argument signature —
      by reading both workflows' own raw journals directly (`wf_2d657d34-184`, `wf_f8b481f4-0f8`),
      not by guessing. RED: 7 new/modified tests in `test_positionMatingUnitForest.R`, all
      hand-constructed and empirically verified against real, unmodified source (not copied from the
      doc's own worked examples) — F1/F2/F3 reproduce §10-11's documented values exactly; a fresh
      nested/chained fixture reproduces the worse-than-erasure regression from scratch; a variant
      confirms the gate doesn't over-suppress a genuine correction; a dangling-parent fixture; the
      erasure trade-off stays untouched; `checkInvariant()` gained a 3rd disjunct + `.commentOneFixture()`
      in its call list (avoiding the "widened disjunct, unwidened call list" vacuity trap §11.3
      flagged); a strict F1 regression assertion. All 7 confirmed failing pre-GREEN, 0 collateral
      damage. GREEN: new internal `.computeDupNudge()` + wiring at the confirmed insertion point.
      Full clean regression: 0 new failed/error (only the pre-existing, unrelated
      `test_wordlist_coverage.R` failure). `lintr::lint_package()`: 4 style nits fixed. REFACTOR:
      cached the parent `[lo,hi]` span Track 3's clamp loop and the new nudge loop each independently
      recomputed — structure only, byte-identical result re-confirmed. Runtime smoke test: headless —
      confirmed the app's own Pedigree Diagram call chain (`makePedigreeMatingLayout()`) runs clean on
      the real 375-individual bundled fixture (1412 nodes/1525 edges, no new errors). `NEWS.Rmd`/
      `NEWS.md` entry added. Full record:
      [`docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md`](docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md)
      §12. **The D1 bar-vs-bar overlap half of this item remains open** — a separate, not-yet-designed
      "bar-aware detect-and-jog repair" (named above) — this session did not touch it.

      **Correction (S603, 2026-08-18), post-close-out — S602's "child-centering half DONE" claim
      RETRACTED:** owner reviewed the published comparison artifact (the same one S602 built) and
      reported 3 observations the artifact's own "verified correct" framing had dismissed or
      undersold. All 3 independently reproduced against current source (not re-derived from the
      artifact's own claims) using the F1 fixture (`test_positionMatingUnitForest.R:1140-1146`,
      `P1×P2→A,Y; A×Y` consanguineous, `A×X`/`W×Y` outside mates) and `visNetwork`'s own live
      `getPositions()`, before (`cdb9a167~1`) vs. after (current `HEAD`), at matched zoom:
      **(1) The Track-3-Engagement Gate fix (`.computeDupNudge()`) has no visible effect.**
      `__union_1` (P1×P2) moves from `(0,0)` — exactly coincident with P2 — to `(-5,0)`. Against
      P2's own 25px node radius, a 5px shift is invisible: before/after screenshots at 3× zoom are
      indistinguishable. The fix is real in code and TDD-tested, but does not visibly correct the
      defect it was built for, even in the one fixture constructed specifically to exercise it.
      **(2)/(3) The X×A / A×Y / W×Y descenders are not centered, most severely W×Y**, whose union
      lands at x=255.12 vs. Y's own x=255.00 — 0.12 units apart, visually indistinguishable from
      descending directly out of Y rather than from between W and Y. Confirmed this is structurally
      **unrelated to the Track-3-Engagement Gate** — none of C1/GC/C2 (these 3 unions' own children)
      are themselves duplicated, so the gate's qualification rule never reaches them. This is pure
      output of the earlier Track 6 "center a union over its one child" design, pre-dating S602
      entirely. **What was wrong in S602's own artifact, and in this assistant's first relay of
      it:** the artifact labeled (2)/(3) "correct behavior, verified" on the strength of Track 6's
      stated design intent, without independently checking whether the geometric result was
      defensible regardless of that intent — a descender landing 0.12 units from a parent's own
      node is a visual defect by inspection, whatever the code comment says it is doing on purpose.
      This assistant repeated that framing to the owner without re-verifying it; corrected here per
      the owner's direct instruction (see `PROJECT_LEARNINGS.md`'s new learning on this). **Net
      effect on this item's own status:** the "child-centering half" is **not DONE** — it is back to
      OPEN, alongside the D1 bar-vs-bar half. The published artifact, `NEWS.Rmd`, and the
      investigation doc's own §12 "Net result" claim are corrected in the same session (see
      investigation doc §13 for the full record, methodology, and images).

      **Progress (S608, 2026-08-18), pivoted to a different mechanism entirely — investigation,
      not implementation:** owner picked up this item, then (via `AskUserQuestion`, given the
      duplicate-occurrence-selection mechanism was exhausted at 5 attempts) pivoted to S603's own
      newly-found, structurally distinct defect: Track 6's single-child union formula places a
      union's marker and both mate edges essentially on top of one of its own 2 parents. A
      15-agent Evidence→Design→Synthesize→Critique→Repair→Critique-2 `Workflow` found this is
      **majority-prevalence, not an edge case** — 72% of all matings in the real 375-individual
      fixture visually coincide with a parent (170/224 single-child unions, live-verified via
      chromote pixel-space rendering, not just internal coordinates). Produced a repaired
      candidate design ("D3″," a safety-gated engagement correction) that Critique Round 2 found
      still carries one live-verified bug — with an already-verified one-line fix in hand (residual
      drops 40/224→11/224) — plus 2 disclosed architectural gaps (a collision-safety guarantee
      that can't see 2 later pipeline passes; a tautological invariant-test surface). **Not yet
      PRE-RED-ready.** Owner-ratified next step (via `AskUserQuestion`, §9): a **targeted repair
      session (READY, Effort S)** — apply the already-verified one-line self-duplicate-exclusion
      fix (residual 40/224→11/224, already measured) + add diagnostic return fields to
      `.computeSingleChildAntiCoincidence()`, run a fresh Critique Round 3 against the result
      specifically, then proceed through PRE-RED→RED→GREEN. Full record, the ratification, and
      exact scope:
      [`docs/planning/pedigree-diagram-single-child-union-parent-coincidence-investigation.md`](docs/planning/pedigree-diagram-single-child-union-parent-coincidence-investigation.md)
      §7-9. Independent finding, unrelated to this item: Track 6's own "91% reduction" headline
      metric is stale at current HEAD (true baseline 53/251, not 9/251) — a separate housekeeping
      item. The original Track 3 child-centering/D1-bar-vs-bar decision (accept as permanent vs.
      investigate further) remains itself unresolved pending this new investigation's own outcome.

      **Progress (S609, 2026-08-18), "D3‴" built and Critique Round 3 run — still NOT sound,
      needs a redesign, not another repair attempt:** picked up §9's ratified targeted-repair
      scope via a `Workflow` (1 rebuild agent + 3 independent adversarial critique lenses, scratch
      copy only, zero production code touched). The rebuild reproduced every number the
      investigation had already established exactly (F1 `__union_4` = 224.00px; real-fixture
      residual 11/224; `resolveEdgeNodeCollisions` pairs = 1427; S583 pinned case = 29; Constraint
      1 bit-identical) and honestly fixed 2 further bugs beyond the ratified scope (a
      floating-point guard band; a latent direction-reversal risk in the safety cap) — but **all 3
      critique lenses independently returned `designStillSound: false`**, finding problems the
      rebuild's own honest disclosure did not reach: (1) **the shipped scratch copy regresses an
      existing, currently-green production test** — Track 6's own "zero exact coincidence"
      invariant guard — from 0 to 3 violations on the real fixture; (2) **7 of the 11 "residual"
      cases are not partial corrections, they are exact no-ops** (`target == curX`, the union
      renders on top of its parent, unchanged) — the `capped` diagnostic field is actively
      misleading for these; (3) a structurally separate, previously-unhypothesized bug: the
      narrow-parent-span midpoint-fallback branch is also defeated by the same obstacle cap; (4)
      the failure isn't limited to "shared founder boundary" as scoped — a hand-built case with 3
      independently-engaged unions (no shared parent) shows the identical collapse, because the
      sweep is a one-directional pass with no fixed-point reconciliation between overlapping local
      corrections; (5) the diagnostic fields fail adversarial mutation testing for a "wrong
      formula" bug class. **Six independent design attempts across this investigation's full
      history (S598, S599, S600, S601×1, S609) have now failed adversarial critique** — this is
      not a one-line-fix-away situation; the root cause is architectural (no reconciliation
      mechanism between 2+ single-child unions whose corrections overlap), matching this
      investigation's own repeated pattern. Full record:
      [`docs/planning/pedigree-diagram-single-child-union-parent-coincidence-investigation.md`](docs/planning/pedigree-diagram-single-child-union-parent-coincidence-investigation.md)
      §10 — **start at §10.3** for a future redesign session. Not scoped for that session (per
      this document's own bounds, §0): the D1 bar-vs-bar residual, the multi-child population, or
      re-litigating the duplicate-occurrence-selection mechanism (already separately exhausted at
      5 attempts).

      **Redirect (S609 continued, 2026-08-18) — owner-directed, informed by re-reading this
      project's own algorithm-design history:** in conversation, the owner challenged this
      whole repair thread against kinship2's own convention. Re-reading
      `pedigree-diagram-track6-child-centered-union-position-plan.md` and
      `pedigree-diagram-option2-layout-design-plan.md` in full (not from memory) established (a)
      nprcgenekeepr's *original* formula was parent-centered, like kinship2, and Track 6 moved
      away from it only after measuring a *worse* defect (max 10,687-unit sibship-bar drift for
      polygamous anchors); (b) kinship2 was never adopted directly because it is GPL (nprcgenekeepr
      is MIT) and its own source contains an uncapped factorial search plus a heuristic its own
      vignette admits "works 9 times out of 10." Reading `inst/extdata/reference/5201430.pdf` (the
      CraneFoot paper) directly then corrected this session's own framing: CraneFoot's published
      Aesthetic (4), "parents centred over children," is — through the mating-unit transformation —
      **Track 6's own rule, not kinship2's**; kinship2 and the Reingold-Tilford/Walker/BJL family
      are 2 different published conventions, not one "the" standard. **Owner directive: "go with
      CraneFoot / the Reingold-Tilford–Walker–BJL family this whole approach is built on"** —
      pursue a complete, correct implementation of that family (issue #141) as the direction for
      this whole defect class, rather than a 7th local-patch attempt or reverting to kinship2-style
      parent-centering. **This is a ratified direction, not a scoped plan** — no redesign session
      has been scheduled, no implementation started. A comment was added to issue #141 documenting
      that the evidence in hand (6 failed local-patch attempts, ordinary-scale correctness
      failures) is a different kind of justification than that issue's own filed text asks for
      (which was performance-only); the `premature optimization` label was deliberately not
      changed — that is a decision for a future planning session or the owner directly. Full
      record, ratification, and the precise scope boundary for a future planning session:
      [`docs/planning/pedigree-diagram-single-child-union-parent-coincidence-investigation.md`](docs/planning/pedigree-diagram-single-child-union-parent-coincidence-investigation.md)
      §11.

      **Scoped (S610, 2026-08-19) — the planning session §11 called for is DONE; implementation is
      now READY to start at Phase 1a (Effort L overall, 5+ sessions):**
      [`docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md`](docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md).
      An 8-agent research→design→3-lens-critique→repair `Workflow` produced it; **all 3 critique
      lenses returned `designStillSound: false` on the first draft**, and the repaired plan states
      what they found rather than hiding it. The most consequential finding was structural: the
      draft's own proposed reconciliation mechanism (a "global LEFTNEIGHBOR table") was both
      *misattributed* (real BJL **replaces** Walker's global per-level table with a purely local
      sibling lookup — the draft claimed BJL keeps it unchanged) and *mechanically unsound*
      (grafting a non-sibling comparison partner into `moveSubtree`/`executeShifts`'s sibling-indexed
      bookkeeping), and would have reintroduced this investigation's own signature "one-directional
      sweep, first one wins" failure shape **one level down, inside the replacement algorithm's own
      internals** — i.e. a 7th instance of the same root cause, caught at the planning stage this
      time instead of after implementation. Phasing: **1a** standalone BJL apportioning engine
      (genuine trees only, cross-checked against MIT-licensed `d3-hierarchy`, strong exact-value
      oracles required on every fixture); **1b** (NEW, required, gates Phase 2) a research/design
      spike for the forest/mixed-gen reconciliation problem the literature does not address at all —
      this project's forest has 0-delta tree edges (an individual→its own anchored union, a
      union→its non-anchor-parent phantom leaf) that no Reingold-Tilford/Walker/BJL no-overlap proof
      covers, and 1b may legitimately conclude "more research needed"; **2** pedigree adapter built
      parallel to production, A/B verified, plus a new reusable checked-in
      `helper-live-render-positions.R` (chromote `getPositions()` ground-truth harness); **3**
      cutover in 2 explicitly-scoped commits (4 files, then 2), each independently green;
      **4** cleanup/docs + close issue #141. Track 3's clamp, Track 6's `finalUnitX` override,
      `.computeDupNudge()`, both `sweepMinSep()` applications and the epsilon de-collision pass are
      all targeted for removal — but **conditionally**, gated on Phase 2's real-fixture
      zero-coincidence test (`test_positionMatingUnitForest.R:1185-1205`) actually passing, never
      asserted in advance. D1/D2/D4/D5, Track 1, Track 2, and the D1 bar-vs-bar residual are all
      explicitly OUT of scope. Issue #141 not closed and its `premature optimization` label not
      changed — both deferred to Phase 4/the owner, matching S609's own restraint.

      **Phase 1a DONE — S611 (2026-08-19):** standalone, pedigree-agnostic BJL apportioning
      engine, [`R/positionTreeApportion.R`](R/positionTreeApportion.R) (`.positionTreeApportion()`,
      `.buildForestChildrenOf()`, both internal/non-exported) +
      [`tests/testthat/test_positionTreeApportion.R`](tests/testthat/test_positionTreeApportion.R)
      (5 `test_that()` blocks, 8 exact-value expectations). **Zero changes to
      `R/makePedigreeDiagramData.R` or any existing test file** (`git status --porcelain -- R/
      tests/` shows only the 2 new files throughout). Strict TDD followed: PRE-RED research →
      `AskUserQuestion` gate → RED (genuine, 5/5 tests erroring on "could not find function," not
      vacuous) → `AskUserQuestion` gate → GREEN (8/8 expectations passed on the first
      implementation attempt) → `AskUserQuestion` gate → REFACTOR (53→0 lintr findings, all
      style-only, re-verified 8/8 GREEN + full regression after). **PRE-RED research, done before
      any code was written:** downloaded and read Walker's primary source (TR89-034, UNC, Sept.
      1989) directly, extracted Figure 12's 15-node worked example and its published final
      x-coordinates from "Nodes Visited in the Second Traversal" (pp.17-20) — not a secondary
      summary. Independently cross-checked against real `d3-hierarchy` v3.1.2 (installed via
      Node.js; **correction to the plan's own wording: ISC-licensed, not MIT** — equally
      permissive and GPL-avoiding, so the plan's licensing rationale is unaffected): all 15 nodes
      matched exactly (relative to root). Generated exact-value oracles for the other 3 required
      fixtures (balanced 3×3 n-ary tree, asymmetric deep-narrow+wide-shallow tree, a 3-tree forest
      via `.buildForestChildrenOf()`) by actually running `d3-hierarchy` on identical input —
      satisfying the plan's own C2-3 "strong, exact-value oracle" requirement at its most rigorous
      reading. **Found and fixed a real defect in the plan's own `apportion()` pseudocode** via
      the required d3-hierarchy source cross-check: the plan omits `vip_mod += shiftVal;
      vop_mod += shiftVal` immediately after `moveSubtree()` fires (real d3-hierarchy's
      `apportion()` does this — `sip += shift; sop += shift`, `tree.js` lines ~163-165). Proved
      this is mechanically necessary, not cosmetic, by implementing both the plan's literal
      pseudocode and the corrected version in JS, constructing an adversarial fixture forcing 2+
      compounding shifts within one `apportion()` call, and confirming only the corrected version
      matches the real reference exactly. The R implementation includes this correction, documented
      in the file's own header and inline at the call site. Full clean regression (277 files,
      excluding the documented pre-existing `test-app-*`/`test-e2e-*`/`appServer`/`shinytest2`
      baseline-noise set) run 3 times (RED baseline, GREEN, REFACTOR): 0 failed/0 error every
      time, including `test_positionMatingUnitForest.R`/`test_buildMatingUnitForest.R`
      unaffected. `lintr::lint()` on both new files: 0 lints. Runtime smoke test: n/a — grep-
      confirmed zero references to any new function outside the 2 new files (no wiring, no
      exports; matches Phase 1a's own explicit "zero changes" scope). **Next: Phase 1b** (forest/
      mixed-gen/cross-branch reconciliation research spike, gates Phase 2) — its own separate
      session, per the plan's own phase boundaries; may legitimately conclude "more research
      needed."

      **Phase 1b — S612 (2026-08-19): substantial progress, NOT DONE — honest "needs a
      continuation session" outcome, exactly the allowance the plan's own Phase 1b charter names.**
      [`docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-reconciliation.md`](docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-reconciliation.md).
      A research→design→critique→repair `Workflow` (research: gen-recompute call-site trace,
      layered-graph literature review, `apportion()` mechanics) → design synthesis → **3 further
      critique+repair rounds** (11 + 4 + 4 = 19 agents total, ~87 min combined). **Settled,
      validated, safe to build on:** the core architecture (Candidate 2b — eliminate every 0-delta
      edge from the tree recursion by reattaching a union's real children onto its anchor,
      representing everything else as a one-way-derived point) survived all 3 critique rounds
      unchallenged at the structural level, independently corroborated by direct reads of
      CraneFoot's actual C++ source and kinship2's own design vignette (both real pedigree tools
      independently never make a mating union a first-class tree-recursion node either). Candidates
      1 (revived global table) and 3 (same-rank/flat-edge, Sugiyama-literature) are conclusively
      ruled out. The B1/B2/B3 non-anchor-occurrence classification is sound. Case (d) (multi-gen
      forest roots) is resolved for the Shiny app's own reactive chain and, more importantly,
      covered generally by a reinstated `sweepMinSep()` backstop. **NOT settled:** round 4's own
      critique (3 lenses, all independently constructing and *executing* a counter-example) found
      that reinstating `sweepMinSep()` as a safety net (fixing one round-2 finding) breaks the
      invariant a new `orderBySex` sign-fold formula (fixing round 2's *other* finding) depends on
      — when `sweepMinSep()` moves a real child of an `orderBySex`-qualifying union, the drift
      (measured: 0.5 and 0.700 in 2 independent executed fixtures) reliably exceeds the sign-fold's
      own tolerance budget (0.4), inverting the male/female ordering the fix exists to preserve.
      This is the *same signature failure shape* (2+ locally-computed corrections whose interaction
      was never checked against each other) recurring a 4th time within this design-note stage
      alone, on top of the 6 prior full implementation attempts — found here, before any
      implementation code, which is exactly Phase 1b's own purpose. The design note's own §7
      proposes 3 concrete candidate fixes for a follow-up session to evaluate (none adopted here,
      deliberately — adopting one without its own adversarial pass would repeat the mistake this
      note documents). **Next: a Phase 1b continuation session** resolving specifically this seam
      (not a restart — cases (a)/(b)/(c)/(d) and the 2b architecture are settled inputs), THEN
      Phase 2. Effort S-M for the continuation.

      **Phase 1b continuation — S613 (2026-08-19): SEAM RESOLVED, first-attempt sound.**
      [`docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-reconciliation.md`](docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-reconciliation.md)
      §8. A repair→3-lens-adversarial-critique `Workflow` (4 agents: 1 repair + 3 independent
      critique lenses) resolved the `sweepMinSep()`-vs-`orderBySex` sign-fold seam on its **first**
      repair attempt — every lens returned `designStillSound: true` with its own independently
      executed verification, no repair round 2 needed. First first-attempt-sound outcome in this
      investigation's full history (4 prior design-note rounds + 6 prior implementation attempts
      all failed critique). **The fix:** anchor the non-anchor parent's derived x on the anchor's
      own frozen Tier-1 `P.x` directly (`M_repr.x = P.x + sign(M)*minSep*0.4`) instead of the
      drift-prone Tier-2 `U.x(FINAL)`, gated on the same `mateCount==1` qualifying test today's
      shipped `orderBySex` already uses (restated in full, 5 conjuncts, since the design note's own
      pseudocode had dropped 2 of them) — B3 duplicates and the non-qualifying fallback are
      untouched. Provably correct for any drift magnitude/sign, not just the 2 magnitudes §7's own
      counter-examples happened to execute. **2 disclosed implementation-time obligations for
      Phase 2** (not further open design questions): (1) a required new Test 15 + an explicit
      assertion that `P.x` is read post-`sweepMinSep()`, never a pre-sweep intermediate — the
      critique found today's shipped code has exactly 2 write-points for a real individual's `x`
      and a careless implementation could read the wrong one; (2) widen the disclosed
      union-dot/`M_repr` cosmetic-distance trade-off to cover `sweepMinSep()` pushing `P` itself,
      not only `P`'s children. **Phase 2 (the pedigree adapter, parallel to production) is now
      READY** — design/research only this session, zero production code touched, matching Phase
      1b's own precedent throughout. Effort L overall unchanged; Phase 2 itself Effort M-L,
      5+ sessions per the parent plan's own estimate.

      **Phase 2a — S614 (2026-08-19): adapter mechanics DONE, split from live-render
      verification.** Owner-directed scope split (via `AskUserQuestion`, matching Phase 2's own
      "splittable if too large" allowance): this session built `.positionMatingUnitForestBJL()`
      (new function, `R/makePedigreeDiagramData.R`, zero changes to `.positionMatingUnitForest()`
      or any other existing code, no shared call site yet) implementing the design note's 3-tier
      reconciliation (Tier 1 genuine-tree BJL + reinstated `sweepMinSep()` backstop; Tier 2 union
      midpoint + exact-tie sweep; Tier 3 B1/B3 derived points using §8.1's fixed formula) — via
      strict TDD (PRE-RED → `AskUserQuestion` → RED → `AskUserQuestion` → GREEN →
      `AskUserQuestion` → REFACTOR, each transition gated). New
      [`tests/testthat/test_positionMatingUnitForestBJL.R`](tests/testthat/test_positionMatingUnitForestBJL.R):
      17 `test_that()` blocks — the design note's own 15-fixture matrix (§4 Tests 1-14 + §8.4's
      required Test 15) plus 3 property tests — all synthetic/hand-built; explicitly **deferred to
      a Phase 2b session**: the reusable chromote-based live-render helper and the real
      375-individual fixture's own zero-coincidence/single-child-union-prevalence measurements
      (both still owed per the parent plan's own Verification Plan). Oracle values for the
      numerically-exact fixtures derived by actually running Tier 1's own mechanics against the
      existing Phase 1a engine, never hand-derived. 2 real implementation defects found and fixed
      during GREEN (both via execution, not foreseen at RED): (1) B1 eligibility needs an explicit
      `!hasParentEdge(M)` conjunct the OLD, shipped `freePassIds` computation doesn't carry — a B2
      individual (own parent edge) was wrongly getting a second, Tier-3 derived-point row; (2) a
      dangling non-anchor party (no own row in `ped`) crashed on `sireOf[[id]]`/`damOf[[id]]` —
      fixed by excluding dangling ids from B1 eligibility up front, matching the OLD function's
      own confirmed behavior of dropping such an id from its output entirely. 3 RED-phase test
      bugs (not implementation bugs) also found and fixed. Verified: `test_file()` 17/17 GREEN (53
      expectations); full clean regression 0 failed/0 error project-wide (OLD function and every
      other existing test bit-for-bit unaffected); `lintr::lint()` 0 findings after REFACTOR (2
      style-only fixes). See `PROJECT_LEARNINGS.md` Learnings 639/640. **Next: Phase 2b** (the
      live-render helper + real-fixture A/B verification) — its own separate session.

      **Phase 2b — S615 (2026-08-20): DONE.** New reusable
      [`tests/testthat/helper-live-render-positions.R`](tests/testthat/helper-live-render-positions.R)
      (`getLiveRenderedPositions()` — renders via the app's own `visNetwork()`/`visPhysics(FALSE)`
      call, `chromote`-drives it headless, reads back ground truth via vis.js's own
      `getPositions()`), completing the parent plan's own Phase 2 "New deliverable... fixing C2-4."
      7 new tests added to
      [`tests/testthat/test_positionMatingUnitForestBJL.R`](tests/testthat/test_positionMatingUnitForestBJL.R)
      (24 total). **Real-375-fixture results, all measured (not assumed):** the zero-exact-
      x/gen-coincidence gate ("the single most important test in the whole migration") **passes**;
      the exact-midpoint invariant (previously synthetic-only) **passes** on real data too;
      single-child-union near-parent prevalence is 224/237 (structural, unchanged — D1 out of
      scope) with a new distance breakdown of 180/224 touching (≤31px) / 208/224 half-column
      (≤60px) vs. the OLD algorithm's clamp-affected 175/224 / 203/224 — comparable, not
      dramatically reduced, because BJL's own genuine child-centering produces similar visual
      closeness for structurally honest reasons (the plan's own "naturally close... may legitimately
      remain close" caveat, now directly measured); Phase 1b §8.4 Obligation 2's combined
      trigger-frequency measurement found 34 `orderBySex`-qualifying B1 unions, drift range
      0.399–0.401, comfortably inside the disclosed cosmetic bound. **Major incidental finding
      (`PROJECT_LEARNINGS.md` Learning 641):** live-rendering revealed vis.js's `getPositions()`
      rounds to whole pixels, so the shared 1e-3-raw-unit "cosmetic" tie-break nudge (×`xScale=120`
      = 0.12px) used by BOTH algorithms renders pixel-identical to whatever it was nudged away
      from — measured side by side on the real fixture: OLD 368/714 nodes pixel-coincident (182
      groups), NEW 380/714 (190 groups), comparable, a pre-existing characteristic, not a Phase 2b
      regression. Owner-directed (`AskUserQuestion`, on finding this): Tests 6/7 report this via
      `message()` as a diagnostic, asserting only what Phase 2b's charter requires (no id silently
      collapses in vis.js's own DataSet — confirmed clean on both the F1/"Track C" fixture and the
      real 714-node fixture), not a hard pixel-coincidence gate neither algorithm clears. A real
      epsilon-magnitude fix, if wanted, is future design work, not scoped here. **Also found and
      fixed:** chromote's own 10s default `Page$loadEventFired()` timeout was too short for the
      714-node fixture's self-contained HTML (helper gained a `loadTimeout` parameter, default 30s,
      used 60s for the real fixture); a NEW `devtools::check()` WARNING ("unstated dependencies in
      tests: chromote, htmlwidgets") from using the same `data-raw/kinship2FidelityValidation.R`
      `::`-call pattern inside the CHECKED `tests/testthat/` surface — fixed by adding both to
      `DESCRIPTION`'s `Suggests:` (owner-clarified packaging rule: `Suggests:` for anything
      test/example/vignette code loads, `Config/Needs/<name>:` for dev-tooling-only packages);
      `PROJECT_LEARNINGS.md` Learning 642. Incidentally also relocated `covr` (pure coverage
      tooling, already CI-installed independently) from `Suggests:` to a new
      `Config/Needs/coverage: covr`, matching this file's own `Config/Needs/website: quarto`
      precedent — flagged, not fixed, that `devtools`/`roxygen2`/`pkgdown` look like further
      instances of the same misplacement (new Housekeeping item below). Full clean regression:
      0 failed/0 error project-wide (confirmed twice — a direct `test_dir()` run and again inside
      `devtools::check()`'s own `testthat.R`). `lintr::lint_package()`: 0 lints. `devtools::check()`:
      0 errors, 1 WARNING + 2 NOTEs — all 3 pre-existing (non-portable filename, `scratchpad/` top
      level dir, `vignettes/figure/` knitr leftover), zero new, matching S614's own baseline
      exactly. `.positionMatingUnitForestBJL()` itself unchanged — Phase 2b touched zero production
      code. **Next: Phase 3** (cutover, 2 explicitly-scoped commits per the parent plan's own Phase
      3 spec) — its own separate session; the real-fixture zero-coincidence gate now has DIRECT
      real-data evidence behind it, not just synthetic-fixture coverage.

## Architecture follow-ups (from TECH_DEBT_AUDIT_2026-05-30.md, re-verified 2026-07-11)
*Resolves the former "Tracker reconciliation" decision item (S365) --
`docs/audits/XARCH_TRACKER_RECONCILIATION_AUDIT_2026-07-11.md` re-verified all 8
XARCH-1..8 findings against current source rather than trusting the six-week-old
audit text. XARCH-1/3/7 are fully RESOLVED (no further tracking). XARCH-2 (implicit/
inconsistent module contract) and XARCH-5 (string-column-keyed pipeline, no
validated seam) are STILL OPEN and owner-directed to GitHub issues #122 and #123
respectively -- track them there, not here. XARCH-4 (sex-code literal
centralization) is now also fully RESOLVED -- S367 (2026-07-12): see
`CHANGELOG.md`. XARCH-6 (`qcStudbook()`/`modInput.R` multi-call redundancy) is
now also fully RESOLVED -- S368 (2026-07-12): see `CHANGELOG.md`. XARCH-8's
narrower remaining gap is now also fully RESOLVED -- S369 (2026-07-12): see
`CHANGELOG.md`. The `man/filterPairs.Rd` staleness this recurring collateral
regen left behind (S367 origin, flagged S368/S369) is now also RESOLVED --
S370 (2026-07-12): see `CHANGELOG.md`. No items remain in this section.*

## Up Next
- [ ] **Act on the LabKey integration research recommendations** (BLOCKED -- remainder
      needs a live LabKey server to test/observe, Effort M) — research pass DONE
      (`docs/research/labkey-integration-options-2026-06-19.md`, S143). **Rec #3 (explicit optional
      API-key auth with `.netrc` fallback + clear error) DONE — S144, `setLabKeyDefaults()`.
      Rec #1 (`Rlabkey` version floor) DONE — S146, `Rlabkey (>= 3.2.0)` in `DESCRIPTION` (all four
      EHR-module repos target LabKey 26.6; the live ONPRC/SNPRC server version, doc §8.1, is still
      unobserved). See `CHANGELOG.md`.
      Rec #2 (config-ize the ONPRC defaults) DONE — S147: centralized into the internal
      `defaultSiteParams()` (single source of truth for `getSiteInfo()`'s no-config fallback; no
      behavior change) + documented the center-specific `lkPedColumns` form in the example config
      (flat `dam`/`sire` = SNPRC direct columns; `Id/parents/dam` = ONPRC curated lookup). All three
      quick wins (Rec #1/#2/#3) DONE.**
      Rec #4/#5 (formalize a data-source adapter on the `getPedDirectRelatives` seam + a deterministic
      mocked integration test) DONE (fetch-boundary slice) — S148: internal `getPedigreeSource()`
      (`labkey` | `dataframe`) now backs `getLkDirectRelatives()`'s fetch with the walk byte-identical,
      plus the first deterministic walk test. **Walk-unification DONE — S149:** `getLkDirectRelatives()`
      now delegates its pedigree walk to `getPedDirectRelatives()`, so the LabKey/EHR path returns the
      full connected pedigree component (collaterals included), consistent with the in-memory function —
      a deliberate, owner-accepted behavior change; the deterministic test now asserts the full
      component incl. the previously-excluded collateral sibling. **`file` provider DONE — S150:**
      `getPedigreeSource()` gained a `"file"` source (params `fileName`/`sep`) that reads a pedigree file
      (CSV or Excel) via the exported `getPedigree()`, alongside `"labkey"` and `"dataframe"`;
      offline-deterministic, validates id/sire/dam, errors loudly like the `dataframe` branch.
      **`"file"` provider WIRED to a first-class caller DONE — S151:** new exported
      `getFileDirectRelatives(ids, fileName, sep, unrelatedParents)`, a file-sourced sibling of
      `getLkDirectRelatives()` (reads via the `"file"` provider, then the source-agnostic
      `getPedDirectRelatives()` walk). The clean symmetric family is now `getPedDirectRelatives`
      (in-memory) / `getLkDirectRelatives` (LabKey) / `getFileDirectRelatives` (file).
      **Option C — file pedigree source through the focal-animal app pipeline DONE — S152:** new exported
      `getFocalAnimalPedFromFile(fileName, pedigreeFileName, sep)`, a file-sourced sibling of
      `getFocalAnimalPed()` (reads focal Ids from one file, builds the connected component from a separate
      pedigree file via `getFileDirectRelatives()`; fail-soft to a classed `nprcgenekeeprFileErr` whose
      `message` names WHY the read failed — bad focal-id list file, a missing/not-found/unreadable/
      wrong-column pedigree file, or no focal IDs matched — surfaced as the app's "File Read Error"
      detail (richer error messages added S155). `modInput`
      gained an optional pedigree-file input on the focal-animals path and dispatches to the offline
      function when supplied, else the unchanged LabKey path — so the Shiny focal-animal workflow can now
      run offline with no LabKey/EHR connection. (The focal-id read was factored into a shared internal
      `readFocalAnimalIds()`.) **Still deferred:**
      a non-LabKey other-EHR provider on the same seam; server-side filtering / `executeSql` / consuming
      the centers' `study.Pedigree`/`ehr.kinship` (research doc explicitly defers until pull size is
      measured + per-center query availability/permissions are confirmed; needs a live LabKey server to
      test/observe, and a naive focal-id server filter is incompatible with the client-side
      connected-component walk).
- [ ] **Investigate factoring out the pedigree-diagram drawing functionality into a separate R
      package that `nprcgenekeepr` depends on** (found 2026-08-19, owner-directed, READY, Effort M
      -- a research/scoping session, not an implementation session) -- look into the possibility,
      advantages, and disadvantages of splitting the pedigree-diagram layout/rendering code
      (`.buildMatingUnitForest()`/`.positionMatingUnitForest()`/`.addRectilinearWaypoints()`/
      `.resolveEdgeNodeCollisions()`/`makePedigreeMatingLayout()` in `R/makePedigreeDiagramData.R`,
      plus the Shiny Diagram-tab module) out of `nprcgenekeepr` into its own standalone package,
      with `nprcgenekeepr` then depending on it. A future session should weigh this independent of,
      and probably after, the Walker/BJL apportioning redesign (`docs/planning/
      pedigree-diagram-walker-bjl-apportioning-redesign-plan.md`, issue #141) currently in
      progress -- splitting mid-redesign would add package-boundary churn on top of an
      already-large in-flight algorithm change. Not scoped further this session (out of Phase 1a's
      own boundary); a future session should produce the actual advantages/disadvantages analysis
      (reuse potential outside this project, cleaner dependency graph, and versioning/release
      overhead, cross-package test/CI complexity, `@noRd`/internal-function visibility loss across
      a package boundary, etc.) before any decision to split.
- [ ] **Simplify `NEWS.Rmd` entries for a non-technical audience, reorganized by feature
      not chronologically, with guardrails against recurrence** (found 2026-08-20,
      owner-directed, READY, Effort L) -- a prior session (S538, 2026-08-12) already
      trimmed the `2.0.0.9000` dev-section once (386->134 lines, 26 entries, rewritten from
      multi-sentence technical paragraphs to the terse pre-1.0.8 house style;
      `PROJECT_LEARNINGS.md` Learning 544), but that fix had no guardrail: 8 days and ~80
      sessions later the section has regrown to 315 lines / 57 entries, most written back in
      the SAME verbose/technical style S538 removed -- e.g. "a KING-robust marker-based
      kinship estimate" (`NEWS.Rmd:57`), "Hudson's Fst between the populations of two
      centers" (`:70`), "a CERVUS-style multilocus likelihood-ratio (LOD) score" (`:91`), and
      exported-function-name-first phrasing (`` `checkLocusMetadata()` ``,
      `` `markerLdBlock()` ``) throughout -- readable to an R programmer, not to the
      colony-manager/veterinarian audience this package's NEWS is meant to serve. **Owner-
      stated requirements for this item (2026-08-20, refined 2026-08-20):** (1) entries must
      be simplified iteratively until the owner is satisfied -- draft, owner review, revise --
      not a single unilateral pass an executing session declares done on its own judgment;
      (2) WITHIN each version/release heading (`# nprcgenekeepr X.Y.Z`), entries must be
      reorganized BY FEATURE (e.g. a "Pedigree Diagram" group, a "Marker Genetics" group, a
      "Genetic Value Analysis" group), not chronologically/by-issue-number the way every
      version section is laid out now -- **the release headings themselves stay in their
      existing reverse-chronological order** (standard changelog/CRAN convention); only the
      entries inside each one get regrouped, never merged across versions; (3) the item must design and land a concrete
      guardrail preventing the verbose/technical style from creeping back in after this pass,
      the way it did after S538's own fix -- candidates to evaluate, not pre-decided: an
      explicit plain-language house-style note committed at the top of the dev section itself
      (visible at the exact point new entries get added), and/or extending `CLAUDE.md`'s
      existing same-session "NEWS.Rmd entry checklist" (ratified Session 448) with an
      explicit terseness/no-jargon/plain-language criterion a new entry must pass before
      commit. A future session should propose the feature-taxonomy and the guardrail
      mechanism via `AskUserQuestion` before rewriting, then iterate the rewrite with the
      owner across as many review rounds as needed -- this is explicitly NOT a one-session,
      one-pass item.
## Housekeeping
- [ ] **(Optional, low priority) Root-cause why the pinned Chrome-for-Testing binary hangs on
      `macos-latest`'s `ChromoteSession$new()` bootstrap** (found S619, 2026-08-20, incidental to
      the chromote CDP-timeout fallback fix below, READY, Effort M -- research only, not
      required) -- the practical problem is FULLY resolved: `macos-latest` reverts to ambient/
      unpinned Chrome (`R-CMD-check.yaml`, `if: matrix.config.os != 'macos-latest'` on the 3
      Chrome-provisioning steps), verified green on real CI. What remains unexplained: raising
      chromote's `default_timeout` to 60s did NOT resolve the pinned binary's hang (same exact
      failure, wall time roughly doubled, confirming the session is genuinely wedged, not merely
      slow) -- direct source inspection confirmed the timeout-governed call is
      `ChromoteSession$new()`'s own internal `Runtime.evaluate("window.devicePixelRatio", ...)`
      bootstrap probe (`private$get_pixel_ratio()`, chromote 0.5.1), but WHY that specific probe
      never gets a response on the pinned macOS ARM64 binary specifically (vs. the SAME pinned
      binary working fine on ubuntu-latest/windows-latest, and vs. ambient Chrome working fine on
      macos-latest) is unconfirmed. A research workflow found a plausible but NOT Chromium-
      confirmed analog (Mozilla Bugzilla #1893921 -- Firefox's own content-process spawn hitting a
      5s AppKit/IOKit sandbox-denial stall specific to GitHub's *virtualized* macOS ARM64 hosts,
      fixed by widening Firefox's own sandbox allowlist) but found no matching Chromium tracker
      entry. Only worth pursuing if pinned-Chrome reproducibility on macOS specifically becomes
      valuable later (e.g. `xattr -l` on the extracted `.app` on a live failing runner to rule
      out/in Gatekeeper quarantine, which the same research found NOT evidenced for
      `browser-actions/setup-chrome`'s actual download/unzip pipeline; or filing a new
      `rstudio/chromote` upstream issue, since no existing issue there matches this exact
      macOS+GHA+live-CDP-timeout signature).
- [ ] **Sweep the 16 accumulated `[x]`-checked DONE items out of `BACKLOG.md`** (found S619,
      2026-08-20, owner-directed via chat after noticing stale DONE entries, READY, Effort S) --
      `BACKLOG.md`'s own header states "Open, actionable work only. Completed history ->
      `CHANGELOG.md`," and `SESSION_RUNNER.md` Phase 3F calls for removing a completed item from
      `BACKLOG.md` in its closing commit, but in practice items are often left `[x]`-checked in
      place rather than deleted, and periodically swept in a dedicated batch pass -- matching
      established precedent (`95ae9d70` "S548: delete 61 resolved BACKLOG.md pointer bullets
      outright," 2026-08-13; `3ff03967` "remove 4 of 9 checked-but-unmigrated BACKLOG.md items,"
      earlier). The last sweep was S548 (2026-08-13); 16 `[x]` items have accumulated since
      (oldest from S592-era collision-avoidance work, newest S607's MIT/REUSE badges) -- spot-
      checked S619: every one already has its own dated `CHANGELOG.md` entry, so nothing is at
      risk of being lost, only redundant duplication awaiting deletion. A future session should
      confirm each of the 16 items' content is fully captured in `CHANGELOG.md` (not just spot-
      checked), then delete the checked bullets outright, matching S548's own verification-then-
      delete method.
- [ ] **Evaluate adopting `context_budget.py`, a new methodology tool shipped in canonical v3.7**
      (found S617, 2026-08-20, incidental to the v3.7 methodology sync, READY, Effort S -- a
      research/scoping session, not an implementation session) -- true upstream `KJ5HST/methodology`
      v3.7 ships a new tracked file, `context_budget.py` (+ `.context-budget.json` seed), that this
      project has never adopted (`bin/status` reports both `missing`/`absent`). Per the methodology
      repo's own `CHANGELOG.md`, it addresses "Failure mode #28 and context_budget.py -- the
      artifacts Phase 0 mandates reading now have ceilings" -- i.e. a token/context-budget tracker,
      the tooling counterpart to the FM #28 "unbounded mandatory read" failure mode this session
      DID adopt into `SESSION_RUNNER.md`. Deliberately not adopted this session (a new capability is
      a bigger decision than syncing an existing file, out of "sync to v3.7"'s own scope) -- a
      future session should read `starter-kit/context_budget.py` and its `HOW_TO_USE.md`/
      `BOOTSTRAP.md` documentation in the sibling `methodology/` checkout, decide whether it's worth
      adopting given this project already tracks file-size risk via `methodology_dashboard.py` and
      `methodology_trim.py`, and if so run `bin/sync` (or manual copy) to add it.
- [ ] **`DESCRIPTION`'s `Suggests:` mixes real test/example/vignette dependencies with
      dev-tooling-only packages that belong in a `Config/Needs/...` field instead** (found
      2026-08-20, incidental to S615's own DESCRIPTION edit, owner-directed via chat, READY,
      Effort S) -- owner-stated rule: `Suggests:` is for packages optional code in `tests/`,
      `man/examples`, or `vignettes/` actually loads; anything needed only by dev tooling (website
      building, linting, coverage, release scripts) belongs in its own `Config/Needs/<name>:`
      field instead (`pak` and similar tools understand these named dev-dependency groups), kept
      out of `Suggests:` entirely. This session already fixed one instance directly (`covr` moved
      to the new `Config/Needs/coverage: covr`, matching the file's own pre-existing `Config/Needs/
      website: quarto` precedent and confirmed via `.github/workflows/test-coverage.yaml:27`
      already installing `covr` itself via `extra-packages: any::covr`, independent of
      `DESCRIPTION`). Not fixed this session (out of Phase 2b's own scope, flagged not touched
      per owner direction): `devtools` and `roxygen2` are also listed in `Config/renv/profiles/
      dev/dependencies` (line 88) as well as `Suggests` -- redundant, or intentionally dual-listed
      for a reason not investigated this session; `pkgdown` sits in `Suggests` with no matching
      `Config/Needs/website` entry even though `quarto` (already `Config/Needs/website`) is ALSO
      still separately listed in `Suggests` -- looks like the same pkgdown-belongs-in-Config/Needs/
      website gap, not confirmed. A future session should audit every `Suggests:` entry against
      "does any file under `tests/`, `vignettes/`, or a roxygen `@examples` block actually load
      this via `library()`/`::`" and relocate anything that fails that test to the matching
      `Config/Needs/<name>` group, verifying `devtools::check()` still reports 0 new
      warnings/notes after.
- [x] **Add MIT license badge + REUSE compliance badge to `README.Rmd`** (found 2026-08-17,
      owner-directed) -- **DONE S607 (2026-08-18).** Both badges added, `README.md` re-rendered.
      REUSE compliance implemented for real, not just the badge: `reuse` CLI installed (v6.2.0),
      `LICENSES/MIT.txt` + `REUSE.toml` added (blanket MIT/R. Mark Sharp, with a carve-out for
      `renv/activate.R` and the 4 `man/figures/lifecycle-*.svg` files, both third-party/Posit
      Software PBC). `reuse lint`: 1234/1234 compliant. `devtools::check()`: 0 new NOTEs. See
      `CHANGELOG.md` and `PROJECT_LEARNINGS.md` Learning 627.
- [ ] **Register `rmsharp/nprcgenekeepr` with api.reuse.software so the REUSE badge renders its
      real compliance status** (found S607, 2026-08-18, DECISION NEEDED / owner action, Effort S)
      -- the badge added above currently renders gray **"unregistered,"** not green: hitting
      `https://api.reuse.software/badge/github.com/rmsharp/nprcgenekeepr` directly returns an
      "unregistered" SVG, and `https://api.reuse.software/info/...` returns "Project not
      registered." This REUSE API service requires a one-time manual registration at
      https://api.reuse.software/register (repo URL + an email address, confirmed via a
      confirmation email) before it will crawl and report a project's actual compliance state --
      this is not something a session can or should do on the owner's behalf (it ties an email
      address to the public registration and is a one-way "join the registry" action). The repo
      itself IS `reuse lint`-compliant now (1234/1234, verified locally); only the badge's live
      display is blocked on this registration step. A future session can verify the badge went
      green after the owner registers, but cannot perform the registration itself.
- [x] (found S584, 2026-08-15, incidental to running the build equivalent during close-out,
      **RESOLVED S587.** Added the 4 flagged words (`matings`, `Rectilinear's`, `runnable`,
      `visNetwork's`) to `inst/WORDLIST`, each placed at its alphabetic neighbor; all 4 confirmed
      via grep as legitimate tracked-source domain/package-name terms (`NEWS.md`/`vignettes/
      articles/pedigree-diagram.qmd`), not typos, before whitelisting. `devtools::check()` --
      the literal CI-matching build equivalent -- now returns 0 errors/0 warnings/1 pre-existing
      unrelated NOTE (the long-known `vignettes/figure/` knitr leftover); `test_wordlist_
      coverage.R` passes 3/3. See `CHANGELOG.md` and `PROJECT_LEARNINGS.md` Learning 595.
      Original finding, kept for the record:) **`devtools::check()` -- the project's own
      documented build equivalent -- was RED on `master` and had been since S573, with no session
      reporting it.** Final line:
      `1 error | 0 warnings | 1 note`. The error is `test_wordlist_coverage.R:121` failing because
      `inst/WORDLIST` does not cover 2 words `spelling::spell_check_package()` flags: **`matings`**
      (`NEWS.md:232`) and **`visNetwork's`** (`NEWS.md:208`). Both entered `NEWS.md` in `c9860f4b`
      (S573, 2026-08-14 14:34). The note is the long-known `vignettes/figure/` knitr leftover
      (already tracked elsewhere in this file). Under the `test_dir` clean-regression read the same
      test flags **4** words (`matings`, `Rectilinear's`, `runnable`, `visNetwork's`) rather than 2,
      because that read sees the vignette `.qmd` sources while the built package under `check()`
      sees only `NEWS.md` -- so a fix must cover all 4, not just the 2 `check()` reports.
      **Fix is expected to be a one-line `inst/WORDLIST` addition** (all 4 are legitimate domain or
      package-name terms, not misspellings), plus a re-run of the build equivalent to confirm it
      returns to `0 errors`. Not fixed in S584 (a second deliverable, out of that session's
      diagnose-the-CI-failure scope -- `PROJECT_LEARNINGS.md` Learning 382's report-don't-fix
      precedent). **The open `NOT_CRAN`/masking question this item originally raised is now
      ANSWERED** (same session, after the S584 push let CI run against current `HEAD`): **CI is NOT
      masking it.** `R-CMD-check.yaml` (run `31868761411`) failed on **all 5 platform jobs** --
      ubuntu release/devel/oldrel-1, macOS release, Windows release -- each with the identical
      `Status: 1 ERROR, 1 NOTE` and the same `test_wordlist_coverage.R:121` failure naming `matings`
      and `visNetwork's`. `r-lib/actions` sets `NOT_CRAN`, so `skip_on_cran()` never fires and the
      test genuinely runs in CI. **This is therefore a live CI red on every platform, not merely a
      local one.** It also settles the S581 discrepancy recorded below: the failure is real,
      reproducible and platform-independent, so S581's reported "0 errors" does not hold up --
      treat any `devtools::check()` claim in handoffs from S573 onward as unverified until re-run.
      Original note, kept for the record: S581's own handoff reports
      `devtools::check()` as "0 errors/0 warnings/1 pre-existing NOTE" at a close-out ~9 hours AFTER
      `c9860f4b` landed. S584 could not reconstruct why that run differed and deliberately drew no
      conclusion; a session fixing this should note that `test_wordlist_coverage.R:113` calls
      `skip_on_cran()`, so whether the test runs at all depends on `NOT_CRAN`, which differs between
      a bare `R CMD check` and `devtools::check()` (the latter sets it) -- that is the most likely
      explanation to check first, and it also determines whether CI's own `R-CMD-check.yaml` is
      currently masking this failure. See `CHANGELOG.md`.
- [x] (found S584, 2026-08-15, incidental to diagnosing the red scheduled `shinytest2.yaml` run,
      **RESOLVED S584 -- owner directed "push" in-session; the unpushed state was NOT deliberate.**
      Pushed `7021c6f7..7436a7a9`, 148 commits, clean fast-forward, no force. `master` and
      `origin/master` now in sync. The 4 push-triggered workflows fired automatically;
      `shinytest2.yaml` was additionally dispatched by hand (`gh workflow run shinytest2.yaml
      --ref master`, run `31868762486`) because it has no push trigger -- exactly as this item
      predicted. Outcome of those 5 runs is recorded in `CHANGELOG.md`. Original finding, kept for
      the record:) **Local `master` was 145
      commits ahead of `origin/master` and unpushed, so every scheduled CI workflow is testing a
      snapshot from Session 545 (`7021c6f7`, 2026-08-13) rather than current work.** Confirmed from
      the failing run's own log (`Commit: 7021c6f7...`, `git checkout ... refs/remotes/origin/master`)
      and `git rev-list --count origin/master..master` = 145. Two live consequences, both hit during
      S584's diagnosis: **(a)** the nightly `shinytest2.yaml` red/green signal says nothing about the
      code actually being written -- S584's own fix for the genuine defect it found is verified
      locally but CANNOT be observed green in CI until a push happens, since that workflow is
      `schedule`/`workflow_dispatch` only (no push trigger); **(b)** CI logs from a stale snapshot
      produce false defect signals -- S584 initially read a missing `^e2e-twin-relations-` module
      group in the CI log as a possible Learning-312 partition-drift defect, when in fact both that
      test file and its group regex were added together in the unpushed `c91f7c49` and are correct
      at `HEAD`. The 4 push-triggered workflows (`R-CMD-check`, `lint`, `pkgdown`, `test-coverage`)
      are likewise reporting on 145-commit-old code, and have not run against any work since S545.
      **Not acted on unilaterally** -- a push of 145 commits is an owner call, not a housekeeping
      decision a session should make on its own (and `master` carries no branch protection, so a
      push is immediately live). The owner then directed the push in the same session, which is why
      this item opened and closed within S584. See `PROJECT_LEARNINGS.md` Learning 592 and
      `CHANGELOG.md`.
- [x] (found S579, 2026-08-14, incidental to this session's own post-close-out ledger re-check;
      **RESOLVED S580**. **`HANDOFFS.md`'s own archive trigger fired** (line headroom 4 records,
      125,404 B against the 65,536 B budget). `--write` (dry run) refused with `SRF_RED` (SRF
      1.1566 against the most-recent archive `306a4b4` vs. 0.1201 against the largest-drop
      boundary `d07814a`, 9.63x spread) -- the same recurring shape Learnings 549/550/586
      diagnosed, now confirmed on this file too (`PROJECT_LEARNINGS.md` Learning 587). Pulled
      absolute byte deltas for both boundaries (116,204 B genuine regrowth in ~1 day vs. `306a4b4`,
      driven by 10 receipts averaging ~12.5 KB each); surfaced via `AskUserQuestion`
      (force/hold/raise-budget) -- owner chose **force**. Dry-run preview with `--force` confirmed
      L1/L2/L3 losslessness (21 of 22 records, 125,404 B -> 9,682 B) before writing; ran
      `--write --force`; the new shard's own `verify.sh` confirmed OK; post-trim `--check` clears
      both triggers (9,682 B, SRF non-positive against both boundaries). See `CHANGELOG.md`.)
- [x] (found S575, 2026-08-14, owner review of a published live-comparison artifact; **DESIGN
      RATIFIED S576, 2026-08-14; IMPLEMENTED S578, 2026-08-14 -- DONE**) **Pedigree Diagram:
      children are frequently rendered far from their own parent union -- a real, widespread
      legibility gap, distinct from and not caught by Track 5's diagonal-edge measurement.**
      Root cause: a mating unit's final x was the midpoint of its 2 real parents' positions,
      decoupled from where its own child was positioned during the earlier recursive descent.
      Design: `docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md`
      (Extended Candidate A -- recompute the union's x from its own children's final span,
      recompute the duplicate-parent node's x from the new union x, broaden the existing
      de-collision pass to cover duplicates). **Implementation (S578):** Pre-RED empirical
      validation found 2 corrections beyond the ratified design doc's own §2.1 snippet: (1)
      `finalUnitX`/`dupX` must be computed AFTER the `orderBySex` block, not at its
      literally-described pre-orderBySex location, or the invariant breaks for any union whose
      child is also swapped as a parent in a deeper union (measured 19/251 >200-unit violations
      without the reorder vs. the ratified 9/251 with it); (2) 3 real-individual x values (not
      just union/duplicate) shift as a side effect of removing duplicates from Track 3's sweep
      pool -- a real, non-epsilon consequence (`9VGCCV`, 0.5 units) the design doc's own §5
      Impact Analysis table did not state. Implemented with the reorder; re-measured on the real
      375-individual fixture: violating edges 100/251 -> 9/251 (91% reduction), worst-case
      offset 10,687 -> 4,121.37 (matches ratified figures), duplicate-to-union distance 61.94/
      120.12 -> 48.00/48.00 (exact match), 0 exact x/gen coincidences post-fix (including 1
      pre-existing duplicate/union coincidence unrelated to this decision, closed as a side
      effect). Full clean regression 1 pre-existing failure unrelated (`test_wordlist_coverage.R`,
      confirmed via the full suite run before vs. after); `lintr::lint_package()` 0 lints on
      touched files. Live/visual verification: rendered + chromote-screenshotted the small
      GA204Z/8LKBV9 fixture (both `edgeStyle` values) and the full real fixture (both values,
      0 console errors) -- visually confirmed a union now sits close to its own child (matches
      the fix's intent) and the duplicate dashed-connector convention is unaffected.
      **`devtools::check()`** (run as its own separate build-equivalent step, not skipped as
      redundant with the already-green `test_dir()` regression) **found a genuinely PRE-EXISTING
      latent defect this session's own change first exposed:** the de-collision pass's `order()`
      tie-break on node id strings is locale-dependent (`LC_COLLATE`), so which of 2 exactly-tied
      nodes absorbs the 1e-3 epsilon nudge could differ between an interactive session's locale
      and `R CMD check`'s own build environment -- reproduced directly via `LC_ALL=C`. Fixed with
      `method = "radix"` (locale-independent byte-order) on both affected `order()` calls;
      re-verified both locales now produce identical, matching output. See `PROJECT_LEARNINGS.md`
      Learning 585. See `CHANGELOG.md`.
- [x] (found S578, 2026-08-14, a broader grep sweep after fixing the locale-dependent `order()`
      defect above, **RESOLVED S581**. **The same locale-dependent `order()` tie-break class
      (`PROJECT_LEARNINGS.md` Learning 585) existed more broadly across the package.** Fresh
      `grep -n "order(" R/*.R` (26 call sites) classified all: 17 not locale-sensitive (numeric/
      index sort keys), 2 already `method="radix"` (Track 6). Of the 6 initially flagged as real
      hits (character-column sorts), empirical verification (RED-phase divergence testing,
      `withr::with_locale`) corrected 2 to FALSE POSITIVES: `kinshipMatrixToKValues.R:107`
      (protected by `data.table`'s own `[.data.table]` auto-substitution to `forder()`, confirmed
      via `datatable.verbose`) and `computeGenomicROH.R:112` (the intermediate `fullMeta` row
      order IS locale-sensitive, but the returned value is provably invariant -- `split()` groups
      by chrom regardless of inter-group order, same-chrom tie-breaking uses the numeric `pos`
      key; confirmed identical output across `LC_COLLATE="C"` vs. `"en_US.UTF-8"`). Explanatory
      comments left in both files documenting why, so a future session re-running this grep
      doesn't re-derive the investigation. **4 real hits fixed** (`method = "radix"` added,
      RED->GREEN->REFACTOR): `orderReport.R:81,93` (imports/noParentage tiers),
      `qcStudbook.R:323` (`order(gen, id)`), `modBreedingGroups.R:690` `bgGroupView` (Ego ID,
      no prior test coverage of this reactive existed -- new `shiny::testServer()` test added).
      Verification: 4 targeted RED tests GREEN; full clean regression 1 pre-existing failure
      unrelated (`test_wordlist_coverage.R`), 0 errors; 0 lints on touched files
      (`lintr::lint_package()`, project's own `.lintr` config); `devtools::check()` 0 errors/0
      warnings/1 pre-existing NOTE; live E2E (`NPRC_RUN_E2E=true`) confirmed all 3 affected
      runtime paths -- `test-e2e-mate-pair-analysis-module.R` (qcStudbook), `test-e2e-genetic-
      value-tutorial.R` (orderReport/reportGV), `test-e2e-breeding-groups-module.R` (bgGroupView)
      -- all pass. See `PROJECT_LEARNINGS.md` Learning 588. See `CHANGELOG.md`.
- [x] (found S576, 2026-08-14, incidental to Track 6's own empirical validation of the
      child-centered union-position design, **DESIGN SESSION DONE S588, 2026-08-15 -- DECISION:
      COMMIT to a redesign (owner corrected mid-session from an initial DEFER, see below).**)
      **Pedigree Diagram: sibling subtree-width asymmetry -- 2-3 direct children of the same mating
      unit can land far apart in x purely because their own descendant-subtree sizes differ,
      independent of where the union itself is positioned.** Design session
      `docs/planning/pedigree-diagram-sibling-subtree-width-plan.md` (evidence:
      `docs/planning/pedigree-diagram-sibling-subtree-width-evidence.qmd`) built a synthetic
      reproduction, rendered it via kinship2 and nprcgenekeepr side by side, and empirically tested
      the one plausible low-risk candidate (a bounded-depth contour-merge lookahead in
      `.positionMatingUnitForest()`). **Rejected**: it closes the sibling gap on the toy example but
      introduces a genuinely worse defect (2 siblings' own connecting lines cross) and *regresses* a
      simplified real-fixture measure (3.2% vs. the shipped algorithm's 0.8% under the same proxy
      methodology) -- the opposite direction from the toy example. Deeper finding (design doc §1.6):
      **no low-risk tuning of the current algorithm can fix this at all** -- `.positionMatingUnitForest()`
      uses the same rigid-subtree model as Reingold-Tilford/Walker/Buchheim-Jünger-Leipert (issue
      #141's own named target), all of which compute the *same* layout faster, not a tighter one; a
      real fix needs a different layout paradigm entirely. First ratified as DEFER (document as
      inherent, file a low-priority tracker) -- **owner corrected mid-session: "these layout issues
      are a high priority and may require a lot of work; the work cost is not a deterrent."**
      Re-ratified via a second `AskUserQuestion`: commit to the redesign, scoped as a dedicated
      follow-up effort (see the new item directly below), not an immediate code change in this
      planning session. Companion GitHub issue
      [#159](https://github.com/rmsharp/nprcgenekeepr/issues/159) filed and then updated same-session
      to reflect the priority correction (title/body rewritten, `premature optimization` label
      removed). See `CHANGELOG.md` and `PROJECT_LEARNINGS.md` Learning 596.
- [x] (found S588, 2026-08-15, design session for the item directly above,
      **RESOLVED S589 -- NOT FEASIBLE.**
      `docs/planning/pedigree-diagram-nonrigid-layout-spike-plan.md` +
      [`-evidence.qmd`](../docs/planning/pedigree-diagram-nonrigid-layout-spike-evidence.qmd)).
      Prototyped a barycenter/median layered-DAG compaction candidate (owner-selected via
      `AskUserQuestion`, over a force-directed alternative). Synthetic 13-individual example:
      modest real improvement (A-B gap 2.5->2.0, 20% reduction), zero edge crossings (row order
      provably preserved by construction, verified empirically). Real 375-individual fixture,
      faithful full-pipeline measurement (harness verified byte-identical to the shipped
      algorithm; baseline reproduced Track 6's own published 9/251, 3.6%, max 4,121.25 exactly):
      **regressed** to 15/251 (5.98%), max offset 5,344, overall layout width 6.1x wider --
      consistent across a 5-point hyperparameter sweep, never better than 15/251. Root cause
      diagnosed: convergence instability at high-mate-count "hub" individuals (found one sire
      with 5 separate mating unions) -- a structural feature entirely absent from the small
      synthetic example. Found and fixed 2 real implementation bugs along the way (an unbounded
      Jacobi-update ratchet; a self-referential down-sweep target), documented for any future
      attempt. This is the SECOND independently-designed candidate (after S588's own
      bounded-lookahead candidate) to improve the toy example while regressing the real fixture,
      via a different failure mechanism each time (edge crossings there; convergence instability
      here). Ratified via `AskUserQuestion`: **recommend a second, narrower spike adapting a
      proven, convergence-guaranteed implementation** (e.g. `igraph::layout_with_sugiyama()`,
      confirmed a well-established CRAN package though not installed in this environment) rather
      than tuning this candidate further; campaign document deferred until that spike has
      evidence. See `CHANGELOG.md` and `PROJECT_LEARNINGS.md`.
- [x] (found S589, 2026-08-15, follow-on to the item directly above,
      **RESOLVED S590 -- NOT FEASIBLE; INVESTIGATION CLOSED AS INHERENT.**
      `docs/planning/pedigree-diagram-layout-sugiyama-spike-plan.md` +
      [`-evidence.qmd`](../docs/planning/pedigree-diagram-layout-sugiyama-spike-evidence.qmd)).
      Adapted `igraph::layout_with_sugiyama()` (owner-selected via `AskUserQuestion` over a ported
      Brandes-Köpf 2002 alternative; `igraph` confirmed installable, used investigation-only, not
      added to `DESCRIPTION`). Synthetic 13-individual example: matched the first spike's own
      improvement (A-B gap 2.5->2.0, 20% reduction), 0 crossings (best of 20 random-vertex-order
      restarts -- found necessary: the natural construction order hit an avoidable 4-crossing
      local optimum; multi-restart is standard practice for this class of heuristic). Real
      375-individual fixture, faithful full-pipeline measurement (harness re-verified
      byte-identical to shipped source via `pkgload::load_all()`; baseline reproduced 9/251, 3.6%,
      max 4,121.25 exactly): **regressed on every axis measured** -- 25/251 (9.96%), max offset
      10,110, layout width 2.4x wider, AND crossings worse than baseline (5,916 vs 3,174, despite
      crossing-minimization being this algorithm's own objective). Not a tuning artifact:
      confirmed across a 4-point restart/seed sweep and an edge-weight check (`weights` param had
      zero measurable effect with explicit `layers` supplied -- a checked, reported limitation).
      Root cause diagnosed: a different high-mate-count hub individual (4 mating unions);
      mechanism differs from the first spike's convergence instability -- sugiyama's own global
      crossing/straightness objective has no term preserving one union's full-sibling compactness,
      unlike the shipped model's recursive contour-merge, which achieves it by construction. THIRD
      independently-designed candidate (bounded-lookahead, barycenter/median, now a proven
      library) to improve the toy example while regressing the real fixture, via a THIRD distinct
      failure mechanism each time. Ratified via `AskUserQuestion`: **close the non-rigid-layout
      investigation as inherent** -- 3 independent paradigms converging on the same real-fixture
      failure pattern is sufficient evidence the current rigid-subtree model is a reasonable local
      optimum; stop pursuing further spikes on this thread without new evidence that changes the
      picture. One untested idea recorded for the record, not pursued (§2 of the plan doc): a
      hybrid "order-then-compact" approach (sugiyama's proven low-crossing order, fed into a
      contour-merge-style compaction pass instead of sugiyama's own coordinate assignment).
      Companion GitHub issue [#159](https://github.com/rmsharp/nprcgenekeepr/issues/159) closed
      same-session citing this cumulative 3-candidate evidence. Incidental finding, reported not
      fixed: the renv-cached installed `nprcgenekeepr` build was stale (predates Track 6 by
      ~3.5h) -- `pkgload::load_all()` used throughout instead of `library()`. See `CHANGELOG.md`
      and `PROJECT_LEARNINGS.md`.
- [x] (found S583, 2026-08-15, incidental to a user question about the just-reshot
      `pb_diagram_legend.png` screenshot. **RESOLVED S596 (2026-08-16)** — Track 3's parent-span
      clamp above closes this item exactly as scoped S592; `__union_1` now lands at x=60 (the
      dam's own boundary), inside `[-60,60]`, byte-for-byte reproduced against this item's own
      concrete example. 2 disclosed trade-offs found during REFACTOR — see the new follow-up item
      above. Original finding, kept for the record:) **Pedigree Diagram: a mating union with a single child (or
      whose children's own midpoint happens to fall outside the parents' span) can be positioned
      entirely OUTSIDE its own two parents' x-range, not merely off-center between them --
      diverges from kinship2's own convention, which always centers the union symbol between the
      two spouses regardless of where children end up.** Distinct from the S576 sibling
      subtree-width item directly above: S576 measures how far a union ends up from ITS OWN
      CHILDREN; this finding is about how far the union can end up from ITS OWN PARENTS -- an axis
      Track 6's own verification (`docs/planning/pedigree-diagram-track6-child-centered-union-
      position-plan.md` §1.4/§2.4) never measured, because `finalUnitX[U] ==
      (min(x[C]) + max(x[C])) / 2` (unconditional midpoint of a union's children) has no term for
      the union's own parents at all. For a union with exactly one child, this collapses to
      `finalUnitX[U] == x[thatChild]` -- zero centering benefit (nothing to center between) while
      actively decoupling the union from its parents' span if that one child's own x has been
      pulled elsewhere by ITS OWN later descendants. **Concrete, reproduced example** (the real
      `obfuscated_rhesus_mhc_ped.csv` fixture, `trimPedigree(c("8LKBV9","FJIB3R","GA204Z"), ped)`,
      the same 6-animal subgraph `pb_diagram_legend.png` depicts): `5A6DFT` (sire) x = -60,
      `8DKELJ` (dam) x = 60, their union (`__union_1`, sole child `8LKBV9`) x = **120** -- entirely
      outside the `[-60, 60]` parent span, past the dam, because `8LKBV9`'s own x is pulled right
      by his own 2 further-generation matings (verified live via `makePedigreeMatingLayout()`,
      exact coordinates reproduced from the live layout function, not estimated). Built the
      identical 6-subject pedigree in `kinship2::pedigree()`/`plot.pedigree()` as a direct
      side-by-side reference: kinship2 draws the descent line from the exact midpoint between
      `5A6DFT` and `8DKELJ`, never displaced outside their span, confirming this is a real
      divergence from kinship2 parity, not a stylistic difference this project has already
      accepted. Not investigated further this session (no candidate fix evaluated) -- likely needs
      its own design session, since a fix must decide how to reconcile "center on children" (Track
      6's own stated goal, still valid for multi-child unions) with "never leave the parents' own
      span" (kinship2's invariant) without reopening Track 6's already-ratified formula wholesale.
      **Confirmed again live (2026-08-15, found in conversation, not a claimed session):** the
      same single-child collapse (`finalUnitX[U] == x[thatChild]`) reproduced 3 more times in one
      small 9-person fixture (`kinship2-fidelity-validation.qmd`'s Track C consanguineous
      example) -- the X&times;A, A&times;Y, and W&times;Y unions each sit exactly at their one
      child's x rather than their own parents' midpoint. See
      [issue #160](https://github.com/rmsharp/nprcgenekeepr/issues/160)'s comment thread for the
      full coordinate evidence (a related but distinct finding on the same fixture). Not filed as
      its own issue -- this is the same already-tracked gap, not a new one. **Scoped for a fix,
      S592 (2026-08-15):** this is exactly what "Implement Track 3 (S583 parent-span clamp)"
      above resolves --
      [`docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`](docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md)
      §2.3. A future implementation session should close this item when Track 3 ships, not treat
      it as a separate unscoped design question.
- [x] (found S574, 2026-08-14, incidental to Track 2's default-flip documentation pass,
      **RESOLVED S582**. **`shiny_app_use/pb_diagram_legend.png` (used in both
      `vignettes/articles/colony-manager-guide.qmd` and `vignettes/articles/pedigree-diagram.qmd`)
      visibly showed the "Direct" radio button pre-selected** -- accurate when captured, but Track 2
      (S574) flipped the Diagram tab's own zero-interaction default to "Rectilinear", so the
      screenshot's own radio-button state (and its diagonal-line routing) no longer matched what a
      fresh session actually rendered (mirrors the S461/S544 stale-screenshot pattern already
      resolved once for this same image, S560). **Fixed (S582):** recaptured via the live app
      (`shinytest2`/chromote), same fixture/focal-animal set the canonical
      `vignettes/articles/pedigree-diagram-screenshots.R` script's own "Base fixture" step uses
      (`obfuscated_rhesus_mhc_ped.csv`, focal ids `8LKBV9`/`FJIB3R`/`GA204Z`, selector
      `#pedigree-moduleContainer`) -- deliberately no `pedigreeEdgeStyle` interaction, so the shot
      captures whatever the app's own zero-interaction default renders (confirmed live via
      `R/modPedigree.R`'s `.currentEdgeStyle()`, which now returns `"rectilinear"` when
      `input$pedigreeEdgeStyle` is `NULL`). New screenshot confirmed showing "Rectilinear
      (kinship2-style)" pre-selected with right-angle edge routing, diffed visually against the
      prior committed image (extracted via `git show 2b3e8ef6:...`) to confirm only the intended
      radio-button/routing state changed. Build-equivalent verification: `pkgdown::build_article()`
      for both `articles/pedigree-diagram` and `articles/colony-manager-guide` rendered clean via
      `quarto render`, and the built HTML's embedded image was MD5-confirmed identical to the new
      source PNG (not a stale cached copy); render litter (`pkgdown_site/`, `pkgdown/`) removed
      before commit. Neither article's surrounding prose needed a text change -- both already said
      "under the default Rectilinear edge style" (already updated by Track 2's own S574 pass), so
      only the image itself was stale. One incidental finding, not fixed (out of this item's scope,
      matching `PROJECT_LEARNINGS.md` Learning 382's "report, don't fix mid-session" precedent):
      `vignettes/articles/pedigree-diagram-screenshots.R`'s other 3 non-base-fixture screenshots
      (`diagram_show_names.png`, `diagram_affected_shading.png`, `diagram_twin_connectors.png`)
      also never set `pedigreeEdgeStyle` before capture, so they may have gone stale by the exact
      same default-flip mechanism -- not verified either way this session, a future session should
      check.
- [ ] (found S582, 2026-08-14, incidental to the `pb_diagram_legend.png` reshoot above, READY,
      Effort S -- not verified) **`vignettes/articles/pedigree-diagram-screenshots.R`'s other 3
      non-base-fixture screenshots may have gone stale by the same default-flip mechanism as
      `pb_diagram_legend.png` above.** `diagram_show_names.png`, `diagram_affected_shading.png`,
      and `diagram_twin_connectors.png` are each captured without ever setting
      `pedigreeEdgeStyle` (see the script's own "3.", "4.", "5." sections) -- like
      `pb_diagram_legend.png` before this session's fix, each therefore renders whatever the app's
      zero-interaction default is, which Track 2 (S574) changed from "direct" to "rectilinear". If
      any of these 3 committed images still show diagonal (`direct`-style) edge routing, they are
      stale in the same way `pb_diagram_legend.png` was. Not checked this session (out of the
      pb_diagram_legend.png item's own scope) -- a future session should open each and confirm,
      reshooting via the same script/technique if stale.
- [ ] (found S508, 2026-08-10, re-surfaced S559, 2026-08-13, **RESOLVED S561**.
      **`HANDOFFS.md`'s declared `methodology_trim.py` regenerated field ("retained
      receipt count") had no matching "This file currently holds **N**" sentence in the
      file's own front matter**, so the tool's own `apply_regenerated()` printed a soft
      `FRONTMATTER_FIELD_ABSENT` finding on every real archive `--write` (not, it turns
      out, on every `--check` too -- corrected finding below). Owner picked the "add the
      sentence" remedy via `AskUserQuestion`, over removing the `regenerated` config
      entry. Added "This file currently holds **3** receipt(s)." to `HANDOFFS.md`'s front
      matter, immediately after the last "Archived N record(s)..." pointer block,
      matching `SESSION_NOTES.md`'s/`CHANGELOG.md`'s own bold-number pointer convention.
      Verified two ways since the live archive trigger doesn't fire this session (20-record
      headroom, well under the byte budget): (1) a direct unit-check importing
      `methodology_trim`'s own `LEDGERS["HANDOFFS.md"].regenerated[0]` regex against the
      new sentence confirms it matches and extracts the correct old value; (2) a dry-run
      `--cut @<sha>` (no `--write`) confirms the live file's own record parser counts
      exactly 3 records, matching the sentence. **Correction to the original finding's own
      framing:** re-reading `methodology_trim.py`'s control flow shows `--check` returns
      immediately after reporting the trigger status and never reaches
      `apply_regenerated()` at all -- only a real `--write` that actually builds an
      archive plan (trigger fires, or an explicit `--cut`) does. The "every check/write
      run" framing in the original S508 finding was inaccurate (or true only of an older
      tool version); the field was absent only on the 3 real archive `--write` passes to
      date, not on ordinary `--check` calls. See `CHANGELOG.md`.)
- [ ] (found S555, incidental to the consanguineous-marker PRE-RED
      investigation above, **FIXED S556**. **A dangling (no-own-row)
      parent anywhere in a pedigree silently widened
      `.positionMatingUnitForest()`'s `genOf` from integer to double,
      which could spuriously trigger `.addRectilinearWaypoints()`'s D2
      "dogleg" reroute on OTHER, unrelated, correctly-matched mate-line
      edges elsewhere in the same diagram.** Root cause: the dangling-
      parent gen fallback used `vapply(danglingIds, ..., numeric(1L))` --
      forcing a double even though the value it returns
      (`matingUnits$gen`) was already integer -- and `genOf <- c(genOf,
      ...)` then silently widened the WHOLE `genOf` vector via R's own
      type-promotion rule, corrupting `.addRectilinearWaypoints()`'s
      strict, type-sensitive `identical(side$gen, Ugen)` comparison.
      Fixed: `numeric(1L)` -> `integer(1L)` (matches the value's actual
      source type). Empirically confirmed on a 5-row reproduction fixture
      (an unrelated, already-on-row union spuriously doglegged purely
      because a second, unrelated union referenced a dangling parent --
      0 spurious nodes after the fix). Scope was `edgeStyle =
      "rectilinear"`-only; the bundled 375-individual real fixture has no
      dangling parents and was never affected. 4 new/updated unit tests
      (3 `expect_type(pos$gen, "integer")` assertions added to existing
      `test_positionMatingUnitForest.R` dangling-parent tests -- existing
      `expect_equal()`-based assertions are type-blind to this class of
      bug, `PROJECT_LEARNINGS.md` Learning 562 -- plus 1 new end-to-end
      regression test in `test_addRectilinearWaypoints.R`). `devtools::
      check()` 0 errors/1 pre-existing warning/1 pre-existing note (both
      unrelated); full clean regression 0 failed/0 error; live E2E
      (`test-e2e-pedigree-module.R`) 15/15, 0 regressions;
      `lintr::lint_package()` 0 lints. Not filed as a GitHub issue.)
- [ ] (found S552, **RESOLVED S558**. **Repository branch cleanup, all 12 stale branches
      now deleted.** S557 deleted 7 confirmed-safe branches (0 commits ahead of `master`,
      prior PR merged) via mechanical mergedness/PR-history checks. The remaining 5 --
      `module`, `issue8`, `issue8-fix`, `marks-broken-issue8`, `nprcmanager-master` -- each
      had real unmerged commits and no PR history, so mergedness alone couldn't establish
      "safe." S558 read each branch's actual diff content (commit history, diffstats,
      merge-bases, and targeted function/file cross-checks against `master`) rather than
      relying on mergedness status: `module`'s merge-base with `master` sits exactly where
      master's own modularization work began (`3773e63b`, 2025-12-30) -- master went on to
      independently complete that same effort more thoroughly (incl. a `feat!: Phase 9`
      commit deleting the legacy `inst/application` app that `module` never got); of
      `module`'s 120 files absent from `master`, none were a substantial unique capability
      (mostly the legacy app, superseded sample data, and small 21-110-line scratch
      helpers/test modules with modern equivalents already on `master`, e.g.
      `nprcgenekeeper.R` -> `R/nprcgenekeepr-package.R`). `issue8`/`issue8-fix`/
      `marks-broken-issue8` all shared the same ancient 2021-04-21 merge-base;
      `issue8-fix`/`marks-broken-issue8` were near-duplicates of each other (8 files
      differ); every named function traceable from their commits
      (`createSimKinships`/`cumulateSimKinships`/`getPotentialParents`/
      `summarizeKinshipValues`/`countKinshipValues`/`kinshipMatrixToKValues`/
      `combinerKinshipTriangles`) already exists on `master` today, complete with `man/`
      docs and `tests/testthat/` coverage. `nprcmanager-master` shared **no merge-base at
      all** with `master` (a disjoint root) -- the project's literal first 8 commits under
      its original "nprcmanager" name (2017). Findings presented to the owner via
      `AskUserQuestion`; all 5 approved for deletion. Deleted: `module` (local+remote),
      `issue8`/`issue8-fix`/`marks-broken-issue8`/`nprcmanager-master` (remote only).
      `git branch -a` now shows only `master` and `gh-pages` (the live `pkgdown.yaml`
      deploy target, confirmed live and excluded from cleanup by S557). See
      `CHANGELOG.md`.)
- [ ] (found S545, **verified S549** -- see
      `docs/audits/KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md`. **Verify the
      results in `inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf` (kinship2's
      supplementary material) can be reproduced with `nprcgenekeepr`'s own exported
      functions.** Scope caveat found first: the full 17-subject `fam1` pedigree cannot be
      exactly reconstructed from this repo's materials (its Figure 1 lives in the kinship2
      *main* paper, not this supplement, not among the repo's other reference PDFs, and not
      shipped in any installed `kinship2` dataset) -- audited the fully-specified 10-subject
      Figure S1 subset instead, reconstructed from Table S1's own kinship values (verified,
      not guessed from the figure). Result: `kinship()`'s autosomal matrix reproduces Table S1
      **exactly** except cells touching the pedigree's one MZ-twin pair (a real, if
      narrow-trigger, capability gap -- see the 2 new items below); pedigree-diagram structure
      (nodes/edges/generations/twin-connector) is correct via `makePedigreeDiagramData()`/
      `makePedigreeMatingLayout()`; kinship2's `pedigree.shrink()` (bit-size-driven,
      availability/affected-status trimming) has no `nprcgenekeepr` equivalent, judged a
      capability-fit non-issue (different problem domain, not this package's mission); no
      X-chromosome-specific kinship computation exists (also judged out of current scope). See
      the audit doc for the full evidence, including a `kinship2`-reproduced side-by-side
      confirming the MZ-twin gap's mechanism precisely. **Note, RESOLVED S567:** the PDF's
      copyright/licensing classification (untracked in git, absent from
      `.gitignore`/`.Rbuildignore` unlike its copyrighted siblings in the same directory) was
      unresolved since S545. Owner decision (via `AskUserQuestion`, 2026-08-14): gitignore it,
      matching the S479/S497 precedent -- it is an NIHMS/PMC deposit (free reading access under
      NIH's public-access policy) but that is not confirmed to carry third-party redistribution
      rights, so it is excluded from this PUBLIC repo out of the same caution as the other 3
      files, not because it fails their "no open-access marking" test. `.gitignore`/
      `.Rbuildignore` both updated; verified by an actual `R CMD build` that the file is now
      excluded from the built tarball (the file remains on local disk, still usable by
      `data-raw/kinship2FidelityValidation.R`). See `CHANGELOG.md`.)
- [ ] **Thread `twinRelations` into `kinship()`'s computation, not just diagram rendering**
      (found S549, Finding #1 of the above audit; design RATIFIED S550; **all 3 slices DONE
      S551-S553, RESOLVED**, see `docs/planning/twin-relations-kinship-computation-plan.md`)
      -- `nprcgenekeepr` already had a twin-declaration data
      model (`checkTwinRelations()`, issue #137) but it feeds only the Diagram tab; every
      kinship-driven calculation silently treats a declared monozygotic-twin pair as ordinary
      full siblings, understating their kinship and understating every relative reached
      through either twin (transitively, not just the direct pair -- kinship2's own behavior).
      Ratified design: extend `kinship()`'s own signature with a new `twinRelations = NULL`
      parameter (porting kinship2's `mzgrp`/`mzindex` in-loop-correction mechanism directly --
      a post-hoc single-pass patch on the finished matrix was proven mathematically
      insufficient, since it cannot correctly propagate to a twin's descendants); `kinship()`
      trusts a pre-validated `twinRelations` (documented precondition) rather than
      re-validating internally, since its flat-vector signature has no `sex` parameter to run
      `checkTwinRelations()`'s full rule set itself. **Slice 1 (core algorithm) DONE S551**:
      `kinship()` gained the `twinRelations` parameter, verified against `kinship2`'s own
      ground truth on the audit's 10-subject fixture (`kinship(8,9)=0.5`,
      `kinship(9,10)=0.28125`, exact matches) plus a 3-member transitive-group fixture and a
      DZ/UZ-coded zero-treatment fixture; `devtools::check()` 0 errors/0 warnings; full clean
      regression read 0 failed/0 error. `R/applyKinshipOverrides.R`'s "never modified" roxygen
      sentence updated per Dragon 2. **Slice 2 (the 4 script-callable functions) DONE S552**:
      `reportGV()`, `gvaConvergence()`, `createSimKinships()`, `cumulateSimKinships()` each
      gained their own `twinRelations = NULL` parameter passed straight through to their
      internal `kinship()` call; `test_gvaConvergence.R` was confirmed to already exist
      (Dragon 4 resolved, no new file needed). Verified: `reportGV()`'s returned `$kinship`
      matches Slice 1's own ground truth exactly with twins declared; `gvaConvergence()`
      accepts the parameter and threads it without error (its own convergence-curve output has
      no kinship-observable surface at this fixture's scale -- the same documented limitation
      `test_gvaConvergence_kinshipOverrides.R` already establishes for the analogous
      `kinshipOverrides` parameter); `createSimKinships()`/`cumulateSimKinships()` both
      directly reproduce the twin-corrected values in every simulated/mean matrix.
      `devtools::check()` 0 errors/0 warnings/1 pre-existing unrelated NOTE; full clean
      regression read 0 failed/0 error; `lintr::lint_package()` 0 lints on all 8 touched files.
      One combined `NEWS.Rmd` entry added covering Slices 1-2 together (the plan's own §8
      item 3 open question, resolved this session). **Slice 3 (full Shiny wiring) DONE S553,
      closing this item:** `modPedigreeServer()`'s return list gained a `twinRelations`
      reactive (the raw, ungated `twinRelationsData()`, unaffected by the "Show Twin
      Connectors" toggle); `R/appServer.R` gained `shared$twinRelations`, wired into
      `sharedKinshipMatrix`'s own `kinship()` call and threaded through to
      `modGeneticValueServer`/`modBreedingGroupsServer`/`modSummaryStatsServer` (each gained
      a matching `twinRelations` parameter on their own fallback `kinship()` recompute path).
      Dragon 1 (the tab-order UX question) resolved via Pre-RED `AskUserQuestion`: a single
      upload point (Diagram tab only) -- Shiny's reactive graph runs every module from
      session start, not gated by tab visibility, so "regardless of tab visit order" is
      satisfied mechanically without a second, duplicate upload control; decision recorded in
      the plan document's own §6 Dragon 1. Verified live end-to-end (Phase 3E, new
      `test-e2e-twin-relations-cross-tab.R`): a `twinRelations` file uploaded on the Diagram
      tab is reflected in the Summary Statistics kinship export for the declared MZ pair
      without ever visiting Genetic Value Analysis; the pre-existing
      `test-e2e-pedigree-module.R` twin-connector suite (13 tests/45 assertions) re-confirmed
      unaffected. `devtools::check()` 0 errors/0 warnings/1 pre-existing unrelated NOTE; full
      clean regression 0 failed/0 error (2,155 test blocks); `lintr::lint_package()` 0 lints on
      all touched files. Fixed 3 pre-existing test-double staleness gaps the full regression
      (not the targeted run) surfaced in untouched files:
      `test_appServer_logging.R`'s own local `modPedigreeServer` stub, `test_modGeneticValue.R`'s
      2 `local_mocked_bindings(reportGV = ...)` signatures, and `test_moduleContract.R`'s
      `modPedigreeServer` return-name whitelist -- see `PROJECT_LEARNINGS.md` Learning 559.
      `NEWS.Rmd` entry extended (one combined Slices 1-3 entry); tutorial/article checklist
      applied (`vignettes/manual_components/_pedigree_browser.Rmd` gained a paragraph on the
      app-wide kinship correction). Not yet filed as a GitHub issue.
- [ ] (found S549, Finding #2 of the above audit, **FIXED S555 for `edgeStyle = "direct"`**.
      **Add a visual marker for consanguineous matings in the Pedigree Diagram tab** --
      kinship2 draws a doubled/thickened mate-line for a blood-related couple;
      `makePedigreeMatingLayout()` rendered every mating unit identically regardless of
      `kinship(sire, dam)`. Distinct from issue #134 (verified layout *doesn't break* for
      consanguineous loops, closed S453 -- a robustness check, not a visual-signaling one)
      and from the "Candidate C" cross-generation dogleg item below (a geometry-signposting
      problem, not a blood-relation one). Fixed: a mating unit whose sire/dam pair has
      `kinship(sire, dam) > 0` (computed via the function's own already-validated
      `twinRelations` parameter too, for correctness parity with the twinRelations-into-
      `kinship()` work above) now renders its 2 spouse-to-union edges with a distinct color/
      width (`"#D55E00"` Okabe-Ito vermillion, width 4) -- always on, no new UI toggle, since
      sire/dam are required columns (a structural fact of the pedigree), unlike the optional
      name/twinRelations sidecars. `edges` gains `color`/`width` columns unconditionally once
      any mating unit exists. 6 new/updated unit tests (`test_makePedigreeMatingLayout.R`);
      new live E2E test confirms 56 marked edges (28 genuinely consanguineous unions x 2) at
      width 4 on the bundled 375-individual fixture. `devtools::check()` 0 errors/0 warnings/
      1 pre-existing NOTE; full clean regression 0 failed/0 error; `lintr::lint_package()` 0
      lints. Not filed as a GitHub issue.
      **Deferred follow-up (owner-directed hold, S555):** `edgeStyle = "rectilinear"`
      propagation -- a marked mate edge whose parent sits at a different gen than its own
      mating unit (the D2 "dogleg" reroute; empirically confirmed live to require an anchor
      who anchors 2+ differently-gen'd units, a real but narrow-trigger scenario, e.g.
      cross-generation consanguineous matings) currently falls back to the generic routing-
      blue color/default width on its 2 replacement projection edges instead of inheriting
      the marker. `.addRectilinearWaypoints()` already defensively guards `width`/`color`
      column presence (no crash), but does not yet propagate a dropped mate edge's own
      color/width onto its replacement edges. A future session should extend the D2 dogleg
      loop in `R/makePedigreeDiagramData.R` (`.addRectilinearWaypoints()`) to look up the
      original edge's color/width before dropping it and stamp both onto its 2 new
      projection edges, falling back to the generic blue/default only when absent -- mirrors
      the color-preservation precedent already established there for KEPT edges (issue #137
      D10). A verified 12-row fixture forcing this exact scenario (an anchor double-anchoring
      2 different-gen units, one of them consanguineous) was constructed empirically this
      session and is a ready-made starting point (see S555's own `PROJECT_LEARNINGS.md`
      entry for the fixture and the reasoning that got there).
      **FIXED S563** (Track C of the kinship2 supplement full-reproduction plan below,
      `docs/planning/kinship2-supplement-full-reproduction-plan.md` §5): S555's own
      12-row fixture code was never committed, so a fresh, independently-verified 9-row
      equivalent (a consanguineous full-sib mating forced to dogleg by its anchor also
      anchoring an unrelated, higher-gen union) was constructed and confirmed live this
      session. `.addRectilinearWaypoints()`'s D2 loop now looks up a dropped mate edge's
      own color/width (keyed by the dogleg's `projId`) and stamps both onto its 2
      replacement projection edges via a post-hoc override after the existing generic
      fallback assignment, applied only when a marker was present -- mirrors the
      KEPT-edges precedent exactly, no other edges affected. 1 new `test_that()` block
      (`tests/testthat/test_makePedigreeMatingLayout.R`, 5 assertions) confirmed RED
      against unmodified source, then GREEN. `devtools::check()` 0 errors / 1 warning +
      1 note (both confirmed pre-existing/unrelated: the untracked "Compounding Loop"
      clutter files' non-portable names, and a pre-existing `vignettes/figure/` knitr
      leftover); full clean regression 1 pre-existing failure unrelated to this change
      (`test_wordlist_coverage.R`, confirmed via `git stash`); `lintr::lint_package()` 0
      lints on touched files. Not filed as a GitHub issue.
- [ ] **Fully reproduce kinship2 supplementary-material PDF's results** (owner-directed
      follow-up to the S549 audit above -- "duplicate the work done in that PDF,"
      overriding that audit's own "no action" verdict on 2 of its 4 findings; plan
      RATIFIED S562, READY, Effort L overall) -- plan complete:
      `docs/planning/kinship2-supplement-full-reproduction-plan.md`. 3 independently
      session-sliceable tracks, no shared code: **Track A** (X-chromosome kinship,
      Table S2 -- `kinship()` gains `chrtype`/`sex` params, ratified scope is the core
      algorithm only, Effort M) -- **DONE S564**, see below; **Track B** (a
      `pedigree.shrink()` equivalent -- new `shrinkPedigree()` function, script-callable
      only, deterministic tie-break [diverges from kinship2's own `runif()`
      non-determinism by design, ratified], the most novel of the 3, Effort L -- 2 of
      kinship2's own internal helpers [`excludeUnavailFounders`/`excludeStrayMarryin`]
      were not yet deparsed by the plan, left as an explicit Pre-RED item) -- **DONE
      S565**, see below; **Track C**
      (finish the `edgeStyle="rectilinear"` consanguineous-marker color/width
      propagation from the deferred item directly above -- smallest of the 3, Effort S,
      no open design question) -- **DONE S563**, see the deferred-follow-up item above
      and `CHANGELOG.md`. Plan's own §6.2 suggests C -> A -> B pickup order
      (smallest/lowest-risk first) but does not force it. **All 3 tracks are now
      DONE** (C: S563, A: S564, B: S565). Verification caveat carried from the S549
      audit: the full 17-subject `fam1` pedigree still isn't reconstructible from
      this repo, and Track B additionally had no PDF-printed worked example to check
      against at all (the PDF only names *which* subjects a shrink would trim, never
      their relationships) -- Track B verified against the installed
      `kinship2::pedigree.shrink()` directly instead. **RESOLVED S566:** filed and
      closed 3 GitHub issues (#156 Track A, #157 Track B, #158 Track C), each citing
      its implementing commit and verification evidence; published a new numeric+
      graphic fidelity validation article,
      [`vignettes/articles/kinship2-fidelity-validation.qmd`](../vignettes/articles/kinship2-fidelity-validation.qmd)
      (matching the `fg-se-validation.qmd` precedent), running the SAME fixture from
      each track's own committed test file through both packages, live, side by
      side: Track A's autosomal and X-linked kinship matrices are bit-for-bit
      identical to kinship2's own output (max abs diff = 0 across 200 compared
      cells); Track B's `shrinkPedigree()` reproduces kinship2's exact surviving
      subject set and exact `bitSize` trajectory on a 16-subject fixture, shown as
      before/after pedigree diagrams from both packages; Track C's consanguineous
      marker flags the same union kinship2 flags under both edge styles. Generated
      by `data-raw/kinship2FidelityValidation.R` (kinship2 installed locally,
      offline, matching the established "no new Suggests dependency" precedent) --
      see that script's own header for the reproduction command. See `CHANGELOG.md`.
- [ ] (**Track A above, DONE S564.** `kinship()` gained `chrtype = c("autosome", "x")`
      and `sex` arguments -- X-chromosome kinship (kinship2 supplement Table S2), core
      algorithm only per ratified D-A2 Option A (no propagation to
      `reportGV()`/`gvaConvergence()`/`createSimKinships()`/`cumulateSimKinships()` or
      the Shiny app). `chrtype = "autosome"` (the default) is byte-identical to every
      prior call site -- pinned by an `expect_identical()` regression test. Full 10x10
      Table S2 transcribed directly from
      `inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf` via
      `pdftotext -layout` (not read visually) and cross-validated by hand-porting
      kinship2's own deparsed X-linked algorithm, run live against the installed
      `kinship2` 1.9.6.2. PRE-RED finding beyond the plan's own framing: Table S2's
      printed values already embed the MZ-twin correction (Figure S1 declares subjects
      8/9 identical twins), so one fixture (the existing `fam1`/`twins` pair already in
      `tests/testthat/test_kinship.R`, extended with a `sex` column) satisfies both
      "reproduce Table S2" and the plan's separately-listed "combined X-linked +
      MZ-twin" coverage requirement. 6 new `test_that()` blocks (Table S2 reproduction;
      twin-correction isolation; backward-compat `expect_identical()` pin; `sex`
      validation; invalid-`chrtype` validation; unknown-sex NA propagation), all
      confirmed failing for the right reason against unmodified source before GREEN.
      `devtools::check()` 0 errors, 1 warning + 1 note, both confirmed pre-existing/
      unrelated via `git stash` (the untracked "Compounding Loop" files' non-portable
      names; a pre-existing `vignettes/figure/` knitr leftover) -- matching Track C's
      own S563 findings exactly. Full clean regression 1 pre-existing failure
      (`test_wordlist_coverage.R`), confirmed via `git stash` unrelated (`matings`/
      `runnable`, from `.qmd` articles, untouched by this diff); this session's own
      2 new spelling flags (`Schaid`/`Sinnwell`, from a new roxygen `@references`
      citation) were fixed via `inst/WORDLIST` additions, not left as new debt.
      `lintr::lint_package()` 0 new lints (2 introduced by new camelCase variable names
      `sexNum`/`founderDiag` suppressed via `# nolint: object_name_linter`, matching
      the file's own established convention and the 5 pre-existing lints already in
      this file, confirmed via `git stash`, left untouched). Not filed as a GitHub
      issue, matching Track C's own precedent. See `CHANGELOG.md`.)
- [ ] (**Track B above, DONE S565.** New `R/shrinkPedigree.R`:
      `shrinkPedigree(ped, genotyped, affected = NULL, maxBits = 16L)`, a
      `kinship2::pedigree.shrink()` equivalent over this package's own
      `id`/`sire`/`dam` data-frame pedigree representation. All 8 of kinship2's own
      internal helpers (`pedigree.shrink`, `bitSize`, `findUnavailable`,
      `excludeUnavailFounders`, `excludeStrayMarryin`, `findAvailNonInform`,
      `findAvailAffected`, `pedigree.trim`) were deparsed directly from the installed
      namespace (1.9.6.2) at Pre-RED -- including the 2 the plan itself flagged as
      not yet deparsed. 4 findings beyond the plan's own framing, all documented in
      the function's own roxygen: (1) `excludeStrayMarryin` ignores `genotyped`
      entirely -- any childless founder is removed unconditionally; (2)
      `excludeUnavailFounders`'s real criterion requires the founder couple have
      exactly one child together *and* neither parent married to anyone else,
      confirmed by a live negative-case test; (3) kinship2's own
      `all(x == 0, na.rm = TRUE)` non-informative-affected check treats `NA` the
      same as unaffected; (4) a real, empirically-confirmed divergence -- kinship2's
      own `pedigree()` constructor forbids a single-known-parent individual
      ("Subjects must have both a father and mother, or have neither"), so its
      algorithm never has to define that case, but this package's pedigrees allow
      partial parentage as ordinary data (`getIdsWithOneParent()`); a literal port
      would divide a zero-length vector and error, so `shrinkPedigree()` never marks
      such an individual non-informative instead (documented, tested, no crash). A
      5th finding: kinship2's own `idTrimmed`/`idList$affect` record only the single
      trial candidate per affected-priority round even when its removal cascades
      further (confirmed live: a fixture exists where kinship2's own `pedSizeFinal`
      drops by 2 in one round but `idTrimmed` names only 1) -- `shrinkPedigree()`
      deliberately fixes this, recording every id actually removed each round, so
      `pedSizeOriginal - pedSizeFinal` always equals `length(idTrimmed)` (does not
      change which individuals survive, only audit-trail completeness). Deterministic
      lowest-id (string-sorted) tie-break (D-B2) confirmed against a fixture proven
      live to be a genuine ~50/50 tie in kinship2's own `runif()`-based reference.
      14 `test_that()` blocks (20 expectation markers incl. a 5-iteration
      determinism-repeat loop) in new `tests/testthat/test_shrinkPedigree.R`, every
      hardcoded expected value (id sets, `bitSize` trajectories, `idList` groupings)
      independently verified live against the installed `kinship2` 1.9.6.2 this
      session (not hand-derived), confirmed failing for the right reason against
      unmodified source before GREEN -- including one test added mid-GREEN after the
      idTrimmed-completeness finding above surfaced. `devtools::check()` 0 errors, 1
      warning + 1 note, both confirmed pre-existing/unrelated via `git stash`
      (matching Track A/C's own findings exactly). Full clean regression 1
      pre-existing failure (`test_wordlist_coverage.R`, `matings`/`runnable` from
      `.qmd` articles, confirmed via `git stash`); this session's own new spelling
      flag (`orchestrator`, from roxygen prose) fixed via `inst/WORDLIST`, not left
      as new debt. `lintr::lint_package()` 0 lints (no suppressions needed -- an
      earlier speculative round of `# nolint: object_name_linter` comments was found
      unnecessary, since this project's `.lintr` already allows camelCase, and was
      removed). `_pkgdown.yml` reference-coverage checklist: added to both the
      "Primary interactive functions" curated group and the "All exposed functions"
      catch-all (a real gap `test_pkgdown_reference_config.R` caught). **All 3 tracks
      of the kinship2 supplement full-reproduction plan are now DONE** (C: S563, A:
      S564, B: S565). None filed as a GitHub issue, matching the established
      "recommend, don't unilaterally file" precedent -- the owner may wish to file
      one (or three) before further related work. See `CHANGELOG.md`.)
- [ ] (found S552, owner-reported live, **FIXED S554**. **Pedigree Diagram tab's
      affected-status shading fills unaffected individuals too, counter to standard
      pedigree drawing convention** -- issue #133's `.affectedColor()`
      (`R/makePedigreeDiagramData.R`) set `color.background` to `"#CC79A7"` when
      `affected == TRUE` and left it `NA_character_` otherwise; in visNetwork an `NA`
      `color.background` does not render as an *open/unfilled* node -- it falls back to
      the library's own default fill, so unaffected/unknown-affected individuals still
      rendered solid-filled. Fixed: `FALSE`/`NA` now get an explicit `"#FFFFFF"`
      (open/unfilled), matching kinship2's own "unfilled if 0/NA" convention (verified
      against the issue #133 plan document's own kinship2-source research). 6 existing
      unit-test assertions updated (`test_makePedigreeDiagramData.R`,
      `test_makePedigreeMatingLayout.R`); new live E2E test confirms the actual rendered
      color for a known TRUE/FALSE/NA triple via the bundled
      `obfuscated_rhesus_mhc_ped_affected.csv` fixture. `devtools::check()` 0 errors/0
      warnings/1 pre-existing NOTE; full clean regression 0 failed/0 error (2,156 test
      blocks); `lintr::lint_package()` 0 lints. Not filed as a GitHub issue.)
- [ ] **`CHANGELOG.md`'s own ~4-entries-per-session ledger convention (claim, Phase 0
      reconcile, deliverable, close-out) may be a `CHANGELOG.md`-side analogue of the
      already-diagnosed `HANDOFFS.md` "Receipt Inflation" (H4) rate problem** (found S543,
      2026-08-12, Effort unknown, not investigated) -- incidental to the `SRF_RED`
      investigation: the tagged region regrew ~105,000 B in roughly a day during an active
      multi-session stretch (S536-S542), and a `grep -c '^### 2026-08-12'` on the pre-trim
      file showed a large share of that region was same-day, multiple-entries-per-session
      housekeeping (claim/reconcile/close-out entries) rather than deliverable-content
      entries. Not confirmed as causal, and not investigated further this session (out of
      the `SRF_RED` decision's own scope, per `PROJECT_LEARNINGS.md` Learning 382's "report,
      don't fix mid-session" precedent). A future session could measure the actual
      housekeeping-vs-deliverable entry-byte split and decide whether a norm analogous to
      the canonical design's own deferred H4 remedy (`docs/planning/ledger-trimmer-design.md`
      §10.2, "the lever is receipt size, and the mechanism would be a norm plus a check, not
      an archiver") is worth adopting for `CHANGELOG.md` specifically.
- [ ] (found S461, **RESOLVED S560**. **Stale `pb_diagram_legend.png` screenshot and its
      surrounding pre-Option-2 prose in `colony-manager-guide.qmd`.** Regenerated the
      screenshot against a small, legible, real 6-animal subgraph (the Option 2
      mating-unit/duplicate-node convention, incl. a consanguineous marker); rewrote the
      paragraph's opening sentence to describe the mating-unit convention and the
      `edgeStyle` toggle, and added a twin-connectors mention. See `CHANGELOG.md`.)
- [ ] (owner-directed, found S544, **RESOLVED S560**. **New dedicated article,
      `vignettes/articles/pedigree-diagram.qmd`, covering the Pedigree Diagram tab's full
      current feature set** (node shapes/legend, `edgeStyle` direct vs. rectilinear,
      consanguineous marker, affected-status shading, name labels, twin/zygosity
      relations and their app-wide kinship correction, hover/click/search/PNG-export
      interaction, and the script-callable `makePedigreeMatingLayout()`/
      `visNetwork::visNetwork()` equivalent) -- matches the established per-tab-article
      convention (`age-sex-pyramid.qmd`, `genetic-value-analysis.qmd`,
      `breeding-group-formation.qmd`), with 5 freshly-captured live-app screenshots via a
      new `shinytest2::AppDriver` script (`pedigree-diagram-screenshots.R`). Cross-linked
      from `colony-manager-guide.qmd`'s function-group table and `a2interactive.Rmd`'s own
      "Pedigree Diagram" section. Subsumes the stale-screenshot item above. See
      `CHANGELOG.md`.)
- [ ] **iCloud "conflicted copy" duplicate `.R` files corrupt
      `devtools::document()`/`R CMD check` output** (found S461, Effort S,
      not a code defect) -- `R/appServer 2.R` and `R/modMarkerGenetics 2.R`
      (carried forward many sessions as passive noise) are SOURCED by
      `pkgload::load_all()`/`devtools::document()` like any other `.R` file,
      silently merging their own stale roxygen comments into the SAME
      generated `.Rd` page as the current source -- confirmed twice this
      session (`man/appServer.Rd`, `man/modMarkerGeneticsServer.Rd`,
      `man/modMarkerGeneticsUI.Rd`, each reverted via `git checkout --`
      immediately). See `PROJECT_LEARNINGS.md` Learning 454. The owner is
      relocating this repository outside iCloud's purview specifically
      because of this and other iCloud-latency issues (same session,
      out-of-band) -- once moved, this item should self-resolve; a future
      session should confirm the 2 duplicate files no longer reappear and,
      if so, close this item without further action.
      **Recurred again S462 (2026-08-03):** the owner rebuilt the package
      locally (outside this session's own tool calls) while reviewing a
      screenshot, which re-corrupted the same 3 `.Rd` files the same way;
      reverted again via `git checkout --`. As of this session's Orient, the
      planned repository relocation had NOT yet happened (`pwd` still
      resolves to the original iCloud-synced path) -- this item cannot be
      closed until the move actually completes.
- [ ] **`devtools::check()`'s spelling NOTE has drifted again -- 6 new words,
      not caught by any session since S461** (found S465, Effort S,
      incidental -- confirmed pre-existing, not caused by this session's own
      diff via a stash test) -- `man/makePedigreeMatingLayout.Rd:40`
      ("sibship", "waypoint") and `vignettes/a2interactive.Rmd:355,371,429,
      437,440,441` ("duplicateToReal", "js's", "makePedigreeMatingLayout",
      "vis") are flagged in `devtools::check()`'s `spelling.R` test diff
      (comparing fresh `spelling.Rout` against the committed
      `spelling.Rout.save`) but are not yet in `inst/WORDLIST`. Mirrors the
      S443/S448/S452 spelling-gap pattern (Learning 426, `CLAUDE.md`'s own
      "Additional close-out checks" precedent) -- a future session should
      hand-add these 6 words to `inst/WORDLIST` in `LC_ALL=C` byte-order
      position (not via `spelling::update_wordlist()`, per S230 convention)
      and re-verify `devtools::check()` drops to the pre-existing iCloud
      duplicate-file warning + vignette-engine note only.
      **Count grown to 9 words as of S490 (2026-08-09), still not fixed** --
      incidental to issue #136 Slice 2's own `devtools::check()` verification
      pass. The original 6 (`sibship`/`waypoint`/`duplicateToReal`/`js's`/
      `makePedigreeMatingLayout`/`vis`) are joined by 3 more: `discoverable`
      (`NEWS.md:140`), a bare `js` (`a2interactive.Rmd:533`, distinct token
      from `js's`), and `unshaded` (`_pedigree_browser.Rmd:55`) -- all 3
      confirmed via `git blame`/`git log -S` to trace to commit `100741ae`
      (S487, 2026-08-08, issue #133 Slice 2's own NEWS/tutorial/article
      commit), not this session's diff. A future session fixing this item
      should hand-add all 9 words, not just the original 6.
- [ ] **The "10 pre-existing baseline warnings" carried in every full-regression
      report since S448 have never been root-caused, and were introduced by a
      test-fixture gap, not a real production-code issue** (found S487,
      incidental to issue #133 Slice 2's own regression read; Effort S, low
      priority) -- the owner asked directly ("we had zero at last release")
      after seeing `warning: 10` in this session's clean regression read, which
      no prior session had actually traced. Root cause: both
      `tests/testthat/test_modMarkerGenetics.R` "cross-center" tests (added by
      commit `a319e0c5`, S447, 2026-08-01, implementing issue #130 Slice 5)
      upload a hand-derived 2-locus toy fixture (Center A n=4, Center B n=6)
      chosen for exact-fraction Fst arithmetic, not for kinship completeness.
      `modMarkerGeneticsServer`'s reactive graph incidentally also computes
      marker-based kinship (the Slice 1 feature) on any uploaded Center-A file,
      and in this fixture `'CA1'`/`'CA2'` share no heterozygous locus --
      `markerKinship()` correctly warns and returns `NA` for that pair (working
      as designed, not a bug), 5x per test x 2 tests = 10. **Confirmed CRAN
      v2.0.0 (released 2026-07-26) predates S447 (2026-08-01) and genuinely
      shipped with a clean, 0-warning suite** -- the owner's recollection was
      correct. S447's own close-out reported "0 failed/0 error" but never
      actually stated a warning count; S448 (the very next session)
      independently found S447's self-reported `devtools::check()` "0/0/0"
      also didn't hold up under re-verification (a missed spelling gap) --
      the same kind of unverified self-report, in the same session, is the
      most likely origin of this gap too, though this was never directly
      confirmed against S447's own raw test output (not preserved). Every
      session from S448 through S486 (~40 sessions) carried "10 pre-existing
      ... warnings" forward as an accepted baseline without investigating what
      it was. Not fixed this session (`PROJECT_LEARNINGS.md` Learning 382's
      "report, don't fix mid-session" precedent -- out of scope for a Slice 2
      legend/documentation TDD session; owner directed file-and-continue via
      `AskUserQuestion`). A future session should either (a) wrap the
      `session$setInputs(genotypeFile = ...)` calls in these 2 tests with
      `suppressWarnings()` (matching the established `PROJECT_LEARNINGS.md`
      Learning 273(d) precedent: "a degenerate out-of-contract input ... often
      misbehaves further downstream -- suppress the incidental warning, not
      the branch"), or (b) adjust the 2-locus fixture so `CA1`/`CA2` share a
      heterozygous locus -- but only after re-verifying the exact-fraction Fst
      values (`58/1001`, `139/308`, `614/2233`) still hold, since the fixture
      was hand-derived specifically to produce those numbers.
      **Count grown from 10 to 15, found incidentally S504 (2026-08-10), still
      not fixed** -- a full clean regression read during issue #149 Slice 1
      showed `warning: 15`, confirmed via a `git stash` comparison to be
      pre-existing (identical on unmodified `HEAD`), unrelated to that
      session's own diff. The 3rd 5-warning source is
      `test_modMarkerGenetics.R`'s "candidate-parent-assignment table is
      non-empty for a real (non-mocked) recorded-but-wrong-parent fixture
      (issue #155)" block, added S502 (2026-08-10) -- a live, non-mocked
      genotype-file upload that incidentally triggers the same
      `markerKinship()` NA-warning path as the 2 original cross-center tests.
      A future session fixing this item should address all 3 test blocks, not
      just the original 2.

- [ ] **`BACKLOG.md`'s own ledger-size housekeeping -- editorial compression, not a
      `methodology_trim.py` config** (found S518, 2026-08-11, READY, Effort L) -- `BACKLOG.md`
      itself is one of the dashboard's 3-file HIGH-risk ledger-size items but does not fit
      `methodology_trim.py`'s chronological-record model: it has 10 `##` sections, each a large
      *standing topical category* that accumulates resolved-item narrative indefinitely, not dated
      newest-on-top records. The file's own header already states the right remedy: "Open,
      actionable work only... for history see `CHANGELOG.md`."
      **Housekeeping section DONE -- S529 (2026-08-12):** an inventory pass (background agent, full
      read of all 2,501 then-current lines) found 62 top-level items file-wide, 48 fully resolved,
      ~1,500 compressible lines total, concentrated in 3 oversized sections (Housekeeping,
      "Pedigree diagram vs kinship2," "Genetic-metrics PDF audit"). Scoped to Housekeeping only for
      this session (owner-picked via `AskUserQuestion`, over top-15-file-wide / single-biggest-item
      / prep-only alternatives) -- self-contained, bounded by clean section headers. All 17 of its
      19 fully-resolved items compressed to the file's own established short-pointer convention; the
      8 genuinely-open items (incl. this one) left untouched. **2 items had NO existing
      `CHANGELOG.md` entry at all** (a real ledger gap, FM #27 -- not just verbose narrative): the
      `inst/extdata/` reorg (Sessions 415-418) and the non-portable-filename fix (Session 497).
      Backfilled proper `CHANGELOG.md` entries for both before compressing, rather than compress to
      a dangling pointer that would have destroyed the only detailed record. Net: Housekeeping
      147→389 lines (263 removed); file total 2,501→2,238 (263 removed). Zero information loss
      verified by re-reading the full compressed section end-to-end before close-out.
      **"Pedigree diagram vs kinship2 audit follow-ups" section DONE -- S530 (2026-08-12):** the
      2nd of the item's 2 remaining sections. Compressed all 12 fully-resolved bulleted items (issues
      #131/#134/#135/#139, Option 2 layout feasibility/design/3 implementation slices, the
      duplicate-node-arc fix, issues #143/#144) to the file's own short-pointer convention, and
      condensed the ~375-line unbulleted S480-S500 Progress-narrative chain (Tier 1 crash-bug fixes +
      #145 spike + doc refresh; Tier 2 issues #133/#136/#137/#145, all closed) into one ~50-line
      consolidated summary retaining every session number, design-doc path, and Learning
      cross-reference. Verified `CHANGELOG.md` (+ its `docs/archive/CHANGELOG-through-*.md` shards)
      actually carries an entry for all 31 session numbers cited before compressing to a pointer --
      0 gaps found this time (unlike the Housekeeping section's 2). All Learning cross-references and
      all 11 cited `docs/planning|audits|research/*` file paths confirmed to resolve. The 4 genuinely
      -open items (Candidate C's connector idea; the 3 dangling-parent-crash-bugs and free-pass-filter
      pointers, both already short; the node-count-off-by-one gap; the docstring-mismatch gap; the
      `highlightNearest` degree=6 bound) left untouched. Net: section 896->286 lines (610 removed);
      file total 2,254->1,658 (596 removed, after this session's own S518-item progress notes added
      lines back elsewhere in the file). Zero information loss verified by re-reading the full
      compressed section end-to-end before close-out.
      **"Genetic-metrics PDF audit follow-ups" section DONE -- S531 (2026-08-12):** the 3rd and
      last of the item's 3 oversized sections. Compressed 8 fully-resolved issue chains
      (#126/#127/#129/#130's shared sequencing-decision bullet, plus the individually-tracked
      #147/#149/#146/#151/#150/#153 design->slice narrative chains) to the file's own short-pointer
      convention; also condensed the S479-S483 re-audit/sequencing context note (still relevant --
      it names the still-open items) without losing any issue number, tier assignment, or audit-doc
      pointer. Left the still-open issue #152 chain (design S517, Slice 1 S525, Slice 2 S526, Slice
      3 next) fully untouched, matching the S529/S530 "leave open items untouched" precedent. An
      early compression pass left a real duplication defect -- the #153 chain's design paragraph was
      replaced but its 3 slice-by-slice progress paragraphs (S520/S521-523/S524) were missed and
      briefly duplicated the new compressed bullet -- caught by this session's own end-to-end re-read
      before close-out and fixed by removing the now-redundant paragraphs. Verified `CHANGELOG.md`
      (+ both `docs/archive/CHANGELOG-through-*.md` shards) carries an entry for all 39 session
      numbers cited before compressing to a pointer -- 0 gaps found. All Learning cross-references
      and all 13 cited `docs/planning|audits/*` file paths confirmed to resolve. Net: section
      753->267 lines (486 removed); file total 1,658->1,173 (485 removed, some absorbed by this
      item's own progress-note growth). Zero information loss verified by re-reading the full
      compressed section end-to-end before close-out.
      **The S518 item is now fully RESOLVED -- all 3 oversized sections compressed across 3
      sessions:** Housekeeping (S529, 147->389 lines), "Pedigree diagram vs kinship2" (S530,
      896->286 lines), "Genetic-metrics PDF audit follow-ups" (S531, 753->267 lines). File total:
      2,501 lines (S529 start) -> 1,173 lines (S531 end), a 1,328-line/53% reduction across 3
      sessions, with zero information loss at any step (each session's own end-to-end re-read plus
      CHANGELOG.md/Learning/file-path cross-reference verification). See `CHANGELOG.md`.
      **Correction (S606, 2026-08-18): "fully RESOLVED" held only as a snapshot -- a standing
      topical section regrows as later sessions append their own progress narrative to it, exactly
      the accumulation pattern this item's own opening paragraph names as the root problem.**
      Between S531 and this session, 3 further issue #152 slice-completion sessions (S532/S533/
      S535) each appended their own multi-paragraph progress update to "Genetic-metrics PDF audit
      follow-ups," regrowing it from S531's 267 lines back to 304 -- with issue #152 now fully
      closed (S535), unlike at S531's compression time (then still open, Slice 3 pending). Owner
      picked this section for re-compression this session via `AskUserQuestion` (over "Pedigree
      diagram vs kinship2" and "both sections"). Re-compressed: the 6 progress paragraphs (S517
      design + Slices 1-5) condensed into 1 consolidated summary retaining every session number,
      design-doc path, and Learning cross-reference. Also corrected 2 stale claims found in the
      same pass, not just compressed around them: the section's own intro paragraph still said
      "#152 (Deferred) is in progress (Slice 3 next)" (superseded by S535's close); and the S535
      paragraph's own "shinytest2/chromote headless-modal-rendering harness limitation" finding was
      never corrected in place after `PROJECT_LEARNINGS.md` Learning 542 (S536) retracted it as a
      test-pedigree-fixture defect (missing `birth` column), not a harness limitation. Verified
      `CHANGELOG.md` (+ its `docs/archive/CHANGELOG-through-*.md` shards) carries an entry for all
      6 session numbers cited (S517/S525/S526/S532/S533/S535) before compressing to a pointer -- 0
      gaps found (1 apparent gap, S492, was a search-pattern false negative: the archive heading
      reads "Session 492," not "S492"). All 6 cited `PROJECT_LEARNINGS.md` Learning
      cross-references (532/538/539/540/541/542) and the 1 cited `docs/planning/*.md` path
      confirmed to resolve; issues #152/#153's CLOSED state independently confirmed via
      `gh issue view`, not assumed from prose. Net: section 304->80 lines (224 removed); file
      total 1,881->1,657 (224 removed). Zero information loss verified by re-reading the full
      compressed section end-to-end before close-out. **"Pedigree diagram vs kinship2" (S530's own
      prior compression target) was NOT re-checked this session for the same regrowth pattern** --
      out of this session's own scope; a future session should check whether it, too, has regrown
      since S530, and should treat this item's own "fully RESOLVED" framing as describing a
      recurring maintenance need, not a one-time fix. See `CHANGELOG.md`.
- [ ] (found S567, 2026-08-14, incidental to a `pkgbuild::build()`/tarball-content check while
      resolving the kinship2 PDF's `.Rbuildignore` classification, **RESOLVED S568**.
      **The untracked "Compounding Loop" files were bundled into every built package tarball**,
      unlike the reference PDFs this project deliberately `.gitignore`/`.Rbuildignore`s. Investigated
      before presenting the decision: the 3 real files (`.html`/`.pdf`/`.webarchive`) turned out to be
      a saved Claude Artifact about this project's own `SESSION_RUNNER.md`/`SAFEGUARDS.md` methodology
      (`github.com/KJ5HST/methodology`) -- personal reference material, not genetics/package content,
      but also not the same as the existing 4 gitignored files (those are copyrighted scientific
      papers). The 4th file, `~$e Compounding Loop.html`, was confirmed via byte inspection to be a
      content-less Microsoft/LibreOffice editor lock file (162 B, just the owner's own name in the
      binary lock-file format), not reference material at all. Presented via `AskUserQuestion`: owner
      picked "gitignore + `.Rbuildignore` in place," matching the established precedent (over moving
      the files out of `inst/extdata/reference/` entirely, tracking+shipping them, or deleting them
      outright); the lock file was deleted unconditionally (never committed, confirmed via
      `git log -- <file>` returning empty, zero content value). Verified via an actual
      `pkgbuild::build()` + tarball-content inspection that all 3 real files are now excluded (the
      NIHMS precedent and the 1 tracked exception both re-confirmed unaffected);
      `git check-ignore -v` confirms all 3 match the new `.gitignore` rule. `devtools::check()`: 0
      errors, 0 warnings, 0 notes -- this also resolved the long-standing "checking for portable
      file names" WARNING every recent session had been carrying forward as pre-existing (these
      exact files were its cause). Incidental finding logged, not fixed: an empty
      `inst/extdata/reference/untitled folder` directory (dated the same day as the Compounding Loop
      files) surfaced during this session's own build-log inspection -- new Housekeeping item below.
      See `CHANGELOG.md`.)
- [ ] (found S568, 2026-08-14, incidental to this session's own `pkgbuild::build()` verification,
      Effort S, not fixed this session) **An empty, untracked `inst/extdata/reference/untitled
      folder` directory** (dated 2026-08-13, the same day as the now-resolved "Compounding Loop"
      files) sits in the package source tree -- `R CMD build` silently drops it during staging
      ("Removed empty directory..."), so it has no build-correctness impact, but it's a stray Finder
      artifact with no content. A future session should confirm with the owner it's safe to delete
      and remove it (no `.gitignore`/`.Rbuildignore` entry needed for an already-build-dropped empty
      directory -- just a filesystem cleanup).

## Pedigree diagram vs kinship2 audit follow-ups (from ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md)
*S435's capability-comparison audit (`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`)
compared the just-shipped issue #129 pedigree-diagram feature against kinship2's pedigree-drawing
feature set (17-point checklist, 8 findings, 8 recommendations). Triaged S436 (2026-07-30) via
explicit owner direction (free-text, not per-item `AskUserQuestion` picks): **all 8 recommendations**
filed as GitHub issues, tracked there, not here -- including Recommendations 4-7, which the audit
itself scored "no action" (data-model-gated, or an already-ratified Dragon-P3 scope tradeoff);
filing tracks the idea for future consideration and does not reverse the audit's own assessment
(each issue body preserves the audit's original disposition text verbatim). Owner set an explicit
priority order that **inverts** the audit's own suggested ordering (which rated Finding #1 highest):
**#131** (diagram image/print export, Finding #3/Rec #2, priority 1) -- **#132** (in-app
shape-to-sex legend, Finding #6/Rec #3, priority 2, also resolves plan Dragon P5) -- **#133**
(affected/phenotype/genotype status encoding, Finding #2/Rec #4, priority 3, data-model gated) --
**#134** (verify inbreeding-loop/consanguinity rendering, Finding #1/Rec #1, priority 4, resolves
plan Dragon P2 / `PROJECT_LEARNINGS.md` Learning 410) -- **#135** (hover tooltips + search/highlight,
Rec #8, priority 5) -- **#136** (name labels instead of ID-only, Finding #8/Rec #7, priority 6,
data-model gated) -- **#137** (twin/zygosity encoding, Finding #5/Rec #5, priority unranked by the
owner, placed 7th as an inference not a stated decision) -- **#138** (full-colony rendering beyond
the 1,500-node cap, Finding #7/Rec #6, priority 8 -- explicitly deprioritized/delayed by the owner,
`low priority` GitHub label applied). Owner also directed (mid-session, 2026-07-30) a broader goal:
overlay kinship2's genetics-domain naming conventions onto the pedigree data model where applicable
when these are implemented, and build test pedigree fixtures with the corresponding added columns --
folded into #133 (kinship2's `affected` argument convention) and #137 (kinship2's `relation`
argument convention), the two data-model-adding items. Owner also directed that any plan
implementing one of #131-#138 must include a documentation phase (`vignettes/articles/
colony-manager-guide.qmd` and/or `vignettes/manual_components/_pedigree_browser.Rmd`), now recorded
as `CLAUDE.md`'s "Tutorial/article documentation checklist" -- checking whether this was already
true for the base feature found it was not: **issue #139** tracks that issue #129's already-shipped
Diagram tab has zero tutorial/article coverage today. See `PROJECT_LEARNINGS.md` Learning 411 and
`CHANGELOG.md` for the full S436 triage record. None imply reopening issue #129 or revisiting the
visNetwork-vs-kinship2 technology decision (D2), which stands as ratified.*
- [ ] (feasibility planning DONE -- S457, 2026-08-02, see
      `docs/planning/pedigree-diagram-mating-lines-plan.md`. **Pedigree Diagram
      tab does not visually indicate mating/couple relationships** (owner-observed
      S456, citing kinship2-convention references) -- confirmed empirically (3
      `visNetwork` POCs via `chromote`) that a true kinship2-style mate-line +
      sibship-bar convention is achievable inside the ratified visNetwork (D2)
      choice via invisible union/waypoint nodes with hand-computed coordinates.
      Owner ratified **Option 2 -- full kinship2-parity layout on visNetwork**
      via `AskUserQuestion`, over reopening D2/switching to kinship2 or a
      smaller partial-repositioning step. See `CHANGELOG.md`.)
- [ ] (design DONE -- S458, 2026-08-02, see
      `docs/planning/pedigree-diagram-option2-layout-design-plan.md`.
      **Pedigree Diagram: full kinship2-parity layout (Option 2 design
      session)** -- designed and owner-ratified a mating-unit/individual
      -duplication transformation (CraneFoot-derived) resolving
      crossing-minimization ordering, multi-mate/half-sib fan-out, and
      inbreeding-loop safety via one mechanism; a simplified
      Reingold-Tilford/Walker contour-merge algorithm (not an off-the-shelf
      package -- `igraph`/`ggraph` are GPL) computes final coordinates. Owner
      ratified via `AskUserQuestion` with one editorial direction:
      non-human-centric terminology (`sire`/`dam`/`mate`/`mating`). See
      `CHANGELOG.md`.)

**Sequencing note (S480, 2026-08-08):** the items below through the `highlightNearest` degree=6
item, plus GitHub issues #133/#136/#137/#138/#141/#145, were jointly examined for implementation
order in `docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md` (kinship2-capability-
and nomenclature-reference-informed). Recommended order: (1) the two dangling-parent crash bugs
below + the free-pass-filter reachability check, (2) issue #145's verification spike, (3) refresh
the stale `.qmd` comparison doc below, (4) the owner's existing #133 > #136 > #137 > #138 order, (5)
#141 and Candidate C stay deferred pending new evidence/owner sign-off.

**Tier 1 -- DONE (S481, S482, S484):** the 2 dangling-parent crash bugs + the free-pass-filter
reachability check were filed and fixed as issue #154 (S481). Issue #145's verification spike (S482,
`docs/research/issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md`) empirically confirmed
(kinship2 v1.9.6.2 source read + 5 synthetic-pedigree tests, not inferred from docs) that kinship2
implements **neither** a hard male-left invariant **nor** a sex-aware crossing-minimizing default --
once an individual has multiple mates, left/right is decided purely by pedigree-data discovery order;
the issue's own cited sources were found unreliable on this point. `docs/planning/pedigree-diagram-
kinship2-reference-comparison.qmd` was refreshed (S484) to reflect issues #143/#144's fixes and to
add a new Example 4 reproducing S482's own kinship2 counter-example directly (`quarto render` clean,
37 chunks).

**Tier 2 -- DONE (S485-S494, S499-S500): issues #133, #136, #137, and #145 are all now fully
implemented and closed.** Each followed design-document ratification (`AskUserQuestion`-gated
judgment calls) then 1-3 implementation slices, each slice a full strict-TDD PRE-RED->RED->GREEN
(->REFACTOR) cycle with clean regression + `devtools::check()` + live `shinytest2`/`chromote`
verification, plus the citation/tutorial/`NEWS.Rmd`/`a2interactive.Rmd` documentation checklists
applied per-slice:
- **Issue #133** (affected/phenotype status): design S485 (`docs/planning/issue133-affected-status-
  pedigree-diagram-plan.md` -- new `affected` logical column, `color.background` + tooltip, no new
  dependency). Slice 1 (data model + rendering) S486 -- found and fixed a gap where the rectilinear
  edge style would have silently erased the new coloring. Slice 2 (legend + docs) S487. **Closed
  S487.**
- **Issue #136** (name labels): design S488 (`docs/planning/issue136-name-labels-pedigree-diagram-
  plan.md` -- corrected 3 premises in the issue itself; found and closed a disclosure defect,
  `obfuscatePed()` would have left `name` unscrubbed). Slice 1 (data model + de-identification) S489.
  Slice 2 (label rendering + off-by-default toggle + docs) S490 -- found and fixed a real
  toggle-discarded-on-rerender defect via live verification (`PROJECT_LEARNINGS.md` Learning 490).
  **Closed S490.**
- **Issue #137** (twin/zygosity encoding): design S491 (`docs/planning/issue137-twin-zygosity-
  pedigree-diagram-plan.md` -- new sidecar `twinRelations` table, zero schema.R changes; a
  workflow-truncation tooling defect found and worked around, `PROJECT_LEARNINGS.md` Learning 491).
  Slice 1 (data model + de-identification, `checkTwinRelations()`/`obfuscateTwinRelations()`) S492.
  Slice 2 (core rendering, MZ/DZ/UZ connector styles) S493. Slice 3 (UI wiring, legend, docs) S494 --
  found and filed (not fixed) a Slice 2 color-wiring gap as its own Housekeeping item. **Closed
  S494.**
- **Issue #145** (sire/dam left-right placement, deferred from Tier 1's spike): design S499
  (`docs/planning/issue145-sire-dam-left-right-placement-plan.md` -- a 3-agent adversarial review
  refuted the first proposed mechanism, `orderBySex = TRUE` parameter ratified instead). Slice 1
  (core positioning) S500. **Closed S500** for the ratified simple-pair scope.

**Issue #138** (full-colony rendering beyond the 1,500-node cap) is the one item in the owner's Tier 2
order this cluster did not reach -- still open, tracked as its own GitHub issue (`low priority`
label), needing its own scoping session first, matching #133/#136/#137/#145's own precedent. See
`CHANGELOG.md` for the full session-by-session record and `PROJECT_LEARNINGS.md` Learnings 485,
488-499 for the individual technical findings.
- [ ] **Candidate C's connector/dogleg visual-signposting idea** (found S473,
      designing the issue #144 plan; not adopted for #144 itself, Effort
      unknown, low priority) -- extends the existing D2 mate-line "dogleg"
      (issue #142) to `edgeStyle="direct"` (which currently gets zero
      compensating treatment for any cross-generation connector) and adds
      dashed/colored/titled styling to both edge styles so a
      multi-generation-spanning mate-line reads as intentional rather than a
      positioning bug. Fully validated (including a real ~37%
      `edgeStyle="rectilinear"` performance regression found and fixed during
      design) but requires its own fresh, explicit owner product-level
      sign-off to pursue -- independently valuable as a diagram-readability
      enhancement, decoupled from #144's own resolution (which does not need
      it). See `docs/planning/issue144-anchor-row-mismatch-fix-plan.md` §5/§8.
      **Also considered and again not adopted for the kinship2-fidelity remediation plan's
      Track 4 (design S572, implemented S573, 2026-08-14)** -- Track 4 ratified and shipped
      Candidate A (gen-aware D2 anchor selection) instead, see
      `docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` §3/§8. Live-rendered
      (S573, both `edgeStyle` values, zero console errors) with the redistribution this decision
      predicted (duplicate nodes 128->102, multi-anchor individuals 2->22, max 5). Still not
      precluded -- remains open as a future, separately-scoped enhancement if the owner judges,
      from that live render, that remaining cross-generation mate-lines still benefit from
      signposting for legibility.
- [ ] **The live app's uploaded/QC'd copy of `obfuscated_rhesus_mhc_ped.csv`
      produces one fewer node than reading the same bundled CSV directly**
      (found S472, incidental to issue #143's live verification, Effort
      unknown, low priority) -- `direct`-style Diagram node count is 739 live
      vs. 740 via `read.csv()` + `.buildMatingUnitForest()`/
      `.positionMatingUnitForest()` directly (a stable, already-tested
      figure, unaffected by this session's fix); the live rectilinear
      -style projection-node count is correspondingly 50 vs. an offline
      -computed 51. Not investigated further this session (out of the
      issue #143 fix's own scope, per `PROJECT_LEARNINGS.md` Learning 382's
      "report, don't fix mid-session" precedent) -- most likely explained by
      the upload/QC pipeline (`modInput.R`'s `qcStudbook()` or similar)
      dropping or merging exactly one row relative to a raw `read.csv()`,
      but this was not confirmed. A future session should identify which
      individual differs and why, and decide whether the app's own bundled
      -fixture test coverage (`test-e2e-pedigree-module.R`, etc.) should
      assert this QC'd count explicitly rather than relying on the
      raw-CSV-read count as a proxy for what the live app actually renders.
- [ ] **`data-raw/rhesusPedigree.R`'s docstring claims
      `rhesusPedigree_fromCenter.csv` is an independent raw/pre-obfuscation
      source for `obfuscated_rhesus_mhc_ped.csv`, but the two shipped fixtures
      are byte-identical on every shared column** (found S470, incidental to
      the founder-positioning audit above, Effort S, low priority) -- confirmed
      via `identical()` on `id`/`sire`/`dam`/`sex`/`gen`/`birth`/`exit`/`age`
      between the two files; `rhesusPedigree_fromCenter.csv` differs only by
      one added `fromCenter` column (all `TRUE`). The documented `obfuscatePed()`
      id/date-obfuscation transform was evidently never applied to produce this
      particular fixture, or produced a no-op. Not fixed this session (reported
      per `PROJECT_LEARNINGS.md` Learning 382's "report, don't fix mid-session"
      precedent -- out of the founder-positioning audit's own scope). A future
      session should reconcile the docstring against the shipped fixture (or
      regenerate `rhesusPedigree_fromCenter.csv` to match the documented
      provenance). See `docs/audits/FOUNDER_POSITIONING_DEFECT_AUDIT_2026-08-03.md`
      Finding #4, `PROJECT_LEARNINGS.md` Learning 468.
- [ ] **`highlightNearest` degree=6 mitigation for the rectilinear style is
      bounded, not a full fix** (found S468, Effort M, low priority) -- a
      very wide sibship's D1 sibship-bar chain can exceed 6 hops (chain
      length scales with the number of children in one mating unit), so a
      hover on an individual in a very large family could still light up
      nothing visible. A full fix would need either a custom JS
      `highlightNearest` reimplementation that specifically skips through
      invisible waypoint nodes regardless of hop count, or a data-layer
      change that keeps degree-1 semantics correct (e.g. tagging waypoint
      edges so a custom traversal treats them as zero-cost hops). Not
      designed this session -- the degree=6 mitigation was explicitly
      scoped as a quick, bounded fix, owner-directed via `AskUserQuestion`.
      A future session should measure the real fixture's own maximum
      sibship size to gauge how often 6 hops is actually insufficient in
      practice before deciding whether a full fix is warranted.

## Outreach
- [ ] **NPRC outreach & announcement plan** (DECISION NEEDED -- owner review/edit of
      drafts + send timing; Effort N/A, not a coding task) -- plan complete:
      `docs/planning/nprc-outreach-announcement-plan.md` (S413, owner-directed, not
      from this backlog). Covers audiences (the NPRC Genetics and Genomics Working
      Group, plus each of the 7 centers' colony-manager/veterinarian contacts), tailored
      messaging, channels, a sourced 7-center contact roster (director + colony-manager/
      head-veterinarian-equivalent + genetics contact per center, each with a source),
      a generic timeline, 5 named risks, and ready-to-edit draft materials (WG email,
      colony-manager/vet email, one-page feature summary, presentation outline). Two
      items remain genuinely unresolved after dedicated research, not just undone: the
      Working Group's current (2026) chair could not be confirmed (recommended action:
      ask `support@nhprc.org` directly, see the plan's §3/§8); and a colony-manager
      contact could not be named at 3 of 7 centers (Southwest, Tulane, Washington --
      the role is undocumented by name on each center's own site). **Next steps are
      owner-executed, real-world actions** (review/edit the drafts, confirm exact
      recipients, send) per the plan's own §7 -- pick this up in a future session only
      if the owner wants help drafting a specific follow-up, not as a general "send the
      emails" coding task. See `CHANGELOG.md`.

## Architecture (issue #122 / XARCH-2 -- module contract)
*Resolved -- S372 planning session through S377 execution (Phases 1-5, all DONE); see
`CHANGELOG.md` for the per-phase detail (S373 vocabulary-composition fix, S374 kinship
dedup, S375 vocabulary collapse, S376 dead-surface pruning, S377 contract doc + guard
test). The living contract is `docs/architecture/module-contract.md`; it is enforced by
`tests/testthat/test_moduleContract.R`. `modInput` is the reference implementation.*

## Documents (v1.0.8 -> v2.0.0 write-up)

## Audit follow-ups
*(From `PED_GV_AUDIT_2026-05-30.md`; all audit follow-up items are now resolved — see
`CHANGELOG.md`. Per-item reachability notes and traps live in `CLAUDE.md` "Project-specific
Learnings".)*

## Genetic-metrics PDF audit follow-ups (from GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md)
*S419's capability-comparison audit (`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md`)
compared the package against the 2015 NHP Genetics and Genomics Working Group PDF and found 12
missing / 9 partial findings (of 37 total). Triaged S422 (2026-07-29) via owner `AskUserQuestion`
picks -- all 6 findings/clusters owner-directed to file as GitHub issues, tracked there, not here:
**#125** (configurable ranking-priority scheme + surface multiple breeding-group candidates,
Dimensions 1 & 2), **#126** (kinship/genome-uniqueness distribution shape statistics -- skewness,
kurtosis, Dimension 3), **#127** (surface `correctUnknownParentMeanKinship()`'s silently-dropped
`flagged` list, Dimension 4), **#128** (breeding-group exclusion is top-N rank-based, not a
genetic-value floor, Dimension 2), **#129** (pedigree-diagram/tree visualization, currently
table-only, Dimension 7), **#130** (marker-based kinship/heterozygosity/parentage-verification +
cross-center identity resolution, Dimensions 5 & 6). 1 finding (NGS/whole-genome/MHC-specific/
linkage-disequilibrium methods, Dimension 5) declined, no action -- the source PDF itself frames
these as speculative future work even in 2015, matching the audit's own Recommendation #5. The
remaining findings (PMX/MateRx/Pedscope/PedSys tool-comparison notes, the "make pedigree available
to researchers" governance recommendation) are descriptive or already-adequately-served, not gaps
requiring tracking. See `CHANGELOG.md`.*

**Second-generation re-audit and issue-sequencing (S479-S483, 2026-08-05 to 2026-08-08):** a ghost
session (reconciled S479, `PROJECT_LEARNINGS.md` Learning 479) produced 2 further capability audits
(`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`, `..._2026-08-06.md`) and filed 8
new GitHub issues: **#146** (configurable/exhaustive breeding-group candidate retention), **#147**
(likelihood-based candidate-parent assignment), **#148** (MHC haplotype-specific frequency
reporting), **#149** (cross-center identity-mapping workflow with provenance export), **#150**
(de-identified pedigree export workflow), **#151** (individual mate-pair analysis), **#152**
(whole-genome/whole-exome sequence input + sequence-based metrics), **#153** (linkage-aware/
haplotype-block metrics). Sequencing ratified S483
(`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md`, owner-directed, 8-agent
codebase-grounded workflow): Tier 1 #147; Tier 2 #149 > #146 > #151; Tier 3 (policy-gated) #150;
Deferred (design-only) #152 > #153 > #148, with #148 flagged as needing its own scope-narrowing
conversation first (filed broader than the audit recommends). **Also found, still not filed as of
this compression:** 2 audit-table High-priority rows -- "Longitudinal genetic-health monitoring" and
"Ancestry guardrails in breeding decisions" -- have no corresponding GitHub issue, despite ranking
above every Medium/Deferred item in this batch (Finding #1/Recommendation 2); a future triage session
should file both. **Every Tier 1/2/3 item (#147, #149, #146, #151, #150) plus Deferred-tier #152 and #153 are now
fully shipped and closed** -- see the compressed entry below. #148 remains unstarted, still
needing its scope-narrowing conversation. See `CHANGELOG.md`.

**Progress, issue #152 (whole-genome/whole-exome sequence input + sequence-based genetic
metrics) -- DONE, closed (design S517 through close-out S535, Sessions 517-535).** Design
ratified S517 (`docs/planning/issue152-sequence-input-genetic-metrics-plan.md` -- two parallel
background research agents plus direct verification of the load-bearing prior Bioconductor
-Imports decline): sparse/GBS-scale scope tier (~50,000-locus ceiling); a shared `locusMetadata`
(`locus, chrom, pos[, cM]`) sidecar reused by sibling issue #153; genome-wide F_ROH (new, Ceballos
et al. 2018) plus genome-scale reruns of the existing kinship/heterozygosity/Fst functions; a new
tab inside the existing `modMarkerGenetics.R` rather than a dedicated module. Scoped as 5 vertical
slices, each its own session, each a full strict-TDD PRE-RED->RED->GREEN(->REFACTOR) cycle gated
by `AskUserQuestion`:
- **Slice 1** (S525): new `checkSequenceGenotypeFile()` structural validator (reuses issue #153's
  `checkLocusMetadata()`); `data-raw/generate_sequence_fixtures.R` (seeded 50-individual x
  1,000-locus synthetic biallelic SNP panel + `locusMetadata` sidecar, committed as
  `inst/extdata/examples/example_sequence_*.csv`).
- **Slice 2** (S526): `markerKinship()`/`markerParentageLikelihood()` performance rewrite --
  vectorized matrix algebra / precomputed per-locus allele-frequency tables -- ~2x/~2.4x speedups,
  output unchanged (golden-master + `system.time()` benchmark regression tests; the median-of-3
  -reps timing-stability fix is `PROJECT_LEARNINGS.md` Learning 532).
- **Slice 3** (S532): new `computeGenomicROH()` F_ROH metric (Ceballos et al. 2018 convention),
  reuses `checkLocusMetadata()`'s coverage classification. `PROJECT_LEARNINGS.md` Learning 538 (a
  lower-than-baseline `devtools::check()` NOTE count needs the same direct verification as a
  higher one) originates here.
- **Slice 4** (S533): new `obfuscateGenotypeMatrix()` de-identification primitive, mirrors the
  established `obfuscate*` family pattern. `PROJECT_LEARNINGS.md` Learning 539 (verification
  tools must be invoked with the project's own default config/args, not an override) originates
  here; found (not fixed) the `.Rbuildignore` `methodolog_trim.py` typo, fixed next session
  (Learning 540).
- **Slice 5** (S535, closes #152): new "Genomic ROH (F_ROH)" tab in `R/modMarkerGenetics.R`
  (curator confirm-gate export: de-identified genotype matrix + F_ROH table + manifest), new
  `obfuscateGenomicROH()`. Live Phase 3E verification found and fixed a real bug --
  `sequenceRohTable` fed `locusMetadata()`'s already-`checkLocusMetadata()`-processed output back
  into `computeGenomicROH()`, which re-runs that same check internally, silently mislabeling a
  column (`PROJECT_LEARNINGS.md` Learning 541). S535 also suspected a `shinytest2`/`chromote`
  headless-modal-rendering harness limitation blocking the export-confirm modal --
  **`PROJECT_LEARNINGS.md` Learning 542 (S536) corrects this: there was no harness limitation, the
  real cause was a test pedigree fixture missing the required `birth` column, which silently
  blocked `req()` upstream of `showModal()`; fixed by completing the fixture.**

Each slice: full clean regression 0 failed/0 error, `devtools::check()` clean modulo pre-existing
NOTEs, citation/`NEWS.Rmd`/`_pkgdown.yml` checklists applied per-slice (tutorial/article checklist
satisfied at Slice 5; `a2interactive.Rmd` deferred per its own standing rule). See `CHANGELOG.md`
for the full session-by-session record.
