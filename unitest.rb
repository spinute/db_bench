#!/usr/bin/env ruby

# simplified version
# n_attrs and n_tuples_base are constant

require 'rubygems'
require 'bundler/setup'

require 'pg'
require 'benchmark'

n_rels = 2
n_rels = (ARGV[0] || n_rels).to_i
n_tuples_base = 10000

conn = PG.connect

0.upto n_rels-1 do |n|
  t = Benchmark.realtime do |bench|
    query = "create table t_#{n} (key integer primary key, value integer)"
    puts query
    conn.exec query
  end

  puts "time: create t_#{n}", t
end

0.upto n_rels-1 do |n|
  n_tuples = (n+1) * n_tuples_base

  puts "insert to t_#{n}"
  t = Benchmark.realtime do |bench|
    0.upto(n_tuples) do |ti|
      query = "insert into t_#{n} values (#{ti}, #{ti})"
      # puts query
      conn.exec query
    end
  end

  puts "time: insert t_#{n}", t
end

# clean up
0.upto n_rels-1 do |n|
  query = "drop table t_#{n}"
  puts query
  conn.exec query
end