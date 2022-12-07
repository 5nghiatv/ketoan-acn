const mysql = require('mysql2')
const express = require('express')
const dotenv = require('dotenv')
dotenv.config()
const fs = require('fs')
var request = require('request')
const path = require('path')
const xml2js = require('xml2js')
const moment = require('moment')
const axios = require('axios')
const Excel = require('exceljs')
const JSZip = require('jszip')
const os = require('os') //console.log("Platform: " + os.platform(), "Architecture: " + os.arch());
const tmp = require('tmp')
const iconv = require('iconv-lite')
//import _ from 'lodash';
const _ = require('lodash')

const Connect = require('./server/models/connect')
const { readFile, connection, query, dbConfig } = require('./data/connect/expAsync')

function createConnect() {
  return mysql.createConnection(dbConfig)
}
console.log(
  1,
  'host=' + process.env.DB_HOST,
  2,
  'Database=' + process.env.DB_DATABASE,
  3,
  'user=' + process.env.DB_USERNAME,
)
// ==============================

const waitFor = (ms) => new Promise((r) => setTimeout(r, ms))
//process.env.TZ = 'UTC';
// process.env.TZ = 'GMT';

const { DBFFile } = require('./data/vfp/dbffile/dbf-file')
//const { DBFFile } = require('dbffile')
if (!String.prototype.hasOwnProperty('addSlashes')) {
  String.prototype.addSlashes = function () {
    return this.replace(/'/g, '').replace(/"/g, '').replace(/\\/g, '')
  }
}

function ErrNum(num) {
  return num || 0
}
function iconv1252(str) {
  str = str.addSlashes()
  var buf = iconv.encode(str, 'cp1252')
  return iconv.decode(Buffer.from(buf), 'cp1258')
}

//==================================================
function deleteAllFile(directory, deldir) {
  //const directory = 'public/download/down-temp';
  var directory = path.join(__dirname, directory)
  fs.readdir(directory, (err, files) => {
    if (err) throw err
    for (const file of files) {
      fs.unlink(path.join(directory, file), (err) => {
        if (err) throw err
      })
    }
    if (deldir) {
      fs.rmdir(directory, function (err) {
        if (err) throw err
      })
    }
  })
}
//==================================================
//==================================================
function runQuery(query, fromtodate, req, res, fn) {
  var mysqlConnection = createConnect()
  mysqlConnection.connect((err) => {
    if (!err) {
      mysqlConnection.query(query, fromtodate, (err, rows, fields) => {
        mysqlConnection.destroy()
        fn(rows)
      })
    } else {
      console.log('DB connection failed \n Error : ' + JSON.stringify(err, undefined, 2))
      fn([])
    }
  })
}

function zipTest() {
  var fs = require('fs')
  var JSZip = require('jszip')
  var zip = new JSZip()
  // Add a top-level, arbitrary text file with contents
  zip.file('Hello.txt', 'Hello World\n')
  // Create a directory within the Zip file structure
  var img = zip.folder('images')
  // Sample image data
  imgData =
    'R0lGODlhEAAQAMQAAORHHOVSKudfOulrSOp3WOyDZu6QdvCchPGolfO0o/XBs/fNwfjZ0frl3/zy7////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAkAABAALAAAAAAQABAAAAVVICSOZGlCQAosJ6mu7fiyZeKqNKToQGDsM8hBADgUXoGAiqhSvp5QAnQKGIgUhwFUYLCVDFCrKUE1lBavAViFIDlTImbKC5Gm2hB0SlBCBMQiB0UjIQA7'
  // Add a file to the 'images' directory,
  // and add an image with data URI as contents.
  img.file('star.gif', imgData, { base64: true })
  // JSZip can generate Buffers so you can do the following
  zip
    .generateNodeStream({
      type: 'nodebuffer',
      streamFiles: true,
      compression: 'DEFLATE',
    })
    .pipe(fs.createWriteStream('public/download/test.zip'))
    .on('finish', function () {
      // JSZip generates a readable stream with a "end" event,
      // but is piped here in a writable stream which emits a "finish" event.
      console.log('out.zip written.')
    })
}

//===========================================
function getAllfiles() {
  //===========================================
  const path = require('path')
  const fs = require('fs')
  const log = console.log
  const folder = './'

  fs.readdirSync(folder).forEach((file) => {
    const extname = path.extname(file)
    const filename = path.basename(file, extname)
    const absolutePath = path.resolve(folder, file)
    log(1, absolutePath, file, filename, extname)
  })
}

//===============================================
//upDropbox();

function upDropbox() {
  var filename = './README.md'
  var filenameUp = 'README.md'
  var content = fs.readFileSync(filename)
  console.log(process.env._DROPBOX_TOKEN, 111, content)
  options = {
    method: 'POST',
    url: 'https://content.dropboxapi.com/2/files/upload',
    headers: {
      'Content-Type': 'application/octet-stream',
      Authorization: 'Bearer ' + process.env._DROPBOX_TOKEN,
      'Dropbox-API-Arg': '{"path": "/' + filenameUp + '","mode": "overwrite","autorename": true,"mute": false}',
    },
    body: content,
  }

  request(options, function (err, res, body) {
    console.log('Err : ' + err, 'res : ' + res, 'body : ' + body)
  })

  request(options, function (err, res, body) {
    console.log('Err : ' + err)
    console.log('res : ' + res)
  })
}

function downDropbox() {
  var token = process.env.DROPBOX_TOKEN
  var filename_l = './testDown.sql'
  var filename_s = 'test.sql'
  var options = {
    method: 'POST',
    url: 'https://content.dropboxapi.com/2/files/download',
    headers: {
      'Content-Type': 'application/octet-stream',
      Authorization: 'Bearer ' + token,
      'Dropbox-API-Arg': '{"path": "/files/' + filename_s + '"}',
    },
  }
  request(options, function (err, res, body) {
    console.log('Err : ' + err)
    console.log('res : ' + res)
    fs.writeFileSync(filename_l, body)
    //  var file = fs.createWriteStream(filename_l);
    //  body.pipe(file);
  })
}

//===========================================
function restoreData() {
  const host = process.env.DB_HOST
  const user = process.env.DB_USERNAME
  const password = process.env.DB_PASSWORD
  const database = process.env.DB_DATABASE

  //const Importer = require('mysql-import');
  const Importer = require('./data/connect/mysql-import')
  const importer = new Importer({ host, user, password, database })
  // New onProgress method, added in version 5.0!
  importer.onProgress((progress) => {
    var percent = Math.floor((progress.bytes_processed / progress.total_bytes) * 10000) / 100
    console.log(`${percent}% Completed`)
  })

  var token = process.env.DROPBOX_TOKEN
  var filename_s = process.env.DB_DATABASE + '_' + process.env.DB_USERNAME + '.sql'
  var filesql = './data/connect/template.sql'
  var options = {
    method: 'POST',
    url: 'https://content.dropboxapi.com/2/files/download',
    encoding: null, // <==== FILE ZIP PHẢI CÓ
    headers: {
      'Content-Type': 'application/octet-stream',
      Authorization: 'Bearer ' + token,
      'Dropbox-API-Arg': '{"path": "/' + filename_s + '"}',
    },
  }
  request(options, function (err, res2, body) {
    //let tmpfile = tempDir+'\\'+ Math.floor(Date.now() / 1000) + '_'+ filename_s;
    let tmpfile = tmp.tmpNameSync() + '_' + filename_s

    fs.writeFileSync(tmpfile, body, 'utf8')
    if (fs.existsSync(tmpfile)) {
      filesql = tmpfile
      body = ''
      console.log(1, 'Download từ dropbox và phục hồi Dữ liệu file: ' + tmpfile)
    } else console.log(1, 'Download from dropbox : ' + res2, '==> phục hồi Dữ liệu trực tiếp file: ' + filename_s)

    importer
      .import(body, filesql)
      .then(() => {
        var files_imported = importer.getImported()
        console.log(`${files_imported.length} SQL file(s) imported.`)
        // res.status(200).json({
        //   success: true,
        //   message: 'Phục hồi Dữ liệu THÀNH CÔNG !!',
        //   filename: filename_s
        // }).end();
      })
      .catch((err) => {
        console.error(err)
      })
  })
}

// ===============================
// const { Readable } = require('stream');
// class BufferStream extends Readable {
//     constructor ( buffer ){
//         super();
//         this.buffer = buffer;
//     }

//     _read (){
//         this.push( this.buffer );
//         this.push( null );
//     }
// }

// function bufferToStream( buffer ) {
//     return new BufferStream( buffer );
// }

//==============================================

function writeZip(dir, name) {
  var zip = new JSZip(),
    code = zip.folder(dir),
    output = zip.generate(),
    filename = ['jsd-', name, '.zip'].join('')

  fs.writeFileSync(path.join(__dirname, filename), output)
  console.log('creating ' + filename)
}

// let aa= null;
// let strd = aa ? aa.split('/').reverse().join('-'): '0000-00-00';
// let newdate =  moment( strd , 'YYYY-MM-DD').toDate();
// let tungay = moment('2021-01-01', 'YYYY-MM-DD').toDate();
// console.log( newdate,tungay)

async function aa() {
  let query = `SELECT * FROM dmtenkho`
  let kq = await runSql(query)
  console.log(kq)
}

async function runSql(query) {
  // console.log(1,'LUÔN LUÔN Chạy Database Gốc MỚI CÓ THÔNG TIN')
  console.log(
    0,
    process.env.APP_URL,
    1,
    '-db:',
    process.env.DB_HOST,
    2,
    process.env.DB_DATABASE,
    3,
    process.env.DB_USERNAME,
  ) // Database GỐC
  const connection = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
    port: process.env.DB_PORT,
  })

  //const connection = createConnect(req, res);
  connection.connect((err) => {
    if (err) {
      console.log('Error: ' + err.message)
    }
  })
  try {
    const response = await new Promise((resolve, reject) => {
      connection.query(query, [], (err, results) => {
        connection.destroy()
        if (err) reject(new Error(err.message))
        resolve(results)
      })
    })
    return response
  } catch (error) {
    console.log(500, error)
  }
}

async function bb() {
  let query = `SELECT * FROM dmtenkho`
  let kq = await runQuerySync(query)
  console.log(kq)
}

async function runQuerySync(query, params) {
  var mysqlConnection = createConnect(req, res)
  mysqlConnection.connect((err) => {
    if (err) {
      console.log('Error: ' + err.message)
    }
  })
  try {
    const response = await new Promise((resolve, reject) => {
      mysqlConnection.query(query, params, (err, results) => {
        mysqlConnection.destroy()
        if (err) reject(new Error(err.message))
        resolve(results)
      })
    })
    return response
  } catch (error) {
    console.log(500, error)
  }
}

var res = {}
var req = {
  body: {
    fromtodate: {
      pd_fromdate: '2021-06-01',
      pd_todate: '2021-09-30',
    },
  },
}

testConnect()
function testConnect() {
  const conn = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
    port: process.env.DB_PORT,
  })

  dbConfig.host = 'localhost'
  conn.connect((err) => {
    conn.close()
    if (err) {
      throw err
    }
    console.log('OK.....connected', dbConfig)
  })
}
