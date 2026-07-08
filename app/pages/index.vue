<template>
  <div class="relative isolate overflow-hidden min-h-full">
    <!-- Ambient Glows -->
    <div class="absolute inset-x-0 -top-40 -z-10 transform-gpu overflow-hidden blur-3xl sm:-top-80" aria-hidden="true">
      <div class="relative left-[calc(50%-11rem)] aspect-1155/678 w-[36rem] -translate-x-1/2 rotate-[30deg] bg-gradient-to-tr from-violet-600 to-indigo-600 opacity-20 sm:left-[calc(50%-30rem)] sm:w-[72rem]"></div>
    </div>

    <!-- Hero Section -->
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 pt-16 pb-24 sm:pt-24 lg:pt-32">
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-8 items-center">
        <!-- Text Column -->
        <div class="max-w-xl lg:max-w-none text-left">
          <div class="inline-flex items-center gap-x-2 rounded-full px-3 py-1 text-xs font-semibold leading-5 text-violet-400 bg-violet-500/10 border border-violet-500/20 mb-6">
            <span>Now in Beta</span>
            <svg viewBox="0 0 2 2" class="h-0.5 w-0.5 fill-current"><circle cx="1" cy="1" r="1" /></svg>
            <span class="text-zinc-400">Nuxt 4 Optimized</span>
          </div>

          <h1 class="text-4xl sm:text-5xl lg:text-6xl font-black tracking-tight text-white leading-[1.1]">
            Deploy Nuxt apps <br />
            with <span class="bg-gradient-to-r from-violet-400 via-fuchsia-400 to-indigo-400 bg-clip-text text-transparent">Zero Friction</span>
          </h1>

          <p class="mt-6 text-base sm:text-lg leading-8 text-zinc-400">
            A premium subscription-based hosting platform built for speed and simplicity. 
            Host client projects, landing pages, and web apps with native subdomain routing and robust database isolation.
          </p>

          <div class="mt-10 flex items-center gap-x-6">
            <button class="px-6 py-3 rounded-xl bg-violet-600 hover:bg-violet-500 text-white font-semibold text-base transition-all shadow-lg shadow-violet-600/10 hover:shadow-violet-600/25 active:scale-98 cursor-pointer">
              Get Hosted Now
            </button>
            <a href="#features" class="text-sm font-semibold leading-6 text-zinc-300 hover:text-white transition-colors flex items-center gap-1">
              Explore features
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4">
                <path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3" />
              </svg>
            </a>
          </div>
        </div>

        <!-- Graphic Column (High-quality SVG Placeholder) -->
        <div class="relative w-full max-w-lg lg:max-w-none mx-auto">
          <div class="aspect-video lg:aspect-square w-full rounded-2xl border border-zinc-900 bg-zinc-950/40 backdrop-blur-md p-6 flex flex-col justify-between shadow-2xl relative overflow-hidden group">
            <!-- Grid overlay -->
            <div class="absolute inset-0 bg-[linear-gradient(to_right,rgba(255,255,255,0.01)_1px,transparent_1px),linear-gradient(to_bottom,rgba(255,255,255,0.01)_1px,transparent_1px)] bg-[size:24px_24px] pointer-events-none"></div>
            <!-- Ambient spotlight in card -->
            <div class="absolute -top-24 -right-24 w-48 h-48 rounded-full bg-violet-500/10 blur-3xl pointer-events-none group-hover:bg-violet-500/20 transition-colors duration-500"></div>

            <!-- Terminal Mockup Window Header -->
            <div class="flex items-center justify-between border-b border-zinc-900/80 pb-4 relative z-10">
              <div class="flex items-center gap-2">
                <span class="w-3 h-3 rounded-full bg-red-500/80"></span>
                <span class="w-3 h-3 rounded-full bg-yellow-500/80"></span>
                <span class="w-3 h-3 rounded-full bg-green-500/80"></span>
              </div>
              <span class="text-xs font-mono text-zinc-600">vortex-deploy.config</span>
            </div>

            <!-- Mock UI Elements (SVG Code Flow Illustration) -->
            <div class="flex-grow flex flex-col justify-center gap-4 py-8 relative z-10 font-mono text-xs">
              <div class="flex items-center gap-3">
                <span class="text-violet-500 select-none">➜</span>
                <span class="text-zinc-500">Initializing project build...</span>
              </div>
              
              <!-- Deployment Pipeline Visual -->
              <div class="border border-zinc-900 bg-zinc-950/60 rounded-xl p-4 flex flex-col gap-3">
                <div class="flex items-center justify-between">
                  <span class="text-zinc-400 font-medium">Build Progress</span>
                  <span class="text-violet-400 font-semibold">Ready</span>
                </div>
                <div class="h-2 w-full bg-zinc-900 rounded-full overflow-hidden">
                  <div class="h-full w-full bg-gradient-to-r from-violet-500 to-fuchsia-500 rounded-full"></div>
                </div>
                <div class="flex items-center justify-between text-[10px] text-zinc-500">
                  <span>Nuxt 4 Bundle</span>
                  <span>3.2 MB (gzip: 840 kB)</span>
                </div>
              </div>

              <div class="flex items-center gap-3 text-emerald-400">
                <span class="font-bold">✔</span>
                <span>Deploying edge functions to 27 regions...</span>
              </div>

              <div class="flex items-center gap-2 text-zinc-500 bg-zinc-900/20 border border-zinc-900/40 p-2 rounded-lg text-[10px] w-fit">
                <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-ping"></span>
                <span>Active Routing: <strong>client-site.vortex.app</strong></span>
              </div>
            </div>

            <!-- Card footer -->
            <div class="border-t border-zinc-900/80 pt-4 flex items-center justify-between text-xs text-zinc-500 relative z-10">
              <span class="flex items-center gap-1.5">
                <span class="w-2 h-2 rounded-full bg-violet-500"></span>
                Active Server Instance
              </span>
              <span>120ms response time</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Features Section -->
    <div id="features" class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-24 sm:py-32 border-t border-zinc-900/60">
      <div class="max-w-2xl lg:max-w-none text-center">
        <h2 class="text-base font-semibold leading-7 text-violet-400 uppercase tracking-wider">Engineered for Performance</h2>
        <p class="mt-2 text-3xl font-bold tracking-tight text-white sm:text-4xl">
          Everything you need to host at scale
        </p>
        <p class="mt-4 text-lg leading-8 text-zinc-400 max-w-xl mx-auto">
          An architecture designed to simplify management, isolate customer environments, and guarantee speed.
        </p>
      </div>

      <div class="mx-auto mt-16 max-w-2xl sm:mt-20 lg:mt-24 lg:max-w-none">
        <dl class="grid max-w-xl grid-cols-1 gap-x-8 gap-y-16 lg:max-w-none lg:grid-cols-3">
          
          <!-- Feature 1 -->
          <div class="flex flex-col bg-zinc-950/40 border border-zinc-900/80 rounded-2xl p-8 hover:border-zinc-800/80 transition-all duration-300 relative group overflow-hidden">
            <div class="absolute -top-12 -left-12 w-24 h-24 rounded-full bg-violet-500/5 blur-2xl group-hover:bg-violet-500/10 transition-colors pointer-events-none"></div>
            <dt class="flex flex-col gap-4">
              <div class="flex h-10 w-10 items-center justify-center rounded-lg bg-violet-600/10 border border-violet-500/20 text-violet-400">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-6 h-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="m3.75 13.5 10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75Z" />
                </svg>
              </div>
              <span class="text-base font-semibold leading-7 text-white">Fast Edge Deployments</span>
            </dt>
            <dd class="mt-4 flex flex-auto flex-col text-base leading-7 text-zinc-400">
              <p class="flex-auto">
                Applications are compiled and served globally on edge nodes. Enjoy minimal latency and instantaneous server-side rendering matching raw edge compute seeds.
              </p>
            </dd>
          </div>

          <!-- Feature 2 -->
          <div class="flex flex-col bg-zinc-950/40 border border-zinc-900/80 rounded-2xl p-8 hover:border-zinc-800/80 transition-all duration-300 relative group overflow-hidden">
            <div class="absolute -top-12 -left-12 w-24 h-24 rounded-full bg-fuchsia-500/5 blur-2xl group-hover:bg-fuchsia-500/10 transition-colors pointer-events-none"></div>
            <dt class="flex flex-col gap-4">
              <div class="flex h-10 w-10 items-center justify-center rounded-lg bg-fuchsia-600/10 border border-fuchsia-500/20 text-fuchsia-400">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-6 h-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12c0 1.268-.63 2.39-1.593 3.068a3.745 3.745 0 0 1-1.043 3.296 3.745 3.745 0 0 1-3.296 1.043A3.745 3.745 0 0 1 12 21c-1.268 0-2.39-.63-3.068-1.593a3.746 3.746 0 0 1-3.296-1.043 3.745 3.745 0 0 1-1.043-3.296A3.745 3.745 0 0 1 3 12c0-1.268.63-2.39 1.593-3.068a3.745 3.745 0 0 1 1.043-3.296 3.746 3.746 0 0 1 3.296-1.043A3.746 3.746 0 0 1 12 3c1.268 0 2.39.63 3.068 1.593a3.746 3.746 0 0 1 3.296 1.043 3.746 3.746 0 0 1 1.043 3.296A3.745 3.745 0 0 1 21 12Z" />
                </svg>
              </div>
              <span class="text-base font-semibold leading-7 text-white">99.9% Uptime SLA</span>
            </dt>
            <dd class="mt-4 flex flex-auto flex-col text-base leading-7 text-zinc-400">
              <p class="flex-auto">
                Built-in health checking and redundant global routing ensure your daughter's projects and custom sites stay up and running without interruption.
              </p>
            </dd>
          </div>

          <!-- Feature 3 -->
          <div class="flex flex-col bg-zinc-950/40 border border-zinc-900/80 rounded-2xl p-8 hover:border-zinc-800/80 transition-all duration-300 relative group overflow-hidden">
            <div class="absolute -top-12 -left-12 w-24 h-24 rounded-full bg-indigo-500/5 blur-2xl group-hover:bg-indigo-500/10 transition-colors pointer-events-none"></div>
            <dt class="flex flex-col gap-4">
              <div class="flex h-10 w-10 items-center justify-center rounded-lg bg-indigo-600/10 border border-indigo-500/20 text-indigo-400">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-6 h-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
                </svg>
              </div>
              <span class="text-base font-semibold leading-7 text-white">Secure Storage</span>
            </dt>
            <dd class="mt-4 flex flex-auto flex-col text-base leading-7 text-zinc-400">
              <p class="flex-auto">
                Isolate file assets, client documents, and system configurations with integrated security parameters, keeping each subscriber workspace completely private.
              </p>
            </dd>
          </div>

        </dl>
      </div>
    </div>

    <!-- Accent Blur Bottom -->
    <div class="absolute inset-x-0 top-[calc(100%-13rem)] -z-10 transform-gpu overflow-hidden blur-3xl sm:top-[calc(100%-30rem)]" aria-hidden="true">
      <div class="relative left-[calc(50%+3rem)] aspect-1155/678 w-[36rem] -translate-x-1/2 bg-gradient-to-tr from-violet-600 to-indigo-600 opacity-20 sm:left-[calc(50%+36rem)] sm:w-[72rem]"></div>
    </div>
  </div>
</template>
