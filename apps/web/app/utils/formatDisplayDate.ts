/** Dates for display only. Keep ISO strings for API requests and date inputs. */
export function formatDisplayDate(value: string, includeTime = false): string {
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return value
  const dateOnly = /^\d{4}-\d{2}-\d{2}$/.test(value)
  const dateText = new Intl.DateTimeFormat('en-GB', {
    day: '2-digit', month: 'short', year: 'numeric',
    ...(dateOnly ? { timeZone: 'UTC' } : {}),
  }).format(date).replace(/ /g, '-')
  if (!includeTime) return dateText
  const timeText = new Intl.DateTimeFormat('en-GB', {
    hour: '2-digit', minute: '2-digit', hour12: false,
  }).format(date)
  return `${dateText} ${timeText}`
}
