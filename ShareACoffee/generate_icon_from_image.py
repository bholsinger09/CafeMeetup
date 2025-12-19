#!/usr/bin/env python3
"""
Generate ShareACoffee App Icon from source image
Takes the provided coffee shop image and generates all required iOS icon sizes
"""

from PIL import Image, ImageDraw, ImageFilter
import os

def create_rounded_icon(input_image, size, output_path, corner_radius_percent=0.2237):
    """
    Create a rounded corner icon from the input image
    iOS uses approximately 22.37% corner radius
    """
    # Resize image to target size
    img = input_image.copy()
    img = img.resize((size, size), Image.Resampling.LANCZOS)
    
    # Create rounded mask
    mask = Image.new('L', (size, size), 0)
    draw = ImageDraw.Draw(mask)
    
    # Calculate corner radius
    corner_radius = int(size * corner_radius_percent)
    
    # Draw rounded rectangle
    draw.rounded_rectangle(
        [(0, 0), (size, size)],
        radius=corner_radius,
        fill=255
    )
    
    # Apply mask
    output = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    output.paste(img, (0, 0))
    output.putalpha(mask)
    
    # Convert to RGB for PNG
    if size == 1024:  # App Store icon should not have transparency
        background = Image.new('RGB', (size, size), (255, 255, 255))
        background.paste(output, mask=output.split()[3])
        output = background
    
    # Save
    output.save(output_path, 'PNG', quality=100)
    print(f"✓ Generated {size}x{size} icon: {output_path}")

def main():
    """Generate all required icon sizes for iOS"""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Look for the source image (should be saved in the same directory)
    source_image_path = os.path.join(script_dir, "coffee_source.jpg")
    
    if not os.path.exists(source_image_path):
        print(f"Error: Source image not found at {source_image_path}")
        print("Please save the coffee shop image as 'coffee_source.jpg' in the project directory")
        return
    
    # Load source image
    print(f"Loading source image: {source_image_path}")
    source_img = Image.open(source_image_path)
    
    # Convert to RGB if necessary
    if source_img.mode != 'RGB':
        source_img = source_img.convert('RGB')
    
    # Crop to square (center crop)
    width, height = source_img.size
    min_dim = min(width, height)
    left = (width - min_dim) // 2
    top = (height - min_dim) // 2
    right = left + min_dim
    bottom = top + min_dim
    source_img = source_img.crop((left, top, right, bottom))
    
    # Enhance image slightly for icon use
    from PIL import ImageEnhance
    enhancer = ImageEnhance.Contrast(source_img)
    source_img = enhancer.enhance(1.1)
    enhancer = ImageEnhance.Sharpness(source_img)
    source_img = enhancer.enhance(1.2)
    
    assets_path = os.path.join(script_dir, "CafeMeetup", "Assets.xcassets", "AppIcon.appiconset")
    
    # Create output directory if it doesn't exist
    os.makedirs(assets_path, exist_ok=True)
    
    # iOS icon sizes required
    icon_sizes = [
        (20, "20x20"),
        (29, "29x29"),
        (40, "40x40"),
        (58, "58x58"),
        (60, "60x60"),
        (76, "76x76"),
        (80, "80x80"),
        (87, "87x87"),
        (120, "120x120"),
        (152, "152x152"),
        (167, "167x167"),
        (180, "180x180"),
        (1024, "1024x1024")
    ]
    
    print("\nGenerating ShareACoffee app icons...")
    print("=" * 60)
    
    for size, name in icon_sizes:
        output_path = os.path.join(assets_path, f"icon_{name}.png")
        create_rounded_icon(source_img, size, output_path)
    
    # Update Contents.json
    contents_json = """{
  "images" : [
    {
      "filename" : "icon_40x40.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "icon_60x60.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "icon_58x58.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "icon_87x87.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "icon_80x80.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "icon_120x120.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "icon_120x120.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "icon_180x180.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "icon_20x20.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "filename" : "icon_40x40.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "icon_29x29.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "icon_58x58.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "icon_40x40.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "filename" : "icon_80x80.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "icon_76x76.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "filename" : "icon_152x152.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "icon_167x167.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "filename" : "icon_1024x1024.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}"""
    
    contents_path = os.path.join(assets_path, "Contents.json")
    with open(contents_path, 'w') as f:
        f.write(contents_json)
    
    print("=" * 60)
    print("✓ All icons generated successfully!")
    print(f"✓ Updated Contents.json")
    print(f"\nIcons saved to: {assets_path}")
    print("\nNext steps:")
    print("1. Open Xcode and clean build folder (Cmd+Shift+K)")
    print("2. Build and run the project")
    print("3. The new ShareACoffee icon will appear on your device")

if __name__ == "__main__":
    main()
