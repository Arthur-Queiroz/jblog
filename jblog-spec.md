# jblog — Documento de Projeto

**Projeto:** jblog — blog pessoal com publicação em Markdown
**Autor:** Arthur
**Domínio:** `jblog.devarthur.com.br`
**Status:** Especificação inicial
**Última atualização:** 11 de junho de 2026

---

## 1. Visão geral

O **jblog** é um blog pessoal onde os posts são escritos em Markdown, armazenados em banco de dados e renderizados como HTML para leitura pública. O sistema oferece busca full-text sobre o conteúdo dos posts e um painel administrativo para criar, editar e publicar conteúdo com facilidade.

A aplicação é deliberadamente leve: um único processo, um único banco, um único deploy. A escolha do Rails se justifica por o blog ser o caso de uso fundador do framework — o CRUD de conteúdo, o painel de administração e a renderização de Markdown são resolvidos por caminhos convencionais e maduros, sem necessidade de construir ferramentas auxiliares do zero.

---

## 2. Requisitos

### 2.1 Requisitos funcionais

| ID | Requisito | Prioridade |
|----|-----------|------------|
| RF1 | Criar, editar e publicar posts escritos em Markdown | Alta |
| RF2 | Renderizar Markdown em HTML para leitura pública, com syntax highlight em blocos de código | Alta |
| RF3 | Listar posts publicados na home, ordenados por data | Alta |
| RF4 | Exibir um post individual em página própria via slug | Alta |
| RF5 | Buscar posts anteriores por termo (full-text sobre título e conteúdo) | Alta |
| RF6 | Painel administrativo protegido para gerenciar posts (a "ferramenta auxiliar" de publicação) | Alta |
| RF7 | Distinguir entre rascunho e post publicado | Média |
| RF8 | Preview do Markdown renderizado antes de publicar | Média |

### 2.2 Requisitos não funcionais

| ID | Requisito |
|----|-----------|
| RNF1 | Leitura pública rápida — HTML pré-renderizado, sem parse de Markdown em tempo de leitura |
| RNF2 | Aplicação leve, com baixo consumo de memória e CPU |
| RNF3 | SEO adequado — HTML server-side, URLs limpas por slug |
| RNF4 | Deploy reprodutível e simples de manter |
| RNF5 | Acesso administrativo restrito ao autor |

---

## 3. Stack tecnológica

| Camada | Tecnologia | Justificativa |
|--------|------------|---------------|
| Framework | **Ruby on Rails 8** | Blog é o caso de uso canônico; scaffold entrega o painel de publicação praticamente pronto |
| Linguagem | **Ruby 3.x** | — |
| Banco de dados | **PostgreSQL** | Full-text search nativo via `pg_search` + `pg_trgm`, sem serviço externo |
| Renderização Markdown | **commonmarker** | Parser CommonMark performático; renderiza no save, HTML guardado no banco |
| Syntax highlight | **rouge** | Highlight de blocos de código no momento da renderização |
| Autenticação | **Rails 8 authentication** (generator nativo) | Autenticação built-in do Rails 8; suficiente para um autor único |
| Servidor de aplicação | **Puma** | Padrão do Rails |
| Deploy | **Kamal 2** | Ferramenta oficial do Rails 8; deploy para VPS com um comando |
| Containerização | **Docker** | Imagem gerada pelo Dockerfile padrão do Rails 8 |
| Reverse proxy / TLS | **Cloudflare Tunnel** | Já em uso na infraestrutura; expõe o subdomínio sem abrir portas |

### 3.1 Decisão de arquitetura: renderização no write

O Markdown é parseado e convertido para HTML **no momento de salvar o post**, não na leitura. O HTML resultante é persistido em coluna própria no banco. A leitura pública fica "burra" e rápida: apenas serve o HTML já pronto. Isso atende RNF1 e RNF2.

### 3.2 Decisão de arquitetura: busca

A busca full-text usa recursos nativos do PostgreSQL (`pg_search` apoiado em `pg_trgm`/`tsvector`), eliminando a necessidade de infraestrutura externa como Elasticsearch. Isso mantém a aplicação em um único processo e um único banco, alinhado ao requisito de menor complexidade possível.

---

## 4. Modelo de dados (preliminar)

### Tabela `posts`

| Coluna | Tipo | Notas |
|--------|------|-------|
| `id` | bigint | PK |
| `title` | string | Título do post |
| `slug` | string | Único, indexado; usado na URL |
| `body_markdown` | text | Fonte original em Markdown |
| `body_html` | text | HTML renderizado (gerado no save) |
| `published` | boolean | `false` = rascunho, `true` = publicado |
| `published_at` | datetime | Data de publicação |
| `created_at` | datetime | — |
| `updated_at` | datetime | — |

Índices: `slug` (único), índice full-text sobre `title` + `body_markdown` para a busca.

---

## 5. Rotas (preliminar)

### Públicas

| Método | Rota | Ação |
|--------|------|------|
| GET | `/` | Lista de posts publicados |
| GET | `/posts/:slug` | Exibe um post |
| GET | `/search?q=termo` | Resultados da busca |

### Administrativas (autenticadas)

| Método | Rota | Ação |
|--------|------|------|
| GET | `/admin/posts` | Lista todos os posts (inclui rascunhos) |
| GET | `/admin/posts/new` | Formulário de novo post |
| POST | `/admin/posts` | Cria post |
| GET | `/admin/posts/:id/edit` | Formulário de edição |
| PATCH | `/admin/posts/:id` | Atualiza post |
| DELETE | `/admin/posts/:id` | Remove post |

A área `/admin` constitui a ferramenta de publicação: formulário com campo Markdown, preview e controle de rascunho/publicado, acessível pelo navegador de qualquer lugar.

---

## 6. Deploy

### 6.1 Destino

O deploy será feito na **VPS Hostinger KVM2** (`srv1722738`, datacenter São Paulo), que possui folga de memória e processamento em relação às cargas atuais (n8n, Evolution API, bancos). Por ser uma aplicação leve, o blog coexiste confortavelmente com os serviços já hospedados.

### 6.2 Domínio

Exposto em **`jblog.devarthur.com.br`** através do **Cloudflare Tunnel** já configurado na VPS, sem necessidade de abrir portas adicionais nem gerenciar TLS manualmente — o tunnel entrega o tráfego ao container do Puma.

### 6.3 Estratégia

- Imagem Docker gerada pelo Dockerfile padrão do Rails 8.
- Orquestração de deploy via **Kamal 2** apontando para a KVM2.
- PostgreSQL como serviço dedicado (container ou instância já existente na VPS).
- Roteamento: Cloudflare Tunnel → container do blog (Puma).

### 6.4 Topologia

```
Internet
   │
   ▼
Cloudflare (jblog.devarthur.com.br)
   │  (Cloudflare Tunnel)
   ▼
VPS Hostinger KVM2 (srv1722738)
   │
   ├── Container: blog (Rails + Puma)
   │        │
   │        ▼
   └── PostgreSQL
```

---

## 7. Próximos passos

1. Definir o esquema final do modelo `Post` e gerar a migration.
2. Configurar `pg_search` e validar a qualidade da busca em português.
3. Implementar a renderização Markdown → HTML no callback de save (commonmarker + rouge).
4. Gerar o scaffold administrativo e proteger a área `/admin` com a autenticação nativa.
5. Definir o layout público (home, post, busca).
6. Configurar Kamal e o ingress via Cloudflare Tunnel na KVM2.
