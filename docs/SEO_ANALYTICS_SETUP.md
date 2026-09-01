# SEO Analytics Setup — VStack Business Solutions

Follow these steps after deploying the site to measure traffic and search performance.

## 1. Google Analytics 4 (GA4)

1. Go to [Google Analytics](https://analytics.google.com/) and create a **GA4** property for `vstackbusinesssolutions.com`.
2. Copy your **Measurement ID** (format: `G-XXXXXXXXXX`).
3. In [`web/index.html`](../web/index.html), replace **both** occurrences of `G-XXXXXXXXXX` with your real ID.
4. Deploy and verify in GA4 **Realtime** report while browsing the live site.

## 2. Google Search Console

Search Console verification file already exists: [`web/googledf2c9123c209affa.html`](../web/googledf2c9123c209affa.html).

1. Open [Google Search Console](https://search.google.com/search-console).
2. Add property: `https://vstackbusinesssolutions.com` (Domain or URL prefix).
3. If not already verified, use the HTML file method (file is deployed at `/googledf2c9123c209affa.html`).
4. Submit sitemap: `https://vstackbusinesssolutions.com/sitemap.xml`
5. Request indexing for key pages:
   - `/`
   - `/locations.html`
   - `/services.html`
   - `/faq.html`
   - `/tools`

**Monthly:** Check Performance → Queries for new keywords; fix Coverage errors.

## 3. Bing Webmaster Tools

1. Go to [Bing Webmaster Tools](https://www.bing.com/webmasters).
2. Add site `https://vstackbusinesssolutions.com`.
3. Import from Google Search Console (easiest) or verify manually.
4. Submit the same sitemap URL.

Bing feeds Microsoft Copilot search — do not skip this.

## 4. Optional: Google Tag Manager

If you prefer GTM over direct gtag, replace the GA4 block in `index.html` with your GTM container snippet and configure GA4 inside GTM.

## 5. What to track monthly

| Metric | Where |
|--------|--------|
| Organic clicks & impressions | Search Console |
| Top search queries | Search Console |
| Page traffic | GA4 |
| Tool page usage | GA4 → Pages → `/tools/*` |
| Index coverage errors | Search Console → Pages |

## 6. Update `sameAs` in schema

When you create LinkedIn, Instagram, or Facebook profiles, add URLs to the `"sameAs"` array in [`web/index.html`](../web/index.html) Organization JSON-LD. This helps Google and AI connect your brand across platforms.
