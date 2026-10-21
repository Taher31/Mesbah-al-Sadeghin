"""One-off: web-sized images and PWA icons in public/, from the Android app's drawables.

    python -I scripts/prepare-images.py [android res folder]

Needs Pillow. The results are committed, so builds don't need this.
"""
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
RES = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT.parent / "android" / "app" / "src" / "main" / "res"
DRAWABLE = RES / "drawable-nodpi"
FOREGROUND = RES / "mipmap-xxxhdpi" / "ic_launcher_foreground.png"
PUBLIC = ROOT / "public"
TEAL = (0x0B, 0x3A, 0x2E, 255)


def save_jpg(src: Path, dest: Path, size=None, quality=80):
    im = Image.open(src).convert("RGB")
    if size:
        im = im.resize(size, Image.LANCZOS)
    im.save(dest, "JPEG", quality=quality, optimize=True, progressive=True)
    print(f"{dest.relative_to(ROOT)}: {dest.stat().st_size // 1024} KB")


def save_png(im: Image.Image, dest: Path):
    im.save(dest, "PNG", optimize=True)
    print(f"{dest.relative_to(ROOT)}: {dest.stat().st_size // 1024} KB")


def logo_art() -> Image.Image:
    """The logo tile cut from the launcher foreground (higher-res than app_logo.png)."""
    fg = Image.open(FOREGROUND).convert("RGBA")
    return fg.crop(fg.getbbox())


def on_teal(art: Image.Image, size: int, art_fraction: float) -> Image.Image:
    """Art centred on the brand teal: platforms that mask icons get no transparent corners."""
    canvas = Image.new("RGBA", (size, size), TEAL)
    side = round(size * art_fraction)
    scaled = art.resize((side, side), Image.LANCZOS)
    canvas.alpha_composite(scaled, ((size - side) // 2, (size - side) // 2))
    return canvas


def main():
    img = PUBLIC / "img"
    icons = PUBLIC / "icons"
    img.mkdir(parents=True, exist_ok=True)
    icons.mkdir(parents=True, exist_ok=True)

    for name in ["cover_anis", "cover_anis_tr", "cover_safineh_fa", "cover_safineh_ar"]:
        save_jpg(DRAWABLE / f"{name}.jpg", img / f"{name}.jpg", quality=84)
    save_jpg(DRAWABLE / "portrait.jpg", img / "portrait.jpg", size=(900, 900), quality=78)

    logo = Image.open(DRAWABLE / "app_logo.png").convert("RGBA")
    logo.save(img / "logo.webp", "WEBP", quality=88, method=6)
    print(f"public/img/logo.webp: {(img / 'logo.webp').stat().st_size // 1024} KB")

    art = logo_art()
    # "any" icons keep the rounded tile with transparent corners, like the Android launcher.
    save_png(art.resize((192, 192), Image.LANCZOS), icons / "icon-192.png")
    save_png(art.resize((512, 512), Image.LANCZOS), icons / "icon-512.png")
    # Maskable: the tile sits inside the 80% safe zone on a full-bleed teal square.
    save_png(on_teal(art, 192, 0.78), icons / "maskable-192.png")
    save_png(on_teal(art, 512, 0.78), icons / "maskable-512.png")
    # iOS rounds the corners itself and shows transparency as black, so fill to the edge.
    save_png(on_teal(art, 180, 0.96).convert("RGB"), icons / "apple-touch-icon.png")
    save_png(art.resize((48, 48), Image.LANCZOS), icons / "favicon-48.png")


if __name__ == "__main__":
    main()
