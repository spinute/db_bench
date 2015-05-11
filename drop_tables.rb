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

conn = PG.connect

0.upto n_rels-1 do |n|
  query = "drop table t_#{n_attrs}_#{n}"
  puts query
  conn.exec query
end