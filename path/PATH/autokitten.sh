#!/usr/bin/env bash
# Automatically create kitty multiplexer session at fuzzy found location

print_help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] [target_dir]

Options:
  -h, --help        Show this help message and exit

Arguments:
  target_dir        Optional: target directory to open. If not provided, fzf is used.
EOF
}

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h | --help)
            print_help
            exit 0
            ;;
        --) # end of options
            shift
            break
            ;;
        -*)
            echo "Unknown option: $1"
            print_help
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

eval "$(zoxide init --cmd cd bash)"

# Determine target directory
if [ -n "$1" ]; then
    TARGET="$1"
    cd "$TARGET" || exit
    TARGET=$(pwd)
else
    cdi
    TARGET=$(pwd)
fi



# Set main tab title
kitten @ set-tab-title " "

# Launch opencode tab
kitten @ launch --cwd current --type tab --tab-title " " opencode

# Launch lazygit tab (only if git repo)
if [ -d "$TARGET/.git" ] || git -C "$TARGET" rev-parse --is-inside-work-tree &>/dev/null; then
    kitten @ launch --cwd current --type tab --tab-title " " lazygit
fi

# Launch yazi tab
kitten @ launch --cwd current --type tab --tab-title " " yazi

# Launch empty terminal tab
kitten @ launch --cwd current --type tab --tab-title " "

# Return to main tab
kitten @ focus-tab --match title:" "

# Run nvim in foreground on main tab
nvim

