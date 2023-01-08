require('dotenv').config()
const jwt = require('jsonwebtoken')
const { User } = require('../models/User.js')

async function verifyToken(req) {
  // exports.verifyToken = async (req, res, next) => {
  // exports.verifyToken = async (req) => {
  let token = req.get('Authorization')
  if (!token) {
    req.isAuth = false
    return
  }
  token = token.split(' ')[1]

  let verify
  try {
    verify = jwt.verify(token, process.env.PRIVATE_KEY)
  } catch (error) {
    req.isAuth = false
    return
  }

  if (!verify._id) {
    req.isAuth = false
    return
  }

  const user = await User.findById(verify._id)
  // console.log(999, user, verify._id)

  if (!user) {
    req.isAuth = false
    return
  }
  // req.userId = user._id
  req.isAuth = { userId: user._id.toString(), username: user.username, email: user.email, admin: user.admin }
  // console.log(111, 'Run verifyToken set: req.isAuth - req.userId', req.isAuth, req.userId)
}

module.exports = verifyToken
