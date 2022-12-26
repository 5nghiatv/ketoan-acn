// import { gql } from '@apollo/client'
import gql from 'graphql-tag'

const getBooks = gql`
  query getBooksQuery {
    books {
      name
      genre
      id
    }
  }
`

const getSingleBook = gql`
  query getSingleBookQuery($id: ID!) {
    book(id: $id) {
      id
      name
      genre
      author {
        id
        name
        age
        birthplace
        books {
          id
          name
        }
      }
    }
  }
`

const getAuthors = gql`
  query getAuthorsQuery {
    authors {
      id
      name
      birthplace
    }
  }
`

export { getBooks, getSingleBook, getAuthors }
