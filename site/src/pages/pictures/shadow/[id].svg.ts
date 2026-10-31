import type { APIRoute, GetStaticPaths } from 'astro';
import { PICTURES, PICTURE_BY_ID, pictureShadowSvg } from '../../../data/pictures';

export const getStaticPaths: GetStaticPaths = () => PICTURES.map((p) => ({ params: { id: p.id } }));

export const GET: APIRoute = ({ params }) => {
  const picture = PICTURE_BY_ID.get(String(params.id));
  if (!picture) return new Response('Not found', { status: 404 });
  return new Response(pictureShadowSvg(picture), {
    headers: { 'Content-Type': 'image/svg+xml; charset=utf-8' },
  });
};
