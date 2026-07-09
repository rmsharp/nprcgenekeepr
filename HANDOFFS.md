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
session: S330
date: 2026-07-09
status: pending
self_score: pending
predecessor_score: pending
active_task: Planning session for Document 1 -- technical description of the v1.0.8 -> v2.0.0 transformation (Shiny modules, new features, enhanced testing, Claude CLI use), with proposed tables/graphics. Document 2 (package-purpose/usage doc) deferred to its own future planning session.
what_was_done: pending
next_steps: pending
key_files: pending
gotchas: pending
runtime_smoke: pending
changelog_ref: pending
commit: pending
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
