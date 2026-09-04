# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create do |t|
  t.test_prelude = format(%(require "simplecov"; SimpleCov.start { skip %p }), "/test/")
  t.test_globs = FileList["test/**/*_test.rb", "test/**/test_*.rb"]
  t.framework = %(require "test/test_helper.rb")
end

begin
  require "rubocop/rake_task"
  RuboCop::RakeTask.new
rescue LoadError
  # RuboCop is a development dependency; skip the task when it is unavailable.
end

task default: :test
