#!/usr/bin/env bash

CORE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$CORE_DIR/fetch.sh"
source "$CORE_DIR/ask.sh"
source "$CORE_DIR/consolog.sh"
source "$CORE_DIR/url.sh"
