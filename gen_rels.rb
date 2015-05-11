#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'pg'

if !args[0] || !args[1]
  puts "usamge: ruby gen_rels.rb n_rels n_attrs"
  exit
end

n_rels = args[0].to_i
n_attrs = args[1].to_i

n_tuples_base = 100

conn = PG.connect

# t_i_j is jth table having i attrs
0.upto n_rels-1 do |n|
  values = "(key integer primary key, "
  n_attrs.times do |i|
    #implementation
  end

  query = "create table t_#{n_attrs}_#{n} #{values}"
  conn.exec query
  puts "create t_#{n_attrs}_#{n}"
end

0.upto n_rels-1 do |n|
  n_tuples = (n+1) * n_tuples_base  

  0.upto(n_tuples) do |ti|
    query = "insert into t_2_#{n} values (#{ti}, #{ti})"
    conn.exec query
  end

  puts "insert t_2_#{n}"
end