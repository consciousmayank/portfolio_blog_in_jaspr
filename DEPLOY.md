# Deployment Guide — mayankjoshi.in

## Publishing a New Blog Post

1. Fill in `blog_website/template_blog.md` with your title, tags, description and content
2. Run the publish script from `blog_website/`:
   ```bash
   dart run tool/publish_post.dart
   ```
3. Commit and push:
   ```bash
   git add content/blog/<slug>.md lib/data/blog_posts.dart
   git commit -m "New post: My Post Title"
   git push origin main
   ```
4. GitHub Actions triggers automatically — Jaspr rebuilds and deploys to GitHub Pages
5. Post is live at `https://mayankjoshi.in/blog/<slug>`

---

## How the CI/CD Pipeline Works

Every `git push` to `main` triggers:
1. GitHub Actions checks out the repo
2. Dart SDK is set up
3. `dart pub get` installs dependencies in `blog_website/`
4. `dart run build_runner build` regenerates `blog_posts.dart` from `.md` files
5. `jaspr build` generates static HTML/CSS/JS in `blog_website/build/jaspr/`
6. The output is deployed to GitHub Pages via `actions/deploy-pages`
7. Site is live at `https://mayankjoshi.in`

---

## One-Time GitHub Setup

### 1. Enable GitHub Pages (do this once)

1. Go to your repo → **Settings → Pages**
2. Under **Source**, select **GitHub Actions**
3. Save

### 2. Add Custom Domain in GitHub

1. Still in **Settings → Pages**
2. Under **Custom domain**, enter `mayankjoshi.in`
3. Click Save — GitHub will create a commit adding a `CNAME` file (already in the repo, so this just validates)
4. Wait for the DNS check to pass, then tick **Enforce HTTPS**

---

## DNS Configuration (one-time, at your domain registrar)

Point `mayankjoshi.in` to GitHub Pages by adding these records in your registrar's DNS panel:

### A Records (apex domain)
| Type | Name | Value |
|------|------|-------|
| A | @ | 185.199.108.153 |
| A | @ | 185.199.109.153 |
| A | @ | 185.199.110.153 |
| A | @ | 185.199.111.153 |

### AAAA Records (IPv6 — optional but recommended)
| Type | Name | Value |
|------|------|-------|
| AAAA | @ | 2606:50c0:8000::153 |
| AAAA | @ | 2606:50c0:8001::153 |
| AAAA | @ | 2606:50c0:8002::153 |
| AAAA | @ | 2606:50c0:8003::153 |

### www redirect (optional)
| Type | Name | Value |
|------|------|-------|
| CNAME | www | consciousmayank.github.io |

DNS propagation typically takes 10–30 minutes, up to 24 hours in rare cases.

---

## Known Upgrade Path: PHP Mailer

The contact form currently POSTs to `/mailer/contact.php`. GitHub Pages only serves static files — PHP is not supported. Options when ready:

1. **Formspree** (free tier) — replace the POST target with a Formspree endpoint, no backend needed
2. **Netlify Forms** — if you ever move to Netlify hosting
3. **GitHub Actions + email API** — e.g. SendGrid or Resend triggered via a serverless function
