require('dotenv').config()
const Book = require('../models/Book')
const Author = require('../models/Author')
const { User } = require('../../models/User.js')
const jwt = require('jsonwebtoken')
const bcrypt = require('bcryptjs')

const mongoDataMethods = {
  getAllBooks: async (condition = null) => (condition === null ? await Book.find() : await Book.find(condition)),
  getBookById: async (id) => await Book.findById(id),
  getAllAuthors: async () => await Author.find(),
  getAuthorById: async (id) => await Author.findById(id),
  createAuthor: async (args) => {
    const newAuthor = new Author(args)
    return await newAuthor.save()
  },
  updateAuthor: async (args) => {
    return await Author.findByIdAndUpdate(args.id, { $set: args })
  },
  deleteAuthor: async (args) => {
    return await Author.findByIdAndDelete(args.id)
  },
  createBook: async (args) => {
    const newBook = new Book(args)
    return await newBook.save()
  },
  updateBook: async (args) => {
    return await Book.findByIdAndUpdate(args.id, { $set: args })
  },
  deleteBook: async (args) => {
    return await Book.findByIdAndDelete(args.id)
  },
  login: async ({ email, password }) => {
    try {
      const user = await User.findOne({ email })
      // console.log(111,'User logined', user)

      if (!user) {
        throw new Error('Invalid Credentials!user')
      }
      const isCorrectPassword = await bcrypt.compare(password, user.password)
      if (!isCorrectPassword) {
        throw new Error('Invalid Credentials!password')
      }

      const expire = `${process.env.TOKENLIFE}`
      const token = jwt.sign({ _id: user._id, isAdmin: user.isAdmin, user: user }, process.env.PRIVATE_KEY, {
        expiresIn: expire,
      })
      // const token = user.password
      return {
        token,
        userId: user._id,
      }
    } catch (error) {
      return error
    }
  },
}

const showError = () => {
  throw new Error('Invalid Credentials!user. Please login then try again...')
}

const resolvers = {
  // QUERY
  Query: {
    hello: (_, args) => {
      // console.log(111, 'context.isAuth', context)
      return `Hello Apollo: ${args.name}`
    },
    login: async (parent, args) => await mongoDataMethods.login(args),

    books: async (parent, args, context) => {
      return context.isAuth ? await mongoDataMethods.getAllBooks() : showError()
    },
    book: async (parent, { id }) => await mongoDataMethods.getBookById(id),

    authors: async (parent, args, context) => {
      return context.isAuth ? await mongoDataMethods.getAllAuthors() : showError()
    },
    author: async (parent, { id }) => await mongoDataMethods.getAuthorById(id),
  },

  Book: {
    author: async ({ authorId }, args) => await mongoDataMethods.getAuthorById(authorId),
  },

  Author: {
    books: async ({ id }, args) => await mongoDataMethods.getAllBooks({ authorId: id }),
  },

  // MUTATION
  Mutation: {
    createAuthor: async (parent, args, context) => {
      return context.isAuth ? await mongoDataMethods.createAuthor(args) : showError()
    },
    updateAuthor: async (parent, args, context) => {
      return context.isAuth ? await mongoDataMethods.updateAuthor(args) : showError()
    },
    deleteAuthor: async (parent, args, context) => {
      return context.isAuth ? await mongoDataMethods.deleteAuthor(args) : showError()
    },
    createBook: async (parent, args, context) => {
      return context.isAuth ? await mongoDataMethods.createBook(args) : showError()
    },
    updateBook: async (parent, args, context) => {
      return context.isAuth ? await mongoDataMethods.updateBook(args) : showError()
    },
    deleteBook: async (parent, args, context) => {
      return context.isAuth ? await mongoDataMethods.deleteBook(args) : showError()
    },
  },
}

module.exports = resolvers
