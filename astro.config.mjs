import { defineConfig } from "astro/config"
import mdx from "@astrojs/mdx"
import sitemap from "@astrojs/sitemap"
import tailwind from "@astrojs/tailwind"
import solidJs from "@astrojs/solid-js"
import react from "@astrojs/react"
import vercel from "@astrojs/vercel/serverless"

// https://astro.build/config
export default defineConfig({
  site: "https://mogesh.m",
  integrations: [
    mdx(), 
    sitemap(), 
    react({ include: ['**/ui/**', '**/canvas-reveal-effect-demo.tsx', '**/background-boxes-demo.tsx'] }),
    solidJs({ include: ['**/components/**/*.tsx'], exclude: ['**/ui/**', '**/canvas-reveal-effect-demo.tsx', '**/background-boxes-demo.tsx'] }), 
    tailwind({ applyBaseStyles: false })
  ],
  output: "server",
  adapter: vercel(),
  experimental: {
    contentCollectionCache: true
  }
})