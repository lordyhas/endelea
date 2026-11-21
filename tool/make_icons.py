"""Generates Endelea's launcher icons and splash images (PLAN.md Phase 8):
the Phosphor "barbell" glyph (Fill) in terracotta on #141210."""
import json
import os
import sys

from PIL import Image, ImageDraw, ImageFont

# Usage: python tool/make_icons.py <project-root>
ROOT = sys.argv[1]
FONT = os.path.join(ROOT, 'third_party/phosphor_flutter/lib/fonts/Phosphor-Fill.ttf')
GLYPH = chr(0xE0B6)  # barbell
BG = (0x14, 0x12, 0x10, 255)
TERRACOTTA = (0xE2, 0x68, 0x3C, 255)
WHITE = (255, 255, 255, 255)


def glyph(size, color, scale):
    """A square transparent image with the glyph centered on its pixels,
    its larger side filling `scale` of the image."""
    canvas = Image.new('RGBA', (size * 2, size * 2), (0, 0, 0, 0))
    font = ImageFont.truetype(FONT, size)
    ImageDraw.Draw(canvas).text((size // 2, size // 2), GLYPH, font=font, fill=color)
    shape = canvas.crop(canvas.getbbox())
    target = int(size * scale)
    ratio = target / max(shape.size)
    shape = shape.resize((max(1, int(shape.width * ratio)), max(1, int(shape.height * ratio))), Image.LANCZOS)
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    img.alpha_composite(shape, ((size - shape.width) // 2, (size - shape.height) // 2))
    return img


def icon(size, rounded):
    """Full icon: glyph on the dark background."""
    big = size * 4
    img = Image.new('RGBA', (big, big), (0, 0, 0, 0))
    mask = Image.new('L', (big, big), 0)
    radius = int(big * 0.22) if rounded else 0
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, big - 1, big - 1), radius=radius, fill=255)
    img.paste(Image.new('RGBA', (big, big), BG), (0, 0), mask)
    img.alpha_composite(glyph(big, TERRACOTTA, 0.62))
    return img.resize((size, size), Image.LANCZOS)


def save(img, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path)


res = os.path.join(ROOT, 'android/app/src/main/res')
densities = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
for name, factor in densities.items():
    # Legacy launcher icon (48 dp), rounded square.
    save(icon(int(48 * factor), rounded=True), f'{res}/mipmap-{name}/ic_launcher.png')
    # Adaptive foreground (108 dp, content in the 66 dp safe zone).
    size = int(108 * factor)
    save(glyph(size, TERRACOTTA, 0.40), f'{res}/mipmap-{name}/ic_launcher_foreground.png')
    # Monochrome status bar icon for notifications (24 dp, white).
    save(glyph(int(24 * factor), WHITE, 0.90), f'{res}/drawable-{name}/ic_stat_endelea.png')
    # Pre-Android 12 splash image.
    save(glyph(int(96 * factor), TERRACOTTA, 0.80), f'{res}/drawable-{name}/splash_logo.png')

# iOS: opaque, square (iOS rounds the corners itself).
appicon = os.path.join(ROOT, 'ios/Runner/Assets.xcassets/AppIcon.appiconset')
contents = json.load(open(os.path.join(appicon, 'Contents.json')))
for image in contents['images']:
    points = float(image['size'].split('x')[0])
    scale = int(image['scale'].rstrip('x'))
    pixels = round(points * scale)
    save(icon(pixels, rounded=False).convert('RGB'), os.path.join(appicon, image['filename']))

launch = os.path.join(ROOT, 'ios/Runner/Assets.xcassets/LaunchImage.imageset')
for suffix, scale in (('', 1), ('@2x', 2), ('@3x', 3)):
    save(glyph(96 * scale, TERRACOTTA, 0.80), os.path.join(launch, f'LaunchImage{suffix}.png'))

# Store icon (512 × 512), kept for the Play Store listing.
save(icon(512, rounded=False).convert('RGB'), os.path.join(ROOT, 'docs/store/icon-512.png'))
print('icons written')
