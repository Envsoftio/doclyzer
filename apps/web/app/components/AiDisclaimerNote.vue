<template>
  <p class="ai-disclaimer" role="note">
    <span class="ai-disclaimer__icon" aria-hidden="true">i</span>
    <span class="ai-disclaimer__text">
      Informational only — not medical advice. Discuss with your doctor.
    </span>
  </p>
</template>

<style scoped>
.ai-disclaimer {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  margin: 0;
  font-size: 0.85rem;
  line-height: 1.45;
  color: #4a4a4a;
  font-family: sans-serif;
}

.ai-disclaimer__icon {
  width: 18px;
  height: 18px;
  border-radius: 999px;
  border: 1px solid #777;
  color: #444;
  font-weight: 600;
  font-size: 0.75rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  flex: 0 0 auto;
  margin-top: 2px;
}
</style>
