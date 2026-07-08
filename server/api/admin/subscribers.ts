import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'

export interface AdminSubscriber {
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

export default defineEventHandler(async (event): Promise<AdminSubscriber[]> => {
  const client = await serverSupabaseClient(event)
  let user = await serverSupabaseUser(event)

  if (!user) {
    const authHeader = getHeader(event, 'Authorization')
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7)
      const { data } = await client.auth.getUser(token)
      user = data.user
    }
  }

  const userId = user?.id || (user as any)?.sub

  if (!userId) {
    throw createError({
      statusCode: 401,
      statusMessage: 'Unauthorized: Valid auth session required'
    })
  }

  // 1. Verify caller is an administrator
  const { data: callerProfile, error: callerError } = await client
    .from('profiles')
    .select('is_admin')
    .eq('id', userId)
    .maybeSingle()

  if (callerError || !callerProfile?.is_admin) {
    throw createError({
      statusCode: 403,
      statusMessage: 'Forbidden: Administrator privileges required'
    })
  }

  // 2. Query global user profiles, their subscriptions, and projects
  const { data: subscribers, error } = await client
    .from('profiles')
    .select('id, full_name, is_admin, subscriptions(id, tier_name, status, current_period_end), projects(*)')

  if (error) {
    throw createError({
      statusCode: 500,
      statusMessage: error.message
    })
  }

  return (subscribers || []) as unknown as AdminSubscriber[]
})
