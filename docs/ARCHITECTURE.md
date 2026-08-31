# Arquitetura

O Flutter segue organizacao feature-first:

- `lib/app`: app, tema e rotas.
- `lib/core`: configuracao, servicos, erros, widgets e utilidades compartilhadas.
- `lib/features`: fluxos de produto.
- `lib/shared/models`: modelos usados por multiplas features.

Operacoes sensiveis passam por Supabase Edge Functions. O frontend usa somente anon key e depende de RLS para consultas diretas autorizadas.

## Privacidade de localizacao

- `alert_locations` guarda coordenadas exatas com RLS estrito.
- `emergency_alerts.public_latitude/public_longitude` guarda uma coordenada arredondada.
- `get_public_alerts_in_bounds` limita o retorno publico a alertas ativos e area aproximada.
- Links de acompanhamento armazenam somente `token_hash`.

## Modo offline

A PWA faz cache apenas de assets estaticos. Alertas pendentes devem usar `client_request_id` para evitar duplicidade quando sincronizados.
