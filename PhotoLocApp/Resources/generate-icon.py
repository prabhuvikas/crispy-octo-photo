#!/usr/bin/env python3
"""
App Icon Generator for PhotoLoc
Converts app-icon.svg to all required iOS app icon sizes

Requirements:
    pip install cairosvg pillow

Usage:
    python generate-icon.py
"""

import os
from pathlib import Path

try:
    import cairosvg
    from PIL import Image
    import io
except ImportError:
    print("❌ Missing dependencies!")
    print("\nInstall with:")
    print("  pip install cairosvg pillow")
    print("\nOr use online converter:")
    print("  https://appicon.co/")
    exit(1)

# iOS App Icon Sizes (in pixels)
IOS_SIZES = {
    'AppIcon': [
        ('1024x1024', 1024),      # App Store
        ('60x60@3x', 180),        # iPhone Notification
        ('60x60@2x', 120),        # iPhone Notification
        ('29x29@3x', 87),         # iPhone Settings
        ('29x29@2x', 58),         # iPhone Settings
        ('40x40@3x', 120),        # iPhone Spotlight
        ('40x40@2x', 80),         # iPhone Spotlight
        ('76x76@2x', 152),        # iPad
        ('76x76@1x', 76),         # iPad
        ('83.5x83.5@2x', 167),    # iPad Pro
    ]
}

def convert_svg_to_png(svg_path, output_path, size):
    """Convert SVG to PNG at specified size"""
    print(f"  Generating {output_path.name}...")

    # Read SVG
    with open(svg_path, 'rb') as f:
        svg_data = f.read()

    # Convert to PNG with high quality
    png_data = cairosvg.svg2png(
        bytestring=svg_data,
        output_width=size,
        output_height=size,
        dpi=300
    )

    # Save PNG
    with open(output_path, 'wb') as f:
        f.write(png_data)

    # Verify it's a valid PNG
    img = Image.open(output_path)
    if img.size != (size, size):
        print(f"    ⚠️  Warning: Size is {img.size}, expected ({size}, {size})")

    return True

def generate_all_icons():
    """Generate all required iOS app icon sizes"""
    script_dir = Path(__file__).parent
    svg_path = script_dir / 'app-icon.svg'
    output_dir = script_dir / 'Generated'

    # Check if SVG exists
    if not svg_path.exists():
        print(f"❌ SVG file not found: {svg_path}")
        return False

    # Create output directory
    output_dir.mkdir(exist_ok=True)

    print("🎨 PhotoLoc App Icon Generator")
    print("=" * 50)
    print(f"SVG Source: {svg_path.name}")
    print(f"Output Directory: {output_dir}")
    print()

    success_count = 0
    total_count = len(IOS_SIZES['AppIcon'])

    print(f"Generating {total_count} icon sizes...")
    print()

    for name, size in IOS_SIZES['AppIcon']:
        output_path = output_dir / f'AppIcon-{name}.png'
        try:
            convert_svg_to_png(svg_path, output_path, size)
            success_count += 1
        except Exception as e:
            print(f"    ❌ Error: {e}")

    print()
    print("=" * 50)
    print(f"✅ Generated {success_count}/{total_count} icons successfully!")
    print()
    print("📁 Output location:")
    print(f"   {output_dir.absolute()}")
    print()
    print("Next steps:")
    print("  1. Review generated icons in the 'Generated' folder")
    print("  2. Add to Xcode:")
    print("     - Open Assets.xcassets")
    print("     - Drag icons to AppIcon")
    print("  3. Or use https://appicon.co/ to generate Assets folder")
    print()

    return success_count == total_count

if __name__ == '__main__':
    try:
        success = generate_all_icons()
        exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\n⚠️  Cancelled by user")
        exit(1)
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        exit(1)
