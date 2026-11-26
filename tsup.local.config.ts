// Low-memory build for Dockerfile.local: CommonJS only (runtime is `node dist/main`), no sourcemaps, no minify.
import { cpSync } from 'node:fs';

import { defineConfig } from 'tsup';

export default defineConfig({
  entry: ['src'],
  outDir: 'dist',
  splitting: false,
  sourcemap: false,
  clean: true,
  minify: false,
  format: ['cjs'],
  onSuccess: async () => {
    cpSync('src/utils/translations', 'dist/translations', { recursive: true });
  },
  loader: {
    '.json': 'file',
    '.yml': 'file',
  },
});
