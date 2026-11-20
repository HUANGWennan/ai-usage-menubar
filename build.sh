#!/bin/sh
set -eu

cd "$(dirname "$0")"
app="build/GPT Quota Countdown.app"
mkdir -p "$app/Contents/MacOS"
xcrun swiftc -O gpt/main.swift -o "$app/Contents/MacOS/GPTQuotaCountdown"
cp gpt/Info.plist "$app/Contents/Info.plist"
codesign --force --sign - "$app"
printf '%s\n' "$app"
