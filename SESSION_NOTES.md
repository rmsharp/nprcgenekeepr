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

### What Session 600 Did
**Deliverable:** 3rd redesign attempt for the duplicate-occurrence-selection centering fix
(`docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md` §8.6) — staying on
the substitution-formula layer (owner-picked via `AskUserQuestion` over pivoting to a post-hoc
bounded nudge, running both in parallel, or accepting Track 3's trade-offs as permanent), but
requiring every candidate to pass a magnitude-stress fixture from round 1 (§8.6 item 1, and S599's
own self-identified process gap), and resolving the TDD white-box test problem (§8.6 item 2) as part
of the design itself. (IN PROGRESS)
**Started:** 2026-08-17.
**Status:** Session claimed. Work beginning.
**Ledger:** `CHANGELOG: pending` — set at claim; this session's actions are recorded in
`CHANGELOG.md` at Phase 3F. Until close-out, this line is the crash breadcrumb for the next
session's reconcile.

### Session 598 Handoff Evaluation (by Session 599)
**Score: 9/10.** **What helped:** the investigation doc's §6 was the entry point exactly as
instructed — this session started design work directly from its 7 open questions with zero
rediscovery, and its explicit "2 candidate guards were tried live and both failed" note (question 1)
saved real time by preventing a design agent from re-trying either. `key_files` correctly pointed at
`R/makePedigreeDiagramData.R:966-1010` — re-verified unchanged before use. The `gotchas` field's
"do not call it Track 4" was heeded throughout (every candidate/design this session produced was
explicitly named something else). **What was wrong:** nothing found — every claim re-verified
live this session (the `-6`/`0.12`/120x-multiplier numbers, the Track C `0.2` figure, the
`duplicates` structural-insertion-order determinism) matched S598's own figures exactly.
**What was missing:** S598 could not have anticipated that a REPAIRED design addressing its own
named counter-example would itself have a deeper, orthogonal problem (unbounded substitution
magnitude, §8.4) — that axis was invisible until this session's own round-2 critique went looking
for it; not a fair gap in S598's handoff, since S598's own critique was killed by the qualification
question first and never got far enough to probe magnitude. **ROI:** high — the §6 open-questions
list drove this entire session's design work with no rediscovery cost.

### What Session 599 Did
**Deliverable: a further investigation-document update, not a ratified plan** — appended §8 to
[`docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md`](docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md).
Ran a fresh 12-agent design→synthesize→critique(→repair→critique) `Workflow` against S598's §6 open
questions; found a repaired design that still fails adversarial critique on a genuinely new axis
(substitution magnitude, not qualification logic); presented the finding via `AskUserQuestion` and,
per owner direction, held rather than shipping or iterating further. **DONE** in the sense the
session's actual final deliverable shape allows — this is the second consecutive session on this
fix to end in "hold," and §8.6 explicitly flags that a 3rd attempt should first weigh whether the
whole approach is right, not just retry the same substitution-formula shape a 3rd time.
**Started/Completed:** 2026-08-16/2026-08-17.

**What actually happened, in order:**

1. **Full Phase 0 orientation** (`SESSION_RUNNER.md`/`SAFEGUARDS.md` read in full; `SESSION_NOTES.md`;
   `gh issue list` — 13 open; `gh run list --branch master` — last 10 runs all `completed success`;
   `git status`/`log`/`diff --stat` — clean tree except 4 untracked `docs/planning/*.html` renders,
   each verified live to have a tracked `.qmd` source, not a ghost session; `methodology_dashboard.py`
   — 96/100 health, 0 High+ risk; ledger reconcile — `CHANGELOG.md`/`HANDOFFS.md` frontiers both ==
   HEAD, no gap; also cross-checked both sequencing-audit docs per `CLAUDE.md`'s own S507 gotcha —
   found nothing new beyond what `BACKLOG.md` already surfaces (the pedigree-diagram audit's own
   Tier 1/2 items are all closed; the genetic-metrics audit's #148 item is already `BACKLOG.md`'s own
   tracked "scope-narrowing" item)). Rendered a 3-item `BACKLOG.md`-sourced priorities picker via
   `AskUserQuestion` (Track 4 centering redesign / issue #148 scope-narrowing / S582 screenshot
   check) — **user picked "Track 4 centering redesign."**
2. **Phase 1**: stated deliverable/workstream back to the user
   (`docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md`, matching the parent collision-avoidance
   plan's own precedent) and declared TDD phase **PRE-RED** (planning-only, no RED/GREEN/REFACTOR
   code this session, per `SESSION_RUNNER.md`'s Planning Sessions discipline).
3. **Phase 1B claim**: stub written to `SESSION_NOTES.md` + `status: pending` receipt opened in
   `HANDOFFS.md`, committed (`02efe41a`) before any technical work, per protocol.
4. **Phase 2 Research**: confirmed no code drift since the investigation doc's own HEAD
   (`git diff f7afa0fd..HEAD --stat -- R/ tests/` empty), then re-read
   `R/makePedigreeDiagramData.R:455-524` and `:955-1015` fresh (not from memory) to confirm the
   `duplicates`-construction loop's structural-insertion-order determinism and the exact Pass
   1/clamp/dupX splice zone the investigation doc claimed — both matched exactly.
5. **12-agent `Workflow`** (design→synthesize→critique→repair→critique, detailed in the investigation
   doc's new §8): 4 independent candidate qualification-rule designs, each live-verified via
   `pkgload::load_all()` + real `.buildMatingUnitForest()`/`.positionMatingUnitForest()` internals
   against the target case and the primary counter-example; a synthesis combining the strongest
   candidate's mechanism; a 3-lens adversarial critique (invariant preservation, edge cases,
   test-blast-radius/TDD-sequencing — same 3 lenses S598 used) that found a NEW compounding misfire
   (2 children of one union each substituting toward a shared 3rd sibling, `0.5→3.775`); a bounded
   repair round adding an abstention ceiling that neutralized it; a second critique pass on the
   repair that **also** returned `designStillSound: false` on 2 of 3 lenses — an unbounded-magnitude
   problem in the untouched "safe" single-substitution case (`-0.05→-16.238` as an unrelated fan-out
   grew, live-measured) and a TDD white-box-test necessity finding. All 12 agents completed, 0
   errors (`wf_115a9428-581`).
6. **Presented the round-2 finding via `AskUserQuestion`** (3 options: hold-and-write-investigation /
   one-more-targeted-repair-round / ship-disclosed). **User picked hold.** Appended §8 to the
   investigation document (workflow structure, all 4 candidates condensed into a table, the
   synthesis/round-1/repair/round-2 findings in full, what was reconfirmed vs. newly found, and an
   updated §8.6 open-questions list superseding §6). Updated the status banner and decision log.
   Updated `BACKLOG.md`'s Track 3 trade-offs item with an S599 progress note pointing at §8.
   Verified every new cross-reference resolves (the workflow journal file, all internal §-references,
   the re-checked `R/makePedigreeDiagramData.R` line claims) before committing.
7. Added `PROJECT_LEARNINGS.md` Learnings 613 (a repair earns a fresh full critique, not a narrower
   "did this fix the one thing" check) and 614 (verifying direction is not verifying magnitude, for
   any substitution-based design) — matching the file's own established format. Refreshed `CLAUDE.md`'s
   `PROJECT_LEARNINGS.md` pointer line (612→614 learnings).

**Runtime smoke test (Phase 3E):** n/a — docs-only planning/investigation session; no `R/`/`tests/`
file touched or shipped (confirmed via `git status`/`git diff --stat` before close-out).

**Close-out checklist mapping** (`CLAUDE.md`): citation/tutorial-article/`NEWS.Rmd`/
`a2interactive.Rmd`/`_pkgdown.yml`/lint checklists all N/A (no `.R` file touched, no new exported
function or Shiny feature, no runtime behavior changed). GitHub issue close-out N/A (this item was
never filed as its own issue, matching `BACKLOG.md`'s established precedent for this same-root-cause
finding, same as S598).

**Self-assessment (Session 599): 8/10.** **Strengths:** (1) Ran a genuinely adversarial second
critique round against the repair itself, rather than treating "the repair fixed the finding it was
built for" as sufficient — found a real, deeper, previously-undiscovered problem (magnitude, not
direction) that none of the 6 designs this session produced (4 candidates + synthesis + repair) had
been tested against. (2) Recognized the workflow's bounded repair allowance was exhausted and
stopped to ask the owner rather than open-ended iterating or silently shipping — matching S598's own
established precedent exactly, at a second, deeper decision point. (3) Wrote a substantive,
well-organized investigation update (§8, with a condensed comparison table for the 4 candidates)
rather than a thin "still broken" note — a future session gets the same "start here, don't re-derive"
value S598's own §6 gave this session. (4) Independently re-verified load-bearing claims at every
level (re-read the source code fresh rather than trusting the investigation doc's line numbers;
the synthesis and both critique rounds each independently re-derived numbers rather than trusting
sibling agents' self-reports) — no claim in the final document rests on unverified agent output.
(5) Every new cross-reference verified to resolve before commit. **Weaknesses:** (1) The 12-agent
workflow was expensive (~1.6M subagent tokens, ~62 minutes) and did not converge to a ratified
design — in retrospect, including a magnitude-stress fixture (grow an unrelated subtree, check the
substituted value stays bounded) in the FIRST round's own candidate-verification requirements, not
only in the round-2 critique, might have surfaced this problem one cycle earlier and saved the
repair round's own cost. (2) Did not proactively flag "the substitution formula itself has never
been questioned, only the logic gating it" as a risk before spending the full budget — this only
became visible once the critique itself found it, though the investigation doc's own §6 (written by
S598) also never named this axis, so the gap isn't unique to this session's own planning. **ROI:**
moderate-to-high — no design shipped, but a second consecutive live-verified failure at increasing
depth (qualification logic, then magnitude) is real, hard-won evidence that narrows what a 3rd
attempt needs to prioritize (§8.6 item 1), and item 3's explicit "reconsider the approach" flag may
save a 3rd session from repeating the same substitution-formula shape a 3rd time.

**Gotchas for the next session:** (1) Start at the investigation document's **§8.6**, not §6 (§6 is
now marked superseded). (2) The core open problem is the substitution formula's own magnitude
(`rawDupX <- rawFinalUnitX[V] + minSep*0.4`), not the qualification/abstention logic around it —
every candidate this session and S598 tried used that formula unchanged; a 3rd attempt should treat
bounding it as the primary target, not a footnote. (3) Before diving into a 3rd redesign attempt,
read §8.6 item 3 first — 2 independent attempts have now failed adversarial critique, and it may be
worth an explicit go/no-go on whether this is the right layer to fix child-centering quality at all,
rather than assuming a 3rd attempt at the same mechanism shape will succeed. (4) The workflow's own
scratchpad R scripts (fixture constructions, the fan-width magnitude sweep) were not committed
(ephemeral, matching S598's own established precedent) — reconstruct from the investigation doc's
§8.4 prose (exact numbers given) if needed again, not from memory of this note.

### Session 597 Handoff Evaluation (by Session 598)
**Score: 7/10.** **What helped:** `HANDOFFS.md`'s `next_steps` named exactly 3 candidates
(Track 3 trade-offs decision / issue #161 / S582 screenshot check), all still accurate and
immediately actionable — the Phase 0 priorities picker rendered them verbatim, and the user's own
pick ("Track 3 trade-offs decision") came directly from that list with zero rediscovery needed.
The `gotchas` field's warning that the refreshed external artifact was never committed (render
script lived only in scratchpad) was correctly scoped as "not this session's problem" and ignored,
appropriately. **What was wrong:** nothing found — S597's own claims (ledger backfill, artifact
staleness finding, all 3 candidates left exactly as S596 left them) were re-verified where it
mattered (the `CHANGELOG.md`/`HANDOFFS.md` frontier check independently confirmed no new gap) and
held up. **What was missing:** S597's handoff couldn't have anticipated that "Track 4," the name
its own `next_steps` used for the child-centering substitution, collides with an already-shipped,
unrelated plan document (`pedigree-diagram-track4-gen-aware-anchor-plan.md`) — this only surfaced
once this session actually went to go read that plan and found two different documents both
using the name for different things. Not a fair ding against S597, which was itself relaying
`BACKLOG.md`'s own (already-established) shorthand. **ROI:** high — the 3-candidate list, still
valid, drove this session's entire Phase 1 pick with no rediscovery cost.

### What Session 598 Did
**Deliverable: an investigation document, not a ratified implementation plan** —
[`docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md`](docs/planning/pedigree-diagram-duplicate-occurrence-centering-investigation.md).
**DONE**, in the sense the session's actual final deliverable shape allows: research/verify/
adversarially-critique the deferred "duplicate-occurrence-selection" fix (`BACKLOG.md`'s informal
"Track 4," the child-centering half of Track 3's disclosed trade-offs) against current HEAD, then
**hold** — owner-directed via `AskUserQuestion` — rather than adopt a design a live adversarial
check found a genuine correctness gap in. **Started/Completed:** 2026-08-16.

**What actually happened, in order:**

1. **Full Phase 0 orientation** (SESSION_RUNNER.md/SAFEGUARDS.md read in full; `SESSION_NOTES.md`;
   `gh issue list` — 13 open; `gh run list --branch master` — last 10 runs all `completed success`;
   `git status`/`log`/`diff --stat` — 15 commits ahead of `origin/master`, 4 untracked
   `docs/planning/*.html` renders, verified live (not just trusted from S597's own note) each has a
   tracked `.qmd` source; `methodology_dashboard.py` — 96/100 health, 0 High+ risk; ledger reconcile
   — `CHANGELOG.md`/`HANDOFFS.md` frontier both == HEAD, no gap). Rendered the `BACKLOG.md`-sourced
   4-item priorities picker (capped per `CLAUDE.md`'s own rule, including the sequencing-audit
   cross-check that surfaced issue #148's scope-narrowing item as a 4th option not inline-tagged in
   `BACKLOG.md`) via `AskUserQuestion` — **user picked "Track 3 trade-offs decision."**
2. **Phase 1 scope narrowing**, own `AskUserQuestion`: the item bundles 2 distinct costs
   (child-centering degradation, D1 bar-vs-bar residual) with 3 named resolution paths for the
   former specifically. User picked **"Scope Track 4 (centering)"** — planning-only, matching
   `SESSION_RUNNER.md`'s Planning Sessions discipline (no RED/GREEN this session).
3. **Phase 1B claim**: stub written to `SESSION_NOTES.md` + `status: pending` receipt opened in
   `HANDOFFS.md`, committed (`9b94d7ce`) before any technical work, per protocol.
4. **Design refresh workflow** (6 agents: 3 parallel verify — code-state relocation, live
   re-verification via `pkgload::load_all()` against the exact `.commentOneFixture()` fixture, and
   a grep-based evidence inventory — then 3 parallel adversarial-critique lenses — invariant
   preservation, edge cases, test-blast-radius/TDD-sequencing). Confirmed the original S592
   12-agent-workflow design (never adopted, named "fix (a)" in that transcript) still fits current
   HEAD exactly at `R/makePedigreeDiagramData.R:974-994`, and live-reproduced its headline number
   (0.12 shipped → -6 under the fix, on the issue #160 comment-1 fixture). **The edge-cases critique
   found `designStillSound: false`**: a live-verified fixture where one individual mates 2 different
   co-siblings of the same union makes the fix's own qualification rule move the union's center
   *farther* from true, not closer — inside the design's own stated scope, not an excluded shape.
5. **User-directed browser-comparison side quest** (mid-session, before processing the workflow
   completion): rendered the exact issue #160 comment-1 fixture through both `kinship2` and
   `nprcgenekeepr` (`chromote` + `visNetwork::saveWidget`, ad hoc scratchpad script, not committed)
   for a direct visual comparison, at the user's request. Traced every edge in the nprcgenekeepr
   render against the fixture's own sire/dam columns before presenting (ground-truth verification,
   not just "looks uncorrupted," per `MEMORY.md`'s standing preference) — confirmed topologically
   correct; the one visible positional anomaly (`__union_1` sitting almost on top of P2, not
   centered between its children) is precisely the phenomenon this session's own investigation is
   about, not a rendering defect.
6. **Presented the edge-case finding via `AskUserQuestion`** (3 options: ship-as-designed-with-
   disclosure / add-an-untested-guard / hold-for-redesign). **User picked hold.** Wrote the full
   investigation document (§0-§7: naming-collision flag, the original design verbatim, fresh
   code-state/live-number/grep-inventory verification, all 3 critique reports in full, 7 concrete
   open questions for a future redesign session, decision log) rather than a ratified plan — status
   banner at the top makes this explicit. Verified every new cross-reference in the document
   resolves (`docs/planning/pedigree-diagram-track6-...md`, this session's own workflow journal
   path, `PROJECT_LEARNINGS.md` Learnings 585/588) before committing.
7. Updated `BACKLOG.md`'s Track 3 trade-offs item with an S598 progress note pointing at the new
   investigation doc and naming the concrete next step (a redesign session against the doc's §6).

**Runtime smoke test (Phase 3E):** n/a — docs-only planning session, no `R/`/`tests/` code
touched or shipped. The kinship2/nprcgenekeepr comparison renders were ad hoc scratchpad scripts
(not committed), matching S597's own established precedent for this kind of side-quest.

**Close-out checklist mapping** (`CLAUDE.md`): citation/tutorial-article/`NEWS.Rmd`/
`a2interactive.Rmd`/`_pkgdown.yml`/lint checklists all N/A (no `.R` file touched, no new exported
function or Shiny feature, no runtime behavior changed). GitHub issue close-out N/A (this item was
never filed as its own issue, matching `BACKLOG.md`'s own established precedent for this
same-root-cause finding).

**Self-assessment (Session 598): 8/10.** **Strengths:** (1) Did not implement a design an
adversarial workflow found a genuine, live-verified correctness gap in, even though the gap was
found only after a first `AskUserQuestion` had already committed to scoping this fix — surfaced it
immediately and let the owner re-decide rather than quietly shipping a narrower guard I would have
had to invent (and, per my own live arithmetic check mid-session, would likely have gotten wrong —
2 candidate guards considered and rejected in real time, both failing to actually exclude the
counter-example). (2) Independently verified the original S592 design against current HEAD rather
than trusting either its own historical claims or `BACKLOG.md`'s summary of it — found and
corrected a real discrepancy (the shipped clamp produces 0.12, not the design-time-predicted exact
0, because of a de-collision nudge the original design predates). (3) Found and flagged the "Track
4" naming collision between 2 unrelated plan documents before it could confuse a future session
mid-implementation. (4) Kept the mid-session user-directed visual-comparison request from derailing
the planning workstream — did it, verified it against ground truth, then returned cleanly to
processing the just-completed workflow. (5) Every new cross-reference in the investigation document
verified to resolve before commit, not assumed. **Weaknesses:** (1) The session's actual deliverable
shape (an investigation, not a plan) only became clear mid-session, after the workflow ran — a
sharper Phase 1 framing might have named this possibility explicitly before committing to "scope
Track 4 (centering)" as if a clean plan were the likely outcome. (2) The comparison-render scratchpad
script (`render_compare.R`) was not committed, matching precedent but meaning a future session
wanting the same comparison must reconstruct it from this note rather than finding a checked-in
copy — flagged as a gotcha below. **ROI:** high — the session avoided shipping a design with a
verified-wrong-direction failure mode inside its own claimed scope, at the cost of not producing a
directly implementable plan this session; the investigation document should make the eventual
redesign session materially faster than starting cold.

**Gotchas for the next session:** (1) Do not reuse "Track 4" as a name for whatever plan eventually
ships the duplicate-occurrence-selection fix — it collides with the shipped
`pedigree-diagram-track4-gen-aware-anchor-plan.md`; see the investigation doc's §1. (2) The
kinship2/nprcgenekeepr comparison render script from this session
(`render_compare.R`, plus `chromote`'s `set_viewport_size()` — not
`screenshot(width=,height=)`, which errors — for sizing a headless-Chrome screenshot of a
`visNetwork` htmlwidget) was not committed; reconstruct from this note if needed again, using
`tests/testthat/test_resolveEdgeNodeCollisions.R:271-281`'s `.commentOneFixture()` for the same
fixture. (3) The investigation document's §6 (7 open questions) is where a redesign session should
start — do not re-run the verification workflow from scratch, its findings are fresh as of this
session (current HEAD `f7afa0fd`+this session's own docs commits).

### Session 596 Handoff Evaluation (by Session 597)
**Score: 8/10.** **What helped:** `HANDOFFS.md`'s `next_steps` field named 3 clear, accurate
candidates (Track 3's disclosed trade-offs decision; issue #161's now-unblocked design call; the
S582 stale-screenshot check) — all 3 fed directly into this session's Phase 0 priorities report
verbatim, with no rediscovery needed. **What was wrong:** S596's own self-assessment claimed full
ledger discipline ("Missed logging my own claim commit ... backfilled at close-out, same
session") but this session's Phase 0 ledger reconcile found a SECOND, un-backfilled gap S596 never
caught: 2 trailing close-out commits (`6261d6f9` Learning 609 + `CLAUDE.md` refresh, `6ba6289e`
the close-out itself) had no matching `CHANGELOG.md` entry, unlike S595's own precedent of a
dedicated "close-out" entry. Backfilled this session (`8fc0e383`) — see that commit and this
session's own CHANGELOG entry below. **What was missing:** nothing the handoff could reasonably
have anticipated — S596 could not have predicted this session would decline all 3 offered
candidates in favor of a user-directed browser detour. **ROI:** high on the 3-candidate list
itself (immediately actionable, still fully valid); moderate overall once the missed ledger entry
is weighed in — the gap cost this session one Phase 0 backfill cycle to catch and fix.

### What Session 597 Did
**Deliverable: none of S596's 3 offered BACKLOG priorities were picked or advanced.** This session
did not complete Phase 1 (no task was ever claimed via `AskUserQuestion`) — the user interrupted
the initial priorities question to ask clarifying questions instead, and the conversation then
followed a different thread through to a user-directed close-out request (context budget
concerns). Recorded honestly as a process deviation, not a completed deliverable.
**Started/Completed:** 2026-08-16.

**What actually happened, in order:**

1. **Full Phase 0 orientation.** `SESSION_RUNNER.md`/`SAFEGUARDS.md` read in full;
   `SESSION_NOTES.md` read; `gh issue list` (13 open); `gh run list --branch master` (last 4 runs —
   lint/pkgdown/test-coverage/R-CMD-check, from S593's push — all `completed success`); `git
   status`/`log`/`diff --stat` (branch 13 commits ahead of `origin/master`, 4 untracked
   `docs/planning/*.html` renders confirmed to have tracked `.qmd` sources — not a ghost session,
   matches the established never-track-planning-renders convention); `methodology_dashboard.py`
   (96/100 health, 0 High+ risk). **Ledger reconcile found and backfilled a real 2-commit
   `CHANGELOG.md` gap** left by S596 (detailed in the handoff evaluation above) — commit
   `8fc0e383`, `docs(changelog): backfill S596 close-out ledger entry`. Rendered the
   `BACKLOG.md`-sourced priorities picker (3 candidates, matching S596's own `next_steps`) via
   `AskUserQuestion` — **user declined the picker to ask a clarifying question instead** ("explain
   Track 3's 2 disclosed trade-offs").

2. **Conversational Q&A, no files touched.** Explained Track 3's 2 disclosed trade-offs
   (child-centering degradation, D1 bar-vs-bar worsening) from `BACKLOG.md`/`CHANGELOG.md`
   evidence. User asked a genuine architecture question — "why can't the D1 bar-vs-bar residual be
   avoided by just spacing the x-ranges further apart?" — answered by reading
   `.positionMatingUnitForest()`'s contour-merge code directly (`R/makePedigreeDiagramData.R:584-
   1010`) and the plan doc's own §1 record of 3 prior global-relayout investigations (S588/S589/
   S590) already closed as NOT FEASIBLE for the same structural reason (a high-mate-count hub
   individual's several subtrees compete for one horizontal budget). User then said "let's keep as
   possibilities Track 4 and ... a bar-aware detect-and-jog repair" — **this edit was not made in
   the moment** (the conversation moved to an unrelated browser request before it was written) —
   **completed retroactively at close-out** (see item 4 below), not silently dropped.

3. **User-directed browser detour → artifact regeneration side-quest.** User asked to view a
   specific `claude.ai/code/artifact/...` URL ("Pedigree Fidelity Proof," a prior session's
   kinship2-vs-nprcgenekeepr comparison). Browser scroll/resize automation failed repeatedly (5+
   distinct approaches — wheel, Page Down, spacebar, fullscreen, `resize_window` timeout) — stopped
   retrying per the harness's own "avoid rabbit holes" guidance and asked the user for help, who
   then pasted the relevant screenshots directly. **The artifact's own "previously-unreported
   defect" callout turned out to be stale** — traced its stamped commit (`f12e7cbb`) to Session
   590, predating issue #160's filing (`5bd295c4`) and all 3 fix tracks; the callout was verbatim
   `PROJECT_LEARNINGS.md` Learning 604, already fixed. Regenerated both plates
   (`kinship2::sample.ped` family 2; the issue #160 comment-1 `P1/P2/X/A/Y/W/C1/GC/C2` fixture)
   fresh against current HEAD via `pkgload::load_all()` + `chromote`, with **independently
   re-derived** (not calling `.resolveEdgeNodeCollisions()` itself) ground-truth collision checks:
   0 same-row collisions on both plates; Track 1's fix confirmed via exact coordinates (D1 bar row
   at y=90, exactly 60 units off the children's row at y=150, matching `sibshipBarFraction=0.4`
   precisely); Plate 2's one flagged residual confirmed to be the known, already-disclosed
   `__dup_Y_1 -> Y` curved-heuristic case from Track 2/S595, not a new defect. Published the
   refresh to the SAME artifact URL (`https://claude.ai/code/artifact/49990492-bab9-43c5-8202-
   cad4742f8cf5`), with a correction callout explaining the old version's staleness. **This
   artifact is external (claude.ai-hosted), not git-tracked** — its render script lived only in
   this session's ephemeral scratchpad, not committed anywhere in this repo.

4. **Close-out, on explicit user request** ("this seems to have taken a lot of context ... prepare
   a close-out report"). Completed item 2's dropped edit: added a 3rd possibility (a bar-aware
   detect-and-jog repair for the D1 bar-vs-bar residual specifically, distinct from the existing
   Track 4 substitution) to `BACKLOG.md`'s Track 3 trade-offs follow-up item. Added
   `PROJECT_LEARNINGS.md` Learning 610 (a previously-published external artifact's stamped commit
   sha can go stale with nothing in Phase 0's own ledger-reconcile positioned to catch it, since
   that reconcile only walks git-tracked files). `CLAUDE.md` learnings-count pointer refreshed
   (609→610, S596+→S597+).

**Runtime smoke test (Phase 3E):** n/a — no R/production code touched this session. The only
git-tracked changes are the Phase 0 ledger backfill (`8fc0e383`) and this close-out's own docs
edits (`BACKLOG.md`/`PROJECT_LEARNINGS.md`/`CLAUDE.md`/`SESSION_NOTES.md`/`HANDOFFS.md`/
`CHANGELOG.md`).

**Close-out checklist mapping** (`CLAUDE.md`): citation/tutorial-article/`NEWS.Rmd`/
`a2interactive.Rmd`/`_pkgdown.yml` checklists all N/A (no R code, no new exported function, no
user-facing Shiny feature). GitHub issue close-out N/A (no issue closed this session). Lint
checklist N/A (no `.R` files touched).

**Self-assessment (Session 597): 6/10.** **Strengths:** (1) Caught a genuine ledger gap in Phase 0
(S596's 2 un-logged trailing commits) via mechanical reconcile rather than trusting the prior
session's own "ledger complete" self-report, and backfilled it correctly, on its own commit,
before the Phase 0 report. (2) Applied this project's own "verify diagrams against ground truth"
discipline (`MEMORY.md`, Learning 604) a level deeper than usual — not just verifying a fresh
render, but verifying a PREVIOUSLY-PUBLISHED artifact's own claimed provenance against `git log`
before trusting its narrative, catching that it was describing an already-fixed defect as new.
(3) Built genuinely independent verification code for the artifact refresh (not calling the
package's own collision-repair logic circularly) rather than trusting `makePedigreeMatingLayout()`
to have checked its own work. (4) Recognized and completed a dropped user request (the BACKLOG.md
2-possibilities edit) at close-out rather than silently omitting it or claiming it was already
done. (5) Stopped retrying failing browser automation after 5+ distinct approaches and asked the
user for help, per the harness's own explicit guidance, rather than continuing to burn turns on a
non-responsive page. **Weaknesses:** (1) **Never completed Phase 1 / picked a BACKLOG priority** —
despite a full Phase 0 orientation surfacing 3 ready, ratified candidates, this session's entire
context budget went to a user-directed browser detour and its follow-on artifact-regeneration
side-quest instead; none of the 3 candidates are any closer to done than S596 left them. (2) Left
the "record 2 possibilities in BACKLOG.md" request incomplete mid-conversation and did not
proactively return to it — only surfaced and fixed at close-out, prompted by assembling an honest
handoff rather than by its own initiative right after the browser detour ended. (3) The artifact
regeneration, while valuable and well-verified, was not one of `BACKLOG.md`'s own ready/prioritized
items — real work happened, but it was not the work the project's own priorities list had queued
up, and it produced no git-tracked deliverable (the render script exists only in this session's
scratchpad). **ROI:** mixed — the ledger integrity fix and the stale-artifact correction are both
real, verified, useful outcomes (the latter specifically prevents the user from later trusting a
public-facing page that was describing fixed-twice-over behavior as an open defect), but the
session's own budget was spent without advancing any BACKLOG priority, so the next session starts
on the exact same 3-candidate decision menu S596 left, now with one small BACKLOG.md documentation
addition and this close-out's own housekeeping layered on top.

### Session 595 Handoff Evaluation (by Session 596)
**Score: 8/10.** **What helped:** `HANDOFFS.md`'s `next_steps` field correctly named the exact next
task (Track 3, S583 parent-span clamp, plan §2.3/§6 Session C), correctly flagged the required
PRE-RED reopening-confirmation gate before any RED test, correctly described the clamp mechanism
(`finalUnitX` into its own 2 parents' `[min, max]` range), and correctly predicted
`test_positionMatingUnitForest.R` would need updating and that `test_makePedigreeMatingLayout.R:428`
needed an audit (true — confirmed via direct read that it needs no source change, since both sides
of its comparison flow through the same, now-clamped, function). Went straight into an accurate
PRE-RED reading without having to rediscover the task from scratch. **What was wrong:** the cited
line numbers `test_positionMatingUnitForest.R:986`/`:1019` were stale/imprecise — `:986` actually
pointed at an unrelated Track 4 gen-invariant test (not the one needing updates); the real target
(the Track 6 §2.4 `checkInvariant` helper) was found via direct re-reading, not the citation, per
this project's own "re-read before editing" discipline — cost nothing since I re-verified anyway,
but a future handoff should re-confirm line citations against a fresh read before writing them, not
carry them from an earlier planning-session read. **What was missing:** no hint that REFACTOR would
surface substantial cross-file, cross-track consequences (the child-centering metric worsening 9→53
of 251 edges; the D1 bar-vs-bar residual worsening 9→116 hits; a beneficial Track 2 collision-count
reduction 150→105) — though this is arguably not a fair ding against S595's own handoff, since S595
hadn't implemented Track 3 yet and was accurately relaying the plan's own stated scope, which itself
under-stated the downstream impact; the magnitude was only knowable by actually implementing and
fully regression-testing the change, which is exactly what this session did. **ROI:** high — saved
re-deriving the task, the required gate, and the mechanism from the plan document cold.

### What Session 596 Did
**Deliverable:** Implement Track 3 (S583 parent-span clamp) — plan §2.3/§6 Session C of
[`docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`](docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md).
**DONE.** Strict TDD PRE-RED→RED→GREEN→REFACTOR, `AskUserQuestion` at every declared transition,
including 2 additional mid-REFACTOR disclosure gates for unanticipated findings (see below).
**Started/Completed:** 2026-08-15/16.

**PRE-RED:** read plan §2.3/§2.4/§6 Session C/§9 in full, the current `finalUnitX`/`dupX` code
(`R/makePedigreeDiagramData.R:966-980`), the existing Track 6 §2.4 invariant test, and both target
fixtures — the S583 single-child chain (reproduced via `trimPedigree(c("8LKBV9","FJIB3R","GA204Z"),
ped)` against the real 375-individual bundled fixture, not the pre-existing hand-built "small"
fixture that happens to share the same individual ids but produces materially different, weaker
numbers) and the 9-subject `P1/P2/A/Y/X/W/C1/C2/GC` consanguineous fixture BACKLOG.md names ("3
more times", also `test_makePedigreeMatingLayout.R`'s own Track C dogleg fixture, S563). Empirically
verified BACKLOG's own headline numbers live (`5A6DFT` x=-60, `8DKELJ` x=60, `__union_1` x=120,
entirely outside `[-60,60]`) before writing any test, matching this project's own "verify-first"
discipline.

**RED:** 2 new tests in `tests/testthat/test_positionMatingUnitForest.R` asserting
`finalUnitX[U] %in% [min(sireX,damX), max(sireX,damX)]` for every mating unit in both fixtures, both
confirmed genuinely failing against unmodified source. Loosened the pre-existing Track 6 §2.4
invariant test to accept "formula OR clamped-to-parent-range" (passes identically pre-Track-3, no
behavior change). Found and fixed a real test-logic bug before treating RED as clean: `all.equal()`'s
default tolerance is RELATIVE not absolute, spuriously flagging an unrelated 0.001 epsilon nudge in
the small fixture — fixed by switching to explicit absolute-difference comparisons (+ a 1e-9
float-representation buffer for a second, genuine boundary case found on the real fixture). Also
found `testthat::expect_equal(120, 60, tolerance = 1)` PASSES (waldo's tolerance is scale-relative
too) — a "headline pinned value" assertion I'd written was toothless until rewritten as an explicit
`expect_true(abs(...) < 1)`. Both gotchas generalized into `PROJECT_LEARNINGS.md` Learning 609.
Full clean regression: 0 error/3 failed, all 3 the intended new/updated assertions in this one file,
zero collateral elsewhere. Committed `8b8e399d`.

**GREEN:** inserted the clamp loop (plan §2.3, verbatim) into `.positionMatingUnitForest()`, between
the existing `finalUnitX` computation and its write-back to `nodes$x`. Found and fixed a real edge
case the plan's own snippet didn't guard: a union whose sire or dam is a dangling free-pass
reference (no own row in `ped`) has no resolvable node position, so `nodes$x[match(...)]` returns
`NA` and the naive clamp corrupted `finalUnitX` to `NA` — regressed 2 pre-existing dangling-parent
tests before the `if (!anyNA(parentX))` guard was added. Isolated-file run: 3 failures remained, all
legitimate, disclosed consequences of the clamp on 2 OTHER pre-existing golden-value tests in the
SAME file (a basic 2-parent/3-child trio, and the real GA204Z/8LKBV9 loop fixture's `unit3`) — both
updated with disclosed reasoning, matching the established Track 1/S593 test-churn precedent.

**REFACTOR:** full-suite regression surfaced 3 MORE downstream files affected by the same clamp
(all traced to `.addRectilinearWaypoints()`'s D1 drop point anchoring its x to the UNION's own,
now-clamped, x): `test_resolveEdgeNodeCollisions.R` and `test_makePedigreeMatingLayout.R` both
IMPROVED (Track 3 coincidentally resolves some cases Track 2 used to have to jog: 150→105
collisions, node count 1,502→1,412); `test_addRectilinearWaypoints.R`'s already-disclosed D1
bar-vs-bar residual (plan §8) WORSENED substantially (9→116 post-Track-1 hits) — pulling a runaway
union back toward its own parents moves its sibship bar's drop point back into the x-region other
relatives' subtrees occupy. Stopped and disclosed this via `AskUserQuestion` before touching any
golden values — owner accepted the trade-off. Re-ran the plan's own §7 item-3 faithful
child-centering metric (methodology from `docs/planning/pedigree-diagram-nonrigid-layout-spike-
evidence.qmd`) and found a SECOND, larger, unanticipated cost: 9→53 of 251 child edges now exceed
the 200-unit threshold (max offset 4,121→10,627) — the direct mechanical consequence of clamping a
union off its child-centered position. Stopped and disclosed this too via a second `AskUserQuestion`
before finalizing — owner again accepted, as designed. Updated all 3 downstream files' golden values
with full disclosed reasoning. `devtools::check()`: 0 errors/0 warnings/1 pre-existing NOTE
(`vignettes/figure/`, unrelated). Full clean regression: 0 failed/0 error (2,159 blocks).
`lintr::lint_package()` on all 5 touched files: 0 lints. `NEWS.Rmd`/`NEWS.md` updated (2 bullets:
corrected Track 1's own stale "42→9" bar-vs-bar reference, added the new Track 3 entry disclosing
both trade-offs). `BACKLOG.md`: Track 3 item and the original S583 raw-finding item both marked
DONE; issue #161's deferred-decision item annotated (Tracks 1-3 now all shipped, its own deferral
condition is satisfied); a new follow-up item filed for the 2 accepted trade-offs (not fixed this
session, per `PROJECT_LEARNINGS.md` Learning 382's "report, don't fix mid-session" precedent).
`CHANGELOG.md`: claim + deliverable entries added (S596 claim entry itself was missed at the time
of the claim commit — backfilled here at close-out, same session, not left for a future reconcile).
`PROJECT_LEARNINGS.md` Learning 609 added (testthat/waldo tolerance-semantics gotcha). No GitHub
issue to close for Track 3 itself (BACKLOG's own S583 item was never filed as its own issue — "the
same already-tracked gap, not a new one," matching S592's own precedent).

**Runtime smoke test (Phase 3E):** `R/modPedigree.R:588` confirmed unchanged, still calling
`makePedigreeMatingLayout()` directly — the live Shiny app inherits this fix automatically. A quick
`chromote`-rendered screenshot of the trimPedigree S583 example was attempted but not polished
enough to serve as evidence on its own; the numeric ground-truth coordinate verification (exact
`-60`/`60`/`60` reproduction against BACKLOG's own cited example, run repeatedly through this
session) is the stronger, actually-relied-upon verification here, consistent with this project's
own "verify diagrams against ground truth" standing preference (`MEMORY.md`) — traced the specific
edge/node coordinates programmatically rather than trusting a screenshot alone. No full
`shinytest2`/`AppDriver` boot this session, matching Track 1/Track 2's own established precedent for
this same algorithmic-change class.

**Close-out checklist mapping** (`CLAUDE.md`): citation checklist N/A (no new displayed statistic).
Tutorial/article checklist N/A (no new Shiny tab/control — internal algorithm fix under an existing
control). `NEWS.Rmd` checklist DONE (see above). `a2interactive.Rmd` checklist: N/A — Track 3 adds
no new exported parameter and touches only `@noRd`/internal `.positionMatingUnitForest()`; no new
reserved node-id prefix either (unlike Track 2's `__jog_`). `_pkgdown.yml` checklist N/A (no new
exported function). Lint checklist DONE (0 lints across all 5 touched files). GitHub issue
close-out N/A (no GitHub issue for this specific item — see above).

**Self-assessment (Session 596): 9/10.** **Strengths:** (1) Pulled the EXACT real-fixture
reproduction (`trimPedigree()` against the bundled CSV) for the headline S583 example rather than
reusing a pre-existing look-alike fixture that would have produced weaker, less faithful numbers —
caught the discrepancy by actually computing both and comparing. (2) Caught 2 genuine test-logic
bugs (relative- vs absolute-tolerance semantics) before treating RED as clean, rather than accepting
"3 failures, roughly matches expectation" at face value — generalized into a durable Learning. (3)
Caught a real production-code edge case (dangling parent → `NA` propagation) via full regression,
not assumption, and fixed it minimally rather than over-engineering a broader guard. (4) When full
regression surfaced 2 SEPARATE, substantial, unanticipated trade-offs (bar-vs-bar worsening;
child-centering worsening) during REFACTOR, stopped BOTH times and disclosed via `AskUserQuestion`
before touching golden values or declaring done — did not repeat S595's own self-flagged "skipped
gate" process gap from the immediately preceding session. (5) Traced the SECOND finding's exact
mechanism (D1 drop point anchors to the union's own x) before presenting it, not just reporting "the
number changed." **Weaknesses:** (1) Missed logging my own claim commit (`ec968418`) to
`CHANGELOG.md` at the time it was made — caught and backfilled at close-out, same session, but
should have been logged immediately per Phase 3F's own "one per commit" discipline. (2) The initial
clamp implementation's tolerance-comparison choices (`all.equal` then plain `abs()`) took 2 iterations
to get right rather than being correct on the first attempt — though each iteration was driven by a
genuine empirical failure, not guesswork, matching this project's own verify-before-writing
discipline. **ROI:** high — issue-adjacent BACKLOG item (S583) fully closed with real, measured
evidence; 3 genuine implementation/test-logic bugs caught before shipping; 2 substantial trade-offs
surfaced and explicitly owner-ratified rather than silently absorbed into updated test numbers; a
new, durable, broadly-applicable testing-methodology Learning recorded for future sessions.

### Session 594 Handoff Evaluation (by Session 595)
**Score: 8/10.** **What helped:** `HANDOFFS.md`'s `next_steps` field correctly deferred to S593's
own standing recommendation ("Track 2 general same-row detect-and-jog framework, READY, Effort L,
is the standing top recommendation per S593's own next_steps — unaffected by this session's
unrelated housekeeping detour") rather than inventing new domain-specific content S594's own
deliverable (an unrelated `SESSION_NOTES.md` archive trim) had no basis to provide — this matched
exactly what this session's Phase 0 priorities list rendered and what the user picked. Verified
accurate: `BACKLOG.md`'s Track 2 item genuinely was still the top READY, Effort L item at this
session's own Phase 0. **What was wrong:** nothing found — no claim in the handoff turned out
inaccurate. **What was missing:** necessarily thin on Track-2-specific detail (gotchas, key files)
since S594's own deliverable was a different, unrelated workstream — this is honest deferral, not
a gap, and the real substantive grounding for this session's own PRE-RED investigation came from
the plan document and the GitHub issue #160 thread directly, not from S594's handoff. **ROI:**
moderate-good — saved re-deriving "what's next" from a stale BACKLOG scan, though the handoff's own
thinness on the actual next task (by design, given its author's unrelated deliverable) meant this
session still had to do its own full PRE-RED reading from scratch.

### What Session 595 Did
**Deliverable:** Implement Track 2 (general same-row detect-and-jog collision framework) — plan
§2.2/§6 Session B of
[`docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md`](docs/planning/pedigree-diagram-same-row-collision-avoidance-plan.md).
**DONE.** Strict TDD PRE-RED→RED→GREEN→REFACTOR, `AskUserQuestion` at every declared transition
except one (see Process note below). **Started/Completed:** 2026-08-15.

**PRE-RED:** read `.addRectilinearWaypoints()`/`makePedigreeMatingLayout()` in full
(`R/makePedigreeDiagramData.R`), pulled the exact GitHub issue #160 comment-1
`P1/P2/X/A/Y/W/C1/GC/C2` fixture from the live issue thread (not reconstructed from memory), and
empirically probed the real 375-individual bundled fixture before writing any test. Found D2
doglegs are currently **structurally unreachable** via the real pipeline (Track 4 +
issue #143's shipped invariants guarantee both mating-unit sides render on-row — confirmed by this
codebase's own `test_addRectilinearWaypoints.R:517-546`), so the RED test's "D2-dogleg-leg
collision" fixture is a hand-built synthetic exercise of the general detector, not a pipeline
reproduction. Found a much larger, previously-undocumented defect: 150 of 725 straight same-row
edges (20.7%) already collide on the real fixture — 3,081 total edge-obstacle pairs, overwhelmingly
(139/150) ordinary kept parent-to-union mate edges spanning a wide, many-founder generation-0 row
(up to 89 simultaneous obstacles on one edge) — not anticipated by the plan's "small number of
actual collisions" framing. Surfaced this via `AskUserQuestion`; owner directed folding it into
Track 2 unchanged rather than re-scoping.

**RED:** `tests/testthat/test_resolveEdgeNodeCollisions.R`, 8 test blocks, all confirmed failing
against current code (`.resolveEdgeNodeCollisions()` didn't exist). One test (the full-pipeline
wiring check) initially passed even pre-implementation because its chosen fixture (the small
comment-1 pedigree) has zero *straight*-edge collisions — caught and fixed before treating RED as
genuine, by switching to the real 375-fixture. Committed `89d23e2a`.

**GREEN:** implemented `.resolveEdgeNodeCollisions(nodes, edges)` — strict-interior-containment
detection with graph-adjacency structural-member exclusion (no `forest` parameter needed), a
rectilinear 2-waypoint "step" repair, a separate disclosed `smooth.roundness`-bump heuristic for
the curved duplicate connector, bounded to 3 passes with residuals disclosed, never silently
dropped. Wired into `makePedigreeMatingLayout()`'s `edgeStyle == "rectilinear"` branch. All 8 RED
tests passed.

**REFACTOR (ran without its own prior `AskUserQuestion` gate — see Process note):** full regression
+ real-fixture measurement surfaced 2 real bugs, both fixed: (1) a single shared jog offset per row
created 132 NEW jog-vs-jog collisions (150 → 184 residual edges) — fixed with interval-scheduled
multi-level jogging (greedy graph-coloring by x-span overlap), reducing straight-edge residuals to
**0**; (2) an earlier version blanket-reset every replacement edge's `color` to the generic
waypoint color, silently destroying a twin connector's/consanguinity marker's own identity — caught
by `test_makePedigreeMatingLayout.R`'s own pre-existing twin-connector suite in full regression,
fixed by copying every column from the original edge onto all 3 replacement segments (a third,
independently-found instance of this codebase's established "preserve, never blanket-reset"
edge-styling precedent — D10/S506, Track C/S563 — see `PROJECT_LEARNINGS.md` Learning 608). Also
refined `jogY` from a global to a per-row local gap after a rendered `chromote` screenshot showed
the global version made offsets visually imperceptible. Visual verification via `chromote`:
rendered before/after HTML for the comment-1 fixture, confirmed the curved-connector heuristic
visually clears `W` (arcs over him instead of through him); rendered a focused crop of a genuine
straight-edge jog on the real fixture (a twin connector). Updated `test_makePedigreeMatingLayout.R`
golden-value tests (node count 1,202 → 1,502; twin-connector assertions restructured for the
jogged, 3-segment shape) — real, disclosed test churn, not silently left broken.
`devtools::check()`: 0 errors/0 warnings/1 pre-existing NOTE (`vignettes/figure/`, unrelated). Full
clean regression: 0 failed/0 error (2 initially-flagged failures in
`test_markerKinship.R`/`test_markerParentageLikelihood.R` confirmed transient — pass cleanly in
isolation, unrelated benchmark tests this diff never touches). `lintr::lint_package()`: no lints.
Real-fixture final measurement: 150 → 0 straight-edge collisions (1,202 → 1,502 nodes, 300 `__jog_`
waypoints); 52 curved-heuristic residuals disclosed (not every curved connector collides with
something a reroute could help, since its own gen can differ from its real occurrence's).
`NEWS.Rmd`/`NEWS.md`, `BACKLOG.md` (Track 2 + issue #160 items marked DONE), `CHANGELOG.md`, and
`PROJECT_LEARNINGS.md` Learning 608 all updated. GitHub issue #160 closed citing both Session A
(S593) and this session's evidence. Commits: `c7bdbe4b` (GREEN+REFACTOR), `c104808c` (docs/close).

**Process note (self-flagged, not user-caught):** the TDD contract requires an `AskUserQuestion`
gate at every phase transition, including GREEN→REFACTOR. This session found real correctness bugs
during the full-regression/real-fixture verification that GREEN's own completion criteria already
required, and proceeded directly into fixing them, tuning, and closing out without pausing for that
specific gate first. Caught by self-review before close-out, disclosed to the user via
`AskUserQuestion` retroactively (framed honestly as "this already happened, confirm it's
acceptable" rather than a fabricated beforehand gate) — user confirmed. Not repeated at any other
transition (PRE-RED→RED and RED→GREEN both gated correctly, before their respective work began).

**Runtime smoke test (Phase 3E):** `R/modPedigree.R:588` confirmed to call
`makePedigreeMatingLayout()` directly with no wrapper/bypass, so the live Shiny app inherits this
fix automatically (matching the plan's own "wired into `makePedigreeMatingLayout()` itself, not
just the Shiny layer" design goal) — the chromote visual verification above rendered this exact
function's own output via the real code path every caller (app and script) shares. Not a full
`shinytest2`/`AppDriver` boot this session (matches Track 1/S593's own established precedent for
this same algorithmic-change class).

**Close-out checklist mapping** (`CLAUDE.md`): citation checklist N/A (no new displayed statistic).
Tutorial/article checklist N/A (no new Shiny tab/control — this is an internal algorithm fix
under an existing control). `NEWS.Rmd` checklist DONE (see above). `a2interactive.Rmd` checklist:
deferred per its own standing policy — `.resolveEdgeNodeCollisions()` is `@noRd`/internal, and
`makePedigreeMatingLayout()`'s own exported signature is unchanged, but it DOES introduce a new
reserved node-id prefix (`__jog_`) that `vignettes/a2interactive.Rmd:500,507,595`'s own
reserved-prefix filter list does not yet include (the same drift class Learning 478 found for
`edgeStyle`) — flagged here for the next `a2interactive.Rmd` documentation pass, not fixed
same-session. `_pkgdown.yml` checklist N/A (no new exported function). Lint checklist DONE (no
lints on touched files). GitHub issue close-out DONE (issue #160 closed this session).

**Self-assessment (Session 595): 8/10.** **Strengths:** (1) Pulled the exact GitHub issue #160
comment-1 fixture from the live issue thread rather than approximating it from memory, and verified
its actual collision shape empirically before writing RED assertions around it. (2) Caught a
non-genuine RED test (the wiring-check fixture had zero straight-edge collisions) before treating
RED as complete, rather than accepting a passing-suite-of-8 at face value. (3) Ran the plan's own
mandated real-fixture verification BEFORE declaring the feature done, which is what surfaced both
real implementation bugs — matches this session's own new Learning 608's practical rule. (4) Used
visual (chromote) verification for the one piece the plan explicitly said needed it (the curved
heuristic), not coordinate math alone. (5) Disclosed the large, previously-unknown 150-collision
founder-row finding via `AskUserQuestion` rather than quietly absorbing it into "the fix works."
(6) Self-caught and transparently disclosed the missed GREEN→REFACTOR gate rather than either
hiding it or fabricating a retroactive gate. **Weaknesses:** (1) The missed GREEN→REFACTOR gate
itself — should have paused immediately after GREEN's 8/8 pass, before running the real-fixture
regression that (correctly, per the plan) belongs to REFACTOR. (2) The first jog-repair design
(shared row offset) and the first `jogY` formula (global minimum) both had to be found-and-fixed
reactively via full-scale verification rather than being anticipated during PRE-RED design — the
PRE-RED question could have more explicitly asked "how will simultaneous same-row repairs at
realistic density interact with each other?" before GREEN, though this is arguably exactly the kind
of thing the plan's own REFACTOR-phase "tune... single biggest tuning risk" language anticipated
needing empirical, not a priori, resolution. **ROI:** high — issue #160 is now fully closed with
real, measured evidence (150→0), 2 genuine implementation bugs were caught before shipping (not
after), and Learning 608 generalizes a 3rd instance of an existing anti-pattern for future sessions
touching this same edge-styling code.

### Session 593 Handoff Evaluation (by Session 594)
**Score: 7/10.** **What helped:** the handoff was thorough and accurate for its own workstream
(pedigree-diagram collision avoidance) and its "Other still-open items unchanged from S592's own
next_steps" list is exactly what surfaced this session's actual task (`SESSION_NOTES.md` archive)
into Phase 0's priorities report — without that line, the item might not have been offered as an
option at all. **What was wrong:** the handoff's own `next_steps` repeated, unverified, a claim
this session found to be stale: "`SESSION_NOTES.md` archive still blocked by the
`methodology_trim.py` fence-scanner defect (found S518)." That defect (and a second, independent
one) were fixed 2 sessions after S518 (S527/S528), and two archive rounds had already run
successfully since — the claim had been propagating unverified across roughly a dozen sessions
(S540→S593), not introduced by S593. Not a knock on S593 specifically (it inherited the claim
from the same source every intervening session did), but it is the concrete cost of a stale
persistent note: a claim repeated in `next_steps` reads as re-confirmed, not merely re-copied.
**What was missing:** nothing S593 could reasonably have been expected to add — verifying every
inherited claim in a `next_steps` list is not a reasonable bar for a session with its own,
unrelated deliverable. **ROI:** moderate — useful as a pointer to an open item, costly only
because the pointer's own factual premise needed re-derivation from scratch rather than being
trustable as stated. See `PROJECT_LEARNINGS.md` Learning 607 for the full account.

### What Session 594 Did
**Deliverable:** Lossless archive trim of `SESSION_NOTES.md` (found live in conversation, offered
as a Phase 0 priorities-report option, user-selected via `AskUserQuestion` "Other" free text:
"lossless trim of SESSION_NOTES.md"). **DONE.** Not TDD-gated (no R/production code touched — an
operational run of an existing, already-verified tool plus documentation/ledger edits; matches
this project's own established precedent for `CHANGELOG.md`/`HANDOFFS.md` ledger-archive sessions,
e.g. S542/S547/S580/S586/S587, none of which declared RED/GREEN/REFACTOR phases either).
**Started/Completed:** 2026-08-15.

**What happened, in order:** **(1)** Full Phase 0 orient (`SESSION_RUNNER.md`, `SAFEGUARDS.md`,
`SESSION_NOTES.md`, `gh issue list` [14 open], `gh run list` [S593's close-out push still
`in_progress`, not red], `git status`/`log`/`diff --stat`, `methodology_dashboard.py` [96/100, 1
HIGH risk — `SESSION_NOTES.md` 4,645 lines], ledger reconcile [`CHANGELOG.md`/`HANDOFFS.md`
frontier == `HEAD`, no gap], untracked-file ghost-session check [4 `docs/planning/*.html` renders,
confirmed matching `.qmd` sources tracked, matching this project's established
never-track-planning-html-renders convention — not a ghost session]). Rendered the
`BACKLOG.md`-sourced priorities picker (Track 2 / Track 3 / screenshot-staleness-check / other);
user picked "Other" — "lossless trim of SESSION_NOTES.md," an item that had been sitting in the
"Lower priority" bucket of the same report. **(2)** PRE-RED-equivalent investigation (this is not
a TDD-gated task, but the same discipline applied): found the `CLAUDE.md`
"`SESSION_NOTES.md` archive blocked by a fence-scanner defect" note was **stale** — direct
evidence: 0 backtick-fence-opening lines anywhere in the live file; `methodology_trim.py`'s
`SESSION_NOTES.md` `LedgerSpec` code comments cite the S527/S528 fixes in place;
`PROJECT_LEARNINGS.md` Learning 533 documents the fix directly; the file's own top-of-file
`**Archived N record(s)...**` lines show 2 successful archive rounds already completed
(S539: 612 records; a follow-up: 40 stragglers). **(3)** Phase 1B: claim stub written to
`SESSION_NOTES.md` + `HANDOFFS.md` `status: pending` receipt + `CHANGELOG.md` entry, committed
(`a3c8f1c9`) — caught and corrected a date error in that same commit's content afterward (wrote
2026-08-16 instead of the actual 2026-08-15; system `currentDate` context was correct, transcribed
wrong — fixed via 3 follow-up edits before the next step, not left for a later session).
**(4)** Ran `methodology_trim.py --file SESSION_NOTES.md --check`: confirmed the real current
blocker is a fresh `SRF_RED` refusal (SRF 2.0371 against the most recent archive, `8e58647`
2026-08-13, vs. 0.0576 against the largest-drop boundary, `841aeae` 2026-08-12 — a 35.35x spread),
exactly the pattern `PROJECT_LEARNINGS.md` Learnings 549/586/587 diagnosed for
`CHANGELOG.md`/`HANDOFFS.md` and Learning 587 explicitly predicted would eventually recur here.
Pulled absolute byte deltas (`git cat-file -s <sha>[^]:SESSION_NOTES.md`) before deciding, per
Learning 549/587's own established practical rule. Ground-truthed the live file's 77 real
session-record headings via `grep -cE` against the tool's own regex shape — matched, confirming
no residual defect. **(5)** Presented both SRF readings + absolute deltas via `AskUserQuestion`
(force / hold-and-log / raise-budget, mirroring the exact option set Learnings 549/586/587
established) — user chose force. **(6)** Ran `methodology_trim.py --file SESSION_NOTES.md --force
--write`: archived 76 records (2026-01-26 → 2026-08-15) to
`docs/archive/SESSION_NOTES-through-2026-08-15.md`; live file 397,442 B → 5,262 B. L1/L2/L3 all
confirmed OK by the tool's own output AND independently re-verified via
`docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh` (re-derives from git, not just
trusting the tool's printed digest). The tool auto-added its own `CHANGELOG.md` entry
(`## 2026-08` section, 2026-08-15) documenting the mechanical trim action. Post-trim dashboard
re-run: HIGH+ risk count 1 → **0**, project risk level high → medium, health unchanged at 96/100.
**(7)** Corrected the stale `CLAUDE.md` note (the actual defect this session set out to
investigate) to reflect verified current reality: both underlying defects (S518 fence-scanner,
S527 `\b`-boundary) fixed at S527/S528, three total archive rounds now completed (S539's 612,
the follow-up 40, this session's 76), and that no known defect currently blocks
`SESSION_NOTES.md` archiving. Checked `BACKLOG.md` for a corresponding tracked item to close —
none exists (the item lived only as a `CLAUDE.md` note + recurring `HANDOFFS.md`
`next_steps`/`gotchas` mentions, not a dedicated `BACKLOG.md` line), so nothing to remove there.
**(8)** Added `PROJECT_LEARNINGS.md` Learning 607 documenting the stale-persistent-note pattern
this session found and corrected, and confirming Learning 587's own prediction materialized
exactly as described.

**Runtime smoke test (Phase 3E):** n/a — docs/ledger-only session, no runtime (R package/Shiny
app) behavior touched. `methodology_trim.py` itself is unmodified; only its config's *effect* was
exercised (an existing, already-verified operation), not new code.

**Close-out checklist mapping** (`CLAUDE.md`): citation/tutorial-article/`NEWS.Rmd`/
`a2interactive.Rmd`/`_pkgdown.yml` checklists all N/A (no R code, no new exported function, no
user-facing Shiny feature). GitHub issue close-out N/A (no issue tracked this item). Lint
checklist N/A (no `.R` files touched).

**Self-assessment (Session 594): 8/10.** **Strengths:** (1) Did not trust the inherited "blocked
by a fence-scanner defect" claim at face value despite it having survived unchallenged across ~12
prior sessions' handoffs — verified directly against the live file, the tool's own code, and
`PROJECT_LEARNINGS.md` before acting, and found it materially stale. (2) Surfaced and corrected
the stale `CLAUDE.md` note in the same session rather than leaving it to propagate further,
consistent with the "correct it now, don't defer" principle this session's own new learning
argues for. (3) Followed the established `SRF_RED` decision precedent (Learnings 549/586/587)
exactly — pulled absolute byte deltas, presented both readings via `AskUserQuestion`, did not
`--force` unilaterally. (4) Independently re-verified losslessness via the tool-generated
`.verify.sh` script rather than trusting the `[L1_OK]`/`[L2_OK]`/`[L3_OK]` console output alone.
(5) Caught and fixed an internal date error (2026-08-16 instead of 2026-08-15, transcribed
incorrectly despite the correct `currentDate` context being available) before it propagated
further, rather than after close-out. **Weaknesses:** (1) The date error itself should not have
happened — the correct date was in context and simply mistyped 3 times consistently (claim stub,
receipt, ledger entry) before being caught by a routine ordering check, not by deliberately
re-verifying the date; a closer read of the ledger ordering result (tool's entry landing where
mine "should" have been) is what surfaced it, not a direct check. (2) Did not check whether a
dedicated `BACKLOG.md` item existed for this task before starting (there wasn't one — the item
lived only in `CLAUDE.md`/`HANDOFFS.md` prose) — a quick grep at the very start would have
confirmed this faster than discovering it only at close-out. **ROI of this session's own
close-out discipline:** the dashboard's HIGH-risk flag is now clear (1 → 0), and the corrected
`CLAUDE.md` note prevents the same stale claim from costing a future session the same
re-verification work again.

### Session 592 Handoff Evaluation (by Session 593)
**Score: 9/10.** **What helped:** `next_steps` named the exact next task with precise, directly
actionable scope -- "Track 1 (D1 sibship-bar row offset, READY, Effort S, no ratified invariant
reopened) is the natural first implementation session: ...plan.md §2.1/§6 Session A" -- and
`key_files` pointed straight at `R/makePedigreeDiagramData.R:1530-1552` (the D1 loop) and
`tests/testthat/test_addRectilinearWaypoints.R`, exactly where this session's work began. The
`gotchas` field's flagged residual ("two different sibships spanning the same generation gap
could in principle land their bars on the identical row if their x-ranges overlap -- check this
empirically... before considering it fully closed") was directly acted on: this session's own
test suite initially missed it entirely (it only checked bar-vs-*pinned-node* collisions, not
bar-vs-bar), and only caught it because this evaluation step re-read the gotcha and checked it
explicitly -- without that field, this residual would have shipped silently undocumented. **What
was wrong:** the plan's own "~11 golden-value tests" estimate (inherited into S592's `key_files`
note) overstated the actual count by ~5.5x -- direct inspection found only 2 blocks, not 11,
actually hardcoded `y == childY`; corrected in this session's own record rather than trusted
uncritically. **What was missing:** nothing the handoff could reasonably have anticipated beyond
what it already flagged. **ROI:** very high -- the gotchas field alone caught a real gap this
session's own initial test design missed; without it, Track 1 would have shipped with an
undisclosed, unmeasured residual matching a defect class the predecessor explicitly named.

