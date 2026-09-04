# frozen_string_literal: true

# Command-line option parsing for the database encoding changer tool. Defines
# OptionsParser.parse!, which builds and returns an options hash consumed by
# DatabaseEncodingChanger.
#
# Defaults are seeded from environment variables (MYSQL_HOST, MYSQL_DATABASE,
# MYSQL_PORT, MYSQL_USER, MYSQL_PASSWORD) and from detecting whether
# pt-online-schema-change is available on PATH (via `which`), which seeds
# :pt_online_schema_change_path and determines whether :osc defaults to true.
#
# Recognized flags cover MySQL connection info (--host, --port, --database,
# --user, --password), the migration target (--encoding, --collation, at least
# one of which is required), and behavior flags (--direct-alter-table, --osc,
# --osc-options, --overwrite, --skip-table-on-error, --verbose).
#
# After parsing, validates the result and raises a RuntimeError if:
# - neither :encoding nor :collation was specified, or
# - neither :direct_alter_table nor :osc is enabled (no way to alter tables).
#
# If pt-online-schema-change is not found but --osc was left at its default,
# :osc is silently disabled with a warning rather than raising an error.

require "optparse"

module MysqlChangeDatabaseEncoding
  module OptionsParser
    def self.parse!(argv = ARGV)
      options = {}

      # set defaults:

      options[:host]                = ENV["MYSQL_HOST"]     || "127.0.0.1"
      options[:database]            = ENV["MYSQL_DATABASE"] || ""
      options[:port]                = ENV["MYSQL_PORT"] || ""
      options[:user]                = ENV["MYSQL_USER"] || "root"
      options[:password]            = ENV["MYSQL_PASSWORD"] || ""
      options[:direct_alter_table]  = false
      options[:osc]                 = true
      options[:osc_options]         = ""
      options[:skip_table_on_error] = false
      options[:overwrite]           = false

      options[:pt_online_schema_change_path] = `which pt-online-schema-change`.strip

      OptionParser.new do |opts|
        opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

        opts.on("-H [HOST]", "--host [HOST]", "Connect to MySQL host HOST.") do |host|
          options[:host] = host
        end

        opts.on("-P [PORT]", "--port [PORT]", "Connect to MySQL port PORT.") do |port|
          options[:port] = port
        end

        opts.on("-D [DATABASE]", "--database [DATABASE]", "Connect to MySQL database DATABASE.") do |database|
          options[:database] = database
        end

        opts.on("-u [USER]", "--user [USER]", "Connect as MySQL user USER.") do |user|
          options[:user] = user
        end

        opts.on("-p [PASSWORD]", "--password [PASSWORD]", "Connect using MySQL password PASSWORD.") do |password|
          options[:password] = password
        end

        opts.on("-e [ENCODING]", "--encoding [ENCODING]",
                "Convert database to ENCODING. One of ENCODING or COLLATION must be specified.") do |encoding|
          options[:encoding] = encoding
        end

        opts.on("-U [COLLATION]", "--collation [COLLATION]",
                "Convert database to COLLATION. One of ENCODING or COLLATION must be specified.") do |collation|
          options[:collation] = collation
        end

        opts.on("--[no-]direct-alter-table",
                "If necessary, issue direct ALTER TABLE statements without OSC. This is used if",
                "pt-online-schema-change is not installed, if --no-osc is passed, or if a table",
                "does not have a primary key.") do |direct|
          options[:direct_alter_table] = direct
        end

        opts.on("--[no-]osc",
                "Enables online schema change using pt-online-schema-change. Defaults to true if",
                "pt-online-schema-change is installed.") do |osc|
          options[:osc] = osc
        end

        opts.on("--osc-options [OPTIONS]",
                "Sets optional parameters for pt-online-schema-change, which are passed on as-is.") do |osc_options|
          options[:osc_options] = osc_options
        end

        opts.on("-o", "--overwrite",
                "Optional parameter to overwrite the collation even if it is already migrated.") do |overwrite|
          options[:overwrite] = overwrite
        end

        opts.on("--[no-]skip-table-on-error",
                "If a SQL error occurs, continue to the next table; if not set, quit on SQL",
                "errors. Defaults to false.") do |skip|
          options[:skip_table_on_error] = skip
        end

        opts.on("-v", "--verbose", "Run with more output.") do |verbose|
          options[:verbose] = verbose
        end
      end.parse!(argv)

      if !options[:pt_online_schema_change_path] && options[:osc]
        puts "WARNING: pt_online_schema_change not detected; online schema change functionality disabled."
        options[:osc] = false
      end

      if !options[:encoding] && !options[:collation]
        raise Error, 'ERROR: One of ENCODING or COLLATION must be specified. Hint: try "--encoding utf8mb4".'
      end

      unless options[:direct_alter_table] || options[:osc]
        raise Error, "ERROR: Either --direct_alter_table or --osc must be enabled."
      end

      options
    end
  end
end

# Copyright (c) 2026 Durable Programming, LLC. All rights reserved.
# See LICENSE for details.
