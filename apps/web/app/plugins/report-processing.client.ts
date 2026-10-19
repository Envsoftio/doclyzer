import { ReportSseParser } from '../utils/reportSse'
type Status = { reportId: string; profileId: string; version: string; status: string; stage: string; acknowledgedAt?: string }
export default defineNuxtPlugin((app) => {
  const config = useRuntimeConfig()
  const base = String(config.public.apiBaseUrl).replace(/\/+$/, '')
  const reports = useState<Record<string, Status>>('report-processing', () => ({}))
  const connection = useState<string>('report-connection', () => 'offline')
  let token = '', generation = 0, controller: AbortController | null = null
  let reconnect: ReturnType<typeof setTimeout> | undefined
  let attempt = 0
  const stop = () => { generation++; controller?.abort(); clearTimeout(reconnect); reports.value = {}; connection.value = 'offline' }
  const run = async (epoch: number) => {
    if (epoch !== generation || !token) return
    const current = new AbortController()
    controller = current
    const signal = current.signal
    connection.value = 'connecting'
    const headers = { Authorization: `Bearer ${token}` }
    try {
      // Every startup/reconnect begins with a consistent authorized snapshot;
      // no cursor or clinical cache survives logout/account changes.
      const snapshot = await fetch(`${base}/reports/processing/snapshot`, { headers, signal })
      if ([401, 403].includes(snapshot.status)) { stop(); return }
      if (snapshot.status === 503) { connection.value = 'disabled'; return }
      if (!snapshot.ok) throw new Error('snapshot unavailable')
      const { data } = await snapshot.json()
      if (epoch !== generation) return
      reports.value = Object.fromEntries(data.reports.map((r: Status) => [r.reportId, r]))
      window.dispatchEvent(new Event('doclyzer-report-change'))
      const response = await fetch(`${base}/reports/processing/events?cursor=${encodeURIComponent(data.cursor)}`, { headers: { ...headers, Accept: 'text/event-stream' }, signal })
      if ([401, 403].includes(response.status)) { stop(); return }
      if (!response.ok || !response.body) throw new Error('stream unavailable')
      connection.value = 'connected'; attempt = 0
      const reader = response.body.getReader(), decoder = new TextDecoder(), parser = new ReportSseParser()
      while (!signal.aborted) {
        const idle = setTimeout(() => current.abort(), 40000)
        const { value, done } = await reader.read().finally(() => clearTimeout(idle))
        if (done) break
        for (const frame of parser.push(decoder.decode(value, { stream: true }))) {
          if (frame.event === 'report.reset') throw new Error('reset required')
          if (frame.event !== 'report.status_changed') continue
          const event = JSON.parse(frame.data) as Status
          if (!/^\d+$/.test(event.version)) throw new Error('invalid version')
          const previous = reports.value[event.reportId]
          if (previous && BigInt(event.version) <= BigInt(previous.version)) continue
          if (previous && BigInt(event.version) > BigInt(previous.version) + 1n) throw new Error('version gap')
          reports.value = { ...reports.value, [event.reportId]: { ...previous, ...event } }
          window.dispatchEvent(new Event('doclyzer-report-change'))
        }
      }
    } catch { /* Reconnect includes authoritative reconciliation. */ }
    finally { current.abort() }
    if (epoch !== generation) return
    connection.value = 'reconnecting'
    reconnect = setTimeout(() => void run(epoch), Math.min(30000, 1000 * 2 ** Math.min(attempt++, 5)) * (0.5 + Math.random() / 2))
  }
  const sync = () => {
    const next = location.pathname.startsWith('/share/') ? '' : sessionStorage.getItem('doclyzerConsumerAccessToken') ?? ''
    if (next === token) return
    stop(); token = next; attempt = 0
    if (token) void run(generation)
  }
  app.$router.afterEach(sync)
  window.addEventListener('storage', sync)
  window.addEventListener('doclyzer-auth-change', sync)
  window.addEventListener('online', () => { if (token) { stop(); void run(generation) } })
  sync()
})
