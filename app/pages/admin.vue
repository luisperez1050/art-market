<script setup lang="ts">
import { ref, computed } from 'vue'

const user = useSupabaseUser()
const client = useSupabaseClient()

const activePane = ref<'subscribers' | 'assets'>('subscribers')

// Admin Auth Loading states
const authLoading = ref(false)
const authError = ref('')

// Check if user is system admin
const { data: adminCheck, refresh: refreshAdminCheck } = await useAsyncData('adminCheck', async () => {
  if (!user.value) return false
  const { data } = await client
    .from('profiles')
    .select('is_admin')
    .eq('id', user.value.id)
    .maybeSingle()
  return data?.is_admin || false
}, { watch: [user] })

const isAdminActive = computed(() => adminCheck.value === true)

// Register and login a pre-seeded or dynamic admin account
const handleAdminDemoLogin = async () => {
  authLoading.value = true
  authError.value = ''
  try {
    // 1. Attempt to sign in with pre-seeded Admin account
    const { data: signInData, error: signInError } = await client.auth.signInWithPassword({
      email: 'admin@gmail.com',
      password: 'vortex123'
    })

    // 2. If user is missing/unseeded, fallback to signing up admin@gmail.com
    if (signInError) {
      const { data: signUpData, error: signUpError } = await client.auth.signUp({
        email: 'admin@gmail.com',
        password: 'vortex123',
        options: {
          data: {
            full_name: 'System Admin',
            is_admin: true
          }
        }
      })

      if (signUpError) throw signUpError

      if (signUpData?.user) {
        // Set profile is_admin flag explicitly (user has own profile update RLS rights)
        await client
          .from('profiles')
          .update({ is_admin: true })
          .eq('id', signUpData.user.id)
      }
    }
    
    // Refresh local check
    refreshAdminCheck()
  } catch (err: any) {
    console.error('Admin Auth Error:', err)
    authError.value = err?.message || err?.error_description || (typeof err === 'object' ? JSON.stringify(err) : String(err)) || 'Failed to authenticate admin session.'
  } finally {
    authLoading.value = false
  }
}

// Query Subscribers List via Nitro Server Endpoints (only works for admins)
const { data: subscribers, refresh: refreshSubscribers } = await useFetch('/api/admin/subscribers', {
  watch: [isAdminActive]
})

const safeSubscribers = computed(() => {
  if (!subscribers.value) return []
  // Map raw return format to match Table layout fields
  return subscribers.value.map(sub => ({
    id: sub.id,
    full_name: sub.full_name,
    is_admin: sub.is_admin,
    subscriptions: sub.subscriptions,
    projects: sub.projects || []
  }))
})

// Metrics totals derived from database subscribers
const metrics = computed(() => {
  const list = safeSubscribers.value
  const activeList = list.filter(s => s.subscriptions?.status === 'active')
  const delinquentList = list.filter(s => s.subscriptions?.status === 'delinquent')
  const mrrTotal = activeList.length * 10.00
  
  return {
    mrr: `$${mrrTotal.toFixed(2)}`,
    active: activeList.length,
    delinquent: delinquentList.length,
    storage: `${activeList.length * 120 + delinquentList.length * 310} MB`
  }
})
</script>

<template>
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-8">
    
    <!-- A. GUEST OR NON-ADMIN AUTHORIZATION FALLBACK -->
    <div v-if="!user || !isAdminActive" class="max-w-md mx-auto py-12 animate-fadeIn">
      <div class="bg-zinc-900/40 border border-zinc-900 rounded-3xl p-8 backdrop-blur-md shadow-2xl relative overflow-hidden">
        <div class="absolute -top-12 -left-12 w-24 h-24 rounded-full bg-violet-500/5 blur-2xl pointer-events-none"></div>
        
        <div class="text-center space-y-3">
          <div class="inline-flex p-3 rounded-2xl bg-violet-600/10 border border-violet-500/20 text-violet-400">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-6 h-6">
              <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m0-10.036A11.959 11.959 0 0 1 3.598 6 11.99 11.99 0 0 0 3 9.75c0 5.592 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.57-.598-3.75h-.152c-3.196 0-6.1-1.249-8.25-3.286Zm0 13.036h.008v.008H12v-.008Z" />
            </svg>
          </div>
          <h2 class="text-2xl font-black text-white tracking-tight">Admin Authorization</h2>
          <p class="text-sm text-zinc-400 max-w-xs mx-auto">
            You require administrator privileges to access system revenue statistics and manage customer subscriptions.
          </p>
        </div>

        <div class="mt-8 space-y-4">
          <div v-if="authError" class="text-xs text-red-400 bg-red-500/10 border border-red-500/25 p-3 rounded-xl font-medium">
            {{ authError }}
          </div>

          <div class="flex flex-col gap-3">
            <button 
              @click="handleAdminDemoLogin"
              :disabled="authLoading"
              class="w-full py-3 rounded-xl bg-violet-600 hover:bg-violet-500 disabled:opacity-50 text-white font-semibold text-sm transition-all shadow-lg shadow-violet-600/15 cursor-pointer flex items-center justify-center gap-2"
            >
              <svg v-if="authLoading" class="animate-spin h-4 w-4 text-white" viewBox="0 0 24 24" fill="none"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
              Sign In as Admin User
            </button>
            
            <NuxtLink 
              to="/" 
              class="w-full py-3 rounded-xl bg-zinc-900 hover:bg-zinc-800 border border-zinc-800 text-zinc-300 hover:text-white font-semibold text-sm text-center transition-colors block"
            >
              Cancel & Return Home
            </NuxtLink>
          </div>
        </div>
      </div>
    </div>

    <!-- B. ACTIVE ADMINISTRATOR CONTROL PANEL -->
    <div v-else class="space-y-8 animate-fadeIn">
      
      <!-- Admin Header -->
      <div class="border-b border-zinc-900 pb-6 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h1 class="text-3xl font-black tracking-tight text-white">Vortex Administration</h1>
          <p class="mt-1 text-sm text-zinc-500">
            Manage system infrastructure, monitoring, billing status, and image asset repositories.
          </p>
        </div>

        <!-- Action Toggles -->
        <div class="inline-flex rounded-xl p-0.5 bg-zinc-950 border border-zinc-900 self-start">
          <button 
            @click="activePane = 'subscribers'"
            :class="[
              activePane === 'subscribers' ? 'bg-zinc-900 text-white font-medium border border-zinc-800/80 shadow-md' : 'border-transparent text-zinc-400 hover:text-zinc-100',
              'px-4 py-2 rounded-lg text-xs tracking-wide transition-all cursor-pointer'
            ]"
          >
            Subscribers
          </button>
          <button 
            @click="activePane = 'assets'"
            :class="[
              activePane === 'assets' ? 'bg-zinc-900 text-white font-medium border border-zinc-800/80 shadow-md' : 'border-transparent text-zinc-400 hover:text-zinc-100',
              'px-4 py-2 rounded-lg text-xs tracking-wide transition-all cursor-pointer'
            ]"
          >
            Asset Manager
          </button>
        </div>
      </div>

      <!-- Administrative Statistics Ribbon -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <!-- Card 1: Total MRR -->
        <div class="bg-zinc-900/30 border border-zinc-900 rounded-2xl p-5 backdrop-blur-md">
          <span class="text-[10px] text-zinc-500 uppercase tracking-widest font-bold block">Total revenue (MRR)</span>
          <span class="text-3xl font-black text-white mt-2 block tracking-tight">{{ metrics.mrr }}</span>
          <span class="text-[10px] text-emerald-400 font-semibold mt-1 inline-flex items-center gap-0.5">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="w-3 h-3">
              <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 10.5 12 3m0 0 7.5 7.5M12 3v18" />
            </svg>
            Active database feeds
          </span>
        </div>

        <!-- Card 2: Active Subs -->
        <div class="bg-zinc-900/30 border border-zinc-900 rounded-2xl p-5 backdrop-blur-md">
          <span class="text-[10px] text-zinc-500 uppercase tracking-widest font-bold block">Active instances</span>
          <span class="text-3xl font-black text-white mt-2 block tracking-tight">{{ metrics.active }}</span>
          <span class="text-[10px] text-zinc-500 mt-1 block">Healthy DNS routes</span>
        </div>

        <!-- Card 3: Delinquent Subs -->
        <div class="bg-zinc-900/30 border border-zinc-900 rounded-2xl p-5 backdrop-blur-md">
          <span class="text-[10px] text-zinc-500 uppercase tracking-widest font-bold block">Delinquent accounts</span>
          <span class="text-3xl font-black text-white mt-2 block tracking-tight">{{ metrics.delinquent }}</span>
          <span class="text-[10px] text-red-400 font-semibold mt-1 inline-flex items-center gap-0.5">
            Requires collection
          </span>
        </div>

        <!-- Card 4: Global Storage -->
        <div class="bg-zinc-900/30 border border-zinc-900 rounded-2xl p-5 backdrop-blur-md">
          <span class="text-[10px] text-zinc-500 uppercase tracking-widest font-bold block">Global storage capacity</span>
          <span class="text-3xl font-black text-white mt-2 block tracking-tight">{{ metrics.storage }}</span>
          <span class="text-[10px] text-zinc-400 mt-1 block">Accumulated data sets</span>
        </div>
      </div>

      <!-- Active Management Zone -->
      <div class="pt-2">
        <div v-if="activePane === 'subscribers'" class="animate-fadeIn">
          <h2 class="text-xl font-extrabold text-white tracking-tight mb-4">Subscriber Registry</h2>
          <AdminSubscriberTable 
            :subscribers="safeSubscribers"
            @refresh="refreshSubscribers"
          />
        </div>

        <div v-else-if="activePane === 'assets'" class="animate-fadeIn">
          <h2 class="text-xl font-extrabold text-white tracking-tight mb-4">Centralized Media Grid</h2>
          <AdminImageManager />
        </div>
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
