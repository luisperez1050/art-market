<script setup lang="ts">
import { ref } from 'vue'

interface Subscriber {
  id: string
  full_name: string | null
  is_admin: boolean
  subscriptions: {
    id: string
    tier_name: string
    status: 'active' | 'trialing' | 'past_due' | 'canceled' | 'delinquent'
    current_period_end: string
  } | null
  projects: Array<{
    id: string
    name: string
    subdomain: string
    domain: string
    git_branch: string
    repo: string
    last_deployment: string
    status: 'active' | 'building' | 'failed'
  }>
}

const props = defineProps<{
  subscribers: Subscriber[]
}>()

const emit = defineEmits<{
  (e: 'refresh'): void
}>()

const client = useSupabaseClient()
const selectedSubscriber = ref<Subscriber | null>(null)
const updateLoading = ref(false)

const toggleStatus = async (sub: Subscriber) => {
  if (!sub.subscriptions) return
  updateLoading.value = true
  try {
    const nextStatus = sub.subscriptions.status === 'active' ? 'delinquent' : 'active'
    await client
      .from('subscriptions')
      .update({ status: nextStatus })
      .eq('user_id', sub.id)

    // Update locally too
    sub.subscriptions.status = nextStatus
    emit('refresh')
  } catch (err) {
    console.error('Failed to update subscription status', err)
  } finally {
    updateLoading.value = false
  }
}
</script>

<template>
  <div class="space-y-6">
    <div class="bg-zinc-900/30 border border-zinc-900 rounded-2xl overflow-hidden backdrop-blur-md">
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse text-sm">
          <thead>
            <tr class="border-b border-zinc-900 text-zinc-500 font-semibold text-xs uppercase bg-zinc-950/20">
              <th class="py-3.5 px-6">Subscriber Name</th>
              <th class="py-3.5 px-6">Plan Tier</th>
              <th class="py-3.5 px-6">MRR</th>
              <th class="py-3.5 px-6">Status</th>
              <th class="py-3.5 px-6 text-right">Action</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-zinc-900/60 text-zinc-300">
            <tr v-if="subscribers.length === 0">
              <td colspan="5" class="py-10 text-center text-zinc-500 font-mono text-xs">
                No subscriber profiles found in Database.
              </td>
            </tr>
            <tr 
              v-else
              v-for="sub in subscribers" 
              :key="sub.id"
              class="hover:bg-zinc-900/10 transition-colors"
            >
              <td class="py-4.5 px-6">
                <div class="font-semibold text-white">{{ sub.full_name || 'Anonymous User' }}</div>
                <div class="text-xs text-zinc-500 font-mono mt-0.5">{{ sub.id }}</div>
              </td>
              <td class="py-4.5 px-6 text-zinc-400">
                {{ sub.subscriptions?.tier_name || 'No Active Plan' }}
              </td>
              <td class="py-4.5 px-6 font-semibold text-white">
                {{ sub.subscriptions ? '$10.00' : '$0.00' }}
              </td>
              <td class="py-4.5 px-6">
                <span 
                  v-if="sub.subscriptions"
                  :class="[
                    sub.subscriptions.status === 'active' ? 'bg-emerald-500/10 text-emerald-400 border-emerald-500/20' : 'bg-red-500/10 text-red-400 border-red-500/20',
                    'inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold border'
                  ]"
                >
                  <span :class="['w-1.5 h-1.5 rounded-full', sub.subscriptions.status === 'active' ? 'bg-emerald-500' : 'bg-red-500']"></span>
                  {{ sub.subscriptions.status }}
                </span>
                <span v-else class="text-zinc-500 text-xs">—</span>
              </td>
              <td class="py-4.5 px-6 text-right">
                <button 
                  @click="selectedSubscriber = sub"
                  class="px-3.5 py-1.5 rounded-lg bg-zinc-900 hover:bg-zinc-800 border border-zinc-800 text-zinc-300 hover:text-zinc-100 font-medium text-xs transition-colors cursor-pointer"
                >
                  Manage
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Subscriber Management Slide-over Drawer -->
    <div v-if="selectedSubscriber" class="fixed inset-0 z-50 flex justify-end" role="dialog" aria-modal="true">
      <div class="fixed inset-0 bg-black/60 backdrop-blur-sm transition-opacity" @click="selectedSubscriber = null"></div>

      <div class="relative w-full max-w-md bg-zinc-950 border-l border-zinc-900 p-6 flex flex-col justify-between shadow-2xl animate-slideLeft">
        <div class="space-y-6">
          <div class="flex items-center justify-between border-b border-zinc-900 pb-4">
            <div>
              <span class="text-xs text-zinc-500 font-mono">{{ selectedSubscriber.id }}</span>
              <h3 class="text-lg font-bold text-white tracking-tight mt-0.5">Manage Subscriber</h3>
            </div>
            <button 
              @click="selectedSubscriber = null"
              class="p-1 rounded-lg text-zinc-500 hover:text-white transition-colors cursor-pointer"
            >
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-6 h-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <div class="space-y-5">
            <div class="bg-zinc-900/20 border border-zinc-900 p-4 rounded-xl space-y-1">
              <span class="text-xs text-zinc-500 font-semibold uppercase tracking-wider">Account Owner</span>
              <p class="text-sm font-semibold text-white">{{ selectedSubscriber.full_name || 'Anonymous User' }}</p>
            </div>

            <div class="grid grid-cols-2 gap-4">
              <div class="bg-zinc-900/20 border border-zinc-900 p-4 rounded-xl space-y-1">
                <span class="text-xs text-zinc-500 font-semibold uppercase tracking-wider">Plan Level</span>
                <p class="text-sm font-semibold text-white">
                  {{ selectedSubscriber.subscriptions?.tier_name.split(' ')[0] || 'None' }}
                </p>
              </div>
              <div class="bg-zinc-900/20 border border-zinc-900 p-4 rounded-xl space-y-1">
                <span class="text-xs text-zinc-500 font-semibold uppercase tracking-wider">Revenue</span>
                <p class="text-sm font-semibold text-white">
                  {{ selectedSubscriber.subscriptions ? '$10.00 / mo' : '$0.00' }}
                </p>
              </div>
            </div>

            <!-- Active Hosting Projects -->
            <div class="bg-zinc-900/20 border border-zinc-900 p-4 rounded-xl space-y-4">
              <h4 class="text-xs font-bold text-zinc-400 uppercase tracking-wider">Active Hosting Parameters</h4>
              
              <div v-if="selectedSubscriber.projects.length === 0" class="text-zinc-600 font-mono text-xs text-center py-2">
                No active projects found.
              </div>
              <div 
                v-else
                v-for="proj in selectedSubscriber.projects" 
                :key="proj.id"
                class="space-y-3 text-sm divide-y divide-zinc-900/40"
              >
                <div class="flex justify-between pt-2 first:pt-0">
                  <span class="text-zinc-500">Name:</span>
                  <span class="text-zinc-300 font-semibold">{{ proj.name }}</span>
                </div>
                <div class="flex justify-between pt-2">
                  <span class="text-zinc-500">Subdomain:</span>
                  <span class="text-zinc-300 font-mono text-xs">{{ proj.subdomain }}.localhost</span>
                </div>
                <div class="flex justify-between pt-2">
                  <span class="text-zinc-500">Custom Domain:</span>
                  <span class="text-zinc-300 font-mono text-xs">{{ proj.domain }}</span>
                </div>
                <div class="flex justify-between pt-2">
                  <span class="text-zinc-500">Last Deploy:</span>
                  <span class="text-zinc-300 font-mono text-xs">{{ proj.last_deployment }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="border-t border-zinc-900 pt-6 mt-6 flex gap-3">
          <button 
            v-if="selectedSubscriber.subscriptions"
            @click="toggleStatus(selectedSubscriber)"
            :disabled="updateLoading"
            :class="[
              selectedSubscriber.subscriptions.status === 'active' ? 'bg-red-600/10 hover:bg-red-600/20 border-red-500/20 text-red-400' : 'bg-emerald-600/10 hover:bg-emerald-600/20 border-emerald-500/20 text-emerald-400',
              'flex-grow px-4 py-2.5 rounded-xl border font-semibold text-xs text-center transition-all cursor-pointer disabled:opacity-50'
            ]"
          >
            {{ selectedSubscriber.subscriptions.status === 'active' ? 'Suspend Subscription' : 'Reactivate Plan' }}
          </button>
          <button 
            @click="selectedSubscriber = null"
            class="px-4 py-2.5 rounded-xl bg-zinc-900 hover:bg-zinc-800 border border-zinc-800 text-zinc-300 hover:text-zinc-100 font-semibold text-xs transition-colors cursor-pointer"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
@keyframes slideLeft {
  from {
    transform: translateX(100%);
  }
  to {
    transform: translateX(0);
  }
}

.animate-slideLeft {
  animation: slideLeft 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}
</style>
