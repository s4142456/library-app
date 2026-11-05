# US 01 Search and Filter Books

This Gherkin specification defines how an authenticated user discovers readable books through a search bar and filters. Borrowing and physical-copy availability are not part of this narrowed feature.

```gherkin
@us01 @must_have @book_search
Feature: Search and filter readable books
  As an authenticated user
  I want to search for books and narrow the results with filters
  So that I can quickly find a book that I want to read in the web application

  # Traceability:
  # Project brief - Functional Requirements - Book Search
  # Narrowed scope - Search bar, filters, and entry into the web reader
  #
  # Primary actor: Authenticated user
  # Data source: MySQL
  # Dependencies: BOOK, AUTHOR, and BOOK_AUTHOR data; published digital content

  Background:
    Given I am authenticated
    And the MySQL database contains published books
    And each published book has a title, at least one author, a publisher, and a genre
    And each searchable book has readable digital content
    And I am on the book search page

  Rule: A user can browse books without entering a search term

    @browse @happy_path
    Scenario: Browse the default book list
      Given the search bar is empty
      And no filters are selected
      When the search page loads
      Then the system returns the default set of published readable books
      And the books are ordered by title in ascending alphabetical order
      And each result shows its title, authors, publisher, and genre
      And each result provides a Read Online action

    @empty_search
    Scenario: Submit an empty search term
      Given the search bar contains only whitespace
      When I submit the search
      Then the system treats the search term as empty
      And the system applies only the selected filters

  Rule: The search bar uses case-insensitive partial matching across title author name genre or publisher

    # Trim surrounding whitespace and treat the remaining term as one literal substring.
    # A match anywhere in any one of the four fields is sufficient (OR semantics).
    # A complete field value also matches under this same rule; it is not a separate search mode.

    @partial_search @case_insensitive
    Scenario Outline: Match a substring in any searchable field regardless of case
      Given a published readable book has "<value>" in its "<field>" field
      And none of its other searchable fields contains "<term>" ignoring case
      And no filters are selected
      When I search for "<term>"
      Then the book is returned once

      Examples:
        | field       | value         | term   |
        | title       | The Hobbit    | hob    |
        | title       | The Hobbit    | HOB    |
        | title       | The Hobbit    | obb    |
        | author name | George Orwell | orw    |
        | author name | George Orwell | ORW    |
        | author name | George Orwell | well   |
        | genre       | Fantasy       | fant   |
        | genre       | Fantasy       | FANT   |
        | genre       | Fantasy       | anta   |
        | publisher   | Pearson       | pear   |
        | publisher   | Pearson       | PEAR   |
        | publisher   | Pearson       | arso   |

    @partial_search @cross_field_matches
    Scenario: Return all books matching through any searchable field
      Given the following published readable books exist:
        | book ID | title              | author name | genre      | publisher     |
        | 101     | The Art of Reading | Alice Brown | Education  | North Press   |
        | 102     | Ocean Life         | Arthur Lee  | Science    | West Press    |
        | 103     | Colour Studies     | Mary Green  | Fine Arts  | East Press    |
        | 104     | Garden Notes       | Jane Smith  | Gardening  | Artisan Press |
        | 105     | Winter Tales       | John White  | Fiction    | South Press   |
      And no filters are selected
      When I search for "aRt"
      Then exactly books 101, 102, 103, and 104 are returned
      And book 105 is excluded because none of its searchable fields contains the term

    @partial_search @deduplication
    Scenario: Return a book once when several fields match
      Given a published readable book contains "art" in both its title and publisher
      And no filters are selected
      When I search for "ART"
      Then the book is returned once

    @input_normalization
    Scenario: Ignore surrounding whitespace
      Given a published book titled "Clean Code" exists
      When I search for "  clean code  "
      Then the system treats the term as "clean code"
      And the results include "Clean Code"

    @multi_author
    Scenario: Match any author of a multi-author book
      Given a published book is associated with "Author One" and "Author Two"
      When I search for "tWo"
      Then the book is returned once
      And both authors are displayed

  Rule: A user can filter books by genre and publisher

    @genre_filter
    Scenario: Filter by genre
      Given published books exist in several genres
      When I select the genre "Fantasy"
      Then every returned book has the genre "Fantasy"
      And books from other genres are excluded

    @publisher_filter
    Scenario: Filter by publisher
      Given published books exist from several publishers
      When I select the publisher "Pearson"
      Then every returned book has the publisher "Pearson"
      And books from other publishers are excluded

    @combined_filters
    Scenario: Combine a text search with genre and publisher filters
      Given books exist across several authors, genres, and publishers
      When I search for "database"
      And I select the genre "Technology"
      And I select the publisher "Pearson"
      Then each result contains "database" in its title, any associated author name, genre, or publisher ignoring case
      And each result has the genre "Technology"
      And each result has the publisher "Pearson"

    @filter_semantics
    Scenario: Apply AND semantics between filter categories
      Given I have selected a genre and a publisher
      When the search is evaluated
      Then a book must match both selected filter categories
      And containing the search term in the title, any associated author name, genre, or publisher ignoring case satisfies the text-search condition

    @combined_filters
    Scenario: Exclude a text match that fails a selected filter
      Given a published readable book has publisher "Pearson" and genre "Science"
      When I search for "PEAR"
      And I select the genre "Fantasy"
      Then that book is excluded even though its publisher matches the search term

    @clear_search
    Scenario: Clear the search and filters
      Given I entered a search term
      And I selected one or more filters
      When I select Clear
      Then the search term is removed
      And the genre and publisher filters return to their default values
      And the default book list is loaded

  Rule: Search parameters are validated by the server

    @validation @security
    Scenario Outline: Reject an invalid filter value
      Given a modified client bypasses the normal filter controls
      When it submits "<parameter>" with the unsupported value "<value>"
      Then the server rejects the request with a validation error
      And the value is not interpolated directly into SQL
      And no internal database details are exposed

      Examples:
        | parameter | value      |
        | genre     | invalid-id |
        | publisher | invalid-id |

    @valid_options
    Scenario: Display only valid filter choices
      Given genres and publishers exist in the approved data source
      When the filter controls load
      Then every selectable genre is valid
      And every selectable publisher is valid
      And the user is not required to enter an internal identifier manually

  Rule: Results contain enough information to identify and read a book

    @result_metadata
    Scenario: Return the required book metadata
      When a book appears in the results
      Then it contains a stable book identifier
      And it contains the title
      And it contains all associated author names
      And it contains the publisher
      And it contains the genre
      And it indicates that digital content is available

    @relational_join @multi_author
    Scenario: Do not duplicate a book when joining authors
      Given a book has two or more authors
      When the MySQL query joins BOOK, BOOK_AUTHOR, and AUTHOR
      Then the results contain one entry for that book
      And all associated authors are included in the entry

    @read_online
    Scenario: Open a book from the results
      Given a book appears in the search results
      When I select Read Online
      Then the application opens that book in the web reader
      And the reader receives the correct book identifier
      And the reading-session behavior follows US 02

    @unpublished_content
    Scenario: Exclude a book whose digital content is not published
      Given a book record exists without published readable content
      When I search for that book
      Then the book is not included in the readable search results
      And no broken Read Online action is displayed

  Rule: The interface handles loading empty failure and accessibility states

    @no_results
    Scenario: No books match the submitted criteria
      Given no published readable book matches the search term and filters
      When the search completes
      Then the page displays a clear no-results message
      And no stale results remain visible
      And I can clear or change the criteria

    @loading_state
    Scenario: A search is in progress
      When the client sends a search request
      And the response has not arrived
      Then a loading state is visible
      And the current criteria remain visible

    @error_state
    Scenario: Search fails
      Given the server or MySQL database cannot complete the search
      When the request fails
      Then the page displays a recoverable error message
      And a Retry action is available
      And no SQL statement or internal error is displayed

    @accessibility
    Scenario: Search and select a book using a keyboard
      Given I use only a keyboard
      When I navigate through the search bar, filters, results, and Read Online actions
      Then every interactive control receives visible focus
      And pressing Enter in the search bar submits the criteria
      And the Read Online action can be activated without a pointer device

    @debounce
    Scenario: Avoid sending a request for every rapid keystroke
      Given automatic search is enabled
      When I type several characters rapidly
      Then the client debounces the input
      And it searches using the settled term

  Rule: Search queries are secure and measurable

    @parameterized_query
    Scenario: Use parameter binding
      Given I supply a search term and optional filters
      When the server constructs the MySQL query
      Then every user-supplied value is passed through prepared-statement parameters
      And raw user input is not concatenated into SQL

    @optimization @query_plan
    Scenario: Provide evidence of search optimization
      Given a representative dataset large enough to expose query-cost differences
      And the unoptimized search query has been recorded
      When the selected indexes or text-search strategy are applied
      Then the query plan before optimization is captured
      And the query plan after optimization is captured
      And comparable execution times are recorded
      And the report explains why the selected indexes help

    @text_matching
    Scenario: Preserve search behavior during optimization
      Given the search returns books using case-insensitive substring matching across all four searchable fields
      When the search implementation is optimized
      Then the same books are returned for the same criteria and dataset
      And matching remains supported at the beginning, middle, and end of each field
      And optimization does not replace substring matching with prefix-only or whole-word matching
```

## Suggested Interface Contract

```http
GET /api/books?search=<term>&genre=<genre>&publisher=<publisher>
GET /api/books/{bookId}/read
```

The search response should include `bookId`, `title`, `authors`, `publisher`, `genre`, and `digitalContentAvailable`. It must not expose a server file-system path or unrestricted storage credential.

The `search` parameter is trimmed and matched as a case-insensitive literal substring anywhere in `title`, any associated author name, `genre`, or `publisher`. These four checks use OR semantics. A complete field value is covered by the same rule. An empty term adds no text-search restriction. Explicit genre and publisher filters still narrow the results using AND semantics; they remain selections of particular genre or publisher values.

Treat characters in the search term as literal text, including any characters that the query mechanism otherwise interprets as wildcards. Parameter binding and literal matching must both be preserved.

## Relational Model Implications

- `USER` stores the authenticated user identity.
- `BOOK` stores bookId, title, publisher, genre, and a protected contentReference.
- "Published readable" means the book has content approved for this application and available through the content endpoint. This narrowed scope does not require a separate publicationStatus or digitalFormat field. The reader obtains page count from the chosen content format when available.
- `AUTHOR` stores each author once.
- `BOOK_AUTHOR` resolves the many-to-many relationship between books and authors.
- Each `BOOK_AUTHOR` row contains bookId and authorId; the pair is its composite primary key, and each value references its parent entity. Author names are stored in `AUTHOR`, not duplicated in `BOOK_AUTHOR`.
- Each book has one or more author links; each stored author has one or more book links. Each link refers to exactly one book and one author.

## Candidate MySQL Indexes

- `BOOK(title)`.
- `BOOK(genre, publisher)` or separate indexes justified by query plans.
- `AUTHOR(author_name)`.
- `BOOK_AUTHOR(author_id, book_id)`.

Index choices must preserve the required substring behavior. Do not assume that a title or author-name index accelerates every contains query, or substitute different matching semantics to obtain an index benefit. Use the query-plan evidence to justify indexes for the actual query, including its filters and joins.

## Required Test Data

- Titles, author names, genres, and publishers searched using mixed capitalization.
- Substrings at the beginning, middle, and end of each searchable field.
- Books matching only through genre or publisher.
- A book matching several searchable fields that must appear once.
- A book matching the term but excluded by a selected filter.
- Several titles containing the same term.
- Similar author names.
- At least one multi-author book.
- Several genres and publishers.
- A published book with readable digital content.
- An unpublished or missing-content book.
- Enough rows for meaningful query-plan comparison.

## Out of Scope

- Borrowing and returning physical books.
- Physical inventory and available-copy counts.
- Reviews and ratings.
- Administrative book management.
- Recommendations and personalized ranking.
- Fuzzy spelling correction and synonym search.
- Advanced user-controlled sorting.
- Reading analytics, which belongs to US 03.

## Open Decisions

- [ ] Confirm whether publisher remains an attribute of `BOOK` or becomes a separate entity.
- [ ] Confirm the supported digital format: HTML pages, PDF, EPUB, or one selected format.
- [ ] Confirm whether pagination is required for the submission dataset.

## Related Stories

- US 02 Read a Book in the Web Application.
- US 03 View Reading Analytics.
