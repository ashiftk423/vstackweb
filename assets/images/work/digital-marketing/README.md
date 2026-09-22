# Digital Marketing Works — Images

Drop **post images** and **Instagram insight screenshots** here.

## Folders

| Media | Path |
|-------|------|
| Post / cover images | `assets/images/work/digital-marketing/` |
| Insight screenshots | same folder (e.g. `brand-x-insights.png`) |
| Videos (reels) | `assets/videos/work/digital-marketing/` |

## Show on the website

Flutter does **not** auto-list new files. After you add media:

1. Open `assets/content/site_content.json`
2. Find the solution with `"slug": "digital-marketing"`
3. Add an entry under `"works"`:

```json
{
  "id": "brand-x-reels",
  "title": "Brand X — Reels",
  "mediaType": "video",
  "media": "assets/videos/work/digital-marketing/brand-x-reel.mp4",
  "description": "Optional story of the campaign.",
  "insightImage": "assets/images/work/digital-marketing/brand-x-insights.png"
}
```

### Optional fields

- **`description`** — write the story text in the JSON entry (omit or `""` to hide)
- **`insightImage`** — path to an Instagram insights screenshot (omit or `""` to hide)
- If **both** are empty, the card has **no** “More info” button

### `mediaType`

- `"image"` — use a file under this images folder
- `"video"` — use a file under `assets/videos/work/digital-marketing/`

Then hot restart / rebuild the app.
