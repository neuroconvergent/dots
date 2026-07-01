#!/usr/bin/env bash
set -e -u -o pipefail

# Launch tuicr as a new kitty tab to review git changes.
# Matches the user's autokitten.sh layout (tuicr lives in its own kitty tab).

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info()  { echo -e "${GREEN}[tuicr]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[tuicr]${NC} $*"; }
log_error() { echo -e "${RED}[tuicr]${NC} $*"; }

usage() {
  cat << EOF
Usage: $(basename "$0") [directory]

Launch tuicr in a new kitty tab to review git changes.

Arguments:
  directory    Git repository directory to review (default: current directory)

Environment variables:
  TUICR_TAB_TITLE   Title for the new kitty tab (default: "Review")

Examples:
  $(basename "$0")                    # Review changes in current directory
  $(basename "$0") ~/project          # Review changes in ~/project
  TUICR_TAB_TITLE="PR #42" $(basename "$0")
EOF
}

check_kitty() {
  if [[ -z "${KITTY_WINDOW_ID:-}" ]] && [[ "${TERM:-}" != "xterm-kitty" ]]; then
    return 1
  fi
  if ! command -v kitten &>/dev/null; then
    log_error "kitten not found on PATH"
    return 1
  fi
  # Verify remote control is reachable
  if ! kitten @ ls &>/dev/null; then
    log_error "kitten @ remote control is not reachable."
    log_error "Ensure kitty is started with --single-instance --listen-on=unix:/tmp/kitty"
    log_error "or set allow_remote_control yes in kitty.conf. Current KITTY_LISTEN_ON=${KITTY_LISTEN_ON:-<unset>}"
    return 1
  fi
  return 0
}

check_tuicr() {
  if ! command -v tuicr &> /dev/null; then
    log_error "tuicr not found. Install it first."
    return 1
  fi
  return 0
}

check_tuicr_stdout_support() {
  tuicr --help 2>&1 | grep -q -- '--stdout'
}

check_git_repo() {
  local dir="$1"
  if ! git -C "$dir" rev-parse --git-dir &> /dev/null; then
    log_error "Not a git repository: $dir"
    return 1
  fi
  return 0
}

detect_existing_tuicr_tab() {
  # Returns 0 if a tab whose current foreground process is `tuicr` already exists.
  # `kitten @ ls` JSON: tabs[].windows[].foreground_processes[] is a list of {pid, cmdline}
  # cmdline is the full command line; we match a leading tuicr token.
  kitten @ ls 2>/dev/null | jq -e '
    [.tabs[].windows[].foreground_processes[]
      | select((.cmdline // "") | split(" ")[0] | test("(^|.*/)tuicr$"))]
    | length > 0
  ' >/dev/null 2>&1
}

launch_tuicr_tab() {
  local target_dir="$1"
  local title="${TUICR_TAB_TITLE:-Review}"

  log_info "Launching tuicr in a new kitty tab"
  log_info "Directory: $target_dir"
  log_info "Tab title: $title"

  local output_file=""
  local tuicr_cmd="tuicr"
  local use_stdout=false

  if check_tuicr_stdout_support; then
    output_file=$(mktemp /tmp/tuicr-output.XXXXXX)
    tuicr_cmd="tuicr --stdout > '$output_file'"
    use_stdout=true
    log_info "Using --stdout mode (output will be captured)"
  else
    log_warn "tuicr --stdout not supported, output will be copied to clipboard"
  fi

  # Create the tab in the background (-d) so we keep our foreground shell.
  # The tab runs tuicr; on exit it prints a sentinel we can key on.
  local sentinel="TUICR_DONE_$$_$(date +%s%N)"
  local sh_cmd="cd '$target_dir' && $tuicr_cmd; printf '\\n%s\\n' '$sentinel'"

  local new_tab_id
  new_tab_id=$(kitten @ launch --type tab --tab-title "$title" \
    --cwd "$target_dir" -d --no-response bash -lc "$sh_cmd")

  log_info "tuicr is running in tab $new_tab_id"
  log_info "Waiting for tuicr to exit..."

  # Poll the new tab's last output line until the sentinel appears or the tab closes.
  while true; do
    if ! kitten @ focus-tab --match "id:$new_tab_id" 2>/dev/null; then
      break
    fi
    local last_line
    last_line=$(kitten @ get-text --match "id:$new_tab_id" 2>/dev/null | tail -n 2 | grep -F "$sentinel" || true)
    if [[ -n "$last_line" ]]; then
      break
    fi
    sleep 2
  done

  log_info "tuicr finished"

  if [[ "$use_stdout" == true ]] && [[ -f "$output_file" ]]; then
    if [[ -s "$output_file" ]]; then
      echo ""
      echo "=== TUICR INSTRUCTIONS ==="
      cat "$output_file"
      echo "=== END TUICR INSTRUCTIONS ==="
    else
      log_info "No instructions exported from tuicr"
      log_info "If you exported to clipboard, paste the instructions here"
    fi
    rm -f "$output_file"
  else
    log_info "If you exported instructions, they are in your clipboard - paste them here"
  fi
}

main() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  if ! check_tuicr; then
    exit 1
  fi

  local target_dir="${1:-.}"
  target_dir=$(cd "$target_dir" && pwd)

  if ! check_git_repo "$target_dir"; then
    exit 1
  fi

  if ! check_kitty; then
    log_error "Not running inside a kitty instance with remote control enabled!"
    echo ""
    echo "tuicr-wrapper-kitty.sh requires kitty with remote control so it can"
    echo "open a new tab and wait on the TUI. Options:"
    echo ""
    echo "  1. Run opencode inside a kitty session started with:"
    echo "       kitty --single-instance --listen-on=unix:/tmp/kitty"
    echo "  2. Or set 'allow_remote_control yes' in kitty.conf."
    echo ""
    echo "Then run /tuicr again. (The user's autokitten.sh launches kitty with"
    echo "remote control, so this is usually already satisfied.)"
    exit 1
  fi

  if detect_existing_tuicr_tab; then
    log_warn "tuicr appears to already be running in another kitty tab"
    log_info "Switch tabs with Ctrl+Shift+Right / Ctrl+Shift+Left"
    exit 0
  fi

  launch_tuicr_tab "$target_dir"
}

main "$@"