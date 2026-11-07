import { BadRequestException } from '@nestjs/common';

export const LANGUAGES = {
  en: { name: "English", nativeName: "English", script: "Latin" },
  hi: { name: "Hindi", nativeName: "हिन्दी", script: "Devanagari" },
  kn: { name: "Kannada", nativeName: "ಕನ್ನಡ", script: "Kannada" },
  te: { name: "Telugu", nativeName: "తెలుగు", script: "Telugu" },
  ml: { name: "Malayalam", nativeName: "മലയാളം", script: "Malayalam" },
  ta: { name: "Tamil", nativeName: "தமிழ்", script: "Tamil" },
  bn: { name: "Bengali", nativeName: "বাংলা", script: "Bengali" },
  or: { name: "Odia", nativeName: "ଓଡ଼ିଆ", script: "Oriya" },
  gu: { name: "Gujarati", nativeName: "ગુજરાતી", script: "Gujarati" },
  pa: { name: "Punjabi", nativeName: "ਪੰਜਾਬੀ", script: "Gurmukhi" },
  mr: { name: "Marathi", nativeName: "मराठी", script: "Devanagari" },
} as const;
export type SupportedLanguage = keyof typeof LANGUAGES;
export type TranslationLanguage = Exclude<SupportedLanguage, 'en'>;
export const SUPPORTED_LANGUAGES = Object.keys(LANGUAGES) as SupportedLanguage[];

export function requireLanguage(value: unknown = 'en'): SupportedLanguage {
  if (typeof value === 'string' && Object.hasOwn(LANGUAGES, value)) return value as SupportedLanguage;
  throw new BadRequestException({ code: 'LANGUAGE_UNSUPPORTED', message: 'Choose a supported language.' });
}
