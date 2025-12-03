#!/usr/bin/env python3
"""
Generate iOS app icons from a source image.
Requires PIL/Pillow: pip install Pillow
"""

from PIL import Image
import os
import json

# Icon sizes required for iOS
ICON_SIZES = [
    ("Icon-1024.png", 1024),  # App Store
    ("Icon-180.png", 180),     # iPhone 3x
    ("Icon-167.png", 167),     # iPad Pro
    ("Icon-152.png", 152),     # iPad 2x
    ("Icon-120.png", 120),     # iPhone 2x
    ("Icon-87.png", 87),       # iPhone 3x settings
    ("Icon-80.png", 80),       # iPad 2x settings
    ("Icon-76.png", 76),       # iPad
    ("Icon-60.png", 60),       # iPhone
    ("Icon-58.png", 58),       # iPhone 2x settings
    ("Icon-40.png", 40),       # iPad/iPhone
    ("Icon-29.png", 29),       # Settings
    ("Icon-20.png", 20),       # Notification
]

def generate_icons(source_image_path, output_dir):
    """Generate all required icon sizes from source image."""
    
    # Open source image
    print(f"Opening source image: {source_image_path}")
    img = Image.open(source_image_path)
    
    # Convert to RGB if necessary
    if img.mode != 'RGB':
        img = img.convert('RGB')
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    print(f"\nGenerating icons in: {output_dir}")
    print("-" * 50)
    
    # Generate each icon size
    for filename, size in ICON_SIZES:
        output_path = os.path.join(output_dir, filename)
        
        # Resize image with high-quality resampling
        resized = img.resize((size, size), Image.Resampling.LANCZOS)
        
        # Save with high quality
        resized.save(output_path, 'PNG', quality=100)
        print(f"✓ Generated {filename} ({size}x{size}px)")
    
    print("-" * 50)
    print(f"\n✓ Successfully generated {len(ICON_SIZES)} icon sizes!")
    
    # Create Contents.json for Xcode
    create_contents_json(output_dir)

def create_contents_json(output_dir):
    """Create Contents.json file for Xcode asset catalog."""
    
    contents = {
        "images": [
            {
                "filename": "Icon-1024.png",
                "idiom": "universal",
                "platform": "ios",
                "size": "1024x1024"
            },
            {
                "filename": "Icon-20.png",
                "idiom": "iphone",
                "scale": "1x",
                "size": "20x20"
            },
            {
                "filename": "Icon-40.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "20x20"
            },
            {
                "filename": "Icon-60.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "20x20"
            },
            {
                "filename": "Icon-29.png",
                "idiom": "iphone",
                "scale": "1x",
                "size": "29x29"
            },
            {
                "filename": "Icon-58.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "29x29"
            },
            {
                "filename": "Icon-87.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "29x29"
            },
            {
                "filename": "Icon-40.png",
                "idiom": "iphone",
                "scale": "1x",
                "size": "40x40"
            },
            {
                "filename": "Icon-80.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "40x40"
            },
            {
                "filename": "Icon-120.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "40x40"
            },
            {
                "filename": "Icon-120.png",
                "idiom": "iphone",
                "scale": "2x",
                "size": "60x60"
            },
            {
                "filename": "Icon-180.png",
                "idiom": "iphone",
                "scale": "3x",
                "size": "60x60"
            },
            {
                "filename": "Icon-20.png",
                "idiom": "ipad",
                "scale": "1x",
                "size": "20x20"
            },
            {
                "filename": "Icon-40.png",
                "idiom": "ipad",
                "scale": "2x",
                "size": "20x20"
            },
            {
                "filename": "Icon-29.png",
                "idiom": "ipad",
                "scale": "1x",
                "size": "29x29"
            },
            {
                "filename": "Icon-58.png",
                "idiom": "ipad",
                "scale": "2x",
                "size": "29x29"
            },
            {
                "filename": "Icon-40.png",
                "idiom": "ipad",
                "scale": "1x",
                "size": "40x40"
            },
            {
                "filename": "Icon-80.png",
                "idiom": "ipad",
                "scale": "2x",
                "size": "40x40"
            },
            {
                "filename": "Icon-76.png",
                "idiom": "ipad",
                "scale": "1x",
                "size": "76x76"
            },
            {
                "filename": "Icon-152.png",
                "idiom": "ipad",
                "scale": "2x",
                "size": "76x76"
            },
            {
                "filename": "Icon-167.png",
                "idiom": "ipad",
                "scale": "2x",
                "size": "83.5x83.5"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    
    json_path = os.path.join(output_dir, "Contents.json")
    with open(json_path, 'w') as f:
        json.dump(contents, f, indent=2)
    
    print(f"\n✓ Created Contents.json")

if __name__ == "__main__":
    # Set paths
    source_image = "AppIconSource/app_icon_source.jpg"
    output_directory = "CafeMeetup/Assets.xcassets/AppIcon.appiconset"
    
    print("=" * 50)
    print("CafeMeetup App Icon Generator")
    print("=" * 50)
    
    # Check if source image exists
    if not os.path.exists(source_image):
        print(f"\n❌ Error: Source image not found at {source_image}")
        print("\nPlease save your image as 'AppIconSource/app_icon_source.jpg'")
        exit(1)
    
    # Generate icons
    try:
        generate_icons(source_image, output_directory)
        print("\n" + "=" * 50)
        print("NEXT STEPS:")
        print("=" * 50)
        print("1. Open your project in Xcode")
        print("2. The icons have been automatically added to Assets.xcassets/AppIcon.appiconset")
        print("3. Build and run your app to see the new icon!")
        print("=" * 50 + "\n")
    except Exception as e:
        print(f"\n❌ Error generating icons: {e}")
        exit(1)
