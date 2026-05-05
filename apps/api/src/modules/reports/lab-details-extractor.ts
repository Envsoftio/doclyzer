export interface ExtractedLabDetails {
  name?: string;
  address?: string;
  phone?: string;
  email?: string;
  location?: string;
}

function normalizeSpace(s: string): string {
  return s.replace(/\s+/g, ' ').trim();
}

function cleanFieldValue(s: string): string {
  return normalizeSpace(s).replace(/^[\-:,\s]+|[\-:,\s]+$/g, '');
}

function uniqueNonEmpty(values: Array<string | undefined>): string[] {
  const seen = new Set<string>();
  const out: string[] = [];
  for (const value of values) {
    if (!value) continue;
    const cleaned = cleanFieldValue(value);
    if (!cleaned) continue;
    const key = cleaned.toLowerCase();
    if (seen.has(key)) continue;
    seen.add(key);
    out.push(cleaned);
  }
  return out;
}

export class LabDetailsExtractor {
  extractFromTranscript(transcript: string | null): ExtractedLabDetails {
    if (!transcript) return {};
    const lines = transcript
      .replace(/\r\n/g, '\n')
      .split('\n')
      .map((line) => normalizeSpace(line))
      .filter((line) => line.length > 0);
    return this.extractFromLines(lines);
  }

  extractFromLines(lines: string[]): ExtractedLabDetails {
    if (lines.length === 0) return {};

    const topLines = lines.slice(0, 40);
    const full = topLines.join('\n');

    const labeled = this.extractLabeledFields(topLines);
    const fallbackName = labeled.name ?? this.extractHeaderLabName(topLines);
    const fallbackAddress =
      labeled.address ?? this.extractAddressBlock(topLines);

    const location =
      labeled.location ?? this.extractLocationFromAddress(fallbackAddress);

    const phone = labeled.phone ?? this.extractPhone(full);
    const email = labeled.email ?? this.extractEmail(full);

    return {
      ...(fallbackName ? { name: fallbackName } : {}),
      ...(fallbackAddress ? { address: fallbackAddress } : {}),
      ...(phone ? { phone } : {}),
      ...(email ? { email } : {}),
      ...(location ? { location } : {}),
    };
  }

  private extractLabeledFields(lines: string[]): ExtractedLabDetails {
    const values: ExtractedLabDetails = {};
    for (const line of lines) {
      const mName = line.match(
        /^(?:lab(?:oratory)?(?:\s*name)?|diagnostic(?:\s*centre|\s*center)?(?:\s*name)?|hospital(?:\s*name)?|clinic(?:\s*name)?)\s*[:\-]\s*(.+)$/i,
      );
      if (mName && !values.name) values.name = cleanFieldValue(mName[1]);

      const mAddress = line.match(
        /^(?:lab\s*address|address)\s*[:\-]\s*(.+)$/i,
      );
      if (mAddress && !values.address) {
        values.address = cleanFieldValue(mAddress[1]);
      }

      const mLocation = line.match(/^(?:location|city)\s*[:\-]\s*(.+)$/i);
      if (mLocation && !values.location) {
        values.location = cleanFieldValue(mLocation[1]);
      }

      const mPhone = line.match(
        /^(?:phone|mobile|contact|helpline|tel)\s*[:\-]\s*([+()0-9\s-]{7,25})$/i,
      );
      if (mPhone && !values.phone) values.phone = cleanFieldValue(mPhone[1]);

      const mEmail = line.match(
        /^(?:email|e-mail)\s*[:\-]\s*([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,})$/i,
      );
      if (mEmail && !values.email) values.email = cleanFieldValue(mEmail[1]);
    }
    return values;
  }

  private extractHeaderLabName(lines: string[]): string | undefined {
    for (const line of lines.slice(0, 12)) {
      if (line.length < 3 || line.length > 90) continue;
      if (line.includes(':') || line.includes('|')) continue;
      if (
        /\b(patient|name|age|gender|booking|sample|report|test|result|reference|doctor)\b/i.test(
          line,
        )
      ) {
        continue;
      }
      if (
        /\b(lab|laboratory|diagnostic|diagnostics|pathology|hospital|clinic)\b/i.test(
          line,
        )
      ) {
        return line;
      }
    }
    return undefined;
  }

  private extractAddressBlock(lines: string[]): string | undefined {
    const candidates: string[] = [];
    for (let i = 0; i < Math.min(lines.length, 24); i++) {
      const line = lines[i];
      if (
        /^(?:address)\s*[:\-]\s*/i.test(line) ||
        /\b(?:road|rd\.?|street|st\.?|nagar|colony|sector|floor|building|near|opp|avenue|lane|city|state|pincode|pin)\b/i.test(
          line,
        )
      ) {
        candidates.push(line.replace(/^(?:address)\s*[:\-]\s*/i, ''));
        const next = lines[i + 1];
        if (
          next &&
          next.length <= 120 &&
          !/^(?:phone|mobile|contact|email|patient|report|booking)\b/i.test(
            next,
          )
        ) {
          candidates.push(next);
        }
      }
    }
    const merged = uniqueNonEmpty(candidates).join(', ');
    return merged || undefined;
  }

  private extractLocationFromAddress(address?: string): string | undefined {
    if (!address) return undefined;
    const parts = address
      .split(',')
      .map((p) => cleanFieldValue(p))
      .filter(Boolean);
    if (parts.length === 0) return undefined;
    const last = parts[parts.length - 1];
    if (!/[A-Za-z]/.test(last)) return undefined;
    if (/\d/.test(last) && parts.length >= 2) return parts[parts.length - 2];
    return last;
  }

  private extractPhone(text: string): string | undefined {
    const m = text.match(
      /\b(?:\+?\d{1,3}[-\s]?)?(?:\(?\d{2,5}\)?[-\s]?)\d{3,5}[-\s]?\d{3,5}\b/,
    );
    return m ? cleanFieldValue(m[0]) : undefined;
  }

  private extractEmail(text: string): string | undefined {
    const m = text.match(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i);
    return m ? cleanFieldValue(m[0]) : undefined;
  }
}
