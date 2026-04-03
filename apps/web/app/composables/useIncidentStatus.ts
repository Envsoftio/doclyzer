export interface PublicIncidentStatus {
  id: string
  severity: 'major' | 'critical'
  status: 'active' | 'monitoring' | 'resolved'
  headline: string
  message: string
  whatsAffected: string
  affectedSurfaces: Array<'mobile_app' | 'web_share' | 'web_landing' | 'api'>
  startedAt: string
  updatedAt: string
  resolvedAt?: string | null
}

const ACTIVE_STATUSES = new Set(['active', 'monitoring'])

export function useIncidentStatus() {
  const incident = ref<PublicIncidentStatus | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)
  const config = useRuntimeConfig()

  const fetchIncident = async () => {
    loading.value = true
    error.value = null
    try {
      const res = await $fetch<{ success: boolean; data: PublicIncidentStatus | null }>(
        `${config.public.apiBaseUrl}/incidents/active`,
      )
      incident.value = res.data ?? null
    } catch (err) {
      error.value = (err instanceof Error ? err.message : String(err)) || 'Failed to load incident status'
    } finally {
      loading.value = false
    }
  }

  onMounted(() => {
    void fetchIncident()
  })

  const isVisible = computed(() => {
    if (!incident.value) return false
    return ACTIVE_STATUSES.has(incident.value.status)
  })

  return { incident, loading, error, fetchIncident, isVisible }
}
