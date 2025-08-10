const mysql = require('mysql2');

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'terraform-20250810123542062900000002.c3eiwo6ky5tz.eu-west-1.rds.amazonaws.com',
  user: 'admin',
  password: process.env.DB_PASSWORD || 'Super123?',
  database: 'tasktracker'
});

module.exports = pool.promise();