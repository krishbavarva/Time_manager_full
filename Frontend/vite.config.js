import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'
import tailwindcss from 'tailwindcss'
import autoprefixer from 'autoprefixer'

// Set your backend IP and port
const BACKEND_URL = 'http://172.20.10.3:4000'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [vue()],
  css: {
    postcss: {
      plugins: [
        tailwindcss(),
        autoprefixer(),
      ],
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  },
  server: {
    port: 3000,
    open: true,
    // Dev proxy to avoid CORS when running vite dev server
    proxy: {
      '/api': {
        target: BACKEND_URL,
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path, // keep the /api path unchanged
      }
    }
  },
  define: {
    'import.meta.env.VITE_API_BASE_URL': JSON.stringify(BACKEND_URL) // make it accessible in http.js
  }
})
