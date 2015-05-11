#!/usr/bin/env ruby

require 'pg'

# example from http://deveiate.org/code/pg/README_rdoc.html

conn = PG.connect( dbname: 'spinute' )

conn.exec "insert into ctest values (#{rand 3}, 'pin')"