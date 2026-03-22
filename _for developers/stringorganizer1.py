#!/usr/bin/env python3
"""
sync_localizations.py

Usage:
  - Run from the root of your project (so `resource/localization/` is reachable).
  - A small popup will ask for the base filename (default: unitvehicles).
  - Backups are written to resource_bak/localization/<lang>/<name>.properties
"""

import os
import shutil
import sys
import tkinter as tk
from tkinter import simpledialog, messagebox

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

ROOT = os.path.join(SCRIPT_DIR, "resource", "localization")
BACKUP_ROOT = os.path.join(SCRIPT_DIR, "resource_bak", "localization")
EXCLUDE_DIR = "en"
ENCODING = "utf-8"


def read_lines(path):
    with open(path, "r", encoding=ENCODING, errors="replace") as f:
        return [line.rstrip("\n") for line in f.readlines()]


def write_lines(path, lines):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding=ENCODING, newline="\r\n") as f:
        for ln in lines:
            f.write(ln + "\n")


def is_comment_or_blank(line):
    s = line.strip()
    return s == "" or s.startswith("#")


def parse_english_sequence(lines):
    """
    Given english file lines (full file), ignore the first two lines for structure purposes,
    and parse the rest into a sequence of items that preserves order:
      - ('comment', [lines...])
      - ('key', key, english_line)
    Note: commented-out keys (lines starting with '#' and then 'key=...') are treated as comments,
    and therefore won't be treated as active keys to insert.
    """
    seq = []
    effective = lines[2:] if len(lines) >= 2 else lines[:]
    buf_comments = []

    for line in effective:
        if is_comment_or_blank(line):
            buf_comments.append(line)
            continue

        # treat as key-line if contains '='
        if "=" in line:
            # flush comments first
            if buf_comments:
                seq.append(("comment", list(buf_comments)))
                buf_comments = []
            # extract key left of the first '='
            left = line.split("=", 1)[0].strip()
            seq.append(("key", left, line))
        else:
            # a non-comment, non key-looking line: treat as comment to be safe
            buf_comments.append(line)

    if buf_comments:
        seq.append(("comment", list(buf_comments)))

    return seq


def parse_target_file(lines):
    """
    Parse the target (localized) file to find:
      - first_two_lines: list length 0..2
      - active_values: dict key -> full value string (right of '=')
      - commented_key_lines: dict key -> the original commented line (e.g. '# key=VALUE' or '# key = VALUE')
      - other_lines: list of lines for possible analysis (not used in final write except for first two)
    """
    first_two = []
    if len(lines) >= 1:
        first_two.append(lines[0])
    if len(lines) >= 2:
        first_two.append(lines[1])

    active = {}
    commented = {}

    # scan every line (including first two) to capture existing keys and commented keys
    for ln in lines:
        stripped = ln.strip()
        if not stripped:
            continue
        if stripped.startswith("#"):
            # attempt to detect commented-out key pattern after the '#'
            after = stripped.lstrip("#").lstrip()
            if "=" in after:
                possible_key = after.split("=", 1)[0].strip()
                if possible_key:  # treat as commented-out key
                    # store the exact original commented line to preserve formatting
                    commented[possible_key] = ln
            continue
        # active key line
        if "=" in ln:
            k = ln.split("=", 1)[0].strip()
            v = ln.split("=", 1)[1]
            active[k] = v
    return first_two, active, commented


def ensure_backup(target_path, rel_lang_folder, filename):
    # copy to BACKUP_ROOT/<lang>/<filename>
    backup_dir = os.path.join(BACKUP_ROOT, rel_lang_folder)
    os.makedirs(backup_dir, exist_ok=True)
    backup_path = os.path.join(backup_dir, filename)
    shutil.copy2(target_path, backup_path)


def sync_file(base_sequence, base_lines, target_path, rel_lang_folder, filename):
    print(f"Processing {rel_lang_folder}/{filename} ...")
    target_lines = read_lines(target_path)
    first_two, active_values, commented_key_lines = parse_target_file(target_lines)

    # prepare output lines:
    out_lines = []

    # Keep first two lines from the localized file (if they exist).
    # If localized file has fewer than 2 lines, pad with english first two if available.
    # But the requirement said: keep those from the secondary files => we prefer target's lines.
    if first_two:
        out_lines.extend(first_two)
    else:
        # Try to take from target (empty); fallback to english base first two lines if present
        if len(base_lines) >= 1:
            out_lines.append(base_lines[0])
        if len(base_lines) >= 2:
            out_lines.append(base_lines[1])

    # For clarity, ensure there's at least one blank line after header if english had one originally:
    # But we will simply follow english ordering below.

    # Now iterate base_sequence and recreate the structure in English order,
    # substituting localized values when available, using existing commented lines when appropriate,
    # and adding commented english key lines (# <english_line>) when missing in target.
    seen_keys = set()

    for item in base_sequence:
        if item[0] == "comment":
            # append each comment line from English (preserve as-is)
            out_lines.extend(item[1])
            continue
        if item[0] == "key":
            _, key, english_line = item
            seen_keys.add(key)
            if key in active_values:
                # produce key=localized_value (note localized_value already contains everything after '=')
                out_lines.append(f"{key}={active_values[key].lstrip()}")
            elif key in commented_key_lines:
                # Use the exact commented line that exists in the target (preserve format)
                out_lines.append(commented_key_lines[key])
            else:
                # insert the English line but commented out with '# '
                # If the english line already has a leading '#', treat it as comment (shouldn't, as keys are active in english)
                out_lines.append("# " + english_line)
            continue

    # Done with english-sequence. We do NOT carry over keys from target that are not in english (they are removed).
    # But we might append any trailing comments that were present in English after the last item (base_sequence handles that).

    # Write backup then write file
    ensure_backup(target_path, rel_lang_folder, filename)
    write_lines(target_path, out_lines)
    print(f" → Wrote {len(out_lines)} lines to {rel_lang_folder}/{filename} (backup created).")


def main():
    # GUI prompt for filename
    root = tk.Tk()
    root.withdraw()
    fname = simpledialog.askstring(
        "Localization sync",
        "Enter base filename (without .properties):",
        initialvalue="unitvehicles",
        parent=root,
    )
    if not fname:
        messagebox.showinfo("Cancelled", "Operation cancelled by user.")
        return

    filename = fname.strip() + ".properties"
    base_path = os.path.join(ROOT, "en", filename)

    if not os.path.isfile(base_path):
        messagebox.showerror("File not found", f"Base file not found:\n{base_path}")
        return

    # read english file
    base_lines = read_lines(base_path)
    if len(base_lines) == 0:
        messagebox.showerror("Empty file", f"Base file appears empty: {base_path}")
        return

    base_sequence = parse_english_sequence(base_lines)

    # gather target language folders
    if not os.path.isdir(ROOT):
        messagebox.showerror("Missing root", f"Localization root not found: {ROOT}")
        return

    langs = []
    for name in os.listdir(ROOT):
        p = os.path.join(ROOT, name)
        if not os.path.isdir(p):
            continue
        if name == EXCLUDE_DIR:
            continue
        langs.append(name)

    if not langs:
        messagebox.showinfo("No languages", "No language folders found to process.")
        return

    # create backup root dir
    os.makedirs(BACKUP_ROOT, exist_ok=True)

    # Process each language folder
    processed = []
    for lang in sorted(langs):
        target_dir = os.path.join(ROOT, lang)
        target_file = os.path.join(target_dir, filename)
        if not os.path.isfile(target_file):
            print(f"Skipping {lang}: {filename} not present.")
            continue
        try:
            sync_file(base_sequence, base_lines, target_file, lang, filename)
            processed.append(lang)
        except Exception as exc:
            print(f"Error processing {lang}: {exc}")

    message = f"Done. Processed languages: {', '.join(processed)}" if processed else "Done. No files were updated."
    messagebox.showinfo("Completed", message)


if __name__ == "__main__":
    main()
