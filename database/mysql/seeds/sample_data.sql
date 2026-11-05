-- Inserts development sample users, books, authors, and book-author links.
-- Run once against the fresh schema created by setup.sql; IDs are explicit
--
-- Every demo account uses the password LibraryDemo123!.
-- passwordHash contains a salted Node.js scrypt hash, not the plain password.
-- Format: scrypt$N$r$p$saltHex$derivedKeyHex (32-byte derived key).
-- Authentication is not implemented yet; a verifier must support this format.

USE `library-app`;

-- Four ordinary users and one admin for authorization and analytics examples.
INSERT INTO users (userId, name, passwordHash, role, email)
VALUES
    (1, 'Alex Nguyen', 'scrypt$16384$8$1$649ea450bdfb5283c895cc8df3efe3a3$e1aa24ed171f6265c182f34021e06694a58c18ff4d90276ec7d056094d0afd8e', 'user', 'alex@example.test'),
    (2, 'Sam Tran', 'scrypt$16384$8$1$a048f091fde564b4bc73cf2927e531c4$c27cff67be52e3accfe2b378d4df5c9d7dd9fc170816ca22877185a4ba4799a9', 'user', 'sam@example.test'),
    (3, 'Jamie Le', 'scrypt$16384$8$1$33e3b8ab526e91eba995f318956bf6b0$2aae829cb934f6897b9882ce34460b2c379f02d98d83acd7cbe31f2da285fb78', 'user', 'jamie@example.test'),
    (4, 'Taylor Pham', 'scrypt$16384$8$1$8a646af36d727e313311a29e413cadf8$cd9adaa7552de2454915624f6236d54882fbe8339df2fd0f17b8281d4945c5d5', 'user', 'taylor@example.test'),
    (5, 'Morgan Admin', 'scrypt$16384$8$1$f9f5b86d48bd9ec8cb3b9fca83d60eea$ff81332f3af37875a131c8779002c2afe726637addeaf6a6e1a39cf8262b29d7', 'admin', 'admin@example.test');

-- Fifteen books covering all four allowed genres and several publishers.
-- Similar titles and repeated publishers support search and filter exercises.
INSERT INTO books (bookId, title, publisher, genre, contentReference)
VALUES
    (1, 'The Art of Acting', 'North Press', 'nonfiction', 'storage/books/the-art-of-acting.pdf'),
    (2, 'Ocean Life', 'West Press', 'scifi', 'storage/books/ocean-life.pdf'),
    (3, 'City Pursuit', 'East Press', 'action', 'storage/books/city-pursuit.pdf'),
    (4, 'Garden Notes', 'Active Press', 'nonfiction', 'storage/books/garden-notes.pdf'),
    (5, 'Winter Tales', 'South Press', 'comedy', 'storage/books/winter-tales.pdf'),
    (6, 'Database Fundamentals', 'Pearson', 'nonfiction', 'storage/books/database-fundamentals.pdf'),
    (7, 'The Database Detective', 'Pearson', 'action', 'storage/books/the-database-detective.pdf'),
    (8, 'Orbit Beyond Midnight', 'North Press', 'scifi', 'storage/books/orbit-beyond-midnight.pdf'),
    (9, 'The Accidental Comedian', 'East Press', 'comedy', 'storage/books/the-accidental-comedian.pdf'),
    (10, 'Clean Code Notes', 'Pearson', 'nonfiction', 'storage/books/clean-code-notes.pdf'),
    (11, 'Action at Dawn', 'West Press', 'action', 'storage/books/action-at-dawn.pdf'),
    (12, 'Galactic Gardens', 'Active Press', 'scifi', 'storage/books/galactic-gardens.pdf'),
    (13, 'Laughing at Lunch', 'South Press', 'comedy', 'storage/books/laughing-at-lunch.pdf'),
    (14, 'Reading Between Stars', 'North Press', 'scifi', 'storage/books/reading-between-stars.pdf'),
    (15, 'The Last Train', 'East Press', 'action', 'storage/books/the-last-train.pdf');

INSERT INTO authors (authorId, name)
VALUES
    (1, 'Alice Brown'),
    (2, 'Arthur Acton'),
    (3, 'Mary Green'),
    (4, 'Jane Smith'),
    (5, 'John White'),
    (6, 'Daniel Nguyen'),
    (7, 'Dana Nguyen'),
    (8, 'Maya Chen'),
    (9, 'Omar Patel'),
    (10, 'Lena Tran');

-- Twenty-three distinct pairs: every book and author participates.
-- Some books have multiple authors, and some authors have multiple books.
INSERT INTO book_authors (bookId, authorId)
VALUES
    (1, 1),
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5),
    (6, 6),
    (7, 6),
    (7, 7),
    (8, 8),
    (8, 9),
    (9, 5),
    (9, 10),
    (10, 6),
    (10, 2),
    (11, 3),
    (11, 7),
    (12, 4),
    (12, 8),
    (13, 1),
    (13, 5),
    (14, 8),
    (14, 10),
    (15, 7);
