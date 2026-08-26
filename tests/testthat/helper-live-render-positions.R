# Helper for the Walker/BJL pedigree-diagram redesign's live-render
# verification (Phase 2, docs/planning/pedigree-diagram-walker-bjl-
# apportioning-redesign-plan.md -- "New deliverable this round, fixing C2-4").

#' Render a nodes/edges pair via the app's own visNetwork() call and read
#' back live, ground-truth rendered positions via chromote
#'
#' Renders \code{nodes}/\code{edges} through the SAME core \code{visNetwork()}
#' call the app itself makes (\code{R/modPedigree.R:611-614} -- fixed x/y,
#' physics off), saves it to a self-contained temporary HTML file, drives a
#' headless \code{chromote} session against it, and calls the underlying
#' vis.js \code{Network}'s own live \code{getPositions()} method -- the
#' widget's actual DOM-rendered ground truth, not a prediction from the R-side
#' \code{x}/\code{y} values alone. vis.js exposes its \code{Network} instance
#' as \code{document.getElementById("graph" + widgetDivId).chart} (confirmed
#' directly against the installed \code{visNetwork.js} source this session,
#' not assumed); \code{widgetDivId} is located dynamically via
#' \code{document.querySelector(".visNetwork")} rather than relying on
#' \code{elementId} (which \code{visNetwork()} does not reliably honor,
#' confirmed live this session -- an explicitly-set \code{elementId} did not
#' appear anywhere in the saved widget's HTML).
#'
#' This is the reusable, checked-in version of the methodology this project
#' has used bespoke and uncommitted at least twice before
#' (\code{test_makePedigreeMatingLayout.R:124}'s own comment;
#' \code{docs/planning/pedigree-diagram-single-child-union-parent-coincidence-
#' investigation.md} sec2.2's own narrated \code{getPositions()} measurement),
#' and mirrors \code{data-raw/kinship2FidelityValidation.R}'s own
#' \code{screenshot_layout()} helper (same widget construction, same
#' self-contained-HTML-plus-chromote technique) but reads back live positions
#' instead of taking a screenshot.
#'
#' Requires \code{chromote} and \code{htmlwidgets} installed locally --
#' declared direct \code{Suggests} dependencies (added this session): unlike
#' \code{data-raw/kinship2FidelityValidation.R} (a build-ignored dev script,
#' outside \code{R CMD check}'s surface, where they stay merely transitive --
#' via \code{shinytest2} and \code{visNetwork} respectively), this helper
#' lives in \code{tests/testthat/} and is checked, so R CMD check's own
#' "unstated dependencies in tests" gate requires them declared. Callers are
#' responsible for their own \code{skip_if_not_installed()}/
#' \code{skip_on_cran()} guards (this helper does not guard itself, matching
#' \code{helper-shinytest2.R}'s own convention of leaving skip logic to the
#' calling test).
#'
#' @param nodes data.frame with at least \code{id}, \code{x}, \code{y}
#'   columns (any other visNetwork node column -- shape/size/color/label --
#'   is passed through unchanged).
#' @param edges data.frame with at least \code{from}, \code{to} columns.
#' @param width,height Pixel viewport size for the rendered widget.
#' @param waitSeconds Seconds to wait after the page load event fires before
#'   reading positions back, giving vis.js time to fully instantiate the
#'   Network for larger graphs.
#' @param loadTimeout Seconds to wait for the page's own \code{load} event
#'   (chromote's \code{Page$loadEventFired(timeout_ = loadTimeout)}) --
#'   chromote's own 10-second default is too short for a several-hundred-node
#'   self-contained HTML (confirmed live this session against the real
#'   375-individual/714-node fixture).
#' @return A data.frame(id, x, y) of the LIVE rendered positions, one row per
#'   node vis.js actually placed -- a silently-collapsed duplicate id in
#'   vis.js's own DataSet would surface here as fewer rows than
#'   \code{nrow(nodes)}, not as an error.
## Tracks whether the session-wide teardown close of chromote's shared
## default_chromote_object() has already been registered, so it registers
## exactly once even though getLiveRenderedPositions() may be called
## multiple times across the test suite (found/fixed S638 -- BACKLOG.md /
## PROJECT_LEARNINGS.md: the shared Chrome browser process was previously
## only ever hard-killed by processx's supervise = TRUE parent-exit
## mechanism when the test R session ended, never gracefully $close()-d,
## so Chromium's own ProcessSingleton cleanup -- which removes its
## SingletonCookie/SingletonSocket lock files, named
## org.chromium.Chromium.<random> on the unbranded Chrome-for-Testing
## build CI uses -- never ran, leaving that directory behind as the
## "checking for detritus in the temp directory" NOTE R CMD check flagged
## on all 3 ubuntu-latest legs).
.chromoteParentTeardownRegistered <- new.env(parent = emptyenv())
.chromoteParentTeardownRegistered$done <- FALSE

getLiveRenderedPositions <- function(nodes, edges, width = 1200L,
                                      height = 900L, waitSeconds = 1.5,
                                      loadTimeout = 30) {
  widget <- visNetwork::visNetwork(nodes, edges, width = width,
      height = height) |>
    visNetwork::visPhysics(enabled = FALSE) |>
    visNetwork::visNodes(physics = FALSE) |>
    visNetwork::visEdges(smooth = FALSE)

  tmpHtml <- tempfile(fileext = ".html")
  htmlwidgets::saveWidget(widget, tmpHtml, selfcontained = TRUE)
  on.exit(unlink(tmpHtml), add = TRUE)

  ## Raise chromote's default per-command timeout BEFORE creating the first
  ## session. chromote::ChromoteSession$new() unconditionally issues an
  ## internal Runtime.evaluate command during its own bootstrap
  ## (private$get_pixel_ratio(), chromote's own R/chromote_session.R --
  ## confirmed by direct source inspection, chromote 0.5.1) to read
  ## window.devicePixelRatio for Emulation$setDeviceMetricsOverride -- not a
  ## call this helper makes itself. That probe is governed by
  ## default_timeout (10s default), a mutable field on the parent Chromote
  ## singleton (chromote::default_chromote_object(), reused by every
  ## ChromoteSession$new() call in this file, since none pass a `parent`
  ## arg) with no constructor argument to raise it. Confirmed insufficient
  ## for the FIRST chromote-driven Chrome launch of a macOS GitHub Actions
  ## R-CMD-check run: macos-latest is GitHub's most resource-constrained
  ## hosted-runner class (3 vCPU/7GB vs. 4 vCPU/16GB on Linux), and a
  ## freshly-provisioned, never-before-executed Chrome-for-Testing binary
  ## pays a first-launch cost on top of that -- failed 3/3 real CI pushes as
  ## "Chromote: timed out waiting for response to command Runtime.evaluate"
  ## inside ChromoteSession$new() itself, always on macos-latest, never on
  ## ubuntu-latest/windows-latest with the identical pinned binary (found
  ## S618, diagnosed S619, 2026-08-20 -- see BACKLOG.md's chromote item for
  ## the full ranked-hypothesis diagnosis).
  chromeParent <- chromote::default_chromote_object()
  if (chromeParent$default_timeout < 60) {
    chromeParent$default_timeout <- 60
  }
  ## Register a ONE-TIME, session-teardown-scoped graceful close of the
  ## shared parent so its Chrome process is properly shut down (and its
  ## temp-dir process-singleton lock files cleaned up by Chromium itself)
  ## once, after the whole test suite finishes -- rather than hard-killed
  ## at R exit. No change to Chrome-launch count/timing: still one shared
  ## launch, reused across every call (see the macos-latest first-launch
  ## timeout sensitivity documented above).
  if (!isTRUE(.chromoteParentTeardownRegistered$done)) {
    withr::defer(chromeParent$close(), envir = testthat::teardown_env())
    .chromoteParentTeardownRegistered$done <- TRUE
  }
  b <- chromote::ChromoteSession$new()
  on.exit(b$close(), add = TRUE)
  ## chromote's own default timeout_ (10s, ChromoteSession$default_timeout)
  ## is too short for a several-hundred-node self-contained HTML in this
  ## environment (confirmed live this session: the real 375-individual
  ## fixture's 714-node/725-edge render intermittently exceeded it, throwing
  ## "timed out waiting for event Page.loadEventFired") -- explicit,
  ## caller-tunable loadTimeout replaces the default for this one call.
  ##
  ## Uses $go_to() rather than the separate Page$navigate()+
  ## Page$loadEventFired() calls it replaces: that 2-call sequence is a
  ## documented chromote race (rstudio/chromote#102 and the package's own
  ## "Loading a page reliably" vignette) -- the page can finish loading and
  ## fire its load event BEFORE Page$loadEventFired() registers a listener
  ## for it, so the second call then waits the full timeout_ for an event
  ## that already happened and will never fire again. $go_to() registers the
  ## listener before navigating, eliminating the race. This was invisible in
  ## local/macOS/Linux CI testing (found S616, 2026-08-20) -- Windows CI's
  ## R-CMD-check run hit it consistently (windows-latest only, both chromote
  ## tests in test_positionMatingUnitForestBJL.R), a slower/busier runner
  ## being exactly what tips a race condition from "usually wins" to "loses."
  ## $go_to()'s own `delay` parameter (seconds after the load event fires)
  ## replaces the separate Sys.sleep(waitSeconds) call this used to make.
  b$go_to(paste0("file://", tmpHtml), timeout_ = loadTimeout,
          delay = waitSeconds)

  js <- paste0(
    "(() => { ",
    "const w = document.querySelector('.visNetwork'); ",
    "const g = document.getElementById('graph' + w.id); ",
    "return g.chart.getPositions(); })()"
  )
  raw <- b$Runtime$evaluate(js, returnByValue = TRUE)$result$value

  if (length(raw) == 0L) {
    return(data.frame(id = character(0L), x = numeric(0L), y = numeric(0L),
                       stringsAsFactors = FALSE))
  }
  data.frame(
    id = names(raw),
    x = vapply(raw, function(p) as.numeric(p$x), numeric(1L)),
    y = vapply(raw, function(p) as.numeric(p$y), numeric(1L)),
    stringsAsFactors = FALSE
  )
}
