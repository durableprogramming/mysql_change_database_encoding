require_relative './test_helper.rb'
require_relative '../lib/database_encoding_changer_table.rb'

class TestDatabaseEncodingChangerTable < Minitest::Test
  def setup
    
    ActiveRecord::Schema.define do
      create_table 'test_1' do |t|
        t.text "test"
      end
    end

    DatabaseEncodingChangerTable.table_name = 'test_1'
    @table = DatabaseEncodingChangerTable
  end

  def teardown
    ActiveRecord::Schema.define do
      drop_table 'test_1'
    end
  end

  def test_eligible_for_online_schema_change_with_primary_key

    assert_equal true, @table.eligible_for_online_schema_change?

  end

  def test_eligible_for_online_schema_change_without_primary_key

    ActiveRecord::Schema.define do
      create_table 'test_2', id: false do |t|
        t.text "test"
      end
    end

    DatabaseEncodingChangerTable.table_name = 'test_2' # reload schema info

    assert_equal false, @table.eligible_for_online_schema_change?
  end
end
