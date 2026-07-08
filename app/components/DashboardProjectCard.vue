<script setup lang="ts">
interface Project {
  name: string
  subdomain: string
  domain: string
  gitBranch: string
  repo: string
  lastDeployment: string
  status: 'active' | 'building' | 'failed'
}

const props = withDefaults(
  defineProps<{
    project?: Project
  }>(),
  {
    project: () => ({
      name: "Acme Art Gallery",
      subdomain: "acme-gallery",
      domain: "acme-gallery.vortex.app",
      gitBranch: "main",
      repo: "luisperez/acme-gallery",
      lastDeployment: "2 hours ago",
      status: "active" as const
    })
  }
)

const emit = defineEmits<{
  (e: 'settings-click'): void
}>()
</script>

<template>
  <div class="bg-zinc-900/30 border border-zinc-900 rounded-2xl overflow-hidden hover:border-zinc-800 transition-all duration-300 shadow-xl backdrop-blur-md">
    <div class="grid grid-cols-1 md:grid-cols-5">
      <!-- Mock Site Preview (2 cols) -->
      <div class="md:col-span-2 bg-zinc-950/60 p-6 flex flex-col justify-between border-b md:border-b-0 md:border-r border-zinc-900 relative group min-h-[180px]">
        <!-- Preview Grid Mock -->
        <div class="absolute inset-0 bg-[linear-gradient(to_right,rgba(255,255,255,0.005)_1px,transparent_1px),linear-gradient(to_bottom,rgba(255,255,255,0.005)_1px,transparent_1px)] bg-[size:16px_16px]"></div>
        
        <!-- Mock Browser Frame -->
        <div class="border border-zinc-800/80 bg-zinc-950/90 rounded-xl p-3 flex-grow flex flex-col justify-between relative z-10 shadow-lg group-hover:border-zinc-700/80 transition-colors duration-300">
          <div class="flex items-center gap-1.5 border-b border-zinc-900 pb-2 mb-2">
            <span class="w-2 h-2 rounded-full bg-zinc-800"></span>
            <span class="w-2 h-2 rounded-full bg-zinc-800"></span>
            <span class="w-2 h-2 rounded-full bg-zinc-800"></span>
            <div class="bg-zinc-900/60 text-[9px] text-zinc-500 px-2 py-0.5 rounded flex-grow text-center font-mono truncate ml-1">
              {{ project.domain }}
            </div>
          </div>
          <!-- Canvas Body -->
          <div class="flex-grow flex flex-col items-center justify-center gap-1.5 py-4">
            <div class="p-2 rounded-full bg-violet-600/10 text-violet-400">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-5 h-5">
                <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 15a4.5 4.5 0 0 0 4.5 4.5H18a3.75 3.75 0 0 0 1.332-7.257 3 3 0 0 0-3.758-3.848 5.25 5.25 0 0 0-10.233 2.33A4.502 4.502 0 0 0 2.25 15Z" />
              </svg>
            </div>
            <span class="text-[10px] text-zinc-400 font-semibold tracking-wide">Live Preview</span>
          </div>
        </div>
      </div>

      <!-- Project Metadata & Actions (3 cols) -->
      <div class="md:col-span-3 p-6 flex flex-col justify-between gap-6">
        <div>
          <!-- Title & Badge -->
          <div class="flex items-center justify-between gap-4">
            <h3 class="font-bold text-lg text-white tracking-tight">{{ project.name }}</h3>
            <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
              <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
              {{ project.status }}
            </span>
          </div>

          <!-- Metadata Fields -->
          <div class="mt-4 grid grid-cols-2 gap-y-4 gap-x-2 text-sm">
            <div>
              <span class="block text-xs text-zinc-500 uppercase tracking-wider font-semibold">Domain</span>
              <a :href="`http://${project.domain}`" target="_blank" class="text-violet-400 hover:text-violet-300 font-medium inline-flex items-center gap-1 transition-colors mt-0.5">
                {{ project.domain }}
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="w-3.5 h-3.5">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 6H5.25A2.25 2.25 0 0 0 3 8.25v10.5A2.25 2.25 0 0 0 5.25 21h10.5A2.25 2.25 0 0 0 18 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25" />
                </svg>
              </a>
            </div>

            <div>
              <span class="block text-xs text-zinc-500 uppercase tracking-wider font-semibold">Repository</span>
              <span class="text-zinc-300 font-mono text-xs inline-flex items-center gap-1.5 mt-1">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-3.5 h-3.5 text-zinc-500">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M14.25 9.75 16.5 12l-2.25 2.25m-4.5 0L7.5 12l2.25-2.25M6 20.25h12A2.25 2.25 0 0 0 20.25 18V6A2.25 2.25 0 0 0 18 3.75H6A2.25 2.25 0 0 0 3.75 6v12A2.25 2.25 0 0 0 6 20.25Z" />
                </svg>
                {{ project.repo }}
              </span>
            </div>

            <div>
              <span class="block text-xs text-zinc-500 uppercase tracking-wider font-semibold">Branch</span>
              <span class="text-zinc-300 text-xs inline-flex items-center gap-1.5 mt-1">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="w-3.5 h-3.5 text-zinc-500">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M7.217 10.907a2.25 2.25 0 1 0 0 2.186m0-2.186c.18.324.283.696.283 1.093s-.103.77-.283 1.093m0-2.186 9.566-5.314m-9.566 7.5 9.566 5.314m0 0a2.25 2.25 0 1 0 3.935-2.186 2.25 2.25 0 0 0-3.935 2.186Zm0-12.814a2.25 2.25 0 1 0 3.933-2.185 2.25 2.25 0 0 0-3.933 2.185Z" />
                </svg>
                {{ project.gitBranch }}
              </span>
            </div>

            <div>
              <span class="block text-xs text-zinc-500 uppercase tracking-wider font-semibold">Last Deployed</span>
              <span class="text-zinc-300 text-xs mt-1 block">
                {{ project.lastDeployment }}
              </span>
            </div>
          </div>
        </div>

        <!-- Action Bar -->
        <div class="flex items-center gap-3 border-t border-zinc-900/60 pt-4 mt-auto">
          <a :href="`http://${project.domain}`" target="_blank" class="flex-grow px-4 py-2 rounded-xl bg-violet-600 hover:bg-violet-500 text-white font-medium text-xs text-center transition-all shadow-md shadow-violet-600/10 hover:shadow-violet-600/25 active:scale-98">
            View Live Site
          </a>
          <button @click="emit('settings-click')" class="px-4 py-2 rounded-xl bg-zinc-900 hover:bg-zinc-800 border border-zinc-800/80 text-zinc-300 hover:text-zinc-100 font-medium text-xs transition-colors cursor-pointer">
            Settings
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
