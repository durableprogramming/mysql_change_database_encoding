require_relative './test_helper'
require_relative '../lib/database_encoding_changer'

class DatabaseEncodingChangerTest < Minitest::Test
  def setup
    @connection = Minitest::Mock.new
    @options = {
      database: 'test_db',
      encoding: 'utf8',
      collation: 'utf8_general_ci',
      osc: false,
      direct_alter_table: true,
      skip_table_on_error: false,
      verbose: true,
      overwrite: false
    }
    @changer = DatabaseEncodingChanger.new(connection: @connection, **@options)
  end

  def test_run

    @connection.expect(:quote_column_name, '`test_db`', ['test_db'])
    @connection.expect(:quote_column_name, '`table1`', ['table1'])
    @connection.expect(:quote_column_name, '`table2`', ['table2'])

    @connection.expect(:execute, nil, ['ALTER DATABASE `test_db` CHARACTER SET utf8 COLLATE utf8_general_ci;'])
    @connection.expect(:execute, nil, ['ALTER TABLE `table1` CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;'])
    @connection.expect(:execute, nil, ['ALTER TABLE `table2` CONVERT TO CHARACTER SET utf8 COLLATE utf8_general_ci;'])

    @changer.stub(:table_list, ['table1', 'table2']) do
      @changer.stub(:run_sql_through_pt_osc, nil) do
        @changer.stub(:verbose_puts, nil) do
          @changer.run!
        end
      end
    end

    @connection.verify

  end
end
