#!/bin/sh

TEMPLATE="$1"
SECTIONS="$2"
OUTDIR="${3:-.}"  # Default to current directory if not specified

# Create output directory if it doesn't exist
mkdir -p "$OUTDIR"

# Remove all existing files in the output directory
rm -f "$OUTDIR"/*

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

# Generate one PDF
generate() {
    section="$1"
    contentfile="$2"

    outtex="$WORKDIR/$section.tex"

    # Insert content into template
    awk -v cf="$contentfile" '
        /ADD_CONTENT_HERE/ {
            while ((getline line < cf) > 0)
                print line
            close(cf)
            next
        }
        { print }
    ' "$TEMPLATE" > "$outtex"

    # Compile
    pdflatex -interaction=nonstopmode \
             -output-directory="$WORKDIR" \
             "$outtex" >/dev/null 2>&1

    # Move PDF to output directory
    mv "$WORKDIR/$section.pdf" "$OUTDIR/$section.pdf"

    # ----------------------------------------
    # POST-PROCESSING HOOK
    # Example:
    # pdfcrop "$OUTDIR/$section.pdf" "$OUTDIR/$section.pdf"
    # ----------------------------------------
}

current=""
content=""
parsing=0  # Flag to indicate if we are inside a section

# Parse sections file
while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
        "%% SECTION:"*)
            if [ -n "$current" ]; then
                generate "$current" "$content"
            fi

            current=$(echo "$line" | sed 's/^%% SECTION:[[:space:]]*//')
            current=$(echo "$current" | tr -d '[:space:]')

            content="$WORKDIR/$current.content"
            : > "$content"

            parsing=1
            ;;
        *)
            if [ "$parsing" -eq 1 ]; then
                # Trim leading/trailing whitespace
                trimmed=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                # Only add non-empty lines
                [ -n "$trimmed" ] && printf "%s\n" "$trimmed" >> "$content"
            fi
            ;;
    esac
done < "$SECTIONS"

# Final section
if [ -n "$current" ]; then
    generate "$current" "$content"
fi
