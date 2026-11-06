export type BookGenre = 'comedy' | 'action' | 'scifi' | 'nonfiction';

export interface BookSearchQueryDto {
    search?: string | null;
    genre?: BookGenre | null;
    publisher?: string | null;
}

export interface BookSearchResultDto {
    bookId: number;
    title: string;
    publisher: string;
    genre: BookGenre;
    authors: string[];
}
