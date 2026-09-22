# SEO Analytics Setup — VStack Business Solutions

Follow these steps after deploying the site to measure traffic and search performance.

## 1. Google Analytics 4 (GA4)

1. Go to [Google Analytics](https://analytics.google.com/) and create a **GA4** property for `vstackbusinesssolutions.com`.
2. Copy your **Measurement ID** (format: `G-XXXXXXXXXX`).
3. Replace the placeholder in **both** places (must match):
   - [`web/index.html`](../web/index.html) — both `G-XXXXXXXXXX` occurrences in the gtag snippet
   - [`lib/services/site_seo_resolver.dart`](../lib/services/site_seo_resolver.dart) — `SiteSeoDefaults.gaMeasurementId`
4. Deploy and verify in GA4 **Realtime** while browsing the live site **and** navigating between Flutter routes (e.g. Home → Solutions → Digital Marketing). Each SPA navigation should register a pageview with the clean path (no `.html`).

### SPA pageviews

`web/index.html` loads gtag with `send_page_view: false`. Flutter’s `SiteSeoListener` calls `gtag('config', …, { page_path, page_title })` on every route change so client-side navigations are counted.

Static SEO redirect shells (e.g. `/solutions/digital-marketing.html`) bounce to clean Flutter URLs in under a second — they do not need their own GA snippet.

## 2. Google Search Console

Search Console verification file already exists: [`web/googledf2c9123c209affa.html`](../web/googledf2c9123c209affa.html).

1. Open [Google Search Console](https://search.google.com/search-console).
2. Add property: `https://vstackbusinesssolutions.com` (Domain or URL prefix).
3. If not already verified, use the HTML file method (file is deployed at `/googledf2c9123c209affa.html`).
4. Submit sitemap: `https://vstackbusinesssolutions.com/sitemap.xml`
5. Request indexing for **clean Flutter URLs only** (do not prioritize duplicate `*.html` solution/product/tool shells):
   - `/`
   - `/solutions`
   - `/solutions/digital-marketing`
   - `/products`
   - `/tools`
   - `/contact`
   - `/locations.html` (static local SEO hub — keep)
   - `/locations/ernakulam.html`
   - `/services.html`
   - `/faq.html`

**Monthly:** Check Performance → Queries; in Pages / Coverage, gradually clear obsolete `.html` solution/product duplicates as Google consolidates to canonical clean URLs.

## 3. Bing Webmaster Tools

1. Go to [Bing Webmaster Tools](https://www.bing.com/webmasters).
2. Add site `https://vstackbusinesssolutions.com`.
3. Import from Google Search Console (easiest) or verify manually.
4. Submit the same sitemap URL.

Bing feeds Microsoft Copilot search — do not skip this.

## 4. Optional: Google Tag Manager

If you prefer GTM over direct gtag, replace the GA4 block in `index.html` with your GTM container snippet and configure GA4 inside GTM (including History Change / SPA pageviews). Keep `SiteSeoDefaults.gaMeasurementId` in sync or disable the Flutter `trackPageView` path to avoid double-counting.

## 5. What to track monthly

| Metric | Where |
|--------|--------|
| Organic clicks & impressions | Search Console |
| Top search queries | Search Console |
| Page traffic (incl. SPA routes) | GA4 |
| Tool page usage | GA4 → Pages → `/tools/*` |
| Index coverage / duplicate `.html` shells | Search Console → Pages |

## 6. Update `sameAs` in schema

When you create LinkedIn, Instagram, or Facebook profiles, add URLs to the `"sameAs"` array in [`web/index.html`](../web/index.html) Organization JSON-LD. This helps Google and AI connect your brand across platforms.
