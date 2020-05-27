require_relative "../config/environment.rb"
require 'active_support/inflector'
require "pry"

class InteractiveRecord

  class << self
    def table_name
      to_s.downcase.pluralize
    end

    def column_names
      DB[:conn].results_as_hash = true

      sql = "pragma table_info('#{table_name}')"
      DB[:conn].execute(sql).map{ |col| col["name"] }
    end
  end

  def initialize(args={})
    args.each do |k,v|
      send("#{k}=", v) if respond_to? "#{k}=".to_sym
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.reject { |col| col == "id"}.join(", ")
  end

  def values_for_insert
    instance_variables.map do |var|
      var = instance_variable_get(var)
      var.nil? ? var : "\'#{var}\'"
    end.compact.join(", ")
  end

  def save
    sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM #{table_name}
    WHERE name = ?
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(attr)
    sql = <<-SQL
    SELECT * FROM #{table_name}
    WHERE #{attr.first.first} = \"#{attr.first.last}\"
    SQL

    DB[:conn].execute(sql)

  end
end
