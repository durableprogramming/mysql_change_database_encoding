# Copyright 2018, David Berube. All rights reserved.
# See LICENSE for license details.

class DatabaseEncodingChangerTable < ActiveRecord::Base

  # This model is used to represent the current table being processed.
  # Since this is a data migration tool, this is only used for 
  # reflection purposes, and not creating, updating, or deleting data; 
  # use of this model allows use to access ActiveRecord's API for 
  # retrieving MySQL table metadata.

  def self.eligible_for_online_schema_change?() 

    # If a table lacks a primary key, pt-online-schema-change will not be able to 
    # modify the table.

    if self.primary_key.nil? and (connection.schema_cache.primary_keys(table_name).nil? or connection.schema_cache.primary_keys(table_name).empty?)
      false
    else
      true
    end
  end


end

