// import { gql } from '@apollo/client'
import gql from 'graphql-tag'

const addSingleBook = gql`
  mutation addSingleBookMutation($name: String, $genre: String, $authorId: ID!) {
    createBook(name: $name, genre: $genre, authorId: $authorId) {
      id
      name
    }
  }
`

const addSingleAuthor = gql`
  mutation addSingleAuthorMutation($name: String, $age: Int, $birthplace: String) {
    createAuthor(name: $name, age: $age, birthplace: $birthplace) {
      id
      name
    }
  }
`
const updateSingleAuthor = gql`
  mutation updateSingleAuthorMutation($id: ID!, $name: String, $age: Int, $birthplace: String) {
    updateAuthor(id: $id, name: $name, age: $age, birthplace: $birthplace) {
      id
      name
    }
  }
`
const deleteSingleAuthor = gql`
  mutation deleteSingleAuthorMutation($id: ID!) {
    deleteAuthor(id: $id) {
      id
      name
    }
  }
`

const updateSingleBook = gql`
  mutation updateSingleBookMutation($name: String, $genre: String, $authorId: ID!, $id: ID!) {
    updateBook(name: $name, genre: $genre, authorId: $authorId, id: $id) {
      id
      name
    }
  }
`

const deleteSingleBook = gql`
  mutation deleteSingleBookMutation($id: ID!) {
    deleteBook(id: $id) {
      id
      name
    }
  }
`

export {
  updateSingleBook,
  addSingleBook,
  deleteSingleBook,
  updateSingleAuthor,
  addSingleAuthor,
  deleteSingleAuthor,
}
