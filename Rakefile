require 'rake'
require 'spec/rake/spectask'

desc 'Run all tests on the timed_scopes plugin.'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.libs << 'lib'
  t.verbose = true
end

desc "Run all the tests"
task :default => :spec