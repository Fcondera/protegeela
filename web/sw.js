const CACHE_NAME = 'protegeela-static-v1';
const STATIC_ASSETS = [
  './',
  './index.html',
  './offline.html',
  './manifest.json',
  './icons/Icon-192.png',
  './icons/Icon-512.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(CACHE_NAME).then((cache) => cache.addAll(STATIC_ASSETS)));
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key)))
    )
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  const url = new URL(request.url);

  if (request.method !== 'GET') return;
  if (url.pathname.includes('/auth/') || url.pathname.includes('/rest/') || url.pathname.includes('/functions/')) return;

  event.respondWith(
    caches.match(request).then((cached) =>
      cached ||
      fetch(request).catch(() => caches.match('./offline.html'))
    )
  );
});
