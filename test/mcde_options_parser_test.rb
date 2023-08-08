require 'minitest/autorun'
require_relative '../lib/mcde_options_parser.rb'
require_relative './test_helper.rb'

class McdeOptionsParserTest < Minitest::Test
  def setup
    @before_env = ENV.to_h
    @before_argv = ARGV.dup
    ARGV.clear
    @options_parser = McdeOptionsParser
  end

  def teardown
    ENV.clear
    ENV.merge!(@before_env)
    ARGV.clear
    ARGV.append(*@before_argv)
  end

  def test_parse_with_defaults
    ARGV.push '--encoding'
    ARGV.push 'utf8'

    options = @options_parser.parse!
    assert_equal '127.0.0.1', options[:host]
    assert_equal '', options[:database]
    assert_equal '', options[:port]
    assert_equal 'root', options[:user]
    assert_equal '', options[:password]
    assert_equal false, options[:direct_alter_table]
    assert_equal true, options[:osc]
    assert_equal '', options[:osc_options]
    assert_equal false, options[:skip_table_on_error]
    assert_equal false, options[:overwrite]
  end

  def test_parse_with_custom_options
    ARGV.push '--encoding'
    ARGV.push 'custom_encoding'
    ARGV.push '--collation'
    ARGV.push 'custom_collation'
    ARGV.push '--host'
    ARGV.push 'custom_host'
    ARGV.push '--database'
    ARGV.push 'custom_database'
    ARGV.push '--port'
    ARGV.push 'custom_port'
    ARGV.push '--user'
    ARGV.push 'custom_user'
    ARGV.push '--password'
    ARGV.push 'custom_password'

    options = @options_parser.parse!

    assert_equal 'custom_host', options[:host]
    assert_equal 'custom_database', options[:database]
    assert_equal 'custom_port', options[:port]
    assert_equal 'custom_user', options[:user]
    assert_equal 'custom_password', options[:password]
    assert_equal false, options[:direct_alter_table]
    assert_equal true, options[:osc]
    assert_equal '', options[:osc_options]
    assert_equal false, options[:skip_table_on_error]
    assert_equal false, options[:overwrite]
  end

  def test_parsing_an_encoding
    ARGV.push '--encoding'
    ARGV.push 'custom_encoding'
    options = @options_parser.parse!
    assert_equal 'custom_encoding', options[:encoding]
    assert_nil options[:collation]
  end

  def test_parsing_a_collation
    ARGV.push '--collation'
    ARGV.push 'custom_collation'

    options = @options_parser.parse!
    assert_nil options[:encoding]
    assert_equal 'custom_collation', options[:collation]
  end

  def test_parsing_without_encoding
    error = assert_raises(RuntimeError) do
      options = @options_parser.parse!
    end
    assert_equal "ERROR: One of ENCODING or COLLATION must be specified. Hint: try \"--encoding utf8mb4\".", error.message
  end

  def test_raises_when_no_method
    ARGV.push '--encoding'
    ARGV.push 'custom_encoding'
    ARGV.push '--collation'
    ARGV.push 'custom_collation'
    ARGV.push '--no-direct_alter_table'
    ARGV.push '--no-osc'

    error = assert_raises(RuntimeError) do
      options = @options_parser.parse!
    end
    assert_equal "ERROR: Either --direct_alter_table or --osc must be enabled.", error.message
  end
end
