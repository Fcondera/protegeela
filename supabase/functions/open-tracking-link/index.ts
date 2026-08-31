import { error, json, readJson, requireContext, sha256, textField } from '../_shared/mod.ts';

Deno.serve(async (req) => {
  const ctx = await requireContext(req);
  if (ctx instanceof Response) return ctx;
  const body = await readJson(req);
  if (body instanceof Response) return body;
  const token = textField(body, 'token');
  if (!token) return error('invalid_payload', 'token is required.');

  const tokenHash = await sha256(token);
  const { data: link } = await ctx.serviceClient
    .from('tracking_links')
    .select('id,alert_id,trusted_contact_id,expires_at,revoked_at')
    .eq('token_hash', tokenHash)
    .maybeSingle();
  if (!link || link.revoked_at || new Date(link.expires_at) <= new Date()) return error('invalid_token', 'Tracking link is invalid or expired.', 403);

  const { data: alert } = await ctx.serviceClient.from('emergency_alerts').select('id,alert_type,status,started_at').eq('id', link.alert_id).single();
  const { data: location } = await ctx.serviceClient
    .from('alert_locations')
    .select('latitude,longitude,accuracy,captured_at')
    .eq('alert_id', link.alert_id)
    .order('captured_at', { ascending: false })
    .limit(1)
    .maybeSingle();

  return json({ alert, location });
});
