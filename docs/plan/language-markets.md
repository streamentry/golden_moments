# Language markets

Researched 2026-10-30 and 31. iOS shares are StatCounter mobile OS for
September 2026. Dementia counts are the latest national or Alzheimer's Disease
International member figures found; "est." is arithmetic from a prevalence rate,
not a published count; "snippet" means seen only in a search excerpt. These
numbers rank effort; they are not install forecasts, and App Store demand for
the activity job remains unmeasured in every market until the worksheet in
`docs/strategy/keyword-research.csv` has rows for it.

## 1. Candidate languages

<!-- cspell:disable -->
| Language (storefronts) | People living with dementia | iOS share | Store spend signal | Naming and stigma |
| --- | --- | --- | --- | --- |
| English (US, UK, CA, AU; en-GB is an indexed language in 172 of 175 storefronts) | US 7.2M with Alzheimer's dementia aged 65+, 11.5M unpaid caregivers ([Alzheimer's Association 2025](https://www.alz.org/getmedia/c05f7ba4-9aea-4cb0-8898-5e8bff3f0930/executive-summary-2025-alzheimers-disease-facts-and-figures.pdf)); UK 982k ([Age UK 2025](https://www.ageuk.org.uk/siteassets/documents/reports-and-publications/reports-and-briefings/age-uk-parliamentary-briefing---dementia-care-june-2025.pdf)); Canada 600-650k ([Alzheimer Society](https://alzheimer.ca/landmark-recommendations)); Australia 433k ([Dementia Australia 2025](https://dementia.org.au/sites/default/files/2025-02/Prevalence-Data-2025-All-forms-of-dementia.pdf)) | US 53.5%, UK 47.0%, CA 64.9%, AU 62.6% | US first at about $59B of $167B gross in-app spend in 2025 ([Sensor Tower](https://sensortower.com/blog/state-of-mobile-2026)) | *Dementia* is neutral in all four. Shipped |
| Japanese (JP) | 4.71M aged 65+ in 2025 plus 5.64M with MCI (MHLW research, [press](https://www.asiae.co.kr/en/article/2024050818024040711)) | 60.5%, the highest of any large market | Third by revenue in 2024 | 痴呆 was replaced by 認知症 in 2004; residual family stigma ([PMC7994709](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7994709/)). 認知症 is acceptable; never 痴呆 or ボケ. Local listings sell 予防 (prevention), which we will not claim |
| Chinese, Traditional (TW, HK; also indexed in US) | Taiwan over 270k ([MOHW](https://mohw.gov.tw/cp-16-44009-1.html)); Hong Kong not found | TW 51.6% | not found | Taiwan uses 失智症 (criticized as "loss of wisdom", rename debated, not adopted, [The News Lens](https://www.thenewslens.com/article/87579)); Hong Kong uses 認知障礙症 or 腦退化症 |
| Chinese, Simplified (indexed in US and two other storefronts; mainland blocked) | 16.9M (2021 data, official 2024 report, [China Daily](https://govt.chinadaily.com.cn/s/202501/06/WS677b4dc8498eec7e1f72c743/china-launches-action-plan-to-tackle-dementia-amid-aging-population-challenge.html)) | 32.1% | Second at $22.1B in 2025, iOS only | Colloquial 老年痴呆 ("senile idiocy") is stigmatizing; a 2012 rename campaign stalled; 认知障碍症 proposed in 2025, not adopted. Mainland availability needs an ICP filing through a Chinese entity (section 2); value is the diaspora through other storefronts |
| German (DE, AT, CH) | 1.8M at end of 2023 ([DAlzG](https://www.deutsche-alzheimer.de/fileadmin/alz/pdf/factsheets/infoblatt1_haeufigkeit_demenzerkrankungen_dalzg.pdf)) | 27.7% | A leading Western Europe growth market (Sensor Tower) | *Demenz* is neutral; *Beschäftigung für Menschen mit Demenz* is the phrase. German is indexed in only 4 storefronts |
| Spanish (es-MX is primary in 16 storefronts and additional in the US; es-ES for Spain) | Mexico 1.3M ([INGER plan 2024](https://www.unotv.com/salud/100-mil-pesos-al-ano-el-costo-oculto-del-alzheimer-80-de-los-pacientes-reciben-atencion-en-su-propio-hogar/)); Spain 984k, CEAFA says 5M affected including family carers ([CEAFA](https://www.ceafa.es/files/2024/09/0409-ceafa-campana-dmundial-alzheimer-2024.docx)) | MX 28.0%, ES 26.9% | low per-capita spend; es-MX also reaches US Spanish searches | *Demencia* is clinical but usable; searches center on *alzhéimer* |
| French (FR, CA-fr, BE, CH; indexed in 32 storefronts) | France 1.0-1.4M, "3 million concernés" with carers ([France Alzheimer](https://www.iledefrance.fr/toutes-les-actualites/septembre-mauve-un-mois-de-sensibilisation-contre-la-maladie-dalzheimer)) | FR 34.7%, CA 64.9% | Western Europe growth market | *Démence* is avoided in public copy; use *maladie d'Alzheimer et maladies apparentées* or *troubles cognitifs* |
| Korean (KR; also indexed in US) | about 1M aged 65+ ([Korea Times 2025](https://www.koreatimes.co.kr/amp/southkorea/health/20250312/number-of-koreas-dementia-patients-nears-1-million-as-population-ages)); 70+ smartphone ownership 76.3% (snippet) | 37.9% | high-ARPU, no 2025 rank found | 치매 is explicitly stigmatized: 43.8% dislike it in a 2023 ministry survey; a 2025 bill proposes 인지저하증, not enacted as of September 2025 ([Dailypharm](https://m.dailypharm.com/user/news/7583)). Do not title the app 치매 게임 |
| Portuguese, Brazil (BR; also indexed in US) | about 1.8-2.7M ([Renade via Brasil61](https://brasil61.com/n/mais-de-2-milhoes-de-brasileiros-vivem-com-alguma-forma-de-demencia-bras227264)) | 20.8% | Third by downloads in 2025, low spend | *Demência* acceptable; *Alzheimer* dominates search. Portugal (238k, iOS 32.5%) is a separate pt-PT locale |
| Italian (IT, CH) | 1.48M ([Federazione Alzheimer Italia 2024](https://www.quotidianosanita.it/studi-e-analisi/giornata-mondiale-alzheimer-nel-mondo-mln-di-persone-con-demenza-quasi-sono-italiani-raddoppieranno-in-pochi-anni/)); about 4M caregivers | 36.6% | mid-tier | *Demenza* neutral; marketing uses *Alzheimer*; *giochi per anziani* is the live phrase |
| Arabic (17 storefronts including US; SA, AE, EG) | Middle East and North Africa about 3M in 2019, rising to about 14M by 2050 ([GBD via The National](https://www.thenationalnews.com/world/2022/01/06/middle-east-faces-surge-in-dementia-as-population-gets-older)) | SA 51.2%, EG 16.6% | Gulf is high-ARPU | الخرف is stigmatized; public copy uses الزهايمر. Right-to-left work required |
| Vietnamese (VN; also indexed in US) | est. about 540k (weak) | 40.2% | low spend | *Sa sút trí tuệ* is clinical; families say *Alzheimer* or *lẫn*. Roboto covers the diacritics; the Fraunces subset does not |
| Polish, Dutch, Turkish, Russian | PL 618k, NL 313k (Alzheimer Europe 2025 via aggregator); TR est. 720k; RU est. 1.6M (weak) | PL 36.3%, NL 31.9%, TR 23.0%, RU 26.5% | small; Russian payments restricted | Dutch and Polish terms neutral; Turkish *bunama* is stigmatized, *demans* is not |
| Hindi and Indic (IN storefront default en-GB plus 11 Indic locales) | 8.8M aged 60+ ([LASI-DAD](https://www.iipsindia.ac.in/sites/default/files/66_AlzheimerPrevalence_of_dementia_in_India.pdf)) | 6.0% | First by downloads, not in the top 20 by spend | Hindi search content is essentially absent; English already reaches India's iOS users |

<!-- cspell:enable -->
Caregiver smartphone adoption at ages 45 to 65 is at or above 90% everywhere
measured. Older adults: US 65+ 79% ([Pew 2026](https://www.pewresearch.org/internet/fact-sheet/mobile/)); Japan 60s 88.6%, 70s 68.1% (MIC 2025, snippet); UK 65+ 67% (Age UK and Ofcom 2025); Germany 65-74 about 64% (Bitkom, snippet).

The researcher's suggested order for an iOS-first free app was English, Japanese,
Chinese Traditional, German, Spanish (Mexico), French, Korean, Chinese Simplified
for the diaspora, Portuguese (Brazil), Italian, then Arabic if right-to-left work is
budgeted. [The plan](README.md) moves Spanish and Vietnamese earlier for the US
bilingual-family case and review cost, and keeps the rest.

## 2. Store localization mechanics

**Apple.** 50 localizations. Each storefront has a default language plus
additional languages whose metadata is shown and whose keywords are searchable
there ([Apple reference](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations)):

- US: en-US plus Arabic, Chinese Simplified, Chinese Traditional, French, Korean,
  Portuguese (Brazil), Russian, **Spanish (Mexico)** and **Vietnamese**. So a
  localization for a diaspora language adds a searchable 100-byte keyword field in
  the US store.
- Canada: en-CA plus fr-CA. UK: en-GB only. Australia: en-AU plus en-GB.
- Japan: Japanese plus en-US. Korea, mainland China, Taiwan, Hong Kong, Germany,
  France, Italy, Netherlands, Portugal, Poland, Brazil, Mexico and Russia: the local
  language plus en-GB.
- India: en-GB plus 11 Indic languages. Indonesia, Vietnam, Türkiye, Egypt, Saudi
  Arabia and UAE: en-GB default, local language additional.
- Primary-language metadata is the fallback; description and keywords are not
  copied when a locale is added; the binary must list its languages in Xcode
  ([Apple](https://developer.apple.com/help/app-store-connect/manage-app-information/localize-app-store-information)).
- Vendor measurement (September 2026, 175 storefronts): en-GB indexed in 172,
  French 32, es-MX 19, Arabic 17, German 4, zh-Hant 4, zh-Hans 3, Korean 2,
  pt-BR 2, Vietnamese 2, Japanese 1 ([ASO Agency](https://asoagency.io/blogs/which-languages-to-localize-app-first)).
  Keywords combine only within one locale (vendor claim, [AppTweak](https://www.apptweak.com/en/aso-blog/how-to-benefit-from-cross-localization-on-the-app-store)).

Practical consequences: an en-GB localization with UK wording (*carer*, *dementia
activities*) is nearly free and is read in most non-English storefronts; es-MX is
free extra US keyword space; every diaspora language in the US list serves two
audiences with one translation.

**Mainland China.** Apple's status reference lists "ICP Filing Number Missing" (MIIT
filing, all apps) and "Missing Game registration number" (NPPA) ([Apple](https://developer.apple.com/help/app-store-connect/reference/app-information/app-and-submission-statuses)).
Third-party sources date the ICP filing requirement to September 2023 for new apps
and say free games without purchases are not asked for an NPPA number in practice
while all games legally need a license ([AppInChina](https://appinchina.co/blog/how-to-make-money-in-china-from-free-mobile-games/), snippet-level).
The ICP filing needs a Chinese entity or agent, so mainland availability is
excluded; zh-Hans is used for the US and other overseas storefronts only.

**Google Play.** 86 language entries. Play machine-translates listings for ten
languages (ar, fr-FR, de, id, it, ja, pt-BR, es-419, es-ES, th) and shows an
automated translation with a notice where no translation exists; screenshots
stay in the default language unless localized ([Google](https://support.google.com/googleplay/android-developer/answer/9844778)).
A supplied translation therefore replaces a machine one that users already see.

**Flutter.** `flutter_localizations`, `intl` and ARB files through `gen-l10n` are
the documented standard; Chinese scripts use a locale with the script code `Hans` or `Hant`; text direction comes from `GlobalWidgetsLocalizations`
([Flutter docs](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)).
Repository state: `l10n.yaml` and `app_en.arb` exist with one template string;
a regex estimate found roughly 300 to 400 hardcoded literals, about 2,400 words,
in `lib/`, plus about 500 words in the canonical store metadata. Extraction to ARB
precedes any translation.

**Cost.** Human translation per source word in 2026 (Alconost, 3,200 projects):
German $0.11, French $0.10, Japanese $0.14, Chinese Simplified $0.10, Korean
$0.10, Arabic $0.09, Portuguese (Brazil) $0.08, Italian $0.08, Spanish $0.08,
Vietnamese $0.09; machine translation with human editing about $0.06-0.12;
linguistic QA $32-48 an hour ([Alconost](https://alconost.com/en/blog/localization-cost)).
Order of magnitude: 3,000 words times nine languages at about $0.10 is about
$2,700 for human translation before QA and screenshots. An estimate, not a quote.

## 3. Typography and right-to-left

Checked locally on the bundled fonts: Roboto Regular maps 896 code points and
covers Vietnamese, Cyrillic, Greek, Polish and Turkish letters; it has no Arabic,
Hebrew, CJK, Hangul or Devanagari. Fraunces Bold is a 224-code-point Latin subset
with no Vietnamese, Polish, Turkish or Cyrillic letters. `gmDisplayFontFamily`
already sets `fontFamilyFallback: [Roboto]` (`lib/design_system.dart`), so those
headlines fall back to Roboto silently; Flutter then falls back to the platform
font when every listed family lacks a glyph ([API](https://api.flutter.dev/flutter/painting/TextStyle/fontFamilyFallback.html)),
so Japanese, Chinese, Korean and Arabic render in system fonts on iOS and Android.
The web build is separate and would need Noto fallbacks (unverified).

Arabic and Hebrew: mirroring through `Directionality`; replace `Alignment.centerLeft`
and `EdgeInsets.only(left:)` with the directional variants; Arabic needs a taller
line height and must never be letter-spaced. CJK: no word spacing; Korean and
German labels run about 30% longer; Traditional and Simplified need separate ARB
files and script-coded locales. Turkish casing must avoid `toUpperCase()` on İ/ı.
"Never ALL CAPS" is moot for CJK.

<!-- cspell:disable -->
## 4. Distribution partners

Alzheimer's Disease International member associations, one per country
([list](https://www.alzint.org/our-members/member-associations/)): US Alzheimer's
Association; UK Alzheimer's Society; Alzheimer Society of Canada; Dementia
Australia; Japan 公益社団法人認知症の人と家族の会 (Kyoto); Alzheimer's Disease Chinese;
Taiwan TADA; Hong Kong HKADA; Deutsche Alzheimer Gesellschaft (publishes the free
"Alzheimer & YOU" app); France Alzheimer et maladies apparentées; Spain CEAFA;
Mexico FEDMA; Brazil Febraz (ABRAz is the older association); Federazione Alzheimer
Italia; Alzheimer Nederland; Portugal Obras Sociais Viseu (Alzheimer Portugal is the
larger charity, not verified); Polish Alzheimer's Association; Alzheimer's
Indonesia; Vietnam VIOBA; Turkish Alzheimer Association; Egyptian Alzheimer
Society; Saudi Alzheimer's Disease Association; India ARDSI. Korea has no ADI
member listed; the government 중앙치매센터 and the 치매안심센터 network are the
practical channels.

## 5. Local search phrases (observed in local content; volumes not measured)

- Japanese: 認知症 アプリ, 認知症 ゲーム 高齢者, 回想法 アプリ, 脳トレ 高齢者, 家族 介護 アプリ.
- Korean: 치매 어르신 게임, 기억력 게임 어르신, 회상 활동; 치매 예방 앱 carries a prevention claim to avoid.
- Chinese Traditional: 失智症 遊戲, 長輩 遊戲 app, 懷舊治療. Simplified: 认知症 游戏, 阿尔茨海默 游戏; 老年痴呆 游戏 is high-volume and stigmatizing.
- German: Demenz Spiele, Beschäftigung für Menschen mit Demenz, Gedächtnistraining Senioren, Demenz App Angehörige.
- Spanish: juegos para personas con alzhéimer, actividades para personas con demencia, estimulación cognitiva mayores, app cuidadores alzhéimer.
- French: jeux pour personnes atteintes d'Alzheimer, activités Alzheimer, stimulation cognitive seniors, application aidants.
- Italian: giochi per anziani con demenza, attività per malati di Alzheimer.
- Portuguese (Brazil): jogos para idosos com demência, atividades para Alzheimer, estimulação cognitiva idosos.
- Arabic: ألعاب لمرضى الزهايمر, أنشطة لكبار السن, تطبيق الزهايمر.
- Vietnamese: trò chơi cho người sa sút trí tuệ, hoạt động cho người bệnh Alzheimer, trò chơi cho người cao tuổi.
- Hindi: searches return English-only content.

Name implication: *Dementia Games* translates cleanly to German, Dutch, Italian
and Japanese; it is stigmatizing or off-trend in Korean, colloquial Simplified
Chinese and Arabic; and under-indexed in French, Spanish and Portuguese, where
searchers type *Alzheimer*. Keep *Golden Moments* as the device label and lead
the local subtitle and keywords with the local Alzheimer or activities phrase.

<!-- cspell:enable -->
## 6. Not verified

Per-country App Store revenue ranks beyond the US and China; Alzheimer Europe
2025 country rows (aggregator); Russia, Türkiye, Vietnam, Indonesia and Egypt
counts (rate times population); caregiver counts outside the US, UK and Spain;
Japan, Korea, Germany and EU age-group smartphone rates (snippets); Apple's live
help text on the China game-license exemption; the within-locale keyword rule
(vendor claim); Fraunces upstream coverage; Flutter web font fallback; the Korean
and Taiwanese rename status after 2025.
