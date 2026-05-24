# syntax=docker/dockerfile:1.6
# Multi-stage build: AOT-compile the Shelf API, ship a thin runtime image.

FROM dart:stable AS build
WORKDIR /src

COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/server.dart -o /src/bin/server

FROM debian:bookworm-slim AS runtime
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates wget \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /src/bin/server /app/server
COPY --from=build /src/migrations /app/migrations
RUN mkdir -p /app/uploads

EXPOSE 8080
ENV PORT=8080
CMD ["/app/server"]
