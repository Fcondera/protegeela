insert into public.emergency_services (name, phone, description, region, is_active)
values ('Servico demonstrativo - substitua antes da producao', '000', 'Numero ficticio para testes locais. Configure servicos reais pelo painel administrativo.', 'demo', true)
on conflict (name, region) do nothing;

insert into public.support_points (name, category, description, address, city, state, latitude, longitude, phone, opening_hours, accessibility_info, is_verified)
values
  ('Ponto de apoio demonstrativo ficticio', 'support_center', 'Dado ficticio para validar interface. Nao representa uma unidade real.', 'Endereco ficticio, 100', 'Cidade Demo', 'AM', -3.1190, -60.0217, null, 'Horario ficticio', 'Informacao ficticia', false)
on conflict do nothing;

insert into public.safety_contents (title, summary, content, category, is_published)
values
  ('Como montar uma rede de apoio', 'Escolha pessoas de confianca e combine sinais claros.', 'Converse em um momento seguro, explique o que voce espera de cada pessoa e revise periodicamente suas permissoes de compartilhamento.', 'support_network', true),
  ('Como compartilhar localizacao', 'Use compartilhamento apenas com pessoas autorizadas.', 'Durante um alerta, a localizacao exata deve ser limitada a contatos de confianca. O mapa publico mostra apenas areas aproximadas.', 'location', true),
  ('Como proteger a conta e o dispositivo', 'Use senha forte e bloqueio de tela.', 'Ative bloqueio do aparelho, evite compartilhar senhas e revise notificacoes discretas se houver risco de alguem observar sua tela.', 'account_security', true)
on conflict do nothing;
