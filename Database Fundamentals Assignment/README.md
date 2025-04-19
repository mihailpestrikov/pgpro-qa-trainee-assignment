# PostgreSQL Academy Database Solution

## 1. Установка PostgreSQL с использованием Docker Compose

Создайте файл `docker-compose.yml` со следующим содержимым:

```yaml
services:
   postgres:
      image: postgres:latest
      container_name: postgres-academy
      environment:
         POSTGRES_DB: academy
         POSTGRES_USER: postgres
         POSTGRES_PASSWORD: pgpro-test-assignment-password
      ports:
         - "5432:5432"
      volumes:
         - postgres-data:/var/lib/postgresql/data
         - ./migrations:/docker-entrypoint-initdb.d
      restart: unless-stopped

volumes:
   postgres-data:
```

## 2. Создайте директорию `migrations` и поместите в неё следующие файлы:

### 01-create-tables.sql
```sql
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
```

### 02-seed-data.sql
```sql
INSERT INTO Students (name, start_year) VALUES
    ('Иванов Иван', 2020),
    ('Петрова Мария', 2021),
    ('Сидоров Алексей', 2019),
    ('Козлова Елена', 2022),
    ('Николаев Дмитрий', 2021);

INSERT INTO Courses (title, hours) VALUES
    ('Базы данных', 72),
    ('Программирование на Python', 108),
    ('Алгоритмы и структуры данных', 90),
    ('Веб-разработка', 120),
    ('Математический анализ', 144);

INSERT INTO Exams (s_id, c_id, score) VALUES
    (1, 1, 85),  -- Иванов сдал Базы данных
    (1, 2, 78),  -- Иванов сдал Python
    (2, 2, 92),  -- Петрова сдала Python
    (3, 1, 79),  -- Сидоров сдал Базы данных
    (3, 3, 88),  -- Сидоров сдал Алгоритмы
    (3, 5, 73),  -- Сидоров сдал Мат. анализ
    (4, 4, 95);  -- Козлова сдала Веб-разработку
    -- Николаев Дмитрий не сдал ни одного экзамена
```

### 03-functions.sql
```sql
-- Функция для генерации случайных данных
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
```

### 04-indexes.sql
```sql
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
```

## 3. Запустите контейнер с помощью Docker Compose:

```bash
docker-compose up -d
```
При первом запуске PostgreSQL автоматически выполнит все скрипты из директории /docker-entrypoint-initdb.d в алфавитном порядке.

## 4. Подключение к базе данных, например через DataGrip

1. Выберать File → New → Data Source → PostgreSQL
2. Ввести параметры подключения:
    - Host: localhost
    - Port: 5432
    - Database: academy
    - User: postgres
    - Password: pgpro-test-assignment-password
3. "Test Connection", "Apply", "Ok"

## 5. Запросы для заданий 5-7
Запрос на поиск студентов, не сдавших ни одного экзамена
```sql
SELECT s.s_id, s.name, s.start_year
FROM Students s
         LEFT JOIN Exams e ON s.s_id = e.s_id
WHERE e.s_id IS NULL;
```

Запрос на список студентов и количество сданных экзаменов
```sql
SELECT s.s_id, s.name, COUNT(e.c_id) AS exams_count
FROM Students s
         JOIN Exams e ON s.s_id = e.s_id
GROUP BY s.s_id, s.name
ORDER BY exams_count DESC;
```

Запрос на список курсов со средним баллом
```sql
SELECT c.c_id, c.title, c.hours, ROUND(AVG(e.score), 2) AS avg_score
FROM Courses c
         JOIN Exams e ON c.c_id = e.c_id
GROUP BY c.c_id, c.title, c.hours
ORDER BY avg_score DESC;
```

## 8. Вызов функции для генерации произвольных данных

```sql
SELECT generate_academy_data(
               50,     -- 50 студентов
               10,     -- 10 курсов
               2018,   -- Мин. год поступления
               2023,   -- Макс. год поступления
               0,      -- Мин. количество экзаменов для студента
               8       -- Макс. количество экзаменов для студента
       );
```

## Примечание по реализации

1. **Автоматическая миграция**: При первом запуске контейнера PostgreSQL автоматически выполняет скрипты из директории /docker-entrypoint-initdb.d.
2. **Персистентность данных**: Данные сохраняются в именованном томе Docker (postgres-data).
3. **Типы данных**: Использованы SERIAL для автоинкремента ID, VARCHAR для имен и названий, INTEGER для числовых значений.
4. **Ограничения**: Добавлены CHECK ограничения для годов (не раньше 1900 и не позже текущего года), часов (положительное число) и оценок (от 0 до 100).
5. **Связи**: Созданы внешние ключи с каскадным удалением, при удалении студента или курса будут удалены и связанные записи в таблице Exams.
6. **Тестовые данные**: Добавлены базовые данные для демонстрации работы запросов.
7. **Генератор данных**: Создана функция на PL/pgSQL для генерации произвольных данных с настраиваемыми параметрами.

## Индексы

В базе данных используются следующие индексы для оптимизации запросов:

#### 1. Для таблицы `Students`:

- `idx_students_name` - ускоряет поиск студентов по имени

#### 2. Для таблицы `Courses`:

- `idx_courses_title` - оптимизирует поиск курсов по названию

#### 3. Для таблицы `Exams`:

- `idx_exams_s_id` - ускоряет поиск экзаменов по студенту (JOIN в запросах)
- `idx_exams_c_id` - ускоряет поиск экзаменов по курсу (JOIN и GROUP BY)
- `idx_exams_score` - оптимизирует запросы с фильтрацией по оценке
- `idx_exams_c_id_score` - специально для запроса среднего балла по курсам

## Альтернативы для генерации моковых данных:
- Python с библиотекой Faker
- Mockaroo - онлайн-сервис для генерации CSV/SQL с моковыми данными