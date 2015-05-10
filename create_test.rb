require 'pg'

conn = PG.connect

query = "create table mini (id integer)"
conn.exec query
