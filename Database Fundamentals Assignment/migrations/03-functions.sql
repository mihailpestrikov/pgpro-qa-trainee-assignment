CREATE OR REPLACE FUNCTION generate_academy_data(
    num_students INTEGER,
    num_courses INTEGER,
    min_year INTEGER,
    max_year INTEGER,
    min_exams_per_student INTEGER,
    max_exams_per_student INTEGER
) RETURNS VOID AS $$
DECLARE
    i INTEGER;
    j INTEGER;
    num_exams INTEGER;
    student_id INTEGER;
    course_id INTEGER;
    random_score INTEGER;
    random_hours INTEGER;
    random_year INTEGER;
    first_names TEXT[] := ARRAY['Александр', 'Мария', 'Дмитрий', 'Елена', 'Иван', 'Анна', 'Сергей', 'Ольга',
        'Андрей', 'Наталья', 'Алексей', 'Татьяна', 'Владимир', 'Екатерина', 'Павел'];
    last_names TEXT[] := ARRAY['Иванов', 'Смирнов', 'Кузнецов', 'Попов', 'Васильев', 'Петров', 'Соколов',
        'Михайлов', 'Новиков', 'Федоров', 'Морозов', 'Волков', 'Алексеев', 'Лебедев'];
    course_prefixes TEXT[] := ARRAY['Основы', 'Введение в', 'Практикум по', 'Теория', 'Методы',
        'Современные подходы к', 'Прикладные аспекты', 'Анализ и синтез в'];
    course_subjects TEXT[] := ARRAY['программирование', 'базы данных', 'алгоритмы', 'информационные системы',
        'математический анализ', 'дискретная математика', 'статистика',
        'машинное обучение', 'компьютерная графика', 'архитектура ЭВМ'];
BEGIN
    TRUNCATE Students, Courses, Exams CASCADE;

    -- Генерация студентов
    FOR i IN 1..num_students LOOP
            random_year := min_year + floor(random() * (max_year - min_year + 1));
            INSERT INTO Students (name, start_year)
            VALUES (
                       last_names[1 + floor(random() * array_length(last_names, 1))] || ' ' ||
                       first_names[1 + floor(random() * array_length(first_names, 1))],
                       random_year
                   );
        END LOOP;

    -- Генерация курсов
    FOR i IN 1..num_courses LOOP
            random_hours := 30 + floor(random() * 121); -- От 30 до 150 часов
            INSERT INTO Courses (title, hours)
            VALUES (
                       course_prefixes[1 + floor(random() * array_length(course_prefixes, 1))] || ' ' ||
                       course_subjects[1 + floor(random() * array_length(course_subjects, 1))],
                       random_hours
                   );
        END LOOP;

    -- Генерация экзаменов
    FOR student_id IN 1..num_students LOOP
            -- Случайное количество экзаменов для студента
            num_exams := min_exams_per_student + floor(random() * (max_exams_per_student - min_exams_per_student + 1));
            num_exams := LEAST(num_exams, num_courses); -- Не больше, чем количество курсов

            FOR j IN 1..num_exams LOOP
                    -- Выбираем случайный курс, который студент еще не сдавал
                    LOOP
                        course_id := 1 + floor(random() * num_courses);
                        -- Проверяем, что такого экзамена еще нет
                        IF NOT EXISTS (SELECT 1 FROM Exams WHERE s_id = student_id AND c_id = course_id) THEN
                            EXIT;
                        END IF;
                    END LOOP;

                    random_score := 60 + floor(random() * 41); -- От 60 до 100 баллов
                    INSERT INTO Exams (s_id, c_id, score) VALUES (student_id, course_id, random_score);
                END LOOP;
        END LOOP;
END;
$$ LANGUAGE plpgsql;