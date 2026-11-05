-- Resets the library application's local development MySQL database.
-- Runs the database and table scripts in dependency order,
-- then loads development sample data.
-- schema/00_database.sql drops the existing library-app database and its data.
-- Start the MySQL CLI from database/mysql, then run SOURCE setup.sql;
-- All SOURCE paths below are relative to the client's working directory.

-- Create and select database
SELECT 'Recreating and selecting development database' AS info;
SOURCE ./schema/00_database.sql;

-- Create users table
SELECT 'Creating users table' AS info;
SOURCE ./schema/01_users.sql;

-- Create books table
SELECT 'Creating books table' AS info;
SOURCE ./schema/02_books.sql;

-- Create authors table
SELECT 'Creating authors table' AS info;
SOURCE ./schema/03_authors.sql;

-- Create book_authors table
SELECT 'Creating book_authors table' AS info;
SOURCE ./schema/04_book_authors.sql;

-- Load sample records after all tables and foreign keys exist.
SELECT 'Loading development sample data' AS info;
SOURCE ./seeds/sample_data.sql;

-- Check table records after insertion. Use UNION ALL to group results into one row
-- Expected counts: users = 5, books = 15, authors = 10, book_authors = 23.
SELECT 'users' AS table_name, COUNT(*) AS record_count FROM users
UNION ALL
SELECT 'books', COUNT(*) FROM books
UNION ALL
SELECT 'authors', COUNT(*) FROM authors
UNION ALL
SELECT 'book_authors', COUNT(*) FROM book_authors;
