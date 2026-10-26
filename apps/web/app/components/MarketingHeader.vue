<script setup lang="ts">
import { nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue'

const config = useRuntimeConfig()
const startRoute = computed(() => config.public.consumerWebEnabled ? '/register' : '/mobile')
const loginRoute = computed(() => config.public.consumerWebEnabled ? '/login' : '/mobile')
const menuOpen = ref(false)
const menuButton = ref<HTMLButtonElement | null>(null)
const menuPanel = ref<HTMLElement | null>(null)

function closeMenu(restoreFocus = false) {
  menuOpen.value = false
  if (restoreFocus) nextTick(() => menuButton.value?.focus())
}

function onMenuKeydown(event: KeyboardEvent) {
  if (!menuOpen.value) return
  if (event.key === 'Escape') {
    event.preventDefault()
    closeMenu(true)
    return
  }
  if (event.key !== 'Tab' || !menuPanel.value) return
  const items = [...menuPanel.value.querySelectorAll<HTMLElement>('a, button:not([disabled])')]
  if (!items.length) return
  const first = items[0]
  const last = items[items.length - 1]
  if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last.focus() }
  if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus() }
}

watch(menuOpen, async (open) => {
  if (import.meta.client) document.body.style.overflow = open ? 'hidden' : ''
  if (open) { await nextTick(); menuPanel.value?.querySelector<HTMLElement>('a')?.focus() }
})
onMounted(() => window.addEventListener('keydown', onMenuKeydown))
onBeforeUnmount(() => {
  window.removeEventListener('keydown', onMenuKeydown)
  document.body.style.overflow = ''
})
</script>

<template>
  <a class="skip-link" href="#main">Skip to content</a>
  <header class="site-header">
    <div class="container header-inner">
      <NuxtLink class="brand" to="/" aria-label="Doclyzer home" @click="closeMenu()">
        <img src="/Doclyzer-logo.svg" width="856" height="183" alt="" />
      </NuxtLink>
      <nav class="desktop-nav" aria-label="Main navigation">
        <NuxtLink to="/#product">Product</NuxtLink><NuxtLink to="/#how-it-works">How it works</NuxtLink><NuxtLink to="/#families">For families</NuxtLink><NuxtLink to="/#faqs">FAQs</NuxtLink>
      </nav>
      <div class="header-actions"><NuxtLink class="login-link" :to="loginRoute">Log in</NuxtLink><NuxtLink class="btn btn-primary header-cta" :to="startRoute">Get started <span aria-hidden="true">→</span></NuxtLink></div>
      <button ref="menuButton" class="menu-toggle" type="button" aria-controls="mobile-navigation" :aria-expanded="menuOpen" :aria-label="menuOpen ? 'Close navigation' : 'Open navigation'" @click="menuOpen ? closeMenu(true) : menuOpen = true"><span v-if="!menuOpen">☰</span><span v-else>×</span></button>
    </div>
    <nav v-if="menuOpen" id="mobile-navigation" ref="menuPanel" class="mobile-nav" aria-label="Mobile navigation">
      <div class="container"><p class="eyebrow">Explore Doclyzer</p><NuxtLink to="/#product" @click="closeMenu()">Product <span>↗</span></NuxtLink><NuxtLink to="/#how-it-works" @click="closeMenu()">How it works <span>↗</span></NuxtLink><NuxtLink to="/#families" @click="closeMenu()">For families <span>↗</span></NuxtLink><NuxtLink to="/#faqs" @click="closeMenu()">FAQs <span>↗</span></NuxtLink><NuxtLink class="btn btn-primary" :to="startRoute" @click="closeMenu()">Get started <span aria-hidden="true">→</span></NuxtLink><NuxtLink class="menu-login" :to="loginRoute" @click="closeMenu()">Log in</NuxtLink><p class="menu-caption">Health reports, organized.</p></div>
    </nav>
  </header>
</template>

<style scoped>
.container{width:min(calc(100% - 48px),1160px);margin-inline:auto}
.skip-link{position:absolute;top:-60px;left:24px;z-index:100;background:#fff;padding:12px}.skip-link:focus{top:12px}
.site-header{position:relative;z-index:20;background:#fafcfb}.header-inner{height:101px;display:flex;align-items:center;border-bottom:1px solid var(--brand-border)}
.brand{display:inline-flex;align-items:center;text-decoration:none}.brand img{display:block;width:178px;height:auto}
.desktop-nav{display:flex;gap:45px;margin:auto}.desktop-nav a,.login-link{text-decoration:none;font-size:13px;font-weight:700;color:var(--brand-ink)}
.desktop-nav a:hover,.login-link:hover{color:var(--brand-teal)}.header-actions{display:flex;align-items:center;gap:42px}.login-link{color:var(--brand-blue)}
.btn{display:inline-flex;align-items:center;justify-content:space-between;gap:28px;min-height:56px;padding:0 18px;border-radius:11px;text-decoration:none;font-size:14px;font-weight:700;transition:background .2s,transform .2s}.btn-primary{background:var(--brand-blue);color:#fff}.btn-primary:hover{background:#0d405e}.btn span{font-size:24px;font-weight:400;line-height:1}.header-cta{min-height:48px;min-width:160px}
.menu-toggle,.mobile-nav{display:none}.eyebrow{margin:0;color:#126b67;text-transform:uppercase;font-size:11px;line-height:1.5;font-weight:800;letter-spacing:.16em}
@media(max-width:1100px){.desktop-nav{gap:24px}.header-actions{gap:20px}}
@media(max-width:980px){.container{width:calc(100% - 96px)}.desktop-nav{margin-left:auto;margin-right:auto}.desktop-nav a:not(:nth-child(2)),.login-link{display:none}.menu-toggle{display:grid;place-items:center;margin-left:22px;width:44px;height:44px;background:#fff;border:1px solid var(--brand-border);border-radius:12px;color:var(--brand-ink);font-size:25px;cursor:pointer}.mobile-nav{display:block;position:fixed;top:83px;left:0;right:0;bottom:0;overflow:auto;background:#fafcfb;z-index:30;padding:36px 0}.mobile-nav .container{display:flex;flex-direction:column;min-height:calc(100% - 36px)}.mobile-nav .eyebrow{margin-bottom:25px}.mobile-nav a:not(.btn){display:flex;justify-content:space-between;align-items:center;text-decoration:none;border-bottom:1px solid var(--brand-border);font-size:24px;font-weight:600;padding:21px 0;color:var(--brand-ink)}.mobile-nav a span{color:var(--brand-blue)}.mobile-nav .btn{margin-top:55px}.mobile-nav .menu-login{justify-content:center!important;color:var(--brand-blue);font-size:15px!important;border:0!important}.menu-caption{font-size:12px;color:var(--brand-muted);margin-top:auto;padding-top:60px}.header-inner{height:83px}}
@media(max-width:600px){.container{width:calc(100% - 48px)}.header-actions,.desktop-nav{display:none}.menu-toggle{margin-left:auto}.mobile-nav .btn{width:100%}}
@media(prefers-reduced-motion:reduce){.btn{transition:none}}
</style>
