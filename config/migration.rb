#!/usr/bin/env ruby
require 'yaml'
require 'rubygems'
require 'active_record'

# A migration script uses a database configuration and creates tables
# very conveniently in a database-agnostic way. Below, add any customizations
# to the sample schema or leave it as-is. When done, type "rake migrate" to
# have this schema generated.

ActiveRecord::Base.establish_connection YAML.load_file('config/database.yml')

