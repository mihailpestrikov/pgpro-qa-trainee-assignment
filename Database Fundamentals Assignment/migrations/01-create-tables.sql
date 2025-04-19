CREATE TABLE Students (
                          s_id SERIAL PRIMARY KEY,
                          name VARCHAR(100) NOT NULL,
                          start_year INTEGER NOT NULL CHECK (start_year > 1900 AND start_year <= EXTRACT(YEAR FROM CURRENT_DATE))
);

CREATE TABLE Courses (
                         c_id SERIAL PRIMARY KEY,
                         title VARCHAR(100) NOT NULL,
                         hours INTEGER NOT NULL CHECK (hours > 0)
);

CREATE TABLE Exams (
                       s_id INTEGER NOT NULL,
                       c_id INTEGER NOT NULL,
                       score INTEGER NOT NULL CHECK (score >= 0 AND score <= 100),
                       PRIMARY KEY (s_id, c_id),
                       FOREIGN KEY (s_id) REFERENCES Students (s_id) ON DELETE CASCADE,
                       FOREIGN KEY (c_id) REFERENCES Courses (c_id) ON DELETE CASCADE
);