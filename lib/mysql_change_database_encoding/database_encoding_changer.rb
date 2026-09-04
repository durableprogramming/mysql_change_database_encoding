# frozen_string_literal: true

# Command-line tool logic for changing the character encoding and/or collation
# of a MySQL database and its tables. Given a set of options (database
# connection info, target encoding/collation, and behavior flags), this class:
#
# - Issues an ALTER DATABASE statement to change the database's default
# character set and/or collation.
# - Iterates over the base tables in the target database (via
# information_schema, using DatabaseEncodingChangerTable for per-table
# metadata) and alters each one to match, skipping tables that are already
# in the target collation unless :overwrite is set.
# - For each table, prefers running the ALTER TABLE via Percona's
# pt-online-schema-change (OSC) to avoid locking, when :osc is enabled and
# the table is eligible (i.e. it has a primary key). Falls back to a direct
# ALTER TABLE statement when OSC is disabled/ineligible and
# :direct_alter_table is set; otherwise the table is skipped.
# - Supports :skip_table_on_error to continue processing remaining tables
# after a SQL error instead of aborting the whole run.
#
# Expects an options hash (see OptionsParser) with keys such as
# :connection, :database, :encoding, :collation, :osc, :osc_options,
# :direct_alter_table, :skip_table_on_error, :overwrite, and :verbose, plus
# MySQL connection parameters (:host, :port, :user, :password) used to build
# the DSN passed to pt-online-schema-change.

require "active_record"
require "English"
require "shellwords"

module MysqlChangeDatabaseEncoding
  class DatabaseEncodingChanger
    def initialize(opts)
      @conn = opts.delete(:connection)

      @options = opts
    end

    def run!
      puts "Processing database settings."
      sql = "ALTER DATABASE #{conn.quote_column_name(@options[:database])}#{encoding_clause}#{collation_clause};"

      ActiveRecord::Migration.say_with_time "Setting database global settings." do
        run_sql_directly sql
      end

      table_list.each do |table|
        DatabaseEncodingChangerTable.use_table(table)

        verbose_puts "Processing #{table}"

        # Just the part following ALTER TABLE tablename, so that it can also be
        # handed to pt-online-schema-change as its --alter argument.
        sql_suffix = "#{convert_encoding_clause}#{collation_clause}"

        use_online_schema_change =  @options[:osc]

        if use_online_schema_change && !DatabaseEncodingChangerTable.eligible_for_online_schema_change?

          verbose_puts "#{table} is not eligible for online schema change."
          use_online_schema_change = false

        end

        if use_online_schema_change

          verbose_puts "Using online schema change for #{table}"

          run_sql_through_pt_osc table, sql_suffix

        elsif @options[:direct_alter_table]
          verbose_puts "Using direct ALTER TABLE for #{table}."

          # The full statement, needed to run the SQL directly.
          full_sql = "ALTER TABLE #{conn.quote_column_name(table)}#{sql_suffix};"

          ActiveRecord::Migration.say_with_time "Migrating without OSC" do
            run_sql_directly full_sql
          rescue ActiveRecord::StatementInvalid
            puts "MySQL Error: #{$ERROR_INFO}"
            puts "Raised during the execution of this SQL statement:"
            puts full_sql

            next if @options[:skip_table_on_error]

            raise
          end
        else
          puts "Skipping #{table}."

        end
      end
    end

    private

    # The " CHARACTER SET x" fragment of an ALTER DATABASE statement, or an
    # empty string when no encoding was requested.
    def encoding_clause
      @options[:encoding] ? " CHARACTER SET #{@options[:encoding]}" : ""
    end

    # The ALTER TABLE spelling of the same thing.
    def convert_encoding_clause
      @options[:encoding] ? " CONVERT TO CHARACTER SET #{@options[:encoding]}" : ""
    end

    # The " COLLATE x" fragment shared by both statements, or an empty string
    # when no collation was requested.
    def collation_clause
      @options[:collation] ? " COLLATE #{@options[:collation]}" : ""
    end

    def run_sql_directly(sql)
      puts "Running SQL:"
      puts sql
      conn.execute sql
    end

    def run_sql_through_pt_osc(table, sql)
      puts "This SQL will be run using pt-online-schema-change:"
      puts sql
      puts "The following command will be run:"
      cmd = "pt-online-schema-change --execute #{@options[:osc_options]} " \
            "--alter #{Shellwords.escape(sql)} #{Shellwords.escape(pt_dsn(table))}"
      puts cmd
      system cmd
    end

    def pt_dsn(table)
      options = {
        "D" => @options[:database],
        "h" => @options[:host],
        "p" => @options[:password],
        "P" => @options[:port],
        "u" => @options[:user],
        "t" => table
      }

      options.map { |k, v| "#{k}=#{v.gsub("\\", "\\\\").gsub(",", '\\,')}" }.join(",")
    end

    def verbose_puts(msg)
      return unless @options[:verbose]

      puts msg
    end

    def table_list
      if @options[:overwrite]
        conn.execute("SELECT table_name FROM information_schema.tables WHERE
                      table_type = 'BASE TABLE'
                      AND table_schema=#{conn.quote(@options[:database])}
                      ;").to_a.flatten
      else
        conn.execute("SELECT table_name FROM information_schema.tables WHERE
                      table_type = 'BASE TABLE'
                      AND table_schema=#{conn.quote(@options[:database])}
                      AND table_collation <> #{conn.quote(@options[:collation])}
                      ;").to_a.flatten
      end
    end

    def conn
      @conn ||= ActiveRecord::Base.connection
    end
  end
end

# Copyright (c) 2026 Durable Programming, LLC. All rights reserved.
# See LICENSE for details.
