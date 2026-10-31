# Golden Moments — pre-submission legal, privacy, and App Review gates

> **Moved 2026-10-25.** This checklist came from `streamentry/golden-moments-web`,
> now merged into `site/`. The legal pages are built from `site/src/pages/` for
> `https://dementiaactivities.games/` (`/app-privacy/`, `/privacy-choices/`,
> `/terms/`, `/safety/`, `/support/`, `/help/`, `/privacy/`, `/legal/`). The app
> (`lib/shared/utils/support_info.dart`, `lib/features/legal/`) and both store
> metadata files still point at the GitHub Pages URLs below, so keep that site
> up until they are switched. The record below is the 2026-10-18 evidence as it was.

**Prepared:** October 18, 2026  
**Owner:** Cloudjet Solutions Pte. Ltd. (publisher shown on the US App Store listing).  
**Status:** PUBLIC PAGES LIVE AND TECHNICALLY VERIFIED. APP/LEGAL RELEASE APPROVAL PENDING. This checklist is not legal advice or proof of regulatory clearance.

## Public URLs (externally verified October 18, 2026)

| App Store Connect purpose | Proposed URL | Required/optional | Status |
| --- | --- | --- | --- |
| App Privacy Policy URL | https://streamentry.github.io/golden-moments-web/app-privacy/ | Required | LIVE/HTTPS verified; native audit PENDING |
| Privacy Choices URL | https://streamentry.github.io/golden-moments-web/privacy-choices/ | Optional, recommended | LIVE/HTTPS verified |
| Support URL | https://streamentry.github.io/golden-moments-web/support/ | Required | LIVE/HTTPS verified; mailbox monitoring PENDING |
| Marketing URL | https://streamentry.github.io/golden-moments-web/ | Optional | LIVE/HTTPS verified |
| Terms / EULA information | https://streamentry.github.io/golden-moments-web/terms/ | Linked from app | LIVE/HTTPS verified; native link test PENDING |
| Safety information | https://streamentry.github.io/golden-moments-web/safety/ | Recommended | LIVE/HTTPS verified; legal review PENDING |
| Website privacy | https://streamentry.github.io/golden-moments-web/privacy/ | Website | PENDING deployment |

The legal pages were merged in [PR #4](https://github.com/streamentry/golden-moments-web/pull/4) at commit `8cbe11efa1cc68b9c0c0a4e68056fab800756436`. [GitHub Actions site checks](https://github.com/streamentry/golden-moments-web/actions/runs/39134721933) and [Pages deployment](https://github.com/streamentry/golden-moments-web/actions/runs/39134721872) both succeeded. An independent live HTTPS fetch on October 18, 2026 resolved all six exact listed pages and the `/legal/` and `/help/` routes. This verifies public page availability, **not** legal signoff, support-mailbox control, or native app compliance. Recheck final URLs before entering values into App Store Connect.

## Published App Store listing vs. next candidate

As observed on the US listing on October 18, 2026:
- Published title: **Golden Moments - Memento Maze**; subtitle: **The game that train your brain**.
- The description makes **brain-health / keep-your-mind-sharp** claims and contains apparently testimonial-style “Betty, 72” and “Michael, 45” quotes without evidence.
- Apple App Privacy label: **Data Not Collected**.
- Google Play's Data safety section currently declares **No data collected** and **No data shared**; audit the signed Android build before confirming those claims.
- Both published stores still make brain-health claims and include unverified testimonial-style quotes; correct both listings before release.
- Google Play's support email differs from the website's configured contact. Confirm ownership and monitor both mailboxes before store updates.
- Age rating **16+**, with **Advertising** and **Unrestricted Web Access** declared.
- Privacy link goes to **cschanhniem.github.io/TheOpenPath/golden-moments-privacy/**, not this website.
- Seller is **CLOUDJET SOLUTIONS PTE. LTD.**; copyright displays **© Hong Le 2025**.
- The 1.3.x features in the mobile repository are **not equivalent to an approved or published App Store release**. Family-photo features are release-gated.

**Before submission:** Remove unsubstantiated disease/cognitive benefits and invented testimonials from *all locales*, screenshots and metadata. Reconcile store title/subtitle/copyright with verifiable evidence. Check the declared age-rating characteristics against the submitted app binary. Do not simply reduce the age rating by assumption.

## Data inventory and actual binary audit

- [ ] Confirm which iOS/iPadOS binary, version/build, and countries are being submitted. Keep archived build ID and checksum.
- [ ] Inventory network endpoints, SDKs, iOS privacy manifests, required-reasons APIs, Android permissions and dependencies from the **built app**, not solely `pubspec.yaml`.
- [ ] Firebase Analytics, Firebase Core and Crashlytics remain in source dependencies; flags deactivating Analytics and disabling automatic Crashlytics are present. **No claim that these flags prove zero transmission**. Observe cold start, gameplay, picker, background/foreground, explicit external links and legacy upgrade under traffic capture.
- [ ] Map each actual transmission to provider, category, purpose, retention and disclosure. If data is collected by us or third parties under Apple's definition, correct the App Privacy label **before submission**. “Data Not Collected” is only acceptable if supported by evidence.
- [ ] Validate `PrivacyInfo.xcprivacy` presence/values for app and SDKs in the archive. Generate/review Xcode's aggregated privacy report and required-reasons APIs; avoid inventing reason codes.
- [ ] Confirm photo picker scope, imported copy location and deletion; test HEIC, iCloud-only photo, cancellation, upgrade, iPad/VoiceOver, denied access, no network, error recovery, backup expectations.
- [ ] Check all web/email links work on a physical iPhone and iPad, online; offline failures provide the URL/address instead of a blank screen.
- [ ] Confirm the web privacy notice accurately explains hosting/logs, that no third-party tracking scripts or uploader are added, and that URL redirects preserve HTTPS.
- [ ] Verify email provider/processor protections, retention and incident response before representing them publicly.

**No claim of encrypted vault, complete remote erasure, HIPAA compliance, certified therapeutic benefit or universal offline operation** without evidence. Operating-system backups, app offload, and imported photos remain distinct.

## Singapore privacy and US state health data

- [ ] Confirm Cloudjet Solutions Pte. Ltd. is the correct contracting legal entity and verify its required public **data protection officer (DPO) contact**, registered business/postal address where legally needed, and `apple@locuno.com` mailbox ownership/monitoring. Do not invent a postal address or name an unappointed DPO.
- [ ] Assign responsibility for responding to privacy requests, access/correction, erasure, and security incidents consistent with Singapore PDPA and applicable US law.
- [ ] **Avoid collecting, recording or inferring disease/health status** from actions, support or analytics. Review the broad definition of health data and inference under Washington's **My Health My Data Act**. If protected consumer health data is collected/processed, seek qualified counsel for specific consent, separate policy, rights and security requirements **before collection**, not after publication.
- [ ] Consider the FTC Health Breach Notification Rule only after evaluating applicability; do not assume HIPAA status or exemption merely because the app is recreational.
- [ ] Verify territories: US targeting alone does not limit App Store availability. If EU/UK/EEA distribution is enabled, check region-specific trader, privacy, consumer and regulated-medical-device declarations.
- [ ] Require counsel to review intended use with **dementia/Alzheimer's** in app metadata. Avoid “therapy,” “train your brain,” “diagnostic,” “slows progression,” or implied clinical study results. A disclaimer does not override functionality or marketing.

## Google Play and Android review gates

- [ ] Audit the signed Android app's SDK initialization, permissions, and network traffic. Align Google Play Data safety responses with the actual binary; do not reuse Apple's questionnaire answers.
- [ ] Correct brain-training and medical-benefit marketing and unverified testimonials in both store listings and all locales.
- [ ] Reconcile the Google Play and website contact mailboxes; establish an internal privacy-request and incident-response owner.
- [ ] Review Google Play privacy URL, deletion information, age rating, permissions, and relevant country availability.

## License, content rights, and presentation

- [ ] Keep **Apple Standard EULA** in App Store Connect unless legal counsel explicitly approves a custom EULA. A website Terms page does not replace a custom App Store license.
- [ ] Verify photo-pack images, classic trademarks, downloaded/embedded media, app logo, fonts and third-party code licenses, distribution rights and necessary attribution. The catalog's source-provenance register is a **starting point, not clearance**.
- [ ] Don't present original user-supplied family photos as company assets, use a real person's image in screenshots without consent, or use invented testimonials.
- [ ] Screenshots must come from the precise candidate build and reflect released capabilities. Link labels and web pages must accurately distinguish the published app from the candidate.
- [ ] Check App Store age-rating responses, medical-device declarations where applicable, accessibility statements, no hidden purchase terms, category and support URLs.

## App Review operational notes

1. **Contact:** An owner must verify that `apple@locuno.com` receives messages and responses; select the monitored address in App Store Connect.
2. **No account:** Describe the fact that there is no registration or test login; reviewer should be able to start the app immediately. Apple account-deletion rule for apps with account creation is not triggered by the documented no-account design; re-evaluate if accounts are added.
3. **Permissions:** Explain the optional user-selected photo picker in one concise sentence; don't request full library or health records unnecessarily.
4. **Privacy:** State precise results of native audit and third-party SDK inventory; do not simply repeat “Data Not Collected.”
5. **Medical:** Explain that the app provides recreational picture activities, not monitoring, testing, treatment or diagnosis; reviewer may access safety notice from in-app About/Privacy.
6. **Content rights:** Keep evidence ready and available in case Apple requests third-party-photo licensing proof.
7. **Distribution:** Set links only after HTTPS page checks, choose live support email and correct store listing.

## Required signoff (only public URL availability verified)

| Signoff | Evidence | Status |
| --- | --- | --- |
| Pages deployed and all six listed legal URLs serve publicly | CI deployment + live external fetch 2026-10-18 | **TECHNICALLY VERIFIED** |
| Verified legal entity / DPO contact / support mailbox | Company records + mailbox test | PENDING |
| Native SDK / traffic / permission audit | Attached test report | PENDING |
| App Store privacy nutrition label matches native data flow | App Store Connect screenshot/report | PENDING |
| Content license/attribution rights | Asset register + rights proof | PENDING |
| Product claims / age rating / regional obligations reviewed | Counsel & owner review | PENDING |
| In-app Privacy / Terms / Support links work on device | Physical device video or checklist | PENDING |
| Apple Standard EULA remains default | App Store Connect screenshot | PENDING |
| Published screenshots and copy align to actual shipped version | Store review | PENDING |

A CI pass, a GitHub merge, or this checklist **does not mean the app is legally safe or approved by Apple**.

## Primary official sources (checked 2026-10-18)

- [Apple App Review Guidelines, privacy 5.1 and health 1.4](https://developer.apple.com/app-store/review/guidelines/)
- [Apple App Review privacy requirements](https://developer.apple.com/app-store/review/)
- [Apple manage app privacy and third-party disclosures](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/)
- [Apple standard EULA and custom-EULA guidance](https://www.apple.com/legal/internet-services/itunes/dev/stdeula/) · [App Store Connect](https://developer.apple.com/help/app-store-connect/manage-app-information/provide-a-custom-license-agreement)
- [Privacy manifests and required-reason APIs](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files)
- [FDA 2026 general-wellness guidance](https://www.fda.gov/regulatory-information/search-fda-guidance-documents/general-wellness-policy-low-risk-devices)
- [FTC Health Breach Notification Rule](https://www.ftc.gov/business-guidance/resources/complying-ftcs-health-breach-notification-rule-0)
- [Washington My Health My Data Act](https://app.leg.wa.gov/RCW/default.aspx?cite=19.373)
- [Singapore Personal Data Protection Regulations 2021](https://sso.agc.gov.sg/SL/PDPA2012-S63-2021?WholeDoc=1)
- [Public US App Store listing, ID 6749312459](https://apps.apple.com/us/app/golden-moments-memento-maze/id6749312459)

- [Singapore PDPA — DPO designation and business-contact obligations](https://sso.agc.gov.sg/Act/PDPA2012?ProvIds=pr11-)
- [Google Play current public listing](https://play.google.com/store/apps/details?id=com.mindfulness.golden_moments)
