# Copyright 2026, Durable Programming, LLC. All rights reserved.
# See LICENSE for license details.

FROM ruby:3.3-slim AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential libmariadb-dev git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# The gemspec reads the version file and shells out to git ls-files, so both
# need to be present before the gem can be built.
COPY . .
RUN gem build mysql_change_database_encoding.gemspec -o mysql_change_database_encoding.gem


FROM ruby:3.3-slim

# libmariadb3 provides the client library mysql2 links against, and
# percona-toolkit supplies pt-online-schema-change, which the tool uses to
# alter tables without locking them.
#
# The build toolchain is needed to compile the mysql2 native extension and is
# removed afterwards so that it does not ship in the final image.
COPY --from=build /build/mysql_change_database_encoding.gem /tmp/
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libmariadb3 \
        default-mysql-client \
        percona-toolkit \
    && apt-get install -y --no-install-recommends build-essential libmariadb-dev \
    && gem install --no-document /tmp/mysql_change_database_encoding.gem \
    && rm /tmp/mysql_change_database_encoding.gem \
    && apt-get purge -y build-essential libmariadb-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --uid 1000 appuser
USER appuser

ENTRYPOINT ["mysql-change-database-encoding"]
CMD ["--help"]
