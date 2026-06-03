# Firebase setup (ashifportfolio-27f49)

VStack website data is **separate** from portfolio (`vstackweb/*` in Firestore, `vstackweb_media/` in Storage).

## 1. Enable Authentication

Firebase Console → **Authentication** → **Sign-in method** → enable **Email/Password**.

## 2. Admin login (hardcoded — no Firebase Auth)

| Field | Value |
|-------|--------|
| Username | `vstackadmin` |
| Password | `Vstack@123#admin` |

Open with **Shift + Ctrl + O**. Firebase is only used for saving website content (Firestore/Storage), not for login.

## 3. Firestore & Storage rules

See previous rules in this file — public read for `vstackweb`, write when `request.auth != null`.

## 4. Run

```powershell
flutter run -d chrome
```

**Stop the app completely**, then run again (hot reload is not enough after Firebase changes).

## 5. Admin dashboard

- **Shift + Ctrl + O** → login with username/password above
- Edit content in dashboard tabs (requires Firestore connected)
- Enquiries appear under **Enquiries** when Firebase works
