#!/usr/bin/env python3
import os
import re
import sys

# Set the working directory to the folder where the script resides
script_dir = os.path.dirname(os.path.realpath(sys.argv[0]))
os.chdir(script_dir)

def list_files():
    # List all .lua or .txt files in the current folder
    files = [f for f in os.listdir('.') if f.endswith(('.lua', '.txt'))]
    return files

def convert_file(file_path):
    backup_path = file_path + ".bak"

    # Read the original content
    with open(file_path, 'r', encoding='utf-8') as f:
        text = f.read()

    # Regex replacement: replace "#…" with UVString("…")
    pattern = r'"#([^"]+)"'
    replacement = r'UVString("\1")'
    new_text = re.sub(pattern, replacement, text)

    # Backup original file if it doesn't already exist
    if not os.path.exists(backup_path):
        os.rename(file_path, backup_path)
    else:
        print(f"Backup already exists: {backup_path}")

    # Write converted content back to the original file
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(new_text)

    print(f"[✓] Converted {file_path} (backup saved as {backup_path})")

def main():
    print("=== UVString Converter ===")
    while True:
        files = list_files()
        if not files:
            print("No .lua or .txt files found in this folder.")
            input("Press Enter to exit...")
            break

        print("\nFiles in current folder:")
        for i, f in enumerate(files):
            print(f"{i+1}. {f}")

        print("0. Exit")
        choice = input("\nEnter the number of the file to convert (0 to exit): ").strip()
        if choice == "0":
            print("Exiting...")
            break

        if not choice.isdigit() or int(choice) < 1 or int(choice) > len(files):
            print("Invalid choice, try again.")
            continue

        index = int(choice) - 1
        file_to_convert = files[index]
        convert_file(file_to_convert)

        print("\nYou can choose another file or type 0 to exit.")

if __name__ == "__main__":
    main()
