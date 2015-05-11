#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'pg'

n_rels = 100
n_tuples_base = 100

conn = PG.connect

# t_i_j is jth table having i attrs
0.upto n_rels-1 do |n|
  query = "create table t_2_#{n} (key integer primary key, value integer)"
  conn.exec query
  puts "create t_2_#{n}"
end

0.upto n_rels-1 do |n|
  n_tuples = (n+1) * n_tuples_base  

  0.upto(n_tuples) do |ti|
    query = "insert into t_2_#{n} values (#{ti}, #{ti})"
    conn.exec query
  end

  puts "insert t_2_#{n}"
end