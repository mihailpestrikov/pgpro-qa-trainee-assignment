-- 5. Запрос на поиск студентов, не сдавших ни одного экзамена
SELECT s.s_id, s.name, s.start_year
FROM Students s
         LEFT JOIN Exams e ON s.s_id = e.s_id
WHERE e.s_id IS NULL;

-- 6. Запрос на список студентов и количество сданных экзаменов
SELECT s.s_id, s.name, COUNT(e.c_id) AS exams_count
FROM Students s
         JOIN Exams e ON s.s_id = e.s_id
GROUP BY s.s_id, s.name
ORDER BY exams_count DESC;

-- 7. Запрос на список курсов со средним баллом
SELECT c.c_id, c.title, c.hours, ROUND(AVG(e.score), 2) AS avg_score
FROM Courses c
         JOIN Exams e ON c.c_id = e.c_id
GROUP BY c.c_id, c.title, c.hours
ORDER BY avg_score DESC;

-- 8. Генерация произвольных данных
SELECT generate_academy_data(50, 10, 2018, 2023, 0, 8);
