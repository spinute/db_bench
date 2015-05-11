#!/usr/bin/env ruby

# simplified version
# n_attrs and n_tuples_base are constant

require 'rubygems'
require 'bundler/setup'

require 'pg'
require 'benchmark'

n_rels = 2
n_rels = (ARGV[0] || n_rels).to_i
n_tuples_base = 1000

conn = PG.connect

0.upto n_rels-1 do |n|
  t = Benchmark.realtime do |bench|
    query = "create table t_#{n} (key integer primary key, value integer)"
    conn.exec query
  end

  puts "time: create t_#{n} -> #{t}"
end

0.upto n_rels-1 do |n|
  n_tuples = (n+1) * n_tuples_base

  t = Benchmark.realtime do |bench|
    0.upto(n_tuples) do |ti|
      query = "insert into t_#{n} values (#{ti}, #{ti})"
      conn.exec query
    end
  end

  puts "time: insert t_#{n} (n_tuples: #{n_tuples}) -> #{t}"
end

from_list = ""
0.upto n_rels-1 do |n|
  if n != n_rels-1
    from_list += " t_#{n},"
  else
  	from_list += " t_#{n}"
  end
end
select_query = "select * from " + from_list
t = Benchmark.realtime do |bench|
  conn.exec "explain " + select_query
end
puts "time: explain " + select_query + " -> #{t}"

# clean up
0.upto n_rels-1 do |n|
  query = "drop table t_#{n}"
  puts query
  conn.exec query
end