<script setup lang="ts">
import { ref, computed } from 'vue'

const user = useSupabaseUser()
const client = useSupabaseClient()

const activeTab = ref<'overview' | 'billing' | 'settings'>('overview')
const isMobileSidebarOpen = ref(false)

// Authentication loading states
const authLoading = ref(false)
const authError = ref('')

// Form values for manual authentication (fallback fields)
const emailInput = ref('')
const passwordInput = ref('')

// Register and login a pre-seeded or dynamic demo subscriber account
const handleDemoLogin = async () => {
  authLoading.value = true
  authError.value = ''
  try {
    // 1. Attempt to sign in with pre-seeded Chloe account
    const { data: signInData, error: signInError } = await client.auth.signInWithPassword({
      email: 'chloe@gmail.com',
      password: 'vortex123'
    })

    // 2. If user is missing/unseeded, fallback to signing up chloe@gmail.com
    if (signInError) {
      const { data: signUpData, error: signUpError } = await client.auth.signUp({
        email: 'chloe@gmail.com',
        password: 'vortex123',
        options: {
          data: {
            full_name: 'Chloe'
          }
        }
      })

      if (signUpError) throw signUpError

      if (signUpData?.user) {
        // Seed database objects client-side
        await client.from('subscriptions').insert({
          user_id: signUpData.user.id,
          tier_name: 'Standard Hosting Tier',
          status: 'active',
          current_period_end: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString()
        })

        await client.from('projects').insert({
          user_id: signUpData.user.id,
          name: "Chloe's Portfolio Gallery",
          subdomain: 'chloes-art',
          domain: 'chloes-art-portfolio.com',
          git_branch: 'main',
          repo: 'chloe/portfolio',
          last_deployment: '2 hours ago',
          status: 'active'
        })

        await client.from('assets').insert([
          { user_id: signUpData.user.id, file_name: 'abstract_canvas_oil.png', size: '1.4 MB', storage_path: 'uploads/abstract.png' },
          { user_id: signUpData.user.id, file_name: 'ocean_impression_watercolor.png', size: '2.1 MB', storage_path: 'uploads/ocean.png' }
        ])
      }
    }
  } catch (err: any) {
    console.error('Demo Auth Error:', err)
    authError.value = err?.message || err?.error_description || (typeof err === 'object' ? JSON.stringify(err) : String(err)) || 'Failed to initialize demo space.'
  } finally {
    authLoading.value = false
  }
}

// Credentials-based sign in
const handleLogin = async () => {
  authLoading.value = true
  authError.value = ''
  try {
    const { error } = await client.auth.signInWithPassword({
      email: emailInput.value,
      password: passwordInput.value
    })
    if (error) throw error
  } catch (err: any) {
    console.error('Manual Auth Error:', err)
    authError.value = err?.message || err?.error_description || (typeof err === 'object' ? JSON.stringify(err) : String(err)) || 'Invalid credentials.'
  } finally {
    authLoading.value = false
  }
}

// Query User Projects via Nitro Server Endpoints
const { data: projects, refresh: refreshProjects } = await useFetch('/api/projects', {
  watch: [user]
})

const activeProject = computed(() => projects.value?.[0] || null)

// Fetch Custom Domains Client-side via Supabase Client
const { data: customDomains, refresh: refreshDomains } = await useAsyncData('customDomains', async () => {
  if (!activeProject.value) return []
  const { data } = await client
    .from('custom_domains')
    .select('*')
    .eq('project_id', activeProject.value.id)
  return data || []
}, { watch: [activeProject] })

const newDomain = ref('')

const addDomain = async () => {
  if (newDomain.value.trim() && activeProject.value) {
    await client.from('custom_domains').insert({
      project_id: activeProject.value.id,
      hostname: newDomain.value.trim().toLowerCase(),
      verified: true
    })
    newDomain.value = ''
    refreshDomains()
  }
}

const removeDomain = async (id: string) => {
  await client.from('custom_domains').delete().eq('id', id)
  refreshDomains()
}

// Fetch user subscription status
const { data: subscription } = await useAsyncData('subscription', async () => {
  if (!user.value) return null
  const { data } = await client
    .from('subscriptions')
    .select('*')
    .eq('user_id', user.value.id)
    .maybeSingle()
  return data || null
}, { watch: [user] })

// Environment variables editor
const envKey = ref('')
const envValue = ref('')

const addEnvVar = async () => {
  if (envKey.value.trim() && envValue.value.trim() && activeProject.value) {
    const currentVars = activeProject.value.env_variables || {}
    const updatedVars = {
      ...currentVars,
      [envKey.value.trim().toUpperCase()]: envValue.value.trim()
    }
    
    await client
      .from('projects')
      .update({ env_variables: updatedVars })
      .eq('id', activeProject.value.id)
    
    envKey.value = ''
    envValue.value = ''
    refreshProjects()
  }
}

const removeEnvVar = async (keyToDelete: string) => {
  if (activeProject.value) {
    const currentVars = { ...(activeProject.value.env_variables || {}) }
    delete currentVars[keyToDelete]

    await client
      .from('projects')
      .update({ env_variables: currentVars })
      .eq('id', activeProject.value.id)

    refreshProjects()
  }
}

const formatEnvVars = computed(() => {
  if (!activeProject.value?.env_variables) return []
  return Object.entries(activeProject.value.env_variables).map(([key, value]) => ({
    key,
    value: String(value)
  }))
})

// Mock Invoice logs derived from user subscription
const invoices = computed(() => {
  if (!subscription.value) return []
  return [
    { id: 'INV-001', date: 'Jun 15, 2026', amount: '$10.00', status: 'paid' },
    { id: 'INV-002', date: 'May 15, 2026', amount: '$10.00', status: 'paid' }
  ]
})
</script>

<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    
    <!-- A. GUEST AUTHENTICATION VIEW -->
    <div v-if="!user" class="max-w-md mx-auto py-12 animate-fadeIn">
      <div class="bg-zinc-900/40 border border-zinc-900 rounded-3xl p-8 backdrop-blur-md shadow-2xl relative overflow-hidden">
        <div class="absolute -top-12 -left-12 w-24 h-24 rounded-full bg-violet-500/5 blur-2xl pointer-events-none"></div>
        
        <div class="text-center space-y-3">
          <div class="inline-flex p-3 rounded-2xl bg-violet-600/10 border border-violet-500/20 text-violet-400">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-6 h-6">
              <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
            </svg>
          </div>
          <h2 class="text-2xl font-black text-white tracking-tight">Access Dashboard</h2>
          <p class="text-sm text-zinc-400 max-w-xs mx-auto">
            Sign in below to manage your custom hosting configuration, environment parameters, and site metrics.
          </p>
        </div>

        <form @submit.prevent="handleLogin" class="mt-8 space-y-4">
          <div class="space-y-1.5">
            <label for="login-email" class="text-xs text-zinc-500 font-semibold uppercase tracking-wider pl-1">Email Address</label>
            <input 
              id="login-email"
              type="email" 
              v-model="emailInput" 
              placeholder="you@domain.com" 
              required
              class="w-full bg-zinc-950 border border-zinc-900 rounded-xl px-3.5 py-2.5 text-sm text-white placeholder-zinc-700 focus:outline-none focus:border-violet-500 transition-colors"
            />
          </div>

          <div class="space-y-1.5">
            <label for="login-password" class="text-xs text-zinc-500 font-semibold uppercase tracking-wider pl-1">Password</label>
            <input 
              id="login-password"
              type="password" 
              v-model="passwordInput" 
              placeholder="••••••••" 
              required
              class="w-full bg-zinc-950 border border-zinc-900 rounded-xl px-3.5 py-2.5 text-sm text-white placeholder-zinc-700 focus:outline-none focus:border-violet-500 transition-colors"
            />
          </div>

          <div v-if="authError" class="text-xs text-red-400 bg-red-500/10 border border-red-500/25 p-3 rounded-xl font-medium">
            {{ authError }}
          </div>

          <div class="pt-2 flex flex-col gap-3">
            <button 
              type="submit" 
              :disabled="authLoading"
              class="w-full py-3 rounded-xl bg-violet-600 hover:bg-violet-500 disabled:bg-violet-800 disabled:opacity-50 text-white font-semibold text-sm transition-all shadow-lg shadow-violet-600/15 cursor-pointer flex items-center justify-center gap-2"
            >
              <svg v-if="authLoading" class="animate-spin h-4 w-4 text-white" viewBox="0 0 24 24" fill="none"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
              Sign In
            </button>

            <!-- Sign in as Demo User Button -->
            <button 
              type="button" 
              @click="handleDemoLogin"
              :disabled="authLoading"
              class="w-full py-3 rounded-xl bg-zinc-900 hover:bg-zinc-800 disabled:opacity-50 border border-zinc-800 text-zinc-300 hover:text-white font-semibold text-sm transition-colors cursor-pointer flex items-center justify-center gap-2"
            >
              Sign In as Demo User
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- B. AUTHENTICATED PORTAL VIEW -->
    <div v-else class="space-y-6">
      
      <!-- Responsive Mobile Header -->
      <div class="lg:hidden flex items-center justify-between border-b border-zinc-900 pb-4 mb-6">
        <div class="flex items-center gap-2">
          <span class="logo-icon text-lg">🚀</span>
          <span class="font-bold text-sm tracking-tight text-white">Dashboard</span>
        </div>
        <button 
          @click="isMobileSidebarOpen = true"
          class="p-2 rounded-xl bg-zinc-900 border border-zinc-800 text-zinc-400 hover:text-white transition-colors cursor-pointer"
          aria-label="Open sidebar"
        >
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-6 h-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
          </svg>
        </button>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-4 gap-8">
        
        <!-- 1. SIDEBAR (Desktop) -->
        <aside class="hidden lg:block lg:col-span-1 bg-zinc-950/40 border border-zinc-900 rounded-2xl p-6 h-fit sticky top-24 backdrop-blur-md">
          <div class="space-y-6">
            <div>
              <h2 class="text-xs font-semibold text-zinc-500 uppercase tracking-wider pl-3">Workspace</h2>
              <p class="text-sm font-bold text-white pl-3 mt-1 truncate">Demo Client Space</p>
            </div>
            
            <nav class="space-y-1.5" aria-label="Sidebar">
              <button 
                @click="activeTab = 'overview'"
                :class="[
                  activeTab === 'overview' ? 'bg-violet-600/10 border-violet-500/30 text-violet-400 font-semibold' : 'border-transparent text-zinc-400 hover:text-zinc-100 hover:bg-zinc-900/20',
                  'w-full flex items-center gap-3 px-3 py-2.5 rounded-xl border text-sm transition-all text-left cursor-pointer'
                ]"
              >
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-5 h-5">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 12l8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25" />
                </svg>
                Overview
              </button>

              <button 
                @click="activeTab = 'billing'"
                :class="[
                  activeTab === 'billing' ? 'bg-violet-600/10 border-violet-500/30 text-violet-400 font-semibold' : 'border-transparent text-zinc-400 hover:text-zinc-100 hover:bg-zinc-900/20',
                  'w-full flex items-center gap-3 px-3 py-2.5 rounded-xl border text-sm transition-all text-left cursor-pointer'
                ]"
              >
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-5 h-5">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 8.25h19.5M2.25 9h19.5m-19.5 5.25h19.5m-19.5 0h19.5M2.25 12h19.5m-19.5 0h19.5M2.25 15h19.5M2.25 15h19.5m-19.5 0h19.5M2.25 18h19.5m-19.5 0h19.5" />
                </svg>
                Billing
              </button>

              <button 
                @click="activeTab = 'settings'"
                :class="[
                  activeTab === 'settings' ? 'bg-violet-600/10 border-violet-500/30 text-violet-400 font-semibold' : 'border-transparent text-zinc-400 hover:text-zinc-100 hover:bg-zinc-900/20',
                  'w-full flex items-center gap-3 px-3 py-2.5 rounded-xl border text-sm transition-all text-left cursor-pointer'
                ]"
              >
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-5 h-5">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 0 1 1.37.49l1.296 2.247a1.125 1.125 0 0 1-.26 1.43l-1.003.828c-.293.241-.438.613-.43.992a7.723 7.723 0 0 1 0 .255c-.008.378.137.75.43.992a7.723 7.723 0 0 1 0 .255c-.008.378.137.75.43.991l1.004.827c.424.35.534.954.26 1.43l-1.298 2.247a1.125 1.125 0 0 1-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.57 6.57 0 0 1-.22.128c-.331.183-.581.495-.644.869l-.213 1.28c-.09.543-.56.941-1.11.941h-2.594c-.55 0-1.02-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 0 1-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 0 1-1.369-.49l-1.297-2.247a1.125 1.125 0 0 1 .26-1.43l1.004-.827c.292-.24.437-.613.43-.992a6.932 6.932 0 0 1 0-.255c.007-.378-.138-.75-.43-.991l-1.004-.827a1.125 1.125 0 0 1-.26-1.43l1.297-2.247a1.125 1.125 0 0 1 1.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.087.22-.128.332-.183.582-.495.645-.869l.214-1.28Z" />
                  <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                </svg>
                Settings
              </button>
            </nav>
          </div>
        </aside>

        <!-- 2. SIDEBAR DRAWER (Mobile Slide-over Overlay) -->
        <div v-if="isMobileSidebarOpen" class="relative z-50 lg:hidden" role="dialog" aria-modal="true">
          <div class="fixed inset-0 bg-black/60 backdrop-blur-sm" @click="isMobileSidebarOpen = false"></div>
          <div class="fixed inset-y-0 left-0 flex max-w-full">
            <div class="w-72 max-w-md transform transition-all duration-300 bg-zinc-950 border-r border-zinc-900 p-6 flex flex-col justify-between">
              <div class="space-y-6">
                <div class="flex items-center justify-between border-b border-zinc-900 pb-4">
                  <div class="flex items-center gap-2">
                    <span class="logo-icon text-lg">🚀</span>
                    <span class="font-bold text-sm tracking-tight text-white">Acme Workspace</span>
                  </div>
                  <button 
                    @click="isMobileSidebarOpen = false"
                    class="p-1 rounded-lg text-zinc-500 hover:text-white transition-colors cursor-pointer"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-6 h-6">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                    </svg>
                  </button>
                </div>

                <nav class="space-y-1.5">
                  <button 
                    @click="activeTab = 'overview'; isMobileSidebarOpen = false"
                    :class="[
                      activeTab === 'overview' ? 'bg-violet-600/10 border-violet-500/30 text-violet-400 font-semibold' : 'border-transparent text-zinc-400 hover:text-zinc-100 hover:bg-zinc-900/20',
                      'w-full flex items-center gap-3 px-3 py-2.5 rounded-xl border text-sm transition-all text-left cursor-pointer'
                    ]"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-5 h-5">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 12l8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25" />
                    </svg>
                    Overview
                  </button>

                  <button 
                    @click="activeTab = 'billing'; isMobileSidebarOpen = false"
                    :class="[
                      activeTab === 'billing' ? 'bg-violet-600/10 border-violet-500/30 text-violet-400 font-semibold' : 'border-transparent text-zinc-400 hover:text-zinc-100 hover:bg-zinc-900/20',
                      'w-full flex items-center gap-3 px-3 py-2.5 rounded-xl border text-sm transition-all text-left cursor-pointer'
                    ]"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-5 h-5">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 8.25h19.5M2.25 9h19.5m-19.5 5.25h19.5m-19.5 0h19.5M2.25 12h19.5m-19.5 0h19.5M2.25 15h19.5M2.25 15h19.5m-19.5 0h19.5M2.25 18h19.5m-19.5 0h19.5" />
                    </svg>
                    Billing
                  </button>

                  <button 
                    @click="activeTab = 'settings'; isMobileSidebarOpen = false"
                    :class="[
                      activeTab === 'settings' ? 'bg-violet-600/10 border-violet-500/30 text-violet-400 font-semibold' : 'border-transparent text-zinc-400 hover:text-zinc-100 hover:bg-zinc-900/20',
                      'w-full flex items-center gap-3 px-3 py-2.5 rounded-xl border text-sm transition-all text-left cursor-pointer'
                    ]"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-5 h-5">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 0 1 1.37.49l1.296 2.247a1.125 1.125 0 0 1-.26 1.43l-1.003.828c-.293.241-.438.613-.43.992a7.723 7.723 0 0 1 0 .255c-.008.378.137.75.43.992a7.723 7.723 0 0 1 0 .255c-.008.378.137.75.43.991l1.004.827c.424.35.534.954.26 1.43l-1.298 2.247a1.125 1.125 0 0 1-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.57 6.57 0 0 1-.22.128c-.331.183-.581.495-.644.869l-.213 1.28c-.09.543-.56.941-1.11.941h-2.594c-.55 0-1.02-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 0 1-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 0 1-1.369-.49l-1.297-2.247a1.125 1.125 0 0 1 .26-1.43l1.004-.827c.292-.24.437-.613.43-.992a6.932 6.932 0 0 1 0-.255c.007-.378-.138-.75-.43-.991l-1.004-.827a1.125 1.125 0 0 1-.26-1.43l1.297-2.247a1.125 1.125 0 0 1 1.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.087.22-.128.332-.183.582-.495.645-.869l.214-1.28Z" />
                      <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                    </svg>
                    Settings
                  </button>
                </nav>
              </div>

              <div class="border-t border-zinc-900 pt-4 text-xs text-zinc-500 truncate">
                {{ user.email }}
              </div>
            </div>
          </div>
        </div>

        <!-- 3. WORKSPACE CONTAINER -->
        <main class="lg:col-span-3 space-y-8 min-h-[500px]">
          
          <!-- Empty Slate Warning -->
          <div v-if="!activeProject" class="bg-zinc-900/30 border border-zinc-900 rounded-2xl p-8 text-center backdrop-blur-md">
            <div class="p-3 rounded-full bg-violet-600/10 border border-violet-500/20 text-violet-400 w-fit mx-auto">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-6 h-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 3.75h.008v.008H12v-.008Z" />
              </svg>
            </div>
            <h3 class="mt-4 font-bold text-white text-lg">No projects found</h3>
            <p class="text-zinc-500 text-sm mt-1">This user account does not have any active project containers provisioned yet.</p>
          </div>

          <!-- Tab 1: OVERVIEW -->
          <div v-else-if="activeTab === 'overview'" class="space-y-8 animate-fadeIn">
            
            <!-- Metrics Ribbon -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
              
              <!-- Card 1: Site Status -->
              <div class="bg-zinc-900/30 border border-zinc-900 rounded-2xl p-5 backdrop-blur-md">
                <span class="text-xs text-zinc-500 uppercase tracking-wider font-semibold">Hosting Status</span>
                <div class="flex items-center justify-between mt-3">
                  <span class="text-2xl font-bold text-white tracking-tight uppercase">{{ activeProject.status }}</span>
                  <span 
                    :class="[
                      activeProject.status === 'active' ? 'bg-emerald-500' : 'bg-yellow-500',
                      'inline-flex h-2.5 w-2.5 rounded-full relative'
                    ]"
                  >
                    <span :class="['animate-ping absolute inline-flex h-full w-full rounded-full opacity-75', activeProject.status === 'active' ? 'bg-emerald-400' : 'bg-yellow-400']"></span>
                  </span>
                </div>
              </div>

              <!-- Card 2: Storage Used -->
              <div class="bg-zinc-900/30 border border-zinc-900 rounded-2xl p-5 backdrop-blur-md">
                <div class="flex justify-between items-start">
                  <span class="text-xs text-zinc-500 uppercase tracking-wider font-semibold">Storage Used</span>
                  <span class="text-xs font-mono text-zinc-400">120 MB / 500 MB</span>
                </div>
                <!-- Progress Bar -->
                <div class="mt-4">
                  <div class="h-2 w-full bg-zinc-950 border border-zinc-900 rounded-full overflow-hidden">
                    <div class="h-full bg-gradient-to-r from-violet-500 to-indigo-500 rounded-full" style="width: 24%"></div>
                  </div>
                </div>
              </div>

              <!-- Card 3: Renewal Date -->
              <div class="bg-zinc-900/30 border border-zinc-900 rounded-2xl p-5 backdrop-blur-md">
                <span class="text-xs text-zinc-500 uppercase tracking-wider font-semibold">Next Renewal</span>
                <div class="flex items-center justify-between mt-3">
                  <span class="text-lg font-bold text-white tracking-tight">
                    {{ subscription?.status === 'active' ? 'Aug 15, 2026' : 'Immediate' }}
                  </span>
                  <span 
                    :class="[
                      subscription?.status === 'active' ? 'text-zinc-500 border-zinc-800 bg-zinc-900' : 'text-red-400 border-red-500/20 bg-red-500/10',
                      'text-[10px] uppercase font-mono px-2 py-0.5 rounded border'
                    ]"
                  >
                    {{ subscription?.status === 'active' ? 'Auto' : 'Hold' }}
                  </span>
                </div>
              </div>

            </div>

            <!-- Project Showcase Card -->
            <div>
              <h2 class="text-lg font-bold text-white tracking-tight mb-4">Active Projects</h2>
              <DashboardProjectCard 
                :project="{
                  name: activeProject.name,
                  subdomain: activeProject.subdomain,
                  domain: activeProject.domain,
                  gitBranch: activeProject.git_branch,
                  repo: activeProject.repo,
                  lastDeployment: activeProject.last_deployment,
                  status: activeProject.status
                }"
                @settings-click="activeTab = 'settings'" 
              />
            </div>

          </div>

          <!-- Tab 2: BILLING -->
          <div v-else-if="activeTab === 'billing'" class="space-y-8 animate-fadeIn">
            <div class="bg-zinc-900/30 border border-zinc-900 rounded-2xl p-6 backdrop-blur-md">
              <h2 class="text-lg font-bold text-white tracking-tight border-b border-zinc-900 pb-4">Subscription Overview</h2>
              
              <div class="mt-6 grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- Plan Tier -->
                <div class="bg-zinc-950/60 border border-zinc-900 rounded-2xl p-6 relative overflow-hidden group">
                  <div class="absolute -top-12 -left-12 w-24 h-24 rounded-full bg-violet-500/5 blur-2xl pointer-events-none"></div>
                  <span class="text-xs text-zinc-500 uppercase tracking-wider font-semibold">Current Plan</span>
                  <h3 class="text-xl font-extrabold text-white mt-2">{{ subscription?.tier_name || 'Standard Hosting Tier' }}</h3>
                  <p class="text-3xl font-black text-violet-400 mt-4">$10.00 <span class="text-sm font-medium text-zinc-500">/ month</span></p>
                  <div class="mt-6 flex gap-2">
                    <span 
                      :class="[
                        subscription?.status === 'active' ? 'bg-violet-500/10 text-violet-400 border-violet-500/20' : 'bg-red-500/10 text-red-400 border-red-500/20',
                        'inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold border'
                      ]"
                    >
                      <span :class="['w-1.5 h-1.5 rounded-full', subscription?.status === 'active' ? 'bg-violet-500 animate-pulse' : 'bg-red-500']"></span>
                      {{ subscription?.status || 'Active' }}
                    </span>
                  </div>
                </div>

                <!-- Card Info -->
                <div class="bg-zinc-950/60 border border-zinc-900 rounded-2xl p-6 flex flex-col justify-between">
                  <div>
                    <span class="text-xs text-zinc-500 uppercase tracking-wider font-semibold">Payment Details</span>
                    <div class="flex items-center gap-3 mt-4">
                      <div class="p-2 bg-zinc-900 border border-zinc-800 rounded-lg text-xs font-mono text-zinc-300 font-bold uppercase">
                        Visa
                      </div>
                      <div>
                        <p class="text-sm font-medium text-white">Visa ending in 4242</p>
                        <p class="text-xs text-zinc-500">Expires 12/2028</p>
                      </div>
                    </div>
                  </div>
                  <button class="mt-6 w-full px-4 py-2 rounded-xl bg-zinc-900 hover:bg-zinc-800 border border-zinc-800 text-zinc-300 hover:text-zinc-100 font-medium text-xs transition-colors cursor-pointer">
                    Update Payment Method
                  </button>
                </div>
              </div>
            </div>

            <!-- Invoices table -->
            <div class="bg-zinc-900/30 border border-zinc-900 rounded-2xl p-6 backdrop-blur-md">
              <h2 class="text-lg font-bold text-white tracking-tight mb-4">Billing History</h2>
              <div v-if="invoices.length === 0" class="text-center py-6 text-zinc-500 text-sm">
                No billing invoice records found.
              </div>
              <div v-else class="overflow-x-auto">
                <table class="w-full text-left border-collapse text-sm">
                  <thead>
                    <tr class="border-b border-zinc-900 text-zinc-500 font-semibold text-xs uppercase">
                      <th class="py-3 px-4">Invoice ID</th>
                      <th class="py-3 px-4">Billing Date</th>
                      <th class="py-3 px-4">Amount</th>
                      <th class="py-3 px-4">Status</th>
                    </tr>
                  </thead>
                  <tbody class="divide-y divide-zinc-900/60 text-zinc-300">
                    <tr v-for="invoice in invoices" :key="invoice.id" class="hover:bg-zinc-900/10 transition-colors">
                      <td class="py-4 px-4 font-mono text-xs">{{ invoice.id }}</td>
                      <td class="py-4 px-4">{{ invoice.date }}</td>
                      <td class="py-4 px-4 font-medium text-white">{{ invoice.amount }}</td>
                      <td class="py-4 px-4">
                        <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                          Paid
                        </span>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Tab 3: SETTINGS -->
          <div v-else-if="activeTab === 'settings'" class="space-y-8 animate-fadeIn">
            
            <!-- Environment Variables panel -->
            <div class="bg-zinc-900/30 border border-zinc-900 rounded-2xl p-6 backdrop-blur-md">
              <h2 class="text-lg font-bold text-white tracking-tight border-b border-zinc-900 pb-4">Environment Variables</h2>
              <p class="text-sm text-zinc-500 mt-2">
                Configure system parameters for your hosted instances. Keys are capitalized automatically. Updates commit directly to Supabase.
              </p>

              <!-- Key-Value Grid -->
              <div class="mt-6 space-y-3">
                <div v-if="formatEnvVars.length === 0" class="text-center py-6 text-zinc-600 text-xs font-mono">
                  No active environment variables configured.
                </div>
                <div 
                  v-else
                  v-for="(v, index) in formatEnvVars" 
                  :key="index" 
                  class="grid grid-cols-1 sm:grid-cols-12 gap-3 items-center bg-zinc-950/40 border border-zinc-900 p-3 rounded-xl hover:border-zinc-800/80 transition-all"
                >
                  <div class="sm:col-span-4">
                    <span class="font-mono text-xs text-violet-400 font-bold block sm:hidden mb-1">Key</span>
                    <span class="font-mono text-xs text-white font-bold select-all">{{ v.key }}</span>
                  </div>
                  <div class="sm:col-span-7">
                    <span class="font-mono text-xs text-zinc-500 font-bold block sm:hidden mb-1">Value</span>
                    <span class="font-mono text-xs text-zinc-400 block truncate select-all">{{ v.value }}</span>
                  </div>
                  <div class="sm:col-span-1 flex justify-end">
                    <button 
                      @click="removeEnvVar(v.key)"
                      class="p-1.5 rounded-lg text-zinc-600 hover:text-red-400 hover:bg-red-500/10 border border-transparent hover:border-red-500/20 transition-all cursor-pointer"
                      title="Remove Variable"
                    >
                      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                      </svg>
                    </button>
                  </div>
                </div>

                <!-- Input Form -->
                <form @submit.prevent="addEnvVar" class="grid grid-cols-1 sm:grid-cols-12 gap-3 items-end pt-4 border-t border-zinc-900/60 mt-4">
                  <div class="sm:col-span-5 flex flex-col gap-1.5">
                    <label for="env-var-key" class="text-xs text-zinc-500 font-semibold uppercase tracking-wider pl-1">New Key</label>
                    <input 
                      id="env-var-key"
                      type="text" 
                      v-model="envKey" 
                      placeholder="e.g. DATABASE_PORT" 
                      class="bg-zinc-950 border border-zinc-900 rounded-xl px-3 py-2 text-sm font-mono text-white placeholder-zinc-700 focus:outline-none focus:border-violet-500 transition-colors"
                    />
                  </div>
                  <div class="sm:col-span-5 flex flex-col gap-1.5">
                    <label for="env-var-val" class="text-xs text-zinc-500 font-semibold uppercase tracking-wider pl-1">New Value</label>
                    <input 
                      id="env-var-val"
                      type="text" 
                      v-model="envValue" 
                      placeholder="e.g. 5432" 
                      class="bg-zinc-950 border border-zinc-900 rounded-xl px-3 py-2 text-sm font-mono text-white placeholder-zinc-700 focus:outline-none focus:border-violet-500 transition-colors"
                    />
                  </div>
                  <div class="sm:col-span-2">
                    <button 
                      type="submit" 
                      class="w-full px-4 py-2 rounded-xl bg-violet-600 hover:bg-violet-500 text-white font-medium text-sm transition-all shadow-md shadow-violet-600/15 cursor-pointer"
                    >
                      Add
                    </button>
                  </div>
                </form>
              </div>
            </div>

            <!-- Custom Domains configuration panel -->
            <div class="bg-zinc-900/30 border border-zinc-900 rounded-2xl p-6 backdrop-blur-md">
              <h2 class="text-lg font-bold text-white tracking-tight border-b border-zinc-900 pb-4">Custom Domains</h2>
              <p class="text-sm text-zinc-500 mt-2">
                Route traffic from external hostnames to your project containers. Add DNS records pointing to our cluster IP.
              </p>

              <!-- Domain List -->
              <div class="mt-6 space-y-3">
                <div v-if="customDomains.length === 0" class="text-center py-6 text-zinc-500 text-sm">
                  No custom domains configured.
                </div>
                <div 
                  v-else
                  v-for="(dom, index) in customDomains" 
                  :key="index"
                  class="flex items-center justify-between bg-zinc-950/40 border border-zinc-900 p-3 rounded-xl"
                >
                  <div class="flex items-center gap-3">
                    <span class="text-sm font-medium text-white select-all">{{ dom.hostname }}</span>
                    <span 
                      :class="[
                        dom.verified ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20' : 'bg-yellow-500/10 text-yellow-400 border-yellow-500/20',
                        'inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-[10px] font-semibold border'
                      ]"
                    >
                      <span :class="['w-1.2 h-1.2 rounded-full', dom.verified ? 'bg-emerald-500' : 'bg-yellow-500']"></span>
                      {{ dom.verified ? 'Verified' : 'Pending Verification' }}
                    </span>
                  </div>
                  <button 
                    @click="removeDomain(dom.id)"
                    class="p-1.5 rounded-lg text-zinc-600 hover:text-red-400 hover:bg-red-500/10 border border-transparent hover:border-red-500/20 transition-all cursor-pointer"
                    title="Remove Domain"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4">
                      <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                    </svg>
                  </button>
                </div>

                <!-- Input Form -->
                <form @submit.prevent="addDomain" class="flex items-end gap-3 pt-4 border-t border-zinc-900/60 mt-4">
                  <div class="flex-grow flex flex-col gap-1.5">
                    <label for="new-custom-domain-field" class="text-xs text-zinc-500 font-semibold uppercase tracking-wider pl-1">New Custom Domain</label>
                    <input 
                      id="new-custom-domain-field"
                      type="text" 
                      v-model="newDomain" 
                      placeholder="e.g. art.chloe.com" 
                      class="bg-zinc-950 border border-zinc-900 rounded-xl px-3 py-2 text-sm text-white placeholder-zinc-700 focus:outline-none focus:border-violet-500 transition-colors"
                    />
                  </div>
                  <div>
                    <button 
                      type="submit" 
                      class="px-4 py-2 rounded-xl bg-violet-600 hover:bg-violet-500 text-white font-medium text-sm transition-all shadow-md shadow-violet-600/15 cursor-pointer h-9.5 flex items-center justify-center"
                    >
                      Configure
                    </button>
                  </div>
                </form>
              </div>
            </div>

          </div>

        </main>

      </div>
    </div>
  </div>
</template>

<style scoped>
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(6px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fadeIn {
  animation: fadeIn 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}
</style>
