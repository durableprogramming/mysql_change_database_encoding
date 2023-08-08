require 'bundler'
require 'minitest/autorun'

require 'minitest/mock'
require "minitest/reporters"
Minitest::Reporters.use!
require 'sqlite3'
require 'active_record'

ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
      database: ':memory:'
)
