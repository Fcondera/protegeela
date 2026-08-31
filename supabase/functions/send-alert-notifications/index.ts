import { audit, error, json, rateLimit, readJson, requireContext, textField } from '../_shared/mod.ts';

Deno.serve(async (req) => {
  const ctx = await requireContext(req);
  if (ctx instanceof Response) return ctx;
  const limited = await rateLimit(ctx, 'send_alert_notifications', 10, 60);
  if (limited) return limited;

  const body = await readJson(req);
  if (body instanceof Response) return body;
  const alertId = textField(body, 'alert_id');
  if (!alertId) return error('invalid_payload', 'alert_id is required.');

  const { data: alertRow } = await ctx.serviceClient.from('emergency_alerts').select('user_id').eq('id', alertId).maybeSingle();
  if (!alertRow || alertRow.user_id !== ctx.user.id) return error('forbidden', 'Alert not owned by user.', 403);

  await ctx.serviceClient.from('alert_recipients').update({ delivery_status: 'sent' }).eq('alert_id', alertId).eq('delivery_status', 'pending');
  await audit(ctx, 'send_alert_notifications', 'emergency_alert', alertId, { mode: 'internal_fallback' });
  return json({ ok: true, mode: 'internal_fallback' });
});
