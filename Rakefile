require "bundler"
Bundler.setup

require "rake"
require "rspec/core/rake_task"

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

RSpec::Core::RakeTask.new("spec") do |spec|
    spec.pattern = "spec/**/*_spec.rb"
end

RSpec::Core::RakeTask.new('spec:progress') do |spec|
    spec.rspec_opts = %w(--format progress)
      spec.pattern = "spec/**/*_spec.rb"
end

task :default => :spec