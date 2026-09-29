# Brand assets

- `../web/images/logo.svg` — editable vector master, transparent, dark theme.
- `../web/images/logo-light.svg` — darker gradients for light surfaces.
- `../web/images/logo.png` — transparent 512px export.
- `../web/favicon.svg` — square dark tile with rounded corners.
- `../web/favicon.ico` — 16/32/48px fallback.
- `../web/favicon-16.png`, `../web/favicon-32.png` — native-size PNGs.
- `../web/apple-touch-icon.png` — opaque 180px icon.
- `preview.png` — 512px preview on the dark site background.

Edit `../web/images/logo.svg`, then regenerate the other assets from the
repository root:

```sh
python3 website/tool/export_brand_assets.py
```

Requires `rsvg-convert` (librsvg) and `magick` (ImageMagick) for regeneration only.
