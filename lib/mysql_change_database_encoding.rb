# mysql_change_database_encoding - Change a MySQL database's encoding and collation
#
# This is the main entry point for the library. It exposes the pieces that make
# up the command-line tool:
#
# - OptionsParser turns command-line arguments and environment variables into
#   an options hash.
# - DatabaseEncodingChanger takes that hash, alters the database's default
#   character set and collation, and then walks every base table applying the
#   same change.
# - DatabaseEncodingChangerTable is a reflection-only ActiveRecord model used to
#   inspect the table currently being migrated.
# - CLI wires the three together for the exe/ binary.
#
# Table alterations run through Percona's pt-online-schema-change when it is
# available and the table has a primary key, falling back to a direct ALTER
# TABLE when configured to do so.

require_relative "mysql_change_database_encoding/version"

module MysqlChangeDatabaseEncoding
  # Raised for user-facing errors: bad or insufficient command-line options,
  # and anything else the CLI should report as a message rather than a
  # backtrace.
  class Error < StandardError; end

  autoload :CLI, "mysql_change_database_encoding/cli"
  autoload :DatabaseEncodingChanger, "mysql_change_database_encoding/database_encoding_changer"
  autoload :DatabaseEncodingChangerTable, "mysql_change_database_encoding/database_encoding_changer_table"
  autoload :OptionsParser, "mysql_change_database_encoding/options_parser"
end

# Copyright (c) 2026 Durable Programming, LLC. All rights reserved.
# See LICENSE for details.
