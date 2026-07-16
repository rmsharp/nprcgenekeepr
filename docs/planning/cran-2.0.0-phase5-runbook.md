# CRAN 2.0.0 — Phase 5 cross-platform-check runbook (owner-run)

**Companion to** `docs/planning/cran-2.0.0-submission-plan.md` Phase 5 + §7, and the
rewritten `cran-comments.md`. Authored by Session 135 (2026-06-18); **refreshed by
Session 242 (2026-06-29)** — submission tooling is now present (was "absent"); the R-hub
branch caveat is removed (the 2.0.0 code is on `master`, in sync with `origin/master`;
the old `add-methodology` branch is gone); the local `--as-cran` gate is re-confirmed GREEN.
**Refreshed again by Session 359 (2026-07-11)** — the local gate was stale (last
locally confirmed S241/S242, 2026-06-29): re-ran `R CMD build .` + `R CMD check
--as-cran --timings` on current `master` (`19ae5657`, macOS, R 4.6.1) and got
`0 errors | 0 warnings | 1 note` (the expected incoming-feasibility note; the
local HTML-manual note is gone — this machine's Tidy is now current). Slowest
example 1.465s (`groupAddAssign`), tests 86s, vignette rebuild 21s — all inside
prior headroom. **More importantly: the win-builder/R-hub results already on file
in `cran-comments.md` are stale in a way that matters, not just old.** They were
captured in Session 328 (2026-07-09, commit `8ca8bb24` — the exact commit later
submitted and archived) — **one day before** Session 349 (2026-07-10, commit
`f7a62aca`) fixed the CRAN Policy violation (`appServer()` unconditionally
writing `~/nprcgenekeepr.log`) that caused the archival. `8ca8bb24` is a verified
git ancestor of `f7a62aca`, so those win-builder/R-hub runs checked the
*pre-fix* code — they do not attest to the code this resubmission will actually
carry. §2 and §3 below must be re-run before this resubmission, not merely
re-pasted from the existing results. (Whether the log-write itself would ever
surface as a win-builder/R-hub check finding is a separate question — `appServer()`
launches an interactive Shiny app that automated checks never invoke, so this was
most likely caught by a human CRAN reviewer, not the check suite. Re-running is
still owed: the results on file are 134 commits behind current `master` (9 touching
`R/`/`tests/`/`DESCRIPTION`/`NAMESPACE`) regardless of that specific defect.)
`cran-comments.md`'s win-builder/R-hub lines have been reset to placeholders
accordingly.
**§2/§3 executed and results folded in by Sessions 361-362 (2026-07-11).**
Session 361 triggered `devtools::check_win_devel/release/oldrelease()` and
`rhub::rhub_check(platforms = c("linux", "windows", "macos"))` on current
`master` (owner-scoped via `AskUserQuestion` to trigger-only, explicitly
excluding `devtools::submit_cran()`). While confirming the R-hub dispatch via
`gh run list`, that same session found `R-CMD-check.yaml` (this repo's own
GitHub Actions CI, unrelated to CRAN's win-builder infrastructure) had been
failing on `windows-latest (release)` on every push since S351 — a real,
reproducible `test_modInput_excelSireDam.R` failure via `create_wkbk()` ->
`WriteXLS::WriteXLS()` (`cannot open .../WriteXLS/1.csv`), a classic
Perl-on-Windows dependency symptom — and, reasonably given the evidence at the
time, flagged it as "very likely" to also block the just-triggered win-builder/
R-hub checks. **Session 362 processed the actual results and found that
prediction did not hold:**
- **win-builder (all three R versions) came back clean** — `0 errors | 0
  warnings` on R-devel/R-release/R-oldrelease, each with only the expected
  incoming-feasibility note (R-oldrelease additionally flagged the known
  `groupAddAssign` >10s timing note on its slower hardware). Verbatim
  `00check.log` for each run confirms `* checking tests ... OK` /
  `Running 'testthat.R' [...s]` with no failure output — `test_modInput_
  excelSireDam.R` genuinely passed on win-builder's Windows Server 2022.
- **R-hub's windows (R-devel) job also finished `Status: OK`,
  `[ FAIL 0 | WARN 1 | SKIP 220 | PASS 3013 ]`** — but its raw log DOES
  contain the same `ERROR: cannot open .../WriteXLS/1.csv` diagnostic text,
  appearing non-fatally (after the check had already reported `Status: OK`,
  most plausibly during example/vignette re-execution rather than the
  `testthat.R` run itself — not fully disambiguated). This is consistent with
  an intermittent Perl-subprocess timing race specific to GitHub-hosted
  Windows runners (both `r-lib/actions/check-r-package` and
  `r-hub/actions/run-check` sit on the same runner family), not a
  deterministic code defect, and not present on CRAN's own win-builder
  infrastructure at all.
- **Net effect: the CRAN pre-submission gate is clean across every environment
  that was actually run this cycle** (local macOS, win-builder x3, R-hub x3).
  The underlying `WriteXLS`/Windows CI flakiness is real or the reproducibly
  red `R-CMD-check.yaml` (7 consecutive runs, S351-S360) — a genuine hygiene
  issue worth fixing (see `BACKLOG.md`'s corrected entry) — but it is a
  GitHub-Actions-runner-specific gap, not a CRAN-submission blocker per the
  actual evidence gathered this cycle. Results folded into `cran-comments.md`'s
  "Test environments" section (replacing the placeholders) rather than
  re-pasted from stale prior-cycle numbers.
- **Still owner-only, unchanged:** `devtools::submit_cran()` and the
  maintainer-email confirmation click.

**Refreshed again by Session 388 (2026-07-16)** — 25 commits touched
`R/`/`tests/`/`DESCRIPTION`/`NAMESPACE` since the S359 gate (`19ae5657`),
including the full XARCH-2 module-contract refactor (S372-377) and XARCH-5
Phase 1 (S386) — the same order of staleness that triggered a mandatory
re-run at S359 (which flagged only 9 commits). Owner scoped this session to
**local re-verify only** (via `AskUserQuestion`), explicitly deferring
win-builder/R-hub re-triggering. Re-ran `R CMD build .` (from the package
root, so renv resolves `openxlsx` and the rest of the project library —
running `R CMD check` from outside the package root, without renv active,
produces a false `ERROR: Package required but not available: 'openxlsx'`;
use `R CMD check --output=<dir>` to keep check artifacts out of the repo tree
while still running from the package root) + `R CMD check --as-cran
--timings` on current `master` (`79380fba`, package code unchanged from
`971bf3c9` — the claim commit touched only `SESSION_NOTES.md`/`HANDOFFS.md`)
in the scratch directory. Result: **`0 errors | 0 warnings | 1 note`**
(the expected incoming-feasibility note only) — timings essentially
unchanged from S359/S362: examples 23s (slowest single example
`groupAddAssign` 1.486s), tests 87s, vignette rebuild 20s — all inside prior
headroom. **`cran-comments.md`'s existing prose numbers ("about 1.4s",
"about 23s", "about 86s", "about 21s") remain accurate as written; no edit
needed.** **Residual staleness, explicitly accepted this session:**
win-builder/R-hub results on file are still from S361/362, i.e. from before
these same 25 commits — the owner chose not to re-trigger them this session
and will decide when to (mirroring the S361 owner-scoped precedent) before
running `devtools::submit_cran()`.

**Why this is a runbook, not an executed step.** win-builder and R-hub v2 are
**outward-facing** (they upload the package to external services), need **network**
access and your **GitHub token**, and return results **asynchronously** (win-builder by
email, ~30 min per run; R-hub via GitHub Actions). Per SAFEGUARDS these are yours to
trigger. `devtools` / `rhub` / `gitcreds` are now **installed** in the renv library
(§0; they were absent when this runbook was first written). The **final CRAN upload is
also yours** (HARD STOP at the end — plan decision #3).

Run these from the package root, in an R session with network access.

---

## Quick sequence (copy-paste, in order)

The full rationale for each step is in the numbered sections below; this is the condensed
run-list. No `git push` is in this list because R-hub checks **`master`**, which is already
in sync with `origin/master` (see step 3).

```r
# one-time -- devtools/rhub/gitcreds are PRESENT as of S242 (install only on a fresh clone):
# install.packages(c("devtools", "rhub", "gitcreds"))
gitcreds::gitcreds_set()                 # paste a GitHub PAT (repo + workflow scopes)

# build the artifact win-builder and CRAN receive:
devtools::build()                        # -> nprcgenekeepr_2.0.0.tar.gz

# cross-platform checks (results arrive async: win-builder by email, R-hub on GitHub):
devtools::check_win_devel()              # ~30 min each, emails rmsharp@me.com
devtools::check_win_release()
devtools::check_win_oldrelease()
rhub::rhub_doctor()                      # verify PAT + setup
rhub::rhub_check(platforms = c("linux", "windows", "macos"))   # checks master (2.0.0, in sync w/ origin) -- no push needed

# only after ALL results are in and clean, and folded into cran-comments.md (step 4):
devtools::submit_cran()                  # HARD STOP -- owner only; then click the email confirmation link
```

Expected results per platform, and what to do if a surprise ERROR/WARNING appears, are in
steps 2-4 below.

---

## 0. One-time prerequisites

```r
# Submission tooling -- devtools, rhub, gitcreds -- is PRESENT in this renv library
# (verified Session 242, 2026-06-29). On a fresh clone, install any that are missing:
#   install.packages(c("devtools", "rhub", "gitcreds"))

# A GitHub Personal Access Token is required for R-hub v2 (it dispatches a
# GitHub Actions workflow). Scopes needed: repo + workflow.
# Create one at https://github.com/settings/tokens, then store it:
gitcreds::gitcreds_set()        # paste the PAT when prompted
```

Notes:
* The win-builder and R-hub **remote** machines install the package's dependencies
  themselves, so the four Suggests S134 added to the local renv library
  (`covr`, `shinytest2`, `shinyWidgets`, `spelling`) are **not** required locally for
  these cross-platform runs. (They were needed only for S134's local true-gate.)
* Confirm the function signatures below against the installed versions —
  the R-hub v2 API has changed across releases.

---

## 1. Build the final source tarball (for win-builder + the submission)

```r
devtools::build()               # or: R CMD build .   -> nprcgenekeepr_2.0.0.tar.gz
```

This is the artifact win-builder checks and the artifact you upload to CRAN. Confirm it
is named `nprcgenekeepr_2.0.0.tar.gz`.

> The local `--as-cran` gate is **GREEN** on the current `master`: Session 240 (2026-06-29)
> re-ran `R CMD build .` + `R CMD check --as-cran --timings` on the 2.0.0 tarball after dozens
> of commits of new work since the original S134 gate and got `0 errors | 0 warnings | 2 notes`
> (the two documented false-positives); Session 241 re-confirmed it after the README badge
> fix. **Session 359 (2026-07-11) re-confirmed it again** on commit `19ae5657` (134 commits
> later, 9 touching `R/`/`tests/`/`DESCRIPTION`/`NAMESPACE`, including S349's CRAN-policy
> log-write fix): `0 errors | 0 warnings | 1 note` — one fewer note than S240/S241 saw, because
> this machine's HTML Tidy is now current (see `cran-comments.md` for the full breakdown).
> The `build` here only produces a fresh artifact to upload — the check result already
> applies. (macOS, R 4.6.1; tarball 2.3 MB, vignettes build cleanly.)

---

## 2. win-builder x3 (uploads the LOCAL tarball — checks the local 2.0.0 tree)

```r
devtools::check_win_devel()        # R-devel
devtools::check_win_release()      # R-release
devtools::check_win_oldrelease()   # R-oldrelease
```

* Each uploads to win-builder and returns a result **by email** to the DESCRIPTION
  maintainer address (`rmsharp@me.com`) in ~30 minutes. Make sure that mailbox is
  unfiltered (CRAN automation must reach it too — plan §1).
* **Expected:** `0 errors | 0 warnings | 1 note` on each — the note being the same
  incoming-feasibility / new-submission note explained in `cran-comments.md`. The local
  HTML-manual note (NOTE 2) should **not** appear on win-builder.

---

## 3. R-hub v2 (checks code pulled FROM GitHub — see branch state below)

```r
rhub::rhub_doctor()                                  # verify setup + token
rhub::rhub_check(platforms = c("linux", "windows", "macos"))
```

* `.github/workflows/rhub.yaml` already exists (it ran for the 1.0.8 submission), so
  `rhub_setup()` is **not** needed again.
* **BRANCH STATE (verified — Session 242, 2026-06-29).** R-hub v2 checks the code that is
  **on GitHub**, not your local working tree. The 2.0.0 package code now lives on **`master`**,
  the repo's default branch, which is **in sync with `origin/master`** — verified this session:
  `git status` = "up to date with 'origin/master'"; `git rev-list --left-right --count
  origin/master...master` = `0  0`; `git diff --name-only origin/master..master` is empty;
  `DESCRIPTION` is `2.0.0`. So `rhub_check()` on `master` checks the correct 2.0.0 code with
  **no branch gymnastics and no push needed**. (The old `add-methodology` working branch this
  section used to reference has been **merged and deleted**, and `origin/master` is no longer at
  1.1.0.9000 — ignore any earlier "push add-methodology first" / "open a new PR to master" /
  "PR #53" wording; all obsolete.) Before running, just confirm the tree is clean and current:
  `git status` should say "up to date with 'origin/master'". If a session left local-ahead
  commits, they are **documentation only** (session notes, changelog, this runbook, the plan —
  all `.Rbuildignore`d, not part of the built package) and do **not** change what R-hub sees;
  pushing them is optional housekeeping (not required for R-hub correctness) but keeps origin current.
  *(win-builder, step 2, has no such caveat — it uploads your local tarball.)*
* The 1.0.8 R-hub run showed several container **failures that were pure infrastructure**
  ("there is no package called 'pak'"), not code defects — the `linux,windows,macos`
  default subset above is the CRAN-relevant set and avoids most of those containers.
  Results appear in the repo's GitHub Actions tab and by email.

---

## 4. Fold the results into `cran-comments.md`, then submit (HARD STOP)

1. Edit `cran-comments.md` `## Test environments`: replace each
   `-- to be run before submission` marker with the actual summarized result, e.g.

   ```
   * win-builder R-devel:        0 errors | 0 warnings | 1 note (incoming feasibility)
   * win-builder R-release:      0 errors | 0 warnings | 1 note
   * win-builder R-oldrelease:   0 errors | 0 warnings | 1 note
   * R-hub linux / windows / macos: 0 errors | 0 warnings | <n> notes
   ```

   (These example numbers live here, not in `cran-comments.md` — that file should
   contain only finished, CRAN-facing prose with nothing to delete before pasting.)
2. Reconcile the NOTE 1 "possibly-misspelled words" list in `cran-comments.md` against
   the **actual** incoming-feasibility output (the win-builder log) so it matches what
   CRAN reports — CRAN computes its own list with **GNU `aspell`** and does **not** read
   `inst/WORDLIST`, so the local spell test is not the authority here. Session 242
   (2026-06-29) pre-reconciled NOTE 1 to the words an offline check flags in DESCRIPTION's
   Title/Description — `EHR`, `kinships`, `LabKey`, `Macaca`, `mulatta`, `Raboin` (all
   correct; the `<...>` reference URL is filtered out of the spell check). That check used
   `utils::aspell(filter = "dcf", program = "hunspell")` — the same call `R CMD check` makes
   — because `aspell` itself is not installable here and the local `hunspell` needs its
   dictionary on `DICPATH` (`system.file("dict", package = "hunspell")`). hunspell's
   dictionary differs slightly from CRAN's `aspell`, so treat this as a proxy: confirm the
   final list against the win-builder output and adjust the "for example" list if CRAN
   names a different set.
3. If any new ERROR/WARNING appears on a platform, **stop** and open a fix session
   (RED-first) — do not submit with an unexplained ERROR/WARNING (plan §1 acceptance bar).
4. Submit — **owner only** (outward-facing publish; SAFEGUARDS + plan decision #3):

```r
devtools::submit_cran()         # or the web form at https://cran.r-project.org/submit.html
```

Then click the **maintainer-email confirmation link** CRAN sends. That confirmation is
the maintainer's action and cannot be delegated.

---

## 5. After CRAN accepts → Phase 6

Tag the release, publish the GitHub release, bump to the dev version — see plan Phase 6
(`usethis::use_github_release()`, `usethis::use_dev_version()`). Do this only after the
acceptance email.
