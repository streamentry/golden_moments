#!/usr/bin/env python3
"""Place fresh simulator captures into the approved App Store frames.

The published frames in assets/screenshots/en-US/{iphone,ipad}/NN.jpg hold
the approved backdrop, headline, supporting text and device bezel. This
replaces only the screen inside the bezel with the capture from
assets/screenshots/en-US/raw/<device>/NN.png, scaled to fit and clipped to
the bezel's rounded corners. Nothing in the capture is drawn or edited.

Usage: python3 scripts/compose_store_screens.py <iphone|ipad> [--check DIR]
  --check DIR  compose captures from DIR and report how closely they
               reproduce the current frames (to verify the geometry).
"""
import argparse
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageStat

ROOT = Path(__file__).resolve().parents[1]
SHOTS = ROOT / 'assets/screenshots/en-US'
FRAMES = ['01', '02', '03', '04', '05', '06']

# The screen inside each bezel, measured from the build 6 frames: left, top,
# width, height and corner radius in frame pixels.
SCREEN = {
    'iphone': (194, 664, 932, 2025, 72),
    'ipad': (256, 584, 1552, 2069, 42),
}
CAPTURE = {'iphone': (1320, 2868), 'ipad': (2064, 2752)}


def screen_mask(width, height, radius):
    """An anti-aliased rounded rectangle, drawn at twice the size."""
    big = Image.new('L', (width * 2, height * 2), 0)
    ImageDraw.Draw(big).rounded_rectangle(
        [0, 0, width * 2 - 1, height * 2 - 1], radius=radius * 2, fill=255)
    return big.resize((width, height), Image.LANCZOS)


def compose(frame, capture, device):
    left, top, width, height, radius = SCREEN[device]
    if capture.size != CAPTURE[device]:
        raise SystemExit(f'{device} capture must be {CAPTURE[device]}, got {capture.size}')
    screen = capture.convert('RGB').resize((width, height), Image.LANCZOS)
    out = frame.convert('RGB').copy()
    # Only inside the rounded screen; the bezel and backdrop stay as approved.
    out.paste(screen, (left, top), screen_mask(width, height, radius))
    return out


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('device', choices=sorted(SCREEN))
    parser.add_argument('--check', type=Path)
    args = parser.parse_args()
    source = args.check or SHOTS / 'raw' / args.device
    for name in FRAMES:
        frame_path = SHOTS / args.device / f'{name}.jpg'
        frame = Image.open(frame_path)
        result = compose(frame, Image.open(source / f'{name}.png'), args.device)
        if args.check:
            diff = ImageStat.Stat(ImageChops.difference(result, frame.convert('RGB')))
            print(f'{args.device} {name}: mean difference {sum(diff.mean) / 3:.2f}')
            continue
        result.save(frame_path, 'JPEG', quality=90, optimize=True)
        print(f'Wrote {frame_path.relative_to(ROOT)}')


if __name__ == '__main__':
    main()
