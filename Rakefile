require_relative "configuration"

Dir[File.join(File.dirname(__FILE__), 'lib/tasks/*.rake')].each { |file| load file }

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)

  require 'cucumber'
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:cucumber) do |t|
    t.cucumber_opts = "features --format pretty"
  end

  task default: [
    "spec",
    "cucumber",
  ]
rescue LoadError
  # nope
end
