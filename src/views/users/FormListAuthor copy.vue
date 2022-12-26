<template>
  <div v-if="listAuthors && listAuthors.authors">
    <CInputGroup class="mb-3">
      <CButton type="button" color="secondary" variant="outline"> Author </CButton>
      <CFormSelect
        v-model="bookAuthorId"
        @input="$emit('update:modelValue', $event.target.value)"
        :class="{ 'is-valid': bookAuthorId !== 'Select author' }"
      >
        <option value="Select author">Select author</option>
        <option v-for="author in listAuthors.authors" :key="author.id" :value="author.id">
          {{ author.name }}
        </option>
      </CFormSelect>
    </CInputGroup>
  </div>
</template>

<script>
/* eslint-disable */

import { useQuery } from '@vue/apollo-composable'
import { getAuthors } from '@/graphql-client/queries'
import { ref, watch } from 'vue'

export default {
  name: 'FormListAuthor',
  components: {},
  data() {
    return {}
  },
  setup() {
    let listAuthors = ref([])
    let bookAuthorId = ref('Select author')
    const { result, loading, error } = useQuery(getAuthors)

    // if (loading) console.log('loading...')
    // if (error) console.log('Error getAuthors...', error)
    listAuthors = result
    // setTimeout(() => {
    //   console.log('authors==>', listAuthors)
    // }, 800)

    watch(listAuthors, (currentValue) => {
      console.log('listAuthors.value =>', currentValue, listAuthors.value)
    })

    return {
      listAuthors,
      bookAuthorId,
    }
  },
  methods: {},
  mounted() {
    // this.$emit('congoithangcha',bookAuthorId)
  },
}
</script>

<style scoped></style>
