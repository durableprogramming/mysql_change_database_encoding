require "test_helper"

class CLITest < Minitest::Test
  def setup
    @cli = MysqlChangeDatabaseEncoding::CLI
    @before_env = ENV.to_h
  end

  def teardown
    ENV.clear
    ENV.merge!(@before_env)
  end

  def test_run_reports_option_errors_and_exits_non_zero
    status = nil
    err = capture_io { status = @cli.run([]) }.last

    assert_equal 1, status
    assert_includes err, "One of ENCODING or COLLATION must be specified"
  end

  def test_run_reports_missing_alteration_method
    status = nil
    err = capture_io do
      status = @cli.run(["--encoding", "utf8", "--no-direct_alter_table", "--no-osc"])
    end.last

    assert_equal 1, status
    assert_includes err, "Either --direct_alter_table or --osc must be enabled."
  end

  def test_run_connects_and_delegates_to_the_changer
    changer = Minitest::Mock.new
    changer.expect(:run!, nil)

    connected_with = nil
    connect = ->(options) { connected_with = options }

    status = nil
    @cli.stub(:establish_connection, connect) do
      MysqlChangeDatabaseEncoding::DatabaseEncodingChanger.stub(:new, changer) do
        capture_io { status = @cli.run(["--encoding", "utf8mb4", "--database", "widgets"]) }
      end
    end

    assert_equal 0, status
    assert_equal "widgets", connected_with[:database]
    assert_equal "utf8mb4", connected_with[:encoding]
    changer.verify
  end
end

# Copyright (c) 2026 Durable Programming, LLC. All rights reserved.
# See LICENSE for details.
