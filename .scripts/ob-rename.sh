#!/usr/bin/env bash
# ob-rename: Rename an Obsidian note and update all wikilinks across the vault.
# Usage: ob-rename <old-file-path> <new-file-path>
#
# Handles: [[name]], [[name|display]], [[name#heading]], [[name#heading|display]]
# Preserves display text, headings, and block refs.

set -euo pipefail

VAULT_ROOT="/data/projects/obsidian-vault"

if [[ $# -ne 2 ]]; then
  echo "Usage: ob-rename <old-path> <new-path>"
  echo "  Paths relative to vault root or absolute."
  echo "  Example: ob-rename 'Projects/Old Note.md' 'Knowledge/New Note.md'"
  exit 1
fi

old_path="$1"
new_path="$2"

# Resolve to absolute paths if relative
[[ "$old_path" != /* ]] && old_path="$VAULT_ROOT/$old_path"
[[ "$new_path" != /* ]] && new_path="$VAULT_ROOT/$new_path"

# Validate old file exists
if [[ ! -f "$old_path" ]]; then
  echo "Error: File not found: $old_path"
  exit 1
fi

# Extract note names (filename without .md extension)
old_name="$(basename "$old_path" .md)"
new_name="$(basename "$new_path" .md)"

if [[ "$old_name" == "$new_name" ]]; then
  echo "Note name unchanged (just moving). No wikilink updates needed."
  mkdir -p "$(dirname "$new_path")"
  mv "$old_path" "$new_path"
  echo "Moved: $old_path → $new_path"
  exit 0
fi

# Escape special regex characters in note names
escape_sed() {
  printf '%s' "$1" | sed 's/[&/\[\].$^*\\]/\\&/g'
}
escape_grep() {
  printf '%s' "$1" | sed 's/[[\.*^$()+?{|\\]/\\&/g'
}

old_escaped_grep="$(escape_grep "$old_name")"
old_escaped_sed="$(escape_sed "$old_name")"
new_escaped_sed="$(escape_sed "$new_name")"

# Find all files containing wikilinks to the old name
# Pattern matches: [[old_name]] or [[old_name| or [[old_name#
echo "Searching for wikilinks to \"$old_name\"..."
mapfile -t files < <(grep -rl "\[\[$old_escaped_grep\(\]\]\||\|#\)" "$VAULT_ROOT" --include="*.md" 2>/dev/null || true)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No wikilinks found referencing \"$old_name\"."
else
  echo "Found ${#files[@]} file(s) with wikilinks to update:"
  for f in "${files[@]}"; do
    rel="${f#$VAULT_ROOT/}"
    # Show matching lines before changing
    matches=$(grep -n "\[\[$old_escaped_grep\(\]\]\||\|#\)" "$f" | head -5)
    echo "  $rel"
    echo "$matches" | sed 's/^/    /'

    # Replace [[old_name with [[new_name, preserving everything after (|, #, ]])
    sed -i "s/\[\[$old_escaped_sed\(\]\]\|[|#]\)/\[\[$new_escaped_sed\1/g" "$f"
  done
fi

# Move the file
mkdir -p "$(dirname "$new_path")"
mv "$old_path" "$new_path"

echo ""
echo "✅ Renamed: $old_name → $new_name"
echo "   Moved:   $old_path → $new_path"
echo "   Updated: ${#files[@]} file(s)"
echo ""
echo "Remember to: cd $VAULT_ROOT && git add -A && git commit -m 'Rename: $old_name → $new_name' && git push"
