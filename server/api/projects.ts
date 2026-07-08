import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'

export interface ProjectResponse {
  id: string
  name: string
  subdomain: string
  domain: string
  git_branch: string
  repo: string
  last_deployment: string
  status: 'active' | 'building' | 'failed'
  created_at: string
}

export default defineEventHandler(async (event): Promise<ProjectResponse[]> => {
  const client = await serverSupabaseClient(event)
  let user = await serverSupabaseUser(event)

  let authErrorDetail = 'No session cookie and no Bearer token found'

  if (!user) {
    const headers = getHeaders(event)
    const authHeader = getHeader(event, 'Authorization') || headers['authorization']
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7)
      const { data, error } = await client.auth.getUser(token)
      if (error) {
        authErrorDetail = `Bearer Token validation error: ${error.message} (status ${error.status})`
      } else {
        user = data?.user
      }
    }
  }

  const userId = user?.id || (user as any)?.sub

  if (!user || !userId) {
    console.warn('[api/projects] No valid user or user ID found in event session:', user)
    throw createError({
      statusCode: 401,
      statusMessage: `Unauthorized: Valid auth session required. Detail: ${authErrorDetail}`
    })
  }

  const { data: projects, error } = await client
    .from('projects')
    .select('*')
    .eq('user_id', userId)

  if (error) {
    throw createError({
      statusCode: 500,
      statusMessage: error.message
    })
  }

  return (projects || []) as ProjectResponse[]
})
