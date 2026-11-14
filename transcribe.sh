#!/bin/bash
# usage: ./transcribe.sh video.mp4  ->  creates video.txt
# crash-safe: audio is split into chunks and transcribed one by one.
# If it crashes or you Ctrl-C, just run it again - finished chunks are skipped.
# Delete the ".name-chunks/" folder next to the input to start over.
set -e
f="$1"
[ -f "$f" ] || { echo "no such file: $f"; exit 1; }

CHUNK=${CHUNK:-300}  # seconds per chunk; a crash loses at most this much
DIR="$(cd "$(dirname "$0")" && pwd)"
CLI="$DIR/whisper.cpp/build/bin/whisper-cli"
MODEL="$DIR/whisper.cpp/models/ggml-base.bin"

# ponytail: cuts at fixed times, so a word at a chunk boundary can clip - silence-aware cutting if that ever matters
W="$(dirname "$f")/.$(basename "${f%.*}")-chunks"
mkdir -p "$W"

DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f")
DUR=${DUR%.*}

for ((s = 0; s < DUR; s += CHUNK)); do
    c="$W/$(printf '%05d' "$s")"
    [ -s "$c.txt" ] && continue   # already done -> resume skips it
    echo "transcribing ${f}: ${s}s..$((s + CHUNK))s"
    ffmpeg -loglevel error -y -ss "$s" -t "$CHUNK" -i "$f" -ar 16000 -ac 1 "$c.wav"
    "$CLI" -m "$MODEL" -f "$c.wav" -nt -otxt -of "$c" >/dev/null 2>&1
    rm -f "$c.wav"
done

: > "${f%.*}.txt"
for t in "$W"/*.txt; do
    [ -e "$t" ] || break
    cat "$t" >> "${f%.*}.txt"
done
echo "saved: ${f%.*}.txt"
