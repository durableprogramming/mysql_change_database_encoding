# Security Policy

## Reporting Vulnerabilities

If you discover a security vulnerability in
mysql_change_database_encoding, please report it to us as follows:

### Contact

Email: security@durableprogramming.com

### Response Time

We will acknowledge receipt of your report within 72 hours and provide a more
detailed response within 7 days indicating our next steps.

### Disclosure

We ask that you do not publicly disclose the vulnerability until we have had a
chance to address it. We will work with you to determine an appropriate
disclosure timeline.

## Supported Versions

Security fixes are applied to the most recent release.

## Scope

This tool connects to a MySQL server with credentials supplied by the operator
and issues DDL against it. A few things are worth knowing when running it:

- Credentials passed as command-line arguments are visible to other users on
  the same host through `ps` and similar tools. Prefer the `MYSQL_PASSWORD` and
  related environment variables, which the tool reads as defaults.
- `--osc-options` is passed through to `pt-online-schema-change` as-is. Treat
  its contents as you would any other shell input.
- The tool issues `ALTER DATABASE` and `ALTER TABLE` statements against every
  table in the target database. Take a backup before running it against data
  you care about.
