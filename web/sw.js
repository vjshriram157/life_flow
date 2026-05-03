const CACHE_NAME = 'lifeflow-cache-v1';
const urlsToCache = [
  '/blood-bank/login.jsp',
  '/blood-bank/assets/css/theme.css'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => response || fetch(event.request))
  );
});
