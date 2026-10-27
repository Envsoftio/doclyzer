<template>
  <footer class="site-footer container">
    <div class="footer-top">
      <div><NuxtLink class="brand" to="/" aria-label="Doclyzer home"><img src="/Doclyzer-logo.svg" width="856" height="183" alt="" /></NuxtLink><p>Health reports, organized.</p></div>
      <nav class="footer-links" aria-label="Footer">
        <div>
          <h3>Product</h3>
          <NuxtLink to="/#how-it-works">How it works</NuxtLink>
          <NuxtLink to="/#product">Features</NuxtLink>
          <NuxtLink to="/#families">For families</NuxtLink>
          <NuxtLink to="/#faqs">FAQs</NuxtLink>
        </div>
        <div>
          <h3>Legal</h3>
          <NuxtLink to="/privacy-policy">Privacy policy</NuxtLink>
          <NuxtLink to="/terms-and-conditions">Terms and conditions</NuxtLink>
          <NuxtLink to="/refund-and-cancellation-policy">Refund and cancellation</NuxtLink>
          <NuxtLink class="medical-disclaimer-link" to="/medical-disclaimer">Medical Disclaimer</NuxtLink>
        </div>
        <div>
          <h3>Support</h3>
          <a href="mailto:vishnu@envsoft.io?subject=Doclyzer%20enquiry">Contact</a>
          <NuxtLink to="/delete-account">Delete account</NuxtLink>
        </div>
      </nav>
    </div>
    <div class="footer-disclaimer" role="note">
      <span class="disclaimer-icon" aria-hidden="true">i</span>
      <div>
        <h2>Important health information</h2>
        <p>Doclyzer helps you organize and better understand your health reports. <strong>The information provided is for educational purposes only and is not medical advice, diagnosis, or treatment.</strong> Always consult a qualified healthcare professional for medical guidance.</p>
      </div>
    </div>
    <div class="footer-bottom">© {{ new Date().getFullYear() }} Doclyzer</div>
  </footer>
</template>

<style scoped>
.container{width:min(calc(100% - 48px),1160px);margin-inline:auto}.site-footer{padding-bottom:46px;color:var(--brand-ink)}
.brand{display:inline-flex;align-items:center;text-decoration:none}.brand img{display:block;width:178px;height:auto}
.footer-top{display:flex;justify-content:space-between;gap:48px;min-height:198px}.footer-top p{color:var(--brand-muted);font-size:14px}
.footer-links{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:40px;width:min(100%,650px)}.footer-links>div{display:flex;flex-direction:column;gap:15px}.footer-links h3{text-transform:uppercase;font-size:11px;letter-spacing:.17em;margin:4px 0 7px}
.footer-links a{font-size:13px;text-decoration:none;color:var(--brand-muted)}.footer-links a:hover{color:var(--brand-teal)}
.footer-links .medical-disclaimer-link{color:#0b6864;font-weight:800;text-decoration:underline;text-decoration-thickness:2px;text-underline-offset:3px}.footer-links .medical-disclaimer-link:hover{color:var(--brand-blue)}
.footer-disclaimer{display:grid;grid-template-columns:36px minmax(0,1fr);align-items:start;gap:14px;margin-bottom:24px;padding:20px 24px;border:1px solid var(--brand-border);border-left:3px solid var(--brand-teal);border-radius:14px;background:var(--brand-mint)}
.disclaimer-icon{display:grid;place-items:center;width:36px;height:36px;border-radius:50%;background:#fff;color:var(--brand-blue);font-size:18px;font-weight:700;font-family:Georgia,serif}
.footer-disclaimer h2{margin:0 0 6px;color:var(--brand-ink);font-size:15px;line-height:1.4;font-weight:700}
.footer-disclaimer p{max-width:90ch;margin:0;color:var(--brand-muted);font-size:14px;line-height:1.65}
.footer-disclaimer strong{color:var(--brand-ink);font-weight:700}
.footer-bottom{border-top:1px solid var(--brand-border);padding-top:20px;color:var(--brand-muted);font-size:11px}
@media(max-width:980px){.container{width:calc(100% - 96px)}.footer-top{display:block}.footer-links{margin-top:32px;max-width:650px}}
@media(max-width:600px){.container{width:calc(100% - 48px)}.footer-top p{margin:22px 0 34px;font-size:12px}.footer-links{grid-template-columns:repeat(2,minmax(0,1fr));gap:32px 20px;margin-top:0}.footer-links a{font-size:12px}.footer-disclaimer{grid-template-columns:30px minmax(0,1fr);gap:12px;margin-top:32px;padding:16px}.disclaimer-icon{width:30px;height:30px;font-size:16px}.footer-disclaimer h2{font-size:14px}.footer-disclaimer p{font-size:13px}.footer-bottom{font-size:10px}}
</style>
