# ProtegeEla

ProtegeEla e uma PWA open source em Flutter para alertas de emergencia, rede de contatos de confianca, compartilhamento de localizacao com privacidade e mapa de pontos de apoio.

Este repositorio existe para que desenvolvedores, organizacoes sociais, pesquisadoras, equipes publicas e comunidades possam estudar, auditar, adaptar e melhorar uma ferramenta de apoio a seguranca de mulheres.

> Importante: o ProtegeEla nao substitui policia, servicos oficiais de emergencia, atendimento medico, assistencia juridica ou acompanhamento profissional. Ele e uma camada de apoio para acionar pessoas autorizadas e organizar informacoes com privacidade.

## Status do projeto

Versao inicial em desenvolvimento. O projeto ja inclui base Flutter, PWA, Supabase, migrations, RLS, Edge Functions, telas principais e testes iniciais.

Antes de qualquer uso real, faca uma revisao tecnica, juridica, de seguranca, privacidade, acessibilidade e atendimento local.

## Open source

O ProtegeEla e distribuido sob licenca MIT. Voce pode usar, estudar, modificar e distribuir o codigo, respeitando os termos da licenca.

Ao contribuir, mantenha estes principios:

- Privacidade por padrao.
- Localizacao exata nunca publica.
- Nenhuma chave secreta no frontend.
- Nenhum dado real de vitimas, contatos ou ocorrencias em commits.
- Textos cuidadosos, sem promessas irreais de protecao ou rastreamento.
- Recursos sensiveis sempre revisados com RLS, testes e auditoria.

Leia tambem:

- `CONTRIBUTING.md`
- `SECURITY.md`
- `CODE_OF_CONDUCT.md`
- `LICENSE`

## O que o MVP entrega

- Cadastro, login, recuperacao de senha e perfil.
- Rede de contatos de confianca.
- Botao de emergencia com pressionamento por 5 segundos.
- Criacao, atualizacao e encerramento de alertas via Edge Functions.
- Captura de localizacao quando autorizada.
- Fallback quando localizacao ou internet falham.
- Mapa com alertas aproximados e pontos de apoio.
- Conteudos de seguranca gerenciaveis.
- Painel administrativo inicial.
- PWA com manifest, pagina offline e service worker seguro.

## Stack

- Flutter Web com Material 3.
- Riverpod para estado.
- GoRouter para navegacao.
- Supabase Auth, PostgreSQL, RLS, Realtime e Edge Functions.
- Flutter Map com OpenStreetMap.
- Geolocator e URL Launcher.

## Estrutura

```text
lib/
  app/
  core/
  features/
    authentication/
    home/
    emergency/
    alerts_map/
    trusted_contacts/
    support_points/
    safety_content/
    profile/
    notifications/
    admin/
  shared/
supabase/
  migrations/
  functions/
  seed/
test/
web/
```

## Rodando localmente

Instale Flutter estavel e configure um projeto Supabase. Depois:

```bash
cp .env.example .env
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
flutter test
flutter analyze
flutter build web --release
```

Tambem e possivel usar `--dart-define`:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-public-anon-key
```

## Supabase

1. Crie um projeto no Supabase.
2. Copie `Project URL` para `SUPABASE_URL`.
3. Copie a `anon public key` para `SUPABASE_ANON_KEY`.
4. Nunca coloque a `service_role key` no Flutter.
5. Aplique as migrations:

```bash
supabase db push
supabase db execute --file supabase/seed/seed.sql
```

Para desenvolvimento local:

```bash
supabase start
supabase functions serve --env-file supabase/.env.local
```

As Edge Functions usam `SUPABASE_SERVICE_ROLE_KEY` somente no ambiente Supabase/local de backend.

## Edge Functions

Funcoes incluidas:

- `create-emergency-alert`
- `update-alert-location`
- `close-emergency-alert`
- `create-tracking-link`
- `open-tracking-link`
- `acknowledge-alert`
- `get-public-alerts-in-bounds`
- `send-alert-notifications`
- `admin-manage-support-point`

Deploy:

```bash
supabase functions deploy create-emergency-alert
supabase functions deploy update-alert-location
supabase functions deploy close-emergency-alert
supabase functions deploy create-tracking-link
supabase functions deploy open-tracking-link
supabase functions deploy acknowledge-alert
supabase functions deploy get-public-alerts-in-bounds
supabase functions deploy send-alert-notifications
supabase functions deploy admin-manage-support-point
```

## PWA

Arquivos principais:

- `web/manifest.json`
- `web/offline.html`
- `web/sw.js`
- `web/icons/Icon-192.png`
- `web/icons/Icon-512.png`

O service worker so faz cache de arquivos estaticos. Ele nao deve armazenar coordenadas exatas, respostas autenticadas, tokens, dados de contatos ou dados sensiveis de alertas.

Para publicar:

```bash
flutter build web --release
```

Hospede o conteudo de `build/web` em um provedor com HTTPS. Configure o dominio no provedor escolhido e revise `ALLOWED_ORIGIN` nas Edge Functions.

## Pontos de apoio reais

O seed contem apenas dados ficticios de demonstracao. Cadastre unidades reais somente apos verificacao por equipe responsavel, preferencialmente pelo painel administrativo ou pela Edge Function `admin-manage-support-point`.

Campos esperados: nome, categoria, endereco, municipio, estado, latitude, longitude, telefone, horario, site, acessibilidade, verificacao e data de verificacao.

## Servicos de emergencia

Numeros ficam na tabela `emergency_services`; nao altere o frontend para trocar numeros. Use o painel administrativo ou SQL seguro:

```sql
insert into public.emergency_services (name, phone, description, region, is_active)
values ('Nome do servico', 'numero', 'Descricao clara', 'BR-AM', true);
```

Antes de producao, remova ou desative o numero ficticio `000`.

## Notificacoes

`NotificationService` esta abstraido no Flutter e `send-alert-notifications` mantem fallback interno. Push via FCM ou OneSignal deve ser adicionado sem dados sensiveis no conteudo, respeitando consentimento e modo discreto.

## Revisao de RLS

Revise especialmente:

- `alert_locations`: sem leitura publica direta.
- `get_public_alerts_in_bounds`: retorna somente coordenadas aproximadas.
- `profiles`: usuarios nao podem se tornar admin pelo frontend.
- `tracking_links`: tokens salvos apenas como hash.
- `support_points`, `safety_contents` e `emergency_services`: escrita apenas admin.

## Limitacoes conhecidas

- PWA nao garante rastreamento continuo em segundo plano quando o navegador esta fechado.
- Push notifications variam por navegador e sistema operacional.
- Ligacoes `tel:` podem nao funcionar em computadores.
- O projeto precisa de Supabase configurado para sair do modo demo.
- Conteudos e pontos reais exigem verificacao humana antes de producao.

## Checklist de seguranca antes do lancamento

- Rodar `flutter analyze`, `flutter test` e `flutter build web --release`.
- Rodar testes das policies principais em ambiente Supabase isolado.
- Confirmar que nenhuma secret key esta no frontend.
- Confirmar que `SUPABASE_SERVICE_ROLE_KEY` existe apenas no backend.
- Remover dados ficticios ou marca-los como demonstracao.
- Validar que localizacao exata nao aparece no mapa publico.
- Validar expiracao e revogacao de links.
- Revisar textos de notificacao em modo discreto.
- Revisar dominio, CORS, HTTPS e headers de seguranca.
- Fazer teste de acessibilidade em celular, tablet e desktop.
