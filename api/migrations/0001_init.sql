-- 0001_init.sql — baseline schema for portfolio_blog dynamic CMS.

CREATE TABLE IF NOT EXISTS _schema_migrations (
    version    INT PRIMARY KEY,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE admin_users (
    id            BIGSERIAL PRIMARY KEY,
    email         TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE blog_posts (
    id               BIGSERIAL PRIMARY KEY,
    slug             TEXT NOT NULL UNIQUE,
    title            TEXT NOT NULL,
    date             DATE NOT NULL,
    description      TEXT NOT NULL DEFAULT '',
    body_markdown    TEXT NOT NULL DEFAULT '',
    cover_image_path TEXT,
    published        BOOLEAN NOT NULL DEFAULT FALSE,
    sort_index       INT NOT NULL DEFAULT 0,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX blog_posts_published_date_idx ON blog_posts (published, date DESC);
CREATE INDEX blog_posts_slug_idx ON blog_posts (slug);

CREATE TABLE blog_post_tags (
    post_id BIGINT NOT NULL REFERENCES blog_posts(id) ON DELETE CASCADE,
    tag     TEXT NOT NULL,
    PRIMARY KEY (post_id, tag)
);

CREATE TABLE roles (
    id         BIGSERIAL PRIMARY KEY,
    company    TEXT NOT NULL,
    title      TEXT NOT NULL,
    start_year NUMERIC(6,2) NOT NULL,
    end_year   NUMERIC(6,2) NOT NULL,
    alt        BOOLEAN NOT NULL DEFAULT FALSE,
    sort_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE core_skills (
    id         BIGSERIAL PRIMARY KEY,
    name       TEXT NOT NULL,
    years      INT NOT NULL,
    percent    INT NOT NULL,
    hot        BOOLEAN NOT NULL DEFAULT FALSE,
    sort_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE experiment_cards (
    id         BIGSERIAL PRIMARY KEY,
    code       TEXT NOT NULL,
    status     TEXT NOT NULL,
    title      TEXT NOT NULL,
    body       TEXT NOT NULL,
    meta       TEXT NOT NULL DEFAULT '',
    span       INT NOT NULL DEFAULT 4,
    sort_index INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE experiment_card_demo (
    card_id BIGINT NOT NULL REFERENCES experiment_cards(id) ON DELETE CASCADE,
    idx     INT NOT NULL,
    line    TEXT NOT NULL,
    style   TEXT NOT NULL,
    PRIMARY KEY (card_id, idx)
);

CREATE TABLE site_lists (
    list_key TEXT NOT NULL,
    idx      INT NOT NULL,
    value    TEXT NOT NULL,
    PRIMARY KEY (list_key, idx)
);

CREATE TABLE contact_messages (
    id              BIGSERIAL PRIMARY KEY,
    name            TEXT NOT NULL,
    email           TEXT NOT NULL,
    subject         TEXT NOT NULL,
    message         TEXT NOT NULL,
    ip              INET,
    user_agent      TEXT,
    delivered       BOOLEAN NOT NULL DEFAULT FALSE,
    smtp_message_id TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX contact_messages_created_at_idx ON contact_messages (created_at DESC);
