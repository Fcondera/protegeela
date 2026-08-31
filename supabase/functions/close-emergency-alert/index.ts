import { audit, error, json, rateLimit, readJson, requireContext, textField } from '../_shared/mod.ts';

Deno.serve(async (req) => {
  const ctx = await requireContext(req);
  if (ctx instanceof Response) return ctx;
  const limited = await rateLimit(ctx, 'close_emergency_alert', 10, 60);
  if (limited) return limited;

  const body = await readJson(req);
  if (body instanceof Response) return body;
  const alertId = textField(body, 'alert_id');
  const reason = textField(body, 'reason', 'other');
  if (!alertId) return error('invalid_payload', 'alert_id is required.');

  const { data: alertRow } = await ctx.serviceClient
    .from('emergency_alerts')
    .select('id,user_id,status')
    .eq('id', alertId)
    .eq('user_id', ctx.user.id)
    .maybeSingle();
  if (!alertRow) return error('forbidden', 'Alert not found for current user.', 403);

  const { data: alert, error: updateError } = await ctx.serviceClient
    .from('emergency_alerts')
    .update({ status: 'closed', ended_at: new Date().toISOString(), end_reason: reason, public_visibility: false })
    .eq('id', alertId)
    .select()
    .single();
  if (updateError) return error('close_failed', 'Could not close alert.', 400);

  await ctx.serviceClient.from('tracking_links').update({ revoked_at: new Date().toISOString() }).eq('alert_id', alertId);
  await audit(ctx, 'close_emergency_alert', 'emergency_alert', alertId, { reason });
  return json({ alert });
});
