# CRAN 2.0.0 — Phase 5 cross-platform-check runbook (owner-run)

**Companion to** `docs/planning/cran-2.0.0-submission-plan.md` Phase 5 + §7, and the
rewritten `cran-comments.md`. Authored by Session 135 (2026-06-18); **refreshed by
Session 242 (2026-06-29)** — submission tooling is now present (was "absent"); the R-hub
branch caveat is removed (the 2.0.0 code is on `master`, in sync with `origin/master`;
the old `add-methodology` branch is gone); the local `--as-cran` gate is re-confirmed GREEN.

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
> fix. The `build` here only produces a fresh artifact to upload — the check result already
> applies. (macOS, R 4.6.0; tarball ~1.9 MB, vignettes build cleanly.)

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
