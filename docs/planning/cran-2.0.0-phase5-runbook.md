# CRAN 2.0.0 — Phase 5 cross-platform-check runbook (owner-run)

**Companion to** `docs/planning/cran-2.0.0-submission-plan.md` Phase 5 + §7, and the
rewritten `cran-comments.md`. Authored by Session 135 (2026-06-18).

**Why this is a runbook, not an executed step.** win-builder and R-hub v2 are
**outward-facing** (they upload the package to external services), need **network**
access and your **GitHub token**, and return results **asynchronously** (win-builder by
email, ~30 min per run; R-hub via GitHub Actions). Per SAFEGUARDS these are yours to
trigger. `devtools` / `rhub` / `gitcreds` are **absent** from this environment (the
commands below install them). The **final CRAN upload is also yours** (HARD STOP at the
end — plan decision #3).

Run these from the package root, in an R session with network access.

---

## 0. One-time prerequisites

```r
# Submission tooling is not installed in this renv library — add it.
install.packages(c("devtools", "rhub", "gitcreds"))

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
* Confirm the function signatures below against the versions you just installed —
  the R-hub v2 API has changed across releases.

---

## 1. Build the final source tarball (for win-builder + the submission)

```r
devtools::build()               # or: R CMD build .   -> nprcgenekeepr_2.0.0.tar.gz
```

This is the artifact win-builder checks and the artifact you upload to CRAN. Confirm it
is named `nprcgenekeepr_2.0.0.tar.gz`.

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

## 3. R-hub v2 (checks code pulled FROM GitHub — see the branch caveat)

```r
rhub::rhub_doctor()                                  # verify setup + token
rhub::rhub_check(platforms = c("linux", "windows", "macos"))
```

* `.github/workflows/rhub.yaml` already exists (it ran for the 1.0.8 submission), so
  `rhub_setup()` is **not** needed again.
* **BRANCH CAVEAT (important).** R-hub v2 checks the code that is **on GitHub**, not your
  local working tree. `origin/add-methodology` is already at version 2.0.0, but is
  **2 commits behind your local branch**: it is missing S133's `withr`-in-Suggests fix
  (commit `b93a5b4c`, which clears a CRAN tests WARNING) and S134's Phase-4 WORDLIST work
  (`56b66ae0`). If you run `rhub_check()` without pushing first, R-hub checks that stale
  tree and will **re-report the very `withr` WARNING S133 fixed** — a result that disagrees
  with win-builder. So run `git push origin add-methodology` **before** `rhub_check()`.
  * To instead check `master`: `origin/master` is still at **1.1.0.9000** and contains
    **none** of the 2.0.0 commits (the merged PR #52 carried only S101-S117, not the
    version bump). You would first have to open a **new** PR to merge `add-methodology` ->
    `master`. There is **no open PR for this** — the previously-assumed "PR #53" does not
    exist (issue numbers consumed that range; do not cite a specific PR number).
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
   the **actual** incoming-feasibility output (the win-builder / `--as-cran` log) so it
   matches what CRAN reports — CRAN computes its own list and does **not** read
   `inst/WORDLIST`, so the local spell test is not the authority here.
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
