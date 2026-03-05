---
stepsCompleted: [1, 2, 3, 4, 5, 6]
inputDocuments: []
date: 2026-03-01
author: Vishnu
---

# Product Brief: doclyzer

<!-- Content will be appended sequentially through collaborative workflow steps -->

---

## Executive Summary

Doclyzer is a product of **Envsoft Solutions LLP**. It is a patient-facing SaaS that lets users store, organise, and understand their medical reports. Users can create **patient profiles** (e.g. Self, family members) and upload reports per profile; each profile has its own timeline, charts, summaries, and share links. A Flutter app and NestJS backend provide upload (PDF), parsing (e.g. Docling), structured storage, trend charts (especially for blood/lab), AI summarisation and insights (including lifestyle and natural remedy suggestions), and chat over report history. Users can share selected report history via a public-style link that opens a web page (not the app). Initial focus: India, USA, and Europe, with PDF-first support and later consideration of regional formats and FHIR.

---

## Core Vision

### Problem Statement

Patients accumulate scattered medical reports (labs, imaging, discharge summaries) in PDFs and paper. They struggle to see trends (e.g. Hb over time), get a clear summary, or share a coherent history with a new doctor. Existing solutions are either doctor-centric EHRs or simple cloud storage without structure, charts, or AI.

### Problem Impact

Without organisation and insight: missed trends, repeated tests, poor handoffs between doctors, and anxiety from not understanding results. Sharing is ad hoc (emailing PDFs or handing over paper).

### Why Existing Solutions Fall Short

- Cloud drives: store files but no parsing, no charts, no AI, no shareable “report pack.”
- Some health apps: tied to one region, one lab, or one EHR; not patient-owned and multi-source.
- No single place that combines: multi-report upload, structured + chartable data, AI summary and chat, and a share link that renders as a clean web page.

### Proposed Solution

- **Store:** Upload PDF reports (and later other formats); parse with Docling (and/or complementary tools) into structured data where possible (labs) and “document + metadata + summary” for imaging and narrative reports. **Capture only real report data:** Many PDFs include promotions, general info, or cover pages. Parsing must **skip non-report content** and extract only the actual report: lab tables, imaging findings/impression, dates, facility. Use layout detection (tables, "Result"/"Findings" sections) to identify report body; ignore marketing and boilerplate. Stored summary and extracted data = clinical report content only.
- **Organise:** Timeline of reports; blood/lab parameters as chartable time series (with normalisation of test names and units); imaging (X-ray, MRI, CT, USG) as dated events with findings text and optional severity.
- **Insight:** AI summarisation, trend highlights, and chat over the user’s report history. **Lifestyle and natural-healing suggestions** are an explicit product requirement: AI should suggest evidence-informed lifestyle changes (diet, exercise, sleep, stress management) and complementary/natural approaches (e.g. yoga, breathing, herbs/supplements where appropriate) based on the user’s report data—always with clear disclaimers (not medical advice; region-specific where needed).
- **Multi-profile (patient profiles):** A user can create and manage **patient profiles** (e.g. “Me”, “Mom”, “Dad”, “Child”). Each profile has its own reports, timeline, charts, summaries, and share links. On upload, the user assigns the report to a profile. All features (trends, AI, share) operate in the context of the selected profile. Report caps and share-link limits apply per account (see Monetization plans); Family tier supports more profiles and higher caps.
- **Share:** User selects a **profile** (or “pack” of reports from that profile) → backend generates a share token → link opens a **web page** (not the Flutter app) showing that profile’s shared reports, summaries, and charts (e.g. Hb trend). Access control: optional expiry and optional password; consent and revoke.
- **Platform:** Flutter app (mobile, possibly web later); NestJS backend; share experience as a separate web app (e.g. React/Next) that consumes a share API.
- **AI / model strategy:** All AI-related tasks (PDF parsing, summarisation, chat, lifestyle suggestions) use **Hugging Face** ([huggingface.co/models](https://huggingface.co/models)) or other **open-source models** (e.g. Docling for document parsing). Models run on a **local server instance** (e.g. in **Docker**) rather than third-party SaaS where possible—Docling or alternative parsers and any LLM/embedding models are deployed as services the NestJS backend calls internally. This keeps data on your infrastructure, supports swapping models (e.g. different Hugging Face models per task), and avoids vendor lock-in.

### Report Types (and What You Might Have Missed)

- **Blood / lab (must-have):** Full structured extraction; charts; reference ranges (including age/sex where applicable); unit and test-name normalisation; duplicate detection (same PDF/content).
- **Imaging (X-ray, MRI, CT, USG, etc.):** Treat as document-type: type, date, facility, body part, indication, impression/findings (text). No “values” to chart; show as timeline of events and link to PDF. Optional: severity/urgency if parseable.
- **Other:** Pathology, discharge summaries, prescriptions: document + metadata + summary first; more structure later.
- **Gaps to include in scope:** (1) Reminders / follow-up (e.g. “Retest in 3 months”), (2) Compare with prior (e.g. “Compare with previous CT”), (3) Export (PDF summary / printable report pack), (4) Offline / low-connectivity cache, (5) Consent and sharing audit, (6) Disclaimers (not medical advice; region-specific for lifestyle/natural remedies), (7) Data deletion and portability (GDPR/CCPA). *(Multi-profile is a core feature above.)*

### Observability, analytics & growth

- **Crashlytics:** Integrate **Firebase Crashlytics** (or equivalent) in the Flutter app for crash and non-fatal error reporting; ensure no PHI is sent in logs or custom keys (anonymised or aggregate only).
- **App analytics:** Use **Firebase Analytics** (or similar) for usage analytics: screen views, funnel events (signup → profile creation → first upload → first share), retention; strict **no PHI** in event names or parameters—only product events (e.g. "report_uploaded", "share_link_created") and anonymised identifiers. Comply with app-store and regional rules (e.g. GDPR consent for analytics where required).
- **Landing page SEO:** Public marketing/landing site (e.g. doclyzer.com) must be **SEO-friendly**: semantic HTML, meta title/description, Open Graph/Twitter cards, structured data (e.g. Organization, WebApplication), fast load, mobile-friendly; target keywords (e.g. "medical report organizer", "share lab reports with doctor", "health report storage"). Sitemap and robots.txt; consider a blog or help section for long-tail content.
- **Legal pages:** **Terms and Conditions**, **Privacy Policy**, and **Refund Policy** must be published and linked from the app (e.g. signup, settings, footer) and from the landing page (footer). Drafts live in `docs/legal/` (terms-and-conditions.md, privacy-policy.md, refund-policy.md); have them reviewed by a qualified lawyer before go-live.

### Backend, AI & infrastructure (server and Docker setup)

- **NestJS backend:** Single API for app and share/landing: auth, profiles, report upload, parsing orchestration, storage, credits/balance, credit packs and subscriptions (both in v1), promo codes, share tokens. No PHI in logs or analytics. Environment-based config (e.g. parser URL, LLM URL, DB, secrets).
- **Parsing service (Docling or alternative):** Run as a **Docker** container. NestJS sends PDF (or file ref) to parser service (HTTP/gRPC); receives structured output (tables, text, metadata). Optional: queue (e.g. Bull/Redis) for async parse so upload responds immediately and summary appears when ready. Image: e.g. `docling` or custom Dockerfile; expose one port; document input/output contract.
- **AI services (summarisation, chat, lifestyle):** Run **Hugging Face** or other open-source LLM/embedding models in **Docker** (one or more containers). NestJS calls these via HTTP (e.g. /summarise, /chat, /suggest) with report context; no PHI in logs. Model swapping: different image or env var per task (e.g. summarisation model vs chat model). GPU optional; CPU-only possible for smaller models.
- **Docker setup:** Use **docker-compose** (or Kubernetes later) to run: (1) NestJS app, (2) parser service (Docling), (3) LLM service(s), (4) DB (e.g. PostgreSQL), (5) Redis if using queues. Volumes for persistent data and optionally model weights. `.env` for URLs and keys. Document in repo: `docker-compose up` for local dev; same stack deployable on a single server or split (e.g. app on VPS, AI on GPU box).
- **Server setup:** Deploy NestJS + Docker stack on a VPS or cloud (e.g. single VM with Docker Compose). Share web app and landing can be served by NestJS (static) or a separate host. HTTPS, env secrets, and backup for DB and uploaded files. Optional: separate node(s) for parser/LLM if scale demands it.

### Report upload, parse flow, and user status (V1)

**End-to-end flow when user submits a report**

1. **App → Backend:** User selects file(s), chooses profile; app uploads PDF(s) to NestJS (e.g. `POST /reports` with multipart file + profileId). Backend validates: file type (PDF), file size (per tier: Free 5 MB, paid 25 MB — see "Max file size per PDF" in this brief), account has credits or is within free cap, profile exists.
2. **Backend stores file:** NestJS stores the raw PDF in object storage (or file system) and creates a **report record** in DB with status `uploading` then `parsing`. User is linked to this record (reportId) so the app can show status.
3. **Parse request:** NestJS sends the PDF (or a storage reference) to the **parser service** (Docling in Docker) via HTTP/gRPC. Request includes reportId so results can be tied back. Parser has a **timeout** (e.g. 60–120 s); if no response in time, backend treats as failure.
4. **Parser response:** Parser returns structured output (e.g. tables for lab, text + metadata for imaging) or an error. NestJS maps this to: structured fields (test names, values, units, dates) for lab; document + metadata + optional summary for imaging/other.
5. **Storage and summary:** Backend saves parsed data to DB; for lab reports, normalises and links to profile’s time series. If basic summary is in scope (V1), NestJS may call an AI summarisation service (same Docker stack) or use rule-based snippet; summary stored on the report record.
6. **Status update to user:** Backend sets report status to `parsed` (or `unparsed` on failure, see below) and, if async, notifies the client (polling or WebSocket). Client shows the report card on the timeline with summary or “Unparsed – view PDF.”

**Sync vs async (V1 recommendation)**

- **Sync (simpler for V1):** Upload + parse in one request; client shows “Uploading…” then “Reading report…” (spinner); when backend responds (success or fail), client shows result. Timeout on client (e.g. 90 s) with “Still reading…”; on backend timeout to parser, return failure and store as unparsed.
- **Async (optional):** Backend accepts upload, returns reportId and status `parsing` immediately; client shows “We’re reading your report” and polls `GET /reports/:id` (or WebSocket) until status is `parsed` or `unparsed`. Use if parse often takes >10–15 s so the app doesn’t block.

**Fail recovery**

- **Parser timeout:** Backend stops waiting after configured timeout (e.g. 60 s). Report record set to `unparsed`; PDF kept. Client receives error or status `unparsed`; user sees “We couldn’t read this format” and options **Retry** (re-submit same file) or **Keep file anyway** (keep unparsed card with “View PDF”).
- **Parser error/crash:** Parser returns 5xx or invalid response. Backend does one **retry** (optional, e.g. after 5 s); if still fail, same as timeout: store PDF, set `unparsed`, return to client with same message and Retry / Keep file anyway.
- **Upload failure (network, 4xx):** Client shows “Upload failed. Check connection and try again.” User can retry upload. No report record until upload succeeds.
- **Duplicate (same file/content):** Before or after parse, backend detects duplicate (hash or content fingerprint). Return “Already added” with option “Add anyway” (second copy) or “Replace existing” (update that report). No data loss.

**How to update the user on what’s happening (V1)**

- **During upload:** Show “Uploading…” (and progress if API supports progress events). After upload accepted: “Reading report…” (or “We’re reading your report” if async).
- **Success:** Report card appears on timeline with date, title, and summary (or lab values). No extra modal unless you want a short “Report added” toast.
- **Parse failed:** Show message: “We couldn’t read this format. Your file is saved; you can view the PDF or try again.” Buttons/actions: **Retry** (same file re-sent to backend), **Keep file anyway** (confirm unparsed card; user can view PDF from timeline). Report card on timeline shows “Unparsed – view PDF” and upload date.
- **Ongoing status (async):** If using polling, poll every 2–5 s until status is `parsed` or `unparsed`; show “Reading report…” and then result or error state. Optional: “This is taking longer than usual” after 30 s.

This behaviour is a **V1 feature**: upload status, parse feedback, and fail recovery with Retry and Keep file anyway.

### Key Differentiators

- **Patient-owned, multi-source:** Any lab or hospital PDF; not locked to one provider or region. **Multi-profile:** Create patient profiles (self, family members) and upload/organise reports per profile; charts, AI, and share are per profile.
- **Share link as web page:** Recipients see a clean page with chosen history and charts without installing the app.
- **Blood-first charts + imaging as timeline:** Clear separation: numbers → charts; imaging → timeline + narrative.
- **AI that’s grounded in the user’s reports:** Chat and suggestions tied to their actual data, with disclaimers. **Open-source / Hugging Face models run locally** (e.g. Docker) for parsing and AI to keep data on your infra.
- **Monetization:** Free tier with **cap on uploads** (see Monetization plans below); paid tiers for power users and families; optional one-time “report pack”; later B2B (clinics/white-label).
- **Regions:** Ship India + USA first (English, PDF-first); add EU when ready (GDPR, possible EU hosting). Report format variance handled by PDF-first + template/parser strategy; FHIR later if needed.

---

## Deeper Analysis (Party Mode)

### Primary persona (recommendation)

- **Primary for v1:** The *chronic self-manager*—someone with recurring labs (e.g. diabetes, thyroid, lipids) who wants to see trends, get summaries, and occasionally share with a doctor. This drives: blood-first charts, “compare with prior,” and one clear share recipient (doctor).
- **Secondary:** Family carer—manages multiple patient profiles (self + family members), uploads reports per profile, shares per profile. Multi-profile is a core product requirement from the start.
- **Explicitly later:** One-off “I had a health scare” user—don’t over-index v1 on them; they’re valuable but different (fewer reports, less retention).

### Success metrics

- **North-star (share-as-wedge):** *Share links opened by recipient* (or *share links created per MAU* as leading indicator). Success = share is used, not just created.
- **Lifestyle/natural-healing:** Define v1 success as *user saw suggestion* (impression) and optionally *marked helpful*. “Add to my plan” / tracking can be v1.5.
- **Retention:** *Return after 2nd report upload* or *monthly active after first share*—prevents “upload once and leave.”

### Share link: recipient and flows

- **Primary recipient:** Doctor (pre-visit or referral). Share page = “doctor view”: timeline, key numbers, trends, one-page summary; minimal branding, print-friendly.
- **Secondary:** Self on another device or family. Same data, different framing (e.g. “Your summary” vs “Patient summary for Dr. X”).
- **Product implication:** One share type, with optional “view as: Doctor / Me / Family” or a single clear default (doctor) and simple custom message.

### Monetization (value-based)

- **Why not subscription-first:** Users typically don’t need reports daily or regularly—annual checkup, occasional panels, one-off scans. A monthly subscription can feel wasteful (“I’m paying every month but I only uploaded twice this year”). **Credits (recharge)** align better: pay per report analysed; no recurring commitment; fits India’s prepaid mindset and irregular usage.
- **Primary model – credits (recharge):** User has a **credit balance**. Credits are **deducted per report** when a report is uploaded and fully analysed (parse + store + AI summary/insights). Optional: extra deduction for heavy AI (e.g. chat with report, lifestyle suggestions) or per active share link—product decision. User **recharges** by buying **credit packs** (e.g. 5, 15, 50 credits); larger packs at better per-credit price. One-time Razorpay Order per purchase; no subscription required.
- **Free tier:** Small initial balance (e.g. 3–5 credits on signup) or a **report cap** (e.g. 5 reports total ever) with basic summary only; one active share link. Creates upgrade moment when they run out.
- **Subscription (v1, alongside credit packs):** For power users or families, offer a **subscription** that gives a **monthly credit allowance** (e.g. 15 credits/month) + extra features (more share links, export). Unused credits can have limited rollover (e.g. cap at 30). Subscription = “credits bundle + features”; both credit packs and subscription are supported from day one (v1).
- **Summary:** Credits-first; recharge via credit packs (one-time) **and** subscription (monthly credits + features)—both in v1. All payments via Razorpay (India + international).

### Monetization plans (suggested tiers)

- **Payments:** Processed via **Razorpay** for both **India and international** (orders for credit packs and subscriptions; INR in India, USD or other currencies for international). Single payment provider. Promo codes are applied in our backend before creating Razorpay order; see “Promo codes with Razorpay” below.
- **Identifying user country / pricing region (show prices in local currency):** We need a **pricing region** (e.g. India, US, EU) per user or per session to choose currency (INR / USD / EUR) and the correct price from the plan table.
  - **Primary – IP geolocation:** Backend derives country from the request (e.g. `CF-IPCountry` if behind Cloudflare, or a geo service such as MaxMind GeoIP2, ip-api.com, or a small middleware that calls a free/paid API). Map country → pricing region (IN → India, US → US, GB/DE/FR/… → EU, etc.). No user action; works for first visit and anonymous pricing pages.
  - **Secondary – App/device locale:** For the app, send device region (e.g. Flutter `Platform.locale` or `Region` from `Localizations.locale`) to the backend when fetching plans or at signup. Backend can use it to refine or override IP (e.g. user in US with device set to India might prefer INR). Use as hint; don’t rely alone (locale can be wrong for “where they pay”).
  - **Override – Explicit choice:** Let the user set **Country / Region** in account or checkout (e.g. “Prices in: India (₹) | United States ($) | Europe (€)”). Store per account so pricing region and currency stay consistent for Razorpay (INR vs USD/EUR). Useful for expats, travel, or when IP/locale are wrong.
  - **Flow:** (1) Anonymous/landing: use IP (and optional locale) to show “From ₹99 for 5 reports” or “$2.99 for 5 reports”. (2) Logged-in: use stored account region if set, else IP + locale. (3) At checkout: show amount in chosen region’s currency; charge in that currency. Plan table holds price per region per product (credit packs, subscription).

| Tier / product | Credits / cap | Share links | AI / lifestyle / chat | Export | Price (India) | Price (US/EU) |
|----------------|----------------|-------------|-------------------------|--------|----------------|----------------|
| **Free** | 3–5 credits on signup (or 5 reports total cap) | 1 active | Basic summary only; no chat, no lifestyle | No | ₹0 | $0 |
| **Credit pack (small)** | 5 credits | 1–2 active (or per-credit for share) | Full AI per report | — | ₹99–149 one-time | $2.99–3.99 |
| **Credit pack (medium)** | 15 credits | Same | Same | PDF pack optional | ₹249–349 one-time | $6.99–9.99 |
| **Credit pack (large)** | 50 credits | Same | Same | Included | ₹699–999 one-time | $19.99–29.99 |
| **Subscription (v1)** | e.g. 15 credits/month + rollover cap (e.g. 30) | 5 active, multi-profile | Full AI | Included | ₹199/mo or ₹1,999/yr | $5.99/mo or $59/yr |

- **Credit deduction rules (v1):** 1 credit = 1 report fully analysed (upload + parse + store + basic summary). Optionally: +0.5 or +1 credit for “full AI” (lifestyle, chat) per report—or keep 1 credit = all-in per report for simplicity. Share links: either free up to limit (1 for free, more for paid) or 0.25 credit per active link per month—decide in PRD. Superadmin plan table should store “credits per report” and “credits per share link” if variable.
- **Max file size per PDF:** By tier or by account type. **Free / small packs:** 5 MB per PDF. **Larger packs / subscription:** 25 MB (or 50 MB). Reject at upload with clear message if over limit.
- **Free tier shape:** Either (a) one-time grant (e.g. 5 credits) so first few reports are free, or (b) hard cap (e.g. 5 reports total ever) with basic summary only. (a) is simpler with a unified credit system; (b) avoids “credits” in free UX. Choose one for v1.
- **B2B (later):** White-label or “clinic dashboard”; price per clinician or per practice.

### Promo codes (superadmin)

- **Purpose:** As a SaaS superadmin (Envsoft Solutions LLP / product operator), you can create and manage **promo codes** for promotional campaigns (e.g. launch discount, partner offer, seasonal deal).
- **Superadmin capabilities:** Create promo codes with rules: e.g. percentage or fixed discount, applicable plan(s) (Pro/Family), validity window, optional usage cap (total redemptions or per user). Deactivate or delete codes. View **per-code analytics:** total redemptions, who used it (user/account identifier, redemption time), revenue impact (discount given, conversion from which plan).
- **Tracking:** Every redemption is logged: code, user/account id, timestamp, plan applied, discount amount. Data available in superadmin analytics and (optionally) export for reporting. No PHI in promo logs—only account-level identifiers.
- **User flow:** User enters promo code at checkout (credit pack or subscription); backend validates (valid, not expired, under cap, applicable to product); discount applied; redemption recorded.
- **Promo codes with Razorpay:** Promo logic is owned by our backend; Razorpay is called with the **final (discounted) amount**.
  - **Validation:** Before creating any Razorpay order (or subscription), backend validates the promo (code exists, not expired, usage cap not exceeded, applicable to selected product—e.g. credit pack or subscription). Invalid/expired code returns a clear error; no payment is created until valid.
  - **Credit pack (one-time):** Backend computes discounted amount from pack price and promo. Create Razorpay **Order** with discounted amount (in paise). On `payment.captured` webhook, record redemption, credit the user’s balance with the pack’s credits, and log (code, user, pack, discount, order_id).
  - **Subscription (v1):** Create Razorpay Offer and link to Subscription, or first payment as Order at discount then subscription from next cycle. Redemption logged for superadmin analytics.
  - **Idempotency:** Idempotency keys or idempotent redemption records so retries don’t double-apply or double-count.
  - **Superadmin analytics:** Redemption records (our DB) = source for “who used which code, when, revenue impact”; Razorpay for payment reconciliation.
- **Add promo codes:** Superadmin can add (create) promo codes: code string, discount type (percentage or fixed), applicable product(s) (e.g. credit pack sizes, subscription), validity start/end, usage cap. Edit or deactivate. Same Promo code management UI.

### Plan table (superadmin)

- **Purpose:** Superadmin must be able to **manage plans and limits** whenever needed, without code deploys. A **plan table** (or plan management screen) in the superadmin dashboard holds all plan definitions and their limits.
- **What can be managed:** (1) **Free tier:** initial credit grant or report cap, share link limit, max file size, which features (e.g. basic summary only). (2) **Credit packs:** pack name/size (e.g. 5, 15, 50 credits), price per region, max file size for accounts with balance from that pack (or account-level file size by “tier” after first purchase). (3) **Credit deduction rules:** credits per report (e.g. 1), optional extra for full AI or per share link—globally or per “plan” if we keep plan labels. (4) **Subscription (v1):** monthly credit allowance, rollover cap, share links, price per region. (5) **Global:** max file size per PDF (e.g. 5 MB free, 25 MB paid). Audit log when superadmin changes any of the above.
- **UI:** List or table of plans; click to edit limits and save. Validation to avoid breaking existing logic (e.g. report cap > 0). Optional: duplicate plan to create a new tier. Audit log when superadmin changes a plan.

### Superadmin dashboard (v1)

- **When:** Part of **v1 / MVP**. Deliver alongside or immediately after core user-facing features (auth, profiles, upload, share, credits/recharge) are stable. Superadmin tooling is a separate, secured surface (e.g. separate app or protected admin routes).
- **Scope:** (1) **Plan table / plan management:** View and edit free tier, credit packs, credit deduction rules, subscription, share links, file size, price per region; see “Plan table (superadmin)” above. (2) **Promo code management:** Add (create), edit, deactivate promo codes; view redemption list and analytics per code. (3) **Superadmin analytics:** Signups, active users, credit pack sales and subscription counts, revenue (one-time + recurring), promo redemptions and impact; optional filters by region or time. (4) **Operational:** Optional: view accounts (no PHI), support-style actions (e.g. revoke share link, flag account)—to be scoped in PRD with compliance in mind.
- **Security:** Superadmin dashboard restricted to a small set of superadmin users (role-based); audit log of admin actions; no PHI on dashboard by default; access via strong auth (e.g. SSO or MFA). Hosted separately or behind strict access control.

### Multi-profile (patient profiles) — requirement detail

- **Create and manage profiles:** User can create multiple **patient profiles** (e.g. “Me”, “Mom”, “Dad”, “Child”). Each profile has a name and optional metadata (e.g. relation, DOB for age-based reference ranges). At least one profile (e.g. “Me”) exists by default.
- **Upload and assign:** On report upload, user selects which profile the report belongs to. All parsing, storage, and display are scoped to that profile. No report exists “without” a profile.
- **Per-profile experience:** Timeline, lab charts, imaging list, AI summary, chat, and lifestyle suggestions are all **per profile**. User switches profile in the app to see that person’s data. Share links are created from a profile (or a subset of that profile’s reports).
- **Caps and limits:** **Credit balance** is **account-level** (shared across all profiles). Free tier: small initial credits or a one-time report cap (e.g. 5 reports total) across all profiles. Paid: user recharges with credit packs; each report analysed consumes credits regardless of which profile it’s assigned to. **Free tier:** 1 patient profile per account; report cap (e.g. 5 total); 1 share link. **Paid tier:** multiple profiles; credit packs; higher share-link limit.
- **Privacy and consent:** User is the “owner” of the account; they are responsible for having consent to upload and manage data for other profiles (e.g. minor children, dependents). Product should surface clear consent/ownership messaging when creating a non-self profile. Deletion: user can delete a profile and all its reports (with confirmation); data deletion/portability applies per account.

### Trust and positioning

- **One-liner:** “Personal health report organiser and insight tool—not a diagnostic or treatment tool.” Disclaimers and consent are core product requirements; compliance (GDPR, etc.) is a differentiator in positioning.
- **Imaging scope (v1):** PDF/text of radiology report only; no DICOM, no PACS. State this in the brief to set expectations.

---

## Target Users

### Primary Users

**Chronic self-manager (primary for v1)**  
- **Who:** Someone with recurring lab work (e.g. diabetes, thyroid, lipids, Hb) who wants to see trends, understand results, and share a clear history with doctors. May have 5–20+ reports over time.  
- **Context:** Manages own health between visits; gets PDFs from labs or patient portals; often sees a new specialist and needs to “bring everything.”  
- **Problem today:** Reports live in email, downloads, or paper; no single view of “how my Hb changed”; sharing = forwarding PDFs or carrying printouts.  
- **Success with Doclyzer:** One place for all reports; charts that show trends; one share link to send before an appointment; AI summary and lifestyle suggestions (with disclaimers) to feel more in control.  
- **Jobs:** Upload reports → assign to “Me” profile → view timeline and charts → create share link for doctor → (optional) read AI insights and lifestyle tips.

**Family carer (secondary, core from day one)**  
- **Who:** Manages health data for self plus one or more others (e.g. parent, spouse, child). Multiple patient profiles; uploads and organises reports per person.  
- **Context:** Schedules and attends appointments, keeps lab printouts/PDFs, needs to share the right person’s history with the right doctor.  
- **Problem today:** Mixed papers and PDFs for different family members; no per-person timeline or share link; easy to bring the wrong report.  
- **Success with Doclyzer:** One account, multiple patient profiles; upload and assign each report to the right profile; per-profile timeline, charts, and share links; switch profile in the app to see that person’s data.  
- **Jobs:** Create profiles (e.g. Me, Mom, Dad) → upload reports and assign to profile → view per-profile trends → create share link per profile for doctors or family.

### Secondary Users

- **One-off / “health scare” user:** Few reports (e.g. one panel or scan); wants quick summary and maybe one share. Valuable for acquisition; less retention. Optimise for simple onboarding and “see summary fast”; don’t over-build v1 for them.  
- **Share link recipient (doctor or family):** Doesn’t use the app; opens share link in browser. Success = clear, print-friendly view of the shared profile’s reports and trends; no login required.  
- **Future B2B:** Clinics or doctors inviting patients to upload into a connected workflow—out of scope for initial brief.

### User Journey

- **Discovery:** App store, search (“medical report organizer”, “share lab reports with doctor”), or word of mouth after receiving a share link.  
- **Onboarding:** Sign up → create first profile (e.g. “Me”) → upload first report(s) → assign to profile → see parsed summary and (if lab) early chart.  
- **Core usage:** Upload new reports as they arrive → assign to profile → view timeline and charts per profile → create/revoke share links; optionally use AI summary, chat, and lifestyle suggestions (paid).  
- **Success moment:** First time they share a link before a doctor visit and the doctor has a clear view; or first time they see a trend (e.g. “Hb over last 6 months”) in one place.  
- **Long-term:** Doclyzer becomes the default place to store and share reports; family carers rely on multi-profile and per-profile share links; power users pay for Pro/Family for more reports, AI, and export.

---

## Success Metrics

### User success

- **Activation:** User has uploaded ≥2 reports and/or created at least one share link (per account).  
- **Value moment:** First share link opened by a recipient (e.g. doctor); or user views a trend chart (e.g. Hb over time) for the first time.  
- **Lifestyle/insight:** User saw an AI lifestyle/natural-healing suggestion and (optionally) marked it helpful (thumbs).  
- **Retention:** 7-day and 30-day retention of activated users; goal = return to view/add reports or use share link again.

### Business objectives

- **North-star (share-as-wedge):** Share links opened by recipient (e.g. within 7 days of creation). Secondary: share links created per MAU.  
- **Growth:** New signups; share-link recipients who sign up (viral loop).  
- **Revenue:** Conversion from Free → Pro/Family; ARPU by region (India vs US/EU); one-time pack uptake.  
- **Trust:** Consent and data-handling compliance (GDPR, etc.); no major privacy/security incidents.

### Key performance indicators

| KPI | Target (example) | Measurement |
|-----|------------------|-------------|
| Share links opened (7d) | % of created links opened | Backend event: share token + first view |
| Activated users (2+ reports or 1+ share) | % of signups within 30d | Account-level events |
| 30-day retention (activated) | e.g. ≥25% | Return visit within 30d of activation |
| Free → Paid conversion | % of activated users | Subscription / one-time purchase |
| Share → signup (recipient) | % of unique link viewers who sign up | Attribution from share token |

Leading indicators: reports uploaded per user, share links created per MAU, AI suggestion impressions and helpful votes.

---

## MVP Scope

### Core features (MVP)

- **Auth & account:** Sign up / sign in; one account per user.
- **Patient profiles:** Create and manage multiple profiles (e.g. Me, family); assign every report to a profile; switch profile to view that person’s data.
- **Upload & parse:** Upload PDF reports; assign to profile; parse with Docling (or agreed stack) — structured extraction for lab reports, document + metadata + summary for imaging and narrative reports. **Upload status & parse feedback (V1):** User sees “Uploading…” then “Reading report…”; on success, report card with summary on timeline; on parse failure, “We couldn’t read this format” with **Retry** and **Keep file anyway** (unparsed card with “View PDF”). See “Report upload, parse flow, and user status (V1)” in this brief for backend flow and fail recovery.
- **Organise:** Per-profile timeline of reports; lab parameters as chartable time series (with normalised test names/units); imaging as dated list with findings text.
- **Basic summary:** Per-report and per-profile summary (no chat, no lifestyle suggestions in Free).
- **Share link:** Create one share link per account (Free); link opens a web page (share.doclyzer.com or similar) showing selected profile’s reports, summaries, and charts; optional expiry; revoke link.
- **Credits & recharge (primary monetization):** User has a credit balance (account-level). Each report analysed consumes credits (e.g. 1 credit per report; rules configurable in plan table). Free tier: small initial credits (e.g. 3–5) or a one-time report cap (e.g. 5 total). User **recharges** by buying **credit packs** (e.g. 5, 15, 50 credits) via Razorpay one-time Order; balance is credited on payment success. Subscription (v1): monthly credit allowance + features (see “Monetization plans” in this brief). Both credit packs and subscription available from day one.
- **Caps:** Free = initial credit grant or report cap (e.g. 5 reports total) and 1 active share link; enforce at account level. Paid = credit balance; each upload that triggers full analysis deducts credits.
- **Platform:** Flutter app (mobile); NestJS backend; share experience as separate web app consuming share API.
- **Promo codes (V1):** Superadmin can create and manage promo codes; track every redemption (who, when, product e.g. credit pack, discount); per-code analytics. User enters code at checkout (credit pack or subscription); backend validates and applies discount; redemption logged. See “Promo codes (superadmin)” and “Superadmin dashboard (v1)” in this brief.
- **Superadmin dashboard (V1):** Secured admin surface: (1) **plan table** — manage free tier, credit packs, credit deduction rules, subscription, share links, file size, price per region; (2) promo code CRUD and redemption list/analytics; (3) high-level analytics (signups, active users, credit sales, subscription MRR/ARR, promo impact). Role-based access, audit log, no PHI; strong auth (e.g. SSO/MFA). See “Plan table (superadmin)”, “Promo codes (superadmin)” in this brief.

### Out of scope for MVP

- **DICOM / PACS:** No image viewing; radiology = PDF/text of report only.
- **FHIR / EHR integration:** PDF-first only; no direct EHR or lab system integration.
- **Full AI (chat, lifestyle suggestions):** Paid feature; MVP can ship with basic summary only and add AI in a fast follow.
- **Export PDF pack, reminders, “compare with prior” UI:** Post-MVP.
- **B2B / clinic dashboard:** Later phase.
- **EU-specific compliance (e.g. EU hosting):** Can follow after India/USA launch if needed.

### MVP success criteria

- User can sign up, create a profile, upload at least 2 reports, assign to profile, see timeline and (for lab) a simple trend; create one share link and open it in a browser with correct data.
- Share link opened by recipient (e.g. within 7 days) as north-star signal.
- No critical security or privacy incidents; clear disclaimers and consent where required.

### Future vision

- **Pro/Family tiers:** More reports, multiple share links, full AI (insights, lifestyle, chat), export PDF pack, reminders.
- **Compare with prior:** Side-by-side or overlay for same test/scan over time.
- **Offline / cache:** Use app with limited data when offline.
- **Regions:** EU launch with GDPR-compliant handling and optional EU hosting; more report formats or FHIR where it adds value.
- **B2B:** Clinic/doctor tools: invite patients, optional white-label share page.
