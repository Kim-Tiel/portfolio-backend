// Dynamic "add another" rows for nested fields_for sections (e.g. education milestones).
// Usage: a <button data-milestones-container="ID" data-milestone-template="TEMPLATE_ID">
// next to a <template id="TEMPLATE_ID"> containing one fields_for block rendered with
// child_index: 'NEW_MILESTONE_INDEX', and a container <div id="ID"> to append into.
document.addEventListener('DOMContentLoaded', function(){
  const addButton = document.getElementById('add-milestone')

  function wireRemoveButton(button){
    button.addEventListener('click', function(){
      const row = button.closest('[data-milestone-row]')
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
  })
})
