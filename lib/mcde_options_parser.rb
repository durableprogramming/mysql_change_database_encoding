
module McdeOptionsParser
  def self.parse!
    
    options = {}

    # set defaults:

    options[:host]                = ENV['MYSQL_HOST']     || '127.0.0.1'
    options[:database]            = ENV['MYSQL_DATABASE'] || ''
    options[:port]                = ENV['MYSQL_PORT'] || ''
    options[:user]                = ENV['MYSQL_USER'    ] || 'root'
    options[:password]            = ENV['MYSQL_PASSWORD'] || ''
    options[:direct_alter_table]  = false
    options[:osc]                 = true
    options[:osc_options]         = ''
    options[:skip_table_on_error] = false
    options[:overwrite]           = false

    options[:pt_online_schema_change_path] = File.which("pt-online-schema-change") 

    OptionParser.new do |opts|
        opts.banner = "Usage: #{$0} [options]"

        opts.on("-H [HOST]",      "--host [HOST]", "Connect to MySQL host HOST.") do |_|
          options[:host] = _
        end

        opts.on("-U [PORT]",       "--port [PORT]", "Connect to MySQL port PORT.") do |_|
          options[:port] = _
        end

        opts.on("-U [DATABASE]",   "--database [DATABASE]", "Connect to MySQL database DATABASE.") do |_|
          options[:database] = _
        end
        
        opts.on("-U [USER]",       "--user [USER]", "Connect as MySQL user USER.") do |_|
          options[:user] = _
        end

        opts.on("-U [PASSWORD]",   "--password [PASSWORD]", "Connect using MySQL password PASSWORD.") do |_|
          options[:password] = _
        end

        opts.on("-U [PORT]",       "--port [PORT]", "Connect to MySQL port PORT.") do |_|
          options[:port] = _
        end

        opts.on("-U [ENCODING]",       "--encoding [ENCODING]", "Convert database to ENCODING. One of ENCODING or COLLATION must be specified.") do |_|
          options[:encoding] = _
        end
        opts.on("-U [COLLATION]",       "--collation [COLLATION]", "Convert database to COLLATION. One of ENCODING or COLLATION must be specified.") do |_|
          options[:collation] = _
        end

        opts.on("--[no-]direct-alter-table", "If necessary, issue direct ALTER TABLE statements without OSC. This is use if pt_online_schema_change is not installed, if --no-osc is passed, or if a table does not have a primary key." ) do |_|
          options[:direct_alter_table] = _
        end

        opts.on("--[no-]osc", "Enables online schema change using pt-online-schema-change. Defaults to true if pt-online-schema-change is installed.") do |_|
          options[:osc] = _
        end
        opts.on("--osc-options [OPTIONS]", "Sets optional parameters for pt-online-schema-change, which are passed on as-is.") do |_|
          options[:osc_options] = _
        end

        opts.on("-o", "--overwrite" ,"Optional parameter to overwrite the collation even if it is already migrated.") do |_|
          options[:overwrite] = _
        end

        opts.on("--[no-]skip-table-on-error", "If a SQL error, continue to next table; if not set, quit on SQL errors. Defaults to false. ") do |_|
          options[:skip_table_on_error] = _
        end

        opts.on("-v", "--verbose", "Run with more output.") do |v|
          options[:verbose] = v
        end

    end.parse!
     
    if !options[:pt_online_schema_change_path] && options[:osc]
      puts "WARNING: pt_online_schema_change not detected; online schema change functionality disabled."
      options[:osc] = false
    end

    if !options[:encoding] && !options[:collation]
      puts 'ERROR: One of ENCODING or COLLATION must be specified. Hint: try "--encoding utf8mb4".'
      exit
    end

    if !(options[:direct_alter_table] || options[:osc])
      puts "ERROR: Either --direct_alter_table or --osc must be enabled."
      exit
    end
    options
  end
end

