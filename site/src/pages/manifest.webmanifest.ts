import type { APIRoute } from 'astro';

export const GET: APIRoute = () =>
  new Response(
    JSON.stringify({
      name: 'Golden Moments: Dementia Activities',
      short_name: 'Golden Moments',
      description: 'Gentle games and activities for people living with dementia.',
      start_url: '/',
      display: 'standalone',
      background_color: '#FDF9F0',
      theme_color: '#FDF9F0',
      icons: [
        { src: '/icons/icon-192.png', sizes: '192x192', type: 'image/png' },
        { src: '/icons/icon-512.png', sizes: '512x512', type: 'image/png' },
        { src: '/icons/icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
      ],
    }),
    { headers: { 'Content-Type': 'application/manifest+json' } },
  );
