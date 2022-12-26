<template>
  <CCol sm="6">
    <CCard>
      <CCardHeader style="font-size: 25px"> Book &#8482; </CCardHeader>
      <CCardBody>
        <CForm @submit.prevent="submitForm">
          <CRow>
            <CCol col="6">
              <CInputGroup class="mb-3">
                <CInputGroupText>Name</CInputGroupText>
                <CFormInput class="form-control" :class="{ 'is-valid': bookName !== '' }" v-model="bookName" />
              </CInputGroup>
              <CInputGroup class="mb-3">
                <CInputGroupText>Genre</CInputGroupText>
                <CFormInput class="form-control" :class="{ 'is-valid': bookGenre !== '' }" v-model="bookGenre" />
              </CInputGroup>

              <!-- <FormListAuthor v-model="bookAuthorId" /> -->
              <div v-if="listAuthors && listAuthors.authors">
                <CInputGroup class="mb-3">
                  <CButton type="button" color="secondary" variant="outline"> Author </CButton>
                  <CFormSelect v-model="bookAuthorId" :class="{ 'is-valid': bookAuthorId !== 'Select author' }">
                    <option value="Select author">Select author</option>
                    <option v-for="author in listAuthors.authors" :key="author.id" :value="author.id">
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
              @click="
                $emit('CreateNewBook', {
                  name: bookName,
                  genre: bookGenre,
                  authorId: bookAuthorId,
                })
              "
              :disabled="!bookName || !bookGenre || bookAuthorId == 'Select author'"
              id="addnew"
            >
              Add New </CButton
            >&nbsp;&nbsp;
            <CButton
              class="btn btn-info btn-sm"
              @click="updateBook()"
              :disabled="!bookName || !bookGenre || bookAuthorId == 'Select author' || !bookAuthorId"
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
</template>

<script>
/* eslint-disable */

import { useQuery, useMutation } from '@vue/apollo-composable'
import { getAuthors } from '@/graphql-client/queries'
import { addSingleAuthor } from '@/graphql-client/mutations'
import { ref, watch, computed, defineComponent, defineExpose } from 'vue'

export default defineComponent({
  name: 'FormCreateBook',
  components: {},
  data() {
    return {}
  },
  setup() {
    let listAuthors = ref([])
    let authorObject = ref()
    let bookName = ref('Kế toán Doanh nghiệp')
    let bookGenre = ref('Development')
    let bookAuthorId = ref('Select author') // Phải Select author mới disabled

    const { result, loading, error } = useQuery(getAuthors)
    listAuthors = result

    // listAuthors = computed(() => result)
    // if (loading) console.log('loading...')
    // if (error) console.log('Error getAuthors...', error)
    // setTimeout(() => {
    //   console.log('authors==>', listAuthors)
    // }, 800)
    // watch(listAuthors, (currentValue) => {
    //   console.log('listAuthors.value =>', currentValue, listAuthors.value)
    // })

    function CreateNewAuthor(authorObj) {
      authorObject = authorObj
      console.log('authorObject', authorObject)
      createAuthor()
    } // Do formChild FormCreateBook.vue Call: @click="$emit('CreateNewBook', { })"
    defineExpose({ CreateNewAuthor }) // SHOW functiopn for Parrent-Call

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

    return {
      listAuthors,
      // createBook,
      bookAuthorId,
      bookName,
      bookGenre,
      CreateNewAuthor,
      createAuthor,
      authorObject,
    }
  },
  methods: {},
  mounted() {},
})
</script>

<style scoped></style>
