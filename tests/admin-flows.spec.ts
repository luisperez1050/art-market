import { test, expect } from '@playwright/test'

test.describe('Admin Panel Flows', () => {
  // Ensure we sign out before each test to guarantee guest state
  test.beforeEach(async ({ page }) => {
    // Intercept Supabase Auth Token requests
    await page.context().route(/auth\/v1\/token/, async route => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          access_token: 'mock-admin-access-token',
          refresh_token: 'mock-refresh-token',
          expires_in: 3600,
          token_type: 'bearer',
          user: {
            id: 'c16ba643-d20f-44f5-a212-df0031704c7a',
            email: 'admin@gmail.com',
            user_metadata: { full_name: 'System Admin' },
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
          id: 'c16ba643-d20f-44f5-a212-df0031704c7a',
          email: 'admin@gmail.com',
          user_metadata: { full_name: 'System Admin' },
          role: 'authenticated'
        })
      })
    })

    // Intercept Supabase client-side profiles query (admin validation check)
    await page.context().route(/rest\/v1\/profiles/, async route => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({ is_admin: true })
      })
    })

    // Intercept Local Subscribers API endpoint
    await page.context().route(/\/api\/admin\/subscribers/, async route => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([
          {
            id: '88a5d129-b671-4907-a9eb-5c594dc87f4c',
            full_name: 'Chloe',
            is_admin: false,
            subscriptions: {
              id: 'sub-chloe',
              tier_name: 'Standard Hosting Tier',
              status: 'active',
              current_period_end: new Date(Date.now() + 30 * 24 * 3600 * 1000).toISOString()
            },
            projects: [
              {
                id: 'fde303e2-c5fb-49ea-bca8-1246f51b4a7c',
                name: "Chloe's Portfolio Gallery",
                subdomain: 'chloes-art',
                domain: 'chloes-art-portfolio.com',
                git_branch: 'main',
                repo: 'chloe/portfolio',
                last_deployment: '2 hours ago',
                status: 'active'
              }
            ]
          },
          {
            id: '00000000-0000-0000-0000-000000000003',
            full_name: 'Apex Marketing Group',
            is_admin: false,
            subscriptions: {
              id: 'sub-apex',
              tier_name: 'Standard Hosting Tier',
              status: 'delinquent',
              current_period_end: new Date(Date.now() - 5 * 24 * 3600 * 1000).toISOString()
            },
            projects: []
          }
        ])
      })
    })

    page.on('console', msg => console.log(`BROWSER_CONSOLE: [${msg.type()}] ${msg.text()}`))
    page.on('request', request => console.log(`NETWORK_REQUEST: [${request.method()}] ${request.url()}`))

    await page.goto('/admin?mock=true')
    
    // Check if sign out button is present, if so click it to start fresh
    const signOutBtn = page.getByRole('button', { name: 'Sign Out' })
    if (await signOutBtn.isVisible()) {
      await signOutBtn.click()
      await expect(page.getByRole('heading', { name: 'Admin Authorization' })).toBeVisible()
    }
  })

  test('should gate admin access and show admin login wall', async ({ page }) => {
    await page.goto('/admin?mock=true')

    // Confirm that the admin auth gate is visible
    const adminHeader = page.getByRole('heading', { name: 'Admin Authorization' })
    await expect(adminHeader).toBeVisible()

    const adminLoginBtn = page.getByRole('button', { name: 'Sign In as Admin User' })
    await expect(adminLoginBtn).toBeVisible()
  })

  test('should log in as System Admin and render subscriber records', async ({ page }) => {
    await page.goto('/admin?mock=true')

    // Click "Sign In as Admin User"
    const adminLoginBtn = page.getByRole('button', { name: 'Sign In as Admin User' })
    await adminLoginBtn.click()

    // Wait for the Sign Out button to appear, indicating login is complete
    await expect(page.getByRole('button', { name: 'Sign Out' })).toBeVisible({ timeout: 10000 })

    // Wait for the admin content view to load
    const titleHeader = page.getByRole('heading', { name: 'Subscriber Registry' })
    await expect(titleHeader).toBeVisible({ timeout: 15000 })

    // Check that seeded records display in the table
    // We seeded Chloe's Portfolio Gallery and Apex Marketing Group
    const chloeRow = page.getByText('Chloe')
    const apexRow = page.getByText('Apex Marketing Group')

    await expect(chloeRow).toBeVisible()
    await expect(apexRow).toBeVisible()

    // Confirm tabs for Subscribers and Asset Manager exist
    await expect(page.getByRole('button', { name: 'Subscribers' })).toBeVisible()
    await expect(page.getByRole('button', { name: 'Asset Manager' })).toBeVisible()
  })
})
