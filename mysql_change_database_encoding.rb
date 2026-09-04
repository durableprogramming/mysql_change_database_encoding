#!/usr/bin/env ruby
# frozen_string_literal: true

# Deprecated entry point, kept so that existing invocations of
#
#   ruby mysql_change_database_encoding.rb --encoding utf8mb4
#
# keep working. New callers should use the exe/mysql-change-database-encoding
# binary, which is what the deb, rpm, and Docker packages install.

warn "WARNING: running mysql_change_database_encoding.rb directly is deprecated; " \
     "use the mysql-change-database-encoding executable instead."

require_relative "lib/mysql_change_database_encoding"

exit MysqlChangeDatabaseEncoding::CLI.run(ARGV)

# Copyright (c) 2026 Durable Programming, LLC. All rights reserved.
# See LICENSE for details.
