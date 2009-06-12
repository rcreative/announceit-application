# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require(File.join(File.dirname(__FILE__), 'config', 'boot'))

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'tasks/rails'
Dir["#{RAILS_ROOT}/lib/plugins/*/**/tasks/**/*.rake"].sort.each { |ext| load ext }
Dir["#{RAILS_ROOT}/vendor/gems/*/**/tasks/**/*.rake"].sort.each { |ext| load ext }

begin
  require 'dataset'
  load 'dataset.rake'
rescue LoadError
end