from PIL import Image
import numpy as np
import os
import sys

# === CONFIGURATION ===
# Use the same folder as the script
script_dir = os.path.dirname(os.path.abspath(__file__))
input_folder = os.path.join(script_dir, "Uncut")    # put original PNGs here
template_path = os.path.join(script_dir, "_cuttemplate.png")

# Output folders for each size
output_folders = {
    "256": os.path.join(script_dir, "Cut 256"),
    "512": os.path.join(script_dir, "Cut 512"),
}

# Output sizes
sizes = {
    "256": (256, 256),
    "512": (512, 512),
}

# Supported image extensions
valid_exts = (".png", ".jpg", ".jpeg", ".bmp", ".tiff")

# Ensure folders exist
if not os.path.exists(input_folder):
    print(f"⚠️ Input folder not found: {input_folder}")
    input("Press Enter to exit...")
    sys.exit()
for folder in output_folders.values():
    os.makedirs(folder, exist_ok=True)

# === STEP 1: Detect crop region from template ===
try:
    template = Image.open(template_path).convert("L")  # grayscale
except FileNotFoundError:
    print(f"⚠️ Template not found: {template_path}")
    input("Press Enter to exit...")
    sys.exit()

template_np = np.array(template)
ys, xs = np.where(template_np == 255)
if len(xs) == 0 or len(ys) == 0:
    print("⚠️ No white square detected in the template!")
    input("Press Enter to exit...")
    sys.exit()

left, upper, right, lower = xs.min(), ys.min(), xs.max(), ys.max()
crop_box = (left, upper, right + 1, lower + 1)
print(f"Detected crop box: {crop_box}")

# === STEP 2: Process all images ===
count = 0
for filename in os.listdir(input_folder):
    if filename.lower().endswith(valid_exts):
        img_path = os.path.join(input_folder, filename)
        try:
            with Image.open(img_path) as img:
                cropped = img.crop(crop_box)
                name, ext = os.path.splitext(filename)

                for size_label, size_value in sizes.items():
                    # === NEW: Check if output file already exists ===
                    save_filename = f"{name}{ext}"
                    save_path = os.path.join(output_folders[size_label], save_filename)

                    if os.path.exists(save_path):
                        print(f"⏭️ Skipping {size_label} - already exists: {save_filename}")
                        continue
                    # ===============================================

                    resized = cropped.resize(size_value, Image.LANCZOS)
                    resized.save(save_path)
                    print(f"✅ {filename} → {save_path}")

                count += 1
        except Exception as e:
            print(f"⚠️ Error processing {filename}: {e}")

print(f"\n🎉 Done! {count} images processed.")
input("Press Enter to close this window...")
