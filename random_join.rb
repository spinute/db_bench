#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'pg'
require 'benchmark'

max_rel_i = 100
n_rels = 2
n_rels = (ARGV[0] || n_rels).to_i

if n_rels < 1 || n_rels > 99
  puts "invalid n_rels"
  exit
end

i_list = Array.new(max_rel_i){|i| i}.shuffle.take n_rels

from_list = ""
i_list.each_with_index do |n, i|
  if i != n_rels - 1
    from_list += " t_2_#{n},"
  else
  	from_list += " t_2_#{n}"
  end
end

conn = PG.connect

select_query = "select * from " + from_list
t = Benchmark.realtime do |bench|
  conn.exec "explain " + select_query
end

# puts "time: explain " + select_query + " -> #{t}"
puts t