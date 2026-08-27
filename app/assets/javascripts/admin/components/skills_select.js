// Checkbox dropdown for picking an experience's skills. Selected skills are
// mirrored as removable chips below the dropdown so the current selection is
// visible without opening it. Unchecking a box (directly or via a chip's
// remove button) is what drops that skill on save — the controller already
// permits skill_ids: [] and Rails' collection setter removes ids left out.
document.addEventListener('DOMContentLoaded', function(){
  document.querySelectorAll('[data-skills-select]').forEach(function(root){
    const summary = root.querySelector('[data-skills-summary]')
    const chips = root.querySelector('[data-skills-chips]')
    const checkboxes = Array.from(root.querySelectorAll('.skills-select-option input[type="checkbox"]'))

    function render(){
      const checked = checkboxes.filter(function(cb){ return cb.checked })

      summary.textContent = checked.length ? checked.length + ' skill' + (checked.length === 1 ? '' : 's') + ' selected' : 'Select skills'

      chips.innerHTML = ''
      checked.forEach(function(cb){
        const label = cb.closest('.skills-select-option').textContent.trim()

        const chip = document.createElement('span')
        chip.className = 'skills-select-chip'
        chip.textContent = label

        const remove = document.createElement('button')
        remove.type = 'button'
        remove.className = 'skills-select-chip-remove'
        remove.setAttribute('aria-label', 'Remove ' + label)
        remove.textContent = '×'
        remove.addEventListener('click', function(){
          cb.checked = false
          render()
        })

        chip.appendChild(remove)
        chips.appendChild(chip)
      })
    }

    checkboxes.forEach(function(cb){
      cb.addEventListener('change', render)
    })

    render()
  })
})
