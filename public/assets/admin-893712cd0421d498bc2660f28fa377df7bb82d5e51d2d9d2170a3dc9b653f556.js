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
