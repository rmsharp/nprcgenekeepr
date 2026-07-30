// Fix for shinyBS 0.65.0's popover/tooltip destroy defect (GitHub issue #140).
//
// shinyBS.addTooltip() (shinyBS.js) unconditionally calls
// $id.popover("destroy") / $id.tooltip("destroy") before initializing a new
// instance. Bootstrap 4 renamed the "destroy" method to "dispose"; its
// _jQueryInterface no longer recognizes "destroy" as a no-op and throws
// instead, so the popover/tooltip is never created. This app pins Bootstrap
// 4.6.0 (R/appUI.R, bslib::bs_theme(version = 4L, ...)), so every
// shinyBS::popify()/addPopover() call in R/modSummaryStats.R is affected.
//
// Fix: override the mutable global shinyBS.addTooltip property with a
// corrected version that only calls destroy when an existing plugin
// instance is actually attached. Both call paths shinyBS exposes --
// popify()'s direct inline-script call and addPopover()'s Shiny
// custom-message handler -- read shinyBS.addTooltip at call time, so
// patching this one property fixes both.
(function () {
  "use strict";

  var MAX_ATTEMPTS = 40; // ~20s at 500ms; generous vs. popify()'s own 500ms delay
  var attempts = 0;

  function patchAddTooltip() {
    attempts += 1;

    if (window.shinyBS && typeof shinyBS.addTooltip === "function") {
      shinyBS.addTooltip = function (id, type, opts) {
        var $id = $("#" + id);

        if (type === "tooltip") {
          if ($id.data("bs.tooltip")) {
            $id.tooltip("destroy");
          }
          $id.tooltip(opts);
        } else if (type === "popover") {
          if ($id.data("bs.popover")) {
            $id.popover("destroy");
          }
          $id.popover(opts);
        }
      };
      return;
    }

    // shinyBS hasn't defined shinyBS.addTooltip yet (or isn't installed) --
    // keep polling up to MAX_ATTEMPTS, then give up silently.
    if (attempts < MAX_ATTEMPTS) {
      setTimeout(patchAddTooltip, 500);
    }
  }

  patchAddTooltip();
})();
