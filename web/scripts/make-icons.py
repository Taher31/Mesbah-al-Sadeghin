"""The app icon in every size, for the web app and the Android app, from one file.

    python -I scripts/make-icons.py

Source: branding/app-icon.png (the official icon; transparent around the arch). Needs Pillow.
The results are committed, so builds don't need this; run it again only if the icon changes.
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
REPO = ROOT.parent
SOURCE = REPO / "branding" / "app-icon.png"
PUBLIC = ROOT / "public"
RES = REPO / "android" / "app" / "src" / "main" / "res"
# The app's deep green (start screen, home hero): behind the icon wherever a square must be filled.
BACKGROUND = (0x04, 0x20, 0x1C, 255)


def art() -> Image.Image:
    im = Image.open(SOURCE).convert("RGBA")
    return im.crop(im.getchannel("A").getbbox())


def square(size: int, height: float, background=None) -> Image.Image:
    """The arch centred on a square, `height` of its side tall (it is taller than wide)."""
    canvas = Image.new("RGBA", (size, size), background or (0, 0, 0, 0))
    a = art()
    h = round(size * height)
    w = round(a.width * h / a.height)
    canvas.alpha_composite(a.resize((w, h), Image.LANCZOS), ((size - w) // 2, (size - h) // 2))
    return canvas


def save(im: Image.Image, dest: Path, fmt="PNG"):
    dest.parent.mkdir(parents=True, exist_ok=True)
    if fmt == "WEBP":
        im.save(dest, "WEBP", quality=90, method=6)
    else:
        im.save(dest, "PNG", optimize=True)
    print(f"{dest.relative_to(REPO)}: {dest.stat().st_size // 1024} KB")


def web():
    icons = PUBLIC / "icons"
    save(square(192, 0.96), icons / "icon-192.png")
    save(square(512, 0.96), icons / "icon-512.png")
    # Maskable: the whole arch inside the 80% circle every platform may cut to.
    save(square(192, 0.60, BACKGROUND), icons / "maskable-192.png")
    save(square(512, 0.60, BACKGROUND), icons / "maskable-512.png")
    # iOS rounds the corners itself and shows transparency as black: fill the square.
    save(square(180, 0.80, BACKGROUND).convert("RGB"), icons / "apple-touch-icon.png")
    save(square(48, 1.0), icons / "favicon-48.png")
    save(square(448, 1.0), PUBLIC / "img" / "logo.webp", "WEBP")


def android():
    densities = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}
    for name, scale in densities.items():
        folder = RES / f"mipmap-{name}"
        # Launchers before Android 8 show these as they are.
        legacy = square(round(48 * scale), 0.92)
        save(legacy, folder / "ic_launcher.png")
        save(legacy, folder / "ic_launcher_round.png")
        # Android 8+: a 108dp layer the launcher masks to its own shape (circle, squircle …) of at
        # least 72dp; at half its height the whole arch stays inside even a circle.
        save(square(round(108 * scale), 0.50), folder / "ic_launcher_foreground.png")
    # The start screen before Android 12 (drawable/splash.xml), drawn at its pixel size.
    save(square(320, 0.80), RES / "drawable-nodpi" / "app_logo.png")


if __name__ == "__main__":
    web()
    android()
