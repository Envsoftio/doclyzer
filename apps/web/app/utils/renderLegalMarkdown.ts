// These policy files use headings, paragraphs, emphasis, quotes, rules, and simple lists.
// Escape source text before adding the small set of HTML tags needed to display them.
function escapeHtml(value: string): string {
  return value.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;')
}

function inline(value: string): string {
  return escapeHtml(value).replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
}

export function renderLegalMarkdown(source: string): string {
  const html: string[] = []
  const paragraph: { text: string; hardBreak: boolean }[] = []
  let list: 'ul' | 'ol' | null = null

  function endParagraph() {
    if (paragraph.length) html.push(`<p>${paragraph.map((part, index) => `${index ? (paragraph[index - 1].hardBreak ? '<br>' : ' ') : ''}${inline(part.text)}`).join('')}</p>`)
    paragraph.length = 0
  }

  function endList() {
    if (list) html.push(`</${list}>`)
    list = null
  }

  for (const rawLine of source.replace(/\r\n/g, '\n').split('\n')) {
    const line = rawLine.trimEnd()
    if (!line.trim()) { endParagraph(); endList(); continue }

    const heading = /^(#{1,3})\s+(.+)$/.exec(line)
    if (heading) {
      endParagraph(); endList()
      const level = heading[1].length
      html.push(`<h${level}>${inline(heading[2])}</h${level}>`)
      continue
    }
    if (line === '---') { endParagraph(); endList(); html.push('<hr>'); continue }
    if (line.startsWith('> ')) { endParagraph(); endList(); html.push(`<blockquote><p>${inline(line.slice(2))}</p></blockquote>`); continue }

    const bullet = /^-\s+(.+)$/.exec(line)
    const numbered = /^\d+\.\s+(.+)$/.exec(line)
    if (bullet || numbered) {
      endParagraph()
      const nextList = bullet ? 'ul' : 'ol'
      if (list !== nextList) { endList(); html.push(`<${nextList}>`); list = nextList }
      html.push(`<li>${inline((bullet || numbered)![1])}</li>`)
      continue
    }

    endList()
    paragraph.push({ text: line, hardBreak: / {2,}$/.test(rawLine) })
  }
  endParagraph()
  endList()
  return html.join('\n')
}
