import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './tests',
  fullyParallel: false, // run sequentially to avoid Supabase session conflicts during dynamic sign-ins
  forbidOnly: !!process.env.CI,
  retries: 0,
  workers: 1, // enforce single worker to prevent race conditions on shared mock databases
  reporter: 'list',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: true,
    stdout: 'ignore',
    stderr: 'pipe',
    timeout: 30000,
    env: {
      PLAYWRIGHT: 'true'
    }
  },
})
