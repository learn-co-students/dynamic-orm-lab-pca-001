require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'
require "pry"

class Student < InteractiveRecord
  column_names.each { |col| send(:attr_accessor, col) }
end
