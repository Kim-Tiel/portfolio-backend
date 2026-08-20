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
