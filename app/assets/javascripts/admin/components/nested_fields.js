<<<<<<< HEAD
// Dynamic "add another" rows for nested fields_for sections (e.g. education milestones).
// Usage: a <button data-milestones-container="ID" data-milestone-template="TEMPLATE_ID">
// next to a <template id="TEMPLATE_ID"> containing one fields_for block rendered with
// child_index: 'NEW_MILESTONE_INDEX', and a container <div id="ID"> to append into.
document.addEventListener('DOMContentLoaded', function(){
  const addButton = document.getElementById('add-milestone')

  function wireRemoveButton(button){
    button.addEventListener('click', function(){
      const row = button.closest('[data-milestone-row]')
=======
// Dynamic "add another" rows for nested fields_for sections (e.g. education
// milestones, experience highlights).
// Usage: a <button class="add-fields-btn" data-fields-container="ID" data-fields-template="TEMPLATE_ID">
// next to a <template id="TEMPLATE_ID"> containing one fields_for block rendered with
// child_index: 'NEW_RECORD_INDEX', and a container <div id="ID"> to append into.
// Each row needs [data-fields-row] and a .remove-fields-btn.
document.addEventListener('DOMContentLoaded', function(){
  function wireRemoveButton(button){
    button.addEventListener('click', function(){
      const row = button.closest('[data-fields-row]')
>>>>>>> origin/develop
      if(!row) return

      // Rails appends the nested-attributes hidden id field as a sibling
      // right after this row's markup, not nested inside it.
      const idField = row.nextElementSibling && row.nextElementSibling.matches('input[name*="[id]"]')
        ? row.nextElementSibling
        : null
      const isPersisted = idField && idField.value !== ''

      if(isPersisted){
        // check_box renders a hidden value="0" companion input before the
        // actual checkbox under the same name — must target the checkbox specifically.
        const destroyField = row.querySelector('input[type="checkbox"][name*="[_destroy]"]')
        if(destroyField) destroyField.checked = true
        row.hidden = true
      } else {
        row.remove()
      }
    })
  }

<<<<<<< HEAD
  document.querySelectorAll('.remove-milestone-btn').forEach(wireRemoveButton)

  if(!addButton) return

  addButton.addEventListener('click', function(){
    const container = document.getElementById(addButton.dataset.milestonesContainer)
    const template = document.getElementById(addButton.dataset.milestoneTemplate)
    if(!container || !template) return

    const uniqueIndex = new Date().getTime()
    const html = template.innerHTML.replace(/NEW_MILESTONE_INDEX/g, uniqueIndex)

    const wrapper = document.createElement('div')
    wrapper.innerHTML = html
    const newRow = wrapper.firstElementChild
    container.appendChild(newRow)

    const newRemoveButton = newRow.querySelector('.remove-milestone-btn')
    if(newRemoveButton) wireRemoveButton(newRemoveButton)
=======
  document.querySelectorAll('.remove-fields-btn').forEach(wireRemoveButton)

  document.querySelectorAll('.add-fields-btn').forEach(function(addButton){
    addButton.addEventListener('click', function(){
      const container = document.getElementById(addButton.dataset.fieldsContainer)
      const template = document.getElementById(addButton.dataset.fieldsTemplate)
      if(!container || !template) return

      const uniqueIndex = new Date().getTime()
      const html = template.innerHTML.replace(/NEW_RECORD_INDEX/g, uniqueIndex)

      const wrapper = document.createElement('div')
      wrapper.innerHTML = html
      const newRow = wrapper.firstElementChild
      container.appendChild(newRow)

      // Auto-fill sort_order with the next number after the highest one
      // currently in the container, so new rows don't start blank/0 — the
      // field stays editable, this is just a convenient default.
      const sortOrderInput = newRow.querySelector('[data-sort-order-input]')
      if(sortOrderInput){
        const existingValues = Array.from(container.querySelectorAll('[data-sort-order-input]'))
          .filter(function(input){ return input !== sortOrderInput })
          .map(function(input){ return parseInt(input.value, 10) })
          .filter(function(n){ return !isNaN(n) })
        sortOrderInput.value = existingValues.length ? Math.max.apply(null, existingValues) + 1 : 0
      }

      const newRemoveButton = newRow.querySelector('.remove-fields-btn')
      if(newRemoveButton) wireRemoveButton(newRemoveButton)
    })
>>>>>>> origin/develop
  })
})
