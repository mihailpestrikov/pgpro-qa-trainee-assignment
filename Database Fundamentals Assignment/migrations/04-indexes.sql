-- Индекс для поиска студентов по имени
CREATE INDEX IF NOT EXISTS idx_students_name ON Students(name);

-- Индекс для поиска курсов по названию
CREATE INDEX IF NOT EXISTS idx_courses_title ON Courses(title);

-- Индексы для ускорения JOIN операций и агрегации
CREATE INDEX IF NOT EXISTS idx_exams_s_id ON Exams(s_id);
CREATE INDEX IF NOT EXISTS idx_exams_c_id ON Exams(c_id);
CREATE INDEX IF NOT EXISTS idx_exams_score ON Exams(score);

-- Составной индекс для часто используемых запросов по курсу и оценке
CREATE INDEX IF NOT EXISTS idx_exams_c_id_score ON Exams(c_id, score);