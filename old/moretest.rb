#!/usr/bin/env ruby

require 'pg'

conn = PG.connect

0.upto(1000000) do |i|
  query = "insert into pintest values (#{i}, 'pin #{i}', 'query #{i}')"
  conn.exec(query)
end

conn.exec( 'select * from pintest ') do |res|
  puts "     pid | username         | query "

  res.each do |row|
    puts " %7d | %16s | %s" %
      row.values_at('procpid', 'username', 'current_query')

  end
end

