-- Defying books table structure / schema

CREATE TABLE books (
    bookId INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
    title VARCHAR(255) NOT NULL,
    publisher VARCHAR(100) NOT NULL,
    genre ENUM('comedy', 'action', 'scifi','nonfiction') NOT NULL,
    contentReference VARCHAR(255) NOT NULL
);