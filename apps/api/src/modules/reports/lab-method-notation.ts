/**
 * Recognized assay annotations, not analyte aliases. Unknown suffixes remain
 * untouched. Keep the original wording in identity evidence for reconciliation.
 */
const ASSAY_SUFFIX = new RegExp(
  '(' +
    [
      'Cholesterol oxidase\\s*[-–]\\s*Peroxidase method',
      'E(?:n)?zymatic \\(Lipase/GK/GPO/POD\\)',
      'High Performance Liquid Chromatography',
      'Copper tartrate to colour complex',
      'Polyelectrolyte based reaction',
      'Protein error of indicators',
      'Creatinine Amidohydrolase',
      'Cationic Mordant Binding',
      'Bromocresol Green Method',
      'Azobilirubin chromophores',
      'Modified Ehrlich reaction',
      'Urease, Colorimetric',
      'UV with P5P, IFCC',
      'UV with P5P',
      'Pyridyl azo Dye',
      'Double indicator',
      'Nitrite reaction',
      'Diazo reaction',
      'Nitroprusside',
      'Chemiluminescence',
      'Chemiluminescent',
      'Direct measured',
      'Direct\\s*-\\s*ISE',
      'Arsenazo III',
      'PTA/MgCl2',
      'Calculated',
      'GOD-POD',
      'Uricase',
      'CLIA',
    ].join('|') +
    ')$',
  'i',
);

export function splitAssayAnnotation(text: string): {
  name: string;
  method?: string;
} {
  const explicit = text.match(/^(.+?)\s*\bMethod\s*:\s*(.+)$/i);
  if (explicit) return { name: explicit[1].trim(), method: explicit[2].trim() };
  const match = text.trim().match(ASSAY_SUFFIX);
  if (!match || !match.index) return { name: text };
  return {
    name: text.slice(0, match.index).trim(),
    method: match[1].trim(),
  };
}

export function isAssayAnnotation(text: string): boolean {
  const match = text.trim().match(ASSAY_SUFFIX);
  return match?.index === 0;
}

/** Preserve numeric tokens: "1 20" must never become "120". */
export function comparisonNotation(text: string): string {
  return (
    text
      .toLowerCase()
      .replace(/[–−]/g, '-')
      .match(/\d+(?:[.,]\d+)*|[a-z]+|[^\s]/g) ?? []
  ).join('|');
}
