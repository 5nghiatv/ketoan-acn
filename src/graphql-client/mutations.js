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

const sendMessage = gql`
  mutation sendMessage($text: String!) {
    sendMessage(text: $text) {
      id
    }
  }
`

export { addSingleBook, addSingleAuthor, sendMessage }
