# Session Notes

**Purpose:** Continuity between sessions. Each session reads this first
and writes to it before closing out.

**Archived 612 record(s), 1998-12-06 → 2026-08-12** into
[`docs/archive/SESSION_NOTES-through-2026-08-12.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-12.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 40 record(s), 2026-08-11 → 2026-08-13** into
[`docs/archive/SESSION_NOTES-through-2026-08-13.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-13.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 76 record(s), 2026-01-26 → 2026-08-15** into
[`docs/archive/SESSION_NOTES-through-2026-08-15.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-15.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

------------------------------------------------------------------------

## ACTIVE TASK

### Session 613 Handoff Evaluation (by Session 614)

**Score: 10/10.** **What helped:** the `HANDOFFS.md` receipt’s
`next_steps` field named 3 exact, binding obligations rather than a
vague “continue Phase 2” pointer — “(1) write the new Test 15 … (2)
restate the `qualifies(U)` gate … the full 5 conjuncts … (3) fold the
widened union-dot/`M_repr` cosmetic drift disclosure into whatever
real-fixture measurement Phase 2 already owed.” All 3 were directly
actionable this session: (1) Test 15 was written in RED exactly as
specified; (2) the implementation’s own `qualifies()` function uses the
full 5-conjunct gate (mateCount(P)==1, mateCount(M)==1,
`!hasOwnDirectChild(P)`, both ids in `realIds`, unambiguous opposite
sex), not the abbreviated 3-conjunct form the design note’s own first
draft used; (3) is explicitly folded into Phase 2b’s own deferred
real-fixture-measurement scope, not silently dropped. `key_files`
pointed exactly at the shipped `sweepMinSep()` (`:997-1015`) and
`orderBySex` (`:1054-1078`) line ranges — both read directly and
cross-checked against my own port. `gotchas` (1) “the S8 formula applies
ONLY to the B1 qualifying case, do not generalize to B3” was directly
useful: my own first implementation draft had exactly this bug
(inferring “is this a B1 call” from `memberId %in% freePassIds` rather
than from which call site invoked it), caught and fixed during GREEN —
the gotcha didn’t prevent the bug, but its framing made the bug fast to
recognize once the test failure pointed at it. **What was missing:**
nothing critical — Phase 2’s own real size (large enough to need this
session’s own further split into 2a/2b) wasn’t flagged by S613’s
handoff, but that was the parent plan’s own “splittable if too large”
note to make, not S613’s job. **What was wrong:** nothing found
inaccurate. **ROI:** very high.

### What Session 614 Did

**Deliverable:** Walker/BJL Phase 2a (issue \#141) — the adapter
mechanics half of the pedigree adapter parallel to production, per
`docs/planning/pedigree-diagram-walker-bjl-apportioning- redesign-plan.md`’s
Phase 2 spec as amended by the Phase 1b design note’s §8 resolution.
**DONE** — new `.positionMatingUnitForestBJL()` implementing the full
3-tier reconciliation, GREEN and REFACTORed, 17/17 new tests passing,
zero collateral damage. Owner-directed scope split (this session’s own
Phase 1 `AskUserQuestion`, before declaring RED): Phase 2b (the
live-render helper + real-375-fixture A/B verification) is explicitly
**not done** — a required, separate follow-up session.
**Started/Completed:** 2026-08-19–2026-08-20.

**What actually happened, in order:**

1.  **Phase 0 orientation** — read `SESSION_RUNNER.md`/`SAFEGUARDS.md`
    in full; `SESSION_NOTES.md` (S613’s own active task);
    `gh issue list` (13 open); `git status`/`log`/`diff --stat` (clean,
    S613 fully closed out, ledger frontiers both `== HEAD`, no reconcile
    owed); `gh run list` (CI green on recent completed runs, 2
    in-progress at report time); `methodology_dashboard.py` (96/100, 1
    HIGH risk — `SESSION_NOTES.md`/`HANDOFFS.md` both past the
    2,000-line cap, unchanged from S613, not fixed this session per
    report-don’t-fix). Ghost-session check on 6 untracked files (4
    rendered `docs/planning/*.html` evidence docs, 1 Office lock-file
    artifact, 1 `scratchpad/` dir of old verification scripts) — all
    traced to already-documented, already- resolved work, none a ghost
    deliverable. Rendered the priorities list (4 numbered
    `AskUserQuestion` options) — **user picked the Walker/BJL Phase 2
    item.**
2.  **Grounded directly in both planning documents before any code** —
    full reads of
    `docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md`
    (Migration Path/Phase 2 spec) and
    `docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-reconciliation.md`
    (§3’s mechanism, §8’s seam-resolution formula and its 2 disclosed
    Phase-2 obligations). **Process gap, disclosed:** this reading ran
    across several large tool calls before the Phase 1B claim stub was
    written — a real deviation from Learning 628’s own “claim at the
    literal next tool call” rule, caught and corrected (claimed
    immediately after, before any further work) but not avoided
    outright. No harm resulted (zero commits/technical changes happened
    during the gap), but the discipline itself was not followed as
    written.
3.  **Phase 1B claimed** — `SESSION_NOTES.md` stub + `HANDOFFS.md`
    `status: pending` receipt, committed (`577ad298`).
4.  **Scope decision, via its own dedicated `AskUserQuestion` before
    declaring RED** (per CLAUDE.md’s own “pre-RED scope decision is a
    separate question” rule): given Phase 1a (a far simpler *generic*
    engine) filled a full session by itself, and Phase 2 adds the full
    B1/B2/B3 classification + 3-tier reconciliation + 15-test matrix + a
    new live-render helper, the user picked **“split: adapter first”** —
    this session scopes to the adapter + full synthetic test matrix; the
    live-render helper and real-375-fixture verification are explicitly
    deferred to a Phase 2b session, disclosed up front in the test
    file’s own header, not silently dropped.
5.  **PRE-RED → RED**, gated via `AskUserQuestion`: wrote
    `tests/testthat/test_positionMatingUnitForestBJL.R` — 17
    `test_that()` blocks (the design note’s own 15-fixture matrix, §4
    Tests 1-14 + §8.4’s required Test 15, plus 3 property tests).
    Derived exact-value oracles for the numerically-tricky fixtures
    (Tests 1, 2, 5, 6, 11, 13, 14,
    15. by actually running Tier 1’s own mechanics (a throwaway probe
        script calling the real, existing
        `.buildMatingUnitForest()`/`.positionTreeApportion()`/`.buildForestChildrenOf()`,
        plus a hand-copied `sweepMinSep()` backstop matching the shipped
        push semantics exactly) against each fixture — never
        hand-derived. Found and fixed 3 of my own fixture-construction
        bugs during this process (wrong assumed anchor in 2 fixtures; a
        vector-misalignment bug in a 3rd) by running each fixture
        against the REAL `.buildMatingUnitForest()` before finalizing
        assertions, not by reasoning alone. Confirmed genuine RED: all
        17 blocks error on “could not find function,” full clean
        regression 0 failed / 17 error (all new) / 0 non-baseline
        offenders. Committed (`0a43ec30`).
6.  **RED → GREEN**, gated: implemented `.positionMatingUnitForestBJL()`
    in `R/makePedigreeDiagramData.R` (new function, zero changes to
    `.positionMatingUnitForest()` or any other existing code). First run
    found 9 failures; diagnosed and fixed each by actually running the
    failing fixture in isolation, not by inspection — **2 were genuine
    implementation defects**: (a) B1 eligibility needs an explicit
    `!hasParentEdge(M)` conjunct the OLD, shipped `freePassIds` helper
    doesn’t carry (its own candidate pool never needed it, since under
    the OLD algorithm a mating unit’s own sire/dam can never also be
    someone’s tracked child — a distinction 2b’s “grandchild reattached
    as a real child” architecture breaks), causing a B2 individual to
    wrongly get a second, Tier-3 derived-point row; (b) a dangling
    non-anchor party (no own row in `ped`) crashed on
    `sireOf[[id]]`/`damOf[[id]]`, fixed by excluding dangling ids from
    B1 eligibility up front, matching the OLD function’s own confirmed
    behavior (verified directly: `.positionMatingUnitForest()` drops a
    dangling free-pass parent from its output entirely). The other 7
    failures were my OWN test bugs (a legitimate epsilon nudge from Tier
    2’s own exact-tie sweep I hadn’t accounted for in 2 assertions; a
    B1/B2 id-classification ambiguity in a 3rd fixture I’d wrongly
    assumed was “B1-free”). Recorded `PROJECT_LEARNINGS.md` Learnings
    639/640 for both defect classes — both are genuinely transferable,
    not one-off. Verified: 17/17 GREEN (53 expectations), full clean
    regression 0 failed/0 error project-wide, 0 non-baseline offenders.
    Committed (`e7f1f593`).
7.  **GREEN → REFACTOR**, gated: `lintr::lint()` (package loaded first,
    Learning 224 methodology) found exactly 2 style lints
    (`character(0)` → `character(0L)`), test file already 0. Fixed,
    re-verified 17/17 GREEN + 0 lints + full clean regression
    unaffected. Committed (`afa7c5f5`).
8.  **Extra verification beyond the gated cycle:** ran
    [`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
    (0 changes, expected — `@noRd`, no exported symbol) and a full
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
    as an additional build-equivalent confirmation beyond the
    testthat/lintr checks the gated cycle itself required. Result: **1
    WARNING, 2 NOTEs, 0 errors — all 3 pre-existing, none attributable
    to this session’s diff:** the non-portable-filename WARNING and the
    “scratchpad” top-level-directory NOTE both trace to the SAME
    untracked files this session’s own Phase 0 ghost-session check
    already found and reported (an Office lock-file artifact,
    `inst/extdata/reference/~$e Compounding Loop.html`; a pre-existing
    `scratchpad/` dir left by an earlier, unrelated session) — confirmed
    pre-existing, not fixed here, per the established “report an
    incidentally-discovered, unrelated gap, don’t fix it mid-session”
    precedent (Learning 382). The 3rd NOTE (`vignettes/figure/` knitr
    leftover) is the same long-documented pre-existing NOTE multiple
    prior sessions’ own close-outs have already recorded.
9.  **Close-out:** `BACKLOG.md`’s Walker/BJL item updated with the S614
    progress paragraph; `PROJECT_LEARNINGS.md` Learnings 639/640
    recorded; this handoff written.

**Runtime smoke test (Phase 3E):** n/a in the traditional sense — the
new function is `@noRd` (internal, non-exported), has zero call sites
anywhere in the package (grep-confirmed: the only reference to
`.positionMatingUnitForestBJL` outside its own definition and its own
test file is this session’s own documentation), and is never reached by
the Shiny app’s reactive chain or any exported function. Matches Phase
1a’s own precedent exactly (`.positionTreeApportion()` also shipped
inert, wired to nothing, in its own session). No runtime behavior
changed; nothing to smoke-test.

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `NEWS.Rmd` / `a2interactive.Rmd` / `_pkgdown.yml`
checklists all **N/A** — no new exported function, no new user-facing
Shiny feature, `@noRd` throughout. GitHub issue close-out **N/A** —
issue \#141 stays open (this is one slice of a 5+ session parent plan).
Lint checklist **DONE** (0 lints on both touched files, confirmed
above).

**Self-assessment (Session 614): 9/10.** **Strengths:** (1) Derived
exact-value oracles for the numerically-tricky RED fixtures by actually
executing the existing engine against a throwaway probe, rather than
hand-computing or guessing — caught 3 of my own fixture-construction
mistakes before they ever reached the implementation phase, matching
this investigation’s own established “verified by execution” standard.
(2) Made the Phase 2a/2b scope split explicit via its own dedicated
`AskUserQuestion`, rather than either forcing all of Phase 2 into one
session (risking a rushed, under-verified close) or silently narrowing
scope without surfacing the decision. (3) Diagnosed every GREEN-phase
test failure by actually running the specific failing fixture in
isolation and reasoning from real output, not by inspection or
assumption — this is what distinguished the 2 genuine implementation
defects from the 7 test-authoring bugs, and would have been impossible
to sort out correctly from code-reading alone. (4) Recorded both genuine
defect classes as transferable `PROJECT_LEARNINGS.md` entries with
concrete practical rules, not just fixed-and-moved-on. (5) Ran the full
clean-regression read 3 times (post-RED, post-GREEN, post-REFACTOR) plus
a fresh
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html),
not just once at the end. **Weaknesses:** (1) The Phase 1B claim was not
made at the literal next tool call after the user picked this item — 2
large planning-document reads happened first (disclosed above, no
technical harm resulted, but the discipline itself was violated). (2)
Did not build the live-render helper or measure the real 375-individual
fixture this session — **this is a real, material gap, not a
formality**: the parent plan’s own Verification Plan names the
real-fixture zero-coincidence check as “the single most important test
in the whole migration,” and it has NOT been run against this new
adapter. Phase 2a being GREEN on synthetic fixtures is necessary but
explicitly not sufficient evidence the adapter is correct on the actual
pedigree shape this whole redesign exists to fix — a future session must
not skip Phase 2b or treat Phase 2a’s own green tests as if they already
answered that question. (3) 3 of my own 17 RED-phase fixtures needed
correction during GREEN (not wrong in intent, but wrong in a specific
mechanical detail — which party wins an anchor tie-break, or what a
legitimate epsilon nudge does to an exact-equality assertion) — a more
careful first pass, verifying EVERY fixture (not just the
numerically-hardest ones) against the real `.buildMatingUnitForest()`
before finalizing, would have caught these in RED rather than GREEN.
**ROI:** high — Phase 2’s single largest, most novel implementation
slice (the 3-tier adapter itself) is done and verified; Phase 2b is now
a bounded, well-scoped remainder (build one reusable helper, run it on
2-3 fixtures) rather than an undifferentiated continuation of “the whole
rest of Phase 2.”

**Next steps:** Phase 2b (its own session) — build
`tests/testthat/helper-live-render-positions.R` (the chromote-based
`getPositions()` ground-truth harness the parent plan’s own Phase 2 spec
requires), then run the real-fixture zero-coincidence gate and the
F1/Track-C/real-375 live-render checks against
`.positionMatingUnitForestBJL()`. **Must explicitly measure, not
assume:** whether the adapter’s own zero-exact-coincidence property
(verified so far only on synthetic fixtures) survives the real
375-individual pedigree’s own scale and irregularity — if it does not,
Phase 2b returns to Phase 1b with the specific counter-example, per the
parent plan’s own gate. Also owed from S613’s own Obligation 3 (deferred
here, not dropped): fold the widened union-dot/`M_repr`
cosmetic-distance disclosure (`sweepMinSep()` pushing `P` itself, not
only `P`’s children) into whatever real-fixture measurement Phase 2b
runs.

**Key files:** `R/makePedigreeDiagramData.R:1278-1457`
(`.positionMatingUnitForestBJL()`, the new function, immediately after
`.positionMatingUnitForest()` and before
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md));
`tests/testthat/test_positionMatingUnitForestBJL.R` (all 17 tests, own
header documents the Phase 2b deferral explicitly);
`R/positionTreeApportion.R` (unchanged, Phase 1a engine this adapter
calls into for Tier 1);
`docs/planning/pedigree-diagram- walker-bjl-phase1b-mixed-gen-reconciliation.md`
§3/§8 (the mechanism/formula this implements); `PROJECT_LEARNINGS.md`
Learnings 639/640 (the 2 defect classes found this session).

**Gotchas for Phase 2b:** (1) The chromote live-render helper is
genuinely new infrastructure (no prior committed version exists despite
2 prior bespoke, uncommitted uses per the parent plan’s own C2-4
finding) — budget real design time, not just a mechanical port. (2)
`.positionMatingUnitForestBJL()` is entirely untested against ANY
real-world-shaped irregularity (polygamous anchors beyond 5 mates, deep
asymmetric branches, actual dangling-parent data) — the real-375 fixture
will very likely surface at least one case the 17 synthetic fixtures
didn’t anticipate; do not be surprised if Phase 2b needs its own
repair-and-critique round rather than a clean first pass, matching this
investigation’s own 6-prior-attempts history. (3)
`mateCountP`/`mateCountM` in `qualifies()` are computed via
`sum(anchoredUnits$sire==id | anchoredUnits$dam==id)` — this counts
ANCHORED unions only (matching the design note’s own intent), not total
mating-unit membership; if a future change touches this function,
preserve that distinction. (4) `derivedX()`’s `isB1` parameter is passed
explicitly by each call site (never inferred from `memberId %in% b1Ids`)
specifically to avoid Learning 639’s own bug recurring — do not
“simplify” this back to an inferred check.

------------------------------------------------------------------------

### Session 614 Handoff Evaluation (by Session 615)

**Score: 9/10.** **What helped:** the `HANDOFFS.md`/`SESSION_NOTES.md`
`next_steps` field named 5 exact, executable pieces of work (“build
helper-live-render-positions.R”; “run the real-fixture zero-coincidence
gate”; “the F1/Track-C/real-375 live-render checks”; “must explicitly
measure, not assume: whether the zero-exact-coincidence property
survives real scale”; “fold in S613’s Obligation 3”) — all 5 were
directly actionable and became this session’s own 7 new tests almost
one-to-one. `key_files` pointed exactly at the shipped
`.positionMatingUnitForestBJL()` (`:1278-1457`) and the new function’s
own output contract (`id`/`x`/`gen`, no `y`) — both read directly and
confirmed before writing a single test. **Gotcha \#2 (“the real-375
fixture will very likely surface at least one case the 17 synthetic
fixtures didn’t anticipate”) was directly borne out — but not in the
shape predicted:** no code defect surfaced (the adapter’s own internal
invariants all passed clean on first run), but the REAL-SCALE
live-render check surfaced something more fundamental — a
previously-unmeasured characteristic of vis.js’s own rendering
(pixel-rounding collapses the shared 1e-3 cosmetic tie-break nudge) that
neither the 17 synthetic tests nor any prior session had reason to find,
since it requires actual production-scale chromote rendering to observe.
The handoff’s own framing (“do not be surprised if Phase 2b needs its
own repair-and-critique round”) correctly primed for “expect something,”
even though what showed up was a measurement finding, not an
implementation bug. **What was missing:** the handoff didn’t anticipate
that
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
itself (not just `testthat`/`lintr`) would be needed to catch a real
regression (the new “unstated dependencies in tests” WARNING) — a
reasonable gap, since Phase 2a touched zero chromote/htmlwidgets code,
so there was no reason for S614 to have hit this. **What was wrong:**
nothing found inaccurate. **ROI:** very high — the 5-item `next_steps`
list mapped almost directly onto this session’s own scope, with zero
re-derivation needed.

### What Session 615 Did

**Deliverable:** Walker/BJL Phase 2b (issue \#141) — the real-fixture
verification half of the Walker/BJL pedigree adapter, per
`docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign- plan.md`’s
Phase 2 spec and
`docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen- reconciliation.md`
§8.4 Obligation 2. **DONE** — new reusable chromote-based live-render
helper, 7 new tests (24 total in the file), all GREEN and REFACTORed.
**Started/Completed:** 2026-08-19 – 2026-08-20.

**What actually happened, in order:**

1.  **Phase 0 orientation** — read `SESSION_RUNNER.md`/`SAFEGUARDS.md`
    in full; `SESSION_NOTES.md` (S614’s own active task);
    `gh issue list` (13 open); `git status`/`log`/`diff --stat` (clean,
    6 local unpushed S614 commits, both `CHANGELOG.md`/`HANDOFFS.md`
    ledger frontiers `== HEAD`, no reconcile owed); `gh run list`
    (S612’s own `R-CMD-check.yaml` failure traced to hosted-runner infra
    flake, not code; 3 S613-push workflows shown `in_progress` 5+ hours
    — flagged as likely stuck/orphaned, not diagnosed, per
    report-don’t-fix); `methodology_dashboard.py` (96/100, 1 HIGH risk,
    unchanged from S614). Ghost-session check on the same 6 untracked
    files S614 already traced — unchanged, no new ghost work. Rendered
    the priorities list (4 numbered `AskUserQuestion` options) — **user
    picked Walker/BJL Phase 2b.**
2.  **Phase 1B claimed** — `SESSION_NOTES.md` stub + `HANDOFFS.md`
    `status: pending` receipt, committed (`87c59054`).
3.  **PRE-RED research** — full reads of both governing planning
    documents’ Phase 2 spec, Phase 1b §8.4 Obligation 1/2, and the
    `data-raw/kinship2FidelityValidation.R`/`test_makePedigreeMatingLayout.R:124`/
    investigation-doc §2.2 precedent for the live-render methodology;
    read `.positionMatingUnitForestBJL()` and
    [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
    directly (not from memory) to derive the exact `xScale=120`/
    `yScale=150` scaling and the vis.js
    `document.getElementById("graph"+el.id).chart` binding mechanism
    (read directly from the installed `visNetwork.js` source, then
    **verified live via a throwaway probe script** before committing to
    the design — confirmed the mechanism actually works and found
    `elementId` isn’t reliably honored by `visNetwork()`, so the helper
    locates the widget dynamically via
    `document.querySelector('.visNetwork')` instead). Found F1 and
    “Track C” are the SAME already-established 9-subject fixture (not 2
    separate ones the plan’s own wording suggested). **2 dedicated
    `AskUserQuestion` gates before RED:** (a) minimal position-only
    nodes/edges for the live-render check vs. full
    [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
    cosmetic decoration — owner picked minimal, informed by the probe
    confirming styling doesn’t affect `getPositions()` when physics is
    off; (b) the formal PRE-RED→RED gate itself, listing the exact 7
    planned tests.
4.  **RED** — added `.buildMinimalEdges()` test helper + 7 `test_that()`
    blocks to `test_positionMatingUnitForestBJL.R` (24 total). Confirmed
    genuine RED: the 3 helper-dependent tests errored “could not find
    function `getLiveRenderedPositions`”; the 4 real-fixture measurement
    tests (calling the ALREADY-SHIPPED adapter, genuinely unknown
    outcome) all **passed on first run** — zero-coincidence gate clean,
    exact-midpoint invariant clean, 224/237 structural count confirmed,
    Obligation 2 drift comfortably bounded. Directly computed (outside
    testthat, for the session record) the actual measured numbers:
    180/224 touching / 208/224 half-column (vs. OLD 175/224 / 203/224);
    34 qualifying B1 unions, drift 0.399–0.401.
5.  **GREEN** — implemented `getLiveRenderedPositions()`
    (`tests/testthat/helper-live-render-positions.R`). First
    combined-file run found 2 real bugs, both found and fixed via direct
    execution, not inspection: (a) chromote’s own 10s default
    `Page$loadEventFired()` timeout was too short for the 714-node real
    fixture’s self-contained HTML — added a `loadTimeout` parameter (30s
    default, 60s for the real fixture); (b) **major finding, not a
    bug**: live-rendering revealed vis.js’s `getPositions()` rounds to
    whole pixels (confirmed via a direct 3-node probe:
    `x=150/150.12/150.5` all read back as `150`), so the shared
    1e-3-raw-unit cosmetic tie-break nudge (×`xScale=120` = 0.12px) used
    by BOTH the OLD and NEW algorithms renders pixel-identical to
    whatever it was nudged away from. Measured side by side on the real
    fixture (same script, same helper): OLD 368/714 nodes
    pixel-coincident (182 groups), NEW 380/714 (190 groups) —
    comparable, a pre-existing shared characteristic, not a Phase 2b
    regression. **Stopped and asked** (via `AskUserQuestion`) rather
    than silently redesigning the tests: owner picked “diagnostic, not
    hard gate” — Tests 6/7 rewritten to assert only DataSet-integrity
    (no id silently collapses; confirmed clean on both fixtures) and
    report the measured rate via
    [`message()`](https://rdrr.io/r/base/message.html). Recorded
    `PROJECT_LEARNINGS.md` Learning 641. 24/24 tests GREEN; full clean
    regression 0 failed/0 error; `lintr::lint_package()` 0 findings
    (already clean, no fixes needed).
6.  **[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
    — found and fixed a real NEW WARNING** (“unstated dependencies in
    tests: chromote, htmlwidgets”) — the SAME `pkg::fn()` pattern
    `data-raw/kinship2FidelityValidation.R` already used safely (that
    script is `.Rbuildignore`d, outside the checked surface) is
    genuinely unsafe once copied into the CHECKED `tests/testthat/`
    surface. **Stopped and asked** rather than unilaterally choosing
    between “add to Suggests” vs. “avoid `::` syntax”; the user
    clarified the general packaging rule directly (`Suggests:` for
    test/example/vignette-needed packages, `Config/Needs/<name>:` for
    dev-tooling-only ones) rather than answering the question as posed —
    applied it: `chromote`/`htmlwidgets` added to `Suggests:` (confirmed
    `renv::snapshot(dev=TRUE)` needed no changes, both already
    transitively pinned). **User then flagged `covr`’s own placement
    mid-turn** (already sitting in `Suggests:` despite being pure
    coverage tooling, already installed independently by
    `.github/workflows/test-coverage.yaml:27`) — relocated to a new
    `Config/Needs/coverage: covr`, matching the file’s own pre-existing
    `Config/Needs/website: quarto` precedent. Flagged (not fixed, user
    directed a `BACKLOG.md` item instead) that `devtools`/
    `roxygen2`/`pkgdown` look like further instances of the same
    misplacement. Recorded `PROJECT_LEARNINGS.md` Learning 642. Re-ran
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html):
    “unstated dependencies in tests … OK” confirmed; final result 0
    errors/1 WARNING/2 NOTEs, all 3 pre-existing (non-portable filename,
    `scratchpad/` top level, `vignettes/figure/` knitr leftover) —
    identical to S614’s own baseline, zero new.
7.  **REFACTOR** — re-confirmed `lintr::lint_package()` 0 lints
    project-wide and the full test suite (via
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)’s
    own `testthat.R` run, 24/24 + whole project) green; no structural
    code changes needed beyond the GREEN-phase bug fixes already made.
8.  **Close-out:** `BACKLOG.md`’s Walker/BJL item updated with the Phase
    2b progress paragraph; new Housekeeping item added for the
    `Suggests`/`Config-Needs` cleanup (user-directed); this handoff
    written.

**Runtime smoke test (Phase 3E):** n/a, matching Phase 1a/2a’s own
precedent exactly — `.positionMatingUnitForestBJL()` itself is unchanged
this session (zero production code touched; only new test
infrastructure + a `DESCRIPTION`/`renv.lock` metadata change). No
runtime behavior changed; nothing to smoke-test.

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `NEWS.Rmd` / `a2interactive.Rmd` / `_pkgdown.yml`
checklists all **N/A** — no new exported function, no new user-facing
Shiny feature. GitHub issue close-out **N/A** — issue \#141 stays open
(one slice of a 5+ session parent plan). Lint checklist **DONE** (0
lints, confirmed above).

**Self-assessment (Session 615): 9/10.** **Strengths:** (1) Verified the
vis.js `getPositions()` binding mechanism via a live throwaway probe
BEFORE committing to the helper’s design, exactly matching this
project’s own “verified by execution” standard — caught that `elementId`
isn’t reliably honored, avoiding a design built on an untested
assumption. (2) When the live-render check revealed the pixel-rounding
characteristic, stopped and asked rather than either (a) silently
weakening the test to hide an inconvenient result, or (b) unilaterally
attempting a production-code fix outside a measurement session’s own
charter — this is the single most consequential judgment call this
session made. (3) Measured the OLD algorithm side by side with the NEW
one before characterizing the finding, rather than assuming (without
evidence) that Phase 2b’s own new code was the cause — this turned a
scary-looking “380 nodes colliding” result into a
correctly-contextualized “comparable to the pre-existing baseline”
finding. (4) Ran
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html),
not just `testthat`/`lintr`, catching a real regression neither of the
other two tools could have found; fixed it via the owner’s own stated
packaging rule rather than guessing. (5) Directly computed the actual
real-fixture measured numbers (touching/half-column counts, Obligation 2
drift range) via a standalone script for the session record, since
`testthat`’s own reporters suppress
[`message()`](https://rdrr.io/r/base/message.html) output by default.
**Weaknesses:** (1) The initial DESCRIPTION-fix question offered only 2
options (add to Suggests vs. avoid `::`) without considering the
`Config/Needs/` alternative at all — the user had to supply that framing
directly rather than it being one of the offered choices, a real gap in
the question’s own completeness. (2) Did not proactively audit the REST
of `Suggests:` for the same misplacement pattern before the user pointed
at `covr` specifically — once `covr`’s own placement was flagged,
`devtools`/`roxygen2`/`pkgdown` should arguably have been checked with
the same scrutiny in the same pass rather than only afterward, in prose,
unverified. (3) The Obligation-2 measurement test re-derives
`b1Ids`/`qualifies()` predicates directly from `forest`/`ped` rather
than reusing any shared production logic — necessary (these predicates
are internal to `.positionMatingUnitForestBJL()`, not separately
callable) but creates a real, disclosed duplication- drift risk if the
production predicate ever changes without the test being updated to
match. **ROI:** very high — Phase 2 is now fully closed out with real,
measured evidence (not just synthetic-fixture coverage) behind its own
most important gate, and a previously-unknown, potentially load-bearing
characteristic of the rendering pipeline (pixel-rounding vs. cosmetic
nudges) is now documented rather than latent.

**Next steps:** Phase 3 (cutover) — its own separate session, per the
parent plan’s own Phase 3 spec: **Commit 3-1** (4 files — production
call site switch, `.positionMatingUnitForest()`/
`.computeDupNudge()`/patch-stack deletion,
`.positionMatingUnitForestBJL()` renamed to replace it outright,
`test_positionMatingUnitForest.R` becomes the merged final test file
with re-pinned positional literals); **Commit 3-2** (2 files, genuinely
deferrable only if `test_addRectilinearWaypoints.R`/
`test_resolveEdgeNodeCollisions.R` are ALREADY green after Commit 3-1 —
must be confirmed by actually running the suite, not assumed). **A
decision Phase 3 should make explicitly, informed by this session’s own
new evidence:** whether the pixel-rounding/cosmetic-nudge characteristic
(Learning 641) needs its own follow-up design session (widening the
epsilon so it survives pixel rounding) before or after cutover — this
session deliberately left that open, not resolved, per its own
measurement-only charter. Also still owed: Phase 4 (cleanup/docs, close
issue \#141).

**Key files:** `tests/testthat/helper-live-render-positions.R` (new, the
reusable chromote helper — `getLiveRenderedPositions()`, `loadTimeout`
param); `tests/testthat/test_positionMatingUnitForestBJL.R:809-` (Phase
2b’s 7 new tests, `.buildMinimalEdges()` helper near the top);
`DESCRIPTION` (`chromote`/ `htmlwidgets` added to `Suggests:`, `covr`
moved to new `Config/Needs/coverage:`);
`R/makePedigreeDiagramData.R:1278-1457`
(`.positionMatingUnitForestBJL()`, UNCHANGED this session — read only,
for the Obligation-2 predicate re-derivation); `PROJECT_LEARNINGS.md`
Learnings 641/642 (the 2 findings this session).

**Gotchas for Phase 3:** (1) The pixel-rounding characteristic (Learning
641) applies EQUALLY to the OLD algorithm being replaced — do not treat
it as something the cutover itself needs to fix; it’s a pre-existing,
disclosed, comparable-magnitude characteristic of both. (2)
`test_positionMatingUnitForestBJL.R`’s own Tests 6/7 (F1/real-375
live-render) are diagnostic, not hard gates — when merging this file’s
content into `test_positionMatingUnitForest.R` per Commit 3-1’s own
spec, preserve that framing rather than accidentally hardening them into
a gate neither algorithm clears. (3) `.buildMinimalEdges()` and the
live-render tests deliberately do NOT exercise
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
own full cosmetic decoration (shapes/colors/twin markers) — Phase 3’s
own live-render check (F1/Track-C/real fixture, “directly confirming…
correct child-centering and no new visual overlap”) is the first point
where that full decoration actually needs live-rendering, and should
reuse `getLiveRenderedPositions()` unmodified (per the plan’s own
intent) rather than building a second helper. (4)
`getLiveRenderedPositions()`’s default
`loadTimeout=30`/`waitSeconds=1.5` are fine for small fixtures; the
real-375-scale render needs `loadTimeout=60`/`waitSeconds=3` explicitly
(not committed as new defaults, to keep small-fixture tests fast) — pass
them explicitly for any comparably large fixture in Phase 3.
