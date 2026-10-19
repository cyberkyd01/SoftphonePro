#!/usr/bin/env python3
"""Generates the desktop icon files from the branding sources (needs Pillow).

  windows/runner/resources/app_icon.ico   multi-size app icon (from icon_1024.png)
  assets/branding/tray_icon.ico           Windows tray icon (white glyph)
  assets/branding/tray_icon_alert.ico     ... with a red alert dot
  assets/branding/tray_mac_template.png   macOS menu-bar template image (black + alpha, 2x)

Run from app/:  python3 tool/gen_desktop_icons.py
"""
from pathlib import Path
from PIL import Image, ImageDraw

root = Path(__file__).resolve().parent.parent
brand = root / "assets" / "branding"

app = Image.open(brand / "icon_1024.png").convert("RGBA")
app.save(root / "windows/runner/resources/app_icon.ico",
         sizes=[(s, s) for s in (16, 24, 32, 48, 64, 128, 256)])

glyph = Image.open(brand / "tray_icon_256.png").convert("RGBA")
glyph = glyph.crop(glyph.getbbox())
side = max(glyph.size)
canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
canvas.paste(glyph, ((side - glyph.width) // 2, (side - glyph.height) // 2))
glyph = canvas.resize((256, 256), Image.LANCZOS)


def with_dot(img, color=(239, 68, 68, 255)):
    out = img.copy()
    d = ImageDraw.Draw(out)
    w = img.width
    r = int(w * 0.20)
    cx, cy = w - r - 2, r + 2
    d.ellipse((cx - r - 2, cy - r - 2, cx + r + 2, cy + r + 2), fill=(0, 0, 0, 90))
    d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=color)
    return out


sizes = [(s, s) for s in (16, 20, 24, 32, 48, 64)]
glyph.save(brand / "tray_icon.ico", sizes=sizes)
with_dot(glyph).save(brand / "tray_icon_alert.ico", sizes=sizes)

# macOS: template images must be black + alpha; 36px = 18pt @2x.
black = Image.new("RGBA", glyph.size, (0, 0, 0, 255))
black.putalpha(glyph.getchannel("A"))
black.resize((36, 36), Image.LANCZOS).save(brand / "tray_mac_template.png")
# (macOS flashes via the status-item title instead of a second image.)
print("ok")
