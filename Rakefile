task default: %w[init]

task :timetest do
  0.upto 3 do |e|
    n_tuples = 10 ** e
    ruby "timetest.rb #{n_tuples}"
  end
end

desc "called from rand_experiment"
task :rand, 'n_rels' do |t, args|
  ruby "random_join.rb #{args['n_rels']}"
end

task :rand_experiment do
  1.upto 100 do |i|
    sh "rake rand[#{i}] -q"
  end
end

desc "usage: rake gen #n_rels #n_attrs"
task :gen, 'n_rels', 'n_attrs' do |t, args|
  ruby "gen_rels.rb #{args['n_rels']} #{args['n_attrs']}"
end

task :unitest, 'n_rels' do |t, args|
  ruby "unitest.rb #{args['n_rels']}"
end

desc "usage: rake drop #n_rels #n_attrs"
task :drop, 'n_rels', 'n_attrs' do |t, args|
  ruby "drop_tables.rb #{args['n_rels']} #{args['n_attrs']}"
end

task :init do
  sh "bundle install --binstubs"
end