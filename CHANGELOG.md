# Changelog — Authoritative Action Ledger

Development / process history for the **nprcgenekeepr** project,
following the [methodology](https://github.com/rmsharp/methodology)
model: `BACKLOG.md` holds open work, **this file** holds completed
history, and `ROADMAP.md` holds the feature inventory and future plans.
Per canonical v3.1+, this file is the cumulative, append-only record of
**actions taken** in this repository — the authoritative answer to
*“what was done here, ever?”* Every session records its actions here at
close-out (`SESSION_RUNNER.md` Phase 3F); Phase 0 reconciles it against
`git log` and backfills anything a crashed or out-of-band session
missed. Taking an action and not recording it is failure mode \#27.

> **Note:** User-facing R-package release notes (the CRAN / pkgdown
> “Changelog”) live in `NEWS.md` / `NEWS.Rmd`. This file tracks the
> development *process* and methodology history, not package releases.

## 2026-08

## 2026-09

**Archived 328 record(s), 2026-08-14 → 2026-09-17** into
[`docs/archive/CHANGELOG-through-2026-09-17.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/CHANGELOG-through-2026-09-17.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/CHANGELOG-through-2026-09-17.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/CHANGELOG-through-2026-09-17.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

### 2026-09-17 · \[ad hoc\] S706 owner-directed push: 65 commits (S697–S706 span) to `origin/master`

- Owner directive (“push”), discharging the standing push decision
  carried since S703’s next-steps. The span includes the first real
  package changes since the last push (S696): issue \#148 Slices 1 AND 2
  ([`checkMhcHaplotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMhcHaplotypeFile.md),
  [`.parseMhcHaplotypeCalls()`](https://github.com/rmsharp/nprcgenekeepr/reference/dot-parseMhcHaplotypeCalls.md),
  [`mhcHaplotypeFrequency()`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeFrequency.md),
  [`mhcHaplotypeCarriers()`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeCarriers.md),
  with tests/man/NAMESPACE/pkgdown/NEWS/WORDLIST), plus the S697–S706
  docs/records commits. Local full suite green on exactly this state
  (2,400 blocks, failed=0, error=0, measured S706 close-out). Push
  triggers the 4 on-push workflows
  (`R-CMD-check.yaml`/`lint.yaml`/`pkgdown.yaml`/`test-coverage.yaml`) —
  the first CI read of both Slice 1 and Slice 2; next session’s Phase 0
  CI check (or this session’s own post-push watch) confirms the runs.
  **Outcome (this session’s watch):** all 4 workflows
  `completed success` on `d3b9dec9` — R-CMD-check, lint, test-coverage,
  pkgdown all green; the push is fully verified, no CI follow-up owed.

### 2026-09-17 · \[issue \#148\] S706 close-out: Slice 2 DONE — `mhcHaplotypeFrequency()` + `mhcHaplotypeCarriers()` shipped under strict TDD; Slice 3 BACKLOG item queued

- **Deliverable (RED `e8a63f05`, GREEN `930536e8`, checklists
  `4a03fff3`):** the ratified plan’s Slice 2 statistics.
  [`mhcHaplotypeFrequency()`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeFrequency.md)
  (exported): per-haplotype `summary` (nCopies, nCarriers, nUncertain,
  frequency, isRare) + one-row file-level `counts`; certain-call 2N
  denominator (D3 exclude-and-disclose); D4 dual `<=` rarity criterion
  (frequency 0.01 / carriers 2, both configurable); an uncertain-only
  label gets no summary row.
  [`mhcHaplotypeCarriers()`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeCarriers.md)
  (exported): carrier detail (haplotype, id, uncertain),
  `rareOnly = TRUE` default; provisional carriers (all calls of the
  haplotype uncertain) listed and flagged, never counted in `nCarriers`.
  All TDD gates owner-approved via `AskUserQuestion` (PRE-RED→RED,
  RED→GREEN, GREEN→skip-REFACTOR-close-out).
- **Semantics fixed by measurement (S706, pre-RED):** the real file’s
  uncertain `A002a_B015` call has NO certain counterpart (pins the
  no-summary-row rule), and counting the one provisional carrier
  (`0F4FY1`, `A008_B015b`) in `nCarriers` would move that haplotype to 3
  carriers and break the plan’s ratified 26-flagged pin — so `nCarriers`
  counts certain carriers only.
- **Verification:** fresh pre-change baseline measured before any test
  file existed (2,384 blocks, failed=0, error=0, skipped=182, warning=42
  — reproducing S705’s shipped-source numbers exactly). RED confirmed
  honest: 12 pattern-less `expect_error()` assertions initially passed
  spuriously (Learning 492’s exact trap, re-applied not re-minted) and
  were tightened to parameter-naming messages before the RED commit —
  final RED state 16 blocks, 0 passing expectations, failures only from
  the two missing symbols. GREEN: 102 assertions green; full suite run
  ONCE on the final post-lint post-checklist source (S705’s own lesson
  applied): 2,400 blocks = baseline + exactly the 16 new, failed=0,
  error=0, skipped/warnings unchanged. Real-data pins reproduce the
  plan’s measured numbers (33 distinct / denominator 60 / 26 flagged all
  via the carrier leg / 61 + 32 carrier rows).
  [`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
  verified (2 NAMESPACE lines + 2 man pages, no collateral). Citation
  checklist (issue \#120): all 6 roxygen `@references` sources verified
  by an independent research agent against Crossref/PubMed — exact
  metadata confirmed incl. the two previously-unverified volume/pages
  (Hurley 2020 = HLA 95(6):516-531; Lacy 2012 = MEE 3(2):433-437);
  Doxiadis prose kept to the paper’s own figures; Allendorf attribution
  kept mild (primary text inaccessible, secondary-source-supported).
  Same-session checklists: `_pkgdown.yml` catch-all entries (coverage
  guard green), `NEWS.Rmd` plain-language entry + `NEWS.md` rendered
  same-commit (plus a pre-existing missing-blank-line heading wart the
  render surfaced, fixed), 13 citation surnames/acronyms to
  `inst/WORDLIST` (S564 precedent), package-loaded lint clean (one
  implicit-integer style fix). Vocabulary grep clean (Dragon 3). Runtime
  smoke n/a — script-callable additions only, no Shiny wiring (arrives
  at Slice 4).
- **Records:** BACKLOG.md — completed Slice 2 item removed (this entry
  is its record); Slice 3 item queued at the top of Up Next
  (`obfuscateMhcHaplotypes()`, plan §4 row 5); batch narrative updated.
  No new numbered learning — the one trap hit was Learning 492’s,
  already recorded. Issue \#148 stays OPEN (Slices 3-4 remain).

### 2026-09-17 · \[issue \#148\] S706 claim: Slice 2 — MHC haplotype statistics (session claimed, work beginning)

- Phase 1B claim for the issue \#148 Slice 2 implementation session
  (S705 next-step A; owner-picked via `AskUserQuestion` at Phase 0).
  Deliverable:
  [`mhcHaplotypeFrequency()`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeFrequency.md)
  (exported: `list(summary, counts)`, ratified D4 dual rarity criterion
  — frequency ≤ 0.01 OR carriers ≤ 2) +
  [`mhcHaplotypeCarriers()`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeCarriers.md)
  (exported: carrier detail), per plan §4 rows 3-4 / §5 Slice 2, strict
  TDD with `AskUserQuestion`-gated phases, building on Slice 1’s
  [`.parseMhcHaplotypeCalls()`](https://github.com/rmsharp/nprcgenekeepr/reference/dot-parseMhcHaplotypeCalls.md).
  Same-session checklists: NEWS.Rmd + NEWS.md render, `_pkgdown.yml`,
  lint, citation checklist (issue \#120 — re-verify every plan §2.8
  source), fresh full-suite baseline (Slice 2 touches package files),
  vocabulary grep at close-out.

### 2026-09-17 · \[ad hoc\] Backfilled (reconcile-on-read): undocumented commits `2f83a6e2`..`ba5bcde8` — S705’s own close-out self-reference commits

- S706 Phase 0 ledger reconcile. The two commits past the frontier are
  S705’s final close-out writes, which by construction land after its
  CHANGELOG entry (`5d3146cf`): `2f83a6e2` (SESSION_NOTES handoff + S704
  evaluation, HANDOFFS receipt completed) and `ba5bcde8` (close-out
  commit sha recorded in the HANDOFFS receipt, self-reconcile). The
  recurring shape S705’s gotcha 2 predicted; no work is missing, the
  record is simply being trued up. HANDOFFS.md frontier is HEAD with a
  `status: complete` receipt — nothing to reconcile there.

### 2026-09-17 · \[issue \#148\] S705 close-out: Slice 1 DONE — `checkMhcHaplotypeFile()` + `.parseMhcHaplotypeCalls()` shipped under strict TDD; Slice 2 BACKLOG item queued

- **Deliverable (RED `5c0f359b`, GREEN `e6b548c6`, checklists
  `2ea1962d`):** the ratified plan’s Slice 1.
  [`checkMhcHaplotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMhcHaplotypeFile.md)
  (exported): wide per-animal MHC haplotype designation validator —
  exactly 3 columns, id-like first column, unique ids, names forced to
  `id, haplotype1, haplotype2`; `NA`/empty cells pass (missing is the
  statistics layer’s concern); the bundled `rhesusGenotypes` loads
  unchanged.
  [`.parseMhcHaplotypeCalls()`](https://github.com/rmsharp/nprcgenekeepr/reference/dot-parseMhcHaplotypeCalls.md)
  (internal): the D3 parse rule — `NA`/empty = missing, trailing `?` =
  uncertain call of the stripped label, labels otherwise opaque (bare
  `"?"` is a certain opaque label, pinned). All TDD gates owner-approved
  via `AskUserQuestion` (PRE-RED→RED, RED→GREEN,
  GREEN→skip-REFACTOR-close-out).
- **Verification:** fresh pre-change baseline measured (2,370 blocks,
  failed=0, error=0, skipped=182 — ending the S699–S704
  inherited-baseline chain), RED confirmed 0 passing for the right
  reasons, GREEN suite run TWICE (the second on the final post-lint-fix
  source): 2,384 blocks = baseline + exactly the 14 new blocks,
  failed=0, error=0, skipped/warnings unchanged. Real-data pins
  reproduce the plan’s measured numbers (62 calls / 2 uncertain / 0
  missing / 33 distinct / 60 certain).
  [`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
  verified (1 NAMESPACE line + 2 expected man pages); same-session
  checklists: `_pkgdown.yml` catch-all entry (coverage guard green),
  `NEWS.Rmd` plain-language entry (new “MHC Haplotype Reporting”
  subsection) + `NEWS.md` rendered, package-loaded lint clean on all 4
  touched files (one `nzchar` style fix). Vocabulary grep clean (plan
  Dragon 3). Runtime smoke n/a — script-callable additions only, no
  Shiny wiring (that arrives at Slice 4).
- **Records:** BACKLOG.md — completed Slice 1 item removed (this entry
  is its record); Slice 2 item queued at the top of Up Next (statistics:
  [`mhcHaplotypeFrequency()`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeFrequency.md) +
  [`mhcHaplotypeCarriers()`](https://github.com/rmsharp/nprcgenekeepr/reference/mhcHaplotypeCarriers.md),
  plan §4 rows 3-4). No new numbered learning — the session followed the
  ratified plan without surprises. Issue \#148 stays OPEN (Slices 2-4
  remain).

### 2026-09-17 · \[issue \#148\] S705 claim: Slice 1 — MHC haplotype validator + parse rule (session claimed, work beginning)

- Phase 1B claim for the issue \#148 Slice 1 implementation session
  (S704 next-step A; owner-picked via `AskUserQuestion` at Phase 0; the
  ratified design plan’s first implementation slice). Deliverable:
  [`checkMhcHaplotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMhcHaplotypeFile.md)
  (exported) +
  [`.parseMhcHaplotypeCalls()`](https://github.com/rmsharp/nprcgenekeepr/reference/dot-parseMhcHaplotypeCalls.md)
  (internal) with tests-first strict TDD, per plan §4 rows 1-2 / §5
  Slice 1; fixtures = bundled real pair + synthetic edge cases (plan
  Dragons 6/7). Same-session checklists: NEWS.Rmd, \_pkgdown.yml, lint,
  fresh full-suite baseline (the S696–S698 baseline is inherited and
  this session touches package files). Claim entry ships in the claim
  commit (Learnings 752/754 convention).

### 2026-09-17 · \[ad hoc\] Backfilled (reconcile-on-read): undocumented commits 52676abe..49af9123 — S704 close-out self-reference commits

- The recurring shape (predicted by S704’s own gotcha 2): the two
  commits that record a session’s close-out (`52676abe` SESSION_NOTES
  handoff + HANDOFFS receipt complete; `49af9123` close-out sha
  self-reconcile into the receipt) necessarily land AFTER that session’s
  Phase 3F ledger entry, so they sit past the frontier until the next
  session’s Phase 0 reconcile records them. No untracked work — both are
  S704’s own documentation.

### 2026-09-17 · \[issue \#148\] S704 close-out: MHC haplotype-reporting design plan RATIFIED (D1-D10; owner picked all 4 recommended judgment calls); Slice 1 BACKLOG item queued; 1 learning

- **Deliverable (`f66ee459`):**
  `docs/planning/issue148-mhc-haplotype-reporting-plan.md` — the
  \#152/#153-mold design plan the S703 scope decision required,
  resolving the scoping doc’s Q1–Q8 as ten numbered decisions. Owner
  ratified all 4 judgment calls at their recommended option via one
  `AskUserQuestion` round: **D2** dedicated wide upload
  (`id, haplotype1, haplotype2` behind a new
  [`checkMhcHaplotypeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMhcHaplotypeFile.md)
  — designation-by- upload, the biallelic gate never adjacent); **D3**
  exclude-and-disclose uncertain `?`-calls (never a distinct haplotype);
  **D4** dual rarity criterion (frequency ≤ 0.01 OR carriers ≤ 2, both
  configurable — measured on the bundled file: the frequency leg alone
  flags 0 at 2N=60, the carrier leg 26/33, hence the dual OR); **D8**
  eighth tab in `modMarkerGenetics`, zero changes to the existing seven.
  Forced: D1 vocabulary, D5 both report shapes, D6 all-exports-gated +
  manifest, D7 persistent caveat, D9 opaque labels, D10 four slices
  (validator → statistics → de-id primitive → UI/export/docs), each a
  future strict-TDD session with per-slice completion criteria and owed
  checklists mapped. Evidence: direct reads of every load-bearing file,
  measured frequency distribution of `rhesusGenotypes`, and a
  DIRECT/INFERENCE/UNVERIFIED-tagged domain-research pass (IPD-MHC
  nomenclature, Wiseman 2013 label convention, CIWD dual-criterion
  precedent, 2N-chromosome denominators).
- **Records:** BACKLOG.md — completed design-plan item removed (this
  entry is its record); new top Up Next item queued (implement Slice 1,
  READY, Effort M, full forward-carried context); batch narrative
  updated (#148 design RATIFIED, Slices 1-4 open). Learning 757 (verify
  “measured” claims and draft citations independently — 1 unmeasured
  measurement and 5 wrong-or-unverifiable citations caught
  pre-ratification). Incidental finding routed into the plan, not fixed
  (Learning 382 precedent):
  [`modMarkerGeneticsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsServer.md)’s
  roxygen `@return` says “fourteen reactive elements” but the return
  list has 19 — repair scheduled as part of Slice 4’s own documented
  `@return` additions. No suite run: docs-only; the S696–S698 baseline
  (2,370 blocks, failed=0, error=0, skipped=182) carries forward by
  inheritance.

### 2026-09-17 · \[issue \#148\] S704 claim: MHC haplotype-reporting design plan (session claimed, work beginning)

- Phase 1B claim for the issue \#148 design-plan session (S703 next-step
  A; owner-picked via `AskUserQuestion` at Phase 0; the design-first
  gate the S703 scope-narrowing decision established). Deliverable:
  `docs/planning/issue148-mhc-haplotype-reporting-plan.md` in the
  \#152/#153 mold — ratify Q1–Q8 from the scoping doc §4 as numbered
  decisions, vertical-slice list, per-slice completion criteria.
  PLANNING session: the plan doc is the whole deliverable, no
  implementation (FM \#18/#19). Docs-only — no TDD phases. Claim entry
  ships in the claim commit (Learnings 752/754 convention).

### 2026-09-17 · \[ad hoc\] Backfilled (reconcile-on-read): undocumented commits 2be33272..aec3b514 — S703 close-out self-reference commits

- The recurring shape (predicted by S703’s own gotcha 2): the two
  commits that record a session’s close-out (`2be33272` SESSION_NOTES
  handoff + HANDOFFS receipt complete; `aec3b514` close-out sha
  self-reconcile into the receipt) necessarily land AFTER that session’s
  Phase 3F ledger entry, so they sit past the frontier until the next
  session’s Phase 0 reconcile records them. No untracked work — both are
  S703’s own documentation.

### 2026-09-17 · \[issue \#148\] S703 close-out: scope-narrowing decision record DONE (owner: design-first, same issue); design-plan BACKLOG item queued; 1 learning

- **Deliverable (`fcf94807`):**
  `docs/planning/issue148-mhc-haplotype-scoping-2026-09-17.md` — the
  scope-narrowing conversation audit Finding \#4 required before any
  \#148 work. Owner decision via `AskUserQuestion`: **design-first, same
  issue** (rejected: sub-issue split, implement-as-filed, defer — all
  recorded with reasons). The doc carries the grep-verified evidence
  inventory (all Finding \#4 preconditions now satisfied by the shipped
  \#146–#153 siblings: vocabulary reservation in code, sibling-validator
  pattern as the landmine defusal, allele-frequency helper, \#150 export
  gate, `rhesusGenotypes` example data) and Q1–Q8, the open design
  questions the future plan session must ratify. Citations line-verified
  before commit (one off-by-one caught and fixed).
- **Records:** BACKLOG.md — new top Up Next item (write
  `docs/planning/issue148-mhc-haplotype-reporting-plan.md` in the
  \#152/#153 mold; READY, Effort M, planning session) with full
  forward-carried context; the genetic-metrics batch narrative’s “#148
  remains unstarted” line updated to point at the decision record.
  Learning 756 (re-derive an audit finding’s claims against HEAD at
  pick-up — the preconditions had dissolved while the gate stayed
  valid). No suite run: docs-only; the S696–S698 baseline (2,370 blocks,
  failed=0, error=0, skipped=182) carries forward by inheritance.

### 2026-09-17 · \[issue \#148\] S703: scope-narrowing comment posted to GitHub issue \#148 (non-commit action)

- Comment `issuecomment-5721771731` records the owner decision on the
  issue itself: the full-feature body is now read through the
  design-first gate — plan doc ratified first, implementation slices
  after; hard constraints restated (biallelic gate untouchable, sibling
  validator, vocabulary reservation, no MHC inference from locus names).
  Issue stays OPEN through design and implementation.

### 2026-09-17 · \[issue \#148\] S703 claim: MHC haplotype scoping document (session claimed, work beginning)

- Phase 1B claim for the issue \#148 scope-narrowing/scoping session
  (S702 next-step A; owner-picked via `AskUserQuestion` at Phase 0; the
  genetic-metrics sequencing audit’s last open item,
  `GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` Finding \#4 —
  the issue is filed as a full feature while the audit recommends
  design-first treatment). Deliverable: one scoping document; the scope
  decision goes to the owner via `AskUserQuestion` mid-session.
  Docs-only planning session — no TDD phases. Claim entry ships in the
  claim commit (Learnings 752/754 convention).

### 2026-09-17 · \[ad hoc\] Backfilled (reconcile-on-read): undocumented commits 5a8bb047..43b29508 — S702 close-out self-reference commits

- The recurring close-out shape (same as S701’s `79b6003b`/`8c0097fb`,
  backfilled `cd2ba39f`): after S702’s ledger-recording commit
  `922350bd`, two further commits landed that by construction cannot
  ledger themselves — `5a8bb047` (SESSION_NOTES handoff + S701
  evaluation, HANDOFFS receipt completed) and `43b29508` (close-out
  commit sha recorded into the HANDOFFS receipt, self-reconcile). Both
  are S702 close-out bookkeeping, fully described by the S702 entry
  below; no work product is missing. Backfilled by the next session’s
  Phase 0 reconcile-on-read, exactly as S702’s gotcha 3 predicted.

### 2026-09-17 · \[BL-Housekeeping\] S702 close-out: CHANGELOG.md archive pass DONE (328 records archived, verified lossless); 1 learning; BACKLOG item removed (both halves done)

- **Deliverable (owner-picked via `AskUserQuestion` at Phase 0;
  docs-only maintenance session — no TDD phases, S700/S701/S594/S539
  archive-pass precedent):** the `methodology_trim.py` archive pass on
  `CHANGELOG.md` — 328 records (2026-08-14 → 2026-09-17) moved to
  `docs/archive/CHANGELOG-through-2026-09-17.md`, live file 464,522 B →
  33,503 B (−92.8%), both triggers cleared. L1/L2/L3/P1A asserted by the
  tool AND re-derived independently by the generated `verify.sh` (“OK:
  L1, L2/front-matter, L3 hold”; 347 = 19 retained + 328 archived). Trim
  commit `6bac092f`.
- **Gates:** `P1_UNDOCUMENTED` never fired — the claim ledger entry
  shipped IN the Phase 1B claim commit (`78dbd8ce`; Learnings 752/754).
  `SRF_RED` DID fire, contrary to the item’s carried “likely GREEN”
  prediction — the actual most-recent archive boundary is S579’s
  2026-08-14 pass (`66d5aa5`), not S547’s ~934 KB relocation (SRF 6.3072
  vs S579; 0.4739 vs S547’s largest-drop boundary — the
  small-denominator shape a fourth time); owner-directed `--force` via
  `AskUserQuestion` (S594/S700/S701 precedent). The wrong carried
  prediction is now Learning 755.
- **Post-trim verification:** dashboard re-run and flag list extracted
  (Learning 753 method) — the `CHANGELOG.md` HIGH read-cap flag and
  MEDIUM trigger flag are GONE; only the pre-existing MEDIUM
  (`.Rproj.user` jspdf artifact) and LOW (9 branches) flags remain. Live
  file lands near the 32,768 B hysteresis stop, not near-zero, as
  Learning 754 predicts (19 records retained).
- BACKLOG Housekeeping item removed entirely (completed-item removal
  convention) — both halves done (HANDOFFS S701, CHANGELOG S702); the
  distinct H4 ~4-entries-per-session *rate* item remains open,
  unchanged. No suite run: docs-only; the S696–S698 baseline (2,370
  blocks, failed=0, error=0, skipped=182) carries forward by
  inheritance.

### 2026-09-17 · \[ad hoc\] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-09-17.md` (328 record(s), 464,522 B → 33,503 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a
session’s judgment. Moved the oldest **328** record(s) (2026-08-14 →
2026-09-17) out of
[`CHANGELOG.md`](https://github.com/rmsharp/nprcgenekeepr/CHANGELOG.md)
into
[`docs/archive/CHANGELOG-through-2026-09-17.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/CHANGELOG-through-2026-09-17.md).
Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run
[`docs/archive/CHANGELOG-through-2026-09-17.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/CHANGELOG-through-2026-09-17.md.verify.sh)
rather than trusting a digest printed here. Live file 464,522 B → 33,503
B (−92.8%).

### 2026-09-17 · \[BL-Housekeeping\] S702 claim: CHANGELOG.md archive pass (session claimed, work beginning)

- Phase 1B claim for the `CHANGELOG.md` archive pass via
  `methodology_trim.py` — the BACKLOG Housekeeping item’s remaining half
  (the `HANDOFFS.md` half was DONE S701); owner-picked via
  `AskUserQuestion` at Phase 0; docs-only maintenance session, no TDD
  phases (S700/S701/S594/S539 archive-pass precedent). This claim entry
  ships IN the claim commit so the ledger frontier sits at HEAD before
  the tool’s first `--write` (`P1_UNDOCUMENTED` gate; Learnings
  752/754). Stub in `SESSION_NOTES.md`, pending receipt in
  `HANDOFFS.md`, this entry — one commit.

### 2026-09-17 · \[ad hoc\] Backfilled (reconcile-on-read): undocumented commits 79b6003b..8c0097fb — S701 close-out self-reference commits

- The recurring close-out shape (same as S700’s `c0b7ec81`/`d86c576a`,
  backfilled `21d09bca`): after S701’s ledger-recording commit
  `1a8aeb20`, two further commits landed that by construction cannot
  ledger themselves — `79b6003b` (SESSION_NOTES handoff + S700
  evaluation, HANDOFFS receipt completed) and `8c0097fb` (close-out
  commit sha recorded into the HANDOFFS receipt, self-reconcile). Both
  are S701 close-out bookkeeping, fully described by the S701 entry
  below; no work product is missing. Backfilled by the next session’s
  Phase 0 reconcile-on-read.

### 2026-09-17 · \[BL-Housekeeping\] S701 close-out: HANDOFFS.md archive pass DONE (116 receipts archived, verified lossless); 1 learning; BACKLOG item narrowed to the CHANGELOG.md half

- **Deliverable (owner-picked via `AskUserQuestion` at Phase 0;
  docs-only maintenance session — no TDD phases, S700/S594/S539
  archive-pass precedent):** the `methodology_trim.py` archive pass on
  `HANDOFFS.md` — 116 receipts (2026-08-14 → 2026-09-17) moved to
  `docs/archive/HANDOFFS-through-2026-09-17.md`, live file 590,777 B →
  31,315 B (−94.7%), both triggers cleared, stale front-matter receipt
  count regenerated 21 → 6. L1/L2/L3/P1A asserted by the tool AND
  re-derived independently by the generated `verify.sh` (“OK: L1,
  L2/front-matter, L3 hold”; 122 = 6 retained + 116 archived). Trim
  commit `9b551c8b`.
- **Gates:** `P1_UNDOCUMENTED` never fired — the claim ledger entry
  shipped IN the Phase 1B claim commit (`f51210bb`), keeping the
  frontier at HEAD (Learning 752 applied; zero wasted cycles, Learning
  754). `SRF_RED` fired as predicted (5.0215 vs the tiny 21-receipt
  2026-08-14 boundary, 0.6989 vs the largest-drop boundary — the
  S594/S700 small-denominator shape exactly); owner-directed `--force`
  via `AskUserQuestion`.
- **Post-trim verification:** dashboard re-run and flag list extracted
  (Learning 753 method) — the `HANDOFFS.md` flags are gone;
  `CHANGELOG.md` (5,562 lines / 461,077 B) is the only remaining flag,
  already queued. `bin/check-handoff` does not exist in this project
  (canonical-only, never copied) — the shard-checker step is N/A, stated
  rather than silently skipped.
- Learning 754 appended to `PROJECT_LEARNINGS.md` (minimal-cut →
  per-file re-fire cadence; ~7-session HANDOFFS recurrence estimate).
  `BACKLOG.md` Housekeeping item rewritten to its remaining
  `CHANGELOG.md` half with forward-carried procedure notes
  (completed-item removal convention). No suite run: docs-only; the
  S696–S698 baseline (2,370 blocks, failed=0, error=0, skipped=182)
  carries forward by inheritance.

### 2026-09-17 · \[ad hoc\] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-09-17.md` (116 record(s), 590,777 B → 31,315 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a
session’s judgment. Moved the oldest **116** record(s) (2026-08-14 →
2026-09-17) out of
[`HANDOFFS.md`](https://github.com/rmsharp/nprcgenekeepr/HANDOFFS.md)
into
[`docs/archive/HANDOFFS-through-2026-09-17.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-09-17.md).
Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run
[`docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/HANDOFFS-through-2026-09-17.md.verify.sh)
rather than trusting a digest printed here. Live file 590,777 B → 31,315
B (−94.7%).

### 2026-09-17 · \[BL-Housekeeping\] S701 claim: HANDOFFS.md archive pass (pre-trim claim entry, clears the tool’s P1_UNDOCUMENTED gate)

- Session claimed (Phase 1B stub in `SESSION_NOTES.md`,
  `status: pending` receipt in `HANDOFFS.md`, this entry — one commit,
  so the ledger frontier sits at HEAD before the first `--write`, per
  Learning 752 / the BACKLOG item’s procedure note 1). Deliverable: the
  `methodology_trim.py` archive pass on `HANDOFFS.md` (6,563 lines /
  590,437 B at orient, HIGH past the 2,000-line read cap). The
  `CHANGELOG.md` pass remains a separate session (same BACKLOG item,
  second half).

### 2026-09-17 · \[ad hoc\] Backfilled (reconcile-on-read): undocumented commits c0b7ec81..d86c576a — S700 close-out self-reference commits

- The recurring close-out shape (same as S699’s `87dfb4dc`/`4901c0f4`,
  backfilled `af664d43`): after S700’s ledger-recording commit
  `c179897a`, two further commits landed that by construction cannot
  ledger themselves — `c0b7ec81` (SESSION_NOTES handoff + S699
  evaluation, HANDOFFS receipt completed) and `d86c576a` (close-out
  commit sha recorded into the HANDOFFS receipt, self-reconcile). Both
  are S700 close-out bookkeeping, fully described by the S700 entry
  below; no work product is missing. Backfilled by the next session’s
  Phase 0 reconcile-on-read.

### 2026-09-17 · \[ad hoc\] S700 close-out: SESSION_NOTES.md trim DONE (170 records archived, verified lossless); 2 learnings; HANDOFFS/CHANGELOG trim item queued

- **Deliverable (owner-picked via `AskUserQuestion` at Phase 0;
  docs-only maintenance session — no TDD phases, S539/S594 archive-pass
  precedent):** the `methodology_trim.py` archive pass on
  `SESSION_NOTES.md` — 170 records (2026-08-19 → 2026-09-17) moved to
  `docs/archive/SESSION_NOTES-through-2026-09-17.md`, live file 931,481
  B → 2,560 B (−99.7%), both triggers cleared. L1/L2/L3 asserted by the
  tool AND re-derived independently by the generated `verify.sh` (both
  green). Trim commit `6f722e25`.
- **Two gates hit, both resolved by their own rules:** `P1_UNDOCUMENTED`
  (the session’s own claim commit was unledgered — reconciled by the
  mid-session claim entry `c75269bb`, per the gate’s instruction;
  Learning 752) and `SRF_RED` (2.3879 vs the most recent, small,
  S594-era archive boundary but 0.1422 vs the largest-drop boundary —
  owner-directed `--force` via `AskUserQuestion`, the S594 precedent
  exactly).
- **Finding (report-don’t-fix):** `HANDOFFS.md` (6,555 lines / 586,022
  B; 122 real receipts vs the stale front-matter “21”) and
  `CHANGELOG.md` (5,515 lines / 457,092 B) are ALSO past the 2,000-line
  read cap with triggers firing, and were already over at S699’s close —
  the “1 HIGH flag” orientation framing was an under-count (the
  dashboard summary counts projects, not flags; Learning 753). Queued as
  one new `BACKLOG.md` Housekeeping item (READY, Effort S each, one file
  per session) carrying the full procedure notes.
- Learnings 752–753 appended to `PROJECT_LEARNINGS.md`. No suite run:
  docs-only, nothing in the package build/test path changed; the
  S696–S698 baseline (2,370 blocks, failed=0, error=0, skipped=182)
  carries forward by inheritance.

### 2026-09-17 · \[ad hoc\] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-09-17.md` (170 record(s), 931,481 B → 2,560 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a
session’s judgment. Moved the oldest **170** record(s) (2026-08-19 →
2026-09-17) out of
[`SESSION_NOTES.md`](https://github.com/rmsharp/nprcgenekeepr/SESSION_NOTES.md)
into
[`docs/archive/SESSION_NOTES-through-2026-09-17.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-09-17.md).
Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run
[`docs/archive/SESSION_NOTES-through-2026-09-17.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-09-17.md.verify.sh)
rather than trusting a digest printed here. Live file 931,481 B → 2,560
B (−99.7%).

### 2026-09-17 · \[ad hoc\] S700: session claimed — SESSION_NOTES.md trim (in progress)

- Claim commit `86c1bc6a` (SESSION_NOTES.md stub + HANDOFFS.md pending
  receipt). Deliverable: the `methodology_trim.py` archive pass on
  `SESSION_NOTES.md` (S699 next-step A; the dashboard’s one HIGH flag,
  ~11,181 lines / 931,481 B against the 65,536 B budget; line headroom
  −140 records). Recorded pre-trim because the tool’s own
  `P1_UNDOCUMENTED` gate (correctly) refuses to trim while any commit
  sits past the ledger frontier — the trim commit would advance the
  frontier and hide it. Outcome recorded in the S700 close-out entry
  above/below at Phase 3F.

### 2026-09-17 · \[ad hoc\] S700 Phase 0: record CHANGELOG.md entry for S699’s close-out commits (reconcile-on-read)

- Phase 0 ledger reconcile found 2 commits since `CHANGELOG.md`’s
  frontier (`8127201d`) with no ledger entry of their own — the same
  self-reference shape this project’s precedent already names repeatedly
  (S639→S643, S647, S698, S699): `87dfb4dc` (S699’s own close-out
  commit, writing the final `SESSION_NOTES.md` handoff + S698 evaluation
  and completing the `HANDOFFS.md` receipt) and `4901c0f4` (recording
  that close-out commit’s sha in the receipt’s `commit:` field,
  self-reconcile). Both postdate `8127201d`, the commit that wrote the
  ledger’s own S699 entry — that entry already describes the session’s
  work; this is a pure reconcile-on-read backfill so the frontier is
  clean.

### 2026-09-17 · \[ad hoc\] S699: standing pedigree-drawing top-priority directive retired by owner sign-off; the 3 measured census residuals itemized at ordinary priority

- **Deliverable (owner-picked via `AskUserQuestion` at Phase 0;
  decision/grooming session, docs-only — no TDD phases):** S698’s
  next-step (A) executed — with the tagged pedigree-fidelity queue
  empty, the owner was asked directly whether the S643 standing
  top-priority directive is satisfied. Owner decision (via
  `AskUserQuestion`, “Sign off + itemize residuals”): the directive is
  **retired** — the pinned `BACKLOG.md` note (owner-directed 2026-08-26,
  S643) removed — and the three remaining measured residuals become
  **ordinary-priority** Housekeeping items. Commits: claim `1ed16e63`,
  deliverable `d6e23e40`.
- **Grounding (re-tallied live from the committed S696 census CSV, not
  quoted from handoffs):** classes a/c1/c2/e/f = 0 on every fixture;
  class b = 8 off-centre unions — the re-tally found **2 of the 8 are
  numerical-noise magnitude** (`__union_75` −2.3e-07 units,
  `__union_132` 8.7e-09 units, caught only by the census’s exact \> 1e-6
  px predicate) and 6 are real 0.5–1.5-unit (60–180 px) minSep-bound
  offsets, a split recorded nowhere before; class c curved-chord
  heuristic = **1,668** total (1,667 Real 375 + 1 Track C — the “1,667”
  in older records is the Real-375-only count); class d = **2** adjacent
  (1 per fixture — “d=1” in older records was Real-375-scoped).
- **The 3 new items** (`BACKLOG.md` Housekeeping, each carrying the CSV
  row ids and coupled prose pointers): (1) class-b investigation —
  noise-tolerance decision for the 2 predicate artifacts +
  structurally-forced-or-reducible analysis for the 6 real offsets,
  article coupling flagged (READY, Effort M); (2) arc-modelling
  measurement pass replacing the curved-chord upper bound with a real
  count (READY, Effort M); (3) class-d 2-adjacent visual assessment
  (READY, Effort S).
- **Agent memory:** the persistent standing-priority memory note
  rewritten to RETIRED (and its index line updated) so stale
  handoffs/forward-carries can’t resurrect the override.
- No new `PROJECT_LEARNINGS.md` entry: the session’s one non-obvious
  finding (the class-b noise/real split) is forward-carried in the live
  item itself, per the completed-item convention’s “detail a live open
  item needs is written INTO that item.”
- No GitHub issue involved;
  NEWS/citation/tutorial/`a2interactive`/`_pkgdown` checklists N/A by
  inspection (no package-path file touched). Full-suite regression not
  re-run this session: no file in the package build/test path changed
  (BACKLOG/CHANGELOG/SESSION_NOTES/ HANDOFFS only); the S696–S698
  baseline (2,370 blocks, failed=0, error=0, skipped=182) carries
  forward.

### 2026-09-17 · \[ad hoc\] S699 Phase 0: record CHANGELOG.md entry for S698’s close-out commits (reconcile-on-read)

- Phase 0 ledger reconcile found 2 commits since `CHANGELOG.md`’s
  frontier (`efd67743`) with no ledger entry of their own — the same
  self-reference shape this project’s precedent already names repeatedly
  (S639→S643, S647, S698): `49ae8ac1` (S698’s own close-out commit,
  writing the final `SESSION_NOTES.md` handoff + S697 evaluation and
  completing the `HANDOFFS.md` receipt) and `ddfa0dae` (recording that
  close-out commit’s sha in the receipt’s `commit:` field,
  self-reconcile). Both postdate `efd67743`, the commit that wrote the
  ledger’s own S698 entry — that entry already describes the session’s
  work; this is a pure reconcile-on-read backfill — no content beyond
  what `49ae8ac1`/`ddfa0dae`’s own diffs already show. `HANDOFFS.md`’s
  own frontier has no gap (`ddfa0dae` is already its last touching
  commit; receipt `status: complete`).

### 2026-09-17 · \[BL-pedRemeasure\] S698: pedigree-drawing housekeeping re-measure pass — D2-dogleg comment re-derived, 5-pair proximity residual closed resolved-by-construction, fidelity-article mate-line paragraphs rewritten to the QP engine

- **Deliverable (owner-picked via `AskUserQuestion` at Phase 0;
  DEVELOPMENT_WORKSTREAM, docs/comments-only — no TDD phases,
  S692/S694/S695/S697 precedent):** the three standing pedigree-fidelity
  Housekeeping re-measures, each re-derived live under the current QP
  engine before any edit (`scratchpad/s698_remeasure.R`, kept on disk
  per the don’t-clean precedent). Commits: claim `3daa4001`, deliverable
  `262c65be`.
- **(A) D2-dogleg reachability
  (`test_resolveEdgeNodeCollisions.R:20-29`):** live re-derivation
  confirms 0 `__proj_` nodes among the real 375 fixture’s 1,456
  rectilinear nodes — the dogleg is structurally unreachable again, but
  by S678’s Decision 2 mechanism (every resolved mate node carries its
  unit’s own gen), not the Track-4-era invariant the comment cited.
  Finding 1 rewritten with its full falsification history (true as
  written 2026-08-15 → falsified in the Walker/BJL era, the S668 census
  measured 56 `__proj_` nodes → dead again S678, absence pinned at
  `test_comparePedigreeStructure.R:687`), dated S698. The item’s second
  question answered: the sibling `test_addRectilinearWaypoints.R`
  0-projection expectation is general (0 on every fixture, by
  construction), not fixture-specific — its S678 CHANGED note already
  states the current mechanism, so no edit was needed there.
- **(B) 5-pair proximity residual (found S667) closed
  resolved-by-construction:** all 5 named pairs re-measured under the QP
  engine by real-id occurrence sweep (S667’s `__dup_X_n` indices are
  allocation-order artifacts and no longer denote the same occurrences —
  Learning 751): minimum same-row named-pair distance is now 480 px
  (`M0YNUR` vs `__dup_L31S6S_4`) against a 25 px radius-sum limit — the
  four S667-measured 10–22 px overlaps and the exact-clearance tie are
  gone; `__union_43` vs every `WDBGPF` occurrence ≥ 3,540 px. An
  independent global class (a) scan found 0 same-row visible-symbol
  overlaps on the whole fixture, agreeing with the committed S696 census
  baseline (a=0, b=8 off-centre, c all curved-chord/c1=c2=0, d=1
  adjacent-only). No code change — the item’s own S687 forward-carry
  anticipated exactly this close.
- **(C) `vignettes/articles/kinship2-fidelity-validation.qmd` mate-line
  claims (2 sites — the Track B “what matches” paragraph, lines 150–163,
  AND the same claim repeated in Caveats):** live-measured on the Track
  B 16-subject fixture: all 4 union dots sit at exactly the midpoint of
  their two mates (union − midpoint = 0.00 px; mates 120 px = 1 minSep
  apart), matching the committed S675 QP-era `trackB-nprc-full.png` —
  which the prose directly contradicted (“at the sire’s own symbol”).
  Both sites rewritten: the two packages’ mate-line conventions now
  agree (side-by-side pair, midpoint descent); the remaining differences
  are the union-dot marker itself (kinship2 draws none; visibility kept
  per issue \#161) and the off-centre residual where minSep floors bind
  (8 of 237 unions on the real 375 fixture, census baseline).
- **Verification:** spell check clean; `test_wordlist_coverage.R` green
  directly (run before the full suite per Learning 750); `lintr` 0 on
  the touched test file (package loaded); edited test file green; full
  unfiltered clean regression **2,370 blocks, failed=0, error=0,
  skipped=182** (the S696/S697 baseline exactly). 3 `BACKLOG.md`
  Housekeeping blocks removed per the completed-item convention. No
  GitHub issue was ever filed for any of the three items → no issue
  close owed. NEWS/citation/tutorial/a2interactive/`_pkgdown` checklists
  N/A by inspection (no behavior change, no new export, statistic, or
  user-facing control; the article edit IS the tutorial/article
  checklist’s own artifact, corrected).

### 2026-09-17 · \[ad hoc\] S698 Phase 0: record CHANGELOG.md entry for S697’s close-out commits (reconcile-on-read)

- Phase 0 ledger reconcile found 2 commits since `CHANGELOG.md`’s
  frontier (`20088807`) with no ledger entry of their own — the same
  self-reference shape this project’s precedent already names repeatedly
  (S639→S643, S647): `daafea9f` (S697’s own close-out commit, writing
  the final `SESSION_NOTES.md` handoff + S696 evaluation and completing
  the `HANDOFFS.md` receipt) and `44f1642a` (recording that close-out
  commit’s sha in the receipt’s `commit:` field, self-reconcile). Both
  postdate `20088807`, the commit that wrote the ledger’s own S697 entry
  (directly below) — that entry necessarily narrates the close-out
  actions *before* the commits performing them existed, so neither later
  commit could cite itself. The substance of both is already described
  in the existing S697 entry; this is a pure reconcile-on-read backfill
  — no content beyond what `daafea9f`/`44f1642a`’s own diffs already
  show. `HANDOFFS.md`’s own frontier has no gap (`44f1642a` is already
  its last touching commit; receipt `status: complete`).

### 2026-09-17 · \[BL-qpPhase4\] S697: QP Migration Path Phase 4 cleanup — `R/` doc-comments describe the QP engine (closes the joint-QP-solver migration plan’s 4-phase path)

- **Deliverable (owner-picked via `AskUserQuestion` at Phase 0;
  DEVELOPMENT_WORKSTREAM, docs-only — no TDD phases, per the
  S692/S694/S695 precedent):** the migration plan’s last open scope
  discharged. Phase 4’s nominal code/constant deletion and NEWS entry
  had already landed at earlier boundaries (S674 deleted the five
  passes, their `.kMax*` constants, and every dead call site at the
  Phase 2 cutover; the NEWS entry landed S675), leaving the doc-comment
  sweep. Commits: claim `b81bfecc`, deliverable `43ed9a24`.
- **Sweep (7 stale sites, all `R/makePedigreeDiagramData.R`):** the S667
  component comment (“every collision-avoidance mechanism run unchanged
  per family” + a named deleted-pass reference); the `qualifies()`
  relocation comment (claimed the deleted `b1AnchorRelativeX()` branch
  still calls it — it is now the S666 conditional-shift pass’s only
  caller); the second-`sweepMinSepBackstop()` rationale (named the
  deleted pass); the S666 chain-rule comment (“Tier
  3/collision-avoidance … also unchanged”); the orphaned 39-line S647
  block describing the deleted shared de-collision pass in present tense
  (removed; its identity folded into the Phase 2 replacement comment,
  which no longer names the deleted symbol); and
  [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
  exported roxygen (attributed the issue-#145 male-left rule to the
  deleted “Tier 3 formula (S8.1)”; now describes the seeding rules +
  `.solveJointQP()` row-order preservation actually enforcing it —
  `man/makePedigreeMatingLayout.Rd` regenerated). Explicitly historical
  enumerations keep their past-tense pass vocabulary.
- **Verification:** the plan’s own Phase 4 gate grep
  (`deCollideIndividualPoints|kMaxUnionPush|kMaxB1ProximityPush` in
  `R/`) returns nothing; `lintr` 0 on the touched file (package loaded);
  full clean regression **2,370 blocks, failed=0, error=0, skipped=182**
  (the S696 baseline exactly) — the first unfiltered run caught failed=1
  in `test_wordlist_coverage.R` because the roxygen rewrite’s “QP” was
  the acronym’s first exported-roxygen (Rd-rendered) use; `QP` added to
  `inst/WORDLIST` (BJL/LOD precedent), gate re-run green (Learning 750).
  Phase 4 record written into the plan doc §Migration Path; `BACKLOG.md`
  Up Next item removed per the completed-item convention. No GitHub
  issue was ever filed for the implementation, so no issue close is
  owed.

### 2026-09-17 · \[ad hoc\] S696: pushed the 76-commit S685–S696 backlog to origin/master — all 4 push-triggered workflows green first-try, no CI break to fix or defer

- **Owner-directed post-close-out action** (“push”, next-step D of the
  S696 handoff): `git push origin master` (`ab00ea49..86e852d1`, 76
  commits) — first CI exposure for everything since S684’s push,
  spanning S685’s disc-aware jog offsets, S688–S690’s Shape A
  root-subtree ordering chain, the S691–S695 exemplar/article/docs
  sessions, and this session’s ascender-stub fix.
- **CI shepherded to terminal on `86e852d1` (poll-observed, every
  conclusion seen, not assumed):** lint success (run 35257056404),
  test-coverage success (35257056632), pkgdown success (35257056707),
  R-CMD-check success (35257056403). **No fix-or-defer action owed**
  under the CI-break tracking convention (`CLAUDE.md`, S636).
- This ledger-entry commit itself rides a follow-up push; its own 4
  workflow runs are the disclosed in-progress residual for the next
  session’s Phase 0 CI check (the same shape S684’s push entry left for
  S685).

### 2026-09-17 · \[BL-ascenderStub\] S696: ascender-stub cosmetic fix — jog corridors rejoin the kid directly (found S679, owner visual gate)

- **Deliverable (owner-picked via `AskUserQuestion` at Phase 0; standing
  pedigree-fidelity directive; DEVELOPMENT_WORKSTREAM, full TDD RED →
  GREEN, REFACTOR gate posed and owner-skipped):**
  `.resolveEdgeNodeCollisions()` no longer draws dangling “ascender”
  stubs above sibship bars. Root cause located in data and
  crop-verified: a corridor rejoining an invisible `__bar_<kid>` point
  whose bar-level ink was entirely rerouted drew the riser collinear
  with the kid descent’s top — 9–27 px of duplicate ink ending mid-air
  at bar level (84 stubs on the real 375 fixture; 15 on the twins trim;
  2 on the first_cousin exemplar). S679’s candidate 2 (“suppress the
  riser on zero-width bars”) refuted by measurement — a zero-width bar
  can never jog. Approach (direct rejoin) and all TDD phase transitions
  owner-ratified via `AskUserQuestion`; owner visual gate ACCEPTED both
  changed renders. Commits: claim `2e5eee98`, RED `d3e15162`, GREEN
  `e6fb81a7`, renders `eeae9914`, census `eeacd06c`, NEWS `05c3313e`.
- **Fix (spike-measured PRE-RED, then TDD):** when a rerouted edge’s
  endpoint is invisible (size 0/NA) and its only surviving edge is one
  vertical descent to a non-jog node, the corridor connects straight to
  the kid; riser + descent dropped, bar point left unreferenced and
  unmoved. Kid-adjacent segments always run waypoint → kid (the
  parent/child-side direction convention); the corridor is emitted
  reversed when only the FROM side is bypassed so jog nodes keep
  1-in/1-out. Suite-side: the D-2 walker collapses only 1-in/1-out jogs
  and bridges parentless components through their shared kid;
  `first_cousin` rectilinearEdges re-pinned 33 → 31 (`CHANGED S696`).
- **Verification:** stubs 84 → 0 (new standing suite invariant, 6 new
  test blocks); zero node movement; census findings byte-identical (CSV
  refreshed — also folds in S690’s never-committed deltas); full clean
  regression **2,370 blocks, failed=0, error=0**; the S685 inertness pin
  passed UNCHANGED (bypass excludes degree-0 endpoints); `lintr` 0 on
  touched files; spell check clean; live E2E pedigree module 16/16
  blocks, 55 expectations, 0 failed (`NPRC_RUN_E2E=true`); twins
  screenshot recaptured through the real app (pixel diff purely
  subtractive); NEWS.Rmd plain-language entry. BACKLOG item removed per
  the completed-item convention; Learning 749.

### 2026-09-17 · \[BL-shapeAPhase3\] S695: Shape A Phase 3 — docs & follow-ups (closes the root-subtree ordering chain: design S688, Phase 1 S689, Phase 2 S690, Phase 3 S695)

- **Deliverable (owner-picked via `AskUserQuestion` at Phase 0; standing
  pedigree-fidelity directive; DEVELOPMENT_WORKSTREAM, docs-only — no
  TDD phases, per the S692/S694 precedent):** the design’s own Phase 3
  spec discharged in full. Commits `52a9b7da` (screenshot), `1d33729b`
  (NEWS), `9727c210` (dispositions).
- **Screenshots — digest-driven minimal recapture:** layout digests
  (`scratchpad/s683_screenshotDigests.R`) run at HEAD and, via a
  temporary git worktree with `R_LIBS` pointed at the renv cache
  library, at `4853639f` (S683’s recapture — the commit at which all 5
  Diagram-tab screenshots were last current). Only the twins trim
  changed (both edge styles); base/show_names/affected trims
  digest-identical, so only `diagram_twin_connectors.png` was recaptured
  (the other 4 untouched, no spurious PNG churn). The new layout was
  ground-truth-verified before the gate: all 42 parent-child triples
  reconstruct exactly from the rendered union edges (sex-free pair trace
  — the S691 helper’s M/F assumption false-alarms on this fixture’s
  NA-sex parent `EE4BJC`), and all 39 rectilinear routing nets confine
  to one union’s family. Owner visual review: **accepted**. Reference
  images `trackB-nprc-*`/`trackC-nprc-*` untouched per the item (S690
  re-proved identity / bitwise-identical layout). See Learning 748.
- **NEWS.Rmd:** plain-language entry (S628 criterion) appended to the
  Pedigree Diagram section — branches sharing animals now sit near each
  other, curved duplicate connectors about a quarter shorter and
  crossing less, a fraction of a second more layout time on very large
  pedigrees; `NEWS.md` re-rendered (diff = the entry only);
  [`spelling::spell_check_package()`](https://docs.ropensci.org/spelling//reference/spell_check_package.html)
  clean, no WORDLIST change needed.
- **Open-Question dispositions** recorded in
  `docs/planning/pedigree-diagram-root-subtree-ordering-plan.md` (new
  `### Dispositions` section, matching the provisional-order plan’s
  precedent): spectral seed NOT TAKEN (S689 gate chose RCM); adaptive QP
  calibration NOT PURSUED; kill switch DECLINED (unconditional pass;
  S690/S691 visual gates found no worsened shape); 1,500-node-cap
  scaling OPEN (no fixture); Track C bitwise identity RESOLVED (guard
  declined S689, then measured max \|dx\| = 0 at S690); ~2,300 px
  mean-span ceiling ACCEPTED RESIDUAL (routing/duplicate-policy work,
  out of scope). Plus the forward-carried SLN0TF class-(d) acceptance /
  alignped3-stays-NOT-PURSUED note from the removed BACKLOG blocks.
- **Checklists:** `a2interactive.Rmd`, citation, `_pkgdown.yml`, lint —
  all N/A by inspection (no new export, statistic, or tracked `.R`
  change). NEWS same-session checklist discharged above. `BACKLOG.md`:
  the Shape A Phase 3 block removed per the completed-item convention
  (this entry + the design doc’s Dispositions section are the durable
  record). After this session no open BACKLOG item depends on scratchpad
  files.
- **Verification:** full clean regression (unfiltered, `NOT_CRAN`) —
  **2,364 blocks, failed=0, error=0**, exactly the S694 baseline (no
  test file touched); the screenshot recapture itself exercised the live
  app end-to-end (AppDriver: upload, QC, navigate, focal-trim, capture)
  under the wired Shape A engine.

### 2026-09-17 · \[BL-exemplarArticle\] S694: “Reading classic breeding structures” — the 5 exemplar pedigrees added to the pedigree-diagram article (closes the S691 follow-up chain)

- **Deliverable (owner-picked via `AskUserQuestion` at Phase 0; standing
  pedigree-fidelity directive; DEVELOPMENT_WORKSTREAM, docs-only — no
  TDD phases, per the S692 data+docs precedent):** new
  `vignettes/articles/pedigree-diagram.qmd` section walking through each
  classic structure’s Rectilinear diagram (full-sibling, backcross,
  half-sibling, first-cousin, linebreeding) with a plain-language
  reading guide per structure — the dashed duplicate-occurrence line and
  the vermillion consanguineous mate-line pair — plus a
  [`system.file()`](https://rdrr.io/r/base/system.file.html) snippet for
  loading an exemplar into the app and a See-also line. Every stated
  id/φ/F fact comes from the S693 test-pinned spec (F = 0.25, 0.25,
  0.125, 0.0625, 0.03125), never hand-derived; the prose claims no
  crossing-free rendering for linebreeding/half-sib (their collision
  warning was owner-accepted at S691’s visual gate). Commits `811160a8`
  (images), `b8ada1d9` (article + regeneration script), `10337bb5`
  (NEWS/WORDLIST).
- **Images regenerated, not copied — and byte-identical to the approved
  renders:** the new tracked script
  `vignettes/articles/pedigree-diagram-exemplar-renders.R` (adapted from
  the untracked `scratchpad/s691_render.R`) renders the 5 shipped
  `inst/extdata/examples/example_pedigree_*.csv` files through the HEAD
  engine into `vignettes/articles/pedigree-diagram-img/`; all five PNGs
  proved byte-identical (`cmp`) to the S691 owner-approved scratchpad
  renders, so the S691 visual approval carries over with no re-review,
  and node/edge counts matched the pinned table (33/35/26/33/30) at
  render time. The script documents the exactly-two expected collision
  warnings (linebreeding, half_sib) so any other warning set reads as an
  engine change requiring re-review before committing images. The
  article session’s dependency on the untracked scratchpad renders is
  now over.
- **Checklists:** tutorial/article (this session IS it) and NEWS.Rmd
  same-session both discharged — plain-language entry (S628 criterion)
  appended to the Pedigree Diagram section, `NEWS.md` re-rendered with
  the entry as the only diff; wordlist gate run locally pre-push:
  [`spelling::spell_check_package()`](https://docs.ropensci.org/spelling//reference/spell_check_package.html)
  flagged 13 words in the new article prose (the exemplar animal-id
  alphabetic prefixes plus “backcross”), added to `inst/WORDLIST`, test
  green (Learning 747). N/A by inspection: citation checklist (no new
  statistic), `a2interactive.Rmd`/`_pkgdown.yml` reference coverage (no
  new export; the article itself was already registered at
  `_pkgdown.yml:63`).
- **Verification:** `quarto render` clean (twice, after the final prose
  pass);
  [`spelling::spell_check_package()`](https://docs.ropensci.org/spelling//reference/spell_check_package.html)
  fully clean; full clean regression (unfiltered, `NOT_CRAN`) **2,364
  blocks, failed=0, error=0** — exactly the S693 baseline (no test file
  touched).
