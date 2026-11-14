#!/bin/bash
# usage: ./transcribe.sh video.mp4  ->  creates video.txt
set -e
f="$1"
t=$(mktemp --suffix=.wav)
trap 'rm -f "$t"' EXIT
ffmpeg -loglevel error -y -i "$f" -ar 16000 -ac 1 "$t"
DIR="$(cd "$(dirname "$0")" && pwd)"
"$DIR/whisper.cpp/build/bin/whisper-cli" \
  -m "$DIR/whisper.cpp/models/ggml-base.bin" \
  -f "$t" -otxt -of "${f%.*}"
