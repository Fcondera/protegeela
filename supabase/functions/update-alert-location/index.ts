import { audit, error, json, rateLimit, readJson, requireContext, textField } from '../_shared/mod.ts';

Deno.serve(async (req) => {
  const ctx = await requireContext(req);
  if (ctx instanceof Response) return ctx;
  const limited = await rateLimit(ctx, 'update_alert_location', 30, 60);
  if (limited) return limited;

  const body = await readJson(req);
  if (body instanceof Response) return body;
  const alertId = textField(body, 'alert_id');
  const location = body.location as Record<string, unknown> | undefined;
  if (!alertId || !location) return error('invalid_payload', 'alert_id and location are required.');

  const { data: alertRow } = await ctx.serviceClient
    .from('emergency_alerts')
    .select('id,user_id,status')
    .eq('id', alertId)
    .eq('user_id', ctx.user.id)
    .maybeSingle();
  if (!alertRow || !['active', 'acknowledged'].includes(alertRow.status)) return error('forbidden', 'Alert is not active or not owned by user.', 403);

  await ctx.serviceClient.from('alert_locations').insert({
    alert_id: alertId,
    user_id: ctx.user.id,
    latitude: location.latitude,
    longitude: location.longitude,
    accuracy: typeof location.accuracy === 'number' ? location.accuracy : 0,
    altitude: typeof location.altitude === 'number' ? location.altitude : null,
    source: textField(location, 'source', 'browser_geolocation'),
    captured_at: textField(location, 'captured_at', new Date().toISOString()),
  });
  await ctx.serviceClient
    .from('emergency_alerts')
    .update({
      location_status: 'captured',
      public_latitude: Number((location.latitude as number).toFixed(3)),
      public_longitude: Number((location.longitude as number).toFixed(3)),
    })
    .eq('id', alertId);

  await audit(ctx, 'update_alert_location', 'emergency_alert', alertId, { has_location: true });
  return json({ ok: true });
});
