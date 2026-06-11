# jblog

Blog pessoal de Markdown em Ruby on Rails 8. Posts são escritos em Markdown,
guardados no Postgres, renderizados para HTML no momento de salvar e servidos
como leitura pública. Tem busca full-text (`pg_search`) e um painel admin para
publicar. Deploy em `jblog.devarthur.com.br` (VPS Hostinger KVM2, via Cloudflare
Tunnel + Kamal 2).

## Setup

```bash
bundle install
bin/rails db:create db:migrate
bin/rails server          # http://localhost:3000
```

## Build / Test / Lint

```bash
bin/rails test            # suíte de testes
bin/rails test test/models/post_test.rb   # um arquivo
bin/rubocop               # lint (rubocop-rails-omakase, padrão do Rails 8)
bin/rubocop -a            # auto-corrige o que for seguro
bin/rails db:migrate      # aplica migrations pendentes
```

Rode `bin/rubocop` e `bin/rails test` antes de finalizar qualquer alteração.

## Project Structure

- `app/models/post.rb` — modelo `Post`; dispara a renderização Markdown no save.
- `app/services/markdown_renderer.rb` — commonmarker + rouge isolados aqui.
- `app/controllers/posts_controller.rb` — leitura pública (lista, post por slug).
- `app/controllers/search_controller.rb` — busca full-text via `pg_search`.
- `app/controllers/admin/posts_controller.rb` — CRUD admin (ferramenta de publicação).
- `app/views/posts/`, `search/`, `admin/posts/` — telas públicas e o formulário admin.
- `config/deploy.yml` — configuração do Kamal (deploy na KVM2).

Convenções padrão do Rails. Onde os nomes de arquivo não bastam, o detalhe está abaixo.

## Architecture

**Renderização no write, não no read.** O Markdown vira HTML quando o post é salvo;
o HTML fica persistido em `posts.body_html`. A leitura pública só serve HTML pronto —
nunca parseia Markdown em request. Mantém a leitura rápida e o processo leve.

**Busca.** `SearchController` consulta `pg_search` sobre `title` + `body_markdown`,
retorna apenas posts publicados, ordenados por relevância. Atenção a acentuação
PT-BR na configuração do índice (ver gotchas).

Modelo `posts`: `title`, `slug` (único, na URL), `body_markdown` (fonte),
`body_html` (renderizado no save), `published` (bool), `published_at`, timestamps.

## Code Standards

- **Evite abstrações.** Escreva o código mais direto que resolve o problema atual.
  Nada de camadas ou objetos preventivos para necessidades hipotéticas. Abstração só
  com repetição real e concreta. Prefira o caminho explícito do Rails ao "esperto":
  se um controller resolve, não invente um service. (`MarkdownRenderer` é exceção
  justificada — isola dependência externa real.)
- **Nomes descrevem o que a coisa é.** Proibido variável de uma letra para conceito
  de domínio: nada de `f` para formulário, `p` para post, `r` para resultado. Use
  `form`, `post`, `search_results`. Exceção: índices triviais de laço (`i`, `j`) e o
  bloco idiomático `form_with do |form|`.
- **Legibilidade e manutenibilidade são prioridade.** Métodos curtos com uma
  responsabilidade. Prefira early return a `if` aninhado. Quebre encadeamentos densos
  em passos com nome. Não economize linhas às custas de clareza.
- **Comentários explicam o porquê, não o quê.** Não comente o óbvio. Comente métodos
  core (callback de renderização, montagem da query de busca) e trechos genuinamente
  difíceis ou não óbvios (decisão de negócio, pegadinha do Postgres, workaround).
- **Padrões do Rails.** Não lute contra o framework. Strong parameters sempre. Lógica
  de domínio no modelo, não no controller. Nada de SQL cru onde o Active Record
  resolve de forma legível (`pg_search` é a exceção esperada).

## Gotchas

- **Acentuação PT-BR na busca.** `tsvector` com dicionário do Postgres tem pegadinhas
  de stemming/acento em português. Avaliar `pg_trgm` (similaridade) vs. dicionário
  configurado antes de fixar o índice. Decisão ainda aberta.
- **Renderização sincronizada.** Se `body_markdown` muda, `body_html` precisa ser
  regerado no mesmo save. Nunca deixe os dois fora de sincronia.
- **Deploy.** Ingress só via Cloudflare Tunnel → container Puma. Não abrir portas na
  VPS. Postgres é serviço dedicado na KVM2.

## Manutenção deste arquivo

Mantenha o AGENTS.md atualizado quando mudanças no código exigirem.
