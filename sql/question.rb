require_relative 'questions_database'
require_relative 'model'

class Question < ModelBase
  attr_accessor :title, :body, :user_id
  attr_reader :id

  # def self.all
  #   data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
  #   data.map { |datum| Question.new(datum) }
  # end

  def self.find_by_title(title)
    data = QuestionsDatabase.instance.execute(<<-SQL, title)
      SELECT
        *
      FROM
        questions
      WHERE
        title = ?
    SQL
    Question.new(data.first)
  end

  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
    # super("questions")
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id)
      INSERT INTO
        questions (title, body, user_id)
      VALUES
        (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @user_id, @id)
      UPDATE
        questions
      SET
        title = ?, body = ?, user_id = ?
      WHERE
        id = ?
    SQL
  end

  #author
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

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
  end
end

if __FILE__ == $PROGRAM_NAME
  # p q = Question.find_by_author_id(1)
  # q.each do |author|
  #   p author.author
  # end
  #
  # p Reply.find_by_user_id(2)
  # p Reply.find_by_question_id(2)
  #
  # p u1 = User.find_by_name('Walter', 'Wan')
  # p u1.authored_questions
  #
  # p q = Question.all
  # p replies = q[1].replies
  #
  # p replies[0].author
  # p replies[0].question
  # p replies[0].parent_reply
  # p replies[0].child_replies
  # p replies[1].child_replies
  # p replies[2].child_replies

  # u = User.all
  # p u[0].authored_replies
  # p QuestionFollow.followers_for_question_id(2)
  # p QuestionFollow.followed_questions_for_user_id(1)
  #
  # p u[0].followed_questions
  #
  # q = Question.all
  # p q[0].followers

  # p QuestionFollow.most_followed_questions(1)
  # p Question.most_followed(1)

  # p QuestionLike.likers_for_question_id(3)
  # p QuestionLike.num_likes_for_question_id(3)
  # p QuestionLike.liked_questions_for_user_id(2)
  u2 = User.all.last
  p u2.average_karma
end
