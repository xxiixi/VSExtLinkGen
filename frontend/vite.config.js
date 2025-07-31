import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 3000,
    proxy: {
      '/extract-data': {
        target: 'http://localhost:8000',
        changeOrigin: true
      }
    }
  }
}) 