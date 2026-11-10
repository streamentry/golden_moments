/** Use an optional user caption as a spoken photo name, with a numbered fallback. */
export function photoTileName(numberedName: string, caption?: string): string {
  return caption?.trim() || numberedName;
}
