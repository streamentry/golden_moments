import { useEffect, useState } from 'react';

/** True when the viewport is at least `min` px wide. False during server render. */
export function useWide(min = 600): boolean {
  const [wide, setWide] = useState(false);
  useEffect(() => {
    const mq = window.matchMedia(`(min-width: ${min}px)`);
    const update = () => setWide(mq.matches);
    update();
    mq.addEventListener('change', update);
    return () => mq.removeEventListener('change', update);
  }, [min]);
  return wide;
}
