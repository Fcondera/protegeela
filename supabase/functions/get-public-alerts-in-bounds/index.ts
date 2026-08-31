import { error, json, numberField, readJson, requireContext } from '../_shared/mod.ts';

Deno.serve(async (req) => {
  const ctx = await requireContext(req);
  if (ctx instanceof Response) return ctx;
  const body = await readJson(req);
  if (body instanceof Response) return body;

  const south = numberField(body, 'south');
  const west = numberField(body, 'west');
  const north = numberField(body, 'north');
  const east = numberField(body, 'east');
  const limit = numberField(body, 'limit') ?? 100;
  if ([south, west, north, east].some((value) => value === null)) return error('invalid_bounds', 'Map bounds are required.');

  const { data, error: rpcError } = await ctx.serviceClient.rpc('get_public_alerts_in_bounds', {
    south,
    west,
    north,
    east,
    max_rows: limit,
  });
  if (rpcError) return error('query_failed', 'Could not load public alerts.', 400);
  return json(data ?? []);
});
