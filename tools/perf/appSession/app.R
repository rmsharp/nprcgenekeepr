## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## The app the scripted session drives (tools/perf/appSession.R): the
## package loaded from the source tree named in NPRC_PERF_PKG, so it measures
## the working tree with no install, and every kinship() and
## convertRelationships() call written to the file named in
## NPRC_PERF_KINSHIP_LOG with its size and the module functions that asked
## (design docs/planning/app-kinship-memory-design.md Appendix A).

suppressMessages(pkgload::load_all(Sys.getenv("NPRC_PERF_PKG"), quiet = TRUE))
perfKinshipLog <- Sys.getenv("NPRC_PERF_KINSHIP_LOG")

## The module and analysis functions on the call stack, outermost first.
perfCallerHeads <- function() {
  heads <- vapply(sys.calls(), function(call) {
    head <- call[[1L]]
    if (is.symbol(head)) as.character(head) else ""
  }, "")
  keep <- grepl(paste0("^(mod|get|diversity|realized|comparison|relationship|",
                       "report|group|shared|markerR|kinshipFor)"), heads)
  paste(unique(heads[keep]), collapse = " > ")
}

## Tracing these calls is this app's purpose, not a debugging leftover.
trace("kinship", where = asNamespace("nprcgenekeepr"), print = FALSE, # nolint: undesirable_function_linter
      tracer = bquote({
        cat(format(Sys.time(), "%H:%M:%OS3"), "kinship n =", length(id), "|",
            .(perfCallerHeads)(), "\n", file = .(perfKinshipLog),
            append = TRUE)
      }))
trace("convertRelationships", where = asNamespace("nprcgenekeepr"), # nolint: undesirable_function_linter
      print = FALSE, tracer = bquote({
        cat(format(Sys.time(), "%H:%M:%OS3"), "convertRelationships n =",
            nrow(kmat), "|", .(perfCallerHeads)(), "\n",
            file = .(perfKinshipLog), append = TRUE)
      }))

shiny::shinyApp(ui = appUI(), server = appServer)
