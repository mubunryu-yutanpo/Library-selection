import dns from 'node:dns'
dns.setDefaultResultOrder('verbatim')

import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
    server: {
        host: '0.0.0.0',
        port: 5173,
        strictPort: true,
        origin: 'http://localhost:5173',
        cors: {
            origin: ['http://localhost:8000'],
            methods: ['GET','POST','PUT','DELETE','OPTIONS'],
            credentials: true,
          },
        hmr: {
          host: 'localhost',
          protocol: 'ws',
          port: 5173,
        },
      },
    plugins: [
        laravel({
            input: ['resources/js/app.js', 'resources/sass/app.scss'],
            refresh: true,
        }),
        vue({
            template: {
                transformAssetUrls: {
                    base: null,
                    includeAbsolute: false,
                },
            },
        }),
        
    ],
});
