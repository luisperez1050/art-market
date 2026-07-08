<script setup lang="ts">
import { ref } from 'vue'

interface Asset {
  id: string
  name: string
  url: string
  size: string
  dateAdded: string
}

const user = useSupabaseUser()
const client = useSupabaseClient()

// Query all assets directly from database
const { data: dbAssets, refresh: refreshAssets } = await useAsyncData('adminAssets', async () => {
  const { data, error } = await client
    .from('assets')
    .select('*')
    .order('created_at', { ascending: false })
  
  if (error) return []
  return data.map(item => ({
    id: item.id,
    name: item.file_name,
    url: item.storage_path.startsWith('http') 
      ? item.storage_path 
      : `https://placehold.co/400x300/3b82f6/ffffff?text=${encodeURIComponent(item.file_name.split('.')[0])}`,
    size: item.size,
    dateAdded: 'Uploaded'
  }))
}, { watch: [user] })

const fileInput = ref<HTMLInputElement | null>(null)
const isDragging = ref(false)
const uploadLoading = ref(false)

const triggerFileSelect = () => {
  fileInput.value?.click()
}

const handleFileSelect = (event: Event) => {
  const target = event.target as HTMLInputElement
  if (target.files && target.files[0]) {
    const file = target.files[0]
    addDbAsset(file.name)
  }
}

const handleDrop = (event: DragEvent) => {
  isDragging.value = false
  if (event.dataTransfer?.files && event.dataTransfer.files[0]) {
    const file = event.dataTransfer.files[0]
    addDbAsset(file.name)
  }
}

const addDbAsset = async (fileName: string) => {
  if (!user.value) return
  uploadLoading.value = true
  try {
    const randomColor = ['8b5cf6', 'ec4899', '3b82f6', '10b981', 'f59e0b'][Math.floor(Math.random() * 5)]
    const mockUrl = `https://placehold.co/400x300/${randomColor}/ffffff?text=${encodeURIComponent(fileName.split('.')[0])}`
    
    // Insert asset meta row directly into Supabase database table
    await client.from('assets').insert({
      user_id: user.value.id,
      file_name: fileName,
      size: `${(Math.random() * 2 + 0.5).toFixed(1)} MB`,
      storage_path: mockUrl
    })

    refreshAssets()
  } catch (err) {
    console.error('Failed to register asset row', err)
  } finally {
    uploadLoading.value = false
  }
}

const deleteAsset = async (id: string) => {
  try {
    // Delete asset row directly from Supabase database table
    await client.from('assets').delete().eq('id', id)
    refreshAssets()
  } catch (err) {
    console.error('Failed to remove asset row', err)
  }
}
</script>

<template>
  <div class="space-y-8">
    
    <!-- Drag and Drop Box -->
    <div 
      @click="triggerFileSelect"
      @dragover.prevent="isDragging = true"
      @dragleave.prevent="isDragging = false"
      @drop.prevent="handleDrop"
      :class="[
        isDragging ? 'border-violet-500 bg-violet-600/5' : 'border-zinc-800 bg-zinc-950/20 hover:border-zinc-700/80 hover:bg-zinc-900/10',
        'border-2 border-dashed rounded-2xl p-10 text-center cursor-pointer transition-all backdrop-blur-sm relative'
      ]"
    >
      <input 
        type="file" 
        ref="fileInput"
        class="hidden" 
        @change="handleFileSelect"
        accept="image/*"
      />

      <div v-if="uploadLoading" class="flex flex-col items-center justify-center gap-3">
        <svg class="animate-spin h-6 w-6 text-violet-500" viewBox="0 0 24 24" fill="none"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
        <span class="text-xs text-zinc-400 font-mono">Writing metadata to Supabase table...</span>
      </div>
      <div v-else class="flex flex-col items-center gap-3">
        <div class="p-3 rounded-xl bg-zinc-900 border border-zinc-800 text-zinc-400 group-hover:text-white transition-colors">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-6 h-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75V16.5m-13.5-9L12 3m0 0 4.5 4.5M12 3v13.5" />
          </svg>
        </div>
        <div>
          <p class="text-sm font-semibold text-white">Click or drag images here to upload</p>
          <p class="text-xs text-zinc-500 mt-1">Inserts meta row directly into Supabase database table</p>
        </div>
      </div>
    </div>

    <!-- Media Grid -->
    <div>
      <div class="flex items-center justify-between mb-4">
        <h3 class="font-bold text-white tracking-tight">Gallery Assets ({{ dbAssets?.length || 0 }})</h3>
        <span class="text-xs text-zinc-500">Hover card to delete asset</span>
      </div>

      <div v-if="!dbAssets || dbAssets.length === 0" class="text-center py-10 bg-zinc-900/10 border border-zinc-900 border-dashed rounded-xl text-zinc-600 font-mono text-xs">
        No asset items registered in Database.
      </div>
      <div v-else class="grid grid-cols-2 md:grid-cols-4 gap-6">
        <div 
          v-for="asset in dbAssets" 
          :key="asset.id"
          class="bg-zinc-900/30 border border-zinc-900 rounded-xl overflow-hidden shadow-lg backdrop-blur-sm hover:border-zinc-800 transition-all duration-300 relative group aspect-[4/3] flex flex-col justify-end"
        >
          <!-- Background Image -->
          <img 
            :src="asset.url" 
            :alt="asset.name" 
            class="absolute inset-0 w-full h-full object-cover z-0 filter brightness-[0.85] group-hover:scale-105 transition-transform duration-300"
          />

          <!-- Gradient overlay -->
          <div class="absolute inset-0 bg-gradient-to-t from-zinc-950/90 via-zinc-950/20 to-transparent z-10"></div>

          <!-- Hover Delete Overlay -->
          <div class="absolute inset-0 bg-black/60 backdrop-blur-xs flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity duration-200 z-20">
            <button 
              @click.stop="deleteAsset(asset.id)"
              class="p-3 rounded-full bg-red-500 hover:bg-red-400 text-white shadow-lg active:scale-95 transition-all cursor-pointer"
              title="Delete Asset"
            >
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="w-5 h-5">
                <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
              </svg>
            </button>
          </div>

          <!-- Bottom details -->
          <div class="p-3 relative z-10 w-full overflow-hidden">
            <p class="text-xs font-semibold text-white truncate" :title="asset.name">{{ asset.name }}</p>
            <div class="flex justify-between items-center text-[10px] text-zinc-400 mt-1 font-mono">
              <span>{{ asset.size }}</span>
              <span>{{ asset.dateAdded }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
