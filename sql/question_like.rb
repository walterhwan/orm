require_relative 'questions_database'
require_relative 'model'

class QuestionLike < ModelBase
  attr_accessor :question_id, :user_id
  attr_reader :id

  # def self.all
  #   data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
  #   data.map { |datum| QuestionLike.new(datum) }
  # end

  def self.likers_for_question_id(question_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_likes
      JOIN
        users ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL
    data.map { |datum| User.new(datum) }
  end

  def self.num_likes_for_question_id(question_id)
    counts = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(*) AS like_count
      FROM
        question_likes
      JOIN
        users ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL
    counts.first['like_count']
  end

  def self.liked_questions_for_user_id(user_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        question_likes
      JOIN
        questions ON questions.id = question_likes.question_id
      WHERE
        question_likes.user_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.most_liked_questions(n)
    data = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        question_likes
      JOIN
        questions ON questions.id = question_likes.question_id
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
        question_likes (question_id, user_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @user_id, @id)
      UPDATE
        question_likes
      SET
        question_id = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end

end
