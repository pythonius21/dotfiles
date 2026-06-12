#!/usr/bin/env bash
# Audio ducking for Quod Libet: lowers volume when a browser starts playing audio,
# restores it when the browser stops.
#
# Dependencies: bash, pactl (pipewire-pulse or pulseaudio), bc, playerctl
#
# Usage: ./quodlibet-duck.sh [--daemonize]

set -euo pipefail

# --- Configuration ---
QUODLIBET_MATCH="Quod Libet"
BROWSER_MATCHES=("Firefox" "Librewolf" "LibreWolf" "Brave" "brave" "Chromium" "chrome")
FADE_DURATION=1.0
FADE_STEPS=30
DUCK_LEVEL=0.05
POLL_INTERVAL=0.3

ORIGINAL_VOLUME=""
DUCKED=false
USE_PACTL=false

quodlibet_running() {
  if [[ "$USE_PACTL" == true ]]; then
    pactl list sink-inputs 2>/dev/null | awk '
      /application.name = / {
        gsub(/^[[:space:]]*application.name = "/, "", $0)
        gsub(/"$/, "", $0)
        if (tolower($0) ~ tolower("'"$QUODLIBET_MATCH"'")) { found=1; exit }
      }
      END { exit !found }
    '
  else
    playerctl --player=quodlibet status 2>/dev/null >/dev/null
  fi
}

get_quodlibet_sink() {
  pactl list sink-inputs 2>/dev/null | awk '
    /Sink Input #[0-9]+/ {
      match($3, /[0-9]+/)
      id = substr($3, RSTART, RLENGTH)
    }
    /application.name = / {
      gsub(/^[[:space:]]*application.name = "/, "", $0)
      gsub(/"$/, "", $0)
      if (tolower($0) ~ tolower("'"$QUODLIBET_MATCH"'")) { print id; exit }
    }
  '
}

get_active_browser_sinks() {
  local pattern
  pattern=$(
    IFS="|"
    echo "${BROWSER_MATCHES[*]}"
  )
  pactl list sink-inputs 2>/dev/null | awk -v pattern="$pattern" '
    /Sink Input #[0-9]+/ {
      match($3, /[0-9]+/)
      id = substr($3, RSTART, RLENGTH)
      corked[id] = "unknown"
      app[id] = ""
    }
    /Corked: (yes|no)/ { corked[id] = $2 }
    /application.name = / {
      gsub(/^[[:space:]]*application.name = "/, "", $0)
      gsub(/"$/, "", $0)
      app[id] = $0
    }
    END {
      for (id in app) {
        if (app[id] != "" && tolower(app[id]) ~ tolower(pattern) && corked[id] != "yes")
          print id
      }
    }
  ' | sort -u
}

get_quodlibet_volume() {
  if [[ "$USE_PACTL" == true ]]; then
    local id
    id=$(get_quodlibet_sink) || return 1
    pactl list sink-inputs 2>/dev/null | awk -v id="$id" '
      /Sink Input #'"$id"'/ {found=1; next}
      found && /Volume:/ {
        match($0, /[0-9]+%/, a)
        gsub(/%/, "", a[0])
        print a[0] / 100
        exit
      }
    '
  else
    playerctl --player=quodlibet volume 2>/dev/null || return 1
  fi
}

set_quodlibet_volume() {
  local value=$1
  if [[ "$USE_PACTL" == true ]]; then
    local id pct
    id=$(get_quodlibet_sink) || return 1
    pct=$(bc -l <<<"scale=0; $value * 100 / 1")
    pactl set-sink-input-volume "$id" "${pct}%" 2>/dev/null || true
  else
    playerctl --player=quodlibet volume "$value" 2>/dev/null || true
  fi
}

fade_to() {
  local target=$1
  local current
  current=$(get_quodlibet_volume) || return 1
  [[ -z "$current" ]] && return 1

  for ((i = 1; i <= FADE_STEPS; i++)); do
    local frac
    frac=$(bc -l <<<"scale=4; $current + ($target - $current) * $i / $FADE_STEPS")
    set_quodlibet_volume "$frac"
    sleep "$(bc -l <<<"$FADE_DURATION / $FADE_STEPS")"
  done
  set_quodlibet_volume "$target"
}

monitor() {
  if ! playerctl --player=quodlibet status 2>/dev/null >/dev/null; then
    echo "quodlibet-duck: playerctl not available, falling back to pactl"
    USE_PACTL=true
  fi

  echo "quodlibet-duck: monitoring started (PID $$)"
  echo "  Fade duration: ${FADE_DURATION}s"
  echo "  Duck level: $(bc -l <<<"$DUCK_LEVEL * 100")%"
  echo "  Volume control: $([[ "$USE_PACTL" == true ]] && echo "pactl" || echo "playerctl")"
  echo "  Monitored browsers: ${BROWSER_MATCHES[*]}"

  while true; do
    if ! quodlibet_running; then
      if [[ "$DUCKED" == true ]]; then
        DUCKED=false
      fi
      sleep "$POLL_INTERVAL"
      continue
    fi

    browser_sinks=($(get_active_browser_sinks))

    if [[ ${#browser_sinks[@]} -gt 0 ]] && [[ "$DUCKED" == false ]]; then
      ORIGINAL_VOLUME=$(get_quodlibet_volume)
      echo "  Browser audio detected, ducking Quod Libet $(bc -l <<<"$ORIGINAL_VOLUME * 100")% -> $(bc -l <<<"$DUCK_LEVEL * 100")%"
      fade_to "$DUCK_LEVEL"
      DUCKED=true
    elif [[ ${#browser_sinks[@]} -eq 0 ]] && [[ "$DUCKED" == true ]]; then
      local restore_to="${ORIGINAL_VOLUME:-1}"
      echo "  Browser audio stopped, restoring Quod Libet $(bc -l <<<"$DUCK_LEVEL * 100")% -> $(bc -l <<<"$restore_to * 100")%"
      fade_to "$restore_to"
      DUCKED=false
      ORIGINAL_VOLUME=""
    fi

    sleep "$POLL_INTERVAL"
  done
}

case "${1:-}" in
--daemonize | -d)
  nohup "$0" >/dev/null 2>&1 &
  echo "quodlibet-duck: started in background (PID $!)"
  ;;
--help | -h)
  echo "Usage: $0 [--daemonize]"
  echo "  --daemonize, -d   Run in background"
  echo "  --help, -h        Show this help"
  ;;
"")
  monitor
  ;;
*)
  echo "Unknown option: $1"
  exit 1
  ;;
esac
