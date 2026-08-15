# Handoff Receipts — durable close-out proof

The cumulative, append-only record of **each session's close-out handoff**, distilled into a
machine-checkable block. It is the durable answer to *"was close-out actually performed, and what
did the session hand its successor?"* — the part of close-out that otherwise lives only in the
transient `SESSION_NOTES.md` (overwritten every session) or the spoken report (which leaves no file
at all).

One `handoff` block per **session** (not per commit), newest on top. The canonical-only
`bin/check-handoff` (copy it into your `bin/` if you want the structural check) asserts each block is
present and structurally complete; the next session's Phase 0 reconcile greps this file for a missing
or still-`pending` receipt and backfills it — that reconcile, not the checker, is the dependable
backstop, so the discipline needs no tooling. Together — a write-step at close-out **and** a
reconcile-on-read backstop — this makes a skipped handoff *detectable* rather than silent.

> **A green `bin/check-handoff` is not a good handoff.** The check verifies presence and structure,
> never semantic quality. Faithfulness is still scored 1–10 by the next session (Phase 3A). A
> well-formed but hollow receipt passes the check and is caught only by that human judgement.

## How to write a receipt

**At Phase 1B (claim the session)** — write the stub block below with `status: pending`, filling what
you can, and commit it with your session-claim commit. This committed `pending` block is the crash
breadcrumb: if the session ends before close-out, the next session's Phase 0 reconcile sees it.

**At Phase 3D (close-out)** — overwrite that block in place to `status: complete` and fill every
field. The block must satisfy all six Minimum Handoff Requirements (`SESSION_RUNNER.md` §3D).

## Format — a fenced `handoff` block

````
```handoff
session: S<N>
date: YYYY-MM-DD
status: <pending | complete>
self_score: <1-10>
predecessor_score: <1-10>
active_task: <current state>
what_was_done: <what you did, including a commit sha — or the literal `pending`>
next_steps: <specific and actionable; never "pick next from backlog">
key_files: <each entry carries a path:line token, e.g. SessionManager.java:245>
gotchas: <traps the next session should watch for>
runtime_smoke: <a run result, or "n/a — docs-only", or "impossible: <reason>">
changelog_ref: <PR #N or a short-sha into CHANGELOG.md>
commit: <short-sha — or `pending` until the next session reconciles it>
```
<free-text prose: the durable proxy for the Phase 3G spoken report, plus the +/- self-score breakdown>

Write clean `key: value` lines — no inline `#` comments (a `#` is a literal value character,
as in `changelog_ref: PR #52`). The keys are the six Phase 3D Minimum Handoff Requirements (the sixth
*is* `self_score`) plus `predecessor_score` (the Phase 3A evaluation) and a little metadata. `status`
is `pending` at the Phase 1B claim and `complete` at
close-out; a third value, `reconciled`, is written *only* by a later session's Phase 0 reconcile
when it reconstructs a receipt a crashed session never completed — you never write it yourself.
````

`self_score` and `predecessor_score` are distinct keys so one can never stand in for the other; omit
`predecessor_score` on Session 1 (there is no predecessor to score). `commit: pending` and
`what_was_done: pending` are legal at write time (the receipt ships in the very commit whose sha it
would name); the next session reconciles them to real shas.

## Size, and when to archive

This file gains a receipt every session and Phase 0 reads it every session, so it carries the same
size discipline as `CHANGELOG.md`: **two caps, two distinct failure modes, fire if either fires,
stop only when both stop conditions hold.**

| Cap | Protects against | Form | Fire when | Cut until |
|---|---|---|---|---|
| **Lines** — ~2,000, the agent `Read` truncation cap | **silent truncation**: a read past the cap returns no error and no marker | a **rate** | headroom < **15** receipts | headroom > **30** |
| **Bytes** — a per-file budget, default **65,536 B** (64 KB) | **context tax**: every session pays for the whole file, every time | a **level with hysteresis** | `size > budget` | `size ≤ ½ × budget` |

**Run this rather than estimating it:**

```sh
python3 methodology_trim.py --file HANDOFFS.md --check
```

`--check` evaluates both conditions and never writes. `--write` performs the trim, refuses unless it
can prove the split lossless, and **neither commits nor stages** — it leaves this file modified and
the new shard *untracked*, and leaves the commit to you (`git add HANDOFFS.md docs/archive/`).

An archive is a **shard**: a new frozen file, same format, same newest-on-top order.

- **Path: `docs/archive/HANDOFFS-through-<CUT-KEY>.md`.** Both halves are load-bearing — the
  directory keeps the shard from shadowing this file, and the `HANDOFFS-` prefix is what the
  trigger's own glob looks for. A shard named otherwise is silently invisible to it.
- **This file keeps one short pointer** naming each shard, the span it covers and how many receipts
  it holds — with the command that recomputes those counts, never a hand-maintained number.
- **The shard back-links here and states only facts about itself.** It must not restate a
  forward-looking rule: a shard is frozen, so a rule copied into one cannot be corrected when the
  live rule moves.
- **After a split, anything that enumerates receipts must span both** — `HANDOFFS.md
  docs/archive/HANDOFFS-*.md` — or it silently counts a shrunken population.

If a `CHANGELOG.md` sits beside this file, its own **Size, and when to archive** section carries the
reasoning both files share: why the line cap must be a rate, why the byte cap cannot be one, and how
to choose the budget. Everything needed to *act* is here.

What is specific to *this* file, and gets receipts wrong if assumed:

- **A record is a `handoff` block *plus the prose beneath it*, not the fence alone.** The self-score
  and predecessor-score paragraphs sit outside the fence and belong to the receipt above them. A
  fence-only cut severs every receipt from its own scoring.
- **Archive oldest-first by position, never by sorting on `session:`.** Two independent `S<N>`
  sequences can share one ledger — a fork and its upstream each running their own counter — and
  their numbers collide. The record's identity is **session + date**.
- **A trim leaves the newest-receipt check alone and moves what the older-receipt checks see.**
  Phase 0 reconcile is frontier-based and a structural checker applies the full schema to the newest
  receipt only, so neither is disturbed. Its other passes are not so confined — an answer-slot rule
  reads every receipt below the newest, and a locator-form rule reads every receipt in the file. So
  after a trim, **run the checker against each shard as well**, and recompute any "all N older
  receipts" count from the files rather than carrying it forward.
- **Never trim to zero receipts.** An empty receipt ledger is indistinguishable from a broken one.
- **A shard freezes, with one exception this file needs:** a `commit:` answer slot may still be
  reconciled inside an archived receipt, because that field was always going to be filled by a later
  session. Nothing else in a shard is rewritten.

**Archived 181 record(s), 2026-07-08 → 2026-08-10** into [`docs/archive/HANDOFFS-through-2026-08-10.md`](docs/archive/HANDOFFS-through-2026-08-10.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-10.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-10.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 39 record(s), 2026-08-10 → 2026-08-12** into [`docs/archive/HANDOFFS-through-2026-08-12.md`](docs/archive/HANDOFFS-through-2026-08-12.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-12.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-12.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 17 record(s), 2026-08-12 → 2026-08-13** into [`docs/archive/HANDOFFS-through-2026-08-13.md`](docs/archive/HANDOFFS-through-2026-08-13.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-13.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-13.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 21 record(s), 2026-08-13 → 2026-08-14** into [`docs/archive/HANDOFFS-through-2026-08-14.md`](docs/archive/HANDOFFS-through-2026-08-14.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

This file currently holds **2** receipt(s). Computed by `methodology_trim.py` on every
`--check`/`--write` run, never hand-maintained.

```handoff
session: S584
date: 2026-08-15
status: complete
self_score: 8
predecessor_score: 9
active_task: Diagnose the red scheduled shinytest2.yaml CI run (red 3 consecutive nights,
  2026-08-12/13/14) -- DONE. Root cause found, reproduced with the CI's literal command, scoped by
  a call-graph sweep, and (owner-directed at a pre-RED gate) fixed with a regression guard. All
  local verification green; NOT yet observable in CI (see gotchas).
what_was_done: Root cause -- .github/workflows/shinytest2.yaml:161-183 runs the E2E tier via
  `Rscript -e testthat::test_dir(...)` per module group, bypassing tests/testthat.R, the only file
  that calls library(nprcgenekeepr). test_dir() does not attach the package under test and no
  helper-/setup-.R does either, so package exports are absent in that process. Fix -- qualified the
  one offending call (nprcgenekeepr::makeExamplePedigreeFile) and added
  tests/testthat/test_e2e_package_qualification.R, a static guard that fails if ANY
  test-{app,e2e}-*.R file calls a package export bare. Verified 4 ways -- guard GREEN; the
  previously-failing group rerun with the EXACT CI command now passes 8/8 in the un-attached
  environment; full clean regression 5,958 passed / 1 pre-existing unrelated failure
  (test_wordlist_coverage.R) / 0 errors; lintr 0 lints on touched files. devtools::check() 1 error /
  0 warnings / 1 note -- BOTH pre-existing, provenance verified (see gotchas), neither caused here.
  Commits 9b23075e (claim) and the close-out commit.
next_steps: The push question is RESOLVED -- owner directed it in-session, 148 commits pushed,
  master == origin/master, and shinytest2 confirmed green (run 31868762486). THE TOP PRIORITY IS NOW
  CI TRIAGE: the push revealed 3 pre-existing reds, each filed as its own READY BACKLOG.md
  Housekeeping item and each a separate deliverable. In recommended pickup order (cheapest and most
  mechanical first): (1) pkgdown -- add `  - articles/pedigree-diagram` to _pkgdown.yml's
  articles/contents list, one line, scope verified in both directions (S560 gap; the docs site is
  currently not deploying at all, so this has the widest user-visible blast radius); (2)
  R-CMD-check -- add the flagged words to inst/WORDLIST, remembering the test_dir read flags 4
  (matings, Rectilinear's, runnable, visNetwork's) while check() flags 2, so cover all 4 (S573 gap,
  red on all 5 platforms); (3) lint -- R/kinship.R:127,131,133, per-finding choice between a real
  fix and a documented # nolint; this one touches R/ so it is Strict-TDD territory and behavior must
  be provably unchanged (S564 gap). Do NOT bundle these: three files, three fixes, three
  deliverables. Then the pre-existing queue: the 3 pedigree-diagram-screenshots.R sibling
  screenshots that
  may share pb_diagram_legend.png's staleness mechanism (found S582, READY, Effort S -- the
  cheapest remaining item); SESSION_NOTES.md archive (dashboard's only HIGH risk, trim trigger
  fires at 3,437 lines / 290,404 B, and the fence-scanner defect that previously blocked it appears
  resolved -- verify the SRF refusal before --write); a full-fixture sweep for the S583
  union-outside-parents-span finding (READY, Effort S); sibling subtree-width asymmetry design
  session (S576, Effort L); BACKLOG.md ledger-size housekeeping, final Genetic-metrics section
  (S518, Effort L); #148 MHC scope-narrowing (DECISION NEEDED); NPRC outreach (DECISION NEEDED).
key_files: tests/testthat/test-e2e-mate-pair-analysis-module.R:61 (the fixed call, now
  nprcgenekeepr::-qualified with a comment saying why it must stay that way -- it was at :58, the
  line CI's error names, before this session's 3 comment lines shifted it);
  tests/testthat/test_e2e_package_qualification.R:1-40 (the new guard, with the full mechanism
  written up in its header comment); .github/workflows/shinytest2.yaml:161-183 (the per-group
  Rscript loop that never attaches the package -- the actual source of the divergence);
  tests/testthat.R:4 (the library(nprcgenekeepr) call CI bypasses);
  tests/testthat/test_shinytest2_workflow_coverage.R (the sibling guard this one mirrors).
gotchas: (1) `gh run view <id> --log` and `--log-failed` both return EMPTY for these runs; the only
  path that worked was `gh api repos/rmsharp/nprcgenekeepr/actions/jobs/<jobId>/logs`. Get the job
  id from `gh run view <runId>`. (2) When reproducing the CI command locally, do NOT copy
  RENV_CONFIG_AUTOLOADER_ENABLED=false from the workflow -- CI installs to the site library, but
  locally it strips the renv library from .libPaths(), so create_test_app() returns "" and the run
  fails at a DIFFERENT line for an unrelated reason, masking the real defect. This cost a wasted
  cycle. (3) `gh run list --branch master --limit 10` truncates below the first failure and
  undercounted this streak as 2 runs when it was 3 -- use `--workflow=shinytest2.yaml` to see a
  full streak once you know which workflow is red. (4) A scheduled run's log records the sha it
  checked out; ALWAYS compare it to local HEAD before diagnosing (`git rev-list --count
  <sha>..HEAD`). Here it was 145 behind, which made a correct-at-HEAD CI group look like a defect.
  (5) `devtools::check()` is currently RED on master and has been since S573 -- 1 error, from
  test_wordlist_coverage.R flagging `matings`/`visNetwork's` in NEWS.md. Do NOT read that error as
  something your own session broke; confirm provenance with `git status --porcelain NEWS.md
  inst/WORDLIST` and `git log -S'<word>' -- NEWS.md` before spending time on it. Filed as its own
  BACKLOG.md item (Effort S -- a one-line inst/WORDLIST addition).
runtime_smoke: PASS, locally AND in CI. Locally the previously-failing E2E group was rerun end to
  end against the live app (real Chrome via shinytest2/AppDriver, real pedigree upload, real Marker
  Genetics genotype upload, real Mate Pair Analysis run) in the exact un-attached environment CI
  uses: files=1 passed=8 failed=0 skipped=0 error=0. Then CONFIRMED in CI after the owner-directed
  push -- shinytest2 run 31868762486 SUCCESS, same group same numbers, all 19 groups green.
changelog_ref: 9b23075e (this session's claim entry -- see the 2026-08-15 section, "S584:" entries)
commit: f36146ea (close-out); 66593c61 (the fix + guard); 9b23075e (claim)
```

```handoff
session: S583
date: 2026-08-15
status: complete
self_score: 9
predecessor_score: 9
active_task: File a new BACKLOG.md finding -- a mating union can be positioned entirely outside
  its own two parents' x-span (not merely off-center), found live via a user question about
  pb_diagram_legend.png, confirmed via direct kinship2 comparison -- DONE, filed.
what_was_done: Reproduced the exact scenario live via makePedigreeMatingLayout() on
  trimPedigree(c("8LKBV9","FJIB3R","GA204Z"), obfuscated_rhesus_mhc_ped.csv) -- confirmed 5A6DFT
  x=-60, 8DKELJ x=60, their union x=120 (outside the parent span). Built the identical pedigree in
  kinship2::pedigree()/plot.pedigree() -- confirmed kinship2 centers the descent line between
  parents unconditionally, a real divergence. Presented both findings + asked the user how to
  proceed via AskUserQuestion; user picked "file as a new BACKLOG item." Filed in BACKLOG.md
  (found S583, placed after the related S576 item, explicit about how it differs) and
  PROJECT_LEARNINGS.md Learning 590. No code changed.
next_steps: This finding (union-outside-parents-span, found S583) needs its own design session
  before any fix -- reconciling Track 6's "center on children" goal with kinship2's "never leave
  the parents' span" invariant without reopening Track 6's ratified formula wholesale. A quick
  sweep of the full 375-animal fixture (mirroring S576's own "9/251 edges" measurement style)
  would strengthen the filed item's scope claim beyond the single reproduced example. Otherwise,
  BACKLOG.md's remaining numbered items are unchanged from S582's own handoff: sibling
  subtree-width asymmetry (READY but likely needs its own design session, found S576); BACKLOG.md
  ledger-size housekeeping (READY, Effort L, found S518); #148 MHC scope-narrowing conversation
  (DECISION NEEDED); NPRC outreach & announcement plan (DECISION NEEDED); the 3
  pedigree-diagram-screenshots.R sibling screenshots that may share pb_diagram_legend.png's own
  staleness mechanism (found S582, unverified). Separately: scheduled shinytest2.yaml CI run still
  red (3+ consecutive days as of this session), unchanged/undiagnosed.
key_files: R/makePedigreeDiagramData.R:966-975 (finalUnitX -- the union-x-from-children formula
  with the parent-distance blind spot); docs/planning/pedigree-diagram-track6-child-centered-
  union-position-plan.md §1.4/§2.4 (the invariant and verification plan that never measured
  distance-to-parents); BACKLOG.md (new item filed directly after the S576 finding);
  PROJECT_LEARNINGS.md Learning 590.
gotchas: kinship2::pedigree()'s dadid/momid arguments need explicit character "0" (via
  missid = "0") for missing parents -- ifelse(is.na(x), 0, x) against a character vector silently
  produces a type that fails kinship2's own id-set validation with a confusing "value not found in
  id list" error; build the missing-parent vector with a character "0" literal from the start. Also:
  when investigating a live user-reported visual, reproduce the EXACT data (same fixture, same
  focal ids) through the actual layout function for real coordinates -- don't estimate from the
  screenshot pixel positions.
runtime_smoke: n/a -- documentation-only finding, no runtime code touched.
changelog_ref: 918e7364 (S582's own last commit before this session's 2 new CHANGELOG entries --
  see the 2026-08-15 section, "S583:" prefixed entries)
commit: ce830dbe
```

```handoff
session: S582
date: 2026-08-15
status: complete
self_score: 9
predecessor_score: 9
active_task: Reshoot shiny_app_use/pb_diagram_legend.png (BACKLOG.md, found S574) -- DONE. New
  image shows Rectilinear (kinship2-style) pre-selected with right-angle edge routing, matching
  the Diagram tab's current zero-interaction default (flipped from "direct" by Track 2, S574).
what_was_done: Located the canonical capture mechanism (vignettes/articles/
  pedigree-diagram-screenshots.R's "Base fixture" step, which never sets pedigreeEdgeStyle).
  Wrote a standalone scratch script reproducing only that step through its first shot() (not the
  full canonical script, to avoid touching the other 4 committed screenshots) and ran it
  (NOT_CRAN=true Rscript ...) -- captured successfully. Diffed the new PNG against the prior
  committed one (git show 2b3e8ef6:...) -- confirmed only the radio-button/routing state changed.
  Build-equivalent: pkgdown::build_article() for both articles/pedigree-diagram and
  articles/colony-manager-guide rendered clean; MD5-confirmed the built HTML embeds the new PNG,
  not a stale copy. Render litter removed before commit. BACKLOG.md item marked [x]/RESOLVED;
  PROJECT_LEARNINGS.md Learning 589 added. Commit pending (this close-out).
next_steps: BACKLOG.md's remaining numbered items (order this session's Phase 0 presented, none
  else picked): a new item this session filed -- verify whether pedigree-diagram-screenshots.R's
  other 3 non-base-fixture screenshots (diagram_show_names.png, diagram_affected_shading.png,
  diagram_twin_connectors.png) are ALSO stale by the same never-sets-pedigreeEdgeStyle mechanism
  (found S582, not verified either way -- open each and compare against a fresh capture); Pedigree
  Diagram sibling subtree-width asymmetry (READY but likely needs its own design session, found
  S576); BACKLOG.md ledger-size housekeeping -- editorial compression (READY, Effort L, found
  S518); #148 MHC scope-narrowing conversation (DECISION NEEDED); NPRC outreach & announcement
  plan (DECISION NEEDED, owner review). Separately: scheduled shinytest2.yaml CI run still red on
  2026-08-13 and 2026-08-14 (2 consecutive days as of this session's own Phase 0 check) --
  unchanged/undiagnosed across 2 sessions now, worth a dedicated diagnose session soon.
  SESSION_NOTES.md is 3,300+ lines, past the 2,000-line HIGH-risk cap -- do NOT run
  methodology_trim.py --write on it until the documented fence-scanner defect is fixed.
key_files: vignettes/articles/shiny_app_use/pb_diagram_legend.png (the regenerated screenshot);
  vignettes/articles/pedigree-diagram-screenshots.R:139-163 (the canonical "Base fixture" capture
  step this session's standalone script reproduced); R/modPedigree.R:419-429 (.currentEdgeStyle(),
  confirms the live default and that its own comment is now stale -- not fixed, noted only);
  BACKLOG.md (S574 item marked RESOLVED S582; new incidental-finding item filed just below it);
  PROJECT_LEARNINGS.md Learning 589 (the generalizable "sibling capture steps are unverified
  peers" pattern).
gotchas: A UI-default flip silently changes what EVERY zero-interaction capture step in a shared
  script renders, not just the one instance someone happened to notice and report -- grep the
  script for the changed input name across ALL its steps, not just the flagged one, before
  assuming the fix is complete. Also: R/modPedigree.R:419-421's own comment above
  .currentEdgeStyle() still says the default is "direct" -- the CODE is correct (returns
  "rectilinear"), only the comment is stale; a future session touching this function should fix
  the comment too, not just be aware the code is right.
runtime_smoke: Documentation-asset-only change (no Shiny runtime behavior touched), so the
  relevant "runtime" is the doc build pipeline, not the live app. pkgdown::build_article() for
  both consuming articles rendered clean via quarto render; MD5-verified the built HTML actually
  embeds the new image, not a stale cached one -- the real-consumer verification this project's
  own Learning 443 precedent calls for.
changelog_ref: a98010d9 (S581's own last CHANGELOG entry before this session's 2 new entries --
  see the 2026-08-14/2026-08-15 sections, "S582:" prefixed entries)
commit: 3e8870d2
```

```handoff
session: S581
date: 2026-08-14
status: complete
self_score: 9
predecessor_score: 9
active_task: Locale-dependent order() tie-break sweep (BACKLOG.md, found S578) -- DONE. 4 real
  hits fixed (method="radix"); 2 initially-flagged hits corrected to false positives via
  empirical verification, documented in-code, no behavior change.
what_was_done: Fresh grep -n "order(" R/*.R (26 sites), classified all. RED (afe39632): 4 real
  hits confirmed via divergence testing, tests added to test_orderReport.R/test_qcStudbook.R/
  test_modBreedingGroups.R (new bgGroupView testServer test). GREEN (5583a621): method="radix"
  added to orderReport.R:81,93, qcStudbook.R:323, modBreedingGroups.R:690. REFACTOR (15450f0d):
  explanatory comments (no behavior change) on kinshipMatrixToKValues.R/computeGenomicROH.R
  documenting why they're false positives. Verification: 4 targeted tests GREEN; full clean
  regression 1 pre-existing failure unrelated, 0 errors; 0 lints (project's own .lintr config);
  devtools::check() 0/0/1 pre-existing NOTE; live E2E (NPRC_RUN_E2E=true) confirmed all 3 affected
  runtime paths pass. NEWS.Rmd/BACKLOG.md/PROJECT_LEARNINGS.md (Learning 588) updated.
next_steps: BACKLOG.md's remaining numbered items (order this session's Phase 0 presented, none
  picked): stale pb_diagram_legend.png screenshot (READY, Effort S, found S574); Pedigree Diagram
  sibling subtree-width asymmetry (READY but needs its own design session first, found S576);
  #148 MHC scope-narrowing conversation (DECISION NEEDED); NPRC outreach & announcement plan
  (DECISION NEEDED, owner review). Separately: scheduled shinytest2.yaml CI run still red 2
  consecutive days (2026-08-13, 2026-08-14), unchanged/undiagnosed across 2 sessions now --
  worth a dedicated diagnose session soon. SESSION_NOTES.md is 3,146+ lines (grows every
  session), past the 2,000-line HIGH-risk cap -- per CLAUDE.md's own fence-scanner-defect note,
  do NOT run methodology_trim.py --write on it until that defect is fixed (rewrap the offending
  4-backtick paragraph, or patch the tool).
key_files: R/orderReport.R:81-86 (imports/noParentage radix fix); R/qcStudbook.R:323-326 (gen/id
  radix fix); R/modBreedingGroups.R:687-693 (bgGroupView radix fix); R/kinshipMatrixToKValues.R:
  105-112 (false-positive explanation); R/computeGenomicROH.R:110-121 (false-positive
  explanation); tests/testthat/test_orderReport.R, test_qcStudbook.R, test_modBreedingGroups.R
  (new RED tests); PROJECT_LEARNINGS.md Learning 588 (full classification methodology).
gotchas: A grep-based "sorts a character column" heuristic over-flags for this defect class --
  always empirically verify divergence (withr::with_locale or just check this session's own
  default LC_COLLATE) before writing a RED test, not just read the sort-key type. Two distinct
  false-positive mechanisms exist and both are easy to miss: (1) a data.table's [.data.table]
  subsetting silently substitutes order() with its own locale-independent forder() -- check
  object class, not just column type; (2) a locale-sensitive intermediate sort can still produce
  a locale-INVARIANT final result if consumed via split()-plus-a-non-character-secondary-key --
  trace how the ordered object is actually used downstream, not just whether the primary key is
  character. Also: lintr::lint_package() with no arguments uses the project's own .lintr config
  (allows camelCase); calling it with linters = linters_with_defaults() produces a completely
  different, much noisier lint set unrelated to what CI actually checks -- don't do this, it
  wastes time chasing lints CI would never flag.
runtime_smoke: qcStudbook/orderReport/bgGroupView are all live runtime-behavior-affecting call
  paths. Confirmed via opt-in live E2E (NPRC_RUN_E2E=true, real shinytest2/chromote browser --
  skipped by default and NOT covered by the ordinary full-regression pass):
  test-e2e-mate-pair-analysis-module.R, test-e2e-genetic-value-tutorial.R,
  test-e2e-breeding-groups-module.R all pass. Full live E2E suite also run for full confidence.
changelog_ref: 12ebaba4 (S580's own last CHANGELOG entry before this session's 6 new entries --
  see the 2026-08-14 section, "S581:" prefixed entries)
commit: 6dd26870
```
Self-score breakdown (9/10): +caught 2 plausible-looking false positives via empirical RED-phase
verification before writing any implementation code, exactly the Strict-TDD safeguard this
project's contract exists for; +caught and corrected an in-session lintr tooling mistake
(default linters vs. project's own .lintr) before it produced a false close-out claim;
+recognized full-regression alone was insufficient runtime verification given 3 confirmed
runtime-affecting paths and ran the project's own opt-in live E2E suite rather than treating
"tests pass" as automatically "runtime verified"; +all 3 TDD phase gates run via AskUserQuestion
per CLAUDE.md's Phase-gate format; +documented false-positive reasoning in-code, not just in
BACKLOG.md, so a future session re-running the same grep doesn't re-derive it.
-still no independent adversarial-verification pass (14+ session standing gap, unaddressed
again); -the 6-hit-to-4-hit scope correction happened mid-RED rather than at PRE-RED, meaning
the user approved a scope (all 6) that immediately shrank -- a more careful PRE-RED (checking
object class/downstream consumption before presenting the classification table) could have
caught this one step earlier.

```handoff
session: S580
date: 2026-08-14
status: complete
self_score: 9
predecessor_score: 9
active_task: HANDOFFS.md byte-budget/line-headroom archive trim (BACKLOG.md Housekeeping, found
  S579) -- DONE. Archived 21 of 22 records to a new dated shard; both triggers clear (9,682 B vs
  65,536 B budget; line-headroom metric abstains, fewer than 1 record since the split).
what_was_done: Hit SRF_RED on the dry run (SRF 1.1566 against the most-recent archive 306a4b4, vs.
  0.1201 against the largest-drop boundary d07814a) -- Learning 549/550/586's false-refusal pattern,
  now confirmed on HANDOFFS.md too (a file Learning 549 had previously called clean). Pulled
  absolute byte deltas for both boundaries before deciding (116,204 B real regrowth in ~1 day);
  surfaced both readings + 3 options via AskUserQuestion; user chose --force. Verified losslessness
  3 ways (dry-run L1/L2/L3, the shard's own verify.sh, post-trim --check). Caught and fixed a
  cosmetic front-matter drift the tool's in-place edit left behind (the "currently holds N
  receipt(s)" sentence stranded between 2 archive pointers) -- repositioned to match the S508/S561
  convention. Removed the resolved BACKLOG.md item; added PROJECT_LEARNINGS.md Learning 587.
  Commits: 9f4110f8 (claim), 838e94ff (the trim), 12ebaba4 (BACKLOG/Learning update), plus this
  close-out commit.
next_steps: BACKLOG.md's remaining numbered items (in the order presented this session's Phase 0,
  none picked): locale-dependent order() sweep (qcStudbook()/orderReport(), READY, Effort M);
  stale pb_diagram_legend.png screenshot (READY, Effort S); Pedigree Diagram sibling
  subtree-width asymmetry (READY but needs its own design session first, found S576); #148 MHC
  scope-narrowing conversation (DECISION NEEDED); NPRC outreach & announcement plan (DECISION
  NEEDED, owner review). Separately, not yet its own BACKLOG item: SESSION_NOTES.md is 3,049+ lines
  (grows every session), past the 2,000-line dashboard HIGH-risk cap -- per CLAUDE.md's own
  "SESSION_NOTES.md archive blocked by a fence-scanner defect" note, do NOT run
  methodology_trim.py --write on it yet; the 4-backtick inline-code-span false-fence at line
  ~23229 must be fixed first (rewrap that one paragraph, or patch the tool's fence-scanner) or the
  archive will misplace ~42% of the file's real record boundaries even though L1/L2/L3 would still
  report lossless.
key_files: HANDOFFS.md (live receipt ledger, now 9,682 B); docs/archive/HANDOFFS-through-2026-08-14.md
  (+.verify.sh, the new shard, 21 records); BACKLOG.md (Housekeeping section, item resolved);
  PROJECT_LEARNINGS.md Learning 587 (the cross-file SRF_RED recurrence).
gotchas: The SRF_RED false-refusal pattern (Learnings 549/550/586/587) is now confirmed on BOTH
  ledger files this project's methodology_trim.py config tracks, not a CHANGELOG.md quirk -- expect
  it again on either file, and on SESSION_NOTES.md too once its fence-scanner defect is fixed and it
  starts archiving. Always pull absolute byte deltas (git cat-file -s <sha>^:<file> / <sha>:<file>)
  before trusting the ratio alone; the two boundaries can disagree by an order of magnitude on the
  same real regrowth. Also: methodology_trim.py's in-place FRONTMATTER_FIELD_REGENERATED edit does
  NOT reposition the "currently holds N receipt(s)" sentence relative to newly-inserted archive
  pointers -- check its position after every --write and move it back to immediately-after-newest
  if a new pointer landed above it.
runtime_smoke: n/a -- docs/ledger-only change, no runtime behavior touched.
changelog_ref: 12ebaba4
commit: 75c23fe5
```
**Self-score breakdown (9/10):** +caught the P1_UNDOCUMENTED-avoidance opportunity from S579's own
experience and applied it proactively; +pulled absolute byte deltas before the SRF_RED decision
rather than trusting the ratio; +caught and fixed the stranded front-matter sentence; +verified
losslessness 3 independent ways; +recorded a forward-looking, cross-file-generalized learning.
-still no independent adversarial-verification pass (13+ session standing gap, unaddressed again);
-skipped a second dedicated scope-confirmation `AskUserQuestion` after the picker, relying on the
picker option's own description instead (defensible, but a departure from S579's own pattern worth
a future session's consistency judgment).

