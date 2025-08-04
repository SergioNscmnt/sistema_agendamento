# syntax = docker/dockerfile:1

ARG RUBY_VERSION=3.2.8
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base
WORKDIR /app

ENV RAILS_ENV="production" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    BUNDLE_FROZEN="0" \
    BUNDLE_DEPLOYMENT="0"

# --- Build stage: instala dev-tools, gems e compila assets
FROM base as build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git libpq-dev libvips-dev pkg-config libyaml-dev imagemagick ruby-dev

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf /root/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache \
           "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .
RUN bundle exec bootsnap precompile app/ lib/ && \
    SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile

# --- Final stage: só copia o que já foi instalado/compilado
FROM base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl postgresql-client libvips libpq-dev libyaml-dev git pkg-config && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app             /app

RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

EXPOSE 3000
CMD ["bash"]
