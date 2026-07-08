<template>
  <div class="min-height-screen flex flex-col bg-zinc-950 text-zinc-50 font-sans antialiased selection:bg-violet-500/30 selection:text-violet-200">
    <!-- Navbar -->
    <header class="sticky top-0 z-50 bg-zinc-950/80 backdrop-blur-md border-b border-zinc-900/80">
      <nav class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between" aria-label="Global">
        <!-- Logo -->
        <div class="flex lg:flex-1">
          <NuxtLink to="/" class="flex items-center gap-2 group">
            <div class="p-2 rounded-xl bg-violet-600/10 border border-violet-500/20 group-hover:border-violet-500/40 transition-colors">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-5 h-5 text-violet-500 group-hover:scale-110 transition-transform duration-200">
                <path stroke-linecap="round" stroke-linejoin="round" d="m3.75 13.5 10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75Z" />
              </svg>
            </div>
            <span class="font-bold text-lg tracking-tight bg-gradient-to-r from-zinc-100 to-zinc-400 bg-clip-text text-transparent">
              Vortex<span class="text-zinc-600 font-medium">Hosting</span>
            </span>
          </NuxtLink>
        </div>

        <!-- Navigation Links -->
        <div class="flex gap-x-8">
          <NuxtLink 
            to="/" 
            class="text-sm font-medium text-zinc-400 hover:text-zinc-100 transition-colors"
            active-class="text-zinc-100 font-semibold"
          >
            Home
          </NuxtLink>
          <NuxtLink 
            to="/pricing" 
            class="text-sm font-medium text-zinc-400 hover:text-zinc-100 transition-colors"
            active-class="text-zinc-100 font-semibold"
          >
            Pricing
          </NuxtLink>
          <NuxtLink 
            to="/dashboard" 
            class="text-sm font-medium text-zinc-400 hover:text-zinc-100 transition-colors"
            active-class="text-zinc-100 font-semibold"
          >
            Dashboard
          </NuxtLink>
          <NuxtLink 
            to="/admin" 
            class="text-sm font-medium text-zinc-400 hover:text-zinc-100 transition-colors"
            active-class="text-zinc-100 font-semibold"
          >
            Admin
          </NuxtLink>
        </div>

        <!-- Call to Action -->
        <div class="flex lg:flex-1 lg:justify-end">
          <button class="px-4 py-2 rounded-xl bg-violet-600 hover:bg-violet-500 text-white font-medium text-sm transition-all shadow-lg shadow-violet-600/10 hover:shadow-violet-600/20 active:scale-95 cursor-pointer">
            Sign In
          </button>
        </div>
      </nav>
    </header>

    <!-- Page Content Slot -->
    <main class="flex-grow">
      <slot />
    </main>

    <!-- Footer -->
    <footer class="border-t border-zinc-900 bg-zinc-950/60 backdrop-blur-sm">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 flex flex-col md:flex-row items-center justify-between gap-4">
        <div class="flex items-center gap-2">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4 text-zinc-600">
            <path stroke-linecap="round" stroke-linejoin="round" d="m3.75 13.5 10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75Z" />
          </svg>
          <span class="text-sm text-zinc-500">
            &copy; 2026 Vortex Hosting. All rights reserved.
          </span>
        </div>
        <div class="flex gap-x-6 text-xs text-zinc-600">
          <a href="#" class="hover:text-zinc-400 transition-colors">Privacy Policy</a>
          <a href="#" class="hover:text-zinc-400 transition-colors">Terms of Service</a>
          <a href="#" class="hover:text-zinc-400 transition-colors">System Status</a>
        </div>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.min-height-screen {
  min-height: 100vh;
}
</style>
