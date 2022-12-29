const Book = require('../models/Book')
const Author = require('../models/Author')
// const { modelName } = require('../models/Author')

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
}

module.exports = mongoDataMethods
