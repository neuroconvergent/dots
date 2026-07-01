#!/usr/bin/env bash
set -e -u -o pipefail

# Launch tuicr in a new wezterm tab to review git changes. Intended for use
# from WSL, where the wezterm GUI/mux host runs on Windows. Therefore this
# wrapper dispatches to the Windows `wezterm.exe` (via WSL interop) rather than
# the Linux `wezterm` build, which cannot control the Windows mux.

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

Launch tuicr in a new wezterm tab to review git changes. Meant for WSL: the
wezterm GUI host runs on Windows, so this script calls wezterm.exe via WSL
interop.

Arguments:
  directory    Git repository directory to review (default: current directory)

Environment variables:
  WEZTERM_CLI        Override the wezterm CLI binary (default: auto-detect
                     wezterm.exe under WSL, else wezterm)
  TUICR_TAB_TITLE    Title for the new wezterm tab (default: "Review")

Examples:
  $(basename "$0")                    # Review changes in current directory
  $(basename "$0") ~/project          # Review changes in ~/project
  TUICR_TAB_TITLE="PR #42" $(basename "$0")
EOF
}

detect_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null
}

resolve_wezterm_cli() {
  if [[ -n "${WEZTERM_CLI:-}" ]]; then
    echo "$WEZTERM_CLI"
    return 0
  fi
  if detect_wsl; then
    if command -v wezterm.exe &>/dev/null; then
      echo wezterm.exe
      return 0
    fi
    return 1
  fi
  if command -v wezterm &>/dev/null; then
    echo wezterm
    return 0
  fi
  return 1
}

check_wezterm() {
  local cli="$1"
  if ! command -v "$cli" &>/dev/null; then
    return 1
  fi
  if ! "$cli" cli list &>/dev/null; then
    log_error "$cli cli list failed - mux server not reachable."
    log_error "Ensure wezterm GUI is running and the mux server is enabled."
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

detect_existing_tuicr_pane() {
  # `wezterm cli list --format json` rows have a "foreground" field with the
  # foreground process name. Match a trailing tuicr.
  "$WEZTERM_CLI" cli list --format json 2>/dev/null | jq -e '
    [.[].foreground // "" | select(test("(^|.*/)tuicr$"))] | length > 0
  ' >/dev/null 2>&1
}

launch_tuicr_tab() {
  local target_dir="$1"
  local title="${TUICR_TAB_TITLE:-Review}"

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

  log_info "Launching tuicr in a new wezterm tab"
  log_info "Directory: $target_dir"
  log_info "Tab title: $title"

  # The spawned tab runs a login shell that cd's to target and runs tuicr.
  local sh_cmd="cd '$target_dir' && $tuicr_cmd; printf '\\nTUICR_DONE_$$\\n'"

  local pane_id
  pane_id=$("$WEZTERM_CLI" cli spawn --cwd "$target_dir" -- bash -lc "$sh_cmd")

  log_info "tuicr is running in pane $pane_id"
  log_info "Waiting for tuicr to exit..."

  # Poll the pane's tail until the sentinel appears or the pane is gone.
  while true; do
    if ! "$WEZTERM_CLI" cli get-text --pane-id "$pane_id" &>/dev/null; then
      break
    fi
    local last_lines
    last_lines=$("$WEZTERM_CLI" cli get-text --pane-id "$pane_id" 2>/dev/null | tail -n 2 || true)
    if echo "$last_lines" | grep -q "TUICR_DONE_"; then
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

  if detect_wsl; then
    log_info "WSL detected; will use wezterm.exe (Windows host)"
  fi

  WEZTERM_CLI=$(resolve_wezterm_cli) || {
    log_error "Could not find a wezterm CLI."
    if detect_wsl; then
      log_error "Under WSL, ensure the Windows wezterm install is on your"
      log_error "Windows PATH so WSL interop can resolve wezterm.exe."
    else
      log_error "Install wezterm or set WEZTERM_CLI to its path."
    fi
    exit 1
  }
  export WEZTERM_CLI

  if ! check_wezterm "$WEZTERM_CLI"; then
    log_error "Not connected to a wezterm GUI/mux instance."
    exit 1
  fi

  if detect_existing_tuicr_pane; then
    log_warn "tuicr appears to already be running in another wezterm pane/tab"
    log_info "Switch tabs with Ctrl+Shift+Tab / Ctrl+Tab"
    exit 0
  fi

  launch_tuicr_tab "$target_dir"
}

main "$@"