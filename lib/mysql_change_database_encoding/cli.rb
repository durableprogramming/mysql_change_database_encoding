# Command-line entry point. CLI.run parses the given arguments, opens a MySQL
# connection from the resulting options, and hands the connection to
# DatabaseEncodingChanger to do the work.
#
# Errors that are the user's to fix (missing encoding/collation, no available
# alteration method, a bad connection) are reported as a single message on
# stderr and turned into a non-zero exit status, rather than a backtrace.

require "active_record"

module MysqlChangeDatabaseEncoding
  module CLI
    module_function

    # Run the tool.
    #
    # @param argv [Array<String>] command-line arguments, defaulting to ARGV
    # @return [Integer] a process exit status: 0 on success, 1 on a
    #   user-correctable error
    def run(argv = ARGV)
      options = OptionsParser.parse!(argv)

      puts "Connecting to #{options[:database]}"
      establish_connection(options)

      DatabaseEncodingChanger.new(options).run!

      0
    rescue Error, ActiveRecord::ActiveRecordError => e
      warn e.message
      1
    end

    def establish_connection(options)
      ActiveRecord::Base.establish_connection(
        adapter: "mysql2",
        host: options[:host],
        port: options[:port],
        database: options[:database],
        username: options[:user],
        password: options[:password]
      )
    end
  end
end

# Copyright (c) 2026 Durable Programming, LLC. All rights reserved.
# See LICENSE for details.
