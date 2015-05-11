task default: %w[timetest]

task :timetest do
  0.upto 3 do |e|
    n_tuples = 10 ** e
    ruby "timetest.rb #{n_tuples}"
  end
end

task :unitest do
  ruby "unitest.rb"
end

task :init do
  sh "bundle install --binstubs"
end