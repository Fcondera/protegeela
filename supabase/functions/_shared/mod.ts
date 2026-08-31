import { createClient, SupabaseClient, User } from 'https://esm.sh/@supabase/supabase-js@2.45.4';

export const corsHeaders = {
  'Access-Control-Allow-Origin': Deno.env.get('ALLOWED_ORIGIN') ?? '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

export type FunctionContext = {
  user: User;
  userClient: SupabaseClient;
  serviceClient: SupabaseClient;
};

export function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, 'content-type': 'application/json; charset=utf-8' },
  });
}

export function error(code: string, message: string, status = 400): Response {
  return json({ error: { code, message } }, status);
}

export async function requireContext(req: Request): Promise<FunctionContext | Response> {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  const supabaseUrl = Deno.env.get('SUPABASE_URL');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
  const serviceRole = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!supabaseUrl || !anonKey || !serviceRole) {
    return error('server_misconfigured', 'Supabase environment variables are missing.', 500);
  }

  const authorization = req.headers.get('Authorization') ?? '';
  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
  });
  const serviceClient = createClient(supabaseUrl, serviceRole, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
  const { data, error: authError } = await userClient.auth.getUser();
  if (authError || !data.user) return error('unauthorized', 'Authentication required.', 401);

  return { user: data.user, userClient, serviceClient };
}

export async function requireAdmin(ctx: FunctionContext): Promise<Response | null> {
  const { data, error: profileError } = await ctx.serviceClient
    .from('profiles')
    .select('role')
    .eq('id', ctx.user.id)
    .maybeSingle();

  if (profileError || data?.role !== 'admin') {
    return error('forbidden', 'Administrator role required.', 403);
  }
  return null;
}

export async function audit(ctx: FunctionContext, action: string, entityType: string, entityId?: string, metadata: Record<string, unknown> = {}) {
  await ctx.serviceClient.from('audit_logs').insert({
    actor_user_id: ctx.user.id,
    action,
    entity_type: entityType,
    entity_id: entityId ?? null,
    metadata,
  });
}

export async function rateLimit(ctx: FunctionContext, action: string, maxEvents: number, windowSeconds: number): Promise<Response | null> {
  const since = new Date(Date.now() - windowSeconds * 1000).toISOString();
  const { count } = await ctx.serviceClient
    .from('audit_logs')
    .select('id', { count: 'exact', head: true })
    .eq('actor_user_id', ctx.user.id)
    .eq('action', `rate_limit:${action}`)
    .gte('created_at', since);

  if ((count ?? 0) >= maxEvents) return error('rate_limited', 'Too many requests. Try again later.', 429);
  await audit(ctx, `rate_limit:${action}`, 'rate_limit');
  return null;
}

export async function sha256(value: string): Promise<string> {
  const bytes = new TextEncoder().encode(value);
  const hash = await crypto.subtle.digest('SHA-256', bytes);
  return Array.from(new Uint8Array(hash)).map((byte) => byte.toString(16).padStart(2, '0')).join('');
}

export function randomToken(): string {
  const bytes = new Uint8Array(32);
  crypto.getRandomValues(bytes);
  return btoa(String.fromCharCode(...bytes)).replaceAll('+', '-').replaceAll('/', '_').replaceAll('=', '');
}

export async function readJson(req: Request): Promise<Record<string, unknown> | Response> {
  try {
    return await req.json();
  } catch (_) {
    return error('invalid_json', 'Invalid JSON body.', 400);
  }
}

export function numberField(body: Record<string, unknown>, key: string): number | null {
  const value = body[key];
  return typeof value === 'number' && Number.isFinite(value) ? value : null;
}

export function textField(body: Record<string, unknown>, key: string, fallback = ''): string {
  const value = body[key];
  return typeof value === 'string' ? value : fallback;
}
