export interface SseFrame { id?: string; event: string; data: string }
/** Incremental UTF-8 decoding belongs to the caller; handles CRLF and multiline data. */
export class ReportSseParser {
  private buffer = ''
  push(chunk: string): SseFrame[] {
    this.buffer += chunk
    if (this.buffer.length > 1024 * 1024) throw new Error('SSE buffer exceeded')
    const frames: SseFrame[] = []
    let match: RegExpExecArray | null
    while ((match = /\r?\n\r?\n/.exec(this.buffer))) {
      const block = this.buffer.slice(0, match.index)
      this.buffer = this.buffer.slice(match.index + match[0].length)
      const frame: SseFrame = { event: 'message', data: '' }
      const data: string[] = []
      for (const line of block.split(/\r?\n/)) {
        if (line.startsWith(':')) continue
        const colon = line.indexOf(':')
        const field = colon < 0 ? line : line.slice(0, colon)
        const value = colon < 0 ? '' : line.slice(colon + 1).replace(/^ /, '')
        if (field === 'data') data.push(value)
        if (field === 'event') frame.event = value
        if (field === 'id' && !value.includes('\0')) frame.id = value
      }
      frame.data = data.join('\n')
      if (data.length) frames.push(frame)
    }
    return frames
  }
}
