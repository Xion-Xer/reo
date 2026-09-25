#!/usr/bin/env bash

decodeURIComponent() {
    local url="${1//+/ }"
    printf '%b\n' "${url//%/\\x}"
}
