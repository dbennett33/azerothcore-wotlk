"""Compose the 512x512 texture sheet and encode it as BLP2 DXT1 (+ PNG copy for previews).

UV layout (matches 10_build_mesh.py):
  body wrap   u 0..1,       v 0.00..0.47   seam at the back, face centred on u=0.5, v 0.09..0.36
  limb wax    u 0..0.44,    v 0.52..0.98   (tubes, blobs, top dish)
  wick        u 0.45..0.50, v 0.955..0.99  dark
  flame       u 0.55..0.95, v 0.55..0.95   sprite on black (additive material)
"""
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from wowlib import OUT, ASSETS
from blp import write_blp2

S = 512
rng = np.random.default_rng(7)

face = Image.open(os.path.join(ASSETS, "waxcandle", "face.png")).convert("RGB")
flame = Image.open(os.path.join(ASSETS, "waxcandle", "flame.png")).convert("RGB")

# wax base colour = the face art's border colour so the paste blends
border = np.concatenate([np.asarray(face)[:8].reshape(-1, 3), np.asarray(face)[-8:].reshape(-1, 3),
                         np.asarray(face)[:, :8].reshape(-1, 3), np.asarray(face)[:, -8:].reshape(-1, 3)])
WAX = tuple(int(x) for x in border.mean(axis=0))
print("wax base colour", WAX)


def wax_sheet(w, h, streaks=True, seed=1):
    """Ivory wax with soft vertical streaks and a little grain."""
    r = np.random.default_rng(seed)
    base = np.array(WAX, dtype=np.float32)[None, None, :] * np.ones((h, w, 1), np.float32)
    if streaks:
        # low-frequency vertical streaks (darker/lighter columns), tileable horizontally
        x = np.arange(w)
        streak = np.zeros(w, np.float32)
        for k in range(1, 7):
            streak += r.uniform(-1, 1) * np.sin(2 * np.pi * k * x / w + r.uniform(0, 6.28)) / k
        streak = (streak / np.abs(streak).max()) * 9.0
        base += streak[None, :, None]
    grain = r.normal(0, 3.0, (h, w, 1)).astype(np.float32)
    grain = np.asarray(Image.fromarray(np.clip(grain[..., 0] + 128, 0, 255).astype(np.uint8)).filter(
        ImageFilter.GaussianBlur(1.2)), np.float32)[..., None] - 128
    base += grain * 1.5
    return np.clip(base, 0, 255).astype(np.uint8)


sheet = Image.fromarray(wax_sheet(S, S, seed=3))
draw = ImageDraw.Draw(sheet)

# ---- body wrap (rows 0..240): darker shading toward the very top rim, warm glow, drips -----------
body_h = int(0.47 * S)
body = np.asarray(sheet.crop((0, 0, S, body_h))).astype(np.float32)
rows = np.arange(body_h)[:, None, None]
# ambient occlusion toward the bottom, warm flame glow toward the top
body *= (1.0 - 0.10 * (rows / body_h)) 
glow = np.clip(1.0 - rows / (0.10 * S), 0, 1) ** 2
body[..., 0] += 26 * glow[..., 0]; body[..., 1] += 10 * glow[..., 0]; body[..., 2] -= 24 * glow[..., 0]
body_img = Image.fromarray(np.clip(body, 0, 255).astype(np.uint8))
bd = ImageDraw.Draw(body_img)
# drips hanging from the rim: rounded strokes, lighter core + darker outline
light = tuple(min(255, c + 14) for c in WAX)
dark = tuple(max(0, c - 38) for c in WAX)
drips = rng.integers(0, S, 26)
for x in drips:
    ln = int(rng.integers(14, 58)); wd = int(rng.integers(7, 15))
    bd.rounded_rectangle((x - wd // 2 - 2, -10, x + wd // 2 + 2, ln + 2), radius=wd // 2 + 2, fill=dark)
    bd.rounded_rectangle((x - wd // 2, -10, x + wd // 2, ln), radius=wd // 2, fill=light)
# wrap the drips across the seam by copying edge strips
arr = np.asarray(body_img).copy()
arr[:, :16] = np.where((np.arange(16) < 8)[None, :, None], arr[:, S - 16:S - 8], arr[:, :16]) if False else arr[:, :16]
body_img = Image.fromarray(arr).filter(ImageFilter.GaussianBlur(0.6))
# thin dark seam line at the bottom of the rim (where the top dish meets the side)
bd = ImageDraw.Draw(body_img)
bd.line((0, 6, S, 6), fill=dark, width=2)

# face paste: u 0.32..0.68 -> x 164..348 ; v 0.09..0.36 -> y 46..184 (4:3 art -> 184x138)
fw, fh = 184, 138
face_s = face.resize((fw, fh), Image.LANCZOS)
mask = Image.new("L", (fw, fh), 0)
ImageDraw.Draw(mask).ellipse((2, 2, fw - 3, fh - 3), fill=255)
mask = mask.filter(ImageFilter.GaussianBlur(10))
body_img.paste(face_s, (164, 46), mask)
sheet.paste(body_img, (0, 0))

# ---- gap rows 240..266 stay wax (both neighbours are wax, no bleed) ------------------------------

# ---- limb wax quadrant (x 0..230, y 266..512): a few drips too ---------------------------------
ld = ImageDraw.Draw(sheet)
for x in rng.integers(4, 220, 9):
    y0 = int(rng.integers(270, 470)); ln = int(rng.integers(10, 30)); wd = int(rng.integers(5, 10))
    ld.rounded_rectangle((x - wd // 2 - 1, y0 - 1, x + wd // 2 + 1, y0 + ln + 1), radius=wd // 2 + 1, fill=dark)
    ld.rounded_rectangle((x - wd // 2, y0, x + wd // 2, y0 + ln), radius=wd // 2, fill=light)

# ---- wick: x 230..256, y 489..507 dark, black tip (v 0.955 = top of wick) -----------------------
ld.rectangle((228, 486, 258, 508), fill=(42, 26, 16))
ld.rectangle((228, 486, 258, 492), fill=(12, 8, 6))

# ---- flame quadrant: x 256..512, y 256..512 black, sprite at u/v 0.55..0.95 (x 282..486) --------
ld.rectangle((256, 256, 512, 512), fill=(0, 0, 0))
fl = flame.resize((204, 204), Image.LANCZOS)
sheet.paste(fl, (282, 282))
# darken the wick-region right edge so DXT blocks bordering black stay dark
ld.rectangle((256, 256, 260, 512), fill=(0, 0, 0))

rgba = np.dstack([np.asarray(sheet), np.full((S, S), 255, np.uint8)])
sheet.save(os.path.join(OUT, "WaxCandleSkin.png"))
n, size = write_blp2(os.path.join(OUT, "WaxCandleSkin.blp"), rgba, alpha=False)
print(f"BLP written: {n} mips, {size} bytes")
