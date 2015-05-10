task :default => :timetest

task :timetest do
  0.upto 6 do |e|
    n_tuples = 10 ** e
    ruby "timetest.rb #{n_tuples}"
  end
end
