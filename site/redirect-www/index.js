const CANONICAL_HOST = 'dementiaactivities.games';

export default {
  fetch(request) {
    const url = new URL(request.url);
    url.protocol = 'https:';
    url.host = CANONICAL_HOST;
    return Response.redirect(url.toString(), 301);
  },
};
