import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';

const ROOT = fileURLToPath(new URL('../../../', import.meta.url));
const MANIFEST = JSON.parse(
  readFileSync(join(ROOT, 'assets/images/illustrations/manifest.json'), 'utf8'),
) as { illustrations: { id: string; name: string }[] };
const APP_LOCALES = [...new Set([
  'en',
  ...readdirSync(join(ROOT, 'assets/data/i18n'))
    .filter((file) => file.startsWith('packs_') && file.endsWith('.json'))
    .map((file) => file.slice('packs_'.length, -'.json'.length).replaceAll('_', '-')),
])];
const LOW_CONFIDENCE_LOCALES = new Set([
  'am', 'as', 'az', 'ha', 'ig', 'jv', 'mn', 'my', 'ne', 'om',
  'or', 'pa', 'ps', 'sd', 'so', 'su', 'sw', 'uz', 'yo', 'zu',
  'af', 'bg', 'et', 'lt', 'lv', 'be', 'bs', 'cy', 'eo', 'eu',
  'hy', 'is', 'ka', 'kk', 'mk',
  'sq', 'sr', 'gl', 'ga', 'si',
  'nn', 'no', 'lb', 'mt', 'gd',
  'fy', 'km', 'ky', 'tl', 'ht',
  'ku', 'tg', 'lo', 'yi', 'la',
  'oc', 'co', 'fo', 'mi', 'mg',
  'ug', 'sn', 'st', 'ny',
]);

const quoteDart = (value: string) => `'${value.replaceAll('\\', '\\\\').replaceAll("'", "\\'").replaceAll('$', '\\$')}'`;

describe('localized illustration labels', () => {
  it('matches the English manifest and exports each app locale label to Flutter', () => {
    const english = JSON.parse(readFileSync(join(ROOT, 'site/src/i18n/play/en.json'), 'utf8'));
    const manifestNames = Object.fromEntries(MANIFEST.illustrations.map(({ id, name }) => [id, name]));
    const dart = readFileSync(join(ROOT, 'lib/features/gentle_activities/data/picture_library.g.dart'), 'utf8');
    const illustrationIds = Object.keys(manifestNames).sort();

    expect(english.illustrations).toEqual(manifestNames);
    expect(APP_LOCALES.filter((locale) => LOW_CONFIDENCE_LOCALES.has(locale)).sort()).toEqual(
      [...LOW_CONFIDENCE_LOCALES].sort(),
    );

    for (const locale of APP_LOCALES) {
      const dictionary = JSON.parse(
        readFileSync(join(ROOT, `site/src/i18n/play/${locale}.json`), 'utf8'),
      ) as { illustrations?: Record<string, string>; pictures?: Record<string, string> };
      const names = locale === 'en' ? english.illustrations : dictionary.illustrations;

      if (LOW_CONFIDENCE_LOCALES.has(locale)) {
        expect(names, locale).toBeUndefined();
        continue;
      }

      expect(Object.keys(names ?? {}).sort(), locale).toEqual(illustrationIds);
      const appLocale = locale.replaceAll('-', '_');
      const dartEntry = dart.split('\n').find((line) => line.startsWith(`  ${quoteDart(appLocale)}: {`));
      expect(dartEntry, appLocale).toBeDefined();
      for (const id of illustrationIds) {
        expect(names?.[id], `${locale}/${id}`).toBeTypeOf('string');
        expect(names?.[id]?.trim(), `${locale}/${id}`).not.toBe('');
        expect(dartEntry, `${appLocale}/${id}`).toContain(`${quoteDart(id)}: ${quoteDart(names?.[id] ?? '')}`);
      }
    }
  });
});
