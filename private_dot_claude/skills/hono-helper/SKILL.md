---
name: hono-helper
description: |
  This skill should be used when the user works with Hono, builds APIs, creates middleware,
  uses Zod validation with Hono, or mentions Hono patterns. Provides guidance for the Hono
  web framework including routing, middleware, validation, and multi-runtime support.
version: 1.0.0
---

# Hono Helper Agent

## What's New in Hono (2025)

- **Multi-runtime**: Runs on Bun, Node.js, Deno, Cloudflare Workers, AWS Lambda, Vercel
- **RPC mode**: End-to-end type safety with `hc` client
- **Zod OpenAPI**: Generate OpenAPI specs from Zod schemas
- **Streaming**: First-class streaming response support
- **JSX middleware**: Server-side JSX rendering
- **Performance**: One of the fastest web frameworks (Bun benchmark leader)

## Installation

```bash
# For Bun
bun add hono

# For Node.js
npm install hono @hono/node-server

# For Cloudflare Workers
npm install hono
```

## Basic Application

### Bun Setup

```typescript
import { Hono } from "hono";

const app = new Hono();

app.get("/", (c) => c.text("Hello Hono!"));

export default app;
```

Bun automatically serves the default export on port 3000.

### Node.js Setup

```typescript
import { Hono } from "hono";
import { serve } from "@hono/node-server";

const app = new Hono();

app.get("/", (c) => c.text("Hello Hono!"));

serve({ fetch: app.fetch, port: 3000 });
```

## Routing

### HTTP Methods

```typescript
app.get("/users", (c) => c.json({ users: [] }));
app.post("/users", (c) => c.json({ created: true }));
app.put("/users/:id", (c) => c.json({ updated: true }));
app.patch("/users/:id", (c) => c.json({ patched: true }));
app.delete("/users/:id", (c) => c.json({ deleted: true }));

// All methods
app.all("/any", (c) => c.text("Any method"));

// Multiple methods
app.on(["GET", "POST"], "/multi", (c) => c.text("GET or POST"));
```

### Path Parameters

```typescript
// Single parameter
app.get("/users/:id", (c) => {
  const id = c.req.param("id");
  return c.json({ id });
});

// Multiple parameters
app.get("/posts/:postId/comments/:commentId", (c) => {
  const { postId, commentId } = c.req.param();
  return c.json({ postId, commentId });
});

// Optional parameter
app.get("/articles/:id?", (c) => {
  const id = c.req.param("id") ?? "default";
  return c.json({ id });
});
```

### Wildcards

```typescript
// Wildcard - matches any path segment
app.get("/files/*", (c) => {
  const path = c.req.path;
  return c.text(`File path: ${path}`);
});

// Regex constraint
app.get("/users/:id{[0-9]+}", (c) => {
  const id = c.req.param("id"); // Guaranteed to be numeric
  return c.json({ id: Number(id) });
});
```

### Route Grouping

```typescript
const api = new Hono();

api.get("/users", (c) => c.json({ users: [] }));
api.get("/posts", (c) => c.json({ posts: [] }));

const app = new Hono();
app.route("/api/v1", api);

// Routes: GET /api/v1/users, GET /api/v1/posts
```

### Chained Routes

```typescript
app
  .get("/endpoint", (c) => c.text("GET"))
  .post((c) => c.text("POST"))
  .put((c) => c.text("PUT"));
```

## Context API

The `c` (context) object provides request/response utilities:

### Request Access

```typescript
app.get("/info", (c) => {
  // URL and path
  const url = c.req.url;
  const path = c.req.path;
  const method = c.req.method;

  // Query parameters
  const page = c.req.query("page");
  const allQueries = c.req.queries("tag"); // Array for repeated params

  // Headers
  const auth = c.req.header("Authorization");
  const allHeaders = c.req.header(); // All headers

  return c.json({ url, path, method, page, auth });
});
```

### Body Parsing

```typescript
app.post("/data", async (c) => {
  // JSON body
  const json = await c.req.json();

  // Form data
  const form = await c.req.parseBody();

  // Raw text
  const text = await c.req.text();

  // Array buffer
  const buffer = await c.req.arrayBuffer();

  return c.json({ received: true });
});
```

### Response Methods

```typescript
// Text response
app.get("/text", (c) => c.text("Plain text"));

// JSON response
app.get("/json", (c) => c.json({ message: "Hello" }));

// HTML response
app.get("/html", (c) => c.html("<h1>Hello</h1>"));

// Custom status
app.get("/created", (c) => c.json({ id: 1 }, 201));

// Redirect
app.get("/old", (c) => c.redirect("/new"));
app.get("/permanent", (c) => c.redirect("/new", 301));

// Not found
app.get("/missing", (c) => c.notFound());

// Stream response
app.get("/stream", (c) => {
  return c.streamText(async (stream) => {
    await stream.write("Hello ");
    await stream.write("World!");
  });
});
```

### Headers and Status

```typescript
app.get("/custom", (c) => {
  // Set response headers
  c.header("X-Custom-Header", "value");
  c.header("Cache-Control", "max-age=3600");

  // Set status
  c.status(201);

  return c.json({ created: true });
});

// Response with headers inline
app.get("/inline", (c) => {
  return c.json(
    { data: "value" },
    200,
    { "X-Custom": "header" }
  );
});
```

### Context Variables

```typescript
// Set variables for downstream handlers
app.use(async (c, next) => {
  c.set("userId", "user-123");
  c.set("requestTime", Date.now());
  await next();
});

app.get("/profile", (c) => {
  const userId = c.get("userId");
  const requestTime = c.get("requestTime");
  return c.json({ userId, requestTime });
});
```

## Validation with Zod

### Setup

```bash
bun add @hono/zod-validator zod
```

### Request Validation

```typescript
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";

const CreateUserSchema = z.object({
  name: z.string().min(1),
  email: z.string().email(),
  age: z.number().int().positive().optional(),
});

app.post(
  "/users",
  zValidator("json", CreateUserSchema),
  (c) => {
    const data = c.req.valid("json");
    // data is typed: { name: string; email: string; age?: number }
    return c.json({ created: data });
  }
);
```

### Multiple Validators

```typescript
const QuerySchema = z.object({
  page: z.coerce.number().default(1),
  limit: z.coerce.number().default(10),
});

const ParamSchema = z.object({
  id: z.string().uuid(),
});

app.get(
  "/users/:id",
  zValidator("param", ParamSchema),
  zValidator("query", QuerySchema),
  (c) => {
    const { id } = c.req.valid("param");
    const { page, limit } = c.req.valid("query");
    return c.json({ id, page, limit });
  }
);
```

### Validation Targets

```typescript
// JSON body
zValidator("json", schema)

// Query parameters
zValidator("query", schema)

// URL parameters
zValidator("param", schema)

// Form data
zValidator("form", schema)

// Headers
zValidator("header", schema)

// Cookies
zValidator("cookie", schema)
```

### Custom Error Handling

```typescript
app.post(
  "/users",
  zValidator("json", CreateUserSchema, (result, c) => {
    if (!result.success) {
      return c.json({
        error: "Validation failed",
        issues: result.error.issues,
      }, 400);
    }
  }),
  (c) => {
    const data = c.req.valid("json");
    return c.json({ created: data });
  }
);
```

## Best Practices Summary

1. **Use route grouping** to organize related endpoints
2. **Apply middleware at appropriate scopes** - global vs path-specific
3. **Validate all inputs** with Zod validators
4. **Handle errors globally** with `app.onError()`
5. **Use typed RPC client** for frontend-backend type safety
6. **Test with `app.request()`** for fast, isolated tests
7. **Export `AppType`** for end-to-end type inference
8. **Use factory pattern** for configurable middleware
9. **Set security headers** with `secureHeaders()` middleware
10. **Keep handlers thin** - delegate to service functions

## When to Ask for Help

- WebSocket integration patterns
- Complex authentication flows (OAuth, SAML)
- Streaming and SSE implementations
- Edge runtime-specific configurations
- GraphQL integration with Hono
- Performance optimization for high-traffic APIs

## Additional Resources

For more detailed patterns and examples, see the reference files:

- **[references/middleware-patterns.md](references/middleware-patterns.md)** - Inline/path-specific/factory middleware, built-in middleware, error handling (global handler, HTTP exceptions, not found), common patterns (API versioning, request ID, database integration, authentication), and static files (Bun)
- **[references/openapi-rpc.md](references/openapi-rpc.md)** - Type-safe RPC client (server setup, client usage), testing (app.request(), testClient), and OpenAPI integration (setup, route definitions with Zod OpenAPI, Swagger UI)
