const { gql } = require('apollo-server-express')

const typeDefs = gql`
  type Book {
    id: ID
    name: String
    genre: String
    author: Author
  }

  type Author {
    id: ID!
    name: String
    age: Int
    birthplace: String
    books: [Book]
  }

  # ROOT TYPE
  type Query {
    hello(name: String): String!
    books: [Book]
    book(id: ID!): Book
    authors: [Author]
    author(id: ID!): Author
  }

  type Mutation {
    createAuthor(name: String, age: Int, birthplace: String): Author
    updateAuthor(id: ID!, name: String, age: Int, birthplace: String): Author
    deleteAuthor(id: ID!): Author
    createBook(name: String, genre: String, authorId: ID!): Book
    updateBook(id: ID!, name: String, genre: String, authorId: ID!): Book
    deleteBook(id: ID!): Book
  }
`

module.exports = typeDefs
