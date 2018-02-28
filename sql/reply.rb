require_relative 'questions_database'
require_relative 'model'

class Reply < ModelBase
  attr_accessor :question_id, :parent_reply_id, :user_id
  attr_reader :id

  # def self.all
  #   data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
  #   data.map { |datum| Reply.new(datum) }
  # end

  def self.find_by_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @user_id = options['user_id']
  end

  def save
    @id ? update : create
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @parent_reply_id, @user_id)
      INSERT INTO
        replies (question_id, parent_reply_id, user_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @parent_reply_id, @user_id, @id)
      UPDATE
        replies
      SET
        question_id = ?, parent_reply_id = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end

  def author
    data = QuestionsDatabase.instance.execute(<<-SQL, @user_id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = ?
    SQL
    User.new(data.first)
  end

  def question
    data = QuestionsDatabase.instance.execute(<<-SQL, @question_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.id = ?
    SQL
    Question.new(data.first)
  end

  def parent_reply
    # raise 'This is the top level reply' unless @parent_reply_id
    return nil unless @parent_reply_id
    data = QuestionsDatabase.instance.execute(<<-SQL, @parent_reply_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.id = ?
    SQL
    Reply.new(data.first)
  end

  def child_replies
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.parent_reply_id = ?
    SQL
    data.map { |datum| Reply.new(datum) }
  end
end
