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
})
