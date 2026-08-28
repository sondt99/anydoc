#!/bin/sh
# Run an anydoc conversion under hard resource caps.
#
# The converter parses hostile binary formats in safe Rust: it cannot execute
# code, write files, or open a socket, so the worst a malicious document can
# do is exhaust memory or spin. These caps bound that structurally, including
# on parser paths no source audit has reached. Use this for documents you did
# not produce; it is unnecessary for your own files.
#
# Usage: scripts/anydoc-sandboxed.sh <command...>
#   scripts/anydoc-sandboxed.sh node node/cli.js untrusted.docx
#   scripts/anydoc-sandboxed.sh ./target/release/examples/convert untrusted.ppt
#
# Env:
#   ANYDOC_MEM_KB   address-space ceiling in KiB (default 2 GiB)
#   ANYDOC_CPU_SEC  CPU-time ceiling in seconds  (default 60)
#   ANYDOC_TIMEOUT  wall-clock ceiling           (default 60s)

set -eu

if [ "$#" -eq 0 ]; then
    echo "usage: $0 <command...>" >&2
    exit 2
fi

ulimit -v "${ANYDOC_MEM_KB:-2097152}"
ulimit -t "${ANYDOC_CPU_SEC:-60}"
ulimit -c 0

# A document must never be able to upload itself, whatever flags reach the CLI.
unset ANYDOC_ALLOW_UPLOAD

exec timeout --signal=KILL "${ANYDOC_TIMEOUT:-60}" "$@"
