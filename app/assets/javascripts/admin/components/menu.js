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
