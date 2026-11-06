import type { RowDataPacket } from 'mysql2';
import { pool } from '../../database/mysql';
import type { BookSearchQueryDto, BookSearchResultDto } from './book.dto';

// Only the repository needs MySQL2's row type; the DTO stays database-independent.
interface BookRow extends RowDataPacket, BookSearchResultDto {}

const sql = `
    SELECT
        b.bookId,
        b.title,
        b.publisher,
        b.genre,
        JSON_ARRAYAGG(a.name) AS authors
    FROM books AS b
    JOIN book_authors AS ba
        ON b.bookId = ba.bookId
    JOIN authors AS a
        ON ba.authorId = a.authorId
    WHERE (? IS NULL OR b.publisher = ?)
      AND (? IS NULL OR b.genre = ?)
    GROUP BY b.bookId, b.title, b.publisher, b.genre
    HAVING (
        ? IS NULL
        OR LOWER(b.title) LIKE LOWER(?) ESCAPE '!'
        OR LOWER(b.publisher) LIKE LOWER(?) ESCAPE '!'
        OR LOWER(b.genre) LIKE LOWER(?) ESCAPE '!'
        OR SUM(LOWER(a.name) LIKE LOWER(?) ESCAPE '!') > 0
    )
    ORDER BY b.title ASC, b.bookId ASC;
`;

export async function searchBooks(
    criteria: BookSearchQueryDto = {}
): Promise<BookSearchResultDto[]> {
    const search = criteria.search?.trim() || null;
    const publisher = criteria.publisher?.trim() || null;
    const genre = criteria.genre || null;

    // Search input is literal text, so escape LIKE wildcards and the escape character.
    const pattern = search === null
        ? null
        : `%${search.replace(/[!%_]/g, (character) => `!${character}`)}%`;

    const [books] = await pool.execute<BookRow[]>(sql, [
        publisher, publisher,
        genre, genre,
        search,
        pattern, pattern, pattern, pattern
    ]);

    return books;
}
