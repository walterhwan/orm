require_relative 'questions_database'
require_relative 'model'

class QuestionFollow < ModelBase
  attr_accessor :question_id, :user_id
  attr_reader :id

  # def self.all
  #   data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
  #   data.map { |datum| QuestionFollow.new(datum) }
  # end

  def self.followers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_follows
      JOIN
        users ON users.id = question_follows.user_id
      WHERE
        question_follows.question_id = ?
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        question_follows
      JOIN
        questions ON questions.id = question_follows.question_id
      WHERE
        question_follows.user_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        question_follows
      JOIN
        questions ON questions.id = question_follows.question_id
      GROUP BY
        question_id
      ORDER BY
        COUNT(*) DESC
      LIMIT
        ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def save
    @id ? update : create
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id)
      INSERT INTO
        question_follows (question_id, user_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id, @id)
      UPDATE
        question_follows
      SET
        question_id = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end

end
