import { audit, error, json, rateLimit, readJson, requireContext, textField } from '../_shared/mod.ts';

Deno.serve(async (req) => {
  const ctx = await requireContext(req);
  if (ctx instanceof Response) return ctx;
  const limited = await rateLimit(ctx, 'create_emergency_alert', 5, 60);
  if (limited) return limited;

  const body = await readJson(req);
  if (body instanceof Response) return body;

  const clientRequestId = textField(body, 'client_request_id');
  if (!clientRequestId) return error('missing_client_request_id', 'client_request_id is required.');

  const alertType = textField(body, 'alert_type', 'immediate_danger');
  const isSilent = body.is_silent === true;
  const location = body.location as Record<string, unknown> | undefined;
  const locationStatus = textField(body, 'location_status', location ? 'captured' : 'location_unavailable');

  const publicLatitude = typeof location?.latitude === 'number' ? Number(location.latitude.toFixed(3)) : null;
  const publicLongitude = typeof location?.longitude === 'number' ? Number(location.longitude.toFixed(3)) : null;

  const { data: existing } = await ctx.serviceClient
    .from('emergency_alerts')
    .select('*')
    .eq('user_id', ctx.user.id)
    .eq('client_request_id', clientRequestId)
    .maybeSingle();
  if (existing) return json({ alert: existing, idempotent: true });

  const { data: alert, error: insertError } = await ctx.serviceClient
    .from('emergency_alerts')
    .insert({
      user_id: ctx.user.id,
      client_request_id: clientRequestId,
      alert_type: alertType,
      is_silent: isSilent,
      location_status: locationStatus,
      public_latitude: publicLatitude,
      public_longitude: publicLongitude,
    })
    .select()
    .single();
  if (insertError) return error('alert_create_failed', 'Could not create alert.', 400);

  if (location && typeof location.latitude === 'number' && typeof location.longitude === 'number') {
    await ctx.serviceClient.from('alert_locations').insert({
      alert_id: alert.id,
      user_id: ctx.user.id,
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: typeof location.accuracy === 'number' ? location.accuracy : 0,
      altitude: typeof location.altitude === 'number' ? location.altitude : null,
      source: textField(location, 'source', 'browser_geolocation'),
      captured_at: textField(location, 'captured_at', new Date().toISOString()),
    });
  }

  const { data: contacts } = await ctx.serviceClient
    .from('trusted_contacts')
    .select('id')
    .eq('owner_user_id', ctx.user.id)
    .eq('invitation_status', 'accepted');
  if (contacts?.length) {
    await ctx.serviceClient.from('alert_recipients').insert(
      contacts.map((contact) => ({ alert_id: alert.id, trusted_contact_id: contact.id })),
    );
  }

  await audit(ctx, 'create_emergency_alert', 'emergency_alert', alert.id, {
    alert_type: alertType,
    has_location: Boolean(location),
    recipients: contacts?.length ?? 0,
  });

  return json({ alert, recipients: contacts?.length ?? 0 }, 201);
});
