#!/bin/bash

# --- Configuration ---
YAML_URL="https://raw.githubusercontent.com/Teknicallity/unix-setup-playbook/refs/heads/main/config.yaml"
# To use a local file instead, comment out the curl and set YAML_FILE directly
# YAML_FILE="/path/to/your/config.yml"

set -euo pipefail

# --- Fetch the YAML ---
YAML_FILE=$(mktemp)
trap "rm -f $YAML_FILE" EXIT
curl -sL "$YAML_URL" -o "$YAML_FILE"

# --- Parse known apps from YAML ---
# We need: apps, brew_only_apps, gui_apps, brew_cask_apps, mas_installed_apps
# Using grep/sed since yq may not be installed

parse_list() {
    # Extracts simple "- value" items under a given key, stops at next top-level key
    local key="$1" file="$2"
    sed -n "/^${key}:/,/^[a-z_]*:/p" "$file" \
        | grep '^\s*-' \
        | sed 's/^[[:space:]]*-[[:space:]]*//' \
        | tr -d '"' \
        | tr '[:upper:]' '[:lower:]'
}

parse_mas_ids() {
    # Extracts MAS app IDs from {id: XXXX, name: "..."} entries
    sed -n '/^mas_installed_apps:/,/^[a-z_]*:/p' "$1" \
        | grep -oE 'id:[[:space:]]*[0-9]+' \
        | awk -F: '{print $2}' \
        | tr -d ' '
}

# Build the set of known formulae (lowercased)
known_formulae=$(
    {
        parse_list "apps" "$YAML_FILE"
        parse_list "brew_only_apps" "$YAML_FILE"
    } | sort -u
)

# Build the set of known casks (lowercased)
known_casks=$(
    {
        parse_list "gui_apps" "$YAML_FILE"
        parse_list "brew_cask_apps" "$YAML_FILE"
    } | sort -u
)

# Build the set of known MAS app IDs
known_mas_ids=$(parse_mas_ids "$YAML_FILE" | sort -u)

# --- Get installed apps ---
installed_formulae=$(brew list --formula -1 2>/dev/null | tr '[:upper:]' '[:lower:]' | sort -u)
installed_casks=$(brew list --cask -1 2>/dev/null | tr '[:upper:]' '[:lower:]' | sort -u)

# mas list outputs "APPID  AppName (version)"
installed_mas_ids=$(mas list 2>/dev/null | awk '{print $1}' | sort -u)

# --- Diff: installed but NOT in your YAML ---

echo "========================================="
echo " Homebrew formulae NOT in your YAML"
echo "========================================="
comm -23 <(echo "$installed_formulae") <(echo "$known_formulae") || true

echo ""
echo "========================================="
echo " Homebrew casks NOT in your YAML"
echo "========================================="
comm -23 <(echo "$installed_casks") <(echo "$known_casks") || true

echo ""
echo "========================================="
echo " Mac App Store apps NOT in your YAML"
echo "========================================="
unknown_mas=$(comm -23 <(echo "$installed_mas_ids") <(echo "$known_mas_ids"))
if [[ -n "$unknown_mas" ]]; then
    # Resolve IDs back to names for readability
    mas_full=$(mas list 2>/dev/null)
    while IFS= read -r app_id; do
        name=$(echo "$mas_full" | grep "^${app_id} " | sed "s/^${app_id} //" | sed 's/ (.*)//')
        echo "$app_id  $name"
    done <<< "$unknown_mas"
else
    echo "(none)"
fi