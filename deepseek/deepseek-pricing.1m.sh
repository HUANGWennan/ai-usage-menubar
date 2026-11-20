#!/bin/sh
# <swiftbar.title>DeepSeek 峰谷时段</swiftbar.title>
# <swiftbar.desc>按北京时间计算 DeepSeek 模型 API 的峰谷计费时段</swiftbar.desc>
# <swiftbar.type>streamable</swiftbar.type>
# <swiftbar.useTrailingStreamSeparator>true</swiftbar.useTrailingStreamSeparator>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
set -eu
display=${DEEPSEEK_SWITCH_FORMAT:-time}
case "$display" in
    time|countdown) ;;
    *) printf '%s\n' 'DEEPSEEK_SWITCH_FORMAT must be time or countdown' >&2; exit 2 ;;
esac

# https://api-docs.deepseek.com/zh-cn/quick_start/pricing/
# 2026 https://www.beijing.gov.cn/cs/gncs/zcwj/202603/t20260327_4568275.html
# 2027 https://www.forestry.gov.cn/lyj/1/szxx/20261105/695102.html
holiday_dates='
2026-01-01 2026-01-03
2026-02-15 2026-02-23
2026-04-04 2026-04-06
2026-05-01 2026-05-05
2026-06-19 2026-06-21
2026-09-25 2026-09-27
2026-10-01 2026-10-07
2027-01-01 2027-01-03
2027-02-05 2027-02-13
2027-04-03 2027-04-05
2027-05-01 2027-05-05
2027-06-09 2027-06-09
2027-09-15 2027-09-15
2027-10-01 2027-10-07
'

is_peak_day() {
    case "$2" in 6|7) return 1 ;; esac
    day_number=$(printf '%s' "$1" | /usr/bin/tr -d '-')
    while read -r start end; do
        [ -n "$start" ] || continue
        start_number=$(printf '%s' "$start" | /usr/bin/tr -d '-')
        end_number=$(printf '%s' "$end" | /usr/bin/tr -d '-')
        if [ "$day_number" -ge "$start_number" ] && [ "$day_number" -le "$end_number" ]; then
            return 1
        fi
    done <<HOLIDAYS
$holiday_dates
HOLIDAYS
    return 0
}

# Vector PDF icons at menu-bar size.
peak_icon='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YUJveCBbMCAwIDIwIDE4XSAvQ291bnQgMSAvS2lkcyBbIDEgMCBSIF0gPj4KZW5kb2JqCjcgMCBvYmoKPDwgL1R5cGUgL0NhdGFsb2cgL1BhZ2VzIDIgMCBSID4+CmVuZG9iago4IDAgb2JqCjw8IC9Qcm9kdWNlciAobWFjT1MgVmVyc2lvbiAyNy4yIFwoQnVpbGQgMjZCMTIzXCkgUXVhcnR6IFBERkNvbnRleHQpIC9DcmVhdGlvbkRhdGUKKEQ6MjAyNjExMTEwMzA2MDZaMDAnMDAnKSAvTW9kRGF0ZSAoRDoyMDI2MTExMTAzMDYwNlowMCcwMCcpID4+CmVuZG9iagp4cmVmCjAgOQowMDAwMDAwMDAwIDY1NTM1IGYgCjAwMDAwMDA0MTYgMDAwMDAgbiAKMDAwMDAwMTc3MSAwMDAwMCBuIAowMDAwMDAwNDk2IDAwMDAwIG4gCjAwMDAwMDAwMjIgMDAwMDAgbiAKMDAwMDAwMTczNiAwMDAwMCBuIAowMDAwMDAwNTY0IDAwMDAwIG4gCjAwMDAwMDE4NTIgMDAwMDAgbiAKMDAwMDAwMTkwMSAwMDAwMCBuIAp0cmFpbGVyCjw8IC9TaXplIDkgL1Jvb3QgNyAwIFIgL0luZm8gOCAwIFIgL0lEIFsgPGU3YTgwZWJjYmU4Y2JkNGVlMzJhMjUyODcwMjJhODZkPgo8ZTdhODBlYmNiZThjYmQ0ZWUzMmEyNTI4NzAyMmE4NmQ+IF0gPj4Kc3RhcnR4cmVmCjIwNjMKJSVFT0YK'
offpeak_icon='JVBERi0xLjMKJcTl8uXrp/Og0MTGCjQgMCBvYmoKPDwgL0xlbmd0aCAxNjUgL0ZpbHRlciAvRmxhdGVEZWNvZGUgPj4Kc3RyZWFtCngBPU85DsMwDNv9Cr5AtWwrUeZs2QI/wUtRtEPQId+vfHWwTFEkRF04cYEpCW4wDnsvPPYvY8/wFJIVDVYS8g5eKAg2fAbiYEZeFRw7cCxVwR4dFCwkSUMYfaTVptPVug0FDchQDocLTevR/vJf0fueZFpmroInsp1wQymC2YpF9W4jEbwrsXbWsEdj67yGrHMlO46iVBNP3GkdnFPTZZw/wMA9jQplbmRzdHJlYW0KZW5kb2JqCjEgMCBvYmoKPDwgL1R5cGUgL1BhZ2UgL1BhcmVudCAyIDAgUiAvUmVzb3VyY2VzIDMgMCBSIC9Db250ZW50cyA0IDAgUiA+PgplbmRvYmoKMyAwIG9iago8PCAvUHJvY1NldCBbIC9QREYgXSAvQ29sb3JTcGFjZSA8PCAvQ3MxIDUgMCBSID4+ID4+CmVuZG9iago2IDAgb2JqCjw8IC9OIDMgL0FsdGVybmF0ZSAvRGV2aWNlUkdCIC9MZW5ndGggMTA3MiAvRmlsdGVyIC9GbGF0ZURlY29kZSA+PgpzdHJlYW0KeAGFVVtoHFUY/jdzdlfIOg9im5pKOnhrKEnZpKIJtdG9JJtt43bZXLRBkM3s2Z1pJjvjzGx6ofhQBEEEo4JPgve3Qp+EeKm2L7aI0kKJEgyi4EPrjUKlLxLW78zszu6GYGfZM9/8/3++//zff84MUfRK0bKMLoVoqerahUxSef7YvBJdpy56gLqpl7qLqmMl8vkpwiVixb3zuvMDhYTl+uD2/s7oLU/dJe6oRKF7YDdLjroEfJIo/Jpq2S5RlME+csK1BH4K+H4bCwTOC1zxcUngBR9jLmJmCinEvA4sq1oR/ui7wAMLbfZKG/bXgAjMzfAqt3VVEVrkbbOsG9xz+MNd3G2R/weXjBpq9q49GGPO4vQR3PtR+yulYlrgR4DPqcXx6Qa+tqzP5Rr4H8tNFoAfI+raVVucTQDvAx4r2xOzwODp0rTaZBOvnNZmnoP9PthXF80jYu5O4G+rC7mjwILnF9VJQVd6iEiKaDwr+t0H3G+bBRGD9UgTJZ4eBx4APq672Rlg5JLecZanhd3jOa2lxDqRS/rqePGw6FMv8DVuZERewf+75eYbeVmsauRELvCwYe549YKHxVxtZhJ25GXzLhrqz2Uvl/WJbCP+fc2eFHYx94pleHsUa2O37FpB1I5c4Qd5dVZoCM7wWNEezzRwieZCReJk0gJGlaq0SQoVKENJ3C2y4SmTTgYsHF4OC8dTM2awIybv+f34ZoRCFW/mDczUkSHV9wnVMF+jP8GnBUwKpfBUg61C2/P4K7jZ4DFZD4uzA/gfZFPsEBtho6Swp9kzbIylYR1lBwPufFsdYj03kcXneQkZuRc3h4ovoTKXihh/RYRJTsDQocVKb63f1+is/aKuXn3j1uUzX+5qxa6x1Reuxy6fadNMB9diENGp2tG7aR/+LXwjvIZxPbwRcCjhn8Ib+K1DrVaXtqou+iVUT6Amw+vEEurVUR1vq26wg6Odz2zla/SxyWiWqyu9vgpCAf5q7k6Ozg604uM/xv+Kr8U/iH8c/0N6W/pUuiB9Jn0ufUeKdFG6JH0tfSOdl74I4rfvub93gp57dQibqELsx2a97Ypif8pJebf8sJyW98iPylNBlCL3yEPypLwXnt1Bd1q7WenQQadj0Kyp1va5xMnQAyZoHboXfdZbGTvOxyxWrNMJcNpQX+yzKp1CbPs5a1TE+tgQy27Z1SNirwfc/nlo9qOpRGcNPDIeSUcSpET2RUYjQ5HDAjfPd2QvfKMY8dZy+Ul8W4hSpnXK1iuaqwzH408qCXzquJKtqvsHlKJhKJ7LUWzucHuZl/aT+E6KeUS3C973L7TzasvmPkt06G/x3mvZ5mtE5xyinsdbtn68G3e8R7T6hFqzl30+CoW+J3LKB4a951AsiXfXz/X6bbzDom8Rbb5Zr//7Yb2++RH4N4guGv8B/yV4CwplbmRzdHJlYW0KZW5kb2JqCjUgMCBvYmoKWyAvSUNDQmFzZWQgNiAwIFIgXQplbmRvYmoKMiAwIG9iago8PCAvVHlwZSAvUGFnZXMgL01lZGlhQm94IFswIDAgMjAgMThdIC9Db3VudCAxIC9LaWRzIFsgMSAwIFIgXSA+PgplbmRvYmoKNyAwIG9iago8PCAvVHlwZSAvQ2F0YWxvZyAvUGFnZXMgMiAwIFIgPj4KZW5kb2JqCjggMCBvYmoKPDwgL1Byb2R1Y2VyIChtYWNPUyBWZXJzaW9uIDI3LjIgXChCdWlsZCAyNkIxMjNcKSBRdWFydHogUERGQ29udGV4dCkgL0NyZWF0aW9uRGF0ZQooRDoyMDI2MTExMTAzMDYwNlowMCcwMCcpIC9Nb2REYXRlIChEOjIwMjYxMTExMDMwNjA2WjAwJzAwJykgPj4KZW5kb2JqCnhyZWYKMCA5CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDI1OSAwMDAwMCBuIAowMDAwMDAxNjE0IDAwMDAwIG4gCjAwMDAwMDAzMzkgMDAwMDAgbiAKMDAwMDAwMDAyMiAwMDAwMCBuIAowMDAwMDAxNTc5IDAwMDAwIG4gCjAwMDAwMDA0MDcgMDAwMDAgbiAKMDAwMDAwMTY5NSAwMDAwMCBuIAowMDAwMDAxNzQ0IDAwMDAwIG4gCnRyYWlsZXIKPDwgL1NpemUgOSAvUm9vdCA3IDAgUiAvSW5mbyA4IDAgUiAvSUQgWyA8YTczYjZiNjU4MWNiYjA1MzdiOGU2ZDY4MTBmNzI4MzA+CjxhNzNiNmI2NTgxY2JiMDUzN2I4ZTZkNjgxMGY3MjgzMD4gXSA+PgpzdGFydHhyZWYKMTkwNgolJUVPRgo='

render_status() {
    now=${1:-$(/bin/date +%s)}
    set -- $(TZ=Asia/Shanghai /bin/date -r "$now" '+%F %u %H%M')
    beijing_day=$1
    weekday=$2
    clock=$3
    icon=$offpeak_icon
    rate='空闲时段 · 峰价的 50%'
    next_state=峰
    boundary=

    if is_peak_day "$beijing_day" "$weekday"; then
        case "$clock" in
            0[0-8]*) boundary=09:00 ;;
            09*|10*|11*) boundary=12:00; next_state=谷 ;;
            12*|13*) boundary=14:00 ;;
            14*|15*|16*|17*) boundary=18:00; next_state=谷 ;;
        esac
    fi

    if [ "$next_state" = 谷 ]; then
        icon=$peak_icon
        rate='高峰时段 · 全价'
    fi

    if [ -z "$boundary" ]; then
        boundary=09:00
        days_ahead=1
        while :; do
            set -- $(TZ=Asia/Shanghai /bin/date -r "$now" -v+"${days_ahead}"d '+%F %u')
            beijing_day=$1
            if is_peak_day "$beijing_day" "$2"; then
                break
            fi
            days_ahead=$((days_ahead + 1))
        done
    fi

    next_epoch=$(TZ=Asia/Shanghai /bin/date -j -f '%Y-%m-%d %H:%M:%S' "$beijing_day $boundary:00" +%s)
    next_local=$(/bin/date -r "$next_epoch" '+%m/%d %H:%M %Z')

    # A short menu-bar hint: the switch time in local time, prefixed only when it
    # falls on a later local day so the two-character prefix stays out of the way.
    switch_clock=$(/bin/date -r "$next_epoch" '+%H:%M')
    switch_day=$(/bin/date -r "$next_epoch" '+%F')
    today=$(/bin/date -r "$now" '+%F')
    if [ "$switch_day" = "$today" ]; then
        switch_hint=$switch_clock
    elif [ "$switch_day" = "$(/bin/date -r "$now" -v+1d '+%F')" ]; then
        switch_hint="明日 $switch_clock"
    else
        switch_hint="$(/bin/date -r "$next_epoch" '+%m/%d') $switch_clock"
    fi

    minutes=$(((next_epoch - now + 59) / 60))
    if [ "$display" = countdown ]; then
        if [ "$minutes" -ge 60 ]; then
            switch_hint=$(printf '%dh%02dm' "$((minutes / 60))" "$((minutes % 60))")
        else
            switch_hint="${minutes}m"
        fi
    fi
    frame=$(
        printf '%s\n' "$switch_hint | image=$icon dropdown=false tooltip='DeepSeek · $rate · 下次切换「${next_state}」${next_local}'" '---'
        printf '%s\n' "DeepSeek · $rate" "下次切换为「${next_state}」 · $next_local"
        if [ "$beijing_day" \> 2027-12-31 ]; then
            printf '%s\n' '节假日表已到期，仅按周一至周五估算'
        fi
        printf '%s\n' '官方计费规则 | href=https://api-docs.deepseek.com/zh-cn/quick_start/pricing/'
    )
}

# A supplied timestamp renders a single snapshot for checking schedule boundaries.
if [ "$#" -gt 0 ]; then
    render_status "$1"
    printf '%s\n' "$frame"
    exit
fi

# SwiftBar restarts the stream on wake. Keep the same filename so the
# menu-bar position is preserved; streamable plugins use their own schedule.
sleep_pid=
trap 'if [ -n "$sleep_pid" ]; then kill "$sleep_pid" 2>/dev/null || :; fi; exit 0' TERM INT HUP
while :; do
    render_status
    printf '%s\n' "$frame" '~~~'
    remaining=$((next_epoch - $(/bin/date +%s)))
    if [ "$remaining" -gt 0 ]; then
        if [ "$display" = countdown ]; then
            # Update only when the displayed minute or price state changes.
            tick=$(((remaining - 1) % 60 + 1))
            remaining=$tick
        fi
        /bin/sleep "$remaining" &
        sleep_pid=$!
        wait "$sleep_pid"
        sleep_pid=
    fi
done
