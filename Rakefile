task default: %w[init]

task :timetest do
  0.upto 3 do |e|
    n_tuples = 10 ** e
    ruby "timetest.rb #{n_tuples}"
  end
end

task :unitest, 'n_rels' do |t, args|
  ruby "unitest.rb #{args['n_rels']}"
end

task :drop, 'n_rels' do |t, args|
  ruby "drop_tables.rb #{args['n_rels']}"
end

task :init do
  sh "bundle install --binstubs"
end