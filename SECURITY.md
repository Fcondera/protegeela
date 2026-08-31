# Política de segurança

Não publique vulnerabilidades em issues públicas quando elas envolverem:

- Bypass de autenticação ou RLS.
- Exposição de localização exata.
- Vazamento de contatos, telefones, e-mails ou tokens.
- Falhas em links de acompanhamento.
- Elevação indevida para administrador.

Relate de forma privada aos mantenedores do projeto. Até que um canal público do projeto exista, use um contato privado da organização responsável pelo deploy.

Antes de produção, revise o checklist de segurança em `README.md` e rode os testes de banco em `test/supabase`.
