# portfolio_blog — Dynamic CMS Deployment Handoff

> Snapshot date: 2026-05-24. Production at **https://mayankjoshi.in** (and admin at **https://admin.mayankjoshi.in**).

## What this repo is now

A **dynamic, server-rendered** portfolio + blog backed by Postgres, with a Flutter admin app for content editing. The static Jaspr build + PHP mailer are gone — Jaspr now runs in `mode: server`, Dart Shelf serves the API, and Postgres holds blog posts + all home-page content.

## Stack

```
                       Internet :443
                             │
            ┌────────────── Caddy (in /srv/edge/, separate stack) ──────────────┐
            │  mayankjoshi.in / www.mayankjoshi.in                              │
            │    /api/*       → portfolio-api:8080                              │
            │    /uploads/*   → file_server /srv/portfolio_blog/uploads         │
            │    everything   → portfolio-web:8080  (Jaspr SSR)                 │
            │  admin.mayankjoshi.in  → portfolio-admin-web:80                    │
            └─────────────────────────────┬────────────────────────────────────┘
                                          │  docker network "edge" (external)
                  ┌───────────────────────┼─────────────────────────┐
                  ▼                       ▼                          ▼
          portfolio-web           portfolio-api               portfolio-admin-web
          (Jaspr server)          (Dart Shelf)                (Flutter Web + nginx)
                                       │
                                       │  docker network "portfolio-net" (internal)
                                       ▼
                              portfolio-postgres
                              (volume: pgdata)
```

| Service | Image / Source | Network(s) | Notes |
|---|---|---|---|
| postgres | `postgres:16-alpine` | portfolio-net | Volume `pgdata`. Internal-only — no edge exposure. |
| api | `./api` (Dart Shelf, AOT) | portfolio-net + edge | Runs migrations on start. Mounts `./uploads`. |
| web | `./blog_website` (Jaspr SSR) | edge | Reads from API via `API_BASE_URL=http://api:8080`. |
| admin-web | `./admin` (Flutter Web) | edge | nginx serves SPA at `admin.mayankjoshi.in`. |

The old `portfolio-php` and `Dockerfile.php` are removed.

## Repository layout

```
portfolio_blog/
├── api/                          # Dart Shelf service
│   ├── bin/server.dart           # entry — connects DB, runs migrator, wires routes
│   ├── lib/
│   │   ├── auth/                 # JWT issue/verify + seed_admin
│   │   ├── db/                   # pool + migrator
│   │   ├── middleware/           # cors + bearer-token guard
│   │   ├── routes/
│   │   │   ├── admin/            # blog/roles/skills/experiments/lists/media/messages/password
│   │   │   ├── admin_auth.dart   # POST /api/admin/login
│   │   │   ├── blog.dart         # GET /api/blog, GET /api/blog/:slug
│   │   │   ├── contact.dart      # POST /api/contact (rate-limit + honeypot)
│   │   │   └── site.dart         # GET /api/site bundle
│   │   └── services/             # mail (Gmail SMTP), rate_limit
│   ├── migrations/0001_init.sql, 0002_seed.sql
│   ├── tool/import_md.dart       # one-shot — generated 0002 blog inserts, kept for reference
│   ├── Dockerfile, pubspec.yaml
├── admin/                        # Flutter app (android/ios/web/macos/linux/windows enabled)
│   ├── lib/{api,auth,routes,screens}/
│   ├── Dockerfile, nginx.conf    # web build only ships in CI
├── blog_website/                 # Jaspr (mode: server)
│   ├── lib/data/api_client.dart  # typed HTTP client used by pages
│   ├── lib/components/contact_form.dart  # @client form posting to /api/contact
│   ├── lib/pages/{home,blog_post}_page.dart  # PreloadStateMixin + SyncStateMixin
│   ├── lib/sections/             # all take data as constructor params now
│   └── Dockerfile
├── uploads/                      # bind-mounted into api at /app/uploads
├── docker-compose.yml            # 4 services on two networks
├── .env.example                  # copy to /srv/portfolio_blog/.env on the VPS
└── .github/workflows/deploy.yml  # SSH → git reset --hard → compose build + up
```

## VPS coordinates

- IP: `187.127.172.150`, user `deploy` (sudo, key-only)
- Project: `/srv/portfolio_blog/` (public-HTTPS clone)
- Uploads root: `/srv/portfolio_blog/uploads/`
- Edge stack: `/srv/edge/` (Caddy + its compose file — out of repo)

## First-time setup on the VPS

**Pre-deploy prerequisite:** enable 2FA on `consciousmayank@gmail.com` and generate a 16-char App Password at https://myaccount.google.com/apppasswords.

```bash
ssh deploy@187.127.172.150
cd /srv/portfolio_blog

# 1. Create .env from the template (NEVER commit this file)
cp .env.example .env
$EDITOR .env   # fill in DB_PASSWORD, JWT_SECRET, GMAIL_APP_PASSWORD, SEED_ADMIN_PASSWORD

# 2. Boot Postgres first and wait for the healthcheck
docker compose up -d postgres
docker compose ps        # postgres should be "(healthy)"

# 3. Boot the API — runs migrations + seeds admin on first start
docker compose up -d api
docker compose logs -f api    # confirm: "applying 0001_init.sql", "applying 0002_seed.sql",
                              # "seed_admin: created admin user consciousmayank@gmail.com",
                              # "portfolio-api listening on :8080"

# 4. Boot the web + admin
docker compose up -d web admin-web

# 5. Wire Caddy (see "Edge config" below)
```

## Edge config — `/srv/edge/Caddyfile`

These edits live on the VPS, NOT in this repo. Replace the previous `mayankjoshi.in` block with:

```caddy
mayankjoshi.in, www.mayankjoshi.in {
    handle_path /api/* {
        reverse_proxy api:8080
    }
    handle_path /uploads/* {
        root * /srv/portfolio_blog/uploads
        file_server
    }
    reverse_proxy web:8080
}

admin.mayankjoshi.in {
    reverse_proxy admin-web:80
}
```

After editing:
```bash
cd /srv/edge
docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile
```

**DNS**: add `admin.mayankjoshi.in` as a CNAME → `mayankjoshi.in` (or A → `187.127.172.150`). Caddy auto-provisions Let's Encrypt on first hit.

## GitHub Actions secrets

At https://github.com/consciousmayank/portfolio_blog_in_jaspr/settings/secrets/actions :

- `VPS_HOST` = `187.127.172.150`
- `VPS_USER` = `deploy`
- `VPS_SSH_KEY` = full PEM block from `~/dev/live_projects/_vps_bootstrap/github_actions_private_key.txt`

The workflow at `.github/workflows/deploy.yml` then runs on every push to `main`:
SSH → `git fetch && git reset --hard origin/main` → `docker compose build api web admin-web` → `docker compose up -d` → smoke-test `/health`.

## Local dev

The Jaspr site and Flutter admin can both run against a locally-launched API.

```bash
# Boot Postgres + API locally (uses .env if present)
docker compose up -d postgres api

# Jaspr server (port 8080 is API; jaspr serve picks its own port)
cd blog_website && dart pub get && dart run build_runner build --delete-conflicting-outputs
~/.pub-cache/bin/jaspr serve

# Flutter admin (web)
cd ../admin && flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

## Operational cheat sheet

```bash
# (always from /srv/portfolio_blog on the VPS)

docker compose ps
docker compose logs -f api
docker compose logs -f web

# Rebuild + restart one service after pulling
docker compose build api && docker compose up -d api

# Inspect DB
docker compose exec postgres psql -U portfolio -d portfolio -c '\dt'
docker compose exec postgres psql -U portfolio -d portfolio -c 'SELECT slug, published, date FROM blog_posts ORDER BY date DESC;'

# Backup DB (manual)
docker compose exec -T postgres pg_dump -U portfolio portfolio | gzip > "pg-$(date +%F).sql.gz"

# Tail nginx access on the admin
docker compose logs -f admin-web

# Try the public contact form end-to-end
curl -X POST https://mayankjoshi.in/api/contact \
  -H 'content-type: application/json' \
  -d '{"name":"Test","email":"t@t.com","subject":"hi","message":"hello"}'
```

## Rotating the admin password

Seed password is consumed on first boot and never persisted in app memory. After first login at `https://admin.mayankjoshi.in`:

1. Go to Settings.
2. Enter the seeded password + a new one (min 12 chars) twice.
3. Save.

The `SEED_ADMIN_PASSWORD` env var in `.env` is from then on inert — clean up the line for hygiene.

## Cutover from the previous static stack

1. Land everything on `feat/dynamic-cms`. The current static deploy stays live until you bring the new stack up.
2. SSH to VPS, `git checkout feat/dynamic-cms`, do "First-time setup" above.
3. Smoke-test on the `edge` network *before* touching Caddyfile:
   ```bash
   docker exec edge-caddy curl -s http://api:8080/health
   docker exec edge-caddy curl -s http://api:8080/api/blog | jq length    # expect 7
   docker exec edge-caddy curl -s http://web:8080/ | head -20             # expect SSR'd HTML
   docker exec edge-caddy curl -s http://admin-web:80/ | head -10
   ```
4. Edit `/srv/edge/Caddyfile` (see "Edge config" above). Keep the OLD `file_server` block commented out as a one-line rollback.
5. `docker compose -f /srv/edge/docker-compose.yml exec caddy caddy reload --config /etc/caddy/Caddyfile`.
6. Verify from the public internet — load each blog URL, submit the contact form, log into admin.
7. Merge `feat/dynamic-cms` → `main` via PR.

**Rollback:** uncomment the old Caddyfile block, comment the new one, `caddy reload`. The previous `build/jaspr/` on disk is the rollback target — keep it for 30 days.

## Verification checklist

- [ ] `curl -sI https://mayankjoshi.in/` → 200 (content comes from DB, not a static file timestamp)
- [ ] `curl -s https://mayankjoshi.in/api/blog | jq length` → 7
- [ ] `curl -s https://mayankjoshi.in/api/site | jq '.roles | length'` → 4
- [ ] Each blog post URL renders with markdown
- [ ] Contact form on the homepage submits → email arrives at `consciousmayank@gmail.com` within ~10s, row in `contact_messages` with `delivered=true`
- [ ] Login at `https://admin.mayankjoshi.in/`, create a draft (`published=false`) — verify it does NOT show on the public home page
- [ ] Toggle `published=true` → reload home page → new post appears immediately (no rebuild)
- [ ] Upload a cover image from the admin → `/uploads/...` URL → image renders on the public blog page
- [ ] `docker compose ps` shows `postgres`, `api`, `web`, `admin-web` all `Up (healthy)` — and NO `portfolio-php`

## Explicitly out of scope (today)

Analytics, draft preview URLs, comments, FT search, RSS, dynamic sitemap, 2FA, iOS App Store distribution, S3/MinIO uploads, CDN, automated DB backups, image transforms, editor collaboration, custom-domain From-address for mail. Each is a small follow-up if needed.
