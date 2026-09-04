# Copyright 2026, Durable Programming, LLC. All rights reserved.
# See LICENSE for license details.

FROM ruby:3.3-alpine AS build

RUN apk add --no-cache build-base mariadb-dev git

WORKDIR /build

# The gemspec reads the version file and shells out to git ls-files, so both
# need to be present before the gem can be built.
COPY . .
RUN gem build mysql_change_database_encoding.gemspec -o mysql_change_database_encoding.gem


FROM ruby:3.3-alpine

# mariadb-connector-c provides the client library mysql2 links against.
# percona-toolkit supplies pt-online-schema-change, which the tool uses to
# alter tables without locking them.
RUN apk add --no-cache mariadb-connector-c mariadb-client percona-toolkit

# Build dependencies are needed to compile the mysql2 native extension, then
# dropped so they do not ship in the final image.
COPY --from=build /build/mysql_change_database_encoding.gem /tmp/
RUN apk add --no-cache --virtual .build-deps build-base mariadb-dev \
    && gem install --no-document /tmp/mysql_change_database_encoding.gem \
    && rm /tmp/mysql_change_database_encoding.gem \
    && apk del .build-deps

RUN addgroup -g 1000 appuser \
    && adduser -D -u 1000 -G appuser appuser
USER appuser

ENTRYPOINT ["mysql-change-database-encoding"]
CMD ["--help"]
