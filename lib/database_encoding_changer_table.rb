# Copyright 2018, David Berube. All rights reserved.
# See LICENSE for license details.
#
# ActiveRecord model backing the table currently being processed by
# DatabaseEncodingChanger. table_name is reassigned at runtime (via class_eval)
# to point this model at whichever base table is being migrated. This model is
# used purely for schema reflection, never for reading, creating, updating, or
# deleting row data.
#
# eligible_for_online_schema_change? checks whether the table has a primary
# key, consulting both self.primary_key and the connection's schema cache
# (since some tables report no primary key through one mechanism but not the
# other). pt-online-schema-change requires a primary key to operate, so tables
# without one must fall back to a direct ALTER TABLE or be skipped.

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

# Copyright (c) 2026 Durable Programming, LLC. All rights reserved.
# See LICENSE for details.
