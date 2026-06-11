# CLAUDE.md

Guia para trabalhar neste repositório. Leia antes de gerar ou alterar código.

## O que é

O **jblog** é um blog pessoal de Markdown. Posts são escritos em Markdown, guardados no Postgres,
renderizados para HTML no momento de salvar e servidos como leitura pública.
Tem busca full-text e um painel administrativo para publicar.

Deploy em `jblog.devarthur.com.br` na VPS Hostinger KVM2, via Cloudflare Tunnel.

## Stack

- Ruby on Rails 8 (Puma)
- PostgreSQL — busca full-text com `pg_search` + `pg_trgm`
- commonmarker (Markdown → HTML) + rouge (syntax highlight)
- Autenticação nativa do Rails 8
- Deploy com Kamal 2 + Docker

## Princípio central de arquitetura

**Renderização no write, não no read.** O Markdown é convertido para HTML quando o
post é salvo, e o HTML fica persistido em `body_html`. A leitura pública apenas serve
HTML pronto — nunca parseia Markdown em tempo de request. Isso mantém a leitura rápida
e o processo leve.

## Estrutura

Segue as convenções padrão do Rails. Pontos que importam:

```
app/
├── models/
│   └── post.rb            # modelo Post; dispara a renderização no callback de save
├── controllers/
│   ├── posts_controller.rb    # leitura pública (lista, post individual)
│   ├── search_controller.rb   # busca full-text
│   └── admin/
│       └── posts_controller.rb # CRUD administrativo (a ferramenta de publicação)
├── services/
│   └── markdown_renderer.rb   # commonmarker + rouge isolados aqui
└── views/
    ├── posts/            # home e página de post
    ├── search/           # resultados
    └── admin/posts/      # formulário com campo Markdown e preview
```

## Modelo de dados

Tabela `posts`:

- `title` (string)
- `slug` (string, único, indexado) — usado na URL
- `body_markdown` (text) — fonte original
- `body_html` (text) — HTML renderizado, gerado no save
- `published` (boolean) — false = rascunho
- `published_at` (datetime)
- timestamps

Índice full-text sobre `title` + `body_markdown` para a busca.

## Rotas

Públicas:
- `GET /` — posts publicados, mais recentes primeiro
- `GET /posts/:slug` — um post
- `GET /search?q=` — busca

Administrativas (autenticadas, sob `/admin`):
- CRUD completo de posts (`new`, `create`, `edit`, `update`, `destroy`, `index`)

## Fluxos importantes

**Publicar um post:** admin preenche o formulário → `body_markdown` é salvo →
callback no modelo chama `MarkdownRenderer` → `body_html` é preenchido →
post fica disponível na leitura pública se `published` for true.

**Buscar:** `SearchController` recebe `q`, consulta via `pg_search` sobre
`title` + `body_markdown`, retorna posts publicados ordenados por relevância.

---

# Regras de código

Estas regras têm prioridade. Legibilidade e manutenibilidade vêm antes de esperteza.

## Evite abstrações

Não crie camadas, módulos ou objetos "por precaução" ou para antecipar
necessidades que ainda não existem. Escreva o código mais direto que resolve o
problema atual. Uma abstração só se justifica quando há repetição real e concreta,
não hipotética. Código duplicado duas vezes é aceitável; abstração prematura não é.

Prefira o caminho explícito do Rails ao "esperto". Se um controller resolve, não
invente um service. (O `MarkdownRenderer` existe porque isola uma dependência
externa real — esse é o tipo de separação que se justifica.)

## Nomes descrevem o que a coisa é

Nada de variáveis de uma letra para representar conceitos do domínio. Errado: `f`
para formulário, `p` para post, `r` para resultado. Certo: `form`, `post`,
`search_results`. O nome deve dizer o que a variável contém sem o leitor precisar
rastrear de onde ela veio.

Exceção única e óbvia: índices triviais de laço (`i`, `j`) e o bloco idiomático do
Rails em views (`form_with do |form|` — aqui escreva `form`, não `f`).

## Legibilidade e manutenibilidade são prioridade

- Funções e métodos curtos, com uma responsabilidade clara.
- Prefira early return a aninhar `if`s.
- Evite encadeamentos longos e densos que exijam reler três vezes. Quebre em passos
  com nomes.
- Não economize linhas às custas de clareza. Código é lido muito mais vezes do que
  é escrito.
- Se um trecho só faz sentido com contexto, esse contexto vira nome de método ou
  comentário — não fica implícito.

## Comentários

Comente o **porquê**, não o **o quê**. Não comente o óbvio (`# incrementa contador`).

Comente quando agregar entendimento real:
- Em métodos "core" ou centrais ao funcionamento do blog (ex.: o callback de
  renderização, a montagem da query de busca).
- Em trechos genuinamente difíceis ou não óbvios — uma decisão de negócio, uma
  pegadinha do Postgres com acentuação em PT-BR, um workaround.

Se o código é simples e o nome já explica, não comente.

## Padrões do Rails

- Siga as convenções do Rails. Não lute contra o framework.
- Strong parameters sempre nos controllers.
- Lógica de domínio no modelo, não no controller.
- Nada de SQL cru onde o Active Record resolve de forma legível (busca full-text via
  `pg_search` é a exceção esperada).

---

## Deploy

- Imagem Docker pelo Dockerfile padrão do Rails 8.
- Kamal 2 aponta para a KVM2 (`srv1722738`).
- Postgres como serviço dedicado na VPS.
- Ingress: Cloudflare Tunnel → container Puma. Não abrir portas na VPS.

## Antes de finalizar qualquer alteração

- O código está legível para alguém que abre o arquivo pela primeira vez?
- Há abstração que dá para remover sem perder clareza?
- Os nomes dizem o que as coisas são?
- Os comentários explicam porquês, não óbvios?
