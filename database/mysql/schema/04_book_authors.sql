-- Defying book_authors table structure / schema
-- With composite primary key creation

CREATE TABLE book_authors(
    bookId INT NOT NULL,
    authorId INT NOT NULL,
    PRIMARY KEY (bookId, authorId),
    FOREIGN KEY (bookId) REFERENCES books(bookId),
    FOREIGN KEY (authorId) REFERENCES authors(authorId),
);