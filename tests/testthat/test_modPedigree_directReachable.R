# Tests for S1077 (BACKLOG "Pedigree Diagram: no way to choose "Direct" for a
# pedigree of 401 to 750 animals"). The Diagram tab draws at most 400 animals
# in its default "Rectilinear" style and 750 in "Direct", but its edge-style
# buttons were drawn only beside a diagram, never beside the over-limit
# message, so a fresh session could not reach the Direct diagram of 401 to
# 750 animals (S1073 measured it in the app on the 708-animal example trim).
# Owner ruling S1077 ("Buttons and wording"): from 401 to 750 animals the
# message keeps the style buttons above it and says Direct draws up to 750;
# above 750 neither style can draw the pedigree, so the message stays as it
# was, with no buttons.

# `n` animals: one trio (A0001 and A0002 the parents of A0003) and founders
# with no recorded relatives, so the diagram is not empty when it is drawn.
pedigreeOfSize <- function(n) {
  ids <- sprintf("A%04d", seq_len(n))
  sire <- rep(NA_character_, n)
  dam <- rep(NA_character_, n)
  sire[3L] <- ids[1L]
  dam[3L] <- ids[2L]
  data.frame(
    id = ids, sire = sire, dam = dam,
    sex = rep(c("M", "F"), length.out = n), stringsAsFactors = FALSE
  )
}

# Runs `code` in a modPedigreeServer session on pedigreeOfSize(n), with the
# whole pedigree in view and `style` chosen first when it is not NULL.
# `code` sees the session's `input`, `output` and `session`, as in
# shiny::testServer().
withDiagramTabOf <- function(n, code, style = NULL) {
  first <- c(list(displayUnknownIds = TRUE, trimPedigree = FALSE),
             if (!is.null(style)) list(pedigreeEdgeStyle = style))
  shiny::testServer(
    modPedigreeServer,
    {
      do.call(session$setInputs, first)
      {{ code }}
    },
    args = list(studbook = shiny::reactive({ pedigreeOfSize(n) }))
  )
}

# The text of the over-limit message (the warning box) in `html`, with runs
# of white space made single spaces; NA when there is no such box.
limitMessage <- function(html) {
  box <- regmatches(
    html,
    regexpr('(?s)<div class="alert alert-warning">.*?</div>', html,
            perl = TRUE)
  )
  if (length(box) == 0L) return(NA_character_)
  trimws(gsub("\\s+", " ", gsub("<[^>]+>", "", box)))
}

# The edge-style radio buttons in `html`: a named logical, one element per
# button in page order, named by its value, TRUE for the selected one.
styleButtons <- function(html) {
  tags <- regmatches(html, gregexpr("<input[^>]*>", html))[[1L]]
  tags <- tags[grepl('name="[^"]*-pedigreeEdgeStyle"', tags)]
  values <- sub('.*value="([^"]*)".*', "\\1", tags)
  stats::setNames(grepl("checked", tags, fixed = TRUE), values)
}

# The message the ruling asks for, for `n` animals between the two limits.
directOfferMessage <- function(n) {
  sprintf(
    paste(
      "Diagram not shown: %d animals exceeds the 400-animal limit of the",
      "Rectilinear style. Choose Direct above to draw up to 750 animals, or",
      "narrow the focal-animal selection."
    ),
    n
  )
}

# The message as it was before S1077, which stays above 750 animals.
plainLimitMessage <- function(n, cap) {
  sprintf(
    paste(
      "Diagram not shown: %d animals exceeds the %d-animal display limit.",
      "Narrow the focal-animal selection to view a diagram."
    ),
    n, cap
  )
}

for (n in c(401L, 750L)) {
  test_that(
    sprintf(
      "a pedigree of %d animals in Rectilinear: the message has the style
       buttons above it, Rectilinear selected, and names Direct", n
    ), {
    skip_if_not_installed("shiny")
    skip_if_not_installed("visNetwork")

    withDiagramTabOf(n, {
      html <- output$pedigreeDiagramUI$html
      expect_false(grepl("visNetwork", html, fixed = TRUE))
      expect_identical(styleButtons(html),
                       c(direct = FALSE, rectilinear = TRUE))
      expect_identical(limitMessage(html), directOfferMessage(n))
      ## "Choose Direct above": the buttons come first (regexpr() gives -1
      ## for a missing one, so both must be found).
      buttonsAt <- regexpr("-pedigreeEdgeStyle", html, fixed = TRUE)[[1L]]
      messageAt <- regexpr("Diagram not shown", html, fixed = TRUE)[[1L]]
      expect_true(buttonsAt > 0L && messageAt > buttonsAt)
    })
  })
}

test_that(
  "the message shows only the style buttons, not the Show Names or Show
   Twin Connectors boxes", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  ## A guard: the two boxes were never beside the message, and the ruling
  ## adds only the style buttons.
  withDiagramTabOf(401L, {
    html <- output$pedigreeDiagramUI$html
    expect_false(grepl("-pedigreeShowNames", html, fixed = TRUE))
    expect_false(grepl("-pedigreeShowTwinConnectors", html, fixed = TRUE))
  })
})

test_that(
  "choosing Direct from the message draws the diagram, and choosing
   Rectilinear again brings the message back with its buttons", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  ## 708 animals: the example as the app trims it (S1073).
  withDiagramTabOf(708L, {
    expect_identical(styleButtons(output$pedigreeDiagramUI$html),
                     c(direct = FALSE, rectilinear = TRUE))

    session$setInputs(pedigreeEdgeStyle = "direct")
    html <- output$pedigreeDiagramUI$html
    expect_true(grepl("visNetwork", html, fixed = TRUE))
    expect_true(is.na(limitMessage(html)))
    expect_identical(styleButtons(html),
                     c(direct = TRUE, rectilinear = FALSE))

    session$setInputs(pedigreeEdgeStyle = "rectilinear")
    html <- output$pedigreeDiagramUI$html
    expect_false(grepl("visNetwork", html, fixed = TRUE))
    expect_identical(limitMessage(html), directOfferMessage(708L))
    expect_identical(styleButtons(html),
                     c(direct = FALSE, rectilinear = TRUE))
  })
})

test_that(
  "above 750 animals the message is unchanged and has no style buttons, in
   either style", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")

  ## A guard: neither style can draw 751 animals, so the ruling leaves this
  ## message as it was.
  withDiagramTabOf(751L, {
    html <- output$pedigreeDiagramUI$html
    expect_identical(limitMessage(html), plainLimitMessage(751L, 400L))
    expect_length(styleButtons(html), 0L)
  })
  withDiagramTabOf(751L, style = "direct", {
    html <- output$pedigreeDiagramUI$html
    expect_identical(limitMessage(html), plainLimitMessage(751L, 750L))
    expect_length(styleButtons(html), 0L)
  })
})
