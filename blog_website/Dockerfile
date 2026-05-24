# syntax=docker/dockerfile:1.6
# Multi-stage build for Jaspr server-mode app.
#  Stage 1: install jaspr CLI + deps, build the SSR bundle
#  Stage 2: thin debian:slim runtime with the AOT binary + static web/

FROM dart:stable AS build
WORKDIR /src

COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline

# jaspr build produces build/jaspr/ containing the AOT-compiled server
# binary plus client assets (web/).
RUN dart pub global activate jaspr_cli \
 && /root/.pub-cache/bin/jaspr build --verbose

FROM debian:bookworm-slim AS runtime
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /src/build/jaspr/ /app/

EXPOSE 8080
ENV PORT=8080
# jaspr names the server binary "app" inside build/jaspr/.
CMD ["/app/app"]
