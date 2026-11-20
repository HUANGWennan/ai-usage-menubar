#!/bin/sh
set -eu
cd "$(dirname "$0")/.."

./build.sh
app='build/GPT Quota Countdown.app'
codesign --verify --strict "$app"
binary="$app/Contents/MacOS/GPTQuotaCountdown"
plugin='./deepseek/deepseek-pricing.1m.sh'
fixture=$(mktemp)
trap 'rm -f "$fixture"' EXIT

expect() {
    if [ "$1" != "$2" ]; then
        printf 'Expected %s, got %s\n' "$1" "$2" >&2
        exit 1
    fi
}

# These timestamps and snapshot fields are synthetic.
now=1900000000
reset=$((now + 3661 - 978307200))
printf '{"records":[{"snapshot":{"primary":{"windowMinutes":300,"resetsAt":%s}}}]}\n' "$reset" > "$fixture"
expect '1h02m' "$("$binary" --preview "$fixture" "$now")"
expect '0m' "$("$binary" --preview "$fixture" "$((now + 3661))")"
printf '{}' > "$fixture"
expect '—' "$("$binary" --preview "$fixture" "$now")"

check_deepseek() {
    timestamp=$(TZ=Asia/Shanghai /bin/date -j -f '%F %T' "$1" +%s)
    output=$(TZ=Asia/Shanghai DEEPSEEK_SWITCH_FORMAT="$2" "$plugin" "$timestamp")
    title=$(printf '%s\n' "$output" | /usr/bin/sed -n '1s/ |.*//p')
    expect "$3" "$title"
    printf '%s\n' "$output" | /usr/bin/grep -Fq "$4"
}

check_deepseek '2026-11-20 08:59:59' countdown '1m' '空闲时段'
check_deepseek '2026-11-20 09:00:00' countdown '3h00m' '高峰时段'
check_deepseek '2026-11-20 12:00:00' time '14:00' '空闲时段'
check_deepseek '2026-11-20 14:00:00' countdown '4h00m' '高峰时段'
check_deepseek '2026-11-20 18:00:00' time '11/23 09:00' '空闲时段'
check_deepseek '2027-04-05 10:00:00' time '明日 09:00' '空闲时段'
printf 'GPT and DeepSeek checks passed.\n'
