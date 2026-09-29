#!/usr/bin/env python3
"""Export the KF mark from web/images/logo.svg (requires librsvg and ImageMagick)."""
from pathlib import Path
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
WEB = ROOT / 'web'
SOURCE = WEB / 'images/logo.svg'


def run(*args):
    subprocess.run([str(arg) for arg in args], check=True)


def render(source, size, target):
    run('rsvg-convert', '-w', size, '-h', size, source, '-o', target)


def main():
    for tool in ('rsvg-convert', 'magick'):
        if not shutil.which(tool):
            raise SystemExit(f'Missing required tool: {tool}')

    svg = SOURCE.read_text()
    # Darker versions of the same gradient stops for light page surfaces.
    light = svg
    for dark_color, light_color in {
        '#00f0ff': '#008799', '#00cbdc': '#0096a7', '#007baa': '#005b7c',
        '#007397': '#005572', '#00bbd2': '#008ba3', '#00e5eb': '#009cab',
        '#00f0ed': '#00a8af', '#ff8a20': '#b9610d', '#ffb020': '#c97200',
        '#ffe451': '#e7ac26', '#008cba': '#006b8c', '#00ddd9': '#00a79f',
        '#8ce8aa': '#8fc683', '#ffe56b': '#ecc95d', '#ff9225': '#b96714',
        '#ffdb46': '#dfa322',
    }.items():
        light = light.replace(dark_color, light_color)
    (WEB / 'images/logo-light.svg').write_text(light)

    favicon = svg.replace('width="96" height="96"', 'width="16" height="16"', 1)
    favicon = favicon.replace('</defs>', '</defs>\n  <rect width="96" height="96" rx="18" fill="#070b0e"/>', 1)
    (WEB / 'favicon.svg').write_text(favicon)

    for size in (16, 32):
        render(WEB / 'favicon.svg', size, WEB / f'favicon-{size}.png')
    with tempfile.TemporaryDirectory(prefix='keyed-form-brand-') as temporary:
        temp = Path(temporary)
        render(WEB / 'favicon.svg', 48, temp / 'favicon-48.png')
        run('magick', WEB / 'favicon-16.png', WEB / 'favicon-32.png',
            temp / 'favicon-48.png', WEB / 'favicon.ico')
        render(SOURCE, 180, temp / 'apple.png')
        run('magick', temp / 'apple.png', '-background', '#070b0e',
            '-alpha', 'remove', '-alpha', 'off', WEB / 'apple-touch-icon.png')
        render(SOURCE, 512, WEB / 'images/logo.png')
        run('magick', WEB / 'images/logo.png', '-background', '#070b0e',
            '-alpha', 'remove', '-alpha', 'off', ROOT / 'branding/preview.png')


if __name__ == '__main__':
    main()
