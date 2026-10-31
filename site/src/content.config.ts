import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';

export const SECTIONS = ['activities', 'caregiving', 'brain-health'] as const;

export const GAME_SLUGS = [
  'picture-pairs',
  'find-the-same',
  'shadow-match',
  'sort-together',
  'picture-puzzle',
  'finish-the-saying',
  'word-search',
  'coloring',
  'conversation-cards',
  'photo-pairs',
  'picture-bingo',
  'calm-breathing',
] as const;

const guideSchema = z.object({
    title: z.string().max(80),
    seoTitle: z.string().max(60).optional(),
    description: z.string().min(110).max(165),
    section: z.enum(SECTIONS),
    order: z.number().int(),
    /** First publication; defaults to `updated` for pages published once. */
    published: z.coerce.date().optional(),
    updated: z.coerce.date(),
    summary: z.string().min(80).max(420),
    keyPoints: z.array(z.string()).min(3).max(6),
    faq: z
      .array(z.object({ q: z.string(), a: z.string() }))
      .min(2)
      .max(6),
    sources: z
      .array(
        z.object({
          title: z.string(),
          publisher: z.string(),
          url: z.string().url(),
        }),
      )
      .min(1),
    relatedGames: z.array(z.enum(GAME_SLUGS)).default([]),
    related: z.array(z.string()).default([]),
    health: z.boolean().default(false),
});

const guides = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/guides' }),
  schema: guideSchema,
});

/**
 * Translations live at `guides-i18n/<language code>/<section>/<slug>.md` and
 * mirror the English entry. Character limits are looser because many
 * languages (Chinese, Japanese, Korean) need far fewer characters.
 */
const guidesI18n = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/guides-i18n' }),
  schema: guideSchema.extend({
    title: z.string().max(120),
    seoTitle: z.string().max(80).optional(),
    description: z.string().min(30).max(220),
    summary: z.string().min(30).max(600),
    /** The date of the English version this translation was made from. */
    translatedFrom: z.coerce.date(),
  }),
});

export const collections = { guides, guidesI18n };
