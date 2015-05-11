#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'pg'

if ! ARGV[0] || ! ARGV[1]
  puts "usamge: ruby gen_rels.rb n_rels n_attrs"
  exit
end

n_rels = ARGV[0].to_i
n_attrs = ARGV[1].to_i

n_tuples_base = 100

conn = PG.connect

# t_i_j is jth table having i attrs
0.upto n_rels-1 do |n|
  values_str = "(key integer primary key, "
  (n_attrs-1).times do |i|
    if i != n_attrs-2
      values_str += "v_#{i} integer, "
    else
      values_str += "v_#{i} integer)"
    end
  end

  query = "create table t_#{n_attrs}_#{n} #{values_str}"
  conn.exec query
  puts "create t_#{n_attrs}_#{n}"
end

0.upto n_rels-1 do |n|
  n_tuples = (n+1) * n_tuples_base
  rand_max = n_tuples * 0.1

  0.upto(n_tuples) do |ti|

    values_str = "(#{ti}, "
    (n_attrs-1).times do |i|
      if i != n_attrs-2
        values_str += "#{rand rand_max} ,"
      else
        values_str += "#{rand rand_max})"
      end
    end

    query = "insert into t_#{n_attrs}_#{n} values #{values_str}"
    conn.exec query
  end

  puts "insert t_#{n_attrs}_#{n}"
end