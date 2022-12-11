const express = require('express')
const router = express.Router()
const Connect = require('../models/connect')
const { ensureAuthenticated, forwardAuthenticated } = require('../configs/auth')

router.use(ensureAuthenticated, function (req, res, next) {
  next()
})

router.get('/connects', function (req, res) {
  Connect.find((err, docs) => {
    // console.log(docs);
    if (!err) {
      // res.json(docs) ;
      res.render('pages/listconnect', {
        connects: docs, // Mảng cả table
      })
    } else {
      console.log('Error in retrieving connects list :' + err)
    }
  })
})

router.get('/connect/:id', (req, res) => {
  var id = req.path.replace('/connect/', '')
  //console.log(path);
  if (id == '0') {
    // Insert new
    res.render('pages/addconnect', {
      connect: new Connect(),
      btndisabled: 'disabled',
    })
  } else {
    // update old
    Connect.findById(id)
      .then((conn) =>
        res.render('pages/addconnect', {
          connect: conn,
          btndisabled: '',
        }),
      )
      .catch((err) =>
        res.status(500).json({
          success: false,
        }),
      )
  }
})

router.post('/connect/:id', (req, res) => {
  // Check input before ------>  Addnew connect
  const { company, taxcode, address, host, username, password, database, port } = req.body
  let errors = []
  if (password.length < 6) {
    errors.push({ msg: 'Mật khẩu có chiều dài phải lớn hơn 5 ký tự...' })
  }
  if (!company || !taxcode || !address || !host || !username || !password || !database || !port) {
    errors.push({ msg: 'Vui lòng nhập đầy đủ nội dung cần thiết  ...' })
  }
  if (errors.length > 0) {
    res.render('pages/addconnect', {
      errors,
      connect: req.body,
      btndisabled: '',
    })
  }

  if ('addnew' in req.body) {
    // Insert new - 'addnew': is name  of  button submit
    if ('_id' in req.body) {
      delete req.body._id
    }
    //var str = req.body.accounts;
    //acc = str.replace("[, ]","").replace("[","").replace("]","");
    //req.body.accounts =  Array.from(acc.split(','), Number) ;
    req.body.active = req.body.active == 'on' ? true : false
    const connect = new Connect(req.body)
    //res.json(connect);
    connect.save(function (err) {
      if (err) {
        console.log('Server error. Please try again.')
      } else {
        console.log('Server save successfully.')
        res.render('pages/addconnect', {
          connect: new Connect(),
          btndisabled: '',
        })
      }
    })
  } else {
    // checkconnect
    //console.log('update id: '+ req.body._id ); // Phải submit mới có Body
    //res.json(req.body);
    if ('checkconnect' in req.body) {
      const mysql = require('mysql2')
      const retcon = mysql.createConnection({
        host: req.body.host,
        user: req.body.username,
        password: req.body.password,
        database: req.body.database,
      })
      retcon.connect(function (err) {
        // The server is either down
        // Collection.updateMany(conditions, update, options,(err, doc) => {});
        Connect.updateMany({}, { $set: { active: false } }, { multi: true, upsert: true }).exec()
        req.body.active = err ? false : true
        req.body.checked = err ? false : true
        res.render('pages/addconnect', {
          connect: req.body,
          btndisabled: '',
        })
      })
    } else {
      if ('createdatabase' in req.body) {
        createDatabase(req, res)
        // res.render('pages/addconnect', {
        //   connect: req.body,
        //   btndisabled: '',
        //   // success_msg: mess,
        //   error_msg: 'Welcome to docker-compose up -d',
        // })
        // Tạo New Database =======================
      } else {
        // update old
        req.body.active = req.body.active == 'on' ? true : false
        if (req.body.active) {
          ;(process.env.DB_HOST = req.body.host),
            (process.env.DB_USERNAME = req.body.username),
            (process.env.DB_PASSWORD = req.body.password),
            (process.env.DB_DATABASE = req.body.database)
        }
        Connect.update({ _id: req.body._id }, { $set: req.body })
          .exec()
          .then(() => res.redirect('/connects')) // redirect phải có /exp/
          .catch((err) => res.status(500).json({ success: false }))
      }
    }
  }
})

router.delete('/connect/:id', (req, res) => {
  // delete connect
  var id = req.path.replace('/connect/', '')
  Connect.findByIdAndRemove(id)
    .exec()
    .then(() => res.redirect('/connects')) // redirect phải có /exp/
    .catch((err) =>
      res.status(500).json({
        success: false,
      }),
    )
})

async function createDatabase(req, res) {
  const { connection, query, dbConfig } = require('../../data/connect/expAsync')
  dbConfig.host = req.body.host
  dbConfig.user = req.body.username
  dbConfig.password = req.body.password
  dbConfig.database = null

  var conn = await connection(dbConfig)
  if (conn)
    await query(
      conn,
      'CREATE DATABASE IF NOT EXISTS ' + req.body.database + ' CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci',
    )
  else throw new Error('Lỗi kết nối Mysql...')
  conn.close()
  //========================= Create database Nếu chưa có
  const fs = require('fs')
  const JSZip = require('jszip')
  const tmp = require('tmp')
  dbConfig.database = req.body.database
  const Importer = require('../../data/connect/mysql-import')
  const importer = new Importer(dbConfig)
  let localfile = __dirname + '/../../data/Backups-ketoan_upload.zip'
  //console.log(111, localfile)
  fs.readFile(localfile, function (err, data) {
    if (!err) {
      var zip = new JSZip()
      zip.loadAsync(data).then(function (contents) {
        Object.keys(contents.files).forEach(function (filename) {
          if (filename.includes('.sql') && !filename.includes('__MACOSX/')) {
            zip
              .file(filename)
              .async('nodebuffer')
              .then(function (content) {
                // var destfile = './' + filename
                var destfile = tmp.tmpNameSync() + '_' + filename
                fs.writeFileSync(destfile, content)
                if (!fs.existsSync(destfile)) throw 'Not file : ' + filename
                // New onProgress method, added in version 5.0!
                let total_bytes = 0
                importer.onProgress((progress) => {
                  total_bytes = progress.total_bytes
                  var percent = Math.floor((progress.bytes_processed / progress.total_bytes) * 10000) / 100
                  console.log(`${percent}% Completed`)
                })

                importer
                  .import('', destfile)
                  .then(() => {
                    var files_imported = importer.getImported()
                    let mess = `${files_imported.length} SQL file(s): ${total_bytes} bytes imported.`
                    console.log(mess)
                    // res.status(200).json({ success: true, message: mess, filename: filename_s }).end()
                    res.render('pages/addconnect', {
                      connect: req.body,
                      btndisabled: '',
                      success_msg: mess,
                      // error_msg:
                    })
                  })
                  .catch((err) => {
                    console.error(err)
                    res.status(500).json({ message: 'Please run again...', error: err }).end()
                  })
              })
          }
        })
      })
    } else {
      res
        .status(500)
        .json({ success: false, error: 'Not read file : ' + localfile })
        .end()
    }
  })
}

module.exports = router
