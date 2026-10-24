# Diagnosis: the scheduled `shinytest2` run of 2026-10-23 that hit its 45-minute limit (S1046, 2026-10-23)

**Deliverable of S1046:** why run `39916862256` (job `120292192510`) was cancelled with "exceeded the
maximum execution time of 45m0s". Nothing was fixed here: the cause sits outside this repository, and
any change to the limit is its own strict-TDD change (see "What a change would touch").

## In plain words

The tests were not slow and nothing hung. **Downloading the tools the job needs ran 6 to 26
times slower than on the night before** (5.6, 25.6 and 6.9 times in the three steps below), so setup
used 31 minutes and 47 seconds of the 45 minutes before a single test started. The tests then ran at
their usual speed and were cut off with 7 of their 21 groups not yet started.

The job installs R, its Linux packages and Chrome with `apt` from Ubuntu's server
(`azure.archive.ubuntu.com`). On 2026-10-23 that server delivered about 52 to 55 kB per second in
all three places the job uses it. On 2026-10-22 the same three steps ran at 309, 1,328 and 360 kB
per second.

## Evidence

All times are UTC. The run used commit `c5545b016`, the same commit as the three green nights before it
(2026-10-20, -21, -22), so no code changed.

| Step | 2026-10-23 (cancelled) | 2026-10-22 (green) |
|---|---|---|
| `setup-r`, `apt` fetch | 29.6 MB in 8 min 58 s (54.9 kB/s) | 30.9 MB in 1 min 40 s (309 kB/s) |
| `setup-r`, step length | 13.3 min | 2.3 min |
| `setup-r-dependencies`, `apt` fetch | 52.1 MB in 16 min 44 s (51.9 kB/s) | 183 MB in 2 min 18 s (1,328 kB/s) |
| `setup-r-dependencies`, step length | 17.4 min | 4.0 min |
| Set up Chrome, `apt` fetch | 2,060 kB in 39 s (52.2 kB/s) | 2,060 kB in 6 s (360 kB/s) |
| Time before the first test | 31 min 47 s (07:18:17 to 07:50:04) | 6 min 57 s (07:18:59 to 07:25:56) |
| Test tier | 13.5 min, then cancelled at 08:03:35 | 23.6 min, finished |

- **Usual setup.** Over the 29 earlier scheduled runs `setup-r` took 0.4 to 2.3 minutes, and over the
  previous 11 `setup-r-dependencies` took 1.0 to 4.0 minutes. The 2026-10-22 numbers above were already the
  slowest of those, so the slowdown may have begun a night earlier.
- **Where the 17.4 minutes went.** 16 min 44 s of `setup-r-dependencies` is the single `apt` fetch
  (ends 07:48:48). The R packages themselves took about 15 seconds after it.
- **The tests ran at their normal pace.** The tier's 14th group started 12 min 43 s into the tier on
  2026-10-23 and 13 min 27 s in on 2026-10-22. The log shows no stalled group.
- **Length of the tier on the 29 earlier runs:** 18.6 to 37.8 minutes, median 26.9.
- **Mirror errors:** one `Ign:` line in the log (07:18:59) and no `Err:` lines, so the server was
  slow, not failing.

To re-read this: `gh run view --job=120292192510 --log` (the `Fetched ... in ...` lines carry the
throughput; the `##[group]E2E module group` lines carry the group start times).

## Hypotheses, ranked, with what decided each

1. **A slow download server ate the time budget.** Predicts low `apt` throughput in every stage and a
   normal test pace. **Confirmed on both** (table above).
2. **A code change made the tier slower or broke it.** Predicts a different commit or a slower pace.
   **Rejected:** same commit as three green nights; the pace matches.
3. **One test group hung.** Predicts a group with no progress. **Rejected:** the groups advance one
   after another to the cancel; the 14th started 48 seconds before it.
4. **The R package cache missed.** Predicts a long R-package install. **Rejected:** R packages took
   seconds; the cost was the `apt` fetch.
5. **A new R release made the install heavier.** Predicts a larger download. **Rejected:** 29.6 MB
   against 30.9 MB the night before.

## What is not established

- **Why the server was slow.** The logs show the speed, not the reason; it is on GitHub's or
  Ubuntu's side. No other workflow ran at that hour, so there is nothing to compare against.
- **The runner image.** The cancelled run used image `20261012.334.1` and agent `20261012.601`; the
  green night before used `20261018.339.1` and `20261015.610`. That is two runs and no mechanism, so it is a
  note, not a cause.
- **Whether it repeats.** The 2026-10-24 07:18 UTC run had not happened when this was written; the
  next Phase 0 `gh run list` shows it.
- **The failures of 2026-10-16 and 2026-10-17** (earlier code) were not examined; they are not this
  deliverable. The 2026-10-17 run took 40.5 minutes in all (tier 37.8), which is 4.5 minutes under the cap.

## How the limit got to 45

The limit was 30 minutes until the run of 2026-09-27 was cancelled at it (30.02 minutes, a real
capacity-growth timeout), and was raised to 45. `tests/testthat/test_shinytest2_workflow_timeout.R`
pins it at exactly 45.

## What a change would touch (not done)

On the night in question the job needed about **55 minutes**: 31.8 minutes of setup plus the 23.6
minutes the tier took the night before (an estimate: 14 of 21 groups matched that night's pace).
A limit of 75 minutes would have let it finish. The change is `timeout-minutes` in
`.github/workflows/shinytest2.yaml:46` and the pinned `45L` in
`tests/testthat/test_shinytest2_workflow_timeout.R:30`; the guard would be edited first (RED), then the
workflow (GREEN). The repository is public, so runner minutes cost nothing; the price of a higher limit
is that a real hang is cut off 30 minutes later.
