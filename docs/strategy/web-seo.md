**`DementiaActivities.games` is a good descriptive domain for a web-based games and activities library. I would use it at a reasonable registration and renewal price—but not pay a premium expecting an SEO advantage.**

Its strength is **explaining the category immediately**, rather than creating a distinctive brand.

## My assessment

| Dimension | Assessment |
|---|---|
| **Clarity** | Strong: “Dementia Activities” makes the intended audience and purpose explicit. |
| **Product fit** | Good for a website where visitors can immediately play games, explore photos, or start a shared activity. |
| **Readability** | Understandable, although “Dementia Activities dot Games” is slightly awkward to say aloud. |
| **Brand identity** | Less distinctive and less warm than “Golden Moments.” I would retain a separate product brand. |
| **Room to expand** | “Activities” gives you room beyond puzzles, but `.games` still frames the experience primarily as play. |

These are naming judgments—not measured conversion results.

## The SEO distinction that matters

**The `.games` ending does not give you an extra “games” keyword ranking advantage.** Google says keywords in a top-level domain do not provide an advantage or disadvantage in search. Its current SEO guidance also says generic domain extensions are not a reason to prefer one site over another. [Google for Developers](https://developers.google.com/search/blog/2015/07/googles-handling-of-new-top-level)

Similarly, having **“dementia activities” in the domain is not a shortcut to ranking for that phrase**. Google states that keywords in the domain name alone have hardly any ranking effect. [Google for Developers](https://developers.google.com/search/docs/fundamentals/seo-starter-guide)

So the reason to choose this domain is:

> **“A caregiver can understand what this website offers.”**

Not:

> “Google will rank it for dementia + activities + games because all three words appear in the address.”

## How I would use it

You do not need to choose between a descriptive domain and a warmer brand.

| Element | Proposed wording |
|---|---|
| **Domain** | `dementiaactivities.games` |
| **Brand / logo** | **Golden Moments** |
| **Homepage SEO title** | **Dementia Games & Activities Online \| Golden Moments** |
| **Main heading** | **Gentle Games & Activities for People with Dementia** |
| **Supporting text** | *Simple picture games, familiar photos, and activities to enjoy together—at your own pace.* |
| **Primary button** | **Play a Game** |

Use “Online” and “Play a Game” only once the browser experience actually works.

Keeping a distinctive brand also fits Google’s site-name guidance: it recommends a unique, concise name and warns that purely generic names may not be selected as the displayed site name. That is separate from the page’s SEO title. [Google for Developers](https://developers.google.com/search/docs/appearance/site-names)

## The main weakness: “activities” is broader than “games”

Dementia activities can include music, art, household tasks, and other shared experiences—not just digital games. The Alzheimer’s Association’s activity guidance reflects that broader scope. [Alzheimer’s Association](https://www.alz.org/help-support/caregiving/daily-care/activities)

**My concern is a possible expectation mismatch:** someone might arrive seeking printable or offline activities, while `.games` suggests immediate interactive play. That is a hypothesis to test, not a demonstrated problem with this domain.

For your proposed web-and-mobile product, I would resolve it by making **playable games the primary experience**, with supporting caregiver activity ideas—not building a large article library that eventually pushes visitors toward an app.

**My decision:** use `DementiaActivities.games` if it is inexpensive and browser-based play is central. At comparable cost, I would prefer `DementiaActivities.com` for a broader activities resource, but I would not delay launching or spend heavily to obtain it.

**Availability, renewal pricing, and trademark clearance remain unverified.** Before committing, show the address to five caregivers and ask what they expect to find; that will reveal more about its practical value than further keyword-name brainstorming.

## Keyword-to-page map (2026-10-25)

One page owns each search intent, so pages do not compete with each other.
These are target queries, not measured volumes: no search-volume or ranking
data has been collected yet (see `keyword-research.csv`). After Search Console
is verified, replace guesses with impressions and positions per page.

| Search intent | Page that owns it |
| --- | --- |
| dementia games, dementia and Alzheimer's games and activities | `/` (home) |
| free dementia games online, Alzheimer's games online | `/games/` |
| alzheimers activities, alzheimers games, activities for Alzheimer's patients | `/activities/alzheimers/` |
| activities for dementia, things to do with someone with dementia | `/activities/ideas/` |
| early, middle, late stage dementia activities | `/activities/early-stage/`, `/middle-stage/`, `/late-stage/` |
| memory games for seniors, senior matching games | `/activities/memory-games/` |
| trivia for seniors with dementia | `/activities/trivia/` |
| puzzles or jigsaw puzzles for dementia | `/activities/puzzles/` |
| printable dementia activities | `/activities/printable/` |
| group activities for memory care or nursing homes | `/activities/care-home-groups/` |
| matching game for dementia | `/games/picture-pairs/` |
| family photo memory game | `/games/photo-pairs/` |
| large print word search | `/games/word-search/` |
| do brain games prevent dementia | `/brain-health/brain-games/` |
| dementia keeps asking to go home, what to say when they want to go home | `/caregiving/asking-to-go-home/` |
| dementia repeating questions, asks the same question over and over | `/caregiving/repeated-questions/` |

Searches that use "patients" are answered in our own words ("people living
with dementia"), per `site/CONTENT_GUIDE.md`. In October 2026 the US results for
printable, memory-game and trivia queries were dominated by scraped pages with
no usable content, which is why those pages exist.

## AI answer engines and app installs (2026-10-30)

The owner reports a lot of traffic from ChatGPT. On 2026-10-30, OAI-SearchBot, ChatGPT-User, GPTBot, Bingbot, PerplexityBot and ClaudeBot all received HTTP 200 from the live site, and `robots.txt` allows everything, so nothing is blocked.

The gap was conversion: no game page linked to the app, and guides ended with a band that keeps people in the browser. Changes:

- `site/src/lib/app.ts` holds the app facts once (summary, features, requirements, FAQ). Describe only released features; keep it in step with `metadata/app-store.en-US.json`.
- `AppCta` sits on every game page (a sidebar box, plus a band after the copy) and on every guide and section page. Photo pairs has its own wording.
- Each game's FAQ and FAQPage data now answers "Is there an app version of this game?" honestly: yes only for Picture pairs and Photo pairs.
- `/app/` carries full `MobileApplication` data and a six-question FAQ. `llms.txt` and `llms-full.txt` lead with an app section and both store links.
- The apps checklist guide now discloses our own app in "Where does Golden Moments fit?".

Still for the maintainer:

1. **Bing Webmaster Tools:** verify the site and submit `sitemap.xml` (the index of every language's sitemap). ChatGPT search draws on Bing's index; IndexNow pings alone do not show coverage or queries.
2. **Install attribution:** App Store Connect › App Analytics › Campaigns gives a provider token (`pt`). With it, store links can carry `ct=web` (or `ct=chatgpt` on pages ChatGPT sends people to), so installs from the site become visible. Without it, site-to-install is unmeasured.
3. **GA4:** compare sessions with source `chatgpt.com` against outbound clicks to apps.apple.com and play.google.com, to see whether the new app links convert.
