// Menu/burger behaviour
document.addEventListener('DOMContentLoaded', function(){
  const burger = document.getElementById('burgerToggle')
  const side = document.getElementById('sideMenu')
  if(!burger || !side) return

  const toggle = () => {
    const open = side.classList.toggle('open')
    side.setAttribute('aria-hidden', String(!open))
  }

  burger.addEventListener('click', (e)=>{
    e.stopPropagation()
    toggle()
  })

  // click outside to close on mobile
  document.addEventListener('click', (e)=>{
    if(window.innerWidth > 880) return
    if(!side.classList.contains('open')) return
    if(side.contains(e.target) || burger.contains(e.target)) return
    side.classList.remove('open')
    side.setAttribute('aria-hidden', 'true')
  })

  // close with Escape
  document.addEventListener('keydown', (e)=>{
    if(e.key === 'Escape' && side.classList.contains('open')){
      side.classList.remove('open')
      side.setAttribute('aria-hidden', 'true')
    }
  })
});
function hideFlashMessages() {
  var flashContainers = document.querySelectorAll('.flash-card, .flash-messages')
  if (!flashContainers.length) return

  window.setTimeout(function() {
    flashContainers.forEach(function(container) {
      container.classList.add('flash-hidden')
    })
  }, 5000)
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', hideFlashMessages)
} else {
  hideFlashMessages()
};
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
});
// Reusable confirmation modal, shared by every admin module.
// Any <form data-confirm-message="..."> has its submit intercepted; the
// modal borrows that form's message/action label, and only a real click on
// the confirm button re-submits it (form.submit() does not re-fire 'submit',
// so there is no risk of looping back into this same handler).
document.addEventListener('DOMContentLoaded', function(){
  const modal = document.getElementById('confirm-modal')
  if(!modal) return

  const messageEl = document.getElementById('confirm-modal-message')
  const confirmBtn = document.getElementById('confirm-modal-confirm')
  let pendingForm = null

  function openModal(form){
    pendingForm = form
    messageEl.textContent = form.dataset.confirmMessage
    confirmBtn.textContent = form.dataset.confirmAction || 'Confirm'
    confirmBtn.className = form.dataset.confirmVariant === 'danger' ? 'danger' : 'primary'
    modal.hidden = false
  }

  function closeModal(){
    modal.hidden = true
    pendingForm = null
  }

  function serializeForm(form){
    return new URLSearchParams(new FormData(form)).toString()
  }

  document.querySelectorAll('form[data-confirm-message]').forEach(function(form){
    // Edit/save forms opt in with data-confirm-skip-unchanged so a save with
    // no actual edits submits straight through instead of nagging the user.
    // Delete forms don't set this — there's no "unchanged" state to skip.
    const initialState = form.dataset.confirmSkipUnchanged === 'true' ? serializeForm(form) : null

    form.addEventListener('submit', function(e){
      if(form.dataset.confirmed === 'true') return
      if(initialState !== null && serializeForm(form) === initialState) return
      e.preventDefault()
      openModal(form)
    })
  })

  confirmBtn.addEventListener('click', function(){
    if(!pendingForm) return
    const form = pendingForm
    closeModal()
    form.dataset.confirmed = 'true'
    form.submit()
  })

  modal.querySelectorAll('[data-confirm-cancel]').forEach(function(el){
    el.addEventListener('click', closeModal)
  })

  document.addEventListener('keydown', function(e){
    if(e.key === 'Escape' && !modal.hidden) closeModal()
  })
});
// Profile page specific JS placeholder
// Add behaviour for admin profile page here (e.g., preview avatar, handle CSV tag parsing)
document.addEventListener('DOMContentLoaded', function(){
  // example: parse available_for input into chips (client-side preview)
  const availInput = document.querySelector('input[name="profile[available_for]"]')
  if(!availInput) return

  availInput.addEventListener('blur', function(){
    // noop for now — placeholder for future enhancements
  })
});






// Manifest file for admin JS; specific behaviours live in the required files above.;
