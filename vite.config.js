import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// GitHub Pages يخدم الموقع من daood40.github.io/waqti/ لذا الأساس الافتراضي '/waqti/'.
// عند بناء نسخة أندرويد (Capacitor) نمرّر VITE_BASE=./ ليعمل التطبيق من الملفات المحلية.
export default defineConfig({
  base: process.env.VITE_BASE || '/waqti/',
  plugins: [react()],
  build: {
    outDir: 'dist',
  },
})
