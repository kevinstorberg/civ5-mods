from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageOps


MOD_ROOT = Path(__file__).resolve().parents[1]
ART_DIR = MOD_ROOT / "Art"
ATLAS_SIZES = (256, 128, 80, 64, 48, 45, 32, 24, 16)
PRUSSIAN_BLUE = (0, 49, 83, 255)
WHITE = (248, 248, 244, 255)


def load_rgba(path: Path) -> Image.Image:
	if not path.is_file():
		raise FileNotFoundError(f"Missing historical art source: {path}")
	return Image.open(path).convert("RGBA")


def cover(
	image: Image.Image,
	size: tuple[int, int],
	centering: tuple[float, float] = (0.5, 0.5),
) -> Image.Image:
	return ImageOps.fit(
		image,
		size,
		method=Image.Resampling.LANCZOS,
		centering=centering,
	)


def photo_icon(
	source: Image.Image,
	size: int,
	centering: tuple[float, float],
) -> Image.Image:
	icon = Image.new("RGBA", (size, size), (0, 0, 0, 0))
	draw = ImageDraw.Draw(icon)
	outer = round(size * 0.07)
	middle = round(size * 0.095)
	inner = round(size * 0.13)
	draw.ellipse((outer, outer, size - outer, size - outer), fill=PRUSSIAN_BLUE)
	draw.ellipse((middle, middle, size - middle, size - middle), fill=WHITE)

	diameter = size - 2 * inner
	photo = cover(source, (diameter, diameter), centering)
	mask = Image.new("L", (diameter, diameter), 0)
	ImageDraw.Draw(mask).ellipse((0, 0, diameter - 1, diameter - 1), fill=255)
	icon.paste(photo, (inner, inner), mask)
	return icon


def eagle_icon(source: Image.Image, size: int) -> Image.Image:
	icon = Image.new("RGBA", (size, size), (0, 0, 0, 0))
	draw = ImageDraw.Draw(icon)
	outer = round(size * 0.07)
	inner = round(size * 0.105)
	draw.ellipse((outer, outer, size - outer, size - outer), fill=PRUSSIAN_BLUE)
	draw.ellipse((inner, inner, size - inner, size - inner), fill=WHITE)

	eagle = source.copy()
	pixels = []
	for red, green, blue, alpha in eagle.getdata():
		if alpha > 0 and red < 96 and green < 96 and blue < 96:
			pixels.append((*PRUSSIAN_BLUE[:3], alpha))
		else:
			pixels.append((red, green, blue, alpha))
	eagle.putdata(pixels)
	bounds = eagle.getbbox()
	if bounds is None:
		raise ValueError("Royal Prussian eagle source has no visible pixels")
	eagle = eagle.crop(bounds)
	available = round(size * 0.67)
	eagle.thumbnail((available, available), Image.Resampling.LANCZOS)
	position = ((size - eagle.width) // 2, (size - eagle.height) // 2)
	icon.alpha_composite(eagle, position)
	return icon


def build_color_atlas(
	eagle: Image.Image,
	frederick: Image.Image,
	officer: Image.Image,
	staff_college: Image.Image,
) -> Image.Image:
	cell_size = 256
	atlas = Image.new("RGBA", (cell_size * 2, cell_size * 2), (0, 0, 0, 0))
	icons = (
		eagle_icon(eagle, cell_size),
		photo_icon(frederick, cell_size, (0.5, 0.34)),
		photo_icon(officer, cell_size, (0.5, 0.57)),
		photo_icon(staff_college, cell_size, (0.52, 0.55)),
	)
	for index, icon in enumerate(icons):
		x = (index % 2) * cell_size
		y = (index // 2) * cell_size
		atlas.alpha_composite(icon, (x, y))
	return atlas


def build_alpha_atlas(eagle: Image.Image) -> Image.Image:
	cell_size = 256
	atlas = Image.new("RGBA", (cell_size * 2, cell_size * 2), (0, 0, 0, 0))
	bounds = eagle.getbbox()
	if bounds is None:
		raise ValueError("Royal Prussian eagle source has no visible pixels")
	mask_source = eagle.crop(bounds).getchannel("A")
	available = round(cell_size * 0.72)
	mask_source.thumbnail((available, available), Image.Resampling.LANCZOS)
	mark = Image.new("RGBA", mask_source.size, (255, 255, 255, 0))
	mark.putalpha(mask_source)
	position = (
		(cell_size - mark.width) // 2,
		(cell_size - mark.height) // 2,
	)
	atlas.alpha_composite(mark, position)
	return atlas


def write_atlas_family(base: Image.Image, stem: str) -> None:
	for size in ATLAS_SIZES:
		resized = base.resize((size * 2, size * 2), Image.Resampling.LANCZOS)
		output = ART_DIR / f"{stem}{size}.dds"
		resized.save(output, format="DDS")
		decoded = Image.open(output)
		if decoded.size != (size * 2, size * 2):
			raise AssertionError(f"{output.name} decoded at {decoded.size}")


def write_static_art(
	frederick: Image.Image,
	sanssouci: Image.Image,
	prussia_map: Image.Image,
) -> None:
	leader = cover(frederick, (1600, 900), (0.5, 0.33))
	leader = leader.filter(ImageFilter.UnsharpMask(radius=1.2, percent=115, threshold=3))
	leader.save(ART_DIR / "Frederick_scene.dds", format="DDS")

	dawn = cover(sanssouci, (1600, 900), (0.5, 0.20))
	dawn = dawn.filter(ImageFilter.UnsharpMask(radius=1.0, percent=90, threshold=2))
	dawn.save(ART_DIR / "Prussia_DOM.dds", format="DDS")

	map_panel = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
	map_image = prussia_map.copy()
	map_image.thumbnail((500, 500), Image.Resampling.LANCZOS)
	map_panel.alpha_composite(
		map_image,
		((512 - map_image.width) // 2, (512 - map_image.height) // 2),
	)
	map_panel.save(ART_DIR / "MapPrussia.dds", format="DDS")


def parse_args() -> argparse.Namespace:
	parser = argparse.ArgumentParser(
		description="Build Prussia's Civ V DDS atlases from credited source art."
	)
	parser.add_argument(
		"source_dir",
		type=Path,
		help="Directory containing eagle.png, frederick.jpg, sanssouci.jpeg, map.png, staff_college.jpg, and officer.jpg",
	)
	return parser.parse_args()


def main() -> None:
	args = parse_args()
	source_dir = args.source_dir
	eagle = load_rgba(source_dir / "eagle.png")
	frederick = load_rgba(source_dir / "frederick.jpg")
	sanssouci = load_rgba(source_dir / "sanssouci.jpeg")
	prussia_map = load_rgba(source_dir / "map.png")
	staff_college = load_rgba(source_dir / "staff_college.jpg")
	officer = load_rgba(source_dir / "officer.jpg")

	ART_DIR.mkdir(parents=True, exist_ok=True)
	write_atlas_family(
		build_color_atlas(eagle, frederick, officer, staff_college),
		"Prussia_Atlas",
	)
	write_atlas_family(build_alpha_atlas(eagle), "Prussia_Alpha")
	write_static_art(frederick, sanssouci, prussia_map)


if __name__ == "__main__":
	main()
