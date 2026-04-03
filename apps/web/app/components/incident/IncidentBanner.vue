<script setup lang="ts">
import type { PublicIncidentStatus } from '~/composables/useIncidentStatus'

const props = withDefaults(defineProps<{ incident: PublicIncidentStatus | null; surface: 'web_share' | 'web_landing' }>(), {
  incident: null,
})

const isVisible = computed(() => {
  if (!props.incident) return false
  if (!(props.incident.status === 'active' || props.incident.status === 'monitoring')) return false
  return props.incident.affectedSurfaces.includes(props.surface)
})

const isCritical = computed(() => props.incident?.severity === 'critical')

const role = computed(() => (isCritical.value ? 'alert' : 'status'))
const ariaLive = computed(() => (isCritical.value ? 'assertive' : 'polite'))

const updatedLabel = computed(() => {
  if (!props.incident) return ''
  const date = new Date(props.incident.updatedAt)
  return date.toLocaleString(undefined, {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  })
})
</script>

<template>
  <div
    class="incident-banner"
    :class="{ 'incident-banner--critical': isCritical }"
    v-show="isVisible"
    :role="role"
    :aria-live="ariaLive"
  >
    <div class="incident-banner__header">
      <span class="incident-banner__label">
        {{ isCritical ? 'Critical service notice' : 'Service notice' }}
      </span>
      <span class="incident-banner__status">
        {{ incident?.status === 'monitoring' ? 'Monitoring' : 'Active' }}
      </span>
    </div>
    <div class="incident-banner__headline">{{ incident?.headline }}</div>
    <div class="incident-banner__message">{{ incident?.message }}</div>
    <div class="incident-banner__meta">
      <span><strong>What's affected:</strong> {{ incident?.whatsAffected }}</span>
      <span>Last updated {{ updatedLabel }}</span>
    </div>
  </div>
</template>

<style scoped>
.incident-banner {
  border-radius: 12px;
  padding: 14px 16px;
  border: 1px solid rgba(148, 163, 184, 0.4);
  background: #f8fafc;
  color: #0f172a;
  display: grid;
  gap: 8px;
}

.incident-banner__header {
  display: flex;
  justify-content: space-between;
  gap: 12px;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.12em;
  color: #334155;
}

.incident-banner__label {
  font-weight: 700;
}

.incident-banner__status {
  font-weight: 600;
}

.incident-banner__headline {
  font-size: 1rem;
  font-weight: 700;
}

.incident-banner__message {
  font-size: 0.95rem;
  line-height: 1.45;
}

.incident-banner__meta {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  font-size: 0.8rem;
  color: #475569;
}

.incident-banner--critical {
  background: #fef2f2;
  border-color: rgba(248, 113, 113, 0.5);
  color: #7f1d1d;
}

.incident-banner--critical .incident-banner__header,
.incident-banner--critical .incident-banner__meta {
  color: #991b1b;
}
</style>
