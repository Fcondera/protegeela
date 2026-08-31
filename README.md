# ProtegeEla

ProtegeEla e um aplicativo PWA open source criado para apoiar mulheres em situacoes de risco, oferecendo acionamento rapido de ajuda, rede de contatos de confianca, compartilhamento de localizacao com privacidade e mapa com pontos de apoio.

O projeto foi desenvolvido com foco em seguranca, acessibilidade, responsabilidade social e arquitetura moderna. Ele pode ser estudado, auditado, adaptado e evoluido por comunidades, organizacoes sociais, equipes publicas, estudantes e desenvolvedores.

> O ProtegeEla nao substitui policia, servicos oficiais de emergencia, atendimento medico, assistencia juridica ou acompanhamento profissional. Ele e uma ferramenta complementar para facilitar comunicacao, apoio e organizacao de informacoes em momentos sensiveis.

## Visao do aplicativo

O objetivo do ProtegeEla e permitir que uma usuaria consiga pedir ajuda de forma simples, discreta e segura, conectando sua rede de apoio e protegendo dados sensiveis.

O aplicativo foi pensado para funcionar em celular, tablet e computador, com instalacao como PWA e interface responsiva. A experiencia prioriza botoes grandes, linguagem clara, navegacao simples, contraste adequado e privacidade por padrao.

## Demonstracao

Versao publicada:

```text
https://protegeela.netlify.app
```

Na tela de login existe a opcao `Entrar temporariamente`, criada para demonstracao rapida sem cadastro real.

No modo temporario:

- A sessao fica apenas no navegador.
- O perfil e ficticio.
- Os contatos sao ficticios.
- Os pontos de apoio sao ficticios.
- Os alertas nao sao enviados para pessoas reais.
- Nenhuma emergencia real e acionada.

Para uso real, e necessario configurar Supabase, banco de dados, RLS, Edge Functions e dados verificados.

## Principais funcionalidades

### Autenticacao e onboarding

- Splash screen.
- Apresentacao do aplicativo.
- Explicacao sobre privacidade.
- Solicitacao contextual de localizacao.
- Cadastro com nome, e-mail, telefone, senha e aceite de termos.
- Login com Supabase Auth.
- Recuperacao de senha sem revelar se o e-mail existe.
- Confirmacao de e-mail.
- Criacao de perfil.
- Cadastro opcional do primeiro contato de confianca.
- Logout.
- Protecao de rotas privadas.
- Entrada temporaria para demonstracao.

### Tela inicial

- Saudacao com o primeiro nome da usuaria.
- Status atual de seguranca.
- Botao central de emergencia como elemento principal.
- Atalhos para mapa, contatos, pontos de apoio e orientacoes.
- Navegacao inferior no celular.
- Navegacao lateral no desktop.

### Botao de emergencia

O componente `EmergencyButton` foi criado para reduzir disparos acidentais e manter acessibilidade.

Funcionalidades:

- Pressionar e segurar por 5 segundos.
- Progresso circular durante o pressionamento.
- Feedback haptico quando disponivel.
- Confirmacao com contagem regressiva de 5 segundos.
- Opcao de enviar imediatamente.
- Opcao de cancelar.
- Opcao de ativar silenciosamente.
- Envio automatico ao final da contagem.
- Prevencao de disparo duplicado.
- Suporte a teclado e leitores de tela.

Ao ativar um alerta, o app tenta capturar a localizacao atual. Se GPS, permissao ou internet falharem, o fluxo nao bloqueia o pedido de ajuda. O alerta pode ser registrado como pendente e sincronizado depois usando `client_request_id` para evitar duplicidade.

### Alerta ativo

A tela de alerta ativo mostra:

- Status do alerta.
- Horario de ativacao.
- Mapa com a ultima localizacao disponivel.
- Precisao aproximada.
- Informacoes sobre contatos avisados.
- Botao para ligar para servico de emergencia configurado.
- Botao para atualizar localizacao.
- Botao para informar que esta em local seguro.
- Botao para encerrar alerta.

Ao encerrar, o sistema registra motivo, data e horario, revoga links de acompanhamento e interrompe atualizacoes de localizacao.

### Localizacao com privacidade

O ProtegeEla separa localizacao exata de localizacao publica aproximada.

- Localizacao exata fica em `alert_locations`.
- Localizacao exata nao tem leitura publica direta.
- O mapa comunitario usa coordenadas aproximadas.
- Contatos so acessam localizacao exata durante alerta ativo e quando autorizados.
- Links de acompanhamento usam token aleatorio com hash no banco.
- Alertas encerrados deixam de aparecer publicamente.

### Mapa geral de alertas

A tela `AlertsMapPage` usa OpenStreetMap com Flutter Map.

Ela pode exibir:

- Localizacao de referencia.
- Alertas ativos permitidos.
- Areas aproximadas de alertas publicos.
- Pontos de apoio.
- Filtros de exibicao.
- Campo de busca.
- Botao para centralizar mapa.
- Legenda de marcadores.

O mapa publico nao mostra nome completo, telefone, foto, endereco ou coordenada exata da pessoa em alerta.

### Rede de contatos de confianca

O aplicativo permite:

- Listar contatos.
- Adicionar contato.
- Enviar convite.
- Aceitar ou recusar vinculo.
- Remover contato.
- Definir contato principal.
- Configurar permissao de localizacao durante alerta.

Um contato nao deve ser considerado ativo sem consentimento.

Durante um alerta, contatos autorizados podem:

- Abrir link seguro.
- Ver localizacao autorizada.
- Confirmar recebimento.
- Informar que estao acompanhando.
- Informar que acionaram ajuda.

### Pontos de apoio

O app possui tela de lista e mapa para pontos de apoio.

Cada ponto pode conter:

- Nome.
- Categoria.
- Descricao.
- Endereco.
- Municipio.
- Estado.
- Latitude e longitude.
- Telefone.
- Horario de funcionamento.
- Site.
- Informacoes de acessibilidade.
- Status de verificacao.
- Data da ultima verificacao.

O seed do projeto inclui apenas dados ficticios e claramente demonstrativos. Pontos reais devem ser cadastrados somente apos verificacao.

### Conteudos de seguranca

Area com orientacoes gerenciaveis por administrador:

- Como montar uma rede de apoio.
- Como compartilhar localizacao.
- Como preservar provas com seguranca.
- Como buscar atendimento.
- Como criar um plano de seguranca.
- Como proteger a conta e o dispositivo.

As telas sensiveis incluem saida rapida e mensagens realistas sobre limitacoes.

### Saida rapida e privacidade visual

O app inclui botao discreto de `Saida rapida` em telas sensiveis.

Ao tocar, a usuaria e redirecionada para uma pagina neutra. O aplicativo nao promete apagar historico do navegador, porque isso nao seria tecnicamente honesto.

Tambem ha configuracoes para:

- Textos discretos em notificacoes.
- Exigencia de PIN para informacoes sensiveis.
- Ocultar previa de alerta.

### Notificacoes

Foi criada uma camada abstrata `NotificationService`.

O projeto esta preparado para:

- Novo alerta recebido.
- Atualizacao de localizacao.
- Alerta encerrado.
- Solicitacao de acompanhamento.

Sem push configurado, o app usa fallback interno. Qualquer integracao futura com FCM ou OneSignal deve evitar dados sensiveis no conteudo da notificacao.

### Painel administrativo

Painel protegido para administradores com base para:

- Indicadores agregados.
- Alertas ativos sem exposicao desnecessaria.
- Pontos de apoio.
- Conteudos informativos.
- Servicos de emergencia.
- Moderacao.
- Logs administrativos.

Indicadores previstos:

- Total de alertas.
- Alertas ativos.
- Alertas encerrados.
- Pontos de apoio verificados.
- Dados agregados sem identificacao pessoal.

## Arquitetura

O projeto segue uma organizacao feature-first:

```text
lib/
  app/
    app.dart
    router.dart
    theme.dart
  core/
    config/
    constants/
    errors/
    services/
    utils/
    widgets/
  features/
    onboarding/
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
    models/
    providers/
supabase/
  migrations/
  functions/
  seed/
test/
web/
```

Essa estrutura facilita manutencao, testes e evolucao por comunidade.

## Tecnologias

Frontend:

- Flutter Web.
- Dart com null safety.
- Material 3.
- Riverpod.
- GoRouter.
- Supabase Flutter.
- Flutter Map.
- OpenStreetMap.
- Geolocator.
- URL Launcher.
- Shared Preferences.

Backend:

- Supabase.
- PostgreSQL.
- Supabase Auth.
- Row Level Security.
- Supabase Realtime.
- Edge Functions.
- PostGIS.

Deploy:

- Netlify.
- PWA manifest.
- Service worker.
- Pagina offline.
- Headers de seguranca.

## Banco de dados

As migrations incluem:

- `profiles`
- `trusted_contacts`
- `emergency_alerts`
- `alert_locations`
- `alert_recipients`
- `tracking_links`
- `support_points`
- `safety_contents`
- `emergency_services`
- `audit_logs`

Tambem foram criados:

- Enums PostgreSQL.
- Chaves estrangeiras.
- Indices.
- Indices geograficos.
- Constraints.
- Triggers de `updated_at`.
- Funcoes RPC.
- Politicas RLS.
- Seed seguro de demonstracao.

## Edge Functions

Funcoes criadas:

- `create-emergency-alert`
- `update-alert-location`
- `close-emergency-alert`
- `create-tracking-link`
- `open-tracking-link`
- `acknowledge-alert`
- `get-public-alerts-in-bounds`
- `send-alert-notifications`
- `admin-manage-support-point`

Essas funcoes centralizam operacoes sensiveis e ajudam a proteger regras de negocio que nao devem ficar apenas no frontend.

## Seguranca

Principios aplicados:

- Nunca colocar `service_role key` no frontend.
- Ativar RLS em todas as tabelas.
- Proteger localizacao exata.
- Armazenar tokens apenas com hash.
- Usar links com expiracao e revogacao.
- Nao expor telefone, e-mail ou nome completo em consultas publicas.
- Registrar operacoes administrativas em audit log.
- Consultar mapa publico por funcao controlada.
- Evitar cache de dados sensiveis na PWA.

Antes de producao, revise `SECURITY.md` e execute auditoria completa.

## Acessibilidade e responsividade

O projeto foi pensado para atender, quando possivel, WCAG 2.1 AA:

- Contraste adequado.
- Areas de toque grandes.
- Labels semanticos.
- Navegacao por teclado.
- Foco visivel.
- Mensagens claras.
- Layout adaptado para celular, tablet e desktop.

No celular, a navegacao principal usa barra inferior. No desktop, a interface usa navegacao lateral e composicoes mais amplas.

## Como rodar localmente

Instale Flutter estavel, configure Supabase e rode:

```bash
cp .env.example .env
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
flutter test
flutter analyze
flutter build web --release
```

Tambem e possivel usar variaveis via `--dart-define`:

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-public-anon-key
```

## Configuracao Supabase

1. Crie um projeto no Supabase.
2. Copie `Project URL` para `SUPABASE_URL`.
3. Copie a `anon public key` para `SUPABASE_ANON_KEY`.
4. Nunca coloque a `service_role key` no Flutter.
5. Aplique as migrations.
6. Rode o seed apenas em ambiente seguro.

```bash
supabase db push
supabase db execute --file supabase/seed/seed.sql
```

Para rodar Edge Functions localmente:

```bash
supabase start
supabase functions serve --env-file supabase/.env.local
```

## Deploy

O projeto inclui `netlify.toml` e `build.sh` para deploy na Netlify.

Fluxo de build:

```bash
bash build.sh
```

O script instala Flutter no ambiente da Netlify, habilita web e gera:

```bash
flutter build web --release --csp --no-web-resources-cdn
```

Arquivos PWA:

- `web/manifest.json`
- `web/offline.html`
- `web/sw.js`
- `web/icons/Icon-192.png`
- `web/icons/Icon-512.png`

## Limitacoes conhecidas

- PWA nao garante rastreamento continuo quando o navegador esta fechado.
- Push notifications variam por navegador e sistema operacional.
- Ligacoes `tel:` podem nao funcionar em computadores.
- O modo temporario e apenas demonstrativo.
- Pontos de apoio reais exigem verificacao humana.
- Uso real exige revisao tecnica, juridica, operacional e de privacidade.

## Checklist antes do uso real

- Rodar `flutter analyze`.
- Rodar `flutter test`.
- Rodar `flutter build web --release`.
- Testar fluxo completo de alerta.
- Revisar todas as policies RLS.
- Confirmar que nenhuma chave secreta esta no frontend.
- Confirmar que localizacao exata nao aparece no mapa publico.
- Validar expiracao e revogacao de links.
- Revisar textos de notificacao em modo discreto.
- Revisar dominio, CORS, HTTPS e headers de seguranca.
- Validar conteudos com especialistas da rede de atendimento.

## Licenca

Este projeto e open source sob licenca MIT.

## Creditos

Projeto idealizado e desenvolvido por:

```text
ConderTech
A desenvolvedora
```

Assinado por **ConderTech**, a desenvolvedora.
