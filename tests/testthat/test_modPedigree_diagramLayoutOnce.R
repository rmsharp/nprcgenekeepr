# Tests for S1074 (BACKLOG "Pedigree Diagram: the first drawing computes the
# layout twice"). The Diagram tab's edge-style radio buttons and its Show Names
# and Show Twin Connectors check boxes are drawn by the same renderUI() that
# first builds the layout, so all three inputs are NULL during that build.
# When the browser binds them, each reports the value it shows ("rectilinear"
# or the style already chosen, FALSE, FALSE). Measured in the app (S1074,
# reactive log): that report invalidated diagramLayout() and the layout was
# built again with the same settings, 3.9 s of the 708-animal example's Direct
# drawing. testServer() never sends those reports itself (see the note after
# the useLabels test in test_modPedigree.R), so each test below sends them
# with session$setInputs(), as the browser does.

diagramTrio <- function() {
  data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    stringsAsFactors = FALSE
  )
}

# The values the three controls show when they are first drawn, which the
# browser reports when it binds them.
shownControlValues <- function(style = "rectilinear") {
  list(
    pedigreeEdgeStyle = style,
    pedigreeShowNames = FALSE,
    pedigreeShowTwinConnectors = FALSE
  )
}

# Counts makePedigreeMatingLayout() calls for the rest of the calling test;
# the returned function gives the count so far.
countLayoutBuilds <- function(env = parent.frame()) {
  builds <- 0L
  real <- get("makePedigreeMatingLayout", envir = asNamespace("nprcgenekeepr"))
  local_mocked_bindings(
    makePedigreeMatingLayout = function(...) {
      builds <<- builds + 1L
      real(...)
    },
    .package = "nprcgenekeepr", .env = env
  )
  function() builds
}

test_that(
  "the Diagram tab's first drawing builds its layout once when its three
   controls report the values they show", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  builds <- countLayoutBuilds()
  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ diagramTrio() })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE)
      drawn <- output$pedigreeDiagram
      expect_identical(builds(), 1L)

      do.call(session$setInputs, shownControlValues())
      expect_identical(output$pedigreeDiagram, drawn)
      expect_identical(builds(), 1L)
    }
  )
})

test_that(
  "any one of the Diagram tab's three controls reporting the value it shows
   builds no second layout", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  builds <- countLayoutBuilds()
  reports <- shownControlValues()
  for (control in names(reports)) {
    shiny::testServer(
      modPedigreeServer,
      args = list(studbook = shiny::reactive({ diagramTrio() })),
      {
        session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE)
        invisible(output$pedigreeDiagram)
        before <- builds()

        do.call(session$setInputs, reports[control])
        invisible(output$pedigreeDiagram)
        expect_identical(builds() - before, 0L, info = control)
      }
    )
  }
})

test_that(
  "with Direct chosen before the diagram is drawn (the S1073 path past the
   400-animal Rectilinear limit), the first drawing builds its layout once", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  builds <- countLayoutBuilds()
  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ diagramTrio() })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE,
                        pedigreeEdgeStyle = "direct")
      drawn <- output$pedigreeDiagram
      expect_identical(builds(), 1L)

      do.call(session$setInputs, shownControlValues("direct"))
      expect_identical(output$pedigreeDiagram, drawn)
      expect_identical(builds(), 1L)
    }
  )
})

# Each change on the tab after the first drawing, in this order.
diagramChanges <- function() {
  list(
    list(pedigreeShowNames = TRUE),
    list(pedigreeEdgeStyle = "direct"),
    list(pedigreeShowNames = FALSE),
    list(pedigreeShowTwinConnectors = TRUE),
    list(pedigreeEdgeStyle = "rectilinear")
  )
}

# A guard, not a new behavior: it passes before and after S1074. It pins that
# each real change on the tab still builds the layout exactly once.
test_that(
  "after the first drawing, each change on the Diagram tab builds its layout
   exactly once more", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  builds <- countLayoutBuilds()
  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ diagramTrio() })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE)
      invisible(output$pedigreeDiagram)
      do.call(session$setInputs, shownControlValues())
      invisible(output$pedigreeDiagram)

      for (change in diagramChanges()) {
        before <- builds()
        do.call(session$setInputs, change)
        invisible(output$pedigreeDiagram)
        expect_identical(builds() - before, 1L,
                         info = paste(names(change), "=", change[[1L]]))
      }
    }
  )
})

# The session's input store passes on a value identical to the one it holds
# (shiny's ReactiveValues with dedupe = FALSE, in testServer() and in a real
# session alike); a browser does not send such a value again (S1074: no
# second build when the tab redrew its controls after a style change). This
# pins that the diagram ignores one if it comes.
test_that(
  "after each change, the three controls reporting the values they already
   show builds no second layout", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  builds <- countLayoutBuilds()
  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ diagramTrio() })),
    {
      shown <- shownControlValues()
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE)
      invisible(output$pedigreeDiagram)
      do.call(session$setInputs, shown)
      invisible(output$pedigreeDiagram)

      for (change in diagramChanges()) {
        do.call(session$setInputs, change)
        invisible(output$pedigreeDiagram)
        shown[names(change)] <- change
        before <- builds()

        do.call(session$setInputs, shown)
        invisible(output$pedigreeDiagram)
        expect_identical(builds() - before, 0L,
                         info = paste("after", names(change), "=",
                                      change[[1L]]))
      }
    }
  )
})

# A mutation pin (S1074): with the held settings' observers at the default
# priority, a change to the pedigree view arriving in the same update as a
# setting change, the view change first, built the layout twice: the outputs
# ran before the held value was updated and again after it. Priority 1 updates
# the held value first.
test_that(
  "a change to the pedigree view and a setting change arriving together build
   the layout once", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  builds <- countLayoutBuilds()
  together <- list(
    list(displayUnknownIds = FALSE, pedigreeShowNames = TRUE),
    list(pedigreeShowNames = TRUE, displayUnknownIds = FALSE),
    list(trimPedigree = TRUE, pedigreeEdgeStyle = "direct")
  )
  for (inputs in together) {
    shiny::testServer(
      modPedigreeServer,
      args = list(studbook = shiny::reactive({ diagramTrio() })),
      {
        session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE)
        invisible(output$pedigreeDiagram)
        do.call(session$setInputs, shownControlValues())
        invisible(output$pedigreeDiagram)
        before <- builds()

        do.call(session$setInputs, inputs)
        invisible(output$pedigreeDiagram)
        expect_identical(builds() - before, 1L,
                         info = paste(names(inputs), collapse = " + "))
      }
    )
  }
})
