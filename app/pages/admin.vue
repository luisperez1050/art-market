<template>
  <div class="relative isolate overflow-hidden min-h-full py-24 sm:py-32">
    <!-- Ambient Glow -->
    <div class="absolute inset-x-0 -top-40 -z-10 transform-gpu overflow-hidden blur-3xl" aria-hidden="true">
      <div class="relative left-[calc(50%-11rem)] aspect-1155/678 w-[36rem] -translate-x-1/2 rotate-[30deg] bg-gradient-to-tr from-violet-600 to-indigo-600 opacity-20 sm:left-[calc(50%-30rem)] sm:w-[72rem]"></div>
    </div>

    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      <div class="max-w-2xl mx-auto text-center">
        <h1 class="text-3xl font-black tracking-tight text-white sm:text-4xl">Admin Control Panel</h1>
        <p class="mt-4 text-lg text-zinc-400">
          Placeholder page for image assets, subscriber tier lists, and billing controls. (Management panel features coming soon).
        </p>
      </div>

      <div class="mt-12 flex justify-center">
        <NuxtLink to="/" class="text-sm font-semibold text-violet-400 hover:text-violet-300 flex items-center gap-1">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="w-4 h-4">
            <path stroke-linecap="round" stroke-linejoin="round" d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" />
          </svg>
          Back to Home
        </NuxtLink>
      </div>
    </div>
  </div>
</template>
