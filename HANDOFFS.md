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

## Three files, three questions, one shared key

- **`SESSION_NOTES.md`** — the *transient scratchpad*: rich working notes, overwritten every session.
- **`HANDOFFS.md`** (this file) — the *durable receipt*: the distilled, machine-checkable proof that
  the handoff was written, kept forever.
- **`CHANGELOG.md`** — the *cumulative action ledger*: *"what was done here, ever?"*, append-only.

The shared key across all three is the commit sha (`changelog_ref` / `commit` here). This file
**distills** the handoff; it does not copy the scratchpad. The belongs-here test: *would the next
session need this block to continue the work without re-reading the whole repo?*

---

<!-- Receipts go below, newest on top. Delete the seed-sentinel line above when you add the first one. -->

```handoff
session: S338
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 10
active_task: DONE. The stale passage in vignettes/articles/engineering-the-2.0.0-release.qmd:487-503 (S336's narration of the shinytest2.yaml CI coverage gap as "currently open") now correctly states the gap was closed by S337 (commit c5ccf69b, live run 29057393786, independently re-verified this session: 15 groups in the current workflow file, run status success/completed).
what_was_done: PRE-RED scope AskUserQuestion (3 options) -> owner picked "prose fix, TDD N/A". Rewrote qmd:487-503 into two paragraphs: para 1 keeps the historical narrative (gap existed 2026-06-11 through 2026-07-08), para 2 states the S337 resolution (new regression test, 2 added CI groups, count-free workflow comment, confirming live run) with the commit sha and run link. Corpus-grepped .qmd/.Rmd/.md for other stale "23 files/13 groups/24 of 26" references -- only hits were dated ledger/planning docs correctly narrating history, none touched. Verified via `quarto render` (23 chunks, 0 errors); cleaned up untracked .html/_files/.gitignore render artifacts the render left in vignettes/articles/ (see gotchas). Independently re-derived (not just trusted from S337's receipt): current workflow file's groups=(...) array has exactly 15 entries incl. the 2 new ones; `gh run view 29057393786` returns status=completed, conclusion=success; commit c5ccf69b exists with the expected message. New PROJECT_LEARNINGS.md Learning 314. Updated CLAUDE.md's learning-count pointer (313->314, Sessions 1-337+ -> 1-338+). Commits: see changelog_ref.
next_steps: No CI/testing work pending from this session. The two dated planning docs matched by the staleness grep (docs/planning/phase8e-assertion-strengthening-subplan.md, docs/planning/issue2-gva-iteration-convergence-plan.md) were confirmed historically-dated and out of scope but not read in full -- a future exhaustive corpus sweep could go further, though nothing indicates a live issue there. No other open item from this session.
key_files: vignettes/articles/engineering-the-2.0.0-release.qmd:487-509 (the rewritten passage), PROJECT_LEARNINGS.md (Learning 314), CLAUDE.md:177 (learning-count pointer)
gotchas: `quarto render`ing any vignettes/articles/*.qmd leaves untracked .html, _files/, and an auto-written .gitignore (for .quarto/) in that subdirectory -- the top-level .gitignore's vignettes/*.html-style patterns are single-level globs and do NOT match vignettes/articles/*.html. Clean these up before staging; confirmed via `git log --all --oneline -- 'vignettes/articles/*.html'` (empty) that no prior session has ever committed rendered output for any sibling article, so absence is the norm, not an oversight.
runtime_smoke: n/a -- docs-only prose change, no R/ package runtime behavior touched. Build-equivalent verification (quarto render, 0 errors) performed instead and stated as this deliverable's actual completeness check, per FM #24.
changelog_ref: CHANGELOG.md 2026-07-09 "Update stale CI-gap narration in the v2.0.0 article (Session 338)"
commit: 195cf2ec
```
<free-text prose: self-score breakdown>

**+ (what went right):** Asked a PRE-RED scope question before any edit, even for a
docs-only change, per the TDD contract. Independently re-derived the key figures
(current CI group count, live-run status, commit existence) rather than trusting
S337's receipt at face value, even though every one of them held exactly. Preserved
the article's historical narrative voice instead of just deleting the stale claim.
Ran the actual build-equivalent (`quarto render`), not just an eyeball diff review.
Caught a genuine, non-obvious repo-hygiene gotcha (render artifacts escaping the
top-level `.gitignore` in this subdirectory) and recorded it as a new learning instead
of silently discarding the evidence. Ran a corpus-wide grep sweep for other stale
references before declaring done.
**- (what could improve):** Did not read the two peripheral planning docs
(`phase8e-assertion-strengthening-subplan.md`, `issue2-gva-iteration-convergence-plan.md`)
in full -- confirmed historically-dated and out of scope from the matched lines alone,
which was adequate for this session's narrow deliverable but not an exhaustive read.

```handoff
session: S337
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 9
active_task: The shinytest2.yaml CI-coverage gap S336 flagged (Learning 312) is FIXED -- all 26 tracked test-{app,e2e}-*.R files now match exactly one of 15 CI groups, guarded by a new regression test. One new cross-deliverable staleness surfaced as a side effect (see gotchas/next_steps): the article's own narration of this gap as "currently open" is now stale.
what_was_done: Re-verified the gap firsthand (git ls-tree + hand-checked all 13 old regexes against all 26 stripped filenames) before touching anything -- exactly reproduced S336's finding (test-e2e-orip-module.R, test-e2e-potential-parents-module.R uncovered). PRE-RED scope AskUserQuestion (3 options) -> owner picked "regression test + fix". RED: wrote tests/testthat/test_shinytest2_workflow_coverage.R -- parses the groups=(...) bash array out of the YAML text and asserts, via the same grepl-after-stripping-test-/.R transform test_dir(filter=) itself uses, that every tracked file matches exactly one group (gap AND overlap checked); confirmed it failed naming exactly the 2 orphaned files, 0 false positives. GREEN gate approved -> added "^e2e-orip-module" and "^e2e-potential-parents-module" to shinytest2.yaml's groups array (matching the existing single-file group style); re-ran the coverage test (passed) and the full clean regression read (1 pre-existing unrelated failure only -- test_vignettes_no_deprecated_minParentAge.R, confirmed pre-existing and unrelated via a git stash A/B of just my 2 changed files). REFACTOR gate approved -> caught that GREEN's own comment/echo updates ("23"->"26", "13"->"15") reintroduced the exact hardcoded-count staleness class being fixed; removed all hardcoded counts from prose and converted the runtime echo message to `${#groups[@]}` (dynamically computed, cannot drift again). Verified: bash -n syntax-check on the extracted run: block (via python yaml.safe_load), dynamic-count sanity check (printed 15 correctly), lintr on the new file (0 lints), full regression read identical before/after refactor. New PROJECT_LEARNINGS.md Learning 313. Updated CLAUDE.md's learning-count pointer (312->313, Sessions 1-336+ -> 1-337+). Commits: see changelog_ref.
next_steps: vignettes/articles/engineering-the-2.0.0-release.qmd:487-503 (written by S336) narrates this CI gap as "a real, currently open gap, not a stale figure this article repeats uncritically" -- that is now FALSE as of this session's GREEN commit. A future documentation-workstream session should update that passage (and check @sec-features / T-tables for any other reference to "24 of 26 covered") to state the gap is closed, citing this session's commit. This is a different capability/deliverable from the CI fix itself -- flagged, not fixed here (same discipline S336 used for the original gap). No other CI/E2E work is pending from this session.
key_files: .github/workflows/shinytest2.yaml:8-27,118-186 (groups array + all count-bearing comments/echo, now count-free/dynamic), tests/testthat/test_shinytest2_workflow_coverage.R (new regression test, full file), PROJECT_LEARNINGS.md (Learning 313), CLAUDE.md:177 (learning-count pointer), vignettes/articles/engineering-the-2.0.0-release.qmd:487-503 (NOT edited -- now stale, flagged above)
gotchas: The article passage above is now a KNOWN STALE cross-reference as a direct, mechanical side effect of this fix -- do not treat "24 of 26 covered, 2 orphaned" as current fact anywhere in the repo; grep for "24 of\|24 covered\|13 hardcoded\|13-group" before trusting any prose claim about this workflow's coverage. The coverage test parses the YAML by locating `groups=(` and the next line matching `^\s*\)\s*$` -- if the array's bash formatting ever changes shape (e.g. inline `)`), the parser needs updating too; it will fail loudly (0 group regexes extracted -> explicit expect_true failure), not silently pass. True live-runner confirmation (an actual `workflow_dispatch`/nightly GitHub Actions run with real Chrome) was NOT performed this session -- only local static verification (parse + syntax + the new test); flagged per FM #24, not silently treated as equivalent.
runtime_smoke: CONFIRMED live -- owner approved triggering it; `gh workflow run shinytest2.yaml --ref master` dispatched run 29057393786, completed success in 18m56s (all 15 per-module groups green, including the 2 new ones for the previously-orphaned files): https://github.com/rmsharp/nprcgenekeepr/actions/runs/29057393786 . Local static verification (YAML parses, bash -n, dynamic ${#groups[@]} sanity check, full testthat regression read before/after REFACTOR) also held.
changelog_ref: CHANGELOG.md 2026-07-09 "Fix CI coverage gap in shinytest2.yaml -- 2 orphaned E2E test files now run (Session 337)"
commit: c22b5e22
```
<free-text prose: self-score breakdown>

**+ (what went right):** full TDD phase-gate discipline -- a PRE-RED scope question plus
all three phase gates (RED/GREEN/REFACTOR), each via `AskUserQuestion`, 0 stakeholder
corrections. Re-verified the gap firsthand (git ls-tree + hand-checked regexes) rather
than trusting S336's handoff numbers at face value, even though they turned out exact.
The RED test mirrors `test_dir(filter=)`'s own matching semantics precisely (not an
approximation) and checks a STRONGER invariant than the minimum ask (overlap, not just
gap). Verified the one other failing test in the suite was pre-existing and unrelated
via a `git stash` A/B rather than assuming. Caught, during my OWN REFACTOR review, that
GREEN's edit reintroduced the identical hardcoded-count defect class being fixed, and
corrected it structurally (a computed count) instead of just re-updating the literal --
this is the session's most valuable catch and it came from taking REFACTOR seriously as
a real phase, not a rubber stamp. Proactively found and flagged (without touching, correct
scope discipline) that the fix stales a DIFFERENT already-shipped document.

**- (what could improve):** skipped the Phase 1B claim stub -- did not write a
`SESSION_NOTES.md`/`HANDOFFS.md` stub before starting technical work; caught only at
close-out. No actual harm this session (it completed normally with no crash), but it is
a real protocol miss that should not recur. Did not perform true live-runner (GitHub
Actions `workflow_dispatch`) verification -- strong local static verification instead,
flagged explicitly rather than silently treated as equivalent, but genuinely not the
same confirmation. Found the stale article passage because I already knew from S336's
own handoff to look at it, not from an independent full-corpus grep sweep for other
possible mentions of the old counts (README, other planning docs) -- a more exhaustive
sweep might have found something I didn't check for.

```handoff
session: S336
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 9
active_task: v2-transformation-article-plan.md is now FULLY EXECUTED (Phase A through Phase F, no Phase G). A real, currently-open CI gap was discovered as a side effect (see gotchas/next_steps) and is unfixed, flagged for a future session. CRAN 2.0.0 review outcome still pending, independent of this plan.
what_was_done: Drafted Abstract (200 words) + Introduction + Conclusion (verbatim NIH grant ack) in engineering-the-2.0.0-release.qmd; Section 5 cut and F6 skipped per two owner AskUserQuestions at kickoff. Ran the full-document claim-source audit (workstream Phase 6) via two parallel forked adversarial-verification passes across all 8 sections (~55 claims), each independently re-derived from git/gh/grep, not the plan's own summary table -- then independently re-verified all 4 reported mismatches firsthand before editing. Fixed 4 real defects: (1) Section 1 misattributed the inst/application/ deletion commit (3db018d1 -> 24992e0b, the correct Phase-9-Part-2/3 commit); (2) Section 2's issue #34 "years later" overclaim -> "about five months later" (gh issue view: 2026-01-20 to 2026-06-12); (3) Section 4's "four sessions that produced Sections 1-3" -> "three" (git log confirms S332/S333/S334); (4) Section 3's CI-coverage claim was stale -- the 13-group E2E CI partition covers 24 of 26 opt-in test files, not "23, no gap"; rewrote to state current verified figures. Full verification chain: quarto render (zero unresolved refs) -> pkgdown::build_article("articles/engineering-the-2.0.0-release") (clean) -> R CMD build . + tar tzf (zero CRAN risk confirmed). Found the plan's own "four existing articles" claim stale (six exist) and rendered all six. Marked Phase F DONE in the plan's Sec7, ticked all 10 Sec10 checklist items, resolved all 4 Sec12 open decisions. Added PROJECT_LEARNINGS.md Learning 312. Commits: 268df760 (S336 claim stub), plus this receipt's own commit (see changelog_ref).
next_steps: No Phase G -- the plan is fully executed. Before anything else: triage the CI-gap defect this session found (see gotchas) -- it needs its own small TDD-governed session, not a continuation of this one. Beyond that, three independent, not-pre-decided directions: (1) the CI-gap fix if prioritized; (2) "Document 2" (package purpose/how-to-use, explicitly out of scope for this plan) needs a fresh planning session per the owner's 2026-07-09 instruction; (3) resume whatever the CRAN 2.0.0 review outcome requires once it arrives.
key_files: vignettes/articles/engineering-the-2.0.0-release.qmd (Abstract/Introduction/Conclusion added; 4 claim-audit fixes applied to Sections 1-3-4), docs/planning/v2-transformation-article-plan.md (Phase F closure note, Sec10 checklist ticked, Sec12 decisions resolved), .github/workflows/shinytest2.yaml:127-141 (the groups=(...) array needing 2 more regexes -- NOT edited this session, flagged only), PROJECT_LEARNINGS.md (Learning 312), CLAUDE.md:177 (learning-count pointer)
gotchas: REAL, CURRENTLY-OPEN DEFECT (not this session's to fix): .github/workflows/shinytest2.yaml's 13-group E2E CI partition covers 24 of 26 files in the opt-in test-(app|e2e)-*.R tier -- test-e2e-potential-parents-module.R (issue #48, S82) and test-e2e-orip-module.R (issues #47/#49, S86) match none of the 13 hardcoded group regexes and never run in CI. Fix: add 2 group regexes to groups=(...) at shinytest2.yaml:127-141, update the header comment's stale "23...no gap" claim, verify via a live triggered workflow run (a local test_dir(filter=) dry run confirms the regex match but not the job itself). Separately: a full-document claim audit run AFTER each phase individually verified its own section can still find real defects a per-section review has no way to catch (drift from unrelated LATER sessions' changes) -- do not treat a phase's own "DONE, verified" status as exempt from a later cross-document audit.
runtime_smoke: n/a -- documentation/article-drafting session, no R/ package runtime behavior changed; the full verification chain (quarto render + pkgdown::build_article() + R CMD build ./tar tzf + all 6 pre-existing articles re-rendered) is this deliverable's actual build-equivalent verification, performed and confirmed
changelog_ref: CHANGELOG.md 2026-07-09 "Phase F of the Document-1 article plan: Abstract/Introduction/Conclusion, full claim audit, full verification chain (Session 336) -- plan now fully executed"
commit: bca11e5d
```
<free-text prose>

**+ (what went right):** did not rubber-stamp Sections 1-4 as already-DONE just
because prior sessions had verified them at draft time -- ran the full-document audit
the plan's own checklist actually requires and it found 4 real, independently
confirmed defects, one of them (the CI gap) a genuinely new class this project hadn't
named before: a claim that was true when its own session verified it and went false
later purely from unrelated sessions changing the world elsewhere. Correctly
separated "discover and report" from "fix" for that CI gap -- documenting it
precisely and flagging it to the owner rather than either silently patching CI
mid-documentation-session (scope creep) or silently ignoring a defect the audit
surfaced (the exact failure the audit exists to prevent). Independently re-verified
every fork-reported finding firsthand before touching the article, per the
"adversarial refutation applies to your own agents' output too" guidance -- all 4
held, but only because they were checked, not assumed. Caught that the plan's own
"four existing articles" instruction was itself stale and rendered the fuller,
correct set of six rather than literally matching a stale instruction.

**- (what could improve):** the two forked audit passes were split by section count
(4 sections each) decided before either ran, not by claim density -- wall-clock came
out ~229s vs ~281s, a modest but real imbalance; a finer split might parallelize more
evenly next time. Did not sweep the rest of the repo (planning docs, README) for
other prose that might also repeat the now-stale "23-file CI tier" claim beyond the
workflow file and the article itself -- no other location was identified as likely,
but the search wasn't exhaustive.

```handoff
session: S335
date: 2026-07-09
status: complete
self_score: 8
predecessor_score: 8
active_task: Phase E of docs/planning/v2-transformation-article-plan.md is DONE. Phase F (assemble/consolidate/verify/publish -- Abstract, Introduction, optional Section 5, Conclusion, full §10 Verification Checklist incl. pkgdown::build_article()/R CMD build tarball check) is next and is the publish gate (§9 dragon #3: public URL, not fully reversible in practice). F6 screenshot reuse still needs an owner AskUserQuestion before Phase F touches vignettes/shiny_app_use/. CRAN 2.0.0 waiting period (from S329) is unchanged and independent.
what_was_done: Added Section 4 ("An AI-Assisted Development Process") + T6 (@tbl-process-metrics, 9-row process-metrics table) + F4 (@fig-tdd-cycle, Mermaid stateDiagram-v2 of RED->GREEN->REFACTOR with AskUserQuestion gate annotations) + F5 (@fig-self-score-trend, ggplot2 line chart, session-chronological order) to engineering-the-2.0.0-release.qmd, reading Phase A's frozen process-metrics.csv/self-score-trend.csv unchanged. Both T6 and F5 carry an explicit "Phase A data freeze (Session 331)" caption stating the source files are live and had already grown past the frozen snapshot by this session -- verified firsthand: live CHANGELOG.md is 317 entries and live PROJECT_LEARNINGS.md is 310, vs. the frozen 309/305. Reordered F5's rows by session number (frozen CSV's date-only sort left same-day sessions in reverse-numeric order) without mutating the frozen file, matching T2's established client-side-reorder precedent; flagged that Sessions 329-330 postdate the range's own end commit (8ca8bb24) despite sharing its calendar date, verified via git log timestamps. Independently verified 3 claim-map facts rather than trusting the summary table alone: SESSION_RUNNER.md's failure-mode table has exactly 27 rows, Session 324 is genuinely the earliest complete HANDOFFS.md receipt, and the Session-325 CHANGELOG ledger-format-resolution date. Cited the 4-consecutive-session commit-sha-backfill self-correction pattern (cc0f7798/2278b46f/ee690776/5f0b81d2, all real commits) as concrete evidence of the ledger mechanism working. quarto render succeeded; T6/F4/F5 resolved as Table 5/Figure 4/Figure 5, zero unresolved refs. F4's first version had a real defect quarto render's exit code could not catch: a \n inside Mermaid transition labels (wrongly modeled on F2's flowchart <br/> syntax) rendered as a literal backslash-n, not a line break -- caught by statically rendering the extracted .mmd via npx mermaid-cli and inspecting the actual PNG (rsvg-convert was tried and rejected -- it doesn't support Mermaid's foreignObject label elements and showed a worse, misleading false defect); fixed by keeping each label on one line, re-verified via mermaid-cli then re-rendered the full article. Cleaned up render artifacts before staging. Commits: bd3b3fcf (S335 claim stub), 9c4fbf93 (Phase 0 ledger backfill for 5f0b81d2, this session's own reconcile-on-read finding), plus this receipt's own commit (see changelog_ref).
next_steps: Phase F of the article plan -- the publish gate. Draft Abstract, Introduction, optional Section 5 (owner decision per plan §12.2 -- recommend drafting only if Sections 1-4's own tables don't already summarize), Conclusion (NIH grant ack, P51 RR13986/P51 OD011092). Then the full §10 Verification Checklist across ALL FOUR sections (not just Section 4): quarto render + pkgdown::build_article() + R CMD build . + tar tzf (zero CRAN risk, S107-110 precedent -- fuller chain than Phase A-E used), spot-check the 4 pre-existing articles still render, F6 needs an explicit owner AskUserQuestion before vignettes/shiny_app_use/ is touched.
key_files: vignettes/articles/engineering-the-2.0.0-release.qmd (Section 4 + T6/F4/F5 appended), vignettes/articles/data/process-metrics.csv + data/self-score-trend.csv (read, not modified -- Phase A's frozen data, now confirmed stale vs. live CHANGELOG.md/PROJECT_LEARNINGS.md), docs/planning/v2-transformation-article-plan.md (header status line + §7 Phase E marked DONE), PROJECT_LEARNINGS.md (Learning 311), CLAUDE.md:177 (learning-count pointer), CHANGELOG.md (backfill entry for undocumented commit 5f0b81d2, prepended during this session's own Phase 0 reconcile)
gotchas: T6/F5's source files (CHANGELOG.md/PROJECT_LEARNINGS.md/HANDOFFS.md/SESSION_NOTES.md) are LIVE, still-growing files read at a point in time (Phase A, Session 331) -- unlike T5's git-ls-tree-at-sha data, these numbers will keep drifting further from the article's own numbers every session; any future session citing T6 should say "as extracted at the Phase A freeze," never "current." Mermaid stateDiagram-v2 transition labels do NOT support \n for line breaks (unlike F2's flowchart <br/>) -- keep labels one line, or verify with mermaid-cli before trusting quarto render's exit code (new Learning 311). BACKLOG.md's stale "#40 open" line remains unpruned -- flagged 4 consecutive sessions now (S333-S335, S334 twice) -- prune next time BACKLOG.md is open for any reason.
runtime_smoke: n/a -- documentation/article-drafting session for vignettes/articles/ support, no R/ package runtime behavior changed; quarto render + a standalone mermaid-cli PNG render (caught and fixed a real Mermaid label defect) is this deliverable's actual build-equivalent verification, performed and confirmed
changelog_ref: CHANGELOG.md 2026-07-09 "Phase E of the Document-1 article plan: drafted Section 4 (AI-assisted development process) + T6/F4/F5 (Session 335)"
commit: 33f943e0
```
<free-text prose, self-score breakdown>

**+ (what went right):** independently re-verified 3 claim-map facts rather than trusting
the plan's own summary table (FM-27 count, Session-324 receipt start, live-vs-frozen
CHANGELOG/PROJECT_LEARNINGS drift); caught a real Mermaid rendering defect invisible to
`quarto render`'s exit code by extending the verification method itself (standalone
`mermaid-cli` PNG render), documented as new Learning 311 for future sessions; fixed a
genuine data-presentation bug (F5's stable-sort row order) without mutating frozen data,
matching established precedent; held scope tightly (no F6, no Section 5, no `BACKLOG.md`
edit -- the conditional instruction was evaluated and correctly found not to trigger).

**- (what could improve):** F4's first drafted version had the `\n` defect at all --
avoidable if Mermaid's `stateDiagram-v2` label syntax had been checked or
verification-rendered before writing the "real" version into the article, rather than
after; did not independently spot-check the `stakeholder_correction_zero_mentions`/
`nonzero_mentions` grep pattern against a hand sample of `SESSION_NOTES.md`, taking the
frozen 269/2 split from the plan's own claim-map row without an independent sanity check.

**Predecessor (Session 334) evaluation: 8/10.** Handoff correctly scoped Phase E and
correctly sourced the F5 coverage caveat, but did not flag that T6/F5's own source files
are live snapshots that would have drifted further by Phase E -- a gap this session had
to discover and verify independently. Full evaluation in `SESSION_NOTES.md`.

```handoff
session: S334
date: 2026-07-09
status: complete
self_score: 8
predecessor_score: 9
active_task: Phase D of docs/planning/v2-transformation-article-plan.md is DONE. Phase E (draft Section 4 -- Claude CLI/methodology, risk HIGH dragon -- + T6/F4/F5, reading process-metrics.csv and self-score-trend.csv) is next. Phase F must come last. 2 open owner decisions from the plan's §12 remain (optional Section 5 at Phase F; F6 screenshot reuse -- did not gate Phase D, likely doesn't gate Phase E either). CRAN 2.0.0 waiting period (from S329) is unchanged and independent.
what_was_done: Added Section 3 ("Testing at Scale") + T5 (@tbl-testing-growth) + F3 (@fig-testing-growth) to engineering-the-2.0.0-release.qmd, reading Phase A's frozen testing-growth.csv unchanged. Cross-checked both endpoint rows against git ls-tree at the exact commits (4548aa1b/8ca8bb24) -- exact match, but surfaced that the CSV's test_file_count column counts ALL .R files under tests/testthat/ (incl. 4 helper/setup files), not just test*.R -- traced to the extraction script's actual line of code (build-document1-evidence.R:121), not guessed; wrote table/prose to state precisely what's counted (new Learning 310). Verified via gh issue view + CHANGELOG.md session headers that BOTH issue #39 (harness-enable, 8a-8d, closed 2026-06-06) and issue #40 (assertion-hardening, 8e-1..8e-7, closed 2026-06-11) are CLOSED -- contradicts BACKLOG.md's stale "#40 open" line (not fixed, scope discipline). Narrated the harness's full arc (dormant scaffold -> executable -> hardened) sourced to both Phase-8 subplans + CHANGELOG.md session entries, not estimated. quarto render caught a real defect on first render (F3's top data label clipped by the y-axis range) -- fixed with scale_y_continuous(expand=...) and re-rendered to confirm. Marked Phase D DONE in the plan's §7, explicitly flagging that T5's "(if extractable) coverage" hedge was NOT populated (no coverage data in the frozen CSV). Commits: baa5c99d (S334 claim stub), 62339088 (Phase 0 ledger backfill for ee690776, this session's own reconcile-on-read finding), plus this receipt's own commit (see changelog_ref).
next_steps: Phase E of the article plan -- draft Section 4 (Claude CLI/methodology) + T6/F4/F5, reading process-metrics.csv and self-score-trend.csv (both already frozen by Phase A). F5 has a stated coverage caveat (plan §6): HANDOFFS.md receipts only cover recent (Session-325-era) sessions -- state that limitation in the caption, don't imply full-range coverage. Re-read PROJECT_LEARNINGS.md's own framing before drafting to confirm the section doesn't contradict this project's documented failure modes/corrections (the plan's own Phase E verification step).
key_files: vignettes/articles/engineering-the-2.0.0-release.qmd (Section 3 + T5/F3 appended), vignettes/articles/data/testing-growth.csv (read, not modified -- Phase A's frozen 5-checkpoint data), vignettes/articles/data-raw/build-document1-evidence.R:108-131 (T5/F3 extraction logic, read to resolve the column-definition question), docs/planning/v2-transformation-article-plan.md (§1/§7 Phase D marked DONE, coverage-hedge flagged), docs/planning/phase8-e2e-harness-subplan.md + docs/planning/phase8e-assertion-strengthening-subplan.md (read for harness-status sourcing), PROJECT_LEARNINGS.md (Learning 310), CLAUDE.md:177 (learning-count pointer), BACKLOG.md (read, confirmed stale on #40 again, not modified -- flagged 3x now across S333/S334)
gotchas: testing-growth.csv's test_file_count is "all .R files in tests/testthat/", not "test*.R files" -- future sessions citing this column should use the same precise framing, not "test file count" bare. BACKLOG.md's "#40 open" line is stale for the third consecutive flagged session (S333, S334) without a fix -- next session that opens BACKLOG.md for any reason should just prune it. F6 screenshot reuse still needs an owner decision but has not gated either Phase C or Phase D -- likely won't gate Phase E's T6/F4/F5 either (Phase E's dragon is tone/T6-extraction, not screenshots). The 8e-7 CI flake-mitigation number ("~1 error / 5 runs") is sourced to the subplan's own self-report, not independently re-measured -- correctly caveated in the article as subplan-sourced, but note if a future audit wants a stronger source.
runtime_smoke: n/a -- documentation/article-drafting session for vignettes/articles/ support, no R/ package runtime behavior changed; quarto render (output HTML + PNG inspected directly, one defect caught and fixed) is this deliverable's actual build-equivalent verification, performed and confirmed
changelog_ref: CHANGELOG.md 2026-07-09 "Phase D of the Document-1 article plan: drafted Section 3 (testing at scale) + T5/F3 (Session 334)"
commit: 735a3f2a
```
<free-text prose, self-score breakdown>

**+ (what went right):** verified the frozen CSV against primary git data before trusting
it (caught a real column-definition ambiguity, not a bug in the data itself); verified
harness status against primary sources (gh issue view, CHANGELOG) rather than the
plan's own hedge or the stale BACKLOG.md line; caught and fixed a real render defect
(clipped data label) by looking at the actual output image, not just the exit code;
held scope tightly (no F6, no Section 4/5, no BACKLOG.md fix); produced a new,
generalizable learning (310) rather than silently fixing the discrepancy and moving on.

**- (what could improve):** flagged BACKLOG.md's staleness a third time without
fixing it -- should have just fixed it this session once it was clear the pattern was
repeating (a small, unambiguous, one-line prune, not scope creep); did not independently
re-verify the 8e-7 flake-rate claim beyond its own subplan source.

**Score: 8/10.** Matches S333's standard: solid verification discipline, one small
scope-discipline judgment call (BACKLOG.md) flagged rather than silently repeated a
fourth time.

```handoff
session: S333
date: 2026-07-09
status: complete
self_score: 8
predecessor_score: 9
active_task: Phase C of docs/planning/v2-transformation-article-plan.md is DONE. Phase D (draft Section 3 -- testing at scale -- + T5/F3, reading testing-growth.csv and cross-checking e2e/shinytest2 status against phase8-e2e-harness-subplan.md, NOT against BACKLOG.md's stale #40-is-open line) is next. Phases D-E remain reorderable; Phase F must come last. 2 open owner decisions from the plan's §12 remain (optional Section 5 at Phase F; F6 screenshot reuse before Phase D/E -- now directly relevant since Phase D is testing). CRAN 2.0.0 waiting period (from S329) is unchanged and independent.
what_was_done: Hand-curated feature-candidates.csv's 47 raw closed-issue candidates down to 13 (28%) genuinely feature-shaped items, reading each borderline candidate's actual CHANGELOG entry rather than trusting closedAt/labels alone -- caught and excluded 3 issue-hygiene closes of pre-range functionality (#34/#14/#8; #34's own entry says "No code changed"). Wrote vignettes/articles/data/feature-highlights.csv (13 curated rows, T2/T3's frozen-CSV-via-kableExtra pattern). Added Section 2 ("New Capabilities in 2.0.0") + T4 to engineering-the-2.0.0-release.qmd: 3 prose clusters (parent identification/species-awareness x5, GVA uncertainty x4, dashboards/activations x2 + 2 smaller fixes). Fulfilled Section 1's forward-reference to modGeneticDiversity/modPotentialParents; correctly distinguished modORIPReporting's pre-existing code from its in-this-section activation. Marked Phase C DONE in the plan's §7. Verified via quarto render: @tbl-features resolved as Table 3, zero unresolved refs, 13/13 rows present. Verified 3 single-commit citations (0eeee3f6, d4320643, 14c8e84d) both resolve and are ancestors of HEAD. Also backfilled undocumented commit 2278b46f (S332's own receipt sha fix) into CHANGELOG.md during Phase 0 reconcile. Commits: 17333a1f (Phase 0 CHANGELOG backfill), 7cd0f395 (S333 claim stub), 4dcc6869 (article + T4 data), cdda9d35 (plan-doc Phase C DONE), 307c9c77 (learnings+pointer), a01e13ce (CHANGELOG+SESSION_NOTES+this receipt's own commit).
next_steps: Phase D of the article plan -- draft Section 3 (testing) + T5/F3, from testing-growth.csv. Cross-check e2e/shinytest2 harness status against phase8-e2e-harness-subplan.md + CHANGELOG.md directly -- BACKLOG.md's "#40 is open" line is stale (verified CLOSED 2026-06-11 via gh issue view). Get an owner decision on F6 screenshot reuse before touching vignettes/shiny_app_use/.
key_files: vignettes/articles/engineering-the-2.0.0-release.qmd (Section 2 + T4 appended), vignettes/articles/data/feature-highlights.csv (new, this session's curated output -- not a Phase A artifact, no regeneration script by design), docs/planning/v2-transformation-article-plan.md (§1/§7 Phase C marked DONE), PROJECT_LEARNINGS.md (Learning 309), CLAUDE.md:177 (learning-count pointer), vignettes/articles/data/feature-candidates.csv (read, not modified -- the 47 raw candidates), BACKLOG.md (read, found stale on #40, not modified -- flagged not fixed, scope discipline)
gotchas: feature-highlights.csv is Phase C's own hand-curated output, not auto-generated -- do not assume a script produced it. A closed issue's closedAt date is not evidence of in-range work (Learning 309) -- always read the actual CHANGELOG entry for borderline candidates in future curation passes (Phase D/E will face the same raw-closed-issue-list risk). BACKLOG.md's "Up Next" section is stale on issue #40 (claims open, actually CLOSED 2026-06-11) -- not fixed this session (scope discipline), Phase D should prune it. F6 screenshot reuse still needs an explicit owner decision, now directly relevant to Phase D. Phase F's own sha-resolution checklist item should sweep this session's 3 single-commit citations too, not just T3's (S332-flagged).
runtime_smoke: n/a -- documentation/article-drafting session for vignettes/articles/ support, no R/ package runtime behavior changed; quarto render (output HTML inspected for resolved cross-refs + correct row count) is this deliverable's actual build-equivalent verification, performed and confirmed
changelog_ref: CHANGELOG.md 2026-07-09 "Phase C of the Document-1 article plan: drafted Section 2 (new features) + T4 (Session 333)"
commit: a01e13ce
```

```handoff
session: S332
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 9
active_task: Phase B of docs/planning/v2-transformation-article-plan.md is DONE. Phase C (draft Section 2 -- new features -- + T4, curating vignettes/articles/data/feature-candidates.csv's 47 raw candidates) is next. Phases C-E remain reorderable; Phase F must come last. 2 open owner decisions from the plan's §12 remain (optional Section 5 at Phase F; F6 screenshot reuse before Phase D/E) but neither blocked Phase B. CRAN 2.0.0 waiting period (from S329) is unchanged and independent.
what_was_done: Owner confirmed the proposed title/slug via AskUserQuestion. Wrote vignettes/articles/engineering-the-2.0.0-release.qmd -- Section 1 (Shiny modules, issue #27, the nine-phase migration Session 22->35), T2 (module inventory, kableExtra, flags 2 of 10 modules as post-migration additions), T3 (nine-phase migration summary, states Phases 3-7 have no quoted sha and Phase 8 was a compound multi-session DONE), F1 (ggplot2 commit-activity chart), F2 (native Quarto Mermaid before/after architecture diagram, no new dependency). Marked Phase B DONE in the plan's §7. Verified via quarto render: cross-references resolved in the output HTML, Mermaid runtime correctly wired -- not just exit code 0. Re-verified live: 4,731 total module lines (wc -l, matches frozen C1 exactly), all 10 modules currently mounted (correcting a stale "only 6 mounted" snapshot in the older planning doc), the "17 files" inst/application/ deletion count (cross-checked against CHANGELOG.md's own Phase-9 entry). Also backfilled one undocumented commit (cc0f7798, S331's own receipt sha fix) into CHANGELOG.md during this session's Phase 0 reconcile. Commits (6, to respect the 5-file blast-radius cap): 6c0eb75f (Phase 0 CHANGELOG backfill), bbd59276 (S332 claim stub), e6bc887f (article), 5501c347 (plan-doc Phase B DONE), 86711601 (learnings+pointer), b051c883 (CHANGELOG+SESSION_NOTES+this receipt's own commit).
next_steps: Phase C of the article plan -- draft Section 2 (new features) + T4, curating (not re-extracting) from vignettes/articles/data/feature-candidates.csv's 47 raw closed-issue candidates. Phases C-E are reorderable, Phase F must come last. Before Phase F specifically: verify each T3 commit sha still resolves in git log (this session reused Phase A's already-verified C3 shas but did not independently re-run git log -1 <sha> for each this session -- see gotcha below).
key_files: vignettes/articles/engineering-the-2.0.0-release.qmd (new, Section 1 + T2/T3/F1/F2), docs/planning/v2-transformation-article-plan.md (§1/§7 Phase B marked DONE), PROJECT_LEARNINGS.md (Learning 308), CLAUDE.md:177 (learning-count pointer), vignettes/articles/data/module-inventory.csv + migration-phases.csv + commit-activity-timeline.csv (read, not modified -- this phase's data source), R/appUI.R + R/appServer.R (read via grep for live module-mount verification, not modified)
gotchas: feature-candidates.csv is 47 RAW candidates, not curated -- Phase C must hand-select feature-worthy items. After any quarto render used for in-session verification, run git status --porcelain on vignettes/articles/ and delete generated .html/_files/render-.gitignore before staging -- the top-level .gitignore's vignettes/*.html glob does not reach the articles/ subdirectory (Learning 308); this will recur every future rendering phase. vignettes/shiny_app_use/ screenshots (F6) remain untouched, need explicit owner confirmation before Phase D/E touches them. The stakeholder-correction-rate number (C14) is a mention-count proxy, not a verified audit -- Section 4 prose (Phase E) must state that limit explicitly. F5 self-score-trend data covers only S324-S330 (7 sessions), a partial window. T3's commit shas were reused from Phase A's already-verified C3 values, not independently re-run this session -- do a final git log -1 <sha> pass before Phase F's publish gate (the plan's own §10 checklist already requires this).
runtime_smoke: n/a -- documentation/article-drafting session for vignettes/articles/ support, no R/ package runtime behavior changed; quarto render (output HTML inspected for resolved cross-refs + correctly-wired Mermaid assets) is this deliverable's actual build-equivalent verification, performed and confirmed
changelog_ref: CHANGELOG.md 2026-07-09 "Phase B of the Document-1 article plan: drafted Section 1 (Shiny modules) + T2/T3/F1/F2 (Session 332)"
commit: b051c883
```

```handoff
session: S331
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 8
active_task: Phase A of docs/planning/v2-transformation-article-plan.md is DONE. Phase B (draft Section 1 + T2/T3/F1/F2) is next, reading from the frozen CSVs. 3 open owner decisions from the plan's §12 remain (title/slug, optional Section 5, F6 screenshot reuse) but none blocked Phase A -- they gate later phases specifically. CRAN 2.0.0 waiting period (from S329) is unchanged and independent.
what_was_done: Wrote vignettes/articles/data-raw/build-document1-evidence.R (checked-in, reproducible extraction script) producing 7 frozen CSVs under vignettes/articles/data/ (module-inventory, migration-phases, feature-candidates [47 raw closed-issue candidates], testing-growth, commit-activity-timeline, process-metrics, self-score-trend). Completed the plan's §3 Claim-Evidence Map (14 dated/sha-anchored rows, C1-C14) and marked Phase A DONE in §7. Corrected two inaccuracies in S330's plan with hard evidence: (1) resolved the §2 first-session-number gotcha -- true Session 1 begins at 6fd87749 (2026-05-30), inside the ratified range, not predating v1.0.8; 328 sessions (Session 1 -> S328) fall within the range. (2) corrected "Phases 1-9 all marked DONE" -- Phase 8 expanded into subplan 8a-8d (issue #39) then hardening pass 8e-1..8e-7 (issue #40, Session 37-50), visible only in the phase body + CHANGELOG.md. Spot-checked 12 numbers by hand, all confirmed exactly. Added PROJECT_LEARNINGS.md Learnings 306-307, updated CLAUDE.md's learning-count pointer (305->307). Commits (5, to respect the 5-file blast-radius cap): 0d98efc9 (script+4 CSVs), 92a6d85e (remaining 3 CSVs), 1ddbf0c5 (plan doc), b8c89420 (learnings+pointer), 046b62d5 (this receipt's own commit).
next_steps: Phase B of the article plan -- draft Section 1 (Shiny modules) + tables T2/T3 + figures F1/F2, reading from vignettes/articles/data/*.csv. Phases B-E are reorderable (no hard dependency), Phase F must come last. Owner may resolve the remaining 3 open §12 decisions before/at the relevant phase (title at Phase B kickoff; Section 5 at Phase F; F6 screenshots before Phase D/E). Independently, CRAN 2.0.0 waiting period continues unchanged.
key_files: vignettes/articles/data-raw/build-document1-evidence.R (new, this session's extraction script), vignettes/articles/data/*.csv (7 new frozen files), docs/planning/v2-transformation-article-plan.md (§2/§3/§7 updated), PROJECT_LEARNINGS.md (Learnings 306-307), CLAUDE.md:177 (learning-count pointer), docs/planning/shiny-module-conversion-plan.md §9 (T3 source, read not modified), docs/planning/phase8-e2e-harness-subplan.md (Phase-8 correction source, read not modified)
gotchas: Phase B drafts .qmd prose for the first time -- read plan §4/§7 Phase B criteria first; T2/T3 read directly from frozen CSVs, no new extraction needed. feature-candidates.csv is 47 RAW candidates, not curated -- Phase C must hand-select feature-worthy items. vignettes/shiny_app_use/ screenshots (F6) remain untouched, need explicit owner confirmation before any future phase touches them. The stakeholder-correction-rate number (C14) is a mention-count proxy, not a verified audit -- Section 4 prose must state that limit explicitly. F5 self-score-trend data covers only S324-S330 (7 sessions), a partial window not a full-range trend.
runtime_smoke: n/a -- data-extraction/tooling session for vignettes/articles/ support, no R/ package runtime behavior changed
changelog_ref: CHANGELOG.md 2026-07-09 "Phase A of the Document-1 article plan: froze the evidence base (Session 331)"
commit: 046b62d5
```

```handoff
session: S330
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 9
active_task: Plan for Document 1 written and DRAFT (not yet approved for implementation). Owner still needs to confirm 4 open decisions (§12 of the plan) before Phase A begins. CRAN 2.0.0 waiting period (from S329) is unchanged and independent of this work.
what_was_done: Wrote docs/planning/v2-transformation-article-plan.md (352 lines) -- a planning-session deliverable for "Document 1," a public Quarto pkgdown article describing the v1.0.8->v2.0.0 transformation (Shiny modules, new features, testing, Claude CLI use). Adapted RESEARCH_DOCUMENTATION_WORKSTREAM.md's claim-source/figure-provenance discipline to this repo's own evidence (git log, CHANGELOG.md, PROJECT_LEARNINGS.md, HANDOFFS.md) in place of external citations. Verified the exact commit-range boundary via CRAN-SUBMISSION's git history (4548aa1b..8ca8bb24, 512 commits) rather than accepting the owner's phrasing loosely. Read shiny-module-conversion-plan.md in full (primary source for Section 1) and discovered the already-adopted Quarto/pkgdown-articles policy (Session 105) before asking a format question, resolving it as settled rather than open. Asked one AskUserQuestion (public vs internal visibility) -- owner chose public. Proposed 7 tables + 6 figures with purpose/source/generation/provenance each, a 6-phase (A-F) session breakdown, 4 dragons, and an adapted verification checklist. Added PROJECT_LEARNINGS.md Learning 305 (mine docs/planning/ for decided policy before asking format questions; CHANGELOG.md grep off-by-one gotcha) and updated CLAUDE.md's learning-count pointer (302->305). Commit: b93f36de (claim stub: d2275494).
next_steps: Owner reviews docs/planning/v2-transformation-article-plan.md and resolves the 4 open decisions in its §12 (title/slug, keep-or-cut Section 5, F6 screenshot reuse, commit-range framing ratification). Once approved, Phase A (build and freeze the evidence base) is the next session -- see the plan's §7. Independently, the CRAN 2.0.0 waiting period from S329 continues (owner's email-confirmation click, then CRAN's review outcome) -- unrelated and not blocking.
key_files: docs/planning/v2-transformation-article-plan.md (new, this session's deliverable), docs/planning/shiny-module-conversion-plan.md (read in full, primary Section-1 source), docs/planning/quarto-documentation-future-proofing-analysis.md:163-237 (Quarto/pkgdown-articles policy), PROJECT_LEARNINGS.md (Learning 305), CLAUDE.md:177 (learning-count pointer), SESSION_NOTES.md (S330 handoff), HANDOFFS.md (this receipt)
gotchas: The plan is a DRAFT -- do not start Phase A without owner approval of the 4 open §12 decisions. vignettes/shiny_app_use/ screenshots must not be touched without explicit owner confirmation (possibly hand-curated). Section 4's evidentiary metrics (self-score trend, TDD adherence rate, correction counts) do not exist yet -- Phase A/E must do real extraction. The exact first-session-number boundary for the 512-commit range is unverified (a same-session grep found a plausible but uncross-checked S1) -- resolve in Phase A before it becomes a document claim.
runtime_smoke: n/a -- planning/documentation session, no R/ package runtime behavior changed
changelog_ref: CHANGELOG.md 2026-07-09 "Wrote the Document-1 (v1.0.8->2.0.0 technical writeup) planning doc (Session 330)"
commit: b93f36de
```

```handoff
session: S329
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 9
active_task: CRAN 2.0.0 submitted successfully. Awaiting owner's email confirmation click, then CRAN's review outcome. Phase 6 (tag + release + dev-version bump) gated on the acceptance email, not yet started.
what_was_done: Owner reported devtools::submit_cran() upload succeeded. Verified firsthand via git diff CRAN-SUBMISSION (auto-written by devtools, not hand-edited): Version 1.0.8/2025-07-26 -> Version 2.0.0/2026-07-09 17:57:22 UTC/SHA 8ca8bb24 (the exact commit submitted, matching origin/master HEAD at submission time). Committed the updated CRAN-SUBMISSION (legitimate expected artifact, consumed/deleted later by Phase 6's use_github_release()). Updated the plan doc's Phase 5 status block (new SUBMITTED note with version/date/SHA evidence) and Sec9 table Phase 5b row (marked partial-done, since CRAN's review outcome is still pending). Added PROJECT_LEARNINGS.md Learning 304 (4 consecutive sessions each discovered a needs-attention file only after starting the claim, not before -- write the Phase 1B stub the moment a task is understood, before any exploratory read). Commit: 8bb126ce (claim stub: ac871a65).
next_steps: Owner clicks the maintainer-email confirmation link CRAN sends to rmsharp@me.com -- without it the submission never reaches CRAN review. After that, this is a pure waiting period (CRAN's automated + human review, historically ~1 day to a couple weeks) -- no action available until CRAN's acceptance or rejection email arrives. Phase 6 is a separate future session, strictly gated on that email. If the owner wants other work meanwhile, one of the 8 open GitHub issues (#116, #37, #36, #28, #12, #11, #10, #5) remains available.
key_files: CRAN-SUBMISSION (auto-updated, committed as-is), docs/planning/cran-2.0.0-submission-plan.md (Phase 5 SUBMITTED note + Sec9 row), PROJECT_LEARNINGS.md (Learning 304), SESSION_NOTES.md (S329 handoff), HANDOFFS.md (this receipt)
gotchas: Do not start Phase 6 until CRAN's acceptance email actually arrives -- submission succeeding != CRAN accepting; CRAN-SUBMISSION still being present (not deleted by use_github_release()) is itself the signal Phase 6 hasn't happened. Write the Phase 1B claim stub before touching ANY file, including read-only exploration -- per new Learning 304, a confirmed 4-session pattern. If CRAN comes back requiring changes rather than a clean accept, that reopens Phase 2/4-class work, not Phase 6 -- read the actual rejection content before assuming what's needed.
runtime_smoke: n/a -- documentation of an owner-taken milestone, no R/ package runtime behavior changed
changelog_ref: CHANGELOG.md 2026-07-09 "CRAN 2.0.0 submitted to CRAN submission team (Session 329)"
commit: 8bb126ce
```

```handoff
session: S328
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 9
active_task: Phase 5b cross-platform checks complete and clean (win-builder x3 0/0/1 expected NOTE, R-hub linux/windows/macos 0/0/0). cran-comments.md fully populated. Only remaining: owner's submit_cran() HARD STOP.
what_was_done: After the S327 .Rbuildignore fix, owner re-ran the full Phase 5b runbook. win-builder x3 all came back 0/0/1 NOTE -- fetched each 00check.log directly and confirmed the remaining note is exactly the expected CRAN-incoming-feasibility note (EHR/Raboin/kinships, correctly spelled). R-hub v2: windows+macos Status:OK on first run (verified via gh run view --log, not just job-success flag); linux failed at setup-deps (Pandoc download 504, confirmed transient infra via the actual log, matching runbook precedent) then Status:OK on a linux-only re-run (watched both runs via gh run watch in background). Updated cran-comments.md: filled in both Test-environments placeholders with real results, reconciled NOTE 1's misspelled-words list to the exact set win-builder flagged (EHR/Raboin/kinships, dropped LabKey/Macaca mulatta) per the runbook's own Sec4.2 instruction. Updated the plan doc's Phase 5 status block + Sec9 table row. Commit: 7517124d (claim stub: 8fcc9170).
next_steps: Owner runs devtools::submit_cran() (or the web form) and clicks the maintainer-email confirmation link -- the plan's HARD STOP, cannot be delegated. After CRAN accepts, Phase 6 (tag + GitHub release + dev-version bump to 2.0.0.9000) is a separate future session, only after the acceptance email. Otherwise one of the 8 open GitHub issues (#116, #37, #36, #28, #12, #11, #10, #5) remains available.
key_files: cran-comments.md (Test environments filled in, NOTE 1 words reconciled), docs/planning/cran-2.0.0-submission-plan.md (Phase 5 status completion note + Sec9 row), SESSION_NOTES.md (S328 handoff), HANDOFFS.md (this receipt)
gotchas: submit_cran() is the owner's action only -- do not attempt to trigger it even if asked to "finish Phase 5b." Three consecutive sessions (S326/S327/S328) each briefly edited a file before writing the Phase 1B claim stub, self-caught every time before a commit landed -- not yet a formal PROJECT_LEARNINGS entry, but a 4th recurrence should trigger one.
runtime_smoke: n/a -- cran-comments.md is .Rbuildignore'd prose, no R/ package runtime behavior changed
changelog_ref: CHANGELOG.md 2026-07-09 "Fold Phase 5b cross-platform results into cran-comments.md, all clean (Session 328)"
commit: 7517124d
```

```handoff
session: S327
date: 2026-07-09
status: complete
self_score: 9
predecessor_score: 7
active_task: .Rbuildignore gap fixed and verified. Owner needs to re-run the Phase 5b runbook (win-builder x3 + R-hub v2) against the corrected tree before folding results into cran-comments.md and submitting.
what_was_done: Owner ran the S326-handed-off Phase 5b runbook; all 3 win-builder results came back 0/0/2 NOTEs. NOTE 1 matched cran-comments.md's pre-explained content. NOTE 2 was new and real (not the plan's anticipated local-HTML-manual note): "Non-standard files/directories found at top level: BOOTSTRAP.md, CONTEXT_TEMPLATE.md, HANDOFFS.md, dashboard_history.jsonl" -- confirmed identical across all 3 logs via WebFetch of each 00check.log. Root cause: S324 methodology sync added these (3 tracked root docs + 1 gitignored-but-not-Rbuildignored generated file) after the S322 local gate ran; gitignore and Rbuildignore are separate mechanisms. Fixed: 4 anchored lines added to .Rbuildignore's existing "Methodology framework files" section. Verified: R CMD build . + tar tzf grep -- files no longer ship, top-level listing back to standard set; artifact removed, not committed. Updated the plan doc (Phase 5 status correction note, new Dragon #11, Sec9 table) and added PROJECT_LEARNINGS.md Learning 303. Commit: c1fc47b9 (claim stub: a1dadfd3).
next_steps: Owner re-runs win-builder x3 against a freshly built tarball (should come back 0/0/1 NOTE now); re-runs rhub::rhub_check() once this fix is pushed (the in-flight run checked the pre-fix tree); folds clean results into cran-comments.md's Test environments section + reconciles the misspelled-words list; then submit_cran() is the owner's HARD STOP action.
key_files: .Rbuildignore (4 new lines), docs/planning/cran-2.0.0-submission-plan.md (Phase 5 status correction + Dragon #11 + Sec9 row), PROJECT_LEARNINGS.md (Learning 303), SESSION_NOTES.md (S327 handoff), HANDOFFS.md (this receipt)
gotchas: The 3 completed win-builder runs and the in-flight R-hub run all reflect the PRE-FIX tree -- do not treat them as final; re-run all cross-platform checks after this fix is pushed. Before any future cross-platform run, diff the root-level file listing against .Rbuildignore coverage directly (a git-log-scoped R/tests/DESCRIPTION drift check cannot see new root-level files, per Dragon #11 / Learning 303).
runtime_smoke: n/a -- build-hygiene/config fix, no R/ package runtime behavior changed; verified via R CMD build + tar tzf per Phase 1's own classification
changelog_ref: CHANGELOG.md 2026-07-09 "Fix .Rbuildignore gap surfaced by win-builder NOTE 2 (Session 327)"
commit: c1fc47b9
```

```handoff
session: S326
date: 2026-07-08
status: complete
self_score: 8
predecessor_score: 8
active_task: CRAN 2.0.0 Phase 5b readiness re-verified, zero drift found. Still PENDING, owner-triggered (win-builder x3 + R-hub v2 need the owner's GitHub PAT and email). 8 open GitHub issues untouched, no priority set among them.
what_was_done: Asked the owner via AskUserQuestion how to scope Phase 5b (verify-only vs. live-run vs. attempt-to-trigger); owner chose verify-only. Confirmed zero drift since S322/S323: git log --oneline 2abfc783..HEAD -- R/ tests/ DESCRIPTION empty; origin/master 0/0 vs HEAD; DESCRIPTION Version still 2.0.0; cran-comments.md and the Phase5 runbook re-read clean; Rscript introspection confirmed devtools 2.5.2/rhub 2.0.1/gitcreds 0.1.2 installed with function signatures still matching the runbook's calls. Added a verification-status note to docs/planning/cran-2.0.0-submission-plan.md's Phase 5 status block + Sec9 table row. No R/tests/DESCRIPTION/cran-comments.md/runbook changes needed. Commit: 4e6193cb (claim stub: a9ebea7e).
next_steps: Either (a) owner runs the Phase 5b runbook (docs/planning/cran-2.0.0-phase5-runbook.md Quick sequence) whenever ready -- folding real results into cran-comments.md and submitting is a separate future session -- or (b) pick up one of the 8 open GitHub issues (#116, #37, #36, #28, #12, #11, #10, #5) -- owner's call, none more urgent.
key_files: docs/planning/cran-2.0.0-submission-plan.md (Phase 5 status block + Sec9 table Phase 5b row), SESSION_NOTES.md (S326 handoff), HANDOFFS.md (this receipt), CHANGELOG.md (new [ad hoc] entry)
gotchas: Phase 5b's actual cross-platform runs remain owner-only -- don't trigger devtools::check_win_*()/rhub::rhub_check() without explicit owner request, despite the plan's Phase 5 prose reading as "fine for the agent to run"; the runbook's SAFEGUARDS framing + repeated owner precedent (S135/S242/S320/S323/S325/S326) overrides that. When adding a HANDOFFS.md receipt, insert directly after the "Receipts go below, newest on top" sentinel comment, not under the "Three files..." heading (this session's own near-miss, self-caught before commit).
runtime_smoke: n/a -- docs/planning-only, no R/ package runtime behavior changed
changelog_ref: CHANGELOG.md 2026-07-08 "CRAN 2.0.0 Phase 5b readiness re-verified, zero drift (Session 326)"
commit: 4e6193cb
```

```handoff
session: S325
date: 2026-07-08
status: complete
self_score: 8
predecessor_score: 7
active_task: CHANGELOG.md ledger-format gap resolved (freeze legacy, go forward). CRAN 2.0.0 Phase 5b remains owner-triggered, not started. 8 open GitHub issues untouched, no priority set among them.
what_was_done: Added an "Authoritative Action Ledger" intro + "How to add an entry" section (source-tag rules: [issue #<N>]/[BL-<N>]/[ad hoc]) to CHANGELOG.md, copied from the real canonical starter-kit/CHANGELOG.md seed (~/Development/methodology). Added a "## Legacy history (pre-ledger format, Sessions 1-324)" boundary marker; the 303 existing entries below it are byte-for-byte unchanged. Wrote this session's own action as the first canonical-format entry above the marker. Updated CLAUDE.md's Adaptations section (CHANGELOG-gap note -> resolution note; corrected a stale "33 learnings" pointer to the actual 302). Backfilled HANDOFFS.md's S324 commit:pending field to 0c3af8b9. Added PROJECT_LEARNINGS.md Learning 302. Commit: 07ae8aec (claim stub: 68f3117f).
next_steps: Either (a) resume docs/planning/cran-2.0.0-submission-plan.md Phase 5b (owner-triggered win-builder x3 + R-hub v2), or (b) pick up one of the 8 open GitHub issues (#116, #37, #36, #28, #12, #11, #10, #5) -- owner's call, none more urgent.
key_files: CHANGELOG.md:1-61 (new intro/how-to-add-an-entry/legacy-marker/S325 entry), CLAUDE.md (Adaptations section), HANDOFFS.md (S324 commit backfill), PROJECT_LEARNINGS.md (Learning 302)
gotchas: New CHANGELOG.md entries always go above "## Legacy history", never inside it. Every new entry needs exactly one [issue #<N>]/[BL-<N>]/[ad hoc] source tag. Neither CRAN Phase 5b nor any open issue is more urgent than another right now.
runtime_smoke: n/a — docs-only, no R/ package runtime behavior changed
changelog_ref: CHANGELOG.md 2026-07-08 "Adopt the canonical Authoritative Action Ledger format going forward (Session 325)"
commit: 07ae8aec
```

```handoff
session: S324
date: 2026-07-08
status: complete
self_score: 8
predecessor_score: 9
active_task: Methodology sync to canonical v3.4 — complete. CRAN 2.0.0 Phase 5b (win-builder/R-hub) remains owner-triggered, not started this session.
what_was_done: Ran bin/sync --source=local --force (full unshallowed clone of KJ5HST/methodology, cross-checked against rmsharp/methodology fork) to update SESSION_RUNNER.md, SAFEGUARDS.md, RECOMMENDED_SKILLS.md, methodology_dashboard.py, docs/methodology/{ITERATIVE_METHODOLOGY,HOW_TO_USE}.md, all 9 docs/methodology/workstreams/*.md; created BOOTSTRAP.md, CLAUDE_TEMPLATE.md, CONTEXT_TEMPLATE.md, HANDOFFS.md. Manually refreshed docs/methodology/README.md (not manifest-tracked). Updated CLAUDE.md (FM count 25->27, new CHANGELOG ledger-gap note) and .gitignore (dashboard_history.jsonl). CHANGELOG.md entry: 2026-07-08 Session 324. Commit: 0c3af8b9.
next_steps: Either (a) resume docs/planning/cran-2.0.0-submission-plan.md Phase 5b — owner-triggered win-builder x3 + R-hub v2, see SESSION_NOTES.md S323 entry — or (b) run a dedicated CHANGELOG.md ledger-format migration session per CLAUDE.md's new Adaptations note (canonical v3.1+ ledger format vs. this project's ~30+-session dated-subsection history).
key_files: CLAUDE.md (Adaptations section, FM-count + CHANGELOG-gap edits), CHANGELOG.md:17-28 (this entry), PROJECT_LEARNINGS.md Learning 301 (shallow-clone / force-overwrite-verification findings), .gitignore (dashboard_history.jsonl), SESSION_RUNNER.md + SAFEGUARDS.md (full canonical replace, now v3.4)
gotchas: CHANGELOG.md is deliberately still old-format (SEED disposition, bin/sync never auto-migrates it) — do not force new-format `[SOURCE]`-tagged entries into it without a dedicated migration pass. Any future methodology sync MUST git fetch --unshallow the canonical clone first, or bin/status falsely reports every TRACKED file as "locally modified" (Learning 301).
runtime_smoke: n/a — docs/infra-only, no R/ package runtime behavior changed
changelog_ref: CHANGELOG.md 2026-07-08 "Update methodology to canonical v3.4 (Session 324)"
commit: 0c3af8b9
```
Synced this project's methodology tooling from a stale v2.6 to the current canonical v3.4 (8 tagged releases), per the user's literal BOOTSTRAP.md-documented request. Verified before force-overwriting the two flagged files (no real customization lost — traced to a prior session's pre-release wording adoption, not a hand-edit). Deferred the CHANGELOG.md ledger-format migration as its own future task rather than bundling a large history reformat into this sync, per the tool's own documented guidance. Self-score 8/10: +diligent verification before any destructive action (shallow-clone bug caught, fork cross-check, project-term grep before --force), +correct scope boundary (didn't reformat 30+ sessions of CHANGELOG history), +adopted the new HANDOFFS.md receipt immediately rather than waiting for a future reconcile; -did not open a Phase 1B pending stub for this deliverable before starting (the new protocol requiring it wasn't yet synced in when the task began — retroactive rather than upfront), -did not restate "TDD Phase: N/A" inline at the top of each chat response per CLAUDE.md's literal enforcement rule during this task. Predecessor (S323) scored 9/10 on documentation quality/completeness alone — its CRAN-plan handoff was not exercised this session since the user redirected to an unrelated deliverable, which is not a mark against it.
