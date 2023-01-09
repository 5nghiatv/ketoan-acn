<template>
  <div>
    <h2>Bookstore</h2>
    <hr />
    <CRow v-if="updaterec">
      <!-- <FormCreateBook @CreateNewBook="CreateNewBook" :bookDetails="bookDetails" ref="callChild" /> -->
      <CCol sm="6">
        <CCard>
          <CCardHeader style="font-size: 25px"> Book &#8482; </CCardHeader>
          <CCardBody>
            <!-- <CForm @submit.prevent="submitForm"> -->
            <CForm>
              <CRow>
                <CCol col="6">
                  <CInputGroup class="mb-3">
                    <CInputGroupText>Name</CInputGroupText>
                    <CFormInput class="form-control" :class="{ 'is-valid': bookName }" v-model="bookName" />
                  </CInputGroup>
                  <CInputGroup class="mb-3">
                    <CInputGroupText>Genre</CInputGroupText>
                    <CFormInput class="form-control" :class="{ 'is-valid': bookGenre }" v-model="bookGenre" />
                  </CInputGroup>

                  <div v-if="listAuthors">
                    <CInputGroup class="mb-3">
                      <CButton type="button" color="secondary" variant="outline"> Author </CButton>
                      <CFormSelect
                        :value="bookAuthorId"
                        v-model="bookAuthorId"
                        :class="{ 'is-valid': bookAuthorId !== 'Select author' }"
                      >
                        <option value="Select author" key="Select author">Select author</option>
                        <option v-for="author in listAuthors" :key="author.id" :value="author.id">
                          {{ author.name }}
                        </option>
                      </CFormSelect>
                    </CInputGroup>
                  </div>
                </CCol>
              </CRow>
              <div class="form-group form-actions">
                <CButton
                  class="btn btn-info btn-sm"
                  @click="createTodo('book')"
                  :disabled="!bookName || !bookGenre || bookAuthorId == 'Select author' || !bookAuthorId"
                  id="addnew"
                >
                  Add New </CButton
                >&nbsp;&nbsp;
                <CButton
                  class="btn btn-info btn-sm"
                  @click="updateTodo('book')"
                  :disabled="!bookName || !bookGenre || bookAuthorId == 'Select author' || !bookAuthorId"
                  id="update"
                >
                  Update </CButton
                >&nbsp;&nbsp;
                <CButton class="btn btn-outline-info btn-sm" @click="restoreTodo('book')" id="restore">
                  >> Restore </CButton
                >&nbsp;&nbsp;
                <CButton
                  class="btn btn-outline-warning btn-sm"
                  @click="deleteTodo('book')"
                  :disabled="!bookName || !bookGenre || bookAuthorId == 'Select author' || !bookAuthorId"
                  id="delete"
                >
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
            <CForm>
              <CRow>
                <CCol col="6">
                  <CInputGroup class="mb-3">
                    <CInputGroupText>Name</CInputGroupText>
                    <CFormInput class="form-control" :class="{ 'is-valid': authorName }" v-model="authorName" />
                  </CInputGroup>
                  <CInputGroup class="mb-3">
                    <CInputGroupText>Age....</CInputGroupText>
                    <CFormInput
                      v-model="authorAge"
                      v-mask-decimal.br="0"
                      class="form-control"
                      :class="{ 'is-valid': authorAge && authorAge > 0 }"
                    />
                  </CInputGroup>
                  <CInputGroup class="mb-3">
                    <CInputGroupText>Birthplace</CInputGroupText>
                    <CFormInput
                      v-model="authorBirthplace"
                      class="form-control"
                      :class="{ 'is-valid': authorBirthplace }"
                    />
                  </CInputGroup>
                </CCol>
              </CRow>

              <div class="form-group form-actions">
                <CButton
                  class="btn btn-info btn-sm"
                  @click="createTodo('author')"
                  :disabled="!authorName || !authorAge || !authorBirthplace"
                  id="addnew"
                >
                  Add New </CButton
                >&nbsp;&nbsp;
                <CButton
                  class="btn btn-info btn-sm"
                  @click="updateTodo('author')"
                  :disabled="!authorName || !authorAge || !authorBirthplace"
                  id="update"
                >
                  Update </CButton
                >&nbsp;&nbsp;
                <CButton class="btn btn-outline-info btn-sm" @click="restoreTodo('author')" id="restore">
                  >> Restore </CButton
                >&nbsp;&nbsp;
                <CButton
                  class="btn btn-outline-warning btn-sm"
                  @click="deleteTodo('author')"
                  :disabled="!authorName || !authorAge || !authorBirthplace"
                  id="delete"
                >
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
            <CCardImage @click="getDetails(book.id)" v-if="stt % 8 == 0" orientation="top" :src="avatar1" />
            <CCardImage @click="getDetails(book.id)" v-if="stt % 8 == 1" orientation="top" :src="avatar2" />
            <CCardImage @click="getDetails(book.id)" v-if="stt % 8 == 2" orientation="top" :src="avatar3" />
            <CCardImage @click="getDetails(book.id)" v-if="stt % 8 == 3" orientation="top" :src="avatar4" />
            <CCardImage @click="getDetails(book.id)" v-if="stt % 8 == 4" orientation="top" :src="avatar5" />
            <CCardImage @click="getDetails(book.id)" v-if="stt % 8 == 5" orientation="top" :src="avatar6" />
            <CCardImage @click="getDetails(book.id)" v-if="stt % 8 == 6" orientation="top" :src="avatar7" />
            <CCardImage @click="getDetails(book.id)" v-if="stt % 8 == 7" orientation="top" :src="avatar8" />
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
            <p>Author: {{ bookDetails.book.author.name }}</p>
            <p>Age: {{ bookDetails.book.author.age }}</p>
            <p>Birthplace: {{ bookDetails.book.author.birthplace }}</p>
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
import avatar7 from '@/assets/images/avatars/7.jpg'
import avatar8 from '@/assets/images/avatars/8.jpg'
import VueImg from '@/assets/images/vue.jpg'

import { mapState } from 'vuex'
import { useQuery, useMutation } from '@vue/apollo-composable'
import { getBooks, getSingleBook, getAuthors } from './queries'
import { defineComponent, ref, computed } from 'vue'
import {
  updateSingleBook,
  addSingleBook,
  deleteSingleBook,
  updateSingleAuthor,
  addSingleAuthor,
  deleteSingleAuthor,
} from './mutations'
import getlistAuthors from './graphql-book'
export default defineComponent({
  name: 'Books',
  components: {},
  data() {
    return {
      updaterec: true,
      VueImg,
      avatar1,
      avatar2,
      avatar3,
      avatar4,
      avatar5,
      avatar6,
      avatar7,
      avatar8,
      googletheme: '',
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
  // setup(props, context: { attrs, slots, emit, expose })
  setup() {
    // let callChild = ref() // Dùng Tham chiếu Children
    let bookName = ref('')
    let bookGenre = ref('')
    let bookAuthorId = ref('Select author') // Phải Select author mới disabled
    let authorObject = ref([])
    let bookDetails = ref([])
    let authorName = ref('')
    let authorAge = ref('')
    let authorBirthplace = ref('')
    let bookObject = ref([])

    const { result, loading } = useQuery(getBooks)
    const listBooks = computed(() => result.value?.books ?? [])
    console.log('listBooks', listBooks)

    let { listAuthors } = getlistAuthors()
    console.log('listAuthors', listAuthors)

    // watch((listAuthors) => { console.log('listAuthors', listAuthors) })

    async function getDetails(bookId) {
      let src = ''
      window.onclick = (e) => {
        src = e.target.src
      }
      const { result, loading } = await useQuery(getSingleBook, { id: bookId })
      setTimeout(
        () => {
          bookDetails.value = bookId !== null && result && result.value !== 'undefined' ? result.value : null
          document.getElementById('imgDetails').src = src
          console.log('Change book details...', bookDetails.value)

          bookName.value = bookDetails.value.book.name
          bookGenre.value = bookDetails.value.book.genre
          bookAuthorId.value = bookDetails.value.book.author?.id
          authorName.value = bookDetails.value.book.author?.name
          authorAge.value = bookDetails.value.book.author?.age.toString()
          authorBirthplace.value = bookDetails.value.book.author?.birthplace
          // console.log( bookDetails.value.book.author)
        },
        loading ? 1500 : 0,
      )
    }

    //===========================
    const letsChoiceBook = () => {
      alert('YOU haven not clicked on a BOOK yet...')
    }

    function createTodo(opt) {
      if (!confirm(`PLEASE, Confirm you want to CREATE the ${opt} ?`)) {
        return
      }
      if (opt == 'book') CreateNewBook()
      else CreateNewAuthor()
    }

    function deleteTodo(opt) {
      if (!confirm(`PLEASE, Confirm you want to DELETE the ${opt} ?`)) {
        return
      }
      if (opt == 'book') deleteOldBook()
      else deleteOldAuthor()
    }

    //===========================
    function deleteOldBook() {
      try {
        bookObject = { id: bookDetails.value.book.id }
        const { mutate: deleteBook } = useMutation(deleteSingleBook, () => ({
          variables: bookObject,
          update(cache) {
            const normalizedId = cache.evict({
              id: cache.identify({ id: bookObject.id, __typename: 'Book' }),
            })
            cache.gc()
            console.log('normalizedId: ', normalizedId)
          },
        }))
        console.log('deleteBook => id', bookObject)
        deleteBook()
        restoreTodo('book')
      } catch (error) {
        return letsChoiceBook()
      }
    }

    //===========================
    function deleteOldAuthor() {
      try {
        bookObject = { id: bookDetails.value.book.author.id }
        const { mutate: deleteAuthor } = useMutation(deleteSingleAuthor, () => ({
          variables: bookObject,
          update(cache) {
            const normalizedId = cache.evict({
              id: cache.identify({ id: bookObject.id, __typename: 'Author' }),
            })
            cache.gc()
            console.log('normalizedId: ', normalizedId)
          },
        }))
        console.log('deleteAuthor => id', bookObject, bookDetails.value.book.author)
        deleteAuthor()
        restoreTodo('author')
        bookAuthorId.value = 'Select author'
      } catch (error) {
        return letsChoiceBook()
      }
    }

    //===========================
    function restoreTodo(opt) {
      if (opt == 'book') {
        bookName.value = ''
        bookGenre.value = ''
        bookAuthorId.value = 'Select author'
      } else {
        authorName.value = ''
        authorAge.value = 0
        authorBirthplace.value = ''
      }
    }

    //===========================
    function updateTodo(opt) {
      if (opt == 'book') updateOldBook()
      else updateOldAuthor()
    }

    //===========================
    function updateOldAuthor() {
      try {
        bookObject = {
          name: authorName.value,
          age: parseInt(authorAge.value),
          birthplace: authorBirthplace.value,
          id: bookDetails.value.book.author.id,
        }
        const { mutate: updateAuthor } = useMutation(updateSingleAuthor, () => ({
          variables: bookObject,
          update(cache) {
            const normalizedId = cache.evict({
              id: cache.identify({ id: bookObject.id, __typename: 'Author' }),
            })
            cache.gc()
            console.log('normalizedId: ', normalizedId)
          },
        }))
        console.log('updateAuthor', bookObject)
        updateAuthor()
      } catch (error) {
        return letsChoiceBook()
      }
    }
    //===========================
    function updateOldBook() {
      try {
        bookObject = {
          name: bookName.value,
          genre: bookGenre.value,
          authorId: bookAuthorId.value,
          id: bookDetails.value.book.id,
        }
        const { mutate: updateBook } = useMutation(updateSingleBook, () => ({
          variables: bookObject,
          update(cache) {
            const normalizedId = cache.evict({
              id: cache.identify({ id: bookObject.id, __typename: 'Book' }),
            })
            cache.gc()
            console.log('normalizedId: ', normalizedId)
          },
        }))
        console.log('updateBook', bookObject)
        updateBook()
      } catch (error) {
        return letsChoiceBook()
      }
    }

    //===========================
    function CreateNewBook(bookObj) {
      bookObject = {
        name: bookName.value,
        genre: bookGenre.value,
        authorId: bookAuthorId.value,
      }
      console.log('bookObj for Add', bookObject)
      createBook()
    } // Do formChild FormCreateBook.vue Call: @click="$emit('CreateNewBook', { })"

    // GraphQL operations
    const { mutate: createBook } = useMutation(addSingleBook, () => ({
      variables: bookObject,
      // variables: { name: bookObject.name, genre: bookObject.genre, authorId: bookObject.authorId },
      update: (cache, { data: { createBook } }) => {
        let data = cache.readQuery({ query: getBooks })
        data = {
          ...data,
          books: [...data.books, createBook],
        }
        cache.writeQuery({ query: getBooks, data })
      },
    }))

    //===========================
    function CreateNewAuthor() {
      authorObject = {
        name: authorName.value,
        age: parseInt(authorAge.value),
        birthplace: authorBirthplace.value,
      }
      console.log('authorObject for Add', authorObject)
      createAuthor()
    } // Do formChild FormCreateBook.vue Call: @click="$emit('CreateNewBook', { })"
    const { mutate: createAuthor } = useMutation(addSingleAuthor, () => ({
      // variables: { name: 'Trần Quang Minh', age: 100 },
      variables: authorObject,
      update: (cache, { data: { createAuthor } }) => {
        let data = cache.readQuery({ query: getAuthors })
        data = {
          ...data,
          authors: [...data.authors, createAuthor],
        }
        cache.writeQuery({ query: getAuthors, data })
      },
    }))
    // watch(() => {
    //   console.log('watch','authorName.value =>', authorName.value)
    // })
    return {
      bookName,
      bookGenre,
      bookAuthorId,
      authorName,
      authorAge,
      authorBirthplace,
      listBooks,
      listAuthors,
      loading,
      bookDetails,
      getDetails,
      createTodo,
      updateTodo,
      restoreTodo,
      deleteTodo,
    }
  },
  methods: {},
})
</script>
<style scoped>
.flex-container {
  display: flex;
  flex-wrap: wrap;
  box-sizing: content-box;
}
.card-title {
  font-size: 1.1rem;
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

<!-- attrs và slot là các đối tượng trạng thái luôn được cập nhật khi chính thành phần đó được cập nhật. 
Điều này có nghĩa là bạn nên tránh phá hủy chúng và luôn tham chiếu các thuộc tính 
dưới dạng attrs.x hoặc slots.x. Cũng lưu ý rằng, không giống như props, 
các thuộc tính của attrs và slot không phản ứng. Nếu bạn có ý định áp dụng các tác dụng phụ dựa trên 
các thay đổi đối với attrs hoặc vị trí, thì bạn nên thực hiện điều đó bên trong hook vòng đời onB BeforeUpdate. 
Exposure là một chức năng có thể được sử dụng để giới hạn rõ ràng các thuộc tính được hiển thị khi phiên bản 
thành phần được truy cập bởi một thành phần cha mẹ thông qua các tham chiếu mẫu:
-->
