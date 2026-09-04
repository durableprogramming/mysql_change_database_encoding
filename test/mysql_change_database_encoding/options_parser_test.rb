require "test_helper"

class OptionsParserTest < Minitest::Test
  def setup
    @before_env = ENV.to_h
    @options_parser = MysqlChangeDatabaseEncoding::OptionsParser
  end

  def teardown
    ENV.clear
    ENV.merge!(@before_env)
  end

  def test_parse_with_defaults
    options = @options_parser.parse!(["--encoding", "utf8"])

    assert_equal "127.0.0.1", options[:host]
    assert_equal "", options[:database]
    assert_equal "", options[:port]
    assert_equal "root", options[:user]
    assert_equal "", options[:password]
    assert_equal false, options[:direct_alter_table]
    assert_equal true, options[:osc]
    assert_equal "", options[:osc_options]
    assert_equal false, options[:skip_table_on_error]
    assert_equal false, options[:overwrite]
  end

  def test_parse_with_custom_options
    options = @options_parser.parse!(
      [
        "--encoding", "custom_encoding",
        "--collation", "custom_collation",
        "--host", "custom_host",
        "--database", "custom_database",
        "--port", "custom_port",
        "--user", "custom_user",
        "--password", "custom_password"
      ]
    )

    assert_equal "custom_host", options[:host]
    assert_equal "custom_database", options[:database]
    assert_equal "custom_port", options[:port]
    assert_equal "custom_user", options[:user]
    assert_equal "custom_password", options[:password]
    assert_equal false, options[:direct_alter_table]
    assert_equal true, options[:osc]
    assert_equal "", options[:osc_options]
    assert_equal false, options[:skip_table_on_error]
    assert_equal false, options[:overwrite]
  end

  def test_parse_reads_connection_defaults_from_the_environment
    ENV["MYSQL_HOST"] = "env_host"
    ENV["MYSQL_DATABASE"] = "env_database"
    ENV["MYSQL_PORT"] = "3307"
    ENV["MYSQL_USER"] = "env_user"
    ENV["MYSQL_PASSWORD"] = "env_password"

    options = @options_parser.parse!(["--encoding", "utf8"])

    assert_equal "env_host", options[:host]
    assert_equal "env_database", options[:database]
    assert_equal "3307", options[:port]
    assert_equal "env_user", options[:user]
    assert_equal "env_password", options[:password]
  end

  def test_command_line_arguments_override_the_environment
    ENV["MYSQL_HOST"] = "env_host"

    options = @options_parser.parse!(["--encoding", "utf8", "--host", "argv_host"])

    assert_equal "argv_host", options[:host]
  end

  def test_parse_does_not_consume_the_global_argv
    before = ARGV.dup

    @options_parser.parse!(["--encoding", "utf8"])

    assert_equal before, ARGV
  end

  def test_parsing_an_encoding
    options = @options_parser.parse!(["--encoding", "custom_encoding"])

    assert_equal "custom_encoding", options[:encoding]
    assert_nil options[:collation]
  end

  def test_parsing_a_collation
    options = @options_parser.parse!(["--collation", "custom_collation"])

    assert_nil options[:encoding]
    assert_equal "custom_collation", options[:collation]
  end

  def test_parsing_without_encoding
    error = assert_raises(MysqlChangeDatabaseEncoding::Error) do
      @options_parser.parse!([])
    end

    assert_equal 'ERROR: One of ENCODING or COLLATION must be specified. Hint: try "--encoding utf8mb4".',
                 error.message
  end

  def test_raises_when_no_method
    error = assert_raises(MysqlChangeDatabaseEncoding::Error) do
      @options_parser.parse!(
        [
          "--encoding", "custom_encoding",
          "--collation", "custom_collation",
          "--no-direct_alter_table",
          "--no-osc"
        ]
      )
    end

    assert_equal "ERROR: Either --direct_alter_table or --osc must be enabled.", error.message
  end
end

# Copyright (c) 2026 Durable Programming, LLC. All rights reserved.
# See LICENSE for details.
