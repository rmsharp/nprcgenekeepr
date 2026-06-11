// Data-ready state management for E2E testing
// This file provides JavaScript handlers for tracking async operation completion

$(document).ready(function() {
  // Initialize data-ready tracking
  window.nprcgenekeeprReady = window.nprcgenekeeprReady || {};

  // Handler for setting data-ready state from Shiny
  Shiny.addCustomMessageHandler('setDataReady', function(message) {
    var selector = message.selector;
    var ready = message.ready;
    var element = $(selector);

    if (element.length) {
      element.attr('data-ready', ready ? 'true' : 'false');
      // Also set a timestamp for debugging
      element.attr('data-ready-timestamp', new Date().toISOString());
    }

    // Track in global state
    window.nprcgenekeeprReady[selector] = ready;

    // Dispatch custom event for test frameworks
    var event = new CustomEvent('nprcgenekeepr:dataReady', {
      detail: { selector: selector, ready: ready }
    });
    document.dispatchEvent(event);
  });

  // Handler for setting loading state
  Shiny.addCustomMessageHandler('setDataLoading', function(message) {
    var selector = message.selector;
    var loading = message.loading;
    var element = $(selector);

    if (element.length) {
      element.attr('data-loading', loading ? 'true' : 'false');
      if (loading) {
        element.attr('data-ready', 'false');
      }
    }
  });

  // Helper function to check if a component is ready (for console debugging)
  window.isComponentReady = function(selector) {
    var element = $(selector);
    return element.length && element.attr('data-ready') === 'true';
  };

  // Helper to wait for component ready (returns a Promise)
  window.waitForReady = function(selector, timeout) {
    timeout = timeout || 30000;
    return new Promise(function(resolve, reject) {
      var startTime = Date.now();

      function check() {
        if (window.isComponentReady(selector)) {
          resolve(true);
        } else if (Date.now() - startTime > timeout) {
          reject(new Error('Timeout waiting for ' + selector + ' to be ready'));
        } else {
          setTimeout(check, 100);
        }
      }

      check();
    });
  };
});
