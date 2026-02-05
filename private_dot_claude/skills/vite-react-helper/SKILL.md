---
name: vite-react-helper
description: |
  This skill should be used when the user works with Vite, React, creates components, manages state, uses hooks, or configures Vite builds. Provides guidance on Vite + React development including build config, HMR, hooks, state management, and performance patterns.
version: 1.0.0
---

# Vite + React Helper Agent

## What's New (2025)

### Vite
- **Rolldown preview**: Rust-based bundler for faster builds
- **Environment API**: Unified dev/build environment handling
- **Text-based lockfile**: Better dependency tracking
- **Node.js 20.19+** required

### React 19
- **React Compiler**: Automatic memoization (experimental)
- **`use()` hook**: Read promises and context in render
- **Actions**: Simplified async mutations
- **Server Components**: First-class RSC support
- **Document metadata**: Native `<title>`, `<meta>` in components

## Project Setup

### Create New Project

```bash
# npm
npm create vite@latest my-app -- --template react-ts

# Bun
bun create vite my-app --template react-ts

cd my-app
npm install  # or bun install
npm run dev
```

### Templates Available

| Template | Description |
|----------|-------------|
| `react` | React with JavaScript |
| `react-ts` | React with TypeScript |
| `react-swc` | React + SWC (faster builds) |
| `react-swc-ts` | React + SWC + TypeScript |

## Vite Configuration

Configure Vite with `defineConfig` in `vite.config.ts`. Key areas: plugin setup (Babel or SWC), server options (`port`, `open`), build output (`outDir`, `sourcemap`), environment variables (`VITE_` prefix), and path aliases (`@/` mapping to `src/`). Use the SWC plugin (`@vitejs/plugin-react-swc`) for faster dev builds. Environment variables are accessed via `import.meta.env` and require TypeScript definitions in `vite-env.d.ts`.

See [references/build-config.md](references/build-config.md) for full configuration examples including plugin options, SWC setup, env vars, and path aliases.

## React Core Patterns

Build components with TypeScript interfaces for props. Use `useState` for simple state, `useReducer` for complex state machines. Effects (`useEffect`) handle side effects with cleanup functions to prevent leaks. `useRef` provides direct DOM access. `createContext` + `useContext` enables global state without prop drilling -- always wrap with a custom hook that validates the provider exists.

See [references/react-patterns.md](references/react-patterns.md) for typed component examples, state patterns, effects, refs, context, custom hooks (data fetching, local storage, debounce), form handling, and error boundaries.

## Performance Optimization

Key techniques: `useMemo` for expensive calculations, `useCallback` + `memo` for stable references that prevent child re-renders, `lazy()` + `Suspense` for code splitting components and routes. Split routes with `React.lazy(() => import('./pages/Page'))` inside a `Suspense` boundary.

See [references/build-config.md](references/build-config.md) for useMemo, useCallback, lazy loading, and code splitting examples.

## Build Optimization

Use `manualChunks` in Rollup options to split vendor bundles (react-vendor, router, UI libs). Analyze bundles with `rollup-plugin-visualizer`. Production config: target `esnext`, enable `cssCodeSplit`, set `chunkSizeWarningLimit` to catch bloat early.

See [references/build-config.md](references/build-config.md) for chunk splitting, bundle analysis, and production optimization configs.

## Testing

Use Vitest with `jsdom` environment and `@testing-library/react`. Configure in `vite.config.ts` under `test` key with `globals: true` and a setup file importing `@testing-library/jest-dom`. Test components with `render`, `screen`, `fireEvent`, and `vi.fn()` for mocks.

See [references/build-config.md](references/build-config.md) for Vitest configuration and component testing examples.

## Best Practices Summary

1. **Use TypeScript** for type safety and better DX
2. **Avoid unnecessary state** - derive values when possible
3. **Use keys correctly** - unique, stable identifiers for lists
4. **Clean up effects** - prevent memory leaks and stale closures
5. **Memoize expensive operations** with `useMemo` and `useCallback`
6. **Lazy load routes and heavy components** with `lazy()` and `Suspense`
7. **Extract reusable logic** into custom hooks
8. **Use SWC plugin** for faster development builds
9. **Configure chunk splitting** for optimal caching
10. **Test components** with React Testing Library

## When to Ask for Help

- Server-side rendering (SSR) setup and hydration issues
- React Server Components integration
- Complex animation orchestration
- State management library selection (Zustand, Jotai, Redux)
- Performance profiling and optimization
- Micro-frontend architectures with Vite

## Additional Resources

- **[references/react-patterns.md](references/react-patterns.md)** - React core patterns (components, state, effects, refs, context), custom hooks (useFetch, useLocalStorage, useDebounce), form handling, and error boundaries
- **[references/build-config.md](references/build-config.md)** - Vite configuration (plugins, SWC, env vars, aliases), performance optimization (useMemo, useCallback, lazy loading, code splitting), build optimization (chunks, bundle analysis, production), and testing setup (Vitest, component tests)
