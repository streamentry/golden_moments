# dementiaactivities.games

The Golden Moments website: free, gentle browser games and caregiver guides.
Astro (static output) with React islands for the games, TanStack Store for game
and settings state, served by Cloudflare Workers Static Assets.

Read `../AGENTS.md` and `../DESIGN.md` first; they apply here too. Content
rules are in [`CONTENT_GUIDE.md`](CONTENT_GUIDE.md).

## Run it

Node is pinned to 24 by `devEngines.runtime` in `package.json`; pnpm downloads
it into `node_modules`, so your global Node version does not matter.

```sh
pnpm install
pnpm dev                 # http://localhost:4321
pnpm test                # game logic unit tests (Vitest)
pnpm build               # static site in dist/
pnpm check:site          # links, titles, descriptions, JSON-LD, alt text, claims wording
pnpm preview             # serves dist/ with the real Workers runtime, headers and 404
```

`pnpm verify` runs tests, build and checks together; CI runs the same steps in
`.github/workflows/site.yaml`.

## Layout

| Path | What it is |
| --- | --- |
| `src/pages/` | Routes: home, `games/`, `[section]/` guides and hubs, legal pages, `robots.txt`, `llms.txt`, `llms-full.txt`, manifest, `pictures/[id].svg` |
| `src/content/guides/<section>/*.md` | The 35 guides. Frontmatter is validated by `src/content.config.ts` |
| `src/games/` | One React island per game, plus `shared/` (frame, tiles, chips, settings store, sound) |
| `src/lib/games/` | Pure game logic with unit tests (`games.test.ts`) |
| `src/data/` | Game registry, picture library, sayings, conversation prompts, word themes, coloring pages |
| `src/lib/schema.ts` | JSON-LD builders (WebSite, Organization, Article/MedicalWebPage, FAQPage, VideoGame, BreadcrumbList) |
| `src/styles/` | Tokens from `DESIGN.md`, base, components and game styles. Light theme only |
| `public/` | Fonts, icons, share images, `_headers` (security and cache headers) |
| `scripts/` | `check-site.mjs` (post-build checks) and `make-images.py` (icons and share images) |

## Rules that are easy to break

- **Two CSPs apply.** Astro emits a hash-based `<meta>` policy for scripts and
  styles; `public/_headers` adds a response policy that allows network
  requests only to this site. Keep both when adding features.
- **No inline `style` attributes.** The build emits a hash-based Content
  Security Policy, which blocks them. Use a class or a `data-` attribute.
  `check-site.mjs` fails the build if one appears.
- **Every picture is drawn in `src/data/pictures.ts`.** Do not add third-party
  images without recording their rights. The app's catalog photos are not
  cleared for the website.
- **No analytics, ads, cookies or tracking.** The privacy page says so. Adding
  any would need a documented decision and a privacy-page update first.
- **No timers, scores, streaks or quizzing**, in games or copy. Health pages use
  risk language and cite sources; see `CONTENT_GUIDE.md`.
- **Photo pairs never uploads.** Photos become object URLs in the tab only.

## Share images and icons

After changing pictures, game titles or the brand mark, regenerate (macOS only,
uses Quick Look and Pillow):

```sh
pnpm build
pnpm exec node scripts/og-games.mjs   # refresh titles and pictures from src/data/games.ts
python3 scripts/make-images.py
```

## Deploy (Cloudflare Workers)

Deploying is a maintainer action; nothing here deploys automatically.

Live since 2026-10-25 at <https://dementiaactivities.games> on the RunLumi
Cloudflare account. The `workers.dev` address is turned off.

- **Site:** `pnpm deploy` (build, checks, then `wrangler deploy`) while logged
  in with `pnpm exec wrangler login`. `wrangler.jsonc` attaches the apex as a
  Workers custom domain.
- **www:** `redirect-www/` is a separate tiny Worker on
  `www.dementiaactivities.games` that 301-redirects to the apex, keeping path
  and query. Deploy it with `cd redirect-www && ../node_modules/.bin/wrangler deploy`
  (only needed if it changes).
- **No injected scripts:** `Cache-Control: no-transform` in `public/_headers`
  stops Cloudflare from injecting its Web Analytics beacon, and the CSP would
  block it anyway. Keep both.

Still to do in the Cloudflare dashboard (the Wrangler login cannot change zone
settings):

1. SSL/TLS, Edge Certificates: turn on **Always Use HTTPS** (plain
   `http://` currently serves the page instead of redirecting).
2. Web Analytics: turn off automatic setup for the zone, so nothing tries to
   inject a beacon.
3. Email Routing: route `web@dementiaactivities.games` to a real inbox.
4. Verify the domain in Google Search Console and Bing Webmaster Tools and
   submit `https://dementiaactivities.games/sitemap-index.xml`.

Nothing runs server side: Workers serves the static files in `dist/`, applies
`public/_headers`, redirects to trailing-slash URLs and serves `404.html`.
