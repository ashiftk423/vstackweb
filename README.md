# VStack IT Solutions — Website

Flutter web marketing site for **VStack IT Solutions**. Content is edited in `assets/content/site_content.json` (no Firebase, no hosting fees for data).

## Edit content

See [assets/content/README.md](assets/content/README.md).

## Run locally

```powershell
flutter pub get
flutter run -d chrome
```

## Host on GitHub Pages (share link with clients)

**Your live URL will be:** [https://ashiftk423.github.io/vstackweb/](https://ashiftk423.github.io/vstackweb/)

### One-time setup in GitHub

1. Open [Repository Settings → Pages](https://github.com/ashiftk423/vstackweb/settings/pages)
2. Under **Build and deployment** → **Source**, choose **GitHub Actions** (not “Deploy from a branch”)
3. Save

### Deploy

Push to the `main` branch. GitHub Actions builds Flutter web and publishes automatically.

```powershell
git add .
git commit -m "Deploy VStack website to GitHub Pages"
git push origin main
```

Check progress under the repo **Actions** tab. When the workflow is green, open the link above.

### Update the site later

Change content or code → commit → push to `main`. The site updates in a few minutes.
