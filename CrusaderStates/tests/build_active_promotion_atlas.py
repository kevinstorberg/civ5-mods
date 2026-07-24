from pathlib import Path

from PIL import Image


MOD_ROOT = Path(__file__).resolve().parents[1]
ART_DIR = MOD_ROOT / "Art"
SOURCE_ATLAS = ART_DIR / "Jerusalem_Atlas256.dds"
OUTPUT_SIZES = (256, 128, 80, 64, 48, 45, 32, 24, 16)
SOURCE_COLORS = {(255, 215, 0), (103, 70, 17)}
ACTIVE_RED = (139, 0, 0)


def build_active_icon() -> Image.Image:
    source_atlas = Image.open(SOURCE_ATLAS).convert("RGBA")
    if source_atlas.size != (512, 512):
        raise ValueError(
            f"{SOURCE_ATLAS.name} must be a 2x2 256px atlas, got {source_atlas.size}"
        )

    source_icon = source_atlas.crop((0, 0, 256, 256))
    source_palette = {
        pixel[:3] for pixel in source_icon.getdata() if pixel[3] > 0
    }
    expected_palette = SOURCE_COLORS | {(255, 255, 255)}
    if source_palette != expected_palette:
        raise ValueError(
            f"Unexpected Deus Vult palette: {sorted(source_palette)}"
        )

    active_pixels = [
        (*ACTIVE_RED, alpha) if (red, green, blue) in SOURCE_COLORS
        else (red, green, blue, alpha)
        for red, green, blue, alpha in source_icon.getdata()
    ]
    active_icon = source_icon.copy()
    active_icon.putdata(active_pixels)

    for source_pixel, active_pixel in zip(
        source_icon.getdata(), active_icon.getdata()
    ):
        source_rgb = source_pixel[:3]
        if source_rgb in SOURCE_COLORS:
            if active_pixel != (*ACTIVE_RED, source_pixel[3]):
                raise AssertionError("Active red did not replace a source color")
        elif active_pixel != source_pixel:
            raise AssertionError("Non-colored source pixel changed")

    return active_icon


def write_atlases(active_icon: Image.Image) -> None:
    for size in OUTPUT_SIZES:
        resized = active_icon.resize((size, size), Image.Resampling.LANCZOS)
        for red, green, blue, alpha in resized.getdata():
            if alpha > 0 and green != blue:
                raise AssertionError(
                    f"Gold-like hue found in {size}px output: "
                    f"{(red, green, blue, alpha)}"
                )

        output_path = ART_DIR / f"Jerusalem_CrusaderActive{size}.dds"
        resized.save(output_path, format="DDS")

        decoded = Image.open(output_path).convert("RGBA")
        if decoded.size != (size, size):
            raise AssertionError(
                f"{output_path.name} decoded as {decoded.size}, expected {(size, size)}"
            )


if __name__ == "__main__":
    write_atlases(build_active_icon())
