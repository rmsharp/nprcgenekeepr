# Session Notes

**Purpose:** Continuity between sessions. Each session reads this first and writes to it before closing out.

**Archived 612 record(s), 1998-12-06 → 2026-08-12** into [`docs/archive/SESSION_NOTES-through-2026-08-12.md`](docs/archive/SESSION_NOTES-through-2026-08-12.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 40 record(s), 2026-08-11 → 2026-08-13** into [`docs/archive/SESSION_NOTES-through-2026-08-13.md`](docs/archive/SESSION_NOTES-through-2026-08-13.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 76 record(s), 2026-01-26 → 2026-08-15** into [`docs/archive/SESSION_NOTES-through-2026-08-15.md`](docs/archive/SESSION_NOTES-through-2026-08-15.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

---

## ACTIVE TASK

### Session 613 Handoff Evaluation (by Session 614)
**Score: 10/10.** **What helped:** the `HANDOFFS.md` receipt's `next_steps` field named 3 exact,
binding obligations rather than a vague "continue Phase 2" pointer — "(1) write the new Test 15
... (2) restate the `qualifies(U)` gate ... the full 5 conjuncts ... (3) fold the widened
union-dot/`M_repr` cosmetic drift disclosure into whatever real-fixture measurement Phase 2
already owed." All 3 were directly actionable this session: (1) Test 15 was written in RED exactly
as specified; (2) the implementation's own `qualifies()` function uses the full 5-conjunct gate
(mateCount(P)==1, mateCount(M)==1, `!hasOwnDirectChild(P)`, both ids in `realIds`, unambiguous
opposite sex), not the abbreviated 3-conjunct form the design note's own first draft used; (3) is
explicitly folded into Phase 2b's own deferred real-fixture-measurement scope, not silently
dropped. `key_files` pointed exactly at the shipped `sweepMinSep()` (`:997-1015`) and `orderBySex`
(`:1054-1078`) line ranges — both read directly and cross-checked against my own port. `gotchas`
(1) "the S8 formula applies ONLY to the B1 qualifying case, do not generalize to B3" was directly
useful: my own first implementation draft had exactly this bug (inferring "is this a B1 call" from
`memberId %in% freePassIds` rather than from which call site invoked it), caught and fixed during
GREEN — the gotcha didn't prevent the bug, but its framing made the bug fast to recognize once the
test failure pointed at it. **What was missing:** nothing critical — Phase 2's own real size (large
enough to need this session's own further split into 2a/2b) wasn't flagged by S613's handoff, but
that was the parent plan's own "splittable if too large" note to make, not S613's job. **What was
wrong:** nothing found inaccurate. **ROI:** very high.

### What Session 614 Did
**Deliverable:** Walker/BJL Phase 2a (issue #141) — the adapter mechanics half of the pedigree
adapter parallel to production, per `docs/planning/pedigree-diagram-walker-bjl-apportioning-
redesign-plan.md`'s Phase 2 spec as amended by the Phase 1b design note's §8 resolution. **DONE**
— new `.positionMatingUnitForestBJL()` implementing the full 3-tier reconciliation, GREEN and
REFACTORed, 17/17 new tests passing, zero collateral damage. Owner-directed scope split (this
session's own Phase 1 `AskUserQuestion`, before declaring RED): Phase 2b (the live-render helper +
real-375-fixture A/B verification) is explicitly **not done** — a required, separate follow-up
session. **Started/Completed:** 2026-08-19–2026-08-20.

**What actually happened, in order:**

1. **Phase 0 orientation** — read `SESSION_RUNNER.md`/`SAFEGUARDS.md` in full; `SESSION_NOTES.md`
   (S613's own active task); `gh issue list` (13 open); `git status`/`log`/`diff --stat` (clean,
   S613 fully closed out, ledger frontiers both `== HEAD`, no reconcile owed); `gh run list` (CI
   green on recent completed runs, 2 in-progress at report time); `methodology_dashboard.py`
   (96/100, 1 HIGH risk — `SESSION_NOTES.md`/`HANDOFFS.md` both past the 2,000-line cap, unchanged
   from S613, not fixed this session per report-don't-fix). Ghost-session check on 6 untracked
   files (4 rendered `docs/planning/*.html` evidence docs, 1 Office lock-file artifact, 1
   `scratchpad/` dir of old verification scripts) — all traced to already-documented, already-
   resolved work, none a ghost deliverable. Rendered the priorities list (4 numbered
   `AskUserQuestion` options) — **user picked the Walker/BJL Phase 2 item.**
2. **Grounded directly in both planning documents before any code** — full reads of
   `docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md` (Migration Path/Phase
   2 spec) and `docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-reconciliation.md`
   (§3's mechanism, §8's seam-resolution formula and its 2 disclosed Phase-2 obligations).
   **Process gap, disclosed:** this reading ran across several large tool calls before the Phase 1B
   claim stub was written — a real deviation from Learning 628's own "claim at the literal next
   tool call" rule, caught and corrected (claimed immediately after, before any further work) but
   not avoided outright. No harm resulted (zero commits/technical changes happened during the gap),
   but the discipline itself was not followed as written.
3. **Phase 1B claimed** — `SESSION_NOTES.md` stub + `HANDOFFS.md` `status: pending` receipt,
   committed (`577ad298`).
4. **Scope decision, via its own dedicated `AskUserQuestion` before declaring RED** (per CLAUDE.md's
   own "pre-RED scope decision is a separate question" rule): given Phase 1a (a far simpler
   *generic* engine) filled a full session by itself, and Phase 2 adds the full B1/B2/B3
   classification + 3-tier reconciliation + 15-test matrix + a new live-render helper, the user
   picked **"split: adapter first"** — this session scopes to the adapter + full synthetic test
   matrix; the live-render helper and real-375-fixture verification are explicitly deferred to a
   Phase 2b session, disclosed up front in the test file's own header, not silently dropped.
5. **PRE-RED → RED**, gated via `AskUserQuestion`: wrote
   `tests/testthat/test_positionMatingUnitForestBJL.R` — 17 `test_that()` blocks (the design
   note's own 15-fixture matrix, §4 Tests 1-14 + §8.4's required Test 15, plus 3 property tests).
   Derived exact-value oracles for the numerically-tricky fixtures (Tests 1, 2, 5, 6, 11, 13, 14,
   15) by actually running Tier 1's own mechanics (a throwaway probe script calling the real,
   existing `.buildMatingUnitForest()`/`.positionTreeApportion()`/`.buildForestChildrenOf()`, plus
   a hand-copied `sweepMinSep()` backstop matching the shipped push semantics exactly) against each
   fixture — never hand-derived. Found and fixed 3 of my own fixture-construction bugs during this
   process (wrong assumed anchor in 2 fixtures; a vector-misalignment bug in a 3rd) by running each
   fixture against the REAL `.buildMatingUnitForest()` before finalizing assertions, not by
   reasoning alone. Confirmed genuine RED: all 17 blocks error on "could not find function," full
   clean regression 0 failed / 17 error (all new) / 0 non-baseline offenders. Committed (`0a43ec30`).
6. **RED → GREEN**, gated: implemented `.positionMatingUnitForestBJL()` in
   `R/makePedigreeDiagramData.R` (new function, zero changes to `.positionMatingUnitForest()` or
   any other existing code). First run found 9 failures; diagnosed and fixed each by actually
   running the failing fixture in isolation, not by inspection — **2 were genuine implementation
   defects**: (a) B1 eligibility needs an explicit `!hasParentEdge(M)` conjunct the OLD, shipped
   `freePassIds` helper doesn't carry (its own candidate pool never needed it, since under the OLD
   algorithm a mating unit's own sire/dam can never also be someone's tracked child — a distinction
   2b's "grandchild reattached as a real child" architecture breaks), causing a B2 individual to
   wrongly get a second, Tier-3 derived-point row; (b) a dangling non-anchor party (no own row in
   `ped`) crashed on `sireOf[[id]]`/`damOf[[id]]`, fixed by excluding dangling ids from B1
   eligibility up front, matching the OLD function's own confirmed behavior (verified directly:
   `.positionMatingUnitForest()` drops a dangling free-pass parent from its output entirely). The
   other 7 failures were my OWN test bugs (a legitimate epsilon nudge from Tier 2's own exact-tie
   sweep I hadn't accounted for in 2 assertions; a B1/B2 id-classification ambiguity in a 3rd
   fixture I'd wrongly assumed was "B1-free"). Recorded `PROJECT_LEARNINGS.md` Learnings 639/640 for
   both defect classes — both are genuinely transferable, not one-off. Verified: 17/17 GREEN (53
   expectations), full clean regression 0 failed/0 error project-wide, 0 non-baseline offenders.
   Committed (`e7f1f593`).
7. **GREEN → REFACTOR**, gated: `lintr::lint()` (package loaded first, Learning 224 methodology)
   found exactly 2 style lints (`character(0)` → `character(0L)`), test file already 0. Fixed,
   re-verified 17/17 GREEN + 0 lints + full clean regression unaffected. Committed (`afa7c5f5`).
8. **Extra verification beyond the gated cycle:** ran `devtools::document()` (0 changes, expected —
   `@noRd`, no exported symbol) and a full `devtools::check()` as an additional build-equivalent
   confirmation beyond the testthat/lintr checks the gated cycle itself required. Result: **1
   WARNING, 2 NOTEs, 0 errors — all 3 pre-existing, none attributable to this session's diff:** the
   non-portable-filename WARNING and the "scratchpad" top-level-directory NOTE both trace to the
   SAME untracked files this session's own Phase 0 ghost-session check already found and reported
   (an Office lock-file artifact, `inst/extdata/reference/~$e Compounding Loop.html`; a pre-existing
   `scratchpad/` dir left by an earlier, unrelated session) — confirmed pre-existing, not fixed here,
   per the established "report an incidentally-discovered, unrelated gap, don't fix it mid-session"
   precedent (Learning 382). The 3rd NOTE (`vignettes/figure/` knitr leftover) is the same
   long-documented pre-existing NOTE multiple prior sessions' own close-outs have already recorded.
9. **Close-out:** `BACKLOG.md`'s Walker/BJL item updated with the S614 progress paragraph;
   `PROJECT_LEARNINGS.md` Learnings 639/640 recorded; this handoff written.

**Runtime smoke test (Phase 3E):** n/a in the traditional sense — the new function is `@noRd`
(internal, non-exported), has zero call sites anywhere in the package (grep-confirmed: the only
reference to `.positionMatingUnitForestBJL` outside its own definition and its own test file is
this session's own documentation), and is never reached by the Shiny app's reactive chain or any
exported function. Matches Phase 1a's own precedent exactly (`.positionTreeApportion()` also
shipped inert, wired to nothing, in its own session). No runtime behavior changed; nothing to
smoke-test.

**Close-out checklist mapping** (`CLAUDE.md`): citation / tutorial-article / `NEWS.Rmd` /
`a2interactive.Rmd` / `_pkgdown.yml` checklists all **N/A** — no new exported function, no new
user-facing Shiny feature, `@noRd` throughout. GitHub issue close-out **N/A** — issue #141 stays
open (this is one slice of a 5+ session parent plan). Lint checklist **DONE** (0 lints on both
touched files, confirmed above).

**Self-assessment (Session 614): 9/10.** **Strengths:** (1) Derived exact-value oracles for the
numerically-tricky RED fixtures by actually executing the existing engine against a throwaway
probe, rather than hand-computing or guessing — caught 3 of my own fixture-construction mistakes
before they ever reached the implementation phase, matching this investigation's own established
"verified by execution" standard. (2) Made the Phase 2a/2b scope split explicit via its own
dedicated `AskUserQuestion`, rather than either forcing all of Phase 2 into one session (risking a
rushed, under-verified close) or silently narrowing scope without surfacing the decision. (3)
Diagnosed every GREEN-phase test failure by actually running the specific failing fixture in
isolation and reasoning from real output, not by inspection or assumption — this is what
distinguished the 2 genuine implementation defects from the 7 test-authoring bugs, and would have
been impossible to sort out correctly from code-reading alone. (4) Recorded both genuine defect
classes as transferable `PROJECT_LEARNINGS.md` entries with concrete practical rules, not just
fixed-and-moved-on. (5) Ran the full clean-regression read 3 times (post-RED, post-GREEN,
post-REFACTOR) plus a fresh `devtools::check()`, not just once at the end. **Weaknesses:** (1) The
Phase 1B claim was not made at the literal next tool call after the user picked this item — 2 large
planning-document reads happened first (disclosed above, no technical harm resulted, but the
discipline itself was violated). (2) Did not build the live-render helper or measure the real
375-individual fixture this session — **this is a real, material gap, not a formality**: the parent
plan's own Verification Plan names the real-fixture zero-coincidence check as "the single most
important test in the whole migration," and it has NOT been run against this new adapter. Phase 2a
being GREEN on synthetic fixtures is necessary but explicitly not sufficient evidence the adapter
is correct on the actual pedigree shape this whole redesign exists to fix — a future session must
not skip Phase 2b or treat Phase 2a's own green tests as if they already answered that question.
(3) 3 of my own 17 RED-phase fixtures needed correction during GREEN (not wrong in intent, but
wrong in a specific mechanical detail — which party wins an anchor tie-break, or what a legitimate
epsilon nudge does to an exact-equality assertion) — a more careful first pass, verifying EVERY
fixture (not just the numerically-hardest ones) against the real `.buildMatingUnitForest()` before
finalizing, would have caught these in RED rather than GREEN. **ROI:** high — Phase 2's single
largest, most novel implementation slice (the 3-tier adapter itself) is done and verified; Phase 2b
is now a bounded, well-scoped remainder (build one reusable helper, run it on 2-3 fixtures) rather
than an undifferentiated continuation of "the whole rest of Phase 2."

**Next steps:** Phase 2b (its own session) — build `tests/testthat/helper-live-render-positions.R`
(the chromote-based `getPositions()` ground-truth harness the parent plan's own Phase 2 spec
requires), then run the real-fixture zero-coincidence gate and the F1/Track-C/real-375 live-render
checks against `.positionMatingUnitForestBJL()`. **Must explicitly measure, not assume:** whether
the adapter's own zero-exact-coincidence property (verified so far only on synthetic fixtures)
survives the real 375-individual pedigree's own scale and irregularity — if it does not, Phase 2b
returns to Phase 1b with the specific counter-example, per the parent plan's own gate. Also owed
from S613's own Obligation 3 (deferred here, not dropped): fold the widened union-dot/`M_repr`
cosmetic-distance disclosure (`sweepMinSep()` pushing `P` itself, not only `P`'s children) into
whatever real-fixture measurement Phase 2b runs.

**Key files:** `R/makePedigreeDiagramData.R:1278-1457` (`.positionMatingUnitForestBJL()`,
the new function, immediately after `.positionMatingUnitForest()` and before
`makePedigreeMatingLayout()`); `tests/testthat/test_positionMatingUnitForestBJL.R` (all 17 tests,
own header documents the Phase 2b deferral explicitly); `R/positionTreeApportion.R`
(unchanged, Phase 1a engine this adapter calls into for Tier 1); `docs/planning/pedigree-diagram-
walker-bjl-phase1b-mixed-gen-reconciliation.md` §3/§8 (the mechanism/formula this implements);
`PROJECT_LEARNINGS.md` Learnings 639/640 (the 2 defect classes found this session).

**Gotchas for Phase 2b:** (1) The chromote live-render helper is genuinely new infrastructure (no
prior committed version exists despite 2 prior bespoke, uncommitted uses per the parent plan's own
C2-4 finding) — budget real design time, not just a mechanical port. (2) `.positionMatingUnitForestBJL()`
is entirely untested against ANY real-world-shaped irregularity (polygamous anchors beyond 5
mates, deep asymmetric branches, actual dangling-parent data) — the real-375 fixture will very
likely surface at least one case the 17 synthetic fixtures didn't anticipate; do not be surprised
if Phase 2b needs its own repair-and-critique round rather than a clean first pass, matching this
investigation's own 6-prior-attempts history. (3) `mateCountP`/`mateCountM` in `qualifies()` are
computed via `sum(anchoredUnits$sire==id | anchoredUnits$dam==id)` — this counts ANCHORED unions
only (matching the design note's own intent), not total mating-unit membership; if a future change
touches this function, preserve that distinction. (4) `derivedX()`'s `isB1` parameter is passed
explicitly by each call site (never inferred from `memberId %in% b1Ids`) specifically to avoid
Learning 639's own bug recurring — do not "simplify" this back to an inferred check.

---

### Session 614 Handoff Evaluation (by Session 615)
**Score: 9/10.** **What helped:** the `HANDOFFS.md`/`SESSION_NOTES.md` `next_steps` field named 5
exact, executable pieces of work ("build helper-live-render-positions.R"; "run the real-fixture
zero-coincidence gate"; "the F1/Track-C/real-375 live-render checks"; "must explicitly measure, not
assume: whether the zero-exact-coincidence property survives real scale"; "fold in S613's Obligation
3") — all 5 were directly actionable and became this session's own 7 new tests almost one-to-one.
`key_files` pointed exactly at the shipped `.positionMatingUnitForestBJL()` (`:1278-1457`) and the
new function's own output contract (`id`/`x`/`gen`, no `y`) — both read directly and confirmed
before writing a single test. **Gotcha #2 ("the real-375 fixture will very likely surface at least
one case the 17 synthetic fixtures didn't anticipate") was directly borne out — but not in the
shape predicted:** no code defect surfaced (the adapter's own internal invariants all passed clean
on first run), but the REAL-SCALE live-render check surfaced something more fundamental — a
previously-unmeasured characteristic of vis.js's own rendering (pixel-rounding collapses the shared
1e-3 cosmetic tie-break nudge) that neither the 17 synthetic tests nor any prior session had reason
to find, since it requires actual production-scale chromote rendering to observe. The handoff's own
framing ("do not be surprised if Phase 2b needs its own repair-and-critique round") correctly primed
for "expect something," even though what showed up was a measurement finding, not an implementation
bug. **What was missing:** the handoff didn't anticipate that `devtools::check()` itself (not just
`testthat`/`lintr`) would be needed to catch a real regression (the new "unstated dependencies in
tests" WARNING) — a reasonable gap, since Phase 2a touched zero chromote/htmlwidgets code, so there
was no reason for S614 to have hit this. **What was wrong:** nothing found inaccurate. **ROI:** very
high — the 5-item `next_steps` list mapped almost directly onto this session's own scope, with zero
re-derivation needed.

### What Session 615 Did
**Deliverable:** Walker/BJL Phase 2b (issue #141) — the real-fixture verification half of the
Walker/BJL pedigree adapter, per `docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-
plan.md`'s Phase 2 spec and `docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-
reconciliation.md` §8.4 Obligation 2. **DONE** — new reusable chromote-based live-render helper,
7 new tests (24 total in the file), all GREEN and REFACTORed. **Started/Completed:** 2026-08-19 –
2026-08-20.

**What actually happened, in order:**

1. **Phase 0 orientation** — read `SESSION_RUNNER.md`/`SAFEGUARDS.md` in full; `SESSION_NOTES.md`
   (S614's own active task); `gh issue list` (13 open); `git status`/`log`/`diff --stat` (clean, 6
   local unpushed S614 commits, both `CHANGELOG.md`/`HANDOFFS.md` ledger frontiers `== HEAD`, no
   reconcile owed); `gh run list` (S612's own `R-CMD-check.yaml` failure traced to hosted-runner
   infra flake, not code; 3 S613-push workflows shown `in_progress` 5+ hours — flagged as likely
   stuck/orphaned, not diagnosed, per report-don't-fix); `methodology_dashboard.py` (96/100, 1 HIGH
   risk, unchanged from S614). Ghost-session check on the same 6 untracked files S614 already
   traced — unchanged, no new ghost work. Rendered the priorities list (4 numbered `AskUserQuestion`
   options) — **user picked Walker/BJL Phase 2b.**
2. **Phase 1B claimed** — `SESSION_NOTES.md` stub + `HANDOFFS.md` `status: pending` receipt,
   committed (`87c59054`).
3. **PRE-RED research** — full reads of both governing planning documents' Phase 2 spec, Phase 1b
   §8.4 Obligation 1/2, and the `data-raw/kinship2FidelityValidation.R`/`test_makePedigreeMatingLayout.R:124`/
   investigation-doc §2.2 precedent for the live-render methodology; read `.positionMatingUnitForestBJL()`
   and `makePedigreeMatingLayout()` directly (not from memory) to derive the exact `xScale=120`/
   `yScale=150` scaling and the vis.js `document.getElementById("graph"+el.id).chart` binding
   mechanism (read directly from the installed `visNetwork.js` source, then **verified live via a
   throwaway probe script** before committing to the design — confirmed the mechanism actually
   works and found `elementId` isn't reliably honored by `visNetwork()`, so the helper locates the
   widget dynamically via `document.querySelector('.visNetwork')` instead). Found F1 and "Track C"
   are the SAME already-established 9-subject fixture (not 2 separate ones the plan's own wording
   suggested). **2 dedicated `AskUserQuestion` gates before RED:** (a) minimal position-only
   nodes/edges for the live-render check vs. full `makePedigreeMatingLayout()` cosmetic decoration
   — owner picked minimal, informed by the probe confirming styling doesn't affect `getPositions()`
   when physics is off; (b) the formal PRE-RED→RED gate itself, listing the exact 7 planned tests.
4. **RED** — added `.buildMinimalEdges()` test helper + 7 `test_that()` blocks to
   `test_positionMatingUnitForestBJL.R` (24 total). Confirmed genuine RED: the 3 helper-dependent
   tests errored "could not find function `getLiveRenderedPositions`"; the 4 real-fixture
   measurement tests (calling the ALREADY-SHIPPED adapter, genuinely unknown outcome) all **passed
   on first run** — zero-coincidence gate clean, exact-midpoint invariant clean, 224/237 structural
   count confirmed, Obligation 2 drift comfortably bounded. Directly computed (outside testthat, for
   the session record) the actual measured numbers: 180/224 touching / 208/224 half-column (vs. OLD
   175/224 / 203/224); 34 qualifying B1 unions, drift 0.399–0.401.
5. **GREEN** — implemented `getLiveRenderedPositions()` (`tests/testthat/helper-live-render-positions.R`).
   First combined-file run found 2 real bugs, both found and fixed via direct execution, not
   inspection: (a) chromote's own 10s default `Page$loadEventFired()` timeout was too short for the
   714-node real fixture's self-contained HTML — added a `loadTimeout` parameter (30s default, 60s
   for the real fixture); (b) **major finding, not a bug**: live-rendering revealed vis.js's
   `getPositions()` rounds to whole pixels (confirmed via a direct 3-node probe: `x=150/150.12/150.5`
   all read back as `150`), so the shared 1e-3-raw-unit cosmetic tie-break nudge (×`xScale=120` =
   0.12px) used by BOTH the OLD and NEW algorithms renders pixel-identical to whatever it was
   nudged away from. Measured side by side on the real fixture (same script, same helper): OLD
   368/714 nodes pixel-coincident (182 groups), NEW 380/714 (190 groups) — comparable, a
   pre-existing shared characteristic, not a Phase 2b regression. **Stopped and asked** (via
   `AskUserQuestion`) rather than silently redesigning the tests: owner picked "diagnostic, not hard
   gate" — Tests 6/7 rewritten to assert only DataSet-integrity (no id silently collapses; confirmed
   clean on both fixtures) and report the measured rate via `message()`. Recorded
   `PROJECT_LEARNINGS.md` Learning 641. 24/24 tests GREEN; full clean regression 0 failed/0 error;
   `lintr::lint_package()` 0 findings (already clean, no fixes needed).
6. **`devtools::check()` — found and fixed a real NEW WARNING** ("unstated dependencies in tests:
   chromote, htmlwidgets") — the SAME `pkg::fn()` pattern `data-raw/kinship2FidelityValidation.R`
   already used safely (that script is `.Rbuildignore`d, outside the checked surface) is genuinely
   unsafe once copied into the CHECKED `tests/testthat/` surface. **Stopped and asked** rather than
   unilaterally choosing between "add to Suggests" vs. "avoid `::` syntax"; the user clarified the
   general packaging rule directly (`Suggests:` for test/example/vignette-needed packages,
   `Config/Needs/<name>:` for dev-tooling-only ones) rather than answering the question as posed —
   applied it: `chromote`/`htmlwidgets` added to `Suggests:` (confirmed `renv::snapshot(dev=TRUE)`
   needed no changes, both already transitively pinned). **User then flagged `covr`'s own placement
   mid-turn** (already sitting in `Suggests:` despite being pure coverage tooling, already installed
   independently by `.github/workflows/test-coverage.yaml:27`) — relocated to a new
   `Config/Needs/coverage: covr`, matching the file's own pre-existing `Config/Needs/website: quarto`
   precedent. Flagged (not fixed, user directed a `BACKLOG.md` item instead) that `devtools`/
   `roxygen2`/`pkgdown` look like further instances of the same misplacement. Recorded
   `PROJECT_LEARNINGS.md` Learning 642. Re-ran `devtools::check()`: "unstated dependencies in tests
   ... OK" confirmed; final result 0 errors/1 WARNING/2 NOTEs, all 3 pre-existing (non-portable
   filename, `scratchpad/` top level, `vignettes/figure/` knitr leftover) — identical to S614's own
   baseline, zero new.
7. **REFACTOR** — re-confirmed `lintr::lint_package()` 0 lints project-wide and the full test suite
   (via `devtools::check()`'s own `testthat.R` run, 24/24 + whole project) green; no structural code
   changes needed beyond the GREEN-phase bug fixes already made.
8. **Close-out:** `BACKLOG.md`'s Walker/BJL item updated with the Phase 2b progress paragraph; new
   Housekeeping item added for the `Suggests`/`Config-Needs` cleanup (user-directed); this handoff
   written.

**Runtime smoke test (Phase 3E):** n/a, matching Phase 1a/2a's own precedent exactly —
`.positionMatingUnitForestBJL()` itself is unchanged this session (zero production code touched;
only new test infrastructure + a `DESCRIPTION`/`renv.lock` metadata change). No runtime behavior
changed; nothing to smoke-test.

**Close-out checklist mapping** (`CLAUDE.md`): citation / tutorial-article / `NEWS.Rmd` /
`a2interactive.Rmd` / `_pkgdown.yml` checklists all **N/A** — no new exported function, no new
user-facing Shiny feature. GitHub issue close-out **N/A** — issue #141 stays open (one slice of a
5+ session parent plan). Lint checklist **DONE** (0 lints, confirmed above).

**Self-assessment (Session 615): 9/10.** **Strengths:** (1) Verified the vis.js `getPositions()`
binding mechanism via a live throwaway probe BEFORE committing to the helper's design, exactly
matching this project's own "verified by execution" standard — caught that `elementId` isn't
reliably honored, avoiding a design built on an untested assumption. (2) When the live-render check
revealed the pixel-rounding characteristic, stopped and asked rather than either (a) silently
weakening the test to hide an inconvenient result, or (b) unilaterally attempting a production-code
fix outside a measurement session's own charter — this is the single most consequential judgment
call this session made. (3) Measured the OLD algorithm side by side with the NEW one before
characterizing the finding, rather than assuming (without evidence) that Phase 2b's own new code was
the cause — this turned a scary-looking "380 nodes colliding" result into a correctly-contextualized
"comparable to the pre-existing baseline" finding. (4) Ran `devtools::check()`, not just
`testthat`/`lintr`, catching a real regression neither of the other two tools could have found; fixed
it via the owner's own stated packaging rule rather than guessing. (5) Directly computed the actual
real-fixture measured numbers (touching/half-column counts, Obligation 2 drift range) via a
standalone script for the session record, since `testthat`'s own reporters suppress `message()`
output by default. **Weaknesses:** (1) The initial DESCRIPTION-fix question offered only 2 options
(add to Suggests vs. avoid `::`) without considering the `Config/Needs/` alternative at all — the
user had to supply that framing directly rather than it being one of the offered choices, a real gap
in the question's own completeness. (2) Did not proactively audit the REST of `Suggests:` for the
same misplacement pattern before the user pointed at `covr` specifically — once `covr`'s own
placement was flagged, `devtools`/`roxygen2`/`pkgdown` should arguably have been checked with the
same scrutiny in the same pass rather than only afterward, in prose, unverified. (3) The Obligation-2
measurement test re-derives `b1Ids`/`qualifies()` predicates directly from `forest`/`ped` rather than
reusing any shared production logic — necessary (these predicates are internal to
`.positionMatingUnitForestBJL()`, not separately callable) but creates a real, disclosed duplication-
drift risk if the production predicate ever changes without the test being updated to match. **ROI:**
very high — Phase 2 is now fully closed out with real, measured evidence (not just synthetic-fixture
coverage) behind its own most important gate, and a previously-unknown, potentially load-bearing
characteristic of the rendering pipeline (pixel-rounding vs. cosmetic nudges) is now documented
rather than latent.

**Next steps:** Phase 3 (cutover) — its own separate session, per the parent plan's own Phase 3
spec: **Commit 3-1** (4 files — production call site switch, `.positionMatingUnitForest()`/
`.computeDupNudge()`/patch-stack deletion, `.positionMatingUnitForestBJL()` renamed to replace it
outright, `test_positionMatingUnitForest.R` becomes the merged final test file with re-pinned
positional literals); **Commit 3-2** (2 files, genuinely deferrable only if `test_addRectilinearWaypoints.R`/
`test_resolveEdgeNodeCollisions.R` are ALREADY green after Commit 3-1 — must be confirmed by
actually running the suite, not assumed). **A decision Phase 3 should make explicitly, informed by
this session's own new evidence:** whether the pixel-rounding/cosmetic-nudge characteristic
(Learning 641) needs its own follow-up design session (widening the epsilon so it survives pixel
rounding) before or after cutover — this session deliberately left that open, not resolved, per its
own measurement-only charter. Also still owed: Phase 4 (cleanup/docs, close issue #141).

**Key files:** `tests/testthat/helper-live-render-positions.R` (new, the reusable chromote helper —
`getLiveRenderedPositions()`, `loadTimeout` param); `tests/testthat/test_positionMatingUnitForestBJL.R:809-`
(Phase 2b's 7 new tests, `.buildMinimalEdges()` helper near the top); `DESCRIPTION` (`chromote`/
`htmlwidgets` added to `Suggests:`, `covr` moved to new `Config/Needs/coverage:`); `R/makePedigreeDiagramData.R:1278-1457`
(`.positionMatingUnitForestBJL()`, UNCHANGED this session — read only, for the Obligation-2 predicate
re-derivation); `PROJECT_LEARNINGS.md` Learnings 641/642 (the 2 findings this session).

**Gotchas for Phase 3:** (1) The pixel-rounding characteristic (Learning 641) applies EQUALLY to the
OLD algorithm being replaced — do not treat it as something the cutover itself needs to fix; it's a
pre-existing, disclosed, comparable-magnitude characteristic of both. (2) `test_positionMatingUnitForestBJL.R`'s
own Tests 6/7 (F1/real-375 live-render) are diagnostic, not hard gates — when merging this file's
content into `test_positionMatingUnitForest.R` per Commit 3-1's own spec, preserve that framing
rather than accidentally hardening them into a gate neither algorithm clears. (3) `.buildMinimalEdges()`
and the live-render tests deliberately do NOT exercise `makePedigreeMatingLayout()`'s own full
cosmetic decoration (shapes/colors/twin markers) — Phase 3's own live-render check (F1/Track-C/real
fixture, "directly confirming... correct child-centering and no new visual overlap") is the first
point where that full decoration actually needs live-rendering, and should reuse
`getLiveRenderedPositions()` unmodified (per the plan's own intent) rather than building a second
helper. (4) `getLiveRenderedPositions()`'s default `loadTimeout=30`/`waitSeconds=1.5` are fine for
small fixtures; the real-375-scale render needs `loadTimeout=60`/`waitSeconds=3` explicitly (not
committed as new defaults, to keep small-fixture tests fast) — pass them explicitly for any
comparably large fixture in Phase 3.

### Session 615 Handoff Evaluation (by Session 616)
**Score: 7/10** (structural ceiling, not a quality fault). **What helped:** the receipt's
`key_files`/`what_was_done` fields let me quickly confirm `getLiveRenderedPositions()` and its
2 call sites were the only surface in play, and its own disclosed gotcha — "the real-375 fixture
will very likely surface at least one case the 17 synthetic fixtures didn't anticipate" — primed
me correctly for "expect a genuine new finding here," which turned out true, just in a different
place (CI-platform timing, not the fixture itself). **What was missing, structurally rather than
by omission:** S615's `next_steps`/`gotchas` are entirely about Phase 3 (cutover) — which is NOT
what this session worked on. This isn't a handoff quality gap: the run that actually failed
(`32335116264`) was triggered by S615's OWN final close-out commit push, meaning the failure
didn't exist yet at the moment S615 wrote its handoff — no amount of care in that handoff could
have surfaced it. This session's actual task was found by MY OWN Phase 0's `gh run list` CI-status
check (the CLAUDE.md addition ratified S545), not inherited from S615's handoff at all. **What was
wrong:** nothing found inaccurate in what S615 claimed about its own work. **ROI:** low for THIS
session specifically, but through no fault of S615's — a real structural limit on how far a
written handoff can reach (it cannot predict a CI run triggered by its own closing commit).

### What Session 616 Did
**Deliverable:** Diagnose and fix the `R-CMD-check.yaml` `windows-latest` CI failure (`gh run`
`32335116264`) introduced by S615's new `tests/testthat/helper-live-render-positions.R`. **DONE**
— root-caused to a documented chromote `Page$navigate()`/`Page$loadEventFired()` race
(rstudio/chromote#102), fixed via `$go_to()`, verified GREEN on 2 consecutive real
`R-CMD-check.yaml` pushes (`windows-latest` clean both times). **Started/Completed:** 2026-08-20.

**What actually happened, in order:**

1. **Phase 0 orientation** — read `SESSION_RUNNER.md`/`SAFEGUARDS.md` in full; `SESSION_NOTES.md`
   (S614/S615's own active task, both read in full); `gh issue list` (13 open); `git status`/`log`/
   `diff --stat` (clean, ledger frontiers both `== HEAD`, no reconcile owed); `methodology_dashboard.py`
   (96/100, 1 HIGH risk, unchanged); **`gh run list --branch master --limit 10`** (per CLAUDE.md's
   S545-ratified CI-status-check step) found `R-CMD-check.yaml` RED on `windows-latest` only, from
   S615's own final push — surfaced as a 4th numbered priorities-list option, distinct from any
   `BACKLOG.md` tag. Ghost-session check on the same 6 untracked files prior sessions already traced
   — unchanged, no new ghost work. Rendered the priorities list (4 numbered `AskUserQuestion`
   options) — **user picked the CI fix.**
2. **Protocol gap, disclosed and corrected (see `PROJECT_LEARNINGS.md` Learning 644):** went
   straight from the picker answer into diagnosis (`gh run view --log-failed`, downloading the
   failed run's artifact, reading `00check.log`/`testthat.Rout.fail`) WITHOUT claiming the session
   first — a 4th recurrence of the Learning 624/625/628 pattern. Caught once the diagnosis reached
   a concrete root-cause hypothesis; corrected immediately (claimed before writing any fix code),
   committed separately (`db736a3d`).
3. **Diagnosis, verified by primary sources, not guesswork:** downloaded the failed run's
   `nprcgenekeepr.Rcheck` artifact directly (`gh run download`) rather than trusting the annotation
   summary alone; confirmed both Windows failures were `Chromote: timed out waiting for event
   Page.loadEventFired` at `helper-live-render-positions.R:84`. `WebSearch`/`WebFetch` research
   (rstudio/chromote#102, the package's own "Loading a page reliably" vignette) identified the
   documented race between `Page$navigate()` and `Page$loadEventFired()` as separate CDP round-
   trips, and `$go_to()` as chromote's own shipped fix; confirmed `$go_to()` exists with the needed
   `timeout_`/`delay` parameters in the exact pinned/installed chromote version (0.5.1).
4. **Pre-RED approach decision, via its own `AskUserQuestion`:** this is a CI-environment-timing
   bug no local test can deterministically RED/GREEN (the race doesn't reliably reproduce on a
   quiet local machine); owner picked "no new test — the CI run itself is the test" over adding a
   source-inspection regression test, with the existing 2 chromote tests (already green locally,
   already red on Windows CI) serving as RED and a real pushed CI run as GREEN.
5. **RED→GREEN gate** (`AskUserQuestion`, exact diff spelled out) → implemented: replaced
   `helper-live-render-positions.R`'s `Page$navigate()`+`Page$loadEventFired()`+`Sys.sleep()`
   sequence with a single `$go_to(url, timeout_ = loadTimeout, delay = waitSeconds)` call.
   Verified locally: full clean regression 0 failed/0 error (incl. all 24 chromote tests),
   `lintr::lint()` 0 findings.
6. **GREEN→REFACTOR gate** (no-op, already 0 lints) → committed (`f75e3e42`), pushed, then polled
   `gh run view`/`gh run list` (background, via `Bash run_in_background` + `TaskOutput`) for the
   real R-CMD-check.yaml run until completion: **`windows-latest` GREEN** — confirms the fix. A
   DIFFERENT, unrelated failure appeared on `ubuntu-latest (release)`
   (`chromote:::launch_chrome()` process-launch abort, not the loadEventFired race) — diagnosed as
   NOT caused by this session's diff (`$go_to()` only touches post-connection page-load waiting,
   never process launch) and confirmed transient by re-running the SAME job unmodified
   (`gh run rerun --job`), which passed clean. **User flagged this had been seen before and asked
   for deeper diagnosis, not a dismissal** — researched it properly (rstudio/chromote issues
   #106/#124/#134/#150/#170, a well-documented port-allocation/resource-contention category) and
   found this project had ALREADY solved an analogous flake for a different workflow
   (`.github/workflows/shinytest2.yaml`'s `browser-actions/setup-chrome@v2` + `CHROMOTE_CHROME` +
   assert-resolvable pattern, from `docs/planning/phase8-e2e-harness-subplan.md` Risk R5) — a
   concrete, evidenced lead for a future session, filed as a `BACKLOG.md` item rather than folded
   into this session's own scope (owner-directed via `AskUserQuestion`, matching "1 and done").
7. **Mid-session, unrelated user question answered without touching files:** "why are `BACKLOG.md`
   items marked Done instead of moved to `CHANGELOG.md`" — investigated and answered directly
   (the file uses `- [x]` checked-but-retained items against its own stated "open items only"
   policy; a known, already-diagnosed gap per S518/S529's own Housekeeping item), no file changes
   made answering it.
8. **Mid-session, second explicit user task, executed inline:** "make a backlog item to simplify
   NEWS.Rmd entries... include guardrails... organize by feature not chronologically." Investigated
   S538's prior trim (386->134 lines, 2026-08-12) and the CURRENT state (315 lines/57 entries, 8
   days later — regrown in the same verbose/technical style with zero guardrail), pulled 3 verified
   current examples of the technical/verbose pattern, wrote a fully-scoped `BACKLOG.md` item
   capturing the owner's 3 explicit requirements (iterative-until-satisfied; by-feature not
   chronological; a designed, landed guardrail against recurrence).
9. **Close-out:** this handoff; `PROJECT_LEARNINGS.md` Learnings 643/644; 2 `BACKLOG.md` items
   filed (NEWS.Rmd simplification; the `launch_chrome()` flake) — committed separately (`935cca22`)
   from the code fix, per `SAFEGUARDS.md`'s commit-boundary discipline.

**Runtime smoke test (Phase 3E):** n/a — the only production-surface file touched is
`tests/testthat/helper-live-render-positions.R`, a test-only helper with zero call sites outside
`tests/testthat/`. No Shiny app / runtime behavior changed.

**Close-out checklist mapping** (`CLAUDE.md`): citation / tutorial-article / `NEWS.Rmd` /
`a2interactive.Rmd` / `_pkgdown.yml` checklists all **N/A** — no new exported function, no new
user-facing Shiny feature, test-infrastructure-only fix. GitHub issue close-out **N/A** — this
work isn't tied to a specific open issue (a CI-health fix incidental to issue #141's own Phase 2b,
not itself part of that issue's scope). Lint checklist **DONE** (0 lints, confirmed above).

**Self-assessment (Session 616): 8/10.** **Strengths:** (1) Diagnosed from primary evidence at
every step — downloaded and read the actual failed-run artifact rather than trusting the
annotation summary; researched the race condition via chromote's own documentation/issue tracker
rather than guessing at a fix; confirmed the exact installed/pinned chromote version had the
needed API before proposing it. (2) Correctly distinguished 2 genuinely different chromote failure
classes (a post-connect event race vs. a pre-connect process-launch failure) rather than assuming
one fix should cover both, or that a green retry meant "nothing more to see" — this distinction
came from actually reading the stack traces, not from a plausible-sounding unified story. (3) When
the user pushed back on treating the launch_chrome flake as a dismissible fluke, did real research
rather than either over-conceding scope (silently expanding this session) or under-responding
(reasserting "it's just flaky") — landed on a well-evidenced `BACKLOG.md` item citing this
project's OWN prior, analogous fix. (4) Honored the CI-environment-only nature of the bug by using
an actual push-and-observe verification loop (background polling) rather than declaring victory on
local-only evidence, which would have been faithful-verification failure mode #24 in this exact
shape. (5) Kept 2 unrelated mid-session user requests (the BACKLOG.md-Done question, the NEWS.Rmd
item) properly scoped — answered/filed without expanding this session's own TDD-gated deliverable.
**Weaknesses:** (1) **Repeated Learning 624/625/628's Phase 1B-skip pattern a 4th time** — went
straight from the priorities-picker answer into diagnostic work (downloading CI artifacts) before
writing the claim stub, exactly the failure mode 3 prior learnings already named. Recorded as
Learning 644 with a candidate mechanical fix (fold the claim into the picker's own
`AskUserQuestion`) rather than a 4th "try to remember better" restatement, since restating clearly
isn't working. (2) Did not verify the `windows-latest` fix with more than 2 CI runs — a race
condition fix confirmed clean twice is strong but not absolute evidence; a 3rd or Nth push over
time would strengthen confidence further, deliberately not pursued here to avoid over-scoping a
single-fix session into an extended confidence-building campaign. **ROI:** high — the actual
CI-red state this session inherited (S615's own final push, `R-CMD-check.yaml` red on
`windows-latest`) is now genuinely green, confirmed by real CI evidence, not just local passing
tests; 2 well-evidenced follow-on `BACKLOG.md` items were filed rather than either silently
expanding scope or losing the findings.

**Next steps:** No specific technical next step from this session's own scope (the CI fix is
complete and verified). 3 items now sit in `BACKLOG.md` a future session could pick up: (1) the
`launch_chrome()` intermittent-flake fix (READY, Effort M — port `shinytest2.yaml`'s Chrome-setup
pattern into `R-CMD-check.yaml`, verify via repeated pushes since the failure is intermittent);
(2) the NEWS.Rmd simplify-by-feature-with-guardrails item (READY, Effort L, owner-directed,
explicitly iterative/multi-round); (3) Walker/BJL Phase 3 (cutover, issue #141) — still the
largest single READY item, unchanged by this session, per S615's own `next_steps` (Commit 3-1 /
3-2 as specified there).

**Key files:** `tests/testthat/helper-live-render-positions.R:75-90` (the `$go_to()` fix, only
file with production-relevant changes); `BACKLOG.md` (2 new items, "Up Next" section, after the
pedigree-package-factoring item); `PROJECT_LEARNINGS.md` Learnings 643/644.

**Gotchas for future sessions:** (1) `$go_to()` is now this project's own established pattern for
ANY future chromote-based live-render helper — do not reintroduce the manual
`Page$navigate()`+`Page$loadEventFired()` sequence elsewhere. (2) The `launch_chrome()` flake is
real and NOT fixed — a future session should not assume "it passed on retry" means it's resolved;
`BACKLOG.md`'s own item lays out why (intermittent, needs the same Chrome-provisioning pattern
`shinytest2.yaml` already uses, needs repeated-push verification not single-run). (3) Learning
644's own candidate fix (folding the Phase 1B claim into the priorities-picker `AskUserQuestion`)
is untried — a future session proposing it should treat it as a hypothesis to test, not an
already-validated mechanism.

**Post-close-out correction (same session, disclosed rather than left silent, matching the
established S575/S603/S607 precedent):** after this record was first written, a context
interruption meant the Phase 3G report was never actually shown to the owner — the owner's next
message ("this is not a formal Phase 3 close-out report") caught it. Separately, before that: the
owner directly clarified the NEWS.Rmd `BACKLOG.md` item's "reorganize by feature" requirement —
feature-grouping applies WITHIN each release heading, never across them (release headings keep
their existing reverse-chronological order). `BACKLOG.md:740-770` edited to make that scoping
explicit; logged in `CHANGELOG.md` as its own dated entry (`8007c1c8`) rather than silently folded
into this record with no trace, matching this project's own "disclose a found-after-the-fact
correction" convention. Both corrections are additive — nothing in the original close-out content
above was inaccurate or retracted, unlike S603's precedent (a retracted fix) or S607's (a
verification gap); this is closer to S575's shape (real findings surfaced after the close-out
commit had already landed).


---

### What Session 617 Did
**Deliverable:** Sync this project's canonical-overlay methodology files to `v3.7` of
`https://github.com/KJ5HST/methodology.git`, per `BOOTSTRAP.md`'s "Updating an existing project"
procedure, then re-apply this project's own documented local customization to
`methodology_trim.py` (`CLAUDE.md`'s "methodology_trim.py local-customization checklist") and verify.
(IN PROGRESS)
**Started:** 2026-08-20
**Status:** Session claimed. Work beginning.
**Ledger:** `CHANGELOG: pending` — set at claim; this session's actions are recorded in
`CHANGELOG.md` at Phase 3F. Until close-out, this line is the crash breadcrumb for the next
session's reconcile.

### Session 616 Handoff Evaluation (by Session 617)
**Score: 8/10.** **What helped:** the handoff was structurally complete (all 6 minimum requirements
present, `HANDOFFS.md` receipt filled correctly) and its "Gotchas for future sessions" item 1
("`$go_to()` is now this project's own established pattern for ANY future chromote-based live-render
helper") is exactly the kind of durable, transferable fact a handoff should carry forward. **What was
missing:** nothing that blocked this session — S616's own task (a CI-timing fix) is unrelated to
today's methodology-sync task, which arrived as a fresh user directive rather than from S616's own
`next_steps` list, so there was little in that list this session could directly use. This is expected,
not a defect in S616's handoff: not every session's task descends from the immediately-prior one.
**What was wrong:** nothing found inaccurate. **ROI:** moderate — mainly useful for confirming the
repo was in a genuinely clean, fully-closed-out state before this session's own claim (verified
independently via `git status`/ledger-frontier checks in Phase 0, which matched what S616 reported).

### What Session 617 Did
**Deliverable:** Sync this project's canonical-overlay methodology files to `v3.7` of
`https://github.com/KJ5HST/methodology.git`. **DONE**, via hand-reconciliation rather than a blind
overlay — the user picked this explicitly (`AskUserQuestion`, "Hand-reconcile onto v3.7") after a
significant discovery changed the shape of the task. **Started/Completed:** 2026-08-20.

**What actually happened, in order:**

1. **Phase 0 orientation** (continuing from the prior turn) — read `SESSION_RUNNER.md`/`SAFEGUARDS.md`
   in full; `SESSION_NOTES.md` (S613-616's own active task, the Walker/BJL Phase 2a/2b + CI-fix
   thread); `gh issue list` (13 open); `git status`/`log`/`diff --stat` (clean, ledger frontiers both
   `== HEAD`); `gh run list` (several in-progress/pending from the last 2 pushes, nothing red);
   `methodology_dashboard.py` (96/100, 1 HIGH risk — `HANDOFFS.md` past its 2,000-line cap,
   unchanged); ghost-session check on 6 untracked files (all pre-existing, already traced by
   S614-616). Rendered the priorities list + `AskUserQuestion` — user did not pick from it; instead
   gave a fresh directive: "sync with v3.7 of https://github.com/KJ5HST/methodology.git".
2. **Investigated the sibling `/Users/rmsharp/Development/methodology` checkout** (a fork,
   `origin=rmsharp/methodology`, `upstream=KJ5HST/methodology`, both remotes present) — confirmed it
   has the real `v3.7` tag (`git describe --tags` → `v3.7`, commit `dcb6fc6`, "Merge pull request #74
   from KJ5HST/release/v3.7"). Ran `bin/status`/`bin/sync --dry-run` against it with the sibling
   checked out AT that tag (never touched the sibling's working tree destructively — restored to
   `main` immediately after extracting what was needed; later comparisons used `git show
   v3.7:<path>` directly, touching nothing in the sibling repo at all).
3. **Major discovery, before any file was touched:** `bin/status` flagged `SESSION_RUNNER.md`,
   `BOOTSTRAP.md`, `CLAUDE_TEMPLATE.md`, `methodology_dashboard.py`, and 3 `docs/methodology/` files
   as "locally modified" (not "N versions behind") against true `v3.7`. Full diffs revealed why:
   this project's `FRAMEWORK_LEARNINGS.md` and `methodology_trim.py` — both actively, heavily used
   (the latter for CHANGELOG/HANDOFFS/SESSION_NOTES archiving; the former never actually true
   canonical) — **have never existed in any tagged `KJ5HST/methodology` release, v1.0.0 through
   v3.7** (checked all 27 tags directly). They reached this project via the 2026-08-10 sync
   (`18d8e3c7`), whose own commit message honestly names its actual source as
   `KJ5HST/methodology v3.6-255-gc43e7ee` — the `rmsharp/methodology` fork's unreleased `main`
   branch, 255 commits past the v3.6 *tag*, not an official release. Also found:
   `methodology_dashboard.py` locally is 2.14.0, genuinely NEWER than true v3.7's 2.10.6 — a literal
   sync would have been a downgrade. Conversely, true v3.7's `SESSION_RUNNER.md` has a real addition
   this project was missing: **Failure Mode #28 "Unbounded mandatory read"** + 4 Degradation
   Detection rows. Recorded as `PROJECT_LEARNINGS.md` Learning 645.
4. **Surfaced this to the user via `AskUserQuestion`** before touching any file — 3 options
   (hand-reconcile / literal overlay / sync from the fork's main instead). **User picked
   hand-reconcile.**
5. **Executed the reconciliation**, file by file, verifying each against the actual `v3.7` tag
   content (`git show v3.7:<path>`, never the sibling's live working tree after the first checkout):
   - `SESSION_RUNNER.md`: added FM #28 + its 4 Degradation Detection rows (genuine new v3.7 content);
     kept the local `FRAMEWORK_LEARNINGS.md`-extraction pattern for the 2 Learning-routing bullets and
     the "Learnings (added by sessions)" section (local's `FRAMEWORK_LEARNINGS.md` already holds 21
     rows vs. v3.7's inline 13 — reverting would have been a real regression, confirmed by reading
     the file directly, not assumed).
   - `RECOMMENDED_SKILLS.md`: applied v3.7's improved `/caveman` skill description verbatim (a genuine
     content upgrade, unrelated to the `FRAMEWORK_LEARNINGS.md` question) — now matches v3.7 exactly.
   - `CLAUDE_TEMPLATE.md`, `ITERATIVE_METHODOLOGY.md`, `HOW_TO_USE.md`,
     `docs/methodology/workstreams/AUDIT_WORKSTREAM.md`: confirmed each's only diff is the
     `FRAMEWORK_LEARNINGS.md` citation-target (both sides self-consistent with their own pattern) —
     no change needed.
   - `BOOTSTRAP.md`: confirmed local is a strict superset of v3.7 (includes the FRAMEWORK_LEARNINGS.md/
     `methodology_trim.py` mentions AND an entire "3 rules for a `bin/sync`-less update" section v3.7
     doesn't have at all) — no change needed.
   - `methodology_dashboard.py`: kept at local 2.14.0 per the user's explicit choice (no downgrade).
   - `SAFEGUARDS.md`, `CONTEXT_TEMPLATE.md`, and 8 `docs/methodology/workstreams/*` files: already
     confirmed byte-identical to v3.7 — no action.
   - `FRAMEWORK_LEARNINGS.md`, `methodology_trim.py`: left untouched by design (not part of v3.7's
     manifest at all; `bin/sync` would neither update nor delete them).
6. **Corrected `CLAUDE.md`'s now-confirmed-inaccurate claim** that `methodology_trim.py` is "a
   canonical-overlay file per `BOOTSTRAP.md`'s sync table" — rewrote the local-customization checklist
   entry to state the actual provenance and narrow the residual risk to its real trigger (a future
   sync against the fork's *unreleased* `main`, not a tagged release, which is what S617 ran).
7. **Verified cross-references** (this project's own Learning #7 discipline, now literally cited
   inside the SESSION_RUNNER.md text just edited): grepped for stale "27 failure modes" claims after
   adding FM #28 — found and fixed one in `CLAUDE.md`'s Project-Specific Failure Modes section; found
   one more (`docs/methodology/README.md`) that is dated historical changelog prose describing a past
   release, correctly left untouched. Also refreshed `CLAUDE.md`'s stale `PROJECT_LEARNINGS.md`
   pointer count (635→645 learnings, ~3.5MB→~2.6MB actual) while already editing the surrounding text.
8. **Filed a `BACKLOG.md` Housekeeping item** for `context_budget.py` (a genuinely new v3.7 tool,
   `bin/status` reports `missing`/`absent`) — deliberately NOT adopted this session (a new capability
   is a bigger decision than syncing an existing file), flagged for a future scoping session.
9. **Verified nothing broke:** `methodology_trim.py --check` still runs cleanly on all 3 ledgers
   (CHANGELOG.md/HANDOFFS.md/SESSION_NOTES.md — pre-existing trigger-fires unrelated to this session,
   matching the dashboard's already-known HIGH risk flag); `methodology_dashboard.py` still runs,
   health unchanged at 96/100.
10. **Close-out:** this handoff; `PROJECT_LEARNINGS.md` Learning 645 recorded (step 3 above).

**Runtime smoke test (Phase 3E):** n/a — docs/tooling-only sync, zero `.R` files touched, no Shiny
app or package runtime behavior affected. Confirmed via `git status --porcelain` (only `.md` files +
`RECOMMENDED_SKILLS.md`/`CLAUDE.md`/`PROJECT_LEARNINGS.md`/`BACKLOG.md` changed).

**Close-out checklist mapping** (`CLAUDE.md`): citation / tutorial-article / `NEWS.Rmd` /
`a2interactive.Rmd` / `_pkgdown.yml` checklists all **N/A** — no R code, no exported function, no
Shiny feature. GitHub issue close-out **N/A** — not tied to a GitHub issue. Lint checklist **N/A** —
no `.R` files touched.

**Self-assessment (Session 617): 9/10.** **Strengths:** (1) Did not blindly trust "sync to v3.7" as a
mechanical file-overlay — checked out the actual tag and diffed against it before touching anything,
which is what surfaced the fork-vs-upstream provenance gap in the first place. (2) When the discovery
changed the shape of the task, stopped and asked via `AskUserQuestion` rather than either silently
downgrading working tools (`methodology_dashboard.py`, the `FRAMEWORK_LEARNINGS.md` pattern) or
silently deviating from the literal instruction by syncing from the fork instead. (3) Verified every
"locally modified" file's diff line-by-line against actual `v3.7` tag content (via `git show`, never
trusting the sibling repo's mutable working tree after the first checkout) rather than accepting
`bin/status`'s summary label at face value — this is what caught that `RECOMMENDED_SKILLS.md`'s "1
version behind" WAS a safe, genuine upgrade while the 7 "locally modified" files were not. (4) Applied
this project's own Learning #7 (cross-reference completeness) to the very edit that introduced it —
grepped for stale failure-mode-count claims after adding FM #28 and fixed the one live instance found.
(5) Recorded the provenance-gap discovery as a `PROJECT_LEARNINGS.md` learning with a concrete,
transferable practical rule, not just fixed-and-moved-on. **Weaknesses:** (1) Did not re-verify the
sibling repo's clean/restored state with a final `git status` after the last `git show`-based
extraction pass (though no further checkouts happened after the one restore, so risk was low — worth
a habit going forward: confirm the sibling repo is exactly as found before ending any session that
touches it). (2) The Phase 1B claim (S617's own stub) happened after the Phase 0
orientation-continuation and BEFORE any technical investigation began, which is correct per Learning
624/625/628/644's own repeated finding — but this session's investigation (checking out tags, running
`bin/status`) happened AFTER the claim, so this session did NOT repeat that specific failure mode;
noting explicitly since it's now a recorded pattern worth confirming session over session. **ROI:**
high — this session avoided 2 real regressions (a `methodology_dashboard.py` downgrade, a
`FRAMEWORK_LEARNINGS.md`-pattern content loss with no replacement) that a literal, un-investigated
"just run `bin/sync`" would have caused, adopted one genuine new capability (FM #28) the project was
missing, and corrected a standing factual error in `CLAUDE.md` about this project's own tooling
provenance.

**Next steps:** No further methodology-sync work is owed from this session's own scope — the
reconciliation is complete and verified. One item is now in `BACKLOG.md` Housekeeping a future session
could pick up: evaluate adopting `context_budget.py` (v3.7's new context/token-budget tracker,
READY, Effort S — a scoping session). Separately, this session's investigation makes 2 broader,
optional future considerations visible (not filed as BACKLOG items, since neither is a concrete,
scoped task yet): (a) whether `FRAMEWORK_LEARNINGS.md`/`methodology_trim.py` should be formally
re-framed as fully project-owned tools (drop the "sync" framing entirely, since no tagged release will
ever update them) or whether this project wants to periodically pull fresh copies from the fork's
`main` on purpose; (b) whether future methodology syncs should default to checking out a specific tag
in the sibling checkout (as this session did) rather than trusting whatever branch happens to be
checked out there, given `bin/sync --source=local`'s documented behavior of reading the working tree
as-is.

**Key files:** `SESSION_RUNNER.md:220-222,278,329-330,356-360,365-382` (the FM #28 addition + the
preserved `FRAMEWORK_LEARNINGS.md` pattern); `CLAUDE.md:272` (the corrected `methodology_trim.py`
provenance note), `CLAUDE.md:282,286` (refreshed cross-reference counts);
`RECOMMENDED_SKILLS.md:94` (the `/caveman` description upgrade); `BACKLOG.md` Housekeeping (the new
`context_budget.py` item, inserted first); `PROJECT_LEARNINGS.md` Learning 645 (the full
provenance-gap finding and practical rule).

**Gotchas for future sessions:** (1) A future "sync methodology" session should check out the specific
target tag in the sibling `/Users/rmsharp/Development/methodology` checkout (verify clean first,
restore the branch after) rather than trusting whatever is currently checked out there — `bin/sync
--source=local` has no concept of "the latest release," it reads the working tree as-is. (2)
`FRAMEWORK_LEARNINGS.md` and `methodology_trim.py` will NOT be touched by any future tagged-release
sync (they're absent from `bin/_manifest.py`'s `DISTRIBUTION` for every tag checked) — do not expect
`bin/status`/`bin/sync` to ever report them as anything but `missing`/absent-from-manifest when
compared against a tag; this is expected, not a bug. (3) `methodology_dashboard.py` was deliberately
left at 2.14.0 (ahead of true v3.7's 2.10.6) — if a future session syncs again and sees this flagged
"locally modified," that's the same intentional preservation, not new drift, unless the fork's version
has since fallen behind what's needed.

---

### What Session 618 Did
**Deliverable:** Fix `R-CMD-check.yaml`'s intermittent chromote Chrome-launch failure (BACKLOG.md
Housekeeping item, found S616) — port `shinytest2.yaml`'s `browser-actions/setup-chrome@v2` +
`CHROMOTE_CHROME` + preflight-resolvability pattern into `R-CMD-check.yaml`, then verify via
repeated real CI pushes. (IN PROGRESS)
**Started:** 2026-08-20
**Status:** Session claimed. Work beginning.
**Ledger:** `CHANGELOG: pending` — set at claim; this session's actions are recorded in
`CHANGELOG.md` at Phase 3F. Until close-out, this line is the crash breadcrumb for the next
session's reconcile.
