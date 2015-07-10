require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    .first.map(&:to_sym)
  end

  def self.finalize!
    # define_method("attributes") do
    #   @attributes ||= {}
    # end

    columns.each do |col|
      define_method("#{col}") do
        attributes[col]
      end

      define_method("#{col}=") do |value|
        attributes[col] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    objects = []

    results.each do |res|
      objects << new(res)
    end

    objects
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL

    parse_all(results).first
  end

  def initialize(params = {})
    params.each do |col, val|
      col = col.to_sym
      raise "unknown attribute '#{col}'" unless self.class.columns.include?(col)
      send("#{col}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |name| send(name) }
  end

  def insert
    cols = self.class.columns.drop(1)
    col_names = cols.join(', ')
    question_marks = Array.new(cols.length) { '?' }.join(', ')
    values = attribute_values.drop(1)

    DBConnection.execute(<<-SQL, *values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    new_id = self.class.all.length
    attributes[:id] = new_id
  end

  def update
    cols = self.class.columns
    set_line = cols.map { |col| "#{col} = ?" }.join(", ")
    values = attribute_values << id

    DBConnection.execute(<<-SQL, *values)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
