# frozen_string_literal: true

# Copyright 2018, David Berube. All rights reserved.
# See LICENSE for license details.
#
# ActiveRecord model backing the table currently being processed by
# DatabaseEncodingChanger. table_name is reassigned at runtime to point this
# model at whichever base table is being migrated. This model is used purely
# for schema reflection, never for reading, creating, updating, or deleting
# row data.
#
# eligible_for_online_schema_change? reports whether the table has a primary
# key. pt-online-schema-change requires one to operate, so tables without a
# primary key must fall back to a direct ALTER TABLE or be skipped.

require "active_record"

module MysqlChangeDatabaseEncoding
  class DatabaseEncodingChangerTable < ActiveRecord::Base
    # This model is used to represent the current table being processed.
    # Since this is a data migration tool, this is only used for
    # reflection purposes, and not creating, updating, or deleting data;
    # use of this model allows us to access ActiveRecord's API for
    # retrieving MySQL table metadata.

    # Point the model at another table, discarding the schema information
    # cached for the previous one.
    #
    # ActiveRecord memoizes both column information and the primary key per
    # class, and assigning table_name alone does not clear the memoized primary
    # key. Since this single class is repointed at every table in the database
    # in turn, stale metadata would otherwise carry over from one table to the
    # next.
    #
    # @param name [String, nil] the table to reflect on
    # @return [void]
    def self.use_table(name)
      self.table_name = name
      reset_column_information
      connection.schema_cache.clear!
    end

    # Whether pt-online-schema-change can operate on this table.
    #
    # Read from the connection rather than from the memoized self.primary_key,
    # so the answer describes the table currently assigned to table_name.
    #
    # @return [Boolean]
    def self.eligible_for_online_schema_change?
      return false if table_name.nil?

      primary_keys = connection.primary_keys(table_name)

      !(primary_keys.nil? || primary_keys.empty?)
    end
  end
end

# Copyright (c) 2026 Durable Programming, LLC. All rights reserved.
# See LICENSE for details.
