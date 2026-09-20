# SESSION_NOTES.md — archive: 2026-09-19 → 2026-09-19

Retired records from [`SESSION_NOTES.md`](../../SESSION_NOTES.md), moved here so the live ledger stays small enough to read
in one pass. Same format, same newest-on-top order — this is the same ledger, continued.

Holds **10 record(s), 2026-09-19 → 2026-09-19**. Cut key: `2026-09-19`. Counts here are computed from the file
itself, never carried forward. This shard is frozen: it states no forward-looking rule,
because the live file owns those and a copy of one was wrong a day after it was written.

---

### Session 723 Handoff Evaluation (by Session 724)
**Score: 9/10.** **What helped:** the annotated BACKLOG item plus gotcha (2)'s re-derive
mandate WAS this session's plan — and the mandate was load-bearing (staleness confirmed:
the list knew 5 of the actual 14 markerKinship blocks); the full-suite baseline
(2437/0/0/184/40) matched this session's fresh inventory read exactly; next-steps (B)
described this session's exact opening play (fresh-suite inventory first, then 273(d) vs
fixture completion); key-file anchors accurate (`R/markerKinship.R:135` confirmed as the
emission site). **What was missing:** nothing material. **What was wrong:** gotcha (2)'s
first half — "the 40 suite warnings are ALL the tracked baseline item's class" — was
refuted by measurement: 37/40 are; 3 warnings in 2 OTHER files are two different classes
(`test_appServer_server.R:206` findGeneration/`-Inf`; `test_modPedigree_processing.R:672`
layout-collision residual). Zero harm done — the same gotcha's own re-derive instruction
pre-neutralized it. **ROI:** high.

### What Session 724 Did
**Deliverable:** Baseline-warnings cleanup — **DONE.** Suite warning count **40 → 0**
(`blocks=2437 failed=0 error=0 skipped=184 warning=0`; block/skip counts equal the
S718–S723 baseline exactly) via 16 `suppressWarnings()` wraps on the exact test calls that
leak working-as-designed production warnings. The suite is back to the 0-warning state of
CRAN v2.0.0 — the owner's "we had zero at last release" report (S487) that opened the item.
BACKLOG item removed in the deliverable commit. No TDD phases (test-hygiene: no new tests,
no assertion or production change; the remedy choice was the session's `AskUserQuestion`
gate, posed with the inventory in hand). Lint checklist applied (3 tracked test `.R` files
touched): `lintr::lint_package()` = 0 lints, package loaded first (Learning 224).
**Started/completed:** 2026-09-19 (single session). Claim `1bd5ef9c`; deliverable
`eb3573bc`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per commit; the deliverable entry carries the full
inventory + verification record.

**What actually happened, in order:**
1. **Phase 0:** reconcile clean (0 undocumented commits on both frontiers, predicted 0);
   CI 10/10 green (still on the S719 push — the 23 then-unpushed commits had never seen
   CI); dashboard 96/100; context-budget reds by-design only; untracked files all
   long-standing/known. Owner picked this item from the 4-option picker. Claim `1bd5ef9c`.
2. **Inventory (fresh full suite, silent reporter + `expectation_warning` walk):** 40
   warnings = 37 markerKinship NA-path across 14 blocks, all `test_modMarkerGenetics.R`
   (3 known 5-warning blocks at :265/:278/:416 + ELEVEN 2-warning `i152_roh` blocks at
   :927–:1712, of which the stale list knew 2) **plus 3 out-of-class** (see the S723
   evaluation above). srcref lines landed on the exact triggering calls = the wrap-site
   list for free.
3. **Remedy gate:** owner picked "suppress all 16 sites" (over markerKinship-only, and
   over fixture completion with its Fst re-derivation risk) via `AskUserQuestion`.
4. **Fix (`eb3573bc`):** 16 wraps — 14 `setInputs(genotypeFile=...)` (2 centerA, 1
   flaggedSlot, 11 i152_roh; fixture filenames partition warning from non-warning sites
   exactly, so replace-all keyed on the fixture-name line was provably precise), 1
   `flushReact()` (appServer), 1 `setInputs(trimPedigree=TRUE)` (modPedigree). Diff =
   exactly the 16 wraps; assertions and production code untouched.
5. **Verification:** the 3 touched files individually 0F/0E/0W; full clean regression
   read 2437/0/0/184/**0**; lint 0.

**Self-assessment (Session 724): 9/10.** **Strengths:** (1) inventory-before-remedy
sequencing caught the class heterogeneity BEFORE any fix was designed — the remedy gate's
options were built from measurement, not the item's stale enumeration; (2) provably
precise edits (fixture-name partition + wrap-count + per-file 0W re-runs + full-suite
exact-baseline block/skip counts); (3) the suite's warning channel is now clean, turning
every future warning into signal. **Weaknesses:** (1) the BACKLOG block removal used
line-number `sed` rather than a context-anchored edit — boundaries were re-verified
immediately before and the diff checked after, but it's the FM #20-adjacent pattern;
(2) the deliverable commit sat exactly at the 5-file blast-radius cap — compliant but
with no headroom; splitting the docs pair from the test trio would have been more
conservative.

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~27 expected after close-out: 23 pre-existing
+ claim + deliverable + records + sha; the last two are an estimate at write time). CI's
R-CMD-check runs this same suite and should confirm warning-free on push. (B) Priorities:
`CLAUDE.md` reduction campaign (READY, M); pedigree-growth measurement (READY, S,
owner-requested S721); owner decisions pending: package-split disposition, REUSE
registration. (C) Standing report-only: HANDOFFS.md truncated duplicate S720 stub (locate
by grepping for two adjacent `session: S720` blocks); iCloud Housekeeping item closable
pending a duplicates-stay-gone confirmation.

**Key files:** `tests/testthat/test_modMarkerGenetics.R` (14 wraps at :265/:278/:416/
:927/:940/:989/:1015/:1046/:1067/:1103/:1123/:1598/:1649/:1712 — wrap adds no lines, so
pre-fix line numbers still hold), `tests/testthat/test_appServer_server.R:206`,
`tests/testthat/test_modPedigree_processing.R:672`, `R/markerKinship.R:131-139` (the
NA-path emission — untouched), `CHANGELOG.md` S724 entries, `PROJECT_LEARNINGS.md`
Learning 769.

**Gotchas for the next session:** (1) **The full-suite baseline is now 2437/0/0/184/0 —
any `warning > 0` in a regression read is a NEW finding, never "baseline."** (2) When
authoring tests that upload degenerate/toy genotype fixtures, wrap the triggering call
per Learning 273(d) AT AUTHORING TIME — the 10→15→40 growth was new tests reusing
warning-prone fixtures without wraps (S447/S502/S535). (3) The 16 wrapped call sites also
mute future unexpected warnings from those exact calls (owner-accepted trade; assertions
unchanged, failures still surface). (4) Standing: context-budget reds by design until the
CLAUDE.md reduction campaign; every `methodology_trim.py` run needs `--budget-bytes
65536`; the stray `~$e Compounding Loop.html` still makes `devtools::check()` warn and
exit 1 non-interactively; `renv.lock` carries no dev tooling (the `Rscript` out-of-sync
banner is expected).

### Session 722 Handoff Evaluation (by Session 723)
**Score: 9/10.** **What helped:** gotcha (3) WAS this session's deliverable, pre-diagnosed in
full — file:line, root cause (roxygen markdown parses `[0, 1]` as a link to topic "0, 1"),
scope (`@noRd`, warning-only, no output effect), and the remedy ("escape the brackets") — zero
diagnosis time; follow-up (A)'s framing predicted exactly how the session would open (the owner
pasting RStudio Install output); the full-suite baseline (2437/0/0/184/40) matched this
session's regression read exactly; "expect 0 undocumented commits; measure it" measured 0; the
truncated-S720-stub report-only finding was accurate in substance. **What was missing:**
nothing material. **What was wrong:** one minor stale anchor — the truncated-stub pointer said
`HANDOFFS.md:171-175`, but S722's own receipt (prepended after the note was written) shifted it
to ~188-192 by read time; locate it by grep/structure, not line number. **ROI:** high.

### What Session 723 Did
**Deliverable:** roxygen unresolved-link warning fix — **DONE.** `R/makePedigreeDiagramData.R:2414`
`@param t ... in [0, 1].` escaped to `\[0, 1\]`, so `devtools::document()`/RStudio-Install runs
are warning-free. Session trigger: the owner's RStudio-button Install (S722 follow-up A)
succeeded end-to-end — S722's encoding fix verified on the live GUI surface — with this warning
the only remaining noise; owner picked the fix via `AskUserQuestion`. No TDD phases (docs-only
roxygen comment, S720–S722 precedent); lint checklist applied (tracked `.R` file touched).
**Started/completed:** 2026-09-19 (single session). Claim `3980cc31`; deliverable `d2a43162`;
BACKLOG annotation `e2a91424`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per commit; deliverable entry carries the verification record.

**What actually happened, in order:**
1. **Phase 0:** reconcile clean (0 undocumented commits, predicted 0); CI 10/10 green (still on
   the S719 commit — now 18+ unpushed commits have never seen CI); dashboard 96/100;
   context-budget reds by-design only. Incidental finding: the iCloud duplicate `.R` files are
   gone and the repo now lives outside iCloud — that Housekeeping item's close condition looks
   satisfiable (confirm-and-close, future session).
2. **Task pick:** owner clarified via their pasted Install output; picked the warning fix from a
   4-option `AskUserQuestion`. Claim `3980cc31`.
3. **Fix + verification (`d2a43162`):** one-line escape. (1) Pre/post stash test — the warning
   reproduces on unfixed HEAD via `document(roclets = c("rd","collate","namespace"))`, absent
   with the fix; the first post-fix check was INVALID (run under `suppressMessages()`, which
   hides roxygen's cli-emitted warning) and was caught and re-run unsuppressed. (2) Zero
   collateral: `man/`/`NAMESPACE` untouched. (3) Lint: no lints (package loaded first,
   Learning 224). (4) Full clean regression read `blocks=2437 failed=0 error=0 skipped=184
   warning=40` — equals the S718–S722 baseline exactly.
4. **Mid-session owner report** (markerKinship NA warnings in RStudio test runs,
   `test_modMarkerGenetics.R:1649`/`:1712`) triaged to the existing BACKLOG baseline-warnings
   Housekeeping item — those 2 blocks are NOT in its stale 3-block list; source confirmed
   `R/markerKinship.R:135` (documented NA path, working as designed). Annotated the item
   (`e2a91424`): count 10→15→40, re-derive-the-inventory instruction added. No fix (1-and-done).

**Self-assessment (Session 723): 9/10.** **Strengths:** (1) caught its own unsound verification
— the `suppressMessages()` first check would have claimed "warning gone" on a channel that
could not see the warning — and re-proved unsuppressed with a pre/post stash test on the exact
surface; (2) zero collateral, exact-baseline suite; (3) the owner's mid-session warning report
was triaged to the tracked item with a verified annotation instead of scope-creeping into a fix.
**Weaknesses:** (1) that first invalid check happened at all — absence-of-output must never be
verified under suppression; (2) a noisy sibling-instance grep was run before realizing roxygen's
own output IS the exhaustive unresolved-link inventory (one wasted step).

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~23 expected after close-out: 18 pre-existing +
claim + fix + annotation + records + sha; the last two are an estimate at write time). The
warning fix reaches other clones only once pushed. (B) **Warning-cleanup session** (READY,
Effort S) — the annotated baseline-warnings item; owner showed active interest this session;
start by re-deriving the full warning-emitting block inventory from a fresh suite run, then
apply Learning 273(d) `suppressWarnings()` or fixture completion per the item. (C) Priorities:
`CLAUDE.md` reduction campaign (READY, M); pedigree-growth measurement (READY, S,
owner-requested S721); owner decisions pending: package-split disposition, REUSE registration.
(D) Report-only standing findings: HANDOFFS.md truncated duplicate S720 stub (locate by grep
for two adjacent `session: S720` blocks — line numbers drift); iCloud Housekeeping item now
closable pending a duplicates-stay-gone confirmation.

**Key files:** `R/makePedigreeDiagramData.R:2414` (the escaped line),
`R/markerKinship.R:135` (the NA-warning emission the owner asked about),
`BACKLOG.md` baseline-warnings item (S723 annotation at its tail), `CHANGELOG.md` S723
entries, `PROJECT_LEARNINGS.md` Learning 768.

**Gotchas for the next session:** (1) **Never verify absence-of-warning under
`suppressMessages()`** — roxygen2 (and cli-based tooling generally) emits warnings as messages;
a clean result under suppression is unsound (Learning 768). (2) The 40 suite warnings are ALL
the tracked baseline item's class — suite green 0F/0E; re-derive the block inventory, don't
trust the item's enumeration. (3) Standing gotchas carry forward: context-budget reds by design
until the CLAUDE.md reduction campaign; every `methodology_trim.py` run needs
`--budget-bytes 65536`; the stray `~$e Compounding Loop.html` still makes `devtools::check()`
warn and exit 1 non-interactively; `renv.lock` carries no dev tooling (the `Rscript`
out-of-sync banner is expected). (4) Full-suite baseline re-confirmed this session:
2437/0/0/184/40.

### Session 721 Handoff Evaluation (by Session 722)
**Score: 9/10.** **What helped:** the BACKLOG Up Next item S721 filed was a ready-to-execute
plan — root cause, exact file list, the fix line, the verification recipe (RStudio's exact
roclet call + regression read + cleanup), and the owner follow-up — so this session spent
zero time on diagnosis; gotcha (5)'s full-suite baseline (2437/0/0/184/40) was directly
load-bearing (this session's read matched it exactly); gotcha (2) pre-explained the renv
"project is out-of-sync" banner that now prints on every `Rscript` start (dev tooling
deliberately absent from the lock — no time lost chasing it); the next-steps priority list
matched the Phase 0 picker one-for-one. **What was missing:** the item counted
`vignettes/a3manual.md` among "the 5 built vignettes" without noting it is gitignored
(`.gitignore:18` — the `knitr::knitr` intermediate), discovered here when `git diff --stat`
showed only 4 files; cost ~1 minute. **What was wrong:** nothing found — every checked claim
held, including the failure fingerprint (leftover build products had every `.html` except
`a2interactive.html`). **ROI:** high.

### What Session 722 Did
**Deliverable:** RStudio-Install vignette-encoding fix — **DONE.** `%\VignetteEncoding{UTF-8}`
added inside the `vignette:` block of all 4 tracked built vignettes (`a2interactive.Rmd`,
`a3manual.Rmd`, `gvaConvergence.Rmd`, `simulatedKValues.Rmd`); the item's 5th file
(`a3manual.md`) is the gitignored `knitr::knitr` intermediate and regenerates WITH the line
from the `.Rmd`'s YAML (verified at its line 14 post-run). No TDD phases (vignette metadata,
no `.R` files — S720/S721 precedent). BACKLOG Up Next item removed in the deliverable commit.
**Started/completed:** 2026-09-19 (single session). Claim `f93a6ce2`; deliverable `10934a2f`;
records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per commit; deliverable entry carries the full
verification record.

**What actually happened, in order:**
1. **Phase 0:** reconcile clean (0 undocumented commits, predicted 0); CI 10/10 green (on the
   S719 commit — the 13 then-unpushed commits have never seen CI); dashboard 96/100;
   context-budget reds by-design only. Owner picked this item from the 4-option picker.
   Claim `f93a6ce2`.
2. **Fix:** one line per file after the `%\usepackage[UTF-8]{inputenc}` boilerplate (which the
   roclet path ignores — the item's diagnosis, confirmed).
3. **Mechanism verification (seconds, no rebuild):** `tools:::.getVignetteEncoding()` returns
   `'non-ASCII'` on the pre-fix HEAD copy of `a2interactive.Rmd` (exactly the value that trips
   `tools::buildVignette()`'s stop) and `'UTF-8'` post-fix.
4. **End-to-end verification (RStudio's exact call):** `devtools::document(roclets = c('rd',
   'collate','namespace','vignette'))` exited 0; all 4 `.Rmd` vignettes rebuilt including the
   previously-failing `a2interactive.Rmd` (its `.html` produced — its absence among the
   leftover build products was the failure fingerprint). `man/` untouched (zero collateral
   `.Rd` churn). Build products then cleaned per the item's recipe.
5. **Regression read:** `blocks=2437 failed=0 error=0 skipped=184 warning=40` — equals the
   S718–S721 baseline exactly. (`devtools::check()` not re-run — the item's verify recipe
   doesn't call for it, S721 ran a full check on effectively this tree yesterday, and CI's
   R-CMD-check will exercise the batch vignette path on push.)
6. **Mid-session owner question** answered (why `vignettes/` retains `.md`/`.R`/`.html`
   files): in-place roclet builds + `.gitignore:18-22` hiding them; no file changes.

**Self-assessment (Session 722): 9/10.** **Strengths:** (1) mechanism-level pre/post
verification added beyond the recipe — proved the fix on the exact reader the failing path
uses before spending minutes on the full rebuild; (2) zero collateral — diff is exactly 4
one-line insertions, `man/` untouched; (3) the gitignored-5th-file wrinkle was detected and
resolved (regeneration verified) rather than claiming "5 files committed" when only 4 could
be. **Weaknesses:** (1) edited `a3manual.md` as if durable before noticing it was gitignored
— caught by `git diff --stat`, cost one check; (2) the actual RStudio Install *button* was
not exercised (no GUI in this environment) — terminal-side proof is complete, but the live
surface remains the owner's follow-up, stated explicitly rather than claimed.

**Next steps (specific):** (A) **Owner: the item's own follow-up** — restart R, Install via
the RStudio button, re-run the appServer tests; if anything still fails, capture the output
as its own finding (most likely stale-installed-copy collateral, already refreshed by S721's
terminal install). (B) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~17 expected after close-out: 13 pre-existing +
claim + deliverable + records + sha; the last two are an estimate at write time). Note the
fix only reaches other clones/machines once pushed. (C) Priorities: `CLAUDE.md` reduction
campaign (READY, M); pedigree-growth measurement (READY, S, owner-requested S721); owner
decisions pending: package-split disposition, REUSE registration. (D) Report-only finding:
`HANDOFFS.md:171-175` holds a truncated duplicate S720 stub block (an unclosed `handoff`
fence with only session/date/status lines immediately above the real S720 receipt) —
pre-existing, not touched this session (Learning 382 precedent); a future session should
repair it deliberately.

**Key files:** `vignettes/a2interactive.Rmd:12` (the load-bearing new line; siblings at
`a3manual.Rmd:14`, `gvaConvergence.Rmd:13`, `simulatedKValues.Rmd:13`), `.gitignore:18`
(why `vignettes/` build products are invisible to git), `CHANGELOG.md` S722 deliverable
entry (full verification record), `PROJECT_LEARNINGS.md` Learning 767.

**Gotchas for the next session:** (1) **The RStudio-button click itself is still unverified**
— everything terminal-side is green, but the button runs in the owner's GUI session; treat
the owner follow-up in next-step (A) as the remaining verification surface. (2) Every
RStudio-button Install (vignette roclet) will keep depositing gitignored build products in
`vignettes/` — harmless, regenerable; `a3manual.md` persists by design. (3) Pre-existing
roxygen warning on every `document()` run: `R/makePedigreeDiagramData.R:2414` `@param t ...
in [0, 1].` parses as a link to topic "0, 1" (`@noRd`, warning-only, no output effect) — not
a regression; escape the brackets if it ever needs silencing. (4) Standing gotchas carry
forward: context-budget reds by design until the CLAUDE.md reduction campaign; every
`methodology_trim.py` run needs `--budget-bytes 65536`; the stray `~$e Compounding Loop.html`
still makes `devtools::check()` warn and exit 1 non-interactively; `renv.lock` carries no dev
tooling (the `Rscript` out-of-sync banner is expected). (5) Full-suite baseline re-confirmed
this session: 2437/0/0/184/40.

### Session 720 Handoff Evaluation (by Session 721)
**Score: 9/10.** **What helped:** next-step (B) named this session's exact deliverable with a
`BACKLOG.md` pointer whose "recount after any BACKLOG edit" caveat proved necessary (the item
sat at line 146 by pickup time); gotcha (1) pre-cleared the `context_budget.py` exit-2 reds as
by-design — zero time lost chasing them; the close-out ledger entry's full-suite baseline
(2437/0/0/184/40) was directly load-bearing — this session's regression read was compared
against it and matched exactly; "expect 0 undocumented commits; measure it" measured exactly 0.
**What was missing:** no current `devtools::check()` baseline exists anywhere current — the old
"iCloud duplicate-file warning" baseline is stale (those files are gone), so this session had
to derive from the session-start `git status` that today's 1 WARNING + 1 NOTE (untracked
`~$e Compounding Loop.html` clutter + `scratchpad/`) are pre-existing rather than compare
against a stated expectation. Minor; now recorded below. **What was wrong:** nothing found.
**ROI:** high.

### What Session 721 Did
**Deliverable:** `Suggests:` audit — **DONE.** All 22 `Suggests:` entries audited against the
owner's rule (real loads in `tests/`/`vignettes/`/roxygen `@examples`); 16 retained with
grep-verified load sites, 6 relocated/removed (owner-ratified via 2 `AskUserQuestion` gates,
both recommended options picked): `devtools` + `roxygen2` → new `Config/Needs/dev`; `quarto`
dropped (already `Config/Needs/website`, `pkgdown.yaml` already passes `needs: website`);
`grid`/`png`/`shinyWidgets` deleted outright (zero uses anywhere). `renv.lock` re-snapshotted
(`dev = TRUE`, S637 precedent) — 21 packages dropped (the 5 + transitive closures);
`renv::status(dev = TRUE)` clean. No TDD phases (DESCRIPTION/config metadata, no `.R` files).
**Started/completed:** 2026-09-19 (single session). Claim `05943cd5`; owner-requested backlog
item `ede5289e`; deliverable `cd748874`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per commit; completed BACKLOG item removed in `cd748874`.

**What actually happened, in order:**
1. **Phase 0:** reconcile clean (0 undocumented commits, predicted 0); CI 10/10 green;
   dashboard 96/100; context-budget reds by-design only. Owner picked this item from the
   4-option picker. Claim `05943cd5`.
2. **Mid-session owner request** (arrived during research): filed the pedigree-drawing
   package-growth measurement item (rough ±20% acceptable) as `BACKLOG.md` Housekeeping
   (READY, S) — `ede5289e`, not acted on (1-and-done).
3. **Audit:** grep inventory of all 22 entries across `R/`/`tests/`/`vignettes/`/`man/`/
   `inst/`/`data-raw/`, then **read every thin hit for code-vs-comment** — this flipped two
   classifications: `devtools`' 20+ test/vignette hits are ALL comments or `eval = FALSE`
   install snippets tangling to comments (`vignettes/a3manual.R:5-10`) → out; `pkgdown`'s
   single hit is real code (`pkgdown::as_pkgdown()`, `test_pkgdown_reference_config.R:25`)
   → stays, refuting the filing item's own suspicion. A secondary engine-level sweep caught
   `markdown` (zero direct hits but `a3manual.{Rmd,md}` use the `knitr::knitr` engine, which
   renders through it) → stays.
4. **Gate:** two `AskUserQuestion`s (devtools/roxygen2 disposition; unused-package deletion);
   owner ratified both recommendations.
5. **Execute `cd748874`:** DESCRIPTION edit (6 lines out, `Config/Needs/dev` in; roxygen2's
   `(>= 8.0.0)` superseded by `Config/roxygen2/version`); `renv::snapshot(dev = TRUE)`.
6. **Verify:** full regression read `blocks=2437 failed=0 error=0 skipped=184 warning=40` —
   equals S718–S720 baseline exactly. Full `devtools::check()` (21m52s): 0 errors, all
   dependency gates OK, vignettes rebuilt OK; 1 WARNING + 1 NOTE both name pre-existing
   UNTRACKED clutter (`inst/extdata/reference/~$e Compounding Loop.html`, `scratchpad/`) —
   0 new findings.

**Self-assessment (Session 721): 9/10.** **Strengths:** (1) read-the-hit discipline caught
both would-be errors (devtools wrongly kept / markdown wrongly removed) before they happened;
(2) precedent-checked the renv question (S637 `526c7fec`, covr absent from lock) instead of
guessing; (3) CI-safety verified before removal (`pkgdown.yaml` `needs: website`), not after.
**Weaknesses:** (1) the first grep pattern set was pure `library()`/`::`-shaped and would have
missed the `markdown` engine dependency without the deliberate secondary sweep — engine/YAML
deps need their own pass by default; (2) `devtools::check()`'s non-interactive exit-1 on the
pre-existing WARNING briefly read as a failure before the log was inspected.

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~12 expected after close-out: 7 pre-existing +
claim + backlog-file + deliverable + records + sha; the last two are an estimate at write
time). (B) Priorities: `CLAUDE.md` reduction campaign (READY, M); pedigree-growth measurement
(READY, S, owner-requested S721); owner decisions pending: package-split disposition, REUSE
registration. (C) Owner call, trivial: delete/relocate the stray untracked
`inst/extdata/reference/~$e Compounding Loop.html` (an Office lock-file artifact) — it alone
makes `devtools::check()` warn (and exit 1 non-interactively); `scratchpad/` likewise drives
the top-level NOTE. Untracked files, deliberately not touched this session.

**Key files:** `DESCRIPTION:60` (trimmed Suggests), `DESCRIPTION:85-87` (Config/Needs
website/coverage/dev groups), `renv.lock` (21 packages dropped), `BACKLOG.md` Housekeeping
(new pedigree-growth item; Suggests item removed), `PROJECT_LEARNINGS.md` Learning 766,
`CHANGELOG.md` S721 deliverable entry (full audit table).

**Gotchas for the next session:** (1) **`devtools::check()` exits 1 non-interactively until
the stray `~$` file is removed** — the WARNING is pre-existing clutter, not a regression;
current true baseline: 0 errors + that clutter WARNING + the `scratchpad/` NOTE. (2)
**`renv.lock` no longer carries dev tooling** (devtools/roxygen2/quarto/pak/usethis/rcmdcheck
etc.) — a fresh clone's `renv::restore()` yields a runtime+test library only; install dev
tooling via `Config/Needs/dev` / `Config/Needs/website` (pak understands these) or the renv
dev profile field. (3) S720's standing gotchas carry forward: context-budget reds by-design
until the CLAUDE.md reduction campaign; every `methodology_trim.py` run needs
`--budget-bytes 65536`; the per-clone no-growth hook refuses CLAUDE.md growth. (4) If a future
feature reintroduces `grid`/`png`/`shinyWidgets`, re-declare them in `Suggests:` then — their
deletion is "unused now", not "banned". (5) Full-suite baseline re-confirmed this session:
2437/0/0/184/40.

### Session 719 Handoff Evaluation (by Session 720)
**Score: 9/10.** **What helped:** gotcha (3) "expect 0 undocumented commits past the
frontier; measure it" measured exactly 0 — the first clean reconcile after two
1-commit sessions; next-step (B) named this session's deliverable with the
`BACKLOG.md:119` pointer, and that item's "State as of S719" paragraph was accurate
in every checked particular (seed untouched, history gitignored, tools
build-ignored, `--budget-bytes 65536` the only way `SESSION_NOTES.md` fires);
gotcha (4) pre-warned not to read `context_budget.py`'s seed-config reds as P10
defects — directly load-bearing for this exact deliverable; the "trim is one
dry-run-verified command away" claim re-verified live (this session's own dry run:
L1–L3 OK, 79,738 B → 3,500 B — larger than their 71,192 → 4,018 because the file
had since grown, consistent). **What was missing:** nothing material; one
discoverable-only wrinkle — the dashboard's `SESSION_NOTES.md` HIGH-flag text
("the trimmer answers NO_CONFIG") contradicts the local trimmer extension, found
only by running both this session. **What was wrong:** nothing found; every
checked claim held. **ROI:** high.

### What Session 720 Did
**Deliverable:** `context_budget.py` ADOPTED with honest ceilings + ledger-trigger
budget SETTLED at the old 65,536 B cadence + the owed `SESSION_NOTES.md` trim
executed — **DONE, owner-ratified** (`BACKLOG.md:119` item, removed in the adoption
commit; both decisions picked via `AskUserQuestion` — adopt-honest over
freeze-at-current and delete; old-cadence-and-trim over the 196,608 B default and a
one-off trim). Docs/process tooling, no TDD phases, no `.R` files touched.
**Started/completed:** 2026-09-19 (single session). Claim `572562f1`; adoption
`bc6be1d0`; trim `c079c27a`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per commit (the trimmer wrote its own for the
trim). FM #28 reduction: `SESSION_NOTES.md` 79,738 B → 3,500 B (21 records to
`docs/archive/SESSION_NOTES-through-2026-09-19.md`, L1–L3 verified pre-commit).

**What actually happened, in order:**
1. **Phase 0:** reconcile clean (0 undocumented commits, predicted 0); CI 10/10
   green on `4565c39d`; dashboard 96/100; owner picked this item from the 4-option
   picker. Claim `572562f1`.
2. **Evaluation:** seed-config run exit 2 (`CLAUDE.md` 41,622 B over 28,000;
   structure pattern instrument-failed; fence missing). `--calibrate` REJECTED:
   0.60 B/token with a −6,015-token intercept (n=119, R²=0.73) — implausible,
   confounded; adopted the dashboard's measured densest 2.27 B/token instead.
   Overlap analysis: dashboard observes, trimmer archives chronological ledgers,
   `context_budget.py` uniquely gates `CLAUDE.md` (under the one-read cap, so
   dashboard-invisible; not a ledger, so trimmer-unreachable). Trim measurements:
   SN 79,738 B fires only under 65,536; HANDOFFS 62,667 and CHANGELOG 49,819 fire
   under neither.
3. **Gate:** two `AskUserQuestion`s; owner ratified both recommended options.
4. **Adoption `bc6be1d0`:** config rewritten with derivations in `_` keys
   (ceilings aligned so a `SESSION_NOTES.md` red means exactly "a trim is owed");
   `budget:protected` fence around the Project Overview; per-clone no-growth hook
   installed; Phase 0 check + red-by-design expectations added to `CLAUDE.md`;
   S719's open trigger-budget paragraph resolved; BACKLOG item swapped for the
   successor "CLAUDE.md reduction campaign" (READY, M). Committed `--no-verify` —
   the hook correctly refuses the `CLAUDE.md` growth this very commit makes;
   bypass recorded in the ledger entry.
5. **Trim `c079c27a`:** dry run then `--write` under `--budget-bytes 65536`;
   verify.sh OK before commit; the hook ran live on this commit and passed it
   (the shrink path, observed end-to-end).

**Self-assessment (Session 720): 9/10.** **Strengths:** (1) measured before
deciding, and rejected the tool's own calibration when it was confidently wrong
rather than adopting a bad number; (2) both decisions went to the owner with
recommendations and measured trade-offs, none pre-empted; (3) single-remedy design
— the two tools' `SESSION_NOTES.md` triggers are the same number, so no standing
two-trigger disagreement; (4) honest-red posture with the remedy filed as a
BACKLOG item and growth mechanically refused meanwhile. **Weaknesses:** (1) one
`BACKLOG.md` edit clipped the first line of the adjacent `Suggests:` item —
caught and restored before commit, but a real anchor-selection error; (2) first
config write guessed `max: 0` disables a bound (it is literal) — caught by
running the tool, cost one iteration; (3) `CLAUDE.md` grew 1,726 B in the very
session that adopted its ceiling (fence + Phase-0 step + decision record) —
documented as red-by-design, but the irony stands.

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~6 expected after close-out: 1
pre-existing + claim + adoption + trim + records + sha — the last two are an
estimate at write time). All changes are docs/config; CI clones never see the
per-clone hook. (B) `Suggests:` audit (READY, S — the item now sits near
`BACKLOG.md:133`; recount after any BACKLOG edit). (C) Owner decisions pending:
package-split disposition (`BACKLOG.md:71`), REUSE registration (`BACKLOG.md`
Housekeeping). (D) `CLAUDE.md` reduction campaign (new item, READY, M) — clears
the by-design red and re-greens the Phase 0 budget check. (E) Informational: the
dashboard's `SESSION_NOTES.md` HIGH flag should clear on its next Phase 0 run
(post-trim 3,500 B); LabKey remainder still BLOCKED.

**Key files:** `.context-budget.json` (calibrated config — every value carries its
derivation in the neighbouring `_` key), `CLAUDE.md` "Context-budget check" under
Additional Phase 0 steps, `CLAUDE.md` trigger-budget decision inside the
`methodology_trim.py` checklist block, `BACKLOG.md:119` (reduction-campaign item),
`docs/archive/SESSION_NOTES-through-2026-09-19.md` + `.verify.sh`,
`.git/hooks/pre-commit` (per-clone, untracked).

**Gotchas for the next session:** (1) **Phase 0's `python3 context_budget.py` run
exits 2 with `CLAUDE.md` + resident red BY DESIGN** until the reduction campaign
lands — only *new* reds are findings; a `SESSION_NOTES.md` red means a
`--budget-bytes 65536` trim is owed, nothing else. (2) **The pre-commit hook
refuses any commit that grows `CLAUDE.md`** — shrink it, or `--no-verify` with the
rationale recorded in the ledger entry; a fresh clone must re-run
`python3 context_budget.py install-hook`. (3) **Every `methodology_trim.py` run
needs `--budget-bytes 65536`** (the tool keeps no per-project setting; decision
recorded in `CLAUDE.md`). (4) `HANDOFFS.md` was 62,667 B before this session's
receipt — under the 65,536 budget it is within ~3 KB of firing; this close-out
measures it after appending (result in the close-out ledger entry) and trims it
if it fires. (5) The dashboard HIGH-flag text "the trimmer answers NO_CONFIG"
for `SESSION_NOTES.md` overstates (stock-class hardcoding vs the local
extension); do not act on the text, act on the size. (6) Full-suite baseline
re-measured this session — see the close-out ledger entry for the number
(2,437 blocks expected).

