#!/usr/bin/env python3
"""Build the Google Play phone frames from fresh emulator captures.

Each frame matches the App Store set: the generated paper backdrop
(art/parchment-backdrop.png), the same "Golden Moments" label, headline and
supporting text from metadata/app-store.en-US.json, and a plain dark bezel.
The capture from assets/screenshots/en-US/raw/android/NN.png is scaled to fit
and clipped to the bezel's rounded screen. Nothing in the capture is drawn or
edited. Frames are 1440 by 2560 pixels (9:16), within Google Play's limits.

Usage: python3 scripts/compose_play_screens.py
"""
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SHOTS = ROOT / 'assets/screenshots/en-US'
FONTS = ROOT / 'assets/fonts'
METADATA = ROOT / 'metadata/app-store.en-US.json'

SIZE = (1440, 2560)
INK = (32, 31, 29)        # headline, as in the App Store frames
MUTED = (74, 70, 61)      # supporting text
LABEL = (122, 90, 26)     # the small "Golden Moments" label
BEZEL = (31, 31, 29)
BEZEL_WIDTH = 14
SCREEN_TOP = 690
SCREEN_BOTTOM_MARGIN = 120
SCREEN_RADIUS = 64


def font(weight, size):
    return ImageFont.truetype(str(FONTS / f'Roboto-{weight}.ttf'), size)


def backdrop():
    """The paper backdrop, scaled to the frame width and cropped from the top."""
    paper = Image.open(SHOTS / 'art/parchment-backdrop.png').convert('RGB')
    width, height = SIZE
    scaled = paper.resize((width, round(paper.height * width / paper.width)), Image.LANCZOS)
    if scaled.height < height:
        raise SystemExit('The backdrop is too short for the frame.')
    return scaled.crop((0, 0, width, height))


def two_lines(draw, text, face):
    """Splits a headline into the two most even lines, as the App Store set does."""
    words = text.split()
    splits = [(' '.join(words[:i]), ' '.join(words[i:])) for i in range(1, len(words))]
    return min(splits, key=lambda pair: max(draw.textlength(line, font=face) for line in pair))


def centered(draw, y, text, face, fill):
    draw.text((SIZE[0] / 2, y), text, font=face, fill=fill, anchor='ma')


def text_block(draw, headline, supporting):
    centered(draw, 110, 'Golden Moments', font('Medium', 40), LABEL)
    face = font('Bold', 112)
    y = 190
    for line in two_lines(draw, headline, face):
        centered(draw, y, line, face, INK)
        y += 128
    centered(draw, y + 40, supporting, font('Regular', 50), MUTED)


def screen_mask(width, height, radius):
    """An anti-aliased rounded rectangle, drawn at twice the size."""
    big = Image.new('L', (width * 2, height * 2), 0)
    ImageDraw.Draw(big).rounded_rectangle(
        [0, 0, width * 2 - 1, height * 2 - 1], radius=radius * 2, fill=255)
    return big.resize((width, height), Image.LANCZOS)


def compose(capture, headline, supporting):
    out = backdrop()
    text_block(ImageDraw.Draw(out), headline, supporting)
    height = SIZE[1] - SCREEN_TOP - SCREEN_BOTTOM_MARGIN
    width = round(capture.width * height / capture.height)
    left = (SIZE[0] - width) // 2
    # The bezel: a dark rounded band around the screen.
    outer = (width + 2 * BEZEL_WIDTH, height + 2 * BEZEL_WIDTH)
    bezel = Image.new('RGB', outer, BEZEL)
    out.paste(bezel, (left - BEZEL_WIDTH, SCREEN_TOP - BEZEL_WIDTH),
              screen_mask(*outer, SCREEN_RADIUS + BEZEL_WIDTH))
    screen = capture.convert('RGB').resize((width, height), Image.LANCZOS)
    out.paste(screen, (left, SCREEN_TOP), screen_mask(width, height, SCREEN_RADIUS))
    return out


def main():
    frames = json.loads(METADATA.read_text())['screenshots']
    target = SHOTS / 'android'
    target.mkdir(exist_ok=True)
    for frame in frames:
        name = f"{frame['order']:02d}"
        capture = Image.open(SHOTS / 'raw/android' / f'{name}.png')
        result = compose(capture, frame['headline'], frame['supporting_text'])
        path = target / f'{name}.jpg'
        result.save(path, 'JPEG', quality=90, optimize=True)
        print(f'Wrote {path.relative_to(ROOT)}')


if __name__ == '__main__':
    main()
