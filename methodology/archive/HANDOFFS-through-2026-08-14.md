# HANDOFFS.md — archive: 2026-08-13 → 2026-08-14

Retired records from [`HANDOFFS.md`](../../HANDOFFS.md), moved here so the live ledger stays small enough to read
in one pass. Same format, same newest-on-top order — this is the same ledger, continued.

Holds **21 record(s), 2026-08-13 → 2026-08-14**. Cut key: `2026-08-14`. Counts here are computed from the file
itself, never carried forward. This shard is frozen: it states no forward-looking rule,
because the live file owns those and a copy of one was wrong a day after it was written.

---

```handoff
session: S579
date: 2026-08-14
status: complete
self_score: 8
predecessor_score: 7
active_task: CHANGELOG.md byte-budget archive trim (BACKLOG.md Housekeeping, found S573) -- DONE.
  Archived 62 of 98 records to a new dated shard; trigger clears (32,753 B vs 65,536 B budget).
what_was_done: Hit SRF_RED on the dry run (SRF 2.0091 against the most-recent archive ec76e487,
  vs. 0.0840 against the largest-drop S547 legacy-relocation boundary) -- the Learning 549/550
  false-refusal pattern recurring. Pulled absolute byte deltas for both boundaries before
  deciding (67,286 B real regrowth in ~26h); surfaced both readings + 3 options via
  AskUserQuestion; user chose --force. Verified losslessness 3 ways (dry-run L1/L2/L3, the
  shard's own verify.sh, post-trim --check). Removed the resolved BACKLOG.md item; added
  PROJECT_LEARNINGS.md Learning 586. Commits: f18431b0 (claim), ea9a05f9 (frontier reconcile),
  66d5aa54 (the trim + BACKLOG/Learning update), plus this close-out commit.
next_steps: BACKLOG.md's remaining numbered items (in the order presented this session's Phase 0,
  none picked): locale-dependent order() sweep (qcStudbook()/orderReport(), READY, Effort M);
  stale pb_diagram_legend.png screenshot (READY, Effort S); Pedigree Diagram sibling
  subtree-width asymmetry (READY but needs its own design session first, found S576); #148 MHC
  scope-narrowing conversation (DECISION NEEDED, ratified GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT
  cluster's own last item); NPRC outreach & announcement plan (DECISION NEEDED, owner review).
  Separately, not yet its own BACKLOG item: SESSION_NOTES.md is 2,935 lines, past the 2,000-line
  dashboard HIGH-risk cap -- a future session should either archive it (methodology_trim.py
  --file SESSION_NOTES.md) or file it as its own item, matching the CHANGELOG.md byte-trigger
  precedent this session just resolved.
key_files: CHANGELOG.md (live ledger, now 32,753 B); docs/archive/CHANGELOG-through-2026-08-14.md
  (+.verify.sh, the new shard, 62 records); BACKLOG.md (Housekeeping section, item removed);
  PROJECT_LEARNINGS.md Learning 586 (the SRF_RED recurrence).
gotchas: The S547 legacy-footer relocation's SRF_RED "fix" is NOT durable -- any subsequent small
  archive of the same file becomes the new most-recent boundary and can re-trigger SRF_RED almost
  immediately (this session hit it ~1 day after the prior small archive, ec76e487). A future
  CHANGELOG.md archive session should expect to re-diagnose this same shape (pull both boundaries'
  absolute byte deltas, don't trust the ratio alone) rather than assume it's permanently resolved.
  Also: this session self-caught a Learning-553-shaped mistake (calling the priorities-picker
  AskUserQuestion before the prose Phase 0 report) -- re-read CLAUDE.md's picker convention before
  the first AskUserQuestion call of a session, not after making the same mistake again.
runtime_smoke: n/a -- docs/ledger-only change, no runtime behavior touched.
changelog_ref: 66d5aa54
commit: c35b1983
```


```handoff
session: S578
date: 2026-08-14
status: complete
self_score: 9
predecessor_score: 8
active_task: Track 6 Pedigree Diagram child-centered union-position implementation (BACKLOG.md
  Housekeeping, design ratified S576) -- DONE. A mating unit's x is now the midpoint of its own
  children's final x (was its 2 parents' midpoint), fixing the widespread "children rendered far
  from their own parent union" legibility gap.
what_was_done: Implemented docs/planning/pedigree-diagram-track6-child-centered-union-position-
  plan.md sec2 (Extended Candidate A) in .positionMatingUnitForest(). Pre-RED empirical validation
  (throwaway reimplementation of the whole function, run against unmodified
  .buildMatingUnitForest() output before touching production code) found 2 corrections beyond the
  ratified design doc's own sec2.1 snippet: (1) finalUnitX/dupX must be computed AFTER the
  orderBySex block, not at its literally-described pre-orderBySex location, or the sec2.4
  invariant breaks for a union whose child is also a swapped parent in a deeper union (measured
  19/251 violations without the reorder vs. the ratified 9/251 with it); (2) 3 real-individual x
  values (not just union/duplicate) shift as a side effect of sec2.2 removing duplicates from
  Track 3's sweep pool -- a real, non-epsilon consequence the design doc's own sec5 table did not
  state. RED: 2 new tests + 1 updated exact-value test in test_positionMatingUnitForest.R,
  confirmed failing (commit 0780cdfd). GREEN: implemented with the reorder; also fixed 2 FURTHER
  pre-existing tests (derived-equality assertions a magic-number grep couldn't find) that directly
  encoded the old formula (commit f65ecbea). devtools::check(), run as its own separate step
  (not skipped as redundant with the already-green pkgload::load_all()+test_dir() regression),
  THEN found a 3rd, genuinely new problem: 5 failures, not the expected 1 pre-existing
  test_wordlist_coverage.R failure. Root-caused via a cheap LC_ALL=C reproduction (no code
  change): order() on a character node-id vector is LC_COLLATE-locale-dependent, so WHICH of 2
  exactly-tied same-gen nodes absorbs the de-collision pass's 1e-3 epsilon nudge differed between
  the interactive en_US.UTF-8 session and devtools::check()'s own build environment -- a
  genuinely PRE-EXISTING latent defect (the original pre-Track-6 pass used the same non-radix
  order()) this decision's own widened node-category coverage first exposed. Fixed with
  method = "radix" on both affected order() calls (commit b0467657); re-verified both locales
  produce identical output. Confirmed GREEN (final): all 30 tests in the touched file pass under
  BOTH locales; 3 other test files pass unchanged; full clean regression under LC_ALL=C 1
  pre-existing unrelated failure (test_wordlist_coverage.R), 0 new; lintr::lint_package() 0
  lints; devtools::check() re-run clean: [FAIL 1 | WARN 33 | SKIP 197 | PASS 5961] -- exactly the
  known pre-existing wordlist failure, 0 warnings, 1 pre-existing note (vignettes/figure knitr
  leftover). Re-measured on the real 375-individual fixture (now locale-stable): violating child
  edges 100/251 -> 9/251, max offset 10,687 -> 4,121.25 (exact match to the ratified figure),
  duplicate-to-union distance 61.94/120.12 -> 47.93/48.00, 0 exact x/gen coincidences post-fix.
  Live/visual verification: rendered + chromote-screenshotted the small GA204Z/8LKBV9 fixture and
  the full real fixture, both edgeStyle values, 0 console errors. A broader grep sweep
  (`grep -n "order(" R/*.R`) after fixing found the SAME locale-dependent order() class exists
  more broadly across the package (2 exported functions: qcStudbook(), orderReport()) -- filed as
  its own BACKLOG.md item, not fixed (out of scope). Downstream updates: BACKLOG.md item marked
  DONE (2 rounds -- initial + the locale-fix addendum), plan doc section 10 added/extended,
  PROJECT_LEARNINGS.md Learnings 584+585 recorded. Commits: ca921a92 (claim), 0780cdfd (RED),
  f65ecbea (GREEN), 228b5071 (downstream round 1), b0467657 (locale fix), 26f7d909 (downstream
  round 2), plus this close-out commit.
next_steps: BACKLOG.md's next Housekeeping item (found S576, READY but "Effort unknown -- not
  scoped"): sibling subtree-width asymmetry -- 2-3 direct children of one mating unit can land far
  apart in x purely from differing descendant-subtree sizes, independent of union position. This
  is explicitly NOT a routine pickup -- it needs its own design/scoping session first (same core
  recursive positioning algorithm as Track 6, one level down the recursion). Do not attempt a
  quick implementation without that scoping session. Separately, 3 Effort-S/M READY items: the
  new locale-dependent-order() sweep item this session filed (qcStudbook()/orderReport(), Effort
  M); recapture the stale pb_diagram_legend.png screenshot (Effort S); trim CHANGELOG.md
  (byte-budget archive trigger fired at 83,410 B vs the 65,536 B budget, Effort S).
key_files: R/makePedigreeDiagramData.R:584 onward (.positionMatingUnitForest(), the whole
  restructured mid-section -- sweep, orderBySex, finalUnitX/dupX, de-collision [now
  method="radix"], final resweep [now method="radix"], in that new order); R/qcStudbook.R:323
  and R/orderReport.R:81,93 (the 2 exported-function instances of the same locale-dependent
  order() class, not yet fixed); tests/testthat/test_positionMatingUnitForest.R (2 new tests + 3
  updated tests, plus 4 locale-stable value corrections); docs/planning/pedigree-diagram-track6-
  child-centered-union-position-plan.md section 10 (the full corrected implementation record,
  including the locale-fix addendum).
gotchas: The next session touching .positionMatingUnitForest() must re-verify the NEW pipeline
  order (sweep -> orderBySex -> finalUnitX/dupX -> de-collision -> final resweep) before changing
  it further -- the orderBySex-before-finalUnitX ordering is LOAD-BEARING (Learning 584), not
  incidental. Also LOAD-BEARING: both order() calls in this function now use method = "radix" --
  reverting to plain order() reintroduces the LC_COLLATE-locale-dependent non-determinism
  (Learning 585); this is invisible under a single-locale interactive session and only surfaces
  via devtools::check() or an explicit LC_ALL=C rerun. A pre-RED grep for test blast radius must
  search BOTH hardcoded magic-number assertions AND derived-equality assertions (e.g.
  expect_equal(x, (a+b)/2)) -- the latter is invisible to a numeric-literal-only search. Any
  future session that also fixes qcStudbook()/orderReport() (the filed follow-up item) should
  re-run devtools::check() under LC_ALL=C explicitly, not just the faster test_dir() read, since
  that is the ONLY thing that caught this class of defect this session.
runtime_smoke: DONE -- rendered + chromote-screenshotted both the small GA204Z/8LKBV9 fixture and
  the full real 375-individual fixture, both edgeStyle values ("direct"/"rectilinear"); 0
  diagram-related console errors in either; visually confirmed a union now sits close to its own
  child, matching the fix's intent.
changelog_ref: 6 entries this session (claim, RED, GREEN, downstream round 1, locale fix,
  downstream round 2) -- see CHANGELOG.md 2026-08-14 S578 entries.
commit: b321df39
```

```handoff
session: S577
date: 2026-08-14
status: complete
self_score: 9
predecessor_score: 9
active_task: Duplicate-individual dashed connector arc curve-direction fix (BACKLOG.md
  Housekeeping, found S575, plan doc section 7a) -- DONE. Fixed the arc to bow toward ancestors
  (matching kinship2's own arcconnect() convention) regardless of which occurrence -- duplicate or
  real -- happens to sit at a smaller x.
what_was_done: Derived the exact vis.js curvedCW/curvedCCW bow-direction formula from the bundled
  vis-network.min.js (Edge._getViaCoordinates) and kinship2's own arcconnect() source (deparse()d
  from plot.pedigree, since it is not exported). Found the bug is position-DEPENDENT, not a fixed
  wrong choice: measured 19/52 same-row duplicate connectors correct pre-fix on the real
  375-individual bundled fixture, 33/52 wrong -- proving neither a blanket from/to swap nor a
  blanket curvedCW/curvedCCW swap would fix it (either just inverts which subset is wrong). RED:
  2 new tests (deterministic loopPed fixture + real fixture) asserting from.x <= to.x on every
  duplicate connector; updated 3 existing tests whose filters assumed from is always the duplicate
  id. Confirmed RED (184/188 pass). GREEN: x-ordered dupEdges' from/to by ascending x
  (R/makePedigreeDiagramData.R ~line 1342), smooth.type/roundness unchanged. Confirmed GREEN
  (188/188 targeted; 4854/4854 full clean regression, 0 error; 0 lint on touched file; real-fixture
  re-measurement 52/52 same-row connectors now correct). REFACTOR gate offered, explicitly skipped
  (diff already minimal). Runtime/visual verification: rendered + chromote-screenshotted a same-row
  demo case, visually confirmed convex/upward bow matching kinship2. devtools::check(): 1 error
  (test_wordlist_coverage.R, "matings"/"visNetwork's"), confirmed pre-existing/unrelated via git
  stash + diff against S576's own final commit (7b04a911) -- identical failure before any of this
  session's changes, not fixed here. Commits: a12ca391 (Phase 0 ledger-reconcile backfill,
  CHANGELOG.md missing an entry for S576's own ce8c50a1), a04090ec (claim), 0d013838 (RED),
  a01c176c (GREEN), ee22559c (downstream: BACKLOG.md item removed, plan doc section 7a updated),
  plus this close-out's own commit (below).
next_steps: No further work on this item -- DONE. Session picks the next BACKLOG.md priority at a
  future Phase 0: Track 6 implementation (READY, Effort L, the ratified S576 design -- 3
  coordinated changes per its own section 6 Migration Path, RED phase should write the finalUnitX
  invariant test + duplicate-vs-real de-collision regression test first); sibling
  subtree-width-asymmetry (READY but not scoped, likely needs its own design session, found S576);
  stale screenshot pb_diagram_legend.png recapture (READY, Effort S, found S574); CHANGELOG.md's
  own byte-budget archive trigger (READY, Effort S, found S573, still firing -- 92,063 B against
  65,536 B as of this session's own entries); the scheduled shinytest2.yaml CI failure (red 2+
  consecutive days, still not diagnosed); SESSION_NOTES.md's own line-cap overage (no BACKLOG item
  yet, 2,652+ lines, past the 2,000-line cap -- a routine methodology_trim.py archive is due).
key_files: R/makePedigreeDiagramData.R:1342-1360ish (the dupEdges construction, the fix itself),
  tests/testthat/test_makePedigreeMatingLayout.R (RED tests + 3 updated existing tests, search for
  "x-ordered"), docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md section 7a
  (the updated record with the root cause and fix summary).
gotchas: (1) The BACKLOG item's own "load-bearing for color/width" caution does NOT apply to
  dupEdges specifically -- verified directly: dupEdges$color/width are unconditionally NA
  regardless of from/to (set explicitly after construction), and no downstream
  .addRectilinearWaypoints() D1/D2 dogleg logic keys off a duplicate-connector row's from/to (D2
  only matches rows whose `to` is a union id "__union_*"; a duplicate connector's `to` is always a
  real individual id). Don't assume this caution generalizes to every from/to change in this
  function -- it's real for mateEdges (D2's own dogleg lookup), not for dupEdges. (2) ~50% (50/102)
  of all duplicate connectors are CROSS-row (dup and real at different gen) -- a case kinship2's own
  algorithm never produces (its duplicates are always same-row), so there is no reference convention
  to match there. The x-ordering fix applies uniformly to these too (for consistency, not because
  it's known-correct for that case) -- if the visual result for cross-row connectors ever looks
  wrong, that's a distinct, unexplored question, not a bug in this fix's own scope. (3) The vis.js
  curvedCW/curvedCCW formulas are NOT simple mirror images with negated roundness -- negating
  smooth.roundness while keeping smooth.type="curvedCW" shrinks the arc's bow magnitude toward zero
  rather than flipping its side (both the angle-rotation term AND the magnitude term share the same
  `(.5*i+.5)` coefficient in the CW formula) -- verified by extracting the actual minified source,
  not assumed from the parameter name.
runtime_smoke: DONE -- rendered 2 demo pedigrees via visNetwork::visSave() + chromote screenshot
  (a cross-row case reproducing the loopPed fixture, and a new minimal same-row polygamous-founder
  case built specifically to isolate the kinship2-comparable scenario); visually confirmed the
  same-row case now bows convex/upward, matching kinship2 exactly.
changelog_ref: this session's own CHANGELOG.md entries (ledger-reconcile backfill, claim, RED,
  GREEN, downstream updates, close-out)
commit: 3a1a8de4
```

```handoff
session: S576
date: 2026-08-14
status: complete
self_score: 8
predecessor_score: 8
active_task: Design document for the pedigree-diagram parent-child positioning offset fix
  (BACKLOG.md Housekeeping, found S575) -- DONE, ratified. Extended Candidate A: recompute a
  mating unit's x from its own children's final x-span (not its 2 parents), recompute the
  duplicate node's x from the new union x, broaden the existing de-collision pass to cover
  duplicates. TDD phase: N/A/PRE-RED throughout (a plan document, no code changed).
what_was_done: Read .positionMatingUnitForest() (R/makePedigreeDiagramData.R:584-1011) and
  .addRectilinearWaypoints()'s D1/D2 loops (:1497-1595) in full to trace the root cause. Wrote and
  ran a throwaway validation script against the real 375-individual bundled fixture
  (obfuscated_rhesus_mhc_ped.csv): reproduced S575's own baseline exactly (100/251 edges >200
  scaled units, 73/251 >500, max 10,687), then measured the proposed fix -- 9/251 >200 (91%
  reduction), max 4,121 (61% reduction). Investigated the 9 residual edges directly: traced to a
  distinct out-of-scope phenomenon (sibling subtree-width asymmetry), not a partial failure of the
  fix. Also measured a metric not named by the originating BACKLOG item (duplicate-node-to-union
  distance) and found the union-only fix alone would regress it (mean 62->849, max 120->10,567) --
  extended the design to fix it too (mean/max back to a constant 48). Wrote
  docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md (9 sections). Ratified
  via AskUserQuestion (owner selected "proceed as written"). Updated the remediation plan (new
  Track 6 entry, §7b pointer), the originating BACKLOG.md item (DESIGN RATIFIED S576), filed a new
  BACKLOG.md item for the residual finding, and appended PROJECT_LEARNINGS.md Learning 582. Commits:
  43dac0f7 (claim), plus this close-out's own commit (below).
next_steps: Implement per the design doc's own §6 Migration Path / §7 Verification Plan -- a
  separate future session (matching Track 4's own S572 design / S573 implementation split). Key
  starting points: (1) replace the finalUnitX loop at R/makePedigreeDiagramData.R:896-926 with the
  children-derived formula (design doc §2.1); (2) relocate/reformulate dupX after it, remove
  duplicates from sweepIds/sweepGen (§2.2); (3) broaden the final de-collision pass (:936-954) to
  include duplicates (§2.3) -- all 3 as one coordinated commit, not separable, since (2)/(3) exist
  specifically to close the side effect (1) alone would introduce. RED phase: write the new
  invariant test (finalUnitX == midpoint of children's final x-span, 0 exceptions on the real
  fixture) and a duplicate-vs-real de-collision regression test first. Also still open from this
  session's own Phase 0 priorities list: the arc curve-direction item (§7a, READY, Effort S/M); the
  new sibling-subtree-width-asymmetry item filed this session (Effort unknown, needs its own
  scoping); issue #148's MHC scope-narrowing conversation (DECISION NEEDED); the legend screenshot
  recapture (READY, Effort S); CHANGELOG.md's byte-budget trim (READY, Effort S); the scheduled
  shinytest2.yaml CI failure (now red 3+ consecutive days, still not diagnosed); SESSION_NOTES.md's
  own line-cap overage (no BACKLOG item yet).
key_files: docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md (the full
  design, especially §2 Decision and §6 Migration Path), R/makePedigreeDiagramData.R:896-926
  (finalUnitX, the code to replace), R/makePedigreeDiagramData.R:842-845 (dupX, to relocate/
  reformulate), R/makePedigreeDiagramData.R:936-954 (final de-collision pass, to broaden),
  docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md §4 Track 6 / §7b (the
  cross-referenced status).
gotchas: (1) S575's reported offset units (200/500/10,687) are makePedigreeMatingLayout()'s own
  SCALED display units (xScale = 120L, :1151/:1287) -- .positionMatingUnitForest() itself, called
  directly (as the implementation session's own RED tests likely will), returns RAW pre-scale
  units; multiply by 120 before comparing to any of this session's or S575's own reported figures,
  or the numbers will look off by exactly that factor (this session hit this itself before
  reconciling it). (2) The 3 changes (§2.1/§2.2/§2.3) are NOT independently choosable -- implementing
  finalUnitX's recompute (§2.1) alone, without also moving dupX (§2.2) and broadening the
  de-collision pass (§2.3), reintroduces essentially the same defect class on the duplicate-node
  side (measured this session, mean distance 62->849). (3) Every mating unit has >=1 child by
  construction (.buildMatingUnitForest() only ever synthesizes a unit from an observed child row)
  -- no empty-kids fallback is needed in the new finalUnitX loop. (4) The 9 residual >200-unit edges
  after this fix are EXPECTED, not a bug in the implementation -- they trace to sibling
  subtree-width asymmetry (a separate, already-filed BACKLOG item), not to an error in Extended
  Candidate A; don't chase them as if the implementation is incomplete.
runtime_smoke: N/A -- no runtime behavior changed this session (a design document only, no R/ or
  tests/ file touched). Stated explicitly, not silently skipped, matching Track 4's S572 precedent
  for design-session close-outs.
changelog_ref: this session's own CHANGELOG.md entries (claim, deliverable, close-out)
commit: 7b04a911
```

```handoff
session: S575
date: 2026-08-14
status: complete
self_score: 6
predecessor_score: 9
active_task: Track 5 (broaden rectilinear routing coverage) re-measurement from
  docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md §Track 5. DONE for its own
  narrow question (edge orthogonality: 0 gap, correct and unchanged). CORRECTED same session: NOT
  "no follow-up needed" overall -- owner review of the published artifact surfaced 2 real findings
  outside Track 5's own scope (see the free-text correction below the fence). TDD phase: PRE-RED
  only throughout (no RED entered, no code changed).
what_was_done: Measured 3 independent ways, all in exact agreement: (a) offline
  makePedigreeMatingLayout() on the real 375-individual bundled fixture -- 1,265/1,315 edges
  orthogonal, all 50 non-orthogonal edges are the intentionally-curved duplicate-connector dashed
  arcs, 0 non-dashed diagonal edges (vs. 237 in "direct" mode); (b) structural proof from reading
  .addRectilinearWaypoints() -- D1 routes every child edge unconditionally, D2 keeps a mate edge
  direct only when already same-row (automatically horizontal) or replaces it with 2 orthogonal
  legs, so coverage is guaranteed by construction for any pedigree, not just this fixture;
  confirmed via test_makePedigreeMatingLayout.R:1131-1144 that Track 4's own invariant makes the
  anchor-side D2 dogleg permanently unreachable, and re-ran the original Track C fixture that
  first demonstrated the diagonal-edge scenario -- 23/24 edges orthogonal, same result; (c) live
  shinytest2/chromote against the real fixture (dev package reinstalled first) -- a live JS query
  of the rendered visNetwork widget's own DataSets reproduces the offline figures exactly, 0
  console errors. Updated the remediation plan's Track 5 section with the full evidence record and
  the §5 status line (all 5 tracks now resolved). Mid-session: built and published a comparison
  Artifact (small real 13-animal subgraph, direct vs. rectilinear, live screenshots) at owner
  request -- https://claude.ai/code/artifact/6769b9f9-d94a-4675-8c67-7e19567cda79. Commits:
  68432947 (claim), 3c3412af (deliverable), plus this close-out's own commit (below).
next_steps: Track 5's own edge-orthogonality question is resolved; the remediation plan's OVERALL
  goal is NOT fully resolved -- 2 new BACKLOG.md Housekeeping items need their own future sessions:
  (a) the duplicate-connector arc's curve direction (Effort S/M, needs a vis.js
  smooth.type/roundness investigation before changing anything); (b) the parent-child positioning
  offset (Effort L, needs its own design session -- touches the core recursive positioning
  algorithm in .positionMatingUnitForest(), shared by every diagram render regardless of
  edgeStyle). Also still open from this session's own Phase 0 priorities list: issue #148's MHC
  scope-narrowing conversation (DECISION NEEDED); recapture shiny_app_use/pb_diagram_legend.png
  (READY, Effort S, found S574); CHANGELOG.md's byte-budget archive trim (READY, Effort S, found
  S573); the scheduled shinytest2.yaml CI failure (now red 3+ consecutive days, still not
  diagnosed); SESSION_NOTES.md's own line-cap overage (no BACKLOG item yet).
key_files: docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md (search "RE-MEASURED
  S575" for the Track 5 section), R/makePedigreeDiagramData.R:1466-1611 (.addRectilinearWaypoints(),
  D1/D2 loops -- the structural proof), tests/testthat/test_makePedigreeMatingLayout.R:1122-1191
  (the Track C fixture + its own Track-4-era inline comment).
gotchas: (1) A live/offline cross-check methodology worth reusing for any future "does mechanism X
  cover every case" question: query the live visNetwork widget's own
  network.body.data.{nodes,edges}.get() via app$get_js(), compute orthogonality the same way
  offline via the exported layout function directly, and confirm they match -- catches both a data-
  level gap and a rendering-config divergence (this app's own visEdges(smooth=FALSE) default) that
  a pure R-level check alone would miss. (2) Any naive (from.x===to.x)||(from.y===to.y)
  orthogonality check will always flag the duplicate-individual dashed connector arcs as
  "diagonal" -- they are DELIBERATELY curved (smooth.type="curvedCW"), not a routing gap; bucket
  dashed/curved edges separately or a future measurement will misreport a phantom gap (see
  PROJECT_LEARNINGS.md Learning 580). (3) devtools::install(quick=TRUE, upgrade=FALSE) is the
  working incantation on this devtools version -- upgrade="never" errors ("must be a single TRUE,
  FALSE, or NA"). (4) A hand-built small pedigree fixture for a live-app upload needs a birth
  column (qcStudbook() hard-errors "Required field(s) missing: birth" without it) and no dangling
  out-of-family parent references (NA them out to make founders) -- both cost a throwaway QC-
  failure round-trip this session before landing on a working 13-row fixture.
runtime_smoke: N/A by the letter of the rule (no runtime behavior changed -- investigation only,
  no R/ or tests/ file touched) -- but a live shinytest2 verification against the real bundled
  fixture was performed anyway (see what_was_done), specifically to substantiate this session's own
  measurement claims, not as a change-verification gate. 0 diagram-related console errors.
changelog_ref: this session's own CHANGELOG.md entries (claim, deliverable, close-out, correction)
commit: bb0c9bb2
```
**Post-close-out correction, same session:** after this receipt was first written with
`self_score: 9` and "no follow-up needed," the owner reviewed the published comparison artifact
directly and found 2 real issues neither Track 5 nor any prior Claim checked for -- the duplicate
connector's curve direction (concave here, convex in kinship2) and a widespread parent-child
positioning offset (100/251 real-fixture child-edge groups >200 units off, 73/251 >500, max
10,687; root-caused to `finalUnitX`'s parent-midpoint computation being decoupled from where the
child was actually positioned, compounded by Track 3's per-row spacing sweep). Both filed as new
`BACKLOG.md` items; the published artifact and this receipt were both corrected in place. Score
revised 9 -> 6: the measurement work itself was sound, but "no follow-up needed" overstated what a
narrowly-scoped edge-orthogonality measurement actually established. See `SESSION_NOTES.md`'s own
correction note (top of ACTIVE TASK) and the remediation plan's §7 for the full record.

```handoff
session: S574
date: 2026-08-14
status: complete
self_score: 9
predecessor_score: 9
active_task: Track 2 implementation (flip default edgeStyle to "rectilinear") from
  docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md Track 2. DONE. TDD phase:
  GREEN (REFACTOR declined via AskUserQuestion -- diff already minimal).
what_was_done: R/makePedigreeDiagramData.R:1091 edgeStyle arg reordered to
  c("rectilinear", "direct"); R/modPedigree.R:423-429 .currentEdgeStyle()'s NULL-input fallback
  flipped "direct" -> "rectilinear" (2-line source diff). Test fixes: 1 helper
  (test_addRectilinearWaypoints.R's .buildLayoutAndForest()) + 13 blocks across
  test_makePedigreeMatingLayout.R/test_modPedigree.R pinned to edgeStyle = "direct" explicitly
  (direct-style-specific invariants that rode the old implicit default) or rewritten to assert
  the new default; 2 new true-implicit-default assertions added (400-cap boundary,
  highlightNearest degree:6). A 9th gap (test-e2e-pedigree-module.R's trio __union_ edge
  assertion) found and fixed only after reinstalling the dev package -- see gotchas. Verified:
  full clean regression 0 failed/0 error among true offenders; devtools::check() 0 errors/0
  warnings/1 pre-existing NOTE; 0 lints on 5 touched .R files. Live shinytest2 (real bundled
  fixture, reinstalled dev package): true implicit default reads "rectilinear", 488 waypoint
  nodes, PNG export + search/highlight present, consanguineous marker survives (56 edges,
  #D55E00/width 4), 0 console errors, 3.05s timed render. Updated 3 vignettes
  (a2interactive.Rmd, colony-manager-guide.qmd, pedigree-diagram.qmd -- the 3rd found during the
  doc pass, not named in the plan's own documentation-debt note), NEWS.Rmd/NEWS.md, roxygen
  docstring + regenerated man/, both planning docs, BACKLOG.md (1 new stale-screenshot item
  flagged, not fixed). Commits: 1a81aefd (claim), plus this close-out's own commit (below).
next_steps: Only Track 5 (broaden rectilinear coverage) remains in the kinship2-fidelity
  remediation plan (docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md) --
  explicitly deferred pending a fresh side-by-side render/re-measurement against the now-landed
  Track 2 default; no effort estimate given (project's own "don't scope speculatively"
  precedent). Independent, unrelated pickup candidates: issue #148's MHC scope-narrowing
  conversation (READY, Effort S); CHANGELOG.md's byte-budget archive (READY, Effort S, found
  S573); the stale pb_diagram_legend.png screenshot (READY, Effort S, found this session); the
  scheduled shinytest2.yaml CI failure (2+ days red, reported not diagnosed by 2 consecutive
  sessions now); SESSION_NOTES.md's own 2,252+-line overage (no BACKLOG item yet).
key_files: R/makePedigreeDiagramData.R:1091 (edgeStyle arg default), :1040-1046 (roxygen doc),
  R/modPedigree.R:423-429 (.currentEdgeStyle()), tests/testthat/test_makePedigreeMatingLayout.R
  (8 blocks, search "Track 2 flips the default"), tests/testthat/test_modPedigree.R (5 blocks,
  same search string), tests/testthat/test-e2e-pedigree-module.R:171-176 (the reinstall-surfaced
  fix), docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md (search "DONE S574").
gotchas: (1) shinytest2::AppDriver spawns a genuinely separate Rscript subprocess reading the
  INSTALLED package, not whatever pkgload::load_all() shadows in the calling session -- any
  live/E2E verification MUST devtools::install() the dev source first, and VERIFY the install
  landed (formals() check), or the result is meaningless regardless of how clean it looks
  (PROJECT_LEARNINGS.md Learning 579, this session's own hard-won discovery -- cost a full
  discarded live-verification pass). (2) A full `testthat::test_dir()` regression run with
  NPRC_RUN_E2E unset SKIPS the entire E2E suite silently -- its "0 failed" is NOT evidence the
  E2E suite passed, only that it didn't run; NPRC_RUN_E2E=true is required separately (S573's own
  gotcha, reconfirmed). (3) Track 5 (the only remaining item) has no effort estimate by design --
  do not invent one; re-measure against the now-current default first. (4) The `!dashes`-selecting
  test pattern (vs. `to == unit`) is NOT edgeStyle-safe even when it looks structural --
  waypoint-touching edges get real (non-NA) colors by design, so any `!dashes`/similar broad
  selector in a future diagram-behavior test should be checked against BOTH edge styles, not
  assumed style-agnostic just because it doesn't mention edgeStyle.
runtime_smoke: Live shinytest2 verification against the real bundled fixture
  (obfuscated_rhesus_mhc_ped.csv), reinstalled dev package, TRUE implicit default (no
  pedigreeEdgeStyle input ever set) -- see what_was_done for full detail. 0 diagram-related
  console errors; 3.05s timed render.
changelog_ref: this session's own CHANGELOG.md entries (claim, deliverable, close-out)
commit: 98327c27
```

```handoff
session: S573
date: 2026-08-14
status: complete
self_score: 9
predecessor_score: 9
active_task: Track 4 implementation (gen-aware D2 anchor selection, Candidate A) from
  docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md. DONE -- vertical-slice session,
  the ratified S572 plan document was the pre-declared contract. Full strict TDD
  PRE-RED->RED->GREEN cycle (REFACTOR declined -- the GREEN diff already is the plan's own
  net-simplification claim).
what_was_done: R/makePedigreeDiagramData.R -- preferAnchor() rewritten gen-first (prefers deeper
  gen, subsuming founder-preference), the elimination/used shortcut and now-dead isFounderOf()
  removed, effGenOf's computation and the anchor dispGenOf override deleted,
  positionIndividual()'s 2 call sites reverted to genOf (24 insertions / 69 deletions, net
  simplification). New invariant test (matingUnits$gen == genOf[[anchor]], 0 exceptions on the
  real fixture) plus the 2 residual-acceptance tests at
  tests/testthat/test_positionMatingUnitForest.R:809-893 rewritten to residual-resolved
  assertions -- confirmed RED for real against unmodified source, then GREEN. 16 pre-existing
  blocks/43 expectations across test_buildMatingUnitForest.R/test_positionMatingUnitForest.R/
  test_addRectilinearWaypoints.R/test_makePedigreeMatingLayout.R re-derived from live
  implementation output, including a full premise rewrite of the consanguineous-marker
  dogleg-propagation test (its triggering scenario is now structurally unreachable, PROJECT_LEARNINGS.md
  Learning 578). Final measured figures: duplicate nodes 128->102, multi-anchor individuals
  2->22 (max 5, WCPXHD), anchor mismatches 51->0, direct-style nodes 740->714, rectilinear nodes
  1228->1202. Full clean regression 0 failed/0 error; devtools::check() 0 errors/0 warnings/1
  pre-existing NOTE; 0 lints on all 5 touched files. Phase 3E: live shinytest2 verification (both
  edgeStyle values, zero console errors, node counts matched exactly, 2 screenshots, existing
  15-test/52-assertion E2E suite unchanged). Updated both planning documents, BACKLOG.md's
  Candidate C item, added a NEWS.Rmd entry (regenerated NEWS.md, incidentally catching it up on
  5 pre-existing unregenerated entries from S563-S571). Commits: 1ebcb006 (claim), plus this
  close-out's own commit (below).
next_steps: Only Track 2 (flip default edgeStyle to "rectilinear") and Track 5 (broaden
  rectilinear coverage, blocked on Track 2) remain in the kinship2-fidelity remediation plan
  (docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md §5) -- Track 2 is now
  fully unblocked (Track 3's spacing fix and Track 4's anchor-selection decision are both
  landed). Track 2's own section (remediation plan, search "### Track 2") lists its own
  completion criteria: re-verify 6 already-shipped features (#129/#131/#132/#134/#135/#138) live
  under the new default, re-confirm the ~37%-regression-then-fixed rectilinear perf figure still
  holds at the new (lower) node counts, and update 2 vignette/article docs in the same session
  per CLAUDE.md's documentation-debt note. Independent, unrelated pickup candidates from this
  session's own Phase 0 priorities list: issue #148's MHC scope-narrowing conversation (READY,
  Effort S), the LabKey integration BLOCKED item (needs a live server), and the NPRC outreach
  plan (DECISION NEEDED, owner-executed, not a coding task).
key_files: R/makePedigreeDiagramData.R:403-412 (new gen-first preferAnchor()), :742-748 (the
  no-anchor-override comment replacing the deleted effGenOf/dispGenOf mechanism -- that
  mechanism itself no longer exists in the file, this is where its removal is explained);
  tests/testthat/test_positionMatingUnitForest.R:798-928 (the 3 RED-phase
  blocks); docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md (implementation record
  appended); docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md (Track 4
  section + §5 status note); tests/testthat/test_makePedigreeMatingLayout.R:1095-1169 (the
  fully-rewritten consanguineous-dogleg test, Learning 578's own example).
gotchas: (1) `.buildLayoutAndForest()`/`.isWaypoint()` and similar test-local helper functions in
  test_addRectilinearWaypoints.R are NOT loaded by pkgload::load_all() -- source the test file
  directly (or define the helper inline) when re-deriving values in a standalone Rscript, not
  just when running via testthat::test_file(). (2) shinytest2's skip_if_not_installed()/
  skip_on_cran() throw a hard error (not a soft skip) when called outside a testthat::test_that()
  context -- wrap any standalone live-verification script's body in test_that() even when it's
  scratch, not committed. (3) NPRC_RUN_E2E=true is a SEPARATE env var from NOT_CRAN=true -- the
  bundled E2E suite is gated on both; setting only NOT_CRAN silently skips every E2E test with no
  error, easy to mistake for "already verified." (4) Track 2's own remediation-plan section notes
  its perf-regression re-confirmation should happen "at the current node cap" -- the node cap
  itself didn't change this session, but the node COUNT feeding into that regression's own timing
  did (740->714 direct, 1228->1202 rectilinear), so re-time it fresh rather than reuse either the
  #144-era or this session's own figures as a stand-in for an actual timed run.
runtime_smoke: Live shinytest2 verification against the real bundled fixture (obfuscated_rhesus_mhc_ped.csv),
  both edgeStyle values -- node counts matched the predicted figures exactly (714 direct, 1202
  rectilinear), zero diagram-related console errors, 2 screenshots confirmed a clean render, 4
  live-queried multi-anchor individuals all rendered with valid coordinates. The existing
  15-test/52-assertion live E2E pedigree-module suite (NPRC_RUN_E2E=true) passed unchanged.
changelog_ref: this session's own CHANGELOG.md entries (claim, deliverable, close-out)
commit: 21022157
```
<**Self-score 9/10.** +: (1) full empirical PRE-RED prototype-then-revert before any RED test was
written, capturing the exact blast radius up front rather than discovering it incrementally.
(2) confirmed RED for real against unmodified source, not reasoned about -- the invariant test's
real-fixture mismatch count (51/237) independently matched the plan's own cited figure exactly.
(3) re-derived every one of the 16 broken pre-existing test blocks from live implementation
output, including recognizing when a test's entire premise (not just its numbers) needed
rewriting -- documented as a new, reusable pattern (Learning 578). (4) ran the plan's own full
§7 verification chain end to end: RED/GREEN/REFACTOR, re-measurement against the live pipeline
(not carried-forward estimates), full regression, devtools::check(), lint, AND a genuine
shinytest2 live-render check with real screenshots and live-queried node coordinates -- not just
"tests pass." (5) caught and fixed a self-introduced dangling-comment-fragment defect by
re-reading the file rather than trusting the edit tool's own success report. (6) updated every
downstream document the plan's own impact analysis named, same session. -: (1) no independent
adversarial-verification pass -- the standing gap flagged S551-S558, still open here on a
larger-than-usual single-session change. (2) the live-verification screenshots are too zoomed-out
to visually distinguish individual multi-anchor nodes by eye; the live-JS-queried coordinates
substantively cover the same "real look" requirement but a zoomed crop would have been the more
literal fulfillment.
**Predecessor (S572) score: 9/10** -- see the Session 572 Handoff Evaluation in SESSION_NOTES.md
for the full breakdown; its next_steps field pointed directly at the plan document's own §6/§7 as
executable instructions, followed with no material gaps found.>

```handoff
session: S572
date: 2026-08-14
status: complete
self_score: 8
predecessor_score: 9
active_task: Track 4 design session (anchor/founder generation-row alignment) from
  docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md §Track 4. DONE -- design
  ratified (Candidate A: gen-aware D2 anchor selection). Implementation is a separate future
  session, per Track 4's own completion criteria.
what_was_done: Wrote docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md (RATIFIED),
  following ARCHITECTURE_WORKSTREAM.md. Decision space reconstructed from 2 sibling planning
  sessions (issue143/issue144 plans) rather than the remediation plan's own loose (a)/(b)
  paraphrase -- found Candidate A/B/C already designed and empirically validated there. Adopted
  Candidate A (owner-ratified via AskUserQuestion): rewrite preferAnchor() gen-first, remove the
  used/elimination shortcut, delete effGenOf/the anchor dispGenOf override as a provable
  consequence (net simplification, not addition). Derived that a founder always has gen=0
  (founder-preference is a special case of gen-preference) and that Candidate A resolves both
  committed residual-acceptance regression tests (test_positionMatingUnitForest.R:809-893) via
  one mechanism. Independently re-simulated Candidate A's own trade-off numbers via a throwaway,
  uncommitted R script against the real 375-individual fixture: confirmed 0 anchor mismatches
  (the structural claim) and found 22 multi-anchor individuals/102 duplicate nodes (vs #144's own
  cited 21/103 -- close, folded into the plan's own evidence rather than left unchallenged).
  Cross-updated the remediation plan's Track 4 section (DESIGN RATIFIED S572) and BACKLOG.md's
  Candidate C item (not closed, still available). Added PROJECT_LEARNINGS.md Learning 577 (a
  handoff's own document pointer is a starting citation, not the complete one -- follow its own
  References/Alternatives-Considered sections one level deeper). No R files touched; no RED/GREEN
  code this session. Commits: 3a4ecc05 (claim), plus this close-out's own commit (below).
next_steps: The next session on this thread implements the ratified decision --
  docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md §6 Migration Path and §7
  Verification Plan are the direct RED/GREEN/REFACTOR instructions (edit preferAnchor() and the
  elimination-branch removal in .buildMatingUnitForest(), delete effGenOf/the anchor dispGenOf
  override in .positionMatingUnitForest(), rewrite the 2 residual-acceptance tests, re-measure
  every carried-forward number against the full pipeline rather than trusting either the #144 or
  this session's own throwaway-script figures). Per the remediation plan's own §5, Track 2 (flip
  edgeStyle default) should wait until this implementation lands. Issue #148's scope-narrowing
  conversation, the LabKey BLOCKED item, and the NPRC outreach plan remain independent, unrelated
  pickup candidates (this session's own Phase 0 priorities list).
key_files: docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md (this session's own
  deliverable, all sections); docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md
  (Track 4 section, DESIGN RATIFIED annotation); docs/planning/issue144-anchor-row-mismatch-fix-plan.md
  (the prior art this session's own decision builds directly on, §5 Alternatives Considered);
  R/makePedigreeDiagramData.R:347-546 (.buildMatingUnitForest, D1/D2 -- the future implementation
  session's edit target), :610-1056 (.positionMatingUnitForest, effGenOf/dispGenOf -- the other
  edit target); tests/testthat/test_positionMatingUnitForest.R:809-893 (the 2 regression tests to
  flip from residual-acceptance to residual-resolution); BACKLOG.md:782-800 (Candidate C item,
  annotated).
gotchas: (1) The plan document's §1.4 duplicate-node/multi-anchor figures are now BRACKETED by 2
  close-but-not-identical estimates (103/21 from #144's own session, 102/22 from this session's
  own re-simulation) -- neither is the implementation session's authoritative number; §7 step 4
  says this explicitly, but a future reader skimming only §1.3's headline "-20%, 2->21" figure
  could mistake it for exact. (2) `isFounderOf()`'s fate (dead code vs. merged vs. reused
  elsewhere) is deliberately left open in §8 -- do not assume it should simply be deleted without
  checking whether anything else in .buildMatingUnitForest() still calls it (this session did not
  exhaustively grep every remaining call site). (3) The plan's §6 step 4 carries forward #144's
  own "~38 failures across 13 blocks" test-blast-radius estimate unmodified since D1/D2 source is
  confirmed unchanged since #144 -- but 3 commits' worth of OTHER file changes (Track 1, Track 3,
  this session's own docs) could still shift the exact count; treat it as an order-of-magnitude
  expectation only, matching the plan's own explicit caveat.
runtime_smoke: n/a -- docs-only session, no code changed, no runtime behavior to verify. The one
  throwaway R script run this session was a scratchpad validation aid (not committed, not part of
  the package), matching #143/#144's own precedent for candidate-validation scripts.
changelog_ref: this session's own CHANGELOG.md entries (Phase 3F)
commit: c5d2c5a9
```

```handoff
session: S571
date: 2026-08-14
status: complete
self_score: 6
predecessor_score: 7
active_task: Track 3 (minimum mate-spacing guarantee) from docs/planning/pedigree-diagram-
  kinship2-fidelity-remediation-plan.md §Track 3. DONE -- full PRE-RED->RED->GREEN cycle
  (RED->GREEN gate skipped, self-caught, retroactively accepted -- see gotchas), REFACTOR
  skipped (owner-confirmed).
what_was_done: .positionMatingUnitForest() (R/makePedigreeDiagramData.R) gained sweepMinSep(), a
  post-merge sweep enforcing the existing minSep=1 between every same-generation real/duplicate
  node -- closing the documented S461 dragon (mergeSubtrees()'s contour-merge only guaranteed
  non-collision, not a minimum gap, between nodes nested at different recursion depths). Applied
  once before finalUnitX and once more at the very end of the function (a 2nd bug, found live
  against the real 375-individual examplePedigree: the pre-existing de-collision pass's
  epsilon-nudge could erode an already-swept gap by 1e-3 -- fixed by re-sweeping last, 0 residual
  violations across 5,334 gaps, was 28). New general-property test
  (test_positionMatingUnitForest.R:278-308), confirmed RED against unmodified source; the file's
  1 pre-existing exact-value pinned test (:191-260) recomputed against the fixed implementation's
  live output. Verified: targeted file green; full clean regression 1 pre-existing failure/33
  pre-existing warnings, byte-identical to a committed-HEAD baseline (git worktree, not stash);
  lintr::lint_package() 0 lints; devtools::check() 0 errors/0 warnings/1 pre-existing NOTE.
  Numeric spacing-variance before/after: Track B min gap 0.5->1.0 (var 0.839->0.733), Track C min
  gap 0.5->1.0 (var 0.397->0.2); live chromote re-renders of both confirm uniform spacing and
  Track C's consanguineous marker/duplicate arc stay legible. NEWS.Rmd entry added; plan document
  annotated DONE S571 with re-verified file:line citations. Commits: 92ecdb6f (claim), plus this
  close-out's own commit (below).
next_steps: Per the plan's own §5 recommended order, Track 4's dedicated design session
  (anchor/founder generation-row alignment, docs/planning/pedigree-diagram-kinship2-fidelity-
  remediation-plan.md §Track 4) is the long-pole item and does not block on anything else --
  worth starting early since it is 2+ sessions on its own (a design session first, choosing
  between 2 genuinely different target designs, then implementation). Track 2 (flip edgeStyle
  default to "rectilinear") should wait until Track 4's design question is at least decided, per
  the plan's own sequencing rationale. Issue #148's scope-narrowing conversation and the LabKey
  BLOCKED item remain independent, unrelated pickup candidates (see this session's own Phase 0
  priorities list).
key_files: R/makePedigreeDiagramData.R:758-786 (dispGenOf moved earlier, pure reordering),
  :892-939 (sweepMinSep() definition + 1st application, pre-finalUnitX), :941-975 (finalUnitX's
  nonAnchorX branch, reads the swept position), :1043-1053 (2nd/final sweepMinSep() application,
  the edge-case fix); tests/testthat/test_positionMatingUnitForest.R:191-260 (pinned test,
  recomputed), :278-308 (new general-property test); NEWS.Rmd (Track 3 entry, appended after
  Track 1's); docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md (Track 3
  section, DONE annotation).
gotchas: (1) The RED->GREEN AskUserQuestion gate was skipped this session -- moved directly from
  confirming RED into writing/verifying the full GREEN implementation. Self-caught only during
  close-out review, disclosed in full, retroactively accepted by the owner via AskUserQuestion.
  A future session should treat "did the gate actually fire as its own tool call before the next
  phase's file edits began" as a mechanically checkable fact at each phase boundary, not
  something inferred after the fact. (2) A `git stash` chained with a slow foreground Rscript
  command hit the tool's 120s timeout and was killed mid-command, before a same-invocation
  `git stash pop` could run -- this session's own uncommitted work sat stashed and briefly
  unaccounted for (recovered via `git stash list` + popping the correct entry; a 2nd, unrelated
  pre-existing stash also exists in this repo -- do not blindly pop "the" stash). Prefer an
  isolated `git worktree` (used for every later baseline comparison this session, worked
  cleanly) over `git stash` when comparing against a pre-change baseline -- no risk to
  in-progress work. (3) The shipped vignettes/articles/kinship2-fidelity-validation.qmd
  article's own trackB-nprc-*/trackC-nprc-* screenshots are now stale (captured before this
  fix) -- not regenerated this session (out of Track 3's own scope, matching Track 1's
  precedent); a future session revisiting that article should regenerate them via
  data-raw/kinship2FidelityValidation.R. (4) Track 4's own design session should start by
  re-reading docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md §Track 4
  directly (already names the 2 candidate designs and the specific code (D2/D3) each touches)
  rather than re-deriving the options from scratch.
runtime_smoke: Numeric verification (0 same-gen gaps under minSep across the real 375-individual
  examplePedigree's 5,334 gaps, confirmed both before -- 28 violations -- and after the edge-case
  fix) plus live chromote renders (scratch location, matching
  data-raw/kinship2FidelityValidation.R's own screenshot_layout() pattern, the SAME visNetwork()
  call R/modPedigree.R's own app tab uses) of the Track B (16-subject) and Track C (9-subject)
  fixtures, visually confirming uniform mate/sibling spacing and that Track C's consanguineous
  marker + duplicate dashed connector both remain legible.
changelog_ref: CHANGELOG.md 2026-08-14 S571 entries (this close-out)
commit: 5add5050
```

```handoff
session: S570
date: 2026-08-14
status: complete
self_score: 8
predecessor_score: 9
active_task: Track 1 (default unaffected fill to unfilled/white) from
  docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md §4. DONE -- full
  PRE-RED->RED->GREEN cycle, REFACTOR skipped (owner-confirmed, diff already minimal).
what_was_done: makePedigreeDiagramData() and makePedigreeMatingLayout()
  (R/makePedigreeDiagramData.R) now default every real/duplicate node to an explicit white
  (#FFFFFF) color.background even when the pedigree has no affected column at all -- previously
  gated entirely behind hasAffected. Mating-unit dot nodes stay NA unconditionally (owner
  decision). .addRectilinearWaypoints() needed no change -- already preserves a pre-existing
  color.background. RED: test_makePedigreeDiagramData.R:266-282 and
  test_makePedigreeMatingLayout.R:660-683,716-742 modified/added, confirmed failing against the
  unmodified implementation. GREEN: implementation change plus 1 additional pre-existing test fix
  (test_makePedigreeMatingLayout.R:420-450, an exact-column-list assertion that also encoded the
  old contract, caught by the full regression run, not the original PRE-RED grep scoping -- see
  PROJECT_LEARNINGS.md Learning 574). Verified: targeted files green; full clean regression 0
  failed/0 error; lintr::lint_package() 0 lints; devtools::check() 0 errors/0 warnings/1
  pre-existing unrelated NOTE (vignettes/figure/ knitr leftover). Live chromote render of the
  bundled examplePedigree (7,306 nodes) and an 8-individual fixture both visually confirm
  unfilled nodes. NEWS.Rmd entry added; plan document annotated DONE S570 with re-verified
  file:line citations. Commits: 4ec6ef79 (claim), 17d20d3d (GREEN implementation).
next_steps: Per the plan's own §5 recommended order, Track 3 (minimum mate-spacing guarantee,
  no open sub-decision) is the natural next pickup -- goes directly into PRE-RED->RED->GREEN.
  Track 4's dedicated design session (anchor/generation-row alignment) does not block Track 3 and
  could be picked up in parallel/instead if the owner wants to start the long-pole item early
  (2+ sessions on its own per the plan). Track 2 (flip edgeStyle default) should wait until after
  Track 3 lands, per the plan's own sequencing rationale (a rectilinear default over a still-
  crowded layout undersells the change). See docs/planning/pedigree-diagram-kinship2-fidelity-
  remediation-plan.md §4 (Track 3/Track 4 own scope/effort/risk/completion-criteria) and §5.
key_files: R/makePedigreeDiagramData.R:74-80,104-117 (makePedigreeDiagramData() fix),
  :1138-1148,1197-1256 (makePedigreeMatingLayout() fix), :1635-1647 (.addRectilinearWaypoints()'s
  pre-existing preservation guard, confirmed unchanged); tests/testthat/test_makePedigreeDiagramData.R:266-282;
  tests/testthat/test_makePedigreeMatingLayout.R:420-450,660-683,716-742; NEWS.Rmd (Track 1 entry,
  appended at the end of the 2.0.0.9000 dev-version block); docs/planning/pedigree-diagram-
  kinship2-fidelity-remediation-plan.md (Track 1 section, DONE annotation).
gotchas: (1) A keyword grep across a test file for the field name being changed will NOT find a
  test asserting that field's absence via an exact column-list/expect_setequal() check -- the
  field name never appears as text in that kind of assertion. The full clean regression run is
  the real backstop for this class of test, not the PRE-RED grep (PROJECT_LEARNINGS.md Learning
  574) -- worth checking proactively for Track 3, not just relying on regression to catch it
  again. (2) Track 3's own plan section (already-documented "dragon":
  docs/planning/pedigree-diagram-option2-layout-design-plan.md:486-495) targets
  .positionMatingUnitForest()'s mergeSubtrees()/minSep contour-merge
  (R/makePedigreeDiagramData.R:681-701 per the plan's own citation -- re-verify against current
  line numbers before editing, this session's own experience is that they drift). (3) This
  project's own bundled examplePedigree (no affected column) is a good fixture for Track 1-style
  visual smoke tests but is NOT informative for Track 3 (spacing) -- use the trackB 16-subject
  fixture the plan's own Claim 3 evidence is measured against instead.
runtime_smoke: Live chromote render (not committed, scratchpad script matching
  data-raw/kinship2FidelityValidation.R's own screenshot_layout() pattern) of
  nprcgenekeepr::examplePedigree (7,306 nodes) and an 8-individual fixture, both confirming every
  real/duplicate node renders visually unfilled (white interior, colored outline) and mating-unit
  dots stay small/distinct, not vis.js's own default solid fill.
changelog_ref: CHANGELOG.md 2026-08-14 S570 entries (this close-out)
commit: 1e7590c2
```

```handoff
session: S569
date: 2026-08-14
status: complete
self_score: 7
predecessor_score: 9
active_task: Planning session comparing nprcgenekeepr's Pedigree Diagram rendering against
  kinship2's (owner-observed 4-point comparison) and proposing a phased remediation plan. DONE --
  docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md written, no implementation.
what_was_done: Verified all 4 owner claims against direct evidence (source, rendered PNGs, prior
  design docs), not from memory: read R/makePedigreeDiagramData.R in full; viewed the actual
  trackB-*.png/trackC-*.png images (not just alt text); read the Track C test fixture and its
  root-cause comment (test_makePedigreeMatingLayout.R:1046-1117); read R/findGeneration.R in full
  (confirms founders always get gen=0); read both prior ratified design docs
  (pedigree-diagram-option2-layout-design-plan.md, pedigree-diagram-rectilinear-waypoint-design-
  plan.md) for already-decided scope and pre-flagged gaps; confirmed examplePedigree has no
  affected column live. Findings: claim 1 (default edge style "direct" not "rectilinear") and
  claim 2 (unaffected fill, NOT the same gap the S552->S554 fix already closed -- that fix only
  covered hasAffected==TRUE) are well-scoped default-value gaps. Claim 3 (mate spacing) is an
  already-documented, unresolved "dragon" (option2 plan :486-495, "no exact collision, not a
  minimum visual spacing"). Claim 4a (generation-row alignment) is the most consequential finding
  -- confirmed via the rendered image that an anchor renders below its own child, root-caused to
  the issue #144 effGenOf=max(own gen, every anchored union's gen) rule; confirmed via the
  rectilinear-waypoint plan's own prior 62%-of-real-mating-units measurement (:90-94) that the
  mechanism is common on real data; already flagged twice in prior docs as "a separate, unpicked
  item" (:101-117; BACKLOG.md's Candidate C item :782-794) needing its own owner sign-off. Claim
  4b (rectilinear scope) confirmed real but narrower than claimed absence (issue #142 shipped
  sibship-bar+dogleg waypoints specifically, not every-edge-orthogonal). Claim 4c (dashed
  duplicate-arc) REFUTED as missing -- dupEdges (:1305-1315) unconditionally builds it; the image
  confirms it renders, just barely legibly, because of claim 3's own spacing gap. Wrote the plan
  document: evidence, "already decided" cross-references, 5 independently-shippable tracks (1
  unaffected-fill default, 2 flip edgeStyle default, 3 minimum mate-spacing guarantee, 4 the
  anchor/generation-row decision -- its own dedicated design session, 5 broaden rectilinear
  coverage, reassessed after 3-4 land), each with scope/effort/risk/completion-criteria/
  verification/session-boundary, plus a recommended pickup order. Verified every file:line
  citation against source after a first draft; corrected 2 that were off by several lines. Added
  PROJECT_LEARNINGS.md Learning 573; bumped CLAUDE.md's learning-count pointer (572->573).
next_steps: This is a DRAFT plan only -- no code changed. A future session should either (a) pick
  up Track 1 (unaffected-fill default) or Track 3 (minimum mate-spacing) directly, both
  well-scoped enough to enter a normal PRE-RED->RED->GREEN cycle without further design work
  (Track 1 has one small open sub-decision: should mating-unit dot nodes also go transparent, or
  stay NA/vis.js-default -- resolve via a quick AskUserQuestion before RED), or (b) open Track 4
  as its own dedicated design session (the anchor/generation-row decision) first, since it is the
  long-pole item and gates how much Track 5 turns out to need. Track 2 (flip edgeStyle default)
  should wait until after Track 3 lands per the plan's own sequencing rationale. See
  docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md §5 for the full
  recommended order and each track's own session-boundary note.
key_files: docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md (this session's
  deliverable, all 5 tracks); R/makePedigreeDiagramData.R:171-173 (.affectedColor()), :1061-1062
  (edgeStyle default), :742-754 (issue #144 effGenOf fix, the claim-4a root cause), :681-701
  (mergeSubtrees/minSep, the claim-3 root cause), :1305-1315 (dupEdges, claim 4c); R/findGeneration.R
  (full file, confirms founder gen=0 always); docs/planning/pedigree-diagram-option2-layout-
  design-plan.md:486-495 (spacing dragon); docs/planning/pedigree-diagram-rectilinear-waypoint-
  design-plan.md:90-94,101-117 (62% measurement, scope-boundary note); BACKLOG.md:419-427
  (S552->S554 fix scope), :782-794 (Candidate C item).
gotchas: (1) Track 4 (generation-row alignment) is architecturally significant -- D2/D3 are shared
  foundation for both edge styles, the duplicate-node model, and the 750-node cap; per this
  project's Vertical Slice gates it cannot be folded into a slice with Tracks 1-3, and per the
  Development Process Contract needs its own PRE-RED AskUserQuestion choosing between the plan's
  2 named design alternatives before any RED work. (2) The Phase 1B claim stub was NOT written
  before this session's investigation began -- caught only at close-out (see SESSION_NOTES.md's
  own "Process gap, self-identified" note). A future session should not repeat this: write the
  stub immediately after the task is understood, before any research/reads. (3) This project's
  own bundled examplePedigree has no `affected` column -- useful as the go-to fixture for
  confirming Track 1's fix, since it already reproduces the default-fill gap live without needing
  a synthetic fixture.
runtime_smoke: n/a -- planning/documentation-only session, no R/ or tests/ file touched, nothing
  to runtime-verify.
changelog_ref: CHANGELOG.md 2026-08-14 S569 entry (this close-out)
commit: af9a387c
```

```handoff
session: S568
date: 2026-08-14
status: complete
self_score: 9
predecessor_score: 9
active_task: Resolved the disposition of the 4 untracked "Compounding Loop" files in
  inst/extdata/reference/, flagged S567 as bundled into every built package tarball. DONE --
  gitignored/.Rbuildignored the 3 real files, deleted the 4th (a content-less lock file).
what_was_done: Investigated before presenting the decision: confirmed none of the 4 files were
  yet gitignored (genuinely untracked, unlike the 4 existing precedent files); read the 3 real
  files' actual content (file/pdftotext/HTML-text extraction) and found they are a saved Claude
  Artifact about this project's own SESSION_RUNNER.md/SAFEGUARDS.md methodology
  (github.com/KJ5HST/methodology), not genetics/package content and not the same kind of material
  as the existing copyrighted-paper precedent files; confirmed via byte inspection that the 4th
  file, ~$e Compounding Loop.html, is a content-less Microsoft/LibreOffice editor lock file (162
  B), never committed (git log empty). Owner picked gitignore+Rbuildignore-in-place for the 3
  real files via AskUserQuestion (over moving them out of the directory, tracking+shipping them,
  or deleting outright); deleted the lock file unconditionally. Added a new, distinct comment
  block to both .gitignore/.Rbuildignore (the existing block's "no open-access marking"
  rationale doesn't describe this file). Wrote the .Rbuildignore comment paren-free from the
  start, applying S567's own documented gotcha rather than repeating its mistake. Verified via an
  actual pkgbuild::build() + tarball inspection (all 3 excluded; NIHMS precedent + the 1 tracked
  exception both unaffected) and git check-ignore -v (all 3 match). Full devtools::check(): 0
  errors, 0 warnings, 0 notes -- also resolved the long-standing "portable file names" WARNING
  every recent session (S563-S567) had carried forward as pre-existing, since these files were
  its cause. BACKLOG.md updated (item marked RESOLVED). Incidental finding logged, not fixed: an
  empty, untracked inst/extdata/reference/untitled folder directory (dated the same day as the
  Compounding Loop files), surfaced via the build log's own "Removed empty directory" message --
  new BACKLOG.md Housekeeping item. Commits: 794e095c (claim) + this close-out commit.
next_steps: This specific item is fully RESOLVED -- no further action owed on the Compounding
  Loop files themselves. BACKLOG.md priorities otherwise unchanged from S567's own handoff, plus
  this session's own new finding: (1) the empty inst/extdata/reference/untitled folder directory
  this session logged (READY, Effort S -- confirm with owner it's safe to delete, then rm it; no
  build-correctness impact since R CMD build already drops it silently). (2) LabKey (BLOCKED,
  Effort M -- remainder needs a live LabKey server). (3) _pkgdown.yml missing
  articles/pedigree-diagram entry (READY, Effort S). (4) issue #148/MHC (DECISION NEEDED --
  needs its own scope-narrowing conversation first, per the ratified Deferred-tier sequencing
  order). (5) NPRC outreach (DECISION NEEDED, Effort N/A, owner-executed real-world action, not
  a coding task).
key_files: .gitignore:75-85 (new Compounding Loop exclusion + comment); .Rbuildignore:119-126
  (same, paren-free per the file's own parsing rule); BACKLOG.md (item marked RESOLVED; new
  Housekeeping item for the empty "untitled folder" finding).
gotchas: (1) .Rbuildignore parses EVERY line -- including `#` comment lines -- as a Perl regex;
  an unbalanced parenthesis anywhere aborts `R CMD build` with a PCRE error (S567's own gotcha,
  re-confirmed still load-bearing -- this session applied it correctly by writing the new
  comment paren-free from the start). (2) `git status` "Untracked" vs. "Ignored" is a reliable,
  fast signal for whether a file already has gitignore coverage -- don't assume "shows up in git
  status" means "already handled the same way as its siblings"; these 4 files looked similar to
  the existing 4 precedent files by location/pattern but were NOT yet gitignored at all, a fact
  only `git status --ignored`/`check-ignore` surfaces directly. (3) `pkgbuild::build()`'s own
  console output reports "Removed empty directory ..." for any empty dir under the staged
  source tree -- a free, incidental signal for stray empty directories, worth scanning even when
  the build's main purpose is unrelated verification.
runtime_smoke: n/a -- config-only change (.gitignore/.Rbuildignore) plus deleting one
  content-less file, no Shiny/application runtime behavior touched. The applicable "build
  equivalent" (R CMD build actually excluding the target files from the built tarball, plus a
  full devtools::check()) was verified directly.
changelog_ref: CHANGELOG.md 2026-08-14 S568 claim + close-out entries
commit: 61ce96a4
```

```handoff
session: S567
date: 2026-08-14
status: complete
self_score: 9
predecessor_score: 9
active_task: Resolved the copyright/licensing classification of
  inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf (kinship2's own supplementary
  material), unresolved since S545. DONE -- gitignored, matching the S479/S497 precedent.
what_was_done: Investigated before presenting the decision (read the PDF's own first page --
  kinship2's own supplementary material, Sinnwell/Therneau/Schaid, Mayo Clinic; an NIHMS/PMC
  deposit, a materially different situation from the 3 existing "no open-access marking"
  gitignored files). Owner picked gitignore via AskUserQuestion. Added a distinguishing
  comment (not merged into the existing 3-file comment, which would have made its own
  rationale inaccurate) to .gitignore and .Rbuildignore. Caught and fixed a real
  self-introduced bug: .Rbuildignore parses every line, including # comments, as a Perl regex
  (its own header warns of this), and my first comment's parenthetical text split an
  unbalanced paren across 2 lines, aborting R CMD build with a PCRE error -- caught by
  actually running pkgbuild::build(), fixed by removing all parens from the comment. Verified
  via a real R CMD build + tarball inspection that the file is now excluded (matching the 3
  precedent files; the 1 tracked exception still ships). devtools::check(): 0 errors, 1
  pre-existing/unrelated warning, 0 notes. BACKLOG.md updated (item's Note marked RESOLVED).
  Incidental finding logged, not fixed: tarball inspection showed the untracked "Compounding
  Loop" files ARE bundled into the built package (unlike the deliberately-excluded reference
  PDFs) -- new BACKLOG.md Housekeeping item. Commits: 1b84ca97 (claim) + this close-out commit.
next_steps: This specific item is fully RESOLVED -- no further action owed on the NIHMS PDF
  itself. 2 items carried forward: (1) the new incidental finding this session logged --
  should the 4 "Compounding Loop" files move to an .Rbuildignore-excluded location, given
  they're personal reference material that currently ships in the built package and trips the
  portable-file-names WARNING? Effort S. (2) BACKLOG.md priorities otherwise unchanged from
  S566's own handoff: LabKey (BLOCKED, Effort M), _pkgdown.yml missing pedigree-diagram entry
  (READY, Effort S), issue #148/MHC (DECISION NEEDED -- needs its own scope-narrowing
  conversation, next in the ratified Deferred-tier sequencing order now that #152/#153 are both
  closed), NPRC outreach (DECISION NEEDED, Effort N/A).
key_files: .gitignore:64-72 (new NIHMS593658 exclusion + comment); .Rbuildignore:113-118 (same,
  paren-free per the file's own parsing rule); BACKLOG.md (kinship2-reproducibility-audit item's
  Note, now RESOLVED; new Housekeeping item for the Compounding Loop tarball-bundling finding).
gotchas: .Rbuildignore parses EVERY line -- including `#` comment lines -- as a Perl regex
  applied to build the source-package file list. An unbalanced parenthesis anywhere, even
  split across two separate comment lines (each line is its own independent regex), aborts
  `R CMD build` with "PCRE pattern compilation error: missing closing parenthesis." The file's
  own header already warns of this ("keep lines paren-free") but it's easy to violate anyway
  when writing multi-line prose comments -- write .Rbuildignore comments with em-dashes/commas,
  never parentheses, and verify with an actual `pkgbuild::build()`/`R CMD build`, not just
  a syntax-looks-fine read. `.gitignore` has no such restriction (its `#` lines are true
  comments) -- the two files' comment conventions are NOT interchangeable.
runtime_smoke: n/a -- config-only change (.gitignore/.Rbuildignore), no Shiny/application
  runtime behavior touched. The applicable "build equivalent" (R CMD build actually excluding
  the target file from the built tarball) was verified directly, twice: once that caught the
  regex bug, once confirming the fix.
changelog_ref: CHANGELOG.md 2026-08-14 S567 claim + close-out entries
commit: 619ffd98
```

```handoff
session: S566
date: 2026-08-14
status: complete
self_score: 8
predecessor_score: 9
active_task: File 3 GitHub issues (kinship2 supplement Tracks A/B/C, all now complete)
  and publish a numeric+graphic fidelity validation article comparing nprcgenekeepr
  against kinship2 -- DONE, closing out the whole kinship2 supplement
  full-reproduction plan.
what_was_done: Filed and closed 3 GitHub issues (#156 Track A, #157 Track B, #158
  Track C), each citing its implementing commit and this session's own independent
  re-verification. New data-raw/kinship2FidelityValidation.R computes each track's
  numeric/graphic comparison live against the installed (non-dependency) kinship2
  1.9.6.2, reusing each track's own already-committed test fixture verbatim, and
  writes 8 PNGs. New vignettes/articles/kinship2-fidelity-validation.qmd (matching
  fg-se-validation.qmd's precedent) embeds the results as frozen tables/images --
  ALL 3 tracks came back exact matches (Track A: 0 max-abs-diff across 200 kinship
  matrix cells; Track B: identical surviving-subject-set and bitSize trajectory;
  Track C: same consanguineous union flagged under both edge styles). Caught and
  fixed 2 real bugs by re-running and inspecting actual output: a kinship2
  sex-validation mismatch in 2 fixtures, and a %in%/NA-comparison defect that
  silently inflated an edge count from 2/3 to 14/10 (would have shipped wrong
  numbers if not caught). Fixed a Quarto _files-suffix directory-naming collision
  found via an actual failed render. lintr::lint_package() 0 lints (24 fixed);
  spelling::spell_check_package() 0 new flags (4 words added to inst/WORDLIST, 1
  resolved by rewording); devtools::check() 0 errors/1 warning+1 note, both
  confirmed pre-existing/unrelated. Updated BACKLOG.md (RESOLVED) and _pkgdown.yml
  (new article registered in the articles: contents: list). Commits: 53bd647a
  (claim) + this close-out commit.
next_steps: The kinship2 supplement full-reproduction plan
  (docs/planning/kinship2-supplement-full-reproduction-plan.md) is now FULLY closed
  out -- all 3 tracks implemented, tested, issue-tracked, and independently
  fidelity-verified against kinship2. No further work is owed on it. Separately,
  2 items carried forward unchanged: (1) the kinship2 supplement PDF
  (inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf) remains
  untracked -- a copyright/licensing decision still owed to the owner. (2) An
  incidental finding this session: _pkgdown.yml's articles: contents: list is
  missing articles/pedigree-diagram (every other article, including this
  session's new one, is listed) -- not fixed (out of scope), logged as a new
  BACKLOG.md Housekeeping item; a future session should confirm whether this
  actually affects the live site's navbar/discoverability before treating it as
  more than cosmetic. BACKLOG.md priorities otherwise unchanged: LabKey (BLOCKED,
  Effort M), NPRC outreach (DECISION NEEDED, Effort N/A), issue #148 (DECISION
  NEEDED -- needs its own scope-narrowing conversation first).
key_files: vignettes/articles/kinship2-fidelity-validation.qmd (the full article);
  data-raw/kinship2FidelityValidation.R (the reproducible generator script, 0
  lints); vignettes/articles/kinship2-fidelity-validation-img/ (8 generated PNGs);
  BACKLOG.md (kinship2 plan tracker item, now RESOLVED); _pkgdown.yml:59 (new
  articles: entry); inst/WORDLIST (4 new words).
gotchas: (1) Quarto reserves the exact directory name "<qmd-basename>_files/" for
  its own knitr output -- a hand-populated directory of that name collides with
  the render-time freezer/copy logic (a WalkError, confirmed hands-on). Name
  hand-populated asset directories something else (this session used "-img"
  suffix, matching pedigree-diagram-screenshots.R's own plain SHOT_DIR
  convention). (2) `x %in% "literal"` and `x == "literal"` BOTH produce NA (not
  FALSE) for an NA left-hand side -- naive `df[cond, ]` indexing on an NA-heavy
  column (e.g. an optional "color" column, NA for every unmarked row) silently
  keeps one all-NA row per NA instead of dropping it, inflating the row count.
  Always guard explicitly: `!is.na(x) & x == "literal"`. Caught this session only
  by re-running and inspecting output after a lintr-suggested %in%->== rewrite,
  not by trusting the fix. (3) kinship2::pedigree()'s dadid=male/momid=female
  validation is STRICTER than nprcgenekeepr's own sire/dam columns (which carry
  no such constraint) -- a committed nprcgenekeepr test fixture may list an
  individual as "sire" in one row despite a different declared sex, and
  kinship2::pedigree() will reject it outright. Swap just that row's 2
  parent-column values for the kinship2-side object only if this recurs; never
  alter the nprcgenekeepr-side fixture itself. (4) fg-se-validation.qmd's own
  creation has ZERO NEWS.Rmd mentions (grep confirms) -- this class of pure
  validation-article deliverable is not NEWS-worthy by established precedent, not
  just by inference; don't add one reflexively.
runtime_smoke: No live shinytest2/chromote app run -- this deliverable is
  script-callable/documentation only (no Shiny UI change). The article's own
  graphics WERE generated via a real chromote screenshot pipeline
  (visNetwork widget -> saved HTML -> chromote screenshot), confirmed working by
  visually inspecting all 8 resulting PNGs before embedding them, and the
  package's own devtools::check() (which runs the full test suite) came back
  0 errors.
changelog_ref: CHANGELOG.md, S566 entries (claim + close-out, both [BL-N]-tagged)
commit: d0390201
```
<Full close-out receipt. See SESSION_NOTES.md's own Session 566 entry for the
complete narrative and self-assessment breakdown -- this block is the durable,
machine-checkable summary of the same session.>

```handoff
session: S565
date: 2026-08-14
status: complete
self_score: 8
predecessor_score: 9
active_task: Track B of the ratified kinship2 supplement full-reproduction plan --
  DONE. shrinkPedigree() ported. All 3 tracks of the plan are now complete
  (C: S563, A: S564, B: S565).
what_was_done: Full PRE-RED->RED->GREEN TDD cycle (REFACTOR skipped, owner choice),
  each transition AskUserQuestion-gated. PRE-RED deparsed all 8 of kinship2's own
  internal helpers directly from the installed namespace (1.9.6.2), including the 2
  the plan itself flagged as undeparsed -- found 5 things beyond the plan's own
  framing (4 at PRE-RED, 1 more mid-GREEN): excludeStrayMarryin ignores genotyped
  entirely; excludeUnavailFounders requires exactly-one-child AND neither-parent-
  remarried; NA affected status counts as unaffected; a single-known-parent
  individual crashes a literal port (kinship2's own pedigree() forbids that input
  shape, this package's data model doesn't) -- handled conservatively instead,
  documented, tested; and kinship2's own idTrimmed/idList$affect silently omit
  cascade-removed ids in the affected-priority tier (confirmed live via a dedicated
  fixture) -- shrinkPedigree() deliberately fixes this bookkeeping gap.
  PROJECT_LEARNINGS.md Learnings 571/572 logged. RED: 14 new test_that() blocks (20
  expectation markers) in new tests/testthat/test_shrinkPedigree.R, every hardcoded
  expected value independently verified live against installed kinship2, not
  hand-derived; 1 more test added mid-GREEN after finding 5 surfaced. GREEN: new
  R/shrinkPedigree.R (8 functions); first test run caught a test-transcription bug
  (missing affected arg), not an implementation bug -- fixed, all 20 markers pass.
  Verified: full clean regression 1 pre-existing failure (test_wordlist_coverage.R,
  confirmed via git stash unrelated); lintr::lint_package() 0 lints (stripped an
  initial round of unneeded nolint comments that were themselves causing new
  line_length findings); devtools::check() 2 cycles to 0 errors/1 pre-existing
  warning/1 pre-existing note -- 1st cycle found and fixed 2 real gaps
  (_pkgdown.yml reference-coverage missing the new export; a new spelling flag,
  "orchestrator", fixed via inst/WORDLIST). Commits: c1c54cb7 (claim) + this
  close-out commit.
next_steps: All 3 tracks of the kinship2 supplement full-reproduction plan
  (docs/planning/kinship2-supplement-full-reproduction-plan.md) are now DONE.
  None of the 3 has a GitHub issue yet (matches the established "recommend, don't
  unilaterally file" precedent) -- the owner may want to file one (or three)
  retroactively, or decide it's not worth it now that the work is complete.
  Separately, 2 unresolved open items carried forward unchanged from S564: (1)
  inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf (the kinship2
  supplement PDF itself) remains untracked -- a possible copyright/licensing
  question the owner should decide (commit it, gitignore it, or leave local-only).
  (2) shrinkPedigree() (and kinship()'s new chrtype/sex params from Track A) are
  exactly the trigger case for a future a2interactive.Rmd documentation pass
  (deferred by design, per that checklist's own standing rule -- not overdue yet).
  BACKLOG.md priorities otherwise unchanged: LabKey (BLOCKED, Effort M), NPRC
  outreach (DECISION NEEDED, Effort N/A), issue #148 (DECISION NEEDED -- needs its
  own scope-narrowing conversation first).
key_files: R/shrinkPedigree.R (the full Track B implementation -- shrinkPedigree()
  plus 7 internal helpers, extensively documented in its own roxygen); tests/
  testthat/test_shrinkPedigree.R (14 test_that() blocks, 20 expectation markers);
  _pkgdown.yml (shrinkPedigree added to 2 reference groups); inst/WORDLIST
  ("orchestrator" added); NEWS.Rmd (new entry); BACKLOG.md (kinship2 plan tracker,
  Track B annotated DONE, all 3 tracks complete); PROJECT_LEARNINGS.md Learnings
  571-572; docs/planning/kinship2-supplement-full-reproduction-plan.md §4 (the
  spec this session implemented, now fully closed out).
gotchas: (1) kinship2's own findAvailAffected()'s trial-removal loop calls the FULL
  findUnavailable() cascade for each candidate, not a single-row removal --
  measuring bitSize after a candidate's removal means measuring after any
  stray-marryin/childless-non-founder cascade too, not just the candidate alone.
  (2) A test fixture transcribed from a live Pre-RED scratch-verification script
  must carry over EVERY argument used in that verification, not just the ped/
  genotyped shape -- an omitted optional argument with its own non-trivial default
  (affected here) silently changes which code path fires (Learning 572). (3) This
  project's .lintr already allows camelCase (object_name_linter styles =
  snake_case/CamelCase/camelCase) -- do not reflexively add
  `# nolint: object_name_linter` comments by pattern-matching an older file; verify
  the lint actually fires first, since an unneeded nolint comment can itself push a
  line over the 80-char limit and create a NEW finding. (4) cyclocomp_linter is
  explicitly disabled in this project's .lintr (`cyclocomp_linter = NULL`) --
  referencing it in a nolint comment produces a "could not find linter" warning,
  not a suppression. (5) The `&`/`disown` double-backgrounding trap (S563's own
  finding, restated in S564's handoff) still caught this session once -- prefer
  `run_in_background: true` alone, or a Monitor with an explicit completion-check
  loop, never manual `&`/`disown`.
runtime_smoke: No live shinytest2/chromote run this session -- Track B is
  script-callable only (ratified D-B3, no Shiny tab), so there is no runtime/UI
  wiring to smoke-test. Behavior was verified by direct execution instead:
  devtools::check()'s own testthat run exercises every new code path against the
  new test fixtures, and every hardcoded expected value was independently
  cross-validated live against the installed kinship2::pedigree.shrink().
changelog_ref: CHANGELOG.md, S565 entries (claim + close-out, both `[BL-N]`-tagged)
commit: f68a24ff
```

```handoff
session: S564
date: 2026-08-13
status: complete
self_score: 8
predecessor_score: 8
active_task: Track A of the ratified kinship2 supplement full-reproduction plan --
  DONE. kinship() gained chrtype = c("autosome", "x") and sex arguments; Track B
  (a pedigree.shrink() equivalent) remains open.
what_was_done: Full PRE-RED->RED->GREEN TDD cycle (REFACTOR skipped, owner choice),
  each transition AskUserQuestion-gated. PRE-RED transcribed the PDF's full 10x10
  Table S2 via pdftotext -layout and cross-validated it by hand-porting kinship2's
  own X-linked algorithm, run live against the installed kinship2 1.9.6.2 --
  discovered Table S2's own printed values already embed the MZ-twin correction
  (Figure S1's subjects 8/9 are twins), so one fixture satisfies both "reproduce
  Table S2" and the plan's separately-listed "combined X-linked+MZ-twin" coverage
  requirement. RED: 6 new test_that() blocks in tests/testthat/test_kinship.R,
  caught and fixed one vacuous-pass assertion before confirming all 6 fail for the
  right reason. GREEN: new chrtype/sex params, an X-linked depth-loop branch reusing
  the existing MZ-twin mzgrp/mzindex correction unchanged; chrtype="autosome"
  (default) left byte-for-byte untouched, pinned by expect_identical(). Verified:
  targeted tests pass; full clean regression 1 pre-existing failure
  (test_wordlist_coverage.R, confirmed via git stash); lintr::lint_package() 2 new
  lints suppressed via documented # nolint (5 pre-existing left untouched);
  devtools::check() needed 4 cycles to reach 0 errors/1 pre-existing warning/1
  pre-existing note (a real codoc mismatch from a stale man/kinship.Rd, a broken
  \\link{sexCodes} cross-reference, and 2 new spelling flags were each found and
  fixed along the way -- PROJECT_LEARNINGS.md Learning 570 logged on the
  check()/document() sync gap this exposed). Commits: bfd9532f (claim) + this
  close-out commit.
next_steps: Pick up Track B (a pedigree.shrink() equivalent, new shrinkPedigree(),
  Effort L, most novel of the 3 -- its own Pre-RED must first deparse kinship2's
  excludeUnavailFounders/excludeStrayMarryin helpers, not yet done) --
  docs/planning/kinship2-supplement-full-reproduction-plan.md §4. Separate session
  (different capability, never bundled per SESSION_RUNNER.md's vertical-slice rule).
  Neither Track A nor B has a GitHub issue yet -- the owner may wish to file for
  both before further implementation. Separately: an unresolved open item from this
  session -- inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf (the
  kinship2 supplement PDF itself) remains untracked; a possible copyright/licensing
  question the owner should decide (commit it, gitignore it, or leave local-only)
  before more documentation accumulates assuming one answer. BACKLOG.md priorities
  otherwise unchanged: LabKey (BLOCKED, Effort M), NPRC outreach (DECISION NEEDED,
  Effort N/A), issue #148 (DECISION NEEDED -- needs its own scope-narrowing
  conversation first).
key_files: R/kinship.R:79-193 (kinship(), the full Track A diff -- chrtype/sex
  params, X-linked branch, roxygen docs); tests/testthat/test_kinship.R:31-95 (fam1
  fixture + gen column, and the 6 new Track A test_that() blocks); man/kinship.Rd
  (regenerated); NEWS.Rmd (new entry); inst/WORDLIST (2 new proper-noun entries);
  BACKLOG.md (kinship2 plan tracker, Track A annotated DONE); PROJECT_LEARNINGS.md
  Learning 570 (the check()/document() sync gap); docs/planning/kinship2-supplement-
  full-reproduction-plan.md §4 (Track B, the next pickup).
gotchas: (1) Always run devtools::document() manually immediately before every
  devtools::check() launch -- check()'s own man/*.Rd regeneration is not reliably
  synced to a pre-launch document() call (Learning 570); a codoc-mismatch or
  Rd-cross-reference WARNING may just mean "document() wasn't re-run after the last
  edit," not a genuine defect. (2) Do not launch a long-running check() and then
  keep editing roxygen/NEWS.Rmd "while waiting" -- assume any such run is now
  unreliable and re-run after document(). (3) Track B's own Pre-RED must deparse
  excludeUnavailFounders/excludeStrayMarryin before writing RED tests -- still not
  done. (4) Track B naming: use `genotyped`, never `avail`/`available` (collides
  with R/makeAvailable.R's own unrelated breeding-group concept). (5) The
  double-backgrounding pitfall (an `&`-suffixed command inside or alongside a
  run_in_background:true Bash call produces a premature "completed" notification
  while the R process keeps running detached) recurred twice this session despite
  being a documented S563 finding -- prefer run_in_background:true alone, or a
  Monitor with an explicit grep-for-completion-marker loop, never `&`/`disown`.
runtime_smoke: No live shinytest2/chromote run this session -- Track A is
  script-callable only (ratified D-A2 Option A explicitly excludes the Shiny app),
  so there is no runtime/UI wiring to smoke-test. Behavior was verified by direct
  execution instead: devtools::check()'s own testthat run (145s) exercises every
  new code path against the new test fixtures, not merely a build-passes check.
changelog_ref: CHANGELOG.md "S564: close out (Track A of kinship2 supplement
  full-reproduction plan DONE)"
commit: 7bbc6273
```

```handoff
session: S563
date: 2026-08-13
status: complete
self_score: 9
predecessor_score: 7
active_task: Implement Track C of the ratified kinship2 supplement
full-reproduction plan (docs/planning/kinship2-supplement-full-reproduction-plan.md
§5) -- edgeStyle="rectilinear" consanguineous-marker color/width propagation onto D2
dogleg-rerouted projection edges, R/makePedigreeDiagramData.R
.addRectilinearWaypoints(). DONE.
what_was_done: Full PRE-RED->RED->GREEN TDD cycle (REFACTOR skipped, owner choice --
diff already minimal), each transition AskUserQuestion-gated. PRE-RED found the
plan's referenced "12-row fixture" was never committed as code; read
.buildMatingUnitForest()'s anchor-selection algorithm directly from source and built
an independently-verified 9-row equivalent on the first attempt (Learning 569). RED:
1 new test_that() block (5 assertions) in
tests/testthat/test_makePedigreeMatingLayout.R, confirmed failing for the right
reason against unmodified source. GREEN: R/makePedigreeDiagramData.R's D2 loop now
looks up a dropped mate edge's color/width (keyed by the dogleg's projId) and applies
it as a post-hoc override after the existing generic-fallback assignment (required by
do.call(rbind, newEdgeList)'s column-alignment constraint across D1/D2 edge types --
a structural wrinkle the plan itself did not anticipate). Verified: targeted +
sibling test files all pass; full clean regression 1 pre-existing failure
(test_wordlist_coverage.R, confirmed via git stash unrelated to this diff);
lintr::lint_package() 0 lints on touched files; devtools::check() 0 errors, 1
warning + 1 note, both confirmed pre-existing/unrelated (untracked "Compounding
Loop" files' non-portable names; a pre-existing vignettes/figure/ knitr leftover).
Close-out: BACKLOG.md's S555 deferred-follow-up item annotated FIXED S563;
kinship2 plan's Track C clause annotated DONE S563 (Tracks A/B remain open);
NEWS.Rmd entry added; PROJECT_LEARNINGS.md Learning 569 logged. Commits: 91c78152
(claim) + this close-out commit.
next_steps: Pick up Track A (X-chromosome kinship, kinship() gains chrtype/sex,
Effort M) or Track B (a pedigree.shrink() equivalent, new shrinkPedigree(),
Effort L, most novel -- its own Pre-RED must first deparse kinship2's
excludeUnavailFounders/excludeStrayMarryin helpers, not yet done) --
docs/planning/kinship2-supplement-full-reproduction-plan.md §3/§4. Each is its own
separate implementation session (different capability, never bundled with the
other per SESSION_RUNNER.md's vertical-slice rule). None of the 3 tracks has a
GitHub issue yet -- the owner may wish to file 3 before further implementation.
Separately: a stale BACKLOG.md tag was found this session (the "ledger-size
housekeeping" item, S518, still says READY/Effort L in its header though its body
says fully RESOLVED since S531) -- a 1-line tag cleanup, not urgent. BACKLOG.md
priorities otherwise unchanged: LabKey (BLOCKED, Effort M), NPRC outreach
(DECISION NEEDED, Effort N/A), issue #148 (DECISION NEEDED -- needs its own
scope-narrowing conversation first, surfaced via the ratified sequencing audit's
own prose order, not an inline tag).
key_files: R/makePedigreeDiagramData.R:1499-1622 (.addRectilinearWaypoints(), the
D2 loop + post-hoc override, this session's entire production diff);
tests/testthat/test_makePedigreeMatingLayout.R:1043-1120 (the new Track C test
block); docs/planning/kinship2-supplement-full-reproduction-plan.md §3/§4 (Tracks
A/B, the next pickups); PROJECT_LEARNINGS.md Learning 569 (the anchor-selection
algorithm, reusable for any future D2-dogleg-targeting fixture); BACKLOG.md (the
S555 deferred-follow-up item and the kinship2 plan item, both annotated this
session).
gotchas: (1) do.call(rbind, newEdgeList) requires matching columns across every
entry -- D1's sibship-bar/chain edges have no color/width columns of their own, so
any future edit to this function that wants per-edge color/width must either add
those columns to ALL newEdgeList entries or use the post-hoc-override pattern this
session established (projColor/projWidth keyed by a unique id, applied after the
blanket fallback assignment) -- do not attempt to set color/width directly inside
the D2 loop's own data.frame() call, it will be silently clobbered by the later
blanket assignment. (2) Track B's own Pre-RED must deparse
excludeUnavailFounders/excludeStrayMarryin before writing RED tests -- still not
done. (3) Track B naming: use `genotyped`, never `avail`/`available` (collides
with R/makeAvailable.R's own unrelated breeding-group concept). (4) Track A's
X-linked branch must apply the existing MZ-twin mzgrp/mzindex correction inside
the new chrtype="x" loop too.
runtime_smoke: No live shinytest2/chromote run this session -- judged sufficient
per the plan's own §5.3 allowance ("a rendering-detail fix, not a new interaction
pattern"): the new unit test directly asserts on the exact edges data.frame
makePedigreeMatingLayout() returns, the same structure R/modPedigree.R's
visNetwork::renderVisNetwork() consumes for rendering -- a static review of the
actual returned data, not merely a build-passes check. Stated explicitly, not
silently skipped.
changelog_ref: this session's own CHANGELOG.md entries, 2026-08-13 (claim; this
close-out entry)
commit: 89be00ca
```

```handoff
session: S562
date: 2026-08-13
status: complete
self_score: 8
predecessor_score: 9
active_task: Write a plan document to fully reproduce
inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf's results with
nprcgenekeepr -- DONE, RATIFIED.
what_was_done: Wrote docs/planning/kinship2-supplement-full-reproduction-plan.md
(~600 lines), following the S550 twin-kinship plan's own structure/evidence
standard. 3 independently session-sliceable tracks: Track A (X-chromosome kinship,
kinship() gains chrtype/sex, core-algorithm-only per ratified scope); Track B (a
new shrinkPedigree() function porting kinship2's own 5-helper pedigree.shrink()
algorithm, script-callable only, deterministic tie-break -- the most novel track,
with 2 kinship2 sub-helpers left as an explicit Pre-RED item); Track C (finish the
edgeStyle="rectilinear" consanguineous-marker color/width propagation, smallest,
no open design question). Deparsed kinship2's own installed namespace directly for
both new capabilities (kinship.default's chrtype="x" branch; pedigree.shrink's
full helper chain). Found 2 real traps: the `available`/`avail` naming collision
with R/makeAvailable.R's unrelated breeding-group concept, and the MZ-twin
correction's interaction with the new X-linked branch. Ratified 4 judgment calls
via one AskUserQuestion call (owner picked this plan's own recommended option in
all 4 cases). Added a BACKLOG.md Housekeeping pointer item. Logged
PROJECT_LEARNINGS.md Learning 568 (the session's own scope-arc/mid-turn-
interruption-misreading process learning). Commits: 749d0530 (claim) + this
close-out commit.
next_steps: Implement one track (Track C recommended first -- smallest, no open
design question, fixture already built: R/makePedigreeDiagramData.R's
.addRectilinearWaypoints() D2 loop, ~2-line fix). Track A next (X-chromosome
kinship -- moderate, well-precedented signature extension to kinship()). Track B
last (pedigree.shrink() equivalent -- most novel; its own Pre-RED must first
deparse kinship2's excludeUnavailFounders/excludeStrayMarryin helpers, not yet
read this session). Each track is its own separate implementation session (never
bundled -- 3 different capabilities per SESSION_RUNNER.md's vertical-slice rule).
None of the 3 tracks has a GitHub issue yet -- the owner may wish to file 3 before
implementation begins. BACKLOG.md priorities otherwise unchanged from S561: LabKey
(BLOCKED, Effort M), NPRC outreach (DECISION NEEDED, Effort N/A).
key_files: docs/planning/kinship2-supplement-full-reproduction-plan.md (the
deliverable, all sections); R/makePedigreeDiagramData.R:1489-1531 (Track C's exact
gap, .addRectilinearWaypoints() D2 loop); R/kinship.R:79-171 (Track A's extension
point); R/trimPedigree.R, R/removeUninformativeFounders.R (confirmed NOT reused by
Track B -- a different problem); R/columnSchema.R:23 (affected column, reusable by
Track B); R/makeAvailable.R (the naming-collision trap Track B's own D-B1 avoids);
docs/planning/twin-relations-kinship-computation-plan.md (S550, the structural
precedent this plan followed); docs/audits/
KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md (S549, the triggering
audit); BACKLOG.md Housekeeping (the new pointer item, inserted directly after the
existing deferred edgeStyle="rectilinear" note).
gotchas: (1) Track B's own Pre-RED must deparse
excludeUnavailFounders/excludeStrayMarryin (kinship2::getFromNamespace(...)) before
writing RED tests -- not done this session, explicitly flagged as an open item, not
assumed. (2) Track B's naming: use `genotyped`, never `avail`/`available` -- the
latter collides with R/makeAvailable.R's own unrelated breeding-group-candidate-pool
concept already in this package's public vocabulary. (3) Track A's X-linked branch
must apply the existing MZ-twin mzgrp/mzindex correction inside the new chrtype="x"
loop too (kinship2 itself does this) -- omitting it would silently regress
twin-kinship parity for any pedigree with both a declared MZ pair and an X-linked
kinship request. (4) Track B cannot be verified against the PDF's own printed
numbers at any reachable scale (only Tracks A/C can) -- verify against installed
kinship2::pedigree.shrink() directly instead, on a self-constructed fixture. (5) The
plan's own AST call-site counts for kinship() (inherited context from the S550 plan)
predate this session and should be re-counted at Track A implementation time, not
trusted as still-current.
runtime_smoke: n/a -- docs-only planning session, no R/ package code changed,
nothing to launch. Stated explicitly, not silently skipped.
changelog_ref: this session's own CHANGELOG.md entries, 2026-08-13 (claim; this
close-out entry)
commit: 0ce5ac60
```

```handoff
session: S561
date: 2026-08-13
status: complete
self_score: 9
predecessor_score: 9
active_task: Resolve HANDOFFS.md's recurring FRONTMATTER_FIELD_ABSENT finding (BACKLOG.md
Housekeeping, found S508, re-surfaced S559) -- add a self-updating "This file currently holds
**N** receipt(s)" sentence to HANDOFFS.md's front matter -- DONE.
what_was_done: Added "This file currently holds **3** receipt(s). Computed by
methodology_trim.py on every --check/--write run, never hand-maintained." to HANDOFFS.md's
front matter, right after the last "Archived N record(s)..." pointer block. Owner picked this
remedy (over removing the regenerated config entry) via AskUserQuestion. Verified via a direct
unit-check (imported methodology_trim's own LEDGERS["HANDOFFS.md"].regenerated[0] regex,
confirmed it matches and extracts the correct value) and a dry-run --cut @<sha> (no --write)
confirming the live record parser counts exactly 3, matching the sentence -- the live archive
trigger doesn't fire this session, so a real --write couldn't be used to verify directly.
Found and corrected a stale claim in the process: methodology_trim.py's --check path returns
before ever reaching apply_regenerated() (only a real --write that builds an archive plan
does), contradicting the original S508 finding's "every check/write run" framing -- logged as
PROJECT_LEARNINGS.md Learning 567 and corrected in the BACKLOG.md item's own resolved-item
text. Commit e2d051fe (claim) + this close-out commit.
next_steps: BACKLOG.md priorities, in order: (1) Fix edgeStyle="rectilinear" consanguineous-
marker color/width propagation on dogleg-rerouted edges (found S555 -- a verified 12-row
reproduction fixture already exists; S560's own handoff called this "READY, Effort S" but
BACKLOG.md's own inline text for the item carries no matching tag -- add the tag when picking
this up, or as its own tiny fix first). (2) Issue #148 (MHC haplotype frequency reporting)
needs a scope-narrowing conversation before implementation, per the ratified genetic-metrics
sequencing audit (DECISION NEEDED). Unchanged: NPRC outreach owner review (DECISION NEEDED);
LabKey remaining recs (BLOCKED); the scheduled shinytest2.yaml CI run is still red, unchanged
since S548, still not diagnosed by any session. Local master remains ahead of origin (45+
commits after this session) -- a future session should consider pushing.
key_files: HANDOFFS.md:127-131 (the new front-matter sentence); methodology_trim.py:196-221
(the LEDGERS["HANDOFFS.md"] regenerated-field regex this sentence must match);
BACKLOG.md:70-90 (item annotated RESOLVED); PROJECT_LEARNINGS.md (new Learning 567);
CLAUDE.md:282 (learnings-count pointer).
gotchas: (1) methodology_trim.py's --check path structurally cannot reach apply_regenerated()
-- it returns at line ~1610, before the archive-plan-building code (~1660+) that calls it at
line 1707. Don't expect a --check run to surface or clear a FRONTMATTER_FIELD_ABSENT finding;
only a real --write with the trigger firing (or an explicit --cut) does. (2) A digit --cut
falls back to the archived span's max date for the shard filename, which collides with an
already-existing same-day shard (SHARD_EXISTS) -- use a non-digit --cut (a date, or @<ref>) to
pick a distinct dry-run shard name when probing this code path safely. (3) Count "retained"
receipts AFTER writing the Phase 1B claim stub, not before -- the stub is itself a live receipt
the moment it's committed; this session wrote N=2 first and had to correct it to 3.
runtime_smoke: n/a -- docs/config-only change (a front-matter sentence + a Python tool's
LEDGERS config was only READ, not modified); no R package or Shiny code touched.
changelog_ref: this session's 2 CHANGELOG.md entries (claim, close-out) dated 2026-08-13
commit: pending
```
<free-text: Strengths (1) traced methodology_trim.py's actual control flow rather than trusting
a 3-session-old prose characterization of its behavior, catching and correcting a stale claim
in the process; (2) caught its own N=2-vs-3 counting mistake by checking against the tool's own
record parser rather than trusting a hand computation; (3) verified a fix that couldn't be
exercised live (trigger doesn't fire) via two independent indirect methods instead of shipping
it unverified; (4) stayed narrowly scoped to the one decision, explicitly deferring the
tempting adjacent edgeStyle="rectilinear" tag-gap fix to a future session.
Weaknesses (1) the ordering mistake that produced the initial wrong N=2 (should have counted
receipts after, not before, writing the claim stub); (2) no second-agent adversarial
verification, though the diff is small (3 lines) and low-risk; (3) 45+ local commits still
unpushed, deferred again.
**Predecessor (S560) score: 9/10** -- see the Session 560 Handoff Evaluation in
SESSION_NOTES.md for the full breakdown; its next_steps field named this exact item verbatim as
item 2 of its priority list, followed as the literal picked option.>

```handoff
session: S560
date: 2026-08-13
status: complete
self_score: 9
predecessor_score: 9
active_task: Write vignettes/articles/pedigree-diagram.qmd (new dedicated Pedigree Diagram
tab article, incl. freshly-captured live-app screenshots via shinytest2) -- BACKLOG.md
Housekeeping, found S544 -- DONE.
what_was_done: Wrote vignettes/articles/pedigree-diagram.qmd (9 sections: Overview, Node
shapes/legend, Diagram Edge Style, Consanguineous marker, Affected-status shading, Showing
names, Twin/zygosity relations, Interacting with the diagram, Script-callable equivalent, See
also) plus vignettes/articles/pedigree-diagram-screenshots.R (a new shinytest2::AppDriver
screenshot script, 5 screenshots against small feature-relevant subgraphs trimmed from the
bundled obfuscated_rhesus_mhc_ped*.csv fixtures). Regenerated pb_diagram_legend.png in place
and fixed colony-manager-guide.qmd's stale pre-Option-2 "one node per animal... directed
sire/dam edges" opening sentence + added the new article to its function-group table.
Updated a2interactive.Rmd's own cross-reference to point to the new article. quarto render
clean on both .qmd files; targeted rmarkdown::render() on a2interactive.Rmd (the one real,
non-ignored vignette touched) confirmed clean; lintr::lint_package() 0 lints.
next_steps: BACKLOG.md priorities, in order: (1) Fix edgeStyle="rectilinear" consanguineous-
marker color/width propagation on dogleg-rerouted edges (READY, Effort S, found S555 -- a
verified 12-row reproduction fixture already exists). (2) Decide add-vs-remove for
HANDOFFS.md's FRONTMATTER_FIELD_ABSENT finding (DECISION NEEDED, Effort S, first seen S508).
(3) Issue #148 (MHC haplotype frequency reporting) needs a scope-narrowing conversation
before implementation, per the ratified genetic-metrics sequencing audit (DECISION NEEDED).
Unchanged: NPRC outreach owner review (DECISION NEEDED); LabKey remaining recs (BLOCKED); the
scheduled shinytest2.yaml CI run is still red, unchanged since S548, still not diagnosed by
any session. Local master remains ahead of origin (44+ commits after this session) -- a
future session should consider pushing.
key_files: vignettes/articles/pedigree-diagram.qmd (new article); vignettes/articles/
pedigree-diagram-screenshots.R (new screenshot script); vignettes/articles/shiny_app_use/
pb_diagram_legend.png (regenerated) + diagram_rectilinear_edge_style.png/
diagram_show_names.png/diagram_affected_shading.png/diagram_twin_connectors.png (new);
vignettes/articles/colony-manager-guide.qmd (Diagram-view paragraph fixed, table row 2
updated); vignettes/a2interactive.Rmd (cross-reference updated); BACKLOG.md Housekeeping (2
items resolved, compressed); PROJECT_LEARNINGS.md (new Learning 566); CLAUDE.md:282
(learnings-count pointer).
gotchas: (1) A live-app screenshot of a full 375-animal bundled fixture is functionally
correct but visually illegible -- trim to a small (3-7 animal) feature-relevant subgraph via
the Diagram tab's own Focal Animals + Trim Pedigree controls BEFORE capturing (Learning 566).
(2) The consanguineous-marker color CANNOT be shown in a close-up/zoomed screenshot when the
marked edge's own endpoint node radius exceeds its world-space length -- confirmed via direct
network.getPositions()/canvasToDOM() JS queries against the live visNetwork widget, not a
screenshot-technique failure; describe it in prose instead of chasing a zoom fix (Learning
566). (3) Quarto crossref syntax `[text](@sec-x)` (markdown-link-wrapped) does NOT resolve --
only bare `@sec-x` or `(@sec-x)` do, and even those render as "(Section N)" against
UN-numbered headings in this project's own quarto config, which is why this article uses
plain prose section-name pointers throughout instead, matching every sibling article's own
convention (none of which use quarto crossrefs at all).
runtime_smoke: n/a -- pure documentation (a new article + a screenshot-generation script
under vignettes/articles/, fully build-ignored via .Rbuildignore); no R/ package code
changed, no runtime/Shiny behavior surface to launch or observe. Stated explicitly, not
silently skipped.
changelog_ref: this session's own CHANGELOG.md entries, 2026-08-13 (reconcile, claim,
deliverable, close-out)
commit: pending
```
<**Self-score 9/10.** +: (1) read all 3 existing coverage surfaces
(`_pedigree_browser.Rmd`, `colony-manager-guide.qmd`, `a2interactive.Rmd`) before writing,
catching `colony-manager-guide.qmd`'s own stale pre-Option-2 opening sentence directly.
(2) did not accept the first illegible screenshot pass as good enough -- iterated to a
concrete fix (trim to a feature-relevant focal set via the app's own existing controls).
(3) when a specific screenshot (the consanguineous-marker close-up) genuinely could not work,
verified WHY via direct JS/canvas-position queries rather than guessing, then described the
limitation honestly in prose instead of shipping a misleading image. (4) verified with the
actual build tool (`quarto render`) rather than eyeballing markdown, catching 2 real defects
(broken crossref syntax, a fabricated vignette title) before they shipped. (5) confirmed the
actual build-ignore/lint scope (`.Rbuildignore`, `.lintr`) rather than assuming close-out
checklist triggers applied broadly. -: (1) the first full-fixture screenshot pass was a
predictable, avoidable mistake -- `a2interactive.Rmd`'s own prose, read earlier the same
session, already explained why a dense real fixture doesn't demonstrate features legibly.
(2) no independent adversarial-verification pass beyond this session's own manual review --
the same standing gap flagged across many prior sessions. (3) did not push the now 44+ local
commits to `origin`, matching the repeatedly-deferred precedent from S548 onward.
**Predecessor (S559) score: 9/10** -- see the Session 559 Handoff Evaluation in
SESSION_NOTES.md for the full breakdown; its `next_steps` field named this exact item
verbatim as item 1 of its priority list, followed as the literal picked option.>

```handoff
session: S559
date: 2026-08-13
status: complete
self_score: 8
predecessor_score: 9
active_task: Archive SESSION_NOTES.md (past the 2,000-line agent read cap, dashboard HIGH risk,
unresolved since S555) via methodology_trim.py; also checked and archived HANDOFFS.md
(dashboard MEDIUM risk) and, once its own byte trigger fired as a direct side effect,
CHANGELOG.md too -- DONE, all 3 ledgers archived and verified.
what_was_done: Ran methodology_trim.py --write against SESSION_NOTES.md, HANDOFFS.md, and
CHANGELOG.md. First attempt chained all 3 --write calls without committing between them,
which broke CHANGELOG.md's own generated verify.sh (compared against a stale HEAD, 2
entries behind) -- not real data loss (the tool's own in-process L1/L2/L3 checks, run
against true in-memory content, had already passed), but an invalid comparison. Recovered
via a precise surgical unwind of just the premature CHANGELOG.md trim, then re-ran all 3 as
separate write-verify-commit cycles per the tool's own advertised discipline. Final commits:
4c7f8415 (claim), 8e586478 (SESSION_NOTES.md: 2,432->339 lines, 208,194->27,604 B), 306a4b4d
(HANDOFFS.md: 109,667->9,200 B), ec76e487 (CHANGELOG.md: 67,414->33,924 B). All 3 shards'
verify.sh scripts pass cleanly against real committed HEAD. Also fixed S558's own HANDOFFS.md
receipt commit: pending -> cafd7d49 before archiving it (documented reconcile exception).
Logged PROJECT_LEARNINGS.md Learning 565 (the chained-trim/verify.sh interaction) and a new
BACKLOG.md Housekeeping item (HANDOFFS.md's recurring FRONTMATTER_FIELD_ABSENT finding,
first seen S508, needs an explicit add-vs-remove decision). Updated CLAUDE.md's stale
"Sessions 1-504+; 503 learnings" pointer to the current count.
next_steps: BACKLOG.md priorities, in order: (1) Write the dedicated Pedigree Diagram tab
article (READY, Effort M, unchanged since S544). (2) Fix edgeStyle="rectilinear"
consanguineous-marker color/width propagation on dogleg-rerouted edges (READY, Effort S,
found S555 -- a verified 12-row reproduction fixture already exists). (3) Decide add-vs-
remove for HANDOFFS.md's FRONTMATTER_FIELD_ABSENT finding (new this session, DECISION
NEEDED, Effort S). (4) Issue #148 (MHC haplotype frequency reporting) needs a
scope-narrowing conversation before implementation, per the ratified genetic-metrics
sequencing audit. Unchanged: NPRC outreach owner review (DECISION NEEDED); LabKey remaining
recs (BLOCKED); the scheduled shinytest2.yaml CI run is still red, unchanged from
S544-S559's own findings, still not diagnosed by any session. Local master remains ahead of
origin (38+ commits after this session) -- a future session should consider pushing.
key_files: BACKLOG.md Housekeeping (new HANDOFFS.md front-matter-field item);
PROJECT_LEARNINGS.md (new Learning 565); CLAUDE.md:282 (learnings-count pointer);
docs/archive/SESSION_NOTES-through-2026-08-13.md, docs/archive/HANDOFFS-through-2026-08-13.md,
docs/archive/CHANGELOG-through-2026-08-13.md (the 3 new shards, each with its own .verify.sh).
No R/ or tests/ files touched this session (pure ledger/documentation housekeeping).
gotchas: (1) methodology_trim.py's generated verify.sh validates an uncommitted --write
against HEAD -- if a session's deliverable is archiving MULTIPLE ledger files in one
sitting, commit each file's own --write (and run its verify.sh) BEFORE running --write
against the next file, exactly as the tool's own printed output says ("one ledger, one
shard, one entry, one commit, one revert"). CHANGELOG.md is the one most likely to break
this way, since every OTHER ledger's own trim writes an entry into it as a side effect. See
PROJECT_LEARNINGS.md Learning 565 for the full recovery methodology if this is hit anyway.
(2) A ledger's own byte trigger can fire as a side effect of another ledger's trim entries
landing in it -- re-run --check on CHANGELOG.md after archiving any other ledger, even if
it wasn't part of the original plan. (3) HANDOFFS.md's declared "retained receipt count"
regenerated front-matter field has no matching sentence in the file's actual front matter
(a real, non-blocking, recurring FRONTMATTER_FIELD_ABSENT finding since S508) -- don't
mistake it for a new defect; it's tracked in BACKLOG.md Housekeeping now, decision pending.
runtime_smoke: n/a -- pure ledger/documentation housekeeping (archiving 3 ledger files), no
runtime/Shiny behavior surface exists to launch or observe. Stated explicitly, not silently
skipped.
changelog_ref: this session's own CHANGELOG.md entries, 2026-08-13 (claim; 3 ledger-trim
entries auto-written by methodology_trim.py; this close-out entry)
commit: abf1a984
```
<**Self-score 8/10.** +: (1) ran --check before every --write and verified losslessness via
each shard's own generated verify.sh before every commit -- caught the chained-trim defect
itself rather than committing broken state. (2) recovered via a precise, minimal surgical
unwind (removing exactly the erroneous trim's own top-inserted entry and bottom-removed
tail) rather than a blanket revert that would have discarded 2 valid trims' work.
(3) extended scope to CHANGELOG.md's own trigger only because this session's own actions
caused it to fire, without treating that as license for unrelated scope creep. (4) fixed
the S558 receipt's stale commit: pending placeholder using the documented reconcile
exception. (5) surfaced the pre-existing S508-era HANDOFFS.md FRONTMATTER_FIELD_ABSENT
finding as an explicit, trackable BACKLOG.md decision item instead of letting it keep
recurring silently. (6) documented the chained-trim gotcha as PROJECT_LEARNINGS.md
Learning 565. -: (1) the core mistake -- chaining 3 --write calls without committing
between them despite the tool's own printed guidance saying exactly that -- was avoidable
and cost real session time to recover from. (2) no independent adversarial-verification
pass beyond the tool's own internal checks and this session's own manual review -- the same
standing gap S551-S558 have flagged across 7 consecutive sessions, though the risk here is
lower given the tool's own L1/L2/L3 checks are themselves independent verification.
(3) did not push the now 38+ local commits to origin -- left for the owner/a future
session, matching the repeatedly-deferred precedent from S548 onward.
**Predecessor (S558) score: 9/10** -- see the Session 558 Handoff Evaluation in
SESSION_NOTES.md for the full breakdown; its next_steps field named this exact item
verbatim as item 1 of its priority list, followed as the literal first and only
investigative step.>

