curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer abc15121961" --data '{ "query": "{ hello }" }' http://localhost:8081/graphql
{ "Authorization": "Bearer abc15121961" }

query {
  login(email: "nghiatv@gmail.com", password: "111111"){
    token
    userId
  }
}

query {
  hello(name: "Trần Văn Nghĩa")
}

HTTP HEADERS
{ "Authorization": "Bear eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2MjExZjNjZmM5ODNkOTFmZGMzMjA2NmEiLCJ1c2VyIjp7Il9pZCI6IjYyMTFmM2NmYzk4M2Q5MWZkYzMyMDY2YSIsInVzZXJuYW1lIjoiVHLhuqduIFbEg24gTmdoxKlhIiwicm9sZSI6IkFkbWluIiwic3RhdHVzIjoiUGVuZGluZyIsImFkbWluIjp0cnVlLCJkYXRhYmFzZXMiOlsia2V0b2FuX3h1YW5tYWkiLCJrZXRvYW5fbmhhdG5hbSIsIm5naGlhdHZfa2V0b2FuIiwibmdoaWF0dl9raW5nbWluaCIsImtldG9hbl91cGxvYWQiLCJrZXRvYW5fYWNuIl0sInNvY2lhbElkIjoiIiwiaW1hZ2UiOiIiLCJuYW1lIjoiTmdoacyDYSIsImVtYWlsIjoibmdoaWF0dkBnbWFpbC5jb20iLCJwYXNzd29yZCI6IiQyYSQxMCRhLkxnd1hidFhGSHhSOWtnUzM0RXVlNHZ5NENGUlBYLlpudVYxdURJNzZkZ3dGWHZPMXkvUyIsInJlZ2lzdGVyZWQiOiIyMDIyLTAyLTE2VDEwOjQ3OjE2LjAwMFoifSwiaWF0IjoxNjczMDkxMzEwLCJleHAiOjE2NzMzOTEzMTB9.5HjJSDFR1Cpff0FS1PQuQQwfuwU_YAT4c5kQ3ypXyIM"
}

mutation {
  createBook (
name: "Tiếng Anh Vở lòng",
genre: "Thiếu nhi",
authorId: "63a12e388b1c1b1c27aa215f"  
  ) {
    id
    name
    genre
  }
}# Write your query or mutation here

mutation {
  deleteBook (
    id: "63ba34fe64f374e9fbb93e5a",
  ) {
    id
    name
  }
}# Write your query or mutation here

mutation {
  createAuthor (
name: "Trần Mai Thảo 2222",
age: 24,
  ) {
    id
    name
    age
  }
}# Write your query or mutation here

mutation {
  deleteAuthor (
    id: "63ba333864f374e9fbb93d7e",
  ) {
    id
    name
    age
  }
}# Write your query or mutation here

query {
  authors {
    id
    name
    age
    books {
      id
      name
    }
  }	
}  

query {
  books {
		id
		name
		genre
		author {
			id
			name
			age
			books {
				id
				name
			}
		}	
  }  
}

query {
	login(email: "nghiatv@gmail.com", password: "111111") {
    token
    userId
  }
}
