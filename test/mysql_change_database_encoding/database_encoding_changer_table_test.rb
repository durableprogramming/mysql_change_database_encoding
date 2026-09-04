# frozen_string_literal: true

require "test_helper"

class DatabaseEncodingChangerTableTest < Minitest::Test
  Model = MysqlChangeDatabaseEncoding::DatabaseEncodingChangerTable

  def setup
    ActiveRecord::Schema.define do
      create_table "table_with_primary_key" do |t|
        t.text "test"
      end

      create_table "table_without_primary_key", id: false do |t|
        t.text "test"
      end
    end
  end

  def teardown
    ActiveRecord::Schema.define do
      drop_table "table_with_primary_key"
      drop_table "table_without_primary_key"
    end

    # The model is repointed at a different table for every table the tool
    # migrates, so reset the class-level state it caches rather than leaking it
    # into the next test.
    Model.use_table(nil)
  end

  def test_eligible_for_online_schema_change_with_primary_key
    Model.use_table "table_with_primary_key"

    assert_equal true, Model.eligible_for_online_schema_change?
  end

  def test_not_eligible_for_online_schema_change_without_primary_key
    Model.use_table "table_without_primary_key"

    refute_includes Model.columns.map(&:name), "id"
    assert_equal false, Model.eligible_for_online_schema_change?
  end
end

# Copyright (c) 2026 Durable Programming, LLC. All rights reserved.
# See LICENSE for details.
