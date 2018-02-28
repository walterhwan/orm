require 'active_support/inflector'
require_relative 'questions_database'

class ModelBase

  def self.table
    self.to_s.tableize
  end

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM #{table}")
    data.map { |datum| self.new(datum) }
  end

  def self.find_by_id(id)
    data = QuestionsDatabase.instance.execute(<<-SQL, id: id)
      SELECT
        *
      FROM
        #{table}
      WHERE
        id = :id
    SQL
    self.new(data.first)
  end

  def initialize(table)
    @table = table
  end

  def save
    @id ? update : create
  end

end
