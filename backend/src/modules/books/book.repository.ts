import type { RowDataPacket } from 'mysql2';
import { pool } from '../../database/mysql';

// LOWER() for case insensitive
const sql = `
    SELECT b.title, b.publisher, b.genre, a.name 
    FROM books AS b
        JOIN book_authors AS ba
        ON b.bookId = ba.bookId
        JOIN authors AS a 
        ON ba.authorId = a.authorId
    WHERE 
        LOWER(b.title) LIKE LOWER(?)
        OR LOWER(b.publisher) LIKE LOWER(?)
        OR LOWER(b.genre) LIKE LOWER(?)
        OR LOWER(a.name) LIKE LOWER(?);
`;