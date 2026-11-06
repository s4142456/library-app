// Creates and exports a reusable MySQL connection pool for backend queries.

import 'dotenv/config';
import mysql, {type Pool} from 'mysql2/promise';

function createPool() {
    // use createPool() for multiple request
    // call host, port, user, password, database from .env
    // set 5 database connections. Could check sizng guidance
    return mysql.createPool({
        host: process.env.DB_HOST,
        port: Number(process.env.DB_PORT || 3306),
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        waitForConnections: true,
        connectionLimit: 5
    });
};

export const pool = createPool();