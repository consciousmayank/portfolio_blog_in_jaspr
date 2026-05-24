# syntax=docker/dockerfile:1.6
# Two-stage build: Flutter Web release → nginx:alpine with SPA fallback.

FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /src

COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter pub get
# --base-href / so go_router deep links resolve from the root.
# API base URL can be overridden at runtime via the Settings screen; default here
# matches production routing (same origin → Caddy proxies /api → portfolio-api).
RUN flutter build web --release \
      --base-href / \
      --dart-define=API_BASE_URL=

FROM nginx:alpine AS runtime
COPY --from=build /src/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
