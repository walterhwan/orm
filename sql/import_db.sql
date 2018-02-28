DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL

  -- FOREIGN KEY (playwright_id) REFERENCES playwrights(id)
);

DROP TABLE if exists questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Join Table
DROP TABLE if exists question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE if exists replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id)
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id)
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE if exists question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('Dave', 'Chang'),
  ('Walter', 'Wan');

INSERT INTO
  questions (title, body, user_id)
VALUES
  ('How to use each in ruby', 'I just had a quick question regarding loops in Ruby.',
  (SELECT id FROM users WHERE users.id = 2)),
  ('How to survive bootcamp', 'I just had a question about bootcamp life.',
  (SELECT id FROM users WHERE users.id = 2)),
  ('How to cook instent noodle?', 'Use hot water.',
  (SELECT id FROM users WHERE users.id = 1)),
  ('How to query database', 'database is hard',
  (SELECT id FROM users WHERE users.id = 2)),
  ('How to make money', 'life is hard',
  (SELECT id FROM users WHERE users.id = 2));

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE users.id = 1),
  (SELECT id FROM questions WHERE questions.id = 2)),
  ((SELECT id FROM users WHERE users.id = 2),
  (SELECT id FROM questions WHERE questions.id = 1)),
  ((SELECT id FROM users WHERE users.id = 2),
  (SELECT id FROM questions WHERE questions.id = 3)),
  ((SELECT id FROM users WHERE users.id = 1),
  (SELECT id FROM questions WHERE questions.id = 3));

INSERT INTO
  replies (question_id, parent_reply_id ,user_id)
VALUES
  (2, NULL, 1),
  (2, 1, 2),
  (2, 2, 1),
  (2, 2, 2);

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  (3, 2),
  (3, 3),
  (2, 2),
  (1, 2),
  (2, 4),
  (2, 5);
