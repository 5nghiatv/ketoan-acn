import { ref, computed } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import { getAuthors } from './queries'

export default function getlistAuthors() {
  const { result, loading, error } = useQuery(getAuthors)
  const listAuthors = computed(() => result.value?.authors ?? [])

  let loading_ = ref(loading)
  let error_ = ref(error)
  // console.log('listAuthors', listAuthors)

  return { listAuthors, loading_, error_ }
}
