#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'pg'

conn = PG.connect

query = 'explain select * from t_2_3'
conn.exec query do |res|
  res.each do |row|
    p row
  end
end