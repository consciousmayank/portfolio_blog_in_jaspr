# Deployment Guide — mayankjoshi.dev

## Publishing a New Blog Post

1. Create a new file: `blog_website/content/blog/my-new-post.md`
2. Add YAML frontmatter and write content in Markdown:
   ```markdown
   ---
   title: "My New Post"
   date: "2025-07-01"
   tags: ["flutter", "dart"]
   description: "Short excerpt shown on the blog listing page."
   ---

   Full post body here...
   ```
3. `git add blog_website/content/blog/my-new-post.md`
4. `git commit -m "New post: My New Post"`
5. `git push origin main`
6. GitHub Actions triggers automatically — Jaspr rebuilds the static site with the new post route included
7. Post is live at `https://mayankjoshi.dev/blog/my-new-post`

---

## GitHub Secrets Setup

Add these three secrets in **GitHub → Settings → Secrets → Actions**:

| Secret Name | Where to Find It |
|---|---|
| `FTP_HOST` | Hostinger cPanel → FTP Accounts → FTP server address |
| `FTP_USER` | Hostinger cPanel → FTP Accounts → Username |
| `FTP_PASS` | Hostinger cPanel → FTP Accounts → Password |

---

## One-Time Manual Setup (cPanel)

These files live outside the Jaspr build output and must be uploaded manually **once** via Hostinger cPanel File Manager. They persist across all future automated deploys.

1. Upload `public_html/mailer/contact.php` → `public_html/mailer/`
2. Upload `public_html/mailer/.htaccess` → `public_html/mailer/`
3. Upload `public_html/.htaccess` → `public_html/` (root URL rewrite rules)

### cPanel Settings
- **PHP Version**: MultiPHP Manager → set domain to **PHP 8.1+**
- **SSL/HTTPS**: SSL/TLS → enable "Force HTTPS Redirect"
- **Domain**: Domains → confirm `mayankjoshi.dev` maps to `public_html/`
- **Email**: Hostinger `mail()` is enabled by default on all shared plans — no extra config needed

---

## How the CI/CD Pipeline Works

Every `git push` to `main` triggers:
1. GitHub Actions checks out the repo
2. Dart SDK is set up
3. `dart pub get` installs dependencies in `blog_website/`
4. `jaspr build` generates static HTML/CSS/JS in `blog_website/build/jaspr/`
5. FTP Deploy Action uploads `build/jaspr/` contents to Hostinger `public_html/`

> **Note**: `dangerous-clean-slate: false` is intentional — this prevents the FTP action from wiping `public_html/mailer/` on every deploy. The `/mailer/` directory is NOT part of the Jaspr build output.

---

## Known Upgrade Path: PHP Mailer

If Hostinger's native `mail()` function is blocked or rate-limited in future:
1. Install PHPMailer via Composer in `public_html/mailer/`
2. Update `contact.php` to use Hostinger's SMTP credentials (available in cPanel → Email Accounts → SMTP settings)
3. Example:
   ```php
   $mail = new PHPMailer\PHPMailer\PHPMailer();
   $mail->isSMTP();
   $mail->Host = 'smtp.hostinger.com';
   $mail->SMTPAuth = true;
   $mail->Username = 'noreply@mayankjoshi.dev';
   $mail->Password = 'your-smtp-password';
   $mail->Port = 587;
   ```
