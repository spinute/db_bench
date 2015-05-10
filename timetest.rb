#!/usr/bin/env ruby

require 'pg'
require 'benchmark'

default = 100
N = ARGV[0].to_i || default

conn = PG.connect

# Benchmark.#bmbm

t = Benchmark.realtime do |bench|
  0.upto(N) do |i|
    query = "insert into mini values (#{i})"
    conn.exec query
  end
end

puts t