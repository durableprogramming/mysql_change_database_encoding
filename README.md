# mysql_change_database_encoding

[![Test](https://github.com/durableprogramming/mysql_change_database_encoding/actions/workflows/test.yml/badge.svg)](https://github.com/durableprogramming/mysql_change_database_encoding/actions/workflows/test.yml)
[![Build Packages](https://github.com/durableprogramming/mysql_change_database_encoding/actions/workflows/build.yml/badge.svg)](https://github.com/durableprogramming/mysql_change_database_encoding/actions/workflows/build.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Ruby](https://img.shields.io/badge/ruby-3.0+-red.svg)](https://www.ruby-lang.org/en/)
[![RuboCop](https://img.shields.io/badge/code_style-rubocop-orange.svg)](https://github.com/rubocop/rubocop)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)
[![Website](https://img.shields.io/website-up-down-green-red/http/durableprogramming.com.svg)](https://durableprogramming.com)

Tool for changing a database's encoding, collation, or both. Supports online schema change via pt-online-schema-change with configurable fallback.

## Installation

### Debian / Ubuntu

Download the `.deb` from the [releases page](https://github.com/durableprogramming/mysql_change_database_encoding/releases) and install it:

```bash
sudo dpkg -i mysql-change-database-encoding_VERSION_all.deb
```

### RedHat / CentOS / Fedora

Download the `.rpm` from the releases page and install it:

```bash
sudo rpm -i mysql-change-database-encoding-VERSION-1.noarch.rpm
```

### Docker

```bash
docker run --rm durableprogramming/mysql-change-database-encoding:latest --help
```

The image includes `pt-online-schema-change`.

### From source

A working Ruby 3.0+ install is required. Clone the repository and install dependencies:

```bash
git clone https://github.com/durableprogramming/mysql_change_database_encoding.git
cd mysql_change_database_encoding
bundle install
```

Then run the tool through Bundler:

```bash
bundle exec exe/mysql-change-database-encoding --help
```

## Usage

```
Usage: mysql-change-database-encoding [options]
    -H, --host [HOST]                Connect to MySQL host HOST.
    -P, --port [PORT]                Connect to MySQL port PORT.
    -D, --database [DATABASE]        Connect to MySQL database DATABASE.
    -u, --user [USER]                Connect as MySQL user USER.
    -p, --password [PASSWORD]        Connect using MySQL password PASSWORD.
    -e, --encoding [ENCODING]        Convert database to ENCODING. One of ENCODING or COLLATION must be specified.
    -U, --collation [COLLATION]      Convert database to COLLATION. One of ENCODING or COLLATION must be specified.
        --[no-]direct-alter-table    If necessary, issue direct ALTER TABLE statements without OSC. This is used if
                                     pt-online-schema-change is not installed, if --no-osc is passed, or if a table
                                     does not have a primary key.
        --[no-]osc                   Enables online schema change using pt-online-schema-change. Defaults to true if
                                     pt-online-schema-change is installed.
        --osc-options [OPTIONS]      Sets optional parameters for pt-online-schema-change, which are passed on as-is.
    -o, --overwrite                  Optional parameter to overwrite the collation even if it is already migrated.
        --[no-]skip-table-on-error   If a SQL error occurs, continue to the next table; if not set, quit on SQL
                                     errors. Defaults to false.
    -v, --verbose                    Run with more output.
```

The following environment variables are also accepted:

```

    MYSQL_HOST
    MYSQL_DATABASE
    MYSQL_PORT
    MYSQL_USER
    MYSQL_PASSWORD
```

An argument passed via a command line switch will override an environment variable.

Note that since command line arguments may be seen by other users on the system - via `ps aux` or similar facilities - it may be safer to use the environment variables.

## Examples

This command will connect to `big_database_full_of_legacy_tables` and change all the tables to `utfmb4` encoding and `utf8mb4_unicode_ci` collation; it will use the pt-online-schema-change tool, if installed, to safely migrate data on a production system:

```bash
MYSQL_PASSWORD=this_is_a_secure_password \
MYSQL_DATABASE=big_database_full_of_legacy_tables \
mysql-change-database-encoding --collation utf8mb4_unicode_ci --encoding utf8mb4 --osc
```

However, if you don't have `pt_online_schema_change` installed, or do not want to use it, the tool can alter tables directly as follows:

```bash
MYSQL_PASSWORD=this_is_a_secure_password \
MYSQL_DATABASE=big_database_full_of_legacy_tables \
mysql-change-database-encoding --collation utf8mb4_unicode_ci --encoding utf8mb4 --direct-alter-table --no-osc
```

## Development

The repository ships a [devenv](https://devenv.sh/) configuration that provides Ruby, a compiler for the native extensions, and `pt-online-schema-change`:

```bash
devenv shell
bundle install
bundle exec rake test
```

The test suite reflects on schema metadata rather than exercising MySQL itself, so it runs against sqlite in memory and needs no database server. The `integration` job in CI covers the MySQL path end to end.

To lint:

```bash
bundle exec rubocop
```

## Releasing

Update `VERSION` in `lib/mysql_change_database_encoding/version.rb`, add a `CHANGELOG.md` entry, commit, and then:

```bash
./script/release --version 1.2.3
```

Both `script/build` and `script/release` refuse to run if the requested version does not match the version file. The gem is built as a release artifact; it is not pushed to RubyGems.

## Commercial Support

Commercial support for this tool is available from Durable Programming, LLC. You can find out more at [durableprogramming.com](https://durableprogramming.com/) or via email at [commercial@durableprogramming.com](mailto:commercial@durableprogramming.com).

## Contributing

By contributing you agree to the terms in [CLA.md](CLA.md). Please also read the [Code of Conduct](CODE-OF-CONDUCT.md).

To report a security issue, see [SECURITY.md](SECURITY.md).

## Copyright

Copyright 2026, Durable Programming LLC. All rights reserved.

Distributed under the GNU GPL version 3.0 license; you can read the full text of the license in the [LICENSE](LICENSE) file.
