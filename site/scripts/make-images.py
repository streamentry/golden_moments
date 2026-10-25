#!/usr/bin/env python3
"""Generate PNG icons and Open Graph share images for the website.

macOS only: SVGs are rasterized with Quick Look (`qlmanage`), then composed
with Pillow. Run after `pnpm build` (it reads dist/pictures/*.svg):

    python3 scripts/make-images.py

Outputs are committed under public/icons and public/og.
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
import tempfile
import textwrap
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

SITE = Path(__file__).resolve().parent.parent
REPO = SITE.parent
DIST_PICS = SITE / "dist" / "pictures"
PUBLIC = SITE / "public"
FONT_BOLD = REPO / "assets" / "fonts" / "Roboto-Bold.ttf"
FONT_REG = REPO / "assets" / "fonts" / "Roboto-Regular.ttf"

PARCHMENT = (253, 249, 240)
INK = (34, 34, 34)
WALNUT = (92, 83, 70)
GOLD = (122, 86, 0)
SUNLIT = (255, 224, 138)
PRINT_WHITE = (255, 253, 247)

W, H = 1200, 630


def rasterize(svg: Path, size: int, out_dir: Path) -> Image.Image:
    # Quick Look draws a fixed-size SVG at its intrinsic size; drop width and
    # height so the viewBox scales to fill the requested thumbnail.
    scalable = out_dir / svg.name
    text = svg.read_text()
    root_end = text.index(">") + 1
    root = re.sub(r'\s(width|height)="\d+"', "", text[:root_end])
    scalable.write_text(root + text[root_end:])
    svg = scalable
    subprocess.run(
        ["qlmanage", "-t", "-s", str(size), "-o", str(out_dir), str(svg)],
        check=True,
        capture_output=True,
    )
    png = out_dir / f"{svg.name}.png"
    img = Image.open(png).convert("RGBA")
    # Quick Look pads small intrinsic sizes with transparency; keep only the art.
    box = img.getbbox()
    if box:
        img = img.crop(box)
    return img.resize((size, size), Image.LANCZOS)


def print_card(pic: Image.Image, angle: float) -> Image.Image:
    border, bottom = 18, 40
    w = pic.width + border * 2
    h = pic.height + border + bottom
    card = Image.new("RGBA", (w, h), PRINT_WHITE + (255,))
    card.paste(pic, (border, border), pic)
    shadow = Image.new("RGBA", (w + 60, h + 60), (60, 44, 10, 0))
    ImageDraw.Draw(shadow).rectangle((30, 40, w + 30, h + 40), fill=(60, 44, 10, 70))
    shadow = shadow.filter(ImageFilter.GaussianBlur(14))
    shadow.paste(card, (30, 30), card)
    return shadow.rotate(angle, expand=True, resample=Image.BICUBIC)


def background() -> Image.Image:
    img = Image.new("RGBA", (W, H), PARCHMENT + (255,))
    glow = Image.new("RGBA", (W, H), SUNLIT + (0,))
    ImageDraw.Draw(glow).ellipse((620, -260, 1500, 420), fill=SUNLIT + (150,))
    glow = glow.filter(ImageFilter.GaussianBlur(90))
    img.alpha_composite(glow)
    return img


def draw_text_block(img: Image.Image, mark: Image.Image, eyebrow: str, title: str, subtitle: str) -> None:
    d = ImageDraw.Draw(img)
    img.alpha_composite(mark.resize((64, 64), Image.LANCZOS), (64, 56))
    d.text((144, 62), "Golden Moments", font=ImageFont.truetype(str(FONT_BOLD), 34), fill=INK)
    d.text((144, 100), eyebrow, font=ImageFont.truetype(str(FONT_REG), 22), fill=WALNUT)

    size = 64 if len(title) <= 40 else 54
    font = ImageFont.truetype(str(FONT_BOLD), size)
    lines = textwrap.wrap(title, width=18 if size == 64 else 22)[:4]
    y = 190
    for line in lines:
        d.text((64, y), line, font=font, fill=INK)
        y += int(size * 1.12)
    sub_font = ImageFont.truetype(str(FONT_REG), 28)
    for line in textwrap.wrap(subtitle, width=36)[:2]:
        y += 6
        d.text((64, y + 10), line, font=sub_font, fill=WALNUT)
        y += 36
    d.rounded_rectangle((64, H - 76, 64 + 12, H - 64), radius=6, fill=(201, 146, 0))
    d.text((88, H - 86), "dementiaactivities.games", font=ImageFont.truetype(str(FONT_BOLD), 26), fill=GOLD)


def compose(pics: list[Image.Image], mark: Image.Image, eyebrow: str, title: str, subtitle: str) -> Image.Image:
    img = background()
    spots = [(700, 70, -5.0), (930, 150, 4.0), (760, 330, 3.0)]
    for pic, (x, y, angle) in zip(pics, spots):
        card = print_card(pic.resize((200, 200), Image.LANCZOS), angle)
        img.alpha_composite(card, (x, y))
    draw_text_block(img, mark, eyebrow, title, subtitle)
    return img.convert("RGB")


def main() -> int:
    if not DIST_PICS.exists():
        print("Run `pnpm build` first so dist/pictures exists.", file=sys.stderr)
        return 1
    games = json.loads((SITE / "scripts" / "og-games.json").read_text())
    (PUBLIC / "icons").mkdir(parents=True, exist_ok=True)
    (PUBLIC / "og" / "games").mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory() as tmp:
        tmpdir = Path(tmp)
        mark = rasterize(PUBLIC / "favicon.svg", 512, tmpdir)
        for size, name in [(180, "apple-touch-icon.png"), (192, "icon-192.png"), (512, "icon-512.png")]:
            icon = Image.new("RGBA", (size, size), PARCHMENT + (255,))
            inner = mark.resize((int(size * 0.84), int(size * 0.84)), Image.LANCZOS)
            offset = (size - inner.width) // 2
            icon.alpha_composite(inner, (offset, offset))
            icon.convert("RGB").save(PUBLIC / "icons" / name, optimize=True)
        mark.resize((48, 48), Image.LANCZOS).save(PUBLIC / "favicon.ico", sizes=[(16, 16), (32, 32), (48, 48)])

        cache: dict[str, Image.Image] = {}

        def pic(pid: str) -> Image.Image:
            if pid not in cache:
                cache[pid] = rasterize(DIST_PICS / f"{pid}.svg", 400, tmpdir)
            return cache[pid]

        pages = [
            ("default", ["teacup", "sunflower", "dog"], "Free · No sign-up · No timers",
             "Gentle Games & Activities for People with Dementia", "Simple picture games to enjoy together, at your own pace."),
            ("activities", ["watering-can", "bread", "tulip"], "Activity ideas",
             "Activities for People with Dementia", "Ideas for every stage, at home or in a group."),
            ("caregiving", ["kettle", "armchair", "lamp"], "For caregivers",
             "Practical Guides for Everyday Care", "Playing together, communication and caring for yourself."),
            ("brain-health", ["apple", "bicycle", "moon"], "Brain health",
             "What the Research Really Says", "Plain, sourced answers. General information, not medical advice."),
        ]
        for slug, ids, eyebrow, title, subtitle in pages:
            compose([pic(i) for i in ids], mark, eyebrow, title, subtitle).save(PUBLIC / "og" / f"{slug}.png", optimize=True)
        for g in games:
            compose([pic(i) for i in g["pictures"]], mark, "Free game · No timer or score", g["title"], g["subtitle"]).save(
                PUBLIC / "og" / "games" / f"{g['slug']}.png", optimize=True
            )
    print("Icons and share images written to public/.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
