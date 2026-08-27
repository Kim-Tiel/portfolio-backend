function hideFlashMessages() {
<<<<<<< HEAD
  var flashContainers = document.querySelectorAll('.flash-card, .flash-messages')
=======
  var flashContainers = document.querySelectorAll('.flash-card, .flash-messages, .form-errors')
>>>>>>> origin/develop
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
}
