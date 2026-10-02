#!/usr/bin/env bash
# Regenerates AgroCampo's UI sound effects (specs/004, master.md "Sonido").
# Every sound is synthesized here from sine tones, so the assets are original
# project work with no third-party license. Requires ffmpeg with libvorbis.
set -euo pipefail

out="$(cd "$(dirname "$0")/.." && pwd)/frontend/assets/sounds"
mkdir -p "$out"

# Plucked tone: frequency $1 (Hz), start $2 (s), decay rate $3, gain $4.
tone() {
  echo "$4*between(t,$2,9)*exp(-$3*(t-$2))*(sin(2*PI*$1*(t-$2))+0.25*sin(4*PI*$1*(t-$2)))"
}

render() {
  local name="$1" duration="$2" expr="$3"
  ffmpeg -loglevel error -y \
    -f lavfi -i "aevalsrc='${expr}':s=44100:d=${duration}" \
    -af "afade=t=in:d=0.004,afade=t=out:st=$(awk "BEGIN{print $duration - 0.03}"):d=0.03" \
    -ac 1 -c:a libvorbis -q:a 2 "$out/$name.ogg"
}

# Short soft click for primary buttons.
render tap 0.06 "0.35*exp(-90*t)*sin(2*PI*1800*t)"

# Gentle two-note confirmation for settings, profile and export saves.
render saved 0.35 "$(tone 1318.5 0 14 0.3)+$(tone 1760 0.09 12 0.3)"

# Distinctive rising arpeggio for a saved agricultural record.
render record_saved 0.75 "$(tone 1046.5 0 9 0.22)+$(tone 1318.5 0.07 9 0.22)+$(tone 1568 0.14 8 0.22)+$(tone 2093 0.21 6 0.24)"

# Low descending pair for failed saves or invalid fields.
render error 0.4 "$(tone 440 0 10 0.35)+$(tone 349.2 0.13 9 0.35)"

ls -l "$out"
