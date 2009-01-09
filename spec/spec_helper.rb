ENV["RAILS_ENV"] = "test"

dir = File.expand_path(File.dirname(__FILE__))
require "#{dir}/../config/environment"
require 'spec'
require 'spec/rails'
require 'spec/integration'
