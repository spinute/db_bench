#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

require 'pg'
require 'benchmark'

default_num = 100
N = (ARGV[0] || default_num).to_i

conn = PG.connect

# Benchmark.#bmbm

t = Benchmark.realtime do |bench|
  0.upto(N) do |i|
    query = "insert into mini values (#{i})"
    conn.exec query
  end
end

puts t
