# Library App

A small library web application for practicing database design and backend development. The interface will remain basic so development can focus on SQL queries, database connections, views, procedures, functions, triggers, and MongoDB aggregation.

## Scope

- Search and filter books by title, author, genre, and publisher.
- Read a selected book in the web application and record a reading session.
- Show average completed-session time per user and the top 10 books by total reading time.

Application roles are `user` and `admin`. Reading analytics are restricted to `admin` accounts. The supported genre values are `comedy`, `action`, `scifi`, and `nonfiction`.

## Tech stack

MySQL and MongoDB are confirmed choices. The existing TypeScript, TSX, and Vite file names indicate an intended application stack; the framework and driver choices below document recommendations, not installed dependencies.

| Layer | Technology | Purpose | Decision status |
| --- | --- | --- | --- |
| Frontend | React + TypeScript | Basic search, reader, login, and analytics screens | Planned from the TSX scaffold |
| Frontend tooling | [Vite](https://vite.dev/guide/) | Frontend development server and production build | Planned from the Vite scaffold |
| Styling | Plain CSS | Minimal functional styling | Proposed |
| Backend runtime and language | Node.js + TypeScript | Run the HTTP API and database access code | Planned from the TypeScript backend scaffold |
| Backend framework | [Express](https://expressjs.com/) | HTTP routes and middleware | Proposed |
| Relational database | MySQL | Users, books, authors, and book-author relationships | Confirmed |
| MySQL driver | [mysql2](https://sidorares.github.io/node-mysql2/docs/documentation) | Connection pools and parameterized SQL, using the Promise API | Proposed |
| Document database | MongoDB | Reading-session documents and duration aggregations | Confirmed |
| MongoDB driver | [Official MongoDB Node.js driver](https://www.mongodb.com/docs/drivers/node/current/) | Access MongoDB from the backend | Proposed |
| Package manager | npm | Manage JavaScript/TypeScript dependencies and development commands | Proposed |

The proposed database access approach uses SQL written directly by the developer and MongoDB aggregation pipelines. An ORM is not planned, to keep database behavior visible for learning. JDBC is a Java API and is not part of this proposed Node.js backend.

The frontend sends HTTP requests to the backend. The backend connects to MySQL and MongoDB. MongoDB aggregates reading activity; the backend retrieves matching MySQL metadata and combines the results.

## Database setup and connection code

Different files have different responsibilities:

| Location | Responsibility |
| --- | --- |
| `database/mysql/setup.sql` | Intended entry point for running database creation, table scripts, and development seed data in order |
| `database/mysql/schema/00_database.sql` | Create and select the MySQL database named `library-app` |
| `database/mysql/schema/01_users.sql` through `04_book_authors.sql` | Define the four relational tables and their constraints |
| `database/mysql/seeds/sample_data.sql` | Insert development sample records |
| `backend/src/database/mysql.ts` | Backend MySQL connection configuration and connection pool |
| `backend/src/database/mongodb.ts` | Backend MongoDB client and connection management |
| `database/mongodb/` | MongoDB validation, seed, index, and practice scripts |

The setup file is `.sql` because it is intended to contain SQL and MySQL client commands for database initialization. It is executed through a connected MySQL client, independently of the application. MySQL client commands such as `SOURCE` are interpreted by the client; they are not SQL statements sent through a Node.js driver.

A JavaScript or TypeScript setup runner could be added later to connect to the server and execute initialization statements programmatically. It is not necessary for the initial SQL-based setup, and it would not replace the backend's runtime connection module.

Saving a SQL file does not execute it. The database and tables are created only when the scripts are run against MySQL. Because the database name contains a hyphen, use backticks around `library-app` in SQL identifiers.

## Current implementation status

- The MySQL database and table definition scripts contain initial SQL.
- `setup.sql` currently contains purpose comments only; its orchestration commands still need to be written.
- Package manifests, application source/configuration files, database connection modules, and seed files are still placeholders. The application is not runnable yet.
- Package versions and installation/startup commands have not been configured.
- The book content format and authentication implementation still need to be selected.
- `compose.yaml` is a placeholder. Local database services are the current development approach; Docker configuration has not been implemented.

The next milestone is to execute and verify the MySQL schema, add sample data, then initialize the backend dependencies and test its MySQL connection.
