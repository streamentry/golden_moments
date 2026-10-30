# Content guide: dementiaactivities.games

This guide is for anyone writing pages for the website, human or agent. The
repository rules in `../AGENTS.md` and the voice rules in `../DESIGN.md` still
apply; this file adds what is specific to long-form web content.

## Who reads this site

- **Caregivers and family members** (the main searcher): busy, often anxious,
  usually on a phone. They want something to do *today* and plain answers.
- **Activity staff** in care homes, adult day programs and memory care.
- **Older adults** themselves, including people living with early dementia,
  who deserve to be addressed as adults, never talked down to.

Write for a US reader at about a grade 6–8 reading level. Short sentences,
concrete examples, no jargon. If a medical term is needed, explain it once.

## What we are, and what we are not

Golden Moments offers **simple shared activities, not a memory test, therapy
or medical advice**.

Never write, imply or let a heading suggest that:

- our games (or any game) treat, slow, reverse, cure or prevent dementia;
- any activity, food, supplement, fast or exercise "prevents" Alzheimer's;
- readers can diagnose, stage or score anyone;
- an activity "improves memory", "sharpens the brain", "trains" or "boosts"
  cognition, or produces "results";
- we are clinicians, or a page was reviewed by a named clinician (no one has).

Do not invent testimonials, quotes, statistics, studies, experts or reviews.
Every number must come from a cited source you actually opened.

Health and research pages (`section: brain-health`, and any page with
`health: true`) must:

- use risk language: "linked with", "associated with", "may lower risk",
  "research suggests", "the evidence is mixed";
- say plainly when evidence is weak, early, or mostly from animals;
- tell readers to talk with a doctor before changing diet, fasting,
  exercise, medicines or supplements, and to seek urgent help for sudden
  changes;
- note that people living with dementia often need *more* support with eating
  and drinking, so restrictive diets and fasting can be risky for them.

Words to avoid in our own claims: brain age, score, IQ, train your brain,
sharpen, boost, decline-proof, therapy (for our games), treatment, clinically
proven, miracle, cure, reverse, patients (say "people living with dementia").
You may use "prevent" or "prevention" only to describe what *research has
asked* ("Can dementia be prevented? What the research says"), never as a
promise.

## Voice

- Warm, plain, adult and respectful. "People living with dementia", "your
  mom", "the person you care for". Not "sufferers", "victims" or "elderly".
- Practical first: lead with what to do. Explanations come after.
- Dignity over correctness: in reminiscence, a pleasant conversation matters
  more than accurate facts. Never quiz ("Do you remember...?", "Who is
  this?"). Prefer open invitations ("Tell me about...", "What do you notice?").
- Stopping is fine. Every activity page should make it clear that ending early,
  changing plans, or just sitting together is a good outcome.
- No emoji, no exclamation-mark praise, no ALL CAPS, sentence-case headings.

## Legal and app help pages

`/app-privacy/` covers the mobile app; `/privacy/` covers this website. Keep
them separate. On every legal page:

- Name the publisher, Cloudjet Solutions Pte. Ltd., Singapore, and give the
  site contact address from `src/lib/site.ts`.
- The Apple Standard EULA covers the iOS app unless the App Store shows another
  license; Android follows Google Play's terms. Do not add a custom EULA,
  forced arbitration or a waiver of consumer rights.
- Describe only what the published app does. Say which version a feature
  arrived in, and keep originals, the app's copies and device backups distinct.
- Do not claim "Data Not Collected", complete deletion from backups or zero
  network traffic from source code alone.
- Never ask people to send photos, diagnoses or identity documents.

## Page format (Markdown + frontmatter)

Files live in `src/content/guides/<section>/<slug>.md`. The URL is
`/<section>/<slug>/`. Frontmatter is validated by `src/content.config.ts`:

```yaml
---
title: "Music Activities for People with Dementia"   # the H1, <= 80 chars
seoTitle: "Music Activities for Dementia: 25 Ideas"   # optional, <= 60 chars
description: "110–165 characters. A plain sentence that answers the search."
section: activities          # activities | caregiving | brain-health
order: 4                     # position in its section hub
updated: 2026-10-25
summary: >-                  # 80–420 chars. The direct answer, quoted by AI
  answer engines. Write it as a complete, self-contained answer.
keyPoints:                   # 3–6 short bullets, each a full idea
  - "..."
faq:                         # 2–6 real questions people search
  - q: "..."
    a: "Two to four sentences. Self-contained."
sources:                     # >= 1; only pages you actually opened
  - title: "Exact page title"
    publisher: "National Institute on Aging"
    url: "https://www.nia.nih.gov/..."
relatedGames: [picture-pairs, conversation-cards]   # see list below
related: [activities/music, caregiving/communication-tips]
health: false                # true shows the health-information notice
---
```

Body rules:

- Do **not** repeat the title as an H1. Start with a short intro paragraph,
  then `##` sections; use `###` below them. Nothing deeper.
- Use question-shaped `##` headings where they match real searches ("What
  activities help in late-stage dementia?"). Answer in the first sentence
  under the heading. This is what search and AI answer engines quote.
- Prefer numbered or bulleted lists of concrete ideas; each idea gets a bold
  name and one or two sentences of *how*, not just a noun.
- Use a table when comparing (stage, time needed, materials).
- Link generously to our games (`/games/<slug>/`) and other guides
  (`/<section>/<slug>/`) where it genuinely helps. Always end URLs with `/`.
- External links only to the sources you cite, written inline as
  `[NIA guidance on ...](https://...)`.
- Length: pillar pages 1,800–3,000 words; other pages 900–1,600 words.
  No filler, no "In conclusion", no restating the intro.
- Do not mention competitors' products by name, except factual, cited public
  records on a "how to choose" page.
- No images in Markdown (pages get illustrations from the layout).

## Game slugs you can link

| Slug | What it is |
| --- | --- |
| `picture-pairs` | Gentle matching pairs with large pictures; pictures can stay visible; 4–12 tiles; no timer or score |
| `find-the-same` | One picture at the top; tap the same one below (2–4 choices) |
| `shadow-match` | A soft shadow at the top; tap the picture that makes it (2–4 choices) |
| `sort-together` | Tap a picture, then the basket it belongs in (kitchen/garden and other themes) |
| `picture-puzzle` | A picture cut into 4 or 9 pieces; tap two pieces to swap them; the whole picture stays visible as a guide |
| `finish-the-saying` | Familiar American sayings with the last word missing; tap a choice or show the ending; a talking prompt follows |
| `word-search` | Large-print word search, words across and down only; printable |
| `coloring` | Tap a color, then a part of the picture; printable pages |
| `conversation-cards` | Picture cards with open, no-quiz conversation prompts by theme; printable |
| `photo-pairs` | Matching pairs made from photos you choose on your device; photos stay in the browser |
| `picture-bingo` | Printable picture bingo cards plus an on-screen caller, for groups |
| `calm-breathing` | A slow, quiet breathing pause to share, started and stopped by you |

## Sources we trust

Prefer, in order: National Institute on Aging (nia.nih.gov) and other NIH
pages, CDC, Alzheimer's Association (alz.org), Alzheimer's Foundation of
America (alzfdn.org), Family Caregiver Alliance, NHS, Alzheimer's Society
(UK), Mayo Clinic, Cochrane reviews, The Lancet Commission on dementia, peer
reviewed studies on PubMed/PMC, FTC. Open every URL before citing it; if it
does not load or does not say what you claim, do not cite it.
