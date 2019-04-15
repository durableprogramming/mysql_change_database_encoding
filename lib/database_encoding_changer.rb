# Copyright 2018, David Berube. All rights reserved.
# See LICENSE for license details.

class DatabaseEncodingChanger

  def initialize(opts)
    @conn = opts.delete(:connection)
    @options = opts
  end

  def run!
    puts "Processing database settings."
    sql = "ALTER DATABASE "
    sql << conn.quote_column_name(@options[:database])
    if @options[:encoding] 
      sql << " CHARACTER SET #{@options[:encoding]}"
    end

    if @options[:collation] 
      sql << " COLLATE #{@options[:collation]}"
    end
    sql << ';'

    ActiveRecord::Migration.say_with_time 'Setting database global settings.' do 

      run_sql_directly sql

    end

    table_list.each do |table|

      DatabaseEncodingChangerTable.class_eval do
        self.table_name = table
      end

      verbose_puts "Processing #{table}"

      sql_suffix = '' # This is just the part following ALTER TABLE tablename, which can be passed to pt-online-schema-change.

      if @options[:encoding] 
        sql_suffix << " CONVERT TO CHARACTER SET #{@options[:encoding]}"
      end

      if @options[:collation] 
        sql_suffix << " COLLATE #{@options[:collation]}"
      end


      use_online_schema_change =  @options[:osc] 

      if use_online_schema_change && !DatabaseEncodingChangerTable.eligible_for_online_schema_change? 

        verbose_puts "#{table} is not eligible for online schema change."
        use_online_schema_change = false

      end

      if use_online_schema_change

        verbose_puts "Using online schema change for #{table}" 

        run_sql_through_pt_osc table, sql_suffix

      elsif @options[:direct_alter_table]
        verbose_puts "Using direct ALTER TABLE for #{table}." 

        full_sql = "ALTER TABLE " # This is the full SQL statement, which is needed to directly run the SQL.
        full_sql << conn.quote_column_name(table)
        full_sql << "#{sql_suffix};"

        ActiveRecord::Migration.say_with_time 'Migrating without OSC' do 

          begin 
            run_sql_directly full_sql
          rescue ActiveRecord::StatementInvalid

            puts "MySQL Error: ${!}"
            puts "Raise during the execution of this SQL statement:"
            puts sql

            if @options[:skip_table_on_error]
              next
            else
              raise
            end

          end

        end
      else
        puts "Skipping #{table}."

      end
    end
  end

  private

  def run_sql_directly(sql)
    puts "Running SQL:"
    puts sql
    conn.execute sql
  end
  def run_sql_through_pt_osc(table, sql)
    puts "This SQL will be run using pt-online-schema-change:"
    puts sql
    puts "The following command will be run:"
    cmd = "pt-online-schema-change --execute "
    cmd << @options[:osc_options]
    cmd << " --alter "
    cmd << Shellwords.escape(sql) 
    cmd << ' '
    cmd << Shellwords.escape(pt_dsn(table))
    system cmd

    
  end
  def pt_dsn(table)

    options = {
      'D'=> @options[:database],
      'h'=> @options[:host],
      'p'=> @options[:password],
      'P'=> @options[:port],
      'u'=> @options[:user],
      't'=> table
    }

    dsn_parts = []

    options.each do |k,v|
      part = k.dup
      part << '='
      part << v.gsub('\\', '\\\\').gsub(',','\\,')
      dsn_parts << part
    end

    dsn_parts.join(',')

  end

  def verbose_puts(msg)
    if @options[:verbose]
      puts msg
    end
  end

  def table_list
<<<<<<< HEAD
    if @options[:overwrite]
      conn.execute("SELECT table_name FROM information_schema.tables WHERE
                    table_type = 'BASE TABLE'
                    AND table_schema=#{conn.quote(@options[:database])}
                    ;").to_a.flatten
    else
      conn.execute("SELECT table_name FROM information_schema.tables WHERE
                    table_type = 'BASE TABLE'
                    AND table_schema=#{conn.quote(@options[:database])}
                    AND table_collation <> #{conn.quote(@options[:collation])}
                    ;").to_a.flatten
    end
=======
    ActiveRecord::Base.connection.tables
>>>>>>> parent of c3b6208... change DatabaseEncodingChange#tables method to avoid trying to migrate views
  end

  def conn
    ActiveRecord::Base.connection
  end

end
