# Copyright 2018, David Berube. All rights reserved.
# See LICENSE for license details.

require 'bundler'
Bundler.require

require 'optparse'
require 'active_record'
require 'pry'
require 'pp'

require_relative 'lib/database_encoding_changer.rb'
require_relative 'lib/database_encoding_changer_table.rb'
require_relative 'lib/mcde_options_parser.rb'

options = McdeOptionsParser.parse! # This method returns an options hash from  options passed via the command line; 
                                   # note that if invalid or insufficient options are passed, execution will terminate inside of this method.

puts "Connecting to #{options[:database]}"

ActiveRecord::Base.establish_connection(  adapter: 'mysql2',
                                          host: options[:host],
                                          port: options[:port],
                                          database: options[:database],
                                          username: options[:user],
                                          password: options[:password])


dec = DatabaseEncodingChanger.new(options)
dec.run! # This set the default encoding and/or collation for the database; 
         # it will then will loop through all of the tables in the database and, likewise,
         # set the default encoding and/or collation.

