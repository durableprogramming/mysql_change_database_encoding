# Copyright 2024, Durable Programming, LLC. All rights reserved.
# See LICENSE for license details.

FROM ruby:3.1-alpine

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    mysql-dev \
    mysql-client \
    bash \
    && rm -rf /var/cache/apk/*

# Create application directory
WORKDIR /app

# Copy Gemfile and install Ruby dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copy application files
COPY mysql_change_database_encoding.rb ./
COPY lib/ ./lib/
COPY README.md LICENSE ./

# Create a non-root user
RUN addgroup -g 1000 appuser && \
    adduser -D -u 1000 -G appuser appuser
USER appuser

# Set the entrypoint
ENTRYPOINT ["ruby", "mysql_change_database_encoding.rb"]
CMD ["--help"]
