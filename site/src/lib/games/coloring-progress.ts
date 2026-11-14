export type ColoringProgress = Readonly<Record<string, Readonly<Record<string, string>>>>;

const EMPTY_PAGE: Readonly<Record<string, string>> = {};

export function coloringPageFills(progress: ColoringProgress, pageId: string): Readonly<Record<string, string>> {
  return progress[pageId] ?? EMPTY_PAGE;
}

export function colorRegion(
  progress: ColoringProgress,
  pageId: string,
  regionId: string,
  paint: string,
): ColoringProgress {
  return {
    ...progress,
    [pageId]: {
      ...coloringPageFills(progress, pageId),
      [regionId]: paint,
    },
  };
}

export function clearColoringPage(progress: ColoringProgress, pageId: string): ColoringProgress {
  if (!progress[pageId]) return progress;
  return { ...progress, [pageId]: EMPTY_PAGE };
}
