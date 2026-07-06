# Posts API

Endpoint JSON público que expõe todos os posts publicados do jblog para consumo
server-to-server (ex: seção "blog" do portfólio jfolio-web via Next.js Route Handler
com `revalidate`).

## Endpoint

```
GET /api/posts
```

Sem autenticação. Sem CORS (o consumo é server-to-server).

### Query parameters

| Parâmetro | Tipo    | Obrigatório | Descrição                          |
|-----------|---------|-------------|------------------------------------|
| `limit`   | integer | não         | Limita a quantidade de posts retornados. Se omitido, retorna todos os publicados. |

Exemplo: `GET /api/posts?limit=3`

## Response

**Status:** `200 OK`
**Content-Type:** `application/json`
**Cache-Control:** `public, max-age=300`

### Shape

```jsonc
[
  {
    "slug": "escondendo-a-api-key-com-bff",
    "title": "Escondendo a API key com um BFF no Next.js",
    "excerpt": "Como proteger chaves de API usando um Backend-for-Frontend no Next.js…",
    "url": "https://jblog.devarthur.com.br/posts/escondendo-a-api-key-com-bff",
    "publishedAt": "2026-06-24",
    "readingTimeMinutes": 6,
    "tags": []
  }
]
```

### Campos

| Campo              | Tipo     | Descrição                                                                 |
|--------------------|----------|---------------------------------------------------------------------------|
| `slug`             | string   | Identificador URL-friendly do post.                                       |
| `title`            | string   | Título do post.                                                           |
| `excerpt`          | string   | Resumo em texto puro (sem markdown), derivado do primeiro parágrafo do post. Máximo 200 caracteres, truncado em limite de palavra. |
| `url`              | string   | URL absoluta do post (inclui scheme + host).                              |
| `publishedAt`      | string   | Data de publicação em ISO-8601 (`YYYY-MM-DD`).                            |
| `readingTimeMinutes` | integer | Tempo estimado de leitura em minutos. Calculado por contagem de palavras (~200 palavras/min), mínimo 1. |
| `tags`             | string[] | Array de tags. Atualmente sempre `[]` (o modelo não possui campo de tags). |

### Regras

- **Ordenação:** `publishedAt` descendente (mais recente primeiro).
- **camelCase:** todos os campos usam camelCase (`publishedAt`, `readingTimeMinutes`).
- **Rascunhos excluídos:** apenas posts com `published: true` são retornados.
- **`excerpt`:** texto puro, sem formatação markdown. Se o primeiro parágrafo exceder 200 caracteres, é truncado no último espaço antes do limite.
- **`url`:** sempre absoluta. Em produção: `https://jblog.devarthur.com.br/posts/{slug}`. Em desenvolvimento: `http://localhost:3000/posts/{slug}`.

## Exemplo de resposta real

```json
[
  {
    "slug": "post-publicado",
    "title": "Post publicado",
    "excerpt": "Conteúdo do post publicado.",
    "url": "http://localhost:3000/posts/post-publicado",
    "publishedAt": "2026-07-05",
    "readingTimeMinutes": 1,
    "tags": []
  }
]
```

## Consumo no jfolio-web (Next.js)

```ts
// app/api/blog/route.ts (Route Handler BFF)
import { NextResponse } from "next/server";

export const revalidate = 300;

interface BlogPost {
  slug: string;
  title: string;
  excerpt: string;
  url: string;
  publishedAt: string;
  readingTimeMinutes: number;
  tags: string[];
}

export async function GET() {
  const res = await fetch(`${process.env.JBLOG_URL}/api/posts?limit=3`);
  const posts: BlogPost[] = await res.json();
  return NextResponse.json(posts.slice(0, 3));
}
```
