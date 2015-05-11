#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'pg'

n_rels = 2
n_rels = (ARGV[0] || n_rels).to_i

conn = PG.connect

0.upto n_rels-1 do |n|
  query = "drop table t_#{n}"
  puts query
  conn.exec query
end