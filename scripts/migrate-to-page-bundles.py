#!/usr/bin/env python3
"""Migrate Hugo flat content files to page bundles.

For each .md post in content/post/, this script:
1. Parses TOML frontmatter to extract slug, thumbnailImage, coverImage
2. Creates a bundle directory named after the slug
3. Moves the .md file to index.md inside the bundle
4. Copies referenced images from static/ into the bundle
5. Rewrites image paths from absolute (/images/...) to relative (filename)
"""

import os
import re
import shutil
import sys

# Use tomllib (Python 3.11+) or fall back to tomli
try:
    import tomllib
except ImportError:
    try:
        import tomli as tomllib
    except ImportError:
        print("ERROR: Python 3.11+ required (for tomllib), or install tomli: pip install tomli")
        sys.exit(1)

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONTENT_DIR = os.path.join(ROOT, "content", "post")
STATIC_DIR = os.path.join(ROOT, "static")

# Stats
stats = {"posts": 0, "images_copied": 0, "warnings": []}


def parse_frontmatter(text):
    """Extract TOML frontmatter between the first pair of +++ delimiters.

    Returns (parsed_dict, end_offset) where end_offset is the character
    position just after the closing +++.
    """
    match = re.match(r"^\+\+\+\n(.*?)\n\+\+\+", text, re.DOTALL)
    if not match:
        return None, 0
    toml_text = match.group(1)
    try:
        return tomllib.loads(toml_text), match.end()
    except Exception as e:
        return None, 0


def find_code_block_ranges(text):
    """Return list of (start, end) character offsets for fenced code blocks.

    Matches ``` and ~~~ style fences.
    """
    ranges = []
    for m in re.finditer(r"^(`{3,}|~{3,}).*?\n.*?^\1\s*$", text, re.MULTILINE | re.DOTALL):
        ranges.append((m.start(), m.end()))
    return ranges


def in_code_block(pos, ranges):
    """Check if a character position falls inside any code block range."""
    for start, end in ranges:
        if start <= pos <= end:
            return True
    return False


def extract_image_refs(text, frontmatter, code_block_ranges, fm_end):
    """Extract all /images/ references from frontmatter and markdown body.

    Returns list of (ref_type, key_or_alt, abs_path) tuples.
    ref_type is 'frontmatter' or 'markdown'.
    """
    refs = []

    # Frontmatter image fields
    for key in ("thumbnailImage", "coverImage"):
        val = frontmatter.get(key, "")
        if val and val.startswith("/images/"):
            refs.append(("frontmatter", key, val))

    # Markdown image syntax: ![alt](/images/path)
    for m in re.finditer(r"!\[([^\]]*)\]\((/images/[^)\s]+)\)", text):
        if m.start() > fm_end and not in_code_block(m.start(), code_block_ranges):
            refs.append(("markdown", m.group(1), m.group(2)))

    return refs


def rewrite_frontmatter(text, path_map):
    """Rewrite image paths in the TOML frontmatter section only."""
    match = re.match(r"^(\+\+\+\n)(.*?)(\n\+\+\+)", text, re.DOTALL)
    if not match:
        return text

    prefix = match.group(1)
    fm_text = match.group(2)
    suffix = match.group(3)
    rest = text[match.end():]

    for abs_path, local_name in path_map.items():
        # Replace the exact value in frontmatter TOML
        fm_text = fm_text.replace(f'"{abs_path}"', f'"{local_name}"')

    return prefix + fm_text + suffix + rest


def rewrite_markdown_images(text, path_map, code_block_ranges, fm_end):
    """Rewrite markdown image references outside of code blocks and frontmatter."""
    def replacer(m):
        if m.start() <= fm_end:
            return m.group(0)
        if in_code_block(m.start(), code_block_ranges):
            return m.group(0)
        abs_path = m.group(2)
        if abs_path in path_map:
            return f"![{m.group(1)}]({path_map[abs_path]})"
        return m.group(0)

    return re.sub(r"!\[([^\]]*)\]\((/images/[^)\s]+)\)", replacer, text)


def migrate_post(md_path):
    """Migrate a single post file to a page bundle."""
    with open(md_path, "r", encoding="utf-8") as f:
        text = f.read()

    frontmatter, fm_end = parse_frontmatter(text)
    if frontmatter is None:
        stats["warnings"].append(f"SKIP: No TOML frontmatter in {md_path}")
        return

    slug = frontmatter.get("slug")
    if not slug:
        # Fallback to filename without extension
        slug = os.path.splitext(os.path.basename(md_path))[0]
        stats["warnings"].append(f"WARN: No slug in {md_path}, using filename: {slug}")

    parent_dir = os.path.dirname(md_path)
    bundle_dir = os.path.join(parent_dir, slug)

    # Avoid collision if bundle dir already exists (shouldn't happen)
    if os.path.exists(bundle_dir):
        stats["warnings"].append(f"WARN: Bundle dir already exists: {bundle_dir}")
        return

    os.makedirs(bundle_dir, exist_ok=True)

    code_block_ranges = find_code_block_ranges(text)
    refs = extract_image_refs(text, frontmatter, code_block_ranges, fm_end)

    # Track used filenames to handle collisions
    used_filenames = set()
    # Maps absolute path -> local filename
    path_map = {}

    for ref_type, key_or_alt, abs_path in refs:
        if abs_path in path_map:
            # Already processed this exact path
            continue

        src = os.path.join(STATIC_DIR, abs_path.lstrip("/"))
        if not os.path.exists(src):
            stats["warnings"].append(f"WARN: Image not found: {src} (referenced in {md_path})")
            continue

        filename = os.path.basename(abs_path)

        # Handle filename collision
        if filename in used_filenames:
            base, ext = os.path.splitext(filename)
            counter = 2
            while f"{base}-{counter}{ext}" in used_filenames:
                counter += 1
            filename = f"{base}-{counter}{ext}"

        used_filenames.add(filename)
        path_map[abs_path] = filename

        shutil.copy2(src, os.path.join(bundle_dir, filename))
        stats["images_copied"] += 1

    # Rewrite references in the text
    new_text = rewrite_frontmatter(text, path_map)
    # Recompute code block ranges after frontmatter rewrite (offsets may shift)
    new_code_block_ranges = find_code_block_ranges(new_text)
    new_fm_match = re.match(r"^\+\+\+\n.*?\n\+\+\+", new_text, re.DOTALL)
    new_fm_end = new_fm_match.end() if new_fm_match else 0
    new_text = rewrite_markdown_images(new_text, path_map, new_code_block_ranges, new_fm_end)

    # Write index.md
    index_path = os.path.join(bundle_dir, "index.md")
    with open(index_path, "w", encoding="utf-8") as f:
        f.write(new_text)

    # Remove original file
    os.remove(md_path)

    stats["posts"] += 1
    print(f"  Migrated: {md_path} -> {bundle_dir}/ ({len(path_map)} images)")


def remove_empty_dirs(path):
    """Remove empty directories recursively."""
    removed = 0
    for dirpath, dirnames, filenames in os.walk(path, topdown=False):
        if not filenames and not dirnames:
            os.rmdir(dirpath)
            removed += 1
    return removed


def main():
    print(f"Hugo Page Bundle Migration")
    print(f"  Content dir: {CONTENT_DIR}")
    print(f"  Static dir:  {STATIC_DIR}")
    print()

    # Collect all .md files
    md_files = []
    for dirpath, dirnames, filenames in os.walk(CONTENT_DIR):
        for fn in filenames:
            if fn.endswith(".md"):
                md_files.append(os.path.join(dirpath, fn))

    md_files.sort()
    print(f"Found {len(md_files)} posts to migrate\n")

    for md_path in md_files:
        migrate_post(md_path)

    # Clean up empty directories
    removed = remove_empty_dirs(CONTENT_DIR)
    print(f"\nRemoved {removed} empty directories")

    print(f"\n{'='*50}")
    print(f"Migration complete!")
    print(f"  Posts migrated: {stats['posts']}")
    print(f"  Images copied:  {stats['images_copied']}")
    if stats["warnings"]:
        print(f"\nWarnings ({len(stats['warnings'])}):")
        for w in stats["warnings"]:
            print(f"  {w}")


if __name__ == "__main__":
    main()
