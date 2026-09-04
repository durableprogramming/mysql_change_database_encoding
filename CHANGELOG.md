# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Changed

- Restructured the project as a Ruby gem. The library now lives under
  `lib/mysql_change_database_encoding/` inside a `MysqlChangeDatabaseEncoding`
  namespace, and the tool ships as an `mysql-change-database-encoding`
  executable rather than a script run from the repository root.
- `McdeOptionsParser` is now `MysqlChangeDatabaseEncoding::OptionsParser`, and
  `parse!` takes an argv argument instead of reading the global `ARGV`.
- Invalid command-line options are reported as a single message on stderr with
  an exit status of 1, rather than raising a backtrace.
- The deb, rpm, and Docker packages install the executable. The Docker image is
  built in two stages and includes `pt-online-schema-change`; its base moves
  from Alpine to Debian slim, which packages percona-toolkit.
- The minimum supported Ruby version is 3.0.
- Short option flags are now distinct and follow the mysql client's
  conventions: `-P` for port, `-D` for database, `-u` for user, `-p` for
  password, and `-e` for encoding. Previously all five, along with
  `--collation`, were declared as `-U`, so only one of them was reachable by
  its short form. Long flags are unchanged.
- The code is formatted to RuboCop's defaults, and `bundle exec rubocop` runs
  in CI.

### Fixed

- `eligible_for_online_schema_change?` read a primary key that ActiveRecord
  memoizes per class and does not clear when the model is repointed at another
  table. Because a single model class is reused for every table in the
  database, a table with no primary key could inherit the previous table's and
  be wrongly reported as eligible for `pt-online-schema-change`. The check now
  reads the primary keys from the connection.
- The message printed when a table fails to alter interpolated `${!}`, which is
  shell syntax rather than Ruby, so it reported the literal text instead of the
  error. It now prints the exception, and the statement it reports is the one
  that actually failed rather than the earlier ALTER DATABASE statement.

### Deprecated

- Running `mysql_change_database_encoding.rb` from the repository root still
  works but prints a warning. Use the `mysql-change-database-encoding`
  executable instead.

## [0.1.0]

- Initial packaged release.
