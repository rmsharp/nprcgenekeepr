# CRAN 3.0.0: the cross-platform runs (owner-run)

**Companion to** `docs/planning/cran-3.0.0-submission-plan.md` Phase 8 and `cran-comments.md`. Written
S1104, 2026-10-31, from the 2.0.0 runbook (`docs/planning/cran-2.0.0-phase5-runbook.md`).

**Why you run these (D5 = A):** each one sends the package to an outside service, and the results reach
you by email or through your GitHub token. Nothing here submits to CRAN. **Do not run
`devtools::submit_cran()` from this runbook; that is Phase 9.**

**How long:** R-hub took about 33 minutes per run in July. win-builder usually takes about 30 minutes per
check, but R-devel once held an upload more than 2 h 20 min. Each upload first builds the package here,
which takes a few minutes (an estimate).

Run everything from the package root, in one R session, in this order.

---

## 1. Confirm the code is the checked code

In a terminal:

```sh
git status --short
git diff --stat 74715d95b HEAD -- R tests man vignettes inst data DESCRIPTION NAMESPACE
git diff --stat 74715d95b origin/master -- R tests man vignettes inst data DESCRIPTION NAMESPACE
```

All three should print nothing. `74715d95b` is the commit CRAN plan Phase 7 checked and CI passed. If
anything prints, stop: a change to those paths repeats Phase 7.

No push is needed. R-hub checks what is on GitHub, and S1104 confirmed that GitHub's copy of those paths
equals `74715d95b`. Local commits ahead of it are notes only.

## 2. Install `rhub` outside the project library

This keeps `renv.lock` as it is. S1104 ran these lines and `rhub_doctor()` passed: token found, scopes
right, the workflow active on the default branch. `rhub_setup()` is not needed.

```r
options(repos = c(CRAN = "https://cloud.r-project.org"))
rhubLib <- path.expand("~/R/nprcgenekeepr-rhub")
dir.create(rhubLib, recursive = TRUE, showWarnings = FALSE)
utils::install.packages("rhub", lib = rhubLib, type = "binary")
.libPaths(c(rhubLib, .libPaths()))
rhub::rhub_doctor()
```

If `rhub_doctor()` reports a missing token, run `gitcreds::gitcreds_set()` and paste a GitHub token with
the repo and workflow scopes.

## 3. Start the five checks

```r
devtools::check_win_devel()
devtools::check_win_release()
devtools::check_win_oldrelease()
rhub::rhub_check(platforms = c("linux", "windows", "macos"))
devtools::check_mac_release()
```

Each `devtools` call builds the package from this tree and uploads it, so no separate `devtools::build()`
is needed. Stay on `master`: `rhub_check()` checks the branch you are on.

- **win-builder:** each call first asks you to confirm the maintainer address, `rmsharp@me.com`, and the
  results come there by email.
- **R-hub:** results appear in the repository's Actions tab.
- **macOS builder:** no email. The call prints a link, with results there in about 5-10 minutes. Copy the
  link.

**An upload gives no receipt.** Do not repeat one because no email has come: a same-named file waiting in
the queue blocks a second copy. To see whether R-devel's is still queued, in a terminal:
`curl ftp://win-builder.r-project.org/R-devel/`. The file leaves that list when its batch starts, and the
check runs some time after that.

## 4. What to expect, and what to do

| Check | Expected |
|---|---|
| win-builder R-devel | 0 errors, 0 warnings, 1 NOTE; "Check time in seconds" 540 or less |
| win-builder R-release and R-oldrelease | 0 errors, 0 warnings, 1 NOTE |
| R-hub linux, windows, macos | `Status: OK` |
| macOS builder | 0 errors, 0 warnings; this service was not used for 2.0.0, so any NOTE is worth reading |

**The expected NOTE** is incoming feasibility: the word "de" (from "de-identified") and the thoughtco.com
URL with an error status. Please open that URL once in a browser, because the cover note says it is
reachable: <https://www.thoughtco.com/age-sex-pyramids-and-population-pyramids-1435272>.

**Two NOTEs that should be gone:** the version (it was `2.0.0.9000` in earlier uploads) and the invalid DOI
(fixed S1097). Either one coming back means the upload was not this tree.

- **R-devel reads over 540 s:** upload it again before anything is cut. One tarball read both 617 s and
  520 s, so about 100 s is run-to-run noise. The levers left are at the end of the plan's section 3.6.
- **Any ERROR or WARNING, or any other NOTE:** stop and do not submit. The next session reads it. A fix
  goes through its own RED-first session and repeats Phase 7.
- **R-hub fails with "there is no package called 'pak'":** that was the service's own failure in the 1.0.8
  run, not a code defect. Re-run that platform.

## 5. Hand the results back

Start a new session and say "fold in the CRAN Phase 8 results". Paste, or save as files, for each check:

- win-builder: the email, and the `00check.log` from its link;
- win-builder R-devel: also the "Check time in seconds" line;
- the macOS builder: the link it printed;
- R-hub: the run's name, which `rhub_check()` prints (in July: "hillocked-veery"). The session reads the
  rest with `gh`.

That session replaces every "to be run before submission" line in `cran-comments.md`, corrects the NOTE list
to what win-builder reported (CRAN's spell check is GNU `aspell`, which the local tools cannot stand in
for), and then `grep -c 'to be run before submission' cran-comments.md` must print 0.

## 6. Then stop (HARD STOP)

Submission is Phase 9 and it is yours: `devtools::submit_cran()`, then the confirmation link CRAN emails to
the maintainer address. Do it only after step 5's session has finished.

An open choice for you, not needed for these runs: whether to report the R bug in `readtablehead()`
upstream (`BACKLOG.md`, the CRAN item). Nothing has been posted, and `cran-comments.md` describes it to CRAN.
