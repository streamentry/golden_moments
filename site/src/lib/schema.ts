import { SITE, absoluteUrl } from './site';

type Node = Record<string, unknown>;

export interface Crumb {
  href: string;
  label: string;
}

export interface FaqItem {
  q: string;
  a: string;
}

const ORG_ID = `${SITE.url}/#organization`;
const SITE_ID = `${SITE.url}/#website`;

/** Google resolves `@id` only within one page, so references also carry the name. */
const ORG_REF = { '@type': 'Organization', '@id': ORG_ID, name: SITE.name, url: SITE.url };

export function organization(): Node {
  return {
    '@type': 'Organization',
    '@id': ORG_ID,
    name: SITE.name,
    url: SITE.url,
    logo: absoluteUrl('/icons/icon-512.png'),
    email: SITE.supportEmail,
    publishingPrinciples: absoluteUrl('/editorial-policy/'),
    parentOrganization: { '@type': 'Organization', name: 'Cloudjet Solutions Pte. Ltd.' },
    sameAs: [SITE.appStoreUrl, SITE.playStoreUrl],
  };
}

export function website(): Node {
  return {
    '@type': 'WebSite',
    '@id': SITE_ID,
    name: SITE.name,
    alternateName: 'Dementia Activities Games',
    url: SITE.url,
    inLanguage: 'en-US',
    publisher: ORG_REF,
  };
}

export function breadcrumbs(items: Crumb[]): Node {
  const all = [{ href: '/', label: 'Home' }, ...items];
  return {
    '@type': 'BreadcrumbList',
    itemListElement: all.map((c, i) => ({
      '@type': 'ListItem',
      position: i + 1,
      name: c.label,
      item: absoluteUrl(c.href),
    })),
  };
}

export function faqPage(items: readonly FaqItem[]): Node {
  return {
    '@type': 'FAQPage',
    mainEntity: items.map((f) => ({
      '@type': 'Question',
      name: f.q,
      acceptedAnswer: { '@type': 'Answer', text: f.a },
    })),
  };
}

export interface ArticleInput {
  path: string;
  title: string;
  description: string;
  updated: Date;
  published?: Date;
  image: string;
  section: string;
  citations: { title: string; url: string }[];
  health: boolean;
}

export function article(input: ArticleInput): Node {
  return {
    '@type': input.health ? 'MedicalWebPage' : 'Article',
    '@id': `${absoluteUrl(input.path)}#article`,
    headline: input.title,
    description: input.description,
    url: absoluteUrl(input.path),
    mainEntityOfPage: absoluteUrl(input.path),
    image: absoluteUrl(input.image),
    dateModified: input.updated.toISOString().slice(0, 10),
    datePublished: (input.published ?? input.updated).toISOString().slice(0, 10),
    inLanguage: 'en-US',
    isAccessibleForFree: true,
    author: ORG_REF,
    publisher: ORG_REF,
    isPartOf: { '@id': SITE_ID },
    citation: input.citations.map((c) => ({ '@type': 'CreativeWork', name: c.title, url: c.url })),
    ...(input.health
      ? { audience: { '@type': 'Audience', audienceType: 'Caregivers and families' }, about: { '@type': 'Thing', name: input.section } }
      : { articleSection: input.section }),
  };
}

export interface GameInput {
  path: string;
  /** False for activities that are not games, such as a breathing pause. */
  isGame: boolean;
  name: string;
  description: string;
  image: string;
}

export function game(input: GameInput): Node {
  return {
    '@type': input.isGame ? ['VideoGame', 'WebApplication'] : 'WebApplication',
    '@id': `${absoluteUrl(input.path)}#game`,
    name: input.name,
    description: input.description,
    url: absoluteUrl(input.path),
    image: absoluteUrl(input.image),
    applicationCategory: input.isGame ? 'GameApplication' : 'LifestyleApplication',
    ...(input.isGame ? { genre: ['Casual', 'Puzzle'], gamePlatform: 'Web browser' } : {}),
    operatingSystem: 'Any',
    browserRequirements: 'Requires JavaScript',
    inLanguage: 'en-US',
    isAccessibleForFree: true,
    offers: { '@type': 'Offer', price: '0', priceCurrency: 'USD' },
    publisher: ORG_REF,
  };
}
