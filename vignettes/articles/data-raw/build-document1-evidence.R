# Build the frozen evidence-base CSVs for Document 1 ("Engineering nprcgenekeepr
# 2.0.0"), per docs/planning/v2-transformation-article-plan.md Phase A.
#
# Run from the package root: Rscript vignettes/articles/data-raw/build-document1-evidence.R
#
# Scope boundary (owner-ratified, 2026-07-09): every count below is anchored to the
# CRAN-submission-to-CRAN-submission commit range --
#   v1.0.8 4548aa1b265566c1dd913bd63ce781932879f8a7 (CRAN 2025-07-26)
#   ..v2.0.0 8ca8bb24551a6a95dc4468d8ef5218bd3d3c91e0 (CRAN 2026-07-09)
# -- 512 non-merge commits. Re-running this script after the repository moves on will
# NOT reproduce the same numbers unless RANGE_START/RANGE_END below are left as-is;
# that is intentional (the Reproducibility Decision in the plan's §5-6 freezes data as
# of the v2.0.0 submission commit, not "current state").

RANGE_START <- "4548aa1b265566c1dd913bd63ce781932879f8a7" # v1.0.8, exclusive
RANGE_END <- "8ca8bb24551a6a95dc4468d8ef5218bd3d3c91e0" # v2.0.0, inclusive
SESSION1_COMMIT <- "6fd87749" # first SESSION_RUNNER-numbered commit ("Session 1")

git <- function(...) {
  system2("git", c(...), stdout = TRUE, stderr = FALSE)
}

out_dir <- "vignettes/articles/data"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- T2: module inventory --------------------------------------------------

mod_files <- sort(Sys.glob("R/mod*.R"))
mod_names <- sub("\\.R$", "", sub("^R/", "", mod_files))

responsibility <- vapply(mod_files, function(f) {
  lines <- readLines(f, warn = FALSE)
  hit <- grep("^#'.*Module( -| —).*UI Function", lines, value = TRUE)
  if (length(hit) == 0) return(NA_character_)
  sub("^#'\\s*", "", sub(" Module.*$", "", hit[1]))
}, character(1), USE.NAMES = FALSE)

loc <- vapply(mod_files, function(f) length(readLines(f, warn = FALSE)), integer(1))

test_count <- vapply(mod_names, function(m) {
  pattern <- paste0("^test[-_]?", m, "(\\.R|_.*\\.R)$")
  length(grep(pattern, list.files("tests/testthat"), value = TRUE))
}, integer(1), USE.NAMES = FALSE)

module_inventory <- data.frame(
  module = mod_names,
  responsibility = responsibility,
  loc = loc,
  test_file_count = test_count,
  stringsAsFactors = FALSE
)
write.csv(module_inventory, file.path(out_dir, "module-inventory.csv"), row.names = FALSE)

# ---- T3: migration phase summary (reformatted + sha-verified, not re-derived) ----
# Source: docs/planning/shiny-module-conversion-plan.md §9. Only shas actually quoted
# there are verified here; phases 3-6 cite a session number only in the source plan.

migration_phases <- data.frame(
  phase = 1:9,
  title = c(
    "Summary Statistics tab parity",
    "Wire the GvAndBgDesc description tab",
    "GVA parity: GU-threshold control + subset/filter export",
    "Input parity: genotype file merge",
    "Breeding Groups parity A: downloads + per-group kinship + group selector",
    "Breeding Groups parity B: seed-group pre-seeding + expose inert controls",
    "Input parity: focal-animal / LabKey pedigree build",
    "Enable the shinytest2 E2E harness end-to-end",
    "Declare canonical: alias runGeneKeepR, delete monolith + orphans"
  ),
  risk = c("LOW-MEDIUM", "LOW", "MEDIUM", "MEDIUM", "MEDIUM", "MEDIUM", "HIGH",
           "HIGH", "HIGH (irreversible)"),
  session = c(22, 23, 24, 25, 26, 27, 29, "31-34 (8a-8d) + 37-50 (8e-1..8e-7)", 35),
  commit_sha = c("596f6bc9", "ef6a9f4c", NA, NA, NA, NA, NA,
                 NA, "3db018d1/24992e0b/53a9e5e0/a1618c48"),
  sha_verified = c(TRUE, TRUE, NA, NA, NA, NA, NA, NA, TRUE),
  status = c(rep("DONE", 7),
             paste("DONE (expanded into 4-session subplan 8a-8d, issue #39 CLOSED S34;",
                   "further hardened 8e-1..8e-7, issue #40, S37-S50)"),
             "DONE"),
  stringsAsFactors = FALSE
)
write.csv(migration_phases, file.path(out_dir, "migration-phases.csv"), row.names = FALSE)

# ---- T4 (raw candidates): closed GitHub issues in range --------------------
# Curation into a final "new features" table is Phase C's job, not Phase A's.

gh_json <- tryCatch(
  system2("gh", c(
    "issue", "list", "--state", "closed",
    "--search", "closed:2025-07-26..2026-07-09",
    "--limit", "300", "--json", "number,title,closedAt,labels"
  ), stdout = TRUE, stderr = FALSE),
  error = function(e) NULL
)
if (!is.null(gh_json) && length(gh_json) > 0) {
  issues <- jsonlite::fromJSON(paste(gh_json, collapse = "\n"))
  issues$labels <- vapply(issues$labels, function(l) {
    if (is.data.frame(l) && nrow(l) > 0) paste(l$name, collapse = ";") else ""
  }, character(1))
  issues$closedAt <- substr(issues$closedAt, 1, 10)
  issues <- issues[order(issues$closedAt), c("number", "closedAt", "labels", "title")]
  write.csv(issues, file.path(out_dir, "feature-candidates.csv"), row.names = FALSE)
} else {
  message("gh CLI unavailable or not authenticated -- feature-candidates.csv not regenerated")
}

# ---- T5 / F3: testing growth at checkpoints ---------------------------------

checkpoints <- data.frame(
  label = c("v1.0.8-CRAN", "Session1-start", "Phase9-monolith-deprecated",
            "Phase9-close", "v2.0.0-CRAN"),
  sha = c(RANGE_START, SESSION1_COMMIT, "3db018d1", "a1618c48", RANGE_END),
  stringsAsFactors = FALSE
)
checkpoints$date <- vapply(checkpoints$sha, function(s) {
  git("log", "-1", "--format=%ad", "--date=short", s)
}, character(1))
checkpoints$test_file_count <- vapply(checkpoints$sha, function(s) {
  files <- git("ls-tree", "-r", "--name-only", s, "--", "tests/testthat/")
  sum(grepl("\\.R$", files))
}, integer(1))
checkpoints$shinytest2_referencing_files <- vapply(checkpoints$sha, function(s) {
  files <- git("ls-tree", "-r", "--name-only", s, "--", "tests/testthat/")
  files <- files[grepl("\\.R$", files)]
  sum(vapply(files, function(f) {
    content <- tryCatch(git("show", paste0(s, ":", f)), error = function(e) character(0))
    any(grepl("shinytest2|AppDriver", content))
  }, logical(1)))
}, integer(1))
checkpoints$test_case_count <- vapply(checkpoints$sha, function(s) {
  files <- git("ls-tree", "-r", "--name-only", s, "--", "tests/testthat/")
  files <- files[grepl("\\.R$", files)]
  sum(vapply(files, function(f) {
    content <- tryCatch(git("show", paste0(s, ":", f)),
                         error = function(e) character(0))
    sum(grepl("test_that\\(", content))
  }, integer(1)))
}, integer(1))

# Codecov's per-commit coverage report (api.codecov.io) is keyed by full commit
# sha and only exists for a commit that had a CI-uploaded report under that
# exact sha (a push/PR trigger that ran to completion under the current branch
# tip at the time). Session1-start, Phase9-monolith-deprecated, and
# Phase9-close have no recorded report (API 404) -- NA is the honest value,
# not a bug; see the article's table caption for the caveat. Both
# CRAN-submission endpoints (RANGE_START/RANGE_END) do have recorded reports.
codecov_coverage_pct <- function(full_sha) {
  url <- paste0(
    "https://api.codecov.io/api/v2/github/rmsharp/repos/nprcgenekeepr/commits/",
    full_sha, "/"
  )
  resp <- tryCatch(
    system2("curl", c("-s", "-m", "15", url), stdout = TRUE, stderr = FALSE),
    error = function(e) NULL
  )
  if (is.null(resp) || length(resp) == 0) return(NA_real_)
  parsed <- tryCatch(jsonlite::fromJSON(paste(resp, collapse = "\n")),
                      error = function(e) NULL)
  cov <- parsed$totals$coverage
  if (is.null(cov)) NA_real_ else as.numeric(cov)
}
full_shas <- vapply(checkpoints$sha, function(s) git("rev-parse", s),
                     character(1))
checkpoints$coverage_pct <- vapply(full_shas, codecov_coverage_pct, numeric(1),
                                    USE.NAMES = FALSE)
write.csv(checkpoints, file.path(out_dir, "testing-growth.csv"), row.names = FALSE)

# ---- F1: commit-activity timeline (commits per month) -----------------------

months <- git("log", "--no-merges", "--format=%ad", "--date=format:%Y-%m",
               paste0(RANGE_START, "..", RANGE_END))
commit_timeline <- as.data.frame(table(month = months), stringsAsFactors = FALSE)
names(commit_timeline) <- c("month", "commit_count")
write.csv(commit_timeline, file.path(out_dir, "commit-activity-timeline.csv"), row.names = FALSE)

# ---- T6: engineering-process metrics ----------------------------------------

changelog <- readLines("CHANGELOG.md", warn = FALSE)
changelog_dates <- regmatches(changelog, regexpr("^### [0-9]{4}-[0-9]{2}-[0-9]{2}", changelog))
changelog_dates <- sub("^### ", "", changelog_dates)

learnings <- readLines("PROJECT_LEARNINGS.md", warn = FALSE)
n_learnings <- sum(grepl("^#### Learning [0-9]+ ", learnings))

handoffs <- readLines("HANDOFFS.md", warn = FALSE)
sessions_hd <- regmatches(handoffs, regexpr("^session: S[0-9]+", handoffs))
statuses_hd <- regmatches(handoffs, regexpr("^status: (complete|pending|reconciled)", handoffs))
n_receipts_complete <- sum(grepl("complete", statuses_hd))

session_notes <- readLines("SESSION_NOTES.md", warn = FALSE)
corr_zero <- sum(grepl("0 stakeholder correction", session_notes))
corr_nonzero <- sum(grepl("[1-9][0-9]* stakeholder correction", session_notes))

process_metrics <- data.frame(
  metric = c(
    "sessions_in_range (Session 1 - S328)",
    "pre_session1_commits_in_range",
    "session1_to_range_end_commits",
    "total_commits_in_range",
    "changelog_entries_total (all, entire ledger falls in-range)",
    "project_learnings_total",
    "handoffs_receipts_complete",
    "stakeholder_correction_zero_mentions",
    "stakeholder_correction_nonzero_mentions"
  ),
  value = c(328, 10, 502, 512, length(changelog_dates), n_learnings,
            n_receipts_complete, corr_zero, corr_nonzero),
  stringsAsFactors = FALSE
)
write.csv(process_metrics, file.path(out_dir, "process-metrics.csv"), row.names = FALSE)

# ---- F5 (optional/partial): self-score trend from HANDOFFS.md --------------
# CAUTION: HANDOFFS.md receipts started at S324 ("freeze legacy, go forward",
# S325) -- this covers only a late tail of the 328-session range, not the full span.
# State that limitation in the article caption; do not imply full-range coverage.

hd_session <- NA_character_
rows <- list()
for (line in handoffs) {
  if (grepl("^session: S[0-9]+$", line)) hd_session <- sub("^session: ", "", line)
  if (grepl("^date: [0-9]{4}-[0-9]{2}-[0-9]{2}$", line) && !is.na(hd_session)) {
    hd_date <- sub("^date: ", "", line)
  }
  if (grepl("^self_score: [0-9]+$", line) && !is.na(hd_session)) {
    rows[[length(rows) + 1]] <- data.frame(
      session = hd_session, date = hd_date,
      self_score = as.integer(sub("^self_score: ", "", line)),
      stringsAsFactors = FALSE
    )
    hd_session <- NA_character_
  }
}
self_score_trend <- do.call(rbind, rows)
self_score_trend <- self_score_trend[order(self_score_trend$date), ]
write.csv(self_score_trend, file.path(out_dir, "self-score-trend.csv"), row.names = FALSE)

message("Wrote ", length(list.files(out_dir)), " frozen data files to ", out_dir)
