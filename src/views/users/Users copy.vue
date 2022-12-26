<template>
  <!-- <ApolloProvider client={client}>
			<Container className='py-3 mt-3' style={{ backgroundColor: 'lightcyan' }}>
				<h1 className='text-center text-info mb-3'>My Books</h1>
				<hr />
				<Forms />
				<hr />
				<BookList />
			</Container>
		</ApolloProvider> -->

  <!-- Forms -->
  <!-- <Row>
			<Col>
				<BookForm />
			</Col>
			<Col>
				<AuthorForm />
			</Col>
		</Row> -->
  <!-- BookList -->
  <!-- <Row>
			<Col xs={8}>
				<CardColumns>
					{data.books.map(book => (
						<Card
							border='info'
							text='info'
							className='text-center shadow'
							key={book.id}
							onClick={setBookSelected.bind(this, book.id)}
							style={{ cursor: 'pointer' }}
						>
							<Card.Body>{book.name}</Card.Body>
						</Card>
					))}
				</CardColumns>
			</Col>
			<Col>
				<BookDetails bookId={bookSelected} />
			</Col>
		</Row> -->

  <div>
    <h1>My Books</h1>
    <div>
      <button @click="sendMessage({ text: 'Hello' })">Send message</button>
    </div>
    <hr />
    <CRow v-if="updaterec">
      <CCol sm="6">
        <CCard>
          <CCardHeader style="font-size: 25px"> Book &#8482; </CCardHeader>
          <CCardBody>
            <CForm @submit.prevent="submitForm">
              <CRow>
                <CCol col="6">
                  <CInputGroup class="mb-3">
                    <CInputGroupText>Name</CInputGroupText>
                    <CFormInput
                      class="form-control"
                      :class="{ 'is-valid': testValidator('bookname') }"
                      v-model="todo.bookname"
                    />
                  </CInputGroup>
                  <CInputGroup class="mb-3">
                    <CInputGroupText>Genre</CInputGroupText>
                    <CFormInput
                      class="form-control"
                      :class="{ 'is-valid': testValidator('genre') }"
                      v-model="todo.genre"
                    />
                  </CInputGroup>

                  <FormListAuthor />
                </CCol>
              </CRow>

              <div class="form-group form-actions">
                <CButton
                  class="btn btn-info btn-sm"
                  @click="createTodo('book')"
                  :disabled="!Validator.bookname || !Validator.genre"
                  id="addnew"
                >
                  Add New </CButton
                >&nbsp;&nbsp;
                <CButton
                  class="btn btn-info btn-sm"
                  @click="updateTodo('book')"
                  :disabled="!todo.id || !isValid"
                  id="update"
                >
                  Update </CButton
                >&nbsp;&nbsp;
                <CButton class="btn btn-outline-info btn-sm" @click="restore('book')" id="restore">
                  >> Restore </CButton
                >&nbsp;&nbsp;
                <CButton class="btn btn-outline-warning btn-sm" @click="deletebook('book')" id="close">
                  >> Delete
                </CButton>
              </div>
            </CForm>
          </CCardBody>
        </CCard>
      </CCol>

      <CCol sm="6">
        <CCard>
          <CCardHeader style="font-size: 25px"> Author &#8482; </CCardHeader>
          <CCardBody>
            <CForm @submit.prevent="submitForm">
              <CRow>
                <CCol col="6">
                  <CInputGroup class="mb-3">
                    <CInputGroupText>Name</CInputGroupText>
                    <CFormInput
                      class="form-control"
                      :class="{ 'is-valid': testValidator('authorname') }"
                      v-model="todo.authorname"
                    />
                  </CInputGroup>
                  <CInputGroup class="mb-3">
                    <CInputGroupText>Age...</CInputGroupText>
                    <CFormInput
                      v-model="todo.age"
                      v-mask-decimal.br="0"
                      type="number"
                      class="form-control"
                      :class="{ 'is-valid': testValidator('age') }"
                    />
                  </CInputGroup>
                  <CInputGroup class="mb-3">
                    <CInputGroupText>Birthplace</CInputGroupText>
                    <CFormInput
                      v-model="todo.birthplace"
                      class="form-control"
                      :class="{ 'is-valid': testValidator('birthplace') }"
                    />
                  </CInputGroup>
                </CCol>
              </CRow>

              <div class="form-group form-actions">
                <CButton
                  class="btn btn-info btn-sm"
                  @click="createTodo('author')"
                  :disabled="!Validator.authorname || !Validator.age || !Validator.birthplace"
                  id="addnew"
                >
                  Add New </CButton
                >&nbsp;&nbsp;
                <CButton
                  class="btn btn-info btn-sm"
                  @click="updateTodo('author')"
                  :disabled="!todo.id || !isValid"
                  id="update"
                >
                  Update </CButton
                >&nbsp;&nbsp;
                <CButton class="btn btn-outline-info btn-sm" @click="restore('author')" id="restore">
                  >> Restore </CButton
                >&nbsp;&nbsp;
                <CButton class="btn btn-outline-warning btn-sm" @click="deletebook('author')" id="close">
                  >> Delete
                </CButton>
              </div>
            </CForm>
          </CCardBody>
        </CCard>
      </CCol>
    </CRow>

    <hr />
    <CRow>
      <CCol :xs="9" class="flex-container">
        <p v-if="loading">Loading...</p>
        <div v-else v-for="(book, stt) in listBooks" :key="book.id">
          <CCard style="width: 15rem; padding: 5px">
            <CCardImage @click="getDetails(book.id)" v-if="stt % 6 == 0" orientation="top" :src="avatar1" />
            <CCardImage @click="getDetails(book.id)" v-if="stt % 6 == 1" orientation="top" :src="avatar2" />
            <CCardImage @click="getDetails(book.id)" v-if="stt % 6 == 2" orientation="top" :src="avatar3" />
            <CCardImage @click="getDetails(book.id)" v-if="stt % 6 == 3" orientation="top" :src="avatar4" />
            <CCardImage @click="getDetails(book.id)" v-if="stt % 6 == 4" orientation="top" :src="avatar5" />
            <CCardImage @click="getDetails(book.id)" v-if="stt % 6 == 5" orientation="top" :src="avatar6" />
            <CCardBody>
              <CCardTitle>{{ book.name }}</CCardTitle>
              <CCardText>
                {{ book.genre }}
              </CCardText>
              <!-- <CButton @click="getDetails(book.id)">Details</CButton> -->
            </CCardBody>
          </CCard>
        </div>
      </CCol>
      <CCol class="flex-container">
        <CCard style="width: 15rem; padding: 5px">
          <CCardImage id="imgDetails" ref="imgDetails" orientation="top" :src="VueImg" />
          <CCardBody v-if="bookDetails && bookDetails.book">
            <CCardTitle>{{ bookDetails.book.name }}</CCardTitle>
            <CCardText> {{ bookDetails.book.genre }}</CCardText>
            <p>{{ bookDetails.book.author.name }}</p>
            <p>Age: {{ bookDetails.book.author.age }}</p>
            <p>All books by this author</p>
            <ul v-for="book in bookDetails.book.author.books" :key="book.id" style="font-style: italic">
              <li key="{{book.id}}">{{ book.name }}</li>
            </ul>
          </CCardBody>
          <p v-else style="padding: 1rem">Select book to Preview</p>
        </CCard>
      </CCol>
    </CRow>
    <br />
  </div>
</template>

<script>
/* eslint-disable */
import avatar1 from '@/assets/images/avatars/1.jpg'
import avatar2 from '@/assets/images/avatars/2.jpg'
import avatar3 from '@/assets/images/avatars/3.jpg'
import avatar4 from '@/assets/images/avatars/4.jpg'
import avatar5 from '@/assets/images/avatars/5.jpg'
import avatar6 from '@/assets/images/avatars/6.jpg'
import VueImg from '@/assets/images/vue.jpg'

import FormListAuthor from './FormListAuthor.vue'
import { mapState } from 'vuex'
import { useQuery, useMutation } from '@vue/apollo-composable'
import { getBooks, getSingleBook } from '@/graphql-client/queries'
import { ref, watch, computed } from 'vue'
import { addSingleAuthor, sendMessage } from '@/graphql-client/mutations'

export default {
  name: 'Books',
  components: {
    FormListAuthor,
  },
  data() {
    return {
      updaterec: true,
      Validator: {
        bookname: false,
        genre: false,
        authorname: false,
        age: 0,
        birthplace: false,
      },

      todo: {
        id: '',
        bookname: '',
        genre: '',
        authorname: '',
        age: 0,
        birthplace: '',
      },

      VueImg,
      avatar1,
      avatar2,
      avatar3,
      avatar4,
      avatar5,
      avatar6,
      // googletheme: '',
    }
  },
  computed: {
    ...mapState(['theme']),
  },
  watch: {
    theme() {
      this.googletheme = this.theme === 'default' ? '' : 'nocturnal'
    },
  },

  setup() {
    const { mutate: sendMessage } = useMutation(sendMessage)
    let bookDetails = ref([])
    const { result, loading } = useQuery(getBooks)
    const listBooks = computed(() => result.value?.books ?? [])
    // setTimeout(() => {
    //   // console.log('authors==>', listAuthors)
    // }, 800)

    // console.log('authors==>', authors)

    async function getDetails(bookId) {
      let src = ''
      window.onclick = (e) => {
        src = e.target.src
      }
      console.log('bookId', bookId)
      const { result, loading } = await useQuery(getSingleBook, { id: bookId })
      setTimeout(
        () => {
          console.log('Loading book details...')
          bookDetails.value = bookId !== null && result && result.value !== 'undefined' ? result.value : null
          document.getElementById('imgDetails').src = src
        },
        loading ? 800 : 0,
      )
    }

    watch(bookDetails, (currentValue) => {
      console.log('bookDetails.value =>', currentValue, bookDetails.value)
    })

    return {
      listBooks,
      loading,
      bookDetails,
      getDetails,
      sendMessage,
    }
  },
  methods: {
    submitForm() {},
    createTodo(opt) {
      alert('createTodo ' + opt)
      console.log(111, opt, this.todo)
      // addAuthor({
      //   variables: { name: this.todo.authorname, age: this.todo.age },
      //   refetchQueries: [{ query: getAuthors }],
      // })
      // // GraphQL operations
      // const [addAuthor, dataMutation] = useMutation(addSingleAuthor)
      // // console.log(dataMutation)
      // // Tránh Error
      // if (!dataMutation) return console.log(dataMutation)
    },
    updateTodo(opt) {
      alert('updateTodo: ' + opt)
    },
    deletebook(opt) {
      alert('deletebook: ' + opt)
    },
    restore(opt) {
      this.todo = {
        id: '',
        bookname: '',
        genre: '',
        authorname: '',
        age: 0,
        birthplace: '',
      }
    },
    testValidator(field) {
      if (field == 'bookname') return (this.Validator.bookname = this.todo.bookname != '')
      if (field == 'genre') return (this.Validator.genre = this.todo.genre != '')
      if (field == 'authorname') return (this.Validator.authorname = this.todo.authorname != '')
      if (field == 'birthplace') return (this.Validator.birthplace = this.todo.birthplace != '')
      if (field == 'age') return (this.Validator.age = this.todo.age > 0)

      let passe =
        this.Validator.bookname &&
        this.Validator.genre &&
        this.Validator.authorname &&
        this.Validator.birthplace &&
        this.Validator.age
      if (!passe) {
        this.$toastr.warning('', 'Vui lòng nhập đầy đủ thông tin.')
      }
      return passe
    },
  },
}
</script>
<style scoped>
.flex-container {
  display: flex;
  flex-wrap: wrap;
  box-sizing: content-box;
}

.App-header {
  background-color: #282c34;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: calc(10px + 2vmin);
  color: white;
}

.card-img-top {
  cursor: pointer;
}
.App-link {
  color: #61dafb;
}

@keyframes App-logo-spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
