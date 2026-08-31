import { audit, error, json, randomToken, rateLimit, readJson, requireContext, sha256, textField } from '../_shared/mod.ts';

Deno.serve(async (req) => {
  const ctx = await requireContext(req);
  if (ctx instanceof Response) return ctx;
  const limited = await rateLimit(ctx, 'create_tracking_link', 20, 60);
  if (limited) return limited;

  const body = await readJson(req);
  if (body instanceof Response) return body;
  const alertId = textField(body, 'alert_id');
  const trustedContactId = textField(body, 'trusted_contact_id') || null;

  const { data: alertRow } = await ctx.serviceClient
    .from('emergency_alerts')
    .select('id,user_id,status')
    .eq('id', alertId)
    .eq('user_id', ctx.user.id)
    .maybeSingle();
  if (!alertRow || !['active', 'acknowledged'].includes(alertRow.status)) return error('forbidden', 'Alert is not active or not owned by user.', 403);

  const token = randomToken();
  const tokenHash = await sha256(token);
  const expiresAt = new Date(Date.now() + 12 * 60 * 60 * 1000).toISOString();
  const { data: link, error: insertError } = await ctx.serviceClient
    .from('tracking_links')
    .insert({ alert_id: alertId, trusted_contact_id: trustedContactId, token_hash: tokenHash, expires_at: expiresAt })
    .select('id,expires_at')
    .single();
  if (insertError) return error('link_create_failed', 'Could not create tracking link.', 400);

  await audit(ctx, 'create_tracking_link', 'tracking_link', link.id, { alert_id: alertId });
  return json({ token, expires_at: expiresAt }, 201);
});
