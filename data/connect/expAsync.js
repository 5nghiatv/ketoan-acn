const dotenv = require('dotenv')
dotenv.config()
exports.dbConfig = {
  host: process.env.DB_HOST,
  user: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
  port: process.env.DB_PORT,
  debug: false,
  multipleStatements: true,
}

const fs = require('fs')
//fs.readFileSync(path.join(__dirname, 'data/connect/test.sql'), { encoding: "UTF-8" }).split(";\n");
exports.readFile = function (path) {
  return new Promise((resolve, reject) => {
    fs.readFile(path, 'utf8', function (err, data) {
      if (err) {
        reject(err)
      }
      resolve(data)
    })
  })
}

const mysql = require('mysql2')
exports.connection = function (params) {
  return new Promise((resolve, reject) => {
    const connection = mysql.createConnection(params)
    connection.connect((error) => {
      if (error) {
        reject(error)
      } else resolve(connection)
    })
  })
}

exports.query = function (conn, q, params) {
  return new Promise((resolve, reject) => {
    conn.query(q, params, (err, results) => {
      if (err) reject(err)
      resolve(results)
    })

    // conn.query(q, params)
    // const handler = (error, result) => {
    //   if (error) {
    //     reject(error)
    //   } else resolve(result)
    // }
    // conn.query(q, params, handler)
  })
}
