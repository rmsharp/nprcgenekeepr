## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Plot colony genetic-health trends from a snapshot history
#'
#' Draws the longitudinal trend view of a colony snapshot history (issue
#' #167): one \code{ggplot} object faceted per metric (free y scales), with
#' \code{snapshotDate} on the x axis and one colored series per
#' \code{membershipRule}, so successive snapshots are compared like with
#' like. Sampling-uncertainty ribbons are drawn exactly where the schema
#' carries a standard error: \code{fg} (\code{fgSE}) and \code{meanGu}
#' (\code{meanGuSE}) — the Monte Carlo gene-drop uncertainty is surfaced,
#' never hidden.
#'
#' Snapshots whose provenance (\code{guIter}, \code{guThresh}, or
#' \code{packageVersion}) changed relative to the same rule's previous
#' snapshot are drawn with a distinct point shape, and the plot carries a
#' caption naming the changed fields: mixed-provenance series are flagged,
#' not refused.
#'
#' @param history data.frame holding the snapshot history in the 27-column
#' version-1 schema; validated internally with
#' \code{\link{checkSnapshotHistory}}. A trend needs at least two
#' snapshots.
#' @param metrics character vector naming the metric columns to facet. The
#' default \code{NULL} plots the 18 metric columns (the \code{reportGV()}
#' colony scalars and the Summary Statistics aggregates); the composition
#' counts (\code{nAnimals}, \code{nMales}, \code{nFemales}) may be
#' requested to make membership churn visible.
#' @return A \code{ggplot} object.
#' @export
#' @examples
#' history <- checkSnapshotHistory(readSnapshotHistory(system.file("extdata",
#'   "examples", "example_snapshot_history.csv",
#'   package = "nprcgenekeepr"
#' )))
#' p <- plotSnapshotTrends(history, metrics = c("fe", "fg", "meanGu"))
#'
#' @importFrom ggplot2 ggplot aes geom_line geom_point geom_ribbon
#' @importFrom ggplot2 facet_wrap labs scale_shape_manual theme_minimal
#' @importFrom ggplot2 .data
plotSnapshotTrends <- function(history, metrics = NULL) {
  history <- checkSnapshotHistory(history)
  if (nrow(history) < 2L) {
    stop("A trend needs at least 2 snapshots; the history has ",
      nrow(history), ".")
  }
  defaultMetrics <- c(
    "fe", "fg", "fgSE", "neGD", "neSexRatio", "neVariance",
    "nMaleFounders", "nFemaleFounders", "nFounders",
    "meanIndivMeanKin", "medianIndivMeanKin", "skewnessIndivMeanKin",
    "kurtosisIndivMeanKin", "meanGu", "medianGu", "meanGuSE",
    "skewnessGu", "kurtosisGu"
  )
  allowedMetrics <- c("nAnimals", "nMales", "nFemales", defaultMetrics)
  if (is.null(metrics)) {
    metrics <- defaultMetrics
  }
  if (length(metrics) == 0L) {
    stop("'metrics' must name at least one metric column.")
  }
  unknownMetrics <- setdiff(metrics, allowedMetrics)
  if (length(unknownMetrics) > 0L) {
    stop("Unknown metric(s): ", toString(unknownMetrics), "; allowed: ",
      toString(allowedMetrics), ".")
  }

  provenance <- snapshotProvenanceChanges(history)
  long <- do.call(rbind, lapply(metrics, function(metricName) {
    data.frame(
      snapshotDate = history$snapshotDate,
      membershipRule = history$membershipRule,
      metric = metricName,
      value = as.numeric(history[[metricName]]),
      provenanceChange = ifelse(provenance$changed, "changed", "stable"),
      stringsAsFactors = FALSE
    )
  }))
  long$metric <- factor(long$metric, levels = metrics)

  ## Lines only for rules with >= 2 snapshots: a one-point series is drawn
  ## as its point alone rather than warning on every facet build.
  ruleCounts <- table(history$membershipRule)
  multiPointRules <- names(ruleCounts)[ruleCounts >= 2L]
  lineData <- long[long$membershipRule %in% multiPointRules, , drop = FALSE]

  p <- ggplot2::ggplot(
    long,
    ggplot2::aes(
      x = .data$snapshotDate, y = .data$value,
      colour = .data$membershipRule, group = .data$membershipRule
    )
  )
  for (ribbonMetric in intersect(c("fg", "meanGu"), metrics)) {
    seColumn <- c(fg = "fgSE", meanGu = "meanGuSE")[[ribbonMetric]]
    ribbonData <- data.frame(
      snapshotDate = history$snapshotDate,
      membershipRule = history$membershipRule,
      metric = factor(ribbonMetric, levels = metrics),
      value = as.numeric(history[[ribbonMetric]]),
      ymin = as.numeric(history[[ribbonMetric]]) -
        as.numeric(history[[seColumn]]),
      ymax = as.numeric(history[[ribbonMetric]]) +
        as.numeric(history[[seColumn]]),
      stringsAsFactors = FALSE
    )
    p <- p + ggplot2::geom_ribbon(
      data = ribbonData,
      ggplot2::aes(ymin = .data$ymin, ymax = .data$ymax),
      fill = "grey70", alpha = 0.4, colour = NA, show.legend = FALSE
    )
  }
  p <- p +
    ggplot2::geom_line(data = lineData) +
    ggplot2::geom_point(ggplot2::aes(shape = .data$provenanceChange)) +
    ggplot2::scale_shape_manual(
      values = c(stable = 16L, changed = 17L), guide = "none"
    ) +
    ggplot2::facet_wrap(~metric, scales = "free_y") +
    ggplot2::labs(
      x = "Snapshot date", y = NULL, colour = "Membership rule"
    ) +
    ggplot2::theme_minimal()
  if (length(provenance$fields) > 0L) {
    p <- p + ggplot2::labs(caption = paste0(
      "Triangle points changed provenance (",
      toString(provenance$fields),
      ") relative to the previous same-rule snapshot."
    ))
  }
  p
}

#' Which snapshots changed provenance relative to their series predecessor
#'
#' Walks each membership-rule series in date order and marks every snapshot
#' whose \code{guIter}, \code{guThresh}, or \code{packageVersion} differs
#' from the same rule's previous snapshot (D4 flag-don't-refuse). The
#' first snapshot of a series has no predecessor and is never marked.
#'
#' @param history validated snapshot history.
#' @return list of \code{changed} (logical along \code{history} rows) and
#' \code{fields} (character; the provenance fields seen changing anywhere
#' in the history, for the plot caption).
#' @noRd
snapshotProvenanceChanges <- function(history) {
  changed <- logical(nrow(history))
  fields <- character(0L)
  for (rule in unique(history$membershipRule)) {
    seriesIdx <- which(history$membershipRule == rule)
    seriesIdx <- seriesIdx[order(history$snapshotDate[seriesIdx])]
    for (k in seq_along(seriesIdx)[-1L]) {
      previous <- history[seriesIdx[k - 1L], , drop = FALSE]
      current <- history[seriesIdx[k], , drop = FALSE]
      changedFields <- character(0L)
      if (current$guIter != previous$guIter) {
        changedFields <- c(changedFields, "guIter")
      }
      if (current$guThresh != previous$guThresh) {
        changedFields <- c(changedFields, "guThresh")
      }
      if (!identical(current$packageVersion, previous$packageVersion)) {
        changedFields <- c(changedFields, "packageVersion")
      }
      if (length(changedFields) > 0L) {
        changed[seriesIdx[k]] <- TRUE
        fields <- union(fields, changedFields)
      }
    }
  }
  list(changed = changed, fields = fields)
}
