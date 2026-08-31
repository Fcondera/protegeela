import { audit, error, json, rateLimit, readJson, requireContext, textField } from '../_shared/mod.ts';

Deno.serve(async (req) => {
  const ctx = await requireContext(req);
  if (ctx instanceof Response) return ctx;
  const limited = await rateLimit(ctx, 'acknowledge_alert', 20, 60);
  if (limited) return limited;

  const body = await readJson(req);
  if (body instanceof Response) return body;
  const alertId = textField(body, 'alert_id');
  const responseStatus = textField(body, 'response_status', 'acknowledged');

  const { data: recipient } = await ctx.serviceClient
    .from('alert_recipients')
    .select('id,trusted_contacts!inner(contact_user_id)')
    .eq('alert_id', alertId)
    .eq('trusted_contacts.contact_user_id', ctx.user.id)
    .maybeSingle();
  if (!recipient) return error('forbidden', 'Alert was not addressed to this user.', 403);

  await ctx.serviceClient
    .from('alert_recipients')
    .update({ delivery_status: 'delivered', response_status: responseStatus, acknowledged_at: new Date().toISOString() })
    .eq('id', recipient.id);
  await ctx.serviceClient.from('emergency_alerts').update({ status: 'acknowledged' }).eq('id', alertId).eq('status', 'active');
  await audit(ctx, 'acknowledge_alert', 'emergency_alert', alertId, { response_status: responseStatus });
  return json({ ok: true });
});
