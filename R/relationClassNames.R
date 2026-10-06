## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Relationship class names
#'
#' Single source of truth for the 11 relationship names that
#' \code{\link{convertRelationships}} gives each pair of animals and that
#' \code{\link{makeRelationClassesTable}} counts. The names are in the order
#' the table lists its rows. Internal helper constant -- both functions read
#' their names from here instead of typing them, so a name cannot change in
#' one place and silently drop pairs from the table.
#' @noRd
relationClassNames <- c(
  self = "Self",
  parentOffspring = "Parent-Offspring",
  fullSiblings = "Full-Siblings",
  halfSiblings = "Half-Siblings",
  grandparentGrandchild = "Grandparent-Grandchild",
  fullCousins = "Full-Cousins",
  cousinOther = "Cousin - Other",
  fullAvuncular = "Full-Avuncular",
  avuncularOther = "Avuncular - Other",
  other = "Other",
  noRelation = "No Relation"
)
