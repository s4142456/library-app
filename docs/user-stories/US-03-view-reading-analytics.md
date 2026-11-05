# US 03 View Reading Analytics

Average completed-session time per user and the top 10 most-read books by total reading time.

The application roles are `user` and `admin`. Only authenticated users with the `admin` role can access reading analytics; the `user` role cannot access these reports.

Duration is elapsed visit time from US 02: `endTime - startTime`, using server timestamps. It includes any idle time within a completed visit. Only sessions with a recorded valid end time qualify; no heartbeat or abandoned-session recovery is required.

```gherkin
@us03 @must_have @mongodb @reading_analytics
Feature: View reading analytics
  As an authenticated admin
  I want to view reading-time analytics
  So that I can understand user engagement and identify the most-read books

  # Traceability:
  # Project brief - Reading Analytics - Average session time per user
  # Project brief - Reading Analytics - Top 10 books by total reading time
  # Narrowed scope excludes most-highlighted-books analytics
  #
  # Primary actor: Admin
  # Analytics source: MongoDB reading_sessions
  # Enrichment source: MySQL USER and BOOK metadata
  # Dependency: US 02 produces valid reading sessions

  Background:
    Given reading sessions are stored in MongoDB
    And valid completed sessions contain userId, bookId, startTime, and endTime
    And user and book display information exists in MySQL

  Rule: Reading analytics are restricted to admins

    @authorization
    Scenario: Admin opens the analytics dashboard
      Given I am authenticated with the role "admin"
      When I request the reading analytics dashboard
      Then I can request both supported analytics reports

    @authorization
    Scenario Outline: Reject a caller who is not an authenticated admin
      Given my authentication state is "<authentication>"
      And my role is "<role>"
      When I request a reading analytics report
      Then the request is rejected with status <status>
      And no analytics data is returned

      Examples:
        | authentication | role   | status |
        | missing        | NONE   | 401    |
        | invalid        | NONE   | 401    |
        | valid          | user   | 403    |

  Rule: Average session time is calculated per user

    @average_session_time @happy_path
    Scenario: Calculate average completed-session time for each user
      Given User 17 has completed sessions lasting 10, 20, and 30 minutes
      When the average-session-time pipeline runs
      Then User 17 has 3 included sessions
      And User 17 has an average session duration of 20 minutes

    @average_session_time
    Scenario: Return every user with at least one eligible session
      Given several users have valid completed sessions
      When the average-session-time pipeline runs
      Then one result is returned for each user with at least one eligible session
      And each result contains userId
      And each result contains includedSessionCount
      And each result contains averageDurationSeconds
      And the results are ordered by averageDurationSeconds descending

    @average_session_time @precision
    Scenario: Preserve precision during calculation
      Given a user has sessions whose average is not a whole minute
      When the pipeline calculates the average
      Then it calculates duration using seconds or milliseconds
      And rounding for display occurs after aggregation

  Rule: The top 10 most-read books are ranked by total reading time

    @top_books @happy_path
    Scenario: Calculate total reading time for each book
      Given a book has several valid completed sessions from one or more users
      When the top-books pipeline runs
      Then the session durations for that book are summed
      And the result contains bookId
      And the result contains includedSessionCount
      And the result contains totalReadingTimeSeconds

    @top_books
    Scenario: Return no more than 10 books
      Given more than 10 books have valid completed reading sessions
      When the top-books pipeline runs
      Then the books are sorted by totalReadingTimeSeconds descending
      And only the first 10 books are returned

    @top_books @tie_break
    Scenario: Apply a deterministic tie-breaker
      Given two books have the same total reading time
      When the top-books pipeline sorts them
      Then the agreed secondary sort is applied
      And repeated executions produce the same order for unchanged data

    @top_books
    Scenario: Include fewer than 10 books when fewer qualify
      Given only 6 books have eligible sessions
      When the top-books pipeline runs
      Then exactly 6 books are returned
      And no placeholder books are added

  Rule: Only valid completed sessions contribute to analytics

    @data_quality
    Scenario Outline: Exclude an ineligible session
      Given a session has "<condition>"
      When either analytics pipeline runs
      Then the session is excluded
      And the pipeline continues processing other valid sessions

      Examples:
        | condition                              |
        | endTime equal to null                  |
        | missing endTime                        |
        | missing userId                         |
        | missing bookId                         |
        | missing startTime                      |
        | endTime earlier than startTime         |

    @missing_completion
    Scenario: Exclude a visit whose closing update was not received
      Given a user closed the reader
      But no completion update reached the server
      And the session endTime is null
      When an analytics pipeline runs
      Then the session is excluded
      And no end time is inferred from the report request time

    @duplicate_protection
    Scenario: Count one session document once
      Given one valid session document exists
      When the pipeline processes reading_sessions
      Then that session contributes once to its user and book aggregates

  Rule: MongoDB results are enriched from authoritative MySQL metadata

    @enrichment
    Scenario: Display user information with average-session results
      Given the MongoDB pipeline returns a known userId
      When the application prepares the dashboard response
      Then it retrieves the corresponding user display name from MySQL
      And it combines the name with the MongoDB aggregate

    @enrichment
    Scenario: Display book information with top-book results
      Given the MongoDB pipeline returns a known bookId
      When the application prepares the dashboard response
      Then it retrieves the corresponding title and authors from MySQL
      And it combines the metadata with the MongoDB aggregate

    @missing_reference
    Scenario: MongoDB references missing MySQL metadata
      Given an aggregate contains a userId or bookId that no longer exists in MySQL
      When the application enriches the result
      Then it preserves the aggregate identifier for investigation
      And it displays a controlled unknown-user or unknown-book label
      And the complete analytics request does not fail

    @database_boundary
    Scenario: Do not attempt a cross-database join
      When an analytics report is generated
      Then MongoDB performs the duration aggregation
      And the application extracts the distinct resulting identifiers
      And MySQL is queried separately for matching metadata
      And the application combines both result sets

  Rule: The dashboard handles empty loading and failure states

    @empty_state
    Scenario: No eligible completed sessions exist
      Given MongoDB contains no eligible completed sessions
      When I open the analytics dashboard
      Then the average-session report displays a no-data state
      And the top-books report displays a no-data state
      And no misleading zero-valued rankings are shown

    @loading_state
    Scenario: Analytics are loading
      When the dashboard requests the reports
      And one or both responses are pending
      Then a loading state is shown for each pending report
      And the page does not display stale results as current

    @mongodb_error
    Scenario: MongoDB aggregation fails
      Given MongoDB cannot complete a pipeline
      When the analytics request fails
      Then the affected report displays a recoverable error
      And a Retry action is available
      And no pipeline or internal error details are exposed

    @mysql_error
    Scenario: MySQL enrichment fails after aggregation
      Given MongoDB successfully returns aggregate identifiers
      But MySQL metadata cannot be retrieved
      When the dashboard response is prepared
      Then the system returns a controlled partial-data or service-error outcome
      And it does not attach incorrect names or titles

    @accessibility
    Scenario: Read analytics without relying on a chart alone
      When an analytics report is displayed
      Then every metric is available as readable text or an accessible table
      And ranking order is programmatically identifiable
      And duration values include their units

  Rule: Aggregation performance is measured and documented

    @aggregation_pipeline @average_session_time
    Scenario: Use a MongoDB aggregation pipeline for average session time
      When the average-session-time report is generated
      Then MongoDB calculates duration, groups by userId, and averages duration

    @aggregation_pipeline @top_books
    Scenario: Use a MongoDB aggregation pipeline for top books
      When the top-books report is generated
      Then MongoDB calculates duration, groups by bookId, sums duration, sorts descending, and limits to 10

    @optimization @explain
    Scenario: Compare aggregation performance before and after indexing
      Given a representative reading_sessions dataset exists
      And the unoptimized pipeline has been recorded
      When the selected MongoDB indexes are created
      Then execution statistics are captured before indexing
      And execution statistics are captured after indexing
      And totalKeysExamined and totalDocsExamined are compared when applicable
      And the report explains whether each index improves the measured workload

    @index_design
    Scenario: Avoid claiming an index benefit without evidence
      Given an index has been proposed for an analytics pipeline
      When explain execution statistics show no meaningful benefit
      Then the result is documented honestly
      And the index is removed or justified for a different measured query
```

## Analytics Definitions

### Average session time per user

```text
duration = endTime - startTime
group by userId
average duration for each user
```

### Top 10 most-read books by reading time

```text
duration = endTime - startTime
group by bookId
sum duration for each book
sort total duration descending
apply the agreed deterministic tie-breaker
limit to 10
```

## Suggested Interface Contract

```http
GET /api/analytics/average-session-time-by-user
GET /api/analytics/top-books-by-reading-time
```

Suggested result fields:

```text
Average by user:
- userId
- userDisplayName
- includedSessionCount
- averageDurationSeconds

Top books:
- rank
- bookId
- title
- authors
- includedSessionCount
- totalReadingTimeSeconds
```

## Data Sources

- MongoDB `reading_sessions` is authoritative for reading activity and duration aggregation.
- MySQL `USER` is authoritative for user display data.
- MySQL `BOOK`, `AUTHOR`, and `BOOK_AUTHOR` are authoritative for book display data.
- The application performs result enrichment; MongoDB and MySQL are not joined directly.

## Candidate MongoDB Indexes

```javascript
db.reading_sessions.createIndex({ userId: 1, startTime: -1, endTime: 1 })
db.reading_sessions.createIndex({ bookId: 1, startTime: -1, endTime: 1 })
```

These are candidates, not guaranteed optimizations. Final choices must be based on `explain("executionStats")` evidence for the actual pipelines and supporting queries.

## Required Test Data

- Multiple sessions for the same user with different durations.
- Multiple users reading the same book.
- More than 10 books with completed sessions.
- Two books tied on total reading time.
- Active sessions with `endTime: null`.
- Invalid sessions that must be excluded.
- An interrupted visit with no received completion update and endTime equal to null.
- A MongoDB identifier whose MySQL metadata is missing.

## Out of Scope

- Most-highlighted-books analytics.
- Highlight capture and analysis.
- Checkout and physical borrowing reports.
- Personalized recommendations.
- Predictive analytics.
- Exporting reports to PDF or spreadsheets.
- Real-time streaming analytics; the MVP calculates reports on request.
- Recovering incomplete sessions, classifying end reasons, and subtracting idle time.

## Open Decisions

- [ ] Confirm the deterministic tie-breaker for books with equal total reading time.
- [ ] Confirm whether analytics cover all time or support a date range.
- [ ] Confirm the display unit and rounding rule for durations.
- [ ] Confirm the minimum duration, if any, for a session to qualify.

## Related Stories

- US 01 Search and Filter Books.
- US 02 Read a Book in the Web Application.
