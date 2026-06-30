## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get the auto-generated unknown-ID format
#'
#' Returns the \code{sprintf} template used to mint placeholder IDs for unknown
#' parents (see \code{\link{addUIds}}) and to detect them. The format is the
#' single source of truth shared by ID *generation* and ID *detection*.
#'
#' The value is read from \code{getOption("nprcgenekeepr.autoIdFormat")},
#' defaulting to \code{"U\%04d"} (a leading \code{"U"} plus a zero-padded
#' integer) for backward compatibility. Set it with
#' \code{\link{setAutoIdFormat}}.
#'
#' @return A single character string: the auto-ID \code{sprintf} format.
#' @seealso \code{\link{setAutoIdFormat}}, \code{\link{addUIds}}
#' @export
#' @examples
#' getAutoIdFormat()
getAutoIdFormat <- function() {
  getOption("nprcgenekeepr.autoIdFormat", "U%04d")
}

#' Set the auto-generated unknown-ID format
#'
#' Sets the \code{sprintf} template used to mint and detect placeholder IDs for
#' unknown parents (see \code{\link{addUIds}}). The format must have a non-empty
#' literal prefix before its first \code{"\%"} (used for detection) and must
#' consume a single integer (used for generation), e.g. \code{"U\%04d"} or
#' \code{"AUTO\%05d"}. The setting is stored in
#' \code{options(nprcgenekeepr.autoIdFormat=)} and read by
#' \code{\link{getAutoIdFormat}}.
#'
#' @param format A single character string: the auto-ID \code{sprintf} format.
#' @return The previous format, returned invisibly.
#' @seealso \code{\link{getAutoIdFormat}}, \code{\link{addUIds}}
#' @export
#' @examples
#' old <- setAutoIdFormat("AUTO%05d")
#' getAutoIdFormat()
#' setAutoIdFormat(old) # restore
setAutoIdFormat <- function(format) {
  if (!is.character(format) || length(format) != 1L || is.na(format)) {
    stop(
      "setAutoIdFormat(): 'format' must be a single non-NA character string.",
      call. = FALSE
    )
  }
  if (!nzchar(getAutoIdPrefix(format))) {
    stop(
      "setAutoIdFormat(): 'format' must have a non-empty literal prefix ",
      "before the first '%' (e.g. \"U%04d\"); got: ", format,
      call. = FALSE
    )
  }
  ok <- tryCatch(
    {
      a <- sprintf(format, 1L)
      b <- sprintf(format, 2L)
      is.character(a) && length(a) == 1L && !is.na(a) && !identical(a, b)
    },
    error = function(e) FALSE,
    warning = function(e) FALSE
  )
  if (!ok) {
    stop(
      "setAutoIdFormat(): 'format' must be an sprintf template that consumes ",
      "a single integer (e.g. \"U%04d\", \"AUTO%05d\"); got: ", format,
      call. = FALSE
    )
  }
  old <- getAutoIdFormat()
  # intentional permanent session setter (this IS the public setter); a scoped
  # withr::with_options() would defeat its purpose
  options(nprcgenekeepr.autoIdFormat = format) # nolint: undesirable_function_linter
  invisible(old)
}

#' Literal prefix of an auto-ID format
#'
#' Returns the literal portion of an auto-ID \code{sprintf} format before its
#' first \code{"\%"} conversion. For \code{"U\%04d"} this is \code{"U"}; for
#' \code{"AUTO\%05d"} it is \code{"AUTO"}. This prefix is what
#' \code{\link{isGeneratedUnknownId}} matches against.
#'
#' @param format auto-ID \code{sprintf} format; defaults to
#' \code{getAutoIdFormat()}.
#' @return The literal prefix, a single character string.
#' @noRd
getAutoIdPrefix <- function(format = getAutoIdFormat()) {
  sub("%.*$", "", format)
}

#' Is an ID an auto-generated unknown ID?
#'
#' The single detection predicate for placeholder IDs minted for unknown
#' parents (see \code{\link{addUIds}}). An ID is auto-generated when it begins
#' with the literal prefix of the configured format (see
#' \code{\link{getAutoIdFormat}}). Matching is case-sensitive (generation always
#' emits the prefix verbatim) and preserves \code{NA} like \code{startsWith()},
#' so it is a drop-in for the leading-prefix checks it replaces.
#'
#' @param id character vector of IDs to test.
#' @param format auto-ID \code{sprintf} format; defaults to
#' \code{getAutoIdFormat()}.
#' @return A logical vector the length of \code{id} (\code{NA} where \code{id}
#' is \code{NA}).
#' @noRd
isGeneratedUnknownId <- function(id, format = getAutoIdFormat()) {
  startsWith(as.character(id), getAutoIdPrefix(format))
}
