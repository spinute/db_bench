#!/usr/bin/env ruby

require 'pg'

# example from http://deveiate.org/code/pg/README_rdoc.html

conn = PG.connect( dbname: 'spinute' )

conn.exec( "SELECT * FROM pintest" ) do |result|
  puts "     PID | User             | Query"

  result.each do |row|
    puts " %7d | %-16s | %s " %
      row.values_at('procpid', 'username', 'current_query')

  end
end
