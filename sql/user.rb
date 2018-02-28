require_relative 'questions_database'
require_relative 'model'

class User < ModelBase
  attr_accessor :fname, :lname
  attr_reader :id

  # def self.all
  #   data = QuestionsDatabase.instance.execute("SELECT * FROM users")
  #   data.map { |datum| User.new(datum) }
  # end

  def self.find_by_name(fname, lname)
    data = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    User.new(data.first)
  end

  # def self.find_by_id(id)
  #   data = QuestionsDatabase.instance.execute(<<-SQL, id)
  #     SELECT
  #       *
  #     FROM
  #       users
  #     WHERE
  #       id = ?
  #   SQL
  #   User.new(data.first)
  # end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def save
    @id ? update : create
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    data = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        (COUNT(question_likes.user_id) /
        CAST(COUNT(DISTINCT title) AS FLOAT)) AS avg_karma
      FROM
        questions
      LEFT JOIN
        question_likes ON question_likes.question_id = questions.id
      WHERE
        questions.user_id = ?
        AND question_likes.user_id IS NOT NULL
    SQL

    data.first['avg_karma']
  end
end
#  / COUNT(DISTINCT title COUNT(question_likes.user_id)
