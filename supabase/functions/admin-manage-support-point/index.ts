import { audit, error, json, rateLimit, readJson, requireAdmin, requireContext, textField } from '../_shared/mod.ts';

Deno.serve(async (req) => {
  const ctx = await requireContext(req);
  if (ctx instanceof Response) return ctx;
  const adminError = await requireAdmin(ctx);
  if (adminError) return adminError;
  const limited = await rateLimit(ctx, 'admin_manage_support_point', 60, 60);
  if (limited) return limited;

  const body = await readJson(req);
  if (body instanceof Response) return body;
  const action = textField(body, 'action');
  const payload = body.payload as Record<string, unknown> | undefined;
  if (!action || !payload) return error('invalid_payload', 'action and payload are required.');

  if (action === 'delete') {
    const id = textField(payload, 'id');
    await ctx.serviceClient.from('support_points').delete().eq('id', id);
    await audit(ctx, 'admin_delete_support_point', 'support_point', id);
    return json({ ok: true });
  }

  const record = { ...payload, created_by: ctx.user.id };
  const query = action === 'update'
    ? ctx.serviceClient.from('support_points').update(record).eq('id', textField(payload, 'id')).select().single()
    : ctx.serviceClient.from('support_points').insert(record).select().single();
  const { data, error: saveError } = await query;
  if (saveError) return error('save_failed', 'Could not save support point.', 400);
  await audit(ctx, `admin_${action}_support_point`, 'support_point', data.id);
  return json({ support_point: data });
});
