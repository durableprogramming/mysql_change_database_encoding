# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "minitest/mock"
require "minitest/reporters"
require "active_record"
require "sqlite3"

require "mysql_change_database_encoding"

Minitest::Reporters.use!

# The table-reflection tests need a real database to introspect. sqlite3 in
# memory is enough: the assertions are about primary keys and column metadata,
# not about MySQL-specific behavior.
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

# Schema definitions are noisy and the output is not useful in test runs.
ActiveRecord::Migration.verbose = false

# Copyright (c) 2026 Durable Programming, LLC. All rights reserved.
# See LICENSE for details.
