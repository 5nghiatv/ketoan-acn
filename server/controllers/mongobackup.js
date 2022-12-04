const dotenv = require('dotenv').config()
const fs = require('fs')
const JSZip = require('jszip')
const tmp = require('tmp')
const { MongoClient, ObjectId } = require('mongodb')
const waitFor = (ms) => new Promise((r) => setTimeout(r, ms))
var request = require('request')

exports.mongobackup = async function (req, res) {
  // process.env.MONGODB_URL_KETOAN || process.env.MONGODB_URL_LOCAL
  if (req.params.func == 'export') {
    exportMongoDb('ketoan', process.env.MONGODB_URL_KETOAN, res)
  } else {
    if (req.params.func == 'importlocal')
      importMongoDb('ketoan', process.env.MONGODB_URL_LOCAL, res)
    else importMongoDb('ketoan', process.env.MONGODB_URL_KETOAN, res)
    // downFromDropbox('ketoan-mongodb.zip')
  }
}

//=================================
async function waitForFileExists(filePath, currentTime = 0, timeout = 5000) {
  if (fs.existsSync(filePath)) return true
  if (currentTime === timeout) return false
  // wait for 1 second
  await new Promise((resolve, reject) => setTimeout(() => resolve(true), 1000))
  // waited for 1second
  return waitForFileExists(filePath, currentTime + 1000, timeout)
}

//=================================
function clientMongoClose(client, err, mess, res) {
  client.close()
  if (mess) console.log(mess)
  if (err == 'success') return res.status(200).json({ success: mess })
  if (err) throw err
}

//=================================
function exportMongoDb(dbName, uri, res) {
  const client = new MongoClient(uri, {
    useUnifiedTopology: true,
  })

  client.connect(function (err) {
    //assert.equal(null, err);
    if (err)
      return clientMongoClose(client, err, 'Lỗi hệ thống...Connect(1)', res)
    const db = client.db(dbName)
    db.listCollections().toArray(async function (err, collections) {
      if (err)
        return clientMongoClose(
          client,
          err,
          'Lỗi hệ thống...get Collection(2)',
          res,
        )
      let colls = []
      await collections.forEach((item) => {
        colls.push(item.name)
      })

      if (colls.length == 0)
        return clientMongoClose(
          client,
          err,
          'Database ' + dbName + ' không có dữ liệu...',
          res,
        )
      var zip = new JSZip()
      let localfile = 'server/backup/' + dbName + '.zip'
      for (let index = 0; index < colls.length; index++) {
        const query = {} // this is your query criteria
        let coll = colls[index]
        await db
          .collection(coll)
          .find(query)
          .toArray(async function (err, docs) {
            if (err)
              return clientMongoClose(
                client,
                err,
                'Lỗi hệ thống...Get Data(3)',
                res,
              )
            await zip.file(coll + '.json', JSON.stringify(docs))
            console.log(index + 1, coll)

            if (index == colls.length - 1) {
              // await zip
              //   .generateNodeStream({
              //     type: 'nodebuffer',
              //     streamFiles: true,
              //     compression: 'DEFLATE',
              //   })
              //   .pipe(fs.createWriteStream(localfile))
              //   .on('finish', function () {
              //     console.log(localfile + ' written.')
              //   })
              upToDropbox(zip, dbName + '-mongodb.zip')

              if (index == colls.length - 1)
                clientMongoClose(
                  client,
                  'success',
                  'Thành công => tổng số collection export ' + colls.length,
                  res,
                )
              else
                clientMongoClose(
                  client,
                  err,
                  'Tổng số collection export : ' + colls.length,
                  res,
                )
            }
          })
        await waitForFileExists(localfile)
      }
    })
  })
}

//=================================
async function importMongoDb(dbName, uri, res) {
  let localfile = 'server/backup/' + dbName + '.zip'
  const client = new MongoClient(uri, {
    useUnifiedTopology: true,
  })
  //=========> When Down from dropbox
  localfile = tmp.tmpNameSync() + '_' + dbName + '-mongodb.zip'
  await downFromDropbox(dbName + '-mongodb.zip', localfile)
  await waitForFileExists(localfile)
  if (!fs.existsSync(localfile))
    return clientMongoClose(
      client,
      true,
      'Không tìm thấy file : ' + localfile,
      res,
    )
  //=================================

  fs.readFile(localfile, function (err, data) {
    if (err)
      return clientMongoClose(client, err, 'Lỗi hệ thống...read file (1)', res)
    var zip = new JSZip()
    zip.loadAsync(data).then(async function (fzip) {
      client.connect(async function (err) {
        if (err)
          return clientMongoClose(
            client,
            err,
            'Lỗi hệ thống...Load data (2)',
            res,
          )
        let countFile = 0
        await fzip.forEach(function (relPath, file) {
          countFile++
        })
        if (countFile == 0)
          clientMongoClose(
            client,
            err,
            'Không tìm thấy file json trong ZIP...',
            res,
          )
        fzip.forEach(async function (relPath, file) {
          zip
            .file(file.name)
            .async('string')
            .then(async function (data) {
              const db = client.db(dbName)
              let collectName = file.name.replace('.json', '')
              try {
                await db.collection(collectName).drop()
              } catch (error) {}
              // const data = fs.readFileSync(localfile)
              let docs = JSON.parse(data)
              for (i in docs) {
                // delete docs[i]._id
                docs[i]._id = ObjectId(docs[i]._id)
                if (docs[i].files_id !== undefined)
                  docs[i].files_id = ObjectId(docs[i].files_id)
                if (docs[i].registered !== undefined)
                  docs[i].registered = new Date(docs[i].registered)
                if (docs[i].birthdate !== undefined)
                  docs[i].birthdate = new Date(docs[i].birthdate)
                if (docs[i].uploadDate !== undefined)
                  docs[i].uploadDate = new Date(docs[i].uploadDate)
                if (docs[i].createdAt !== undefined)
                  docs[i].createdAt = new Date(docs[i].createdAt)
                if (docs[i].dofbirth !== undefined)
                  docs[i].dofbirth = new Date(docs[i].dofbirth)
              }
              // console.log(docs)
              db.collection(collectName).insertMany(
                docs,
                function (err, result) {
                  if (err)
                    return clientMongoClose(
                      client,
                      err,
                      'Lỗi hệ thống...Insert data (3)',
                      res,
                    )
                  console.log(
                    countFile,
                    '==> Inserted ' + collectName,
                    result.insertedCount,
                    'Rows',
                  )
                  countFile--
                  if (countFile == 0) {
                    if (!fs.existsSync(localfile)) fs.unlinkSync(localfile)
                    return clientMongoClose(
                      client,
                      'success',
                      '= ==> Insert completed...',
                      res,
                    )
                  }
                },
              )
            })
          await waitFor(
            Math.max(data.length / 5000 < 5000 ? 5000 : data.length / 5000),
          )
        })
      })
    })
  })
}

//========================================
function upToDropbox(zip, filename) {
  console.log('Begin save to Dropbox...')
  var tokenDropbox = process.env.DROPBOX_TOKEN
  zip
    .generateAsync({ type: 'nodebuffer', compression: 'DEFLATE' }) // compression: 'DEFLATE'  LÀ  ZIP
    .then(function (buffer) {
      var options = {
        method: 'POST',
        url: 'https://content.dropboxapi.com/2/files/upload',
        headers: {
          'Content-Type': 'application/octet-stream',
          Authorization: 'Bearer ' + tokenDropbox,
          'Dropbox-API-Arg':
            '{"path": "/' +
            filename +
            '","mode": "overwrite","autorename": true,"mute": false}',
        },
        body: buffer,
      }

      request(options, function (err, body) {
        console.log('Save to Dropbox : ' + (err ? 'ERROR...' : 'thành công '))
      })
    })
    .catch((err) => {
      throw err
    })
}
//==================================================
function downFromDropbox(filename, tmpfile) {
  var tokenDropbox = process.env.DROPBOX_TOKEN
  var options = {
    method: 'POST',
    url: 'https://content.dropboxapi.com/2/files/download',
    encoding: null, // <====---------- FILE ZIP PHẢI CÓ
    headers: {
      'Content-Type': 'application/octet-stream',
      Authorization: 'Bearer ' + tokenDropbox,
      'Dropbox-API-Arg': '{"path": "/' + filename + '"}',
    },
  }
  request(options, function (err, res2, body) {
    if (err) throw err
    fs.writeFileSync(tmpfile, body, 'utf8')
    console.log('Download compled : ' + tmpfile)
  })
}
//==================================================
