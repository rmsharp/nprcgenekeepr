## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Standard sex-code values
#'
#' Single source of truth for the four standardized sex-code string values
#' used throughout the package (see \code{\link{convertSexCodes}}, which
#' produces them from raw input). Internal helper constant -- comparisons
#' against \code{ped$sex}/\code{ageDist$sex} elsewhere in the package
#' reference these named elements instead of repeating the bare string
#' literals.
#' @noRd
sexCodes <- c(male = "M", female = "F", hermaphrodite = "H", unknown = "U")
