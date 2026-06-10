# Edit website content (no Firebase, no storage costs)

All text and images are loaded from this folder. After changes, run **hot restart** (`R` in terminal) or rebuild the app.

## Main file

Edit **`site_content.json`** — one structured file for the whole site.

## Add a project

Copy this block into the `"projects"` array (change `id` to something unique):

```json
{
  "id": "my-project",
  "sortOrder": 4,
  "title": "Project name",
  "category": "Web App",
  "description": "What you built.",
  "tech": "Flutter · Dart",
  "year": "2025",
  "image": "assets/images/projects/my-project.jpg",
  "link": "https://your-demo-link.com"
}
```

- **`image`**: optional — path under `assets/images/projects/`
- **`link`**: optional — set to `null` if none
- **`sortOrder`**: lower numbers appear first

## Add a team member

```json
{
  "id": "member-id",
  "sortOrder": 4,
  "name": "Full Name",
  "role": "Job title",
  "bio": "Short bio.",
  "initials": "FN",
  "isLeadership": false,
  "photo": "assets/images/team/member-id.jpg"
}
```

- **`photo`**: optional — put file in `assets/images/team/`

## Images

1. Save JPG or PNG in `assets/images/projects/` or `assets/images/team/`
2. Reference the path in JSON, e.g. `"assets/images/projects/retail-pos.jpg"`
3. If `pubspec.yaml` lists new folders, run `flutter pub get`

## Hero & contact

- **`site`**: badge, title, subtitle, stats array
- **`contact`**: email, WhatsApp number (country code, no +), enquiry types
