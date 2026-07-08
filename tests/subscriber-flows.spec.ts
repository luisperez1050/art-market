import { test, expect } from '@playwright/test'

test.describe('Subscriber Dashboard Flows', () => {
  // Ensure we sign out before each test to guarantee guest state
  test.beforeEach(async ({ page }) => {
    // Intercept Supabase Auth Token requests
    await page.context().route(/auth\/v1\/token/, async route => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          access_token: 'mock-access-token',
          refresh_token: 'mock-refresh-token',
          expires_in: 3600,
          token_type: 'bearer',
          user: {
            id: '88a5d129-b671-4907-a9eb-5c594dc87f4c',
            email: 'chloe@gmail.com',
            user_metadata: { full_name: 'Chloe' },
            role: 'authenticated'
          }
        })
      })
    })

    // Intercept Supabase Auth User requests
    await page.context().route(/auth\/v1\/user/, async route => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          id: '88a5d129-b671-4907-a9eb-5c594dc87f4c',
          email: 'chloe@gmail.com',
          user_metadata: { full_name: 'Chloe' },
          role: 'authenticated'
        })
      })
    })

    // Intercept Local Projects API endpoint
    await page.context().route(/\/api\/projects/, async route => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([
          {
            id: 'fde303e2-c5fb-49ea-bca8-1246f51b4a7c',
            user_id: '88a5d129-b671-4907-a9eb-5c594dc87f4c',
            name: "Chloe's Portfolio Gallery",
            subdomain: 'chloes-art',
            domain: 'chloes-art-portfolio.com',
            git_branch: 'main',
            repo: 'chloe/portfolio',
            last_deployment: '2 hours ago',
            status: 'active',
            env_variables: {},
            created_at: new Date().toISOString()
          }
        ])
      })
    })

    // Intercept Custom Domains database calls
    await page.context().route(/rest\/v1\/custom_domains/, async route => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([])
      })
    })

    page.on('console', msg => console.log(`BROWSER_CONSOLE: [${msg.type()}] ${msg.text()}`))

    await page.goto('/dashboard?mock=true')
    
    // Check if sign out button is present, if so click it to start fresh
    const signOutBtn = page.getByRole('button', { name: 'Sign Out' })
    if (await signOutBtn.isVisible()) {
      await signOutBtn.click()
      await expect(page.getByRole('heading', { name: 'Access Dashboard' })).toBeVisible()
    }
  })

  test('should gate access and render login wall initially', async ({ page }) => {
    await page.goto('/dashboard?mock=true')

    // Confirm that the auth overlay / sign in container is rendered
    const loginHeader = page.getByRole('heading', { name: 'Access Dashboard' })
    await expect(loginHeader).toBeVisible()

    const demoLoginBtn = page.getByRole('button', { name: 'Sign In as Demo User' })
    await expect(demoLoginBtn).toBeVisible()
  })

  test('should log in as Chloe and view subscriber metrics card', async ({ page }) => {
    await page.goto('/dashboard?mock=true')

    // Click on "Sign In as Demo User"
    const demoLoginBtn = page.getByRole('button', { name: 'Sign In as Demo User' })
    await demoLoginBtn.click()

    // Wait for the Sign Out button to appear, indicating login is complete
    await expect(page.getByRole('button', { name: 'Sign Out' })).toBeVisible({ timeout: 10000 })

    // Wait for the auth overlay to disappear and projects card to load
    const projectHeader = page.getByText("Chloe's Portfolio Gallery")
    await expect(projectHeader).toBeVisible({ timeout: 15000 })

    // Verify sub-tabs exist
    await expect(page.getByRole('button', { name: 'Overview' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Billing' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Settings' }).first()).toBeVisible()
  })
})
