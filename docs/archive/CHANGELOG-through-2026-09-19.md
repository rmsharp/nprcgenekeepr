# CHANGELOG.md — archive: 2026-09-18 → 2026-09-19

Retired records from [`CHANGELOG.md`](../../CHANGELOG.md), moved here so the live ledger stays small enough to read
in one pass. Same format, same newest-on-top order — this is the same ledger, continued.

Holds **35 record(s), 2026-09-18 → 2026-09-19**. Cut key: `2026-09-19`. Counts here are computed from the file
itself, never carried forward. This shard is frozen: it states no forward-looking rule,
because the live file owns those and a copy of one was wrong a day after it was written.

---

### 2026-09-19 · [BL] S718 close-out: pointer-block sweep session records — SESSION_NOTES handoff + S717 evaluation (9/10), HANDOFFS receipt complete, ledger triggers verified not firing
- CI note: the 3 workflows in-flight at orientation on the S717 close-out
  head completed green in-session (test-coverage 12m48s, pkgdown 18m36s,
  R-CMD-check 31m32s; lint was already green), plus the scheduled shinytest2
  run green — 5/5; S717's deliberately-unwatched docs-only CI round is
  closed. FM #28 reduction this session = the deliverable itself (444 lines
  out of `BACKLOG.md`, 1,119 → 675); `methodology_trim.py --check` verified
  the SESSION_NOTES/HANDOFFS/CHANGELOG byte triggers all clear at close-out.
  No new learning appended (routine application of the S686 convention, no
  new signal — stated, not silent, per the S711/S712 precedent). No push
  (owner's call, per the standing convention).

### 2026-09-19 · [BL] S718 deliverable: pointer-block sweep RATIFIED and executed — all 15 `[ ]`-marked-but-fully-RESOLVED blocks removed from `BACKLOG.md` (429 lines, 1,119 → 690)
- Owner ratified "remove all 15" via `AskUserQuestion` (over a keep-S457/S458
  variant and a hold), extending the S686 completed-item convention to the
  S529–S531-era population the S687 item flagged. Verification before the
  gate: every resolving session has dated ledger entries in the CHANGELOG
  corpus (live + `docs/archive/CHANGELOG-*` shards; 3–7 headings each;
  **0 FM #27 gaps** — unlike S529's sweep, which found 2); depth spot-checked
  on the densest block (S565 Track B — the shard entry carries all of the
  block's verification detail); no open sub-threads (the S568 block's
  untitled-folder finding already stands as its own item, which stays); zero
  live cross-references from `CLAUDE.md`/`SESSION_NOTES.md`/`HANDOFFS.md`
  into the population.
- Removed (block → resolving sessions): S508-found HANDOFFS front-matter
  field → S561; `genOf` integer-widening fix → S556; repository branch
  cleanup → S557/S558; kinship2-supplement reproducibility audit + PDF
  classification → S549/S567; twinRelations-into-`kinship()` (3 slices) →
  S551–S553; consanguineous-mating marker + rectilinear propagation →
  S555/S563; kinship2-supplement full-reproduction plan + fidelity article +
  issues #156–#158 → S562/S566; Track A X-chromosome kinship → S564; Track B
  `shrinkPedigree()` → S565; affected-status shading fix → S554; stale
  `pb_diagram_legend.png` regeneration → S560; `pedigree-diagram.qmd`
  article → S560; Compounding-Loop tarball exclusion → S568; Option-2
  feasibility pointer → S457; Option-2 design pointer → S458.
- Deletion executed by a guarded line-range script (first/last-line anchors
  verified on every range before writing; diff confirmed deletion-only,
  429 deletions / 0 insertions). Full block text remains recoverable at the
  pre-sweep tree, commit `f058a8de` (`git show f058a8de:BACKLOG.md`). The
  completed sweep item itself (S687) is removed in this same commit per the
  convention. The 18 genuinely-open `[ ]` items are untouched; the
  borderline S518 BACKLOG-compression item was excluded as a
  recurring-maintenance item per its own S606 correction.

### 2026-09-19 · [BL] S718 claim: pointer-block sweep ratification + (if ratified) execution (BACKLOG Housekeeping item, owner-picked via `AskUserQuestion` at Phase 0)
- Docs-only maintenance session, no TDD phases (S686/S687 precedent). Plan:
  inventory the S529–S531-era `[ ]`-marked-but-fully-RESOLVED pointer blocks
  in `BACKLOG.md`, verify each has a complete `CHANGELOG.md` (or archive-shard)
  record, present the concrete population at the ratification gate, then — if
  ratified — apply the S686 4-step relocation (verify/enrich ledger,
  forward-carry live context, extract open sub-threads, delete). Stub +
  pending receipt committed with this entry.

### 2026-09-19 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit `4cfe2dad` — S717's close-out self-reference commit (recorded the records-commit sha in its own `HANDOFFS.md` receipt), the documented recurring 1-commit shape; backfilled by the next session's Phase 0 reconcile

### 2026-09-19 · [ad hoc] S717 close-out: push to `origin/master` DONE — 33 commits (`1788e2b8..047d7f74`), all 4 CI workflows green on the pushed head
- First remote validation of the S715 curved-connector arc-verified
  roundness fix and the S716 MHC display rounding (plus the S712–S714
  census assessments and five sessions of records). CI on `047d7f74`:
  lint 4m41s, test-coverage 10m26s, pkgdown 18m40s, R-CMD-check 34m16s
  (run ids 35425960304/340/312/299), all `completed success` — watched to
  completion in-session via a 2-min poller, then confirmed directly via
  `gh run list`. The records + self-reconcile commits that follow are
  pushed immediately; their own docs-only CI round is verified at the next
  session's unconditional Phase 0 CI check (S706/S711 precedent).

### 2026-09-19 · [ad hoc] S717 claim: owner-directed push to `origin/master` (S716 next-step A, owner-picked via `AskUserQuestion` at Phase 0)
- Process/ops session, no TDD phases (S711 precedent): push the ~33 pending
  commits (S712–S716, incl. real package code — the S715 curved-connector
  fix and the S716 MHC display rounding, both never yet seen by CI), then
  watch all 4 on-push workflows to completion. Claim made BEFORE the push
  so the pushed head carries the session's own breadcrumb. Stub + pending
  receipt committed with this entry.

### 2026-09-19 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit `b229a305` — S716's close-out self-reference commit (recorded the records-commit sha in its own `HANDOFFS.md` receipt), the documented recurring 1-commit shape; backfilled by the next session's Phase 0 reconcile

### 2026-09-18 · [BL] S716 close-out: MHC Haplotype Reporting polish DONE — display-only 4-decimal frequency rounding, `@return` rewritten, NEWS stale-phrase sweep + heading repair, article screenshot re-captured
- **Deliverable (strict TDD for the code part, every gate owner-approved via
  `AskUserQuestion`; BACKLOG item removed in this commit):**
  `output$mhcSummaryTable` (`R/modMarkerGenetics.R:1170`) now renders
  `DT::formatRound(DT::datatable(tbl), "frequency", digits = 4L)` — a
  client-side display renderer gated on `type !== 'display'`, so the
  `mhcHaplotypeSummaryTable` reactive, the CSV export, and DT's own
  sorting/filtering keep full precision. RED `27d06c97` (3 formatter
  grepls failing at HEAD for the right reason + reactive-identity and
  pre-upload pins), GREEN `dbd68126` (3-line edit). REFACTOR judged
  unnecessary at the owner-approved GREEN exit gate.
- **Docs (owner-scoped pre-RED):** `modMarkerGeneticsUI()` `@return`
  rewritten to the real 8-sub-tab UI (`c4fb69f3`, `document()`
  scope-checked); NEWS.Rmd sweep removed all 8 verified-stale "no Shiny
  screen yet" phrases (owner-ratified beyond the 2 the item named; the 2
  accurate ones stay) and repaired 2 pre-existing swallowed section
  headings (`## MHC Haplotype Reporting`, `## Genetic Value Analysis`
  rendered as literal `\##` for want of a preceding blank line); NEWS
  plain-language entry for the rounding (`37d17a55`); colony-manager-guide
  MHC screenshot re-captured live at the original framing (`476372e6`) —
  re-obligated by this session's own display change.
- **Verification:** full clean regression 2,437 blocks 0 failed / 0 error
  (+1 = the new test block; warnings 40 unchanged);
  `lintr::lint_package()` 0; wordlist/moduleContract/pkgdown guards green;
  Phase 3E live smoke: all rendered page-1 frequency cells exactly 4
  decimals, no module console errors; full MHC e2e green under
  `NPRC_RUN_E2E=true` incl. the full-precision CSV download pins;
  `devtools::check()` 0 errors + the known pre-existing 1 W / 1 N
  untracked-file artifacts. Learning 765 appended (DT 0.34.0 formatX
  seam + the NEWS render-diff/`\##` reflex + the e2e opt-in corollary).

### 2026-09-18 · [BL] S716 claim: MHC Haplotype Reporting follow-up polish (BACKLOG Housekeeping item, issue #148 Slice 4 close-out; owner-picked via `AskUserQuestion` at Phase 0)
- Three-part polish, strict TDD for the code part: (1) display-only rounding of
  the `frequency` column in `output$mhcSummaryTable` (`R/modMarkerGenetics.R`;
  the `mhcHaplotypeSummaryTable` reactive and the export stay untouched — tests
  pin those exactly), (2) `modMarkerGeneticsUI()`'s `@return` updated to cover
  the tabs shipped by #148 Slice 4 / #152 / #153, (3) the two stale "no Shiny
  screen yet" `NEWS.Rmd` phrases fixed + `NEWS.md` re-rendered (plain-language
  criterion). Stub + pending receipt committed with this entry.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit `56c705b8` — S715's close-out self-reference commit (recorded the records-commit sha in its own `HANDOFFS.md` receipt), the documented recurring 1-commit shape; backfilled by the next session's Phase 0 reconcile

### 2026-09-18 · [BL] S715 close-out: curved duplicate-connectors FIXED — arc-verified roundness selection ships; cArc 587 → 149 events, 117 → 72 arcs; exemplar + Track C warnings cleared, owner-ratified renders
- **Deliverable (strict TDD, every gate owner-approved via `AskUserQuestion`;
  BACKLOG item removed in this commit):** `.resolveEdgeNodeCollisions()`'s
  curved branch (`R/makePedigreeDiagramData.R`) now scores each connector's
  PAINTED arc for TRUE disc hits — `.curvedCwVia()` (the S714-verified
  vis-network `curvedCW` transcription), `.bezierPointAt()`,
  `.bezierMinDistTo()` (exact cubic solve), `.arcDiscHitCount()` (a
  conservative Lipschitz-bound sampled prefilter keeps the exact solve to
  near-boundary candidates; counts provably unchanged, resolve
  0.21 → 0.95 s instead of +4.4 s unoptimized) — and walks the roundness
  ladder `seq(0.05, 0.60, 0.05)` in preference order (fewest true hits,
  tie → closest to base 0.2, tie → smaller). `curved-heuristic` residuals
  now disclose exactly the arcs no step fully clears. RED `d39c66eb`
  (7 assertions failing for the right reasons, incl. the never-worse
  property the old bump measurably violated), GREEN `704d7c4c`.
- **Verification:** target file + exemplar file green; full clean
  regression 2,436 blocks, 0 failed / 0 error (warnings 48 → 40 = the
  cleared collision warnings); `lintr::lint_package()` 0;
  `devtools::check()` 0 errors + the known pre-existing 1 W / 1 N
  untracked-local-file artifacts; census re-run `69152999` (postfix CSV;
  frozen 2026-09-02 and 2026-09-18 baselines untouched): **cArc
  587 → 149 events, cArcEdges 117 → 72; Track C fully arc-clean; class
  (b) = 6 unchanged**, so the fidelity article's "6 of 237" is NOT
  re-obligated. Test pins re-derived: residuals 56 → 72 (the true
  population, no longer chord false positives), the S690 named pair
  `__dup_1X40V5_1 → 1X40V5` now pins UNCHANGED 0.2 (it was a false
  positive), `__dup_0L5AWR_1 → 0L5AWR` pins cleared-at-0.5 (6 → 0 hits).
- **Exemplar warning pins (owner-ratified at the GREEN gate, per the
  S693 pin's own re-render rule):** linebreeding + half_sib now render
  warning-free (their 4 pinned residuals = 1 chord false positive + 3
  true collisions, all cleared by the ladder);
  `test_examplePedigreeFixtures.R` specs flipped, renders
  `scratchpad/s715_render_{linebreeding,half_sib}_after.png` approved.
- **Incidental (`fa4ec9ad`):** S714's article edit left
  `test_wordlist_coverage.R` failing on `px` (that session touched no
  package files and carried the baseline forward — the carried-baseline
  heuristic has a hole for `.qmd`-fed tests, Learning 764); fixed via
  `inst/WORDLIST` per the S564/S565 precedent. NEWS.Rmd plain-language
  entry + NEWS.md render in `69152999`.
- **Runtime evidence (Phase 3E):** live chromote renders through the
  app's own widget construction (the S712/S714 verified path) — 2
  exemplar full views + Real-375 before/after site crops
  (`scratchpad/s715_render_site_0L5AWR_{before,after}_zoom.png`).

### 2026-09-18 · [BL] S715 claim: curved duplicate-connectors fix — arc-verified roundness selection replacing the blind +0.3 bump
- Session claimed (stub + pending receipt + this entry). Owner picked the
  S714-filed BACKLOG Housekeeping item via the Phase 0 `AskUserQuestion` picker.
  Scope: `.resolveEdgeNodeCollisions()`'s curved branch
  (`R/makePedigreeDiagramData.R`) gains arc-verified roundness selection using
  the census's exact predicates (ported as internal helpers); strict TDD;
  `test_resolveEdgeNodeCollisions.R` pins re-derived; census re-run + full
  suite + lint at verification.
- **Ledger repair (ad hoc, disclosed):** removed a 5-line truncated duplicate
  S713 receipt header (an unclosed ` ```handoff ` fence, no unique content)
  that S714's records commit `8c717ee6` accidentally inserted into
  `HANDOFFS.md` between the S714 prose and the real S713 receipt.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit `0b4d84bb` — S714 close-out self-reference
- S714's final commit recorded its own records-commit sha (`8c717ee6`) into the
  `HANDOFFS.md` receipt after the ledger entry was written — the recurring
  self-reconcile shape (predicted "~1" by the S714 handoff; measured 1).
  Backfilled at Session 715 Phase 0.

### 2026-09-18 · [BL] S714 close-out: curved-chord upper bound REPLACED by the true arc census — 1,668 chord rows were 100% false positives; real population 587 events / 117 arcs; fix item ratified and filed
- **Deliverable (`318c32da`; curved-chord BACKLOG block replaced by the ratified
  fix item in this commit):** the census now measures the arc vis-network
  actually paints. The `curvedCW` via formula was transcribed from the bundled
  `vis-network.min.js` and verified against the LIVE widget via chromote
  (`edgeType.getViaNode()`): max |via(model) − via(live)| = 1.1e-13 px over all
  173 curved edges, per-edge roundness overrides (0.2 / bumped 0.5) confirmed
  applied. Exact point-to-quadratic distances (cubic root solve), no sampling.
- **Findings (audit doc `docs/audits/PEDIGREE_DRAWING_CURVED_ARC_CENSUS_
  2026-09-18.md`):** (1) overlap join: 0 of the frozen 1,667+1 chord pairs are
  true hits — the arc bows over every same-row chord obstacle; (2) the true
  population, 587 events on 117 of 170 Real-375 connectors (Track C arc-clean),
  sits entirely where no predicate ever looked: 485 events on cross-row
  connectors (`c1` was same-row-only, `c2` skipped curved), 102 from bumped arcs
  crossing upper rows; median penetration 10.9 px of a 25-px radius; (3) the
  repair pass's blind +0.3 roundness bump is net-negative on Real 375 (21 arcs
  hit at 0.2 → 24 at the shipped 0.5); (4) incidental: vis-network
  parseInt-truncates predefined node coordinates — counts stable under that
  quantization (587→586 events, 117 arcs in every ±1-px jitter draw)
  (Learning 763). Census script extended (`c-arc-inside`, scoreboard
  `cArc`/`cArcEdges`, chord subclass retired, lint 0, post-lint re-run
  byte-identical); new baseline CSV
  `docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-18_findings.csv` (595
  rows); frozen 2026-09-02 artifacts untouched.
- **S713 forward-carry discharged:** the re-run reports class (b) = 6 (first
  post-S713 confirmation of the ratified dust floor); the fidelity article's
  mate-line paragraph now cites 6 of 237 (`vignettes/articles/
  kinship2-fidelity-validation.qmd`), the caveats bullet verified count-free,
  Track B centering re-verified (b = 0 on both Track B fixtures).
- **Owner gate (recommended option taken):** fix item filed — arc-verified
  roundness selection replacing the blind bump (BACKLOG, READY, Effort M,
  strict TDD; full brief in the block, incl. which
  `test_resolveEdgeNodeCollisions.R` pins re-derive). Corpus sweep: the test
  comments' "47" figures are frozen CHANGED-history (live pin 56L, correct);
  the only stale live "47" was in the removed BACKLOG block.

### 2026-09-18 · [BL] S714 claim: census curved-chord arc-modelling measurement pass
- BACKLOG Housekeeping "Census curved-chord heuristic" item (S713 next-step A),
  owner-picked via `AskUserQuestion` at Phase 0. Deliverable: model the
  actually-drawn arc geometry (render layer's curved connectors + the roundness
  bump applied to duplicate connectors) and count how many drawn arcs truly pass
  inside a visible unrelated symbol — replacing the 1,667 Real-375 + 1 Track C
  `c-curved-chord` chord-heuristic upper bound — reproducibly, by extending
  `data-raw/pedigreeDrawingErrorCensus.R` or a committed sibling script; then
  recommend whether a fix item is warranted. Carries the S713 forward-carry
  (article "8 of 237" sites + Track B centering) if a census re-run lands.
  Measurement/scoping session, no TDD phases unless package code turns out to be
  touched. Stub + pending receipt written with this entry.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit 35a33905 — S713 close-out self-reconcile
- S713's final commit recorded its own close-out commit sha (`f67830a1`) into the
  completed `HANDOFFS.md` receipt — the recurring self-reference shape S713's own
  handoff predicted (gotcha 4, "expect ~1"). Measured: exactly 1 commit past the
  frontier. No other action in the gap.

### 2026-09-18 · [BL] S713 close-out: census class (b) CLOSED — 6 real rows accepted as minSep-forced structural residuals, 2 dust rows ratified out of the predicate (both owner-ratified)
- **Deliverable (BACKLOG "Census class (b)" block removed in this commit):** the
  census's 8 class-(b) rows are fully dispositioned. The **6 real 60–180 px rows**
  (`__union_97/114/130/137/191/228`) are **accepted as structural residuals, no fix
  item**; the **2 numerical-noise rows** (`__union_75` ≈ 2.8e-5 px, `__union_132`
  ≈ 1.0e-6 px) are solver dust, and the census predicate now skips below the test
  suite's own 1e-3 raw-unit (0.12 px) meaningful floor
  (`data-raw/pedigreeDrawingErrorCensus.R`, commit `de4e6ce8`) so future runs report 6.
  The frozen 2026-09-02 census CSV is untouched (audit record; closure lives here).
- **Evidence — forced vs reducible (the item's own question), both instruments
  agreeing (`scratchpad/s713_probe.R`/`s713_probe2.R`, results in
  `scratchpad/s713_probe_results.rds`):** (1) binding-chain analysis: every
  adjacent pair between each of the 6 unions' rendered mates is BINDING at its
  floor, and the chain-implied minimum offset given the solved mate span equals the
  observed offset exactly (0.5/0.5/1.0/1.5/1.0/0.5 raw units) — marry-in-chain /
  polygamous-anchor crowding (WCPXHD's 5-unit chain, HV7LZ3's 3-unit anchor);
  (2) wUnion sweep 2 → 2e5 on trace()-captured QP inputs (target component: 733
  variables): offsets shrink only by stretching mate spans (`__union_137`
  480 → 1,787 px; `__union_130` 360 → 834 px) — i.e. **minSep-forced at the
  owner-ratified S675 weights**; centering by weight escalation degrades the layout
  and would contradict the no-weight-tuning mandate. The 6 are already disclosed,
  named, and bounded (≤ 1.55 u) by the committed structural-residual test
  (`tests/testthat/test_positionMatingUnitForest.R`, Learning 726 pattern), whose
  own comment reads "8 rows of which 2 dust = 6 meaningful" — the predicate change
  aligns the census with that same dust line (Learning 762).
- **Continuity:** frozen census reproduced to the digit from `s712_layouts.rds`
  (max |diff| ≈ 2e-15 u on all 8 rows) and from a fresh current-engine run (6 real
  rows to 1e-12) before any counterfactual was trusted. Predicate edit verified:
  old skip reproduces the frozen 8 on the current layout; new floor yields exactly
  the disclosed 6, dropping exactly the 2 dust rows. `lintr::lint_package()` (loaded
  per Learning 224): 0 lints. Crops of all 4 neighbourhoods
  (`scratchpad/s713_crop_*.png`): each "off-centre" dot sits adjacent to its distal
  marry-in mate — the conventional multiple-marriage-chain rendering.
- **Coupled prose re-verified (no edit owed now):** Track B "all four union dots
  exactly centered" re-measured live (max residual 1.9e-11 px); the article's
  "8 of 237 ... where the separation floors bind" stays accurate as a citation of
  the standing frozen baseline — the count becomes 6 only at the next census
  re-run, an obligation forward-carried into the curved-chord BACKLOG item.

### 2026-09-18 · [BL] S713 claim: census class (b) off-centre union-dot assessment
- S712 next-step A / BACKLOG "Census class (b)" item, owner-picked via
  `AskUserQuestion` at Phase 0. Deliverable: (i) decide whether the 2
  numerical-noise rows (`__union_75` −2.3e-07 units, `__union_132` 8.7e-09 units)
  belong in the census (the visible-offset tolerance question for the census
  predicate); (ii) determine whether the 6 real 60–180 px offsets
  (`__union_97/114/130/137/191/228`) are minSep-forced or QP-reducible
  (`R/makePedigreeDiagramData.R`, `.solveJointQP()`); (iii) re-verify the coupled
  fidelity-article prose ("8 of 237", 0.00-px Track B centering). Assessment
  session. Stub + pending receipt written with this entry.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit ed79261f — S712 close-out self-reconcile
- S712's final commit recorded its own close-out commit sha into the completed
  `HANDOFFS.md` receipt (the recurring 1-commit self-reference shape its handoff
  gotcha 4 predicted; measured exactly 1). Backfilled at S713 Phase 0 reconcile.

### 2026-09-18 · [BL] S712 close-out: census class (d) CLOSED — both duplicate-adjacent sites assessed acceptable (owner-ratified)
- **Deliverable (this commit; BACKLOG "Census class (d)" block removed in it):** the
  census's 2 class-(d) "adjacent" rows (`docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_
  2026-09-02_findings.csv` rows 3 and 1679 — the CSV itself is a frozen audit record,
  unchanged) are **closed as visually acceptable**, owner-ratified via
  `AskUserQuestion` with all 6 crops presented.
- **Evidence:** fresh current-engine layouts of both fixtures (default rectilinear;
  `scratchpad/s712_probe.R`, cached at `scratchpad/s712_layouts.rds`) reproduce the
  census to the digit — Track C `__dup_Y_2`/`Y` dx = 120.0 px exactly, Real 375
  `__dup_SLN0TF_2`/`SLN0TF` dx = 119.9999999992 px; both pairs same-row with ZERO
  nodes strictly between; the dashed duplicate-connector is present in the edge frame
  at both sites. Crops (100% / 2.2x / context per site, Learning 732 recipe,
  `scratchpad/s712_crop_*.png`): Track C plainly legible (70-px rim gap, connector
  visible); Real 375 structurally identical, its short connector visually obscured
  only by unrelated long-range dashed chords — the class-(c) curved-chord density
  issue tracked in its own BACKLOG item, not an adjacency defect.
- **Rationale for acceptance:** adjacent-at-minSep (1 raw unit = 120 px, the engine's
  own same-row minimum) is the same spacing as any other adjacent pair on the row;
  the overlap subclass (< 50 px) has count 0; adjacency minimizes duplicate-connector
  length, and added separation would lengthen the connector and feed the very class-c
  clutter that is the only legibility concern observed. No separation follow-up
  scoped. Coupled-prose check: `vignettes/articles/kinship2-fidelity-validation.qmd`
  contains zero class-(d)/"adjacent" references (grep-verified), so no prose update
  was owed.
- **Also closed in-session:** S711's open CI loop — R-CMD-check on the S711
  close-out head completed green (run 35390065689, 33m33s; that head is now 4/4).

### 2026-09-18 · [BL] S712 claim: census class (d) duplicate-adjacent assessment
- S711 next-step A / BACKLOG "Census class (d)" item, owner-picked via
  `AskUserQuestion` at Phase 0. Deliverable: render the 2 duplicate-adjacent sites
  (`__dup_Y_2` vs `Y`, Track C; `__dup_SLN0TF_2` vs `SLN0TF`, Real 375) as crops,
  verify local geometry programmatically, judge acceptability, and close the item
  with a dated note or scope a follow-up. Stub + pending receipt written with this
  entry.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit 1788e2b8 — S711 close-out self-reconcile
- S711's final commit recorded its own close-out commit sha into the completed
  `HANDOFFS.md` receipt (the recurring 1-commit self-reference shape its handoff
  gotcha 3 predicted; measured exactly 1). Backfilled at S712 Phase 0 reconcile.

### 2026-09-18 · [ad hoc] S711 close-out: owner-directed push DONE — 34 commits to origin/master, all 4 CI workflows green
- **Push (non-commit action):** `955f6f19..afd33514`, 34 commits (32 at session start
  + Phase 0 backfill `83618479` + claim `afd33514`), spanning S708 MHC Slice 4, the
  S709 export-preview crash fix, and the S710 ledger archive pass. Claim was committed
  BEFORE the push so the pushed head carries the session's own breadcrumb.
- **Outcome:** all 4 on-push workflows green on `afd33514` — lint 5m43s,
  test-coverage 9m58s, pkgdown 16m52s, R-CMD-check 33m22s (runs
  35386636842/35386636857/35386636853/35386636874); watched to completion in-session,
  then re-verified via `gh run list` before recording. Close-out records + the
  self-reconcile sha commit are pushed immediately after this entry (second push);
  that round's verification belongs to the next session's unconditional Phase 0 CI
  check (S706 precedent). Docs-only local changes; runtime smoke n/a — the
  deliverable's verification IS the CI matrix on real runners.

### 2026-09-18 · [ad hoc] S711 claim: owner-directed push of local master to origin/master
- S710 next-step A, owner-picked via `AskUserQuestion` at Phase 0. 33 commits ahead at
  claim (32 at session start + the Phase 0 backfill `83618479`); the claim commit
  itself makes 34. Deliverable: push, then verify the 4 on-push CI workflows
  (R-CMD-check / lint / pkgdown / test-coverage) green and record the outcome.
  Stub + pending receipt written with this entry.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit 0f7f94fe — S710 close-out self-reconcile
- S710's final commit recorded its own close-out commit sha into the completed
  `HANDOFFS.md` receipt (the recurring 1-commit self-reference shape its handoff
  gotcha 5 predicted; measured exactly 1). Backfilled at S711 Phase 0 reconcile.

### 2026-09-18 · [ad hoc] S710 close-out: ledger archive pass DONE — all three byte triggers cleared
- **Deliverable (trims `7fbe17b7`/`3dbe15f3`/`447f2beb`):** S709 next-step A. All three
  ledger files trimmed into `docs/archive/*-through-2026-09-18.md` shards, L1/L2/L3
  verified by each shard's own `verify.sh`: `SESSION_NOTES.md` 87,984 → 4,771 B
  (19 records), `HANDOFFS.md` 78,503 → 16,481 B (13 receipts, never zero),
  `CHANGELOG.md` 68,117 → 9,471 B (40 records, trimmed last so the two earlier
  trim-injected entries landed inside its cut). Final `--check` on all three: no
  trigger fires.
- **Findings:** the default cut on every file collided with the existing
  `-through-2026-09-17` shards (S704–S708 all share that date) — legal retained counts
  were quantized (SESSION_NOTES ≥15 or ≤2; HANDOFFS ≤2; CHANGELOG ≤8) and probed with
  dry-run `--cut N` before any write (Learning 761). The predicted small-denominator
  SRF refusals (Learnings 549/586/594) never fired — no `--force`, no owner gate
  needed. Docs-only; no package files touched; runtime smoke n/a.

### 2026-09-18 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-09-18.md` (40 record(s), 68,117 B → 9,471 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **40** record(s) (2026-09-17 → 2026-09-18) out of [`CHANGELOG.md`](../../CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-09-18.md`](../../docs/archive/CHANGELOG-through-2026-09-18.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-09-18.md.verify.sh`](../../docs/archive/CHANGELOG-through-2026-09-18.md.verify.sh)
rather than trusting a digest printed here. Live file 68,117 B → 9,471 B (−86.1%).

### 2026-09-18 · [ad hoc] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-09-18.md` (13 record(s), 78,503 B → 16,481 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **13** record(s) (2026-09-17 → 2026-09-18) out of [`HANDOFFS.md`](../../HANDOFFS.md) into
[`docs/archive/HANDOFFS-through-2026-09-18.md`](../../docs/archive/HANDOFFS-through-2026-09-18.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh`](../../docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh)
rather than trusting a digest printed here. Live file 78,503 B → 16,481 B (−79.0%).

### 2026-09-18 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-09-18.md` (19 record(s), 87,984 B → 4,771 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **19** record(s) (2026-08-14 → 2026-09-18) out of [`SESSION_NOTES.md`](../../SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-09-18.md`](../../docs/archive/SESSION_NOTES-through-2026-09-18.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-09-18.md.verify.sh`](../../docs/archive/SESSION_NOTES-through-2026-09-18.md.verify.sh)
rather than trusting a digest printed here. Live file 87,984 B → 4,771 B (−94.6%).

### 2026-09-18 · [ad hoc] S710 claim: ledger archive pass — trim SESSION_NOTES.md, HANDOFFS.md, and CHANGELOG.md
- Session claimed (stub + pending HANDOFFS receipt + this entry, one commit). S709
  next-step A, owner-picked via `AskUserQuestion` at Phase 0: all three ledger byte
  triggers fire (`SESSION_NOTES.md` 87,140 B, `HANDOFFS.md` 78,117 B, `CHANGELOG.md`
  65,829 B — it crossed its 65,536 B budget with this session's own Phase 0 backfill).
  Run `methodology_trim.py --write` per file with L1/L2/L3 losslessness verification;
  any small-denominator SRF refusal goes to the owner via `AskUserQuestion` before a
  `--force` (Learnings 549/586/594). Docs-only maintenance; no TDD phases apply.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit `710fea78` — S709's own close-out self-reference commit
- S710 Phase 0 ledger reconcile. The one commit past the frontier (`33b0a556`) is
  S709's final close-out write, which by construction lands after its CHANGELOG entry:
  `710fea78` (close-out commit sha recorded in the HANDOFFS receipt, self-reconcile).
  S709's gotcha 5 predicted about 1 self-reference commit; it measured as exactly 1.

### 2026-09-18 · [BL-Up-Next] S709 close-out: export-preview session-crash fix DONE — the Marker Genetics observers survive missing pedigree ids and failed-validation uploads
- **Deliverable (RED `cd63250c`, GREEN `310c731d`, NEWS `76807b2a`+`61c544a3`):** the top
  BACKLOG Up Next item (found S708). Every upstream read inside the LD-block, sequence,
  and MHC export-preview observers in `R/modMarkerGenetics.R` now goes through
  `safeRead()` + `req()`, so a malformed upload's validation error or an erroring
  `pedigree()` aborts the preview quietly instead of ending the user's session (Learning
  758); the sequence observer ports the MHC tab's Dragon 5 pre-check
  (`sequenceExportMissingIds`: build nothing, show the count + alias-map precondition in
  the guidance); the three guidance renderUIs name the could-not-be-processed state.
  Strict TDD, all gates owner-approved via `AskUserQuestion` (3 PRE-RED approach
  decisions, PRE-RED→RED, RED→GREEN, GREEN→skip-REFACTOR-and-close-out).
- **Two evidence-driven scope rulings (owner-ratified):** the LD-block missing-id
  pre-check was deliberately NOT ported — `markerLdBlock()` subsets its matrix to
  `founderIds` drawn from the same pedigree (`R/markerLdBlock.R:236`), so `idsUsed` can
  never carry a non-pedigree id and the branch would be untestable dead code; and the
  RED tests exposed a SECOND, unknown crash path fixed in the same GREEN — the module's
  eager E2E data-ready `observe()` re-threw a malformed shared upload's validation error
  with no export click at all (Learning 759).
- **Verification:** fresh pre-change baseline 2,405→S708-shape reproduced (2,427 blocks,
  failed=0). RED honest: 5 new `testServer` blocks fail via `shiny.destroyed.error`
  (Learning 759's refinement: the destroyed module session IS directly assertable),
  1 guard passes by design; the new live E2E reproduced the disconnect on the real tab
  pre-fix (`Shiny.shinyapp.isConnected()` FALSE). GREEN: target file 66/66; both live
  E2E tests pass (Phase 3E smoke — session survives, guidance shows the reason,
  pre-existing full export flow unchanged); package-loaded lint 0; full suite once on
  final source 2,434 blocks = baseline + the 7 new, failed=3 all triaged (2 wall-clock
  benchmarks green on quiet re-run — CPU contention, Learning 760; 1 spelling fixed by
  rewording the NEWS entry, re-run green); `devtools::check()` 0 errors, 1 W + 1 N both
  the known untracked-local-file artifacts. Learnings 759/760 appended; BACKLOG item
  removed.

### 2026-09-18 · [BL-Up-Next] S709 claim: fix the LD-block/Genomic ROH export-preview session-disconnect crash
- Session claimed (stub + pending HANDOFFS receipt + this entry, one commit). Top BACKLOG
  Up Next item (found S708): both existing export observers in `R/modMarkerGenetics.R`
  call de-identification primitives that `stop()` inside `observeEvent()`, which
  disconnects a live Shiny session (Learning 758); port the MHC tab's
  `mhcExportMissingIds` pre-check to `ldBlockExportPreview` and `sequenceExportPreview`,
  and fold in the MHC malformed-upload residual. Strict TDD. Close-out entry follows at
  Phase 3F.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit `cc540bf3` — S708's own close-out self-reference commit
- S709 Phase 0 ledger reconcile. The one commit past the frontier (`6b008487`) is
  S708's final close-out write, which by construction lands after its CHANGELOG entry:
  `cc540bf3` (close-out commit sha recorded in the HANDOFFS receipt, self-reconcile).
  S708's gotcha 5 predicted about 1 self-reference commit; it measured as exactly 1.

### 2026-09-18 · [issue #148] S708 closed issue #148 on GitHub (all 4 slices shipped)
- `gh issue close 148 --reason completed` with a comment listing the four slices' commits
  and S708's verification evidence (closed 2026-09-18T05:23:31Z,
  https://github.com/rmsharp/nprcgenekeepr/issues/148). Non-commit action, per the issue
  close-out checklist (close in the same session the last BACKLOG item ships).

