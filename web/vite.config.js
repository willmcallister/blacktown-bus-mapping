import { defineConfig } from 'vite'

export default defineConfig({
  base: "/blacktown-bus-mapping/",
  build: {
  	outDir: '../dist',
  	emptyOutDir: true
  }
})