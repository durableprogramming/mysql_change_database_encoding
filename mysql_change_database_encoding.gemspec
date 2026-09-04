# frozen_string_literal: true

require_relative "lib/mysql_change_database_encoding/version"

Gem::Specification.new do |spec|
  spec.name = "mysql_change_database_encoding"
  spec.version = MysqlChangeDatabaseEncoding::VERSION
  spec.authors = ["Durable Programming"]
  spec.email = ["commercial@durableprogramming.com"]

  spec.summary = "Tool for changing a MySQL database's encoding, collation, or both"
  spec.description = "Changes the character encoding and/or collation of a MySQL database and all of its tables. " \
                     "Supports online schema change via Percona's pt-online-schema-change to avoid locking " \
                     "production tables, with a configurable fallback to direct ALTER TABLE statements."
  spec.homepage = "https://github.com/durableprogramming/mysql_change_database_encoding"
  spec.license = "GPL-3.0-or-later"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/master"
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[test/ spec/ features/ .git .github packaging/ script/ Gemfile
                          Dockerfile .dockerignore .rubocop devenv Rakefile
                          mysql_change_database_encoding.rb])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "activerecord", ">= 6.0", "< 9.0"
  spec.add_dependency "mysql2", "~> 0.5"
  spec.add_dependency "ptools", "~> 1.4"
end
