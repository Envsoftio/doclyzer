export const languages = [
  { code: 'en', name: 'English', language: 'en-IN', file: 'en.json' },
  { code: 'hi', name: 'हिन्दी', language: 'hi-IN', file: 'hi.json' },
  { code: 'kn', name: 'ಕನ್ನಡ', language: 'kn-IN', file: 'kn.json' },
  { code: 'te', name: 'తెలుగు', language: 'te-IN', file: 'te.json' },
  { code: 'ml', name: 'മലയാളം', language: 'ml-IN', file: 'ml.json' },
  { code: 'ta', name: 'தமிழ்', language: 'ta-IN', file: 'ta.json' },
  { code: 'bn', name: 'বাংলা', language: 'bn-IN', file: 'bn.json' },
  { code: 'or', name: 'ଓଡ଼ିଆ', language: 'or-IN', file: 'or.json' },
  { code: 'gu', name: 'ગુજરાતી', language: 'gu-IN', file: 'gu.json' },
  { code: 'pa', name: 'ਪੰਜਾਬੀ', language: 'pa-IN', file: 'pa.json' },
  { code: 'mr', name: 'मराठी', language: 'mr-IN', file: 'mr.json' },
] as const
export type SupportedLanguage = (typeof languages)[number]['code']
export function supportedLanguage(value: unknown): SupportedLanguage {
  return languages.some(language => language.code === value) ? value as SupportedLanguage : 'en'
}
