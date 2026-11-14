# mp4-to-text

Convert MP4 (and other audio/video) files to text with [whisper.cpp](https://github.com/ggml-org/whisper.cpp) — 100% free, no API keys, no uploads.

## Website (in-browser, free hosting)

[https://blogdoon.github.io/mp4-to-text/](https://blogdoon.github.io/mp4-to-text/)

Runs entirely in your browser via WebAssembly — your files never leave your machine. Powered by the official `whisper.wasm` example from whisper.cpp.

**Crash protection:** transcription progress is autosaved in your browser at least once a minute. After a crash or accidental close: reload, load the same model + file, press Transcribe — it resumes from the last saved segment (with a 2 s overlap so no words are missed). "Clear saved progress" starts over.

## Local CLI (faster, no length limits)

```bash
./transcribe.sh video.mp4   # -> video.txt
```

One-time setup:

```bash
git clone --depth 1 https://github.com/ggml-org/whisper.cpp
cd whisper.cpp
cmake -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j8 --config Release
bash models/download-ggml-model.sh base
```

Requires `ffmpeg`. Needs ~150 MB RAM for the base model; transcribes ~3–4x faster than realtime on a modern CPU.
