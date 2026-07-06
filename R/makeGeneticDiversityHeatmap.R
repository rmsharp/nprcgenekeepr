## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Make a genetic diversity heat map
#'
#' Renders a red/yellow/green stoplight heat map of breeding-group genetic
#' diversity metrics. Each row is a breeding group and each column is a
#' metric; every cell is colored by its color index, where 1 is red (the
#' problem condition), 2 is yellow (watch), and 3 is green (healthy).
#'
#' This function is agnostic to the number of metric columns: it draws one
#' tile per group-by-metric cell for whatever metric columns it is handed,
#' preserving their input order across the top of the plot.
#'
#' @param stats A data frame with one row per breeding group. The first
#'   column holds the group label; every remaining column is a metric whose
#'   values are color indices in \code{c(1, 2, 3)}.
#' @return A \code{ggplot} object: a \code{\link[ggplot2]{geom_tile}} heat
#'   map with metric headers across the top and group labels down the left,
#'   filled red/yellow/green from the color indices.
#' @examples
#' stats <- data.frame(
#'   group = c("Group_1", "Group_2"),
#'   Value = c(1, 3), Origin = c(2, 3),
#'   Production = c(3, 2), Inbreeding = c(1, 2)
#' )
#' p <- makeGeneticDiversityHeatmap(stats)
#'
#' @importFrom ggplot2 ggplot aes geom_tile scale_fill_manual
#' @importFrom ggplot2 scale_x_discrete labs theme_minimal theme
#' @importFrom ggplot2 element_text .data
#' @export
makeGeneticDiversityHeatmap <- function(stats) {
  if (!is.data.frame(stats)) {
    stop("makeGeneticDiversityHeatmap() requires 'stats' to be a data frame.")
  }
  if (ncol(stats) < 2L) {
    stop("makeGeneticDiversityHeatmap() requires 'stats' to have a group ",
         "label column plus at least one metric column.")
  }
  groups <- as.character(stats[[1L]])
  metricNames <- names(stats)[-1L]
  metricValues <- unlist(stats[metricNames], use.names = FALSE)
  if (!all(metricValues %in% c(1L, 2L, 3L))) {
    stop("makeGeneticDiversityHeatmap() requires every metric colorIndex ",
         "to be 1, 2, or 3.")
  }
  long <- data.frame(
    group = factor(rep(groups, times = length(metricNames)),
                   levels = rev(unique(groups))),
    metric = factor(rep(metricNames, each = nrow(stats)),
                    levels = metricNames),
    colorIndex = factor(metricValues, levels = c("1", "2", "3")),
    stringsAsFactors = FALSE
  )
  ggplot2::ggplot(
    long,
    ggplot2::aes(x = .data$metric, y = .data$group, fill = .data$colorIndex)
  ) +
    ggplot2::geom_tile(color = "white") +
    ggplot2::scale_fill_manual(
      values = c("1" = "red", "2" = "yellow", "3" = "green"),
      drop = FALSE, guide = "none"
    ) +
    ggplot2::scale_x_discrete(position = "top") +
    ggplot2::labs(x = NULL, y = NULL) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45L, hjust = 0L)
    )
}
