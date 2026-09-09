// Keeps a range slider's linked <output> in sync as the user drags it.
// Any input[type=range][data-range-output] wires itself up automatically —
// the attribute's value is the id of the <output> element to update.
function initRangeSliders() {
  var sliders = document.querySelectorAll('input[type="range"][data-range-output]')

  sliders.forEach(function(slider) {
    var output = document.getElementById(slider.dataset.rangeOutput)
    if (!output) return

    slider.addEventListener('input', function() {
      output.textContent = slider.value + '%'
    })
  })
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initRangeSliders)
} else {
  initRangeSliders()
}
