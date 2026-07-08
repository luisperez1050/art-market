import { test, expect } from '@playwright/test'

test.describe('Public Routing & Layout Flows', () => {
  test('should render the landing page with headers and navigation', async ({ page }) => {
    // Navigate to the main home page
    await page.goto('/')

    // Check page title or essential hero elements
    await expect(page).toHaveTitle(/Vortex/)
    
    // Assert primary brand text is visible in header
    const branding = page.locator('header').getByText('Vortex')
    await expect(branding).toBeVisible()

    // Assert navigation links exist
    const homeLink = page.locator('header').getByRole('link', { name: 'Home' })
    const pricingLink = page.locator('header').getByRole('link', { name: 'Pricing' })
    const dashboardLink = page.locator('header').getByRole('link', { name: 'Dashboard' })
    const adminLink = page.locator('header').getByRole('link', { name: 'Admin' })

    await expect(homeLink).toBeVisible()
    await expect(pricingLink).toBeVisible()
    await expect(dashboardLink).toBeVisible()
    await expect(adminLink).toBeVisible()
  })

  test('should navigate to pricing page and render core plans list', async ({ page }) => {
    await page.goto('/')
    
    // Click on the Pricing navbar link
    await page.locator('header').getByRole('link', { name: 'Pricing' }).click()
    
    // Expect path to be /pricing
    await expect(page).toHaveURL('/pricing')
    
    // Verify pricing headers exist
    const plansHeader = page.getByRole('heading', { name: 'Pricing Plans' })
    await expect(plansHeader).toBeVisible()
  })
})
