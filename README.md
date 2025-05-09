# Тестовое задание для Postgres Pro

Реализация тестового задания для стажировки в Postgres Pro, включающее две части:
1. Теория тестирования
2. Основы баз данных

## Часть 1: Теория тестирования

План тестирования web интернет-магазина на протяжении 4-месячного цикла разработки (3 месяца разработки + 1 месяц поддержки).

- Разбивка процесса на этапы с описанием действий
- Применение методологий и принципов тестирования
- Управление рисками и ресурсами

## Часть 2: Основы баз данных

- База данных учебного заведения со студентами, курсами и экзаменами
- PostgreSQL в Docker контейнере
- Миграции для создания схемы БД и наполнения данными
- Запросы для решения поставленных задач
- Функция для генерации произвольных данных

### Структура проекта

```
academy-project/
├── docker-compose.yml       # Docker Compose для PostgreSQL
├── migrations/              # Директория с миграциями
│   ├── 01-create-tables.sql # Создание таблиц
│   ├── 02-seed-data.sql     # Наполнение тестовыми данными
│   ├── 03-functions.sql     # Функции для генерации данных
│   └── 04-indexes.sql       # Индексы для оптимизации запросов
└── querries/                # Директория с SQL запросами
    └── answers.sql          # Запросы для заданий 5-7
```

### Быстрый старт

1. **Установка и запуск**

```bash
git clone pgpro-qa-trainee-assignment
cd pgpro-qa-trainee-assignment
docker-compose up -d
```

2. **Подключение к базе данных**

```
Host: localhost
Port: 5432
Database: academy
User: postgres
Password: pgpro-test-assignment-password
```

### Модель данных

База данных состоит из трех таблиц:
- **Students**: информация о студентах (ID, имя, год поступления)
- **Courses**: информация о курсах (ID, название, количество часов)
- **Exams**: результаты экзаменов (связь студента с курсом и полученная оценка)

### Основные функции

- Хранение информации о студентах и курсах
- Учет результатов экзаменов
- Генерация тестовых данных
- Оптимизированные запросы благодаря индексам