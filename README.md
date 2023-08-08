# mysql_change_database_encoding

Tool for changing a database's encoding, collation, or both. Supports online schema change via pt-online-schema-change with configurable fallback.

# Installation

A working Ruby install is required; use of rbenv or RVM is recommended, but not required. To use, clone this git repo and then install dependencies:

```
git clone https://github.com/durableprogramming/mysql_change_database_encoding.git
cd mysql_change_database_encoding
bundle install
```

# Usage

```
Usage: mysql_change_database_encoding.rb [options]
    -H, --host [HOST]                Connect to MySQL host HOST.
        --database [DATABASE]        Connect to MySQL database DATABASE.
        --user [USER]                Connect as MySQL user USER.
        --password [PASSWORD]        Connect using MySQL password PASSWORD.
        --port [PORT]                Connect to MySQL port PORT.
        --encoding [ENCODING]        Convert database to ENCODING. One of ENCODING or COLLATION must be specified.
    -U, --collation [COLLATION]      Convert database to COLLATION. One of ENCODING or COLLATION must be specified.
        --[no-]direct-alter-table    If necessary, issue direct ALTER TABLE statements without OSC. This is use if pt_online_schema_change is not installed, if --no-osc is passed, or if a table does not have a primary key.
        --[no-]osc                   Enables online schema change using pt-online-schema-change. Defaults to true if pt-online-schema-change is installed.
        --osc-options [OPTIONS]      Sets optional parameters for pt-online-schema-change, which are passed on as-is.
    -o, --overwrite                  Optional parameter to overwrite the collation even if it is already migrated.
        --[no-]skip-table-on-error   If a SQL error, continue to next table; if not set, quit on SQL errors. Defaults to false. 
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

# Examples

This command will connect to `big_database_full_of_legacy_tables` and change all the tables to `utfmb4` encoding and `utf8mb4_unicode_ci` collation; it will use the pt-online-schema-change tool, if installed, to safely migrate data on a production system:

```
MYSQL_PASSWORD=this_is_a_secure_password MYSQL_DATABASE=big_database_full_of_legacy_tables ruby mysql_change_database_encoding.rb --collation utf8mb4_unicode_ci --encoding utf8mb4 --osc
```


However, if you don't have `pt_online_schema_change` installed, or do not want to use it, the tool can alter tables directly as follows:

```
MYSQL_PASSWORD=this_is_a_secure_password MYSQL_DATABASE=big_database_full_of_legacy_tables ruby mysql_change_database_encoding.rb --collation utf8mb4_unicode_ci --encoding utf8mb4 --direct --no-osc
```

