# Tests for issue #137 Slice 3: a twin/zygosity relations sidecar file
# uploaded on the Pedigree Browser's Diagram tab, gated by a "Show Twin
# Connectors" toggle. Mirrors test_modGeneticValue_kinshipOverrides.R's
# fileInfo()/testServer() pattern for the sibling kinship-overrides
# upload feature -- the closest existing precedent for "a validated,
# non-fatal-on-error file upload threaded into a render/report call."

twinPed <- function() {
  data.frame(
    id = c("F1", "F2", "S1", "S2", "S3"),
    sire = c(NA, NA, "F1", "F1", "F1"),
    dam = c(NA, NA, "F2", "F2", "F2"),
    sex = c("M", "F", "F", "F", "M"),
    stringsAsFactors = FALSE
  )
}

# Build the data.frame shiny's fileInput hands the server for an uploaded
# file (mirrors test_modGeneticValue_kinshipOverrides.R's own fileInfo()).
fileInfo <- function(path) {
  data.frame(
    name = basename(path), size = 1L, type = "text/csv",
    datapath = path, stringsAsFactors = FALSE
  )
}

# .buildTwinConnectorEdges() rows carry a non-NA label ("MZ"/"DZ"/"?");
# every other edge in the layout has label = NA. Isolates the new connector
# rows without depending on from/to id matching (Learning 493's own gotcha
# #2 -- id-based filters can incidentally catch pre-existing edges).
twinConnectorRows <- function(edges) {
  edges[!is.na(edges$label) & edges$label %in% c("MZ", "DZ", "?"), ]
}

test_that(
  "modPedigreeServer's diagramLayout() carries no twin connector edges
   when no twinRelations file is uploaded, even with the toggle on", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ twinPed() })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE,
                         pedigreeShowTwinConnectors = TRUE)
      session$flushReact()
      layout <- diagramLayout()
      expect_identical(nrow(twinConnectorRows(layout$edges)), 0L)
    }
  )
})

test_that(
  "modPedigreeServer's diagramLayout() carries twin connector edges once a
   valid twinRelations file is uploaded AND the toggle is switched on", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(csv), add = TRUE)
  writeLines(c("id1,id2,code", "S1,S2,MZ twin"), csv)

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ twinPed() })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE,
                         twinRelationsFile = fileInfo(csv),
                         pedigreeShowTwinConnectors = TRUE)
      session$flushReact()
      layout <- diagramLayout()
      rows <- twinConnectorRows(layout$edges)
      expect_identical(nrow(rows), 1L)
      expect_true(all(c("S1", "S2") %in% c(rows$from, rows$to)))
      expect_identical(rows$label, "MZ")
    }
  )
})

test_that(
  "modPedigreeServer's diagramLayout() carries no twin connector edges when
   a valid twinRelations file is uploaded but the toggle stays off (D4
   off-by-default parity with the existing show-names toggle -- the toggle
   gates whether the data even reaches the builder, not a post-hoc filter)",
  {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(csv), add = TRUE)
  writeLines(c("id1,id2,code", "S1,S2,MZ twin"), csv)

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ twinPed() })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE,
                         twinRelationsFile = fileInfo(csv),
                         pedigreeShowTwinConnectors = FALSE)
      session$flushReact()
      layout <- diagramLayout()
      expect_identical(nrow(twinConnectorRows(layout$edges)), 0L)
    }
  )
})

test_that(
  "modPedigreeServer ignores a malformed twinRelations file (non-fatal,
   mirrors the D5 kinship-overrides precedent -- a bad file warns/notifies
   and is ignored, the diagram is never aborted)", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(csv), add = TRUE)
  # S9 is not in the pedigree -- checkTwinRelations() stop()s; the module
  # must catch it and continue rendering (never abort the diagram).
  writeLines(c("id1,id2,code", "S1,S9,MZ twin"), csv)

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ twinPed() })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE,
                         twinRelationsFile = fileInfo(csv),
                         pedigreeShowTwinConnectors = TRUE)
      session$flushReact()
      layout <- diagramLayout()
      expect_identical(nrow(twinConnectorRows(layout$edges)), 0L)
      expect_true(nrow(layout$nodes) > 0L)
    }
  )
})

# ---------------------------------------------------------------------------
# BL-N Slice 3 (twinRelations-into-kinship() plan, docs/planning/
# twin-relations-kinship-computation-plan.md sec 4): modPedigreeServer()'s
# return list gains a twinRelations reactive so appServer can thread it
# app-wide (sec 2.7). Unlike diagramLayout()'s twinRelations (gated by the
# "Show Twin Connectors" toggle, D11), this return-list entry is the RAW,
# UNGATED twinRelationsData() reactive -- the toggle only ever controlled
# whether the diagram RENDERS connectors, never whether the underlying
# validated data exists (sec 2.7's own already-confirmed reading of the
# existing gate).
# ---------------------------------------------------------------------------

test_that(
  "modPedigreeServer's return list exposes a twinRelations reactive matching
   twinRelationsData(), independent of the Show Twin Connectors toggle
   (Slice 3)", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(csv), add = TRUE)
  writeLines(c("id1,id2,code", "S1,S2,MZ twin"), csv)

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ twinPed() })),
    {
      # Toggle deliberately left at its default (off) -- the return-list
      # entry must still carry the validated data (unlike diagramLayout()'s
      # own gated copy).
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE,
                         twinRelationsFile = fileInfo(csv))
      session$flushReact()
      result <- session$getReturned()
      twins <- result$twinRelations()
      expect_true(is.data.frame(twins))
      expect_identical(nrow(twins), 1L)
      expect_true(all(c("S1", "S2") %in% c(twins$id1, twins$id2)))
    }
  )
})

test_that(
  "modPedigreeServer's return-list twinRelations entry is NULL when no
   twinRelations file is uploaded (backward compatibility, Slice 3)", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ twinPed() })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE)
      session$flushReact()
      result <- session$getReturned()
      expect_null(result$twinRelations())
    }
  )
})
