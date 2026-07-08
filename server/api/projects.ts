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
  const user = await serverSupabaseUser(event)
  if (!user) {
    throw createError({
      statusCode: 401,
      statusMessage: 'Unauthorized: Valid auth session required'
    })
  }

  const client = await serverSupabaseClient(event)

  const { data: projects, error } = await client
    .from('projects')
    .select('*')
    .eq('user_id', user.id)

  if (error) {
    throw createError({
      statusCode: 500,
      statusMessage: error.message
    })
  }

  return (projects || []) as ProjectResponse[]
})
