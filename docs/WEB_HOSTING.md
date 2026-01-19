## Web Hosting Guide (NewLife)

Deploy the NewLife Flutter web app to Firebase Hosting or GitHub Pages for free/low-cost hosting.

### Option 1: Firebase Hosting (Recommended)

Firebase Hosting provides free tier (5GB/month), custom domain, SSL, CDN, and fast deployment.

#### Prerequisites

- Firebase account (free at https://firebase.google.com)
- Firebase CLI installed:
  ```powershell
  npm install -g firebase-tools
  ```

#### Step 1: Build Flutter Web

```powershell
flutter pub get
flutter build web --release
```

Output: `build/web/` — ready for deployment.

#### Step 2: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click **+ Add project**
3. Name: `newlife-church-app` (or similar)
4. Choose region (e.g., `us-central1`)
5. Create project

#### Step 3: Initialize Firebase Hosting

```powershell
firebase login
firebase init hosting
```

When prompted:

- **Which Firebase project?** → Select your project
- **What do you want to use as your public directory?** → `build/web`
- **Configure as single-page app?** → `yes` (for Flutter routing)
- **Set up automatic builds and deploys with GitHub?** → `no` (optional; skip for now)

This creates:
- `firebase.json` — hosting config
- `.firebaserc` — project reference

#### Step 4: Deploy

```powershell
firebase deploy
```

Output:
```
✓ Deploy complete!

Project Console: https://console.firebase.google.com/project/newlife-church-app/overview
Hosting URL: https://newlife-church-app.web.app
```

Visit https://newlife-church-app.web.app 🎉

#### Optional: Custom Domain

1. In Firebase Console, go to **Hosting** → **Custom domains**
2. Click **Add custom domain**
3. Enter domain (e.g., `app.newlifecc.co.uk`)
4. Verify ownership (add DNS records)
5. SSL certificate auto-generated

#### Redeployment

After code changes:

```powershell
flutter build web --release
firebase deploy
```

---

### Option 2: GitHub Pages (Free Alternative)

GitHub Pages hosts static sites for free. Requires public GitHub repo.

#### Prerequisites

- GitHub account with public repo
- GitHub CLI or Git command line
- GitHub Actions enabled (automatic)

#### Step 1: Build Flutter Web

```powershell
flutter pub get
flutter build web --release
```

#### Step 2: Configure for GitHub Pages

GitHub Pages serves from `/docs` or `gh-pages` branch. We'll use `/docs`:

1. Copy build output to docs folder:
   ```powershell
   Remove-Item -Recurse docs -ErrorAction SilentlyContinue
   Copy-Item build/web docs
   ```

2. Create `docs/404.html` for SPA routing (copy from `docs/index.html`):
   ```powershell
   Copy-Item docs/index.html docs/404.html
   ```

#### Step 3: Push to GitHub

```powershell
git add docs/
git commit -m "Deploy web build"
git push origin main
```

#### Step 4: Enable GitHub Pages

1. Go to your repo on GitHub
2. **Settings** → **Pages**
3. **Source**: `Deploy from a branch`
4. **Branch**: `main`, folder `docs`
5. Click **Save**

GitHub will deploy automatically. Your site is live at:
```
https://<github-username>.github.io/<repo-name>
```

Example: `https://myusername.github.io/newlife-church-app`

#### Custom Domain (Optional)

1. Go to your domain registrar
2. Add DNS record:
   - Type: `CNAME`
   - Name: `app` (or subdomain)
   - Value: `<github-username>.github.io`
3. In GitHub Pages settings, add custom domain: `app.newlifecc.co.uk`
4. Check "Enforce HTTPS"

#### Redeployment

After changes:

```powershell
flutter build web --release
Remove-Item -Recurse docs -ErrorAction SilentlyContinue
Copy-Item build/web docs
Copy-Item docs/index.html docs/404.html
git add docs/
git commit -m "Deploy web update"
git push origin main
```

Or automate with GitHub Actions:

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Web

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter build web --release
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./build/web
```

---

### Comparison

| Feature | Firebase | GitHub Pages |
|---------|----------|--------------|
| **Cost** | Free tier (5GB/mo) | Free unlimited |
| **Custom domain** | ✓ | ✓ |
| **SSL** | ✓ Automatic | ✓ Automatic |
| **CDN/Speed** | ✓ Global CDN | ~ Regional |
| **Database** | ✓ Realtime DB/Firestore | ✗ Static only |
| **Backend** | ✓ Cloud Functions | ✗ |
| **Analytics** | ✓ Built-in | ✗ (use GA) |
| **Ease** | Easiest | Simple |

**Recommendation**: Use **Firebase Hosting** for faster deployments and better analytics. Use **GitHub Pages** if you want zero cost and already host code there.

---

### Troubleshooting

**"404 on page refresh"** — Firebase/GitHub requires SPA routing config:
- Firebase: Done automatically in `firebase.json`
- GitHub: Use `404.html` redirect (Flutter creates this)

**"Blank page or assets not loading"** — Check:
1. `flutter build web --release` succeeded
2. `build/web/index.html` exists
3. Redeploy and clear browser cache (Ctrl+Shift+Delete)

**"Large bundle size"** — Flutter web is ~3–5MB gzipped by default:
```powershell
flutter build web --release --dart-define=FLUTTER_WEB_USE_EXPERIMENTAL_WASM=true
```
(WASM can reduce size further; experimental)

**"Custom domain not working"** — DNS can take 24–48 hours to propagate:
```powershell
# Check DNS propagation
nslookup app.newlifecc.co.uk
```

---

### Resources

- Firebase Hosting: https://firebase.google.com/docs/hosting
- GitHub Pages: https://pages.github.com
- Flutter Web: https://flutter.dev/docs/deployment/web
- Flutter Web Performance: https://flutter.dev/docs/perf/best-practices
